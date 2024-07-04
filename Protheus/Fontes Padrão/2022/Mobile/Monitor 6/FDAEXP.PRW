/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ProntaEnt³ Autor ³ Marcelo Vieira        ³ Data ³ 16/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo Espelho para tabelas do pronta-entrega             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Vieira    ³13.09.02³Geracao das bases para versao em Advpl           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ProntaEnt()
Local aCabNFsai    := {} // Contem os dados do arquivo cab  de notas de saida
Local aIteNFsai    := {} // Contem os dados do arquivo item de notas de saida
Local cCabNFsai:="HF2" + cEmpAnt + "0" 
Local cIteNFsai:="HD2" + cEmpAnt + "0" 

cVendedor := PALMUSER->P_CODVEND           

//Cabecalho da nota de saida
aadd( aCabNFsai,{"F2_DOC"     ,"C",  6,   0 })
aadd( aCabNFsai,{"F2_SERIE"   ,"C",  3,   0 })
aadd( aCabNFsai,{"F2_CLIENTE" ,"C",  6,   0 })
aadd( aCabNFsai,{"F2_TABELA"  ,"C",  3,   0 })
aadd( aCabNFsai,{"F2_LOJA"    ,"C",  2,   0 })
aadd( aCabNFsai,{"F2_COND"    ,"C",  3,   0 })
aadd( aCabNFsai,{"F2_DUPL"    ,"C",  6,   0 })
aadd( aCabNFsai,{"F2_EMISSAO" ,"D",  8,   0 })
aadd( aCabNFsai,{"F2_EST"     ,"C",  2,   0 })
aadd( aCabNFsai,{"F2_FRETE"   ,"N", 14,   2 })
aadd( aCabNFsai,{"F2_SEGURO"  ,"N", 14,   2 })
aadd( aCabNFsai,{"F2_ICMFRET" ,"N", 14,   2 })
aadd( aCabNFsai,{"F2_TIPOCLI" ,"C",  1,   0 })
aadd( aCabNFsai,{"F2_VALBRUT" ,"N", 14,   2 })
aadd( aCabNFsai,{"F2_VALICM"  ,"N", 14,   2 })
aadd( aCabNFsai,{"F2_BASEICM" ,"N", 14,   2 })
aadd( aCabNFsai,{"F2_VALIPI"  ,"N", 14,   2 })
aadd( aCabNFsai,{"F2_BASEIPI" ,"N", 14,   2 })
aadd( aCabNFsai,{"F2_VALMERC" ,"N", 14,   2 })
aadd( aCabNFsai,{"F2_DESCONT" ,"N", 14,   2 })
aadd( aCabNFsai,{"F2_TIPO"    ,"C",  1,   0 })
aadd( aCabNFsai,{"F2_ICMSRET" ,"N", 14,   2 })
aadd( aCabNFsai,{"F2_PLIQUI"  ,"N",  9,   2 })
aadd( aCabNFsai,{"F2_PBRUTO"  ,"N",  9,   2 })
aadd( aCabNFsai,{"F2_TRANSP"  ,"C",  6,   0 })
aadd( aCabNFsai,{"F2_VEND1"   ,"C",  6,   0 })
aadd( aCabNFsai,{"F2_OK"      ,"C",  4,   0 })
aadd( aCabNFsai,{"F2_FIMP"    ,"C",  1,   0 })
aadd( aCabNFsai,{"F2_FILIAL"  ,"C",  2,   0 })
aadd( aCabNFsai,{"F2_BASEISS" ,"N", 14,   2 })
aadd( aCabNFsai,{"F2_VALISS"  ,"N", 14,   2 })
aadd( aCabNFsai,{"F2_VALFAT"  ,"N", 16,   2 })
aadd( aCabNFsai,{"F2_BRICMS"  ,"N", 14,   2 })
aadd( aCabNFsai,{"F2_PREFIXO" ,"C",  3,   0 })
aadd( aCabNFsai,{"F2_VALCOFI" ,"N", 14,   2 })
aadd( aCabNFsai,{"F2_VALPIS"  ,"N", 14,   2 })
aadd( aCabNFsai,{"F2_VALIRRF" ,"N", 14,   2 })
aadd( aCabNFsai,{"F2_SEQCAR"  ,"C",  2,   0 })
aadd( aCabNFsai,{"F2_BASEINS" ,"N", 14,   2 })
aadd( aCabNFsai,{"F2_DTENTR"  ,"D",  8,   0 })
aadd( aCabNFsai,{"F2_TIPODOC" ,"C",  2,   0 })
aadd( aCabNFsai,{"F2_QTDITE"  ,"N",  5, 0})
aadd( aCabNFsai,{"F2_STATUS"  ,"C",  1, 0})

