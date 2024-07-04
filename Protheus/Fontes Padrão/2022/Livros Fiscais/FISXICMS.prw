#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"


Static __aPrepared := {} 

/*/{Protheus.doc} FISXVICMS
    (Componentização da função MaFisVICMS - 
    Calculo do Valor do ICMS do Item)    
    
	@Author Renato Rezende
    @since 15/04/2020
    @version 12.1.27

    @Autor da função original 
    Edson Maricate # 08/12/1999

	@param:
	aNfCab      -> Array com dados do cabeçalho da nota
	aNFItem     -> Array com dados item da nota
	nItem       -> Item que esta sendo processado
	aPos        -> Array com dados de FieldPos de campos
	aInfNat	    -> Array com dados da natureza
	aPE		    -> Array com dados dos pontos de entrada
	aSX6	    -> Array com dados Parametros
	aDic	    -> Array com dados Aliasindic
	aFunc	    -> Array com dados Findfunction
/*/
Function FISXVICMS(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, lReproc, lDif)
Local nSavValICM  := 0
Local nSValICMFR  := 0
Local lCalcDif	  := .F.
Local lDevTotal	  := .F.
Local aMaICMVeic  := {} //usado no PE MaICMVeic
Local aMaCalcICMS := {}
Local lDevTot     := aSX6[MV_DEVTOT]
Local lExecDevol  := .T.
Local nValIcmsBruto	 := 0 //valor bruto do ICMS, antes de ser submetido ao arredondamento
Local lTribICM	  := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_ICMS)

DEFAULT lReproc   := .F.
Default lDif	  := .F. //Esta variável indica que a MaFisVICMS foi chamada de forma recursiva, deverá recalcular o valor do ICMS porém não deverá refazer o ICMS Diferido.

//Identifico se é diferimento parcial jogando parcela diferida em Outros ou Isento. A referência IT_COLVDIF somente será preenchida para diferimento parcial, se o campo FT_VOPDIF existir e se o campo F4_COLVDIF estiver preenchido.
aNfItem[nItem][IT_COLVDIF]	:= Iif (aNFItem[nItem][IT_TS][TS_COLVDIF] $ '1/2' .AND. aNFItem[nItem][IT_TS][TS_PICMDIF]<>0 .And. aNFItem[nItem][IT_TS][TS_PICMDIF]<>100 .AND. aPos[FP_FT_VOPDIF] , aNFItem[nItem][IT_TS][TS_COLVDIF] , '' )

//Salva o valor do ICMS no reprocessamento.
nSavValICM := aNfItem[nItem][IT_VALICM]
nSValICMFR := aNfItem[nItem][IT_ICMFRETE]

//DIAT - SC
aNFitem[nItem][IT_B1DIAT]:= aNfItem[nItem][IT_PRD][SB_PRDDIAT]

If (aNFItem[nItem][IT_TS][TS_ICM] <> "N" .Or. (aNFCab[NF_SIMPNAC] =="1" .And. aNFItem[nItem][IT_TS][TS_COMPL] == "S" .And. aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] .And. (aNFItem[nItem][IT_TS][TS_CIAP] == "S" .Or. aNFItem[nItem][IT_TS][TS_CONSUMO] == "S"))) .Or. lTribICM
	//Calculo do valor do ICMS do item.
	If aNFitem[nItem][IT_TIPONF ] == "I" .And. !lTribICM
		If aNFItem[nItem][IT_TS][TS_AGREG]<>"F"
			aNfItem[nItem][IT_VALICM]	:= aNfItem[nItem][IT_VALMERC]
		EndIf
		aNfItem[nItem][IT_ICMFRETE]	:= 0
	ElseIf aNFitem[nItem][IT_TIPONF ] == "P" .And. aNfItem[nItem][IT_VALICM] > 0  //Mantendo o valor do ICMS quando for a nota fiscal de complemento de IPI + ICMS 
		aNfItem[nItem][IT_VALICM] := nSavValICM
	Else
		If !lTribICM
			IF aNfItem[nItem][IT_UFXPROD][UFP_RDCTIMP] > 0 .And. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_CLIFOR] =="F" .And. aNFCab[NF_TPCLIFOR] =="X" .And. Substr(aNfItem[nItem][IT_CF],1,1)=="3" .And. aNFItem[nItem][IT_TS][TS_INTBSIC]$"123"
				aNfItem[nItem][IT_VALICM]  	:= aNfItem[nItem][IT_BASEICM]*aNfItem[nItem][IT_UFXPROD][UFP_RDCTIMP]/100
			ElseIF aNfItem[nItem][IT_UFXPROD][UFP_BASRDZ]  == '2' 
				aNfItem[nItem][IT_VALICM]  	:= (aNfItem[nItem][IT_BASEICM]* (aNfItem[nItem][IT_ALIQICM] - aNfItem[nItem][IT_ALIQFECP])/100) + (aNfItem[nItem][IT_BICMORI]* ( aNfItem[nItem][IT_ALIQFECP])/100)
			Else
				aNfItem[nItem][IT_VALICM]  	:= aNfItem[nItem][IT_BASEICM]*aNfItem[nItem][IT_ALIQICM]/100
			EndIf
			nValIcmsBruto	:= aNfItem[nItem][IT_VALICM]
			aNfItem[nItem][IT_ICMFRETE]	:= aNfItem[nItem][IT_BSFRETE]*aNfItem[nItem][IT_ALIQICM]/100
	
			MaItArred(nItem,{"IT_VALICM"})
			MaItArred(nItem,{"IT_ICMFRETE"})

			// Ajuste para NAO pegar aliq original ICMS das NFs de 2012, este ajuste deve ser retirado em 01/01/2014
			If aNFitem[nItem][IT_ALIQICM] == 4
				lExecDevol := .F.
			EndIf
		Else
			ICMSConf(aNFCab, aNfItem, nItem)
		EndIf
		// Adicionado tratamento para que o valor de ICMS nao seja obtido da NF de origem em retornos de remessas em garantia.

		// O mesmo tratamento existe na MaAliqICM para que a aliquota nao seja obtida da NF de origem, entao o valor segue a mesma regra.
		If ( aNFCab[NF_TIPONF] $ "DB" .Or. aNFItem[nItem][IT_TS][TS_PODER3] =="D" ) .And. lExecDevol .And. !(aNFItem[nItem][IT_TS][TS_PODER3] == "D" .And. aNFItem[nItem][IT_TS][TS_OPERGAR] == '1')
			If !Empty(aNFItem[nItem][IT_RECORI]) .And. !FISXRTCOMP(aNFCab[NF_CLIFOR], aNFItem[nItem][IT_RECORI],aSX6) .And. !aNfCab[NF_PPDIFAL]
				If aNFCab[NF_TIPONF] $ "DB"
					If ( aNFCab[NF_CLIFOR] == "C")
						dbSelectArea("SD2")
						MsGoto(aNFItem[nItem][IT_RECORI])
						If aPos[FP_D2_ICMSDIF] .AND. (SD2->D2_VALICM > 0 .Or. Abs(aNfItem[nItem][IT_VALICM]-SD2->D2_VALICM)<=1) .And. aNfItem[nItem][IT_QUANT] = SD2->D2_QUANT .And. Iif(!lDevTot , SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0 , SD2->D2_VALICM >0)
							aNfItem[nItem][IT_VALICM]  := SD2->D2_VALICM
							aNfItem[nItem][IT_ICMSDIF] := Iif(aPos[FP_D2_ICMSDIF],SD2->D2_ICMSDIF,0)
							aNfItem[nItem][IT_VOPDIF] := If(aPos[FP_D2_VOPDIF], SD2->D2_VOPDIF, 0)
							lDevTotal	:=	.T.
						Else
							lCalcDif	:=	.T.
						EndIf
					ElseIF aPos[FP_D1_ICMSDIF]
						dbSelectArea("SD1")
						MsGoto(aNFItem[nItem][IT_RECORI])
						If (SD1->D1_VALICM > 0 .Or. Abs(aNfItem[nItem][IT_VALICM]-SD1->D1_VALICM)<=1) .And. aNfItem[nItem][IT_QUANT] = SD1->D1_QUANT .And. Iif(!lDevTot , SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0 , SD1->D1_VALICM >0)
							aNfItem[nItem][IT_VALICM] := SD1->D1_VALICM
							aNfItem[nItem][IT_ICMSDIF] := If( aPos[FP_D1_ICMSDIF] ,SD1->D1_ICMSDIF,0)
							aNfItem[nItem][IT_VOPDIF] := If(aPos[FP_D1_VOPDIF], SD1->D1_VOPDIF, 0)
							lDevTotal	:=	.T.
						Elseif aNFItem[nItem][IT_TS][TS_DEVPARC]$"1S" .And. ((SD1->D1_VALICM > 0 .Or. Abs(aNfItem[nItem][IT_VALICM]-SD1->D1_VALICM)<=1) .And. aNfItem[nItem][IT_QUANT] <> SD1->D1_QUANT .And. Iif(!lDevTot , SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0 , SD1->D1_VALICM >0))
							aNfItem[nItem][IT_VALICM] := SD1->D1_VALICM / SD1->D1_QUANT * aNfItem[nItem][IT_QUANT]
							aNfItem[nItem][IT_ICMSDIF] := If( aPos[FP_D1_ICMSDIF] ,SD1->D1_ICMSDIF / SD1->D1_QUANT * aNfItem[nItem][IT_QUANT],0)
							aNfItem[nItem][IT_VOPDIF] := If(aPos[FP_D1_VOPDIF], SD1->D1_VOPDIF / SD1->D1_QUANT * aNfItem[nItem][IT_QUANT], 0)
							// Se utilizar F4_DEVPARC = SIM segue o fluxo de uma dev. total pois os valores
							// serao proporcionalizados e nao devem ser recalculados posteriormente.
							lDevTotal := .T.
						ElseIf !((SD1->D1_VALICM > 0 .Or. Abs(aNfItem[nItem][IT_VALICM]-SD1->D1_VALICM)<=1) .And. aNfItem[nItem][IT_QUANT] <> SD1->D1_QUANT .And. Iif(!lDevTot , SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0 , SD1->D1_VALICM >0))
							lCalcDif	:=	.T.
						EndIf
					EndIf
				Else
					If ( aNFCab[NF_CLIFOR] == "C")
						dbSelectArea("SD1")
						MsGoto(aNFItem[nItem][IT_RECORI])
						If (SD1->D1_VALICM > 0 .Or. Abs(aNfItem[nItem][IT_VALICM]-SD1->D1_VALICM)<=1) .And. aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT .And. Iif(!lDevTot , SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0 , SD1->D1_VALICM >0)
							If(aNfItem[nItem][IT_TS][TS_SITTRIB] == "51" .And. aNfItem[nItem][IT_TS][TS_ICMSDIF] == "3")
								aNfItem[nItem][IT_VALICM] := aNfItem[nItem][IT_BASEICM] * (aNfItem[nItem][IT_ALIQICM] / 100) // Recalculando IT_VALICM Issue DSERFISE-4011
							Else
								aNfItem[nItem][IT_VALICM] := SD1->D1_VALICM
							EndIf						
							lDevTotal	:=	.T.
						Else
							lCalcDif	:=	.T.
						EndIf
					Else
						dbSelectArea("SD2")
						MsGoto(aNFItem[nItem][IT_RECORI])
						If (SD2->D2_VALICM > 0 .Or. Abs(aNfItem[nItem][IT_VALICM]-SD2->D2_VALICM)<=1) .And. aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT .And. Iif(!lDevTot , SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0 , SD2->D2_VALICM >0)
							aNfItem[nItem][IT_VALICM] := SD2->D2_VALICM
							lDevTotal	:=	.T.
						Else
							lCalcDif	:=	.T.
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Else
	aNfItem[nItem][IT_VALICM]	 := 0
	aNfItem[nItem][IT_ICMFRETE] := 0
EndIf

If !lTribICM
	//Retorna o valor do ICMS no reprocessamento para calcular ICMS Diferido.
	If !lReproc .AND. !lDif
		If lCalcDif .Or. (!lCalcDif .And. aNFCab[NF_TIPONF] $ "DB" .And. !lDevTotal) .Or. !(aNFCab[NF_TIPONF] $ "DB")
			If lReproc
				aNfItem[nItem][IT_VALICM]   := nSavValICM
			EndIf
			aNfItem[nItem][IT_ICMSDIF] := 0
			If aNFItem[nItem][IT_TS][TS_ICMSDIF] $ "1|3|4|6|7"
				aNfItem[nItem][IT_ICMSDIF] := aNfItem[nItem][IT_VALICM]
				//Monta base composta utilizando aliquota
				If aNFItem[nItem][IT_TS][TS_ICMSDIF] == "7"
					aNfItem[nItem][IT_ICMSDIF] := (aNfItem[nItem][IT_BASEICM] / (1-(aNfItem[nItem][IT_ALIQICM]/100))) * (aNfItem[nItem][IT_ALIQICM]/100)
				Endif
				//Valor do ICMS da Operação - Sem diferimento (Valor como se não tivesse o diferimento)
				aNfItem[nItem][IT_VOPDIF]  := aNfItem[nItem][IT_VALICM]
			EndIf
			If  aNFItem[nItem][IT_TS][TS_PICMDIF]<>0 .And. aNFItem[nItem][IT_TS][TS_PICMDIF]<>100 .And. aNFItem[nItem][IT_TS][TS_ICMSDIF] <> '7'
				//Quando utilizado base composta, multiplicar pela base calculada
				aNfItem[nItem][IT_ICMSDIF] := aNfItem[nItem][IT_VALICM]*aNFItem[nItem][IT_TS][TS_PICMDIF]/100
				MaItArred(nItem,{"IT_ICMSDIF"})
			EndIf
			If aNFItem[nItem][IT_TS][TS_ICMSDIF]=="1" .And. aNFItem[nItem][IT_TS][TS_PICMDIF]==100 .And. aNFItem[nItem][IT_TS][TS_ICM] == "N"
				aNfItem[nItem][IT_ICMSDIF] :=	MaFisICDif(aNfItem, nItem)
				//Valor do ICMS da Operação - Sem diferimento (Valor como se não tivesse o diferimento)
				//Quando não calcula ICMS o Valor do ICMS da Operação seria o ICMS Diferido
				aNfItem[nItem][IT_VOPDIF] := aNfItem[nItem][IT_ICMSDIF]
			ElseIf 	(aNFItem[nItem][IT_TS][TS_ICMSDIF] $ "3#7") .Or. (aNFItem[nItem][IT_TS][TS_ICMSDIF]=="4") .Or. (aNFItem[nItem][IT_TS][TS_ICMSDIF]=="1" .And. aNFItem[nItem][IT_TS][TS_PICMDIF]<>100 .And. aNFItem[nItem][IT_TS][TS_ICM] <> "N")
				If aNFItem[nItem][IT_TS][TS_ICMSDIF] == "7"
					If aNFItem[nItem][IT_TS][TS_PICMDIF] <> 100
						aNfItem[nItem][IT_VOPDIF] := (aNfItem[nItem][IT_BASEICM] + aNfItem[nItem][IT_ICMSDIF]) * (aNfItem[nItem][IT_ALIQICM]/100)
						aNfItem[nItem][IT_ICMSDIF]:= aNfItem[nItem][IT_VOPDIF] * (aNFItem[nItem][IT_TS][TS_PICMDIF]/100)
						aNfItem[nItem][IT_VALICM] := aNfItem[nItem][IT_VOPDIF] - aNfItem[nItem][IT_ICMSDIF]
						nValIcmsBruto			  			:= aNfItem[nItem][IT_VALICM]
					ElseIf aNFItem[nItem][IT_TS][TS_PICMDIF] == 100 .And. aNFCab[NF_UFDEST] $ "RJ" .And. (aNFItem[nItem][IT_TS][TS_ICMSDIF] $ "7")
						aNfItem[nItem][IT_VOPDIF]	:= aNfItem[nItem][IT_ICMSDIF] := (aNfItem[nItem][IT_BASEICM] / (1-((aNfItem[nItem][IT_ALIQICM]+aNfItem[nItem][IT_ALIQFECP])/100))) * ((aNfItem[nItem][IT_ALIQICM])/100)
						aNfItem[nItem][IT_VALICM]	:= 0
						nValIcmsBruto				:= 0
					Else
						aNfItem[nItem][IT_VOPDIF]  := aNfItem[nItem][IT_ICMSDIF] := (aNfItem[nItem][IT_BASEICM] / (1-(aNfItem[nItem][IT_ALIQICM]/100))) * (aNfItem[nItem][IT_ALIQICM]/100)
						aNfItem[nItem][IT_VALICM]  := 0
						nValIcmsBruto							 := 0
					EndIf
					MaItArred(nItem,{"IT_ICMSDIF"})
				Else
					aNfItem[nItem][IT_VALICM] -= aNfItem[nItem][IT_ICMSDIF]
					nValIcmsBruto			  			-= aNfItem[nItem][IT_ICMSDIF]
					//Valor do ICMS da Operação - Sem diferimento (Valor como se não tivesse o diferimento)
					//É o Val.ICMS mais o valor do Diferimento
					aNfItem[nItem][IT_VOPDIF] := aNfItem[nItem][IT_VALICM]+aNfItem[nItem][IT_ICMSDIF]
				EndIf
			Endif

			//Diferimento para PR conforme http://tdn.totvs.com/display/public/softwaregestao/Diferimento+Parcial+do+ICMS+e+ICMS-ST+-+PR
			If (aNFItem[nItem][IT_TS][TS_ICMSDIF]=="5")
				nAliqdif:=(aNfItem[nItem][IT_ALIQICM] * 100/(100-aNFItem[nItem][IT_TS][TS_PICMDIF]) )//Aliquota Cheia
				aNfItem[nItem][IT_ICMSDIF] :=(aNfItem[nItem][IT_BASEICM] * nAliqdif/100) * aNFItem[nItem][IT_TS][TS_PICMDIF]/100
				MaItArred(nItem,{"IT_ICMSDIF"})
				//Valor do ICMS da Operação - Sem diferimento (Valor como se não tivesse o diferimento)
				aNfItem[nItem][IT_VOPDIF] := aNfItem[nItem][IT_VALICM]
			Endif

			//Se for diferimento parcial demonstrando a parcela não diferida em Outros ou Isento, precisa reduzir a base de cálculo do ICMS
			If aNfItem[nItem][IT_COLVDIF] $ '1/2'
				aNfItem[nItem][IT_BASEICM]	:= aNfItem[nItem][IT_BASEICM] * (1-(aNFItem[nItem][IT_TS][TS_PICMDIF]/100))
				MaFisVICMS(nItem,,.T.) //Recalcula o valor do ICMS considerando a base de cálculo reduzida, chamando a MaFisVICMS de forma recursiva.

				// para não haver diferença entre o XML e a tabela SFT quanto a atag <vICMS> e o campo FT_VALICM, efetuamos a difererença entre
				// o ICMS cheio (ICMS sem a redução da porcentagem diferida) com o ICMS reduzido (valor encontrado após o cálculo do ICMS com base reduzida).				
				aNfItem[nItem][IT_ICMSDIF] := aNfItem[nItem][IT_VOPDIF] - aNfItem[nItem][IT_VALICM]
			EndIF

			//Guardo o valor do ICMS antes de ser submetido a MaItArred()
			aNfItem[nItem][IT_VICMBRT] := nValIcmsBruto
			MaItArred(nItem,{"IT_VALICM"})
		EndIf
		//Retorna o valor do ICMS no reprocessamento.
	ElseIF !lDif
		aNfItem[nItem][IT_VALICM]   := nSavValICM
		aNfItem[nItem][IT_ICMFRETE] := nSValICMFR
		//Se for diferimento parcial demonstrando a parcela não diferida em Outros ou Isento e vier chamando a MaFisVICMS de forma recursiva.
		//O ICMS será o ICMS de Operação subtraindo o ICMS Diferido
	ElseIf lDif .and. aNfItem[nItem][IT_COLVDIF] $ '1/2'
		aNfItem[nItem][IT_VALICM]  	:= aNfItem[nItem][IT_VOPDIF] - aNfItem[nItem][IT_ICMSDIF]
	EndIf
	//Identifica um valor a ser lancado como estorno de credito/debito na apuracao do ICMS. Este valor
	//  eh obtido quando se tem um percentual de estorno definido no cadastro de TES.

	// Observacao mais completa pode ser encontrada mais adiante na gravacao do Livro Fiscal.
	If aNFItem[nItem][IT_TS][TS_ESTCRED]<>0
		aNfItem[nItem][IT_ESTCRED] := aNfItem[nItem][IT_VALICM] * (aNFItem[nItem][IT_TS][TS_ESTCRED]/100) // Antigo - NoRound(aNfItem[nItem][IT_VALICM] * aNFItem[nItem][IT_TS][TS_ESTCRED]/100,2)
		MaItArred(nItem,{"IT_ESTCRED"})
	Endif

	If !Empty(aNfItem[nItem][IT_PR43080])
		aNfItem[nItem][IT_ICSEMDS] := aNfItem[nItem][IT_BSSEMDS]*aNfItem[nItem][IT_ALIQICM]/100
		MaItArred(nItem,{"IT_ICSEMDS"})
		aNfItem[nItem][IT_DS43080] := aNfItem[nItem][IT_ICSEMDS] - aNfItem[nItem][IT_VALICM]
	EndIf
	//ATENCAO!!! Ponto de entrada para uso exclusivo da TOTVS, nao sugerir o uso do mesmo a clientes - GDP FISCAL
	If aPE[PE_MAICMVEIC]
		aMaICMVeic := ExecBlock("MaICMVeic",.f.,.f.,{nItem,aNfItem[nItem][IT_BASEICM],aNfItem[nItem][IT_ALIQICM],aNfItem[nItem][IT_VALICM]})
		aNfItem[nItem][IT_BASEICM] := aMaICMVeic[1]
		aNfItem[nItem][IT_ALIQICM] := aMaICMVeic[2]
		aNfItem[nItem][IT_VALICM]  := aMaICMVeic[3]
	EndIf

	If aPE[PE_MACALCICMS]
		aMaCalcICMS := ExecBlock("MACALCICMS",.f.,.f.,{aNfCab[NF_OPERNF],nItem,aNfItem[nItem][IT_BASEICM],aNfItem[nItem][IT_ALIQICM],aNfItem[nItem][IT_VALICM]})
		IF ValType(aMaCalcICMS) == "A"
			IF Len(aMaCalcICMS) == 3
				aNfItem[nItem][IT_BASEICM] := aMaCalcICMS[1]
				aNfItem[nItem][IT_ALIQICM] := aMaCalcICMS[2]
				aNfItem[nItem][IT_VALICM]  := aMaCalcICMS[3]
			Endif
		Endif
	Endif

	If aNFItem[nItem][IT_TS][TS_CPRESPR] > 0 .And. aNFCab[NF_OPERNF] == "S" // CREDITO PRESUMIDO - PR - Art.631-A do RICMS/2008
		aNfItem[nItem][IT_CPRESPR] := aNfItem[nItem][IT_VALICM]*(aNFItem[nItem][IT_TS][TS_CPRESPR]/100)
	Endif

	IF !aNFCab[NF_TIPONF] $ "DB" .AND. !aNfCab[NF_PPDIFAL] .AND. aNfItem[nItem,IT_PREDIC] == 0 .AND. aNFItem[nItem][IT_TS][TS_AGREG]$"D/R/E"
		//Se for agrega D, R ou E e não possuir redução de base de cálculo e também não for Difal, significa que a dedução de ICMS será exatamente o valor do ICMS já calculado
		//Esta alteração se deve pelo motivo de arredondamento, existem situações onde IT_DEDICM fica com diferença de centavos do IT_VALICM, pois existem
		//tratamento de round indevidamente para estas referências. Desta forma estou assegurando que o valor de dedução de ICMS será exatamente igual ao valor de ICMS.
		aNfItem[nItem][IT_DEDICM]	:= aNfItem[nItem][IT_VALICM]
	EndIF

	If aNFItem[nItem][IT_TS][TS_ICMSDIF] == "6"
		aNfItem[nItem][IT_DEDICM]	:= aNfItem[nItem][IT_ICMSDIF]
	EndIf //issue DSERFIS1-8601
