#Include "Protheus.ch"
#Include "FINA989.ch"

Static nTamFil    := nil
Static nTamE2Pref := nil
Static nTamE2Num  := nil
Static nTamE2Par  := nil
Static nTamE2Tipo := nil
Static nTamE2For := nil
Static nTamE2Lj   := nil

Static nTamE1Pref := nil
Static nTamE1Num  := nil
Static nTamE1Par  := nil
Static nTamE1Tipo := nil
Static nTamE1Cli  := nil
Static nTamE1Lj   := nil

Static nTamFTDoc  := nil
Static nTamFTSer  := nil
Static nTamF2Tip  := nil
Static __nBx2030	:= 1
Static __nBx2040	:= 1

Static nTamNumPro := nil
Static nTamDescr  := nil
Static nTamIDSEJU := nil
Static nTamVara   := nil
Static nTamCodC18 := nil
Static cBDname	  := nil
Static cSrvType   := nil
Static _lPCCBaixa := nil
Static lAI0_INDPAA := nil

Static _oFINA989T := nil
Static __oBxFinCR := Nil
Static __oBxFinCP := Nil
Static lPagQry	  := .F.
Static lRecQry	  := .F.
Static cFilFiscal := nil	
Static cSubstSQL := ""
Static cIsNullSQL := ""
Static lExtFiscal := .F.
Static cAliasRQry := ""
Static cAliasPQry := ""
Static cAliaSE1   := ""
Static cAliaSE2   := ""
Static cConcat    := ""

Static __cBxFinCR	:= ""
Static __cBxFinCP	:= ""

Static nTamCCFNum := nil
Static aT157Env	  := {}
Static aT001ABEnv := {}

Static lGerou 	:= .F.
Static __lGer154 := .F.
Static __lBxFin
Static lAutomato := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA989 
Realiza a geração da TAFST1 dos titulso a pagar e receber

@param aFils Array das filiais selecionadas
@param aResWiz2 Array das resposta do wizard 2
@param aResWiz3 Array das resposta do wizard 3
@param aResWiz4 Array das resposta do wizard 4
@param aResWiz5 Array das resposta do wizard 5
@param oProcess objeto de regua de processamento se houver
@param lEnd recebido como referencia do MsNewProcess

@return lEnd Retorna .T. para indicar o fim de processamento

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------

Function FINA989(aFils,aResWiz2,aResWiz3,aResWiz4,aResWiz5,oProcess, lEnd)
Local lJob       := .F.

Default aFils := {}
Default aResWiz2 := {}
Default aResWiz3 := {}
Default aResWiz4 := {}
Default aResWiz5 := {}
Default lEnd := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando for chamado via JOB, as informacoes do WIZARD serao passadas como pergunte³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lJob := IsBlind() )
	Aadd(aFils,cFilAnt )
	
	Pergunte("FINTAF",.F.)
	
	// alimenta array das respostas da tela de Wizard 2
	aResWiz2		:= Array(10)
	aResWiz3		:= Array(12)
	aResWiz4		:= Array(3)
	aResWiz5		:= Array(8)
	// alimenta array das respostas da tela de Wizard 2
	aResWiz2[1]	:= MV_PAR01 // Considera data 1-Emissão Digita. (EMIS1) 2-Emissão Real (EMISSAO)
	aResWiz2[2]	:= MV_PAR02 // Data de 
	aResWiz2[3]	:= MV_PAR03 // Data Ate
	aResWiz2[4]	:= MV_PAR04 //1-Pessoa Física","2 -Pessoa Jurídica","3-Estrangeiro","4-Todas"
	aResWiz2[5]	:= MV_PAR05 // Cliente De 
	aResWiz2[6]	:= MV_PAR06	// Cliente Ate				
	aResWiz2[7]	:= MV_PAR07 // Loja De
	aResWiz2[8]	:= MV_PAR08	// Loja Ate		
	
	// alimenta array das respostas da tela de Wizard 3
	aResWiz3[1]	:= MV_PAR09	//// Considera data 1-Emissão Digita. (EMIS1) 2-Emissão Real (EMISSAO)
	aResWiz3[2]	:= MV_PAR10 //"Considera Data Pagamento "1-Data Vencto Real (VENCREA)", "2-Data Vencto (VENCTO)", "3-Data baixa (BAIXA)"
	aResWiz3[3]	:= MV_PAR11  // Data de 
	aResWiz3[4]	:= MV_PAR12 // Data Ate
	aResWiz3[5]	:= MV_PAR13 //1-Pessoa Física","2 -Pessoa Jurídica","3-Estrangeiro","4-Todas"
	aResWiz3[6]	:= MV_PAR14 // Fornecedor de 
	aResWiz3[7]	:= MV_PAR15	// Fornecedor ate 				
	aResWiz3[8]	:= MV_PAR16 // Loja de 
	aResWiz3[9]	:= MV_PAR17	// Loja ate		

	aResWiz4[1]	:= MV_PAR18 //Tipo de saída "1-Arquivo TXT", "2-Banco a Banco"
	aResWiz4[2]	:= MV_PAR19 // Diretório Arquivo Destino
	aResWiz4[3]	:= MV_PAR20 //Nome do arquivo destino RetFileName(MV_PAR24)
	
	aResWiz5[1] := If(MV_PAR21 == 1, .T., .F.) // EXPORTAR T001AB-PROCESSOS REFERENCIADOS
	aResWiz5[2] := If(MV_PAR22 == 1, .T., .F.) //  EXPORTAR T003-PARTICIPANTES
	aResWiz5[3] := If(MV_PAR23 == 1, .T., .F.) // EXPORTAR T154-CADASTRO DE TITULOS A RECEBER
	aResWiz5[4] := If(MV_PAR24 == 1, .T., .F.) // EXPORTAR T154-CADASTRO DE TITULOS A PAGAR
	aResWiz5[5] := If(MV_PAR25 == 1, .T., .F.) // EXPORTAR T154AA-TIPOS DE SERVICOS
	
	lAutomato := .T.
EndIf

If _lPCCBaixa == nil
	IniVarStat()
EndIf	

If Type("lBuild") <> "L"
	Private lBuild := .F.
EndIf
	 
lEnd := FinExpTAF(,,aFils,aResWiz2,aResWiz3,aResWiz4,aResWiz5,oProcess)
Return lEnd
		  
//-------------------------------------------------------------------
/*/{Protheus.doc} FinExpTAF 
Função para ser chamada tanto pela rotina do Wizard (FINA988) como pelas rotinas de inclusao/baixas do contas a pagar e receber 
para fazer a migração online.

@param nRecno Deve ser enviado o recno do registro da SE1 ou SE2, caso nao esteja processando pelo Wizard.
@param nCarteira  Deve ser enviado 1 para SE2 ou 2 para SE1, caso nao esteja processando pelo Wizard.
@param aFils Array das filiais selecionadas do Wizard
@param aResWiz2 Array das resposta do wizard 2
@param aResWiz3 Array das resposta do wizard 3
@param aResWiz4 Array das resposta do wizard 4
@param aResWiz5 Array das resposta do wizard 5
@param oProcess objeto de regua de processamento do Wizard
@param lEnd recebido como referencia do MsNewProcess do Wizard

@return lEnd Retorna .T. para indicar o fim de processamento

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
		  
Function FinExpTAF(nRecno,nCarteira,aFils,aResWiz2,aResWiz3,aResWiz4,aResWiz5,oProcess,aParticip, lExtReinf, lFiltReinf, cFiltInt, aLstT013 )

Local lRet  := .T.
Local nFil := 1
Local lOpenST1 	:= .F.
Local cFilBkp := cFilAnt
Local nCart := 1
Local lProcessa := .F.
Local cCtrlT154 := '0'
Local cNumNF	:= ''
Local cCodLojAnt := ""
Local dDtTit	:= CTOD("  /  /    ")

// para integração do taf
Private cTpSaida := "2"	// "1-TXT MILE","2-Banco-a-banco","3-Nativo"
Private cInc := "000001" // utilizado pela funcao do taf
Private cDirSystem := ""
Private cNomeArq	 := "" 	
Private nHdlTxt	  := 0
Private lGeraST2TAF := .F.

//respostas dos perguntes do wizard contas a receber
Private nTpEmData := 1
Private dDataEmDe  := CTOD("  /  /    ")
Private dDataEmAte := CTOD("  /  /    ")
Private nTpEmPessoa:= 1
Private cCliDe     := ""
Private cCliAte    := ""
Private cLojaCliDe  := ""
Private cLojaCliAte := ""

//respostas dos perguntes do wizard contas a receber
Private nTpPgEmis := 1
Private dDataPgDe  := CTOD("  /  /    ")
Private dDataPgAte := CTOD("  /  /    ")
Private nTpPgData := 1
Private nTpPgPessoa:= 1
Private cForDe		:= ""
Private cForAte		:= ""
Private cLojaForDe	:= ""
Private cLojaForAte	:= ""

Private lIntTAF    := FindFunction("TAFExstInt") .AND. TAFExstInt() // Verifica Intergacao NATIVA Protheus x TAF
Private lGerT001AB := .T.
Private lGerT003   := .T.
Private lGerT154AA := .T.
Private lGerT154CR := .T.
Private lGerT154CP := .T.
Private lGerT157   := .T.	
Private cAliasQry  := "" // alias da query do titulos
Private cAliasTRB := "" // alias da tabela temporaria

Default nRecno   := 0
Default nCarteira:= 3 
Default aFils    := {}
Default aResWiz2 := {} 
Default aResWiz3 := {}
Default aResWiz4 := {}
Default aLstT013 := {}

Default aResWiz5 := Array(8)
Default oProcess := Nil
Default aParticip := {}
Default lExtReinf := .f.
Default lFiltReinf := .F.
Default cFiltInt := "3"

If __lBxFin == Nil
	__lBxFin := .T.
EndIf

If _lPCCBaixa == nil
	IniVarStat()
EndIf	

If Len(aResWiz4) > 1
	cTpSaida := Alltrim(Str(aResWiz4[1]))
	cDirSystem := Alltrim(aResWiz4[2])
	cNomeArq :=  Alltrim(aResWiz4[3])
	If Len(aResWiz4) >  3
		nHdlTxt := aResWiz4[4]
	EndIf	 
EndIf

If !lAutomato
	If cTpSaida == "2" .and. !lExtFiscal //"2-Banco-a-banco"
			
		dbUseArea( .T.,"TOPCONN","TAFST1","TAFST1",.T.,.F.) //Abre Exclusivo
		
		lOpenST1 := Select("TAFST1") > 0
		
		If !lOpenST1
			Help(" ",1,"EXCLTAFST1",, STR0001,1,0) //"Não foi encontrada e/ou não foi possivel a abertura Exclusiva da tabela TAFST1 no mesmo Ambiente de ERP!"
			Return .F.
		Endif
	EndIf
EndIf
If Len(aResWiz2) > 1 // Parametros do titulo a receber
	nTpEmData 	:= aResWiz2[1]	//Considera Data 1 - Data de Contabilização (EMIS1) 2-Data de Emissão (EMISSAO)
	dDataEmDe 	:= aResWiz2[2]	//Data de
	dDataEmAte	:= aResWiz2[3]	//Data até
	nTpEmPessoa:= aResWiz2[4]	//Tipo de Pessoa	"1-Pessoa Física","2-Pessoa Jurídica","3-Todas"
	cCliDe     := aResWiz2[5]	//Cliente De
	cCliAte    := aResWiz2[6]	//Cliente Ate
	cLojaCliDe	:= aResWiz2[7]	//Loja De
	cLojaCliAte	:= aResWiz2[8]	//Loja Ate
	
EndIf

If Len(aResWiz3) > 1 // Parametros do titulo a pagar e baixas 

	nTpPgEmis	:= aResWiz3[1]	//Considera Data 1 - Emissão Digita. (EMIS1) 2-Emissão Real (EMISSAO)
	nTpPgData 	:= aResWiz3[2]	//Considera Data "1-Data Vencto Real (VENCREA)", "2-Data Vencto (VENCTO)", "3-Data baixa (BAIXA)"
	dDataPgDe 	:= aResWiz3[3]	//Data de
	dDataPgAte	:= aResWiz3[4]	//Data até
	nTpPgPessoa:= aResWiz3[5]	//Tipo de Pessoa	"1-Pessoa Física","2-Pessoa Jurídica","3-Todas"
	cForDe     := aResWiz3[6]	//Cliente De
	cForAte    := aResWiz3[7]	//Cliente Ate
	cLojaForDe	:= aResWiz3[8]	//Loja De
	cLojaForAte	:= aResWiz3[9]	//Loja Ate
	
EndIf

If Empty(aFils)
	Aadd(aFils,cFilAnt)
EndIf

If cTpSaida == "1" .and. nHdlTxt == 0
	//Cria arquivo
	nHdlTxt := FinCriaArq(cDirSystem,cNomeArq)
	If nHdlTxt <= 0 
		Return .F.
	EndIf	
	
EndIf

// se passar o recno, define os layouts que devem ser enviados
If nRecno > 0
	aResWiz5[1] := .T.
	aResWiz5[2] := .T.
	If nCarteira == 2
		aResWiz5[3] := .T.
		aResWiz5[4] := .F.
		aResWiz5[5] := .T.
	ElseIf nCarteira == 1
		aResWiz5[3] := .F.
		aResWiz5[4] := .T.
		aResWiz5[5] := .T.
	EndIf
EndIf


nCarteira := 3 // todas
If aResWiz5[3] .and. !aResWiz5[4]
	nCarteira := 2 // receber
ElseIf	 aResWiz5[4] .and. !aResWiz5[3]
	nCarteira := 1 // pagar
EndIf
lGerT001AB := aResWiz5[1]
lGerT003   := aResWiz5[2]
lGerT154CR := aResWiz5[3]
lGerT154CP := aResWiz5[4]
lGerT154AA := aResWiz5[5]
If Len(aResWiz5) > 7
	lGerT157 := aResWiz5[8]
EndIf	

If oProcess <> Nil
	oProcess:SetRegua1(Len(aFils))
EndIf
If !lAutomato
	If !lExtFiscal 
		//Cria o arquivo temporario
		CriaArqTMP(@cAliasTRB)
	EndIf	
EndIf
For nFil := 1 To Len( aFils )
		
	cFilAnt := aFils[ nFil ]
	
	If !lExtFiscal .or. lAutomato
		If oProcess <> Nil
			oProcess:IncRegua1(STR0002 + cFilAnt) //STR0002 "Processando Filial: "
			oProcess:SetRegua2(6)
			oProcess:IncRegua2( STR0003 + STR0004 ) //"Gerando Registro " "T001-Informações do contribuinte..."
		Endif		
	
		lRet := FExpT001()
	EndIf	
	
	
	For nCart := 1 To 2
		
		lProcessa := .F.
		
		
		//Cria query dos titulos a pagar
		If nCart == 1 .and.  (nCarteira == 1 .OR. nCarteira == 3)
		 	If Empty(cAliasPQry)
		 		cAliasPQry := GetNextAlias()
		 		MntQryPag(nRecno,@cAliasPQry, lExtReinf, lFiltReinf)
		 		FI8->(DbSetOrder(1))
			EndIf
			lProcessa := .T.
			cAliasQry := cAliasPQry
		EndIf 
		
		//Cria query dos titulos a receber
		If nCart == 2 .and. (nCarteira == 2 .OR. nCarteira == 3)
			If Empty(cAliasRQry)
				cAliasRQry := GetNextAlias()
				MntQryRec(nRecno,@cAliasRQry, lExtReinf)
				FI7->(DbSetOrder(1))
			EndIf	
			lProcessa := .T.
			cAliasQry := cAliasRQry
		EndIf	
		
		cCodLojAnt := ""
		
		If lProcessa
			(cAliasQry)->(DbGotop())
			While (cAliasQry)->(!Eof())
	
				
				//Desconsidera titulo originador de desdobramento a pagar
				If nCart == 1 .and. (cAliasQry)->DESDOBR == "S" .and. FI8->(MsSeek(xFilial("FI8")+(cAliasQry)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+COD+LOJA)))
					(cAliasQry)->(DBSkip())
					Loop
				EndIf	
				
				//Desconsidera titulo originador de desdobramento a receber	
				If nCart == 2 .and. (cAliasQry)->DESDOBR == "1" .and. FI7->(MsSeek(xFilial("FI7")+(cAliasQry)->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+COD+LOJA)))
					(cAliasQry)->(DBSkip())
					Loop
				EndIf
				
				//gera sempre o cadastro de obras se houver
				If lGerT157
					If oProcess <> Nil
						oProcess:IncRegua2( STR0003 +  STR0036 ) //"Gerando Registro " "T157-Cadastro de obras..."
					Endif
					lRet := FFinT157(nCart,cAliasQry)
				EndIf		
					
				If lGerT001AB
					If oProcess <> Nil
						oProcess:IncRegua2( STR0003 +  STR0005 ) //"Gerando Registro " "T001AB-Processos judiciais..."
					Endif		
			
					lRet := FFinT001AB(nRecno,nCart,(cAliasQry)->FK7_IDDOC)
					
				EndIf
				
				If lGerT003
					If oProcess <> Nil
						oProcess:IncRegua2( STR0003 +  STR0006) //"Gerando Registro " "T003-Participantes..."
					Endif		
					If cCodLojAnt <> (cAliasQry)->(COD + LOJA)
						lRet := FFinT003(nRecno,nCart, cAliasQry, @aParticip, lFiltReinf, cFiltInt, aLstT013 )
						cCodLojAnt := (cAliasQry)->(COD + LOJA)
					EndIf
					If cTpSaida == "1"
						If nCart == 1 .And. ( __nBx2040 > 1 .And. Select(__cBxFinCP) > 0 )
							(__cBxFinCP)->(DbGoTop())
							While !((__cBxFinCP)->(Eof()))
								dDtTit := StoD(Iif(nTpPgEmis == 1, (__cBxFinCP)->E2_EMIS1,(__cBxFinCP)->E2_EMISSAO ))
								If ( dDtTit < dDataPgDe .Or. dDtTit > dDataPgAte )
									FFinT003(nRecno,nCart, __cBxFinCP, @aParticip, lFiltReinf, cFiltInt, aLstT013 )
								EndIf

								(__cBxFinCP)->(DbSkip())
							EndDo
						ElseIf ( __nBx2030 > 1 .And. Select(__cBxFinCR) > 0 )
							(__cBxFinCR)->(DbGoTop())
							While !((__cBxFinCR)->(Eof()))
								dDtTit := StoD(Iif(nTpEmData == 1, (__cBxFinCR)->E1_EMIS1,(__cBxFinCR)->E1_EMISSAO ))
								If ( dDtTit < dDataEmDe .Or. dDtTit > dDataEmAte )
									FFinT003(nRecno,nCart, __cBxFinCR, @aParticip, lFiltReinf, cFiltInt, aLstT013 )
								EndIf
								(__cBxFinCR)->(DbSkip())
							EndDo
						EndIf	
					EndIf
				EndIf
					
				If lGerT154CR .and.  nCart == 2
					If oProcess <> Nil	
						oProcess:IncRegua2( STR0003 +  STR0007) //"Gerando Registro " "T154-Titulos a receber..."
					EndIf
			
					//Exportação INSS contas a receber e pagar
					// Registro 2010-2030
					lRet := FFinT154(nRecno, nCart, cAliasQry, oProcess, @cCtrlT154, @cNumNF, __cBxFinCR, (cAliasQry)->FK7_IDDOC)
					
				EndIf
				
				If lGerT154CP .and.  nCart == 1
					If oProcess <> Nil	
						oProcess:IncRegua2( STR0003 +  STR0008) //"Gerando Registro " "T154-Titulos a pagar..."
					EndIf
					//Exportação INSS contas a pagar 
					// Registro 2020-2040
					lRet := FFinT154(nRecno, nCart, cAliasQry, oProcess, @cCtrlT154, @cNumNF, __cBxFinCP, (cAliasQry)->FK7_IDDOC)
				EndIf

				(cAliasQry)->(DBSkip())
				
				// Verifica se ‚ outro documento e atualiza controle de criacao do Reg 154
				If 	(nCart == 1 .and. lGerT154CP .and. (cAliasQry)->(E2_NUM+E2_PREFIXO) <> cNumNF) .or. ;
					(nCart == 2 .and. lGerT154CR .and. (cAliasQry)->(E1_NUM+E1_PREFIXO) <> cNumNF) 
					cCtrlT154 := '0'
					If cTpSaida == "2" .AND. Len(aDadosST1) > 0
						FConcST1()
					EndIf
					
				EndIf
			EndDo
			If !lExtFiscal .or. lAutomato
				If nCart == 1
					(cAliasPQry)->(DBCloseArea())
					cAliasPQry := ""
				Else
					(cAliasRQry)->(DBCloseArea())
					cAliasRQry := ""
				EndIf	
			EndIf
		EndIf
	Next nCart
	aT157Env := {}	
	aT001ABEnv := {}
Next nFil

If __lBxFin .And. lGerT003
	For nCart := 1 To 2
		cCodLojAnt := ""
		If nCart == 1 .And. ( __nBx2040 > 1 .And. Select(__cBxFinCP) > 0 )
			(__cBxFinCP)->(DbGoTop())
			While !((__cBxFinCP)->(Eof()))
				dDtTit := StoD(Iif(nTpPgEmis == 1, (__cBxFinCP)->E2_EMIS1,(__cBxFinCP)->E2_EMISSAO ))

				If cCodLojAnt <> (__cBxFinCP)->(COD + LOJA)
					lRet := FFinT003(nRecno,nCart, __cBxFinCP, @aParticip, lFiltReinf, cFiltInt, aLstT013 )
					cCodLojAnt := (cAliasQry)->(COD + LOJA)
				EndIf

				If ( dDtTit < dDataPgDe .Or. dDtTit > dDataPgAte )
					FFinT154(nRecno, nCart, __cBxFinCP, oProcess, @cCtrlT154, @cNumNF, __cBxFinCP, (__cBxFinCP)->FK7_IDDOC)
				Else
					(__cBxFinCP)->(DbSkip())
				EndIf

				// Verifica se é outro documento e atualiza controle de criacao do Reg 154
				If 	(__cBxFinCP)->(E2_NUM+E2_PREFIXO) <> cNumNF
					cCtrlT154 := '0'
					If cTpSaida == "2" .AND. Len(aDadosST1) > 0
						FConcST1()
					EndIf
					
				EndIf
			EndDo
		ElseIf ( __nBx2030 > 1 .And. Select(__cBxFinCR) > 0 )
			(__cBxFinCR)->(DbGoTop())
			While !((__cBxFinCR)->(Eof()))
				dDtTit := StoD(Iif(nTpEmData == 1, (__cBxFinCR)->E1_EMIS1,(__cBxFinCR)->E1_EMISSAO ))
				If cCodLojAnt <> (__cBxFinCR)->(COD + LOJA)
					lRet := FFinT003(nRecno,nCart, __cBxFinCR, @aParticip, lFiltReinf, cFiltInt, aLstT013 )
					cCodLojAnt := (cAliasQry)->(COD + LOJA)
				EndIf

				If ( dDtTit < dDataEmDe .Or. dDtTit > dDataEmAte )
					FFinT154(nRecno, nCart, __cBxFinCR, oProcess, @cCtrlT154, @cNumNF, __cBxFinCR, (__cBxFinCR)->FK7_IDDOC)
				Else
					(__cBxFinCR)->(DbSkip())
				EndIf

				If (__cBxFinCR)->(E1_NUM+E1_PREFIXO) <> cNumNF
					cCtrlT154 := '0'
					If cTpSaida == "2" .AND. Len(aDadosST1) > 0
						FConcST1()
					EndIf
					
				EndIf				
			EndDo
		EndIf

	Next
	__lBxFin	:= .F.
EndIf

If cTpSaida == '1' .and. (!lExtFiscal .or. lAutomato)
	FClose(nHdlTxt)
Endif	

If lOpenST1 .and. (!lExtFiscal .or. lAutomato)
	TAFST1->(DbCloseArea())
EndIf	
If !lAutomato
	If !lExtFiscal 
	
		If (cAliasTRB)->(RecCount()) > 0
			If MsgYesNo(STR0035) //"Deseja imprimir o log dos títulos enviados ao TAF?"
				FINR989(cAliasTRB)
			EndIf
		EndIf
	
		FTmpClean()
	EndIf	
EndIf
cFilAnt := cFilBkp
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FinCriaArq 
Validação e criação do arquivo TXT 

@param cDirSystem Diretorio onde deverá ser criado o arquivo
@param cNomeArq
@return nHdl numero do Handle da criação do arquivo 

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function FinCriaArq(cDirSystem,cNomeArq)
Local nHdl := 0
Local cNomeDir
Local nRetDir := 0

If Right(cDirSystem,1) <> "\"
	cDirSystem := cDirSystem + "\"
EndIf
If Lower( Right( Alltrim( cNomeArq ), 4 ) ) <> ".txt"
	cNomeArq := ( cNomeArq + ".txt" )
EndIf
	
cNomeDir := cDirSystem + cNomeArq
If !File( cNomeDir )	
	
	If !ExistDir(cDirSystem)
		nRetDir := MakeDir( cDirSystem )
	EndIf
	If nRetDir != 0
		cNomeDir := ""
		Help( ,,"CRIADIR",,  STR0009 + cValToChar( FError() ) , 1, 0 ) //"Não foi possível criar o diretório. Erro: "
	EndIf
Else
	If lAutomato .Or. ( !lAutomato .And. MsgYesNo(STR0010) ) //"Já existe um arquivo de mesmo nome, deseja substituir?"
		nRetDir := FErase(cNomeDir)
		
		If nRetDir != 0
			cNomeDir := ""
			Help( ,,"DELARQ",,  STR0011 + cValToChar( FError() ) , 1, 0 )//"Não foi possível recriar o arquivo. Erro: "
		EndIf
	Else	
		cNomeDir := ""
	EndIf		
EndIf

If !Empty( cNomeDir )
	nHdl :=  MsFCreate( cNomeDir )
	
	If nHdl < 0
		Help( ,,"CRIAARQ",, STR0012 + cValToChar( FError() ) , 1, 0 ) //"Não foi possível criar o arquivo. Erro: "
	EndIf	
	
EndIf
Return nHdl

//-------------------------------------------------------------------
/*/{Protheus.doc} FExpT001 
Gera os registros do Layout T001 - Filial 

