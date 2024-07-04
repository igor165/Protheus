#INCLUDE "AGRX500.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//=============================================================================
/*****  Funções de geração de pendências da rotina AGRX500 - Romaneios  *****/
//=============================================================================


/*/{Protheus.doc} AGRX500PEN
//Função para geração de pendências 

@author 	ana.olegini
@since 		23/01/2018
@version 	P12
@return 	lRetorno, Retorna verdadeiro ou falso
/*/
Function AGRX500PEN(cRomaneio, cSafra, cEntidade, cLojEnt, nPesoLiq, lTemRastro)
	Local lRetorno 	:= .F.
	Local cTMP01	:= GetNextAlias()
	Local cQuery	:= ""
	Local aCab		:= {}
	Local nPesoPen	:= 0
	Local cProduto  := ""
	Local aDadosRom := {}
	
	//-- DXL - Fardão / DXB - Produção x Fardão
	cQuery := " SELECT DXL_FILIAL, DXL_CODIGO, DXL_SAFRA,"
	cQuery +=        " DXL_PSESTI, DXL_PSFISC, DXL_PSLIQU, DXL_CODPRO, "
	cQuery +=        " (DXL_PSLIQU - DXL_PSESTI) PENDENCIA"
	cQuery +=   " FROM " + RetSqlName('DXL')+ " DXL "	 

	cQuery +=  " WHERE DXL.D_E_L_E_T_	= '' "
	cQuery +=    " AND DXL.DXL_FILIAL	= '"+ FWxFilial("DXL") 	+"'"
	cQuery +=    " AND DXL.DXL_SAFRA	= '"+ cSafra 			+"'"
	cQuery +=    " AND DXL.DXL_PRDTOR	= '"+ cEntidade 		+"'"
	cQuery +=    " AND DXL.DXL_LJPRO	= '"+ cLojEnt 			+"'"
	cQuery +=    " AND DXL.DXL_PSESTI	> 0 "
	//-- VERIFICA SE EXISTE PENDENCIAS 
	cQuery +=    " AND NOT EXISTS ( SELECT N9C_PESLIQ  FROM  " + RetSqlName('N9C')+ " N9C " 
	cQuery +=                                        " WHERE N9C.D_E_L_E_T_ = '' "	
	cQuery +=                                          " AND N9C.N9C_STATUS = '1' 			  AND N9C.N9C_FILIAL	= '"+ FWxFilial("N9C") +"'"
	cQuery +=                                          " AND N9C.N9C_CODSAF	= DXL.DXL_SAFRA   AND N9C.N9C_CODENT	= DXL.DXL_PRDTOR  "
	cQuery +=                                          " AND N9C.N9C_LOJENT	= DXL.DXL_LJPRO   AND N9C.N9C_CODROM	= '"+ cRomaneio + "')"
	//--VERIFICA SE EXISTE PRODUÇÃO X FARDAO
	cQuery +=    " AND EXISTS ( SELECT DXB_FARDAO FROM  " + RetSqlName('DXB')+ " DXB "  	
	cQuery +=                                        " WHERE DXB.D_E_L_E_T_ = ''              AND DXB.DXB_FILIAL = '"+ FWxFilial("DXB") +"'" 
	cQuery +=                                          " AND DXB.DXB_SAFRA  = DXL.DXL_SAFRA   AND DXB.DXB_FARDAO = DXL.DXL_CODIGO "
	cQuery +=                                          " AND DXB.DXB_ROTINA = 'AGRA601'	)"				 
	//--VERIFICA SE EXISTE RELACIONAMENTO FARDÃO X ROMANEIO
	cQuery +=    " AND EXISTS ( SELECT DX0_FARDAO FROM  " + RetSqlName('DX0')+ " DX0 "  	
	cQuery +=                                        " WHERE DX0.D_E_L_E_T_ = ''              AND DX0.DX0_FILIAL = '"+ FWxFilial("DX0") +"'" 
	cQuery +=                                          " AND DX0.DX0_FARDAO = DXL.DXL_CODIGO  AND DX0.DX0_NRROM = '"+ cRomaneio + "')"				 
	cQuery := ChangeQuery( cQuery )

	//--Identifica se tabela esta aberta e fecha
	If Select(cTMP01) <> 0
		(cTMP01)->(dbCloseArea())
	EndIf
				
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTMP01,.T.,.T.)
	If (cTMP01)->( !Eof() )
	
		lTemRastro := .T. //para não gerar OP quando há rastro de produção
		
		IF (cTMP01)->DXL_PSESTI <> (cTMP01)->DXL_PSLIQU //tem diferença entre peso líquido e peso estimado
		
			cProduto := (cTMP01)->DXL_CODPRO
			
			aAdd( aCab, { "DXL_CODIGO"  , (cTMP01)->DXL_CODIGO  } )	//1
			aadd( aCab, { "DXL_SAFRA" 	, (cTMP01)->DXL_SAFRA 	} )	//2
			aadd( aCab, { "DXL_PRDTOR" 	, cEntidade 			} )	//3
			aadd( aCab, { "DXL_LJPRO" 	, cLojEnt 				} )	//4
			aadd( aCab, { "DXL_CODROM" 	, cRomaneio			 	} )	//5
			
			//-- para cada fardão encontrado salva a quantidade para pendencia
			While (cTMP01)->( !Eof() )
				
				//--Soma a quantidade total de todos os fardões para calculo da pendencia
				nPesoPen += (cTMP01)->DXL_PSESTI 
				
				//--proximo registro tabela principal
				(cTMP01)->(dbSkip())			
			EndDo
			
			//-- Salva o peso total da pendecia (Peso de todos os fardões vinculados)
			aadd( aCab, { "PESOFISICO",  nPesoPen			} )	//6
			
			//--Resultado do valor da pendencia 
			//-- nPesoLiq = Peso Liquido do ROmaneio - Peso total 
			//-- nPesoPen = Peso da Pendecia (Peso de todos os fardões vinculados)
			aadd( aCab, { "PENDENCIA",  nPesoLiq - nPesoPen	} )	//7
			aadd( aCab, { "DXL_CODPRO" 	, cProduto} )	//8
			
			if nPesoLiq > nPesoPen
				aadd( aCab, { "PESOLIQUIDO",  nPesoLiq - nPesoPen	} )	//9
			else
				aadd( aCab, { "PESOLIQUIDO",  nPesoLiq				} )	//9
			endIf		
	        
			aDadosRom := AGRX500ROM()
			aadd( aCab, { "FILROM" 	, aDadosRom[1] 	            } )	//10
			aadd( aCab, { "ROMORI" 	, aDadosRom[2] 	            } )	//11
			
			DbSelectArea("NJM")
			DbSetOrder(1) //FILIAL+ROMANEIO
			
			If NJM->(MsSeek(FwXFilial("NJM") + NJJ->NJJ_CODROM))
				aadd( aCab, { "LOTCTL" 	, NJM->NJM_LOTCTL		} )	//12
				aadd( aCab, { "NMLOT" 	, NJM->NJM_NMLOT      	} )	//13
				aadd( aCab, { "LOCLIZ" 	, NJM->NJM_LOCLIZ		} )	//14
			EndIf 
			
			NJM->(dbCloseArea())
		EndIf
	EndIf	
	
	If Len(aCab) > 0
		//-- CHAMA FUNCAO GERADORA DE PENDENCIAS
		lRetorno := A500PenFF(aCab,"1") //pendência física 		
	else
		lRetorno := .T.		
	EndIf


	If lRetorno
			If RecLock( "NJJ", .F. )
				NJJ->NJJ_STATUS := '3'
				NJJ->( msUnLock() )
			EndIf
	EndIf