//item da nota de saida
aadd( aIteNFsai,{"D2_DOC"     ,"C",  6, 0 }) // 
aadd( aIteNFsai,{"D2_FILIAL"  ,"C",  2, 0 }) //
aadd( aIteNFsai,{"D2_ITEM"    ,"C",  3, 0 }) //
aadd( aIteNFsai,{"D2_COD"     ,"C", 15, 0 }) //
aadd( aIteNFsai,{"D2_UM"      ,"C",  2, 0 }) //
aadd( aIteNFsai,{"D2_SEGUM"   ,"C",  2, 0 }) //
aadd( aIteNFsai,{"D2_QUANT"   ,"N", 11, 2 }) //
aadd( aIteNFsai,{"D2_PRCVEN"  ,"N", 14, 2 }) //
aadd( aIteNFsai,{"D2_TOTAL"   ,"N", 14, 2 }) //
aadd( aIteNFsai,{"D2_VALIPI"  ,"N", 14, 2 }) //
aadd( aIteNFsai,{"D2_VALICM"  ,"N", 14, 2 }) //
aadd( aIteNFsai,{"D2_TES"     ,"C",  3, 0 }) //
aadd( aIteNFsai,{"D2_CF"      ,"C",  5, 0 }) //
aadd( aIteNFsai,{"D2_DESC"    ,"N",  5, 2 }) //
aadd( aIteNFsai,{"D2_IPI"     ,"N",  5, 2 }) //
aadd( aIteNFsai,{"D2_PICM"    ,"N",  5, 2 }) //
aadd( aIteNFsai,{"D2_CLIENTE" ,"C",  6, 0 }) //
aadd( aIteNFsai,{"D2_LOJA"    ,"C",  2, 0 }) //
aadd( aIteNFsai,{"D2_EMISSAO" ,"D",  8, 0 }) //
aadd( aIteNFsai,{"D2_GRUPO"   ,"C",  4, 0 }) //
aadd( aIteNFsai,{"D2_TP"      ,"C",  2, 0 }) //
aadd( aIteNFsai,{"D2_SERIE"   ,"C",  3, 0 }) //
aadd( aIteNFsai,{"D2_PRUNIT"  ,"N", 14, 2 }) //
aadd( aIteNFsai,{"D2_EST"     ,"C",  2, 0 }) //
aadd( aIteNFsai,{"D2_DESCON"  ,"N", 12, 2 }) //
aadd( aIteNFsai,{"D2_TIPO"    ,"C",  1, 0 }) //
aadd( aIteNFsai,{"D2_BRICMS"  ,"N", 14, 2 }) //
aadd( aIteNFsai,{"D2_BASEICM" ,"N", 16, 2 }) //
aadd( aIteNFsai,{"D2_VALACRS" ,"N", 16, 2 }) //
aadd( aIteNFsai,{"D2_ICMSRET" ,"N", 14, 2 }) //
aadd( aIteNFsai,{"D2_LOTECTL" ,"C", 10, 0 }) //
aadd( aIteNFsai,{"D2_CLASFIS" ,"C",  3, 0 }) //
aadd( aIteNFsai,{"D2_ALIQISS" ,"N",  5, 2 }) //
aadd( aIteNFsai,{"D2_BASEIPI" ,"N", 14, 2 }) //
aadd( aIteNFsai,{"D2_BASEISS" ,"N", 14, 2 }) //
aadd( aIteNFsai,{"D2_VALISS"  ,"N", 14, 2 }) //
aadd( aIteNFsai,{"D2_SEGURO"  ,"N", 14, 2 }) //
aadd( aIteNFsai,{"D2_VALFRE"  ,"N", 14, 2 }) //
aadd( aIteNFsai,{"D2_ICMFRET" ,"N", 14, 2 }) //
aadd( aIteNFsai,{"D2_OK"      ,"C",  2, 0 }) //
aadd( aIteNFsai,{"D2_QTDEFAT" ,"N", 16, 4 }) //
aadd( aIteNFsai,{"D2_QTDAFAT" ,"N", 16, 4 }) //
aadd( aIteNFsai,{"D2_DESCR"   ,"C", 30, 0 }) //

ConOut("PALMJOB: Criando arquivo de notas de Saidas para " + Trim(PALMUSER->P_USER) + " - " + Time())

PalmCreate(aCabNFsai,cCabNFsai ,"HF2")
PalmCreate(aIteNFsai,cIteNFsai ,"HD2")

HF2->(dbCloseArea())
HD2->(dbCloseArea())

Return

