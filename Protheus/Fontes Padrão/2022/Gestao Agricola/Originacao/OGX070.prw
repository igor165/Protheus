#INCLUDE "PROTHEUS.CH"
#INCLUDE "OGA070.CH" 

static __cMVIncote  := SUPERGETMV("MV_AGRO034",.F.,"") //Incoterms que não calculam Despesa Logística
static __lIntGFE    := SuperGetMv("MV_INTGFE",,.F.)   //Integração GFE    
static __lAutomato  := isBlind()

/*/{Protheus.doc} OGX070CDEM()
    Calcula preço demonstrativo para todas as cadências e regras fiscais para o contrato o modelo passado
    @type  Function
    @author user
    @since date
    @version version
    @param  cFilCtr     char    Filial do contrato
    @param  cContrato   char    Contrato
    @param  lcalcGFE    logical Indica se chama GFE para cálculo das despesas logísticas    
    @param  oModel      object  Objeto model do contrato
    @return .T.    
    @example
    (examples)
    @see (links_or_references)
    /*/ 
 Function OGX070CDEM(cFilCtr as char, cContrato as char, lcalcGFE as logical, oModel as object)        
    Local oModelNJR  as object     
    Local oModelN9A  as object
    Local oModelNNY  as object
    Local nIt        as numeric
    Local nA         as numeric
    Local aRetDem    as array
    Local nCotacao   as numeric    
    Local aAreaNJR   as array
    Local aAreaNNY   as array
    Local aAreaN9A   as array	

    Private _lShowHelp    := .T. 
    Default cFilCtr   := ""
    Default cContrato := ""
    Default lcalcGFE  := .F.
    Default oModel    := nil

    aAreaNJR := NJR->(GetArea())
    aAreaNNY := NNY->(GetArea())
    aAreaN9A := N9A->(GetArea())

    If ValType(oModel) == "O"        
        oModelNNY  := oModel:GetModel( "NNYUNICO" )
        oModelNJR  := oModel:GetModel( "NJRUNICO" )                 
        oModelN9A  := oModel:GetModel( "N9AUNICO" )       

       //atualiza regras fiscais
        for nIt := 1 to oModelNNY:Length()
            oModelNNY:GoLine(nIt)
    
            nA := 1 //reset value
            while nA <= oModelN9A:Length()
                oModelN9A:GoLine(nA)

                If oModelN9A:GetValue("N9A_VLT2MO") == 0
                   nA++
                   loop 
                EndIf
                
                iif(oModelN9A:GetValue("N9A_VLRTAX") > 0, nCotacao := oModelN9A:GetValue("N9A_VLRTAX"), nCotacao := 1)                

                aRetDem :=  OGX070CALC( oModelNJR:GetValue("NJR_FILIAL"),    ;
                                        oModelN9A:GetValue("N9A_FILORG"),    ;
                                        oModelN9A:GetValue("N9A_CODCTR"),    ; 
                                        oModelN9A:GetValue("N9A_ITEM"),      ;
                                        oModelN9A:GetValue("N9A_SEQPRI"),    ;
                                        oModelNJR:GetValue("NJR_CODSAF"),    ;
                                        oModelN9A:GetValue("N9A_CODENT"),    ;
                                        oModelN9A:GetValue("N9A_LOJENT"),    ;
                                        oModelN9A:GetValue("N9A_ENTENT"),    ;
                                        oModelN9A:GetValue("N9A_LJEENT"),    ;
                                        oModelNJR:GetValue("NJR_CODPRO"),    ;
                                        oModelN9A:GetValue("N9A_QUANT"),     ;
                                        oModelN9A:GetValue("N9A_VLT2MO") * nCotacao,     ;
                                        oModelNJR:GetValue("NJR_UM1PRO"),    ;
                                        oModelNJR:GetValue("NJR_INCOTE"),    ; 
                                        oModelNJR:GetValue("NJR_TIPMER"),    ;
                                        oModelNJR:GetValue("NJR_MOEDA"),     ;
                                        lcalcGFE                             ;
                                        )
                oModelN9A:SetValue("N9A_VLUDES", aRetDem[1] ) //Valor unitário despesas
	            oModelN9A:SetValue("N9A_VLTDES", aRetDem[2] ) //Valor total despesas	            
                nA++
            EndDo
        Next nIt

    Else        
        
	    NJR->(dbSetOrder(1))
        NNY->(dbSetOrder(1))
        N9A->(dbSetOrder(1))
        if NJR->(dbSeek(cFilCtr+cContrato)) //temos cadências
            //Lista as Previsão de entrega
            if NNY->(dbSeek(cFilCtr+cContrato)) //temos cadências
                while NNY->(!Eof()) .And. alltrim(NNY->(NNY_FILIAL+NNY_CODCTR)) == alltrim(cFilCtr+cContrato)                    
                    //busca as regras fiscais                    
                    if N9A->(dbSeek(cFilCtr+cContrato+NNY->NNY_ITEM)) //temos regras fiscais
                        while N9A->(!Eof()) .And. alltrim(N9A->(N9A_FILIAL+N9A_CODCTR+N9A_ITEM)) == alltrim(cFilCtr+cContrato+NNY->NNY_ITEM)
                            If N9A->N9A_VLT2MO == 0                                
                                N9A->(dbSkip()) 
                                loop
                            EndIf

                            iif(N9A->N9A_VLRTAX > 0, nCotacao := N9A->N9A_VLRTAX, nCotacao := 1)

                            aRetDem := OGX070CALC(  NJR->NJR_FILIAL,    ;
                                                    N9A->N9A_FILORG,    ;
                                                    N9A->N9A_CODCTR,    ; 
                                                    N9A->N9A_ITEM,      ;
                                                    N9A->N9A_SEQPRI,    ;
                                                    NJR->NJR_CODSAF,    ;
                                                    N9A->N9A_CODENT,    ;
                                                    N9A->N9A_LOJENT,    ;
                                                    N9A->N9A_ENTENT,    ;
                                                    N9A->N9A_LJEENT,    ;
                                                    NJR->NJR_CODPRO,    ;
                                                    N9A->N9A_QUANT,     ;
                                                    N9A->N9A_VLT2MO * nCotacao,     ;
                                                    NJR->NJR_UM1PRO,    ;
                                                    NJR->NJR_INCOTE,    ; 
                                                    NJR->NJR_TIPMER,    ;
                                                    NJR->NJR_MOEDA,     ;
                                                    lcalcGFE            ;
                                                    )                            
                            RecLock('N9A',.f.)
                                N9A->N9A_VLUDES := aRetDem[1] //Valor unitário despesas
                                N9A->N9A_VLTDES := aRetDem[2] //Valor total despesas                                
                            N9A->(MsUnLock())		    	
                            N9A->(dbSkip()) 
                        EndDo
                    EndIf
                    NNY->(dbSkip()) 
                EndDo
            EndIf
        EndIf                                            
    EndIf

    RestArea(aAreaNJR)
    RestArea(aAreaNNY)
    RestArea(aAreaN9A)

    FwFreeObj(aAreaNJR)
    FwFreeObj(aAreaNNY)
    FwFreeObj(aAreaN9A)
    FwFreeObj(aRetDem)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} OGX070CALC
