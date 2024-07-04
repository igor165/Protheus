#Include 'Protheus.ch'
/*{Protheus.doc}
Função de compatibilização do release incremental.
Função chamada apartir da rotina RUP_AGR  
Atualiza migração release 12.1.17 para 12.1.23
*/
Function RUP_CMC( )
	
	AjustaSX3()

Return .T.

/*/{Protheus.doc} RUP_CMC25
 Ajuste de dicionário para release 12.1.25
@type function
@version 
@author rafael.voltz
@since 07/04/2020
@param , param_type, param_description
@return return_type, return_description
/*/
Function RUP_CMC25( )
	
	AjustSX125()
    AjustaSX3() //necessario chamar novamente, pois nessa função tem alterações da release 12.1.23 e 12.1.25.
	AjustaSX7125()
 
Return .T.

/*/{Protheus.doc} RUP_CMC30
 Ajuste de dicionário para release 12.1.30
@type function
@version 
@author rafael.voltz
@since 07/04/2020
@param , param_type, param_description
@return return_type, return_description
/*/
Function RUP_CMC30( )
	
    AjustaSX330()
    AjustaSX930()
 
Return .T.

/*/{Protheus.doc} RUP_CMC33
 Ajuste de dicionário para release 12.1.33
@type function
@version 
@author claudineia.reinert
@since 05/03/2020
/*/
Function RUP_CMC33( )
	
	AjustaSX330()
    AjustaSX930()
    AjustSX333()
 
Return .T.

/*/{Protheus.doc} AjustaSX3
 Ajusta SX3 a partir da 12.1.17
@type function
@version 
@author rafael.voltz
@since 07/04/2020
@return return_type, return_description
/*/
Static Function AjustaSX3()
    Local cUsado    := ""
    Local cNaoUsado := ""
	
    If  MPDicInDB()
        cUsado    := "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     " //Usado
        cNaoUsado := "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x       " //Não Usado
    Else 
        cUsado      := "€€€€€€€€€€€€€€ " //usado
        cNaoUsado   := "€€€€€€€€€€€€€€€" //Não Usado
    EndIf

	//Atualiza tamanho 	
	DbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	
	//usado
	fUpdSX3("NN8_QTDRES",   { {"X3_USADO", cUsado} })	
	fUpdSX3("NN8_QTENAF",   { {"X3_USADO", cUsado} })	
	fUpdSX3("NN8_VLRLIQ",   { {"X3_USADO", cUsado} })	
	fUpdSX3("NN8_VALLQT",   { {"X3_USADO", cUsado} })	
	fUpdSX3("NN8_VLRLQT",   { {"X3_USADO", cUsado} })	
	fUpdSX3("NN8_FREFIN",   { {"X3_USADO", cUsado} })	
	fUpdSX3("NN8_SEGFIN",   { {"X3_USADO", cUsado} })	
	fUpdSX3("NN8_DSPFIN",   { {"X3_USADO", cUsado} })	
	fUpdSX3("NN8_DTPAGT",   { {"X3_USADO", cUsado} })			
	fUpdSX3("NK7_FLUIG",    { {"X3_USADO", cNaoUsado} })				
	fUpdSX3("N7C_TIPORD",   { {"X3_USADO", cNaoUsado} })				
	fUpdSX3("NJR_PROMIN",   { {"X3_USADO", cNaoUsado} })				
	fUpdSX3("NJR_STSMIN",   { {"X3_USADO", cNaoUsado} })				
	fUpdSX3("NK7_COMPRE",   { {"X3_USADO", cNaoUsado} })				
	fUpdSX3("NK7_PAUTA",    { {"X3_USADO", cNaoUsado} })				
	fUpdSX3("NK7_TRIBUT",   { {"X3_VALID", ''} })				
	fUpdSX3("DX6_DESBAL",   { {"X3_RELACAO", 'IIF(!INCLUI,Posicione("DX5",1,M->DX6_FILIAL+M->DX6_CODBAL,"DX5_DESCRI")," ")'}, {"X3_INIBRW", 'Posicione("DX5",1,DX6->DX6_FILIAL+DX6->DX6_CODBAL,"DX5_DESCRI")'} })					
	fUpdSX3("ND1_VLUFIN",   { {"X3_USADO", cNaoUsado} })				
	fUpdSX3("ND1_VLUDEM",   { {"X3_USADO", cNaoUsado} })				
	fUpdSX3("N9A_VLUDPR",   { {"X3_USADO", cNaoUsado} })				
	fUpdSX3("N9A_VLTDPR",   { {"X3_USADO", cNaoUsado} })				
	fUpdSX3("N9A_VLUDEM",   { {"X3_USADO", cNaoUsado} })				
    fUpdSX3("N9A_VLTDEM",   { {"X3_USADO", cNaoUsado} })				
	fUpdSX3("N9A_VLTIMP",   { {"X3_USADO", cNaoUsado} })				
	fUpdSX3("N89_VRIMP",    { {"X3_USADO", cNaoUsado} })				
    fUpdSX3("N79_DESOPE",   { {"X3_TAMANHO", 40} })				
    fUpdSX3("NN7_TIPO",     { {"X3_VALID", 'Pertence("1/2/3")'}, {"X3_CBOX", '1=Previsão;2=Pagamento;3=Despesa'}, {"X3_CBOXSPA", '1=Previsión;2=Pago;3=Gasto'} , {"X3_CBOXENG", '1=Estimation;2=Payment;3=Expense'} })				
	fUpdSX3("NN7_NOMFAV",   { {"X3_RELACAO", 'If(Inclui," ",POSICIONE("NJ0",1,XFILIAL("NJ0")+ NN7->(NN7_CODFAV+NN7_LOJFAV),"NJ0_NOME"))'} })				    	
	fUpdSX3("N84_PROVIS",   { {"X3_USADO", cNaoUsado} })	
	fUpdSX3("NCS_MESEMB", 	{ {"X3_PICTURE", "@R 9999/99"} })						
    