//retorna alias usados pelo servico
User Function PNFSAI( )
Return {"SF2","SD2"}

//retorna nome fisico do arquivo espelho
User Function PNFSArq( )          
Local cCabNFsai:="HF2" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cIteNFsai:="HD2" + Left(PALMSERV->P_EMPFI,2) + "0"
Return { cCabNFsai, cIteNFsai }

//retorna indice usado pelo arquivo espelho
User Function PNFSInd( )
Local cIndSf2 := "F2_DOC+F2_SERIE" 
Local cIndSd2 := "D2_DOC+D2_SERIE+D2_ITEM"
Return {cIndSf2,cIndSd2 }

///--------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Movmtos  ³ Autor ³ Marcelo Vieira        ³ Data ³ 16/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo Espelho para tabelas do pronta-entrega             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Vieira    ³13.09.02³Geracao das bases para versao em Advpl           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MOVMTOSPE()

Local cVendedor := PALMUSER->P_CODVEND           
Local aStruHB6  := {} // Estoque no caminhao 
Local aStruHE5  := {} // Cadastro de Movimento Bancario ( Baixas ) 
Local aStruHTR  := {} // Tabela de Trocas 

// Engatilhado se precisar uma cadastro mais detalhado para Cheques 
//Local aStruHEF  := {} // Tabela de CHEQUES

Local cArqHB6   :="HB6" + cEmpAnt + "0" 
Local cArqHE5   :="HE5" + cEmpAnt + "0" 
Local cArqHTR   :="HTR" + cEmpAnt + "0" 

// Engatilhado se precisar uma cadastro mais detalhado para Cheques 
// Local cArqHEF   :="HEF" + cEmpAnt + "0" 

//cliente padrao para achar rapido o cliente na tabela 
Local cCliPadr   := GetMV("MV_FDACLIP",,"000001")  // Cliente  padrao definir parametro na retaguarda
Local cLojaPad   := GetMV("MV_FDALOJP",,"01"    )  // Loja padrao definir parametro na retaguarda
Local cTipoRem   := GetMV("MV_FDATREM",,"596")     // Tipo de saida de nota para venda externa
Local lEstaNFsim := .f.

// Estoque do Caminhao
aadd( aStruHB6,{"B6_FILIAL"  ,"C",  2, 0 }) // 
aadd( aStruHB6,{"B6_DOC"     ,"C",  6, 0 }) // 
aadd( aStruHB6,{"B6_SERIE"   ,"C",  3, 0 }) //
aadd( aStruHB6,{"B6_DATA"    ,"D",  8, 0 }) //
aadd( aStruHB6,{"B6_COD"     ,"C", 15, 0 }) // 
aadd( aStruHB6,{"B6_ITEMORI" ,"C",  2, 0 }) // ITEM ORIGEM 
aadd( aStruHB6,{"B6_ORI"     ,"N", 14, 2 }) // 
aadd( aStruHB6,{"B6_QTD"     ,"N", 14, 2 }) //
aadd( aStruHB6,{"B6_QTSEGUM" ,"N", 14, 2 }) //
aadd( aStruHB6,{"B6_PRCVEN"  ,"N", 14, 2 }) // Preco de venda para devolver deve ser o mesmo da saida. 
aadd( aStruHB6,{"B6_LOTECTL" ,"C", 10, 0 }) // NUMERO DO LOTE
aadd( aStruHB6,{"B6_DTVALID" ,"D",  8, 0 }) // DATA DE VALIDADE
aadd( aStruHB6,{"B6_NFENTR"  ,"C",  6, 0 }) // Nr. da Nota de Entrada que sera usada para devolver os produtos
aadd( aStruHB6,{"B6_SERNFE"  ,"C",  6, 0 }) // Serie da Nota de Entrada que sera usada para devolver os produtos
aadd( aStruHB6,{"B6_DATNFE"  ,"D",  8, 0 }) // Data da Nota de Entrada que sera usada para devolver os produtos
aadd( aStruHB6,{"B6_STATUS"  ,"C",  1, 0 }) //