Função de cálculo do preço demonstrativo e das despesas
@author  rafael.voltz
@since   20/08/2018
@version version
@param cFilCtr      char    Filial do contrato
@param cFilOrg      char    Filial Origem da Regra Fiscal
@param cContrato    char    Contrato 
@param cCodCad      char    Código da cadência
@param cCodRegFis   char    Código da Regra Fiscal
@param cSafra       char    Código da safra
@param cCodEnt      char    Código da Entidade Cliente
@param cLojEnt      char    Loja da Entidade Cliente
@param cEntEnt      char    Código da Entidade de Entrega
@param cLjEEnt      char    Loja da Entidade de Entrega
@param cCodPro      char    Código do produto
@param nQtd         numeric Quantidade da regra fiscal
@param nVlrFix      numeric Valor fixado
@param cUmProd      char    Unidade de medida do produto
@param cTipIncote   char    Tipo INCOTERM
@param cTipoMerc    char    Tipo de Mercado
@param nMoedaCtr    numeric Moeda do Contrato
@param lcalcGFE     logical Indica se chama GFE para cálculo das despesas logísticas

@return Array{
                nUnitDesp  numeric  Valor unitário das despesas
                nTotDesp   numeric  Valor total das despesas
                nUnitDem   numeric  Valor unitário demonstrativo
                nTotDem    numeric  Valor total demonstrativo
            }
