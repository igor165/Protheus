#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISXCPRB
    Componentização da função MaFisCPRB
    Contribuição Previdenciária Incidente sobre a Receita Bruta (CPRB)
        
	@author Rafael Oliveira
    @since 06/04/2020
    @version 12.1.27
    
    @Autor da unção original 
	@author Mauro A. Gonçalves
	@history Vogas Júnior, 07/06/2018, (DSERFIS1-6133) alterada forma de obtensão da Base de cálculo CPRB.

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
*/

Function FISXCPRB(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc)

Local nAlq 			:= 0
Local nBaseCPRB		:= 0
Local lAgreg		:= .F.
Local lIntTms		:= IntTms()
Local lTribGen 		:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_CPRB)
Local nPosTgCPRB 	:= 0
Local lRecalCPRB    := .T.

If !lTribGen
	If aSX6[MV_CPRBNF] .And. aNFItem[nItem][IT_TS][TS_CALCCPB]=="1"
		If aNFCab[NF_TIPONF] == "D" .And. !Empty(aNFItem[nItem][IT_RECORI]) // devolucao
			If aNFCab[NF_CLIFOR] == "C"
				SD2->(MsGoto(aNFItem[nItem][IT_RECORI]) )
				If aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT
					aNfItem[nItem][IT_ALIQCPB] := SD2->D2_ALIQCPB
					aNfItem[nItem][IT_BASECPB] := SD2->D2_BASECPB
					aNfItem[nItem][IT_VALCPB]  := SD2->D2_VALCPB
					lRecalCPRB := .F.
				ElseIf aNfItem[nItem][IT_QUANT] <> SD2->D2_QUANT .And. aNFItem[nItem][IT_TS][TS_DEVPARC]$"1S"
					aNfItem[nItem][IT_ALIQCPB] := SD2->D2_ALIQCPB
					aNfItem[nItem][IT_BASECPB] := (aNfItem[nItem][IT_QUANT] * SD2->D2_BASECPB)/SD2->D2_QUANT
					aNfItem[nItem][IT_VALCPB]  := (aNfItem[nItem][IT_QUANT] * SD2->D2_VALCPB)/SD2->D2_QUANT
					lRecalCPRB := .F.
				EndIf
			EndIf
		Else
			nAlq := aNfItem[nItem][IT_PRD][SB_CG1_ALIQ]
		Endif
		If nAlq > 0 .And. lRecalCPRB
			If !aNFItem[nItem][IT_TS][TS_PISCRED] $ "5" .AND. !aNfItem[nItem][IT_TIPONF]$"I|P"

				nBaseCPRB := aNfItem[nItem][IT_VALMERC]-IIf(aNFItem[nItem][IT_TS][TS_AGREG]$"DR",aNfItem[nItem][IT_DEDICM],0)

				//Tratamento do Agrega Valor - PIS / COF / ICMS
				nAliqAgr := 0

				If aNFItem[nItem][IT_TS][TS_AGREG]=="I"
					If aNFItem[nItem][IT_TS][TS_ICM] == "N"
					nAliqAgr += aNfItem[nItem][IT_ALIQSOL]
						lAgreg	 := .T.
					Else
						If aNfCab[NF_PPDIFAL]
							nAliqAgr += aNfItem[nItem][IT_ALIQCMP]+aNfItem[nItem][IT_ALFCCMP]
						Else
							nAliqAgr += aNfItem[nItem][IT_ALIQICM]
						Endif
						lAgreg	 := .T.
					EndIf
				EndIf

				If aNFItem[nItem][IT_TS][TS_AGRPIS]=="P"
					nAliqAgr += aNfItem[nItem][IT_ALIQPS2]
					lAgreg	 := .T.
					If aNFItem[nItem][IT_TS][TS_AGRCOF]=="C"
						nAliqAgr += aNfItem[nItem][IT_ALIQCF2]
					Endif
				Endif

				If lAgreg

					If aSX6[MV_RNDICM]
						nBaseCPRB := Round(nBaseCPRB / ( 1 - (nAliqAgr/100)) , 2 )
					Else
						nBaseCPRB := nBaseCPRB / ( 1 - (nAliqAgr/100))
					EndIf

				Endif

				If aNFItem[nItem][IT_TS][TS_AGREG] == "I" .And. !lAgreg
					nBaseCPRB += If(aNFitem[nItem][IT_TIPONF ]<>"I",aNfItem[nItem][IT_VALICM],0)
				EndIf

				If !(aNFItem[nItem][IT_TS][TS_AGREG]=="I" .AND. lAgreg .AND. aSX6[MV_DBSTPIS]$"1|6" .AND. lIntTms) //Tratamento para não duplicar o valor do icms na base de pis
					nBaseCPRB := ( nBaseCPRB - IIf( aNFItem[nItem][IT_TS][TS_PISBRUT] == "1" , 0 , (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]+aNfItem[nItem][IT_DS43080]) ) + aNfItem[nItem][IT_DESCZFCOF] + aNfItem[nItem][IT_DESCZFPIS] + IIf(aNfItem[nItem][IT_DESCZFPIS]<>0,0,IIF(aNFItem[nItem][IT_TS][TS_CRPRST]<>0 .And. lIntTms,aNfItem[nitem][IT_VLCSOL],aNfItem[nitem][IT_VALSOL])) )
				EndIf

				If ( !(aNfCab[NF_CLIFOR]=="C" .And. aNfCab[NF_CALCSUF]$"SI" .And. !aNFitem[nItem][IT_TIPONF ]$"BD" .And. ;
					aNFItem[nItem][IT_TS][TS_ISS] <> "S" .And. aSX6[MV_DESCZF] .And. aSX6[MV_DESZFPC] ) .And. aSX6[MV_FRTBASE] ) .Or. aSX6[MV_FRTBASE]
					nBaseCPRB += IIf(aNFItem[nItem][IT_TS][TS_DESPPIS] <> "2",aNfItem[nItem][IT_DESPESA],0) + IIF(aNFItem[nItem][IT_TS][TS_DESPPIS] <> "2",aNfItem[nItem][IT_SEGURO],0) + IIF(aNFItem[nItem][IT_TS][TS_DESPPIS] <> "2",aNfItem[nItem][IT_FRETE],0)
				EndIf

				If aNFItem[nItem][IT_TS][TS_CREDIPI] == "N" .AND. aSX6[MV_DEDBCPR]$"S,P" .AND. aNFItem[nItem][IT_TS][TS_IPI]<>"R"
					nBaseCPRB += aNfItem[nItem][IT_VALIPI]
				EndIf

				If aNFCab[NF_DEDBSPC] $ " 1"

					if aSX6[MV_DESCZF] .and. aSX6[MV_DEDBCPR] == "D"
						if (aNfItem[nItem][IT_DESCZF])>0
							nBaseCPRB -= aNfItem[nItem][IT_VALICM]
							nBaseCPRB -= aNfItem[nItem][IT_DESCZF]

						endif
					else
					
						If aSX6[MV_DEDBCPR]$"S,I"
							nBaseCPRB -= aNfItem[nItem][IT_VALICM]
						EndIf

						// Caso seja comerciante atacadista, o valor do IPI deve ser retirado da base de calculo do PIS pois esta embutido no valor da mercadoria
						If aNFItem[nItem][IT_TS][TS_CREDIPI] == "S" .And. aSX6[MV_DEDBCPR]$"S,P" .And. aNFItem[nItem][IT_TS][TS_IPI] == "R"
							nBaseCPRB -= aNfItem[nItem][IT_VALIPI]
						EndIf

					endif

				EndIf

				//Exclui valor do Difal (EC/15) da base de cálculo de PIS
				IF aNfItem[nItem][IT_TS][TS_DIFALPC] == '1'
					nBaseCPRB -= (aNfItem[nItem][IT_DIFAL]+aNfItem[nItem][IT_VALCMP]+aNfItem[nItem][IT_VFCPDIF])
				EndIF

				If aSX6[MV_CRDBPIS] $ "S" .And. Substr(aNfItem[nItem][IT_CF],1,1)=="3"
					nBaseCPRB += aNfItem[nItem][IT_VALICM]
				EndIf
				If aNFItem[nItem][IT_TS][TS_PISDSZF] == "2"
					nBaseCPRB += aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFCOF] + aNfItem[nItem][IT_DESCZFPIS])
				Endif

				// Tratamento para retirada do valor do ICMS solidario da base do PIS Apuracao
				If ((MaFisDbST("PS2",nItem) .Or. (aSX6[MV_RPCBIZF] .And. aNfCab[NF_SUFRAMA])) .And. aNfItem[nItem][IT_DESCZFPIS] == 0)
					nBaseCPRB -= IIF(aNFItem[nItem][IT_TS][TS_CRPRST]<>0 .And. lIntTms,aNfItem[nItem][IT_VLCSOL],aNfItem[nItem][IT_VALSOL])
				Endif

				aNfItem[nItem][IT_BASECPB] := nBaseCPRB

				If !aSX6[MV_RNDICM] .And. lAgreg
					MaItArred(nItem,{"IT_BASECPB"})
				EndIf

				If aNFItem[nItem][IT_TS][TS_OPERSUC]=="1" .And. aNfCab[NF_SIMPSC]<>"1" .And. aNFCab[NF_SIMPNAC]<>"1" // Operacoes com Sucata
					nBaseCPRB := (aNFitem[nItem][IT_VALICM] / ( (100-(aNFitem[nItem][IT_ALIQICM]+aNFitem[nItem][IT_ALIQPS2]+aNFitem[nItem][IT_ALIQCF2]))/100 ) )
					aNfItem[nItem][IT_BASECPB] := nBaseCPRB
				Endif

			Else
				aNfItem[nItem][IT_BASECPB] := 0
			EndIf

			aNfItem[nItem][IT_ALIQCPB]	:= nAlq
			aNfItem[nItem][IT_VALCPB]	:= aNfItem[nItem][IT_BASECPB] * nAlq / 100
			aNfItem[nItem][IT_CODATIV]	:= aNfItem[nItem][IT_PRD][SB_CODATIV]
		Endif
	Else
		aNfItem[nItem][IT_ALIQCPB]	:= 0
		aNfItem[nItem][IT_BASECPB]	:= 0
		aNfItem[nItem][IT_VALCPB]	:= 0
	Endif