// Movimento Bancário 
aadd(aStruHE5,{"E5_FILIAL"	    	, "C",  2, 0}) // 
aadd(aStruHE5,{"E5_DATA"			, "D",  8, 0}) // 
aadd(aStruHE5,{"E5_TIPO"			, "C",  3, 0}) // 
aadd(aStruHE5,{"E5_VALOR"			, "N", 17, 2}) // 
aadd(aStruHE5,{"E5_NATUREZ"			, "C", 10, 0}) // 
aadd(aStruHE5,{"E5_BANCO"			, "C",  3, 0}) // 
aadd(aStruHE5,{"E5_AGENCIA"			, "C",  5, 0}) // 
aadd(aStruHE5,{"E5_CONTA"			, "C",  3, 0}) // 
aadd(aStruHE5,{"E5_NUCHEQ"			, "C", 15, 0}) // 
aadd(aStruHE5,{"E5_VENCTO"          , "D",  8, 0}) // 
aadd(aStruHE5,{"E5_RECPAG"			, "C",  1, 0}) // 
aadd(aStruHE5,{"E5_BENEF"			, "C", 30, 0}) // 
aadd(aStruHE5,{"E5_HISTOR"			, "C",  3, 0}) // 
aadd(aStruHE5,{"E5_TIPODOC"			, "C",  2, 0}) // 
aadd(aStruHE5,{"E5_LA"				, "C",  2, 0}) // 
aadd(aStruHE5,{"E5_PREFIXO"			, "C",  3, 0}) // 
aadd(aStruHE5,{"E5_NUMERO"			, "C",  3, 0}) // 
aadd(aStruHE5,{"E5_PARCELA"			, "C",  1, 0}) // 
aadd(aStruHE5,{"E5_CLIFOR"			, "C",  6, 0}) // 
aadd(aStruHE5,{"E5_LOJA"			, "C",  2, 0}) // 
aadd(aStruHE5,{"E5_DTDIGIT"			, "C",  3, 0}) // 
aadd(aStruHE5,{"E5_MOTBX"			, "C",  3, 0}) // 
aadd(aStruHE5,{"E5_SEQ"	    		, "C",  2, 0}) // 
aadd(aStruHE5,{"E5_DTDISPO"			, "D",  8, 0}) // 
aadd(aStruHE5,{"E5_VLJUROS"			, "N", 17, 2}) // 
aadd(aStruHE5,{"E5_VLMULTA"			, "N", 17, 2}) // 
aadd(aStruHE5,{"E5_VLDESCO"			, "N", 17, 2}) // 
aadd(aStruHE5,{"E5_STATUS"			, "C", 1, 2})  //  Status de importacao para Protheus

// TABELA DE TROCAS
aadd( aStruHTR, {"TR_CLI"   , "C",  6, 0}) //  CLIENTE
aadd( aStruHTR, {"TR_LOJA"  , "C",  2, 0}) //  LOJA
aadd( aStruHTR, {"TR_GRUPO" , "C",  3, 0}) //  GRUPO PRODUTO
aadd( aStruHTR, {"TR_PROD"  , "C", 15, 0}) //  CODIGO DO PRODUTO
aadd( aStruHTR, {"TR_DATA"  , "D",  8, 0}) //  DATA DA TROCA 
aadd( aStruHTR, {"TR_DTVENC", "D",  8, 0}) //  DATA DO VENCIMENTO
aadd( aStruHTR, {"TR_QTD"   , "N", 16, 4}) //  QUANTIDADE TROCADA
aadd( aStruHTR, {"TR_OBS"   , "C",200, 0}) //  OBSERVACAO DA TROCA 
aadd( aStruHTR, {"TR_STATUS", "C",  1, 0}) //  STATUS SE E PARA IMPORTAR OU NAO