Else
	ICMSConf(aNFCab, aNfItem, nItem)
EndIf

// Calcula o valor do FECP-Proprio
MaFisFECP(nItem,,lReproc,"BSE|VLR")

Return

/*
MaAliqIcms-Eduardo/Edson - 08.12.1999
Calculo da Aliquota para operacoes de ICMS
*/
Function FISXAICMS(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc,lSolidario,lICDif)
Local nAliquota		:=	IIf( aNfItem[nItem][IT_PRD][SB_PICM] == 0 ,  aSX6[MV_ICMPAD]  ,  aNfItem[nItem][IT_PRD][SB_PICM] )
Local nAlqFecop		:=	IIf( aNfItem[nItem][IT_PRD][SB_FECOP] == "1" , aNfItem[nItem][IT_PRD][SB_ALFECOP] , 0 )
Local cTipoNF		:=	aNfCab[NF_TIPONF]
Local cSimpNac		:=	aSX6[MV_CODREG]
Local cAliqDifST	:=	"2"
Local lFreteAut		:=	aNFItem[nItem][IT_TS][TS_LFICM] <> "N" .And. aNFItem[nItem][IT_TS][TS_FRETAUT] <> "2" .And. aNFItem[nItem][IT_TS][TS_FRETAUT] <> "3" .And. aNfItem[nItem][IT_AUTONOMO]>0
Local cExceRes13	:=	"6107|6108|6929"
Local aMVPPDIFAL 	:= &(aSX6[MV_PPDIFAL])
Local lCalDifal		:= IIf(aNFCab[NF_CLIFOR] == "C", aNFCab[NF_TPCLIFOR] $ "F|L", aNFCab[NF_LINSCR]) .And. aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] .And. (Iif(valType(aMVPPDIFAL)== "A", Len(aMVPPDIFAL)>0 .And. Year(aNfCab[NF_DTEMISS]) >= aMVPPDIFAL[1][1],.F.))
Local lCalcAliq     := .T.
Local nAliqSN       := 0
Local lTribICM	  	:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_ICMS)
Local lDifMaj		:= .T.

Default lSolidario	:=	.F.
Default lICDif		:=	.F.

If lTribICM
	ICMSConf(aNFCab, aNfItem, nItem)
	nAliquota := aNfItem[nItem][IT_ALIQICM]
	Return nAliquota
EndIf

If ((aNFItem[nItem][IT_TS][TS_ICM] <> "N" .Or. lICDif .Or. (lCalDifal .And. aNfItem[nItem][IT_TS][TS_DIFAL]=="1")) .Or. lSolidario .Or. (aNFCab[NF_SIMPNAC] =="1" .And. aNFItem[nItem][IT_TS][TS_COMPL] == "S" .And. aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] .And. (aNFItem[nItem][IT_TS][TS_CIAP] == "S" .Or. aNFItem[nItem][IT_TS][TS_CONSUMO] == "S")) .Or. lFreteAut) .And. aNfItem[nItem][IT_TS][TS_ISS]<>"S"

	// Verifica se a nota fiscal eh de Conhecimento de Frete
	If !lSolidario .And. (AllTrim(aNFCab[NF_ESPECIE]) $ "CTR/CTE" .Or. "NFST"$AllTrim(aNFCab[NF_ESPECIE]))
		nAliquota := Val(Substr(aSX6[MV_FRETEST],(AT(aNfCab[NF_UFORIGEM],aSX6[MV_FRETEST])+2),5))
		nAliquota := IIf(nAliquota>0,NoRound(nAliquota,2),12)
	EndIf

	Do Case
		// Verifica se a nota fiscal eh de Conhecimento de Frete
		Case aNfCab[NF_TPCOMP] == "F"
			// Verifica o Parametro MV_FRETEST que contem as Aliq. de ICMS/Frete
			If aSX6[MV_M116FOR] == .F. .And. aNfCab[NF_UFDEST]<>aNfCab[NF_UFORIGEM]
				If aNfCab[NF_UFDEST]$aSX6[MV_NORTE] .And.!(aNfCab[NF_UFORIGEM]$aSX6[MV_NORTE] )
					nAliquota := 7
				Else
					nALiquota := 12 // Aliquota de Frete Fixa em 12%
				EndIf
			ElseIf aSX6[MV_M116FOR] == .T. .And. !Empty(aNfItem[nItem][IT_EXCECAO])				
				nAliquota := Iif(SubStr(aNFItem[nItem][IT_TS][TS_CF],1,1) == "1" , aNfItem[nItem][IT_EXCECAO][01] ,aNfItem[nItem][IT_EXCECAO][02] ) 				
			Else
				nAliquota := Val(Substr(aSX6[MV_FRETEST],(AT(aNfCab[NF_UFORIGEM],aSX6[MV_FRETEST])+2),5))
				nAliquota := IIf(nAliquota>0,NoRound(nAliquota,2),12)
			EndIf
		Case AllTrim(aNFCab[NF_ESPECIE])$"CA" 
			// Verifica o Parametro MV_FRETEST que contem as Aliq. de ICMS/Frete
			If aNFCab[NF_LINSCR]
				If aNfCab[NF_UFDEST]$aSX6[MV_NORTE] .And. !(aNfCab[NF_UFORIGEM]$aSX6[MV_NORTE] )
					nAliquota := 7
				Else
					nAliquota := 12 // Aliquota de Frete Fixa em 12%
				EndIf
			EndIf
			// Verifica se a nota fiscal eh de Servicos
		Case ( aNFItem[nItem][IT_TS][TS_ISS] == "S" ) 
			// Calcula a aliquota do ISS
			If !lSolidario
				nAliquota := If ( aNfItem[nItem][IT_PRD][SB_ALIQISS] == 0 , aSX6[MV_ALIQISS] , aNfItem[nItem][IT_PRD][SB_ALIQISS] )
				// Verifica as Excecoes fiscais
				If ( !Empty(aNFitem[nItem][IT_EXCECAO]) )
					If ( aNFCab[NF_UFORIGEM]==aNFCab[NF_UFDEST])
						If (aNfItem[nItem][IT_EXCECAO][1] > 0)
							nAliquota := aNfItem[nItem][IT_EXCECAO][1] //Aliquota Interna
						EndIf
					Else
						If aNfItem[nItem][IT_EXCECAO][2] > 0
							nAliquota := aNfItem[nItem][IT_EXCECAO][2] //Aliquota Externa
						EndIf
					EndIf
				EndIf
			Else
				nAliquota := 0
			EndIf
		Case ( aNFItem[nItem][IT_TS][TS_PODER3] =="D" ) .And. !Empty(aNFItem[nItem][IT_RECORI]) .And. aNFItem[nItem][IT_TS][TS_OPERGAR] <> '1' .And. aSx6[MV_CDIFDEV] == 1//Devolucao de Poder de Terceiros // Quando for difal ou operacao em garantia Calcula aliq interestadual
				If aNFCab[NF_OPERNF] == "E"
					dbSelectArea("SD2")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					nAliquota  := SD2->D2_PICM
					cTipoNF    := IIf(SD2->D2_TIPO$"IP",SD2->D2_TIPO,cTipoNF)
				Else
					dbSelectArea("SD1")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					//1-no caso da devolucao de sucata preciso pegar a aliquota original para fazer o calulo do icms
					//2-caso em que eh feito o retorno de demonstracao e excede os 60 dias para SP e eh feita NF Compl ICMS
					//3-Tratamento para atender arts. 402 do RICMS-SP/2000 e na Portaria CAT n 22/2007 - Chamado TRCYAF - Retorno Beneficiamento com Suspensão fora do prazo
					If	!(aNFItem[nItem][IT_TS][TS_OPERSUC] == "1" .And. aNfCab[NF_SIMPSC]<>"1" .And. aNFCab[NF_SIMPNAC]<>"1") .And.;
						!(cTipoNF == "B" .And. SD1->D1_TIPO == "N" .And. aSX6[MV_ESTADO] == "SP" .And. AllTrim(aNfItem[nItem][IT_CF])$"5913/6913" .And. (dDataBase-SD1->D1_EMISSAO) > 60 .And. aNFCab[NF_UFORIGEM]==aNFCab[NF_UFDEST]) .And.;
						!(cTipoNF == "N" .And. SD1->D1_TIPO == "B" .And. aSX6[MV_ESTADO] == "SP" .And. (dDataBase-SD1->D1_EMISSAO) > 180 .And. aNFCab[NF_UFORIGEM]==aNFCab[NF_UFDEST])
						nAliquota := SD1->D1_PICM
					EndIF
					cTipoNF    := IIf(SD1->D1_TIPO$"IP",SD1->D1_TIPO,cTipoNF)
				EndIf

				// Flag p/ determinar se a aliquota foi obtida do doc. de origem.
				lCalcAliq := .F.

			// Nas devolucoes sempre pega a aliquota da NF original.
		Case ( aNFCab[NF_TIPONF] == "D" .And. !Empty(aNFItem[nItem][IT_RECORI]) .And. !FISXRTCOMP(aNFCab[NF_CLIFOR], aNFItem[nItem][IT_RECORI],aSX6))
			If aNFCab[NF_TIPONF] == "D"
				If ( aNFCab[NF_CLIFOR] == "C" )
					dbSelectArea("SD2")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					If !Empty(SD2->D2_PICM)
						nAliquota  := SD2->D2_PICM
					EndIf
					cTipoNF    := IIf(SD2->D2_TIPO$"IP",SD2->D2_TIPO,cTipoNF)
					If (SD2->D2_DESCZFR - (SD2->D2_DESCZFP + SD2->D2_DESCZFC) <> 0) .And. IIF(!Empty(aSX6[MV_IMPZFRC]),  !(SubStr( aNfItem[nItem][IT_CLASFIS],1,1 ) $ aSX6[MV_IMPZFRC]) ,aNfItem[nItem][IT_PRD][SB_IMPZFRC] $ " N")  //  So zera a aliquota se o item nao for importado, pois se for ele mantem a aliquota de icms da saida
						nAliquota := 0
					EndIf
				Else
					dbSelectArea("SD1")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					nAliquota  := SD1->D1_PICM
					If lSolidario .And. nAliquota == 0 .And. cPaisLoc == "BRA"
						nAliquota := SD1->D1_ALIQSOL
					EndIf
					cTipoNF    := IIf(SD1->D1_TIPO$"IP",SD1->D1_TIPO,cTipoNF)
				EndIf
			Else
				If ( aNFCab[NF_CLIFOR] == "C" )
					dbSelectArea("SD1")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					nAliquota  := SD1->D1_PICM
					cTipoNF    := IIf(SD1->D1_TIPO$"IP",SD1->D1_TIPO,cTipoNF)
				Else
					dbSelectArea("SD2")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					nAliquota  := SD2->D2_PICM
					cTipoNF    := IIf(SD2->D2_TIPO$"IP",SD2->D2_TIPO,cTipoNF)
				EndIf
			EndIf

			// Flag p/ determinar se a aliquota foi obtida do doc. de origem.
			lCalcAliq := .F.

			// Tratamento para Exportacao
		Case ( aNFCab[NF_TPCLIFOR] == "X" ) 
			If nModulo == 43
				If ( aNFCab[NF_CLIFOR]== "C" ) .And. ( aNFCab[NF_UFDEST]<> "X" )
					// Calculo da Aliquota de ICMS para Exportacao
					nAliquota := 12
				EndIf
			ElseIf ( aNFCab[NF_CLIFOR]=="C" )
				// Calculo da Aliquota de ICMS para Exportacao
				nAliquota := 13
			EndIf
			// Verifica as Excecoes fiscais
			If ( !Empty(aNFitem[nItem][IT_EXCECAO]) .And. aNFItem[nItem][IT_EXCECAO][1] > 0 .And. aNfItem[nItem][IT_EXCECAO][7] <> "S" )
				nAliquota := aNFItem[nItem][IT_EXCECAO][1] //Aliquota Interna
			EndIf

			// Tratamento para Nao Inscritos e Consumidores Finais
		Case ( aNFCab[NF_LINSCR] .And. Iif(ValType(aMVPPDIFAL)== "A",!lCalDifal,.F.)) 
			If ( aNFCab[NF_CLIFOR]=="F" )
				nAliquota := IIf(!Empty( aNfItem[nItem][IT_PRD][SB_PICM] ) , aNfItem[nItem][IT_PRD][SB_PICM] , FISXALQORI(aNFCab, aSX6, nItem) )
			EndIf

			If  Year( aNfCab[NF_DTEMISS] ) >= 2013							.And.	;
				( aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] )				.And.	;
				SubStr( aNfItem[nItem][IT_CLASFIS] , 1 , 1 ) $ "1|2|3|8"	.And.	;
				(Alltrim( aNfItem[nItem][IT_CF]) $cExceRes13 .Or. lCalDifal)
				nAliquota :=  4
			EndIf

			If aNfCab[NF_USAALIQSN] .And. (nAliqSN := MaAliqSimp(aNfCab, aNfItem, nItem)) > 0			
				nAliquota := nAliqSN			
			EndIf

			// Tratamento para calculo do FECP
			// Verifica as Excecoes fiscais
			If (!Empty(aNFItem[nItem][IT_EXCECAO]) .And. aNfItem[nItem][IT_EXCECAO][7] <> "S")
				If ( aNFCab[NF_UFORIGEM] == aNFCab[NF_UFDEST] )
					If ( aNFItem[nItem][IT_EXCECAO][1] ) <> 0
						nAliquota := aNFItem[nItem][IT_EXCECAO][1]  //Aliq. de ICMS Interna
					EndIf
				Else
					If (aNFItem[nItem][IT_EXCECAO][2] > 0)
						nAliquota :=  aNFItem[nItem][IT_EXCECAO][2]   //Aliq. de ICMS Externa
					EndIf
				EndIf
			EndIf

			// Tratamento para Operacoes internas com ICMS
		Case ( aNFCab[NF_UFORIGEM] == aNFCab[NF_UFDEST] )

			//Para situações onde a UF de origem é diferente do MV_ESTADO, vindo do TMS, não pode adotar alíquota do MV_ICMPAD, precisa adotar alíquota interna do destino
			If nModulo == 43 .AND. IntTms() .AND. lSolidario .AND. aNFCab[NF_UFORIGEM] <> aSX6[MV_ESTADO] .AND. (AllTrim(aNFCab[NF_ESPECIE]) $ "CTR/CTE" .Or. "NFST"$AllTrim(aNFCab[NF_ESPECIE]))
				//Neste caso precisa adotar o padrão da alíquota do destino, considerando o parâmetro
				nAliquota 	:= Val(Substr(aSX6[MV_FRETEST],(AT(aNfCab[NF_UFORIGEM],aSX6[MV_FRETEST])+2),5))
			EndIF

			If aNfCab[NF_USAALIQSN] .And. (nAliqSN := MaAliqSimp(aNfCab, aNfItem, nItem)) > 0 			
				nAliquota := nAliqSN			
			EndIf

			//Para situações em que é um pedido de compra, não é ossível adotar a MV_ICMPAD pois a filial de entrega é preenchida no campo cfilialent do cabeçalho do pedido
			//Deve ser adotada a aliquota do destino.
			If aNFCab[NF_UFORIGEM] <> aSX6[MV_ESTADO] .And. FunName()$"MATA120|MATA121"
				nAliquota := FISXAlqDest(nItem, aSX6, aNfCab, aNFItem)
			EndIf
			// Tratamento para calculo do FECP
			// Verifica as Excecoes fiscais
			If (!Empty(aNFItem[nItem][IT_EXCECAO]) .And. aNfItem[nItem][IT_EXCECAO][7] <> "S")
				If ( aNFItem[nItem][IT_EXCECAO][1] ) <> 0
					nAliquota :=  aNFItem[nItem][IT_EXCECAO][1]   //Aliq. de ICMS Interna
				EndIf
			EndIf

			// Tratamento para Operacaoes InterEstaduais com ICMS
		Case ( aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] )
			If ( aNFCab[NF_TIPONF] <> "D" )
				If ( aNFCab[NF_UFORIGEM] $ aSX6[MV_NORTE] )
					nAliquota := 12
				Else
					nAliquota := IIf( aNFCab[NF_UFDEST] $ aSX6[MV_NORTE] , 7 , 12 )
				EndIf

				// Tratamento para ser levado em consideracao a aliquota de destino
				//	para os cfops 5118/5119/6118/6119
				If aSX6[MV_ESTADO]== 'SP' .And. aNFCab[NF_UFORIGEM]==aSX6[MV_ESTADO] .And. (aNFItem[nItem][IT_CF] $ aSX6[MV_TESVEND]) .And. aNFCab[NF_UFDEST] == aNFCab[NF_UFORIGEM]
					nAliquota := IIf(!Empty( aNfItem[nItem][IT_PRD][SB_PICM] ) , aNfItem[nItem][IT_PRD][SB_PICM] , FISXALQORI(aNFCab, aSX6, nItem))
				EndIf
			Else
				// Para devolução deve obter a UF da nota de origem.
				cCmpDevUF := Iif(aNfCab[NF_OPERNF] == "S",aNFCab[NF_UFDEST],aNFCab[NF_UFORIGEM])
				// Calculo da Aliquota de ICMS
				If ( aNFCab[NF_UFORIGEM] $ aSX6[MV_NORTE] )
					nAliquota := IIf( cCmpDevUF $ aSX6[MV_NORTE] , 12 , 7 ) //MV_ICMTRF
				Else
					nAliquota := 12 //MV_ICMTRF
				Endif
			EndIf

		// 	tratamento Resolucao do Senado Federal 13/2012
		//	Aliquota Interestadual de 4% caio
		// Parecer da Consultoria tributaria: http://tdn.totvs.com/pages/viewpage.action?pageId=82477729
		//   Regras para aplicacao da Aliquota de 4%
		// - Operacao Interestadual
		// - Contribuinte do ICMS
		// - Operacao apos 01/01/2013
		// - Origem do item = 1,2,3,8
		// - Excecao 1: CFOP's de Venda destinada a Nao Contribuinte, ainda que possua IE (6107;6108) 	(cExceRes13)
		// - Excecao 2: CFOP de operacao registrada em Cupom Fiscal (6929)								(cExceRes13)
			If  Year( aNfCab[NF_DTEMISS] ) >= 2013							.And.	;
				SubStr( aNfItem[nItem][IT_CLASFIS] , 1 , 1 ) $ "1|2|3|8"	.And.	;
				(!Alltrim( aNfItem[nItem][IT_CF]) $cExceRes13 .Or. lCalDifal)
				nAliquota :=  4
			EndIf

			//Alimento com alíquota interestadual para que possa efetuar o cálculo da Antecipação tributária para Simples Nacional
			If (aNFCab[NF_SIMPNAC] =="1" .AND. aNFCab[NF_CLIFOR] =="F") .Or.;
			(lCalDifal .And. aNfItem[nItem][IT_TS][TS_DIFAL]=="1" .And. (Iif(IntTms() .And. nModulo == 43,iif(aNfCab[NF_TPFRETE] == "F",.T.,.F.),.T.)))
				aNFitem[nItem][IT_ALIQDIF] := nAliquota
			EndIF

			If aNfCab[NF_USAALIQSN] .And. (nAliqSN := MaAliqSimp(aNfCab, aNfItem, nItem)) > 0			
				nAliquota := nAliqSN			
			EndIf

			If (!Empty(aNFItem[nItem][IT_EXCECAO]))
				If (aNFItem[nItem][IT_EXCECAO][2]) <> 0
					nAliquota :=  aNFItem[nItem][IT_EXCECAO][2]   //Aliq. de ICMS Externa
				EndIf
			EndIf
	EndCase

	// FECOP - CEARA - Caso no SB1 seja configurado para calcular FECOP a aliquota do Solidario sera Majorada em 2% - opcoes informadas no SB1 de 19 % ou  27%
	If (nAlqFecop == 19 .Or. nAlqFecop == 27) .And. aSX6[MV_ESTADO] == "CE" .And. aNFCab[NF_UFDEST] == "CE" .And. aNfCab[NF_OPERNF] == "S"
		nAliquota := nAlqFecop
	EndIf