/*/
//-------------------------------------------------------------------
Function OGX070CALC(cFilCtr as char, cFilOrg as char, cContrato as char, cCodCad as char, cCodRegFis as char, cSafra as char, cCodEnt as char, cLojEnt as char, cEntEnt as char, cLjEEnt as char, cCodPro as char, nQtd as numeric, nVlrFix as numeric, cUmProd as char, cTipIncote as char, cTipoMerc as char, nMoedaCtr as numeric, lcalcGFE as logical)
    Local aRetFrete  as array
    Local aAreaNJ0   as array  
    Local aAreaSA2   as array   
    Local aAreaGU3   as array   
    Local aAreaNJU   as array
    Local aAreaNNY   as array
    Local aAreaNJ7   as array   
    Local aSM0       as array
    Local nUnitDem   as numeric
    Local nTotDem    as numeric
    Local nUnitDesp  as numeric
    Local nTotDesp   as numeric
    Local nPos       as numeric
    Local nValFrete  as numeric
    Local nFatorConv as numeric
    Local nQtdRet    as numeric
    Local nQtdConv   as numeric
    Local nQtUM      as numeric    
    Local nFatRed    as numeric     
    Local cCodDes    as char  
    Local cHoraRef	 as char    
    Local cTpTab 	 as char    
    Local cIndice    as char
	Local cCodRem	 as char
	Local cOperLog	 as char
    Local dDataRef   as date    
    Local lTomaCred	 as logical
    Local nValFreteR as numeric
    Local nCid		 as numeric
    Local cRota		 as char
    Local cRedImp	 as char
    Local aCriterios[14]
    Local aRetIcm	 := {}
    Local cCdClFr  	 := POSICIONE("GUK", 1, FWxFilial("GUK") + PADR(AllTrim(cCodPro), TamSX3("GUK_ITEM")[1]), "GUK_CDCLFR")

    aAreaNJ0   := NJ0->(GetArea())
    aAreaSA2   := SA2->(GetArea())
    aAreaGU3   := GU3->(GetArea())
    aAreaNJU   := NJU->(GetArea())
    aAreaNNY   := NNY->(GetArea())
    aAreaNJ7   := NJ7->(GetArea())
    aSM0	   := FwLoadSM0()
    nUnitDem   := 0
    nTotDem    := 0
    nUnitDesp  := 0
    nTotDesp   := 0
    nPos       := 0  
    nValFrete  := 0
    nFatorConv := 1
    nQtdRet    := 0
    nQtUM      := 0        
    nFatRed	   := 1
    nValFreteR := 0
    nQtdConv   := nQtd
    cCodDes    := ""    
    cTpTab	   := "4" /*Frete Referência*/
    cTpRef     := "3" //tipo de frete referência
    lTomaCred  := iif(SUPERGETMV("MV_GFECRIC",.F.,"2") = "1",.T.,.F.) //Toma crédito?	
    cRedImp    := ""

    /* INICIO CÁLCULO DESPESA DE FRETE */
    If !(cTipIncote $ __cMVIncote) .and. __lIntGFE .and. lcalcGFE .and. !FWIsInCallStack('OGA250REA')
        /* DADOS DO EMITENTE - UTILIZA FILIAL ORIGEM DA REGRA FISCAL*/        
        If (nPos := aScan(aSM0, {|x| cFilOrg $ x[2]})) > 0
            cCnpj := aSM0[nPos][18]             

            /* BUSCA CÓDIGO DO GFE */
            cCodRem := POSICIONE("GU3", 11, xFilial("GU3") + cCnpj, "GU3_CDEMIT") //GU3_FILIAL+GU3_IDFED            
        EndIf
        
        if cTipoMerc = '1' //INTERNO
	        /* DADOS DO DESTINATÁRIO - CASO TENHA ENTIDADE ENTREGA ASSUME ELA*/
	        If !Empty(cEntEnt) 
	            cCodEnt := cEntEnt
	            cLojEnt := cLjEEnt
	        EndIf
	
	        NJ0->(dbSetOrder(1))
	        If NJ0->(dbSeek(xFilial("NJ0") + cCodEnt + cLojEnt ))                                
	            /* BUSCA CÓDIGO DO GFE */            
	            cCodDes := POSICIONE("GU3", 11, FWxFilial("GU3") + NJ0->NJ0_CGC, "GU3_CDEMIT") //GU3_FILIAL+GU3_IDFED
	            
	            nCid := POSICIONE("GU3",1,FWxFilial("GU3")+cCodDes,"GU3_NRCID")
	        EndIf
	    else //NJR_TIPMER = 2 EXTERNO
	    
	    	NJ0->(dbSetOrder(1))
	        If NJ0->(dbSeek(xFilial("NJ0") + cCodEnt + cLojEnt ))
	            /* BUSCA CÓDIGO DO GFE */
	            cCodDes := POSICIONE("GU3", 11, FWxFilial("GU3") + NJ0->NJ0_CGC, "GU3_CDEMIT") //GU3_FILIAL+GU3_IDFED
	        EndIf
	    	
	    	//Porto de origem especifiacado ao contrato 
	    	cRota := GETDATASQL("SELECT N7R_CODROT FROM " + RetSqlName("N7R") + " "+;
	    	 					"WHERE N7R_FILIAL = '"+cFilCtr+"' AND N7R_CODCTR = '" + cContrato + "' AND N7R_TIPO = '1' AND D_E_L_E_T_ = ' '" )
	    	
	    	//Caso tenha encontrato uma rota de origem pra este contrato.
	    	if EMPTY(cRota)
	    		//"Ajuda" //"Rota(porto) não encontrada. Despesa logística não será calculada." //"Verifique se ao menos um porto de origem foi informado."
	    		If !__lAutomato .And. _lShowHelp
                    AGRHELP(STR0013, STR0014, STR0015)
                    _lShowHelp := .F.
                EndIf
			//Caso tenha encontrado uma rota para este contrato.
			else
				//encontra o numero da cidade na GU7 a partir do codigo do porto selecionado no contrato.
		    	//Se baseia no primeiro porto do tipo origem encontrado.
		    	nCid := GETDATASQL("SELECT GU7.GU7_NRCID FROM " + RetSqlName("GU7") + " GU7 " +;
								   "INNER JOIN " + RetSqlName("SY9") + " SY9 ON SY9.D_E_L_E_T_ = ' ' "+;
								   "AND SY9.Y9_FILIAL = GU7.GU7_FILIAL " +;
								   "AND SY9.Y9_CIDADE = GU7.GU7_NMCID " +;
								   "WHERE SY9.Y9_COD = '"+ cRota +"' "+;
								   "AND GU7.D_E_L_E_T_ = ' '")
					
				//Caso não tenha encontrado a rota.
				if EMPTY(nCid) .AND. _lShowHelp
					//Cidade do porto não encontrada. Cálculo não será feito.
					//"Ajuda" //"Cidade referente ao porto não encontrada. Despesa logística não será calculada." //"Verifique se a cidade do porto de origem está escrita corretamente."
					AGRHELP(STR0013, STR0016, STR0017)
                    _lShowHelp := .F.
				endIf
			endIf
	    endIf
	    
        /* BUSCA TIPO DE OPERAÇÃO */
        cOperLog := POSICIONE("NJU", 1, xFilial("NJU") + cSafra, "NJU_OPELOG")

        If !Empty(cCodRem) .and. !Empty(cCodDes) .and. !Empty(cOperLog) 
			      	
			dDataRef  := POSICIONE("NNY",1,cFilCtr + cContrato + cCodCad + cCodRegFis,"NNY_DATFIM")
			
			/*aCriterios[1]	: Remetente
			aCriterios[2]	: Destinatário
			aCriterios[3]	: Cidade Origem
			aCriterios[4]	: Cidade Destino
			aCriterios[5]	: Transportador
			aCriterios[6]	: Grupo Transportador
			aCriterios[7]	: Tipo Operação
			aCriterios[8]	: Tipo Veículo
			aCriterios[9]	: Modalidade de Transporte
			aCriterios[10]	: Classificação de Frete*/
				
			aCriterios[1] 	:= cCodRem
			aCriterios[2] 	:= cCodDes
            aCriterios[3] 	:= POSICIONE("GU3",1,FWxFilial("GU3")+cCodRem,"GU3_NRCID")            
            aCriterios[4]	:= nCid
            aCriterios[5]	:= ""
            aCriterios[6]	:= ""
            aCriterios[7]	:= cOperLog
            aCriterios[8] 	:= ""
            aCriterios[9]	:= '2' //Rodoviario
            aCriterios[10] 	:= cCdClFr
            
            aRetFrete := GFETabPrzQbr(aCriterios, dDataRef, cHoraRef, cTpTab, cTpRef)            

            If Len(aRetFrete) > 0    
                If aRetFrete[5] = .T.                
	                
                	//Definindo os valores do ICMS ou ISS
                	If aCriterios[3] != aCriterios[4] //Origem != Destino
		
						aRetIcm := GFEFnIcms(aRetFrete[7][1][2], ;    //Código do transportador
											 cCodRem, ;             //Código do remetente
											 cCodDes, ;	            //Código do destinatario
											 aCriterios[3], ;		//Número da cidade de origem
											 aCriterios[4], ;		//Número da cidade de destino	
											 GW1->GW1_USO, ;	    //Forma de utilização da mercadoria
											 GW8->GW8_TPITEM, ;     //Tipo de item
											 GW8->GW8_CDCLFR, ;     //Classificação de frete
											 GW1->GW1_ICMSDC, ;     //Mercadoria é tributada de ICMS?
											 Posicione("GWN", 1, FWxFilial("GWN") + GW1->GW1_NRROM, "GWN_CDTPOP"),;  //Tipo de Operação do Agrupador do Documento de Carga
											 FWxFilial("GWF"))      //Filial do cálculo - Usado no parâmetro MV_GFECRIC para as exceções das filiais que não tem direito a crédito
							/*aRetIcm[1] := nAliqIcms
							aRetIcm[2] := cTipoAtrib
							aRetIcm[3] := cRedImp
							aRetIcm[4] := tributação presumida*/
							
							cRedImp := aRetIcm[3]
					Else 
						If empty(POSICIONE("GU3",1,XFILIAL("GU3")+aRetFrete[7][1][2],"GU3_PCISS"))
							//aRetIcm[1] := Posicione("GU7", 1, FWxFilial("GU7") + aCriterios[3], "GU7_PCISS") //Busca a aliquota no cadastro de cidades
							aAdd(aRetIcm, Posicione("GU7", 1, FWxFilial("GU7") + aCriterios[3], "GU7_PCISS"))
						else 
							//aRetIcm[1] := (POSICIONE("GU3",1,FWxFilial("GU3")+aRetFrete[7][1][2],"GU3_PCISS"))
							aAdd(aRetIcm, POSICIONE("GU3",1,FWxFilial("GU3")+aRetFrete[7][1][2],"GU3_PCISS"))
						endif
					EndIf
					
					/* Converte Unidade que foi passada para o GFE com o que foi retornado pelo GFE */
					if Len(aRetFrete[7][1]) > 4
		                If Alltrim(aRetFrete[7][1][8]) != Alltrim(cUMProd)
		                    nQtUM := AGRX001(aRetFrete[7][1][8], cUMProd, 1, cCodPro)
		                    aRetFrete[7][1][4] := ( aRetFrete[7][1][4] * nQtUM )
		                EndIf   
					endIf
					
					 if !EMPTY(cRedImp) //Caso tenha redução do imposto
					 	nFatRed := 1 - ( aRetIcm[3]/100 )				 	
					 endif
					
					//Toma credito
					if lTomaCred //Sim, valor vazio
						nValFrete := aRetFrete[7][1][4]
					else //Não, valor com imposto
						nValFrete := aRetFrete[7][1][4] / (1-((aRetIcm[1]/100) * nFatRed))
					endIf
					
					//Caso seja um contrato de mercado externo, converter para a cotação da moeda do contrato antes de gravar.
					If cTipoMerc == "2" //Externo                                        
	                    cIndice   := POSICIONE("NJ7",1,xFilial("NJ7") + AllTrim(Str(nMoedaCtr)), "NJ7_INDICE")                    
	                    nVrIndice := getVlIndic(cIndice, dDataRef)		                
	                    nValFrete := nValFrete / nVrIndice
	                EndIf
	                
                    nTotDesp  := nValFrete * nQtd
                    nUnitDesp := nValFrete
                	
                	NC9->(dbSetOrder(2)) //NC9_FILIAL+NC9_CODCTR+NC9_PRVENT+NC9_REGFIS+NC9_TIPDES 
	                If NC9->(dbSeek(cFilCtr + cContrato + cCodCad + cCodRegFis + "1"))
	                    Reclock("NC9", .F.)
	                    NC9->NC9_UMDESP := cUMProd
	                    NC9->NC9_VLUNPR := nValFrete 
	                    NC9->NC9_VLTOPR := nValFrete * nQtd
	                Else	                    
	                    Reclock("NC9", .T.)
	                    NC9->NC9_FILIAL := cFilCtr
	                    NC9->NC9_CODCTR := cContrato
	                    NC9->NC9_PRVENT := cCodCad
	                    NC9->NC9_REGFIS := cCodRegFis
	                    NC9->NC9_TIPDES := "1"
	                    NC9->NC9_SEQDES := PadL(cValToChar(1), TamSX3("GXS_SEQ")[1], "0")
	                    NC9->NC9_UMDESP := cUMProd
	                    NC9->NC9_VLUNPR := nValFrete
	                    NC9->NC9_VLTOPR := nValFrete * nQtd
	                EndIf
	                NC9->(MsunLock())
	            Elseif _lShowHelp
	            	Help( , , "Ajuda", , aRetFrete[6] + STR0018, 1, 0 ) //"AJUDA"###""
                    _lShowHelp := .F.
	            EndIF
            EndIf
        EndIf        
    EndIf 
    
    NC9->(dbSetOrder(2)) //NC9_FILIAL+NC9_CODCTR+NC9_PRVENT+NC9_REGFIS+NC9_TIPDES 
    If NC9->(dbSeek(cFilCtr + cContrato + cCodCad + cCodRegFis + "1"))        
        If NC9->NC9_VLTORE > NC9->NC9_VLTOPR //se realizado > que previsto, assume realizado
            nUnitDesp := NC9->NC9_VLTORE / nQtd
            nTotDesp  := NC9->NC9_VLTORE
        Else
            nUnitDesp := NC9->NC9_VLUNPR
            nTotDesp  := NC9->NC9_VLTOPR
        EndIf
    EndIf    
	
    /* ATUALIZA POR FIXACAO DA REGRA FISCAL */    
    If TableInDic("ND1")
        fAtuVlrFix(cFilCtr, cContrato, cCodCad, cCodRegFis, nUnitDesp)
    EndIf

    /* FIM CÁLCULO DESPESA DE FRETE */

    /* DEMAIS DESPESAS INCLUIR TRATATIVAS AQUI */

    RestArea(aAreaNJ0)
    RestArea(aAreaSA2)
    RestArea(aAreaGU3)
    RestArea(aAreaNJU)
    RestArea(aAreaNNY)
    RestArea(aAreaNJ7)

    FwFreeObj(aSM0)
    FwFreeObj(aAreaNJ0)
    FwFreeObj(aAreaSA2)
    FwFreeObj(aAreaGU3)    
    FwFreeObj(aAreaNJU)
    FwFreeObj(aAreaNJ7)
    FwFreeObj(aAreaNNY)
    FwFreeObj(aRetFrete)

