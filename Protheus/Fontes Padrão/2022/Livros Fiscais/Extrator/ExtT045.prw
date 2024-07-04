#Include "Protheus.ch"
#Include "TOPCONN.ch"
#Include "RwMake.ch"
#Include "FILEIO.CH"

//DEFINES PARA O BLOCO K
#Define 0210 1
#Define K001 2
#Define K100 3
#Define K200 4
#Define K210 5
#Define K215 6
#Define K220 7
#Define K230 8
#Define K235 9
#Define K250 10
#Define K255 11
#Define K260 12
#Define K265 13
#Define K270 14
#Define K275 15
#Define K280 16
#Define K990 17
#Define 0200 18

/*/{Protheus.doc} RegT045
	(Realiza a geracao do registro T045 do TAF)

	@type Function
	@author Vitor Henrique
	@since 16/09/2016

	@Param n_HdlT007, numerico, Random do arquivo T007
	@Param n_HdlT003, numerico, Random do arquivo T003
	@Param a_Produtos, array, Produtos do registro T007
	@Param a_Particip, array, Participantes do registro T003

	@Return lGerou, logico, se gerou ou não.
	/*/
Function ExtT045(n_HdlT003,n_HdlT007,a_Produtos,a_Particip)

	Local aRegs0210    := {}
	Local aRegsK100    := {}
	Local aRegsK200    := {}
	Local aRegsK220    := {}
	Local aRegsK21X    := {}
	Local aRegsK23X    := {}
	Local aRegsK235    := {}
	Local aRegsK25X    := {}
	Local aRegsK26X    := {}
	Local aRegsK27X    := {}
	Local aRegsK280    := {}
	Local aProdK       := {}
	Local aProdKUnic   := {}
	Local aProdUnic    := {}
	Local aPartK       := {}
	Local aPartKUnic   := {}
	Local aPartUnic    := {}
	Local aChaves	   := {}
	Local aInfoMXSped  := {}
	Local aAliProc     := ARRAY(18)
	Local cReg         := "T045"
	Local cRegFilho    := ""
	Local cCodPart 	   := ""
	Local cProdAnt0210 := ""
	Local cCodProd	   := ""
	Local nI 		   := 1
	Local nY 		   := 1
	Local nCnt		   := 1
	Local cTxtSys      := cDirSystem + "\" + cReg + ".TXT"
	Local nHdlTxt	   := IIf( cTpSaida == "1" , MsFCreate( cTxtSys ) , 0 )
	Local cDataDe      := DToS(oWizard:GetDataDe())
	Local cDataAte     := DToS(oWizard:GetDataAte())
	Local lVirgula	   := .F.
	Local lMov0210     := oWizard:GetReg0210Mov() == '1' // Gera infomarções do Bloco K e do REG0210
	Local lProcBlK	   := .T.
	Local cAli0210	   := GetNextAlias()
	Local cAliK001	   := GetNextAlias()
	Local cAliK100	   := GetNextAlias()
	Local cAliK200	   := GetNextAlias()
	Local cAliK210	   := GetNextAlias()
	Local cAliK215	   := GetNextAlias()
	Local cAliK220	   := GetNextAlias()
	Local cAliK230	   := GetNextAlias()
	Local cAliK235	   := GetNextAlias()
	Local cAliK250	   := GetNextAlias()
	Local cAliK255	   := GetNextAlias()
	Local cAliK260	   := GetNextAlias()
	Local cAliK265	   := GetNextAlias()
	Local cAliK270	   := GetNextAlias()
	Local cAliK275	   := GetNextAlias()
	Local cAliK280	   := GetNextAlias()
	Local cAliK990	   := GetNextAlias()
	Local cAli0200	   := GetNextAlias()
	Local nDecPerda	   := 4 //TamSx3("G1_PERDA")[2] setado 4, pois o layout do taf exige isso, deixei a dica do campo G1_PERDA para caso seja pedido no futuro
	Local nDeQtcomp	   := 6 //TamSx3("D4_QTDEORI")[2] setado 6, pois o layout do taf exige isso, deixei a dica do campo D4_QTDEORI para caso seja pedido no futuro
	Local aAlias	   := 	{cAli0210,cAliK001,cAliK100,cAliK200,cAliK210,cAliK215,cAliK220,cAliK230,;
							cAliK235,cAliK250,cAliK255,cAliK260,cAliK265,cAliK270,cAliK275,cAliK280,cAliK990,cAli0200}
	Local aIndTRB := {}
	local lGrava  := .T.
	Local lBlkApg := FindFunction("BlkApgArq")
	Local lGerou := .F.

	Default n_HdlT003:= 0
	Default n_HdlT007:= 0

	Default a_Produtos  := {}
	Default a_Particip  := {}

	aInfoMXSped	:=	getapoinfo("MATXSPED.PRW")

	lProcBlK := val( subStr( dToS( aInfoMXSped[ 4 ] ) , 5 , 2 ) ) > 9 .or. year( aInfoMXSped[ 4 ] ) > 2016
	AFill(aAliProc,.T.)
	If lProcBlK
		//Chama a function para geração das inf. do bloco K
		aIndTRB :=  SPDBlocoK(Stod(cDataDe),Stod(cDataAte), @aAlias,@aAliProc, lMov0210)
		
		//se estiver vazio é porque existe imcompatibilidade entre as versões, não realizo o processamento
		If Empty( aIndTRB )
			lGrava := .F.
		Else
			/*----------------------------------------------------------
						Informações do Registro K100
			----------------------------------------------------------*/
			If Select(aAlias[K100]) > 0
				cReg := "T045"
				DbSelectArea( aAlias[K100] )
				While (aAlias[K100])->( !Eof() )
					lGerou := .T.
				
					(aAlias[K100])->( Aadd( aRegsK100, { {cReg, DT_INI, DT_FIN }} ) )	
						
					(aAlias[K100])-> ( DbSkip() )
				EndDo
			EndIf
			/*----------------------------------------------------------
						Informações do Registro K200
			----------------------------------------------------------*/
			cReg := "T045AA"
			If Select(aAlias[K200]) > 0
				DbSelectArea( aAlias[K200] )
				While (aAlias[K200])->( !Eof() )
					
					//Ajusta o codigo do participante
					If !Empty((aAlias[K200])->(COD_PART))
						If Substr((aAlias[K200])->(COD_PART), 1, 3) == 'SA1'
							cCodPart := 'C' 
						ElseIf Substr((aAlias[K200])->(COD_PART), 1, 3) == 'SA2'
							cCodPart := 'F' 
						EndIf 
						
						cCodPart += Substr((aAlias[K200])->(COD_PART), 4, 6)
					EndIf
					
					//Garante que não vai registro repetido
					If aScan(aChaves, Alltrim((aAlias[K200])->(Dtoc(DT_EST)+COD_ITEM+IND_EST+cCodPart))) == 0
					
						(aAlias[K200])->( Aadd( aRegsK200, { {cReg, DT_EST, COD_ITEM, QTD, IND_EST, cCodPart }} ) )
						
						//Adiciona os produtos do registro em um array
						Aadd(aProdK,(aAlias[K200])->(COD_ITEM))
						
						//Adiciona os participante do registro em um array
						Aadd(aPartK,cCodPart)
						
						//Adiciona chave de registro em arraray
						Aadd(aChaves , Alltrim((aAlias[K200])->(Dtoc(DT_EST)+COD_ITEM+IND_EST+cCodPart))) 
						
					EndIf
					
					cCodPart := ''
					
					(aAlias[K200])-> ( DbSkip() )
				EndDo
			EndIf
			/*----------------------------------------------------------
						Informações do Registros K210 e K215
			----------------------------------------------------------*/
			If Select(aAlias[K210]) > 0 .And. Select(aAlias[K215]) > 0
				nCnt 	  := 1
				cReg      := "T045AG"
				cRegFilho := "T045AH"
				DbSelectArea( aAlias[K210] )
				DbSelectArea( aAlias[K215] )
				
				While (aAlias[K210])->( !Eof() )
				
					(aAlias[K210])->( Aadd( aRegsK21X, { {cReg, DT_INI_OS, DT_FIN_OS, COD_DOC_OS, COD_ITEM_O, QTD_ORI }} ) )
					
					//Adiciona os produtos do registro em um array
					Aadd(aProdK,(aAlias[K210])->(COD_ITEM_O))
					
					/*----------------------------------------------------------
							Laço para Geração dos Registros Filhos K215
					----------------------------------------------------------*/
					While (aAlias[K215])->( !Eof() ) .AND. AllTrim((aAlias[K210])->COD_DOC_OS) == AllTrim((aAlias[K215])->COD_DOC_OS)  
					
						(aAlias[K215])->( Aadd( aRegsK21X[nCnt], { cRegFilho, COD_ITEM_D, QTD_DES} ) )
						
						//Adiciona os produtos do registro em um array
						Aadd(aProdK,(aAlias[K215])->(COD_ITEM_D))
							
						(aAlias[K215])-> ( DbSkip() )
					EndDo
						
					nCnt++	
					(aAlias[K210])-> ( DbSkip() )
				EndDo
			EndIf
			
			/*----------------------------------------------------------
						Informações do Registro K220
			----------------------------------------------------------*/
			If Select(aAlias[K220]) > 0
				cReg := "T045AB"
				DbSelectArea( aAlias[K220] )
				While (aAlias[K220])->( !Eof() )
				
					(aAlias[K220])->( Aadd( aRegsK220, { {cReg, DT_MOV, COD_ITEM_O, COD_ITEM_D, QTD_ORI} } ) )
					
					//Adiciona os produtos do registro em um array
					Aadd(aProdK,(aAlias[K220])->(COD_ITEM_O))
					Aadd(aProdK,(aAlias[K220])->(COD_ITEM_D))
						
					(aAlias[K220])-> ( DbSkip() )
				EndDo
			EndIf
			
			/*----------------------------------------------------------
						Informações do Registros K230 e K235
			----------------------------------------------------------*/
			If Select(aAlias[K230]) > 0 .And. Select(aAlias[K235]) > 0
				nCnt	  := 1
				cReg      := "T045AC"
				cRegFilho := "T045AD"
				DbSelectArea( aAlias[K230] )
				DbSelectArea( aAlias[K235] )
				
				While (aAlias[K230])->( !Eof() )
				
					aRegs := {}
					(aAlias[K230])->( Aadd( aRegsK23X, { {cReg, DT_INI_OP, DT_FIN_OP, COD_DOC_OP, COD_ITEM, QTD_ENC }} ) )
					
					//Adiciona os produtos do registro em um array
					Aadd(aProdK,(aAlias[K230])->(COD_ITEM))
					
					/*----------------------------------------------------------
							Laço para Geração dos Registros Filhos K235
					----------------------------------------------------------*/
					While (aAlias[K235])->( !Eof() ) .AND. AllTrim((aAlias[K230])->COD_DOC_OP) == AllTrim((aAlias[K235])->COD_DOC_OP) 
						
						(aAlias[K235])->( Aadd( aRegsK23X[nCnt], { cRegFilho, DT_SAIDA, COD_ITEM, QTD, COD_INS_SU} ) )
							
						//Adiciona os produtos do registro em um array
						Aadd(aProdK,(aAlias[K235])->(COD_ITEM))	
						Aadd(aProdK,(aAlias[K235])->(COD_INS_SU))
							
						(aAlias[K235])-> ( DbSkip() )
					EndDo
					
					nCnt++
					(aAlias[K230])-> ( DbSkip() )
				EndDo
			EndIf
			
			/*----------------------------------------------------------
						Informações do Registros K250 e K255
			----------------------------------------------------------*/
			If Select(aAlias[K250]) > 0 .And. Select(aAlias[K255]) > 0
				nCnt 	  := 1
				cReg      := "T045AE"
				cRegFilho := "T045AF"
				DbSelectArea( aAlias[K250] )
				DbSelectArea( aAlias[K255] )
				While (aAlias[K250])->( !Eof() )
				
					aRegs := {}
					(aAlias[K250])->( Aadd( aRegsK25X, { {cReg, DT_PROD, COD_ITEM, QTD}} ) )
					
					//Adiciona os produtos do registro em um array
					Aadd(aProdK,(aAlias[K250])->(COD_ITEM))
					
					/*----------------------------------------------------------
							Laço para Geração dos Registros Filhos K255
					----------------------------------------------------------*/
					While (aAlias[K255])->( !Eof() ) .AND. AllTrim((aAlias[K250])->CHAVE) == AllTrim((aAlias[K255])->CHAVE)  
				
						(aAlias[K255])->( Aadd( aRegsK25X[nCnt], { cRegFilho, DT_CONS, COD_ITEM, QTD, COD_INS_SU} ) )
							
						//Adiciona os produtos do registro em um array
						Aadd(aProdK,(aAlias[K255])->(COD_ITEM))	
							
						(aAlias[K255])-> ( DbSkip() )
					EndDo
					
					nCnt++	
					(aAlias[K250])-> ( DbSkip() )
				EndDo
			EndIf
			
			/*----------------------------------------------------------
						Informações do Registros K260 e K265
			----------------------------------------------------------*/
			If Select(aAlias[K260]) > 0 .And. Select(aAlias[K265]) > 0
				nCnt 	  := 1
				cReg      := "T045AI"
				cRegFilho := "T045AJ"
				DbSelectArea( aAlias[K260] )
				DbSelectArea( aAlias[K265] )
				While (aAlias[K260])->( !Eof() )
				
					(aAlias[K260])->( Aadd( aRegsK26X, { { cReg, COD_OP_OS, COD_ITEM, DT_SAIDA, QTD_SAIDA, DT_RET, QTD_RET } } ) )
					
					//Adiciona os produtos do registro em um array
					Aadd(aProdK,(aAlias[K260])->(COD_ITEM))
					
					/*----------------------------------------------------------
							Laço para Geração dos Registros Filhos K265
					----------------------------------------------------------*/
					While (aAlias[K265])->( !Eof() ) .AND. AllTrim((aAlias[K260])->COD_OP_OS) == AllTrim((aAlias[K265])->COD_OP_OS)  
				
						(aAlias[K265])->( Aadd( aRegsK26X[nCnt], { cRegFilho, COD_ITEM, QTD_CONS, QTD_RET} ) )
							
						//Adiciona os produtos do registro em um array
						Aadd(aProdK,(aAlias[K265])->(COD_ITEM))	
							
						(aAlias[K265])-> ( DbSkip() )
					EndDo
						
					nCnt++	
					(aAlias[K260])-> ( DbSkip() )
				EndDo
			EndIf
			
			/*----------------------------------------------------------
						Informações do Registros K270 e K275
			----------------------------------------------------------*/
			If Select(aAlias[K270]) > 0 .And. Select(aAlias[K275]) > 0
				nCnt 	  := 1
				cReg      := "T045AK"
				cRegFilho := "T045AL"
				DbSelectArea( aAlias[K270] )
				DbSelectArea( aAlias[K275] )
				While (aAlias[K270])->( !Eof() )
				
					
					(aAlias[K270])->( Aadd( aRegsK27X, { {cReg, DT_INI_AP, DT_FIN_AP, COD_OP_OS, COD_ITEM, QTD_COR_P, QTD_COR_N, ORIGEM }} ) )
					
					//Adiciona os produtos do registro em um array
					Aadd(aProdK,(aAlias[K270])->(COD_ITEM))		
					
					/*----------------------------------------------------------
							Laço para Geração dos Registros Filhos K275
					----------------------------------------------------------*/
					While (aAlias[K275])->( !Eof() ) .AND. AllTrim((aAlias[K270])->COD_OP_OS) == AllTrim((aAlias[K275])->COD_OP_OS)  
				
						(aAlias[K275])->( Aadd( aRegsK27X[nCnt], { cRegFilho, COD_ITEM, QTD_COR_P, QTD_COR_N, COD_INS_SU} ) )		
						
						//Adiciona os produtos do registro em um array
						Aadd(aProdK,(aAlias[K275])->(COD_ITEM))	
						Aadd(aProdK,(aAlias[K275])->(COD_INS_SU))
							
						(aAlias[K275])-> ( DbSkip() )
					EndDo
					
					nCnt++		
					(aAlias[K270])-> ( DbSkip() )
				EndDo
			EndIf
			
			/*----------------------------------------------------------
						Informações do Registro K280
			----------------------------------------------------------*/
			If Select(aAlias[K280]) > 0
				cReg := "T045AM"
				DbSelectArea( aAlias[K280] )
				While (aAlias[K280])->( !Eof() )
				
					//Ajusta o codigo do participante
					If !Empty((aAlias[K280])->(COD_PART))
						If Substr((aAlias[K280])->(COD_PART), 1, 3) == 'SA1'
							cCodPart := 'C' 
						ElseIf Substr((aAlias[K280])->(COD_PART), 1, 3) == 'SA2'
							cCodPart := 'F' 
						EndIf 
						
						cCodPart += Substr((aAlias[K280])->(COD_PART), 4, 6)
					EndIf
				
					(aAlias[K280])->( Aadd( aRegsK280, { { cReg, DT_EST, COD_ITEM, QTD_COR_P, QTD_COR_N, IND_EST, cCodPart }} ) )	
						
					//Adiciona os produtos do registro em um array
					Aadd(aProdK,(aAlias[K280])->(COD_ITEM))	
					
					//Adiciona os participante do registro em um array
					Aadd(aPartK,cCodPart)
					
					cCodPart := ""
						
					(aAlias[K280])-> ( DbSkip() )
				EndDo
			EndIf
			
			/*----------------------------------------------------------
						Informações do Registros 0210
			----------------------------------------------------------*/
			If Select(aAlias[0210]) > 0
				nCnt 	  := 0
				cReg      := "T046"
				cRegFilho := "T046AA"
				DbSelectArea( aAlias[0210] )
				While (aAlias[0210])->( !Eof() )
				
					If (aAlias[0210])->(COD_ITEM) <> cProdAnt0210
						Aadd( aRegs0210, {{ cReg, (aAlias[0210])->(COD_ITEM), cDataDe, cDataAte }})	
						nCnt++
					EndIf
					
					(aAlias[0210])->( Aadd( aRegs0210[nCnt], { cRegFilho, COD_I_COMP, {QTD_COMP,nDeQtcomp}, {PERDA,nDecPerda}} ) )		
					cProdAnt0210 := (aAlias[0210])->(COD_ITEM)
					
					//Adiciona os produtos do registro em um array
					Aadd(aProdK,(aAlias[0210])->(COD_ITEM))
							
					(aAlias[0210])-> ( DbSkip() )
				EndDo
			EndIf

			//Fecha os Arquivos Temporarios
			For nI := 1 To Len(aAlias)
				If Select(aAlias[nI]) > 0
					If lBlkApg
						BlkApgArq({aAlias[nI]}) //--Parametro tipo Array
					Else
						(aAlias[nI])->( DbCloseArea() )
					EndIf
				EndIf
			Next nI
		EndIf
	EndIf

	If lGrava
		// Cadastra todos os T003(Produtos) que estiverem no Bloco K
		// Remove participantes repetidos do array de particip. do bloco k
		For nI := 1 to Len(aPartK)
			If Ascan(aPartKUnic,aPartK[nI]) == 0 .AND. !Empty(aPartK[nI])
				Aadd(aPartKUnic,aPartK[nI])
			EndIf     
		Next nI   

		//Gera os participantes do bloco k e os coloca no array
		For nI := 1 to Len(aPartKUnic)
			RegT003(@n_HdlT003,@a_Particip,aPartKUnic[nI])
		Next nI

		//Remove participantes repetidos do array de produtos
		For nI := 1 to Len(a_Particip)
			If AScan(aPartUnic,{|x| x[1][2] == a_Particip[nI,1,2] }) == 0 .AND. !Empty(a_Particip[nI])
				Aadd(aPartUnic,a_Particip[nI])
			EndIf     
		Next nI   

		a_Particip := {}
		a_Particip := aPartUnic

		// Cadastra todos os T007(Produtos) que estiverem no Bloco K
		// Remove produtos repetidos do array de prod. do bloco k
		For nI := 1 to Len(aProdK)
			If Ascan(aProdKUnic,aProdK[nI]) == 0 .AND. !Empty(aProdK[nI])
				Aadd(aProdKUnic,aProdK[nI])
			EndIf     
		Next nI   

		//Gera os produtos do bloco k e os coloca no array de produtos
		For nI := 1 to Len(aProdKUnic)
			RegT007(@n_HdlT007,@a_Produtos,aProdKUnic[nI])
		Next nI

		//Remove produtos repetidos do array de produtos
		For nI := 1 to Len(a_Produtos)
			If AScan(aProdUnic,{|x| x[1][2] == a_Produtos[nI,1,2] }) == 0 .AND. !Empty(a_Produtos[nI])
				Aadd(aProdUnic,a_Produtos[nI])
			EndIf     
		Next nI

		a_Produtos := {}
		a_Produtos := aProdUnic

		// Add nome do txt gerado para colocar no arquivo principal apenas arquivos gerados no processamento atual.
		Aadd(aArqGer, cTxtSys)

		// Gera todos os registros do bloco K
		For nI := 1 to Len(aRegsK100)
			FConcTxt( aRegsK100[nI], nHdlTxt )	
		Next nI

		For nI := 1 to Len(aRegsK200)
			FConcTxt( aRegsK200[nI], nHdlTxt )	
		Next nI

		For nI := 1 to Len(aRegsK220)
			FConcTxt( aRegsK220[nI], nHdlTxt )	
		Next nI

		For nI := 1 to Len(aRegsK23X)
			FConcTxt( aRegsK23X[nI], nHdlTxt )
		Next nI

		For nI := 1 to Len(aRegsK25X)
			FConcTxt( aRegsK25X[nI], nHdlTxt )
		Next nI

		For nI := 1 to Len(aRegsK21X)
			FConcTxt( aRegsK21X[nI], nHdlTxt )
		Next nI

		For nI := 1 to Len(aRegsK26X)
			FConcTxt( aRegsK26X[nI], nHdlTxt )
		Next nI

		For nI := 1 to Len(aRegsK27X)
			FConcTxt( aRegsK27X[nI], nHdlTxt )
		Next nI

		For nI := 1 to Len(aRegsK280)
			FConcTxt( aRegsK280[nI], nHdlTxt )	
		Next nI

		// Grava o registro na TABELA TAFST1 e limpa o array aDadosST1
		If cTpSaida == "2" .And. (	len( aRegsK100 ) > 0 .Or.;
									len( aRegsK200 ) > 0 .Or.;
									len( aRegsK220 ) > 0 .Or.;
									len( aRegsK23X ) > 0 .Or.;
									len( aRegsK25X ) > 0 .Or.;
									len( aRegsK21X ) > 0 .Or.;
									len( aRegsK26X ) > 0 .Or.;
									len( aRegsK27X ) > 0 .Or.;
									len( aRegsK280 ) > 0 )
			FConcST1()
		EndIf

		// Gera Registro T046
		ExtT046(aRegs0210)		

	EndIf		

	// Libero Handle do Arquivo
	If cTpSaida == "1" 
		FClose(nHdlTxt)
	EndIf

Return lGerou
