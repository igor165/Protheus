#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISXISS
    (Componentização da função MaFisISS - 
    Calculo do COFINS - Apuracao / Retencao e ST) 

    MaFisISS -Alexandre Lemes -05/11/2012
    Calculo do ISS   
    
	@author Rafael Oliveira
    @since 11/05/2020
    @version 12.1.27
    
	@param:
	aNfCab      -> Array com dados do cabeçalho da nota
	aNFItem     -> Array com dados item da nota
	nItem       -> Item que esta sendo processado
	aPos        -> Array com dados de FieldPos de campos
	aInfNat	    -> Array com dados da narutureza
	aPE		    -> Array com dados dos pontos de entrada
	aSX6	    -> Array com dados Parametros
	aDic	    -> Array com dados Aliasindic
	aFunc	    -> Array com dados Findfunction        
    cExecuta    -> String vinda da pilha do MATXFIS 
/*/

Function FISXISS(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cExecuta, cMunForISS, cFornCE1, cDescCE1, cLojaCE1, dVencCE1, cRecIssCE1)

Local aIssPrg    := {}
Local cSBCodISS  := aNfItem[nItem][IT_PRD][SB_CODISS]
Local cSBRegrISS := ""
Local cBuffer    := ""
Local cUfPresISS := ""
Local cCodMunISS := ""
Local cCdMunic	 := Iif(Len(Alltrim(SM0->M0_CODMUN))<=5,xFisCodIBGE(SM0->M0_ESTENT),"")+SM0->M0_CODMUN
Local nTotalISS  := 0
Local nItValidos := 0
Local nX         := 0
Local nY         := 0
Local nBseISS    := 0
Local nAliqISS   := 0
Local nAliqTMS   := 0
Local dLei13137	 := CtoD("22/06/2015")
Local lPostVenc := aSX6[MV_ANTVISS] == "2"
Local nDia       := 1
Local nUtil      := 0
Local cMes       := Alltrim(Str(IIf(Month(dDataBase)== 12,1,Month(dDataBase)+1)))
Local cAno       := Alltrim(Str(IIf(Month(dDataBase)== 12,Year(dDataBase)+1,Year(dDataBase))))
Local cDia       := ""
Local aAuxData   := {CTOD("  /  /  "),CTOD("  /  /  "),RetFeriados(),LastDay(Ctod("01/"+cMes+"/"+cAno),2)}
Local lRetISS    := .F.
Local lAchou     := .F.
Local lExcecao   := .F.
Local lTribGen	 := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_ISS)
Local nAliqSN    := 0
Local aAreaSC6   := {}
Local lValidArrd := .F.	

//Abaixo é realizado o tratamento de desconto referente ao ISS
//nas operações de prestação de serviço para órgão público.
//
//Nessa situação, a TES está configurada para NÃO calcular o ISS,
//pois não deve gravar valor de ISS em lugar algum, nem em SD2.
//E o livro está configurado como Isento.
//
//Neste caso, preciso calcular o que seria o ISS, caso houvesse e
//tratá-lo como desconto, no campo IT_DEDICM.

Local lDescISS	 := (aNFItem[nItem][IT_TS][TS_ISS] == "N" .And. aNFItem[nItem][IT_TS][TS_LFISS] == "I" .And. aNfCab[NF_OPIRRF] == "EP"  .And. aNFItem[nItem][IT_TS][TS_AGREG] == "D")

DEFAULT cExecuta := "BSE|ALQ|VLR"

//Define o Codigo ISS.
If ("COD" $ cExecuta)
	aNfItem[nItem][IT_PRD][SB_CODISS] := aNfItem[nItem][IT_CODISS]
	// infelizmente deixei aqui a chamada pois é onde o CODISS é atualizado, infelizmente não há um local centralizado junto com o posicionamento das demais tabelas.
	// vide mais anotações na chamada da mesma função no final do IF da alíquota.
	FISXSEEKCLI(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cMunForISS)
EndIf

//Define Aliquota ISS.
If ("ALQ" $ cExecuta) .Or. (lDescISS)

	If aNfCab[NF_OPERNF] == "E" .And. cSBCodISS <> aNfItem[nItem][IT_CODISS]
		aNfItem[nItem][IT_CODISS]	:= cSBCodISS
	EndIf

	If ( aNfCab[NF_OPERNF] == "S" .And. (lDescISS .Or. aNFItem[nItem][IT_TS][TS_ISS] == "S") ) .Or.;
		(aNfCab[NF_OPERNF] == "E" .And. !Empty(aNfItem[nItem][IT_CODISS]) .And. (aNFItem[nItem][IT_TS][TS_ISS] == "S" .Or. lDescISS ) ) .Or.;
		( !Empty(aNfCab[NF_NATUREZA]) .And. aInfNat[NT_CALCISS] == "S" .And. aNFItem[nItem][IT_TS][TS_ICM] == "N" .And. aNfCab[NF_OPERNF]$aSX6[MV_TPNFISS] .And. aNFItem[nItem][IT_TS][TS_DUPLIC] == "S")

		aNfItem[nItem][IT_CALCISS] := "S"
		//A aliquota sempre sera atualizada conforme atualizacao realizada no item, seguindo o mesmo tratamento realizado para os outros impostos
		nAliqISS := IIf( aNfItem[nItem][IT_PRD][SB_ALIQISS] == 0 , aSX6[MV_ALIQISS] , aNfItem[nItem][IT_PRD][SB_ALIQISS] )

		If IntTms() .And. nModulo == 43 //TMS
			If aPE[PE_TM200ISS]
				nAliqTMS := ExecBlock("TM200ISS",.F.,.F.,{DTC->DTC_SERVIC, DTC->DTC_TIPTRA, DTC->DTC_LOTNFC, DTC->DTC_CLICAL, DTC->DTC_LOJCAL, DTC->DTC_CLIREM, DTC->DTC_LOJREM, DTC->DTC_CLIDES, DTC->DTC_LOJDES})
				If ValType(nAliqTMS) == "N"
					nAliqISS := nAliqTMS
				EndIf
			Else
				DUY->(dbSetOrder(1))
				If aPos[FP_DUY_ALQISS] .And.;
					DUY->(MsSeek(xFilial("DUY")+ Iif(IsInCallStack('TMSA040'), M->DT4_CDRORI, DTC->DTC_CDRCAL) )) .And. ;
					DUY->DUY_ALQISS > 0

					nAliqISS := DUY->DUY_ALQISS
					
				EndIF

			EndIf
		EndIf

		If aNfCab[NF_USAALIQSN]
			If (nAliqSN := MaAliqSimp(aNfCab, aNfItem, nItem)) > 0
				nAliqISS := nAliqSN
			EndIf
		EndIf

		//Define a Aliquota do ISS por Excecao Fiscal.
		If ( !Empty(aNFitem[nItem][IT_EXCECAO]) ) .And. aNfItem[nItem][IT_EXCECAO][7] == "S"			
			
			If aNFItem[nItem][IT_EXCECAO][ Iif(aNFCab[NF_UFORIGEM] == aNFCab[NF_UFDEST] , 1 , 2 ) ] > 0
				nAliqISS := aNfItem[nItem][IT_EXCECAO][Iif(aNFCab[NF_UFORIGEM] == aNFCab[NF_UFDEST] , 1 , 2 ) ]
				lExcecao := .T.
			EndIf

		EndIf
	Else
		aNfItem[nItem][IT_CALCISS] := "N"
	EndIf

	aNfItem[nItem][IT_RATEIOISS]:= aNFItem[nItem][IT_TS][TS_ISS]
	aNfItem[nItem][IT_ALIQISS]  := nAliqISS

	aNfItem[nItem][IT_CNAE]	:= aNfItem[nItem][IT_PRD][SB_CNAE]
	aNfItem[nItem][IT_CFPS]	:= aNFItem[nItem][IT_TS][TS_CFPS]
	aNfItem[nItem][IT_TRIBMU] := aNfItem[nItem][IT_PRD][SB_TRIBMU]

	//Tratamento para Controle de Aliquota atraves da tabela CE1 - Aliquotas do ISS.
	If aSX6[MV_ISSXMUN] .And. aNFItem[nItem][IT_TS][TS_ISS] == "S" .And. ((aNfCab[NF_OPERNF] == "E" .And. !aNFCab[NF_TIPONF] $ "DB") .Or. (aNfCab[NF_OPERNF] == "S")) .And. aDic[AI_CE1]

		cUfPresISS := IIf( aNfItem[1][IT_PRD][SB_MEPLES] == "2" , aNFCab[NF_UFPREISS] , aNFCab[NF_UFORIGEM] )
		cCodMunISS := IIf( aNfItem[1][IT_PRD][SB_MEPLES] == "2" , aNfCab[NF_CODMUN]   , IIf( aNfCab[NF_OPERNF] == "S" , Substr(Alltrim(cCdMunic),3,5) , cMunForISS ) )

		cCodMunISS := IIf( aSX6[MV_EISSXM]=="1" .And. aNfCab[NF_OPERNF] == "E",Substr(Alltrim(cCdMunic),3,5),cCodMunISS )

		cFornCE1   := Space(Len(SA2->A2_COD))
		cLojaCE1   := Space(Len(SA2->A2_LOJA))
		cDescCE1    := CE1->CE1_MUNISS
		dVencCE1   := CTod("")
		cRecIssCE1 := Iif( aNfCab[NF_OPERNF] == "S" .And. !aNFCab[NF_TIPONF] $ "DB" , "1" , aNFCab[NF_RECISS] )

		CE1->(dbSetOrder(1)) //Cod.Prest.Servico sempre segue o Municipio do cadastro da filial sigamat.emp no caso de operacoes de saida.

		If aNfCab[NF_OPERNF] == "S" .And. CE1->(msSeek(xFilial("CE1")+cSBCodISS+SM0->M0_ESTENT+Substr(Alltrim(cCdMunic),3,5)+aNfItem[nItem][IT_PRODUTO]))
			aNfItem[nItem][IT_CODISS]:= CE1->CE1_CPRISS
		ElseIf aNfCab[NF_OPERNF] == "S" .And. CE1->(MsSeek(xFilial("CE1")+aNfItem[nItem][IT_PRD][SB_CODISS]+SM0->M0_ESTENT+Substr(Alltrim(cCdMunic),3,5)))
			aNfItem[nItem][IT_CODISS]:= CE1->CE1_CPRISS
		EndIf

		If aNfCab[NF_OPERNF] == "E" .And. aSX6[MV_EISSXM]<>"1"
			If CE1->(MsSeek(xFilial("CE1")+cSBCodISS+SA2->A2_EST+SA2->A2_COD_MUN+aNfItem[nItem][IT_PRODUTO]))
				lAchou := .T.
			ElseIf CE1->(MsSeek(xFilial("CE1")+cSBCodISS+SA2->A2_EST+SA2->A2_COD_MUN))
				lAchou := .T.
			//ElseIf CE1->(MsSeek(xFilial("CE1")+aNfItem[nItem][IT_PRD][SB_CODISS]+SM0->M0_ESTENT+cCodMunISS+aNfItem[nItem][IT_PRODUTO]))
			//	lAchou := .T.
			Endif

		ElseIf aNfCab[NF_OPERNF] == "E" .And. aSX6[MV_EISSXM]=="1"
			If CE1->(MsSeek(xFilial("CE1")+cSBCodISS+SM0->M0_ESTENT+cCodMunISS+aNfItem[nItem][IT_PRODUTO]))
				lAchou := .T.
			ElseIf CE1->(MsSeek(xFilial("CE1")+cSBCodISS+SM0->M0_ESTENT+cCodMunISS))
				lAchou := .T.
			//ElseIf CE1->(MsSeek(xFilial("CE1")+aNfItem[nItem][IT_PRD][SB_CODISS]+SM0->M0_ESTENT+cCodMunISS+aNfItem[nItem][IT_PRODUTO]))
			//	lAchou := .T.
			Endif
		Else
			If CE1->(MsSeek(xFilial("CE1")+cSBCodISS+cUfPresISS+cCodMunISS+aNfItem[nItem][IT_PRODUTO]))
				lAchou := .T.
			ElseIf CE1->(MsSeek(xFilial("CE1")+cSBCodISS+cUfPresISS+cCodMunISS))
				lAchou := .T.
			//ElseIf CE1->(MsSeek(xFilial("CE1")+aNfItem[nItem][IT_PRD][SB_CODISS]+cUfPresISS+cCodMunISS+" "))
			//	lAchou := .T.
			Endif
		EndIf

		If lAchou
			//ALTERACAO DO MUNICIPIO
			If aNfCab[NF_OPERNF] == "E"
				aNfItem[nItem][IT_CODISS]:= CE1->CE1_CTOISS
			EndIf

			aNfItem[nItem][IT_ALIQISS]:= IIf(!Empty(CE1->CE1_ALQISS) .And. !lExcecao,CE1->CE1_ALQISS,nAliqISS)

			//Grava campo Cnae e Tribmun SFT
			If aPos[FP_CE1_TRIBMU]
				aNfItem[nItem][IT_TRIBMU] := PadR(CE1->CE1_TRIBMU, GTamMxFis( TAM_CE1_TRIBMU ))
			EndIf

			If aPos[FP_CE1_CNAE]
				aNfItem[nItem][IT_CNAE] := CE1->CE1_CNAE
			EndIf

			If CE1->CE1_RETISS == "1"  //Retem ISS 1=SIM / 2=NAO

				If	aSX6[MV_EISSXM] =="1" .And. aPos[FP_CE1_RMUISE]
					If aNfCab[NF_OPERNF] == "S" .And. aNFCab[NF_RECISS] $ "S|1|" .And.;
						((CE1->CE1_RMUISS == "1" .And. Substr(Alltrim(cCdMunic),3,5) == cMunForISS ) .Or.;
						(CE1->CE1_RMUISS == "2" .And. Substr(Alltrim(cCdMunic),3,5) <> cMunForISS ) .Or.;
						(CE1->CE1_RMUISS == "3" ))

						lRetISS := .T.
					ElseIf aNfCab[NF_OPERNF] == "E" .And. aNFCab[NF_RECISS] $ "N|2| " .And.;
						((CE1->CE1_RMUISE == "1" .And. Substr(Alltrim(cCdMunic),3,5) == cMunForISS ) .Or.;
						(CE1->CE1_RMUISE == "2" .And. Substr(Alltrim(cCdMunic),3,5) <> cMunForISS ) .Or.;
						(CE1->CE1_RMUISE == "3" ))

						lRetISS := .T.
					Else
						cRecIssCE1 := '1' // nao gera titulo de ISS
					EndIF
				ElseIf ((CE1->CE1_RMUISS == "1" .And. Substr(Alltrim(cCdMunic),3,5) == cMunForISS ) .Or.; //cMunForIss e o Municipio Or\iginal do Fornecedor
						  (CE1->CE1_RMUISS == "2" .And. Substr(Alltrim(cCdMunic),3,5) <> cMunForISS ) .Or.;
						  (CE1->CE1_RMUISS == "3" )) .And. !(aNFCab[NF_RECISS] $ "S|1|" .And. aNfCab[NF_OPERNF] == "E") 

					lRetISS := .T.
				EndIf

				If lRetISS
					cFornCE1    := CE1->CE1_FORISS
					cLojaCE1    := CE1->CE1_LOJISS
					cDescCE1    := CE1->CE1_MUNISS

					If cPaisLoc == "BRA"
						dbSelectArea("CC2")
						CC2->(dbSetOrder(1))
						CC2->(dbSeek(xFilial("CC2")+CE1->CE1_ESTISS+CE1->CE1_CMUISS))
						If aPos[FP_CC2_TPDIA] .and. CC2->CC2_TPDIA == "2" .And. CC2->CC2_DTRECO <> 0
							If cMes == "2" .And. CC2->CC2_DTRECO > Day(LastDay(Ctod("01"+"/"+"2"+"/"+cAno)))
								cDia 		:= Alltrim(Str(Day(LastDay(Ctod("01"+"/"+"2"+"/"+cAno)))))
								dVencCE1	:= DataValida(Ctod(cDia+"/"+cMes+"/"+cAno), lPostVenc)
							Else
								cDia 		:= Alltrim(Str(CC2->CC2_DTRECO))
								dVencCE1	:= DataValida(Ctod(cDia+"/"+cMes+"/"+cAno), lPostVenc)
							EndIf
						Else
							While nUtil < CC2->CC2_DTRECO .And. nDia <= Day(aAuxData[4])
								aAuxData[1]:=CTOD((Str(nDia))+"/"+cMes+"/"+cAno)
								If LastDay(aAuxData[1],3) == aAuxData[1] .And. ;
									Ascan(aAuxData[3],Dtos(aAuxData[1])) == 0
									aAuxData[2] := aAuxData[1]
									nUtil++
								EndIf
								nDia++
							EndDo
							dVencCE1    := IIF(nUtil < CC2->CC2_DTRECO,LastDay(aAuxData[2],2),aAuxData[2])
						Endif
					Endif

						cRecIssCE1  := "2"
				EndIf

				dVencISS := dVencCE1
				cFornISS := cFornCE1
				cLojaISS := cLojaCE1

			Endif

			aNFCab[NF_RECISS] := Iif( aNfCab[NF_OPERNF] == "S" .And. !aNFCab[NF_TIPONF] $ "DB" , aNFCab[NF_RECISS] , cRecISSCE1 )
		Else
			If !lExcecao .And. (aNfItem[nItem][IT_ALIQISS] <= 0 .OR. aNfItem[nItem][IT_ALIQISS] == aSX6[MV_ALIQISS])
				nAliqISS := IIf( aNfItem[nItem][IT_PRD][SB_ALIQISS] == 0 , aSX6[MV_ALIQISS] , aNfItem[nItem][IT_PRD][SB_ALIQISS] )
				aNfItem[nItem][IT_ALIQISS]:= nAliqISS
			EndIf
		EndIf
	EndIf
	// Chamando o posicionamento da CLI pois infelizmente o CODISS é atualizado na função de cálculo do ISS :/
	// Poderia estar na função que carrega o produto se não fosse a CE1
	// Retirar daqui quando reescrever o ISS :D
	FISXSEEKCLI(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cMunForISS)

EndIf

//Define a Base do ISS.
If ("BSE" $ cExecuta) .Or. (lDescISS)

	aNfItem[nItem][IT_BASEISS]:= 0

	If (aNfItem[nItem][IT_CALCISS] == "S" .Or. lDescISS ) .And. (aNfCab[NF_OPERNF] == "E" .Or. ;
		((aNfCab[NF_RECISS] == "1" .And. aNfCab[NF_OPERNF] == "S" .And. aSX6[MV_DESCISS] ) .Or. (aNfCab[NF_RECISS] <> "1" .And. aNfCab[NF_OPERNF] == "S") ) )

		//-- Se descontos incondicionais subtraidos antes de aplicar % de reducao da base
		nBseISS := (aNfItem[nItem][IT_VALMERC] + aNfItem[nItem][IT_ACRESCI]) - IIf( aNFItem[nItem][IT_TS][TS_DESCOND] == "2" .And. (!aPos[FP_F4_DESCISS] .Or. aNFItem[nItem][IT_TS][TS_DESCISS] <> "2") , (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]) , 0 ) //Caso o desconto INCONDICIONAL aNFItem[nItem][IT_TS][TS_DESCOND] == "2" abater o desconto da base de ISS.

		If aNFItem[nItem][IT_TS][TS_BASEISS] > 0 // Reducao padrao da base do ISS ( TES )
			nBseISS := ( nBseISS * aNFItem[nItem][IT_TS][TS_BASEISS] ) / 100
			aNfItem[nItem][IT_PREDISS] := aNFItem[nItem][IT_TS][TS_BASEISS]
		EndIf

		If aNfItem[nItem,IT_REDISS] > 0 // Reducao opcional da base do ISS ( TES )
			nBseISS := ( nBseISS * aNfItem[nItem,IT_REDISS] ) / 100
			aNfItem[nItem][IT_PREDISS] := aNfItem[nItem,IT_REDISS]
		EndIf

		//-- Se descontos incondicionais subtraidos apos de aplicar % de reducao da base
		nBseISS := nBseISS - IIf( aNFItem[nItem][IT_TS][TS_DESCOND] == "2" .And. (aPos[FP_F4_DESCISS] .And. aNFItem[nItem][IT_TS][TS_DESCISS] == "2") , (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]) , 0 ) //Caso o desconto INCONDICIONAL aNFItem[nItem][IT_TS][TS_DESCOND] == "2" abater o desconto da base de ISS.

		If aNFItem[nItem][IT_TS][TS_AGRISS] == "1"
			nBseISS := nBseISS/(1-(aNfItem[nItem][IT_ALIQISS]/100))
		Endif

		//Tratamento de Controle de Deducoes atraves do cadastro CC2 - Municipios.
		If cPaisLoc == "BRA" .And. aSX6[MV_ISSXMUN] .And. aPos[FP_CC2_PERMAT] .And. aPos[FP_CC2_PERSER] .And. aPos[FP_CC2_MDEDMA] .And. aPos[FP_CC2_MDEDSR]
			If aNFItem[nItem][IT_TS][TS_ISS] == "S" .And. ( (aNfCab[NF_OPERNF] == "E" .And. !aNFCab[NF_TIPONF] $ "DB") .Or. (aNfCab[NF_OPERNF] == "S" .And. aNFCab[NF_TIPONF] $ "DB") )
				//Muncio Arbitra o Valor da Deducao 1=SIM e 2=NAO e foi Informado o percentual a Arbitrar.
				CC2->(dbSetOrder(1))
				If CC2->(MsSeek(xFilial("CC2") + aNFCab[NF_UFORIGEM] + aNfCab[NF_CODMUN]))
					If CC2->CC2_PERMAT > 0 //Municipio Arbitra Deducoes de Materiais.
						aNfItem[nItem,IT_ABMATISS]	:=	nBseISS * (CC2->CC2_PERMAT/100)
					EndIf
					If CC2->CC2_PERSER > 0  //Municipio Arbitra Deducoes de Servicos.
						aNfItem[nItem,IT_ABVLISS]	:=  nBseISS * (CC2->CC2_PERSER/100)
					EndIf
					If CC2->CC2_MDEDMA == "2"
						aNfItem[nItem,IT_ABMATISS]	:= 0
					EndIf
					If CC2->CC2_MDEDSR == "2"
						aNfItem[nItem,IT_ABVLISS]	:= 0
					EndIf
				EndIf
			EndIf
		EndIf

		nBseISS -= aNfItem[nItem,IT_ABVLISS]
		nBseISS -= aNfItem[nItem,IT_ABMATISS]

		//Alteracao da base de calculo do ISS para o municipio conforme campo Base ISS, conforme Lei Complementar 185 de 25 de julho de 2007 (Barueri).
		If aPos[FP_CC2_BASISS]
			//-- Verificar campo Exe.Servico (B1_MEPLES), 1=EP ou 2=LES
			cUfPresISS := IIf( aNfItem[1][IT_PRD][SB_MEPLES] == "2" , aNFCab[NF_UFPREISS] , aNFCab[NF_UFORIGEM] )
			cCodMunISS := IIf( aNfItem[1][IT_PRD][SB_MEPLES] == "2" , aNfCab[NF_CODMUN]   , IIf( aNfCab[NF_OPERNF] == "S" , Substr(Alltrim(cCdMunic),3,5) , cMunForISS ) )
			//-- Verificar campo Ded.Base ISS (CC2_BASISS), 1=Sim ou 2=Nao
			CC2->(dbSetOrder(1)) //CC2_FILIAL+CC2_EST+CC2_MUN
			If CC2->(MsSeek(xFilial("CC2") + cUfPresISS + cCodMunISS) .And. CC2_BASISS == "1")
				//-- Somente se acima do valor informado no parametro MV_VL10925.
				nBseISS := nBseISS - aNfItem[nItem][IT_VALIRR]
				If dDataBase >= dLei13137 .Or. aNfItem[nItem][IT_VALMERC] >= aSX6[MV_VL10925]
					nBseISS := nBseISS - aNfItem[nItem][IT_VALPIS] - aNfItem[nItem][IT_VALCOF] - aNfItem[nItem][IT_VALCSL]
				EndIf
			EndIf
		//Removi else if do aPos[FP_CC2_BASISS] pois este campo já existe faz muito tempo
		EndIf

		//Eeftua o Gross Up do Imposto de renda na base de cálculo do ISS
		IF xFisGrossIR(nItem, aNFItem, aNfCab,"ISS") //Verifica se deverá considerar GrossUp do IRRF na base do ISS
			nBseISS	:= nBseISS / ( 1 - ( aNfItem[nItem][IT_ALIQIRR] / 100 ) )
			// nesse momento a única opção do campo A2_GROSSIR que aplica o IR GrossUp na BC do ISS
			// é a opção 3. Conforme solicitação na ISSUE DSERFISE-2461 o ISS também deve ter seu valor embutido em sua BC
			nBseISS := nBseISS / ( 1 - ( aNfItem[nItem][IT_ALIQISS] / 100 ) )
		EndIF
		aNfItem[nItem][IT_BASEISS] := nBseISS

	EndIf

EndIf

//Define o Valor do ISS.
If ("VLR" $ cExecuta) .Or. (lDescISS)

	aNfItem[nItem][IT_VALISS] := 0

	If aNfItem[nItem][IT_CALCISS] == "S" .Or. lDescISS

		aNfItem[nItem][IT_VALISS] := aNfItem[nItem][IT_BASEISS] * aNfItem[nItem][IT_ALIQISS] / 100

		If aNFItem[nItem][IT_TS][TS_AGREG] == "D" .Or. aNFItem[nItem][IT_TS][TS_AGREG] == "R"
			If lDescISS
				aNfItem[nItem][IT_DEDICM] := aNfItem[nItem][IT_VALISS]
			Else
				If aNFItem[nItem][IT_TS][TS_BASEISS] > 0
					If aSX6[MV_DBRDIF]
						aNfItem[nItem][IT_DEDICM] := Round(aNfItem[nItem][IT_BICMORI] * aNfItem[nItem][IT_ALIQISS] / 100 * (1-(aNFItem[nItem][IT_TS][TS_BASEISS]/100)),2)
					Else
						aNfItem[nItem][IT_DEDICM] := Round(aNfItem[nItem][IT_BICMORI] * aNfItem[nItem][IT_ALIQISS] / 100 * (aNFItem[nItem][IT_TS][TS_BASEISS]/100),2)
					EndIf
				Else
					aNfItem[nItem][IT_DEDICM] := aNfItem [nItem][IT_BICMORI] - Round(aNfItem[nItem][IT_BICMORI] * (1-(aNfItem[nItem][IT_ALIQISS]/100*IIf(aNFItem[nItem][IT_TS][TS_BASEISS]==0,1,aNFItem[nItem][IT_TS][TS_BASEISS]/100))),2)
				EndIf
			EndIf
		EndIf

		If aNFCab[NF_TIPONF] $ "DB"
			If !Empty(aNFItem[nItem][IT_RECORI])
				
				If ( aNFCab[NF_CLIFOR] == "C")
					SD2->(MsGoto(aNFItem[nItem][IT_RECORI]))
					If (SD2->D2_VALISS > 0 .Or. Abs(aNfItem[nItem][IT_VALISS]-SD2->D2_VALISS)<=1) .And. aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT .And. SD2->D2_VALFRE + SD2->D2_SEGURO + SD2->D2_DESPESA == 0
						aNfItem[nItem][IT_VALISS] := SD2->D2_VALISS
						aNfItem[nItem][IT_DEDICM] := IIf(cPaisLoc == "BRA" .And. (aNFItem[nItem][IT_TS][TS_AGREG] == "D" .Or. aNFItem[nItem][IT_TS][TS_AGREG] == "R") , SD2->D2_DESCICM , 0 )
					EndIf
				Else
					SD1->(MsGoto(aNFItem[nItem][IT_RECORI]))
					If (SD1->D1_VALISS > 0 .Or. Abs(aNfItem[nItem][IT_VALISS]-SD1->D1_VALISS)<=1) .And. aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT .And. SD1->D1_VALFRE + SD1->D1_SEGURO + SD1->D1_DESPESA == 0
						aNfItem[nItem][IT_VALISS] := SD1->D1_VALISS
						aNfItem[nItem][IT_DEDICM] := IIf(aNFItem[nItem][IT_TS][TS_AGREG] == "D" .Or. aNFItem[nItem][IT_TS][TS_AGREG] == "R" , SD1->D1_DESCICM , 0 )
					EndIf
				EndIf
			EndIf
		Else
			lValidArrd := (aNfItem[nItem][IT_VALISS] > 0 .And. aNfItem[nItem][IT_VALISS] < 0.01)
			MaItArred(nItem, {"IT_VALISS"}, , lValidArrd)
		EndIf
	EndIf
	//Abaixo é realizado o tratamento de desconto referente ao ISS
	//nas operações de prestação de serviço para órgão público.
	//Acima já utilizei o que seria o ISS como um desconto, no IT_DEDICM
	//portanto abaixo, volto a zerar o ISS, pois não há ISS no documento
	If lDescISS
		aNfItem[nItem][IT_VALISS] 	:= 0
		aNfItem[nItem][IT_ALIQISS]	:= 0
		aNfItem[nItem][IT_BASEISS]	:= 0
	EndIf

EndIf

//Verifico se tenho o cálculo do ISS pelo configurador, caso tenha será substituído o valor das referências legado
If lTribGen
	AtuLegISS(aNfItem, nItem)
EndIf

Return

/*±±³Funcao MaSeekCLI ³ Autor ³   Caio Martins     Data  ³19/10/2018³ ±±
±±³Descri‡…o ³A funcao efetua o calculo do ISS BI Tributado (Cepom) ³±±*/