Return  Nil	

/*/{Protheus.doc} AjustSX125
 Ajusta SX1 na release 12.1.25
@type function
@version 
@author rafael.voltz
@since 07/04/2020
@return return_type, return_description
/*/
Static Function AjustSX125()
	
    Local aPerguntes := {"OGA262", "OGA261A", "OGA450A1", "OGC004"}
    Local nX   := 0    
	//Atualiza tamanho 	
	DbSelectArea("SX1")
	SX1->(dbSetOrder(1))
	/* Exclusão dos Perguntes com ordem de apenas 1 dígito, pois foi alterado na ATUSX para 2 e gerou duplicidade */
	For nX := 1 To len(aPerguntes)
        If SX1->(DbSeek(aPerguntes[nX]))
            While SX1->(!Eof()) .AND. ALLTRIM(SX1->X1_GRUPO) == aPerguntes[nX]
                If Len(alltrim(SX1->X1_ORDEM)) == 1
                    RecLock("SX1")
                    SX1->(dbDelete())        
                    SX1->(MsUnlock())
                EndIf
                SX1->(dbSkip())
            EndDo
        EndIf
    Next nX

Return  Nil	

/*/{Protheus.doc} AjustaSX7125
 Ajusta SX7 na realese 12.1.25
@type function
@version 
@author rafael.voltz
@since 07/04/2020
@return return_type, return_description
/*/
Static Function AjustaSX7125()
			
	 // Alterar gatilho campo N8w_moeda 		
	DbSelectArea("SX7")
	DbSetOrder(1)
	If SX7->(dbSeek('N8W_MOEDA'+'001'))
		RecLock("SX7", .F. )
		If X7_REGRA = "OGA820DMOE(M->N8W_MOEDA)"
			Replace X7_REGRA With "OGA880DMOE(M->N8W_MOEDA)"
		endif
		SX7->(MsUnLock())
	endif
		
return Nil   