@return lRet Retorna .t. para final de execução

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Function FExpT001()
Local lRet := .T.
Local aRegs    := {}
Local cReg     := "T001" // código do registro no TAF
	
		aRegs := {}
		( Aadd( aRegs, {  ;
		cReg,; // 1 Registro T001-Cadastro de empresas
		cEmpAnt+cFilAnt,;// 2 FILIAL
		"",;// 3	EMAIL
		"",;// 4	CÓDIGO FEBRABAN
		"",;// 5	CRT
		"",;// 6	MATRIZ
		"",;// 7	DESC_RZ_SOCIAL
		"",;// 8	INSTAL_ANP
		"",;// 9	SEGMENTO
		"",;// 10	IND_ESCRITURACAO
		"",;// 11	CLASSTRIB
		"",;// 12	IND_ACORDO
		"",;// 13	NMCTT
		"",;// 14	CPFCTT
		"",;// 15	FONEFIXO
		"",;// 16	FONECEL
		"",;// 17	IDEEFR
		"",;// 18	CNPJEFR
		"",;// 19	IND_DESONERACAO
		"",;// 20	IND_SIT_PJ
		"",;// 21	INI_PER
		"",;// 22	FIM_PER
		"",;// 23	IND_ASSOC_DESPORT
		"",;// 24	IND_PROD_RURAL
		"" }))// 25 	EXECPAA
		
		
		FConcTxt( aRegs,nHdlTxt )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTpSaida == "2" 
			FConcST1()
		EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FExpT001AB 
Gera os registros do Layout T001AB - Processos 

@return lRet Retorna .t. para final de execução

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function FFinT001AB(nRecno,nCarteira, cIdDoc)
Local cQuery := ""
Local lRet := .T.

Local aRegs    := {}
Local cReg     := "T001AB" // código do registro no TAF
Local cFilialTAF:= ""
Local lGeraT1AB := .T.
Local cDataIni	:= ""
Local cDataFin	:= ""

Default nRecno := 0
Default nCarteira := 3

DBSelectArea("CCF")
CCF->(DBSetOrder(1)) // CCF_FILIAL, CCF_NUMERO, CCF_TIPO, R_E_C_N_O_, D_E_L_E_T_

DBSelectArea("FKG")
FKG->(DBSetOrder(2)) //FKG_FILIAL, FKG_IDDOC, FKG_TPIMP, R_E_C_N_O_, D_E_L_E_T_
FKG->(DBSeek(xFilial("FKG") + cIdDoc + "INSS"))


While FKG->(!Eof()) .and. Alltrim(FKG->(FKG_FILIAL+FKG_IDDOC+FKG_TPIMP)) == Alltrim(xFilial("FKG") + cIdDoc + 'INSS')
	
	If Alltrim(FKG->FKG_TPATRB) == '004' // Processo judicial
		If AScan(aT001ABEnv,{ |x| x[1] == Alltrim(FKG->FKG_NUMPRO) }) == 0 .and. CCF->(DBSeek(xFilial("CCF") + padr(FKG->FKG_NUMPRO, nTamCCFNum) +  FKG->FKG_TPPROC)) 
			Aadd(aT001ABEnv,{ Alltrim(FKG->FKG_NUMPRO) })
			lGeraT1AB := .T.
			If !Empty(CCF->CCF_DTINI)
				cDataIni := STRZERO(MONTH(CCF->CCF_DTINI),2)+STRZERO(YEAR(CCF->CCF_DTINI),4) 
			EndIf

			If !Empty(CCF->CCF_DTFIN)
				cDataFin := STRZERO(MONTH(CCF->CCF_DTFIN),2)+STRZERO(YEAR(CCF->CCF_DTFIN),4) 
			EndIf
			
			If lIntTAF
				cFilialTAF:= FTafGetFil( allTrim( cEmpAnt ) + allTrim( cFilAnt ) , {} , "C1G" )
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se no TAF o registro existe e não ha alteracoes. ³
				//³Caso exista e nao haja alteracoes nos campos,NAO geramos  ³
				//³o registro na TAFST1 para a integracao.                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If C1G->( MsSeek( cFilialTAF + PadR( CCF->CCF_NUMERO , nTamNumPro ) + CCF->CCF_TIPO ))
					
					If C1G->C1G_DESCRI  == PadR(CCF->CCF_DESCJU, nTamDescr).And. ;
						Substr(C1G->C1G_SECJUD,1,nTamIDSEJU) == CCF->CCF_IDSEJU .And. ;
						C1G->C1G_VARA   == PadR(CCF->CCF_IDVARA, nTamVara)  .And. ;
						C1G->C1G_DTSENT == SToD(CCF->CCF_DTSENT).And. ;
						C1G->C1G_DTADM  == SToD(CCF->CCF_DTADM) 
						
						If !Empty(CCF->CCF_NATJU)
							If C18->( MsSeek( xFilial("C18") + C1G->C1G_ACAJUD ) )
								If C18->C18_CODIGO == PadR( CCF->CCF_NATJU , nTamCodC18)
									lGeraT1AB := .F.
								EndIf
							EndIf
						Else
							lGeraT1AB := .F.
						EndIf
						
						If !Empty(CCF->CCF_NATAC )
							If C19->( MsSeek( xFilial("C19") + C1G->C1G_INRCFE ) )
								If C19->C19_CODIGO == PadR(CCF->CCF_NATAC , nTamCodC18)
									lGeraT1AB := .F.
								EndIf
							EndIf
						Else
							lGeraT1AB := .F.
						EndIf
						
					Endif
					
				EndIf
				
			EndIf
			
			If lGeraT1AB
				lGerou := .T.
				
				aRegs := {}
				CCF->( Aadd( aRegs, {  cReg,; //001-REGISTRO):
				CCF_NUMERO,; //002-NUM_PROC
				CCF_TIPO,; //003-IND_PROC
				CCF_DESCJU,; //004-DESCRI_RESUMIDA
				CCF_IDSEJU,; //005-ID_SEC_JUD
				CCF_IDVARA,; //006-ID_VARA
				CCF_NATJU,;  //007-IND_NAT_ACAO_JUSTICA
				CCF_DESCJU,; //008-DESC_DEC_JUD
				CCF_DTSENT,; //009-DT_SENT_JUD
				CCF_NATAC,;  //010-IND_NAT_ACAO_RECEITA
				CCF_DTADM,;  //011-DT_DEC_ADM
				CCF_TPCOMP,; //012-TP_PROC 1-Judicial 2 - Administrativo
				CCF_INDAUT,; // 015-IND_AUTORIA
				CCF_UF,; 	 // 013-UF_VARA
				CCF_CODMUN,; //014-COD_MUN_VARA
				cDataIni,; //016-DT_INI_VAL FORMATO MMAAAA
				cDataFin;  //017-DT_FIN_VAL FORMATO MMAAAA
				 } ) )

				FConcTxt( aRegs,nHdlTxt )
				
				
			EndIf
			
			
			//GERAR O BLOCO T001AO
			
			While CCF->(!Eof()) .and. CCF->(CCF_FILIAL + CCF_NUMERO + CCF_TIPO) == xFilial("CCF") + padr(FKG->FKG_NUMPRO, nTamCCFNum) + FKG->FKG_TPPROC
			
				cReg := "T001AO" 
				aRegs := {}
				CCF->( Aadd( aRegs, {  cReg,; //REGISTRO):
				CCF_INDSUS,; //COD_SUSP
				CCF_SUSEXI,; //IND_SUSPENS
				CCF_DTADM,; //DT_DEC_ADM
				IIf(CCF_MONINT == "1", "S", "N"); //IND_DEPOSITO
				 } ) )
				
				FConcTxt( aRegs,nHdlTxt )
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				CCF->(DBSkip())
				
			EndDo
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cTpSaida == "2" 
				FConcST1()
			EndIf	
			
		EndIf
	EndIf
	
	FKG->(DBSkip())
		
EndDo


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FFinT003 
Gera os registros do Layout FExpT003 - Participantes (Fornecedores e Clientes) 

@return lRet Retorna .t. para final de execução

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Function FFinT003(nRecno,nCart, cAliasQry, aParticip, lFiltReinf, cFiltInt, _aListT003  )

Local cCodPart   := ""
Local cCgc       := ""

Local cTpPessoa  := ""
Local cCodMun    := ""
Local cEndereco  := ""
Local cNum       := ""
Local cComplem   := ""
Local cBairro    := ""
Local cUF        := ""
Local cCEP       := ""
Local cTel       := ""
Local cPais      := ""
Local cNome		 := ""
Local cDDD		 := ""
Local cFax		 := ""
Local cEmail	 := ""
Local cInscr	 := ""
Local cSuframa	 := ""
Local cIndNif    := ""
Local cNif		 := ""
Local cPaisEX	 := ""
Local cEndEX	 := ""
Local cNumEx	 := ""
Local cComplEX	 := ""
Local cBaiEX	 := "" 
Local cMunEX	 := ""
Local cCepEX	 := ""
Local cRelFont   := ""
Local cRamoAtv	 := ""
Local cDt		 := ""
Local nPOsicao	 := 0
Local cContrib	 := ""
Local cIndCP	 := ""
Local cIseImun	 := ""
Local cEstex	 := ""
Local cTelre	 := ""
Local cMotNif	 := ""
Local cNifex	 := ""
Local cTrBex	 := ""

Local aGetEnd    := {}
Local aRegs      := {}
Local cReg         := "T003"

Local cQuery 		:= ""
Local lRet := .T.

Local cFilialTAF:= ""
Local lGeraT003 := .T.
Local cINDCPRB := ""
Local cExecPAA := ""
Local cDesport := ""

Default nRecno := 0
Default nCart := 1
Default aParticip  := {}
Default _aListT003 := {}
Default lFiltReinf := .F.
Default cFiltInt   := "3"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montando a Estrutura da Query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cCodPart  := ""
cCpf      := ""
cCgc      := ""
cTpPessoa := ""
cCodMun   := ""
aGetEnd	  := {}


If lFiltReinf .And. (cFiltInt $ "1|3" .Or. empty(cFiltInt))
	If nCart == 1 // A PAGAR
		DbSelectArea("SA2")
		DBSetOrder(1) //A2_FILIAL, A2_COD, A2_LOJA, R_E_C_N_O_, D_E_L_E_T_
		If SA2->(MsSeek( xFilial("SA2") +  (cAliasQry)->COD + (cAliasQry)->LOJA))
			cCodPart := (cAliasQry)->COD + (cAliasQry)->LOJA

			IF lBuild
				nPosicao   := FindHash(oHashT003, cCodPart)
			Else
				nPosicao := aScan(aParticip,{|aX| aX[2]==cCodPart})
			EndIf	

			If nPosicao == 0

				IF lBuild
					AddHash(oHashT003, cCodPart, nPosicao)
				EndIf

				RegT003Pos("SA2", @aParticip )
			EndIf
		EndIf
	Else
		DbSelectArea("SA1")
		DBSetOrder(1) //A1_FILIAL, A1_COD, A1_LOJA, R_E_C_N_O_, D_E_L_E_T_
		If SA1->(MsSeek( xFilial("SA1") +  (cAliasQry)->COD + (cAliasQry)->LOJA))
			cCodPart := (cAliasQry)->COD + (cAliasQry)->LOJA

			IF lBuild
				nPosicao   := FindHash(oHashT003, cCodPart)
			Else
				nPosicao := aScan(aParticip,{|aX| aX[2]==cCodPart})
			EndIf	

			If nPosicao == 0

				IF lBuild
					AddHash(oHashT003, cCodPart, nPosicao)
				EndIf
				
				RegT003Pos("SA1", @aParticip )
			EndIf
		EndIf
	EndIf
