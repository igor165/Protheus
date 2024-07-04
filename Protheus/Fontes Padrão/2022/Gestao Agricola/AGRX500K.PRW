#INCLUDE "AGRA500.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//===================================================================================
/*****  Funções relacionadas a saída por transferência - Romaneios  *****/
//===================================================================================


/*/{Protheus.doc} AX500SaiTr
//TODO Descrição auto-gerada.
@author silvana.torres
@since 21/05/2018
@version undefined
@param cFilCli, characters, descricao
@param cFilOri, characters, descricao
@param cRomDest, characters, descricao
@param lAlgodao, logical, descricao
@param cNumOP, characters, descricao

@type function
/*/
Function AX500SaiTr(cFilCli, cFilOri, cRomDest, lAlgodao, cNumOP, oModel, lEfet)
	Local lRet		:= .T.
	Local cTpMovto  := SuperGetMV("MV_TPMVTRF",.F.,'') //Tipo de movimento para Transferência entre filiais
	Local cRomPar	:= ''
	
	Private _cIdMV := ""  //usada para gravar movimentação (AGRX500H.prw)

	//Verifica se saida foi originada por um romaneio de entrada
	If NJJ->NJJ_TIPO = "B" .AND. SUBSTRING(NJJ->NJJ_OBS,1,17) = "Filial de origem:"
	   //se saida foi criada por entrada já foi gravada movimentação no mesmo ID, então não faz nada
	Else
		//senão grava movimentação saida por transferência no OG (OGA440) 
		If !Empty(cTpMovto) 
		   lRet := A500GrvMov(cTpMovto, NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM)
		EndIf
	EndIf	
	
	if .Not. lAlgodao
		//Verifica se Lança produção (flag no tipo de operação)
		if AGRX500LP(NJJ->NJJ_TOETAP)
		
			IF .NOT. Empty(NJJ->NJJ_CODPRO) .AND. .NOT. Empty(NJJ->NJJ_PSLIQU) .AND. .NOT. Empty(NJJ->NJJ_LOCAL)
			
				if Empty(cNumOP)
					//-- Gera ordem de produção
					Processa({|| lRet := A500GERAOP(@cNumOP, NJJ->NJJ_CODPRO, NJJ->NJJ_PSLIQU, NJJ->NJJ_LOCAL, 3) }, STR0041 , STR0040 )	//"Gerando Ordem de Produção..."###"Aguarde"
				endIf
					
				//-- Realiza o apontamento da OP 
				If lRet
					Processa({|| lRet := A500APROD(cNumOP, NJJ->NJJ_CODROM, NJJ->NJJ_CODPRO, NJJ->NJJ_PSLIQU, NJJ->NJJ_LOCAL, 3) }, STR0039, STR0040 ) //"Movimentando Ordem de Produção..."###"Aguarde"
				EndIf
			endIf
		endIf
	endIf
	
	if lRet
		//Verifica se Gera Pré-romaneio(flag no tipo de operação)
		if AGRX500GPR(NJJ->NJJ_TOETAP)
			IF .NOT. Empty(NJJ->NJJ_CODPRO) .AND. .NOT. Empty(NJJ->NJJ_PSLIQU) .AND. .NOT. Empty(NJJ->NJJ_LOCAL)
				
				//--Se algodão - Gera peso líquido nos fardões vinculados
				//--Senão passa verdadeiro pois é semente
				lRet := If(lAlgodao, AGRX500DXL(NJJ->NJJ_PSLIQU), .T.) 
				
				If lRet
			
					//verifica se a produção é de outra filial
					cFilCli := AGRX500POF(NJJ->NJJ_CODENT, NJJ->NJJ_LOJENT)
					
					if trim(cFilCli) <> ""
						//--ALTERA A FILIAL CORRENTE PARA A FILIAL DA ENTIDADE
						//================================
						cFilAnt := cFilCli			
						//================================
						
						//--Funcao na rotina AGRX500
						if .NOT. A500GerRom(NJJ->NJJ_TIPO, NJJ->NJJ_TOETAP, cFilOri, .F., lAlgodao, @cRomPar, oModel)
							lRet := .F.
						endIf

						//Verifica se saida foi originada por um romaneio de entrada
						If NJJ->NJJ_TIPO = "B" .AND. SUBSTRING(NJJ->NJJ_OBS,1,17) = "Filial de origem:"
						   //se saida foi criada por entrada já foi gravada movimentação no mesmo ID, então não faz nada
						Else
							//grava movimentação entrada por transferência no OG (OGA440) 
							If lRet .And. !Empty(cTpMovto) 
							   lRet := A500GrvMov(cTpMovto, cFilCli, NJJ->NJJ_CODROM)
							EndIf
						EndIf	
						
						/*//--Se processo de transferencia criar romaneios pelo GFE
						//--Deve-se tratar com a variavel criada de parametro
						//--Pois o erp se perde e retorna o posicionamento do romaneio de origem
						If FwIsInCallStack("GFEA523")*/
						cRomDest := cRomPar
						/*Else
							cRomDest   := NJJ->NJJ_CODROM
						EndIf*/
						cFilCli	   := ""
						
						//--RETORNA COM A FILIAL DE ORIGEM 
						//================================
						cFilAnt := cFilOri
						//================================
						
						If lRet
							//Efetua a transferência entre filiais. Funcao na rotina AGRX500B
							Processa({|| lRet := AGRX500TRE(M->NJJ_PSLIQU,NJJ->NJJ_CODSAF,M->NJJ_CODENT, M->NJJ_LOJENT,M->NJJ_CODPRO, "", "", .F., "", {{M->NJJ_CODROM,01,cFilAnt}})}, STR0100, STR0040 ) //"Movimentando Ordem de Produção..."###"Aguarde"
						EndIf
						
						//Efetiva transferência entre filiais
						If lRet
						   Processa({|| lRet := AGRX500EFT()}, STR0129, STR0040 ) //"Efetivando transferência..."###"Aguarde"
						   lEfet := lRet
						EndIf
					endIf
				endIf
			Else
				//Não gera pré-romaneio. Então, gera somente pedido de venda e a nota.								
				lRet := AGRX500PED(NJJ->NJJ_CODROM)
			endIf								
		endIf	
	endif
	
	//inicializa variavel do tipo de movimento -- função A500GrvMov()
	_cIdMV := ""	
		
Return lRet