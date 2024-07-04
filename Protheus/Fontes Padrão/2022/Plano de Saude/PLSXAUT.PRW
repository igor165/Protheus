#INCLUDE "plsxaut.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMCCR.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "TOPCONN.CH"

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

STATIC __cCdTbPd  	:= ""
STATIC __aNiveis  	:= {}
STATIC __bRetErr  	:= { |cNivCri,cChaveAut| { .f., aCodCri, cNivCri, cChaveAut } }
STATIC __bRetAut  	:= { |cAutoriza,cNivAut,cChaveAux| {.t., cAutoriza, cNivAut, cChaveAux } }
STATIC __bErrXML  	:= { |aCodCri| cNvCriXML := PL973PATH(aCodCri) }
STATIC __cTissVer 	:= PLSTISSVER()
STATIC aCodCri    	:= {}
STATIC nItensBrw  	:= 0
STATIC lPLSXMUDFAS	:= isInCallStack("PLSXMUDFAS")
STATIC lPLVLPROAUT	:= existBlock("PLVLPROAUT")
STATIC lPLSAUT03	:= existBlock("PLSAUT03")
STATIC lPLAUTPRI	:= existBlock("PLAUTPRI")
STATIC lPLSAUT02	:= existBlock("PLSAUT02")
STATIC lPLSA268A	:= findFunction("PLSA268A")
STATIC nMV_QTDPROC	:= getNewPar("MV_QTDPROC",0)
STATIC cMV_PLSUNCR	:= getNewPar("MV_PLSUNCR","0")
STATIC cMV_PLSUNI	:= getNewPar("MV_PLSUNI","1")
STATIC cMV_PLSGEIN	:= getNewPar("MV_PLSGEIN","")
STATIC cMV_PLSNAPL	:= getNewPar("MV_PLSNAPL","XX")
STATIC cMV_PLSTPIN	:= getNewPar("MV_PLSTPIN","OPE")
STATIC cMV_VLDREGI	:= getNewPar("MV_VLDREGI","0")
STATIC cMV_PLSGLAN	:= getNewPar("MV_PLSGLAN","035")
STATIC __cCodCon  	:= getNewPar("MV_PLSCDCO","")
STATIC __cDesGenPtu := getNewPar("MV_PLMEDPT","")+"-"+getNewPar("MV_PLMATPT","")+"-"+getNewPar("MV_PLTAXPT","")+"-"+getNewPar("MV_PLOPMPT","")
STATIC UID_AUTP		:= 'PLSAUTP'

#DEFINE __aCdCri049 {"020",STR0161}//"O valor contratato e diferente do valor informado/apresentado."
#DEFINE __aCdCri074 {"038",STR0193}//"Produto do usuario nao permite atendimento por esta Rede de Atendimento."
#DEFINE __aCdCri088 {"054",STR0192}//"O usuario autorizado e diferente do usuario que esta sendo cobrado pela operadora destino."
#DEFINE __aCdCri096 {"060",STR0056}//"Operadora do usuario bloqueada para atendimento em intercambio."
#DEFINE __aCdCri098 {"062",STR0057}//"Procedimento não existente na liberação de origem."
#DEFINE __aCdCri099 {"063",STR0133}//"Participacao de servico informada invalida."
#DEFINE __aCdCri100 {"064",STR0058}//"Credenciado bloqueado no subcontrato do usuario."
#DEFINE __aCdCri101 {"065",STR0059}//"Credenciado bloqueado no produto do usuario."
#DEFINE __aCdCri104 {"705",STR0060}//"Rede de atendimento de Alto Custo"
#DEFINE __aCdCri122 {"069",STR0063}//"Quantidade de diarias pre-autorizadas diferente da quantidade de diarias contidas na guia."
#DEFINE __aCdCri123 {"070",STR0064}//"Codigo de diaria contido na guia nao localizado na autorizacao de origem."
#DEFINE __aCdCri124 {"071",STR0065}//"Dente/Regiao nao autorizado(a) a ser selecionado(a) para este procedimento."}
#DEFINE __aCdCri125 {"072",STR0061}//"localidade não é permitida para este usuário"
#DEFINE __aCdCri126 {"552",STR0066}//"Tipo de Admissão Inválida"
#DEFINE __aCdCri127 {"553",STR0067}//"Tipo de Contrato Inválido"
#DEFINE __aCdCri128 {"554",STR0068}//"Tipo de Atendimento Inválido"
#DEFINE __aCdCri135 {"073",STR0064}//"Não foram selecionadas todas as faces necessárias para o dente "
#DEFINE __aCdCri136 {"074",STR0070}//"Não é permitido Selecionar faces não autorizadas para o dente "
#DEFINE __aCdCri137 {"075",STR0071}//"Não há seleção válida para este procedimento. "
#DEFINE __aCdCri138 {"076",STR0069}//"Não foram selecionadas todas as faces necessárias para o dente "
#DEFINE __aCdCri139 {"077",STR0074}//"Quantidade solicitada nao permitida devido ao grupo de quantidade cadastrado."
#DEFINE __aCdCri140 {"078",STR0119}//"Quantidade maior/menor que o limite permitido na parametrização na tabela padrão."
#DEFINE __aCdCri141 {"079",STR0120}//"Item da liberação não solicitado"
#DEFINE __aCdCri143 {"081",STR0208}//"Liberação não encontrada"
#DEFINE __aCdCri144 {"082",STR0121}//"Item da liberação já executado"
#DEFINE __aCdCri145 {"083",STR0122}//"Item com quantidade maior que a solicitada"
#DEFINE __aCdCri146 {"084",STR0123}//"Resumo de internação sem previa Solicitação"
#DEFINE __aCdCri152 {"560",STR0167}//"Para a solicitação referente a esta internacao ja consta data de alta"
#DEFINE __aCdCri153 {"561",STR0168}//"Incompatibilidade de informação entre tipo de faturamento e data de alta"
#DEFINE __aCdCri154 {"562",STR0126}//"Honorário prestador não importado"
#DEFINE __aCdCri155 {"563",STR0127}//"Equipe informada no resumo de internação para guia com honorário prestador"
#DEFINE __aCdCri160 {"089",STR0088}//"Tipo de procedimento invalido para o procedimento informado"
#DEFINE __aCdCri161 {"090",STR0089}//"Procedimento com periodicidade em relação à outro procedimento já realizado."
#DEFINE __aCdCri162 {"564",STR0103}//"Quantidade de procedimentos maior que a quantidade restante autorizada"
#DEFINE __aCdCri163 {"091",STR0128}//"Solicitação (Resumo/Honorario) não encontrada para este usuário."
#DEFINE __aCdCri164 {"092",STR0129}//"Item da internação não encontrado na importação do Resumo de internação"
#DEFINE __aCdCri167 {"095",STR0130}//"Resumo de Internação - Rede de Atendimento não informada"
#DEFINE __aCdCri168 {"096",STR0169}//"Profissional de Saúde não informado"
#DEFINE __aCdCri170 {"565",STR0132}//"Nota não encontrada na base de dados"
#DEFINE __aCdCri174 {"09A",STR0135}//"Participação já informada para este item"
#DEFINE __aCdCri175 {"581",STR0170}//"Participacao informada nao existe para este procedimento ou o procedimento nao possui nenhum participacao cadastrada."
#DEFINE __aCdCri176 {"09C",STR0134}//"Item nao encontrado ou participação ja definida"
#DEFINE __aCdCri177 {"566",STR0139}//"Procedimento incompativel com um dos procedimentos da guia - Criticar"
#DEFINE __aCdCri178 {"567",STR0140}//"Procedimento incompativel com um dos procedimentos da guia - Auditar"
#DEFINE __aCdCri179 {"568",STR0142}//"Pre-requisito nao encontrado dentro do periodo maximo exigido."
#DEFINE __aCdCri181 {"09H",STR0141}//"Procedimento bloqueado na sub-especialidade de Rede de atendimento."
#DEFINE __aCdCri182 {"570",STR0148}//"O limite de US foi atingido."
#DEFINE __aCdCri183 {"09I",STR0147}//"Esta Guia será Glosada, pois, está duplicada."
#DEFINE __aCdCri184 {"09J",STR0157}//"Atendimento domiciliar necessita liberação atenção a saude."
#DEFINE __aCdCri185 {"09K",STR0158}//"A Rede Nao Referenciada executante é uma RDA que permite solicitar/executar"
#DEFINE __aCdCri186 {"09L",STR0194} //exixte no PLSMCCR.CH, mas ainda assim causava erro de variavel não exixstente. "Procedimento já existente no pacote."
#DEFINE __aCdCri187 {"573",STR0154}//"Demanda por requerimento"
#DEFINE __aCdCri190 {"569",STR0143}//"Pre-requisito nao cumpriu periodo minimo exigido."
#DEFINE __aCdCri191 {"09M",STR0159}//"Não permite Reembolso para o Usuário!"
#DEFINE __aCdCri193 {"571",STR0153}//"Procedimento incompativel com um dos procedimentos da guia - Reduzir a UCO"
#DEFINE __aCdCri194 {"574",STR0156}//"Auditoria Participativa"
#DEFINE __aCdCri195 {"09N",STR0160}//"Data de entrega fora do prazo"
#DEFINE __aCdCri197 {"09P",STR0165}//"Habilita checagem de regra para procedimentos incompatíveis!"
#DEFINE __aCdCri09Z {"09Z",STR0166}//"Guia Juridica - Esta guia não será submetida aos critérios de validação do sistema!"
#DEFINE __aCdCri204 {"0AA",STR0171} //"Quantidade de procedimentos é superior a quantidade permitida"
#DEFINE __aCdCri003 {"002",STR0172}//"Procedimento em carencia para este usuario"
#DEFINE __aCdCri09W {"09W",STR0173}//"Data da realização do evento ou da guia superior a data do sistema"
#DEFINE __aCdCri205 {"09R",STR0174}//"Codigo de procedimento enviado em Guia de Consulta, nao reconhecido como uma consulta pela operadora"
#DEFINE __aCdCri207 {"09V",STR0175}//"Paciente ja esta internado"
#DEFINE __aCdCri209 {"09T",STR0176}//"Evento generico não pode ser solicitado no Portal para atendimento de intercâmbio."
#DEFINE __aCdCri09U {"09U",STR0185}//"Guia possui cobranca de participacao nao prevista na composicao do evento"
#DEFINE __aCdCri210 {"906",STR0186}//"Matrícula intercâmbio inválida, rever cadastro beneficiário"
#DEFINE __aCdCri211 {"0A1",STR0177}//"RDA Bloqueada na data do procedimento"
#DEFINE __aCdCriRMB {"0RB",STR0178}//"Existe um reembolso já pago ao beneficiário sobre o procedimento/honorário"
#DEFINE __aCdCri214 {"0A2",STR0182}//"RDA Bloqueada nas exceções do Produto x RDA´s (Redes referenciadas para Cooperativas)."
#DEFINE __aCdCri216 {"0A3",STR0183}//"RDA não encontrada na Rede Referenciada deste Produto (Cooperaticas Médicas)."
#DEFINE __aCdCriPTS {"0TS",STR0184}//"Apenas um procedimento pode ser executado para a mesma data de execução, prestador e beneficiario."
#DEFINE __aCdCri213 {"584",STR0181}//"Procedimento fora da Data de Internação e Data de alta"}
#DEFINE __aCdCri585 {"585",STR0195}//"Quantidade de diarias Solicitadas diferente do Configurado na Tabela Padrao"}
#DEFINE __aCdCri208 {"0TT",STR0196}//"Valor cobrado da despesa diferente do valor negociado."
#DEFINE __aCdCri028 {"518",STR0197}//"Nao existe composicao para esse procedimento."
#DEFINE __aCdCri0A5 {"0A5",STR0191}//Não é Possível gerar uma consulta para um paciente internado.
#DEFINE __aCdCri09S {"09S",STR0198}//"Quantidade de dias permitido para execução da guia foi ultrapassado"
#DEFINE __aCdCri242 {"0A6",STR0202}//"Refeição para acompanhantes."
#DEFINE __aCdCri500 {"011",STR0109}//"O produto do beneficiario nao atende a esta cidade ou estado, verifique a area de abrangencia do plano."

/*/{Protheus.doc} PLSAUTP
Autorizacao de Procedimentos
@type function
@author tuliocesar
@since 20.04.00
@param cOpeUsr , caracter, Operadora Usuario
@param cMatrUsr, caracter, Matricula do Usuario
@param dData   , data    , Data Procedimento
@param cHora   , caracter, Hora Procedimento
@param cOpeRDA , caracter, Operadora RDA
@param cCodRDA , caracter, Codigo RDA
@param cCodLoc , caracter, Cod local RDA
@param cLocal  , caracter, local atendimento
@param cCodEsp , caracter, Codigo da Especialidade
@param cCdTbPd , caracter, Codigo Tab Padrao
@param cCodPro , caracter, Codigo Procedimento
@param nQtd    , numerico, Quantidade
@param aDadUsr , caracter, Dados do Usuario
@param lIntPort, Logico  , Internação do Portal
@version 1.0
/*/
function PLSAUTP(dData,cHora,cCdTbPd,cCodPro,nQtd,aDadUsr,nRegBD6,aDadRDA,cTipo,;
		lTratRDA,cCid,lTratUsr,cLocalExec,lTratSolic,cOpeSol,cCodPRFSol,cAno,cMes,;
		cPadInt,cPadCon,cRegAte,lValorGC,cCodPRFExe,cProRel,nPrPrRl,cOpeExe,aValAcu,cAteRNA,;
		cGuiaOpe,cGuiaEmp,cSequen,cNumeroGuia,lRegPagAto,cTpLocExec,cFaces,lMudFase,cSenhaAut,;
		cTipPreGui,cGrpInt,aObsolet,cRdaEDI,cChavLib,cAreaAbr,aDiarGui,aDiarPre,cDente,aFaces,;//47
		lRecursivo,lTratExe,lTratPagRda,cTipoProc,cCodEsp,aQtdBrow,aVldGen,cCodLoc,cChavGui,;
		lReembolso, cTpProc, lRpc, cAliascab, cRegInt, cTipAte, lNProPac, lBK6BAU, cFinAte, cGrauPa, lElegibil,;
		cGuiJur, aBD7, cEspSol,cEspExe, dDatCab, lCriDatSup, cTipGuia, cStProc, aCritCab, lVerWeb, lCid, lPtuOnline,;//79
		lInter, aRetAudPTU, cTabCrit, cValorApr, aDiarGlo, lNovaLib, nQTD078, cStatItem, lOutDesp, cNumLibe2,;
		cTipAdmissao,cGuiRefOpm, cTGOriginal,aDadProrro,lIntPort,cNraOpeInt,lAuto)

	local aAreaBEA		:= {}
	local aAreaBE2		:= {}
	local aAreaBA1		:= BA1->(getArea())
	local aAreaBAU		:= BAU->(getArea())
	local aAreaBA0		:= {}
	local nRecBAX		:= 0
	local i				:= 1
	local nOrdBAX       := 0
	local nfor          := 0
	local nQtdCH       	:= 0
	local nLimCH        := 0
	local nPos          := 0
	local nI       		:= 0
	local nPos1    		:= 0
	local nSaldo		:= 0
	local nPos2    		:= 0
	local nPos3			:= 0
	local nY	   		:= 1
	local nDiascar 		:= 0
	local nP	   		:= 0
	local nA	   		:= 0
	local cAcePar		:= "0"
	local cOpeRDA   	:= ""
	local cCodRDA       := ""
	local cLocal        := ""
	local cSubEsp       := ""
	local cTrtExe    	:= ""
	local cCodTab       := ""
	local cMatOri  		:= ""
	local cTipPreRDA    := ""
	local cCodOpeRDA    := ""
	local cDesCri49		:= ""
	local cCdProCon     := ""
	local cOpeOri    	:= iIf(len(aDadUsr)>=45,aDadUsr[45],"")
	local cOpeUsr 		:= iIf(len(aDadUsr)>=37,aDadUsr[37],"")
	local cMatrUsr 		:= iIf(len(aDadUsr)>=38,aDadUsr[38],"")
	local cMatric    	:= iIf(len(aDadUsr)>=2,aDadUsr[2],"")
	local cViaCartao 	:= iIf(len(aDadUsr)>=53,strZero(aDadUsr[53],2),"")
	local cMatAnt    	:= iIf(len(aDadUsr)>=3,allTrim(aDadUsr[3]),"")
	local cCodPla 		:= iIf(len(aDadUsr)>=11,aDadUsr[11],"")
	local cVersao       := iIf(len(aDadUsr)>=12,aDadUsr[12],"")
	local cCodCon  		:= __cCodCon
	local cDesGenPtu    := __cDesGenPtu
	local aRetPro 		:= {.t.}
	local aRet    		:= {.t.}
	local aRetAbr		:= {}
	local aVetTab		:= {}
	local aRetMed		:= {}
	local aRetProc      := {}
	local aValor        := {}
	local aRetAnoMes 	:= {}
	local aOldRet       := {}
	local aRdas      	:= {}
	local aCompo        := {}
	local aProdVinc     := {}
	local aAux          := {}
	local aRetOpe       := {}
	local aAuxRetPro    := {}
	local aQtd    	 	:= {}
	local aPerio   		:= {}
	local aSlvaCri 		:= {}
	local aRetPtoEnt    := {}
	local aMatric  		:= {}
	local aRetCar  		:= {}
	local aNewCri  		:= {}
	local aRetOLD		:= {}
	local aRetAux		:= {}
	local aRetPAut		:= {}
	local lUnimeds   	:= iIf( allTrim(cMV_PLSUNI)=="1",.t.,.f.)
	local lUsrInt 		:= iIf( allTrim(cMV_PLSGEIN) == BA1->BA1_CODEMP,.t.,.f.)
	local lConsulta  	:= PLSISCON(cCdTbPd,cCodPro)
	local lChkExec      := .f.
	local lAutorizado   := .f.
	local lValCob       := .t.
	local lFim     		:= .f.
	local lMatMed  		:= .f.
	local lIntEve       := .f.
	local lRepasse 		:= .f.
	local lOpeOnline    := .f.
	local cNil	   		:= eval( { || BR8->( dbSetOrder(1) ), BR8->( msSeek( xFilial("BR8") + cCdTbPd + cCodPro ) ) } )
	local lAudUnim      := iIf(allTrim(cMV_PLSUNCR) == "1",.t.,.f.) // Verifica se Valida Auditoria para usuario Intercambio UNIMED
	local cChvBE2Aux    := ""
	local j				:= 0
	local lVldPrIn      := .t. //Por padrao, o sistema vai checar procedimentos incompativeis para todos os eventos, vou usar essa variavel para via PE tratar a execao, ou seja, mantem a critica ativa mas so chama o funcao no procedimento do PE
	local cCritAux		:= ""
	local lVldRda 		:= .t.
	local nCompo        := 0
	local nCri09U       := 0
	local aCri09U		:= {}
	local lLibera 		:= iIf(funName() == "PLSA094A" .and. type("M->BE1_NUMLIB") == "C" .and. ! empty(M->BE1_NUMLIB),.t.,.f.)
	local cBA1DATCAR    := ""
	local aClasSeri		:= {}
	local cNivAut		:= ""
	local cChvNiv		:= ""
	local cIntPad		:= plsIntPad()
	local aProcByp		:= {}
	local lTratLib    	:= getNewPar("MV_PLSTRLB", .T.)
	local aAuxAudPTU    := {}
	//Saldo Prorrogação e Internação
	local lConfeBE2		:= getNewPar("MV_PLPRISL", .f.)

	local tamBE2_CODPRO	:= BE2->(tamSx3("BE2_CODPRO")[1])
	local tamBE2_DENREG	:= BE2->(tamSx3("BE2_DENREG")[1])
	local tamBE2_FADENT	:= BE2->(tamSx3("BE2_FADENT")[1])
	local tamBXV_CODPAD := BXV->(tamSx3('BXV_CODPAD')[1])
	local tamBXV_CODPRO := BXV->(tamSx3('BXV_CODPRO')[1])

	local lPLPGATO		:= getNewPar("MV_PLPGATO",.t.)
	local cPrioridade  	:= getNewPar("MV_PLSPRIO","")
	local lPreproc := .F.

	local cHashCHV 		:= ''
	local lGHash		:= .f.
	local lReturn		:= .f.
	local lCri09S		:= .f.
	local lCri088		:= .f.
	local lTsOnl        := IsInCallStack("proconline")
	Local lEncCr        := .F.
	Local lEstInt       := .F.
	Local aHasInt       := {}
	Local lNewAud       := GetNewPar("MV_PL790NE","0") == "1"
	Local aDelCriCar    := {}
	local lHatAtv			:= GetNewPar("MV_PLSHAT","0") == "1" .and. FWAliasInDic("B2Z")
	local nSaldHat		:= 0
	local lNVldHat		:= .f.
	Local nIz				:= 0
	Local cNumLibOpm 	:= M->B4A_GUIREF
	Local lCritInt		:= .F.
	Local aCritInt		:= {}
	Local aCriAbrangPTU := {}
	Local lTipoR        := GetNewPar("MV_PLSTPRE","1") == "1"
	LOCAL lAllRed       := .F.
	Local lAchou        := .F.
	local aAutUniOri    := {} // houve pré autorização da unimed origem ? 

	default aObsolet	:= {}
	default cCodPRFSol	:= ""
	default cOpeSol		:= ""
	default aCritCab	:= {}
	default nPrPrRl     := 0
	default nRegBD6		:= 0
	default cPadInt     := ""
	default cPadCon     := ""
	default cRegAte     := "1"
	default cLocalExec  := "1"
	default cAno        := ""
	default cMes        := ""
	default cCodPRFExe  := ""
	default cProRel     := ""
	default cGuiaOpe    := ""
	default cGuiaEmp    := ""
	default cSequen     := ""
	default cNumeroGuia := ""
	default cAteRNA     := "0" //Nao e atendimento recen nascido
	default cTpLocExec  := ""
	default cSenhaAut   := ""
	default cFaces		:= ""
	default cTipPreGui  := ""
	default cGrpInt     := ""
	default cRdaEDI     := ""
	default cChavLib	:= ""
	default cAreaAbr	:= iIf(len(aDadUsr) >= 65,aDadUsr[65],"")
	default cDente		:= ""
	default cTipoProc   := ""
	default cCodEsp     := ""
	default cCodLoc     := ""
	default cChavGui    := ""
	default cAliascab	:= ""
	default cRegInt		:= ""
	default cTipAte		:= ""
	default cTpProc		:= BR8->BR8_TPPROC
	default lTratRDA    := .t.
	default lTratUsr    := .t.
	default lTratSolic  := .f.
	default lValorGC    := .f.
	default lRegPagAto  := .t.
	default lReembolso	:= .f.
	default lMudFase    := .f.
	default lRecursivo	:= .f.
	default lTratExe    := .f.
	default lTratPagRda := .t.
	default lNProPac	:= .f.
	default lRpc		:= .t.
	default cOpeExe     := cIntPad
	default aValAcu     := {}
	default aDiarGui	:= {}
	default aDiarPre    := {}
	default aDiarGlo    := {}
	default aFaces		:= {}
	default aQtdBrow	:= {}
	default aDadRDA		:= {}
	default aVldGen		:= {}
	default lBK6BAU		:= .f.
	default cFinAte		:= ""
	default cGrauPa		:= ""
	default lElegibil	:= .f.
	default cGuiJur		:= ""
	default aBD7		:= {}
	default cEspSol		:= ''
	default cEspExe		:= ''
	default cCid		:= ''
	default dDatCab		:= ctod('')
	default lCriDatSup  := .t.
	default cTipGuia	:= ""
	default cStProc		:= "S"
	default lVerWeb     := .f.
	default lCid		:= .t.
	default lPtuOnline  := .f.
	default lInter      := .f.
	default aRetAudPTU  := {}
	default cTabCrit    := ""
	default cValorApr   := ""
	default lNovaLib    := .f.
	default nQtd078		:= 0 //variável para ajustes na regra quantidade mínima/máxima
	default cStatItem   := ""
	default lOutDesp	:= .f.
	default cNumLibe2	:= ""
	default cTipAdmissao:= ""
	default cGuiRefOpm 	:= ""
	default cTGOriginal := ""
	default aDadProrro  := {}
	default lIntPort	:= .F.
	default cNraOpeInt := ""
	default lAuto       := .F.

	aCodCri := {} //Variavel static

	cTipPreRDA 	:= iIf(lTratRDA,( iIf(len(aDadRda) >= 27, aDadRda[27],"" ) ),"")
	cCodOpeRDA 	:= iIf(lTratRDA,( iIf(len(aDadRda) >= 28 .and. ! empty(aDadRda[28]) ,aDadRda[28],iIf(len(aDadRda)>14,aDadRda[14],""))),"")
	cCodRda 	:= iIf(lTratRDA,( iIf(len(aDadRda) >= 2, aDadRda[2],"" ) ),"")

	// Verifico se deve atualizar o dDataBase na virada do dia para PTU/TISS Online
	if isBlind() .or. FunName() == "RPC"
		FwDateUpd(.F., .T.)
	endIf

	// Seta variaveis se for necessario validar a rede de atendimento...
	if lTratRDA .and. len(aDadRda) >= 15

		if empty(cCodLoc)
			cCodLoc := aDadRda[12]
		endIf

		if empty(cLocal)
			cLocal := aDadRda[13]
		endIf

		if empty(cCodEsp)
			cCodEsp := aDadRda[15]
		else

			cCodEsp := Subs(cCodEsp,1,3)

			if cCodEsp <> aDadRda[15]// CASO SEJA DIFERENTE PRECISO RECARREGAR O ADARDA POIS ELE IRA PASSAR POR VARIAS VALIDAÇÕES E CASO ESTEJA COM ESPECIALIDADE ERRADA O SISTEMA IRA APRESENTAR CRITICAS ERRADAS
				aDadRda[15] := cCodEsp
				aDadRda[17] := Posicione("BAQ",1,xFilial("BAQ") + cCodOpeRDA + cCodEsp,"BAQ_DESCRI")
			endIf

		endIf

	endIf

	/*
//ver por que a chave ainda esta errada
cHashCHV := md5(UID_AUTP + dtos(dData) + allTrim(cCdTbPd) + allTrim(cCodPro) + allTrim(cValToChar(nQtd)) + allTrim(cAteRNA) + allTrim(cDente) + allTrim(cCodEsp) +;
				aDadUsr[2] + allTrim(cCodOpeRDA) + allTrim(cTipPreRDA) + allTrim(cCodRda) + allTrim(cTipo) + allTrim(cCid) + allTrim(cCodPRFSol) +;
				allTrim(cCodLoc) + allTrim(cLocal) + allTrim(cTipGuia) + allTrim(cTpProc) + allTrim(cChavLib) + allTrim(cChavGui) + allTrim(cNumeroGuia), 2 )

lGHash   := PLGetGD(UID_AUTP, cHashCHV, @aRet)

if ! lGHash
	*/
	if lPLSXMUDFAS
		aCodCri := {}
	elseIf nQtd >= 1
		aCodCri := {}
	else

		// ESSA TRATATIVA SE DÁ PARA VERIFICAR SE É UM ITEM NOVO NA GUIA OU UM JA EXISTENTE PARA QUE NÃO ACOMULE CRITICAS DE OUTROS ITENS E OU ZERA AS CRITICAS DO ITEM CORRENTE
		if valType(nItensBrw) == "N" .or. subStr(readvar(),7,7) $ "_CODPRO"

			if nItensBrw <> val(cSequen) .or. subStr(readvar(),7,7) $ "_CODPRO"
				nItensBrw 	:= val(cSequen)
				aCodCri 	:= {}
			endIf

		endIf

	endIf

	if ! lTratUsr
		aRet := { .t., "", "NTU" ,nil }
	endIf

	// se for atendimento ao recen nascido nao tratar rda
	if cAteRNA == "1"

		lTratRDA := .f.

		aadd(aVldGen,nil)
		aadd(aVldGen,nil)
		aadd(aVldGen,nil)
		aadd(aVldGen,nil)
		aadd(aVldGen,.t.)

	endIf

	lChkExec := (cOpeExe == cIntPad)

	// Monta matriz de apoio __aNiveis...
	if __cCdTbPd <> cCdTbPd .or. len(__aNiveis) == 0
		__cCdTbPd := cCdTbPd
		__aNiveis := PLSESPNIV(cCdTbPd)
	endIf

	// PE para realizar validacoes iniciais customizadas pelo cliente
	if lPLVLPROAUT

		aRetCri := execBlock("PLVLPROAUT",.f.,.f.,{cCdTbPd,cCodPro,cDente,cFaces,nQtd,dData,cHora,cSequen,aDadRDA,cLocalExec,cTpLocExec})

		if ! aRetCri[1]

			aRet 	:= aClone(aRetCri)
			lReturn := .t.

		endIf

	endIf

	if ! lReturn

		if lMudFase

			if PLSPOSGLO(cIntPad,__aCdCriRMB[1],__aCdCriRMB[2],cLocalExec,'1')

				if PLSVRRCM()

					aadd(aCodCri,{__aCdCriRMB[1],__aCdCriRMB[2],"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

					// alias e caminho da critica.
					PLSCOMPCRI(aCodCri,"B44")

					aRet 	:= eval(__bRetErr,"B44",cCdTbPd + cCodPro)
					lReturn := .t.

				endIf

			endIf

		endIf

		//Verifica se a RDA estava bloqueada na data
		if ! lReturn .and. ! A360CHEBLO(cCodRda, dData, .t., time(),,aDadProrro)

			if PLSPOSGLO(cIntPad,__aCdCri211[1],__aCdCri211[2],cLocalExec,'1',cTpLocExec)

				aadd(aCodCri,{__aCdCri211[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"BAU")

				aRet 	:= eval(__bRetErr,"BAU",cCdTbPd + cCodPro)
				lReturn := .t.

			endIf

		endIf

		if ! lReturn

			If Empty(cCodRda) .And. (!Empty(cNumLibOpm) .Or. !Empty(cGuiRefOpm)) .And. (cTipGuia == "07" .Or. cTipGuia == "09")
				BEA->(dbSetOrder(1)) //BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT
				if funName()=="RPC"
					if BEA->(msSeek(xFilial("BEA")+cGuiRefOpm))
						cCodRda := BEA->BEA_CODRDA
					EndIf
				Else
					if BEA->(msSeek(xFilial("BEA")+cNumLibOpm))
						cCodRda := BEA->BEA_CODRDA
					EndIf
				EndIf
				If Empty(cFinAte)
					cFinAte := BEA->BEA_TIPPAC
				EndIf
			EndIf
			// Verifica se o procedimento informado e existente na tabela padrao...
			aRetProc := PLSVLDPTP(cCdTbPd, cCodPro, cLocalExec, cTpLocExec, cCodRda, cTipGuia, dData, @aCompo, lMudFase,cFinAte)

			if ! aRetProc[1]

				aRet 	:= aClone(aRetProc)
				lReturn := .t.
				//Em caso de bloqueio do procedimento, retorno com as críticas
				if BR8->BR8_PROBLO == "1"
					return aRet
				endif
			endIf

		endIf

		// Conforme a especialidade valida parametrizacao do tipo de rede de atendimento e produto.
		if ! lReturn .and. len(aCritCab) > 0

			for nP := 1 to len(aCritCab)

				if aScan(aCritcab[nP],{|x| x[1] == __aCdCri074[1]}) > 0
					lVldRda := .f. // ja validou no cabecalho
				endIf

				exit
			next

		endIf

		// Verifica se e item generico PTU solicitado pelo Portal
		if ! lReturn .and. lUnimeds .and. lVerWeb .and. cOpeOri <> cIntPad .and. allTrim(cCodPro) $ cDesGenPtu

			if PLSPOSGLO(cIntPad,__aCdCri209[1],__aCdCri209[2],cLocalExec,'1',cTpLocExec)

				aadd(aCodCri,{__aCdCri209[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"BA0")

				aRet 	:= eval(__bRetErr,"BA0",cCdTbPd + cCodPro)
				lReturn := .t.
			endIf

		endIf

		// Verifica se e PTU Online pelo Portal com Matricula sem 17 caracteres
		if ! lReturn .and. lUnimeds .and. lVerWeb .and. cOpeOri <> cIntPad .and. len(allTrim(aDadUsr[3])) <> 17

			if PLSPOSGLO(cIntPad,__aCdCri210[1],__aCdCri210[2],cLocalExec,"1",cTpLocExec,,.t.)

				aadd(aCodCri,{__aCdCri210[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"BA0")

				aRet 	:= eval(__bRetErr,"BA0",cCdTbPd + cCodPro)
				lReturn := .t.

			endIf

		endIf

		if ! lReturn .and. lVldRda

			aRet := PLSVLDRDA(cLocalExec,cCdTbPd,cCodPro)

			if ! aRet[1]

				aadd(aCodCri,{__aCdCri074[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,iIf(aDadUsr[24]=="1","BBI","BBK"))


				//Tratamento para informar aonde esta configurada a co-participação
				aCobertPro  := PLSAUTPDIR(cOpeOri,subStr(aDadUsr[2],5,12),cCdTbPd,cCodPro,aDadUsr,dData,cHora,nil,nil,.f.,nil,nQtd,nil,nil,nil,;
					cGuiaOpe,cGuiaEmp,aDadUsr[11],aDadUsr[12],.t.,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,;
					{.f.,.f.,.f.,.f.,.t.,.t.,.t.,.f.,.f.,.f.,.f.},nil,nil,nil,nil,nil,nil,cRegInt)//rodo para pegar o nivel de cobertura, vou precisar para calcular a co participacao

				aRet 	:= eval(__bRetErr,iIf(aDadUsr[24]=="1","BBI","BBK"),If(valType(aCobertPro) == "A" .and.  len(aCobertPro) > 0,aCobertPro[4],cCdTbPd + cCodPro))
				lReturn := .t.

			endIf

		endIf

		// Verifica se o procedimento informado e obrigatorio informar a Cid...
		if ! lReturn .and. lCid

			aRetProc := PLSVLDOCD(cCdTbPd,cCodPro,cLocalExec,cCid,(nQtd + nQtd078),lTratSolic,lTratExe,cTpLocExec,cTipoProc,cChavGui,cTipGuia)

			if ! aRetProc[1]

				//Tratamento para informar aonde esta configurada a co-participação
				aCobertPro  := PLSAUTPDIR(cOpeOri,subStr(aDadUsr[2],5,12),cCdTbPd,cCodPro,aDadUsr,dData,cHora,nil,nil,.f.,nil,nQtd,nil,nil,nil,;
					cGuiaOpe,cGuiaEmp,aDadUsr[11],aDadUsr[12],.t.,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,;
					{.f.,.f.,.f.,.f.,.t.,.t.,.t.,.f.,.f.,.f.,.f.},nil,nil,nil,nil,nil,nil,cRegInt)//rodo para pegar o nivel de cobertura, vou precisar para calcular a co participacao

				aRet 	:= eval(__bRetErr,iIf(valType(aCobertPro) == "A" .and.  len(aCobertPro) > 0,aCobertPro[3],"BR8"),If(valType(aCobertPro) == "A" .and.  len(aCobertPro) > 0,aCobertPro[4],cCdTbPd + cCodPro))
				lReturn := .t.

			endIf
		else
			aRetProc := { .t. }
		endIf
		//Critica "081" verifica se existe senha para os itens obrigatorios no rol de procedimentos da unimed do brasil
		if lMudFase .and. !lReturn .and. ( BAU->BAU_TIPPRE == cMV_PLSTPIN .and. (cTipGuia $ G_RES_INTER + '|' + G_HONORARIO + '|' +  G_SADT +'|'+ G_CONSULTA) )	

			if BR8->BR8_RISCO == "0" //Senão é baixo risco é racionalização (alto custo), obrigatorio autorização
				if !empty(cNraOpeInt)
					aAutUniOri := PlSenAut(cNraOpeInt,cCdTbPd,cCodPro)
				else 
					aAutUniOri := {.f.,STR0209+cCodPro+STR0210} //Autorização não informada  para o procedimento: cCodPro que é de alto risco (BR8_RISCO = 0)
				endif	
			endif

			if len(aAutUniOri) > 0 .and. aAutUniOri[1] == .f.
				if PLSPOSGLO(cIntPad,__aCdCri143[1],__aCdCri143[2],cLocalExec,'1',cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri143[1]} )
					aadd(aCodCri,{__aCdCri143[1],aAutUniOri[2],"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

					// alias e caminho da critica
					PLSCOMPCRI(aCodCri,"BEA")
				endif
			endif

		endif

		// valida pre-autorizacao
		if ! lReturn .and. (!lHatAtv .And. !empty(cChavLib)) .Or. (lHatAtv .And. (!Empty(cChavLib) .Or. !Empty(cSenhaAut)) ) .and. ;
				cTipGuia $ G_CONSULTA + '|' + G_SADT_ODON + '|' + G_RES_INTER + '|' + G_HONORARIO .and. getNewPar("MV_PLPRAUT","1") == "1"

			//Se hat, já valido rapidamente.
			if lHatAtv
				aRetPAut := PLHATVLDP( cTipGuia, cIntPad, cCodRDA, cSenhaAut, cChavLib, cMatric, cCdTbPd, cCodPro)
			endif
			if empty(aRetPAut) .or. !aRetPAut[1]
				aRetPAut:= PLBYEPU(cTipGuia, cChavLib, @aProcByp, cCdTbPd, cCodPro, cDente, cFaces, lOutDesp, cNumLibe2 )
				lNVldHat := .t.
			endif

			lPreAut := aRetPAut[1]
			cNivAut := aRetPAut[2]
			cChvNiv := aRetPAut[3]
			nSaldHat := iif(len(aRetPAut) == 4, aRetPAut[4], 0) //Se HAT, retornamos o saldo neste momento.

			if (empty(aVldGen)) //O sistema estava solicitando forçar novamente quando se tratava de liberação com RDA genérica.
				aVldGen := {iif(lPreAut /*.And. FunName() == 'PLSA498'*/,.F.,.T.),.T.,.F.,.F.,iif(lPreAut, .t., .f.),.F.,.F.,.F.,.F.,!lPreAut,.F.}
				lTratUsr:= .T.
			elseif ( len(aVldGen) >= 10 .and. (aVldGen[10] != nil .and. aVldgen[10] != !lPreAut) )
				aVldGen[10] := !lPreAut
			endIf

			// Deve ser validado também as guias de GHI e GRI oriundas de importação do ptu A500
			if cTipGuia == G_SADT .or. (BAU->BAU_TIPPRE == cMV_PLSTPIN .and. cTipGuia $ G_RES_INTER + '|' + G_HONORARIO ) .or. (lConfeBE2 .and. cTipGuia == G_RES_INTER)

				aAreaBEA := BEA->(getArea())
				aAreaBE2 := BE2->(getArea())

				if cTipGuia == G_RES_INTER
					BEA->(dbsetorder(6))
					BEA->(dbgotop())
					BE2->(dbgotop())

					if BEA->( msSeek( xFilial("BEA") + cChavLib ) )
						if BEA->(BEA_OPEMOV + BEA_ANOINT + BEA_MESINT + BEA_NUMINT ) == cChavLib //

							nSaldo := 0

							While !BEA->(Eof()) .And. BEA->(BEA_FILIAL + BEA_OPEMOV + BEA_ANOINT + BEA_MESINT + BEA_NUMINT) == xfilial("BEA") + cChavLib

								BE2->(dbSetOrder(6)) //BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_CODPAD+BE2_CODPRO+BE2_DENREG+BE2_FADENT
								cChvBE2Aux := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) + cCdTbPd + allTrim(cCodPro) + space( tamBE2_CODPRO - len(allTrim(cCodPro)) )  + allTrim(cDente) + space( tamBE2_DENREG - len(allTrim(cDente)) ) + allTrim(cFaces) + space( tamBE2_FADENT - len(allTrim(cFaces)) )

								if ! lPreAut .and. PLSPOSGLO(cIntPad,__aCdCri098[1],__aCdCri098[2],cLocalExec,'1',cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri098[1]} ) .and. ! BE2->(msSeek( xFilial("BE2") + cChvBE2Aux))

									if empty(cTpProc) .or. ( ! empty(cTpProc) .and. !( allTrim(cTpProc) $ allTrim( getNewPar("MV_PLSOPMM","0,1,2,3,4,5,6,7,8,9"))))

										aadd(aCodCri,{__aCdCri098[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

										// alias e caminho da critica.
										PLSCOMPCRI(aCodCri,"BEA")

										aRet 	:= eval(__bRetErr,"BEA",cCdTbPd + cCodPro)
										lReturn := .t.

									endIf

								elseIf lPreAut .and. BE2->( msSeek( xFilial("BE2") + cChvBE2Aux ) ) .and. allTrim(BE2->BE2_CODPRO) == allTrim(cCodPro)

									while ! BE2->(eof()) .and. xFilial("BE2") + cChvBE2Aux == BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_CODPAD+BE2_CODPRO+BE2_DENREG+BE2_FADENT)
										nSaldo += BE2->BE2_SALDO
										BE2->(dbSkip())
									endDo

								endIf
								BEA->(dbskip())
							enddo
						endif
					endif

					//após percorrer todas as solicitações, verifica se a glosa 564 é pertinente
					if lPreAut .and. PLSPOSGLO(cIntPad,__aCdCri162[1],__aCdCri162[2],cLocalExec,'1',cTpLocExec) .and. nQtd > nSaldo
						aadd(aCodCri,{__aCdCri162[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
						aadd(aCodCri,{""   ,STR0030, Str(nSaldo, 6)       , "","",cCdTbPd,cCodPro}) //"Quantidade permitida para o procedimento foi excedida"
						aadd(aCodCri,{""   ,STR0033, Str(nQtd, 6)		  , "","",cCdTbPd,cCodPro}) //"Quantidade solicitada"
						aadd(aCodCri,{""   ,STR0034, Str(nQtd - nSaldo ,6), "","",cCdTbPd,cCodPro})	//"Quantidade Ultrapassada pelo usuario"

						// alias e caminho da critica.
						PLSCOMPCRI(aCodCri,"BEA")
						aRet 	:= eval(__bRetErr,"BEA",cCdTbPd + cCodPro)
						lReturn := .t.
					endif

					//Parte da aalidação do HAT das críticas de não conter na liberação e quantidade. Como a query já foi feita antes, retornamos o saldo presente, economizando tempo
				elseif !lNVldHat .and. lHatAtv .and. cTipGuia $ G_SADT_ODON
					if !lPreAut .and. PLSPOSGLO(cIntPad,__aCdCri098[1],__aCdCri098[2],cLocalExec,'1',cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri098[1]} )
						if empty(cTpProc) .or. ( ! empty(cTpProc) .and. !( allTrim(cTpProc) $ allTrim( getNewPar("MV_PLSOPMM","0,1,2,3,4,5,6,7,8,9"))))
							aadd(aCodCri,{__aCdCri098[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
							// alias e caminho da critica.
							PLSCOMPCRI(aCodCri,"B2Z")
							aRet 	:= eval(__bRetErr,"B2Z",cCdTbPd + cCodPro)
							lReturn := .t.
						endIf
					endif
					if lPreAut .and. PLSPOSGLO(cIntPad,__aCdCri162[1],__aCdCri162[2],cLocalExec,'1',cTpLocExec) .and. nQtd > nSaldHAT
						aadd(aCodCri,{__aCdCri162[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
						aadd(aCodCri,{""   ,STR0030, Str(nSaldHAT, 6)       , "","",cCdTbPd,cCodPro}) //"Quantidade permitida para o procedimento foi excedida"
						aadd(aCodCri,{""   ,STR0033, Str(nQtd, 6)		  , "","",cCdTbPd,cCodPro}) //"Quantidade solicitada"
						aadd(aCodCri,{""   ,STR0034, Str(nQtd - nSaldHAT ,6), "","",cCdTbPd,cCodPro})	//"Quantidade Ultrapassada pelo usuario"

						// alias e caminho da critica.
						PLSCOMPCRI(aCodCri,"B2Z")
						aRet 	:= eval(__bRetErr,"B2Z",cCdTbPd + cCodPro)
						lReturn := .t.
					endif

					//Parte da SADT*******************************
				else
					if BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) == cChavLib

						BE2->(dbSetOrder(6)) //BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_CODPAD+BE2_CODPRO+BE2_DENREG+BE2_FADENT
						cChvBE2Aux := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) + cCdTbPd + allTrim(cCodPro) + space( tamBE2_CODPRO - len(allTrim(cCodPro)) )  + allTrim(cDente) + space( tamBE2_DENREG - len(allTrim(cDente)) ) + allTrim(cFaces) + space( tamBE2_FADENT - len(allTrim(cFaces)) )

						if ! lPreAut .and. PLSPOSGLO(cIntPad,__aCdCri098[1],__aCdCri098[2],cLocalExec,'1',cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri098[1]} ) .and. ! BE2->(msSeek( xFilial("BE2") + cChvBE2Aux))

							if empty(cTpProc) .or. ( ! empty(cTpProc) .and. !( allTrim(cTpProc) $ allTrim( getNewPar("MV_PLSOPMM","0,1,2,3,4,5,6,7,8,9"))))

								aadd(aCodCri,{__aCdCri098[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

								// alias e caminho da critica.
								PLSCOMPCRI(aCodCri,"BEA")

								aRet 	:= eval(__bRetErr,"BEA",cCdTbPd + cCodPro)
								lReturn := .t.

							endIf

						elseIf lPreAut .and. BE2->( msSeek( xFilial("BE2") + cChvBE2Aux ) ) .and. allTrim(BE2->BE2_CODPRO) == allTrim(cCodPro)

							if PLSPOSGLO(cIntPad,__aCdCri162[1],__aCdCri162[2],cLocalExec,'1',cTpLocExec)
								nSaldo := 0

								while ! BE2->(eof()) .and. xFilial("BE2") + cChvBE2Aux == BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_CODPAD+BE2_CODPRO+BE2_DENREG+BE2_FADENT)
									nSaldo += BE2->BE2_SALDO
									BE2->(dbSkip())
								endDo

								if nQtd > nSaldo

									aadd(aCodCri,{__aCdCri162[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
									aadd(aCodCri,{""   ,STR0030, Str(nSaldo, 6)       , "","",cCdTbPd,cCodPro}) //"Quantidade permitida para o procedimento foi excedida"
									aadd(aCodCri,{""   ,STR0033, Str(nQtd, 6)		  , "","",cCdTbPd,cCodPro}) //"Quantidade solicitada"
									aadd(aCodCri,{""   ,STR0034, Str(nQtd - nSaldo ,6), "","",cCdTbPd,cCodPro})	//"Quantidade Ultrapassada pelo usuario"

									// alias e caminho da critica.
									PLSCOMPCRI(aCodCri,"BEA")

									aRet 	:= eval(__bRetErr,"BEA",cCdTbPd + cCodPro)
									//lReturn := .t.
								endIf
							endif
						endIf
					endif

				endIf

				BEA->(restArea(aAreaBEA))
				BE2->(restArea(aAreaBE2))

			endIf

			if 	! lReturn .and. lPreAut .and. lTratExe

				aRet := PLSTratExe(cCdTbPd,cCodPro,lTratRDA,lTratUsr,lChkExec,cLOCALExec,cCodPRFExe,;
					aRetPro,aDadRda,aDadUsr,,dData,cCodEsp,cCodLoc,cOpeExe,nil,aBD7,cEspSol,cEspExe)

				if ! aRet[1]

					PLSINCRI(aCodCri,aRet[2])

					aRet := eval(__bRetErr,"BBM",cIntPad+cCodEsp+cCdTbPd+cCodPro)

				else
					aRet := eval(__bRetAut,"1",cNivAut,cChvNiv)

				endIf
				if lTratLib .And. !Empty(cChavLib) .And. len(aVldGen) >= 2 .and. aVldGen[1] != nil .and. !aVldgen[1]
					lReturn := .t.
				endIf
			endIf

		endIf

		if ! lReturn .and. nMV_QTDPROC > 0

			if len(aQtdBrow) >= nMV_QTDPROC .and. PLSPOSGLO(cIntPad,__aCdCri204[1],__aCdCri204[2],cLocalExec,'1',cTpLocExec)
				aadd(aCodCri,{__aCdCri204[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
				aRet := eval(__bRetErr,"BA0",cOpeOri)
				lFim := .t.
			endIf

		endIf

		//verifica se tem mais participacao do que o previsto - CodPad,CodPro,Sequen,{aCompo},{Unm's}
		if ! lReturn .and. lMudFase .and. nRegBD6 > 0 .and. getNewPar("MV_PLPGPAN",.f.) .and. PLSPOSGLO(cIntPad,__aCdCri09U[1],__aCdCri09U[2])

			BD6->(dbGoto(nRegBD6))

			aadd(aCri09U,{BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_SEQUEN,{},{}})

			aCri09U[len(aCri09U),4] := PLSCOMEVE(BD6->BD6_CODTAB, BD6->BD6_CODPAD, BD6->BD6_CODPRO, BD6->BD6_CODOPE, BD6->BD6_DATPRO,;
				BD6->BD6_TIPGUI, .f., .f., BD6->BD6_CODRDA, BD6->BD6_CODESP, "", BD6->BD6_CODLOC, "0", {})

			BD7->(dbSetOrder(2))
			BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO)))

			while ! BD7->(eof()) .and. BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO) == BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO)

				aadd(aCri09U[len(aCri09U),5],{BD7->BD7_CODUNM})

				BD7->(dbSkip())
			endDo

			if len(aCri09U) > 0

				for nCri09U := 1 to len(aCri09U)

					nPos    := 0
					cUnmMed := ""

					if len(aCri09U[nCri09U,5]) >= len(aCri09U[nCri09U,4])

						for nCompo := 1 to len(aCri09U[nCri09U,5])

							nPos := ascan(aCri09U[nCri09U,4],{|x| x[1] == aCri09U[nCri09U,5,nCompo,1]})
							if nPos == 0
								cUnmMed := aCri09U[nCri09U,5,nCompo,1]
							endIf

						next nCompo

						if ! empty(cUnmMed)
							aadd(aCodCri,{__aCdCri09U[1],__aCdCri09U[2],"",BCT->BCT_NIVEL,BCT->BCT_TIPO,aCri09U[nCri09U,1],aCri09U[nCri09U,2],aCri09U[nCri09U,3],cUnmMed})
							PLSCOMPCRI(aCodCri,"BD4")
						endIf

					endIf

				next nCri09U

			endIf

		endIf

		//Inclusão da Critica de data de procedimento se a mesma for maior que a database
		if ! lReturn .and. ( (dData > dDataBase .and. ! empty(dData)) .or. (dDatCab > dDataBase .and. !empty(dDatCab)) ) .and. lCriDatSup

			if PLSPOSGLO(cIntPad,__aCdCri09W[1],__aCdCri09W[2],cLocalExec,'1',cTpLocExec)
				aadd(aCodCri,{__aCdCri09W[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
				aRet := eval(__bRetErr,"BA0",cOpeOri)
				lFim := .t.
			endIf

		endIf

		if ! lReturn

			// Se for matmed atualizo a variavel
			lMatMed := cTpProc $ '1,2'

			// Eventual
			lIntEve  := ( lUnimeds ) .and. ( cOpeOri <> cIntPad )

			// Repasse
			if len(aDadUsr) >= 43
				lRepasse := iIf(allTrim(aDadUsr[43])=='02',.t.,.f.)
			endIf

			// Ponto de entrada para avaliar a troca da operadora origem...
			if existBlock("PLSCHGOO")
				aRetPtoEnt 	:= execBlock("PLSCHGOO",.f.,.f.,{cOpeOri,lIntEve})
				lIntEve 	:= aRetPtoEnt[1]
				cOpeOri 	:= aRetPtoEnt[2]
			endIf

		endIf

		// Analisar caso de usuario de outra operadora...
		if ! lReturn .and. lIntEve .and. ! lRepasse .and. len(aDadUsr) > 0

			aAreaBA0 := BA0->(getArea())

			// Tratamento para bloqueio de atendimento de usuarios de outras operadoras |
			BA0->(dbSetOrder(1))
			if BA0->(msSeek(xFilial("BA0")+cOpeOri)) .and. PLSPOSGLO(cIntPad,__aCdCri096[1],__aCdCri096[2],cLocalExec,nil,cTpLocExec) .and. BA0->BA0_BLOINO == '1'

				aadd(aCodCri,{__aCdCri096[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"BA0")

				BA0->(restArea(aAreaBA0))

				aRet := eval(__bRetErr,"BA0",cOpeOri)
				lFim := .t.
				lCritInt := .T.
				aCritInt := aclone(aRet[2])
				// Usuario nao esta bloqueado
			else

				BA0->(restArea(aAreaBA0))

				// Antes de chacar qualquer regra verifica se for consulta o tempo de retorn
				aPerio 	:= PlRetPaPer("BR8")

				aRet 	:= PLSTratPer(cMatric,dData,cHora,cCdTbPd,cCodPro,nQtd,0,"",cLocalExec,aDadRda,nRegBD6,cCid,lTratRda,;
					"1",aDadUsr,cFaces,aQtd,aPerio,"",cRdaEDI,cDente,aFaces,nil,nil,nil,aQtdBrow,cChavGui,nil,nil,nil,cSequen,,cEspExe)

				if ! aRet[1]

					PLSINCRI(aCodCri,aRet[2])
					aRet := eval(__bRetErr,"INT","")
					lFim := .t.
					lCritInt := .T.
					aCritInt := aclone(aRet[2])
				else

					// Tratar o executante p/ usuario d intercambio...
					if lTratExe

						aRet := PLSTratExe(cCdTbPd,cCodPro,lTratRDA,lTratUsr,lChkExec,cLocalExec,cCodPRFExe,;
							aRetPro,aDadRda,aDadUsr,,dData,cCodEsp,cCodLoc,cOpeExe,,aBD7,cEspSol,cEspExe)

						if ! aRet[1]
							PLSINCRI(aCodCri,aRet[2])
							aRet := eval(__bRetErr,"BBM",cIntPad+cCodEsp+cCdTbPd+cCodPro)
							lFim := .t.
							lCritInt := .T.
							aCritInt := aclone(aRet[2])
						endIf

					endIf

					// Tratar o solicitante p/ usuario d intercambio...
					if lTratSolic

						aRet := PLSTratSol(cOpeSol,cCdTbPd,cCodPro,aDadRda,aDadUsr,cLocalExec,cCodLoc,lTratSolic,@aRet,cCodPRFSol,lTratRDA,dData,cCodEsp,cTipoProc)

						BA0->(dbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
						if BA0->(msSeek(xFilial("BA0")+cOpeOri)) .and. BA0->BA0_ONLINE == "1"
							lOpeOnline := .t.
						endIf

					endIf

					// Chacar regra dos 300 chs...
					if PLSPOSGLO(cIntPad,__aCdCri069[1],__aCdCri069[2],cLocalExec,nil,cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri069[1]} ) .and. empty(cGuiaOpe) .and. !lMatMed .and. !lOpeOnline

						aRetOpe := PLSRtLimCH(cOpeOri,dData)
						nLimCH  := aRetOpe[1]
						cCodTab := aRetOpe[2]

						nQtdCH  := PLSRtQtdCH(cCodTab,cCdTbPd,cCodPro,cIntPad,dData,cProRel,nPrPrRl,.t.,cAno,cMes)[1]

						if nQTDCH > nLimCH

							aadd(aCodCri,{__aCdCri069[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
							aadd(aCodCri,{""   ,STR0001,allTrim(Str(nLimCH)),"","",cCdTbPd,cCodPro}) //"Limite por procedimento"
							aadd(aCodCri,{""   ,STR0002,allTrim(Str(nQtdCH)),"","",cCdTbPd,cCodPro}) //"Quantidade/Valor do procedimento"
							aadd(aCodCri,{""   ,STR0003,allTrim(Str(nQtdCH-nLimCH)),"","",cCdTbPd,cCodPro}) //"Diferenca ultrapassada"

							// alias e caminho da critica.
							PLSCOMPCRI(aCodCri,"BA0")

							aRet := eval(__bRetErr,"BA0",cOpeOri)
							lFim := .t.
							lCritInt := .T.
							aCritInt := aclone(aRet[2])
						elseif aRet[1]

							aOldCodCri  := aClone(aCodCri)
							aCodCri	 	:= {}

							// rodo para pegar o nivel de cobertura, vou precisar para calcular a co participacao
							aAuxRetPro  := PLSAUTPDIR(cOpeUsr,cMatrUsr,cCdTbPd,cCodPro,aDadUsr,dData,cHora,nil,nil,.f.,nil,nQtd,cLocalExec,nil,nil,;
								cGuiaOpe,cGuiaEmp,cCodPla,cVersao,.t.,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,;
								{.f.,.f.,.f.,.f.,.t.,.t.,.t.,.f.,.f.,lAudUnim,.f.},nil,lTratSolic,lTratExe,aBD7,cEspSol,cEspExe,cRegInt)

							aCodCri := aClone(aOldCodCri)

							//o conteudo de erro que esta nesta matriz nunca e retornado
							if ! aAuxRetPro[1]

								//Retorna o que ja ESTAVA na acodcri
								if lAudUnim

									aadd(aCodCri,{__aCdCri051[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

									// alias e caminho da critica.
									PLSCOMPCRI(aCodCri,aAuxRetPro[3])

									aRet := eval(__bRetErr,aAuxRetPro[3],aAuxRetPro[4])
									lFim := .t.
									lCritInt := .T.
									aCritInt := aclone(aRet[2])
								else
									aRet := eval(__bRetAut,BR8->BR8_AUTORI,"BR8",BR8->(BR8_CODPAD+BR8_CODPSA)) //Apaga tudo que esta no aRet
									lFim := .t.
								endIf
							else
								aRet := aClone(aAuxRetPro)
								lFim := .t.
							endIf

						endIf

					elseIf aRet[1]

						aOldCodCri  := aClone(aCodCri)
						aCodCri	 := {}

						// rodo para pegar o nivel de cobertura, vou precisar para calcular a co participacao
						aAuxRetPro  := PLSAUTPDIR(cOpeUsr,cMatrUsr,cCdTbPd,cCodPro,aDadUsr,dData,cHora,nil,nil,.f.,nil,nQtd,cLocalExec,nil,nil,;
							cGuiaOpe,cGuiaEmp,cCodPla,cVersao,.t.,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,;
							{.f.,.f.,.f.,.f.,.t.,.t.,.t.,.f.,.f.,lAudUnim,.f.},nil,nil,nil,aBD7,cEspSol,cEspExe,cRegInt)

						aCodCri     := aClone(aOldCodCri)

						if ! aAuxRetPro[1]

							if lAudUnim

								aadd(aCodCri,{__aCdCri051[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

								// alias e caminho da critica.
								PLSCOMPCRI(aCodCri,aAuxRetPro[3])

								aRet := aClone(eval(__bRetErr,aAuxRetPro[3],aAuxRetPro[4]))
								lFim := .t.
								lCritInt := .T.
								aCritInt := aclone(aRet[2])
							else
								aRet := eval(__bRetAut,BR8->BR8_AUTORI,"BR8",BR8->(BR8_CODPAD+BR8_CODPSA))
								lFim := .t.
							endIf
						else
							aRet := aClone(iIf(!aRetProc[1], aRetProc, aAuxRetPro))
							lFim := .t.
						endIf

					endIf

					// Tratamento de abrangencia no intercambio
					aRetAbr := PLSABRANG(cAreaAbr,cLocalExec,cTpLocExec,cCdTbPd,cCodPro,aDadUsr,aDadRda)

					if !aRetAbr[1]
						PLSINCRI(aCodCri,aRetAbr[2])
						aRet := eval(__bRetErr,"BIA",cAreaAbr+cCdTbPd+cCodPro)
						lFim := .t.
						lCritInt := .T.
						aCritInt := aclone(aRet[2])
					endIf

				endIf

			endIf

			if ! lReturn .and. ! aRetProc[1]

				aRet := aRetProc
				PLSCOMPCRI(aRet[2],"BR8")

				aRet 	:= eval(__bRetErr,"BR8",cCdTbPd + cCodPro)
				lReturn := .t.

			endIf

		else

			if ! lReturn .and. ( lUnimeds ) .and. ( cTipPreRDA == cMV_PLSTPIN ) .and. !lRepasse

				// Verificacao solicitacao normal
				if lMudFase .and. !lPtuOnline

					if ( empty(cSenhaAut) .or. val(cSenhaAut) == 0 )

						// Antes de checar qualquer regra verifica se for consulta o tempo de retorn
						aRet := PLSTratPer(cMatric,dData,cHora,cCdTbPd,cCodPro,nQtd,0,"",cLocalExec,aDadRda,nRegBD6,cCid,lTratRda,"1",aDadUsr,;
							cFaces,aQtd,aPerio,"",cRdaEDI,cDente,aFaces,nil,nil,nil,aQtdBrow,cChavGui,nil,nil,nil,cSequen,/*lConsideraRDA*/,cEspExe)
						if ! aRet[1]
							PLSINCRI(aCodCri,aRet[2])

							aRet := eval(__bRetErr,"INT","")
							lFim := .t.
							lCritInt := .T.
							aCritInt := aclone(aRet[2])
						else

							// Checar regra dos 300 chs...
							aRetOpe := PLSRtLimCH(cCodOpeRDA,dData)
							nLimCH  := aRetOpe[1]
							cCodTab := aRetOpe[2]

							nQtdCH  := PLSRtQtdCH(cCodTab,cCdTbPd,cCodPro,cIntPad,dData,cProRel,nPrPrRl,.t.,cAno,cMes)[1]

							if PLSPOSGLO(cIntPad,__aCdCri069[1],__aCdCri069[2],cLocalExec,nil,cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri069[1]} ) .and. nQTDCH > nLimCH .and. !lMatMed

								aadd(aCodCri,{__aCdCri069[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
								aadd(aCodCri,{""   ,STR0001,allTrim(Str(nLimCH)),"","",cCdTbPd,cCodPro}) 			//"Limite por procedimento"
								aadd(aCodCri,{""   ,STR0002,allTrim(Str(nQtdCH)),"","",cCdTbPd,cCodPro}) 			//"Quantidade/Valor do procedimento"
								aadd(aCodCri,{""   ,STR0003,allTrim(Str(nQtdCH-nLimCH)),"","",cCdTbPd,cCodPro}) 	//"Diferenca ultrapassada"

								// alias e caminho da critica.
								PLSCOMPCRI(aCodCri,"BA0")
								aRet 	:= eval(__bRetErr,"BA0",cOpeOri)
								lValCob := .f.
								lFim 	:= .t.
								lCritInt := .T.
								aCritInt := aclone(aRet[2])
							endIf
							// Tratamento de abrangencia no intercambio
							// O tratamento anterior nao atendia a demanda de mercado para MULTI-Opera
							// doras, por isso o linha abaixo devera ser descontinuada na versao 9
							// Daher 21/08/2006

							aRetAbr := PLSABRANG(cAreaAbr,cLocalExec,cTpLocExec,cCdTbPd,cCodPro,aDadUsr,aDadRda)
							if !aRetAbr[1]
								PLSINCRI(aCodCri,aRetAbr[2])
								aRet 	:= eval(__bRetErr,"BIA",cAreaAbr+cCdTbPd+cCodPro)
								lValCob := .f.
								lFim 	:= .t.
								lCritInt := .T.
								aCritInt := aclone(aRet[2])
							endIf

							// Se nao tem criticas ate aqui entra na validacao de cobertura
							if lValCob
								aOldCodCri	:= aClone(aCodCri)
								aCodCri	 	:= {}
								// rodo para pegar o nivel de cobertura
								aAuxRetPro  := PLSAUTPDIR(cOpeUsr,cMatrUsr,cCdTbPd,cCodPro,aDadUsr,dData,cHora,nil,nil,.f.,nil,nQtd,cLocalExec,nil,nil,;
									cGuiaOpe,cGuiaEmp,cCodPla,cVersao,.t.,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,;
									{.f.,.f.,.f.,.f.,.t.,.t.,.t.,.f.,.f.,.f.,.f.},nil,nil,nil,aBD7,cEspSol,cEspExe,cRegInt)

								aCodCri	:= aClone(aOldCodCri)

								if ! aAuxRetPro[1]
									aRet := eval(__bRetAut,BR8->BR8_AUTORI,"BR8",BR8->(BR8_CODPAD+BR8_CODPSA))
									lFim := .t.
								else
									aRet := aClone(aAuxRetPro)
									lFim := .t.
								endIf
							endIf

						endIf

						// a guia existe, e muda de fase e existe a senha, nao existe motivo p glosar autoriza...
					else

						aOldCodCri  := aClone(aCodCri)
						aCodCri	 	:= {}

						// Rodo para pegar o nivel de cobertura
						aAuxRetPro  := PLSAUTPDIR(cOpeUsr,cMatrUsr,cCdTbPd,cCodPro,aDadUsr,dData,cHora,nil,nil,.f.,nil,nQtd,cLocalExec,nil,nil,;
							cGuiaOpe,cGuiaEmp,cCodPla,cVersao,.t.,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,;
							{.f.,.f.,.f.,.f.,.t.,.t.,.t.,.f.,.f.,.f.,.f.},,lTratSolic,lTratExe,aBD7,cEspSol,cEspExe,cRegInt)

						aCodCri     := aClone(aOldCodCri)

						// Atencao - se negar vai autorizar pq ja tem senha/muda fase/a guia ja existe
						if ! aAuxRetPro[1]
							aRet := eval(__bRetAut,BR8->BR8_AUTORI,"BR8",BR8->(BR8_CODPAD+BR8_CODPSA))
							lFim := .t.
						else
							aRet := aClone(aAuxRetPro)
							lFim := .t.
						endIf
					endIf

				ElseIf cOpeOri == cIntPad .And. cOpeOri <> cCodOpeRDA

					// Tratamento de abrangencia no intercambio
					aRetAbr := PLSABRANG(cAreaAbr,cLocalExec,cTpLocExec,cCdTbPd,cCodPro,aDadUsr,aDadRda)

					If !aRetAbr[1]
						PLSINCRI(aCodCri,aRetAbr[2])
						aRet := eval(__bRetErr,"BIA",cAreaAbr+cCdTbPd+cCodPro)
						lCritInt := .T.
						aCritInt := aclone(aRet[2])
						aCriAbrangPTU := aClone(aRet)
					EndIf
				EndIf

			endIf
		endIf

		// Ponto de entrada apos checar regras de cobertura e direitos de execucao do prestador e solicitante
		// Obs: existe uma documentacao dizendo os parametros recebidos e os de retorno.
		if ! lReturn .and. lUnimeds .and. lUsrInt

			if lPLSAUT03
				// aDadRDA[02] - cCodRDA
				//	aDadRDA[12] - cCodLoc
				//	aDadRDA[13] - cLocal
				//	aDadRDA[14] - cOpeRDA
				//	aDadRDA[15] - cCodEsp
				if len(aRet) == 2

					aadd(aRet," ")
					aadd(aRet," ")

				endIf

				aRet := execBlock("PLSAUT03",.f.,.f.,{aRet,dData,cHora,cCdTbPd,cCodPro,nQtd,cCid,cLocalExec,cOpeSol,cCodPRFSol,;
					iIf(len(aDadRDA)>=14,aDadRDA[14],""),iIf(len(aDadRDA)>=2,aDadRDA[02],""),;
					iIf(len(aDadRDA)>=12,aDadRDA[12],""),iIf(len(aDadRDA)>=13,aDadRDA[13],""),;
					iIf(len(aDadRDA)>=15,aDadRDA[15],""),cOpeUsr,cMatrUsr,cPadInt,aDadUsr,aDadRda,;
					cTpLocExec,cTipPreRDA,cRdaEDI,cAteRNA})

			endIf

		endIf

		// Retorno quando a critica de solicitacao PTU Online
		if  (! lFim .and. ! lReturn) .OR. lMudFase

			// Guia Juridica - A guia juridica concede ao beneficiário o direito de executar aquilo que está solicitando,
			// por meio de liminar judicial apresentada à operadora.
			// Por isso, as regras a seguir não poderão ser aplicadas.
			if cGuiJur == "1"
				aRet 	:= {.t.,"","JUR",nil}
				lReturn := .t.
			endIf

			if ! lReturn .OR. lMudFase

				// Tratar Situacao Adversa x Regra
				if lPLSA268A .and. aRet[1]

					aRet := PLSREGSIT(cCdTbPd,cCodPro,cCodOpeRDA,cCodRda,cCodPRFSol,cCodPRFExe,cChavLib,cTpProc,lRpc)

					if 	!aRet[1]
						PLSINCRI(aCodCri,aRet[2])

						aRet := eval(__bRetErr,"B51",cTpProc+cCdTbPd+cCodPro)
					endIf

				endIf

				// Seta variaveis se for necessario validar a rede de atendimento...
				if lTratRDA

					cOpeRDA  := aDadRda[14]
					cCodRDA  := aDadRda[02]
					cCodLoc  := aDadRda[12]
					cLocal   := aDadRda[13]

					if empty(cCodEsp)
						cCodEsp := aDadRda[15]
					endIf

					cSubEsp  := aDadRda[21]
					cTrtExe  := aDadRda[24]
					// Se nao foi passado o ano e mes como parametro monto ele ...
					if empty(cAno) .or. empty(cMes)

						aRetAnoMes 	:= PLSXVLDCAL(dData,cOpeRda,.f.,cCdTbPd,cCodPro)

						cAno		:= aRetAnoMes[4]
						cMes 		:= aRetAnoMes[5]
					endIf

				endIf

				// Caso já houve autorização nao é necessario verificar novamente....
				if !Empty(cChavLib) .And. lTratLib

					aRetPAut:= PLBYEPU(cTipGuia, cChavLib, @aProcByp, cCdTbPd, cCodPro, cDente, cFaces, lOutDesp, cNumLibe2 )
					lPreproc := aRetPAut[1] .And. len(aVldGen) >= 2 .and. aVldGen[1] != nil .and. !aVldgen[1]
					cNivAut := aRetPAut[2]
					cChvNiv := aRetPAut[3]
					aRet := eval(__bRetAut,"1",cNivAut,cChvNiv)

				endIf


				// Primeiro passo. Verificar se usuario tem direito...
				if lTratUsr .and. len(aDadUsr) >= 56  .and. !lPreproc .AND. !lUsrInt

					aProdVinc := aDadUsr[56]
					cCodPla   := aDadUsr[11]
					cVersao   := aDadUsr[12]
					cOpeUsr   := aDadUsr[37]
					cMatrUsr  := aDadUsr[38]

					aRetPro   := PLSAUTPDIR(cOpeUsr,cMatrUsr,cCdTbPd,cCodPro,aDadUsr,dData,cHora,nRegBD6,aDadRda,;	//9
						lTratRDA,cCid,nQtd,cLocalExec,cOpeSol,cCodPRFSol,cGuiaOpe,cGuiaEmp,;	//17
						cCodPla,cVersao,.t.,nil,nil,cSequen,cNumeroGuia,cTpLocExec,cFaces,;		//16
						cGrpInt,aObsolet,cRdaEDI,cAreaAbr,cDente,aFaces,cCodEsp,aQtdBrow,;		//24
						aVldGen,cChavGui,lTratSolic,lTratExe,aBD7,cEspSol,cEspExe,cRegInt,,;	//33
						cTipoProc,lIntPort,lMudFase,lAuto)	//36

					aRet := aClone(aRetPro)

					if ! aRet[1] .and. len(aRet[2]) > 0

						aAux 		:= aClone(aRet[2])
						aSlvaCri 	:= aClone(aCodCri)

						if aScan(aAux,{|x| x[1] == __aCdCri001[1]}) > 0

							for nfor := 1 to len(aProdVinc)

								cCodPla  := aProdVinc[nfor,1]
								cVersao  := aProdVinc[nfor,2]

								aAuxRetPro  := PLSAUTPDIR(cOpeUsr,cMatrUsr,cCdTbPd,cCodPro,aDadUsr,dData,cHora,nRegBD6,aDadRda,;
									lTratRDA,cCid,nQtd,cLocalExec,cOpeSol,cCodPRFSol,cGuiaOpe,cGuiaEmp,;
									cCodPla,cVersao,.f.,aProdVinc,nfor,cSequen,cNumeroGuia,cTpLocExec,cFaces,;
									cGrpInt,aObsolet,cRdaEDI,cAreaAbr,cDente,aFaces,cCodEsp,aQtdBrow,aVldGen,;
									cChavGui,lTratSolic,lTratExe,aBD7,cEspSol,cEspExe,cRegInt)

								if aAuxRetPro[1]

									aRet    	:= aClone(aAuxRetPro)
									aRetPro 	:= aClone(aRet)
									aCodCri		:= {}
									exit

								else

									if (nI := ascan(aCodCri,{|x| x[1] == __aCdCri051[1] })) > 0 .and. ascan(aSlvaCri,{|x|  x[1] == __aCdCri051[1] }) == 0 .and. ;
											ascan(aCodCri,{|x|  x[1] == __aCdCri001[1] }) > 0 .and. PLSPOSGLO(cIntPad,__aCdCri051[1],__aCdCri051[2],cLocalExec,nil,cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri051[1]} )

										aadd(aCodCri,{__aCdCri051[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

										// alias e caminho da critica.
										PLSCOMPCRI(aCodCri,"BI3")

										aRet := eval(__bRetErr,"BI3",cOpeUsr+cCodPla+cVersao)
										exit
									endIf

								endIf

							next

						endIf

					endIf

				endIf

				// Verifica se ha critica financeira
				if aRet[1]

					aRetAux := PLSVLDFIN(cMatric,dData,cCdTbPd,cCodPro,cLocalExec,aDadUsr,nil,.t.,nil,cTpLocExec)

					if ! aRetAux[1]
						PLSINCRI(aCodCri,aRetAux[2])
						aRet := eval(__bRetErr,"FIN",cCdTbPd+cCodPro)
					endIf
				endIf


				// Passo recursivo - vou tratar as situacoes de usuários transferidos
				// Se teve critica de carencia, vou verificar a carencia cumprida de todos os
				// usuários transferidos
				if ! aRet[1] .and. len(aDadUsr) >= 74 .and. !lRecursivo .And. ( ( ( nP := ascan( aCodCri,{|x| x[1] == __aCdCri003[1] } ) ) > 0 .or. ( ( nA := ascan(aCodCri,{|x|  x[1] == __aCdCri018[1] } )) > 0 ) ) )

					nP := ascan(aCodCri,{|x| x[1] == __aCdCri003[1] } ) 
					nA := ascan(aCodCri,{|x|  x[1] == __aCdCri018[1] } )

					If aDadUsr[24] == "1"
						lAllRed := .T. // Atende todos os tipos de rede,nesse caso não uso a nova validação de carência voltada para o tipo de rede
					EndIf

					// guardo as posicoes mais criticas
					aSlvCri := aClone(aCodCri)

					aAreaBA1 := BA1->(getArea())
					aAreaBAU := BAU->(getArea())

					cMatOri := allTrim(aDadUsr[76])

					cBA1DATCAR := BA1->BA1_DATCAR

					//Pego todas as matriculas
					BA1->(dbSetOrder(2))
					while ! empty(cMatOri) .and. BA1->(msSeek(xFilial("BA1")+cMatOri))

						aadd(aMatric,{BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO),BA1->(recno())})

						if allTrim(cMatOri) <> allTrim(BA1->BA1_TRAORI)
							cMatOri := allTrim(BA1->BA1_TRAORI)
						else
							cMatOri := ""
						endIf

					endDo

					If Len(aMatric) > 0   //coloco o amatric em ordem crescente
						ASORT(aMatric, , , {|x, y| x[2] < y[2]} )
					EndIf

					//para cada matricula vou verificar se a carencia jah foi cumprida para o procedimento
					for nY := 1 to len(aMatric)       // em ordem crescente

						//zero os arrays que sao criticos
						aCodCri := {}

						//carga no aDadUsr, observe que eu nao altero o aDadUsr que eh estatico, pois passo para a funcao o nono parametro .f.
						aSlvUsr := PLSDADUSR(aMatric[nY][1],"1",.f.,dData,nil,nil,nil,nil,.f.)

						if aSlvUsr[1]

							aSlvUsr:=PlsAtuSlv(aSlvUsr,lTipoR,lAllRed,aDadusr)    //vejo novas regras de carência. Tipo de Rede ou Rede Referenciada e também acomodação.

							If aSlvUsr[Len(aSlvUsr)]
								//primeiro verifica se o beneficiário tinha direito de fazer o procedimento
								aRetCar :=  PLSAUTP(dData,cHora,cCdTbPd,cCodPro,nQtd,aSlvUsr,nRegBD6,aDadRda,cTipo,;
									.f.,cCid,.t.,cLocalExec,.f.,cOpeSol,cCodPRFSol,cAno,cMes,cPadInt,;
									cPadCon,cRegAte,nil,nil,nil,nil,nil,nil,nil,nil,nil,cSequen,;
									cNumeroGuia,nil,cTpLocExec,cFaces,lMudFase,cSenhaAut,nil,cGrpInt,nil,;
									nil,nil,nil,nil,nil,nil,nil,.t.,,,,,,,,,,,,,cRegInt)

								//no plano antigo o beneficiario tinha direito
								if ascan(aCodCri,{|x|  x[1] == __aCdCri001[1] }) == 0
									//mudei este trecho pois há diversas maneiras de transferir um beneficiário.
									aDadUsr[28]:=aSlvUsr[28]
									lAchou:=.T.
									exit

								endIf

							EndIf
						endIf
					next

					If !lAchou .And. !Empty(aDadUsr[75])
						aDadUsr[28]:= aDadUsr[75]
					Endif

					//se ja teve carencia cumprida
					if !Empty(aDadUsr[75])
						aCodCri := {}
						
						//primeiro verifica se o beneficiário tem direito de fazer o procedimento com a nova data de carência
						aRetCar :=  PLSAUTP(dData,cHora,cCdTbPd,cCodPro,nQtd,aDadUsr,nRegBD6,aDadRda,cTipo,.f.,cCid,.t.,cLocalExec,.f.,cOpeSol,cCodPRFSol,cAno,cMes,cPadInt,;
							cPadCon,cRegAte,nil,nil,nil,nil,nil,nil,nil,nil,nil,cSequen,cNumeroGuia,nil,cTpLocExec,cFaces,lMudFase,cSenhaAut,nil,cGrpInt,nil,;
							nil,nil,nil,nil,nil,nil,nil,.t.,,,,,,,,,,,,,cRegInt)

						aDadUsr[28]:= cBA1DATCAR                                 //devolvo a data de carência inicial para o adadusr

						if nA > 0

							if (nPos:=ascan( aCodcri,{|x| x[1] == __aCdCri018[1] } ))
								aSlvCri[nA+1] := aCodcri[nPos+1]

								If Len(aCodcri[nPos+2])>0 .And. !Empty(aCodcri[nPos+2])
									aSlvCri[nA+2] := aCodcri[nPos+2]
								EndIf

								If Len(aCodcri[nPos+3])>0 .And. !Empty(aCodcri[nPos+3])
									aSlvCri[nA+3] := aCodcri[nPos+3]
								Endif

								If Len(aCodcri[nPos+4])>0 .And. !Empty(aCodcri[nPos+4])
									aSlvCri[nA+4] := aCodcri[nPos+4]
								EndIf

								aCodCri := aClone(aSlvCri)
								aRet[2] := aClone(aSlvCri)
							else
								aDelCriCar := {}
								Aadd(aDelCriCar,nA)
								for nY := nA+1 to len(aSlvCri)
									if Empty(aSlvCri[nY,1])
										Aadd(aDelCriCar,nY)
									else
										exit
									endIf
								next

								for nY := 1 to len(aSlvCri)
									if aScan(aDelCriCar,nY) == 0
										aadd(aNewCri,aSlvCri[nY])
									endIf
								next

								aCodCri := aClone(aNewCri)
								if len(aCodCri) > 0
									aRet[2] := aClone(aNewCri)
								else
									aRet := {.t.,{},aRet[3],aRet[4]}
								endIf
							endIf

						endif
						If nP > 0

							if len(aSlvCri) > 3

								if  (nPos:=ascan( aCodcri,{|x| x[1] == __aCdCri003[1] } ))   //aqui ajusto a critica.Somente a critica de carência irá ser atualizada

									aSlvCri[nP+1]  := aCodcri[nPos+1]

									If Len(aCodcri[nPos+2])>0 .And. !Empty(aCodcri[nPos+2])
										aSlvCri[nP+2] := aCodcri[nPos+2]
									EndIf

									If Len(aCodcri[nPos+3])>0 .And. !Empty(aCodcri[nPos+3])
										aSlvCri[nP+3] := aCodcri[nPos+3]
									Endif

									If Len(aCodcri[nPos+4])>0 .And. !Empty(aCodcri[nPos+4])
										aSlvCri[nP+4] := aCodcri[nPos+4]
									EndIf

									aCodCri := aClone(aSlvCri)
									aRet[2] := aClone(aSlvCri)
								else
									aDelCriCar := {}
									Aadd(aDelCriCar,nP)
									for nY := nP+1 to len(aSlvCri)
										if Empty(aSlvCri[nY,1])
											Aadd(aDelCriCar,nY)
										else
											exit
										endIf
									next

									for nY := 1 to len(aSlvCri)
										if aScan(aDelCriCar,nY) == 0
											aadd(aNewCri,aSlvCri[nY])
										endIf
									next

									aCodCri := aClone(aNewCri)
									if len(aCodCri) > 0
										aRet[2] := aClone(aNewCri)
									else
										aRet := {.t.,{},aRet[3],aRet[4]}
									endIf
								endIf

							endIf
						endIf

					else
						aCodCri := aClone(aSlvCri)
					endIf

					//restauro o que faltou
					BA1->(restArea(aAreaBA1))
					BAU->(restArea(aAreaBAU))

				endIf

				// Segundo passo - Vou tratar as diarias liberadas e as diarias contidas nas guias se existem diarias informadas na guia
				nPos3 := ascan(aDiarGlo,{|x| allTrim(x[1]+x[2]) == allTrim(cCdTbPd+cCodPro)})

				if len(aDiarGui) > 0 .and. ! lElegibil .and. nPos3 == 0

					lAutorizado := aRet[1]

					// esse aqui sempre tem q ser maior que zero...
					nPos1 := ascan(aDiarGui,{|x| allTrim(x[1]+x[2]) == allTrim(cCdTbPd+cCodPro) })
					nPos2 := ascan(aDiarPre,{|x| allTrim(x[1]+x[2]) == allTrim(cCdTbPd+cCodPro) })

					if nPos1 > 0

						if nPos2 == 0

							if PLSPOSGLO(cIntPad,__aCdCri123[1],__aCdCri123[2],cLocalExec,'1',cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri123[1]} )

								aadd(aCodCri,{__aCdCri123[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro,cSequen})

								PLSCOMPCRI(aCodCri,"BE4")
								aRet := eval(__bRetErr,"BE4",cNumeroGuia+cSequen+cCdTbPd+cCodPro)

							endIf

						else

							aDiarPre[nPos2][3] -= nQtd

							if aDiarPre[nPos2][3] < 0

								if PLSPOSGLO(cIntPad,__aCdCri122[1],__aCdCri122[2],cLocalExec,'1',cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri122[1]} )

									aadd(aCodCri,{__aCdCri122[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro,cSequen})

									// alias e caminho da critica.
									PLSCOMPCRI(aCodCri,"BE4")

									aRet := eval(__bRetErr,"BE4",cNumeroGuia+cSequen+cCdTbPd+cCodPro)

								endIf

							endIf

						endIf
					endIf

				elseIf len(aDiarGlo) > 0 .and. ! lElegibil .and. nPos3 > 0

					lAutorizado := aRet[1]

					if PLSPOSGLO(cIntPad,__aCdCri122[1],__aCdCri122[2],cLocalExec,'1',cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri122[1]} )

						aadd(aCodCri,{__aCdCri122[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro,cSequen})

						// alias e caminho da critica.
						PLSCOMPCRI(aCodCri,"BE4")

						aRet := eval(__bRetErr,"BE4",cNumeroGuia+cSequen+cCdTbPd+cCodPro)

					endIf

				endIf

				// Terceiro passo. Verificar se a rede de atendimento pode executar...
				if lTratExe	.and. ! lElegibil

					// Salva aret
					aRetOLD := aClone(aRet)

					// Trata executante
					PLSTratExe(cCdTbPd,cCodPro,lTratRDA,lTratUsr,lChkExec,cLocalExec,cCodPRFExe,;
						aRetPro,aDadRda,aDadUsr,@aRet,dData,cCodEsp,cCodLoc,cOpeExe,cAliascab,aBD7,cEspSol,cEspExe,@cCritAux)

					if len(aRet[2]) == 0
						aRet := aRetOld
					endIf

					// Rede nao Referencida cadastrada tambem como RDA
					if lBK6BAU .and. lReembolso

						// Se for reembolso e a rda pode executar eu nego
						if aRet[1] .or. ( len(aRet[2]) > 0 .and. ascan(aRet[2],{|x| x[1] == "006" } ) == 0)

							if PLSPOSGLO(cIntPad,__aCdCri185[1],__aCdCri185[2],cLocalExec,'0',cTpLocExec)

								aadd(aCodCri,{__aCdCri185[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

								// alias e caminho da critica.
								PLSCOMPCRI(aCodCri,"B44")

								aRet := eval(__bRetErr,"B44",cTpProc+cCdTbPd+cCodPro)

							endIf
						else
							aRet := aClone(aRetOLD)
						endIf

					endIf

				endIf

				// Quarto passo. Verificar se a o solicitante pode executar...
				if lTratSolic .and. ! lElegibil

					aRet := PLSTratSol(cOpeSol,cCdTbPd,cCodPro,aDadRda,aDadUsr,cLocalExec,cCodLoc,lTratSolic,@aRet,cCodPRFSol,lTratRDA,dData,cCodEsp,cTipoProc,cEspSol)

				endIf

				if len(aRet) == 0
					aRet := {.t.,{},"",""}
				endIf

				//lPLPGATO - somente se a operadora tiver a regra de pagar no ato
				// Quinto passo. Verifico se neste caso ele deveria pagar no ato sim/nao...
				if lPLPGATO .and. (lTratPagRda .and. (aRet[1] .or. ( valType(aRet[2]) == "A" .and. len(aRet[2]) > 0 .and. aRet[2][1][1] $ __aCdCri051[1])) .and. ! lElegibil) .or. (! lTratPagRda .and. lRegPagAto)

					PLSTratPgA(cCodEsp,cOpeRda,cCodRda,cCdTbPd,cCodPro,cCodPRFExe,cCodLoc,cSequen,cMes,cAno,;
						cSubEsp,dData,nQtd,cGrpInt,aDadUsr,cPadInt,cRegAte,lValorGC,cHora,aRdas,cProRel,nPrPrRl,aValAcu,;
						@aRet,cCid,cPadCon,lTratRDA,lTratUsr,lRegPagAto,cTipPreGui,cLocal,lRpc,cRegInt,cFinAte,cDente,cFaces,;
						cTipGuia,nil,aCompo)

				endIf

				// Verifico a regra de localidadexRegiaoxRede Credenciada...
				if cMV_VLDREGI == "1" .and. ! lElegibil

					PLSTratReg(aRetPro,aDadRDA,aDadUsr,@aRet,cLocalExec,cTpLocExec,cCdTbPd,cCodPro)

				endIf

				// Verifico a regra de procedimentos incompativeis...
				if lPLAUTPRI

					lVldPrIn := execBlock("PLAUTPRI",.f.,.f.,{cCodRda,cCdTbPd,cCodPro})

				endIf

				if  ! lElegibil .and. PLSPOSGLO(cIntPad,__aCdCri197[1],__aCdCri197[2],cLocalExec,'1',cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri197[1]} ) .and. lVldPrIn .and. !IsInCallStack("PLVLDPRE")

					lVerIncomp	:= .f.    // verificando se o procedimento e um  incompativel antes de chamar a função
					lTemB26		:= .f.
					lTemBJ4		:= .f.

					cSQL := " SELECT BJ4_FILIAL,BJ4_CODIGO,BJ4_CODPAD,BJ4_CODPSA "
					cSql += "   FROM " + retSqlName("BJ4")
					cSql += "  WHERE BJ4_FILIAL = '" + xFilial("BJ4") + "' "
					cSQL += "    AND ( BJ4_CODIGO = '" + cCdTbPd + cCodPro + "' OR "
					cSQL += "        ( BJ4_CODPAD = '" + cCdTbPd + "' AND BJ4_CODPSA = '" + cCodPro + "' ) ) AND  "
					cSQL += "        D_E_L_E_T_   = ' ' "

					dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSVLDPRI",.f.,.t.)

					if !PLSVLDPRI->(eof())
						lVerIncomp	:= .t.
						lTemBJ4		:= .t.
					endIf

					PLSVLDPRI->(dbCloseArea())

					// Há prestadora que tem o mesmo procedimento configurado na tabela BJ4 com um procedimento incompativel e na B26 com outro procedimento amarrado a RDA.
					// Precisamos mesmo assim varrer as duas tabelas pois a B26 temos a amarração com a RDA especificas
					if ! lVerIncomp .or. !lTemB26

						cSQL := " SELECT B26_FILIAL, B26_AUXPSA,B26_AUXPAD,B26_CODPAD,B26_CODPSA "
						cSql += "   FROM " + retSqlName("B26")
						cSql += "  WHERE B26_FILIAL = '" + xFilial("B26") + "' "
						cSQL += "    AND B26_CODRDA = '" + cCodRDA + "' "
						cSQL += "    AND (( B26_AUXPAD = '" + cCdTbPd + "' AND B26_AUXPSA = '" + cCodPro + "' ) "
						cSQL += "    OR  ( B26_CODPAD = '" + cCdTbPd + "' AND B26_CODPSA = '" + cCodPro + "' ) ) AND "
						cSQL += "    D_E_L_E_T_ = ' ' "

						dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSVLDPRI",.f.,.t.)

						if !PLSVLDPRI->(eof())
							lVerIncomp	:= .t.
							lTemB26		:= .t.
						endIf

						PLSVLDPRI->(dbCloseArea())

					endIf

					if ! empty(cDente)
						lVerIncomp := .t.
					endIf

					if lVerIncomp
						PLSVLDPRI(cCid,cLocalExec,aQtdBrow,aDadUsr,dData,lRpc,cCodOpeRDA,cCodRda,cCdTbPd,cCodPro,cSequen,@aRet,cFaces,cDente,nRegBD6,cNumeroGuia,cProRel,nPrPrRl,cCritAux,lTemB26,lTemBJ4, (GetNewPar("MV_PLSSENT", "1") <> '2'))
					endIf

				endIf

				// Verifico a regra de procedimentos pre-requisitos...
				if ! lElegibil
					PLSVLDPRE(cCid,cLocalExec,aQtdBrow,aDadUsr,dData,lRpc,cCodOpeRDA,cCodRda,cCdTbPd,cCodPro,cSequen,@aRet,cFaces,cDente,nRegBD6,cNumeroGuia,cProRel,nPrPrRl)
				endIf

				// Valida procedimentos quantidade de us
				if ! lElegibil

					PLSVLDLUS(cCid,"1",aQtdBrow,aDadUsr,dData,lRpc,cCodOpeRDA,cCodRda,cCdTbPd,cCodPro,cSequen,@aRet,cFaces,cDente,nRegBD6,cNumeroGuia,cProRel,nPrPrRl,;
						cAno, cMes, cSubEsp, nQtd, cPadInt, cCodEsp, cCodLoc, cRegAte, nPrPrRl, aValAcu, cHora, aDadRda, cTipo, cPadCon,;
						aRdas, aQtdBrow)
				endIf

				// Regime de Atendimento
				if PLSPOSGLO(cIntPad,__aCdCri184[1],__aCdCri184[2],,"0",,"1") .and. ( cRegInt == "3" .or. cTipAte == "06" ) .and. !lElegibil

					aadd(aCodCri,{__aCdCri184[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro} )

					// alias e caminho da critica.
					PLSCOMPCRI(aCodCri,"BEA")

					aRet := eval(__bRetErr,"BEA",cTpProc+cCdTbPd+cCodPro)

				endIf

				// Valida tipo de procedimento com o procedimento informado
				if PLSPOSGLO(cIntPad,__aCdCri160[1],__aCdCri160[2]) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri160[1]} ) .and. cTpProc <> BR8->BR8_TPPROC .and. !empty(BR8->BR8_TPPROC) .and. !lElegibil

					aadd(aCodCri,{__aCdCri160[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro} )

					// alias e caminho da critica.
					PLSCOMPCRI(aCodCri,"BR8")

					aRet := eval(__bRetErr,"BR8",cTpProc+cCdTbPd+cCodPro)

				endIf

				// Verifica se o procedimento eh por requerimento
				if BR8->BR8_REQUER == "1" .and. ! lReembolso .and. ! lElegibil .and. PLSPOSGLO(cIntPad,__aCdCri187[1],__aCdCri187[2],,,,'1')

					aadd(aCodCri,{__aCdCri187[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro} )

					// alias e caminho da critica.
					PLSCOMPCRI(aCodCri,"BR8")

					aRet := eval(__bRetErr,"BR8",cTpProc+cCdTbPd+cCodPro)

				endIf

				if cTipGuia == G_CONSULTA

					if PLSPOSGLO(cIntPad,__aCdCri205[1],__aCdCri205[2],,"1") .and. !lConsulta

						aadd(aCodCri,{__aCdCri205[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro} )

						PLSCOMPCRI(aCodCri,"BR8")
						aRet := eval(__bRetErr,"BR8",cTpProc+cCdTbPd+cCodPro)

					endIf

				endIf

				if lConsulta .And. cAteRNA <> '1' .And. cTipGuia != "03" //cTipGuia != "03" porque será verificado abaixo com a crítica 09V avisando que o paciente já está internado dentro da rotina de solicitação de internação.

					lEstInt:= PLSPOSGLO(PLSINTPAD(),__aCdCri0A5[1],__aCdCri0A5[2],'','1','')

					aHasInt := PLSUSRINTE(cMatric, iIf(!lRpc,dDataBase,date()),,.T. )

					if len(aHasInt) > 0 .and. aHasInt[1]
						If lEstInt .and. len(aHasInt) >= 7 .and. (aHasInt[7] != BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT))
							aadd(aCodCri,{__aCdCri0A5[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro} )

							PLSCOMPCRI(aCodCri,"BE4")
							aRet := eval(__bRetErr,"BE4",cTpProc+cCdTbPd+cCodPro)
						endif
					endIf
				endIf

				If cTipGuia $ G_SOL_INTER .And. PLSPOSGLO(PLSINTPAD(),__aCdCri207[1],__aCdCri207[2],'','1','') .And. cAteRNA <> '1' .And. cTipGuia != "03" //Se o beneficiário estiver internado, critica.

					aHasInt := PLSUSRINTE(cMatric, iIf(!lRpc,dDataBase,date()),,.T.,,,,,,,,.T.) // Verifica se o beneficiário já está internado.

					BE4->(dbSetOrder(18))//BE4_FILIAL, BE4_OPERDA, BE4_CODEMP, BE4_MATRIC, BE4_TIPREG, BE4_DIGITO, BE4_CODRDA, BE4_DATPRO
					if len(aHasInt) > 0 .and. aHasInt[1]// Se o paciente já estiver internado, aponta a crítica.
						aadd(aCodCri,{__aCdCri207[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro} )

						PLSCOMPCRI(aCodCri,"BE4")
						aRet := eval(__bRetErr,"BE4",cTpProc+cCdTbPd+cCodPro)
					endIf
				EndIf

				// Verifica se a rda aceita auditoria participativa
				if ! lElegibil

					cAcePar := iIf( len(aDadRda) >= 33,aDadRda[33],"0" )

					if BR8->BR8_PARTIC == "1" .and.  cAcePar == "2" .and. !lReembolso .and.	PLSPOSGLO(cIntPad,__aCdCri194[1],__aCdCri194[2],,,,'1')

						aadd(aCodCri,{__aCdCri194[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro} )

						// alias e caminho da critica.
						PLSCOMPCRI(aCodCri,"BAU")
						aRet := eval(__bRetErr,"BAU",cTpProc+cCdTbPd+cCodPro)

					endIf

				endIf

				// Nego procedimento informado no browse ja contido no pacote.
				if lNProPac .and. ! lElegibil .and. PLSPOSGLO(cIntPad,__aCdCri186[1],__aCdCri186[2],,"0")

					aadd(aCodCri,{__aCdCri186[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro} )

					// alias e caminho da critica.
					PLSCOMPCRI(aCodCri,cTabCrit)

					aRet := eval(__bRetErr,cTabCrit,cTpProc+cCdTbPd+cCodPro)
				endIf

				// Se o contrato ou quando pessoa fisica a familia permite reembolso
				if PLSPOSGLO(cIntPad,__aCdCri191[1],__aCdCri191[2],,"0") .and. lReembolso .and. !iIf( len(aDadUsr)>=87,aDadUsr[87],.t. ) .and. !lElegibil

					aadd(aCodCri,{__aCdCri191[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro} )

					// alias e caminho da critica
					PLSCOMPCRI(aCodCri,"BEA")

					aRet := eval(__bRetErr,"BEA",cTpProc+cCdTbPd+cCodPro)

				endIf

				// Verifica data de entrega
				if PLSPOSGLO(cIntPad,__aCdCri195[1],__aCdCri195[2],,"0") .and. dData + getNewPar("MV_PLSDIRE",60) < date() .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri195[1]} ).and. !lElegibil

					aadd(aCodCri,{__aCdCri195[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro} )

					// alias e caminho da critica
					PLSCOMPCRI(aCodCri,"BEA")

					aRet := eval(__bRetErr,"BEA",cTpProc+cCdTbPd+cCodPro)

				endIf

				// Valida adadrda
				if len(aDadRDA) > 0 .and. ! lElegibil

					PLSDUPGUI(cCdTbPd,cCodPro,aDadUsr,nRegBD6,aDadRDA,cOpeUsr,@aRet,dData,cCodEsp,nil,nil,lLibera)

				endIf

			endIf

		endIf

		If lTsOnl .And. Alltrim(BA1->BA1_NOMUSR) == "USUARIO GENERICO"// TISS Online: A Guia será negada para Usuário Generico
			aRetAux := PLSDADUSR(cMatric, "2", .T., dData, cCdTbPd, cCodPro, cViaCartao)
			If !aRetAux[1]
				PLSINCRI(aCodCri, aRetAux[2]) // Crítica 508 - Matricula do usuario: Invalida.
				aRet := eval(__bRetErr, "BA1", cCdTbPd+cCodPro)
			EndIf
		EndIf

	endIf

	//Crítica para validar o valor apresentado com o valor negociado na auditoria
	If lMudFase .AND. PLSPOSGLO(PLSINTPAD(),__aCdCri208[1],__aCdCri208[2],cLocalExec)

		cGuiPri := ""
		lOkAnx := .F.
		aProcAnx := {}

		If cTipGuia  == "02"
			cGuiPri := AllTrim(BD5->BD5_GUIPRI)
		ElseIf cTipGuia  == "05"
			cGuiPri := AllTrim(BE4->BE4_GUIINT)
		EndIf

		aGuiRef	:= PLS790VGOP(cTipGuia, cGuiPri)

		B53->(DbSetOrder(1)) //B53_FILIAL+B53_NUMGUI+B53_ORIMOV
		For nIz := 1 To Len(aGuiRef)

			If B53->(DbSeek(xFilial("B53")+aGuiRef[nIz]))

				B72->(DbSetOrder(1)) //B72_FILIAL+B72_ALIMOV+B72_RECMOV+B72_SEQPRO+B72_CODGLO+B72_CODPAD+B72_CODPRO
				If B72->(DbSeek(xFilial("B72")+B53->B53_ALIMOV + AllTrim(B53->B53_RECMOV)))
					lOkAnx := .T.
					While !B72->(Eof()) .And. xFilial("B72") + B53->(B53_ALIMOV + B53_RECMOV) == B72->(B72_FILIAL + B72_ALIMOV + B72_RECMOV)
						If B72->B72_PARECE == "0"
							aadd(aProcAnx, {B72->B72_CODPRO, B72->B72_CODPAD, B72->B72_VLRAUT})
						EndIf

						B72->(DbSkip())
					End
				EndIf
			EndIf
		Next
		aRetAnx := {lOkAnx, aProcAnx}

		If aRetAnx[1]
			For nIz := 1 To Len(aRetAnx[2])
				If cCodPro == aRetAnx[2][nIz][1] .AND. cCdTbPd == aRetAnx[2][nIz][2] .AND. BD6->BD6_VLRAPR <> aRetAnx[2][nIz][3]
					AaDd(aCodCri,{__aCdCri208[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
					// Alias e caminho da critica.
					PLSCOMPCRI(aCodCri,"B72")
					aRet := Eval(__bRetErr,"B72",cCdTbPd + cCodPro)
					Exit
				EndIf
			Next
		EndIf
	EndIf

	// Valida se o valor apresentado e maior que o contratado
	if ! lReturn .and. ! lMudFase .and. PLSPOSGLO(cIntPad,__aCdCri049[1],__aCdCri049[2],cLocalExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri049[1]} )

		if ! lElegibil .and. cTipoProc $ 'S,E,0' .and. ( (cAliascab $ "BE1,BE4") .or. (empty(cAliascab) .and. cTipGuia $ G_CONSULTA + '|' + G_SADT_ODON + '|' + G_SOL_INTER) )

			//Consulta e SADT
			if empty(cAliascab) .and. cTipGuia $ G_CONSULTA + '|' + G_SADT_ODON

				cAliascab := "BE1"

			elseIf empty(cAliascab) .and. cTipGuia == G_SOL_INTER

				cAliascab := "BE4"

			endIf

			cDesCri49 	:= PLSBCTDESC()
			aRetAux 	:= PLSVLDAPG( cAliascab,cMes,cAno,cIntPad,cCodRda,cCodEsp,cCodLoc,cCdTbPd,cCodPro,nQtd,dData,cHora,;
				aDadRda,aDadUsr,cPadInt,cRegAte,cPadCon,aRdas,cRegInt,cFinAte,If(lVerWeb .and. ! lMudFase .or. lRpc .and. ! lMudFase, .t.,.f.),cValorApr, lMudFase,cTipGuia)
			if aRetAux[1]

				aadd(aCodCri,{__aCdCri049[1],cDesCri49,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,aRetAux[2])

				aRet :=  eval(__bRetErr,aRetAux[2],cTpProc+cCdTbPd+cCodPro)

			endIf

		endIf

	endIf

	//aqui estou pegando as novas criticas da nova tabela BXV, que pode estar alimentada por alguma rotina
	if ! lReturn .and. ! empty(cChavGui)

		xChavGui := subStr(cChavGui,1,len(BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))

		BXV->(dbSetOrder(2))

		lEntrou := .f.

		//pego as criticas do iten
		if BXV->(msSeek(xChavGui + cCdTbPd + cCodPro))

			while !BXV->(eof()) .and. allTrim(BXV->(BXV_FILIAL+BXV_CHVGUI+BXV_CODPAD+BXV_CODPRO)) == allTrim(xChavGui+cCdTbPd+cCodPro)

				if ! empty(BXV->BXV_CODGLO) .or. !empty(BXV->BXV_DESGLO)

					aadd(aCodCri,{BXV->BXV_CODGLO,BXV->BXV_DESGLO,"",If(!empty(BXV->BXV_CODGLO),'2',''),If(!empty(BXV->BXV_CODGLO),'1',''),cCdTbPd,cCodPro,cSequen,'1'})

					lEntrou := .t.

				endIf

				BXV->(dbSkip())
			endDo

		endIf

		//pego as criticas do cabecalho
		if BXV->( msSeek(xChavGui + space(tamBXV_CODPAD) + space(tamBXV_CODPRO) ) )

			while !BXV->(eof()) .and. allTrim(BXV->(BXV_FILIAL+BXV_CHVGUI+BXV_CODPAD+BXV_CODPRO)) == allTrim(xChavGui + space(tamBXV_CODPAD) + space(tamBXV_CODPRO))

				if ! empty(BXV->BXV_CODGLO) .or. ! empty(BXV->BXV_DESGLO)

					aadd(aCodCri,{BXV->BXV_CODGLO,BXV->BXV_DESGLO,"",If(!empty(BXV->BXV_CODGLO),'2',''),If(!empty(BXV->BXV_CODGLO),'1',''),cCdTbPd,cCodPro,cSequen,'1'})

					lEntrou := .t.

				endIf

				BXV->(dbSkip())
			endDo

		endIf

		if lEntrou
			aRet := eval(__bRetErr,"BXV",xChavGui)
		endIf

	endIf

	//Crítica de data de validade da senha
	If lMudFase .and. !empty(cSenhaAut) .and. PLSPOSGLO(cIntPad,__aCdCri09S[1],__aCdCri09S[2],cLocalExec)
		BEA->(DbSetOrder(14)) //BEA_FILIAL+BEA_SENHA
		if BEA->(DBSeek(xFilial("BEA") + alltrim(cSenhaAut))) .and. !empty(dtos(BEA->BEA_VALSEN)) .and. BEA->BEA_VALSEN < BD6->BD6_DATPRO

			lCri09S := .T.
			//Valida procedimento seriado, se tiver um na guia ignora a regra.
			cSql := " SELECT BD6_SEQUEN FROM " + RetSqlName("BD6") + " BD6 "
			cSql += " INNER JOIN " + RetSqlName("BR8") + " BR8 "
			cSql += " ON BR8_FILIAL = '" + xfilial("BR8") + "' "
			cSql += " AND BR8_CODPAD = BD6_CODPAD "
			cSql += " AND BR8_CODPSA = BD6_CODPRO "
			cSql += " AND BR8_CLASSE <> ' ' "
			cSql += " AND BR8.D_E_L_E_T_ = ' ' "
			cSql += " INNER JOIN " + RetSqlName("BJE") + " BJE "
			cSql += " ON BJE_FILIAL = '" + xfilial("BJE") + "' "
			cSql += " AND BJE_CODIGO = BR8_CLASSE "
			cSql += " AND BJE_TIPO   = '2' "
			cSql += " AND BJE.D_E_L_E_T_ = ' ' "
			cSql += " WHERE BD6_FILIAL = '" + xfilial("BD6") + "' "
			cSql += " AND BD6_CODOPE = '" + BD6->BD6_CODOPE + "' "
			cSql += " AND BD6_CODLDP = '" + BD6->BD6_CODLDP + "' "
			cSql += " AND BD6_CODPEG = '" + BD6->BD6_CODPEG + "' "
			cSql += " AND BD6_NUMERO = '" + BD6->BD6_NUMERO + "' "
			cSql += " AND BD6.D_E_L_E_T_ = ' ' "

			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"PLSBJE",.F.,.T.)
			if !PLSBJE->(eof())
				lCri09S := .f.
			endif

			PLSBJE->(dbCloseArea())
			if lCri09S
				aadd(aCodCri,{__aCdCri09S[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

				// alias e caminho da critica
				PLSCOMPCRI(aCodCri,"BEA")
				aRet := eval(__bRetErr,"BEA", cChavLib)

			endIf
		endIf
	endIf

	//Crítica de usuário diferente na autorização e que está sendo cobrado
	If lMudFase .and. !empty(cSenhaAut) .and. PLSPOSGLO(cIntPad,__aCdCri088[1],__aCdCri088[2],cLocalExec)
		BEA->(DbSetOrder(14)) //BEA_FILIAL+BEA_SENHA
		if BEA->(DBSeek(xFilial("BEA") + alltrim(cSenhaAut)))
			//PLSCONFMAT verifica se o usuário que está sendo cobrado é o mesmo da autorização
			lCri088 := !PLSCONFMAT(cMatric,cMatant , BEA->BEA_OPEUSR +BEA->BEA_CODEMP + BEA->BEA_MATRIC + BEA->BEA_TIPREG + BEA->BEA_DIGITO ,BEA->BEA_MATANT)

			if lCri088
				aadd(aCodCri,{__aCdCri088[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
				// alias e caminho da critica

				PLSCOMPCRI(aCodCri,"BEA")
				aRet := eval(__bRetErr,"BEA", cChavLib)

			endIf

		Endif
	Endif

	// Valida se o Procedimento esta fora da Data de Internação e Data de alta
	if ! lReturn .and. PLSPOSGLO(cIntPad,__aCdCri213[1],__aCdCri213[2],cLocalExec,'1',cTpLocExec)

		aAreaIntBE4 := BE4->(getArea())

		if ! empty(cSenhaAut)

			//O regime de atendimento deve ser Internação
			if cTipGuia == G_SADT + "|" + G_HONORARIO .and. BD5->BD5_REGATE == "1"

				if ! empty(BD5->BD5_GUIINT)

					BE4->(dbSetOrder(1))
					if BE4->(msSeek(xFilial("BE4")+BD5->BD5_GUIINT))

						if dData < BE4->BE4_DATPRO  .or. (dData >= BE4->BE4_DATPRO .and. !empty(BE4->BE4_DTALTA) .and. dData > BE4->BE4_DTALTA)

							//"Procedimento fora da Data de Internação e Data de alta"
							aadd(aCodCri,{__aCdCri213[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

							// alias e caminho da critica.
							PLSCOMPCRI(aCodCri,"BE4")
							aRet := eval(__bRetErr,"BE4",cOpeOri)
						endIf

					endIf

				else

					BE4->(dbSetOrder(7))
					if BE4->(msSeek(xFilial("BE4")+cSenhaAut))

						if dData < BE4->BE4_DATPRO  .or. (dData >= BE4->BE4_DATPRO .and. !empty(BE4->BE4_DTALTA) .and. dData > BE4->BE4_DTALTA)

							aadd(aCodCri,{__aCdCri213[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

							// alias e caminho da critica.
							PLSCOMPCRI(aCodCri,"BE4")
							aRet := eval(__bRetErr,"BE4",cOpeOri)
						endIf

					endIf

				endIf

			else

				BE4->(dbSetOrder(7))
				if BE4->(msSeek(xFilial("BE4")+cSenhaAut)) .and. cTipGuia $ G_SOL_INTER + "|" + G_RES_INTER

					if dData < BE4->BE4_DATPRO  .or. (dData >= BE4->BE4_DATPRO .and. !empty(BE4->BE4_DTALTA) .and. dData > BE4->BE4_DTALTA)

						aadd(aCodCri,{__aCdCri213[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

						// alias e caminho da critica.
						PLSCOMPCRI(aCodCri,"BE4")

						aRet := eval(__bRetErr,"BE4",cOpeOri)

					endIf

				endIf

			endIf

		endIf

		RestArea(aAreaIntBE4)

	endIf
	//Verifico se existe classe do tipo tratamento seriado e aplico a regra de tratamento seriado
	//onde um procedimento não pode ser executado mais de uma vez na mesma data, para o mesmo beneficiário,
	//executado pelo mesmo prestador.
	if ! lReturn .and. PLSPOSGLO(cIntPad,__aCdCriPTS[1],__aCdCriPTS[2],cLocalExec)

		BJE->(dbSetOrder(5))//BJE_FILIAL+BJE_CODINT+BJE_TIPO
		if BJE->( msSeek( xFilial("BJE") + cIntPad + "2") ) //2 = tipo seriado

			aClasSeri := PLCLASERI("2")

			//garantir o posicionamneto na BR8
			aAreaBR8z := BR8->(GetArea())

			BR8->(dbSetOrder(1))
			BR8->(msSeek(xFilial("BR8")+cCdTbPd+cCodPro))

			if !empty(BR8->BR8_CLASSE) .and. ascan(aClasSeri,alltrim(BR8->BR8_CLASSE))
				if ! lVerWeb

					if ! empty(cDente) .and. cAliascab == "BE1"

						cTipGuia := "1"
						cAliascab:= "BEA"

					elseIf  cAliascab == "BE1"

						cTipGuia  := "2"
						cAliascab := "BEA"

					elseIf cTipGuia == "03"

						cTipGuia := "3"

					endIf

				else

					if cTipGuia  == "2"

						cAliascab := "BEA"

					elseIf cTipGuia  == "3"

						cAliascab := "BE4"

					elseIf cTipGuia  == "4"

						cAliascab := "B0D"

					endIf

				endIf

				if len(aDadRda) >= 2

					//Verifica se a regra se aplica das guias de atendimento
					if ! PLVALPRSE(cCodPro, aDadRda[2], cMatric, dData, aClasSeri, cTipGuia, cCdTbPd, lReembolso)

						aadd(aCodCri,{__aCdCriPTS[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

						// alias e caminho da critica.
						PLSCOMPCRI(aCodCri,cAliascab)

						if lReembolso
							cAliascab := "B44"
						endIf

						if len(aRet) != 4
							aRet 	:= eval(__bRetErr,cAliascab,cCodPro)
						else
							aRet[2] := aClone(aCodCri)
						endIf

						//Verifica se a regra se aplica no nível do processamento de contas (BD6)
					elseIf PLSEXIBD6(cMatric, dData, cCdTbPd, cCodPro, aDadRda[2], BD6->(BD6_CODOPE + BD6_CODPEG + BD6_CODLDP + BD6_NUMERO))

						aadd(aCodCri,{__aCdCriPTS[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

						// alias e caminho da critica.
						PLSCOMPCRI(aCodCri,"BD6")

						if len(aRet) != 4
							aRet 	:= eval(__bRetErr,"BD6",cCodPro)
						else
							aRet[1] := .f.
							aRet[2] := aClone(aCodCri)
						endIf
					endIf

				endIf
			endif
			//Limpa o array _aDadProc utilizado na função PLVALPRSE
			PLIMPAVAR()
			RestArea(aAreaBR8z)
		endIf
	endIf

	//caso tenha critica e é execução de uma liberação... vejo se esta critica foi auditada...caso sim...autorizo
	if !aRet[1] .And. !Empty(cChavLib) .And. Len(aDadRda) > 0 .And. Len(aCodCri)>0

		lEncCr := FdCrifor(cChavLib,aRet[2],aDadRda[2],{},{},,.T.,Alltrim(cCdTbPd),Alltrim(cCodPro),lNewAud)

		If lEncCr
			aRet[1] := .T.
			aRet[2] := "1"
			If !Empty(cNivAut) .And. !Empty(cChvNiv) .And. Len(aRet)>3
				aRet[3]:= cNivAut
				aRet[4]:= cChvNiv
			EndIf
			aCodCri := {}
		EndIf
	endIf

	//Se teve crítica na parte de validações de intercâmbio, na mudança de fase ele ainda vai executar
	//o restante das verificações, pra achar se tem um nível de coparticipação possível pra caso a crítica
	//seja reconsiderada, com isso, o aRet pode chegar aqui como "ok, sem críticas, deixa o cara fazer"
	//Se for o caso, vamos por de volta a crítica que deu, mudar pra .F. e manter o nível que seria de autorização
	//Pra cálculo de coparticipação em um possível segundo momento
	If aRet[1] .AND. lCritInt .AND. lMudFase
		aRet[1] := .f.
		aRet[2] := aCritInt
	endIf

	// Se houver Critica de abrangência no PTU Online não Autoriza
	If aRet[1] .And. Len(aCriAbrangPTU) > 0
		aRet := aClone(aCriAbrangPTU)
	EndIf

	// Tratamento de Prioridade sobre a critica de auditoria.
	// MV_PLSPRIO  Retorna as criticas que tem prioridade sobre a regra de auditoria
	if ! empty(cPrioridade) .and. ! empty(aCodCri)

		aRet[1] := .f.
		aRet[2] := PLSPRIOR(@aCodCri,cPrioridade)
	Elseif ! empty(aCodCri)
		aRet[1] := .f.
		aRet[2] := aClone(aCodCri)
	endIf
	// Ponto de entrada apos checar regras de cobertura e direitos de execucao do prestador e solicitante
	// Obs: existe uma documentacao dizendo os parametros recebidos e os de retorno.
	if ! lReturn .and. lPLSAUT02

		//aDadRDA[02] - cCodRDA
		//aDadRDA[12] - cCodLoc
		//aDadRDA[13] - cLocal
		//aDadRDA[14] - cOpeRDA
		//aDadRDA[15] - cCodEsp

		if(cTGOriginal == '11')
			cTipGuia := cTGOriginal
		endif

		aRet := execBlock("PLSAUT02",.f.,.f.,{	aRet, dData, cHora, cCdTbPd, cCodPro, nQtd, cCid, cLocalExec, cOpeSol, cCodPRFSol,;
			iIf(len(aDadRDA) >= 14, aDadRDA[14], ""), iIf(len(aDadRDA)>=2 , aDadRDA[02], ""),;
			iIf(len(aDadRDA) >= 12, aDadRDA[12], ""), iIf(len(aDadRDA)>=13, aDadRDA[13], ""),;
			iIf(! empty(cCodEsp),cCodEsp,iIf(len(aDadRDA)>=15,aDadRDA[15],"")), cOpeUsr, cMatrUsr, cPadInt, aDadUsr, aDadRda,;
			cTpLocExec, cAteRNA, cTipGuia, cChavGui, cChavLib, cNumeroGuia, lRpc,cTipAdmissao } )

	endIf

	If len(aRet) == 2 .And. !lUnimeds

		aadd(aRet," ")
		aadd(aRet," ")

	endIf

return(aRet)

/*/{Protheus.doc} PLSAUTPDIR
Verifica se usuario tem direito a um determinado proc.
@type function
@author tuliocesar
@since 20.04.00
cMatrUsr, caracter, Matricula do Usuario
cCdTbPd , caracter, Codigo Tab Padrao
cCodPro , caracter, Codigo Procedimento
aDadusr , array   , Dados do Usuario
lIntPort, Logico  , Internação do Portal
@version 1.0
/*/
function PLSAUTPDIR(cOpeUsr,cMatrUsr,cCdTbPd,cCodPro,aDadUsr,dData,cHora,nRegBD6,aDadRDA,lTratRDA,cCid,;
		nQtd,cLocalExec,cOpeSol,cCodPRFSol,cGuiaOpe,cGuiaEmp,cCodPla,cVersao,lProdPr,aProdVinc,nIndPV,cSequen,;
		cNumeroGuia,cTpLocExec,cFaces,cGrpInt,aObsolet,cRdaEDI,cAreaAbr,cDente,aFaces,cCodEsp,aQtdBrow,aVldGen,;
		cChavGui,lTratSolic,lTratExe,aBD7,cEspSol,cEspExe,cRegInt, cChavLib,cTipoProc,lIntPort,lMudFase, lAuto) //silvia

	local cSexo     	:= aDadUsr[25]
	local nIdade    	:= aDadUsr[27]
	local cTipCEmp  	:= aDadUsr[08]
	local cConEmp   	:= aDadUsr[09]
	local dDatCar   	:= aDadUsr[28]
	local cVerCon   	:= aDadUsr[39]
	local cSubCon   	:= aDadUsr[41]
	local cOpeRda   	:= iIf(lTratRDA,aDadRDA[14],"")
	local cCodRda   	:= iIf(lTratRDA,aDadRDA[02],"")
	local cVerSub   	:= aDadUsr[42]
	local cConsPad      := ""
	local cDesDen		:= ""
	local nNiveis
	local nInd		    := 1
	local nI			:= 1
	local nX			:= 1
	local bAddCriPad	:= { || PLSPOSGLO(PLSINTPAD(),__aCdCri001[1],__aCdCri001[2],cLocalExec,nil,cTpLocExec),  aadd(aCodCri,{__aCdCri001[1],PLSBCTDESC(),cCdTbPd+"-"+cCodPro,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro}) }
	local aRetFun		:= {}
	local cCodInt   	:= subs(cOpeUsr + cMatrUsr, atCodOpe[1], atCodOpe[2])
	local cCodEmp   	:= subs(cOpeUsr + cMatrUsr, atCodEmp[1], atCodEmp[2])
	local cMatric   	:= subs(cOpeUsr + cMatrUsr, atMatric[1], atMatric[2])
	local cTipoReg  	:= subs(cOpeUsr + cMatrUsr, atTipReg[1], atTipReg[2])
	local cFilBAQ   	:= xFilial("BAQ")
	local lCobProd
	local lCobGCP
	local cChave        := ""
	local cAliCri		:= ""
	local lFlag         := .t.
	local lentrou 		:= .f.
	local aPerio        := {}
	local aQtd		    := {}
	local aOldRet		:= {}
	local lCrSexIda     := .f.
	local aRetRDA       := { "" }
	local cAnaGlo       := cMV_PLSGLAN
	local lBR8_UNIMIN	:= BR8->(FieldPos('BR8_UNIMIN')) > 0
	local lBR8_UNIMAX	:= BR8->(FieldPos('BR8_UNIMAX')) > 0
	local lUsrInt       := iIf( allTrim(cMV_PLSGEIN) == BA1->BA1_CODEMP,.T.,.F.)
	local cCodRdaBT		:= ""
	local lConsJur      := GetNewPar("MV_PLCONJU", .F.)

	default lTratRDA    := .t.
	default cOpeSol     := ""
	default cCodPRFSol  := ""
	default cGuiaOpe    := ""
	default cGuiaEmp    := ""
	default cCodPla     := ""
	default cVersao     := ""
	default lProdPr     := .t.
	default cSequen     := ""
	default cNumeroGuia := ""
	default cTpLocExec  := ""
	default cFaces		:= ""
	default cGrpInt		:= ""
	default aObsolet 	:= {}
	default cRdaEDI     := ""
	default cAreaAbr	:= ""
	default cDente	    := ""
	default aFaces		:= {}
	default cCodEsp     := ""
	default aQtdBrow	:= {}
	default aVldGen  	:= {}
	default cChavGui    := ""
	default lTratSolic  := .t.
	default lTratExe    := .f.
	default aBD7		:= {}
	default cEspSol		:= ''
	default cEspExe		:= ''
	default cRegInt		:= ''
	default cChavLib	:= ''
	default cHora		:= ''
	default cTipoProc	:= ""
	default lIntPort	:= .F.
	default lMudFase	:= .F.
	default lAuto       := .F.

	if empty(cCodEsp)
		cCodEsp  := IF(lTratRDA,aDadRDA[15],"")
	endIf

	if lProdPr
		lCobProd := aDadUsr[34] == "1"
		lCobGCP  := aDadUsr[35] == "1"
		cConsPad := aDadUsr[49]
	else
		lCobProd := aProdVinc[nIndPV,3]=="1"
		lCobGCP  := aProdVinc[nIndPV,4]=="1"
		cConsPad := aProdVinc[nIndPV,5]
	endIf

	// Monta variaveis de apoio...
	if __cCdTbPd <> cCdTbPd .or. len(__aNiveis) == 0
		__cCdTbPd := cCdTbPd
		__aNiveis := PLSESPNIV(cCdTbPd)
	endIf
	nNiveis := (__aNiveis[1]+1)

	// Trecho abaixo comentado: durante a mudança de fase, na valoração da coparticipação, sempre entra dentro desse IF e retorna o nível de autorização BR8, mesmo quando não é pra retornar este nível.. Situação pega durante a execução do caso de teste PLSRETCOP.
	//Posiciona na glosa...
	//if ! PLSPOSGLO(PLSINTPAD(),__aCdCri001[1],__aCdCri001[2],cLocalExec,nil,cTpLocExec,iIf(__aCdCri001[1]$cAnaGlo,'1','0')) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri001[1]} )

	//	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01','Niveis nao validados B1E|BAQ|BFG|BFE|BFD|BFC|BT8|BT7|BB2|BRV|BR8|BAQ' , 0, 0, {})

	//	return(eval(__bRetAut,BR8->BR8_AUTORI,"BR8",BR8->(BR8_CODPAD+BR8_CODPSA)))
	//endIf

	// Niveis a serem verificados e suas ordens de prioridade...
	// 0o.  - B1E - Odontologico
	// 1o.  - BAQ - Cabecalho Especialidade (Idade Minima/Maximo e Sexo)
	// 2o.  - BFG - Cobertura Usuario
	// 3o.  - BFE - Grupo Cobertura Usuario
	// 4o.  - BFD - Cobertura Familia
	// 5o.  - BFC - Grupo Cobertura Familia
	// 6o.  - BT8 - Cobertura Grupo/Empresa...
	// 7o.  - BT7 - Grupo Cobertura Grupo/Empresa
	// 8o.  - BB2 - Cobertura do Produto
	// 9o.  - BRV - Grupo Cobertura Produto
	// 10o. - BR8 - Tabela Padrao (somente se BI3_TODOS estiver sim)
	// 11o. - BAQ - Cabecalho Especialidade (Idade Minima/Maxima e Sexo)

	if lTratRDA

		BAQ->(dbSetOrder(1))
		if ! BAQ->( msSeek( cFilBAQ + cOpeRda + cCodEsp ) )

			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',STR0081 + " [" + cFilBAQ + cOpeRda + cCodEsp + "] " + STR0082 , 0, 0, {})//"PLS - Chave"###"nao localizado no cadastro de especialidade"

		else

			aRetRDA := PlsRetRDA(cOpeRda,cCodEsp,aDadRDA)

			// quando estiver =1 iremos fazer a validação na funcao PLSTratExe para que seja analisado no executante que o sistema aprovou
			// tambem testo o !lTratExe pois o tratamento do PLSVLDESP quando "MV_PLSCTES" == 0 so ocorre na plstratexe
			if getNewPar("MV_PLSCTES","0") == "0"  .or. ! lTratExe
				//[1]	   - alias
				//[2][1] - Idade Minima
				//[2][2] - Idade Maxima
				//[2][3] - Sexo Perm.
				aRetFun := PLSVLDESP( nIdade,aRetRDA[2][1],aRetRDA[2][2],aRetRDA[2][3],cSexo,cLocalExec,cCdTbPd,cCodPro,;
					BAQ->BAQ_CODESP,BAQ->BAQ_DESCRI,aRetRDA[1],lTratSolic,lTratExe,aDadUsr[43]<>'99',cDente,cFaces,aRetRDA)
				if ! aRetFun[1]

					for nInd := 1 to len(aRetFun[2])
						aadd(aCodCri,{aRetFun[2,nInd,1],aRetFun[2,nInd,2],aRetFun[2,nInd,3],aRetFun[2,nInd,4],aRetFun[2,nInd,5],cCdTbPd,cCodPro})
					next
					// Liga flag para que nas proximas validacoes, caso nao haja mais critica,
					// possa identificar que houve critica de idade/sexo e retornar erro.
					lCrSexIda := .t.
				endIf
			endIf
		endIf
	endIf

	// (BOR) - Subcontrato x rede de atendimento
	if  cTipCEmp == "2"

		BOR->(dbSetOrder(1))
		if ! empty(cCodRDA) .and. BOR->(msSeek(xFilial("BOR")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodRDA))

			if 	BOR->BOR_PERM == "1" .and. PLSPOSGLO(PLSINTPAD(),__aCdCri100[1],__aCdCri100[2],cLocalExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri100[1]} )
				aadd(aCodCri,{__aCdCri100[1],__aCdCri100[2],"","","",cCdTbPd,cCodPro})

				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"BOR")

				return(eval(__bRetErr,"BOR",cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodRDA))
			endIf

		endIf

		if ! empty(cRdaEDI) .and. BOR->(msSeek(xFilial("BOR")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+allTrim(cRdaEDI)))

			if 	BOR->BOR_PERM == "1" .and. PLSPOSGLO(PLSINTPAD(),__aCdCri100[1],__aCdCri100[2],cLocalExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri100[1]} )

				aadd(aCodCri,{__aCdCri100[1],__aCdCri100[2],"","","",cCdTbPd,cCodPro})

				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"BOR")

				return(eval(__bRetErr,"BOR",cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cRdaEDI))
			endIf
		endIf

	endIf

	//BFG - Cobertura Usuario...
	if aDadUsr[29] == "1"

		aRetFun := PLSVLDGEN(__aNiveis,nNiveis,"BFG",cCodInt+cCodEmp+cMatric+cTipoReg+cCdTbPd,cCodPro,cSexo,cCodInt,;
			dData,cHora,dDatCar,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,;
			cLocalExec,aDadRda,nIdade,cOpeSol,cCodPRFSol,lTratRda,cGuiaOpe,cGuiaEmp,cCodPla,;
			cVersao,cNumeroGuia,cTpLocExec,cFaces,nil,nil,cRdaEDI,cAreaAbr,cDente,aFaces,aQtdBrow,;
			aVldGen,cChavGui,cSequen,aBD7,cEspSol,cEspExe)

		if aRetFun[1]
			// Nao houve criticas neste nivel, mas houve critica de idade/sexo
			if aRetFun[2,1] .and. lCrSexIda
				return(eval(__bRetErr,aRetRDA[1],cCodInt+cCodesp))
			else
				return(aRetFun[2])
			endIf
		endIf
	endIf

	//BFE - Grupo Cobertura Usuario...
	if aDadUsr[30] == "1"

		aRetFun := PLSVLDGRU("BFE",cCodInt+cCodEmp+cMatric+cTipoReg,cSexo,cCodInt,dData,cHora,dDatCar,cCdTbPd,cCodPro,;
			nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,cLocalExec,aDadRda,nIdade,cOpeSol,cCodPRFSol,lTratRda,;
			cGuiaOpe,cGuiaEmp,cCodPla,cVersao,cNumeroGuia,cTpLocExec,cFaces,cAreaAbr,cDente,aFaces,aQtdBrow,;
			aVldGen,cChavGui,cRdaEdi,cSequen,aBD7,cEspSol,cEspExe,cRegInt,cTipoProc)

		if aRetFun[1]
			if aRetFun[2,1] .and. lCrSexIda // Nao houve criticas neste nivel, mas houve critica de idade/sexo
				return(eval(__bRetErr,aRetRDA[1],cCodInt+cCodesp))
			else
				return(aRetFun[2])
			endIf
		endIf
	endIf

	//BFD - Cobertura Familia...
	if aDadUsr[32] == "1"

		aRetFun := PLSVLDGEN(__aNiveis,nNiveis,"BFD",cCodInt+cCodEmp+cMatric+cCdTbPd,cCodPro,cSexo,cCodInt,;
			dData,cHora,dDatCar,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,;
			cLocalExec,aDadRda,nIdade,cOpeSol,cCodPRFSol,lTratRda,cGuiaOpe,cGuiaEmp,cCodPla,;
			cVersao,cNumeroGuia,cTpLocExec,cFaces,nil,nil,cRdaEDI,cAreaAbr,cDente,aFaces,aQtdBrow,;
			aVldGen,cChavGui,cSequen,aBD7,cEspSol,cEspExe)
		if aRetFun[1]
			if aRetFun[2,1] .and. lCrSexIda // Nao houve criticas neste nivel, mas houve critica de idade/sexo
				return(eval(__bRetErr,aRetRDA[1],cCodInt+cCodesp))
			else
				return(aRetFun[2])
			endIf
		endIf
	endIf

	//BFC - Grupo Cobertura Familia...
	if aDadUsr[33] == "1"

		aRetFun := PLSVLDGRU("BFC",cCodInt+cCodEmp+cMatric,cSexo,cCodInt,dData,cHora,dDatCar,cCdTbPd,cCodPro,;
			nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,cLocalExec,aDadRda,nIdade,cOpeSol,cCodPRFSol,lTratRda,;
			cGuiaOpe,cGuiaEmp,cCodPla,cVersao,cNumeroGuia,cTpLocExec,cFaces,cAreaAbr,cDente,aFaces,aQtdBrow,;
			aVldGen,cChavGui,cRdaEdi,cSequen,aBD7,cEspSol,cEspExe,cRegInt)

		if aRetFun[1]
			if aRetFun[2,1] .and. lCrSexIda // Nao houve criticas neste nivel, mas houve critica de idade/sexo
				return(eval(__bRetErr,aRetRDA[1],cCodInt+cCodesp))
			else
				return(aRetFun[2])
			endIf
		endIf
	endIf

	//BT8 - Cobertura Subcontrato x Produto
	if  cTipCEmp == "2"

		if aDadUsr[50] == "1"

			aRetFun := PLSVLDGEN(__aNiveis,nNiveis,"BT8",cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodPla+cVersao+cCdTbPd,cCodPro,;
				cSexo,cCodInt,dData,cHora,dDatCar,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,;
				cLocalExec,aDadRda,nIdade,cOpeSol,cCodPRFSol,lTratRda,cGuiaOpe,cGuiaEmp,cCodPla,cVersao,;
				cNumeroGuia,cTpLocExec,cFaces,nil,nil,cRdaEDI,cAreaAbr,cDente,aFaces,aQtdBrow,aVldGen,cChavGui,cSequen,aBD7,cEspSol,cEspExe)
			if aRetFun[1]
				if aRetFun[2,1] .and. lCrSexIda // Nao houve criticas neste nivel, mas houve critica de idade/sexo
					return(eval(__bRetErr,aRetRDA[1],cCodInt+cCodesp))
				else
					return(aRetFun[2])
				endIf
			endIf
		endIf

		//BT7 - Grupo Cobertura Subcontrato x Produto
		if aDadUsr[51] == "1"

			aRetFun := PLSVLDGRU("BT7",cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodPla+cVersao,cSexo,cCodInt,dData,cHora,;
				dDatCar,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,cLocalExec,aDadRda,;
				nIdade,cOpeSol,cCodPRFSol,lTratRda,cGuiaOpe,cGuiaEmp,cCodPla,cVersao,cNumeroGuia,;
				cTpLocExec,cFaces,cAreaAbr,cDente,aFaces,aQtdBrow,aVldGen,cChavGui,cRDAEdi,cSequen,aBD7,cEspSol,cEspExe,cRegInt)

			if aRetFun[1]
				if aRetFun[2,1] .and. lCrSexIda // Nao houve criticas neste nivel, mas houve critica de idade/sexo
					return(eval(__bRetErr,aRetRDA[1],cCodInt+cCodesp))
				else
					return(aRetFun[2])
				endIf
			endIf
		endIf

	endIf

	//(BT4) - rede de referenciada
	if  cTipCEmp <> "2" .or. (cTipCEmp == "2" .and. lConsJur) //pessoa fisica

		BT4->(dbSetOrder(1))
		cCodRdaBT := cCodRda
		cCodRda := iIf(!lTratRDA .And. empty(cCodRda) .And. M->BE1_ATERNA == "1" .And. aDadRDA != NIL .And. len(aDadRDA)>=2,aDadRDA[02],cCodRda)
		if !empty(cCodRDA) .and. BT4->(msSeek(xFilial("BT4")+cCodInt+cCodPla+cVersao+cCodRDA))

			if 	BT4->BT4_PERM == "1" .and. PLSPOSGLO(PLSINTPAD(),__aCdCri101[1],__aCdCri101[2],cLocalExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri101[1]} )
				aadd(aCodCri,{__aCdCri101[1],__aCdCri101[2],"","","",cCdTbPd,cCodPro})

				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"BT4")

				return(eval(__bRetErr,"BT4",cCodInt+cCodPla+cVersao+cCodRDA))
			endIf

		endIf
		cCodRda := cCodRdaBT
		if ! empty(cRdaEDI) .and. BT4->(msSeek(xFilial("BT4")+cCodInt+cCodPla+cVersao+allTrim(cRdaEDI)))

			if 	BT4->BT4_PERM == "1" .and. PLSPOSGLO(PLSINTPAD(),__aCdCri101[1],__aCdCri101[2],cLocalExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri101[1]} )

				aadd(aCodCri,{__aCdCri101[1],__aCdCri101[2],"","","",cCdTbPd,cCodPro})

				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"BT4")

				return(eval(__bRetErr,"BT4",cCodInt+cCodPla+cVersao+cRdaEDI))
			endIf

		endIf

	endIf

	//BB2 - Cobertura Produto...
	if lCobProd

		// Verifico se o produto NAO oferece cobertura a alguns tipos de internacoes|
		BYK->(dbSetOrder(7))
		cChave := xFilial("BYK") + cCodInt + cCodPla + cVersao + cGrpInt + "0"

		if  BYK->(msSeek(cChave)) .and. !empty(cGrpInt)

			lFlag := .t. // por enquanto ele tem direito
			while !BYK->(eof()) .and. BYK->(BYK_FILIAL+BYK_CODIGO+BYK_VERSAO+BYK_GRPINT+BYK_TIPINT+BYK_BENUTL) == cChave

				if  empty(BYK->BYK_CODPSA) .and. empty(BYK->BYK_CODDOE)
					lFlag := .f. // nao tem direito
					Exit
				endIf

				BYK->(dbSkip())
			endDo

			if !lFlag
				PLSPOSGLO(PLSINTPAD(),__aCdCri085[1],__aCdCri085[2])
				aadd(aCodCri,{__aCdCri085[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"BYK")

				return(eval(__bRetErr,"BYK",cCodInt+cCodPla+cVersao))
			endIf
		endIf

		aRetFun := PLSVLDGEN(__aNiveis,nNiveis,"BB2",cCodInt+cCodPla+cVersao+cCdTbPd,cCodPro,;
			cSexo,cCodInt,dData,cHora,dDatCar,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,;
			cLocalExec,aDadRda,nIdade,cOpeSol,cCodPRFSol,lTratRda,cGuiaOpe,cGuiaEmp,cCodPla,cVersao,cNumeroGuia,;
			cTpLocExec,cFaces,nil,nil,cRdaEDI,cAreaAbr,cDente,aFaces,aQtdBrow,aVldGen,cChavGui,cSequen,aBD7,cEspSol,cEspExe)
		if aRetFun[1]
			if aRetFun[2,1] .and. lCrSexIda // Nao houve criticas neste nivel, mas houve critica de idade/sexo
				return(eval(__bRetErr,aRetRDA[1],cCodInt+cCodesp))
			else
				return(aRetFun[2])
			endIf
		endIf
	endIf

	//BRV - Grupo Cobertura Produto...
	if lCobGCP

		aRetFun := PLSVLDGRU("BRV",cCodInt+cCodPla+cVersao,cSexo,cCodInt,dData,cHora,;
			dDatCar,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,cLocalExec,aDadRda,;
			nIdade,cOpeSol,cCodPRFSol,lTratRda,cGuiaOpe,cGuiaEmp,cCodPla,cVersao,cNumeroGuia,;
			cTpLocExec,cFaces,cAreaAbr,cDente,aFaces,aQtdBrow,aVldGen,cChavGui,cRdaEDI,cSequen,aBD7,cEspSol,cEspExe,cRegInt,cTipoProc)

		if aRetFun[1]
			if aRetFun[2,1] .and. lCrSexIda // Nao houve criticas neste nivel, mas houve critica de idade/sexo
				return(eval(__bRetErr,aRetRDA[1],cCodInt+cCodEsp))
			else
				return(aRetFun[2])
			endIf
		endIf
	endIf

	//Ultimo Nivel - Tabela Padrao (sempre pesquisa no item)
	if BR8->BR8_BENUTL == "1" .and. cConsPad <> "0"

		// Testa Idade Maxima/Minima, Sexo...
		aQtd    	:= PlRetPaQtd("BR8")
		aPerio	 	:= PlRetPaPer("BR8")
		nPerioPer 	:= BR8->BR8_PERIOD
		cUniPerio 	:= BR8->BR8_UNPERI

		//Se a periodicidade varia por idade

		if BR8->BR8_DIFIDA = '1'
			cChavePer := BR8->(BR8_FILIAL+BR8_CODPAD+BR8_CODPSA)
			aRetIdade := PLBUSDIFID("BR8",cChavePer,aDadUsr[26],nPerioPer,cUniPerio)
			nPerioPer := aRetIdade[1]
			cUniPerio := aRetIdade[2]
		End If

		aRetFun := PLSVLDAut(nIdade,BR8->BR8_IDAMIN,BR8->BR8_IDAMAX,BR8->BR8_SEXO,cSexo,;
			{BR8->BR8_UNCAR,BR8->BR8_CARENC,"1",BR8->BR8_CLACAR,cCodInt,dDatCar,.f.},dData,cHora,dDatCar,;
			cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,BR8->BR8_NIVEL,;
			BR8->BR8_QTD,BR8->BR8_UNCA,nPerioPer,cUniPerio,BR8->BR8_AUTORI,;
			cLocalExec,aDadRDA,cOpeSol,cCodPRFSol,lTratRda,cGuiaOpe,cGuiaEmp,cCodPla,cVersao,cNumeroGuia,cTpLocExec,;
			cFaces,"BR8",BR8->(BR8_FILIAL+BR8_CODPAD+BR8_CODPSA),aQtd,aPerio,cRdaEDI,cAreaAbr,cDente,aFaces,aQtdBrow,;
			aVldGen,cChavGui,cSequen,aBD7,cEspSol,cEspExe,;
			iIf(lBR8_UNIMIN,BR8->BR8_UNIMIN,''),iIf(lBR8_UNIMAX,BR8->BR8_UNIMAX,''),cChavLib,,,lIntPort,lMudFase, lAuto)

		if ! aRetFun[1]
			for nInd := 1 to len(aRetFun[2])
				if !PLSCHKExi(aCodCri,aRetFun[2,nInd,1]+cCodPro+aRetFun[2,nInd,3], .T.) // Adicionado mais um parâmetro porque não trazia corretamente a o array pra ser adicionado, assim pulando algumas críticas.
					aadd(aCodCri,{aRetFun[2,nInd,1],aRetFun[2,nInd,2],aRetFun[2,nInd,3],aRetFun[2,nInd,4],aRetFun[2,nInd,5],cCdTbPd,cCodPro,If(len(aRetFun[2,nInd])>=8,aRetFun[2,nInd,8],'')})
				endIf
			next
			return(eval(__bRetErr,"BR8",BR8->(BR8_CODPAD+BR8_CODPSA)))
		endIf

		// Procedimento autorizado...
		if lCrSexIda // Nao houve criticas neste nivel, mas houve critica de idade/sexo
			return(eval(__bRetErr,aRetRDA[1],cCodInt+cCodesp))
		else
			return(eval(__bRetAut,BR8->BR8_AUTORI,"BR8",BR8->(BR8_CODPAD+BR8_CODPSA)))
		endIf

	elseIf len(aOldRet) > 0

		return(aOldRet)

	elseIf cConsPad == "0" .And. !lUsrInt

		if PLSCHKCRI( {'BAU',cCodRda,__aCdCri001[1]} )

			if ascan(aCodCri,{|x|  x[1] == __aCdCri001[1] }) == 0
				eval(bAddCriPad)

				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"BI3")
			endIf

			return(eval(__bRetErr,"BI3",BI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO)))
		else
			return(eval(__bRetAut,BR8->BR8_AUTORI,"BR8",BR8->(BR8_CODPAD+BR8_CODPSA)))
		endIf

	elseIf cConsPad <> "0" .and. BR8->BR8_BENUTL == "0" .And. !lUsrInt

		if PLSCHKCRI( {'BAU',cCodRda,__aCdCri001[1]} )

			if ascan(aCodCri,{|x|  x[1] == __aCdCri001[1] }) == 0
				eval(bAddCriPad)
				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"BR8")
			endIf

			return(eval(__bRetErr,"BR8",BR8->(BR8_CODPAD+BR8_CODPSA)))
		else
			return(eval(__bRetAut,BR8->BR8_AUTORI,"BR8",BR8->(BR8_CODPAD+BR8_CODPSA)))
		endIf

	endIf

	// Caso nao autorize retorna o erro de nao autorizado padrao...
	if !lUsrInt
		eval(bAddCriPad)
	endif

	// alias e caminho da critica.
	PLSCOMPCRI(aCodCri,"BR8")

return(eval(__bRetErr,"BR8",BR8->(BR8_CODPAD+BR8_CODPSA)))

/*/{Protheus.doc} PLSGRUCOB
Tratamento para cobertura dentro de um Grupo de Cobertura
@type function
@author tuliocesar
@since 20.04.00
@version 1.0
/*/
function PLSGRUCOB(cCodInt,cCodGru,cCdTbPd,cCodPro,nIdade,cSexo,dData,cHora,dDatCar,nRegBD6,cOpeUsr,cMatrUsr,;
		aDadUsr,cCid,nQtd,cLocalExec,aDadRda,cOpeSol,cCodPRFSol,lTratRda,cGuiaOpe,cGuiaEmp,cCodPla,;
		cVersao,cNumeroGuia,cTpLocExec,cFaces,cAlias,cChaveAux,cAreaAbr,cDente,aFaces,aQtdBrow,aVldGen,;
		cChavGui,cRdaEDI,cSequen,aBD7,cEspSol,cEspExe,lMenorNiv,cTipoProc)
	local aArea		:= getArea()
	local lSeekVin	:= .f.
	local nNiveis   := (__aNiveis[1]+1)
	local cGruVin	:= ''
	local aRetFun	:= {}
	local bAddCriPad:= { || PLSPOSGLO(PLSINTPAD(),__aCdCri001[1],__aCdCri001[2],cLocalExec,nil,cTpLocExec), aadd(aCodCri,{__aCdCri001[1],PLSBCTDESC(),cCdTbPd+"-"+cCodPro,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro}) }

	default lTratRda 	:= .t.
	default cGuiaOpe 	:= ""
	default cGuiaEmp 	:= ""
	default cCodPLa  	:= ""
	default cVersao  	:= ""
	default cNumeroGuia := ""
	default cTpLocExec  := ""
	default cFaces		:= ""
	default cAlias      := ""
	default cChaveAux   := ""
	default cAreaAbr	:= ""
	default cDente		:= ""
	default aFaces      := {}
	default aQtdBrow	:= {}
	default aVldGen		:= {}
	default cChavGui	:= ""
	default cRdaEDI     := ""
	default cSequen		:= ""
	default aBD7		:= {}
	default cEspSol 	:= ''
	default cEspExe		:= ''
	default lMenorNiv	:= .f.
	default cTipoProc	:= ""

	// Valida no grupo de cobertura...
	aRetFun := PLSVLDGEN(__aNiveis,nNiveis,"BG8",cCodInt+cCodGru+cCdTbPd,cCodPro,;
		cSexo,cCodInt,dData,cHora,dDatCar,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,;
		cLocalExec,aDadRda,nIdade,cOpeSol,cCodPRFSol,lTratRda,cGuiaOpe,cGuiaEmp,cCodPla,cVersao,;
		cNumeroGuia,cTpLocExec,cFaces,cAlias,cChaveAux,cRdaEDI,cAreaAbr,cDente,aFaces,aQtdBrow,aVldGen,cChavGui,;
		cSequen,aBD7,cEspSol,cEspExe,@lMenorNiv,,cTipoProc)
	if aRetFun[1]
		restArea(aArea)
		return(aRetFun[2])
	endIf

	// Procura na TDE...
	BG7->(dbSetOrder(1))
	if BG7->(msSeek(xFilial("BG7")+cCodInt+cCodGru))

		lSeekVin := ! empty(BG7->BG7_GRUVIN)
		cGruVin  := BG7->BG7_GRUVIN

		// Procura no Grupo Vinculado...
		if lSeekVin

			// Valida no grupo de cobertura...
			aRetFun := PLSVLDGEN(__aNiveis,nNiveis,"BG8",cCodInt+cGruVin+cCdTbPd,cCodPro,;
				cSexo,cCodInt,dData,cHora,dDatCar,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,;
				cLocalExec,aDadRda,nIdade,cOpeSol,cCodPRFSol,lTratRda,cGuiaOpe,cGuiaEmp,cCodPla,cVersao,;
				cNumeroGuia,cTpLocExec,cFaces,cAlias,cChaveAux,cRdaEDI,cAreaAbr,cDente,aFaces,aQtdBrow,aVldGen,cChavGui,cSequen,aBD7,cEspSol,cEspExe,lMenorNiv)
			if aRetFun[1]
				restArea(aArea)
				return(aRetFun[2])
			endIf

		endIf

	endIf

	restArea(aArea)

return("NCR") //Nao checado regras para este grupo de cobertura

/*/{Protheus.doc} PLSVLDAUT
Valida Idade, Sexo, Carencia, etc...
@type function
@author tuliocesar
@since 20.04.00
@version 1.0
/*/
function PLSVLDAut(	nIdade,nIdaMin,nIdaMax,cSexoSis,cSexoUsr,aCarencia,;
		dDatPro,cHora,dDatCar,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,;
		cCid,nQtd,cNivel,nQtdPer,cUniPer,nPerioPer,cUniPerio,cAutori,cLocalExec,aDadRDA,cOpeSol,cCodPRFSol,;
		lTratRda,cGuiaOpe,cGuiaEmp,cCodPla,cVersao,cNumeroGuia,cTpLocExec,cFaces,cAliasAut,cChaveAut,;
		aQtd,aPerio,cRdaEDI,cAreaAbr,cDente,aFaces,aQtdBrow,aVldGen,cChavGui,cSequen,aBD7,cEspSol,cEspExe,;
		cUniMin,cUniMax,cChavLib,lGruAuto,cTipoProc,lIntPort,lMudFase, lAuto)

	local lVldSex     	:= eval( { || cSexoSis $ "3, " .or. cSexoUsr == cSexoSis .or. empty(cSexoUsr) } )
	local aRetPad     	:= {.t.,{}}
	local aSlvPad	  	:= {}
	local aCriticas   	:= {}

	local aArea			:= getArea()

	local cCodEsp    	:= ""
	local cOpeRda     	:= ""
	local lVldIda     	:= .f.
	local lFlag       	:= .f.
	local lQtdBYl	  	:= .f.
	local lQtdB05	  	:= .f.
	local lPerBYl	  	:= .f.
	local lVldAbr     	:= .t.
	local lTratQtd    	:= .t.
	local lTratPer    	:= .t.
	local lTratCar    	:= .t.
	local lTratGrpQd  	:= .t.
	local lNaoVldIda  	:= .f.
	local lNaoVldSex  	:= .f.
	local lNaoVldAbr  	:= .f.
	local lValGuiOpe  	:= .t.
	local lValGuiEmp  	:= .t.
	local lValGuiAud  	:= .t.
	local lAvalContr  	:= .t.
	local lAuditada   	:= .F.
	local cAbrOpeRDA  	:= ""
	local cListAbrUsr 	:= ""
	local cCodRda	  	:= ""
	local cRNameBD6		:= retSqlName("BD6")
	local cRNameBA1		:= retSqlName("BA1")
	local nI 		  	:= 1
	local nY		  	:= 1
	local cVldMatVid  	:= getNewPar("MV_PLSMTVD", "1")
	local nDiasMax		:= 0
	local nQtdFaces    	:= 0
	local nQtdFSol		:= 0
	local nQtdFHis		:= 0
	local nQtdFGui		:= 0
	local nPerdQtd  	:= 0
	local cPerdUni  	:= ""
	local cConsPer		:= ""
	local lAutori		:= .f.
	local cChave		:= ""
	local lPLPERSIT     := existBlock("PLPERSIT")
	local lLibPor       := .F.
	local lMud720       := IsInCallStack('PLSA720MF')
	local lGuiLib		:= .F.
	local cGuiPro		:= IIF(Empty(M->B4Q_GUIREF) .Or.  M->B4Q_GUIREF == NIL,"", M->B4Q_GUIREF)
	local nQtdExec		:= 0
	local cMVPLSRAC078  := getNewPar("MV_PLSRC78","3")
	local lCritRefeicao := .F.
	local lProcRefeicao := .F.
	local aRetRefAcomp  := {}
	Local cMatric   	:= aDadUsr[5]
	Local lLibCobr      := .F.

	default aDadRDA    := {}
	default cOpeSol    := ""
	default cCodPRFSol := ""
	default lTratRDA   := .t.
	default cGuiaOpe   := ""
	default cGuiaEmp   := ""
	default cCodPla    := ""
	default cVersao    := ""
	default cNumeroGuia:= ""
	default cTpLocExec := ""
	default cFaces     := ""
	default cAliasAut  := ""
	default cChaveAut  := ""
	default aQtd       := {}
	default aPerio	   := {}
	default cRdaEDI    := ""
	default cAreaAbr   := ""
	default cDente	   := ""
	default aFaces     := {}
	default aQtdBrow   := {}
	default aVldGen    := {}
	default cChavGui   := ""
	default cChavLib   := ""
	default cSequen	   := ""
	default aBd7	   := {}
	default cEspSol	   := ''
	default cEspExe	   := ''
	default cUniMin    := ''
	default cUniMax    := ''
	default lGruAuto   := .F.
	default cTipoProc  := ""
	default lIntPort   := .F.
	default lMudFase   := isInCallStack("PLSA720VMF") .or. isInCallStack("Z1PosTab")
	default lAuto      := .F.
	// Validação de idade minima e maxima
	if empty(nIdaMin) .And. !empty(nIdaMax)

		lVldIda := eval({ || ( ( nIdade <= nIdaMax) .or. ( nIdaMax == 0 ) .or.;
			( ! empty(aDadUsr[45]) .and. aDadUsr[45] <> cOpeUsr) ) })

	elseif empty(nIdaMax) .And. !empty(nIdaMin)

		lVldIda := eval({ || ( ( nIdade >= nIdaMin) .or. ( nIdaMin == 0 ) .or.;
			( ! empty(aDadUsr[45]) .and. aDadUsr[45] <> cOpeUsr) ) })

	elseif (!empty(nIdaMin) .And. !empty(nIdaMax)) .Or. (empty(nIdaMin) .And. empty(nIdaMax))

		lVldIda := eval({ || ( ( nIdade >= nIdaMin .and. nIdade <= nIdaMax ) .or.;
			( nIdaMin == 0 .and. nIdaMax == 0 ) .or. ( ! empty(aDadUsr[45]) .and. aDadUsr[45] <> cOpeUsr) ) })

	endIf

	// Existiam clientes que possuiam os campos BR8_UNIMIN E BR8_UNIMX na sua base preenchidos...
	// Estes campos são de quando o sistema foi iniciado... por isso precisavam de tratamento
	if ! empty(cUniMin) .and. nIdaMin > 0

		//dias
		if cUniMin == '0'
			nIdaMin := round(nIdaMin/365,2)
			//meses
		elseIf cUniMin == '1'
			nIdaMin := round(nIdaMin/12,2)
		endIf

		lVldIda := eval( {|| ( ( nIdade >= nIdaMin .and. nIdade <= nIdaMax ) .or. ( nIdaMin == 0 .and. nIdaMax == 0 ) .or. ( ! empty(aDadUsr[45]) .and. aDadUsr[45] <> cOpeUsr) ) })

	endIf

	if ! empty(cUniMax) .and. nIdaMax > 0

		//dias
		if cUniMax == '0'
			nIdaMax := round(nIdaMax/365,2)
			//meses
		elseIf cUniMax == '1'
			nIdaMax := round(nIdaMax/12,2)
		endIf

		lVldIda := eval( {|| ( ( nIdade >= nIdaMin .and. nIdade <= nIdaMax ) .or. ( nIdaMin == 0 .and. nIdaMax == 0 ) .or. (!empty(aDadUsr[45]) .and. aDadUsr[45] <> cOpeUsr) ) })

	endIf

	If FWAliasInDic("BKV")
		lProcRefeicao := PLProcRefeic(cCdTbPd, cCodPro)

		If lProcRefeicao
			aRetRefAcomp := PLCheckRefeic(nIdade, cCdTbPd, cCodPro, lIntPort, cOpeUsr, aDadUsr)
			lCritRefeicao := !aRetRefAcomp[1]
		EndIf

	EndIf

	// Codigo da Rda
	cCodRda := iIf(lTratRDA,( iIf(len(aDadRda)>2,aDadRda[2],"" ) ),"")

	// seto as variaveis que vao identificar quais regras eu devo checar na funcao generica de validacoes
	if len(aVldGen) >= 1 .and. aVldGen[1] != nil
		lTratQtd     := aVldGen[1] //indica se devo checar a regra de quandtidade
	endIf
	if len(aVldGen) >= 2 .and. aVldGen[2] != nil
		lTratPer     := aVldGen[2]//indica se devo checar a regra de periodicidade
	endIf
	if len(aVldGen) >= 3 .and. aVldGen[3] != nil
		lTratCar     := aVldGen[3]//indica se devo checar a regra de carencia
	endIf
	if len(aVldGen) >= 4 .and. aVldGen[4] != nil
		lTratGrpQd   := aVldGen[4]//indica se devo checar a regra de grupo de quantidade
	endIf
	if len(aVldGen) >= 5 .and. aVldGen[5] != nil
		lNaoVldIda   := aVldGen[5]//indica se eu nao devo validar a Idade
	endIf
	if len(aVldGen) >= 6 .and. aVldGen[6] != nil
		lNaoVldSex   := aVldGen[6]//indica se eu nao devo validar o sexo
	endIf
	if len(aVldGen) >= 7 .and. aVldGen[7] != nil
		lNaoVldAbr   := aVldGen[7]//indica se eu nao devo validar a abrangencia
	endIf
	if len(aVldGen) >= 8 .and. aVldGen[8] != nil
		lValGuiOpe   := aVldGen[8]//indica se seu devo chegar a regra de guia na operadora
	endIf
	if len(aVldGen) >= 9 .and. aVldGen[9] != nil
		lValGuiEmp   := aVldGen[9]//indica se seu devo chegar a regra de guia na empresa
	endIf
	if len(aVldGen) >= 10 .and. aVldGen[10] != nil
		lValGuiAud   := aVldGen[10]//indica se seu devo chegar a regra de guia auditada
	endIf
	if len(aVldGen) >= 11 .and. aVldGen[11] != nil
		lAvalContr   := aVldGen[11]//indica se seu devo chegar a regra de avaliacao contratual
	endIf

	//Início da validação crítica 078

	if ( cMVPLSRAC078 == "3" ) .or. ( cMVPLSRAC078 == "1" .and. cTipoProc == "S" ) .or. ( cMVPLSRAC078 == "2" .and. cTipoProc == "E" )

		if BR8->BR8_QTMAAU > 0 .and. PLSPOSGLO(PLSINTPAD(),__aCdCri140[1],__aCdCri140[2],cLocalExec,'1',cTpLocExec) .and. ( nQtd < BR8->BR8_QTMIAU .or. !(nQtd >= BR8->BR8_QTMIAU .and. nQtd <= BR8->BR8_QTMAAU) .or.  nQtd > BR8->BR8_QTMAAU)


			lRet := .f.

			if PLSPOSGLO(PLSINTPAD(),__aCdCri140[1],__aCdCri140[2],cLocalExec,'1',cTpLocExec) .and. !PLSCHKExi(aCodCri,__aCdCri140[1]+cCodPro)

				aadd(aCodCri,{__aCdCri140[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro,subStr(cChavGui,34,3)})

				if cTipoProc == "S"
					aadd(aCodCri,{""   ,STR0101,"","","",cCdTbPd,cCodPro,subStr(cChavGui,34,3)})          //"Solicitação"
				else
					aadd(aCodCri,{""   ,STR0102,"","","",cCdTbPd,cCodPro,subStr(cChavGui,34,3)})                //"Execução"
				endIf

				aadd(aCodCri,{""   ,STR0117,allTrim(Str(BR8->BR8_QTMIAU)),"","",cCdTbPd,cCodPro,subStr(cChavGui,34,3)})  //"Quantidade minima permitida"
				aadd(aCodCri,{""   ,STR0118,allTrim(Str(BR8->BR8_QTMAAU)),"","",cCdTbPd,cCodPro,subStr(cChavGui,34,3)})  //"Quantidade máxima permitida"

				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"BR8")

			endIf
			aRet := {.f.,aCodCri,"BR8","",.f.}
		endIf

	endIf
	//Fim da validação crítica 078

	If  !lGruAuto
		if ! empty(cDente) .and. ! empty(cFaces)

			cSQL := " SELECT BYL_AUTORI "
			cSQL += "   FROM " + RetSqlName("BYL") + " WHERE "
			cSQL += " BYL_FILIAL = '" + xFilial("BYL")+ "' AND "
			cSQL += " BYL_CODPAD = '" + cCdTbPd + "' AND "
			cSQL += " BYL_CODPSA = '" + allTrim(cCodPro) + "' AND "
			cSQL += " BYL_CODIGO = '" + allTrim(cDente) + "' AND "
			cSQL += " BYL_FACE   = '" + allTrim(cFaces) + "' AND "
			cSQL += " D_E_L_E_T_ = ' ' "

			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSTratQtd",.f.,.t.)

			if ! PLSTratQtd->(eof())

				if ! empty(PLSTratQtd->BYL_AUTORI)
					cAutori := PLSTratQtd->BYL_AUTORI
					lAutori := .t.
				endIf

			endIf

			PLSTratQtd->( dbCloseArea() )

		endIf

		// Tratamento odontologico
		if ! empty(cDente) .and. !lAutori

			cSQL := "SELECT B05_IDAMAX, B05_IDAMIN "

			// Campo de tipo de autorização no nivel de dente.
			if B05->( FieldPos("B05_AUTORI") ) > 0
				cSQL += ", B05_AUTORI "
			endIf

			cSQL += "FROM "+RetSqlName("B05")+" WHERE "
			cSQL += "B05_FILIAL = '"+xFilial("B05")+"' AND "
			cSQL += "B05_CODPAD = '"+cCdTbPd+"' AND "
			cSQL += "B05_CODPSA = '"+allTrim(cCodPro)+"' AND "
			cSQL += "B05_CODIGO = '"+allTrim(cDente)+"' AND "
			cSQL += "D_E_L_E_T_ = ' ' "

			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSTratIda",.f.,.t.)

			if ! PLSTratIda->(eof())

				plsTField("PLSTratIda",.f.,{ "B05_IDAMIN","B05_IDAMAX" } )

				if PLSTratIda->B05_IDAMAX > 0
					nIdaMin   := PLSTratIda->B05_IDAMIN
					nIdaMax   := PLSTratIda->B05_IDAMAX
				endIf

				if !empty(PLSTratIda->B05_AUTORI)
					cAutori := PLSTratIda->B05_AUTORI
				endIf

			endIf

			lVldIda := eval({ || ( ( nIdade >= nIdaMin .and. nIdade <= nIdaMax ) .or. ( nIdaMin == 0 .and. nIdaMax == 0 ) ) })

			PLSTratIda->(DbCloseArea())

		endIf
	EndIf

	if len(aDadRda) > 0
		cCodEsp := aDadRda[15]
		cOpeRda := aDadRda[14]
	else

		if lTratRda .and. len(aDadRda) == 0
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',STR0083+" ["+funName()+"]" , 0, 0, {})//"PLSVLDAUT aDadRda Invalido"
		endIf

		cCodEsp := ""
		cOpeRda := PLSINTPAD()
	endIf

	// Abrangencia
	if empty(cAreaAbr) .and. len(aDadUsr) >= 65 .and. !empty(aDadUsr[65])
		cAreaAbr := aDadUsr[65]
	endIf

	lAuditada := PLSLibAud(cCodPro,cCdTbPd,cChavLib)
	//Seek necessário pois nesse ponto existia uma função que posicionava na BR8
	//e esse posicionamento era utilizado em outras funçõs, como a função foi retirada
	//o registro ficou desposicionado.
	BR8->(dbSetOrder(1))
	BR8->(msSeek(xFilial("BR8") + cCdTbPd + cCodPro))

	// Se a autorizacao for 0 - Dispensa autorizacao nao checa nada...
	if cAutori <> "0" //zero, nao checa regra nenhuma.

		if ! empty(aCarencia[4]) //a classe de carencia esta preenchida...

			PlsClascar(aCarencia,aDadUsr,cCdTbPd,cCodPro,cOpeUsr,cCodPla,cVersao,.t.,cAliasAut,cChaveAut)

			if len(aCarencia) >= 6 .and. ! empty(aCarencia[6])
				dDatCar := aCarencia[6]
			endIf

		endIf

		if !lVldIda .And. !lNaoVldIda .And. !lProcRefeicao

			if PLSPOSGLO(PLSINTPAD(),__aCdCri002[1],__aCdCri002[2],cLocalExec,nil,cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri002[1]} )

				aadd(aCriticas,{__aCdCri002[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
				aadd(aCriticas,{""   ,STR0006,allTrim(Str(nIdaMin)),"","",cCdTbPd,cCodPro}) //"Idade Minima"
				aadd(aCriticas,{""   ,STR0007,allTrim(Str(nIdaMax)),"","",cCdTbPd,cCodPro}) //"Idade Maxima"
				aadd(aCriticas,{""   ,STR0008,allTrim(Str(nIdade)),"","",cCdTbPd,cCodPro}) //"Idade Usuario"

				if ! empty(cDente)
					aadd(aCriticas,{""   ,STR0086, allTrim(cDente), "","",cCdTbPd,cCodPro}) //"Dente"
				endIf

				if ! empty(cFaces)
					aadd(aCriticas,{""   ,STR0076, allTrim(cFaces), "","",cCdTbPd,cCodPro}) //"Faces"
				endIf

				PLSCOMPCRI(aCriticas,cAliasAut,cChaveAut)

			else
				lVldIda := .t.
			endIf
		endIf

		//se forco a nao validacao da idade seto sempre true
		if lNaoVldIda
			lVldIda := .t.
		endIf

		If lCritRefeicao

			If PLSPOSGLO(PLSINTPAD(), __aCdCri242[1], __aCdCri242[2], cLocalExec, nil, cTpLocExec)
				aAdd(aCriticas,{__aCdCri242[1], PLSBCTDESC(), "", BCT->BCT_NIVEL, BCT->BCT_TIPO, cCdTbPd, cCodPro})

				For nY := 1 To Len(aRetRefAcomp[2])
					aAdd(aCriticas,{"", STR0006+" / "+STR0007, AllTrim(Str(aRetRefAcomp[2,nY,1]))+" / "+AllTrim(Str(aRetRefAcomp[2,nY,2])), "", "", cCdTbPd, cCodPro}) //"Idade Minima";"Idade Maxima"
				Next nY

				aAdd(aCriticas,{"", STR0008, AllTrim(Str(nIdade)), "", "", cCdTbPd, cCodPro}) //"Idade Usuario"
				aAdd(aCriticas,{"", STR0200, STR0201, "", "", cCdTbPd, cCodPro}) //"Deficiente";"Não"

				cAliasAut := 'BKV'
				cChaveAut := cCdTbPd+cCodPro
				PLSCOMPCRI(aCriticas, cAliasAut, cChaveAut)

			EndIf
		EndIf

		if ! lVldSex  .and. !lNaoVldSex

			if PLSPOSGLO(PLSINTPAD(),__aCdCri004[1],__aCdCri004[2],cLocalExec,nil,cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri004[1]} )

				if !PLSCHKExi(aCodCri,__aCdCri004[1]+cCodPro)

					aadd(aCriticas,{__aCdCri004[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
					aadd(aCriticas,{""   ,STR0009            	  ,X3COMBO("BR8_SEXO",allTrim(cSexoSis)),"","",cCdTbPd,cCodPro}) //"Sexo do Procedimento"
					aadd(aCriticas,{""   ,STR0010                 ,X3COMBO("BR8_SEXO",allTrim(cSexoUsr)),"","",cCdTbPd,cCodPro}) //"Sexo Usuario"

					if ! empty(cDente)
						aadd(aCriticas,{""   ,STR0086, allTrim(cDente), "","",cCdTbPd,cCodPro}) //"Dente"
					endIf

					if ! empty(cFaces)
						aadd(aCriticas,{""   ,STR0076, allTrim(cFaces), "","",cCdTbPd,cCodPro}) //"Faces"
					endIf

					PLSCOMPCRI(aCriticas,cAliasAut,cChaveAut)

				else

					aCriticas := aCodCri

				endIf

			else
				lVldSex := .t.
			endIf

		endIf

		// se forco a nao validacao do sexo seto sempre true
		if lNaoVldSex
			lVldSex := .t.
		endIf

		// Tratamento de abrangencia
		// O tratamento anterior nao atendia a demanda de mercado para MULTI-Opera
		// doras, por isso o linha abaixo devera ser descontinuada na versao 9
		// Daher 21/08/2006
		//Retirado na versão 12.. Oscar 19/05/2020

		// Trata carencia e preexistencia...
		if lTratCar
			aRetPad := PLSTRATCar(	aCarencia[1],aCarencia[2],aCarencia[3],dDatPro,cHora,dDatCar,cCdTbPd,cCodPro,;
				nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,cLocalExec,cCodEsp,cOpeRda,aDadRda,cOpeSol,;
				cCodPRFSol,lTratRda,aCriticas,cAliasAut, lAuto)
		else
			if len(aCriticas) > 0
				aRetPad := {.f.,aCriticas}
			endIf
		endIf
		// Trata Quantidade permitida ...
		// Tratamento odontologico
		if !empty(cDente) .and. !empty(cFaces)

			cSQL := "SELECT BYL_QTD, BYL_UNCA,  BYL_PERIOD, BYL_UNPERI, BYL_TIPO, BYL_CONPER , BYL_DIFIDA "
			cSQL += " FROM "+RetSqlName("BYL")+" WHERE "
			cSQL += "BYL_FILIAL = '"+xFilial("BYL")+"' AND "
			cSQL += "BYL_CODPAD = '"+cCdTbPd+"' AND "
			cSQL += "BYL_CODPSA = '"+allTrim(cCodPro)+"' AND "
			cSQL += "BYL_CODIGO = '"+allTrim(cDente)+"' AND "
			cSQL += "BYL_FACE   = '"+allTrim(cFaces)+"' AND "
			cSQL += "D_E_L_E_T_ = ' ' "

			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSTratQtd",.f.,.t.)

			if ! PLSTratQtd->(eof())

				plsTField("PLSTratQtd",.f.,{ "BYL_QTD","BYL_PERIOD" } )

				if PLSTratQtd->BYL_QTD > 0

					// Referente a quantidade.
					nQtdPer   := PLSTratQtd->BYL_QTD
					cUniPer   := PLSTratQtd->BYL_UNCA

					// NOVO: Referente a periodicidade para quantidade.
					nPerdQtd  := PLSTratQtd->BYL_PERIOD
					cPerdUni  := PLSTratQtd->BYL_UNPERI

					//Se a periodicidade varia por idade
					if PLSTratQtd->BYL_DIFIDA = '1'
						cChavePer 	:= xFilial("BYL")+allTrim(cCdTbPd)+allTrim(cCodPro)+allTrim(cDente)+PLSTratQtd->BYL_TIPO+allTrim(cFaces)
						aRetIdade 	:= PLBUSDIFID("BYL",cChavePer,aDadUsr[26],nPerdQtd,cPerdUni)
						nPerdQtd 	:= aRetIdade[1]
						cPerdUni   	:= aRetIdade[2]
					endIf

					// NOVO: Considera periodicidade para quantidade ?
					cConsPer  := PLSTratQtd->BYL_CONPER

					aQtd    := PlRetPaQtd("BYL")
					lQtdBYl	:= .t.

				endIf

			endIf

			PLSTratQtd->(DbCloseArea())

		endIf

		// Tratamento odontologico - Dente
		if !empty(cDente) .and. !lQtdBYl

			cSQL := "SELECT B05_QTD, B05_UNCA, B05_PERIOD, B05_UNPERI, B05_TIPO ,B05_CONPER,B05_DIFIDA "
			cSQL += " FROM "+RetSqlName("B05")+" WHERE "
			cSQL += "B05_FILIAL = '"+xFilial("B05")+"' AND "
			cSQL += "B05_CODPAD = '"+cCdTbPd+"' AND "
			cSQL += "B05_CODPSA = '"+allTrim(cCodPro)+"' AND "
			cSQL += "B05_CODIGO = '"+allTrim(cDente)+"' AND "
			cSQL += "D_E_L_E_T_ = ' ' "

			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSTratQtd",.f.,.t.)

			if ! PLSTratQtd->(eof())

				plsTField("PLSTratQtd",.f.,{ "B05_QTD","B05_PERIOD" } )

				if PLSTratQtd->B05_QTD > 0

					// Referente a quantidade.
					nQtdPer   := PLSTratQtd->B05_QTD
					cUniPer   := PLSTratQtd->B05_UNCA

					// NOVO: Referente a periodicidade para quantidade.
					nPerdQtd  := PLSTratQtd->B05_PERIOD
					cPerdUni  := PLSTratQtd->B05_UNPERI

					//Se a periodicidade varia por idade
					if PLSTratQtd->B05_DIFIDA = '1'
						cChavePer 	:= xFilial("B05")+cCdTbPd+allTrim(cCodPro)+allTrim(cDente)+PLSTratQtd->B05_TIPO
						aRetIdade 	:= PLBUSDIFID("B05",cChavePer,aDadUsr[26],nPerdQtd,cPerdUni)
						nPerdQtd 	:= aRetIdade[1]
						cPerdUni   	:= aRetIdade[2]
					endIf

					// NOVO: Considera periodicidade para quantidade ?
					cConsPer  := PLSTratQtd->B05_CONPER

					aQtd      := PlRetPaQtd("B05")
					lQtdB05   := .t.
				endIf

			endIf

			PLSTratQtd->(DbCloseArea())

		endIf

		if nQtdPer > 0 .and. PLSPOSGLO(PLSINTPAD(),__aCdCri046[1],__aCdCri046[2],cLocalExec,nil,cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri046[1]} ) .and. lTratQtd .And. !PLSCheckTEA(cMatric, cCid, cCdTbPd, cCodPro)
			If funName()=="RPC" .And. (nRegBD6 > 0 .Or. !Empty(cNumeroGuia))
				lLibPor := .T.
			EndIf

			If funName()=="PLSA094B" .Or. (funName()=="RPC" .And. Empty(cNumeroGuia))
				lGuiLib := .T.
			EndIf

			If funName() == "PLSA09P" .And. !Empty(cGuiPro)  .And. BR8->BR8_TPPROC =='4'  //Utiliza a Guia de Referencia na prorrogação para contar o qtd de diarias na internação e prorrogação.
				BEJ->(dbSetOrder(2))//BEJ_FILIAL + BEJ_CODOPE + BEJ_ANOINT + BEJ_MESINT + BEJ_NUMINT + BEJ_CODPAD + BEJ_CODPRO
				If BEJ->(dbSeek(xFilial("BEJ") + cGuiPro+cCdTbPd+cCodPro))
					nQtdExec := BEJ->BEJ_QTDPRO
				EndIf

				cSQL := " SELECT SUM(BQV_QTDPRO) AS BQV_QTDPRO FROM " +RetSqlName("B4Q") + " B4Q, " +RetSqlName("BQV")+ " BQV "
				cSQL += " WHERE B4Q.B4Q_FILIAL = '"+xFilial("B4Q")+"' AND "
				cSQL += " BQV.BQV_FILIAL = '" +xFilial("BQV")+ "' AND "
				cSQL += " B4Q.B4Q_GUIREF = '" +cGuiPro+ "' AND "
				cSQL += " BQV.BQV_CODOPE = B4Q_OPEMOV AND "
				cSQL += " BQV.BQV_ANOINT = B4Q_ANOAUT AND "
				cSQL += " BQV.BQV_MESINT = B4Q_MESAUT AND "
				cSQL += " BQV.BQV_NUMINT = B4Q_NUMAUT AND "
				cSQL += " BQV.BQV_CODPRO = '" +cCodPro+ "' AND "
				cSQL += " BQV.BQV_STATUS = '1' AND BQV.D_E_L_E_T_ = ' ' AND B4Q.D_E_L_E_T_ = ' '"

				dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSQL),"PLSBQVVERPROC",.f.,.t.)
				If !PLSBQVVERPROC->(EoF())
					nQtdExec += PLSBQVVERPROC->BQV_QTDPRO
				EndIf
				PLSBQVVERPROC->(DbCloseArea())

			EndIf

			// Trata quantidade convencional.s
			aRetPad := PlsTratQtd(	aDadUsr[2],dDatPro,cHora,cCdTbPd,cCodPro,nQtd,nQtdPer,cUniPer,;
				cLocalExec,nRegBD6,cNivel,aQtd,aPerio,aDadRDA,cCid,aDadUsr,;
				cAliasAut,cRdaEDI,cFaces,cDente,aFaces,aRetPad,aQtdBrow,cChavGui,;
				nPerdQtd,cPerdUni,cConsPer,cSequen,nQtdExec,cEspExe,lLibPor,cEspSol,lGuiLib,lIntPort, cNumeroGuia,lMudFase)

		endIf
		// Depois de tratar a quantidade convencional, trata novo conceito de tratamento de quantidade...
		// novo conceito de quantidade para tratar restaurações: Neste caso, existe mais de um procedimento que devem ser aglutinados
		// A soma dessa aglutinação não pode ser maior que a quantidade permitida.

		// Verifica na tabela padrão, a quantidae de faces que o procedimento contempla em caso de restauração.
		B04->( dbSetOrder(01) )
		if 	!empty(cDente) .and. B04->( msSeek(xFilial("B04")+cDente))

			// Reposiciona tabela padrao.
			if (cCdTbPd+cCodPro) <> BR8->(BR8_CODPAD+BR8_CODPSA)
				// Reposiciona Tabela
				BR8->( dbSetOrder(01) )
				BR8->( msSeek(xFilial("BR8")+cCdTbPd+cCodPro) )
			endIf

			// Se a quantidade de faces for maior que zero, entra na regra...
			if B04->B04_QTDFAC > 0 .and. BR8->BR8_QTDFAC > 0

				// Reinicia as variaveis
				nQtdFaces	:= 0
				nQtdFSol	:= 0
				nQtdFHis	:= 0
				nQtdFGui	:= 0

				// Primeiro: Quantidade de faces baseado na quantidade solicitada.
				nQtdFSol := (nQtd * BR8->BR8_QTDFAC)

				// Segundo: Quantidade de faces baseado no historico do paciente.
				cSQL := "SELECT BR8_CODPAD, BR8_CODPSA, BR8_QTDFAC FROM "+RetSqlName("BR8")+" WHERE "
				cSQL += "BR8_FILIAL = '"+xFilial("BR8")+"' AND "
				cSQL += "BR8_QTDFAC > 0 AND "
				cSQL += "D_E_L_E_T_ = ' ' "

				dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSTratQtd",.f.,.t.)

				if !PLSTratQtd->(eof())
					plsTField("PLSTratQtd",.f.,{ "BR8_QTDFAC" } )
				endIf

				// Vou pegar todos os procedimentos que se enquadram na mesma regra.
				aProcs := {}
				while !PLSTratQtd->( eof() )

					aadd(aProcs, {PLSTratQtd->BR8_CODPAD, PLSTratQtd->BR8_CODPSA, PLSTratQtd->BR8_QTDFAC} )

					PLSTratQtd->( dbSkip() )
				endDo

				PLSTratQtd->(DbCloseArea())

				// Ja sei quais são os procedimentos que se enquadram na mesma regra.
				// Agora vou buscar esses procedimentos no historico do usuario, para saber o quanto ele ja executou.
				for nY := 1 to len(aProcs)

					//Periodo maximo em dias que o historico pode ser consultado para verificação de pre-requisitos.
					nDiasMax 	:= PLSCalcDia(B04->B04_PERIOD,B04->B04_UNIDAD)

					// Consulta ao historico do paciente...
					cSQL := "SELECT BD6_QTDPRO "

					if cVldMatVid == "2"	// Utiliza matricua da vida.
						cSql += "FROM "+cRNameBD6+","+cRNameBA1+" WHERE "
					else
						cSql += "FROM "+cRNameBD6+" WHERE "
					endIf

					if cVldMatVid == "2"	// Utiliza matricua da vida.
						cSQL += "BA1_FILIAL = BD6_FILIAL AND "
						cSQL += "BA1_CODINT = BD6_OPEUSR AND "
						cSQL += "BA1_CODEMP = BD6_CODEMP AND "
						cSQL += "BA1_MATRIC = BD6_MATRIC AND "
						cSQL += "BA1_TIPREG = BD6_TIPREG AND "
						cSQL += "BA1_MATVID = '"+aDadUsr[5]+"' AND "

					else	// Utiliza verificação pela matricula do contrato.
						cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
						cSQL += "BD6_OPEUSR = '"+Subs(aDadUsr[2],atCodOpe[1],atCodOpe[2])+"' AND "
						cSQL += "BD6_CODEMP = '"+Subs(aDadUsr[2],atCodEmp[1],atCodEmp[2])+"' AND "
						cSQL += "BD6_MATRIC = '"+Subs(aDadUsr[2],atMatric[1],atMatric[2])+"' AND "
						cSQL += "BD6_TIPREG = '"+Subs(aDadUsr[2],atTipReg[1],atTipReg[2])+"' AND "
						cSQL += "BD6_DIGITO = '"+Subs(aDadUsr[2],atDigito[1],atDigito[2])+"' AND "

					endIf
					cSQL += "BD6_CODPAD = '"+aProcs[nY][1]+"' AND "
					cSQL += "BD6_CODPRO = '"+aProcs[nY][2]+"' AND "
					cSQL += "BD6_DENREG = '"+cDente+"' AND "

					// Se nDiasMax == 0 significa que deve olhar para todos historico, sem limitecao de periodo.
					if nDiasMax > 0
						cSQL += "BD6_DATPRO > '"+dtos(dDatPro-nDiasMax)+"' AND "
					endIf

					cSQL += "( BD6_FASE = '3' OR BD6_FASE = '4') AND "
					if lPLPERSIT
						cSQL += execBlock("PLPERSIT",.f.,.f.)
						cSQL += " AND  "
					else
						cSQL += "( ( BD6_SITUAC = '1' ) OR ( BD6_SITUAC = '3' AND BD6_LIBERA = '1') )  AND BD6_STATUS <> '0' AND  "
					endIf

					if findFunction("PlReChvEst")
						aRetAux  := PlReChvEst("BD6",.t.,.f.,.t.,.f.)
						cSQL     += aRetAux[1]
					endIf
					cSQL += cRNameBD6 + ".D_E_L_E_T_ = ' ' "

					dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSHIS",.f.,.t.)

					if !PLSHIS->(eof())
						plsTField("PLSHIS",.f.,{ "BD6_QTDPRO" } )
					endIf

					// Multiplica a quantidade de vezes que o procedimento foi encontrado no historico pela quantidade de faces
					// que ele abrange.
					while !PLSHIS->( eof() )

						nQtdFHis += (PLSHIS->BD6_QTDPRO * aProcs[nY][3])

						PLSHIS->( dbSkip() )
					endDo

					PLSHIS->( dbCloseArea() )

					// Terceiro: Quantidade de faces baseado nos itens ja digitados na guia.
					if len(aQtdBrow) > 0
						Aeval(aQtdBrow, {|x| If( (x[1] == aProcs[nY][1] .and.;
							x[2] == aProcs[nY][2] .and.;
							x[6] == cDente), nQtdFGui += (x[3] * aProcs[nY][3]), nil)})
					endIf
				next

				// Soma as faces...
				nQtdFaces := (nQtdFSol+nQtdFHis+nQtdFGui)

				// Se a quantidade de faces ja executadas no dente, for maior que a permitida, critica.
				if nQtdFaces > B04->B04_QTDFAC .And. !PLSCheckTEA(cMatric, cCid, cCdTbPd, cCodPro)

					// Valida existencia da critica...
					PLSPOSGLO(PLSINTPAD(),__aCdCri046[1],__aCdCri046[2],cLocalExec)

					aRetPad[1] := .f.

					aadd(aRetPad[2],{__aCdCri046[1],PLSBCTDESC(),"", BCT->BCT_TIPO, BCT->BCT_NIVEL,cCdTbPd,cCodPro})
					aadd(aRetPad[2],{""   ,STR0030 + STR0031, Str(B04->B04_QTDFAC, 6),"","",cCdTbPd,cCodPro}) 	//"Quantidade permitida para o procedimento foi excedida"
					aadd(aRetPad[2],{""   ,STR0032, Str(nQtdFHis, 6), "","",cCdTbPd,cCodPro}) 					//"Quantidade ja executada pelo usuario"
					aadd(aRetPad[2],{""   ,STR0033, Str(nQtdFSol+nQtdFGui, 6), "","",cCdTbPd,cCodPro}) 			//"Quantidade solicitada"
					aadd(aRetPad[2],{""   ,STR0034, Str(Abs((nQtdFSol+nQtdFGui+nQtdFHis)-B04->B04_QTDFAC),6)   , "","",cCdTbPd,cCodPro})					 //"Quantidade Ultrapassada pelo usuario"

					if !empty(cDente)
						aadd(aRetPad[2],{""   ,STR0086, allTrim(cDente), "","",cCdTbPd,cCodPro}) 				//"Dente"
					endIf

					PLSCOMPCRI(aRetPad[2],cAliasAut,cChaveAut)
				endIf
			endIf

		endIf

		// Trata Periodicidade permitida ...
		// Tratamento odontologico
		if !empty(cDente) .and. !empty(cFaces)

			cSQL := "SELECT BYL_PERIOD, BYL_UNPERI, BYL_CODPAD, BYL_CODPSA, BYL_CODIGO, BYL_TIPO ,BYL_CONPER ,BYL_DIFIDA "
			cSQL += "FROM "+RetSqlName("BYL")+" WHERE "
			cSQL += "BYL_FILIAL = '"+xFilial("BYL")+"' AND "
			cSQL += "BYL_CODPAD = '"+cCdTbPd+"' AND "
			cSQL += "BYL_CODPSA = '"+allTrim(cCodPro)+"' AND "
			cSQL += "BYL_CODIGO = '"+allTrim(cDente)+"' AND "
			cSQL += "BYL_FACE   = '"+allTrim(cFaces)+"' AND "
			cSQL += "D_E_L_E_T_ <> '*'"

			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSTratPer",.f.,.t.)

			if ! PLSTratPer->(eof())

				plsTField("PLSTratPer",.f.,{ "BYL_PERIOD" } )

				if PLSTratPer->BYL_PERIOD > 0

					nPerioPer   := PLSTratPer->BYL_PERIOD
					cUniPerio   := PLSTratPer->BYL_UNPERI
					cChave		:= PLSTratPer->(BYL_CODPAD+BYL_CODPSA+BYL_CODIGO)

					//Se a periodicidade varia por idade
					if PLSTratPer->BYL_DIFIDA == '1'

						cChavePer := xFilial("BYL")+allTrim(cCdTbPd)+allTrim(cCodPro)+allTrim(cDente)+PLSTratQtd->BYL_TIPO+allTrim(cFaces)
						aRetIdade := PLBUSDIFID("BYL",cChavePer,aDadUsr[26],nPerioPer,cUniPerio)
						nPerioPer := aRetIdade[1]
						cUniPerio := aRetIdade[2]

					endIf

					aPerio	:= PlRetPaPer("BYL",cChave)

					// NOVO: Considera periodicidade para quantidade ?
					cConsPer  := PLSTratPer->BYL_CONPER

					lPerBYl		:= .t.
				endIf

			endIf

			PLSTratPer->(DbCloseArea())

		endIf

		// Tratamento odontologico
		if !empty(cDente) .and. !lPerBYl

			cSQL := "SELECT B05_PERIOD, B05_UNPERI, B05_CODPAD, B05_CODPSA, B05_CODIGO, B05_TIPO, B05_CONPER,B05_DIFIDA "
			cSQL += " FROM "+RetSqlName("B05")+" WHERE "
			cSQL += "B05_FILIAL = '"+xFilial("B05")+"' AND "
			cSQL += "B05_CODPAD = '"+cCdTbPd+"' AND "
			cSQL += "B05_CODPSA = '"+allTrim(cCodPro)+"' AND "
			cSQL += "B05_CODIGO = '"+allTrim(cDente)+"' AND "
			cSQL += "D_E_L_E_T_ = ' ' "

			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSTratPer",.f.,.t.)

			if ! PLSTratPer->(eof())

				plsTField("PLSTratPer",.f.,{ "B05_PERIOD" } )

				if PLSTratPer->B05_PERIOD > 0

					nPerioPer   := PLSTratPer->B05_PERIOD
					cUniPerio   := PLSTratPer->B05_UNPERI
					cChave		:= PLSTratPer->(B05_CODPAD+B05_CODPSA+B05_CODIGO)

					//Se a periodicidade varia por idade
					if PLSTratPer->B05_DIFIDA = '1'

						cChavePer := xFilial("B05")+cCdTbPd+allTrim(cCodPro)+allTrim(cDente)+PLSTratQtd->B05_TIPO
						aRetIdade := PLBUSDIFID("B05",cChavePer,aDadUsr[26],nPerioPer,cUniPerio)
						nPerioPer := aRetIdade[1]
						cUniPerio := aRetIdade[2]

					endIf

					aPerio := PlRetPaPer("B05",cChave)

					// NOVO: Considera periodicidade para quantidade ?
					cConsPer  := PLSTratPer->B05_CONPER
				endIf
			endIf

			PLSTratPer->(DbCloseArea())

		endIf

		if PLSPOSGLO(PLSINTPAD(),__aCdCri047[1],__aCdCri047[2],cLocalExec,nil,cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri047[1]} ) .and. lTratPer .and. cConsPer <> "1" .And. !PLSCheckTEA(cMatric, cCid, cCdTbPd, cCodPro)
			If funName()=="RPC" .And. (nRegBD6 > 0 .Or. !Empty(cNumeroGuia))
				lLibPor := .T.
			EndIf

			If funName()=="PLSA094B" .Or. funName()=="RPC" .And. Empty(cNumeroGuia)
				lGuiLib := .T.
			EndIf

			aRetPad := PlsTratPer(aDadUsr[2],dDatPro,cHora,cCdTbPd,cCodPro,nQtd,nPerioPer,cUniPerio,cLocalExec,aDadRDA,nRegBD6,;
				cCid,lTratRda,cNivel,aDadUsr,cFaces,aQtd,aPerio,cAliasAut,cRdaEDI,cDente,aFaces,aRetPad,nil,;
				nil,aQtdBrow,cChavGui,nil,nil,cChaveAut,cSequen,,cEspExe,lLibPor,cEspSol,lGuiLib,lIntPort)
		endIf

		// Trata o grupo de quantidade
		if PLSPOSGLO(PLSINTPAD(),__aCdCri139[1],__aCdCri139[2],cLocalExec,nil,cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri139[1]} ) .and. lTratGrpQd
			aRetPad := PLSGrpQtd(cCdTbPd,cCodPro,aDadUsr,aRetPad,nQtd,dDatPro,nRegBD6,cHora,cLocalExec)
		endIf

	endIf

	//críticas relacionadas a cobertura não devem aparecer no PTU ONLINE
	If  cAutori $ "2,3,4,5,6" .And. FindFunction("PLAutIntUrgPTU") .And. IsInCallStack('PLAutIntUrgPTU')
		lLibCobr:= .T.
	EndIF

	// Se der tudo ok ou nao eu vejo se pode ser liberado direto...
	if cAutori $ "2,3,4,5,6" .And. !lLibCobr    // se estiver com alguns desses ja sei que vai haver critica

		//joga no aCriticas criticas que ja podem ter existido...
		if ! aRetPad[1]
			aCriticas := aClone(aRetPad[2])
		endIf

		If empty(cCodRda) .AND. len(aDadRda) >= 2
			cCodRda := aDadRda[2]
		endIf

		lFlag := .f.

		if cAutori == "2" .and. empty(cGuiaOpe) .and. PLSPOSGLO(PLSINTPAD(),__aCdCri050[1],__aCdCri050[2],cLocalExec,nil,cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri050[1]} ) .and. (lValGuiOpe .Or. lMud720)  // Guia Operadora

			aadd(aCriticas,{__aCdCri050[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

			PLSCOMPCRI(aCriticas,cAliasAut,cChaveAut)
			lFlag := .t.

		elseIf cAutori == "2" .and. !Empty(cGuiaOpe) .and. PLSPOSGLO(PLSINTPAD(),__aCdCri050[1],__aCdCri050[2],cLocalExec,nil,cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri050[1]} ) .And. !PLRetGuiAut(cGuiaOpe,cCodPro,cCdTbPd)  .And. !IsInCallStack('PLSA090') .And. !IsInCallStack('PUTAUTHORIZATION') // Guia Operadora e guia que irá executar o procedimento dentro do portal.
			aadd(aCriticas,{__aCdCri050[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

			PLSCOMPCRI(aCriticas,cAliasAut,cChaveAut)
			lFlag := .T.

		elseIf cAutori == "3" .and. !lAuditada .And.  PLSPOSGLO(PLSINTPAD(),__aCdCri051[1],__aCdCri051[2],cLocalExec,nil,cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri051[1]} ) .and. lValGuiAud
			aadd(aCriticas,{__aCdCri051[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
			PLSCOMPCRI(aCriticas,cAliasAut,cChaveAut)
			lFlag := .t.

		elseIf cAutori == "4" .and. empty(cGuiaEmp) .and. PLSPOSGLO(PLSINTPAD(),__aCdCri052[1],__aCdCri052[2],cLocalExec,nil,cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri052[1]} ) .and. lValGuiEmp// Guia Empresa

			aadd(aCriticas,{__aCdCri052[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

			PLSCOMPCRI(aCriticas,cAliasAut,cChaveAut)
			lFlag := .t.

		elseIf cAutori == "5" .and. empty(cGuiaOpe) .and. empty(cGuiaEmp) .and. PLSPOSGLO(PLSINTPAD(),__aCdCri053[1],__aCdCri053[2],cLocalExec,nil,cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri053[1]} ) .and. lValGuiOpe .and. lValGuiEmp // Guia Empresa / Operadora

			aadd(aCriticas,{__aCdCri053[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

			PLSCOMPCRI(aCriticas,cAliasAut,cChaveAut)
			lFlag := .t.

		elseIf cAutori == "6" .and. PLSPOSGLO(PLSINTPAD(),__aCdCri054[1],__aCdCri054[2],cLocalExec,nil,cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri054[1]} ) .and. lAvalContr// Avaliacao Contratual

			aadd(aCriticas,{__aCdCri054[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

			PLSCOMPCRI(aCriticas,cAliasAut,cChaveAut)
			lFlag := .t.

		endIf

		if lFlag
			aRetPad := {.f.,aCriticas}
		endIf

	endIf

	restArea(aArea)

return(aRetPad)

/*/{Protheus.doc} PLSTRATCAR
Valida carencia
@type function
@author tuliocesar
@since 20.04.00
@version 1.0
/*/
function PLSTRATCar(cUnCar,nDiascar,cNivCar,dDatPro,cHora,dDatCar,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,;
		aDadUsr,cCID,cLocalExec,cCodEsp,cOpeRda,aDadRda,cOpeSol,cCodPRFSol,lTratRda,aCriticas,cAliasAut, lAuto)
	Local cCodEmp   	:= Subs(cOpeUsr+cMatrUsr,atCodEmp[1],atCodEmp[2])
	Local cCodRda 		:= iIf( len(aDadRda)>2,aDadRda[2],"" )

	Local nDiasFT
	Local nDias
	Local cCodPadCon
	Local cCodProCon
	Local cSQL
	Local dAux
	Local aOldCrit
	Local aOldCadCri
	Local aSubSid

	Local lOK		  	:= .T.
	Local lCritDet  	:= .F.
	Local lCpoBF3   	:= .F.
	Local lDoenca   	:= .F.
	Local lCrit005		:= .F.
	Local lUsrInt       := iIf( allTrim( getNewPar("MV_PLSGEIN","")) == cCodEmp,.t.,.f.)
	Local lGloCar   	:= PLSPOSGLO(PLSINTPAD(),__aCdCri003[1],__aCdCri003[2],cLocalExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri003[1]} ) .and. !lUsrInt
	Local lGloDoe   	:= PLSPOSGLO(PLSINTPAD(),__aCdCri018[1],__aCdCri018[2],cLocalExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri018[1]} )

	Local nCarCmp		:= 0

	Local cNameBF3  	:= RetSQLName("BF3")
	Local cNameBYY  	:= RetSQLName("BYY")
	Local cFilBF3   	:= xFilial("BF3")
	Local cCodDoe   	:= ""
	Local cDesDoe   	:= ""
	Local cCodInt   	:= Subs(cOpeUsr+cMatrUsr,atCodOpe[1],atCodOpe[2])
	Local cMatric   	:= Subs(cOpeUsr+cMatrUsr,atMatric[1],atMatric[2])
	Local cTipoReg  	:= Subs(cOpeUsr+cMatrUsr,atTipReg[1],atTipReg[2])
	Local cDsDoe    	:= PLSBCTDESC()
	Local cTpCar    	:= BCT->BCT_TIPO
	Local cNvCar    	:= BCT->BCT_NIVEL
	Local cCdPrBYY		:= ""
	Local cAliasTrb	   	:= Getnextalias()
	Local cMvPLSCDCO   	:= GETMV("MV_PLSCDCO")

	Local aRetSub   	:= {}
	Local aRetCri   	:= {}
	Local aAreaBAU		:= {}
	Local aAreaBR8		:= {}
	Local aArea     	:= GetArea()


	Default lTratRda 	:= .T.
	Default nDiascar	:= 0
	Default cCodEsp 	:= ""
	Default cOpeRda 	:= ""
	Default cNivCar  	:= ""
	Default cAliasAut	:= ""
	Default aCriticas 	:= {}
	Default lAuto       := .F.
	// Verififa PRE-Existencia no usuario...
	if aDadUsr[31] == "1" .and. !empty(cCid)

		BRW->(dbSetOrder(1))
		if ( getNewPar("MV_PLSPREE","1") == "2" ) .or. ( BRW->(msSeek(xFilial("BRW")+BR8->(BR8_CODROL))) .and. BRW->BRW_COMPLE == "1" )

			cSQL := "SELECT BF3_CODDOE, BF3_MESAGR, BF3_UNAGR ,BF3_CODPAD ,BF3_CODPSA "

			lCpoBF3 := BF3->(FieldPos("BF3_DATCPT")) > 0

			if lCpoBF3
				cSQL += ", BF3_DATCPT "
			endIf

			cSQL += "FROM "
			cSQL += cNameBF3 +" WHERE "
			cSQL += "BF3_FILIAL = '"+cFilBF3+"' AND "
			cSQL += "BF3_CODINT = '"+cCodInt+"' AND "
			cSQL += "BF3_CODEMP = '"+cCodEmp+"' AND "
			cSQL += "BF3_MATRIC = '"+cMatric+"' AND "
			cSQL += "BF3_TIPREG = '"+cTipoReg+"' AND "
			cSQL += "BF3_CODDOE = '"+cCid+"' AND "
			cSQL += "((BF3_CODPAD = '"+cCdTbPd+"' AND BF3_CODPSA = '"+cCodPro+"')"
			cSQL += " OR (BF3_CODPAD = ' ' AND BF3_CODPSA= ' ')) AND "
			cSQL += "BF3_PAGAGR <> '1' AND "
			cSQL += "D_E_L_E_T_ = ' ' "

			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSTRATCar",.f.,.t.) //Query na BF3 para ver se existe CID pré-existente vinculado.

			if ! PLSTRATCar->(eof())

				plsTField("PLSTRATCar",.f.,{ "BF3_MESAGR","BF3_DATCPT" } )

				if BA9->BA9_CODDOE <> PLSTRATCar->BF3_CODDOE
					BA9->(dbSetOrder(1))
					BA9->(msSeek(xFilial("BA9")+PLSTRATCar->BF3_CODDOE))
				endIf
				BAA->(dbSetOrder(1)) //Ver primeiro se este procedimento está na BAA, se estiver é crítica pré-existente.
				If BAA->(msSeek(xFilial("BAA")+PLSTRATCar->BF3_CODDOE+cCdTbPd+cCodPro))
					lCrit005 	:= .T.
					nDiascar 	:= BA9->BA9_MESAGR
					cAliasAut	:= "BA9"
					cUnCar   	:= BA9->BA9_UNAGR
				EndIf

				cCodDoe  := allTrim(PLSTRATCar->BF3_CODDOE)
				cDesDoe  := BA9->BA9_DOENCA

				If 	PLSTRATCar->BF3_MESAGR > 0 .And. !Empty(PLSTRATCar->BF3_UNAGR) //Se tiver o CID na BF3 com os dias de carências e a unidade de carência, começa a pegar por lá, é um nível a mais da BAA.
					lCrit005 	:= .T.
					cAliasAut	:= "BF3"
					nDiascar := PLSTRATCar->BF3_MESAGR
					cUnCar   := PLSTRATCar->BF3_UNAGR
				EndIf

				if empty(PLSTRATCar->BF3_CODPAD) .or. empty(PLSTRATCar->BF3_CODPSA)

					cSQL := "SELECT BYY_CODDOE, BYY_CODPRO, BYY_CARENC, BYY_UNIDAD "
					cSQL += "FROM " + cNameBYY
					cSQL += " WHERE BYY_FILIAL = '" + xFilial('BYY') + "' AND "
					cSQL += "       BYY_CODINT = '" + cCodInt + "' AND "
					cSQL += "       BYY_CODEMP = '" + cCodEmp + "' AND "
					cSQL += "       BYY_MATRIC = '" + cMatric + "' AND "
					cSQL += "       BYY_TIPREG = '" + cTipoReg + "' AND "

					cSQL += "       BYY_CODDOE = '" + cCodDoe + "' AND "
					cSQL += "       BYY_CODPAD = '" + cCdTbPd + "' AND "
					cSQL += "       BYY_CODPRO = '" + cCodPro + "' AND "
					cSQL += "       D_E_L_E_T_ = ' ' "

					dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSCARBYY",.f.,.t.) //Faz query para ver se existe o procedimento na BYY como exceção de carência (se existir na query, quer dizer que a tem uma nova carência no procedimento da BYY).

					if ! PLSCARBYY->(eof())

						plsTField("PLSCARBYY",.f.,{ "BYY_CARENC" } )

						lCrit005 	:= .T.
						nDiascar 	:= PLSCARBYY->BYY_CARENC
						cAliasAut	:= "BYY"
						cUnCar   	:= PLSCARBYY->BYY_UNIDAD

					endIf

					PLSCARBYY->(DbCloseArea())
				endIf

				cDesDoe  := BA9->BA9_DOENCA

				If lCrit005 //se a crítica for de pré-existência (entrar na BAA ou BYY), cai aqui para dar a mesma.
					lDoenca  := .t.
				EndIf

				if lCpoBF3 .and. ! empty(PLSTRATCar->BF3_DATCPT) //se existir valor no BF3_DATCPT, alterna a data da carência que busca da BA1_DATCAR

					dDatCar := PLSTRATCar->BF3_DATCPT

				endIf

			endIf

			PLSTRATCar->(DbCloseArea())
			RestArea(aArea)
		endIf

	endIf

	// Testa se existe carencia a ser verificada...
	if nDiascar == 0 .and. cNivCar <> "1"
		if len(aCriticas) >0
			return( {.f.,aCriticas} )
		else
			return( {.t.,{}} )
		endIf
	endIf

	if cUnCar $ "2,3,4" // Dias,Meses,Anos

		nDias 	:= PLSCarDias(nDiascar,cUnCar) // Calcula em dias
		dAux	:= dDatCar+nDias

		if dtos(dDatPro) < dtos(dAux)

			nDiasFT := dAux - dDatPro
			nCarCmp := nDias-nDiasFT

			if nCarCmp < 1
				nCarCmp := 0
			endIf

			if !lDoenca .and. lGloCar
				lOK	:= .f.
				aadd(aCriticas,{__aCdCri003[1],__aCdCri003[2]            ,"",cTpCar,cNvCar,cCdTbPd,cCodPro})
				lCritDet := .t.
			endif
			If lDoenca .and. lGloDoe 
				lOK	:= .f.
				if !lGloCar .And. !lAuto
				aadd(aCriticas,{__aCdCri003[1],__aCdCri003[2]            ,"",cTpCar,cNvCar,cCdTbPd,cCodPro})
				aadd(aCriticas,{""   ," " + STR0012  + dtoc(dDatCar) + ")", allTrim(str(nDiascar))+" "+X3COMBO("BR8_UNCAR",cUnCar),"","",cCdTbPd,cCodPro}) //"Carencia do procedimento ("
				aadd(aCriticas,{""   ," " +STR0013+dtoc(dDatPro),allTrim(Str(nCarCmp))+STR0014,"","",cCdTbPd,cCodPro}) //"Carencia cumprida ate a data do procedimento "###" Dias"
				aadd(aCriticas,{""   ," " +STR0015                  ,allTrim(Str(nDiasFT)),"","",cCdTbPd,cCodPro}) //"Quantidade restante de dias ate a utilizacao"
				aadd(aCriticas,{""   ," " +STR0016                ,dtoc(dAux)+" ("+PLSDIASEM(dAux)+")","","",cCdTbPd,cCodPro}) //"Data em que podera ser realizado o procedimento"
				endif
				aadd(aCriticas,{__aCdCri018[1],cDsDoe                 ,"",cTpCar,cNvCar,cCdTbPd,cCodPro})
				aadd(aCriticas,{"" , STR0011,cCodDoe+" - "+cDesDoe,"","",cCdTbPd,cCodPro}) //"Doenca Preexistente do usuario"
				lCritDet := .t.				
			endIf
			
			if lCritDet
				aadd(aCriticas,{""   ,STR0012 + dtoc(dDatCar) + ")", allTrim(str(nDiascar))+" "+X3COMBO("BR8_UNCAR",cUnCar),"","",cCdTbPd,cCodPro}) //"Carencia do procedimento ("
				aadd(aCriticas,{""   ,STR0013+dtoc(dDatPro),allTrim(Str(nCarCmp))+STR0014,"","",cCdTbPd,cCodPro}) //"Carencia cumprida ate a data do procedimento "###" Dias"
				aadd(aCriticas,{""   ,STR0015                  ,allTrim(Str(nDiasFT)),"","",cCdTbPd,cCodPro}) //"Quantidade restante de dias ate a utilizacao"
				aadd(aCriticas,{""   ,STR0016                ,dtoc(dAux)+" ("+PLSDIASEM(dAux)+")","","",cCdTbPd,cCodPro}) //"Data em que podera ser realizado o procedimento"
			endIf

			if len(aCriticas) > 0
				PLSCOMPCRI(aCriticas,cAliasAut)
			endIf
		endIf
	elseIf cUnCar == "1"   // Horas

		BeginSql alias cAliasTrb
			SELECT * FROM %table:BX1% BX1
			WHERE BX1.BX1_FILIAL = %exp:xFilial("BX1")% AND  BX1_recno = %exp:strZero(BA1->(recno()),tamSx3("BX1_recno")[2])%  AND BX1_DATA= %exp:BA1->BA1_DATINC%  AND  BX1_TIPO='I' AND BX1.%notDel%
		Endsql

		aRetPeri := PlsEntrePeri(BA1->BA1_DATINC,(cAliasTrb)->BX1_HORA,Msdate(),time(),nDiascar)

		nHora := 0

		if aRetPeri[1] > 0 //em Dias
			nHora += (aRetPeri[1]*24)
		endIf

		if aRetPeri[2] > 0 //em horas
			nHora += aRetPeri[2]
		endIf

		if (nDiascar > nHora )

			lOK	:= .f.
			aadd(aCriticas,{__aCdCri003[1],__aCdCri003[2] ,"",cTpCar,cNvCar,cCdTbPd,cCodPro})
			aadd(aCriticas,{""   ,"Carencia do procedimento hora/data de Inicio ( "+If(!empty((cAliasTrb)->BX1_HORA),(subStr((cAliasTrb)->BX1_HORA,1,5)+"  /  "+ dtoc(stod((cAliasTrb)->BX1_DATA)))," Não há registro de inclusão na BX1") + " ) ", allTrim(str(nDiascar))+" "+X3COMBO("BR8_UNCAR",cUnCar),"","",cCdTbPd,cCodPro}) //"Carencia do procedimento ("
			aadd(aCriticas,{""   ,"Hora em que podera ser realizado o procedimento ("+aRetPeri[6]+"  /  "+ dtoc(Stod((cAliasTrb)->BX1_DATA)+aRetPeri[5])+")","","",cCdTbPd,cCodPro}) //"Data em que podera ser realizado o procedimento"
			lCritDet := .t.
		endIf

		(cAliasTrb)->(DbCloseArea())
	endIf
	// Caso esteja em carencia vou verificar exames subsidiarios na especialidade
	if ! lOK  .and. lTratRda

		aAreaBAU	:= BAU->(getArea())
		aAreaBR8	:= BR8->(getArea())

		aOldCrit   	:= aClone(aCriticas)
		aOldCadCri 	:= aClone(aCodCri)

		aCriticas  	:= {}
		aCodCri		:= {}

		BAU->(dbSetOrder(5))
		if BAU->(msSeek(xFilial("BAU")+cCodPRFSol))

			BBF->(dbSetOrder(1))
			if BBF->(msSeek(xFilial("BBF")+BAU->BAU_CODIGO))

				while ! BBF->(eof()) .and. BBF->(BBF_FILIAL+BBF_CODIGO) == xFilial("BBF")+BAU->BAU_CODIGO

					aSubSid := PLSTRATSUB(cOpeSol,BBF->BBF_CDESP,cCdTbPd,cCodPro,__aNiveis)

					// verificar a carencia da consulta...
					if aSubSid[1]

						cCodPadCon := Subs(cMvPLSCDCO,1,2)
						cCodProCon := Subs(cMvPLSCDCO,3,16)

						cCodProCon := cCodProCon+Space(16-len(cCodProCon))

						aRetSub := PLSAUTP(dDatPro,cHora,cCodPadCon,cCodProCon,1,aDadUsr,nRegBD6,aDadRDA,"1",;
							.f.,cCid,.t.,cLocalExec,.f.,"","","","","","","",nil,nil)

						if ( aRetSub[1] ) .or. ( ( ! aRetSub[1] ) .and. ( ! aRetSub[2,1,1] $ __aCdCri003[1]+","+__aCdCri018[1] ) )
							lOK       := .t.
						endIf
					endIf

					BBF->(dbSkip())
				endDo

			endIf
		endIf

		aCriticas := aClone(aOldCrit)
		aCodCri   := aClone(aOldCadCri)

		BAU->(restArea(aAreaBAU))
		BR8->(restArea(aAreaBR8))
	endIf
	// Retorno da funcao...
	if ! lOK
		aRetCri := {.f.,aCriticas}
	else
		if len(aCriticas) > 0
			aRetCri := {.f.,aCriticas}
		else
			aRetCri := {.t.,{}}
		endIf

	endIf

return(aRetCri)

/*/{Protheus.doc} PLSAUTPMDD

Verifica se o Médico tem permissão para solicitar/executar o procedimento

Criticas validadas:
__aCdCri020,__aCdCri021,__aCdCri039,__aCdCri044,__aCdCri062,__aCdCri083
__aCdCri104,__aCdCri126,__aCdCri127,__aCdCri128,__aCdCri177,__aCdCri181

@type function
@author tuliocesar
@param cOpeRDA  , caracter, Operadora Rede de Atendimento
@param cMatrRDA , caracter, Codigo Rede de Atendimento
@param cCdTbPd  , caracter, Codigo Tab Padrao
@param cCodPro  , caracter, Codigo Procedimento
@param aDadRDA  , array,    Dados da Rede de Atendimento
@param cTipo    , caracter, 1 - Execucao
2 - Solicitacao
@param cOrdPes  , caracter, 1 - Primeiro:Procedimentos nao autorizados
Segundo :Procedimentos autorizados
2 - Primeiro:Procedimentos autorizados
Segundo :Procedimentos nao autorizados
@param aBD7, Array, Array bi-dimensional com informações de especialidade do Prestador, Solicitante e Executante
[1] - Unidade da composição
[2] - Contratado,Especialidade,local,Tipo de Pessoa,Flag tipo Profissional - PRESTADOR
[3] - Contratado,Especialidade,local,Tipo de Pessoa,Flag tipo Profissional - EXECUTANTE
[4] - Contratado,Especialidade,local,Tipo de Pessoa,Flag tipo Profissional - SOLICITANTE
@since 20.04.00
@version 1.0
/*/
function PLSAUTPMDD(cOpeRDA,cCodRDA,cCdTbPd,cCodPro,aDadRDA,cTipo,aDadUsr,cLocalExec,cCodEsp,cCodLoc,lSolicitante,aLocais,;
		dDatPro,aBD7,cEspSol,cEspExe,lTiss,lTlocal,lLimpCri,cEspCri,lVldXML,cCodPRFSol)
	local nNiveis    	:= 0
	local nIdade     	:= 0
	local cSexo      	:= ""
	local cCodPla  	 	:= ""
	local cVersao  	 	:= ""
	local cCodGru  	 	:= ""
	local aArea      	:= BAX->(GetArea())
	local lAltCus    	:= iIf(len(aDadRda)>=30,iIf(aDadRda[30]=="1",.t.,.f.),.f.)
	local cDado      	:= ""
	local cSQL       	:= ""
	local nfor       	:= 0
	local nInd       	:= 1
	local cMVPLSREGE	:= getNewPar("MV_PLSREGE","1")
	local cMVPLSREGS	:= getNewPar("MV_PLSREGS","0")
	local aRetGeral  	:= {.T., ""}
	local lTratarEsp	:= .t.
	local cNomRda	 	:= iIf(BAU->BAU_CODIGO <> cCodRDA,Posicione("BAU",1,xFilial("BAU")+cCodRDA,'BAU_NOME'),BAU->BAU_NOME)
	local cFilBBM   	:= xFilial("BBM")
	local cNameBBM		:= RetSQLName("BBM")
	local cFilBC0   	:= xFilial("BC0")
	local cNameBC0  	:= RetSQLName("BC0")
	local cFilBBN   	:= xFilial("BBN")
	local cNameBBN  	:= RetSQLName("BBN")
	local cIntPad		:= plsIntPad()
	local lGlo20 		:= PLSPOSGLO(cIntPad,__aCdCri020[1],__aCdCri020[2],cLocalExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri020[1]} )
	local cDes20 		:= PLSBCTDESC()//RDA nao autorizada a executar o procedimento (Campo Executa/Solicita/Ambos
	local lGlo39 		:= PLSPOSGLO(cIntPad,__aCdCri039[1],__aCdCri039[2],cLocalExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri039[1]} )
	local cDes39 		:= PLSBCTDESC()//Solicitante nao autorizado a solicitar este procedimento (Campo Executa/Solicita/Ambos)
	local bAddCriPad	:= { |cAlias| If(!PLSCHKExi(aCodCri, If(!lSolicitante,__aCdCri020[1],__aCdCri039[1]) + cCodPro ) .and. ((lSolicitante .and. lGlo39) .or. (!lSolicitante .and. lGlo20)) ,;
		(aadd(aCodCri,{If(!lSolicitante,__aCdCri020[1],__aCdCri039[1]),IF(!lSolicitante,cDes20,cDes39);
		,"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro}),PLSCOMPCRI(aCodCri,cAlias)), ) }
	local lGlo21 		:= PLSPOSGLO(cIntPad,__aCdCri021[1],__aCdCri021[2],cLocalExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri021[1]} )
	local cDes21 		:= PLSBCTDESC()//Procedimento bloqueado na especialidade de Rede de atendimento.
	local lGlo103 		:= PLSPOSGLO(cIntPad,__aCdCri104[1],__aCdCri104[2],cLocalExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri104[1]} )
	local cDes103 		:= PLSBCTDESC()//Rede de atendimento de Alto Custo
	local lGlo181 		:= PLSPOSGLO(cIntPad,__aCdCri181[1],__aCdCri181[2],cLocalExec)
	local cDes181 		:= PLSBCTDESC()//Procedimento bloqueado na sub-especialidade de Rede de atendimento
	local lGlo177 		:= PLSPOSGLO(cIntPad,__aCdCri177[1],__aCdCri177[2],cLocalExec)//Cobranca bloqueada devido ao Parcelamento
	local cVarAux		:= ""

	local cOrdPes  		:= "1"
	local cChave   		:= ""
	local ni       		:= 0
	local lCond	    	:= .f.
	local cFilLog   	:= "PLSTREXE.LOG"
	local lGrupo    	:= .f.
	local lFoundBC0 	:= .f.
	local nforBE9   	:= 1
	local lFoundBE9 	:= .f.
	local cNameBE9  	:= RetSqlName("BE9")
	local lTrtSubEsp 	:= .f.
	local lPrcOutEsp 	:= .f.
	local lContinua  	:= .t.
	local lBC0_VIGDE  	:= BC0->(FieldPos("BC0_VIGDE")) > 0
	local lBC0_VIGATE 	:= BC0->(FieldPos("BC0_VIGATE")) > 0
	local lBC0_DATBLO 	:= BC0->(FieldPos("BC0_DATBLO")) > 0
	local lBFP_DATVAL 	:= BFP->(FieldPos("BFP_DATVAL")) > 0
	local lBBM_DATVAL 	:= BBM->(FieldPos("BBM_DATVAL")) > 0
	local lAutorB3Z     := .f.
	local lAutorB0G     := .f.
	local aAreaBI3      := {}
	local cWhile		:= ""
	local cDesLoc       := ""
	local lPLSESP01     := existBlock("PLSESP01")
	local nTamBE9_VIGATE:= tamSx3("BE9_VIGATE")[1]
	local aRetBQ1       := {}
	local cDesProSol    := ""
	local lAchouEsp 	:= .F. // utilizada para criticar quando não encontrar proc. na BBM da especialidade

	default cCodEsp     := aDadRDA[15]
	default cCodLoc     := Subs(aDadRDA[12],1,3)
	default lSolicitante:= .f.
	default aLocais  	:= {}
	default dDatPro     := dDataBase
	default aBD7		:= {}
	default cEspSol	  	:= ''
	default cEspExe		:= ''
	default lTiss		:= .f.
	default lTlocal		:= .f.
	default lLimpCri    := .f.
	default lVldXML		:= .f.
	default aDadUsr		:= PLSGETUSR()
	default cCodPRFSol  := ""

	if len(aDadUsr) >= 71
		cCodPla	:= aDadUsr[11]
		cVersao	:= aDadUsr[12]
		cSexo 	:= aDadUsr[25]
		nIdade	:= aDadUsr[27]
		cCodGru	:= aDadUsr[71]
	endIf

	if len(allTrim(cCodLoc)) > 3 // Tratamento para chamadas com a localidade para nao dar problema no indice
		cCodLoc := subs(cCodLoc,1,3) // pego apenas o local
	endIf

	if __cCdTbPd <> cCdTbPd .or. len(__aNiveis) == 0
		__cCdTbPd := cCdTbPd
		__aNiveis := PLSESPNIV(cCdTbPd)
	endIf
	nNiveis := (__aNiveis[1]+1)

	if lTiss
		aLocais := PLSLOCRDA(cCodRda,cOpeRda)//o alocais nao vem preenchido quando eh tiss
	endIf

	if ! lTiss

		if BAX->(msSeek(xFilial("BAX")+cCodRda+cOpeRda+cCodLoc+cCodEsp))

			if BAX->(FieldPos("BAX_ORDPES")) > 0 .and. BAX->BAX_ORDPES == "2"
				cOrdPes := "2"
			endIf

			if BAX->BAX_CONESP <> "0"
				lTratarEsp := .t.
			else
				lTratarEsp := .f.
			endIf

			//Verifica a data de bloqueio da especialidade
			if !lSolicitante .and. PLSPOSGLO(cIntPad,__aCdCri083[1],__aCdCri083[2]) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri083[1]} ).and.( dDatpro >= BAX->BAX_DATBLO) .and. !empty(BAX->BAX_DATBLO)

				aadd(aCodCri,{__aCdCri083[1],PLSBCTDESC(),"",BCT->BCT_TIPO,BCT->BCT_NIVEL,cCdTbPd,cCodPro})
				aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
				aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})

				PLSCOMPCRI(aCodCri,"BAX")

				// Alimenta o caminho no log do XML.
				if lVldXml
					eval(__bErrXML,aCodCri)
				endIf

				return(eval(__bRetErr,"BAX",cCodRda+cOpeRda+cCodLoc+cCodEsp))

			endIf

			// Fatores que levam a liberacao direto, sem nem checar regras...
			// se libera material e medicamento
			// o procedimento eh material e medicamento
			// o procedimento eh material e medicamento
			if BAX->(FieldPos("BAX_LIMATM")) > 0 .and. BAX->BAX_LIMATM == "1" .and.  !(BR8->BR8_TPPROC $ "0/4/6") .and. !empty(BR8->BR8_TPPROC)

				BAX->(RestArea(aArea))
				return(eval(__bRetAut,"0","BAX",BAX->(BAX_CODIGO+BAX_CODINT+BAX_CODLOC+BAX_CODESP)))    // 0 -> Dispensa autorizacao

			endIf

		endIf

		BAX->(RestArea(aArea))

		if !lSolicitante .and. ! lGlo20 .and. ! lGlo21

			return(eval(__bRetAut,"0","BAQ",cOpeRDA+cCodEsp)) // 0 -> Dispensa autorizacao

		elseIf !lSolicitante .and. !lGlo39 .and. ! lGlo21

			return(eval(__bRetAut,"0","BAQ",cOpeRDA+cCodEsp))

		endIf
		// Niveis a serem verificados e suas ordens de prioridade...
		//
		// 1o. - BAU - Redes de Atendimento se e de alto custo ou nao
		// 2o. - BBI - Produtos que ele pode ou nao atender...
		// 3o. - BBN - Procedimentos nao autorizados...
		// 4o. - BC0 - Procedimentos Autorizados...
		// 5o. - BBM - Especialidade X Procecimentos...

		// 1o. BAU - Redes de Atendimento se e de alto custo ou nao
		if ! lSolicitante .and. lAltCus .and. lGlo103

			if !PLSCHKExi(aCodCri,__aCdCri104[1]+cCodPro)

				aadd(aCodCri,{__aCdCri104[1],cDes103,"",BCT->BCT_TIPO,BCT->BCT_NIVEL,cCdTbPd,cCodPro})
				aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
				aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})
				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"BAU")

				// Alimenta o caminho no log do XML.
				if lVldXml
					eval(__bErrXML,aCodCri)
				endIf

			endIf

			BAX->(RestArea(aArea))
			return(eval(__bRetErr,"BAU",cCodRda+cOpeRda+cCodLoc+cCodEsp+cCodPla+cVersao))

		endIf

	endIf

	// 2o. BBI - Produtos que ele pode ou nao atender...
	if (! lSolicitante .or. getNewPar("MV_CRPLSOL",.f.)) .and. PLSPOSGLO(cIntPad,__aCdCri062[1],__aCdCri062[2],cLocalExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri062[1]} )

		if ! empty(cCodGru)

			if BBI->(BBI_FILIAL+BBI_CODIGO+BBI_CODINT+BBI_CODLOC+BBI_CODESP+BBI_CODGRU) <> xFilial("BBI")+cCodRda+cOpeRda+cCodLoc+cCodEsp+cCodGru

				BBI->(dbSetOrder(2))
				lCond := BBI->(msSeek(xFilial("BBI")+cCodRda+cOpeRda+cCodLoc+cCodEsp+cCodGru))

			else
				lCond := .t.
			endIf

		endIf

		if ! lCond

			if BBI->(BBI_FILIAL+BBI_CODIGO+BBI_CODINT+BBI_CODLOC+BBI_CODESP+BBI_CODPRO+BBI_VERSAO) <> xFilial("BBI")+cCodRda+cOpeRda+cCodLoc+cCodEsp+cCodPla+cVersao

				BBI->(dbSetOrder(1))
				lCond := BBI->(msSeek(xFilial("BBI")+cCodRda+cOpeRda+cCodLoc+cCodEsp+cCodPla+cVersao))

			else
				lCond := .t.
			endIf

		endIf

		//quando for xml tiss checa em todos os locais
		if len(aLocais) > 0 .and. ((!lCond) .or. (lCond .and. BBI->BBI_ATIVO == "0"))//quando eh importacao xml eu tenho que checar todos os locais

			nrecnoBBI 	:= BBI->(recno())

			for nI := 1 to len(aLocais)

				cCodLoc := aLocais[nI,1]

				if BBI->( msSeek( xFilial("BBI") + cCodRda + cOpeRda + cCodLoc + cCodEsp + cCodPla + cVersao) )

					if BBI->BBI_ATIVO <> "0"
						lCond := .t.
						exit
					endIf

				endIf

			next

			if !lCond
				BBI->(dbGoto(nrecnoBBI))
			endIf

		endIf


		if lCond .and. BBI->BBI_ATIVO <> "0" .and. PLSINTval("BBI","BBI_VIGDE","BBI_VIGATE",dDatPro) .and. !lTiss

			//Verifico no nivel de Loc. de Atend. X Espec. X Produto X Proced.
			cSQL := "SELECT R_E_C_N_O_ REC FROM " + cNameBE9 + " WHERE "
			cSQL += "BE9_FILIAL = '" + xFilial("BE9") + "' AND "
			cSQL += "BE9_CODIGO = '" + cCodRDA + "' AND "
			cSQL += "BE9_CODINT = '" + cOpeRda + "' AND "
			cSQL += "BE9_CODLOC = '" + subStr(cCodLoc,1,3) + "' AND "
			cSQL += "BE9_CODESP = '" + cCodEsp  + "' AND "
			cSQL += "BE9_CODPLA = '" + cCodPla + "' AND "
			cSQL += "BE9_CODPAD = '" + cCdTbPd + "' AND "
			cSQL += "BE9_CODTAB <> '' AND "

			cSQL += PLREQNI("BE9", "BE9_CODPRO", __aNiveis[2], cCodPro)

			cSQL += "( '" + dtos(dDatPro) + "' >= BE9_VIGDE  OR BE9_VIGDE  = '' ) AND "
			cSQL += "( '" + dtos(dDatPro) + "' <= BE9_VIGATE OR BE9_VIGATE = '' ) AND "

			cSQL +=  cNameBE9 + ".D_E_L_E_T_ = ' ' "

			cSQL +=  " ORDER BY BE9_NIVEL DESC "

			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPDIR",.f.,.t.)

			if ! PLSAUTPDIR->(eof())

				lFoundBE9 := .t.
				BE9->(dbGoto(PLSAUTPDIR->(REC)))

			else

				BE9->( dbSetOrder(1) )//BE9_FILIAL+BE9_CODIGO+BE9_CODINT+BE9_CODLOC+BE9_CODESP+BE9_CODPLA+BE9_CODPAD+BE9_CODPRO

				cChave   	:= xFilial("BE9")+cCodRda+cOpeRda+Subs(cCodLoc,1,3)+cCodEsp+cCodPla+cCdTbPd+cCodPro
				cwhile	 	:= "BE9->(BE9_FILIAL+BE9_CODIGO+BE9_CODINT+BE9_CODLOC+BE9_CODESP+BE9_CODPLA+BE9_CODPAD+BE9_CODPRO)"
				lFoundBE9 	:= BE9->( msSeek( cChave ) )

				if ! lFoundBE9 .and. ! empty(cCodGru)

					BE9->( dbSetOrder(11) )//BE9_FILIAL+BE9_CODINT+BE9_CODIGO+BE9_CODLOC+BE9_CODESP+BE9_CODGRU+BE9_CODPLA+BE9_CODTAB+BE9_CODPAD+BE9_CODPRO

					cChave		:= xFilial("BE9") + cOpeRda + cCodRda + subStr(cCodLoc,1,3) + cCodEsp + cCodGru
					cwhile	 	:= "BE9->(BE9_FILIAL+BE9_CODINT+BE9_CODIGO+BE9_CODLOC+BE9_CODESP+BE9_CODGRU)"
					lFoundBE9	:= BE9->( msSeek( cChave ) )

				endIf

				if lFoundBE9

					while &(cWhile) == cChave .and. ! BE9->( eof() )

						if (BE9->BE9_VIGDE <= dDatPro .and. BE9->BE9_VIGATE >= dDatPro) .or. BE9->BE9_VIGATE == ctod(Space(nTamBE9_VIGATE))
							exit
						endIf

						BE9->(dbSkip())
					endDo

				endIf

			endIf

			PLSAUTPDIR->(dbCloseArea())

			if lFoundBE9 .and. BE9->BE9_ATIVO <> "0"  .and. PLSINTval("BE9","BE9_VIGDE","BE9_VIGATE",dDatPro)

				if PLSPOSGLO(cIntPad,__aCdCri126[1],__aCdCri126[2],cLocalExec) .and. BEA->BEA_TIPADM == "6" .and. BE9->BE9_URGEN == "1".and. BE9->BE9_ELET == "0"

					aadd(aCodCri,{__aCdCri126[1],PLSBCTDESC(),"",BCT->BCT_TIPO,BCT->BCT_NIVEL,cCdTbPd,cCodPro}) //552###"Tipo de Admissão Inválida"
					aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
					aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})

					// alias e caminho da critica.
					PLSCOMPCRI(aCodCri,"BE9")

					// Alimenta o caminho no log do XML.
					if  lVldXml
						eval(__bErrXML,aCodCri)
					endIf

					return(eval(__bRetErr,"BE9",cChave))

				endIf

				if PLSPOSGLO(cIntPad,__aCdCri126[1],__aCdCri126[2],cLocalExec) .and. BEA->BEA_TIPADM == "5" .and. BE9->BE9_ELET == "1".and. BE9->BE9_URGEN == "0"

					aadd(aCodCri,{__aCdCri126[1],PLSBCTDESC(),"",BCT->BCT_TIPO,BCT->BCT_NIVEL,cCdTbPd,cCodPro}) //552###"Tipo de Admissão Inválida"
					aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
					aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})

					// alias e caminho da critica.
					PLSCOMPCRI(aCodCri,"BE9")

					// Alimenta o caminho no log do XML.
					if  lVldXml
						eval(__bErrXML,aCodCri)
					endIf

					return(eval(__bRetErr,"BE9",cChave))

				endIf

				if PLSPOSGLO(cIntPad,__aCdCri127[1],__aCdCri127[2],cLocalExec) .and. len(aDadUsr)>=41 .and. empty(allTrim(aDadUsr[41])) .and. BE9->BE9_PF == "0"

					aadd(aCodCri,{__aCdCri127[1],PLSBCTDESC(),"",BCT->BCT_TIPO,BCT->BCT_NIVEL,cCdTbPd,cCodPro}) //"553"###"Tipo de Contrato Inválido"
					aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
					aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})

					// alias e caminho da critica.
					PLSCOMPCRI(aCodCri,"BE9")

					// Alimenta o caminho no log do XML.
					if lVldXml
						eval(__bErrXML,aCodCri)
					endIf

					return(eval(__bRetErr,"BE9",cChave))

				endIf

				if PLSPOSGLO(cIntPad,__aCdCri127[1],__aCdCri127[2],cLocalExec) .and. len(aDadUsr)>=41 .and. !empty(allTrim(aDadUsr[41])) .and. BE9->BE9_PJ == "0"

					aadd(aCodCri,{__aCdCri127[1],PLSBCTDESC(),"",BCT->BCT_TIPO,BCT->BCT_NIVEL,cCdTbPd,cCodPro}) //"553"###"Tipo de Contrato Inválido"
					aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
					aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})

					// alias e caminho da critica.
					PLSCOMPCRI(aCodCri,"BE9")

					// Alimenta o caminho no log do XML.
					if lVldXml
						eval(__bErrXML,aCodCri)
					endIf

					return(eval(__bRetErr,"BE9",cChave))

				endIf

				if PLSPOSGLO(cIntPad,__aCdCri128[1],__aCdCri128[2],cLocalExec) .and. BE9->BE9_ATEINT == "0" .and. BE9->BE9_ATEEXT == "1"

					aadd(aCodCri,{__aCdCri128[1],PLSBCTDESC(),"",BCT->BCT_TIPO,BCT->BCT_NIVEL,cCdTbPd,cCodPro}) //"554"###"Tipo de Atendimento Inválido"
					aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
					aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})

					// alias e caminho da critica.
					PLSCOMPCRI(aCodCri,"BE9")

					// Alimenta o caminho no log do XML.
					if lVldXml
						eval(__bErrXML,aCodCri)
					endIf

					return(eval(__bRetErr,"BE9",cChave))

				endIf

			elseIf BE9->BE9_ATIVO == "0" .or. (BE9->BE9_ATIVO <> "0" .and. !PLSINTval("BE9","BE9_VIGDE","BE9_VIGATE",dDatPro))//Ativo fora da vigencia

				if PLSPOSGLO(cIntPad,__aCdCri044[1],__aCdCri044[2],cLocalExec)

					if 	!PLSCHKExi(aCodCri,__aCdCri044[1]+cCodPro)         //não monta se já existir a critica

						aadd(aCodCri,{__aCdCri044[1],PLSBCTDESC(),"",BCT->BCT_TIPO,BCT->BCT_NIVEL,cCdTbPd,cCodPro})
						aadd(aCodCri,{"","Procedimento",cCdTbPd+"-"+cCodPro,"","",cCdTbPd,cCodPro})
						aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
						aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})

						// alias e caminho da critica.
						PLSCOMPCRI(aCodCri,"BE9")

						// Alimenta o caminho no log do XML.
						if lVldXml
							eval(__bErrXML,aCodCri)
						endIf

					endIf
					BAX->(RestArea(aArea))

					return(eval(__bRetErr,"BE9",cCodRda+cOpeRda+cCodLoc+cCodEsp+cCodPla+cVersao))

				endIf

			endIf

		elseIf lCond .and. BBI->BBI_ATIVO == "0" .or. (lCond .and. BBI->BBI_ATIVO <> "0" .and. !PLSINTval("BBI","BBI_VIGDE","BBI_VIGATE",dDatPro))//Ativo fora da vigencia

			if PLSPOSGLO(cIntPad,__aCdCri062[1],__aCdCri062[2],cLocalExec)

				if !lTiss

					if !PLSCHKExi(aCodCri,__aCdCri062[1]+cCodPro)

						aadd(aCodCri,{__aCdCri062[1],PLSBCTDESC(),"",BCT->BCT_TIPO,BCT->BCT_NIVEL,cCdTbPd,cCodPro})
						aadd(aCodCri,{""   ,STR0017,cCodPla+cVersao,"","",cCdTbPd,cCodPro}) //"Produto do Usuario"
						aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
						aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})

						// alias e caminho da critica.
						PLSCOMPCRI(aCodCri,"BBI")

						// Alimenta o caminho no log do XML.
						if lVldXml
							eval(__bErrXML,aCodCri)
						endIf

						BAX->(RestArea(aArea))

					endIf

					return(eval(__bRetErr,"BBI",cCodRda+cOpeRda+cCodLoc+cCodEsp+cCodPla+cVersao))

				else
					return(.f.)
				endIf
			endIf

		endIf

	endIf
	// Este for trata a regra de quem eu vou checar primeiro, ou seja, se sao
	// os procedimentos autorizados ou os nao autorizados
	while nInd <= 2

		if (nInd == 1 .and. cOrdPes == "1") .or. (nInd == 2 .and. cOrdPes == "2")

			// 3o. BBN - Procedimentos nao autorizados...
			BBN->(dbSetOrder(1))//BBN_FILIAL+BBN_CODIGO+BBN_CODINT+BBN_CODLOC+BBN_CODESP+BBN_CODPAD+BBN_CODPSA+BBN_NIVEL
			if BBN->( msSeek(cFilBBN + cCodRDA + cOpeRDA + cCodLoc + cCodEsp) )

				if ! lSolicitante .or. getNewPar("MV_PLEXSL", .f.)

					// 1 Grupo, 2 Sub-Grupo e 3 Item...
					cSQL := "SELECT BBN_FILIAL FROM "+cNameBBN+" WHERE "
					cSQL += "BBN_FILIAL = '"+cFilBBN+"' AND "
					cSQL += "BBN_CODIGO = '"+cCodRDA+"' AND "
					cSQL += "BBN_CODINT = '"+cOpeRDA+"' AND "
					cSQL += "BBN_CODLOC = '"+cCodLoc+"' AND "
					cSQL += "BBN_CODESP = '"+cCodEsp+"' AND "
					cSQL += "BBN_CODPAD = '"+cCdTbPd+"' AND "

					cSQL += PLREQNI("BBN", "BBN_CODPSA", __aNiveis[2], cCodPro)

					cSQL +=  cNameBBN+".D_E_L_E_T_ = ' ' "

					cSQL +=  " ORDER BY BBN_NIVEL DESC "

					dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPMDD",.f.,.t.)

					if ! PLSAUTPMDD->(eof())

						// Procedimento autorizado...
						PLSPOSGLO(cIntPad,__aCdCri044[1],__aCdCri044[2],cLocalExec)

						if !PLSCHKExi(aCodCri,__aCdCri044[1]+cCodPro)

							aadd(aCodCri,{__aCdCri044[1],PLSBCTDESC(),"",BCT->BCT_TIPO,BCT->BCT_NIVEL,cCdTbPd,cCodPro})
							aadd(aCodCri,{"","Procedimento",cCdTbPd+"-"+cCodPro,"","",cCdTbPd,cCodPro})
							aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
							aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})

							// alias e caminho da critica.

							PLSCOMPCRI(aCodCri,"BBN")

							// Alimenta o caminho no log do XML.
							if lVldXml
								eval(__bErrXML,aCodCri)
							endIf

						else
							aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
							aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})
						endIf

						PLSAUTPMDD->(DbCloseArea())

						if lTiss
							return .f.
						else
							return(eval(__bRetErr,"BBN",cCodRDA+cOpeRDA+cCodLoc+cCodEsp+cCdTbPd+cCodPro))
						endIf

					endIf

					PLSAUTPMDD->(DbCloseArea())

				endIf

			endIf

		endIf

		if (nInd == 2 .and. cOrdPes == "1")  .or. (nInd == 1 .and. cOrdPes == "2")

			// 4o. BC0 - Procedimentos Autorizados...
			// 1 Grupo, 2 Sub-Grupo e 3 Item...
			BC0->(dbSetOrder(1))

			// Quando eh solicitante eu tenho que olhar os BC0 dele independentemente
			// do local ou a especialidade
			if lPLSESP01
				lContinua :=  execBlock("PLSESP01" ,.f.,.f.,{cCdTbPd,cCodPro,aDadRDA,aDadUsr,cCodEsp,cCodLoc,dDatpro})
			endIf

			if  !lSolicitante
				cChave    := cCodLoc+cCodEsp
				lFoundBC0 := BC0->(msSeek(cFilBC0+cCodRDA+cOpeRDA+cChave))
			else

				cChave    := cCodLoc
				lFoundBC0 := BC0->(msSeek(cFilBC0+cCodRDA+cOpeRDA+cChave))

				if !lFoundBC0 .and. len(aLocais) >= 1

					for nI := 1 to len(aLocais)

						cChave 	  := aLocais[nI][1]
						lFoundBC0 := BC0->(msSeek(cFilBC0+cCodRDA+cOpeRDA+cChave))

						if lFoundBC0
							exit
						endIf

					next

				endIf

			endIf

			if lFoundBC0

				cSQL := "SELECT BC0_TIPO FROM "+cNameBC0+" WHERE "
				cSQL += "BC0_FILIAL = '"+cFilBC0+"' AND "
				cSQL += "BC0_CODIGO = '"+cCodRDA+"' AND "
				cSQL += "BC0_CODINT = '"+cOpeRDA+"' AND "

				// se o solicitante tem mais de um local eu tenho que pesquisar em todos
				if len(aLocais) >= 1 .and. lSolicitante

					for nI := 1 to len(aLocais)

						if nI == 1
							cSQL += "("
						endIf
						cSQL += "BC0_CODLOC = '"+aLocais[nI][1]+"'  "
						if nI <> len(aLocais)
							cSQL += " OR "
						else
							cSQL += ") AND "
						endIf
					next

				else
					cSQL += "BC0_CODLOC = '"+cCodLoc+"' AND "
				endIf

				cSQL += "BC0_CODESP = '"+cCodEsp+"' AND "
				cSQL += "BC0_CODPAD = '"+cCdTbPd+"' AND "

				cSQL += PLREQNI("BC0", "BC0_CODOPC", __aNiveis[2], cCodPro)

				// Tratamento do novo campo vigencia criado, no futuro o else fieldpos tem q ser apagado.
				if lBC0_VIGDE .and. lBC0_VIGATE
					cSQL += "( '"+dtos(dDatPro)+"' >= BC0_VIGDE  OR BC0_VIGDE = ' ' ) AND "
					cSQL += "( '"+dtos(dDatPro)+"' <= BC0_VIGATE OR BC0_VIGATE = ' ' ) AND "
				endIf

				if lBC0_DATBLO
					cSQL += "(BC0_DATBLO = ' '  OR BC0_DATBLO > '"+dtos(dDatPro)+"' ) AND "
				endIf

				cSQL += cNameBC0+".D_E_L_E_T_ = ' ' "

				cSQL +=  " ORDER BY BC0_NIVEL DESC "

				dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPMDD",.f.,.t.)

				lAutorizou := .f.

				if ! PLSAUTPMDD->(eof())

					//Quando o aLocais esta preenchido com mais de um local eu tenho que varrer todos os locais se em pelo menos um local o prestador
					//puder executar eu libero a execução, esta regra é equivalente a do executante.. se em pelo menos um local ele pode fazer.. eu libero..
					while ! PLSAUTPMDD->(eof())

						if PLSAUTPMDD->BC0_TIPO == "3" .or. PLSAUTPMDD->BC0_TIPO == cTipo
							lAutorizou := .t.
							exit
						endIf

						PLSAUTPMDD->(dbSkip())
					endDo

					// Procedimento autorizado...
					if lAutorizou

						PLSAUTPMDD->(DbCloseArea())
						BAX->(RestArea(aArea))

						if ltiss
							return .t.
						else
							return(eval(__bRetAut,"0","BC0",cCodRDA+cOpeRda+cCodLoc+cCodEsp+cCdTbPd+cCodPro))
						endIf

					else

						PLSAUTPMDD->(DbCloseArea())

						BAX->(RestArea(aArea))

						eval(bAddCriPad,"BC0")

						aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
						aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})

						if lTiss
							return .f.
						else
							return(eval(__bRetErr,"BC0",cCodRDA+cOpeRda+cCodLoc+cCodEsp+cCdTbPd+cCodPro))
						endIf

					endIf

				endIf
				PLSAUTPMDD->(DbCloseArea())

			endIf

		endIf

		nInd++

	endDo
	// 4.1o. B3Z - Excecoes Rede Atendimento PTU
	if allTrim(getNewPar("MV_PLRDREF","0")) == "1" .and. allTrim(getNewPar("MV_PLSUNI","0")) == "1"

		B3Z->(dbSetOrder(1))//B3Z_FILIAL+B3Z_CODIGO+B3Z_VERSAO+B3Z_CODRDA
		if B3Z->(msSeek(xFilial("B3Z")+cOpeRDA+cCodPla+cVersao+cCodRDA))

			//Aqui nego diretamente
			if B3Z->B3Z_INDEXC == "2"

				cChave := cOpeRDA+cCodPla+cVersao+cCodRDA

				PLSPOSGLO(cIntPad,__aCdCri214[1],__aCdCri214[2],cLocalExec)
				aadd(aCodCri,{__aCdCri214[1],PLSBCTDESC(),"",BCT->BCT_TIPO,BCT->BCT_NIVEL,cCdTbPd,cCodPro})
				aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})

				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"B3Z")

				// Alimenta o caminho no log do XML.
				if lVldXml
					eval(__bErrXML,aCodCri)
				endIf

				return(eval(__bRetErr,"B3Z",cChave))

				//Aqui autorizo diretamente
			elseIf B3Z->B3Z_INDEXC == "1"
				lAutorB3Z := .t.
			endIf

		endIf

		// 4.2o. B0G - Rede Referenciada PTU
		if !lAutorB3Z

			aAreaBI3 := BI3->(GetArea())

			BI3->(dbSetOrder(1))//BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO
			if BI3->(msSeek(xFilial("BI3")+cOpeRDA+cCodPla+cVersao)) .and. !empty(BI3->BI3_REDEDI)

				B0G->(dbSetOrder(1))//B0G_FILIAL+B0G_CODRDA
				if B0G->(msSeek(xFilial("B0G")+cCodRDA))

					while xFilial("B0G")+cCodRDA == B0G->(B0G_FILIAL+B0G_CODRDA) .and. !B0G->(eof())

						if allTrim(BI3->BI3_REDEDI) == allTrim(B0G->B0G_ABRRED)+allTrim(B0G->B0G_CODREF)
							lAutorB0G := .t.
							Exit
						endIf
						B0G->(dbSkip())
					endDo

				endIf

			else
				//Se nao foi informado a Rede Referenciada no Produto nao valido
				lAutorB0G := .t.
			endIf

			RestArea(aAreaBI3)

			if !lAutorB0G
				cChave := cOpeRDA+cCodPla+cVersao

				PLSPOSGLO(cIntPad,__aCdCri216[1],__aCdCri216[2],cLocalExec)
				aadd(aCodCri,{__aCdCri216[1],PLSBCTDESC(),"",BCT->BCT_TIPO,BCT->BCT_NIVEL,cCdTbPd,cCodPro})
				aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})

				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"B0G")

				// Alimenta o caminho no log do XML.
				if lVldXml
					eval(__bErrXML,aCodCri)
				endIf

				return(eval(__bRetErr,"B0G",cChave))
			endIf
		endIf
	endIf
	// 5o. BFP - Sub-Especialidade X Procedimento...
	if !lTiss

		if BAX->(BAX_FILIAL+BAX_CODIGO+BAX_CODINT+BAX_CODLOC+BAX_CODESP) <> xFilial("BAX")+cCodRda+cOpeRda+cCodLoc+cCodEsp
			BAX->(dbSetOrder(1))
			lTratarEsp := BAX->(msSeek(xFilial("BAX")+cCodRda+cOpeRda+cCodLoc+cCodEsp)) .and. BAX->BAX_CONESP <> "0"
		endIf

		if !lTratarEsp .and. len(aLocais) >= 1 .and. lSolicitante //quando eh solicitante eu tenho que verificar em todos os locais dele

			for nI := 1 to len(aLocais)

				cLocTmp		:= aLocais[nI][1]
				lTratarEsp 	:= BAX->(msSeek(xFilial("BAX")+cCodRda+cOpeRda+cLocTmp+cCodEsp)) .and. BAX->BAX_CONESP <> "0"

				if lTratarEsp
					exit
				endIf

			next

		endIf

		lTrtSubEsp := !empty(BAX->BAX_CODSUB) // Trata subs Especialidade

		if lTrtSubEsp .and. lGlo181 .and. !(cCodEsp $ getNewPar("MV_PLSESPL","000"))

			BFP->(dbSetOrder(1))
			if BFP->(msSeek(xFilial("BFP")+cOpeRda+cCodEsp+BAX->BAX_CODSUB))

				// 1 Grupo, 2 Sub-Grupo e 3 Item...
				cSQL := "SELECT BFP_TIPO, BFP_ATIVO FROM "+ RetSqlName("BFP")+" WHERE "
				cSQL += "BFP_FILIAL = '"+xFilial("BFP")+"' AND "
				cSQL += "BFP_CODINT = '"+cOpeRDA+"' AND "
				cSQL += "BFP_CODESP = '"+cCodEsp+"' AND "
				cSQL += "BFP_CODSUB = '"+BAX->BAX_CODSUB+"' AND "
				cSQL += "BFP_CODPAD = '"+cCdTbPd+"' AND "

				if lBFP_DATVAL
					cSQL += "( '"+dtos(dDatPro)+"' <= BFP_DATVAL OR BFP_DATVAL = '"+Space(10)+"' )   AND "
				endIf

				cSQL += PLREQNI("BFP", "BFP_CODPSA", __aNiveis[2], cCodPro)

				cSQL +=  " D_E_L_E_T_ = ' ' "

				cSQL +=  " ORDER BY BFP_NIVEL DESC "

				dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPMDD",.f.,.t.)

				if ! PLSAUTPMDD->(eof())

					// Procedimento autorizado...
					if PLSAUTPMDD->BFP_ATIVO == "1"

						if PLSAUTPMDD->BFP_TIPO == "3" .or. PLSAUTPMDD->BFP_TIPO == cTipo

							cVarAux := PLSAUTPMDD->BFP_TIPO

							PLSAUTPMDD->(DbCloseArea())

							BAX->(RestArea(aArea))

							return(eval(__bRetAut,"0","BFP",(cOpeRda+cCodEsp+cCdTbPd+cCodPro)))

						else

							PLSAUTPMDD->(DbCloseArea())

							BAX->(RestArea(aArea))

							if (!lGlo181 .and. !lSolicitante) .or. (!lGlo39 .and. lSolicitante)

								return(eval(__bRetAut,"0","BFP",(cOpeRda+cCodEsp+cCdTbPd+cCodPro)))

							else

								eval(bAddCriPad,"BFP")

								aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
								aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})

								return(eval(__bRetErr,"BFP",(cOpeRda+cCodEsp+cCdTbPd+cCodPro)))

							endIf

						endIf

					else

						if (!lSolicitante) .and. !PLSCHKExi(aCodCri,__aCdCri181[1]+cCodPro)

							aadd(aCodCri,{__aCdCri181[1],cDes181,"",BCT->BCT_TIPO,BCT->BCT_NIVEL,cCdTbPd,cCodPro})
							aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
							aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})

							// alias e caminho da critica.
							PLSCOMPCRI(aCodCri,"BFP")

							// Alimenta o caminho no log do XML.
							if lVldXml
								eval(__bErrXML,aCodCri)
							endIf

						elseIf (!lSolicitante) .and. !PLSCHKExi(aCodCri,__aCdCri039[1]+cCodPro) .and. !PLSCHKExi(aCodCri,__aCdCri021[1]+cCodPro)

							aadd(aCodCri,{__aCdCri039[1],cDes39,"",BCT->BCT_TIPO,BCT->BCT_NIVEL,cCdTbPd,cCodPro})
							aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
							aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})

							// alias e caminho da critica.
							PLSCOMPCRI(aCodCri,"BFP")

							// Alimenta o caminho no log do XML.
							if lVldXml
								eval(__bErrXML,aCodCri)
							endIf

						endIf

						PLSAUTPMDD->(DbCloseArea())

						return(eval(__bRetErr,"BFP",(cOpeRda+cCodEsp+cCdTbPd+cCodPro)))

					endIf

				endIf
				PLSAUTPMDD->(DbCloseArea())

			endIf

		endIf
	endIf

	// 6o. BBM - Especialidade X Procedimento...
	if BAX->(BAX_FILIAL+BAX_CODIGO+BAX_CODINT+BAX_CODLOC+BAX_CODESP) <> xFilial("BAX")+cCodRda+cOpeRda+cCodLoc+cCodEsp

		BAX->(dbSetOrder(1))
		lTratarEsp := BAX->(msSeek(xFilial("BAX")+cCodRda+cOpeRda+cCodLoc+cCodEsp)) .and. BAX->BAX_CONESP <> "0"

	endIf

	if !lTratarEsp .and. len(aLocais) >= 1 .and. lSolicitante //quando eh solicitante eu tenho que verificar em todos os locais dele

		for nI := 1 to len(aLocais)

			cLocTmp := aLocais[nI][1]

			lTratarEsp := BAX->(msSeek(xFilial("BAX")+cCodRda+cOpeRda+cLocTmp+cCodEsp)) .and. BAX->BAX_CONESP <> "0"

			if lTratarEsp
				exit
			endIf

		next

	endIf

	BAX->(RestArea(aArea))

	// Verificacao pela BQ1, a Vale solicitou que a verificacao do Profissional Solicitante fosse realizada pelas
	// especialidades do profissional na BQ1
	if lGlo21 .and. lSolicitante .and. GetNewPar("MV_PLBQ1AU","0") == "1" .and. FunName() <> "RPC"

		aRetBQ1 := PLSolicBQ1(cCodRda,cOpeRDA,cCdTbPd,cCodPro,cCodPRFSol,dDatPro,cTipo,cLocalExec,cEspSol)

		// Achou parametrizacao
		if aRetBQ1[1]
			if lTiss
				return .T.
			else
				return(eval(__bRetAut,"0","BBM",(cOpeRda+cCodEsp+cCdTbPd+cCodPro)))
			endIf

			//012 - Solicitante nao autorizado a solicitar este procedimento (Campo Executa/Solicita/Ambos)
		elseIf !aRetBQ1[1]

			BB8->( DbSetOrder(1) ) //BB8_FILIAL + BB8_CODIGO + BB8_CODINT + BB8_CODLOC + BB8_LOCAL
			if !empty(cCodLoc) .and. BB8->( MsSeek(xFilial("BB8")+cCodRda+cOpeRda+cCodLoc) )
				cDesLoc := BB8->BB8_DESLOC
			endIf

			BB0->(DbSetOrder(1))//BB0_FILIAL+BB0_CODIGO
			if !empty(cCodPRFSol) .and. BB0->(MsSeek(xFilial("BB0")+cCodPRFSol))
				cDesProSol := Alltrim(BB0->BB0_NOME)
			endIf

			if !PLSCHKExi(aCodCri,__aCdCri039[1]+cCodPro)
				eval(bAddCriPad,"BBM")
				aadd(aCodCri,{"","Profissional Solicitante",cCodPRFSol+" - "+cDesProSol,"","",cCdTbPd,cCodPro})
				aadd(aCodCri,{"","Local de Atendimento",cCodLoc+" - "+cDesLoc,"","",cCdTbPd,cCodPro})
				aadd(aCodCri,{"","Especialidade",aRetBQ1[2]+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+aRetBQ1[2],"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})
			endIf

			if lTiss
				return .F.
			else
				return(Eval(__bRetErr,"BBM",(cOpeRda+aRetBQ1[2]+cCdTbPd+cCodPro)))
			endIf

		endIf

	elseIf lTratarEsp .and. lGlo21 .and. !(cCodEsp $ getNewPar("MV_PLSESPL","000"))

		BBM->(dbSetOrder(1)) //BBM_FILIAL+BBM_CODINT+BBM_CODESP+BBM_CODPAD+BBM_CODPSA+BBM_NIVEL+BBM_TIPO+BBM_ATIVO
		if BBM->(msSeek(cFilBBM + cOpeRda + cCodEsp ) )

			// 1 Grupo, 2 Sub-Grupo e 3 Item...
			cSQL := "SELECT BBM_TIPO, BBM_ATIVO FROM "+cNameBBM+" WHERE "
			cSQL += "BBM_FILIAL = '"+cFilBBM+"' AND "
			cSQL += "BBM_CODINT = '"+cOpeRDA+"' AND "
			cSQL += "BBM_CODESP = '"+cCodEsp+"' AND "
			cSQL += "BBM_CODPAD = '"+cCdTbPd+"' AND "

			if lBBM_DATVAL
				cSQL += "( '"+dtos(dDatPro)+"' <= BBM_DATVAL OR BBM_DATVAL = '"+Space(10)+"' )   AND "
			endIf

			cSQL += PLREQNI("BBM", "BBM_CODPSA", __aNiveis[2], cCodPro)
			cSQL += cNameBBM + ".D_E_L_E_T_ = ' ' "

			cSQL +=  " ORDER BY BBM_NIVEL DESC "

			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPMDD",.f.,.t.)

			if ! PLSAUTPMDD->(eof())

				// Procedimento autorizado...
				if PLSAUTPMDD->BBM_ATIVO == "1"

					lPrcOutEsp := .t.

					if PLSAUTPMDD->BBM_TIPO == "3" .or. PLSAUTPMDD->BBM_TIPO == cTipo

						cVarAux := PLSAUTPMDD->BBM_TIPO

						PLSAUTPMDD->(DbCloseArea())

						if lTiss
							return .t.
						else
							return(eval(__bRetAut,"0","BBM",(cOpeRda+cCodEsp+cCdTbPd+cCodPro)))
						endIf

					else

						PLSAUTPMDD->(DbCloseArea())

						if ( ! lGlo20 .and. ! lSolicitante ) .or. ( !lGlo39 .and. lSolicitante )

							if lTiss
								return .t.
							else
								return(eval(__bRetAut,"0","BBM",(cOpeRda+cCodEsp+cCdTbPd+cCodPro)))
							endIf

						else

							BB8->( DbSetOrder(1) ) //BB8_FILIAL + BB8_CODIGO + BB8_CODINT + BB8_CODLOC + BB8_LOCAL
							If ! empty(cCodLoc) .and. BB8->( MsSeek(xFilial("BB8")+cCodRda+cOpeRda+cCodLoc) )

								cDesLoc := BB8->BB8_DESLOC
							EndIf

							If !PLSCHKExi(aCodCri,__aCdCri020[1]+cCodPro)

								eval(bAddCriPad,"BBM")

								aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
								aadd(aCodCri,{"","Local de Atendimento",cCodLoc+" - "+cDesLoc,"","",cCdTbPd,cCodPro})
								aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})
							EndIf

							If !lTiss
								Return(Eval(__bRetErr,"BBM",(cOpeRda+cCodEsp+cCdTbPd+cCodPro)))
							else
								return .F.
							EndIf

						endIf

					endIf

				else

					if ! lSolicitante .and. !PLSCHKExi(aCodCri,__aCdCri021[1]+cCodPro)

						aadd(aCodCri,{__aCdCri021[1],cDes21,"",BCT->BCT_TIPO,BCT->BCT_NIVEL,cCdTbPd,cCodPro})
						aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
						aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})

						// alias e caminho da critica.
						PLSCOMPCRI(aCodCri,"BBM")

						// Alimenta o caminho no log do XML.
						if lVldXml
							eval(__bErrXML,aCodCri)
						endIf

					elseIf !PLSCHKExi(aCodCri,__aCdCri039[1]+cCodPro) .and. !PLSCHKExi(aCodCri,__aCdCri021[1]+cCodPro)

						aadd(aCodCri,{__aCdCri039[1],cDes39,"",BCT->BCT_TIPO,BCT->BCT_NIVEL,cCdTbPd,cCodPro})
						aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
						aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})

						// alias e caminho da critica.
						PLSCOMPCRI(aCodCri,"BBM")

						// Alimenta o caminho no log do XML.
						if lVldXml
							eval(__bErrXML,aCodCri)
						endIf

					endIf

					PLSAUTPMDD->(DbCloseArea())

					if lTiss
						return .f.
					else
						return(eval(__bRetErr,"BBM",(cOpeRda+cCodEsp+cCdTbPd+cCodPro)))
					endIf
				endIf
			else
				lAchouEsp := .T.
			endIf
			PLSAUTPMDD->(DbCloseArea())
		else
			lAchouEsp := .T.
		endIf

	endIf

	if !lTiss .and. lAchouEsp
		// Parametro MV_PLSREGE conteudo padrao 1
		//
		// 1 - Somente sera considerado o que estiver negado ou autorizado na
		//     especialidade. Caso tenha um procedimento que nao esteja
		//     parametrizado o sistema vai criticar o direito de execucao da rda
		//
		// 2 - Caso nao tenha parametrizado na especialidade o sistema vai autorizar
		//     E a excessao do caso acima
		//
		// Parametro MV_PLSREGS conteudo padrao 0
		// O parametro MV_PLSREGS tem o mesmo comportamento do parametro MV_PLSREGE, porem,
		// ele faz a verificacao na Solicitacao:
		// Critica 012 - Solicitante nao autorizado a solicitar este procedimento (Campo Executa/Solicita/Ambos)

		if lTratarEsp .AND. !(cCodEsp $ getNewPar("MV_PLSESPL","000")) .And. ;
				((cMVPLSREGE == "1" .And. !lSolicitante) .Or. (cMVPLSREGS == "1" .And. lSolicitante))

			//Este bloco verifica regra de Solicitacao (Liberacao)
			if lSolicitante .And. cMVPLSREGS == "1"

				If !PLSCHKExi(aCodCri,__aCdCri039[1]+cCodPro) .and. !PLSCHKExi(aCodCri,__aCdCri021[1]+cCodPro) .And. ;
						PLSPOSGLO(cIntPad,__aCdCri039[1],__aCdCri039[2],cLocalExec,'1', "")

					aadd(aCodCri,{__aCdCri039[1],cDes39,"",BCT->BCT_TIPO,BCT->BCT_NIVEL,cCdTbPd,cCodPro})
					aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
					aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})

					// alias e caminho da critica.
					PLSCOMPCRI(aCodCri,"BAQ")

					// Alimenta o caminho no log do XML.
					if lVldXml
						eval(__bErrXML,aCodCri)
					endIf
				endIf
			endIf

			//Este bloco verifica regra de Execucao (Autoriza SADT)
			If !lSolicitante .And. cMVPLSREGE == "1"

				if !PLSCHKExi(aCodCri,__aCdCri021[1]+cCodPro)

					if PLSPOSGLO(cIntPad,__aCdCri021[1],__aCdCri021[2],cLocalExec,'1', "")

						aadd(aCodCri,{__aCdCri021[1],cDes21,"",BCT->BCT_TIPO,BCT->BCT_NIVEL,cCdTbPd,cCodPro})
						aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
						aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})

						// alias e caminho da critica.
						PLSCOMPCRI(aCodCri,"BAQ")

						// Alimenta o caminho no log do XML.
						if lVldXml
							eval(__bErrXML,aCodCri)
						endIf

					endIf

				elseIf  !PLSCHKExi(aCodCri,__aCdCri039[1]+cCodPro) .and. !PLSCHKExi(aCodCri,__aCdCri021[1]+cCodPro)

					if PLSPOSGLO(cIntPad,__aCdCri039[1],__aCdCri039[2],cLocalExec,'1', "")

						aadd(aCodCri,{__aCdCri039[1],cDes39,"",BCT->BCT_TIPO,BCT->BCT_NIVEL,cCdTbPd,cCodPro})
						aadd(aCodCri,{"","Rede de Atendimento",cCodRDA+" - "+cNomRda,"","",cCdTbPd,cCodPro})
						aadd(aCodCri,{"","Especialidade",cCodEsp+" - "+Posicione("BAQ",1,xFilial("BAQ")+cOpeRda+cCodEsp,"BAQ_DESCRI"),"","",cCdTbPd,cCodPro})

						// alias e caminho da critica.
						PLSCOMPCRI(aCodCri,"BAQ")

						// Alimenta o caminho no log do XML.
						if lVldXml
							eval(__bErrXML,aCodCri)
						endIf
					endIf

				endIf
			endIf

			if aScan(aCodcri, {|x| x[1] $ __aCdCri039[1]+"|"+__aCdCri021[1]+"|"+__aCdCri020[1]}) > 0
				aRetGeral := eval(__bRetErr,"BAQ",cOpeRDA+cCodEsp)
			else
				aRetGeral := eval(__bRetAut,"0","BAQ",cOpeRDA+cCodEsp)
			endIf

		else
			aRetGeral := eval(__bRetAut,"0","BAQ",cOpeRDA+cCodEsp)
		endIf
	endIf

	// Caso nao autorize retorna o erro de nao autorizado padrao...
	if !lTiss

		if !lLimpCri
			return(aRetGeral)
		else

			if aRetGeral[1]

				aRetGeral := {}
				return(.t.)
			else
				aRetGeral := {}
				return(.f.)
			endIf

		endIf

	else

		return(.t.)

	endIf

	/*/{Protheus.doc} PLSVLDESP
Valida Idade e sexo da especialidade
@type function
@author tuliocesar
@since 20.04.00
@version 1.0
	/*/
	function PLSVLDESP(nIdade,nIdaMin,nIdaMax,cSexoSis,cSexoUsr,cLocalExec,cCdTbPd,;
			cCodPro,cCodEsp,cDesEsp,cAlias,lTratSolic,lTratExe,lInterc,;
			cDente,cFaces,aRetRda)
		local lVldIda   := eval({ || ( ( nIdade >= nIdaMin .and. nIdade <= nIdaMax ) .or. ( nIdaMin == 0 .and. nIdaMax == 0 ) ) })
		local lVldSex   := .f.
		local aRetPad   := {.t.,{}}
		local aCriticas := {}
		local nI 		:= 1
		local _lVldSex  := .f.
		local _lVldIda	:= .f.
		local cIntPad	:= plsIntPad()
		local cEspSobCtes	:= getNewPar("MV_PLSOBCT","009,010") //Parametro que determina as especialidades (BAQ) que deverão sobressair a regra do MV_PLSCTES para validação

		default cAlias  := "BAQ"
		default lInterc := .f.
		default cDente  := ''
		default cFaces  := ''
		default aRetRda := {}

		// Quando e cadastrado um usuario de intercambio eventual atraves do Portal
		// o sexo nao e informado, assim, a verificacao nao sera realizada se for
		// um usuario de intercambio com o sexo em branco
		lVldSex   := (cSexoSis $ "3, ") .or. (cSexoUsr == cSexoSis) .or. (empty(cSexoUsr) .and. lInterc)

		if len(aRetRda) >= 2 .and. (!lVldSex .or. !lVldIda)

			if  cCodEsp $ cEspSobCtes
				_nIdaMin	:= aRetRda[2][1]
				_nIdaMax	:= aRetRda[2][2]
				_cSexoSis	:= aRetRda[2][3]
				_lVldSex	:= (_cSexoSis $ "3, ") .or. (cSexoUsr == _cSexoSis) .or. (empty(cSexoUsr) .and. lInterc) .or. lVldSex
				_lVldIda	:= ( nIdade >= _nIdaMin .and. nIdade <= _nIdaMax ) .or. ( _nIdaMin == 0 .and. _nIdaMax == 0 ) .or. lVldIda

			elseif len(aRetRda) >= 3  .and. (!lVldSex .or. !lVldIda)

				for nI:= 3 to len(aRetRda)
					_nIdaMin	:= aRetRda[nI][1]
					_nIdaMax	:= aRetRda[nI][2]
					_cSexoSis	:= aRetRda[nI][3]
					_lVldSex	:= (_cSexoSis $ "3, ") .or. (cSexoUsr == _cSexoSis) .or. (empty(cSexoUsr) .and. lInterc) .or. lVldSex
					_lVldIda	:= (( nIdade >= _nIdaMin .and. nIdade <= _nIdaMax ) .or. ( _nIdaMin == 0 .and. _nIdaMax == 0 ) .or. lVldIda) .and. !Empty(aRetRda[1])
				next

				lVldIda := lVldIda .and. _lVldIda
				lVldSex := lVldSex .and. _lVldSex

			endIf

		endIf

		if ! lVldIda .and. PLSPOSGLO(cIntPad,__aCdCri022[1],__aCdCri022[2],cLocalExec)
			aadd(aCriticas,{__aCdCri022[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
			aadd(aCriticas,{""   ,STR0018,cCodEsp+" - "+cDesEsp,"","",cCdTbPd,cCodPro}) //"Especialidade"
			aadd(aCriticas,{""   ,STR0006,allTrim(Str(nIdaMin)),"","",cCdTbPd,cCodPro}) //"Idade Minima"
			aadd(aCriticas,{""   ,STR0007,allTrim(Str(nIdaMax)),"","",cCdTbPd,cCodPro}) //"Idade Maxima"
			aadd(aCriticas,{""   ,STR0008,allTrim(Str(nIdade)),"","",cCdTbPd,cCodPro}) //"Idade Usuario"
			if !empty(cDente)
				aadd(aCriticas,{""   ,STR0086, allTrim(cDente), "","",cCdTbPd,cCodPro}) //"Dente"
			endIf
			if !empty(cFaces)
				aadd(aCriticas,{""   ,STR0076, allTrim(cFaces), "","",cCdTbPd,cCodPro}) //"Faces"
			endIf

			// alias e caminho da critica.
			PLSCOMPCRI(aCriticas,cAlias)

		endIf

		if ! lVldSex .and. PLSPOSGLO(cIntPad,__aCdCri023[1],__aCdCri023[2],cLocalExec) .and. (lTratSolic .or. lTratExe)

			aadd(aCriticas,{__aCdCri023[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
			aadd(aCriticas,{""   ,STR0018,cCodEsp+" - "+cDesEsp,"","",cCdTbPd,cCodPro}) //"Especialidade"
			aadd(aCriticas,{""   ,STR0019,X3COMBO(cAlias+"_SEXO",allTrim(cSexoSis)),"","",cCdTbPd,cCodPro}) //"Sexo da Especialidade"
			aadd(aCriticas,{""   ,STR0010,X3COMBO(cAlias+"_SEXO",allTrim(cSexoUsr)),"","",cCdTbPd,cCodPro}) //"Sexo Usuario"

			if !empty(cDente)
				aadd(aCriticas,{""   ,STR0086, allTrim(cDente), "","",cCdTbPd,cCodPro}) //"Dente"
			endIf

			if !empty(cFaces)
				aadd(aCriticas,{""   ,STR0076, allTrim(cFaces), "","",cCdTbPd,cCodPro}) //"Faces"
			endIf

			// alias e caminho da critica.
			PLSCOMPCRI(aCriticas,cAlias)

		endIf

		if len(aCriticas)>0 .and. (! LVldIda .or. ! lVldSex .and. (lTratSolic .or. lTratExe))
			aRetPad := { .f.,aCriticas,cAlias,cCodEsp }
		endIf

	return(aRetPad)

	/*/{Protheus.doc} PLSXANASAD
Trata a situacao adversa
@type function
@author tuliocesar
@since 18.03.03
@version 1.0
	/*/
	function PLSXANASAD(lHelp, dData)
		local aDadUsr  		:= PLSGETUsr()
		local cOpeUsr  		:= aDadUsr[37]
		local cMatrUsr 		:= cOpeUsr+aDadUsr[38]
		local cCodPro  		:= aDadUsr[11]
		local cVerPro  		:= aDadUsr[12]
		local cCodEmp  		:= Subs(cMatrUsr,atCodEmp[1],atCodEmp[2])
		local cMatric  		:= Subs(cMatrUsr,atMatric[1],atMatric[2])
		local cTipReg  		:= Subs(cMatrUsr,atTipReg[1],atTipReg[2])
		local cConEmp  		:= aDadUsr[09]
		local cVerCon  		:= aDadUsr[39]
		local cSubCon  		:= aDadUsr[41]
		local cVerSub  		:= aDadUsr[42]
		local aSituac  		:= {}
		local cNvStAd       := allTrim( getNewPar("MV_PLNVSAD","0") )

		cNvStAd := iIf( empty( cNvStAd ), "0", cNvStAd )

		default dData := dDataBase
		// Busva as situacoes adversas informadas no produto...
		BGX->(dbSetOrder(1))

		BGZ->(dbSetOrder(1))
		if ("1" $ cNvStAd .Or. "0" $ cNvStAd) .And. BGZ->(msSeek(xFilial("BGZ")+cOpeUsr+cCodPro+cVerPro))  // NIVEL 1 Produto
			while ! BGZ->( eof() ) .and. BGZ->(BGZ_FILIAL+BGZ_CODINT+BGZ_CODIGO+BGZ_VERSAO) == xFilial("BGZ")+cOpeUsr+cCodPro+cVerPro

				if BGX->( msSeek(xFilial("BGX")+BGZ->(BGZ_CODINT+BGZ_CODSAD)) ) .and. PLSINTval("BGZ","BGZ_VIGDE","BGZ_VIGATE",dData)

					aadd(aSituac,{BGX->BGX_CODSAD,BGX->BGX_DESCRI})

					if !empty(BGX->BGX_OBS1)
						aadd(aSituac,{"",BGX->BGX_OBS1})
					endIf

					if !empty(BGX->BGX_OBS2)
						aadd(aSituac,{"",BGX->BGX_OBS2})
					endIf

					if !empty(BGX->BGX_OBS3)
						aadd(aSituac,{"",BGX->BGX_OBS3})
					endIf

					if !empty(BGX->BGX_OBS4)
						aadd(aSituac,{"",BGX->BGX_OBS4})
					endIf

					if !empty(BGX->BGX_OBS5)
						aadd(aSituac,{"",BGX->BGX_OBS5})
					endIf

					if !empty(BGX->BGX_OBS6)
						aadd(aSituac,{"",BGX->BGX_OBS6})
					endIf
				endIf

				BGZ->(dbSkip())
			endDo
		endIf
		// controlar se já passou no while devido o campo versão de produto não estar no índice
		lFirst:=.t.
		// Busva as situacoes adversas informadas no subcontrato...
		BHN->(dbSetOrder(1))
		if ("2" $ cNvStAd .Or. "0" $ cNvStAd) .And. BHN->(msSeek(xFilial("BHN")+cOpeUsr+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodPro)) //NIVEL 2 Subcontrato

			while BHN->( !eof() ).and. xFilial("BHN")+cOpeUsr+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodPro == ;
					BHN->(BHN_FILIAL + BHN_CODINT + BHN_CODIGO + BHN_NUMCON + BHN_VERCON + BHN_SUBCON + BHN_VERSUB + BHN_CODPRO)

				if BHN->BHN_VERPRO <> cVerPro
					BHN->(dbSkip())
					Loop
				endIf

				if BGX->(msSeek(xFilial("BGX")+BHN->(BHN_CODINT+BHN_CODSAD))) .and. PLSINTval("BHN","BHN_VIGDE","BHN_VIGATE",dData)

					if lFirst .And. "0" $ cNvStAd
						aSituac:={}
						lFirst := .f.
					endIf

					aadd(aSituac,{BGX->BGX_CODSAD,BGX->BGX_DESCRI})

					if !empty(BGX->BGX_OBS1)
						aadd(aSituac,{"",BGX->BGX_OBS1})
					endIf

					if !empty(BGX->BGX_OBS2)
						aadd(aSituac,{"",BGX->BGX_OBS2})
					endIf

					if !empty(BGX->BGX_OBS3)
						aadd(aSituac,{"",BGX->BGX_OBS3})
					endIf

					if !empty(BGX->BGX_OBS4)
						aadd(aSituac,{"",BGX->BGX_OBS4})
					endIf

					if !empty(BGX->BGX_OBS5)
						aadd(aSituac,{"",BGX->BGX_OBS5})
					endIf

					if !empty(BGX->BGX_OBS6)
						aadd(aSituac,{"",BGX->BGX_OBS6})
					endIf
				endIf

				BHN->(dbSkip())
			endDo

		endIf

		lFirst:=.t.
		// Busva as situacoes adversas do usuario...
		BHH->( dbSetOrder(1) )
		if ("3" $ cNvStAd .Or. "0" $ cNvStAd) .And. BHH->(msSeek(xFilial("BHH")+cOpeUsr+cCodEmp+cMatric+cTipReg))    //NIVEL 3 Beneficiário

			while ! BHH->(eof()) .and. BHH->(BHH_FILIAL + BHH_CODINT + BHH_CODEMP + BHH_MATRIC + BHH_TIPREG) == ;
					xFilial("BHH")+cOpeUsr+cCodEmp+cMatric+cTipReg

				if BGX->(msSeek(xFilial("BGX")+BHH->(BHH_CODINT+BHH_CODSAD))) .and. PLSINTval("BHH","BHH_VIGDE","BHH_VIGATE",dData)

					if lFirst .And. "0" $ cNvStAd
						aSituac := {}
						lFirst  := .f.
					endIf

					aadd(aSituac,{BGX->BGX_CODSAD,BGX->BGX_DESCRI})

					if !empty(BHH->BHH_OBS1)
						aadd(aSituac,{"",BHH->BHH_OBS1})
					endIf

					if !empty(BHH->BHH_OBS2)
						aadd(aSituac,{"",BHH->BHH_OBS2})
					endIf

					if !empty(BHH->BHH_OBS3)
						aadd(aSituac,{"",BHH->BHH_OBS3})
					endIf

					if !empty(BHH->BHH_OBS4)
						aadd(aSituac,{"",BHH->BHH_OBS4})
					endIf

					if !empty(BHH->BHH_OBS5)
						aadd(aSituac,{"",BHH->BHH_OBS5})
					endIf
					if !empty(BHH->BHH_OBS6)
						aadd(aSituac,{"",BHH->BHH_OBS6})
					endIf
					if !empty(BHH->BHH_OBS7)
						aadd(aSituac,{"",BHH->BHH_OBS7})
					endIf

					if !empty(BHH->BHH_OBS8)
						aadd(aSituac,{"",BHH->BHH_OBS8})
					endIf

					if !empty(BHH->BHH_OBS9)
						aadd(aSituac,{"",BHH->BHH_OBS9})
					endIf

					if !empty(BHH->BHH_OBS10)
						aadd(aSituac,{"",BHH->BHH_OBS10})
					endIf

					if !empty(BHH->BHH_OBS11)
						aadd(aSituac,{"",BHH->BHH_OBS11})
					endIf
					if !empty(BHH->BHH_OBS12)
						aadd(aSituac,{"",BHH->BHH_OBS12})
					endIf

				endIf

				BHH->(dbSkip())
			endDo
		endIf
		// Exibe msg caso exista...
		if len(aSituac) > 0 .and. lHelp
			PLSCRIGEN(aSituac,{ {STR0020,"@C",30} , {STR0021,"@C",50 } },STR0022) //"Codigo"###"Descricao"###"Situacoes Adversas"
		endIf

	return(aSituac)

	/*/{Protheus.doc} PLSTratQtd
Verifica se o usuario tem permissao para efetuar Qtd Sol.
@type function
@author tuliocesar
@since 12.06.03
@param cMatrUsr, caracter, Matricula do Usuario
@param dData   , data    , Data para verificacao da quantidade
@param cHora   , caracter, Hora para verificacao
@param cCdTbPd , caracter, Tabela Padrao Saude
@param cCodPro , caracter, Codigo Procedimento
@param nQtdSoli, numerico, Quantidade sendo solicitada p/verificacao
@param nNivel  , numerico, Nivel que esta sendo analisado
@param lIntPort, Logico  , Internação do Portal
@version 1.0
	/*/
	function PLSTratQtd(cMatrUsr,dData,cHora,cCdTbPd,cCodPro,nQtdSoli,; //6
			nQtdPer,cUniPer,cLocalExec,nRegBD6,cNivel,aQtd,aPerio,; //13
			aDadRDA,cCid,aDadUsr,cAlias,cRdaEDI,cFaces,cDente,aFaces,; //21
			aRet,aQtdBrow,cChavGui, nPerdQtd, cPerdUni, cConsPer,cSequen,; //28
			nQtd,cEspExe,lLibPor,cEspSol,lGuiLib,lIntPort,cNumeroGuia,lMudFase) //36
		local aArea			:= getArea()
		local cSQL			:= ""
		local cCampos 		:= ""
		local cCodNiv		:= ""
		local nAux1     	:= 0
		local nAux2     	:= 0
		local nGravi    	:= 1
		local i         	:= 1
		local nNiveis   	:= 0

		local aDias     	:= {STR0023,STR0024,STR0025,STR0026,STR0027,STR0028,STR0029} //"Domingo"###"Segunda"###"Terca"###"Quarta"###"Quinta"###"Sexta"###"Sabado"
		local dDataSe
		local cOpeUsr   	:= Subs(cMatrUsr,atCodOpe[1],atCodOpe[2])
		local cCodEmp   	:= Subs(cMatrUsr,atCodEmp[1],atCodEmp[2])
		local cMatric   	:= Subs(cMatrUsr,atMatric[1],atMatric[2])
		local cTipReg   	:= Subs(cMatrUsr,atTipReg[1],atTipReg[2])
		local cDigito   	:= Subs(cMatrUsr,atDigito[1],atDigito[2])
		local cCodEsp		:= ""
		local cCodRda		:= ""
		local cIntPad		:= plsIntPad()
		local aRetAux		:= {}
		local nQtdEve   	:= 0
		local nOrdBD6		:= 0
		local nRecBD6		:= 0
		local dDatInc   	:= ctod("")
		local dDatAnaIni	:= ctod("")
		local cTipPre   	:= ""
		local nI			:= 0
		local nX			:= 0
		local nK			:= 0
		local cFilGui   	:= ""
		local cCodOpe   	:= ""
		local cCodLDP   	:= ""
		local cCodPeg   	:= ""
		local cNumero   	:= ""
		local cOrimov   	:= ""
		local nSlvSol   	:= nQtdSoli
		local nSlvQtEv  	:= 0
		local cTipCon		:= ""
		local lTipCon		:= .f.
		local nDias			:= 0
		local dUltimo   	:= ""
		local cUltimo   	:= ""
		local cProximo  	:= ""
		local dPrimeiro 	:= ctod("")
		local cVldMatVid    := getNewPar("MV_PLSMTVD", "1")
		local lTratLib    	:= getNewPar("MV_PLSTRLB", .t.)
		local lPtuOnline	:= IsInCallStack("u_PlsTrtPtu")
		local lBD6_QTDDEN	:= BD6->(FieldPos("BD6_QTDDEN")) > 0
		local aPacotes		:= {}
		local lEspExe		:= .f.
		local lTratExeQtd   := getNewPar("MV_PLSTREX", .t.)
		local lNeQtd        := .T.
		local JaVercr       := .F.
		local cfunName      := FunName()
		local lCkLib        := getNewPar("MV_PLSCKLB", .t.)
		local nQtdPro		:= 0
		Local lTratInt    	:= getNewPar("MV_PLSTRIN", .F.)
		Local lTratAnex    	:= GetNewPar("MV_PLSTRAX", .F.)
		Local nQtdAdd       := 0
		Local aDadosAdd     := {}

		default nRegBD6 	:= 0
		default cNivel  	:= BR8->BR8_NIVEL
		default aQtd    	:= {}
		default aPerio  	:= {}
		default cCid		:= ""
		default aDadRDA 	:= {}
		default aDadUsr 	:= {}
		default cAlias		:= ""
		default cRdaEDI 	:= ""
		default cFaces  	:= ""
		default cDente  	:= ""
		default aRet    	:= { .t., {} }
		default aFaces  	:= {}
		default aQtdBrow	:= {}
		default cChavGui	:= ""
		default cConsPer 	:= ""
		default nPerdQtd 	:= 0
		default cPerdUni 	:= ""
		default cSequen 	:= ""
		default nQtd      	:= 0
		default cEspExe 	:= ""
		default lLibPor   	:= .F.
		default cEspSol		:= ""
		default lGuiLib		:= .F.
		default lIntPort	:= .F.
		default cNumeroGuia := ""
		default lMudFase	:= isInCallStack("PLSA720VMF") .or. isInCallStack("Z1PosTab")

		if __cCdTbPd <> cCdTbPd .or. len(__aNiveis) == 0
			__cCdTbPd := cCdTbPd
			__aNiveis := PLSESPNIV(cCdTbPd)
		endIf

		if ! empty(cChavGui)

			cFilGui   := subs(cChavGui,1,len(xFilial("BA1")))

			nStart := (len(cFilGui))
			cCodOpe   := subs(cChavGui,nStart+1,4)

			nStart := (nStart + len(cCodOpe))
			cCodLDP   := subs(cChavGui,nStart+1,4)

			nStart := (nStart + len(cCodLDP))
			cCodPeg   := subs(cChavGui,nStart+1,8)

			nStart := (nStart + len(cCodPeg))
			cNumero   := subs(cChavGui,nStart+1,8)

			nStart := (nStart + len(cNumero))
			cOrimov   := subs(cChavGui,nStart+1,1)

			nStart := (nStart + len(cOrimov))
			cSequen   := subs(cChavGui,nStart+1,3)
		endIf

		if len(aDadUsr) >= 66
			dDatInc := aDadUsr[66]
		else
			dDatInc := BA1->BA1_DATINC //Caso nao esteja com o plsmfun atualizado, que foi incluido a posicao 66 com o datinc pego o do posicionado
		endIf

		if len(aDadRDA) >= 27
			cCodEsp := aDadRDA[15]
			cCodRda := aDadRDA[2]
			cTippre := aDadRda[27]
		endIf
		// Tratamento item,subgrupo,grupo
		// Pego o nome do campo referente ao nivel que me foi passado na funcao
		// Depois pego o maior nivel possivel existente
		if len(__aNiveis) > 0

			nNiveis := (__aNiveis[1]+1)

			while i <= len(__aNiveis[2])

				if __aNiveis[2,i,3] == cNivel
					cCodNiv := __aNiveis[2,i,4]
					nGravi  := i
				endIf

				i++
			endDo

		else
			PLSPOSGLO(cIntPad,__aCdCri075[1],__aCdCri075[2],cLocalExec)
			aRet := { .f.,   { {__aCdCri075[1],PLSBCTDESC(),"", BCT->BCT_TIPO, BCT->BCT_NIVEL,cCdTbPd,cCodPro} } }

			restArea(aArea)
			return aRet

		endIf

		// Vejo quantos procedimentos jah foram autorizados no browse
		// Essa regra só pode ser aplicada durante o atendimento. Ela verifica itens já digitados na guia e que ainda estão em memoria.
		// Durante a mudança de fase não pode ser aplicada porque o item no aQtdBrw é o mesmo que chega por parametro e a contagem é duplicada.
		if (empty(cChavGui) .OR. cFunName $ 'PLSA498|PLSA600|RPC') .and. !lMudFase

			if val(cNivel) == nNiveis

				for nI:=1 to len(aQtdBrow)

					if allTrim(aQtdBrow[nI][1]+aQtdBrow[nI][2]) == allTrim(cCdTbPd+cCodPro)

						if !empty(cDente)

							if len(aQtdBrow[nI]) > 6 .and. allTrim(aQtdBrow[nI][6]) == allTrim(cDente)

								if !empty(cFaces)

									if allTrim(aQtdBrow[nI][7]) == allTrim(cFaces)
										nQtd += aQtdBrow[nI][3]
									endIf

								else
									nQtd += aQtdBrow[nI][3]
								endIf
							endIf
						else
							if aQtdBrow[nI][8] < cSequen
								nQtd += aQtdBrow[nI][3]
							endIf
						endIf

					endIf

				next

			else

				for nI:=1 to len(aQtdBrow)

					if allTrim(aQtdBrow[nI][1]+Subs(aQtdBrow[nI][2],__aNiveis[2,nGravi,1],__aNiveis[2,nGravi,2])) == allTrim(cCdTbPd+Subs(cCodPro,__aNiveis[2,nGravi,1],__aNiveis[2,nGravi,2]))

						if !empty(cDente)

							if len(aQtdBrow[nI]) > 6 .and. allTrim(aQtdBrow[nI][6]) == allTrim(cDente)

								if !empty(cFaces)

									if allTrim(aQtdBrow[nI][7]) == allTrim(cFaces)
										nQtd += aQtdBrow[nI][3]
									endIf

								else
									nQtd += aQtdBrow[nI][3]
								endIf
							endIf

						else
							if aQtdBrow[nI][8] < cSequen
								nQtd += aQtdBrow[nI][3]
							endIf
						endIf

					endIf
				next

			endIf

		endIf


		cSQL :=  "SELECT BD6_QTDPRO, BD6_DATPRO, BD6_HORPRO , BD6_ESPEXE"
		cSQL +=  ", BD6_QTDDEN, BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, BD6_GUIORI "

		if  !empty(cDente)

			if cVldMatVid == "2"
				cSQL += "FROM "+RetSqlName("BD6")+","+RetSqlName("BYT")+","+RetSqlName("BA1")+" WHERE "
			else
				cSQL += "FROM "+RetSqlName("BD6")+","+RetSqlName("BYT")+" WHERE "
			endIf

			cSQL += "BYT_FILIAL = BD6_FILIAL AND "
			cSQL += "BYT_CODOPE = BD6_OPEUSR AND "
			cSQL += "BYT_CODLDP = BD6_CODLDP AND "
			cSQL += "BYT_CODPEG = BD6_CODPEG AND "
			cSQL += "BYT_NUMERO = BD6_NUMERO AND "
			cSQL += "BYT_CODPAD = BD6_CODPAD AND "
			cSQL += "BYT_CODPSA = BD6_CODPRO AND "
			cSQL += "BYT_CODIGO = BD6_DENREG AND "
			cSQL += "BYT_CODIGO = '"+allTrim(cDente)+"' AND "
			if !empty(cFaces)
				cSQL += "BYT_FACES = BD6_FADENT AND "
				cSQL += "BYT_FACES = '"+allTrim(cFaces)+"' 	AND "
			endIf
			cSQL += RetSqlName("BYT")+".D_E_L_E_T_ <> '*' AND "

		else
			if cVldMatVid == "2"
				cSQL += "FROM "+RetSqlName("BD6")+","+RetSqlName("BA1")+" WHERE "
			else
				cSQL += "FROM "+RetSqlName("BD6")+" WHERE "
			endIf

		endIf

		if cVldMatVid == "2"	// Utiliza matricua da vida.

			cSQL += "BA1_FILIAL = BD6_FILIAL AND "
			cSQL += "BA1_CODINT = BD6_OPEUSR AND "
			cSQL += "BA1_CODEMP = BD6_CODEMP AND "
			cSQL += "BA1_MATRIC = BD6_MATRIC AND "
			cSQL += "BA1_TIPREG = BD6_TIPREG AND "
			cSQL += "BA1_MATVID = '"+aDadUsr[5]+"' AND "

		else	// Utiliza verificação pela matricula do contrato.

			cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
			cSQL += "BD6_OPEUSR = '"+cOpeUsr+"' AND "
			cSQL += "BD6_CODEMP = '"+cCodEmp+"' AND "
			cSQL += "BD6_MATRIC = '"+cMatric+"' AND "
			cSQL += "BD6_TIPREG = '"+cTipReg+"' AND "
			cSQL += "BD6_DIGITO = '"+cDigito+"' AND "
		endIf

		if !lTratExeQtd .And. empty(cChavGui) .And. IIF( cFunName <> 'RPC', cFunName $ 'PLSA094B',!lLibPor)     //Parâmetro para identificar se considera as execuções na periodicidade da liberação.
			cSQL += "(BD6_LIBERA = '1' OR (BD6_LIBERA = '0' AND BD6_ORIMOV='5')) AND "
		elseif !lTratLib .And. IIF(cFunName <> 'RPC', cFunName $ 'PLSA094A/PLSA498/PLSA600/PLSA475/PLSA175',lLibPor)
			cSQL += "BD6_LIBERA = '0' AND "	//Criado o parametro MV_PLSTRLB para que as liberacoes tbm sejam levadas em consideracao ao checar regras de periodicidade e quantidade
		endif

		if cUniPer $ "1,2" //Por hora(1) ou por dia(2)
			cSQL += "BD6_DATPRO = '" + dtos(dData) + "' AND "
		elseIf cUniPer = "3" .or. cUniPer = "6"   //Por Mes ou por Semana
			cSQL += "SUBSTRING(BD6_DATPRO,1,4) = '" + Str(Year(dData), 4) + "' AND SUBSTRING(BD6_DATPRO,5,2) = '" + strZero(Month(dData), 2) + "' AND "
		elseIf cUniPer = "4"   //Por Ano

			lTipCon := .t.
			if len(aDadUsr) >= 86
				cTipCon := aDadUsr[86]
			endIf

			if cTipCon == "1" .or. ( empty(cTipCon) .and. getNewPar("MV_PLSRQTD","1") == "1")
				cSQL += "SUBSTRING(BD6_DATPRO,1,4) = '" + Str(Year(dData), 4) + "' AND "

			else //Por ano contratual

				// Considerar data inclusao contrato BA3_DATBAS (se PF) ou BQC_DATCON (se PJ)?
				if getNewPar("MV_PLSQTDC","0") == "1".and. len(aDadUsr) >= 89
					dDatInc := aDadUsr[89]
				endIf

				dDatAnaIni := ctod(subs(dtos(dDatInc),7,2)+"/"+subs(dtos(dDatInc),5,2)+"/"+Str(Year(dData), 4))

				if dData < dDatAnaIni
					dDatAnaIni := ctod(subs(dtos(dDatInc),7,2)+"/"+subs(dtos(dDatInc),5,2)+"/"+Str(Year(dData)-1, 4))
				endIf

				//dia que usr entrou   +     mes que usr entrou     +           ano anterior do evento
				cSQL += "BD6_DATPRO >= '"+dtos(dDatAnaIni)+"' AND BD6_DATPRO <= '"+dtos(dDatAnaIni+365)+"' AND "
			endIf

		endIf

		//antencao eu somente trato essa regra se tiver o indice 2, ao contrario nem entro aqui, pois eh um ponto critico do sistema.
		if getNewPar('MV_PLTRTPM','0') == '1' .and. SIX->(msSeek("BLE2"))

			BLE->(dbSetOrder(2))
			if BLE->(msSeek(xFilial("BLE")+cOpeUsr+cCdTbPd+cCodPro))
				while !BLE->(eof())	 .and. BLE->(BLE_FILIAL+BLE_CODINT+BLE_CPADOC+BLE_CODOPC) == xFilial("BLE")+cOpeUsr+cCdTbPd+cCodPro
					aadd(aPacotes, {BLE->BLE_CODPAD, BLE->BLE_CODPRO})
					BLE->(dbSkip())
				endDo
			endIf

		endIf

		if len(aPacotes) > 0

			cSQL += "(( "

			if ! existBlock("PLSQD6CT")
				cSQL += "BD6_CODPAD = '"+cCdTbPd+"' AND "
			else
				cSQL += execBlock("PLSQD6CT",.f.,.f.,{cCdTbPd})
			endIf

			// Tratamento item,subgrupo,grupo
			if ! existBlock("PLSQD6CP")

				if val(cNivel) == nNiveis .or. getNewPar("MV_PLCONI1","0") == "1"
					cSQL += "BD6_CODPRO = '" + allTrim(cCodPro) + "') OR "
				else
					cSQL += "BD6_"+cCodNiv + " = '"+Subs(cCodPro,__aNiveis[2,nGravi,1],__aNiveis[2,nGravi,2])+"') OR "
				endIf

			else
				cSQL += execBlock("PLSQD6CP",.f.,.f.,{cNivel,nNiveis,cCodNiv,nGravi,__aNiveis,cCdTbPd,cCodPro})
			endIf

			for nI:=1 to len(aPacotes)

				cSQL += "(BD6_CODPAD = '"+allTrim(aPacotes[nI][1])+"' AND "
				cSQL += " BD6_CODPRO = '"+allTrim(aPacotes[nI][2])+"') "

				if nI <> len(aPacotes)
					cSQL += " OR "
				else
					cSQL += " ) AND "
				endIf

			next

		else
			if ! existBlock("PLSQD6CT")
				cSQL += "BD6_CODPAD = '"+cCdTbPd+"' AND "
			else
				cSQL += execBlock("PLSQD6CT",.f.,.f.,{cCdTbPd})
			endIf
			// Tratamento item,subgrupo,grupo
			if ! existBlock("PLSQD6CP")

				if val(cNivel) == nNiveis .or. getNewPar("MV_PLCONI1","0") == "1"

					cSQL += "BD6_CODPRO = '"+allTrim(cCodPro)+"' AND "

				else

					cSQL += "BD6_"+cCodNiv + " = '"+Subs(cCodPro,__aNiveis[2,nGravi,1],__aNiveis[2,nGravi,2])+"' AND "

				endIf

			else
				cSQL += execBlock("PLSQD6CP",.f.,.f.,{cNivel,nNiveis,cCodNiv,nGravi,__aNiveis,cCdTbPd,cCodPro})
			endIf
		endIf

		if ! empty(cChavGui)
			cSQL += " ( ( BD6_FASE = '2' OR  BD6_FASE = '3' OR BD6_FASE = '4') OR "
			cSQL += " ( BD6_FILIAL = '"+cFilGui+"' AND BD6_CODOPE = '"+cCodOpe+"' AND BD6_CODLDP = '"+cCodLDP+"' AND BD6_CODPEG = '"+cCodPeg+"' AND BD6_NUMERO = '"+cNumero+"' AND BD6_ORIMOV = '"+cOrimov+"' AND BD6_SEQUEN < '"+cSequen+"' AND BD6_FASE = '1' )) AND "
		else
			if cUniPer == "5"  // por vida
				if !lTratLib  .And.  (IIF(!cFunName =='RPC', cFunName $ 'PLSA094A',lLibPor)) //Criado o parametro MV_PLSTRLB para que as liberacoes tbm sejam levadas em consideracao ao checar regras de periodicidade e quantidade
					cSQL += " ( BD6_FASE = '2' OR BD6_FASE = '3' OR BD6_FASE = '4' OR  (BD6_SITUAC = '1' AND BD6_LIBERA = '0' AND BD6_FASE = '1')) AND "
				else
					If lTratInt .And. (IIF(!cfunName =='RPC', cfunName $ 'PLSA092',lIntPort)) // Criado o parametro MV_PLSTRIN para que as solicitações de Internação tbm sejam levadas em consideracao ao checar regras de periodicidade e quantidade
						cSQL += " ( BD6_FASE = '2' OR BD6_FASE = '3' OR BD6_FASE = '4' OR  (BD6_SITUAC <> '2' AND (BD6_LIBERA <> '0' OR BD6_TIPGUI = '03' ) AND BD6_FASE = '1')) AND "
					Else
						cSQL += " ( BD6_FASE = '2' OR BD6_FASE = '3' OR BD6_FASE = '4' OR  (BD6_SITUAC <> '2' AND BD6_LIBERA <> '0' AND BD6_FASE = '1')) AND "
					EndIf
				endIf

				// Esse item foi comentando pois nao podemos contar com uma guia em fase de digitaçõa e que não é uma liberação
			else

				cSQL += " ( BD6_FASE = '2' OR BD6_FASE = '3' OR BD6_FASE = '4' ) AND "

			endIf
		endIf

		if existBlock("PLQTDSIT")
			cSQL += execBlock("PLQTDSIT",.f.,.f.)
			cSQL += " AND  "
		else
			if lPtuOnline
				cSQL += "(  BD6_SITUAC = '1'  OR  BD6_SITUAC = '3'  ) AND BD6_STATUS <> '0' AND "
			else
				cSQL += "( ( BD6_SITUAC = '1' ) OR ( BD6_SITUAC = '3' AND (BD6_LIBERA = '1' OR (BD6_LIBERA = '0' AND BD6_ORIMOV='5'))) )  AND BD6_STATUS <> '0' AND  "
			endIf
		endIf

		aRetAux  := PlReforBD6("2",aQtd,aPerio,cCodEsp,cCodRda,cCid,cAlias,cTipPre,cRdaEDI,cEspExe,cEspSol,lGuiLib)
		cSQL     += aRetAux[4]
		// Funcao generica que trata campos do estorno
		if findFunction("PlReChvEst")
			aRetAux  := PlReChvEst("BD6",.t.,.f.,.t.,.f.)
			cSQL     += aRetAux[1]
		endIf

		cSQL += " BD6_TIPGUI <> '06' AND " //excluo as guias de honorario individual

		cSQL += RetSqlName("BD6")+".D_E_L_E_T_ = ' ' "

		if nRegBD6 > 0 .And. !lLibPor
			// Se veio da liberacao retira
			cSQL += " AND "+PLRELIBI(nRegBD6)
			// Retira o proprio item
			cSQL += RetSqlName("BD6")+".R_E_C_N_O_ <> "+allTrim(Str(nRegBD6))
		endIf
		// Tratamento das guias nao pagas e nao cobradas
		// Pois se a guia nao tem valor de pagamento nem de cobranca ela de fato
		// nao foi realizada
		if getNewPar("MV_PLVALSO","1")=="1"

			if getNewPar("MV_PLTGPCO","1") == "1"

				nQtdPro := nQtd
				nQtd := 0 // zero o que foi encontrado

				cSQL += " AND ((BD6_BLOCPA <> '1' AND BD6_VLRTPF > 0 ) OR ( SELECT COUNT(*) FROM "+ RetSqlName("BD7") +" WHERE "
				cSQL += " BD6_FILIAL = BD7_FILIAL AND "
				cSQL += " BD6_CODOPE = BD7_CODOPE AND "
				cSQL += " BD6_CODLDP = BD7_CODLDP AND "
				cSQL += " BD6_CODPEG = BD7_CODPEG AND "
				cSQL += " BD6_NUMERO = BD7_NUMERO AND "
				cSQL += " BD6_ORIMOV = BD7_ORIMOV AND "
				cSQL += " BD6_SEQUEN = BD7_SEQUEN AND "
				cSQL += RetSqlName("BD7")+".D_E_L_E_T_ = ' ' AND "
				cSQL += " (BD7_BLOPAG <> '1') "
				cSQL += ") > 0  "
				if !empty(cChavGui)
					cSQL += " OR (BD6_FILIAL = '"+cFilGui+"' AND BD6_CODOPE = '"+cCodOpe+"' AND BD6_CODLDP = '"+cCodLDP+"' AND BD6_CODPEG = '"+cCodPeg+"' AND BD6_NUMERO = '"+cNumero+"' AND BD6_ORIMOV = '"+cOrimov+"' AND BD6_SEQUEN < '"+cSequen+"' AND BD6_FASE = '1' )) "
				else
					cSQL += " ) "
				endIf
			endIf
		endIf

		// Considera Guias de Anexo Clínico na Critica de Quantidade
		If lTratAnex
			cSql += " UNION "
			cSql += " SELECT B4C_QTDPRO, B4C_DATPRO As BD6_DATPRO, null, null, null, null, null, null, null, null, null"
			cSql += " FROM " + RetSqlName("B4C") + " B4C "
			cSql += " INNER JOIN " + RetSqlName("B4A") + " B4A "
			cSql += " 	ON B4C_FILIAL = '" + xFilial("B4C") + "'"
			cSql += "  AND B4C_OPEMOV = B4A_OPEMOV "
			cSql += "  AND B4C_ANOAUT = B4A_ANOAUT "
			cSql += "  AND B4C_MESAUT = B4A_MESAUT "
			cSql += "  AND B4C_NUMAUT = B4A_NUMAUT "
			cSql += " WHERE B4A.B4A_FILIAL = '" + xFilial("B4A") + "' AND"
			cSQL += "  B4A_OPEUSR = '" + cOpeUsr + "' AND "
			cSQL += "  B4A_CODEMP = '" + cCodEmp + "' AND "
			cSQL += "  B4A_MATRIC = '" + cMatric + "' AND "
			cSQL += "  B4A_TIPREG = '" + cTipReg + "' AND "
			cSQL += "  B4A_DIGITO = '" + cDigito + "' AND "

			Do Case
				Case cUniPer $ "1,2" //Por hora(1) ou por dia(2)
					cSQL += "B4C_DATPRO = '" + DtoS(dData) + "' AND "
				Case cUniPer == "3" .Or. cUniPer == "6"   //Por Mes ou por Semana
					cSQL += "SUBSTRING(B4C_DATPRO,1,4) = '" + Str(Year(dData), 4) + "' AND SUBSTRING(B4C_DATPRO,5,2) = '" + StrZero(Month(dData), 2) + "' AND "
				Case cUniPer == "4"   //Por Ano

					If cTipCon == "1" .Or. ( Empty(cTipCon) .And. GetNewPar("MV_PLSRQTD","1") == "1")
						cSQL += "SUBSTRING(B4C_DATPRO,1,4) = '" + Str(Year(dData), 4) + "' AND "
					Else //Por ano contratual
						dDatAnaIni := CtoD(Subs(DtoS(dDatInc),7,2) + "/" + Subs(DtoS(dDatInc),5,2) + "/" + Str(Year(dData), 4))

						If dData < dDatAnaIni
							dDatAnaIni := CtoD(Subs(DtoS(dDatInc),7,2) + "/" + Subs(DtoS(dDatInc),5,2) + "/" + Str(Year(dData)-1, 4))
						EndIf
						//dia que usr entrou   +     mes que usr entrou     +           ano anterior do evento
						cSQL += "B4C_DATPRO >= '" + DtoS(dDatAnaIni) + "' AND B4C_DATPRO <= '" + DtoS(dDatAnaIni+365) + "' AND "
					endIf
			EndCase

			If Len(aPacotes) > 0
				cSQL += "(( "

				cSQL += "B4C_CODPAD = '"+cCdTbPd+"' AND "

				cSQL += "B4C_CODPRO = '" + AllTrim(cCodPro) + "') OR "

				For nI:= 1 To Len(aPacotes)

					cSQL += "(B4C_CODPAD = '" + AllTrim(aPacotes[nI][1]) + "' AND "
					cSQL += " B4C_CODPRO = '" + AllTrim(aPacotes[nI][2]) + "') "

					If nI <> Len(aPacotes)
						cSQL += " OR "
					Else
						cSQL += " ) AND "
					EndIf
				Next nI
			Else
				cSQL += "B4C_CODPAD = '" + cCdTbPd + "' AND "
				cSQL += "B4C_CODPRO = '" + AllTrim(cCodPro ) + "' AND "
			EndIf

			If GetNewPar("MV_PLSVCID","0") == "1"
				If !Empty(cCid)
					cSQL += " B4A.B4A_CIDPRI = '"+ cCid +"' AND "
				Else
					cSQL += " B4A.B4A_CIDPRI = '" + Space(TamSx3("B4A_CIDPRI")[1]) + "' AND "
				EndIf
			EndIf

			cSql += "  B4C.B4C_STATUS  = '1' AND"
			cSql += "  B4C.D_E_L_E_T_  = ' ' AND B4A.D_E_L_E_T_  = ' ' "
		EndIf
		// Ordena por data.
		cSql += " ORDER BY BD6_DATPRO "

		dbUseArea(.t.,"TOPCONN",tcGenQry(,,PLSConSQL(cSql)),"PLSVERQTD",.f.,.t.)

		nSlvSol := nQtdSoli

		if nRegBD6 > 0 .And. !lLibPor

			nOrdBD6 := BD6->(indexOrd())
			nRecBD6 := BD6->(recno())

			BD6->(dbGoto(nRegBD6))

			if  BD6->BD6_QTDDEN > 0
				nQtdEve  := BD6->BD6_QTDPRO / BD6->BD6_QTDDEN
				nQtdSoli := 0
				nSlvQtEv := nQtdEve
			endIf

			BD6->(dbGoto(nRecBD6))
			BD6->(dbSetOrder(nOrdBD6))

		endIf

		if ! PLSVERQTD->(eof())

			plsTField("PLSVERQTD",.f.,{ "BD6_QTDDEN","BD6_QTDPRO","BD6_DATPRO" } )

			while ! PLSVERQTD->(eof())

				nQtdAdd := 0

				if cUniPer == "1" .and. left(PLSVERQTD->BD6_HORPRO, 2) = left(cHora, 2)

					if lBD6_QTDDEN .and. PLSVERQTD->BD6_QTDDEN > 0
						nQtdAdd := (PLSVERQTD->BD6_QTDPRO / PLSVERQTD->BD6_QTDDEN) + nQtdEve
						nQtd += nQtdAdd

						nQtdEve := 0
					else
						nQtdAdd := PLSVERQTD->BD6_QTDPRO + nQtdEve
						nQtd += nQtdAdd

						nQtdEve := 0
					endIf

					// tratamento da quantidade por semana ...
				elseIf cUniPer == "6"

					dDataSe := PLSVERQTD->BD6_DATPRO

					// soh vou pegar a quantidade de execucoes dentro da semana que ele estah
					// observe q pode entrar nesse if mesmo estando em semanas diferentes
					if (dData - dDataSe) <= 6

						// Posicao do dia da semana no vetor de dias da semana...
						// nAux1 := Dia da semana em que esta se solicitando o procedimento
						// nAux2 := Dia da semana em que foi realizado um procedimento qualquer
						nAux1 := ascan(aDias,{ |a| a == PLSDIASEM(dData)})
						nAux2 := ascan(aDias,{ |a| a == PLSDIASEM(PLSVERQTD->BD6_DATPRO)})

						// ele encontra-se na mesma semana ?
						if nAux1 >= nAux2

							if lBD6_QTDDEN .and. PLSVERQTD->BD6_QTDDEN > 0
								nQtdAdd := (PLSVERQTD->BD6_QTDPRO / PLSVERQTD->BD6_QTDDEN) + nQtdEve
								nQtd += nQtdAdd
								nQtdEve := 0
							else
								nQtdAdd := PLSVERQTD->BD6_QTDPRO + nQtdEve
								nQtd += nQtdAdd
								nQtdEve := 0
							endIf

						endIf

					endIf

					//NOVO: Periodicidade ser'a usada em conjuto com a quantidade.
				elseIf cUniPer == " " .and. cConsPer == '1'

					nDias 	:= PLSCalcDia(nPerdQtd,cPerdUni,"2") // Calcula em dias

					// Considera o proprio dia ao retroceder a data.
					// Analisa validade da regra.
					if dtos(PLSVERQTD->BD6_DATPRO) >= dtos(dData-(nDias-1))	.and. dtos(PLSVERQTD->BD6_DATPRO) <= dtos(dData)

						nQtdAdd := PLSVERQTD->BD6_QTDPRO + nQtdEve
						nQtd += nQtdAdd
						nQtdEve := 0

						// Obtem a data do primeiro evento realizado dentro do periodo.
						// A data que o proximo podera ser realizado ser calculada por ela.
						if empty(dPrimeiro)
							dPrimeiro := dtos(PLSVERQTD->BD6_DATPRO)
						endIf

					endIf

				elseIf cUniPer <> "1" .and. cUniPer <> "6"

					if lBD6_QTDDEN .and. PLSVERQTD->BD6_QTDDEN > 0

						nQtdAdd := (PLSVERQTD->BD6_QTDPRO / PLSVERQTD->BD6_QTDDEN) + nQtdEve
						nQtd += nQtdAdd
						nQtdEve := 0

					else

						nQtdAdd := PLSVERQTD->BD6_QTDPRO + nQtdEve
						nQtd += nQtdAdd
						nQtdEve := 0

						// Obtem a data do primeiro evento realizado dentro do periodo.
						// A data que o proximo podera ser realizado ser calculada por ela.
						if empty(dPrimeiro)
							dPrimeiro := dtos(PLSVERQTD->BD6_DATPRO)
						endIf

					endIf

				endIf

				If nQtdAdd > 0 .And. !Empty(PLSVERQTD->BD6_NUMERO)
					aAdd(aDadosAdd, { PLSVERQTD->BD6_GUIORI,;
						PLSVERQTD->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV),;
						nQtdAdd})
				EndIf

				PLSVERQTD->(dbSkip())
			endDo

		else
			lNeQtd  := .F.
			nQtd:=nQtdPro
		endIf

		PLSVERQTD->(DbCloseArea())


		If nQtdSoli > nQtdPer .And. IIF( cFunName <> 'RPC', cFunName $ 'PLSA094B/PLSA498/PLSA600/PLSA475/PLSA175',!lLibPor) .And. lCkLib
			aRet[1]  := .f.
			lCritica := .t.
			lNeQtd  := .F.
		EndIF

		If Len(aDadosAdd) > 0
			nQtd := QtdLibAutorizada(aDadosAdd, nQtd)
		EndIf

		// Testa se passou o limite...
		if (((nQtdPer > 0) .and. (nQtdSoli + Iif(cFunName $ 'RPC' .And. !Empty(cNumeroGuia),0,nQtd) > nQtdPer)) .Or. ((nQtdPer > 0) .and. (nQtdSoli + nQtdPro > nQtdPer))) .And. !PLSCheckTEA(cMatric, cCid, cCdTbPd, cCodPro) //feito o Iif(cfunname) porque quando se trata no portal ele trata como autorização somando com a quantidade das liberações efetuadas. Mas como está autorizando, ele não pode somar com a quantidade de procedimentos nas liberações.

		//NOVO: Linha que informa quando podera ser executado novamente. Apenas quando existir combinacao de quantidade + periodicidade.
		if cUniPer == " " .and. cConsPer == '1' .and. !empty(dPrimeiro)

			aRet := PLSCALCPER(cPerdUni,dData,dPrimeiro,nPerdQtd,@cUltimo,@cProximo)

			If !aRet[1]
				aRet[2] := {}
			EndIf

		endIf

		if !aRet[1]

			aadd(aRet[2],{__aCdCri046[1],PLSBCTDESC(),"", BCT->BCT_TIPO, BCT->BCT_NIVEL,cCdTbPd,cCodPro,cSequen})
			aadd(aRet[2],{""   ,STR0030 + X3COMBO("BR8_UNCA",cUniPer) + STR0031, Str(nQtdPer, 6),"","",cCdTbPd,cCodPro,cSequen}) //"Quantidade permitida para o procedimento "###" foi excedida"
			aadd(aRet[2],{""   ,STR0032, Str(nQtd-nSlvQtEv, 6), "","",cCdTbPd,cCodPro,cSequen}) //"Quantidade ja executada pelo usuario"
			aadd(aRet[2],{""   ,STR0033, Str(nSlvSol, 6), "","",cCdTbPd,cCodPro,cSequen}) //"Quantidade solicitada"
			aadd(aRet[2],{""   ,STR0034, Str(Abs(nQtd+nQtdSoli-nQtdPer),6)   , "","",cCdTbPd,cCodPro,cSequen})					 //"Quantidade Ultrapassada pelo usuario"

			if cUniPer == " " .and. cConsPer == '1' .and. !empty(dPrimeiro)
				aadd(aRet[2],{""   ,STR0096, cProximo, "","",cCdTbPd,cCodPro})  //"O procedimento poderá ser realizado somente em "
			endIf

			if !empty(cDente)
				aadd(aRet[2],{""   ,STR0086, allTrim(cDente), "","",cCdTbPd,cCodPro,cSequen}) //"Dente"
			endIf

			if !empty(cFaces)
				aadd(aRet[2],{""   ,STR0076, allTrim(cFaces), "","",cCdTbPd,cCodPro,cSequen}) //"Faces"
			endIf

		else

			aRet := {.f., 	{ {__aCdCri046[1],PLSBCTDESC(),"", BCT->BCT_TIPO, BCT->BCT_NIVEL,cCdTbPd,cCodPro,cSequen},;
				{""   ,STR0030 + X3COMBO("BR8_UNCA",cUniPer) + STR0031, Str(nQtdPer, 6),"","",cCdTbPd,cCodPro,cSequen},; //"Quantidade permitida para o procedimento "###" foi excedida"
				{""   ,STR0032, Str(nQtd-nSlvQtEv, 6), "","",cCdTbPd,cCodPro,cSequen},; //"Quantidade ja executada pelo usuario"
				{""   ,STR0033, Str(nSlvSol, 6), "","",cCdTbPd,cCodPro,cSequen},; //"Quantidade solicitada"
				{""   ,STR0034, Str(Abs(nQtd+nQtdSoli-nQtdPer),6)   , "","",cCdTbPd,cCodPro,cSequen}} }					 //"Quantidade Ultrapassada pelo usuario"

			if cUniPer == " " .and. cConsPer == '1' .and. !empty(dPrimeiro)
				aadd(aRet[2],{""   ,STR0096, cProximo, "","",cCdTbPd,cCodPro})  //"O procedimento poderá ser realizado somente em "
			endIf

			if !empty(cDente)
				aadd(aRet[2],{""   ,STR0086, allTrim(cDente), "","",cCdTbPd,cCodPro,cSequen}) //"Dente"
			endIf

			if !empty(cFaces)
				aadd(aRet[2],{""   ,STR0076, allTrim(cFaces), "","",cCdTbPd,cCodPro,cSequen}) //"Faces"
			endIf
		endIf
		endIf

		// ponto de entrada para checar regra especifica periodicidade...
		if existBlock("PLSTratQ")

			aParaPnt := {cMatrUsr,dData,cHora,cCdTbPd,cCodPro,nQtdSoli,cLocalExec,aDadRDA,nRegBD6,cCid,aRet,cDente,cFaces}
			aRetPnt  := execBlock("PLSTratQ",.f.,.f.,aParaPnt)

			if     aRetPnt[1] == "1" //devo continuar tratando, o ponto de entrada nao fez nada
				//continua normalmente...
			elseIf aRetPnt[1] == "0" //o ponto de entrada criticou e devolveu a critica, nao pode autorizar...

				if !aRet[1]
					for nK:=1 to len(aRetPnt[2])
						aadd(aRet[2],aRetPnt[2][nK])
					next
				else
					aRet := {.f.,aClone(aRetPnt[2])}
				endIf

			elseIf aRetPnt[1] == "2" //o ponto de entrada analisou e autorizou...

				aRet := {.t.,{},"",""}

			endIf

		endIf

		// Restaura area...
		restArea(aArea)

	return aRet

	/*/{Protheus.doc} PLSTratPer
Verifica se o usuario tem permissao para efetuar Per Sol.
cMatrUsr   -> Matricula do Usuario
dData      -> Data para verificacao da periodicidade
cHora      -> Hora para verificacao
cCdTbPd    -> Tabela Padrao Saude
cCodPro    -> Codigo Procedimento
nQtdSoli   -> Quantidade sendo solicitada p/verificacao
nNivel     -> Nivel que esta sendo analisado
nQtdPer    -> Quantidade permitida para determinado tipo
cUniPer    -> Unidade (1=Hora,2=Dia,3=Mes,4=Ano,5=Vida)
lIntPort   -> Internação do Portal
@type function
@author Wagner Mobile Costa
@since 18.06.03
@version 1.0
	/*/
	function PLSTratPer(cMatrUsr,dData,cHora,cCdTbPd,cCodPro,nQtdSoli,nPerioPer, cUniPer,cLocalExec,aDadRDA,nRegBD6,;
			cCid,lTratRda,cNivel,aDadUsr,cFaces,aQtd,aPerio,cAlias,cRdaEDI,cDente,aFaces,aRet,cCodEsp,cCodRda,;
			aQtdBrow,cChavGui,lPeriod,cCodProExc,cChaveAut,cSequen,lConsideraRDA,cEspExe,lLibPor,cEspSol,lGuiLib,lIntPort)
		local aArea		 	:= getArea()
		local aRetAux 	 	:= {}
		local aAreaBD6		:= {}
		local nQtd       	:= 0
		local aUltimo    	:= {}
		local cUltimo    	:= ""
		local cProximo   	:= ""
		local dUltimo    	:= ""
		local cNumImp    	:= ""
		local cChaveNota 	:= ""
		local cOriMovNota	:= ""
		local dPeriOk		:= ctod("")
		local cHorPOk		:= ""
		local nMes			:= 0
		local nAno			:= 0
		local nPeriodo		:= 0
		local lDiaOk		:= .f.
		local lMesOk		:= .f.
		local cSQL       	:= ""
		local nfor			:= 0
		local nNiveis    	:= 0
		local cOpeRda    	:= ""
		local cNameBBM   	:= RetSQLName("BBM")
		local cNameBD6   	:= RetSqlName("BD6")
		local cNameB06   	:= RetSqlName("B06")
		local cNameBYT   	:= RetSqlName("BYT")
		local cNameBA1   	:= RetSqlName("BA1")
		local aParaPnt		:= {}
		local aRetPnt		:= {}
		local cCodNiv	 	:= ""
		local i          	:= 1
		local j 		 	:= 1
		local nGravi     	:= 1
		local nK		 	:= 1
		local cOpeUsr    	:= Subs(cMatrUsr,atCodOpe[1],atCodOpe[2])
		local cCodEmp    	:= Subs(cMatrUsr,atCodEmp[1],atCodEmp[2])
		local cMatric    	:= Subs(cMatrUsr,atMatric[1],atMatric[2])
		local cTipReg    	:= Subs(cMatrUsr,atTipReg[1],atTipReg[2])
		local cDigito    	:= Subs(cMatrUsr,atDigito[1],atDigito[2])
		local cGruOpe    	:= ""
		local cTipPre    	:= ""
		local cFacRea    	:= ""
		local lInterc    	:= .f.
		local lFound     	:= .f.
		local lPerB06    	:= .f.
		local cCodPro1   	:= ""
		local cCdTbPd1   	:= ""
		local nPerioPer1 	:= 0
		local cUniPer1   	:= ""
		local cNivel1    	:= ""
		local cGuiLibera 	:= ""
		local cChaveBD6  	:= ""
		local cFilGui   	:= ""
		local cCodOpe   	:= ""
		local cCodLDP   	:= ""
		local cCodPeg   	:= ""
		local cNumero   	:= ""
		local cOrimov   	:= ""
		local cIntPad		:= plsIntPad()
		local lCritica	 	:= .f.
		local lPtuOnline	:= IsInCallStack("u_PlsTrtPtu")
		local cFunName		:= funName()
		local nI			:= 0
		local nX			:= 0
		local aCodPro   	:= {}
		local nPosProc  	:= 0
		local aCalcPer	 	:= {}
		local aRecBD6   	:= {}
		local aPacotes		:= {}
		local lAutIni	   	:= .t. // Guarda a Autorização Inicial
		local cVldMatVid    := getNewPar("MV_PLSMTVD", "1")
		local lTratLib    	:= getNewPar("MV_PLSTRLB", .t.)
		local lEspExe		:= .f.
		local lTratExeQtd   := getNewPar("MV_PLSTREX", .t.)
		Local lTratInt    	:= getNewPar("MV_PLSTRIN", .F.)
		Local lTratAnex    	:= GetNewPar("MV_PLSTRAX", .F.)


		default lTratRDA 		:= .t.
		default nRegBD6  		:= 0
		default cCid     		:= ""
		default cFaces   		:= ""
		default cNivel   		:= BR8->BR8_NIVEL
		default aDadUsr  		:= PLSGETUSR()
		default aQtd	 		:= {}
		default aPerio   		:= {}
		default aDadRDA  		:= {}
		default cAlias 	 		:= ""
		default cRdaEDI  		:= ""
		default cDente   		:= ""
		default aRet     		:= { .t., {} }
		default aFaces	 		:= {}
		default cCodEsp  		:= ""
		default cCodRda  		:= ""
		default aQtdBrow 		:= {}
		default cChavGui 		:= ""
		default lPeriod  		:= .f.
		default cCodProExc 		:= ""
		default cChaveAut 		:= ""
		default cSequen   		:= ""
		default lConsideraRDA 	:= .f.
		default cEspExe			:= ""
		default lLibPor         := .F.
		default cEspSol	  		:= ""
		default lGuiLib			:= .F.
		default lIntPort		:= .F.

		if __cCdTbPd <> cCdTbPd .or. len(__aNiveis) == 0
			__cCdTbPd := cCdTbPd
			__aNiveis := PLSESPNIV(cCdTbPd)
		endIf

		nNiveis := (__aNiveis[1]+1)

		if ! empty(cChavGui)

			cFilGui   := subs(cChavGui,1,len(xFilial("BA1")))

			nStart := (len(cFilGui))
			cCodOpe   := subs(cChavGui,nStart+1,4)

			nStart := (nStart + len(cCodOpe))
			cCodLDP   := subs(cChavGui,nStart+1,4)

			nStart := (nStart + len(cCodLDP))
			cCodPeg   := subs(cChavGui,nStart+1,8)

			nStart := (nStart + len(cCodPeg))
			cNumero   := subs(cChavGui,nStart+1,8)

			nStart := (nStart + len(cNumero))
			cOrimov   := subs(cChavGui,nStart+1,1)

			nStart := (nStart + len(cOrimov))
			cSequen   := subs(cChavGui,nStart+1,3)

		endIf

		lAutIni := aRet[1]
		cFaces 	:= allTrim(cFaces)

		if len(aDadUsr) >= 52 .and. len(aDadRda) >= 27
			cGruOpe := aDadUsr[52]
			cOpeOri := aDadUsr[45]
			cTippre := aDadRda[27]
			lInterc := (cTipPre == cMV_PLSTPIN) .or. cOpeOri <> cIntPad
		endIf

		// Tratamento item,subgrupo,grupo
		// Pego o nome do campo referente ao nivel que me foi passado na funcao
		// Depois pego o maior nivel possivel existente
		if len(__aNiveis) > 0

			nNiveis := (__aNiveis[1]+1)

			while i <= len(__aNiveis[2])

				if __aNiveis[2,i,3] == cNivel
					cCodNiv := __aNiveis[2,i,4]
					nGravi  := i
				endIf

				i++
			endDo

		else

			PLSPOSGLO(cIntPad,__aCdCri075[1],__aCdCri075[2],cLocalExec)

			aRet := { .f.,   { {__aCdCri075[1],PLSBCTDESC(),"", BCT->BCT_TIPO, BCT->BCT_NIVEL,cCdTbPd,cCodPro} } }

			restArea(aArea)

			return aRet

		endIf

		// ponto de entrada para checar regra especifica periodicidade...
		if existBlock("PLSTRATP")

			aParaPnt := {cMatrUsr,dData,cHora,cCdTbPd,cCodPro,nQtdSoli,nPerioPer,cUniPer,cLocalExec,aDadRDA,nRegBD6,cCid,cAlias,aRet,cDente,cFaces}
			aRetPnt  := execBlock("PLSTRATP",.f.,.f.,aParaPnt)

			// o ponto de entrada criticou e devolveu a critica, nao pode autorizar...
			if aRetPnt[1] == "0"

				if ! aRet[1]
					for nK := 1 to len(aRetPnt[2])
						aadd(aRet[2],aRetPnt[2][nK])
					next
				else
					aRet := {.f.,aClone(aRetPnt[2])}
				endIf

				restArea(aArea)

				return(aRet)

				// o ponto de entrada analisou e autorizou...
			elseIf aRetPnt[1] == "2"

				aRet := {.t.,{},"",""}

				restArea(aArea)

				return(aRet)

			endIf

		endIf

		if len(aDadRDA) == 0

			if empty(cCodEsp)

				cCodEsp := ""

				if lTratRda

					FWLogMsg('WARN',, 'SIGAPLS', cFunName, '', '01',STR0084 , 0, 0, {})//"PLS - Passagem de parametros para PLSTRATPER invalida"

				endIf

			endIf

		else

			cCodEsp := aDadRDA[15]
			cOpeRda := aDadRDA[14]
			cCodRda := aDadRDA[2]

			if ! lInterc

				// Grupo Periodicidade/ Procedimento
				if  ! lPeriod .and. PLSPOSGLO(cIntPad,__aCdCri161[1],__aCdCri161[2],cLocalExec,"0") .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri161[1]} )

					cCodPro1   := cCodPro
					cCdTbPd1   := cCdTbPd
					nPerioPer1 := nPerioPer
					cUniPer1   := cUniPer
					cNivel1    := cNivel

					cSQL := "SELECT B06_CODTAB,B06_CODPRO,B06_NIVEL, B06_CDNV01, B06_CDNV02, B06_CDNV03, B06_CDNV04, B06_PERIOD, B06_UNPERI, "
					cSQL += "       B06_DIFIDA "
					cSQL += "  FROM " + cNameB06
					cSQL += "  WHERE B06_FILIAL = '" + xFilial("B06") + "' AND "
					cSQL += "        B06_CODPAD = '" + cCdTbPd + "' AND "
					cSQL += "        B06_CODPSA = '" + allTrim(cCodPro) + "' AND "
					cSQL += "        D_E_L_E_T_ = ' ' "
					cSQL +=  " GROUP BY B06_FILIAL,B06_CODPAD,B06_CODPSA,B06_CODTAB,B06_CODPRO,B06_NIVEL, B06_CDNV01, B06_CDNV02, B06_CDNV03, B06_CDNV04, B06_PERIOD, B06_UNPERI, B06_DIFIDA "
					cSQL +=  " ORDER BY B06_NIVEL DESC"

					dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSPerB06",.f.,.t.)

					if !PLSPerB06->(eof())
						plsTField("PLSPerB06",.f.,{ "B06_PERIOD","B06_PERIOD" } )
					endIf

					while ! PLSPerB06->(eof()) .and. (PLSPerB06->B06_PERIOD > 0  .or. PLSPerB06->B06_DIFIDA = '1')

						nPerAux   := nPerioPer
						cUniAux   := cUniPer
						cCodPro   := PLSPerB06->B06_CODPRO
						cCdTbPd   := PLSPerB06->B06_CODTAB
						nPerioPer := PLSPerB06->B06_PERIOD
						cUniPer   := PLSPerB06->B06_UNPERI
						cNivel    := PLSPerB06->B06_NIVEL
						lPerB06   := .t.

						//Se a periodicidade varia por idade
						if (PLSPerB06->B06_DIFIDA = '1')

							cChavePer := xFilial("B06")+ cCdTbPd + allTrim(cCodPro)+PLSPerB06->(B06_CODTAB+B06_CODPRO+B06_NIVEL)
							aRetIdade := PLBUSDIFID("B06",cChavePer,aDadUsr[26],nPerioPer,cUniPer)

							//Diz se encontrou a regra variavel por idade
							if aRetIdade[3]

								nPerioPer := aRetIdade[1]
								cUniPer   := aRetIdade[2]

								// se não encontrou, volta a regra antiga.
								// que era ver se a BBM tinha periodicidade cadastrada. Qndo = 0 volta pro valor antes da minha validação.
							elseIf PLSTratPer->B06_PERIOD = 0

								nPerioPer := nPerAux
								cUniPer := cUniAux

							endIf

						endIf

						// se eh um item
						if allTrim(cNivel) = allTrim(Str((__aNiveis[1]+1)))

							aadd(aCodPro,cCodPro)

							//Qdo Grupo/SubGrupo, olhar a regra, menos para os itens especificamente parametrizados
						else

							if len(aCodPro) > 0

								nPosProc := ascan(__aNiveis[2],{|x| x[3] == PLSPerB06->B06_NIVEL})

								for nI:= 1 to len(aCodPro)

									if subStr(aCodPro[nI],__aNiveis[2,nPosProc,1],__aNiveis[2,nPosProc,2]) = subStr(PLSPerB06->B06_CODPRO,__aNiveis[2,nPosProc,1],__aNiveis[2,nPosProc,2])

										if !empty(cCodProExc)
											cCodProExc += ", "
										endIf

										cCodProExc += "'"+allTrim(aCodPro[nI])+"'"

									endIf

								next nI

							endIf

						endIf

						aRet := PlsTratPer(cMatrUsr,dData,cHora,cCdTbPd,cCodPro,nQtdSoli,nPerioPer,cUniPer,cLocalExec,aDadRDA,nRegBD6,;
							cCid,lTratRda,cNivel,aDadUsr,cFaces,aQtd,aPerio,cAlias,cRdaEDI,cDente,aFaces,aRet,nil,;
							nil,aQtdBrow,cChavGui,lPerB06,cCodProExc,,,,cEspExe)

						PLSPerB06->(dbSkip())
					endDo

					PLSPerB06->(DbCloseArea())

					restArea(aArea)

					if aRet[1] .and. len(aRet[2]) == 0
						cCodPro   := cCodPro1
						cCdTbPd   := cCdTbPd1
						nPerioPer := nPerioPer1
						cUniPer   := cUniPer1
						cNivel    := cNivel1
						lPeriod   := .f.
					endIf

				endIf

				// Especialidade x Procedimento...
				if ! lPeriod

					cSQL := "SELECT BBM_PERIOD, BBM_UNPER, BBM_CODPSA, BBM_NIVEL, BBM_TIPO, BBM_ATIVO, BBM_DIFIDA "
					cSQL += "  FROM " + cNameBBM
					cSQL += " WHERE BBM_FILIAL = '" + xFilial("BBM") + "' AND "
					cSQL += "       BBM_CODINT = '" + cOpeRDA + "' AND "
					cSQL += "       BBM_CODESP = '" + cCodEsp + "' AND "
					cSQL += "       BBM_CODPAD = '" + cCdTbPd + "' AND "

					cSQL += PLREQNI("BBM", "BBM_CODPSA", __aNiveis[2], cCodPro)

					cSQL +=  " D_E_L_E_T_ = ' ' "

					cSQL +=  " ORDER BY BBM_NIVEL DESC "

					dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSTratPer",.f.,.t.)

					if ! PLSTratPer->(eof())

						plsTField("PLSTratPer",.f.,{ "BBM_PERIOD" } )

						if  (PLSTratPer->BBM_PERIOD > 0 .or. PLSTratPer->BBM_DIFIDA = '1')

							nPerAux := nPerioPer
							cUniAux := cUniPer

							nPerioPer := PLSTratPer->BBM_PERIOD
							cUniPer   := PLSTratPer->BBM_UNPER

							//Se a periodicidade varia por idade
							if PLSTratPer->BBM_DIFIDA = '1'

								cChavePer := xFilial("BBM")+cOpeRDA+cCodEsp+cCdTbPd+PLSTratPer->(BBM_CODPSA+BBM_NIVEL+BBM_TIPO+BBM_ATIVO)
								aRetIdade := PLBUSDIFID("BBM",cChavePer,aDadUsr[26],nPerioPer,cUniPer)

								if aRetIdade[3] //Diz se encontrou a regra variavel por idade

									nPerioPer := aRetIdade[1]
									cUniPer   := aRetIdade[2]

								elseIf PLSTratPer->BBM_PERIOD = 0 //se não encontrou, volta a regra antiga.

									// que era ver se a BBM tinha periodicidade cadastrada. Qndo = 0 volta pro valor antes da minha validação.
									nPerioPer := nPerAux
									cUniPer := cUniAux

								endIf

							endIf

						endIf

					endIf

					PLSTratPer->(DbCloseArea())

				endIf

			else

				//Funcao que posiciona no grupo de operadora na vigencia correta...
				if PLSPosGOpe(cGruOpe,dData)

					if PLSISCON(cCdTbPd,cCodPro,.t.)

						if BGH->BGH_PERCON > 0 .or. BGH->BGH_DIFIDA = '1'

							nPerAux := nPerioPer
							cUniAux := cUniPer

							nPerioPer := BGH->BGH_PERCON
							cUniPer   := BGH->BGH_UNPERI

							//Se a periodicidade varia por idade
							if BGH->BGH_DIFIDA = '1'

								cChavePer := BGH->(BGH_FILIAL+BGH_GRUOPE+BGH_CODSEQ)
								aRetIdade := PLBUSDIFID("BGH",cChavePer,aDadUsr[26],nPerioPer,cUniPerio)

								if aRetIdade[3] //Diz se encontrou a regra variavel por idade

									nPerioPer := aRetIdade[1]
									cUniPer   := aRetIdade[2]

								elseIf BGH->BGH_PERCON = 0 //se não encontrou, volta a regra antiga.

									// que era ver se a BBM tinha periodicidade cadastrada. Qndo = 0 volta pro valor antes da minha validação.
									nPerioPer := nPerAux
									cUniPer := cUniAux

								endIf

							endIf

						else
							nPerioPer := getNewPar("MV_PLSPEIN",15)
							cUniPer   := "2" //Dias
						endIf

					endIf

				endIf

			endIf

		endIf

		if (nPerioPer == 0 .OR. nQtdSoli == 0) .and. ! lPeriod
			restArea(aArea)
			return aRet
		endIf

		if cUniPer = "1"
			cSQL := "SELECT BD6_DATPRO+BD6_HORPRO ULTIMO, BD6_NUMIMP, BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, "+iIf(lPtuOnline,"BD6_SITUAC, BD6_LIBERA, ","") + "BD6_ESPEXE, " + cNameBD6 + ".R_E_C_N_O_ recno "
		else
			cSQL := "SELECT BD6_DATPRO ULTIMO, BD6_NUMIMP, BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, "+iIf(lPtuOnline,"BD6_SITUAC, BD6_LIBERA, ","") + "BD6_ESPEXE, " + cNameBD6 + ".R_E_C_N_O_ recno "
		endIf

		if ! empty(cFaces)
			cSQL += ", BD6_FACES "
		endIf

		// Verifica se a guia que esta mudando a fase e oriunda de uma libercao e a descarta da verificacao
		if ! empty(cChavGui)

			aArea	:= GetArea()
			nRecBD5 := BD5->(recno())
			nRecBD6 := BD6->(recno())

			BD6->(dbSetOrder(1))
			if BD6->(msSeek(cChavGui))     //mudanca de fase

				//Acha BD5 correspondente ao BD6 que esta sendo verificado
				BD5->(dbSetOrder(1))
				if BD5->(msSeek(BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_SITUAC+BD6_FASE+dtos(BD6_DATPRO)+BD6_OPERDA+BD6_CODRDA)))

					cGuiLibera := BD5->BD5_NRLBOR

					//Procura na BEA a guia de liberacao correspondente
					BEA->(dbSetOrder(1))
					if BEA->(msSeek(xFilial("BEA")+cGuiLibera))

						//Procura BD6s da Guia de liberacao
						if BD6->(msSeek(xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)))

							cChaveBD6 := BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)

							//Verifica qual o BD6 corresponde ao procedimento analisado e marca o seu recno
							while BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) == cChaveBD6 .and. !BD6->(eof())

								if BD6->BD6_CODPAD == cCdTbPd .and. allTrim(BD6->BD6_CODPRO) == allTrim(cCodPro)
									aadd(aRecBD6,{BD6->(recno())})
								endIf

								BD6->(dbSkip())
							endDo

						endIf

					endIf

				endIf

			endIf

			RestArea(aArea)
			BD5->(dbGoto(nRecBD5))
			BD6->(dbGoto(nRecBD6))

		elseIf Type("M->BE1_NUMLIB") <> 'U'

			aArea:= GetArea()

			cGuiLibera := M->BE1_NUMLIB

			dbSelectArea("BEA")
			//Procura na BEA a guia de liberacao correspondente
			BEA->(dbSetOrder(1))
			if BEA->(msSeek(xFilial("BEA")+cGuiLibera))

				//Procura BD6s da Guia de liberacao
				if BD6->(msSeek(xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)))

					cChaveBD6 := BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)

					//Verifica qual o BD6 corresponde ao procedimento analisado e marca o seu recno
					while BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) == cChaveBD6 .and. !BD6->(eof())

						if BD6->BD6_CODPAD == cCdTbPd .and. allTrim(BD6->BD6_CODPRO) == allTrim(cCodPro)
							aadd(aRecBD6,{BD6->(recno())})
						endIf

						BD6->(dbSkip())
					endDo

				endIf

			endIf

			RestArea(aArea)

		endIf

		if 	! lPeriod .and. ! empty(cDente)

			if cVldMatVid == "2"
				cSQL += ", BYT_CODIGO , BYT_FACES FROM " + cNameBD6 + "," + cNameBYT + "," + cNameBA1 + "  WHERE "
			else
				cSQL += ", BYT_CODIGO , BYT_FACES FROM " + cNameBD6 + "," + cNameBYT + "  WHERE "
			endIf

			cSQL += "BYT_FILIAL = '" + xFilial('BYT') + "' AND "
			cSQL += "BYT_CODOPE = BD6_OPEUSR AND "
			cSQL += "BYT_CODLDP = BD6_CODLDP AND "
			cSQL += "BYT_CODPEG = BD6_CODPEG AND "
			cSQL += "BYT_NUMERO = BD6_NUMERO AND "
			cSQL += "BYT_CODPAD = BD6_CODPAD AND "
			cSQL += "BYT_CODPSA = BD6_CODPRO AND "
			cSQL += "BYT_CODIGO = BD6_DENREG AND "
			cSQL += "BYT_CODIGO = '"+allTrim(cDente)+"' AND "

			if !empty(cFaces)
				cSQL += "BYT_FACES = BD6_FADENT AND "
				cSQL += "BYT_FACES = '" + allTrim(cFaces) + "' 	AND "
			endIf

			cSQL +=  cNameBYT + ".D_E_L_E_T_ = ' ' AND "

		else

			if cVldMatVid == "2"
				cSQL += "FROM " + cNameBD6 + "," + cNameBA1 + " WHERE "
			else
				cSQL += "FROM " + cNameBD6 + " WHERE "
			endIf

		endIf

		if cVldMatVid == "2"	// Utiliza matricua da vida.

			cSQL += "BA1_FILIAL = '" + xFilial('BA1') + "' AND "
			cSQL += "BA1_CODINT = BD6_OPEUSR AND "
			cSQL += "BA1_CODEMP = BD6_CODEMP AND "
			cSQL += "BA1_MATRIC = BD6_MATRIC AND "
			cSQL += "BA1_TIPREG = BD6_TIPREG AND "
			cSQL += "BA1_MATVID = '" + aDadUsr[5] + "' AND "

			// Utiliza verificação pela matricula do contrato.
		else

			cSQL += "BD6_FILIAL = '" + xFilial("BD6")+  "' AND "
			cSQL += "BD6_OPEUSR = '" + cOpeUsr + "' AND "
			cSQL += "BD6_CODEMP = '" + cCodEmp + "' AND "
			cSQL += "BD6_MATRIC = '" + cMatric + "' AND "
			cSQL += "BD6_TIPREG = '" + cTipReg + "' AND "
			cSQL += "BD6_DIGITO = '" + cDigito + "' AND "

		endIf

		if !lTratExeQtd .And. empty(cChavGui) .And. (IIF( cFunName <> 'RPC', cFunName $ 'PLSA094B',!lLibPor))      //Parâmetro para identificar se considera as execuções na periodicidade da liberação.
			cSQL += "BD6_LIBERA = '1' AND "
		elseif ! lTratLib .And. (IIF( cfunName <> 'RPC', cfunName $ 'PLSA094A/PLSA498/PLSA600/PLSA475/PLSA175',lLibPor))
			cSQL += "BD6_LIBERA = '0' AND "	//Criado o parametro MV_PLSTRLB para que as liberacoes tbm sejam levadas em consideracao ao checar regras de periodicidade e quantidade na execução
		endIf

		//antencao eu somente trato essa regra se tiver o indice 2, ao contrario nem entro aqui, pois eh um ponto critico do sistema.
		if getNewPar('MV_PLTRTPM','0') == '1'

			BLE->(dbSetOrder(2))
			if BLE->(msSeek(xFilial("BLE")+cOpeUsr+cCdTbPd+cCodPro))

				while !BLE->(eof())	 .and. BLE->(BLE_FILIAL+BLE_CODINT+BLE_CPADOC+BLE_CODOPC) == xFilial("BLE")+cOpeUsr+cCdTbPd+cCodPro

					aadd(aPacotes, {BLE->BLE_CODPAD, BLE->BLE_CODPRO})

					BLE->(dbSkip())
				endDo

			endIf

		endIf

		if len(aPacotes) > 0

			cSQL += "(( "

			if ! existBlock("PLSQD6CT")
				cSQL += "BD6_CODPAD = '" + cCdTbPd + "' AND "
			else
				cSQL += execBlock("PLSQD6CT",.f.,.f.,{cCdTbPd})
			endIf

			// Tratamento item,subgrupo,grupo
			if ! existBlock("PLSQD6CP")

				if val(cNivel) == nNiveis .or. getNewPar("MV_PLCONI1","0") == "1"
					cSQL += "BD6_CODPRO = '" + allTrim(cCodPro) + "') OR "
				else
					cSQL += "BD6_" + cCodNiv + " = '" + subs(cCodPro,__aNiveis[2,nGravi,1],__aNiveis[2,nGravi,2]) + "') OR "
				endIf

				// não verifica os procedimentos já analisados( trata B06 )
				if ! empty(cCodProExc)
					cSQL += "BD6_CODPRO NOT IN (" + cCodProExc + ")) OR "
				endIf
			else
				cSQL += execBlock("PLSQD6CP",.f.,.f.,{cNivel,nNiveis,cCodNiv,nGravi,__aNiveis,cCdTbPd,cCodPro})
			endIf

			for nI := 1 to len(aPacotes)

				cSQL += " (BD6_CODPAD = '" + allTrim(aPacotes[nI][1]) + "' AND "
				cSQL += "  BD6_CODPRO = '" + allTrim(aPacotes[nI][2]) + "') "

				if nI <> len(aPacotes)
					cSQL += " OR "
				else
					cSQL += " ) AND "
				endIf

			next

		else

			if ! existBlock("PLSQD6CT")
				cSQL += "BD6_CODPAD = '" + cCdTbPd + "' AND "
			else
				cSQL += execBlock("PLSQD6CT",.f.,.f.,{cCdTbPd})
			endIf

			if ! existBlock("PLSQD6CP")

				if val(cNivel) == nNiveis .or. getNewPar("MV_PLCONI1","0") == "1"
					cSQL += "BD6_CODPRO = '" + allTrim(cCodPro) + "' AND "
				else
					cSQL += "BD6_" + cCodNiv + " = '" + Subs(cCodPro,__aNiveis[2,nGravi,1],__aNiveis[2,nGravi,2]) + "' AND "
				endIf

				// não verifica os procedimentos já analisados( trata B06 )
				if !empty(cCodProExc)
					cSQL += "BD6_CODPRO NOT IN (" + cCodProExc + ") AND "
				endIf

			else
				cSQL += execBlock("PLSQD6CP",.f.,.f.,{cNivel,nNiveis,cCodNiv,nGravi,__aNiveis,cCdTbPd,cCodPro})
			endIf

		endIf

		// Aqui vou tratar todos aqueles campinhos do BR8, por exemplo:
		// BR8_PTRCRE,BR8_PTRESP,BR8_PTRMED,BR8_PTRPAT,BR8_PTRGEN,BR8_PTRSOL
		// BR8_UNQSOL,BR8_APOSPE,BR8_APPESO que dizem se a peridoicade cadastrada eh|
		// valida por patologia,medico,especialidade....
		aRetAux  := PlReforBD6("1",aQtd,aPerio,cCodEsp,cCodRda,cCid,cAlias,cTipPre,cRdaEDI,cEspExe,cEspSol,lGuiLib)
		cSQL     += aRetAux[4]

		// Funcao generica que trata campos do estorno
		if findFunction("PlReChvEst")
			aRetAux  := PlReChvEst("BD6",.t.,.f.,.t.,.f.)
			cSQL     += aRetAux[1]
		endIf

		// Exclui a propria do consulta e verifica se veio de uma liberacao
		if nRegBD6 > 0 .And. !lLibPor

			// Exclui o proprio registro
			cSQL += cNameBD6+".R_E_C_N_O_ <> " + allTrim(Str(nRegBD6)) + " AND "

			// Se veio da liberacao retira
			cSQL += PLRELIBI(nRegBD6)

		endIf

		cSQL += " (BD6_DATPRO <= '" + dtos(dData) + "'  OR  BD6_DATPRO >= '" + dtos(dData) + "' AND  BD6_DATPRO <= '" + dtos(dData+nPerioPer) + "') AND "

		// esse tratamento se faz necessario devido que nesse momento ainda nao foi gravado a fase para a Guia corrente somente a nivel de autorização ou rejeição
		if cUniPer = "1"
			cSQL += "( BD6_FASE = '2' OR BD6_FASE = '3' OR BD6_FASE = '4' OR  (BD6_FASE = '1' AND BD6_CHVNIV <> ' ')) AND "
		else

			if lTratLib .And. (IIF(!cfunName =='RPC', cfunName $ 'PLSA094A',lLibPor))
				cSQL += "( BD6_FASE = '2' OR BD6_FASE = '3' OR BD6_FASE = '4' OR ( BD6_FASE='1' AND BD6_SITUAC = '3' AND BD6_LIBERA = '1') ) AND "
			else
				If lTratInt .And. (IIF(!cfunName =='RPC', cfunName $ 'PLSA092',lIntPort)) // Criado o parametro MV_PLSTRIN para que as solicitações de Internação tbm sejam levadas em consideracao ao checar regras de periodicidade e quantidade
					cSQL += "( BD6_FASE = '2' OR BD6_FASE = '3' OR BD6_FASE = '4' OR (BD6_SITUAC = '1' AND BD6_TIPGUI = '03' AND BD6_FASE = '1') ) AND "
				Else
					cSQL += "( BD6_FASE = '2' OR BD6_FASE = '3' OR BD6_FASE = '4') AND "
				EndIf
			endIf

		endIf

		if existBlock("PLPERSIT")
			cSQL += execBlock("PLPERSIT",.f.,.f.)
			cSQL += " AND  "
		else

			if lPtuOnline
				cSQL += "( ( BD6_SITUAC = '1' ) OR ( BD6_SITUAC = '3' ) )  AND BD6_STATUS <> '0' AND  "
			else
				cSQL += "( ( BD6_SITUAC = '1' ) OR ( BD6_SITUAC = '3' AND BD6_LIBERA = '1') )  AND BD6_STATUS <> '0' AND  "
			endIf

		endIf

		//excluo as guias de honorario individual
		cSQL += " BD6_TIPGUI <> '06' AND "

		//Verifica se pra considerar a
		if lConsideraRDA
			cSQL += " BD6_CODRDA = '" + cCodRDA + "' AND "
		endIf

		cSQL += cNameBD6 + ".D_E_L_E_T_ = ' ' "

		// Tratamento das guias nao pagas e nao cobradas
		// Pois se a guia nao tem valor de pagamento nem de cobranca ela de fato
		// nao foi realizada
		if getNewPar("MV_PLVALSO","0") == "1" .and. getNewPar("MV_PLTGPCO","1") == "1"

			cSQL += " AND ((BD6_BLOCPA <> '1' ) OR ( SELECT COUNT(*) FROM " + RetSqlName("BD7") + " WHERE "
			cSQL += " BD6_FILIAL = BD7_FILIAL AND "
			cSQL += " BD6_CODOPE = BD7_CODOPE AND "
			cSQL += " BD6_CODLDP = BD7_CODLDP AND "
			cSQL += " BD6_CODPEG = BD7_CODPEG AND "
			cSQL += " BD6_NUMERO = BD7_NUMERO AND "
			cSQL += " BD6_ORIMOV = BD7_ORIMOV AND "
			cSQL += " BD6_SEQUEN = BD7_SEQUEN AND "
			cSQL += RetSqlName("BD7") + ".D_E_L_E_T_ = ' ' AND "
			cSQL += " (BD7_BLOPAG <> '1' ) ) > 0) "

		endIf

		// Considera Guias de Anexo Clínico na Critica de Periodicidade
		If lTratAnex
			cSql += " UNION "
			cSql += " SELECT B4C_DATPRO ULTIMO, null, null , null, null, null, null, null, null "

			If lPtuOnline
				cSQL += ", null, null "
			EndIf

			If !Empty(cFaces)
				cSQL += ", null "
			EndIf

			cSql += " FROM " + RetSqlName("B4C") + " B4C "
			cSql += " INNER JOIN " + RetSqlName("B4A") + " B4A "
			cSql += " 	ON B4C_FILIAL = '" + xFilial("B4C") + "'"
			cSql += "  AND B4C_OPEMOV = B4A_OPEMOV "
			cSql += "  AND B4C_ANOAUT = B4A_ANOAUT "
			cSql += "  AND B4C_MESAUT = B4A_MESAUT "
			cSql += "  AND B4C_NUMAUT = B4A_NUMAUT "
			cSql += " WHERE B4A.B4A_FILIAL = '" + xFilial("B4A") + "' AND"
			cSQL += "  B4A_OPEUSR = '" + cOpeUsr + "' AND "
			cSQL += "  B4A_CODEMP = '" + cCodEmp + "' AND "
			cSQL += "  B4A_MATRIC = '" + cMatric + "' AND "
			cSQL += "  B4A_TIPREG = '" + cTipReg + "' AND "
			cSQL += "  B4A_DIGITO = '" + cDigito + "' AND "

			cSQL += " (B4C_DATPRO <= '" + DtoS(dData) + "'  OR  B4C_DATPRO >= '" + DtoS(dData) + "' AND  B4C_DATPRO <= '" + DtoS(dData+nPerioPer) + "') AND "

			If Len(aPacotes) > 0

				cSQL += "(( "
				cSQL += "B4C_CODPAD = '" + cCdTbPd + "' AND "
				cSQL += "B4C_CODPRO = '" + AllTrim(cCodPro) + "') OR "

				// Não verifica os procedimentos já analisados
				If !Empty(cCodProExc)
					cSQL += "B4C_CODPRO NOT IN (" + cCodProExc + ")) OR "
				EndIf

				For nI := 1 To Len(aPacotes)
					cSQL += " (B4C_CODPAD = '" + AllTrim(aPacotes[nI][1]) + "' AND "
					cSQL += "  B4C_CODPRO = '" + AllTrim(aPacotes[nI][2]) + "') "

					If nI <> Len(aPacotes)
						cSQL += " OR "
					Else
						cSQL += " ) AND "
					EndIf
				Next nI
			Else

				cSQL += "B4C_CODPAD = '" + cCdTbPd + "' AND "
				cSQL += "B4C_CODPRO = '" + AllTrim(cCodPro) + "' AND "

				// Não verifica os procedimentos já analisados
				If !Empty(cCodProExc)
					cSQL += "B4C_CODPRO NOT IN (" + cCodProExc + ") AND "
				EndIf
			EndIf

			If GetNewPar("MV_PLSVCID","0") == "1"
				If !Empty(cCid)
					cSQL += " B4A.B4A_CIDPRI = '" + cCid + "' AND "
				Else
					cSQL += " B4A.B4A_CIDPRI = '" + Space(TamSx3("B4A_CIDPRI")[1]) + "' AND "
				EndIf
			EndIf

			cSql += "  B4C.B4C_STATUS  = '1' AND"
			cSql += "  B4C.D_E_L_E_T_  = ' ' AND B4A.D_E_L_E_T_  = ' ' "
			cSQL += " ORDER BY ULTIMO
		Else
			cSQL += " ORDER BY BD6_FILIAL,BD6_OPEUSR,BD6_CODEMP,BD6_MATRIC,BD6_TIPREG,BD6_DIGITO,BD6_DATPRO"

			if cUniPer == "1"
				cSQL += ",BD6_HORPRO"
			endIf
		EndIf

		dbUseArea(.t.,"TOPCONN",tcGenQry(,,PLSConSQL(cSql)),"PLSVERPER",.f.,.t.)

		// Vejo quantos procedimentos jah foram autorizados no browse

		// Essa regra só pode ser aplicada durante o atendimento. Ela verifica itens já digitados na guia e que ainda estão em memoria.
		// Durante a mudança de fase não pode ser aplicada porque o item no aQtdBrw é o mesmo que chega por parametro e a contagem é duplicada.
		if empty(cChavGui).or. cfunName $ 'PLSA498/PLSA600/RPC'

			if val(cNivel) == nNiveis

				for nI := 1 to len(aQtdBrow)

					if allTrim(aQtdBrow[nI][1] + aQtdBrow[nI][2]) == allTrim(cCdTbPd+cCodPro)

						if ! empty(cDente)

							if len(aQtdBrow[nI]) > 6 .and. allTrim(aQtdBrow[nI][6]) == allTrim(cDente)

								if !empty(cFaces)

									if allTrim(aQtdBrow[nI][7]) == allTrim(cFaces)

										if val(aQtdBrow[nI][8]) < val(cSequen)
											dUltimo := if(cUniPer=="1",dtos(aQtdBrow[nI][4])+aQtdBrow[nI][5],dtos(aQtdBrow[nI][4]))
										endIf

									endIf

								else
									if val(aQtdBrow[nI][8]) < val(cSequen)
										dUltimo := if(cUniPer=="1",dtos(aQtdBrow[nI][4])+aQtdBrow[nI][5],dtos(aQtdBrow[nI][4]))
									endif
								endIf

							endIf

						else
							if val(aQtdBrow[nI][8]) < val(cSequen)
								dUltimo := if(cUniPer=="1",dtos(aQtdBrow[nI][4])+aQtdBrow[nI][5],dtos(aQtdBrow[nI][4]))
							endIf

						endIf

					endIf

				next

			else

				for nI := 1 to len(aQtdBrow)

					if allTrim(aQtdBrow[nI][1]+Subs(aQtdBrow[nI][2],__aNiveis[2,nGravi,1],__aNiveis[2,nGravi,2])) == allTrim(cCdTbPd+Subs(cCodPro,__aNiveis[2,nGravi,1],__aNiveis[2,nGravi,2]))

						if !empty(cDente)

							if len(aQtdBrow[nI]) > 6 .and. allTrim(aQtdBrow[nI][6]) == allTrim(cDente)

								if !empty(cFaces)

									if allTrim(aQtdBrow[nI][7]) == allTrim(cFaces)
										if val(aQtdBrow[nI][8]) < val(cSequen)
											dUltimo := if(cUniPer=="1",dtos(aQtdBrow[nI][4])+aQtdBrow[nI][5],dtos(aQtdBrow[nI][4]))
										endif
									endIf

								else
									if val(aQtdBrow[nI][8]) < val(cSequen)
										dUltimo := if(cUniPer=="1",dtos(aQtdBrow[nI][4])+aQtdBrow[nI][5],dtos(aQtdBrow[nI][4]))
									endif
								endIf

							endIf

						else

							if val(aQtdBrow[nI][8]) < val(cSequen)
								dUltimo := if(cUniPer=="1",dtos(aQtdBrow[nI][4])+aQtdBrow[nI][5],dtos(aQtdBrow[nI][4]))
							endIf

						endIf

					endIf

				next

			endIf

		endIf

		/*
// Esse bloco foi retirado pois a contagem da periodiciade deve ser em cima das guias ja digitadas e não a que esta em tempo de digitação.
if empty(cChavGui) .and. len(aRet)>0 .and. PLSVERPER->(eof()) .and. len(aRecBD6) > 0 .and. nQtdSoli > nPerioPer .And. !lPtuOnLine

	If !lTratLib .And. (IIF(!cfunName =='RPC', cfunName $ 'PLSA094A',lLibPor))
	 	If (cfunName $ 'PLSA094A' .Or. lLibPor)
		    aRet[1]  := .f.
			lCritica := .t.
		EndIf
	Else
	    aRet[1]  := .f.
		lCritica := .t.
	EndIf
endIf
		*/

		//se estou no contas medicas, e estou executando mais que um evento no mesmo BD6
		//isso significa que a data do ultimo procedimento realizado eh a propria data
		//do evento
		if ! empty(cChavGui) .and. empty(dUltimo) .and. nQtdSoli > 1

			BD6->(dbSetOrder(1))
			// se nao tem uma liberacao envolvida
			if ( BD6->(msSeek(cChavGui)) .and. len(aRecBD6) == 0 ) .or. nQtdSoli > 1

				dUltimo := dtos(dData)

			endIf

		endIf

		if ! PLSVERPER->(eof()) .or. ! empty(dUltimo)

			BEA->(dbSetOrder(12))//BEA_FILIAL+BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV

			while !PLSVERPER->(eof())

				// Verifica BD6s da liberacao origem e desconsidera-os da verificacao
				if ascan(aRecBD6,{|x| x[1] == PLSVERPER->recno}) > 0 .And. !lTratLib .And. (cFunName == 'PLSA094A' .Or. lLibPor)
					PLSVERPER->(dbSkip())
					Loop
				endIf

				// Ptu Online, verifica se a guia e proveniente de Ptu quando LIBERA = 0
				if lPtuOnline .and. PLSVERPER->BD6_SITUAC == '3' .and. PLSVERPER->BD6_LIBERA == '0'

					if BEA->(msSeek(xFilial("BEA")+PLSVERPER->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))

						if BEA->BEA_COMUNI <> "1" .or. empty(BEA->BEA_NRTROL) //Se a guia nao e oriunda Ptu Online desconsidera

							PLSVERPER->(dbSkip())
							Loop

						endIf

						//Nao achou o atendimento na BEA desconsidera
					else
						PLSVERPER->(dbSkip())
						Loop
					endIf

				endIf

				if empty(cDente) .and. PLSVERPER->ULTIMO > dUltimo

					cChaveNota  := PLSVERPER->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)
					cOriMovNota := PLSVERPER->(BD6_ORIMOV)
					cNumImp     := PLSVERPER->(BD6_NUMIMP)
					dUltimo     := PLSVERPER->ULTIMO

					// Odonto em nivel de face.
				elseIf !empty(cDente) .and. !empty(cFaces) .and. PLSVERPER->ULTIMO > dUltimo

					if allTrim(PLSVERPER->BYT_CODIGO) == allTrim(cDente) .and. allTrim(PLSVERPER->BYT_FACES) == allTrim(cFaces)

						cChaveNota  := PLSVERPER->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)
						cOriMovNota := PLSVERPER->(BD6_ORIMOV)
						cNumImp     := PLSVERPER->(BD6_NUMIMP)
						dUltimo     := PLSVERPER->ULTIMO

					endIf

					// Odonto em nivel de dente.
				elseIf !empty(cDente) .and. empty(cFaces) .and. PLSVERPER->ULTIMO > dUltimo

					if allTrim(PLSVERPER->BYT_CODIGO) == allTrim(cDente)
						cChaveNota  := PLSVERPER->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)
						cOriMovNota := PLSVERPER->(BD6_ORIMOV)
						cNumImp     := PLSVERPER->(BD6_NUMIMP)
						dUltimo     := PLSVERPER->ULTIMO
					endIf

				endIf

				PLSVERPER->(dbSkip())
			endDo

			aCalcPer := PLSCALCPER(cUniPer,dData,dUltimo,nPerioPer,@cUltimo,@cProximo,cHora,nQtdSoli)

			if len(aCalcPer) > 0
				aRet[1]  := aCalcPer[1]
				lCritica := aCalcPer[2]
			endIf

		endIf

		PLSVERPER->(DbCloseArea())

		if getNewPar("MV_PLSPEAG","0") == "1" .and. cFunName == "PLSA300"

			if aRet[1] .and. ! lCritica

				cSQL := "SELECT BBD_DATA,BBD_TIPO,BBD_CID,BBD_HORA FROM "+RetSQLName("BBD")
				cSQL += " WHERE BBD_FILIAL = '"+xFilial("BBD")+"' AND "
				cSQL += "       BBD_CODPAC = '"+cMatrUsr+"' AND "
				cSQL += "       BBD_CODESP = '"+aDadRDA[15]+"' AND "
				cSQL += "       BBD_DATA  >= '"+dUltimo+"' AND "
				cSQL += "       BBD_CODIGO = '"+aDadRDA[2]+"' AND "
				cSQL += "       BBD_CODINT = '"+subStr(cMatrUsr,1,4)+"' AND "
				cSQL += "       BBD_CODCAN = ' ' AND "

				if getNewPar("MV_PLBBDPR","0") == "1"
					cSQL += "BBD_CODPRO = '" +cCodPro+"' AND "
				endIf

				//Define se o CID sera considerado na regra de periodicidade. 1=Sim ou 0=Nao
				if getNewPar("MV_PLSVCID","0") == "1"
					cSQL += " BBD_CID <> '"+Space(len(BBD->BBD_CID))+"' AND "
				endIf

				cSQL += "D_E_L_E_T_ = ' '"
				cSQL += "ORDER BY BBD_DATA, BBD_HORA"

				dbUseArea(.t.,"TOPCONN",TCGENQRY(,,cSQL),"QRYBBD",.f.,.t.)

				TcSetField("QRYBBD","BDD_DATA","D",8,0)

				while !QRYBBD->(eof())

					// tratamento da revisão
					if QRYBBD->BBD_TIPO <>"2"

						aCalcPer := PLSCALCPER( cUniPer, dData, iIf(cUniPer<>"1",QRYBBD->BBD_DATA,QRYBBD->BBD_DATA+" "+strTran(QRYBBD->BBD_HORA, ":", "")), ;
							nPerioPer, @cUltimo, @cProximo, iIf( cUniPer<>"1",NIL, ;
							iIf (valType(aHorAge) == "A" .and. valType(oHorarios)<>"U", strTran(aHorAge[oHorarios:nAt,2],":",""),Subs(strTran(time(),":",""),1,4)) ) )

						if !aRet[1] .and. aRet[2] //lCritica
							Exit
						endIf

						dUltimo := QRYBBD->BBD_DATA
					endIf

					QRYBBD->(dbSkip())
				endDo

				QRYBBD->(dbCloseArea())
				if len(aCalcPer) > 0
					aRet[1]  := aCalcPer[1]
					lCritica := aCalcPer[2]
				endIf
			endIf
		endIf

		restArea(aArea)

		if !PLSCheckTEA(cMatric, cCid, cCdTbPd, cCodPro) .And. lCritica .and. ! aRet[1]

			if lPeriod

				PLSPOSGLO(cIntPad,__aCdCri161[1],__aCdCri161[2],cLocalExec)
				aadd(aRet[2],{__aCdCri161[1],PLSBCTDESC(),"B06", BCT->BCT_TIPO, BCT->BCT_NIVEL,cCdTbPd,cCodPro})
				aadd(aRet[2],{""   ,STR0104 + X3COMBO("BR8_UNPERI",cUniPer), Str(nPerioPer, 6),"","",cCdTbPd,cCodPro})  //"Existe periodicidade para realizar este procedimento de "

				if allTrim(cNivel) = allTrim(Str((__aNiveis[1]+1)))
					aadd(aRet[2],{""   ,STR0105+"   "+allTrim(cCodPro)+"   "+STR0094, cUltimo, "","",cCdTbPd,cCodPro})  //"Devido a realização de outro procedimento "###"em "
				else
					aadd(aRet[2],{""   ,STR0095+"   "+allTrim(cCodPro)+"   "+STR0094, cUltimo, "","",cCdTbPd,cCodPro})  //"Devido procedimento realizado do Grupo/SubGrupo "###"em "
				endIf

				aadd(aRet[2],{""   ,STR0096, cProximo, "","",cCdTbPd,cCodPro})  //"O procedimento poderá ser realizado somente em "

				if !empty(cOriMovNota)
					aadd(aRet[2],{""   ,STR0106+If(cOriMovNota$" ,1",STR0107,STR0041)+STR0042, Transform(cChaveNota,"@R !!!!.!!!!.!!!!!!!!-!!!!!!!!"), "","",cCdTbPd,cCodPro}) //"Numero da Conta de "###"Sadt/Consulta"###"Internacao"###" Gerada " //"Numero da Conta de "###"Sadt/Consulta/Odontológica"###"Internacao"###" Gerada "
				endIf

				if !empty(cNumImp)
					aadd(aRet[2],{""   ,STR0108, cNumImp, "","",cCdTbPd,cCodPro}) //"Impresso "	 					  	 //"Numero do Impresso"
				endIf

				if !empty(cDente)
					aadd(aRet[2],{""   ,STR0086, allTrim(cDente), "","",cCdTbPd,cCodPro}) //"Ultimo procedimento executado foi em " //"Dente"
				endIf

				if !empty(cFaces)
					aadd(aRet[2],{""   ,STR0087, cFaces, "","",cCdTbPd,cCodPro}) //"Faces"
				endIf

				// alias e caminho da critica.
				PLSCOMPCRI(aRet[2],cAlias,cChaveAut)

			else

				PLSPOSGLO(cIntPad,__aCdCri047[1],__aCdCri047[2],cLocalExec)
				aadd(aRet[2],{__aCdCri047[1],PLSBCTDESC(),"", BCT->BCT_TIPO, BCT->BCT_NIVEL,cCdTbPd,cCodPro,cSequen})
				aadd(aRet[2],{""   ,STR0036 + X3COMBO("BR8_UNPERI",cUniPer) + STR0031, Str(nPerioPer, 6),"","",cCdTbPd,cCodPro,cSequen}) //"A periodicidade permitida para o procedimento "###" foi excedida"
				aadd(aRet[2],{""   ,STR0037, cUltimo, "","",cCdTbPd,cCodPro,cSequen}) //"Ultimo procedimento executado foi em "
				aadd(aRet[2],{""   ,STR0038, cProximo, "","",cCdTbPd,cCodPro,cSequen}) //"Proximo procedimento podera ser executado em "

				if ! empty(cOriMovNota)
					aadd(aRet[2],{""   ,STR0106+If(cOriMovNota$" ,1",STR0107,STR0041)+STR0042, Transform(cChaveNota,"@R !!!!.!!!!.!!!!!!!!-!!!!!!!!"), "","",cCdTbPd,cCodPro,cSequen}) //"Numero da Conta de "###"Sadt/Consulta"###"Internacao"###" Gerada " //"Numero da Conta de "###"Sadt/Consulta/Odontológica"###"Internacao"###" Gerada "
				endIf

				if ! empty(cNumImp)
					aadd(aRet[2],{""   ,STR0108, cNumImp, "","",cCdTbPd,cCodPro,cSequen}) //"Numero do Impresso"
				endIf

				if ! empty(cDente)
					aadd(aRet[2],{""   ,STR0086, allTrim(cDente), "","",cCdTbPd,cCodPro,cSequen}) //"Ultimo procedimento executado foi em " //"Dente"
				endIf

				if ! empty(cFaces)
					aadd(aRet[2],{""   ,STR0087, cFaces, "","",cCdTbPd,cCodPro,cSequen}) //"Faces"
				endIf

				// alias e caminho da critica.
				PLSCOMPCRI(aRet[2],cAlias,cChaveAut)

			endIf

		endIf

		restArea(aArea)

		// Para quando aRet[1] correspondente a autorização vier falso no início da
		// função, continuará falso para poder criticar corretamente.
		if !lAutIni .and. aRet[1]
			aRet[1] := lAutIni
		endIf

	return aRet

	/*/{Protheus.doc} PLSClascar
Verifica se tem classe de carencia e retorna
@type function
@author Wagner Mobile Costa
@since 20.06.03
@param aCarencia, array, 	[1] = Unidade de contagem da carencia
[2] = Quantidade de carencia da unidade acima
[3] = Nivel da Classe de Carencia
[4] = Classe da carencia informada
[5] = Codigo da Operadora
[6] = Data base de carencia
[7] = Existia regra sim ou nao (novo)
@version 1.0
	/*/
	function PlsClascar(aCarencia,aDadUsr,cCdTbPd,cCodPro,cOpeUsr,cCodPla,cVersao,lVerBDL,cAliasAut,cChaveAut)
		local cAlias	:= ''
		local cClascar  := aCarencia[4]
		local cTipoUsr  := aDadUsr[8]
		local lOK       := .f.
		local cCodEmp   := Subs(aDadUsr[2],5,4)
		local cConEmp   := aDadUsr[9]
		local cVerCon   := aDadUsr[39]
		local cSubCon   := aDadUsr[41]
		local cVerSub   := aDadUsr[42]
		local cMatricU  := aDadUsr[2]
		local cMatric   := Subs(cMatricU,atMatric[1],atMatric[2])
		local cTipoReg  := Subs(cMatricU,atTipReg[1],atTipReg[2])
		local aRetCla	:= {}
		local lCond		:= .t.

		default cCodPla   := aDadUsr[11]
		default cVersao   := aDadUsr[12]
		default lVerBDL   := .t.
		default cAliasAut := ""
		default cChaveAut := ""

		if existBlock("PLCLACAR")
			aRetCla   := execBlock("PLCLACAR",.f.,.f.,{aCarencia,lOK,aDadUsr,cCdTbPd,cCodPro,cOpeUsr,cCodPla,cVersao,lVerBDL,cAliasAut,cChaveAut})
			aCarencia := aClone(aRetCla[1])
			lOK       := aRetCla[2]
		endIf

		//Verifica usuario
		BFO->(dbSetOrder(1))
		if BFO->(msSeek(xFilial("BFO")+cOpeUsr+cCodEmp+cMatric+cTipoReg+cClascar))

			aCarencia[1] := BFO->BFO_UNICAR
			aCarencia[2] := BFO->BFO_CARENC

			if len(aCarencia) >= 6 .and. BFO->(FieldPos("BFO_DATCAR")) > 0 .and. ! empty(BFO->BFO_DATCAR)
				aCarencia[6] := BFO->BFO_DATCAR
			endIf

			lOK := .t.
		endIf

		//Verifica no grupo de cobertura do usuario
		if ! lOK .and. cAliasAut == "BFE"

			BVI->(dbSetOrder(1))
			if BVI->(msSeek(xFilial("BVI")+cChaveAut))

				aCarencia[1] := BVI->BVI_UNCAR
				aCarencia[2] := BVI->BVI_QTDCAR

				if len(aCarencia) >= 6 .and. BVI->(FieldPos("BVI_DATCAR")) > 0 .and. ! empty(BVI->BVI_DATCAR)
					aCarencia[6] := BVI->BVI_DATCAR
				endIf

				lOK := .t.
			endIf

		endIf

		//Verifica familia
		if ! lOK

			BFJ->(dbSetOrder(1))
			if BFJ->(msSeek(xFilial("BFJ")+cOpeUsr+cCodEmp+cMatric+cClascar))
				aCarencia[1] := BFJ->BFJ_UNICAR
				aCarencia[2] := BFJ->BFJ_CARENC
				lOK := .t.
			endIf

		endIf

		if ! lOK .and. cTipoUsr == "2"

			//Verifica no subcontrato
			BA6->(dbSetOrder(1))

			lCond := BA6->(msSeek(xFilial("BA6")+cOpeUsr+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodPla+cVersao+cClascar))

			if lCond
				aCarencia[1] := BA6->BA6_UNICAR
				aCarencia[2] := BA6->BA6_CARENC
				lOK := .t.
			endIf

		endIf

		//Verifica no produto do usuario
		if ! lOK

			BAN->(dbSetOrder(1))
			if BAN->(msSeek(xFilial("BAN")+cOpeUsr+cCodPla+cVersao+cClascar))
				aCarencia[1] := BAN->BAN_UNCAR
				aCarencia[2] := BAN->BAN_QTDCAR
				lOK := .t.
			endIf

		endIf

		if (! lOK .Or. funname() == "PLSA094D") .and. lVerBDL   // quando eh chamada pela rotina de Grupo  de Carencia, nao verifica o nivel BDL-Classe de Carencia

			BDL->(dbSetOrder(1))

			if BDL->(msSeek(xFilial("BDL") + aCarencia[5] + aCarencia[4]))
				aCarencia[1] := BDL->BDL_UNCAR
				aCarencia[2] := BDL->BDL_CARENC
			endIf

		endIf

		if len(aCarencia) >= 7
			aCarencia[7] := lOK  //Somente pode estar lOK se existe nivel especifico (que sao todos menos o BDL)
		endIf

	return aCarencia

	/*/{Protheus.doc} PLSVLDPTP
Valida a existencia do procedimento na tabela padrao
@type function
@author tuliocesar
@since 20.04.00
@version 1.0
	/*/
	function PLSVLDPTP(cCdTbPd, cCodPro, cLocalExec, cTpLocExec, cCodRda, cTipGuia, dData, aComEve, lMudFase, cFinAte)
		local cNivel	:= ""
		local cDesPro	:= ""
		local aRet		:= {}
		local cIntPad 	:= plsIntPad()

		default cTpLocExec  := ""
		default cCodRda		:= ""
		default cTipGuia	:= ""
		default dData		:= ctod("")
		default aComEve		:= {}
		default lMudFase	:= .f.
		default cFinAte		:= ""

		// Verifica se existe o procedimento...
		BR8->( dbSetOrder(1) )
		if ! BR8->( msSeek(xFilial("BR8") + cCdTbPd + cCodPro) )

			PLSPOSGLO(cIntPad,__aCdCri055[1],__aCdCri055[2],cLocalExec,nil,cTpLocExec)

			aadd(aCodCri,{__aCdCri055[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
			aadd(aCodCri,{"",STR0047,cCodPro,"","",cCdTbPd,cCodPro}) //"Procedimento Informado"

			// alias e caminho da critica.
			PLSCOMPCRI(aCodCri,"BR8")

			aRet := {.f.,aCodCri,"BR8","",.f.}

		else

			if BR8->BR8_PROBLO == "1"

				PLSPOSGLO(cIntPad,__aCdCri060[1],__aCdCri060[2],cLocalExec,nil,cTpLocExec)

				aadd(aCodCri,{__aCdCri060[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
				aadd(aCodCri,{"",STR0047,cCodPro,"","",cCdTbPd,cCodPro}) //"Procedimento Informado"

				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"BR8")
				aRet := {.f.,aCodCri,"BR8","",.f.}

			elseIf BR8->BR8_ANASIN <> "1"

				PLSPOSGLO(cIntPad, __aCdCri068[1],__aCdCri068[2],cLocalExec,nil,cTpLocExec)

				aadd(aCodCri,{__aCdCri068[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
				aadd(aCodCri,{"",STR0047,cCodPro,"","",cCdTbPd,cCodPro}) //"Procedimento Informado"

				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"BR8")

				aRet := {.f.,aCodCri,"BR8","",.f.}

			else
				cDesPro := BR8->BR8_DESCRI
				cNivel  := BR8->BR8_NIVEL
				aRet := {.t.}
			endIf

		endIf

		if aRet[1] .and. ! lMudFase

			If BR8->BR8_ODONTO == '1' .And. cTipGuia <> G_ODONTO
				cTipGuia:= G_ODONTO
			EndIF

			aComEve := PLSCOMEVE('', cCdTbPd, cCodPro, cIntPad, dData, cTipGuia, nil, nil, cCodRda, nil, nil, nil,nil,nil,nil,nil,nil,cFinAte)

			//Verifica se existe composicao para o procedimento
			if len(aComEve) == 0

				PLSPOSGLO(cIntPad, __aCdCri028[1],__aCdCri028[2],cLocalExec,nil,cTpLocExec)

				aadd(aCodCri,{__aCdCri028[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
				aadd(aCodCri,{"",STR0047,cCodPro,"","",cCdTbPd,cCodPro}) //"Procedimento Informado"

				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"BD4")

				aRet := { .f., aCodCri, "BD4", "", .f. }

			endIf

		endIf

		if existBlock("PLSVLDP1")
			aRet := execBlock("PLSVLDP1",.f.,.f.,{cCdTbPd,cCodPro,cLocalExec,aRet})
		endIf

	return(aRet)

	/*/{Protheus.doc} PLSVLDGEN
Realiza uma validacao generica
@type function
@author tuliocesar
@since 17.01.04
@version 1.0
	/*/
	function PLSVLDGEN(	__aNiveis,nNiveis,cAlias,cChaveAux,cChavePro,cSexo,cCodInt,dData,cHora,dDatCar,cCdTbPd,cCodPro,;
			nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,cLocalExec,aDadRda,nIdade,cOpeSol,cCodPRFSol,lTratRda,;
			cGuiaOpe,cGuiaEmp,cCodPla,cVersao,cNumeroGuia,cTpLocExec,cFaces,cAliasAut,cChaveAut,cRdaEDI,cAreaAbr,;
			cDente,aFaces,aQtdBrow,aVldGen,cChavGui,cSequen,aBD7,cEspSol,cEspExe,lMenorNiv, cChavLib,cTipoProc)
		local aArea			:= getArea()
		local nInd			:= 0
		local nfor			:= 0
		local nPos      	:= 0
		local nPerioPer		:= 0
		local cChave		:= ''
		local bChaveProc	:= { || If(nfor == 1,cCodPro,Subs(cCodPro,__aNiveis[2,(nfor-1),1],__aNiveis[2,(nfor-1),2])) }
		local aRetGer   	:= {.f.}
		local cFilSeek  	:= xFilial(cAlias)
		local lAchou		:= .f.
		local bAddCriPad	:= { || PLSPOSGLO(PLSINTPAD(),__aCdCri001[1],__aCdCri001[2],cLocalExec), aadd(aCodCri,{__aCdCri001[1],PLSBCTDESC(),cCdTbPd+"-"+cCodPro,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro}) }
		local dDatCarEsp	:= ctod("")
		local aQtd      	:= {}
		local aPerio    	:= {}

		local cCodRda   	:= iIf(lTratRDA,( iIf(len(aDadRda)>2,aDadRda[2],"" ) ),"")
		local cNivCalc		:= ""
		local cUniPerio		:= ""
		local aCarencia 	:= {"","","","",cCodInt,dDatCarEsp,.f.}
		local lBR8_UNIMIN 	:= BR8->(FieldPos('BR8_UNIMIN')) > 0
		local lBR8_UNIMAX 	:= BR8->(FieldPos('BR8_UNIMAX')) > 0
		local lGruAuto		:= .F.

		default lTratRda    := .t.
		default cGuiaOpe    := ""
		default cGuiaEmp    := ""
		default cCodPla     := ""
		default cVersao     := ""
		default cNumeroGuia := ""
		default cTpLocExec  := ""
		default cFaces      := ""
		default cAliasAut   := cAlias
		default cChaveAut   := cChaveAux
		default cRdaEDI     := ""
		default cAreaAbr	:= ""
		default cDente		:= ""
		default aFaces      := {}
		default aQtdBrow	:= {}
		default aVldGen		:= {}
		default cChavGui    := ""
		default cSequen		:= ""
		default aBd7		:= {}
		default cEspSol		:= ''
		default	cEspExe		:= ''
		default lMenorNiv	:= .f.
		default cChavLib  	:= ''
		default cTipoProc	:= ""

		// Checagem do nivel
		for nfor := 1 to nNiveis

			cChave := cFilSeek + cChaveAux + eval(bChaveProc)

			(cAlias)->(dbSetOrder(nFor))
			if (cAlias)->(msSeek(cChave))

				if nfor == 1
					lAchou 		:= .t.
					lMenorNiv	:= .t.
				else
					lAchou := ( __aNiveis[2,(nfor-1),3] == (cAlias)->&(cAlias + "_NIVEL") )
				endIf

			else
				lAchou := .f.
			endIf

			if lAchou .and. lMenorNiv .and.  nfor > 1
				//Esse tratamento se dá para os casos onde foi encontrando o procedimento no nivel 4 no menor nivel,
				//o sistema nao pode subir o nivel, e fazer outra autorização, pois temos casos em que após encontrado
				// no nivel 4 e para enviar para auditoria o sistema nao pode subir o nivel e autorizar o procedimento
				lAchou := .f.
			endIf

			// Se achou e esta ativo
			if lAchou .and. &(cAlias+"->"+cAlias+"_BENUTL") == "1"

				dDatCarEsp := dDatCar

				if (cAlias)->( fieldPos(cAlias+"_DATCAR") ) > 0

					if ! empty( &(cAlias+"->"+cAlias+"_DATCAR") )
						dDatCarEsp := &(cAlias+"->"+cAlias+"_DATCAR")
					endIf

				endIf

				// Testa Idade Maxima/Minima, Sexo...
				if len(aQtd) == 0
					aQtd := PlRetPaQtd(cAlias)
				endIf

				if len(aPerio) == 0
					aPerio := PlRetPaPer(cAlias)
				endIf

				//Se a periodicidade varia por idade
				if &(cAlias+"->"+cAlias+"_DIFIDA") = '1'

					//As chaves na tabela de Period. dif. por idade são baseadas nos indices 1 de cada alias...
					//Se for criada uma chave diferente do indice, deve-se inclui-la como exceção nesta parte que busca a chave
					SIX->(dbSetOrder(1)) //INDICE+ORDEM
					if SIX->(msSeek(cAlias+"1"))
						cChavePer := &(cAlias+ "->(" + allTrim(SIX->CHAVE) + ")")
					endIf

					aRetIdade := PLBUSDIFID(cAlias,cChavePer,aDadUsr[26],nPerioPer,cUniPerio)
					nPerioPer := aRetIdade[1]
					cUniPerio := aRetIdade[2]
				else
					nPerioPer := &(cAlias+"->"+cAlias+"_PERIOD")
					cUniPerio := &(cAlias+"->"+cAlias+"_UNPERI")
				endIf

				//Verifica se existe carencia parametrizada no nivel de grupos determinados do subcontrato
				if cAliasAut == "BT7" .and. !empty(&(cAliasAut+"->"+cAliasAut+"_UNCAR"))
					aCarencia := {BT7->BT7_UNCAR,BT7->BT7_CARENC,"","",cCodInt,dDatCarEsp,.f.}
					BFO->(dbSetOrder(1))
					If BFO->(dbSeek(xFilial("BFO")+cCodInt+left(cMatrUsr,4)+subStr(cMatrUsr,5,6)))
						aCarencia[2] := BFO->BFO_CARENC
					endIf
				else
					aCarencia := {&(cAlias+"->"+cAlias+"_UNCAR"),&(cAlias+"->"+cAlias+"_CARENC"),&(cAlias+"->"+cAlias+"_NIVCAR"), &(cAlias+"->"+cAlias+"_CLACAR"),cCodInt,dDatCarEsp,.f.}
				endIf

				lGruAuto := IIf (cAlias =="BG8" .and. &(cAlias+"->"+cAlias+"_AUTORI") =="3",.T., .F.)

				aRetFun := PLSVLDAut(nIdade,&(cAlias+"->"+cAlias+"_IDAMIN"),&(cAlias+"->"+cAlias+"_IDAMAX"),;
					&(cAlias+"->"+cAlias+"_SEXO"),cSexo,aCarencia,dData,cHora,dDatCarEsp,;
					cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,&(cAlias+"->"+cAlias+"_NIVEL"),;
					&(cAlias+"->"+cAlias+"_QTD"),&(cAlias+"->"+cAlias+"_UNCA"),nPerioPer,;
					cUniPerio,&(cAlias+"->"+cAlias+"_AUTORI"),cLocalExec,aDadRDA,cOpeSol,;
					cCodPRFSol,lTratRda,cGuiaOpe,cGuiaEmp,cCodPla,cVersao,cNumeroGuia,;
					cTpLocExec,cFaces,cAliasAut,cChaveAut,aQtd,aPerio,cRdaEDI,cAreaAbr,;
					cDente,aFaces,aQtdBrow,aVldGen,cChavGui,cSequen,aBD7,cEspSol,cEspExe,;
					iIf(lBR8_UNIMIN,BR8->BR8_UNIMIN,''),iIf(lBR8_UNIMAX,BR8->BR8_UNIMAX,''),cChavLib,lGruAuto,cTipoProc)

				restArea(aArea)

				if ! aRetFun[1]

					for nInd := 1 to len(aRetFun[2])

						nPos := ascan(aCodCri,{|x| 	(x[1] == aRetFun[2,nInd,1]) .and. ;
							(x[2] == aRetFun[2,nInd,2]) .and. ;
							(x[3] == aRetFun[2,nInd,3]) .and. ;
							(x[4] == aRetFun[2,nInd,4]) .and. ;
							(x[5] == aRetFun[2,nInd,5]) .and. ;
							(x[6] == cCdTbPd) 			.and. ;
							(x[7] == cCodPro) })

						if nPos == 0
							aadd(aCodCri,{aRetFun[2,nInd,1],aRetFun[2,nInd,2],aRetFun[2,nInd,3],aRetFun[2,nInd,4],aRetFun[2,nInd,5],cCdTbPd,cCodPro,If(len(aRetFun[2,nInd])>=8,aRetFun[2,nInd,8],'')})
						endIf

					next

					aRetGer := {.t.,eval(__bRetErr,cAliasAut,cChaveAuT)}
					exit

				endIf

				// Procedimento autorizado...
				aRetGer := {.t.,eval(__bRetAut,&(cAlias+"->"+cAlias+"_AUTORI"),cAliasAut,cChave)}

				exit

				// Se achou e nao esta ativo
			elseIf lAchou .and. &(cAlias+"->"+cAlias+"_BENUTL") == "0"

				// Verifica se a critica por rda
				if PLSCHKCRI( {'BAU',cCodRda,__aCdCri001[1]} )

					restArea(aArea)

					if ascan(aCodCri,{|x| x[1] == __aCdCri001[1]}) == 0

						eval(bAddCriPad)

						PLSCOMPCRI(aCodCri,cAliasAut)

					endIf

					aRetGer := { .t.,eval(__bRetErr,cAliasAut,cChaveAut) }

					exit

				else

					aRetGer := {.t.,eval(__bRetAut,&(cAlias+"->"+cAlias+"_AUTORI"),cAliasAut,cChaveAut)}

					exit

				endIf

			endIf

		next

	return(aRetGer)

	/*/{Protheus.doc} PLSVLDGRU
Valida o grupo de cobertura em um determinado nivel
@type function
@author tuliocesar
@since 17.01.04
@version 1.0
	/*/
	function PLSVLDGRU( cAlias,cChaveAux,cSexo,cCodInt,dData,cHora,dDatCar,cCdTbPd,cCodPro,;
			nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,cLocalExec,aDadRda,nIdade,cOpeSol,cCodPRFSol,lTratRda,;
			cGuiaOpe,cGuiaEmp,cCodPla,cVersao,cNumeroGuia,cTpLocExec,cFaces,cAreaAbr,cDente,aFaces,aQtdBrow,;
			aVldGen,cChavGui,cRdaEDI,cSequen,aBD7,cEspSol,cEspExe,cRegInt,cTipoProc)
		local aRetGer   	:= {.f.}
		local aRetFun		:= {}
		local aArea			:= getArea()
		local cFilSeek  	:= xFilial(cAlias)
		local lAchou		:= .f.
		local nLenChave 	:= len(cFilSeek+cChaveAux)
		local lNegado   	:= .f.
		local aCriSlv		:= {}
		local dDatCarEsp	:= ctod("")
		local cCodGruNeg    := ""
		local lMenorNiv		:= .f. // Caso ele ache em menor nivel e esta para auditoria ele nao pode subir o nivel e autorizar sem ir para auditoria e ou como ele ja ahou em menor nivel nao precisa subir

		private lConcat		:= .t. 	//Variável para que, caso o ponto de entrada PLSGCOBA seja utilizado e já retorne a chave com o
		//Código do grupo, o desenvolovedor possa impedir que o sistema concatene novamente o _CODGRU da tabela na chave.

		default lTratRda    := .t.
		default cGuiaOpe    := ""
		default cGuiaEmp    := ""
		default cCodPla     := ""
		default cVersao     := ""
		default cNumeroGuia := ""
		default cTpLocExec  := ""
		default cFaces		:= ""
		default cAreaAbr 	:= ""
		default cDente		:= ""
		default aFaces      := {}
		default aQtdBrow	:= {}
		default aVldGen     := {}
		default cChavGui    := ""
		default cRdaEDI     := ""
		default cSequen		:= ""
		default aBd7		:= {}
		default cEspSol 	:= ''
		default cEspExe		:= ''
		default cRegInt		:= ''
		default cTipoProc	:= ""

		//Ponto de Entrada
		if existBlock("PLSGCOBA")

			cChaveAux := execBlock("PLSGCOBA",.f.,.f.,{ cAlias, cFilSeek, cChaveAux, cCdTbPd,cCodPro,cMatrUsr,cNumeroGuia,dData,cCodInt,aDadRda,nQtd,cRegInt})
			nLenChave := len(cFilSeek + cChaveAux)

		endIf

		(cAlias)->(dbSetOrder(1))

		if (cAlias)->(msSeek( cFilSeek + cChaveAux ) )

			while ! (cAlias)->(eof()) .and. subs( ( (cAlias)->( &(indexKey()) ) ),1,nLenChave) == subs( cFilSeek + cChaveAux ,1,nLenChave)

				dDatCarEsp := dDatCar

				if (cAlias)->(FieldPos(cAlias+"_DATCAR")) > 0

					if ! empty( (cAlias)->( &(cAlias + "_DATCAR") ) )
						dDatCarEsp := (cAlias)->( &(cAlias + "_DATCAR") )
					endIf

				endIf

				aRetFun := PLSGRUCOB(cCodInt,(cAlias)->( &(cAlias + "_CODGRU") ),cCdTbPd,cCodPro,nIdade,cSexo,dData,cHora,dDatCarEsp,;
					nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,cLocalExec,aDadRda,cOpeSol,cCodPRFSol,lTratRda,;
					cGuiaOpe,cGuiaEmp,cCodPla,cVersao,cNumeroGuia,cTpLocExec,cFaces,cAlias,cChaveAux,cAreaAbr,;
					cDente,aFaces,aQtdBrow,aVldGen,cChavGui,cRdaEDI,cSequen,aBD7,cEspSol,cEspExe,@lMenorNiv,cTipoProc)

				if valType(aRetFun) == "A"

					if aRetFun[1]

						restArea(aArea)

						if lConcat
							aRetGer := {.t.,eval(__bRetAut,aRetFun[2],cAlias,cChaveAux + (cAlias)->( &(cAlias + "_CODGRU") ) ) }
						else
							aRetGer := {.t.,eval(__bRetAut,aRetFun[2],cAlias,cChaveAux)}
						endIf

						return(aRetGer)

					else

						cCodGruNeg := (cAlias)->( &(cAlias + "_CODGRU") )
						lNegado    := .t.
						aCriSlv    := aClone(aRetFun[2])

					endIf

				endIf

				(cAlias)->(dbSkip())
			endDo

			if lNegado

				restArea(aArea)

				aCodCri := aClone(aCriSlv)

				if lConcat
					aRetGer := { .t., eval(__bRetErr,cAlias,cChaveAux+cCodGruNeg) }
				else
					aRetGer := { .t., eval(__bRetErr,cAlias,cChaveAux) }
				endIf

				return(aRetGer)

			endIf

		endIf

		restArea(aArea)

	return(aRetGer)

	/*/{Protheus.doc} PLSVLDGLC
Realiza uma validacao generica
@type function
@author tuliocesar
@since 17.01.04
@version 1.0
	/*/
	function PLSVLDGLC(__aNiveis,nNiveis,cAlias,cChaveAux,cCodPro,lTrtRdaAte,cTipoRdaAte)
		local nfor
		local cChave
		local bChaveProc:= { || If(nfor == 1,cCodPro,Subs(cCodPro,__aNiveis[2,(nfor-1),1],__aNiveis[2,(nfor-1),2])) }
		local aRetGer   := {.f.}
		local cFilSeek  := xFilial(cAlias)
		local lAchou    := .f.
		default lTrtRdaAte := .f.

		for nfor := 1 to nNiveis

			cChave := cFilSeek+cChaveAux+eval(bChaveProc)

			dbSelectArea(cAlias)
			dbSetOrder(nfor)
			msSeek(cChave)

			if Found()
				lAchou := .t.

				if lTrtRdaAte
					if &(cAlias+"->"+cAlias+"_TIPO") == "3" .or. &(cAlias+"->"+cAlias+"_TIPO")  == cTipoRdaAte
						Exit
					else
						lAchou := .f.
						Exit
					endIf
				else
					Exit
				endIf
			endIf
		next

		aRetGer := {If(lAchou,.t.,.f.)}

	return(aRetGer)


	/*/{Protheus.doc} PLSTRATSUB
@type function
@author tuliocesar
@since 21/03/12
@version 1.0
	/*/
	function PLSTRATSUB(cOpeRda,cCodEsp,cCdTbPd,cCodPro,__aNiveis)
		local nfor
		local cSQL
		local cNameBBM := RetSQLName("BBM")
		local cFilBBM  := xFilial("BBM")
		local lOK      := .f.
		local nNiveis   := (__aNiveis[1]+1)
		local aArea    := GetArea()

		cSQL := "SELECT BBM_TIPO FROM "+cNameBBM+" WHERE "
		cSQL += "BBM_FILIAL = '"+cFilBBM+"' AND "
		cSQL += "BBM_CODINT = '"+cOpeRDA+"' AND "
		cSQL += "BBM_CODESP = '"+cCodEsp+"' AND "
		cSQL += "BBM_CODPAD = '"+cCdTbPd+"' AND "

		cSQL += PLREQNI("BBM", "BBM_CODPSA", __aNiveis[2], cCodPro)
		cSQL += "BBM_SUBSID = '1' AND "

		cSQL +=  cNameBBM+".D_E_L_E_T_ = ' ' "

		cSQL +=  " ORDER BY BBM_NIVEL DESC "

		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSTRATSUB",.f.,.t.)

		if ! PLSTRATSUB->(eof())
			lOK := .t.
		endIf

		PLSTRATSUB->(DbCloseArea())
		RestArea(aArea)

	return({lOK})

	/*/{Protheus.doc} PLSVLDPRI
Valida procedimentos incompativeis e cid imcompativel
@type function
@author tuliocesar
@since 20.04.00
@version 1.0
	/*/
	function PLSVLDPRI(	cCid,cLocalExec,aCodsProcs,aDadUsr,dDatPro,lRPC,cOpeRDA,cCodRDA,cCodPad,;
			cCodProc,cSequen,aRet,cFace,cDenReg,nRegBD6,cNumeroGuia,cProRel,nPrPrRl,cCritAux,lTemB26,lTemBJ4,lVerIncopat)
		local nNiveis	:= 0
		local nfor		:= 0
		local nAux 		:= 1  // iniciando como 1 como default
		local nInd		:= 0
		local lRet      := .t.
		local cSQL		:= ""
		local cNameBJ4  := RetSQLName("BJ4")
		local cNameB26  := RetSQLName("B26")
		local cFilBJ4   := xFilial("BJ4")
		local cFilB26   := xFilial("B26")
		local cNameBAA  := RetSQLName("BAA")
		local cFilBAA   := xFilial("BAA")
		local lExiste   := .f.
		local lFlag     := .f.
		local aProcInc  := {}
		local cCdTbPd   := ""
		local cCodPro   := ""
		local cCodProd  := ""
		local cCdTabPd  := ""
		local _cCdTbPd  := ""
		local _cCodPro  := ""
		local _cDenReg  := ""
		local _cFace    := ""
		local cCodAux   := ""
		local cChave    := ""
		local cChave2   := ""
		local nOrdBA0   := BA0->(indexOrd())
		local nRecBA0   := BA0->(recno())
		local nOrdBR8   := BR8->(indexOrd())
		local nRecBR8   := BR8->(recno())
		local nOrdBA9    := BA9->(indexOrd())
		local nRecBA9    := BA9->(recno())
		local bRest      := { || BR8->(dbSetOrder(nOrdBR8)), BR8->(dbGoto(nRecBR8)), BA9->(dbSetOrder(nOrdBA9)), BA9->(dbGoto(nRecBA9)), BA0->(dbSetOrder(nOrdBA0)), BA0->(dbGoto(nRecBA0)) }
		local nPos		 := 0
		local cTratLim	 := ""
		local nLimCH	 := 0
		local aCompo	 := {}
		local nQtdCH     := 0
		local cCodTab 	 := ""
		local cAno    	 := ""
		local cMes    	 := ""
		local cIntPad 	 := PLSINTPAD()
		local nQtd  	 := 1
		local nDias		 := 0
		local cChave3    := ""
		local cChave4    := ""
		local cCodCri	 := ""
		local lFieldsB08 := PLSaliasEX("B08") .and. (B08->( FieldPos("B08_QUANTI") ) > 0 .and. B08->( FieldPos("B08_UNIDAD") ) > 0)
		local lCposB08   := PLSaliasEX("B08") .and. (B08->( FieldPos("B08_EXCETO") ) > 0 .and. B08->( FieldPos("B08_PERIOD") ) > 0)
		local lCposB87   := PLSaliasEX("B87") .and. (B87->( FieldPos("B87_EXCETO") ) > 0 .and. B87->( FieldPos("B87_PERIOD") ) > 0)
		local cVldMatVid := getNewPar("MV_PLSMTVD", "1")
		local cSentido 	 := getNewPar("MV_PLSSENT", "1")
		local cAliascrit := ""
		local cNumImp    := ""
		local aRangeDt   := {}
		local lCri       := .f.
		local nD	     := 0
		local lWeb			:=(funName()=="RPC")
		Local lEhDaqui	:= .F.

		default dDatPro  := dDataBase
		default lRPC	 := .f.
		default cOpeRDA  := ""
		default cCodRDA  := ""
		default cCodPad  := ""
		default cCodProc := ""
		default cSequen  := ""
		default aRet	 := {.t.}
		default cFace	 := ""
		default	cDenReg  := ""
		default cProRel  := ""
		default nPrPrRl  := 0
		default nRegBD6	 := 0
		default cNumeroGuia := ""
		default cCritAux	:= ""
		default lTemB26	 :=.f.
		default lTemBJ4	 :=.f.
		default lVerIncopat :=.T.

		// cVldMatVid: Variavel que contem a definição do parametro MV_PLSMTVD e que determina se a
		// verificação da incompatibilidade sera feita pela matricula do usuario ou se sera feita pela vida dele.

		// cSentido: Variavel que contem a definição do parametro MV_PLSSENT se a verificação será nos dois sentidos, ou se será de sentido unico.
		// Sentido Duplo: Quando informar um procedimento incompativel, nao importa qual dois dois for executado primeiro, ao executar o segundo o sistema ira criticar.
		// Sentido Unico: Nesse caso, o sistema ira verificar na sequencia cadastrada.


		// Ajusta o tamanho da variavel de procedimento. Ela tem que ter o mesmo tamanho do campo BR8_CODPSA, caso contrario,
		// Todas as chaves de busca por msSeek falham.
		cCodProc := allTrim(cCodProc)+Space( (tamSx3("BR8_CODPSA")[1]-len(allTrim(cCodProc))) )

		if empty(dDatPro)
			dDatPro := dDataBase
		endIf
		// Se for usuario de intercambio nao faz nada
		if len(aDadUsr)>1 .and. len(aDadUsr)>=45 .and. aDadUsr[45] != PlsIntPaD()
			return(aRet)
		endIf

		// Se o Registro ja foi auditado, nao verifica novamente...
		if nRegBD6 > 0
			if BD6->(FieldPos("BD6_AUDITA")) > 0
				if !empty(cNumeroGuia) .and. BD6->BD6_AUDITA == "1"
					return(aRet)
				endIf
			endIf
		endIf

		// verificar procedimentos incompativeis...
		// vou procurar no historico do usuario
		if (iIf(len(aDadUsr)>=1, aDadUsr[1], .f.)) .and. BR8->(msSeek(xFilial("BR8")+cCodPad+cCodProc))  .and. (BR8->BR8_ODONto == '1' .or. getNewPar("MV_PLSPRIM",.f.))

		// Nivel de procedimentos incompativeis.
		lFlag     := .f.
		cCdTbPd   := cCodPad
		cCodPro   := cCodProc

		// Incompatibilidade no nivel de procedimento
		if lTemBJ4

			cHoraInicio:= time()
			cHoraGer   := time()
			cSQL := "SELECT BD6_CODPAD,BD6_CODPRO,BD6_DENREG,BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO "

			if cVldMatVid == "2"	// Utiliza matricua da vida.
				cSql += "FROM "+RetSqlName("BJ4")+","+RetSqlName("BD6")+","+RetSqlName("BA1")+" WHERE "
			else
				cSql += "FROM "+RetSqlName("BJ4")+","+RetSqlName("BD6")+" WHERE "
			endIf

			cSQL += "BJ4_FILIAL = '"+xFilial("BJ4")+"' AND "
			cSQL += "BJ4_CODIGO = '"+cCdTbPd+cCodPro+"' AND "

			if cVldMatVid == "2"	// Utiliza matricua da vida.
				cSQL += "BA1_FILIAL = BD6_FILIAL AND "
				cSQL += "BA1_CODINT = BD6_OPEUSR AND "
				cSQL += "BA1_CODEMP = BD6_CODEMP AND "
				cSQL += "BA1_MATRIC = BD6_MATRIC AND "
				cSQL += "BA1_TIPREG = BD6_TIPREG AND "
				cSQL += "BA1_MATVID = '"+aDadUsr[5]+"' AND "

			else	// Utiliza verificação pela matricula do contrato.
				cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
				cSQL += "BD6_OPEUSR = '"+Subs(aDadUsr[2],atCodOpe[1],atCodOpe[2])+"' AND "
				cSQL += "BD6_CODEMP = '"+Subs(aDadUsr[2],atCodEmp[1],atCodEmp[2])+"' AND "
				cSQL += "BD6_MATRIC = '"+Subs(aDadUsr[2],atMatric[1],atMatric[2])+"' AND "
				cSQL += "BD6_TIPREG = '"+Subs(aDadUsr[2],atTipReg[1],atTipReg[2])+"' AND "
				cSQL += "BD6_DIGITO = '"+Subs(aDadUsr[2],atDigito[1],atDigito[2])+"' AND "

			endIf
			cSQL += "BD6_DATPRO > '"+dtos(dDatPro-getNewPar("MV_PLLIMID",360))+"' AND "

			cSQL += "((BD6_FASE = '3' OR BD6_FASE = '4') "

			cSQL += "OR  (  BD6_CODPEG = '"+BD6->BD6_CODPEG+"'AND BD6_FASE = '1'))  AND " // VERIFICANDO ITEM NA MESMA GUIA
			if existBlock("PLPERSIT")
				cSQL += execBlock("PLPERSIT",.f.,.f.)
				cSQL += " AND  "
			else
				cSQL += "( ( BD6_SITUAC = '1' ) OR ( BD6_SITUAC = '3' AND BD6_LIBERA = '1') )  AND BD6_STATUS <> '0' AND  "
			endIf
			if findFunction("PlReChvEst")
				aRetAux  := PlReChvEst("BD6",.t.,.f.,.t.,.f.)
				cSQL     += aRetAux[1]
			endIf
			cSQL += "BD6_FILIAL = BJ4_FILIAL AND "
			cSQL += "BD6_CODPAD = BJ4_CODPAD AND "//ainda nao estou tratando grupo/subgupo/item
			cSQL += "BD6_CODPRO = BJ4_CODPSA AND "
			cSQL += RetSqlName("BD6")+".D_E_L_E_T_ = ' ' AND "
			cSQL += RetSqlName("BJ4")+".D_E_L_E_T_ = ' ' "

			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSVLDPRI",.f.,.t.)

			while !PLSVLDPRI->(eof())

				lExiste  := .t.
				lFlag    := .t.
				aadd(aProcInc,{	cCdTbPd,;
					cCodPro,;
					PLSVLDPRI->BD6_CODPAD,;
					PLSVLDPRI->BD6_CODPRO,;
					"",;
					"",;
					PLSVLDPRI->(BD6_CODOPE+"."+BD6_CODLDP+"."+BD6_CODPEG+"."+BD6_NUMERO),;
					"",;
					"",;
					cSequen,;
					"",;
					"BJ4",;
					""})

				PLSVLDPRI->(dbSkip())
			endDo
			PLSVLDPRI->(DbCloseArea())

			if !lFlag .and. cSentido = "2"   .and. !lExiste

				// Incompatibilidade no nivel de procedimento
				//BJ4 X BD6
				cSQL := "SELECT BD6_CODPAD,BD6_CODPRO,BD6_DENREG,BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO "

				if cVldMatVid == "2"	// Utiliza matricua da vida.
					cSql += "FROM "+RetSqlName("BJ4")+","+RetSqlName("BD6")+","+RetSqlName("BA1")+" WHERE "
				else
					cSql += "FROM "+RetSqlName("BJ4")+","+RetSqlName("BD6")+" WHERE "
				endIf
				cSQL += "BJ4_FILIAL = '"+xFilial("BJ4")+"' AND "
				cSQL += "BJ4_CODPAD = '"+cCdTbPd+"' AND "
				cSQL += "BJ4_CODPSA = '"+cCodPro+"' AND "

				if cVldMatVid == "2"	// Utiliza matricua da vida.
					cSQL += "BA1_FILIAL = BD6_FILIAL AND "
					cSQL += "BA1_CODINT = BD6_OPEUSR AND "
					cSQL += "BA1_CODEMP = BD6_CODEMP AND "
					cSQL += "BA1_MATRIC = BD6_MATRIC AND "
					cSQL += "BA1_TIPREG = BD6_TIPREG AND "
					cSQL += "BA1_MATVID = '"+aDadUsr[5]+"' AND "

				else	// Utiliza verificação pela matricula do contrato.
					cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
					cSQL += "BD6_OPEUSR = '"+Subs(aDadUsr[2],atCodOpe[1],atCodOpe[2])+"' AND "
					cSQL += "BD6_CODEMP = '"+Subs(aDadUsr[2],atCodEmp[1],atCodEmp[2])+"' AND "
					cSQL += "BD6_MATRIC = '"+Subs(aDadUsr[2],atMatric[1],atMatric[2])+"' AND "
					cSQL += "BD6_TIPREG = '"+Subs(aDadUsr[2],atTipReg[1],atTipReg[2])+"' AND "
					cSQL += "BD6_DIGITO = '"+Subs(aDadUsr[2],atDigito[1],atDigito[2])+"' AND "
				endIf

				cSQL += "BD6_DATPRO > '"+dtos(dDatPro-getNewPar("MV_PLLIMID",360))+"' AND "
				cSQL += "((BD6_FASE = '3' OR BD6_FASE = '4') "

				cSQL += "OR  (  BD6_CODPEG = '"+BD6->BD6_CODPEG+"'AND BD6_FASE = '1'))  AND " // VERIFICANDO ITEM NA MESMA GUIA
				if existBlock("PLPERSIT")
					cSQL += execBlock("PLPERSIT",.f.,.f.)
					cSQL += " AND  "
				else
					cSQL += "( ( BD6_SITUAC = '1' ) OR ( BD6_SITUAC = '3' AND BD6_LIBERA = '1') )  AND BD6_STATUS <> '0' AND  "
				endIf
				if findFunction("PlReChvEst")
					aRetAux  := PlReChvEst("BD6",.t.,.f.,.t.,.f.)
					cSQL     += aRetAux[1]
				endIf
				cSQL += "BD6_FILIAL = BJ4_FILIAL AND "

				if TcGetDb() $ "DB2*ORACLE*POSTGRES"
					cSQL += "BD6_CODPAD || BD6_CODPRO = BJ4_CODIGO AND "
				else
					cSQL += "BD6_CODPAD + BD6_CODPRO = BJ4_CODIGO AND "
				endIf
				cSQL += RetSqlName("BD6")+".D_E_L_E_T_ = ' ' AND "
				cSQL += RetSqlName("BJ4")+".D_E_L_E_T_ = ' ' "

				dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSVLDPRI",.f.,.t.)

				while !PLSVLDPRI->(eof())

					lExiste  := .t.
					lFlag    := .t.

					aadd(aProcInc,{ cCdTbPd,;
						cCodPro,;
						PLSVLDPRI->BD6_CODPAD,;
						PLSVLDPRI->BD6_CODPRO,;
						"",;
						"",;
						PLSVLDPRI->(BD6_CODOPE+"."+BD6_CODLDP+"."+BD6_CODPEG+"."+BD6_NUMERO),;
						"",;
						"",;
						cSequen,;
						"",;
						"BJ4",;
						""})

					PLSVLDPRI->(dbSkip())
				endDo

				PLSVLDPRI->(DbCloseArea())
			endIf
		endIf

		//Inicio
		//B26 X BD6
		if lTemB26

			// Nivel de procedimentos incompativeis da RDA.
			if !lFlag   .and. !lExiste
				cCdTbPd   := cCodPad
				cCodPro   := cCodProc
				lFlag     := .f.

				// Incompatibilidade no nivel de procedimento da RDA.
				cSQL := "SELECT B26_QUANTI, B26_UNIDAD, B26_TPACAO, B26_VIGINI, B26_VIGFIN, BD6_DATPRO, BD6_CODPAD,BD6_CODPRO, "
				cSQL += "BD6_DENREG,BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO "

				if cVldMatVid == "2"	// Utiliza matricua da vida.
					cSql += " FROM "+RetSqlName("B26")+","+RetSqlName("BD6")+","+RetSqlName("BA1")+" WHERE "

				else
					cSql += " FROM "+RetSqlName("B26")+","+RetSqlName("BD6")+" WHERE "

				endIf

				cSQL += "B26_FILIAL = '"+xFilial("B26")+"' AND "
				cSQL += "B26_CODRDA = '"+cCodRDA+"' AND "
				cSQL += "B26_AUXPAD = '"+cCdTbPd+"' AND "
				cSQL += "B26_AUXPSA = '"+cCodPro+"' AND "

				if cVldMatVid == "2"	// Utiliza matricua da vida.
					cSQL += "BA1_FILIAL = BD6_FILIAL AND "
					cSQL += "BA1_CODINT = BD6_OPEUSR AND "
					cSQL += "BA1_CODEMP = BD6_CODEMP AND "
					cSQL += "BA1_MATRIC = BD6_MATRIC AND "
					cSQL += "BA1_TIPREG = BD6_TIPREG AND "
					cSQL += "BA1_MATVID = '"+aDadUsr[5]+"' AND "

				else	// Utiliza verificação pela matricula do contrato.
					cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
					cSQL += "BD6_OPEUSR = '"+Subs(aDadUsr[2],atCodOpe[1],atCodOpe[2])+"' AND "
					cSQL += "BD6_CODEMP = '"+Subs(aDadUsr[2],atCodEmp[1],atCodEmp[2])+"' AND "
					cSQL += "BD6_MATRIC = '"+Subs(aDadUsr[2],atMatric[1],atMatric[2])+"' AND "
					cSQL += "BD6_TIPREG = '"+Subs(aDadUsr[2],atTipReg[1],atTipReg[2])+"' AND "
					cSQL += "BD6_DIGITO = '"+Subs(aDadUsr[2],atDigito[1],atDigito[2])+"' AND "

				endIf

				cSQL += "(BD6_FASE = '3' OR BD6_FASE = '4') AND "
				if existBlock("PLPERSIT")
					cSQL += execBlock("PLPERSIT",.f.,.f.)
					cSQL += " AND  "
				else
					cSQL += "( ( BD6_SITUAC = '1' ) OR ( BD6_SITUAC = '3' AND BD6_LIBERA = '1') )  AND BD6_STATUS <> '0' AND  "
				endIf
				if findFunction("PlReChvEst")
					aRetAux  := PlReChvEst("BD6",.t.,.f.,.t.,.f.)
					cSQL     += aRetAux[1]
				endIf
				cSQL += "BD6_FILIAL = B26_FILIAL AND "
				cSQL += "BD6_CODPAD = B26_CODPAD AND "//ainda nao estou tratando grupo/subgupo/item
				cSQL += "BD6_CODPRO = B26_CODPSA AND "
				cSQL += RetSqlName("BD6")+".D_E_L_E_T_ = ' ' AND "
				cSQL += RetSqlName("B26")+".D_E_L_E_T_ = ' ' "

				dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSql)),"PLSVLDPRI",.f.,.t.)

				if !PLSVLDPRI->(eof())
					plsTField("PLSVLDPRI",.f.,{ "B26_QUANTI","BD6_DATPRO" } )
				endIf

				while !PLSVLDPRI->(eof())

					nDias 	:= PLSCalcDia(PLSVLDPRI->B26_QUANTI,PLSVLDPRI->B26_UNIDAD) // Calcula em dias

					// Analisa validade da regra.
					// Analisa Vigencia
					if dtos(PLSVLDPRI->BD6_DATPRO) >= dtos(dDatPro-nDias) .and. PLSINTval("B26","B26_VIGINI","B26_VIGFIN",dDatPro)

						lExiste  := .t.
						lFlag    := .t.
						aadd(aProcInc,{	cCdTbPd,;
							cCodPro,;
							PLSVLDPRI->BD6_CODPAD,;
							PLSVLDPRI->BD6_CODPRO,;
							"",;
							"",;
							PLSVLDPRI->(BD6_CODOPE+"."+BD6_CODLDP+"."+BD6_CODPEG+"."+BD6_NUMERO),;
							"",;
							"",;
							cSequen,;
							PLSVLDPRI->B26_TPACAO,;
							"B26",;
							""})
					endIf
					PLSVLDPRI->(dbSkip())
				endDo
				PLSVLDPRI->(DbCloseArea())

				if !lFlag .and. cSentido = "2" .and. !lExiste

					// Incompatibilidade no nivel de procedimento
					cSQL := "SELECT B26_VIGINI,B26_VIGFIN,B26_QUANTI,B26_UNIDAD,B26_TPACAO,BD6_DATPRO,BD6_CODPAD,BD6_CODPRO, "
					cSql += "BD6_DENREG,BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO "

					if cVldMatVid == "2"	// Utiliza matricua da vida.
						cSql += " FROM "+RetSqlName("B26")+","+RetSqlName("BD6")+","+RetSqlName("BA1")+" WHERE "

					else
						cSql += " FROM "+RetSqlName("B26")+","+RetSqlName("BD6")+" WHERE "

					endIf

					cSQL += "B26_FILIAL = '"+xFilial("B26")+"' AND "
					cSQL += "B26_CODRDA = '"+cCodRDA+"' AND "
					cSQL += "B26_CODPAD = '"+cCdTbPd+"' AND "
					cSQL += "B26_CODPSA = '"+cCodPro+"' AND "

					if cVldMatVid == "2"	// Utiliza matricua da vida.
						cSQL += "BA1_FILIAL = BD6_FILIAL AND "
						cSQL += "BA1_CODINT = BD6_OPEUSR AND "
						cSQL += "BA1_CODEMP = BD6_CODEMP AND "
						cSQL += "BA1_MATRIC = BD6_MATRIC AND "
						cSQL += "BA1_TIPREG = BD6_TIPREG AND "
						cSQL += "BA1_MATVID = '"+aDadUsr[5]+"' AND "

					else	// Utiliza verificação pela matricula do contrato.
						cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
						cSQL += "BD6_OPEUSR = '"+Subs(aDadUsr[2],atCodOpe[1],atCodOpe[2])+"' AND "
						cSQL += "BD6_CODEMP = '"+Subs(aDadUsr[2],atCodEmp[1],atCodEmp[2])+"' AND "
						cSQL += "BD6_MATRIC = '"+Subs(aDadUsr[2],atMatric[1],atMatric[2])+"' AND "
						cSQL += "BD6_TIPREG = '"+Subs(aDadUsr[2],atTipReg[1],atTipReg[2])+"' AND "
						cSQL += "BD6_DIGITO = '"+Subs(aDadUsr[2],atDigito[1],atDigito[2])+"' AND "

					endIf

					cSQL += "((BD6_FASE = '3' OR BD6_FASE = '4') "
					cSQL += "OR  (  BD6_CODPEG = '"+BD6->BD6_CODPEG+"'AND BD6_FASE = '1'))  AND " // VERIFICANDO ITEM NA MESMA GUIA
					if existBlock("PLPERSIT")
						cSQL += execBlock("PLPERSIT",.f.,.f.)
						cSQL += " AND  "
					else
						cSQL += "( ( BD6_SITUAC = '1' ) OR ( BD6_SITUAC = '3' AND BD6_LIBERA = '1') )  AND BD6_STATUS <> '0' AND  "
					endIf
					if findFunction("PlReChvEst")
						aRetAux  := PlReChvEst("BD6",.t.,.f.,.t.,.f.)
						cSQL     += aRetAux[1]
					endIf
					cSQL += "BD6_FILIAL = B26_FILIAL AND "
					cSQL += "BD6_CODPAD = B26_AUXPAD AND "//ainda nao estou tratando grupo/subgupo/item
					cSQL += "BD6_CODPRO = B26_AUXPSA AND "
					cSQL += RetSqlName("BD6")+".D_E_L_E_T_ = ' ' AND "
					cSQL += RetSqlName("B26")+".D_E_L_E_T_ = ' ' "

					dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSql)),"PLSVLDPRI",.f.,.t.)

					if !PLSVLDPRI->(eof())
						plsTField("PLSVLDPRI",.f.,{ "B26_QUANTI","BD6_DATPRO" } )
					endIf

					while !PLSVLDPRI->(eof())

						nDias := PLSCalcDia(PLSVLDPRI->B26_QUANTI,PLSVLDPRI->B26_UNIDAD) // Calcula em dias

						// Analisa validade da regra.
						// Analisa Vigencia
						if dtos(PLSVLDPRI->BD6_DATPRO) >= dtos(dDatPro-nDias) .and. PLSINTval("B26","B26_VIGINI","B26_VIGFIN",dDatPro)

							lExiste  := .t.
							lFlag    := .t.
							aadd(aProcInc,{ cCdTbPd,;
								cCodPro,;
								PLSVLDPRI->BD6_CODPAD,;
								PLSVLDPRI->BD6_CODPRO,;
								"",;
								"",;
								PLSVLDPRI->(BD6_CODOPE+"."+BD6_CODLDP+"."+BD6_CODPEG+"."+BD6_NUMERO),;
								"",;
								"",;
								cSequen,;
								PLSVLDPRI->B26_TPACAO,;
								"B26",;
								""})
						endIf

						PLSVLDPRI->(dbSkip())
					endDo
					PLSVLDPRI->(DbCloseArea())
				endIf
			endIf
		endIf

		endIf

		// Incompatibilidade ODONTO
		// Especificos odontologico.
		if !lFlag .and. (iIf(len(aDadUsr)>= 1, aDadUsr[1], .f.)) .and. !lExiste

			cCdTbPd   := cCodPad
			cCodPro   := cCodProc
			lFlag     := .f.
			// Incompatibilidade no nivel de procedimento
			BR8->(dbSetOrder(1))
			if BR8->(msSeek(xFilial("BR8")+cCdTbPd+cCodPro))  .and. BR8->BR8_ODONTO == '1'

				// Incompatibilidade no nivel de dente
				if !lFlag .and. !empty(cDenReg) .and. !lExiste
					//OK - VALIDADO!
					cSQL := "SELECT BD6_CODRDA, BD6_DATPRO,BD6_CODPAD,BD6_CODPRO,BD6_DENREG,BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_NUMIMP"

					if lFieldsB08
						cSQL += ", B08_QUANTI, B08_UNIDAD "
					endIf

					if lCposB08
						cSQL += ", B08_EXCETO, B08_PERIOD "
					endIf
					if B08->( FieldPos("B08_CONRDA") ) > 0
						cSQL += ", B08_CONRDA "
					endIf

					if cVldMatVid == "2"	// Utiliza matricua da vida.
						cSQL += " FROM "+RetSqlName("BD6")+","+RetSqlName("B08")+","+RetSqlName("BA1")+" WHERE "

					else
						cSQL += " FROM "+RetSqlName("BD6")+","+RetSqlName("B08")+" WHERE "

					endIf
					cSQL += "B08_FILIAL = '"+xFilial("B08")+"' AND "
					cSQL += "B08_CODPAD = '"+cCdTbPd+"' AND "
					cSQL += "B08_CODPSA = '"+cCodPro+"' AND "
					cSQL += "B08_DENREG = '"+allTrim(cDenReg)+"' AND "

					if cVldMatVid == "2"	// Utiliza matricua da vida.
						cSQL += "BA1_FILIAL = BD6_FILIAL AND "
						cSQL += "BA1_CODINT = BD6_OPEUSR AND "
						cSQL += "BA1_CODEMP = BD6_CODEMP AND "
						cSQL += "BA1_MATRIC = BD6_MATRIC AND "
						cSQL += "BA1_TIPREG = BD6_TIPREG AND "
						cSQL += "BA1_MATVID = '"+aDadUsr[5]+"' AND "

					else	// Utiliza verificação pela matricula do contrato.
						cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
						cSQL += "BD6_OPEUSR = '"+Subs(aDadUsr[2],atCodOpe[1],atCodOpe[2])+"' AND "
						cSQL += "BD6_CODEMP = '"+Subs(aDadUsr[2],atCodEmp[1],atCodEmp[2])+"' AND "
						cSQL += "BD6_MATRIC = '"+Subs(aDadUsr[2],atMatric[1],atMatric[2])+"' AND "
						cSQL += "BD6_TIPREG = '"+Subs(aDadUsr[2],atTipReg[1],atTipReg[2])+"' AND "
						cSQL += "BD6_DIGITO = '"+Subs(aDadUsr[2],atDigito[1],atDigito[2])+"' AND "

					endIf

					cSQL += "( BD6_FASE = '3' OR BD6_FASE = '4') AND "
					if existBlock("PLPERSIT")
						cSQL += execBlock("PLPERSIT",.f.,.f.)
						cSQL += " AND  "
					else
						cSQL += "( ( BD6_SITUAC = '1' ) OR ( BD6_SITUAC = '3' AND BD6_LIBERA = '1') )  AND BD6_STATUS <> '0' AND  "
					endIf

					if findFunction("PlReChvEst")
						aRetAux  := PlReChvEst("BD6",.t.,.f.,.t.,.f.)
						cSQL     += aRetAux[1]
					endIf

					cSQL += "BD6_FILIAL = B08_FILIAL AND "
					cSQL += "BD6_CODPAD = B08_CHVPAD AND "//ainda nao estou tratando grupo/subgupo/item
					cSQL += "BD6_CODPRO = B08_CHVPSA AND "
					cSQL += "BD6_DENREG = B08_CHVREG AND "
					cSQL += RetSqlName("BD6")+".D_E_L_E_T_ = ' ' AND "
					cSQL += RetSqlName("B08")+".D_E_L_E_T_ = ' ' "
					cSQL += "ORDER BY BD6_DATPRO "

					dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSql)),"PLSVLDPRI",.f.,.t.)

					if !PLSVLDPRI->(eof())
						plsTField("PLSVLDPRI",.f.,{ "B08_EXCETO","BD6_DATPRO","B08_QUANTI" } )
					endIf

					if !lFieldsB08 .and. !lCposB08

						if !PLSVLDPRI->(eof()) .and. !lCri

							lExiste	:= .t.
							lFlag	:= .t.
							lCri	:= .t.

							aadd(aProcInc,{	cCdTbPd,;
								cCodPro,;
								PLSVLDPRI->BD6_CODPAD,;
								PLSVLDPRI->BD6_CODPRO,;
								PLSVLDPRI->BD6_DENREG,;
								cDenReg,;
								PLSVLDPRI->(BD6_CODOPE+"."+BD6_CODLDP+"."+BD6_CODPEG+"."+BD6_NUMERO),;
								"",;
								"",;
								cSequen,;
								"",;
								"B08",;
								PLSVLDPRI->BD6_NUMIMP})
						endIf

					endIf

					while !PLSVLDPRI->(eof()) .and. lFieldsB08 .and. lCposB08

						if PLSVLDPRI->B08_EXCEto > 0 .and. !empty(PLSVLDPRI->B08_PERIOD)

							dCalcDt := CProcInc(PLSVLDPRI->BD6_DATPRO,PLSVLDPRI->B08_QUANTI,PLSVLDPRI->B08_UNIDAD,PLSVLDPRI->B08_EXCETO,PLSVLDPRI->B08_PERIOD)

							aadd(aRangeDt,{PLSVLDPRI->BD6_DATPRO,dCalcDt})

						else
							Exit
						endIf

						PLSVLDPRI->(dbSkip())
					endDo

					PLSVLDPRI->(dbGotop())

					while !PLSVLDPRI->(eof()) .and. !lCri

						if PLSVLDPRI->B08_CONRDA <> '1' .or. (PLSVLDPRI->B08_CONRDA == '1' .and. PLSVLDPRI->BD6_CODRDA == cCodRda)

							if lFieldsB08 .and. lCposB08

								if 	len(aRangeDt) > 0 .and. PLSVLDPRI->B08_QUANTI <> 0 .and. !empty(PLSVLDPRI->B08_UNIDAD) .and.;
										PLSVLDPRI->B08_EXCEto <> 0 .and. !empty(PLSVLDPRI->B08_PERIOD)

									for nD := 1 to len(aRangeDt)

										if lCri
											Exit
										elseIf(dtos(dDataBase) >= dtos(aRangeDt[nD][1]) .and. dtos(dDataBase) <= dtos(aRangeDt[nD][2]))
											lCri := .t.
										endIf

									next nD

									if  lCri

										lExiste  := .t.
										lFlag	 := .t.

										aadd(aProcInc,{	cCdTbPd,;
											cCodPro,;
											PLSVLDPRI->BD6_CODPAD,;
											PLSVLDPRI->BD6_CODPRO,;
											PLSVLDPRI->BD6_DENREG,;
											cDenReg,;
											PLSVLDPRI->(BD6_CODOPE+"."+BD6_CODLDP+"."+BD6_CODPEG+"."+BD6_NUMERO),;
											"",;
											"",;
											cSequen,;
											"",;
											"B08",;
											PLSVLDPRI->BD6_NUMIMP})
									endIf

								else

									lExiste  := .t.
									lFlag	 := .t.
									aadd(aProcInc,{	cCdTbPd,;
										cCodPro,;
										PLSVLDPRI->BD6_CODPAD,;
										PLSVLDPRI->BD6_CODPRO,;
										PLSVLDPRI->BD6_DENREG,;
										cDenReg,;
										PLSVLDPRI->(BD6_CODOPE+"."+BD6_CODLDP+"."+BD6_CODPEG+"."+BD6_NUMERO),;
										"",;
										"",;
										cSequen,;
										"",;
										"B08",;
										PLSVLDPRI->BD6_NUMIMP})
									Exit
								endIf

							endIf

							if len(aRangeDt) == 0

								nDias 	:= iIf (lFieldsB08, PLSCalcDia(PLSVLDPRI->B08_QUANTI,PLSVLDPRI->B08_UNIDAD), 0) 	// Calcula em dias

								if lFieldsB08 .and. nDias > 0 .and. (dtos(PLSVLDPRI->BD6_DATPRO) >= dtos(dDatPro-nDias))	// Analisa validade da regra.

									lExiste  := .t.
									lFlag	 := .t.

									aadd(aProcInc,{	cCdTbPd,;
										cCodPro,;
										PLSVLDPRI->BD6_CODPAD,;
										PLSVLDPRI->BD6_CODPRO,;
										PLSVLDPRI->BD6_DENREG,;
										cDenReg,;
										PLSVLDPRI->(BD6_CODOPE+"."+BD6_CODLDP+"."+BD6_CODPEG+"."+BD6_NUMERO),;
										"",;
										"",;
										cSequen,;
										"",;
										"B08",;
										PLSVLDPRI->BD6_NUMIMP})

								endIf

							endIf

						endIf

						PLSVLDPRI->(dbSkip())
					endDo

					PLSVLDPRI->(DbCloseArea())
				endIf

				// Inverte a posicao do procedimento...
				if !lFlag .and. !empty(cDenReg) .and. cSentido <> "2" .and. !lExiste
					cSQL := "SELECT BD6_CODRDA, BD6_DATPRO, BD6_CODPAD,BD6_CODPRO,BD6_DENREG,BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_NUMIMP"
					if lFieldsB08
						cSQL += ", B08_QUANTI, B08_UNIDAD"
					endIf

					if lCposB08
						cSQL += ", B08_EXCETO, B08_PERIOD "
					endIf
					if B08->( FieldPos("B08_CONRDA") ) > 0
						cSQL += ", B08_CONRDA "
					endIf

					if cVldMatVid == "2"	// Utiliza matricua da vida.
						cSQL += " FROM "+RetSqlName("BD6")+","+RetSqlName("B08")+","+RetSqlName("BA1")+" WHERE "

					else
						cSQL += " FROM "+RetSqlName("BD6")+","+RetSqlName("B08")+" WHERE "

					endIf

					cSQL += "B08_FILIAL = '"+xFilial("B08")+"' AND "
					cSQL += "B08_CHVPAD = '"+cCdTbPd+"' AND "
					cSQL += "B08_CHVPSA = '"+cCodPro+"' AND "
					cSQL += "B08_CHVREG = '"+cDenReg+"' AND "

					if cVldMatVid == "2"	// Utiliza matricua da vida.
						cSQL += "BA1_FILIAL = BD6_FILIAL AND "
						cSQL += "BA1_CODINT = BD6_OPEUSR AND "
						cSQL += "BA1_CODEMP = BD6_CODEMP AND "
						cSQL += "BA1_MATRIC = BD6_MATRIC AND "
						cSQL += "BA1_TIPREG = BD6_TIPREG AND "
						cSQL += "BA1_MATVID = '"+aDadUsr[5]+"' AND "

					else	// Utiliza verificação pela matricula do contrato.
						cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
						cSQL += "BD6_OPEUSR = '"+Subs(aDadUsr[2],atCodOpe[1],atCodOpe[2])+"' AND "
						cSQL += "BD6_CODEMP = '"+Subs(aDadUsr[2],atCodEmp[1],atCodEmp[2])+"' AND "
						cSQL += "BD6_MATRIC = '"+Subs(aDadUsr[2],atMatric[1],atMatric[2])+"' AND "
						cSQL += "BD6_TIPREG = '"+Subs(aDadUsr[2],atTipReg[1],atTipReg[2])+"' AND "
						cSQL += "BD6_DIGITO = '"+Subs(aDadUsr[2],atDigito[1],atDigito[2])+"' AND "

					endIf

					cSQL += "( BD6_FASE = '3' OR BD6_FASE = '4') AND "
					if existBlock("PLPERSIT")
						cSQL += execBlock("PLPERSIT",.f.,.f.)
						cSQL += " AND  "
					else
						cSQL += "( ( BD6_SITUAC = '1' ) OR ( BD6_SITUAC = '3' AND BD6_LIBERA = '1') )  AND BD6_STATUS <> '0' AND  "
					endIf

					if findFunction("PlReChvEst")
						aRetAux  := PlReChvEst("BD6",.t.,.f.,.t.,.f.)
						cSQL     += aRetAux[1]
					endIf

					cSQL += "BD6_FILIAL = B08_FILIAL AND "
					cSQL += "BD6_CODPAD = B08_CODPAD AND "//ainda nao estou tratando grupo/subgupo/item
					cSQL += "BD6_CODPRO = B08_CODPSA AND "
					cSQL += "BD6_DENREG = CASE "
					cSQL += "WHEN B08_DENREG = '' THEN BD6_DENREG else B08_DENREG END AND "
					cSQL += RetSqlName("BD6")+".D_E_L_E_T_ = ' ' AND "
					cSQL += RetSqlName("B08")+".D_E_L_E_T_ = ' ' "
					cSQL += "ORDER BY BD6_DATPRO "

					dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSql)),"PLSVLDPRI",.f.,.t.)

					if !PLSVLDPRI->(eof())
						plsTField("PLSVLDPRI",.f.,{ "B08_EXCETO","BD6_DATPRO","B08_QUANTI" } )
					endIf

					while !PLSVLDPRI->(eof()) .and. lFieldsB08 .and. lCposB08

						if PLSVLDPRI->B08_EXCEto > 0 .and. !empty(PLSVLDPRI->B08_PERIOD)

							dCalcDt := CProcInc(PLSVLDPRI->BD6_DATPRO,PLSVLDPRI->B08_QUANTI,PLSVLDPRI->B08_UNIDAD,PLSVLDPRI->B08_EXCETO,PLSVLDPRI->B08_PERIOD)

							aadd(aRangeDt,{PLSVLDPRI->BD6_DATPRO,dCalcDt})

						else
							Exit
						endIf

						PLSVLDPRI->(dbSkip())
					endDo

					PLSVLDPRI->(dbGotop())

					while !PLSVLDPRI->(eof()) .and. !lCri

						if lFieldsB08 .and. lCposB08

							if PLSVLDPRI->B08_CONRDA <> '1' .or. (PLSVLDPRI->B08_CONRDA == '1' .and. PLSVLDPRI->BD6_CODRDA == cCodRda)

								if len(aRangeDt) > 0

									for nD := 1 to len(aRangeDt)

										if lCri
											Exit
										elseIf(dtos(dDataBase) >= dtos(aRangeDt[nD][1]) .and. dtos(dDataBase) <= dtos(aRangeDt[nD][2]))
											lCri := .t.
										endIf

									next nD

									if  lCri

										lExiste  := .t.
										lFlag	 := .t.

										aadd(aProcInc,{	cCdTbPd,;
											cCodPro,;
											PLSVLDPRI->BD6_CODPAD,;
											PLSVLDPRI->BD6_CODPRO,;
											PLSVLDPRI->BD6_DENREG,;
											cDenReg,;
											PLSVLDPRI->(BD6_CODOPE+"."+BD6_CODLDP+"."+BD6_CODPEG+"."+BD6_NUMERO),;
											"",;
											"",;
											cSequen,;
											"",;
											"B08",;
											PLSVLDPRI->BD6_NUMIMP})
									endIf
								endIf
							endIf

							if len(aRangeDt) == 0

								nDias 	:= iIf (lFieldsB08, PLSCalcDia(PLSVLDPRI->B08_QUANTI,PLSVLDPRI->B08_UNIDAD), 0) 	// Calcula em dias

								if !lFieldsB08 .or. nDias == 0 .or. (dtos(PLSVLDPRI->BD6_DATPRO) >= dtos(dDatPro-nDias))	// Analisa validade da regra.

									lExiste  := .t.
									lFlag	 := .t.

									aadd(aProcInc,{	cCdTbPd,;
										cCodPro,;
										PLSVLDPRI->BD6_CODPAD,;
										PLSVLDPRI->BD6_CODPRO,;
										PLSVLDPRI->BD6_DENREG,;
										cDenReg,;
										PLSVLDPRI->(BD6_CODOPE+"."+BD6_CODLDP+"."+BD6_CODPEG+"."+BD6_NUMERO),;
										"",;
										"",;
										cSequen,;
										"",;
										"B08",;
										PLSVLDPRI->BD6_NUMIMP})
								endIf

							endIf

						endIf

						PLSVLDPRI->(dbSkip())
					endDo

					PLSVLDPRI->(DbCloseArea())
				endIf

				// Incompatibilidade no nivel de face
				if !lExiste

					B05->(dbSetOrder(1))

					if 	!lFlag .and. !empty(cFace) .and. !empty(cDenReg) .and. B05->(msSeek(xFilial("B05")+cCdTbPd+cCodPro+cDenReg))

						cSQL := "SELECT BD6_CODRDA, BD6_DATPRO, BD6_CODPAD,BD6_CODPRO,BD6_DENREG,BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_NUMIMP,BD6_FADENT"
						cSQL += ", B87_QUANTI, B87_UNIDAD, B87_CONRDA "

						if lCposB87
							cSQL += ", B87_EXCETO, B87_PERIOD "
						endIf

						if cVldMatVid == "2"	// Utiliza matricua da vida.

							cSQL += " FROM "+RetSqlName("BD6")+","+RetSqlName("B87")+","+RetSqlName("BA1")+" WHERE "

						else

							cSQL += " FROM "+RetSqlName("BD6")+","+RetSqlName("B87")+" WHERE "

						endIf

						cSQL += "B87_FILIAL = '"+xFilial("B87")+"' AND "
						cSQL += "B87_CODPAD = '"+cCdTbPd+"' AND "
						cSQL += "B87_CODPSA = '"+cCodPro+"' AND "
						cSQL += "B87_DENREG = '"+cDenReg+"' AND "
						cSQL += "B87_FACINC = '"+cFace+"'   AND "

						if cVldMatVid == "2"	// Utiliza matricua da vida.
							cSQL += "BA1_FILIAL = BD6_FILIAL AND "
							cSQL += "BA1_CODINT = BD6_OPEUSR AND "
							cSQL += "BA1_CODEMP = BD6_CODEMP AND "
							cSQL += "BA1_MATRIC = BD6_MATRIC AND "
							cSQL += "BA1_TIPREG = BD6_TIPREG AND "
							cSQL += "BA1_MATVID = '"+aDadUsr[5]+"' AND "

						else	// Utiliza verificação pela matricula do contrato.
							cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
							cSQL += "BD6_OPEUSR = '"+Subs(aDadUsr[2],atCodOpe[1],atCodOpe[2])+"' AND "
							cSQL += "BD6_CODEMP = '"+Subs(aDadUsr[2],atCodEmp[1],atCodEmp[2])+"' AND "
							cSQL += "BD6_MATRIC = '"+Subs(aDadUsr[2],atMatric[1],atMatric[2])+"' AND "
							cSQL += "BD6_TIPREG = '"+Subs(aDadUsr[2],atTipReg[1],atTipReg[2])+"' AND "
							cSQL += "BD6_DIGITO = '"+Subs(aDadUsr[2],atDigito[1],atDigito[2])+"' AND "

						endIf

						cSQL += "( BD6_FASE = '3' OR BD6_FASE = '4') AND "
						if existBlock("PLPERSIT")
							cSQL += execBlock("PLPERSIT",.f.,.f.)
							cSQL += " AND  "
						else
							cSQL += "( ( BD6_SITUAC = '1' ) OR ( BD6_SITUAC = '3' AND BD6_LIBERA = '1') )  AND BD6_STATUS <> '0' AND  "
						endIf

						if findFunction("PlReChvEst")
							aRetAux  := PlReChvEst("BD6",.t.,.f.,.t.,.f.)
							cSQL     += aRetAux[1]
						endIf

						cSQL += "BD6_FILIAL = B87_FILIAL AND "
						cSQL += "BD6_CODPAD = B87_CHVPAD AND "//ainda nao estou tratando grupo/subgupo/item
						cSQL += "BD6_CODPRO = B87_CHVPSA AND "
						cSQL += "BD6_DENREG = B87_CHVREG AND "
						cSQL += "BD6_FADENT = B87_FACE AND "
						cSQL += RetSqlName("BD6")+".D_E_L_E_T_ = ' ' AND "
						cSQL += RetSqlName("B87")+".D_E_L_E_T_ = ' ' "
						cSQL += "ORDER BY BD6_DATPRO "

						dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSql)),"PLSVLDPRI",.f.,.t.)

						if !PLSVLDPRI->(eof())
							plsTField("PLSVLDPRI",.f.,{ "B08_EXCETO","BD6_DATPRO","B08_QUANTI" } )
						endIf

						while !PLSVLDPRI->(eof()) .and. lCposB87

							if PLSVLDPRI->B87_EXCEto > 0 .and. !empty(PLSVLDPRI->B87_PERIOD)

								dCalcDt := CProcInc(PLSVLDPRI->BD6_DATPRO,PLSVLDPRI->B87_QUANTI,PLSVLDPRI->B87_UNIDAD,PLSVLDPRI->B87_EXCETO,PLSVLDPRI->B87_PERIOD)

								aadd(aRangeDt,{PLSVLDPRI->BD6_DATPRO,dCalcDt})

							else
								Exit
							endIf

							PLSVLDPRI->(dbSkip())
						endDo

						PLSVLDPRI->(dbGotop())

						while !PLSVLDPRI->(eof()) .and. !lCri

							if PLSVLDPRI->B87_CONRDA <> '1' .or. (PLSVLDPRI->B87_CONRDA == '1' .and. PLSVLDPRI->BD6_CODRDA == cCodRda)

								if lCposB87

									if len(aRangeDt) > 0

										for nD := 1 to len(aRangeDt)

											if lCri
												Exit
											elseIf(dtos(dDataBase) >= dtos(aRangeDt[nD][1]) .and. dtos(dDataBase) <= dtos(aRangeDt[nD][2]))
												lCri := .t.
											endIf

										next nD

										if  lCri

											lExiste  := .t.
											lFlag	 := .t.

											aadd(aProcInc,{	cCdTbPd,;
												cCodPro,;
												PLSVLDPRI->BD6_CODPAD,;
												PLSVLDPRI->BD6_CODPRO,;
												PLSVLDPRI->BD6_DENREG,;
												cDenReg,;
												PLSVLDPRI->(BD6_CODOPE+"."+BD6_CODLDP+"."+BD6_CODPEG+"."+BD6_NUMERO),;
												cFace,;
												PLSVLDPRI->BD6_FADENT,;
												cSequen,;
												"",;
												"B87",;
												PLSVLDPRI->BD6_NUMIMP})
										endIf

									endIf

								endIf

								if len(aRangeDt) == 0

									nDias 	:= PLSCalcDia(PLSVLDPRI->B87_QUANTI,PLSVLDPRI->B87_UNIDAD) 	// Calcula em dias

									if nDias == 0 .or. (dtos(PLSVLDPRI->BD6_DATPRO) >= dtos(dDatPro-nDias))	// Analisa validade da regra.

										lExiste  := .t.
										lFlag	 := .t.

										aadd(aProcInc,{ cCdTbPd,;
											cCodPro,;
											PLSVLDPRI->BD6_CODPAD,;
											PLSVLDPRI->BD6_CODPRO,;
											PLSVLDPRI->BD6_DENREG,;
											cDenReg,;
											PLSVLDPRI->(BD6_CODOPE+"."+BD6_CODLDP+"."+BD6_CODPEG+"."+BD6_NUMERO),;
											cFace,;
											PLSVLDPRI->BD6_FADENT,;
											cSequen,;
											"",;
											"B87",;
											PLSVLDPRI->BD6_NUMIMP})
									endIf

								endIf

							endIf

							PLSVLDPRI->(dbSkip())
						endDo

						PLSVLDPRI->(DbCloseArea())

						// Inverte a posicao do procedimento...
						if !lFlag .and. cSentido <> "2" .and. !lExiste

							cSQL := "SELECT BD6_CODRDA, BD6_DATPRO, BD6_CODPAD,BD6_CODPRO,BD6_DENREG,BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_NUMIMP,BD6_FADENT"
							cSQL += ", B87_QUANTI, B87_UNIDAD, B87_CONRDA "

							if lCposB87
								cSQL += ", B87_EXCETO, B87_PERIOD "
							endIf
							if cVldMatVid == "2"	// Utiliza matricua da vida.
								cSQL += " FROM "+RetSqlName("BD6")+","+RetSqlName("B87")+","+RetSqlName("BA1")+" WHERE "

							else
								cSQL += " FROM "+RetSqlName("BD6")+","+RetSqlName("B87")+" WHERE "

							endIf

							cSQL += "B87_FILIAL = '"+xFilial("B87")+"' AND "
							cSQL += "B87_CHVPAD = '"+cCdTbPd+"' AND "
							cSQL += "B87_CHVPSA = '"+cCodPro+"' AND "
							cSQL += "B87_CHVREG = '"+cDenReg+"' AND "
							cSQL += "B87_FACE   = '"+cFace+"'   AND "

							if cVldMatVid == "2"	// Utiliza matricua da vida.
								cSQL += "BA1_FILIAL = BD6_FILIAL AND "
								cSQL += "BA1_CODINT = BD6_OPEUSR AND "
								cSQL += "BA1_CODEMP = BD6_CODEMP AND "
								cSQL += "BA1_MATRIC = BD6_MATRIC AND "
								cSQL += "BA1_TIPREG = BD6_TIPREG AND "
								cSQL += "BA1_MATVID = '"+aDadUsr[5]+"' AND "

							else	// Utiliza verificação pela matricula do contrato.
								cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
								cSQL += "BD6_OPEUSR = '"+Subs(aDadUsr[2],atCodOpe[1],atCodOpe[2])+"' AND "
								cSQL += "BD6_CODEMP = '"+Subs(aDadUsr[2],atCodEmp[1],atCodEmp[2])+"' AND "
								cSQL += "BD6_MATRIC = '"+Subs(aDadUsr[2],atMatric[1],atMatric[2])+"' AND "
								cSQL += "BD6_TIPREG = '"+Subs(aDadUsr[2],atTipReg[1],atTipReg[2])+"' AND "
								cSQL += "BD6_DIGITO = '"+Subs(aDadUsr[2],atDigito[1],atDigito[2])+"' AND "

							endIf

							cSQL += "( BD6_FASE = '3' OR BD6_FASE = '4') AND "
							if existBlock("PLPERSIT")
								cSQL += execBlock("PLPERSIT",.f.,.f.)
								cSQL += " AND  "
							else
								cSQL += "( ( BD6_SITUAC = '1' ) OR ( BD6_SITUAC = '3' AND BD6_LIBERA = '1') )  AND BD6_STATUS <> '0' AND  "
							endIf

							if findFunction("PlReChvEst")
								aRetAux  := PlReChvEst("BD6",.t.,.f.,.t.,.f.)
								cSQL     += aRetAux[1]
							endIf

							cSQL += "BD6_FILIAL = B87_FILIAL AND "
							cSQL += "BD6_CODPAD = B87_CODPAD AND "//ainda nao estou tratando grupo/subgupo/item
							cSQL += "BD6_CODPRO = B87_CODPSA AND "
							cSQL += "BD6_DENREG = B87_DENREG AND "
							cSQL += "BD6_FADENT = B87_FACINC AND "
							cSQL += RetSqlName("BD6")+".D_E_L_E_T_ <> '*' AND "
							cSQL += RetSqlName("B87")+".D_E_L_E_T_ <> '*' "
							cSQL += "ORDER BY BD6_DATPRO "

							dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSql)),"PLSVLDPRI",.f.,.t.)

							if !PLSVLDPRI->(eof())
								plsTField("PLSVLDPRI",.f.,{ "B08_EXCETO","BD6_DATPRO","B08_QUANTI" } )
							endIf

							while !PLSVLDPRI->(eof()) .and. lCposB87

								if PLSVLDPRI->B87_EXCEto > 0 .and. !empty(PLSVLDPRI->B87_PERIOD)

									dCalcDt := CProcInc(PLSVLDPRI->BD6_DATPRO,PLSVLDPRI->B87_QUANTI,PLSVLDPRI->B87_UNIDAD,PLSVLDPRI->B87_EXCETO,PLSVLDPRI->B87_PERIOD)

									aadd(aRangeDt,{PLSVLDPRI->BD6_DATPRO,dCalcDt})

								else
									Exit
								endIf

								PLSVLDPRI->(dbSkip())
							endDo

							PLSVLDPRI->(dbGotop())

							while !PLSVLDPRI->(eof()) .and. !lCri

								if PLSVLDPRI->B87_CONRDA <> '1' .or. (PLSVLDPRI->B87_CONRDA == '1' .and. PLSVLDPRI->BD6_CODRDA == cCodRda)

									if lCposB87

										if len(aRangeDt) > 0

											for nD := 1 to len(aRangeDt)

												if lCri
													Exit
												elseIf(dtos(dDataBase) >= dtos(aRangeDt[nD][1]) .and. dtos(dDataBase) <= dtos(aRangeDt[nD][2]))
													lCri := .t.
												endIf

											next nD

											if  lCri

												lExiste  := .t.
												lFlag	 := .t.
												aadd(aProcInc,{	cCdTbPd,;
													cCodPro,;
													PLSVLDPRI->BD6_CODPAD,;
													PLSVLDPRI->BD6_CODPRO,;
													PLSVLDPRI->BD6_DENREG,;
													cDenReg,;
													PLSVLDPRI->(BD6_CODOPE+"."+BD6_CODLDP+"."+BD6_CODPEG+"."+BD6_NUMERO),;
													cFace,;
													PLSVLDPRI->BD6_FADENT,;
													cSequen,;
													"",;
													"B87",;
													PLSVLDPRI->BD6_NUMIMP})
											endIf

										endIf

									endIf

									if len(aRangeDt) == 0

										nDias 	:= PLSCalcDia(PLSVLDPRI->B87_QUANTI,PLSVLDPRI->B87_UNIDAD) 	// Calcula em dias

										if nDias == 0 .or. (dtos(PLSVLDPRI->BD6_DATPRO) >= dtos(dDatPro-nDias))	// Analisa validade da regra.

											lExiste  := .t.
											lFlag	 := .t.

											aadd(aProcInc,{ cCdTbPd,;
												cCodPro,;
												PLSVLDPRI->BD6_CODPAD,;
												PLSVLDPRI->BD6_CODPRO,;
												PLSVLDPRI->BD6_DENREG,;
												cDenReg,;
												PLSVLDPRI->(BD6_CODOPE+"."+BD6_CODLDP+"."+BD6_CODPEG+"."+BD6_NUMERO),;
												cFace,;
												PLSVLDPRI->BD6_FADENT,;
												cSequen,;
												"",;
												"B87",;
												PLSVLDPRI->BD6_NUMIMP})
										endIf

									endIf

								endIf

								PLSVLDPRI->(dbSkip())
							endDo

							PLSVLDPRI->(DbCloseArea())

						endIf

					endIf

				endIf

			endIf

		endIf

		// vou procurar os procedimentos em uma mesma guia
		// la em cima eu procuro os procedimentos incompativeis no historico do
		// usuario (BD6)


		if !lExiste

			cCdTbPd   := cCodPad
			cCodPro   := cCodProc

			if __cCdTbPd <> cCdTbPd .or. len(__aNiveis) == 0
				__cCdTbPd := cCdTbPd
				__aNiveis := PLSESPNIV(cCdTbPd)
			endIf
			nNiveis := (__aNiveis[1]+1)

			BR8->(dbSetOrder(1))
			if BR8->(msSeek(xFilial("BR8")+cCdTbPd+cCodPro))  .and. BR8->BR8_ODONTO == '1'

				if !empty(cDenReg)

					nTamDenReg := tamSx3("B08_DENREG")[1]
					nTamCodPsa := tamSx3("B08_CODPSA")[1]

					for nInd := 1 to len(aCodsProcs)

						_cSequen   := aCodsProcs[nInd,8]
						_cCdTbPd   := aCodsProcs[nInd,1]
						_cCodPro   := aCodsProcs[nInd,2]
						_cDenReg   := If(len(aCodsProcs[nInd])>=6,aCodsProcs[nInd,6],"")
						_cFace     := If(len(aCodsProcs[nInd])>=7,aCodsProcs[nInd,7],"")

						if __cTissVer >= "3"
							//Faz o De-Para
							cCodProd := allTrim(PLSVARVINC(_cCdTbPd,'BR8', _cCodPro))//PLSGETVINC("BTU_CDTERM", "BR8", .f., "", ::ProDad:CodPro )
							//cCdTabPd := _cCdTbPd//allTrim(PLSVARVINC('87','BR4', _cCdTbPd))//PLSGETVINC("BTU_CDTERM", "BR4", .f., "", ::ProDad:CodPad )
							cCdTabPd := allTrim(PLSVARVINC('87','BR4', _cCdTbPd))//Retornado a função para fazer o de x para corretamente.
							lFlag	   := .f.
						endIf

						if _cSequen == cSequen
							Loop
						endIf

						//Ajusto as variaveis com o tamnho dos campos, prenchendo com espacos a direita, pois se nao tiver os espacos o seek falha
						cCodPro  := padr(cCodPro, nTamCodPsa)
						cDenReg  := padr(cDenReg, nTamDenReg)
						_cCodPro := padr(_cCodPro, nTamCodPsa)
						_cDenReg := padr(_cDenReg, nTamDenReg)
						cCodProd := padr(cCodProd, nTamCodPsa)

						for nfor := 1 to nNiveis

							if nfor == 1
								if __cTissVer >= "3"   //Se tem tiss 3 tem que fazer a busca com o codigo do de-para 'cCodProd'
									cChave  := xFilial("B08")+cCdTbPd + cCodPro + cDenReg + cCdTabPd+ cCodProd+allTrim(str(nNiveis))+_cDenReg
									cChave2 := xFilial("B08")+cCdTbPd + cCodPro + cDenReg + cCdTabPd+ cCodProd+allTrim(str(nNiveis))+Space(nTamDenReg)//tem que ter o espaco senao o seek acha parte da chave
									cChave3 := xFilial("B08")+cCdTabPd+ cCodProd+ _cDenReg+ cCdTbPd + cCodPro +allTrim(str(nNiveis))+cDenReg
									cChave4 := xFilial("B08")+cCdTabPd+ cCodProd+ _cDenReg+ cCdTbPd + cCodPro +allTrim(str(nNiveis))+Space(nTamDenReg)//tem que ter o espaco senao o seek acha parte da chave
								else
									cChave  := xFilial("B08")+cCdTbPd + cCodPro + cDenReg + _cCdTbPd+ _cCodPro+allTrim(str(nNiveis))+_cDenReg
									cChave2 := xFilial("B08")+cCdTbPd + cCodPro + cDenReg + _cCdTbPd+ _cCodPro+allTrim(str(nNiveis))+Space(nTamDenReg)//tem que ter o espaco senao o seek acha parte da chave
									cChave3 := xFilial("B08")+_cCdTbPd+ _cCodPro+ _cDenReg+ cCdTbPd + cCodPro +allTrim(str(nNiveis))+cDenReg
									cChave4 := xFilial("B08")+_cCdTbPd+ _cCodPro+ _cDenReg+ cCdTbPd + cCodPro +allTrim(str(nNiveis))+Space(nTamDenReg)//tem que ter o espaco senao o seek acha parte da chave
								endIf
							else
								cCodAux := Subs(_cCodPro,__aNiveis[2,(nfor-1),1],__aNiveis[2,(nfor-1),2])
								cCodAux := cCodAux+Space(len(B08->B08_CDNV01)-len(cCodAux))
								cCodAux1 := Subs(cCodPro,__aNiveis[2,(nfor-1),1],__aNiveis[2,(nfor-1),2])
								cCodAux1 := cCodAux+Space(len(B08->B08_CDNV01)-len(cCodAux))
								cChave  := xFilial("B08")+cCdTbPd +cCodPro +cDenReg +_cCdTbPd+cCodAux +__aNiveis[2,(nfor-1),3]+_cDenReg
								cChave2 := xFilial("B08")+cCdTbPd +cCodPro +cDenReg +_cCdTbPd+cCodAux +__aNiveis[2,(nfor-1),3]+Space(nTamDenReg)//tem que ter o espaco senao o seek acha parte da chave
								cChave3 := xFilial("B08")+_cCdTbPd+_cCodPro+_cDenReg+cCdTbPd +cCodAux1+__aNiveis[2,(nfor-1),3]+cDenReg
								cChave4 := xFilial("B08")+_cCdTbPd+_cCodPro+_cDenReg+cCdTbPd +cCodAux1+__aNiveis[2,(nfor-1),3]+Space(nTamDenReg)//tem que ter o espaco senao o seek acha parte da chave
							endIf

							B08->(dbSetOrder(nfor))
							if (B08->(msSeek(cChave)) .or.;
									(B08->(msSeek(cChave2)) .and. (empty(B08->B08_DENREG) .or. allTrim(_cDenReg) == allTrim(cDenReg) ))) .or.;
									(B08->(msSeek(cChave3)) .or.;
									(B08->(msSeek(cChave4)) .and. (empty(B08->B08_DENREG) .or. allTrim(_cDenReg) == allTrim(cDenReg) )))

								if lCposB08
									if B08->B08_EXCEto > 0 .and. !empty(B08->B08_PERIOD) .and. B08->B08_QUANTI > 0 .and. !empty(B08->B08_UNIDAD)
										lExiste  := .f.
									else
										lExiste  := .t.
									endIf
								else
									lExiste  := .t.
								endIf
								lFlag	 := .t.

								aadd(aProcInc,{cCdTbPd,;
									cCodPro,;
									_cCdTbPd,;
									_cCodPro,;
									_cDenReg,;
									cDenReg,;
									"",;
									"",;
									"",;
									cSequen,;
									"",;
									"B08",;
									""})

							endIf
						next
						// Trata na face...
						if !lFlag .and.;
								allTrim(_cDenReg) == allTrim(cDenReg) .and.;
								!empty(cFace) .and. !empty(_cFace) // Trata cadastro de incompatibilidade generico.

							B10->(dbSetOrder(1))
							if (B10->(msSeek(xFilial("B10")+cFace+_cFace))) .or. (B10->(msSeek(xFilial("B10")+_cFace+cFace)))
								lExiste  := .t.
								aadd(aProcInc,{cCdTbPd,;
									cCodPro,;
									_cCdTbPd,;
									_cCodPro,;
									_cDenReg,;
									cDenReg,;
									"",;
									cFace,;
									_cFace,;
									cSequen,;
									"",;
									"B10",;
									""})
							endIf
						endIf

						//Se nao achou, trata o novo cadastro.
						if !lExiste

							cSQL := "SELECT * FROM "+RetSqlName("B87")+" WHERE "
							cSQL += "B87_FILIAL = '"+xFilial("B87")+"' AND "
							cSQL += "B87_CODPAD = '"+cCdTbPd+"' AND "
							cSQL += "B87_CODPSA = '"+cCodPro+"' AND "
							cSQL += "B87_DENREG = '"+cDenReg+"' AND "
							cSQL += "B87_FACINC = '"+cFace+"'   AND "
							cSQL += "B87_CHVPAD = '"+_cCdTbPd+"' AND "
							cSQL += "B87_CHVPSA = '"+_cCodPro+"' AND "
							cSQL += "B87_CHVREG = '"+_cDenReg+"' AND "
							cSQL += "B87_FACE   = '"+_cFace+"' AND "
							cSQL += RetSqlName("B87")+".D_E_L_E_T_ = ' ' "

							dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSVLDPRI",.f.,.t.)

							if !PLSVLDPRI->(eof())
								plsTField("PLSVLDPRI",.f.,{ "B87_EXCETO","B87_QUANTI" } )
							endIf

							if PLSVLDPRI->( eof() )

								// Nao encontrou! Refaz a query invertendo a combinacao!
								PLSVLDPRI->( dbCloseArea() )

								cSQL := "SELECT * FROM "+RetSqlName("B87")+" WHERE "
								cSQL += "B87_FILIAL = '"+xFilial("B87")+"' AND "
								cSQL += "B87_CODPAD = '"+_cCdTbPd+"' AND "
								cSQL += "B87_CODPSA = '"+_cCodPro+"' AND "
								cSQL += "B87_DENREG = '"+_cDenReg+"' AND "
								cSQL += "B87_FACINC = '"+_cFace+"'   AND "

								cSQL += "B87_CHVPAD = '"+cCdTbPd+"' AND "
								cSQL += "B87_CHVPSA = '"+cCodPro+"' AND "
								cSQL += "B87_CHVREG = '"+cDenReg+"' AND "
								cSQL += "B87_FACE   = '"+cFace+"' AND "
								cSQL += RetSqlName("B87")+".D_E_L_E_T_ = ' ' "

								dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSVLDPRI",.f.,.t.)

								if !PLSVLDPRI->(eof())
									plsTField("PLSVLDPRI",.f.,{ "B87_EXCETO","B87_QUANTI" } )
								endIf

								if !PLSVLDPRI->( eof() )

									if lCposB87

										if PLSVLDPRI->B87_EXCEto > 0 .and. !empty(PLSVLDPRI->B87_PERIOD) .and. PLSVLDPRI->B87_QUANTI > 0 .and. !empty(PLSVLDPRI->B87_UNIDAD)
											lExiste := .f.
										else
											lExiste := .t.
										endIf

									else
										lExiste := .t.
									endIf

								endIf

							elseIf lCposB87

								if PLSVLDPRI->B87_EXCEto > 0 .and. !empty(PLSVLDPRI->B87_PERIOD) .and. PLSVLDPRI->B87_QUANTI > 0 .and. !empty(PLSVLDPRI->B87_UNIDAD)
									lExiste := .f.
								else
									lExiste := .t.
								endIf

							endIf

							// Encerra area de trabalho.
							PLSVLDPRI->( dbCloseArea() )

							if lExiste

								aadd(aProcInc,{	cCdTbPd,;
									cCodPro,;
									_cCdTbPd,;
									_cCodPro,;
									_cDenReg,;
									cDenReg,;
									"",;
									cFace,;
									_cFace,;
									cSequen,;
									"",;
									"B87",;
									""})
							endIf

						endIf

					next

				endIf

			endIf

		endIf

		// FIM DA INCOMPATIBILIDADE DE ODONTO

		if !lExiste .and. lTemBJ4

			for nInd := 1 to len(aCodsProcs)

				_cSequen := aCodsProcs[nInd,8]
				_cCdTbPd := aCodsProcs[nInd,1]
				_cCodPro := aCodsProcs[nInd,2]

				if _cSequen == cSequen
					Loop
				endIf

				for nfor := 1 to nNiveis

					cSQL := "SELECT BJ4_CODPAD,BJ4_CODPSA FROM "+cNameBJ4+" WHERE "
					cSQL += "BJ4_FILIAL = '"+cFilBJ4+"' AND "
					cSQL += "( BJ4_CODIGO = '"+_cCdTbPd+_cCodPro+"' AND "
					cSQL += "BJ4_CODPAD = '"+cCdTbPd+"' AND "

					if nfor == 1
						cSQL += "BJ4_CODPSA = '"+allTrim(cCodPro)+"' "
					else
						cSQL += "BJ4_CDNV0"+strZero(nfor-1,1)+" = '"+Subs(cCodPro,__aNiveis[2,(nfor-1),1],__aNiveis[2,(nfor-1),2])+"' AND "
						cSQL += "BJ4_NIVEL = '"+__aNiveis[2,(nfor-1),3]+"' "
					endIf

					cSQL += " )"

					if cSentido = "2"

						cSQL += " OR ( BJ4_CODIGO = '"+cCdTbPd+cCodPro+"' AND "
						cSQL += "BJ4_CODPAD = '"+_cCdTbPd+"' AND "

						if nfor == 1
							cSQL += "BJ4_CODPSA = '"+allTrim(_cCodPro)+"' "
						else
							cSQL += "BJ4_CDNV0"+strZero(nfor-1,1)+" = '"+Subs(_cCodPro,__aNiveis[2,(nfor-1),1],__aNiveis[2,(nfor-1),2])+"' AND "
							cSQL += "BJ4_NIVEL = '"+__aNiveis[2,(nfor-1),3]+"' "
						endIf

						cSQL += " ) "

					endIf

					cSQL +=  "AND D_E_L_E_T_ = ' ' "

					dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSVLDPRI",.f.,.t.)

					if ! PLSVLDPRI->(eof())

						lExiste  := .t.

						aadd(aProcInc,{	cCdTbPd,;
							cCodPro,;
							_cCdTbPd,;
							_cCodPro,;
							"",;
							"",;
							"",;
							"",;
							"",;
							cSequen,;
							"",;
							"BJ4",;
							""})

						PLSVLDPRI->(DbCloseArea())
						eval(bRest)
						Exit
					endIf

					PLSVLDPRI->(DbCloseArea())
					eval(bRest)
				next

			next

		endIf

		// Verifica a incompatibilidade na B26
		if !lExiste .and. lTemB26

			for nInd := 1 to len(aCodsProcs)

				_cSequen := aCodsProcs[nInd,8]
				_cCdTbPd := aCodsProcs[nInd,1]
				_cCodPro := aCodsProcs[nInd,2]

				if _cSequen == cSequen
					Loop
				endIf

				for nfor := 1 to nNiveis

					cSQL := "SELECT B26_CODPAD,B26_CODPSA FROM "+cNameB26+" WHERE "
					cSQL += "B26_FILIAL = '"+cFilB26+"' AND "
					cSQL += "(B26_CODPAD = '"+cCdTbPd+"' AND "

					if nfor == 1
						cSQL += "B26_CODPSA = '"+allTrim(cCodPro)+"' "
					else
						cSQL += "B26_CDNV0"+strZero(nfor-1,1)+" = '"+Subs(cCodPro,__aNiveis[2,(nfor-1),1],__aNiveis[2,(nfor-1),2])+"' AND "
						cSQL += "B26_NIVEL = '"+__aNiveis[2,(nfor-1),3]+"' "
					endIf

					cSQL += " )"
					cSQL += "OR (B26_AUXPAD = '"+cCdTbPd+"' AND "
					cSQL += "B26_AUXPSA = '"+allTrim(cCodPro)+"' "
					cSQL += " ) "

					// cSentido: Variavel que contem a definição do parametro MV_PLSSENT se a verificação será nos dois sentidos, ou se será de sentido unico.
					// Sentido Duplo: Quando informar um procedimento incompativel, nao importa qual dois dois for executado primeiro, ao executar o segundo o sistema ira criticar.
					// Sentido Unico: Nesse caso, o sistema ira verificar na sequencia cadastrada.
					if cSentido = "2"

						cSQL += "OR (B26_CODPAD = '"+_cCdTbPd+"' AND "

						if nfor == 1
							cSQL += "B26_CODPSA = '"+allTrim(_cCodPro)+"' "
						else
							cSQL += "B26_CDNV0"+strZero(nfor-1,1)+" = '"+Subs(_cCodPro,__aNiveis[2,(nfor-1),1],__aNiveis[2,(nfor-1),2])+"' AND "
							cSQL += "B26_NIVEL = '"+__aNiveis[2,(nfor-1),3]+"' "
						endIf

						cSQL += " ) "

					endIf

					cSQL +=  "AND D_E_L_E_T_ = ' ' "

					dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSVLDPRI",.f.,.t.)

					if ! PLSVLDPRI->(eof())

						lExiste  := .t.

						aadd(aProcInc,{	cCdTbPd,;
							cCodPro,;
							_cCdTbPd,;
							_cCodPro,;
							"",;
							"",;
							"",;
							"",;
							"",;
							cSequen,;
							"",;
							"B26",;
							""})

						PLSVLDPRI->(DbCloseArea())
						eval(bRest)
						Exit
					endIf

					PLSVLDPRI->(DbCloseArea())
					eval(bRest)
				next

			next

		endIf

		// Se existir, aplica a critica.
		if lExiste
			lRet := .f.
			BR8->(dbSetOrder(1))
			for nfor := 1 to len(aProcInc)
				if nfor == 1
					// Criticas utilizadas pela regra de procedimentos incompativeis.
					if aProcInc[nfor][11] == "1"
						// Critica utilizada quando o proc. incompativel estiver cadastrado no B26 - Proc. Incom. da RDA e o tipo de ação for "Criticar"
						if PLSPOSGLO(PLSINTPAD(),__aCdCri177[1],__aCdCri177[2],cLocalExec,,iIf(lWeb,"2",""))
							cCodCri := __aCdCri177[1]
							lEhDaqui := .T.
						endIf

					elseIf aProcInc[nfor][11] == "2"
						// Critica utilizada quando o proc. incompativel estiver cadastrado no B26 - Proc. Incom. da RDA e o tipo de ação for "Auditar"
						if PLSPOSGLO(PLSINTPAD(),__aCdCri178[1],__aCdCri178[2],cLocalExec,NIL,iIf(lWeb,"2",""),"1")
							cCodCri := __aCdCri178[1]
							lEhDaqui := .T.
						endIf

					elseIf aProcInc[nfor][11] == "3"
						// Critica utilizada quando o proc. incompativel estiver cadastrado no B26 - Proc. Incom. da RDA e o tipo de ação for "Reduzir a UCO"
						// Para redução da UCO, o procedimento será enviado para a auditoria e la, as providencias para reduzir a UCO serão tomadas.
						if PLSPOSGLO(PLSINTPAD(),__aCdCri193[1],__aCdCri193[2],cLocalExec,NIL,iIf(lWeb,"2",""),"1")
							cCodCri := __aCdCri193[1]
							lEhDaqui := .T.
						endIf

					else
						// Critica utilizada quando o procedimento incompativel estiver cadastrado no BJ4 - Cadastro de Proc. Incompativeis.
						if PLSPOSGLO(PLSINTPAD(),__aCdCri057[1],__aCdCri057[2],cLocalExec,,iIf(lWeb,"2","")) .and. lVerIncopat
							cCodCri := __aCdCri057[1]
							lEhDaqui := .T.
						endIf

					endIf

					if ! empty(cCodCri)
						if ascan(aCodCri,{|x| x[1] == cCodCri}) == 0 // Tratamaneto para não repetir a mesmas criticas
							aadd(aCodCri,{cCodCri,PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,aProcInc[nfor][1],aProcInc[nfor][2],aProcInc[nfor][10]})
							BR8->(msSeek(xFilial("BR8")+aProcInc[nfor,1]+aProcInc[nfor,2]))
							if len(aProcInc[nfor])>=8 .and. !empty(aProcInc[nfor][8])
								B09->(dbSetOrder(1))
								B09->(msSeek(xFilial("B09")+aProcInc[nfor][8]))
								aadd(aCodCri,{"",STR0109+allTrim(aProcInc[nfor,6])+") - Face ("+allTrim(aProcInc[nfor][8])+")",allTrim(aProcInc[nfor,2])+"-"+allTrim(BR8->BR8_DESCRI),"","",aProcInc[nfor,1],aProcInc[nfor,2],aProcInc[nfor][10]})

							elseIf !empty(aProcInc[nfor,6])
								aadd(aCodCri,{""   ,STR0110+allTrim(BR8->BR8_CODPSA)+STR0144+allTrim(aProcInc[nfor,6])+")",allTrim(BR8->BR8_DESCRI),"","",aProcInc[nfor,1],aProcInc[nfor,2],aProcInc[nfor][10]})
							else
								aadd(aCodCri,{""   ,STR0110+allTrim(BR8->BR8_CODPSA)+")",allTrim(BR8->BR8_DESCRI),"","",aProcInc[nfor,1],aProcInc[nfor,2],aProcInc[nfor][10]})
							endIf

							BR8->(msSeek(xFilial("BR8")+aProcInc[nfor,3]+aProcInc[nfor,4]))
							if len(aProcInc[nfor])>=9 .and. !empty(aProcInc[nfor][9])
								B09->(dbSetOrder(1))
								B09->(msSeek(xFilial("B09")+aProcInc[nfor][9]))
								aadd(aCodCri,{""   ,STR0111+allTrim(aProcInc[nfor,5])+") - Face ("+allTrim(aProcInc[nfor][9])+")",allTrim(B09->B09_FACDES),"","",aProcInc[nfor,1],aProcInc[nfor,2],aProcInc[nfor][10]})
							elseIf !empty(aProcInc[nfor,5])
								aadd(aCodCri,{""   ,STR0112+allTrim(aProcInc[nfor,4])+STR0113+allTrim(aProcInc[nfor,5])+")",allTrim(BR8->BR8_DESCRI),"","",aProcInc[nfor,1],aProcInc[nfor,2],aProcInc[nfor][10]})
							else
								aadd(aCodCri,{""   ,STR0112+allTrim(aProcInc[nfor,4])+")",allTrim(BR8->BR8_DESCRI),"","",aProcInc[nfor,1],aProcInc[nfor,2],aProcInc[nfor][10]})
							endIf

							if !empty(aProcInc[nfor,7])
								aadd(aCodCri,{""   ,STR0114+allTrim(aProcInc[nfor,7])+")",allTrim(aProcInc[nfor,7]),"","",aProcInc[nfor,1],aProcInc[nfor,2],aProcInc[nfor][10]})
							endIf

							if len(aProcInc[nfor]) > 11 .and. empty(cAliascrit)
								cAliascrit := aProcInc[nfor][12]
							endIf

							if len(aProcInc[nfor]) > 12 .and. !empty(aProcInc[nfor][13])
								aadd(aCodCri,{""   ,"Numero do Impresso", aProcInc[nfor][13], "","",aProcInc[nfor,1],aProcInc[nfor,2]}) //"Numero do Impresso"
							endIf

							if len(aProcInc[nfor]) > 12 .and. !empty(aProcInc[nfor][13])
								aadd(aCodCri,{""   ,"", "", "","",aProcInc[nfor,1],aProcInc[nfor,2]}) //"Numero do Impresso"
							endIf

							// alias e caminho da critica.
							PLSCOMPCRI(aCodCri,iIf(!empty(cAliascrit),cAliascrit,"BJ4"))
						endIf

					endIf
				endIf
			next
		endIf

		// Monta array de critica, se houver critica.
		//Se deu cr´tica dentro da função, alimenta o array
		if lEhDaqui .AND. len(aCodCri) > 0
			aRet := {.f.,aCodCri,iIf(empty(cAliascrit),cCritAux,cAliascrit),cCodPad+cCodProc}
		endIf

		eval(bRest)
		// verificar cid incompativel...
		if ! lExiste .and. ! empty(cCid)

			cCdTbPd   := cCodPad
			cCodPro   := cCodProc
			if __cCdTbPd <> cCdTbPd .or. len(__aNiveis) == 0
				__cCdTbPd := cCdTbPd
				__aNiveis := PLSESPNIV(cCdTbPd)
			endIf
			nNiveis := (__aNiveis[1]+1)

			BAA->(dbSetOrder(1))
			if BAA->(msSeek(xFilial("BAA")+allTrim(cCid)))

				cSQL := "SELECT BAA_CODPAD, BAA_CODPRO FROM "+cNameBAA+" WHERE "
				cSQL += "BAA_FILIAL = '"+cFilBAA+"' AND "
				cSQL += "BAA_CODDOE = '"+cCid+"' AND "
				cSQL += "BAA_CODPAD = '"+cCdTbPd+"' AND "

				cSQL += PLREQNI("BAA", "BAA_CODPRO", __aNiveis[2], cCodPro)

				cSQL +=  cNameBAA+".D_E_L_E_T_ = ' ' "

				cSQL +=  " ORDER BY BAA_NIVEL DESC "

				dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSVLDPRI",.f.,.t.)

				if ! PLSVLDPRI->(eof())

					lExiste  := .t.
					aadd(aProcInc,{PLSVLDPRI->BAA_CODPAD,PLSVLDPRI->BAA_CODPRO})

				endIf

				PLSVLDPRI->(DbCloseArea())
				eval(bRest)

			endIf

			if lExiste
				lRet := .f.
				PLSPOSGLO(PLSINTPAD(),__aCdCri058[1],__aCdCri058[2],cLocalExec)
				if !PLSCHKExi(aCodCri,__aCdCri058[1]+cCodPro)
					aadd(aCodCri,{__aCdCri058[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro,cSequen})
					BR8->(dbSetOrder(1))
					BA9->(dbSetOrder(1))
					for nfor := 1 to len(aProcInc)
						BR8->(msSeek(xFilial("BR8")+aProcInc[nfor,1]+aProcInc[nfor,2]))
						aadd(aCodCri,{""   ,STR0048+allTrim(BR8->BR8_CODPSA)+" )",allTrim(BR8->BR8_CODPSA)+" - "+allTrim(BR8->BR8_DESCRI),"","",cCdTbPd,cCodPro,cSequen})    //"Procedimento ( "
						BA9->(msSeek(xFilial("BA9")+cCid))
						aadd(aCodCri,{""   ,STR0050+allTrim(cCid)+" )",allTrim(cCid)+" - "+allTrim(BA9->BA9_DOENCA),"","",cCdTbPd,cCodPro,cSequen})    //"Incompativel com o CID ( "
					next

					// alias e caminho da critica.
					PLSCOMPCRI(aCodCri,"BA9")
				endIf
				eval(bRest)
				aRet := {.f.,aCodCri,"BA9",cCodPad+cCodProc}
			endIf
		endIf

		// Analisa a quantidade maxima de CH por guia...
		if ! lExiste
			cTratLim := iIf(len(aDadUsr)>=15, aDadUsr[15],"")
			nLimCH   := iIf(len(aDadUsr)>=16, aDadUsr[16],"")
			if cTratLim == "1"
				BA0->(dbSetOrder(1))
				if BA0->(msSeek(xFilial("BA0")+aDadUsr[45]))
					cCodTab := BA0->BA0_CODTAB
					BA0->(dbGoto(nRecBA0))
					BA0->(dbSetOrder(nOrdBA0))
				endIf

				nUSMensal 	:= 0
				nQtdCH    	:= 0
				aRetAux		:= PLSXVLDCAL(dDatPro,PLSINTPAD(),.t.,"","",lRPC)

				if len(aRetAux) >= 4
					cAno   := aRetAux[4]
					cMes   := aRetAux[5]
				endIf
				BFM->(dbSetOrder(1))
				if BFM->(msSeek(xFilial("BFM")+cIntPad+cAno+cMes))
					nUSMensal := BFM->BFM_VALRDA
				endIf

				cCdTbPd := cCodPad
				cCodPro := cCodProc

				if len(aCodsProcs) > 0 .and. nAux< len(aCodsProcs)
					nQtd := aCodsProcs[nAux,3]
				endIf

				if empty(cProRel)
					aCompo := PLSCOMEVE(cCodTab, cCdTbPd, cCodPro, PlsIntPad(), dDatPro, nil, nil, nil, cCodRda)
				else
					aCompo := PLSCOMEVE(cCodTab, cCdTbPd, cProRel, PlsIntPad(), dDatPro, nil, nil, nil, cCodRda)
				endIf

				nQtdCH2 := 0
				for nfor := 1 to len(aCompo)

					if allTrim(aCompo[nfor,6]) $ "PLSRETCH"

						if empty(aCompo[nfor,12]) // Nao e em porte medico (CBHPM)
							if empty(cProRel)
								nQtdCH  += aCompo[nfor,3] * nQtd
							else
								nQtdCH  += Round((aCompo[nfor,3]*nPrPrRl,2)/100,2) * nQtd
							endIf
						else
							if empty(cCodTab)
								cCodTab := aCompo[nfor,15]
							endIf

							BW4->(dbSetOrder(1))
							if BW4->(msSeek(xFilial("BW4")+cIntPad+cCodTab+aCompo[nfor,12]))
								if (BW4->( FieldPos("BW4_VIGINI") ) > 0 .and. BW4->( FieldPos("BW4_VIGFIN") ) > 0)

									while BW4->BW4_CODOPE == cIntPad .and. BW4->BW4_CODTAB == cCodTab .and. BW4->BW4_PORTE == aCompo[nfor,12]

										if ( ( dtos(dDatPro) >= dtos(BW4->BW4_VIGINI) ) .and. ;
												( dtos(dDatPro) <= dtos(BW4->BW4_VIGFIN) .or. empty(BW4->BW4_VIGFIN) ) ) .or. ;
												( !empty(BW4->BW4_VIGINI) .and. !empty(BW4->BW4_VIGFIN) )

											if PLSINTval("BW4",'BW4_VIGINI','BW4_VIGFIN',dDatPro)
												if nPrPrRl == 0
													nQtdCH  += Round(BW4->BW4_VLRREA/nUSMensal,2) * nQtd
												else
													nQtdCH  += Round(((BW4->BW4_VLRREA/nUSMensal,2)*nPrPrRl)/100,2) * nQtd
												endIf
											endIf
										elseIf  BW4->BW4_VIGINI == ctod(" / / ") .and. BW4->BW4_VIGFIN == ctod(" / / ")
											if nPrPrRl == 0
												nQtdCH  += Round(BW4->BW4_VLRREA/nUSMensal,2) * nQtd
											else
												nQtdCH  += Round(((BW4->BW4_VLRREA/nUSMensal,2)*nPrPrRl)/100,2) * nQtd
											endIf
										endIf
										BW4->(dbSkip())
									endDo
								else

									if nPrPrRl == 0
										nQtdCH  += Round(BW4->BW4_VLRREA/nUSMensal,2) * nQtd
									else
										nQtdCH  += Round(((BW4->BW4_VLRREA/nUSMensal,2)*nPrPrRl)/100,2) * nQtd
									endIf

								endIf

							endIf

						endIf

					elseIf allTrim(aCompo[nfor,6]) $ "PLSRETREA,PLSCALRCC"

						if empty(cProRel)
							nQtdCH  += Round(aCompo[nfor,3]/nUSMensal,2) * nQtd
						else
							nQtdCH  += Round(((aCompo[nfor,3]/nUSMensal,2)*nPrPrRl)/100,2) * nQtd
						endIf

					elseIf allTrim(aCompo[nfor,6]) $ "PLSRETPA"

						cSQL := "SELECT BKF_COEFIC "

						if  BKF->( FieldPos("BKF_VIGINI") ) > 0 .and. BKF->( FieldPos("BKF_VIGFIN") ) > 0
							cSQL += ", BKF_VIGINI, BKF_VIGFIN "
						endIf

						cSQL += " FROM " + RetSqlName("BKF") + " WHERE "
						cSQL += "    BKF_FILIAL = '" + xFilial("BKF") + "'"
						cSQL += "AND BKF_CODINT = '" + cIntPad + "'"
						cSQL += "AND BKF_CODTAB = '" + aCompo[nfor,15] + "'"
						cSQL += "AND BKF_SEQPOR =  " + allTrim(Str(aCompo[nfor,3]))
						cSQL += " AND " + RetSqlName("BKF") + ".D_E_L_E_T_ = ' ' "

						dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSBKF",.f.,.t.)

						if !PLSBKF->(eof())

							plsTField("PLSBKF",.f.,{ "BKF_VIGINI","BKF_VIGFIN","BKF_COEFIC" } )

							// Novo Tratamento de vigencia.
							while !PLSBKF->(eof())

								if PLSINTval("PLSBKF",'BKF_VIGINI','BKF_VIGFIN',dDatAnalise)
									nQtdCH += PLSBKF->BKF_COEFIC * nQtd
								endIf

								PLSBKF->( dbSkip() )
							endDo

						else

							FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',STR0138 + " " + aCompo[nfor,15] + " - " + cCodPro + " - " + STR0137 , 0, 0, {})

						endIf

						PLSBKF->(dbCloseArea())

					elseIf allTrim(aCompo[nfor,6]) $ "PLSRETCRR,PLSCALDP,PLSRETIN,PLSRETTCR,PLSRETUCO,PLSRETM2,PLSRETAUX"
						//Nao foi elaborado ainda uma forma de achar a quantidade de CH a partir dessas unidades
					endIf
				next

				if nQtdCH > nLimCH
					lRet := .f.
					PLSPOSGLO(PLSINTPAD(),__aCdCri061[1],__aCdCri061[2],cLocalExec)
					if !PLSCHKExi(aCodCri,__aCdCri061[1]+cCodPro)
						aadd(aCodCri,{__aCdCri061[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro,cSequen})
						aadd(aCodCri,{""   ,STR0051,STR(nLimCH),"","",cCdTbPd,cCodPro,cSequen})    //"Limite parametrizado no subcontrato"
						aadd(aCodCri,{""   ,STR0052,STR(nQtdCH),"","",cCdTbPd,cCodPro,cSequen})    //"Quantidade de CH na guia atual solicitada"
						aadd(aCodCri,{""   ,STR0053,STR(nQtdCH-nLimCH),"","",cCdTbPd,cCodPro,cSequen})    //"Limite ultrapassado"

						// alias e caminho da critica.
						PLSCOMPCRI(aCodCri,"BQC")
					endIf
					eval(bRest)
					aRet := {.f.,aCodCri,"BQC",cCodPad+cCodProc}
				endIf
			endIf
		endIf

		// Ponto de entrada apos checar regras de procedimentos incompativeis
		if lRet .and. existBlock("PLSPROIN")
			aRet := execBlock("PLSPROIN",.f.,.f.,{cCid,cLocalExec,aCodsProcs,aDadUsr,dDatPro,cCodPad,cCodProc,cSequen, aRet})
			if  !aRet[1]
				aRet := {.f.,aRet[2],"1",cCodPad+cCodProc}
			endIf
		endIf

		eval(bRest)

	return(aRet)

	/*/{Protheus.doc} PLSVLDCSIP
Valida uma cobertura para um usuario para uso no SIP
@type function
@author tuliocesar
@since 17.06.04
@version 1.0
	/*/
	function PLSVLDCSIP(cMatricUsr,dDataEve,cHoraEve,cCodPad,cCodPro,cCodPla,cVersao)
		local aRet		:= {}
		local aDadUsr 	:= PLSDADUSR(cMatricUsr,"1",.t.,dDataEve)
		local cCritica	:= ""
		local lOK     	:= .f.
		local dDataEve1 := dDataEve
		local cHoraEve1 := cHoraEve
		local cCodPad1  := cCodPad
		local cCodPro1  := cCodPro
		local cCodOpe   := subs(cMatricUsr,1,4)
		local cMatric   := subs(cMatricUsr,5,13)
		local nRegBD6 	:= 0
		local cLocalExec:= ""

		// Veririca se o usuario e valido...
		if aDadUsr[1]

			// Verifica se o procedimento tem direito...
			aRet  := PLSAUTPDIR(cCodOpe,cMatric,cCodPad1,cCodPro1,aDadUsr,dDataEve1,cHoraEve1,nRegBD6,nil,;
				.f.,nil,1,cLocalExec,nil,nil,nil,nil,;
				cCodPla,cVersao,.t.,nil,nil,nil,nil,nil,nil,;
				nil,nil,nil)

			if aRet[1]
				lOK      := .t.
			else
				//estamos colocando as criticas abaixo como as que nao vamos dar direito (olhar plsmccr.ch)
				//__aCdCri001 {"501","Usuario nao possui cobertura para este procedimento."}
				//__aCdCri055 {"026","Procedimento informado nao existe na tabela padrao."}
				//__aCdCri068 {"034","Procedimento invalido para lancamentos como eventos (analitico/sintetico)"}
				if aRet[2,1,1] $ __aCdCri001[1]+__aCdCri055[1]+__aCdCri068[1]
					cCritica := STR0054                 //"2-Usuario nao possui cobertura para o procedimento informado"
				else
					lOK      := .t.
				endIf
			endIf
		else
			cCritica := STR0055 //"1-Usuario invalido"
		endIf

	return({lOK,cCritica})

	/*/{Protheus.doc} PLSTratSol
@type function
@author tuliocesar
@since 27.04.05
@version 1.0
	/*/
	function PLSTratSol(cOpeSol,cCdTbPd,cCodPro,aDadRDA,aDadUsr,cLocalExec,cCodLoc,lTratSolic,aRet,cCodPRFSol,lTratRDA,dData,cCodEsp,cTipoProc,cEspSol)
		local aAreaBAU	  := BAU->(getArea())
		local lRegraSol   := ( BR8->BR8_TRRGSL $ ", 1" )
		local lAutorizado := aRet[1]
		local lCheck	  := .t.
		local cTipo		  := "2"
		local cOpeRDA 	  := ""
		local cTipPreRDA  := If( lTratRDA, iIf(len(aDadRda)>27,aDadRda[27],""), "")
		local aSlvCri	  := aClone(aCodCri)
		local aLocais     := {}
		local aRetAux	  := {}
		local aOldRet     := aClone(aRet)
		local lGo		  := .f.
		local lPLEXSL	  := (getNewPar("MV_PLEXSL", .f.))
		local aBkpCdCri	  := aClone(aCodCri)

		default dData     := dDataBase
		default cCodEsp	  := ""
		default cTipoProc := ""
		default cEspSol	  := ""

		// Nao trata se for ope
		if cTipPreRDA == cMV_PLSTPIN
			lRegraExe := .f.
		endIf

		// Regra
		if lRegraSol .and. lTratSolic .and. ! empty(cCodPRFSol) .and. lTratRDA

			// Rda do Profissional
			if !lPLEXSL
				BAU->( dbSetOrder(5) )//BAU_FILIAL + BAU_CODBB0
				if BAU->( msSeek(xFilial("BAU")+cCodPRFSol) )
					lGo := .t.
				endIf
			else
				BAU->(dbSetOrder(1))
				if BAU->(msSeek(xFilial("BAU") + aDadRda[2]))
					lGo := .t.
				endIf
			endIf

			if lGo

				// Pegando os Locais de atendimentos da rda do solicitante
				aLocais := PLSLOCRDA(BAU->BAU_CODIGO,cOpeSol,cCodLoc)

				// Se Informada a Especialidade
				BBF->( dbSetOrder(1) )//BBF_FILIAL + BBF_CODIGO + BBF_CODINT + BBF_CDESP
				BQ1->( dbSetOrder(1) )

				if ! lPLEXSL .and. ! empty(cEspSol) .and. BQ1->(msSeek(xFilial("BQ1")+cCodPRFSol+cEspSol))

					if BBF->( msSeek(xFilial("BBF")+BAU->BAU_CODIGO+cOpeSol+cEspSol) )

						if !(dData >= BBF->BBF_DATBLO) .or. empty(BBF->BBF_DATBLO)
							//se a RDA solicitante é diferente da RDA contratada, eu tenho que varrer todos os locais do solicitante
							if BAU->BAU_CODIGO <> aDadRda[2]
								aLocais := PLSLOCRDA(BAU->BAU_CODIGO,cOpeSol)//para solicitante com especilidade especifica eu tenho que considerar todos locais
							endIf

							PLSLOCESP(cOpeSol,BAU->BAU_CODIGO,cCdTbPd,cCodPro,aDadRDA,cTipo,aDadUsr,cLocalExec,cEspSol,cCodLoc,lCheck,aLocais,dData,lAutorizado,@aRet,@aOldRet,,.t.)

						endIf

					else

						if existBlock("PLVLDSOL")
							aRet := execBlock("PLVLDSOL",.f.,.f.,{cTipoProc,cOpeSol,BAU->BAU_CODIGO,cCdTbPd,cCodPro,aDadRDA,cTipo,aDadUsr,cLocalExec,cEspSol,cCodLoc,lCheck,aLocais,dData,lAutorizado,aRet,aOldRet})
						endIf

					endIf

				elseIf lPLEXSL .AND. ! empty(cCodEsp)

					if existBlock("PLVLDSOL")
						aRet := execBlock("PLVLDSOL",.f.,.f.,{cTipoProc,cOpeSol,BAU->BAU_CODIGO,cCdTbPd,cCodPro,aDadRDA,cTipo,aDadUsr,cLocalExec,cCodEsp,cCodLoc,lCheck,aLocais,dData,lAutorizado,aRet,aOldRet})
					else

						aRetAux  := aClone(aRet)
						aOldRet  := aClone(aRetAux)
						cOpeRDA  := aDadRDA[14]

						BB8->(dbSetOrder(1)) //BB8_FILIAL+BB8_CODIGO+BB8_CODINT+BB8_CODLOC+BB8_LOCAL

						BAX->(dbSetOrder(1)) //BAX_FILIAL+BAX_CODIGO+BAX_CODINT+BAX_CODLOC+BAX_CODESP+BAX_CODSUB
						if BAX->(msSeek(xFilial("BAX")+BAU->BAU_CODIGO))

							while !BAX->(eof()) .and. BAU->BAU_CODIGO == BAX->BAX_CODIGO

								if (BAX->BAX_CODESP <> cCodEsp .and. ! (getNewPar("MV_PLSCTES","0") == "1") .or. ( empty(cCodPRFSol) .and. lTratSolic == "1" ))
									BAX->(dbSkip())
									loop
								endIf

								If BB8->(dbseek(xFilial("BB8")+BAX->BAX_CODIGO+BAX->BAX_CODINT+BAX->BAX_CODLOC))
									If !empty(BB8->BB8_DATBLO) .AND. dData >= BB8->BB8_DATBLO
										BAX->(dbSkip())
										loop
									EndIf
								EndIf

								if ! (dData >= BAX->BAX_DATBLO) .or. empty(BAX->BAX_DATBLO)

									lNegado := ! PLSLOCESP(cOpeRDA,BAU->BAU_CODIGO,cCdTbPd,cCodPro,{},cTipo,aDadUsr,cLocalExec,;
										BAX->BAX_CODESP,BAX->BAX_CODLOC,lCheck,nil,dData,lAutorizado,@aRetAux,@aOldRet,nil,nil,nil,nil,cCodPRFSol,cEspSol)

									//REGRA: SE EM AO MENOS UMA DAS ESPECIALIDADES DO SOLICITANTE EXISTIR POSSIBILIDADE DE EXECUCAO, PERMITO.
									if !lNegado
										aCodCri := aClone(aBkpCdCri)
										Exit
									endIf

								endIf

								BAX->(dbSkip())
							endDo
						endIf

					endIf

				else

					if BBF->( msSeek(xFilial("BBF")+BAU->BAU_CODIGO) )

						// Verificando as especialidades da rda do profissional
						while ! BBF->( eof() ) .and. BBF->(BBF_FILIAL+BBF_CODIGO) == xFilial("BBF")+BAU->BAU_CODIGO

							if !(dData >= BBF->BBF_DATBLO) .or. empty(BBF->BBF_DATBLO)

								if PLSLOCESP(cOpeSol,BAU->BAU_CODIGO,cCdTbPd,cCodPro,aDadRDA,cTipo,aDadUsr,cLocalExec,BBF->BBF_CDESP,cCodLoc,lCheck,aLocais,dData,lAutorizado,@aRet,@aOldRet,,.t.)
									Exit
								endIf

							endIf

							BBF->( dbSkip() )
						endDo

					endIf

				endIf

			endIf

			BAU->(restArea(aAreaBAU))

		endIf

		//Ajuste para nao apagar o conteudo de criticas anteriores...
		if len(aRetAux) == 0

			aRetAux:= aClone(aRet)

			if len(aRetAux) == 0
				aRetAux := {.t.,{},"",""}
				aRet := aClone(aRetAux)
			endIf

		endIf

		if !aRetAux[1]
			aRet := aClone(aRetAux)
		else
			aCodCri := aClone(aSlvCri)
		endIf

		if len(aRet) == 0
			aRet := {.t.,{},"",""}
		endIf

	return(aRet)

	/*/{Protheus.doc} PLSTratExe
@type function
@author tuliocesar
@since 27.04.05
@version 1.0
	/*/
	function PLSTratExe(cCdTbPd,cCodPro,lTratRDA,lTratUsr,lChkExec,cLocalExec,cCodPRFExe,;
			aRetPro,aDadRDA,aDadUsr,aRet,dData,cCodEspExe,cCodLocExe,cCodOpeExe,;
			cAliasCab,aBD7,cEspSol,cEspExe,cCritAux,lVldXml)
		local lAutorizado	:= .f.
		local nFor			:= 0
		local aRetMed		:= {}
		local aOldRet		:= {}
		local aSlvCri 		:= aClone(aCodCri)
		local nRecBAX		:= 0
		local nOrdBAX		:= 0
		local nRecBAU		:= 0
		local nOrdBAU		:= 0
		local nPos			:= 0
		local cOpeRDA		:= ""
		local cCodRDA		:= ""
		local cCodLoc		:= ""
		local cLocal		:= ""
		local cCodEsp		:= ""
		local cSubEsp		:= ""
		local cTrtExe		:= ""
		local cTipo			:= "1"
		local lCheck		:= .f.
		local lFlagAut      := .f.
		local lRegraExe   	:= .t.
		local lOk 			:= .f.
		local cTipPreRDA  	:= If(lTratRDA, iIf(len(aDadRda)>27,aDadRda[27],"" ), "")
		local cFilLog  		:= "PLSTREXE.LOG"
		local aRdaAux		:= {}
		local aProfPes		:= {}
		local lContinua		:= .t.
		local lEspecAtende	:= .t. // indica que na verredura das especialidades com o paramentro MV_PLSCTES ativado ele entrou um proceidmento em outra especialidade que pode atender
		local nPos007		:= 0
		local nPosCri		:= 0
		local aRetAux		:= {}
		local aEspBus 		:= {}
		local lentrou 		:= .f.
		local xCodPrEx 		:= ''
		local xTpPf			:= ''
		local xCodUnd		:= ''
		local xTpAtd		:= ''
		local xCodEsEx 		:= ''
		local xCodLoEx 		:= ''
		local nK			:= 1
		local nH			:= 1
		local nInd 			:= 1
		local nOrBAX		:= 1
		local cSeekBAX		:= ''
		local cwhile		:= ''
		local i				:= 0
		local cIntPad		:= PLSIntPad()
		local lPLSESP01     := existBlock("PLSESP01")
		local cPrioridade   := getNewPar("MV_PLSPRIO","")
		local cEspSobCtes		:= getNewPar("MV_PLSOBCT","009,010") //Parametro que determina as especialidades (BAQ) que deverão sobressair a regra do MV_PLSCTES para validação
		local nInd2 			:= 0
		local nOrdBAQ       := 0
		local nRecBAQ       := 0
		local lVerifica     := .F.

		default dData 	  	:= dDataBase
		default aRetPro   	:= {}
		default aRet      	:= {.t.,{}}
		default cCodEspExe	:= ""//trata a especialidade do execuante
		default cCodLocExe	:= ""//trata o local de atendimento do execuante
		default cCodOpeExe	:= cIntPad //trata a operadora do execunate
		default cAliascab   := ""
		default aBD7		:= {}
		default cEspSol     := ''
		default cEspExe		:= ''
		default cCritAux	:= ""
		default lVldXml		:= .f.

		// Novo conceito aBD7
		// Na TISS sao enviada participacoes distintas por membro de equipe, ou seja|
		// o PRESTADOR A fez o HM, o PRESTADOR B fez o AUX, o PRESTADOR C fez o PA
		// Isso so ocorre quando vem uma importacao XML, pois ate entao nao sabemos |
		// isso... sendo assim tudo que existe aqui continua valendo quando nao eh
		// informada a especialidade do SOLCIITANTE ou do EXECUNTANTE. Quando eh
		// informado isso e o EXECUTANTE ou o SOLICITANTE eh uma RDA da operadora
		// eu tenho que checar se aquele cara pode executar ou solicitar um evento
		// Os novos campos criados sao BE4_,BD5_,BD6_,BD7_ESPSOL e
		// BE4_,BD5_,BD6_,BD7_ESPEXE - daher
		//
		// Essas variaveis cEspSol e cEspExe devem ser alimentadas somente quando
		// nao existir o aBD7 - por exemplo na autorizacao SADT/Liberacao etc
		// Nao trata se for ope
		if BR8->(FieldPos("BR8_TRRGEX")) > 0
			if BR8->BR8_TRRGEX == "0"
				lRegraExe := .f.
			endIf
		endIf

		// Indices
		BBF->( dbSetOrder(1) ) //BBF_FILIAL + BBF_CODIGO + BBF_CODINT + BBF_CDESP
		BB8->( dbSetOrder(1) ) //BB8_FILIAL + BB8_CODIGO + BB8_CODINT + BB8_CODLOC + BB8_local
		BBF->( dbSetOrder(1) )
		BQ1->( dbSetOrder(1) )

		// Checa regra
		if lTratRDA .and. lRegraExe

			cTrtExe := aDadRDA[24]
			cOpeRDA := aDadRDA[14]
			cCodRDA := aDadRDA[02]
			cSubEsp	:= aDadRda[21]
			cLocal	:= aDadRDA[13]
			cCodLoc	:= iIf( ! empty(cCodLocExe),cCodLocExe,aDadRDA[12] )
			cCodEsp := iIf( ! empty(cCodEspExe),cCodEspExe,aDadRDA[15] )

			if lTratUsr

				lAutorizado := If(len(aRetPro) >= 1,aRetPro[1],.f.)
				lNegado 	:= .f.

				// verifico a partir da especialidade da RDA
				if ( ! lChkExec ) .or. ( empty(cCodPRFExe) ) .or. ( ! empty(cCodPRFExe) .and. cTrtExe == "0" )

					//aqui eu trato o seguinte:
					//la no portal ou na tela de autorizaSADT, por exemplo, o aBD7 vem vazio, pois nem existe BD7 ainda
					//mas lá tem o campo de EXECUTANTE e tem o campo de ESPECIALIDADE do executante - campo novo
					//dai essa variavel vai trazer essa especialidade cEspExe
					if len(aBD7) == 0 .and. ! empty(cEspExe) .and. ! empty(cCodPRFExe) .and. ! lVldXml

						aadd(aBd7,{'HM'})											  													  //[1] - UNIDADE
						aadd(aBd7[len(aBd7)],{cCodRDA	 	,aDadRDA[15] 	,aDadRDA[12]	,aDadRDA[8]	,'C'}) //[2] - CONTRATADO e ESPECIALIDADE e local e TIPO F/J e FLAG CONTRATADO
						aadd(aBd7[len(aBd7)],{cCodPRFExe	,cEspExe	  	,''		   		,'F'		  	,'E'}) //[3] - EXECUTANTE e ESPECIALIDADE e local e TIPO F/J e FLAG EXECUTANTE
						aadd(aBd7[len(aBd7)],{''	  	 	,''		  		,''		   		,'F'		  	,'S'}) //[4] - SOLICITANTE e ESPECIALIDADE e local  e TIPO F/J e FLAG SOLICITANTE

					elseIf lVldXml .and. ! empty(cEspExe) .and. ! empty(cCodRDA)

						aadd(aBd7,{'HM'})											  //[1] - UNIDADE
						aadd(aBd7[len(aBd7)],{cCodRDA	 	,cEspExe 	,aDadRDA[12]	,aDadRDA[8]	,'C'})	//[2] - SE for VLDXML TRATA COM A ESPECIALIDADE DO EXECUTANTE.

					endIf

					//aqui eu inicio o tratamento mesmo do prexecutante
					for nk := 1 to len(aBD7)

						if len(aBd7[nK]) >= 3 .or. lVldXml

							for nH := 1 to len(aBD7[nK])

								if valType(aBd7[nK][nH]) == 'C'

									xCodUnd	 := aBd7[nK][nH]

								elseIf valType(aBd7[nK][nH]) == 'A'

									xCodPrEx := aBd7[nK][nH][1]
									xCodEsEx := aBd7[nK][nH][2]
									xCodLoEx := aBd7[nK][nH][3]
									xTpPf	 := aBd7[nK][nH][4]
									xTpAtd	 := aBd7[nK][nH][5]

									//Se o tratamento para executante estiver ligado, exibo no complemento da critica a especialidade do Executante.
									if cTrtExe == "1" .and. !lVldXml
										cEspCri := aBd7[nK][3][2]
									else
										cEspCri := aBd7[nK][nH][2]
									endIf

									if ! empty(xCodPrEx) .and. ! empty(xCodEsEx) .and. (ascan(aProfPes,{|x| x == xCodPrEx}) == 0) .and. xTpAtd $ "C,E"

										if lPLSESP01
											lContinua :=  execBlock("PLSESP01" ,.f.,.f.,{cCdTbPd,cCodPro,aDadRDA,aDadUsr,BAX->BAX_CODESP,cCodLoc,dData})
										endIf

										if xTpPf == 'J'

											BAU->(dbSetOrder(1))
											BBF->(dbSetOrder(1))
											BQ1->(dbSetOrder(1))

											if (getNewPar("MV_PLSCTES","0") == "1" .or. ( empty(cCodPRFExe) .and. cTrtExe == "1" )) .and. lContinua .and. !lVldXml

												lOk 		:= BAU->( msSeek(xFilial("BAU")+xCodPrEx) ) .and. BBF->( msSeek(xFilial("BBF")+BAU->BAU_CODIGO) )

												nOrBAX 		:= 1
												cSeekBAX	:= 'BAX->(msSeek(xFilial("BAX")+BAU->BAU_CODIGO+"'+cIntPad+'"))'
												cwhile		:= 'xFilial("BAX")+"'+cIntPad+'"+BAU->BAU_CODIGO == BAX->(BAX_FILIAL+BAX_CODINT+BAX_CODIGO)'

											else

												lOk 		:= BAU->( msSeek(xFilial("BAU")+xCodPrEx) ) .and. BBF->( msSeek(xFilial("BBF")+BAU->BAU_CODIGO+cOpeRda+xCodEsEx) )

												nOrBAX 		:= 3
												cSeekBAX	:= 'BAX->(msSeek(xFilial("BAX")+BBF->BBF_CODESP+BAU->BAU_CODIGO))'
												cwhile		:= 'xFilial("BAX")+BBF->BBF_CODESP+BAU->BAU_CODIGO == BAX->(BAX_FILIAL+BAX_CODINT+BAX_CODESP+BAX_CODIGO)'

											endIf

										else

											//no contratado eu pego o BD6_CODRDA entao eu tenho que dar o seek pelo BAU_CODIGO
											if xTpAtd $ 'C'
												BAU->(dbSetOrder(1))//BAU_FILIAL+BAU_CODIGO
											else
												BAU->(dbSetOrder(5))//BAU_FILIAL+BAU_CODBB0
											endIf

											BBF->(dbSetOrder(1))
											BQ1->(dbSetOrder(1))

											if lPLSESP01
												lContinua :=  execBlock("PLSESP01" ,.f.,.f.,{cCdTbPd,cCodPro,aDadRDA,aDadUsr,BAX->BAX_CODESP,cCodLoc,dData})
											endIf

											if (getNewPar("MV_PLSCTES","0") == "1" .or. ( empty(cCodPRFExe) .and. cTrtExe == "1" )) .and. lContinua .and. !lVldXml

												lOk 		:= BAU->( msSeek(xFilial("BAU") + xCodPrEx) ) .and. BQ1->(msSeek(xFilial("BQ1") + BAU->BAU_CODBB0)) .and. BBF->( msSeek(xFilial("BBF") + BAU->BAU_CODIGO) )

												nOrBAX		:= 1
												cSeekBAX	:= 'BAX->(msSeek(xFilial("BAX")+BAU->BAU_CODIGO+"'+cIntPad+'"))'
												cwhile		:= 'xFilial("BAX")+"'+cIntPad+'"+BAU->BAU_CODIGO == BAX->(BAX_FILIAL+BAX_CODINT+BAX_CODIGO)'

											else

												lOk 		:= BAU->( msSeek(xFilial("BAU") + xCodPrEx) ) .and. BQ1->(msSeek(xFilial("BQ1") + BAU->BAU_CODBB0 + xCodEsEx)) .and. BBF->( msSeek(xFilial("BBF") + BAU->BAU_CODIGO + cOpeRda + xCodEsEx) )

												nOrBAX 		:= 3
												cSeekBAX	:= 'BAX->(msSeek(xFilial("BAX")+BBF->BBF_CODESP+BAU->BAU_CODIGO))'
												cwhile		:= 'xFilial("BAX")+BBF->BBF_CODESP+BAU->BAU_CODIGO == BAX->(BAX_FILIAL+BAX_CODINT+BAX_CODESP+BAX_CODIGO)'

											endIf

											//se o profissional eh uma pessoa fisica eu somente valido a regra de execucao se a unidade a que se refere a compiscao
											//eh um honorario, por ex.: HM,PA,PPM.. se for um COP eu nao checo pois uma PF nao faz um Custo Operacional ou Filme
											if lOk
												lOk := allTrim(xCodUnd) $ PLSUnHM()
											endIf

										endIf

										lVerifica := IIF((!IsInCallStack("PLSA090") .OR. !IsInCallStack("PLSA092")),.T., !(cCodEsp $ cEspSobCtes))

										if lOk .AND. lVerifica

											aRetAux  := aClone(aRetMed)
											aOldRet  := aClone(aRetAux)

											BB8->(dbSetOrder(1)) //BB8_FILIAL+BB8_CODIGO+BB8_CODINT+BB8_CODLOC+BB8_LOCAL

											BAX->(dbSetOrder(nOrBAX))
											if &(cSeekBAX)

												while !BAX->(eof()) .and. &(cwhile)

													if ! empty(xCodLoEx) .and. xCodLoEx <> BAX->BAX_CODLOC .and. !(getNewPar("MV_PLSCTES","0") == "1" .or. ( empty(cCodPRFExe) .and. cTrtExe == "1" )) .and. !lVldXml
														BAX->(dbSkip())
														loop
													endIf

													If BB8->(dbseek(xFilial("BB8")+BAX->BAX_CODIGO+BAX->BAX_CODINT+BAX->BAX_CODLOC))
														If !empty(BB8->BB8_DATBLO) .AND. dData >= BB8->BB8_DATBLO
															BAX->(dbSkip())
															loop
														EndIf
													EndIf

													if ( !(dData >= BAX->BAX_DATBLO) .or. empty(BAX->BAX_DATBLO) )

														If !lVldXml
															aRetRDA := PlsRetRDA(cOpeRda,BAX->BAX_CODESP,aDadRDA)
															aRetMed := PLSVLDESP(aDadUsr[27],aRetRDA[2][1],aRetRDA[2][2],aRetRDA[2][3],aDadUsr[25],cLocalExec,cCdTbPd,cCodPro,BAQ->BAQ_CODESP,BAQ->BAQ_DESCRI,aRetRDA[1],.t.,.t.,aDadUsr[43]<>'99',nil,nil,aRetRDA)
														endIf

														/*If !lVldXml .AND. aRetMed[1]
													lNegado := !PLSLOCESP(cOpeRda,BAU->BAU_CODIGO,cCdTbPd,cCodPro,{},cTipo,aDadUsr,cLocalExec,;
																	  BAX->BAX_CODESP,BAX->BAX_CODLOC,lCheck,nil,dData,lAutorizado,@aRetMed,@aOldRet,NIL,NIL,NIL,lVldXML)
												else
													aRetAux := {.f.,aRetMed[2]}
													lNegado := .T.
														endIf*/
														lNegado := !PLSLOCESP(cOpeRda,BAU->BAU_CODIGO,cCdTbPd,cCodPro,{},cTipo,aDadUsr,cLocalExec,;
															BAX->BAX_CODESP,BAX->BAX_CODLOC,lCheck,nil,dData,lAutorizado,IIF(lVldXML,Nil, @aRetMed),@aOldRet,IIF(lVldXML,@aRetMed,NIL),.T.,NIL,lVldXML)

														if lPLSESP01

															lContinua :=  execBlock("PLSESP01" ,.f.,.f.,{cCdTbPd,cCodPro,aDadRDA,aDadUsr,BAX->BAX_CODESP,cCodLoc,dData})

															if !lContinua
																Exit
															endIf

														endIf

														//A REGRA EH BEM CLARA SE EM PELO MENOS UMA ESPECIALIDADE O CARA PODE FAZER EU SAIO DA ROTINA
														if ! lNegado
															//A especialidade foi aprovada, porem temos que verificar se as criticas de sexo, idade não fora criticadas ai temos que exibilas
															If Len(aRetMed[2]) > 1 // Verificando se existe alguma critica de de sexo e idade
																aRetAux := {.F.,aRetMed[2]}
															Else
																aRetAux := {} // Não existindo a criticas o procedimento é liberado para que a especialidade posso executar
															Endif
															Exit
														Else
															aRetAux := {.F.,aRetMed[2]}
														EndIf

													endIf

													BAX->(dbSkip())
												endDo

											endIf

											lentrou := .t.

											if !lNegado
												Exit
											endIf

										endIf

										aadd(aProfPes,xCodPrEx)

									endIf

								endIf
								//se foi negado e eu estou validando o contratado eu saio da rotina
								//na verdade se o contratado nao pode fazer, o sistema tem que criticar...
								//por exemplo se uma clinica(CONTRATADO) nao pode fazer um parto, e tiver um obstetra (EXECUTANTE)
								//la dentro o sistema tem que criticar
								//mesmo o obstetra estando autorizado a fazer o parto
								if lNegado .and. xTpAtd == 'C'
									exit
								endIf

							next

							if ! lNegado
								exit
							endIf

						endIf

					next

					if ! lEntrou

						aadd(aEspBus,cCodEsp)

						aRetRDA := PlsRetRDA(cOpeRda,cCodEsp,aDadRDA)
						aRetMed := PLSVLDESP(aDadUsr[27],aRetRDA[2][1],aRetRDA[2][2],aRetRDA[2][3],aDadUsr[25],cLocalExec,cCdTbPd,cCodPro,BAQ->BAQ_CODESP,BAQ->BAQ_DESCRI,aRetRDA[1],.t.,.t.,aDadUsr[43]<>'99',nil,nil,aRetRDA)

						if aRetMed[1]

							aRetMed := PLSAUTPMDD(cOpeRDA,cCodRDA,cCdTbPd,cCodPro,aDadRDA,"1",aDadUsr,cLocalExec,cCodEsp,Subs(cCodLoc,1,3),.f.,nil,dData,,,,,,,,lVldXML)

							if ! aRetMed[1]
								cCritAux := aRetMed[3]
							else
								aRetAux  := aClone(aRetMed)
								aOldRet  := aClone(aRetAux)
							endIf

						endIf

						// "1" - Executando
						if ! aRetMed[1]


							lFlagAut := .f.

							// Com o MV_PLSCTES ativado irei analisar a BAX(Especialidades do Local), para checar se alguma especialidade que possa atender.
							// Caso atendendo o sistema vai chekar outras criticas atraves das chamdas das funções PLSLOCESP,PlsRetRDA e PLSVLDESP.

							if (getNewPar("MV_PLSCTES","0") == "1" .or. ( empty(cCodPRFExe) .and. cTrtExe == "1" ) .and. ! lVldXml)  .and. !(cCodEsp $ cEspSobCtes)

								lFlagAut := lAutorizado
								aRetAux  := aClone(aRetMed)
								aOldRet  := aClone(aRetAux)

								nRecBAX  := BAX->(recno())
								nOrdBAX  := BAX->(indexOrd())
								aEspBus:={}

								// Analisando se alguma especialidade da RDA podera atender.
								if BAX->( msSeek(xFilial("BAX")+cCodRda+cOpeRda+cCodLoc) )

									while ! BAX->(eof()) .and. BAX->(BAX_FILIAL+BAX_CODIGO+BAX_CODINT+BAX_CODLOC) == xFilial("BAX")+cCodRda+cOpeRda+cCodLoc

										if aScan(aEspBus,{|x| allTrim(x) == allTrim(BAX->BAX_CODESP)}) == 0 .and. ( !(dData >= BAX->BAX_DATBLO) .or. empty(BAX->BAX_DATBLO) )

											aadd(aEspBus,BAX->BAX_CODESP)

											if lPLSESP01

												lContinua :=  execBlock("PLSESP01" ,.f.,.f.,{cCdTbPd,cCodPro,aDadRDA,aDadUsr,BAX->BAX_CODESP,cCodLoc,dData})

												if ! lContinua
													Exit
												endIf

											endIf

											lFlagAut := .f.

											if PLSLOCESP(cOpeRda,cCodRDA,cCdTbPd,cCodPro,aDadRDA,cTipo,aDadUsr,cLocalExec,BAX->BAX_CODESP,cCodLoc,lCheck,nil,dData,lAutorizado,@aRetAux,@aOldRet,@aRetMed,.t.,,lVldXML)

												//A especilidade pode atender agora irei analisar outras criticas para essa especialidade e ver se realmente pode atender através das funções PlsRetRDA e PLSVLDESP

												PLSPUTRDA(15,BAX->BAX_CODESP)
												PLSPUTRDA(17,BAQ->(posicione("BAQ",1,xFilial("BAQ")+cOpeRda+BAX->BAX_CODESP,"BAQ_DESCRI")))


												lEspecAtende := .t.
												aRetRDA 	 := PlsRetRDA(cOpeRda,BAX->BAX_CODESP,aDadRDA)
												aRetFun 	 := PLSVLDESP(aDadUsr[27],aRetRDA[2][1],aRetRDA[2][2],aRetRDA[2][3],aDadUsr[25],cLocalExec,cCdTbPd,cCodPro,BAX->BAX_CODESP,aDadRda[17],aRetRDA[1],.t.,.t.,aDadUsr[43]<>'99',nil,nil,aRetRDA)

												if PLSPOSGLO(cIntPad,__aCdCri022[1],__aCdCri022[2],cLocalExec)

													if ! aRetFun[1]

														for nInd := 1 to len(aRetFun[2])
															aadd(aCodCri,{aRetFun[2,nInd,1],aRetFun[2,nInd,2],aRetFun[2,nInd,3],aRetFun[2,nInd,4],aRetFun[2,nInd,5],cCdTbPd,cCodPro})
														next

														aRetAux[1]   := len(aCodCri) == 0
														aRetAux[2]   := aClone(aCodCri)
													endIf

												endIf

											//Se achou especialidade válida, limpamos as críticas 007 do array de deixamos as outras que não são referenet a especialidade
											if !FWISINCALLSTACK("PLSUA410")
												aCodCri := {}

												for nInd := 1 to len(aRetFun[2])
													// se estou com o paramentro ativado MV_PLSCTES encontrei uma especialdiade do executante que atenda meu procedimento devo retirar as críticas do prestador referentes à especialidade
													If !( AllTrim(aRetFun[2,nInd,1])  $ '006/007/012/526') .AND. !(Empty(aRetFun[2,nInd,1]))
														cCodCri := aRetFun[2,nInd,1]
														for nInd2 := nInd to len(aRetFun[2])
															If cCodCri <> aRetFun[2,nInd2,1] .and. !Empty(aRetFun[2,nInd2,1])
																Exit
															Endif
															aadd(aCodCri,{aRetFun[2,nInd2,1],aRetFun[2,nInd2,2],aRetFun[2,nInd2,3],aRetFun[2,nInd2,4],aRetFun[2,nInd2,5],cCdTbPd,cCodPro})
														Next nInd2
													Endif
												next

												aRetAux[1] := len(aCodCri) == 0
												aRetAux[2] := aClone(aCodCri)

												exit
											endif 
											
											Else
												//Tratamento para que no momomento de não achar na
												//especialidade o procedimento vai  acumulando as criticas até
												//achar, caso não achar ele exibe a critica.

												if PLSPOSGLO(cIntPad,__aCdCri021[1],__aCdCri021[2],cLocalExec)

													if ascan(aRetMed[2],{|x| x[1] == __aCdCri021[1] }) == 0 .And. ascan(aRetMed[2],{|x| x[1] == __aCdCri104[1] }) == 0
														lEspecAtende := .f. // Aqui definimos se sera exibo a critica 007
													endIf

												endIf

											endIf

										endIf
										BAX->( dbSkip() )
									endDo

								endIf

								BAX->( dbGoto(nRecBAX) )
								BAX->( dbSetOrder(nOrdBAX) )

								if ! lEspecAtende

									if PLSPOSGLO(cIntPad,__aCdCri021[1],__aCdCri021[2],cLocalExec)

										if ascan(aRetAux[2],{|x| x[1] == __aCdCri021[1] })=0

											aadd(aCodCri,{__aCdCri021[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro,""})

											PLSCOMPCRI(aCodCri,"BAX")

											// Alimenta o caminho no log do XML.
											if lVldXml
												eval(__bErrXML,aCodCri)
											endIf

										endIf

									endIf

								endIf

								if lFlagAut

									aRetAux := aClone(aRetMed)
									aOldRet := aClone(aRetAux)

									//caso o parametro para checar todas especialidades estej ativo eu preciso checar se o prestador pode atender
									//naquela especialidade uma determianda idade

									if getNewPar("MV_PLSCTES","0") == "1" .and. !lVldXml

										aRetRDA := PlsRetRDA(cOpeRda,cCodEsp,aDadRDA)
										aRetFun := PLSVLDESP(aDadUsr[27],aRetRDA[2][1],aRetRDA[2][2],aRetRDA[2][3],aDadUsr[25],cLocalExec,cCdTbPd,cCodPro,cCodEsp,BAX->BAX_CODESP,aRetRDA[1],.t.,.t.,aDadUsr[43]<>'99',nil,nil,aRetRDA)

										if PLSPOSGLO(cIntPad,__aCdCri022[1],__aCdCri022[2],cLocalExec)

											if ! aRetFun[1]

												for nInd := 1 to len(aRetFun[2])
													aadd(aCodCri,{aRetFun[2,nInd,1],aRetFun[2,nInd,2],aRetFun[2,nInd,3],aRetFun[2,nInd,4],aRetFun[2,nInd,5],cCdTbPd,cCodPro})
												next

												aRetAux[1]   := len(aCodCri) == 0
												aRetAux[2]   := aClone(aCodCri)

											endIf
										endIf
									endIf
								endIf

							else

								if lAutorizado
									aRetAux := aClone(aRetMed)
								elseIf len(aRetAux)>0
									aRetAux[1] := .f.

									for nfor := 1 to len(aRetMed[2])
										nPos := ascan(aRetAux[2],{|x| x[1] == aRetMed[2,nfor,1]})
										if nPos == 0
											aadd(aRetAux[2],aRetMed[2,nfor])
										endIf
									next
								endIf

							endIf

						endIf

					endIf

				else

					nRecBAU := BAU->( recno() )
					nOrdBAU := BAU->( indexOrd() )
					aOldRet := aClone(aRetAux)
					lNegado := .f.

					//aqui eu trato o seguinte:
					//la no portal ou na tela de autorizaSADT, por exemplo, o aBD7 vem vazio, pois nem existe BD7 ainda
					//mas lá tem o campo de EXECUTANTE e tem o campo de ESPECIALIDADE do executante - campo novo
					//dai essa variavel vai trazer essa especialidade cEspExe
					if len(aBD7) == 0 .and. ! empty(cEspExe) .and. ! empty(cCodPRFExe)
						aadd(aBd7,{	'HM'})											  						//[1] - UNIDADE
						aadd(aBd7[len(aBd7)],{cCodRDA	 ,aDadRDA[15] ,aDadRDA[12],aDadRDA[8]	,'C'})	 	//[4] - CONTRATADO  e ESPECIALIDADE e local e TIPO F/J e FLAG CONTRATADO
						aadd(aBd7[len(aBd7)],{cCodPRFExe,cEspExe	  ,''		   ,'F'			,'E'})  	//[2] - EXECUTANTE  e ESPECIALIDADE e local  e TIPO F/J e FLAG EXECUTANTE
						aadd(aBd7[len(aBd7)],{''	  	 ,''		  ,''		   ,'F',		,'S'}) 		//[3] - SOLICITANTE e ESPECIALIDADE e local e TIPO F/J e FLAG SOLICITANTE
					endIf

					BAU->(dbSetOrder(1))

					//aqui eu inicio o tratamento mesmo do prexecutante
					for nk := 1 to len(aBD7)

						if len(aBd7[nK]) >= 3

							for nH := 1 to len(aBD7[nK])

								if valType(aBd7[nK][nH]) == 'C'

									xCodUnd	 := aBd7[nK][nH]

								elseIf valType(aBd7[nK][nH]) == 'A'

									xCodPrEx := aBd7[nK][nH][1]
									xCodEsEx := aBd7[nK][nH][2]
									xCodLoEx := aBd7[nK][nH][3]
									xTpPf	 := aBd7[nK][nH][4]
									xTpAtd	 := aBd7[nK][nH][5]

									//Se o tratamento para executante estiver ligado, exibo no complemento da critica a especialidade do Executante.
									if cTrtExe == "1" .and. !lVldXml
										cEspCri := aBd7[nK][3][2]
									else
										cEspCri := aBd7[nK][nH][2]
									endIf

									if !empty(xCodPrEx) .and. !empty(xCodEsEx) .and. (ascan(aProfPes,{|x| x == xCodPrEx}) == 0) .and. xTpAtd $ "C,E"

										if xTpPf == 'J'

											if getNewPar("MV_PLSCTES","0") == "1" .or. ( empty(cCodPRFExe) .and. cTrtExe == "1" ) .and. !lVldXml
												lOk 		:= BAU->( msSeek(xFilial("BAU")+xCodPrEx) ) .and. BBF->( msSeek(xFilial("BBF")+BAU->BAU_CODIGO) )
												nOrBAX 		:= 1
												cSeekBAX	:= 'BAX->(msSeek(xFilial("BAX")+BAU->BAU_CODIGO+"'+cIntPad+'"))'
												cwhile		:= 'xFilial("BAX")+"'+cIntPad+'"+BAU->BAU_CODIGO == BAX->(BAX_FILIAL+BAX_CODINT+BAX_CODIGO)'
											else
												lOk 		:= BAU->( msSeek(xFilial("BAU")+xCodPrEx) ) .and. BBF->( msSeek(xFilial("BBF")+BAU->BAU_CODIGO+cOpeRda+xCodEsEx) )
												nOrBAX 		:= 3
												cSeekBAX	:= 'BAX->(msSeek(xFilial("BAX")+BBF->BBF_CODESP+BAU->BAU_CODIGO))'
												cwhile		:= 'xFilial("BAX")+BBF->BBF_CODESP+BAU->BAU_CODIGO == BAX->(BAX_FILIAL+BAX_CODINT+BAX_CODESP+BAX_CODIGO)'
											endIf

										else
											//no contratado eu pego o BD6_CODRDA entao eu tenho que dar o seek pelo BAU_CODIGO
											if xTpAtd $ 'C'
												BAU->(dbSetOrder(1))
											else
												BAU->(dbSetOrder(5))
											endIf

											if getNewPar("MV_PLSCTES","0") == "1" .or. ( empty(cCodPRFExe) .and. cTrtExe == "1" ) .and. !lVldXml

												//se eh para checar todas especialidades eu nao
												//preciso checar a especialidade especifica na bq1
												lOk 		:= BAU->( msSeek(xFilial("BAU")+xCodPrEx) ) .and. BQ1->(msSeek(xFilial("BQ1")+BAU->BAU_CODBB0)) .and. BBF->( msSeek(xFilial("BBF")+BAU->BAU_CODIGO) )
												nOrBAX		:= 1
												cSeekBAX	:= 'BAX->(msSeek(xFilial("BAX")+BAU->BAU_CODIGO+"'+cIntPad+'"))'
												cwhile		:= 'xFilial("BAX")+"'+cIntPad+'"+BAU->BAU_CODIGO == BAX->(BAX_FILIAL+BAX_CODINT+BAX_CODIGO)'

											else

												lOk 		:= BAU->( msSeek(xFilial("BAU")+xCodPrEx) ) .and. BQ1->(msSeek(xFilial("BQ1")+BAU->BAU_CODBB0+xCodEsEx)) .and. BBF->( msSeek(xFilial("BBF")+BAU->BAU_CODIGO+cOpeRda+xCodEsEx) )
												nOrBAX 		:= 3
												cSeekBAX	:= 'BAX->(msSeek(xFilial("BAX")+BBF->BBF_CODESP+BAU->BAU_CODIGO))'
												cwhile		:= 'xFilial("BAX")+BBF->BBF_CODESP+BAU->BAU_CODIGO == BAX->(BAX_FILIAL+BAX_CODINT+BAX_CODESP+BAX_CODIGO)'

											endIf

											//se o profissional eh uma pessoa fisica eu somente valido a regra de execucao se a unidade a que se refere a compiscao
											//eh um honorario, por ex.: HM,PA,PPM.. se for um COP eu nao checo pois uma PF nao faz um Custo Operacional ou Filme
											if lOk
												lOk := allTrim(xCodUnd) $ PLSUnHM()
											endIf

										endIf

										if lOk

											aRetAux  := aClone(aRetMed)
											aOldRet  := aClone(aRetAux)

											BAX->(dbSetOrder(nOrBAX))

											if &(cSeekBAX)

												while !BAX->(eof()) .and. &(cwhile)

													if !empty(xCodLoEx) .and. xCodLoEx <> BAX->BAX_CODLOC .and. !(getNewPar("MV_PLSCTES","0") == "1" .or. ( empty(cCodPRFExe) .and. cTrtExe == "1" ))
														BAX->(dbSkip())
														loop
													endIf

													if ( !(dData >= BAX->BAX_DATBLO) .or. empty(BAX->BAX_DATBLO) )

														lNegado := !PLSLOCESP(cOpeRda,BAU->BAU_CODIGO,cCdTbPd,cCodPro,{},cTipo,aDadUsr,cLocalExec,BAX->BAX_CODESP,BAX->BAX_CODLOC,lCheck,nil,dData,lAutorizado,@aRetAux,@aOldRet,,,,lVldXML)

														//A REGRA EH BEM CLARA SE EM PELO MENOS UMA ESPECIALIDADE O CARA PODE FAZER EU SAIO DA ROTINA
														if !lNegado

															if len(aCodCri) > 0
																// Esse tramento se da quando apos terminar while na bax e estiver ainda com critica o sistema agrupa as critias QUE VEIO
																// antes de entrada mv_Plsctes com o acodcri depois que entro no plsCtes isso se da para os casos da critica 007/006

																aOldRet   := {.f.,{}}
																lAnterior := .f.

																for i := 1 to len(aCodCri)

																	if !empty(aCodCri[i,1])

																		if !PLSCHKExi(aOldRet[2],aCodCri[i,1]+aCodCri[i,7]) .and. !aCodCri[i,1] $ "006|007" // Preciso retirar a 007 pois o plsctes esta ativado e no final preciso exibir as outras critias
																			lAnterior := .t.
																			aadd(aOldRet[2],aCodCri[i])
																		else
																			lAnterior := .f.
																		endIf
																	else
																		if lAnterior
																			aadd(aOldRet[2],aCodCri[i])
																		endIf
																	endIf
																next i

																aCodCri		 := aClone(aOldRet[2])

															endIf

															exit
														endIf

													endIf

													BAX->(dbSkip())
												endDo

											endIf

											lentrou := .t.
											if !lNegado
												exit
											endIf

										endIf

										aadd(aProfPes,xCodPrEx)

									endIf

								endIf

								//se foi negado e eu estou validando o contratado eu saio da rotina
								//na verdade se o contrato nao pode fazer, o sistema tem que criticar...
								//por exemplo se uma clinica(CONTRATADO) nao pode fazer um parto, e tiver um obstetra (EXECUTANTE)
								//la dentro o sistema tem que criticar
								//mesmo o obstetra estando autorizado a fazer o parto
								if lNegado .and. xTpAtd == 'C'
									exit
								endIf

							next

							if !lNegado
								exit
							endIf

						endIf

					next

					if ! lEntrou

						aadd(aEspBus,cCodEsp)

						aRetRDA := PlsRetRDA(cOpeRda,cCodEsp,aDadRDA)
						aRetMed := PLSVLDESP(aDadUsr[27],aRetRDA[2][1],aRetRDA[2][2],aRetRDA[2][3],aDadUsr[25],cLocalExec,cCdTbPd,cCodPro,BAQ->BAQ_CODESP,BAQ->BAQ_DESCRI,aRetRDA[1],.t.,.t.,aDadUsr[43]<>'99',nil,nil,aRetRDA)

						if aRetMed[1]

							aRetMed := PLSAUTPMDD(cOpeRDA,cCodRDA,cCdTbPd,cCodPro,aDadRDA,"1",aDadUsr,cLocalExec,cCodEsp,Subs(cCodLoc,1,3),.f.,nil,dData,,,,,,,,lVldXML)

							if ! aRetMed[1]
								cCritAux := aRetMed[3]
							else
								aRetAux  := aClone(aRetMed)
								aOldRet  := aClone(aRetAux)
							endIf

						endIf

						// "1" - Executando
						if ! aRetMed[1]

							// Caso nao autorize, procuro em todas as especialidades da rda e local...
							lFlagAut := .f.

							if getNewPar("MV_PLSCTES","0") == "1" .or. ( empty(cCodPRFExe) .and. cTrtExe == "1" ) .and. !lVldXml

								lFlagAut := lAutorizado
								aRetAux  := aClone(aRetMed)
								aOldRet  := aClone(aRetAux)

								nRecBAX  := BAX->(recno())
								nOrdBAX  := BAX->(indexOrd())

								// Especialidades do local de atendimento
								if BAX->( msSeek(xFilial("BAX")+cCodRda+cOpeRda+cCodLoc) )

									while ! BAX->(eof()) .and. BAX->(BAX_FILIAL+BAX_CODIGO+BAX_CODINT+BAX_CODLOC) == xFilial("BAX")+cCodRda+cOpeRda+cCodLoc

										if ascan(aEspBus,{|x| allTrim(x) == allTrim(BAX->BAX_CODESP)}) == 0 .and. ( !(dData >= BAX->BAX_DATBLO) .or. empty(BAX->BAX_DATBLO) )

											aadd(aEspBus,BAX->BAX_CODESP)

											if lPLSESP01

												lContinua :=  execBlock("PLSESP01" ,.f.,.f.,{cCdTbPd,cCodPro,aDadRDA,aDadUsr,BAX->BAX_CODESP,cCodLoc,dData})

												if !lContinua
													Exit
												endIf

											endIf

											lFlagAut := .f.

											if PLSLOCESP(cOpeRda,cCodRDA,cCdTbPd,cCodPro,aDadRDA,cTipo,aDadUsr,cLocalExec,BAX->BAX_CODESP,cCodLoc,lCheck,nil,dData,lAutorizado,@aRetAux,@aOldRet,@aRetMed,.t.,,lVldXML)

												// Atualiza a especialidade em memoria caso seja diferente Regra valida todas as especialidades
												if aDadRda[15] <> BAX->BAX_CODESP
													PLSPUTRDA(15,BAX->BAX_CODESP)
													PLSPUTRDA(17,BAQ->(posicione("BAQ",1,xFilial("BAQ")+cOpeRda+BAX->BAX_CODESP,"BAQ_DESCRI")))
												endIf

												lEspecAtende := .t.

												aRetRDA := PlsRetRDA(cOpeRda,cCodEsp,aDadRDA)
												aRetFun := PLSVLDESP(aDadUsr[27],aRetRDA[2][1],aRetRDA[2][2],aRetRDA[2][3],aDadUsr[25],cLocalExec,cCdTbPd,cCodPro,BAQ->BAQ_CODESP,BAQ->BAQ_DESCRI,aRetRDA[1],.t.,.t.,aDadUsr[43]<>'99',nil,nil,aRetRDA)

												if PLSPOSGLO(cIntPad,__aCdCri022[1],__aCdCri022[2],cLocalExec)

													if ! aRetFun[1]

														for nInd := 1 to len(aRetFun[2])
															aadd(aCodCri,{aRetFun[2,nInd,1],aRetFun[2,nInd,2],aRetFun[2,nInd,3],aRetFun[2,nInd,4],aRetFun[2,nInd,5],cCdTbPd,cCodPro})
														next

														aRetAux[1] := len(aCodCri) == 0
														aRetAux[2] := aClone(aCodCri)
													endIf

												endIf

												Exit
											else
												//Tratamento para que no momomento de não achar na
												//especialidade o procedimento vai  acumulando as criticas até
												//achar, caso não achar ele exibe a critica.

												if PLSPOSGLO(cIntPad,__aCdCri021[1],__aCdCri021[2],cLocalExec)
													if ascan(aRetMed[2],{|x| x[1] == __aCdCri021[1] }) == 0 .And. ascan(aRetMed[2],{|x| x[1] == __aCdCri104[1] }) == 0
														lEspecAtende := .f. // Aqui definimos se sera exibo a critica 007
													endIf
												endIf
											endIf
										endIf
										BAX->( dbSkip() )
									endDo
								endIf

								BAX->( dbGoto(nRecBAX) )
								BAX->( dbSetOrder(nOrdBAX) )

								if ! lEspecAtende

									if PLSPOSGLO(cIntPad,__aCdCri021[1],__aCdCri021[2],cLocalExec)

										if ascan(aRetAux[2],{|x| x[1] == __aCdCri021[1] }) == 0

											aadd(aCodCri,{__aCdCri021[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro,""})

											PLSCOMPCRI(aCodCri,"BAX")

											// Alimenta o caminho no log do XML.
											if lVldXml
												eval(__bErrXML,aCodCri)
											endIf

										endIf

									endIf

								endIf

								if lFlagAut

									aRetAux := aClone(aRetMed)
									aOldRet := aClone(aRetAux)

									//caso o parametro para checar todas especialidades estej ativo eu preciso checar se o prestador pode atender
									//naquela especialidade uma determianda idade
									if getNewPar("MV_PLSCTES","0") == "1" .and. !lVldXml

										aRetRDA := PlsRetRDA(cOpeRda,cCodEsp,aDadRDA)
										aRetFun := PLSVLDESP(aDadUsr[27],aRetRDA[2][1],aRetRDA[2][2],aRetRDA[2][3],aDadUsr[25],cLocalExec,cCdTbPd,cCodPro,cCodEsp,BAQ->BAQ_CODESP,aRetRDA[1],.t.,.t.,aDadUsr[43]<>'99',nil,nil,aRetRDA)

										if PLSPOSGLO(cIntPad,__aCdCri022[1],__aCdCri022[2],cLocalExec)

											if ! aRetFun[1]

												for nInd := 1 to len(aRetFun[2])
													aadd(aCodCri,{ aRetFun[2,nInd,1] ,aRetFun[2,nInd,2], aRetFun[2,nInd,3], aRetFun[2,nInd,4], aRetFun[2,nInd,5], cCdTbPd,cCodPro} )
												next

												aRetAux[1]   := len(aCodCri) == 0
												aRetAux[2]   := aClone(aCodCri)

											endIf

										endIf

									endIf

								endIf

							else

								if lAutorizado

									aRetAux := aClone(aRetMed)

								elseIf len(aRetAux) > 0

									aRetAux[1] := .f.

									for nfor := 1 to len(aRetMed[2])

										nPos := ascan(aRetAux[2],{|x| x[1] == aRetMed[2,nfor,1]})

										if nPos == 0
											aadd(aRetAux[2], aRetMed[2,nFor] )
										endIf

									next

								endIf

							endIf

						endIf

					endIf

				endIf

			endIf

		endIf

		// * Realizado ajuste para inserir as criticas e autorizacoes em um array auxiliar
		//   para nao deletar autorizacoes encontradas em niveis mais especificos ou criticas
		//   efetuadas antes de tratar o executante.
		if len(aRetAux) == 0

			if getNewPar("MV_PLSCTES","0") == "0" // Tratamento para carregar as criticas apos  executar PLSAUTPMDD.
				aRetAux:= aClone(aRetMed)
			else
				aRetAux := aClone(aRet)
			endIf

			if len(aRetAux) == 0
				aRetAux := {.t.,{},"",""}
				aRet 	:= aClone(aRetAux)
			endIf

		endIf

		if ! empty(cPrioridade)

			if ! aRetAux[1]

				aRet := aClone(aRetAux)

			elseIf ! empty(cPrioridade) .and. ascan( aCodCri,{|x| x[1] == __aCdCri051[1] }) > 0

				//Tratamento de Prioridade sobre a critica de auditoria.
				// MV_PLSPRIO  Retorna as criticas que tem prioridade sobre a regra de auditoria
				aCodCri := PLSPRIOR(@aCodCri,cPrioridade)

			else
				aCodCri := aClone(aSlvCri)
			endIf

		elseIf !aRetAux[1]

			aRet 	:= aClone(aRetAux)

		else

			aCodCri := aClone(aSlvCri)

		endIf

		if len(aRet) == 0
			aRet := { .t., {} ,"" ,"" }
		endIf

	return(aRetAux)

	/*/{Protheus.doc} PLSTratPgA
Trata a regra do pagamento no ato
@type function
@author tuliocesar
@since 27.04.05
@version 1.0
	/*/
	function PLSTratPGA(cCodEsp,cOpeRda,cCodRda,cCdTbPd,cCodPro,cCodPRFExe,cCodLoc,cSequen,cMes,cAno,cSubEsp,dData,nQtd,cGrpInt,aDadUsr,cPadInt,;
			cRegAte,lValorGC,cHora,aRdas,cProRel,nPrPrRl,aValAcu,aRet,cCid,cPadCon,lTratRDA,lTratUsr,lRegPagAto,cTipPreGui,cLocal,lRpc,;
			cRegInt,cFinAte,cDente,cFaces,cTipoGuia,lforcou,aCompo,lAutoma)

		local aAreaBAU	:= {}
		local aValor	:= {}
		local lCompra	:= .f.
		local cIntPad	:= plsIntPad()
		local aPacote	:= {0,0,{},""}
		local aPacPro	:= {}
		local nPac		:= 0

		default cTipPreGui 	:= ""
		default cCodRda 	:= ""
		default cOpeRda 	:= ""
		default aRdas 		:= {}
		default cCodLoc 	:= ""
		default cCodEsp 	:= ""
		default cSubEsp 	:= ""
		default cLocal  	:= ""
		default lRpc		:= .t.
		default cRegInt 	:= ""
		default cFinAte		:= ""
		default cDente  	:= ""
		default cFaces  	:= ""
		default cTipoGuia 	:= ''
		default lforcou		:= .f.
		default aCompo		:= {}
		default lAutoma		:= .F.

		if len(aRet) >= 1 .and. valType(aRet[1]) == "L"

			lCompra := ! aRet[1]

			if lRegPagAto .and. len(aRet[2]) > 0 .and. valType(aRet[2]) == "A" .and. !lforcou// Ha Criticas porem temos um pagamento no ato se a criticar for para forçar o sistema nao calculo o pagto no ato
				lCompra := aRet[1]
			endIf

			if lCompra
				// Quando o procedimento vai para auditoria ele tem que preencher o valor
				// da compra, pq quem vai gerar o titulo eh o plsa790
				lCompra := !(ascan(aCodCri,{|x| x[1] == __aCdCri051[1]}) > 0)
			endIf

		endIf

		if lTratUsr .and. lRegPagAto

			// Corrigi matriz
			if len(aRet) <= 2
				aadd(aRet,"")
				aadd(aRet,"")
			endIf

			if len(aRet) <= 3
				aadd(aRet,"")
			endIf

			if ! empty(cCodPRFExe)

				aAreaBAU := BAU->(getArea())

				BAU->(dbSetOrder(5)) //BAU_FILIAL+BAU_CODBB0
				if BAU->( msSeek( xFilial("BAU") + cCodPRFExe) )

					aRdas := PLS720IBD7("0",0,cCdTbPd,cCodPro,"",cOpeRda,cCodRda,BAU->BAU_CONREG,BAU->BAU_SIGLCR,BAU->BAU_ESTCR,;
						BAU->BAU_CODBB0,cCodEsp,cCodLoc+cLocal,"3",cSequen,"1",cTipoGuia,dData,nil,@aCompo)

					if len(aCompo) == 0

						PLSPOSGLO(cIntPad,__aCdCri028[1],__aCdCri028[2],"1")
						aadd(aRet,.f.)
						aadd(aRet,{})
						aadd(aRet,{__aCdCri028[1],PLSBCTDESC()} )

						if ! lRpc

							aadd(aCodCri,{__aCdCri028[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro,cSequen})

							// alias e caminho da critica.
							PLSCOMPCRI(aCodCri,"BD4")

							aRet := aClone( eval(__bRetErr, "BD4", cCdTbPd+cCodPro) )

						endIf

					endIf

				endIf

				BAU->(restArea(aAreaBAU))

			endIf

			//Caso o precedimento seja pacote atualizará o valor
			BR8->(dbSetOrder(1)) //BR8_FILIAL + BR8_CODPAD + BR8_CODPSA
			If BR8->(MSSeek( xFilial("BR8") + cCdTbPd + cCodPro ))
				If BR8->BR8_TPPROC == "6"
					aPacPro := PlRetPac(cIntPad,cCodRda,cCdTbPd,cCodPro,,dData)

					for nPac := 1 to len(aPacPro)
						aadd(aPacote[3],{aPacPro[nPac][1],aPacPro[nPac][2],aPacPro[nPac][5],aPacPro[nPac][4],aPacPro[nPac][6],aPacPro[nPac][3]})

						aPacote[1] += aPacPro[nPac][5]
						aPacote[2] += aPacPro[nPac][4]
						aPacote[4] := aPacPro[nPac][10]
					next
				EndIf
			EndIf

			if len(aRet) >= 1 .and. valType(aRet[1]) == "L" .and. aRet[1]

				aValor := PLSCALCCOP(cCdTbPd,cCodPro,cMes,cAno,cCodRda,cCodEsp,cSubEsp,;
					cCodLoc,nQtd,dData,.t.,"",0,cGrpInt,aDadUsr,cPadInt,cPadCon,;
					{},cRegAte,0,lValorGC,lCompra,cHora,aRdas,cOpeRda,cTipPreGui,cProRel,nPrPrRl,aValAcu,;
					If(((aRet[1] .or. (ascan(aCodCri,{|x| x[1] == __aCdCri051[1]}) > 0)) .and. len(aRet) >= 3) .or. (len(aRet) >= 3 .and. lCompra).or. (len(aRet) >= 3 .and. !lCompra .and. !aRet[1]),aRet[3],''),;//se autorizou ou se vai pra auditoria
					if ((len(aRet) >= 4 .and. (aRet[1] .or. (ascan(aCodCri,{|x| x[1] == __aCdCri051[1]}) > 0))) .or.;
					(len(aRet) >= 4 .and. lCompra).or. (len(aRet) >= 4 .and. !lCompra .and. !aRet[1]),aRet[4],""),;
					nil,nil,cCid,,cTipoGuia,,,,,,,,,,,,,aPacote,,,,cRegInt,cFinAte,,,,cDente,cFaces)

				// Verifica se tem valor para pagamento no ato. OK, deve ser paga no ato
				if aValor[1] .and. aValor[16] == "1"

					PLSPOSGLO(cIntPad,__aCdCri056[1],__aCdCri056[2],"1")
					aadd(aRet,.t. ) 								//5
					aadd(aRet,aValor)								//6
					aadd(aRet,{__aCdCri056[1],PLSBCTDESC()} ) 		//7

					//Se for pagamento no ato mais o parametro estiver desligado nega
					if ! lRpc .and. getNewPar("MV_PLSWNAT",.f.)

						aadd(aCodCri,{__aCdCri056[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro,cSequen})

						// alias e caminho da critica.
						PLSCOMPCRI(aCodCri,"ATO")

						aRet := aClone( eval(__bRetErr, "ATO", cCdTbPd+cCodPro) )

					endIf

				elseIf aValor[1]

					aadd(aRet,.f.)
					aadd(aRet,{})
					aadd(aRet,{"",""})
					aadd(aRet,aValor[5])
					aadd(aRet,aValor[9])

				endIf

			endIf

		endIf

	return(aRet)

	/*/{Protheus.doc} PLSCHKExi
Verifica se existe alguma critica na matriz
@type function
@author tuliocesar
@since 01.08.05
@version 1.0
	/*/
	function PLSCHKExi(aMat,cCampo, lOdonto)
		Default lOdonto := .F.

		If lOdonto
			return(ascan( aMat,{|x| x[1]+x[7]+x[3] == cCampo } ) > 0)
		EndIf

	return(ascan( aMat,{|x| x[1]+x[7] == cCampo } ) > 0)

	/*/{Protheus.doc} PlRetPaQtd
Retorna a prametrizacao da quantidade por nivel de cobertura
@type function
@author tuliocesar
@since 01.08.05
@version 1.0
	/*/
	function PlRetPaQtd(cAlias)
		local aRet := {}

		If  &(cAlias)->(FieldPos(cAlias+"_QTDESP"))  > 0
			aadd(aRet,{ &(cAlias)->(&( cAlias + "_QTDESP" ) ) } )
		EndIf

		If	&(cAlias)->(FieldPos(cAlias+"_QTDMED"))  > 0
			aadd(aRet,{ &(cAlias)->(&(cAlias + "_QTDMED" ) ) } )
		EndIf

		If &(cAlias)->(FieldPos(cAlias+"_QTDPAT"))  > 0
			aadd(aRet,{ &(cAlias)->(&( cAlias + "_QTDPAT" ) ) } )
		EndIf

	return aRet

	/*/{Protheus.doc} PlRetPaPer
Retorna a prametrizacao da peridicidade p nivel de cobert.
@type function
@author tuliocesar
@since 01.08.05
@version 1.0
	/*/
	function PlRetPaPer(cAlias,cChave)
		local aRet := {}

		if !empty(cChave)

			(cAlias)->(dbSetOrder(1))
			(cAlias)->( msSeek( xFilial(cAlias) + cChave ) )

		endIf


		If  &(cAlias)->(FieldPos(cAlias+"_PTRESP"))  > 0 .and.;
				&(cAlias)->(FieldPos(cAlias+"_PTRMED"))  > 0 .and.;
				&(cAlias)->(FieldPos(cAlias+"_PTRPAT"))  > 0

			aadd(aRet,{&(cAlias)->(&(cAlias+"_PTRESP"))})
			aadd(aRet,{&(cAlias)->(&(cAlias+"_PTRMED"))})
			aadd(aRet,{&(cAlias)->(&(cAlias+"_PTRPAT"))})
		endIf

	return aRet

	/*/{Protheus.doc} PlReforBD6
Retorna a parametrizacao da peridicidade p nivel de cobert.
A pergunta que se deve fazer no momento de preencher aqueles campos referentes
a parametros de Quantidade e Periodicidade é simples, para melhor
entendimento, por exemplo, no momento de se preencher o campo CID, para
uma periodicidade igual a 20, pergunta-se EH VINTE POR CID ? se tiver
vazio EH, caso estiver preenchido segue a regra do preenchimento
@type function
@author tuliocesar
@param cTipo, caracter, 1 -> Periodicidade
2 -> Quantidade
@since 01.08.05
@version 1.0
	/*/
	function PlReforBD6(cTipo,aQtd,aPerio,cCodEsp,cCodRda,cCid,cAlias,cTipPre,cRdaEDI,cEspExe,cEspSol,lGuiLib)

		local cSQL			:= ""
		local lEspecia 	:= .t.
		local lRedeAte 	:= .f.
		local lPatolog 	:= .t.
		local cSim			:= "1"
		default cAlias	:= ""
		default cTipPre	:= ""
		default cRdaEDI	:= ""
		default cEspExe	:= ""
		default cEspSol := ""
		default lGuiLib	:= .F.

		if cTipo == "1" .and. len(aPerio) > 0
			lEspecia := If(empty(aPerio[1][1]),.f.,If(aPerio[1][1]==cSim,.t.,.f.))
			lRedeAte := If(empty(aPerio[2][1]),.f.,If(aPerio[2][1]==cSim,.t.,.f.))
			lPatolog := If(empty(aPerio[3][1]),.f.,If(aPerio[3][1]==cSim,.t.,.f.))
		elseIf cTipo == "2" .and. len(aQtd) > 0
			lEspecia := If(empty(aQtd[1][1]),.f.,If(aQtd[1][1]==cSim,.t.,.f.))
			lRedeAte := If(empty(aQtd[2][1]),.f.,If(aQtd[2][1]==cSim,.t.,.f.))
			lPatolog := If(empty(aQtd[3][1]),.f.,If(aQtd[3][1]==cSim,.t.,.f.))
		elseIf cTipo == "2" .and. len(aQtd) == 0
			lEspecia := .f.
			lRedeAte := .f.
			lPatolog := .f.
		endIf

		SX6->(dbSetOrder(1))

		if cTipo == "1"
			// tratar a especialidade
			if lEspecia .and. ! empty(cCodEsp)
				if !empty(cEspExe) .And. lGuiLib == .F.
					cSQL += " (( BD6_ESPEXE <> ' ' AND BD6_ESPEXE = '"+cEspExe+"' ) OR ( BD6_ESPEXE = ' ' AND BD6_CODESP = '"+cEspExe+"' ) OR (BD6_ESPEXE = ' ' AND BD6_ESPSOL = '"+cEspExe+"')) AND "
				elseif !empty(cEspSol) .And. lGuiLib == .T.
					cSQL += " (( BD6_ESPSOL <> ' ' AND BD6_ESPSOL = '"+cEspSol+"' ) OR ( BD6_ESPSOL = ' ' AND BD6_CODESP = '"+cEspSol+"' ) OR (BD6_ESPSOL = ' ' AND BD6_ESPEXE = '"+cEspSol+"')) AND "
				elseIf empty(cEspExe) .And. lGuiLib == .F.
					cSQL += " (BD6_CODESP = '"+cCodEsp+"' OR BD6_ESPEXE = '"+cCodEsp+"' OR BD6_ESPSOL = '"+cCodEsp+"') AND "
				elseIf empty(cEspSol) .And. lGuiLib == .T.
					cSQL += " (BD6_CODESP = '"+cCodEsp+"' OR BD6_ESPSOL = '"+cCodEsp+"' OR BD6_ESPEXE = '"+cCodEsp+"') AND "
				endIf
			endIf

			if BD6->(FieldPos("BD6_RDAEDI")) > 0 .and. cTipPre == cMV_PLSTPIN .and. !empty(cRdaEDI)
				cSQL += " BD6_RDAEDI = '"+cRdaEDI+"' AND "
			else
				if lRedeAte .or. getNewPar("MV_PLSPRDA","0") == "1"
					cSQL += " BD6_CODRDA = '"+cCodRda+"' AND "
				endIf
			endIf

			if lPatolog .or. getNewPar("MV_PLSVCID","0") == "1"
				if ! empty(cCid)
					lPatolog := .t.
					cSQL += " BD6_CID = '"+cCid+"' AND "
				else
					lPatolog := .f.
					cSQL += " BD6_CID = '"+Space(len(BD6->BD6_CID))+"' AND "
				endIf
			endIf

		elseIf cTipo == "2"

			if lEspecia  .and. ! empty(cCodEsp)
				if !empty(cEspExe) .And. lGuiLib == .F.
					cSQL += " (( BD6_ESPEXE <> ' ' AND BD6_ESPEXE = '"+cEspExe+"' ) OR ( BD6_ESPEXE = ' ' AND BD6_CODESP = '"+cEspExe+"' ) OR (BD6_ESPEXE = ' ' AND BD6_ESPSOL = '"+cEspExe+"')) AND "
				elseIf !empty(cEspSol) .And. lGuiLib == .T.
					cSQL += " (( BD6_ESPSOL <> ' ' AND BD6_ESPSOL = '"+cEspSol+"' ) OR ( BD6_ESPSOL = ' ' AND BD6_CODESP = '"+cEspSol+"' ) OR (BD6_ESPSOL = ' ' AND BD6_ESPEXE = '"+cEspSol+"')) AND "
				elseIf empty(cEspExe) .And. lGuiLib == .F.
					cSQL += " (BD6_CODESP = '"+cCodEsp+"' OR BD6_ESPEXE = '"+cCodEsp+"' OR BD6_ESPSOL = '"+cCodEsp+"') AND "
				elseIf empty(cEspSol) .And. lGuiLib == .T.
					cSQL += " (BD6_CODESP = '"+cCodEsp+"' OR BD6_ESPSOL = '"+cCodEsp+"' OR BD6_ESPEXE = '"+cCodEsp+"') AND "
				endIf
			endIf

			if BD6->(FieldPos("BD6_RDAEDI")) > 0 .and. cTipPre == cMV_PLSTPIN .and. !empty(cRdaEDI)
				cSQL += " BD6_RDAEDI = '"+cRdaEDI+"' AND "
			else
				if lRedeAte
					cSQL += " BD6_CODRDA = '"+cCodRda+"' AND "
				endIf
			endIf
			if lPatolog  .or. getNewPar("MV_PLSVCID","0") == "1"
				if ! empty(cCid)
					cSQL += " BD6_CID = '"+cCid+"' AND "
				else
					lPatolog := .f.
					cSQL += " BD6_CID = '"+Space(len(BD6->BD6_CID))+"' AND "
				endIf
			endIf
		endIf

	return {lEspecia,lRedeAte,lPatolog,cSQL}

	/*/{Protheus.doc} PlsRetRDA
Retorna parametros de atendimento especiais para RDA
@type function
@author tuliocesar
@since 01.08.05
@version 1.0
	/*/
	function PlsRetRDA(cOpeRda,cCodEsp,aDadRDA)
		local aRet 	   		:= {'',{0,0,''}}
		local cCodRDA  		:= aDadRDA[02]
		local aVet	   		:= {}
		local nI       		:= 1
		local cChavePar		:= ""

		BAQ->(dbSetOrder(1))
		BBF->(dbSetOrder(1))

		if ! BAQ->(msSeek(xFilial("BAQ")+cOpeRda+cCodEsp))

			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',STR0081+" ["+xFilial("BAQ")+cOpeRda+cCodEsp+"] "+STR0082 , 0, 0, {})//"PLS - Chave"###"nao localizado no cadastro de especialidade"

			aRet[1]	:= "BAQ"

		else

			aRet := {"BAQ",{BAQ->BAQ_IDAMIN,BAQ->BAQ_IDAMAX,BAQ->BAQ_SEXO}}

			//so preencho se eu tiver que varrer todas especialidades
			if getNewPar("MV_PLSCTES","0") == "1"

				if BBF->(msSeek(xFilial("BBF")+cCodRDA+cOpeRDA))

					while !BBF->(eof()) .and. xFilial("BBF")+cCodRDA == BBF->(BBF_FILIAL+BBF_CODIGO)

						if BBF->BBF_CODESP <> cOpeRDA + cCodEsp

							if empty(BBF->BBF_DATBLO) .and. aScan(aVet,{|x| x[1] == BBF->BBF_IDAMIN .and. x[2] == BBF->BBF_IDAMAX .and. x[3] == BBF->BBF_SEXO } ) == 0
								aadd(aVet,{BBF->BBF_IDAMIN,BBF->BBF_IDAMAX,BBF->BBF_SEXO})
							endIf

						endIf

						BBF->(dbSkip())
					endDo

				endIf

			endIf

			if 	BBF->( msSeek(xFilial("BBF")+cCodRDA+cOpeRDA+cCodEsp)) .and. empty(BBF->BBF_DATBLO)


				if BBF->BBF_IDAMAX > 0 .or. ! empty(BBF->BBF_SEXO)
					aRet[1]	   := "BBF"
					aRet[2][1] := BBF->BBF_IDAMIN
					aRet[2][2] := BBF->BBF_IDAMAX
					aRet[2][3] := BBF->BBF_SEXO
				endIf

				if len(aVet) > 0

					for nI := 1 to len(aVet)

						aadd(aRet,aVet[nI])

					next

				endIf

			endIf

		endIf

	return aRet

	/*/{Protheus.doc} PLSTratReg
Trata a regra da  localidade x regiao x rede credenciada.
@type function
@author tuliocesar
@since 29.11.06
@version 1.0
	/*/
	function PLSTratReg(aRetPro,aDadRDA,aDadUsr,aRet,cLocalExec,cTpLocExec,cCdTbPd,cCodPro)
		local lAutorizado	:= .f.
		local lRet			:= .t.
		local cMatVid		:= aDadUsr[5]
		local cCodPla		:= aDadUsr[11]
		local cVersao		:= aDadUsr[12]
		local cCodOpe		:= __CUSERID
		local cIntPad		:= PlsIntPad()
		local aRegiao		:= {}
		local I				:= 0
		local nOrdBEA		:= BEA->(indexOrd())
		local nRecBEA		:= BEA->(recno())
		local nOrdBE2		:= BE2->(indexOrd())
		local nRecBE2		:= BE2->(recno())
		local bRest       := { || BEA->(dbSetOrder(nOrdBEA)),BEA->(dbGoto(nRecBEA)),BE2->(dbSetOrder(nOrdBE2)),BE2->(dbGoto(nRecBE2))}

		BY8->(dbSetOrder(1))
		if BY8->(msSeek(xFilial("BY8")+cIntPad+cCodOpe))

			while !BY8->(eof()) .and. BY8->BY8_CODOPE == cCodOpe

				aadd(aRegiao,BY8->BY8_CODREG)

				BY8->(dbSkip())
			endDo

		endIf

		BIB->(dbSetOrder(1))
		BB8->(dbSetOrder(1))
		BIC->(dbSetOrder(1))
		BY7->(dbSetOrder(1))
		BY9->(dbSetOrder(1))
		BTS->(dbSetOrder(1))
		BTS->(msSeek(xFilial("BTS")+cMatvid))

		for i := 1 to len(aRegiao)

			cCepUsr := BTS->BTS_CEPUSR
			cMunic  := BTS->BTS_CODMUN

			if BY9->(msSeek(xFilial("BY9")+cIntPad+cCodPla+cVersao))

				while BY9->(!eof()) .and. BY9->(BY9_FILIAL+BY9_CODIGO+BY9_VERSAO)== xFilial("BY9")+cIntPad+cCodPla+cVersao

					if BY9->BY9_CODREG == aRegiao[i]

						if BIB->(msSeek(xFilial("BIB")+cIntPad+aRegiao[i]))

							if BB8->(msSeek(xFilial("BB8")+aDadRDA[2]+aDadRDA[14]+aDadRDA[18]))

								if BB8->(fieldPos("BB8_REGMUN"))== 0
									lAutorizado:= .t.
								else

									if BB8->BB8_REGMUN == aRegiao[i]

										if (BIB->BIB_TIPO == "1" .or. BIB->BIB_TIPO == "3")

											if !BIC->(msSeek(xFilial("BIC")+cIntPad+cMunic))

												if BY7->(msSeek(xFilial("BY7")+cIntPad+aRegiao[i],.t.))

													while BY7->(!eof()) .and. BY7->BY7_CODREG == aRegiao[i]

														if cCepUsr >= BY7->BY7_CEPDE .and. cCepUsr <= BY7->BY7_CEPATE
															lAutorizado := .t.
															Exit
														endIf

														BY7->(dbSkip())
													endDo

												endIf
											else
												lAutorizado := .t.
											endIf

										endIf

									endIf

								endIf
							else
								if BY7->(msSeek(xFilial("BY7")+cIntPad+cCepUsr,.t.))
									lAutorizado := .t.
								endIf
							endIf
						endIf
					endIf
					BY9->(dbSkip())
				endDo
			endIf
		next

		if !lAutorizado .and. PLSPOSGLO(cIntPad,__aCdCri125[1],__aCdCri125[2],cLocalExec,'0',cTpLocExec) .and. PLSCHKCRI( {'BAU',aDadRda[2],__aCdCri125[1]} )

			aRet := aClone(aRetPro)
			aadd(aCodCri,{__aCdCri125[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro}) //localidade não é permitida para este usuário

			// alias e caminho da critica.
			PLSCOMPCRI(aCodCri,"BAU")

			aRet := {.f.,aCodCri,"BAU",.f.}
		endIf

		eval(bRest)

	return(aRet)

	/*/{Protheus.doc} PLSVLDOCD
Valida se o CID sera obrigatorio ou nao...
@type function
@author tuliocesar
@since 20.04.07
@version 1.0
	/*/
	function PLSVLDOCD(cCdTbPd,cCodPro,cLocalExec,cCid,nQtd,lTratSolic,lTratExe,cTpLocExec,cTipoProc,cChavGui,cTipGuia)
		local lRet			:= .f.
		local aRet 			:= {.t.,{},"","",.f.}

		local lProrrog      := .F.

		default nQtd 		:= 0
		default lTratSolic 	:= .f.
		default lTratExe   	:= .f.
		default cTpLocExec 	:= ""
		default cTipoProc  	:= ""
		default cChavGui    := ""
		default cTipGuia    := ""

		//Guia de prorrogacao ignoro a verificacao de CID
		if cTipGuia == "11"
			lProrrog := .T.
		endIf

		if funName() == "RPC"

			if 	!lProrrog .and. empty(cCid) .and. PLSPOSGLO(PLSINTPAD(),__aCdCri040[1],__aCdCri040[2],cLocalExec,'1',cTpLocExec) .and. BR8->BR8_CIDOBR == "1" .and. !IsInCallStack("PLVLDPRE")

				lRet := .f.
				aadd(aCodCri,{__aCdCri040[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro,subStr(cChavGui,34,3)}) //nelson inclui a ultima posicao do array

				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"BR8")

				aRet := {.f.,aCodCri,"BR8","",.f.}

			endIf

		else

			if 	!lProrrog .and. empty(cCid) .and. PLSPOSGLO(PLSINTPAD(),__aCdCri040[1],__aCdCri040[2],cLocalExec,'1',cTpLocExec) .and. BR8->BR8_CIDOBR == "1"

				lRet := .f.
				aadd(aCodCri,{__aCdCri040[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro,subStr(cChavGui,34,3)}) //nelson inclui a ultima posicao do array

				// alias e caminho da critica.
				PLSCOMPCRI(aCodCri,"BR8")

				aRet := {.f.,aCodCri,"BR8","",.f.}

			endIf
		endIf

		//Antigo ponto de chamada da validação crítica 078. A chamada da validação agora está na PLSVLDAut. Alteração 20/04/2020.

	return(aRet)

	/*/{Protheus.doc} PlsGrpQtd
Verifica a regra do grupo de quantidade
@type function
@author tuliocesar
@since 12.05.07
@version 1.0
	/*/
	function PLSGrpQtd(cCdTbPd,cCodPro,aDadUsr,aRet,nQtdSoli,dData,nRegBD6,cHora,cLocalExec)
		local aArea		:= getArea()
		local cMatrUsr	:= aDadUsr[2]
		local cOpeUsr   := Subs(cMatrUsr,atCodOpe[1],atCodOpe[2])
		local cCodEmp   := Subs(cMatrUsr,atCodEmp[1],atCodEmp[2])
		local cMatric   := Subs(cMatrUsr,atMatric[1],atMatric[2])
		local cTipReg   := Subs(cMatrUsr,atTipReg[1],atTipReg[2])
		local cDigito   := Subs(cMatrUsr,atDigito[1],atDigito[2])
		local cNumCon   := aDadUsr[9]
		local cVerCon   := aDadUsr[39]
		local cSubCon   := aDadUsr[41]
		local cVerSub   := aDadUsr[42]
		local cCodPla   := aDadUsr[11]
		local cUniPer   := ""
		local cCodAux   := ""
		local cChave    := ""
		local cSQL		:= ""
		local cCodNiv   := ""
		local dDatAnaIni:= ctod("")
		local dDatInc   := aDadUsr[66]
		local dDataSe	:= ctod("")
		local nGravi    := 1
		local nRecBD6 	:= 0
		local nQtdEve	:= 0
		local nAux1 	:= 0
		local nAux2 	:= 0
		local nQtd		:= 0
		local nQtdPer   := 0
		local nI		:= 0
		local nJ		:= 0
		local nNiveis   := 0

		local aGrupos   := {}
		local aRetAux	:= {}
		local aProcs	:= {0,"",{},""}

		local cTipCon	:= ""
		local lTipCon	:= .f.
		local lCid		:= .f.		// Variavel para controlar se o cadastro esta utilizando CID ou nao
		local cCid		:= ""		// Caso o sistema esteja utilizando o CID no grupo de quantidade, os mesmo eh guardado para verificacao na query do BD6
		local cCidate	:= ""		// Guarda o CID utilizando no atendimento
		local lTratNiv	:= .f.
		local lPLSQD6CT := existBlock("PLSQD6CT")

		if __cCdTbPd <> cCdTbPd .or. len(__aNiveis) == 0
			__cCdTbPd := cCdTbPd
			__aNiveis := PLSESPNIV(cCdTbPd)
		endIf

		// Tratamento item,subgrupo,grupo
		// Pego o nome do campo referente ao nivel que me foi passado na funcao
		// Depois pego o maior nivel possivel existente
		if len(__aNiveis) > 0
			nNiveis := (__aNiveis[1]+1)
		else
			PLSPOSGLO(PLSINTPAD(),__aCdCri075[1],__aCdCri075[2],cLocalExec)
			aRet := { .f.,   { {__aCdCri075[1],PLSBCTDESC(),"", BCT->BCT_TIPO, BCT->BCT_NIVEL,cCdTbPd,cCodPro} } }

			restArea(aArea)

			return aRet

		endIf

		// Pega o CID do atendimento ou liberacao, para verificacao da configuracao |
		// no grupo de quantidade.
		if funName() == "PLSA094A" .or. funName() == "PLSA094B"
			cCidate := M->BE1_CID
		endIf
		// Sequencia da pesquisa
		// BW9 - Grupo Quantidade x Usuario
		// BW7 - Grupo Quantidade x Familia
		// BW5 - Grupo Quantidade x Produto x Subcontrato
		if aProcs[1] == 0 .and. empty(aProcs[2])

			BW9->(dbSetOrder(1))
			BW2->(dbSetOrder(1))

			if BW9->(msSeek(xFilial("BW9")+cOpeUsr+cCodEmp+cMatric+cTipReg))

				while !BW9->(eof()) .and. BW9->(BW9_FILIAL + BW9_CODINT + BW9_CODEMP + BW9_MATRIC + BW9_TIPREG) == xFilial("BW9")+cOpeUsr+cCodEmp+cMatric+cTipReg .and. aProcs[1] == 0 .and. empty(aProcs[2])

					//pesquiso o cabecalho
					if BW2->(msSeek(xFilial("BW2")+BW9->(BW9_CODINT+BW9_CODGRU))) .and. aProcs[1] == 0 .and. empty(aProcs[2])

						//Verifica se o CID esta preenchido, se siim guarda o mesmo
						//para ser utilizado na query do BD6.
						//Se existir CID, o sistema não vai consultar os procedimentos.
						lCid := !empty(BW2->BW2_CODDOE)
						cCid := BW2->BW2_CODDOE

						if lCid

							if cCid == cCidate
								aProcs[1] := BW2->BW2_QTD
								aProcs[2] := BW2->BW2_UNCA
								aProcs[4] := BW2->BW2_CODGRU
							endIf

						else

							for nJ := 1 to nNiveis

								if nJ == 1
									cChave  := xFilial("BW3")+BW2->(BW2_CODINT+BW2_CODGRU)+cCdTbPd+cCodPro
								else
									cCodAux := Subs(cCodPro,__aNiveis[2,(nJ-1),1],__aNiveis[2,(nJ-1),2])
									cCodAux := cCodAux+Space(len(BW3->BW3_CDNV01)-len(cCodAux))+__aNiveis[2,(nJ-1),3]
									cChave  := xFilial("BW3")+BW2->(BW2_CODINT+BW2_CODGRU)+cCdTbPd+cCodAux
								endIf

								//pesquiso o procedimento
								BW3->(dbSetOrder(nJ))
								if BW3->(msSeek(cChave))

									aProcs[1] := BW2->BW2_QTD
									aProcs[2] := BW2->BW2_UNCA
									aProcs[4] := BW2->BW2_CODGRU

									//dou um seek no começo da tabela para iniciar do topo
									if BW3->(msSeek(xFilial("BW3")+BW2->(BW2_CODINT+BW2_CODGRU)))

										while !BW3->(eof()) .and. xFilial("BW3")+BW2->(BW2_CODINT+BW2_CODGRU) == BW3->(BW3_FILIAL+BW3_CODINT+BW3_CODGRU)

											nI := ascan(__aNiveis[2],{|x| x[3] == BW3->BW3_NIVEL})//este nI sempre tem que ser > 0

											if nI <> 0
												cCodNiv := __aNiveis[2,nI,4]
												nGravi  := nI
											else
												cCodNiv := ""
												nGravi  := 1
											endIf

											aadd(aProcs[3],{BW3->BW3_CODPAD,BW3->BW3_CODPSA,BW3->BW3_NIVEL,cCodNiv,nGravi})

											BW3->(dbSkip())
										endDo

										Exit
									endIf

								endIf

							next

						endIf

					endIf

					BW9->(dbSkip())
				endDo

			endIf

		endIf

		if aProcs[1] == 0 .and. empty(aProcs[2])

			BW7->(dbSetOrder(1))
			BW2->(dbSetOrder(1))

			if BW7->(msSeek(xFilial("BW7")+cOpeUsr+cCodEmp+cMatric))

				while !BW7->(eof()) .and. BW7->(BW7_FILIAL + BW7_CODINT + BW7_CODEMP + BW7_MATRIC) == xFilial("BW7")+cOpeUsr+cCodEmp+cMatric .and. aProcs[1] == 0 .and. empty(aProcs[2])

					if BW2->(msSeek(xFilial("BW2")+BW7->(BW7_CODINT+BW7_CODGRU))) .and. aProcs[1] == 0 .and. empty(aProcs[2])

						//Verifica se o CID esta preenchido, se siim guarda o mesmo
						//para ser utilizado na query do BD6.
						//Se existir CID, o sistema não vai consultar os procedimentos.
						lCid := !empty(BW2->BW2_CODDOE)
						cCid := BW2->BW2_CODDOE

						if lCid

							if cCid == cCidate
								aProcs[1] := BW2->BW2_QTD
								aProcs[2] := BW2->BW2_UNCA
								aProcs[4] := BW2->BW2_CODGRU
							endIf

						else

							for nJ := 1 to nNiveis

								if nJ == 1
									cChave  := xFilial("BW3")+BW2->(BW2_CODINT+BW2_CODGRU)+cCdTbPd+cCodPro
								else
									cCodAux := Subs(cCodPro,__aNiveis[2,(nJ-1),1],__aNiveis[2,(nJ-1),2])
									cCodAux := cCodAux+Space(len(BW3->BW3_CDNV01)-len(cCodAux))+__aNiveis[2,(nJ-1),3]
									cChave  := xFilial("BW3")+BW2->(BW2_CODINT+BW2_CODGRU)+cCdTbPd+cCodAux
								endIf

								//pesquiso o procedimento
								BW3->(dbSetOrder(nJ))

								if BW3->(msSeek(cChave))

									aProcs[1] := BW2->BW2_QTD
									aProcs[2] := BW2->BW2_UNCA
									aProcs[4] := BW2->BW2_CODGRU

									//dou um seek no começo da tabela para iniciar do topo
									if BW3->(msSeek(xFilial("BW3")+BW2->(BW2_CODINT+BW2_CODGRU)))

										while !BW3->(eof()) .and. xFilial("BW3")+BW2->(BW2_CODINT+BW2_CODGRU) == BW3->(BW3_FILIAL+BW3_CODINT+BW3_CODGRU)

											nI := ascan(__aNiveis[2],{|x| x[3] == BW3->BW3_NIVEL})//se for igual a zero eh do tipo procedimento

											if nI <> 0
												cCodNiv := __aNiveis[2,nI,4]
												nGravi  := nI
											else
												cCodNiv := ""
												nGravi := 1
											endIf

											aadd(aProcs[3],{BW3->BW3_CODPAD,BW3->BW3_CODPSA,BW3->BW3_NIVEL,cCodNiv,nGravi})
											BW3->(dbSkip())
										endDo

										Exit

									endIf

								endIf

							next

						endIf

					endIf

					BW7->(dbSkip())
				endDo

			endIf

		endIf

		if aProcs[1] == 0 .and. empty(aProcs[2])

			BW5->(dbSetOrder(1))
			BW2->(dbSetOrder(1))

			if BW5->(msSeek(xFilial("BW5")+cOpeUsr+cCodEmp+cNumCon+cVerCon+cSubCon+cVerSub+cCodPla))

				while !BW5->(eof()) .and. BW5->(BW5_FILIAL + BW5_CODINT + BW5_CODIGO + BW5_NUMCON + BW5_VERCON + BW5_SUBCON + BW5_VERSUB + BW5_CODPRO) == xFilial("BW5")+cOpeUsr+cCodEmp+cNumCon+cVerCon+cSubCon+cVerSub+cCodPla .and. aProcs[1] == 0 .and. empty(aProcs[2])

					if BW2->(msSeek(xFilial("BW2")+BW5->(BW5_CODINT+BW5_CODGRU))) .and. aProcs[1] == 0 .and. empty(aProcs[2])

						//Verifica se o CID esta preenchido, se siim guarda o mesmo
						//para ser utilizado na query do BD6.
						//Se existir CID, o sistema não vai consultar os procedimentos.
						lCid := !empty(BW2->BW2_CODDOE)
						cCid := BW2->BW2_CODDOE

						if lCid

							if cCid == cCidate
								aProcs[1] := BW2->BW2_QTD
								aProcs[2] := BW2->BW2_UNCA
								aProcs[4] := BW2->BW2_CODGRU
							endIf

						else

							for nJ := 1 to nNiveis

								if nJ == 1
									cChave  := xFilial("BW3")+BW2->(BW2_CODINT+BW2_CODGRU)+cCdTbPd+cCodPro
								else
									cCodAux := Subs(cCodPro,__aNiveis[2,(nJ-1),1],__aNiveis[2,(nJ-1),2])
									cCodAux := cCodAux+Space(len(BE9->BE9_CDNV01)-len(cCodAux))+__aNiveis[2,(nJ-1),3]
									cChave  := xFilial("BW3")+BW2->(BW2_CODINT+BW2_CODGRU)+cCdTbPd+cCodAux
								endIf

								//pesquiso o procedimento
								BW3->(dbSetOrder(nJ))

								if BW3->(msSeek(cChave))

									aProcs[1] := BW2->BW2_QTD
									aProcs[2] := BW2->BW2_UNCA
									aProcs[4] := BW2->BW2_CODGRU

									//dou um seek no começo da tabela para iniciar do topo
									if BW3->(msSeek(xFilial("BW3")+BW2->(BW2_CODINT+BW2_CODGRU)))

										while !BW3->(eof()) .and. xFilial("BW3")+BW2->(BW2_CODINT+BW2_CODGRU) == BW3->(BW3_FILIAL+BW3_CODINT+BW3_CODGRU)

											nI := ascan(__aNiveis[2],{|x| x[3] == BW3->BW3_NIVEL})//este nI sempre tem que ser > 0

											if nI <> 0
												cCodNiv := __aNiveis[2,nI,4]
												nGravi  := nI
											else
												cCodNiv := ""
												nGravi := 1
											endIf

											aadd(aProcs[3],{BW3->BW3_CODPAD,BW3->BW3_CODPSA,BW3->BW3_NIVEL,cCodNiv,nGravi})
											BW3->(dbSkip())
										endDo

										Exit

									endIf

								endIf

							next

						endIf

					endIf

					BW5->(dbSkip())
				endDo

			endIf
		endIf

		// Monta query de acesso...
		nQtdPer := aProcs[1]
		cUniPer := aProcs[2]

		if nQtdSoli <= nQtdPer

			cSQL := "SELECT BD6_QTDPRO,BD6_DATPRO,BD6_HORPRO "
			cSQL += "FROM "+RetSqlName("BD6")+" WHERE "
			cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
			cSQL += "BD6_OPEUSR = '"+cOpeUsr+"' AND "
			cSQL += "BD6_CODEMP = '"+cCodEmp+"' AND "
			cSQL += "BD6_MATRIC = '"+cMatric+"' AND "
			cSQL += "BD6_TIPREG = '"+cTipReg+"' AND "
			cSQL += "BD6_DIGITO = '"+cDigito+"' AND "
			//Se o cadastro da quantidade for por CID, o mesmo eh utilizado na query
			if lCid
				cSQL += "BD6_CID = '"+cCid+"' AND "
			endIf

			if cUniPer $ "1,2" //Por hora(1) ou por dia(2)
				cSQL += "BD6_DATPRO = '" + dtos(dData) + "' AND "
			elseIf cUniPer = "3" .or. cUniPer = "6"   //Por Mes ou por Semana
				cSQL += "subStrING(BD6_DATPRO,1,4) = '" + Str(Year(dData), 4) + "' AND subStrING(BD6_DATPRO,5,2) = '" + strZero(Month(dData), 2) + "' AND "
			elseIf cUniPer = "4"   //Por Ano

				if BI3->(FieldPos("BI3_TPCONT")) > 0
					lTipCon := .t.
					if len(aDadUsr) >= 86
						cTipCon := aDadUsr[86]
					endIf
				endIf

				if 	(lTipCon .and. cTipCon == "1") .or.;
						(lTipCon .and. empty(cTipCon).and. getNewPar("MV_PLSRQTD","1") == "1").or.;
						(!lTipCon .and. getNewPar("MV_PLSRQTD","1") == "1")//por ano civil

					cSQL += "subStrING(BD6_DATPRO,1,4) = '" + Str(Year(dData), 4) + "' AND "

					//Por ano contratual
					//dia que usr entrou      +   mes que usr entrou    +  ano do evento
				else

					dDatAnaIni := ctod(subs(dtos(dDatInc),7,2)+"/"+subs(dtos(dDatInc),5,2)+"/"+Str(Year(dData), 4))

					if dData < dDatAnaIni
						dDatAnaIni := ctod(subs(dtos(dDatInc),7,2)+"/"+subs(dtos(dDatInc),5,2)+"/"+Str(Year(dData)-1, 4))
					endIf

					cSQL += "BD6_DATPRO >= '"+dtos(dDatAnaIni)+"' AND BD6_DATPRO <= '"+dtos(dDatAnaIni+365)+"' AND "
				endIf
			endIf


			cSQL += " ( "

			cSQL += "BD6_CODPAD || BD6_CODPRO IN (SELECT BW3_CODPAD || BW3_CODPSA FROM "+RetSqlName("BW3")+" WHERE BW3_FILIAL = '" + xFilial("BW3") + "' AND BW3_CODPAD = '" + cCdTbPd + "' AND BW3_CODGRU = '" + aProcs[4] + "') "

			for nI := 1 to len(aProcs[3])

				// Tratamento item,subgrupo,grupo
				if __cCdTbPd <> aProcs[3][nI][1] .or. len(__aNiveis) == 0
					__cCdTbPd := aProcs[3][nI][1]
					__aNiveis := PLSESPNIV(aProcs[3][nI][1])
				endIf
				nNiveis := (__aNiveis[1]+1)

				if val(aProcs[3][nI][3]) <> nNiveis .and. len(__aNiveis[2]) >= aProcs[3][nI][5]

					if ! lTratNiv
						cSQL += " OR ( "
						lTratNiv := .t.
					else
						cSQL += " ) OR ( "
					endIf

					if !lPLSQD6CT
						cSQL += "BD6_CODPAD = '"+aProcs[3][nI][1]+"' AND "
					else
						cSQL += execBlock("PLSQD6CT",.f.,.f.,{aProcs[3][nI][1]})
					endIf

					cSQL += "BD6_"+aProcs[3][nI][4] + " = '"+Subs(aProcs[3][nI][2],__aNiveis[2,aProcs[3][nI][5],1],__aNiveis[2,aProcs[3][nI][5],2])+"' AND "
					cSQL += "BD6_NIVEL" + " >= '"+aProcs[3][nI][3]+"' "

				endIf

			next

			if lTratNiv
				cSQL += " ) "
			endIf

			cSQL += ") AND "
			cSQL += "( BD6_FASE = '3' OR BD6_FASE = '4') AND "
			cSQL += "( ( BD6_SITUAC = '1' ) OR ( BD6_SITUAC = '3' AND BD6_LIBERA = '1') )  AND  "

			// Funcao generica que trata campos do estorno
			if findFunction("PlReChvEst")
				aRetAux  := PlReChvEst("BD6",.t.,.f.,.t.,.f.)
				cSQL     += aRetAux[1]
			endIf

			cSQL += RetSqlName("BD6")+".D_E_L_E_T_ = ' ' "

			if nRegBD6 > 0
				cSQL += "AND "+ RetSqlName("BD6")+".R_E_C_N_O_ <> "+allTrim(Str(nRegBD6))+""
			endIf
			// Tratamento das guias nao pagas e nao cobradas
			// Pois se a guia nao tem valor de pagamento nem de cobranca ela de fato
			// nao foi realizada
			cSQL += " AND ((BD6_BLOCPA <> '1' AND BD6_VLRTPF > 0) OR ( SELECT COUNT(*) FROM "+ RetSqlName("BD7") +" WHERE "
			cSQL += " BD6_FILIAL = BD7_FILIAL AND "
			cSQL += " BD6_CODLDP = BD7_CODLDP AND "
			cSQL += " BD6_CODPEG = BD7_CODPEG AND "
			cSQL += " BD6_NUMERO = BD7_NUMERO AND "
			cSQL += " BD6_ORIMOV = BD7_ORIMOV AND "
			cSQL += " BD6_SEQUEN = BD7_SEQUEN AND "
			cSQL += RetSqlName("BD7")+".D_E_L_E_T_ = ' ' AND "
			cSQL += " (BD7_BLOPAG <> '1' AND BD7_VLRPAG > 0) "
			cSQL += ") > 0)  "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW alias "PLSVERQTD"

			while ! PLSVERQTD->(eof())

				if cUniPer == "1" .and. left(PLSVERQTD->BD6_HORPRO, 2) = left(cHora, 2)

					nQtd += PLSVERQTD->BD6_QTDPRO

					// tratamento da quantidade por semana ...
				elseIf cUniPer == "6"

					dDataSe := PLSVERQTD->BD6_DATPRO

					// soh vou pegar a quantidade de execucoes dentro da semana que ele estah
					// observe q pode entrar nesse if mesmo estando em semanas diferentes
					if (dData - dDataSe) <= 6
						// Posicao do dia da semana no vetor de dias da semana...
						// nAux1 := Dia da semana em que esta se solicitando o procedimento
						// nAux2 := Dia da semana em que foi realizado um procedimento qualquer
						nAux1 := ascan(aDias,{ |a| a == PLSDIASEM(dData)})
						nAux2 := ascan(aDias,{ |a| a == PLSDIASEM(PLSVERQTD->BD6_DATPRO)})
						// ele encontra-se na mesma semana ?
						if nAux1 >= nAux2
							nQtd += PLSVERQTD->BD6_QTDPRO
						endIf

					endIf

				elseIf cUniPer <> "1" .and. cUniPer <> "6"
					nQtd += PLSVERQTD->BD6_QTDPRO
				endIf

				PLSVERQTD->(dbSkip())
			endDo

			PLSVERQTD->(DbCloseArea())
			restArea(aArea)

		endIf

		// Testa se passou o limite...
		if nQtdPer > 0 .and. nQtdSoli + nQtd > nQtdPer .and. len(aProcs[3]) > 0

			if !aRet[1]
				aadd(aRet[2],{__aCdCri139[1],PLSBCTDESC(),"", BCT->BCT_TIPO, BCT->BCT_NIVEL,cCdTbPd,cCodPro})
				aadd(aRet[2],{""   ,STR0030 + X3COMBO("BR8_UNCA",cUniPer) + STR0031, Str(nQtdPer, 6),"","",cCdTbPd,cCodPro}) //"Quantidade permitida para o procedimento "###" foi excedida"
				aadd(aRet[2],{""   ,STR0032, Str(nQtd, 6), "","",cCdTbPd,cCodPro}) //"Quantidade ja executada pelo usuario"
				aadd(aRet[2],{""   ,STR0033, Str(nQtdSoli, 6), "","",cCdTbPd,cCodPro}) //"Quantidade solicitada"
				aadd(aRet[2],{""   ,STR0034, Str(Abs(nQtd+nQtdSoli-nQtdPer),6)   , "","",cCdTbPd,cCodPro})					 //"Quantidade Ultrapassada pelo usuario"
			else
				aRet := {.f., 	{ {__aCdCri139[1],PLSBCTDESC(),"", BCT->BCT_TIPO, BCT->BCT_NIVEL,cCdTbPd,cCodPro},;
					{""   ,STR0030 + X3COMBO("BR8_UNCA",cUniPer) + STR0031, Str(nQtdPer, 6),"","",cCdTbPd,cCodPro},; //"Quantidade permitida para o procedimento "###" foi excedida"
					{""   ,STR0032, Str(nQtd, 6), "","",cCdTbPd,cCodPro},; //"Quantidade ja executada pelo usuario"
					{""   ,STR0033, Str(nQtdSoli, 6), "","",cCdTbPd,cCodPro},; //"Quantidade solicitada"
					{""   ,STR0034, Str(Abs(nQtd+nQtdSoli-nQtdPer),6)   , "","",cCdTbPd,cCodPro} } }					 //"Quantidade Ultrapassada pelo usuario"
			endIf

		elseIf lCid		// Caso o sistema esteja utilzando CID, nao verifica o len do aProcs

			if nQtdPer > 0 .and. nQtdSoli + nQtd > nQtdPer

				if !aRet[1]
					aadd(aRet[2],{__aCdCri139[1],PLSBCTDESC(),"", BCT->BCT_TIPO, BCT->BCT_NIVEL,cCdTbPd,cCodPro})
					aadd(aRet[2],{""   ,STR0030 + X3COMBO("BR8_UNCA",cUniPer) + STR0031, Str(nQtdPer, 6),"","",cCdTbPd,cCodPro}) //"Quantidade permitida para o procedimento "###" foi excedida"
					aadd(aRet[2],{""   ,STR0032, Str(nQtd, 6), "","",cCdTbPd,cCodPro}) //"Quantidade ja executada pelo usuario"
					aadd(aRet[2],{""   ,STR0033, Str(nQtdSoli, 6), "","",cCdTbPd,cCodPro}) //"Quantidade solicitada"
					aadd(aRet[2],{""   ,STR0034, Str(Abs(nQtd+nQtdSoli-nQtdPer),6)   , "","",cCdTbPd,cCodPro})					 //"Quantidade Ultrapassada pelo usuario"
				else
					aRet := {.f., 	{	{__aCdCri139[1],PLSBCTDESC(),"", BCT->BCT_TIPO, BCT->BCT_NIVEL,cCdTbPd,cCodPro},;
						{""   ,STR0030 + X3COMBO("BR8_UNCA",cUniPer) + STR0031, Str(nQtdPer, 6),"","",cCdTbPd,cCodPro},; //"Quantidade permitida para o procedimento "###" foi excedida"
						{""   ,STR0032, Str(nQtd, 6), "","",cCdTbPd,cCodPro},; //"Quantidade ja executada pelo usuario"
						{""   ,STR0033, Str(nQtdSoli, 6), "","",cCdTbPd,cCodPro},; //"Quantidade solicitada"
						{""   ,STR0034, Str(Abs(nQtd+nQtdSoli-nQtdPer),6)   , "","",cCdTbPd,cCodPro} } }					 //"Quantidade Ultrapassada pelo usuario"
				endIf

			endIf

		endIf

		restArea(aArea)

	return aRet

	/*/{Protheus.doc} PLLimpCCri
Funcao generica para manipular aCodCri
@type function
@author tuliocesar
@since 12.05.07
@version 1.0
	/*/
	function PLLimpCCri(lLimpa,lSubst,aNewCri)
		default lLimpa  := .t. //indica se eh para limpar o aCodCri
		default lSubst  := .f. //indica se eh para substituir o aCodCri pelo aNewCri
		default aNewCri := {}

		if lLimpa
			aCodCri    := {}
		endIf

		if lSubst
			aCodCri := aClone(aNewCri)
		endIf

	return aClone(aCodCri)


	/*/{Protheus.doc} PLSABRANG
Verifica Abrangencia
@type function
@author daher
@since 06.12.07
@version 1.0
	/*/
	function PLSABRANG(cAreaAbr,cLocalExec,cTpLocExec,cCdTbPd,cCodPro,aDadUsr,aDadRda,aCriticas)
		local aArea			:= getArea()
		local nOrdBIA 		:= 0
		local nRecBIA 		:= 0
		local cCodRda 		:= ""
		local cAbrOpeRDA  	:= ""
		local cListAbrUsr 	:= ""
		local cOpeRda		:= PlsIntPad()
		local cAbranI 		:= ""
		local cAbranII	 	:= ""
		local lRet	  		:= .t.
		default aCriticas 	:= {}
		default aDadRda		:= {}

		cCodRda := iIf( len(aDadRda) > 2 , aDadRda[2],"" )

		// Tratamento da abrangencia
		if ! empty(cAreaAbr) .and. PLSPOSGLO(PLSINTPAD(),__aCdCri026[1],__aCdCri026[2],cLocalExec,"0",cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri026[1]} )

			// Verifico se a dadrda foi informada
			if len(aDadRda) >= 29 .and. ! empty(aDadRda[28])
				cOpeRda := aDadRda[28]
			endIf

			if len(aDadUsr) >= 65
				// meu usuario indo ate outra operadora ate outra operadora
				// a pessoa pode cadastrar a regra tanto na operadora que ele foi qto na operadora do usuario
				BIA->( dbSetOrder(2) )

				if BIA->( msSeek( xFilial("BIA") + aDadUsr[37] + cOpeRda ) ) .or. BIA->( msSeek( xFilial("BIA") + aDadUsr[45] + cOpeRda ) ) .and. ! empty(BIA->BIA_ABRREL) .and. (empty(BA1->BA1_DATREP) .or. ddatabase <= BA1->BA1_DATREP)
					cAbranI := BIA->BIA_ABRREL
				endIf

				if BIA->( msSeek( xFilial("BIA") + cOpeRda + aDadUsr[37] ) ) .or. BIA->( msSeek( xFilial("BIA") + cOpeRda + aDadUsr[45] ) ) .and. ! empty(BIA->BIA_ABRREL) .and. (empty(BA1->BA1_DATREP) .or. ddatabase <= BA1->BA1_DATREP)
					cAbranII := BIA->BIA_ABRREL
				endIf

				if ( !( allTrim(cAreaAbr) $ cAbranI ) .and. ! empty(cAbranI) ) .or. ( !( allTrim(cAreaAbr) $ cAbranII ) .and. ! empty(cAbranII) )

					lRet := .f.
					aadd(aCriticas,{__aCdCri026[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
					aadd(aCriticas,{"",STR0004,cAreaAbr,"","",cCdTbPd,cCodPro})
					aadd(aCriticas,{"",STR0005,BIA->BIA_ABRREL,"","",cCdTbPd,cCodPro})

					// alias e caminho da critica.
					PLSCOMPCRI(aCriticas,"BIA")

				endIf

			endIf

			If ExistBlock("PLSABRA1")
				aRetAbrang := ExecBlock("PLSABRA1",.F.,.F.,{aDadUsr, aDadRda, aCriticas})
				lRet := aRetAbrang[1] // True ou False
				aCriticas := aRetAbrang[2] //Array com as criticas
			Endif

			restArea(aArea)
		endIf

	return( { lRet, aCriticas } )

	/*/{Protheus.doc} PLSLOCRDA
Pegar os locais de atendimento da rda
@type function
@author alexander
@since 11.09.08
@version 1.0
	/*/
	function PLSLOCRDA(cCodRda,cOpeSol,cCodLoc)
		local aLocais := {}
		default cCodLoc	:= ""
		// Pegando os Locais de atendimentos da rda do solicitante
		BB8->( dbSetOrder(1) )//BB8_FILIAL + BB8_CODIGO + BB8_CODINT + BB8_CODLOC + BB8_local

		if !empty(cCodLoc) .and. BB8->( msSeek(xFilial("BB8")+cCodRda+cOpeSol+cCodLoc) )

			aadd(aLocais,{BB8->BB8_CODLOC,BB8->BB8_LOCAL})

		elseIf BB8->( msSeek(xFilial("BB8")+cCodRda) )

			while ! BB8->(eof()) .and. BB8->(BB8_FILIAL+BB8_CODIGO) == xFilial("BB8")+cCodRda

				aadd(aLocais,{BB8->BB8_CODLOC,BB8->BB8_LOCAL})

				BB8->(dbSkip())

			endDo

		endIf

	return(aLocais)

	/*/{Protheus.doc} PLSLOCESP
Verifica local e Especialidade da Rda (Profissional)
@type function
@author tuliocesar
@since 11.09.08
@version 1.0
	/*/
	function PLSLOCESP( cOpeRda,cCodRda,cCdTbPd,cCodPro,aDadRDA,cTipo,aDadUsr,cLocalExec,;
			cCodEsp,cCodLoc,lCheck,aLocais,dData,lAutorizado,aRet,aOldRet,;
			aRetMed,lFlag,cEspCri,lVldXML,cCodPRFSol,cEspSol )
		local nfor		:= 0
		local nPos 		:= 0
		local lRet		:= .f.
		local I			:= 0

		default aRet	:= {}
		default lFlag   := .f.
		default aRetMed := {}
		default aOldRet := {}
		default cEspCri	:= ""
		default lVldXML	:= .f.
		default cCodPRFSol := ""
		default cEspSol    := ""
		// Validacao na MDD
		aRetMed := PLSAUTPMDD(cOpeRda,cCodRda,cCdTbPd,cCodPro,aDadRDA,cTipo,aDadUsr,cLocalExec,cCodEsp,cCodLoc,lCheck,aLocais,dData,NIL,cEspSol,NIL,NIL,NIL,,cEspCri,lVldXML,cCodPRFSol)

		if ! aRetMed[1]

			if len(aRetMed[2]) > 0 .and. getNewPar("MV_PLSCTES","0") == "1"

				if ascan(aRetMed[2],{|x| x[1] == __aCdCri021[1] }) == 0
					//Apresento criticas junto com as que esta vindo com aRet
					aRet := {.F., {}, aRetMed[3], aRetMed[4]}
					For i:=1 to Len(aRetMed[2])
						aadd(aRet[2],aRetMed[2,i])
					Next i
				Endif
			Else
				aRet := aClone(aRetMed)
			Endif
		Else

			if ! lFlag
				aRet := aClone(aRetMed)
			endIf

			if len(aRetMed[2]) > 0 .and. getNewPar("MV_PLSCTES","0") == "1"

				// Esse tramento se faz necessario devido o parametro MV_PLSCTES esta ativado foi feito a liberação porem o acriticas de especialidasde anteriores coninua e preciso limpa-las
				aOldRet   := { .f., {} }
				lAnterior := .f.

				for i := 1 to len(aCodCri)

					if ! empty(aCodCri[i,1])

						lAnterior := .t.

						if ! PLSCHKExi(aOldRet[2], aCodCri[i,1] + aCodCri[i,7] ) .and. ! aCodCri[i,1] $ __aCdCri020[1] + "|" + __aCdCri021[1] // Preciso retirar a 007 pois o plsctes esta ativado e no final preciso exibir as outras critias
							aadd(aOldRet[2],aCodCri[i])
						else
							lAnterior := .f.
						endIf

					else

						if lAnterior
							aadd(aOldRet[2],aCodCri[i])
						endIf

					endIf

				next i

				aCodCri := aClone(aOldRet[2])

			endIf

			lRet := .t.


		endIf

	return(lRet)

	/*/{Protheus.doc} PLRELIBI
Veririfica se veio de uma liberacao e retira no sql
@type function
@author tuliocesar
@since 10.10.09
@version 1.0
	/*/
	function PLRELIBI(nRegBD6)
		local cSQL 		 := ""
		local cChvBE2Aux := ""
		local nRecBD6 	 := BD6->( recno() )
		local nRecBEA 	 := BEA->( recno() )

		// Se veio de uma liberacao exclui o item da liberacao
		BD6->( dbGoto(nRegBD6) )

		if ! empty(BD6->BD6_NRLBOR )

			BEA->( dbSetOrder(1) ) //BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT
			if BEA->( msSeek( xFilial("BEA") + BD6->BD6_NRLBOR ) )

				BE2->(dbSetOrder(6)) //BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_CODPAD + BE2_CODPRO
				cChvBE2Aux := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) + BD6->BD6_CODPAD + BD6->BD6_CODPRO

				if at('BE2_DENREG',BE2->(IndexKey()) ) > 0 .and. at('BE2_FADENT',BE2->(indexKey()) ) > 0
					cChvBE2Aux += BD6->BD6_DENREG + space( tamSx3("B05_CODIGO")[1] - len(BD6->BD6_DENREG) ) + BD6->BD6_FADENT
				endIf

				if BE2->(msSeek( xFilial("BE2") + cChvBE2Aux))
					cSQL += "BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_CODPAD+BD6_CODPRO <> '" + allTrim(BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)+BE2->(BE2_CODPAD+BE2_CODPRO)) + "' AND "
				endIf

			endIf

		endIf

		BD6->( dbGoto(nRecBD6) )
		BEA->( dbGoto(nRecBEA) )

	return(cSQL)

	/*/{Protheus.doc} PLVLDRESHO
Validacoes do Resumo
@type function
@author tuliocesar
@since 17.07.20
@version 1.0
	/*/
	function PLVLDRESHO(cNumPeg,cLocalExec,cTipoGrv,dDtAlta,cTipFat,lHonor,cMatric,cOrigem,;
			cLibEsp,cAuditoria,cNumImp,dDatPro,aItens,aMatBd6,aEventosAut,aEventosNeg,;
			aCriticas,aDadIte,PLSFLOGX,lDetalhe,cCodRda, cCodEsp, cSubEsp, cCodLoc, cLocal, cOpeOri, cCodPla, lWeb, lTemAux)

		local nfor2   		:= 0
		local nfor	  		:= 0
		local nPos			:= 0
		local cCodCri 		:= ""
		local cSeqMov 		:= ""
		local cCodPad 		:= ""
		local cCodPro 		:= ""
		local lEquipe 		:= .f.
		local lRet	  		:= .f.
		local cCodTab   	:= ""
		local cAliasTab 	:= ""
		local cOpeMov 		:= PlsIntPad()

		default cLibEsp		:= "0"
		default cAuditoria	:= "0"
		default cNumImp		:= ""
		default PLSFLOGX 	:= ""
		default dDatPro		:= ctod("")
		default aEventosAut := {}
		default aEventosNeg := {}
		default aCriticas   := {}
		default aDadIte		:= {}
		default aMatBd6		:= {}
		default lDetalhe	:= .t.
		default cCodEsp		:= ""
		default cSubEsp		:= ""
		default cCodLoc		:= ""
		default cLocal		:= ""
		default lWeb		:= .F.
		default lTemAux		:= .f.

		// aItens
		for nFor2 := 1 to len(aItens)

			cSeqMov := PLSRETDAD(aItens[nfor2],"SEQMOV")
			cCodPad := PLSRETDAD(aItens[nfor2],"CODPAD")
			cCodPro := PLSRETDAD(aItens[nfor2],"CODPRO")
			aTpPIte	:= PLSRETDAD(aItens[nfor2],"ATPPAR",{})
			cDente 	:= PLSRETDAD(aItens[nfor2],"DENTE","")
			cFace  	:= PLSRETDAD(aItens[nfor2],"FACE","")

			// Se tem equipe no item do resumo
			lEquipe := len(aTpPIte)>0

			if lEquipe

				aVetTab := PLSRETTAB(cCodPad,cCodPro,dDatPro,cOpeMov,cCodRda,cCodEsp,cSubEsp,cCodLoc + cLocal,dDatPro,"1",cOpeOri,cCodPla,"2","1")

				if aVetTab[1]

					cAliasTab := aVetTab[4]
					aCompo := PLSCOMEVE(aVetTab[3],cCodPad,cCodPro,cOpeMov,dDatPro, nil, nil, nil, cCodRda, cCodEsp, cSubEsp, cCodLoc)

					if len(aCompo) == 0
						return {.f.,,}
					else
						cCodTab := aCompo[1][15]
					endIf

				endIf

				lPart := .f.
				for nfor := 1 to len(aTpPIte)

					if __cTissVer < "3" .and. empty(aTpPIte[nfor,1]) .and. PLSPOSGLO(cOpeMov,__aCdCri099[1],__aCdCri099[2],cLocalExec)
						cCodCri := __aCdCri099[1]
						lPart := .t.
						exit
					endIf

					if !empty(aTpPIte[nfor,1]).and. PLSPOSGLO(cOpeMov,__aCdCri175[1],__aCdCri175[2],cLocalExec)

						if !empty(cCodTab) .and. PLSCHKGPA(cOpeMov,cCodTab,cCodPad,cCodPro,allTrim(aTpPIte[nfor][1]),,dtoc(date()),,lWeb,lTemAux)
							lPart := .t.
						endIf

					else
						lPart := .t.
					endIf

					if !lPart .and. PLSCHKCRI({'BAU',cCodRDA,__aCdCri175[1]})
						cCodCri := __aCdCri175[1]
					endIf

					if !empty(cCodCri)
						aadd( aCriticas,{cSeqMov,cCodCri,PLSBCTDESC(),cCodPad,cCodPro,cDente,cFace} )
						cCodCri := ""
					endIf

					if lHonor
						lPart := .f.
					endIf
				next

			endIf

		next

		if len(aCriticas) == 0
			lRet := .t.
		endIf

	return( {lRet,nPos,cSeqMov} )

	/*/{Protheus.doc} PLSCALCPER
Faz o calculo da periodicidade de acordo com os parametros
@type function
@author tuliocesar
@since 26.03.10
@version 1.0
	/*/
	function PLSCALCPER(cUniPer,dData,dUltimo,nPerioPer,cUltimo,cProximo,cHora,nQtdSoli)
		local lCritica		:= .f.
		local lRet 			:= .t.
		local dPeriOk		:= ctod("")
		local cHorPOk		:= ""
		local nAno			:= 0
		local nMes			:= 0
		local lDiaOk      	:= .f.
		local nResult		:= 0
		default cUniPer 	:= ""
		default dData		:= ctod("")
		default dUltimo 	:= ""
		default nPerioPer	:= 0
		default cUltimo 	:= ""
		default cProximo 	:= ""
		default	cHora		:= ""
		default nQtdSoli    := 0

		if len(dUltimo)==14
			dUltimo := left(dUltimo,12)
		endIf


		if cUniPer = "1"

			if !(funName() == "PLSA300" .and. cHora < strTran(cHorPOk, ":", ""))
				dPeriOk := Stod(left(dUltimo, 8))
				cHorPOk := right(dUltimo, 4)

				SomaDiaHor(@dPeriOk,@cHorPOk,nPerioPer)

				if dtos(dData)+left(strTran(cHora, ":", ""),4) <= dtos(dPeriOk)+strTran(cHorPOk, ":", "")
					cUltimo  := dtoc(Stod(left(dUltimo, 8))) + " - " +;
						Trans(right(dUltimo, 4), "@R 99:99")
					cProximo := dtoc(dPeriOk) + " - " + cHorPOk
					lRet	  := .f.
					lCritica := .t.
				endIf
			else
				// Caso a chamada vier do PLSA300 e a hora selecionada for menor	que a
				// ultima hora que houve um agendamento medico, validaremos a hora no
				// sentido inverso.
				SomaDiaHor(@dPeriOk,@cHorPOk,(nPerioPer*-1))
				if dtos(dData)+left(strTran(cHora, ":", ""),4) <= dtos(dPeriOk)+strTran(cHorPOk, ":", "")
					cUltimo  := dtoc(Stod(left(dUltimo, 8))) + " - " +;
						Trans(right(dUltimo, 4), "@R 99:99")
					cProximo := dtoc(dPeriOk) + " - " + cHorPOk
					lRet	  := .f.
					lCritica := .t.
				endIf
			endIf
		elseIf cUniPer = "2"
			nResult := (dData - Stod(dUltimo))
			iF nResult < nPerioPer .or. nQtdSoli > nPerioPer
				if !(funName() == "PLSA300" .and. nResult < 0)
					cUltimo  := dtoc(Stod(dUltimo))
					cProximo := dtoc(Stod(dUltimo) + nPerioPer)
					lRet  := .f.
					lCritica := .t.
				else
					// Caso a chamada vier do PLSA300 e a diferenca for negativa, corresponde
					// que houve um agendamento médico posterior a data que está sendo trata_
					// da. Logo a validação fica invertida para tras.
					nResult := (nResult * -1) // Transforma nResult em Positivo
					if nResult < nPerioPer
						cUltimo  := dtoc(Stod(dUltimo) - nPerioPer)
						cProximo := dtoc(Stod(dUltimo))
						lRet  := .f.
						lCritica := .t.
					endIf
				endIf
			endIf

		elseIf cUniPer = "3"

			if !(funName() == "PLSA300" .and. dtos(dData) < dUltimo)
				nMes := val(Subs(dUltimo, 5, 2)) + nPerioPer
				nAno := val(left(dUltimo, 4))
				if nMes > 12
					nAno += Int(nMes / 12)
					nPeriodo := 12	// Comeco em 12 pois o mes passara de 12
					while .t.
						nPeriodo += 12	// Somo 12 para ir ao proximo ano
						if nMes < nPeriodo	// Caso o mes seja menor que esse periodo calculo a diferenca
							nMes := 12 - (nPeriodo - nMes)
							Exit
						endIf
					endDo
				endIf

				// Tratamento caso a data para execucao do proximo procedimento (periodicidade) seja no Mes 12 e Ano |
				// diferente do ano da data base. Isso impedira o retorno de data invalida gerada pelo calculo acima |
				if nMes == 0
					nMes := 12
					nAno := nAno - 1
				endIf

				cProximo := AjusDiaPer(right(allTrim(dUltimo), 2),strZero(nMes, 2),Str(nAno, 4)  )

				lDiaOk := .t.
				if nAno = Year(dData) .and. Month(dData) <= nMes
					lDiaOk := Day(dData) >= val(right(allTrim(dUltimo), 2))
				endIf
				if PLSDIFANOS(	left(dUltimo, 4),Subs(dUltimo, 5, 2),;
						left(dtos(dData), 4),strZero(Month(dData), 2),"M") < nPerioPer .or.;
						! lDiaOk
					cUltimo := dtoc(Stod(dUltimo))
					lRet 	:= .f.
					lCritica:= .t.
				endIf
			else
				// Caso a chamada vier do PLSA300 e a data selecionada for menor	que a
				// ultima data que houve um agendamento medico, validaremos o Mes no
				// sentido inverso.
				nMes := val(Subs(dUltimo, 5, 2)) - nPerioPer
				nAno := val(left(dUltimo, 4))
				if nMes < 1
					nAno -= Int( ((12-val(Subs(dUltimo, 5, 2)))+nPerioPer)/12 )
					nPeriodo := 12	// Comeco em 12 pois o mes passara de 12
					while .t.
						nPeriodo -= 12	// Somo 12 para ir ao proximo ano
						if nMes < nPeriodo .or. nMes == 0	// Caso o mes seja menor que esse periodo calculo a diferenca
							nMes := 12 - (nPeriodo - nMes)
							Exit
						endIf
					endDo
				endIf
				cProximo := right(allTrim(dUltimo), 2) + "/" + strZero(nMes, 2) + "/" + Str(nAno, 4)

				lDiaOk := .t.
				if nAno = Year(dData) .and. Month(dData) <= nMes
					lDiaOk := Day(dData) <= val(right(allTrim(dUltimo), 2))
				endIf
				if (PLSDIFANOS(	left(dUltimo, 4),Subs(dUltimo, 5, 2),;
					left(dtos(dData), 4),strZero(Month(dData), 2),"M")*-1) < nPerioPer .or.;
					! lDiaOk
				cProximo := dtoc(Stod(dUltimo))
				cUltimo 	:= right(allTrim(dUltimo), 2) + "/" + strZero(nMes, 2) + "/" + Str(nAno, 4)
				lRet 		:= .f.
				lCritica	:= .t.
			endIf
		endIf

		elseIf cUniPer = "4"
		lDiaOk   := .t.
		lMesOk   := .t.
		if !(funName() == "PLSA300" .and. dtos(dData) < dUltimo)
			cProximo := right(allTrim(dUltimo), 2) + "/" +;
				Subs(allTrim(dUltimo), 5, 2) + "/" +;
				Str(val(left(dUltimo, 4)) + nPerioPer, 4)
			if Month(dData) <= val(Subs(cProximo, 4, 2)) .and.;
					Year(dData) = val(right(cProximo, 4))
				lDiaOk := Day(dData) >= val(right(allTrim(dUltimo), 2))
				lMesOk := Month(dData) = val(Subs(allTrim(dUltimo), 5, 2))
			endIf
			if (Year(dData) - val(left(dUltimo, 4))) < nPerioPer .or. (! lDiaOk .or. ! lMesOk)
				cUltimo := dtoc(Stod(dUltimo))
				lRet	:= .f.
				lCritica:= .t.
			endIf
		else
			// Caso a chamada vier do PLSA300 e a data selecionada for menor	que a
			// ultima data que houve um agendamento medico, validaremos o Ano no
			// sentido inverso.
			cProximo := right(allTrim(dUltimo), 2) + "/" +;
				Subs(allTrim(dUltimo), 5, 2) + "/" +;
				Str(val(left(dUltimo, 4)) - nPerioPer, 4)
			if Month(dData) >= val(Subs(cProximo, 4, 2)) .and.;
					Year(dData) == val(right(cProximo, 4))
				lDiaOk := Day(dData) <= val(right(allTrim(dUltimo), 2))
				lMesOk := Month(dData) <= val(Subs(allTrim(dUltimo), 5, 2))
			endIf
			if (val(left(dUltimo, 4)) - Year(dData)) < nPerioPer .or. (! lDiaOk .or. ! lMesOk)
				cProximo := dtoc(Stod(dUltimo))
				cUltimo := right(allTrim(dUltimo), 2) + "/" + Subs(allTrim(dUltimo), 5, 2) + "/" + Str(val(left(dUltimo, 4)) - nPerioPer, 4)
				lRet	:= .f.
				lCritica:= .t.
			endIf
		endIf
		elseIf ! empty(dUltimo)
		cUltimo 	:= dtoc(Stod(dUltimo))
		cProximo 	:= STR0035 //"Sem Permissao"
		lRet		:= .f.
		lCritica 	:= .t.
		endIf

	return({lRet,lCritica})

	/*/{Protheus.doc} PLSCarDias
Calcula os dias de acordo com carencia e unidade...
@type function
@author tuliocesar
@since 07.07.01
@version 1.0
	/*/
	static function PLSCalcDia(nQuanti,cUnid,cTipo)
		local nDias := 0
		default cTipo := '1'

		// Testa unidade...
		if cTipo == "1"
			if     cUnid == "1" //Dia
				nDias := nQuanti

			elseIf cUnid == "2" //Mes
				nDias := 30 * nQuanti

			elseIf cUnid == "3" //Ano
				nDias := 365 * nQuanti

			endIf
		elseIf cTipo == "2"
			if     cUnid == "1" .or. cUnid =="2" //Dia ou horas
				nDias := nQuanti

			elseIf cUnid == "3" //Mes
				nDias := 30 * nQuanti

			elseIf cUnid == "3" //Ano
				nDias := 365 * nQuanti

			endIf
		endIf

	return(nDias)

	/*/{Protheus.doc} PLSVLDPRI
Valida procedimentos pre-requisitados...
@type function
@author tuliocesar
@since 24/11/10
@version 1.0
	/*/
	function PLSVLDPRE(	cCid,cLocalExec,aCodsProcs,aDadUsr,dDatPro,lRPC,cOpeRDA,cCodRDA,cCodPad,;
			cCodProc,cSequen,aRet,cFace,cDenReg,nRegBD6,cNumeroGuia,cProRel,nPrPrRl)
		local aAreaBA9	:= BA9->(getArea())
		local aAreaBA0	:= BA0->(getArea())
		local aAreaBR8	:= BR8->(getArea())
		local nNiveis	:= 0
		local nfor		:= 0
		local nAux		:= 0
		local nInd		:= 0
		local lRet      := .t.
		local lExiste   := .f.
		local lFlag     := .f.
		local aProcInc  := {}
		local cSQL		:= ""
		local cCdTbPd   := ""
		local cCodPro   := ""
		local _cCdTbPd  := ""
		local _cCodPro  := ""
		local _cDenReg  := ""
		local _cFace    := ""
		local cCodAux   := ""
		local cChave    := ""
		local cChave2   := ""
		local nPos
		local cTratLim
		local nLimCH
		local aCompo
		local nQtdCH    := 0
		local cCodTab 	:= ""
		local cAno    	:= ""
		local cMes    	:= ""
		local cIntPad 	:= plsIntPad()
		local nQtd  	:= 1
		local nDias		:= 0
		local cChave3   := ""
		local cChave4   := ""
		local cCodCri	:= ""
		local cVldMatVid := getNewPar("MV_PLSMTVD", "1")
		local lPreReq   := .f.
		local nP 		:= 0
		local lPLPERSIT := existBlock("PLPERSIT")

		default dDatPro := dDataBase
		default lRPC	:= .f.
		default cOpeRDA := ""
		default cCodRDA := ""
		default cCodPad := ""
		default cCodProc:= ""
		default cSequen := ""
		default aRet	:= {.t.}
		default cFace	:= ""
		default	cDenReg := ""
		default cProRel := ""
		default nPrPrRl := 0
		default nRegBD6	:= 0
		default cNumeroGuia := ""

		if empty(dDatPro)
			dDatPro := dDataBase
		endIf

		// Se for usuario de intercambio nao faz nada
		if len(aDadUsr) > 1 .and. len(aDadUsr) >= 45 .and. aDadUsr[45] != cIntPad
			return(aRet)
		endIf

		// Se o Registro ja foi auditado, nao verifica novamente...
		if nRegBD6 > 0
			if BD6->(FieldPos("BD6_AUDITA")) > 0
				if !empty(cNumeroGuia) .and. BD6->BD6_AUDITA == "1"
					return(aRet)
				endIf
			endIf
		endIf

		// Especificos odontologico.
		if !lFlag .and. iIf( len(aDadUsr) >= 1 ,aDadUsr[1],.f.)

			cCdTbPd   := cCodPad
			cCodPro   := cCodProc
			lFlag     := .f.

			// Incompatibilidade no nivel de procedimento
			BR8->(dbSetOrder(1))
			if BR8->(FieldPos("BR8_ODONTO")) > 0 .and. BR8->(msSeek(xFilial("BR8")+cCdTbPd+cCodPro))  .and. BR8->BR8_ODONto == '1'

				// Seleciona os pre-requisitos do procedimento atual.
				if !lFlag .and. !empty(cDenReg)

					cSQL := "SELECT B0N_CODPAD, B0N_CODPSA, B0N_DENREG, B0N_QTDMIN, B0N_UNIMIN, B0N_QTDMAX, B0N_UNIMAX "

					if B0N->(FieldPos("B0N_PRERGU")) > 0
						cSQL += ", B0N_PRERGU "
					endIf

					CSQL += "FROM "+RetSqlName("B0N")+" WHERE "
					cSQL += "B0N_FILIAL = '"+xFilial("B0N")+"' AND "
					cSQL += "B0N_CHVPAD = '"+cCdTbPd+"' AND "
					cSQL += "B0N_CHVPSA = '"+cCodPro+"' AND "
					cSQL += "B0N_CHVREG = '"+cDenReg+"' AND "

					cSQL += RetSqlName("B0N")+".D_E_L_E_T_ = ' ' "

					dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSVLDPRE",.f.,.t.)

					if !PLSVLDPRE->(eof())
						plsTField("PLSVLDPRE",.f.,{ "B0N_QTDMAX" } )
					endIf

					while !PLSVLDPRE->(eof())

						if len(aCodsProcs) > 0

							for nP := 1 to len(aCodsProcs)

								if PLSVLDPRE->B0N_PRERGU == "1"

									if aCodsProcs[nP][1]+aCodsProcs[nP][2] == PLSVLDPRE->B0N_CODPAD+PLSVLDPRE->B0N_CODPSA
										lPreReq := .t.
										Exit
									else
										lPreReq := .f.
									endIf

								else
									lPreReq := .f.
								endIf

							next nP

						endIf

						if !lPreReq

							//Periodo maximo em dias que o historico pode ser consultado para verificação de pre-requisitos.
							nDiasMax := PLSCalcDia(PLSVLDPRE->B0N_QTDMAX,PLSVLDPRE->B0N_UNIMAX)

							// Verifica os pre-requisitos foram executados dentro dos prazos previstos.
							cSQL := "SELECT BD6_DATPRO, BD6_CODPAD,BD6_CODPRO,BD6_DENREG,BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO "
							cSQL += "FROM "+RetSqlName("BD6")+" WHERE "
							cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
							cSQL += "BD6_OPEUSR = '"+Subs(aDadUsr[2],atCodOpe[1],atCodOpe[2])+"' AND "

							if cVldMatVid == "2"	// Utiliza matricua da vida.
								cSQL += "BD6_MATVID = '"+aDadUsr[5]+"' AND "

							else	// Utiliza verificação pela matricula do contrato.
								cSQL += "BD6_CODEMP = '"+Subs(aDadUsr[2],atCodEmp[1],atCodEmp[2])+"' AND "
								cSQL += "BD6_MATRIC = '"+Subs(aDadUsr[2],atMatric[1],atMatric[2])+"' AND "
								cSQL += "BD6_TIPREG = '"+Subs(aDadUsr[2],atTipReg[1],atTipReg[2])+"' AND "
								cSQL += "BD6_DIGITO = '"+Subs(aDadUsr[2],atDigito[1],atDigito[2])+"' AND "

							endIf
							cSQL += "BD6_CODPAD = '"+PLSVLDPRE->B0N_CODPAD+"' AND "
							cSQL += "BD6_CODPRO = '"+PLSVLDPRE->B0N_CODPSA+"' AND "
							cSQL += "BD6_DENREG = '"+PLSVLDPRE->B0N_DENREG+"' AND "

							// Se nDiasMax == 0 significa que deve olhar para todos historico, sem limitecao de periodo.
							if nDiasMax > 0
								cSQL += "BD6_DATPRO > '"+dtos(dDatPro-nDiasMax)+"' AND "
							endIf

							cSQL += "( BD6_FASE = '3' OR BD6_FASE = '4') AND "

							if lPLPERSIT
								cSQL += execBlock("PLPERSIT",.f.,.f.)
								cSQL += " AND  "
							else
								cSQL += "( ( BD6_SITUAC = '1' ) OR ( BD6_SITUAC = '3' AND BD6_LIBERA = '1') )  AND BD6_STATUS <> '0' AND  "
							endIf

							if findFunction("PlReChvEst")
								aRetAux  := PlReChvEst("BD6",.t.,.f.,.t.,.f.)
								cSQL     += aRetAux[1]
							endIf

							cSQL += RetSqlName("BD6")+".D_E_L_E_T_ = ' ' "

							dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSVLDGUI",.f.,.t.)

							// Se nao encontrou o procedimento no historio, significa que o pre-requisito nao foi atendido.
							// Adiciona o procedimento na matriz de criticas.
							if PLSVLDGUI->(eof())

								aadd(aProcInc,{	cCdTbPd,;
									cCodPro,;
									PLSVLDPRE->B0N_CODPAD,;
									PLSVLDPRE->B0N_CODPSA,;
									PLSVLDPRE->B0N_DENREG,;
									cDenReg,;
									"",;
									"",;
									"",;
									cSequen,;
									"1"})	// Nao encontrado dentro do periodo maximo
							else
								plsTField("PLSVLDGUI",.f.,{ "BD6_DATPRO","B0N_QTDMIN" } )

								// Encontrou no historico dentro do periodo maximo. Agora preciso verificar se esta dentro do periodo minimo.
								while !PLSVLDGUI->(eof())

									nDiasMin := PLSCalcDia(PLSVLDPRE->B0N_QTDMIN,PLSVLDPRE->B0N_UNIMIN) 	// Calcula em dias

									if (dtos(PLSVLDGUI->BD6_DATPRO) > dtos(dDatPro-nDiasMin)) // Analisa validade da regra.

										aadd(aProcInc,{	cCdTbPd,;
											cCodPro,;
											PLSVLDGUI->BD6_CODPAD,;
											PLSVLDGUI->BD6_CODPRO,;
											PLSVLDGUI->BD6_DENREG,;
											cDenReg,;
											PLSVLDGUI->BD6_DATPRO+nDiasMin,;
											"",;
											"",;
											cSequen,;
											"2"})	// Nao atende ao periodo minimo.
									endIf

									PLSVLDGUI->( dbSkip() )
								endDo

							endIf

							// Fecha area de trabalho temporaria.
							PLSVLDGUI->( dbCloseArea() )
						endIf

						PLSVLDPRE->( dbSkip() )
					endDo

					PLSVLDPRE->(DbCloseArea())
				endIf
			endIf
		endIf

		// Se nao encontrar os pre-requisitos, aplica a critica.
		if len(aProcInc) > 0

			lRet := .f.

			BR8->(dbSetOrder(1))
			for nfor := 1 to len(aProcInc)

				if aProcInc[nfor][11] == "1" // Não encontrou no periodo maximo.

					// Este procedimento pre-requisito não foi encontrado dentro do periodo maximo exigido.
					PLSPOSGLO(cIntPad,__aCdCri179[1],__aCdCri179[2],cLocalExec)
					cCodCri := __aCdCri179[1]

				elseIf aProcInc[nfor][11] == "2"
					// Este procedimento pre-requisito não foi encontrado dentro do periodo minimo exigido.
					PLSPOSGLO(cIntPad,__aCdCri190[1],__aCdCri190[2],cLocalExec,NIL,NIL,"1")
					cCodCri := __aCdCri190[1]

					// Inserir texto " @data
				endIf

				aadd(aCodCri,{cCodCri,allTrim(PLSBCTDESC()) + " [" + allTrim(aProcInc[nfor][4]) + "]","",BCT->BCT_NIVEL,BCT->BCT_TIPO,aProcInc[nfor][1],aProcInc[nfor][2],aProcInc[nfor][10],aProcInc[nfor]})

				BR8->(msSeek(xFilial("BR8")+aProcInc[nfor,1]+aProcInc[nfor,2]))

				if !empty(aProcInc[nfor,6])
					aadd(aCodCri,{""   ,STR0110+allTrim(BR8->BR8_CODPSA)+STR0144+allTrim(aProcInc[nfor,6])+")" + " [" + allTrim(aProcInc[nfor][4]) + "]",allTrim(BR8->BR8_DESCRI),"","",aProcInc[nfor,1],aProcInc[nfor,2],aProcInc[nfor][10],aProcInc[nfor]})
				else
					aadd(aCodCri,{""   ,STR0110+allTrim(BR8->BR8_CODPSA)+")" + " [" + allTrim(aProcInc[nfor][4]) + "]",allTrim(BR8->BR8_DESCRI),"","",aProcInc[nfor,1],aProcInc[nfor,2],aProcInc[nfor][10],aProcInc[nfor]})
				endIf

				BR8->(msSeek(xFilial("BR8")+aProcInc[nfor,3]+aProcInc[nfor,4]))

				if !empty(aProcInc[nfor,5])
					aadd(aCodCri,{""   ,STR0145+allTrim(aProcInc[nfor,4])+STR0113+allTrim(aProcInc[nfor,5])+")",allTrim(BR8->BR8_DESCRI),"","",aProcInc[nfor,1],aProcInc[nfor,2],aProcInc[nfor][10],aProcInc[nfor]})
				else
					aadd(aCodCri,{""   ,STR0145+allTrim(aProcInc[nfor,4])+")",allTrim(BR8->BR8_DESCRI),"","",aProcInc[nfor,1],aProcInc[nfor,2],aProcInc[nfor][10],aProcInc[nfor]})
				endIf

				// Se for critica pelo periodo minimo, exibe quando podera ser feita.
				if aProcInc[nfor][11] == "2"
					aadd(aCodCri,{""   ,STR0146,dtoc(aProcInc[nfor][7]),"","",aProcInc[nfor,1],aProcInc[nfor,2],aProcInc[nfor][10],aProcInc[nfor]})
				endIf

			next

			aRet := {.f.,aCodCri,"1",cCodPad+cCodProc}

		endIf

		BA9->(restArea(aAreaBA9))
		BA0->(restArea(aAreaBA0))
		BR8->(restArea(aAreaBR8))

	return(aRet)

	/*/{Protheus.doc} PLSVLDLUS
Valida procedimentos quantidade de us
@type function
@author tuliocesar
@since 24/11/10
@version 1.0
	/*/
	function PLSVLDLUS( cCid,cLocalExec,aCodsProcs,aDadUsr,dDatPro,lRPC,cOpeRDA,cCodRDA,cCodPad,;
			cCodProc,cSequen,aRet,cFace,cDenReg,nRegBD6,cNumeroGuia,cProRel,nPrPrRl,;
			cAno, cMes, cSubEsp, nQtd, cPadInt, cCodEsp, cCodLoc, cRegAte, nPrPrRl,;
			aValAcu, cHora, aDadRda, cTipo, cPadCon, aRdas)

		local aAreaBA9	:= BA9->(getArea())
		local aAreaBA0	:= BA0->(getArea())
		local aAreaBR8	:= BR8->(getArea())
		local nfor		:= 0
		local nAux		:= 0
		local lRet      := .t.
		local aProcInc  := {}
		local cSQL		:= ""
		local _cCdTbPd  := ""
		local _cCodPro  := ""
		local _cDenReg  := ""
		local _cFace    := ""
		local cChave3   := ""
		local cChave4   := ""
		local cCodCri	:= ""

		// Reinicia a variavel
		local nQtdUsHis := 0
		local nQtdUsGui := 0
		local nQtdUSPrm	:= ""
		local nQtdPerUs := ""
		local cUndPerUs	:= ""
		local cIntPad	:= plsIntPad()
		local nDiasMax	:= 0
		local aPacote 	:= {0,0,{},""}
		local aUnidsBlo := {}
		local aVlBloq	:= {}
		local lCirurgico:= .f.
		local aQtdPer 	:= {}
		local aValor 	:= {}
		local nX		:= 0
		local cVldMatVid:= getNewPar("MV_PLSMTVD", "1")

		aRetCPag		:= {}

		if empty(dDatPro)
			dDatPro := dDataBase
		endIf

		// Se for usuario de intercambio nao faz nada
		if len(aDadUsr) < 1 .or. len(aDadUsr) < 85
			return(aRet)
		endIf

		// Garante integridade do array.
		if len(aDadUsr) >= 83

			// aDadUsr
			nQtdUSPrm	:= aDadUsr[83]	// Quantidade de US permitida
			nQtdPerUs 	:= aDadUsr[84]	// Periodo a considerar para busca no historico
			cUndPerUs	:= aDadUsr[85]	// Unidade de medida do periodo.

			// So executa a regra se for definido no cadastro que existe controle de quantidade de US executada.
			if BQC->(FieldPos("BQC_QTDUS")) > 0 .and. nQtdUSPrm > 0

				//Periodo maximo em dias que o historico pode ser consultado para verificação de pre-requisitos.
				nDiasMax := PLSCalcDia(nQtdPerUs,cUndPerUs)

				// Seleciona os pre-requisitos do procedimento atual.
				cCodInt := Subs(aDadUsr[2],atCodOpe[1],atCodOpe[2])

				cSQL := "SELECT BD7_REFTDE "

				if cVldMatVid == "2"	// Utiliza matricua da vida.
					cSql += "FROM "+RetSqlName("BD7")+","+RetSqlName("BD6")+","+RetSqlName("BA1")+" WHERE "
				else
					cSql += "FROM "+RetSqlName("BD7")+","+RetSqlName("BD6")+" WHERE "
				endIf

				// Monta o final da query, identico a qualquer cTipoCon
				cSQL += "BD7_FILIAL = '"+xFilial("BD7")+"' AND "
				cSQL += "BD7_CODOPE = BD6_CODOPE AND "
				cSQL += "BD7_CODLDP = BD6_CODLDP AND "
				cSQL += "BD7_CODPEG = BD6_CODPEG AND "
				cSQL += "BD7_NUMERO = BD6_NUMERO AND "
				cSQL += "BD7_ORIMOV = BD6_ORIMOV AND "
				cSQL += "BD7_SEQUEN = BD6_SEQUEN AND "

				if cVldMatVid == "2"	// Utiliza matricua da vida.

					cSQL += "BA1_FILIAL = BD6_FILIAL AND "
					cSQL += "BA1_CODINT = BD6_OPEUSR AND "
					cSQL += "BA1_CODEMP = BD6_CODEMP AND "
					cSQL += "BA1_MATRIC = BD6_MATRIC AND "
					cSQL += "BA1_TIPREG = BD6_TIPREG AND "
					cSQL += "BA1_MATVID = '"+aDadUsr[5]+"' AND "

				else	// Utiliza verificação pela matricula do contrato.

					cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
					cSQL += "BD6_OPEUSR = '"+Subs(aDadUsr[2],atCodOpe[1],atCodOpe[2])+"' AND "
					cSQL += "BD6_CODEMP = '"+Subs(aDadUsr[2],atCodEmp[1],atCodEmp[2])+"' AND "
					cSQL += "BD6_MATRIC = '"+Subs(aDadUsr[2],atMatric[1],atMatric[2])+"' AND "
					cSQL += "BD6_TIPREG = '"+Subs(aDadUsr[2],atTipReg[1],atTipReg[2])+"' AND "
					cSQL += "BD6_DIGITO = '"+Subs(aDadUsr[2],atDigito[1],atDigito[2])+"' AND "

				endIf
				cSQL += "BD6_DATPRO > '" + dtos(dDatPro-nDiasMax) + "' AND "
				cSQL += "( BD6_FASE = '3' OR BD6_FASE = '4') AND "

				if existBlock("PLPERSIT")
					cSQL += execBlock("PLPERSIT",.f.,.f.)
					cSQL += " AND  "
				else
					cSQL += "( ( BD6_SITUAC = '1' ) OR ( BD6_SITUAC = '3' AND BD6_LIBERA = '1') )  AND BD6_STATUS <> '0' AND  "
				endIf

				cSQL += RetSQLName("BD6")+".D_E_L_E_T_ = ' ' AND "
				cSQL += RetSQLName("BD7")+".D_E_L_E_T_ = ' ' "

				dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSql)),"PLSQTDUS",.f.,.t.)

				nQtdUsHis := 0

				if !PLSQTDUS->(eof())

					plsTField("PLSQTDUS",.f.,{ "BD7_REFTDE" } )

					// Faz o levantamento do total de US baseado no historico do BD7.
					PLSQTDUS->( dbeval({|| nQtdUsHis += PLSQTDUS->BD7_REFTDE}) )

				endIf

				PLSQTDUS->( dbCloseArea() )

				// Faz o levantamento do total de US da guia atual.
				nQtdUsGui := 0

				// Primeiro os procedimentos que ja foram alculados...
				BR8->(dbSetOrder(1))
				for nAux := 1 to len(aCodsProcs)

					_cSequen   := aCodsProcs[nAux,8]
					_cCdTbPd   := aCodsProcs[nAux,1]
					_cCodPro   := aCodsProcs[nAux,2]

					if BR8->(msSeek(xFilial("BR8")+_cCdTbPd+_cCodPro))

						// Verifica se eh um procedimento cirurgico...
						lCirurgico := If(BR8->BR8_TIPEVE$"2,3",.t.,.f.)

						// Regras de quantidade...
						aQtdPer := PlMonQtPer(_cSequen,_cCdTbPd,_cCodPro,nQtd,.f.,"",dDataBase)

						// Valoriza o procedimento para obter a quantidade de US.
						aValor := PLSCALCEVE(_cCdTbPd,_cCodPro,cMes,cAno,cCodInt,cCodRDA,cCodEsp,cSubEsp,cCodLoc,nQtd,dDataBase,aDadUsr[48],;
							cPadInt,cRegAte,0,aDadUsr,cPadCon,aQtdPer,nil,nil,nil,nil,cHora,aRdas,nil,cProRel,;
							nPrPrRl,{},nil,dDataBase,cHora,aUnidsBlo,cTipo,.f.,0,aVlBloq,nil,lCirurgico,1,;
							"1","1",nQtd,nQtd,aPacote,"",cSequen)

						// Pega da matriz apenas o necessario
						aValor := aClone(aValor[1])

						// Soma a quantidade de US do procedimento...
						for nX := 1 to len(aValor)

							if 	allTrim(aValor[nX][1]) $ getNewPar("MV_PLSCAUX","AUX") .or. allTrim(aValor[nX][1]) $ getNewPar("MV_PLSCRCC","RCC")
								nQtdUsGui += aValor[nX,9]

							elseIf allTrim(aValor[nX][1]) $ getNewPar("MV_PLSCPA","PA")
								nQtdUsGui += aValor[nX,5,1,1]

							elseIf allTrim(aValor[nX][1]) $ "PPM"  //nao necessario criar mais um parametro no sistema
								nQtdUsGui += aValor[nX,5,1,1]

							else
								nQtdUsGui += aValor[nX,9]

							endIf

						next
					endIf

				next

				// Depois o procedimento que esta sendo solicitado.

				// Verifica se eh um procedimento cirurgico...
				lCirurgico := If(BR8->BR8_TIPEVE $ "2,3",.t.,.f.)

				// Regras de quantidade...
				aQtdPer := PlMonQtPer(cSequen,cCodPad,cCodProc,nQtd,.f.,"",dDataBase)

				// Valoriza o procedimento para obter a quantidade de US.
				aValor := PLSCALCEVE(cCodPad,cCodProc,cMes,cAno,cCodInt,cCodRDA,cCodEsp,cSubEsp,cCodLoc,nQtd,dDataBase,aDadUsr[48],;
					cPadInt,cRegAte,0,aDadUsr,cPadCon,aQtdPer,nil,nil,nil,nil,cHora,aRdas,nil,cProRel,;
					nPrPrRl,{},nil,dDataBase,cHora,aUnidsBlo,cTipo,.f.,0,aVlBloq,nil,lCirurgico,1,;
					"1","1",nQtd,nQtd,aPacote,"",cSequen)

				// Pega da matriz apenas o necessario
				aValor := aClone(aValor[1])

				// Soma a quantidade de US do procedimento...
				for nX := 1 to len(aValor)

					if 	allTrim(aValor[nX][1]) $ getNewPar("MV_PLSCAUX","AUX") .or. allTrim(aValor[nX][1]) $ getNewPar("MV_PLSCRCC","RCC")
						nQtdUsGui += aValor[nX,9]

					elseIf allTrim(aValor[nX][1]) $ getNewPar("MV_PLSCPA","PA")
						nQtdUsGui += aValor[nX,5,1,1]

					elseIf allTrim(aValor[nX][1]) $ "PPM"  //nao necessario criar mais um parametro no sistema
						nQtdUsGui += aValor[nX,5,1,1]

					else
						nQtdUsGui += aValor[nX,9]

					endIf

				next

				// Se a quantidade do historico, somada a quantidade da guia atual for maior que a quantidade permitida no contrato... critica!
				if (nQtdUsHis+nQtdUsGui) > nQtdUSPrm

					// Critica
					aadd(aProcInc,{	cCodPad,;
						cCodProc,;
						"",;
						"",;
						"",;
						cDenReg,;
						"",;
						"",;
						"",;
						cSequen,;
						""})	// Nao atende ao periodo minimo.
				endIf

			endIf

		endIf

		// O limite foi excedido.
		if len(aProcInc) > 0

			lRet := .f.

			BR8->(dbSetOrder(1))

			for nfor := 1 to len(aProcInc)

				// Este procedimento pre-requisito não foi encontrado dentro do periodo maximo exigido.
				if PLSPOSGLO(cIntPad,__aCdCri182[1],__aCdCri182[2],cLocalExec)

					cCodCri := __aCdCri182[1]

					aadd(aCodCri,{cCodCri,PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,aProcInc[nfor][1],aProcInc[nfor][2],aProcInc[nfor][10]})

					//Quebra em duas linhas para caber na tela de criticas do portal.
					aadd(aCodCri,{""   ,STR0149+allTrim(Transform(nQtdUSPrm, PesqPict( "BQC","BQC_QTDUS"))),"","","",aProcInc[nfor,1],aProcInc[nfor,2],aProcInc[nfor][10]})
					aadd(aCodCri,{""   ,STR0150+iIf(aDadUsr[08]=="2",STR0151, STR0152)+STR0162,"","","",aProcInc[nfor,1],aProcInc[nfor,2],aProcInc[nfor][10]})

				endIf

			next

			// Monta array de criticas.
			if len(aCodCri) > 0
				aRet := {.f.,aCodCri,iIf(aDadUsr[08]=="2","BQC", "BI3"),cCodPad+cCodProc}
			endIf

		else

			// Se estiver dentro do limite definido no subcontrato, testa o limite definido pra RDA.
			// Garante integridade do array.
			if BAU->(FieldPos("BAU_QTDUS")) > 0 .and.  len(aProcInc) == 0 .and. len(aDadRDA) >= 34

				// aDadUsr
				nQtdUSPrm	:= aDadRDA[34]	// Quantidade de US permitida

				if nQtdUSPrm > 0

					//O Periodo de verifica'cao eh a competencia de pagamento da guia.
					aRetCPag := PLSXVLDCAL(dDataBase,cIntPad,.t.,"","")

					// Seleciona os pre-requisitos do procedimento atual.
					cCodInt := Subs(aDadUsr[2],atCodOpe[1],atCodOpe[2])

					cSQL := "SELECT BD7_REFTDE "
					cSql += "FROM "+RetSqlName("BD7")+","+RetSqlName("BD6")+" WHERE "

					// Monta o final da query, identico a qualquer cTipoCon
					cSQL += "BD7_FILIAL = '"+xFilial("BD7")+"' AND "
					cSQL += "BD7_CODOPE = BD6_CODOPE AND "
					cSQL += "BD7_CODLDP = BD6_CODLDP AND "
					cSQL += "BD7_CODPEG = BD6_CODPEG AND "
					cSQL += "BD7_NUMERO = BD6_NUMERO AND "
					cSQL += "BD7_ORIMOV = BD6_ORIMOV AND "
					cSQL += "BD7_SEQUEN = BD6_SEQUEN AND "
					cSQL += "BD6_CODRDA = '"+cCodRDA+"' AND "
					cSQL += "BD6_ANOPAG = '"+aRetCPag[4]+"' AND "
					cSQL += "BD6_MESPAG = '"+aRetCPag[5]+"' AND "
					cSQL += "( BD6_FASE = '3' OR BD6_FASE = '4') AND "

					if existBlock("PLPERSIT")
						cSQL += execBlock("PLPERSIT",.f.,.f.)
						cSQL += " AND  "
					else
						cSQL += "( ( BD6_SITUAC = '1' ) OR ( BD6_SITUAC = '3' AND BD6_LIBERA = '1') )  AND BD6_STATUS <> '0' AND  "
					endIf
					cSQL += RetSQLName("BD6")+".D_E_L_E_T_ = ' ' AND "
					cSQL += RetSQLName("BD7")+".D_E_L_E_T_ = ' ' "

					dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSql)),"PLSQTDUS",.f.,.t.)

					// Faz o levantamento do total de US baseado no historico do BD7.
					nQtdUsHis := 0

					if !PLSQTDUS->(eof())

						plsTField("PLSQTDUS",.f.,{ "BD7_REFTDE" } )

						PLSQTDUS->( dbeval({|| nQtdUsHis += PLSQTDUS->BD7_REFTDE}) )

					endIf

					PLSQTDUS->( dbCloseArea() )

					// Faz o levantamento do total de US da guia atual.
					nQtdUsGui := 0

					// Primeiro os procedimentos que ja foram alculados...
					BR8->(dbSetOrder(1))
					for nAux := 1 to len(aCodsProcs)

						_cSequen   := aCodsProcs[nAux,8]
						_cCdTbPd   := aCodsProcs[nAux,1]
						_cCodPro   := aCodsProcs[nAux,2]

						if BR8->(msSeek(xFilial("BR8")+_cCdTbPd+_cCodPro))

							// Verifica se eh um procedimento cirurgico...
							lCirurgico := If(BR8->BR8_TIPEVE$"2,3",.t.,.f.)

							// Regras de quantidade...
							aQtdPer := PlMonQtPer(_cSequen,_cCdTbPd,_cCodPro,nQtd,.f.,"",dDataBase)

							// Valoriza o procedimento para obter a quantidade de US.
							aValor := PLSCALCEVE(_cCdTbPd,_cCodPro,cMes,cAno,cCodInt,cCodRDA,cCodEsp,cSubEsp,cCodLoc,nQtd,dDataBase,aDadUsr[48],;
								cPadInt,cRegAte,0,aDadUsr,cPadCon,aQtdPer,nil,nil,nil,nil,cHora,aRdas,nil,cProRel,;
								nPrPrRl,{},nil,dDataBase,cHora,aUnidsBlo,cTipo,.f.,0,aVlBloq,nil,lCirurgico,1,;
								"1","1",nQtd,nQtd,aPacote,"",cSequen)

							// Pega da matriz apenas o necessario
							aValor := aClone(aValor[1])

							// Soma a quantidade de US do procedimento...
							for nX := 1 to len(aValor)

								if 	allTrim(aValor[nX][1]) $ getNewPar("MV_PLSCAUX","AUX") .or. allTrim(aValor[nX][1]) $ getNewPar("MV_PLSCRCC","RCC")
									nQtdUsGui += aValor[nX,9]

								elseIf allTrim(aValor[nX][1]) $ getNewPar("MV_PLSCPA","PA")
									nQtdUsGui += aValor[nX,5,1,1]

								elseIf allTrim(aValor[nX][1]) $ "PPM"  //nao necessario criar mais um parametro no sistema
									nQtdUsGui += aValor[nX,5,1,1]

								else
									nQtdUsGui += aValor[nX,9]

								endIf
							next
						endIf
					next

					// Depois o procedimento que esta sendo solicitado.
					// Verifica se eh um procedimento cirurgico...
					lCirurgico := If(BR8->BR8_TIPEVE$"2,3",.t.,.f.)

					// Regras de quantidade...
					aQtdPer := PlMonQtPer(cSequen,cCodPad,cCodProc,nQtd,.f.,"",dDataBase)

					// Valoriza o procedimento para obter a quantidade de US.
					aValor := PLSCALCEVE(cCodPad,cCodProc,cMes,cAno,cCodInt,cCodRDA,cCodEsp,cSubEsp,cCodLoc,nQtd,dDataBase,aDadUsr[48],;
						cPadInt,cRegAte,0,aDadUsr,cPadCon,aQtdPer,nil,nil,nil,nil,cHora,aRdas,nil,cProRel,;
						nPrPrRl,{},nil,dDataBase,cHora,aUnidsBlo,cTipo,.f.,0,aVlBloq,nil,lCirurgico,1,;
						"1","1",nQtd,nQtd,aPacote,"",cSequen)

					// Pega da matriz apenas o necessario
					aValor := aClone(aValor[1])

					// Soma a quantidade de US do procedimento...
					for nX := 1 to len(aValor)

						if 	allTrim(aValor[nX][1]) $ getNewPar("MV_PLSCAUX","AUX") .or. allTrim(aValor[nX][1]) $ getNewPar("MV_PLSCRCC","RCC")
							nQtdUsGui += aValor[nX,9]

						elseIf allTrim(aValor[nX][1]) $ getNewPar("MV_PLSCPA","PA")
							nQtdUsGui += aValor[nX,5,1,1]

						elseIf allTrim(aValor[nX][1]) $ "PPM"  //nao necessario criar mais um parametro no sistema
							nQtdUsGui += aValor[nX,5,1,1]

						else
							nQtdUsGui += aValor[nX,9]

						endIf
					next

					// Se a quantidade do historico, somada a quantidade da guia atual for maior que a quantidade permitida no contrato... critica!
					if (nQtdUsHis+nQtdUsGui) > nQtdUSPrm

						// Critica
						aadd(aProcInc,{	cCodPad,;
							cCodProc,;
							"",;
							"",;
							"",;
							cDenReg,;
							"",;
							"",;
							"",;
							cSequen,;
							""})	// Nao atende ao periodo minimo.
					endIf

				endIf

			endIf

			// O limite foi excedido.
			if len(aProcInc) > 0
				lRet := .f.

				BR8->(dbSetOrder(1))
				for nfor := 1 to len(aProcInc)

					// Este procedimento pre-requisito não foi encontrado dentro do periodo maximo exigido.
					if PLSPOSGLO(cIntPad,__aCdCri182[1],__aCdCri182[2],cLocalExec)

						cCodCri := __aCdCri182[1]

						aadd(aCodCri,{cCodCri,PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,aProcInc[nfor][1],aProcInc[nfor][2],aProcInc[nfor][10]})

						//Quebra em duas linhas para caber na tela de criticas do portal.
						aadd(aCodCri,{""   ,STR0149+allTrim(Transform(nQtdUSPrm, PesqPict( "BAU","BAU_QTDUS"))),"","","",aProcInc[nfor,1],aProcInc[nfor,2],aProcInc[nfor][10]})
						aadd(aCodCri,{""   ,STR0163+STR0164,"","","",aProcInc[nfor,1],aProcInc[nfor,2],aProcInc[nfor][10]})
					endIf

				next

				// Monta array de criticas.
				if len(aCodCri) > 0
					aRet := {.f.,aCodCri,"BAU",cCodPad+cCodProc}
				endIf
			endIf

		endIf

		BA9->(restArea(aAreaBA9))
		BA0->(restArea(aAreaBA0))
		BR8->(restArea(aAreaBR8))

	return(aRet)

	/*/{Protheus.doc} PLSDUPGUI
Desc. Funcao para verificar a existencia de guias duplicadas.
@type function
@author tuliocesar
@since 16/12/10
@version 1.0
	/*/
	function PLSDUPGUI(cCdTbPd,cCodPro,aDadUsr,nRegBD6,aDadRDA,cOpeUsr,aRet,dData,cCodEsp,lContab,cNrLbor,lLibera)
		local aAreaBD6 		:= {}
		local aAreaBD7 		:= {}
		local cCodEmp 		:= iIf(len(aDadUsr)>=2,subStr(aDadUsr[2],5,4),"")
		local cMatric 		:= iIf(len(aDadUsr)>=2,subStr(aDadUsr[2],9,6),"")
		local cTipReg 		:= iIf(len(aDadUsr)>=2,subStr(aDadUsr[2],15,2),"")
		local cCodRda 		:= aDadRda[2]
		local cCodLoc 		:= aDadRda[12]
		local aTipBD7   	:= {}
		local i				:= 0
		local cIntPad		:= plsIntPad()
		local lPLSA001A		:= ( nRegBD6 == 0 .and. isInCallStack("PLSA001A") )
		local lCriticado 	:= .f.
		local lB45_GRAUPA	:= type("M->B45_GRAUPA") <> "U"

		default lContab := .f.
		default cNrLbor := " "
		default lLibera	:= .f.

		if lPLSA001A

			if B1N->( msSeek( xFilial("B1N") + BOW->BOW_PROTOC ) )
				cMatric := subStr(B1N->B1N_MATRIC,09,6)
				cTipReg := subStr(B1N->B1N_MATRIC,15,2)
				dData	:= M->B45_DATPRO
			else
				return
			endIf

		endIf

		if lContab .or. ( PLSPOSGLO(cIntPad,__aCdCri183[1],__aCdCri183[2],nil,"0") .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri183[1]} ) )

			cSQL := " SELECT COUNT( R_E_C_N_O_)  AS QTD,BD6_FILIAL, BD6_CODOPE, BD6_OPEUSR, BD6_CODEMP, BD6_MATRIC, BD6_TIPREG,  "
			cSQL += "        BD6_DATPRO, BD6_CODPAD, BD6_CODPRO, BD6_CODESP, BD6_CODRDA, BD6_CODLOC, BD6_LOCAL, "
			cSQL += "        BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, BD6_FASE, R_E_C_N_O_ As nRec, COUNT(*) AS QTD "
			cSQL += "   FROM " + retSqlName("BD6")
			cSQL += "  WHERE BD6_FILIAL = '" + xFilial("BD6") + "' AND "
			cSQL += "        BD6_OPEUSR = '" + cOpeUsr + "' AND "
			cSQL += "        BD6_CODEMP = '" + cCodEmp + "' AND "
			cSQL += "        BD6_MATRIC = '" + cMatric + "' AND "
			cSQL += "        BD6_TIPREG = '" + cTipReg + "' AND "
			cSQL += "        BD6_DATPRO = '" + dtos(dData) + "' AND "
			cSQL += "        BD6_CODPAD = '" + cCdTbPd + "' AND "
			cSQL += "        BD6_CODPRO = '" + cCodPro + "' AND "
			cSQL += "        BD6_CODRDA = '" + cCodRda + "' AND "
			cSQL += "        BD6_CODLOC = '" + cCodLoc + "' AND "
			cSQL += "        BD6_CODESP = '" + cCodEsp + "' AND "
			cSQL += "        BD6_NRLBOR = '" + cNrLbor + "' AND "
			cSQL += "        ( BD6_SITUAC = '1' OR BD6_LIBERA = '1' ) AND "

			if ! lContab .or. lPLSA001A

				cSQL += " BD6_FASE <> '1' AND "

				if findFunction("PlReChvEst") .and. ! lPLSA001A
					aRetAux  := PlReChvEst("BD6",.t.,.f.,.t.,.f.)
					cSQL     += aRetAux[1]
				endIf

			endIf

			if nRegBD6 > 0
				cSQL += " R_E_C_N_O_ <> " + cValToChar(nRegBD6) + " AND "
			endIf

			cSQL += " D_E_L_E_T_ = ' ' "
			cSQL += " GROUP BY R_E_C_N_O_,BD6_FILIAL,BD6_CODOPE,BD6_OPEUSR,BD6_CODEMP,BD6_MATRIC,BD6_TIPREG,BD6_DATPRO,BD6_CODPAD,BD6_CODPRO,BD6_CODESP,BD6_CODRDA,BD6_CODLOC,BD6_LOCAL,BD6_CODLDP, BD6_CODPEG,BD6_NUMERO,BD6_ORIMOV, BD6_FASE "

			dbUseArea(.t.,"TOPCONN",TCGENQRY(,,cSQL),"PLSBD6",.f.,.t.)

			if ! PLSBD6->( eof() ) .and. PLSBD6->QTD >= 1 .and. (! lLibera .or. lPLSA001A)

				aAreaBD6 := BD6->(getArea())
				aAreaBD7 := BD7->(getArea())

				BD6->(dbGoto(PLSBD6->NREC))
				BD7->(dbSetOrder(1))

				if BD7->(msSeek(xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))

					while ! BD7->(eof()) .and. BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)== BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

						aadd(aTipBD7,{BD7->BD7_CODUNM,BD7->BD7_CODTPA})

						BD7->(dbSkip())
					endDo

				endIf

			endIf

			if ! lPLSA001A

				if nRegBD6 > 0 .and. len(aTipBD7) > 0

					if empty(aAreaBD6)
						aAreaBD6 := BD6->(getArea())
					endIf

					if empty(aAreaBD7)
						aAreaBD7 := BD7->(getArea())
						BD7->(dbSetOrder(1))
					endIf

					BD6->(dbGoto(nRegBD6))

					if BD7->(msSeek(xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))

						while ! BD7->(eof()) .and.  BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)== BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

							if aScan(aTipBD7,{|x| allTrim(x[1]+x[2]) == allTrim(BD7->BD7_CODUNM+BD7->BD7_CODTPA)}) > 0

								lCriticado := .t.

								aadd(aCodCri,{__aCdCri183[1],alltrim(PLSBCTDESC()) + " Protocolo: " + PLSBD6->(BD6_CODPEG) + ", na guia: " + PLSBD6->(BD6_NUMERO),PLSBD6->BD6_CODOPE,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
								exit
							endIf

							BD7->(dbSkip())
						endDo

					endIf

				endIf

			else

				if len(aTipBD7) > 0

					if empty(aAreaBD7)
						aAreaBD7 := BD7->(getArea())
						BD7->(dbSetOrder(1))
					endIf

					if BD7->(msSeek(xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))

						while !BD7->(eof()) .and.  BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)== BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

							if lB45_GRAUPA

								if ! empty(M->B45_GRAUPA)

									if BD7->BD7_CODTPA == M->B45_GRAUPA

										lCriticado := .t.

										aadd(aCodCri,{__aCdCri183[1],alltrim(PLSBCTDESC()) + " Protocolo: " + PLSBD6->(BD6_CODPEG) + ", na guia: " + PLSBD6->(BD6_NUMERO),PLSBD6->(BD6_CODOPE),BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
										exit
									endIf

								else

									lCriticado := .t.

									aadd(aCodCri,{__aCdCri183[1],alltrim(PLSBCTDESC()) + " Protocolo: " + PLSBD6->(BD6_CODPEG) + ", na guia: " + PLSBD6->(BD6_NUMERO),PLSBD6->(BD6_CODOPE),BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
									exit

								endIf

							else

								lCriticado := .t.

								aadd(aCodCri,{__aCdCri183[1],alltrim(PLSBCTDESC()) + " Protocolo: " + PLSBD6->(BD6_CODPEG) + ", na guia: " + PLSBD6->(BD6_NUMERO),PLSBD6->(BD6_CODOPE),BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})
								exit
							endIf

							BD7->(dbSkip())
						endDo

					endIf

				endIf

			endIf

			if len(aCodCri) > 0 .and. lCriticado
				PLSCOMPCRI(aCodCri,"BD6")
				aRet := eval(__bRetErr,"BD6", PLSBD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) + cCdTbPd + cCodPro, aCodCri)
			endIf

			PLSBD6->(dbCloseArea())

		endIf

		if ! empty(aAreaBD6)
			BD6->(restArea(aAreaBD6))
		endIf

		if ! empty(aAreaBD7)
			BD7->(restArea(aAreaBD7))
		endIf

	return

	/*/{Protheus.doc} PLSSITADV
Valida Situaçao Adversa BD6_CODPRO...
@type function
@author tuliocesar
@since 28/12/10
@version 1.0
	/*/
	function PLSSITADV(cCdTbPd,cCodPro,nRecnoBd6)
		local cCodOpeRDA := ""
		local cCodRda    := ""
		local cCodPRFSol := ""
		local cCodPRFExe := ""
		local cChavLib   := ""
		local aSituac    := {}
		local aCriticas  := {}
		local nX         := 0
		local nI         := 0
		default nrecnoBd6:= 0

		if findFunction("PLSA268A")

			// Tratar Situacao Adversa x Regra no Contas Medicas
			BD6->(dbGoto(nrecnoBd6))

			cCodOpeRDA := BD6->BD6_OPERDA
			cCodRda    := BD6->BD6_CODRDA
			cCodPRFSol := BD6->BD6_REGSOL
			cCodPRFExe := BD6->BD6_REGEXE
			cChavLib   := BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)

			// PLSA268A - Retorna array com Sit. Adversa / Criticas caso exista.
			aCriticas := PLSA268A(cCdTbPd,cCodPro,cCodOpeRDA,cCodRda,cCodPRFSol,cCodPRFExe,cChavLib)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			// Descricao do Array aCriticas
			//--------------------------------------------------------------------------
			// aCriticas[n][01] - CODIGO DA CRITICA [B51->B51_PROPRI+B51->B51_CODCRI]
			// aCriticas[n][02] - DESCRICAO DA CRITICA
			// aCriticas[n][03] - TIPO DA ACAO [ALERTA \ GLOSA \ REVERSAO]
			// aCriticas[n][04] - CODIGO DA SITUACAO ADVERSA
			// aCriticas[n][05] - DESCRICAO DA SITUACAO ADVERSA
			// aCriticas[n][06] - OBSERVACAO 01
			// aCriticas[n][07] - OBSERVACAO 02
			// aCriticas[n][08] - OBSERVACAO 03
			// aCriticas[n][09] - OBSERVACAO 04
			// aCriticas[n][10] - OBSERVACAO 05
			// aCriticas[n][11] - OBSERVACAO 06
			// aCriticas[n][12] - OBSERVACAO 07
			// aCriticas[n][13] - OBSERVACAO 08
			// aCriticas[n][14] - OBSERVACAO 09
			// aCriticas[n][15] - OBSERVACAO 10
			// aCriticas[n][16] - OBSERVACAO 11
			// aCriticas[n][17] - OBSERVACAO 12

			// Trata Somente Situacao Adversa e nao Glosa -TIPO DA ACAO [ALERTA]
			if len(aCriticas) > 0

				for nX := 1 to len(aCriticas)

					if aCriticas[nX][3] == "1"

						aadd(aSituac,{aCriticas[nX][4],aCriticas[nX][5]})
						// Observacoes da situacao adversa
						for nI:= 6 to 17

							if !empty(aCriticas[nX][nI])
								aadd(aSituac,{"",aCriticas[nX][nI]})
							endIf
						next nI

					endIf

				next nX

				// Exibe
				if len(aSituac) > 0
					PLSCRIGEN(aSituac,{ {STR0020,"@C",30} , {STR0021,"@C",50 } },STR0022) //"Codigo"###"Descricao"###"Situacoes Adversas"
				endIf

			endIf

		endIf
	return .t.

	/*/{Protheus.doc} PLSREGSIT
Regra da Situacao Adversa
@type function
@author tuliocesar
@since 28/12/10
@version 1.0
	/*/
	function PLSREGSIT(cCdTbPd,cCodPro,cCodOpeRDA,cCodRda,cCodPRFSol,cCodPRFExe,cChavLib,cTpProc,lRpc)
		local aSituac		:= {}
		local aCriticas	    := {}
		local nI,nX,nJ	    := 0
		local aRet        	:= {}
		local xaRet		    := {}
		local nPosX         := 0
		local cPriori       := "4" // Ordem Prioridade
		local cIntPad		:= plsIntPad()

		default cTpProc     := ""
		default lRpc    	:= .t.

		// PLSA268A - Retorna array com Sit. Adversa / Criticas caso exista.
		aCriticas:= PLSA268A(cCdTbPd,cCodPro,cCodOpeRDA,cCodRda,cCodPRFSol,cCodPRFExe,cChavLib)

		// 1 - Judicial | 2 - Administrativo | 3 - Tecnico     <- Ordem de prioridade
		// Caso os niveis sejam iguais, tem prioridade o que foi cadastrado primeiro
		// Descricao do Array aCriticas
		//--------------------------------------------------------------------------
		// aCriticas[n][01] - CODIGO DA CRITICA [B51->B51_PROPRI+B51->B51_CODCRI]
		// aCriticas[n][02] - DESCRICAO DA CRITICA
		// aCriticas[n][03] - TIPO DA ACAO [ALERTA \ GLOSA \ REVERSAO]
		// aCriticas[n][04] - CODIGO DA SITUACAO ADVERSA
		// aCriticas[n][05] - DESCRICAO DA SITUACAO ADVERSA
		// aCriticas[n][06] - OBSERVACAO 01
		// aCriticas[n][07] - OBSERVACAO 02
		// aCriticas[n][08] - OBSERVACAO 03
		// aCriticas[n][09] - OBSERVACAO 04
		// aCriticas[n][10] - OBSERVACAO 05
		// aCriticas[n][11] - OBSERVACAO 06
		// aCriticas[n][12] - OBSERVACAO 07
		// aCriticas[n][13] - OBSERVACAO 08
		// aCriticas[n][14] - OBSERVACAO 09
		// aCriticas[n][15] - OBSERVACAO 10
		// aCriticas[n][16] - OBSERVACAO 11
		// aCriticas[n][17] - OBSERVACAO 12

		if !empty(aCriticas)

			for nX:= 1 to len(aCriticas)

				// diferente Alerta
				if aCriticas[nX][3] <> "1"

					// Verifica se e Glosa e se a critica ainda nao foi incluida
					if aCriticas[nX][3] == "2"

						cPriori := aCriticas[nX][18]

						if len(aRet) > 0
							nPosX := ascan(aRet,{|x| x[1] == aCriticas[nX][1]})
						endIf

						if nPosX == 0 .and. PLSPOSGLO(cIntPad,aCriticas[nX][1],aCriticas[nX][2])

							aadd(aRet,{aCriticas[nX][1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro} )
							aadd(aRet,{"",aCriticas[nX][5],aCriticas[nX][4]+" ","","",cCdTbPd,cCodPro} )

							// Observacoes da situacao adversa
							for nJ:= 6 to 17

								if !empty(aCriticas[nX][nJ])
									aadd(aRet,{"",aCriticas[nX][nJ],"","","",cCdTbPd,cCodPro})
								endIf

							next nJ

						endIf

						// 3 - Reversao
					else

						if aCriticas[nX][18] > cPriori
							Loop
						endIf

						// Se nao tiver glosa amarrada, reverto todas as Glosas
						if empty(aCriticas[nX][1])
							aRet :={}
						else

							// Verifico se encontro a Glosa, se encontrar retiro ela
							if len(aRet) > 0
								nPosX := ascan(aRet,{|x| x[1] == aCriticas[nX][1]})
							endIf

							if nPosX > 0

								xaRet:= {}
								lSkip	:=.t.

								for nI:= 1 to len(aRet)

									if empty(aRet[nI][1]) .and. lSkip
										Loop
									else
										if !empty(aRet[nI][1]) .and. aRet[nI][1]==aCriticas[nX][1]
											lSkip:=.t.
											Loop
										else
											lSkip:=.f.
											aadd(xaRet,aRet[nI])
										endIf
									endIf
								next nI
								aRet := aClone(xaRet)
							endIf

						endIf

					endIf

				else

					aadd(aSituac,{aCriticas[nX][4],aCriticas[nX][5]})

					// Observacoes da situacao adversa
					for nI := 6 to 17

						if !empty(aCriticas[nX][nI])
							aadd(aSituac,{"",aCriticas[nX][nI]})
						endIf

					next nI

				endIf

			next nX

			// Caso tenha situacao Adversa - Exibir
			if ! lRpc .and. len(aSituac) > 0
				PLSCRIGEN(aSituac,{ {STR0020,"@C",30} , {STR0021,"@C",50 } },STR0022) //"Codigo"###"Descricao"###"Situacoes Adversas"
			endIf

		endIf

	return( { (len(aRet) == 0) , aRet} )

	/*/{Protheus.doc} PLSCHKGPA
Tratamento do campo 45a
@type function
@author tuliocesar
@since 20/01/11
@version 1.0
	/*/
	function PLSCHKGPA(cCodOpe,cCodTab,cCodPad,cCodPro,cGrauPa,cTisVer,cDatAnalise,lTryAUX,lWeb,lTemAux)
		local aArea 			 := GetArea()
		local lRet    			 := .f.
		local dDatAnalise		 := ctod('')
		local cSlvGra 			 := ''

		local nCompTmp		:= 1
		local y				:= 1
		local arrayHue		:= {}
		local aVetAux  		:= {}
		local cMatAtual		:= ""

		default cTisVer 	 := __cTissVer
		default cDatAnalise	 := ''

		default lTryAux		:= .f. 
		default lWeb		:= .f.
		default lTemAux		:= .f.

		if !empty(cDatAnalise)
			dDatAnalise := PLSAJUDAT(cDatAnalise)
		endIf

		cCodPro := padr(cCodPro,tamSx3("BD4_CODPRO")[1])
		// Posiciona no BD4
		//BD4_FILIAL + BD4_CODTAB + BD4_CDPADP + BD4_CODPRO + BD4_CODTPA
		if cTisVer < '3'
			if !(allTrim(cGrauPa) $ getNewPar('MV_PARAUXI',"1,2,3,4"))
				BD4->( dbSetOrder(3) )
				if BD4->( msSeek( xFilial("BD4")+cCodOpe+cCodTab+cCodPad+cCodPro+cGrauPa ) )
					lRet := .t.
				else
					if BD4->( msSeek( xFilial("BD4")+cCodOpe+cCodTab+cCodPad+cCodPro ) ) .and. empty(BD4->BD4_CODTPA) .and. allTrim(cGrauPa) == cMV_PLSNAPL
						lRet := .t.
					else
						//o sistema so tem que ir no nivel acima se o cara nao preencheu o campo codigo da participacao-daher
						if BD4->( msSeek( xFilial("BD4")+cCodOpe+cCodTab+cCodPad+cCodPro ) )
							while !lRet .and. !BD4->(eof()) .and. BD4->(BD4_FILIAL + BD4_CODTAB + BD4_CDPADP + BD4_CODPRO) == xFilial("BD4")+cCodOpe+cCodTab+cCodPad+cCodPro
								if empty(BD4->BD4_CODTPA)
									BKC->(dbSetOrder(1))
									if BKC->(msSeek(xFilial("BKC")+BD4->BD4_CODIGO+cCodOpe+cGrauPa))
										lRet	:= .t.
									endIf
								endIf
								BD4->(dbSkip())
							endDo
						endIf
					endIf
				endIf
			else
				BD4->( dbSetOrder(3) )
				if BD4->( msSeek( xFilial("BD4")+cCodOpe+cCodTab+cCodPad+cCodPro))
					while !lRet .and. !BD4->(eof()) .and. BD4->(BD4_FILIAL + BD4_CODTAB + BD4_CDPADP + BD4_CODPRO) == xFilial("BD4")+cCodOpe+cCodTab+cCodPad+cCodPro
						if (allTrim(BD4->BD4_CODIGO) $ getNewPar("MV_PLSCAUX","AUX"))
							if !empty(BD4->BD4_CODTPA)
								if val(BD4->BD4_CODTPA)  >= val(cGrauPa)
									lRet	:= .t.
								endIf
							else
								if BKC->(msSeek(xFilial("BKC")+BD4->BD4_CODIGO+cCodOpe+cGrauPa))
									lRet	:= .t.
								endIf
							endIf
						else
							if BKC->(msSeek(xFilial("BKC")+BD4->BD4_CODIGO+cCodOpe+cGrauPa))
								lRet	:= .t.
							endIf

						endIf
						BD4->(dbSkip())
					endDo
				endIf
			endIf
		else

			if lWeb
				cTmpGraupa := PLSGETVINC("BTU_CDTERM", "BWT", .F., "35",  cGrauPa)
			endif

			cSql := "SELECT BWT_CODPAR FROM "+RetSqlName('BWT')
			cSql += " WHERE BWT_FILIAL = '"+xFilial('BWT')+"'"
			cSql += " AND BWT_CODOPE = '"+cCodOpe+"'"
			cSql += " AND BWT_CODEDI = '"+ iif(lWeb, cTmpGraupa, cGrauPa)+"'"
			cSql += " AND D_E_L_E_T_ = ' ' "

			dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"TrbBWT2",.f.,.t.)

			BD4->( dbSetOrder(3) )
			BKC->(dbSetOrder(1))

			while !TrbBWT2->(eof()) .and. !lRet

				cSlvGra := cGrauPa
				cGrauPa := TrbBWT2->BWT_CODPAR

				if !(allTrim(cGrauPa) $ getNewPar('MV_PARAUXI',"1,2,3,4"))

					if BD4->( msSeek( xFilial("BD4")+cCodOpe+cCodTab+cCodPad+cCodPro+cGrauPa ) )

						while !lRet .and. !BD4->(eof()) .and. BD4->(BD4_FILIAL + BD4_CODTAB + BD4_CDPADP + BD4_CODPRO + BD4_CODTPA) == xFilial("BD4")+cCodOpe+cCodTab+cCodPad+cCodPro+cGrauPa

							if (( ( dtos(dDatAnalise) >= dtos(BD4->BD4_VIGINI) ) .and. ;
									( dtos(dDatAnalise) <= dtos(BD4->BD4_VIGFIM) .or. empty(BD4->BD4_VIGFIM) ) ) .or. ;
									( empty(BD4->BD4_VIGINI) .and. empty(BD4->BD4_VIGFIM) ))
								lRet := .t.
							endIf

							BD4->(dbSkip())
						endDo

					else
						//o sistema so tem que ir no nivel acima se o cara nao preencheu o campo codigo da participacao-daher
						if BD4->( msSeek( xFilial("BD4")+cCodOpe+cCodTab+cCodPad+cCodPro ) )

							while !lRet .and. !BD4->(eof()) .and. BD4->(BD4_FILIAL + BD4_CODTAB + BD4_CDPADP + BD4_CODPRO) == xFilial("BD4")+cCodOpe+cCodTab+cCodPad+cCodPro

								If !lWeb .AND. (allTrim(BD4->BD4_CODIGO) $ getNewPar("MV_PLSCAUX","AUX")) .AND. BD4->BD4_VALREF < Val(cGrauPa)
									BD4->(dbSkip())
									Loop
								endIf
								if empty(BD4->BD4_CODTPA) .and. ;
										(( ( dtos(dDatAnalise) >= dtos(BD4->BD4_VIGINI) ) .and. ;
										( dtos(dDatAnalise) <= dtos(BD4->BD4_VIGFIM) .or. empty(BD4->BD4_VIGFIM) ) ) .or. ;
										( empty(BD4->BD4_VIGINI) .and. empty(BD4->BD4_VIGFIM) ))

									if BKC->(msSeek(xFilial("BKC")+BD4->BD4_CODIGO+cCodOpe+cGrauPa))
										lRet	:= .t.
									endIf

								endIf

								BD4->(dbSkip())
							endDo

						endIf

					endIf
				else

					if BD4->( msSeek( xFilial("BD4")+cCodOpe+cCodTab+cCodPad+cCodPro))

						while !lRet .and. !BD4->(eof()) .and. BD4->(BD4_FILIAL + BD4_CODTAB + BD4_CDPADP + BD4_CODPRO) == xFilial("BD4")+cCodOpe+cCodTab+cCodPad+cCodPro

							if (( ( dtos(dDatAnalise) >= dtos(BD4->BD4_VIGINI) ) .and. ;
									( dtos(dDatAnalise) <= dtos(BD4->BD4_VIGFIM) .or. empty(BD4->BD4_VIGFIM) ) ) .or. ;
									( empty(BD4->BD4_VIGINI) .and. empty(BD4->BD4_VIGFIM) ))

								if (allTrim(BD4->BD4_CODIGO) $ getNewPar("MV_PLSCAUX","AUX"))

									if !empty(BD4->BD4_CODTPA)

										if val(BD4->BD4_CODTPA)  >= val(cGrauPa)
											lRet	:= .t.
										endIf

									else 

										if BKC->(msSeek(xFilial("BKC")+BD4->BD4_CODIGO+cCodOpe+cGrauPa))
											lRet	:= .t.
										endIf

									endIf

								else

									if BKC->(msSeek(xFilial("BKC")+BD4->BD4_CODIGO+cCodOpe+cGrauPa))
										lRet	:= .t.
									endIf

								endIf

							endIf
							BD4->(dbSkip())
						endDo

					endIf

				endIf

				TrbBWT2->(dbSkip())
			endDo

			TrbBWT2->(DbCloseArea())
		endIf

		//Verifico se a participação informada é Aux e se permite Auxiliar em algum momento na solictiação/prorrogação, para suprimir o aviso do Portal de participação inválida
		if (lWeb .and. !lRet .and. lTemAux )
			if (cTmpGraupa $ "01,02,03,04" .and. getNewPar("MV_PLCAAUX","1") == "3")
				lRet := .t.
			endif
		endif

		//Verificação se não é um auxiliar da regra 5 da CBHPM
		if !lRet .and. lTryAux .and. cSlvGra $ "01,02,03,04" .and. getNewPar("MV_PLCAAUX","1") == "3"

			BR8->(dbSetOrder(1))

			if ( BR8->(msSeek(xFilial("BR8")+cCodPad+cCodPro)) .and. BR8->BR8_TIPEVE == "2" )

				cMatAtual := aDadosUnic[(ascan( aDadosUnic, {|x| x[1]=="NUMEROCARTEIRA"})),3]

				x := len(aMapGuia)

				while x > 0 .and. ! lRet

					//Devido à ordem das tags no XML, pra ter um array completo no final
					for y := aMapGuia[x][1] to iIf( x >= len(aMapGuia), len(aDados), aMapGuia[x+1][1])
						if aDados[y][1] == "NUMEROCARTEIRA"
							xMatric := aDados[y][3]
						elseIf aDados[y][1] == "DATAEXECUCAO"
							xData := PLSAJUDAT(aDados[y][3])
						elseIf aDados[y][1] == "CODIGOTABELA"
							xTab := aDados[y][3]
						elseIf aDados[y][1] == "CODIGOPROCEDIMENTO"
							xProc := aDados[y][3]
							aadd(arrayHue, {xData, xTab, xProc, xMatric})
						endIf
					next

					//Procuro nos itens gravados da guia
					for y := 1 to len(arrayHue)

						aVetAux  := {}

						//Se não for do mesmo beneficiário e na mesma data
						if cMatAtual <> arrayHue[y][4] .or. dDatAnalise <> arrayHue[y][1]
							Loop
						endIf

						aCompTmp := PLSCOMEVE(cCodTab,allTrim(PLSVARVINC('87','BR4',arrayHue[y][2])),allTrim(PLSVARVINC(arrayHue[y][2], 'BR8', arrayHue[y][3],CCODPAD+CSLVPRO,'\CODIGOPROCEDIMENTO',,)),cCodOpe,arrayHue[y][1])//Carrego a composicao do evento

						for nCompTmp := 1 to len(aCompTmp)

							if aCompTmp[nCompTmp,1] == "AUX"//Guardo os auxilizares encontrados na composicao
								aadd(aVetAux,aCompTmp[nCompTmp,16])//Grau de participação
							endIf

						next nCompTmp

						if len(aVetAux) > 0 .and. ascan(aVetAux, cSlvGra)//Se teve AUX, vejo se o Grau de participação é o enviado
							lRet := .t.
							Exit
						endIf
					next
					x--
				endDo

			endIf
		endIf

		RestArea(aArea)

	return lRet

	/*/{Protheus.doc} PLSVLDGPA
Valida Grau Participacao
@type function
@author tuliocesar
@since 12/05/11
@version 1.0
	/*/
	function PLSVLDGPA(cAliascab,cCodPad,cCodPro,cGrauPa)
		local aArea		:= GetArea()
		local lRet		:= .f.
		local cAlias    := ""
		local cNumLib   := ""
		local cChaveBD7 := ""

		// Rotina que esta chamando
		if cAliascab == "B0K"
			cAlias 	:= "BE4"
			cNumLib	:= M->B0I_NUMINT
		elseIf cAliascab == "B0D"
			cAlias 	:= "BE4"
			cNumLib	:= M->B0D_NUMINT
		elseIf cAliascab == "BE1"
			cAlias 	:= "BEA"
			cNumLib	:= M->BE1_NUMLIB
		endIf

		// Monta chave conforme alias
		if cAlias == "BE4"
			BE4->( dbSetOrder(2) ) //BE4_FILIAL + BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT
			cChaveDin	:= cAlias+"_OPEPEG+"+cAlias+"_CODLDP+"+cAlias+"_CODPEG+"+cAlias+"_NUMERO+"+cAlias+"_ORIMOV"
		elseIf cAlias == "BEA"
			BEA->( dbSetOrder(1) )//BEA_FILIAL + BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT + dtos(BEA_DATPRO) + BEA_HORPRO
			cChaveDin	:= cAlias+"_OPEPEG+"+cAlias+"_CODLDP+"+cAlias+"_CODPEG+"+cAlias+"_NUMGUI+"+cAlias+"_ORIMOV"
		endIf

		if !empty(cNumLib)

			// Posiciona na liberacao
			if (cAlias)->( msSeek( xFilial(cAlias)+cNumLib ) )

				cChaveBD7 := (cAlias)->&(cChaveDin)+cCodPad+cCodPro

				BD7->( dbSetOrder(2) ) //BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_CODPAD + BD7_CODPRO + BD7_CODUNM + BD7_NLANC
				if BD7->( msSeek(xFilial("BD7")+cChaveBD7) )

					while !BD7->( eof() ) .and. BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO) == cChaveBD7

						if BD7->BD7_CODTPA == cGrauPa .and. BD7->BD7_SALDO > 0
							lRet := .t.
							exit
						endIf


						BD7->( dbSkip() )
					endDo

				endIf

			endIf

		else
			lRet := .t.
		endIf

		RestArea(aArea)

	return lRet

	/*/{Protheus.doc} PLSVLDAPG
Valida se o valor apresentado e maior que o calculado
@type function
@author tuliocesar
@since 10/08/11
@version 1.0
	/*/
	function PLSVLDAPG( cAliascab,cMes,cAno,cCodInt,cCodRda,cCodEsp,cCodLoc,cCodPad,cCodPro,nQtd,dData,cHora,;
			aDadRda,aDadUsr,cPadInt,cRegAte,cPadCon,aRdas,cRegInt,cFinAte, lWeb, cValorApr, lMudaFase, cTipoGuia)
		local aArea     	:= getArea()
		local nJ			:= 1
		local lRet			:= .f.
		local lCirurgico	:= .f.
		local cAliasIte 	:= iIf( cAliascab == 'BE1' , 'BE2' , 'BEJ' )
		local cTipGui   	:= ""
		local nVlrApr		:= 0
		local nPerVia		:= 0
		local cRegPag		:= ''
		local cRegCob		:= ''
		local cNivel		:= ''
		local aPacote 		:= {0,0,{},""}
		local aRetB43 		:= {}
		local aValor		:= {}
		local nCompo		:= 1
		local cTipAdm		:= ""
		local cMV_PLSTPGV	:= getNewPar("MV_PLSTPGV","")
		local lRecGlo		:= .f.
		local nVlrGlo		:= 0
		local lGlosaApr   := .f.

		default lWeb      := .f.
		default cValorApr := ""
		default lMudaFase := .f.
		default cTipoGuia := ""

		if lMudaFase

			cAliasIte := "BD6"

		elseIf cAliascab == 'BE1'

			cAliasIte := "BE2"

		elseIf cAliascab == 'BE4'

			cAliasIte := 'BEJ'

		endIf

		if empty(cTipoGuia)
			cTipGui := iIf(cAliascab == 'BE1', '02', '03')
		else
			//Utiliza o cTipoGuia por parâmetro (caso seja fornecido)
			cTipGui := cTipoGuia
		endIf

		if ! lWeb .and. ! lMudaFase

			// Valida se esta em memoria pois o F12 (consulta) nao tem este campo em memoria
			if Type("M->"+cAliasIte+"_VLRAPR") == 'U'
				return( { lRet,cNivel } )
			endIf

			// Pega os valores da memoria
			nVlrApr	:= M->&(cAliasIte+"_VLRAPR")
			nPerVia	:= M->&(cAliasIte+"_PERVIA")
			cRegPag	:= M->&(cAliasIte+"_REGPAG")
			cRegCob	:= M->&(cAliasIte+"_REGCOB")
			cTipAdm	:= M->&( iIf(cAliascab == "BE4", "BE4", "BE1") +"_TIPADM")

		elseIf (!lWeb .and. lMudaFase)

			nVlrApr	:= &(cAliasIte+"->"+cAliasIte+"_VLRAPR")
			nPerVia	:= &(cAliasIte+"->"+cAliasIte+"_PERVIA")
			cRegPag	:= &(cAliasIte+"->"+cAliasIte+"_REGPAG")
			cRegCob	:= &(cAliasIte+"->"+cAliasIte+"_REGCOB")
			cTipAdm	:= &(iIf(cAliascab == "BE4", "BE4", "BD5")+"->"+( iIf(cAliascab == "BE4", "BE4", "BD5") +"_TIPADM"))

		elseIf lWeb
			nVlrApr	:= iIf(! empty(cValorApr), val(strTran(strTran(cValorApr,".",""),",",""))/100 , 0)
			nPerVia	:= 0
		endIf

		if nVlrApr > 0

			// Verifica se eh um procedimento cirurgico...
			BR8->( dbSetOrder(1) )
			if BR8->(msSeek(xFilial("BR8") + cCodPad + cCodPro))

				lCirurgico := iIf(BR8->BR8_TIPEVE $ "2,3",.t.,.f.)

				aRetB43 := PlRetPac(aDadRda[14],cCodRda,cCodPad,cCodPro,nil,dData)

				for nJ := 1 to len(aRetB43)

					aadd( aPacote[3],{aRetB43[nJ][1],aRetB43[nJ][2],aRetB43[nJ][5],aRetB43[nJ][4],aRetB43[nJ][6],aRetB43[nJ][9]})

					aPacote[1] += aRetB43[nJ][4]
					aPacote[2] += aRetB43[nJ][5]
					aPacote[4] := aRetB43[nJ][10]

				next

			endIf

			//glosa automatico
			if ! empty(cMV_PLSTPGV)
				lGlosaApr := ( BR8->BR8_TPPROC $ cMV_PLSTPGV )
			endIf

			if lGlosaApr

				// Calcula o valor do procedimento
				aValor := PLSCALCEVE(cCodPad,cCodPro,cMes,cAno,cCodInt,cCodRda,cCodEsp,aDadRda[21],cCodLoc,nQtd,;
					dData,aDadUsr[48],cPadInt,cRegAte,nVlrApr,aDadUsr,cPadCon,;
					{},nil,nil,nil,nil,cHora,{},nil,nil,nil,;
					{},nil,dData,cHora,{},cTipGui,.f.,nVlrApr,{},nil,;
					lCirurgico,nPerVia,cRegPag,cRegCob,nQtd,nVlrApr,aPacote,,,,,cRegInt,cFinAte,,,,,,cTipAdm)

				//regra do valor maior menor
				nVlrGlo := getValTPC(aValor[2], (nVlrApr * nQtd), lRecGlo)[2]

				if lGlosaApr .and. nVlrGlo > 0
					lRet	:= .t.
					cNivel 	:= aValor[4]
				endIf

			endIf

		endIf

		restArea(aArea)

	return( { lRet, cNivel } )

	/*/{Protheus.doc} PLSBIND
@type function
@author tuliocesar
@since 28.03.13
@version 1.0
	/*/
	function PLSBUIND(cAlias,cDescInd)
		local nOrdem := 0

		SIX->(dbSetOrder(1)) //INDICE+ORDEM
		SIX->(msSeek(cAlias))

		while SIX->(!eof())  .and.  allTrim(SIX->INDICE) == allTrim(cAlias)

			if allTrim(strTran(upper(SIX->CHAVE),' ','')) == allTrim(strTran(upper(cDescInd),' ','')) .or. allTrim(strTran(upper(cDescInd),' ','')) $ allTrim(strTran(upper(SIX->CHAVE),' ',''))

				// se for numerico o conteudo do ORDEM assume ele mesmo, senao calcula o numero do indice (ex: "A" => 10, "B" => 11, "C" => 12, etc)
				if asc(SIX->ORDEM) < 65
					nOrdem := val(SIX->ORDEM)
				else
					nOrdem := asc(SIX->ORDEM) - 55
				endIf

			endIf

			if nOrdem > 0
				exit
			endIf

			SIX->(dbSkip())
		endDo

	return(nOrdem)

	/*/{Protheus.doc} PlsEntrePeri
Função para calulo do periodo entre horas e datas
@type function
@author tuliocesar
@since 08/05/13
@version 1.0
@return array, 	//[1] dias
//[2] hora
//[3] segundos
//[4] formato hora
//[5] data calulada futuro
//[6] hora calculada futuro
//[7] Qtd Dias Fim
//[8] Qtd minutos Fim
	/*/
	function PlsEntrePeri(dDataIni1,nHoraIni1,dDataFim2,nHoraFim2,nQtdHora)
		local nDiasRet 	:= 0
		local nHoraret 	:= 0
		local nMinutos 	:= 0
		local nDiasFut 	:= 0
		local nHoraFut 	:= 0
		local si		:= iIf(dDataFim2>dDataIni1 .or. (dDataFim2==dDataIni1 .and. nHoraFim2>nHoraIni1),1,0)
		local dDtBkIni	:= dDataIni1
		local nHrBkIni	:= nHoraIni1
		local dDtFinal	:= date()
		local nHrFinal	:= time()

		default nQtdHora:=1

		nHoraIni1 := (val(left(nHoraIni1,2))*60) + val(right(nHoraIni1,2))   //Transformado tudo em minutos
		nHoraFim2 := (val(left(nHoraFim2,2))*60) + val(right(nHoraFim2,2))   //Transformado tudo em minutos
		nMinutFut := (nQtdHora*60) //Transformado tudo em minutos

		if si == 1
			dDataFim2	:=((dDataFim2-dDataIni1)*1440)+nHoraFim2    // convertendo o periodo de datas em minutos
			dDataIni1	:= nHoraIni1
			nMinutos 	:= dDataFim2-dDataIni1
		else
			dDataIni1	:=	((dDataIni1-dDataFim2)*1440)+nHoraIni1 // convertendo o periodo de datas em minutos
			dDataFim2	:=	nHoraFim2
			nMinutos	:= 	dDataIni1-dDataFim2
		endIf


		while .t.

			if nMinutos > 59

				if (nMinutos/60) > 24

					nDiasRet := int((nMinutos/60)/24)
					nMinutos := nMinutos-((nDiasRet*24)*60)
				else

					nHoraret := int(nMinutos/60)
					nMinutos := nMinutos-(nHoraret*60)

					if nHoraret == 24
						nDiasRet := nDiasRet+1
					endIf

				endIf

			else
				exit
			endIf

		endDo


		while .t.

			if nMinutFut > 59

				if (nMinutFut/60) > 24

					nDiasFut	:= int(nMinutFut/60/24)
					nMinutFut	:= nMinutFut-((nDiasFut*24)*60)

				else
					nHoraFut := int(nMinutFut/60)
					nMinutFut:= nMinutFut-(nHoraFut*60)

					if nHoraFut == 24
						nDiasFut:= nDiasFut+1
					endIf

				endIf
			else

				dDtFinal := dDtBkIni+nDiasFut

				if (val(subStr(nHrBkIni,1,2)) + nHoraFut) > 24
					nHrFinal := strZero(((val(subStr(nHrBkIni,1,2)) + nHoraFut)-24),2) + subStr(nHrBkIni,3,3)
				else
					nHrFinal := strZero(val(subStr(nHrBkIni,1,2))+nHoraFut,2)+subStr(nHrBkIni,3,3)
				endIf

				exit
			endIf
		endDo

	return({nDiasRet,nHoraret,nMinutos,strZero(nHoraret,2)+":"+strZero(nMinutos,2),dDtFinal,nHrFinal,nDiasFut,nHoraFut} )

	/*/{Protheus.doc} PLSUnHM
Desc. unidades que fazem referencia a honorario medicos
@type function
@author tuliocesar
@since 08/05/13
@version 1.0
	/*/
	function PLSUnHM()
		local cUnidades := "HM,HMR,PPM,RCC,CIR,PA,PAP,PAR,AUX,AUR,DOP,CRR,INC"

		if existBlock("PLXAUHM")
			cUnidades := execBlock("PLXAUHM",.f.,.f.,{cUnidades})
		endIf

	return cUnidades

	/*/{Protheus.doc} CProcInc
Funcao para calcular os periodos de procedimentos incompativeis
@type function
@author tuliocesar
@since 07/02/13
@version 1.0
	/*/
	static function CProcInc(dDatPro,nQuant,cUnid,cExc,cPer)
		local nDias := 0
		local nExc
		local dDtAlt := 0

		if cUnid == "1" //Dia
			nDias := nQuant
		elseIf cUnid == "2" //Mes
			nDias := 30 * nQuant
		elseIf cUnid == "3" //Ano
			nDias := 365 * nQuant
		endIf

		if cExc > 0
			if cPer == '0' // Dias
				nExc  := cExc
			elseIf cPer == '1' // Meses
				nExc := cExc * 30
			elseIf cPer == '2' // Anos
				nExc := cExc * 365
			endIf
		endIf

		dDtAlt := (dDatPro + nDias) - nExc

	return (dDtAlt)

	/*/{Protheus.doc} PLSLibAud
Funcao para verificar se a guia de liberacao/internacao carregada ja foi auditada.
@type function
@author tuliocesar
@since 25/11/13
@version 1.0
	/*/
	function PLSLibAud(cCodPro,cCdTbPd,cChavLib)
		local lRet := .f.
		local aAreaBEA	:= BEA->(GetArea())
		local aAreaBE4	:= BE4->(GetArea())
		local aAreaBD6	:= BD6->(GetArea())
		local cKeyIte	:= ""
		local cSeekBD6	:= ""
		local cSenhaRef	:= Iif(Type("BD5->BD5_SENHA") <> "U", BD5->BD5_SENHA, "")

		default cCodPro	:= ""
		default cCdTbPd	:= ""
		default cChavLib:= ""

		//Seta a chave de busca
		BEA->(DbSetOrder(1)) //BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+DTOS(BEA_DATPRO)+BEA_HORPRO
		BD6->(DbSetOrder(1)) //BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
		BE4->(DbSetOrder(2)) //BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT

		//Procura primeiro na BE4 e depois na BEA
		If !Empty(cChavLib) .And. BE4->(DBSeek(xFilial("BE4") + cChavLib))
			cSeekBD6	:= BE4->(BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO)
		ElseIf !Empty(cChavLib) .And. BEA->(DBSeek(xFilial("BEA") + cChavLib))
			cSeekBD6	:= BEA->(BEA_OPEMOV + BEA_CODLDP + BEA_CODPEG + BEA_NUMGUI)
		Endif

		// Caso nao achar e o Tratamento para Operadoras que não utilizam Liberação e sim a autorização estiver ativado
		If Empty(cSeekBD6) .And. GetNewPar("MV_PLTRAUT",.F.)
			BEA->(DbSetOrder(14)) //BEA_FILIAL+BEA_SENHA
			If !Empty(cSenhaRef) .And. BEA->(DBSeek(xFilial("BEA") + cSenhaRef))
				cSeekBD6	:= BEA->(BEA_OPEMOV + BEA_CODLDP + BEA_CODPEG + BEA_NUMGUI)
			EndIf
		EndIf

		If !Empty(cSeekBD6) .And. BD6->(DBSeek(xFilial("BD6") + cSeekBD6))
			cKeyIte := BD6->(BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO)
			//Verifica qual o BD6 corresponde ao procedimento analisado
			While !BD6->(Eof()) .And. BD6->(BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO) == cKeyIte
				If AllTrim(BD6->BD6_CODPAD) == AllTrim(cCdTbPd) .And. Alltrim(BD6->BD6_CODPRO) == Alltrim(cCodPro)
					//Campo BD6_AUDITA identifica se a guia ja foi auditada (somente verifica se ja foi submetida à auditoria, nao representa o parecer)
					lRet := BD6->BD6_AUDITA == "1"
					exit
				EndIf
				BD6->(DbSkip())
			EndDo
		EndIf

		RestArea(aAreaBEA)
		RestArea(aAreaBE4)
		RestArea(aAreaBD6)

	return lRet

	/*/{Protheus.doc} AjusDiaPer
Ajusta dia correto para exibir no log da periodicidade
@type function
@author tuliocesar
@since 11/03/13
@version 1.0
	/*/
	static function AjusDiaPer(cDia,cMes,cAno)

		// Tratamento para meses com 30 dias e o dia disponivel cai no dia 31
		if cDia == "31" .and. cMes $ "04/06/09/11"
			cDia := "01"
			cMes := strZero(val(cMes) + 1,2)
			// Tratamento para fevereiro valida se e ano bissexto para liberar o dia 29
		elseIf cMes == "02"
			if (cDia == "29" .and. val(cAno) % 4 <> 0) .or. (cDia >= "30")
				cDia := "01"
				cMes := "03"
			endIf
		endIf

		cRet := cDia+"/"+cMes+"/"+cAno

	return(cRet)

	//-------------------------------------------------------------------
	/*/{Protheus.doc} PLLibPTLi6
Funcao para verificar autorizacao de procedimentos solicitados pelo
PTU Online com valor inferior a 6 consultas eletivas

FUNCAO DESATIVADA (NAO HA CHAMADAS PARA ELA ATIVAS)

@type function
@author tuliocesar
@since 10/01/14
@version 1.0
	/*/
	//-------------------------------------------------------------------
	function PLLibPTLi6(aDadUsr,aVldGen,dData,cHora,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,cCID,cLocalExec,cCodEsp,cOpeRda,aDadRda,;
			cOpeSol,cCodPRFSol,lTratRda,nQtd,cRdaEDI,cFaces,cDente,aQtdBrow,cChavGui,cSequen,aFaces,cTpLocExec,aAuxAudPTU)

		local cCodInt      := subs(cOpeUsr + cMatrUsr, atCodOpe[1], atCodOpe[2])
		local cCodEmp      := subs(cOpeUsr + cMatrUsr, atCodEmp[1], atCodEmp[2])
		local cTipoReg     := subs(cOpeUsr + cMatrUsr, atTipReg[1], atTipReg[2])
		local cMatric      := subs(cOpeUsr + cMatrUsr, atMatric[1], atMatric[2])
		local cSexo        := aDadUsr[25]
		local cTipCEmp     := aDadUsr[08]
		local cConEmp      := aDadUsr[09]
		local cVerCon      := aDadUsr[39]
		local cSubCon      := aDadUsr[41]
		local cVerSub      := aDadUsr[42]
		local lCobProd     := aDadUsr[34] == "1"
		local lCobGCP      := aDadUsr[35] == "1"
		local cConsPad     := aDadUsr[49]
		local dDatCar      := aDadUsr[28]
		local cCodPla 	   := iIf(len(aDadUsr)>=11,aDadUsr[11],"")
		local cVersao      := iIf(len(aDadUsr)>=12,aDadUsr[12],"")
		local aRetFun      := {}
		local bAddCriPad   := { || PLSPOSGLO(PLSINTPAD(),__aCdCri001[1],__aCdCri001[2],cLocalExec,nil,cTpLocExec),  aadd(aCodCri,{__aCdCri001[1],PLSBCTDESC(),cCdTbPd+"-"+cCodPro,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro}) }

		// Niveis que serao verificados e suas ordens de prioridade para PTU
		// 1o.  - BFG - Cobertura Usuario
		// 2o.  - BFE - Grupo Cobertura Usuario
		// 3o.  - BFD - Cobertura Familia
		// 4o.  - BFC - Grupo Cobertura Familia
		// 5o.  - BT8 - Cobertura Grupo/Empresa
		// 6o.  - BT7 - Grupo Cobertura Grupo/Empresa
		// 7o.  - BB2 - Cobertura do Produto
		// 8o.  - BRV - Grupo Cobertura Produto
		// 9o.  - BR8 - Tabela Padrao

		// BFG - Cobertura Usuario...
		if aDadUsr[29] == "1"
			aRetFun := PLLibPTGen(aDadUsr,aVldGen,dData,cHora,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,cCID,cLocalExec,cCodEsp,cOpeRda,aDadRda,;
				cOpeSol,cCodPRFSol,lTratRda,nQtd,cRdaEDI,cFaces,cDente,aQtdBrow,cChavGui,cSequen,aFaces,;
				"BFG",cCodInt+cCodEmp+cMatric+cTipoReg+cCdTbPd,cTpLocExec,cCodInt)

			if aRetFun[1]
				if len(aRetFun[3]) > 0
					aAuxAudPTU := aRetFun[3]
				endIf
				return(aRetFun[2])
			endIf
		endIf
		// BFE - Grupo Cobertura Usuario...
		if aDadUsr[30] == "1"

			aRetFun := 	PLVLDGRPTU("BFE",cCodInt+cCodEmp+cMatric+cTipoReg,cSexo,cCodInt,dData,cHora,;
				dDatCar,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,cLocalExec,aDadRda,;
				cOpeSol,cCodPRFSol,lTratRda,cCodPla,cVersao,;
				cTpLocExec,cFaces,cDente,aFaces,aQtdBrow,aVldGen,cChavGui,cRDAEdi,cSequen,cCodEsp,cOpeRda,cCodInt)

			if aRetFun[1]
				if len(aRetFun[3]) > 0
					aAuxAudPTU := aRetFun[3]
				endIf
				return(aRetFun[2])
			endIf
		endIf
		// BFD - Cobertura Familia...
		if aDadUsr[32] == "1"
			aRetFun := PLLibPTGen(aDadUsr,aVldGen,dData,cHora,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,cCID,cLocalExec,cCodEsp,cOpeRda,aDadRda,;
				cOpeSol,cCodPRFSol,lTratRda,nQtd,cRdaEDI,cFaces,cDente,aQtdBrow,cChavGui,cSequen,aFaces,;
				"BFD",cCodInt+cCodEmp+cMatric+cCdTbPd,cTpLocExec,cCodInt)

			if aRetFun[1]
				if len(aRetFun[3]) > 0
					aAuxAudPTU := aRetFun[3]
				endIf
				return(aRetFun[2])
			endIf
		endIf
		// BFC - Grupo Cobertura Familia...
		if aDadUsr[33] == "1"

			aRetFun := PLVLDGRPTU("BFC",cCodInt+cCodEmp+cMatric,cSexo,cCodInt,dData,cHora,;
				dDatCar,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,cLocalExec,aDadRda,;
				cOpeSol,cCodPRFSol,lTratRda,cCodPla,cVersao,;
				cTpLocExec,cFaces,cDente,aFaces,aQtdBrow,aVldGen,cChavGui,cRDAEdi,cSequen,cCodEsp,cOpeRda,cCodInt)

			if aRetFun[1]
				if len(aRetFun[3]) > 0
					aAuxAudPTU := aRetFun[3]
				endIf
				return(aRetFun[2])
			endIf

		endIf
		// BT8 - Cobertura Subcontrato x Produto
		if  cTipCEmp == "2"

			if aDadUsr[50] == "1"

				aRetFun := PLLibPTGen(aDadUsr,aVldGen,dData,cHora,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,cCID,cLocalExec,cCodEsp,cOpeRda,aDadRda,;
					cOpeSol,cCodPRFSol,lTratRda,nQtd,cRdaEDI,cFaces,cDente,aQtdBrow,cChavGui,cSequen,aFaces,;
					"BT8",cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodPla+cVersao+cCdTbPd,cTpLocExec,cCodInt)

				if aRetFun[1]
					if len(aRetFun[3]) > 0
						aAuxAudPTU := aRetFun[3]
					endIf
					return(aRetFun[2])
				endIf

			endIf

			// BT7 - Grupo Cobertura Subcontrato x Produto
			if aDadUsr[51] == "1"

				aRetFun := PLVLDGRPTU("BT7",cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub+cCodPla+cVersao,cSexo,cCodInt,dData,cHora,; //PLSVLDGRU
					dDatCar,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,cLocalExec,aDadRda,;
					cOpeSol,cCodPRFSol,lTratRda,cCodPla,cVersao,;
					cTpLocExec,cFaces,cDente,aFaces,aQtdBrow,aVldGen,cChavGui,cRDAEdi,cSequen,cCodEsp,cOpeRda,cCodInt)

				if aRetFun[1]
					if len(aRetFun[3]) > 0
						aAuxAudPTU := aRetFun[3]
					endIf
					return(aRetFun[2])
				endIf

			endIf

		endIf

		// BB2 - Cobertura Produto...
		if lCobProd

			aRetFun := PLLibPTGen(aDadUsr,aVldGen,dData,cHora,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,cCID,cLocalExec,cCodEsp,cOpeRda,aDadRda,;
				cOpeSol,cCodPRFSol,lTratRda,nQtd,cRdaEDI,cFaces,cDente,aQtdBrow,cChavGui,cSequen,aFaces,;
				"BB2",cCodInt+cCodPla+cVersao+cCdTbPd,cTpLocExec,cCodInt)

			if aRetFun[1]
				if len(aRetFun[3]) > 0
					aAuxAudPTU := aRetFun[3]
				endIf
				return(aRetFun[2])
			endIf

		endIf

		// BRV - Grupo Cobertura Produto...
		if lCobGCP

			aRetFun := PLVLDGRPTU("BRV",cCodInt+cCodPla+cVersao,cSexo,cCodInt,dData,cHora,;
				dDatCar,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,cLocalExec,aDadRda,;
				cOpeSol,cCodPRFSol,lTratRda,cCodPla,cVersao,;
				cTpLocExec,cFaces,cDente,aFaces,aQtdBrow,aVldGen,cChavGui,cRDAEdi,cSequen,cCodEsp,cOpeRda,cCodInt)

			if aRetFun[1]
				if len(aRetFun[3]) > 0
					aAuxAudPTU := aRetFun[3]
				endIf
				return(aRetFun[2])
			endIf

		endIf

		// BR8 - Tabela padrao
		aRetFun := PLLibPTGen(aDadUsr,aVldGen,dData,cHora,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,cCID,cLocalExec,cCodEsp,cOpeRda,aDadRda,;
			cOpeSol,cCodPRFSol,lTratRda,nQtd,cRdaEDI,cFaces,cDente,aQtdBrow,cChavGui,cSequen,aFaces,;
			"BR8",cCdTbPd,cTpLocExec,cCodInt)

		if aRetFun[1]
			if len(aRetFun[3]) > 0
				aAuxAudPTU := aRetFun[3]
			endIf
			return(aRetFun[2])
		endIf

		// Caso nao autorize retorna o erro de nao autorizado padrao...
		eval(bAddCriPad)

		// alias e caminho da critica.
		PLSCOMPCRI(aCodCri,"BR8")

	return(eval(__bRetErr,"BR8",BR8->(BR8_CODPAD+BR8_CODPSA)))


	//-------------------------------------------------------------------
	/*/{Protheus.doc} PLLibPTGen
Funcao para verificar autorizacao de procedimentos solicitados pelo
PTU Online com valor inferior a 6 consultas eletivas - Realiza validacoes genericas

FUNCAO DESATIVADA (NAO HA CHAMADAS PARA ELA ATIVAS)

@type function
@author tuliocesar
@since 12/01/14
@version 1.0
	/*/
	//-------------------------------------------------------------------
	function PLLibPTGen(aDadUsr,aVldGen,dData,cHora,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,cCID,cLocalExec,cCodEsp,cOpeRda,aDadRda,;
			cOpeSol,cCodPRFSol,lTratRda,nQtd,cRdaEDI,cFaces,cDente,aQtdBrow,cChavGui,cSequen,aFaces,cAlias,cChaveAux,cTpLocExec,cCodInt)

		local cUniPer      := ""
		local cNivel       := ""
		local cAliasAut    := ""
		local nI           := 0
		local nfor         := 0
		local nQtdPer      := 0
		local nNiveis      := 0
		local aNivCobPTU   := {}
		local bChaveProc   := { || If(nfor == 1,cCodPro,Subs(cCodPro,__aNiveis[2,(nfor-1),1],__aNiveis[2,(nfor-1),2])) }
		local lAchou       := .f.
		local lTratQtd     := .t.
		local lTratCar     := .t.
		local lCriAudit    := .f. //Por padrao, todas as criticas nesse processo nao sao enviadas para Auditoria
		local aRet         := {.f.,{}}
		local aRetFun      := {}
		local aQtd         := {}
		local aPerio       := {}
		local aCarencia    := {}
		local bAddCriPad   := { || PLSPOSGLO(PLSINTPAD(),__aCdCri001[1],__aCdCri001[2],cLocalExec,nil,cTpLocExec),  aadd(aCodCri,{__aCdCri001[1],PLSBCTDESC(),cCdTbPd+"-"+cCodPro,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro}) }
		local cCodRda 	   := iIf(lTratRDA,( iIf(len(aDadRda)>=2,aDadRda[2],"" ) ),"")
		local dDatCar	   := aDadUsr[28]
		local cCodPla 	   := iIf(len(aDadUsr)>=11,aDadUsr[11],"")
		local cVersao      := iIf(len(aDadUsr)>=12,aDadUsr[12],"")

		if __cCdTbPd <> cCdTbPd .or. len(__aNiveis) == 0
			__cCdTbPd := cCdTbPd
			__aNiveis := PLSESPNIV(cCdTbPd)
		endIf
		nNiveis := (__aNiveis[1]+1)


		// seto as variaveis que vao identificar quais regras eu devo checar na funcao generica de validacoes
		if len(aVldGen) >= 1 .and. aVldGen[1] != nil
			lTratQtd := aVldGen[1] //indica se devo checar a regra de quandtidade
		endIf

		// Verifico se vou checar regra de carencia
		if len(aVldGen) >= 3 .and. aVldGen[3] != nil
			lTratCar := aVldGen[3]//indica se devo checar a regra de carencia
		endIf

		for nfor := 1 to nNiveis

			cChave := xFilial(cAlias)+cChaveAux+eval(bChaveProc)

			dbSelectArea(cAlias)
			dbSetOrder(nfor)
			msSeek(cChave)

			if Found()
				if nfor == 1
					lAchou := .t.
				else
					lAchou := (__aNiveis[2,(nfor-1),3] == &(cAlias+"->"+cAlias+"_NIVEL"))
				endIf
			else
				lAchou := .f.
			endIf
			// Se achou e esta ativo
			if lAchou .and. &(cAlias+"->"+cAlias+"_BENUTL") == "1"

				nQtdPer    := &(cAlias+"->"+cAlias+"_QTD")
				cUniPer    := &(cAlias+"->"+cAlias+"_UNCA")
				cNivel     := &(cAlias+"->"+cAlias+"_NIVEL")
				aQtd       := PlRetPaQtd(cAlias)
				aPerio	   := PlRetPaPer(cAlias)

				cAliasAut  := cAlias

				// Verifico a carencia
				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',cAlias+" recno -> "+ cValtoChar(&(cAlias+"->(recno())")) , 0, 0, {})
				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',cAlias+"->"+cAlias+"_UNCAR -> " +&(cAlias+"->"+cAlias+"_UNCAR") , 0, 0, {})
				FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01',cAlias+"->"+cAlias+"_CARENC -> "+cValToChar(&(cAlias+"->"+cAlias+"_CARENC")) , 0, 0, {})

				if lTratCar

					aRet := PLSTRATCar(&(cAlias+"->"+cAlias+"_UNCAR")  ,&(cAlias+"->"+cAlias+"_CARENC") ,;
						"1",dData,cHora,aDadUsr[28] ,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,;
						aDadUsr,cCID,cLocalExec,cCodEsp,cOpeRda,aDadRda,cOpeSol,cCodPRFSol,lTratRda)

					if !aRet[1]
						PLSINCRI(aCodCri,aRet[2])
						Exit
					endIf

					// Verifico grupos de cobertura de carencia
					aCarencia := {&(cAlias+"->"+cAlias+"_UNCAR"),&(cAlias+"->"+cAlias+"_CARENC"),"1",&(cAlias+"->"+cAlias+"_CLACAR"),cCodInt,dDatCar,.f.}

					if !empty(aCarencia[4]) //A classe de carencia deve estar preenchida

						PlsClascar(aCarencia,aDadUsr,cCdTbPd,cCodPro,cOpeUsr,cCodPla,cVersao,.t.,cAliasAut,cAlias)

						aRet := PLSTRATCar(aCarencia[1],aCarencia[2],aCarencia[3],dData,cHora,aDadUsr[28] ,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,;
							aDadUsr,cCID,cLocalExec,cCodEsp,cOpeRda,aDadRda,cOpeSol,cCodPRFSol,lTratRda)

						if !aRet[1]
							PLSINCRI(aCodCri,aRet[2])
							Exit
						endIf
					endIf

				endIf

				if nQtdPer > 0 .and. PLSPOSGLO(PLSINTPAD(),__aCdCri046[1],__aCdCri046[2],cLocalExec,nil,cTpLocExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri046[1]} ) .and. lTratQtd .And. !PLSCheckTEA(cMatric, cCid, cCdTbPd, cCodPro)

					// Verifico o limite de quantidade
					aRet := PlsTratQtd(aDadUsr[2],dData,cHora,cCdTbPd,cCodPro,nQtd,nQtdPer,cUniPer,;
						cLocalExec,nRegBD6,cNivel,aQtd,aPerio,aDadRDA,cCid,aDadUsr,;
						cAliasAut,cRdaEDI,cFaces,cDente,aFaces,aRet,aQtdBrow,cChavGui,;
						/*nPerdQtd*/,/*cPerdUni*/,/*cConsPer*/,cSequen)

					if !aRet[1]
						PLSINCRI(aCodCri,aRet[2])
						Exit
					endIf
				endIf

				// Verifico a periodiciade
				//Se a periodicidade varia por idade
				if &(cAlias+"->"+cAlias+"_DIFIDA") = '1'

					//As chaves na tabela de Period. dif. por idade são baseadas nos indices 1 de cada alias...
					//Se for criada uma chave diferente do indice, deve-se inclui-la como exceção nesta parte que busca a chave
					dbSelectArea("SIX")
					dbSetOrder(1) //INDICE+ORDEM
					if msSeek(cAlias+"1")
						cChavePer := &(cAlias+ "->(" + allTrim(SIX->CHAVE) + ")")
					End If

					aRetIdade := PLBUSDIFID(cAlias,cChavePer,aDadUsr[26],nPerioPer,cUniPerio)
					nPerioPer := aRetIdade[1]
					cUniPerio   := aRetIdade[2]
				else
					nPerioPer := &(cAlias+"->"+cAlias+"_PERIOD")
					cUniPerio   := &(cAlias+"->"+cAlias+"_UNPERI")
				endIf

				aRet := PLSTratPer(cMatrUsr,dData,cHora,cCdTbPd,cCodPro,nQtd,;
					nPerioPer,cUniPerio,cLocalExec,aDadRDA,nRegBD6,;
					cCid,lTratRda,cNivel,aDadUsr,cFaces,aQtd,aPerio,;
					cAlias,cRdaEDI,cDente,aFaces,aRet,cCodEsp,cCodRda,;
					aQtdBrow,cChavGui,/*lPeriod*/,/*cCodProExc*/,cChaveAux,cSequen)

				if !aRet[1]
					PLSINCRI(aCodCri,aRet[2])
					Exit
				endIf
				nfor := nNiveis + 1 //forco para sair do laco
				// Se achou e nao esta ativo adiciona a critica de falta de cobertura
			elseIf lAchou
				nfor := nNiveis + 1 //forco para sair do laco

				eval(bAddCriPad)
				PLSCOMPCRI(aCodCri,cAlias)
			endIf
		next
		// Verifico se achei parametrizacao
		if lAchou
			if aRet[1]
				aRetGer := {.t.,eval(__bRetAut,"1",cAlias,cChaveAux,),{}}
			else
				aRetGer := {.t.,;
					eval(__bRetErr,cAlias,cChaveAux,),;
					{.T.,iIf(lCriAudit,"1","0")} }	// Indica se o item pode ser enviado ou nao para auditoria
			endIf
		else
			aRetGer := {.f.,{},{}}
		endIf

	return(aRetGer)

	//-------------------------------------------------------------------
	/*/{Protheus.doc} PLVLDGRPTU
Funcao para verificar autorizacao de procedimentos solicitados pelo
PTU Online com valor inferior a 6 consultas eletivas - Pre-validacao dos Grupos de Cobertura

FUNCAO DESATIVADA (NAO HA CHAMADAS PARA ELA ATIVAS)

@type function
@author tuliocesar
@since 12/01/14
@version 1.0
	/*/
	//-------------------------------------------------------------------
	function PLVLDGRPTU(cAlias,cChaveAux,cSexo,cCodInt,dData,cHora,dDatCar,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,;
			cCid,nQtd,cLocalExec,aDadRda,cOpeSol,cCodPRFSol,lTratRda,cCodPla,cVersao,cTpLocExec,cFaces,cDente,;
			aFaces,aQtdBrow,aVldGen,cChavGui,cRDAEdi,cSequen,cCodEsp,cOpeRda,cCodInt)
		local aRetGer       := {.f.}
		local aRetFun       := {}
		local bRest         := { || If(!empty(cOldalias),(dbSelectArea(cOldalias),dbSetOrder(nOldOrdem),dbGoto(nOldrecno)),nil) }
		local cOldalias     := alias()
		local nOldOrdem     := indexOrd()
		local nOldrecno     := recno()
		local cFilSeek      := xFilial(cAlias)
		local nlenChave     := len(cFilSeek+cChaveAux)
		local lNegado       := .f.
		local aCriSlv       := {}
		local cCodGruNeg    := ""
		local dDatCarEsp
		default lTratRda    := .t.
		default cCodPla     := ""
		default cVersao     := ""
		default cTpLocExec  := ""
		default cFaces		:= ""
		default cDente		:= ""
		default aFaces      := {}
		default aQtdBrow	:= {}
		default aVldGen     := {}
		default cChavGui    := ""
		default cRdaEDI     := ""
		default cSequen		:= ""
		default cCodInt      := ""

		dbSelectArea(cAlias)
		dbSetOrder(1)
		if msSeek(cFilSeek+cChaveAux)
			while ! eof() .and. Subs((&(IndexKey())),1,nlenChave) == Subs(cFilSeek+cChaveAux,1,nlenChave)

				dDatCarEsp := dDatCar
				if FieldPos(cAlias+"_DATCAR") > 0
					if ! empty(&(cAlias+"->"+cAlias+"_DATCAR"))
						dDatCarEsp := &(cAlias+"->"+cAlias+"_DATCAR")
					endIf
				endIf

				aRetFun := PLGRCOBPTU(cCodInt,&(cAlias+"->"+cAlias+"_CODGRU"),cCdTbPd,cCodPro,cSexo,dData,cHora,dDatCarEsp,; //PLSGRUCOB
					nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,cLocalExec,aDadRda,cOpeSol,cCodPRFSol,lTratRda,;
					cCodPla,cVersao,cTpLocExec,cFaces,cAlias,cChaveAux,;
					cDente,aFaces,aQtdBrow,aVldGen,cChavGui,cRdaEDI,cSequen,cCodEsp,cOpeRda,aDadUsr,cCodInt)


				if valType(aRetFun) == "A"
					if   aRetFun[1]
						eval(bRest)
						aRetGer := {.t.,eval(__bRetAut,aRetFun[2],cAlias,cChaveAux+&(cAlias+"->"+cAlias+"_CODGRU"))}
						// Indica que passou na regra de 6 consultas
						aadd(aRetGer[2],.t.)

						return(aRetGer)
					else
						cCodGruNeg := &(cAlias+"->"+cAlias+"_CODGRU")
						lNegado    := .t.
						aCriSlv    := aClone(aRetFun[2])
					endIf
				endIf
				dbSkip()
			endDo

			if lNegado
				eval(bRest)
				aCodCri := aClone(aCriSlv)
				aRetGer := {.t.,eval(__bRetErr,cAlias,cChaveAux+cCodGruNeg)}
				// Se houve resposta de auditoria pre-determinada, incrementa resposta
				if len(aRetFun) > 5
					aadd(aRetGer[2],aRetFun[5])
					aadd(aRetGer[2],aRetFun[6])
				endIf

				return(aRetGer)
			endIf

		endIf

		eval(bRest)

	return(aRetGer)

	//-------------------------------------------------------------------
	/*/{Protheus.doc} PLGRCOBPTU
Funcao para verificar autorizacao de procedimentos solicitados pelo
PTU Online com valor inferior a 6 consultas eletivas - Valida Grupos de Cobertura

FUNCAO DESATIVADA (NAO HA CHAMADAS PARA ELA ATIVAS)

@type function
@author tuliocesar
@since 12/01/14
@version 1.0
	/*/
	//-------------------------------------------------------------------
	function PLGRCOBPTU(cCodInt,cCodGru,cCdTbPd,cCodPro,cSexo,dData,cHora,dDatCarEsp,nRegBD6,cOpeUsr,cMatrUsr,aDadUsr,cCid,nQtd,cLocalExec,;
			aDadRda,cOpeSol,cCodPRFSol,lTratRda,cCodPla,cVersao,cTpLocExec,cFaces,cAlias,cChaveAux,;
			cDente,aFaces,aQtdBrow,aVldGen,cChavGui,cRdaEDI,cSequen,cCodEsp,cOpeRda,aDadUsr,cCodInt)
		local bRest      := { || If(!empty(cOldalias),(dbSelectArea(cOldalias),dbSetOrder(nOldOrdem),dbGoto(nOldrecno)),nil) }
		local cOldalias  := alias()
		local nOldOrdem  := indexOrd()
		local nOldrecno  := recno()
		local nNiveis    := (__aNiveis[1]+1)
		local bAddCriPad := { || PLSPOSGLO(PLSINTPAD(),__aCdCri001[1],__aCdCri001[2],cLocalExec,nil,cTpLocExec), aadd(aCodCri,{__aCdCri001[1],PLSBCTDESC(),cCdTbPd+"-"+cCodPro,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro}) }
		local cTipCEmp   := aDadUsr[08]
		local cConEmp    := aDadUsr[09]
		local cVerCon    := aDadUsr[39]
		local cSubCon    := aDadUsr[41]
		local cVerSub    := aDadUsr[42]
		local lCobProd   := aDadUsr[34] == "1"
		local lCobGCP    := aDadUsr[35] == "1"
		local cConsPad   := aDadUsr[49]
		local lSeekVin   := .f.
		local cGruVin    := ""
		local aRetFun    := {}

		// Valida no grupo de cobertura...
		aRetFun := PLLibPTGen(aDadUsr,aVldGen,dData,cHora,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,cCID,cLocalExec,cCodEsp,cOpeRda,aDadRda,;
			cOpeSol,cCodPRFSol,lTratRda,nQtd,cRdaEDI,cFaces,cDente,aQtdBrow,cChavGui,cSequen,aFaces,;
			"BG8",cCodInt+cCodGru+cCdTbPd,cCodPro,cTpLocExec)
		if aRetFun[1]
			eval(bRest)
			return(aRetFun[2])
		endIf

		// Procura na TDE...
		BG7->(dbSetOrder(1))
		BG7->(msSeek(xFilial("BG7")+cCodInt+cCodGru))

		if BG7->(Found())

			lSeekVin := ! empty(BG7->BG7_GRUVIN)
			cGruVin  := BG7->BG7_GRUVIN

			// Procura no Grupo Vinculado...
			if lSeekVin

				// Valida no grupo de cobertura...
				aRetFun := PLLibPTGen(aDadUsr,aVldGen,dData,cHora,cCdTbPd,cCodPro,nRegBD6,cOpeUsr,cMatrUsr,cCID,cLocalExec,cCodEsp,cOpeRda,aDadRda,;
					cOpeSol,cCodPRFSol,lTratRda,nQtd,cRdaEDI,cFaces,cDente,aQtdBrow,cChavGui,cSequen,aFaces,;
					"BG8",cCodInt+cGruVin+cCdTbPd,cCodPro,cTpLocExec)

				if aRetFun[1]
					eval(bRest)
					return(aRetFun[2])
				endIf

			endIf

		endIf

		eval(bRest)

	return("NCR") //Nao checado regras para este grupo de cobertura

	/*/{Protheus.doc} PLBUSDIFID
Funcao para localizar a regra de periodicidade de acordo com a idade do beneficiario
@type function
@author tuliocesar
@since 22/10/15
@version 1.0
	/*/
	function PLBUSDIFID(cAlias,cChave,dDataNasc,nPerioPer,cUniPerio)
		local aRet 			:= {}
		local nPerioPerAux 	:= nPerioPer
		local cUniPerioAux 	:= cUniPerio

		dbSelectArea("B1Y")
		B1Y->(dbSetOrder(1))
		if B1Y->(msSeek(xFilial("B1Y")+cAlias+cChave))

			while !B1Y->(eof()) .and. xFilial("B1Y") == B1Y->B1Y_FILIAL .and. B1Y->B1Y_alias == cAlias .and. allTrim(B1Y->B1Y_CHAVE) == allTrim(cChave)

				//Transformo a idade do beneficiario e a idade da regra em dias para compara-las
				nIdadeDias	:= PlsEntrePeri(dDataNasc,time(),date(),time())[1]
				nPeriDias 	:= PLSCalcDia(B1Y->B1Y_IDADE,B1Y->B1Y_TIDADE,"1")

				//Se a idade estiver dentro do critério, recupero a regra e saio da busca
				//Desta forma a primeira regra encontrada é a que valerá.
				if nIdadeDias <= nPeriDias
					aRet := {B1Y->B1Y_PERIOD,	B1Y->B1Y_UNPERI,.t.}
					Exit
				endIf

				B1Y->(dbSkip())
			endDo

			if len(aRet) = 0
				aRet := {nPerioPerAux,	cUniPerioAux,.f.}
			endIf

		else
			aRet := {nPerioPerAux,	cUniPerioAux,.f.}
		endIf

	return aRet

	/*/{Protheus.doc} PLVLDPART
Valida participação das guias de Resumo/Honorário na Dig. Ofline.
@type function
@author PLSTEAM
@since 22/10/17
@version 1.0
	/*/
	function PLVLDPART(dDatPro, cCodRda, cCodEsp, cSubEsp, cCodLoc, cLocal, cOpeOri, cCodPla, aItens, aLstPartAnt)
		local lRet     		:= .f.
		local cOpeMov  		:= PlsIntPad()
		local lChkGpa  		:= .f.

		local cCodPad		:= ""
		local cCodPro		:= ""
		local aTpPIte 		:= {}
		local aVetTab 		:= {}
		local aCompo  		:= {}

		local cAliasTab 	:= ""
		local cCodTab   	:= ""
		local nInd			:= 0
		local nPar			:= 0
		local nCmp			:= 0
		local lAchou 		:= .f.
		local nQtdVez 		:= 0
		local cMsg 			:= ""
		local nTotAux		:= 0
		local nTamBKC_CODIGO:= tamSx3("BKC_CODIGO")[1]

		default dDatPro := ctod("")

		cCodPad := PLSRETDAD(aItens[1],"CODPAD")
		cCodPro := PLSRETDAD(aItens[1],"CODPRO")
		aTpPIte	:= PLSRETDAD(aItens[1],"ATPPAR",{})


		aVetTab := PLSRETTAB(cCodPad,cCodPro,dDatPro,;
			cOpeMov,cCodRda,cCodEsp,cSubEsp,cCodLoc + cLocal,;
			dDatPro,"1",cOpeOri,cCodPla,"2","1")

		if aVetTab[1]
			cAliasTab := aVetTab[4]
			aCompo    := PLSCOMEVE(aVetTab[3],cCodPad,cCodPro,cOpeMov,dDatPro ,nil, nil, nil, cCodRda, cCodEsp, cSubEsp, cCodLoc)
			cCodTab   := aCompo[1][15]
		endIf

		//Primeiro vou verificar se o procedimento esta configurado na B4D ou BKC
		lChkGpa := PLSCHKGPA(cOpeMov,cCodTab,cCodPad,cCodPro,allTrim(aTpPIte[1][1]),,dtoc(date()))


		if lChkGpa //Se esta configurada a participação, verificando se já existe outro grau de participação para a mesma Unidade de Saúde

			for nInd := 1 to len(aCompo)

				//Se achou a Paricipação, configurada no BD4_CODTPA, verifica se a participação é a mesma que esta sendo incluida.
				//Se esta configurado no BD4_CODTPA, autoriza direto pois no javascript Já verifica se esta duplicado, mesmo grau de participação para o mesmo  procedimento na mesma guia.
				if !empty(aCompo[nInd,16]) .and. strZero(val(allTrim(aTpPIte[1][1])),2) = strZero(val(allTrim(aCompo[nInd,16])),2)
					lRet := .t.
				endIf

			next nInd

			if !lRet

				nQtdVez := len(aCompo)

				if aLstPartAnt <> nil
					for nPar := 1 to len(aLstPartAnt)  //Loop para executar enquanto possuir partipação já adicionadas.
						if aLstPartAnt[nPar] <> nil .and. allTrim(aLstPartAnt[nPar]) <> ""
							lAchou := .f.

							for nCmp := 1 to nQtdVez

								if aCompo[nCmp] <> nil .and. !lAchou
									if !(allTrim(aCompo[nCmp,1]) $ getNewPar("MV_PLSCAUX","AUX"))
										if !empty(aCompo[nCmp,16])

											if strZero(val(allTrim(aLstPartAnt[nPar])),2) == strZero(val(allTrim(aCompo[nCmp,16])),2)
												lAchou := .t.
												aDel(aCompo,nCmp)
											endIf

										endIf


										if !lAchou // Se não achou procura na BKC.

											//Vejo se na BKC da unidade de saúde tem a participação
											BKC->(dbSetOrder(1))

											if BKC->(msSeek(xFilial("BKC")+allTrim(aCompo[nCmp,1]) + space( nTamBKC_CODIGO - len(allTrim(aCompo[nCmp,1])) )+cOpeMov+allTrim(aLstPartAnt[nPar])))
												lAchou := .t.
												aDel(aCompo,nCmp)
											endIf

										endIf
									else
										nTotAux++
									endIf

								endIf
							next
						endIf
					next
				endIf

				//Pronto, agora o acompo possuí apenas as participações que não foram usadas
				for nCmp := 1 to nQtdVez
					if aCompo[nCmp] <> nil
						BKC->(dbSetOrder(1))

						if BKC->(msSeek(xFilial("BKC")+allTrim(aCompo[nCmp,1]) + space( nTamBKC_CODIGO - len(allTrim(aCompo[nCmp,1])) ) +cOpeMov+allTrim(aTpPIte[1][1])))
							lRet := .t.
						endIf
					endIf
				next
			endIf

			if !lRet
				cMsg := "Participação informada esta configurada para mesma unidade de saude de outra participação."
			endIf

		else
			lRet := .f.
			cMsg := "Participação Informada nao existe para este procedimento."
		endIf

	return {lRet, cMsg}

	/*/{Protheus.doc} PLSPRIOR
Funcao para Tratamento de Prioridade sobre a critica de auditoria.
MV_PLSPRIO  Retorna as criticas que tem prioridade sobre a regra de auditoria
@type function
@author
@since
@version 1.0
	/*/
	Function PLSPRIOR(aCodCri,cPrioridade)
		local lPrio := .f.
		local nPos  := 0

		default cPrioridade  := getNewPar("MV_PLSPRIO","")

		nPos  := ascan( aCodCri,{|x| x[1] == __aCdCri051[1] })

		if nPos > 0

			lPrio := ascan( aCodCri, {|x| x[1] $ cPrioridade}) > 0

			if lPrio

				While .T.
					if Len(aCodCri) >= nPos .And. (aCodCri[nPos,1] == __aCdCri051[1] .or. empty(aCodCri[nPos,1]))
						aDel(aCodCri, nPos)
						aSize(aCodCri, len(aCodCri)-1)
					else
						exit
					Endif
				EndDo

			endIf

		endIf

	Return(aCodCri)

	/*/{Protheus.doc} PLRetGuiAut
Confere se o procedimento que esta na guia e a mesma Guia de autorização.

@type function
@author Totvs
@since 19/10/2017
@version 1.0
@return lRet: determina que caso for .t. o procedimento na guia contem na guia de autorização.
	/*/
Function PLRetGuiAut(cGuiaOpe,cCodPro,cCdTbPd)
Local lRet		:=.F.
Local cAliasTrb	:= ""
Local lSeekOk	:= .F.

BEA->(DbSetOrder(14)) //BEA_FILIAL+BEA_SENHA
lSeekOk := BEA->(MsSeek(xFilial("BEA") + cGuiaOpe))

If !lSeekOk
	BEA->(DbsetOrder(1))
	lSeekOk := BEA->(MsSeek(xFilial("BEA") + Substr(cGuiaOpe, 1, 18))) //codope+ano+mes+numero
											  
endif

If lSeekOk
	cAliasTrb:= GetNextAlias()
	
	BeginSql Alias cAliasTrb
		SELECT BE2_FILIAL,BE2_OPEMOV,BE2_ANOAUT,BE2_MESAUT,BE2_NUMAUT,BE2_SEQUEN
		FROM %table:BE2% BE2
		WHERE BE2_FILIAL	= %exp:xFilial("BD6")%
		AND BE2_OPEMOV 	=  %exp:BEA->BEA_OPEMOV%
		AND BE2_CODLDP 	=  %exp:BEA->BEA_CODLDP%
		AND BE2_CODPEG 	=  %exp:BEA->BEA_CODPEG%
		AND BE2_NUMERO 	=  %exp:BEA->BEA_NUMGUI%
		AND BE2_CODPAD 	=  %exp:cCdTbPd%
		AND BE2_CODPRO 	=  %exp:cCodPro%
		AND BE2.%NotDel%	
	Endsql

	If !(cAliasTrb)->(Eof())
		lRet:=.T.
	Endif
	(cAliasTrb)->(DbCloseArea())		
	
Endif

Return lRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} PLSolicBQ1
Verifica se o profissional solicitante tem parametrizacao valida de
especialidade no Alias BQ1

@author  Renan Sakai
@version P12
@since   11/12/2018
	/*/
	//-------------------------------------------------------------------
	Static Function PLSolicBQ1(cCodRda,cOpeRDA,cCdTbPd,cCodPro,cCodPRFSol,dDatPro,cTipo,cLocalExec,cEspSol)
		Local lGlo39      := .F.
		Local lRet        := .F.
		Local cSql        := ""
		Local cCodEsp     := ""
		Local cIntPad     := PlsIntPad()
		local lBBM_DATVAL := BBM->(FieldPos("BBM_DATVAL")) > 0
		Local aDadBQ1     := {}
		Local nPos        := 0
		Local nX          := 0
		Default cEspSol   := ""

		lGlo39   := PLSPOSGLO(cIntPad,__aCdCri039[1],__aCdCri039[2],cLocalExec) .and. PLSCHKCRI( {'BAU',cCodRda,__aCdCri039[1]} )
		BQ1->(DbSetOrder(1))//BQ1_FILIAL+BQ1_CODIGO+BQ1_CODESP

		if !Empty(cEspSol)
			if BQ1->(MsSeek(xFilial("BQ1")+cCodPRFSol+cEspSol))
				Aadd(aDadBQ1,{BQ1->BQ1_CODESP,""})
			endIf
		elseIf BQ1->(MsSeek(xFilial("BQ1")+cCodPRFSol))
			while BQ1->(BQ1_FILIAL+BQ1_CODIGO) == xFilial("BQ1")+cCodPRFSol .And. !BQ1->(Eof())
				Aadd(aDadBQ1,{BQ1->BQ1_CODESP,""})
				BQ1->(DbSkip())
			endDo
		endIf

		for nX := 1 to len(aDadBQ1)

			BBM->(dbSetOrder(1)) //BBM_FILIAL+BBM_CODINT+BBM_CODESP+BBM_CODPAD+BBM_CODPSA+BBM_NIVEL+BBM_TIPO+BBM_ATIVO
			if BBM->(msSeek(xFilial("BBM") + cOpeRda + aDadBQ1[nX,1] ) )

				// 1 Grupo, 2 Sub-Grupo e 3 Item...
				cSQL := "SELECT BBM_TIPO, BBM_ATIVO FROM "+RetSQLName("BBM")+" WHERE "
				cSQL += "BBM_FILIAL = '"+xFilial("BBM")+"' AND "
				cSQL += "BBM_CODINT = '"+cOpeRDA+"' AND "
				cSQL += "BBM_CODESP = '"+aDadBQ1[nX,1]+"' AND "
				cSQL += "BBM_CODPAD = '"+cCdTbPd+"' AND "

				if lBBM_DATVAL
					cSQL += "( '"+dtos(dDatPro)+"' <= BBM_DATVAL OR BBM_DATVAL = '"+Space(10)+"' )   AND "
				endIf

				cSQL += PLREQNI("BBM", "BBM_CODPSA", __aNiveis[2], cCodPro)
				cSQL += RetSQLName("BBM") + ".D_E_L_E_T_ = ' ' "

				cSQL +=  " ORDER BY BBM_NIVEL DESC "

				dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSAUTPMDD",.f.,.t.)

				if !PLSAUTPMDD->(eof())
					if PLSAUTPMDD->BBM_ATIVO == "1" //Procedimento autorizado...
						//Achou parametrizacao
						if PLSAUTPMDD->BBM_TIPO == "3" .Or. PLSAUTPMDD->BBM_TIPO == cTipo .Or. !lGlo39
							lRet := .T.
							PLSAUTPMDD->(DbCloseArea())
							exit
						endIf
					endIf
				endIf
				PLSAUTPMDD->(DbCloseArea())
			endIf

		next

		if len(aDadBQ1) > 0
			cCodEsp := aDadBQ1[1,1]
		endIf

		aRet := {lRet,cCodEsp}

	Return aRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} PLS790VGOP
Busca a guia de OPME com base na chave da guia
@author Fábio S. dos Santos
@since 30/09/2016
@version P12
	/*/
	//-------------------------------------------------------------------
	Function PLS790VGOP(cTipoGuia, cGuiPri)
		Local aArea := GetArea()
		Local cChaveGuia := ""
		Local aChaveGuia	:= {}
		Local aAreaBE4	:= BE4->(GetArea())
		Local aAreaB4A	:= B4A->(GetArea())

		If !(EmpTy(cGuiPri))

			If cTipoGuia == "05"
				BE4->(DbSetOrder(1))//BE4->BE4_CODOPE+BE4->BE4_CODLDP+BE4->BE4_CODPEG+BE4->BE4_NUMERO
				If BE4->(MsSeek(xFilial("BE4")+cGuiPri))
					cGuiPri := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
				EndIf
			EndIf

			B4A->(DbSetOrder(4))//B4A_FILIAL+B4A_GUIREF
			If B4A->(MsSeek(xFilial("B4A")+cGuiPri))
				while !(B4A->(EoF())) .AND. AllTrim(B4A->B4A_GUIREF) == AllTrim(cGuiPri)
					if B4A->B4A_TIPGUI == '09'
						cChaveGuia := B4A->(B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT)
						aadd(aChaveGuia, cChaveGuia)
					endif
					B4A->(DbSkip())
				EndDo
			EndIf

		EndIf

		Restarea(aAreaBE4)
		RestArea(aAreaB4A)
		RestArea(aArea)
	Return aChaveguia

	//-------------------------------------------------------------------
	/*/{Protheus.doc} PLSCONFMAT
Confere a Matricula do processamento de contas com a da solicitação
@author Eduardo Bento
@since 03/06/2020
	/*/
	//-------------------------------------------------------------------

	Function PLSCONFMAT (cMatric,cMatAnt,cMatSol,cMatAntSol)
		//					(PLXAUT, PLXAUT , Seek  , Seek	  )
		Local lMatConf	:= .F.

		Default cMatric		:= ""
		Default cMatAnt		:= ""
		Default cMatSol		:= ""
		Default cMatAntSol	:= ""

		//Se não tiver nenhuma matrícula, retorna F
		If Empty(cMatric) .and. Empty(cMatAnt)
			Return lMatConf
		Endif

		//Confere se é mesma matrícula ou matrícula antiga
		If (Iif(!Empty(cMatric),cMatric == cMatSol,.F.)) .or. (Iif(!Empty(cMatAnt),cMatAnt == cMatAntSol,.F.))
		lMatConf	:= .T.
		Endif

	Return lMatConf

	//-------------------------------------------------------------------
	/*/{Protheus.doc} PLCheckRefeic
Verifica se o Beneficiário tem direito a refeição informada

@author Sakai, Vinicius
@since 05/01/2021
@version Protheus 12
	/*/
	//-------------------------------------------------------------------
	Function PLCheckRefeic(nIdade, cCdTbPd, cCodPro, lIntPort, cOpeUsr, aDadUsr)

		Local cSql := ""
		Local nFindRegistro := 0
		Local lValidacao := .F.
		Local cMatVida := aDadUsr[5]
		Local lInter := lIntPort .Or. FunName() == "PLSA092"
		Local nIdaMin := 0
		Local nIdaMax := 0
		Local aIdades := {}

		// Verifica se o acompanhante é deficiente
		cSql := " SELECT COUNT(*) CONTADOR FROM " + RetSQLName("BTS") + " BTS "
		cSql += " WHERE BTS.BTS_FILIAL = '"+xFilial("BTS")+"' "
		cSql += "   AND BTS.BTS_MATVID = '"+cMatVida+"' "
		cSql += "   AND BTS.BTS_DEFFIS = '1'"
		cSql += "   AND BTS.D_E_L_E_T_ = ' ' "

		nFindRegistro := MPSysExecScalar(cSql, "CONTADOR")

		If nFindRegistro > 0
			lValidacao := .T.
			Return {lValidacao, aIdades}
		EndIf

		// Verifica idade do acompanhante
		cSql := " SELECT BKV_IDAMIN, BKV_IDAMAX FROM " + RetSQLName("BKV") + " BKV "
		cSql += " WHERE BKV.BKV_FILIAL = '"+xFilial("BKV")+"' "
		cSql += "   AND BKV.BKV_CODPAD = '"+Alltrim(cCdTbPd)+"' "
		cSql += "   AND BKV.BKV_CODPSA = '"+Alltrim(cCodPro)+"' "
		cSql += "   AND BKV.BKV_TIPO IN ('3','"+iif(lInter,"1","2")+"') "
		cSql += "   AND BKV.D_E_L_E_T_ = ' ' "

		DbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"TrbBKV",.f.,.t.)

		While !TrbBKV->(eof())

			nIdaMin  := TrbBKV->BKV_IDAMIN
			nIdaMax  := TrbBKV->BKV_IDAMAX
			aadd(aIdades,{nIdaMin,nIdaMax})

			Do case
				Case Empty(nIdaMin) .And. !Empty(nIdaMax)

					lValidacao := eval({ || ( ( nIdade <= nIdaMax) .Or. ( nIdaMax == 0 ) .Or. ;
						( !empty(aDadUsr[45]) .And. aDadUsr[45] <> cOpeUsr) ) })

				Case Empty(nIdaMax) .And. !Empty(nIdaMin)

					lValidacao := eval({ || ( ( nIdade >= nIdaMin) .Or. ( nIdaMin == 0 ) .Or. ;
						( !empty(aDadUsr[45]) .And. aDadUsr[45] <> cOpeUsr) ) })

				Case (!Empty(nIdaMin) .And. !Empty(nIdaMax)) .Or. (Empty(nIdaMin) .And. Empty(nIdaMax))

					lValidacao := Eval({ || ( ( nIdade >= nIdaMin .And. nIdade <= nIdaMax ) .Or. ;
						( nIdaMin == 0 .And. nIdaMax == 0 ) .Or. ( ! Empty(aDadUsr[45]) .And. aDadUsr[45] <> cOpeUsr) ) })
			EndCase

			//Achou uma regra valida, ja retorna a funcao como .T.
			If lValidacao
				Exit
			EndIf

			TrbBKV->(DbSkip())
		EndDo

		TrbBKV->(DbCloseArea())

	Return {lValidacao, aIdades}


	//-------------------------------------------------------------------
	/*/{Protheus.doc} PLProcRefeic
Verifica se o procedimento é de Refeição

@author Vinicius Queiros Teixeira
@since 11/11/2021
@version Protheus 12
	/*/
	//-------------------------------------------------------------------
	Function PLProcRefeic(cCdTbPd, cCodPro)

		Local lRetorno := .F.
		Local lRefeicAcomp := BR8->(FieldPos('BR8_REFACO')) > 0

		If lRefeicAcomp
			cSql := " SELECT COUNT(*) CONTADOR FROM " + RetSQLName("BR8") + " BR8 "
			cSql += " WHERE BR8.BR8_FILIAL = '"+xFilial("BR8")+"' "
			cSql += "   AND BR8.BR8_CODPAD = '"+cCdTbPd+"' "
			cSql += "   AND BR8.BR8_CODPSA = '"+cCodPro+"' "
			cSql += "   AND BR8.BR8_REFACO = '1'"
			cSql += "   AND BR8.D_E_L_E_T_ = ' ' "

			nFindRegistro := MPSysExecScalar(cSql, "CONTADOR")

			If nFindRegistro > 0
				lRetorno := .T.
			EndIf
		EndIf

	Return lRetorno


	//-------------------------------------------------------------------
	/*/{Protheus.doc} QtdLibAutorizada
Retira a quantiade de Autorização, quando já houver vinculação com
uma guia de Liberação, para evitar duplicidade de quantidade.

@author Vinicius Queiros Teixeira
@since 22/06/2021
@version Protheus 12
	/*/
	//-------------------------------------------------------------------
	Static Function QtdLibAutorizada(aDadosAdd, nQuantidade)

		Local nX := 0
		Local nFoundLiberacao := 0
		Local cGuiaOrigem := ""

		For nX := 1 To Len(aDadosAdd)

			cGuiaOrigem := aDadosAdd[nX][1]

			If !Empty(cGuiaOrigem)
				nFoundLiberacao := aScan(aDadosAdd, {|x| Alltrim(x[2]) == Alltrim(cGuiaOrigem)})

				If nFoundLiberacao > 0
					nQuantidade -= aDadosAdd[nX][3]
				EndIf
			EndIf

		Next nX

	Return nQuantidade


	//-------------------------------------------------------------------
	/*/{Protheus.doc} PLAutIntUrgPTU
Regras de Autorização das Solicitações de Guias de Internação, onde
o tipo de internação seja "Internação Clínica" e "Urgência e Emergência"
(PTU Online)

@author Vinicius Queiros Teixeira
@since 03/09/2021
@version Protheus 12
	/*/
	//-------------------------------------------------------------------
Function PLAutIntUrgPTU(aRetFun, cCdTbPd, cCodPro, nQtdSolic, cLocalExec, cTpLocExec)

	Local nX := 0
	Local lRemoveCritica := .F.
	Local aRegCriDel := {}
	Local nSize := 0
	Local cNivelCritica := ""
	Local cChave := ""
	Local aCritica := {}

	Default aRetFun := {.T., {}}
	Default nQtdSolic := 1

	nQtdSolic := IIf(nQtdSolic == 0, 1, nQtdSolic) 

	// Verifica crítica de quantidade (Critica 0AA)
	If nQtdSolic > 1
		If Len(aCodCri) == 0 .Or. Ascan(aCodCri, {|x| x[1] == __aCdCri204[1]}) == 0
			If PLSPOSGLO(PLSINTPAD(), __aCdCri204[1], __aCdCri204[2], cLocalExec, Nil, cTpLocExec)

				aAdd(aCritica, {__aCdCri204[1], PLSBCTDESC(), "", BCT->BCT_NIVEL, BCT->BCT_TIPO, cCdTbPd, cCodPro})
				aAdd(aCritica, {"", STR0203, STR0204, "", "", cCdTbPd, cCodPro}) // "Quantidade Superior a 1:" - "Para todas as Internações de Urgência/Emergência a quantidade deverá ser 1"
				aAdd(aCritica, {"", STR0205, cValtoChar(nQtdSolic), "", "", cCdTbPd, cCodPro}) // "Quantidade Solicitada: "

				PLSINCRI(aCodCri, aCritica)

				If !aRetFun[1]
					cNivelCritica := aRetFun[3]
					cChave := aRetFun[4]
				Else
					cNivelCritica := "BEJ"
					cChave := cCdTbPd+cCodPro
				EndIf

				aRetFun := eval(__bRetErr, cNivelCritica, cChave)
			EndIf
		EndIf
	EndIf

	// Remove as críticas que são não utilizadas na Solic. de Internações Clínicas de Urgência/Emergência
	If !aRetFun[1] .And. ValType(aRetFun[2]) == "A"

		For nX := 1 To Len(aRetFun[2])

			If !Empty(aRetFun[2][nX][1])

				Do Case
					// Críticas de Abrangencia
					Case Alltrim(aRetFun[2][nX][1]) $ __aCdCri500[1]+"/"+__aCdCri062[1]+"/"+__aCdCri074[1]+"/"+__aCdCri026[1] // "011/032/038/050"
						lRemoveCritica := .F.
					
					// Críticas de Carência e Cobertura
					Case Alltrim(aRetFun[2][nX][1]) $ __aCdCri003[1]+"/"+__aCdCri001[1] // "002/035"
						lRemoveCritica := .F.
					
					// Crítica de quantidade permitida
					Case Alltrim(aRetFun[2][nX][1]) $ __aCdCri204[1] // "0AA"
						lRemoveCritica := .F.

					OtherWise
						lRemoveCritica := .T.
						PlsPtuLog(cCdTbPd+"-"+allTrim(cCodPro)+" -> Removendo crítica "+aRetFun[2][nX][1]+". Internações Clínicas de Urgência/Emergência.")
				EndCase
									
			EndIf

			If lRemoveCritica
				aAdd(aRegCriDel, nX) // Posicoes do Array que serão removidos
			EndIf

		Next nX

		// Deleta posicoes marcadas do array
		If Len(aRegCriDel) > 0

			For nX := 1 To Len(aRegCriDel)

				aDel(aRetFun[2], aRegCriDel[(Len(aRegCriDel) + 1) - nX]) // Deleto a partir das ultimas posicoes para nao perder o ponteiro
				nSize++

			Next nX

			aSize(aRetFun[2], Len(aRetFun[2]) - nSize)
		EndIf

		// Sem críticas, autoriza o evento
		If Len(aRetFun[2]) == 0
			aRetFun[1] := .T.
		EndIf
	
	EndIf

Return aRetFun


	/*/{Protheus.doc} PLSCheckTEA
Verifica se a vida tem Transtorno do Espectro Autista
@author  r.soares
@version P12
@since   21.09.21
	/*/
	Function PLSCheckTEA(cMatVid, cCid, cCdTbPd, cCodPro)

		Local lRet := .F.
		Local nTEABA9 := 0
		Local nTEABTS := 0

		Default cMatVid := ""
		Default cCid := ""
		Default cCdTbPd := ""
		Default cCodPro := ""

		If !Empty(cCid) .And. PChkTEACid(cCid) .And. PChkTEAPro(cCdTbPd, cCodPro)
			If BA9->( FieldPos("BA9_TEA") ) > 0 .And. !Empty(cCid)
				cQuery := " SELECT COUNT(*) CONTADOR FROM " + RetSQLName("BA9") + " BA9 "
				cQuery += " WHERE BA9.BA9_FILIAL = '" + xFilial("BA9")+ "' "
				cQuery += " AND BA9.BA9_CODDOE = '"+ cCid +"' "
				cQuery += " AND BA9.BA9_TEA = '1' "
				cQuery += "	AND BA9.D_E_L_E_T_ = ' '"
				nTEABA9 := MPSysExecScalar(cQuery, "CONTADOR")

				If nTEABA9 > 0
					lRet := .T.
				EndIf
			EndIf

			If BTS->( FieldPos("BTS_TEA") ) > 0 .And. !Empty(cMatVid) .And. !lRet
				cQuery := " SELECT COUNT(*) CONTADOR FROM " + RetSQLName("BTS") + " BTS "
				cQuery += " WHERE BTS.BTS_FILIAL = '" + xFilial("BTS")+ "' "
				cQuery += " AND BTS.BTS_MATVID = '"+ cMatVid +"' "
				cQuery += " AND BTS.BTS_TEA = '1' "
				cQuery += "	AND BTS.D_E_L_E_T_ = ' '"
				nTEABTS := MPSysExecScalar(cQuery, "CONTADOR")

				If nTEABTS > 0
					lRet := .T.
				EndIf
			EndIf
		EndIf

	Return lRet

	/*/{Protheus.doc} PChkTEACid
Verifica os Cids que contém na guia, e se algum deles são válidos de acordo com a RN 469/21 - beneficiário Portador do Transtorno do Espectro Autista
@author  r.soares
@version P12
@since   23.09.21
	/*/
	Function PChkTEACid(cCid)

		Local lRet := .F.

		If AllTrim(cCid) $ GetNewPar("MV_PCIDTEA","F986/Q35/Q36/Q37/K07/F90/R48/G473/T20/T27/T280/R490/F985/F80/F801/F802/F809/R13/R471/R482/R480/J380/J381/J384/Z963/D141/D020/J38/J383/H90/H91/F70/F79/R470/F840/F841/F843/F845/F849/F20/F29/F50/F31/F33/F84")
			lRet := .T.
		EndIf

	Return lRet

	/*/{Protheus.doc} PChkTEAPro
Verifica os Procedimentos que contém na guia, e se algum deles são válidos de acordo com a RN 469/21 - beneficiário Portador do Transtorno do Espectro Autista
@author  r.soares
@version P12
@since   23.09.21
	/*/
	Function PChkTEAPro(cCodTab, cCodPro)

		Local lRet := .F.

		Default cCodTab := ""
		Default cCodPro := ""

		cCodTab	:= alltrim(PLSGETVINC("BTU_CDTERM", "BR4", .F., "87",  ,.T.))
		cCodPro := alltrim(PLSGETVINC("BTU_CDTERM", "BR8", .F., cCodTab, , .F. ))
		If cCodPro $ GetNewPar("MV_PLSTEA","50000616/50000470")
			lRet := .T.
		EndIf

	Return lRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} PlsAtuSlv
Função criada para atender as novas regras de carência para beneficiário transferido.
Nessa nova regra o sistema deve avaliar se no novo plano tem as mesmas (Redes Referenciadas ou Tipo de rede (definido no parâmetro abaixo lTipoR)) que no plano antigo.
A mesma validação é feita para o padrão de acomodação. Por exemplo: Caso o Benef tenha a comodação X no plano atual, mas não a tenha em produtos anteriores o sistema vai utilizar a data que
o beneficiário foi transferido (bloqueio) para outro produto ou contrato como data de carência.
aSlvUsr = Array com as infromações do beneficiário em planos anteriores
lTipoR  = Trata-se de um parâmetro. Quando esta variável for .T. significa que temos que considerar o Tipo de Rede. Com F consideramos o cadastro de Rede Referenciada.
lAllRed = Quando estiver igual a T significa que o produto que o beneficiário usa hoje pode atender todas os tipos de rede. Sendo assim desnconsidero as validações.

@author jose.paulo
@since 14/07/2022
@version Protheus 12
	/*/
	//-------------------------------------------------------------------
	Function PlsAtuSlv(aSlvUsr,lTipoR,lAllRed,aDadusr)
		Local nH         := 0
		Local cDadAnt    := ""
		Local cDados     := ""
		Local aChkRe     := {}
		Local lSeg       := .T.
		Default aSlvUsr  := {}
		default aDadusr  := {}
		Default lTipoR   := .F.
		Default lAllRed  := .F.

		If !lTipoR
			cDados:= ChkRedeA(aDadusr[37]+aDadusr[11]+aDadusr[12])
			aChkRe:=StrTokArr(cDados,"/")
		ElseIF !lAllRed
			cDados:= ChkTipR(aDadusr[37]+aDadusr[11]+aDadusr[12])
			aChkRe:=StrTokArr(cDados,"/")
		EndIf

		If !lTipoR                                                           //vou analisar o cadastro de Rede Referenciada no produto
			cDadAnt+= ChkRedeA(aSlvUsr[37]+aSlvUsr[11]+aSlvUsr[12])          //Pego todas as redes que estão neste roduto antigo do benef.

			If Empty(cDados) .And. Empty(cDadAnt)                            //se nada foi encontrado, aplico a nova regra inserindo a data de bloqueio no lugar da carência
				lSeg:= .F.

			ElseIf !Empty(cDados) .And. Empty(cDadAnt)
				lSeg:= .F.

			ElseIf !Empty(cDados) .And. !Empty(cDadAnt)
				For nH:=1 to Len(aChkRe)
					If !(aChkRe[nH] $ cDadAnt)
						lSeg:= .F.
					EndIf
				Next nH
			EndIf
		EndIf

		If lTipoR .And. !lAllRed
			cDadAnt+= ChkTipR(aSlvUsr[37]+aSlvUsr[11]+aSlvUsr[12])

			If Empty(cDados) .And. Empty(cDadAnt)
				lSeg:= .F.
			ElseIf !Empty(cDados) .And. Empty(cDadAnt)
				lSeg:= .F.
			ElseIf !Empty(cDados) .And. !Empty(cDadAnt)
				For nH:=1 to Len(aChkRe)
					If !(aChkRe[nH] $ cDadAnt)
						lSeg:= .F.
					EndIf
				Next nH

			EndIf

		EndiF

		If Empty(aSlvUsr[20]) .Or. Empty(aDadusr[20])
			lSeg:= .F.
		ElseIf !Empty(aSlvUsr[20]) .And. !Empty(aDadusr[20])
			If aSlvUsr[20] <> aDadusr[20]
				lSeg:= .F.
			EndIf
		EndIf

		AADD(aSlvUsr,lSeg)

	Return aclone(aSlvUsr)


	/*/{Protheus.doc} ChkRedeA
Procura a rede credenciada. A verificação é apenas para saber se existe ou não no Produto antigo.
@author  jose.paulo
@version P12
@since   11/07/2022
	/*/
	Function ChkRedeA(cChvRde)
		Local   cSql    := ""
		Local   cRet    := ""
		Default cChvRde := ""

		cSQL := " SELECT BT4_CODCRE "
		cSql += "   FROM " + retSqlName("BT4")
		cSql += "  WHERE BT4_FILIAL = '" + xFilial("BT4") + "' "
		cSQL += "    AND BT4_CODIGO = '" + substr(cChvRde,1,8)  + "'  "
		cSQL += "    AND BT4_VERSAO = '" + substr(cChvRde,9,3)  + "'  "
		cSQL += "    AND BT4_PERM  <> '1'  "
		cSQL += "    AND D_E_L_E_T_ = ' ' "
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSREDEA",.f.,.t.)

		while !PLSREDEA->(eof())
			cRet+= PLSREDEA->BT4_CODCRE + "/"
			PLSREDEA->(dbSkip())
		EndDo

		PLSREDEA->(dbCloseArea())

	Return cRet

	/*/{Protheus.doc} ChkRedeA
Procura a rede credenciada. A verificação é apenas para saber se existe ou não no Produto antigo.
@author  jose.paulo
@version P12
@since   11/07/2022
	/*/
	Function ChkTipR(cChvTp)
		Local   cSql    := ""
		Local   cRet    := ""
		Default cChvTp := ""

		cSQL := " SELECT BB6_CODRED "
		cSql += "   FROM " + retSqlName("BB6")
		cSql += "  WHERE BB6_FILIAL = '" + xFilial("BB6") + "' "
		cSQL += "    AND BB6_CODIGO = '" + substr(cChvTp,1,8)  + "'  "
		cSQL += "    AND BB6_VERSAO = '" + substr(cChvTp,9,3)  + "'  "
		cSQL += "    AND BB6_ATIVO <> '0'  "
		cSQL += "    AND D_E_L_E_T_ = ' ' "
		dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"PLSTPRED",.f.,.t.)

		while !PLSTPRED->(eof())
			cRet+= PLSTPRED->BB6_CODRED + "/"
			PLSTPRED->(dbSkip())
		EndDo

		PLSTPRED->(dbCloseArea())

	Return cRet


/*/{Protheus.doc} PlSenAut
	(usado para verificar se existe autorização da unimed origem do beneficiário )
	@type  Static Function
	@author Thiago Rodrigues
	@since 13/07/2022
	@version version
	@return Array com .t. ou .f. mais a descrição da critica
	@see (links_or_references)
/*/
Static Function PlSenAut(cNraOpeInt,cCdTbPd,cCodPro)
local aRet      := {.t.,""} 
local cSql      := ""

//Procura a autorização
cSql := " SELECT  BEA_OPEMOV, BEA_ANOAUT, BEA_MESAUT, BEA_NUMAUT, BEA_DATPRO, BEA_HORPRO"
cSql += " FROM " + retSqlName("BEA")
cSql += " WHERE BEA_FILIAL = '" + xFilial("BEA") + "' "
cSql += " AND BEA_NRAOPE = '" + cNraOpeInt + "' "
cSql += " AND BEA_OPESOL <> '" + PLSINTPAD()+  "' "
cSql += " AND D_E_L_E_T_=' ' "

dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"AliasBEA",.f.,.t.)

if !AliasBEA->(eof())
//Verifica se o item esta na autorização
	cSql := " SELECT 1 "
	cSql += " FROM " + retSqlName("BE2")
	cSql += " WHERE BE2_FILIAL = '" + xFilial("BE2") + "' "
	cSql += " AND BE2_OPEMOV = '" + AliasBEA->(BEA_OPEMOV) + "' "
	cSql += " AND BE2_ANOAUT = '" + AliasBEA->(BEA_ANOAUT) +  "' "
	cSql += " AND BE2_MESAUT = '" + AliasBEA->(BEA_MESAUT) +  "' "
	cSql += " AND BE2_NUMAUT = '" + AliasBEA->(BEA_NUMAUT) +  "' "
	cSql += " AND BE2_DATPRO = '" + AliasBEA->(BEA_DATPRO) +  "' "
	cSql += " AND BE2_HORPRO = '" + AliasBEA->(BEA_HORPRO) +  "' "
	cSql += " AND BE2_CODPAD = '" + Alltrim(cCdTbPd) +  "' "
	cSql += " AND BE2_CODPRO = '" + Alltrim(cCodPro) +  "' "
	cSql += " AND D_E_L_E_T_ = ' ' "

	dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"AliasBE2",.f.,.t.)

	if AliasBE2->(eof())
		aRet    := {.f.,STR0211+cCodPro+STR0212} //O Procedimento: cCodPro não consta na autorização
	endif

	AliasBE2->(dbCloseArea())
else 

aRet    := {.f.,STR0213} //Autorização não encontrada

endif

AliasBEA->(dbCloseArea())

Return aRet