Function FISXSEEKCLI(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cMunForISS)
Local lBiTrib := .F.
Local cMunSM0 := Iif(Len(Alltrim(SM0->M0_CODMUN))==5, Alltrim(SM0->M0_CODMUN), Substr(Alltrim(SM0->M0_CODMUN),3,5) )

aNfItem[nItem][IT_ISSCPM] := .F.

If cPaisLoc == "BRA" .And. aDic[AI_CLI] .And. !(aNFCab[NF_TIPONF]$"DB")

	CLI->(dbSetOrder(1))

	IF aNfCab[NF_OPERNF] == "E"
		IF CLI->(MsSeek(xFilial("CLI")+"1"+aNfItem[nItem][IT_CODISS]+SM0->M0_ESTENT+cMunSM0+aNfCab[NF_CODCLIFOR]+aNfCab[NF_LOJA])) .AND. !(cMunSM0 $ cMunForISS)
			aNfItem[nItem][IT_ISSCPM] := .T.
		EndIF
	Else
		IF CLI->(MsSeek(xFilial("CLI")+"2"+aNfItem[nItem][IT_CODISS]+aNFCab[NF_UFDEST]+cMunForISS)) .AND. !(cMunSM0 $ cMunForISS)
			aNfItem[nItem][IT_ISSCPM] := .T.
		EndIf
	EndIf