Else
	nAliquota := 0
EndIf

//----------------------------------------------------
//Tomada de decisao para majoracao da aliquota - FCP
//----------------------------------------------------
MaFisFECP(nItem,,,"ALQ")


lDifMaj := IIF((		aNFItem[nItem][IT_TS][TS_PICMDIF] == 100; 
				.And. 	aNFCab[NF_UFDEST] $ "RJ";
				.And. (aNFItem[nItem][IT_TS][TS_ICMSDIF] $ "7");
				),.F., .T.)

// Soh majoro a aliquota se:
// 1 - A aliquota nao foi obtida do docto de origem (lCalcAliq = .T.). Neste caso ja veio majorada.
// 2 - Nao for calculo de ST (lSolidario = .F.). A aliquota do ST sera majorada na propria MaAliqSol.
If lCalcAliq .And. !lSolidario .And. aNfItem[nItem][IT_ALIQFECP] > 0 .And. lDifMaj
	nAliquota	+=	aNfItem[nItem][IT_ALIQFECP]
EndIf

If ((aNFItem[nItem][IT_TS][TS_ICM] <> "N" .Or. lICDif .Or. lCalDifal ) .Or. (aNFCab[NF_SIMPNAC] =="1" .And. aNFItem[nItem][IT_TS][TS_COMPL] == "S" .And. (aNFItem[nItem][IT_TS][TS_CIAP] == "S" .Or. aNFItem[nItem][IT_TS][TS_CONSUMO] == "S"))) .Or. lFreteAut ;
	.Or. (IntTms() .And. nModulo == 43 .And. aNFItem[nItem][IT_TS][TS_ICM]=="N" .And. aNFItem[nItem][IT_TS][TS_LFICM]=="T")
	If !lSolidario
		aNFitem[nItem][IT_ALIQICM] := nAliquota
	EndIf
	aNFitem[nItem][IT_TIPONF ] := cTipoNF
Else
	aNFitem[nItem][IT_ALIQICM] := 0
	aNFitem[nItem][IT_TIPONF ] := cTipoNF
EndIf

//Simples Nacional - Aliquota ICMS solidario.
If cSimpNac $ "1/2" .And. lSolidario .And. aNFCab[NF_OPERNF] == "S"
	//Busca RecNo do Produto para verificar campo que trata a aliquota interna
	//a ser tributada para o Simples Nacional através de Exceção Fiscal.
	//O campo deve ser informado no parâmetro MV_ALQDFB1.
	If aNFCab[NF_UFORIGEM] == aNFCab[NF_UFDEST]
		If aPos[FP_MV_ALQDFB1]
			cAliqDifST := aNfItem[nItem][IT_PRD][SB_ALQDFB1]
		Endif
		If cAliqDifST $ "2 "
			aNFitem[nItem][IT_ALIQSOL] := Val(Subs(aSX6[MV_ESTICM] ,AT(aNFCab[NF_UFDEST],aSX6[MV_ESTICM])+2,5))
		EndIf
	Endif
EndIf

//Entrada de Conhecimento de Frete - Aliquota ICMS 4%.
//Valida se informado cliente de destino contribuinte, caso seja não contribuinte deve ser utilizada aliquota interestadual
If (aNFCab[NF_OPERNF] == "E") .And. (Empty(aNfCab[NF_CLIDEST]) .Or. !aNFCab[NF_CLIEDEST]) .And.;
((AllTrim(aNFCab[NF_ESPECIE])=="CA"  .And. (aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] .Or. aNFCab[NF_UFORIGEM]=="BA")) .Or. ;
	((AllTrim(aNFCab[NF_ESPECIE])=="CTE" .And. (aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] .Or. aNFCab[NF_UFORIGEM]=="BA") .And. aNFCab[NF_MODAL] == "02")))

	aNFitem[nItem][IT_ALIQICM] := 4

	// Verifica as Excecoes fiscais
	If ( !Empty(aNFItem[nItem][IT_EXCECAO]) .And. aNfItem[nItem][IT_EXCECAO][7] <> "S" )		
		If ( aNFItem[nItem][IT_EXCECAO][ Iif(aNFCab[NF_UFORIGEM] == aNFCab[NF_UFDEST], 1, 2 ) ] ) <> 0
			nAliquota := aNFItem[nItem][IT_EXCECAO][ Iif(aNFCab[NF_UFORIGEM] == aNFCab[NF_UFDEST], 1 , 2 ) ]
		EndIf
	Else
		nAliquota := 4
	Endif
EndIf

Return(nAliquota)

/*/
MaFisBSICM - Edson Maricate -08.12.1999
Executa o calculo da Base do ICMS do Item.
/*/
Function FISXBICMS(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, lReproc , lZF , lICDif , cCampo, lAgreg, cAliasPROD, aTes)
Local nSalvaBase  := 0
Local lIncide     := .F.
Local nReduzICMS  := 0
Local nReduzAnt	 := 0
Local nDespOri    := 0
Local nBsFrete    := 0
Local nAliqAgr    := 0
Local nDesAces	  := 0
Local lRet        := .F.
Local lVlr_Frt    := .F.
Local lDevTot     := aSX6[MV_DEVTOT]
Local lRedBIcm    := aSX6[MV_REBICM]
Local nAuxBicms   := 0
Local nIncLeitMG  := 0
Local aMaICMVeic  := {} //usado no PE MaICMVeic
Local aMaCalcICMS := {}
Local aPautICMS   := {}
Local aAreaSC6    := {}
Local nPautaICMS  := aNfItem[nItem][IT_PRD][SB_INT_ICM]
Local nPautICFOB  :=  IIf( !Empty(aNFitem[nItem,IT_EXCECAO]) .And. aNFItem[nItem,IT_EXCECAO,32] > 0 , aNFItem[nItem,IT_EXCECAO,32], Iif (aNfItem[nItem][IT_UFXPROD][UFP_PAUTFOB] > 0, aNfItem[nItem][IT_UFXPROD][UFP_PAUTFOB], aNfItem[nItem][IT_PRD][SB_MV_PAUTFOB]))
Local aMvUfirce   := {}
Local cOrigUf 	:= ""
Local nCustoEnt	:= 0
Local nPerc		:= 0
Local nBaseCalc 	:= 0
Local aAliqAgr	:= {}
Local nPerNort	:= 0
Local nPerSul		:= 0
Local nPerImp		:= 0
Local nAliqDed := 0
Local nIndice  := 0
Local lIndVFut := .F.
Local lPISImp  := .F.
Local lCOFImp  := .F.
Local lCalBIcm := .F.
Local nBsICMAntR := 0 
Local lTribICM	:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_ICMS)
Local lRed43080	:= .F.
Local lProdNac  := IIF(!Empty(aSX6[MV_IMPZFRC]),  !(SubStr( aNfItem[nItem][IT_CLASFIS],1,1 ) $ aSX6[MV_IMPZFRC]) ,aNfItem[nItem][IT_PRD][SB_IMPZFRC] $ " N") //Indica se o produto é nacional e deverá ter o desconto de ZFM aplicado

Local cOrigProd := 0

Default lZF       := .F.
Default lICDif    := .F.
Default cCampo    := ""
Default lAgreg    := .T.

//Abaixo grava no item se a NF foi emitida sob norma específica e se deva indicar dessa forma na geração do SpedFiscal
aNfItem[nItem][IT_NORESPE] := aNFItem[nItem][IT_TS][TS_NORESPE]

