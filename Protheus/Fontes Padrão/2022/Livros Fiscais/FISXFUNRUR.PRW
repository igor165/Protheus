#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*
MaFisRURAL -Alexandre Lemes -04/10/2012
Executa o calculo do FUNRURAL.
*/
Function FISXFUNRUR(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cExecuta)

Local aPFunRur  := {}
Local npRural   := aSX6[MV_CONTSOC]
Local nY 		:= Len(npRural)
Local nAliquota	:= 0
Local nNewAlqRur:= 0
Local nPosAlqFun:= 1
Local nBCFun    := 0
Local nPosTgFUNR := 0
Local lTribGen 	 := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_FUNRUR)
DEFAULT cExecuta := "BSE|ALQ|VLR|"


IF !lTribGen
	If aNfItem[nItem][IT_PRD][SB_CONTSOC] == "S" .And. aNFItem[nItem][IT_TS][TS_CONTSOC]=="1" .And. aNfCab[NF_TPCLIFOR] <> "X"
		IF  "ALQ" $ cExecuta
			//Define Aliquota FUNRURAL
			//aPFunRur[1]  == "F"
			//aPFunRur[2]  == "L"
			//aPFunRur[3]  == "J"
			Do While nY > 0
				nY:=AT("/",npRural)
				AADD(aPFunRur,IIf(nY > 0,Substr(npRural,1,nY-1),npRural))
				npRural:=Substr(npRural,nY+1,Len(npRural))
			EndDo
			//Retidado o "J" passado na função AT, pois de acordo com o que foi visto pela nossa consultora tributária, na entrada não
			// deve haver a retenção quando o fornecedor for pessoa jurídica
			If aNfCab[NF_CLIFOR] == "F"
				nAliquota := IIf( AT(SA2->A2_TIPORUR,"FL") > 0 , Val(aPFunRur[ AT(SA2->A2_TIPORUR,"FL") ]) , 0 )
			Else // Este ajuste e necessario pois este campo grava FLJ no MP10 e 123 no MP11 e ainda no MP11 a ordem de FJL e invertida ao prametro que le FLJ
				If SM0->M0_PRODRUR $ "F|1"
					nPosAlqFun := 1
				ElseIf SM0->M0_PRODRUR $ "L|3"
					nPosAlqFun := 2
				ElseIf SM0->M0_PRODRUR $ "J|2"
					nPosAlqFun := 3
				EndIf
				nAliquota := IIf( Val(SM0->M0_PRODRUR) > 0 , Val(aPFunRur[nPosAlqFun]) , 0 )
			EndIf
			//Ponto de Entrada para alterar a aliquota de Funrural de 2.3% para 0,02% conforme acoes
			//judiciarias movidas por alguns produtores e empregadores rurais cuja causa tem sido aceita
			//por inconstitucionalidade do art. 25 da Lei n 8.212/91.
			If aPE[PE_MAFISRUR]
				nNewAlqRur := ExecBlock( "MAFISRUR",.F.,.F.,{aNfItem[nItem,IT_TES],aNfItem[nItem,IT_PRODUTO],aNfCab[NF_CLIFOR],aNfCab[NF_OPERNF],aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA],IIf(aNfCab[NF_CLIFOR] == "F", SA2->A2_TIPORUR , SM0->M0_PRODRUR ) , nAliquota})
				If ValType(nNewAlqRur) == "N"
					nAliquota := nNewAlqRur
				EndIf
			EndIf

			aNfItem[nItem][IT_PERFUN] := nAliquota

		EndIF

		IF "BSE" $ cExecuta
			nBCFun := FISXBCFUN(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc)
			//Define a Base FUNRURAL
			IF aNfItem[nItem][IT_PERFUN] > 0
				If (aNFItem[nItem][IT_TS][TS_BSRURAL] == "1")
					aNfItem[nItem][IT_BASEFUN] := IIF(aNFItem[nItem][IT_TS][TS_DICMFUN] =="1" .And. aNFItem[nItem][IT_TS][TS_AGREG] == "D" .And. aNfItem[nItem][IT_DEDICM]>0 , (aNfItem[nItem][IT_VALMERC]-aNfItem[nItem][IT_DEDICM]) - aNfItem[nItem][IT_DESCONTO],;
					aNfItem[nItem][IT_VALMERC] - aNfItem[nItem][IT_DESCONTO])
				Elseif (aNFItem[nItem][IT_TS][TS_BSRURAL] == "2")
					aNfItem[nItem][IT_BASEFUN] := IIF(aNFItem[nItem][IT_TS][TS_DICMFUN] =="1" .And. aNFItem[nItem][IT_TS][TS_AGREG] == "D" .And. aNfItem[nItem][IT_DEDICM]>0 ,(aNfItem[nItem][IT_VALMERC]-aNfItem[nItem][IT_DEDICM]) - aNfItem[nItem][IT_DESCONTO] + aNfItem[nItem][IT_FRETE] + aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO],;
					aNfItem[nItem][IT_VALMERC] - aNfItem[nItem][IT_DESCONTO] + aNfItem[nItem][IT_FRETE] + aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO])
				Elseif (aNFItem[nItem][IT_TS][TS_BSRURAL] == "3")
					aNfItem[nItem][IT_BASEFUN] := IIF(aNFItem[nItem][IT_TS][TS_DICMFUN] =="1" .And. aNFItem[nItem][IT_TS][TS_AGREG] == "D" .And. aNfItem[nItem][IT_DEDICM]>0 ,(aNfItem[nItem][IT_VALMERC]-aNfItem[nItem][IT_DEDICM]) - aNfItem[nItem][IT_DESCONTO] + aNfItem[nItem][IT_FRETE] + aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO],;
					aNfItem[nItem][IT_VALMERC] - aNfItem[nItem][IT_DESCONTO] + aNfItem[nItem][IT_FRETE] + aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO])+ aNfItem[nItem][IT_VALIPI]+ aNfItem[nItem][IT_VALSOL]

				EndIf
			Else
				aNfItem[nItem][IT_BASEFUN] := 0
			EndIF

		EndIF

		IF "VLR" $ cExecuta
			//Define o Valor FUNRURAL
			IF aNfItem[nItem][IT_PERFUN] > 0
				aNfItem[nItem][IT_FUNRURAL] := ( aNfItem[nItem][IT_BASEFUN] * aNfItem[nItem][IT_PERFUN] ) / 100
			Else
				aNfItem[nItem][IT_FUNRURAL]:= 0
			EndIf
			MaItArred(nItem,{"IT_FUNRURAL"})
		EndIF
	Else
		aNfItem[nItem][IT_BASEFUN] := 0
		aNfItem[nItem][IT_PERFUN]  := 0
		aNfItem[nItem][IT_FUNRURAL]:= 0

	EndIf
