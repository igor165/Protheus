#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISXCRDPRE
    (Componentização de um pedaço da função xFisLF - 
    Atualiza os livros fiscais para o item.)
    
	@author Rafael Oliveira
    @since 11/05/2020
    @version 12.1.27

    @Autor da função original 
    Edson Maricate # 20/12/1999
    
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
                    "1" -  Presumido ICM
                    "2" -  Presumido Substituicao Tributaria
                    "3" - Credito Presumido Pela Carga Tributária
/*/

Function FISXCRDPRE(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, nBICMOri,cExecuta, cAliasPROD)
Local cLeiteIn 	 := aSX6[MV_PRODLEI]
Local aRegra     := {}
Local nX         := 0
Local cMvEstado  := aSX6[MV_ESTADO]
Local cProdLeite := IIf((cAliasPROD)->(FieldPos(cLeiteIn)) > 0 , (cAliasPROD)->&(cLeiteIn) , "" )
Local nCrdPresMG := Iif( aPos[FP_B1_CRDPRES] .And. !Empty(aNfItem[nItem][IT_PRD][SB_CRDPRES]) , aNfItem[nItem][IT_PRD][SB_CRDPRES] , aNFItem[nItem][IT_TS][TS_CRDPRES] )
Local nCrePSC	 := 0
Local aMVCRPRESC := &(aSX6[MV_CRPRESC])
Local lTribGIC   := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_PRES_ICMS) 
Local lTribGPD   := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_PRODEPE) 
Local lTribGST   := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_PRES_ST) 
Local lTribGCT   := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_PRES_CARGA)
Local lTribOut   := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_CRDOUT)
Local nRetVCtb	 := IIF(!aNFItem[nItem][IT_TS][TS_INCSOL]$"A,N,D",aNfItem[nItem][IT_VALSOL],0)

Default nBICMOri      := aNfItem[nItem][IT_TOTAL]+;
IIf(aNFItem[nItem][IT_TS][TS_DESCOND] == "1" ,(aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]), 0)+;
IIf(aNFItem[nItem][IT_TS][TS_AGREG]   == "N" .And. aNFItem[nItem][IT_TS][TS_TRFICM]=="2",aNfItem[nItem][IT_VALMERC],0)-;
IIf(aNFItem[nItem][IT_TS][TS_IPILICM] <> "1" .And. aNFItem[nItem][IT_TS][TS_IPI]<>"R"   ,aNfItem[nItem][IT_VALIPI] ,0)-;
IIf(aNFItem[nItem][IT_TS][TS_AGRRETC] == "1",0,nRetVCtb)-;
IIf(aNFItem[nItem][IT_TS][TS_DESPICM] == "2",aNfItem[nItem][IT_DESPESA] + aNfItem[nItem][IT_AFRMIMP],0)-;
IIf(aNFItem[nItem][IT_TS][TS_PSCFST] == "1" .And. aNFItem[nItem][IT_TS][TS_APSCFST] == "1",(aNfItem[nItem][IT_VALPS3]+aNfItem[nItem][IT_VALCF3]),0)

IF cExecuta == "1"     
     
    // CREDITO ESTIMULO MANAUS - TS_CRDEST = 1 - Nao Calcula | 2 - Produtos Eletronicos | 3 - Contrucao Civil |4 - Pelo NCM
    If aNFItem[nItem][IT_TS][TS_CRDEST]$"23" .And. aPos[FP_B1_CRDEST] .And. aPos[FP_F3_CRDEST]
        aNfItem[nItem][IT_LIVRO][LF_CRDEST]	:= NoRound(aNfItem[nItem][IT_VALICM] * aNfItem[nItem][IT_PRD][SB_CRDEST] /100,2)
    ElseIf aNFItem[nItem][IT_TS][TS_CRDEST]$"4" //Deve ser feito para entradas e saidas (calculo: Créditos - Débitos * %de estímulo)
        If FindFunction("M953CRDM")
            aRegra := M953CRDM() // Lembre-se de refazer esta funcao para melhorar a performance
        EndIf
        If Len(aRegra)>0 .And.;
            (nX := AScanX(aRegra, {|x| x[1]== Alltrim(aNfItem[nItem][IT_LIVRO][LF_POSIPI]) .And. x[2]== aNfCab[NF_A1CRDMA] } )) > 0 .Or.;
            (nX := AScanX(aRegra, {|x| x[1]== Alltrim(aNfItem[nItem][IT_LIVRO][LF_POSIPI]) .And. x[2]=="4" } )) > 0
            aNfItem[nItem][IT_LIVRO][LF_CRDEST]	:= NoRound(aNfItem[nItem][IT_VALICM] * aRegra[nX,3]/100, 2 )
        EndIf
    EndIf

    //Preenche Tipo de Credito presumido para PE mesmo que nota seja não icentivada
    If aNFItem[nItem][IT_TS][TS_TPPRODE] <> "" .And. cMvEstado == "PE"
        aNfItem[nItem][IT_LIVRO][LF_TPPRODE] := aNFItem[nItem][IT_TS][TS_TPPRODE]
    EndIf

    //CREDITO PRESUMIDO referente a Zona Franca de Manaus
    aNfItem[nItem][IT_LIVRO][LF_CRDZFM] := aNfItem[nItem][IT_CRDZFM]    

    If (aNFItem[nItem][IT_TS][TS_CRDPRES] > 0 .And. !Empty(aNFItem[nItem][IT_TS][TS_TPCPRES])) .or. lTribGIC

        IF !lTribGIC
            //Se o percentual do Crédito Presumido TS_CRDPRES estiver preenchido e o Tipo de Crédito Presumido TS_TPCPRES
            //também estiver preenchido, então o crédito presumido será calculado seguindo esta nova regra. Caso somente o percentual TS_CRDPRES
            //estivere preenchido, então irá seguir as regras que já existiam antes desta implementação, mantendo assim o legado.
            Do Case
                Case aNFItem[nItem][IT_TS][TS_TPCPRES] == "C"
                    //Base de cálculo para crédito presumido será o valor contábil
                    aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := NoRound((aNfItem[nItem][IT_LIVRO][LF_VALCONT] * aNFItem[nItem][IT_TS][TS_CRDPRES]) / 100,2)
                    aNfItem[nItem][IT_LIVRO][LF_BASECPR] := aNfItem[nItem][IT_LIVRO][LF_VALCONT]

                Case aNFItem[nItem][IT_TS][TS_TPCPRES] == "R"
                    //Base de cálculo para crédito presumido será a base do ICMS, e irá reduzir o valor do crédito presumido do total do documento.
                    aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := NoRound((aNfItem[nItem][IT_BASEICM] * aNFItem[nItem][IT_TS][TS_CRDPRES]) / 100,2)
                    aNfItem[nItem][IT_LIVRO][LF_BASECPR] := aNfItem[nItem][IT_BASEICM]
                    aNfItem[nItem][IT_LIVRO][LF_VALCONT] -= aNfItem[nItem][IT_LIVRO][LF_CRDPRES]
                Case aNFItem[nItem][IT_TS][TS_TPCPRES] == "F" // Opcao limita total operacao por frete
                    If aNfItem[nItem][IT_FRETE]>0
                        aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := NoRound((aNfItem[nItem][IT_LIVRO][LF_VALCONT] * aNFItem[nItem][IT_TS][TS_CRDPRES]) / 100,2)
                        aNfItem[nItem][IT_LIVRO][LF_BASECPR] := aNfItem[nItem][IT_LIVRO][LF_VALCONT]
                        // Limita ao valor do Frete
                        If aNfItem[nItem][IT_LIVRO][LF_CRDPRES] > aNfItem[nItem][IT_FRETE]
                            aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := aNfItem[nItem][IT_FRETE]
                            aNfItem[nItem][IT_LIVRO][LF_BASECPR] := aNfItem[nItem][IT_FRETE]
                        EndIf
                        // Para SC sera baseado no frete so' e somente se, este nao ultrapassa valor de pauta.
                        // Sendo assim, limita ao valor da pauta
                        If (cMvEstado$"SC") .AND. (aNfItem[nItem][IT_PAUTIC]>0) .AND. (aNfItem[nItem][IT_LIVRO][LF_CRDPRES]>aNfItem[nItem][IT_PAUTIC])
                            aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := aNfItem[nItem][IT_PAUTIC]
                            aNfItem[nItem][IT_LIVRO][LF_BASECPR] := aNfItem[nItem][IT_PAUTIC]
                        EndIf
                    EndIf
                Case aNFItem[nItem][IT_TS][TS_TPCPRES] == "M"
                    aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := NoRound((aNfItem[nItem][IT_VALMERC] * aNFItem[nItem][IT_TS][TS_CRDPRES]) / 100,2)
                    aNfItem[nItem][IT_LIVRO][LF_BASECPR] := aNfItem[nItem][IT_VALMERC]
                Case aNFItem[nItem][IT_TS][TS_TPCPRES] == "B"
                    //Base de cálculo para crédito presumido será a base do ICMS
                    aNfItem[nItem][IT_PRESICM] := (aNfItem[nItem][IT_BASEICM] * aNFItem[nItem][IT_TS][TS_CRDPRES]) / 100
                    MaItArred(nItem, {"IT_PRESICM"})                 
                    aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := aNfItem[nItem][IT_PRESICM]                   
                    aNfItem[nItem][IT_LIVRO][LF_BASECPR] := aNfItem[nItem][IT_BASEICM]
                    
                Case aNFItem[nItem][IT_TS][TS_TPCPRES] == "N" //Base calculo valor do ICMS
                    If aSX6[MV_RNDICM]
                        aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := Round((aNfItem[nItem][IT_VALICM] * aNFItem[nItem][IT_TS][TS_CRDPRES]) / 100,2)
                    Else
                        aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := NoRound((aNfItem[nItem][IT_VALICM] * aNFItem[nItem][IT_TS][TS_CRDPRES]) / 100,2)
                    EndIf
                    aNfItem[nItem][IT_LIVRO][LF_BASECPR] := aNfItem[nItem][IT_VALICM]
            EndCase

            //CREDITO PRESUMIDO - MG - RICMS/02 - Inciso X, artigo 75 do estado de MG
            //Agora passa a funcionar de forma genérica, não só para MG.
            If aNFItem[nItem][IT_TS][TS_AGREGCP]=="1" // Agrega o credito presumido ao valor total
                // Agrega o credito presumido ao valor total e duplicata, seguindo a mesma regra do produto agregando ao total
                aNfItem[nItem][IT_TOTAL] += aNfItem[nItem][IT_LIVRO][LF_CRDPRES]
                If aNFItem[nItem][IT_TS][TS_TPCPRES] $ "C|M"// C-Cred. Tot. Oper; M-Cred. Val. Merc.
                    aNfItem[nItem][IT_LIVRO][LF_VALCONT] += aNfItem[nItem][IT_LIVRO][LF_CRDPRES]
                EndIf

                If aNFItem[nItem][IT_TS][TS_DUPLIC] <> "N"
                    aNfItem[nItem][IT_BASEDUP] += aNfItem[nItem][IT_LIVRO][LF_CRDPRES]
                EndIf
            EndIf
        
        Else
            //Função responsavel por gravar referencias com base no configurador            
            CredPres(aNFCab,aNfItem,nItem,aSX6,cMvEstado,cExecuta,TRIB_ID_PRES_ICMS,cProdLeite)
        EndIf

    ElseIf aNFItem[nItem][IT_TS][TS_CRDPRES] > 0 .Or. aNfItem[nItem][IT_B1DIAT] == "1" .Or. nCrdPresMG > 0 .Or. aNFItem[nItem][IT_TS][TS_CRPRSIM] > 0 .Or. aNFItem[nItem][IT_TS][TS_CRPRERO] > 0 .Or. ;
        aNFItem[nItem][IT_TS][TS_CRPRESP] > 0 .Or. aNFItem[nItem][IT_TS][TS_CROUTSP] > 0 .Or. aNFItem[nItem][IT_TS][TS_CRPREPR] > 0 .Or. aNFItem[nItem][IT_TS][TS_CPRESPR] > 0 .Or. aNFItem[nItem][IT_TS][TS_CRPREPE] > 0 .Or. aNFItem[nItem][IT_TS][TS_CPPRODE] > 0

        If cMvEstado == "RJ" .Or. cMvEstado == "SC" .Or. cMvEstado == "PR" .Or. cMvEstado == "SP" .Or. cMvEstado == "MT" .Or. cMvEstado == "PE";
            .Or. cMvEstado == "RO" .Or. cMvEstado == "MG" .Or. cMvEstado == "CE" .Or. (cMvEstado == "RS" .And. (aNFItem[nItem][IT_TS][TS_CREDPRE] > 0 .Or. cProdLeite == "1" ))

            IF !lTribGIC
                //CREDITO PRESUMIDO - MG - RICMS/02 - Inciso X, artigo 75 do estado de MG
                If cMvEstado == "MG" .And. nCrdPresMG > 0
                    aNfItem[nItem][IT_CRPREMG]	:= 0

                    If aSX6[MV_RNDICM]
                        aNfItem[nItem][IT_CRPREMG]	:= Round((aNfItem[nItem][IT_VALMERC] + Iif( aNFItem[nItem][IT_TS][TS_AGREG] == "I" , aNfItem[nItem][IT_VALICM] , 0 ) ) * (nCrdPresMG / 100) , 2 )
                    Else
                        aNfItem[nItem][IT_CRPREMG]	:= NoRound((aNfItem[nItem][IT_VALMERC] + Iif( aNFItem[nItem][IT_TS][TS_AGREG] == "I" , aNfItem[nItem][IT_VALICM] , 0 ) ) * (nCrdPresMG / 100) )
                    EndIf

                    If aNFCab[NF_OPERNF]=="S" .And. !aNFItem[nItem][IT_TS][TS_AGREG] == "I" .And. aSX6[MV_VALICM]
                        If aSX6[MV_RNDICM]
                            aNfItem[nItem][IT_CRPREMG]	:= Round((aNfItem[nItem][IT_VALICM] * nCrdPresMG) / 100,2)
                        Else
                            aNfItem[nItem][IT_CRPREMG]	:= NoRound((aNfItem[nItem][IT_VALICM] * nCrdPresMG) / 100,2)
                        EndIf
                    EndIf

                    If aNFItem[nItem][IT_TS][TS_AGREGCP]=="1" // Agrega o credito presumido ao valor total e duplicata
                        aNfItem[nItem][IT_TOTAL] += NoRound(aNfItem[nItem][IT_CRPREMG])
                        If aNFItem[nItem][IT_TS][TS_DUPLIC] <> "N"
                            aNfItem[nItem][IT_BASEDUP] += NoRound(aNfItem[nItem][IT_CRPREMG])
                        EndIf
                    EndIf

                    aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := aNfItem[nItem][IT_CRPREMG]
                EndIf

                //CREDITO PRESUMIDO - RJ - Rio de Janeiro
                If cMvEstado == "RJ"
                    If aSX6[MV_CRPRERJ]
                        aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := NoRound((aNfItem[nItem][IT_BASEICM] * aNFItem[nItem][IT_TS][TS_CRDPRES]) / 100,2)
                    Else
                        aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := NoRound((aNfItem[nItem][IT_LIVRO][LF_VALCONT] * aNFItem[nItem][IT_TS][TS_CRDPRES]) / 100,2)
                    Endif
                Endif

                //CREDITO PRESUMIDO - SP - Lei 6.374,de 01.03.1989 nos art.38,6§ e 112 regulamentada pelo Dec. 52.381 de 19.11.2007 DOE PR de 22.11.2007
                If cMvEstado == "SP"
                    aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := NoRound((aNfItem[nItem][IT_LIVRO][LF_VALCONT] * aNFItem[nItem][IT_TS][TS_CRDPRES]) / 100,2)
                    //CREDITO PRESUMIDO - SP - Conforme o Decreto 52.586 de 28.12.2007, relativo a aquisicao de Leite Cru
                    If aNFItem[nItem][IT_TS][TS_CRPRESP] > 0 .And. aNFCab[NF_OPERNF] == "E"
                        aNfItem[nItem][IT_LIVRO][LF_CRPRESP] := NoRound((aNfItem[nItem][IT_LIVRO][LF_VALCONT] * aNFItem[nItem][IT_TS][TS_CRPRESP]) / 100,2)
                    Endif
                    //CREDITO OUTORGADO - SP
                    //Conforme Decreto 56.018 de 16.07.2010 - Art. 31 do Anexo III do RICMS,
                    //relativo a entrada de carnes e demais produtos comestiveis.
                    IF !lTribOut
                        aNfItem[nItem][IT_CROUTSP]:= 0
                        If Substr(aNfItem[nItem][IT_POSIPI],1,4) $ aSX6[MV_CROUTSP] .And. aNFCab[NF_UFDEST]=="SP" .And. aNFCab[NF_UFORIGEM]=="SP" .And. aNFItem[nItem][IT_TS][TS_CROUTSP] > 0
                            aNfItem[nItem][IT_CROUTSP]:= NoRound((aNfItem[nItem][IT_VALMERC] * aNFItem[nItem][IT_TS][TS_CROUTSP]) / 100,2)
                        Endif
                        aNfItem[nItem][IT_LIVRO][LF_CROUTSP] := aNfItem[nItem][IT_CROUTSP]
                    Else
                        CredOut(aNFCab,aNfItem,nItem,aSX6,cMvEstado)
                    Endif
                Endif

                //CREDITO PRESUMIDO - RS de Acordo com o RICMS - Livro I, titulo V, Atr. 32, Inciso XIX.
                If cMvEstado == "RS"
                    If aNFItem[nItem][IT_TS][TS_CREDPRE] > 0 .And. aNFCab[NF_OPERNF] == "E"
                        aNfItem[nItem][IT_LIVRO][LF_CREDPRE] := NoRound((aNfItem[nItem][IT_QUANT] * aNFItem[nItem][IT_TS][TS_CREDPRE]) , 2 )
                    EndIf

                    If cProdLeite == "1" .And. aNFCab[NF_OPERNF] == "S"
                        aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := NoRound((aNfItem[nItem][IT_VALICM]*(aNFItem[nItem][IT_TS][TS_CRDPRES]/100)),2)
                    Endif
                Endif

                //CREDITO PRESUMIDO - SC RICMS - Anexo 02 - Benefícios Fiscais - Capitulo III (Art. 18) e  Art 142
                If cMvEstado == "SC"
                    aNfItem[nItem][IT_CRPRESC]	:= 0

                    If 	aNfItem[nItem][IT_B1DIAT] == "1" .And. aNfItem[nItem][IT_PREDIC] == 0 .And. aNFItem[nItem][IT_TS][TS_CRDPRES] == 0  ;
                        .And. ( aNFCab[NF_OPERNF] == "S" .Or. (aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_TIPONF]$"DB") )
                        //Conforme Art. 15, IX do Anexo 2 - RICMS - DO CREDITO PRESUMIDO SC
                        //De acordo com o Regime Especial DIAT-SC o percentual do credito presumido
                        //e' definido conforme aliquota do ICMS DIAT - SC
                        For nCrePSC := 1 to Len(aMVCRPRESC)
                            If aNfItem[nItem][IT_ALIQICM] == aMVCRPRESC[nCrePSC][1]
                                aNfItem[nItem][IT_CRPRESC]:= ((aNfItem[nItem][IT_VALICM] * aMVCRPRESC[nCrePSC][2] ) / 100)
                                Exit
                            EndIf
                        Next
                        MaItArred(nItem,{"IT_CRPRESC"})

                    ElseIf aNFItem[nItem][IT_TS][TS_CRDPRES] > 0 .And. aNFCab[NF_OPERNF] == "E" .And. !Empty(aNfItem[nItem][IT_FRETE])
                        If aNfItem[nItem][IT_FRETE] > NoRound((aNfItem[nItem][IT_VALMERC] * aNFItem[nItem][IT_TS][TS_CRDPRES]) / 100,2)
                            aNfItem[nItem][IT_CRPRESC]	:= NoRound((aNfItem[nItem][IT_VALMERC] * aNFItem[nItem][IT_TS][TS_CRDPRES]) / 100,2)
                        Else
                            aNfItem[nItem][IT_CRPRESC]	:= aNfItem[nItem][IT_FRETE]
                        EndIf
                    Elseif aNFCab[NF_OPERNF] == "S"
                        aNfItem[nItem][IT_CRPRESC]	:= NoRound((aNfItem[nItem][IT_BASEICM] * aNFItem[nItem][IT_TS][TS_CRDPRES]) / 100,2)
                    EndIf
                    aNfItem[nItem][IT_LIVRO][LF_CRDPRES]	:= aNfItem[nItem][IT_CRPRESC]

                    //CREDITO PRESUMIDO - SC - Simples Nacional
                    //Lei 14.264/07 - Decreto 1036 de 28/01/08  RICMS/SC Art. 29, Parag 5
                    aNfItem[nItem][IT_CRPRSIM]	:= 0
                    If aNFCab[NF_SIMPNAC]=="1" .And. aNFItem[nItem][IT_TS][TS_CRPRSIM] > 0 .And. !(aNfItem[nItem][IT_VALSOL] > 0) .And. (Substr(aNfItem[nItem][IT_LIVRO][LF_CFO],1,1)$"1" .Or. (aNFCab[NF_OPERNF] == "S" .And. aNFCab[NF_TIPONF] $ "BD"))
                        aNfItem[nItem][IT_CRPRSIM]	:= (aNfItem[nItem][IT_VALMERC] - (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT])) * aNFItem[nItem][IT_TS][TS_CRPRSIM] / 100
                    EndIf
                    aNfItem[nItem][IT_LIVRO][LF_CRPRSIM] := aNfItem[nItem][IT_CRPRSIM]
                EndIf

                //CREDITO PRESUMIDO - CE - Artigo 64 Inciso VII
                if cMvEstado=="CE" .And. (aNFItem[nItem][IT_TS][TS_CRDPRES]>0) .And. aNFCab[NF_OPERNF]=='E'
                    If aNfItem[nItem][IT_FRETE] > NoRound((aNfItem[nItem][IT_VALMERC] * aNFItem[nItem][IT_TS][TS_CRDPRES]) / 100,2)
                        aNfItem[nItem][IT_CRPRECE]	:= NoRound((aNfItem[nItem][IT_VALMERC] * aNFItem[nItem][IT_TS][TS_CRDPRES]) / 100,2)
                    Else
                        aNfItem[nItem][IT_CRPRECE]	:= aNfItem[nItem][IT_FRETE]
                    EndIf
                    aNfItem[nItem][IT_LIVRO][LF_CRDPRES] :=  aNfItem[nItem][IT_CRPRECE]
                EndIF

                //CREDITO PRESUMIDO - PR  Lei 14.985 de 06.01.2006 Decreto 6.144 - 22.02.2006 - DOE PR
                If cMvEstado == "PR"
                    If aNFItem[nItem][IT_TS][TS_AGREG]$"BC"
                        aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := NoRound((IIF(aNfItem[nItem][IT_BASEICM]==0,aNfItem[nItem][IT_LIVRO][LF_VALCONT]/(1-(aNfItem[nItem][IT_ALIQICM]/100)),aNfItem[nItem][IT_BASEICM])*(aNFItem[nItem][IT_TS][TS_CRDPRES]/100)),2)
                    Else
                        aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := NoRound((IIF(aNfItem[nItem][IT_BASEICM]==0,nBICMOri,aNfItem[nItem][IT_BASEICM])*(aNFItem[nItem][IT_TS][TS_CRDPRES]/100)),2)
                    EndIf
                    //CREDITO PRESUMIDO - PR  RICMS - Art. 4 Anexo III - Credito Presumido - PR Decreto n. 1.980
                    aNfItem[nItem][IT_CRPREPR]	:= 0
                    If aNFItem[nItem][IT_TS][TS_CRPREPR] > 0 // .And. aNFCab[NF_OPERNF] == "E"
                        aNfItem[nItem][IT_CRPREPR] := NoRound((aNfItem[nItem][IT_LIVRO][LF_VALCONT] * aNFItem[nItem][IT_TS][TS_CRPREPR]) / 100,2)
                    Endif
                    aNfItem[nItem][IT_LIVRO][LF_CRPREPR] := aNfItem[nItem][IT_CRPREPR]
                    aNfItem[nItem][IT_LIVRO][LF_CPRESPR] := aNfItem[nItem][IT_CPRESPR] // CREDITO PRESUMIDO - PR - Art.631-A do RICMS/2008
                Endif

                //CREDITO PRESUMIDO - MT - Mato Grosso Comunicado PRODEIC 067/2005 Resolucao 36/2005 Lei 7.958/2003 Decreto 1.432/2003
                If cMvEstado == "MT"
                    aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := NoRound((aNfItem[nItem][IT_VALICM]*(aNFItem[nItem][IT_TS][TS_CRDPRES]/100)),2)
                Endif

                //CREDITO PRESUMIDO - RO - Rondonia Lei 1.473/2005 - Artigo 1 Operacoes Interestaduais com produtos importados
                If cMvEstado == "RO"
                    If SubStr(aNfItem[nItem][IT_LIVRO][LF_CFO],1,1) $ "6" .And. aNfItem[nItem][IT_PRD][SB_ORIGEM] == "1"
                        aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := NoRound((aNfItem[nItem][IT_VALICM]*(aNFItem[nItem][IT_TS][TS_CRDPRES]/100)),2)
                    EndIf

                    If aNFItem[nItem][IT_TS][TS_CRPRERO] > 0 //CREDITO PRESUMIDO - RO - RICMS - (Art. 39) Anexo IV
                        aNfItem[nItem][IT_LIVRO][LF_CRPRERO] := NoRound((aNfItem[nItem][IT_VALICM]*(aNFItem[nItem][IT_TS][TS_CRPRERO]/100)),2)
                    EndIf
                Endif
            Else
                //Função responsavel por gravar referencias com base no configurador                                
                CredPres(aNFCab,aNfItem,nItem,aSX6,cMvEstado,cExecuta,TRIB_ID_PRES_ICMS,cProdLeite)
            Endif

            //CREDITO PRESUMIDO - PE - Art.6 Decreto  n28.247
            If cMvEstado == "PE"
                aNfItem[nItem][IT_CRPREPE]:= 0
                IF !lTribGIC
                    If aNFItem[nItem][IT_TS][TS_CRPREPE] > 0
                        aNfItem[nItem][IT_CRPREPE]:= NoRound( ( aNfItem[nItem][IT_VALICM] * (aNFItem[nItem][IT_TS][TS_CRPREPE]/100) ) , 2 )
                    EndIf
                    aNfItem[nItem][IT_LIVRO][LF_CRPREPE] := aNfItem[nItem][IT_CRPREPE]
                Else
                    //Função responsavel por gravar referencias com base no configurador                    
                    CredPres(aNFCab,aNfItem,nItem,aSX6,cMvEstado,cExecuta,TRIB_ID_PRES_ICMS,cProdLeite)
                Endif

                IF !lTribGPD
                    //No trecho abaixo do cálculo do Prodepe, a referência IT_CPPRODE somente existe para controle de arredondamento e controle de sobra
                    If aNFItem[nItem][IT_TS][TS_CPPRODE] > 0
                        If 	aNfItem[nItem][IT_LIVRO][LF_TPPRODE] $ "5"
                            aNfItem[nItem][IT_CPPRODE]	:= ( aNfItem[nItem][IT_LIVRO][LF_VALCONT] - aNfItem[nItem][IT_VALSOL] ) * ( aNFItem[nItem][IT_TS][TS_CPPRODE] / 100 )
                            MaItArred(nItem,{"IT_CPPRODE"})
                            aNfItem[nItem][IT_LIVRO][LF_CPPRODE] := aNfItem[nItem][IT_CPPRODE]
                        Else
                            aNfItem[nItem][IT_CPPRODE]	:= aNfItem[nItem][IT_VALICM] * ( aNFItem[nItem][IT_TS][TS_CPPRODE] / 100 )
                            MaItArred(nItem,{"IT_CPPRODE"})
                            aNfItem[nItem][IT_LIVRO][LF_CPPRODE] := aNfItem[nItem][IT_CPPRODE]
                        Endif
                        If 	aNfItem[nItem][IT_LIVRO][LF_TPPRODE] $ "3#4" .And. aNfItem[nItem][IT_LIVRO][LF_CPPRODE] > aNfItem[nItem][IT_FRETE]
                            aNfItem[nItem][IT_CPPRODE]	:= aNfItem[nItem][IT_FRETE]
                            MaItArred(nItem,{"IT_CPPRODE"})
                            aNfItem[nItem][IT_LIVRO][LF_CPPRODE] := aNfItem[nItem][IT_CPPRODE]
                        EndIf
                    EndIf
                Else
                    //Função responsavel por gravar referencias com base no configurador                                        
                    CredPres(aNFCab,aNfItem,nItem,aSX6,cMvEstado,cExecuta,TRIB_ID_PRODEPE,cProdLeite)
                Endif
            EndIf
        Else
            //Calculo do Credito Presumido para todos os outros estados que nao possuem uma regra definida
            //Caso a regra do calculo seja essa mesma, somente sera preciso alterar o P9AUTOTEXT para apresentar na apuracao.
            IF !lTribGIC
                aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := NoRound((aNfItem[nItem][IT_LIVRO][LF_VALCONT] * aNFItem[nItem][IT_TS][TS_CRDPRES]) / 100,2)
            Else
                //Função responsavel por gravar referencias com base no configurador                    
                CredPres(aNFCab,aNfItem,nItem,aSX6,cMvEstado,cExecuta,TRIB_ID_PRES_ICMS,cProdLeite)
            EndIF
        EndIf
    Else
        aNfItem[nItem][IT_CRPRESC]:= 0
        aNfItem[nItem][IT_CRPREPE]:= 0
        aNfItem[nItem][IT_CRPREPR]:= 0
        aNfItem[nItem][IT_CRPRECE]:= 0
        aNfItem[nItem][IT_CRPREMG]:= 0
        aNfItem[nItem][IT_CRPRSIM]:= 0
    
    EndIf

    IF !lTribGIC // Calculo do RS que estava fora das demais regras
        aNfItem[nItem][IT_CREDPRE] := 0 //Credito Presumido - Art. 6 Decreto  n28.247 ???

        If aNFCab[NF_OPERNF]=="E" .And. aNFItem[nItem][IT_TS][TS_CREDPRE] > 0
            aNfItem[nItem][IT_CREDPRE]	:= NoRound( (aNfItem[nItem][IT_QUANT] * aNFItem[nItem][IT_TS][TS_CREDPRE]) , 2 )
        EndIf

        aNfItem[nItem][IT_LIVRO][LF_CREDPRE] := aNfItem[nItem][IT_CREDPRE]
    Else
        //Função responsavel por gravar referencias com base no configurador                    
        CredPres(aNFCab,aNfItem,nItem,aSX6,cMvEstado,cExecuta,TRIB_ID_PRES_ICMS,cProdLeite)
    EndIF

     

Elseif cExecuta == "2" // Presumido Substituicao Tributaria        
    IF !lTribGST  
        //Grava valor Credito Presumido Substituicao Tributaria retido pelo contratante do servico de transporte - Decreto 44.147/2005 (MG)
        If aNFItem[nItem][IT_TS][TS_CRPRST]<>0
            aNfItem[nItem][IT_LIVRO][LF_CRPRST]	 := aNfItem[nItem][IT_VLCSOL] - aNfItem[nItem][IT_VALSOL]
            // Joao: Verifiquei todas as chamadas de MaFisLF e ninguém passa este parâmetro como .T.
            // Para não mudar todas as funções abaixo para FUNCTION optei por comentar o trecho. Caso
            // ocorra algum reflexo será necessário alterar todas as funções para FUNCTION pois foi
            // preciso retirar a MaFisLF do MATXFIS por conta do tamanho do fonte.
            /*If lRecPreSt
                MaAliqSoli(nItem)
                MaExcecao(nItem)
                MaMargem(nItem)
                MaFisVSol(nItem)
                MaFisVTot(nItem)
            EndIf*/
        EndIf
    Else
        //Função responsavel por gravar referencias com base no configurador        
        CredPres(aNFCab,aNfItem,nItem,aSX6,cMvEstado,cExecuta,TRIB_ID_PRES_ST,cProdLeite)
    EndIF