EndIf

Return

/*±±³Funcao    FISXISSBI ³ Autor ³ Caio Martins Data  ³19/10/2018³ ±±
±±³Descri‡…o ³A funcao efetua o calculo do ISS BI Tributado (Cepom) ³±±*/

Function FISXISSBI(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cExecuta, cMunForISS)
Local cMunSM0	:= Iif(Len(Alltrim(SM0->M0_CODMUN))==5, Alltrim(SM0->M0_CODMUN), Substr(Alltrim(SM0->M0_CODMUN),3,5) )
Local cUFBusca	:= ""
Local cMunBusca	:= ""
Local cFunName  := AllTrim(FunName())
Local lSeekCE1	:= .F.
Local lVldCpo   := .F.
Local lVldMun   := .F.
Local lTribGen 	:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_ISSBI)
Local nPosTgISSB:= 0

DEFAULT cExecuta  := "BSE|ALQ|VLR"

If !lTribGen
	// VERIFICA SE A ROTINA E A DO PEDIDO DE VENDA E SE O PRODUTO ESTA CONFIGURADO COMO LES
	IF (cFunName $ "MATA410|OFIXA018|OFIXA011|OFIXA100"); 
		.AND. aNfItem[nItem][IT_PRD][SB_MEPLES] == "2"
		lVldCpo	:=  ( EMPTY(M->C5_ESTPRES) .OR. EMPTY(M->C5_MUNPRES) ) .Or. ( ALLTRIM(M->C5_MUNPRES) == ALLTRIM(cMunForISS) )	
	EndIF

	CE1->(dbSetOrder(1))

	If aNfItem[nItem][IT_ISSCPM] .And. aNfItem[nItem][IT_VALISS] > 0
		If ("ALQ" $ cExecuta)
			IF aNfCab[NF_OPERNF] == "E"
				cUFBusca := SM0->M0_ESTENT
				cMunBusca := cMunSM0
			ElseIf aNfItem[nItem][IT_PRD][SB_MEPLES] == "2"
				If CE1->(msSeek(xFilial("CE1")+aNfItem[nItem][IT_CODISS]+aNFCab[NF_UFPREISS]+aNFCab[NF_CODMUN]+aNfItem[nItem][IT_PRODUTO])) .OR. CE1->(msSeek(xFilial("CE1")+aNfItem[nItem][IT_CODISS]+aNFCab[NF_UFPREISS]+aNFCab[NF_CODMUN]))
					cUFBusca := aNFCab[NF_UFDEST]
					cMunBusca := cMunForISS
				Else
					cUFBusca := aNFCab[NF_UFPREISS]
					cMunBusca := aNfCab[NF_CODMUN]
				EndIF
			Else
				cUFBusca := aNFCab[NF_UFDEST]
				cMunBusca := cMunForISS
			EndIf

			IF !lVldCpo
			// Abaixo 2 Seeks na CE1 porque o produto não é obrigatório
				If CE1->(msSeek(xFilial("CE1")+aNfItem[nItem][IT_CODISS]+cUFBusca+cMunBusca+aNfItem[nItem][IT_PRODUTO]))
					lSeekCE1 := .T.
				ElseIf CE1->(msSeek(xFilial("CE1")+aNfItem[nItem][IT_CODISS]+cUFBusca+cMunBusca))
					lSeekCE1 := .T.
				EndIf

				If lSeekCE1
					aNfItem[nItem][IT_ALQCPM]:= CE1->CE1_ALQISS
				EndIf
			EndIF
		EndIf

		If ("BSE" $ cExecuta)
			aNfItem[nItem][IT_BASECPM] := aNfItem[nItem][IT_BASEISS]
		EndIf

		If ("VLR" $ cExecuta)
			If aNfItem[nItem][IT_ALQCPM] > 0
				aNfItem[nItem][IT_VALCPM] := aNfItem[nItem][IT_BASECPM] * (aNfItem[nItem][IT_ALQCPM]/100)
			EndIf
			If aNfItem[nItem][IT_VALCPM] <=0
				aNfItem[nItem][IT_VALCPM] := 0
				aNfItem[nItem][IT_BASECPM] := 0
			EndIf
		EndIf

	EndIf
