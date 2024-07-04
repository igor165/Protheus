#INCLUDE "MATXFIS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/
MaFisVComp - Edson Maricate -08.12.1999
Executa o calculo do ICMS Complementar / Antecipacao ICMS
/*/
Function FisValDifal(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, lReproc, cCampo)
Local nMargem		:= 0
Local nBase			:= 0
Local nReduzICMS	:= 0
Local nRedICMSCOM	:= 0
Local nVlIcmOri		:= 0
Local nRedAntec		:= 0
Local cSimpNac		:= aSX6[MV_CODREG]
Local nSvValComp	:= 0
Local nSvValAnt		:= 0
Local nUltimo		:= 0
Local nDifal		:= 0
Local nPos			:= 0
Local aMVPPDIFAL	:= &(aSX6[MV_PPDIFAL])
Local lDifal		:= Iif(valType(aMVPPDIFAL)=="A", Len(aMVPPDIFAL)>0 .And. Year(aNfCab[NF_DTEMISS]) >= aMVPPDIFAL[1][1],.F.)
Local nBsAntIc 		:= 0
Local lDevCompra 	:= aNfCab[NF_TIPONF] == "D" .And. aNfCab[NF_OPERNF] == "S" .And. aNFCab[NF_CLIFOR] == "F"
Local lCalcula 		:= .T.
Local nAlqIcmOri := aNfItem[nItem][IT_ALIQICM]
Local lDevVda := .F.
Local lCompPrc := .F.
Local lBaseSimp	:= .F. /*Esta variável indica que na compra de simples nacional, com difal com base dupla, ao compor a base dupla o valor a ser retirado/expurgado será 
						 considerando alíquota do simples e não alíquota interestadual.
					     Irá seguir a fórmula de cálculo abaixo:
					    	Base de Cálculo X (1 – % ICMS que compõe a Alíquota do Simples Nacional (¹) / 100%) = Valor expurgado o imposto (valor sem ICMS);
							Valor expurgado o imposto / (1 – Alíquota interna / 100%) = Nova Base de Cálculo;
							Nova Base de Cálculo X (Alíquota Interna – Alíquota Interestadual) = Imposto a Recolher, ou seja, o DIFAL a UF do destino.
					     Link com exemplo do estado da Baha https://www.sefaz.ba.gov.br/contribuinte/tributacao/duvidas/diferenca_aliquota.pdf*/
Local lBicmcpl	:=	Iif(Empty(aNFItem[nItem][IT_TS][TS_BICMCMP]),.F.,.T.)
Local lProcEC87	     := .T.
Local lDevIntegral	:= .F.
Local nBaseICCpl	:=	0
Local nValoICCpl	:=	0
Local nPercRdICM	:=	0
Local nValoMerc		:=	0
Local lCompIcm		:= .F.
Local lCalDev       := aNfCab[NF_TIPONF]$"D|B" .And. aNFCab[NF_OPERNF] == "E" .And. aNFItem[nItem][IT_TS][TS_PODER3] =="D" // variável para saber se é uma devolução
Local lTribDifal	:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_DIFAL)
Local lTribCMP		:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_CMP)
Local lTribANTI		:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_ANTEC)
Local lDevTot     	:= aSX6[MV_DEVTOT]


Default lReproc	:= .F.
Default cCampo := ""

//Chamo aqui também a função ChkPPDIFAL, pois precisa ser atualizada aqui nas situações que for executada pelo MaFisAlt e não passar pela MaNewFisTES
//caso a nota fiscal possua itens que calculam difal e itens que não calculam difal (nota conjugada), pode acontecer da referência estar com status do último item
//e o difal pode ser calculado de forma indevida para todos os itens ou simplesmente não ser calculado para nenhum item, já que terá somente o status do último item processado
aNfCab[NF_PPDIFAL] := FisChkPDif(nItem,aMVPPDIFAL,aNfCab,aNfItem)

nSvValComp	:= aNfItem[nItem][IT_VALCMP]
nSvValAnt	:= aNfItem[nItem][IT_VALANTI]

// Reducao no Valor de Antecipação de ICMS
nRedAntec := aNFItem[nItem][IT_TS][TS_REDANT]

// Aliquota p/ calculo do ICMS "Original" quando nao for devolução.
// Nao usar IT_ALIQICM pois a aliquota deve ser sempre a da operacao interestadual,
// ou seja, 7, 12 ou 4 (produtos importados). Se utilizar o IT_ALIQICM e o fornecedor
// for optante do SIMPLES a aliquota no IT_ALIQICM sera, por exemplo, 3.41 e o calculo
// sera feito incorretamente.
If aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] .And. aNfCab[NF_TIPONF] <> "D"
	nAlqIcmOri := FISXALIEST(aNFCab, aNfItem, aSX6, nItem)
EndIf

//Valor do ICMS original, sem a reducao na base de calculo.
nVlIcmOri := aNfItem[nItem][IT_BICMORI] * (nAlqIcmOri / 100)

// Carrega a reducao da base do ICMS
If !Empty(aNFitem[nItem,IT_EXCECAO]) .And. aNfItem[nItem,IT_EXCECAO,14] > 0
	nReduzICMS := aNfItem[nItem,IT_EXCECAO,14]
Else
	nReduzICMS := aNFItem[nItem][IT_TS][TS_BASEICM]
EndIf

If !Empty(aNFitem[nItem,IT_EXCECAO]) .And. aNfItem[nItem,IT_EXCECAO,33] > 0
	nRedICMSCOM := aNfItem[nItem,IT_EXCECAO,33]
Else
	If aNFItem[nItem][IT_TS][TS_BASCMP] > 0
		nRedICMSCOM := aNFItem[nItem][IT_TS][TS_BASCMP]
	Endif
Endif

//Aliquota da antecipacao de ICMS - Proprio
//Excecao Fiscal
If !Empty(aNFitem[nItem,IT_EXCECAO]) .And. aNFItem[nItem,IT_EXCECAO,34] > 0
	aNfItem[nItem][IT_ALANTICMS]:= aNFItem[nItem,IT_EXCECAO,34]
//UFxUF
ElseIf aNfItem[nItem][IT_UFXPROD][UFP_ALANTICMS] > 0
	aNfItem[nItem][IT_ALANTICMS]:= aNfItem[nItem][IT_UFXPROD][UFP_ALANTICMS]
EndIf

aNfItem[nItem][IT_VALCMP] := 0
aNfItem[nItem][IT_VALANTI] := 0
aNfItem[nItem][IT_DIFAL] := 0
aNfItem[nItem][IT_PDDES] := 0
aNfItem[nItem][IT_PDORI] := 0
aNfItem[nItem][IT_BASEDES]:= 0

