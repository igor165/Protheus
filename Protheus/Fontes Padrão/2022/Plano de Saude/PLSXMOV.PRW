#INCLUDE "plsxmov.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMCCR.CH"
#INCLUDE 'APWEBEX.CH'

#DEFINE G_CONSULTA  "01"
#DEFINE G_SADT "02"
#DEFINE G_SOL_INTER "03"
#DEFINE G_REEMBOLSO "04"
#DEFINE G_RES_INTER "05"
#DEFINE G_HONORARIO "06"
#DEFINE G_ANEX_QUIM "07"
#DEFINE G_ANEX_RADI "08"
#DEFINE G_ANEX_OPME "09"
#DEFINE G_REC_GLOSA "10"
#DEFINE G_PROR_INTE "11"
#DEFINE G_ODONTO "13"

#DEFINE __cTextoAll STR0001 		//"*** Todos ***"
#DEFINE __aCdCri065 {"934",STR0058}//"Time out.Operadora fora do Ar."
#DEFINE __aCdCri092 {"058",STR0051}//"Esta empresa nao pode emitir guias via POS."
#DEFINE __aCdCri096 {"060",STR0052}//"Operadora do usuario bloqueada para atendimento em intercambio."
#DEFINE __aCdCri103 {"911",STR0053}//"Operadora nao esta On-Line -> "
#DEFINE __aCdCri104 {"912",STR0054}//"Rede de atendimento de Alto Custo"
#DEFINE __aCdCri105 {"913",STR0055}//"Procedimento na cadastrado na tabela MAT/MED"
#DEFINE __aCdCri106 {"907",STR0056}//"Data de atendimento informada na transacao de internacao (On-Line)"
#DEFINE __aCdCri116 {"550",STR0095} //"Nao foi possivel localizar o nivel de cobranca."
#DEFINE __aCdCri141 {"079",STR0061}//"Item da liberação não solicitado"
#DEFINE __aCdCri142 {"080",STR0062}//"Lote de Guia já importado"
#DEFINE __aCdCri143 {"081",STR0064}//"Liberação não encontrada"
#DEFINE __aCdCri144 {"082",STR0065}//"Item da liberação já executado"
#DEFINE __aCdCri145 {"083",STR0066}//"Item com quantidade maior que a solicitada"
#DEFINE __aCdCri147 {"555",STR0068}//"Hash informado no nome do arquivo diferente do contido no arquivo"
#DEFINE __aCdCri148 {"556",STR0069}//"Hash invalido na validação do arquivo"
#DEFINE __aCdCri152 {"560",STR0070}//"Internação com data de alta"
#DEFINE __aCdCri153 {"561",STR0071}//"Incompatibilidade de informação entre (Tipo de faturamento e data de alta)"
#DEFINE __aCdCri154 {"562",STR0072}//"Honorário prestador não importador"
#DEFINE __aCdCri155 {"563",STR0073}//"Equipe informada no resumo de intrnação para guia com honorário prestador"
#DEFINE __aCdCri158 {"087",STR0074}//"Bloqueio de pagamento e cobrança, evento não Autorizado."
#DEFINE __aCdCri171 {"566",STR0085}//"Verificar informacao do Prestador,Operadora de Movimento e o local"
#DEFINE __aCdCri172 {"098",STR0086}//"Obrigatorio a informacao do prestador executante para este tipo de guia"
#DEFINE __aCdCri173 {"099",STR0087}//"Guia já processada com este de numero impresso"
#DEFINE __aCdCri197 {"09P",STR0092}//"Habilita checagem de regra para procedimentos incompatíveis!"
#DEFINE __aCdCri198 {"09Q",STR0093}//"Habilita checagem DE/PARA TUSS!"
#DEFINE __aCdCri199 {"09R",STR0096}//"Não foi possível criar usuário genérico!"
#DEFINE __aCdCri091 {"057",STR0097}//"Usuario importado invalido. Deve ser alterado o usuario para o correto ou glosada a nota."
#DEFINE __aCdCri159 {"088",STR0075}//"Matricula não existe ou invalida, criado usuário genérico."
#DEFINE __aXMLCri23 {"X23",STR0098}//"Numero da senha de autorizacao enviada invalida"
#DEFINE __aCdCri200 {"980",STR0100}//"Procedimento do tipo 'Pacote' em autorização PTU On-line"
#DEFINE __aCdCri202 {"978",STR0101}//"Registro DS_OBSERVA informado, guia automaticamente enviada para Auditoria"
#DEFINE __aCdCri203 {"979",STR0102}//"Registro DS_OPME informado, serviço não existe na tabela de Intercâmbio Nacional"
#DEFINE __aCdCri107 {"910",STR0103}//"Processo de autorizacao On-Line (Cancelado)"
#DEFINE __aCdCri210 {"906",STR0104}//"Matrícula intercâmbio inválida, rever cadastro beneficiário"
#DEFINE __aCdCri585 {"585",STR0108} //"Quantidade de diarias Solicitadas diferente do Configurado na Tabela Padrao"}
#DEFINE __aCdCri228 {"986",STR0105}//"Erro na estrutura do arquivo PTU Online gerado."
#DEFINE __aCdCri500 {"011",STR0109}//"O produto do beneficiario nao atende a esta cidade ou estado, verifique a area de abrangencia do plano."
#DEFINE __aCdCri062 {"032",STR0110}//"A Rede de Atendimento nao pode atender a usuarios deste produto."
#DEFINE __aCdCri074 {"038",STR0111}//"Produto do usuario nao permite atendimento por esta Rede de Atendimento."
#DEFINE __aCdCri026 {"050",STR0112}//"Abrangencia de atendimento nao permitida para este produto."
#define __aCdCri241 {"588",STR0114}//"Token inválido."


// Abrangencia - "AREAABR"
//     	1 = Nacional
//     	2 = Regional A - Grupo de Estados
//     	3 = Estadual
//     	4 = Regional B - Grupo de Municipios
//     	5 = Municipal
// Natureza Juridica da Contratacao - "NATJURI"
//     	2 = Fisica
//		3 = Empresarial
//     	4 = Adesao
//     	5 = Beneficente

STATIC nHoraBase	:= 0
STATIC cHoraBase	:= ""
STATIC lWLIO 		:= ( getNewPar("MV_PLCPXML",'0') == '1' ) .or. ( getNewPar("MV_PLCPWEB",'0') == '1' ) .or. ( getNewPar("MV_PLCPTON",'0') == '1' )
STATIC lBX6SQTISS := BX6->(fieldPos("BX6_SQTISS")) > 0
STATIC lBX6IDOUTD := BX6->(fieldPos("BX6_IDOUTD")) > 0
STATIC lBX6MEMORI := BX6->(fieldPos("BX6_MEMORI")) > 0
Static lcmpTiss4  := BD5->(FieldPos("BD5_SAUOCU")) > 0 .AND. BD5->(FieldPos("BD5_TMREGA")) > 0 .AND. BD5->(FieldPos("BD5_COBESP")) > 0

/*/{Protheus.doc} PLSXDIGO
Gravar Execução a partir do Controller
@type function
@author Roberto Vanderlei
@since 31.05.16
@version 1.0
/*/
function PLSXDIGO(aDados,aItens)
	local objCtrlGuia	:= nil
	local aRetorno		:= {}
	local aCriticas		:= {}
	local oObjGui		:= nil
	local nPos			:= 0
	local cTipo			:= ""
	local nQtdPJbMF		:= getNewPar("MV_JBPROFF",25)
	local lNMultT		:= .f.
	local nQtdP			:= 0

	//Inicia o processo de gravacao da guia
	objCtrlGuia := CO_Guia():New()
	oObjGui 	:= objCtrlGuia:addGuia(aDados,aItens)

	aRetorno := PLSRETOFF(oObjGui:getCodOpe() + oObjGui:getAnoPag() + oObjGui:getMesPag() + oObjGui:getNumAut())

	freeObj(oObjGui)

	oObjGui := nil
	nPos 	:= aScan(aDados,{|x| x[1] == "TIPOCONFIRM"})
	cTipo 	:= aDados[nPos,2]

	//Se quantidade de procedimentos da guia maior ou igual que o valor definido em parâmetro, é automático o uso de multithread
	//Se não, é verificado a configuração da RDA
	nQtdP := objCtrlGuia:cntProced(aRetorno[2], "1")

	if nQtdP >= nQtdPJbMF
		lNMultT := .f.
	else
		lNMultT := PLSExbCrOff(BD5->(recno()))
	endIf

	//Se não, trabalha com multithread
	if ( cTipo == "1" .and. lNMultT )

		aCriticas := PLSMDFSGDIG(BD5->(recno()))

		if valType(aCriticas) <> "A"
			aCriticas := {}
		endIf

	elseIf ( cTipo == "1" .and. ! lNMultT )

		PLSMDFSGDIG(BD5->(recno()),,"S")

	endIf

	if len(aCriticas) > 0
		aRetorno[1] := .f.
	endIf

return ( { aRetorno, aCriticas, lNMultT } )

/*/{Protheus.doc} PLSXAUTP
(long_description)
@type function
@author Tulio Cesar
@since 15.09.03
@version 1.0
/*/
function PLSXAUTP(aDados,aItens,cCaraterSol,nDestino,aMatM)

	local lImpXml   	:= PLSRETDAD( aDados,"IMPXML",.f. )
	local lImpTxt   	:= PLSRETDAD( aDados,"IMPTXT",.f. )
	local cTipoGrv		:= PLSRETDAD( aDados,"TPGRV","1" )
	local cnil 			:= eval( { || iIf( lWLIO, PLSWLIO(aDados,aItens), nil ) } )
	local cnil2			:= eval( { || PLXMVPR(@aDados,@aItens,lImpXml,cTipoGrv,lImpTxt,aMatM) } )
	local nPosRet		:= 0
	local nfor			:= 0
	local nfor2			:= 0
	local nPos			:= 0
	local nY			:= 0
	local nX			:= 0
	local nI			:= 0
	local nRecBEALIB	:= 0
	local nQtdSol		:= 0
	local nSize			:= 0
	local nVlrTPF		:= 0
	local nVlrApr 	  	:= 0
	local nVAprTot		:= 0
	local nQtdDiAut   	:= 0
	local nQtdDiNeg   	:= 0
	local nLastPos   	:= 0
	local nPosCodPad	:= 0
	local nPosCodPro	:= 0
	local nPosQtdPro	:= 0
	local nRecBAU		:= 0
	local nRecBE2		:= 0
	local nRecBeaIni  	:= BEA->( recno() )
	local cMatUsa		:= ""
	local cAno			:= ""
	local cMes			:= ""
	local cSeqMov		:= ""
	local cCodPad		:= ""
	local cCodPro		:= ""
	local cHoraPro		:= ""
	local cRegAte     	:= ""
	local cDente  		:= ""
	local cFace   		:= ""
	local cOpeOri     	:= PlsIntPad()
	local cNomUsrIE   	:= ""
	local cRetCriMv   	:= ""
	local cSomInt     	:= ""
	local cMsgClient  	:= ""
	local cSenhaOpe   	:= ""
	local cTpLibToAut	:= ""
	local cGuiaOri 		:= ""
	local cMsg			:= ""
	local cDesLoc		:= ""
	local cDesLocPro	:= ""
	local clocal		:= ""
	local cAutRet		:= ""
	local cNumGuiH		:= ""
	local clocalExec  	:= "1"
	local cAuditoria  	:= "0"
	local cLibEsp     	:= "0"
	local cRetGui  	  	:= "0"
	local cOperad		:= PLSRtCdUsr()
	local dDPrAH		:= ctod("")
	local cFilBCT     	:= xFilial("BCT")
	local cBCTPropri    := ""
	local cVersao 		:= "13/08/2013 - 035"
	local cSenBSN       := ""
	local lTrtExe		:= .f.
	local lTrtCCl		:= .f.
	local lConsulta		:= .f.
	local lOPMM			:= .f.
	local lLogTro		:= .t.
	local lTrtUsr     	:= .t.
	local lContinua   	:= .t.
	local lOnline  	  	:= .f.
	local lIncUso 	  	:= .f.
	local lAprovLib   	:= .f.
	local lFindRes		:= .f.
	local lUsuGer		:= .f.
	local lMatGer 		:= .f.
	local lOnTLine		:= .f.
	local lAto			:= .f.
	local lCriMatInv    := .f.
	local lAllAutori    := .f.
	local aTrb			:= {}
	local aRetFun		:= {}
	local aCriticas   	:= {}
	local aRetorno    	:= {}
	local aHeader     	:= {}
	local aCols       	:= {}
	local aVetTrab    	:= {}
	local aDadBEA     	:= {}
	local aDadBE4     	:= {}
	local aArea		  	:= {}
	local aEventosAut 	:= {}
	local aEventosNeg 	:= {}
	local aHeaderLib  	:= {}
	local aVetTrabLib 	:= {}
	local aColsLib	  	:= {}
	local aDadIte	  	:= {}
	local aDadCri     	:= {}
	local aCabCri     	:= {}
	local aTrbCri     	:= {}
	local aRetExe		:= {}
	local aMatOPMM		:= {}
	local aTpSlvte       := {}
	local aAutItens  	:= {}
	local aItensLOri 	:= {}
	local aDadUsr       := {}
	local aMatTroca		:= {}
	local aTpPIte		:= {}
	local aMatInf		:= {}
	local aRetLib		:= {}
	local aIndDelCols	:= {}
	local aCloneCols	:= {}
	local ACABDF 		:= {}
	local ADADDF 		:= {}
	local ATRBDF 		:= {}
	local aDadRda		:= {}
	local aRdaProf		:= {}
	local aDaSenPro		:= {}
	local aMatAlias   	:= {"BEA","BE2","BEG"}
	local aRetPECab     := {}
	local aHeadeB4B		:= {}
	local aColsB4B		:= {}
	local aDadTemp      := {}
	local lPLSA235      := .T. //Padrao e chamar cadastro PLSA235

	local aVetB4B       := {0}
	local aHeadeBQV		:= {}
	local aBQVPTUDif    := {}
	local cTipSai    	:= PLSRETDAD( aDados,"TIPSAI","" )
	local cHoraSol   	:= PLSRETDAD( aDados,"HORASOL","" )
	local cCarSol    	:= PLSRETDAD( aDados,"CARSOL","" )
	local cNumLib    	:= PLSRETDAD( aDados,"NUMLIB","" )
	local cNumSol    	:= iIf( empty(PLSRETDAD( aDados,"NUMSOL","" )), PLSRETDAD( aDados,"NUMLIB","" ), PLSRETDAD( aDados,"NUMSOL","" ))
	local cLotGui    	:= PLSRETDAD( aDados,"LOTGUI","" )
	local cPadCon	 	:= PLSRETDAD( aDados,"PADCON","" )
	local cPadInt	 	:= PLSRETDAD( aDados,"PADINT",getNewPar("MV_PLPADIN","01") )
	local cMatric    	:= PLSRETDAD( aDados,"USUARIO","" )
	local cOpeMov    	:= PLSRETDAD( aDados,"OPEMOV","" )
	local cCidPri    	:= PLSRETDAD( aDados,"CIDPRI","" )
	local cCodRda    	:= PLSRETDAD( aDados,"CODRDA","" )
	local cRdaEdi    	:= PLSRETDAD( aDados,"RDAEDI","" )
	local cNomEdi    	:= PLSRETDAD( aDados,"NOMEDI","" )
	local cCodRdaPro 	:= PLSRETDAD( aDados,"RDAPRO",cCodRda )
	local cOpeSol    	:= PLSRETDAD( aDados,"OPESOL","" )
	local cCDPFSO    	:= PLSRETDAD( aDados,"CDPFSO","" )
	local cCodEsp    	:= PLSRETDAD( aDados,"CODESP","" )
	local cNumImp    	:= PLSRETDAD( aDados,"NUMIMP","" )
	local cCodLoc    	:= PLSRETDAD( aDados,"CODLOC","" )
	local cCodLocPro 	:= PLSRETDAD( aDados,"LOCPRO","" )
	local cViaCartao 	:= PLSRETDAD( aDados,"VIACAR","" )
	local cTipoMat   	:= PLSRETDAD( aDados,"TIPOMAT","" )
	local cCodPRFExe 	:= PLSRETDAD( aDados,"CDPFEX","" )
	local cOpeExe    	:= PLSRETDAD( aDados,"CDOPEX","" )
	local cNomUsrCar 	:= PLSRETDAD( aDados,"NOMUSR","" )
	local cNrSeqTR   	:= PLSRETDAD( aDados,"NRTRAN","" )
	local cTipPre    	:= PLSRETDAD( aDados,"TPPRES","" )
	local cAreaAbr   	:= PLSRETDAD( aDados,"AREAABR","" )
	local cNumPeg    	:= PLSRETDAD( aDados,"NUMPEG","" )
	local cTipFat   	:= PLSRETDAD( aDados,"TIPFAT","" )
	local cTipGui	 	:= PLSRETDAD( aDados,"TIPGUI","" )
	local cTipInt    	:= PLSRETDAD( aDados,"TIPINT",getNewPar("MV_PLTPINT","01") )
	local cGrpInt 	 	:= PLSRETDAD( aDados,"TPEVEN","1" )
	local cIndAci	 	:= PLSRETDAD( aDados,"INDACI","" )
	local nQtNasV 	 	:= PLSRETDAD( aDados,"QTNASV",0 )
	local nQtNasM	 	:= PLSRETDAD( aDados,"QTNASM",0 )
	local nQtNasP	 	:= PLSRETDAD( aDados,"QTNASP",0 )
	local nQtObtP	 	:= PLSRETDAD( aDados,"QTOBTP",0 )
	local nQtObAR	 	:= PLSRETDAD( aDados,"QTOBAR",0 )
	local cCidObt	 	:= PLSRETDAD( aDados,"CIDOBT","" )
	local cNrdCob 	 	:= PLSRETDAD( aDados,"NRDCOB","" )
	local cObtMul 	 	:= PLSRETDAD( aDados,"OBTMUL","" )
	local cTipAlt 	 	:= PLSRETDAD( aDados,"TIPALT","" )
	local cNrdCnv 	 	:= PLSRETDAD( aDados,"NRDCNV","" )
	local cUndDoe    	:= PLSRETDAD( aDados,"UNDDOE","" )
	local nTmpDoe    	:= PLSRETDAD( aDados,"TMPDOE",0 )
	local cTipDoe    	:= PLSRETDAD( aDados,"TIPDOE","" )
	local cTranOS    	:= PLSRETDAD( aDados,"TRANORDSERV","" )
	local cOpeSolOS  	:= PLSRETDAD( aDados,"OPESOLOS","" )
	local aUnMed     	:= PLSRETDAD( aDados,"AUNMED",{} )
	local aTpParG    	:= PLSRETDAD( aDados,"ATPARG",{} )
	local cTipo      	:= PLSRETDAD( aDados,"TIPO","1" )
	local cCnpjSolT  	:= PLSRETDAD( aDados,"CGCSOLT","" )
	local cIndCli    	:= PLSRETDAD( aDados,"INDCLI","" )
	local cCobEsp    	:= PLSRETDAD( aDados,"COBESP","" ) //Cobertura especial TISS Versao 4.00
	local cArqImp	 	:= PLSRETDAD( aDados,"ARQIMP","" )
	local cTipAdm  	 	:= PLSRETDAD( aDados,"TIPADM",iIf(cCarSol=="U",subStr( getNewPar("MV_PLSCDIU","4,5") ,1,1),getNewPar("MV_PLSTPAD","1") ) )
	local cRegint  	 	:= PLSRETDAD( aDados,"REGINT","" )
	local cOpeInt    	:= PLSRETDAD( aDados,"OPEINT","" )
	local cNrOpe1100 	:= PLSRETDAD( aDados,"NRAOPE1100","" )
	local cRdaCon	 	:= PLSRETDAD( aDados,"RDACON", "" )
	local cCBOS		 	:= PLSRETDAD( aDados,"CODCBO","" )
	local cADaB7B       := PLSRETDAD( aDados,"ADADB7B","")
	local cCodOri       := PLSRETDAD( aDados,"CODORI","" )

	// Logica
	local lRegras    	:= PLSRETDAD( aDados,"CHKREG",.t. )
	local lRegPagAto 	:= PLSRETDAD( aDados,"LREGPAGATO",.t. )
	local lReanaliza 	:= PLSRETDAD( aDados,"LVALOR",.f. )
	local lRetVPF    	:= PLSRETDAD( aDados,"LRETVPF",.f. )
	local lIncAutIE  	:= PLSRETDAD( aDados,"INCAUTIE",.f. )
	local lVeioComu  	:= PLSRETDAD( aDados,"LVEIOCOMU",.f. )
	local lAudEmp    	:= PLSRETDAD( aDados,"AUDEMP",.f. )
	local lforcAud   	:= PLSRETDAD( aDados,"FORCAUD",.f. )
	local lFAudMOP   	:= PLSRETDAD( aDados,"FAUDMOP",.f. )
	local lFAudAte   	:= PLSRETDAD( aDados,"FAUDATE",.f. )
	local lPacAudi   	:= PLSRETDAD( aDados,"PACAUDI",.f.)
	local lInter     	:= PLSRETDAD( aDados,"INTERN",.f. )
	local lPtuOnline 	:= PLSRETDAD( aDados,"PTUONLINE",.f.) //Recebendo uma Solicitacao PTU Online pelo PLSTRTPTUSCS2
	local lEvolu     	:= PLSRETDAD( aDados,"EVOLU",.f. )
	local lEvoSADT   	:= PLSRETDAD( aDados,"EVOSADT",.f. )
	local lHonor     	:= PLSRETDAD( aDados,"HORIND",.f. )
	local lResInt    	:= PLSRETDAD( aDados,"RESINT",.f. )
	local lAutoCus   	:= PLSRETDAD( aDados,"ALTOCUS",.f. )
	local lGerSenha  	:= PLSRETDAD( aDados,"GERSEN",.f. )
	local lWeb 		 	:= PLSRETDAD( aDados,"RPC", ( PLSRETDAD( aDados,"TPGRV","1" ) == "2" ) )
	local lNMudFase  	:= PLSRETDAD( aDados,"LNMUDF", ( getNewPar("MV_PLMFSG",'1') == '0' )  )
	local lUnimeds   	:= iIf( allTrim( getNewPar("MV_PLSUNI","1") )=="1", .t. , .f. )
	local lIncNeg	 	:= nil
	local lLoadRda   	:= iIf( lImpXml .or. lImpTxt , iIf( allTrim( getNewPar("MV_PLSLDRD","0") )=="1",.t.,.f. ) , .f.)
	local lPtuA1100  	:= PLSRETDAD( aDados,"PTUA1100",.f. )
	local lUrgPTUInter  := PLSRETDAD( aDados,"INTCLIURG", .F.)

	local dDatNasUsr 	:= PLSRETDAD( aDados,"DATNAS",ctod("") )
	local dDataSol   	:= PLSRETDAD( aDados,"DATASOL",ctod("") )
	local dDtAlta    	:= PLSRETDAD( aDados,"DTALTA",ctod("") )
	local cHrAlta    	:= PLSRETDAD( aDados,"HRALTA","" )
	local dDtIniFat  	:= PLSRETDAD( aDados,"DTINIFAT",ctod("") )
	local cHrIniFat  	:= PLSRETDAD( aDados,"HRINIFAT","" )
	local dDtFimFat  	:= PLSRETDAD( aDados,"DTFIMFAT",ctod("") )
	local cHrFimFat  	:= PLSRETDAD( aDados,"HRFIMFAT","" )
	local dDatPro    	:= Iif( cTipo == "4".And. IsInCallStack("proconline"), PLSRETDAD( aDados,"DATACA", dDataBase), PLSRETDAD( aDados,"DATPRO", dDtIniFat))
	local cHora      	:= PLSRETDAD( aDados,"HORAPRO","" )
	local cMsg01     	:= PLSRETDAD( aDados,"MSG01","" )
	local cMsg02	 	:= PLSRETDAD( aDados,"MSG02","" )
	local cMsg03	 	:= PLSRETDAD( aDados,"MSG03","" )
	local cMsg08	 	:= PLSRETDAD( aDados,"MSG08","" )
	local cMsg09	 	:= PLSRETDAD( aDados,"MSG09","" )
	local cMsgAll     	:= PLSRETDAD( aDados,"MSGALL","" )
	local cTipoAte   	:= iIf(!empty(PLSRETDAD( aDados,"TIPATE","" )),strZero( val( PLSRETDAD( aDados,"TIPATE","" ) ),2 ),PLSRETDAD( aDados,"TIPATE","" ))
	local cOrigem    	:= PLSRETDAD( aDados,"ORIGEM","1" )
	local cCodLDP   	:= PLSRETDAD( aDados,"CODLDP",iIf(RetDigGuia(),PLSRETLDP(4),iIf(PLSOBRPRDA(cCodRda),iIf(lImpTxt,PLSRETLDP(3),PLSRETLDP(9)),PLSRETLDP(5))) )
	local cOriMov 	 	:= iIf( cTipo = "3", "2","1" )
	local lSolicit	 	:= (cOrigem == "2")	//indica se eh solicitacao, na solicitacao nao valoriza a guia
	local cCodEspPro 	:= cCodEsp
	local lRdaProf	 	:= ( cCodRda <> cCodRdaPro )
	local lforBlo    	:= PLSRETDAD( aDados,"forBLO",.f. )
	local cTipPac    	:= PLSRETDAD( aDados,"TIPPAC",alltrim(BEA->BEA_TIPPAC) )
	local aTipPart   	:= PLSRETDAD( aDados,"TIPPAR", PlRConTPA() )
	local aTpPart   	:= {}
	local cEmgest 	 	:= PLSRETDAD( aDados,"EMGEST","0" )
	local cAborto 	 	:= PLSRETDAD( aDados,"ABORTO","0" )
	local cPrvQui 	 	:= PLSRETDAD( aDados,"PRVQUI","" )
	local cPrvOpm 	 	:= PLSRETDAD( aDados,"PRVOPM","" )
	local cTraGra 	 	:= PLSRETDAD( aDados,"TRAGRA","0" )
	local cComurp 	 	:= PLSRETDAD( aDados,"COMURP","0" )
	local cAtespa  	 	:= PLSRETDAD( aDados,"ATESPA","0" )
	local cComnal 	 	:= PLSRETDAD( aDados,"COMNAL","0" )
	local cBaipes 	 	:= PLSRETDAD( aDados,"BAIPES","0" )
	local cPaareo 	 	:= PLSRETDAD( aDados,"PAAREO","0" )
	local cPatnor 	 	:= PLSRETDAD( aDados,"PATNOR","0" )
	local cEspSol 	 	:= PLSRETDAD( aDados,"ESPSOL","" )
	local cTipCon 	 	:= PLSRETDAD( aDados,"TIPCON","" )
	local dDatAcat	 	:= PLSRETDAD( aDados,"DATACA",date() )
	local cEspExe	 	:= PLSRETDAD( aDados,"ESPEXE","" )
	local lGuiHoRe	 	:= lHonor .or. lResInt
	local cAteRN   	 	:= PLSRETDAD( aDados,"ATENRN","0" )
	local cFase		 	:= PLSRETDAD( aDados,"FASE","1" )
	local cSituac	 	:= PLSRETDAD( aDados,"SITUAC",if(IsInCallStack("proconline"),if(getNewPar("MV_PLBQGUI",.f.),'3','1'),'1') ) // Determina que na importação do arquivo Tiss atraves de webservice(TISS on Line) se as guias entrarão bloqueadas.
	local cGuiOri	 	:= PLSRETDAD( aDados,"GUIORI","" )
	local cCnes      	:= PLSRETDAD( aDados,"CNES","" )
	local lPTUOnOS   	:= PLSRETDAD( aDados,"PTUONOS",.f. )
	local cStProc	 	:= ""
	local dDatRet	 	:= stod('')
	local lOkVerPTU  	:= .t.
	local lCriAutPTU 	:= .f.
	local cSituacPTU 	:= ""
	local lCriTime   	:= .f.
	local lPTUOnSol  	:= .f. //Indica se e umA solicitacao do PTU Online no Portal do Prestador
	local cAutori    	:= ""
	local nIteLibPTU 	:= 0
	local dDtRlz     	:= PLSRETDAD( aDados,"DTRLZ",ctod("") )
	local dDtRlz2    	:= PLSRETDAD( aDados,"DTRLZ2",ctod("") )
	local dDtRlz3    	:= PLSRETDAD( aDados,"DTRLZ3",ctod("") )
	local dDtRlz4    	:= PLSRETDAD( aDados,"DTRLZ4",ctod("") )
	local dDtRlz5    	:= PLSRETDAD( aDados,"DTRLZ5",ctod("") )
	local dDtRlz6    	:= PLSRETDAD( aDados,"DTRLZ6",ctod("") )
	local dDtRlz7    	:= PLSRETDAD( aDados,"DTRLZ7",ctod("") )
	local dDtRlz8    	:= PLSRETDAD( aDados,"DTRLZ8",ctod("") )
	local dDtRlz9    	:= PLSRETDAD( aDados,"DTRLZ9",ctod("") )
	local dDtRlz1    	:= PLSRETDAD( aDados,"DTRLZ1",ctod("") )
	local lFindNewUs 	:= .f.
	local aRetUsrInt 	:= {}
	local cNewAut    	:= PLSRETDAD( aDados,"NEWAUT","" )
	local lnInfEquip 	:= PLSRETDAD( aDados,"NINFEQ",.f. ) //INDICA SE FOI INforMADA EQUIPE PARA O PROCEDIMENTO
	local lXmlOrigS	 	:= PLSRETDAD( aDados,"XMLORIY",.f. ) //origem XML
	local nI1		 	:= 0
	local nI2		 	:= 0
	local aCampCust  	:= {}
	local cNomExec   	:= ""
	local cProtoc   	:= PLSRETDAD( aDados,"PROTOC","" )
	local cTokEdi   	:= PLSRETDAD( aDados,"TOKEDI","" )
	local cAusenCod      := PLSRETDAD( aDados,"AUSENCIACOD","" )
	local cGuiJur		:= PLSRETDAD( aDados,"ID_LIMINAR","" )
	local aDadB4Q    	:= {}
	local aChaveGen		:= {}
	local cSexo 		:= ""
	local cTGOriginal 	:= ""
	local aEspCbXML		:= PLSRETDAD( aDados,"ESPXML",{})
	local cGuiPri 		:= PLSRETDAD( aDados,"GUIPRI","" )
	local cNuLibera     := cNumLib
	local nQtdDiSol 	:= PLSRETDAD( aDados,"QDISOL",0)
	local lPProcDiaria	:= .f.
	local lProRadio 	:= .f.
	local lNovaLib 		:= .f.
	local lAudi 		:= .f.
	local lAtuBD6		:= .f.
	local nRecGer		:= 0
	local aAreaBAU		:= {}
	local lNrTrol       := B00->( FieldPos("B00_NRTROL") ) > 0
	local nEn
	local aRetPrt       := {}
	local lTsOnPr		:= IsInCallStack("proconline")
	local cStaGu        := ""
	local nPosRetLib    := 0
	local nIt           := 0
	local cNvCr         := ""
	local cChNv         := ""
	Local cTipAto		   := PLSRETDAD( aDados,"TIPATO","" )
	Local aProrInt		:= {}
	Local aAreaBE4
	Local lORI821		:= PLSRETDAD( aDados,"ORI821",.F. )
	Local aDadB6M		:= {}
	Local aDadB6MAux	:= {}
	Local cEtaAut	 	:= PLSRETDAD( aDados, "ETAAUT"  ,"")
	Local dDtSoli      	:= PLSRETDAD( aDados, "DTSOLI"  ,CtoD(""))
	Local cTpGuia   	:= PLSRETDAD( aDados, "TPGUIA"  ,"")
	Local cTpAcom		:= PLSRETDAD( aDados, "TPACOM"  ,"")
	Local cAliasPTU		:= PLSRETDAD( aDados, "ALIASPTU","")
	Local cTransPTU		:= PLSRETDAD( aDados, "TRANSPTU","")
	Local lPTUOn80		:= Alltrim(GetNewPar("MV_PTUVEON","80")) >= "80"
	Local aItensB6L		:= {}
	Local cNrTrolPTU	:= ""
	Local cUniOri		:= PLSRETDAD( aDados, "UNIORI","")
	Local cCdPacote		:= ""
	Local cRdaPacote	:= PLSRETDAD( aDados, "RDAPAC","")
	Local cRdaExe		:= PLSRETDAD( aDados, "RDAEXECUTANTE","")
	Local cQtdPacote	:= ""
	Local lB6L_QTDPAC   := B6L->(FieldPos("B6L_QTDPAC")) > 0
	Local cDatValAut    := ""
	Local aAutoPTU      := PLSRETDAD( aDados, "PTUONAUTO"  ,{.F.,""})
	local aSituIni     	:= PLSRETDAD( aDados,"SITUINI",{} )
	local cNumImpOD    	:= PLSRETDAD( aDados,"NUMIMPOD","" )
	local lOriHat		:= PLSRETDAD( aDados,"HAT",.f. )
	Local lPTUOn90  	:= Alltrim(GetNewPar("MV_PTUVEON", "90")) >= "90"
	Local cNomeSocial   := ""

	//Guia Consulta e SADT
	Local cCodEspNw     := PLSRETDAD( aDados, "COBESPW", "" )
	local cRegAtdNw		:= PLSRETDAD( aDados, "REGATDW", "" )
	local cSadOcuNw     := PLSRETDAD( aDados, "SADOCUW", "" )

	//Campo Observação - Prorrogação de Internação
	local cObsGuNw		:= PLSRETDAD( aDados, "OBSGUI", "" )

	private Inclui		:= .t.

	Default nDestino := 0
	Default aMatM    := {}

	if findFunction('PGetTisVer') .and. PGetTisVer() >= '3' .and. ! empty(cCarSol) .and. !lPtuOnline
		cTipAdm := cCarSol
	endIf	

	if cTipGui == G_PROR_INTE
		cTipGui		:= '03'
		cTGOriginal	:= '11'
		lNovaLib 	:= .t.
	endIf

	// Tratamento para inclusão de procedimentos negados na guia
	lIncNeg := getNewPar("MV_PLSINEG", .t.) .And. !lTsOnPr

	// PE para gravacao de campos customizados nas guias do portal
	if lWeb .and. existBlock("PPLMGCB2")
		aCampCust := execBlock("PPLMGCB2",.f.,.f.,{cTipGui,aDados,aItens} )
	endIf

	// Inicio
	nHoraBase := Seconds()
	cHoraBase := Time()
	// Tratamento Importacao XML sempre vai entrar aqui
	if lImpXml .or. lImpTxt .OR. lORI821

		// Desabilita o log.
		lWLIO	 := .f.
		lAtuPeg := iIf(lImpXml,.f.,lImpTxt) //quando eh importacao xml nao atualizo os totais

		///caso não tem itens não importa a guia
		if len(aItens) == 0

			aadd(aMatInf, {'NAO HÁ PROCEDIMENTOS NA GUIA', 'nil' } )
			aadd(aMatInf, {'NUM. GUIA PRESTADOR ', cNumImp } )

			aRetorno := {.f.,;								//1
				cAutRet,; 							//2
				"",;								//3
				aCriticas,;                         //4
				aEventosAut,;                       //5
				aEventosNeg,;                       //6
				nVlrTPF,;                           //7
				cRetCriMv,;                         //8
				cMsgClient,;                        //9
				aMatInf,;                           //10
				lAto,;								//11
				dDPrAH,;                            //12
				allTrim( str(nQtdDiAut) ),;         //13
				iIf(lGerSenha,dDatRet,ctod("")) }	//14

			return(aRetorno)
		endIf

		if cTipGui $ G_CONSULTA + '|' + G_SADT + '|' + G_HONORARIO + '|' + G_REEMBOLSO + "|" + G_ODONTO
			cMsg01 := cMsgAll//o campo de mensagem é único no bd5, por isso trocamos o conteúdo aqui
			cMsg02 := ''

			if !empty(cNumImpOD) .AND. cTipGui == G_ODONTO
				cNumImp := cNumImpOD
			endif

			cNumGuiH := PLSICM(	cOpeMov,cMatric,cTipoGrv,clocalExec,cCDPFSO,cCodPRFExe,dDatPro,cHora,cNumImp,cCodRda,cCodLDP,; //11
				cTipo,cCodLoc,cCodEsp,cTipGui,cCidPri,nQtNasV,nQtNasM,nQtNasP,nQtObtP,nQtObAR,cTipFat,cCidObt,cNrdCob,; //24
				cObtMul,cTipAlt,cNrdCnv,cLotGui,aItens,cArqImp,cNumLib,aTipPart,"BD5",lHonor,'1',cNumSol,nil,lAtuPeg,; //38
				nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,cTipSai,cTipCon,cNomUsrCar,dDatAcat,cTipoAte,cGrpInt,; //56
				cTipInt,cIndAci,cUndDoe,nTmpDoe,cTipDoe,cMsg01,cMsg02,cEspSol,cEspExe,cTipAdm,cRegint,cCarSol,aItens,cAteRN,; //70
				lImpTxt,cFase,cSituac,cGuiOri,cCnes,aCriticas,,,,,lnInfEquip, lXmlOrigS, aEspCbXML, cGuiPri, lImpXml ,;//85
				/*lChkByFase*/, cTipPac, cTipAto, /*cParCop*/, /*cTipMaj*/,,cIndCli, /*cguiint*/, @nDestino, aSituIni,; //95
				cCodEspNw, cRegAtdNw, cSadOcuNw) //98
		endIf

		if cTipGui $ G_SOL_INTER + '|' + G_RES_INTER

			cNumGuiH := PLSICM(	cOpeMov,cMatric,cTipoGrv,clocalExec,cCDPFSO,cCodPRFExe,dDatPro,cHora,cNumImp,cCodRda,cCodLDP,;
				cTipo,cCodLoc,cCodEsp,cTipGui,cCidPri,nQtNasV,nQtNasM,nQtNasP,nQtObtP,nQtObAR,cTipFat,cCidObt,cNrdCob,;
				cObtMul,cTipAlt,cNrdCnv,cLotGui,aItens,cArqImp,cNumLib,aTipPart,"BE4",.f.,'2',cNumSol,nil,lAtuPeg,;
				cPadCon,dDtAlta,cHrAlta,cEmgest,cAborto,cTraGra,cComurp,cAtespa,cComnal,cBaipes,cPaareo,cPatnor,cTipSai,;
				cTipCon,cNomUsrCar,dDatAcat,cTipoAte,cGrpInt,cTipInt,cIndAci,cUndDoe,nTmpDoe,cTipDoe,cMsg01,cMsg02,cEspSol,;
				cEspExe,cTipAdm,cRegint,cCarSol,aItens,cAteRN,lImpTxt,cFase,cSituac,cGuiOri,cCnes,aCriticas,dDtIniFat,cHrIniFat,;
				dDtFimFat,cHrFimFat,lnInfEquip, lXmlOrigS, aEspCbXML, cGuiPri, lImpXml,/*lChkByFase*/, cTipPac)

		endIf

	else

		BA1->( dbSetOrder(2) ) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO

		if !BA1->( msSeek( xFilial("BA1")+allTrim(cMatric) ) )

			BA1->( dbSetOrder(5) )//BA1_FILIAL + BA1_MATANT + BA1_TIPANT

			if !BA1->( msSeek( xFilial("BA1")+allTrim(cMatric) ) )

				// Verifico se cadastro usuario de intercambio
				if lUnimeds .and. subStr(cMatric,1,4) <> PlsIntPad() .and. (lSolicit .or. lPTUOnOS) .and. len(cMatric) == 17

					if ExistBlock("PLMOV235")
						lPLSA235 := ExecBlock("PLMOV235",.F.,.F.,{aDados,aItens})
					endIf

					if lPLSA235
						aRetUsrInt := PLSA235(.f./*lMsgNovaMat*/,cMatric,/*lInterGen*/,.t./*lIncAuto*/,cNomUsrCar,/*dDatNasUsr*/,.t./*lRPC*/,/*cSexo*/,.t./*lIncWeb*/,/*lChkCon*/,.t.)

						if aRetUsrInt[1]
							BA1->( dbSetOrder(2) )
							if BA1->(msSeek(xFilial("BA1")+aRetUsrInt[2]))
								cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
								lFindNewUs := .t.
							endIf
						endIf
					endIf
				endIf
				if !lFindNewUs
					if PLSPOSGLO(PLSINTPAD(),__aCdCri159[1],__aCdCri159[2],clocalExec,'1',cTipoGrv)
						PXMLUsrGe(cOpeMov)
					else
						lContinua := .f.
						PLSMONCRI(aItens,{},.f.,__aCdCri159[1],PLSBCTDESC(),,aCriticas,aEventosNeg)
					endIf
				endIf
			endIf
		endIf

		if lContinua

			aRetFun := PLSDADUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),"1",.f.,dDataBase)

			if aRetFun[1] .and. ! cNomUsrCar == "BENEFICIARIO INEXISTENTE"
				cMatric := allTrim(aRetFun[2])
			endIf

			aDadUsr := PLSGETUSR()

		endIf

		PLLimpCCri(.t.)

		// Inicio da checagem
		if ! lIncAutIE .and. getNewPar("MV_PLSIAIE","0") == "1"
			lIncAutIE := .t.
		endIf

		// Se for solicitacao
		if cOrigem == "2"
			dDataSol := dDatPro
			cHoraSol := cHora
		endIf

		// Se solicitacao de Ptu Online, inclui guia negada
		if lPtuOnline
			lIncNeg := .t.
		endIf

		// Ordem do BR8
		BR8->( dbSetOrder(1) ) //BR8_FILIAL + BR8_CODPAD + BR8_CODPSA + BR8_ANASIN
		// Ajusta a descricao e tpproc dos itens

		for nfor := 1 To len(aItens)

			cSeqMov 	:= PLSRETDAD(aItens[nfor],"SEQMOV")
			cCodPad 	:= PLSRETDAD(aItens[nfor],"CODPAD")
			cCodPro 	:= PLSRETDAD(aItens[nfor],"CODPRO")
			nVlrApr		:= PLSRETDAD(aItens[nfor],"VLRAPR",0)
			cCdPacote 	:= PLSRETDAD(aItens[nfor],"CDPACOTE","")
			cQtdPacote  := PLSRETDAD(aItens[nfor],"QTPACOTE","")
			nVAprTot+= nVlrApr

			If !Empty(cCdPacote) .And. PlsAliasExi("B6L") // Quando for Pacote de outra Unimed grava na B6L, para depois consultar o WebService

				If cTransPTU == "00605"
					cNrTrolPTU := StrZero(Val(PLSRETDAD( aDados,"NR_IDENT_O","")),10)
				Else
					cNrTrolPTU := cNrSeqTR
				EndIf

				aAdd(aItensB6L,{{ "B6L_SEQUEN", cSeqMov},;
					{ "B6L_ALIAS" , IIF(cAliasPTU == "BEA","BE2",IIF(cAliasPTU == "BE4","BEJ","BQV"))},;
					{ "B6L_UNIORI", StrZero(Val(cUniOri),4)},;
					{ "B6L_CODRDA", cRdaPacote},;
					{ "B6L_CODPAC", cCdPacote},;
					{ "B6L_COMUNI", "0"},;
					{ "B6L_NRTROL", cNrTrolPTU},;
					{ "B6L_DTATEN", dDatabase}})

				If lB6L_QTDPAC
					aAdd(aItensB6L[Len(aItensB6L)], {"B6L_QTDPAC", Val(cQtdPacote)})
				EndIf
			EndIf
			// Br8
			BR8->(dbSetOrder(1))
			if BR8->( msSeek(xFilial("BR8")+cCodPad+cCodPro) )

				PLSPUTDAD(aItens[nfor],"DATINC",BR8->BR8_DATINC,.t.)
				PLSPUTDAD(aItens[nfor],"NIVEL",BR8->BR8_NIVEL,.t.)

				if !empty(PLSRETDAD(aItens[nfor],"DESCOPME")) // Retorno de alteração PTU
					PLSPUTDAD(aItens[nfor],"DESCRI",(PLSRETDAD(aItens[nfor],"DESCOPME")),.t.)
				else
					PLSPUTDAD(aItens[nfor],"DESCRI",BR8->BR8_DESCRI,.t.)
				endIf

				PLSPUTDAD(aItens[nfor],"TPPROC",BR8->BR8_TPPROC,.t.)
				PLSPUTDAD(aItens[nfor],"TIPEVE",BR8->BR8_TIPEVE,.t.)

				if BR8->BR8_TPPROC = "4"
					lPProcDiaria := .t.
				endIf

				If lPTUOn80
					PLSPUTDAD(aItens[nfor],"TPTAB",PtTpTabTus(,,.T.),.t.)
					PLSPUTDAD(aItens[nfor],"TPTABREF",PtTpTabTus(,,.T.,.T.),.t.)
				EndIf
			else
				//o sistema somente vai entar aqui quando for TISSONLINE de um codigo que nao
				//existe na tabela padrao vou pegar o codigo de procedimento generico
				PLSPUTDAD(aItens[nfor],"DESCRI","PROCEDIMENTO INEXISTENTE",.t.)

				BR8->(dbSetOrder(3))
				if BR8->( msSeek(xFilial("BR8")+allTrim(getNewPar("MV_PLPSPXM","99999994"))) )
					PLSPUTDAD(aItens[nfor],"DATINC",dDataBase,.t.)
					PLSPUTDAD(aItens[nfor],"NIVEL",BR8->BR8_NIVEL,.t.)
					PLSPUTDAD(aItens[nfor],"TPPROC",BR8->BR8_TPPROC,.t.)
					PLSPUTDAD(aItens[nfor],"TIPEVE",BR8->BR8_TIPEVE,.t.)
				endIf

			endIf

			// Verifica se a tabela informada esta no parametro
			if cCodPad $ getNewPar("MV_PLSTRCO","ZZ")

				cCodPro := PLSRETDAD(aItens[nfor],"CODPRO")
				cDente  := PLSRETDAD(aItens[nfor],"DENTE","")
				cFace   := PLSRETDAD(aItens[nfor],"FACE","")

				// Troca as informacoes
				BR8->( dbSetOrder(5) ) //BR8_FILIAL + BR8_CODEDI
				if BR8->( msSeek(xFilial("BR8")+cCodPro) )
					aadd(aMatTroca,{cSeqMov,cCodPad,cCodPro,BR8->BR8_CODPSA,cDente,cFace} )
					PLSPUTDAD(aItens[nfor],"CODPRO",BR8->BR8_CODPSA)
				endIf

			endIf

		next

		// Monta os dados solicitados em uma matriz que nao sera alterada.
		// O objetivo e ter em uma unica matriz os procedimentos e suas respectivas
		// quantidades solicitadas e a partir disso trabalhar autorizacoes parciais
		// a partir de uma liberacao original.
		if lContinua .and. ! lResInt

			for nfor := 1 To len(aItens)

				cSeqMov := PLSRETDAD(aItens[nfor],"SEQMOV")
				cCodPad := PLSRETDAD(aItens[nfor],"CODPAD")
				cCodPro := PLSRETDAD(aItens[nfor],"CODPRO")
				cDescri	:= PLSRETDAD(aItens[nfor],"DESCRI","")
				nQtdSol := PLSRETDAD(aItens[nfor],"QTD",0)
				nQtdAut := PLSRETDAD(aItens[nfor],"QTDAUT",0)
				cTpProc	:= PLSRETDAD(aItens[nfor],"TPPROC","")
				cDente  := PLSRETDAD(aItens[nfor],"DENTE","")
				cFace   := PLSRETDAD(aItens[nfor],"FACE","")
				cStProc := PLSRETDAD(aItens[nfor],"STPROC","")

				// Itens
				aadd( aAutItens,{cSeqMov,;	//[1]  cSeqMov  -> Sequencia do evento
					cCodPad,;	//[2]  cCodPad  -> Tipo Codigo Procedimento
					cCodPro,;	//[3]  cCodPro  -> Codigo do Procedimento
					nQtdSol,;	//[4]  nQtdSol  -> Quantidade do Procedimento
					0,;			//[5]  zero     -> Sera a diferenca entre qual quantidade tinha sido liberada (saldo) - a quantidade que foi solicitada na autorizacao corrente
					.t.,;		//[6]  Status(L)-> Valor logico se este item sera retirado da liberacao original ou nao
					0,;			//[7]  recno    -> recno do registro BE2 relacionado a liberacao original
					.f.,;		//[8]  lColsDel -> Indica se um item do aCols que foi solicitado nao podera ser autorizado ou nao
					nQtdAut,;	//[9]  nQtdAut	-> Quantidade Autorizada
					.f.,;		//[10] XXX 		-> Indica se um item ja foi executado anteriormente
					.f.,;		//[11] XXX 		-> Indica se um item existe na liberacao
					.f.,;		//[12] XXX 		-> Indica se o item pode ser executado pelo executante
					cTpProc,;	//[13] cTpProc	-> Tipo do procedimento
					cDescri,;  	//[14] cDescri	-> Descricao do procedimento
					cDente,;   	//[15] cDente	-> Dente
					cFace,;		//[16] cFace	-> Face
					cStProc} )	//[17] cStatus	-> Status

				if ! lHonor .and. ! lResInt .and. ! empty(cTpProc) .and. ( allTrim(cTpProc) $ allTrim( getNewPar("MV_PLSOPMM","0,1,2,3,4,5,6,7,8,9")))
					aadd( aMatOPMM,{cSeqMov,cCodPad,cCodPro,nQtdSol,0,.t.,0,.t.,nQtdAut} )
					lOPMM := .t.
				endIf

			next

		endIf

		// Tratamento para o usuario
		if ! lResInt

			if lContinua

				aRetFun := PLSUSUATE(@cMatric,clocalExec,cHora,cViaCartao,cTipoMat,cNomUsrCar,cTipoGrv,aItens,;
					aCriticas,aEventosNeg,aMatInf,dDatPro,dDatNasUsr,lResInt,lHonor,lIncAutIE,.f.,;
					nil,cOpeOri,(lPtuOnline .Or. lTsOnPr),cTokEdi)

				If len(aCriticas) > 0 .And. lPtuOnline
					For nFor := 1 To Len(aCriticas)
						cBCTPropri := BCT->BCT_PROPRI
						BCT->(DbSetOrder(1))
						If BCT->(MsSeek(cFilBCT+PlsIntPad()+cBCTPropri+Right(aCriticas[nFor][2], 2))) .And. !Empty(aCriticas[nFor][2])
							cAuditoria := BCT->BCT_AUDITO
							If cAuditoria == "1"
								Exit
							EndIf
						EndIf
					Next
				endIf

				lContinua := aRetFun[1]
				lMatGer   := aRetFun[2]
				lUsuGer   := aRetFun[3]
				cMatUsa   := aRetFun[4]
				cOpeOri	  := aRetFun[5]
				cRetGui	  := aRetFun[6]
				cSomInt	  := aRetFun[7]
				aDadUsr	  := aRetFun[8]
				lCriMatInv:= aRetFun[9]

				if lCriMatInv .and. lPtuOnline
					PlsPtuPut("MSG01","Matricula informada: "+PLSRETDAD( aDados,"CD_UNI","" )+PLSRETDAD( aDados,"ID_BENEF","" ),aDados)
				endIf

				// Tratamento para rede de atendimento contratado e o profissional
				if lContinua
					// Quando for uma prorrogação de Internação, pego a data e hora da internação para posteriormente verificar a RDA
					If cTGOriginal == "11"
						aAreaBE4 := BE4->(GetArea()) // Caso tenha alguma BE4 posicionada

						BE4->(DbSetORder(2))//BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
						If BE4->(msSeek(xFilial("BE4")+cNumLib)) // Numero da Solic. Internação
							aProrInt	:= {BE4->BE4_DATPRO, Substr(BE4->BE4_HORPRO,1,4)}
						EndIF

						RestArea(aAreaBE4)
					EndIf

					aRetFun := PLSREDATE(cOpeMov,cCodRda,cCodRdaPro,@cCodLoc,@cCodLocPro,@cCodEsp,@cCodEspPro,dDatPro,;
						aItens,aDadIte,aCriticas,aEventosNeg,aDadUsr,cLibEsp,cAuditoria,cOrigem,;
						cNumImp,IIF(lPtuOnline .or. lTsOnPr,.T.,lLoadRda),lRdaProf,lIncNeg,cTipGui,cGuiPri,;
						lPtuOnline,cCarSol,lFAudMOP,lFAudAte,lforcAud,lAutoCus,lPacAudi,cNumLib,aProrInt)

					If lTsOnPr
						If ExistBlock("PLSPRCAB")
							aRetPrt := ExecBlock("PLSPRCAB",.F.,.F.,{aRetFun})
							aRetFun := aRetPrt
						Endif
					EndIf

					lContinua 	:= aRetFun[1]
					cLocal  	:= aRetFun[2]
					cDesLoc  	:= aRetFun[3]
					cDesLocPro 	:= aRetFun[4]
					nRecBAU	    := aRetFun[5]
					aDadRda 	:= aRetFun[6]
					aRdaProf  	:= aRetFun[7]
					lTrtExe		:= aRetFun[8]
					lTrtCCl		:= iIf( lSolicit,.f.,iIf(len(aDadRDA)>0,iIf(aDadRDA[23]!='1',.f.,.t.),.f.) )
				endIf

			endIf

			// Identifica o primeiro item passado no aItens
			if lContinua

				if len(aItens) > 0

					cSeqMov   := PLSRETDAD(aItens[1],"SEQMOV")
					cCodPad   := PLSRETDAD(aItens[1],"CODPAD")
					cCodPro   := PLSRETDAD(aItens[1],"CODPRO")
					nQtdSol   := PLSRETDAD(aItens[1],"QTD",0)
					nQtdAut   := PLSRETDAD(aItens[1],"QTDAUT",0)
					cDente    := PLSRETDAD(aItens[1],"DENTE","")
					cFace     := PLSRETDAD(aItens[1],"FACE","")
					cStProc   := PLSRETDAD(aItens[1],"STPROC","")

					lConsulta := PLSISCON(cCodPad,cCodPro) .and. len(aItens) == 1

					if empty(cTipGui)
						cTipGui   := if(!lConsulta, IIF(!empTy(cDente) .OR. !empTy(cFace), G_ODONTO, getNewPar("MV_PLSTPGS","02") ),getNewPar("MV_PLSTPGC","01"))
					endIf

				else
					lContinua := .f.
				endIf

			elseIf lPtuOnline .and. len(aItens) == 1
				lConsulta := PLSISCON(PLSRETDAD(aItens[1],"CODPAD"),PLSRETDAD(aItens[1],"CODPRO"))
			endIf

			if lPtuOnline .and. empty(cTipGui)
				cTipGui  := iIf( !lConsulta, getNewPar("MV_PLSTPGS","02"), getNewPar("MV_PLSTPGC","01") )
			endIf

			// 1=Autorizacao SADT;2=Liberacao;4=Autorizacao Odontologica
			if lContinua .and. cOrigem <> "2" .and. ! empty(cNumLib) .and. len(aDadUsr) > 0 .and. ! lEvolu .and. ! lInter

				// Verficia se exite procedimento de liberacao
				aRetLib := PLSRETAULI(cMatric,cNumLib,iIf(cTipo=='2' .and. lWeb,'A','L'),cCodRdaPro,cCodLocPro,cCodEspPro,cCodPRFExe,clocalExec,lWeb,aRdaProf,aDadUsr,cTipo,cEspSol,cEspExe)

				//se o parametro estiver igual a '0' significa que eu trato na execução de uma liberação somente se o profissional
				//executante complementar(se ele for uma rda) pode ou nao executar um procedimento.
				//se o parametro estiver igual a '1' significa que eu trato na execução de uma liberação alem do profissional executante tambem se
				//o contratado executante pode ou nao executar um procedimento
				aSlvRtLb := aClone(aRetLib)

				if getNewPar('MV_PLTREXC','0') == '1' .and. !aRetLib[1]

					aRetLib := PLSRETAULI(cMatric,cNumLib,'L',cCodRda,cCodLoc,cCodEsp,cCodPRFExe,clocalExec,lWeb,aDadRda,aDadUsr,cTipo,cEspSol,cEspExe)
					if !aRetLib[1]
						aRetLib := aClone(aSlvRtLb)
					endIf

				endIf

				BAU->( dbGoto(nRecBAU) )

				// Retorna o conteudo original da rda contratada para a aDadRDA statica
				PLSCLORDA(aDadRda)

				if aRetLib[1]

					// Ajusta os niveis na matriz item
					for nfor := 1 To len(aItens)

						cSeqMov := PLSRETDAD(aItens[nfor],"SEQMOV")
						cCodPad := PLSRETDAD(aItens[nfor],"CODPAD")
						cCodPro := PLSRETDAD(aItens[nfor],"CODPRO")
						cDente  := PLSRETDAD(aItens[nfor],"DENTE","")
						cFace   := PLSRETDAD(aItens[nfor],"FACE","")

						if ( nPos := aScan( aRetLib[4],{|x| x[2]+x[3]+x[4]+x[24]+x[25] == cSeqMov+cCodPad+cCodPro+cDente+cFace } ) ) > 0
							PLSPUTDAD(aItens[nfor],"NIVAUT",aRetLib[4,nPos,15],.t.)
							PLSPUTDAD(aItens[nfor],"NIVCRI",aRetLib[4,nPos,16],.t.)
							PLSPUTDAD(aItens[nfor],"CHVNIV",aRetLib[4,nPos,17],.t.)
						endIf
					next

					// Se for liberacao
					for nfor := 1 To len(aAutItens)
						cSeqMov   := aAutItens[nfor,1]
						cCodPad   := aAutItens[nfor,2]
						cCodPro   := aAutItens[nfor,3]
						nQtdSol   := aAutItens[nfor,4]
						nQtdAut   := aAutItens[nfor,9]
						cDente    := aAutItens[nfor,15]
						cFace     := aAutItens[nfor,16]
						cStProc   := aAutItens[nfor,17]
						// Verifica se o procedimento foi encontrado e se e permitido para o executante
						// So e possivel a verificacao da sequancia quando o array de itens nao foi
						// alterado no portal.
						// Caso seja necessario a verificacao da sequencia qdo o procedimento e excluido
						// sera necessario alteracao no java script que faz a exclusao no portal.
						if len(aRetLib[4]) ==  len(aAutItens) .and. len(aAutItens) != 1
							nPos := aScan( aRetLib[4],{|x| x[2]+x[3]+x[4]+x[24]+x[25] == cSeqMov+cCodPad+cCodPro+cDente+cFace } )
						else
							nPos := aScan( aRetLib[4],{|x| x[3]+x[4]+x[24]+x[25] == cCodPad+cCodPro+cDente+cFace } )
						endIf

						if nPos > 0 .and. aRetLib[4,nPos,10] == "1"

							// Se for um procedimento de solicitacao de internacao
							if aRetLib[4,nPos,13] > 0 .and. empty(aRetLib[4,nPos,11])

								aadd(aItensLOri,{cSeqMov,cCodPad,cCodPro,0,cDente,cFace})

								// Comun a todos os casos
								nLastPos			:= len(aItensLOri)

								aAutItens[nfor,7] 	:= aRetLib[4,nPos,12] //recno
								aAutItens[nfor,8]	:= .t.	//Se a quantidade for maior que a solicitada
								lAprovLib         	:= .t.
								nRecBEALIB        	:= aRetLib[7]
								cGuiaOri          	:= aRetLib[8]

								// Verificando o saldo
								if nQtdSol > aRetLib[4,nPos,13]
									aAutItens[nfor,5] := 0
									aAutItens[nfor,6] := .f. 		//Item nao sera excluido da liberacao original

									if aRetLib[4,nPos,13] == 0
										aAutItens[nfor,10] := .t. 	//Para controlar se o item ja foi executado anteriormente
									endIf
								else
									// Quantidade e a mesma
									if nQtdSol == aRetLib[4,nPos,13]
										aAutItens[nfor,5] := 0 		//nao existe mais saldo na liberacao original
										aAutItens[nfor,6] := .t. 	//Item sera retirado da liberacao original

										aItensLOri[nLastPos,4] 	:= 0
									else
										aAutItens[nfor,5] 		:= aRetLib[4,nPos,13] - nQtdSol 	//Saldo que ficou na liberacao original
										aAutItens[nfor,6] 		:= .f. 									//Item nao sera excluido da liberacao original

										aItensLOri[nLastPos,4] 	:= aRetLib[4,nPos,13] - nQtdSol 	//Saldo que ficou na liberacao original
									endIf
								endIf
							else
								lAprovLib			:= .t.
								aAutItens[nfor,10]	:= .t. 	//Para controlar se o item ja foi executado anteriormente
								nRecBEALIB          := aRetLib[7]
								cGuiaOri            := aRetLib[8]
							endIf
						else
							lAprovLib 	:= .t.
							nRecBEALIB	:= aRetLib[7]
							cGuiaOri  	:= aRetLib[8]

							if nPos <> 0 .and. len(aRetLib[4,nPos,14]) >= 2

								for nI := 1 To len(aRetLib[4,nPos,14,2])
									if !empty(aRetLib[4,nPos,14,2,nI,1])
										aadd(aRetExe,{aRetLib[4,nPos,14,2,nI,1],aRetLib[4,nPos,14,2,nI,2]+iIf(len(aRetLib[4,nPos,14,2,nI])>=3 .and. !empty(aRetLib[4,nPos,14,2,nI,3]),' ( '+aRetLib[4,nPos,14,2,nI,3]+' ) ',''),aRetLib[4,nPos,14,2,nI,6],aRetLib[4,nPos,14,2,nI,7] } )
									endIf
								next
								aAutItens[nfor,12]	:= .t. 	//Se o item pode ser executado pelo executante
							else
								aAutItens[nfor,11]	:= .t. 	//Para controlar se o item existe na liberacao
							endIf
						endIf
					next

				elseIf len(aRetLib[5])>0
					PLSMONCRI(aItens,aRetLib[5],.t.,,,,aCriticas,aEventosNeg)
				endIf
			endIf

		endIf
		// Monta calendario de pagamento
		if lContinua
			aRetAux 	:= PLSXVLDCAL(dDatPro,cOpeMov,.f.,cCodPad,cCodPro)
			cAno 		:= aRetAux[4]
			cMes 		:= aRetAux[5]
			lContinua  	:= aRetAux[1]
			aTrb 	   	:= aRetAux[2]
			if ! lContinua
				PLSMONCRI(aItens,aTrb,.t.,,,,aCriticas,aEventosNeg)
			endIf
		endIf
		// Preenche o PADINT para solicitacao de internacao XML
		if lSolicit .and. lInter .and. (lImpXml .or. lImpTxt) .and. len(aDadUsr) > 10 // Trata aDadUsr por criticas ou por variavel em branco

			BI3->(dbSetOrder(1))//BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO
			if BI3->(msSeek(xFilial("BI3")+PlsIntPad()+aDadUsr[11]+aDadUsr[12]))
				cPadInt := BI3->BI3_CODACO
			endIf

		endIf

		lContinua := ( len(aEventosNeg) <> len(aItens) )

		//Roberto-Valida Itens para verificar se Vai criticar ou não (Diária)
		if (lContinua .and. cTipGui = '11' .or. cTipGui = '03') .and. len(aItens) > 0
			aRetFun := PLSDIAQTD(aItens,aCriticas,aEventosNeg, cOrigem, cLibEsp, cNumImp, dDatPro, aDadRda, aDadIte, nQtdDiSol)
		endIf

		if lContinua .and. lHonor

			lContinua  := .f.
			lReanaliza := .f.
			lFindRes   := .t.

			// Alimenta a matriz para gravacao da guia de honorario
			if lHonor
				// Monta dados do executante no honorario pego somente o primeiro pq a informacao vem no cab
				for nfor2 := 1 To len(aItens)

					PLSDADITE(aDadIte,aItens[nfor2],cOrigem,cLibEsp,cAuditoria,cNumImp,,dDatPro)

					if len(aTpPIte) == 0
						aTpPIte	:= PLSRETDAD(aItens[nfor2],"ATPPAR",{})
					else
						aTpSlvte       := PLSRETDAD(aItens[nfor2],"ATPPAR",{})
						if len(aTpSlvte[1])> 0
							aadd(aTpPIte, aTpSlvte[1])
						endIf
					endIf

				next
			endIf
		endIf
		// Preenche o PADINT para solicitacao de internacao
		if lSolicit .and. lInter .and. len(aDadUsr) > 10 // Trata aDadUsr por criticas ou por variavel em branco
			BI4->(dbSetOrder(1))//BI4_FILIAL + BI4_CODACO
			If BI4->(msSeek(xFilial("BI4")+cPadInt))
				cPadInt := BI4->BI4_CODACO
			Else
				BI3->(dbSetOrder(1))//BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO
				if BI3->(msSeek(xFilial("BI3")+PlsIntPad()+aDadUsr[11]+aDadUsr[12]))
					cPadInt := BI3->BI3_CODACO
				endIf
			EndIf
		endIf
		// Tratamento do resumo de internacao
		if lContinua .and. lResInt

			lContinua  := .f.
			lReanaliza := .f.
			lFindRes   := .t.

			Begin Transaction

				PLSGRVHORE( cNumPeg,clocalExec,cTipoGrv,dDatPro,cHora,aItens,aUnMed,'2',;
					cOpeMov,cMatric,cCDPFSO,cCodPRFExe,cNumImp,cTipPre,cCodRda,cCodLDP,;
					cTipo,cCodLoc,cCodEsp,'03',cCidPri,nQtNasV,nQtNasM,nQtNasP,nQtObtP,nQtObAR,cTipFat,;
					cCidObt,cNrdCob,cObtMul,cTipAlt,cNrdCnv,cLotGui,cArqImp,'',cNumLib,aTipPart)

				BE4->( RecLock("BE4",.f.) )
				if empty(BE4->BE4_PADCON)
					BE4->BE4_PADCON := cPadCon
				endIf
				BE4->BE4_DATPRO := dDatPro
				BE4->BE4_HORPRO := cHora
				if len(aCriticas) == 0
					BE4->BE4_DTALTA := dDtAlta
					BE4->BE4_HRALTA := cHrAlta
					BE4->BE4_TIPFAT := cTipFat
				endIf

				BE4->BE4_DTINif := dDtIniFat
				BE4->BE4_HRINif := cHrIniFat
				BE4->BE4_DTFIMF := dDtFimFat
				BE4->BE4_HRFIMF := cHrFimFat
				BE4->BE4_EMGEST := PLSRETDAD( aDados,"EMGEST","0" )
				BE4->BE4_ABORTO := PLSRETDAD( aDados,"ABORTO","0" )
				BE4->BE4_TRAGRA := PLSRETDAD( aDados,"TRAGRA","0" )
				BE4->BE4_COMURP := PLSRETDAD( aDados,"COMURP","0" )
				BE4->BE4_ATESPA := PLSRETDAD( aDados,"ATESPA","0" )
				BE4->BE4_COMNAL := PLSRETDAD( aDados,"COMNAL","0" )
				BE4->BE4_BAIPES := PLSRETDAD( aDados,"BAIPES","0" )
				BE4->BE4_PARCES := PLSRETDAD( aDados,"PAAREO","0" )
				BE4->BE4_PATNOR := PLSRETDAD( aDados,"PATNOR","0" )
				BE4->BE4_ARQIMP := cArqImp
				BE4->BE4_LOTGUI := cLotGui
				BE4->BE4_NRDCNV := cNrdCnv
				BE4->BE4_NASVIV := nQtNasV
				BE4->BE4_NASMOR := nQtNasM
				BE4->BE4_NASVPR := nQtNasP
				BE4->BE4_OBTMUL := cObtMul
				BE4->BE4_TIPALT := cTipAlt
				BE4->( msUnLock() )

			End Transaction
		endIf

		// Inclui procedimentos que nao estao na liberacao original conforme parametro MV_PLSOPMM
		if lContinua .and. lOPMM .and. ! lSolicit .and. ! lHonor .and. ! lResInt

			for nfor := 1 To len(aMatOPMM)

				if aScan( aItensLOri,{|x| x[1] == aMatOPMM[nfor,1] } ) == 0

					nPos := aScan( aAutItens,{|x| x[1] == aMatOPMM[nfor,1] } )

					if nPos > 0
						aAutItens[nPos,5] 	:= 0
						aAutItens[nPos,6] 	:= .f.
						aAutItens[nPos,8] 	:= .t.
						aAutItens[nPos,10] 	:= .f.
						aAutItens[nPos,11] 	:= .f.
						aAutItens[nPos,12] 	:= .f.
					endIf

				endIf

			next

		endIf

		// Caso seja Autorizacao a partir de liberacao verifica se sera total ou parcial
		if lContinua .and. lAprovLib
			cTpLibToAut := ""

			BEA->( dbGoto(nRecBEALIB) )

			dDataSol := BEA->BEA_DATSOL
			cHoraSol := BEA->BEA_HORSOL
			cCidPri  := BEA->BEA_CID
			cCDPFSO  := BEA->BEA_CDPFSO
			cOpeSol  := BEA->BEA_OPESOL

			// Busca dados da liberacao PTU Online
			if subStr(PLSRETDAD( aDados,"USUARIO","" ),5,4) == getNewPar("MV_PLSGEIN","0050") .and. ;
					PLSRETDAD( aDados,"TP_CLIENTE","" ) == 'WEB' .and.  !empty(PLSRETDAD( aDados,"NUMLIB","" ))

				cSenhaOpe := BEA->BEA_NRAOPE
				cNrSeqTR  := BEA->BEA_NRTROL

			endIf

			// Se gera log caixa preta
			if lWLIO
				PlsLogFil(space(3)+"",__PLSFLOGX)
				PlsLogFil(space(3)+"CONTEUDO ALTERADO PELA SOLICITACAO ORIGINAL",__PLSFLOGX)
				PlsLogFil(space(3)+"",__PLSFLOGX)
				PlsLogFil(space(3)+"DATA SOLICITACAO [" + DToC(dDataSol) + "]",__PLSFLOGX)
				PlsLogFil(space(3)+"HORA SOLICITACAO [" + cHoraSol + "]",__PLSFLOGX)
				PlsLogFil(space(3)+"PROF. SOLICIANTE [" + cCDPFSO + "]",__PLSFLOGX)
				PlsLogFil(space(3)+"OPE. SOLICITANTE [" + cOpeSol + "]",__PLSFLOGX)
				PlsLogFil(space(3)+"CID              [" + cCidPri + "]",__PLSFLOGX)
				PlsLogFil("",__PLSFLOGX)
			endIf

			// Caso existe no be2 e nao existe na matriz e o salvo for maior que zero e parcial
			if BE2->(msSeek(xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))
				while ! BE2->(eof()) .and. BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == ;
						xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)

					if aScan(aItensLOri,{|x| allTrim(x[1]+x[2]+x[3]+x[5]+x[6]) == BE2->(BE2_SEQUEN+BE2_CODPAD)+allTrim( BE2->BE2_CODPRO )+allTrim( BE2->BE2_DENREG )+allTrim( BE2->BE2_FADENT ) } ) == 0 .and. BE2->BE2_SALDO > 0
						cTpLibToAut := "P"       //se tem algum item da pre-autorizacao(liberacao) que nao foi analisado e parcial
						Exit
					endIf

					BE2->(dbSkip())
				endDo
			endIf
			// Verifico se existe algum item para ser executado em outro momento
			if empty(cTpLibToAut)
				for nfor := 1 To len(aAutItens)
					if !aAutItens[nfor,6]   		//pelo menos um NAO vai autorizar
						cTpLibToAut := "P"       	//Parcial
						Exit
					elseIf aAutItens[nfor,6]     	//autorizou
						if aAutItens[nfor,5] > 0 	//pelo menos um ainda tem saldo portando e parcial
							cTpLibToAut := "P"
							Exit
						else                      	//por enquanto todos autorizam e nao tem mais saldo
							cTpLibToAut := "T"
						endIf
					endIf
				next
			endIf
		endIf

		// Continua
		if lContinua .or. (lPtuOnline .and. !lCriMatInv)

			if len(aDadUsr) == 0 .and. (lPtuOnline .and. !lContinua)

				aRetFun := PLSUSUATE(@cMatric,clocalExec,cHora,cViaCartao,cTipoMat,cNomUsrCar,cTipoGrv,aItens,;
					aCriticas,aEventosNeg,aMatInf,dDatPro,dDatNasUsr,lResInt,lHonor,lIncAutIE,lImpXml,;
					.t.,cOpeOri,(lPtuOnline .Or. lTsOnPr),cTokEdi)
				aDadUsr	  := aRetFun[8]

				// Trecho para assegurar que guia será gravada com críticas de usuário
				If !lContinua .And. lTsOnPr .And. Len(aDadIte) == 0
					for nfor := 1 To len(aItens)
						PLSDADITE(aDadIte,aItens[nfor],cOrigem,cLibEsp,cAuditoria,cNumImp,,dDatPro,aDadRda)
					next
				EndIf

			endIf

			cRegAte := iIf(len(aDadUsr) >= 92, aDadUsr[92], "")

		endIf

		// Valida cada evento se tem direito
		if (lContinua .or. lPtuOnline .or. lTsOnPr)

			// Se Ptu Online e houveram criticas, carrega variaveis para criar a guia

			// 03.08.2018 - Alterado para que solicitacoes Tiss Online tambem gerem guia
			// mesmo com criticas de cabecalho. Ajuste necessario pois segundo a RN 395,
			// todo atendimento deve gerar o protocolo de negativas com os motivos das criticas
			if (lPtuOnline .or. lTsOnPr) .and. !lContinua

				//So chamo o PLSUSUATE novamente se o aDadUsr estiver vazio
				If len(aDadUsr) == 0
					aRetFun := PLSUSUATE(@cMatric,clocalExec,cHora,cViaCartao,cTipoMat,cNomUsrCar,cTipoGrv,aItens,;
						aCriticas,aEventosNeg,aMatInf,dDatPro,dDatNasUsr,lResInt,lHonor,lIncAutIE,lImpXml,;
						.t.,cOpeOri,(lPtuOnline .Or. lTsOnPr),cTokEdi)

					lMatGer   := aRetFun[2]
					lUsuGer   := aRetFun[3]
					cMatUsa   := aRetFun[4]
					cOpeOri	  := aRetFun[5]
					cRetGui	  := aRetFun[6]
					cSomInt	  := aRetFun[7]
					aDadUsr	  := aRetFun[8]

					// Trecho para assegurar que guia será gravada com críticas de usuário
					If !lContinua .And. lTsOnPr .And. Len(aDadIte) == 0
						for nfor := 1 To len(aItens)
							PLSDADITE(aDadIte,aItens[nfor],cOrigem,cLibEsp,cAuditoria,cNumImp,,dDatPro,aDadRda)
						next
					EndIf
				EndIf

				//Sou vou chamar de novo se o aDadRda estiver vazio (teoricamente vira sempre preenchido pois
				//estou passando o lLoadRda como .T. na sua primeira chamada)
				If len(aDadRda) == 0
					aRetFun := PLSREDATE(cOpeMov,cCodRda,cCodRdaPro,@cCodLoc,@cCodLocPro,@cCodEsp,@cCodEspPro,dDatPro,;
						aItens,aDadIte,aCriticas,aEventosNeg,aDadUsr,cLibEsp,cAuditoria,cOrigem,;
						cNumImp,.T.,lRdaProf,lIncNeg,;
						nil,nil,lPtuOnline,nil,nil,nil,nil,nil,nil,cNumLib,aProrInt)

					clocal  	:= aRetFun[2]
					cDesLoc  	:= aRetFun[3]
					cDesLocPro 	:= aRetFun[4]
					nRecBAU	    := aRetFun[5]
					aDadRda 	:= aRetFun[6]
					aRdaProf  	:= aRetFun[7]
					lTrtExe		:= aRetFun[8]
				endIf

				aRetAux := PLSXVLDCAL(dDatPro,cOpeMov,.f.,cCodPad,cCodPro)
				cAno	:= aRetAux[4]
				cMes    := aRetAux[5]
				aTrb   	:= aRetAux[2]

			endIf
			// Monta o Cabecalho
			Store Header "BE2" TO aHeader for .t.

			if cTipo=="4"
				B04->(dbSetOrder(1))
				Store Header "BYS" TO aCabDF for .t.
			endIf
			// Se e liberacao e vai virar autorizacao
			if lAprovLib
				// Posiciona na liberacao
				BEA->( dbGoto(nRecBEALIB) )
				// Atualiza a liberacao
				aVetTrab := {}
				aCols    := {}
				PLSA090MDA(BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT),"",aHeader,aVetTrab,aCols)
				// Grava os valores para fazer a exclusao da liberacao
				aHeaderLib  := aClone(aHeader)
				aVetTrabLib := aClone(aVetTrab)
				aColsLib	:= aClone(aCols)
				aCols    	:= {}
				aVetTrab 	:= {}
			endIf

			// Monta o aCols baseado no aHeader
			// REGRA DE UM USUARIO NORMAL
			if ( !lUnimeds ) .or. ( (lUnimeds .and. cOpeOri == PLSINTPAD()) .or. lCriMatInv )

				// Checar a regra do procedimento
				PLSXMOVREG(	aItens,lAprovLib,lTrtUsr,lRegras,lConsulta,cOrigem,cAno,cMes,dDatPro,cHora,aDadUsr,aDadRDA,cCidPri,;
					clocalExec,cOpeSol,cCDPFSO,cPadInt,cPadCon,cRegAte,cCodPRFExe,cOpeExe,lRegPagAto,cTipoGrv,cAreaAbr,;
					cCodEsp,cCodLoc,cFilBCT,cTipoGrv,cLibEsp,cNumImp,cOpeMov,@nQtdDiAut,;
					aDadIte,aCriticas,aEventosNeg,aEventosAut,lAudEmp,lFAudMOP,lFAudAte,lforcAud,lAutoCus,aRdaProf,;
					cCodEspPro,cCodLocPro,lTrtExe,aDadBea,@lAto,lWeb,lInter,lSolicit,.f.,lPacAudi,lPtuOnline,cRdaEDI,lPtuA1100,nil,cTipGui,;
					cEspSol,cEspExe,cNumLib,cCarSol,@cSenBSN,cNuLibera, lNovaLib, cAteRN,/*lTissOn*/,@aBQVPTUDif,cRegInt,cCaraterSol,;
					cTGOriginal,@lAllAutori,aProrInt, lUrgPTUInter)

				// Usuario nao e da minha operadora (web,pos e xml)
			else
				// Abrir tabelas
				aArea := GetArea()
				for nI := 1 To len(aMatAlias)
					if Select(aMatAlias[nI]) == 0
						DbSelectArea(aMatAlias[nI])
					endIf
				next
				RestArea(aArea)

				// Checa se a operadora esta online
				lOnLine  := BA0->(Posicione("BA0",1,xFilial("BA0")+cOpeOri,"BA0_ONLINE")) == "1"
				lOnTLine := lOnLine

				// Se importacao XML, nao realiza comunicacao
				if lImpXml
					lOnLine  := .f.
					lOnTLine := .f.
				endIf
				// Regra para usuario de outra operadora
				if cOpeOri <> PLSINTPAD()

					// Indica solicitacao PTU Online
					lPTUOnSol := .t.
					// forco a minha operadora como Origem se OPESOL vazio
					if empty(cOpeSol)
						cOpeSol := PlsIntPad()
					endIf

					// Antes de realizar a comunicacao, verifico periodicidade interna de
					// consulta
					if len(aItens) == 1 .and. lOnline .and. lConsulta .and. allTrim(PLSRETDAD(aItens[1],"CODPRO")) $ getNewPar("MV_PTCELET","10101012")
						lOkVerPTU := VPerConPTU(aDados,aItens,aDadRDA,aDadUsr,aDadIte,aCriticas,aEventosNeg)
					endIf

					// Verifica se e PTU Online pelo Portal com Matricula sem 17 caracteres
					if lOnline .and. len(allTrim(aDadUsr[3])) <> 17 .and. PLSPOSGLO(PLSINTPAD(),__aCdCri210[1],__aCdCri210[2],clocalExec,"1","2",,.t.)
						lOkVerPTU := criMatPT17(aDados,aItens,aDadRDA,aDadUsr,aDadIte,aCriticas,aEventosNeg,clocalExec)
					endIf

					// Ordem de Servico PTU Online 5.0
					if lPTUOnOS

						cOpeSol	 := cOpeSolOS

						aadd(aDadBEA,{"BEA_NRTROS",cTranOS})

						if lInter
							aadd(aDadBE4,{"BE4_NRTROS",cTranOS})
						endIf

						// Parametro de comunicacao automatica da guia 00600 ativado
						// IMPORTANTE - Desabilitado temporariamente, necessario rever esta
						// transacao no futuro

						lOnLine := .f.
						aadd(aDadBEA,{"BEA_TRACON","0"})

						lVeioComu := .f.
						PlsPtuLog("**********************************")
						PlsPtuLog("Gerando Guia referente a OS '"+cTranOS+"' para posterior solicitação manual.")
						PlsPtuLog("***********************************")

						if PLSALIASEX("BSN")

							lExitTran := .f.
							cNrSeqTR  := strZero( val( BSN->(getSx8Num("BSN","BSN_SEQUEN") ) ),10)
							BSN->(confirmSX8())

							SIX->(dbSetOrder(1))
							if SIX->( msSeek("BEAM") )
								BEA->(dbSetOrder(22))//BEA_FILIAL + BEA_NRTROL
								if BEA->(msSeek(xFilial("BEA")+cNrSeqTR+space( TamSX3("B0S_NUMSEQ")[1]-len(cNrSeqTR))+PlsIntPad()))

									while !lExitTran
										cNrSeqTR := strZero(val(cNrSeqTR)+1,10)

										if !BEA->(msSeek(xFilial("BEA")+cNrSeqTR))
											lExitTran := .t.
										endIf
									endDo

								endIf
							endIf

							BSN->(RecLock("BSN",.t.))
							BSN->BSN_FILIAL := xFilial("BSN")
							BSN->BSN_SEQUEN := cNrSeqTR
							BSN->(msUnLock())

						endIf

					endIf

					// Verifica se ha procedimentos liberados, caso nao exista, nao comunica
					if lOkVerPTU .and. lOnLine

						for nfor :=1 to len(aItens)
							nIteLibPTU += PLSRETDAD(aItens[nfor],"QTD",0)
						next

						if nIteLibPTU == 0
							lOkVerPTU   := .f.
							lCriAutPTU  := .t.
						endIf

					endIf

					// Ponto de entrada para definir se ira comunicar Online ou nao
					if existBlock("PTXMOVPTON")
						lOnLine := execBlock("PTXMOVPTON",.f.,.f.,{aDadUsr,aDadRDA,aDados,aItens} )
					endIf

					// A funcao abaixo processa online com outra operadora solicitacao do
					// Portal/Xml
					// Se a operadora do usuario estiver online caso contrario segue regra de
					// intercambio normalmente
					// -----------------------------------------------
					// Se tiver online
					// Se nao encontra uma liberacao

					if lOnLine .and. ! lAprovLib .and. lOkVerPTU

						aRetFun := PLSXMOVONL(aItens,lAprovLib,lTrtUsr,lConsulta,cOrigem,cAno,cMes,dDatPro,cHora,aDadUsr,aDadRDA,cCidPri,;
							clocalExec,cOpeSol,cCDPFSO,cPadInt,cPadCon,cRegAte,cCodPRFExe,cOpeExe,lRegPagAto,cTipoGrv,cAreaAbr,;
							cCodEsp,cCodLoc,cFilBCT,cViaCartao,cOpeOri,cLibEsp,cCodRda,cNumImp,@nQtdDiAut,@nQtdDiNeg,;
							aDadIte,aCriticas,aEventosNeg,aEventosAut,aDadBEA,aDados,cOriMov,cCarSol,cIndCli,@lCriTime,;
							cTranOS,lInter,cIndAci,cAteRN,lEvolu,cProtoc,cTokEdi,aAutoPTU,cEspSol,cTipoAte,cCodEspNw,cSadOcuNw)

						// Dados da transacao online
						lOnLine 	:= aRetFun[1]
						cNrSeqTR 	:= aRetFun[2]
						cSenhaOpe 	:= aRetFun[3]
						cMsg03 		:= aRetFun[4]
						lVeioComu   := aRetFun[5]
						cAutori     := aRetFun[6]
						cDatValAut  := aRetFun[8]

						If lPTUOn80 .And. Len(aRetFun) >= 9
							aDadB6MAux	:= aRetFun[9]
						EndIf

						If lPTUOn90 .And. Len(aRetFun) >= 10
							cNomeSocial	:= aRetFun[10]
						EndIf

					endIf

					// Processa regra de usuario de intercambio normalmente
					// (Solicitacao via ptu online de outra operadora ou caso a operadora
					//  nao esteja online)
					//  lCriAutPTU - todos itens estao criticados, preciso entrar aqui para
					//  gerar a guia negada

					if ! lOnLine .or. lAprovLib .or. lCriAutPTU


						// Checar a regra do procedimento
						PLSXMOVREG(	aItens,lAprovLib,lTrtUsr,lRegras,lConsulta,cOrigem,cAno,cMes,dDatPro,cHora,aDadUsr,aDadRDA,cCidPri,;
							clocalExec,cOpeSol,cCDPFSO,cPadInt,cPadCon,cRegAte,cCodPRFExe,cOpeExe,lRegPagAto,cTipoGrv,cAreaAbr,;                         //cCarSol,cSenBSN,cNuLibera   estava faltando estes 3 parametros
							cCodEsp,cCodLoc,cFilBCT,cTipoGrv,cLibEsp,cNumImp,cOpeMov,@nQtdDiAut,;                                                        //como n foi posssivel testar o processo.. vou deixar em branco
							aDadIte,aCriticas,aEventosNeg,aEventosAut,lAudEmp,nil,nil,nil,nil,aRdaProf,cCodEspPro,cCodLocPro,lTrtExe,;
							aDadBea,@lAto,lWeb,lInter,lSolicit,lImpXml,nil,nil,nil,nil,nil,cTipGui,cEspSol,cEspExe,cNumLib,,,,lNovaLib,;
							nil,nil,nil,cRegInt,cCaraterSol,cTGOriginal,,aProrInt)

					endIf

				endIf

			endIf

			If lWeb .And. !lPtuOnline .And. lInter .And. Len(aDadIte)>0 .And. Len(aItens)>0 .And. Len(aDadIte) == Len(aItens) .And. Len(aCriticas)>0 .And. (nPs:=aScan(aCriticas,{|x| allTrim(x[2]) == "585"}))>0
				//critica 585.. embora esteja parametrizada apenas p 1 procedimento...todos procedimentos da guia vem com a critica..aqui ajusto o nivel do adadite
				For nIt:=1 to Len(aDadIte)
					
					cNvCr := PLSRETDAD(aItens[nIt],"NIVCRI")
					cChNv := PLSRETDAD(aItens[nIt],"CHVNIV")

					If !Empty(cNvCr)
						PLSPUTDAD(aDadIte[nIt], "BE2_CHVNIV", cChNv, .T.)
						PLSPUTDAD(aDadIte[nIt], "BE2_NIVCRI", cNvCr, .T.)
						PLSPUTDAD(aDadIte[nIt], "BE2_NIVAUT", "", .T.)
					Else
						PLSPUTDAD(aDadIte[nIt], "BE2_CHVNIV", cChNv, .T.)
						PLSPUTDAD(aDadIte[nIt], "BE2_NIVCRI", "BR8", .T.) // BR8: Nivel padrão da critica 585
						PLSPUTDAD(aDadIte[nIt], "BE2_NIVAUT", "", .T.)
					EndIf
				Next
			EndIf

			// Checagem se e para incluir mesmo se for negado
			if lVeioComu .and. empty(aEventosAut)
				lIncUso 	:= .t.
				aEventosAut := aEventosNeg
				nQtdDiAut   := nQtdDiNeg
				cSenhaOpe	:= replicate("0",10)
			endIf
			// Grava demais campos
			// Quando for falso segue o processo normal
			if ! lIncUso .and. ! lInter
				if ( BAU->BAU_TIPPRE == getNewPar("MV_PLSTPIN","OPE") )
					lGerSenha := .t.
				endIf
			endIf
			// Para PTU Online preciso gerar a senha de internacao na criacao da guia
			if lPtuOnline .and. !lIncUso .and. ( BAU->BAU_TIPPRE == getNewPar("MV_PLSTPIN","OPE") )
				lGerSenha := .t.
			endIf

			if lPtuOnline
				aAreaBB0 := BB0->(GetArea())
				BB0->(dbSetOrder(5))
				if ! empty(allTrim(cCodOri))
					if BB0->(msSeek(xFilial("BB0")+cCodOri))
						aadd(aDadBEA,{"BEA_CDPFSO",cCDPFSO})
						aadd(aDadBEA,{"BEA_ESTSOL",BB0->BB0_ESTADO})
						aadd(aDadBEA,{"BEA_OPESOL",cOpeSol})
						aadd(aDadBEA,{"BEA_REGSOL",BB0->BB0_NUMCR})
						aadd(aDadBEA,{"BEA_NOMSOL",BB0->BB0_NOME})
						aadd(aDadBEA,{"BEA_SIGLA",BB0->BB0_CODSIG})

						aadd(aDadBEA,{"BEA_ESTEXE",BB0->BB0_ESTADO})
						aadd(aDadBEA,{"BEA_REGEXE",BB0->BB0_NUMCR})
						aadd(aDadBEA,{"BEA_NOMEXE",BB0->BB0_NOME})
						aadd(aDadBEA,{"BEA_SIGEXE",BB0->BB0_CODSIG})
						aadd(aDadBEA,{"BEA_CDPFRE",cCodPRFExe})
						aadd(aDadBEA,{"BEA_OPEEXE",cOpeExe})
					endIf
				elseIf !empty(cOpeSol) .and. cOpeOri <> PLSINTPAD() //Para intercambio preciso gravar o OPESOL
					aadd(aDadBEA,{"BEA_OPESOL",cOpeSol})
				endIf

				aadd(aDadBEA,{"BEA_SOLORI",PLSRETDAD( aDados,"SOLORIG","" ) } )
				RestArea(aAreaBB0)

				If lPTUOn90
					If BEA->(FieldPos("BEA_COBESP")) > 0
						aAdd(aDadBEA, {"BEA_COBESP", PLSRETDAD(aDados, "COBESPE", "")})
					EndIf
				EndIf
			else
				BB0->(dbSetOrder(1))
				if ! empty(allTrim(cCDPFSO))
					if BB0->(msSeek(xFilial("BB0")+cCDPFSO))
						aadd(aDadBEA,{"BEA_CDPFSO",cCDPFSO})
						aadd(aDadBEA,{"BEA_ESTSOL",BB0->BB0_ESTADO})
						aadd(aDadBEA,{"BEA_OPESOL",cOpeSol})
						aadd(aDadBEA,{"BEA_REGSOL",BB0->BB0_NUMCR})
						aadd(aDadBEA,{"BEA_NOMSOL",BB0->BB0_NOME})
						aadd(aDadBEA,{"BEA_SIGLA",BB0->BB0_CODSIG})
					endIf
				elseIf !empty(cOpeSol) .and. cOpeOri <> PLSINTPAD() //Para intercambio preciso gravar o OPESOL
					aadd(aDadBEA,{"BEA_OPESOL",cOpeSol})
				endIf

				if lcmpTiss4
					aadd(aDadBEA,{"BEA_COBESP",cCobEsp})
				EndIf
				aadd(aDadBEA,{"BEA_SOLORI",PLSRETDAD( aDados,"SOLORIG","" ) } )

				BB0->(dbSetOrder(1))
				if ! empty(allTrim(cCodPRFExe))
					if BB0->(msSeek(xFilial("BB0")+cCodPRFExe))
						aadd(aDadBEA,{"BEA_ESTEXE",BB0->BB0_ESTADO})
						aadd(aDadBEA,{"BEA_REGEXE",BB0->BB0_NUMCR})
						aadd(aDadBEA,{"BEA_NOMEXE",BB0->BB0_NOME})
						aadd(aDadBEA,{"BEA_SIGEXE",BB0->BB0_CODSIG})
						aadd(aDadBEA,{"BEA_CDPFRE",cCodPRFExe})
						aadd(aDadBEA,{"BEA_OPEEXE",cOpeExe})
					endIf
				endIf
			endIf

			aadd(aDadBEA,{"BEA_CANCEL","0"})
			aadd(aDadBEA,{"BEA_TPGRV",cTipoGrv})
			aadd(aDadBEA,{"BEA_HORSOL",cHoraSol})
			aadd(aDadBEA,{"BEA_DATSOL",dDataSol})

			aadd(aDadBEA,{"BEA_INDCLI",subStr( cIndCli,1,250)  } )
			aadd(aDadBEA,{"BEA_INDCL2",subStr(cIndCli,251,500) } )

			if !empty(cNumLib)
				nOrdBEA := BEA->(indexOrd())
				nRecBEA := BEA->(recno())
				BEA->(dbSetOrder(1))
				if BEA->(msSeek(xFilial('BEA')+cNumLib))
					aadd(aDadBEA,{"BEA_ESPSOL",BEA->BEA_ESPSOL } )
				endIf
				BEA->(dbSetOrder(nOrdBEA))
				BEA->(dbGoto(nRecBEA))
			else
				aadd(aDadBEA,{"BEA_ESPSOL",cEspSol } )
			endIf

			aadd(aDadBEA,{"BEA_ESPEXE",cEspExe } )
			aadd(aDadBEA,{"BEA_GUIPRI",PLSRETDAD( aDados,"GUIPRI","" ) } )
			aadd(aDadBEA,{"BEA_GUIPRE",PLSRETDAD( aDados,"GUIPRE","" ) } )

			if (nPos := aScan(aDadBEA,{|x| x[1] == "BEA_TRACON"})) == 0
				aadd(aDadBEA,{"BEA_TRACON",iif(lPtuOnline .And. lAllAutori,"1","0")})
			else
				aDadBEA[nPos,2] := "0"
			endIf

			if (nPos := aScan(aDadBEA,{|x| x[1] == "BEA_TIPATE"})) == 0
				aadd(aDadBEA,{"BEA_TIPATE",cTipoAte})
			else
				aDadBEA[nPos,2] := cTipoAte
			endIf

			aadd(aDadBEA,{"BEA_TIPDOE",cTipDoe } )
			aadd(aDadBEA,{"BEA_TPODOE",nTmpDoe } )
			aadd(aDadBEA,{"BEA_UTPDOE",cUndDoe } )
			aadd(aDadBEA,{"BEA_INDACI",cIndAci } )
			if !lInter
				If Empty(cTipCon) .And. cTipoAte <> "04" .And. !lConsulta
					aadd(aDadBEA,{"BEA_TIPCON",PLSRETDAD( aDados,"TIPCON","" )  } )
				Else
					aadd(aDadBEA,{"BEA_TIPCON",PLSRETDAD( aDados,"TIPCON","1" )  } )
				EndIf
			endIf
			aadd(ADADBEA,{"BEA_TIPATO",PLSRETDAD( aDados,"TIPATO","")})
			aadd(ADADBEA,{"BEA_TIPFAT",PLSRETDAD( aDados,"TIPFAT","")})

			if (nPos := aScan(aDadBEA,{|x| x[1] == "BEA_TIPSAI"})) == 0
				aadd(aDadBEA,{"BEA_TIPSAI",cTipSai})
			else
				aDadBEA[nPos,2] := cTipSai
			endIf

			if lGerSenha

				if (nPos := aScan(aDadBEA,{|x| x[1] == "BEA_VALSEN"})) == 0

					if getNewPar("MV_PLSUNI","1") == "1" .and. (aDadUsr[45] <> PlsIntPad() .or. (Type(BAU->BAU_TIPPRE) <> 'U' .and. BAU->BAU_TIPPRE == getNewPar("MV_PLSTPIN","OPE"))) .or. lPtuOnline .or. lPTUOnSol
						aadd(aDadBEA,{"BEA_VALSEN",dDatabase+getNewPar("MV_PLPRZPT",30)})
					else
						aadd(aDadBEA,{"BEA_VALSEN",dDatabase+getNewPar("MV_PLPRZLB",30)})
					endIf

				else

					if getNewPar("MV_PLSUNI","1") == "1" .and. (aDadUsr[45] <> PlsIntPad() .or. (Type(BAU->BAU_TIPPRE) <> 'U' .and. BAU->BAU_TIPPRE == getNewPar("MV_PLSTPIN","OPE"))) .or. lPtuOnline .or. lPTUOnSol
						aDadBEA[nPos,2] := dDatabase+getNewPar("MV_PLPRZPT",30)
					else
						aDadBEA[nPos,2] := dDatabase+getNewPar("MV_PLPRZLB",30)
					endIf

				endIf

			endIf

			if (nPos := aScan(aDadBEA,{|x| x[1] == "BEA_STALIB"})) == 0
				aadd(aDadBEA,{"BEA_STALIB",if(len(aEventosAut) > 0,"1","0")})
			else
				aDadBEA[nPos,2] := if(len(aEventosAut) > 0,"1","0")
			endIf

			if (nPos := aScan(aDadBEA,{|x| x[1] == "BEA_TIPATE"})) == 0
				aadd(aDadBEA,{"BEA_TIPATE",if(lConsulta,"",cTipoAte)})
			else
				aDadBEA[nPos,2] := cTipoAte
			endIf

			if (nPos := aScan(aDadBEA,{|x| x[1] == "BEA_PAGATO"})) == 0
				aadd(aDadBEA,{"BEA_PAGATO","0"})
			endIf

			if (nPos := aScan(aDadBEA,{|x| x[1] == "BEA_GUIACO"})) == 0
				aadd(aDadBEA,{"BEA_GUIACO","0"})
			endIf


			if (nPos := aScan(aDadBEA,{|x| x[1] == "BEA_QUACOB"})) == 0
				aadd(aDadBEA,{"BEA_QUACOB","0"})
			endIf


			if (nPos := aScan(aDadBEA,{|x| x[1] == "BEA_TIPPRE"})) == 0
				aadd(aDadBEA,{"BEA_TIPPRE",aDadRda[27]})
			else
				aDadBEA[nPos,2] := aDadRda[27]
			endIf

			if ! empty(cGuiaOri)
				aadd(aDadBEA,{"BEA_NRLBOR",cGuiaOri})
			elseIf cOrigem == '2' .and. ! empty(cGuiPri)
				aadd(aDadBEA,{"BEA_GUIPRI",cGuiPri})
			endIf

			if lIncUso
				aadd(aDadBEA,{"BEA_STATUS","3"})
			else
				aadd(aDadBEA,{"BEA_STATUS","1"})
			endIf

			// Continua alimentanto dadbea
			aadd(aDadBEA,{"BEA_ORIMOV",iif(lOriHat,'6',cOriMov)})
			aadd(aDadBEA,{"BEA_TIPO",cTipo})
			aadd(aDadBEA,{"BEA_NUMIMP",cNumImp})
			aadd(aDadBEA,{"BEA_TIPPAC",iIf( ! empty(cTipPac),cTipPac,getNewPar("MV_PLSTPAA","9")) } )
			aadd(aDadBEA,{"BEA_OPEMOV",cOpeMov})
			aadd(aDadBEA,{"BEA_CID",cCidPri})
			aadd(aDadBEA,{"BEA_CIDSEC",PLSRETDAD( aDados,"CID2","" ) } )
			aadd(aDadBEA,{"BEA_CID3",PLSRETDAD( aDados,"CID3","" ) } )
			aadd(aDadBEA,{"BEA_CID4",PLSRETDAD( aDados,"CID4","" ) } )
			aadd(aDadBEA,{"BEA_CID5",PLSRETDAD( aDados,"CID5","" ) } )

			if ! empty(cCidPri)
				aadd(aDadBEA,{"BEA_DESCID",Posicione("BA9",1,xFilial("BA9")+cCidPri,"BA9_DOENCA")})
			endIf

			aadd(aDadBEA,{"BEA_MATUSA",cMatUsa})
			aadd(aDadBEA,{"BEA_MSG01",cMsg01})
			aadd(aDadBEA,{"BEA_MSG02",cMsg02})
			aadd(aDadBEA,{"BEA_MSG03",cMsg03})
			if BEA->( fieldPos("BEA_MSG08") ) > 0 .And. BEA->( fieldPos("BEA_MSG09") ) > 0
				aadd(aDadBEA,{"BEA_MSG08",cMsg08})
				aadd(aDadBEA,{"BEA_MSG09",cMsg09})
			endIf
			aadd(aDadBEA,{"BEA_NRTROL",cNrSeqTR})
			aadd(aDadBEA,{"BEA_COMUNI",iIf(lVeioComu .and. !lCriTime,"1","0")})
			aadd(aDadBEA,{"BEA_VIACAR",val(cViaCartao)} )
			aadd(aDadBEA,{"BEA_DTDIGI",date()})
			aadd(aDadBEA,{"BEA_USUOPE", cOperad})
			aadd(aDadBEA,{"BEA_DESOPE", iIf(empty(PLRETOPE()),'ELETRONICA',cOperad)})
			aadd(aDadBEA,{"BEA_LOCAL", cLocal})
			aadd(aDadBEA,{"BEA_CODLOC",cCodLoc})
			aadd(aDadBEA,{"BEA_DESLOC",aDadRda[19]})
			aadd(aDadBEA,{"BEA_ENDLOC",aDadRda[20]})
			aadd(aDadBEA,{"BEA_CODESP", aDadRda[15] })
			aadd(aDadBEA,{"BEA_DESESP", aDadRda[17] })
			aadd(aDadBEA,{"BEA_DATPRO",dDatPro})
			aadd(aDadBEA,{"BEA_CODRDA",cCodRda})
			aadd(aDadBEA,{"BEA_OPERDA",cOpeMov})
			aadd(aDadBEA,{"BEA_RDAEDI",cRdaEdi})
			aadd(aDadBEA,{"BEA_NOMEDI",cNomEdi})

			if empty(cTipPre)
				cTipPre := BAU->BAU_TIPPRE
			endIf

			cSexo := BA1->BA1_SEXO
			aadd(aDadBEA,{"BEA_TIPPRE",cTipPre})
			aadd(aDadBEA,{"BEA_NOMRDA",aDadRDA[6]})
			aadd(aDadBEA,{"BEA_MATANT",aDadUsr[3]})
			aadd(aDadBEA,{"BEA_NOMUSR",aDadUsr[6]})
			aadd(aDadBEA,{"BEA_ATERNA",cAteRN})
			aadd(aDadBEA,{"BEA_TIPUSR",aDadUsr[43]})
			aadd(aDadBEA,{"BEA_CPFUSR",BA1->BA1_CPFUSR})
			aadd(aDadBEA,{"BEA_IDUSR",BA1->BA1_DRGUSR})
			aadd(aDadBEA,{"BEA_DATNAS",BA1->BA1_DATNAS})
			aadd(aDadBEA,{"BEA_CONEMP",aDadUsr[9]})
			aadd(aDadBEA,{"BEA_VERCON",aDadUsr[39]})
			aadd(aDadBEA,{"BEA_SUBCON",aDadUsr[41]})
			aadd(aDadBEA,{"BEA_VERSUB",aDadUsr[42]})
			aadd(aDadBEA,{"BEA_MATVID",aDadUsr[5]})
			aadd(aDadBEA,{"BEA_PACOTE","0"})
			aadd(aDadBEA,{"BEA_OPEUSR",Subs(aDadUsr[2],atCodOpe[1],atCodOpe[2])})
			aadd(aDadBEA,{"BEA_CODEMP",Subs(aDadUsr[2],atCodEmp[1],atCodEmp[2])})
			aadd(aDadBEA,{"BEA_MATRIC",Subs(aDadUsr[2],atMatric[1],atMatric[2])})
			aadd(aDadBEA,{"BEA_TIPREG",Subs(aDadUsr[2],atTipReg[1],atTipReg[2])})
			aadd(aDadBEA,{"BEA_DIGITO",Subs(aDadUsr[2],atDigito[1],atDigito[2])})
			aadd(aDadBEA,{"BEA_HORPRO",cHora})
			aadd(aDadBEA,{"BEA_HHDIGI",StrTran(Time(),":","")})
			aadd(aDadBEA,{"BEA_OPEINT",cOpeInt } )
			aadd(aDadBEA,{"BEA_NOMTIT",aDadUsr[6]})
			aadd(aDadBEA,{"BEA_ATEAMB","1"})
			aadd(aDadBEA,{"BEA_ANOPAG",cAno})
			aadd(aDadBEA,{"BEA_MESPAG",cMes})
			aadd(aDadBEA,{"BEA_TIPADM",cTipAdm } )
			aadd(aDadBEA,{"BEA_ARQIMP",cArqImp } )
			aadd(aDadBEA,{"BEA_LOTGUI",cLotGui} )

			// Vou priorizar o cSenhaOpe pois e o retorno da comunicacao online
			if !lWeb .and. !lIncUso .And. !lTsOnPr
				cSenhaOpe:= cSenBSN
			endIf
			if !empty(cNrOpe1100)
				aadd(aDadBEA,{"BEA_NRAOPE",cNrOpe1100})
			elseIf empty(cSenhaOpe) .or. (val(cSenhaOpe) == 0 .and. !lIncUso)
				aadd(aDadBEA,{"BEA_NRAOPE",BEA->BEA_NRAOPE} )
			else
				aadd(aDadBEA,{"BEA_NRAOPE",cSenhaOpe})
			endIf

			aadd(aDadBEA,{"BEA_DTRLZ",dDtRlz})
			aadd(aDadBEA,{"BEA_DTRLZ2",dDtRlz2})
			aadd(aDadBEA,{"BEA_DTRLZ3",dDtRlz3})
			aadd(aDadBEA,{"BEA_DTRLZ4",dDtRlz4})
			aadd(aDadBEA,{"BEA_DTRLZ5",dDtRlz5})
			aadd(aDadBEA,{"BEA_DTRLZ6",dDtRlz6})
			aadd(aDadBEA,{"BEA_DTRLZ7",dDtRlz7})
			aadd(aDadBEA,{"BEA_DTRLZ8",dDtRlz8})
			aadd(aDadBEA,{"BEA_DTRLZ9",dDtRlz9})
			aadd(aDadBEA,{"BEA_DTRLZ1",dDtRlz1})
			aadd(aDadBEA,{"BEA_PROATE",cProtoc})

			if BEA->( fieldPos("BEA_TOKEDI") ) > 0
				aadd(aDadBEA,{"BEA_TOKEDI",cTokEdi})
			endIf

			if BEA->( fieldPos("BEA_AUSVLD") ) > 0
				aadd(aDadBEA,{"BEA_AUSVLD",cAusenCod})
			endIf

			if !Empty(cDatValAut)
				aadd(aDadBEA,{"BEA_VALSEN",Stod(cDatValAut)})
			endIf

			//Guia Consulta e SADT r7
			aadd(aDadBEA,{"BEA_COBESP", cCodEspNw})
			aadd(aDadBEA,{"BEA_TMREGA", cRegAtdNw})
			aadd(aDadBEA,{"BEA_SAUOCU", cSadOcuNw})

			If lPTUOn90 .And. !Empty(cNomeSocial)
				aadd(aDadBEA,{"BEA_NOMSOC", cNomeSocial})
			Else
				aadd(aDadBEA,{"BEA_NOMSOC", BA1->BA1_NOMSOC})
			EndIf

			// Alterações do PTU Online 6.0
			aadd(aDadBEA,{"BEA_GUIJUR",iIf(cGuiJur == 'S', '1','0') } )

			If (lPTUOnline .Or. lPTUOnOS) .And. cTransPTU $ "00600/00605/00806" .And. PLSALIASEXI("B6M") .And. lPTUOn80

				aadd(aDadB6MAux, {"B6M_ETAAUT" ,cEtaAut})
				aadd(aDadB6MAux, {"B6M_DTSOLI" ,dDtSoli})
				aadd(aDadB6MAux, {"B6M_TIPGUI" ,cTpGuia})
				aadd(aDadB6MAux, {"B6M_TPACOM" ,cTpAcom})

				If cTransPTU == "00605"
					aadd(aDadB6MAux,{"B6M_NRTROL", StrZero(Val(PLSRETDAD( aDados,"NR_IDENT_O","")),10) })
				Else
					aadd(aDadB6MAux,{"B6M_NRTROL",cNrSeqTR})
				EndIf

				aadd(aDadB6MAux,{"B6M_NRAOPE",cSenhaOpe})
				aadd(aDadB6MAux,{"B6M_ALIAS" ,cAliasPTU})

				aadd(aDadB6M,aDadB6MAux)

			ElseIf lOnline .And. Len(aDadB6MAux) > 0 .And. lPTUOn80 // Portal
				aadd(aDadB6M,aDadB6MAux)
			EndIf

			// Se for internacao
			if lInter

				cMsgClient := PLSRETDAD( aDados,"MSG01","" ) + PLSRETDAD( aDados,"MSG02","" )
				dDPrAH 	   := PLSRETDAD( aDados,"DATPRVINT",dDataBase )

				aadd(aDadBE4,{"BE4_CGCRDA",cCnpjSolT})
				aadd(aDadBE4,{"BE4_CID",cCidPri})

				if ! empty(cCidPri)
					BA9->(dbSetOrder(1))
					if BA9->(msSeek(xFilial("BA9")+cCidPri))
						aadd(aDadBE4,{"BE4_INTSIP",BA9->BA9_INTSIP})
					endIf
				endIf
				if ! empty(cCidPri)
					aadd(aDadBE4,{"BE4_DESCID",Posicione("BA9",1,xFilial("BA9")+cCidPri,"BA9_DOENCA")})
				endIf

				aadd(aDadBE4,{"BE4_DTDIGI",date()})
				aadd(aDadBE4,{"BE4_PODRFS",'1'})
				aadd(aDadBE4,{"BE4_BLOPAG",'0'})
				aadd(aDadBE4,{"BE4_STAFAT",'1'})

				if getNewPar("MV_PLSUNI","1") == "1" .and. (aDadUsr[45] <> PlsIntPad() .or. (Type(BAU->BAU_TIPPRE) <> 'U' .and. BAU->BAU_TIPPRE == getNewPar("MV_PLSTPIN","OPE"))) .or. lPtuOnline
					aadd(aDadBE4,{"BE4_DATVAL",dDataBase+getNewPar("MV_PLPRZPT",30)})
				else
					aadd(aDadBE4,{"BE4_DATVAL",dDataBase+getNewPar("MV_PLPRZLB",30)})
				endIf
				aadd(aDadBE4,{"BE4_FASE","1"})
				aadd(aDadBE4,{"BE4_SITUAC","1"})
				aadd(aDadBE4,{"BE4_PADCON",cPadCon})
				aadd(aDadBE4,{"BE4_PADINT",cPadInt})
				aadd(aDadBE4,{"BE4_DTALTA",dDtAlta})
				aadd(aDadBE4,{"BE4_HRALTA",cHrAlta})
				aadd(aDadBE4,{"BE4_REGINT",cRegint } )

				if (nPos := aScan(aDadBE4,{|x| x[1] == "BE4_PAGATO"})) == 0
					aadd(aDadBE4,{"BE4_PAGATO","0"})
				endIf

				aadd(aDadBE4,{"BE4_LOTGUI",cLotGui})

				aadd(aDadBE4,{"BE4_PREOPE",cPrvOpm})
				aadd(aDadBE4,{"BE4_PREQUI",cPrvQui})
				aadd(aDadBE4,{"BE4_ATERNA",cAteRN})
				aadd(aDadBE4,{"BE4_ESPSOL",cEspSol})
				aadd(aDadBE4,{"BE4_ESPEXE",cEspExe})
				aadd(aDadBE4,{"BE4_EMGEST",PLSRETDAD( aDados,"EMGEST","0" ) } )
				aadd(aDadBE4,{"BE4_ABORTO",PLSRETDAD( aDados,"ABORTO","0" ) } )
				aadd(aDadBE4,{"BE4_TRAGRA",PLSRETDAD( aDados,"TRAGRA","0" ) } )
				aadd(aDadBE4,{"BE4_COMURP",PLSRETDAD( aDados,"COMURP","0" ) } )
				aadd(aDadBE4,{"BE4_ATESPA",PLSRETDAD( aDados,"ATESPA","0" ) } )
				aadd(aDadBE4,{"BE4_COMNAL",PLSRETDAD( aDados,"COMNAL","0" ) } )
				aadd(aDadBE4,{"BE4_BAIPES",PLSRETDAD( aDados,"BAIPES","0" ) } )
				aadd(aDadBE4,{"BE4_PARCES",PLSRETDAD( aDados,"PAAREO","0" ) } )
				aadd(aDadBE4,{"BE4_PATNOR",PLSRETDAD( aDados,"PATNOR","0" ) } )
				aadd(aDadBE4,{"BE4_NRDCNV",PLSRETDAD( aDados,"NRDCNV","" ) } )
				aadd(aDadBE4,{"BE4_NASVIV",nQtNasV } )
				aadd(aDadBE4,{"BE4_NASMOR",nQtNasM } )
				aadd(aDadBE4,{"BE4_NASVPR",nQtNasP } )
				aadd(aDadBE4,{"BE4_OBTMUL",cObtMul } )
				aadd(aDadBE4,{"BE4_OBTPRE",nQtObtP } )
				aadd(aDadBE4,{"BE4_OBTTAR",nQtObAR } )
				aadd(aDadBE4,{"BE4_TIPALT",cTipAlt } )
				aadd(aDadBE4,{"BE4_CIDOBT",cCidObt } )
				aadd(aDadBE4,{"BE4_NRDCOB",cNrdCob } )
				aadd(aDadBE4,{"BE4_TIPFAT",cTipFat } )

				// Grava RDA contratado solicitante

				if !empty(cRdaCon)

					//Grava o ponteiro original da BAU
					aAreaBAU := BAU->(GetArea())

					aadd(aDadBE4,{"BE4_RDACON",Posicione("BAU",4,xFilial("BAU")+cRdaCon,"BAU_CODIGO")}) //Posiciona e retorna o Codigo da BAU da RDA CONT. SOL. após busca pelo CPF/CNPJ.
					aadd(aDadBE4,{"BE4_DRDACO",BAU->BAU_NOME}) //Como está posicionado, armazena o nome da RDA na BE4.

					//Restaura BAU original para prosseguir
					RestArea(aAreaBAU)

				endIf
				// Qtd diarias autorizadas / Solicitada

				if !lPProcDiaria
					nQtdDiAut := PLSRETDAD( aDados,"QDISOL",nQtdDiAut) // Se não possuir procedimento de diária, pega a quantidade autorizada do cabeçalho.
				endIf

				if !lEvolu
					aadd(aDadBE4,{"BE4_DIASSO",PLSRETDAD( aDados,"QDISOL",nQtdDiAut)  } )
					aadd(aDadBE4,{"BE4_DIASIN",nQtdDiAut })
				else
					aadd(aDadBE4,{"BE4_DIASPR",nQtdDiAut})
				endIf

				aadd(aDadBE4,{"BE4_QTDEVE",len(aItens)})
				aadd(aDadBE4,{"BE4_GUIIMP","0"})
				aadd(aDadBE4,{"BE4_GRPINT",cGrpInt } )
				aadd(aDadBE4,{"BE4_TIPINT",cTipInt } )
				aadd(aDadBE4,{"BE4_PADINT",iIf(!empty(cPadInt),cPadInt,getNewPar("MV_PLPADIN","01"))})
				aadd(aDadBE4,{"BE4_PRVINT",PLSRETDAD( aDados,"DATPRVINT",dDataBase ) } )
				aadd(aDadBE4,{"BE4_DATPRO",dDatPro})
				aadd(aDadBE4,{"BE4_HORPRO",cHora})
				aadd(aDadBE4,{"BE4_INDCLI",cIndCli } )
				aadd(aDadBEA,{"BE4_PROATE",cProtoc})

				if BE4->( fieldPos("BE4_TOKEDI") ) > 0
					aadd(aDadBE4,{"BE4_TOKEDI",cTokEdi})
				endIf

				// Alterações do PTU Online 6.0
				aadd(aDadBE4,{"BE4_GUIJUR",iIf(cGuiJur == 'S', '1','0') } )

			endIf

			// PE para manipulacao dos dados que serao gravados no cabecalho da guia
			if existBlock("PLCABXMOV")
				aRetPECab := execBlock("PLCABXMOV",.f.,.f.,{aDadBEA,aDadBE4} )
				if len(aRetPECab) > 0
					aDadBEA := aRetPECab[1]
					aDadBE4 := aRetPECab[2]
				endIf
			endIf

			// Ajusta os Itens da matriz adadite para acos
			if len(aCols) == 0
				aVetTrab := {}
				aTrbDF   := {}
				for nY := 1 To len(aDadIte)
					// Verifica se o procedimento existe
					aadd(aCols, Array(len(aHeader)+1) )
					// Marca como nao deletado
					aCols[ len(aCols),len(aCols[len(aCols)]) ] := .f.
					// Ajusta aCols
					for nX := 1 To len(aDadIte[nY])
						nPos := PLRETPOS(aDadIte[nY,nX,1],aHeader,.f.)
						if nPos > 0
							aCols[len(aCols),nPos] := aDadIte[nY,nX,2]
						endIf
					next
					aadd(aVetTrab,0)

					if cTipo == "4"
						cSeq   := PLSRETDAD(aDadIte[nY],"BE2_SEQUEN")
						cDente := PLSRETDAD(aDadIte[nY],"BE2_DENREG")
						cFace  := PLSRETDAD(aDadIte[nY],"BE2_FADENT")
						cCodPad:= PLSRETDAD(aDadIte[nY],"BE2_CODPAD")
						cCodPro:= PLSRETDAD(aDadIte[nY],"BE2_CODPRO")
						aadd(aDadDF,Array( len(aCabDF)+1))

						aDadDF[ len(aDadDF),len(aDadDF[len(aDadDF)]) ] := .f.

						if ( nPosRet := PLRETPOS("BYS_SEQUEN",aCabDF,.f.) ) > 0
							aDadDF[ len(aDadDF),nPosRet ] := cSeq
						endIf

						if ( nPosRet := PLRETPOS("BYS_CODIGO",aCabDF,.f.) ) > 0
							aDadDF[ len(aDadDF),nPosRet ] := cDente
						endIf

						if B04->(msSeek(XFILIAL("B04")+cDente))
							if ( nPosRet := PLRETPOS("BYS_DESCRI",aCabDF,.f.) ) > 0
								aDadDF[ len(aDadDF),nPosRet ] := B04->B04_DESCRI
							endIf
							if ( nPosRet := PLRETPOS("BYS_TIPO",aCabDF,.f.) ) > 0
								aDadDF[ len(aDadDF),nPosRet ]   := B04->B04_TIPO
							endIf
							if ( nPosRet := PLRETPOS("BYS_SEGMEN",aCabDF,.f.) ) > 0
								aDadDF[ len(aDadDF),nPosRet ] := B04->B04_SEGMEN
							endIf
							if ( nPosRet := PLRETPOS("BYS_DESSEG",aCabDF,.f.) ) > 0
								aDadDF[ len(aDadDF),nPosRet ] := B04->B04_DESSEG
							endIf
							if ( nPosRet := PLRETPOS("BYS_M_ARCO",aCabDF,.f.) ) > 0
								aDadDF[ len(aDadDF),nPosRet ] := B04->B04_M_ARCO
							endIf
							if ( nPosRet := PLRETPOS("BYS_DESARC",aCabDF,.f.) ) > 0
								aDadDF[ len(aDadDF),nPosRet ] := B04->B04_DESARC
							endIf
						endIf

						if ( nPosRet := PLRETPOS("BYS_FACES",aCabDF,.f.) ) > 0
							aDadDF[ len(aDadDF),nPosRet ] := cFace
						endIf
						if ( nPosRet := PLRETPOS("BYS_CODPAD",aCabDF,.f.) ) > 0
							aDadDF[ len(aDadDF),nPosRet ] := cCodPad
						endIf
						if ( nPosRet := PLRETPOS("BYS_CODPSA",aCabDF,.f.) ) > 0
							aDadDF[ len(aDadDF),nPosRet ] := cCodPro
						endIf
						aadd(aTrbDF,0)
					endIf
				next
			endIf
			// Se tem algum procedimento
			if len(aCols) > 0
				// Criticas
				if len(aCriticas) > 0
					if (cTGOriginal == '11') //guia nova de prorrogação
						PLSDADCRI("BQZ",aCriticas,aCabCri,aDadCri,aTrbCri,"BQZ_SEQUEN","BQZ_CODGLO","BQZ_DESGLO","BQZ_INFGLO",iIf(lPtuOnline,"BQZ_CODEDI",nil))
					else
						PLSDADCRI("BEG",aCriticas,aCabCri,aDadCri,aTrbCri,"BEG_SEQUEN","BEG_CODGLO","BEG_DESGLO","BEG_INFGLO",iIf(lPtuOnline,"BEG_CODEDI",nil))
					endIf
				endIf
				// Transacao online
				if ! empty(cNomUsrIE)
					BA1->(RecLock("BA1",.f.))
					BA1->BA1_NOMUSR := cNomUsrIE
					BA1->(msUnLock())
				endIf

				// Inicia a Transacao
				Begin Transaction

					// Quando for Total a acols de gravacao tem que ser a mesma da lib
					if len(aColsLib) > 0 .and. cTpLibToAut == "T"

						cCampos := PLSA090Fld(cTipo)
						nPosSeq := PLRETPOS("BE2_SEQUEN",aHeaderLib,.f.)
						nPosPad := PLRETPOS("BE2_CODPAD",aHeaderLib,.f.)
						nPosPro := PLRETPOS("BE2_CODPRO",aHeaderLib,.f.)
						nPosDen := PLRETPOS("BE2_DENREG",aHeaderLib,.f.)
						nPosFac := PLRETPOS("BE2_FADENT",aHeaderLib,.f.)

						if nPosSeq > 0 .and. nPosPad > 0 .and. nPosPro > 0

							for nI := 1 To len(aCols)
								if ( nPosRet := PLRETPOS("BE2_SEQUEN",aHeader,.f.) ) > 0
									cSeq := aCols[nI,nPosRet]
								endIf
								if ( nPosRet := PLRETPOS("BE2_CODPAD",aHeader,.f.) ) > 0
									cCodPad	:= aCols[nI,nPosRet]
								endIf
								if ( nPosRet := PLRETPOS("BE2_CODPRO",aHeader,.f.) ) > 0
									cCodPro	:= aCols[nI,nPosRet]
								endIf
								if ( nPosRet := PLRETPOS("BE2_DENREG",aHeader,.f.) ) > 0
									cCodDen	:= aCols[nI,nPosRet]
								endIf
								if ( nPosRet := PLRETPOS("BE2_FADENT",aHeader,.f.) ) > 0
									cCodFac	:= aCols[nI,nPosRet]
								endIf

								if len(aRetLib[4]) ==  len(aAutItens)
									nPosCol := aScan(aColsLib,{|x| allTrim(x[nPosSeq]+x[nPosPad]+x[nPosPro]) == allTrim(cSeq+cCodPad+cCodPro) })
								else
									nPosCol := aScan(aColsLib,{|x| allTrim(x[nPosPad])+allTrim(x[nPosPro])+allTrim(x[nPosDen])+allTrim(x[nPosFac]) == allTrim(cCodPad)+allTrim(cCodPro)+allTrim(cCodDen)+allTrim(cCodFac) })
								endIf
								if nPosCol>0
									for nY:=1 To len(aHeader)
										if !( allTrim(aHeader[nY,2]) $ cCampos)
											loop
										endIf

										nPos := PLRETPOS(allTrim(aHeader[nY,2]),aHeaderLib,.f.)

										if nPos > 0 .and. allTrim(aHeader[nY,2]) <> "BE2_QTDPRO" .and. allTrim(aHeader[nY,2]) <> "BE2_VLRAPR" .and.;
												allTrim(aHeader[nY,2]) <> "BE2_VIA" .and. allTrim(aHeader[nY,2]) <> "BE2_QTDSOL" .and. allTrim(aHeader[nY,2]) <> "BE2_STATUS"

											aCols[nI,nY] := aColsLib[nPosCol,nPos]
										endIf

									next
								endIf
								//na execucao de uma sadt o saldo tem q ser zero, so tem q atualizar o saldo da liberacao
								if PLRETPOS("BE2_SALDO",aHeader,.f.) > 0 .and. PLRETPOS("BE2_QTDSOL",aHeader,.f.)> 0 .and. PLRETPOS("BE2_QTDPRO",aHeader,.f.) > 0
									aCols[nI,PLRETPOS("BE2_SALDO",aHeader,.f.)] := if(!empty(cNumLib) .and. (lInter .or. lEvolu .or. lHonor),Acols[nI,PLRETPOS("BE2_QTDSOL",aHeader,.f.)]-Acols[nI,PLRETPOS("BE2_QTDPRO",aHeader,.f.)],0)
								endIf

								//na execução, caso tenha sido incluída a via de acesso, a porcentagem do valor da
								//via também deve ser atualizada de acordo com o cadastro (Tab. BGR)
								if PLRETPOS("BE2_VIA",aHeader,.f.) > 0 .and. PLRETPOS("BE2_PERVIA",aHeader,.f.) > 0 .and. !empty(aCols[nI,PLRETPOS("BE2_VIA",aHeader,.f.)])
									aCols[nI,PLRETPOS("BE2_PERVIA",aHeader,.f.)] := 0

									BGR->( dbSetOrder(1) )//BGR_FILIAL + BGR_CODINT + BGR_CODVIA
									if BGR->(msSeek(xFilial("BGR")+PlsIntPad()+aCols[nI,PLRETPOS("BE2_VIA",aHeader,.f.)]))
										aCols[nI,PLRETPOS("BE2_PERVIA",aHeader,.f.)] := BGR->BGR_PERC
									endIf

								endIf
							next
						else
							// Se gera log caixa preta
							if lWLIO
								PlsLogFil(space(03)+"CAMPOS NAO ENCONTRADOS PLRETPOS - BE2_SEQUEN,BE2_CODPAD,BE2_CODPRO" ,__PLSFLOGX)
							endIf
						endIf
					endIf

				End Transaction

				// Altera SITUAC para guia de PTU
				if !lOkVerPTU
					cSituacPTU := "3"
				endIf

				if lOnLine .and. empty(cSituacPTU) .and. !empty(cAutori)
					if cAutori == "1" .or. cAutori == "2"
						cSituacPTU := "1"
					else
						cSituacPTU := "3"
					endIf
				endIf

				if cTipo == '2'

					for nfor2 := 1 To len(aItens)

						aTpPar  := PLSRETDAD(aItens[nfor2],"ATPPAR",{})

						if len(aTpPar) > 0
							aadd(aTpPart, aTpPar)
						endIf

					next

					Store Header "B4B" TO aHeadeB4B for .t.

					aDadTemp := Array(11)

					for nI1 := 1 To len(aTpPart)

						for nI2 := 1 To len(aTpPart[nI1])

							aDadTemp := Array(11)

							aDadTemp[aScan(aHeadeB4B,{|x| allTrim(x[2]) == "B4B_SEQUEN"})] := aTpPart[nI1][nI2][10]
							aDadTemp[aScan(aHeadeB4B,{|x| allTrim(x[2]) == "B4B_OPEMOV"})] := cOpeMov
							aDadTemp[aScan(aHeadeB4B,{|x| allTrim(x[2]) == "B4B_GRAUPA"})] := aTpPart[nI1][nI2][1]
							aDadTemp[aScan(aHeadeB4B,{|x| allTrim(x[2]) == "B4B_SICONS"})] := aTpPart[nI1][nI2][5]
							aDadTemp[aScan(aHeadeB4B,{|x| allTrim(x[2]) == "B4B_NUCONS"})] := aTpPart[nI1][nI2][4]
							aDadTemp[aScan(aHeadeB4B,{|x| allTrim(x[2]) == "B4B_UFCONS"})] := aTpPart[nI1][nI2][6]

							cNomExec := Posicione("BB0",1,xFilial("BB0")+aTpPart[nI1][nI2][7],"BB0_NOME")
							aDadTemp[aScan(aHeadeB4B,{|x| allTrim(x[2]) == "B4B_NOMPRF"})] := cNomExec
							aDadTemp[aScan(aHeadeB4B,{|x| allTrim(x[2]) == "B4B_CGC"})]    := aTpPart[nI1][nI2][2]
							aDadTemp[aScan(aHeadeB4B,{|x| allTrim(x[2]) == "B4B_CDPFPR"})] := aTpPart[nI1][nI2][7]

							if len(aTpPart[nI1][nI2][11]) > 6
								aDadTemp[aScan(aHeadeB4B,{|x| allTrim(x[2]) == "B4B_CODESP"})] := subStr(aTpPart[nI1][nI2][11],4)
							else
								aDadTemp[Ascan(aHeadeB4B,{|x| AllTrim(x[2]) == "B4B_CODESP"})] := Iif(cTipo == '2' .AND. LEN(aTpPart[nI1][nI2]) >= 12, aTpPart[nI1][nI2][12], aTpPart[nI1][nI2][11])
							endIf

							aDadTemp[11] := .f.

							aadd(aColsB4B, aDadTemp)
							aDadTemp := {}
						next
					next

					aVetB4B := {0}
				endIf

				//Isso se faz necessário pois após dar a validação de quantidade executada maior que a autorizada, mesmo assim o sistema baixava o saldo.
				if lWeb
					for nEn := 1 To len(aEventosNeg)

						nPos := aScan(aAutItens,{|x| allTrim(x[1])+allTrim(x[2])+allTrim(x[3])+allTrim(x[15])+allTrim(x[16]) == alltrim(aEventosNeg[nEn][1])+ alltrim(aEventosNeg[nEn][2])+ alltrim(aEventosNeg[nEn][3])+ alltrim(aEventosNeg[nEn][7])+ alltrim(aEventosNeg[nEn][8])})

						if nPos > 0

							if !empty(cNumLib) .and. len(aRetLib) > 3 .And. len(aRetLib[4])	> 0
								nPosRetLib := aScan(aRetLib[4],{|x|allTrim(x[3])+allTrim(x[4])+allTrim(x[24])+allTrim(x[25]) == alltrim(aEventosNeg[nEn][2])+ alltrim(aEventosNeg[nEn][3])+ alltrim(aEventosNeg[nEn][7])+ alltrim(aEventosNeg[nEn][8])})
								if nPosRetLib > 0
									aAutItens[nPos, 5] := aRetLib[4,nPosRetLib,13] // Caso seja negado, atualiza o saldo para o solicitado inicalmente
								endIf
							else

								nPosSeq := PLRETPOS("BE2_SEQUEN",aHeader,.f.)
								nPosPad := PLRETPOS("BE2_CODPAD",aHeader,.f.)
								nPosPro := PLRETPOS("BE2_CODPRO",aHeader,.f.)
								nPosDen := PLRETPOS("BE2_DENREG",aHeader,.f.)
								nPosFac := PLRETPOS("BE2_FADENT",aHeader,.f.)

								nPosCol := aScan(aCols,{|x| allTrim(x[nPosSeq])+ allTrim(x[nPosPad])+allTrim(x[nPosPro])+allTrim(x[nPosDen])+allTrim(x[nPosFac]) == alltrim(aEventosNeg[nEn][1])+ alltrim(aEventosNeg[nEn][2])+ alltrim(aEventosNeg[nEn][3])+ alltrim(aEventosNeg[nEn][7])+ alltrim(aEventosNeg[nEn][8])})

								if nPosCol > 0
									aCols[nPosCol,PLRETPOS("BE2_SALDO",aHeader,.f.)] := 0
								endif

								//aAutItens[nPos, 5] := 0 //Caso seja liberação e negou, zera saldo.
							endif
						endif
					next nEn
				endif

				//Caso o parametro esteja .T. não considera as criticas de auditoria.
				if GetNewPar("MV_PLATURG",.F.) .And. lWeb  .And. PLSISURG(cCaraterSol)
					for nEn := 1 To len(aCols)
						nPos := PLRETPOS("BE2_AUDITO",aHeader,.f.)
						if nPos > 0 .And. aCols[nEn,nPos] == "1"
							aCols[nEn,nPos] := "0"
						endIf
					next nEn
				endIf

				// Gravacao
				if ! lEvolu .or. (lEvolu .and. cTGOriginal <> '11')

					if IsInCallStack('tisssolicitacaoprocedimento') //Para TISS Online, desmarco o cArqImp para evitar que gere uma nova PEG para a guia
                        cArqImp := ''
                    endIf

					aRet090 := PLSA090Grv(	aClone(aCols),aClone(aHeader),aDadBEA,K_Incluir,aClone(aVetTrab),{},aDadUsr[2],dDatPro,cHora,"1",cAno,;
						cMes,cTipGui,lInter,aDadCri,aCabCri,aTrbCri,/*lAutori*/,cOrigem,cCodLDP,;
						iIf(len(aEventosNeg)>0 .and. lIncNeg,.t.,lReanaliza),/*cFiltro*/,/*cKey*/,lforBlo,lVeioComu,lNMudFase,;
						/*cAliasIte*/,/*cAliasCri*/,.t.,lEvolu,aDadBE4,lGerSenha,lWeb,/*aDadB43*/,/*aCabB43*/,/*aTrbB43*/,;
						/*oBrwEven*/,/*lExcluiAte*/,/*oBrwB47*/,/*cAliasCab*/,/*lReembolso*/,/*oBrwB46*/,/*oBrwB44*/,;
						lIncNeg,/*cObsoleto*/,lSolicit,cTipoGrv,aDadDF,aCabDF,aTrbDF,aDaSenPro,lGuiHoRe,/*aMatBd6*/,/*aMatCom*/,;
						/*lResInt*/,/*cAliasCmp*/,iIf(cTipo=="4",.t.,nil),cNuLibera,cArqImp,lEvoSadt,iIf(!empty(cSituacPTU),cSituacPTU,nil),/*lProtoc*/,;
						/*aPartic*/,aColsB4B,aHeadeB4B,aVetB4B,/*cNumLibOd*/,/*lRecGlo*/,lPTUOnSol,/*cObsEvo*/,/*nNrSeqTR*/,/*cSenhaOpe*/,;
						cOpeSol, cNewAut,lPtuOnline,aCampCust,iif(!empty(cDatValAut),Stod(cDatValAut),nil),/*lSUS*/,/*aArraySUS*/, /*lReembCriaBD5*/,;
						/*lGuiAudit*/,/*oGetBZC*/,/*cTrolComun*/,aBQVPTUDif,cADaB7B,aDadB6M,aItensB6L, cRdaExe)

					// Grava o recno gerado
					nRecGer := BEA->(recno())

					if lAprovLib
						cStaGu := BEA->BEA_STATUS
						// Posiciona na liberacao original
						BEA->( dbGoto( nRecBEALIB ) )

						// Se for total atualiza o cabecalho da liberacao tb
						if cTpLibToAut == "T"

							if PLIBAUD(@cNumLib,.t.)
								cStaLib := "6"
								PLSATUCS(cStaLib)
							else
								If cStaGu <> '3'
									PLSATUCS()
								EndIf
							endIf
						endIf

						// Posiciona na liberacao
						aIndDelCols:= {}
						nPosSeqMov := PLRETPOS("BE2_SEQUEN",aHeader,.f.)
						nPosCodPad := PLRETPOS("BE2_CODPAD",aHeader,.f.)
						nPosCodPro := PLRETPOS("BE2_CODPRO",aHeader,.f.)
						nPosQtdPro := PLRETPOS("BE2_QTDPRO",aHeader,.f.)
						nPosDenPro := PLRETPOS("BE2_DENREG",aHeader,.f.)
						nPosFacPro := PLRETPOS("BE2_FADENT",aHeader,.f.)

						if nPosCodPad > 0 .and. nPosCodPro > 0

							for nfor := 1 To len(aCols)
								// So e possivel a verificacao da sequancia quando o array de itens nao foi al-
								// rado no portal.
								// Caso seja necessario a verificacao da sequencia qdo o procedimento e exclui-
								// sera necessario alteracao no java script que faz a exclusao no portal.
								if len(aRetLib[4]) ==  len(aAutItens)
									nPos := aScan(aAutItens,{|x| allTrim(x[1])+allTrim(x[2])+allTrim(x[3])+allTrim(x[15])+allTrim(x[16]) == allTrim(aCols[nfor,nPosSeqMov])+allTrim(aCols[nfor,nPosCodPad])+allTrim(aCols[nfor,nPosCodPro])+allTrim(aCols[nfor,nPosDenPro])+allTrim(aCols[nfor,nPosFacPro])})
								else
									nPos := aScan(aAutItens,{|x| allTrim(x[2])+allTrim(x[3])+allTrim(x[15])+allTrim(x[16]) == allTrim(aCols[nfor,nPosCodPad])+allTrim(aCols[nfor,nPosCodPro])+allTrim(aCols[nfor,nPosDenPro])+allTrim(aCols[nfor,nPosFacPro])})
								endIf

								if nPos > 0

									if aAutItens[nPos,8] .and. aAutItens[nPos,7] > 0

										BE2->( dbGoto(aAutItens[nPos,7]) )
										nRecBE2 := aAutItens[nPos,7]

										nSaldo  := aAutItens[nPos,5]
										cStaLib := iIf(nSaldo==0,"2","1")
										PLSATUSS( nil,.t.,.t.,nSaldo,cStaLib,,,,,nRecBE2,,,,)
									endIf

									if ! aAutItens[nPos,8]
										aadd(aIndDelCols,nfor)
									endIf

								endIf

							next

							// Deleta cols
							if len(aIndDelCols) > 0

								aCloneCols := aClone(aCols)

								for nfor := 1 To len(aCloneCols)

									if aScan(aIndDelCols,nfor) > 0

										nSize := len(aCols)
										if len(aCols) >= nfor
											aDel(aCols,nfor)
										endIf
										if len(aCols)+1 >= (nSize-1)
											aSize(aCols,nSize-1)
										endIf
										nSize := len(aVetTrab)
										if len(aVetTrab) >= nfor
											aDel(aVetTrab,nfor)
										endIf
										if len(aVetTrab)+1 >= (nSize-1)
											aSize(aVetTrab,nSize-1)
										endIf

									endIf

								next

							endIf

						endIf

						//Ajusta o status do cabecalho, se não ajustou lá em cima
						if cTpLibToAut <> "T" .and. BEA->BEA_TIPGUI $ G_SADT + "|" + G_ODONTO .and. !PLSSALDO("",BEA->(BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT))
							cTpLibToAut := "T"
							if PLIBAUD(@cNumLib,.t.)
								cStaLib := "6"
								PLSATUCS(cStaLib)
							else
								PLSATUCS()
							endIf
						endIf
					endIf

					lProRadio 	:= aRet090[12]
					lAudi		:= aRet090[9]
					//Retorna ao recno gerado no 090GRV
					if nRecGer > 0
						BEA->(dbGoto(nRecGer))
					endIf

				else

					aRetAux := PLSXVLDCAL(dDataBase,PLSINTPAD(),.t.,"","")

					aadd(aDadB4Q,{"B4Q_MATANT",BA1->BA1_MATANT })
					aadd(aDadB4Q,{"B4Q_OPEUSR",BA1->BA1_CODINT })
					aadd(aDadB4Q,{"B4Q_CODEMP",BA1->BA1_CODEMP })
					aadd(aDadB4Q,{"B4Q_CONEMP",BA1->BA1_CONEMP })
					aadd(aDadB4Q,{"B4Q_SUBCON",BA1->BA1_SUBCON })
					aadd(aDadB4Q,{"B4Q_VERCON",BA1->BA1_VERCON })
					aadd(aDadB4Q,{"B4Q_VERSUB",BA1->BA1_VERSUB })
					aadd(aDadB4Q,{"B4Q_MATRIC",BA1->BA1_MATRIC })
					aadd(aDadB4Q,{"B4Q_TIPREG",BA1->BA1_TIPREG })
					aadd(aDadB4Q,{"B4Q_DIGITO",BA1->BA1_DIGITO })
					aadd(aDadB4Q,{"B4Q_NOMUSR",BA1->BA1_NOMUSR })
					aadd(aDadB4Q,{"B4Q_CANCEL",'0' })
					aadd(aDadB4Q,{"B4Q_ANOPAG",aRetAux[4] })
					aadd(aDadB4Q,{"B4Q_MESPAG",aRetAux[5] })
					aadd(aDadB4Q,{"B4Q_PROATE",cProtoc})
					if B4Q->( fieldPos("B4Q_NOMSOC") ) > 0
						aadd(aDadB4Q,{"B4Q_NOMSOC", BA1->BA1_NOMSOC})
					endif
					aadd(aDadB4Q,{"B4Q_JUSOBS", cObsGuNw})

					//Caso a Operadora trabalhe com senha para prorrogação de internação, gera a senha
					If GetnewPar("MV_PLPRGSN", .F.)
						aadd(aDadB4Q,{"B4Q_SENHA",PLSSenAut(dDataBase)})
					EndIf

					private aAutforAnx 	:= {}
					private aCodCriHis 	:= {}


					aHeadeBQV := aClone(aHeader)

					nCpf	:= PLRETPOS("BEA_CDPFSO",aDadBEA,.f.)
					nEst   	:= PLRETPOS("BEA_ESTSOL",aDadBEA,.f.)
					nOpe   	:= PLRETPOS("BEA_OPESOL",aDadBEA,.f.)
					nReg   	:= PLRETPOS("BEA_REGSOL",aDadBEA,.f.)
					nNom   	:= PLRETPOS("BEA_NOMSOL",aDadBEA,.f.)
					nSigla 	:= PLRETPOS("BEA_SIGLA",aDadBEA,.f.)


					for nfor2 := 1 to len(aHeadeBQV)
						aHeadeBQV[nfor2][2] := "BQV_" + subStr(aHeadeBQV[nfor2][2], 5)
					next

					for nfor2 := 1 to len(aDadBEA)
						if aDadBEA[nfor2][1] = "BEA_ESTSOL"
							M->B4Q_ESTSOL := aDadBEA[nfor2][2]
						else
							if aDadBEA[nfor2][1] = "BEA_REGSOL"
								M->B4Q_REGSOL := aDadBEA[nfor2][2]
							else
								if aDadBEA[nfor2][1] = "BEA_NOMSOL"
									M->B4Q_NOMSOL := aDadBEA[nfor2][2]
								else
									if aDadBEA[nfor2][1] = "BEA_SIGLA"
										M->B4Q_SIGLA  := aDadBEA[nfor2][2]
									else
										if aDadBEA[nfor2][1] = "BEA_DATPRO"
											M->B4Q_DATPRO  := aDadBEA[nfor2][2]
										else
											if aDadBEA[nfor2][1] = "BEA_CODRDA"
												M->B4Q_CODRDA  := aDadBEA[nfor2][2]
											else
												if aDadBEA[nfor2][1] = "BEA_NOMRDA"
													M->B4Q_NOMRDA  := aDadBEA[nfor2][2]
												else
													if aDadBEA[nfor2][1] = "BEA_DATNAS"
														M->B4Q_IDADE	:= DateDiffYear(dDataBase,aDadBEA[nFor2][2])
													endIf
												endIf
											endIf
										endIf
									endIf
								endIf
							endIf
						endIf
					next

					if B4Q->( fieldPos("B4Q_ESPSOL") ) > 0
						M->B4Q_ESPSOL := cCBOS
					endIf

					M->B4Q_GUIREF := cNuLibera

					M->B4Q_SEXO   := cSexo
					M->B4Q_OPESOL := cOpeSol
					M->B4Q_CDPFSO := cCDPFSO

					M->B4Q_DATSOL := Date()
					M->B4Q_INDCLI := cIndCli
					M->B4Q_TIPACO := cPadInt

					aRet090 := PLSA09PGRV(K_Incluir,cOpeSol,'BQV'/*'BE2'*/,'B4Q','BQZ',aDadB4Q,aHeadeBQV/*aClone(aHeader)*//*aHeadIten*/,aClone(aCols)/*aColsIten*/,aClone(aVetTrab),aCabCri,aDadCri,aTrbCri,;
					"11",dDataBase,aRetAux[4],aRetAux[5],aChaveGen,nQtdDiSol, nil, nQtdDiAut)

					lAudi := iIf( len(aRet090) >= 9,aRet090[9],.f.)

				endIf

				// Fecha Semaforo
				DbCommitAll()

				//Conclui um protocolo
				if !empty(cProtoc)

					gerRegB00(cProtoc,,iIf(lInter,'BE4','BEA'),,,BEA->(BEA_OPEMOV + BEA_CODEMP + BEA_MATRIC + BEA_TIPREG + BEA_DIGITO),,,,,,,,,,,,,,.t.) // Gera registro na B00

					if ! empty(cNrSeqTR) .and. lNrTrol
						B00->(Reclock("B00",.f.))
						B00->B00_NRTROL := cNrSeqTR
						B00->(msUnLock())
					endIf

					P773AutCon(iIf(lInter,'BE4','BEA'),cProtoc,BEA->(BEA_OpeMov+BEA_AnoAut+BEA_MesAut+BEA_NumAut)) //Atualiza a guia com o número do protocolo

					//Complementa a guia em um job

					if getNewPar("MV_PL395WS","0") == "1"  .and. !empty(cNrSeqTR) .and. lOnLine .and. !lAprovLib .and. lOkVerPTU .and. PLSALIASEX("B4J")
						aThreads := {}
						StartJob("PLRCOMPRWB",GetEnvServer(),.f.,cEmpAnt,cFilAnt,aThreads,B00->(recno()) )
					endIf

				endIf
				// Alimenta participacao para o hm quando na execucao do importacao xml
				// Somente quando for raio-x o indicado para este tipo de evente vir em uma guia separada
				if len(aTpParG) > 0 .and. cTipo == '2'

					cNumPeg := BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)

					BD6->( dbSetOrder(6) )//BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_CODPAD + BD6_CODPRO
					for nfor2 := 1 To len(aItens)
						cCodPad := PLSRETDAD(aItens[nfor2],"CODPAD")
						cCodPro := PLSRETDAD(aItens[nfor2],"CODPRO")

						// Posiciona no bd6
						BD6->( msSeek(xFilial("BD6")+cNumPeg+"1"+cCodPad+cCodPro) )

						// Define participacao no bd7
						PLSPARBD7(cNumPeg+BD6->(BD6_ORIMOV+BD6_SEQUEN),aUnMed,aTpParG,clocalExec,cTipoGrv)
					next
				endIf

				// Alimenta participacao para o hm quando na execucao do importacao xml
				// Somente quando for raio-x o indicado para este tipo de evente vir em uma guia separada
				if cTipo == '2'

					cNumPeg := BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)

					BD6->( dbSetOrder(6) )//BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_CODPAD + BD6_CODPRO
					for nfor2 := 1 To len(aItens)
						cCodPad := PLSRETDAD(aItens[nfor2],"CODPAD")
						cCodPro := PLSRETDAD(aItens[nfor2],"CODPRO")
						aTpPar  := PLSRETDAD(aItens[nfor2],"ATPPAR",{})

						if len(aTpPar) > 0

							// Posiciona no bd6
							BD6->( msSeek(xFilial("BD6")+cNumPeg+"1"+cCodPad+cCodPro) )

							// Define participacao no bd7
							PLSPARBD7(cNumPeg+BD6->(BD6_ORIMOV+BD6_SEQUEN),aUnMed,aTpPar,clocalExec,cTipoGrv)
						endIf
					next
				endIf

			else
				// Se gera log caixa preta
				if lWLIO
					PlsLogFil(space(03)+"NENHUM PROCEDIMENTO ENCONTRADO NA MATRIZ ACOLS" ,__PLSFLOGX)
					PlsLogFil("",__PLSFLOGX)
				endIf
			endIf
		endIf

		// Transacoes online
		if lIncUso
			aEventosAut := {}
		endIf

		// Reanaliza
		if lRetVPF .and. lReanaliza .and. len(aEventosAut) > 0
			BD6->( dbSetOrder(1) )//BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO
			if BD6->(msSeek(xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)))

				while ! BD6->(eof()) .and. BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO) == ;
						xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI)

					nPos := aScan(aEventosAut,{|x| x[1] == BD6->BD6_SEQUEN })
					if nPos > 0 .and. len(aEventosAut[nPos]) >= 12
						aEventosAut[nPos][12] := BD6->BD6_VLRPAG + BD6->BD6_VLRGLO
					endif

					if BD6->BD6_VLRTPF > 0 .and. BD6->BD6_BLOCPA <> "1"
						
						if nPos > 0
							nVlrTPF += BD6->BD6_VLRTPF
						endIf

					endIf

					nPos := aScan(aItens,{|x| allTrim(PLSRETDAD(x,"CODPAD")) == allTrim(BD6->BD6_CODPAD) .and. allTrim(PLSRETDAD(x,"CODPRO")) == allTrim(BD6->BD6_CODPRO) })

					if nPos > 0

						cSlvPad := PLSRETDAD(aItens[nPos],"SLVPAD",'')
						cSlvPro := PLSRETDAD(aItens[nPos],"SLVPRO",'')

						if lWeb .and. getNewPar("MV_PLMFJOB","1") == "1" // Esse if foi criado pq Se esta mudando fase em JOB não adianta atualizar isso aqui pois a transção ainda nao vai ter concluido
							lAtuBD6 := .f.
						endIf
						if !empty(cSlvPad) .and. lAtuBD6
							BD6->(Reclock("BD6",.f.))
							BD6->BD6_SLVPAD := cSlvPad
							BD6->BD6_SLVPRO := cSlvPro

							if cTipo == '2' .and. !empty(PLSRETDAD(aItens[nPos],"DATPRO")) //INI 29-03

								BD6->BD6_DATPRO := PLSRETDAD(aItens[nPos],"DATPRO")

								BD7->(dbSetOrder(1))
								if BD7->(msSeek(xFilial('BD6')+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
									BD7->(Reclock("BD7",.f.))
									BD7->BD7_DATPRO := PLSRETDAD(aItens[nPos],"DATPRO") //FIM 29-03
									BD7->(msUnLock())
								endIf

							endIf//FIM 29-03

							BD6->(msUnLock())
						endIf
					endIf
					BD6->(dbSkip())
				endDo

				if nVlrTPF > 0
					// Se gera log caixa preta
					if lWLIO
						PlsLogFil(space(03)+ "",__PLSFLOGX)
						PlsLogFil(space(03)+ "VALOR APRESENTADO DOS ITENS AUTORIZADOS, AJUSTADO COM BASE NO BD6_VLRTPF!",__PLSFLOGX)
					endIf
				endIf
			endIf

		endIf
		// Na evolucao existe a necessidade da senha por procedimento
		if lEvolu
			for nI := 1 To len(aDaSenPro)
				if ( nPos := aScan(aEventosAut,{|x| x[1]+x[2]+x[3] == aDaSenPro[nI,1] }) ) > 0
					aEventosAut[nPos,9] := aDaSenPro[nI,2]
				endIf
			next
		endIf

		// Gravacao das criticas em um arquivo de controle
		if !len(aEventosAut) > 0 .and. getNewPar("MV_PLSGRVC","1") == "1"
			cRetCriMv := PLSGRVAUN(.f.,"",cMatric,dDatPro,cHora,cOpeMov,cCidPri,cCodRda,cOpeSol,cCdPFSO,cCodEsp,aItens,aCriticas,clocalExec,cTipoGrv)
		endIf

		// Monta retorno da funcao quando for servico tb deve ser exibida
		if cRetGui == "1" .and. cSomInt <> "1"
			cMsgClient := STR0027 //"Guia valida com autorizacao da empresa anexa"
		endIf

		// Coloca no procedimento original os procedimentos originais
		if len(aMatTroca) > 0

			for nfor := 1 To len(aMatTroca)

				if len(aCriticas) > 0
					if ( nPos := aScan(aCriticas,{|x| allTrim(x[1]+x[4]+x[5]+x[6]+x[7]) == allTrim(aMatTroca[nfor,1]+aMatTroca[nfor,2]+aMatTroca[nfor,4]+aMatTroca[nfor,5]+aMatTroca[nfor,6]) } ) ) > 0
						aCriticas[nPos,5] := aMatTroca[nfor,3]
					endIf
				endIf
				if len(aEventosAut) > 0
					if ( nPos := aScan(aEventosAut,{|x| allTrim(x[1]+x[2]+x[3]+x[7]+x[8]) == allTrim(aMatTroca[nfor,1]+aMatTroca[nfor,2]+aMatTroca[nfor,4]+aMatTroca[nfor,5]+aMatTroca[nfor,6]) } ) ) > 0
						aEventosAut[nPos,3] := aMatTroca[nfor,3]
					endIf
				endIf
				if len(aEventosNeg) > 0
					if ( nPos := aScan(aEventosNeg,{|x| allTrim(x[1]+x[2]+x[3]+x[7]+x[8]) == allTrim(aMatTroca[nfor,1]+aMatTroca[nfor,2]+aMatTroca[nfor,4]+aMatTroca[nfor,5]+aMatTroca[nfor,6]) } ) ) > 0
						aEventosNeg[nPos,3] := aMatTroca[nfor,3]
					endIf
				endIf
				// Se gera log caixa preta
				if lWLIO
					if lLogTro
						lLogTro := .f.
						PlsLogFil(space(03)+"RETORNADO O CODIGO ORIGINAL ( MV_PLSTRCO REFERENTE AO BR8_CODEDI )" ,__PLSFLOGX)
						PlsLogFil(space(03),__PLSFLOGX)
					endIf
					PlsLogFil(space(03)+"TROCA - "+aMatTroca[nfor,4]+" ORIGINAL - "+aMatTroca[nfor,3],__PLSFLOGX)
				endIf
			next
		endIf
	endIf

	// Numero de autorizacao de retorno
	if (lImpXml .or. lImpTxt) .and. cTipGui $ G_CONSULTA + "#" + G_SADT + "#" + G_RES_INTER + "#" + G_HONORARIO + "#" + G_REEMBOLSO + "#" + G_ODONTO
		cAutRet := 	cNumGuiH
		// Eventos Autorizados
		aadd(aEventosAut,{'001','00','000000',0,'',0,'','',""})
		// Informacoes para importacao de HONORARIO
		cDesc := ""
		BCL->(dbSetOrder(1))
		if BCL->(msSeek(xFilial('BCL')+cOpeMov+cTipGui))
			cDesc := BCL->BCL_DESCRI
		endIf

		aadd(aMatInf,{"TIPO DE GUIA",cDesc})
		aadd(aMatInf, {'ORIGEM' , iIf(cOrigem=='1','EXECUCAO','SOLICITACAO') } )

		aadd(aMatInf, {replicate('-',60) , "nil" } )
		aadd(aMatInf, {'CONTRATADO' , "nil" } )
		aadd(aMatInf, {'OPE. RDA' , cOpeMov } )
		aadd(aMatInf, {'COD. RDA' , cCodRda } )

		aadd(aMatInf, {'local ATENDIMENTO', cDesLocPro } )
		aadd(aMatInf, {'local DIGITACAO', BD5->BD5_CODLDP } )
		aadd(aMatInf, {'PROTOCOLO', BD5->BD5_CODPEG } )
		aadd(aMatInf, {'GUIA', BD5->BD5_NUMERO } )
		aadd(aMatInf, {'NUM. GUIA PRESTADOR ', cNumImp } )
		aadd(aMatInf, {'NUM. SOLICITACAO ', cNumSol } )

		aadd(aMatInf, {replicate('-',60) , "nil" } )

		aadd(aMatInf, {'MATRICULA' , cMatric } )
		aadd(aMatInf, {'NOME USU.' , upper(cNomUsrCar) } )
		aadd(aMatInf, {'VIA CARTÃO' , cViaCartao } )

		aadd(aMatInf, {'CID' , cCidPri } )
		if !empty(cCidPri)
			aadd(aMatInf, {replicate('-',60) , "nil" } )
		endIf

		nVAprTot := 0
		for nfor := 1 To len(aItens)
			nVlrApr	:= PLSRETDAD(aItens[nfor],"VLRAPR",0)
			nVAprTot+= nVlrApr
		next
		aadd(aMatInf, {'VALOR TOTAL APR', allTrim( str(nVAprTot) ) } )

		// Ponto de entrada para implementacao de mais informacoes para o log do xml
		if  existBlock("PLSXMINF")
			aMatInf := execBlock("PLSXMINF",.f.,.f.,{aDados,aItens,aMatInf} )
		endIf
	elseIf nRecBeaIni <> BEA->(recno()) .and. (lInter .and. !lEvolu)
		cAutRet := BEA->(BEA_OPEMOV+BEA_ANOINT+BEA_MESINT+BEA_NUMINT)
	elseIf lEvolu
		if cTGOriginal = '11'
			cAutRet := B4Q->(B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT)
		else
			cAutRet := BEA->(BEA_OPEMOV+BEA_ANOINT+BEA_MESINT+BEA_NUMINT)
		endIf
	elseIf lFindRes
		cAutRet := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
	elseIf nRecBeaIni <> BEA->(recno())
		cAutRet := BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)
	endIf

	// Se Ptu Online verifica informacacoes adicionais
	if lPtuOnline

		// Tipo de acomodacao que o beneficiario tem direito
		aadd(aMatInf,space(1)+"C")//Padrao nao se aplica

		if len(aDadUsr) > 0

			BI3->(dbSetOrder(1))//BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO
			if BI3->(msSeek(xFilial("BI3")+PlsIntPad()+aDadUsr[11]+aDadUsr[12]))
				BI4->(dbSetOrder(1))//BI4_FILIAL + BI4_CODACO
				if BI4->(msSeek(xFilial("BI4")+BI3->BI3_CODACO))
					aMatInf[1] := iIf(BI4->BI4_CODEDI == "2",space(1)+"A",space(1)+"B")
				endIf
			endIf

		endIf

		// Informa Data de Internacao
		if lInter .and. len(aEventosAut) > 0
			aArea := GetArea()
			PLSA92DtIn(.T.,Date(),left(Time(),5),.t.)
			lGerSenha := .t.
			RestArea(aArea)
		endIf
	endIf

	if lGerSenha .and. len(aDadUsr) > 44 .and. getNewPar("MV_PLSUNI","1") == "1" .and. (aDadUsr[45] <> PlsIntPad() .or. BEA->BEA_TIPPRE == getNewPar("MV_PLSTPIN","OPE"))

		dDatRet := dDatabase+getNewPar("MV_PLPRZPT",30)

		if lInter .and.  !empty(BE4->BE4_DATVAL)
			dDatRet := BE4->BE4_DATVAL
		elseIf !empty(BEA->BEA_VALSEN)
			dDatRet := BEA->BEA_VALSEN
		endIf

	else
		dDatRet := dDatabase+getNewPar("MV_PLPRZLB",30)
	endIf

	// Retorno
	aRetorno := {len(aEventosAut)>0,;																//1
		cAutRet,; 																			//2
		iIf((nRecBeaIni<>BEA->(recno()) .or. lFindRes .or. lEvolu) .and. !lHonor, iIf((lPTUONLINE),BEA->BEA_NRAOPE,BEA->BEA_SENHA),""),;//3
		aCriticas,;                                                                 		//4
		aEventosAut,;                                                               		//5
		aEventosNeg,;                                                               		//6
		nVlrTPF,;                                                                   		//7
		cRetCriMv,;                                                                 		//8
		cMsgClient,;                                                                		//9
		aMatInf,;                                                                     		//10
		lAto,;																				//11
		dDPrAH,;                                                                    		//12
		allTrim( str(nQtdDiAut) ),;                                                   		//13
		iIf(lGerSenha,dDatRet,ctod("")) ,;													//14
		"",;																				//15 - essa posição na versão 11 é utilizada.. na 12 está disponível
		lProRadio,;																			//16
		lAudi }																			//16
	// Se gera log caixa preta
	if lWLIO
		PlsLogFil(space(03)+replicate("-",60),__PLSFLOGX)
		PlsLogFil(space(03)+"VERSAO"+space(35-len("VERSAO"))+"["+cVersao+"]" ,__PLSFLOGX) //"-> Inicio da Transacao                   -> Data : "###" Hora : "

		if len(aEventosAut)>0
			if lResInt
				cMsg := " ORIGINAL"
			endIf
			PlsLogFil(space(03)+"AUTORIZACAO/LIBERACAO"+cMsg+space(35-len("AUTORIZACAO/LIBERACAO"+cMsg))+"["+aRetorno[2]+"]",__PLSFLOGX)
			PlsLogFil(space(03)+"CHAVE 1 C. MEDICAS"+space(35-len("CHAVE 1 C. MEDICAS"))+"["+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV)+"]",__PLSFLOGX)

			PlsLogFil(space(03)+"SENHA"+cMsg+space(35-len("SENHA"+cMsg))+"["+allTrim(aRetorno[3])+"]",__PLSFLOGX)
		endIf

		PlsLogFil(space(03)+"TRANSACAO"+space(35-len("TRANSACAO"))+"["+iIf( cOrigem=='1','EXECUCAO','SOLICITACAO')+"]",__PLSFLOGX)
		PLSLOGFIL(space(3)+"TIPO DE GUIA"+space(35-len("TIPO DE GUIA"))+"["+iIf(LEVOLU,"PRORROGACAO",iIf(LHONOR,"HONORARIO INDIVIDUAL",iIf(LRESINT,"RESUMO DE INTERNACAO",iIf(LINTER,"INTERNACAO",iIf(LCONSULTA,"CONSULTA",iIf(CTIPO=="4","ODONTOLOGICO","SADT"))))))+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"OPERACAO"+space(35-len("OPERACAO"))+"["+iIf( cTipoGrv=='1','REMOTE',iIf(cTipoGrv=='2','WEB',iIf(cTipoGrv=='3','POS','IMPORTACAO' ) ) )+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"INCLUIR NEG"+space(35-len("INCLUIR NEG"))+"["+iIf( lIncNeg,'SIM','NAO')+"] (SOMENTE PARA ALGUMAS CRITICAS DE ITEM)",__PLSFLOGX)
		PlsLogFil(space(03)+"LOAD DADRDA"+space(35-len("LOAD DADRDA"))+"["+iIf( lLoadRda,'SIM','NAO')+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"cTpLibToAut"+space(35-len("cTpLibToAut"))+"["+cTpLibToAut+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"cGuiaOri"+space(35-len("cGuiaOri"))+"["+cGuiaOri+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"TipGui"+space(35-len("TipGui"))+"["+cTipGui+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"lMatGer"+space(35-len("lMatGer"))+"["+if(lMatGer,"SIM","NAO")+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"lUsuGer"+space(35-len("lUsuGer"))+"["+if(lUsuGer,"SIM","NAO")+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"cMatUsa"+space(35-len("cMatUsa"))+"["+cMatUsa+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"cOpeOri"+space(35-len("cOpeOri"))+"["+cOpeOri+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"cRetGui"+space(35-len("cRetGui"))+"["+cRetGui+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"cSomInt"+space(35-len("cSomInt"))+"["+cSomInt+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"clocal RDA"+space(35-len("clocal RDA"))+"["+clocal+"."+cCodLoc+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"nVlrTPF"+space(35-len("nVlrTPF"))+"["+allTrim(str(nVlrTPF))+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"cCodEsp"+space(35-len("cCodEsp"))+"["+cCodEsp+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"cOriMov"+space(35-len("cOriMov"))+"["+cOriMov+"]",__PLSFLOGX)

		if !empty(cDesLocPro)
			PlsLogFil(space(03)+"clocal PROF"+space(35-len("clocal PROF"))+"["+left(cDesLocPro,7)+"]",__PLSFLOGX)
			PlsLogFil(space(03)+"cCodEspPro"+space(35-len("cCodEspPro"))+"["+cCodEspPro+"]",__PLSFLOGX)
		endIf

		if !lResInt
			PlsLogFil(space(03)+"lAprovLib"+space(35-len("lAprovLib"))+"["+if(lAprovLib,"SIM","NAO")+"]",__PLSFLOGX)
		endIf

		PlsLogFil(space(03)+"lRdaProf"+space(35-len("lRdaProf"))+"["+iIf(lRdaProf,"SIM","NAO")+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"lTrtExe"+space(35-len("lTrtExe"))+"["+iIf(lTrtExe,"SIM","NAO")+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"lTrtCCl"+space(35-len("lTrtCCl"))+"["+iIf(lTrtCCl,"SIM","NAO")+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"lOpe"+space(35-len("lOpe"))+"["+iIf(lUnimeds,"SIM","NAO")+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"lOPMM"+space(35-len("lOPMM"))+"["+iIf(lOPMM,"SIM","NAO")+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"lInter"+space(35-len("lInter"))+"["+iIf(lInter,"SIM","NAO")+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"lResInt"+space(35-len("lResInt"))+"["+iIf(lResInt,"SIM","NAO")+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"lEvolu"+space(35-len("lEvolu"))+"["+iIf(lEvolu,"SIM","NAO")+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"lHonor"+space(35-len("lHonor"))+"["+iIf(lHonor,"SIM","NAO")+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"lConsulta"+space(35-len("lConsulta"))+"["+iIf(lConsulta,"SIM","NAO")+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"lOdonto"+space(35-len("lOdonto"))+"["+iIf(cOriMov=="4","SIM","NAO")+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"lRetVPF"+space(35-len("lRetVPF"))+"["+iIf(lRetVPF,"SIM","NAO")+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"lReanaliza"+space(35-len("lReanaliza"))+"["+iIf(lReanaliza,"SIM","NAO")+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"lFindRes"+space(35-len("lFindRes"))+"["+iIf(lFindRes,"SIM","NAO")+"]",__PLSFLOGX)
		PlsLogFil(space(03)+"lOnLine"+space(35-len("lOnLine"))+"["+iIf(lOnLine,"SIM","NAO")+"]",__PLSFLOGX)

		// Log da transacao online
		if cOpeOri <> PLSINTPAD() .and. !empty(cOpeOri)
			PlsLogFil(space(03)+replicate("-",60),__PLSFLOGX)
			PlsLogFil(space(03)+"TRANSACAO DE INTERCAMBIO ENTRE OPERADORAS" ,__PLSFLOGX)
			PlsLogFil(space(03)+"ON-LINE"+space(35-len("ON-LINE"))+"["+iIf( lOnTLine,'SIM','NAO')+"] " ,__PLSFLOGX)
			PlsLogFil(space(03)+"SUCESSO TRAN."+space(35-len("SUCESSO TRAN."))+"["+iIf( lOnLine,'SIM','NAO')+"]" ,__PLSFLOGX)
			PlsLogFil(space(03)+"VEIO COMUNI"+space(35-len("VEIO COMUNI"))+"["+iIf( lVeioComu,'SIM','NAO')+"]" ,__PLSFLOGX)
			PlsLogFil(space(03)+"TRAN ORIGEM"+space(35-len("TRAN ORIGEM"))+"["+cNrSeqTR+"]" ,__PLSFLOGX)
			PlsLogFil(space(03)+"TRAN RETORNO"+space(35-len("TRAN RETORNO"))+"["+cSenhaOpe+"]" ,__PLSFLOGX)
			PlsLogFil(space(03)+"MENSAGEM"+space(35-len("MENSAGEM"))+"["+cMsg03+"]" ,__PLSFLOGX)
			PlsLogFil(space(03)+replicate("-",60),__PLSFLOGX)
			PlsLogFil(space(03)+"VALOR TOTAL PARTICIPACAO FINANCEIRA ["+allTrim(str(aRetorno[7],17,2))+"]",__PLSFLOGX)
			PlsLogFil(space(03)+"NUMERO DE CONTROLE NO ARQUIVO DE CRITICAS (BXE/BXF) ["+cRetCriMv+"]",__PLSFLOGX)
			PlsLogFil(space(03)+"MENSAGEM CLIENTE (OPCIONAL) ["+cMsgClient+"]",__PLSFLOGX)
			PlsLogFil("",__PLSFLOGX)
		endIf

		// Log
		if len(aCols)>0
			PlsLogFil("",__PLSFLOGX)
			PlsLogFil(space(03)+"ITENS NA MATRIZ ACOLS",__PLSFLOGX)

			for nI := 1 To len(aCols)
				cSeqMov 	:= aCols[nI,aScan(aHeader,{|x| allTrim(x[2]) == "BE2_SEQUEN"})]
				cCodPad 	:= aCols[nI,aScan(aHeader,{|x| allTrim(x[2]) == "BE2_CODPAD"})]
				cCodPro 	:= aCols[nI,aScan(aHeader,{|x| allTrim(x[2]) == "BE2_CODPRO"})]
				cHoraPro	:= aCols[nI,aScan(aHeader,{|x| allTrim(x[2]) == "BE2_HORPRO"})]
				cDente 		:= aCols[nI,aScan(aHeader,{|X| allTrim(x[2]) == "BE2_DENREG"})]
				cFace 		:= aCols[nI,aScan(aHeader,{|X| allTrim(x[2]) == "BE2_FADENT"})]

				PlsLogFil( space(03) + "SEQMOV ["+cSeqMov+"] CODPAD ["+cCodPad+"] CODPRO ["+cCodPro+"] HORPRO ["+cHoraPro+"] HORA ["+cHora+"] "+iIf(cTipo=="4"," DENTE ["+cDente+"] FACE ["+cFace+"] ",""),__PLSFLOGX)
			next

			PlsLogFil("",__PLSFLOGX)
		endIf
		// Log	eventos na acolslib
		if len(aColsLib)>0
			PlsLogFil(space(03)+"ITENS NA MATRIZ ACOLSLIB",__PLSFLOGX)
			for nI := 1 To len(aColsLib)
				cSeqMov 	:= aColsLib[nI,aScan(aHeaderLib,{|x| allTrim(x[2]) == "BE2_SEQUEN"})]
				cCodPad 	:= aColsLib[nI,aScan(aHeaderLib,{|x| allTrim(x[2]) == "BE2_CODPAD"})]
				cCodPro 	:= aColsLib[nI,aScan(aHeaderLib,{|x| allTrim(x[2]) == "BE2_CODPRO"})]
				cDente 		:= aColsLib[nI,aScan(aHeaderLib,{|X| allTrim(x[2]) == "BE2_DENREG"})]
				cFace 		:= aColsLib[nI,aScan(aHeaderLib,{|X| allTrim(x[2]) == "BE2_FADENT"})]

				PLSLOGFIL( space(3)+"SEQMOV ["+CSEQMOV+"] CODPAD ["+CCODPAD+"] CODPRO ["+ allTrim(CCODPRO)+"] "+iIf(CTIPO=="4"," DENTE ["+ allTrim(CDENTE)+"] FACE ["+ allTrim(CFACE)+"] ",""),__PLSFLOGX)
			next
			PlsLogFil("",__PLSFLOGX)
		endIf
		// Log	eventos autorizados
		if len(aEventosAut) > 0
			if lResInt
				PlsLogFil(space(03)+"EVENTOS ATUALIZADOS",__PLSFLOGX)
			else
				PlsLogFil(space(03)+"EVENTOS AUTORIZADOS",__PLSFLOGX)
			endIf
			PlsLogFil(space(03)+"SEQ  CODPAD  CODPRO    DESCRICAO                                               NQTDSOL",__PLSFLOGX)
			for nfor := 1 To len(aEventosAut)
				PlsLogFil(	space(03)+aEventosAut[nfor,1]+space(02)+;
					aEventosAut[nfor,2]+space(06)+;
					aEventosAut[nfor,3]+space(02)+;
					PadR(aEventosAut[nfor,5],54)+space(02)+;
					allTrim(str(aEventosAut[nfor,4],7,2)),__PLSFLOGX)
			next
			PlsLogFil("",__PLSFLOGX)
		endIf

		// Log	Eventos negados
		if len(aEventosNeg) > 0
			PlsLogFil("",__PLSFLOGX)
			if lResInt
				PlsLogFil(space(03)+"EVENTOS NAO ATUALIZADOS",__PLSFLOGX)
			else
				PlsLogFil(space(03)+"EVENTOS NEGADOS",__PLSFLOGX)
			endIf
			PlsLogFil(space(03)+"SEQ  CODPAD  CODPRO    DESCRICAO                                               NQTDSOL",__PLSFLOGX)
			for nfor := 1 To len(aEventosNeg)
				PlsLogFil(	space(03)+aEventosNeg[nfor,1]+space(02)+;
					aEventosNeg[nfor,2]+space(06)+;
					aEventosNeg[nfor,3]+space(02)+;
					PadR(aEventosNeg[nfor,5],54)+space(02)+;
					allTrim(str(aEventosNeg[nfor,4],7,2)),__PLSFLOGX)
			next
			PlsLogFil("",__PLSFLOGX)
		endIf

		// Log de criticas
		if len(aCriticas) > 0
			PlsLogFil(space(03)+"CRITICAS",__PLSFLOGX)
			PlsLogFil(space(03)+"SEQ  PROCEDIMENTO  CODIGO  CRITICA",__PLSFLOGX)
			for nfor := 1 To len(aCriticas)
				if ! empty(aCriticas[nfor,2])
					PlsLogFil(space(03)+aCriticas[nfor,1]+space(02)+;
						aCriticas[nfor,5]+space(06)+;
						aCriticas[nfor,2]+space(05)+;
						aCriticas[nfor,3]+space(02),__PLSFLOGX)
				else
					PlsLogFil(space(30)+aCriticas[nfor,3]+space(02),__PLSFLOGX)
				endIf
			next
			PlsLogFil("",__PLSFLOGX)
		elseIf len(aEventosNeg) > 0 .and. len(aCriticas) == 0
			PlsLogFil(space(03)+"CRITICADO MAIS NAO FOI ENCONTRADO CRITICA(S)",__PLSFLOGX)
			PlsLogFil("",__PLSFLOGX)
		endIf

		if len(aAutItens) > 0
			PlsLogFil(space(03)+"aAutItens",__PLSFLOGX)
			PlsLogFil(space(03)+"SEQ  CODPAD  CODPRO    NQTDSOL  (Dif. LIB - AUT)  recno  STATUS  LCOLSDEL  ITEJAEXECANT  ITEEXILIB  EXEC-PROF",__PLSFLOGX)
			for nfor := 1 To len(aAutItens)
				PlsLogFil(space(03) + aAutItens[nfor,1] 			+ space(02) +;
					aAutItens[nfor,2] 						+ space(06) +;
					aAutItens[nfor,3] 						+ space(02) +;
					allTrim( str(aAutItens[nfor,4]) )		+ space(08) +;
					allTrim( str(aAutItens[nfor,5],7,2) )	+ space(14) +;
					allTrim( str(aAutItens[nfor,7],10) ) 	+ space(06) +;
					iIf( aAutItens[nfor,6],"SIM","NAO" )	+ space(05) +;
					iIf( aAutItens[nfor,8],"SIM","NAO" )	+ space(07) +;
					iIf( aAutItens[nfor,10],"SIM","NAO" )	+ space(11) +;
					iIf( aAutItens[nfor,11],"SIM","NAO" ) 	+ space(08) +;
					iIf( aAutItens[nfor,12],"SIM","NAO" ) ,__PLSFLOGX )
			next
			PlsLogFil("",__PLSFLOGX)
		endIf
		// Log
		if len(aMatOPMM) > 0
			PlsLogFil("",__PLSFLOGX)
			PlsLogFil(space(03)+"ATENCAO INCLUSAO DE PROCEDIMENTOS SEM AUTORIZACAO",__PLSFLOGX)
			PlsLogFil(space(03)+"aMatOPMM - PARAMETRO MV_PLSOPMM",__PLSFLOGX)
			PlsLogFil(space(03)+"SEQ  CODPAD  CODPRO    NQTDSOL  (Dif. LIB - AUT)  recno  STATUS  LCOLSDEL",__PLSFLOGX)
			for nfor := 1 To len(aMatOPMM)
				PlsLogFil(space(03)+aMatOPMM[nfor,1]			+space(02)+;
					aMatOPMM[nfor,2]			   			+space(06)+;
					aMatOPMM[nfor,3]						+space(02)+;
					allTrim( str(aMatOPMM[nfor,4]) )		+space(08)+;
					allTrim( str(aMatOPMM[nfor,5],7,2) )	+space(14)+;
					allTrim( str(aMatOPMM[nfor,7],10) )	+space(06)+;
					iIf(aMatOPMM[nfor,6],"SIM","NAO")		+space(05)+;
					iIf(aMatOPMM[nfor,8],"SIM","NAO"),__PLSFLOGX)
			next
			PlsLogFil("",__PLSFLOGX)
		endIf
		PlsLogFil("",__PLSFLOGX)
		PlsLogFil(space(3)+"FIM DA TRANSAÇÃO. ( INICIO ["+DtoC(Date())+"-"+cHoraBase+"] DURAÇÃO ["+allTrim(str(Seconds()-nHoraBase,12,3))+"] SEGUNDOS )",__PLSFLOGX)
		PlsLogFil("",__PLSFLOGX)
	endIf

return(aRetorno)

/*/{Protheus.doc} PLSMONCRI
Alimenta criticas
@type function
@author Alexander
@since 06.12.07
@version 1.0
/*/
function PLSMONCRI(aItens,aTrb,lTp,cCodCri,cCritic,cDescAux,aCriticas,aEventosNeg)
	local nfor,nfor2
	local cSeqMov := ""
	local cCodPad := ""
	local cCodPro := ""
	local cDescri := ""
	local nQtdSol := 0

	// for
	for nfor2 := 1 To len(aItens)
		cSeqMov := PLSRETDAD(aItens[nfor2],"SEQMOV")
		cCodPad := PLSRETDAD(aItens[nfor2],"CODPAD")
		cCodPro := PLSRETDAD(aItens[nfor2],"CODPRO")
		cDescri	:= PLSRETDAD(aItens[nfor2],"DESCRI","")
		nQtdSol := PLSRETDAD(aItens[nfor2],"QTD",0)
		nQtdAut := PLSRETDAD(aItens[nfor2],"QTDAUT",0)
		cDente 	:= PLSRETDAD(aItens[nfor2],"DENTE","")
		cFace  	:= PLSRETDAD(aItens[nfor2],"FACE","")
		cSlvPad := PLSRETDAD(aItens[nfor2],"SLVPAD","")
		cSlvPro := PLSRETDAD(aItens[nfor2],"SLVPRO","")
		// Critica
		if lTp
			if len(aTrb)>0
				for nfor := 1 To len(aTrb)
					aadd( aCriticas,{cSeqMov,aTrb[nfor,1],aTrb[nfor,2]+iIf(len(aTrb[nfor])>=3 .and. !empty(aTrb[nfor,3]),' ( '+aTrb[nfor,3]+' ) ',''),cCodPad,cCodPro,cDente,cFace} )
				next
			endIf
		else
			if !empty(cDescAux)
				aadd( aCriticas,{cSeqMov,cCodCri,cDescAux,cCodPad,cCodPro,cDente,cFace} )
			else
				aadd( aCriticas,{cSeqMov,cCodCri,cCritic,cCodPad,cCodPro,cDente,cFace} )
			endIf
		endIf
		// Eventos
		if valType(aEventosNeg) == 'A'
			if aScan(aEventosNeg,{|x| allTrim(x[1]+x[2]+x[3]+x[7]+x[8]) == allTrim(cSeqMov+cCodPad+cCodPro+cDente+cFace) } ) == 0
				aadd(aEventosNeg,{cSeqMov,cCodPad,cCodPro,nQtdSol,cDescri,nQtdAut,cDente,cFace,"",cSlvPad,cSlvPro})
			endIf
		endIf
	next

return

/*/{Protheus.doc} PLSXEXCA
Exclui uma autorizacao a partir de seu numero
@type function
@author Tulio Cesar
@since 06.02.04
@version 1.0
/*/
function PLSXEXCA(cNumeroAut,cTipExc)
	local nI       := 0
	local aCols    := {}
	local aHeader  := PLSA090Hea(cTipExc)
	local aVetTrab := {}
	local aCabCri  := {}
	local aDadCri  := {}
	local aTrbCri  := {}
	local aRet     := {.f.,"","","","",.f.,"","",.f.}
	local aMatExe  := {}
	local cNumAut  := ""
	private inclui := .f.

	Default cTipExc := "" // Tipo para retornar os campos no aHeader, 1 = Autorização e 2 = Liberação

	if at(',',cNumeroAut) > 0
		while (nPos := at(',',cNumeroAut)) > 0
			cNumAut    := allTrim(subStr(cNumeroAut,1,nPos-1))
			cNumeroAut := allTrim(subStr(cNumeroAut,nPos+1,len(cNumeroAut)))
			aadd(aMatExe,cNumAut)
		endDo
	endIf
	// Pega o ultimo ou o unico
	aadd(aMatExe,allTrim(cNumeroAut))
	// Processa
	BEA->(dbSetOrder(1))

	for nI := 1 To len(aMatExe)

		cNumeroAut := aMatExe[nI]

		if BEA->(msSeek(xFilial("BEA")+cNumeroAut))

			Store Header "BEG" TO aCabCri for .t.

			BEG->(dbSetOrder(1))
			if ! BEG->(msSeek(xFilial("BEG")+cNumeroAut))
				Store COLS Blank "BEG" TO aDadCri FROM aCabCri
			else
				Store COLS "BEG" TO aDadCri FROM aCabCri VETTRAB aTrbCri while xFilial("BEG")+cNumeroAut == BEG->(BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT)
			endIf

			// Alimenta matriz
			PLSA090MDa(BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT),"1",aHeader,aVetTrab,aCols)

			// Gravacao
			aRet := PLSA090Grv(	aClone(aCols),aClone(aHeader),{},K_Excluir,aClone(aVetTrab),{},"",ctod(""),"","","","",BEA->BEA_TIPGUI,.f.,;
				aDadCri,aCabCri,aTrbCri,nil,BEA->BEA_ORIGEM,BEA->BEA_CODLDP,/*lReanaliza*/,;
				/*cFiltro*/,/*cKey*/,/*lforBloq*/,/*lVeioComu*/,/*lNMudFase*/,/*cAliasIte*/,/*cAliasCri*/,/*lAjusta*/,/*lEvolu*/,/*aDadBE4*/,;
				/*lGerSenha*/,/*lWeb*/,/*aDadB43*/,/*aCabB43*/,/*aTrbB43*/,/*oBrwEven*/,/*lExcluiAte*/,/*oBrwB47*/,/*cAliasCab*/,;
				/*lReembolso*/,/*oBrwB46*/,/*oBrwB44*/,/*lIncNeg*/,/*cObsoleto*/,/*lSolicit*/,/*cTpGrv*/,/*aColsDF*/,/*aHeaderDF*/,;
				/*aVetDF*/,/*aDaSenPro*/,/*lGuiHoRe*/,/*aMatBd6*/,/*aMatCom*/,/*lResInt*/,/*cAliasCmp*/,/*lOdontoWeb*/,/*cNumLib*/,;
				/*cArqImp*/,/*lEvoSadt*/,/*cSituac*/,/*lProtoc*/,/*aPartic*/)

			lProRadio 	:= aRet[12]
			lAudi 		:= aRet[9]

		endIf

	next

return aRet[1]

/*/{Protheus.doc} PLSLISEST
Devolve todos os estados a partir de uma operadora
@type function
@author Tulio Cesar
@since 02.07.04
@version 1.0
/*/
function PLSLISEST(cCodOpe)
	local aRetorno 	:= {}
	local lUnimeds	:= if( allTrim(getNewPar("MV_PLSUNI","1") )=="1",.t.,.f.)
	LOCAL nContSX5  := 0
	LOCAL nI		:= 0
	LOCAL aSX5		:= {}

	if lUnimeds
		BA0->(dbSetOrder(1))
		if BA0->(msSeek(xFilial("BA0")+cCodOpe))
			aadd(aRetorno,BA0->BA0_EST)
		endIf
	else
		aSX5 	 := FWGetSX5("12")
		nContSX5 := len(aSX5)

		If nContSX5 > 0

			For nI := 1 To nContSX5
				AaDd(aRetorno,allTrim(aSX5[nI][3]))
			Next

		EndIf

	endIf

	if len(aRetorno) == 0
		aRetorno := {""}
	endIf

return(aRetorno)

/*/{Protheus.doc} PLSLISESP
Devolve todas as especialidades a partir de uma operadora
@type function
@author Tulio Cesar
@since 02.07.04
@version 1.0
/*/
function PLSLESP(cCodOpe,cEstado)
	local aRetorno := {}
	local cSQL := ""

	cSQL += "SELECT DISTINCT BAQ.BAQ_CODESP, BAQ.BAQ_DESCRI "
	cSQL += "FROM "+RetSQLName("BAQ")+" BAQ "

	cSQL += "INNER JOIN "+RetSQLName("BAX")+" BAX "
	cSQL += "ON BAQ_CODINT = BAX_CODINT "
	cSQL += "AND BAQ_CODESP = BAX_CODESP "

	cSQL += "WHERE BAQ_FILIAL = '"+xFilial("BAQ")+"' AND "
	cSQL += "BAX_FILIAL = '"+xFilial("BAX")+"' AND "
	cSQL += "BAX_CODINT = '"+cCodOpe+"' AND "
	cSQL += "BAX.D_E_L_E_T_ = ' ' "

	if existBlock("PLORDESP")
		cSQL += execBlock("PLORDESP",.f.,.f.)
	else
		cSQL += "ORDER BY BAQ.BAQ_CODESP "
	endIf

	PLSQuery(cSQL,"TrbPls")

	aadd(aRetorno,__cTextoAll)

	while ! TrbPls->(eof())
		aadd(aRetorno,TrbPls->BAQ_CODESP+"-"+TrbPls->BAQ_DESCRI)
		TrbPls->(dbSkip())
	endDo
	TrbPls->(dbCloseArea())

	if len(aRetorno) == 1
		aRetorno := {""}
	endIf

return(aRetorno)

/*/{Protheus.doc} PLSLISMUN
Devolve todos os municipios a partir de uma espec. + estado
@type function
@author Tulio Cesar
@since 02.07.04
@version 1.0
/*/
function PLSLISMUN(cCodOpe,cCodEsp,cEstado,cCodMun,lInverte)
	local aRetorno   := {}
	local cSQL		 := ""
	local cMVPLSRDAG := getNewPar("MV_PLSRDAG","999999")
	local lFlag      := .f.
	default cCodMun  := ""
	default lInverte := .f.

	if empty(cCodMun)
		cSQL := "SELECT DISTINCT BB8_CODMUN FROM "+RetSQLName("BAX")+", "+RetSQLName("BB8")+" WHERE "
	else
		cSQL := "SELECT DISTINCT BB8_BAIRRO FROM "+RetSQLName("BAX")+", "+RetSQLName("BB8")+" WHERE "
	endIf
	cSQL += "BB8_FILIAL = '"+xFilial("BB8")+"' AND "
	cSQL += "BB8_CODINT = '"+cCodOpe+"' AND "
	cSQL += "BAX_FILIAL = '"+xFilial("BAX")+"' AND "
	cSQL += "BAX_CODINT = '"+cCodOpe+"' AND "
	if subs(cCodEsp,1,3) <> Subs(__cTextoAll,1,3)
		cSQL += "BAX_CODESP = '"+subs(cCodEsp,1,3)+"' AND "
	endIf
	cSQL += "BB8_EST    = '"+cEstado+"' AND "

	if ! empty(cCodMun)
		if subs(cCodMun,1,7) <> Subs(__cTextoAll,1,7)
			cSQL += "BB8_CODMUN = '"+cCodMun+"' AND "
		endIf
	endIf

	cSQL += "BB8_DATBLO = '"+space(8)+"' AND "

	cSQL += "BB8_CODIGO = BAX_CODIGO AND "
	cSQL += "BB8_CODINT = BAX_CODINT AND "
	cSQL += "BB8_CODIGO <> '"+cMVPLSRDAG+"' AND "
	cSQL += RetSQLName("BB8")+".D_E_L_E_T_ = ' ' AND "
	cSQL += RetSQLName("BAX")+".D_E_L_E_T_ = ' '"

	PLSQuery(cSQL,"TrbPls")

	aadd(aRetorno,__cTextoAll)

	while ! TrbPls->(eof())

		lFlag := .t.

		if empty(cCodMun)
			BID->(dbSetOrder(1))
			if BID->(msSeek(xFilial("BID")+TrbPls->BB8_CODMUN))
				if lInverte
					aadd(aRetorno,allTrim(BID->BID_DESCRI)+"-"+BID->BID_CODMUN)
				else
					aadd(aRetorno,BID->BID_CODMUN+"-"+allTrim(BID->BID_DESCRI))
				endIf
			endIf
		else
			aadd(aRetorno,TrbPls->BB8_BAIRRO)
		endIf

		TrbPls->(dbSkip())
	endDo
	TrbPls->(dbCloseArea())

	if ! lFlag
		aRetorno := {""}
	endIf

	if lInverte
		aSort(aRetorno)
	endIf

return(aRetorno)

/*/{Protheus.doc} PLSLISRDA
Devolve todas as RDAS
@type function
@author Tulio Cesar
@since 02.07.04
@version 1.0
/*/
function PLSLISRDA(cCodOpe,cCodEsp,cEstado,cCodMun,cBairro,cProduto,cVersao,lFiltRDA)
	local aRetorno   := {}
	local cSQL
	local cMVPLSRDAG := getNewPar("MV_PLSRDAG","999999")
	local nPos
	local lGrava
	default cCodMun  := ""
	default cProduto := ""
	default cVersao  := ""
	default lFiltRDA := .f.

	cSQL := "SELECT BB8_CODIGO, BB8_CODLOC, BAX_CODESP FROM "+RetSQLName("BAX")+", "+RetSQLName("BB8")+", "
	cSql += RetSqlName("BAU") +" WHERE  "
	cSQL += "BB8_FILIAL = '"+xFilial("BB8")+"' AND "
	cSQL += "BB8_CODINT = '"+cCodOpe+"' AND "
	cSQL += "BAX_FILIAL = '"+xFilial("BAX")+"' AND "
	cSQL += "BAX_CODINT = '"+cCodOpe+"' AND "
	if subs(cCodEsp,1,3) <> Subs(__cTextoAll,1,3)
		cSQL += "BAX_CODESP = '"+subs(cCodEsp,1,3)+"' AND "
	endIf
	cSQL += "BB8_EST    = '"+cEstado+"' AND "
	if subs(cCodMun,1,7) <> Subs(__cTextoAll,1,7)
		cSQL += "BB8_CODMUN = '"+cCodMun+"' AND "
	endIf
	if allTrim(cBairro) <> __cTextoAll
		cSQL += "BB8_BAIRRO = '"+cBairro+"' AND "
	endIf

	cSQL += "BB8_DATBLO = '" +space(8)+ "' AND "
	cSQL += "BB8_CODIGO = BAX_CODIGO AND "
	cSQL += "BB8_CODINT = BAX_CODINT AND "
	cSQL += "BB8_CODLOC= BAX_CODLOC AND "
	cSQL += "BB8_GUIMED = '1' AND "
	cSQL += "BAX_GUIMED = '1' AND "
	cSQL += "BAU_FILIAL='"+xFilial("BAU")+"' AND "
	cSQL += "BAU_CODIGO = BB8_CODIGO AND "
	cSQL += "BAU_GUIMED <> '0' AND "
	cSQL += "(BAU_CODOPE='"+cCodOpe+"' OR BAU_CODOPE='"+space(len(BAU->BAU_CODOPE))+"') AND "
	cSQL += RetSQLName("BB8")+".D_E_L_E_T_ = ' ' AND "
	cSQL += RetSQLName("BAX")+".D_E_L_E_T_ = ' ' AND "
	cSQL += RetSQLName("BAU")+".D_E_L_E_T_ = ' '  "
	PLSQuery(cSQL,"TrbPls")

	while ! TrbPls->(eof())

		if cMVPLSRDAG == TrbPls->BB8_CODIGO
			TrbPls->(dbSkip())
			loop
		endIf

		BAU->(dbSetOrder(1))
		if BAU->(msSeek(xFilial("BAU")+TrbPls->BB8_CODIGO)) .and. empty(BAU->BAU_CODBLO)
			lGrava := .t.
			if lFiltRDA
				BBI->(dbSetOrder(1))

				lCond := BBI->(msSeek(xFilial("BBI")+BAU->BAU_CODIGO+cCodOpe+TrbPLS->BB8_CODLOC+TrbPLS->BAX_CODESP+cProduto+cVersao))

				if lCond
					if BBI->BBI_ATIVO == "0"
						lGrava := .f.
					endIf
				endIf
			endIf

			if lGrava
				nPos := aScan(aRetorno,{ |x| x[1] == BAU->BAU_CODIGO .and. x[3] == TrbPls->BB8_CODLOC .and. x[4] == TrbPls->BAX_CODESP})
				if  nPos == 0
					aadd(aRetorno,{BAU->BAU_CODIGO,BAU->BAU_NOME,TrbPls->BB8_CODLOC,TrbPls->BAX_CODESP})
				endIf
			endIf
		endIf

		TrbPls->(dbSkip())
	endDo
	TrbPls->(dbCloseArea())

	if len(aRetorno) == 0
		aRetorno := {}
	endIf

return(aRetorno)

/*/{Protheus.doc} PLSLISBAI
Devolve todos os bairros
@type function
@author Tulio Cesar
@since 02.07.04
@version 1.0
/*/
function PLSLISBAI(cCodOpe,cCodEsp,cEstado,cMunicipio)
	local aRetorno := {}

	aRetorno := PLSLISMUN(cCodOpe,cCodEsp,cEstado,cMunicipio)

	if len(aRetorno) == 0
		aRetorno := {""}
	endIf

return(aRetorno)

/*/{Protheus.doc} PLSGETERDA
Valida a senha da rede de atendimento
@type function
@author Tulio Cesar
@since 06.07.04
@version 1.0
/*/
function PLSGETERDA(cOpeRda,cCodRda,cAno,cMes,cFase)
	local cSQL
	local aRet   := {}
	local nfor
	local aStruc := {}
	local cAux

	local aHeaMv := {}
	local aMovto := {}

	local aHeaDCF := {}
	local aDCFixo := {}

	local aHeaDCV := {}
	local aDCVar  := {}

	local aHeaAP  := {}
	local aAP     := {}
	default cFase := "3"
	// Movimentos - BD7    ***     Movimentos - BD7    ***     Movimentos - BD7
	cAux   := ""
	aStruc := BD7->(DbStruct())
	for nfor := 1 To len(aStruc)
		aadd(aHeaMv,aStruc[nfor,1])
		cAux += aStruc[nfor,1]+","
	next
	cAux := Subs(cAux,1,len(cAux)-1)
	cSQL := "SELECT "
	cSQL += cAux
	cSQL += " FROM "+RetSQLName("BD7")+" WHERE "
	cSQL += "BD7_FILIAL = '"+xFilial("BD7")+"' AND "
	cSQL += "BD7_CODOPE = '"+cOpeRda+"' AND "
	cSQL += "BD7_ANOPAG = '"+cAno+"' AND "
	cSQL += "BD7_MESPAG = '"+cMes+"' AND "
	cSQL += "BD7_SITUAC = '1' AND "
	cSQL += "BD7_FASE   = '"+cFase+"' AND "
	cSQL += "BD7_CODRDA = '"+cCodRda+"' AND "
	cSQL += "D_E_L_E_T_ = ' '"
	cSQL += "ORDER BY BD7_FILIAL,BD7_CODOPE,BD7_CODLDP,BD7_CODPEG,BD7_NUMERO,BD7_ORIMOV"

	PLSQuery(cSQL,"PlsTrb")

	while ! PlsTrb->(eof())

		aadd(aMovto,{})
		for nfor := 1 To len(aHeaMv)
			aadd(aMovto[len(aMovto)],&("PlsTrb->"+aHeaMv[nfor]))
		next

		PlsTrb->(dbSkip())
	endDo

	PlsTrb->(dbCloseArea())
	// Debitos Creditos Mensais Fixos - BBC *** Debitos Creditos Mensais Fixos - BBC
	aStruc := BBC->(DbStruct())
	for nfor := 1 To len(aStruc)
		aadd(aHeaDCF,aStruc[nfor,1])
	next

	BBC->(dbSetOrder(2))
	if BBC->(msSeek(xFilial("BBC")+cCodRda+"11"))

		while ! BBC->(eof()) .and. BBC->(BBC_FILIAL+BBC_CODIGO+BBC_STATUS+BBC_PROMED) == xFilial("BBC")+cCodRda+"11"

			if ! ( cAno + cMes + "01" >= DtoS(BBC->BBC_VLDINI) .and. ;
					(DtoS(LastDay(ctod("01/"+cMes+"/"+cAno))) <= DtoS(BBC->BBC_VLDFIM) .or. empty(BBC->BBC_VLDFIM)) )
				BBC->(dbSkip())
				loop
			endIf

			aadd(aDCFixo,{})
			for nfor := 1 To len(aHeaDCF)
				aadd(aDCFixo[len(aDCFixo)],&("BBC->"+aHeaDCF[nfor]))
			next
			BBC->(dbSkip())
		endDo

	endIf
	// Debitos Creditos Mensais Variaveis - BGQ ***
	aStruc := BGQ->(DbStruct())
	for nfor := 1 To len(aStruc)
		aadd(aHeaDCV,aStruc[nfor,1])
	next

	BGQ->(dbSetOrder(2))
	if BGQ->(msSeek(xFilial("BGQ")+cCodRda+cAno+cMes+cOpeRda))

		while ! BGQ->(eof()) .and. BGQ->(BGQ_FILIAL+BGQ_CODIGO+BGQ_ANO+BGQ_MES+BGQ_CODOPE) == xFilial("BGQ")+cCodRda+cAno+cMes+cOpeRda

			if ( cFase == "3" .and. ! empty(BGQ->BGQ_NUMCOB) ) .or. ;
					( cFase == "4" .and. empty(BGQ->BGQ_NUMCOB) )
				BGQ->(dbSkip())
				loop
			endIf

			aadd(aDCVar,{})
			for nfor := 1 To len(aHeaDCV)
				aadd(aDCVar[len(aDCVar)],&("BGQ->"+aHeaDCV[nfor]))
			next
			BGQ->(dbSkip())
		endDo

	endIf
	// Apontamentos producao medica - BCE ***
	aStruc := BCE->(DbStruct())
	for nfor := 1 To len(aStruc)
		aadd(aHeaAP,aStruc[nfor,1])
	next

	BCE->(dbSetOrder(2))
	if BCE->(msSeek(xFilial("BCE")+cCodRda+cOpeRda+cAno+cMes))

		while ! BCE->(eof()) .and. BCE->(BCE_FILIAL+BCE_CODIGO+BCE_CODINT+BCE_ANOPAG+BCE_MESPAG) == xFilial("BCE")+cCodRda+cOpeRda+cAno+cMes

			if ( cFase == "3" .and. ! empty(BCE->BCE_NUMLOT) ) .or. ;
					( cFase == "4" .and. empty(BCE->BCE_NUMLOT) )
				BCE->(dbSkip())
				loop
			endIf

			aadd(aAP,{})
			for nfor := 1 To len(aHeaAP)
				aadd(aAP[len(aAP)],&("BCE->"+aHeaAP[nfor]))
			next
			BCE->(dbSkip())
		endDo

	endIf
	// Posiciona na RDA
	BAU->(dbSetOrder(1))
	BAU->(msSeek(xFilial("BAU")+cCodRda))

	// Monta retorno da funcao
	aRet := { {aMovto,aHeaMv} , {aDCFixo,aHeaDCF} , {aDCVar,aHeaDCV}, {aAP,aHeaAP} }

return(aRet)

/*/{Protheus.doc} PLSVLDSUSR
Valida a senha do beneficiario.
@type function
@author Tulio Cesar
@since 15.07.04
@version 1.0
/*/
function PLSVLDSUSR(cMatricUsr,cSenhaPLS)
	local lRet := .f.

	BA1->(dbSetOrder(2))
	if BA1->(msSeek(xFilial("BA1")+cMatricUsr)) .and. empty(BA1->BA1_MOTBLO)
		BA3->(dbSetOrder(1))
		if BA3->(msSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC))) .and. empty(BA3->BA3_MOTBLO)
			lRet := .t.
		endIf
	endIf

return(lRet)

/*/{Protheus.doc} PLSGETMOV
Retorna os movimentos do usuario com base em parametros
@type function
@author Tulio Cesar
@since 20.07.04
@version 1.0
/*/
function PLSGETMOV(cMatric,nPeriodo,aCampos,nLimite)
	local cSQL
	local aRet  := {}
	local nCont := 0
	local nfor

	default nPeriodo := 0
	default aCampos  := {}
	default nLimite  := {}

	// Se nao passou nenhum campo devolve vazio
	if len(aCampos) == 0
		return(aRet)
	endIf

	// Busca os eventos na base de dados
	cSQL := "SELECT * FROM "+RetSQLName("BD6")+" WHERE "
	cSQL += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
	cSQL += "BD6_OPEUSR = '"+Subs(cMatric,atCodOpe[1],atCodOpe[2])+"' AND "
	cSQL += "BD6_CODEMP = '"+Subs(cMatric,atCodEmp[1],atCodEmp[2])+"' AND "
	cSQL += "BD6_MATRIC = '"+Subs(cMatric,atMatric[1],atMatric[2])+"' AND "
	cSQL += "BD6_TIPREG = '"+Subs(cMatric,atTipReg[1],atTipReg[2])+"' AND "
	// Se foi passado o periodo busca no periodo dos eventos
	if nPeriodo > 0
		cSQL += "BD6_DATPRO >= '"+dtos((dDataBase-nPeriodo))+"' AND "
	endIf

	cSQL += "( BD6_FASE = '3' OR BD6_FASE = '4' ) AND "
	cSQL += "BD6_SITUAC = '1' AND "
	cSQL += "D_E_L_E_T_ = '' "
	cSQL += "ORDER BY BD6_FILIAL, BD6_DATPRO"

	PLSQuery(cSQL,"PLSGETMOV")

	while ! PLSGETMOV->(eof())
		nCont ++

		aadd(aRet,{})
		for nfor := 1 To len(aCampos)
			aadd(aRet[len(aRet)],&("BD6->"+aCampos[nfor]))
		next

		if nLimite > 0 .and. nCont > nLimite
			Exit
		endIf

		PLSGETMOV->(dbSkip())
	endDo

	PLSGETMOV->(dbCloseArea())

return(aRet)

/*/{Protheus.doc} PLSRtLimCH
@type function
@author Tulio Cesar
@since 26.05.07
@version 1.0
/*/
function PLSRtLimCH(cOpeOri,dDatPro)
	local cGruOpe   := ""
	local cCodTab   := ""
	local nOrdBA0   := BA0->(indexOrd())
	local nRecBA0   := BA0->(recno())
	local nLimCH    := getNewPar("MV_PLSLMCH",300)
	local cTipLim   := getNewPar("MV_PLSTPLM","1")
	local cNivelVld := ""
	local lContinua := .t.
	default dDatPro := dDataBase

	BA0->(dbSetOrder(1))
	BA0->(msSeek(xFilial("BA0")+cOpeOri))
	cGruOpe := BA0->BA0_GRUOPE
	cCodTab := BA0->BA0_CODTAB

	if ( BA0->BA0_LIMCH > 0 ) .or. ( BA0->BA0_LIMCH == 0 .and. BA0->BA0_NIVVAL == "1" )
		nLimCH    := BA0->BA0_LIMCH
		cNivelVld := BA0->BA0_NIVVAL
		lContinua := .f.

		if ! empty(BA0->BA0_TIPLIM)
			cTipLim := BA0->BA0_TIPLIM
		endIf
	endIf

	BA0->(dbSetOrder(nOrdBA0))
	BA0->(dbGoto(nRecBA0))

	if lContinua
		BGH->(dbSetOrder(1))
		if BGH->(msSeek(xFilial("BGH")+cGruOpe))
			while ! BGH->(eof()) .and. BGH->(BGH_FILIAL+BGH_GRUOPE) == xFilial("BGH")+cGruOpe

				if ( dtos(dDatPro) >= dtos(BGH->BGH_DATINI) ) .and. ( dtos(dDatPro) <= dtos(BGH->BGH_DATFIN) .or. empty(BGH->BGH_DATFIN) )

					if BGH->BGH_LIMCH > 0

						nLimCH := BGH->BGH_LIMCH

						if ! empty(BGH->BGH_TIPLIM)
							cTipLim := BGH->BGH_TIPLIM
						endIf

					endIf

				endIf

				BGH->(dbSkip())
			endDo
		endIf

	endIf

return({nLimCH,cCodTab,cNivelVld,cTipLim})

/*/{Protheus.doc} PLSRtQtdCH
(long_description)
@type function
@author Tulio Cesar
@since 26.05.07
@version 1.0
/*/
function PLSRtQtdCH(cCodTab,cCodPad,cCodPro,cOpeMov,dData,cProRel,nPrPrRl,lRetCoC,cAno,cMes)
	local aCompo
	local nQtdCH    := 0
	local nQtdVlr   := 0
	local nfor2
	local nUSMensal := 0
	local nOrdBFM   := BFM->(indexOrd())
	local nRecBFM   := BFM->(recno())
	local nOrdBW4   := BW4->(indexOrd())
	local nRecBW4   := BW4->(recno())
	local nVlrPad	:= 0
	local bRest     := { || BFM->(dbGoto(nRecBFM)), BFM->(dbSetOrder(nOrdBFM)), BW4->(dbGoto(nRecBW4)), BW4->(dbSetOrder(nOrdBW4)) }
	default cCodTab := ""
	default lRetCoC := .f.
	default cProRel := ""
	default nPrPrRl := 0
	default cAno    := subs(dtos(dData),1,4)
	default cMes    := subs(dtos(dData),5,2)

	if Type("dDatAnalise") == "U"
		dDatAnalise := dData
	endIf

	BFM->(dbSetOrder(1))
	if BFM->(msSeek(xFilial("BFM")+cOpeMov+cAno+cMes))
		nUSMensal := BFM->BFM_VALRDA
	endIf

	if empty(cProRel)
		aCompo := PLSCOMEVE(cCodTab,cCodPad,cCodPro,PLSINTPAD(),dData,nil,lRetCoC)
	else
		aCompo := PLSCOMEVE(cCodTab,cCodPad,cProRel,PLSINTPAD(),dData,nil,lRetCoC)
	endIf

	for nfor2 := 1 To len(aCompo)
		if     allTrim(aCompo[nfor2,6]) $ "PLSRETCH"

			if empty(aCompo[nfor2,12]) // Nao e em porte medico (CBHPM)
				if nPrPrRl == 0
					nQtdCH  += aCompo[nfor2,3]
					nQtdVlr += round(aCompo[nfor2,3]*nUSMensal,2)
				else
					nQtdCH  += round((round(aCompo[nfor2,3]*nPrPrRl,2))/100,2)
					nQtdVlr += round(((round(aCompo[nfor2,3]*nUSMensal,2))*nPrPrRl)/100,2)
				endIf
			else
				if empty(cCodTab)
					if len(aCompo[nfor2]) >= 15
						cCodTab := aCompo[nfor2,15]
					else
						cCodTab := ""
					endIf
				endIf

				BW4->(dbSetOrder(1))
				if BW4->(msSeek(xFilial("BW4")+cOpeMov+cCodTab+aCompo[nfor2,12]))

					while BW4->BW4_CODOPE == cOpeMov .and. BW4->BW4_CODTAB == cCodTab .and. BW4->BW4_PORTE == aCompo[nfor2,12]

						if ( ( dtos(dDatAnalise) >= dtos(BW4->BW4_VIGINI) ) .and. ;
								( dtos(dDatAnalise) <= dtos(BW4->BW4_VIGFIN) .or. empty(BW4->BW4_VIGFIN) ) ) .or. ;
								( !empty(BW4->BW4_VIGINI) .and. !empty(BW4->BW4_VIGFIN) )

							if PLSINTval("BW4",'BW4_VIGINI','BW4_VIGFIN',dDatAnalise)

								if nPrPrRl == 0
									nQtdCH  += round(BW4->BW4_VLRREA/nUSMensal,2)
									nQtdVlr += BW4->BW4_VLRREA
								else
									nQtdCH  += round(((round(BW4->BW4_VLRREA/nUSMensal,2))*nPrPrRl)/100,2)
									nQtdVlr += round((round(BW4->BW4_VLRREA*nPrPrRl,2))/100,2)
								endIf

							endIf
						elseIf  BW4->BW4_VIGINI == ctod(" / / ") .and. BW4->BW4_VIGFIN == ctod(" / / ") .and. nVlrPad == 0
							nVlrPad := BW4->BW4_VLRREA
						endIf
						BW4->(dbSkip())
					endDo
				endIf
			endIf
		elseIf allTrim(aCompo[nfor2,6]) $ "PLSRETREA,PLSCALRCC"
			if nPrPrRl == 0
				nQtdCH  += round(aCompo[nfor2,3]/nUSMensal,2)
				nQtdVlr += aCompo[nfor2,3]
			else
				nQtdCH  += round(((round(aCompo[nfor2,3]/nUSMensal,2))*nPrPrRl)/100,2)
				nQtdVlr += round(((aCompo[nfor2,3])*nPrPrRl)/100,2)
			endIf
		elseIf allTrim(aCompo[nfor2,6]) $ "PLSRETCRR,PLSCALDP,PLSRETIN,PLSRETTCR,PLSRETUCO,PLSRETM2,PLSRETPA,PLSRETAUX"
			//TODO - Nao foi elaborado ainda uma forma de achar a quantidade de CH a partir dessas unidades
		endIf
	next

	eval(bRest)

return({nQtdCH,nQtdVlr})

/*/{Protheus.doc} PLSWLIO
Log Caixa Preta
@type function
@author Tulio Cesar
@since 26.05.07
@version 1.0
/*/
function PLSWLIO(aDad,aIte)
	local nI := 0

	// Log
	PlsLogFil(space(03)+replicate("*",90),__PLSFLOGX)
	PlsLogFil(space(03)+"CABEÇALHO",__PLSFLOGX)
	PlsLogFil(space(03)+replicate("*",90),__PLSFLOGX)

	for nI := 1 To len(aDad)

		if valType(aDad[nI,2]) <> 'A'
			cCampo 	  := aDad[nI,1]
			cConteudo := aDad[nI,2]

			Do case
				case valType(cConteudo) == 'D'
					cConteudo := dtoc(cConteudo)
				case valType(cConteudo) == 'L'
					cConteudo :=  iIf(cConteudo,STR0004,STR0005) //"SIM"###"NAO"
				case valType(cConteudo) == 'N'
					cConteudo :=  allTrim( str(cConteudo) )
				OtherWise
					cConteudo :=  allTrim( cConteudo )
			endCase

			if empty( allTrim( StrTran( cConteudo,"/","" ) ) )
				cConteudo := ""
			endIf

			if !empty(allTrim(cConteudo))
				PlsLogFil(space(03)+cCampo+space(15-len(cCampo))+"["+cConteudo+"]",__PLSFLOGX)
			endIf
		endIf

	next

	// Itens
	PlsLogFil("",__PLSFLOGX)
	PlsLogFil(space(03)+replicate("*",80),__PLSFLOGX)
	PlsLogFil(space(03)+"ITENS DA GUIA (EVENTOS)",__PLSFLOGX)
	PlsLogFil(space(03)+replicate("*",80),__PLSFLOGX)

	for nI := 1 To len(aIte)
		cSeqMov 	:= PLSRETDAD(aIte[nI],"SEQMOV")
		cCodPad 	:= PLSRETDAD(aIte[nI],"CODPAD")
		cCodPro 	:= PLSRETDAD(aIte[nI],"CODPRO")
		nQtdSol 	:= PLSRETDAD(aIte[nI],"QTD",0)
		nVlrApr		:= PLSRETDAD(aIte[nI],"VLRAPR",0)
		cTpProc  	:= PLSRETDAD(aIte[nI],"TPPROC","")
		dDtProIte	:= PLSRETDAD(aIte[nI],"DATPRO", PLSRETDAD( aDad,"DATPRO",ctod("") ) )
		cDente 		:= PLSRETDAD(aIte[nI],"DENTE","")
		cFace 		:= PLSRETDAD(aIte[nI],"FACE","")

		PlsLogFil(space(03)+"SEQMOV ["+cSeqMov+"] CODPAD ["+cCodPad+"] CODPRO ["+cCodPro+"] QTDSOL ["+allTrim(str(nQtdSol,7,2))+"] TPPROC ["+cTpProc+"] DTPROC ["+DToS(dDtProIte)+"] NVLRAPR ["+allTrim(str(nVlrApr))+"]"+iIf(PLSRETDAD(ADAD,"TIPO","1")=="4"," DENTE ["+CDENTE+"] FACE ["+CFACE+"] ",""),__PLSFLOGX)
	next

	PlsLogFil("",__PLSFLOGX)

return

/*/{Protheus.doc} PLSGRVAUN
(long_description)
@type function
@author Tulio Cesar
@since 26.05.07
@version 1.0
/*/
function PLSGRVAUN(lBaseadoAtend,cNumGuia,cMatric,dDatPro,cHora,cOpeMov,cCidPri,cCodRda,cOpeSol,cCdPFSO,cCodEsp,aItens,aCriticas,clocalExec,cTipoGrv)
	local nfor		  := 0
	local cCodPad	  := ""
	local cCodPro	  := ""
	local nQtdSol	  := 0
	local cSeqMov	  := ""
	local cRet        := ""
	default aItens    := {}
	default aCriticas := {}
	default cNumGuia  := ""
	default cTipoGrv  := ""

	if lBaseadoAtend
		BEA->(dbSetOrder(1))
		if BEA->(msSeek(xFilial("BEA")+cNumGuia))
			cMatric := BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO)
			dDatPro := BEA->BEA_DATPRO
			cHora   := BEA->BEA_HORPRO
			cOpeMov := BEA->BEA_OPEMOV
			cCidPri := BEA->BEA_CID
			cCodRda := BEA->BEA_CODRDA
			cOpeSol := BEA->BEA_OPESOL
			cCdPFSO := BEA->BEA_CDPFSO
			cCodEsp := BEA->BEA_CODESP

			aCriticas := {}
			BEG->(dbSetOrder(1))
			BE2->(dbSetOrder(1))
			if BE2->(msSeek(xFilial("BE2")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)))

				while ! BE2->(eof()) .and. BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) == ;
						xFilial("BE2")+BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)

					aadd(aItens, { {"SEQMOV",BE2->BE2_SEQUEN},{"CODPAD",BE2->BE2_CODPAD},{"CODPRO",BE2->BE2_CODPRO},{"QTD",BE2->BE2_QTDSOL},{"QTDAUT",BE2->BE2_QTDPRO} }  )

					if BEG->(msSeek(xFilial("BEG")+BE2->(BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN)))
						while ! BEG->(eof()) .and. BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN) == ;
								xFilial("BEG")+BEG->(BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN)

							aadd(aCriticas,{BE2->BE2_SEQUEN,BEG->BEG_CODGLO,BEG->BEG_DESGLO,BEG->BEG_INFGLO})
							BEG->(dbSkip())

						endDo
					endIf

					BE2->(dbSkip())
				endDo

			endIf
		else
			return
		endIf
	endIf

	cHora := StrTran(cHora,":","")
	cHora := subStr(cHora,1,2)+subStr(cHora,3,2)

	BXE->(RecLock("BXE",.t.))
	BXE->BXE_FILIAL := xFilial("BXE")
	BXE->BXE_CODSEQ := getSx8Num("BXE","BXE_CODSEQ")
	BXE->BXE_MATRIC := cMatric
	BXE->BXE_DATPRO := dDatPro
	BXE->BXE_HORAPR := cHora
	BXE->BXE_OPEMOV := cOpeMov
	BXE->BXE_CIDPRI := cCidPri
	BXE->BXE_CODRDA := cCodRda
	BXE->BXE_OPESOL := cOpeSol
	BXE->BXE_CDPFSO := cCdPFSO
	BXE->BXE_CODESP := cCodEsp
	BXE->BXE_TPGRV := cTipoGrv

	if BXE->(fieldPos("BXE_ORITRA")) > 0
		BXE->BXE_ORITRA := cTipoGrv
	endIf

	BXE->BXE_NUMGUI := cNumGuia
	BXE->(msUnLock())

	cRet := BXE->BXE_CODSEQ

	confirmSX8()

	for nfor := 1 To len(aItens)
		cSeqMov := PLSRETDAD(aItens[nfor],"SEQMOV")
		cCodPad := PLSRETDAD(aItens[nfor],"CODPAD")
		cCodPro := PLSRETDAD(aItens[nfor],"CODPRO")
		nQtdSol := PLSRETDAD(aItens[nfor],"QTD",0)
		nQtdAut := PLSRETDAD(aItens[nfor],"QTDAUT",0)

		BXF->(RecLock("BXF",.t.))
		BXF->BXF_FILIAL := xFilial("BXF")
		BXF->BXF_CODSEQ := BXE->BXE_CODSEQ
		BXF->BXF_SEQMOV := cSeqMov
		BXF->BXF_CODPAD := cCodPad
		BXF->BXF_CODPRO := cCodPro
		BXF->BXF_QTD    := nQtdSol
		BXF->(msUnLock())
	next

	for nfor := 1 To len(aCriticas)
		BXG->(RecLock("BXG",.t.))
		BXG->BXG_FILIAL := xFilial("BXG")
		BXG->BXG_CODSEQ := BXE->BXE_CODSEQ
		BXG->BXG_SEQMOV := aCriticas[nfor,1]
		BXG->BXG_CODCRI := aCriticas[nfor,2]
		BXG->BXG_DESCRI := aCriticas[nfor,3]
		BXG->BXG_INFO   := aCriticas[nfor,4]
		BXG->(msUnLock())
	next

return(cRet)

/*/{Protheus.doc} PLSEXCAUN
(long_description)
@type function
@author Tulio Cesar
@since 26.05.07
@version 1.0
/*/
function PLSEXCAUN(cNumGuia,cCodSeq)
	local lRet := .f.
	local cMsg
	local cChave  := ""
	local nOrdem
	default cCodSeq := ""

	if ! empty(cNumGuia)
		nOrdem := 4
		cChave := cNumGuia
	else
		nOrdem := 1
		cChave := cCodSeq
	endIf

	if ! empty(cChave)
		SIX->(dbSetOrder(1))
		if ! SIX->( msSeek("BXE"+str(nOrdem,1) ) )
			cMsg := STR0036+str(nOrdem,1)+STR0037 //"Indice "###" no arquivo BXE"
		else
			BXE->(dbSetOrder(nOrdem))
			if BXE->(msSeek(xFilial("BXE")+cChave))
				BXF->(dbSetOrder(1))
				while BXF->(msSeek(xFilial("BXF")+BXE->BXE_CODSEQ))
					BXF->(RecLock("BXF",.f.))
					BXF->(DbDelete())
					BXF->(msUnLock())
				endDo

				BXG->(dbSetOrder(1))
				while BXG->(msSeek(xFilial("BXG")+BXE->BXE_CODSEQ))
					BXG->(RecLock("BXG",.f.))
					BXG->(DbDelete())
					BXG->(msUnLock())
				endDo
				BXE->(RecLock("BXE",.f.))
				BXE->(DbDelete())
				BXE->(msUnLock())
				lRet := .t.
			else
				cMsg := STR0038 //"Guia/Critica nao encontrada no arquivo de autorizacoes negadas"
			endIf
		endIf
	endIf

return( {lRet,cMsg} )

/*/{Protheus.doc} PLSRETDAD
Descri‡„o Retorna conteudo da matriz
@type function
@author Alexander Santos
@since 26.05.07
@version 1.0
/*/
function PLSRETDAD(aMat,cCampo,cdefault,lId)
	local nPos  	 := 0
	local cRet  	 := ""
	default cdefault := ""
	default lId		 := .f.

	// Pega o conteudo
	nPos := aScan(aMat,{ |x| allTrim( x[1] ) == allTrim( cCampo ) } )

	// Se achou
	if nPos > 0

		if lId
			cRet := aMat[nPos,3]
		else
			cRet := aMat[nPos,2]
		endIf

		// Compatibiliza com o valor logico enviado pela importacao xml tiss
		if valType(cRet) == 'C' .and. cRet $ 'true,false'
			cRet := iIf(cRet=='true',"1","0")
		endIf

		if valType(cRet) <> 'L' .and. empty(cRet)
			cRet := cdefault
		endIf
	else
		cRet := cdefault
	endIf

return iIf(valType(cRet)=="C",allTrim(cRet),cRet)

/*/{Protheus.doc} PLSPUTDAD
Coloca conteudo na matriz
@type function
@author Alexander Santos
@since 26.05.07
@version 1.0
/*/
function PLSPUTDAD(aMat,cCampo,cConteudo,lnew,lempty,cId)
	local nPos 		:= 0
	default lnew 	:= .f.
	default lempty 	:= .t.
	default cId		:= ""
	// Pega o conteudo
	nPos := aScan(aMat,{ |x| allTrim( x[1] ) == allTrim( cCampo ) } )
	// Se achou
	if nPos > 0

		if lempty
			aMat[nPos,2] := cConteudo
		else
			if !empty(cConteudo)
				aMat[nPos,2] := cConteudo
			endIf
		endIf

	elseIf lnew

		if lempty
			aadd( aMat, {cCampo , cConteudo, upper(cId) } )
		elseIf !empty(cConteudo)
			aadd( aMat, {cCampo , cConteudo, upper(cId) } )
		endIf

	endIf

return

/*/{Protheus.doc} PLSPEGCON
Monta matriz dadite
@type function
@author Alexander Santos
@since 26.05.07
@version 1.0
/*/
function PLSDADITE(aDadIte,aItens,cOrigem,cLibEsp,cAuditoria,cNumImp,cStatus,dDatPro,aDadRda,cAlias)
	local nI		:= 1
	local cCdpDrc 	:= "01"
	local cBloPag 	:= "0"
	local cSolRev 	:= "0"
	local cHora		:= StrTran(Time(),":","")
	local cTipPe  	:= BAU->BAU_TIPPE
	local nQtdSol   := PLSRETDAD(aItens,"QTD",0)

	local cTipEve	:= PLSRETDAD(aItens,"TIPEVE","")
	local cPROCCI 	:= iIf(cTipEve $ "2,3","1","0")
	local cVia    	:= PLSRETDAD(aItens,'VIAAC',"")
	local nPerVia 	:= 0

	local cDente 	:= allTrim( PLSRETDAD(aItens,"DENTE","") )
	local cFace 	:= PLSRETDAD(aItens,"FACE","")
	local cCodPad 	:= allTrim( PLSRETDAD(aItens,"CODPAD") )
	local cCodPro 	:= allTrim( PLSRETDAD(aItens,"CODPRO") )
	local aMatCam	:= {}
	default cAlias	:= "BE2"
	default cStatus := iIf( empty( PLSRETDAD(aItens,"STATUS") ),"0",PLSRETDAD(aItens,"STATUS") )
	default aDadRda	:= {}

	// se existe a sequencia nao inclui novamente
	if aScan( aDadIte,{|x| x[1,2] == PLSRETDAD(aItens,"SEQMOV") } ) > 0
		return(nil)
	endIf

	// Via de acesso
	cVia 	:= iIf( ! empty(cVia),cVia,iIf(cPROCCI=="1",getNewPar("MV_PLSVAPR","0"),"") )
	nPerVia := plRtPerV(cVia)

	// Define campos de tratamento e conteudo
	// 3 posicao do aMatCam definine se nao vai .t.ou vai .f. fazer fieldpos
	aMatCam :={ {cAlias+"_SEQUEN",PLSRETDAD(aItens,"SEQMOV"),.t.},;
		{cAlias+"_CODPAD",PLSRETDAD(aItens,"CODPAD"),.t.},;
		{cAlias+"_CODPRO",PLSRETDAD(aItens,"CODPRO"),.t.},;
		{cAlias+"_DESPRO",StrTran(PLSRETDAD(aItens,"DESCRI",""), "'", ""),.t.},;
		{cAlias+"_QTDSOL","eval({|| nQtdSol })",.f.},;
		{cAlias+"_QTDPRO","eval({|| PLSRETDAD(aItens,'QTDAUT',nQtdSol) })",.t.},;
		{cAlias+"_SALDO","eval({|| iIf(cOrigem=='1',0,nQtdSol) })",.f.},;
		{cAlias+"_CHVNIV",PLSRETDAD(aItens,"CHVNIV",""),.f.},;
		{cAlias+"_NIVAUT",PLSRETDAD(aItens,"NIVAUT",""),.f.},;
		{cAlias+"_NIVCRI",PLSRETDAD(aItens,"NIVCRI",""),.f.},;
		{cAlias+"_NIVEL",PLSRETDAD(aItens,"NIVEL",""),.f.},;
		{cAlias+"_TPPROC",PLSRETDAD(aItens,"TPPROC",""),.f.},;
		{cAlias+"_VLRAPR","eval({|| PLSRETDAD(aItens,'VLRAPR',0) })",.f.},;
		{cAlias+"_VALOR","eval({|| PLSRETDAD(aItens,'VLRAPR',0) })",.f.},;
		{cAlias+"_VALTOT","Eval({|| (PLSRETDAD(aItens,'QTDAUT',nQtdSol)*PLSRETDAD(aItens,'VLRAPR',0))*PLSRETDAD(aItens,'REDAC',1)  })",.F.},;
		{cAlias+"_DATPRO","eval({|| PLSRETDAD(aItens,'DATPRO',dDatPro) })",.t.},;
		{cAlias+"_HORPRO",PLSRETDAD(aItens,"HORINI",cHora),.f.},;
		{cAlias+"_HORINI",PLSRETDAD(aItens,"HORINI",cHora),.f.},;
		{cAlias+"_HORFIM",PLSRETDAD(aItens,"HORFIM",cHora),.t.},;
		{cAlias+"_STATUS",cStatus,.t.},;
		{cAlias+"_TIPRDA",cTipPe,.f.},;
		{cAlias+"_LIBESP",cLibEsp,.f.},;
		{cAlias+"_AUDITO",cAuditoria,.f.},;
		{cAlias+"_PROCCI",cPROCCI,.f.},;
		{cAlias+"_CDPDRC",cCdpDrc,.f.},;
		{cAlias+"_BLOPAG",cBloPag,.f.},;
		{cAlias+"_SOLREV",cSolRev,.f.},;
		{cAlias+"_NUMIMP",cNumImp,.f.},;
		{cAlias+iIf(cAlias == "BE2","_VIA","_VIACES"),cVia,.t.},;
		{cAlias+"_PERVIA",'eval({|| nPerVia })',.f.},;
		{cAlias+"_DENREG",cDente,.f.},;
		{cAlias+"_DESREG",PLSDESDF(cCodPad + cCodPro+space(TamSx3("BE2_CODPRO")[1]-len(cCodPro) ) + cDente + space( TamSx3("B05_CODIGO")[1]-len(cDente) ),0),.f.},;
		{cAlias+"_FADENT",cFace,.f.},;
		{cAlias+"_FACDES",PLSDESDF(cFace,1),.f.},;
		{cAlias+"_PRFATD",iIf(len(aDadRDA)>0,aDadRDA[5],""),.f.},;
		{cAlias+"_RESAUT",PLSRETDAD(aItens,"RESAUT",""),.f.},;
		{cAlias+"_MEMO1" ,PLSRETDAD(aItens,"INDCLIEVO",""),.t.},;
		{cAlias+"_TECUTI",PLSRETDAD(aItens,"TECUT",""),.f.},;
		{cAlias+"_PRPRRL","eval({|| PLSRETDAD(aItens,'REDAC',0) })",.f.},;
		{cAlias+"_REDACR","eval({|| PLSRETDAD(aItens,'REDAC',0) })",.f.},;
		{cAlias+"_VLCOMP","eval({|| PLSRETDAD(aItens,'VLCOMP',0) })",.f.},;
		{cAlias+"_NRTROL","eval({|| PLSRETDAD(aItens,'TRAITEPTU','') })",.t.},;
		{cAlias+"_NRAOPE","eval({|| PLSRETDAD(aItens,'NRAOPE','') })",.t.},;
		{cAlias+"_PACOTE","eval({|| PLSRETDAD(aItens,'PACOTE','') })",.t.},;
		{cAlias+"_DIAGNO",PLSRETDAD(aItens,"DIAGNO","NAO INforMADO"),.f.},;
		{cAlias+"_SEQPTU",PLSRETDAD(aItens,"SQ_ITEM"),.t.},;
		{cAlias+"_REGANV",PLSRETDAD(aItens,"CD_ANVISA"),.t.},;
		{cAlias+"_GUIJUR",PLSRETDAD(aItens,"ID_LIMINAR"),.t.},;
		{cAlias+"_CDPACO",PLSRETDAD(aItens,"CDPACOTE",""),.f.}}

	// Monta matriz adadite
	bMat := " {|| aadd(aDadIte,{ "

	for nI := 1 To len(aMatCam)

		if aMatCam[nI,3] .or. &( cAlias+"->( fieldPos('" + aMatCam[nI,1] + "') )" ) > 0

			if at('EVAL', upper(aMatCam[nI,2]) ) == 0

				bMat += "{'" + aMatCam[nI,1] + " ','" + aMatCam[nI,2] + "' },"

			else

				bMat += "{'" + aMatCam[nI,1] + " '," + aMatCam[nI,2] + " },"

			endIf

		endIf

	next

	bMat := left( bMat, len(bMat) - 1 ) + " } ) } "

	eval(&bMat)

return(nil)

/*/{Protheus.doc} PLVLDMATAN
Valida Matricula
@type function
@author Alexander Santos
@since 17.07.08
@version 1.0
/*/
function PLVLDMATAN(cMatric)
	local lRet := .t.

	BA1->( dbSetOrder(2) ) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO

	lRet := !BA1->( msSeek( xFilial("BA1")+cMatric ) )

	// Verifica matricula antiga
	BA1->( dbSetOrder(5) ) //BA1_FILIAL + BA1_MATANT + BA1_TIPANT

	if lRet
		lRet := !BA1->( msSeek( xFilial("BA1")+cMatric ) )
	endIf

	if lRet
		lRet := !BA1->( msSeek( xFilial("BA1")+Right(cMatric,16) ) )
	endIf
	// Posiciona na familia
	BA3->(dbSetOrder(1))
	BA3->(msSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))

return lRet

/*/{Protheus.doc} PLSVLDPRO
Verificaçao do procedimento
@type function
@author Alexander Santos
@since 17.07.08
@version 1.0
/*/
function PLSVLDPRO(aItens,clocalExec,cTipoGrv,cCidPri,cOrigem,nTp,aEventosNeg,aCriticas)
	local nY,nX	  := 0
	local nQtdSol := 0
	local cSeqMov := ""
	local cCodPad := ""
	local cCodPro := ""
	local lRet    := .t.
	local lFatal  := .f.
	local aRetFun := {}
	local aTrb	  := {}
	local aOldCri := {}
	default nTp   := 1

	// Salvo a matriz aCodCri Statica
	aOldCri := PLLimpCCri(.f.)

	// Verifica todos os itens
	for nY := 1 To len(aItens)
		cSeqMov	:= PLSRETDAD(aItens[nY],"SEQMOV")
		cCodPad	:= PLSRETDAD(aItens[nY],"CODPAD")
		cCodPro	:= PLSRETDAD(aItens[nY],"CODPRO")
		cDescri	:= PLSRETDAD(aItens[nY],"DESCRI","")
		nQtdSol := PLSRETDAD(aItens[nY],"QTD",0)
		nQtdAut := PLSRETDAD(aItens[nY],"QTDAUT",0)
		cDente  := PLSRETDAD(aItens[nY],"DENTE","")
		cFace   := PLSRETDAD(aItens[nY],"FACE","")
		cSlvPad := PLSRETDAD(aItens[nY],"SLVPAD","")
		cSlvPro := PLSRETDAD(aItens[nY],"SLVPRO","")
		aTrb	:= {}

		// Limpar outras criticas
		PLLimpCCri(.t.)

		// Verifica se o procedimento informado existente na tabela padrao
		aRetFun := PLSVLDPTP(cCodPad,cCodPro,clocalExec,cTipoGrv)

		if !aRetFun[1]
			lRet	:= .f.
			lFatal 	:= !BR8->( Found() )
			aTrb   	:= aRetFun[2]
		endIf

		// Verifica se o procedimento informado e obrigatorio informar o Cid
		if nTp == 1

			if aRetFun[1]

				// Verifica se o procedimento/Cid
				aRetFun := PLSVLDOCD(cCodPad,cCodPro,clocalExec,cCidPri,nQtdSol,iIf( cOrigem=="2",.t.,.f. ),iIf( cOrigem=="2",.f.,.t. ),cTipoGrv,nil)

				if !aRetFun[1]
					lRet := .f.
					aTrb := aRetFun[2]
				endIf
			endIf

		endIf

		// Inclui a critica e o evento negado
		if !aRetFun[1]
			aadd( aEventosNeg,{cSeqMov,cCodPad,cCodPro,nQtdSol,cDescri,nQtdAut,cDente,cFace,"",cSlvPad,cSlvPro} )
			// Alimenta a critica
			for nX := 1 To len(aTrb)
				aadd( aCriticas,{cSeqMov,aTrb[nX,1],aTrb[nX,2]+iIf(len(aTrb[nX])>=3 .and. !empty(aTrb[nX,3]),' ( '+aTrb[nX,3]+' ) ',''),cCodPad,cCodPro,cDente,cFace} )
			next
		endIf
	next

	// Retorna com o conteudo original
	PLLimpCCri(.f.,.t.,aOldCri)

return( { lRet , lFatal } )

/*/{Protheus.doc} PLSXMOVREG
Validacoes regras de usuario local e de intercambio
Para intercambio somente se a operadora nao estiver online
@type function
@author Alexander Santos
@since 17.07.08
@version 1.0
/*/
function PLSXMOVREG(aItens,lAprovLib,lTrtUsr,lRegras,lConsulta,cOrigem,cAno,cMes,dDatPro,cHora,aDadUsr,aDadRDA,cCidPri,;
		cLocalExec,cOpeSol,cCDPFSO,cPadInt,cPadCon,cRegAte,cCodPRFExe,cOpeExe,lRegPagAto,cTipoGrv,cAreaAbr,;
		cCodEsp,cCodLoc,cFilBCT,cTipoGrv,cLibEsp,cNumImp,cOpeMov,nQtdDiAut,aDadIte,aCriticas,;
		aEventosNeg,aEventosAut,lAudEmp,lFAudMOP,lFAudAte,lforcAud,lAutoCus,aRdaProf,cCodEspPro,cCodLocPro,lTrtExe,;
		aDadBea,lAto,lWeb,lInter,lSolicit,lXMLLote,lPacAudi,lPtuOnline,cRdaEDI,lPtuA1100,lConPtuOn,cTipGui,;
		cEspSol,cEspExe,cNumLib,cCarSol,cSenBSN,cNuLibera, lNovaLiberacao, cAteRn,lTissOn,aBQVPTUDif,cRegInt,;
		cCaraterSol,cTGOriginal,lAllAutori,aProrInt,lUrgPTUInter)
	local nfor2,nfor	:= 0
	local nRecBD6		:= 0
	local nQtdSol 		:= 0
	local nQtdAut 		:= 0
	local cSeqMov 		:= ""
	local cCodPad 		:= ""
	local cCodPro 		:= ""
	local cTpProc 		:= ""
	local cDente 		:= ""
	local cFace 		:= ""
	local cAuditoria	:= "0"
	local cIdRespWsd    := ""
	local cCrRespWsd    := ""
	local cDescGlo      := ""
	local lContinua 	:= .t.
	local lLogEx		:= .t.
	local lExc := .f.
	local lAudTodos     := .f.
	local lCriCab       := .f.
	local lNegAllIte    := .f.
	local aTrb 			:= {}
	local aRetFun		:= {}
	local aCliente		:= {}
	local aOldCri		:= {}
	local aRet          := {}
	local nH            := 0
	local nPoa			:= 0
	local aQtdBrow		:= {}
	local __cSeqMov 	:= ""
	local __cCodPad 	:= ""
	local __cCodPro 	:= ""
	local __cDescri		:= ""
	local __nQtdSol 	:= ""
	local __nQtdAut 	:= ""
	local __cTpProc		:= ""
	local __cDente  	:= ""
	local __cFace   	:= ""
	local __cStProc 	:= ""
	local aVldGen 		:= {}
	local lTratExLib  	:= if(allTrim(getNewPar("MV_PLEXLB","0"))=="1",.t.,.f.)
	local aRetAudPTU    := {}
	local lVerAllAud    := getNewPar("MV_PLAUDTO","0") == "1"
	local cCriNegAll    := getNewPar("MV_PTCRINE","")
	local lPermAudBR    := .f.
	local nCrit      	:= 0
	local lPtuOnUr      := .f.
	local lVldAbrag     := .f.
	local lTmpAudTod    := .f.
	local aPrevalid     := {}
	local lBaixoRisc    := .f.
	local lImpedeAud	:= .f. // Se ocorreu critica que não deve gerar demanda desnecessária na auditoria
	local nTraiTePTU    := 0
	local lChkLib 	   := GetNewPar("MV_PLSCKLB", .T.) //Indica se as regras de periodicidade e quantidade serao avaliadas na liberacao
	local cStatItem     := ""
	LOCAL lCri022BR     := GetNewPar("MV_PT022BR","1") == "1"
	LOCAL lForUsuar		:=IsInCallStack("PLSA973PRO") // Caso esta vindo da Tiss/Tissonline devemos sempre verificar as regras de usuatio
	LOCAL lPLAUPTON     := existBlock("PLAUPTON")
	LOCAL cCriUrgAud    := GetNewPar("MV_PTAUDUR","")
	LOCAL lCriUrgAud    := .f.
	LOCAL lCritAbrang	:= .F.
	LOCAL lAddCritica   := .F.
	LOCAL lPlAtuRG		:= GetNewPar("MV_PLATURG",.F.)
	Local lFoundItem := .F.
    Local lNegProPac := .F.
    Local aItensPac := {}
    Local aItGeralPac := {}
    Local njx := 0
    Local nyw := 0
	Local njy := 0
	local nVlrAut	:= 0

	default lFAudMOP	:= .f.
	default lFAudAte	:= .f.
	default lforcAud	:= .f.
	default lAutoCus	:= .f.
	default lAto		:= .f.
	default lXMLLote	:= .f.
	default lPacAudi    := .f.
	default lPtuOnline  := .f.
	default lConPtuOn   := .f.
	Default nPosNRAOPE	:= 0
	default cTipGui		:= ""
	default cEspSol    	:= ""
	default cEspExe    	:= ""
	default cNumLib		:= ""
	default cCarSol     := ""
	default cSenBSN     := ""
	default cNuLibera   := ""
	default lNovaLiberacao 	:= .f.
	default cAteRn       	:= '0'
	default cAteRn       	:= '0'
	default lTissOn      	:= isincallStack('tisssolicitacaoprocedimento')
	default aBQVPTUDif   	:= {}
	default cRegInt   		:= ""
	default cTGOriginal     := ""
	default lAllAutori      := .F.
	default aProrInt		:= {} // Prorrogação de Internação
	default lUrgPTUInter	:= .F.

	// Salvo a matriz aCodCri Statica
	if !lXMLLote
		aOldCri := PLLimpCCri(.f.)
	endIf

	// Se recebimento de Ptu Online com itens carregados pula verificacao

	if !( lFAudMOP .Or. lFAudAte .Or. lforcAud .Or. lAutoCus .Or. lPacAudi ) .And. ;
			len(aDadIte) > 0 .and. lPtuOnline .And. cCarSol <> "U"   // (se for atendimento de urgencia deve passar pelo PE PLABRPTU)

		return({})
	endIf

	// Verifica se ha criticas de cabecalho
	if len(aCriticas) > 0 .and. lPtuOnline
		lCriCab := .t.
	endIf

	// Atualiza variavel para verificacao de Abrangencia
	if empty(cAreaAbr)  .and. len(aDadUsr)>=65
		cAreaAbr := aDadUsr[65]
	endIf

	// Se PTU Online e Emergencia, nao verifica Abrangecia
	if lPtuOnline .and. cCarSol == "U"

		if existBlock("PLABRPTU")
			lVldAbrag := execBlock("PLABRPTU",.f.,.f.,{aDadUsr,aDadRDA,aItens,cOpeSol} )
		endIf

		if !lVldAbrag
			aVldGen := {nil,nil,nil,nil,nil,nil,.t.,nil,nil,nil,nil}
			lPtuOnUr  := .t.
		endIf

	endIf

	// Trato o aCriticas quando ha criticas de cabeçalho
	if lPtuOnUr .and. lPtuOnline .and. len(aCriticas) > 0 .And. !lUrgPTUInter

		aRegCriDel := {}
		nSizeTrb   := 0

		for nCrit := 1 to len(aCriticas)

			if !empty(aCriticas[nCrit][2])
				if allTrim(aCriticas[nCrit][2]) $ __aCdCri500[1]+"/"+__aCdCri062[1]+"/"+__aCdCri074[1]+"/"+__aCdCri026[1] //"011/032/038/050"
					lDelCriArr := .t.
					PlsPtuLog("Removendo crítica de abrangÊncia "+aCriticas[nCrit][2]+". Atendimento de UrgÊncia/EmergÊncia.")
				else
					lDelCriArr := .f.
				endIf
			endIf
			// Marca Posicoes do Array que serao deletadas
			if lDelCriArr
				aadd(aRegCriDel,nCrit)
			endIf

		next

		// Deleta posicoes marcadas do array
		if len(aRegCriDel) > 0

			for nCrit := 1 to len(aRegCriDel)
				aDel(aCriticas,aRegCriDel[(len(aRegCriDel)+1)-nCrit])//Deleto a partir das ultimas posicoes para nao perder o ponteiro
				nSizeTrb ++
			next

			aSize(aCriticas,len(aCriticas)-nSizeTrb)
		endIf

		// Se nao restou criticas, autorizo o evento
		if len(aCriticas) == 0
			lContinua   := .t.
			lCriCab     := .f.
			aEventosNeg := {}
		endIf

	endIf

	//Se 'Prorrogacao de Internacao', nao considero a 'Solicitacao de Internacao' como uma liberacao
	if cTGOriginal == "11"
		cNuLibera := ""
	endIf

	// MV_PLAUDTO - Ao processar uma solicitacao Ptu Online ha a opcao de enviar
	// todos os itens para auditoria quando um deles for marcado para auditar
	//
	// MV_PTCRINE - Indica criticas que se apresentadas, irao suplantar todas que
	// estiverem parametrizadas para envio a auditoria
	if lPtuOnline .and. (lVerAllAud .or. !empty(cCriNegAll)) .and. !lPtuA1100

		for nfor := 1 To len(aItens)

			lContinua 	:= .t.
			cLibEsp 	:= "0"
			cAuditoria 	:= "0"
			aRetAudPTU  := {}
			aVldGen     := {}

			cSeqMov 	:= PLSRETDAD(aItens[nfor],"SEQMOV")
			cCodPad 	:= PLSRETDAD(aItens[nfor],"CODPAD")+space(TamSx3("BD6_CODPAD")[1] - len(PLSRETDAD(aItens[nfor],"CODPAD")))
			cCodPro 	:= PLSRETDAD(aItens[nfor],"CODPRO")+space(TamSx3("BD6_CODPRO")[1] - len(PLSRETDAD(aItens[nfor],"CODPRO")))
			cDescri		:= PLSRETDAD(aItens[nfor],"DESCRI","")
			nQtdSol 	:= PLSRETDAD(aItens[nfor],"QTD",0)
			nQtdAut 	:= PLSRETDAD(aItens[nfor],"QTDAUT",0)
			cTpProc		:= PLSRETDAD(aItens[nfor],"TPPROC","")
			cDente  	:= PLSRETDAD(aItens[nfor],"DENTE","")+space(TamSx3("BD6_DENREG")[1] - len(PLSRETDAD(aItens[nfor],"DENTE","")))
			cFace   	:= PLSRETDAD(aItens[nfor],"FACE","")
			cStProc   	:= PLSRETDAD(aItens[nfor],"STPROC","")
			cDiagno	    := PLSRETDAD(aItens[nfor],"DIAGNO","")
			cDsEvento	:= PLSRETDAD(aItens[nfor],"DSEVENTO","0")

			BD6->( dbSetOrder(1) )

			nRecBD6 := 0

			// Se PTU Online e Emergencia, nao verifica Abrangecia
			if lPtuOnline .and. cCarSol == "U" .and. !lVldAbrag
				aVldGen  := {nil,nil,nil,nil,nil,nil,.t.,nil,nil,nil,nil}
				lPtuOnUr := .t.
			endIf


			// Se tem uma liberacao
			if lAprovLib .and. BD6->( msSeek(xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV) ) )
				// ja foi liberada pela auditoria/esta autorizada e ainda nao virou uma autorizacao
				if BEA->BEA_STATUS == "1" .and. BD6->BD6_SITUAC == "3"
					lTrtUsr := .f.
				endIf
				// Para nao pegar a liberacao no tratamento de periodicidade e outros
				nRecBD6 := BD6->( recno() )
			endIf

			// Se PTU Online e Emergencia, nao verifica Abrangecia
			if cCarSol == "U"
				aVldGen := {nil,nil,nil,nil,nil,nil,.t.,nil,nil,nil,nil}
			endIf

			// Item de Baixo Risco nao vou realizar as criticas de auditoria
			lBaixoRisc	:= VBaixRisco(aItens,.T.)

			if lBaixoRisc
				if len(aVldGen) > 0
					aVldGen[8]  := .f.
					aVldGen[10] := .f.
				else
					aVldGen := {nil,nil,nil,nil,nil,nil,nil,.f.,nil,.f.,nil}
				endIf
			endIf

			//Ajusta o lRegras para regras especificas do PTU Online
			if lPtuOnline .And. !lRegras
				//Se guia de baixo risco ou Urgencia/Emergencia, verifico as regras pois
				//devo ignorar o processo de auditoria automatica
				if lBaixoRisc .Or. cCarSol == "U"
					lRegras := .T.
				endIf
			endIf

			// Vai checar regra para todos os casos menos quando existir uma liberacao
			// O lRegras somente sera false no caso de um processo do Ptu OnLine (Meu usuario em outra operadora)
			// Isso esta no fonte plstrtptu_scs2
			// Sempre tem que entrar aqui caso nao exista uma liberacao

			if !lAprovLib .and. lRegras .or. ( cOrigem == "2" .and. nQtdAut == 0 )

				aQtdBrow := {}	// Reinicia array.

				for nH := 1 To len(aItens)

					__cSeqMov 	:= PLSRETDAD(aItens[nH],"SEQMOV")
					__cCodPad 	:= PLSRETDAD(aItens[nH],"CODPAD")+space(TamSx3("BD6_CODPAD")[1] - len(PLSRETDAD(aItens[nH],"CODPAD")))
					__cCodPro 	:= PLSRETDAD(aItens[nH],"CODPRO")+space(TamSx3("BD6_CODPRO")[1] - len(PLSRETDAD(aItens[nH],"CODPRO")))
					__cDescri	:= PLSRETDAD(aItens[nH],"DESCRI","")
					__nQtdSol 	:= PLSRETDAD(aItens[nH],"QTD",0)
					__nQtdAut 	:= PLSRETDAD(aItens[nH],"QTDAUT",0)
					__lAutoriz	:= lTissOn .OR. PLSRETDAD(aItens[nH],"STPROC", "S")=="S"
					__cTpProc	:= PLSRETDAD(aItens[nH],"TPPROC","")
					__cDente  	:= PLSRETDAD(aItens[nH],"DENTE","")+space(TamSx3("BD6_DENREG")[1] - len(PLSRETDAD(aItens[nH],"DENTE")))
					__cFace   	:= PLSRETDAD(aItens[nH],"FACE","")
					__cSequen	:= PLSRETDAD(aItens[nH],"SEQMOV","")
					__cStProc	:= PLSRETDAD(aItens[nH],"STPROC","")

					if (__cCodPad + __cCodPro == cCodPad + cCodPro .and. __cDente + __cFace == cDente + cFace )	// Retira o registro atual da matriz que sera enviada ao PLSAUTP()
						loop
					elseIf !__lAutoriz 	//	Se o registro atual não estiver autorizado não entra na matriz.
						loop
					endIf

					aadd(aQtdBrow,{	__cCodPad,;
						__cCodPro,;
						__nQtdSol,;
						dDatPro,;
						cHora,;
						__cDente,;
						__cFace,;
						__cSequen})
				next

				
				aRetFun := PLSAUTP( dDatPro,;
						cHora,;
						cCodPad,;
						cCodPro,;
						if(nQtdSol==0,1,nQtdSol),;
						aDadUsr,;
						nRecBD6,;
						iIf(lTrtExe,aRdaProf,aDadRDA),;
						"1",;
						iIf(getNewPar("MV_PLSMODA","1")=="0",.f.,.t.),;
						cCidPri,;
						lTrtUsr,;
						cLocalExec,;
						lSolicit,;
						cOpeSol,;
						cCDPFSO,;
						cAno,;
						cMes,;
						cPadInt,;
						cPadCon,;
						cRegAte,;
						.t.,;
						cCodPRFExe,;
						nil,;
						nil,;
						cOpeExe,;
						nil,nil,nil,nil,;
						cSeqMov,;
						cNumLib,;
						lRegPagAto,;
						cTipoGrv,;
						cFace,nil,nil,nil,nil,nil,;
						iIf(!empty(cRdaEDI),cRdaEDI,nil),;
						nil,;
						cAreaAbr,;
						nil,nil,;
						cDente,;
						nil,;
						.f.,;
						iIf(lTratExLib, lTratExLib, (!lSolicit .or. !empty(cCodPRFExe))),;
						.t.,;
						cTpProc,;
						cCodEspPro,;
						aQtdBrow,;
						aVldGen,;
						iIf(! empty(cCodLocPro),cCodLocPro,cCodLoc),;
						nil,;
						nil,;
						cTpProc,;
						lWeb,;
						nil,;
						nil,;
						nil,;
						nil,;
						nil,;
						nil,;
						nil,;
						nil,;
						nil,;
						nil,;
						cEspSol,;
						cEspExe,;
						nil,;
						nil,;
						nil,;
						cStProc,;
						nil,;
						nil,;
						nil,;
						lPtuOnline,;
						lInter,;
						@aRetAudPTU,,,,,,,,,,,cTGOriginal,aProrInt)

				If lUrgPTUInter .And. FindFunction("PLAutIntUrgPTU")
					aRetFun := PLAutIntUrgPTU(aRetFun, cCodPad, cCodPro, nQtdSol, cLocalExec, cTipoGrv)
				EndIf
				
				// Retorno
				if !(GetNewPar("MV_PLATURG",.F.) .and. PLSISURG(cCaraterSol))
					lContinua	:= aRetFun[1]

				else
					aRetFun[1] := .T.
					lContinua	:= aRetFun[1]

				endif

				if len(aRetFun) > 1
					aTrb := aRetFun[2]
				endIf

				aadd(aPrevalid,aClone(aRetFun))
				// Deleta criticas de abrangencia quando atendimento de Urg/Emerg. PTU Online
				if lPtuOnUr .and. lPtuOnLine .and. !lContinua .And. !lUrgPTUInter

					aRegCriDel := {}
					nSizeTrb   := 0

					for nCrit := 1 to len(aTrb)

						// BCT_ATIVBR - Verifica se exibo ou nao as criticas apresentadas no Baixo Risco
						if !empty(aTrb[nCrit][1])

							if allTrim(aTrb[nCrit][1]) $ __aCdCri500[1]+"/"+__aCdCri062[1]+"/"+__aCdCri074[1]+"/"+__aCdCri026[1] //"011/032/038/050"
								lDelCriArr := .t.
								PlsPtuLog(cCodPad+"-"+allTrim(cCodPro)+" -> Removendo crítica de abrangÊncia "+aTrb[nCrit][1]+". Atendimento de UrgÊncia/EmergÊncia.")
							else
								lDelCriArr := .f.
							endIf

						endIf
						// Marca Posicoes do Array que serao deletadas
						if lDelCriArr
							aadd(aRegCriDel,nCrit)
						endIf

					next

					// Deleta posicoes marcadas do array
					if len(aRegCriDel) >0

						for nCrit := 1 to len(aRegCriDel)
							aDel(aTrb,aRegCriDel[(len(aRegCriDel)+1)-nCrit])//Deleto a partir das ultimas posicoes para nao perder o ponteiro
							nSizeTrb ++
						next

						aSize(aTrb,len(aTrb)-nSizeTrb)
					endIf

					// Se nao restou criticas, autorizo o evento
					if len(aTrb) == 0
						lContinua := .t.
					endIf

				endIf

				// Verifica se o evento e de Baixo Risco, caso positivo, o mesmo nao pode ser
				// enviado para estudo.
				if lPtuOnline .and. lBaixoRisc

					lPermAudBR := .f.
					// Verifica criticas que permitem Auditoria no Baixo Risco:
					// 022 - Para este procedimento necessita Guia da Empresa.
					if !lContinua .And. len(aTrb) > 0 .And. lCri022BR
						for nfor2 := 1 To len(aTrb)
							if aTrb[nfor2][1] == __aCdCri052[1]
								lPermAudBR := .t.
							endIf
						next
					endIf
					// Verifica se o evento e de Baixo Risco
					if lBaixoRisc .and. !lPermAudBR .and. !lContinua

						//Ajusta array de criticas baseado no campo BCT_ATIVBR
						PLTrabRisc(@aTrb,cCodPad,cCodPro,.F.,cSeqMov,@aEventosNeg,"1")

						// Se restou criticas, aciona o Baixo Risco
						if len(aTrb) == 0
							lContinua := .t.
						endIf

					endIf
				endIf
			endIf

			if !lContinua

				for nfor2 := 1 To len(aTrb)
					// Evento precisa de Auditoria / Guia Empresa
					if aTrb[nfor2,1] == __aCdCri051[1] .Or. (lAudEmp .And. aTrb[nfor2,1] == __aCdCri052[1])
						cAuditoria := "1"

						//Indica criticas que podem ser enviadas para Audito mesmo se atendimento de
						//Urgencia/Emergencia
						if aTrb[nfor2,1] $ cCriUrgAud
							lCriUrgAud := .T.
						endIf
					endIf

					// Se a critica coloca na auditoria
					if cAuditoria <> "1"

						// Ponto de entrada para indicar se o procedimento vai para auditoria PTU On
						if  lPtuOnline .and. lPLAUPTON
							cAuditoria := execBlock("PLAUPTON",.f.,.f.,{aDadUsr,aTrb,cOpeSol,aRetAudPTU} )
							aRetAudPTU := {.t.,cAuditoria}
						else
							// Verifico se a critica dele colocar o procedimento em auditoria
							BCT->( dbSetOrder(1) ) //BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO
							if !Empty(aTrb[nfor2,1]) .And. BCT->( msSeek( xFilial("BCT")+PlsIntPad()+aTrb[nfor2,1] ) )
								cAuditoria := iIf(BCT->BCT_AUDITO == "1","1","0")
							endIf
							//Indica criticas que podem ser enviadas para Audito mesmo se atendimento de
							//Urgencia/Emergencia
							if !empty(aTrb[nfor2,1]) .And. aTrb[nfor2,1] $ cCriUrgAud
								lCriUrgAud := .T.
							endIf
							// aRetAudPTU indica se o item pode ser enviado ou nao para auditoria
							// Implementado para a regra de item com valor inferior a 6 consultas
							if len(aRetAudPTU) > 1
								cAuditoria := aRetAudPTU[2]
							endIf
						endIf
					endIf
					// lNegAllIte - Indica se determinada critica for apresentada, ela deve
					// negar todos os itens do PTU msm que existe itens parametrizados para auditoria
					if ! empty(cCriNegAll) .And. aTrb[nFor2,1] $ cCriNegAll
						lNegAllIte := .t.
					endIf

				next

				/*Se atendimento de urgencia/emergencia e consulta, nao podemos enviar para auditoria:

				6.8. Consultas Eletivas 6.8.1. A Unimed Executora, com prestador on-line no Intercâmbio Eletrônico,
				deve solicitar autorização à Unimed Origem para consultas eletivas, que deverão obrigatoriamente ser
				autorizadas” ou “negadas”. Se a Unimed Origem responder à transação como “em estudo”, o WSD a autorizará,
				conforme definido no item 6.3. - WSD – Intercâmbio. */
				if lConsulta .And. lPtuOnUr
					cAuditoria := "0"
				endIf
				// Indica que um dos itens caiu para estudo e nao e baixo risco
				if cAuditoria == "1" .and. !lBaixoRisc
					lTmpAudTod := .t.
				endIf
			endIf

			// Ha um item com descricao, precisa enviar para auditoria
			if cDsEvento == "1" .and. !lBaixoRisc
				lTmpAudTod := .t.
			endIf
		next
		// Se algum item cai para auditoria, aborta verificacao
		if (lTmpAudTod .or. lFAudMOP .or. lFAudAte .or. lforcAud .or. lAutoCus .or. lPacAudi ) .and. lVerAllAud .and. ;
				(!lBaixoRisc .and. (cCarSol <> "U" .Or. lCriUrgAud))

			lAudTodos := .t.
		endIf
	endIf

	// Tratamento dos Itens
	for nfor := 1 To len(aItens)
		lContinua 	:= .t.
		cLibEsp 	:= "0"
		cAuditoria 	:= "0"
		lImpedeAud	:= .f.
		aRetAudPTU  := {}
		aVldGen     := {}

		cSeqMov 	:= PLSRETDAD(aItens[nfor],"SEQMOV")
		cCodPad 	:= PLSRETDAD(aItens[nfor],"CODPAD")+space(TamSx3("BD6_CODPAD")[1] - len(PLSRETDAD(aItens[nfor],"CODPAD")))
		cCodPro 	:= PLSRETDAD(aItens[nfor],"CODPRO")+space(TamSx3("BD6_CODPRO")[1] - len(PLSRETDAD(aItens[nfor],"CODPRO")))
		cDescri		:= PLSRETDAD(aItens[nfor],"DESCRI","")
		nQtdSol 	:= PLSRETDAD(aItens[nfor],"QTD",0)
		nQtdAut 	:= PLSRETDAD(aItens[nfor],"QTDAUT",0)
		cTpProc		:= PLSRETDAD(aItens[nfor],"TPPROC","")
		cDente  	:= PLSRETDAD(aItens[nfor],"DENTE","")+space(TamSx3("BD6_DENREG")[1] - len(PLSRETDAD(aItens[nfor],"DENTE","")))
		cFace   	:= PLSRETDAD(aItens[nfor],"FACE","")
		cSlvPad     := PLSRETDAD(aItens[nfor],"SLVPAD","")
		cSlvPro		:= PLSRETDAD(aItens[nfor],"SLVPRO","")
		cStProc   	:= PLSRETDAD(aItens[nfor],"STPROC","")
		cDiagno		:= PLSRETDAD(aItens[nfor],"DIAGNO","")
		cDsEvento	:= PLSRETDAD(aItens[nfor],"DSEVENTO","0")

		if lPtuA1100
			cIdRespWsd := PLSRETDAD(aItens[nfor],"ID_RESPWSD","")
			cCrRespWsd := PLSRETDAD(aItens[nfor],"CD_MENS_ER","")
		endIf

		BD6->( dbSetOrder(1) )
		nRecBD6 := 0

		lNegProPac := .F.
        aItensPac := {}
        aItGeralPac := {}

		For nyw := nFor To 1 Step -1

			aItensPac := PlRetPac(PlsIntPad(), aDadRda[2], PLSRETDAD(aItens[nyw],"CODPAD"), PLSRETDAD(aItens[nyw],"CODPRO"), Nil, dDatPro)

			If Len(aItensPac) > 0

				For njx := 1  To Len(aItensPac)

					lFoundItem := IIf(Len(aItensPac[njx]) >= 11, aItensPac[njx][11], .F.)

					If !lFoundItem
						Aadd(aItGeralPac, AllTrim(aItensPac[njx,2]))
					EndIf
				Next njx

				If Len(aItGeralPac) > 0
					For  njy := nFor To 1 Step -1
						If Ascan( aItGeralPac, PLSRETDAD(aItens[njy],"CODPRO")) > 0
							lNegProPac:= .T.
						Endif
					Next njy
				endif
			EndIf
		Next nyw

		If Len(aItGeralPac) > 0 .And. Ascan(aItGeralPac, Alltrim(cCodPro)) > 0
			lNegProPac := .T.
		EndIF

		// Se tem uma liberacao
		if lAprovLib .and. BD6->( msSeek(xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV) ) )
			// ja foi liberada pela auditoria/esta autorizada e ainda nao virou uma autorizacao
			if BEA->BEA_STATUS == "1" .and. BD6->BD6_SITUAC == "3"
				If !lForUsuar .And. !lWeb // Caso esta vindo da Tiss/Tissonline devemos sempre verificar as regras de usuatio
					lTrtUsr := .F.
				Endif
			endIf
			// Para nao pegar a liberacao no tratamento de periodicidade e outros
			nRecBD6 := BD6->( recno() )
		endIf

		If lWeb .And. !lAprovLib .And. !lPtuA1100 .And. !lPtuOnLine .And. BD6->( msSeek(xFilial("BD6")+BEA->(BEA_OPEMOV+BEA_CODLDP+BEA_CODPEG+BEA_NUMGUI+BEA_ORIMOV) ) )
			nRecBD6 := BD6->(recno())
		EndIF

		If cTipGui $ G_SADT + "|" + G_ODONTO .and. lSolicit .And. !lPtuOnline
			if !lChkLib
				aVldGen := {.F.,.F.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.}
			else
				aVldGen := {.T.,.T.,.T.,.T.,.f.,.F.,.T.,.T.,.T.,.T.,.T.}
			endif
		EndIf

		// Se PTU Online e Emergencia, nao verifica Abrangecia
		if lPtuOnline .and. cCarSol == "U" .and. !lVldAbrag
			aVldGen  := {nil,nil,nil,nil,nil,nil,.t.,nil,nil,nil,nil}
			lPtuOnUr := .t.
		endIf

		// Item de Baixo Risco nao vou realizar as criticas de auditoria
		if !lBaixoRisc
			lBaixoRisc	:= VBaixRisco(aItens,.T.)
		endIf

		// Item de Baixo Risco nao vou realizar as criticas de auditoria
		if lBaixoRisc .and. lPtuOnline
			if len(aVldGen) > 0
				aVldGen[8]  := .f.
				aVldGen[10] := .f.
			else
				aVldGen := {nil,nil,nil,nil,nil,nil,nil,.f.,nil,.f.,nil}
			endIf
		endIf

		//Ajusta o lRegras para regras especificas do PTU Online
		if lPtuOnline .And. !lRegras
			//Se guia de baixo risco ou Urgencia/Emergencia, verifico as regras pois
			//devo ignorar o processo de auditoria automatica
			if lBaixoRisc .Or. cCarSol == "U"
				lRegras := .T.
			endIf
		endIf
		// Vai checar regra para todos os casos menos quando existir uma liberacao
		// O lRegras somente sera false no caso de um processo do Ptu OnLine (Meu usuario em outra operadora)
		// Isso esta no fonte plstrtptu_scs2
		// Sempre tem que entrar aqui caso nao exista uma liberacao
		if (lRegras .or. ( cOrigem == "2" .and. nQtdAut == 0 ) )

			aQtdBrow := {}	// Reinicia array.

			for nH := 1 To len(aItens)

				__cSeqMov 	:= PLSRETDAD(aItens[nH],"SEQMOV")
				__cCodPad 	:= PLSRETDAD(aItens[nH],"CODPAD")+space(TamSx3("BD6_CODPAD")[1] - len(PLSRETDAD(aItens[nH],"CODPAD")))
				__cCodPro 	:= PLSRETDAD(aItens[nH],"CODPRO")+space(TamSx3("BD6_CODPRO")[1] - len(PLSRETDAD(aItens[nH],"CODPRO")))
				__cDescri	:= PLSRETDAD(aItens[nH],"DESCRI","")
				__nQtdSol 	:= PLSRETDAD(aItens[nH],"QTD",0)
				__nQtdAut 	:= PLSRETDAD(aItens[nH],"QTDAUT",0)
				__lAutoriz	:= lTissOn .OR. PLSRETDAD(aItens[nH],"STPROC", "S")=="S"
				__cTpProc	:= PLSRETDAD(aItens[nH],"TPPROC","")
				__cDente  	:= PLSRETDAD(aItens[nH],"DENTE","")+space(TamSx3("BD6_DENREG")[1] - len(PLSRETDAD(aItens[nH],"DENTE")))
				__cFace   	:= PLSRETDAD(aItens[nH],"FACE","")
				__cSequen	:= PLSRETDAD(aItens[nH],"SEQMOV","")
				__cStProc	:= PLSRETDAD(aItens[nH],"STPROC","")

				if (__cCodPad + __cCodPro == cCodPad + cCodPro .and. __cDente + __cFace == cDente + cFace )	// Retira o registro atual da matriz que sera enviada ao PLSAUTP()
					loop

				elseIf !__lAutoriz //	Se o registro atual não estiver autorizado não entra na matriz.
					loop

				endIf

				aadd(aQtdBrow,{	__cCodPad,__cCodPro,__nQtdSol,dDatPro,cHora,__cDente,__cFace,__cSequen})
			next

			//se eh guia de honorario individual nao checa qtd e periodicidade
			if cTipGui == '06'
				//so checo a carencia,Idade,sexo
				aVldGen := {.f.,.f.,.t.,.f.,.t.,.t.,.f.,.f.,.f.,.f.,.f.}
			endIf

			// Se ja fez pre validacao, nao precisa rodar novamente a PLSAUTP
			if nfor <= len(aPrevalid)
				aRetFun := aPrevalid[nfor]
			else

				if cOrigem == "1" .and. !empty(cNumLib)

					BE2->(dbSetOrder(6))
					if BE2->(msSeek(xFilial("BE2") + cNumLib + cCodPad + cCodPro))
						if BE2->BE2_STATUS == "1"
							cStatItem := "1"
						else
							cStatItem := "0"
						endIf
					else
						cStatItem := "0"
					endIf
				endIf

				aRetFun := PLSAUTP( dDatPro,;
						cHora,;
						cCodPad,;
						cCodPro,;
						if(nQtdSol==0,1,nQtdSol),;
						aDadUsr,;
						nRecBD6,;
						iIf(lTrtExe,aRdaProf,aDadRDA),;
						"1",;
						iIf(getNewPar("MV_PLSMODA","1")=="0",.f.,.t.),;
						cCidPri,;
						lTrtUsr,;
						cLocalExec,;
						lSolicit,;
						cOpeSol,;
						cCDPFSO,;
						cAno,;
						cMes,;
						cPadInt,;
						cPadCon,;
						cRegAte,;
						.t.,;
						cCodPRFExe,;
						nil,;
						nil,;
						cOpeExe,;
						nil,;
						cAteRN,;
						nil,nil,nil,nil,;//32
						lRegPagAto,;
						cTipoGrv,;
						cFace,nil,nil,nil,nil,nil,;
						iIf(!empty(cRdaEDI),cRdaEDI,nil),;
						cNuLibera,;
						cAreaAbr,;
						nil,;
						nil,;
						cDente,;
						nil,;
						.f.,;
						iIf(lTratExLib, lTratExLib, (!lSolicit .or. !empty(cCodPRFExe))),;
						.t.,;//50
						cTpProc,;
						cCodEspPro,;
						aQtdBrow,;
						aVldGen,;
						iIf( ! empty(cCodLocPro),cCodLocPro,cCodLoc),;
						nil,;
						nil,;
						cTpProc,;
						lWeb,;
						"BE1",;
						cRegInt,;
						nil,;
						lNegProPac,;
						nil,;
						nil,;
						nil,;
						nil,;
						nil,;
						nil,;
						cEspSol,;//70
						cEspExe,;
						nil,;
						nil,;
						cTipGui,;
						cStProc,;
						nil,;
						nil,;
						nil,;
						lPtuOnline,;
						lInter,;
						@aRetAudPTU,;
						nil,;
						allTrim(str(PLSRETDAD(aItens[1],"VLRAPR",0))),,lNovaLiberacao,;
						nil,;
						cStatItem,;
						nil,;
						nil,;
						cCaraterSol,,cTGOriginal,aProrInt)					//93
			endIf

			If lUrgPTUInter .And. FindFunction("PLAutIntUrgPTU")
				aRetFun := PLAutIntUrgPTU(aRetFun, cCodPad, cCodPro, nQtdSol, cLocalExec, cTipoGrv)
			EndIf

			// Retorno
			if !(lPlAtuRG .and. PLSISURG(cCaraterSol))

				lContinua	:= aRetFun[1]

			else
				aRetFun[1] := .T.
				lContinua	:= aRetFun[1]

			endif

			if len(aRetFun) > 1
				aTrb := aRetFun[2]
			endIf

			/*Se atendimento de urgencia/emergencia e consulta, nao podemos enviar para auditoria:

			6.8. Consultas Eletivas 6.8.1. A Unimed Executora, com prestador on-line no Intercâmbio Eletrônico,
			deve solicitar autorização à Unimed Origem para consultas eletivas, que deverão obrigatoriamente ser
			autorizadas” ou “negadas”. Se a Unimed Origem responder à transação como “em estudo”, o WSD a autorizará,
			conforme definido no item 6.3. - WSD – Intercâmbio. */
			if lConsulta .And. lPtuOnUr
				cAuditoria := "0"
			elseIf valType(aTrb) <> "C"
				cAuditoria := iIf(aScan( aTrb,{|x| x[1] == __aCdCri051[1] } ) > 0, "1", "0")
			endIf

			// Verifica se procedimento em auditoria se enquandra na exceção cadastrada
			// Caso esteja na exceção retira o procedimento da auditoria.
			if ! empty(cAuditoria) .and. cAuditoria == "1"

				//Internação ou Resumo de Internação
				if cTipGui == "03" .or. cTipGui == "05"

					cTpaten := PLSRetAut("3")[1]

					//Anexos
				elseif cTipGui == "07" .or. cTipGui == "08" .or. cTipGui == "09"

					cTpaten := PLSRetAut("7")[1]

				else

					cTpaten := PLSRetAut()[1]

				endif

				//B1O_CODPRO+B1O_TPGUIA+B1O_IDADE+B1O_QTDPRO
				if PLSVLDEX(left( cCodPro + space( TamSX3("B1O_CODPRO")[1] ), TamSX3("B1O_CODPRO")[1] )+cTpaten,aDadUsr[26],nQtdSol)

					if len(aRetFun[2]) == 2
						cAuditoria := "0"
						lImpedeAud := .t.
						lExc := .t.
						aTrb := {}
						lContinua := .t.
						aRetFun[1] := .t.
						aRetFun[2] := {}

					else
						aRetFun[2][Ascan( aTrb,{|x| x[1] == "025"} )][2] := ""
						aRetFun[2][aScan( aTrb,{|x| x[1] == "025"} )][1] := ""
					endIf
				endIf
			endIf

			//Variavel para controle do BEA_TRACON
			if lPtuOnline
				if nFor == 1 .And. lContinua
					lAllAutori := .T.
				elseIf nFor > 1 .And. !lContinua
					lAllAutori := .F.
				endIf
			endIf

			// Deleta criticas de abrangencia quando atendimento de Urg/Emerg. PTU Online
			if lPtuOnUr .and. lPtuOnLine .and. !lContinua .And. !lUrgPTUInter

				aRegCriDel := {}
				nSizeTrb   := 0

				for nCrit := 1 to len(aTrb)
					// Removo as criticas de Abrangencia que nao podem ser exibidas
					if !empty(aTrb[nCrit][1])
						if allTrim(aTrb[nCrit][1]) $ __aCdCri500[1]+"/"+__aCdCri062[1]+"/"+__aCdCri074[1]+"/"+__aCdCri026[1] //"011/032/038/050"
							lDelCriArr := .t.
							PlsPtuLog(cCodPad+"-"+Alltrim(cCodPro)+" -> Removendo crítica de abrangência "+aTrb[nCrit][1]+". Atendimento de Urgência/Emergência.")
						else
							lDelCriArr := .f.
						endIf
					endIf
					// Marca Posicoes do Array que serao deletadas
					if lDelCriArr
						aadd(aRegCriDel,nCrit)
					endIf
				next
				// Deleta posicoes marcadas do array
				if len(aRegCriDel) >0
					for nCrit := 1 to len(aRegCriDel)
						aDel(aTrb,aRegCriDel[(len(aRegCriDel)+1)-nCrit])//Deleto a partir das ultimas posicoes para nao perder o ponteiro
						nSizeTrb ++
					next

					aSize(aTrb,len(aTrb)-nSizeTrb)
				endIf
				// Se nao restou criticas, autorizo o evento
				if len(aTrb) == 0
					lContinua := .t.
					VerCritPTU(aDadIte,aItens[nFor],nil,"1")
				endIf

			endIf

			// Verifica se o evento e de Baixo Risco, caso positivo, o mesmo nao pode ser
			// enviado para estudo.
			if lPtuOnline .and. lBaixoRisc

				lPermAudBR := .f.
				// Verifica criticas que permitem Auditoria no Baixo Risco:
				// 022 - Para este procedimento necessita Guia da Empresa.
				if !lContinua .And. len(aTrb) > 0 .And. lCri022BR
					for nfor2 := 1 To len(aTrb)
						if aTrb[nfor2][1] == __aCdCri052[1]
							lPermAudBR := .t.
						endIf
					next
				endIf


				if !lPermAudBR .and. !lContinua

					//Ajusta array de criticas baseado no campo BCT_ATIVBR
					PLTrabRisc(@aTrb,cCodPad,cCodPro,.T.,cSeqMov,@aEventosNeg,"1")

					// Se restou criticas, aciona o Baixo Risco
					if len(aTrb) > 0
						aRetAudPTU := {.t.,"0"}
					else
						lContinua := .t.
					endIf
				endIf

			endIf

			// Se for solicitacao de consulta PTU Online realizo a gravacao posteriormente
			if !lConPtuOn

				// Utiliza as criticas de cabecalho se existirem
				if lCriCab
					lContinua := .f.
					aTrb      := {}

					// Remove criticas de Baixo Risco se houver
					if lPtuOnline .and. lBaixoRisc
						lPermAudBR := .f.

						BR8->(dbSetOrder(1))//BR8_FILIAL + BR8_CODPAD + BR8_CODPSA + BR8_ANASIN

						// Verifica criticas que permitem Auditoria no Baixo Risco:
						// 022 - Para este procedimento necessita Guia da Empresa.
						if len(aCriticas) > 0 .And. lCri022BR
							for nfor2 := 1 To len(aCriticas)
								if aCriticas[nfor2][1] == __aCdCri052[1]
									lPermAudBR := .t.
								endIf
							next
						endIf

						// Verifica se o evento e de Baixo Risco
						if !lPermAudBR

							//Ajusta array de criticas baseado no campo BCT_ATIVBR
							PLTrabRisc(@aCriticas,cCodPad,cCodPro,.T.,cSeqMov,@aEventosNeg,"2")

							// Se restou criticas, aciona o Baixo Risco
							if len(aRetAudPTU) == 0
								if len(aCriticas) > 0
									aRetAudPTU := {.t.,"0"}
								else
									lContinua := .t.
								endIf
							endIf
						endIf

					endIf

					// Se baixo risco nao posso auditar com criticas de cabecalho

					// IMPORTANTE: A regra consiste em adicionar na posicao 8 do aCriticas o indicativo
					// que nao pode auditar (essa posicao sera utilizada no PLSTRTPTU_SCS2)
					// se no futuro mudarem a montagem do aCriticas aumentado a quantidade de itens no retorno
					// e necessario ajustar esse trecho para a nova posicao
					if len(aRetAudPTU) > 1 .and. aRetAudPTU[1]
						cAuditoria := "0"
						for nPoa :=1 To len(aCriticas)
							if len(aCriticas[nPoa]) == 7
								aadd(aCriticas[nPoa],{.t.,cAuditoria})
							endIf
						next
					else
						BCT->( dbSetOrder(1) )
						for nPoa := 1 To len(aCriticas)
							if !empty(aCriticas[nPoa,2])
								if BCT->( msSeek( xFilial("BCT")+PlsIntPad()+aCriticas[nPoa,2] ) )
									cAuditoria := iIf(BCT->BCT_AUDITO == "1","1","0")
									if cAuditoria == '1'
										exit
									endIf
								endIf
							endIf
						next
					endIf
				endIf

				if len(aRetFun) >= 4
					if lContinua .and. !lAudTodos
						PLSPUTDAD(aItens[nfor],"NIVAUT",aRetFun[3],.t.)
						PLSPUTDAD(aItens[nfor],"CHVNIV",aRetFun[4],.t.)
						PLSPUTDAD(aItens[nfor],"NIVCRI","",.t.)
					else
						PLSPUTDAD(aItens[nfor],"NIVAUT","",.t.)
						PLSPUTDAD(aItens[nfor],"CHVNIV",aRetFun[4],.t.)
						PLSPUTDAD(aItens[nfor],"NIVCRI",aRetFun[3],.t.)
					endIf
				endIf
			endIf

			// Procedimento com Critica 050 (Abrangencia de atendimento nao permitida para este produto.)
			// não força o item para Auditoria quando for OPME
			If ValType(aRetFun[2]) == "A"
				lCritAbrang := IIF(aScan( aRetFun[2], {|x| x[1] == "050" } ) > 0, .T., .F.) //__aCdCri026[1]
			EndIf

			//Eu tenho que limpar as criticas pois caso isso nao seja feita o sistema
			//pode pegar a critica de um procedimento e colocar no outro
			PLLimpCCri(.t.)
		else

			// Limpar outras criticas
			PLLimpCCri(.t.)
			// Valida procedimento
			aRetFun  	:= PLSVLDPTP(cCodPad,cCodPro,clocalExec,cTipoGrv)
			lContinua	:= aRetFun[1]
			if !lContinua
				aTrb := aRetFun[2]
			endIf

		endIf

		// Verifica se e uma importacao A1100
		if lPtuA1100

			if cIdRespWsd == "2" //Autorizado
				aadd(aEventosAut,{cSeqMov,cCodPad,cCodPro,nQtdSol,cDescri,nQtdAut,cDente,cFace,"",cSlvPad,cSlvPro})
				PLSDADITE(aDadIte,aItens[nfor],cOrigem,cLibEsp,"0",cNumImp,"1",dDatPro,aDadRda)
			else
				BCT->(dbSetOrder(4))//BCT_FILIAL+BCT_CODOPE+BCT_CODED2
				if BCT->(msSeek(xFilial("BCT")+PlsIntPad()+cCrRespWsd))
					cCrRespWsd := BCT->(BCT_PROPRI+BCT_CODGLO)
					cDescGlo   := BCT->BCT_DESCRI
					PLSPOSGLO(PLSINTPAD(),cCrRespWsd,BCT->BCT_DESCRI)
				else
					cCrRespWsd := "999"
					cDescGlo   := cCrRespWsd +" - CRITICA PTU ONLINE NAO ENCONTRADA"
				endIf
				PLSDADITE(aDadIte,aItens[nfor],cOrigem,cLibEsp,"0",cNumImp,,dDatPro,aDadRda)
				aadd( aCriticas,{cSeqMov,cCrRespWsd,cDescGlo,"01"/*01*/,cCodPro,"",""} )
			endIf


			//Neste trecho trabalho as condicoes do PTU Online que devo forcar o item para a Auditoria
		elseif (((lFAudMOP .Or. cDsEvento == '1') .And. !lCritAbrang) .Or. ; // Solicitacao PTU descricao de mat/met que nao esta na tabela
				lFAudAte .Or. ; // Solicitacao PTU online com data de atendimento
				lforcAud .Or. ; // Solicitacao PTU com msg de observacao
				lAutoCus .Or. ; // Solicitacao PTU com alto custo
				lPacAudi ) .And. ;// Solicitacao PTU com pacote
				(!lBaixoRisc .And. cCarSol <> "U" .And. !lUrgPTUInter) //Se Baixo Risco ou Urg/Emerg ignoro a regra de envio automatico

			PLSPUTDAD(aItens[nfor],"NIVAUT","",.t.)
			PLSPUTDAD(aItens[nfor],"CHVNIV","",.t.)
			PLSPUTDAD(aItens[nfor],"NIVCRI","OLN",.t.)

			cAuditoria := "1"
			// Verifica a Critica
			Do Case
				Case lFAudMOP .or. cDsEvento == '1'
					PLSPOSGLO(PLSINTPAD(),__aCdCri203[1],__aCdCri203[2])
				Case lFAudAte
					PLSPOSGLO(PLSINTPAD(),__aCdCri106[1],__aCdCri106[2])
				Case lforcAud
					PLSPOSGLO(PLSINTPAD(),__aCdCri202[1],__aCdCri202[2])
				Case lAutoCus
					PLSPOSGLO(PLSINTPAD(),__aCdCri104[1],__aCdCri104[2])
				Case lPacAudi
					PLSPOSGLO(PLSINTPAD(),__aCdCri200[1],__aCdCri200[2])
			EndCase

			nPosNRAOPE := aScan(aItens[nfor],{|x| x[1] == "NRAOPE"})

			if empty(cSenBSN)
				cSenBSN:= PLSNRAOPE()
			endIf
			if nPosNRAOPE > 0
				aItens[nfor][nPosNRAOPE] := cSenBSN
			else
				aadd(aItens[nfor],{"NRAOPE",cSenBSN})
			endIf

			if !VerCritPTU(aDadIte,aItens[nFor],cAuditoria) //Verifica se item ja foi incluido no aDadIte
				PLSDADITE(aDadIte,aItens[nfor],cOrigem,cLibEsp,cAuditoria,cNumImp,,dDatPro,aDadRda)
			endIf

			Do Case
				Case lFAudMOP .Or. cDsEvento == '1'
					aadd(aCriticas,{cSeqMov,__aCdCri203[1],PLSBCTDESC(),cCodPad,cCodPro,cDente,cFace})
				Case lFAudAte
					aadd(aCriticas,{cSeqMov,__aCdCri106[1],PLSBCTDESC(),cCodPad,cCodPro,cDente,cFace})
				Case lforcAud
					aadd(aCriticas,{cSeqMov,__aCdCri202[1],PLSBCTDESC(),cCodPad,cCodPro,cDente,cFace})
				Case lAutoCus
					aadd(aCriticas,{cSeqMov,__aCdCri104[1],PLSBCTDESC(),cCodPad,cCodPro,cDente,cFace})
				Case lPacAudi
					aadd(aCriticas,{cSeqMov,__aCdCri200[1],PLSBCTDESC(),cCodPad,cCodPro,cDente,cFace})
			EndCase
			aadd(aEventosNeg,{cSeqMov,cCodPad,cCodPro,nQtdSol,cDescri,nQtdAut,cDente,cFace,"",cSlvPad,cSlvPro})

			// Se autorizou ou criticou
		elseIf !lContinua

			//Se for solicitacao de consulta PTU Online realizo a gravacao posteriormente
			if !lConPtuOn
				BCT->( dbSetOrder(1) ) //BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO
				for nfor2 := 1 To len(aTrb)

					//somente verifica no codigo da critica e nao no detalhamento.
					if !empty(aTrb[nfor2,1])

						//Realizo esse ascan para não repetir criticas de cabecalho
						lAddCritica := aScan( aCriticas, {|x| x[1] == cSeqMov .And. x[2] == aTrb[nfor2,1] .And. x[4] == aTrb[nfor2,6] .And. x[5] == Alltrim(aTrb[nfor2,7])  }) == 0

						//Se vai para liberacao especial
						cLibEsp := PLSLIBESP(cFilBCT+cOpeMov+aTrb[nfor2,1],cLibEsp,cOrigem,cCodPad,cCodPro)

						//Se a critica coloca na auditoria
						if cAuditoria <> "1"

							//Ponto de entrada para indicar se o procedimento vai para auditoria PTU On
							if  lPtuOnline .and. lPLAUPTON
								cAuditoria := execBlock("PLAUPTON",.f.,.f.,{aDadUsr,aTrb,cOpeSol,aRetAudPTU} )
								aRetAudPTU := {.t.,cAuditoria}
							else
								//Verifico se a critica dele colocar o procedimento em auditoria
								if BCT->( msSeek( xFilial("BCT")+PlsIntPad()+aTrb[nfor2,1] ) )
									cAuditoria := iIf(BCT->BCT_AUDITO == "1","1","0")
								endIf

								//aRetAudPTU indica se o item pode ser enviado ou nao para auditoria
								//Implementado para a regra de item com valor inferior a 6 consultas
								if len(aRetAudPTU) > 1
									cAuditoria := aRetAudPTU[2]
									lAudTodos  := .f. //Se baixo risco, nao posso enviar registros para auditoria
								endIf

								//Nao posso enviar o item para estudo, devo forcar a negacao
								if lNegAllIte
									if cAuditoria == "1"
										PlsPtuLog("Utilizado o parâmetro MV_PTCRINE para nao permitir o envio de eventos para Auditoria.")
									endIf

									if len(aRetAudPTU) > 1
										aRetAudPTU[2] := "0"
									else
										cAuditoria := "0"
										aRetAudPTU := {.t.,cAuditoria}
									endIf
								else
									//Coloca na auditoria
									if aTrb[nfor2,1] == __aCdCri051[1] .and. len(aRetAudPTU) < 2
										cAuditoria := "1"
									endIf
									//Quando for critica de guia da empresa tb vai para auditoria ptu-online
									if lAudEmp
										if aTrb[nfor2,1] == __aCdCri052[1] .and. len(aRetAudPTU) < 2
											cAuditoria := "1"
										endIf
									endIf
								endIf

								//Se PTU Online de Urgencia/Emergencia, nao posso enviar para a auditoria
								if lPtuOnline .And. cCarSol == "U" .And. !(aTrb[nfor2,1] $ cCriUrgAud)
									cAuditoria := "0"
								endIf

							endIf
						endIf
					endIf
					//Aqui eu evito de gerar demanda desnecessária na auditoria caso ocorra alguma critica absurda no portal (parametrizado no cadastro da critica), exemplo Sexo incompativel não precisa ir pra auditoria, caso o procedimento também esteja configurado pra auditar
					if BCT->BCT_NAOAUD == "1"
						cAuditoria := "0"
						lImpedeAud := .t.
					endIf

					if lAddCritica
						aadd( aCriticas,{cSeqMov,aTrb[nfor2,1],allTrim(aTrb[nfor2,2])+iIf(len(aTrb[nfor2])>=3 .and. !empty(aTrb[nfor2,3]),' ( '+aTrb[nfor2,3]+' ) ',''),aTrb[nfor2,6],aTrb[nfor2,7],"","",iIf(len(aRetAudPTU) > 1,{.t.,cAuditoria},{.f.,""})} )
					endIf
				next
				// Ajusta baixo risco quando houver critica de cabecalho
				if len(aTrb) == 0 .and. lCriCab .and. len(aRetAudPTU) > 1
					cAuditoria := aRetAudPTU[2]
					lAudTodos  := .f. //Se baixo risco, nao posso enviar registros para auditoria
				endIf
				//Aqui eu evito de gerar demanda desnecessária na auditoria caso ocorra alguma critica absurda no portal (parametrizado no cadastro da critica), exemplo Sexo incompativel não precisa ir pra auditoria, caso o procedimento também esteja configurado pra auditar
				if lImpedeAud
					cAuditoria := "0"
				endIf
				// Matriz
				if cAuditoria == "0" .and. len(aCriticas) > 0
					nPosNRAOPE := aScan(aItens[nfor],{|x| x[1] == "NRAOPE"})
					if nPosNRAOPE > 0
						aItens[nfor][nPosNRAOPE] := replicate ("0",10)
					else
						aadd(aItens[nfor],{"NRAOPE",replicate ("0",10)})
					endIf
				endIf

				if lPtuOnline //Se PTU Online verifica se o item ja esta no aDadIte
					VerCritPTU(aDadIte,aItens[nFor],iIf(lAudTodos,"1",cAuditoria))
				endIf
				PLSDADITE(aDadIte,aItens[nfor],cOrigem,cLibEsp,iIf(lAudTodos,"1",cAuditoria),cNumImp,,dDatPro,aDadRda)

				//Verifico se o evento ja havia sido adicionado anteriormente com critica de cabecalho
				if aScan( aEventosNeg, {|x| x[1] == cSeqMov .And. x[2] == cCodPad .And. x[3] == Alltrim(cCodPro) }) == 0
					aadd(aEventosNeg,{cSeqMov,cCodPad,cCodPro,nQtdSol,cDescri,nQtdAut,cDente,cFace,"",cSlvPad,cSlvPro})
				endIf

			else
				// Retorno para solicitacao de consulta PTU Online
				aRet := {.f.}
			endIf

		elseIf lAudTodos  //Envia todos itens a auditoria quando um unico for marcado para auditar

			PLSPUTDAD(aItens[nfor],"NIVAUT","",.t.)
			PLSPUTDAD(aItens[nfor],"CHVNIV","",.t.)
			PLSPUTDAD(aItens[nfor],"NIVCRI","OLN",.t.)

			cAuditoria := "1"

			PLSPOSGLO(PLSINTPAD(),__aCdCri107[1],__aCdCri107[2])

			nPosNRAOPE := aScan(aItens[nfor],{|x| x[1] == "NRAOPE"})

			if empty(cSenBSN)
				cSenBSN:= PLSNRAOPE()
			endIf
			if nPosNRAOPE > 0
				aItens[nfor][nPosNRAOPE] := cSenBSN
			else
				aadd(aItens[nfor],{"NRAOPE",cSenBSN})
			endIf

			if !VerCritPTU(aDadIte,aItens[nFor],cAuditoria) //Verifica se item ja foi incluido no aDadIte
				PLSDADITE(aDadIte,aItens[nfor],cOrigem,cLibEsp,cAuditoria,cNumImp,,dDatPro,aDadRda)
			endIf

			aadd(aCriticas,{cSeqMov,__aCdCri107[1],PLSBCTDESC(),cCodPad,cCodPro,cDente,cFace})
			aadd(aEventosNeg,{cSeqMov,cCodPad,cCodPro,nQtdSol,cDescri,nQtdAut,cDente,cFace,"",cSlvPad,cSlvPro})

		else
			// Se for solicitacao de consulta PTU Online realizo a gravacao posteriormente
			if !lConPtuOn

				if aScan(aEventosNeg,{|x| allTrim(x[1]+x[2]+x[3]+x[7]+x[8]) == allTrim(cSeqMov+cCodPad+cCodPro+cDente+cFace) } ) > 0
					loop
				endIf

				if ( nPos := aScan(aCriticas,{|x| x[2]+allTrim(x[1]+x[4]+x[5]+x[6]+x[7]) == __aCdCri064[1]+allTrim(cSeqMov+cCodPad+cCodPro+cDente+cFace) } )  ) > 0
					// Se gera log caixa preta
					if lWLIO
						if lLogEx
							PlsLogFil(space(03)+"ATENÇÃO",__PLSFLOGX)
							lLogEx := .f.
						endIf
						PlsLogFil(space(03)+aCriticas[nPos,1]+space(02)+aCriticas[nPos,5]+space(06)+aCriticas[nPos,2]+space(05)+aCriticas[nPos,3]+space(02),__PLSFLOGX)
					endIf

					nSize := len(aCriticas)
					aDel(aCriticas,nPos)
					aSize(aCriticas,nSize-1)
				endIf

				if  len(aRetFun) > 5 .and. aRetFun[5]
					aValor := aRetFun[6]
					if aValor[1] .and. aValor[16] == "1" .and. if( len(aValor)>=27, !aValor[27], .t. )

						if  len(aCliente)==0
							if BA3->BA3_TIPOUS=="1"
								aCliente := PLBUSCACLIEN("1","1",aDadUsr)
							else
								aCliente := PLBUSCACLIEN("2","1",aDadUsr)
							endIf
						endIf

						if (!aCliente[1]) .or. (aValor[12]==0 .and. BR8->BR8_PODDIG<>"1")

							PLSPOSGLO(PLSINTPAD(),__aCdCri116[1],__aCdCri116[2])

							if lPtuOnline //Se PTU Online verifica se o item ja esta no aDadIte
								VerCritPTU(aDadIte,aItens[nFor],cAuditoria)
							endIf

							PLSDADITE(aDadIte,aItens[nfor],cOrigem,cLibEsp,cAuditoria,cNumImp,,dDatPro,aDadRda)

							aadd(aCriticas,{cSeqMov,__aCdCri116[1],PLSBCTDESC(),cCodPad,cCodPro,cDente,cFace})
							aadd(aEventosNeg,{cSeqMov,cCodPad,cCodPro,nQtdSol,cDescri,nQtdAut,cDente,cFace,"",cSlvPad,cSlvPro})
							loop
						else
							if aScan(aDadBea,{|X| X[1] == "BEA_PAGATO"})==0
								aadd(aDadBea,{"BEA_PAGATO","1"})
								aadd(aDadBea,{"BEA_GUIACO","1"})
								aadd(aDadBea,{"BEA_QUACOB","1"})
								aadd(aDadBea,{"BEA_CODCLI",aCliente[3]})
								aadd(aDadBea,{"BEA_LOJA",aCliente[4]})
							endIf

							nPos := aScan(aDadBea,{|X| X[1] == "BEA_VALOR"})
							if nPos==0
								aadd(aDadBea,{"BEA_VALOR",aValor[12]})
							else
								aDadBea[nPos,2] += aValor[12]
							endIf
							PLSPUTDAD(aItens[nfor],"VLCOMP",aValor[12], .t. )
							lAto :=  .t.
						endIf
					endIf
				endIf

				// Critica
				if getNewPar("MV_PTUVEON","50") >= "60"

					if lAprovLib .and. lWeb .and. !empty(BEA->BEA_NRTROL)

						nTraiTePTU := aScan(aItens[nfor],{|x| x[1] == "TRAITEPTU"})

						if nTraiTePTU > 0
							aItens[nfor][nTraiTePTU]:= BEA->BEA_NRTROL
						else
							aadd(aItens[nfor],{"TRAITEPTU",BEA->BEA_NRTROL})
						endIf

					endIf

					nPosNRAOPE := aScan(aItens[nfor],{|x| x[1] == "NRAOPE"})
					if empty(cSenBSN)
						cSenBSN:= PLSNRAOPE()
					endIf
					if nPosNRAOPE > 0
						aItens[nfor][nPosNRAOPE] := cSenBSN
					else
						aadd(aItens[nfor],{"NRAOPE",cSenBSN})
					endIf
				endIf

				if lPtuOnline //Se PTU Online verifica se o item ja esta no aDadIte
					VerCritPTU(aDadIte,aItens[nFor],iIf(lAudTodos,"1",cAuditoria))
				endIf

				PLSDADITE(aDadIte,aItens[nfor],cOrigem,cLibEsp,iIf(lAudTodos,"1",cAuditoria),cNumImp,'1',dDatPro,aDadRda)

				aadd(aEventosAut,{cSeqMov,cCodPad,cCodPro,nQtdSol,cDescri,nQtdAut,cDente,cFace,"",cSlvPad,cSlvPro,nVlrAut})
				iIf(cTpProc=='4',(nQtdDiAut += nQtdSol),nil)
			else
				// Retorno para solicitacao de consulta PTU Online
				aRet := {.t.}
			endIf
		endIf

		// Adiciona campos especificos da BQV - utilizar qdo o campo nao existir na BE2 ³
		aAux := {}
		Aadd(aAux,{"BQV_SEQUEN",cSeqMov})
		Aadd(aAux,{"BQV_TOKEDI",PlsPtuGet("TOKEDI",aItens[nFor])})
		Aadd(aAux,{"BQV_PROATE",PlsPtuGet("PROTOC",aItens[nFor])})
		Aadd(aAux,{"BQV_NRTROL",PlsPtuGet("TRAITEPTU",aItens[nFor])})
		Aadd(aBQVPTUDif,aAux)

	next
	// Retorna com o conteudo original
	if !lXMLLote
		PLLimpCCri(.f.,.t.,aOldCri)
	endIf

return(aRet)

/*/{Protheus.doc} PLSXMOVONL
Validacoes regras de usuario de intercambio para operadora online
@type function
@author Alexander Santos
@since 17.07.08
@version 1.0
/*/
function PLSXMOVONL(aItens,lAprovLib,lTrtUsr,lConsulta,cOrigem,cAno,cMes,dDatPro,cHora,aDadUsr,aDadRDA,cCidPri,;
					clocalExec,cOpeSol,cCDPFSO,cPadInt,cPadCon,cRegAte,cCodPRFExe,cOpeExe,lRegPagAto,cTipoGrv,cAreaAbr,;
					cCodEsp,cCodLoc,cFilBCT,cViaCartao,cOpeOri,cLibEsp,cCodRda,cNumImp,nQtdDiAut,nQtdDiNeg,aDadIte,;
					aCriticas,aEventosNeg,aEventosAut,aDadBEA,aDados,cOriMov,cCarSol,cIndCli,lCriTime,cTranOS,lInter,;
					cIndAci,cAteRN,lEvolu,cProtoc,cTokEdi,aAutoPTU,cEspSol,cTipoAte,cCodEspNw,cSadOcuNw)

	Local cNrSeqTR  	:= ""
	Local nPos 			:= 0
	Local nI,nY			:= 0
	Local nfor2,nfor	:= 0
	Local nQtdSol 		:= 0
	Local nQtdAut 		:= 0
	Local nPerVia 		:= 0
	Local cSeqMov 		:= ""
	Local cCodPad 		:= ""
	Local cCodPro 		:= ""
	Local cTpProc 		:= ""
	Local cPROCCI 		:= ""
	Local cVia    		:= ""
	Local cSigla  		:= ""
	Local cEstCr 		:= ""
	Local cNumCr 		:= ""
	Local cTpTab		:= ""
	Local cTpTabRef		:= ""
	Local cAuditoria	:= "0"
	Local cDesOPM 		:= ""
	Local cTipGui		:= ""
	Local cCodCri		:= ""
	Local cDesCri		:= ""
	Local cCriDesc		:= ""
	Local cTpAut		:= ""
	Local cSenhaOpe 	:= ""
	Local cMsg03 	  	:= ""
	Local cAutori       := ""
	Local aProcAux    	:= {}
	Local aValor		:= {}
	Local aRdas			:= {}
	Local lCirurgico	:= .f.
	Local lOnLine		:= .t.
	Local lVeioComu		:= .f.
	Local cTipUrg       := ""
	Local cVerPtuOn     := getNewPar("MV_PTUVEON","40")
	Local cDecItem      := ""
	Local cQtdItem      := ""
	Local cDatValid     := ""
	Local lTVBA0BAU		:= getNewPar("MV_PTUTIVE",.f.)
	Local cTVerPTU      := PlsTissVer()
	Local cRegAnv		:= ""
	Local lPTUOn80   	:= GetNewPar("MV_PTUVEON","80") >= "80"
	Local cDtSolic  	:= DtoS(dDataBase)
	Local cTpAcomod		:= ""
	Local cTpGuia		:= ""
	Local aRetPTU		:= {}
	Local cTpEtapaAut   := ""
	Local lPTUOn90   	:= GetNewPar("MV_PTUVEON","90") >= "90"
	Local cNomeSocial 	:= ""

	Default cCDPFSO := ""
	Default cCarSol := ""
	Default cIndCli := ""
	Default lCriTime := .f.
	Default cTranOS := replicate("0",10)
	Default lInter := .f.
	Default cIndAci := "9"
	Default cAteRN := "0"
	Default lEvolu := .f.
	Default cProtoc := ""
	Default cTokEdi := ""
	Default aAutoPTU := {.F.,""}
	Default cEspSol := ""
	Default cTipoAte := "" 
	Default cCodEspNw := ""
	Default cSadOcuNw := ""

	// Executante
	BB0->( dbSetOrder(1) )
	if ! empty(allTrim(cCodPRFExe))
		if BB0->(msSeek(xFilial("BB0")+cCodPRFExe))
			cEstCr := BB0->BB0_ESTADO
			cNumCr := BB0->BB0_NUMCR
		endIf
	endIf

	// Monta a matriz de procedimentos
	for nfor := 1 To len(aItens)

		cSeqMov := PLSRETDAD(aItens[nfor],"SEQMOV")
		cCodPad := PLSRETDAD(aItens[nfor],"CODPAD")
		cCodPro := PLSRETDAD(aItens[nfor],"CODPRO")
		cDescri	:= PLSRETDAD(aItens[nfor],"DESCRI","")
		nQtdSol := PLSRETDAD(aItens[nfor],"QTD",0)
		nQtdAut := PLSRETDAD(aItens[nfor],"QTDAUT",0)
		cTpProc	:= PLSRETDAD(aItens[nfor],"TPPROC","")
		cTipEve	:= PLSRETDAD(aItens[nfor],"TIPEVE","")
		dDatInc	:= PLSRETDAD(aItens[nfor],"DATINC",ctod(""))
		cDente 	:= PLSRETDAD(aItens[nfor],"DENTE","")
		cFace  	:= PLSRETDAD(aItens[nfor],"FACE","")
		cRegAnv	:= PLSRETDAD(aItens[nfor],"CD_ANVISA","")
		cGuiJur	:= PLSRETDAD(aItens[nfor],"ID_LIMINAR","")

		// Se quantidade autorizada for igual a zero pulo pois nao posso envia-lo
		if nQtdAut == 0
			loop
		endIf

		if lEvolu .and. cOrimov =="2" .and. empty(cIndCli)
			cIndCli := allTrim(PLSRETDAD(aItens[nfor],"INDCLIEVO"))
		endIf
		
		// 18 = TUSS Taxas hospitalares,diárias e gases medicinais
		// 19 = TUSS Materiais
		// 20 = TUSS Medicamentos
		// 22 = TUSS Procedimentos e eventos em saúde(medicina,odonto e demais áreas de saúde)
		// 98 = Tabela Própria de Pacotes
		// 00 = Tabela Própria das Operadoras
		cTpTab := PLSRETDAD(aItens[nfor],"TPTAB","")

		If cTpTab == "00" // Tabela Própria, pega a tabela de Referência
			cTpTabRef := PLSRETDAD(aItens[nfor],"TPTABREF","")
		EndIf
		
		// Vai na tde para verificar se o procedimento ja foi informado para unimed brasil
		// Somente se for ortese/protese ou material

		if cTpProc $ '5,1,2,6' .and. empty(dDatInc )

			// Descricao do procedimento nao enviar para pacote
			cDesOPM := left(cDescri,80)
			cSigla  := getNewPar("MV_PLSIGLA","CRM")

			// Se uma consulta ou exame
			if lConsulta
				cTipGui := "01"
			else
				cTipGui := "02"
			endIf
			// Monta matriz rdas
			aRdas := PLS720IBD7("0",0,cCodPad,cCodPro,"",cOpeSol,cCodRda,cNumCr,cSigla,cEstCr,cCodPRFExe,;
				cCodEsp,cCodLoc,"3",cSeqMov,cOriMov,cTipGui)

			// Se e cirurgico ou nao 1=Clinico;2=Cirurgico;3=Ambos
			cPROCCI 	:= iIf(cTipEve $ "2,3", "1","0")
			lCirurgico  := (cPROCCI == "1")
			cVia    	:= iIf(cPROCCI=="1",getNewPar("MV_PLSVAPR","0"),"")
			nPerVia 	:= plRtPerV(cVia)

			// Calcula o valor do procedimento
			aValor := PLSCALCEVE(cCodPad,cCodPro,cMes,cAno,PlsIntPad(),cCodRda,cCodEsp,iIf(len(aDadRDA)>0,aDadRda[21],""),cCodLoc,nQtdSol,;
				dDatPro,aDadUsr[48],cPadInt,cRegAte,0,aDadUsr,cPadCon,;
				{},nil,nil,nil,nil,cHora,aRdas,nil,nil,nil,{},nil,dDatPro,cHora,{},cTipGui,.f.,0,{},nil,;
				lCirurgico,nPerVia,"","",nQtdSol,0)

			// Verifica se consegue pegar o valor do procedimento
			for nI := 1 To len(aValor[1])

				if !empty(aValor[1][nI][4])
					aadd(aCriticas,{cSeqMov,aValor[1][nI][4],allTrim(cCodPro)+"-> ( " + allTrim(aValor[1][nI][4]) + " )","",""})
					lOnLine := .f.
				endIf

			next

		endIf

		If cTpTab $ "22/98" .Or. (cTpTab == "00" .And. cTpTabRef == "22")
			cQtdItem := cValToChar(nQtdAut)
		else
			cDecItem := cValToChar(nQtdAut - Int(nQtdAut))
			cDecItem := Padr(Substr(cDecItem,3,len(cDecItem)),4,"0")
			cQtdItem := cValtoChar(int(nQtdAut) )+"."+cDecItem
		endIf

		// Monta matriz
		aadd( aProcAux,{} )

		PlsPtuPut("TP_TABELA"	,cTpTab	,aProcAux[len(aProcAux)])			   	//Identifica o Tipo de Tabela utilizado no Servico Medico.
		PlsPtuPut("CD_SERVICO"	,cCodPro,aProcAux[len(aProcAux)])	   	 		//Codigo do Servico.
		PlsPtuPut("QT_SERVICO"	,cQtdItem,aProcAux[len(aProcAux)])	
		PlsPtuPut("CODPAD"	    ,cCodPad,aProcAux[len(aProcAux)])	   	 		//CodPad para ponto de entrada PLPTUITE
		PlsPtuPut("TP_ANEXO","9",aProcAux[len(aProcAux)])//Anexo nao habilitado ainda para o Portal do Prestador
		PlsPtuPut("QT_FREQUEN","00",aProcAux[len(aProcAux)])

		// Informar que o procedimento ainda nao foi cadastrado na unimed brasil
		if !empty(cDesOPM)
			// Alimenta a matriz obs. descricao somente para diferente de pacote
			if !(cTpTab $ '4/98')
				PlsPtuPut("DS_OPME",cDesOPM,aProcAux[len(aProcAux)])	    						   				//Descricao do procedimento de ortese/protese e material
			endIf
			PlsPtuPut("VL_SERVICO" ,StrTran(strZero(noRound(aValor[2],2),15,2),".",""),aProcAux[len(aProcAux)])	//Valor do procedimento
		endIf

		if lEvolu .and. cOrimov =="2"
			PlsPtuPut("DS_IND_CLI"	,cIndCli,aProcAux[len(aProcAux)])	   	 		//Indicacao clinica da prorrogacao
		endIf

		PlsPtuPut("SQ_ITEM", strZero(nfor,2), aProcAux[len(aProcAux)])
		PlsPtuPut("CD_ANVISA", cRegAnv, aProcAux[len(aProcAux)])
		PlsPtuPut("ID_PACOTE","N",aProcAux[len(aProcAux)])
	next

	// Mesmo padrao plsxmov desta forma o pos e web poderao usar
	PlsPtuPut("VIACAR",strZero(val(cViaCartao),2),aDados)

	// Altera para trasancao Ptu Online
	If !lPTUOn90
		nPos := aScan(aDados,{|x| x[1] == "TP_CLIENTE"})
		if nPos > 0
			aDados[nPos][2] := "UNIMED"
		endIf
	EndIf

	// Consulta ou Exame
	if lConsulta
		PlsPtuPut("TP_ATENDIM","0",aDados)  //Nao se aplica
	else
		PlsPtuPut("TP_ATENDIM","1",aDados)  //Atendimento Ambulatorial
	endIf

	if cGuiJur == 'N'
		PlsPtuPut("ID_LIMINAR","0",aDados)
	else
		PlsPtuPut("ID_LIMINAR","1",aDados)
	endIf

	// Indicador de Urgencia/Emergencia - S=Sim/N=Nao
	if findFunction('PGetTisVer') .and. PGetTisVer() >= '3'
		cTipUrg := allTrim(PLSVARVINC("23","BDR",getNewPar("MV_PLURGTS","2") ) )
		iIf(allTrim(cCarSol) == cTipUrg,PlsPtuPut("ID_URG_EME","S",aDados),PlsPtuPut("ID_URG_EME","N",aDados))	//Indicador de Urgencia
	else
		iIf(allTrim(cCarSol) == "U",PlsPtuPut("ID_URG_EME","S",aDados),PlsPtuPut("ID_URG_EME","N",aDados))	//Indicador de Urgencia
	endIf

	// Remove quebra de linha da indicacao clinica
	cIndCli := StrTran(cIndCli,Chr(13)+Chr(10),space(1))
	cIndCli := StrTran(cIndCli,Chr(10),space(1))

	// Genericos
	PlsPtuPut("CTIPREQ","0",aDados)
	PlsPtuPut("OPEMOV",PlsIntPad(),aDados)
	PlsPtuPut("USUARIO",Subs(aDadUsr[3],iIf(len(aDadUsr[3])=16,4,5)),aDados)
	PlsPtuPut("CIDPRI",cCidPri,aDados)
	PlsPtuPut("CODESP",cCodEsp,aDados)
	PlsPtuPut("DS_IND_CLI",cIndCli,aDados)
	// Usadas na transacao diretamente
	PlsPtuPut("CD_UNI_DES",cOpeOri,aDados)										//Codigo da Unimed Destino da transacao.
	PlsPtuPut("CUNIDOM",cOpeOri,aDados)							 			    //Para qual operadora enviar
	PlsPtuPut("CD_UNI",cOpeOri,aDados)										    //Codigo da Unimed

	if !lEvolu
		PlsPtuPut("CD_TRANS","00600",aDados)			    //Codigo da Transacao
	else
		PlsPtuPut("CD_TRANS","00605",aDados)							//Envio de Complemento
		PlsPtuPut("NR_TRANS_R",BEA->BEA_NRTROL,aDados)            //Transacao original
	endIf

	PlsPtuPut("ID_RN",iIf(cAteRN=="1","S","N"),aDados)                                                   //21 ID_RN Indica se o beneficiário é recém-nato

	If !lPTUOn90
		if cIndAci == "0"
			PlsPtuPut("ID_ACIDENT","1",aDados)                                              //23 Indicador de Acidente
		elseIf cIndAci == "1"
			PlsPtuPut("ID_ACIDENT","2",aDados)                                              //23 Indicador de Acidente
		elseIf cIndAci == "2"
			PlsPtuPut("ID_ACIDENT","3",aDados)                                              //23 Indicador de Acidente
		else
			PlsPtuPut("ID_ACIDENT","9",aDados)                                              //23 Indicador de Acidente
		endIf
	EndIf

	PlsPtuPut("CD_UNI_ATE",PlsIntPad(),aDados) 										//27 CD_UNI_ATEND - Código da Unimed na qual o Beneficiário será atendido
		
	If !lPTUOn90
		PlsPtuPut("ID_ANEXO","N",aDados)                                                //28 ID_ANEXO - Indica a existência de um anexo na transação		
		PlsPtuPut("TP_SEXO",iIf(aDadUsr[25]=="2","3","1"),aDados) 						//29 TP_SEXO - Sexo do Beneficiário
		PlsPtuPut("NR_IDADE",strZero(aDadusr[27],3),aDados) 							//30 NR_IDADE - Idade do Beneficiário
	EndIf

	if lTVBA0BAU
		BA0->(dbSetOrder(1))
		if BA0->( msSeek(xFilial("BA0")+PLSIntPad() ) )
			if !empty(BA0->BA0_TISVER)
				cTVerPTU := allTrim(BA0->BA0_TISVER)
			endIf
		endIf
	endIf

	PlsPtuPut("NR_VER_TIS",cTVerPTU,aDados)		 //34 NR_VER_TISS  - Número de versão da TISS que o prestador enviou a transação

	if lInter
		PlsPtuPut("DT_SUG_INT",DtoS(dDataBase),aDados)
		Do case
			case cGrpInt == "1" //1 = Internação Clínica
				PlsPtuPut("TP_INTERNA","1",aDados)
			case cGrpInt  == "2" //2 = Internação Cirúrgica
				PlsPtuPut("TP_INTERNA","2",aDados)
			case cGrpInt == "3" //3 = Internação Obstétrica
				PlsPtuPut("TP_INTERNA","3",aDados)
			case cGrpInt == "4" //6 = Internação Pediátrica
				PlsPtuPut("TP_INTERNA","6",aDados)
			case cGrpInt == "5" //7 = Internação Psiquiátrica
				PlsPtuPut("TP_INTERNA","7",aDados)
		endCase
	endIf

	// Número da Transação da Ordem de Serviço
	if !empty(cTranOS)
		PlsPtuPut("NR_IDE_OS",cTranOS,aDados)								     	
	else
		PlsPtuPut("NR_IDE_OS",replicate("0",10),aDados)							
	endIf

	If !lPTUOn90
		PlsPtuPut("ID_ORDEM_S", IIf(!Empty(cTranOS), "S", "N"), aDados) // Indica se o pedido de autorização foi gerado através de uma comunicação de Ordem de Serviço
	EndIf

	BAU->(dbSetOrder(1))
	BAU->(dbSeek(xFilial('BAU') + cCodRda ))

	// 1 = Solicitação de autorização Prévia
	// 2 = Solicitação de autorização pelo prestador executante
	cTpEtapaAut := IIF(BAU->BAU_CODIGO == GetNewPar("MV_PLSRDAG","999999"),"1","2")

	If Len(aDadRDA) > 0 .And. (cTpEtapaAut == "2" .Or. BAU->BAU_TIPRED $ "2/3" .Or. (lInter .Or. (lEvolu .And. cOrimov == "2")) .Or. !lPtuOn80) // Mandatório se internação ou tipoEtapaAutorizacao = 2 ou tpRedeMIN = 2 ou 3.

		PlsPtuPut("ID_ALTO_CU",iIf(aDadRda[30]=="1","1","3"),aDados)			//Identifica se prestador da transacao de Alto Custo
		PlsPtuPut("NM_PRESTAD",Pad(aDadRda[6],25),aDados)						//Nome do prestador de Alto Custo.
		PlsPtuPut("CD_UNI_PRE",PlsIntPad(),aDados)                              //Codigo da Unimed do Prestador do Servico.
		PlsPtuPut("CD_PREST",Padl(aDadRda[2],8,"0"),aDados)                     //Codigo do Prestador
		PlsPtuPut("TIPO_REDE_",BAU->BAU_TIPRED, aDados)

		If lPTUOn90
			If !Empty(cCodEsp)
				BAQ->(DbSetOrder(1))
				If BAQ->(MsSeek(xFilial("BAQ")+PlsIntPad()+cCodEsp))
					If !Empty(BAQ->BAQ_CBOS)
						PlsPtuPut("CD_CBO_EXEC", StrZero(Val(BAQ->BAQ_CBOS), 6), aDados)
					EndIf
				EndIf
			EndIf
		EndIf

	EndIf

	PlsPtuPut("CD_IBGE", BAU->BAU_MUN, aDados)
	PlsPtuPut("ID_LIMINAR", "N", aDados)
	PlsPtuPut("PROT_ATEND",cProtoc,aDados)
	PlsPtuPut("TOKEN",cTokEdi,aDados)

	cTpGuia := IIF(lInter .Or. (lEvolu .And. cOrimov == "2"),"3",IIF(lConsulta,"1","2")) // 1 = Consulta , 2 = SP/SADT , 3 = Internação
	PlsPtuPut("TP_GUIA",cTpGuia,aDados)

	If cTpGuia == "3" // Quando for uma Internação ou Prorrogação de Internação
		If BI4->(DbSeek(xFilial("BI4")+aDadUsr[17])) // 17 = Acomodação
			Do Case
				Case BI4->BI4_CODEDI == "1" // Apartamento(Individual)
					cTpAcomod := Padr("B",2)
				Case BI4->BI4_CODEDI == "2" // Enfermaria(Coletiva)
					cTpAcomod := Padr("A",2)
				Case BI4->BI4_CODEDI $ "3/4"// Não se aplica
					cTpAcomod := Padr("C",2)
				Otherwise
					cTpAcomod := ""
			EndCase
		EndIf
	Else
		cTpAcomod := "C" // Quando for informado no campo tipoGuia = 1 (Consulta) ou 2 (SADT), utilizar a opção C = Não se Aplica.
	EndIf

	PlsPtuPut("TP_ACOMODAC",cTpAcomod,aDados)
	PlsPtuPut("TP_ETAP_AUT",cTpEtapaAut,aDados) // 2 = Solicitação de autorização pelo prestador executante
	PlsPtuPut("DT_SOLICIT" ,cDtSolic,aDados) // Momento em que a Unimed Prestadora toma conhecimento do pedido

	If lPTUOn90
		// Classifica o tipo de atendimento quando se tratar de Saúde Ocupacional
		If !Empty(cSadOcuNw)
			PlsPtuPut("ID_SAUDEOCUP", cValToChar(Val(cSadOcuNw)), aDados)
		Else
			If !Empty(cTipoAte)
				Do Case
					Case cTipoAte == "14" // Admissional
						PlsPtuPut("ID_SAUDEOCUP", "1", aDados)

					Case cTipoAte == "15" // Demissional
						PlsPtuPut("ID_SAUDEOCUP", "2", aDados)

					Case cTipoAte == "16" // Periódico
						PlsPtuPut("ID_SAUDEOCUP", "3", aDados)

					Case cTipoAte == "17" // Retorno ao trabalho 
						PlsPtuPut("ID_SAUDEOCUP", "4", aDados)

					Case cTipoAte == "18" // Mudança de função 
						PlsPtuPut("ID_SAUDEOCUP", "5", aDados)

					Case cTipoAte == "19" // Promoção à saúde
						PlsPtuPut("ID_SAUDEOCUP", "6", aDados)
				EndCase
			EndIf
		EndIf

		// Indica cobertura especial de atendimento
		If cTVerPTU >= "4.00.00" .And. !Empty(cCodEspNw)
			PlsPtuPut("ID_COBESPE", cValToChar(Val(cCodEspNw)), aDados) 
		EndIf

		// Dados de Prestador Solicitante, somente para guias de consulta não deverá ser enviado
		If !lConsulta
			If !Empty(cCDPFSO)
				BB0->(dbSetOrder(1))
				If BB0->(MsSeek(xFilial("BB0")+cCDPFSO))

					If FwIsNumeric(Alltrim(BB0->BB0_CODIGO))
						PlsPtuPut("CD_UNI_REQ", BB0->BB0_CODOPE, aDados)
						PlsPtuPut("CD_PRE_REQ", PadL(BB0->BB0_CODIGO, 8, "0"), aDados)
					EndIf

					PlsPtuPut("NM_PRO_SOLIC", PadR(BB0->BB0_NOME, 70, ""), aDados)
					PlsPtuPut("SG_CONSEL", BB0->BB0_CODSIG, aDados)
					PlsPtuPut("NM_CONSEL", BB0->BB0_NUMCR, aDados)
					PlsPtuPut("UN_FEDERA", BB0->BB0_ESTADO, aDados)

					// CBO Solicitante
					If !Empty(cEspSol)
						BAQ->(DbSetOrder(1))
						If BAQ->(DbSeek(xFilial("BAQ")+BB0->BB0_CODOPE+cEspSol))
							PlsPtuPut("CD_CBO_SOL", StrZero(Val(BAQ->BAQ_CBOS), 6), aDados)
						EndIf
					EndIf

				EndIf
			EndIf
		EndIf

	EndIf
	
	// Tratamento para retorno da solicitacao
	aRet := PLSANAINT(aDados,aProcAux,iIf(lEvolu,"BE4",),nil,nil,nil,nil,nil,nil,nil,aAutoPTU)

	// Retorna o TP_CLIENTE para o padrao WEB
	nPos := aScan(aDados,{|x| x[1] == "TP_CLIENTE"})
	if nPos > 0
		aDados[nPos][2] := "PORTAL"
	endIf

	// Checa o retorno
	if valType( aRet[1,2] ) == 'A'

		// Retorno
		cAutori   := aRet[1,1]
		cNrSeqTR  := aRet[1,4]
		cSenhaOpe := aRet[1,5]
		cMsg03 	  := aRet[1,6]
		cDatValid := aRet[1,8]
		lVeioComu := .t.

		If lPTUOn90 .And. Len(aRet[1]) >= 9
			cNomeSocial := aRet[1][9]
		EndIf

		// for dos procedimentos
		for nfor2 := 1 To len(aItens)

			cSeqMov 	:= PLSRETDAD(aItens[nfor2],"SEQMOV")
			cCodPad 	:= PLSRETDAD(aItens[nfor2],"CODPAD")
			cCodPro 	:= PLSRETDAD(aItens[nfor2],"CODPRO")
			cDescri		:= PLSRETDAD(aItens[nfor2],"DESCRI","")
			nQtdSol 	:= PLSRETDAD(aItens[nfor2],"QTD",0)
			nQtdAut 	:= PLSRETDAD(aItens[nfor2],"QTDAUT",0)
			cTpProc		:= PLSRETDAD(aItens[nfor2],"TPPROC","")
			cDente  	:= PLSRETDAD(aItens[nfor2],"DENTE","")
			cFace   	:= PLSRETDAD(aItens[nfor2],"FACE","")
			cSlvPad 	:= PLSRETDAD(aItens[nfor2],"SLVPAD","")
			cSlvPro 	:= PLSRETDAD(aItens[nfor2],"SLVPRO","")

			if lEvolu
				PlsPtuPut("TRAITEPTU",cNrSeqTR,aItens[nfor2])
				PlsPtuPut("NRAOPE",cSenhaOpe,aItens[nfor2])
			endIf

			// Se quantidade autorizada for igual a zero pulo pois nao posso envia-lo
			if nQtdAut == 0
				loop
			endIf

			// Pega a posicao do acos de procedimentos	( 11 e comunicado e auditoria)
			for nI := 1 To len(aRet[1,2])
				nPos := aScan( aRet[1,2,nI] , { |x| allTrim(x[2]) == allTrim(cCodPro) } )
				if nPos > 0 .and. allTrim(aRet[1,2,nI,nPos,2]) == allTrim(cCodPro)
					nPos := nI
					Exit
				endIf
			next
			// Se nao encontrar o procedimento erro no retorno
			if nPos <> 0
				cAuditoria := "0"
				// Atualizado
				cTpAut := PlsPtuGet("ID_AUTORIZ",aRet[1,2,nPos])
				// Atualiza o procedimento
				if cTpAut == "2"
					// Um autorizado finaliza a tranzacao
					if (nPos := aScan(aDadBEA,{|x| x[1] == "BEA_TRACON"})) == 0
						aadd(aDadBEA,{"BEA_TRACON","1"})
					else
						aDadBEA[nPos,2] := "1"
					endIf
					if !lEvolu
						PlsPtuPut("TRAITEPTU",cNrSeqTR,aItens[nfor2])
						PlsPtuPut("NRAOPE",cSenhaOpe,aItens[nfor2])
					endIf

					PLSDADITE(aDadIte,aItens[nfor2],cOrigem,cLibEsp,cAuditoria,cNumImp,"1",dDatPro,aDadRda)

					aadd(aEventosAut,{cSeqMov,cCodPad,cCodPro,nQtdSol,cDescri,nQtdAut,cDente,cFace,"",cSlvPad,cSlvPro})

					iIf(cTpProc=='4',nQtdDiAut++,nil)
				else
					// Pega a posicao do acols de criticas
					for nY := 1 To 5
						cCodCri := ""
						// Caso exista criticas
						if val(PlsPtuGet("CD_MENS_E"+allTrim(str(nY)),aRet[1,2,nPos]) ) > 0
							// Posiciona Time-Out
							PLSPOSGLO(PLSINTPAD(),__aCdCri065[1],__aCdCri065[2])
							// Verifica se e critica de time-out
							if allTrim(PlsPtuGet("CD_MENS_E"+allTrim(str(nY)),aRet[1,2,nPos])) == __aCdCri065[1]
								cCodCri  := __aCdCri065[1]
								cCriDesc  := PLSBCTDESC()
								lCriTime := .t.
							elseIf allTrim(PlsPtuGet("CD_MENS_E"+allTrim(str(nY)),aRet[1,2,nPos])) == __aCdCri228[1]
								PLSPOSGLO(PLSINTPAD(),__aCdCri228[1],__aCdCri228[2])
								cCodCri := __aCdCri228[1]
								cCriDesc := PLSBCTDESC()
								lCriTime  := .t.
							else
								// Pega o codigo da critica
								cCodCri := PlsRtcdCed(PlsIntPad(),PlsPtuGet("CD_MENS_E"+allTrim(str(nY)),aRet[1,2,nPos]),4)
								if empty(cCodCri)
									if PLSPOSGLO(PLSINTPAD(),__aCdCri102[1],__aCdCri102[2],clocalExec,,cTipoGrv)
										cCodCri := __aCdCri102[1]
										cCriDesc := PLSBCTDESC()
									endIf
								else
									cCriDesc := PlsRtcdCed(PlsIntPad(),PlsPtuGet("CD_MENS_E"+allTrim(str(nY)),aRet[1,2,nPos]),3)
								endIf
							endIf
						else
							if cTpAut == "3"
								if PLSPOSGLO(PLSINTPAD(),__aCdCri052[1],__aCdCri052[2],clocalExec,,cTipoGrv)
									cCodCri := __aCdCri052[1]
									cCriDesc := PLSBCTDESC()
								endIf
							elseIf cTpAut == "4"
								if PLSPOSGLO(PLSINTPAD(),__aCdCri051[1],__aCdCri051[2],clocalExec,,cTipoGrv)
									cCodCri := __aCdCri051[1]
									cCriDesc := PLSBCTDESC()
								endIf
							endIf
							// Marca como auditoria
							if cTpAut $ "3,4"
								cAuditoria := "1"
							endIf
							aadd(aCriticas,{cSeqMov+cCodPro,cCodCri,cCriDesc,"",""})
							Exit
						endIf
						// Atualiza
						aadd(aCriticas,{cSeqMov+cCodPro,cCodCri,cCriDesc,"",""})
					next

					PlsPtuPut("TRAITEPTU",cNrSeqTR,aItens[nfor2])
					PlsPtuPut("NRAOPE",replicate("0",10),aItens[nfor2])

					PLSDADITE(aDadIte,aItens[nfor2],cOrigem,cLibEsp,cAuditoria,cNumImp,,dDatPro,aDadRda)

					aadd(aEventosNeg,{cSeqMov,cCodPad,cCodPro,nQtdSol,cDescri,nQtdAut,cDente,cFace,"",cSlvPad,cSlvPro})

					iIf(cTpProc=='4',(nQtdDiNeg += nQtdSol),nil)

				endIf
			else
				aadd(aCriticas,{cSeqMov,"000","Procedimento nao encontrado no retorno -> "+cCodPro,"",""})
			endIf
		next

		If lPTUOn80 .And. PlsAliasExi("B6M")
			If !lEvolu
				aAdd(aRetPTU, { "B6M_TIPGUI", cTpGuia })
				aAdd(aRetPTU, { "B6M_ALIAS" , IIF(lInter,"BE4","BEA") })
				aAdd(aRetPTU, { "B6M_ETAAUT", "2" })
				aAdd(aRetPTU, { "B6M_DTSOLI", StoD(cDtSolic) })
				aAdd(aRetPTU, { "B6M_TPACOM", cTpAcomod })
			Else
				aAdd(aRetPTU, { "B6M_TPACOM", cTpAcomod })
				aAdd(aRetPTU, { "B6M_ALIAS" , "BQV" })
			EndIf
			aAdd(aRetPTU, { "B6M_NRAOPE", cSenhaOpe })
			aAdd(aRetPTU, { "B6M_NRTROL", cNrSeqTR })
		EndIf
	else

		lOnLine := .f.

		if Type("aRet[1][3][1][1]") == "C" .and. ! empty(aRet[1][3][1][1])

			for nfor2 := 1 To len(aItens)

				cSeqMov 	:= PLSRETDAD(aItens[nfor2],"SEQMOV")
				cCodPad 	:= PLSRETDAD(aItens[nfor2],"CODPAD")
				cCodPro 	:= PLSRETDAD(aItens[nfor2],"CODPRO")
				cDescri		:= PLSRETDAD(aItens[nfor2],"DESCRI","")
				nQtdSol 	:= PLSRETDAD(aItens[nfor2],"QTD",0)
				nQtdAut 	:= PLSRETDAD(aItens[nfor2],"QTDAUT",0)
				cTpProc		:= PLSRETDAD(aItens[nfor2],"TPPROC","")
				cDente  	:= PLSRETDAD(aItens[nfor2],"DENTE","")
				cFace   	:= PLSRETDAD(aItens[nfor2],"FACE","")
				cSlvPad 	:= PLSRETDAD(aItens[nfor2],"SLVPAD","")
				cSlvPro	 	:= PLSRETDAD(aItens[nfor2],"SLVPRO","")

				aadd(aEventosNeg,{cSeqMov,cCodPad,cCodPro,nQtdSol,cDescri,nQtdAut,cDente,cFace,"",cSlvPad,cSlvPro})

				// Se foi um time-out, gravo a guia para posterior consulta e reenvio
				if aRet[1][3][1][1] == __aCdCri065[1] .and. len(aRet[1]) > 6
					cNrSeqTR  := aRet[1,7]
					PLSDADITE(aDadIte,aItens[nfor2],cOrigem,cLibEsp,cAuditoria,cNumImp,,dDatPro,aDadRda)
				endIf

			next nfor2

			aadd(aCriticas,{cSeqMov,aRet[1][3][1][1],aRet[1][3][1][2],"","","",""})

		endIf

	endIf

return( { lOnLine,cNrSeqTR,cSenhaOpe,cMsg03,lVeioComu,cAutori,aRet,cDatValid,aRetPTU,cNomeSocial} )

/*/{Protheus.doc} PLSLIBESP
Se vai para liberacao especial
@type function
@author Alexander Santos
@since 17.07.08
@version 1.0
/*/
function PLSLIBESP(cChave,cLibEsp,cOrigem,cCodPad,cCodPro)
	default cCodPad := ''
	default cCodPro := ''

	BCT->( dbSetOrder(1) )
	BCT->( msSeek(cChave) )
	// Verifica procedimento
	if !empty(allTrim(cCodPad+cCodPro))
		BR8->( dbSetOrder(1) ) //BR8_FILIAL + BR8_CODPAD + BR8_CODPSA + BR8_ANASIN
		BR8->( msSeek(xFilial("BR8")+cCodPad+cCodPro) )
	endIf
	// Verifica critia e se o procedimento envia para libera especial
	if cOrigem == "2" .and. cLibEsp <> "1" .and. BCT->( Found() ) .and. BR8->BR8_LIBESP == "1" .and. BCT->BCT_LIBESP == "1"
		cLibEsp := "1"
	endIf

return(cLibEsp)

/*/{Protheus.doc} PLSFINDESP
@type function
@author Alexander Santos
@since 17.07.08
@version 1.0
/*/
function PLSFINDESP(cOpeMov,cCodRda,cCodLoc,cCodEsp,dDatPro,aDadUsr,cCodPad,cCodPro,lLoadRda,lProf,lRdaProf,lSolicit,cTipGui,cGuiPri,aProrInt)
	local aRetFun 	:= {.t.,{}}
	local cLocal  	:= ""
	local cEspAux	:= ""
	local cDesLoc	:= ""
	local lTrtPro	:= .f.
	local lFirst	:= .t.
	local lFiltPRF  := getNewPar("MV_PLSPRFS",.t.)
	default lProf	:= .f.
	default lRdaProf:= .f.
	default cTipGui := ""
	default cGuiPri := ""
	default aProrInt := {}

	// Tratamento
	BB8->( dbSetOrder(1) )

	if empty(cCodLoc)

		if BB8->( msSeek(xFilial("BB8")+cCodRda+cOpeMov) )

			while !BB8->( eof() ) .and. BB8->(BB8_FILIAL+BB8_CODIGO+BB8_CODINT) == xFilial("BB8")+cCodRda+cOpeMov

				cLocal   := BB8->BB8_LOCAL
				cCodLoc  := BB8->BB8_CODLOC
				cDesLoc  := BB8->BB8_DESLOC

				// "1" Checar executante "0" Nao checar executante e sim na especialidade da RDA da guia
				// lProf = .t. Estou tratando a rda do profissional
				if !lProf

					// Igual porque na solicitacao sempre tenho que checar o solicitante
					lTrtPro := (lSolicit .and. lRdaProf)

					// Nao verifico o executante na solicitacao
					if !lSolicit
						lTrtPro := iIf(BB8->BB8_TRTEXE=='1',.t.,.f.)
					endIf
					// Se contratado diferente de executante e a especialidade for do executante e nao existir
					// no contratado e for para considerar o executante zera a especialidade
					if lFirst

						if ! empty(cCodEsp) .and. lTrtPro .and. lRdaProf

							cEspAux := cCodEsp
							PLSCHKER(cOpeMov+cCodEsp+cCodRda,@cCodEsp)

							if lWLIO .and. empty(cCodEsp)
								PlsLogFil(space(03)+"ESPECIALIDADE NAO ENCONTRADA NO CONTRATADO ["+cEspAux+"]" ,__PLSFLOGX)
								PlsLogFil("",__PLSFLOGX)
							endIf

						endIf

						lFirst := .f.

					endIf

				endIf

				// Valida a Rda
				aRetFun := PLSDADRDA(cOpeMov,cCodRda,"1",dDatPro,cCodLoc,cCodEsp,cCodPad,cCodPro,,(lTrtPro .or. lLoadRda))

				if aRetFun[1]
					// Se gera log caixa preta
					if lWLIO
						PlsLogFil(space(03)+"LOCAL ENCONTRADO ["+clocal+"."+cCodLoc+"] - ( "+iIf(lProf,"PROFISSIONAL","RDA")+" )",__PLSFLOGX)
					endIf
					exit
				endIf

				BB8->( dbSkip() )
			endDo

			// Verifica se vai mostrar as criticas ou nao
			if lTrtPro .and. lRdaProf
				aRetFun := {.t.,{}}
			endIf

		endIf

	else

		BB8->( msSeek(xFilial("BB8")+cCodRda+cOpeMov+cCodLoc) )
		cLocal  := BB8->BB8_LOCAL
		cDesLoc := BB8->BB8_DESLOC

		// "1" Checar executante "0" Nao checar executante e sim na especialidade da RDA da guia
		// lProf = .t. Estou tratando a rda do profissional
		if !lProf

			// Igualo porque na solicitacao sempre tenho que checar o solicitante
			if  lFiltPRF
				lTrtPro := (lSolicit .and. lRdaProf)
			endIf

			// Nao verifico o executante na solicitacao
			if !lSolicit
				lTrtPro  := iIf(BB8->BB8_TRTEXE == '1',.t.,.f.)
			endIf

			// Se contratado diferente de executante e a especialidade for do executante e nao existir
			// no contratado e for para considerar o executante zera a especialidade
			if ! empty(cCodEsp) .and. lTrtPro .and. lRdaProf

				cEspAux := cCodEsp
				PLSCHKER(cOpeMov+cCodEsp+cCodRda,@cCodEsp)

				if empty(cCodEsp) .and. lWLIO
					PlsLogFil(space(03)+"ESPECIALIDADE NAO ENCONTRADA NO CONTRATADO ["+cEspAux+"]" ,__PLSFLOGX)
					PlsLogFil("",__PLSFLOGX)
				endIf

			endIf

		endIf

		// Valida a Rda
		aRetFun := PLSDADRDA(cOpeMov,cCodRda,"1",IIF(Len(aProrInt) > 0,aProrInt[1],dDatPro),cCodLoc,cCodEsp,cCodPad,cCodPro,,(lTrtPro .or. lLoadRda),,,,Len(aProrInt) > 0)

		if aRetFun[1] .and. lWLIO
			PlsLogFil(space(03)+"LOCAL UTILIZADO ["+cLocal+"."+cCodLoc+"] - ( "+iIf(lProf,"PROFISSIONAL","RDA")+" ) ",__PLSFLOGX)
			PlsLogFil("",__PLSFLOGX)
		elseIf ( lTrtPro .and. lRdaProf )
			aRetFun := {.t.,{}}
		endIf

	endIf

	// Conforme a especialidade valida parametrizacao do tipo de rede de atendimento e produto.
	if aRetFun[1]
		aRetFun := PLSVLDRDA(,,,,,,cTipGui,cGuiPri)
	endIf

return( { cCodEsp,cLocal,cCodLoc,cDesLoc,lTrtPro,aRetFun} )

/*/{Protheus.doc} PLSDIAQTD
Validacao da rede de atendimento
@type function
@author Roberto Arruda
@since 17.09.16
@version 1.0
/*/
function PLSDIAQTD(aItens, aCriticas,aEventosNeg, cOrigem, cLibEsp, cNumImp, dDatPro, aDadRda, aDadIte, nQtdDiSol)
	local lContinua := .t.
	local aCodCri   := {}
	local aTrb 	    := {}
	local cCodPad	:= ""
	local cCodPro	:= ""
	local nfor			:= 0

	local nMaiorQtdDiaria := 0
	local cCodPadMaior	:= ""
	local cCodProMaior	:= ""
	local lCrit585		:= .f.
	local nSS				:= 1
	local aRetFun := {}
	default nQtdDiSol := 0
	default aItens := {}

	//Procurando item com maior diária configurada na BR8
	for nfor := 1 To len(aItens)
		cCodPad := PLSRETDAD(aItens[nfor],"CODPAD")
		cCodPro := PLSRETDAD(aItens[nfor],"CODPRO")

		BR8->(dbSetOrder(1))
		if BR8->( msSeek( xFilial("BR8")+cCodPad+cCodPro))
			if !empty(BR8->BR8_QTDDIA)
				lCrit585 := .t.
				if val(BR8->BR8_QTDDIA) > nMaiorQtdDiaria
					cCodPadMaior := cCodPad
					cCodProMaior := cCodPro
					nMaiorQtdDiaria := val(BR8->BR8_QTDDIA)

				endIf
			endIf
		endIf
	next

	if nQtdDiSol > nMaiorQtdDiaria .and. lCrit585

		if PLSPOSGLO(PLSINTPAD(),__aCdCri585[1],__aCdCri585[2])
			aadd(aCodCri,{__aCdCri585[1],PLSBCTDESC(),""/*Subs(cCodInt,1,ntCodOpe)*/,BCT->BCT_NIVEL,BCT->BCT_TIPO,cCodPad,cCodPro})
			aRetFun := {.f.,aCodCri}
		endIf

		// Verifica resultado da checagem
		if len(aRetFun) > 0

			lContinua  := aRetFun[1]
			aTrb 	   := aRetFun[2]

			if !lContinua
				for nSS := 1 To len(aItens)
					PLSDADITE(aDadIte,aItens[nSS],cOrigem,cLibEsp,"1",cNumImp,,dDatPro,aDadRda)
				next

				PLSMONCRI(aItens,aTrb,.t.,,,,@aCriticas,@aEventosNeg)

			endIf

		endIf

	endIf

return(lContinua)

/*/{Protheus.doc} PLSREDATE
Validacao da rede de atendimento
@type function
@author Alexander Santos
@since 17.07.08
@version 1.0
/*/
function PLSREDATE(cOpeMov,cCodRda,cCodRdaPro,cCodLoc,cCodLocPro,cCodEsp,cCodEspPro,dDatPro,;
		aItens,aDadIte,aCriticas,aEventosNeg,aDadUsr,;
		cLibEsp,cAuditoria,cOrigem,cNumImp,lLoadRda,lRdaProf,lIncNeg,cTipGui,cGuiPri,;
		lPtuOnline,cCarSol,lFAudMOP,lFAudAte,lforcAud,lAutoCus,lPacAudi,cNumLib,aProrInt)
	local lContinua := .t.
	local nRecBAU	:= 0
	local nfor		:= 0
	local cLocal  	:= ""
	local cDesLoc 	:= ""
	local cDesLocPro:= ""
	local aTrb		:= {}
	local aDadRDA	:= {}
	local aRdaProf	:= {}
	local aRetFun 	:= {}
	local lTrtPro	:= .f.
	local lSolicit	:= (cOrigem == "2")
	local lVerAudit := .T.
	local lBaixoRisc := .F.
	local cCriUrgAud := GetNewPar("MV_PTAUDUR","")
	local aRetPE     := {}

	Default cTipGui := ""
	Default cGuiPri := ""
	Default lPtuOnline := .F.
	Default cCarSol    := ""
	Default lFAudMOP   := .F.
	Default lFAudAte   := .F.
	Default lforcAud   := .F.
	Default lAutoCus   := .F.
	Default lPacAudi   := .F.
	Default cNumLib    := ""
	Default aProrInt   := {} // Prorrogação de Internação

	// Caso seja solicitacao e a Rda do Solicitante eh diferente do contratado
	if lRdaProf .and. lWLIO
		PlsLogFil("",__PLSFLOGX)
		PlsLogFil(space(03)+"RDA DO CONTRATADO ["+cCodRda+"] RDA DO PROFISSIONAL ["+cCodRdaPro+"]" ,__PLSFLOGX)
		PlsLogFil("",__PLSFLOGX)
	endIf

	// local de Atendimento (Contratado) x Especialidade do Profissional
	aRetFun 	:= PLSFINDESP(cOpeMov,cCodRda,cCodLoc,cCodEsp,dDatPro,aDadUsr,"","",lLoadRda,.f.,lRdaProf,lSolicit,cTipGui,cGuiPri,aProrInt)

	if existBlock("PLXMRATE")
		aRetPE := execBlock( "PLXMRATE",.f.,.f.,{aClone(aRetFun),cOpeMov,cCodRda,cCodLoc,cCodEsp,dDatPro,aDadUsr,;
			lLoadRda,lRdaProf,lSolicit,cTipGui,cGuiPri,cNumLib,cOrigem})
		cCodEsp		:= aRetPE[1]
		cLocal  	:= aRetPE[2]
		cCodLoc 	:= aRetPE[3]
		cDesLoc 	:= aRetPE[4]
		lTrtPro		:= aRetPE[5]
		aRetFun 	:= aClone(aRetPE[6])
	else
		cCodEsp		:= aRetFun[1]
		cLocal  	:= aRetFun[2]
		cCodLoc 	:= aRetFun[3]
		cDesLoc 	:= aRetFun[4]
		lTrtPro		:= aRetFun[5]
		aRetFun 	:= aClone(aRetFun[6])
	endIf

	// Verifica resultado da checagem
	if len(aRetFun) > 0

		lContinua  := aRetFun[1]
		aTrb 	   := aRetFun[2]

		//Se PTU Online, verifica se e baixo risco,
		//devo autorizar o evento se houver critica de cobertura
		if lPtuOnline .And. !lContinua
			lBaixoRisc := VBaixRisco(aItens)
			if lBaixoRisc
				BCT->(DbSetOrder(1)) //BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO
				for nfor := 1 To len(aTrb)
					if !empty(aTrb[nfor,1])
						//Verifico com o BCT_ATIVBR se a critica pode ser apresentada no Baixo Risco
						if BCT->(MsSeek(xFilial("BCT")+PlsIntPad()+aTrb[nfor,1])) .And. BCT->BCT_ATIVBR == "1"
							lContinua := .F.
							exit
						else
							lContinua := .T.
						endIf
					endIf
				next
			endIf
		endIf

		if !lContinua
			PLSMONCRI(aItens,aTrb,.t.,,,,aCriticas,aEventosNeg)

			// Se Baixo Risco, indico nas criticas que nao e permitido auditar

			// IMPORTANTE: A regra consiste em adicionar na posicao 8 do aCriticas o indicativo
			// que nao pode auditar (essa posicao sera utilizada no PLSTRTPTU_SCS2)
			// se no futuro mudarem a montagem do aCriticas aumentado a quantidade de itens no retorno
			// e necessario ajustar esse trecho para a nova posicao
			if lBaixoRisc
				for nfor := 1 To len(aCriticas)
					if len(aCriticas[nfor]) == 7
						aadd(aCriticas[nfor],{.T.,"0"})
					endIf
				next
			endIf

		else
			nRecBAU	:= BAU->( recno() )
		endIf
	else
		lContinua  := .f.
	endIf

	// lIncNeg, lLoadRda, e nao validou a rda
	if lIncNeg .and. lLoadRda .and. !lContinua

		lContinua := .t.

		//Verifico se a critica esta parametrizada para enviar para a auditoria
		if lPtuOnline .Or. IsInCallStack("PLSA973PRO")

			if lPtuOnline .And. ;
					(lFAudMOP .Or. ; // Solicitacao PTU descricao de mat/met que nao esta na tabela
					lFAudAte .Or. ; // Solicitacao PTU online com data de atendimento
					lforcAud .Or. ; // Solicitacao PTU com msg de observacao
					lAutoCus .Or. ; // Solicitacao PTU com alto custo
					lPacAudi) .And. ;// Solicitacao PTU com pacote
					(!lBaixoRisc .And. cCarSol <> "U") //Se Baixo Risco ou Urg/Emerg ignoro a regra de envio automatico

				lVerAudit  := .F.
				cAuditoria := "1"

			elseIf lPtuOnline .And. lBaixoRisc //Se baixo risco nao posso auditar
				lVerAudit  := .F.
				cAuditoria := "0"
			endIf

			if lVerAudit
				BCT->(DbSetOrder(1))//BCT_FILIAL+BCT_CODOPE+BCT_PROPRI+BCT_CODGLO
				for nfor := 1 To len(aTrb)

					// Este trecho trata a regra de atendimento de urgencia/emergencia nao poderem
					// enviar o atedimento para Auditoria. A unica excecao sao as criticas indicadas
					// no parametro MV_PTAUDUR
					lVerAudit := .T.
					if lPtuOnline .And. cCarSol == "U"
						lVerAudit  := .F.
						cAuditoria := "0"

						if aTrb[nfor,1] $ cCriUrgAud
							lVerAudit := .T.
						endIf
					endIf

					if lVerAudit .And. BCT->( msSeek( xFilial("BCT")+PlsIntPad()+aTrb[nfor,1] ) )
						if cAuditoria <> "1"
							cAuditoria := iif(BCT->BCT_AUDITO == "1","1","0")
						endIf
					endIf
				next
			endIf
		endIf

		for nfor := 1 To len(aItens)
			PLSDADITE(aDadIte,aItens[nfor],cOrigem,cLibEsp,cAuditoria,cNumImp,,dDatPro,aDadRda)
		next

	endIf

	// Dados da rda, especialidade
	if lContinua

		aDadRDA  := PLSGETRDA()

		if len(aDadRDA) == 0

			// Se gera log caixa preta
			if lWLIO
				PlsLogFil(space(03)+"aDadRDA esta vazia" ,__PLSFLOGX)
				PlsLogFil(space(03)+"Operadora"+space(15-len("Operadora"))+"["+cOpeMov+"]",__PLSFLOGX)
				PlsLogFil(space(03)+"Rda"+space(15-len("Rda"))+"["+cCodRDA+"]",__PLSFLOGX)
				PlsLogFil(space(03)+"DatPro"+space(15-len("DatPro"))+"["+DToS(dDatPro)+"]",__PLSFLOGX)
				PlsLogFil(space(03)+"Matricula"+space(15-len("Matricula"))+"["+aDadUsr[2]+"]",__PLSFLOGX)
				PlsLogFil(space(03)+"local"+space(15-len("local"))+"["+clocal+"]",__PLSFLOGX)
				PlsLogFil(space(03)+"CodLoc"+space(15-len("CodLoc"))+"["+cCodLoc+"]",__PLSFLOGX)
				PlsLogFil(space(03)+"CodEsp"+space(15-len("CodEsp"))+"["+cCodEsp+"]",__PLSFLOGX)
				PlsLogFil(space(03)+"CodEspPro"+space(15-len("CodEspPro"))+"["+cCodEspPro+"]",__PLSFLOGX)
			endIf
			lContinua := .f.
		endIf

		// Se ok com a Rda
		if lContinua .and. len(aDadRDA) > 0

			// Buscou a especilidade sugerida no aDadRda
			if empty(cCodEsp)
				cCodEsp		:= aDadRda[15]
				cCodEspPro  := iIf(lRdaProf,cCodEspPro,cCodEsp)
			else
				PLSPUTRDA(15,cCodEsp)
				BAQ->( dbSetOrder(1) )
				if BAQ->(msSeek( xFilial("BAQ")+cOpeMov+cCodEsp) )
					PLSPUTRDA(17,BAQ->BAQ_DESCRI)
				endIf
			endIf

			// Carrega dados da rda do profissional
			if lRdaProf .and. lTrtPro

				// local de Atendimento x Especialidade do Profissional
				aRetFun    := PLSFINDESP(cOpeMov,cCodRdaPro,cCodLocPro,cCodEspPro,dDatPro,aDadUsr,"","",lLoadRda,.t.,.f.,lSolicit)
				cCodEspPro := aRetFun[1]
				cCodLocPro := aRetFun[3]
				cDesLocPro := aRetFun[2]+"."+aRetFun[3]+" - "+aRetFun[4]
				aRetFun	   := aClone(aRetFun[6])

				// Verifica se tudo ok com a rda do profissional
				if len(aRetFun) > 0

					lContinua  := aRetFun[1]
					aTrb 	   := aRetFun[2]

					if !lContinua
						PLSMONCRI(aItens,aTrb,.t.,,,,aCriticas,aEventosNeg)
					else

						aRdaProf := PLSGETRDA()

						if empty(cCodEspPro)
							cCodEspPro := aRdaProf[15]
						endIf

					endIf

				else
					lContinua  := .f.
				endIf
				// Retorna para o BAU do contratado
				BAU->( dbGoto(nRecBAU) )
				// Retorna o conteudo original da rda contratada para a aDadRDA statica
				PLSCLORDA(aDadRda)
			else
				aRdaProf := aDadRda
			endIf
		else
			// Buscou a especilidade sugerida na aDadRda
			PLSPOSGLO(PLSINTPAD(),__aCdCri171[1],__aCdCri171[2])
			PLSMONCRI(aItens,{},.f.,__aCdCri171[1],PLSBCTDESC(),,aCriticas,aEventosNeg)
		endIf

	endIf

return( { lContinua,cLocal,cDesLoc,cDesLocPro,nRecBAU,aDadRDA,aRdaProf,lTrtPro } )

/*/{Protheus.doc} PLSUSUATE
Validacao do usuario
@type function
@author PLSTEAM
@since 17.07.08
@version 1.0
/*/
function PLSUSUATE(cMatric,clocalExec,cHora,cViaCartao,cTipoMat,cNomUsrCar,cTipoGrv,aItens,;
		aCriticas,aEventosNeg,aMatInf,dDatPro,dDatNasUsr,lResInt,lHonor,lIncAutIE,lImpXml,;
		lPtuOnline,cOpeOri,lVldTok,cTokEdi)
	local lContinua	 := .t.
	local lUsuGer	 := .t.
	local lMatGer	 := .f.
	local lCriMatInv := .f.
	local nfor		 := 0
	local cDesCri159 := ""
	local cMatUsa	 := ""
	local cRetGui  	 := ""
	local cSomInt  	 := ""
	local cGuiPOS 	 := ""
	local cCrGuiPOS  := ""
	local cMatOri    := cMatric
	local aRetFun	 := {}
	local aDadUsr	 := {}
	default lPtuOnline := .f.
	default cOpeOri    := ""
	default lVldTok  := .f.
	default cTokEdi  := ""

	// Verifica se vai usar usuario generico
	if PLSPOSGLO(PLSINTPAD(),__aCdCri159[1],__aCdCri159[2],clocalExec,,cTipoGrv)
		cDesCri159 := PLSBCTDESC()

		// Verifica matricula antiga
		lMatGer := PLVLDMATAN(cMatric)

	endIf

	// Carrego o aDadUsr sem fazer algumas validacoes
	aRetFun := iIf(lMatGer,{.f.,{}},PLSA090USR(cMatric,dDatPro,cHora,"BE1",.f.,.t.,nil,nil,nil,nil,cViaCartao,cTipoMat,lIncAutIE,cNomUsrCar,dDatNasUsr,,.t.) )

	// Se PTU Online (lVldTok) e foi informado token, o mesmo é validado.
	If lVldTok .And. Substr(cMatric,5,4) <> GetNewPar("MV_PLSGEIN","0050") .And. ; //So entra nesta condicao se nao for intercambio
			BA1->(FieldPos("BA1_TKSEED")) > 0 .And. !lCriMatInv .And. !Empty(AllTrim(cTokEdi)) .And. ;
			PLSPOSGLO(PLSINTPAD(),__aCdCri241[1],__aCdCri241[2],cLocalExec,nil,cTipoGrv)

		aRetTok := PLSUTOKVLD(cMatric, cTokEdi)
		If !aRetTok[1]
			aAdd(aRetFun[2],{__aCdCri241[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,"",""})
			aAdd(aRetFun[2],{""   ,STR0115,cTokEdi,"",""}) //"Token informado"
			aAdd(aRetFun[2],{""   ,STR0116,aRetTok[2],"",""}) //"Token correto"
			aRetFun[1] := .F.
		EndIf
	EndIf

	// Verifica se houve critica de beneficiario invalido
	for nfor := 1 to len(aRetFun[2])

		if aRetFun[2][nfor][1] == "508"
			lCriMatInv := .t.
			Exit
		endIf

	next

	if aRetFun[1] .or. (lPtuOnline .and. !lCriMatInv)

		// Monta a dadusr
		aDadUsr := PLSGETUSR()

		// Pega dados da dadusr e verifica regra do pos
		cMatUsa := aRetFun[4]
		cOpeOri := aDadUsr[45]

		// Ajusta para matricula siga
		if	allTrim(cMatric) <> allTrim(aDadUsr[2])

			// Se gera log caixa preta
			if lWLIO
				PlsLogFil("",__PLSFLOGX)
				PlsLogFil(space(03)+' Matricula Recebida ( '+cMatric+' ) - Matricula Usada ( '+allTrim(aDadUsr[2])+' )' ,__PLSFLOGX)
				PlsLogFil("",__PLSFLOGX)
			endIf

			cMatric := allTrim(aDadUsr[2])
		endIf

		if len(aDadUsr) >= 67
			cRetGui  := aDadUsr[67]
		endIf

		if len(aDadUsr) >= 68
			cSomInt  := aDadUsr[68]
		endIf

		if len(aDadUsr) >= 69

			cGuiPOS := aDadUsr[69]

			if len(aDadUsr) >= 70
				cCrGuiPOS :=aDadUsr[70]
			endIf

			// POS
			if cGuiPOS == "0" .and. cTipoGrv == "3"
				lContinua  := .f.
				PLSPOSGLO(PLSINTPAD(),__aCdCri092[1],__aCdCri092[2])
				PLSMONCRI(aItens,{},.f.,__aCdCri092[1],PLSBCTDESC(),cCrGuiPOS,aCriticas,aEventosNeg)
			endIf

		endIf

	else

		lContinua := .f.

		// Somente na importacao xml
		if lPtuOnline

			// Criacao usuario generico caso nao exista ou invalido
			lUsuGer := PLSUsrGen( PLSINTPAD() )

			if lUsuGer

				lContinua := .t.
				// Se gera log caixa preta
				if lWLIO
					PlsLogFil(space(03)+' Matricula ( '+cMatric+' ) - '+__aCdCri159[1]+' - '+cDesCri159 ,__PLSFLOGX)
					PlsLogFil("",__PLSFLOGX)
				endIf

				aRetFun := PLSDADUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),"1"	,.f.,dDataBase)

				if aRetFun[1]

					// Se gera log caixa preta
					if lWLIO
						PlsLogFil(space(03)+' Sendo utilizada a matricula do usuário genérico',__PLSFLOGX)
					endIf

					cMatOri := cMatric
					cMatric := allTrim(aRetFun[2])
					aDadUsr := PLSGETUSR()

					if len(aDadUsr) >= 67
						cRetGui := aDadUsr[67]
					endIf
					if len(aDadUsr) >= 68
						cSomInt := aDadUsr[68]
					endIf

					if !lPtuOnline
						aadd(aMatInf, { __aCdCri159[1]+' - '+cDesCri159 , "nil" } )
						aadd(aMatInf, { 'MATRICULA INVALIDA - NAO UTILIZADA NA IMPORTACAO ( '+cMatOri+' )' , "nil"} )
						aadd(aMatInf, { 'MATRICULA GENERICA - USADA NA IMPORTACAO         ( '+cMatric+' )' , "nil"} )

						aadd(aMatInf, { replicate('-',60) , "nil"} )
					endIf
				else
					lContinua := .f.
					if !lPtuOnline
						aadd(aMatInf, { 'CRITICAS DO USUARIO GENERICO' , "nil"} )
					endIf
					// Se gera log caixa preta
					if lWLIO
						PlsLogFil(space(03)+'CRITICAS DE USUARIO GENERICO',__PLSFLOGX)
						PlsLogFil("",__PLSFLOGX)
					endIf

					for nfor := 1 To len(aRetFun[2])
						if !lPtuOnline
							aadd(aMatInf, { upper(aRetFun[2,nfor,1]+' - '+aRetFun[2,nfor,2]) , "nil"} )
						endIf
						PlsLogFil(space(03)+aRetFun[2,nfor,1]+' - '+aRetFun[2,nfor,2],__PLSFLOGX)
					next
					if !lPtuOnline
						aadd(aMatInf, { replicate('-',60) , "nil"} )
					endIf
					// Se gera log caixa preta
					if lWLIO
						PlsLogFil("",__PLSFLOGX)
					endIf

				endIf

			else

				if !lPtuOnline
					aadd(aMatInf, { 'NAO FOI POSSIVEL CRIAR USUARIO GENERICO' , "nil"} )
				endIf

				// Se gera log caixa preta
				if lWLIO
					PlsLogFil(space(03)+'NAO FOI POSSIVEL CRIAR USUARIO GENERICO',__PLSFLOGX)
					PlsLogFil("",__PLSFLOGX)
				endIf

			endIf

		endIf

		// Exibe as criticas
		if !lContinua

			if lWLIO .and. len(aDadUsr)==0
				PlsLogFil("",__PLSFLOGX)
				PlsLogFil(space(03)+"<< aDadUsr esta vazia, parametros informados na PLSA090USR >>" ,__PLSFLOGX)
				PlsLogFil(space(03)+"Matricula"+space(15-len("Matricula"))+"["+cMatric+"]",__PLSFLOGX)
				PlsLogFil(space(03)+"Dat. Proc"+space(15-len("Dat. Proc"))+"["+DtoS(dDatPro)+"]",__PLSFLOGX)
				PlsLogFil(space(03)+"Hor. Proc"+space(15-len("Hor. Proc"))+"["+cHora+"]",__PLSFLOGX)
				PlsLogFil(space(03)+"Via Car."+space(15-len("Via Car."))+"["+cViaCartao+"]",__PLSFLOGX)
				PlsLogFil(space(03)+"Tip Mat."+space(15-len("Tip Mat."))+"["+cTipoMat+"]",__PLSFLOGX)
				PlsLogFil(space(03)+"lIncAutIE"+space(15-len("lIncAutIE"))+"["+iIf(lIncAutIE,"Sim","Nao")+"]",__PLSFLOGX)
				PlsLogFil(space(03)+"Nom Usr"+space(15-len("Nom Usr"))+"["+cNomUsrCar+"]",__PLSFLOGX)
				PlsLogFil(space(03)+"Dt. Nasc"+space(15-len("Dt. Nasc"))+"["+DtoS(dDatNasUsr)+"]",__PLSFLOGX)
				PlsLogFil("",__PLSFLOGX)
			endIf

			// Itens
			if !aRetFun[1] .or. lCriMatInv
				PLSMONCRI(aItens,aRetFun[2],.t.,,,,aCriticas,aEventosNeg)
			endIf

		endIf

	endIf

return( { lContinua,lMatGer,lUsuGer,cMatUsa,cOpeOri,cRetGui,cSomInt,aDadUsr,lCriMatInv } )

/*/{Protheus.doc} PLSCHKER
Se a especialidade existe para rda
@type function
@author Alexander Santos
@since 17.07.08
@version 1.0
/*/
function PLSCHKER(cChave,cCodEsp)

	BAX->( dbSetOrder(3) )//BAX_FILIAL + BAX_CODINT + BAX_CODESP + BAX_CODIGO
	if !BAX->( msSeek(xFilial("BAX")+cChave) )
		cCodEsp := ""
	endIf

return

/*/{Protheus.doc} PLSDESDF
Retorna a descricao de um dente ou face
@type function
@author Alexander Santos
@since 17.07.08
@version 1.0
/*/
function PLSDESDF(cCont,cTp)
	local cRet := ""

	if !empty(cCont)

		if cTp == 0
			B05->( dbSetOrder(1) )
			if B05->( msSeek(xFilial("B05")+cCont) )
				cRet := B05->B05_DESCRI
			endIf
		else
			B09->( dbSetOrder(1) )
			if B09->( msSeek(xFilial("B09")+cCont) )
				cRet := B09->B09_FACDES
			endIf
		endIf

	endIf

return cRet

/*/{Protheus.doc} PLSGRVHOR
Monta dados para gravacao da guia de honorario
@type function
@author Alexander Santos
@since 16.03.10
@version 1.0
/*/
function PLSGRVHOR(cNumLib,cAno,cMes,cTipGui,lNMudFase,aDados,aDadIte,aTpPIte,aMatBd6,aUnMed,;
		aCriticas,aItens,aEventosAut,aEventosNeg)

	//Guia de Honorarios é somente no BD5 agora
return {}

/*/{Protheus.doc} PLSDADCRI
Monta a dadcri
@type function
@author Alexander Santos
@since 16.03.10
@version 1.0
/*/
function PLSDADCRI(cAlias,aCriticas,aCabCri,aDadCri,aTrbCri,cSequen,cCodGlo,cDesGlo,cInfGlo,cCodEDI)
	local nfor	:= 0
	local _nInd := 0
	default cCodEDI := ""
	default cInfGlo := ""

	// Inicia Matriz
	aTrbCri := Array( len(aCriticas) )

	// Store header e cols
	Store Header cAlias TO aCabCri for .t.
	Store COLS Blank cAlias	TO aDadCri FROM aCabCri

	// Monta criticas
	for nfor := 1 To len(aCriticas)

		nPos 			:= PLRETPOS(cSequen,aCabCri,.f.)
		aTrbCri[nfor] 	:= 0

		if nPos > 0
			if nfor > len(aDadCri)
				aadd(aDadCri,{})
				for _nInd :=  1 To len(aCabCri)+1

					aadd(aDadCri[len(aDadCri)],_nInd)
					if _nInd <= len(aCabCri)
						aDadCri[len(aDadCri),_nInd] := CriaVar(aCabCri[_nInd,2],.t.)
					else
						aDadCri[len(aDadCri),_nInd] := .f.
					endIf

				next
			endIf

			aDadCri[len(aDadCri),nPos] := aCriticas[nfor,1]

			nPos := PLRETPOS(cAlias+'_SEQCRI',aCabCri,.f.)
			if nPos > 0
				aDadCri[len(aDadCri),nPos] := strZero(nfor, 3)
			endIf

			nPos := PLRETPOS(cCodGlo,aCabCri,.f.)
			if nPos > 0
				aDadCri[len(aDadCri),nPos] := aCriticas[nfor,1]
			endIf

			nPos := PLRETPOS(cCodGlo,aCabCri,.f.)
			if nPos > 0
				aDadCri[len(aDadCri),nPos] := aCriticas[nfor,2]
			endIf

			nPos := PLRETPOS(cDesGlo,aCabCri,.f.)
			if nPos > 0
				aDadCri[len(aDadCri),nPos] := aCriticas[nfor,3]
			endIf

			nPos := PLRETPOS(cInfGlo,aCabCri,.f.)
			if nPos > 0
				aDadCri[len(aDadCri),nPos] := aCriticas[nfor,4]
			endIf

			if !empty(cCodEDI) .and. (nPos := PLRETPOS(cCodEDI,aCabCri,.f.) )  > 0 .and. !empty(aCriticas[nfor,2])
				BCT->(dbSetOrder(1))//BCT_FILIAL+BCT_CODOPE+BCT_PROPRI+BCT_CODGLO
				if BCT->(msSeek(xFilial("BCT")+PlsIntPad()+aCriticas[nfor,2]))	 .and. !empty(BCT->BCT_CODED2)
					aDadCri[len(aDadCri),nPos] := BCT->BCT_CODED2
				endIf
			endIf
		endIf
	next

return

/*/{Protheus.doc} PLXMVPR
Log original executado no rdmake
@type function
@author Alexander Santos
@since 16.03.10
@version 1.0
/*/
static function PLXMVPR(aDados,aItens,lImpXml,cTipoGrv,lImpTxt,aMatM)
	local oJson			:= JsonObject():new()
	Default aMatM := {}
	// Se tem ponto de entrada executa e lista os dados originais no log
	if existBlock("PLSXMVPR")
		aRetPto := execBlock( "PLSXMVPR",.f.,.f.,{aDados,aItens,lImpXml,cTipoGrv,lImpTxt,aMatM} )
		aDados  := aRetPto[1]
		aItens  := aRetPto[2]
		// Se permiti log
		if lWLIO
			PlsLogFil(STR0063,__PLSFLOGX)
			PLSWLIO(aDados,aItens)
		endIf
	endIf

	if PLSRETDAD( aDados,"NUMIMP","" ) == "HAT"
		cMsgAll := PLSRETDAD( aDados,"MSGALL","" )		
		PlsPtuPut("NUMIMP", '',aDados)
		PlsPtuPut("HAT", .T.,aDados)
		if !empty(cMsgAll) .and. empty(oJson:fromJson(cMsgAll))
			PlsPtuPut("MSGALL", '',aDados)
			PlsPtuPut("MSG01" , '',aDados)
			PlsPtuPut("MSG02" , '',aDados)
			PlsPtuPut("PROTOC" 	, oJson['proAte'],aDados)
			PlsPtuPut("OBSGUI" 	, cvaltochar(oJson['obsGui']),aDados)
			if oJson['isExec']
				PlsPtuPut("ORIGEM" 		,"1" 	,aDados)
				PlsPtuPut("RPC"       	,.T. 	,aDados)
				PlsPtuPut("TP_CLIENTE"	,"WEB"	,aDados)
				PlsPtuPut("NUMLIB"		,oJson['numLib'],aDados)
			endif
		endif
	endif

return

/*/{Protheus.doc} PLSLGPLS
Log
@type function
@author Tulio Cesar
@since 26.05.07
@version 1.0
/*/
function PLSLGPLS()
	STATIC lPLSLGPLS := nil

	if lPLSLGPLS == nil
		lPLSLGPLS := (getNewPar("MV_PLSXMOV","0")=="1")
	endIf

return lPLSLGPLS

/*/{Protheus.doc} PLSICM
Inclui conta medica
@type function
@author Tulio Cesar
@since 24.04.12
@version 1.0
/*/
function PLSICM(cOpeMov,cMatric,cTipoGrv,clocalExec,cCodPSol,cCodPExe,dDatPro,cHora,cNumImp,cCodRda,; //10
		cCodLDP,cTipo,cCodLoc,cCodEsp,cTipGui,cCid,nQtNasV,nQtNasM,nQtNasP,nQtObtP,nQtObAR,cTipFat,; //22
		cCidObt,cNrdCob,cObtMul,cTipAlt,cNrdCnv,cLotGui,aItens,cArqImp,cNumLib,aTipPart,; //32
		cAlias,lHonor,cOrimov,cNumSol,lObsoleto,lAtuPeg,cPadCon,dDtAlta,cHrAlta,cEmgest,cAborto,; //43
		cTraGra,cComurp,cAtespa,cComnal,cBaipes,cPaareo,cPatnor,cTipSai,cTipCon,cNomUsr,dDatAcat,cTipoAte,; //55
		cGrpInt,cTipInt,cIndAci,cUndDoe,nTmpDoe,cTipDoe,cMsg01,cMsg02,cEspSol,cEspExe,cTipAdm,cRegint,cCarSol,; //68
		nNUsado,cAteRN,lImpTxt,cFase,cSituac,cGuiOri,cCnes,aCriticas,dDtIniFat,cHrIniFat,dDtFimFat,cHrFimFat,lnInfEquip,; //81
		lXmlOrigS, aEspCbXML, cGuiPri, lImpXml, lChkByFase, cTipPac, cTipAto, cParCop, cTipMaj, aTipRecGlo, cIndCli, cGuiInt, nDestino, aSituIni,;
		cCodEspNw, cRegAtdNw, cSadOcuNw ) //98
	local nI			:= 0
	local nPos			:= 0
	local cNumGui		:= ""
	local cFasePEG		:= ""
	local cMesBCI 		:= iIf( !empty(dDatAcat),strZero(Month(dDatAcat),2), strZero(Month(date()),2) )
	local cAnoBCI		:= iIf( !empty(dDatAcat),str(Year(dDatAcat),4), str(Year(date()),4) )
	local cMes 			:= strZero(Month(dDatPro),2)
	local cAno 			:= str(Year(dDatPro),4)
	local nQtdTotEve	:= 0
	local nVlrTotGui	:= 0
	local nRecExe 		:= 0
	local nRecSol 		:= 0
	local nInd1			:= 0
	local lCriaPEG		:= .f.
	local aRetFun  		:= {}
	local aDadRDA		:= {}
	local aDatPag 		:= {}
	local cCodEmp 		:= getNewPar("MV_PLSGEIN","0001")
	local cModulo   	:= IIF(FindFunction("StrTPLS"),Modulo11(StrTPLS(cOpeMov+cCodEmp+"99999999")),Modulo11(cOpeMov+cCodEmp+"99999999")) //Função StrTPLS "Substitui as letras de uma String pelo caracter passado por parametro "
	local cMatrAntGen	:= cOpeMov+cCodEmp+"99999999"+cModulo
	local nIndUt		:=	0
	local cMatricXml	:= ""
	local nTamMat 		:= len(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))
	local nTamAnt 		:= len(BA1->BA1_MATANT)
	local cspaceUsuAtu	:= iIf(len(allTrim(cMatric)) == 16,"",space(nTamMat - len(allTrim(cMatric))))
	local cspaceMatAnt	:= space(nTamAnt - len(allTrim(cMatric)))
	local lFoundID		:= .f.
	Local nrecBCIZ := 0

	default cFase			:= '1'
	default cSituac			:= '1'
	default aTipPart		:= {}
	default cAlias			:= "BD5"
	default lHonor			:= .f.
	default cOrimov			:= '1'
	default cNumSol			:= ""
	default lObsoleto 		:= .f.
	default lAtuPeg			:= .t.
	default lImpTxt			:= .f.
	default cPadCon 		:= ''
	default dDtAlta 		:= ''
	default cHrAlta 		:= ''
	default cEmgest 		:= ''
	default cAborto 		:= ''
	default cTraGra 		:= ''
	default cComurp 		:= ''
	default cAtespa 		:= ''
	default cComnal 		:= ''
	default cBaipes 		:= ''
	default cPaareo 		:= ''
	default cPatnor 		:= ''
	default cTipSai 		:= ''
	default cTipCon 		:= ''
	default cNomUsr 		:= ''
	default dDatAcat		:= date()
	default cTipoAte		:= ''
	default cGrpInt 		:= ''
	default cTipInt 		:= ''
	default cIndAci 		:= ''
	default cUndDoe 		:= ''
	default nTmpDoe 		:= 0
	default cTipDoe 		:= ''
	default cMsg01  		:= ''
	default cMsg02  		:= ''
	default cEspSol			:= ''
	default cEspExe 		:= ''
	default cTipAdm			:= ''
	default cRegint			:= ''
	default cCarSol 		:= ''
	default cAteRN			:= "0"
	default cCnes			:= ''
	default aCriticas		:= []
	default dDtIniFat 		:= ctod("")
	default cHrIniFat 		:= ""
	default dDtFimFat  		:= ctod("")
	default cHrFimFat  		:= ""
	default lnInfEquip  	:= .f.
	default lXmlOrigS		:= .f.
	default aEspCbXML		:= {}
	default nNUsado			:= nil
	default cGuiPri			:= ""
	default lImpXml			:= .f. .or. IsInCallstack("PLSA974")
	default lChkByFase		:= .f.
	default cTipPac			:= getNewPar("MV_PLSTPAA","9")
	default cTipAto			:= ''
	default cParCop			:= ''
	default cTipMaj			:= ''
	default aTipRecGlo		:= {'',''}
	default cIndCli			:= ''
	default cGuiInt			:= ''
	default ndestino		:= 0
	Default aSituIni		:= {}

	// Validacao do usuario
	BA1->( dbSetOrder(2) ) //BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
	BA1->( dbGotop() )

	if  ! BA1->( msSeek( xFilial("BA1")+allTrim(cMatric)+cspaceUsuAtu))

		BA1->( dbSetOrder(5) )//BA1_FILIAL + BA1_MATANT + BA1_TIPANT
		BA1->( dbGotop() )

		if !BA1->( msSeek( xFilial("BA1")+allTrim(cMatric)+cspaceMatAnt ) )

			cMatricXML	:= cMatric

			PXMLUsrGe(cOpeMov)

			aRetFun := PLSDADUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),"1",.f.,dDataBase)

			if ! aRetFun[1]

				for nI := 1 To len(aRetFun[2])

					if ! empty(aRetFun[2,nI,1])

						PLSICRI(@aCriticas,aRetFun[2,nI,1],aRetFun[2,nI,2])

					endIf

				next

			endIf

		endIf

	endIf

	// Posiciona na familia
	BA3->( dbSetOrder(1) )//BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
	BA3->( msSeek( xFilial("BA3") + BA1->( BA1_CODINT+BA1_CODEMP+BA1_MATRIC ) ) )

	aRetFun := PLSDADUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),'1',.f.,dDatPro,nil,nil,nil,nil,nil,.f.)
	aDadUsr := PLSGETUSR()

	if ! aRetFun[1]

		for nI := 1 to len(aRetFun[2])

			if ! empty(aRetFun[2,nI,1])
				PLSICRI(@aCriticas,aRetFun[2,nI,1],aRetFun[2,nI,2])
			endIf

		next

	endIf

	// Verifica se o proficional de saude solicitante existe se nao cria
	if ! empty(cCodPExe)
		nRecExe := PLSIPRF(cOpeMov,cCodPExe)
	endIf

	if ! empty(cCodPSol)
		nRecSol := PLSIPRF(cOpeMov,cCodPSol)
	endIf

	// Verifica a RDA
	aRetFun := PLSDADRDA(cOpeMov,cCodRda,"1",dDatPro,cCodLoc,cCodEsp,nil,nil,nil,nil,nil,nil,.t.)
	aDadRDA := PLSGETRDA()

	if ! aRetFun[1]

		for nI := 1 to len(aRetFun[2])

			if ! empty(aRetFun[2,nI,1])
				PLSICRI(@aCriticas,aRetFun[2,nI,1],aRetFun[2,nI,2])
			endIf

		next

	endIf

	//Para importacao de txt by mile
	if lImpTxt .and. len(aCriticas) > 0
		return('')
	endIf

	if ! lChkByFase

		// Criar PEG
		cChaveBCI := upper(cOpeMov + cCodLDP + cTipGui + cCodRda + cArqImp)
		cChaveB2  := lower(cOpeMov + cCodLDP + cTipGui + cCodRda + cArqImp)

		// Verifica se o PEG existe
		if nInd1 == 0
			nIndUt := PLSBUIND("BCI","BCI_FILIAL + BCI_CODOPE + BCI_CODLDP + BCI_TIPGUI + BCI_CODRDA + BCI_ARQUIV") /// Busca da Ordem do indice pela descrição
			nInd1  := nIndUt
		endIf

		//Primeiro buscamos pelo IDXML, caso seja importação e exista essa informação
		if lImpXml .and. ! lImpTxt .and. SIX->(msSeek("BCIG")) .and. ! empty(BXX->BXX_IDXML)
			BCI->(dbSetOrder(16))
			lFoundID := BCI->(msSeek(xfilial("BCI") + cOpeMov + PLSRETLDP(2) + cTipGui + cCodRDA + BXX->BXX_IDXML))
		endIf

		//Caso não seja encontrado (ou não seja buscado) pelo IDXML, segue a busca pelo arquivo
		if ! lFoundID

			BCI->( dbSetOrder(nInd1) )//BCI_FILIAL + BCI_CODOPE + BCI_CODLDP + BCI_TIPGUI + BCI_CODRDA + BCI_ARQUIV
			if ! BCI->( msSeek( xFilial("BCI") + cChaveBCI ) ) .and. ! BCI->( msSeek( xFilial("BCI") + cChaveB2 ) )
				lCriaPEG := .t.
			endIf

		endIf
	else
		lCriaPEG := .t.
	endIf

	// Total do valor apresentado
	for nI := 1 to len(aItens)

		nPos := aScan(aItens[nI],{ |x| allTrim( x[1] ) == "VLRAPR" } )
		nPos2:= aScan(aItens[nI],{ |x| allTrim( x[1] ) == "QTDAUT" } )

		if nPos > 0
			nVlrTotGui += aItens[nI,nPos,2]
		endIf

		if nPos2 > 0
			nQtdTotEve += aItens[nI,nPos2,2]
		endIf

	next

	// Verifica se cria peg
	if lCriaPEG

		// Data de pagamento
		if getNewPar("MV_PLSDTPG",.f.)
			aDatPag := PLSXVLDCAL(dDataBase,cOpeMov,.t.,"","",nil,cCodRda,.f.)
		endIf

		if ! lChkByFase

			BCI->(dbSetOrder(12))//BCI_FILIAL+BCI_CODOPE+BCI_CODLDP+BCI_TIPGUI+BCI_CODRDA+BCI_ARQUIV
			lCriaPEG := ! BCI->(msSeek(xFilial("BCI") + cOpeMov + cCodLDP + cTipGui + cCodRda + upper(cArqImp))) .and.;
				! BCI->(msSeek(xFilial("BCI") + cOpeMov + cCodLDP + cTipGui + cCodRda + cArqImp))

		else
			if cTipGui == G_REC_GLOSA .and. aTipRecGlo[1] == "1" .and. empty(aTipRecGlo[2])  //Recurso de Protocolo inteiro
				lCriaPEG = .t.
			elseif cTipGui == G_REC_GLOSA .and. aTipRecGlo[1] == "1"
				BCI->(dbSetOrder(1))
				if ( BCI->(  msSeek( xFilial("BCI") + cOpeMov + cCodLDP + aTipRecGlo[2]) )	)
					lCriaPEG := .f.
				endif
			else
				BCI->(dbSetOrder(4))//BCI_FILIAL+BCI_OPERDA+BCI_CODRDA+BCI_ANO+BCI_MES+BCI_TIPO+BCI_FASE+BCI_SITUAC+BCI_TIPGUI+BCI_CODLDP+BCI_ARQUIV

				//preferencia criar no PEG em digitacao eletronica
				//verifica se tem PEG na fase digitacao
				lCriaPEG := ! BCI->(  msSeek( xFilial("BCI") + cOpeMov + cCodRda + cAnoBCI + cMesBCI + "2" + "1" + cSituac + cTipGui + cCodLDP) ) .and.;
					! BCI->(  msSeek( xFilial("BCI") + cOpeMov + cCodRda + cAnoBCI + cMesBCI + "2" + "3" + cSituac + cTipGui + cCodLDP) )
			endif

		endIf

		// Cria peg
		if lCriaPEG
			PLSIPP(cOpeMov,cCodLDP,cOpeMov,cCodRda,cMesBCI,cAnoBCI,dDataBase,cTipGui,cLotGui,aDatPag,cFase,cArqImp,nQtdTotEve,1,nVlrTotGui,,cSituac, iIf( !empty(dDatAcat),dDatAcat, date()))
		endIf

	else

		// Atualiza totais
		if lAtuPeg
			PLSATUPP(nQtdTotEve,nVlrTotGui)
		else

			//Importação de XML, garantimos que a PEG encontrada será a criada anteriormente na submissão do XML
			if lImpXml .and. !lImpTxt .and. SIX->(msSeek("BCIG")) .and. !empty(BXX->BXX_IDXML)

				BCI->(dbSetOrder(16))
				if BCI->(msSeek(xfilial("BCI") + cOpeMov + PLSRETLDP(2) + cTipGui + cCodRDA + BXX->BXX_IDXML))

					BCI->( recLock("BCI",.f.) )
					BCI->BCI_LOTGUI	:= cLotGui
					BCI->( msUnLock() )

				endIf

			else

				BCI->( dbSetOrder(nInd1) )//BCI_FILIAL + BCI_CODOPE + BCI_CODLDP + BCI_TIPGUI + BCI_CODRDA + BCI_ARQUIV
				if BCI->( msSeek( xFilial("BCI")+cChaveBCI ) ) .or. BCI->( msSeek( xFilial("BCI") + cChaveB2 ) )

					BCI->( recLock("BCI",.f.) )
					BCI->BCI_LOTGUI	:= cLotGui
					BCI->( msUnLock() )

					// Esse tratamento se da para cliente que importam a Tiss com datas antigas
				else

					BCI->( dbSetOrder(4) )
					if BCI->(msSeek(xFilial("BCI") + cOpeMov + cCodRda + strZero(Year(ddatabase),4) + strZero(Month(ddatabase),2) + "2" + cFase + cSituac + cTipGui + cCodLDP + upper(cArqImp)))

						BCI->( recLock("BCI",.f.) )
						BCI->BCI_LOTGUI	:= cLotGui
						BCI->( msUnLock() )

					endIf

				endIf

			endIf

		endIf

	endIf

	//buscanso os números fora da transação
	if cTipGui $ G_CONSULTA + '|' + G_SADT + '|' + G_HONORARIO + '|' + G_REEMBOLSO + '|' + G_REC_GLOSA + "|" + G_ODONTO

		cNumero  := PLSA500NUM("BD5", BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG)
		cNumInt  := ""

	else

		cNumero  := PLSA500NUM("BE4", BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG)
		cNumInt  := PLNUMINT(cOpeMov,cAno,cMes)

	endIf

	if ! lChkByFase
		cFasePEG := BCI->BCI_FASE
	else
		cFasePEG := cFase
	endIf

	nrecBCIZ := BCI->(Recno())

	begin transaction

		// Gravar o cabecalho da guia
		cNumGui := PLSICAB(	cTipGui,BCI->BCI_CODOPE,BCI->BCI_CODLDP,BCI->BCI_CODPEG, cFasePEG,BCI->BCI_SITUAC,dDatPro,; //7
			cHora,cMes,cAno,cNumImp,cCid,nQtNasV,nQtNasM,nQtNasP,nQtObtP,nQtObAR,cTipFat,cCidObt,cNrdCob,; //20
			cObtMul,cTipAlt,cNrdCnv,aDadRDA,aCriticas,cLotGui,cNumLib,lHonor,cNumSol,cPadCon,dDtAlta,; //31
			cHrAlta,cEmgest,cAborto,cTraGra,cComurp,cAtespa,cComnal,cBaipes,cPaareo,cPatnor,cArqImp,aItens,; //43
			cTipSai,cTipCon,cNomUsr,cMatrAntGen,nRecExe,nRecSol,cTipoAte,cGrpInt,cTipInt,cIndAci,cUndDoe,; //54
			nTmpDoe,cTipDoe,cMsg01,cMsg02,cEspSol,cEspExe,cTipAdm,cRegInt,BCI->BCI_MES,BCI->BCI_ANO,cCarSol,; //65
			aItens,cAteRN,lImpTxt,cGuiOri,cCnes,cMatricXml,dDtIniFat,cHrIniFat,dDtFimFat,cHrFimFat, aEspCbXML,;//76
			cGuiPri, lImpXml, cNumero, cNumInt, cTipPac, cTipAto, cParCop, cTipMaj,, cIndCli, cGuiInt, BCI->BCI_CODRDA,; //88
			cCodEspNw, cRegAtdNw, cSadOcuNw) //91
		If cTipGui <> "05"
			nDestino := BD5->(recno())
		endIf
		// Grava itens da guia
		PLSIITE(clocalExec,cTipoGrv,aItens,aCriticas,cNumLib,aTipPart,cAlias,lHonor,dDatPro,cHora,cOrimov,cMatrAntGen,dDatAcat,lImpTxt,aDadUsr,lnInfEquip, lXmlOrigS, lImpXml)

		If PLSALIASEX("B6B")
			PLAgruCri(BD6->BD6_CODRDA, BD6->BD6_CODOPE, BD6->BD6_CODLDP, BD6->BD6_CODPEG, BD6->BD6_NUMERO)
		endIf

		if !empTy(aSituIni)
			GrvAneSIni(aSituIni, .F., )
		endif
	end transaction

	If nrecBCIZ > 0 .and. !BCI->(eof())

		If nrecBCIZ <> BCI->(Recno())
			BCI->(dbgoTo(nrecBCIZ))
		endIf

		aFase 	:= PLSMDVFA(BCI->(Recno()), .F.) //Vai retornar {"1", .F.}, mas se um dia a regra mudar, ao alterar a função aqui fica certo

		// Verifica qual será o status TISS do PEG
		cStaTiss :=  PLRETSTISS(aFase[1],,BCI->(recno()), aFase[2])

		If cStaTIss < "2" //Forçamos 2, pq deve vir 1 aqui, com os fontes atuais
			cStaTIss := "2"
		endIf

		BCI->(RecLock("BCI", .F.))
		BCI->BCI_STTISS := cStaTiss
		BCI->(MsUnLock())

		// Chama integracao com o faturamento no HAT
		If GetNewPar("MV_PLSHAT","0") == "1"
			PLHATINTFAT(BCI->BCI_CODOPE,BCI->BCI_CODLDP,BCI->BCI_CODPEG)
		EndIf

	endIf

return(cNumGui)

/*/{Protheus.doc} PLSIPP
Criacao do PEG
@type function
@author Tulio Cesar
@since 22/03/12
@version 1.0
/*/
function PLSIPP(cOpeMov,cCodLDP,cOpeRda,cCodRda,cMesBCI,cAnoBCI,dDTRec,cTipGui,cLotGui,aDatPag,cFase,cArqImp,nQtdTotEve,nQtdGui,nVlrTotGui,cOrigem,cSituac,dDatPeg,cDigOff,cIDXML,cBrjCodigo,cTpArq)
	local nHP 			:= 0
	local cNewPEG 		:= ""
	local cCodIn		:= PLSINTPAD()
	local cStaTiss 		:= "1"
	default cSituac		:= '1'
	default nQtdTotEve 	:= 0
	default nQtdGui		:= 0
	default nVlrTotGui	:= 0
	default cOrigem	    := "0"
	default cOpeMov		:= PLSINTPAD()
	default cCodLDP		:= "9999"
	default dDatPeg 	:= dDataBase
	default cDigOff 	:= ""
	default cIDXML 		:= ""
	default cArqImp		:= ""
	default cLotGui		:= ""
	default cBrjCodigo 	:= ""
	default cTpArq 		:= ""

	BCL->(dbSetOrder(1))
	BCL->(msSeek(xFilial("BCL")+cOpeMov+cTipGui))

	// Abre Semaforo
	nHP := PLSAbreSem("PLSPEG.SMF")

	// cria PEG
	cNewPEG  := PLSA175Cod(cOpeMov,cCodLDP)

	//pego mês, parametrização do calendário.
	aDatPag  := PLSXVLDCAL(dDatPeg,cCodIn)
	cStaTiss := PLRETSTISS(cFase,cSituac)

	BCI->( RecLock("BCI",.t.) )
	BCI->BCI_FILIAL := xFilial("BCI")
	BCI->BCI_CODOPE := cOpeMov

	// Arquivo de importacao
	BCI->BCI_ARQUIV := StrTran(cArqImp,".XML","")

	// Grava restante do BCI
	BCI->BCI_CODLDP := cCodLDP
	BCI->BCI_CODPEG := cNewPEG
	BCI->BCI_OPERDA := cOpeRda

	BCI->BCI_CODRDA := cCodRda
	BCI->BCI_CGCRDA := Posicione("BAU",1,xFilial("BAU")+cCodRda,"BAU_CPFCGC")
	BCI->BCI_NOMRDA := BAU->( Posicione("BAU",1,xFilial("BAU")+cCodRda,"BAU_NOME") )
	BCI->BCI_TIPPRE := BAU->BAU_TIPPRE

	BCI->BCI_TIPSER := getNewPar("MV_PLSTPSP","01")
	BCI->BCI_TIPGUI := cTipGui

	if IsInCallStack("PLSA974") .and. !empty(BXX->BXX_DATMOV)
		BCI->BCI_DTDIGI := BXX->BXX_DATMOV
	else
		BCI->BCI_DTDIGI := date()
	endIf

	// Data de recebimento do PEG
	BCI->BCI_DATREC := dDTRec
	BCI->BCI_ORIGEM := cOrigem

	BCI->BCI_CODCOR := BCL->BCL_CODCOR

	BCI->BCI_FASE   := cFase
	BCI->BCI_STTISS := if(cStaTiss < "2", "2", cStaTiss) //Em análise
	BCI->BCI_MES    := iIf(empty(aDatPag[5]), cMesBCI, aDatPag[5])
	BCI->BCI_ANO    := iIf(empty(aDatPag[4]), cAnoBCI, aDatPag[4])
	BCI->BCI_SITUAC	:= cSituac
	BCI->BCI_STATUS := "1"
	BCI->BCI_TIPO   := "2"

	if len(aDatPag) > 6
		BCI->BCI_CODDAT := aDatPag[6]
		if cCodRda != BAU->BAU_CODIGO //1
			BAU->(dbSetOrder(1))
			if BAU->(msSeek(xfilial("BAU")+cCodRDA))
				BCI->BCI_DATPAG := PLSCHKNCAL(BCI->BCI_MES)//aDatPag[7]
			else
				BCI->BCI_DATPAG := aDatPag[7]
			endIf
		else
			BCI->BCI_DATPAG := PLSCHKNCAL(BCI->BCI_MES)//aDatPag[7]
		endIf
	endIf
	BCI->BCI_LOTGUI := cLotGui
	BCI->BCI_GUIPAP := iIf( PLSRETPAP( cOpeRda,cCodRda,cTipGui),"1","0" )

	// Vlr.Tt.Guias/Nr Guias Dig/Qt.Evt.Dig./Qtd Eventos
	BCI->BCI_QTDEVE := nQtdTotEve
	BCI->BCI_QTDDIG := nQtdGui
	BCI->BCI_VLRGUI := nVlrTotGui
	BCI->BCI_VLRAPR := nVlrTotGui
	BCI->BCI_VALORI := nVlrTotGui * nQtdTotEve

	//Informa se é gravação da digitação off-line
	if (cDigOff == '1')
		BCI->BCI_DIGOFF := '1' //Se trata da digitação off-line
	else
		BCI->BCI_DIGOFF := '0'
	endIf

	if BCI->(fieldPos("BCI_IDXML")) > 0
		BCI->BCI_IDXML := cIDXML
	endIf

	if BCI->(fieldPos("BCI_LOTEDI")) > 0
		BCI->BCI_LOTEDI := cBrjCodigo
	endIf

	if BCI->(fieldPos("BCI_TIP550")) > 0
		BCI->BCI_TIP550 := cTpArq
	endIf

	BCI->( msUnLock() )

	BCI->( DbCommit() )

	if existBlock("PLDTDIGT")
		execBlock("PLDTDIGT",.f.,.f.,BCI->(recno()))
	endIf

	// Fecha semaforo
	PLSFechaSem(nHP,"PLSPEG.SMF")

return()

/*/{Protheus.doc} PLSATUPP
Atualiza peg
@type function
@author Tulio Cesar
@since 22/03/12
@version 1.0
/*/
function PLSATUPP(nQtdTotEve,nVlrTotGui,nQtdGui,lBusQtd,cCodOpe,cCodLdp,cCodPeg,cChaveOri,lVlrApr)
	local aAreaBD6 		:= BD6->(getArea())
	local aAreaBCI		:= BCI->(getArea())
	local cSql			:= ""
	local nVlrAprTot	:= 0
	local lEmpTyChv		:= .T.
	local lSeekBCI		:= .F.
	local cSqlZ			:= ""
	local cFaseZ		:= ""

	default nQtdTotEve 	:= 0
	default nVlrTotGui 	:= 0
	default nQtdGui 	:= 1
	default lBusQtd		:= .f.
	default cCodOpe		:= ""
	default cCodLdp		:= ""
	default cCodPeg		:= ""
	default cChaveOri	:= ""
	default lVlrApr		:= .f.

	lEmpTyChv := empTy(cCodOpe + cCodLdp + cCodPeg)

	if ! lEmpTyChv
		BCI->( dbSetOrder(1) ) //BCI_FILIAL + BCI_CODOPE + BCI_CODLDP + BCI_CODPEG + BCI_FASE + BCI_SITUAC
		lSeekBCI := BCI->( msSeek(xFilial("BCI") + cCodOpe + cCodLdp + cCodPeg) )
	endIf

	if ! lEmpTyChv

		// Busca totais
		if lBusQtd

			// Query totais
			cSql := " SELECT COUNT(BD6_CODPRO) AS QTDITET,SUM(BD6_VLRPAG) AS VLRAPRT "

			if lVlrApr
				cSql += ", SUM(BD6_VALORI) AS VLRAPRI  "
			endIf

			cSql += "   FROM " + retSQLName("BD6")
			cSql += "  WHERE BD6_FILIAL = '" + xFilial("BD6") + "' "
			cSql += "    AND BD6_CODOPE = '" + cCodOpe + "' "
			cSql += "    AND BD6_CODLDP = '" + cCodLdp + "' "
			cSql += "    AND BD6_CODPEG = '" + cCodPeg + "' "
			cSql += "    AND BD6_CODRDA = '" + IIf(lSeekBCI, BCI->BCI_CODRDA, BD6->BD6_CODRDA) + "' "
			cSql += "    AND D_E_L_E_T_ = ' ' "

			//abre a area
			OPEN QUERY cSql ALIAS "PLSATUPP"

			// atualiza dados do peg
			if !PLSATUPP->(eof())
				nQtdTotEve := PLSATUPP->QTDITET
				nVlrTotGui := PLSATUPP->VLRAPRT

				if lVlrApr
					nVlrAprTot := PLSATUPP->VLRAPRI
				endIf

			endIf

			CLOSE QUERY "PLSATUPP"
		endIf

		If !(empTy(cCodLdp)) .AND. PLSRETLDP(4) <> cCodLdp .AND. cCodLdp <> PLSRETLDP(9) //Não atualiza PEGs temporárias
			//Atualiza a fase do PEG..
			//Regra:
			//Se tem uma em digitação, Fase 1
			//Se não tem digitação e uma em conferência, Fase 2
			//Se não tem digitação, nem conferência e uma Pronta, Fase 3
			//Se não tem digitação, nem conferência, nem pronta e uma Faturada, Fase 4
			cSqlZ := " SELECT COUNT(BD6_FASE) FASEBD6, BD6_FASE FROM " + RetsqlName("BD6")
			cSqlZ += "  WHERE BD6_FILIAL = '" + xFilial("BD6") + "' "
			cSqlZ += "    AND BD6_CODOPE = '" + cCodOpe + "' "
			cSqlZ += "    AND BD6_CODLDP = '" + cCodLdp + "' "
			cSqlZ += "    AND BD6_CODPEG = '" + cCodPeg + "' "
			cSqlZ += "    AND BD6_CODRDA = '" + IIf(lSeekBCI, BCI->BCI_CODRDA, BD6->BD6_CODRDA) + "' "
			cSqlZ += "    AND D_E_L_E_T_ = ' ' "
			cSqlZ += "		GROUP BY BD6_FASE " //Da fase 1 pra fase 4

			OPEN QUERY cSqlZ ALIAS "PLFASPEG"

			if ! PLFASPEG->(eoF())

				while !PLFASPEG->(eoF())

					If PLFASPEG->BD6_FASE == "1" .AND. PLFASPEG->FASEBD6 > 0
						cFaseZ := ""
						Exit
					elseIf PLFASPEG->BD6_FASE == "2" .AND. PLFASPEG->FASEBD6 > 0
						cFaseZ := "2"
						Exit
					elseIf PLFASPEG->BD6_FASE == "3" .AND. PLFASPEG->FASEBD6 > 0
						cFaseZ := "3"
						Exit
					elseIf	PLFASPEG->BD6_FASE == "4" .AND. PLFASPEG->FASEBD6 > 0
						cFaseZ := "4"
						Exit
					endIf

					PLFASPEG->(DbSkip())
				endDo

			endIf

			CLOSE QUERY "PLFASPEG"

		endIf

	endIf

	if ! lEmpTyChv .And. lSeekBCI

		BCI->( recLock("BCI",.f.) )

		if ! lBusQtd
			BCI->BCI_QTDEVE	:= BCI->BCI_QTDEVE + nQtdTotEve
			BCI->BCI_QTDDIG	:= BCI->BCI_QTDDIG + nQtdGui
			BCI->BCI_VLRGUI	:= BCI->BCI_VLRGUI + nVlrTotGui
			if lVlrApr
				BCI->BCI_VLRAPR := BCI->BCI_VLRAPR + nVlrAprTot
			endIf
		else
			BCI->BCI_QTDEVE	:= nQtdTotEve
			BCI->BCI_QTDDIG	:= nQtdGui
			BCI->BCI_VLRGUI	:= nVlrTotGui
			if lVlrApr
				BCI->BCI_VLRAPR := BCI->BCI_VLRAPR + nVlrAprTot
			endIf
		endIf

		if ! empTy(cFaseZ)
			BCI->BCI_FASE := cFaseZ
		endIf

		BCI->( msUnLock() )
		BCI->( dbCommit() )

	endIf
	// atualiza a peg origem
	if ! empty(cChaveOri)

		BCI->( dbGotop() )
		BCI->( dbSetOrder(1) ) //BCI_FILIAL + BCI_CODOPE + BCI_CODLDP + BCI_CODPEG + BCI_FASE + BCI_SITUAC
		if BCI->( msSeek(xFilial("BCI") + cChaveOri) )

			BCI->( recLock("BCI",.f.) )
			if !lBusQtd
				BCI->BCI_QTDEVE	:= BCI->BCI_QTDEVE + nQtdTotEve
				BCI->BCI_QTDDIG	:= BCI->BCI_QTDDIG + nQtdGui
				BCI->BCI_VLRGUI	:= BCI->BCI_VLRGUI + nVlrTotGui
				if lVlrApr
					BCI->BCI_VLRAPR := BCI->BCI_VLRAPR + nVlrAprTot
				endIf
			else

				nQtdTotEve 	:= iIf(BCI->BCI_QTDEVE < nQtdTotEve	, 0, BCI->BCI_QTDEVE - nQtdTotEve)
				nQtdGui 	:= iIf(BCI->BCI_QTDDIG < nQtdGui	, 0, BCI->BCI_QTDDIG - nQtdGui)
				nVlrTotGui 	:= iIf(BCI->BCI_VLRGUI < nVlrTotGui	, 0, BCI->BCI_VLRGUI - nVlrTotGui)

				BCI->BCI_QTDEVE	:= nQtdTotEve
				BCI->BCI_QTDDIG	:= nQtdGui
				BCI->BCI_VLRGUI	:= nVlrTotGui
				if lVlrApr
					BCI->BCI_VLRAPR := BCI->BCI_VLRAPR + nVlrAprTot
				endIf
			endIf
			BCI->( msUnLock() )
			BCI->( DbCommit() )

		endIf
	endIf

	restArea(aAreaBD6)
	restArea(aAreaBCI)

return(nil)

/*/{Protheus.doc} PLSICAB
Inclui cabecalho da guia
@type function
@author Tulio Cesar
@since 24.04.12
@version 1.0
/*/
function PLSICAB(cTipGui,cCodOpe,cCodLdp,cCodPeg,cFase,cSituac,dDatPro,cHora,cMes,cAno,cNumImp,; //11
		cCid,nQtNasV,nQtNasM,nQtNasP,nQtObtP,nQtObAR,cTipFat,cCidObt,cNrdCob,cObtMul,; //21
		cTipAlt,cNrdCnv,aDadRDA,aCriticas,cLotGui,cNumLib,lHonor,cNumSol,cPadCon,; //30
		dDtAlta,cHrAlta,cEmgest,cAborto,cTraGra,cComurp,cAtespa,cComnal,cBaipes,cPaareo,; //40
		cPatnor,cArqImp,aItens,cTipSai,cTipCon,cNomUsr,cMatrAntGen,nRecExe,nRecSol,cTipoAte,; //50
		cGrpInt,cTipInt,cIndAci,cUndDoe,nTmpDoe,cTipDoe,cMsg01,cMsg02,cEspSol,cEspExe,cTipAdm,; //61
		cRegInt,cMesPag,cAnoPag,cCarSol,aItens,cAteRN,lImpTxt,cGuiOri,cCnes,cMatricXml, ; //71
		dDtIniFat,cHrIniFat,dDtFimFat,cHrFimFat, aEspCbXML, cGuiPri, lImpXml, cNumero, cNumInt, cTipPac,; //81
		cTipAto, cParCop, cTipMaj, aDadUsr, cIndCli, cGuiInt,cXCodRda, cCodEspNw, cRegAtdNw, cSadOcuNw)//91

	local cOpeSol 		:= ""
	local cEstSol 		:= ""
	local cSigSol 		:= ""
	local cRegSol 		:= ""
	local cNomSol 		:= ""
	local cCdPfSo 		:= ""
	local lInterc 		:= .f.
	local cGrpEmpInt	:= getNewPar("MV_PLSGEIN","0050")
	local lUnimeds		:= iIf( allTrim( getNewPar("MV_PLSUNI","1") )=="1", .t. , .f. )
	local nOrdBEA 		:= 0
	local nRecBEA 		:= 0
	local lTratGuiPre	:= getNewPar("MV_PLTRPRE",.f.)   // TRATA A GUIA DO PRESTADOR NA IMPORTAÇÃO DA TISS, HÁ CLIENTES QUE NAO TEM ESSA INforMAÇÃO NO SISTEMA ()
	Local cSenhaRInt	:= ""
	local lCodEspEmp	:= .t. //Indica se o cod.especialidade esta vazio
	local aHistContr	:= {} //Dados do histórico de transferência de contrato
	Local cPartpAdmE	:= getNewPar("MV_PLSCDEL","")
	Local cPartpAdmU	:= getNewPar("MV_PLSCDUR","")

	default lHonor  	:= .f.
	default lImpTxt 	:= .f.
	default cNumSol 	:= ""
	default cPadCon 	:= ""
	default dDtAlta 	:= ""
	default cHrAlta 	:= ""
	default cEmgest 	:= ""
	default cAborto 	:= ""
	default cTraGra 	:= ""
	default cComurp 	:= ""
	default cAtespa 	:= ""
	default cComnal 	:= ""
	default cBaipes 	:= ""
	default cPaareo 	:= ""
	default cPatnor 	:= ""
	default cArqImp 	:= ""
	default aItens  	:= {}
	default cTipSai 	:= ""
	default cTipCon 	:= ""
	default cNomUsr 	:= ""
	default cMatrAntGen := ""
	default nRecExe 	:= 0
	default nRecSol 	:= 0
	default cTipoAte	:= ''
	default cGrpInt 	:= ''
	default cTipInt 	:= ''
	default cIndAci 	:= ''
	default cUndDoe 	:= ''
	default nTmpDoe 	:= 0
	default cTipDoe 	:= ''
	default cMsg01  	:= ''
	default cMsg02  	:= ''
	default cEspSol 	:= ''
	default cEspExe		:= ''
	default cTipAdm		:= ''
	default cRegInt		:= ''
	default cMesPag		:= ''
	default cAnoPag		:= ''
	default cAteRN		:= "0"
	default cGuiOri		:= ''
	default cCnes		:= ''
	default cMatricXml	:= ' '
	default dDtIniFat  	:= ctod("")
	default cHrIniFat  	:= ""
	default dDtFimFat  	:= ctod("")
	default cHrFimFat  	:= ""
	default aEspCbXML	:= {}
	default cGuiPri		:= ""
	default lImpXml		:= .f.
	default cNumero 	:= ""
	default cNumInt 	:= ""
	default cCidObt     := ""
	default cNrdCob     := ""
	default cTipPac		:= getNewPar("MV_PLSTPAA","9")
	default cTipAto		:= ''
	default aDadUsr 	:= PLSGETUSR()
	default cParCop		:= '0'
	default cTipMaj		:= ''
	default cIndCli		:= ''
	default cGuiInt 	:= ''
	default cXCodRda    := ''

	if empty(cTipPac)
		cTipPac		:= getNewPar("MV_PLSTPAA","9")
	endif

	//Verifica se existe divergência no histórico de transferência de contratos
	aHistContr := plsConEmp(dDatPro,BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG+BA1->BA1_DIGITO)

	// Verifica o tipo de guia
	if cTipGui $ G_CONSULTA + '|' + G_SADT + '|' + G_HONORARIO + '|' + G_REEMBOLSO + '|' + G_REC_GLOSA + "|" + G_ODONTO

		// Inclui cabecalho da guia
		if empty(cNumero)

			cNumero  := PLSA500NUM("BD5", cCodOpe, cCodLdp, cCodPeg)

			PLSLOGFIL("Atenção: chamada PLSICAB invalida. Contate o suporte. Código 'PLSICAB'","PLSISCAB.LOG")

		endIf

		BA3->( dbSetOrder(1) )
		BA3->( msSeek( xFilial("BA3") + BA1->( BA1_CODINT+BA1_CODEMP+BA1_MATRIC ) ) )

		BI3->( dbSetOrder(1) )//BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO
		BI3->(msSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO) ) )

		BD5->( RecLock("BD5",.t.) )

		BD5->BD5_FILIAL := xFilial("BD5")

		// Chave da guia
		BD5->BD5_CODOPE := cCodOpe
		BD5->BD5_CODLDP := cCodLdp
		BD5->BD5_CODPEG := cCodPeg
		BD5->BD5_NUMERO := cNumero

		// Profissional solicitante
		if nRecSol > 0
			BB0->(dbGoto(nRecSol))
			BD5->BD5_OPESOL := cCodOpe
			BD5->BD5_ESTSOL := BB0->BB0_ESTADO
			BD5->BD5_SIGLA  := BB0->BB0_CODSIG
			BD5->BD5_REGSOL := BB0->BB0_NUMCR
			BD5->BD5_NOMSOL := BB0->BB0_NOME
			BD5->BD5_CDPFSO := BB0->BB0_CODIGO
		endIf

		// Profissional solicitante
		if nRecExe > 0
			BB0->(dbGoto(nRecExe))
			BD5->BD5_OPEEXE := cCodOpe
			BD5->BD5_ESTEXE := BB0->BB0_ESTADO
			BD5->BD5_SIGEXE := BB0->BB0_CODSIG
			BD5->BD5_REGEXE := BB0->BB0_NUMCR
			BD5->BD5_CDPFRE := BB0->BB0_CODIGO
		endIf

		// Rede de Atendimento
		BD5->BD5_OPERDA := cCodOpe

		if len(aDadRDA) > 0
			BD5->BD5_CODRDA := aDadRDA[2]
			BD5->BD5_NOMRDA := aDadRDA[6]
			BD5->BD5_TIPRDA := aDadRDA[8]
			BD5->BD5_CODLOC := aDadRDA[12]
			BD5->BD5_LOCAL  := aDadRDA[13]

			if existBlock("PLTISESP") .and. lImpXml .and. !empty(PLSRETDAD(aItens[1],"ESPPE",""))
				BD5->BD5_CODESP := PLSRETDAD(aItens[1],"ESPPE","")
				lCodEspEmp := .F.
			else
				BD5->BD5_CODESP := aDadRDA[15]
			endIf

			BD5->BD5_CPFRDA := aDadRDA[16]
			BD5->BD5_DESLOC := aDadRDA[19]
			BD5->BD5_ENDLOC := aDadRDA[20]
			BD5->BD5_TIPPRE := aDadRDA[27]
		endIf

		//caso a rda fique vazia por conta do cliente ter um local com CNES sem especlidade cadastrada, evita  ter q excluir a importação e importar novamente após arrumar o cadastro.
		if Empty(BD5->BD5_CODRDA)
			BD5->BD5_CODRDA := cXCodRda
		endif

		// Usuario
		BD5->BD5_OPEUSR := BA1->BA1_CODINT
		BD5->BD5_MATANT := BA1->BA1_MATANT

		if allTrim(BA1->BA1_MATANT) == allTrim(cMatrAntGen)
			BD5->BD5_NOMUSR := cNomUsr
		else
			BD5->BD5_NOMUSR := BA1->BA1_NOMUSR
		endIf

		if !empty(cMatricXml)
			BD5->BD5_MATXML := cMatricXml
		endIf

		if BA1->BA1_CODEMP == cGrpEmpInt
			lInterc := .t.
		endIf

		BD5->BD5_CODEMP := BA1->BA1_CODEMP

		BD5->BD5_MATRIC := BA1->BA1_MATRIC
		BD5->BD5_TIPREG := BA1->BA1_TIPREG
		BD5->BD5_CPFUSR := BA1->BA1_CPFUSR
		BD5->BD5_IDUSR  := BA1->BA1_DRGUSR
		BD5->BD5_DATNAS := BA1->BA1_DATNAS
		BD5->BD5_DIGITO := BA1->BA1_DIGITO

		BD5->BD5_CONEMP := Iif(Empty(aHistContr),BA1->BA1_CONEMP,aHistContr[1])
		BD5->BD5_VERCON := Iif(Empty(aHistContr),BA1->BA1_VERCON,aHistContr[3])
		BD5->BD5_SUBCON := Iif(Empty(aHistContr),BA1->BA1_SUBCON,aHistContr[2])
		BD5->BD5_VERSUB := Iif(Empty(aHistContr),BA1->BA1_VERSUB,aHistContr[4])

		BD5->BD5_MATVID := BA1->BA1_MATVID

		// Dados complementares
		BD5->BD5_FASE	:= cFase
		BD5->BD5_SITUAC	:= cSituac
		BD5->BD5_DATPRO	:= dDatPro
		BD5->BD5_HORPRO	:= cHora
		BD5->BD5_NUMIMP	:= cNumImp //Numero do impresso no PLS e sempre o Nro. da guia do prestador
		BD5->BD5_GUIINT := cGuiInt

		if lUnimeds

			nOrdBEA := BEA->(indexOrd())
			nRecBEA := BEA->(recno())

			BEA->(dbSetOrder(14))
			If	! empty(cNumLib) .and. BEA->(MsSeek(xFilial("BEA")+cNumLib)) .and. !Empty(BEA->BEA_NRAOPE)
				BD5->BD5_NRAOPE := BEA->BEA_NRAOPE
			else
				BD5->BD5_NRAOPE	:= cNumLib
			endIf

			BEA->(dbGoto(nRecBEA))
			BEA->(dbSetOrder(nOrdBEA))

		else
			BD5->BD5_NRAOPE	:= cNumLib
		endIf

		BD5->BD5_LOTGUI	:= cLotGui
		BD5->BD5_TIPGUI := cTipGui
		BD5->BD5_GUIORI	:= cGuiOri

		if lImpXml .and. !empty(BXX->BXX_DATMOV)
			BD5->BD5_DTDIGI 	:= BXX->BXX_DATMOV
		else
			BD5->BD5_DTDIGI 	:= date()
		endIf
		if BD5->(fieldpos("BD5_TISVER")) > 0
			if lImpXml
				BD5->BD5_TISVER	:= BXX->BXX_TISVER
			else
				BD5->BD5_TISVER	:= PGetTISVer()
			endif
		endif

		BD5->BD5_MESPAG := cMesPag
		BD5->BD5_ANOPAG := cAnoPag
		BD5->BD5_TIPPAC := cTipPac
		BD5->BD5_MATUSA := "1"
		BD5->BD5_ATERNA := cAteRN
		BD5->BD5_ATEAMB	:= '1'
		BD5->BD5_PACOTE := "0"
		BD5->BD5_ORIMOV := "1"
		BD5->BD5_GUIACO := "0"
		BD5->BD5_LIBERA := "0"
		BD5->BD5_RGIMP  := "1"
		BD5->BD5_TPGRV  := "4"
		BD5->BD5_TIPATE := cTipoAte
		BD5->BD5_CID	:= cCid
		BD5->BD5_TIPFAT := cTipFat
		BD5->BD5_REGATE := iIf(len(aDadUsr) >= 92, aDadUsr[92], "")
		BD5->BD5_TIPATO	:= cTipAto
		BD5->BD5_TIPMAJ := cTipMaj
		BD5->BD5_REGINT := cRegInt
		BD5->BD5_GRPINT := cGrpInt
		BD5->BD5_TIPINT := cTipInt

		if lcmpTiss4
			//Guia Consulta e SADT r7
			BD5->BD5_COBESP := cCodEspNw
			BD5->BD5_TMREGA := cRegAtdNw
			BD5->BD5_SAUOCU := cSadOcuNw
		endif

		if !empty(cPadCon)
			BD5->BD5_PADCON := cPadCon
		else
			BD5->BD5_PADCON := PLSACOMUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),'2')
		endIf

		BD5->BD5_PADINT := BI3->BI3_CODACO
		BD5->BD5_QTDEVE := len(aItens)
		BD5->BD5_TIPSAI := cTipSai
		BD5->BD5_TIPCON := iif(cTipoAte == '04' .and. empty(cTipCon), '1',cTipCon )
		BD5->BD5_INDACI := cIndAci
		BD5->BD5_SENHA  := cNumLib
		BD5->BD5_INDCLI	:= substr(cIndCli,1,250)
		BD5->BD5_INDCL2	:= substr(cIndCli,251,250)

		//Pelo padrão TISS, o valor do caráter de atendimento pode ser 1 (eletivo) ou 2 (Urgência/emergência)
		//Caso o ctipadm chegue aqui com 1 ou 2, é que não houve de-para ou a terminologia cadastrada no sistema é a mesma da TISS
		//daí o sistema vai buscar se há valor nos parâmetros de valor default e usar eles, caso contrário, usa o que veio com o de-para
		//o E e U foi mantido por legado somente para que o comportamento do sistema não mude para clientes com algum cadastro antigo.
		if cTipAdm $ "E,1" .AND. ! empty(cPartpAdmE)
			cTipAdm	:= cPartpAdmE
		elseif cTipAdm $ "U,2" .AND. ! empty(cPartpAdmU)
			cTipAdm	:= cPartpAdmU
		endIf

		BD5->BD5_TIPADM	:= cTipAdm

		BD5->BD5_OBSGUI := cMsg01 + cMsg02
		BD5->BD5_ESPSOL := cEspSol

		if ! empty(cEspEXe)
			BD5->BD5_ESPEXE := cEspEXe
		else
			BD5->BD5_ESPEXE := PLSRETDAD(aItens[1],"ESPPRO","")
		endIf

		BD5->BD5_UTPDOE    := cUndDoe
		BD5->BD5_TPODOE    := nTmpDoe
		BD5->BD5_TIPDOE    := cTipDoe
		BD5->BD5_CNES      := cCnes

		If !lHonor .and. valType(cGuiPri) == "C" .and. !empty(cGuiPri)
			BD5->BD5_GUIPRI := cGuiPri
		endif

		if lHonor

			BD5->BD5_GUIPRI := iIf( valType(cGuiPri) <> "C", "", cGuiPri)
			BD5->BD5_REGFOR := '1'

			if ! empty(cNumSol)

				BE4->(dbSetOrder(2))
				if BE4->( msSeek(xFilial("BE4") + padr(cNumSol,18)))

					BD5->BD5_GUIINT := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
					BD5->BD5_GUIPRI := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)

					if lInterc
						BD5->BD5_NRAOPE := BE4->BE4_NRAOPE
					endIf

					BD5->BD5_SENHA  := BE4->BE4_SENHA

				else

					BE4->( dbSetOrder(7) )
					if BE4->( msSeek( xFilial("BE4") + padr(cNumSol,TamSX3("BE4_SENHA")[1])))

						BD5->BD5_GUIINT := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
						BD5->BD5_GUIPRI := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)

						if lInterc
							BD5->BD5_NRAOPE := BE4->BE4_NRAOPE
						endIf

						BD5->BD5_SENHA  := BE4->BE4_SENHA

					else

						PLSICRI(@aCriticas,__aXMLCri23[1],__aXMLCri23[2])

					endIf

				endIf

			endIf

		else

			BEA->( dbSetOrder(1) )
			if BEA->( msSeek( xFilial("BEA") + padr(allTrim(cNumLib),18)) )

				//se esta eh uma liberacao
				if BEA->BEA_LIBERA == '1'

					BD5->BD5_NRLBOR	:= BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)

					if lInterc
						BD5->BD5_NRAOPE := BEA->BEA_NRAOPE
					endIf

					BD5->BD5_SENHA  := BEA->BEA_SENHA

				else

					BD5->BD5_NRLBOR	:= iIf( empty(BEA->BEA_NRLBOR), BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT), BEA->BEA_NRLBOR)

					if lInterc
						BD5->BD5_NRAOPE := BEA->BEA_NRAOPE
					endIf

					BD5->BD5_SENHA  := BEA->BEA_SENHA

				endIf

				If BEA->BEA_TIPGUI == "03"
					BD5->BD5_GUIPRI := BEA->(BEA_OPEINT+BEA_ANOINT+BEA_MESINT+BEA_NUMINT)
					BE4->(DbSetOrder(2))
					If BE4->(MsSeek(xFilial("BE4") + BEA->(BEA_OPEINT+BEA_ANOINT+BEA_MESINT+BEA_NUMINT)))
						BD5->BD5_GUIINT := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
					endIf
				endIf
			else

				BEA->( dbSetOrder(14) )
				if !empty(cNumLib) .and. BEA->( msSeek( xFilial("BEA") + padr(allTrim(cNumLib),tamSX3("BEA_SENHA")[1])) )

					//se esta eh uma liberacao
					if BEA->BEA_LIBERA == '1'

						BD5->BD5_NRLBOR	:= BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)

						if lInterc
							BD5->BD5_NRAOPE := BEA->BEA_NRAOPE
						endIf

						BD5->BD5_SENHA  := BEA->BEA_SENHA

					else

						BD5->BD5_NRLBOR	:= iIf( empty(BEA->BEA_NRLBOR), BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT), BEA->BEA_NRLBOR)

						if lInterc
							BD5->BD5_NRAOPE := BEA->BEA_NRAOPE
						endIf

						BD5->BD5_SENHA  := BEA->BEA_SENHA

					endIf

					If BEA->BEA_TIPGUI == "03"
						BD5->BD5_GUIPRI := BEA->(BEA_OPEINT+BEA_ANOINT+BEA_MESINT+BEA_NUMINT)
						BE4->(DbSetOrder(2))
						If BE4->(MsSeek(xFilial("BE4") + BEA->(BEA_OPEINT+BEA_ANOINT+BEA_MESINT+BEA_NUMINT)))
							BD5->BD5_GUIINT := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
						endIf
					endIf
				else

					if lTratGuiPre

						cAliasTrb := GetnextAlias()

						BeginSql Alias cAliasTrb
							SELECT
								BEA.R_E_C_N_O_
							FROM
								%table:BEA% BEA
							WHERE
								BEA_FILIAL = %exp:xFilial("BEA")%
								AND BEA_GUIPRE = %exp:cNumLib%
								AND BEA.%NotDel%
						Endsql

						if (cAliasTrb)->(eof())

							if !empty(cNumLib)
								PLSICRI(@aCriticas,__aXMLCri23[1],__aXMLCri23[2])
							endIf
						else

							BEA->(dbGoto((cAliasTrb)->R_E_C_N_O_))

							(cAliasTrb)->(dbCloseArea())

							//se esta eh uma liberacao
							if BEA->BEA_LIBERA == '1'

								BD5->BD5_NRLBOR	:= BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)

								if lInterc
									BD5->BD5_NRAOPE := BEA->BEA_NRAOPE
								endIf

								BD5->BD5_SENHA  := BEA->BEA_SENHA

							else

								BD5->BD5_NRLBOR	:= iIf( empty(BEA->BEA_NRLBOR), BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT), BEA->BEA_NRLBOR)

								if lInterc
									BD5->BD5_NRAOPE := BEA->BEA_NRAOPE
								endIf

								BD5->BD5_SENHA  := BEA->BEA_SENHA

							endIf

							If BEA->BEA_TIPGUI == "03"
								BD5->BD5_GUIPRI := BEA->(BEA_OPEINT+BEA_ANOINT+BEA_MESINT+BEA_NUMINT)
								BE4->(DbSetOrder(2))
								If BE4->(MsSeek(xFilial("BE4") + BEA->(BEA_OPEINT+BEA_ANOINT+BEA_MESINT+BEA_NUMINT)))
									BD5->BD5_GUIINT := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
								endIf
							endIf
						endIf

					endIf

				endIf

			endIf

		endIf

		//Ajuste nos dados de especialidade
		if len(aEspCbXML) > 0 .and. lCodEspEmp
			PlGrvEspXML("BD5",aEspCbXML)
		endIf

		BD5->( msUnLock() )

		cRet := BD5->(BD5_CODOPE+" - "+BD5_CODLDP+" - "+BD5_CODPEG+" - "+BD5_NUMERO)

	elseIf cTipGui $ G_SOL_INTER + '|' + G_RES_INTER

		aAreaBEA := BEA->(GetArea())

		BEA->( dbSetOrder(14) )     //Ha Cliente que tem que comparar a senha com a matricula para saber se é o mesmo usuario
		if BEA->( msSeek(xFilial("BEA")+padr(allTrim(cNumLib),18)) )

			if BEA->BEA_LIBERA == '1'

				if BA1->(BA1_MATRIC) <> BEA->(BEA_MATRIC)
					PLSICRI(@aCriticas,__aXMLCri23[1],__aXMLCri23[2])
				endIf

			endIf

		endIf
		RestArea(aAreaBEA)

		if empty(cNumero)

			cNumero  := PLSA500NUM("BE4", cCodOpe, cCodLdp, cCodPeg)

			PLSLOGFIL("Atenção: chamada PLSICAB invalida. Contate o suporte. Código 'PLSICAB'","PLSISCAB.LOG")

		endIf

		cCC := PLSUSRCC(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))

		if empty(cNumInt)

			cNumInt  := PLNUMINT(cCodOpe,cAno,cMes)
			PLSLOGFIL("Atenção: chamada PLSICAB invalida. Contate o suporte. Código 'PLSICAB'","PLSISCAB.LOG")

		endIf

		BA3->( dbSetOrder(1) )
		BA3->( msSeek( xFilial("BA3") + BA1->( BA1_CODINT+BA1_CODEMP+BA1_MATRIC ) ) )

		BI3->( dbSetOrder(1) )//BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO
		BI3->(msSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO) ) )

		BE4->(RecLock("BE4",.t.))

		BE4->BE4_FILIAL := xFilial("BE4")
		BE4->BE4_CODOPE := cCodOpe
		BE4->BE4_CODLDP := cCodLdp
		BE4->BE4_CODPEG := cCodPeg
		BE4->BE4_NUMERO := cNumero
		BE4->BE4_NUMIMP := cNumImp//o numero do impresso no pls eh sempre o nro da guia no prestador
		BE4->BE4_GUIORI := cGuiOri
		BE4->BE4_GUIIMP := "1"
		BE4->BE4_DATPRO := BE4->BE4_DATPRO := iIf(cTipGui == G_RES_INTER,dDtIniFat,dDatPro)
		BE4->BE4_PRVINT := dDatPro
		BE4->BE4_DATVAL := BE4->BE4_DATPRO+getNewPar("MV_PLPRZAI",30)
		BE4->BE4_TIPUSR := aDadUsr[43]
		BE4->BE4_HORPRO := cHora
		BE4->BE4_OPEUSR := BA1->BA1_CODINT
		BE4->BE4_MATANT := BA1->BA1_MATANT
		BE4->BE4_ATERNA := cAteRN
		BE4->BE4_NRDCOB := cNrdCob
		BE4->BE4_CIDOBT := cCidObt

		if allTrim(BA1->BA1_MATANT) == allTrim(cMatrAntGen)
			BE4->BE4_NOMUSR := cNomUsr
		else
			BE4->BE4_NOMUSR := BA1->BA1_NOMUSR
		endIf

		if !empty(cMatricXml)
			BE4->BE4_MATXML := cMatricXml
		endIf

		BE4->BE4_OPERDA := cCodOpe

		if len(aDadRDA) > 0
			BE4->BE4_CODRDA := aDadRDA[2]
			BE4->BE4_NOMRDA := aDadRDA[6]
			BE4->BE4_CODESP := aDadRda[15]
			BE4->BE4_LOCAL  := aDadRda[13]
			BE4->BE4_CODLOC := aDadRda[12]
			BE4->BE4_TIPPRE := aDadRda[27]
		endIf

		BE4->BE4_TIPCON	:= cTipCon
		BE4->BE4_INDACI	:= cIndAci
		BE4->BE4_UTPDOE	:= cUndDoe
		BE4->BE4_TPODOE	:= nTmpDoe
		BE4->BE4_TIPDOE	:= cTipDoe

		if empty(cCid)
			BE4->BE4_CID := xRetCidGe()
			BE4->BE4_DESCID := BA9->(Posicione("BA9",1,xFilial("BA9")+BE4->BE4_CID,"BA9_DOENCA"))
		else
			BE4->BE4_CID := cCid
			BE4->BE4_DESCID := BA9->(Posicione("BA9",1,xFilial("BA9")+BE4->BE4_CID,"BA9_DOENCA"))
		endIf

		if !empty(BE4->BE4_CID)
			BE4->BE4_INTSIP := BA9->(Posicione("BA9",1,xFilial("BA9")+BE4->BE4_CID,"BA9_INTSIP"))
		endIf

		BE4->BE4_OPESOL := cCodOpe
		BE4->BE4_TIPGUI := BCI->BCI_TIPGUI
		BE4->BE4_CODEMP := BA1->BA1_CODEMP
		BE4->BE4_MATRIC := BA1->BA1_MATRIC

		if BA1->BA1_CODEMP == cGrpEmpInt
			lInterc := .t.
		endIf

		BE4->BE4_TIPREG := BA1->BA1_TIPREG
		BE4->BE4_CPFUSR := BA1->BA1_CPFUSR
		BE4->BE4_IDUSR  := BA1->BA1_DRGUSR
		BE4->BE4_DATNAS := BA1->BA1_DATNAS
		BE4->BE4_FASE   := BCI->BCI_FASE
		BE4->BE4_SITUAC := BCI->BCI_SITUAC
		BE4->BE4_DIGITO := BA1->BA1_DIGITO

		BE4->BE4_CONEMP := Iif(Empty(aHistContr),BA1->BA1_CONEMP,aHistContr[1])
		BE4->BE4_VERCON := Iif(Empty(aHistContr),BA1->BA1_VERCON,aHistContr[3])
		BE4->BE4_SUBCON := Iif(Empty(aHistContr),BA1->BA1_SUBCON,aHistContr[2])
		BE4->BE4_VERSUB := Iif(Empty(aHistContr),BA1->BA1_VERSUB,aHistContr[4])

		BE4->BE4_MATVID := BA1->BA1_MATVID

		if lImpXml .and. ! empty(BXX->BXX_DATMOV)
			BE4->BE4_DTDIGI 	:= BXX->BXX_DATMOV
		else
			BE4->BE4_DTDIGI 	:= date()
		endIf

		if BE4->(fieldpos("BE4_TISVER")) > 0
			if lImpXml
				BE4->BE4_TISVER	:= BXX->BXX_TISVER
			else
				BE4->BE4_TISVER	:= PGetTISVer()
			endif
		endif

		BE4->BE4_ANOINT := cAno
		BE4->BE4_MESINT := cMes
		BE4->BE4_NUMINT := cNumInt
		BE4->BE4_MATUSA := "1"
		BE4->BE4_PACOTE := "0"
		BE4->BE4_SENHA  := cNumSol
		BE4->BE4_TPGRV  := "4"
		BE4->BE4_ORIMOV := "2"
		BE4->BE4_MESPAG := cMesPag
		BE4->BE4_ANOPAG := cAnoPag
		BE4->BE4_CC     := cCC

		if cTipAdm $ "E,1"
			BE4->BE4_TIPADM	:=  getNewPar("MV_PLSCDEL","0")
		else
			BE4->BE4_TIPADM	:=  getNewPar("MV_PLSCDUR","0")
		endIf

		BE4->BE4_PADINT := BI3->BI3_CODACO
		BE4->BE4_RGIMP  := "1"

		if nRecSol > 0
			BB0->(dbGoto(nRecSol))
			BE4->BE4_OPESOL := cCodOpe
			BE4->BE4_ESTSOL := BB0->BB0_ESTADO
			BE4->BE4_SIGLA  := BB0->BB0_CODSIG
			BE4->BE4_REGSOL := BB0->BB0_NUMCR
			BE4->BE4_NOMSOL := BB0->BB0_NOME
			BE4->BE4_CDPFSO := BB0->BB0_CODIGO
		endIf

		if nRecExe > 0
			BB0->(dbGoto(nRecExe))
			BE4->BE4_OPEEXE := cCodOpe
			BE4->BE4_ESTEXE := BB0->BB0_ESTADO
			BE4->BE4_SIGLA  := BB0->BB0_CODSIG
			BE4->BE4_REGEXE := BB0->BB0_NUMCR
			BE4->BE4_NOMEXE := BB0->BB0_NOME
			BE4->BE4_CDPFRE := BB0->BB0_CODIGO
		endIf

		BE4->BE4_STATUS := '1'

		if ! empty(cPadCon)
			BE4->BE4_PADCON := cPadCon
		else
			BE4->BE4_PADCON := PLSACOMUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG),'2')
		endIf

		BE4->BE4_DTALTA := dDtAlta
		BE4->BE4_HRALTA := cHrAlta
		BE4->BE4_DTINif := dDtIniFat
		BE4->BE4_HRINif := cHrIniFat
		BE4->BE4_DTFIMF := dDtFimFat
		BE4->BE4_HRFIMF := cHrFimFat
		BE4->BE4_TIPFAT := cTipFat
		BE4->BE4_QTDEVE := len(aItens)
		BE4->BE4_EMGEST := cEmgest
		BE4->BE4_ABORTO := cAborto
		BE4->BE4_TRAGRA := cTragra
		BE4->BE4_COMURP := cComurp
		BE4->BE4_ATESPA := cAtespa
		BE4->BE4_COMNAL := cComnal
		BE4->BE4_BAIPES := cBaipes
		BE4->BE4_PARCES := cPaareo
		BE4->BE4_PATNOR := cPatNor
		BE4->BE4_ARQIMP := cArqImp
		BE4->BE4_LOTGUI := cLotGui
		BE4->BE4_NRDCNV := cNrdCnv
		BE4->BE4_NASVIV := nQtNasV
		BE4->BE4_NASMOR := nQtNasM
		BE4->BE4_NASVPR := nQtNasP
		BE4->BE4_OBTMUL := cObtMul
		BE4->BE4_MSG01 	:= cMsg01
		BE4->BE4_MSG02 	:= cMsg02
		BE4->BE4_ESPSOL := cEspSol
		BE4->BE4_ESPEXE := cEspExe
		BE4->BE4_CNES   := cCnes
		BE4->BE4_GRPINT := cGrpInt
		BE4->BE4_TIPINT := cTipInt
		BE4->BE4_TIPALT := cTipAlt
		BE4->BE4_REGINT := cRegInt
		BE4->BE4_TIPMAJ := cTipMaj

		//Ajuste nos dados de especialidade
		if len(aEspCbXML) > 0
			PlGrvEspXML("BE4",aEspCbXML)
		endIf

		BE4->(msUnLock())
		nRecBE4 := BE4->(recno())

		If ! empty(cNumSol)

			BE4->(dbSetOrder(2))
			if BE4->(msSeek(xFilial("BE4") + padr(cNumSol,18)))

				cChave 	:= BE4->BE4_CODOPE+BE4->BE4_CODLDP+BE4->BE4_CODPEG+BE4->BE4_NUMERO
				cTipAl1 := Posicione('BIY',1,xFilial('BIY')+cCodOpe+cTipAlt,'BIY_MOTSAI')

				//se o tipo de faturamento eh total eu tenho que fechar a guia de solicitacao
				if cTipFat $ "T,4" .and. allTrim(cTipAl1) <> '31' //se o tipo de alta nao eh por transferencia

					BE4->(RecLock("BE4",.f.))

					BE4->BE4_DTALTA := dDtAlta
					BE4->BE4_HRALTA := cHrAlta
					BE4->BE4_TIPFAT := cTipFat
					BE4->BE4_TIPALT := cTipAlt

					if empty(BE4->BE4_DATPRO)
						BE4->BE4_DATPRO := dDatPro
					endIf

					if empty(BE4->BE4_PRVINT)
						BE4->BE4_PRVINT := dDatPro
					endIf

					if empty(BE4->BE4_DATVAL)
						BE4->BE4_DATVAL := BE4->BE4_DATPRO+getNewPar("MV_PLPRZAI",30)
					endIf

					if empty(BE4->BE4_HORPRO)
						BE4->BE4_HORPRO := cHora
					endIf
					BE4->(msUnLock())

				else

					BE4->(RecLock("BE4",.f.))
					if empty(BE4->BE4_DATPRO)
						BE4->BE4_DATPRO := dDatPro
					endIf
					if empty(BE4->BE4_PRVINT)
						BE4->BE4_PRVINT := dDatPro
					endIf
					if empty(BE4->BE4_DATVAL)
						BE4->BE4_DATVAL := BE4->BE4_DATPRO+getNewPar("MV_PLPRZAI",30)
					endIf
					if empty(BE4->BE4_HORPRO)
						BE4->BE4_HORPRO := cHora
					endIf

					BE4->(msUnLock())

				endIf

				cOpeSol := BE4->BE4_OPESOL
				cEstSol := BE4->BE4_ESTSOL
				cSigSol := BE4->BE4_SIGLA
				cRegSol := BE4->BE4_REGSOL
				cNomSol := BE4->BE4_NOMSOL
				cCdPfSo := BE4->BE4_CDPFSO
				cNraOpe := BE4->BE4_NRAOPE
				cSenhaRInt := BE4->BE4_SENHA

				BE4->(dbGoto(nRecBE4))

				//gravo na guia de resumo o nro da solicitacao
				BE4->(RecLock("BE4",.f.))

				BE4->BE4_GUIINT := cChave
				BE4->BE4_SENHA  := cSenhaRInt
				BE4->BE4_OPESOL  := cOpeSol
				BE4->BE4_ESTSOL  := cEstSol
				BE4->BE4_SIGLA   := cSigSol
				BE4->BE4_REGSOL  := cRegSol
				BE4->BE4_NOMSOL  := cNomSol
				BE4->BE4_CDPFSO  := cCdPfSo

				if ! empty(cNraOpe) .and. lInterc
					BE4->BE4_NRAOPE := cNraOpe
				endIf

				BE4->(msUnLock())

			else

				BE4->( dbSetOrder(7) )
				if BE4->(msSeek(xFilial("BE4") + padr(cNumSol,tamSx3("BE4_SENHA")[1])))

					cTipAl1 := Posicione('BIY',1,xFilial('BIY')+cCodOpe+cTipAlt,'BIY_MOTSAI')

					cChave := BE4->BE4_CODOPE+BE4->BE4_CODLDP+BE4->BE4_CODPEG+BE4->BE4_NUMERO

					//se o tipo de faturamento eh total eu tenho que fechar a guia de solicitacao
					//se o tipo de alta nao eh por transferencia
					if cTipFat $ "T,4" .and. allTrim(cTipAl1) <> '31'

						BE4->(RecLock("BE4",.f.))
						BE4->BE4_DTALTA := dDtAlta
						BE4->BE4_HRALTA := cHrAlta
						BE4->BE4_TIPFAT := cTipFat
						BE4->BE4_TIPALT := cTipAlt

						if empty(BE4->BE4_DATPRO)
							BE4->BE4_DATPRO := dDatPro
						endIf

						if empty(BE4->BE4_PRVINT)
							BE4->BE4_PRVINT := dDatPro
						endIf

						if empty(BE4->BE4_DATVAL)
							BE4->BE4_DATVAL := BE4->BE4_DATPRO+getNewPar("MV_PLPRZAI",30)
						endIf

						if empty(BE4->BE4_HORPRO)
							BE4->BE4_HORPRO := cHora
						endIf
						BE4->(msUnLock())

					endIf

					cOpeSol := BE4->BE4_OPESOL
					cEstSol := BE4->BE4_ESTSOL
					cSigSol := BE4->BE4_SIGLA
					cRegSol := BE4->BE4_REGSOL
					cNomSol := BE4->BE4_NOMSOL
					cCdPfSo := BE4->BE4_CDPFSO
					cNraOpe := BE4->BE4_NRAOPE
					cSenhaRInt := BE4->BE4_SENHA

					BE4->(dbGoto(nRecBE4))

					//gravo na guia de resumo o nro da solicitacao
					BE4->(RecLock("BE4",.f.))

					BE4->BE4_GUIINT := cChave
					BE4->BE4_SENHA  := cSenhaRInt
					BE4->BE4_OPESOL  := cOpeSol
					BE4->BE4_ESTSOL  := cEstSol
					BE4->BE4_SIGLA   := cSigSol
					BE4->BE4_REGSOL  := cRegSol
					BE4->BE4_NOMSOL  := cNomSol
					BE4->BE4_CDPFSO  := cCdPfSo

					if ! empty(cNraOpe) .and. lInterc
						BE4->BE4_NRAOPE := cNraOpe
					endIf

					BE4->(msUnLock())

				else
					PLSICRI(@aCriticas,__aXMLCri23[1],__aXMLCri23[2])
				endIf

			endIf

		endIf

		BE4->(dbGoto(nRecBE4))

		cRet := BE4->(BE4_CODOPE+" - "+BE4_CODLDP+" - "+BE4_CODPEG+" - "+BE4_NUMERO)

	endIf

	if existBlock('PLSICAB1')
		execBlock( 'PLSICAB1',.f.,.f.,{	cTipGui,cCodOpe,cCodLdp,cCodPeg,cFase,cSituac,dDatPro,cHora,cMes,cAno,cNumImp,;
			cCid,nQtNasV,nQtNasM,nQtNasP,nQtObtP,nQtObAR,cTipFat,cCidObt,cNrdCob,cObtMul,;
			cTipAlt,cNrdCnv,aDadRDA,aCriticas,cLotGui,cNumLib,lHonor,cNumSol,cPadCon,;
			dDtAlta,cHrAlta,cEmgest,cAborto,cTraGra,cComurp,cAtespa,cComnal,cBaipes,cPaareo,;
			cPatnor,cArqImp} )
	endIf

return cRet

/*/{Protheus.doc} PLSIITE
Inclui item da guia
@type function
@author PLSTEAM
@since 24.04.12
@version 1.0
/*/
function PLSIITE(cLocalExec,cTipoGrv,aItens,aCriticas,cNumLib,aTipPart,cAlias,lHonor,dDatPro,cHora,cOrimov,;
		cMatrAntGen,dDatAcat,lImpTxt,aDadUsr,lnInfEquip, lXmlOrigS, lImpXml)
	local nI	  	:= 0
	local nJk		:= 1
	local nfor	  	:= 0
	local nforY	  	:= 0
	local nforCpo 	:= 0
	local cSeqMov 	:= ""
	local cCodPad 	:= ""
	local cCodPro 	:= ""
	local cDente 	:= ""
	local cFace 	:= ""
	local nQtd	  	:= 0
	local nVlrApr	:= 0
	local nVlTxAp	:= 0
	local nVlrDif 	:= 0
	local nPerVia 	:= 0

	local nVlrBpr 	:= 0
	local nVlrGlo 	:= 0
	local nVlrMan 	:= 0
	local nVlrPag 	:= 0

	local nVlrBpf 	:= 0
	local nVlrTpf 	:= 0
	local nVlrPf 	:= 0
	local nPrTxPg	:= 0
	local nValoriRG	:= 0

	local cCodVia 	:= ""
	local cMacro  	:= ""
	local cCampoOri	:= ""
	local cCodGlo 	:= ""
	local cDesGlo 	:= ""
	local cSlvPad 	:= ""
	local cSlvPro 	:= ""
	local cSlvDes 	:= ""
	local cLibCer	:= ""
	local cEspPro	:= ""
	local cNivAux 	:= ""
	local cNivCri 	:= ""
	local cChvNiv 	:= ""
	local cPagAto	:= ""
	local cCdPdRc	:= ""
	local cProRel	:= ""
	local cTpEvCt	:= ""
	local ljaexec   := .F.

	local aCompo	:= {}
	local aCodTab	:= {}
	local aCpoNiv 	:= {}
	local aCposPad	:= {}
	local aPartic	:= {}
	local aTpPar	:= {}
	local aUndBd7  	:= {}
	local aBD7		:= {}
	local lWeb		:= .f.
	local nPac		:= 0
	local lUnimeds	:= iIf( allTrim( getNewPar("MV_PLSUNI","1") )=="1", .t. , .f. )
	Local cGenXML	:= allTrim(getNewPar("MV_PLPSPXM","99999994"))
	Local cGenPTU 	:= allTrim(getNewPar("MV_PLMEDPT","")) + "|" + allTrim(getNewPar("MV_PLMATPT","")) + "|" + allTrim(getNewPar("MV_PLTAXPT","")) + "|" + allTrim(getNewPar("MV_PLOPMPT",""))
	Local lPLSUNHMS := existBlock('PLSUNHMS')
	Local lPLSIITE1 := existBlock('PLSIITE1')
	Local cUniMedida := ""
	Local lGrvBX6	:= .F.
	Local cSeqTISS := ""
	Local cIdOutDes := ""
	local cDescFace	:= ""
	local lGrvFac	:= .f.
	local aRetVld	:= {}
	local lSaldoMfas := getNewPar("MV_PLPRAUT","1") == "1" //indica que o saldo será verificado e baixado na mudança de fase

	default lHonor  	:= .f.
	default lImpTxt		:= .f.
	default dDatPro 	:= ctod('')
	default cHora   	:= ''
	default cOrimov 	:= '1'
	default cAlias 	 	:= "BD5"
	default cMatrAntGen := ""
	default dDatAcat    := date()
	default aDadUsr 	:= PLSGETUSR()
	default lnInfEquip 	:= .f.
	default lXmlOrigS  	:= .f.
	default lImpXml		:= .f.

	// Indice
	BR8->( dbSetOrder(1) ) //BR8_FILIAL + BR8_CODPAD + BR8_CODPSA + BR8_ANASIN

	// Ajusta a descricao e tpproc dos itens
	for nfor := 1 To len(aItens)

		aPartic   	:= {}
		lAtuSaldo 	:= .f.
		lGrvFac		:= .f.

		lWeb		:= PLSRETDAD(aItens[nfor],"RPC",(PLSRETDAD(aItens[nfor],"TPGRV","1") == "2" ))

		cSeqMov 	:= PLSRETDAD(aItens[nfor],"SEQMOV")
		cCodPad 	:= PLSRETDAD(aItens[nfor],"CODPAD")
		cCodPro 	:= PLSRETDAD(aItens[nfor],"CODPRO")
		cDesPro 	:= PLSRETDAD(aItens[nfor],"DESPRO")

		cCdPdRc 	:= PLSRETDAD(aItens[nfor],"CDPDRC")
		cProRel 	:= PLSRETDAD(aItens[nfor],"PROREL")

		cNivAux 	:= PLSRETDAD(aItens[nfor],"NIVAUT")
		cNivCri 	:= PLSRETDAD(aItens[nfor],"NIVCRI")
		cChvNiv 	:= PLSRETDAD(aItens[nfor],"CHVNIV")
		cPagAto 	:= PLSRETDAD(aItens[nfor],"PAGATO")
		cTpEvCt 	:= PLSRETDAD(aItens[nfor],"TPEVCT")

		nVlrBpr 	:= PLSRETDAD(aItens[nfor],"VALBPR",0)
		nVlrGlo 	:= PLSRETDAD(aItens[nfor],"VALGLO",0)
		nVlrMan 	:= PLSRETDAD(aItens[nfor],"VALMAN",0)
		nVlrPag 	:= PLSRETDAD(aItens[nfor],"VALPAG",0)

		nVlrBpf 	:= PLSRETDAD(aItens[nfor],"VALBPF",0)
		nVlrTpf 	:= PLSRETDAD(aItens[nfor],"VALTPF",0)
		nVlrPf 		:= PLSRETDAD(aItens[nfor],"VALPF",0)

		nVlrApr		:= PLSRETDAD(aItens[nfor],"VALOR",0)
		nVlrApr		:= PLSRETDAD(aItens[nfor],"VLRAPR",nVlrApr)
		nPrTxPg		:= PLSRETDAD(aItens[nfor],"PRTXPG",0)
		nVlTxAp		:= PLSRETDAD(aItens[nfor],"VLTXAP",0)
		nVlrDif		:= PLSRETDAD(aItens[nfor],"VLRDIF",nVlrDif)

		nQtd		:= PLSRETDAD(aItens[nfor],"QTD",0)
		aTpPar	 	:= PLSRETDAD(aItens[nfor],"ATPPAR",{})
		cHorIni 	:= PLSRETDAD(aItens[nfor],"HORINI",cHora)
		cHorFim 	:= PLSRETDAD(aItens[nfor],"HORFIM",cHora)
		dDtPro		:= PLSRETDAD(aItens[nfor],"DATPRO",dDatPro)
		cSlvPad 	:= PLSRETDAD(aItens[nfor],"SLVPAD",'')
		cSlvPro 	:= PLSRETDAD(aItens[nfor],"SLVPRO",'')
		cSlvDes 	:= PLSRETDAD(aItens[nfor],"SLVDES",'')

		cCodVia 	:= PLSRETDAD(aItens[nfor],"VIAACE",'')
		nPerVia 	:= PLSRETDAD(aItens[nfor],"PERVIA",0)

		if nPerVia == 0
			nPerVia := plRtPerV(cCodVia)
			PLSPUTDAD(aItens[nfor],"PERVIA",nPerVia,.t.)
		endIf

		cDente  	:= PLSRETDAD(aItens[nfor],"DENTE","")
		cFace   	:= PLSRETDAD(aItens[nfor],"FACE","")
		cEspPro 	:= PLSRETDAD(aItens[nfor],"ESPPRO","")
		cEspPe		:= PLSRETDAD(aItens[nfor],"ESPPE","")
		aBD7		:= PLSRETDAD(aItens[nfor],"REGBD7",{})
		aEspItXML	:= PLSRETDAD(aItens[nfor],"ESPXML",{})
		aPacPro		:= PLSRETDAD(aItens[nfor],"PACPRO",{})

		lGrvBX6	:= .F.
		cUniMedida	:= PLSRETDAD(aItens[nfor],"MEDIDA","")
		cSeqTISS 	:= PLSRETDAD(aItens[nfor],"SQTISS","")
		cIdOutDes	:= PLSRETDAD(aItens[nfor],"IDOUTD","")

		nValoriRG	:= PLSRETDAD(aItens[nfor],"VALORIRG",0)
		cDescFace	:= PLSRETDAD(aItens[nfor],"DESOFACE","")

		If !(empTy(cUniMedida)) .OR. (lBX6SQTISS .AND. !(empTy(cSeqTISS))) .OR. (lBX6IDOUTD .AND. !(empTy(cIdOutDes)))
			lGrvBX6 := .T.
		EndIf

		for nJk := 1 To len(aTpPar)

			aadd(aPartic, {	aTpPar[nJk,1],; 					//[1]
				cSeqMov,;							//[2]
				cCodPad + cCodPro,;					//[3]
				nVlrApr,;							//[4]
				aTpPar[nJk,5],;						//[5]
				aTpPar[nJk,4],;						//[6]
				aTpPar[nJk,6],;						//[7]
				0,;									//[8]
				iIf(len(aTpPar[nJk]) >= 9,aTpPar[nJk,9],''),;//[9] BD7_CDPFPR
				aTpPar[nJk,2],;						//[10] BD7_CODRDA
				aTpPar[nJk,3],;						//[11]
				iIf(len(aTpPar[nJk]) >= 10,aTpPar[nJk,10],''),;//[12] BD7_ESPEXE
				iIf(len(aTpPar[nJk]) >= 11,aTpPar[nJk,11],{})} )//unidade que posso incluir, se vazio posso todas
		next

		BR8->( dbSetOrder(1) )
		BR8->( msSeek(xFilial("BR8")+cCodPad+cCodPro) )

		BT5->(dbSetOrder(1))
		BT5->(msSeek(xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP)))

		// Composicao do Nivel
		aCpoNiv := PLSUpCpoNv(cCodPad,cCodPro,"BD6")

		// Grava itens
		BD6->( RecLock("BD6",.t.) )

		// Nivel
		for nforY := 1 To len(aCpoNiv)
			&(aCpoNiv[nforY,1]) := (aCpoNiv[nforY,2])
		next

		// Detalhe
		BD6->BD6_FILIAL := xFilial("BD6")

		// Evento
		BD6->BD6_SEQUEN := cSeqMov
		BD6->BD6_CODPAD := cCodPad

		if !empty(cEspPe) .and. existBlock("PLTISESP") .and. lImpXml
			BD6->BD6_CODESP := cEspPe
		else
			BD6->BD6_CODESP := &(cAlias + "->" + cAlias + "_CODESP")
		endIf

		BD6->BD6_ESPEXE	:= BD6->BD6_CODESP
		BD6->BD6_ESPSOL	:= BD6->BD6_CODESP

		BD6->BD6_SLVPAD := cSlvPad
		BD6->BD6_CODPRO := cCodPro
		BD6->BD6_SLVPRO := cSlvPro

		BD6->BD6_CDPDRC	:= cCdPdRc
		BD6->BD6_PROREL	:= cProRel

		if !empty(cDesPro) .and. (allTrim(cCodPro) == cGenXML  .OR. (lUnimeds .AND. allTrim(cCodPro) $ cGenPTU))
			BD6->BD6_DESPRO := upper(cDesPro)
			BD6->BD6_SLVDES := cSlvDes
		else
			BD6->BD6_DESPRO := BR8->BR8_DESCRI
			BD6->BD6_SLVDES := cSlvDes
		endIf

		// Dente e face quando e procedimento de consulta no odontologico
		if !empty(cDente)

			B04->( dbSetOrder(1) )//B04_FILIAL+B04_CODIGO+B04_TIPO
			if B04->(msSeek(XFILIAL("B04") + cDente))
				BD6->BD6_DENREG := cDente
				BD6->BD6_DESREG := B04->B04_DESCRI
			endIf

		endIf

		if !empty(cFace)
			if empty(cDescFace)
				aRetVld := PlRtDOdoFc(cFace, cCodpad, cCodPro, cDente)
				if aRetVld[1] .and. aRetVld[2]
					cDescFace := aRetVld[3]
					lGrvFac	:= .t.
				endif
			else 
				lGrvFac	:= .t.	
			endif
			if lGrvFac
				BD6->BD6_FADENT := cFace
				BD6->BD6_FACDES := cDescFace
			endIf

		endIf

		if BCI->BCI_TIPGUI == '05'
			aDadRDA := PLSGETRDA()
			if len(aDadRDA) > 0
				BD6->BD6_TIPRDA := aDadRDA[8]
			endif
		endif

		BD6->BD6_DTDIGI := dDatAcat

		BD6->BD6_NIVEL  := BR8->BR8_NIVEL
		BD6->BD6_QTDPRO := nQtd
		BD6->BD6_QTDAPR := nQtd
		BD6->BD6_VLRAPR := nVlrApr
		BD6->BD6_VLTXAP := nVlTxAp

		If IsInCallStack("PLSRECGLO2") .or. IsInCallStack("PLSRECGLO3")
			BD6->BD6_VALORI := iif(nValoriRG > 0, nValoriRG, nVlrApr)
		Else
			BD6->BD6_VALORI := (nVlrApr * nQtd)
		EndIf

		if nPrTxPg > 0
			BD6->BD6_VLTXAP := ( BD6->BD6_VALORI * nPrTxPg ) / 100
		endIf

		if lImpTxt
			BD6->BD6_VLRBPR := nVlrBpr
			BD6->BD6_VLRMAN := nVlrMan
			BD6->BD6_VLRGLO := nVlrGlo
			BD6->BD6_VLRPAG := nVlrPag

			BD6->BD6_VLRBPF := nVlrBpf
			BD6->BD6_VLRTPF := nVlrTpf
			BD6->BD6_VLRPF 	:= nVlrPf
		endIf

		if nVlrDif > 0
			BD6->BD6_VLRDEC := nVlrDif
		endIf

		if nVlrDif < 0
			BD6->BD6_VLRDEC := -(nVlrDif)
		endIf

		BD6->BD6_PERVIA := nPerVia
		BD6->BD6_VIA 	:= cCodVia
		BD6->BD6_PROCCI := if(BR8->BR8_TIPEVE$"2,3","1","0") //Mesma regra do gatilho do campo BD6_CODPRO no proc contas

		if !empty(BD6->BD6_VIA) .and. BD6->BD6_VIA >= "1"
			BD6->BD6_PROCCI := "1"
		endIf

		if !empty(dDtPro)
			BD6->BD6_DATPRO := dDtPro
		endIf

		if !empty(cHorIni)
			BD6->BD6_HORPRO := cHorIni
		endIf

		if !empty(cHorFim)
			BD6->BD6_HORFIM := strTran(cHorFim,':','')
		endIf

		// usuario
		BD6->BD6_OPEORI := BA1->BA1_OPEORI
		BD6->BD6_MATANT := BA1->BA1_MATANT
		BD6->BD6_CODPLA := BA3->BA3_CODPLA

		BD6->BD6_MODCOB := iIf( len(aDadUsr) >= 48, aDadUsr[48], "")
		BD6->BD6_TIPUSR := iIf( len(aDadUsr) >= 90, aDadUsr[90], "")
		BD6->BD6_INTERC := iIf( len(aDadUsr) >= 91, aDadUsr[91], "0")
		BD6->BD6_TIPINT := iIf( len(aDadUsr) >= 43, aDadUsr[43], "")

		// Complemento
		BD6->BD6_INCAUT := '1'
		BD6->BD6_STATUS := "1"
		BD6->BD6_NRAOPE := cNumLib
		BD6->BD6_ATEAMB := '1'
		BD6->BD6_PAGATO := cPagAto
		BD6->BD6_TPEVCT := cTpEvCt

		BD6->BD6_NIVAUT := cNivAux
		BD6->BD6_NIVCRI := cNivCri
		BD6->BD6_CHVNIV := cChvNiv

		// Monta strutura de dados do bd5 para espelhar no bd6
		aCposPad := (cAlias)->( DbStruct() )

		for nforCpo := 1 To len(aCposPad)

			cMacro := ( "BD6->BD6_" + Subs( aCposPad[nforCpo,1],5,10 ) )

			if Type(cMacro) <> "U" .and. !(allTrim("BD6_" + Subs(aCposPad[nforCpo,1],5,10) ) $ "BD6_DATPRO,BD6_HORPRO,BD6_CNPJED,BD6_VLRAPR,BD6_VALORI,BD6_VLRTPF,BD6_VLRPAG,BD6_VLRGLO,BD6_TPRDAE,BD6_QTDAPR,BD6_TIPUSR,BD6_RDAEDI,BD6_NOMEDI,BD6_TRDAED,BD6_RPEDI,BD6_ESPEDI,BD6_VLRMAN,BD6_VLRBPR,BD6_CODESP,BD6_TIPINT")

				cCampoOri := (cAlias)->&( cAlias + "_" + Subs( aCposPad[nforCpo,1],5,10) )
				&(cMacro) := cCampoOri
			endIf
		next

		// Retorna tabela
		aCodTab := PLSRETTAB(BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_DATPRO,;
			BD6->BD6_CODOPE,BD6->BD6_CODRDA,BD6->BD6_CODESP,BD6->BD6_SUBESP,BD6->(BD6_CODLOC+BD6_LOCAL),;
			BD6->BD6_DATPRO,"1",BD6->BD6_OPEORI,BD6->BD6_CODPLA,"2","1")

		if aCodTab[1]
			BD6->BD6_CODTAB := aCodTab[3]
			BD6->BD6_ALIATB := aCodTab[4]
		endIf

		// Verifica se envia para conferencia
		cCodGlo := ""

		if aScan( aCriticas,{|x| x[3]+x[4]+x[5] == BD6->(BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO) } ) > 0
			cCodGlo := aCriticas[nI,1]
			cDesGlo := aCriticas[nI,2]
		else

			for nI := 1 To len(aCriticas)

				if empty(aCriticas[nI,3])
					cCodGlo := aCriticas[nI,1]
					cDesGlo := aCriticas[nI,2]
					exit
				endIf

			next

		endIf

		// Envia para conferencia
		PLBLOPC("BD6", (! empty(cCodGlo) ), cCodGlo, cDesGlo, .t., .f., (! empty(cCodGlo) ))

		if !lImpXml .and. !lWeb .and. !lImpTxt
			BD6->BD6_CONMUS := '0'//desconsidero a guia para tratamento de qtd x periodicidade
		endIf

		BD6->( msUnLock() )

		cTipGui := (cAlias)->&( cAlias + "_TIPGUI" )

		if cTipGui $ G_CONSULTA + "|" + G_SADT + "|" + G_REEMBOLSO + "|" + G_REC_GLOSA + "|" + G_ODONTO //Vericar

			cLibCer := (cAlias)->&( cAlias + "_NRLBOR" )

		elseIf cTipGui $ G_SOL_INTER + "|" + G_RES_INTER + "|" + G_HONORARIO

			cLibCer := (cAlias)->&( cAlias + "_GUIINT" )

		endIf

		//Cria a B43 caso for pacote
		if len(aPacPro) > 0

			aChvPac := {	BD6->BD6_SEQUEN,;
				BD6->BD6_CODOPE,;
				BD6->BD6_CODLDP,;
				BD6->BD6_CODPEG,;
				BD6->BD6_NUMERO,;
				BD6->BD6_ORIMOV}

			for nPac := 1 to len(aPacPro)
				B43->(Reclock("B43",.t.))
				B43->B43_SEQUEN := aChvPac[1]
				B43->B43_CODOPE := aChvPac[2]
				B43->B43_CODLDP := aChvPac[3]
				B43->B43_CODPEG := aChvPac[4]
				B43->B43_NUMERO := aChvPac[5]
				B43->B43_ORIMOV := aChvPac[6]
				B43->B43_DESPRO := Posicione("BR8",1,xFilial("BR8") + aPacPro[nPac][1] + aPacPro[nPac][2], "BR8_DESCRI")
				B43->B43_CODPAD := aPacPro[nPac][1]
				B43->B43_CODPRO := aPacPro[nPac][2]
				B43->B43_TIPO   := aPacPro[nPac][3]
				B43->B43_VALCH  := aPacPro[nPac][4]
				B43->B43_VALFIX := aPacPro[nPac][5]
				B43->B43_PRINCI := aPacPro[nPac][6]
				B43->B43_NIVPAC := aPacPro[nPac][10]
				B43->( msUnLock() )
			next

		endIf

		If lGrvBX6
			PLGRVBX6(cUniMedida, cSeqTISS, cIdOutDes)
		EndIF
		// Complemento do evento
		if lImpTxt

			PLSICOP(cTipGui,aBD7)

		else

			PLS720IBD7('',BD6->BD6_VLPGMA,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODTAB,BD6->BD6_CODOPE,BD6->BD6_CODRDA,;
				BD6->BD6_REGEXE,BD6->BD6_SIGEXE,BD6->BD6_ESTEXE,BD6->BD6_CDPFRE,BD6->BD6_CODESP,BD6->(BD6_CODLOC+BD6_LOCAL),"1",BD6->BD6_SEQUEN,;
				cOrimov,cTipGui,BD6->BD6_DATPRO,nil,nil,nil,nil,nil,nil,nil,nil,aPartic,aTipPart,lHonor,dDatAcat,,,,,lnInfEquip, lXmlOrigS,,aEspItXml)

			//Cria "UNL" (UNIDADE NAO localIZADA) caso a mesma nao tenha sido criada acima
			BD7->(dbSetOrder(1))
			if !BD7->(msSeek(xFilial('BD6')+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))

				//BD7
				PCrB7Gen("UNL",aTpPar,nVlrApr)

				//BD6
				BD6->(Reclock("BD6",.f.))
				BD6->BD6_ENVCON := "1"
				BD6->( msUnLock() )

				//Carrega a composição do Evento
				aCompo := PLSCOMEVE(BD6->BD6_CODTAB,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODOPE,BD6->BD6_DATPRO)

				//Ajusta as especialidades caso for importacao XML
				if len(aEspItXML) > 0
					PlGrvEspXML("BD7",aEspItXML,aCompo)
				endIf

				aadd(aUndBd7,"UNL")

			else

				//Carrega a composição do Evento
				aCompo := PLSCOMEVE(BD6->BD6_CODTAB,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODOPE,BD6->BD6_DATPRO)

				nRecBD7 := BD7->(recno())

				//Ajusta as especialidades caso for importacao XML
				if (len(aEspItXML) > 0 .or. len(aUndBD7) == 0) .and. !lUnimeds
					PlGrvEspXML("BD7",aEspItXML,aCompo,,,aUndBD7)
				endIf

				BD7->(dbGoto(nRecBD7))

			endIf

			//E usuario generico, vou glosar manualmente p ir para conferencia...
			if allTrim(BD6->BD6_MATANT) == allTrim(cMatrAntGen)

				PLSPOSGLO(PLSINTPAD(),__aCdCri091[1],__aCdCri091[2],clocalExec,'1',cTipoGrv)

				BD6->(RecLock("BD6",.f.))
				PLBLOPC("BD6", .t., __aCdCri091[1], PLSBCTDESC(), .t., .f., .t.)
				BD6->(msUnLock())

				if BD7->(msSeek(xFilial('BD6')+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))

					while !BD7->(eof()) .and. xFilial('BD6')+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) == ;
							BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

						BD7->(RecLock("BD7",.f.))
						BD7->BD7_BLOPAG := BD6->BD6_BLOPAG
						BD7->BD7_MOTBLO := BD6->BD6_MOTBPG
						BD7->BD7_DESBLO := BD6->BD6_DESBPG
						BD7->(msUnLock())

						BD7->(dbSkip())
					endDo

				endIf

			endIf

			if len(aUndBd7) > 0

				cUndHM := "HM,HMR,PPM,RCC,CIR"

				if lPLSUNHMS
					cUndHM := execBlock( 'PLSUNHMS',.f.,.f.,{cUndHM} )
				endIf

				//verifica se tem honorario no evento
				if aScan(aCompo,{|x| allTrim(x[1]) $ cUndHM }) > 0

					for nforY := 1 to len(aUndBd7)

						// no evento que eu acabei de criar tem o honorario
						if allTrim(aUndBd7[nforY]) $ cUndHM
							lAtuSaldo := .t.
							exit
						endIf

					next

				else
					lAtuSaldo := .t.
					if BD6->BD6_TIPGUI <> "05"
						ljaexec := PlsVrcExec()
						if ljaexec
							lAtuSaldo := .f.
						endif
					endif
				endIf

				if ! lAtuSaldo
					BD6->( reclock("BD6",.f.) )
					BD6->BD6_CONMUS := '0'//se nao vou atualizar o saldo significa que essa guia nao conta para quantidade/periodicidade
					BD6->( msUnLock() )
				endIf

				if lAtuSaldo .and. ! empty(cLibCer) .AND. !lSaldoMfas //não atualiza se é processado na mudança  de fase
					PLSAtuLib(cLibCer,'',BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_QTDPRO,aPartic,cTipGui$"05",cTipGui$"06")
				endIf

			endIf

		endIf

		if lPLSIITE1
			execBlock( 'PLSIITE1',.f.,.f.,{cSeqMov,cCodPad,cCodPro,cDesPro,nVlrApr,nQtd,aTpPar,cHorIni,cHorFim,dDtPro,cSlvPad,cSlvPro,cSlvDes} )
		endIf

	next

return

/*/{Protheus.doc} PLSICOP
Composicao da guia BD7
@type function
@author Tulio Cesar
@since 24.04.12
@version 1.0
/*/
static function PLSICOP(cTipoGuia,aCompo)
	local nInd			:= 0
	local cNoSeApli 	:= getNewPar("MV_PLSNAPL","O")
	local lBD7_DTDIGI   := BD7->(fieldPos("BD7_DTDIGI")) > 0

	default aCompo := {}

	BR8->(dbSetOrder(1))
	BR8->(msSeek(xFilial("BR8")+BD6->(BD6_CODPAD+BD6_CODPRO)))

	BD7->(dbSetOrder(1)) //BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC

	for nInd := 1 to len(aCompo)

		if BD7->( msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)+aCompo[nInd,2]+aCompo[nInd,3]) )
			loop
		endIf

		BD7->(recLock("BD7",.t.))
		BD7->BD7_FILIAL 	:= xFilial("BD7")
		BD7->BD7_CODOPE 	:= BD6->BD6_CODOPE
		BD7->BD7_CODLDP 	:= BD6->BD6_CODLDP
		BD7->BD7_CODPEG 	:= BD6->BD6_CODPEG
		BD7->BD7_NUMERO 	:= BD6->BD6_NUMERO
		BD7->BD7_SEQUEN 	:= BD6->BD6_SEQUEN
		BD7->BD7_CODPRO 	:= BD6->BD6_CODPRO
		BD7->BD7_CODPAD 	:= BD6->BD6_CODPAD
		BD7->BD7_LIBERA 	:= BD6->BD6_LIBERA
		BD7->BD7_CC     	:= BD6->BD6_CC
		BD7->BD7_NUMIMP 	:= BD6->BD6_NUMIMP
		BD7->BD7_TIPUSR 	:= BD6->BD6_TIPUSR
		BD7->BD7_PERHES 	:= BD6->BD6_PERHES
		BD7->BD7_LOTGUI 	:= BD6->BD6_LOTGUI
		BD7->BD7_NOMUSR 	:= BD6->BD6_NOMUSR
		BD7->BD7_INTERC 	:= BD6->BD6_INTERC
		BD7->BD7_SEQIMP 	:= BD6->BD6_SEQIMP
		BD7->BD7_ESPSOL 	:= BD6->BD6_ESPSOL
		BD7->BD7_TIPGUI 	:= BD6->BD6_TIPGUI
		BD7->BD7_CID		:= BD6->BD6_CID
		BD7->BD7_OPEUSR 	:= BD6->BD6_OPEUSR
		BD7->BD7_TIPREG 	:= BD6->BD6_TIPREG
		BD7->BD7_MATRIC 	:= BD6->BD6_MATRIC
		BD7->BD7_CODEMP 	:= BD6->BD6_CODEMP
		BD7->BD7_CONEMP 	:= BD6->BD6_CONEMP
		BD7->BD7_SUBCON 	:= BD6->BD6_SUBCON
		BD7->BD7_VERSUB 	:= BD6->BD6_VERSUB
		BD7->BD7_VERCON 	:= BD6->BD6_VERCON
		BD7->BD7_BLOPAG 	:= BD6->BD6_BLOPAG
		BD7->BD7_MOTBLO 	:= BD6->BD6_MOTBPG
		BD7->BD7_DESBLO 	:= BD6->BD6_DESBPG
		BD7->BD7_TPGRV  	:= BD6->BD6_TPGRV
		BD7->BD7_CODPLA 	:= BD6->BD6_CODPLA
		BD7->BD7_ANOPAG 	:= BD6->BD6_ANOPAG
		BD7->BD7_MESPAG 	:= BD6->BD6_MESPAG
		BD7->BD7_DATPRO 	:= BD6->BD6_DATPRO
		BD7->BD7_ORIMOV 	:= BD6->BD6_ORIMOV
		BD7->BD7_CODESP 	:= BD6->BD6_CODESP
		BD7->BD7_DESESP 	:= BAQ->(posicione("BAQ",1,xFilial("BAQ")+BD6->(BD6_OPERDA+BD6_CODESP),"BAQ_DESCRI"))
		BD7->BD7_MODCOB 	:= BA3->BA3_MODPAG
		BD7->BD7_CONMFT 	:= BR8->BR8_CONMFT

		if lBD7_DTDIGI
			BD7->BD7_DTDIGI 	:= BD6->BD6_DTDIGI
		endIf

		BD7->BD7_LOCATE 	:= BD6->(BD6_CODLOC+BD6_LOCAL)
		BD7->BD7_LOCAL  	:= BD6->BD6_LOCAL
		BD7->BD7_CODLOC 	:= BD6->BD6_CODLOC
		BD7->BD7_FASE		:= BD6->BD6_FASE
		BD7->BD7_SITUAC 	:= BD6->BD6_SITUAC
		BD7->BD7_DESLOC 	:= BD1->(Posicione("BD1",1,xFilial("BD1")+BD6->(BD6_CODOPE+BD6_CODLOC),"BD1_DESLOC"))
		BD7->BD7_PROCCI 	:= if(BR8->BR8_TIPEVE $ "2,3","1","0")
		BD7->BD7_PROBD7 	:= "1"

		//Considera o BD6 posicionado!!!
		if findFunction("PLSCLAINS")
			BD7->BD7_CLAINS := PLSCLAINS()
		endIf

		BD7->BD7_CODTPA := aCompo[nInd,1]
		BD7->BD7_CODUNM := aCompo[nInd,2]
		BD7->BD7_NLANC  := iIf(allTrim(BD7->BD7_CODUNM) $ getNewPar("MV_PLSCAUX","AUX"),strZero(val(aCompo[nInd,3]),2),"")
		BD7->BD7_REFTDE := aCompo[nInd,4]
		BD7->BD7_UNITDE := aCompo[nInd,5]
		BD7->BD7_SIGLA	:= aCompo[nInd,7]
		BD7->BD7_REGPRE	:= aCompo[nInd,8]
		BD7->BD7_ESTPRE	:= aCompo[nInd,9]
		BD7->BD7_NOMPRE	:= BB0->( Posicione("BB0",4,xFilial("BB0")+BD7->(BD7_ESTPRE+BD7_REGPRE+BD7_SIGLA),"BB0_NOME") )
		BD7->BD7_CDPFPR := aCompo[nInd,10]
		BD7->BD7_CODRDA := aCompo[nInd,11]
		BD7->BD7_NOMRDA := aCompo[nInd,12]
		BD7->BD7_ESPEXE := aCompo[nInd,13]

		BD7->BD7_VLRBPR := aCompo[nInd,18]
		BD7->BD7_VLRMAN := aCompo[nInd,19]
		BD7->BD7_VLRAPR	:= aCompo[nInd,17]
		BD7->BD7_VLRGLO	:= aCompo[nInd,14]
		BD7->BD7_VLRPAG	:= aCompo[nInd,15]

		BD7->BD7_VLRBPF := aCompo[nInd,20]
		BD7->BD7_VLRTPF	:= aCompo[nInd,16]

		if allTrim(BD7->BD7_CODTPA) <> cNoSeApli .and. (cTipoGuia $ '03,05' .or. BD6->BD6_LIBERA == '1')
			BD7->BD7_SALDO := BD6->BD6_QTDPRO
		endIf

		BD7->(msUnLock())
	next

return()

/*/{Protheus.doc} PLSICRI
Inclusao de critica
@type function
@author Tulio Cesar
@since 24.04.12
@version 1.0
/*/
static function PLSICRI(aCriticas,cCodCri,cDescri,cSequen,cCodPad,cCodPro)
	local aArea 	:= BCT->(getArea())
	local lAtivo	:= .t.
	local lUpdLoad	:= .t.
	default cSequen	:= ""
	default cCodPad := ""
	default cCodPro := ""

	if BCT->(msSeek(xFilial("BCT")+PlsIntPad()+cCodCri))
		if BCT->BCT_ATIVO == "0"
			lAtivo:=.f. //Critica n/ao esta ativa
		endIf

		if BCT->BCT_ENVCOX <> "1"
			lUpdLoad := .f. // Critica n/ao esta ativa UPLOAD
		endIf

		if !lAtivo  .and.  !lUpdLoad
			return // Critica n/ao esta ativa
		endIf

	endIf
	RestArea(aArea)


	// Se nao existe inclui
	if aScan( aCriticas,{|x| x[1]+x[3]+x[4]+x[5] == cCodCri+cSequen+cCodPad+cCodPro } ) == 0
		aadd( aCriticas,{cCodCri,cDescri,cSequen,cCodPad,cCodPro} )
	endIf

return

/*/{Protheus.doc} PLSIPRF
Verifica se o profissional existe e cria
@type function
@author Tulio Cesar
@since 24.04.12
@version 1.0
/*/
function PLSIPRF(cOpeMov,cCodPSol)
	local cEst	:= BA0->( Posicione("BA0",1, xFilial("BA0") + cOpeMov,"BA0_EST") )
	local nRecBB0	:= 0

	// Verifica se existe o profissional
	if !empty( allTrim(cCodPSol) ) .and. len(cCodPSol)<=6
		BB0->( dbSetOrder(1) )//BB0_FILIAL+BB0_CODIGO
	elseIf !empty( allTrim(cCodPSol) ) .and. len(cCodPSol)>=6
		BB0->(dbSetOrder(4))//BB0_FILIAL+BB0_ESTADO+BB0_NUMCR+BB0_CODSIG+BB0_CODOPE
	endIf
	// Cria profissional de saude
	if !BB0->(msSeek( xFilial("BB0")+cCodPSol ) )

		//Se não deu Seek na BB0 Verifica se não da Seek no profissional padrão da operadora.
		BB0->(dbSetOrder(7))//BB0_FILIAL+BB0_NUMCR...
		if !BB0->(msSeek( xFilial("BB0")+"OPE" + cOpeMov ) )
			PlSveProfAll("PROFISSIONAL PAD. OPER. " + cOpeMov, getMv("MV_PLSIGLA"), cEst, "OPE" + cOpeMov, cOpeMov, '', '1', cOpeMov, {})
		endIf
	endIf
	nRecBB0 := BB0->(recno())

return nRecBB0

/*/{Protheus.doc} PLSRETLDP
Retorna o local de digitacao
@type function
@author Tulio Cesar
@since 17.07.08
@version 1.0
/*/
function PLSRETLDP(nLoc)
	local cCodLdp := "0000"

	do case

		// inclusao manual. nao esta sendo mais utilizado  "MV_PLSLDPAD"
		case nLoc == 1

			cCodLdp := getNewPar("MV_PLSLDPAD","0001")

			// importacao xml tiss. nao esta sendo mais utilizado  "MV_PLSXMLP"
		case nLoc == 2

			cCodLdp := getNewPar("MV_PLSXMLP","0002")

			// importacao txt - movimentacao
		case nLoc == 3

			cCodLdp := getNewPar("MV_PLSTXTP","0003")

			// Digitação Offline
		case nLoc == 4

			cCodLdp := getNewPar("MV_PLSDIGP","8000")

			//Inclusao de guias
		case nLoc == 5

			cCodLdp := getNewPar("MV_PLSPEGE","0000")

			//Liberacao
		case nLoc == 6

			cCodLdp := GetNewPar("MV_PLSLLIB","9999")

			// Reembolso
		case nLoc == 7

			cCodLdp := getNewPar("MV_PLSPREM","9000")

			// local Generico
		case nLoc == 9

			cCodLdp := "9999"

	endCase

return(cCodLdp)

/*/{Protheus.doc} PLSDELMOV
Delete registro de movimento de um peg contas e atendimento
@type function
@author Tulio Cesar
@since 17.07.08
@version 1.0
/*/
function PLSDELMOV(cChave,cFase,lTudoOk,cTpGuEx)
	local lRet  := .f.
	local lEntrou := .f.
	local aArea := getArea()
	local cGuiInt := ''
	local cTpFat := ''
	local aUndBd7 := {}
	local nforY := 1
	local lPLSUNHMS   := existBlock('PLSUNHMS')
	default cTpGuEx   := ""
	default lTudoOk   :=	.t.

	//deleta bea,be2 e beg
	BCI->(dbSetOrder(1))//BCI_FILIAL + BCI_CODOPE + BCI_CODLDP + BCI_CODPEG + BCI_FASE + BCI_SITUAC
	if BCI->(msSeek(xFilial("BCI")+cChave)) .and. empty(BCI->BCI_PROCES)

		//atualiza status do peg
		PLSM190Pro(,,,,,,,,,,,.f.,.t.,BCI->(recno()))

		//verifica se esta em digitacao
		if BCI->BCI_FASE $ cFase

			lRet := .t.

			begin transaction

				BEA->(dbSetOrder(12))//BEA_FILIAL + BEA_OPEMOV + BEA_CODLDP + BEA_CODPEG + BEA_NUMGUI + BEA_ORIMOV
				if BEA->(msSeek(xFilial("BEA")+cChave))

					while BEA->(msSeek(xFilial("BEA")+cChave))

						//deleta be2
						BE2->(dbSetOrder(1))//BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT + BE2_SEQUEN
						if BE2->(msSeek(xFilial("BE2")+BEA->(BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT)))

							while BE2->(msSeek(xFilial("BE2")+BEA->(BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT)))

								//deleta beg
								BEG->(dbSetOrder(1))//BEG_FILIAL + BEG_OPEMOV + BEG_ANOAUT + BEG_MESAUT + BEG_NUMAUT + BEG_SEQUEN
								if BEG->(msSeek(xFilial("BEG")+BE2->(BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT)))

									while BEG->(msSeek(xFilial("BEG")+BE2->(BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT)))
										BEG->( recLock("BEG",.f.) )
										BEG->(dbDelete())
										BEG->( msUnLock() )
									endDo

								endIf
								//deleta be2
								BE2->( recLock("BE2",.f.) )
								BE2->(dbDelete())
								BE2->( msUnLock() )
							endDo
						endIf
						//deleta bea
						BEA->( recLock("BEA",.f.) )
						BEA->(dbDelete())
						BEA->( msUnLock() )
					endDo
				endIf

				//deleta be4,bej e bel
				BE4->(dbSetOrder(1))//BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
				if BE4->(msSeek(xFilial("BE4")+cChave))

					cGuiInt := BE4->BE4_GUIINT

					while BE4->(msSeek(xFilial("BE4")+cChave))

						//deleta bej
						BEJ->(dbSetOrder(1))//BEJ_FILIAL + BEJ_CODOPE + BEJ_ANOINT + BEJ_MESINT + BEJ_NUMINT + BEJ_SEQUEN
						if BEJ->(msSeek(xFilial("BEJ")+BE4->(BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT)))

							while BEJ->(msSeek(xFilial("BEJ")+BE4->(BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT)))

								//deleta bel
								BEL->(dbSetOrder(1))//BEL_FILIAL + BEL_CODOPE + BEL_ANOINT + BEL_MESINT + BEL_NUMINT + BEL_SEQUEN
								if BEL->(msSeek(xFilial("BEL")+BEJ->(BEJ_FILIAL + BEJ_CODOPE + BEJ_ANOINT + BEJ_MESINT + BEJ_NUMINT)))

									while BEL->(msSeek(xFilial("BEL")+BEJ->(BEJ_FILIAL + BEJ_CODOPE + BEJ_ANOINT + BEJ_MESINT + BEJ_NUMINT)))
										BEL->( recLock("BEL",.f.) )
										BEL->(dbDelete())
										BEL->( msUnLock() )
									endDo

								endIf

								//deleta bej
								BEJ->( recLock("BEJ",.f.) )
								BEJ->(dbDelete())
								BEJ->( msUnLock() )
							endDo

						endIf

						//deleta bqv, bqz
						BQV->(dbSetOrder(1))//BQV_FILIAL + BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT + BQV_SEQUEN
						if BQV->(msSeek(xFilial("BQV")+BE4->(BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT)))

							while BQV->(msSeek(xFilial("BQV")+BE4->(BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT)))

								//deleta bqz
								BQZ->(dbSetOrder(1))//BQZ_FILIAL + BQZ_CODOPE + BQZ_ANOINT + BQZ_MESINT + BQZ_NUMINT + BQZ_SEQUEN
								if BQZ->(msSeek(xFilial("BQZ")+BQV->(BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT + BQV_SEQUEN)))

									while BQZ->(msSeek(xFilial("BQZ")+BQV->(BQV_CODOPE + BQV_ANOINT + BQV_MESINT + BQV_NUMINT + BQV_SEQUEN)))
										BQZ->( recLock("BQZ",.f.) )
										BQZ->(dbDelete())
										BQZ->( msUnLock() )
									endDo

								endIf

								//deleta bqv
								BQV->( recLock("BQV",.f.) )
								BQV->(dbDelete())
								BQV->( msUnLock() )

							endDo

						endIf

						//deleta be4
						cTpFat := BE4->BE4_TIPFAT

						BE4->( recLock("BE4",.f.) )
						BE4->(dbDelete())
						BE4->( msUnLock() )
					endDo

					//limpa as informacoes de alta na solicitacao da internacao
					lExiste := .f.

					cSql := " SELECT BE4_GUIINT FROM " + RetSqlName("BE4")
					cSql += " WHERE BE4_FILIAL = '"+xFilial("BE4")+"' "
					cSql += " AND BE4_GUIINT = '"+cGuiInt+"' "
					cSql += " AND D_E_L_E_T_ <> '*' "

					PlsQuery(cSql,'TrbS1')

					if !TrbS1->(eof())
						lExiste := .t.
					endIf

					TrbS1->(dbCloseArea())

					BE4->(dbSetOrder(1))//BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE

				endIf

				//deleta bd7
				BD7->(dbSetOrder(1))//BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN + BD7_CODUNM + BD7_NLANC
				if BD7->(msSeek(xFilial("BD7")+cChave))

					while BD7->(msSeek(xFilial("BD7")+cChave))

						if (nO := aScan(aUndBd7,{|x| allTrim(x[1]) == allTrim(BD7->(BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO))  })) > 0
							aadd(aUndBd7[nO][2],BD7->BD7_CODUNM)
						else
							aadd(aUndBd7,{BD7->(BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO),{BD7->BD7_CODUNM}})
						endIf
						BD7->( recLock("BD7",.f.) )
						BD7->(dbDelete())
						BD7->( msUnLock() )
					endDo

				endIf

				//deleta bd5
				aRecBE2 := {}
				BD5->(dbSetOrder(1))//BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_SITUAC + BD5_FASE + dtos(BD5_DATPRO) + BD5_OPERDA + BD5_CODRDA
				if BD5->(msSeek(xFilial("BD5")+cChave))

					while BD5->(msSeek(xFilial("BD5")+cChave))
						nRecBD5 := BD5->(recno())
						nOrdBD5	:= BD5->(indexOrd())

						//ainda nao trato saldo para honorario individual, so SPSDAT - daher 23/04/2013
						if ! empty(BD5->BD5_NRLBOR) .and. BD5->BD5_TIPGUI $ "02/13"

							// Se e uma excluao de autorizacao baseada em uma liberacao refaz saldo
							BD6->(dbSetOrder(1))
							if BD6->(msSeek(xFilial("BD6")+cChave+BD5->BD5_NUMERO))

								while !BD6->(eof()) .and. xFilial("BD6")+cChave+BD5->BD5_NUMERO == BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)
									// Atualizo saldo de uma liberacao
									// Aqui tem a seguinte regra se um evento tem HM e neste BD6 que eu acabei
									// de criar nao existe o HM, eu nao atualizo o saldo.. o saldo sempre eh abatido
									// quando se faz o honorario medico, pois podem ter 3 bd6 referentes a um mesmo
									// evento e eu so tenho que abater o saldo 1 vez senao fica com saldo negativo
									lAtuSaldo 	:= .f.
									aCompo 		:= PLSCOMEVE(BD6->BD6_CODTAB,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODOPE,BD6->BD6_DATPRO)

									if len(aUndBd7) > 0

										nO := aScan(aUndBd7,{|x| allTrim(x[1]) == allTrim(BD6->(BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO))  })

										cUndHM := "HM,HMR,PPM,RCC,CIR"
										if lPLSUNHMS
											cUndHM := execBlock( 'PLSUNHMS',.f.,.f.,{cUndHM} )
										endIf

										if aScan(aCompo,{|x| allTrim(x[1]) $ cUndHM }) > 0 .and. nO > 0//verifica se tem honorario no evento
											for nforY := 1 to len(aUndBd7[nO][2])
												if allTrim(aUndBd7[nO][2][nforY]) $ cUndHM // no evento que eu acabei de criar tem o honorario
													lAtuSaldo := .t.
													exit
												endIf
											next
										else
											lAtuSaldo := .t.
										endIf

										if !lAtuSaldo
											BD6->(dbSkip())
											loop
										endIf
									endIf

									// Seleciona todos os registros da execucao que esta sendo deletada
									cSQL := "SELECT BE2_SEQUEN, BE2_CODPAD, BE2_CODPRO, BE2_QTDPRO, BE2_SALDO, R_E_C_N_O_ FROM " + BE2->( RetSQLName("BE2") )
									cSQL += " WHERE BE2_FILIAL = '" + xFilial('BE2')				+"' "
									cSQL += " 	AND BE2_OPEMOV = '" + Subs(BD5->BD5_NRLBOR,1,4)		+"' "
									cSQL += " 	AND BE2_ANOAUT = '" + Subs(BD5->BD5_NRLBOR,5,4)		+"' "
									cSQL += " 	AND BE2_MESAUT = '" + Subs(BD5->BD5_NRLBOR,9,2)		+"' "
									cSQL += " 	AND BE2_NUMAUT = '" + Subs(BD5->BD5_NRLBOR,11,8)	+"' "
									cSQL += " 	AND BE2_CODPAD = '" + BD6->BD6_CODPAD				+"' "
									cSQL += " 	AND BE2_CODPRO = '" + BD6->BD6_CODPRO				+"' "
									cSQL += " 	AND BE2_STATUS = '1' AND BE2_LIBERA = '1' "
									cSQL += " 	AND D_E_L_E_T_ = ' '"

									dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"TrbBE2",.f.,.t.)

									// while nos itens da execucao
									while !TrbBE2->( eof() )
										//aqui eu garanto que um mesmo be2 nunca vai ser reprocessado
										//aqui eu garanto que se ele ainda tem saldo para abeter
										if aScan(aRecBE2,{|x| x == TrbBE2->R_E_C_N_O_}) <> 0 .and. TrbBE2->BE2_SALDO == 0
											TrbBE2->(dbSkip())
											loop
										endIf

										aadd(aRecBE2,TrbBE2->R_E_C_N_O_)
										// Quantidade do procedimento na execucao
										nQtdPro := BD6->BD6_QTDPRO
										cSequen := TrbBE2->BE2_SEQUEN
										PLSATUSS( nil ,.f.,nil,nil,"1",.f.,BD5->BD5_NRLBOR + cSequen,6,nil,nil,1,nQtdPro )
										lEntrou := .t.

										TrbBE2->( dbSkip() )
									endDo

									TrbBE2->( dbCloseArea() )

									BD6->(dbSkip())
								endDo
							endIf
							if PLSSALDO(BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV),BD5->BD5_NRLBOR)
								BEA->(dbSetOrder(1))
								if BEA->(msSeek(xFilial("BEA")+BD5->BD5_NRLBOR))
									PLSATUCS('1')
								endIf
							endIf
						endIf
						BD5->(dbGoto(nRecBD5))
						BD5->(dbSetOrder(nOrdBD5))

						BD5->( recLock("BD5",.f.) )
						BD5->(dbDelete())
						BD5->( msUnLock() )
					endDo

				endIf

				//deleta bd6
				BD6->(dbSetOrder(1))//BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO
				if BD6->(msSeek(xFilial("BD6")+cChave))

					while BD6->(msSeek(xFilial("BD6")+cChave))
						BD6->( recLock("BD6",.f.) )
						BD6->(dbDelete())
						BD6->( msUnLock() )
					endDo

				endIf

				//deleta B43
				B43->(dbSetOrder(1))//B43_FILIAL+B43_CODOPE+B43_CODLDP+B43_CODPEG+B43_NUMERO+B43_ORIMOV+B43_SEQUEN
				if B43->(msSeek(xFilial("B43")+cChave))

					while B43->(msSeek(xFilial("B43")+cChave))
						B43->( recLock("B43",.f.) )
						B43->(dbDelete())
						B43->( msUnLock() )
					endDo

				endIf

				if lTudoOk
					BCI->( recLock("BCI",.f.) )
					BCI->(dbDelete())
					BCI->( msUnLock() )
				endIf

				if	!lTudoOk .and. PLSALIASEX("B0Y")

					if cTpGuEx $ "03"
						cCampo := "BE4_NUMERO"
					else
						cCampo := "BD5_NUMERO"
					endIf

					DBSelectArea("B0Y")
					B0Y->( dbSetOrder(1) )  //B0Y_FILIAL + B0Y_CAMPO + B0Y_CHAVE
					if B0Y->( msSeek( xFilial("B0Y")+cCampo+cChave ) )
						B0Y->( recLock("B0Y",.f.) )
						B0Y->(dbDelete())
						B0Y->( msUnLock() )
					endIf

				endIf

			end transaction
		endIf
	endIf

	restArea(aArea)

return(lret)

/*/{Protheus.doc} PLSATUPEG
Atualiza status do PEG
@type function
@author Tulio Cesar
@since 17.07.08
@version 1.0
/*/
function PLSATUPEG(cOpeOri,cLdpOri,cPegOri,cGuiOri,cOpeDes,cLdpDes,cPegDes,cAliCab,lTrangui)
	local aArea 	:= getArea()
	local nI		:= 0
	local cSql		:= ""
	local cNumGuia	:= ""
	local lErro		:= .f.
	local lMudComp	:= .t.
	local aAlias	:= {}
	local aIndices  := {}
	local nInd      := 0
	local lPLMDCPTR := existBlock("PLMDCPTR")
	default cAliCab := ""
	default lTrangui := .F.
	//alias tratados
	aadd(aAlias,"BD5") ; aadd(aIndices,1)
	aadd(aAlias,"BD7") ; aadd(aIndices,1)
	aadd(aAlias,"BD6") ; aadd(aIndices,1)
	aadd(aAlias,"BDX") ; aadd(aIndices,1)
	aadd(aAlias,"BEA") ; aadd(aIndices,12)
	aadd(aAlias,"BE2") ; aadd(aIndices,13)
	aadd(aAlias,"BE4") ; aadd(aIndices,13)
	aadd(aAlias,"BX6") ; aadd(aIndices,1)
	aadd(aAlias,"BYT") ; aadd(aIndices,1)

	if ! empty(cAliCab)

		cNumGuia := PLSA500NUM(cAliCab, cOpeDes, cLdpDes, cPegDes)

	endIf

	cAno := BCI->BCI_ANO
	cMes := BCI->BCI_MES

	//monta update da bd7
	for nI := 1 to len(aAlias)

		cAlias 	:= aAlias[nI]
		nInd    := aIndices[nI]
		lErro 	:= .f.

		//verifica se o alias não esta disponivel (exemplo nova funcionalidade que não esta no ambiente do cliente)
		if ! PLSALIASEX(cAlias)
			loop
		endIf

		// Se nao tem registro para a chave ignora
		DbSelectArea(cAlias)
		dbSetOrder(nInd)
		if ! msSeek(xFilial(cAlias)+cOpeOri+cLdpOri+cPegOri)
			loop
		endIf

		//select
		cSql := " SELECT R_E_C_N_O_ REC "
		cSql += "   FROM "+retSQLName(cAlias)
		cSql += "  WHERE "+cAlias+"_FILIAL = '"+xFilial(cAlias)+"' "

		//verifica se e codope ou opemov
		if (cAlias)->( fieldPos(cAlias+"_CODOPE") ) > 0

			cSql += "    AND "+cAlias+"_CODOPE = '"+cOpeOri+"' "

		elseIf (cAlias)->( fieldPos(cAlias+"_OPEMOV") ) > 0

			cSql += "    AND "+cAlias+"_OPEMOV = '"+cOpeOri+"' "

		else
			lErro := .t.
		endIf

		if (cAlias)->( fieldPos(cAlias+"_CODLDP") ) > 0
			cSql += "    AND "+cAlias+"_CODLDP = '"+cLdpOri+"' "
		endIf

		if (cAlias)->( fieldPos(cAlias+"_CODPEG") ) > 0
			cSql += "    AND "+cAlias+"_CODPEG = '"+cPegOri+"' "
		endIf

		//verifica se e numero ou numgui
		if (cAlias)->( fieldPos(cAlias+"_NUMERO") ) > 0
			cSql += "    AND "+cAlias+"_NUMERO = '"+cGuiOri+"' "
		elseIf (cAlias)->( fieldPos(cAlias+"_NUMGUI") ) > 0
			cSql += "    AND "+cAlias+"_NUMGUI = '"+cGuiOri+"' "
		else
			lErro := .t.
		endIf

		cSql += "    AND D_E_L_E_T_ = ' ' "

		//se nao tem erro
		if !lErro

			//abre a area
			PlsQuery(cSql,"PLSATUPEG")

			while ! PLSATUPEG->(eof())

				//posiciona no registro
				(cAlias)->(dbGoto(PLSATUPEG->REC))

				if !(cAlias)->(eof())

					(cAlias)->(recLock(cAlias,.f.))

					(cAlias)->&(cAlias+"_CODOPE") := cOpeDes
					(cAlias)->&(cAlias+"_CODLDP") := cLdpDes
					(cAlias)->&(cAlias+"_CODPEG") := cPegDes

					if lPLMDCPTR
						lMudComp := execBlock("PLMDCPTR",.f.,.f.)
					endIf

					// nao tirar esse fieldpos pois ele não existe em todas as tabelas que podem chegar no cAlias
					if lMudComp .and. (cAlias)->( fieldPos(cAlias+"_MESPAG") ) > 0 .and. (cAlias)->( fieldPos(cAlias+"_ANOPAG") ) > 0
						(cAlias)->&(cAlias+"_MESPAG") := cMes
						(cAlias)->&(cAlias+"_ANOPAG") := cAno
					endIf

					if ! empty(cNumGuia)

						if (cAlias)->( fieldPos(cAlias+"_NUMERO") ) > 0
							(cAlias)->&(cAlias+"_NUMERO") := cNumGuia
						elseIf (cAlias)->( fieldPos(cAlias+"_NUMGUI") ) > 0
							(cAlias)->&(cAlias+"_NUMGUI") := cNumGuia
						endIf

					endIf

					If lTrangui
						if (cAlias)->( fieldPos(cAlias+"_DTDIGI") ) > 0
							(cAlias)->&(cAlias+"_DTDIGI") := MsDate()
						Endif

						if (cAlias)->( fieldPos(cAlias+"_DTCTBF") ) > 0
							(cAlias)->&(cAlias+"_DTCTBF") := MsDate()
						endIf
					endIf

					(cAlias)->(msUnLock())

				endIf

				PLSATUPEG->(dbSkip())

			endDo

			PLSATUPEG->(dbCloseArea())
		endIf

	next

	restArea(aArea)

return(nil)

/*/{Protheus.doc} PCrB7Gen
Cria um BD7 para casos onde a unidade de medida nao foi localizada de acordo com
a participacao enviada no arquivo
@type function
@author TOTVS
@since 28.01.13
@version 1.0
/*/
function PCrB7Gen(cCodUnm,aTpPar,nVlrApr)
	local cProBD7Ori := ""
	local cCodEsp	 := ""
	local cCodInt	 := PLSINTPAD()
	default aTpPar := {}
	default nVlrApr:=0
	BR8->(dbSetOrder(1))
	BR8->(msSeek(xFilial("BR8")+BD6->(BD6_CODPAD+BD6_CODPRO)))
	BAU->(dbSetOrder(1))
	BAU->(msSeek(xFilial("BAU")+BD6->BD6_CODRDA))

	BD7->(RecLock("BD7",.t.))
	BD7->BD7_FILIAL := xFilial("BD7")
	BD7->BD7_CODOPE := BD6->BD6_CODOPE
	BD7->BD7_CODLDP := BD6->BD6_CODLDP
	BD7->BD7_CODPEG := BD6->BD6_CODPEG
	BD7->BD7_NUMERO := BD6->BD6_NUMERO
	BD7->BD7_SEQUEN := BD6->BD6_SEQUEN
	BD7->BD7_CODUNM := cCodUnm
	BD7->BD7_CODPRO := BD6->BD6_CODPRO
	BD7->BD7_CODPAD := BD6->BD6_CODPAD
	BD7->BD7_LIBERA := BD6->BD6_LIBERA
	BD7->BD7_CC     := BD6->BD6_CC
	BD7->BD7_NUMIMP := BD6->BD6_NUMIMP
	BD7->BD7_NLANC  := ""
	BD7->BD7_ORIMOV := BD6->BD6_ORIMOV
	BD7->BD7_FASE   := BD6->BD6_FASE
	BD7->BD7_SITUAC := BD6->BD6_SITUAC

	BD7->BD7_MODCOB := BD6->BD6_MODCOB
	BD7->BD7_TIPUSR := BD6->BD6_TIPUSR
	BD7->BD7_INTERC := BD6->BD6_INTERC
	BD7->BD7_TIPINT := BD6->BD6_TIPINT

	BD7->BD7_LOTGUI := BD6->BD6_LOTGUI
	BD7->BD7_CLAINS := PLSCLAINS() //Considera o BD6 posicionado!!!
	BD7->BD7_NOMUSR := BD6->BD6_NOMUSR
	BD7->BD7_SEQIMP := BD6->BD6_SEQIMP

	if empty(BD7->BD7_PROBD7)
		cProBD7Ori      := "0"
		BD7->BD7_PROBD7 := "1"
	else
		cProBD7Ori := BD7->BD7_PROBD7
	endIf

	BD7->BD7_TIPGUI := BD6->BD6_TIPGUI
	BD7->BD7_CID    := BD6->BD6_CID
	BD7->BD7_OPEUSR := BD6->BD6_OPEUSR
	BD7->BD7_CODESP := BD6->BD6_CODESP
	BD7->BD7_DESESP := BAQ->(Posicione("BAQ",1,xFilial("BAQ")+BD6->(BD6_OPERDA+BD6_CODESP),"BAQ_DESCRI"))
	BD7->BD7_TIPREG := BD6->BD6_TIPREG
	BD7->BD7_MATRIC := BD6->BD6_MATRIC
	BD7->BD7_CODEMP := BD6->BD6_CODEMP
	BD7->BD7_CONMFT := BR8->BR8_CONMFT
	BD7->BD7_PROCCI := if(BR8->BR8_TIPEVE$"2,3","1","0")
	BD7->BD7_CONEMP := BD6->BD6_CONEMP
	BD7->BD7_SUBCON := BD6->BD6_SUBCON
	BD7->BD7_VERSUB := BD6->BD6_VERSUB
	BD7->BD7_VERCON := BD6->BD6_VERCON
	BD7->BD7_FASE   := BD6->BD6_FASE
	BD7->BD7_SITUAC := BD6->BD6_SITUAC
	BD7->BD7_TPGRV  := BD6->BD6_TPGRV
	BD7->BD7_CODPLA := BD6->BD6_CODPLA
	BD7->BD7_ANOPAG := BD6->BD6_ANOPAG
	BD7->BD7_TIPRDA := BD6->BD6_TIPRDA
	BD7->BD7_MESPAG := BD6->BD6_MESPAG
	BD7->BD7_DATPRO := BD6->BD6_DATPRO
	BD7->BD7_CONMFT := BR8->BR8_CONMFT
	BD7->BD7_CODRDA := BAU->BAU_CODIGO
	BD7->BD7_LOCATE := BD6->(BD6_CODLOC+BD6_LOCAL)
	BD7->BD7_CODLOC := BD6->BD6_CODLOC
	BD7->BD7_LOCAL  := BD6->BD6_LOCAL
	BD7->BD7_DATPRO := BD6->BD6_DATPRO
	BD7->BD7_DESLOC := BD1->(Posicione("BD1",1,xFilial("BD1")+BD6->(BD6_CODOPE+BD6_CODLOC+BD6_LOCAL),"BD1_DESLOC"))
	BD7->BD7_DTDIGI := BD6->BD6_DTDIGI

	if cProBD7Ori <> "1"
		BD7->BD7_NOMRDA := BAU->BAU_NOME
	endIf

	if (len(aTpPar) > 0 .and. !empty(aTpPar[1,5]))
		BD7->BD7_SIGLA  := aTpPar[1,5]
		BD7->BD7_REGPRE := aTpPar[1,6]
		BD7->BD7_ESTPRE := aTpPar[1,7]
		BD7->BD7_NOMPRE := BB0->( Posicione("BB0",4,xFilial("BB0")+BD7->(BD7_ESTPRE+BD7_REGPRE+BD7_SIGLA),"BB0_NOME") )
		BD7->BD7_CDPFPR := BB0->BB0_CODIGO
	elseif !empty(BD6->BD6_CDPFRE)
		BD7->BD7_REGPRE := BD6->BD6_REGEXE
		BD7->BD7_SIGLA  := BD6->BD6_SIGEXE
		BD7->BD7_ESTPRE := BD6->BD6_ESTEXE
		BD7->BD7_NOMPRE := BR8->( Posicione("BB0",1,xFilial("BB0")+BD6->BD6_CDPFRE,"BB0_NOME") )
		BD7->BD7_CDPFPR := BD6->BD6_CDPFRE
	endIf

	aRetEspec := PLSGTESPP(BD7->BD7_CODRDA)

	if empty(BD6->BD6_CODESP)
		cCodEsp := aRetEspec[1]
	else
		cCodEsp := BD6->BD6_CODESP
	endIf

	BD7->BD7_CODESP := cCodEsp
	BD7->BD7_DESESP := BAQ->(Posicione("BAQ",1,xFilial("BAQ")+cCodInt+cCodEsp,"BAQ_DESCRI"))

	if len(aTpPar) > 0 //Gravando a participação que esta vindo do XML
		BD7->BD7_CODTPA := aTpPar[1,1]
		If aTpPar[1,1] $ "01,02,03,04" .AND. getNewPar("MV_PLCAAUX","1") == "3"
			BD7->BD7_NLANC  := StrZero( Val(aTpPar[1,1]), 2)
		endIf
	endIf

	// Determina que mesmo for tipo de participação 'UNL' devemos Apresentar o Valor de Glosa para analise no Contas Medicas
	if  getNewPar("MV_PLTPUNL",.f.)
		BD7->BD7_VLRAPR := nVlrApr
	endIf

	BD7->(msUnLock())

return

/*/{Protheus.doc} PlRetCidGe
Retorna um codigo de cid Generico
@type function
@author Daher
@since 03.07.05
@version 1.0
/*/
static function xRetCidGe()
	local cCodCid := getNewPar("MV_PLCDGEN","00000000")

	BA9->(dbSetOrder(1))
	if !BA9->(msSeek(xFilial("BA9")+cCodCid))
		BA9->(RecLock("BA9",.t.))
		BA9->BA9_CODDOE := cCodCid
		BA9->BA9_DOENCA := "CID GENERICO PARA USO NO XML IMPORTACAO"
		BA9->BA9_ABREVI := "CID GENERICO"
		BA9->(msUnLock())
	endIf

return cCodCid

/*/{Protheus.doc} PLBLD6D7
Bloqueio do BD6 e BD7
@type function
@author TOTVS
@since 17.07.08
@version 1.0
/*/
function XPLBLD6D7(cChave,cCodCri,cDesCri)
	local lBloq := .t.

	if BD7->( indexOrd() ) <> 1
		BD7->( dbSetOrder(1) ) //BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN + BD7_CODUNM + BD7_NLANC
	endIf

	if BD7->( msSeek( xFilial("BD7")+cChave ) )

		while !BD7->( eof() ) .and. xFilial("BD7")+cChave == BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

			if allTrim(BD7->BD7_CODTPA) <> ''
				lBloq := .f.
				Exit
			endIf

			if lBloq
				BD7->( RecLock("BD7",.f.) )
				PLBLOPC("BD7", .t., cCodCri, cDesCri)
				BD7->( msUnLock() )
			endIf

			BD7->( dbSkip() )
		endDo

	endIf
	// Bloqueio de pagamento e cobranca para itens nao encontrados
	if lBloq

		BD6->( RecLock("BD6",.f.) )
		PLBLOPC("BD6", .t., cCodCri, cDesCri, .t., .t., .t.)
		BD6->( msUnLock() )

	endIf
	// Log do procedimento bloqueado
	PlsLogFil(space(03)+"PROCEDIMENTO [ "+BD6->BD6_CODPAD+" - "+allTrim(BD6->BD6_CODPRO)+" ] BLOQUEADO NA CONTA MEDICA" ,__PLSFLOGX)

return

/*/{Protheus.doc} PXMOVTISS
Atualiza os dados dos vetores de aDados e aItens do XMOV
com os valores das terminologias TISS
@type function
@author Rogerio Tabosa
@since 20.01.14
@version 1.0
/*/
function PXMOVTISS(aDados, aItens, aCpoTermo)
	local nI 		:= 0 // Variavel de contador
	local nJ 		:= 0 // Variavel de contador
	local nP 		:= 0 // Variavel de posição do array
	local cVarVinc	:= "" // Guardo valor retornado do vinculo
	local cSlvPad	:= "" // Guardo valor retornado do vinculo

	//Array com os campos do XMOV e a tabela correspondente
	default aCpoTermo := {	{ "TIPSAI", "39", "BEA"},; //Tipo de Saida
		{ "TIPATE", "50", ""   },; //Tipo de atendimento
		{ "TIPFAT", "55", ""   },; //Tipo de faturamento
		{ "INDACI", "36", "BEA"},; //Indicador de acidente
		{ "CARSOL", "23", "BDR"   },; //Carater da solicitaçao//
		{ "TIPCON", "52", ""   },; //Tipo de consulta
		{ "AUNMED", "60", ""   },; //Unidade de medida
		{ "CODPAD", "87", "BR4"},; //Tabela padrao
		{ "CODPRO", "",   "BR8"},; //procedimento
		{ "TECUT" , "48", ""   },; //Tecnica utilizada
		{ "CODESP", "24", "BAQ"}}  //Tecnica utilizada
	private aErrVarVin := {.f., "", "", ""}

	// BUSCO OS CAMPOS NO ADADOS E ATUALIZO ELES COM PLSVARVINC
	if len(aCpoTermo) > 0

		for nI := 1 to len(aCpoTermo)

			if (nP:= aScan( aDados,{|x| x[1] == aCpoTermo[nI,1] } )) > 0 // Busco no aDados

				cVarVinc := PLSVARVINC(aCpoTermo[nI,2], iIf(!empty(aCpoTermo[nI,3]),aCpoTermo[nI,3],"") , aDados[nP,2])

				if ! empty(cVarVinc)
					aDados[nP,2] := cVarVinc
				endIf

			endIf

		next nI

	endIf

	for nJ := 1 To len(aItens)

		if len(aCpoTermo) > 0

			for nI := 1 to len(aCpoTermo)

				if (nP := aScan( aItens[nJ],{|x| x[1] == aCpoTermo[nI,1] } )) > 0 // Busco no aDados

					if aItens[nJ,nP,1] == "CODPAD"
						cSlvPad := PLSRETDAD( aItens[nJ],"CODPAD",.f. )
					endIf

					if aItens[nJ,nP,1] == "CODPRO"

						if empty(cSlvPad)
							cSlvPad := PLSRETDAD( aItens[nJ],"CODPAD",.f. )
						endIf

						cVarVinc := PLSVARVINC(cSlvPad, iIf(!empty(aCpoTermo[nI,3]),aCpoTermo[nI,3],"") , aItens[nJ,nP,2])

						if !empty(cVarVinc)
							aItens[nJ,nP,2] := cVarVinc
						endIf

					else

						cVarVinc := PLSVARVINC(aCpoTermo[nI,2], iIf(!empty(aCpoTermo[nI,3]),aCpoTermo[nI,3],"") , aItens[nJ,nP,2])

						if ! empty(cVarVinc)
							aItens[nJ,nP,2] := cVarVinc
						endIf

					endIf

				endIf

			next nI

		endIf

	next nJ

return()

/*/{Protheus.doc} VPerConPTU
Verifica periodicidade para atendimento de intercambio Portal
@type function
@author TOTVS
@since 12.03.14
@version 1.0
/*/
static function VPerConPTU(aDados,aItens,aDadRDA,aDadUsr,aDadIte,aCriticas,aEventosNeg)
	local nfor      := 0
	local aRetFun   := {}
	local aTrb      := {}
	local cLibEsp   := "0"
	local cAuditoria:= "0"
	local lContinua := .f.
	local cMatrUsr  := PLSRETDAD(aDados,"USUARIO")
	local dData     := PLSRETDAD(aDados,"DATPRO")
	local cHora     := PLSRETDAD(aDados,"HORAPRO")
	local cCid      := PLSRETDAD(aDados,"CIDPRI","")
	local cCodPad	:= PLSRETDAD(aItens[1],"CODPAD")
	local cCodPro   := PLSRETDAD(aItens[1],"CODPRO")
	local cSeqMov   := PLSRETDAD(aItens[1],"SEQMOV")
	local nQtdSol   := PLSRETDAD(aItens[1],"QTD",0)
	local cOrigem   := PLSRETDAD( aDados,"ORIGEM","1" )
	local cNumImp   := PLSRETDAD( aDados,"NUMIMP","" )
	local nQtdAut   := PLSRETDAD(aItens[1],"QTDAUT",0)
	local cDescri	:= PLSRETDAD(aItens[1],"DESCRI","")
	local cSlvPad	:= PLSRETDAD(aItens[1],"SLVPAD","")
	local cSlvPro	:= PLSRETDAD(aItens[1],"SLVPRO","")

	aRetFun := PLSTratPer(	cMatrUsr,dData,cHora,cCodPad,cCodPro,nQtdSol,nil, nil,"1",aDadRDA,nil,;
		cCid,.t.,"1"/*cNivel*/,aDadUsr,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,cSeqMov ,nil)

	lContinua := aRetFun[1]
	if !lContinua .And. len(aRetFun) > 1
		aTrb 	  := aRetFun[2]
	endIf

	if !lContinua
		for nfor := 1 to len(aTrb)
			aadd( aCriticas,{cSeqMov,aTrb[nfor,1],allTrim(aTrb[nfor,2])+iIf(len(aTrb[nfor])>=3 .and. !empty(aTrb[nfor,3]),' ( '+aTrb[nfor,3]+' ) ',''),aTrb[nfor,6],aTrb[nfor,7],"",""} )
		next
		// Matriz
		PLSDADITE(aDadIte,aItens[1],cOrigem,cLibEsp,cAuditoria,cNumImp,,dData,aDadRda)
		aadd(aEventosNeg,{cSeqMov,cCodPad,cCodPro,nQtdSol,cDescri,nQtdAut,"","","",cSlvPad,cSlvPro})
	endIf

return(lContinua)

/*/{Protheus.doc} criMatPT17
Critica itens da solicitacao pois a matricula do usuario de
intercambio nao tem 17 caracteres
@type function
@author TOTVS
@since 28.05.14
@version 1.0
/*/
static function criMatPT17(aDados,aItens,aDadRDA,aDadUsr,aDadIte,aCriticas,aEventosNeg,clocalExec)
	local nfor 			:= 0
	local nX   			:= 0
	local bRetErrPTU  	:= { |cNivCri,cChaveAut| {.f.,aCodCri,cNivCri,cChaveAut} }
	local dData			:= ctod("")
	local cHora			:= ""
	local cCid			:= ""
	local cCdTbPd		:= ""
	local cCodPro		:= ""
	local cSeqMov		:= ""
	local cOrigem		:= ""
	local cNumImp		:= ""
	local nQtdAut		:= 0
	local cDescri		:= ""
	local aCodCri 		:= {}
	local aTrb    		:= {}
	local cLibEsp   	:= "0"
	local cAuditoria	:= "0"

	for nX := 1 to len(aItens)

		aCodCri   := {}
		dData     := PLSRETDAD(aDados,"DATPRO")
		cHora     := PLSRETDAD(aDados,"HORAPRO")
		cCid      := PLSRETDAD(aDados,"CIDPRI","")
		cCdTbPd   := PLSRETDAD(aItens[nX],"CODPAD")
		cCodPro   := PLSRETDAD(aItens[nX],"CODPRO")
		cSeqMov   := PLSRETDAD(aItens[nX],"SEQMOV")
		nQtdSol   := PLSRETDAD(aItens[nX],"QTD",0)
		cOrigem   := PLSRETDAD(aDados,"ORIGEM","1" )
		cNumImp   := PLSRETDAD(aDados,"NUMIMP","" )
		nQtdAut   := PLSRETDAD(aItens[nX],"QTDAUT",0)
		cDescri   := PLSRETDAD(aItens[nX],"DESCRI","")
		cSlvPad   := PLSRETDAD(aItens[nX],"SLVPAD","")
		cSlvPro   := PLSRETDAD(aItens[nX],"SLVPRO","")

		aadd(aCodCri,{__aCdCri210[1],PLSBCTDESC(),"",BCT->BCT_NIVEL,BCT->BCT_TIPO,cCdTbPd,cCodPro})

		// Alias e caminho da critica
		PLSCOMPCRI(aCodCri,"BA1")

		aTrb := {}
		aTrb := (eval(bRetErrPTU,"BA1",cCdTbPd + cCodPro))
		aTrb := aTrb[2]

		for nfor := 1 to len(aTrb)
			aadd( aCriticas,{cSeqMov,aTrb[nfor,1],allTrim(aTrb[nfor,2])+iIf(len(aTrb[nfor])>=3 .and. !empty(aTrb[nfor,3]),' ( '+aTrb[nfor,3]+' ) ',''),aTrb[nfor,6],aTrb[nfor,7],"",""} )
		next

		// Matriz
		PLSDADITE(aDadIte,aItens[nX],cOrigem,cLibEsp,cAuditoria,cNumImp,,dData,aDadRda)

		aadd(aEventosNeg,{cSeqMov,cCdTbPd,cCodPro,nQtdSol,cDescri,nQtdAut,"","","",cSlvPad,cSlvPro})

	next

return(.f.)

/*/{Protheus.doc} VBaixRisco
Verifica se todos os eventos da guia sao de baixo risco
@type function
@author TOTVS
@since 19.08.15
@version 1.0
/*/
static function VBaixRisco(aItens,lLog)
	local lRet     := .t.
	local nfor     := 0
	local nQtdIte  := 0
	local aAreaBR8 := BR8->(GetArea())
	local cCodPad  := ""
	local cCodPro  := ""
	local lExiQtdRis := BR8->(FieldPos("BR8_QTDRIS")) > 0
	local cPacoteGen := Alltrim(GetNewPar("MV_PLPACPT",""))
	local lPTUOn80	 := Alltrim(GetNewPar("MV_PTUVEON","80")) >= "80"
	local lTissDebug	:= IiF(GetNewPar("MV_PLTIDEB","1")=="1",.T.,.F.)
	default lLog   := .F.

	BR8->(dbSetOrder(1))//BR8_FILIAL + BR8_CODPAD + BR8_CODPSA + BR8_ANASIN
	// Verifica se todos os itens sao de baixo risco
	for nfor := 1 to len(aItens)

		cCodPad  := PLSRETDAD(aItens[nfor],"CODPAD")+space(TamSx3("BD6_CODPAD")[1] - len(PLSRETDAD(aItens[nfor],"CODPAD")))
		cCodPro  := PLSRETDAD(aItens[nfor],"CODPRO")+space(TamSx3("BD6_CODPRO")[1] - len(PLSRETDAD(aItens[nfor],"CODPRO")))
		nQtdIte  := PLSRETDAD(aItens[nfor],"QTD")

		If Alltrim(cCodPro) == cPacoteGen .And. lPTUOn80
			Loop
		EndIf

		if BR8->(msSeek(xFilial("BR8")+cCodPad+cCodPro)) .and. BR8->BR8_RISCO == "1"
			if lExiQtdRis .And. BR8->BR8_QTDRIS > 0 .And. (nQtdIte > BR8->BR8_QTDRIS)
				lRet := .f.
				Exit
			endIf
		else
			lRet := .f.
			Exit
		endIf

	next

	// Se itens de baixo risco, gero o log no console PTU Online
	if lRet .And. lLog

		for nfor := 1 to len(aItens)
			cCodPad  := PLSRETDAD(aItens[nfor],"CODPAD")+ space(TamSx3("BD6_CODPAD")[1] - len(PLSRETDAD(aItens[nfor],"CODPAD")))
			cCodPro  := PLSRETDAD(aItens[nfor],"CODPRO")+ space(TamSx3("BD6_CODPRO")[1] - len(PLSRETDAD(aItens[nfor],"CODPRO")))
			If lTissDebug
				PlsPtuLog(cCodPad+"-"+Alltrim(cCodPro)+" -> Evento de Baixo Risco.")
			Endif
		next

	endIf

	RestArea(aAreaBR8)

return lRet

/*/{Protheus.doc} RetDigGuia

Retorna variável lógica informando se a guia foi digitada posteriormente através do portal do prestador.
Essa verificação é feita através da variável private lDigiGuia, que é alimentada com a propriedade "DigitacaoGuia" do webservice WSPLSXMOV.
A propriedade do webservice é carregada com o valor HttpGet->cTipoOrigem enviado pela tela quando a guia é digitada posteriormente.

@author Rodrigo Morgon
@since 24/11/2015
@version P12
/*/
function RetDigGuia()
return (Type("lDigiGuia") <> "U" .and. lDigiGuia)


/*/{Protheus.doc} PLSBACKGUI

Muda fase da guia finalizada para digitação.

@author Rodrigo Morgon
@since 26/11/2015
@version P12
/*/
function PLSBACKGUI(crecnos, nTipoGuias)
	local aArea := GetArea()
	local lRet := .t.
	local aGuias := {}
	local nI := 1
	aGuias	:= Separa(crecnos, "|" , .f.)

	if len(aGuias) > 0
		for nI := 1 to len(aGuias)
			if (nTipoGuias == 3 .or. nTipoGuias == 5)
				//Se guia de internação
				DbSelectArea("BE4")
				BE4->(dbGoto(val(aGuias[nI])))

				//Posiciona na PEG relacionada à guia.
				DbSelectArea("BCI")
				BCI->(dbSetOrder(14))//BCI_FILIAL + BCI_CODPEG

				//Verifica se existe PEG na BCI e, caso positivo, realiza o retorno da fase da guia.
				lRet := BCI->(msSeek(xFilial("BCI")+allTrim(BE4->BE4_CODPEG))) .and. PLSA500RFS("BE4",aGuias[nI],6,,.f.,.t.)
			else
				//Se guia dos demais tipos
				DbSelectArea("BD5")
				BD5->(dbGoto(val(aGuias[nI])))

				//Posiciona na PEG relacionada à guia.
				DbSelectArea("BCI")
				BCI->(dbSetOrder(14))//BCI_FILIAL + BCI_CODPEG

				//Verifica se existe PEG na BCI e, caso positivo, realiza o retorno da fase da guia.
				lRet := BCI->(msSeek(xFilial("BCI")+allTrim(BD5->BD5_CODPEG))) .and. PLSA500RFS("BD5",aGuias[nI],6,,.f.,.t.)
			endIf
		next
	endIf

	RestArea(aArea)

return lRet

/*/{Protheus.doc} PlGrvEspXML
Gravacao das especialidades de arquivos XML

@type function
@author victor.silva
@since 12/04/2016
@version 1.0
/*/
function PlGrvEspXML(cAlias,aEspXML,aCompo,_cEspExe,_cCodEsp,aUndBD7)
	local nI 			:= 1
	local nBkpPri 	:= 0
	local nBkpRec 	:= 0
	local nPos			:= 0
	local nPosEsp 	:= 0
	local aPriori		:= {}
	local aEspUnic	:= {}

	default aCompo	:= {}
	default _cEspExe	:= ""
	default _cCodEsp	:= ""
	default aUndBD7		:= nil

	/*
Estrutura do aEspXML definido no PLSA973
[1] - Especialidade do Executante (Utilizada para estabelecer a prioridade)
[2] - CBO do Executante
[3] - Especialidade do Prestador (Utilizada para ajuste do campo BD6_CODESP)
[4] - Codigo da unidade de medida (Posicionar na especialidade referente a unidade em edicao)

	*/

	Do case

		case cAlias $ "BE4/BD5"

			//Para o cabecalho, eh utilizada a especialidade com maior ocorrencia na guia.
			for nI:= 1 to len(aEspXML)

				nPos := aScan(aEspUnic,{|x| allTrim(x[2]) == aEspXML[nI][1][3]})

				if nPos  == 0

					aadd(aEspUnic,{1,aEspXML[nI][1][3]})

					if nBkpRec == 0

						nBkpRec := aEspUnic[len(aEspUnic)][1]
						_cCodEsp:= aEspUnic[len(aEspUnic)][2]

					elseIf nBkpRec < aEspUnic[len(aEspUnic)][1]

						nBkpRec := aEspUnic[len(aEspUnic)][1]
						_cCodEsp:= aEspUnic[len(aEspUnic)][2]

					endIf

				else

					aEspUnic[nPos][1]++

					if nBkpRec < aEspUnic[nPos][1]
						nBkpRec := aEspUnic[nPos][1]
						_cCodEsp:= aEspUnic[nPos][2]
					endIf

				endIf

			next

			(cAlias)->&(cAlias+"_CODESP") := _cCodEsp

			return

		case cAlias == "BD6"

			BD6->(RecLock("BD6",.f.))
			BD6->BD6_ESPEXE := _cEspExe
			BD6->BD6_CODESP := _cCodEsp
			BD6->(msUnLock())

			return

		case cAlias == "BD7"
			/*
	Estrutura do aPriori
	[1] - Unidade do procedimento
	[2] - Prioridade da Unidade segundo cadastro da tabela BD3
			*/
			for nI := 1 to len(aCompo)
				aadd(aPriori,{val(aCompo[nI][2]),aCompo[nI][1]})
			next

			//Estabelecendo a prioridade da especialidade que vai para o campo BD6_ESPEXE com base na composicao do item.
			while !BD7->(eof()) .and. 	xFilial('BD6')+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) == ;
					BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

				//Se o array com a especialidade dos membros esta vazio,
				//devo apenas salvar as composicoes para atualizar o controle de saldo
				if len(aEspXML) == 0 .and. aUndBd7 <> nil
					aadd(aUndBd7,BD7->BD7_CODUNM)
					BD7->(dbSkip())
					loop
				endIf

				//localiza a especialidade da Composicao em edicao
				nPosEsp	:= aScan(aEspXML,{|x| len(x) >= 4 .and. allTrim(x[4]) == allTrim(BD7->BD7_CODTPA)})

				//Atualiza a especialidade do Prestador
				if nPosEsp > 0

					BD7->(RecLock("BD7",.f.))
					BD7->BD7_ESPEXE := aEspXML[nPosEsp][1]
					BD7->BD7_CODESP := aEspXML[nPosEsp][3]
					BD7->(msUnLock())

					_cEspExe := aEspXML[nPosEsp][1]
					_cCodEsp := aEspXML[nPosEsp][3]
				elseIf len(aEspXML) >= 0

					BD7->(RecLock("BD7",.f.))
					BD7->BD7_ESPEXE := aEspXML[len(aEspXML)][1]
					BD7->BD7_CODESP := aEspXML[len(aEspXML)][3]
					BD7->(msUnLock())

					_cEspExe := aEspXML[len(aEspXML)][1]
					_cCodEsp := aEspXML[len(aEspXML)][3]
				endIf

				//Se for UNL nao precisa buscar a prioridade
				if allTrim(BD7->BD7_CODUNM) == "UNL"
					_cEspExe := aEspXML[1][1]
					_cCodEsp := aEspXML[1][3]
				else
					//Verifica qual a posicao da Unidade atual no array de prioridades
					nPosPri := aScan(aPriori,{|x| allTrim(x[2]) == allTrim(BD7->BD7_CODUNM)})

					if nPosPri > 0 .and. nPosEsp > 0

						//Se estiver vazia, armazena a primeira
						if empty(_cCodEsp)
							_cEspExe 	:= aEspXML[nPosEsp][1]
							_cCodEsp 	:= aEspXML[nPosEsp][3]
							nBkpPri 	:= aPriori[nPosPri][1]
							//Se ja estiver preenchida, verifica se a prioridade anterior eh menor do que a atual
						elseIf nBkpPri > aPriori[nPosPri][1]
							_cEspExe 	:= aEspXML[nPosEsp][1]
							_cCodEsp 	:= aEspXML[nPosEsp][3]
							nBkpPri 	:= aPriori[nPosPri][1]
						endIf
					endIf
				endIf

				if aUndBd7 <> nil
					aadd(aUndBd7,BD7->BD7_CODUNM)
				endIf
				BD7->(dbSkip())

			endDo

			//Chamada recursiva para atualizacao das especialidades da BD6
			if len(aEspXML) > 0
				PlGrvEspXML("BD6",aEspXML,aCompo,_cEspExe,_cCodEsp)
			endIf

			return

	endCase

return

/*/{Protheus.doc} PLSDELMOVZ
Delete registro de movimento de um peg contas e ajusta eventuais efeitos no atendimento
função feita com base na PLSDELMOV, mas para uso na importação XML
@type function
@author Oscar Zanin
@since 19/04/2017
@version 1.0
/*/
function PLSDELMOVZ(cChave,cFase,lTudoOk,cTpGuEx)
	local lRet  	 := .f.
	local lEntrou 	 := .f.
	local aArea 	 := getArea()
	local cGuiInt 	 := ''
	local cTpFat 	 := ''
	local aUndBd7 	 := {}
	local nforY 	 := 1
	local cSqlUPDBE4 := ""
	local cSqlUPDB43 := ""
	local cSqlUPDBD6 := ""
	local cSqlUPDBD7 := ""
	local aDadBE4	 := {}
	local isPLSUNHMS := existBlock('PLSUNHMS')
	local nI		 := 1

	default cTpGuEx   := ""
	default lTudoOk   :=	.t.

	BCI->(dbSetOrder(1))//BCI_FILIAL + BCI_CODOPE + BCI_CODLDP + BCI_CODPEG + BCI_FASE + BCI_SITUAC
	if BCI->(msSeek(xFilial("BCI")+cChave)) .and. empty(BCI->BCI_PROCES)

		//atualiza status do peg
		PLSM190Pro(,,,,,,,,,,,.f.,.t.,BCI->(recno()))

		//verifica se esta em digitacao
		if BCI->BCI_FASE == cFase

			lRet := .t.

			BD7->(dbSetOrder(1))//BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO + BD7_ORIMOV + BD7_SEQUEN + BD7_CODUNM + BD7_NLANC
			if BD7->(msSeek(xFilial("BD7")+cChave))
				while !(BD7->(eof())) .and. BD7->(BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG) == xFilial("BD7")+cChave//BD7->(msSeek(xFilial("BD7")+cChave))

					if (nO := aScan(aUndBd7,{|x| allTrim(x[1]) == allTrim(BD7->(BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO))  })) > 0
						aadd(aUndBd7[nO][2],BD7->BD7_CODUNM)
					else
						aadd(aUndBd7,{BD7->(BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG + BD7_NUMERO),{BD7->BD7_CODUNM}})
					endIf

					BD7->(dbSkip())
				endDo
			endIf

			BE4->(dbSetOrder(1))//BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
			if BE4->( msSeek( xFilial("BE4") + cChave ) )

				while !(BE4->(eof())) .and. BE4->(BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG) == xFilial("BE4")+cChave

					cGuiInt := BE4->BE4_GUIINT
					cTpFat	:= BE4->BE4_TIPFAT

					aadd(aDadBE4, {cGuiInt, cTpFat})

					BE4->(dbSkip())
				endDo

				//BE4
				cSqlUPDBE4 := " UPDATE " + RetSqlName("BE4") + " SET "
				cSqlUPDBE4 += " D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
				cSqlUPDBE4 += " WHERE "
				cSqlUPDBE4 += " BE4_FILIAL = '" + xFilial("BE4") + "' AND "
				cSqlUPDBE4 += " BE4_CODOPE = '" + subStr(cChave, 1, 4) + "' AND "
				cSqlUPDBE4 += " BE4_CODLDP = '" + subStr(cChave, 5, 4) + "' AND "
				cSqlUPDBE4 += " BE4_CODPEG = '" + subStr(cChave, 9, 8) + "' AND "
				cSqlUPDBE4 += " D_E_L_E_T_ = ' '  "
			endIf

			//B43
			cSqlUPDB43 := " UPDATE " + RetSqlName("B43") + " SET "
			cSqlUPDB43 += " D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
			cSqlUPDB43 += " WHERE "
			cSqlUPDB43 += " B43_FILIAL = '" + xfilial("B43") + "' AND "
			cSqlUPDB43 += " B43_CODOPE = '" + subStr(cChave, 1, 4) + "' AND "
			cSqlUPDB43 += " B43_CODLDP = '" + subStr(cChave, 5, 4) + "' AND "
			cSqlUPDB43 += " B43_CODPEG = '" + subStr(cChave, 9, 8) + "' AND "
			cSqlUPDB43 += " D_E_L_E_T_ = ' '  "

			//BD7
			cSqlUPDBD7 := " UPDATE " + RetSqlName("BD7") + " SET "
			cSqlUPDBD7 += " D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
			cSqlUPDBD7 += " WHERE "
			cSqlUPDBD7 += " BD7_FILIAL = '" + xFilial("BD7") + "' AND "
			cSqlUPDBD7 += " BD7_CODOPE = '" + subStr(cChave, 1, 4) + "' AND "
			cSqlUPDBD7 += " BD7_CODLDP = '" + subStr(cChave, 5, 4) + "' AND "
			cSqlUPDBD7 += " BD7_CODPEG = '" + subStr(cChave, 9, 8) + "' AND "
			cSqlUPDBD7 += " D_E_L_E_T_ = ' '  "

			//BD6
			cSqlUPDBD6 := " UPDATE " + RetSqlName("BD6") + " SET "
			cSqlUPDBD6 += " D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
			cSqlUPDBD6 += " WHERE "
			cSqlUPDBD6 += " BD6_FILIAL = '" + xFilial("BD6") + "' AND "
			cSqlUPDBD6 += " BD6_CODOPE = '" + subStr(cChave, 1, 4) + "' AND "
			cSqlUPDBD6 += " BD6_CODLDP = '" + subStr(cChave, 5, 4) + "' AND "
			cSqlUPDBD6 += " BD6_CODPEG = '" + subStr(cChave, 9, 8) + "' AND "
			cSqlUPDBD6 += " D_E_L_E_T_ = ' '  "

			begin transaction

				for nI := 1 To len(aDadBE4)

					//limpa as informacoes de alta na solicitacao da internacao
					lExiste := .f.
					cSql := " SELECT BE4_GUIINT FROM " + RetSqlName("BE4")
					cSql += " WHERE BE4_FILIAL = '"+xFilial("BE4")+"' "
					cSql += " AND BE4_GUIINT = '"+aDadBE4[nI][1]+"' "
					cSql += " AND D_E_L_E_T_ <> '*' "

					PlsQuery(cSql,'TrbS1')

					if !TrbS1->(eof())
						lExiste := .t.
					endIf

					TrbS1->(dbCloseArea())

				next

				//deleta bd5
				aRecBE2 := {}

				BD5->(dbSetOrder(1))//BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO + BD5_SITUAC + BD5_FASE + dtos(BD5_DATPRO) + BD5_OPERDA + BD5_CODRDA
				if BD5->(msSeek(xFilial("BD5")+cChave))

					while BD5->(msSeek(xFilial("BD5")+cChave))

						nRecBD5 := BD5->(recno())
						nOrdBD5	:= BD5->(indexOrd())

						if !empty(BD5->BD5_NRLBOR) .and. BD5->BD5_TIPGUI $ "02/13"//ainda nao trato saldo para honorario individual, so SPSDAT - daher 23/04/2013

							// Se e uma excluao de autorizacao baseada em uma liberacao refaz saldo
							BD6->(dbSetOrder(1))
							if BD6->(msSeek(xFilial("BD6")+cChave+BD5->BD5_NUMERO))

								while !BD6->(eof()) .and. xFilial("BD6")+cChave+BD5->BD5_NUMERO == BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)

									// Atualizo saldo de uma liberacao
									// Aqui tem a seguinte regra se um evento tem HM e neste BD6 que eu acabei
									// de criar nao existe o HM, eu nao atualizo o saldo.. o saldo sempre eh abatido
									// quando se faz o honorario medico, pois podem ter 3 bd6 referentes a um mesmo
									// evento e eu so tenho que abater o saldo 1 vez senao fica com saldo negativo
									lAtuSaldo 	:= .f.
									aCompo 		:= PLSCOMEVE(BD6->BD6_CODTAB,BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_CODOPE,BD6->BD6_DATPRO)

									if len(aUndBd7) > 0

										nO := aScan(aUndBd7,{|x| allTrim(x[1]) == allTrim(BD6->(BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO))  })

										cUndHM := "HM,HMR,PPM,RCC,CIR"

										if isPLSUNHMS
											cUndHM := execBlock( 'PLSUNHMS',.f.,.f.,{cUndHM} )
										endIf

										//verifica se tem honorario na composição do evento
										if aScan(aCompo,{|x| allTrim(x[1]) $ cUndHM }) > 0 .and. nO > 0

											for nforY := 1 to len(aUndBd7[nO][2])

												if allTrim(aUndBd7[nO][2][nforY]) $ cUndHM // no evento que eu estou excluindo, tem nonorário?
													lAtuSaldo := .t.
													exit
												endIf

											next

										else
											lAtuSaldo := .t.
										endIf

										if !lAtuSaldo
											BD6->(dbSkip())
											loop
										endIf
									endIf

									// Seleciona todos os registros da execucao que esta sendo deletada
									cSQL := "SELECT BE2_SEQUEN, BE2_CODPAD, BE2_CODPRO, BE2_QTDPRO, BE2_SALDO, R_E_C_N_O_ FROM " + BE2->( RetSQLName("BE2") )
									cSQL += " WHERE BE2_FILIAL = '" + xFilial('BE2')				+"' "
									cSQL += " 	AND BE2_OPEMOV = '" + Subs(BD5->BD5_NRLBOR,1,4)		+"' "
									cSQL += " 	AND BE2_ANOAUT = '" + Subs(BD5->BD5_NRLBOR,5,4)		+"' "
									cSQL += " 	AND BE2_MESAUT = '" + Subs(BD5->BD5_NRLBOR,9,2)		+"' "
									cSQL += " 	AND BE2_NUMAUT = '" + Subs(BD5->BD5_NRLBOR,11,8)	+"' "
									cSQL += " 	AND BE2_CODPAD = '" + BD6->BD6_CODPAD				+"' "
									cSQL += " 	AND BE2_CODPRO = '" + BD6->BD6_CODPRO				+"' "
									cSQL += " 	AND BE2_STATUS = '1' AND BE2_LIBERA = '1' "
									cSQL += " 	AND D_E_L_E_T_ = ' '"

									dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"TrbBE2",.f.,.t.)

									// while nos itens da execucao
									while !TrbBE2->( eof() )

										//aqui eu garanto que um mesmo be2 nunca vai ser reprocessado
										//aqui eu garanto que se ele ainda tem saldo para abeter
										if aScan(aRecBE2,{|x| x == TrbBE2->R_E_C_N_O_}) <> 0 .and. TrbBE2->BE2_SALDO == 0
											TrbBE2->(dbSkip())
											loop
										endIf

										aadd(aRecBE2,TrbBE2->R_E_C_N_O_)

										// Quantidade do procedimento na execucao
										nQtdPro := BD6->BD6_QTDPRO
										cSequen := TrbBE2->BE2_SEQUEN

										PLSATUSS( nil ,.f.,nil,nil,"1",.f.,BD5->BD5_NRLBOR + cSequen,6,nil,nil,1,nQtdPro )

										lEntrou := .t.

										TrbBE2->( dbSkip() )
									endDo
									TrbBE2->( dbCloseArea() )

									BD6->(dbSkip())
								endDo
							endIf
							if PLSSALDO(BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV),BD5->BD5_NRLBOR)
								BEA->(dbSetOrder(1))
								if BEA->(msSeek(xFilial("BEA")+BD5->BD5_NRLBOR))
									PLSATUCS('1')
								endIf
							endIf
						endIf
						BD5->(dbGoto(nRecBD5))
						BD5->(dbSetOrder(nOrdBD5))

						BD5->( recLock("BD5",.f.) )
						BD5->(dbDelete())
						BD5->( msUnLock() )
					endDo
				endIf

				if TCSQLExec(cSqlUPDBD6) < 0

					FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', "TCSQLError() " + TCSQLError() , 0, 0, {})

				elseIf allTrim( TCGetDB() ) == "ORACLE"

					TCSQLExec("COMMIT")

				endIf

				//em casos que o campo nao existe D_E_L_E_T_ e R_E_C_D_E_L_...
				if tcSqlExec(cSqlUPDBD7) < 0

					if BD7->( msSeek( xFilial("BD7") + cChave ) )

						while  ! BD7->(eof()) .and. xFilial("BD7") + cChave == BD7->(BD7_FILIAL + BD7_CODOPE + BD7_CODLDP + BD7_CODPEG)

							BD7->(RecLock("BD7", .F.))
							BD7->(dbDelete())
							BD7->(MsUnLock())

							BD7->(DbSkip())
						endDo

					endIf

				elseIf allTrim( TCGetDB() ) == "ORACLE"

					TCSQLExec("COMMIT")

				endIf

				if TCSQLExec(cSqlUPDB43) < 0

					FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', "TCSQLError() " + TCSQLError() , 0, 0, {})

				elseIf allTrim( TCGetDB() ) == "ORACLE"

					TCSQLExec("COMMIT")

				endIf

				if TCSQLExec(cSqlUPDBE4) < 0

					FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', "TCSQLError() " + TCSQLError() , 0, 0, {})

				elseIf allTrim( TCGetDB() ) == "ORACLE"

					TCSQLExec("COMMIT")

				endIf

				if lTudoOk
					BCI->( recLock("BCI",.f.) )
					BCI->(dbDelete())
					BCI->( msUnLock() )
				else

					if cTpGuEx $ "03"
						cCampo := "BE4_NUMERO"
					else
						cCampo := "BD5_NUMERO"
					endIf

					B0Y->( dbSetOrder(1) )  //B0Y_FILIAL + B0Y_CAMPO + B0Y_CHAVE
					if B0Y->( msSeek( xFilial("B0Y")+cCampo+cChave ) )
						B0Y->( recLock("B0Y",.f.) )
						B0Y->(dbDelete())
						B0Y->( msUnLock() )
					endIf

				endIf

			end transaction
		endIf
	endIf

	restArea(aArea)

return(lret)

/*/{Protheus.doc} plRtPerV
retorna o percentual da via
@type function
@author PLSTEAM
@since 13.06.00
@version 1.0
/*/
function plRtPerV(cVia)
	local nPerVia := 0

	if ! empty(cVia)

		BGR->(dbSetOrder(1))//BGR_FILIAL+BGR_CODINT+BGR_CODVIA
		if BGR->( msSeek(xFilial('BGR') + plsIntPad() + cVia ) )
			nPerVia := BGR->BGR_PERC
		endIf

	endIf

return(nPerVia)

/*/{Protheus.doc} PLTrabRisc
Ajusta de Arrays de Trabalho se solicitado uma guia com eventos de
Baixo Risco no PTU Online

@author  PLS TEAM
@version P11
@since   19/12/2017
/*/
static function PLTrabRisc(aAuxBaiRis,cCodPad,cCodPro,lLog,cSeqMov,aEventosNeg,cTpArr)
	local aRegCriDel := {}
	local aAreaBCT   := {}
	local nSizeTrb   := 0
	local nCrit      := 0
	local cCodInt	 := plsIntPad()
	local lDelCriArr := .f.
	local lExiAtivBR := BCT->( fieldPos("BCT_ATIVBR") ) > 0

	default lLog     := .f.
	default cTpArr   := "1"

	aAreaBCT := BCT->( getArea() )

	BCT->( dbSetOrder(1) )//BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO

	for nCrit := 1 to len(aAuxBaiRis)

		// BCT_ATIVBR - Verifica se exibo ou nao as criticas apresentadas no Baixo Risco
		if ! empty(aAuxBaiRis[nCrit][1])

			lDelCriArr := .f.
			if BCT->( msSeek( xFilial("BCT") + cCodInt + IIF(cTpArr=="1",aAuxBaiRis[nCrit][1],aAuxBaiRis[nCrit][2]))) .and. ( ! lExiAtivBR .or. BCT->BCT_ATIVBR <> "1" )

				lDelCriArr := .t.

				if lLog
					PlsPtuLog(cCodPad + "-" + alltrim(cCodPro) + STR0106 + aAuxBaiRis[nCrit][1] + STR0107)//" -> Crítica " ### " não será apresentada devido ao campo BCT_ATIVBR."
				endIf

			endIf

		endIf

		// Marca Posicoes do Array que serao deletadas
		if lDelCriArr
			aadd(aRegCriDel,nCrit)
		endIf

	next

	BCT->( restArea(aAreaBCT) )

	// Deleta posicoes marcadas do array
	if len(aRegCriDel) > 0

		for nCrit := 1 to len(aRegCriDel)

			aDel(aAuxBaiRis,aRegCriDel[ ( len(aRegCriDel) + 1 ) - nCrit] )//Deleto a partir das ultimas posicoes para nao perder o ponteiro

			nSizeTrb ++

		next

		aSize(aAuxBaiRis,len(aAuxBaiRis) - nSizeTrb)

	endIf

	//Ajusta o aEventosNeg para quando houver criticas de Cabecalho
	if len(aEventosNeg) > 0 .and. len(aAuxBaiRis) == 0
		aRegCriDel := {}
		nCrit := Ascan(aEventosNeg,{|x|x[1] == cSeqMov .And. x[2] == cCodPad .And. Alltrim(x[3]) == Alltrim(cCodPro) })
		if nCrit > 0

			aadd(aRegCriDel,nCrit)
			for nCrit := 1 to len(aRegCriDel)
				aDel(aEventosNeg,aRegCriDel[ ( len(aRegCriDel) + 1 ) - nCrit] )//Deleto a partir das ultimas posicoes para nao perder o ponteiro
				nSizeTrb ++
			next

			aSize(aEventosNeg,len(aEventosNeg) - nSizeTrb)

		endIf
	endIf

return

/*/{Protheus.doc} PLGRVBX6
Função para incluir um BX6 vinculado ao BD6 que está sendo gravado
no PLSXAUTP -> PLSIITE
@author  Oscar Zanin
@version P12
@since   27/07/2018
/*/
Function PLGRVBX6(cUniMedida, cSeqTISS, cIdOutDes,cMemo,cMemoPac)

	Default cUniMedida := ""
	Default cSeqTISS := ""
	default cIdOutDes := ""
	default cMemo :=""
	default cMemoPac := ""

	BX6->(dbsetorder(1)) //BX6_FILIAL+BX6_CODOPE+BX6_CODLDP+BX6_CODPEG+BX6_NUMERO+BX6_ORIMOV+BX6_SEQUEN
	if !BX6->(msseek(xfilial("BX6")+BD6->BD6_CODOPE+BD6->BD6_CODLDP+BD6->BD6_CODPEG+BD6->BD6_NUMERO+BD6->BD6_ORIMOV+BD6->BD6_SEQUEN ))
		BX6->(RecLock("BX6", .T.))
		BX6->BX6_FILIAL := Xfilial("BX6")
		BX6->BX6_CODOPE := BD6->BD6_CODOPE
		BX6->BX6_CODLDP := BD6->BD6_CODLDP
		BX6->BX6_CODPEG := BD6->BD6_CODPEG
		BX6->BX6_NUMERO := BD6->BD6_NUMERO
		BX6->BX6_ORIMOV := BD6->BD6_ORIMOV
		BX6->BX6_SEQUEN := BD6->BD6_SEQUEN
		BX6->BX6_CODPAD := BD6->BD6_CODPAD
		BX6->BX6_CODPRO := BD6->BD6_CODPRO
		BX6->BX6_CODUNM := cUniMedida
		If lBX6SQTISS .AND. !(EmpTy(cSeqTISS))
			BX6->BX6_SQTISS := StrZero( val(cSeqTISS), 4)
		endIf
		If lBX6IDOUTD .AND. !(EmpTy(cIdOutDes))
			BX6->BX6_IDOUTD := StrZero( val(cIdOutDes), 4) //campo do Identificador de sequencial do item ao qual esta outra despesa se refere
		endIf
		If lBX6MEMORI .AND. !(empty(cMemo))
			BX6->BX6_MEMORI := cMemo
		endIf
		If lBX6MEMORI .AND. !(empty(cMemoPac))
			BX6->BX6_MEMORI := cMemoPac
		endIf
		BX6->(MsUnLock())
	elseif lBX6MEMORI .AND. !(empty(cMemoPac))
		BX6->(RecLock("BX6",.F.))
		BX6->BX6_MEMORI := cMemoPac
		BX6->(MsUnLock())
	endif
return


//-------------------------------------------------------------------
/*/{Protheus.doc} VerCritPTU
Verifica se o item ja esta no aDadIte e altera o mesmo para auditoria = sim

@author  Renan Sakai
@version P12
@since    03.12.18
/*/
//-------------------------------------------------------------------
Static Function VerCritPTU(aDadIte,aItens,cAuditoria,cStatus,cAlias)
	Local nPosItem := 0
	Local nPosAud  := 0
	Local nPosStat := 0
	Local lAjust   := .F.
	Default aDadIte    := {}
	Default cAuditoria := ""
	Default cStatus    := ""
	Default cAlias     := "BE2"

	nPosItem := aScan(aDadIte,{|x| x[1,2] == PLSRETDAD(aItens,"SEQMOV")})

	if len(aDadIte) > 0 .And. !Empty(cAuditoria) .And. nPosItem > 0
		lAjust := .T.
		if (nPosAud := Ascan(aDadIte[nPosItem],{|x|Alltrim(x[1]) == cAlias+"_AUDITO"}) ) > 0
			aDadIte[nPosItem,nPosAud,2] := cAuditoria
		endIf
	endIf

	if len(aDadIte) > 0 .And. !Empty(cStatus) .And. nPosItem > 0
		lAjust := .T.
		if (nPosStat := Ascan(aDadIte[nPosItem],{|x|Alltrim(x[1]) == cAlias+"_STATUS"}) ) > 0
			aDadIte[nPosItem,nPosStat,2] := cStatus
		endIf
	endIf

Return lAjust


function PLAgruCri(cCodRDA, cCodOpe, cCodLdp, cCodPeg, cNumero)

	Local aItens := {}
	Local cSql := ""
	Local lInter := .F.
	Local lFed := .F.
	local lNac := .f.
	Local lPrime := .T.
	Local cEstOpe := ""
	Local cSeqMov := ""
	Local cAlias := "BD5"
	local cOpeOrigem := ""
	Local lHonor := .F.
	Local cOrimov := ""
	Local lGrava := .F.
	Local aDadUsr := {} //PLSGETUSR()
	local cGrpEmpInt := getNewPar("MV_PLSGEIN","0050")

	cSql := " Select B6C_CODPAD, B6C_CODPRO, B6C_QTDPRO, B6C_NIVEL, BD6_OPEORI, BD6_HORPRO, BD6_HORFIM, BD6_DATPRO, BD6_ORIMOV, BD6_TIPGUI, BD6_QTDPRO, BD6_NUMERO from " + RetSqlName("BD6") + " BD6 "
	cSql += " Inner Join " + RetSqlName("B6B") + " B6B " //Proc principal
	cSql += " On "
	cSql += " B6B_FILIAL = '" + xfilial("B6B") + "' AND "
	cSql += " B6B_CODINT = BD6_CODOPE AND "
	cSql += " B6B_CODPAD = BD6_CODPAD AND "
	cSql += " B6B_CODPRO = BD6_CODPRO AND "
	cSql += " B6B.D_E_L_E_T_ = ' ' "
	cSql += " Inner Join " + RetsqlName("B6D") + " B6D " //RDA
	cSql += " On "
	cSql += " B6D_FILIAL = '" + xfilial("B6D") + "' AND "
	cSql += " B6D_CODINT = B6B_CODINT AND "
	cSql += " B6D_CODIGO = B6B_CODIGO AND "
	cSql += " B6D_CODRDA = '" + cCodRDA + "' AND "
	cSql += " B6D.D_E_L_E_T_ = ' ' "
	cSql += " Inner Join " + RetsqlName("B6C") + " B6C " //Proc para incluir
	cSql += " On "
	cSql += " B6C_FILIAL = '" + xFilial("B6C") + "' AND "
	cSql += " B6C_CODINT = B6B.B6B_CODINT AND "
	cSql += " B6C_CODIGO = B6B.B6B_CODIGO AND "
	cSql += " B6C.D_E_L_E_T_ = ' ' "
	cSql += " Where "
	cSql += " BD6_FILIAL = '" + xFilial("BD6") + "' AND "
	cSql += " BD6_CODOPE = '" + cCodOpe + "' AND "
	cSql += " BD6_CODLDP = '" + cCodLdp + "' AND "
	cSql += " BD6_CODPEG = '" + cCodPeg + "' AND "
	cSql += " BD6_NUMERO = '" + cNumero + "' AND "
	cSql += " BD6.D_E_L_E_T_ = ' ' "

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),"AGRBD6", .F., .T.)

	while !AGRBD6->(eoF())

		If lPrime
			cOrimov := AGRBD6->(BD6_ORIMOV)
			cOpeOrigem := AGRBD6->(BD6_OPEORI)
			If AGRBD6->(BD6_TIPGUI) == "05"
				cAlias := "BE4"
			endIf
			lInter := cOpeOrigem <> cCodOpe
			if !lInter
				if cAlias == "BD5"
					BD5->(DbSetOrder(1))
					if BD5->(MsSeek(xfilial("BD5")+cCodOpe+cCodLdp+cCodPeg+cNumero))
						if BD5->BD5_CODEMP == cGrpEmpInt
							lInter := .t.
							BA1->(DbSetOrder(2))
							if BA1->(MsSeek(xfilial("BA1")+BD5->(BD5_OPEUSR+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO)))
								cOpeOrigem := BA1->BA1_OPEORI
							endif
						endif
					endif
				else
					BE4->(DbSetOrder(1))
					if BE4->(MsSeek(xfilial("BE4")+cCodOpe+cCodLdp+cCodPeg+cNumero))
						if BE4->BE4_CODEMP == cGrpEmpInt
							lInter := .t.
							BA1->(DbSetOrder(2))
							if BA1->(MsSeek(xfilial("BA1")+BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)))
								cOpeOrigem := BA1->BA1_OPEORI
							endif
						endif
					endif
				endIf
			endif

			If lInter
				BA0->(DbSetOrder(1))
				If BA0->(MsSeek(xfilial("BA0")+cCodOpe))
					cEstOpe := BA0->BA0_EST
				endIf
				If BA0->(MsSeek(xfilial("BA0")+cOpeOrigem)) .ANd. BA0->BA0_EST == cEstOpe
					lFed := .t.
				else
					lNac := .t.
				endIf
			endIf
			lPrime := .F.
			csql := " Select BD6_SEQUEN from " + RetSqlName("BD6") + " BD6 "
			cSql += " Where "
			cSql += " BD6_FILIAL = '" + xFilial("BD6") + "' AND "
			csql += " BD6_CODOPE = '" + cCodOpe + "' AND "
			csql += " BD6_CODLDP = '" + cCodLdp + "' AND "
			cSql += " BD6_CODPEG = '" + cCodPeg + "' AND "
			cSql += " BD6_NUMERO = '" + cNumero + "' AND "
			cSql += " BD6.D_E_L_E_T_ = ' ' "
			cSql += " OrDer By BD6_SEQUEN DESC "
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),"MXSEQ", .F., .T.)
			cSeqMov := MXSEQ->(BD6_SEQUEN)
			MXSEQ->(dbCloseArea())
		endIf
		//1=Federativo;2=Local;3=Intercambio;4=Nacional;5=Todos
		If EmpTy( AGRBD6->(B6C_NIVEL) )
			AGRBD6->(Dbskip())
			Loop
		elseIf Alltrim( AGRBD6->(B6C_NIVEL) ) == '3' .AND. !lInter
			AGRBD6->(Dbskip())
			Loop
		elseIf Alltrim( AGRBD6->(B6C_NIVEL) ) == '2' .AND. lInter
			AGRBD6->(Dbskip())
			Loop
		elseIf Alltrim( AGRBD6->(B6C_NIVEL) ) == '1' .AND. !lFed
			AGRBD6->(Dbskip())
			Loop
		elseIf Alltrim( AGRBD6->(B6C_NIVEL) ) == '4' .AND. !lNac
			AGRBD6->(Dbskip())
			Loop
		endIf

		//AaDd( aMatIte, {"VLRAPR" , nVlrApr } )
		aadd(aItens,{})
		/*
	Beneficiário local: BD6_OPEORI igual a plsintpad().
	Beneficiário federativo: BD6_OPEORI diferente de plsintpad, mas o estados das operadoras devem ser iguais, BA0_EST(Operadora do plsintpad()) = BA0_EST(Operadora do BD6_OPEORI), exemplo: Unimed São Paulo enviando para Unimed Guarulhos, ambos são da federação de São Paulo.
	Beneficiário nacional: pode ser um else da busca acima, caso o estado seja diferente ele é nacional.
	Intercambio: Sempre que BD6_OPEORI for diferente do plsintpad()
	Todos: Não precisa verificar nada.
		*/
		//	lWeb		:= PLSRETDAD(aItens[nfor],"RPC",(PLSRETDAD(aItens[nfor],"TPGRV","1") == "2" ))
		//
		aadd(aItens[Len(aItens)], {"RPC", .F.})
		cSeqMov 	:= soma1(cSeqMov)
		aadd(aItens[Len(aItens)], {"SEQMOV", cSeqMov})
		aadd(aItens[Len(aItens)], {"CODPAD", AGRBD6->B6C_CODPAD})
		aadd(aItens[Len(aItens)], {"CODPRO", AGRBD6->B6C_CODPRO})
		aadd(aItens[Len(aItens)], {"DESPRO", Posicione("BR8",1,AGRBD6->B6C_CODPAD+AGRBD6->B6C_CODPRO, "BR8_DESCRI")})
		aadd(aItens[Len(aItens)], {"QTD", AGRBD6->B6C_QTDPRO * AGRBD6->BD6_QTDPRO}) //Quantidade do BD6 * Quantidade do B6C
		aadd(aItens[Len(aItens)], {"HORINI", AGRBD6->BD6_HORPRO})
		aadd(aItens[Len(aItens)], {"HORFIM", AGRBD6->BD6_HORFIM})
		aadd(aItens[Len(aItens)], {"DATPRO", StoD(AGRBD6->BD6_DATPRO)})
		aadd(aItens[Len(aItens)], {"SLVPAD", AGRBD6->B6C_CODPAD})
		aadd(aItens[Len(aItens)], {"SLVPRO", AGRBD6->B6C_CODPRO})

		//Verifica se o procedimento e de tipo pacote e alimenta os itens para gravacao da B43
		If BR8->( MsSeek(xFilial("BR8")+AGRBD6->B6C_CODPAD+AGRBD6->B6C_CODPRO) ) .And. BR8->BR8_TPPROC == "6"
			AaDd( aItens[Len(aItens)], {"PACPRO" , PlRetPac(cCodOpe,cCodRDA,AGRBD6->B6C_CODPAD,AGRBD6->B6C_CODPRO,,StoD(AGRBD6->BD6_DATPRO)) } )
		EndIf
		lGrava := .T.
		AGRBD6->(Dbskip())
	EndDo
	AGRBD6->(DbcloseArea())

	IF cAlias == "BD5"
		BD5->(dbSetOrder(1))
		BD5->(Msseek(xfilial("BD5") + cCodOpe + cCodLdp + cCodPeg + cNumero))
		PLSDADUSR(BD5->(BD5_OPEUSR+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO),"1",.f.,BD5->BD5_DATPRO)
		aDadUsr := PLSGETUSR()
		If BD5->BD5_TIPGUI == "06"
			lHonor := .T.
		endIf
	else
		BE4->(dbSetOrder(1))
		BE4->(Msseek(xfilial("BE4") + cCodOpe + cCodLdp + cCodPeg + cNumero))
		PLSDADUSR(BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO),"1",.f.,BE4->BE4_DATPRO)
		aDadUsr := PLSGETUSR()
	endIF
	If lGrava
		PLSIITE(/*clocalExec*/"1",/*cTipoGrv*/ "1",aItens,/*aCriticas*/{},/*cNumLib*/,/*aTipPart*/,cAlias,lHonor,/*dDatPro*/,/*cHora*/,cOrimov,/*cMatrAntGen*/,/*dDatAcat*/,/*lImpTxt*/,aDadUsr,/*lnInfEquip*/, /*lXmlOrigS*/, /*lImpXml*/)
	endIf

return

//-------------------------------------------------------------------
/*/{Protheus.doc} plsConEmp
Função para verificar se houve transferência do beneficiário entre contratos

@author    Eduardo Bento
@version   V12
@since     20/01/2022
/*/
//-------------------------------------------------------------------
function plsConEmp(dDataAtend,cMatricula)

	local cSQL 			:= ""
	local aDadosHist 	:= {} //Dados do Contrato: 1-Contrato 2-SubContrato 3-Versão do Contrato 4-Versão do SubContrato
	default dDataAtend	:= stod("") //Data de Atendimento
	default cMatricula	:= ""

	cSQL := "SELECT BQT_DTRANS DATA_TRANSFERENCIA, BQT_CONORI CONTRATO_ORIGEM, BQT_SUBORI SUBCONTRATO_ORIGEM, "
	cSQL += "BQT_VCOORI VERSAO_CONTRATO, BQT_VRSORI VERSAO_SUBCONTRATO "
	cSQL += "FROM " + RetSQLName("BQT") + " "
	cSQL += "WHERE BQT_FILIAL = '"+xFilial("BQT")+"' AND "
	cSQL += "BQT_MATRIC = '"+cMatricula+"' AND "
	cSQL += "D_E_L_E_T_ = ' ' "
	cSQL += "ORDER BY DATA_TRANSFERENCIA"
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"QRYBQT",.F.,.T.)

	While !QRYBQT->(Eof())
		If dDataAtend < stod(QRYBQT->DATA_TRANSFERENCIA)
			aDadosHist := {QRYBQT->CONTRATO_ORIGEM,QRYBQT->SUBCONTRATO_ORIGEM,QRYBQT->VERSAO_CONTRATO,QRYBQT->VERSAO_SUBCONTRATO}
		EndIf
		QRYBQT->(dbSkip())
	EndDo
	QRYBQT->(dbCloseArea())

return aDadosHist

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSISURG
Verifica se após o de-para se o registro na BDR é realmente de urgencia

@author    Lucas Nonato
@version   V12
@since     13/07/2022
/*/
function PLSISURG(cCod)
local lRet 		:= .f.
local cSql 		:= ""
default cCod 	:= ""

if !empty(cCod)
	if cCod == '2'
		lRet := .t.
	endif

	if !lRet
		cSql := " SELECT BDR_CARINT " 
		cSql += " FROM " + RetSqlName("BDR") + " BDR "
		cSql += " WHERE BDR_FILIAL = '" + xFilial("BDR") + "' " 
		cSql += " AND BDR_CODOPE = '" + plsintpad() + "' " 
		cSql += " AND BDR_CODTAD = '" + cCod + "' " 	
		cSql += " AND D_E_L_E_T_ = ' ' " 

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbUrg",.F.,.T.)
		if !TrbUrg->(eof())	
			if TrbUrg->BDR_CARINT == 'U'
				lRet := .t.
			endif
		endif
		TrbUrg->(dbclosearea())
	endif
endif

return lRet