ElseIF  cExecuta == "3"  //CREDITO PRESUMIDO PELA CARGA TRIBUTÁRIA

    IF !lTribGCT
        //  Exemplo: DECRETO N. 42.649 DE 05 DE OUTUBRO DE 2010  /RJ
        If aNFItem[nItem][IT_TS][TS_CPRCATR] == "1" .And. aNfItem[nItem][IT_PRD][SB_B1CALTR] == "1"
            If aNFCab[NF_OPERNF] == "S" .And. (Substr(aNfItem[nItem][IT_LIVRO][LF_CFO],1,1)$"6" .Or. aNfItem[nItem][IT_PRD][SB_ORIGEM] <> "0" .Or. aSX6[MV_CPCATRI])
                aNfItem[nItem][IT_LIVRO][LF_CRDPCTR] := aNfItem[nItem][IT_LIVRO][LF_VALICM] - aNfItem[nItem][IT_LIVRO][LF_VALFECP] - ( aNfItem[nItem][IT_LIVRO][LF_BASEICM] * ( aNfItem[nItem][IT_PRD][SB_B1CATRI] / 100 )  )
            ElseIf aNFCab[NF_OPERNF] == "E" .And. aNFCab[NF_TIPONF] $ "DB"
                aNfItem[nItem][IT_LIVRO][LF_CRDPCTR] := aNfItem[nItem][IT_LIVRO][LF_VALICM] - aNfItem[nItem][IT_LIVRO][LF_VALFECP] - ( aNfItem[nItem][IT_LIVRO][LF_BASEICM] * ( aNfItem[nItem][IT_PRD][SB_B1CATRI] / 100)  )
            EndIf
        EndIf
    Else
        //Função responsavel por gravar referencias com base no configurador        
        CredPres(aNFCab,aNfItem,nItem,aSX6,cMvEstado,cExecuta,TRIB_ID_PRES_CARGA,cProdLeite)
    Endif