IF !lTribCMP // Se não for configurador faz legado
	If aNFItem[nItem][IT_TS][TS_COMPL] == "S" .And.(aNFItem[nItem][IT_TS][TS_ICM] $ "S/N" .Or. cSimpNac $ "1") .And. (aNfCab[NF_TIPONF]<>"D" .Or. lDevCompra) .And. !aNfCab[NF_PPDIFAL]

		// Tratamento p/ devolucao de compra com diferencial de aliquota calculado.
		// Necessario para que seja feito o estorno do valor na linha 016 da apuracao.
		If lDevCompra .And. !Empty(aNFItem[nItem][IT_RECORI])
			dbSelectArea("SD1")
			MsGoto(aNFItem[nItem][IT_RECORI])
			If aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT .And. SD1->D1_ICMSCOM > 0
				aNfItem[nItem][IT_VALCMP] := SD1->D1_ICMSCOM
				lCalcula := .F.
			EndIf
		EndIf

		// condição para saber se é uma devolução de venda, se for, não calcular ICMS complementar
		If lCalDev
			lCalcula := .F.
		EndIf

		If lCalcula

			If ( aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] ) .And. aNFItem[nItem][IT_TS][TS_MKPCMP]=="2"
				// Calculo do ICMS Complementar por margem de lucro
				nMargem := aNfItem[nItem][IT_MARGEM]

				//Calculo da Base do ICMS Complementar

				If !Empty(aNFitem[nItem,IT_EXCECAO]) .And. aNfItem[nItem,IT_EXCECAO,33] > 0
					nPercRdICM := 100 - aNfItem[nItem,IT_EXCECAO,33]
				Else
					If aNFItem[nItem][IT_TS][TS_BASCMP] > 0
						nPercRdICM  := 100 - aNFItem[nItem][IT_TS][TS_BASCMP]
					Endif
				Endif
				nValoMerc	:= aNfItem[nItem][IT_VALMERC]				//Valor da mercadoria		//O2
				nBaseICCpl	:= (nValoMerc * (100 - nPercRdICM)) / 100	//Base ICMS Complementar	//T2

				aNfItem[nItem][IT_BSICARD] := nBaseICCpl

				//Calculo do Valor do ICMS Complementar
				nValoICCpl	:= nBaseICCpl * (aNfItem[nItem][IT_ALIQCMP] - aNfItem[nItem][IT_ALIQICM]) / 100	//Valor do ICMS Comp. //V2
				If nValoICCpl < 0
					nValoICCpl := nValoICCpl * (-1)
				EndIf

				aNfItem[nItem][IT_VLICARD] := nValoICCpl

				//Tratamento efetuado para que o IPI NÃO seja considerado na Base de Cálculo do ICC, conforme solicitado na Portaria CAT 75 de 2008, Artigo 2 do
				//Regulamento de ICMS do Estado de São Paulo orienta sobre o assunto, na qual preve fato gerador do ICMS, quando ocorrer a entrada em estabelecimento do
				//Simples Nacional de mercadorias oriundas de outros Estados.
				nBase := IIf(aNFItem[nItem][IT_TS][TS_AGREG]<>"F",aNfItem[nItem][IT_VALMERC]-IIf(aNFItem[nItem][IT_TS][TS_AGREG]$"DR",aNfItem[nItem][IT_DEDICM],0),0)+;
				Iif(aNfCab[NF_TPCLIFOR]=="R" .And. cSimpNac $ "1" .And. aSX6[MV_ESTADO] == "SP" .And. aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST],0,IIf(aNFItem[nItem][IT_TS][TS_INCIDE]$"S",aNfItem[nItem][IT_VALIPI],0))+;
				aNfItem[nItem][IT_FRETE]+aNfItem[nItem][IT_SEGURO]+aNfItem[nItem][IT_DESPESA]+aNfItem[nItem][IT_ICMSDIF] //issue DSERFIS1-8601

				If aNFItem[nItem][IT_TS][TS_AGREG]<>"F" .and. aNFItem[nItem][IT_TS][TS_DESCOND] <> "1" 
					nBase -= (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT])
				EndIf

				If aNFItem[nItem][IT_TS][TS_DESPICM] == "2" .or. aNFItem[nItem][IT_TS][TS_DESPICM] == "3"
					nBase -= aNfItem[nItem][IT_DESPESA]
					nBase -= aNfItem[nItem][IT_SEGURO]
				EndIf

				// Operacoes de venda para consumidor final nao podem ter
				// margem de lucro se o destino for para uso e consumo.
				If aNFItem[nItem][IT_TS][TS_CONSUMO]$"SO" .And.;
					(	( aNfCab[NF_TPCLIFOR]=="F" .And. aNfCab[NF_CLIFOR]=="C" ) .Or.;
					( aNfCab[NF_CLIFOR]=="F" ) ) .And.;
					aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST]
					nMargem := 0
				EndIf

				If nReduzICMS > 0 .And. Iif(lBicmcpl,Iif(aNFItem[nItem][IT_TS][TS_BICMCMP] == "1",.T.,.F.),aSX6[MV_BICMCMP])
					nBase := (nBase*nReduzICMS)/100
					aNfItem[nItem][IT_PREDCMP]	:= nReduzICMS
				EndIf

				If nMargem > 0
					nBase := nBase*(1+(nMargem/100))
					aNfItem[nItem][IT_MVACMP]	:= nMargem
				EndIf

				//EC 87/2015 calculo para estado que aderiram DOLT/SUTRI n 002/2016
				//http://tdn.totvs.com/download/attachments/223929840/Parecer%20Consultoria%20Tribut%C3%A1ria%20Segmentos%20-%20TUESYM%20-%20Base%20de%20c%C3%A1lculo%20do%20diferencial%20de%20al%C3%ADquota%20%E2%80%93%20EC872015%20-%20MG.pdf?version=1&modificationDate=1453393192000&api=v2
				If lDifal .And. aSX6[MV_ESTADO] $ aSX6[MV_BASDENT] .And. (aNfCab[NF_OPERNF] == "E" .Or. lDevCompra) .And. ;
					(!(AllTrim(aNFCab[NF_ESPECIE])$"CTR/CTE/CTA/CA/CTF/NTSC/NTST" .Or. "NFST"$AllTrim(aNFCab[NF_ESPECIE])) .Or. aNFCab[NF_UFDEST] $ aSX6[MV_BASDPUF])

					If aSX6[MV_ESTADO] $ aSX6[MV_BASDEGO] //base de calculo conforme Estado de Goias Decreto 8.519 de 2015 - TVFCPK -TUWAOG
						nBase := aNfItem[nItem][IT_BASEDES] := nBase/(1-(aNfItem[nItem][IT_ALIQCMP]/100)) //Base Destino
					ElseIf aSX6[MV_ESTADO] $ aSX6[MV_BASDSER] //base de calculo conforme Estado de Sergipe http://tdn.totvs.com/pages/releaseview.action?pageId=267800346 - TWFOKI
						nBase := aNfItem[nItem][IT_BASEDES] := nBase/(1-((aNfItem[nItem][IT_ALIQCMP]-aNFItem[nItem,IT_ALIQICM])/100)) //Base Destino
					Else
						If aNFCab[NF_SIMPNAC] == "1" .And. aNfCab[NF_TPCLIFOR]=="F"
							nVlIcmOri := (aNfItem[nItem][IT_BASEICM]*aNfItem[nItem][IT_ALIQDIF]/100)
						EndIf
						If aNFCab[NF_SIMPNAC] == "1" .AND. aNFCab[NF_OPERNF] == "E"
							lBaseSimp	:= aSX6[MV_ESTADO]  $ aSX6[MV_BDSIMP] //MV_BDSIMP somente terá efeito para base dupla e compra de simples nacional
						EndIF
						nBase := aNfItem[nItem][IT_BASEDES] := (nBase- Iif(lBaseSimp, aNfItem[nItem][IT_VALICM] ,Iif(aNFCab[NF_SIMPNAC] == "1" .And. aNfCab[NF_TPCLIFOR]=="F", nVlIcmOri,aNfItem[nItem][IT_VALICM])))/(1-(aNfItem[nItem][IT_ALIQCMP]/100)) //Base Destino
					Endif

					If nRedICMSCOM > 0
						nBase := aNfItem[nItem][IT_BASEDES] := (nBase*nRedICMSCOM)/100
						aNfItem[nItem][IT_PREDCMP]	:= nRedICMSCOM
					Endif
				ElseIf	lDifal .And.	nRedICMSCOM > 0
					nBase := aNfItem[nItem][IT_BASEDES] := (nBase*nRedICMSCOM)/100
					aNfItem[nItem][IT_PREDCMP]	:= nRedICMSCOM
				EndIf

				If aNFCab[NF_SIMPNAC] == "1" .And. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_CLIFOR] =="F"
					nVlIcmOri := (aNfItem[nItem][IT_BASEICM]*aNfItem[nItem][IT_ALIQDIF]/100)
				EndIf

				IF aSX6[MV_CMPALIQ] //Calcula ICMS Complementar pela diferença entre aliquotas.
					aNfItem[nItem][IT_VALCMP] := (Iif(aNfItem[nItem][IT_BASEDES] > 0,nBase,Iif(Iif(lBicmcpl,Iif(aNFItem[nItem][IT_TS][TS_BICMCMP] == "1",.T.,.F.),aSX6[MV_BICMCMP]),aNfItem[nItem][IT_BASEICM],aNfItem[nItem][IT_BICMORI]))*((aNfItem[nItem][IT_ALIQCMP]- Iif(lBaseSimp, nAlqIcmOri ,aNFItem[nItem,IT_ALIQICM] )  )/100))
				Else
					aNfItem[nItem][IT_VALCMP] := (Iif(aNfItem[nItem][IT_BASEDES] > 0,nBase, Iif(Iif(lBicmcpl,Iif(aNFItem[nItem][IT_TS][TS_BICMCMP] == "1",.T.,.F.),aSX6[MV_BICMCMP]) , aNfItem[nItem][IT_BASEICM] , aNfItem[nItem][IT_BICMORI] )  )*(aNfItem[nItem][IT_ALIQCMP]/100)) -  IIf(lBaseSimp, aNfItem[nItem][IT_BASEICM] * aNFItem[nItem][IT_ALIQICM] / 100, Iif( aNFItem[nItem][IT_TS][TS_COMPRED] $ " 1", aNfItem[nItem][IT_VALICM], nVlIcmOri ))
				Endif

				If aNFItem[nItem][IT_TS][TS_COMPL] == "S" .And. aNFItem[nItem][IT_TS][TS_ICM] == "N" .and. aNFCab[NF_SIMPNAC] =="1" .and. (aNFItem[nItem][IT_TS][TS_CIAP] == "S" .Or. aNFItem[nItem][IT_TS][TS_CONSUMO] == "S")
					aNfItem[nItem][IT_VALICM] := 0
				EndIf

				/*
				Foi criado o parametro MV_DIFALIQ para que o usuario informe uma aliquota especifica a ser utilizada no calculo
				do ICMS Complementar.
				Ao aplicar esta aliquota, ira ignorar as regras utilizadas no calculo de diferenciacao entre aliquota interna e
				aliquota interestadual.
				*/
				If aSX6[MV_DIFALIQ] <> 0
					aNfItem[nItem][IT_VALCMP] := ( nBase * aSX6[MV_DIFALIQ] ) / 100
				Endif

				//Foi adicionado aqui para gravar a base destino após fazer o calculo e gravar os valores do complementar acima. Parece não fazer sentido, mas se não fosse base dupla e não tem redução do icm complementar não gravava base destino.
				//Para atender o caso de teste do legado: https://jiraproducao.totvs.com.br/secure/Tests.jspa#/testCase/GTSER-T13839
				if lDifal .and. aNfItem[nItem][IT_BASEDES]==0 .and. nBase>0
					aNfItem[nItem][IT_BASEDES] := nBase
				endif
			Else
				If ( aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] ) .And. aNFCab[NF_TPCLIFOR] <> "X"

					/* O diferencial de alíquotas, na aquisição interestadual de material de uso e consumo ou ativo imobilizado,
					o contribuinte, mesmo que optante pelo Simples Nacional, estará sujeito ao recolhimento do diferencial de alíquotas
					fora do regime simplificado*/

					//Tratamento efetuado para que o IPI NÃO seja considerado na Base de Cálculo do ICC, conforme solicitado na Portaria CAT 75 de 2008, Artigo 2 do
					//Regulamento de ICMS do Estado de São Paulo orienta sobre o assunto, na qual preve fato gerador do ICMS, quando ocorrer a entrada em estabelecimento do
					//Simples Nacional de mercadorias oriundas de outros Estados.
					nBase := IIf(aNFItem[nItem][IT_TS][TS_AGREG]<>"F",aNfItem[nItem][IT_VALMERC]-IIf(aNFItem[nItem][IT_TS][TS_AGREG]$"DR",aNfItem[nItem][IT_DEDICM],0),0)+;
					Iif(aNfCab[NF_TPCLIFOR]=="R" .And. cSimpNac $ "1" .And. aSX6[MV_ESTADO] == "SP" .And. aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST],0,IIf(aNFItem[nItem][IT_TS][TS_INCIDE]$"S",aNfItem[nItem][IT_VALIPI],0))+;
					aNfItem[nItem][IT_FRETE]+aNfItem[nItem][IT_SEGURO]+aNfItem[nItem][IT_DESPESA]

					If aNFItem[nItem][IT_TS][TS_AGREG]<>"F" .and. aNFItem[nItem][IT_TS][TS_DESCOND] <> "1" 
						nBase -= (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT])
					EndIf

					If aNFCab[NF_SIMPNAC] == "1" .And. aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_CLIFOR] =="F"
						nVlIcmOri := (aNfItem[nItem][IT_BASEICM]*aNfItem[nItem][IT_ALIQDIF]/100)
					EndIf

					IF aNFCab[NF_SIMPNAC] == "1" .AND. aNFCab[NF_CLIFOR] =="F"
						lBaseSimp	:= aSX6[MV_ESTADO]  $ aSX6[MV_BDSIMP] //MV_BDSIMP somente terá efeito para base dupla e compra de simples nacional
					EndIF

					//EC 87/2015 calculo para estado que aderiram DOLT/SUTRI n 002/2016
					//http://tdn.totvs.com/download/attachments/223929840/Parecer%20Consultoria%20Tribut%C3%A1ria%20Segmentos%20-%20TUESYM%20-%20Base%20de%20c%C3%A1lculo%20do%20diferencial%20de%20al%C3%ADquota%20%E2%80%93%20EC872015%20-%20MG.pdf?version=1&modificationDate=1453393192000&api=v2
					If lDifal .And. aSX6[MV_ESTADO] $ aSX6[MV_BASDENT] .And.(aNfCab[NF_OPERNF] == "E" .Or. lDevCompra) .And. ;
						(!(AllTrim(aNFCab[NF_ESPECIE])$"CTR/CTE/CTA/CA/CTF/NTSC/NTST" .Or. "NFST"$AllTrim(aNFCab[NF_ESPECIE])) .Or. aNFCab[NF_UFDEST] $ aSX6[MV_BASDPUF])

						If nReduzICMS > 0 .And. Iif(lBicmcpl,Iif(aNFItem[nItem][IT_TS][TS_BICMCMP] == "1",.T.,.F.),aSX6[MV_BICMCMP])
							nBase := (nBase*nReduzICMS)/100
							aNfItem[nItem][IT_PREDCMP]	:= nReduzICMS
						EndIf

						IF aSX6[MV_ESTADO] $ aSX6[MV_BASDEGO]
							aNfItem[nItem][IT_BASEDES] := nBase/(1-(aNfItem[nItem][IT_ALIQCMP]/100)) //Base Destino
						ElseIf aSX6[MV_ESTADO] $ aSX6[MV_BASDSER] //base de calculo conforme Estado de Sergipe http://tdn.totvs.com/pages/releaseview.action?pageId=267800346 - TWFOKI
							aNfItem[nItem][IT_BASEDES] := nBase/(1-((aNfItem[nItem][IT_ALIQCMP]-aNFItem[nItem,IT_ALIQICM])/100)) //Base Destino
						Else
							aNfItem[nItem][IT_BASEDES] := (nBase- Iif( aNFItem[nItem][IT_TS][TS_COMPRED] $ " 1" .OR. lBaseSimp , aNfItem[nItem][IT_VALICM], nVlIcmOri ))/(1-(aNfItem[nItem][IT_ALIQCMP]/100)) //Base Destino
						Endif

						If nRedICMSCOM > 0
							aNfItem[nItem][IT_BASEDES] := (aNfItem[nItem][IT_BASEDES]*nRedICMSCOM)/100
							aNfItem[nItem][IT_PREDCMP] := nRedICMSCOM
						Endif
					ElseIf	lDifal .And.	nRedICMSCOM > 0
						aNfItem[nItem][IT_BASEDES] := (aNfItem[nItem][IT_VALMERC]-aNfItem[nItem][IT_VALICM])/(1-(aNfItem[nItem][IT_ALIQCMP]/100)) //Base Destino
						aNfItem[nItem][IT_BASEDES] := (aNfItem[nItem][IT_BASEDES]*nRedICMSCOM)/100
						aNfItem[nItem][IT_PREDCMP] := nRedICMSCOM
					EndIf

					If aNFCab[NF_SIMPNAC] =="1" .And. aNFItem[nItem][IT_TS][TS_COMPL] == "S" .And. aNFItem[nItem][IT_TS][TS_CONSUMO]$"S" .And. aNFCab[NF_CLIFOR] =="F" .And. aNfItem[nItem][IT_ALIQCMP] >aNfItem[nItem][IT_ALIQDIF]
						aNfItem[nItem][IT_VALCMP] := (Iif(aNfItem[nItem][IT_BASEDES] > 0,aNfItem[nItem][IT_BASEDES],aNfItem[nItem][IT_BASEICM])*((aNfItem[nItem][IT_ALIQCMP] - Iif(lBaseSimp ,nAlqIcmOri , aNfItem[nItem][IT_ALIQDIF]) ) /100))
					Else 
						IF aSX6[MV_CMPALIQ] //Calcula ICMS Complementar pela diferença entre aliquotas.
							aNfItem[nItem][IT_VALCMP] := (Iif(aNfItem[nItem][IT_BASEDES] > 0,aNfItem[nItem][IT_BASEDES],Iif(Iif(lBicmcpl,Iif(aNFItem[nItem][IT_TS][TS_BICMCMP] == "1",.T.,.F.),aSX6[MV_BICMCMP]),aNfItem[nItem][IT_BASEICM],aNfItem[nItem][IT_BICMORI]))*((aNfItem[nItem][IT_ALIQCMP]- Iif(lBaseSimp ,nAlqIcmOri , aNFItem[nItem,IT_ALIQICM]) )/100))
						Else
							aNfItem[nItem][IT_VALCMP] := (Iif(aNfItem[nItem][IT_BASEDES] > 0,aNfItem[nItem][IT_BASEDES], Iif(Iif(lBicmcpl,Iif(aNFItem[nItem][IT_TS][TS_BICMCMP] == "1",.T.,.F.),aSX6[MV_BICMCMP]),aNfItem[nItem][IT_BASEICM] ,aNfItem[nItem][IT_BICMORI])   )*(aNfItem[nItem][IT_ALIQCMP]/100)) - IIf(lBaseSimp , aNfItem[nItem][IT_BASEICM] * aNFItem[nItem][IT_ALIQICM] / 100, Iif( aNFItem[nItem][IT_TS][TS_COMPRED] $ " 1", aNfItem[nItem][IT_VALICM], nVlIcmOri ))
						Endif
					EndIf

					If aNfCab[NF_OPERNF] == "E" .And. aNFCab[NF_SIMPNAC] == "1" .And. aNFItem[nItem][IT_TS][TS_ICM] == "N" .And. aNFItem[nItem][IT_TS][TS_COMPL] == "S" .And. aNFItem[nItem][IT_TS][TS_CIAP] == "S"
						aNfItem[nItem][IT_BASEICM]	:= 0
						aNfItem[nItem][IT_VALICM]	:= 0
					Endif

					If Iif(lBicmcpl,Iif(aNFItem[nItem][IT_TS][TS_BICMCMP] == "1",.T.,.F.),aSX6[MV_BICMCMP])
						aNfItem[nItem][IT_PREDCMP]	:= nReduzICMS
					Else
						aNfItem[nItem][IT_PREDCMP]	:= 0
					Endif

					/* Foi criado o parametro MV_DIFALIQ para que o usuario informe uma aliquota especifica a ser utilizada no calculo
					do ICMS Complementar.
					Ao aplicar esta aliquota, ira ignorar as regras utilizadas no calculo de diferenciacao entre aliquota interna e
					aliquota interestadual. */

					If aSX6[MV_DIFALIQ] <> 0
						If Iif(lBicmcpl,Iif(aNFItem[nItem][IT_TS][TS_BICMCMP] == "1",.T.,.F.),aSX6[MV_BICMCMP])
							aNfItem[nItem][IT_VALCMP] := ( aNfItem[nItem][IT_BASEICM] * aSX6[MV_DIFALIQ] ) / 100
						Else
							aNfItem[nItem][IT_VALCMP] := ( aNfItem[nItem][IT_BICMORI] * aSX6[MV_DIFALIQ] ) / 100
						Endif
					Endif

					//Foi adicionado aqui para gravar a base destino após fazer o calculo e gravar os valores do complementar acima. Parece não fazer sentido, mas se não fosse base dupla e não tem redução do icm complementar não gravava base destino.
					//Para atender o caso de teste do legado: https://jiraproducao.totvs.com.br/secure/Tests.jspa#/testCase/GTSER-T13839
					if lDifal .and. aNfItem[nItem][IT_BASEDES]==0 .and. nBase>0
						aNfItem[nItem][IT_BASEDES] := nBase
					endif

				EndIf
			EndIf

		EndIf
	EndIf
