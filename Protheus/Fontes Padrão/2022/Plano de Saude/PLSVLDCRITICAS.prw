#Include 'Protheus.ch'
#INCLUDE "PLSMCCR.CH" 

STATIC cCodRDA		:= ""
static lSempMsgErro	:= .t.
static nValorCrit	:= 0

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVlCabConsulta
LOTEGUIAS de Consulta: Valida o cabeçalho.

@author  Silvia Sant'Anna
@version P12
@since   05/10/2018
/*/
//-------------------------------------------------------------------
Function PlsVlCabConsulta(oLote)	
	
	Local aAreaBAU	:= BAU->(GetArea())
	Local aAreaBA0	:= BA0->(GetArea())
	local aResult		:= {}
	Local cSoap		:= ""
	local dDataH		:= Date()
	local lCalend		:= iif(GetNewPar("MV_PLCALPG","1") == "2", .t., .f.)
	
	//Verifica se Codigo da RDA ou CPF/CNPJ existe:
	If !Empty(oLote:cCodRDA)
		BAU->(DbSetOrder(1)) //BAU_FILIAL+BAU_CODIGO
		If ! BAU->(MsSeek(xFilial("BAU")+ alltrim(oLote:cCodRDA)))
	   		cSoap := PLSTISSNWL( oLote, {},  {{1, 0, "", "1203" ,"CÓDIGO PRESTADOR INVÁLIDO"}} )
	   	Endif
		
	Elseif !Empty(oLote:cCgcOri)
		If CGC(oLote:cCgcOri)
			BAU->(DbSetOrder(4)) //BAU_FILIAL+BAU_CPFCGC
			If ! BAU->(MsSeek(xFilial("BAU")+ alltrim(oLote:cCgcOri)))
				cSoap := PLSTISSNWL( oLote, {}, {{1, 0, "", "1203" ,"CODIGO PRESTADOR INVÁLIDO"}} )
		   	Endif	
		Else
			cSoap := PLSTISSNWL( oLote, {}, {{1, 0, "", "1206" ,"CPF / CNPJ INVÁLIDO"}} )
	   	Endif
	Endif
	
	cCodRDA := BAU->BAU_CODIGO
	oLote:cCodRDA := cCodRDA
	
	If !Empty(oLote:cRegAns)
		BA0->( DbSetOrder(5) ) //BA0_FILIAL+BA0_SUSEP
		If !BA0->( MsSeek( xFilial("BA0")+ alltrim(oLote:cRegAns) ) )
			cSoap := PLSTISSNWL( oLote, {}, {{1, 0, "", "5027", "REGISTRO ANS DA OPERADORA INVÁLIDO"}} ) //função do michel
		EndIf
	EndIf 
	
	//Validar Calendário de Pagamento
	if lCalend .and. empty(cSoap)
		aResult := PLSXVLDCAL(dDataH,PlsIntPad(),.f.,'','',.t.,cCodRda,.f.,.f.)
		if aResult[1]
			if ( !(dDataH >= ctod(aResult[8]) .and. dDataH <= ctod(aResult[9])) ) //busca janela 1
				if !(Len(aResult) >= 10 .AND. aResult[10] .AND. dDataH >= ctod(aResult[8]) .and. dDataH <= ctod(aResult[9]) ) //busca janela 2, caso exista
					cSoap := PLSTISSNWL( oLote, {}, {{1, 0, "", "3091", "COBRANÇA FORA DO PRAZO ESTIPULADO NO CONTRATO - PERIODO DE " + strtran(aResult[8], "/", "-") + " ATÉ " + strtran(aResult[9], "/", "-") }} ) //função do michel
				endif
			endif
		else
			cSoap := PLSTISSNWL( oLote, {}, {{1, 0, "", "3091", "COBRANÇA FORA DO PRAZO ESTIPULADO NO CONTRATO - ENTRE EM CONTATO COM A OPERADORA - CALENDARIO NAO CADASTRADO" }} ) //função do michel
		endif		
	endif		

	If Empty(cSoap)
		cSoap := PLTisOnBXX( oLote, cCodRDA )
    	if ! Empty(cSoap)
    	  	return cSoap
    	Endif
    EndIf
    
	RestArea(aAreaBAU)
	RestArea(aAreaBA0)
	
Return (cSoap)


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVlGuiConsulta
LOTEGUIAS Consulta: Valida as Guias.

@author  Silvia Sant'Anna
@version P12
@since   05/10/2018
/*/
//-------------------------------------------------------------------
function PlsVlGuiConsulta (oLote, oGuia, aCritSoap, nX)
	
	local aAreaBA1 	:= BA1->(GetArea())
	local aAreaBA3	:= BA3->(GetArea())
	local aAreaBFG	:= BFG->(GetArea())
	local aAreaBAU	:= BAU->(GetArea())
	local aAreaBR8	:= BR8->(GetArea())
	local aAreaBA0	:= BA0->(GetArea())
	local aVgDatBlo	:= {}
	local lCritica	:= .f.
	local dDataAtend	:= PLSAJUDAT(oGuia:cDataAtend)
	local cNumGuiPre	:= oGuia:cNUMGUIPRE
	local cMatNova		:= ""

	//verifico o tipo de crítica - no futuro pode ser parametrizado:
	nValorCrit := iif(lSempMsgErro, 1, 2)

	If cCodRDA <> BAU->BAU_CODIGO
		BAU->(DbSetOrder(1)) //BAU_FILIAL+BAU_CODIGO
		BAU->(MsSeek(xFilial("BAU")+cCodRDA))
	EndIf
	
	If !Empty(oGuia:cRegAnsCab)
		BA0->( DbSetOrder(5) ) //BA0_FILIAL+BA0_SUSEP
		If !BA0->( MsSeek( xFilial("BA0")+ alltrim(oGuia:cRegAnsCab ) ))
			aAdd(aCritSoap,{nValorCrit, nX, "", "5027", "REGISTRO ANS DA OPERADORA INVÁLIDO - N Guia: " + AllTrim(cNumGuiPre)})
		EndIf
	EndIf 

	//valida CNES
	if !empty(oGuia:oRDA:cCnes)
		PlsVlLtdCnes(oGuia:oRDA:cCnes, dDataAtend, @aCritSoap, nX, cCodRda, AllTrim(cNumGuiPre))
	endif	

	//Verifica se a data do atendimento é menor que a data de inclusão no plano :
	if (dDataAtend < BAU->BAU_DTINCL)	
		aAdd(aCritSoap,{nValorCrit, nX, "", "1201", "ATENDIMENTO FORA DA VIGENCIA DO CONTRATO COM O CREDENCIADO - N Guia: " + AllTrim(cNumGuiPre)})
	endif
	
	//Verifica se a RDA estava bloqueada na data :
	if ! Empty(cCodRDA) .AND. ! A360CHEBLO(cCodRda, dDataAtend, .t., time())
		aAdd(aCritSoap,{nValorCrit, nX, "", "1212" ,"ATENDIMENTO / REFERÊNCIA FORA DA VIGÊNCIA DO CONTRATO DO PRESTADOR - N Guia: " + AllTrim(cNumGuiPre)})
	endIf
	
	if !empty(oGuia:oBenef:cCarteirinha)                                                                                                                                         
		BA1->(dbsetorder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
		if !BA1->(dbseek(xFilial("BA1") + alltrim(oGuia:oBenef:cCarteirinha)))
			BA1->(dbsetorder(5))
			if !BA1->(DbSeek(xFilial("BA1")+alltrim(oGuia:oBenef:cCarteirinha))) //BA1_FILIAL + BA1_MATANT + BA1_TIPANT
				lCritica := .t.
				aAdd(aCritSoap,{nValorCrit, nX, "", "1001", "NUMERO DA CARTEIRA INVALIDO - N Guia: " + AllTrim(cNumGuiPre)})
			endif
		endif
		
		if !lCritica  //Significa que achou o beneficiário.
			//Verificar se o beneficiário estava bloqueado no dia do atendimento :
			if (PlChHiBlo('BCA',dDataAtend,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BA1->BA1_TIPREG,nil,nil,nil,nil,@aVgDatBlo,.F.))
				// Verifica se a matricula informada e anterior a alguma transferencia
				if !empty(BA1->(BA1_TRADES)) .and. PlXmlCkDes(BA1->(BA1_TRADES), dDataAtend, @cMatNova)
					oGuia:oBenef:cCarteirinha := cMatNova
					BA1->(dbsetorder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
					BA1->(dbseek(xFilial("BA1") + alltrim(cMatNova)))
				else
					aAdd(aCritSoap,{nValorCrit, nX, "", "1016", "BENEFICIÁRIO COM ATENDIMENTO SUSPENSO - N Guia: " + AllTrim(cNumGuiPre)})
				endif
			endif
			
			//Verifica se a data do atendimento é menor que a data de inclusão no plano :
			if (dDataAtend < BA1->BA1_DATINC)	
				aAdd(aCritSoap,{nValorCrit, nX, "", "1005", "ATENDIMENTO ANTERIOR À INCLUSÃO DO BENEFICIÁRIO - N Guia: " + AllTrim(cNumGuiPre)})
			endif
			
			//Verifica data da carteira	:
			if (!empty(BA1->BA1_DTVLCR) .and. dDataAtend > BA1->BA1_DTVLCR)	
				aAdd(aCritSoap,{nValorCrit, nX, "", "1017", "DATA VALIDADE DA CARTEIRA VENCIDA - N Guia: " + AllTrim(cNumGuiPre) })
			endif
			
		endif		
			
	endif
	    

	PlsVlProcConsulta(oLote,oGuia,@aCritSoap,nX)
	

	RestArea(aAreaBA1)
	RestArea(aAreaBA3)
	RestArea(aAreaBFG)
	RestArea(aAreaBAU)
	RestArea(aAreaBR8)
	RestArea(aAreaBA0)

return (aCritSoap)


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVlProcConsulta
LOTEGUIAS Consulta: Valida os Procedimentos.

@author  Silvia Sant'Anna
@version P12
@since   05/10/2018
/*/
//-------------------------------------------------------------------
function PlsVlProcConsulta (oLote, oGuia, aCritSoap, nX)
	local cCodPad	:= ""
	local cCodPro	:= ""
	local aTabDup	:= PlsBusTerDup(SuperGetMv("MV_TISSCAB",.F.,"87"))
	
	//verifico o tipo de crítica - no futuro pode ser parametrizado:
	nValorCrit := iif(lSempMsgErro, 1, 3)

	cCodPad	:= AllTrim(PLSVARVINC('87','BR4',oGuia:oProced:cCodTab))
	cCodPro	:= AllTrim(PLSVARVINC(oGuia:oProced:cCodTab,'BR8', oGuia:oProced:cCodPro, cCodPad+oGuia:oProced:cCodPro,,aTabDup,@CCODPAD))
	
	BR8->(dbSetOrder(1)) //BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN
	If BR8->(msSeek(xFilial("BR8") + alltrim(cCodPad + cCodPro) ))	

		if ! PLSISCON(cCodPad, cCodPro)
			aAdd(aCritSoap,{nValorCrit, nX, cCodPro,  "5058", "PROCEDIMENTO INCOMPATÍVEL COM O TIPO DE GUIA. - N Guia: " + alltrim(oGuia:cNUMGUIPRE) })
		Endif
	Else
		aAdd(aCritSoap,{nValorCrit, nX, cCodPro,  "1801", "PROCEDIMENTO INVÁLIDO. - N Guia: " + alltrim(oGuia:cNUMGUIPRE) })
	EndIf
return (aCritSoap)


function PlsVlLtdCnes(cCnes, dDataAtend, aCritSoap, nX, cCodRda, cNumGuiaAv)
local lRet 		:= .t.
local cOpeMov	:= PlsIntPad()
local lFound	:= .f.
local lNoCnes	:= .f.
local cLocXML	:= ""
local dDatBlo	:= CtoD("")
local cCompCrit	:= ""
default cNumGuiaAv	:= ""

//verifico o tipo de crítica - no futuro pode ser parametrizado:
nValorCrit := iif(lSempMsgErro, 1, 2)

//Verifica se o CNES existe em algum local de atendimento do Prestador
BB8->(DbSetOrder(1))//BB8_FILIAL+BB8_CODIGO+BB8_CODINT+BB8_CODLOC+BB8_LOCAL
if BB8->(MsSeek(xFilial("BB8")+ cCodRda + cOpeMov))
	While !BB8->(Eof()) .And. AllTrim(BB8->(BB8_CODIGO + BB8_CODINT)) == cCodRda + cOpeMov  	
		lFound	:= AllTrim(BB8->BB8_CNES) == AllTrim(cCnes) 
		lNoCnes	:= empty(BB8->BB8_CNES)
		cLocXML	:= AllTrim(BB8->BB8_CODLOC)
		dDatBlo	:= BB8->BB8_DATBLO
		
		BB8->(DbSkip())
			
		if lFound .Or. lNoCnes
			exit
		endif
	EndDo
	
	if (!lFound .And. !lNoCnes)
		lRet 		:= .F.
		cCompCrit	:= "CNES não encontrado nos Locais de atendimento." 
	endif
endif
	
if lRet
	if !empty(dDatBlo) .And. !lNoCnes .and. dDataAtend >= dDatBlo
		lRet := .F.
		cCompCrit	:= "Local de atendimento bloqueado na data do atendimento."
	endif
endif

if !lRet
	aAdd(aCritSoap,{nValorCrit, nX, "", "1202", "NÚMERO DO CNES INVÁLIDO - " + cCompCrit + " - N Guia: " + alltrim(cNumGuiaAv)})
endif

return (aCritSoap)

/*/{Protheus.doc} function
Verfica se existe matricula vigente para matriculas que estão bloqueadas (wsloteguias)
@author  victor.silva
@since   20201005
/*/
function PlXmlCkDes(cMatDes, dDataAtend, cMatNova)
	local aAreaBA1		:= BA1->(GetArea())
	local lHasMatVig	:= .F.
	local lIntHat    	:= 	GetNewPar("MV_PLSHAT","0") == "1"
	default dDataAtend	:= Date()

	// Caso a integracao com o HAT esteja desabilitada nao roda a validacao
	if lIntHat
		BA1->(dbsetorder(2)) // BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO
		if BA1->(dbseek(xFilial("BA1") + alltrim(cMatDes)))
			if !(PlChHiBlo('BCA',dDataAtend,BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC),BA1->BA1_TIPREG,nil,nil,nil,nil,{},.F.))
				cMatNova := BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO)
				lHasMatVig := .T.
			// Caso tenha outra matricula de transferencia, faz a chamada recursiva
			elseif !empty(BA1->(BA1_TRADES))
				lHasMatVig := PlXmlCkDes(BA1->(BA1_TRADES), dDataAtend, @cMatNova)
			endif
		endif
	endif

	RestArea(aAreaBA1)

return lHasMatVig