Return lRetorno


/*/{Protheus.doc} AGRX500PFG
//Gera pendência de diferença entre peso fiscal e peso líquido - GRANEL 
@author silvana.torres
@since 05/02/2018
@version undefined
@param cRomaneio, characters, descricao
@param cSafra, characters, descricao
@param cEntidade, characters, descricao
@param cLojEnt, characters, descricao
@param nPesoLiq, numeric, descricao
@param nQtdFis, numeric, descricao
@param cToEtap, characters, descricao
@type function
/*/
Function AGRX500PFG(cRomaneio, cSafra, cEntidade, cLojEnt, nPesoLiq, nQtdFis, cToEtap)

	Local aArea     := GetArea()
	Local lRet 		:= .F.
	Local aCab		:= {}
	Local cFilTemp  := cFilAnt
	Local cFilCli	:= ""
	Local aDadosNJ0 := {}
	Local aDadosRom := {}

	aAdd( aCab, { "CODIGO"  , ""  					} )	//1
	aadd( aCab, { "SAFRA" 	, cSafra 				} )	//2
	aadd( aCab, { "PRDTOR" 	, cEntidade 			} )	//3
	aadd( aCab, { "LJPRO" 	, cLojEnt 				} )	//4
	aadd( aCab, { "NMROM" 	, cRomaneio			 	} )	//5
	
	aadd( aCab, { "PESOFISCAL", nQtdFis				} )	//6		//-- Salva o peso da pendencia (Peso da NF)	
	aadd( aCab, { "PENDENCIA" , nPesoLiq - nQtdFis	} )	//7  	//--Resultado do valor da pendencia 	
	aadd( aCab, { "PRODUTO"   , NJJ->NJJ_CODPRO		} )	//8
	
	if nPesoLiq > nQtdFis
		aadd( aCab, { "PESOLIQUIDO",  nPesoLiq - nQtdFis	} )	//9
	else
		aadd( aCab, { "PESOLIQUIDO",  nPesoLiq				} )	//9
	endIf	
		
	aDadosRom := AGRX500ROM()
	aadd( aCab, { "FILROM" 	, aDadosRom[1] 	        } )	//10
	aadd( aCab, { "ROMORI" 	, aDadosRom[2] 	        } )	//11
	
	DbSelectArea("NJM")
	DbSetOrder(1) //FILIAL+ROMANEIO
	
	If NJM->(MsSeek(FwXFilial("NJM") + NJJ->NJJ_CODROM))
		aadd( aCab, { "LOTCTL" 	, NJM->NJM_LOTCTL			} )	//12
		aadd( aCab, { "NMLOT" 	, NJM->NJM_NMLOT      		} )	//13
		aadd( aCab, { "LOCLIZ" 	, NJM->NJM_LOCLIZ			} )	//14
	EndIf 
	
	NJM->(dbCloseArea())
	
	//-- CHAMA FUNCAO GERADORA DE PENDENCIAS
	lRet := A500PenFF(aCab, "2") //fiscal

	If lRet	
		//verifica se a produção é de outra filial
		cFilCli := AGRX500POF(NJJ->NJJ_CODENT, NJJ->NJJ_LOJENT) 
		if cFilCli <> ""
		
			//verifica se alguma etapa, do tipo de operação usado, movimenta origem 
			if AGRX500MO(cToEtap)	
				//busca entidade/loja da filial destino
				aDadosNJ0  := AGRX500ENL(cFilTemp)
				aCab[3][2] := aDadosNJ0[1] //3 (entidade)
				aCab[4][2] := aDadosNJ0[2] //4 (loja)

				cFilAnt := cFilCli	
				
				lRet := A500PenFF(aCab, "2", cFilTemp) //fiscal
				
				cFilAnt := cFilTemp
			endIf 
		endIf
		
		if lRet
			If RecLock( "NJJ", .F. )
				NJJ->NJJ_STATUS := '3'
				NJJ->( msUnLock() )
			EndIf
		endIf
	EndIf
	
	RestArea(aArea)