//O bloco a seguir providencia para que em operações de devolução e ou beneficiamento quando o parametro MV_DEVTOT = .T.
//o valor da BASE do ICMS seja igual a Base do Imposto do documento Original quando a devolução e ou beneficiamento for
//igual a do documento original, se houverem despesas acessorias inclusas na base do documento original (Frete, Despesas e Seguro)
//as mesmas deverão ser digitadas manualmente no documento de devolução.
If ( aNFCab[NF_TIPONF] $ "DB" .Or. aNFItem[nItem][IT_TS][TS_PODER3] =="D" ) .And. !Empty(aNFItem[nItem][IT_RECORI]) .And. !FISXRTCOMP(aNFCab[NF_CLIFOR], aNFItem[nItem][IT_RECORI],aSX6)
	If aNFCab[NF_TIPONF] $ "DB"
		If ( aNFCab[NF_CLIFOR] == "C")
			dbSelectArea("SD2")
			MsGoto(aNFItem[nItem][IT_RECORI])
			If aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT  .And. (Iif(!lDevTot ,SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0 , SD2->D2_BASEICM >0) .Or. ;
				(!aNfCab[NF_CALCSUF]$'IN '.And. aSX6[MV_DESCZF] .And. aSX6[MV_DESZFPC] ))

				aNfItem[nItem][IT_BASEICM] := SD2->D2_BASEICM
				aNfItem[nItem][IT_DEDICM]  := IIF(aNFItem[nItem][IT_TS][TS_AGREG]$"DRE" .And. cPaisLoc == "BRA",SD2->D2_DESCICM,0)
				aNfItem[nItem][IT_PREDIC]	:= aNFItem[nItem][IT_TS][TS_BASEICM]
				lRet := .T.
			ElseIf aNfItem[nItem][IT_QUANT] <> SD2->D2_QUANT .And. aNFItem[nItem][IT_TS][TS_DEVPARC]$"1S"
				aNfItem[nItem][IT_BASEICM] := (aNfItem[nItem][IT_QUANT] * SD2->D2_BASEICM)/SD2->D2_QUANT
				aNfItem[nItem][IT_DEDICM]  := IIF(aNFItem[nItem][IT_TS][TS_AGREG]$"DRE" .And. cPaisLoc == "BRA",(aNfItem[nItem][IT_QUANT] * SD2->D2_DESCICM)/SD2->D2_QUANT,0)
				If aNFItem[nItem][IT_TS][TS_AGREG]<>"F"
					aNfItem[nItem][IT_BICMORI]	:= aNfItem[nItem][IT_VALMERC] - (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]) + IIf(!lZF,aNfItem[nItem][IT_DESCZF],0) +  aNfItem[nItem][IT_ACRESCI]
				EndIf
				lRet := .T.
			EndIf
		Else
			dbSelectArea("SD1")
			MsGoto(aNFItem[nItem][IT_RECORI])
			If aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT .And. Iif(!lDevTot , SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0 ,SD1->D1_BASEICM > 0)
				aNfItem[nItem][IT_BASEICM] := SD1->D1_BASEICM
				aNfItem[nItem][IT_DEDICM]  := IIF(aNFItem[nItem][IT_TS][TS_AGREG]$"DRE" .And. cPaisLoc == "BRA" ,SD1->D1_DESCICM,0)
				aNfItem[nItem][IT_PREDIC]	:= aNFItem[nItem][IT_TS][TS_BASEICM]
				lRet := .T.
			ElseIf aNfItem[nItem][IT_QUANT] <> SD1->D1_QUANT .AND. aNFItem[nItem][IT_TS][TS_DEVPARC]$"1S"
				aNfItem[nItem][IT_BASEICM] := (aNfItem[nItem][IT_QUANT] * SD1->D1_BASEICM)/SD1->D1_QUANT
				aNfItem[nItem][IT_DEDICM]  := IIF(aNFItem[nItem][IT_TS][TS_AGREG]$"DRE" .And. cPaisLoc == "BRA",(aNfItem[nItem][IT_QUANT] * SD1->D1_DESCICM)/SD1->D1_QUANT,0)
				If aNFItem[nItem][IT_TS][TS_AGREG]<>"F"
					aNfItem[nItem][IT_BICMORI]	:= aNfItem[nItem][IT_VALMERC] - (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]) + IIf(!lZF,aNfItem[nItem][IT_DESCZF],0) +  aNfItem[nItem][IT_ACRESCI]
				EndIf
				lRet := .T.
			EndIf
		EndIf
		If aNFItem[nItem][IT_TS][TS_ICMSDIF] == "6"
			aNfItem[nItem][IT_DEDICM] += aNfItem[nItem][IT_ICMSDIF]
		EndIf //issue DSERFIS1-8601
	Else
		If ( aNFCab[NF_CLIFOR] == "C")
			dbSelectArea("SD1")
			MsGoto(aNFItem[nItem][IT_RECORI])
			If aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT .And. Iif(!lDevTot , SD1->D1_VALFRE+SD1->D1_SEGURO+SD1->D1_DESPESA==0 ,SD1->D1_BASEICM > 0)
				aNfItem[nItem][IT_BASEICM] := SD1->D1_BASEICM
				aNfItem[nItem][IT_DEDICM]  := IIF(aNFItem[nItem][IT_TS][TS_AGREG]$"DRE" .And. cPaisLoc == "BRA",SD1->D1_DESCICM,0)
				aNfItem[nItem][IT_PREDIC]	:= aNFItem[nItem][IT_TS][TS_BASEICM]
				If aNFItem[nItem][IT_TS][TS_OPERSUC]=="1" .And. (aNfCab[NF_SIMPSC]<>"1" .Or. aNFCab[NF_SIMPNAC]<>"1") .And. SD1->D1_BASEICM <= 0
					lRet := .F.
				Else
					lRet := .T.
				EndIf
			ElseIf aNfItem[nItem][IT_QUANT] <> SD1->D1_QUANT .AND. aNFItem[nItem][IT_TS][TS_DEVPARC]$"1S"
				aNfItem[nItem][IT_BASEICM] := (aNfItem[nItem][IT_QUANT] * SD1->D1_BASEICM)/SD1->D1_QUANT
				aNfItem[nItem][IT_DEDICM]  := IIF(aNFItem[nItem][IT_TS][TS_AGREG]$"DRE" .And. cPaisLoc == "BRA",(aNfItem[nItem][IT_QUANT] * SD1->D1_DESCICM)/SD1->D1_QUANT,0)
				lRet := .T.
			EndIf
		Else
			dbSelectArea("SD2")
			MsGoto(aNFItem[nItem][IT_RECORI])
			If aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT .And. Iif(!lDevTot ,SD2->D2_VALFRE+SD2->D2_SEGURO+SD2->D2_DESPESA==0 , SD2->D2_BASEICM >0)
				aNfItem[nItem][IT_BASEICM] := SD2->D2_BASEICM
				aNfItem[nItem][IT_DEDICM]  := IIF(aNFItem[nItem][IT_TS][TS_AGREG]$"DRE" .And. cPaisLoc == "BRA",SD2->D2_DESCICM,0)
				aNfItem[nItem][IT_PREDIC]	:= aNFItem[nItem][IT_TS][TS_BASEICM]
				lRet := .T.
			ElseIf aNfItem[nItem][IT_QUANT] <> SD2->D2_QUANT
				aNfItem[nItem][IT_BASEICM] := (aNfItem[nItem][IT_QUANT] * SD2->D2_BASEICM)/SD2->D2_QUANT
				aNfItem[nItem][IT_DEDICM]  := IIF(aNFItem[nItem][IT_TS][TS_AGREG]$"DRE" .And. cPaisLoc == "BRA",(aNfItem[nItem][IT_QUANT] * SD2->D2_DESCICM)/SD2->D2_QUANT,0)
				lRet := .T.
			EndIf
			If aNFItem[nItem][IT_TS][TS_ICMSDIF] == "6"
				aNfItem[nItem][IT_DEDICM] += aNfItem[nItem][IT_ICMSDIF]
			EndIf //issue DSERFIS1-8601
		EndIf
	EndIf
EndIf

//Para buscar a data da NF original de Simples Faturamento de Venda com entrega Futura
IF Alltrim(aNfItem[nItem][IT_CF])$aSX6[MV_REMVFUT] .And.  !Empty(aNFItem[nItem][IT_RECORI]) .And.  aNfItem[nItem][IT_INDICE] <> 0 .And. aNfItem[nItem][IT_TS][TS_INDVF] == '1' .And. (!aNFCab[NF_TIPONF] $ "DB")
    dbSelectArea("SD2")
    MsGoto(aNFItem[nItem][IT_RECORI])
    IF Month(SD2->D2_EMISSAO)  <>  Month(aNfCab[NF_DTEMISS]) .Or. Year(SD2->D2_EMISSAO)  <>  Year(aNfCab[NF_DTEMISS])
		dbSelectArea("F0R")
		F0R->(dbSetOrder(1))
		If F0R->(MsSeek(xFilial("F0R")+aNFCab[NF_UFDEST]+AnoMes(SD2->D2_EMISSAO)))
			nIndice := aNFCab[NF_INDICE]/F0R->F0R_INDICE
		EndIf
        lIndVFut := .T.
    EndIf
EndIf


	// Carrega a reducao da base do ICMS
	nReduzICMS := PerRedIC(aNfItem,nItem,aNfCab,@lRed43080)

	//Tratamento para Convênio 139/06, irá verificar CFOP e Campo no TES
	IF aLLTRIM(aNfItem[nItem][IT_CF]) $ aSX6[MV_C13906] .AND. aNFItem[nItem][IT_TS][TS_CV139] == "1"
		aNfItem[nItem][IT_CV139] := "1"
	Else
		aNfItem[nItem][IT_CV139] := ""
	EndIF

	//Utilizada função MaFisFECP para obter Aliquota do FECP complementar (IT_ALFCCMP) que sera agregada na base de calculo quando aplicada Difal
	//Quando for separada aliquota do fecp do calculo esta função deve ser removida.
	/*If aNfCab[NF_PPDIFAL] .And. (aNFItem[nItem][IT_TS][TS_AGREG]$"D" .Or.(aNFItem[nItem][IT_TS][TS_AGREG]$"I" .And. IntTms()))
		MaFisFECP(nItem)
	Endif*/