Else
	AtuLegDIF(aNfItem,nItem,1)
Endif

IF !lTribANTI // Se configurador calcula legado
	//Antecipacao ICMS - Mesma Regra do ICMS Complementar
	If aNFItem[nItem][IT_TS][TS_ANTICMS] == "1" .And. !aNfCab[NF_PPDIFAL]

		nBsAntIc := aNfItem[nItem][IT_BICMORI]

		//Tratamento Sutri MG 002
		If ( aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] ) .And. aNFCab[NF_TPCLIFOR] <> "X"
			If ((aSX6[MV_ESTADO] $ aSX6[MV_BASDENT]) .And. aSX6[MV_BASDANT] ) .And. aNfCab[NF_OPERNF] == "E" .And. ;
				!(AllTrim(aNFCab[NF_ESPECIE])$"CTR/CTE/CTA/CA/CTF/NTSC/NTST" .Or. "NFST"$AllTrim(aNFCab[NF_ESPECIE]))

				IF aNFCab[NF_SIMPNAC] == "1"
					nVlIcmOri := (aNfItem[nItem][IT_BICMORI] * aNfItem[nItem][IT_ALIQDIF]/100)
					nBsAntIc  := aNfItem[nItem][IT_BASEDES] := (aNfItem[nItem][IT_BICMORI]-nVlIcmOri)/(1-(aNfItem[nItem][IT_ALIQCMP]/100))
				ElseIf aSX6[MV_BSICMCM]
					nBsAntIc := aNfItem[nItem][IT_BASEDES] := aNfItem[nItem][IT_BASEICM]/(1-(aNfItem[nItem][IT_ALIQCMP]/100))
				Else
					nVlIcmOri := aNfItem[nItem][IT_BICMORI] * (aNfItem[nItem][IT_ALIQICM]/100)
					nBsAntIc := aNfItem[nItem][IT_BASEDES] := (aNfItem[nItem][IT_BICMORI]-nVlIcmOri)/(1-(aNfItem[nItem][IT_ALIQCMP]/100))
				Endif
			EndIf
		EndIf

		IF aNFCab[NF_SIMPNAC] == "1" .And. Iif(cSimpNac <> "1" .And. aSX6[MV_ESTADO] <> "MG",.T.,.F.)
			//Alteração referente a Issue MSERV-6527, tratamento feito contemplando apenas o estado de MG, conforme parecer da consultoria: http://tdn.totvs.com/x/V_yRDg
			//A Antecipação tributária para Fornecedor optante pelo Simples Nacional será calculado com alíquota interestadual normal, aplicando a
			//Alíquota que se aplicaria a operação caso o fornecedor não fosse optante pelo SN e não a que foi utiliza e destacada na nota fiscal.
			aNfItem[nItem][IT_VALANTI]:= ((nBsAntIc * IIf(nRedAntec > 0, (nRedAntec/100), 1)) * ((aNfItem[nItem][IT_ALIQCMP]-aNFitem[nItem][IT_ALIQDIF])/100))
		ElseIf aNFItem[nItem][IT_TS][TS_INCIDE] == "N" .And. aNFItem[nItem][IT_TS][TS_IPIANTE] == "1"
			aNfItem[nItem][IT_VALANTI]:= (((nBsAntIc + aNfItem[nItem][IT_VALIPI]) * IIf(nRedAntec > 0, (nRedAntec/100), 1)) * (aNfItem[nItem][IT_ALIQCMP]/100)) - nVlIcmOri
		ElseIf aNFItem[nItem][IT_TS][TS_INCIDE] == "N" .And. (aSX6[MV_ESTADO] $ "BA|MA|CE")
			// Implementação do tratametno abaixo com base na consultoria tributario.
			// http://tdn.totvs.com/pages/releaseview.action?pageId=264896731  Item 29
			// Tratamento diferenciado p/ BA - Só deduz o próprio destacado quando houver redução da antecipação. Caso contrário deduz o ICMS próprio original (s/ redução).
			aNfItem[nItem][IT_VALANTI] := (((aNfItem[nItem][IT_BICMORI] + aNfItem[nItem][IT_VALIPI]) * IIf(nRedAntec > 0, (nRedAntec/100), 1)) * (aNfItem[nItem][IT_ALIQCMP]/100)) - IIf((aSX6[MV_ESTADO] $ "BA" .And. nRedAntec > 0) .Or. aSX6[MV_ESTADO] $ "CE", aNfItem[nItem][IT_VALICM], nVlIcmOri)
		ElseIf aNfItem[nItem][IT_UFXPROD][UFP_VL_ANT] > 0
			// Antecipacao de ICMS com pauta.
			// http://tdn.totvs.com/pages/releaseview.action?pageId=271158371
			aNfItem[nItem][IT_VALANTI] := (((aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_UFXPROD][UFP_VL_ANT]) * IIf(nRedAntec > 0, (nRedAntec/100), 1)) * (aNfItem[nItem][IT_ALIQCMP]/100)) - aNfItem[nItem][IT_VALICM]
		ElseIf aNfItem[nItem][IT_ALANTICMS] > 0 .AND. aNFCab[NF_UFORIGEM] == aNFCab[NF_UFDEST]
			//Antecipacao de ICMS com porcentagem fixa
			aNfItem[nItem][IT_VALANTI]:= (aNfItem[nItem][IT_TOTAL] * IIf(aNfItem[nItem][IT_ALANTICMS] > 0, (aNfItem[nItem][IT_ALANTICMS]/100), 1))
		ElseIf aSX6[MV_CMPALIQ]
			aNfItem[nItem][IT_VALANTI]:= ((nBsAntIc * IIf(nRedAntec > 0, (nRedAntec/100), 1)) * ((aNfItem[nItem][IT_ALIQCMP]-aNfItem[nItem][IT_ALIQICM])/100))
		Else
			aNfItem[nItem][IT_VALANTI]:= ((nBsAntIc * IIf(nRedAntec > 0, (nRedAntec/100), 1)) * (aNfItem[nItem][IT_ALIQCMP]/100)) - nVlIcmOri
		Endif

		//Removido tratamento abaixo com base na consultoria
		// http://tdn.totvs.com/pages/releaseview.action?pageId=264896731  Item 29
		//Reducao Antecipação ICMS
		//Decreto  6.284 de 14/03/1997, Art. 352-A § 4. do Regulame  o do ICMS do Estado da Bahia
		/*If nRedAntec > 0
			aNfItem[nItem][IT_VALANTI]	:= aNfItem[nItem][IT_VALANTI] * nRedAntec /100
		EndIf*/

	EndIf