Elseif cExecuta == "4" 
    //Credito Outorgado - GO Inc.III, Art 11 Anexo IX - RCTE-GO/97
    IF !lTribOut
        If cMvEstado$"GO" .And. aNFCab[NF_OPERNF]=='S' .And. SubStr(aNfItem[nItem][IT_LIVRO][LF_CFO],1,1) $ "6" .And.;
            aNFItem[nItem][IT_TS][TS_CONSUMO]$"N" .And. aNFItem[nItem][IT_TS][TS_CROUTGO]>0        

            If aSX6[MV_RNDICM]
                aNfItem[nItem][IT_LIVRO][LF_CROUTGO]:= Round((aNfItem[nItem][IT_BASEICM] * aNFItem[nItem][IT_TS][TS_CROUTGO]) / 100,2)
            Else
                aNfItem[nItem][IT_LIVRO][LF_CROUTGO]:= NoRound((aNfItem[nItem][IT_BASEICM] * aNFItem[nItem][IT_TS][TS_CROUTGO]) / 100,2)
            EndIf
        Endif        
    Else
        CredOut(aNFCab,aNfItem,nItem,aSX6,cMvEstado)
    Endif
Endif

Return


/*/{Protheus.doc} CRDConvRf 
	(Função responsavel por converter alteração de referencia legado em referencia do configurador)
	
	@author Rafael Oliveira
    @since 03/12/2020
    @version 12.1.27

	@param:	
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado	
	ccampo -> Campo que esta sendo alterado	

	/*/