Else
	If nCart == 1 // A PAGAR
		DbSelectArea("SA2")
		DBSetOrder(1) //A2_FILIAL, A2_COD, A2_LOJA, R_E_C_N_O_, D_E_L_E_T_
		If SA2->(DBSeek( xFilial("SA2") +  (cAliasQry)->COD + (cAliasQry)->LOJA))
			cCodPart := RetPartTAF("FOR", (cAliasQry)->COD, (cAliasQry)->LOJA)
			
			If SA2->A2_TIPO == "F" // Fisica
				cCpf := SA2->A2_CGC 
				cTpPessoa := "1"
			ElseIf SA2->A2_TIPO == "J"  // Juridica
				cCgc := SA2->A2_CGC
				cTpPessoa := "2"
			Else	//estrangeiro
				cCpf := ""
				cCGC := ""
				If Len(AllTrim(SA2->A2_CGC)) == 11
					cTpPessoa := "1"
				ElseIf Len(AllTrim(SA2->A2_CGC)) == 14
					cTpPessoa := "2"
				EndIf
				cIndNif	:= IIf(!Empty(SA2->A2_NIFEX),"1", IIf( SA2->A2_MOTNIF == "1", "2", "3")  )
				cNif	:= SA2->A2_NIFEX
				cRelFont:= SA2->A2_BREEX
				cPaisEX := SA2->A2_PAISEX
				aGetEnd 	:= FisGetEnd( SA2->A2_LOGEX, SA2->A2_EST )
				cEndEX := aGetEnd[1]
				cNumEx := Iif( !Empty( aGetEnd[2]) , aGetEnd[3], "SN" )
				cComplEX := SA2->A2_COMPLR
				cBaiEX := SA2->A2_BAIEX
				cMunEX := SA2->A2_CIDEX
				cCepEX := SA2->A2_POSEX
			EndIf
			
			aGetEnd 	:= FisGetEnd( SA2->A2_END, SA2->A2_EST ) // função do fiscal q separa o endereço
			cEndereco	:= aGetEnd[1] 
			cNum 		:= Iif( !Empty( aGetEnd[2]) , aGetEnd[3], "SN" )
			cComplem	:= SA2->A2_COMPLEM
			cBairro		:= SA2->A2_BAIRRO
			cUF 		:= SA2->A2_EST
			cCEP 		:= SA2->A2_CEP
			cTel 		:= SA2->A2_TEL
			cNome		:= SA2->A2_NOME
			cDDD		:= SA2->A2_DDD
			cFax		:= SA2->A2_FAX
			cEmail		:= SA2->A2_EMAIL
			cInscr		:= SA2->A2_INSCR
			cDt			:= ""
			cContrib 	:= SA2->A2_CONTRIB
			cSuframa	:= ""
			cDesport	:= Iif(SA2->A2_DESPORT == "1", "1","2")
			cINDCPRB	:= Iif(SA2->A2_CPRB == "2" .or. Empty(SA2->A2_CPRB), "0", "1")  
			cExecPAA	:= ""
			cRamoAtv	:= IIf(!Empty(SA2->A2_TIPORUR),"4","")
			
			If SA2->A2_EST == "EX"
				cCodMun := "99999"
			Else
				cCodMun := SA2->A2_COD_MUN
			EndIf
			
			If Empty(SA2->A2_CODPAIS)
				cPais := ""
			Else
				cPais := padl(Alltrim(SA2->A2_CODPAIS),5,"0")
			EndIf

			If SA2->(FieldPos("A2_INDCP")) > 0
				cIndCP	 := SA2->A2_INDCP 
			EndIf	

			If SA2->(FieldPos("A2_ISEIMUN")) > 0
				cIseImun := SA2->A2_ISEIMUN
			EndIf

			If SA2->(FieldPos("A2_ESTEX")) > 0
				cEstex	 := SA2->A2_ESTEX
			EndIf

			If  SA2->(FieldPos("A2_TELRE")) > 0
				cTelre 	:= SA2->A2_TELRE
			EndIf

			If  SA2->(FieldPos("A2_NIFEX")) > 0 .and. SA2->(FieldPos("A2_MOTNIF")) > 0
				cMotNif := IIf(!Empty(SA2->A2_NIFEX),"1",IIf(SA2->A2_MOTNIF=='1','2',IIf(SA2->A2_MOTNIF=='2','3',SA2->A2_MOTNIF)))
			EndIf

			If  SA2->(FieldPos("A2_NIFEX")) > 0
				cNifex := SA2->A2_NIFEX
			EndIf

			If SA2->(FieldPos("A2_TRBEX")) > 0
				cTrBex := SA2->A2_TRBEX
			EndIf
			
		EndIf		
			
	Else // A Receber
		DbSelectArea("SA1")
		DBSetOrder(1) //A1_FILIAL, A1_COD, A1_LOJA, R_E_C_N_O_, D_E_L_E_T_
		If SA1->(DBSeek( xFilial("SA1") +  (cAliasQry)->COD + (cAliasQry)->LOJA))
			cCodPart := RetPartTAF("CLI", (cAliasQry)->COD, (cAliasQry)->LOJA)
			If SA1->A1_PESSOA == "F"
				cCpf := SA1->A1_CGC 
				cTpPessoa := "1"
			ElseIf SA1->A1_PESSOA == "J" 
				cCgc := SA1->A1_CGC
				cTpPessoa := "2"
			EndIf	
			
			aGetEnd 	:= FisGetEnd( SA1->A1_END, SA1->A1_EST ) // função do fiscal q separa o endereço
			cPais 		:= SA1->A1_PAIS
			cEndereco	:= aGetEnd[1] 
			cNum 		:= Iif( !Empty( aGetEnd[2]) , aGetEnd[3], "SN" )
			cComplem	:= SA1->A1_COMPLEM
			cBairro		:= SA1->A1_BAIRRO
			cUF 		:= SA1->A1_EST
			cCEP 		:= SA1->A1_CEP
			cTel 		:= SA1->A1_TEL
			cNome		:= SA1->A1_NOME
			cDDD		:= SA1->A1_DDD
			cFax		:= SA1->A1_FAX
			cEmail		:= SA1->A1_EMAIL
			cInscr		:= SA1->A1_INSCR
			cDt			:= SA1->A1_DTCAD
			cSuframa	:= SA1->A1_SUFRAMA
			cDesport	:= ""
			cContrib	:= ""
			cIndCP	 	:= ""
			cIseImun	:= ""
			cEstex	 	:= ""
			cTelre	 	:= ""
			cMotNif		:= ""
			cNifex	 	:= ""
			cTrBex	 	:= ""
			If SA1->A1_EST == "EX"
				cCodMun := "99999"
			Else
				cCodMun := SA1->A1_COD_MUN
			EndIf		

			If Empty(SA1->A1_CODPAIS)
				cPais := ""
			Else
				cPais := padl(Alltrim(SA1->A1_CODPAIS),5,"0")
			EndIf
			cINDCPRB := ""
			If lAI0_INDPAA
				cExecPAA := Posicione("AI0",1, SA1->(A1_FILIAL + A1_COD + A1_LOJA), "AI0_INDPAA")
			EndIf	
			cExecPAA := Iif(cExecPAA == "1", "1", "0")
			cRamoAtv	:= ""
			
		EndIf

	EndIf
		
	lGeraT003 := .T.
	If lIntTAF
	
		DbSelectArea("C1H")   
		C1H->(DbSetOrder(1))
		
		DbSelectArea("C07")   
		C07->(DbSetOrder(3))
		
		DbSelectArea("C08")   
		C08->(DbSetOrder(3))
		
		DbSelectArea("C09")   
		C09->(DbSetOrder(3))
		
		DbSelectArea("AIF")	
		cFilialTAF:= FTafGetFil( allTrim( cEmpAnt ) + allTrim( cFilAnt ) , {} , "C1H" )
		dbSelectArea(cAliasQry)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se no TAF o registro existe e não ha alteracoes. ³
		//³Caso exista e nao haja alteracoes nos campos,NAO geramos  ³
		//³o registro na TAFST1 para a integracao.                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If C1H->( MsSeek( cFilialTAF + PadR( cCodPart , TAMSX3("C1H_CODPAR")[1] ) ) )

			If  Alltrim(C1H->C1H_PPES)   == Alltrim(cTpPessoa)  .And. ;
				Alltrim(C1H->C1H_NOME)   == Alltrim(cNome)  .And. ;
				Alltrim(C1H->C1H_END)    == Alltrim(cEndereco)   .And. ;
				Alltrim(C1H->C1H_NUM)    == Alltrim(cNum)   .And. ;
				Alltrim(C1H->C1H_COMPL)  == Alltrim(cComplem) .And. ;
				Alltrim(C1H->C1H_BAIRRO) == Alltrim(cBairro).And. ;
				Alltrim(C1H->C1H_CEP)    == Alltrim(cCEP)   .And. ;
				Alltrim(C1H->C1H_DDD)    == Alltrim(cDDD)   .And. ;
				Alltrim(C1H->C1H_FONE)   == Alltrim(cTel)  .And. ;
				Alltrim(C1H->C1H_FAX)    == Alltrim(cFax)   .And. ;
				Alltrim(C1H->C1H_EMAIL)  == Alltrim(cEmail) .And. ;
				Alltrim(C1H->C1H_CNPJ)   == Alltrim(cCGC)  .And. ;
				Alltrim(C1H->C1H_CPF)    == Alltrim(cCPF)   .And. ;
				Alltrim(C1H->C1H_IE)     == Alltrim(cInscr)    .And. ;
				Alltrim(C1H->C1H_SUFRAM) == Alltrim(cSuframa) 
				
				If !Empty(cCodMun) .and. !Empty(C1H->C1H_CODMUN)
					If C07->( MsSeek( xFilial("C07") + C1H->C1H_CODMUN ) )
						If Alltrim(C07->C07_CODIGO) == Alltrim(cCodMun)
							lGeraT003 := .F.
						Else	
							lGeraT003 := .T.
						EndIf
					EndIf
				Else
					lGeraT003 := .T.
				EndIf
				
				If !lGeraT003 .and. !Empty(cPais) .and. !Empty(C1H->C1H_CODPAI)
					If C08->( MsSeek( xFilial("C08") + C1H->C1H_CODPAI ) )
						If Alltrim(C08->C08_CODIGO) == Alltrim( cPais )
							lGeraT003 := .F.
						EndIf
					EndIf
				Else
					lGeraT003 := .T.
				EndIf

				If !lGeraT003 .and. !Empty(cUF) .and. !Empty(C1H->C1H_UF)
					If C09->( MsSeek( xFilial("C09") + C1H->C1H_UF ) )
						If C09->C09_UF == cUF
							lGeraT003 := .F.
						EndIf
					EndIf
				Else
					lGeraT003 := .T.
				EndIf
				
				If !lGeraT003 .and. ( Alltrim(C1H->C1H_PAISEX) == Alltrim(cPaisEX) .AND. ;
					Alltrim(C1H->C1H_LOGEXT) == Alltrim(cEndEX)  .AND. ;
					Alltrim(C1H->C1H_NUMEXT) == Alltrim(cNumEx)  .AND. ;
					Alltrim(C1H->C1H_COMEXT) == Alltrim(cComplEX)  .AND. ;
					Alltrim(C1H->C1H_BAIEXT) == Alltrim(cBaiEX)  .AND. ;
					Alltrim(C1H->C1H_NMCEXT) == Alltrim(cMunEX)  .AND. ;
					Alltrim(C1H->C1H_CDPOSE) == Alltrim(cCepEX)  .AND. ;
					Alltrim(C1H->C1H_RELFON) == Alltrim(cRelFont) )
					lGeraT003 := .F.
				Else 
					lGeraT003 := .T.
				EndIf
				

			EndIf

		EndIf
		
	EndIf

	IF lBuild
		nPosicao   := FindHash(oHashT003, cCodPart)
		if nPosicao == 0
			nPosicao := aScan(_aListT003,{|aX| AllTrim(aX[1])==AllTrim(cCodPart)})
		endif
	Else
		nPosicao := aScan(aParticip,{|aX| aX[2]==cCodPart})
	EndIf

	If nPosicao == 0
		IF lBuild
			AddHash(oHashT003, cCodPart, nPosicao)
		EndIf

		If lGeraT003
			lGerou := .T.
			
			aRegs := {}
			(cAliasQry)->( Aadd( aRegs, {  ;
			cReg,; 		// 001-TIPO REGISTRO
			cCodPart,;	// 002-CODIGO PARTIPANTE
			cNome,;		// 003-NOME
			cPais,;		// 004-COD_PAIS
			cCgc,;		// 005-CNPJ
			cCpf,;		// 006-CPF
			cInscr,;	// 007-IE
			cCodMun,;	// 008-COD_MUN
			cSuframa,;	// 009-SUFRAMA
			"",;		// 010-TP_LOGRA
			cEndereco,; // 011-ENDERECO
			cNum,; 		// 012-NUM
			cComplem,;	// 013-COMPLEM_END
			"",;		// 014-TP_BAIRRO
			cBairro,;	// 015-BAIRRO	
			cUF,;		// 016-UF
			cCEP,;		// 017-CEP
			cDDD,;		// 018-DDD
			cTel,;		// 019-FONE
			cDDD,;		// 020-DDD
			cFax,;		// 021-FAX
			cEmail,;	// 022-EMAIL
			cDt,; 		// 023-DT_INCLUSAO
			cTpPessoa,;	// 024-TP_PESSOA
			"",;		// 025-RAMO_ATIV
			"",;		// 026-COD_INST_ANP
			"",;		// 027-COD_ATIV
			cPaisEX,;	// 28-COD_PAIS_EXT
			cEndEX,;	// 29-LOGRAD_EXT
			cNumEx,;	// 30-NR_LOGRAD_EXT
			cComplEX,;	// 31-COMPLEM_EXT
			cBaiEX,;	// 32-BAIRRO_EXT
			cMunEX,;	// 33-NOME_CIDADE_EXT
			cCepEX,;	// 34-COD_POSTAL_EXT
			"",;		// 35-DT_LAUDO_MOLEST_GRAVE
			cRelFont,;	// 36-REL_FONTE_PAG_RESID_EXTERIOR
			"",;		// 37-INSCR_MUNICIPAL 
			"",;		// 38-SIMPLES_NACIONAL
			"",; 		//39-ENQUADRAMENTO
			"",; 		//40-OBSOLETO
			cINDCPRB,; 	//41-INDCPRB
			"",; 		//42-CODTRI
			cExecPAA,; 	//43-EXECPAA
			cDesport,;	//44-IND_ASSOC_DESPORT
			cContrib,;	//45-CONTRIBUINTE
			cIndCP,;	//46-INDOPCCP
			cIseImun,;	//47-ISENCAO_IMUNIDADE 
			cEstex,;	//48-ESTADO_EXT
			cTelre,; 	//49-TELEFONE_EXT
			cMotNif,;	//50-INDICATIVO_NIF
			cNifex,;	//51-NIF
			cTrBex } ) ) //52-FORMA_TRIBUTACAO

			FConcTxt( aRegs, nHdlTxt )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cTpSaida == "2"
				FConcST1()
			EndIf
		EndIf
	EndIf
EndIf


Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FFinT154
Gera os registros do Layout FExpT154 de titulos a receber com INSS - Fatura/recibo 

@param nRecno - Caso queira exportar somente um recno em especifico
@return lRet Retorna .t. para final de execução

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
//Função de exportação de INSS de contas a receber e a pagar 
Function FFinT154(nRecno, nCart, cAliasQry, oProcess, cCtrlT154, cRefNF, cBxFin, cIdDoc )
Local lRet := .T.
Local aRegs		:= {}
Local cReg			:= "T154"
Local cNumTit	    := ""
Local cNumNF		:= ""
Local cPrefixo		:= ""
Local cSerie		:= ""
Local cTipoNF		:= ""
Local cParcela		:= ""
Local cContaAnlt	:= ""
Local cTpRepasse	:= ""
Local cTpServico	:= ""
Local nVlrBruto	:= 0
Local nVlrParc	:= 0
Local nVlrMat		:= 0
Local nVlrAlim	:= 0
Local nVlrTrans	:= 0
Local nVlrSub		:= 0
Local nVlrDedPr	:= 0
Local nVlrAdiPr	:= 0
Local nVlrBaseIN	:= 0
Local nVlrCP		:= 0
Local nVlrGilrat	:= 0
Local nVlrSenar	:= 0
Local nVlrRetenc:= 0
Local cTpProc	:= ""

Local nAPos15		:= 0
Local nAPos20		:= 0
Local nAPos25		:= 0
Local nVlrAdic := 0
Local cCodPart := ""
Local dDataEmis := CTOD("  /  /    ")
Local cHist		:= ""

Local aAreaSF2 := SF2->(GetArea())
Local cEspecie	:= ""
Local lCalcIssBx	:= IsIssBx("P")
Local lGera154	:= .T.
Local cCNO		:= ""
Local cTpInsc	:= ""
Local cIndProc	:= ""
Local aProcJud	:= {}
Local nI		:= 0

Default nRecno := 0
Default cCtrlT154 := '0'
Default cRefNF := ''

DbSelectArea("FKG")
FKG->(DBSetOrder(2)) //FKG_FILIAL+FKG_IDDOC+FKG_TPIMP

DbSelectArea("SFT")
SFT->(DBSetOrder(1)) //FT_FILIAL, FT_TIPOMOV, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA, FT_ITEM, FT_PRODUTO, R_E_C_N_O_, D_E_L_E_T_

DbSelectArea("CCF")
CCF->(DBSetOrder(1)) // CCF_FILIAL, CCF_NUMERO, CCF_TIPO, R_E_C_N_O_, D_E_L_E_T_

nVlrBruto  := 0
nVlrParc := 0
nVlrRetenc:= 0
cNumNF    := ""
cSerie     := ""
cTipoNF    := "" 		
nVlrCP     := 0
nVlrGilrat := 0
nVlrSenar  := 0
cEspecie := ""

nVlrMat		:= 0
nVlrAlim	:= 0
nVlrTrans	:= 0
nVlrDedPr	:= 0
nVlrAdiPr	:= 0
nVlrSub	:= 0

cTpProc	:= ""

nVlrAdic := 0
nAPos15  := 0
nAPos20  := 0
nAPos25  := 0 

DbSelectArea("FKG")
FKG->(DbSeek(xFilial("FKG") + (cAliasQry)->FK7_IDDOC + "INSS"))

While FKG->(!Eof()) .and. Alltrim(FKG->(FKG_FILIAL+FKG_IDDOC+FKG_TPIMP)) == Alltrim(xFilial("FKG") + (cAliasQry)->FK7_IDDOC + 'INSS')

	// APLICA 1 - BASE e DEDUÇÃO
	If FKG->FKG_APLICA == '1' .and. FKG->FKG_DEDACR == '1'
		If Alltrim(FKG->FKG_TPATRB) == '001' // MATERIAL
			nVlrMat += FKG->FKG_VALOR
		ElseIf Alltrim(FKG->FKG_TPATRB) == '002' // ALIMENTAÇAO
			nVlrAlim += FKG->FKG_VALOR
		ElseIf Alltrim(FKG->FKG_TPATRB) == '003' // TRANSPORTE
			nVlrTrans += FKG->FKG_VALOR
		EndIf

	ElseIf FKG->FKG_APLICA == '2' .and. FKG->FKG_DEDACR == '1'		//APLICA 2 - VALOR E DEDUCAO
	 	 	
	 	 If Alltrim(FKG->FKG_TPATRB) == '004' // Processo Judicial
	 	 
	 	 	If CCF->(DBSeek(xFilial("CCF") + padr(FKG->FKG_NUMPRO, nTamCCFNum) +  FKG->FKG_TPPROC)) 
	 	 		
	 	 		While CCF->(!Eof()) .and. CCF->(CCF_FILIAL + CCF_NUMERO + CCF_TIPO ) == xFilial("CCF") + padr(FKG->FKG_NUMPRO, nTamCCFNum) +  FKG->FKG_TPPROC
	 	 			If Empty(FKG->FKG_CODSUS) .or. Alltrim(CCF->CCF_INDSUS) == Alltrim(FKG->FKG_CODSUS) 
			 	 		If CCF->CCF_TRIB == '1' // Colocar tratamento para apsentadoria normal
			 	 		
			 	 			cTpProc := "1"
			 	 			cIndProc   := CCF->CCF_TIPO
					
			 	 			nVlrDedPr += FKG->FKG_VALOR
			 	 		
			 	 			AAdd(aProcJud,{cTpProc,cIndProc, FKG->FKG_VALOR, FKG->FKG_NUMPRO,'13', FKG->FKG_CODSUS}) // depois q decidir sobre o cod_SUSP incluir no array 
			 	 		ElseIf CCF->CCF_TRIB == '2' // Colocar tratamento para apsentadoria especial
				 		
			 	 			cTpProc := "2" 
				 			cIndProc   := 	CCF->CCF_TIPO
				 			
				 			nVlrAdiPr += 	FKG->FKG_VALOR
				 		
				 			AAdd(aProcJud,{cTpProc,cIndProc, FKG->FKG_VALOR,FKG->FKG_NUMPRO,'13', FKG->FKG_CODSUS}) // depois q decidir sobre o cod_SUSP incluir no array
				 		EndIf
			 		EndIf	
			 		CCF->(DBskip())
			 	EndDo	
			 	
			EndIf	
		 	
	 	 ElseIf Alltrim(FKG->FKG_TPATRB) == '005' // Subcontratada
	 	 	nVlrSub += FKG->FKG_VALOR	
	 	 EndIf
	EndIf
	
	If FKG->FKG_APLICA == '2' .and. FKG->FKG_DEDACR != '1' // Aplicacao por Valor e Acrescimo
		If Alltrim(FKG->FKG_TPATRB) == '007' //APOSENTADORIA ESPECIAL 15 ANOS                     
			If FKG->FKG_APLICA == '2'
				nAPos15 += FKG->FKG_BASECA
				nVlrAdic += FKG->FKG_VALOR
			EndIf
		ElseIf Alltrim(FKG->FKG_TPATRB) == '008' //APOSENTADORIA ESPECIAL 20 ANOS
			If FKG->FKG_APLICA == '2'
				nAPos20 += FKG->FKG_BASECA
				nVlrAdic += FKG->FKG_VALOR
			EndIf
		ElseIf Alltrim(FKG->FKG_TPATRB) == '009' //APOSENTADORIA ESPECIAL 25 ANOS                         
		 	If FKG->FKG_APLICA == '2'
		 		nAPos25 += FKG->FKG_BASECA
		 		nVlrAdic += FKG->FKG_VALOR
		 	EndIF 
		EndIf
	EndIf	
	
	FKG->( DBSkip() )
EndDo 	

If nCart == 1 // A PAGAR

	cPrefixo := (cAliasQry)->E2_PREFIXO
	
	cParcela := padr(Alltrim((cAliasQry)->E2_PARCELA), nTamE2Par)
	cCodPart := RetPartTAF("FOR", (cAliasQry)->COD, (cAliasQry)->LOJA)
	dDataEmis:= Iif(nTpEmData == 1, (cAliasQry)->E2_EMIS1,(cAliasQry)->E2_EMISSAO )
	cHist	 := (cAliasQry)->E2_HIST
	cContaAnlt := (cAliasQry)->E2_CONTAD
	cTpRepasse := (cAliasQry)->FKF_TPREPA
	cTpServico := If(!Empty((cAliasQry)->FKF_TPSERV), "1" + padl((cAliasQry)->FKF_TPSERV, 8 ,"0"), "")
	cTipoFat := "3" // 3-Titulo Avulso	2 - Desdobramento
	nVlrBruto := 0 
	If alltrim((cAliasQry)->E2_ORIGEM) $ "MATA461|MATA460|MATA103|MATA100"
		cNumNF	:= padr(Alltrim((cAliasQry)->E2_NUM), nTamFTDoc)
		cSerie	:= padr(Alltrim((cAliasQry)->E2_PREFIXO), nTamFTSer)
		If SFT->(DBseek(xFilial("SFT") + "E" +  cSerie + cNumNF + (cAliasQry)->COD + (cAliasQry)->LOJA ) )
		
			cEspecie := AModNot( SFT->FT_ESPECIE )
                
			//Tratamento para NFS
            If Empty(cEspecie)
            	cEspecie := "01"
            EndIf
			
			cTipoFat := "1" // Titulo oriundo de nota
			cNumNF 	:= padr(Alltrim(cNumNF), nTamE1Num)
			dDataEmis := SFT->FT_EMISSAO
			If cRefNF <> cNumNF+cSerie 
				cRefNF := cNumNF+cSerie
				cCtrlT154 := '0'
			EndIf
			
			cCtrlT154 := IF(cCtrlT154 == '0','1',cCtrlT154)
			cNumTit  := Alltrim((cAliasQry)->E2_NUM)
			nVlrBruto := 0
			While SFT->(!Eof()) .and. SFT->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA) ==  (xFilial("SFT") + "E" +  cSerie + cNumNF + (cAliasQry)->COD + (cAliasQry)->LOJA)
				nVlrBruto += SFT->FT_VALCONT
				SFT->(DBSkip())
			EndDo
		Else
			If EMPTY(cTpServico) .AND. EMPTY(cTpRepasse)
				lGera154 := .F.
			EndIf
			cNumNF := ""
			cSerie  := ""		
			cEspecie := "" 
			cCtrlT154 := '0'
			cNumTit  := Alltrim((cAliasQry)->E2_NUM) + Iif(!Empty(cParcela), "-" + cParcela, "" )
		EndIf
	Else	
		cCtrlT154 := '1'
		cRefNF := ''
		cNumTit  := Alltrim((cAliasQry)->E2_NUM) + Iif(!Empty(cParcela), "-" + cParcela, "" )
	EndIf	
	
	nVlrBaseIN := (cAliasQry)->E2_BASEINS - nVlrMat - nVlrAlim - nVlrTrans
	
	nVlrParc := (cAliasQry)->(E2_VALOR + E2_INSS + (If( (cAliasQry)->A2_CALCIRF == "2" ,0,E2_IRRF))+;
				If(!lCalcIssBx,E2_ISS,0) + E2_SEST + If(_lPCCBaixa,0,E2_PIS+E2_COFINS+E2_CSLL))
	
	If Empty(cNumNF)
		nVlrBruto := nVlrParc
	EndIf

	If (cAliasQry)->ED_CALCINS == "S" .and. (cAliasQry)->A2_RECINSS == "S"
		If nVlrMat + nVlrTrans + nVlrAlim > 0 
			nVlrRetenc := (cAliasQry)->E2_INSS
		Else
			nVlrRetenc := (cAliasQry)->FKF_ORIINS
		Endif
	Else	
		nVlrRetenc := (cAliasQry)->E2_INSS
	EndIf
	