// Engatilhado se precisar uma cadastro mais detalhado para Cheques 
// TABELA DE CHEQUES
/*
aadd( aStruHEF,{"EF_FILIAL" , "C",2 , 0 } )
aadd( aStruHEF,{"EF_PREFIXO", "C",3 , 0 } )
aadd( aStruHEF,{"EF_TITULO" , "C",6 , 0 } )
aadd( aStruHEF,{"EF_PARCELA", "C",1 , 0 } )
aadd( aStruHEF,{"EF_TIPO"   , "C",3 , 0 } )
aadd( aStruHEF,{"EF_NUM"    , "C",15, 0 } )
aadd( aStruHEF,{"EF_BANCO"  , "C",3 , 0 } )
aadd( aStruHEF,{"EF_AGENCIA", "C",5 , 0 } )
aadd( aStruHEF,{"EF_VALOR"  , "N",17, 2 } )
aadd( aStruHEF,{"EF_DATA"   , "D",8 , 0 } )
aadd( aStruHEF,{"EF_CONTA"  , "C",10, 0 } )
aadd( aStruHEF,{"EF_IMPRESS", "C",1 , 0 } )
aadd( aStruHEF,{"EF_HIST"   , "C",60, 0 } )
aadd( aStruHEF,{"EF_NUMNOTA", "C",6 , 0 } )
aadd( aStruHEF,{"EF_RG"     , "C",15, 0 } )
aadd( aStruHEF,{"EF_SERIE"  , "C",3 , 0 } )
aadd( aStruHEF,{"EF_TEL"    , "C",15, 0 } )
aadd( aStruHEF,{"EF_VENCTO" , "D",8 , 0 } )
aadd( aStruHEF,{"EF_DTREPRE", "D",8 , 0 } )
aadd( aStruHEF,{"EF_CHDEVOL", "C",2 , 0 } )
aadd( aStruHEF,{"EF_COMP"   , "C",3 , 0 } )
aadd( aStruHEF,{"EF_VALORBX", "N",14, 2 } )
aadd( aStruHEF,{"EF_CLIENTE", "C",6 , 0 } )
aadd( aStruHEF,{"EF_LOJACLI", "C",2 , 0 } )
aadd( aStruHEF,{"EF_CPFCNPJ", "C",14, 0 } )
aadd( aStruHEF,{"EF_EMITENT", "C",40, 0 } )
aadd( aStruHEF,{"EF_STATUS",  "C",1,  0 } ) 
*/
ConOut("PALMJOB: Criando arquivo de movtos bancarios para " + Trim(PALMUSER->P_USER) + " - " + Time())
PalmCreate( aStruHE5,cArqHE5 ,"HE5")
ConOut("PALMJOB: Criando arquivo de trocas para " + Trim(PALMUSER->P_USER) + " - " + Time())
PalmCreate( aStruHTR,cArqHTR ,"HTR")
ConOut("PALMJOB: Criando arquivo de estoque veiculo para " + Trim(PALMUSER->P_USER) + " - " + Time())
PalmCreate( aStruHB6,cArqHB6 ,"HB6")

ConOut("PALMJOB: Buscando nota para carregar o estoque veículo para " + Trim(PALMUSER->P_USER) + " - " + Time())

dbSelectArea("SF2") 
dbSetOrder(2)       // Seta o indice por cliente / loja
dbSeek(xFilial("SF2") + cCliPadr + cLojaPad  )

Do While SF2->(!eof()) 

   //if  SF2->F2_EMISSAO == dDataBase .And.  SF2->F2_VEND1==cVendedor
   if  SF2->F2_VEND1==cVendedor
       lEstaNFsim := .t.   
   endif
   if lEstaNFsim
	
		dbSelectArea("SD2") 
		dbSetOrder(3)       // Seta o indice por cliente / loja                               
		dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA  )
	
		Do While  SD2->(!EOF()) .And. SD2->D2_DOC == SF2->F2_DOC 
	
		   // Verifica se a Nota encontrada e para vender                   
		   ConOut( "PALMJOB: Nota de Remessa CFOP : "  + cTipoRem  )
	 
	       //ConOut( lEstaNFsim  )	   
	
		   If  lEstaNFsim .AND. Alltrim(SD2->D2_CF) == Alltrim(cTipoRem) .And. SD2->D2_QTDEDEV==0   // ( SD2->D2_QUANT - SD2->D2_QTDEDEV)  > 0  

		       // Para garantir que a nota no HandHeld nao sera excluida 
		       //If  SD2->D2_QTDEDEV = 0 
		      
			         dbSelectArea("HB6")
			    	 RecLock("HB6",.T.)            
			    	 
				     HB6->B6_COD     := SD2->D2_COD    	 
					 HB6->B6_DOC     := SD2->D2_DOC
					 HB6->B6_SERIE   := SD2->D2_SERIE
				     HB6->B6_DATA    := SD2->D2_EMISSAO
			         HB6->B6_FILIAL  := SD2->D2_FILIAL
					 HB6->B6_ORI     := SD2->D2_QUANT
					 HB6->B6_QTD     := SD2->D2_QUANT
					 HB6->B6_ITEMORI := SD2->D2_ITEM 
			         HB6->B6_PRCVEN  := SD2->D2_PRCVEN 		 
			         HB6->B6_LOTECTL := SD2->D2_LOTECTL 		 
			         HB6->B6_DTVALID := SD2->D2_DTVALID
					 HB6->B6_QTSEGUM := 0  // so em caso de necessidades futuras 
			    	
			     	 HB6->(MsUnlock())
		     	 
		       //Endif
		      		 
		   Endif       
		   
		   SD2->( dbSkip() )
		   
		Enddo
		
   endif
	
    SF2->( DBSKIP() )
	
Enddo

Conout( "PALMJOB: " + if(lEstaNFsim,"Existe nf para caminhao" , "Nota para veiculo nao encontrada!")  )

// Criacao de CHEQUES Desabilitada por enquanto
//ConOut("PALMJOB: Criando arquivo de Cheques para " + Trim(PALMUSER->P_USER) + " - " + Time())
//PalmCreate( aStruHEF,cArqHEF ,"HEF")