Return lRet


/*/{Protheus.doc} AGRX500PFA
//Gera pendência de diferença entre peso fiscal e peso líquido - ALGODÃO 
@author silvana.torres
@since 05/02/2018
@version undefined
@param cRomaneio, characters, descricao
@param cSafra, characters, descricao
@param cEntidade, characters, descricao
@param cLojEnt, characters, descricao
@param nPesoLiq, numeric, descricao
@param nQtdFis, numeric, descricao
@param cToEtap, characters, descricao
@type function
/*/
Function AGRX500PFA(cRomaneio, cSafra, cEntidade, cLojEnt, nPesoLiq, nQtdFis, cToEtap)
	
	Local aArea     := GetArea()
	Local lRet 		:= .F.
	Local cAlias	:= GetNextAlias()
	Local cQuery	:= ""
	Local aCab		:= {}
	Local cFilTemp  := cFilAnt
	Local cFilCli	:= "" 
	Local aDadosNJ0 := {}
	Local aDadosRom := {}

	cQuery := " SELECT DXL_FILIAL, DXL_CODIGO, DXL_SAFRA,"
	cQuery +=        " DXL_PSESTI, DXL_PSFISC, DXL_PSLIQU, DXL_CODPRO "
	cQuery +=   " FROM " + RetSqlName('DXL')+ " DXL "	 
	cQuery +=  " WHERE DXL.D_E_L_E_T_	= '' "
	cQuery +=    " AND DXL.DXL_FILIAL	= '"+ FWxFilial("DXL") 	+"'"
	cQuery +=    " AND DXL.DXL_SAFRA	= '"+ cSafra 			+"'"
	//cQuery +=    " AND DXL.DXL_PRDTOR	= '"+ cEntidade 		+"'"
	//cQuery +=    " AND DXL.DXL_LJPRO	= '"+ cLojEnt 			+"'"
	//-- VERIFICA SE EXISTE PENDENCIAS DE DIFERENÇA DE PESO FISCAL 
	cQuery +=    " AND NOT EXISTS ( SELECT N9C_PESLIQ  
	cQuery +=    " 					  FROM  " + RetSqlName('N9C')+ " N9C " 
	cQuery +=                      " WHERE N9C.D_E_L_E_T_ 	= '' "	
	cQuery +=                        " AND N9C.N9C_STATUS 	= '1' 			  "
	cQuery +=                        " AND N9C.N9C_TPPEN 	IN ('2','4') 		  "
	cQuery +=    " 					   AND N9C.N9C_FILIAL	= '"+ FWxFilial("N9C") +"'"
	cQuery +=    " 					   AND N9C.N9C_CODSAF	= DXL.DXL_SAFRA   "
	cQuery +=    " 					   AND N9C.N9C_CODENT	= DXL.DXL_PRDTOR  "
	cQuery +=    " 					   AND N9C.N9C_LOJENT	= DXL.DXL_LJPRO   "
	cQuery +=    " 					   AND N9C.N9C_CODROM	= '" + cRomaneio + "' ) "	
	//--VERIFICA SE EXISTE RELACIONAMENTO FARDÃO X ROMANEIO
	cQuery +=    " AND EXISTS ( SELECT DX0_FARDAO FROM  " + RetSqlName('DX0')+ " DX0 "  	
	cQuery +=                                        " WHERE DX0.D_E_L_E_T_ = ''              AND DX0.DX0_FILIAL = '"+ FWxFilial("DX0") +"'" 
	cQuery +=                                          " AND DX0.DX0_FARDAO = DXL.DXL_CODIGO  AND DX0.DX0_CODUNI = DXL.DXL_CODUNI "
	cQuery +=                                          " AND DX0.DX0_NRROM = '"+ cRomaneio + "')"				 
		 
	cQuery := ChangeQuery( cQuery )

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.T.,.T.)
	
	If (cAlias)->( !Eof() )
		
		lRet := .T.
		
		aAdd( aCab, { "DXL_CODIGO"  , (cAlias)->DXL_CODIGO  } )	//1
		aadd( aCab, { "DXL_SAFRA" 	, cSafra 				} )	//2
		aadd( aCab, { "DXL_PRDTOR" 	, cEntidade 			} )	//3
		aadd( aCab, { "DXL_LJPRO" 	, cLojEnt 				} )	//4
		aadd( aCab, { "DXL_CODROM" 	, cRomaneio			 	} )	//5
	
		//-- Salva o peso da pendeNcia (Peso da NF)
		aadd( aCab, { "PESOFISCAL",  nQtdFis				} )	//6
		
		//--Resultado do valor da pendencia 
		aadd( aCab, { "PENDENCIA",  nPesoLiq - nQtdFis		} )	//7
		aadd( aCab, { "DXL_CODPRO" 	, (cAlias)->DXL_CODPRO 	} )	//8
		
		if nPesoLiq > nQtdFis
			aadd( aCab, { "PESOLIQUIDO",  nPesoLiq - nQtdFis	} )	//9
		else
			aadd( aCab, { "PESOLIQUIDO",  nPesoLiq				} )	//9
		endIf	
				
		aDadosRom := AGRX500ROM()
		aadd( aCab, { "FILROM" 	, aDadosRom[1] 	            } )	//10
		aadd( aCab, { "ROMORI" 	, aDadosRom[2] 	            } )	//11
		
		DbSelectArea("NJM")
		DbSetOrder(1) //FILIAL+ROMANEIO
		
		If NJM->(MsSeek(FwXFilial("NJM") + NJJ->NJJ_CODROM))
			aadd( aCab, { "LOTCTL" 	, NJM->NJM_LOTCTL		} )	//12
			aadd( aCab, { "NMLOT" 	, NJM->NJM_NMLOT      	} )	//13
			aadd( aCab, { "LOCLIZ" 	, NJM->NJM_LOCLIZ		} )	//14
		EndIf 
		
		NJM->(dbCloseArea())
	EndIf	
	
	If Len(aCab) > 0 .AND. lRet
	
		//-- CHAMA FUNCAO GERADORA DE PENDENCIAS
		lRet := A500PenFF(aCab, "2") //fiscal

		If lRet
		
			//verifica se a produção é de outra filial
			cFilCli := AGRX500POF(NJJ->NJJ_CODENT, NJJ->NJJ_LOJENT) 
			if cFilCli <> ""
			
				//verifica se alguma etapa, do tipo de operação usado, movimenta origem 
				if AGRX500MO(cToEtap)	
					//busca entidade/loja da filial destino
					aDadosNJ0  := AGRX500ENL(cFilTemp)
					aCab[3][2] := aDadosNJ0[1] //3 (entidade)
					aCab[4][2] := aDadosNJ0[2] //4 (loja)
					
					cFilAnt := cFilCli	
					
					lRet := A500PenFF(aCab, "2", cFilTemp) //fiscal
					
					cFilAnt := cFilTemp
				endIf 
			endIf
			
			if lRet
				If RecLock( "NJJ", .F. )
					NJJ->NJJ_STATUS := '3'
					NJJ->( msUnLock() )
				EndIf
			endIf
		EndIf
	EndIf

	RestArea(aArea)
	