Else
	If (nPosTgISSB := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_ISSBI})) >0  
		aNfItem[nItem][IT_VALCPM]:= aNfItem[nItem][IT_TRIBGEN][nPosTgISSB][TG_IT_VALOR]
		aNfItem[nItem][IT_BASECPM]:= aNfItem[nItem][IT_TRIBGEN][nPosTgISSB][TG_IT_BASE]
		aNfItem[nItem][IT_ALQCPM]:= aNfItem[nItem][IT_TRIBGEN][nPosTgISSB][TG_IT_ALIQUOTA]
	Endif
EndIf

Return

/*/{Protheus.doc} MaAliqSimp()
@description Função responsável por retornar a alíquota do ICMS ou ISS
calculada pela apuração do SIMPLES NACIONAL.
@author joao.pellegrini
/*/
Static Function MaAliqSimp(aNfCab, aNfItem, nItem)
Local nPosAlq := 0

If !Empty(AllTrim(aNfItem[nItem][IT_PRD][SB_B1GRUPO]))
	nPosAlq := aScan(aNfCab[NF_ALIQSN], {|x| AllTrim(x[SN_GRUPO]) == AllTrim(aNfItem[nItem][IT_PRD][SB_B1GRUPO])})
ElseIf !Empty(AllTrim(aNfItem[nItem][IT_CODISS]))
	nPosAlq := aScan(aNfCab[NF_ALIQSN], {|x| AllTrim(x[SN_CODISS]) == AllTrim(aNfItem[nItem][IT_CODISS])})