Else
	AtuLegDIF(aNfItem,nItem,2)
Endif

//Tratamento EC 87 -Diferencial de aliquota parcial para estado de destino
//http://tdn.totvs.com/pages/releaseview.action?pageId=189301460 //http://tdn.totvs.com/pages/releaseview.action?pageId=192096926
If (aNFItem[nItem][IT_TS][TS_COMPL] == "S" .And.( aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] ) .And.;
((aNfCab[NF_OPERNF] == "S" .And. ((aNFCab[NF_TPCLIFOR]=="F" .And. aNFCab[NF_LINSCR]) .Or. aNfCab[NF_TIPONF]=="D")) .Or. aNfCab[NF_OPERNF] == "E") .And. aNfCab[NF_PPDIFAL]) .Or. lTribDifal

	nUltimo := Len(aMVPPDIFAL)

	IF (nPos := aScan(aMVPPDIFAL,{|x| x[1]== Year(aNfCab[NF_DTEMISS])})) > 0
		aNfItem[nItem][IT_PDDES]:= aMVPPDIFAL[nPos][2]
		aNfItem[nItem][IT_PDORI]:= aMVPPDIFAL[nPos][3]
	ElseIf Year(aNfCab[NF_DTEMISS] ) > aMVPPDIFAL[nUltimo][1]

		aNfItem[nItem][IT_PDDES]:= aMVPPDIFAL[nUltimo][2]
		aNfItem[nItem][IT_PDORI]:= aMVPPDIFAL[nUltimo][3]
	Endif

	// Flags p/ facilitar a leitura do IF abaixo.
	lDevVda := (aNfCab[NF_TIPONF]$"D|B" .Or. (aNFCab[NF_OPERNF] == "E" .And. aNFItem[nItem][IT_TS][TS_PODER3] =="D"))
	lCompPrc := (aNfCab[NF_TIPONF] == "C" .And. (aNfCab[NF_TPCOMPL] == "1" .Or. Empty(aNfCab[NF_TPCOMPL])))
	lCompIcm := (aNfCab[NF_TIPONF] == "I")

	//EC 87 Devolucao de venda ou complemento de preco utiliza os percentuais da NF de origem.
	If (!Empty(aNFItem[nItem][IT_RECORI]) .And. aNfCab[NF_PPDIFAL] .And. (lDevVda .Or. lCompPrc .Or. lCompIcm))
		If aNFCab[NF_CLIFOR] == "C"
			dbSelectArea("SD2")
			MsGoto( aNFItem[nItem][IT_RECORI] )
			lDevIntegral := aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT
			//Espelha os percentuais
			IF SD2->D2_PDDES > 0 .OR. SD2->D2_PDORI > 0
				aNfitem[nItem][IT_PDDES] 	:= SD2->D2_PDDES
				aNfitem[nItem][IT_PDORI] 	:= SD2->D2_PDORI
			ElseIf (nPos := aScan(aMVPPDIFAL,{|x| x[1]== Year(SD2->D2_EMISSAO)})) > 0
				aNfItem[nItem][IT_PDDES]:= aMVPPDIFAL[nPos][2]
				aNfItem[nItem][IT_PDORI]:= aMVPPDIFAL[nPos][3]
			Endif

			//Espelha os valores na devolução integral ou proporcionaliza na devolução parcial
			If lDevVda .And. lDevTot
				aNfItem[nItem][IT_BASEDES]	:= Iif( lDevIntegral , SD2->D2_BASEDES , ( aNfItem[nItem][IT_QUANT] * SD2->D2_BASEDES ) / SD2->D2_QUANT )
				aNfItem[nItem][IT_DIFAL]	:= Iif( lDevIntegral , SD2->D2_DIFAL   , ( aNfItem[nItem][IT_QUANT] * SD2->D2_DIFAL   ) / SD2->D2_QUANT )
				aNfItem[nItem][IT_VALCMP]	:= Iif( lDevIntegral , SD2->D2_ICMSCOM , ( aNfItem[nItem][IT_QUANT] * SD2->D2_ICMSCOM ) / SD2->D2_QUANT )
			EndIf

		Else
			dbSelectArea("SD1")
			MsGoto( aNFItem[nItem][IT_RECORI] )
			lDevIntegral := aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT

			//Espelha os percentuais
			aNfitem[nItem][IT_PDDES] 	:= SD1->D1_PDDES
			aNfitem[nItem][IT_PDORI] 	:= SD1->D1_PDORI

			//Espelha os valores na devolução integral ou proporcionaliza na devolução parcial
			If lDevVda .And. lDevTot
				aNfItem[nItem][IT_BASEDES]	:= Iif( lDevIntegral , SD1->D1_BASEDES , ( aNfItem[nItem][IT_QUANT] * SD1->D1_BASEDES ) / SD1->D1_QUANT )
				aNfItem[nItem][IT_DIFAL]	:= Iif( lDevIntegral , SD1->D1_DIFAL   , ( aNfItem[nItem][IT_QUANT] * SD1->D1_DIFAL   ) / SD1->D1_QUANT )
				aNfItem[nItem][IT_VALCMP]	:= Iif( lDevIntegral , SD1->D1_ICMSCOM , ( aNfItem[nItem][IT_QUANT] * SD1->D1_ICMSCOM ) / SD1->D1_QUANT )
			EndIf

		EndIf

		If nRedICMSCOM > 0
			aNfItem[nItem][IT_PREDCMP]	:= nRedICMSCOM
		Endif

		//Se o DEVPARC estiver com conteúdo 1 ou S, siginifica que proporcionalizará os valores na devolução, e não deverá recalcular.
		If (lDevIntegral .OR. aNFItem[nItem][IT_TS][TS_DEVPARC] $ "1S") .And. lDevTot
			lProcEC87	:= .F.
		EndIF

	EndIF

	If lProcEC87
		IF !lTribDifal
			//Verifica se utiliza duas bases
			If aSX6[MV_BASDUPL] .Or. aNFCab[NF_UFDEST] $aSX6[MV_UFBASDP]
				aNfItem[nItem][IT_BASEDES] := (aNfItem[nItem][IT_VALMERC]- Iif( aNFItem[nItem][IT_TS][TS_DESCOND] == "1", 0 , aNfItem[nItem][IT_DESCONTO] )  +aNfItem[nItem][IT_FRETE]+aNfItem[nItem][IT_SEGURO]+aNfItem[nItem][IT_DESPESA]+Iif(aNFItem[nItem][IT_TS][TS_INCIDE] $ "S|F",aNfItem[nItem][IT_VALIPI],0)-aNfItem[nItem][IT_VALICM])/(1-(aNfItem[nItem][IT_ALIQCMP]+aNfItem[nItem][IT_ALFCCMP])/100); //base Destino
												*Iif(Iif(lBicmcpl,Iif(aNFItem[nItem][IT_TS][TS_BICMCMP] == "1",.T.,.F.),aSX6[MV_BICMCMP]) .and. nReduzICMS<>0 .And. nReduzICMS<>100,nReduzICMS/100,1) // Tratamento para aplicar a redução do ICMS quando campo F4_BICMCMP ou parametro MV_BICMCMP estão ativos.
			Else
				aNfItem[nItem][IT_BASEDES] := Iif(Iif(lBicmcpl,Iif(aNFItem[nItem][IT_TS][TS_BICMCMP] == "1",.T.,.F.),aSX6[MV_BICMCMP]) .Or. aNfCab[NF_TIPONF]$"D|B" .Or. aNFItem[nItem][IT_TS][TS_PODER3] =="D",Iif(Iif(lBicmcpl,Iif(aNFItem[nItem][IT_TS][TS_BICMCMP] == "1",.F.,.T.),!aSX6[MV_BICMCMP]) .and. nReduzICMS<>0 .And. nReduzICMS<>100,aNfItem[nItem][IT_BASEICM] * 100 /nReduzICMS,aNfItem[nItem][IT_BASEICM]),aNfItem[nItem][IT_BICMORI])
			EndIf

			If nRedICMSCOM > 0
				aNfItem[nItem][IT_BASEDES] := (aNfItem[nItem][IT_BASEDES]*nRedICMSCOM)/100
				aNfItem[nItem][IT_PREDCMP]	:= nRedICMSCOM
			Endif

			IF aNFCab[NF_UFDEST] $ aSX6[MV_UFALCMP] //Calcula ICMS Complementar pela diferença entre aliquotas.
				nDifal := ( aNfItem[nItem][IT_BASEDES] * (aNfItem[nItem][IT_ALIQCMP] - aNfItem[nItem][IT_ALIQICM] ) )  / 100
			Else
				nDifal := (aNfItem[nItem][IT_BASEDES]*(aNfItem[nItem][IT_ALIQCMP]/100)) - Iif( aNFItem[nItem][IT_TS][TS_COMPRED] $ " 1", Iif( aNfItem[nItem][IT_VICMBRT] > 0 , aNfItem[nItem][IT_VICMBRT] ,aNfItem[nItem][IT_VALICM] ), nVlIcmOri )
			Endif

			If cSimpNac $ "1" .And. aNFCab[NF_OPERNF] == "S" .And. aNfItem[nItem][IT_ALIQCMP] >aNfItem[nItem][IT_ALIQDIF]
				nDifal := (aNfItem[nItem][IT_BASEDES]*((aNfItem[nItem][IT_ALIQCMP] - aNfItem[nItem][IT_ALIQDIF]) /100))
			Endif
		Else
			nDifal := AtuLegDIF(aNfItem,nItem,3)			
		Endif

		If aNfCab[NF_OPERNF] == "S" // campo Difal tera valor a ser pago em outro estado
			aNfItem[nItem][IT_VALCMP] := (Iif(aNfCab[NF_TIPONF]=="D",aNfItem[nItem][IT_PDDES],aNfItem[nItem][IT_PDORI] )* nDifal)/100 //valor do estado de origem
			aNfItem[nItem][IT_DIFAL] := (Iif(aNfCab[NF_TIPONF]=="D",aNfItem[nItem][IT_PDORI],aNfItem[nItem][IT_PDDES] )* nDifal)/100 // valor estado destino
		Else
			aNfItem[nItem][IT_VALCMP] := (Iif(aNfCab[NF_TIPONF]=="D" .Or. (aNfCab[NF_TIPONF]=="B" .And. Iif(Type("cFormul")=="C",cFormul == "S", .F.)),aNfItem[nItem][IT_PDORI],aNfItem[nItem][IT_PDDES] )* nDifal)/100 // valor estado destino
			aNfItem[nItem][IT_DIFAL] := (Iif(aNfCab[NF_TIPONF]=="D" .Or. (aNfCab[NF_TIPONF]=="B" .And. Iif(Type("cFormul")=="C",cFormul == "S", .F.)),aNfItem[nItem][IT_PDDES],aNfItem[nItem][IT_PDORI])* nDifal)/100 //valor do estado de origem
		Endif
	EndIF