Return lRet


/*/{Protheus.doc} A500PenFF
//Função para criar pendencia fisica/fiscal

@author ana.olegini
@since 23/01/2018
@version P12
@return lRetorno, Retorna verdaeiro ou falso 
/*/
Function A500PenFF(aCab, cTipo, cFilOriPen)
	Local lRetorno 		:= .T.
	
	Default cFilOriPen 	:= ""
	
	//OBSERVAÇÃO = tabela não possui rotina MVC
	//-- Inclusão na tabela N9B - Cabeçalho Pendencia
	dbSelectArea('N9B')
	N9B->( dbSetOrder(1) )	
	If .Not. MsSeek( FWxFilial("N9B")+aCab[2][2]+aCab[3][2]+aCab[4][2]+aCab[8][2])
		RecLock('N9B', .T.)
			N9B->N9B_FILIAL := FWxFilial("N9B")
			N9B->N9B_CODSAF := aCab[2][2]
			N9B->N9B_CODENT := aCab[3][2]
			N9B->N9B_LOJENT := aCab[4][2]
			
			If cTipo == '1' //físico
			   N9B->N9B_FISICO := N9B->N9B_FISICO + aCab[7][2]    //1=Complemento Fisico;3=Devolucao Fisica
			Else  //fiscal 
			   N9B->N9B_FISCAL := N9B->N9B_FISCAL + aCab[7][2]    //2=Complemento Fiscal;4=Devolucao Fiscal
			EndIf   
			
			N9B->N9B_CODPRO := aCab[8][2] 
		N9B->(msUnLock())
	Else
		RecLock('N9B', .F.)
			If cTipo == '1' //físico
			   N9B->N9B_FISICO := N9B->N9B_FISICO + aCab[7][2]    //1=Complemento Fisico;3=Devolucao Fisica
			Else  //fiscal 
			   N9B->N9B_FISCAL := N9B->N9B_FISCAL + aCab[7][2]    //2=Complemento Fiscal;4=Devolucao Fiscal
			EndIf   
		N9B->(msUnLock())			
	EndIf
		
	cItens := A500NumPen(aCab[2][2], aCab[3][2], aCab[4][2])			//envia a safra e produtor
	//-- Inclusão na tabela N9C - Itens Pendencia
	dbSelectArea("N9C")		
	RecLock('N9C', .T.)
		N9C->N9C_FILIAL := FWxFilial("N9C")
		N9C->N9C_CODSAF := aCab[2][2]
		N9C->N9C_CODENT := aCab[3][2]
		N9C->N9C_LOJENT := aCab[4][2]
		N9C->N9C_ITEM   := Soma1(cItens)
		N9C->N9C_CODROM := aCab[5][2]
		N9C->N9C_FILORI := cFilOriPen				
		N9C->N9C_QTDPEN := aCab[7][2] 
		N9C->N9C_CODPRO := aCab[8][2]
		
		if cTipo == '1' //físico
			N9C->N9C_TPPEN  := If( aCab[7][2] > 0, '1', '3' )		//1=Complemento Fisico;3=Devolucao Fisica
			N9C->N9C_PESLIQ := aCab[9][2]
		elseIf cTipo == '2' //fiscal			
			N9C->N9C_TPPEN  := If( aCab[7][2] > 0, '2', '4' )		//2=Complemento Fiscal;4=Devolucao Fiscal
			N9C->N9C_PESLIQ := aCab[9][2]
		endIf
		
		N9C->N9C_STATUS := '1'									//1=Aberta;2=Finalizada
		N9C->N9C_FILROM := aCab[10][2]
		N9C->N9C_ROMORI := aCab[11][2]
		N9C->N9C_LOTCTL := aCab[12][2]
		N9C->N9C_NMLOT 	:= aCab[13][2]
		N9C->N9C_LOCLIZ := aCab[14][2]
	N9C->(msUnLock())