EndIf

Return Iif(nPosAlq > 0, aNfCab[NF_ALIQSN][nPosAlq][SN_ALIQ], 0 )

/*/{Protheus.doc} ISSConvRf
(Função responsavel por converter alteração de referencia legado em referencia do configurador)

@author Renato Rezende
@since 10/12/2020
@version 12.1.31

@param:	
aNFItem-> Array com dados item da nota
nItem  -> Item que esta sendo processado
ccampo -> Campo que esta sendo alterado	
nExecuta -> Referência que está sendo verificada
/*/
Function ISSConvRf(aNfItem,nItem,ccampo, nExecuta)
Local cCampoConv 	:= ""
Local cCtrRefBas	:= ""
Local cCtrRefVal	:= ""
Local cCtrRefAlq	:= ""

If nExecuta == 1
	cCtrRefBas	:= "IT_BASEISS"
	cCtrRefVal	:= "IT_VALISS"
	cCtrRefAlq	:= "IT_ALIQISS"
ElseIf nExecuta == 2
	cCtrRefBas	:= "IT_BASECPM"
	cCtrRefVal	:= "IT_VALCPM"
	cCtrRefAlq	:= "IT_ALQCPM"
ElseIf nExecuta == 3
	cCtrRefVal	:= "IT_DEDICM"