If !lRet
		If !lTribICM
		aNfItem[nItem][IT_DEDICM]:= 0

		lReproc := IIf(lReproc==Nil,.F.,lReproc)

		// Salva  a base do ICMS no reprocessamento.
		nSalvaBase	:= aNfItem[nItem][IT_BASEICM]

		// Variaveis para controle de PIS/COFINS importacao (c/ valor ou aliq. zero)
		lPISImp := (aNFItem[nItem][IT_TS][TS_INTBSIC]$"13" .And. (aNfItem[nItem][IT_VALPS2] > 0 .Or. aNFItem[nItem][IT_TS][TS_CSTPIS] $"73"))
		lCOFImp := (aNFItem[nItem][IT_TS][TS_INTBSIC]$"23" .And. (aNfItem[nItem][IT_VALCF2] > 0 .Or. aNFItem[nItem][IT_TS][TS_CSTCOF] $"73"))
		lCalBIcm:= (aNFItem[nItem][IT_TS][TS_PISCRED]$"3" .And. aNFItem[nItem][IT_TS][TS_PISCOF]$"4" .And. aNFItem[nItem][IT_TS][TS_CSTPIS] $"71" .And. aNFItem[nItem][IT_TS][TS_CSTCOF] $"71")

		//Operacoes com Sucata - Valor do Pis e Cofins integra a base de calculo do ICMS
		If !(aNFItem[nItem][IT_TS][TS_OPERSUC]=="1" .And. aNfCab[NF_SIMPSC]<>"1" .And. aNFCab[NF_SIMPNAC]<>"1")
			If lPISImp
				aNfItem[nItem][IT_BASEICM] := aNfItem[nItem][IT_BICMORI]
				aNfItem[nItem][IT_BASEICM] += aNfItem[nItem][IT_VALPS2]
			EndIf

			If lCOFImp
				If aNfItem[nItem][IT_BASEICM] <> (aNfItem[nItem][IT_BICMORI]+aNfItem[nItem][IT_VALPS2])
					aNfItem[nItem][IT_BASEICM] := aNfItem[nItem][IT_BICMORI]
				EndIf
				aNfItem[nItem][IT_BASEICM] += aNfItem[nItem][IT_VALCF2]
			EndIf

			If lCalBIcm
				aNfItem[nItem][IT_BASEICM] := aNfItem[nItem][IT_BICMORI]
			EndIf
		EndIf

		// Se o parâmetro está habilitado significa que não foi informado o II no valor aduaneiro então devo somar o II na base do ICMS para ficar correta.
		IF aSX6[MV_EIC0064] .And. (!(aNFItem[nItem][IT_TS][TS_AGREG] $ "B|C") .And. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_CLIFOR] =="F" .And. aNFCab[NF_TPCLIFOR] =="X" .And. Substr(aNfItem[nItem][IT_CF],1,1)=="3" .And. (lPISImp .And. lCOFImp .Or. lCalBIcm))
			aNfItem[nItem][IT_BASEICM] += aNfItem[nItem][IT_VALII]
		EndIf

		// Calculo da base de ICMS - Valor da Mercadoria
		//Issue Dserfis1-16425 - Não estava trazendo a base de ICMS para calculo de ICMS devendo deduzir somente o valor da mercadoria na Duplicata

		//Alteracao realizada caso o produto tenha o TES configurado
		//para aplicacao de Deducao ICM
		If FunName() == "FRTA010" .And. (aNFItem[nItem][IT_TS][TS_AGREG] == "D" .Or. aNFItem[nItem][IT_TS][TS_AGREG] == "R")
			aNfItem[nItem][IT_BICMORI]	:= aNfItem[nItem][IT_VALMERC] + IIf(!lZF,aNfItem[nItem][IT_DESCZF],0)
		Else
			aNfItem[nItem][IT_BICMORI]	:= aNfItem[nItem][IT_VALMERC] - (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]) + IIf(!lZF,aNfItem[nItem][IT_DESCZF],0) +  aNfItem[nItem][IT_ACRESCI]
		Endif
		If aNFItem[nItem][IT_TS][TS_ICMSDIF] == "6"
			aNfItem[nItem][IT_BICMORI] -= aNfItem[nItem][IT_ICMSDIF]
		EndIf//issue DSERFIS1-8601


		//Conforme parecer de nossa Consultora Tributaria:
		//Recomendo que a configuração quanto ao DESCONTO CONDICIONAL OU INCONDICIONAL no cadastro do TES, seja
		//tambem aplicado ao calculo do ICMS nas operacoes com a ZFM, de tal forma que quando
		//haja o desconto do PIS e da COFINS e o calculo do ICMS, que este seja feito segundo a
		//configuracao e interpretacao do cliente.
		If aNFItem[nItem][IT_TS][TS_DESCOND] == "1"
			aNfItem[nItem][IT_BICMORI] += (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT])
		EndIf

		If	aSX6[MV_ESTADO] == "BA" .And. aNfCab[NF_UFDEST] == "BA"  .And. aNFCab[NF_SIMPNAC] =="1" .And. aNfItem[nItem][IT_VRDICMS] > 0
			aNfItem[nItem][IT_BICMORI] += aNfItem[nItem][IT_VRDICMS]
		EndIf

		// DSERFISE-2323: Desconto SUFRAMA - Quando o sistema desconta o PIS/COFINS da base de cálculo, ele abate os valores do IT_VALMERC. 
		// Ao preencher os campos de frete, despesa e seguro, o sistema faz os recálculos dos valores. 
		// Nesse trecho, estamos recalculando o valor de IT_VALMERC para o valor original, pois quando o sistema recalcular os valores de PIS/COFINS esses valores serão descontados do IT_VALMERC.
		If  aNfCab[NF_CLIFOR]=="C" .And. !aNfCab[NF_CALCSUF]$"IN " .And. !aNFitem[nItem][IT_TIPONF ]$"BD" .And. ;
			aNFItem[nItem][IT_TS][TS_ISS] <> "S" .And. (aSX6[MV_DESCZF] .Or. aSX6[MV_DESZFPC]) .And. ( aNFItem[nItem][IT_TS][TS_PISCRED]$"134" ) .And. aNfItem[nItem][IT_DESCZF] > 0 .And.;
		    (aNfCab[NF_FRETE] > 0 .Or. aNfCab[NF_DESPESA] > 0 .Or. aNfCab[NF_SEGURO] > 0 .Or. aNfCab[NF_VLR_FRT] > 0 .Or. aNfCab[NF_AUTONOMO] > 0 .OR. (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]) > 0 ) .And. (!lProdNac .Or. !aSX6[MV_RPCBIZF])
				aNfItem[nItem][IT_VALMERC] := aNfItem[nItem][IT_BICMORI] + (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT])
		EndIf

		//-- Pauta ICMS por tipo de frete CIF/FOB - PORTARIA 216/2013 - SEFAZ/MT
		If nPautICFOB > 0 .And. aNfCab[NF_TPFRETE] == "F"//-- Se tipo frete = FOB utiliza Pauta ICMS-ST informada no parametro MV_PAUTFOB
			nPautaICMS := nPautICFOB	
		EndIf

		If aPE[PE_PAUTICMS]  //PE para tratamento de pauta de ICMS
			aPautICMS := ExecBlock( "PAUTICMS" , .F. , .F. , { cAliasPROD , Right(cAliasPROD,2)+"_INT_ICM" , nPautaICMS } )
			If aPautICMS[1] == "S"
				nPautaICMS := aPautICMS[2]
			EndIf
		EndIf

		// Calculo da base de ICMS - Pauta fiscal
		If ( nPautaICMS<>Nil .And.  nPautaICMS<>0 ) .Or. (!Empty(aNFitem[nItem][IT_EXCECAO]) .And. aNfItem[nItem][IT_EXCECAO][16]<>0) .Or. (!Empty(aNfItem[nItem][IT_UFXPROD]) .And. aNfItem[nItem][IT_UFXPROD][UFP_VLICMP]<>0)
			If Len (aNfItem[nItem][IT_EXCECAO])>0 .And. Iif( aNfCab[NF_TPFRETE] == "F" , aNFItem[nItem,IT_EXCECAO,32] > 0 , aNfItem[nItem][IT_EXCECAO][16] > 0 )

				aNfItem[nItem][IT_PAUTIC] := Iif( aNfCab[NF_TPFRETE] == "F" , aNFItem[nItem,IT_EXCECAO,32] , aNfItem[nItem][IT_EXCECAO][16] )

				If aNFItem[nItem][IT_TS][TS_PAUTICM] $ " 1"
					If aNfItem[nItem][IT_BICMORI] > 0 .And. Max(aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_PAUTIC] ,aNfItem[nItem][IT_BICMORI]) <> aNfItem[nItem][IT_BICMORI]
						aNfItem[nItem][IT_BICMORI] := aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_PAUTIC]
					Else
						aNfItem[nItem][IT_PAUTIC] := 0
					EndIf
				Else
					aNfItem[nItem][IT_BICMORI] := aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_PAUTIC]
				EndIf
			ElseIf Len (aNfItem[nItem][IT_UFXPROD])>0 .And. Iif( aNfCab[NF_TPFRETE] == "F" , aNfItem[nItem][IT_UFXPROD][UFP_PAUTFOB] > 0 , aNfItem[nItem][IT_UFXPROD][UFP_VLICMP] > 0 )

				aNfItem[nItem][IT_PAUTIC]	:= Iif( aNfCab[NF_TPFRETE] == "F" , aNfItem[nItem][IT_UFXPROD][UFP_PAUTFOB] , aNfItem[nItem][IT_UFXPROD][UFP_VLICMP] )

				If aNFItem[nItem][IT_TS][TS_PAUTICM] $ " 1"
					If aNfItem[nItem][IT_BICMORI] > 0 .And. Max(aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_PAUTIC] , aNfItem[nItem][IT_BICMORI]) <> aNfItem[nItem][IT_BICMORI]
						aNfItem[nItem][IT_BICMORI] := aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_PAUTIC]
					Else
						aNfItem[nItem][IT_PAUTIC] := 0
					EndIf
				Else
					aNfItem[nItem][IT_BICMORI] := aNfItem[nItem][IT_PAUTIC]
				EndIf
			Else
				If !Empty(aNFItem[nItem][IT_VLR_FRT])
					If (aNfItem[nItem][IT_BICMORI]+aNfItem[nItem][IT_FRETE]) < (aNfItem[nItem][IT_QUANT]*nPautaICMS+aNfItem[nItem][IT_VLR_FRT])
						aNfItem[nItem][IT_BICMORI] := aNfItem[nItem][IT_QUANT]*nPautaICMS
						aNfItem[nItem][IT_PAUTIC]  := nPautaICMS
						lVlr_Frt := .T.
					EndIf
				Else
					If aNFItem[nItem][IT_TS][TS_PAUTICM] $ " 1"
						If aNfItem[nItem][IT_BICMORI] > 0 .And. Max(aNfItem[nItem][IT_QUANT]*nPautaICMS,aNfItem[nItem][IT_BICMORI]) <> aNfItem[nItem][IT_BICMORI]
							aNfItem[nItem][IT_BICMORI] := aNfItem[nItem][IT_QUANT]*nPautaICMS
							aNfItem[nItem][IT_PAUTIC]  := nPautaICMS
						EndIf
					Else
						aNfItem[nItem][IT_BICMORI] := aNfItem[nItem][IT_QUANT]*nPautaICMS
					EndIf
				EndIf
			EndIf
			If !Empty( aSX6[MV_ICMPFAT] )
				aNfItem[nItem][IT_BICMORI] *= aNfItem[nItem][IT_PRD][SB_ICMPFAT]
			EndIf
			If aSX6[MV_ICPAUTA]=="2"
				If aNFItem[nItem][IT_TS][TS_DESPRDIC] $ " 1"
					If lVlr_Frt
						aNfItem[nItem][IT_BICMORI]	+= aNfItem[nItem][IT_VLR_FRT]
					Else
						aNfItem[nItem][IT_BICMORI]	+= aNfItem[nItem][IT_FRETE]
					EndIf
					aNfItem[nItem][IT_BSFRETE]	:= aNfItem[nItem][IT_FRETE]
					If aNFItem[nItem][IT_TS][TS_DESPICM] <> "2" .And. aNFItem[nItem][IT_TS][TS_DESPICM] <> "3"
						aNfItem[nItem][IT_BICMORI]	+= aNfItem[nItem][IT_DESPESA]
						aNfItem[nItem][IT_BICMORI]	+= aNfItem[nItem][IT_SEGURO]
						aNfItem[nItem][IT_BICMORI]	+= aNfItem[nItem][IT_AFRMIMP]
					EndIf
				Else
					If lVlr_Frt
						nDespOri += aNfItem[nItem][IT_VLR_FRT]
					Else
						nDespOri += aNfItem[nItem][IT_FRETE]
					EndIf
					nBsFrete += aNfItem[nItem][IT_FRETE]
					If aNFItem[nItem][IT_TS][TS_DESPICM] <> "2" .And. aNFItem[nItem][IT_TS][TS_DESPICM] <> "3"
						nDespOri += aNfItem[nItem][IT_DESPESA]
						nDespOri += aNfItem[nItem][IT_SEGURO]
					EndIf
				EndIf
			EndIf
		Else
			If aNFItem[nItem][IT_TS][TS_DESPRDIC] $ "1 " .Or. aNFItem[nItem][IT_TS][TS_DESPICM] $ "14"
				aNfItem[nItem][IT_BICMORI]	+= aNfItem[nItem][IT_FRETE]
				aNfItem[nItem][IT_BSFRETE]	:= aNfItem[nItem][IT_FRETE]
				If aNFItem[nItem][IT_TS][TS_DESPICM] <> "2" .And. aNFItem[nItem][IT_TS][TS_DESPICM] <> "3"
					aNfItem[nItem][IT_BICMORI]	+= aNfItem[nItem][IT_DESPESA]
					aNfItem[nItem][IT_BICMORI]	+= aNfItem[nItem][IT_SEGURO]
					aNfItem[nItem][IT_BICMORI]	+= aNfItem[nItem][IT_AFRMIMP]
				EndIf
			Else
				nDespOri += aNfItem[nItem][IT_FRETE]
				nBsFrete += aNfItem[nItem][IT_FRETE]
				If aNFItem[nItem][IT_TS][TS_DESPICM] <> "2" .And. aNFItem[nItem][IT_TS][TS_DESPICM] <> "3"
					nDespOri += aNfItem[nItem][IT_DESPESA]
					nDespOri += aNfItem[nItem][IT_SEGURO]
					nDespOri += aNfItem[nItem][IT_AFRMIMP]
				EndIf
			EndIf

			// A base do ICMS sera somente as despesas acessorias FRETE/SEGURO/DESPESAS usado para tributar o ICMS somente das despesas
			If aNFItem[nItem][IT_TS][TS_DESPICM] == "5" // Somente Despesas Acessorias
				aNfItem[nItem][IT_BICMORI]	:= aNfItem[nItem][IT_FRETE] + aNfItem[nItem][IT_SEGURO] + aNfItem[nItem][IT_DESPESA]
			EndIf

		EndIf
		If (aNFItem[nItem][IT_TS][TS_INCIDE] == "S" .Or. (aNFItem[nItem][IT_TS][TS_INCIDE] == "F" .And. aNFCab[NF_TPCLIFOR] =="F" .And. aNFCab[NF_CLIFOR] =="C")) .And.;
			aNFItem[nItem][IT_TS][TS_IPI] <> "R"
			lIncide := .T.
			If aNFitem[nItem][IT_TIPONF ] <> "P"
				If (aNFCab[NF_OPERNF] == "S" .And. aNfCab[NF_OPIRRF] == "EP" .And. aNFItem[nItem][IT_TS][TS_AGREG]=="D")//ADICIONADO MAIS UMA CONDIÇÃO NO IF (AGREG == "D") PARA QUE OUTROS CONTEXTOS NÃO SEJAM AFETADOS.
					MaFisIPI(nItem,"BSE|VLR",,"1")
					aNfItem[nItem][IT_BICMORI]	+= aNfItem[nItem][IT_VIPIORI]
					MaFisIPI(nItem,"BSE|VLR")
				Else
					aNfItem[nItem][IT_BICMORI]	+= aNfItem[nItem][IT_VALIPI]
				EndIf
			Else
				aNfItem[nItem][IT_BICMORI]	:= aNfItem[nItem][IT_VALIPI]
			EndIf
			If aNfItem[nItem][IT_BSFRETE] <> 0
				aNfItem[nItem][IT_BSFRETE]	+= aNfItem[nItem][IT_VALIPI]
			EndIf
			If aNFItem[nItem][IT_TS][TS_IPILICM] <> "1"
				aNfItem[nItem][IT_VIPIBICM]:= NoRound((aNfItem[nItem][IT_VALIPI]))
			Else
				aNfItem[nItem][IT_VIPIBICM]:= 0
			EndIf
		EndIf
		If aNFItem[nItem][IT_TS][TS_IPIVFCF]$"24"
			aNfItem[nItem][IT_BICMORI]+= aNfItem[nItem][IT_IPIVFCF]
		EndIf
		If ((aNFItem[nItem][IT_TS][TS_ICM] <> "N" .Or. lICDif) .And. !aNFitem[nItem][IT_TIPONF ]$"IP") .Or. (aNFitem[nItem][IT_TIPONF ]=="P".And.lIncide) .Or. (aNFCab[NF_SIMPNAC] =="1" .And. aNFItem[nItem][IT_TS][TS_COMPL] == "S" .And. aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] .And. (aNFItem[nItem][IT_TS][TS_CIAP] == "S" .Or. aNFItem[nItem][IT_TS][TS_CONSUMO] == "S"))
			nAliqAgr := 0
			nDesAces := 0
			If aNFItem[nItem][IT_TS][TS_DESPRDIC] == "2"
				If !(aNFItem[nItem][IT_TS][TS_DESPICM] $ "23")
					nDesAces := aNfItem[nItem][IT_FRETE] + aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO] + aNfItem[nItem][IT_AFRMIMP] 
				Else
					nDesAces := aNfItem[nItem][IT_FRETE]
				Endif
			Endif	
			If aNFItem[nItem][IT_TS][TS_AGRPIS]=="P" .And. !aNFItem[nItem][IT_TS][TS_INTBSIC]$"123"
				nAliqAgr += aNfItem[nItem][IT_ALIQPS2]
			Endif
			If aNFItem[nItem][IT_TS][TS_AGRCOF]=="C" .And. !aNFItem[nItem][IT_TS][TS_INTBSIC]$"123"
				nAliqAgr += aNfItem[nItem][IT_ALIQCF2]
			Endif

			If (aNFItem[nItem][IT_TS][TS_AGREG]=="I" .Or. aNFItem[nItem][IT_TS][TS_AGREG]=="A") .And. !aNFItem[nItem][IT_TS][TS_INTBSIC]$"123"

				//Tratamento para EC87 utilizar aliquota de destino
				If aNfCab[NF_PPDIFAL]
					nAliqAgr += aNfItem[nItem][IT_ALIQCMP]+aNfItem[nItem][IT_ALFCCMP]
				Else
					nAliqAgr += aNfItem[nItem][IT_ALIQICM]
				Endif

				If lAgreg
					If lRedBIcm
						If aSX6[MV_RNDICM]
							aNfItem[nItem][IT_BICMORI]	:= Round(aNfItem[nItem][IT_BICMORI]/( 1 - (nAliqAgr/100)),2)
						Else
							aNfItem[nItem][IT_BICMORI]	:= aNfItem[nItem][IT_BICMORI]/( 1 - (nAliqAgr/100))
						EndIf
					Else
						If aSX6[MV_RNDICM]
							aNfItem[nItem][IT_BICMORI]	:= Round(aNfItem[nItem][IT_BICMORI]/( 1 - (nAliqAgr/100*IIF(nReduzICMS==0,1,nReduzICMS/100))),2)
						Else
							aNfItem[nItem][IT_BICMORI]	:= aNfItem[nItem][IT_BICMORI]/( 1 - (nAliqAgr/100*IIF(nReduzICMS==0,1,nReduzICMS/100)))
							MaItArred(nItem,{"IT_BICMORI"})
						EndIf
					EndIf
				EndIf

				aNfItem[nItem][IT_BSFRETE]	:= Round(aNfItem[nItem][IT_BSFRETE]/( 1 - (nAliqAgr/100*IIF(nReduzICMS==0,1,nReduzICMS/100))),2)
				nDespOri := nDespOri/( 1 - (nAliqAgr/100))
				nBsFrete := nBsFrete/( 1 - (nAliqAgr/100))
			EndIf

			If ( aNFItem[nItem][IT_TS][TS_AGREG]=="D" .Or. aNFItem[nItem][IT_TS][TS_AGREG]=="R" )
				If aNfCab[NF_PPDIFAL] .And. aNFCab[NF_LINSCR] .And. aNfItem[nItem][IT_TS][TS_DEDDIF] $ " 1"
					nAliqDed := aNfItem[nItem][IT_ALIQCMP] + aNfItem[nItem][IT_ALFCCMP]
				Else
					nAliqDed :=	aNfItem[nItem][IT_ALIQICM]
				EndIf
				If (nReduzICMS > 0)
					If aSX6[MV_DBRDIF]
						aNfItem[nItem][IT_DEDICM] := Round((aNfItem[nItem][IT_BICMORI] - nDesAces) * nAliqDed/100 * (1-(nReduzICMS/100)),2)
					Else
						aNfItem[nItem][IT_DEDICM] := Round((aNfItem[nItem][IT_BICMORI] - nDesAces) * nAliqDed/100 * (nReduzICMS/100),2)
					EndIf
				Else
					aNfItem[nItem][IT_DEDICM] := (aNfItem[nItem][IT_BICMORI] - nDesAces)-Round((aNfItem[nItem][IT_BICMORI] - nDesAces) * (1-(nAliqDed/100*IIF(nReduzICMS==0,1,nReduzICMS/100))),2)
				EndIf
			EndIf

			If aNFItem[nItem][IT_TS][TS_ICMSDIF] == "6"
				aNfItem[nItem][IT_DEDICM]	:= aNfItem[nItem][IT_ICMSDIF]
			EndIf //issue DSERFIS1-8601

			If (aNFItem[nItem][IT_TS][TS_AGREG]=="E" )
			aNfItem[nItem][IT_DEDICM]	:= (aNfItem[nItem][IT_BICMORI] - nDesAces) - Round((aNfItem[nItem][IT_BICMORI] - nDesAces) * ( 1 - (aNfItem[nItem][IT_ALIQICM]/100*IIF(nReduzICMS==0,1,nReduzICMS/100))),2)
			EndIf
			// Salva a base de ICMS original e aplica a reducao.
			If !(aNFItem[nItem][IT_TS][TS_OPERSUC]=="1" .And. aNfCab[NF_SIMPSC]<>"1" .And. aNFCab[NF_SIMPNAC]<>"1")
				If !lPISImp .And. !lCOFImp .And. !lCalBIcm
					aNfItem[nItem][IT_BASEICM]	:= aNfItem[nItem][IT_BICMORI]
				EndIf
			ElseIf aNFItem[nItem][IT_TS][TS_OPERSUC]=="1" .And. aNfCab[NF_SIMPSC]<>"1" .And. aNFCab[NF_SIMPNAC]<>"1"
				aNfItem[nItem][IT_BASEICM]	:= aNfItem[nItem][IT_BICMORI]
				aNfItem[nItem][IT_BASEICM] += (aNfItem[nItem][IT_VALPS2]+aNfItem[nItem][IT_VALCF2])
			ElseIf aNFItem[nItem][IT_TS][TS_PODER3] =="D" .And. aNfItem[nItem][IT_BASEICM] <= 0
				aNfItem[nItem][IT_BASEICM]	:= aNfItem[nItem][IT_BICMORI]
			Endif
			//Aplica o desconto da ZF
			IF aNfCab[NF_SUFRAMA] .And. (aNfItem[nItem][IT_DESCZFPIS] + aNfItem[nItem][IT_DESCZFCOF]) > 0 .And. aNfCab[NF_UFDEST]$aSX6[MV_RPCBIUF]
				IF ((aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS] + aNfItem[nItem][IT_DESCZFCOF]))<=0) .And. nReduzICMS<=0 .And. ;//Se tiver desconto apenas de pis/cof
					IIF(!Empty(aSX6[MV_IMPZFRC]),  !(SubStr( aNfItem[nItem][IT_CLASFIS],1,1 ) $ aSX6[MV_IMPZFRC]) ,aNfItem[nItem][IT_PRD][SB_IMPZFRC] $ " N")
					aNfItem[nItem][IT_BASEICM] +=((aNfItem[nItem][IT_DESCZFPIS] + aNfItem[nItem][IT_DESCZFCOF]))
				Else
					aNfItem[nItem][IT_BASEICM] += aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS] + aNfItem[nItem][IT_DESCZFCOF])
				EndIf
			EndIf

			If nReduzICMS > 0
				//Tratamento realizado para que não seja efetuado cálculo quando a Redução de ICMS for 100% e não gere problemas na NF-e, porém
				//no trecho abaixo será atribuido novamente o percentual informado na TES para que não haja impacto nos demais tratamentos quando houver redução de 100%
				nReduzAnt := nReduzICMS
				nReduzICMS := IIf(nReduzICMS == 100, 0, nReduzICMS)			

				//Ao dobrar a base do ICMS(campo F4_BASEICM =200%)o valor do IPI NAO deve ser dobrado quando compor a base do ICMS para operacoes de venda de software
				//aNFItem[nItem][IT_TS][TS_VDASOFT] == "1" (SIM).
				If aNFItem[nItem][IT_TS][TS_VDASOFT] == "1" .And. nReduzICMS >= 100  .And. (aNFItem[nItem][IT_TS][TS_INCIDE] == "S" .Or. (aNFItem[nItem][IT_TS][TS_INCIDE] == "F" .And. aNFCab[NF_TPCLIFOR] =="F" .And. aNFCab[NF_CLIFOR] =="C")) .And. aNFItem[nItem][IT_TS][TS_IPI] <> "R"
					aNfItem[nItem][IT_BASEICM]	:= (aNfItem[nItem][IT_BASEICM] * nReduzICMS /100 ) - aNfItem[nItem][IT_VALIPI]
				Else
					If aNFItem[nItem][IT_TS][TS_BSRDICM] == "2"
						//a base de calculo da reducao sera composta apenas pelo valor da mercadoria sem o valor das
						//despesas acessorias.
						//apos aplicar o percentual de reducao, o valor das despesas acessorias (frete, seguro, despesas) e somado
						nAuxBicms := aNfItem[nItem][IT_VALMERC] - aNfItem[nItem][IT_DESCONTO]
						nAuxBicms := ( nAuxBicms * nReduzICMS / 100 ) + (aNfItem[nItem][IT_FRETE] + aNfItem[nItem][IT_SEGURO] + aNfItem[nItem][IT_DESPESA] + Iif(lIncide,aNfItem[nItem][IT_VALIPI],0) )
						aNfItem[nItem][IT_BASEICM]	:= nAuxBicms
					Else
						aNfItem[nItem][IT_BASEICM]	:= aNfItem[nItem][IT_BASEICM] * nReduzICMS /100
					EndIf
				Endif
				MaItArred(nItem,{"IT_BASEICM"})
				If nReduzICMS <> 200
				aNfItem[nItem][IT_BSFRETE]	:= aNfItem[nItem][IT_BSFRETE] * nReduzICMS /100
				EndIf
				MaItArred(nItem,{"IT_BSFRETE"})
				If (aNFItem[nItem][IT_TS][TS_INCIDE] == "S"  .Or. (aNFItem[nItem][IT_TS][TS_INCIDE] == "F" .And. aNFCab[NF_TPCLIFOR] =="F" .And. aNFCab[NF_CLIFOR] =="C")) .And.;
					aNFItem[nItem][IT_TS][TS_IPI] <> "R"
					aNfItem[nItem][IT_VIPIBICM]	:= NoRound(aNfItem[nItem][IT_VIPIBICM]* nReduzICMS /100,2)
				Else
					aNfItem[nItem][IT_VIPIBICM]	:= 0
				EndIf

				//Se o preco de venda for menor que o preço de pauta não aplica a redução
				//Atende ao Decreto N 51703 DE 31/07/2014 PARA RS
				If ((aPos[FP_F4_RDBSICM] .And. aNFItem[nItem][IT_TS][TS_RDBSICM] == "2") .And. ((aNfItem[nItem][IT_VALMERC] / aNfItem[nItem][IT_QUANT]) < aNfItem[nItem][IT_PAUTIC]))
					aNfItem[nItem][IT_BASEICM] := aNfItem[nItem][IT_BICMORI]
					aNfItem[nItem][IT_CLASFIS] := aNfItem[nItem][IT_PRD][SB_ORIGEM] + "00"
				EndIf

				//Atribuindo o valor de Redução anterior, caso seja 100% de redução
				If nReduzICMS == 0 .And. nReduzAnt == 100
					nReduzICMS := nReduzAnt
				EndIf

			EndIf
			If aNFItem[nItem][IT_TS][TS_DESPRDIC] == "2"
				aNfItem[nItem][IT_BASEICM] += nDespOri
				aNfItem[nItem][IT_BICMORI] += nDespOri
				aNfItem[nItem][IT_BSFRETE] += nBsFrete
			EndIf

			//retorna o valor para Unidade Fiscal Referencia do Ceará (UFIRCE)
			If 	(aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] .And. aNFCab[NF_UFDEST] == "CE" .And. aNFCab[NF_LINSCR] .And. anfcab[NF_OPERNF] == "S" .And. aNFItem[nItem][IT_TS][TS_VENPRES] <> "1")
				aMvUfirce := &(aSX6[MV_UFIRCE])
				If (aMvUfirce <> Nil .And. Len(aMvUfirce) == 2 .And. !Empty(aMvUfirce[01]) .And. !Empty(aMvUfirce[02]))
					If aNfItem[nItem][IT_VALMERC] > (aMvUfirce[1] * aMvUfirce[2])
						aNfItem[nItem][IT_BASEICM] := aNfItem[nItem][IT_VALMERC] - (aMvUfirce[1] * aMvUfirce[2])
					EndIf
				EndIf
			EndIf

			//Tratamento para atender o DECRETO N 35.679, de 13 de Outubro de 2010 - Pernambuco
			//Obs. Se o valor real da operação for menor que o cálculo realizado conforme Decreto, será considerado o Valor Real da Operação.
			If aNFCab[NF_OPERNF]=="S" .And. aSX6[MV_ESTADO] == "PE" .And. aNfCab[NF_UFDEST] == "PE"  .And. aNfItem[nItem][IT_TS][TS_CUSENTR] =="1"
				//Posiciono na tabela SD1 para buscar o valor do Custo de Aquisição mais recente
				dbSelectArea("SD1")
				SD1->(DbSetOrder(5))
				SD1->(DbSeek(xFilial("SD1")+aNfItem[nItem][IT_PRODUTO]+'ZZ',.T.))
				SD1->(DbSkip(-1))
				// Tratamento para desconsiderar registro de complemento de frete.
				While  SD1->(!BOF()) .And. (SD1->D1_COD == aNfItem[nItem][IT_PRODUTO] .And. SD1->D1_QUANT  ==  0)
					SD1->(DbSkip(-1))
				EndDo
				IF SD1->D1_COD == aNfItem[nItem][IT_PRODUTO]
					nCustoEnt := SD1->D1_CUSTO / SD1->D1_QUANT 
					nCustoEnt :=   nCustoEnt * aNfItem[nItem][IT_QUANT] 
					//Posiciono na tabela SF1 para buscar a UF de origem para efetuar os cálculos
					dbSelectArea("SF1")
					SF1->(dbSetOrder(1))
					If SF1->(dbSeek(xFilial("SF1")+ SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA ))
						cOrigUf := SF1->F1_EST
					EndIf
					//Percentual MV_AGRPERC
					aAliqAgr	:= &(aSX6[MV_AGRPERC])
					If aAliqAgr <> Nil
						If Len(aAliqAgr) == 2 .Or. Len(aAliqAgr) == 3
							nPerNort:= IIf(!Empty(aAliqAgr[1]), aAliqAgr[1], 0)
							nPerSul := IIf(!Empty(aAliqAgr[2]), aAliqAgr[2], 0)
						Endif
						If Len(aAliqAgr) == 3
							nPerImp := IIf(!Empty(aAliqAgr[3]), aAliqAgr[3], 0)
						Endif
					EndIf
					cOrigProd := SubStr(SD1->D1_CLASFIS, 1,1)
					//Percentual de acordo com a Ultima Aquisição
					If cOrigUf == "EX" .OR. cOrigProd $ "2|7"
						nPerc := nPerImp
					ElseIf cOrigUf $ aSX6[MV_NORTE]
						nPerc := nPerNort
					Else
						nPerc := nPerSul
					EndIf
					//Cálculo
					nBaseCalc += nCustoEnt + ((nCustoEnt * nPerc ) / 100)
					//Verifico se o valor calculado pelo D1_CUSTO é menor do que a Base Calculada anteriormente
					If nBaseCalc < aNfItem[nItem][IT_BASEICM]
						nReduzICMS								:= (nBaseCalc / aNfItem[nItem][IT_BASEICM]) * 100
						aNfItem[nItem,IT_PREDIC]				:= nReduzICMS
						aTes[TS_BASEICM]						:= nReduzICMS
						aNFItem[nItem][IT_TS][TS_BASEICM]	:= nReduzICMS
						aNfItem[nItem][IT_BASEICM]			:= nBaseCalc
					Endif
				EndIF
			EndIf

		Else
			aNfItem[nItem][IT_BASEICM]	:= 0
			aNfItem[nItem][IT_BSFRETE]	:= 0
		EndIf
		If lReproc
			// Tratamento se existir percentual de desconto do decreto RICMS-MG numero 43.080/2002
			if aNfItem[nItem][IT_PR43080]>0
				nBsICMAntR := nSalvaBase / (1-(aNfItem[nItem][IT_PR43080]/100))  
			endif
			//-->> Tratamento para não utilizar a base salva anteriormente que já está aplicado o desconoto do decreto RICMS-MG numero 43.080/2002
			//If aNFCab[NF_UFORIGEM] <> "MG" .And. aNfItem[nItem][IT_PRD][SB_PR43080] == 0
			aNfItem[nItem][IT_BASEICM]	:= nSalvaBase
			//Endif
		EndIf
	Else
		ICMSConf(aNFCab, aNfItem, nItem)
	EndIf
