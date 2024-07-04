#Include 'Protheus.ch'
#INCLUDE "PLSMCCR.CH" 

STATIC cCodRDA	:= ""
static lSempMsgErro	:= .t.
static nValorCrit	:= 0

//-------------------------------------------------------------------
/*/{Protheus.doc} PlVlTCabSADT
LOTEGUIAS de Consulta: Valida o cabeçalho.

@author  Silvia Sant'Anna
@version P12
@since   05/10/2018
/*/
//-------------------------------------------------------------------
Function PlVlTCabSADT(oLote)	
	
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
			if ( !(dDataH >= ctod(aResult[8]) .and. dDataH <= ctod(aResult[9])) )
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
/*/{Protheus.doc} PlVlTGuiSADT
LOTEGUIAS Consulta: Valida as Guias.

@author  Silvia Sant'Anna
@version P12
@since   05/10/2018
/*/
//-------------------------------------------------------------------
function PlVlTGuiSADT (oLote, oGuia, aCritSoap, nX)
	
	local aAreaBA1 	:= BA1->(GetArea())
	local aAreaBA3	:= BA3->(GetArea())
	local aAreaBFG	:= BFG->(GetArea())
	local aAreaBAU	:= BAU->(GetArea())
	local aAreaBR8	:= BR8->(GetArea())
	local aAreaBA0	:= BA0->(GetArea())
	local aAreaBEA	:= BEA->(GetArea())
	local aVgDatBlo	:= {}
	local aRetF		:= {}
	local lCritica	:= .f.
	local dDataAtend	:= PLSAJUDAT(oGuia:oProced:cDatExec)
	local cMatNova		:= ""
	local cNumGuiPre	:= oGuia:cNUMGUIPRE

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
	if !empty(oGuia:oRDAExecutante:cCnes )
		PlsVlLtdCnes(oGuia:oRDAExecutante:cCnes, dDataAtend, @aCritSoap, nX, cCodRda, cNumGuiPre)
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
	
	//RDA Executante
	aRetF := PlVrCodBAU(oGuia)
	if !aRetF[1]
		aAdd(aCritSoap,{nValorCrit, nX, "", aRetF[2], aRetF[3] + " DO CONTRATADO EXECUTANTE - N Guia: " + AllTrim(cNumGuiPre)})		
	endif    

	//Procedimento
	PlVlProcSADT(oLote,oGuia,@aCritSoap,nX)
	
	RestArea(aAreaBA1)
	RestArea(aAreaBA3)
	RestArea(aAreaBFG)
	RestArea(aAreaBAU)
	RestArea(aAreaBR8)
	RestArea(aAreaBA0)
	RestArea(aAreaBEA)

return (aCritSoap)


//-------------------------------------------------------------------
/*/{Protheus.doc} PlVlProcSADT
LOTEGUIAS Consulta: Valida os Procedimentos.

@author  Silvia Sant'Anna
@version P12
@since   05/10/2018
/*/
//-------------------------------------------------------------------
function PlVlProcSADT (oLote, oGuia, aCritSoap, nX, lOutrDesp)
	local cCodPad		:= ""
	local cCodPro		:= ""
	local cCodPadBK	:= ""
	local cCodProBK	:= ""
	local aTabDup		:= PlsBusTerDup(SuperGetMv("MV_TISSCAB",.F.,"87"))
	default lOutrDesp	:= .f.	
	
	//verifico o tipo de crítica - no futuro pode ser parametrizado:
	nValorCrit := iif(lSempMsgErro, 1, 3)
	
	cCodPadBK	:= iif(!lOutrDesp, oGuia:oProced:cCodTab, oGuia:oProcedOutDesp:cCodTab) 
	cCodProBK	:= iif(!lOutrDesp, oGuia:oProced:cCodPro, oGuia:oProcedOutDesp:cCodPro) 
					
	cCodPad	:= AllTrim(PLSVARVINC('87', 'BR4', cCodPadBK))
	cCodPro	:= AllTrim(PLSVARVINC(cCodPadBK, 'BR8', cCodProBK, cCodPad+cCodProBK , ,aTabDup, @CCODPAD))
	
	BR8->(dbSetOrder(1)) //BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN
	If !BR8->(msSeek(xFilial("BR8") + alltrim(cCodPad + cCodPro) ))	
		aAdd(aCritSoap,{nValorCrit, nX, cCodPro,  "1801", "PROCEDIMENTO INVÁLIDO. - N Guia: " + alltrim(oGuia:cNUMGUIPRE) })
	endif
	