Else

	//Atualiza com base no configurador
	IF (nPosTgFUNR := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_FUNRUR})) > 0 
		aNfItem[nItem][IT_PERFUN]	:= aNfItem[nItem][IT_TRIBGEN][nPosTgFUNR][TG_IT_ALIQUOTA]
		aNfItem[nItem][IT_BASEFUN]	:= aNfItem[nItem][IT_TRIBGEN][nPosTgFUNR][TG_IT_BASE]
		aNfItem[nItem][IT_FUNRURAL]	:= aNfItem[nItem][IT_TRIBGEN][nPosTgFUNR][TG_IT_VALOR]
	Endif
Endif

Return

/*
// Função criada para encapsular o calculo do BASE do Fun Rural para utilizar para o calculo do GILRAT, INSS e SENAR
//essa função é especifica para produtor RURAL , caso nao atenda ao Lprodutor, segue o calculo normal do INSS e SENAR
// utilizando a base IT_TOTAL e para o GILTRAT mantem o calculo ja existe na MAFISRURAL adicionando somente a 3 opção
// com IPI + ICMS ST.
//https://jiraproducao.totvs.com.br/browse/DSERFIS1-16082
*/
Function FISXBCFUN(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc)

Local nRet := 0
Local lProdutor := Iif(SM0->M0_PRODRUR $ "F|1|L|3|J|2" .OR. (aNfCab[NF_CLIFOR] == "F" .And. aNfCab[NF_TIPORUR] $ "FL"),.T.,.F.)

If lProdutor  .And. !Empty(aNFItem[nItem][IT_TS][TS_BSRURAL])
    If (aNFItem[nItem][IT_TS][TS_BSRURAL] == "1")
        nRet := IIF(aNFItem[nItem][IT_TS][TS_DICMFUN] =="1" .And. aNFItem[nItem][IT_TS][TS_AGREG] == "D" .And. aNfItem[nItem][IT_DEDICM]>0 , (aNfItem[nItem][IT_VALMERC]-aNfItem[nItem][IT_DEDICM]) - aNfItem[nItem][IT_DESCONTO],;
        aNfItem[nItem][IT_VALMERC] - aNfItem[nItem][IT_DESCONTO])
    Elseif (aNFItem[nItem][IT_TS][TS_BSRURAL] == "2")
        nRet := IIF(aNFItem[nItem][IT_TS][TS_DICMFUN] =="1" .And. aNFItem[nItem][IT_TS][TS_AGREG] == "D" .And. aNfItem[nItem][IT_DEDICM]>0 ,(aNfItem[nItem][IT_VALMERC]-aNfItem[nItem][IT_DEDICM]) - aNfItem[nItem][IT_DESCONTO] + aNfItem[nItem][IT_FRETE] + aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO],;
        aNfItem[nItem][IT_VALMERC] - aNfItem[nItem][IT_DESCONTO] + aNfItem[nItem][IT_FRETE] + aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO])
    Elseif (aNFItem[nItem][IT_TS][TS_BSRURAL] == "3")
        nRet := IIF(aNFItem[nItem][IT_TS][TS_DICMFUN] =="1" .And. aNFItem[nItem][IT_TS][TS_AGREG] == "D" .And. aNfItem[nItem][IT_DEDICM]>0 ,(aNfItem[nItem][IT_VALMERC]-aNfItem[nItem][IT_DEDICM]) - aNfItem[nItem][IT_DESCONTO] + aNfItem[nItem][IT_FRETE] + aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO],;
        aNfItem[nItem][IT_VALMERC] - aNfItem[nItem][IT_DESCONTO] + aNfItem[nItem][IT_FRETE] + aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_SEGURO])+ aNfItem[nItem][IT_VALIPI]+ aNfItem[nItem][IT_VALSOL]
    EndIf
EndIf

Return nRet


/*/{Protheus.doc} FUNRConvRf
	(Função responsavel por converter alteração de referencia legado em referencia do configurador)
	
	@author Rafael Oliveira
    @since 23/11/2020
    @version 12.1.27

	@param:	
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado	
	ccampo -> Campo que esta sendo alterado	

	/*/
Function FUNRConvRf(aNfItem,nItem,ccampo)
 Local cCampoConv := ""

	IF cCampo == "IT_FUNRURAL"
		cCampoConv := "TG_IT_VALOR"		
	Elseif cCampo == "IT_BASEFUN"	
		cCampoConv := "TG_IT_BASE"				
	Elseif cCampo == "IT_PERFUN"
		cCampoConv := "TG_IT_ALIQUOTA"
	Endif
	

Return cCampoConv