Endif

If lReproc
	aNfItem[nItem][IT_VALCMP] := nSvValComp
	aNfItem[nItem][IT_VALANTI] := nSvValAnt
Else
	aNfItem[nItem][IT_DIFAL] := Max(0, aNfItem[nItem][IT_DIFAL])
	IF !lTribCMP
		aNfItem[nItem][IT_VALCMP] := If(aNfCab[NF_OPERNF] == "E" .Or. aNfItem[nItem][IT_DIFAL] > 0 .Or. lDevCompra, Max(0,aNfItem[nItem][IT_VALCMP]),0)
	Endif
	aNfItem[nItem][IT_VALANTI]:= Max(0,aNfItem[nItem][IT_VALANTI])
	MaItArred(nItem,{"IT_VALCMP"})
	MaItArred(nItem,{"IT_DIFAL"},,,.T.)
	MaFisFECP(nItem,,,"BSE|VLR")
EndIf

Return .T.

/*/
MaALIQCMP- Edson Maricate -08.12.1999
Executa o calculo da aliquota do ICMS complementar.
/*/
Function FisAlqDifal(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc)

Local nAliquota	:= aNfItem[nItem][IT_ALIQICM]
Local aMVPPDIFAL 	:= &(aSX6[MV_PPDIFAL])
Local lCalDifal		:= Iif(valType(aMVPPDIFAL) == "A", Len(aMVPPDIFAL) > 0 .And. Year(aNfCab[NF_DTEMISS]) >= aMVPPDIFAL[1][1] .And. aNfItem[nItem][IT_TS][TS_DIFAL] == "1", .F.)