Function CRDConvRf(aNfItem, nItem, ccampo, nExecuta)
 Local cCampoConv := ""
 Local cCmpRef    := ""

If nExecuta == 1
    cCmpRef := "IT_CRPREMG|LF_CRPRESP|LF_CROUTSP|LF_CREDPRE|LF_CRDPRES|IT_CRPRESC|IT_CRPRSIM|IT_CRPRECE|IT_CRPREPR|LF_CRPRERO|IT_CRPREPE"
Elseif nExecuta == 2
    cCmpRef := "LF_CRPRST"
ElseIF nExecuta == 3
    cCmpRef := "LF_CRDPCTR"
ElseIF nExecuta == 4
    cCmpRef :="IT_CPPRODE"
Endif

IF cCampo $ cCmpRef
    cCampoConv := "TG_IT_VALOR"		
Elseif cCampo == "LF_BASECPR"	
    cCampoConv := "TG_IT_BASE"				
Endif	

Return cCampoConv


/*/{Protheus.doc} CredPres
 Função responsavel por gravar referencias com base no configurador

 	@author Rafael Oliveira
    @since 03/12/2020
    @version 12.1.27

	@param:	
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado	
	cMvEstado -> Estado
    cExecuta    -> Identifica calculo
    /*/
Static Function CredPres(aNFCab,aNfItem,nItem,aSX6,cMvEstado,cExecuta,Id,cProdLeite)
Local nPosTrG := 0