Return lRetorno


/*/{Protheus.doc} A500NumPen
//Função para retornar o sequencial do item conforme a safra e produtor/entidade

@author ana.olegini
@since 26/01/2018
@version P12
@return cItens, retorna o item sequencial 
/*/
Static Function A500NumPen(cSafra, cProdutor, cLojProd)
	Local cTMP02	:= GetNextAlias()
	Local cQuery	:= ""

	cQuery := " SELECT MAX(N9C_ITEM) MAXIMO FROM " + RetSqlName('N9C')+ " N9C "
	cQuery +=  " WHERE N9C_CODSAF = '"+ cSafra	 	+"'"
	cQuery +=     "AND N9C_CODENT = '"+ cProdutor 	+"'"
	cQuery +=     "AND N9C_LOJENT = '"+ cLojProd	+"'"
	
	cQuery := ChangeQuery( cQuery )

	//--Identifica se tabela esta aberta e fecha
	If Select(cTMP02) <> 0
		(cTMP02)->(dbCloseArea())
	EndIf
				
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTMP02,.T.,.T.)
	If Select(cTMP02) <> 0
		IF .NOT. EMPTY( (cTMP02)->MAXIMO )
			cItens := (cTMP02)->MAXIMO
		Else
			cItens := '0000000000'
		EndIf
	EndIf
	(cTMP02)->(dbCloseArea())

Return cItens