Else // A RECEBER

	cPrefixo := (cAliasQry)->E1_PREFIXO
	
	cParcela := padr(Alltrim((cAliasQry)->E1_PARCELA), nTamE1Par)
	cCodPart := RetPartTAF("CLI", (cAliasQry)->COD, (cAliasQry)->LOJA)
	dDataEmis:= Iif(nTpEmData == 1, (cAliasQry)->E1_EMIS1,(cAliasQry)->E1_EMISSAO )
	cHist	 := (cAliasQry)->E1_HIST
	cContaAnlt := (cAliasQry)->E1_CONTA
	cTpRepasse := (cAliasQry)->FKF_TPREPA
	cTpServico := If(!Empty((cAliasQry)->FKF_TPSERV), "1" + padl((cAliasQry)->FKF_TPSERV, 8 ,"0"), "")
	cTipoFat := "3" // 3-Titulo Avulso	2 - Desdobramento
	nVlrBruto := 0 
	If alltrim((cAliasQry)->E1_ORIGEM) $ "MATA461|MATA460|MATA103|MATA100"
		cNumNF	:= padr(Alltrim((cAliasQry)->E1_NUM), nTamFTDoc)
		cSerie		:= padr(Alltrim((cAliasQry)->E1_SERIE), nTamFTSer)
		If SFT->(DBseek(xFilial("SFT") + "S" +  cSerie + cNumNF + (cAliasQry)->COD + (cAliasQry)->LOJA ) )

			cEspecie := AModNot( SFT->FT_ESPECIE )
                
			//Tratamento para NFS
            If Empty(cEspecie)
            	cEspecie := "01"
            EndIf

			cTipoFat := "1" // Titulo oriundo de nota
			cNumNF 	:= padr(Alltrim(cNumNF), nTamE1Num)
			dDataEmis := SFT->FT_EMISSAO
			If cRefNF <> cNumNF+cSerie 
				cRefNF := cNumNF+cSerie
				cCtrlT154 := '0'
			EndIf
			
			cCtrlT154 := IF(cCtrlT154 == '0','1',cCtrlT154)
			cNumTit  := Alltrim((cAliasQry)->E1_NUM)
			nVlrBruto := 0
			While SFT->(!Eof()) .and. SFT->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA) ==  (xFilial("SFT") + "S" +  cSerie + cNumNF + (cAliasQry)->COD + (cAliasQry)->LOJA)
				nVlrBruto += SFT->FT_VALCONT
				SFT->(DBSkip())
			EndDo
			
		Else
			If EMPTY(cTpServico) .AND. EMPTY(cTpRepasse)
				lGera154 := .F.
			EndIf
			cNumNF := ""
			cSerie  := ""		
			cEspecie := "" 
			cCtrlT154 := '0'
			cNumTit  := Alltrim((cAliasQry)->E1_NUM) + Iif(!Empty(cParcela), "-" + cParcela, "" )
		EndIf
	Else	
		cCtrlT154 := '1'
		cRefNF := ''
		cNumTit  := Alltrim((cAliasQry)->E1_NUM) + Iif(!Empty(cParcela), "-" + cParcela, "" )
	EndIf	
	
	
	nVlrBaseIN := (cAliasQry)->E1_BASEINS - nVlrMat - nVlrAlim - nVlrTrans
	
	nVlrParc := (cAliasQry)->E1_VALOR
	If Empty(cNumNF)
		nVlrBruto := nVlrParc
	EndIf
	
	If (cAliasQry)->ED_CALCINS == "S" .and. (cAliasQry)->A1_RECINSS == "S"
		IF nVlrMat + nVlrTrans + nVlrAlim > 0 
			nVlrRetenc := (cAliasQry)->E1_INSS			
		Else
			nVlrRetenc := (cAliasQry)->FKF_ORIINS
		ENDIF
	Else	
		nVlrRetenc := (cAliasQry)->E1_INSS
	EndIf
EndIf

If !Empty((cAliasQry)->FKF_CNO)
	DbSelectArea("SON")
	SON->(DBSetOrder(1)) //ON_FILIAL, ON_CODIGO, R_E_C_N_O_, D_E_L_E_T_
	If SON->(DBSeek(xFilial("SON") + (cAliasQry)->FKF_CNO ))
		cCNO := Alltrim(SON->ON_CNO)
		cTpInsc := Alltrim(SON->ON_TPINSCR)
	EndIf
EndIf

If lGera154 .AND. cCtrlT154 == '1'
	__lGer154 := lGerou := .T.
	
	aRegs := {}
	cReg         := "T154"
	Aadd( aRegs, {  ;
	cReg,; 					//01-TIPO REGISTRO
	cNumTit,;				//02-NUMERO
	cPrefixo,; 				//03-SERIE
	cCodPart ,; 			//04-COD_PARTICIPANTE
	dDataEmis,; 			//05-EMISSAO
	Iif(nCart==1, "0","1"),;					//06-NATUREZ 0-PAGAR 1-RECEBER
	cHist,; 				//07-OBSERVACAO
	cEspecie,;				//08-CODMOD_DOC
	cNumNF,; 				//09-NUM_DOC
	cSerie,; 				//10-SER_DOC
	"",;					//11-SUBSER_DOC
	nVlrBruto,	;			//12-VLR_BRUTO
	"",;					//13-TP_PROC_RET_PRIN_N_EFET_INSS-obsoleto
	"",;					//14-NR_PROC_RET_PRIN_N_EFET_INSS-obsoleto
	"",;					//15-TP_PROC_RET_ADC_N_EFET_INSS-obsoleto
	"",;					//16-NR_PROC_RET_ADC_N_EFET_INSS-obsoleto
	"",;					//17-COD_CONT_ANAL-obsoleto
	"",;					//18-TP_REPASSE-obsoleto
	"",;					//19-TP_PROC_COMERC_RURAL-obsoleto
	"",;					//20-NR_PROC_COMERC_RURAL-obsoleto
	0,;						//21-VLR_CP-obsoleto
	0,;						//22-VLR_GILRAT-obsoleto
	0,;						//23-VLR_SENAR-obsoleto
	0,;						//24-VLR_CP_SUSP-obsoleto
	0,;						//25-VLR_RAT_SUSP-obsoleto
	0,;						//26-VLR_SENAR_SUSP-obsoleto
	0,;						//27-VLR_PREV_PRIVADA-obsoleto
	0,;						//28-VLR_FAPI-obsoleto
	0,;						//29-VLR_FUNPRESP-obsoleto
	0,;						//30-VLR_PENSAO_ALI-obsoleto
	"",;					//31-TP_PROC_RRA-obsoleto
	"",;					//32-NUM_PROC_RRA-obsoleto
	"",;					//33-NAT_RRA-obsoleto
	0,;						//34-QTD_MESES_RRA-obsoleto
	"",;					//35-NUM_PROC_DM-obsoleto
	"",;					//36-IND_ORIG_REC-obsoleto
	"",;					//37-CNPJ_ORI_REC_DM-obsoleto
	cTipoFat,;				//38-TIPO_RECIBO_FATURA
	"",;					//39-COD_SERV_MUN - 
	"",;					//40-LOC_PRESTACAO 
	"",;					//41-OBSOLETO
	"",;					//42-OBSOLETO
	"",;					//43-TIPDOC	
	cCNO,;					//44-NR_INSC_ESTAB
	cTpInsc})				//45-TP_INSCRICAO		
	
	
	FConcTxt( aRegs, nHdlTxt)
	cCtrlT154 := '2'

	If (!EMPTY(cTpServico) .OR. !EMPTY(cTpRepasse))  .AND. lGerT154AA
		If oProcess <> Nil	
			oProcess:IncRegua2( STR0003 + STR0013 ) //"Gerando Registro " "T154AA-Tipo de Serviço..."
		EndIf
	
		aRegs := {}
		cReg         := "T154AA"
				
		Aadd( aRegs, {  ;
		cReg,; 					//01-TIPO REGISTRO
		cTpServico,;			//02-TIP_SERV
		nVlrBaseIN,; 			//03-VLR_BASE_CALCULO_INSS
		nVlrRetenc, ; 			//04-VALOR_TRIBUTO_INSS
		nVlrSub,; 				//05-VLR_RET_SERV_SUBCONTRAT_INSS
		nVlrDedPr,;				//06-VLR_RET_PRIN_N_EFET_INSS
		nAPos15,; 				//07-VLR_SER_15_ANOS
		nAPos20,;				//08-VLR_SER_20_ANOS
		nAPos25,; 				//09-VLR_SER_25_ANOS
		nVlrAdic,; 				//10-VLR_ADICIONAL
		nVlrAdiPr,;				//11-VLR_RET_ADV_N_EFET_INSS
		cTpRepasse,	;					//12-TPREPASSE
		IIf(!Empty(cTpRepasse), Posicione("SX5",1,xFilial("SX5") + "0G" + cTpRepasse, "X5_DESCRI"),""),;					//13-DESCRECURSO
	 	IIf(!Empty(cTpRepasse),nVlrBruto,0),;						//14-VLRBRUTO
		IIf(!Empty(cTpRepasse),nVlrRetenc,0);						//15-VLRRETAPUR
		})
				
		FConcTxt( aRegs, nHdlTxt)
	EndIf
	
	For ni := 1 to Len(aProcJud)
		
		aRegs := {}
		cReg         := "T154AF" // Indicativo de Suspensão por processo judicial/administrativo
		Aadd( aRegs, {  ;
		cReg,; 						//01-TIPO REGISTRO
		aProcJud[ni][1] ,;			//02-TP_PROC
		aProcJud[ni][4],; 			//03-NUM_PROC
		aProcJud[ni][2],; 			//04-IND_PROC
		aProcJud[ni][6],; 			//05-COD_SUS
		aProcJud[ni][3],;			//06-VAL_SUS
		aProcJud[ni][5]; 			//07-COD_TRIB
		})	
		FConcTxt( aRegs, nHdlTxt)
	Next ni
		
EndIf	// lGera154 

If cCtrlT154 <> '0' 
	// Gera o registro T154AB: Parcelas da fatura/recibo - 
	// Para titulo avulso será 1 para 1
	If oProcess <> Nil	
		oProcess:IncRegua2( STR0003 + STR0014 ) //"Gerando Registro " "T154AB-Parcelas da fatura/recibo..."
	EndIf
	
	aRegs := {}
	cReg         := "T154AB"
	Aadd( aRegs, {  ;
	cReg,; 						//01-TIPO REGISTRO
	Iif(Empty(cParcela),"1",cParcela) ,;			//02-NUM_PARC
	nVlrParc}) 				//03-VLR_PARC
	
	//gera log
	F989Addlog(cFilAnt,Iif(nCart==1, "P","R"),cPrefixo,Iif(nCart==1, (cAliasQry)->E2_NUM,(cAliasQry)->E1_NUM),cParcela,Iif(nCart==1, (cAliasQry)->E2_TIPO,(cAliasQry)->E1_TIPO),;
	(cAliasQry)->COD,(cAliasQry)->LOJA,dDataEmis,cTpServico,cTpRepasse, nVlrParc, nVlrBaseIN, nVlrRetenc, nVlrMat+nVlrAlim+nVlrTrans+nVlrSub,nVlrDedPr)
	
	FConcTxt( aRegs, nHdlTxt)

	If !Empty(cBxFin) .And. Select(cBxFin) > 0
		(cBxFin)->(DbGoTop())
		If (cBxFin)->(DbSeek(cIdDoc))
			While (cBxFin)->FK7_IDDOC == cIdDoc
				aRegs := {}
				cReg         := "T154AC" // Indicativo de Suspensão por processo judicial/administrativo
				Aadd( aRegs, {  ;
				cReg,; 						//01-TIPO REGISTRO
				(cBxFin)->DTBXFIN ,;			//02-DATA DA BAIXA
				(cBxFin)->VLBXFIN;		//03-VALOR DA BAIXA
				})
			
				FConcTxt( aRegs, nHdlTxt)
				(cBxFin)->(DbSkip())
			EndDo
		Else
			(cBxFin)->(DbSkip())
		EndIf
	EndIf

EndIf

RestArea(aAreaSF2)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FExpT999 
Gera os registros do Layout T999 de exclusao de registro pai no TAF.
Este é utilizado somente se houver exclusao do titulo a pagar/receber.

@param nRecno - Caso queira exportar somente um recno em especifico
@param nCarteira - 1 para carteira a pagar , 2 para a receber 

@return lRet Retorna .t. para final de execução

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Function FExpT999(nRecno, nCarteira, cLayout)
Local cChave	:= ""
Local cReg 	:= "T999"
Local aRegs	:= {}
Local lOpenST1 := .T.

Private cTpSaida := "2" // utilizado na FConcTxt para definir se integração será banco a banco ou txt
Private lGeraST2TAF := .F.
Private aDadosST1 := {} //utilizado pelas funcoes do TAF na gravacao dos dados na ST1
Private cInc := "000001" // utilizado pela funcao do taf

Default nRecno := 0
Default nCarteira := 1
Default cLayout := "T154"

If Select("TAFST1") == 0
	dbUseArea( .T.,"TOPCONN","TAFST1","TAFST1",.T.,.F.) //Abre Exclusivo
	
	lOpenST1 := Select("TAFST1") > 0
	
	If !lOpenST1
		Help(" ",1,"EXCLTAFST1",, STR0001,1,0) //" Não foi encontrada e/ou não foi possivel a abertura Exclusiva da tabela TAFST1 no mesmo Ambiente de ERP!"
		Return .F.
	Endif
EndIf

If nCarteira == 1 // Pagar
	SE2->(DbGoto(nRecno))
	If cLayout == "T154"
	
		cChave := cLayout+"|" +;//REGISTRO
			SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA) +"|"+;//NUMERO
			RetPartTAF("FOR", SE2->E2_FORNECE, SE2->E2_LOJA) +"|" +; //COD_PARTICIPANTE
			"1"			//NATUREZ 1-PAGAR 2-RECEBER
	EndIf


Else //Receber
	SE1->(DbGoto(nRecno))
	If cLayout == "T154"
	
		cChave := cLayout+"|" +;//REGISTRO
			SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA +"|"+;//NUMERO
			RetPartTAF("CLI", SE1->E1_CLIENTE, SE1->E1_LOJA) +"|" +; //COD_PARTICIPANTE
			"2"			//NATUREZ 1-PAGAR 2-RECEBER
	EndIf
EndIf

//F987Incl(cReg, cChave)
 
Aadd( aRegs, {  ;
		cReg,; 				// TIPO REGISTRO
		cChave})				// Chave
							
FConcTxt( aRegs)

FConcST1()

If lOpenST1
	TAFST1->(DbCloseArea())
EndIf	


Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} CriaArqTMP() 
Cria o arquivo de trabalho para armazenar os registros enviados ao TAF para relatorio

@param cAliasTRB,caracter, alias da tabela temporaria

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------

Static Function CriaArqTMP(cAliasTRB)
Local aCampos := {}
Local aCamposPg := {}

If _oFINA989T == Nil
	// TRB de titulos	
	aCampos :=	{}
	cAliasTRB := GetNextAlias() // alias da tabela temporaria
	aAdd (aCampos, {"FILIAL"	,	"C",	nTamFil						,	0})
	aAdd (aCampos, {"RECPAG"	,	"C",	01							,	0})
	aAdd (aCampos, {"PREFIXO"	,	"C",	Max(nTamE2Pref,nTamE1Pref) 	,	0})
	aAdd (aCampos, {"NUMERO"	,	"C",	Max(nTamE1Num,nTamE2Num)	,	0})
	aAdd (aCampos, {"PARCELA"	,	"C",	Max(nTamE1Par,nTamE2Par)	,	0})
	aAdd (aCampos, {"TIPO"		,	"C",	Max(nTamE1Tipo,nTamE2Tipo)	,	0})
	aAdd (aCampos, {"CLIFOR"	,	"C",	Max(nTamE1Cli,nTamE2For)	,	0})
	aAdd (aCampos, {"LOJA"		,	"C",	Max(nTamE1Lj,nTamE2Lj)		,	0})
	aAdd (aCampos, {"EMISSAO"	,	"D",	8							,	0})
	aAdd (aCampos, {"TPSERV"	,	"C",	02							,	0})
	aAdd (aCampos, {"TPREPASSE"	,	"C",	02							,	0})
	aAdd (aCampos, {"VLBRUTO"	,	"N",	18							,	2})
	aAdd (aCampos, {"VLBASEINSS",	"N",	18							,	2})
	aAdd (aCampos, {"VLINSS"	,	"N",	18							,	2})
	aAdd (aCampos, {"DEDINSS"	,	"N",	18							,	2})
	aAdd (aCampos, {"DEDPROCJD"	,	"N",	18							,	2})
	
	
	//Deleta a tabela temporária no banco de dados, caso já exista	
	FTmpClean()
	
	// Criação da Tabela Temporßria >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	_oFINA989T := FWTemporaryTable():New( cAliasTRB )  
	_oFINA989T:SetFields(aCampos) 
	_oFINA989T:AddIndex("1", {"FILIAL","RECPAG","PREFIXO","NUMERO","PARCELA","TIPO","CLIFOR","LOJA","EMISSAO"})
	_oFINA989T:AddIndex("2", {"FILIAL","RECPAG","CLIFOR","LOJA","EMISSAO","PREFIXO","NUMERO","PARCELA","TIPO"})
	_oFINA989T:Create() 	

EndIf	

/*
	//TRB de pagamentos
	aCamposPg :=	{}
	aAdd (aCamposPg, {"FILIAL"		,	"C",	nTamFil						,	0})
	aAdd (aCamposPg, {"RECPAG"		,	"C",	01								,	0})
	aAdd (aCamposPg, {"PREFIXO"		,	"C",	Max(nTamE2Pref,nTamE1Pref) 	,	0})
	aAdd (aCamposPg, {"NUMERO"		,	"C",	Max(nTamE1Num,nTamE2Num)		,	0})
	aAdd (aCamposPg, {"PARCELA"		,	"C",	Max(nTamE1Par,nTamE2Par)		,	0})
	aAdd (aCamposPg, {"TIPO"			,	"C",	Max(nTamE1Tipo,nTamE2Tipo)	,	0})
	aAdd (aCamposPg, {"CLIFOR"		,	"C",	Max(nTamE1Cli,nTamE2For)		,	0})
	aAdd (aCamposPg, {"LOJA"			,	"C",	Max(nTamE1Lj,nTamE2Lj)		,	0})
	aAdd (aCamposPg, {"PAGTO"		,	"D",	8								,	0})
	aAdd (aCamposPg, {"CODRET"		,	"C",	04								,	0})
	aAdd (aCamposPg, {"VLBAIXA"		,	"N",	18								,	2})
	aAdd (aCamposPg, {"VLBASEIMP"	,	"N",	18								,	2})
	aAdd (aCamposPg, {"VLIMPOSTO"	,	"N",	18								,	2})
	
	cArqTrb2 := CriaTrab(aCampos,.T.)
	dbUseArea( .T.,, cArqTrb2, "TRBPGTO", .F., .F. )
	cIndTRBI2 := CriaTrab(,.F.)
	IndRegua( "TRBPGTO",cIndTRBI2,"FILIAL+RECPAG+PREFIXO+NUMERO+PARCELA+TIPO+CLIFOR+LOJA+CODRET",,,STR0016) //"Selecionando Registros..."
	DbSelectArea ("TRBPGTO")
	TRBPGTO->( dbClearIndex() )
	TRBPGTO->( dbSetIndex(cIndTRBI2+OrdBagExt()) )
*/	
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FTmpClean        

Função para limpar o objeto da FWTemporaryTable

@Return ( Nil ) 

@author Karen Honda
@since  21/11/2017
@version 1.0

/*/   
//-------------------------------------------------------------------         
Static Function FTmpClean()

If _oFINA989T <> Nil
	_oFINA989T:Delete()
	_oFINA989T := Nil
Endif

Return  


//-------------------------------------------------------------------
/*/{Protheus.doc} F989Addlog        

Função para alimentar o objeto da FWTemporaryTable com os registros enviados ao TAF

@Return ( Nil ) 

@author Karen Honda
@since  21/11/2017
@version 1.0

/*/   
//-------------------------------------------------------------------         
Static Function F989Addlog(cFilTit,cRECPAG,cPREFIXO,cNUMERO,cPARCELA,cTIPO,cCLIFOR,cLOJA,dEMISSAO, cTpServ, cTpRepasse,nVlBruto, nVlBaseINS, nVlINSS, nVlDed,nVlProc)
If !lAutomato
	If !lExtFiscal
		Reclock(cAliasTRB, .T.)
		(cAliasTRB)->FILIAL 	:= cFilTit
		(cAliasTRB)->RECPAG 	:= cRECPAG
		(cAliasTRB)->PREFIXO 	:= cPREFIXO
		(cAliasTRB)->NUMERO	 	:= cNUMERO
		(cAliasTRB)->PARCELA 	:= cPARCELA
		(cAliasTRB)->TIPO 		:= cTIPO
		(cAliasTRB)->CLIFOR 	:= cCLIFOR
		(cAliasTRB)->LOJA 		:= cLOJA
		(cAliasTRB)->EMISSAO 	:= IIf(ValType(dEMISSAO) == "D", dEMISSAO, stod(dEMISSAO))
		(cAliasTRB)->TPSERV 	:= cTpServ
		(cAliasTRB)->TPREPASSE 	:= cTpRepasse
		(cAliasTRB)->VLBRUTO 	:= nVlBruto
		(cAliasTRB)->VLBASEINSS := nVlBaseINS
		(cAliasTRB)->VLINSS 	:= nVlINSS
		(cAliasTRB)->DEDINSS 	:= nVlDed
		(cAliasTRB)->DEDPROCJD 	:= nVlProc
		(cAliasTRB)->(MsUnlock())
	EndIf
EndIf	
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} RetPartTaf        

Função que retorna o codigo do participante conforme cadastro de cliente/fornecedor

@Param cCliFor    -> CLI - para clientes, FOR - Fornecedor, TRA - Transportadora
@Param cCodigo    -> código do cliente/fornecedor
@Param cLoja      -> Loja
 
@Return ( Nil ) 

@author Karen Honda
@since  19/08/2016
@version 1.0

/*/                                 
//-------------------------------------------------------------------
Static Function RetPartTAF(cCliFor, cCodigo, cLoja)
Local cRet := ""
Local cSigla := ""

