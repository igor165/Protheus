#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ720AlPrd
Calcula o valor do IPI para apresentar na tela de itens

@type 		Function
@author 	Bruno Almeida
@since 		31/05/2019
@version 	P12
@param		
@return  	Numerico, Valor do IPI
/*/
//-------------------------------------------------------------------
Function LJ720AlPrd()

Local aArea			:= {}	//Guarda a area atual
Local aAreaSA1		:= {}	//Guarda a area do SA1
Local nPrcVenda 	:= 0	//Preco de venda do produto
Local nVlrMerc 		:= 0	//Valor total da mercadoria (quantidade x preco unitario)
Local nDescontos 	:= 0	//Desconto no item
Local nValIpi		:= 0	//Valor de IPI

If TRB->TRB_VALIPI > 0 .AND. M->TRB_QUANT <> TRB->TRB_QUANT .AND. ExistFunc('LJ720GetPd')

	aArea		:= GetArea()
	aAreaSA1	:= SA1->(GetArea())

    cCdFl := LJ720GetPd()[1]
    cCdCli := LJ720GetPd()[2]
    cCdLj := LJ720GetPd()[3]

	SA1->(DbSetOrder(1))
	If SA1->(DbSeek( FWxFilial("SA1",cCdFl) + cCdCli + cCdLj ) )

		//Inicializa a funcao fiscal
		MaFisSave()
		MaFisEnd()
		MaFisIni(SA1->A1_COD,;		// 1-Codigo Cliente/Fornecedor
				SA1->A1_LOJA,;		// 2-Loja do Cliente/Fornecedor
				"C",;				// 3-C: 
				"D",;				// 4-Tipo da NF
				SA1->A1_TIPO,;		// 5-Tipo do Cliente/Fornecedor
				Nil,;
				Nil,;
				Nil,;
				Nil,;
				"MATA461")
				
		nDescontos := ( ( (TRB->TRB_VLRDES + TRB->TRB_VRDESP) / TRB->TRB_QTDORI ) * TRB->TRB_QUANT )
		
		nVlrMerc  := ( TRB->TRB_VLRTOT + nDescontos )
		nPrcVenda := ( ( TRB->TRB_VLRTOT + nDescontos ) / TRB->TRB_QUANT )
		
		//Agrega os itens para a funcao fiscal
		MaFisAdd(TRB->TRB_CODPRO,;  		// 01-Codigo do Produto ( Obrigatorio )
					TRB->TRB_TES,;  		// 02-Codigo do TES ( Opcional )
					M->TRB_QUANT,;			// 03-Quantidade ( Obrigatorio )
					nPrcVenda,;     		// 04-Preco Unitario ( Obrigatorio )
					nDescontos,;    		// 05-Valor do Desconto ( Opcional )
					"",;            		// 06-Numero da NF Original ( Devolucao/Benef )
					"",;            		// 07-Serie da NF Original ( Devolucao/Benef )
					0,;             		// 08-RecNo da NF Original no arq SD1/SD2
					0,;			      		// 09-Valor do Frete do Item ( Opcional )
					0,;    					// 10-Valor da Despesa do item ( Opcional )
					0,;     				// 11-Valor do Seguro do item ( Opcional )
					0,;             		// 12-Valor do Frete Autonomo ( Opcional )
					nVlrMerc,;      		// 13-Valor da Mercadoria ( Obrigatorio )
					0)              		// 14-Valor da Embalagem ( Opiconal )	
					
		nValIpi := MaFisRet(,"NF_VALIPI")

		MaFisEnd()
		MaFisRestore()
		
	Endif

	RestArea(aAreaSA1)
	RestArea(aArea)

EndIf

Return nValIpi

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj720ExDev
Exclui titulo CR referente a taxa da administradora financeira, gerado para compensar a NCC.
USO MATA103 - No momento que a nota de devolução é excluída

@author  Rafael Tenorio da Costa
@since 	 15/04/21
@version 1.0
/*/
//-------------------------------------------------------------------
Function Lj720ExDev()

    Local lRetorno  := .T.
    Local aArea     := GetArea()
    Local aAreaSE1  := SE1->( GetArea() )
    Local aRotAuto  := {}
    Local aErro     := {}
    Local cErro     := ""
    Local cSql      := ""
    Local aTituloCr := {}
    Local nCont     := 0    

	Private lMsHelpAuto     := .T.
	Private lMsErroAuto		:= .F.
    Private lAutoErrNoFile  := .T.  //Define que retorna o erro do MsExecAuto para o array

    If SF1->F1_TIPO == "D" .And. SF1->F1_ORIGLAN == "LO"

        cSql := " SELECT R_E_C_N_O_ RECNOSE1 FROM " + RetSqlName("SE1")
        cSql += " WHERE   E1_FILIAL  = '" + xFilial("SE1") + "'"
        cSql +=     " AND E1_PREFIXO = '" + SF2->F2_PREFIXO + "'"
        cSql +=     " AND E1_NUM     = '" + SF2->F2_DUPL + "'"
        cSql +=     " AND E1_TIPO    = '" + PadR("CR"     , TamSx3("E1_TIPO")[1]   ) + "'"
        cSql +=     " AND E1_ORIGEM  = '" + PadR("LOJA701", TamSx3("E1_ORIGEM")[1] ) + "'"
        cSql +=     " AND D_E_L_E_T_ = ' '"

        aTituloCr := RmiXSql(cSql, "*", /*lCommit*/, /*aReplace*/)

        If Len(aTituloCr) > 0 

            SE1->( DbSetOrder(1) )  //E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
            SE1->( DbGoto( aTituloCr[1][1] ) )

            If !SE1->( Eof() )

                aRotAuto  := {	{"E1_FILIAL"	, SE1->E1_FILIAL	, Nil} ,;
                                {"E1_PREFIXO"	, SE1->E1_PREFIXO	, Nil} ,;
                                {"E1_NUM"	  	, SE1->E1_NUM		, Nil} ,;
                                {"E1_PARCELA" 	, SE1->E1_PARCELA	, Nil} ,;
                                {"E1_TIPO"	 	, SE1->E1_TIPO      , Nil}  }
                

                MSExecAuto( { |x, y| Fina040(x, y) }, aRotAuto, 5)  //Exclusão

                If lMsErroAuto

                    lRetorno := .F.
                    aErro    := GetAutoGRLog()

                    For nCont := 1 To Len(aErro)
                        cErro += AllTrim( aErro[nCont] ) + CRLF
                    Next nCont

                    LjxjMsgErr(cErro, /*cSolucao*/, /*cRotina*/)
                EndIf
            EndIf
        EndIf

    EndIf

    aSize(aTituloCr, 0)
    aSize(aErro    , 0)

    RestArea(aAreaSE1)
    RestArea(aArea)

Return lRetorno