return (aCritSoap)



//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVlProcConsulta
LOTEGUIAS Consulta: Valida os Procedimentos.

@author  Silvia Sant'Anna
@version P12
@since   05/10/2018
/*/
//-------------------------------------------------------------------
function PlVlExTSADT(oLote,oGuia,aCritSoap,nX)
local aAreaBB0	:= BB0->(getarea())
local aAreaBAU	:= BAU->(getarea())
local cCodigo 	:= oGuia:oProfExecSadt:cCodProf
local cCodPro		:= oGuia:oProced:cCodPro
local cNumGuiPre	:= oGuia:cNUMGUIPRE  

//verifico o tipo de crítica - no futuro pode ser parametrizado:
nValorCrit := iif(lSempMsgErro, 1, 3)

BAU->( DbSetOrder(1) ) //BAU_FILIAL + BAU_CODIGO

if !BAU->( MsSeek( xFilial("BAU")+cCodigo ) )
	BAU->( DbSetOrder(4) ) //BAU_FILIAL + BAU_CPFCGC
	
	if !BAU->( MsSeek( xFilial("BAU")+cCodigo ) )
		BB0->( DbSetOrder(1) ) //BB0_FILIAL + BB0_CODIGO
		
		if !BB0->( MsSeek( xFilial("BB0")+cCodigo ) )
			BB0->( DbSetOrder(3) ) //BB0_FILIAL + BB0_CPF
			
			if !BB0->( MsSeek( xFilial("BB0")+cCodigo ) )
				aAdd(aCritSoap,{nValorCrit, nX, cCodPro, "1206", "CPF / CNPJ INVÁLIDO DO EXECUTANTE. - N Guia: " + alltrim(oGuia:cNUMGUIPRE)})
			endif
		
		endif
	
	endif

endif
		
RestArea(aAreaBB0)
RestArea(aAreaBAU)

Return (aCritSoap)



//-------------------------------------------------------------------
/*/{Protheus.doc} PlVrCodBAU
LOTEGUIAS Consulta: Valida os Procedimentos.

@author  Silvia Sant'Anna
@version P12
@since   05/10/2018
/*/
//-------------------------------------------------------------------
static function PlVrCodBAU(oGuia)
local aRetorno	:= {.t.}	
local aAreaBAU	:= BAU->(getarea())
//Verifica se Codigo da RDA ou CPF/CNPJ existe:
If !Empty(oGuia:oRDAExecutante:cCodRda)
	BAU->(DbSetOrder(1)) //BAU_FILIAL+BAU_CODIGO
	If ! BAU->(MsSeek(xFilial("BAU")+ alltrim(oGuia:oRDAExecutante:cCodRda)))
   		aRetorno := {.f.,"1203", "CODIGO PRESTADOR INVÁLIDO" }
   	Endif
	
Elseif !Empty(oGuia:oRDAExecutante:cCgc)
	If CGC(oGuia:oRDAExecutante:cCgc)
		BAU->(DbSetOrder(4)) //BAU_FILIAL+BAU_CPFCGC
		If ! BAU->(MsSeek(xFilial("BAU")+ alltrim(oGuia:oRDAExecutante:cCgc)))
			aRetorno := {.f.,"1203", "CODIGO PRESTADOR INVÁLIDO" }
	   	Endif	
	Else
		aRetorno := {.f.,"1206", "CPF / CNPJ INVÁLIDO" }
   	Endif
Endif

RestArea(aAreaBAU)

return aRetorno