Else

    IF (nPosTgCPRB := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_CPRB})) >0  
    
        aNfItem[nItem][IT_VALCPB]:= aNfItem[nItem][IT_TRIBGEN][nPosTgCPRB][TG_IT_VALOR]
        aNfItem[nItem][IT_BASECPB]:= aNfItem[nItem][IT_TRIBGEN][nPosTgCPRB][TG_IT_BASE]
        aNfItem[nItem][IT_ALIQCPB]:= aNfItem[nItem][IT_TRIBGEN][nPosTgCPRB][TG_IT_ALIQUOTA]

    Endif
EndIf

Return

/*/{Protheus.doc} CPRBConvRf
(Função responsavel por converter alteração de referencia legado em referencia do configurador)

@author Renato Rezende
@since 26/11/2020
@version 12.1.31

@param:	
aNFItem-> Array com dados item da nota
nItem  -> Item que esta sendo processado
ccampo -> Campo que esta sendo alterado	
/*/
Function CPRBConvRf(aNfItem,nItem,ccampo)
Local cCampoConv := ""

IF cCampo == "IT_VALCPB"
    cCampoConv := "TG_IT_VALOR"
Elseif cCampo == "IT_BASECPB"
    cCampoConv := "TG_IT_BASE"
Elseif cCampo == "IT_ALIQCPB"
    cCampoConv := "TG_IT_ALIQUOTA"
Endif

Return cCampoConv