HB6->(dbCloseArea())
HE5->(dbCloseArea())
HTR->(dbCloseArea()) 

// Criacao de CHEQUES Desabilitada por enquanto
//HEF->(dbCloseArea()) 

Return

//retorna alias usados pelo servico
User Function PMOVTOTB()
Return {"SF2","SD2","SB1","SE5","SEF"}

//retorna nome fisico do arquivo espelho
User Function PMOVARQ()          
Local cArqHB6   :="HB6" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cArqHE5   :="HE5" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cArqHTR   :="HTR" + Left(PALMSERV->P_EMPFI,2) + "0"

// Por enquando nao vai controlar Cheques 
//Local cArqHEF   :="HEF" + Left(PALMSERV->P_EMPFI,2) + "0"

Return { cArqHB6,cArqHE5,cArqHTR }

//retorna indice usado pelo arquivo espelho
User Function PMOVIND()          
Local cIndHb6 := "B6_COD+B6_DOC+B6_SERIE"
Local cIndHe5 := "E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR"
Local cIndHtr := "TR_CLI+TR_LOJA"

Return { cIndHb6,cIndHe5,cIndHtr }

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PBancos  ³ Autor ³ Fabio Garbin          ³ Data ³ 20/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo Espelho de Bancos                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function PBancos()
 
Local aBanco    := {} // Contem os dados do arquivo de Bancos (SA6)
Local cBanco    :="HA6" + cEmpAnt + "0" //+(PSALIAS)->P_EMPFI 
Local aBnc      := {} , ni
Local cVendedor := PALMUSER->P_CODVEND
 
// Preenche o array com os campos a serem enviados
aadd(aBanco,{"A6_COD"     , "C",  4, 0}) // Codigo da Transp.
aadd(aBanco,{"A6_NOME"    , "C", 40, 0}) // Nome da Transp.
 
//If PalmLock(PALMUSER->P_SERIE) = "0"
ConOut("PALMJOB: Criando arquivo de Bancos para " + Trim(PALMUSER->P_USER) + " - " + Time())
//PalmCreate(<estrutura>,<arquivo>,<alias>)
PalmCreate(aBanco,cBanco,"BNC")
                
//Bancos
dbSelectArea("SA6")
dbSeek(xFilial("SA6"))
While !SA6->(Eof()) .and. SA6->A6_FILIAL == xFilial("SA6")
	nPos := aScan(aBnc,{|x| x[1] == SA6->A6_COD })
	If nPos = 0
		aAdd(aBnc, {SA6->A6_COD, SA6->A6_NOME})
	EndIf
	dbSelectArea("SA6")
	dbSkip()
EndDo    

For ni := 1 To Len(aBnc)
	dbSelectArea("BNC")
	RecLock("BNC",.T.)
	BNC->A6_COD    := aBnc[ni,1]
	BNC->A6_NOME   := aBnc[ni,2]
	BNC->(MsUnlock())
Next 
BNC->(dbCloseArea())
Return Nil
 
//retorna alias usado pelo servico
User Function PBncTab( )
Return {"SA6"}
 
//retorna nome fisico do arquivo espelho
User Function PBncArq( )
Local cFileBnc := "HA6" + Left(PALMSERV->P_EMPFI,2) + "0"
Return {cFileBnc}
 
//retorna indice usado pelo arquivo espelho
User Function PBncInd( )
cKeyBnc := "A6_COD"
Return {cKeyBnc}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PExpReceb  ³ Autor ³ Cleber Martinez     ³ Data ³ 10/05/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria	as tabelas de recebimento (HEL) e devolucao (HD1/HF1) ³±±
±±³          | 													          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ JOB	(Cliente FDA )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			   ³        ³                                                 ³±±
±±|            |        |                                                 ³±±
±±ÀÄÄÄ--ÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PExpReceb()

Local aRecebimentos := {} // Contem os dados do arquivo de Recebimentos
Local aDevCab	    := {} // Contem os dados do arquivo de Devol. (Cabec)
Local aDevItem		:= {} // Contem os dados do arquivo de Devol. (Itens)

Local cFileReceb  := "HEL" + cEmpAnt + "0" 
Local cFileDevCab := "HF1" + cEmpAnt + "0" 
Local cFileDevIte := "HD1" + cEmpAnt + "0" 

