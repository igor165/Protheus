#INCLUDE "protheus.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/** {Protheus.doc} OGX020
  Executa simulação de um pedido para obter o valor dos impostos
@param:	cFilOrig -> Filial de Origem utilizada para cálculo
        cTpDoc 	-> Tipo de Movimento ('E')->Entrada / S saída
		cCliFor	-> Fornecedor
		cLoja		-> Loja do fornecedor
		cProd		-> Proudto
		cTES		->	TES
		nQtd		-> Qtidade
		nVrUni		-> Valor Unitario        
        cTipocli    -> Tipo de Cliente
        cNaturez    -> Natureza Financeira
        nMoedaD     -> Moeda
        nTaxa       -> Taxa        
        cTpFrete	-> Indica o tp. de frete

@Return	aImpostos	-> Valor dos impostos
@author: 	Emerson Coelho/Marcelo Ferrari
@since: 	21/09/2017
@Uso: 		SIGAAGR - Originação de Grãos
*/         
Function OGX020(cFilOrig, cTpDoc, cCliFor, cLoja, cProd, cTES, aItens, cTipocli, cNaturez, nMoedaD, nTaxa, cTpFrete)	
	Local aAreaAtu	 := getarea()
	Local nValMerc	 := 0	
	Local nI         := 0	
	Local aImpostos  := {}	
	Local lTrbGen	 := FindFunction("ChkTrbGen") .AND. ChkTrbGen("SD2","D2_IDTRIB") //protecão do motor

	Local nQtdTotal  := 0
	Local nVlrTotal  := 0
	Local nValMercT  := 0
	Local nQtd       := 0
	Local nVrUni	 := 0		
    Local cFilAtu	 := cFilAnt // Filial corrente	

	Default cTpDoc 	:= "E"
	Default cCliFor	:= ""
	Default cLoja	:= ""
	Default cProd	:= ""
	Default cTES	:= ""
	Default aItens  := {{"", 0 , 0, ""}} //Filial, Qtd, Vlr Unit, tipo	
	Default cTipocli := 'R'
	Default cNaturez := ""
    Default nMoedaD  := 1
    Default nTaxa   := 0	
	Default lExibe  := .T.	
	Default ctpFrete := 'S'   //C=CIF;F=FOB;T=Por cuenta terceros;S=Sin flete 	
	Private aAgrItFat := {}	
   
    cFilAnt   := cFilOrig

	If cTpDoc == "E" // Docto de Entrada

		//-- Salva situação atual --//
		MaFisSave()
		MaFisEnd()

		//-- Executa regras a respeito da inicialização das regras fiscais caso não estejam inicializadas --/
		If !MaFisFound("NF")	
			dbSelectArea("SA2")
			SA2->(dbSetOrder(1))
			SA2->(dbGoTop())
			SA2->(dbSeek(xFilial("SA2") + cCliFor + cLoja))

			//-- Efetua inicialização das regras fiscais para o calculo --//
			//MaFisIni : Inicializa a função fiscal
			// 		Parâmetros da função MaFisIni():
			//01..cCodCliFor..Caracter.....Código Cliente/Fornecedor 
			//02..cLoja.......Caracter.....Loja do Cliente/Fornecedor 
			//03..cCliFor.....Caracter.....C:Cliente , F:Fornecedor 
			//04..cTipoNF.....Caracter.....Tipo da NF( "N","D","B","C","P","I" ) 
			//05..cTpCliFor...Caracter.....Tipo do Cliente/Fornecedor 
			//06..aRelImp.....Array........Relação de Impostos que suportados no arquivo 
			//07..cTpComp.....Caracter.....Tipo de complemento 
			//08..lInsere.....Lógico.......Permite Incluir Impostos no Rodapé .T./.F. 
			//09..cAliasP.....Caracter.....Alias do Cadastro de Produtos - ("SBI" P/ Front Loja) 
			//10..cRotina.....Caracter.....Nome da rotina que esta utilizando a função 
			//11..cTipoDoc....Caracter.....Tipo de documento 
			//12..cEspecie....Caracter.....Espécie do documento 
			//13..cCodProsp...Caracter.....Código e Loja do Prospect 
			//14..cGrpCliFor..Caracter.....Grupo Cliente 
			//15..cRecolheISS.Caracter.....Recolhe ISS 
			//16..cCliEnt.....Caracter.....Código do cliente de entrega na nota fiscal de saída 
			//17..cLojEnt.....Caracter.....Loja do cliente de entrega na nota fiscal de saída 
			//18..aTransp.....Array........Informações do transportador [01]-UF,[02]-TPTRANS 
			//19..lEmiteNF....Lógico.......Se esta emitindo nota fiscal ou cupom fiscal (Sigaloja)
			//20..lCalcIPI....Lógico.......Define se calcula IPI (SIGALOJA) 
			//21..cPedido.....Caracter.....Pedido de Venda 
			//22..cCliFat.....Caracter.....Cliente do Faturamento 
			//23..cLojcFat....Caracter.....Loja do Cliente do Faturamento 
			


			//MaFisRelImp       --retornando  um array  com  a  referencias  fiscais  separadas  para  cada  Alias  informado
			//	01  cProg  Caracter  Reservado sem uso no momento, NÃO necessita ser informado 
			//	02  aAlias  Array  Array contendo os alias dos arquivos Exemplo: {SF1,SD1} 

			MaFisIni(SA2->A2_COD,                          ;
			         SA2->A2_LOJA,                         ;
			         "F",                                  ;
			         "N",                                  ;
			         Nil,                                  ;
			         MaFisRelImp("MT100",{"SF1","SD1"}),   ;
			         ,                                     ;
			         .F.,                                  ;
			         NIL,                                  ;
			         NIL,                                  ;
			         NIL,;
			         NIL,;
			         NIL,;
			         NIL,;
			         NIL,;
			         NIL,;
			         NIL,;
			         NIL,;
			         NIL,;
			         NIL,;
			         NIL,;
			         NIL,;
			         NIL,;
			         NIL,;
			         dDataBase,;
			         ctpFrete,;
					 nil,;
					NIL,;
					NIL,;
					NIL,;
					NIL,;
					NIL,;
					lTrbGen)

			MaFisAlt("NF_UFDEST"	, SA2->A2_EST)
			MaFisAlt("NF_ESPECIE"	, "SPED")

            If !Empty(cNaturez)
		    	MaFisAlt("NF_NATUREZA"	, cNaturez) // colocar a natureza correta?????;;;
		    EndIf
		    
		    If !Empty(nMoedaD) .AND. (nMoedaD != 1)
		    	// Para contratos em outra moeda tenho q ajustar a modea ??? --
		    	MaFisAlt("NF_MOEDA"	, nMoedaD) // colocar a natureza correta?????;;;  //
		    	
		    	If !Empty(nTaxa)
			    	MaFisAlt("NF_TXMOEDA"	, nTaxa) // 
			    EndIf
		    EndIf
		    		   

			//-- Posiciona no Codigo do item --//
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			SB1->(dbGoTop())
			SB1->(dbSeek(xFilial("SB1") + cProd ))
			//--Buscando a TES --//
			dbSelectArea("SF4")
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4") + cTES ))

			//-- Adiionando os dados do Item ao processamento Fiscal --
			// Agrega os itens para a função fiscal
			//       Ordem Parâmetro Tipo Descrição
			//       01 cProduto Caracter Código do Produto ( Obrigatório )
			//       02 cTes Caracter Código do TES ( Opcional )
			//       03 nQtd Numérico Quantidade ( Obrigatório )
			//       04 nPrcUnit Numérico Preço Unitário ( Obrigatório )
			//       05 nDesconto Numérico Valor do Desconto ( Opcional )
			//       06 cNFOri Caracter Numero da NF Original ( Devolução/Benef )
			//       07 cSEROri Caracter Serie da NF Original ( Devolução/Benef )
			//       08 nRecOri Numérico RecNo da NF Original no arq SD1/SD2
			//       09 nFrete Numérico Valor do Frete do Item ( Opcional )
			//       10 nDespesa Numérico Valor da Despesa do item ( Opcional )
			//       11 nSeguro Numérico Valor do Seguro do item ( Opcional )
			//       12 nFretAut Numérico Valor do Frete Autônomo ( Opcional )
			//       13 nValMerc Numérico Valor da Mercadoria ( Obrigatório )
			//       14 nValEmb Numérico Valor da Embalagem ( Opcional )
			//       15 nRecSB1 Numérico RecNo do SB1
			//       16 nRecSF4 Numérico RecNo do SF4
			//       17 cNItem Caracter Numero do item – Exemplo “01”
			//       18 nDesNTrb Numérico Despesas não tributadas (Portugal)
			//       19 nTara Numérico Tara (Portugal)

			For nI := 1 to len(aItens)
			   nQtd     := aItens[nI][2]
			   nVrUni   := aItens[nI][3]

	           nValmerc := (nVrUni * nQtd)
	         //  nValmerc :=	A410ARRED(nQtd * nVrUni, 'D1_TOTAL')
	           aAdd(aItens[nI], nValmerc )
			   
			   nQtdTotal := nQtdTotal + nQtd
			   nVlrTotal := nVlrTotal + nVrUni
			   nValMercT := nValMercT + nValMerc 
               
			   MaFisAdd(SB1->B1_COD, SF4->F4_CODIGO, nQtd, nVrUni, 0, "", "", , 0, 0, 0, 0, nValMerc, 0, SB1->(RecNo()))
			Next nI	

			aImpostos := MaFisRet(,"NF_IMPOSTOS")  // -- Armazena os Impostos aqui terá todos os impostos -- //
			
			//aImpMotor := MaFisRet(,"NF_TRIBGEN") //busca impostos do motor
			//tratar igual a Saidas

			/*/
			!---------------------------------------------------------------------------------------------	!
			!	Atençaõ: 	Não levamos em consideração que na natureza financeira tbem tem varios impostos	! 
			!				a serem deduzidos ou não. Alinhado c. vitor q decidiu nesse momento não tratar 	!
			!				esta questão. ( Para nos basearmos em como fazer isso verificar a rotina 		!
			!				A103ATUSE2 do MATA103)															!	
			!---------------------------------------------------------------------------------------------	!
			/*/

			MaFisEnd() //-- Finaliza as Funções fiscais --//
		EndIf
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Executa regras em torno da simulação de impostos através do documento fiscal de saída³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄADÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Executa regras a respeito da inicialização das regras fiscais caso não estejam inicializadas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		//-- Salva situação atual --//
		MaFisSave()
		MaFisEnd()
		//-- Efetua inicialização das regras fiscais para o calculo --//
		//MaFisIni : Inicializa a função fiscal
		// 		Parâmetros da função MaFisIni():
		//01..cCodCliFor..Caracter.....Código Cliente/Fornecedor 
		//02..cLoja.......Caracter.....Loja do Cliente/Fornecedor 
		//03..cCliFor.....Caracter.....C:Cliente , F:Fornecedor 
		//04..cTipoNF.....Caracter.....Tipo da NF( "N","D","B","C","P","I" ) 
		//05..cTpCliFor...Caracter.....Tipo do Cliente/Fornecedor 
		//06..aRelImp.....Array........Relação de Impostos que suportados no arquivo 
		//07..cTpComp.....Caracter.....Tipo de complemento 
		//08..lInsere.....Lógico.......Permite Incluir Impostos no Rodapé .T./.F. 
		//09..cAliasP.....Caracter.....Alias do Cadastro de Produtos - ("SBI" P/ Front Loja) 
		//10..cRotina.....Caracter.....Nome da rotina que esta utilizando a função 
		//11..cTipoDoc....Caracter.....Tipo de documento 
		//12..cEspecie....Caracter.....Espécie do documento 
		//13..cCodProsp...Caracter.....Código e Loja do Prospect 
		//14..cGrpCliFor..Caracter.....Grupo Cliente 
		//15..cRecolheISS.Caracter.....Recolhe ISS 
		//16..cCliEnt.....Caracter.....Código do cliente de entrega na nota fiscal de saída 
		//17..cLojEnt.....Caracter.....Loja do cliente de entrega na nota fiscal de saída 
		//18..aTransp.....Array........Informações do transportador [01]-UF,[02]-TPTRANS 
		//19..lEmiteNF....Lógico.......Se esta emitindo nota fiscal ou cupom fiscal (Sigaloja)
		//20..lCalcIPI....Lógico.......Define se calcula IPI (SIGALOJA) 
		//21..cPedido.....Caracter.....Pedido de Venda 
		//22..cCliFat.....Caracter.....Cliente do Faturamento 
		//23..cLojcFat....Caracter.....Loja do Cliente do Faturamento 

		//MaFisRelImp       --retornando  um array  com  a  referencias  fiscais  separadas  para  cada  Alias  informado
		//	01  cProg  Caracter  Reservado sem uso no momento, NÃO necessita ser informado 
		//	02  aAlias  Array  Array contendo os alias dos arquivos Exemplo: {SF1,SD1} 

		If !MaFisFound("NF")
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			SA1->(dbGoTop())
			SA1->(dbSeek(xFilial("SA1") + cCliFor + cLoja))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Efetua inicialização das regras fiscais para o calculo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			                                               
			MaFisIni(SA1->A1_COD,                         	;
			         SA1->A1_LOJA,                        	;
			         IIf(cTpDoc $ 'DB',"F","C"),          	;
			         "N",                                 	;
			         IIf(cTpDoc $ 'DB', Nil ,cTipoCli ) , 	;
			         MaFisRelImp("MT100",{"SF2","SD2"}),  	;
			         ,                                    	;
			         .F.,                                 	;
			         NIL,                        			;
			         NIL,                                	;
			         NIL,									;
			         NIL,									;
			         NIL,									;
			         NIL,									;
			         NIL,									;
			         NIL,									;
			         NIL,									;
			         NIL,									;
			         NIL,									;
			         NIL,									;
			         NIL,									;
			         NIL,									;
			         NIL,									;
			         NIL,									;
			         dDataBase,									;
			         ctpFrete,;
					 NIL,;
					 NIL,;
					 NIL,;
					 NIL,;
					 NIL,;
					 NIL,;
					 lTrbGen) //indicado que usa o motor de impostos
			
            If !Empty(cNaturez)
		    	MaFisAlt("NF_NATUREZA"	, cNaturez) // MaFisLoad("NF_NATUREZA", cNaturez)
		    EndIf
		    
		    If !Empty(nMoedaD) .AND. (nMoedaD != 1)
		    	// Para contratos em outra moeda tenho q ajustar a modea ??? --
		    	MaFisAlt("NF_MOEDA"	, nMoedaD)
		    	
		    	If !Empty(nTaxa)
			    	MaFisAlt("NF_TXMOEDA"	, nTaxa) 
			    EndIf
		    EndIf
		    		    
			MaFisAlt("NF_UFDEST"	, SA1->A1_EST) //MaFisLoad("NF_UFDEST"	, SA1->A1_EST)
	
			//-- Posiciona no Codigo do item --//
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			SB1->(dbGoTop())
			SB1->(dbSeek(xFilial("SB1") + cProd ))
			//--Buscando a TES --//
			dbSelectArea("SF4")
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4") + cTES ))
			//-- Adiionando os dados do Item ao processamento Fiscal --
			// Agrega os itens para a função fiscal
			//       Ordem Parâmetro Tipo Descrição
			//       01 cProduto Caracter Código do Produto ( Obrigatório )
			//       02 cTes Caracter Código do TES ( Opcional )
			//       03 nQtd Numérico Quantidade ( Obrigatório )
			//       04 nPrcUnit Numérico Preço Unitário ( Obrigatório )
			//       05 nDesconto Numérico Valor do Desconto ( Opcional )
			//       06 cNFOri Caracter Numero da NF Original ( Devolução/Benef )
			//       07 cSEROri Caracter Serie da NF Original ( Devolução/Benef )
			//       08 nRecOri Numérico RecNo da NF Original no arq SD1/SD2
			//       09 nFrete Numérico Valor do Frete do Item ( Opcional )
			//       10 nDespesa Numérico Valor da Despesa do item ( Opcional )
			//       11 nSeguro Numérico Valor do Seguro do item ( Opcional )
			//       12 nFretAut Numérico Valor do Frete Autônomo ( Opcional )
			//       13 nValMerc Numérico Valor da Mercadoria ( Obrigatório )
			//       14 nValEmb Numérico Valor da Embalagem ( Opcional )
			//       15 nRecSB1 Numérico RecNo do SB1
			//       16 nRecSF4 Numérico RecNo do SF4
			//       17 cNItem Caracter Numero do item – Exemplo “01”
			//       18 nDesNTrb Numérico Despesas não tributadas (Portugal)
			//       19 nTara Numérico Tara (Portugal)
			
			For nI := 1 to len(aItens)
			   nQtd     := aItens[nI][3]
			   nVrUni   := aItens[nI][2]
			   cTipProd := aItens[nI][4]

			   If Empty(cTipProd)
				  cTipProd := ""	
			   EndIf
			  
	           nValmerc := (nVrUni * nQtd)
	           nValmerc :=	A410ARRED(nQtd * nVrUni, 'D1_TOTAL')
	           aAdd(aItens[nI], nValmerc )
			   
			   nQtdTotal := nQtdTotal + nQtd
			   nVlrTotal := nVlrTotal + nVrUni
			   nValMercT := nValMercT + nValMerc 
			
			   aAdd(aAgrItFat,{"", "", /*nSeq*/, cTipProd, nVrUni, nI  })

			   MaFisAdd(SB1->B1_COD, SF4->F4_CODIGO, nQtd, nVrUni, 0, "", "", , 0, 0, 0, 0, nValMerc, 0, SB1->(RecNo()))
			   
			Next nI			

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Compõe array de retorno com as informações³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			
			aImpostos  := MaFisRet(,"NF_IMPOSTOS")			                
			aAdd(aImpostos, {"PAUTA",      "PAUTA"     , MaFisRet(1,"IT_PAUTIC"), 0, 0, "PAUTA"} )			

			MaFisEnd()		// Finaliza as Funcoes Fiscais de Calculo
		EndIf
	EndIF	
 
    RestArea( aAreaAtu )
    
    cFilAnt   := cFilAtu

Return aImpostos