IF cExecuta == '1' // Prodepe Pernambuco
    If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_PRODEPE})) > 0 
        
        //Preenche Tipo de Credito presumido para PE mesmo que nota seja não icentivada
        aNfItem[nItem][IT_LIVRO][LF_TPPRODE]    := aNFItem[nItem][IT_TS][TS_TPPRODE]        
        aNfItem[nItem][IT_LIVRO][LF_CPPRODE]  	:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]
        aNfItem[nItem][IT_CPPRODE]          	:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]

    EndIf

    //ICMS de todos Estados
    If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_PRES_ICMS})) > 0        
    
        Do Case                 
            Case cMvEstado == "MG"
                aNfItem[nItem][IT_LIVRO][IT_CRPREMG] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]
            Case cMvEstado == "SP"                
                aNfItem[nItem][IT_LIVRO][LF_CRPRESP] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]
                //CREDITO OUTORGADO - SP -Relativo a entrada de carnes e demais produtos comestiveis.
                If Substr(aNfItem[nItem][IT_POSIPI],1,4) $ aSX6[MV_CROUTSP] .And. aNFCab[NF_UFDEST]=="SP" .And. aNFCab[NF_UFORIGEM]=="SP" 
                    aNfItem[nItem][IT_LIVRO][LF_CROUTSP] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]
                Endif
            Case cMvEstado == "RS"
                aNfItem[nItem][IT_LIVRO][LF_CREDPRE] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]
                aNfItem[nItem][IT_CREDPRE] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]
                
                IF cProdLeite == "1"
                    aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]
                Endif
            Case cMvEstado == "SC"
                aNfItem[nItem][IT_CRPRESC] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]                
                If aNFCab[NF_SIMPNAC]=="1"
                    aNfItem[nItem][IT_CRPRSIM] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR] 
                    aNfItem[nItem][IT_LIVRO][LF_CRPRSIM] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR] 
                Endif
            Case cMvEstado=="CE"
                aNfItem[nItem][IT_CRPRECE] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]
            Case cMvEstado == "PR"
                aNfItem[nItem][IT_CRPREPR] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]
                aNfItem[nItem][IT_LIVRO][LF_CRPREPR] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]
                aNfItem[nItem][IT_LIVRO][LF_CPRESPR] := aNfItem[nItem][IT_CPRESPR]
            Case cMvEstado == "RO"
                aNfItem[nItem][IT_LIVRO][LF_CRPRERO] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]
            Case cMvEstado == "PE"
                aNfItem[nItem][IT_CRPREPE]  := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]
                aNfItem[nItem][IT_LIVRO][LF_CRPREPE] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]            
            otherwise //Generico                
                aNfItem[nItem][IT_LIVRO][LF_BASECPR] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_BASE]                
        EndCase
        
        // Referencias comuns para estados
        IF cMvEstado <> "RS"               
            aNfItem[nItem][IT_LIVRO][LF_CRDPRES] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]
        Endif        
    Endif