If !(aNFCab[NF_UFORIGEM]$"EX") .And. aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST]

	nAliquota := aNfItem[nItem][IT_PRD][SB_PICM]

	If aNFCab[NF_TIPONF] == "D" .Or. (aNFCab[NF_TIPONF] == "B" .And. aNfCab[NF_OPERNF] == "E" .And. aNFItem[nItem][IT_TS][TS_PODER3]== "D" .And. aSX6[MV_CDIFBEN])   // devolucao ou retorno por beneficiamento conforme alinhamento do chamado TUTZKF
		nAliquota := Iif( nAliquota <> 0 .And. !(lCalDifal .And. aNfCab[NF_OPERNF] == "E" ), nAliquota , FISXALQORI(aNFCab, aSX6, nItem))
		If !Empty(aNFItem[nItem][IT_RECORI])
			If ( aNFCab[NF_CLIFOR] == "C" )
				If aPos[FP_D2_ALIQCMP]
					dbSelectArea("SD2")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					nAliquota := SD2->D2_ALIQCMP
				EndIf
			Else
				If aPos[FP_D1_ALIQCMP]
					dbSelectArea("SD1")
					MsGoto( aNFItem[nItem][IT_RECORI] )
					nAliquota := SD1->D1_ALIQCMP
				Endif
			Endif
		EndIf
	Else 
		//Utiliza aliquota destino para Difal na saída
		nAliquota := Iif( nAliquota <> 0 .And. !(lCalDifal .And. aNfCab[NF_OPERNF] == "S" .And. aNFCab[NF_TPCLIFOR]=="F" ), nAliquota , FISXAlqDest(nItem, aSX6, aNfCab, aNFItem) )

		MaFisFECP(nItem,,,"ALQ")

		If aNfItem[nItem][IT_ALFCCMP] > 0 .And. !lCalDifal
			nAliquota	+=	aNfItem[nItem][IT_ALFCCMP]
		Endif
	EndIf