/*/{Protheus.doc} AjustaSX330
Ajusta SX3 na realease 12.1.30
@type function
@version 
@author rafael.voltz
@since 07/04/2020
@return return_type, return_description
/*/
Static Function AjustaSX330()
	
	DbSelectArea("SX3")
	SX3->(dbSetOrder(2)) 

	fUpdSX3("NJJ_CODCTR", { {"X3_F3", 'NJJCTR'} })				
	fUpdSX3("NJM_CODCTR", { {"X3_F3", 'NJJCTR'} })
	fUpdSX3("NJM_ITEM",   { {"X3_VISUAL", 'A'} })	
	fUpdSX3("NJM_SEQPRI", { {"X3_VISUAL", 'A'} })	
	fUpdSX3("NJR_CODEMB", { {"X3_FOLDER", '6'} })	
	fUpdSX3("NJR_DESEMB", { {"X3_FOLDER", '6'} })	
	fUpdSX3("NJR_TIPEMB", { {"X3_FOLDER", '5'} })	
	fUpdSX3("NJR_STSASS", { {"X3_VISUAL", 'V'} })	
	fUpdSX3("NJR_STSFIS", { {"X3_VISUAL", 'V'} })	
	fUpdSX3("NJR_STSFIN", { {"X3_VISUAL", 'V'} })	
	fUpdSX3("NJR_STSEST", { {"X3_VISUAL", 'V'} })	
	fUpdSX3("NJR_UM2PRO", { {"X3_TITULO", 'Unid.Med.2'  }, {"X3_DESCRIC", 'Unidade de Medida 2' }, {"X3_FOLDER", '2' } })		
	fUpdSX3("NJR_QTDUM2", { {"X3_TITULO", 'Quant. 2 UM' }, {"X3_DESCRIC", 'Quantidade 2 UM' },     {"X3_FOLDER", '2' } })		
	fUpdSX3("NJR_AGGPRV", { {"X3_FOLDER", '4'}, {"X3_VALID", ""} })	
	fUpdSX3("NJR_BCOPRV", { {"X3_FOLDER", '4'} })	
	fUpdSX3("NJR_BOLSA",  { {"X3_FOLDER", '4'} })	
	fUpdSX3("NJR_CLVL",   { {"X3_FOLDER", '4'} })	
	fUpdSX3("NJR_CTAPRV", { {"X3_FOLDER", '4'} })	
	fUpdSX3("NJR_DESMOF", { {"X3_FOLDER", '4'} })	
	fUpdSX3("NJR_DESMOR", { {"X3_FOLDER", '4'} })	
	fUpdSX3("NJR_DIASF",  { {"X3_FOLDER", '4'} })	
	fUpdSX3("NJR_DIASR",  { {"X3_FOLDER", '4'} })	
	fUpdSX3("NJR_ITVDAP", { {"X3_FOLDER", '4'} })	
	fUpdSX3("NJR_MOEDAF", { {"X3_FOLDER", '4'} })	
	fUpdSX3("NJR_MOEDAR", { {"X3_FOLDER", '4'} })	
	fUpdSX3("NJR_OPERAC", { {"X3_FOLDER", '4'} })	
	fUpdSX3("NJR_TRANSF", { {"X3_FOLDER", '4'} })	
	fUpdSX3("NJR_VENDED", { {"X3_FOLDER", '4'} })	
	fUpdSX3("NJR_MSGNFS", { {"X3_FOLDER", '5'} })	
	fUpdSX3("NJR_BCOPRV", { {"X3_VALID", 'existcpo("NN0",FwFldGet("NJR_CODENT")+FwFldGet("NJR_BCOPRV"))'}}) 		
	fUpdSX3("NJR_CTAPRV", { {"X3_VALID", ""} })		
	fUpdSX3("NJK_TIPREG", { {"X3_ORDEM", "05"}, {"X3_TITULO", "Nível"}, {"X3_DESCRIC", "Nível Grupo Desconto"} })	
	fUpdSX3("NJK_CODDES", { {"X3_ORDEM", "06"} })		
    fUpdSX3("NJK_DESDES", { {"X3_ORDEM", "07"} })
    fUpdSX3("NJK_OBRGT" , { {"X3_ORDEM", "08"} })
    fUpdSX3("NJK_BASDES", { {"X3_ORDEM", "09"} })
    fUpdSX3("NJK_PERDES", { {"X3_ORDEM", "10"} })
    fUpdSX3("NJK_READES", { {"X3_ORDEM", "11"} })
    fUpdSX3("NJK_QTDDES", { {"X3_ORDEM", "12"} })
    fUpdSX3("NJK_DESRES", { {"X3_ORDEM", "13"} })
    fUpdSX3("NJK_RESINF", { {"X3_ORDEM", "14"} })
	fUpdSX3("NCS_MESEMB", { {"X3_PICTURE", "@R 9999/99"} })

return nil