Else
	If !((aNFItem[nItem][IT_TS][TS_ICM] <> "N" .Or. lICDif) .And. !aNFitem[nItem][IT_TIPONF ]$"IP") .Or. (aNFitem[nItem][IT_TIPONF ]=="P".And.lIncide)
		aNfItem[nItem][IT_BASEICM]	:= 0
		aNfItem[nItem][IT_BSFRETE]	:= 0
	EndIf
EndIf

If !lTribICM
	//Verificacao da reducao da base de calculo do icms conforme decreto RICMS-MG numero 43.080/2002
	//O campo PR43080 só deve funcionara para operações de empresas de MG  http://www.fazenda.mg.gov.br/empresas/legislacao_tributaria/decretos/d43080_2002.htm
	If (lRed43080 .And. aNfItem[nItem][IT_BASEICM] > 0) .Or. (lReproc .And. aNfItem[nItem][IT_PR43080]>0)
		// Tratamento se existir percentual de desconto do decreto RICMS-MG numero 43.080/2002 pego do percentual 
		If lReproc .And. aNfItem[nItem][IT_PR43080]>0
			nReduzICMS := aNfItem[nItem][IT_PR43080]
		EndIf

		If !Empty(nReduzICMS)
			if lReproc .and. nBsICMAntR > 0 
				aNfItem[nItem][IT_BSSEMDS] := nBsICMAntR
			else
				aNfItem[nItem][IT_BSSEMDS] := aNfItem[nItem][IT_BASEICM] + ((aNfItem[nItem][IT_VALMERC]*(100-nReduzICMS))/100) //para guardar a base sem desconto
				aNfItem[nItem][IT_PR43080] := 100-nReduzICMS
			endif
		EndIf
	EndIf

	//verificacao do incentivo prod.leite artigo 207-B RICMS-MG
	If aNfItem[nItem][IT_VALMERC]>0 .And. aNFCab[NF_UFORIGEM]=="MG" .And. ((aPos[FP_A2_INCLTMG] .And. SA2->A2_INCLTMG=="1") .Or. (aPos[FP_A1_INCLTMG] .And. SA1->A1_INCLTMG=="1"));
	.And. !(AllTrim(aNfCab[NF_ESPECIE]) $ "CTR/CTE/CTA/CA/CTF" .Or. "NFST"$AllTrim(aNfCab[NF_ESPECIE]))
		//Entrada-Devolução
		If aPos[FP_A2_INCLTMG] .And. (aNFCab[NF_OPERNF]=="E" .Or. (aNFCab[NF_UFDEST]=="MG" .And. aNFCab[NF_OPERNF]=="S" .And. aNFCab[NF_TIPONF]$"D")) .And. (!Empty(aNfItem[nItem][IT_PRD][SB_PRINCMG]) .And. SA2->A2_INCLTMG=="1")
			nIncLeitMG := aNfItem[nItem][IT_PRD][SB_PRINCMG]		
			aNfItem[nItem][IT_PRINCMG]	:= nIncLeitMG		
		Endif
		//Saida
		If aPos[FP_A1_INCLTMG] .And. aNFCab[NF_UFDEST]=="MG" .And. (aNFCab[NF_OPERNF]=="S" .Or. (aNFCab[NF_OPERNF]=="E" .And. aNFCab[NF_TIPONF]$"D")) .AND. (!Empty(aNfItem[nItem][IT_PRD][SB_PRINCMG]) .And. SA1->A1_INCLTMG=="1")
			nIncLeitMG := aNfItem[nItem][IT_PRD][SB_PRINCMG]	
			aNfItem[nItem][IT_PRINCMG]	:= nIncLeitMG		
		Endif
		//tratamento para que seja possível ajustar até 0.02 centavos o valor do campo D1_VLINCMG
		If	(aNfItem[nItem][IT_VLINCMG] > 0 .And. ;
			aNfItem[nItem][IT_VALMERC]*(nIncLeitMG/100) <> aNfItem[nItem][IT_VLINCMG] .And. ;
			IIf(aNfItem[nItem][IT_VALMERC]*(nIncLeitMG/100) - aNfItem[nItem][IT_VLINCMG] <  0,;
			(aNfItem[nItem][IT_VALMERC]*(nIncLeitMG/100) - aNfItem[nItem][IT_VLINCMG])*-1 <= 0.02,;
			aNfItem[nItem][IT_VALMERC]*(nIncLeitMG/100) - aNfItem[nItem][IT_VLINCMG]     <= 0.02))
			aNfItem[nItem][IT_VLINCMG]	:= aNfItem[nItem][IT_VLINCMG]
		Else
		aNfItem[nItem][IT_VLINCMG]	:= Round(aNfItem[nItem][IT_VALMERC]*(nIncLeitMG/100),2)
		EndIf
	EndIf

	//Especifico para VEICULOS
	If cPaisLoc == "BRA" .And. aSX6[MV_VEICICM] .And. Substr(aNfItem[nItem][IT_CF],1,1)=="5" .And. aNfCab[NF_OPERNF] == "S" .And. aPos[FP_B1_CHASSI] .And. !Empty( aNfItem[nItem][IT_PRD][SB_CHASSI] ) // Alteracao de base para veiculos usados
		If aNfItem[nItem][IT_BASVEIC] == 0
			aAreaSC6 := SC6->(GetArea())
			SC6->(dbSetOrder(1))
			If SC6->( MsSeek(xFilial("SC6")+aNfCab[NF_PEDIDO]+aNfItem[nItem][IT_ITEM]+aNfItem[nItem][IT_PRODUTO]) )
				aNfItem[nItem][IT_BASVEIC] := SC6->C6_BASVEIC
			EndIf
			RestArea(aAreaSC6)
		EndIf
		If nReduzICMS > 0
			aNfItem[nItem][IT_BASEICM] := Round((aNfItem[nItem][IT_BICMORI] - aNfItem[nItem][IT_BASVEIC])*(nReduzICMS/100),2)
		Else
			aNfItem[nItem][IT_BASEICM] -= aNfItem[nItem][IT_BASVEIC]
		EndIf
		If aNfItem[nItem][IT_BASEICM] < 0
			aNfItem[nItem][IT_BASEICM] := 0
		EndIF
	EndIf

	//ATENCAO!!! Ponto de entrada para uso exclusivo da TOTVS, nao sugerir o uso do mesmo a clientes - GDP FISCAL
	If aPE[PE_MAICMVEIC]
		aMaICMVeic := ExecBlock("MaICMVeic",.f.,.f.,{nItem,aNfItem[nItem][IT_BASEICM],aNfItem[nItem][IT_ALIQICM],aNfItem[nItem][IT_VALICM]})
		aNfItem[nItem][IT_BASEICM] := aMaICMVeic[1]
		aNfItem[nItem][IT_ALIQICM] := aMaICMVeic[2]
		aNfItem[nItem][IT_VALICM]  := aMaICMVeic[3]
	EndIf

	If aPE[PE_MACALCICMS]
		aMaCalcICMS := ExecBlock("MACALCICMS",.f.,.f.,{aNfCab[NF_OPERNF],nItem,aNfItem[nItem][IT_BASEICM],aNfItem[nItem][IT_ALIQICM],aNfItem[nItem][IT_VALICM]})
		IF ValType(aMaCalcICMS) == "A"
			IF Len(aMaCalcICMS) == 3
				aNfItem[nItem][IT_BASEICM] := aMaCalcICMS[1]
				aNfItem[nItem][IT_ALIQICM] := aMaCalcICMS[2]
				aNfItem[nItem][IT_VALICM]  := aMaCalcICMS[3]
			Endif
		Endif
	Endif

	IF lIndVFut
		aNfItem[nItem][IT_BASEICM]  :=  aNfItem[nItem][IT_BASEICM] * (nIndice)
	EndIf

	//Tratamento para atender o Decreto n 13.780/2012, a Lei n 7.014/1996 e o Parecer n 26.733/2013
	//em resposta do fisco referente Redução na Alíq do ICMS nas vendas e remessas para empresas
	// do Simples Nacional nas operações internas - BA
	If	aNfItem[nItem][IT_VRDICMS] > 0
		aNFitem[nItem][IT_DESCONTO]-= aNfItem[nItem][IT_VRDICMS]
		aNfItem[nItem][IT_VRDICMS] := 0
	EndIf

	If	aSX6[MV_ESTADO] == "BA" .And. aNfCab[NF_UFDEST] == "BA"  .And. aNFCab[NF_SIMPNAC] =="1" .And. aNFItem[nItem][IT_TS][TS_FTRICMS] > 0
		aNfItem[nItem][IT_FTRICMS] 	:=	aNFItem[nItem][IT_TS][TS_FTRICMS]
		If lRet .And. cPaisLoc == "BRA"//Nota de Devolução usando o mesmo valor da nota para a referencia aNfItem[nItem][IT_BASEICM]				
			aNfItem[nItem][IT_VRDICMS] 	:=	Iif(aNFCab[NF_CLIFOR] == "C", SD2->D2_VRDICMS , SD1->D1_VRDICMS)  
			aNFitem[nItem][IT_VALMERC]	-=	aNfItem[nItem][IT_VRDICMS]
			aNfItem[nItem][IT_PRCUNI]	:=	aNFitem[nItem][IT_VALMERC] / aNfItem[nItem][IT_QUANT]		
		Else		
			aNfItem[nItem][IT_VRDICMS] 	:= Round((aNfItem[nItem][IT_BASEICM] * (aNfItem[nItem][IT_FTRICMS] / 100)),2)
			aNfItem[nItem][IT_BASEICM] 	:= aNfItem[nItem][IT_BASEICM] - aNfItem[nItem][IT_VRDICMS]
			aNFitem[nItem][IT_DESCONTO]	+= aNfItem[nItem][IT_VRDICMS]
		EndIf
	EndIf

	If	aNFItem[nItem][IT_TS][TS_AGRPEDG] $ "1|5" .And. aNfItem[nItem][IT_VALPEDG] > 0
		aNfItem[nItem][IT_BASEICM] += aNfItem[nItem][IT_VALPEDG]
	EndIf
Else
	ICMSConf(aNFCab, aNfItem, nItem)
EndIf

Return

/*/
xFisRtComp - Luciana Pires - 09.04.2008
Retorna os valores da nota fiscal de complemento de ICMS
	cAlOri - Defino Alias da tabela pelo tipo (se Cliente/Forn)
/*/
Function FISXRTCOMP(cAlOri,nRecOri,aSX6)

Local aArea			:= GetArea()
Local cAlias      	:= If(cAlOri == "C","SD2","SD1")
Local cQuery		:= ""
Local lQuery      	:= .F.
Local lComplem		:= .F.
Local lMvxfc    	:= aSX6[MV_XFCOMP]
Local cIndex		:= ""
Local nx 			:= 0
Local aInsert		:={}
Local cMD5			:= ""
Local nLen 			:= 0 

#IFDEF TOP
	Local aStru    	:= {}
#ELSE
	Local cChave	:= ""
#ENDIF

If !lMvxfc // Se .F. nao verificar notas complementares de ICMS.
	Return(lComplem)
Endif

dbSelectArea(cAlias)
(cAlias)->(DbSetOrder(1))
ProcRegua(LastRec())