EndIf

aNfItem[nItem][IT_ALIQCMP]	:= nAliquota

Return

/*/{Protheus.doc} PPDIFAL()
Função que fará validação para preencher a referência NF_PPDIFAL do aNfCAb
@author erick.dias
20/04/2018
/*/
Function FisChkPDif(nItem,aMVPPDIFAL,aNfCab,aNfItem)

Local lRet:= .F.
Local lTribDifal:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_DIFAL)

IF !lTribDifal
	lRet	:= Iif(valType(aMVPPDIFAL)== "A", Len(aMVPPDIFAL)>0 .And. Year(aNfCab[NF_DTEMISS]) >= aMVPPDIFAL[1][1] .And. ;
					aNfItem[nItem][IT_TS][TS_DIFAL]=="1" .And. ;
					aNFCab[NF_UFORIGEM] <> aNFCab[NF_UFDEST] .And. ;
					aNFCab[NF_LINSCR] .And.;
					(Iif(IntTms() .And. nModulo == 43, Iif(aNfCab[NF_TPFRETE] == "F",.T.,.F.),.T.)),.F.)
Else 
	lRet := .T.
Endif


Return lRet

/*/{Protheus.doc} DifConvRf 
	(Função responsavel por converter alteração de referencia legado em referencia do configurador)
	
	@author Erich Buttner
    @since 07/12/2020
    @version 12.1.27

	@param:	
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado	
	ccampo -> Campo que esta sendo alterado	

	/*/