Return {nUnitDesp, nTotDesp}


/*{Protheus.doc} getVlIndic
Retornar o valor do índice conforme o item do plano de vendas
@author rafael.voltz
@since 05/09/2018
@type function
*/
Static Function  getVlIndic(cIndice, dDataRef) 
	Local nValor     := 0	
    
    nVrIndice := 0
	dbSelectArea("NK0")
	NK0->( dbSetOrder(1) )
	If NK0->(DbSeek(xFilial("NK0") + cIndice ))
		nValor := AgrGetInd( NK0->NK0_INDICE,NK0->NK0_TPCOTA, dDataRef)
	EndIF
	
return nValor

/*{Protheus.doc} AGRGFE003
Grava o valor da despesa logistica vindo do GFE
@author MARCELO.FERRARI
@since 20/10/2018
@type function
@param array - Contem os valores de ICMS, PIS, COFINS e TOTAL DO FRETE
@uso: gfexfunc
*/
function AGRGFE003(aDadosAgro)
    Local nI        := 0
    Local cAliasQry := ""
    Local aAreaNC9  := {}

    for nI := 1 to len( aDadosAgro )
        cSql := "SELECT DISTINCT A1_COD, A1_LOJA, A1_CGC  ,NJ0_CODENT, NJ0_LOJENT  , " + ;
                        " NJJ_FILIAL, NJJ_FILORG, NJJ_CODROM, NJJ_DOCSER, " + ;
                        " NJJ_DOCNUM  ,NJJ_CODCTR, NJJ_CODSAF  ,N9K_CODROM, " + ;
                        " N9K_CODCTR, N9K_ITEMPE, N9K_ITEMRF  " + ;
                "FROM " + RetSqlName("NJJ") + " NJJ " + ;
                "INNER JOIN " + RetSqlName("NJ0") + " NJ0 ON  " + ;
                    " NJJ_CODENT = NJ0_CODENT AND  " + ;
                    " NJJ.D_E_L_E_T_ = NJ0.D_E_L_E_T_  " + ;
                "INNER JOIN " + RetSqlName("SA1") + " SA1 ON   " + ;
                    " NJ0_CODCLI = A1_COD  AND  " + ;
                    " NJ0.D_E_L_E_T_ = SA1.D_E_L_E_T_ " + ;  
                "INNER JOIN " + RetSqlName("N9K") + " N9K ON   " + ;
                    " N9K_CODCTR = NJJ_CODCTR AND   " + ;
                    " N9K_CODROM = NJJ_CODROM AND   " + ;
                    " N9K.D_E_L_E_T_ = NJJ.D_E_L_E_T_   " + ;
                "WHERE 1=1   " + ;
                " AND NJJ_FILIAL = '" + fwxFilial("NJJ")+ "' " + ;
                " AND NJJ_DOCSER = '" + aDadosAgro[nI, 4] + "' " + ;
                " AND NJJ_DOCNUM = '" + aDadosAgro[nI, 5] + "' " + ;
                " AND A1_CGC     = '" + aDadosAgro[nI, 6] + "' " + ;
                " AND NJJ.D_E_L_E_T_ = ' ' "
        
        cAliasQry := GetSqlAll(cSql)

        If !(cAliasQry)->(Eof())  //se encontrou registro, 
        
            If Select("NC9") = 0
                aAreaNC9 = GetArea("NC9")
            Else
                dbSelectArea("NC9")
            EndIf

            NC9->(dbSetOrder(2))

            While !(cAliasQry)->(Eof())   //processa o resultado da consulta
                //Verifica na NC9 se existe o registro para atualizar o valor
                If NC9->( DbSeek( fwxFilial("NC9")+(cAliasQry)->N9K_CODCTR+(cAliasQry)->N9K_ITEMPE+(cAliasQry)->N9K_ITEMRF+"1" ) )
                    Reclock("NC9", .F.)
                        //ACUMULA OS VALORES PARA CADA DOCUMENTO DESTA ENTREGA / REGRA FISCAL
                        NC9->NC9_VLICMR := NC9->NC9_VLICMR + aDadosAgro[nI, 07 ]
                        NC9->NC9_VLPISR := NC9->NC9_VLPISR + aDadosAgro[nI, 08 ]
                        NC9->NC9_CLCOFR := NC9->NC9_CLCOFR + aDadosAgro[nI, 09 ]
                        NC9->NC9_VLTORE := NC9->NC9_VLTORE + aDadosAgro[nI, 10 ]                        
                    NC9->(MsUnLock())
                EndIF
                (cAliasQry)->(dbSkip())
            EndDo

        EndIf
    Next nI

    If !Empty(aAreaNC9)
        RestArea(aAreaNC9)
    EndIf
	(cAliasQry)->(dbCloseArea())

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fAtuVlrFix
Funcao para atualizar os valores demonstrativos das fixacoes
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function fAtuVlrFix(cFilCtr, cContrato, cCodCad, cCodRegFis, nUnitDesp)
 
 Local cAliasQry  := getNextAlias()  

 BeginSql Alias cAliasQry
    SELECT R_E_C_N_O_ RECNO,
           ND1.ND1_QTDE,
           ND1.ND1_FILIAL,
           ND1.ND1_CODCTR,
           ND1.ND1_ITEMPE,
           ND1.ND1_ITEMRF,
           ND1.ND1_SEQCP,
           ND1.ND1_SEQPF,
           ND1.ND1_SEQN9J,
           ND1.ND1_SEQ,
           ND1.ND1_VLUFAT
      FROM %table:ND1% ND1
     WHERE ND1.ND1_FILIAL = %Exp:cFilCtr%       
       AND ND1.ND1_CODCTR = %Exp:cContrato%
       AND ND1.ND1_ITEMPE = %Exp:cCodCad%
       AND ND1.ND1_ITEMRF = %Exp:cCodRegFis%
       AND ND1.%notDel%
 EndSql 

 (cAliasQry)->(dbGotop())
 While (cAliasQry)->(!Eof())    

    If nUnitDesp > 0
        ND1->(dbGoTo((cAliasQry)->RECNO))
        If RecLock("ND1",.F.)            
            ND1->ND1_VLUDES := nUnitDesp
            ND1->(MsUnLock())
        Endif
    Endif

    (cAliasQry)->(dbSkip())
 EndDo
 (cAliasQry)->(dbCloseArea())

Return