#IFDEF TOP
	If ( TcSrvType()!="AS/400" )
		lQuery := .T.
		If !(Alltrim(cAlOri)=="C")
			cAlias := "SD1_COMP"
			aStru  := SD1->(dbStruct())
			cQuery := "SELECT D1_FILIAL, D1_NFORI, "
			cQuery += "       D1_SERIORI, D1_ITEMORI, "
			cQuery += "       D1_TIPO, D1_PICM,"
			cQuery += "       D1_BASEICM, D1_VALICM, "
			cQuery += "       D1_TES "
			cQuery += "FROM "+RetSqlName("SD1")+" SD1 "
			Aadd(aInsert,cValToChar(xFilial("SD1")))
			cQuery += "WHERE D1_FILIAL= ? AND "
			Aadd(aInsert,cValtochar(SD1->D1_FORNECE))
			cQuery +=        "D1_FORNECE = ? AND "
			Aadd(aInsert,cValtochar(SD1->D1_LOJA))
			cQuery +=        "D1_LOJA = ? AND "
			Aadd(aInsert,cValtochar(SD1->D1_DOC))
			cQuery +=        "D1_NFORI= ?AND "
			Aadd(aInsert,cValtochar(SD1->D1_SERIE))
			cQuery +=        "D1_SERIORI= ?  AND "
			Aadd(aInsert,cValtochar(SD1->D1_ITEM))
			cQuery +=        "D1_ITEMORI= ? AND "
			cQuery +=        "D1_TIPO='I' AND "
			cQuery +=        "D_E_L_E_T_=' ' "
			
			nLen := Len(aInsert)
			cMD5 := MD5(cQuery)
			If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0 
				Aadd(__aPrepared,{FWPreparedStatement():New(),cMD5})
				nPosPrepared := Len(__aPrepared)
				__aPrepared[nPosPrepared][1]:SetQuery(ChangeQuery(cQuery))
			EndIf 
			For nX := 1 to nLen
				__aPrepared[nPosPrepared][1]:SetString(nX,aInsert[nX])
			Next 
			cQuery := __aPrepared[nPosPrepared][1]:getFixQuery()
			aInsert := aSize(aInsert,0)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		Else
			cAlias := "SD2_COMP"
			aStru  := SD2->(dbStruct())
			cQuery := "SELECT D2_FILIAL, D2_NFORI, "
			cQuery += "       D2_SERIORI, D2_ITEMORI, "
			cQuery += "       D2_TIPO, D2_PICM,"
			cQuery += "       D2_BASEICM, D2_VALICM, "
			cQuery += "       D2_TES "
			cQuery += "FROM "+RetSqlName("SD2")+" SD2 "			
			Aadd(aInsert,cValToChar(xFilial("SD1")))
			cQuery += "WHERE D2_FILIAL= ? AND "
			Aadd(aInsert,cValtochar(SD2->D2_CLIENTE))
			cQuery +=        "D2_CLIENTE = ? AND "
			Aadd(aInsert,cValtochar(SD2->D2_LOJA))
			cQuery +=        "D2_LOJA = ? AND "
			Aadd(aInsert,cValtochar(SD2->D2_DOC))
			cQuery +=        "D2_NFORI= ? AND "
			Aadd(aInsert,cValtochar(SD2->D2_SERIE))
			cQuery +=        "D2_SERIORI= ? AND "
			Aadd(aInsert,cValtochar(SD2->D2_ITEM))
			cQuery +=        "D2_ITEMORI=?  AND "
			cQuery +=        "D2_TIPO='I' AND "
			cQuery +=        "D_E_L_E_T_=' ' "

			nLen := Len(aInsert)
			cMD5 := MD5(cQuery)
			If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0 
				Aadd(__aPrepared,{FWPreparedStatement():New(),cMD5})
				nPosPrepared := Len(__aPrepared)
				__aPrepared[nPosPrepared][1]:SetQuery(ChangeQuery(cQuery))
			EndIf 
			For nX := 1 to nLen
				__aPrepared[nPosPrepared][1]:SetString(nX,aInsert[nX])
			Next 
			cQuery := __aPrepared[nPosPrepared][1]:getFixQuery()
			aInsert := aSize(aInsert,0)
					
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
		Endif
		For nX := 1 To Len(aStru)
			If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0
				TcSetField(cAlias,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
			EndIf
		Next nX
		dbSelectArea(cAlias)
	Else
#ENDIF

#IFNDEF TOP	
	cIndex := CriaTrab(NIL,.F.)
    If !(Alltrim(cAlOri)=="C")
	    cChave := "D1_FILIAL+D1_NFORI+D1_SERIORI+D1_ITEMORI+D1_TIPO"
		cQuery := "D1_FILIAL=='"+xFilial("SD1")+"' .And. "
		cQuery += "D1_FORNECE=='"+SD1->D1_FORNECE+"' .And. "
		cQuery += "D1_LOJA=='"+SD1->D1_LOJA+"' .And. "
		cQuery += "D1_NFORI=='"+SD1->D1_DOC+"' .And. "
		cQuery += "D1_SERIORI=='"+SD1->D1_SERIE+"' .And. "
		cQuery += "D1_ITEMORI=='"+SD1->D1_ITEM+"' .And. "
		cQuery += "D1_TIPO=='I' "
	Else
	    cChave := "D2_FILIAL+D2_NFORI+D2_SERIORI+D2_ITEMORI+D2_TIPO"
		cQuery := "D2_FILIAL=='"+xFilial("SD2")+"' .And. "
		cQuery += "D2_CLIENTE=='"+SD2->D2_CLIENTE+"' .And. "
		cQuery += "D2_LOJA=='"+SD2->D2_LOJA+"' .And. "
		cQuery += "D2_NFORI=='"+SD2->D2_DOC+"' .And. "
		cQuery += "D2_SERIORI=='"+SD2->D2_SERIE+"' .And. "
		cQuery += "D2_ITEMORI=='"+SD2->D2_ITEM+"' .And. "
		cQuery += "D2_TIPO=='I' "
	Endif
    IndRegua(cAlias,cIndex,cChave,,cQuery)
    nIndex := RetIndex(cAlias)

	#IFNDEF TOP
		dbSetIndex(cIndex+OrdBagExt())
	#ENDIF

	If !(Alltrim(cAlOri)=="C")
		dbSelectArea("SD1")
	Else
		dbSelectArea("SD2")
	Endif

    dbSetOrder(nIndex+1)
    dbSelectArea(cAlias)
    ProcRegua(LastRec()) 
   	dbGoTop()

#endif 

#IFDEF TOP
	Endif
#ENDIF

Do While !(cAlias)->(Eof())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se achei a nota de complemento ja       ³
	//³posso voltar para a funcao original     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lComplem := .T.
	Exit
Enddo

If !lQuery
	#IFNDEF TOP
		If !(Alltrim(cAlOri)=="C")
			RetIndex("SD1")
		Else
			RetIndex("SD2")
		Endif
		dbClearFilter()
		Ferase(cIndex+OrdBagExt())
	#ENDIF
Else
	dbSelectArea(cAlias)
	dbCloseArea()	
Endif

RestArea(aArea)

Return(lComplem)

/*MaFisICDif - Luccas Curcio - 26.12.2011
Calculo do ICMS Diferido para os casos em que o valor de di-
ferimento de ICM eh o valor total do imposto(F4_PICMDIF=100)
*/
Static Function MaFisICDif(aNfItem, nItem)
Local	nBaseICM	:=	0
Local	nAliqICM	:=	0
Local	nICMSDif	:=	0

Local	aReseta		:=	{aNfItem[nItem][IT_BASEICM],;
aNfItem[nItem][IT_ALIQICM],;
aNfitem[nItem][IT_TIPONF],;
aNfItem[nItem][IT_BICMORI],;
aNfItem[nItem][IT_BSFRETE],;
aNfItem[nItem][IT_DEDICM],;
aNfItem[nItem][IT_VIPIBICM],;
aNFitem[nItem][IT_ALIQDIF],;
aNFitem[nItem][IT_ALIQSOL]}

// Calcula a aliquota e base de ICMS apenas para verificar o valor do ICMS Diferido
// Os valores da base e da aliquota serao posteriormente zerados novamente, pois essa
// situacao acontece apenas quando o campo F4_ICM = Nao, ou seja, todos os valores de
// ICMS da nota deverao estar zerados.

// Chama funcao que calcula base de ICMS
MaFisBSICM(nItem,.F.,,.T.)

// Atribui o valor da base para a variavel que ira calcular o ICMS Diferido
nBaseICM				:=	aNfItem[nItem][IT_BASEICM]

// Reseta variaveis
aNfItem[nItem][IT_BASEICM]		:=	aReseta[1]
aNfItem[nItem][IT_BICMORI]		:=	aReseta[4]
aNfItem[nItem][IT_BSFRETE]		:=	aReseta[5]
aNfItem[nItem][IT_DEDICM]		:=	aReseta[6]
aNfItem[nItem][IT_VIPIBICM]	:=	aReseta[7]

// Chama funcao que calcula aliquota de ICMS
MaAliqIcms(nItem,,.T.)
// Atribui o valor da aliquota para a variavel que ira calcular o ICMS Diferido
nAliqICM				:=	aNfItem[nItem][IT_ALIQICM]
// Reseta variaveis
aNfItem[nItem][IT_ALIQICM]		:=	aReseta[2]
aNfitem[nItem][IT_TIPONF]		:=	aReseta[3]
aNFitem[nItem][IT_ALIQDIF]		:=	aReseta[8]
aNFitem[nItem][IT_ALIQSOL]		:=	aReseta[9]
// Calcula o valor do ICMS Diferido, com base e aliquota 'virtuais'
nICMSDif	:=	nBaseICM * nAliqICM / 100

Return nICMSDif

/*MaAliqOrig - Edson Maricate -13.12.1999
Calculo da Aliquota para operacoes de ICMS
*/
Function FISXALQORI(aNFCab, aSX6, nItem)
Local nPerIcm
Local cOrig := aNFCab[NF_UFORIGEM]
Local cMVEstIcm := aSX6[MV_ESTICM]

nPerIcm := Val(Subs(cMVEstIcm,AT(cOrig,cMVEstIcm)+2,5))

Return(nPerIcm)

/*/{Protheus.doc} MaAliqSimp()
@description Função responsável por retornar a alíquota do ICMS
calculada pela apuração do SIMPLES NACIONAL.
@author joao.pellegrini
/*/
Static Function MaAliqSimp(aNfCab, aNfItem, nItem)
Local nPosAlq := 0

If !Empty(AllTrim(aNfItem[nItem][IT_CF]))
	nPosAlq := aScan(aNfCab[NF_ALIQSN], {|x| AllTrim(x[SN_CFOP]) == AllTrim(aNfItem[nItem][IT_CF])})
EndIf

Return Iif(nPosAlq > 0, aNfCab[NF_ALIQSN][nPosAlq][SN_ALIQ], 0 )  

/*MaFisAIEst
Retorna aliquota da operação interestadual
*/
Function FISXALIEST(aNFCab, aNfItem, aSX6, nItem)
Local nAlqIcmOri	:= 0
Local cExceRes13	:=	"6107|6108|6929"

If aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST]
	// Se o usuario alterou a aliquota de ICMS e inseriu uma aliquota interestadual (7, 12 ou 4) respeito a aliquota inserida.
	If (aNfItem[nItem][IT_ALIQICM] == 4 .Or. aNfItem[nItem][IT_ALIQICM] == 7 .Or. aNfItem[nItem][IT_ALIQICM] == 12)
		nAlqIcmOri := aNfItem[nItem][IT_ALIQICM]
	Else
		If (aNFCab[NF_UFORIGEM] $ aSX6[MV_NORTE])
			nAlqIcmOri := 12
		Else
			nAlqIcmOri := IIf(aNFCab[NF_UFDEST] $ aSX6[MV_NORTE], 7, 12)
		EndIf

		If SubStr(aNfItem[nItem][IT_CLASFIS], 1, 1) $ "1|2|3|8"	 .And. !Alltrim(aNfItem[nItem][IT_CF]) $ cExceRes13
			nAlqIcmOri := 4
		EndIf
	EndIf

EndIf
Return nAlqIcmOri

/*
MaAliqDest -Eduardo/Edson   -13.12.1999
Calculo da Aliquota para operacoes de ICMS
*/
Function FISXALQDEST(nItem, aSX6, aNfCab, aNFItem)

Local nPerIcm
Local cDestino := aNFCab[NF_UFDEST]

nPerIcm := Val(Subs(aSX6[MV_ESTICM],AT(cDestino,aSX6[MV_ESTICM])+2,5))

//Caso exsita aliquota informada na CFC utiliza esta aliquota.
IF aNfItem[nItem][IT_UFXPROD][UFP_PICM] > 0
	nPerIcm	:= aNfItem[nItem][IT_UFXPROD][UFP_PICM]
EndIf

If !Empty(aSX6[MV_FRETEST]) .And. (aNfCab[NF_TPCOMP] == "F"  .Or. (("/"+AllTrim(aNFCab[NF_ESPECIE])+"/") $"/CTR/CTE/NFST/"))
	nPerICM := Val(Substr(aSX6[MV_FRETEST],(AT(aNfCab[NF_UFDEST],aSX6[MV_FRETEST])+2),5))
	nPerICM := IIf(nPerICM>0,NoRound(nPerICM,2),Val(Subs(aSX6[MV_ESTICM],AT(cDestino,aSX6[MV_ESTICM])+2,5)))
EndIf
If ( !Empty(aNFItem[nItem][IT_EXCECAO]) )
	If ( aNFItem[nItem][IT_EXCECAO][6] ) <> 0
		nPerIcm := aNfItem[nItem][IT_EXCECAO][6]
	EndIf
EndIf
Return(nPerIcm)


/*/
MaFisVDescZF - Edson Maricate - 08.12.1999
Executa o calculo do Valor do Desconto da ZF.
Retorno
ExpN1: Item.
/*/
Function FISXDESCZF(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc)
Local nOldVlr  := aNfItem[nItem][IT_DESCZF]
Local lConsumo := aNFItem[nItem][IT_TS][TS_CONSUMO] == "S"
Local lExecuta := .T.
Local cUFCliFor := xFisCodIBGE(IIf(aNfCab[NF_OPERNF] == "S", aNfCab[NF_UFDEST], aNfCab[NF_UFORIGEM]))
Local cMunZFMALC := "1100106|1100304|1200203|1200104|1200252|1302603|1303569|1303536|1304062|1400456|1400100|1400159|1600303|1600600|"
Local cFunName := alltrim(FunName())
Local lProdNac := IIF(!Empty(aSX6[MV_IMPZFRC]),  !(SubStr( aNfItem[nItem][IT_CLASFIS],1,1 ) $ aSX6[MV_IMPZFRC]) ,aNfItem[nItem][IT_PRD][SB_IMPZFRC] $ " N")

/*
Foram consideradas as fontes abaixo para compor a lista dos municípios que formam a ZFM , ALCs e COREs que pertencam a zona incentivada
http://www.suframa.gov.br/suframa_fale_conosco_faq_internamento.cfm
http://www.suframa.gov.br/invest/zona-franca-de-manaus-alc.cfm
http://site.suframa.gov.br/assuntos/modelo-zona-franca-de-manaus/area-de-beneficios
http://tdn.totvs.com/pages/releaseview.action?pageId=336409606
*/

// Flag p/ determinar operacao interna na ZFM/ALC para definir se o ICMS deve ou nao ser descontado.
// Atencao: Eh interna em relacao aos municipios que fazem parte da ZFM/ALC/CORE e nao interna em relacao aos estados!
Local lIntALCZFM := AllTrim(aNFCab[NF_M0CODMUN]) $ cMunZFMALC .And. AllTrim(cUFCliFor+aNfCab[NF_CODMUN]) $ cMunZFMALC .AND. substr(aNfItem[nItem][IT_CF],1,1) == "5"

If aNFCab[NF_TIPONF] $ "DB" .Or. aNFItem[nItem][IT_TS][TS_PODER3] == "D"
	If !Empty(aNFItem[nItem][IT_RECORI])
		If aNFCab[NF_TIPONF] $ "DB"
			If aNFCab[NF_CLIFOR] == "C" .And. cPaisLoc == "BRA"
				dbSelectArea("SD2")
				MsGoto(aNFItem[nItem][IT_RECORI])
				If SD2->D2_DESCZFR > 0
					aNfItem[nItem][IT_DESCZF]:=  (SD2->D2_DESCZFR/SD2->D2_QUANT) * (aNfItem[nItem][IT_QUANT])
				EndIf
				If SD2->D2_DESCZFP > 0
					aNfItem[nItem][IT_DESCZFPIS]:=(SD2->D2_DESCZFP/SD2->D2_QUANT)* (aNfItem[nItem][IT_QUANT])
				EndIf
				If SD2->D2_DESCZFC > 0
					aNfItem[nItem][IT_DESCZFCOF]:=(SD2->D2_DESCZFC/SD2->D2_QUANT)* (aNfItem[nItem][IT_QUANT])
				EndIf

				//Se for devolução de venda para Zona Franca de Manaus, e houver calculado desconto do ICMS, irei zerar a base de cálculo e valor
				//pois na saída não houve o cálculo do ICMS, logo na devolução também não deve ter o cálculo, desta forma a informação do ICMS não
				//será gravada na CD2, resolvendo assim o erro "610 – Total da NF difere do somatório dos Valores que compõe o Valor Total da NF"
				//na transmissão da NFE.
				IF aNfItem[nItem][IT_DESCZF] > 0 .And. SD2->D2_VALICM == 0
					aNfItem[nItem][IT_BASEICM] := 0
					aNfItem[nItem][IT_VALICM]  := 0
				EndIF

				lExecuta := .F.
			EndIf
		EndIf
	EndIf
EndIf

If lExecuta

	If aNFItem[nItem][IT_TS][TS_CONSUMO] == " " // Garante se o produto na operacao eh material de consumo mesmo que na TES nao tenha sido informado
		If (aNFItem[nItem][IT_TS][TS_INCIDE] == "S" .Or. (aNFItem[nItem][IT_TS][TS_INCIDE] == "F" .And. aNFCab[NF_TPCLIFOR] == "F" .And. aNFCab[NF_CLIFOR] == "C" )) .And.;
			( Substr(aNfItem[nItem][IT_CF],2,3)$"91 /92 /97 " .Or. (Substr(aNfItem[nItem][IT_CF],2,2) $ "55" .And. Substr(aNfItem[nItem][IT_CF],4,1)<>" ")) .And. aNFItem[nItem][IT_TS][TS_IPI] <> "R"
			lConsumo := .T.
		Endif
	EndIf

	If aNfCab[NF_CLIFOR] == "C" .And. aNfCab[NF_SUFRAMA] .And. !aNFitem[nItem][IT_TIPONF ] $ "BD" .And. !aNfCab[NF_LINSCR] .And. ;
		lProdNac .And. aNFItem[nItem][IT_TS][TS_ISS] <> "S" .And. aNFItem[nItem][IT_TS][TS_ICM] == "S" .And. !lConsumo .And. aSX6[MV_DESCZF] .And.;
		( aNfCab[NF_OPERNF] == "S" .And. aNfCab[NF_TPCLIFOR] <> "F" ) .And. aNfCab[NF_CNPJ] <> SM0->M0_CGC .And. !lIntALCZFM
		aNfItem[nItem][IT_DESCZF]  := NoRound(aNfItem[nItem][IT_VALICM],2)
		MaItArred(nItem,{"IT_DESCZF"})
		aNfItem[nItem][IT_BASEICM] := 0
		aNfItem[nItem][IT_VALICM]  := 0

		If aNfCab[NF_ROTINA] $ "MATA461|FATA701" .Or. cFunName $ "MATA920|OFIXA018|OFIXA011|OFIXA100"

			// O valor de nOldVlr deverá ser deduzido somente quando o parâmetro MV_RPCBIUF estiver preenchido e a UF destino estiver contida no parâmetro, pois o sistema faz um fluxo diferente nesse caso.
			If aSX6[MV_RPCBIZF] .And. aNfCab[NF_UFDEST] $ aSX6[MV_RPCBIUF]
				aNfItem[nItem][IT_VALMERC] -= aNfItem[nItem][IT_DESCZF] -  nOldVlr
			Else
				aNfItem[nItem][IT_VALMERC] -= aNfItem[nItem][IT_DESCZF]
			EndIf			

			If cPaisLoc == "RUS"
				aNfItem[nItem][IT_VALMERC_C1] -= xMoeda((( aNfItem[nItem][IT_DESCZF]) -  nOldVlr),aNfCab[NF_MOEDA],1,dDataBase,,aNfCab[NF_TXMOEDA])
			EndIf
			If aNfCab[NF_TIPONF] $ "CPI" .And. cFunName $ "MATA920"
				aNfItem[nItem][IT_PRCUNI]:= ( aNfItem[nItem][IT_VALMERC] - (aNfItem[nItem][IT_DESCONTO]+ aNfItem[nItem][IT_DESCTOT]) )
			Else
				aNfItem[nItem][IT_PRCUNI]:= ( aNfItem[nItem][IT_VALMERC] - (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]) ) / aNfItem[nItem][IT_QUANT]
			EndIf
		EndIf

	Else

		aNfItem[nItem][IT_DESCZF] := 0

	EndIf

	aNfItem[nItem][IT_DESCZFPIS] := 0
	aNfItem[nItem][IT_DESCZFCOF] := 0

