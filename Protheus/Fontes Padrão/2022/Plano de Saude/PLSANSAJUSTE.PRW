#Include "PROTHEUS.CH"
#DEFINE LOGPLS 'fatans2020.log'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
ModelDef - MVC.

@author    
@version   V12
@since     
/*/
//------------------------------------------------------------------------------------------

Function PlsAnsAjuste(lAutomato,aParam)

	Local aParamBox		:= {}
	Local cTitulo       :="Ajuste"  
	Local lCentered     := .T.
	
	Local aTipoPes		:= {"1=Pessoa Fisica","2=Juridica"}
	Local aAnalisaPrd	:= {"1=Somente Faixa etaria","2=Somente Reajuste","3=Ambos"}
	Local aMesAnter		:= {"0=Não","1=Sim"}
	Local aTipCalc		:= {"1=Padrão","2=Base de calculo Faixa atual"}
	Local nVlrCorte		:= 0
	
	Default lAutomato	:= .F.
	Default aParam        := {}


	Iif(!lAutomato,aAdd(aParamBox, {1, "Operadora:"				, Space(Tamsx3("BDC_CODOPE")[1])			,"@!"					, "", "B89PLS"	, "", 50, .T.}),)
	Iif(!lAutomato,aAdd(aParamBox, {1, "Empresa De :"			, Space(Tamsx3("BA3_CODEMP")[1])			,"@!"					, "", "B7APLS"	, "", 50, .F.}),)  
	Iif(!lAutomato,aAdd(aParamBox, {1, "Empresa Até:"			, Replicate("Z",Tamsx3("BA3_CODEMP")[1])	,"@!"					, "", "B7APLS"	, "", 50, .F.}),) 
	Iif(!lAutomato,aAdd(aParamBox, {1, "Contrato De:"			, Space(Tamsx3("BA3_CONEMP")[1])			,"@!"					, "", ""	    , "", 50, .F.}),) 
	Iif(!lAutomato,aAdd(aParamBox, {1, "Contrato Até:"			, Replicate("Z",Tamsx3("BA3_CONEMP")[1])	,"@!"					, "", ""    	, "", 50, .F.}),) 
	Iif(!lAutomato,aAdd(aParamBox, {1, "Mes Faturam:"			, Space(Tamsx3("BDC_MESINI")[1])			,"@!"					, "", ""		, "", 50, .T.}),)   
	Iif(!lAutomato,aAdd(aParamBox, {1, "Ano Faturam:"			, Space(Tamsx3("BDC_ANOINI")[1])			,"@!"					, "", ""		, "", 50, .T.}),) 
	Iif(!lAutomato,aAdd(aParamBox, {2, "Tipo:"																						,""	,aTipoPes 	, 60, "", .T.}),)   
	Iif(!lAutomato,aAdd(aParamBox, {1, "Cod.Lanc.Reaj.:"		, Space(Tamsx3("BSQ_CODLAN")[1])			,"@!"					, "", "BSPPLS"	, "", 50, .T.}),) 
	Iif(!lAutomato,aAdd(aParamBox, {1, "Cod.Lanc.Fai .:"		, Space(Tamsx3("BSQ_CODLAN")[1])			,"@!"					, "", "BSPPLS"	, "", 50, .T.}),)
	Iif(!lAutomato,aAdd(aParamBox, {1, "Mes Base Fx.Etaria:"	, '01'										,"@!"					, "", ""		, "", 50, .T.}),)   
	Iif(!lAutomato,aAdd(aParamBox, {1, "Ano BaseFx.Etaria:"		, '2020'									,"@!"					, "", ""		, "", 50, .T.}),) 
	Iif(!lAutomato,aAdd(aParamBox, {1, "Matricula De :"			, Space(Tamsx3("BA3_MATRIC")[1])			,"@!"					, "", ""		, "", 50, .F.}),)  
	Iif(!lAutomato,aAdd(aParamBox, {1, "Matricula Até:"			, Replicate("Z",Tamsx3("BA3_MATRIC")[1])	,"@!"					, "", ""		, "", 50, .F.}),)  
	Iif(!lAutomato,aAdd(aParamBox, {2, "Considera:"																					, "",aAnalisaPrd, 60, "", .T.}),)   
	Iif(!lAutomato,aAdd(aParamBox, {1, "Mes Base Reajuste:"		, '05'										,"@!"					, "", ""		, "", 50, .T.}),)   
	Iif(!lAutomato,aAdd(aParamBox, {1, "Ano Base Reajuste:"		, '2020'									,"@!"					, "", ""		, "", 50, .T.}),) 
	Iif(!lAutomato,aAdd(aParamBox, {1, "Grupos de Cobrança:"	, Space(Tamsx3("BA3_GRPCOB")[1])			,"@!"					, "", "BR0PLS"	, "", 50, .F.}),) 
	Iif(!lAutomato,aAdd(aParamBox, {2, "Analisa Meses anteriores:"																	, "",aMesAnter	, 60, "", .T.}),) 
	Iif(!lAutomato,aAdd(aParamBox, {1, "Valor de corte:"		,  nVlrCorte,  "@ER 999.99","Positivo()", "", ".T.", 50,  .F.}),)    
	Iif(!lAutomato,aAdd(aParamBox, {2, "Tipo de Calculo:"																						,""	,aTipCalc 	, 60, "", .T.}),) 


	if lAutomato .or. ParamBox(aParamBox, cTitulo,@aParam ,,, lCentered,,, /*oMainDlg */, , , )
		Iif(!lAutomato,Processa({|| PlANSProc(aParam) }, "Processando familias","Processando....",.T.),PlANSProc(aParam))
	EndIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} 