// Tabela de Recebimentos (SEL)
aAdd(aRecebimentos, {"EL_CLIENTE",	"C", 06, 0} )
aAdd(aRecebimentos, {"EL_LOJA",		"C", 02, 0} )
aAdd(aRecebimentos, {"EL_SEQ", 		"C", 03, 0} ) //Campo usado apenas no Handheld (EFFEM)
aAdd(aRecebimentos, {"EL_TIPODOC",	"C", 02, 0} )
aAdd(aRecebimentos, {"EL_PREFIXO", "C", 03, 0} )
aAdd(aRecebimentos, {"EL_NUMERO", 	"C", 06, 0} )
aAdd(aRecebimentos, {"EL_PARCELA", 	"C", 01, 0} )
aAdd(aRecebimentos, {"EL_VALOR",	"N", 17, 2} )
aAdd(aRecebimentos, {"EL_MOEDA",	"C", 02, 0} )
aAdd(aRecebimentos, {"EL_EMISSAO",	"D", 08, 0} )
aAdd(aRecebimentos, {"EL_DTVCTO",	"D", 08, 0} )
aAdd(aRecebimentos, {"EL_TPCRED",	"C", 01, 0} )
aAdd(aRecebimentos, {"EL_BANCO",	"C", 03, 0} )
aAdd(aRecebimentos, {"EL_AGENCIA",	"C", 05, 0} )
aAdd(aRecebimentos, {"EL_CONTA",	"C", 10, 0} )
aAdd(aRecebimentos, {"EL_BCOCHQ",	"C", 03, 0} )
aAdd(aRecebimentos, {"EL_AGECHQ",	"C", 05, 0} )
aAdd(aRecebimentos, {"EL_CTACHQ",	"C", 10, 0} )
aAdd(aRecebimentos, {"EL_OBSBCO",	"C", 20, 0} )
aAdd(aRecebimentos, {"EL_ACREBAN",	"C", 01, 0} )
aAdd(aRecebimentos, {"EL_TERCEIR",	"C", 01, 0} )
aAdd(aRecebimentos, {"EL_STATUS",	"C", 01, 0} )
aAdd(aRecebimentos, {"EL_COND",		"C", 03, 0} )

//Tabela de Devolucoes (Cabec.)
aAdd(aDevCab, {"F1_TIPO",		"C", 01, 0} )
aAdd(aDevCab, {"F1_FORMUL",		"C", 01, 0} )
aAdd(aDevCab, {"F1_DOC",		"C", 06, 0} )
aAdd(aDevCab, {"F1_SERIE",		"C", 03, 0} )
aAdd(aDevCab, {"F1_EMISSAO",	"D", 08, 0 } )
aAdd(aDevCab, {"F1_FORNECE",	"C", 06, 0} )
aAdd(aDevCab, {"F1_LOJA",		"C", 02, 0} )
aAdd(aDevCab, {"F1_ESPECIE",	"C", 03, 0} )
aAdd(aDevCab, {"F1_COND",		"C", 03, 0} )
aAdd(aDevCab, {"F1_DESPESA",	"N", 10, 0} )
aAdd(aDevCab, {"F1_QTDITE", 	"N", 04, 0} )
aAdd(aDevCab, {"F1_STATUS",		"C", 01, 0} )
aAdd(aDevCab, {"F1_VALOR",		"N", 14, 2} )

//Tabela de Devolucoes (Item)
aAdd(aDevItem, {"D1_DOC",	 	"C", 06, 0} )
aAdd(aDevItem, {"D1_ITEM",		"C", 04, 0} )
aAdd(aDevItem, {"D1_COD",		"C", 15, 0} )
aAdd(aDevItem, {"D1_QUANT",		"N", 10, 0} )
aAdd(aDevItem, {"D1_VUNIT",		"N", 14, 2} )
aAdd(aDevItem, {"D1_TOTAL",		"N", 14, 2} )
aAdd(aDevItem, {"D1_TES",		"C", 03, 0} )
aAdd(aDevItem, {"D1_NFORI",	 	"C", 06, 0} )
aAdd(aDevItem, {"D1_SERIORI",	"C", 03, 0} )
aAdd(aDevItem, {"D1_ITEMORI",	"C", 04, 0} )
aAdd(aDevItem, {"D1_LOTECTL",	"C", 10, 0} )
aAdd(aDevItem, {"D1_DTVALID",	"D",  8, 0} )
if cPaisLOc<>"BRA"
   aAdd(aDevItem, {"D1_IVA",		"N", 14, 2} )
endif   

ConOut("PALMJOB: Criando arquivos de Recebimento para " + Trim(PALMUSER->P_USER) + " - " + Time())

PalmCreate(aRecebimentos, cFileReceb ,"HEL")
PalmCreate(aDevCab  , cFileDevCab    ,"HF1")
PalmCreate(aDevItem , cFileDevIte 	 ,"HD1")

HEL->(dbCloseArea()) 
HF1->(dbCloseArea()) 
HD1->(dbCloseArea())