/*/{Protheus.doc} fUpdSX3
Função para atualizar a tabela SX3
@type function
@version 
@author rafael.voltz
@since 07/04/2020
@param cFieldSearch, character, Nome do campo a ser pesquisado
@param aFieldX3, array, Campo na SX3 e conteúdo
/*/
Static Function fUpdSX3(cFieldSearch, aFieldX3)
	Local nX := 0
	//ja esta posicionado e ordenado na SX3 na função chamadora

	If SX3->(DbSeek(cFieldSearch))
		RecLock("SX3")
		
		For nX := 1 to Len(aFieldX3)
			SX3->&(aFieldX3[nX,1]) := aFieldX3[nX,2]
		Next nX

		SX3->(MsUnlock())
	EndIf

Return 

/*/{Protheus.doc} AjustaSX930
    Função para ajustar a SX9 
    @type  Static Function
    @author user
    @since 01/10/2020
    @version version    
    /*/
Static Function AjustaSX930()
    
	DbSelectArea("SX9")
    SX9->(dbSetOrder(2)) 
	
    If SX9->(DbSeek("NN3"+"SB1"))
        While SX9->(X9_CDOM + X9_DOM) == "NN3"+"SB1"
            If ALLTRIM(SX9->X9_EXPCDOM) == "NN3_UM1PRO" .AND. ALLTRIM(SX9->X9_EXPDOM) == "B1_UM"
                RecLock("SX9",.F.)
                SX9->(dbdelete())
                SX9->(MsUnlock())
                exit
            EndIf
            SX9->(dbSkip())
        EndDo
    EndIf
Return 

/*/{Protheus.doc} AjustSX333
Ajusta SX3 na realease 12.1.33
@type function
@version 
@author claudineia.reinert
@since 05/03/2021
/*/
Static Function AjustSX333()
	
	DbSelectArea("SX3")
	SX3->(dbSetOrder(2)) 
	
	fUpdSX3("N9A_CODENT",   { {"X3_RELACAO", 'M->NJR_CODENT'} })	
	fUpdSX3("N9A_LOJENT",   { {"X3_RELACAO", 'M->NJR_LOJENT'} })	
	fUpdSX3("N9A_CODFIN",   { {"X3_RELACAO", 'M->NJR_CODFIN'} })	
	fUpdSX3("N9A_TIPCLI",   { {"X3_RELACAO", 'M->NJR_TIPOCL'} })	

	fUpdSX3("NP9_FORMUV",   { {"X3_RELACAO", 'If(!INCLUI,AGR960MFOR(NP9->NP9_FORMUL),"")'} })

	fUpdSX3("DX0_FILIAL", { {"X3_ORDEM", "01"} })	
	fUpdSX3("DX0_CODROM", { {"X3_ORDEM", "02"} })	
	fUpdSX3("DX0_ITEM "	, { {"X3_ORDEM", "03"} })	
	fUpdSX3("DX0_FARDAO", { {"X3_ORDEM", "04"} })	
	fUpdSX3("DX0_SAFRA ", { {"X3_ORDEM", "05"} })
	fUpdSX3("DX0_PRDTOR", { {"X3_ORDEM", "06"} })
	fUpdSX3("DX0_LOJA"	, { {"X3_ORDEM", "07"} })
	fUpdSX3("DX0_FAZ"	, { {"X3_ORDEM", "08"} })
	fUpdSX3("DX0_CODPRO", { {"X3_ORDEM", "09"} })
	fUpdSX3("DX0_CODVAR", { {"X3_ORDEM", "10"} })
	fUpdSX3("DX0_TALHAO", { {"X3_ORDEM", "11"} })
	fUpdSX3("DX0_RATEIO", { {"X3_ORDEM", "12"} })
	fUpdSX3("DX0_PSLIQU", { {"X3_ORDEM", "13"} })
	fUpdSX3("DX0_CODUNB", { {"X3_ORDEM", "14"} })
	fUpdSX3("DX0_PSFISC", { {"X3_ORDEM", "15"} })
	fUpdSX3("DX0_CODUNI", { {"X3_ORDEM", "16"} })
	fUpdSX3("DX0_TIPROM", { {"X3_ORDEM", "17"} })
	fUpdSX3("DX0_NRROM ", { {"X3_ORDEM", "18"} })
	fUpdSX3("DX0_BOLETI", { {"X3_ORDEM", "19"} })			

return nil
