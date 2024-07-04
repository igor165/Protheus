#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISxSenar
    (Componentização da função MaFisSENAR - 
    Calculo do Serviço Nacional de Aprendizagem Rural (SENAR))

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
Function FISxSenar(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc)

Local lDev 		:= Iif(Alltrim(aNfCab[NF_TIPONF]) $ "DB",.T.,.F.)
Local nBCFun 	:= MaFisBCFun(nItem)
Local cFunrural := aSX6[MV_FUNRURA]
Local lTribGen 	:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_SENAR)
Local nPosTgSnar:= 0

If !lTribGen
	aNfItem[nItem][IT_BSSENAR]:= 0
	aNfItem[nItem][IT_ALSENAR]:= 0
	aNfItem[nItem][IT_VLSENAR]:= 0

	If aNFItem[nItem][IT_TS][TS_ALSENAR] > 0 .And. (aNFItem[nItem][IT_TS][TS_DUPLIC] == "S" .Or. aNFItem[nItem][IT_TS][TS_CSENAR]=="1")
		If ((SubStr(aNfItem[nItem][IT_CF],1,1) $ "5|6|7" .And. !lDev) .Or.(SubStr(aNfItem[nItem][IT_CF],1,1) $ "1|2" .And. lDev))
			iF nBCFun > 0 .and. cFunrural = '1'
				aNfItem[nItem][IT_BSSENAR] := nBCFun 
			Else
				aNfItem[nItem][IT_BSSENAR]:= aNfItem[nItem][IT_TOTAL]
			EndIf
			aNfItem[nItem][IT_ALSENAR]:= aNFItem[nItem][IT_TS][TS_ALSENAR]
			aNfItem[nItem][IT_VLSENAR]:= aNfItem[nItem][IT_BSSENAR]*(aNFItem[nItem][IT_TS][TS_ALSENAR]/100)
			MaItArred(nItem,{"IT_VLSENAR"})
		ElseIf (((SubStr(aNfItem[nItem][IT_CF],1,1) $ "1|2") .Or.(SubStr(aNfItem[nItem][IT_CF],1,1) $ "5|6" .And. lDev)) .And. (aNfCab[NF_TPCLIFOR] == "F" .Or. aNfCab[NF_TIPORUR] == "F"))
			iF nBCFun > 0 .and. cFunrural == '1'
				aNfItem[nItem][IT_BSSENAR] := nBCFun
			Else
				aNfItem[nItem][IT_BSSENAR]:= aNfItem[nItem][IT_TOTAL]
			EndIf
			aNfItem[nItem][IT_ALSENAR]:= aNFItem[nItem][IT_TS][TS_ALSENAR]
			aNfItem[nItem][IT_VLSENAR]:= aNfItem[nItem][IT_BSSENAR]*(aNFItem[nItem][IT_TS][TS_ALSENAR]/100)
			MaItArred(nItem,{"IT_VLSENAR"})
		Endif
	Endif
Else

    IF (nPosTgSnar := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_SENAR})) >0  
    
        aNfItem[nItem][IT_VLSENAR]:= aNfItem[nItem][IT_TRIBGEN][nPosTgSnar][TG_IT_VALOR]
        aNfItem[nItem][IT_BSSENAR]:= aNfItem[nItem][IT_TRIBGEN][nPosTgSnar][TG_IT_BASE]
        aNfItem[nItem][IT_ALSENAR]:= aNfItem[nItem][IT_TRIBGEN][nPosTgSnar][TG_IT_ALIQUOTA]

    Endif
EndIf

Return

/*/{Protheus.doc} SNARConvRf
(Função responsavel por converter alteração de referencia legado em referencia do configurador)

@author Renato Rezende
@since 25/11/2020
@version 12.1.31

@param:	
aNFItem-> Array com dados item da nota
nItem  -> Item que esta sendo processado	
ccampo -> Campo que esta sendo alterado	
/*/
Function SNARConvRf(aNfItem,nItem,ccampo)
Local cCampoConv := ""

IF cCampo == "IT_VLSENAR"
    cCampoConv := "TG_IT_VALOR"		
Elseif cCampo == "IT_BSSENAR"	
    cCampoConv := "TG_IT_BASE"				
Elseif cCampo == "IT_ALSENAR"
    cCampoConv := "TG_IT_ALIQUOTA"				
Endif

Return cCampoConv


/*/{Protheus.doc} dedSenarDup -> Deduz SENAR da Duplicata?
	
	Essa função verifica se será deduzido o valor do SENAR da duplicata
	com base em critérios de operação e configuração do sistema e retorna
	se houve a dedução.

	@type  Function
	@author anedino.santos
	@since 22/02/2022
	@version 0.1
	@param aNfCab, Array, Array contendo as informações do cabeçalho da nota fiscal
	@param aTes, Array, Array contendo as informações da TES aplicada ao produto
	@param aNfItem, Array, Array contendo as informações dos itens
	@param nItem, Number, variável com a numeração do item atual.
/*/
Function dedSenarDup(aNfCab, aTes, aNfItem, nItem)
	Local lTribGen 	 := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_FUNRUR)
	// deduz SENAR na saída?
	local lDSenarSai :=  cPaisLoc =="BRA" .AND. SM0->M0_PRODRUR$"FL13" .And. (Iif(Len(Alltrim(aNfCab[NF_CNPJ]))< 14,"F","J") == "J" .And. aNfCab[NF_OPIRRF] != "PF")
	// deduz SENAR na entrada?
	local lDSenarEnt :=  cPaisLoc =="BRA" .AND. RetPessoa(SM0->M0_CGC) $ "J" .And. (Iif(Len(Alltrim(aNfCab[NF_CNPJ]))< 14,"F","J") == "F" .Or. aNfCab[NF_TIPORUR] == "F")


	//Saída   - So desconta quando eu não pago; So não irei descontar no valor do titulo, se o comprador for pessoa Juridica, pois só não pagarei se o cliente for Juridico.
	//Entrada - So desconta quando eu pago; So desconto no valor do titulo, se o vendedor for pessoa Fisica, pois só pagarei, se eu for pessoa Juridica e estiver comprando de pessoa fisica.
	//Caso o SENAR seja deduzido do valor total da duplicada, quando ocorrer a devolução também deverá deduzir, para que a operação seja anulada corretamente.
	If cPaisLoc =="BRA" .And. (aTes[TS_ALSENAR] > 0 .or. lTribGen) .And. (!(aNfCab[NF_TPCLIFOR]$"X"))      .And. ;
		((aNfCab[NF_OPERNF] == "S" .And. !(Alltrim(aNfCab[NF_TIPONF]) $ "DB") .and. lDSenarSai)     .OR. ;	//Deduz na venda
		(aNfCab[NF_OPERNF] == "E" .And. !(Alltrim(aNfCab[NF_TIPONF]) $ "DB") .and. lDSenarEnt)     .OR. ;	//Deduz na compra
		(Alltrim(aNfCab[NF_TIPONF]) $ "DB" .AND. aNfCab[NF_OPERNF] == "E" .AND. lDSenarSai) .OR. ;	//Se deduziu SENAR na venda também deverá deduzir SENAR na devolução de venda
		(Alltrim(aNfCab[NF_TIPONF]) $ "DB" .AND. aNfCab[NF_OPERNF] == "S" .AND. lDSenarEnt); 		//Se deduziu SENAR na compra também deverá deduzir SENAR na devolução de compra
		)// fim da expressão do IF

		aNfItem[nItem][IT_BASEDUP]	-= aNfItem[nItem][IT_VLSENAR]
	Endif

Return NIL