@author . .  
@version   V12
@since     
/*/
//------------------------------------------------------------------------------------------
Function PlANSProc(aParam)

	Local cAliasQry 	:= GetNextAlias()
	Local dDtRefBlq		:= cToD('01/'+aParam[11]+'/'+aParam[12])
	Local nQtdMesIni	:= 0
	Local lPeREj2       := ExistBlock("PANSREJ2")
	Local lPeRej3       := ExistBlock("PANSREJ3")
	Local lPeRej4       := ExistBlock("PANSREJ4")
	Local cCodEmp		:= ''
	Local cConEmp       := ''
	Local cSubCon       := ''
	Local dDataRefIni	:= dDtRefBlq
	
	//PE para procedure
	if ExistBlock( "PANSREJ1" )
		ExecBlock("PANSREJ1",.F.,.F.)
	endIf

	//Verificando a quantidade de registro para o processar o IndRegua
	BeginSql Alias cAliasQry
	
		SELECT  COUNT(*) AS CONTADOR
		FROM       %table:BA3%  BA3
		WHERE
			BA3_FILIAL       =  %xfilial:BA3% 
			AND BA3_CODINT   =  %exp:aParam[1]% 
			AND BA3_CODEMP   >= %exp:aParam[2]% 
			AND BA3_CODEMP   <= %exp:aParam[3]% 
			AND BA3_CONEMP   >= %exp:aParam[4]% 
			AND BA3_CONEMP   <= %exp:aParam[5]% 
			AND BA3_TIPOUS   =  %exp:aParam[8]% 
			AND BA3_MATRIC   >= %exp:aParam[13]% 
			AND BA3_MATRIC   <= %exp:aParam[14]% 
			AND (BA3_DATBLO  =  %Exp:" "%
			OR BA3_DATBLO    >= %Exp:dDtRefBlq%)
			AND BA3.%notDel%
	EndSql

    nQtdRec := (cAliasQry)->(CONTADOR)
    (cAliasQry)->(DbCloseArea())

    If nQtdRec = 0
        MsgStop("Não há dados com os parâmetros informados!!")
        Return
    Endif

	//Gerando os registros para o processamento
	BeginSql Alias cAliasQry
	
		SELECT  BA3.R_E_C_N_O_ AS BA3REC
		FROM       %table:BA3%  BA3
		WHERE
			BA3_FILIAL       =  %xfilial:BA3% 
			AND BA3_CODINT   =  %exp:aParam[1]% 
			AND BA3_CODEMP   >= %exp:aParam[2]% 
			AND BA3_CODEMP   <= %exp:aParam[3]% 
			AND BA3_CONEMP   >= %exp:aParam[4]% 
			AND BA3_CONEMP   <= %exp:aParam[5]% 
			AND BA3_TIPOUS   =  %exp:aParam[8]% 
			AND BA3_MATRIC   >= %exp:aParam[13]% 
			AND BA3_MATRIC   <= %exp:aParam[14]% 
			AND (BA3_DATBLO  =  %Exp:" "%
			OR BA3_DATBLO    >= %Exp:dDtRefBlq%)
			AND BA3.%notDel%
		ORDER BY
			BA3_FILIAL
			, BA3_CODINT
			, BA3_CODEMP
			, BA3_CONEMP
			, BA3_VERCON
			, BA3_SUBCON
			, BA3_VERSUB
			, BA3_MATRIC

	EndSql
	BG9->(DbSetOrder(1))
	BT5->(DbSetOrder(1))
	BQC->(DbSetOrder(1))
	BT6->(DbSetOrder(1))
	BI3->(DbSetOrder(1))

	PlsPtuLog('',LOGPLS)
    PlsPtuLog('',LOGPLS)
	PlsPtuLog('******************************************',LOGPLS)
	PlsPtuLog('Iniciando processamento ' + Dtos(Date()) + "-" + Time(),LOGPLS)
	PlsPtuLog('******************************************',LOGPLS)

	ProcRegua(nQtdRec)
    IncProc("Processando......") 

	
	While !(cAliasQry)->( EOF() )

		//Posiciona na familia                                      
   		BA3->( dbGoto((cAliasQry)->BA3REC) )

		BI3->(DbSeek(xFilial("BI3")+BA3->BA3_CODINT+BA3->BA3_CODPLA+BA3->BA3_VERSAO))

		//Contrato não regulamentados não se aplica a regra
		If BI3->BI3_APOSRG <> '1'
			Incproc()
	    	(cAliasQry)->( dbSkip() )
			Loop
		EndIf

		//Tratativa para grupo de cobrança
		If !Empty(aParam[18]) .and. BA3->BA3_GRPCOB <> aParam[18] 
			Incproc()
	    	(cAliasQry)->( dbSkip() )
			Loop
		endIf
			
		BG9->(DbSeek(xFilial("BG9")+BA3->BA3_CODINT+BA3->BA3_CODEMP))
		BT5->(DbSeek(xFilial("BT5")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON))
		BQC->(DbSeek(xFilial("BQC")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB))
		BT6->(DbSeek(xFilial("BT6")+BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB+BA3->BA3_CODPLA+BA3->BA3_VERSAO))


		If lPeREj4
			lContinua := Execblock("PANSREJ4",.F.,.F.,(cAliasQry)->BA3REC)
        	If !lContinua
				(cAliasQry)->( dbSkip() )
				Loop
        	Endif
		Endif
		
		aCliente := PLS770NIV(BA3->BA3_CODINT,BA3->BA3_CODEMP,;
										BA3->BA3_MATRIC,If(BA3->BA3_TIPOUS=="1","F","J"),;
										BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,;
										BA3->BA3_VERSUB,1)
	
		oFatANS  := PLCREDANS():New()


	    aRetUsr   := PLSLOADUSR(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,Str(Year(dDatabase),4) ,Str(Month(dDatabase),2))
	
		//Precisa verificar qual é o beneficiario mais novo da familia.
		// Exemplo : Beneficiario titular incluso em 01/11/2019
		//			 Beneficiario dependente incluso 01/02/2020
		//			Nesse  cenário  o beneficario dependente não iria gerar o crédito.
		aSort(aRetUsr,,,{|x,y| x[14] > y[14] })
		If Len(aRetUsr) > 0
			dDataRefIni := aRetUsr[1,14]
		Endif


		//Familias incluidas apos janeiro.
		If SUBSTR(DTOS(dDataRefIni),1,6) >= (aParam[12] + aParam[11])
			oFatANS:cMesBase   := StrZero(Month(dDataRefIni),2)
			oFatANS:cAnoBase   := StrZero(Year(dDataRefIni),4)
		Else
			oFatANS:cMesBase   := aParam[11]
			oFatANS:cAnoBase   := aParam[12]
		Endif

		oFatANS:cMesFat    := aParam[6]
		oFatANS:cAnoFat    := aParam[7]
		oFatANS:cMatric    := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC
		oFatANS:cLanReajus := aParam[9]
		oFatANS:cLanFaixa  := aParam[10]
		oFatANS:cTipPessoa := BA3->BA3_TIPOUS
		if len(aCliente) > 0
			oFatANS:cNivel := aCliente[1][18]
		endIf
		oFatANS:cConsidera 	:= aParam[15]
	    oFatANS:cMesBasReaj	:= aParam[16]
		oFatANS:cAnoBasReaj	:= aParam[17]
		oFatANS:cTipCalc	:= aParam[21]

		// Verifica se o contrato Coletivo por adesão ou empresarial, tabela BT5 posicionada .
		oFatANS:TipoContrato()

		If lPeREj2
			oFatANS:Mais29Vidas(lPeREj2)
		Else
			// Verifica se o contrato possui mais de 29 vidas, tabela BA3 posicionada para verificar a contagem 
			If BA3->BA3_CODEMP <> cCodEmp .Or. ;
				BA3->BA3_CONEMP <> cConEmp .Or. ; 
				BA3->BA3_SUBCON <> cSubCon

				oFatANS:Mais29Vidas(lPeREj2)
				cCodEmp := BA3->BA3_CODEMP
				cConEmp := BA3->BA3_CONEMP
				cSubCon := BA3->BA3_SUBCON
			Endif
		Endif	


		//Verifica se existe mais de um mes para gerar credito
		//Exemplo: mes de Faturamento 10 eu ja tinha gerado faturamento no mes 09 sem rodar a suspensaão
		//Proximo mes deve gerar os credditos do mes 09 e mes 10.
		If aParam[19] =="1"
			oFatANS:CredFaltantes()
		Endif	

		For nQtdMesIni := 1 to oFatANS:nTotGerFat
				
			oFatANS:calcDifFat(lPeRej3,aParam[20])
			oFatANS:cMesFat    :=  StrZero(Val(oFatANS:cMesFat)+1,2)
	   		Incproc()
		Next nQtdMesIni

	    (cAliasQry)->( dbSkip() )
	Enddo

	(cAliasQry)->(DbCloseArea())
	MsgInfo('Processamento finalizado')

Return