Function DifConvRf(aNfItem, nItem, ccampo, nExecuta)
 Local cCampoConv 	:= ""
 Local cCmpRefBase  := ""
 Local cCmpRefAliq  := ""
 Local cCmpRefVlr	:= ""
 
If nExecuta == 1
    cCmpRefBase := "IT_BASEDES"
	cCmpRefAliq := "IT_ALIQCMP"
	cCmpRefVlr	:= "IT_DIFAL"
Elseif nExecuta == 2
    cCmpRefBase := "IT_BASEDES"
	cCmpRefAliq := "IT_ALIQCMP"
	cCmpRefVlr	:= "IT_VALCMP"
ElseIF nExecuta == 3
    cCmpRefBase := "IT_BASEDES"
	cCmpRefAliq := "IT_ALANTICMS"
	cCmpRefVlr	:= "IT_VALANTI"
Endif

IF cCampo $ cCmpRefVlr
    cCampoConv := "TG_IT_VALOR"		
Elseif cCampo $ cCmpRefBase	
    cCampoConv := "TG_IT_BASE"
ElseIf cCampo $ cCmpRefAliq
	cCampoConv := "TG_IT_ALIQUOTA"					
Endif	

Return cCampoConv

/*/{Protheus.doc} AtuLegDIF
(Função responsavel por preencher as referencia legado com os valores das referencia do configurador)

@author Erich Buttner
@since 08/12/2020
@version 12.1.31

@param:	
aNFItem-> Array com dados item da nota
nItem  -> Item que esta sendo processado
/*/
Static Function AtuLegDIF(aNfItem,nItem,nExecuta)
Local nPosTgDIFAL	:= 0
Local nPosTgCMP		:= 0
Local nPosTgANTI	:= 0
Local nDifal 		:= 0

If  nExecuta = 1 .and. (nPosTgCMP := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_CMP})) >0  

	aNfItem[nItem][IT_VALCMP]:= aNfItem[nItem][IT_TRIBGEN][nPosTgCMP][TG_IT_VALOR]
	aNfItem[nItem][IT_BASEDES]:= aNfItem[nItem][IT_TRIBGEN][nPosTgCMP][TG_IT_BASE]
	aNfItem[nItem][IT_ALIQCMP]:= aNfItem[nItem][IT_TRIBGEN][nPosTgCMP][TG_IT_ALIQUOTA]

Endif

If nExecuta = 2 .and. (nPosTgANTI := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_ANTEC})) >0  

	aNfItem[nItem][IT_VALANTI]:= aNfItem[nItem][IT_TRIBGEN][nPosTgANTI][TG_IT_VALOR]
	aNfItem[nItem][IT_BASEDES]:= aNfItem[nItem][IT_TRIBGEN][nPosTgANTI][TG_IT_BASE]
	aNfItem[nItem][IT_ALANTICMS]:= aNfItem[nItem][IT_TRIBGEN][nPosTgANTI][TG_IT_ALIQUOTA]

Endif

If nExecuta = 3 .and. (nPosTgDIFAL := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_DIFAL})) >0  

	aNfItem[nItem][IT_DIFAL]:= aNfItem[nItem][IT_TRIBGEN][nPosTgDIFAL][TG_IT_VALOR]
	aNfItem[nItem][IT_BASEDES]:= aNfItem[nItem][IT_TRIBGEN][nPosTgDIFAL][TG_IT_BASE]
	aNfItem[nItem][IT_ALIQCMP]:= aNfItem[nItem][IT_TRIBGEN][nPosTgDIFAL][TG_IT_ALIQUOTA]	
	nDifal := aNfItem[nItem][IT_TRIBGEN][nPosTgDIFAL][TG_IT_VALOR]
Endif

Return nDifal
