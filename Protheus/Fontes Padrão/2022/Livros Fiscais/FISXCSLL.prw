#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISxSenar
    Componentização da função MaFisCSLL
    Contribuição Social Sobre O Lucro Líquido
        
	@author Rafael Oliveira
    @since 03/04/2020
    @version 12.1.27
    
    @Autor da unção original -Alexandre Lemes -01/10/2012 

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

/*MaFisCSLL-Alexandre Lemes -01/10/2012 
*/
Function FISXCSLL(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc,cExecuta)

Local aMaCalcCSL := IIf( aPE[PE_MACALCCSL] , ExecBlock("MaCalcCSL") , Array(2) )
Local nAliqSB1   := aNfItem[nItem][IT_PRD][SB_PCSLL]
Local nAliquota  := IIf(Empty(nAliqSB1),aSX6[MV_TXCSLL],nAliqSB1)
Local nDesconto  := 0
Local nDescISS	 := 0
Local lTribGen := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_CSLL)

DEFAULT cExecuta  := "BSE|ALQ|VLR"

If !lTribGen
	//Define Base CSLL
	If "BSE" $ cExecuta
		If (( aPE[PE_MACALCCSL] .And. aMaCalcCSL[1]=="S" ) .Or. ( !Empty(aNfCab[NF_NATUREZA]) .And. aInfNat[NT_CALCCSL]=="S" )) .And.;
		(aNfCab[NF_RECCSLL] $ "S|P" ) .And. ( aNfItem[nItem][IT_PRD][SB_CSLL] == " " .Or. aNfItem[nItem][IT_PRD][SB_CSLL] == "1" .Or. (aNfCab[NF_RECCSLL] == "P" .And. !aSX6[MV_RETEMPU]))
		//MV_RETEMPU Define a forma de calculo de retenção para empresas publicas, caso esteja = .T. passará a validar informações dos campos de retenção do cadastro de produtos e não mais do cadastro de clientes. 
			// A base de calculo da retencao eh o valor da duplicata
			// porem de acordo com a Cons. Trib. Liz, o valor do ISS nao
			// devera ser deduzido da base do PIS/COF/CSL retencao. Para
			// isso foi criado o parametro MV_DEISSBS que se estiver como
			// .T. nao sera descontado e se estiver como .F. - default sera
			nDescISS := IIf(aSX6[MV_DEISSBS] .And. aNfCab[NF_RECISS]=="1" .And. aSX6[MV_DESCISS] .And. aNfCab[NF_OPERNF]=="S" .And. aSX6[MV_TPABISS]=="1", aNfItem[nItem][IT_VALISS] , 0 )
			nDesconto:= IIf(aSX6[MV_CSLLBRU] == "1" , (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]) , 0) // Caso o parametro indique a base de calculo pelo valor bruto da nota fiscal somar o valor do desconto concedido ao total da duplicata.

			aNfItem[nItem][IT_BASECSL] := aNfItem[nItem,IT_BASEDUP] + IIf( aNfItem[nItem,IT_BASEDUP] > 0 , nDesconto , 0 ) + nDescISS

			if aSX6[MV_DEISSBS] == .F. .and. aSX6[MV_TPABISS]=="2" .And. aNfCab[NF_OPERNF]=="S"
				aNfItem[nItem][IT_BASECSL] := aNfItem[nItem][IT_BASECSL] - aNfItem[nItem][IT_VALISS]
			endif

			If aNFItem[nItem][IT_TS][TS_IPIPC]=="2" 	// Indica se o valor do IPI deve compor a base de calculo. 1=Sim (Compoe) e 2=Nao(Nao Compoe)
				aNfItem[nItem][IT_BASECSL] -= aNfItem[nItem][IT_VALIPI]
			Endif

			// Tratamento para retirada do valor do ICMS solidario da base do CSLL
			// Verifica se o valor do ICMS Solidario esta agregado ao valor total
			If !(aNFItem[nItem][IT_TS][TS_INCSOL]$"A,N,D") .And. MaFisDbST("CSL",nItem)
				aNfItem[nItem][IT_BASECSL] -= aNfItem[nItem][IT_VALSOL]
			Endif

			If aNFItem[nItem][IT_TS][TS_DBSTCSL] == "1" .And. aNFCab[NF_OPIRRF] == "EP" // Agrega o Valor do ICMS Retido - Somente para Empresa Publica
				aNfItem[nItem][IT_BASECSL] += aNfItem[nItem][IT_VALSOL]
			Endif

			//Quando operação de entrada com diferimento para orgão Publico, base de retenção deve ser sobre total da nota.
			If aNFItem[nItem][IT_TS][TS_PICMDIF]<>0 .And. aNFItem[nItem][IT_TS][TS_ICMSDIF]$" ,1,2" .And. aNFItem[nItem][IT_TS][TS_ICM] == "S"
				aNfItem[nItem][IT_BASECSL] += aNfItem[nItem][IT_ICMSDIF]
			EndIf

		Else
			aNfItem[nItem][IT_BASECSL] := 0
		EndIf
	EndIf
	//Define Aliquota CSLL
	If "ALQ" $ cExecuta
		If Empty(nAliqSB1) .Or. aSX6[MV_TPALCSL]== "1"
			If !Empty(aNfCab[NF_NATUREZA]) .And. aInfNat[NT_CALCCSL]=="S" .And. !Empty(aInfNat[NT_PERCCSL])
				nAliquota :=  aInfNat[NT_PERCCSL]
			EndIf

			If aPE[PE_MACALCCSL]
				If aMaCalcCSL[1]=="S" .And. !Empty(aMaCalcCSL[2])
					nAliquota := aMaCalcCSL[2]
				EndIf
			EndIf
		EndIf
		aNfItem[nItem][IT_ALIQCSL]	:= nAliquota
	EndIf

	//Define Valor CSLL
	If "VLR" $ cExecuta
		If ( aPE[PE_MACALCCSL] .And. aMaCalcCSL[1] == "S" ) .Or. ( !Empty(aNfCab[NF_NATUREZA]) .And. aInfNat[NT_CALCCSL] == "S" )
			aNfItem[nItem][IT_VALCSL] := aNfItem[nItem][IT_BASECSL]*aNfItem[nItem][IT_ALIQCSL]/100
		Else
			aNfItem[nItem][IT_VALCSL] := 0
		EndIf

		MaItArred(nItem,{"IT_VALCSL"})
	EndIf