cCliFor := Alltrim(cCliFor)

If cCliFor == "CLI"
	cSigla := "C"
ElseIf cCliFor == "TRA"
	cSigla := "T"
Else
	cSigla := "F"
EndIf

cRet := cSigla + cCodigo + cLoja

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MntQryRec        

Função que monta a query dos titulos a receber para envio ao TAF

@Param nRecno    -> Recno do titulo a receber posicionado, caso seja somente para mandar só ele
@Param cAliasSE1    -> Alias para receber o resultado da query 
 
@Return ( Nil ) 

@author Karen Honda
@since  19/08/2016
@version 1.0

/*/                                 
//-------------------------------------------------------------------

Static Function MntQryRec(nRecno, cAliasSE1, lExtReinf)
Local cQuery := ""
Local aCpoNum := {'E1_VALOR','E1_IRRF','E1_INSS','E1_PIS','E1_COFINS','E1_CSLL','E1_ISS','E1_BASEINS','FKF_ORIINS'}
Local aStru		:= {}
Local nLoop 	:= 1
Local aTamSX3Cpo := {}
Local cCampos	:= ''
Local cQry		:= ''
Local cCond		:= ''
Local cQryAux	:= ''
Local cCondAux	:= ''
Local cFields	:= ''

Default lExtReinf	:= 	.f.

	__cBxFinCR	:= 'BXFINCR'

	cCampos	:= "SELECT SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_EMIS1,SE1.E1_EMISSAO,"
	cCampos	+= "SE1.E1_VENCTO, SE1.E1_VENCREA, SE1.E1_NATUREZ, SE1.E1_HIST, SE1.R_E_C_N_O_, "
	cCampos	+= "SE1.E1_VALOR, SE1.E1_IRRF, SE1.E1_INSS, SE1.E1_PIS, SE1.E1_COFINS, SE1.E1_CSLL, SE1.E1_ISS, "
	cCampos	+= "SE1.E1_BASEINS, SE1.E1_ORIGEM, SE1.E1_CONTA,SE1.E1_SERIE,SE1.E1_DESDOBR DESDOBR, "   
	cCampos	+= "SA1.A1_CGC, SA1.A1_NOME, SA1.A1_END, SA1.A1_BAIRRO, SA1.A1_MUN, SA1.A1_EST, SA1.A1_CEP, SA1.A1_RECINSS, SA1.R_E_C_N_O_ A1_RECNO, SED.ED_CODIGO, SED.ED_CALCINS, "
	cCampos	+= "' ' TPREX, ' ' TRBEX,"
	cCampos	+= " SED.ED_PERCINS, SA1.A1_COD COD, SA1.A1_LOJA LOJA, " 
	cCampos += cIsNullSQL + "(FK7.FK7_IDDOC,' ') FK7_IDDOC, "
	cCampos	+= cIsNullSQL + "(FKF.FKF_CPRB,' ')  FKF_CPRB, "
	cCampos	+= cIsNullSQL + "(FKF.FKF_CNAE,' ')  FKF_CNAE, "
	cCampos	+= cIsNullSQL + "(FKF.FKF_TPREPA,' ') FKF_TPREPA, "
	cCampos	+= cIsNullSQL + "(FKF.FKF_INDSUS,' ') FKF_INDSUS, "
	cCampos	+= cIsNullSQL + "(FKF.FKF_INDDEC,' ') FKF_INDDEC, "
	cCampos	+= cIsNullSQL + "(FKF.FKF_TPSERV,' ') FKF_TPSERV, "
	cCampos	+= cIsNullSQL + "(FKF.FKF_CNO,' ') FKF_CNO, "
	cCampos	+= cIsNullSQL + "(FKF.FKF_ORIINS,0) FKF_ORIINS "
	//cQuery += cIsNullSQL + "(FKF.FKF_INSS15,0) FKF_INSS15, "
	//cQuery += cIsNullSQL + "(FKF.FKF_INSS20,0) FKF_INSS20, "
	//cQuery += cIsNullSQL + "(FKF.FKF_INSS25,0) FKF_INSS25 "

	If __nBx2030 == 2
		cQryAux	+= " , FK1_DATA DTBXFIN "
	
	ElseIf __nBx2030 == 3
		cQryAux	+= " , FK1_DTDISP DTBXFIN "
	EndIf

	cQuery := cCampos
	cCond := " FROM " + RetSqlName("SE1") + " SE1 "
	
	cCond += " INNER JOIN "+ RetSqlName("SA1") + " SA1 "
	cCond += " ON (SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
	cCond += " AND SA1.A1_COD = SE1.E1_CLIENTE"
	cCond += " AND SA1.A1_LOJA = SE1.E1_LOJA "
	If nTpEmPessoa = 1 // Pessoa física
		cCond += "AND SA1.A1_PESSOA = 'F'  "
	ElseIf nTpEmPessoa = 2 // Pessoa Juridica
		cCond += "AND SA1.A1_PESSOA = 'J'  "
	ElseIf nTpEmPessoa = 3 // Estrangeiro
		cCond += "AND SA1.A1_PESSOA = 'X'  "
	Else
		cCond += "AND SA1.A1_PESSOA IN ('J', 'F', 'X')  "
	EndIf
	cCond += " AND SA1.D_E_L_E_T_ = ' ' )"

	cCond += " INNER JOIN "+ RetSqlName("SED") + " SED "
	cCond += " ON ( SED.ED_FILIAL = '" + xFilial("SED") + "'"
	cCond += " AND SED.ED_CODIGO = SE1.E1_NATUREZ "
	cCond += " AND SED.D_E_L_E_T_ = ' ' )"

	cCond += " LEFT JOIN " + RetSqlName("FK7") + " FK7 ON ( FK7.FK7_FILIAL = '"+ xFilial("FK7") +"' AND FK7.FK7_ALIAS = 'SE1' AND "
	cCond += " FK7.FK7_CHAVE = "
	
	If cBDname $ "MYSQL|POSTGRES"
		cCond += "CONCAT( "
	EndIf
	cCond += " SE1.E1_FILIAL "+ cConcat + " '|' " + cConcat
	cCond += " SE1.E1_PREFIXO "+ cConcat + " '|' " + cConcat
	cCond += " SE1.E1_NUM "+ cConcat + " '|' " + cConcat
	cCond += " SE1.E1_PARCELA "+ cConcat + " '|' " + cConcat
	cCond += " SE1.E1_TIPO "+ cConcat + " '|' " + cConcat
	cCond += " SE1.E1_CLIENTE "+ cConcat + " '|' " + cConcat
	cCond += " SE1.E1_LOJA "
	If cBDname $ "MYSQL|POSTGRES"
		cCond += ") "
	EndIf

	cCond += " AND FK7.D_E_L_E_T_ = ' ') "
	cCond += "LEFT JOIN " + RetSqlName("FKF") + " FKF "
	cCond += "ON ( FKF.FKF_FILIAL = '" + xFilial("FKF") + "' AND"
	cCond += " FKF.FKF_IDDOC = FK7.FK7_IDDOC AND FKF.D_E_L_E_T_ = ' ' ) "
	
	If nRecno > 0
		cCondAux += "AND SE1.R_E_C_N_O_ = " + Str(nRecno) + "  " 	
	Else

		If !Empty(dDataEmDe) .And. !Empty(dDataEmAte)
			If nTpEmData == 1
				cCondAux += "AND  ( SE1.E1_EMIS1 >= '" + Dtos(dDataEmDe) + "' AND SE1.E1_EMIS1 <= '" + Dtos(dDataEmAte) + "') "
			ElseIf nTpEmData == 2
				cCondAux += "AND  ( SE1.E1_EMISSAO >= '" + Dtos(dDataEmDe) + "' AND SE1.E1_EMISSAO <= '" + Dtos(dDataEmAte) + "') "
			EndIf
		EndIf

		cCondAux += " AND SE1.E1_TIPO NOT IN " + FormatIn(MVABATIM+"|"+MV_CRNEG +"|" +MVPROVIS+"|"+MVRECANT+"|"+MV_CPNEG+ "|"+ MVTAXA+"|"+MVTXA+"|"+MVINSS+"|"+"SES","|")  + " "
		cCondAux += " AND SE1.E1_FILORIG = '" + cFilAnt + "' "
		cCondAux += " AND SE1.E1_FATURA NOT IN ('NOTFAT') " // desconsidera titulos fatura
		cCondAux += " AND SE1.E1_NUMLIQ = ' ' " // desconsidera titulos liquidados
		
		cCondAux += " AND (FKF.FKF_TPSERV != ' ' OR FKF.FKF_TPREPA != ' ' "
		
		If !lExtReinf
			cCondAux += " OR SE1.E1_ORIGEM IN ('MATA461','MATA460','MATA103','MATA100') "
		EndIf

		cCondAux += " ) AND SE1.D_E_L_E_T_ = ' ' "

		If !Empty(cCliDe)
			cCondAux += "AND SE1.E1_CLIENTE >= '" + cCliDe + "' "	
		EndIf
		If !Empty(cCliAte)
			cCondAux += "AND SE1.E1_CLIENTE <= '" + cCliAte + "' "	
		EndIf

		If !Empty(cLojaCliDe)
			cCondAux += "AND SE1.E1_LOJA >= '" + cLojaCliDe + "' "	
		EndIf
		If !Empty(cLojaCliAte)
			cCondAux += "AND SE1.E1_LOJA <= '" + cLojaCliAte + "' "	
		EndIf
		
	EndIf	
	cQuery += cCond + " WHERE E1_FILIAL = '" + xFilial("SE1") + "' " + cCondAux

	If nRecno == 0
		If __nBx2030 > 1

			cQry += cCampos + cQryAux

			cQry	+= " , ( E5_VALOR + ( CASE WHEN E5_SEQ = (Select Max(E5MX.E5_SEQ) "
			cQry	+= " FROM " + RetSqlName("SE5") + " E5MX "
			cQry	+= " Where E1_SALDO = 0 AND E5MX.E5_FILIAL = '" + xFilial("SE5") + "' "
			cQry	+= " AND E5MX.E5_PREFIXO = SE1.E1_PREFIXO AND E5MX.E5_NUMERO = SE1.E1_NUM "
			cQry	+= " AND E5MX.E5_PARCELA = SE1.E1_PARCELA AND E5MX.E5_TIPO = SE1.E1_TIPO "
			cQry	+= " AND E5MX.E5_CLIFOR = SE1.E1_CLIENTE AND E5MX.E5_LOJA = SE1.E1_LOJA "
			cQry	+= " AND SE1.D_E_L_E_T_ = ' ' "
			cQry	+= " AND E5MX.D_E_L_E_T_ = ' ' "
			cQry	+= " AND E5MX.E5_TIPODOC != 'ES' AND E5MX.D_E_L_E_T_ = ' ' )

			cQry	+= " THEN (E1_INSS + E1_COFINS + E1_CSLL + "
			cQry	+= " (CASE WHEN E5_PRETIRF != '1' THEN E1_IRRF ELSE 0 END ) + E1_ISS + E1_DECRESC - E1_ACRESC - E1_JUROS - E1_MULTA ) ELSE 0 END ) ) AS VLBXFIN "
			
			cQry	+= cCond

			cQry += " JOIN " + RetSqlName("FK1") + " FK1 "
			cQry += " On FK1.FK1_FILIAL = '" + xFilial("FK1") + "'"
			cQry += " AND NOT EXISTS( "
			cQry += " 	SELECT FK1EST.FK1_IDDOC FROM " + RetSqlName("FK1") +" FK1EST"
			cQry += " 	WHERE FK1EST.FK1_FILIAL = FK1.FK1_FILIAL"
			cQry += " 	AND FK1EST.FK1_IDDOC = FK1.FK1_IDDOC "
			cQry += " 	AND FK1EST.FK1_SEQ = FK1.FK1_SEQ "
			cQry += " 	AND FK1EST.FK1_TPDOC = 'ES' "
			cQry += " 	AND FK1EST.D_E_L_E_T_ = ' ') "
			cQry += " AND FK1.D_E_L_E_T_ = ' ' "
			cQry += " AND FK1.FK1_IDDOC = FK7.FK7_IDDOC "

			If !Empty(dDataEmDe) .AND. !Empty(dDataEmAte) 
				If __nBx2030 == 2 // baixa
					cQry += "AND FK1.FK1_DATA >= '" + Dtos(dDataEmDe ) + "' AND FK1.FK1_DATA <= '" + Dtos(dDataEmAte) + "' "
				Else
					cQry += "AND FK1.FK1_DTDISP >= '" + Dtos(dDataEmDe ) + "' AND FK1.FK1_DTDISP <= '" + Dtos(dDataEmAte) + "' "
				EndIf	
			EndIf
			cQry += " AND FK7.D_E_L_E_T_ = ' ' "
			
			cQry += " LEFT JOIN " + RetSqlName("SE5") + " SE5 "
			cQry += " On SE5.E5_FILIAL = '" + xFilial("SE5") + "'"
			cQry += " AND SE5.E5_TABORI = 'FK1' "
			cQry += " AND SE5.E5_IDORIG = FK1.FK1_IDFK1 "
			cQry += " AND SE5.E5_RECPAG = 'R' "
			cQry += " AND SE5.E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE','E2','CH','ES') "
			cQry += " AND SE5.E5_MOTBX NOT IN ('FAT','LIQ','DEV', 'CMP') "
			cQry += " AND SE5.D_E_L_E_T_ = ' ' "

			cQry +=	" WHERE E1_FILIAL = '" + xFilial("SE1") + "' "
			
			cQry += " AND SE1.E1_TIPO NOT IN " + FormatIn(MVABATIM+"|"+MV_CRNEG +"|" +MVPROVIS+"|"+MVRECANT+"|"+MV_CPNEG+ "|"+ MVTAXA+"|"+MVTXA+"|"+MVINSS+"|"+"SES","|")  + " "
			cQry += " AND SE1.E1_FILORIG = '" + cFilAnt + "' "
			cQry += " AND SE1.E1_FATURA NOT IN ('NOTFAT') " // desconsidera titulos fatura
			cQry += " AND SE1.E1_NUMLIQ = ' ' " // desconsidera titulos liquidados
		
			cQry += " AND (FKF.FKF_TPSERV != ' ' OR FKF.FKF_TPREPA != ' ' "
		
			cQry += " ) AND SE1.D_E_L_E_T_ = ' ' "
			cQry += " AND ((SA1.A1_RECINSS = 'S' AND SED.ED_CALCINS = 'S') OR SE1.E1_INSS > 0)  " // se recolhe INSS

			cQry += " AND EXISTS (SELECT FK1.FK1_IDFK1 FROM " + RetSqlName("FK1") + " FK1 "
			cQry += " WHERE "
			cQry += 		" FK1.FK1_IDDOC = FK7.FK7_IDDOC "
			
			cQry += 		" AND FK1.FK1_RECPAG = 'R' "
			cQry += 		" AND FK1.FK1_TPDOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE','E2','CH','ES') "
			cQry += 		" AND FK1.FK1_MOTBX NOT IN ('FAT','LIQ','DEV', 'CMP') "
			
			cQry += " AND FK1.D_E_L_E_T_ = ' ' "
			cQry += " ) "
			cQry += " AND SE1.D_E_L_E_T_ = ' ' "

			cQry	:= ChangeQuery(cQry)

			If __oBxFinCR <> Nil
				__oBxFinCR:Delete()
				__oBxFinCR := Nil	
			EndIf

			aStru := {{ 'E1_FILIAL', "C",TAMSX3("E1_FILIAL")[1],0}, ;
				{ 'E1_PREFIXO', "C",TAMSX3("E1_PREFIXO")[1],0}, ;
				{ 'E1_NUM', "C",TAMSX3("E1_NUM")[1],0}, ;
				{ 'E1_PARCELA', "C",TAMSX3("E1_PARCELA")[1],0}, ;
				{ 'E1_TIPO', "C",TAMSX3("E1_TIPO")[1],0}, ;
				{ 'E1_CLIENTE', "C",TAMSX3("E1_CLIENTE")[1],0}, ;
				{ 'E1_LOJA', "C",TAMSX3("E1_LOJA")[1],0}, ;
				{ 'E1_EMIS1', "C",TAMSX3("E1_EMIS1")[1],0}, ;
				{ 'E1_EMISSAO',"C",TAMSX3("E1_EMISSAO")[1],0}, ;
				{ 'E1_VENCTO', "C",TAMSX3("E1_VENCTO")[1],0}, ;
				{ 'E1_VENCREA', "C",TAMSX3("E1_VENCREA")[1],0}, ;
				{ 'E1_NATUREZ', "C",TAMSX3("E1_NATUREZ")[1],0}, ;
				{ 'E1_HIST', "C",TAMSX3("E1_HIST")[1],0}, ;
				{ 'RECSE1', "N", 10, 0 }, ;
				{ 'E1_VALOR', "N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]}, ;
				{ 'E1_IRRF', "N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]}, ;
				{ 'E1_INSS',"N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]}, ;
				{ 'E1_PIS', "N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]}, ;
				{ 'E1_COFINS', "N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]}, ;
				{ 'E1_CSLL', "N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]}, ;
				{ 'E1_ISS', "N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]}, ;
				{ 'E1_BASEINS', "N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]}, ;
				{ 'E1_ORIGEM', "C",TAMSX3("E1_ORIGEM")[1],0}, ;
				{ 'E1_CONTA', "C",TAMSX3("E1_CONTA")[1],0}, ;
				{ 'E1_SERIE', "C",TAMSX3("E1_SERIE")[1],0}, ;
				{ 'DESDOBR', "C",TAMSX3("E1_DESDOBR")[1],0}, ;
				{ 'A1_CGC', "C",TAMSX3("A1_CGC")[1],0}, ;
				{ 'A1_NOME', "C",TAMSX3("A1_NOME")[1],0}, ;
				{ 'A1_END', "C",TAMSX3("A1_END")[1],0}, ;
				{ 'A1_BAIRRO', "C",TAMSX3("A1_BAIRRO")[1],0}, ;
				{ 'A1_MUN', "C",TAMSX3("A1_MUN")[1],0}, ;
				{ 'A1_EST', "C",TAMSX3("A1_EST")[1],0}, ;
				{ 'A1_CEP', "C",TAMSX3("A1_CEP")[1],0}, ;
				{ 'A1_RECINSS', "C",TAMSX3("A1_RECINSS")[1],0}, ;
				{ 'A1_RECNO', "N", 10, 0 }, ;
				{ 'ED_CODIGO', "C",TAMSX3("ED_CODIGO")[1],0}, ;
				{ 'ED_CALCINS', "C",TAMSX3("ED_CALCINS")[1],0}, ;
				{'TPREX', "C", TAMSX3("A2_TPREX")[1], 0 }, { 'TRBEX', "C", TAMSX3("A2_TRBEX")[1], 0 }, ;
				{ 'ED_PERCINS', "N",TAMSX3("ED_PERCINS")[1], TAMSX3("ED_PERCINS")[2]}, ;
				{ 'COD', "C",TAMSX3("A1_COD")[1],0}, ;
				{ 'LOJA', "C",TAMSX3("A1_LOJA")[1],0}, ;
				{ 'FK7_IDDOC', "C", TAMSX3("FK7_IDDOC")[1], 0 }, ;
				{ 'FKF_CPRB', "C",TAMSX3("FKF_CPRB")[1],0}, ;
				{ 'FKF_CNAE', "C",TAMSX3("FKF_CNAE")[1],0}, ;
				{ 'FKF_TPREPA', "C",TAMSX3("FKF_TPREPA")[1],0}, ;
				{ 'FKF_INDSUS', "C",TAMSX3("FKF_INDSUS")[1],0}, ;
				{ 'FKF_INDDEC', "C",TAMSX3("FKF_INDDEC")[1],0}, ;
				{ 'FKF_TPSERV', "C",TAMSX3("FKF_TPSERV")[1],0}, ;
				{ 'FKF_CNO', "C",TAMSX3("FKF_CNO")[1],0}, ;
				{ 'FKF_ORIINS', "N",TAMSX3("FKF_ORIINS")[1],TAMSX3("FKF_ORIINS")[2]}, ;
				{ 'DTBXFIN', "C",TAMSX3("FK1_DATA")[1],0}, ;
				{ 'VLBXFIN', "N",TAMSX3("E1_VLCRUZ")[1],TAMSX3("E1_VLCRUZ")[2]} }

			__oBxFinCR := FwTemporaryTable():New( __cBxFinCR )
			__oBxFinCR:SetFields(aStru)
			__oBxFinCR:AddIndex('1', {'FK7_IDDOC'})
			
			__oBxFinCR:Create()

			For nLoop := 1 to Len(aStru)
				cFields += aStru[nLoop][1] + ","//Nome do campo
			Next
			cFields := Left(cFields, Len(cFields) -1) //Remover a ultima vírgula
							
			TcSQLExec("Insert Into " + __oBxFinCR:GetRealName() ;
				+ " (" + cFields + ") (" + cQry + ") " )

		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PE permite regra customizada para o retorno de titulos     ³
	//³para a REINF, podendo por exemplo trazer titulos com valor ³
	//³de INSS zerado.                                            ³
	//³Caso contrario segue a regra padrao, de descartar os que   ³
	//³nao sofreram retencao de INSS                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If ExistBlock("F989CRIN")                        			
	 	cQuery += ExecBlock("F989CRIN",.F.,.F., {cQuery})
	Else
		cQuery += "AND ((SA1.A1_RECINSS = 'S' AND SED.ED_CALCINS = 'S') OR SE1.E1_INSS > 0)  " // se recolhe INSS
	EndIf			
	cQuery += " ORDER BY SE1.E1_FILIAL,COD,LOJA,SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_TIPO"

 	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSE1,.F.,.T.)

	For nLoop := 1 To Len( aCpoNum )
		aTamSX3Cpo := TamSX3(aCpoNum[nLoop])
		TcSetField( cAliasSE1, aCpoNum[nLoop], "N",aTamSX3Cpo[1],aTamSX3Cpo[2])
	Next nLoop 	

 	lRecQry	  := .T.
 	
 	cFilFiscal	  := cFilAnt	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MntQryPag        

Função que monta a query dos titulos a pagar para envio ao TAF

@Param nRecno    -> Recno do titulo a pagar posicionado, caso seja somente para mandar só ele
@Param cAliasSE2    -> Alias para pagar o resultado da query 
 
@Return ( Nil ) 

@author Karen Honda
@since  19/08/2016
@version 1.0

/*/                                 
//-------------------------------------------------------------------