Return                  

//retorna alias usados pelo servico
User Function PRecTab( )
Return {"SEL","SF1","SD1"}

//retorna nome fisico do arquivo espelho
User Function PRecArq( )          
Local cFileReceb  := "HEL" + Left(PALMSERV->P_EMPFI,2) + "0" 
Local cFileDevCab := "HF1" + Left(PALMSERV->P_EMPFI,2) + "0" 
Local cFileDevIte := "HD1" + Left(PALMSERV->P_EMPFI,2) + "0" 
Return {cFileReceb,cFileDevCab,cFileDevIte}

//retorna indice usado pelo arquivo espelho
User Function PRecInd( )
Return {"EL_CLIENTE+EL_LOJA+EL_SEQ","F1_DOC+F1_SERIE","D1_DOC+D1_ITEM"}


/*
Excessoes Fiscais 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PExcesFis  ³ Autor ³ Marcelo Vieira      ³ Data ³ 14/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Exporta a tabela de excessoes fiscais     				  ³±±
±±³          | 													          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ JOB	(Cliente FDA )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			   ³        ³                                                 ³±±
±±|            |        |                                                 ³±±
±±ÀÄÄÄ--ÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PExcesFis()
Local aExcesFis   := {} // Contem os dados do arquivo de Devol. (Cabec)
Local cFileExces  := "HF7" + cEmpAnt + "0" 
Local cUsaExecFis := GetMV("MV_FDAEXCF",,"N")

// Tabela de Excessoes Fiscais (SF7)

aAdd(aExcesFis, {"F7_GRTRIB",	"C", 03, 0} )
aAdd(aExcesFis, {"F7_SEQUEN",	"C", 02, 0} )
aAdd(aExcesFis, {"F7_EST", 		"C", 02, 0} ) 
aAdd(aExcesFis, {"F7_TIPOCLI",	"C", 01, 0} )
aAdd(aExcesFis, {"F7_ALIQINT", "N", 05,  2} )
aAdd(aExcesFis, {"F7_ALIQEXT", 	"N", 05, 2} )
aAdd(aExcesFis, {"F7_MARGEM", 	"N", 05, 2} )
aAdd(aExcesFis, {"F7_ALIQDST",	"N", 5,  2} )
aAdd(aExcesFis, {"F7_GRPCLI",	"C", 03, 0} )
aAdd(aExcesFis, {"F7_ISS"   ,	"C", 01, 0} )
aAdd(aExcesFis, {"F7_VLR_ICM",	"N", 09, 2} )
aAdd(aExcesFis, {"F7_VLR_IPI",	"N", 09, 2} )

ConOut("PALMJOB: Criando arquivos de Excessoes Fiscais para " + Trim(PALMUSER->P_USER) + " - " + Time())
PalmCreate(aExcesFis, cFileExces ,"HF7")

if cUsaExecFis=="S" 

   dbSelectArea("SF7") 

   do While SF7->( !eof() )

       dbSelectArea("HF7")
       RecLock("HF7",.T.)

	   HF7->F7_GRTRIB := SF7->F7_GRTRIB
	   HF7->F7_SEQUEN := SF7->F7_SEQUEN
	   HF7->F7_EST	  := SF7->F7_EST
	   HF7->F7_TIPOCLI:= SF7->F7_TIPOCLI
	   HF7->F7_ALIQINT:= SF7->F7_ALIQINT
	   HF7->F7_ALIQEXT:= SF7->F7_ALIQEXT
	   HF7->F7_MARGEM := SF7->F7_MARGEM
	   HF7->F7_ALIQDST:= SF7->F7_ALIQDST
	   HF7->F7_GRPCLI := SF7->F7_GRPCLI
  	   HF7->F7_ISS	  := SF7->F7_ISS
	   HF7->F7_VLR_ICM:= SF7->F7_VLR_ICM
	   HF7->F7_VLR_IPI:= SF7->F7_VLR_IPI
	   
       HF7->(MsUnlock())
                        
      dbSelectArea("SF7")
      SF7->( dbSkip() )
      
   Enddo   
   
Endif

HF7->(dbCloseArea()) 

Return                  

//retorna alias usados pelo servico
User Function PExcFTab( )
Return {"SF7"}

//retorna nome fisico do arquivo espelho
User Function PExcFArq( )          
Local cFileExces  := "HF7" + Left(PALMSERV->P_EMPFI,2) + "0" 
Return {cFileExces}

//retorna indice usado pelo arquivo espelho
User Function PExcFInd( )
Return {"F7_GRTRIB+F7_GRPCLI+F7_SEQUEN"}
