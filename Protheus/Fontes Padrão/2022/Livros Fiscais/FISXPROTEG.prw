#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISxProteg
    (Componentização da função MaFisPROT - 
    Calculo do Fundo de Proteção Social do Estado de Goiás (PROTEGE-GO))
    
	@author Renato Rezende
    @since 17/02/2020
    @version 12.1.25
    
	@param:
	aNfCab -> Array com dados do cabeçalho da nota
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado
	aPos   -> Array com dados de FieldPos de campos
	aInfNat	-> Array com dados da narutureza
	aPE		-> Array com dados dos pontos de entrada
	aSX6	-> Array com dados Parametros
	aDic	-> Array com dados Aliasindic
	aFunc	-> Array com dados Findfunction	
    /*/
Function FISxProteg(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc)

Local nCrOutPrtg := 0
Local nReduzICMS := 0
Local nVlrBase   := 0
Local nDifVlr    := 0
Local nRedPrtg   := 0
Local nVlrBaseCr := 0
Local nIsenPrtg  := 0
Local nRedBaST   := 0
Local nVlrBaseIs := 0
Local nPosTgPROTEG := 0
Local lTribGen 	 := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_PROTEG)

aNfItem[nItem][IT_BASEPRO]	:=	0
aNfItem[nItem][IT_ALIQPRO]	:=	0
aNfItem[nItem][IT_VALPRO]	:=	0

IF !lTribGen
	// Verifica se deverá calcular o PROTEGE-GO
	If	(aNFItem[nItem][IT_TS][TS_ALIQPRO] > 0) .AND. ((aNFCab[NF_UFORIGEM]=="GO") .OR. (aNFCab[NF_UFDEST]=="GO"))
		// Carrega a reducao da base do ICMS
		If !Empty(aNFitem[nItem,IT_EXCECAO]) .And. aNfItem[nItem,IT_EXCECAO,14] > 0
			nReduzICMS := aNfItem[nItem,IT_EXCECAO,14]
		Else
			nReduzICMS := aNFItem[nItem][IT_TS][TS_BASEICM]
		EndIf
		// Carrega a reducao da base do ICMS ST
		nRedBaST	  := Iif(Len(aNFItem[nItem][IT_EXCECAO]) > 0 .And. aNFItem[nItem][IT_EXCECAO][26] > 0,aNFItem[nItem][IT_EXCECAO][26],aNFItem[nItem][IT_TS][TS_BSICMST])
		// Credito Outorgado
		If	aNFCab[NF_UFORIGEM]=="GO" .And. aNFCab[NF_OPERNF]=='S' .And. SubStr(aNfItem[nItem][IT_CF],1,1) $ "6" .And.;
			aNFItem[nItem][IT_TS][TS_CONSUMO]$"N" .And. aNfItem[nItem][IT_LIVRO][LF_CROUTGO] > 0 .Or. aNfItem[nItem][IT_LIVRO][LF_CRDPRES] > 0
			// Valor PROTEGE-GO no Credito Outorgado. Eh recomendavel utilizar SEMPRE o campo
			// de credito presumido generico - CRDPRES - pois eh com base nele que sao gerados
			// os lancamentos na apuracao atraves dos codigos de reflexo quando necessario.
			If aNfItem[nItem][IT_LIVRO][LF_CRDPRES] > 0
				nVlrBaseCr := aNfItem[nItem][IT_LIVRO][LF_CRDPRES]
			Else
				nVlrBaseCr	:= aNfItem[nItem][IT_LIVRO][LF_CROUTGO]
			EndIf
			nCrOutPrtg	:= nVlrBaseCr * aNFItem[nItem][IT_TS][TS_ALIQPRO] / 100
		Endif
		// Isenção de ICMS
		If	aNfItem[nItem][IT_LIVRO][LF_ISENICM] > 0
			nVlrBaseIs	:= aNfItem[nItem][IT_LIVRO][LF_ISENICM]
			nIsenPrtg	:= nVlrBaseIs * aNFItem[nItem][IT_TS][TS_ALIQPRO] / 100
		EndIf
		If	(nReduzICMS > 0) .Or. (nRedBaST > 0)
			If	aNFCab[NF_UFORIGEM]=="GO" .And. aNFCab[NF_OPERNF]=='S' .And. SubStr(aNfItem[nItem][IT_CF],1,1) $ "5"
				// Base Original do ICMS
				nVlrBase := aNfItem[nItem][IT_BASEICM] + aNfItem[nItem][IT_LIVRO][LF_OUTRICM]
				// É realizada a dedução de IT_VIPIBICM para posteriormente adicionarmos IT_VALIPI por conta da forma como é composto o valor de LF_OUTRICM.
				If aNfItem[nItem][IT_VIPIBICM] > 0 .And. aNfItem[nItem][IT_LIVRO][LF_OUTRICM] > 0
					nVlrBase := nVlrBase - aNfItem[nItem][IT_VIPIBICM] + aNfItem[nItem][IT_VALIPI]
				EndIf
				// Valor do ICMS Original - Valor do ICMS com redução
				nDifVlr  := (nVlrBase * aNfItem[nItem][IT_ALIQICM] / 100) - aNfItem[nItem][IT_VALICM]
				// Valor PROTEGE-GO na Redução de ICMS = Valor da diferença * Aliquota PROTEGE-GO
				nRedPrtg := nDifVlr * aNFItem[nItem][IT_TS][TS_ALIQPRO] / 100
			ElseIf aNFCab[NF_UFDEST]=="GO" .AND. aNFCab[NF_OPERNF]=='S' .And. SubStr(aNfItem[nItem][IT_CF],1,1) $ "6"
				// Base Original do ICMS ST
				nVlrBase := aNfItem[nItem][IT_BASESOL] + aNfItem[nItem][IT_LIVRO][LF_OUTRICM]
				// É realizada a dedução de IT_VIPIBICM para posteriormente adicionarmos IT_VALIPI por conta da forma como é composto o valor de LF_OUTRICM.
				If aNfItem[nItem][IT_VIPIBICM] > 0 .And. aNfItem[nItem][IT_LIVRO][LF_OUTRICM] > 0
					nVlrBase := nVlrBase - aNfItem[nItem][IT_VIPIBICM] + aNfItem[nItem][IT_VALIPI]
				EndIf
				// Valor do ICMS ST Original - Valor do ICMS com redução
				nDifVlr  := (nVlrBase * aNfItem[nItem][IT_ALIQSOL] / 100) - aNfItem[nItem][IT_VALSOL]
				// Valor PROTEGE-GO na Redução de ICMS ST = Valor da diferença * Aliquota PROTEGE-GO
				nRedPrtg := nDifVlr * aNFItem[nItem][IT_TS][TS_ALIQPRO] / 100
			Endif
		EndIf
	EndIf
	// Base PROTEGE-GO
	aNfItem[nItem][IT_BASEPRO]	:= nVlrBaseIs + nVlrBaseCr + nDifVlr
	// Aliquota PROTEGE-GO
	aNfItem[nItem][IT_ALIQPRO]	:= aNFItem[nItem][IT_TS][TS_ALIQPRO]
	// Valor do PROTEGE-GO
	aNfItem[nItem][IT_VALPRO]	:=	nIsenPrtg + nCrOutPrtg + nRedPrtg
Else
	
	//Atualiza com base no configurador
	IF (nPosTgPROTEG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_PROTEG})) > 0 
		aNfItem[nItem][IT_ALIQPRO]	:= aNfItem[nItem][IT_TRIBGEN][nPosTgPROTEG][TG_IT_ALIQUOTA]
		aNfItem[nItem][IT_TS][TS_CROUTGO]:= aNfItem[nItem][IT_TRIBGEN][nPosTgPROTEG][TG_IT_ALIQUOTA]
		aNfItem[nItem][IT_BASEPRO]	:= aNfItem[nItem][IT_TRIBGEN][nPosTgPROTEG][TG_IT_BASE]
		aNfItem[nItem][IT_VALPRO]	:= aNfItem[nItem][IT_TRIBGEN][nPosTgPROTEG][TG_IT_VALOR]
	Endif

Endif

Return


/*/{Protheus.doc} PROTConvRf
	(Função responsavel por converter alteração de referencia legado em referencia do configurador)
	
	@author Rafael Oliveira
    @since 23/11/2020
    @version 12.1.27

	@param:	
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado	
	ccampo -> Campo que esta sendo alterado	

	/*/
Function PROTConvRf(aNfItem,nItem,ccampo)
 Local cCampoConv := ""

	IF cCampo == "IT_VALPRO"
		cCampoConv := "TG_IT_VALOR"		
	Elseif cCampo == "IT_BASEPRO"	
		cCampoConv := "TG_IT_BASE"				
	Elseif cCampo == "IT_ALIQPRO"
		cCampoConv := "TG_IT_ALIQUOTA"
	Endif
	

Return cCampoConv