Static Function MntQryPag(nRecno, cAliasSE2, lExtReinf, lFiltReinf)
Local cQuery := ""
Local cCampos := ""
Local aCpoNum := {'E2_VALOR','E2_IRRF','E2_INSS','E2_PIS','E2_COFINS','E2_CSLL','E2_ISS','E2_SEST','E2_BASEINS','E2_VRETPIS','E2_VRETCOF','E2_VRETCSL','E2_SALDO','FKF_ORIINS'}
Local nLoop := 1
Local aTamSX3Cpo := {}
Local aStru		:= ""
Local cCamposFim := ""
Local cQry		:= ""
Local cQryAux	:= ""
Local cCond		:= ""
Local cFields	:= ""

Default nRecno := 0
Default lExtReinf	:=	.f.
Default lFiltReinf	:=	.f.

	__cBxFinCP	:= 'BXFINCP'

	cCampos := "SELECT SE2.E2_FILIAL,SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA, SE2.E2_TIPO, SE2.E2_FORNECE COD, SE2.E2_LOJA LOJA, SE2.E2_EMIS1,SE2.E2_EMISSAO,"
	cCampos += "SE2.E2_VENCTO, SE2.E2_VENCREA, SE2.E2_NATUREZ, SE2.E2_HIST, SE2.R_E_C_N_O_ RECNO, "
	cCampos += "SE2.E2_VALOR, SE2.E2_IRRF, SE2.E2_INSS, SE2.E2_PIS, SE2.E2_COFINS, SE2.E2_CSLL, SE2.E2_ISS, SE2.E2_DESDOBR DESDOBR,"
	cCampos += "SE2.E2_SEST, SE2.E2_BASEINS, SE2.E2_ORIGEM, SE2.E2_CONTAD, SE2.E2_CODRET,SE2.E2_VRETPIS,SE2.E2_VRETCOF,SE2.E2_VRETCSL, SE2.E2_SALDO,"   
	cCampos += "SA2.A2_CGC, SA2.A2_NOME, SA2.A2_END, SA2.A2_BAIRRO, SA2.A2_MUN, SA2.A2_EST, SA2.A2_CEP, SA2.A2_NUMDEP, SA2.A2_CALCIRF,SA2.A2_RECINSS, SA2.R_E_C_N_O_ A2_RECNO, SED.ED_CODIGO, SED.ED_CALCINS, "
	cCampos += "SA2.A2_TPREX TPREX, SA2.A2_TRBEX TRBEX,"
	cCampos += "SED.ED_PERCINS, " 
	cCampos += cIsNullSQL + "(FK7.FK7_IDDOC,' ') FK7_IDDOC, "
	cCampos += cIsNullSQL + "(FKF.FKF_CPRB,' ')  FKF_CPRB, "
	cCampos += cIsNullSQL + "(FKF.FKF_CNAE,' ')  FKF_CNAE, "
	cCampos += cIsNullSQL + "(FKF.FKF_TPREPA,' ') FKF_TPREPA, "
	cCampos += cIsNullSQL + "(FKF.FKF_INDSUS,' ') FKF_INDSUS, "
	cCampos += cIsNullSQL + "(FKF.FKF_INDDEC,' ') FKF_INDDEC, "
	cCampos += cIsNullSQL + "(FKF.FKF_TPSERV,' ') FKF_TPSERV, "
	cCampos += cIsNullSQL + "(FKF.FKF_CNO,' ') FKF_CNO, "
	cCampos += cIsNullSQL + "(FKF.FKF_ORIINS,0) FKF_ORIINS "
	//cCampos += cIsNullSQL + "(FKF.FKF_INSS15,0) FKF_INSS15, "
	//cCampos += cIsNullSQL + "(FKF.FKF_INSS20,0) FKF_INSS20, "
	//cCampos += cIsNullSQL + "(FKF.FKF_INSS25,0) FKF_INSS25 "
	If __nBx2040 == 2
		cQryAux	+= " , FK2_DATA DTBXFIN "
	
	ElseIf __nBx2040 == 3
		cQryAux	+= " , FK2_DTDISP DTBXFIN "
	EndIf
	
	cQuery := cCampos
	cCond := " FROM " + RetSqlName("SE2") + " SE2 "
	
	cCond += " INNER JOIN "+ RetSqlName("SA2") + " SA2 "
	cCond += " ON (SA2.A2_FILIAL = '" + xFilial("SA2") + "'"
	cCond += " AND SA2.A2_COD = SE2.E2_FORNECE"
	cCond += " AND SA2.A2_LOJA = SE2.E2_LOJA " 
	If !lFiltReinf .and. nTpPgPessoa = 1 // Pessoa física
		cCond += "AND SA2.A2_TIPO = 'F' "
	ElseIf nTpPgPessoa = 2 // Pessoa Juridica
		cCond += "AND SA2.A2_TIPO = 'J'  "
	ElseIf nTpPgPessoa = 3 // Pessoa Exterior
		cCond += "AND SA2.A2_TIPO = 'X'  "
	EndIf
	cCond += " AND SA2.D_E_L_E_T_ = ' ' )"

	cCond += " INNER JOIN "+ RetSqlName("SED") + " SED "
	cCond += " ON ( SED.ED_FILIAL = '" + xFilial("SED") + "'"
	cCond += " AND SED.ED_CODIGO = SE2.E2_NATUREZ "
	cCond += " AND SED.D_E_L_E_T_ = ' ' )"

	cCond += " LEFT JOIN " + RetSqlName("FK7") + " FK7 "
	cCond += " ON ( FK7.FK7_FILIAL = '" + xFilial("FK7") + "' AND"
	cCond += " FK7.FK7_ALIAS = 'SE2' AND "

	cCond += " FK7.FK7_CHAVE = "
	
	If cBDname $ "MYSQL|POSTGRES"
		cCond += "CONCAT( "
	EndIf
	cCond += " SE2.E2_FILIAL "+ cConcat + " '|' " + cConcat
	cCond += " SE2.E2_PREFIXO "+ cConcat + " '|' " + cConcat
	cCond += " SE2.E2_NUM "+ cConcat + " '|' " + cConcat
	cCond += " SE2.E2_PARCELA "+ cConcat + " '|' " + cConcat
	cCond += " SE2.E2_TIPO "+ cConcat + " '|' " + cConcat
	cCond += " SE2.E2_FORNECE "+ cConcat + " '|' " + cConcat
	cCond += " SE2.E2_LOJA "
	If cBDname $ "MYSQL|POSTGRES"
		cCond += ") "
	EndIf

	cCond += " AND FK7.D_E_L_E_T_ = ' ' "
	cCond += ") "

	cCond += " LEFT JOIN " + RetSqlName("FKF") + " FKF "
	cCond += " ON ( FKF.FKF_FILIAL = '" + xFilial("FKF") + "'"
	cCond += " AND  FKF.FKF_IDDOC = FK7.FK7_IDDOC AND FKF.D_E_L_E_T_ = ' ' ) "
	
	cQuery += cCond
	cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' "

	If nRecno > 0
		cQuery += "AND SE2.R_E_C_N_O_ = " + Str(nRecno) + "  " 	
	Else
		// Abaixo as vezes atualizo apenas a cQuery porque a variável cCampos será utilizada no UNION e nem todas as condições devem ser aplicadas nesse caso.
		If !Empty(dDataPgDe) .And. !Empty(dDataPgAte)
			
			If nTpPgEmis == 1
				cQuery += "AND ( SE2.E2_EMIS1 >= '" + Dtos(dDataPgDe ) + "' AND SE2.E2_EMIS1 <= '" + Dtos(dDataPgAte) + "')  "
			ElseIf nTpPgEmis == 2
				cQuery += "AND ( SE2.E2_EMISSAO >= '" + Dtos(dDataPgDe) + "' AND SE2.E2_EMISSAO <= '" + Dtos(dDataPgAte) + "')   "
			EndIf	
		EndIf

		cCamposFim := " AND SE2.E2_TIPO NOT IN " + FormatIn(MVABATIM+"|"+MVPROVIS+"|"+MVPAGANT+"|"+MV_CPNEG+"|"+MVIRABT+"|"+MVCSABT+"|"+MVCFABT+"|"+MVPIABT+"|"+MVISS+"|"+ MVTAXA+"|"+MVTXA+"|"+MVINSS+"|"+"SES","|")  + "  "	
		cCamposFim += " AND SE2.E2_FILORIG = '" + cFilAnt + "' "	
		cCamposFim += " AND SE2.E2_FATURA NOT IN ('NOTFAT') " // desconsidera titulos fatura
		cCamposFim += " AND SE2.E2_NUMLIQ = ' ' " // desconsidera titulos liquidados

		cQuery  += cCamposFim
		
		If !Empty(cForDe)
			cQuery += "AND SE2.E2_FORNECE >= '" + cForDe + "' "	
		EndIf
		If !Empty(cForAte)
			cQuery += "AND SE2.E2_FORNECE <= '" + cForAte + "' "	
		EndIf

		If !Empty(cLojaForDe)
			cQuery += "AND SE2.E2_LOJA >= '" + cLojaForDe + "' "	
		EndIf
		If !Empty(cLojaForAte)
			cQuery += "AND SE2.E2_LOJA <= '" + cLojaForAte + "' "	
		EndIf

		cQuery += " AND ((SA2.A2_RECINSS = 'S' AND SED.ED_CALCINS = 'S') AND SE2.E2_INSS > 0 ) "
		if lFiltReinf
			cQuery += "AND SA2.A2_TIPO <> 'F' " 
		endif
		cQuery += " AND (FKF.FKF_TPSERV != ' ' OR FKF.FKF_TPREPA != ' ' " 
		
		If !lExtReinf
			cQuery += " OR SE2.E2_ORIGEM IN ('MATA461','MATA460','MATA103','MATA100') "		
		EndIf

		cQuery += " ) AND SE2.D_E_L_E_T_ = ' ' "
	EndIf

	If nRecno == 0
		If __nBx2040 > 1
		
			cQry := cCampos + cQryAux
			cQry	+= " , ( E5_VALOR + ( CASE WHEN E5_SEQ = (Select Max(E5MX.E5_SEQ) "
			cQry	+= " FROM " + RetSqlName("SE5") + " E5MX "
			cQry	+= " Where E2_SALDO = 0 AND E5MX.E5_FILIAL = '" + xFilial("SE5") + "' "
			cQry	+= " AND E5MX.E5_PREFIXO = SE2.E2_PREFIXO AND E5MX.E5_NUMERO = SE2.E2_NUM "
			cQry	+= " AND E5MX.E5_PARCELA = SE2.E2_PARCELA AND E5MX.E5_TIPO = SE2.E2_TIPO "
			cQry	+= " AND E5MX.E5_CLIFOR = SE2.E2_FORNECE AND E5MX.E5_LOJA = SE2.E2_LOJA "
			cQry	+= " AND SE2.D_E_L_E_T_ = ' ' "
			cQry	+= " AND E5MX.D_E_L_E_T_ = ' ' "
			cQry	+= " AND E5MX.E5_TIPODOC != 'ES' AND E5MX.D_E_L_E_T_ = ' ' )

			cQry	+= " THEN (E2_INSS + E2_COFINS + E2_CSLL + "
			cQry	+= " (CASE WHEN E5_PRETIRF != '1' THEN E2_IRRF ELSE 0 END ) + E2_ISS + E2_DECRESC - E2_JUROS - E2_ACRESC - E2_MULTA ) ELSE 0 END ) ) AS VLBXFIN "
			
			cQry	+= cCond
			cQry += " JOIN " + RetSqlName("FK2") + " FK2 "
			cQry += " On FK2.FK2_FILIAL = '" + xFilial("FK2") + "'"
			cQry += " AND NOT EXISTS( "
			cQry += " 	SELECT FK2EST.FK2_IDDOC FROM " + RetSqlName("FK2") +" FK2EST"
			cQry += " 	WHERE FK2EST.FK2_FILIAL = FK2.FK2_FILIAL"
			cQry += " 	AND FK2EST.FK2_IDDOC = FK2.FK2_IDDOC "
			cQry += " 	AND FK2EST.FK2_SEQ = FK2.FK2_SEQ "
			cQry += " 	AND FK2EST.FK2_TPDOC = 'ES' "
			cQry += " 	AND FK2EST.D_E_L_E_T_ = ' ') "
			cQry += " AND FK2.D_E_L_E_T_ = ' ' "
			cQry += " AND FK2.FK2_IDDOC = FK7.FK7_IDDOC "

			If !Empty(dDataPgDe) .AND. !Empty(dDataPgAte) 
				If __nBx2040 == 2 // baixa
					cQry += "AND FK2.FK2_DATA >= '" + Dtos(dDataPgDe ) + "' AND FK2.FK2_DATA <= '" + Dtos(dDataPgAte) + "' "
				Else
					cQry += "AND FK2.FK2_DTDISP >= '" + Dtos(dDataPgDe ) + "' AND FK2.FK2_DTDISP <= '" + Dtos(dDataPgAte) + "' "
				EndIf
			EndIf
			cQry += " AND FK7.D_E_L_E_T_ = ' ' "
			
			cQry += " LEFT JOIN " + RetSqlName("SE5") + " SE5 "
			cQry += " On SE5.E5_FILIAL = '" + xFilial("SE5") + "'"
			cQry += " AND SE5.E5_TABORI = 'FK2' "
			cQry += " AND SE5.E5_IDORIG = FK2.FK2_IDFK2 "
			cQry += " AND SE5.E5_RECPAG = 'P' "
			cQry += " AND SE5.E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE','E2','CH','ES') "
			cQry += " AND SE5.E5_MOTBX NOT IN ('FAT','LIQ','DEV', 'CMP') "
			cQry += " AND SE5.D_E_L_E_T_ = ' ' "
			
			cQry	+= " WHERE E2_FILIAL = '" + xFilial("SE2") + "' " + cCamposFim

			cQry += " AND ((SA2.A2_RECINSS = 'S' AND SED.ED_CALCINS = 'S') AND SE2.E2_INSS > 0 ) "
			If lFiltReinf
				cQry += "AND SA2.A2_TIPO <> 'F' " 
			EndIf
			cQry += " AND (FKF.FKF_TPSERV != ' ' OR FKF.FKF_TPREPA != ' ' " 
			
			cQry += " ) AND SE2.D_E_L_E_T_ = ' ' "

			cQry += " AND EXISTS (SELECT FK2.FK2_IDFK2 FROM " + RetSqlName("FK2") + " FK2 "
			cQry += " WHERE "
			cQry += 		" FK2.FK2_IDDOC = FK7.FK7_IDDOC "
			
			cQry += 		" AND FK2.FK2_RECPAG = 'P' "
			cQry += 		" AND FK2.FK2_TPDOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE','E2','CH','ES') "
			cQry += 		" AND FK2.FK2_MOTBX NOT IN ('FAT','LIQ','DEV', 'CMP') "
			
			If !Empty(dDataPgDe) .AND. !Empty(dDataPgAte) 
				If __nBx2040 == 2 // baixa
					cQry += "AND FK2.FK2_DATA >= '" + Dtos(dDataPgDe ) + "' AND FK2.FK2_DATA <= '" + Dtos(dDataPgAte) + "' "
				Else
					cQry += "AND FK2.FK2_DTDISP >= '" + Dtos(dDataPgDe ) + "' AND FK2.FK2_DTDISP <= '" + Dtos(dDataPgAte) + "' "
				EndIf	
			EndIf
			cQry += " AND FK2.D_E_L_E_T_ = ' ' "
			cQry += " ) "
			cQry += " AND SE2.D_E_L_E_T_ = ' ' "

			cQry	:= ChangeQuery(cQry)

			If __oBxFinCP <> Nil
				__oBxFinCP:Delete()
				__oBxFinCP := Nil
			EndIf

			aStru := {{ 'E2_FILIAL', "C",TAMSX3("E2_FILIAL")[1],0}, ;
				{ 'E2_PREFIXO', "C",TAMSX3("E2_PREFIXO")[1],0}, ;
				{ 'E2_NUM', "C",TAMSX3("E2_NUM")[1],0}, ;
				{ 'E2_PARCELA', "C",TAMSX3("E2_PARCELA")[1],0}, ;
				{ 'E2_TIPO', "C",TAMSX3("E2_TIPO")[1],0}, ;
				{ 'COD', "C",TAMSX3("E2_FORNECE")[1],0}, ;
				{ 'LOJA', "C",TAMSX3("E2_LOJA")[1],0}, ;
				{ 'E2_EMIS1', "C",TAMSX3("E2_EMIS1")[1],0}, ;
				{ 'E2_EMISSAO',"C",TAMSX3("E2_EMISSAO")[1],0}, ;
				{ 'E2_VENCTO', "C",TAMSX3("E2_VENCTO")[1],0}, ;
				{ 'E2_VENCREA', "C",TAMSX3("E2_VENCREA")[1],0}, ;
				{ 'E2_NATUREZ', "C",TAMSX3("E2_NATUREZ")[1],0}, ;
				{ 'E2_HIST', "C",TAMSX3("E2_HIST")[1],0}, ;
				{ 'RECSE2', "N", 10, 0 }, ;
				{ 'E2_VALOR', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
				{ 'E2_IRRF', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
				{ 'E2_INSS',"N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
				{ 'E2_PIS', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
				{ 'E2_COFINS', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
				{ 'E2_CSLL', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
				{ 'E2_ISS', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
				{ 'DESDOBR', "C",TAMSX3("E2_DESDOBR")[1],0}, ;
				{ 'E2_SEST', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
				{ 'E2_BASEINS', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
				{ 'E2_ORIGEM', "C",TAMSX3("E2_ORIGEM")[1],0}, ;
				{ 'E2_CONTAD', "C",TAMSX3("E2_CONTAD")[1],0}, ;
				{ 'E2_CODRET', "C",TAMSX3("E2_CODRET")[1],0}, ;
				{ 'E2_VRETPIS', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
				{ 'E2_VRETCOF', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
				{ 'E2_VRETCSL', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
				{ 'E2_SALDO', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]}, ;
				{ 'A2_CGC', "C",TAMSX3("A2_CGC")[1],0}, ;
				{ 'A2_NOME', "C",TAMSX3("A2_NOME")[1],0}, ;
				{ 'A2_END', "C",TAMSX3("A2_END")[1],0}, ;
				{ 'A2_BAIRRO', "C",TAMSX3("A2_BAIRRO")[1],0}, ;
				{ 'A2_MUN', "C",TAMSX3("A2_MUN")[1],0}, ;
				{ 'A2_EST', "C",TAMSX3("A2_EST")[1],0}, ;
				{ 'A2_CEP', "C",TAMSX3("A2_CEP")[1],0}, ;
				{ 'A2_NUMDEP', "C",TAMSX3("A2_NUMDEP")[1],0}, ;
				{ 'A2_CALCIRF', "C",TAMSX3("A2_CALCIRF")[1],0}, ;
				{ 'A2_RECINSS', "C",TAMSX3("A2_RECINSS")[1],0}, ;
				{ 'A2_RECNO', "N", 10, 0 }, ;
				{ 'ED_CODIGO', "C",TAMSX3("ED_CODIGO")[1],0}, ;
				{ 'ED_CALCINS', "C",TAMSX3("ED_CALCINS")[1],0}, ;
				{'TPREX', "C", TAMSX3("A2_TPREX")[1], 0 }, { 'TRBEX', "C", TAMSX3("A2_TRBEX")[1], 0 }, ;
				{ 'ED_PERCINS', "N",TAMSX3("ED_PERCINS")[1], TAMSX3("ED_PERCINS")[2]}, ;
				{ 'FK7_IDDOC', "C", TAMSX3("FK7_IDDOC")[1], 0 }, ;
				{ 'FKF_CPRB', "C",TAMSX3("FKF_CPRB")[1],0}, ;
				{ 'FKF_CNAE', "C",TAMSX3("FKF_CNAE")[1],0}, ;
				{ 'FKF_TPREPA', "C",TAMSX3("FKF_TPREPA")[1],0}, ;
				{ 'FKF_INDSUS', "C",TAMSX3("FKF_INDSUS")[1],0}, ;
				{ 'FKF_INDDEC', "C",TAMSX3("FKF_INDDEC")[1],0}, ;
				{ 'FKF_TPSERV', "C",TAMSX3("FKF_TPSERV")[1],0}, ;
				{ 'FKF_CNO', "C",TAMSX3("FKF_CNO")[1],0}, ;
				{ 'FKF_ORIINS', "N",TAMSX3("FKF_ORIINS")[1],TAMSX3("FKF_ORIINS")[2]}, ;
				{ 'DTBXFIN', "C",TAMSX3("FK2_DATA")[1],0}, ;
				{ 'VLBXFIN', "N",TAMSX3("E2_VLCRUZ")[1],TAMSX3("E2_VLCRUZ")[2]} }

			__oBxFinCP := FwTemporaryTable():New( __cBxFinCP )
			__oBxFinCP:SetFields(aStru)
			__oBxFinCP:AddIndex('1', {'FK7_IDDOC'})
			
			__oBxFinCP:Create()

			For nLoop := 1 to Len(aStru)
				cFields += aStru[nLoop][1] + ","//Nome do campo
			Next
			cFields := Left(cFields, Len(cFields) -1) //Remover a ultima vírgula
							
			TcSQLExec("Insert Into " + __oBxFinCP:GetRealName() ;
				+ " (" + cFields + ") (" + cQry + ") " )
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³PE permite regra customizada para o retorno de titulos     ³
	//³para a REINF, podendo por exemplo trazer titulos com valor ³
	//³de INSS zerado.                                            ³
	//³Caso contrario segue a regra padrao, de descartar os que   ³
	//³nao sofreram retencao de INSS                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If ExistBlock("F989CPIN")                        			
	 	cQuery += ExecBlock("F989CPIN",.F.,.F.,{cQuery})
	EndIf			
	cQuery += " ORDER BY E2_FILIAL,COD,LOJA,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO"

 	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSE2,.F.,.T.)

	For nLoop := 1 To Len( aCpoNum )
		aTamSX3Cpo := TamSX3(aCpoNum[nLoop])
		TcSetField( cAliasSE2, aCpoNum[nLoop], "N",aTamSX3Cpo[1],aTamSX3Cpo[2])
	Next nLoop 	

 	lPagQry	  := .T.
 	
 	cFilFiscal := cFilAnt	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IniVarStat        

Inicializa as variaveis statics

@Return nil 

@author Karen Honda
@since  10/10/2017
@version 1.0

/*/                                 
//-------------------------------------------------------------------

Static Function IniVarStat()
nTamFil    := TamSx3( "E2_FILIAL" )[1]
nTamE2Pref := TamSx3( "E2_PREFIXO" )[1]
nTamE2Num  := TamSx3( "E2_NUM" )[1]
nTamE2Par  := TamSx3( "E2_PARCELA" )[1]
nTamE2Tipo := TamSx3( "E2_TIPO" )[1]
nTamE2For  := TamSx3("E2_FORNECE")[1]
nTamE2Lj   := TamSx3("E2_LOJA")[1]

nTamE1Pref := TamSx3( "E1_PREFIXO" )[1]
nTamE1Num  := TamSx3( "E1_NUM" )[1]
nTamE1Par  := TamSx3( "E1_PARCELA" )[1]
nTamE1Tipo := TamSx3( "E1_TIPO" )[1]
nTamE1Cli  := TamSx3("E1_CLIENTE")[1]
nTamE1Lj   := TamSx3("E1_LOJA")[1]

nTamFTDoc  := TamSx3( "FT_NFISCAL" )[1]
nTamFTSer  := TamSx3( "FT_SERIE" )[1]
nTamF2Tip  := TamSx3( "F2_TIPO" )[1]

nTamNumPro := TAMSX3("C1G_NUMPRO")[1]
nTamDescr  := TAMSX3("C1G_DESCRI")[1]
nTamIDSEJU := TAMSX3("CCF_IDSEJU")[1]
nTamVara   := TAMSX3("C1G_VARA")[1]
nTamCodC18 := TAMSX3("C18_CODIGO")[1]
cBDname	:= Upper( TCGetDB() )
cSrvType := TcSrvType()
_lPCCBaixa  := SuperGetMv("MV_BX10925",.T.,"2") == "1"
nTamCCFNum := TAMSX3("CCF_NUMERO")[1]

If "MSSQL" $ cBDname 
	cConcat := "+"
ElseIf cBDname $ "MYSQL|POSTGRES"
	cConcat := ","
Else
	cConcat := "||"
EndIf

If cBDname $ "ORACLE|DB2|POSTGRES|INFORMIX" 
	cSubstSQL := "SUBSTR"
Else
	cSubstSQL := "SUBSTRING"
EndIf

If cBDname $ "INFORMIX*ORACLE"
	cIsNullSQL := "NVL"
ElseIf  cBDname $ "DB2*POSTGRES"  .OR. ( cBDname == "DB2/400" .And. Upper(cSrvType) == "ISERIES" )  
	cIsNullSQL := "COALESCE" 
Else
	cIsNullSQL := "ISNULL"
EndIf

If lAI0_INDPAA == nil
	DBSelectArea("AI0")
	lAI0_INDPAA := AI0->(FieldPos("AI0_INDPAA")) > 0
EndIf
Return




//-------------------------------------------------------------------
/*/{Protheus.doc} FINR989 
Gera o relatorio dos titulos enviados para o TAF pelo extrator financeiro 
Está no mesmo fonte, para não perder o alias da tabela temporaria, ao chamar o reportprint
@param cAliasTRB, caracter, Alias da tabela temporaria

@return Nil 

@author Karen Honda
@since 21/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Function FINR989()
Local oReport := Nil

oReport := ReportDef()
oReport:PrintDialog()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef 
Define a estrutura do relatorio 

@author Karen Honda
@since 21/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef()

Local oReport
Local oSection1
Local oSection2

oReport := TReport():New("FINR989",STR0017,,{|oReport| ReportPrint(oReport)},STR0018) //"Títulos enviados ao TAF" - "Extrator Financeiro"

//Gestao
oReport:SetUseGC(.F.)

oSection1 := TRSection():New(oReport,STR0019,,,,,,) //"Cliente/Fornecedor"
TRCell():New(oSection1,"FILIAL" ,cAliasTRB,	,,10+nTamFil  ,.F.,{|| STR0020 + (cAliasTRB)->FILIAL }) //"Filial: "
TRCell():New(oSection1,"RECPAG" ,cAliasTRB,,,20  ,.F.,{||STR0021 +  If((cAliasTRB)->RECPAG=="P", STR0022,STR0023) }) // "Carteira: " "Pagar" "Receber"
TRCell():New(oSection1,"CLIFOR" ,cAliasTRB,	,,Max(nTamE1Cli,nTamE2For)+Max(nTamE1Lj,nTamE2Lj)+15  ,.F.,{|| STR0024+ (cAliasTRB)->CLIFOR +"/"+ (cAliasTRB)->LOJA }) //"Código/Loja: "
TRCell():New(oSection1,"NOME" ,cAliasTRB,	,,30  ,.F.,{|| If((cAliasTRB)->RECPAG=="P", SA2->A2_NREDUZ,SA1->A1_NREDUZ)})
TRCell():New(oSection1,"CPFCGC" ,cAliasTRB,	,,24  ,.F.,{|| STR0025 + If((cAliasTRB)->RECPAG=="P", SA2->A2_CGC,SA1->A1_CGC)}) //"CNPJ/CPF: "
oSection1:SetHeaderPage(.F.)
oSection1:SetHeaderBreak(.F.)
oSection1:SetHeaderSection(.F.)

oSection2 := TRSection():New(oReport,STR0026,{cAliasTRB,"FKF"},,,,,.T.) //"Títulos"
TRCell():New(oSection2,"PREFIXO"	,cAliasTRB,RetTitle("E1_PREFIXO"),,Max(nTamE2Pref,nTamE1Pref),.F.,{||(cAliasTRB)->PREFIXO})
TRCell():New(oSection2,"NUMERO" 	,cAliasTRB,RetTitle("E1_NUM")  	 ,,Max(nTamE1Num,nTamE2Num)  ,.F.,{||(cAliasTRB)->NUMERO})
TRCell():New(oSection2,"PARCELA"	,cAliasTRB,RetTitle("E1_PARCELA"),,Max(nTamE1Par,nTamE2Par)  ,.F.,{||(cAliasTRB)->PARCELA})
TRCell():New(oSection2,"TIPO"		,cAliasTRB,RetTitle("E1_PREFIXO"),,Max(nTamE1Tipo,nTamE2Tipo),.F.,{||(cAliasTRB)->TIPO})
TRCell():New(oSection2,"EMISSAO"	,cAliasTRB,STR0027 				 ,,10 ,.F.,{||(cAliasTRB)->EMISSAO}) //"Emissão"
TRCell():New(oSection2,"TPSERV"		,cAliasTRB,RetTitle("FKF_TPSERV"),,02 ,.F.,{||(cAliasTRB)->TPSERV})
TRCell():New(oSection2,"TPREPASSE"	,cAliasTRB,RetTitle("FKF_TPREPA"),,02 ,.F.,{|| (cAliasTRB)->TPREPASSE   })
TRCell():New(oSection2,"VLBRUTO"	,cAliasTRB,RetTitle("E1_VALOR")  ,"@E 9,999,999,999,999.99",18 ,.F.,{||(cAliasTRB)->VLBRUTO})
TRCell():New(oSection2,"VLBASEINSS"	,cAliasTRB,RetTitle("E1_BASEINS"),"@E 9,999,999,999,999.99",18 ,.F.,{||(cAliasTRB)->VLBASEINSS})
TRCell():New(oSection2,"VLINSS"		,cAliasTRB,RetTitle("E1_INSS") 	 ,"@E 999,999,999.99",14 ,.F.,{||(cAliasTRB)->VLINSS})
TRCell():New(oSection2,"DEDINSS"	,cAliasTRB,STR0028 	 			 ,"@E 999,999,999.99",14 ,.F.,{||(cAliasTRB)->DEDINSS}) //"Deduçoes "
TRCell():New(oSection2,"DEDPROCJD"	,cAliasTRB,STR0029 				 ,"@E 999,999,999.99",14 ,.F.,{||(cAliasTRB)->DEDPROCJD}) //"Processo Jud."

oSection2:Cell("VLBRUTO"):SetHeaderAlign("RIGHT")
oSection2:Cell("VLBASEINSS"):SetHeaderAlign("RIGHT")
oSection2:Cell("VLINSS"):SetHeaderAlign("RIGHT")
oSection2:Cell("DEDINSS"):SetHeaderAlign("RIGHT")
oSection2:Cell("DEDPROCJD"):SetHeaderAlign("RIGHT")

oBreak2 := TRBreak():New(oSection2,{ || (cAliasTRB)->(FILIAL+RECPAG+CLIFOR+LOJA) },STR0030,.F.) //'Sub-Total:'
oBreak2:OnPrintTotal({||oReport:SkipLine(1)})
TRFunction():New ( oSection2:Cell("NUMERO"),, 'COUNT',oBreak2, STR0031,,,.F.,.T.,.F.,oSection2,,,) //"Total Títulos"
TRFunction():New ( oSection2:Cell("VLBRUTO"),, 'SUM',oBreak2, STR0032,,,.F.,.F.,.F.,oSection2,,,) //"Total Vl.Bruto"
TRFunction():New ( oSection2:Cell("VLBASEINSS"),, 'SUM',oBreak2, STR0033,,,.F.,.F.,.F.,oSection2,,,) //"Total Base INSS"
TRFunction():New ( oSection2:Cell("VLINSS"),, 'SUM',oBreak2, STR0034,,,.F.,.F.,.F.,oSection2,,,) //"Total Vl.INSS"

oReport:SetPortrait()

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint 
Realiza a impressão do relatorio
@param oReport, objeto, Objeto Treport 

@author Karen Honda
@since 21/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local cCodAnt := ""

DBSelectArea("SA1")
SA1->(DBSetOrder(1)) //A1_FILIAL, A1_COD, A1_LOJA, R_E_C_N_O_, D_E_L_E_T_

DBSelectArea("SA2")
SA2->(DBSetOrder(1)) //A1_FILIAL, A1_COD, A1_LOJA, R_E_C_N_O_, D_E_L_E_T_

DBSelectArea(cAliasTRB)
(cAliasTRB)->(DBSetOrder(2))
(cAliasTRB)->(DBGotop())

oSection1:Init()
While (cAliasTRB)->(!EOF())					
	
			
	If (cAliasTRB)->(FILIAL+RECPAG+CLIFOR+LOJA) <> cCodAnt	
				
		cCodAnt := (cAliasTRB)->(FILIAL+RECPAG+CLIFOR+LOJA)
		If (cAliasTRB)->RECPAG == "P"
			SA2->(DBSeek(xFilial("SA2",(cAliasTRB)->FILIAL) + (cAliasTRB)->CLIFOR + (cAliasTRB)->LOJA))
		Else
			SA1->(DBSeek(xFilial("SA1",(cAliasTRB)->FILIAL) + (cAliasTRB)->CLIFOR + (cAliasTRB)->LOJA))
		EndIF
		
		oReport:ThinLine()
		oSection1:PrintLine()
		
	EndIf
	oSection2:Init()
	oSection2:PrintLine()
				
	(cAliasTRB)->(DbSkip())
	
	If (cAliasTRB)->(FILIAL+RECPAG+CLIFOR+LOJA)  <> cCodAnt
		oSection2:Finish()
	EndIf	
EndDo

oSection1:Finish()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FFinT157 
Exporta o cadastro de obras
@param cAliasQry, caracter, Alias da query 

@author Karen Honda
@since 21/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function FFinT157(nCart,cAliasQry)
Local lRet := .T.
Local aRegs    := {}
Local cReg     := "T157" // código do registro no TAF
Local cFilialTAF:= ""

Local lGeraT157 := .T. 


DbSelectArea("SON")
SON->(DBSetOrder(1))
If SON->(DBSeek( xFilial("SON") + (cAliasQry)->FKF_CNO )) .and. aScan(aT157Env,{ |x| x[1] + x[2] == xFilial("SON") + SON->ON_CNO }) == 0


	If lIntTAF
		
		cFilialTAF:= FTafGetFil( allTrim( cEmpAnt ) + allTrim( cFilAnt ) , {} , "T9C" )
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se no TAF o registro existe e não ha alteracoes. ³
		//³Caso exista e nao haja alteracoes nos campos,NAO geramos  ³
		//³o registro na TAFST1 para a integracao.                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("T9C")
		T9C->(DBSetOrder(3))		
		If T9C->( MsSeek( cFilialTAF +  SON->ON_TPINSCR + SON->ON_CNO))
				
			If  Alltrim(T9C->T9C_TPINSC)   == SON->ON_TPINSCR  .And. ;
				Alltrim(T9C->T9C_NRINSC)   == Alltrim(SON->ON_CNO)  .And. ;
				Alltrim(T9C->T9C_INDOBR)   == Alltrim(SON->ON_IDOBRA)  .And. ;
				Alltrim(T9C->T9C_DSCOBR)   == Alltrim(SON->ON_DESC)  //.And. ;
				//Alltrim(T9C->T9C_INDTER)   == Alltrim(SON->ON_CNO)  		
				
				lGeraT157 := .F.
			EndIf
		EndIf
					
	EndIf
	
	If lGeraT157
	
		//Gera T157 - Cadastro de Obras
		cReg     := "T157"
		Aadd( aRegs, {  ;
		cReg,; 			// 1 Registro T157-Cadastro de Obras
		SON->ON_TPINSCR,;		// 2 TP_INSCRICAO
		SON->ON_CNO,;	// 3	NR_INSC_ESTAB
		SON->ON_IDOBRA,;// 4	IND_OBRA
		Iif(SON->ON_TPOBRA == "2","1","2"),;// 5	IND_TERCEIRO
		Substr(SON->ON_DESC,1,30);// 6	DESCRICAO
		})
		
		FConcTxt( aRegs, nHdlTxt )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grvava o registro na TABELA TAFST1 e limpa o array aDadosST1.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTpSaida == "2" //.and. !lExtFiscal
			FConcST1()
		EndIf
	
		aAdd(aT157Env, {xFilial("SON"), SON->ON_CNO})
	EndIf
EndIF
Return lRet

/*/{Protheus.doc} AddHash
@author Bruno Cremaschi
@since 25.02.2019
/*/
//-------------------------------------------------------------------

Static Function AddHash(oHash,cChave,nPos)
Local cSet  := "HMSet"

&cSet.(oHash, cChave, nPos)

Return

//-------------------------------------------------------------------
/*/
{Protheus.doc} AddHash
@author Bruno Cremaschi
@since 25.02.2019

/*/
//-------------------------------------------------------------------
Static Function FindHash(oHash, cChave)
Local nPosRet	:= 0
Local cGet    := "HMGet"

&cGet.( oHash , cChave  , @nPosRet )

Return nPosRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FEXPT003 
Chamada pelo extrator fiscal para exportação do T003 do financeiro
@param cFilQry, caracter, filial em execução
@param cTipoSaida, caracter, "1-Arquivo TXT", "2-Banco a Banco"
@param nHandle, numérico, numero do handle, se for arquivo TXT
@param aWizard, array, informações do wizard do extrator fiscal

@author Karen Honda
@since 21/11/2017
@version P12
/*/
//-------------------------------------------------------------------

Function FEXPT003(cFilQry, cTipoSaida, nHandle, aWizard, lExtReinf, lFiltReinf, cFiltInt, _aListT003 )
Local aFils := {}
Local aResWiz2 := Array(10)
Local aResWiz3 := Array(11)
Local aResWiz4 := Array(4)
Local aResWiz5 := Array(8)

Default lExtReinf	:= .f.
Default lFiltReinf 	:= .f.
Default cFiltInt	:= "3"
Default _aListT003  := {}

lGerou := .F.

FFinIniVar(cFilQry, cTipoSaida, nHandle, aWizard, @aFils, @aResWiz2, @aResWiz3, @aResWiz4, @aResWiz5, "T003", lFiltReinf, cFiltInt)

FinExpTAF(/*1*/,/*2*/,aFils,aResWiz2,aResWiz3,aResWiz4,aResWiz5,/*8*/,/*9*/,lExtReinf,lFiltReinf,cFiltInt,@_aListT003 )

Return lGerou
		
//-------------------------------------------------------------------
/*/{Protheus.doc} FExpT001AB 
Chamada pelo extrator fiscal para exportação do T001AB do financeiro
@param cFilQry, caracter, filial em execução
@param cTipoSaida, caracter, "1-Arquivo TXT", "2-Banco a Banco"
@param nHandle, numérico, numero do handle, se for arquivo TXT
@param aWizard, array, informações do wizard do extrator fiscal

@author Karen Honda
@since 21/11/2017
@version P12
/*/
//-------------------------------------------------------------------		
Function FExpT001AB(cFilQry, cTipoSaida, nHandle, aWizard, lExtReinf, lFiltReinf, cFiltInt)

Local aFils := {}
Local aResWiz2 := Array(10)
Local aResWiz3 := Array(11)
Local aResWiz4 := Array(4)
Local aResWiz5 := Array(8)

Default lExtReinf := .f.
Default lFiltReinf 	:= .f.
Default cFiltInt	:= "3"

lGerou := .F.

FFinIniVar(cFilQry, cTipoSaida, nHandle, aWizard, @aFils, @aResWiz2, @aResWiz3, @aResWiz4, @aResWiz5, "T001AB", lFiltReinf, cFiltInt)

FinExpTAF(,,aFils,aResWiz2,aResWiz3,aResWiz4,aResWiz5,,,lExtReinf, lFiltReinf, cFiltInt)

Return lGerou

//-------------------------------------------------------------------
/*/{Protheus.doc} FExpT157 
Chamada pelo extrator fiscal para exportação do T157 do financeiro
@param cFilQry, caracter, filial em execução
@param cTipoSaida, caracter, "1-Arquivo TXT", "2-Banco a Banco"
@param nHandle, numérico, numero do handle, se for arquivo TXT
@param aWizard, array, informações do wizard do extrator fiscal

@author Karen Honda
@since 21/11/2017
@version P12
/*/
//-------------------------------------------------------------------		
Function FExpT157(cFilQry, cTipoSaida, nHandle, aWizard, lExtReinf)

Local aFils := {}
Local aResWiz2 := Array(10)
Local aResWiz3 := Array(11)
Local aResWiz4 := Array(4)
Local aResWiz5 := Array(8)

Default lExtReinf := .f.
Default lFiltReinf 	:= .f.
Default cFiltInt	:= "3"

FFinIniVar(cFilQry, cTipoSaida, nHandle, aWizard, @aFils, @aResWiz2, @aResWiz3, @aResWiz4, @aResWiz5, "T157")

FinExpTAF(,,aFils,aResWiz2,aResWiz3,aResWiz4,aResWiz5,,,lExtReinf)

Return	

//-------------------------------------------------------------------
/*/{Protheus.doc} FExpT157 
Chamada pelo extrator fiscal para exportação do T154 do financeiro
@param cFilQry, caracter, filial em execução
@param cTipoSaida, caracter, "1-Arquivo TXT", "2-Banco a Banco"
@param nHandle, numérico, numero do handle, se for arquivo TXT
@param aWizard, array, informações do wizard do extrator fiscal

@author Karen Honda
@since 21/11/2017
@version P12
/*/
//-------------------------------------------------------------------	
Function FExpT154(cFilQry, cTipoSaida, nHandle, aWizard, aParticip, lExtReinf, lFiltReinf, cFiltInt)

Local aFils := {}
Local aResWiz2 := Array(10)
Local aResWiz3 := Array(11)
Local aResWiz4 := Array(4)
Local aResWiz5 := Array(8)

Default aParticip := {}
Default lExtReinf := .f.
Default lFiltReinf 	:= .f.
Default cFiltInt	:= "3"

lGerou := .F.

FFinIniVar(cFilQry, cTipoSaida, nHandle, aWizard, @aFils, @aResWiz2, @aResWiz3, @aResWiz4, @aResWiz5, "T154", lFiltReinf, cFiltInt)

FinExpTAF(,,aFils,aResWiz2,aResWiz3,aResWiz4,aResWiz5,,@aParticip,lExtReinf, lFiltReinf, cFiltInt)

Return __lGer154

//-------------------------------------------------------------------
/*/{Protheus.doc} FFinIniVar 
Inicializa os array com as informações do wizard fiscal

@param cFilQry, caracter, filial em execução
@param cTipoSaida, caracter, "1-Arquivo TXT", "2-Banco a Banco"
@param nHandle, numérico, numero do handle, se for arquivo TXT
@param aWizard, array, informações do wizard do extrator fiscal
@param aFils, array, filial a ser executada
@param aResWiz2, array, Parametros do titulo a receber
@param aResWiz3, array, Parametros do titulo a pagar e baixas 
@param aResWiz4, array, Parametros tipo de saida
@param aResWiz5, array, Parametros layout
@param cLayout, caracter, layout que será exportado

@author Karen Honda
@since 21/11/2017
@version P12
/*/
//-------------------------------------------------------------------	
Function FFinIniVar(cFilQry, cTipoSaida, nHandle, aWizard, aFils, aResWiz2, aResWiz3, aResWiz4, aResWiz5, cLayout, lFiltReinf, cFiltInt)

Default lFiltReinf := .F.
Default cFiltInt := "3"

//Seta static que a execução está sendo chamada pelo extrator fiscal
lExtFiscal := .T.
aFils := {}
Aadd(aFils,cFilQry )

//Se mudar de filial, refaz a query dos titulos 
If cFilFiscal != cFilAnt
	lPagQry := .F.
	lRecQry := .F.
EndIf

// Parametros do titulo a receber
aResWiz2[1]	 := Val(aWizard[1][1]) //Considera Data 1 - Data de Contabilização (EMIS1) 2-Data de Emissão (EMISSAO)
aResWiz2[2]	 := aWizard[1][2] //Data de
aResWiz2[3]	 := aWizard[1][3] //Data até
aResWiz2[4]  := 4	//Tipo de Pessoa	"1-Pessoa Física","2-Pessoa Jurídica","3-Todas"
aResWiz2[5]	 := ""//Cliente De
aResWiz2[6]	 := ""//Cliente Ate
aResWiz2[7]	 := ""//Loja De
aResWiz2[8]	 := ""//Loja Ate
aResWiz2[9]	 := aWizard[1][4] // Nota fiscal de
aResWiz2[10] := aWizard[1][5] // Nota fiscal Ate	

// Parametros do titulo a pagar e baixas 
aResWiz3[1]	:= Val(aWizard[2][1]) //Considera Data 1 - Emissão Digita. (EMIS1) 2-Emissão Real (EMISSAO)
aResWiz3[2]	:= 3 //Considera Data "1-Data Vencto Real (VENCREA)", "2-Data Vencto (VENCTO)", "3-Data baixa (BAIXA)"
aResWiz3[3]	:= aWizard[2][2]//Data de
aResWiz3[4]	:= aWizard[2][3]//Data até
aResWiz3[5]	:= 4
aResWiz3[6]	:= ""
aResWiz3[7]	:= ""
aResWiz3[8]	:= ""
aResWiz3[9]	:= ""
aResWiz3[10]:= aWizard[1][4] // Nota fiscal de
aResWiz3[11]:= aWizard[1][5] // Nota fiscal Ate

//Parametros tipo de saida	
aResWiz4[1] := Val(cTipoSaida)
aResWiz4[2] := ""
aResWiz4[3] := ""
aResWiz4[4] := If(Empty(nHandle), 0, nHandle)
	
	
// Parametros layout
aResWiz5 := {.F., .F., .F., .F., .F., .F., .F., .F.  }

__nBx2030	:= Val(aWizard[3][1]) //Considera Data 1 - Data de Contabilização (EMIS1) 2-Data de Emissão (EMISSAO)
__nBx2040	:= Val(aWizard[4][1]) //Considera Data 1 - Data de Contabilização (EMIS1) 2-Data de Emissão (EMISSAO)

If  cLayout == "T001AB"
	aResWiz5[1] := .T. // T001AB
ElseIf	cLayout == "T003"	
	aResWiz5[2] := .T. // T003
ElseIf cLayout == "T154"
	If lFiltReinf  .And. (cFiltInt $ "1|3" .Or. empty(cFiltInt))
		aResWiz5[2] := .T. // T003
	EndIf
	aResWiz5[3] := .T. // T154CR
	aResWiz5[4] := .T. // T154CP
	aResWiz5[5] := .T. // T154AA
ElseIf cLayout == "T157"
	aResWiz5[8] := .T.	// T157
EndIf

Return	

//-------------------------------------------------------------------
/*/{Protheus.doc} FFinExtFim 
Chamada pelo extrator fiscal para finalizar a extração e fechar as tabelas do fin
@author Karen Honda
@since 21/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Function FFinExtFim()
	If !Empty(cAliasRQry)
		(cAliasRQry)->(DBCloseArea())
		cAliasRQry := nil
	Endif	
		
	If !Empty(cAliasPQry)
		(cAliasPQry)->(DBCloseArea())
		cAliasPQry := nil
	EndIf	
	
	FTmpClean()	
	
	aSize(aT157Env,0)
	aT157Env := {}

	aSize(aT001ABEnv,0)
	aT001ABEnv := {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FFinExtOK
Chamada pelo extrator fiscal para verificar se o ambiente está atualizado para poder chamar o fin
@author Karen Honda
@since 21/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Function FFinExtOK()
Local lRet := .T.
If AliasInDic("FKG")
	If FKG->(FieldPos("FKG_CALCUL")) == 0
		lRet := .F.
	EndIf 
Else
	lRet := .F. 
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FatuCrT003
Faturas Contas a Receber, chamada pelo extrator fiscal para listar de forma distinta todos os clientes,
quando reinf = 'sim' e fitra = 'apenas cadastros', é necessário rodar as movimentações para identificar 
os participantes para o reinf.
@author Denis Souza
@since 15/05/2019
@version P12
/*/
//-------------------------------------------------------------------

Function FatuCrT003( aRegT003, oWizard )

	Local cQuery 	 := ""
	Local dDataEmDe	 := CtoD('  /  /    ')
	Local dDataEmAte := CtoD('  /  /    ')
	Local nTpEmData	 := 2

	If Type("oWizard") == "O"
		dDataEmDe	:= oWizard:GetDataDe()
		dDataEmAte	:= oWizard:GetDataAte()
		nTpEmData	:= Val( oWizard:GetTituReceber() )

		If Empty( cAliaSE1 )
			cAliaSE1 := GetNextAlias()
		EndIf

		cQuery := "SELECT DISTINCT( SA1.R_E_C_N_O_ ) A1_RECNO "
		cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
		cQuery += " INNER JOIN "+ RetSqlName("SA1") + " SA1 "
		cQuery += " ON (SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQuery += " AND SA1.A1_COD = SE1.E1_CLIENTE"
		cQuery += " AND SA1.A1_LOJA = SE1.E1_LOJA "

		cQuery += " AND SA1.A1_PESSOA IN ('J', 'F', 'X')  "
		cQuery += " AND SA1.D_E_L_E_T_ = ' ' )"

		cQuery += " INNER JOIN "+ RetSqlName("SED") + " SED "
		cQuery += " ON ( SED.ED_FILIAL = '" + xFilial("SED") + "'"
		cQuery += " AND SED.ED_CODIGO = SE1.E1_NATUREZ "
		cQuery += " AND SED.D_E_L_E_T_ = ' ' )"

		cQuery += " LEFT JOIN " + RetSqlName("FK7") + " FK7 ON ( FK7.FK7_FILIAL = '"+ xFilial("FK7") +"' AND FK7.FK7_ALIAS = 'SE1' AND "
		cQuery += " FK7.FK7_CHAVE = "

		If cBDname $ "MYSQL|POSTGRES"
			cQuery += "CONCAT( "
		EndIf
		cQuery += " SE1.E1_FILIAL "	+ cConcat + " '|' " + cConcat
		cQuery += " SE1.E1_PREFIXO "+ cConcat + " '|' " + cConcat
		cQuery += " SE1.E1_NUM "	+ cConcat + " '|' " + cConcat
		cQuery += " SE1.E1_PARCELA "+ cConcat + " '|' " + cConcat
		cQuery += " SE1.E1_TIPO "	+ cConcat + " '|' " + cConcat
		cQuery += " SE1.E1_CLIENTE "+ cConcat + " '|' " + cConcat
		cQuery += " SE1.E1_LOJA "
		If cBDname $ "MYSQL|POSTGRES"
			cQuery += ") "
		EndIf

		cQuery += " AND FK7.D_E_L_E_T_ = ' ') "
		cQuery += "LEFT JOIN " + RetSqlName("FKF") + " FKF "
		cQuery += "ON ( FKF.FKF_FILIAL = '" + xFilial("FKF") + "' AND"
		cQuery += " FKF.FKF_IDDOC = FK7.FK7_IDDOC AND FKF.D_E_L_E_T_ = ' ' ) "
		cQuery += " WHERE E1_FILIAL = '" + xFilial("SE1") + "' "

		If !Empty(dDataEmDe) .And. !Empty(dDataEmAte)
			If nTpEmData == 1
				cQuery += "AND  ( SE1.E1_EMIS1 >= '" + Dtos(dDataEmDe) + "' AND SE1.E1_EMIS1 <= '" + Dtos(dDataEmAte) + "') "
			ElseIf nTpEmData == 2
				cQuery += "AND  ( SE1.E1_EMISSAO >= '" + Dtos(dDataEmDe) + "' AND SE1.E1_EMISSAO <= '" + Dtos(dDataEmAte) + "') "
			EndIf	
		EndIf

		cQuery += " AND SE1.E1_TIPO NOT IN " + FormatIn(MVABATIM+"|"+MV_CRNEG +"|" +MVPROVIS+"|"+MVRECANT+"|"+MV_CPNEG+ "|"+ MVTAXA+"|"+MVTXA+"|"+MVINSS+"|"+"SES","|")  + " "
		cQuery += " AND SE1.E1_FILORIG = '" + cFilAnt + "' "
		cQuery += " AND SE1.E1_FATURA NOT IN ('NOTFAT') "
		cQuery += " AND SE1.E1_NUMLIQ = ' ' "
		cQuery += " AND (FKF.FKF_TPSERV != ' ' OR FKF.FKF_TPREPA != ' ' "
		//cQuery += " OR SE1.E1_ORIGEM IN ('MATA461','MATA460','MATA103','MATA100') "
		cQuery += " ) AND SE1.D_E_L_E_T_ = ' ' "

		/*--------------------------------------------------------------|
		| PE permite regra customizada para o retorno de titulos		|
		| para a REINF, podendo por exemplo trazer titulos com valor	|
		| de INSS zerado.												|
		| Caso contrario segue a regra padrao, de descartar os que		|
		| nao sofreram retencao de INSS									|
		---------------------------------------------------------------*/
		If ExistBlock("F989CRIN")
			cQuery += ExecBlock("F989CRIN",.F.,.F., {cQuery})
		Else
			cQuery += "AND ((SA1.A1_RECINSS = 'S' AND SED.ED_CALCINS = 'S') OR SE1.E1_INSS > 0)  " // se recolhe INSS
		Endif
		cQuery += " ORDER BY A1_RECNO "

		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliaSE1,.F.,.T.)

		(cAliaSE1)->(DbGotop())
		While (cAliaSE1)->(!Eof())
			("SA1")->( DbGoTo( (cAliaSE1)->A1_RECNO ) )		
			RegT003Pos( "SA1" , @aRegT003 )
			(cAliaSE1)->(DBSkip())
		EndDo

		If !Empty(cAliaSE1)
			(cAliaSE1)->(DBCloseArea())
			cAliaSE1 := nil
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FatuCpT003
Faturas Contas a Pagar, chamada pelo extrator fiscal para listar de forma distinta todos os fornecedores,
quando reinf = 'sim' e fitra = 'apenas cadastros', é necessário rodar as movimentações para identificar 
os participantes para o reinf.
@author Denis Souza
@since 15/05/2019
@version P12
/*/
//-------------------------------------------------------------------

Function FatuCpT003( aRegT003, oWizard )

	Local cQuery 	 := ""
	Local cCampos 	 := ""
	Local cCamposFim := ""
	Local dDataEmDe	 := CtoD('  /  /    ')
	Local dDataEmAte := CtoD('  /  /    ')
	Local nTpEmData	 := 2

	If Type("oWizard") == "O"
		dDataPgDe	:= oWizard:GetDataDe()
		dDataPgAte	:= oWizard:GetDataAte()
		nTpPgEmis	:= Val( oWizard:GetTituReceber() )

		If Empty( cAliaSE2 )
			cAliaSE2 := GetNextAlias()
		EndIf

		cCampos := " SELECT DISTINCT( SA2.R_E_C_N_O_ ) A2_RECNO "
		cCampos += " FROM " + RetSqlName("SE2") + " SE2 "

		cCampos += " INNER JOIN " + RetSqlName("SA2") + " SA2 "
		cCampos += " ON (SA2.A2_FILIAL = '" + xFilial("SA2") + "'"
		cCampos += " AND SA2.A2_COD = SE2.E2_FORNECE "
		cCampos += " AND SA2.A2_LOJA = SE2.E2_LOJA "
		cCampos += " AND SA2.A2_TIPO IN ('F', 'J', 'X') "
		cCampos += " AND SA2.D_E_L_E_T_ = ' ' )"

		cCampos += " INNER JOIN "+ RetSqlName("SED") + " SED "
		cCampos += " ON ( SED.ED_FILIAL = '" + xFilial("SED") + "'"
		cCampos += " AND SED.ED_CODIGO = SE2.E2_NATUREZ "
		cCampos += " AND SED.D_E_L_E_T_ = ' ' )"

		cCampos += " LEFT JOIN " + RetSqlName("FK7") + " FK7 "
		cCampos += " ON ( FK7.FK7_FILIAL = '" + xFilial("FK7") + "' AND"
		cCampos += " FK7.FK7_ALIAS = 'SE2' AND "

		cCampos += " FK7.FK7_CHAVE = "

		If cBDname $ "MYSQL|POSTGRES"
			cCampos += "CONCAT( "
		EndIf
		cCampos += " SE2.E2_FILIAL "  + cConcat + " '|' " + cConcat
		cCampos += " SE2.E2_PREFIXO " + cConcat + " '|' " + cConcat
		cCampos += " SE2.E2_NUM "	  + cConcat + " '|' " + cConcat
		cCampos += " SE2.E2_PARCELA " + cConcat + " '|' " + cConcat
		cCampos += " SE2.E2_TIPO "	  + cConcat + " '|' " + cConcat
		cCampos += " SE2.E2_FORNECE " + cConcat + " '|' " + cConcat
		cCampos += " SE2.E2_LOJA "
		If cBDname $ "MYSQL|POSTGRES"
			cCampos += ") "
		EndIf

		cCampos += " AND FK7.D_E_L_E_T_ = ' ' "
		cCampos += ") "

		cCampos += " LEFT JOIN " + RetSqlName("FKF") + " FKF "
		cCampos += " ON ( FKF.FKF_FILIAL = '" + xFilial("FKF") + "'"
		cCampos += " AND  FKF.FKF_IDDOC = FK7.FK7_IDDOC AND FKF.D_E_L_E_T_ = ' ' ) "
		cCampos += " WHERE E2_FILIAL = '" + xFilial("SE2") + "' "

		cQuery := cCampos

		If !Empty(dDataPgDe) .And. !Empty(dDataPgAte)
			If nTpPgEmis == 1
				cQuery += "AND ( SE2.E2_EMIS1 >= '" + Dtos(dDataPgDe ) + "' AND SE2.E2_EMIS1 <= '" + Dtos(dDataPgAte) + "') "
			ElseIf nTpPgEmis == 2
				cQuery += "AND ( SE2.E2_EMISSAO >= '" + Dtos(dDataPgDe) + "' AND SE2.E2_EMISSAO <= '" + Dtos(dDataPgAte) + "') "
			EndIf
		EndIf

		cCamposFim := " AND SE2.E2_TIPO NOT IN " + FormatIn(MVABATIM+"|"+MVPROVIS+"|"+MVPAGANT+"|"+MV_CPNEG+"|"+MVIRABT+"|"+MVCSABT+"|"+MVCFABT+"|"+MVPIABT+"|"+MVISS+"|"+ MVTAXA+"|"+MVTXA+"|"+MVINSS+"|"+"SES","|")  + "  "
		cCamposFim += " AND SE2.E2_FILORIG = '" + cFilAnt + "' "	
		cCamposFim += " AND SE2.E2_FATURA NOT IN ('NOTFAT') "	//Desconsidera titulos fatura
		cCamposFim += " AND SE2.E2_NUMLIQ = ' ' " 			   	//Desconsidera titulos liquidados

		cQuery  += cCamposFim
		cCampos += cCamposFim

		cQuery += " AND ((SA2.A2_RECINSS = 'S' AND SED.ED_CALCINS = 'S') OR SE2.E2_INSS > 0 ) "
		cQuery += " AND (FKF.FKF_TPSERV != ' ' OR FKF.FKF_TPREPA != ' ' " 
		//cQuery += " OR SE2.E2_ORIGEM IN ('MATA461','MATA460','MATA103','MATA100') "
		cQuery += " ) AND SE2.D_E_L_E_T_ = ' ' "

		cQuery += "UNION "
		cQuery += cCampos

		cQuery += " AND EXISTS (SELECT SE5.E5_NUMERO FROM " + RetSqlName("SE5") + " SE5 "
		cQuery += " WHERE "
		cQuery += "  SE5.E5_FILIAL = SE2.E2_FILIAL "
		cQuery += "  AND SE5.E5_PREFIXO = SE2.E2_PREFIXO "
		cQuery += "  AND SE5.E5_NUMERO = SE2.E2_NUM "
		cQuery += "  AND SE5.E5_PARCELA = SE2.E2_PARCELA "
		cQuery += "  AND SE5.E5_TIPO = SE2.E2_TIPO "
		cQuery += "  AND SE5.E5_CLIFOR = SE2.E2_FORNECE "
		cQuery += "  AND SE5.E5_LOJA = SE2.E2_LOJA "
		cQuery += "  AND SE5.E5_RECPAG = 'P' "
		cQuery += "  AND SE5.E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','TR','TE','E2','CH','ES','PA') "
		cQuery += "  AND SE5.E5_SITUACA NOT IN ('C','E','X') "
		cQuery += "  AND SE5.E5_MOTBX != 'CMP' "
		cQuery += "  AND SE5.E5_MOTBX NOT IN ('FAT','LIQ','DEV') "

		If !Empty(dDataPgDe) .And. !Empty(dDataPgAte)
			If nTpPgEmis == 1
				cQuery += "AND SE2.E2_VENCREA >= '" + Dtos(dDataPgDe ) + "' AND SE2.E2_VENCREA <= '" + Dtos(dDataPgAte) + "' "
			ElseIf nTpPgEmis == 2
				cQuery += "AND SE2.E2_VENCTO >= '" + Dtos(dDataPgDe ) + "' AND SE2.E2_VENCTO <= '" + Dtos(dDataPgAte) + "' "
			EndIf
		EndIf
		cQuery += " AND SE5.D_E_L_E_T_ = ' ' "
		cQuery += " ) "

		cQuery += " AND SE2.E2_CODRET IN (SELECT X5_CHAVE FROM "+ RetSqlName("SX5") + " WHERE X5_TABELA = '0E' AND D_E_L_E_T_ = ' ') "
		cQuery += " AND SE2.D_E_L_E_T_ = ' ' "

		/*--------------------------------------------------------------|
		| PE permite regra customizada para o retorno de titulos		|
		| para a REINF, podendo por exemplo trazer titulos com valor	|
		| de INSS zerado.												|
		| Caso contrario segue a regra padrao, de descartar os que		|
		| nao sofreram retencao de INSS									|
		---------------------------------------------------------------*/
		If ExistBlock("F989CPIN")                        			
			cQuery += ExecBlock("F989CPIN",.F.,.F.,{cQuery})
		Endif			
		cQuery += " ORDER BY A2_RECNO "

		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliaSE2,.F.,.T.)

		(cAliaSE2)->(DbGotop())
		While (cAliaSE2)->(!Eof())
			("SA2")->( DbGoTo( (cAliaSE2)->A2_RECNO ) )		
			RegT003Pos( "SA2" , @aRegT003 )
			(cAliaSE2)->(DBSkip())
		EndDo

		If !Empty(cAliaSE2)
			(cAliaSE2)->(DBCloseArea())
			cAliaSE2 := nil
		EndIf
	EndIf

Return Nil