Elseif cExecuta == '2'

    If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_PRES_ST})) > 0        
        aNfItem[nItem][IT_LIVRO][LF_CRPRST]	:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]        
    Endif

Elseif cExecuta == '3'

    If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_PRES_CARGA})) > 0        
        aNfItem[nItem][IT_LIVRO][LF_CRDPCTR] 	:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]        
    Endif

Endif

Return 

/*/{Protheus.doc} CredOut
 Função responsavel por gravar referencias com base no configurador

 	@author Rafael Oliveira
    @since 03/12/2020
    @version 12.1.27

	@param:	
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado	
	cMvEstado -> Estado
    cExecuta    -> Identifica calculo
    /*/
Static Function CredOut(aNFCab,aNfItem,nItem,aSX6,cMvEstado)
Local nPosTrG := 0

If (nPosTrG := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_CRDOUT})) > 0        
    IF cMvEstado == "SP"
        aNfItem[nItem][IT_CROUTSP]:= 0
        If Substr(aNfItem[nItem][IT_POSIPI],1,4) $ aSX6[MV_CROUTSP] .And. aNFCab[NF_UFDEST]=="SP" .And. aNFCab[NF_UFORIGEM]=="SP" .And. aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR] > 0
            aNfItem[nItem][IT_CROUTSP]:= aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]            
        Endif
        aNfItem[nItem][IT_LIVRO][LF_CROUTSP] := aNfItem[nItem][IT_CROUTSP]
    ElseIF cMvEstado == "GO"
        //Credito Outorgado - GO Inc.III, Art 11 Anexo IX - RCTE-GO/97
        If aNFCab[NF_OPERNF]=='S' .And. SubStr(aNfItem[nItem][IT_LIVRO][LF_CFO],1,1) $ "6" .And. aNFItem[nItem][IT_TS][TS_CONSUMO]$"N" .And. aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR] > 0
            aNfItem[nItem][IT_LIVRO][LF_CROUTGO] := aNfItem[nItem][IT_TRIBGEN][nPosTrG][TG_IT_VALOR]
        Endif
    Endif
Endif

Return