Else

	If (nPosTrGCSLL := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_CSLL})) > 0 

		aNfItem[nItem][IT_BASECSL] 	:= aNfItem[nItem][IT_TRIBGEN][nPosTrGCSLL][TG_IT_BASE]
		aNfItem[nItem][IT_ALIQCSL] 	:= aNfItem[nItem][IT_TRIBGEN][nPosTrGCSLL][TG_IT_ALIQUOTA]
		aNfItem[nItem][IT_VALCSL] 	:= aNfItem[nItem][IT_TRIBGEN][nPosTrGCSLL][TG_IT_VALOR]

	EndIf

EndIf

Return

/*/{Protheus.doc} CSLLConvRf
	(Função responsavel por converter alteração de referencia legado em referencia do configurador)
	
	@author Erich Buttner
    @since 25/11/2020
    @version 12.1.27

	@param:	
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado	
	ccampo -> Campo que esta sendo alterado	

	/*/
Function CSLLConvRf(aNfItem,nItem,ccampo)
 Local cCampoConv := ""

	IF cCampo == "IT_VALCSL"
		cCampoConv := "TG_IT_VALOR"		
	Elseif cCampo == "IT_BASECSL"	
		cCampoConv := "TG_IT_BASE"				
	Elseif cCampo == "IT_ALIQCSL"
		cCampoConv := "TG_IT_ALIQUOTA"				
	Endif
	

Return cCampoConv