EndIf

IF cCampo $ cCtrRefVal
    cCampoConv := "TG_IT_VALOR"
Elseif cCampo $ cCtrRefBas
    cCampoConv := "TG_IT_BASE"
Elseif cCampo $ cCtrRefAlq
    cCampoConv := "TG_IT_ALIQUOTA"
Endif

Return cCampoConv

/*/{Protheus.doc} AtuLegISS
(Função responsavel por preencher as referencia legado com os valores das referencia do configurador)

@author Renato Rezende
@since 10/12/2020
@version 12.1.31

@param:	
aNFItem-> Array com dados item da nota
nItem  -> Item que esta sendo processado
/*/
Static Function AtuLegISS(aNfItem,nItem)
Local nPosTgISS:= 0
Local nPosTgDed:= 0

If (nPosTgISS := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_ISS})) >0  

	aNfItem[nItem][IT_CALCISS]:= "S"
	aNFItem[nItem][IT_TS][TS_ISS]:= "S"
	aNfItem[nItem][IT_VALISS]:= aNfItem[nItem][IT_TRIBGEN][nPosTgISS][TG_IT_VALOR]
	aNfItem[nItem][IT_BASEISS]:= aNfItem[nItem][IT_TRIBGEN][nPosTgISS][TG_IT_BASE]
	aNfItem[nItem][IT_ALIQISS]:= aNfItem[nItem][IT_TRIBGEN][nPosTgISS][TG_IT_ALIQUOTA]
	aNFItem[nItem][IT_TS][TS_LFISS] := RetLFLeg(aNfItem,nItem,nPosTgISS,TS_LFISS)
	
	If aNfItem[nItem][IT_TRIBGEN][nPosTgISS][TG_IT_LF][TG_LF_PERC_REDUCAO] > 0
		aNfItem[nItem][IT_PREDISS]:= 100-aNfItem[nItem][IT_TRIBGEN][nPosTgISS][TG_IT_LF][TG_LF_PERC_REDUCAO]
	EndIf
	
	aNFItem[nItem][IT_TS][TS_CSTISS] := aNfItem[nItem][IT_TRIBGEN][nPosTgISS][TG_IT_REGRA_ESCR][RE_CST]

Endif

If (nPosTgDed := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_DEDUCAO})) >0  

	aNfItem[nItem][IT_DEDICM]:= aNfItem[nItem][IT_TRIBGEN][nPosTgDed][TG_IT_VALOR]
Endif

Return 