EndIf

Return

/*
±±³Funcao    ³xFisSitTri ³ Autor ³                       ³ Data ³         ³±±
±±³Descri‡…o ³                                                            ³±±*/
Function FISXSITTRI(aSX6,aPos)
Local cProduto	:=	""
Local cOrigem 	:=	""
Local cSitTrib	:=	""
Local nXProd	:=	0
Local nPosVal	:=	0
Local nPosQtdVen:=	0
Local dEmissao 	:= CtoD("//")
Local cCpoProd 	:= ""
Local cVarProd 	:= ""
Local nPosC6_TES:= 0
Local nPosCtl	:= 0
Local nPNumLt	:= 0
Local nPosCod	:= 0
Local nPosGrade	:= 0
Local cChkRfGrd	:= ""
Local lGrade	:= .F.
Local nPItGrd415:= 0
Local cTESProd  := ''
Local lOFIXACall := IsInCallStack("OFIXA018") .Or. IsInCallStack("OFIXA011") .Or. IsInCallStack("OFIXA100")

//Se o preco de venda for menor que o preço de pauta não aplica a redução
//Atende ao Decreto Nº 51703 DE 31/07/2014 PARA RS
If Type("aHeader") <> "U"
	nPosVal    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})
	nPosQtdVen := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
	nPosC6_TES := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
	nPosCod	   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
	nPosCtl	   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LOTECTL"})
	nPNumLt	   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NUMLOTE"})
	nPosGrade  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_GRADE"})
	nPItGrd415 := aScan(aHeader,{|x| AllTrim(x[2])=="CK_ITEMGRD"})
EndIf

If aSX6[MV_FISAUCF] .And. FindFunction( "XFciGetOrigem" )

	If IsInCallStack( "MATA410" ) // Pedido de venda
		cCpoProd := "C6_PRODUTO"
		cVarProd := "M->C6_PRODUTO"
		dEmissao := M->C5_EMISSAO
	ElseIf IsInCallStack( "MATA415" ) // Orçamento
		cCpoProd := "CK_PRODUTO"
		cVarProd := "M->CK_PRODUTO"
		dEmissao := M->CJ_EMISSAO
	ElseIf IsInCallStack( "FATA300" ) // Oportunidade
		cCpoProd := "ADZ_PRODUT"
		cVarProd := "M->ADZ_PRODUT"
		dEmissao := M->ADY_DATA
	EndIf

	If !Empty(cCpoProd) .And. !Empty(cVarProd) .And. !Empty(dEmissao)

		If SX7->X7_CAMPO $ cCpoProd .And. Type(cVarProd) <> "U"
			cProduto := &(cVarProd)
		Elseif Type('aCols')=='A' .And. Type('aHeader')=='A'
			nXProd := aScan(aHeader,{|x| AllTrim(x[2]) == cCpoProd})
			cProduto := aCols[n,nXProd]
		ElseIf IsInCallStack("MATA415") .And. (ReadVar() $ "M->CK_PRODUTO|M->CK_OPER|M->CK_TES")
			cProduto := TMP1->CK_PRODUTO
		EndIf

		cOrigem  := XFciGetOrigem( cProduto , dEmissao )[1]

	EndIf
Endif

If Empty(cOrigem)
	If IsInCallStack("MATA415") .And. (ReadVar() $ "M->CK_PRODUTO|M->CK_OPER|M->CK_TES")
		cProduto 	:= TMP1->CK_PRODUTO
		cChkRfGrd	:= TMP1->CK_PRODUTO
		lGrade		:= !Empty(nPItGrd415) .And. MaGrade() .AND. MatGrdPrrf(@cChkRfGrd)		
		If ReadVar() $ "M->CK_PRODUTO" .And. cProduto == SB1->B1_COD .And. TMP1->CK_TES <> SF4->F4_CODIGO
			SF4->(dbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4") + TMP1->CK_TES))
		EndIf
		cProduto	:= If(lGrade, cChkRfGrd, cProduto)
	ElseIf nPosCod > 0 .And. (IsInCallStack("MATA410") .Or. IsInCallStack("MATA416") .Or. IsInCallStack("FATA400") .Or. lOFIXACall)
		cChkRfGrd	:= aCols[n,nPosCod]
		lGrade		:= MaGrade() .AND. MatGrdPrrf(@cChkRfGrd)
		If lGrade .Or. Empty(cProduto)
			cProduto	:= If(lGrade .AND. aCols[n,nPosGrade] == "S", cChkRfGrd, aCols[n,nPosCod])
		EndIf
	EndIf
EndIf

If !Empty(cProduto)
	dbSelectArea("SB1")
	dbSetOrder(1)
	MsSeek(xFilial("SB1") + cProduto)
EndIf

//TES conforme cadastro do produto ou Indicador(SB1 ou SBZ conforme parâmetros)
cTESProd := RetFldProd(cProduto,'B1_TS')
If cTESProd <> "   " .And. nPosC6_TES > 0 .And. cTESProd == aCols[n,nPosC6_TES]
	dbSelectArea("SF4")
	dbSetOrder(1)
	MsSeek(xFilial("SF4") + cTESProd )
ElseIf nPosC6_TES > 0 .And. !Empty(aCols[n,nPosC6_TES])
	dbSelectArea("SF4")
	dbSetOrder(1)
	MsSeek(xFilial("SF4") + aCols[n,nPosC6_TES])
EndIf

If aPos[FP_F4_RDBSICM] .And. ((SF4->F4_RDBSICM == "2") .And. Type('aCols')=='A' .And. ((aCols[n][nPosVal] / aCols[n][nPosQtdVen]) < SB1->B1_INT_ICM))
	cSitTrib:= "00"
Else
	cSitTrib:= SF4->F4_SITTRIB
EndIf

If aSX6[MV_ORILOTE] .And. Empty(cOrigem) .And. !Empty(cProduto) .And. FindFunction("OrigemLote") .And. Rastro(cProduto)
	If ((nPosCtl > 0 .And. !Empty(aCols[n,nPosCtl])) .Or. (nPNumLt > 0 .And. !Empty(aCols[n,nPNumLt])))
		cOrigem := OrigemLote(cProduto, aCols[n,nPosCtl], aCols[n,nPNumLt])
	EndIf
EndIf

If Empty(cOrigem) //Origem  conforme cadastro do produto ou Indicador(SB1 ou SBZ conforme parâmetros)
	cOrigem := RetFldProd(cProduto,'B1_ORIGEM')
	If lGrade .AND. aCols[n,nPosGrade] == "S" .And. Empty(cOrigem) //Caso se trate de um produto do tipo grade, o sistema deverá considerar o produto já posicionado.
		cOrigem := SB1->B1_ORIGEM
	EndIf
Endif

//para produtos integrados com WMS, se a TES movimentar estoque carrega o Serviço,Endereço de Saida
If IsInCallStack( "MATA410" ) .Or. lOFIXACall
	nPosCod    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
	nPosCodTes := aScan(aHeader,{|x| AllTrim(x[2])=="C6_TES"})
	nPosSer    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERVIC"})
	nPosEnd    := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ENDPAD"})

	If nPosSer > 0 .And. IntDl(aCols[n][nPosCod]) .And. !Empty(aCols[n][nPosCodTes])
		SF4->(dbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4")+aCols[n][nPosCodTes]))
		If SF4->(!Eof()) .And. SF4->F4_ESTOQUE == "S"
			SB5->(dbSetOrder(1))
			If SB5->(MsSeek(xFilial("SB5")+aCols[n][nPosCod])) .And. Empty(aCols[n][nPosSer])
				If SB5->(FieldPos("B5_SERVSAI")) > 0
					aCols[n][nPosSer] := SB5->B5_SERVSAI
				EndIf
				If SB5->(FieldPos("B5_ENDSAI")) > 0
					aCols[n][nPosEnd] := SB5->B5_ENDSAI
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return cOrigem + cSitTrib

/*/
MaFisBSICA - Alexandre Lemes - 24/09/2012
Executa o calculo da Base do ICMS do frete Autonomo
*/
Function FISXICA(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc)
Local lTribFrete  := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_FRTAUT)
Local nPosTrG	  := 0

IF !lTribFrete
	aNfItem[nItem][IT_BASEICA]:= IIf( aNFItem[nItem][IT_TS][TS_LFICM] <> "N" .And. aNFItem[nItem][IT_TS][TS_FRETAUT] <> "2" .And. aNFItem[nItem][IT_TS][TS_FRETAUT] <> "3", aNfItem[nItem][IT_AUTONOMO] , 0 )
	aNfItem[nItem][IT_VALICA] := IIf( aNFItem[nItem][IT_TS][TS_LFICM] <> "N" , aNfItem[nItem][IT_BASEICA] * aNfItem[nItem][IT_ALIQICM] / 100 , 0 )
Else

	//Atualiza dados com configurador
	If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_FRTAUT})) > 0 	
	
		aNfItem[nItem][IT_BASEICA]  := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_BASE]
		aNfItem[nItem][IT_VALICA]  	:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]

	EndIf 

Endif

Return


/*/
PerRedIC - Rafael Oliveira - 29/07/2012
// Carrega a reducao da base do ICMS
*/
Function PerRedIC(aNfItem,nItem,aNfCab,lRed43080)
Local nReduzICMS := 0
Local nPosTrG := 0

Default aNfCab := {}
Default lRed43080 := .F.

If (nPosTrG:= aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_ICMS})) > 0
	If aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_LF][TG_LF_PERC_REDUCAO] > 0
		nReduzICMS:= 100-aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_LF][TG_LF_PERC_REDUCAO]
		aNfItem[nItem][IT_PREDIC] := nReduzICMS
	EndIf
Else
	// Carrega a reducao da base do ICMS
	//EXCEÇÃO
	If !Empty(aNFitem[nItem,IT_EXCECAO]) .And. aNfItem[nItem,IT_EXCECAO,14] > 0
		nReduzICMS := aNfItem[nItem,IT_EXCECAO,14]
	//TES
	Elseif aNFItem[nItem][IT_TS][TS_BASEICM] > 0
		nReduzICMS := aNFItem[nItem][IT_TS][TS_BASEICM]
	//PRODUTO
	//Verificacao da reducao da base de calculo do icms conforme decreto RICMS-MG numero 43.080/2002
	ElseIf !Empty(aNfCab) .And. aNfItem[nItem][IT_PRD][SB_PR43080] > 0 .And.;
			(( aNfCab[NF_OPERNF] == "S" .And. aNFCab[NF_UFORIGEM] == "MG") .OR.( aNfCab[NF_OPERNF] == "E" .and. aNfCab[NF_UFDEST] == "MG" .and. aNFCab[NF_UFORIGEM] $ "MG/EX"));
			.And. aNfItem[nItem][IT_CF] <> '5927'
		
		nReduzICMS := 100-aNfItem[nItem][IT_PRD][SB_PR43080]//Ajuste para funcionar igual ao campo da TES e Exceção
		lRed43080 := .T.

	EndIf

	aNfItem[nItem,IT_PREDIC] := nReduzICMS

EndIf 
Return nReduzICMS



/*/{Protheus.doc} ICMSConvRf 
	(Função responsavel por converter alteração de referencia legado em referencia do configurador)
	
	@author Erich Buttner
    @since 18/12/2020
    @version 12.1.27

	@param:	
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado	
	ccampo -> Campo que esta sendo alterado	

	/*/
Function ICMSConvRf(aNfItem, nItem, ccampo, nExecuta, aNfCab)
 Local cCampoConv 	 := ""
 Local cCmpBasRef    := ""
 Local cCmpAlqRef    := ""
 Local cCmpVlrRef    := ""
 
If nExecuta == 1 // ICMS
	cCmpBasRef    := "IT_BASEICM"
	cCmpAlqRef    := "IT_ALIQICM"
	cCmpVlrRef    := "IT_VALICM"
Elseif nExecuta == 2 //Frete autonomo
    cCmpBasRef    := "IT_BASEICA"	
	cCmpVlrRef    := "IT_VALICA"
ElseIF nExecuta == 3 // Desconto de Zona Franca ICMS
	cCmpVlrRef    := "IT_DESCZF"
ElseIF nExecuta == 4 // Diferimento de ICMS	
	cCmpVlrRef    := "IT_ICMSDIF"
ElseIF nExecuta == 5 // Estorno do crédito e Débito na apuração de ICMS    
	cCmpVlrRef    := "IT_ESTCRED"
Endif

IF cCampo $ cCmpBasRef
    cCampoConv := "TG_IT_BASE"
Elseif cCampo $ cCmpAlqRef
    cCampoConv := "TG_IT_ALIQUOTA"
Elseif cCampo $ cCmpVlrRef
	cCampoConv := "TG_IT_VALOR"
Endif	

Return cCampoConv


/*/{Protheus.doc} ICMSConf
 Função responsavel por gravar referencias com base no configurador

 	@author Erich Buttner
    @since 18/12/2020
    @version 12.1.27

	@param:	
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado	
	cMvEstado -> Estado
    nExecuta    -> Identifica calculo
    /*/
Static Function ICMSConf(aNFCab, aNfItem, nItem)
Local nPosTrG := 0

//ICMS
If (nPosTrG:= aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_ICMS})) > 0
	aNfItem[nItem][IT_BASEICM]  	 := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_BASE]
	aNfItem[nItem][IT_ALIQICM]  	 := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_ALIQUOTA]
	aNfItem[nItem][IT_VALICM]   	 := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]
	aNFItem[nItem][IT_TS][TS_LFICM] := RetLFLeg(aNfItem,nItem,nPosTrG,TS_LFICM)
	aNFItem[nItem][IT_TS][TS_ICM] := "S" 
	
	aNfItem[nItem][IT_PAUTIC]:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_PAUTA]

	If aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_LF][TG_LF_PERC_REDUCAO]
		aNfItem[nItem][IT_PREDIC]:= 100-aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_LF][TG_LF_PERC_REDUCAO]
	EndIf

	IF aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_REGRA_ESCR][RE_CSTCAB] =='000001' //Regime normal
		aNFItem[nItem][IT_TS][TS_SITTRIB] 	:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_REGRA_ESCR][RE_CST]

		//Chamada a função do pré-calculo para refazer a classificação do livro fiscal
		MaFisPreCalc(nItem,"IT_TES")

	Elseif aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_REGRA_ESCR][RE_CSTCAB] =='000002' //Simples Nacional
		aNFItem[nItem][IT_TS][TS_CSOSN] 	:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_REGRA_ESCR][RE_CST]
	Endif		

	IF aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_LF][TG_LF_DIFERIDO] > 0
		//Diferimento
		aNFItem[nItem][IT_TS][TS_PICMDIF]  	 := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_REGRA_ESCR][RE_PERCDIF]
		aNfItem[nItem][IT_ICMSDIF]  	 	 := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_LF][TG_LF_DIFERIDO]

		//Valor do ICMS da Operação - Sem diferimento (Valor como se não tivesse o diferimento)
		aNfItem[nItem][IT_VOPDIF]		 	 := aNfItem[nItem][IT_BASEICM] * aNfItem[nItem][IT_ALIQICM]/100
		MaItArred(nItem,{"IT_VOPDIF"})
	Endif


EndIf

//Estorno Crédito
If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_ESTICM})) > 0 			
	aNFItem[nItem][IT_TS][TS_ESTCRED]  	 := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_ALIQUOTA]		
	aNfItem[nItem][IT_ESTCRED]   	 	 := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]		
EndIf 

//Zona Franca
ZFTribLeg(aNFItem, nItem)

Return 


/*/{Protheus.doc} ZFTribLeg
 Função responsavel por gravar referencias com base no configurador

 	@author Rafael Oliveira
    @since 18/12/2020
    @version 12.1.30
*/

Function ZFTribLeg(aNFItem, nItem)
Local nPosTrG := 0
	
aNfItem[nItem][IT_DESCZF]  := 0

//Sempre faço Zona Franca de PIS, COFINS e ICMS devido a referencia IT_DESCZF acumular toda desonaração
If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_DZFICM})) > 0		
	aNfItem[nItem][IT_DESCZF]   	 := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]		
EndIf 
If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_DZFPIS})) > 0		
	aNfItem[nItem][IT_DESCZFPIS]   	 := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]		
EndIf 
If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_DZFCOF})) > 0		
	aNfItem[nItem][IT_DESCZFCOF]   	 := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]		
EndIf 

//Refrencia Acumula a desoneraçao de zona franca
aNfItem[nItem][IT_DESCZF] += aNfItem[nItem][IT_DESCZFPIS] + aNfItem[nItem][IT_DESCZFCOF]
	


Return
