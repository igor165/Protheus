#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"
#INCLUDE "FWMVCDEF.CH"

STATIC aTabProg		:= {}
STATIC aTabDep		:= {}
STATIC aPesqF2D  	:= {}
STATIC aPesqSD1  	:= {}
STATIC aPesqF0R		:= {}
STATIC PVALORI		:= Iif(FindFunction("xFisTpForm"), xFisTpForm("0"), "")
STATIC PINDCALC		:= Iif(FindFunction("xFisTpForm"), xFisTpForm("9"), "")
STATIC LSEMREDUCAO	:= .F.
STATIC lAliascj3	:= AliasIndic("CJ3")
STATIC __aPrepared	:= {}
STATIC aPesqEstr	:= {} //Ultima aquisi��o com estrutura de produto

 
//-----------------------------------------------------------------------------------------------------------------------
//Este fonte tem objetivo de concentrar todas as fun��es e regras do configurador de tributos
//com objetivo de centralizar o c�digo do configurador, evitando assim eventuais problemas de concorr�ncia de fontes
//Somente fun��es que s�o envolvidas com o configurador dever�o ser adicionadas nestes fonte.
//Este fonte � dependente da MATXFIS, IMPXFIS e MATXDEF
//-----------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisTrbGen()
Fun��o que far� o enquadramento das regras de tributos g�ricos, procurando
pelos perfis de opera��o, produto/origem, opera��o e origem/destino.
Esta fun��o tamb�m far� os c�lculos dos tributos gen�ricos, e todas as informa��es
das regras e valores ser�o atualizados diretamente no aNfItem.

@param aNfCab   - Array com as informa��es cabe�alho da nota fiscal
@param aNfItem  - Array com toda as informa��es do item da nota fiscal
@param nItem    - N�mero do item da nota fiscal
@param cCampo   - Campo processado na Recall
@param cExecuta - Campo com propriedade do tributo gen�rico que dever� ser processada, BSE, VLR ou ALQ
@param cTrib    - Tributo gen�rico que dever� ser processado
@param aPos    - Array com cache dos fieldpos
@param aDic    - Array com cache de aliasindic
@param nTGITRef - Tamanho do array ItemRef dos tributos gen�ricos
@param aMapForm   - HashMap com o mapeamento dos operandos e formulas

@author Erick Gon�alves Dias
@since 26/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FisTribGen(aNfCab, aNfItem, nItem, cCampo, cExecuta, cTrib, aPos, aDic, nTGITRef, aMapForm, aDepTrib, aDepVlOrig, aFunc,aUltPesqF2D)
  
Local cAliasQry		:= ""
Local cCodProd		:= aNfItem[nItem][IT_PRODUTO]
Local cPart			:= aNfCab[NF_CODCLIFOR]
Local cLoja			:= aNfCab[NF_LOJA]
Local cTipoPart		:= Iif( aNfCab[NF_CLIFOR] == "C", "2" , "1" )
Local cOrigProd		:= SubStr( aNfItem[nItem][IT_CLASFIS] , 1 , 1 )
Local cUfOrigem		:= aNFCab[NF_UFORIGEM]
Local cUfDestino	:= aNfCab[NF_UFDEST]
Local cCfop			:= aNfItem[nItem][IT_CF]
Local cTpOper		:= aNfItem[nItem][IT_TPOPER]
Local cNcm 			:= aNfItem[nItem][IT_POSIPI]
Local c1UM 			:= aNfItem[nItem][IT_B1UM]
Local c2UM 			:= aNfItem[nItem][IT_B1SEGUM]
Local cCodIss		:= aNfItem[nItem][IT_CODISS]
Local nTrbGen		:= 0
Local cOperando		:= ""
Local nPosOper		:= 0
Local nX			:= 0
Default cExecuta    := ""
Default cTrib		:= ""
Default aMapForm	:= {}	

//Atribuo o array das pesquisas com cache das notas
aPesqF2D	:= aUltPesqF2D

cCampo	:= Alltrim(cCampo)

// Verifica se a flag para c�lculo dos tributos gen�ricos foi passada como ".T.". Esta flag � passada via MaFisIni e serve para indicar que
// a rotina consumidora est� preparada para gravar, visualizar e excluir os tributos gen�ricos. Esta prote��o serve para evitar que os tributos
// sejam calculados e n�o sejam gravados/visualizados devido � aus�ncia da chamada dos componentes espec�ficos criados para este fim.
If aNfCab[NF_CALCTG]

	/*
	Considero as refer�ncias IT_RECORI pois � quando alterou o recno da nota original.
	Considero o IT_QUANT pois influencia diretamente na devolu��o, seja parcial ou integral.
	Refa�o a query quando se altera a quantidade, pois preciso do valor original como base para refazer a proporcionalidade,
	caso contr�rio conseguria fazer a proporcionalidade correta somente da primeira vez.
	Verificou tamb�m se cCampo est� vazio, pois no caso da planilha financeira e no faturamento a recall � chamada sem campo espec�fico
	Verifico tamb�m se o RECORI est� preenchido e se o tipo da nota � devolu��o ou beneficiamento
	*/
	If cCampo <> "IT_TRIBGEN" .AND. aNFCab[NF_TIPONF] $ "DB" .And. !Empty(aNFItem[nItem][IT_RECORI])
		IF Alltrim(cCampo) == "IT_RECORI" .OR. Alltrim(cCampo) == "IT_QUANT" .OR. cCampo == "IT_" .OR. Empty(cCampo)
			//Chama fun��o que far� o tratamento das devolu��es dos tributos gen�ricos
			FisDevTrbGen(aNfCab, @aNfItem, nItem, aPos, aDic, cCampo, nTGITRef, aMapForm)

			If aDic[AI_CJ2]
				For nTrbGen:= 1 to Len(aNfItem[nItem][IT_TRIBGEN])
					//Atualiza refer�ncias do livro
					FisLivroTG(aNfItem, nItem, nTrbGen, aNfCab, aMapForm, .T.)
				Next nTrbGen
			Endif
		EndIF		
	Else

		/*Verifico se a Recall foi chamada na altera��o de c�digo de produto, c�digo do participante, loja do participanta, uf de origem,
		UF de destino,c�digo de TES e CFOP. Por�m estou verificando tamb�m se cCampo est� vazia, pois o processamento do faturamente chama somente 1
		vez a Recall, e n�o chama com altera��o de campos espec�fico, j� que o envio de informa��es para MATXFIS � feito via load.
		Se estas condi��es forem atendidas a query ser� feira e todas as refer�ncias dos tributos gen�ricos tamb�m ser�o refeitos.*/
		If cCampo == "IT_PRODUTO" .OR. cCampo == "NF_CODCLIFOR" .OR. cCampo == "NF_LOJA"   .OR. cCampo == "NF_UFORIGEM" .OR. ;
	       cCampo == "NF_UFDEST"  .OR. cCampo == "IT_CF"        .OR. cCampo == "IT_TES"    .OR. cCampo == "NF_DTEMISS"  .OR. ;
		   cCampo == "NF_NATUREZA" .OR. cCampo == "IT_CLASFIS"   .OR. cCampo == "IT_TPOPER" .OR. cCampo == "IT_CODISS"  .OR. cCampo == "IT_POSIPI" .OR. Empty(cCampo)

			//Verifica primeiro se todos os campos "chaves" est�o preenchidos antes de prosseguir com a query.
			If !Empty(cCodProd)  .AND. !Empty(cPart)      .AND. !Empty(cLoja)  .AND. !Empty(cTipoPart) .AND. ;
			   !Empty(cUfOrigem) .AND. !Empty(cUfDestino) .AND. !Empty(cCfop)

				//Zero toda a estrutura dos tributos gen�ricos, j� que as regras e perfis ser�o enquadrados novamente e tudo ser� refeito.
				aNfItem[nItem][IT_TRIBGEN]	:= Nil
				aNfItem[nItem][IT_TRIBGEN]	:= {}					

				//Somente far� a query se o participante estiver contido em ao menos 1 perfil.
				If aNfCab[NF_PERF_PART]
					//Se todos os campos "chaves" est�o preenchidos, chamaremos a fun��o para realizar a query.
					cAliasQry	:= QryTribGen(cCodProd, cPart, cLoja, cTipoPart, cOrigProd, cUfOrigem, cUfDestino, cCfop, aNfCab[NF_DTEMISS], cTpOper, aPos, aDic, cNcm, c1UM, c2UM, cCodIss, aNFCab, aNfItem, nItem)

					Do While !(cAliasQry)->(Eof())
						//Chama fun��o para adicionar nova estrutura do tributo gen�rico, populando todas as refer�ncias das regras cadastradas
						//As informa��es ser�o atualizadas no pr�prio aNfItem
						nTrbGen	:= AddTrbGen(@aNfItem,nItem, cAliasQry, nTGITRef,aNfCab, aPos, aDic, aMapForm, aDepTrib, aDepVlOrig, .F.)
						
						(cAliasQry)->(DbSKip())
					Enddo					

					//Chama fun��o que interpretar� as regras de base de c�lculo e al�quota e valor
					//As informa��es ser�o atualizadas no pr�prio aNfItem
					For nTrbGen:= 1 to Len(aNfItem[nItem][IT_TRIBGEN])
						//Chama fun��o que interpretar� as regras de base de c�lculo, al�quota e valor. Os valores ser�o atualizados no pr�prio aNfItem
						FisCalcTG(@aNFItem, nItem, nTrbGen,,aNfCab, aMapForm,,aFunc)
					Next nTrbGen

					If aDic[AI_CJ2]
						For nTrbGen:= 1 to Len(aNfItem[nItem][IT_TRIBGEN])
							//Atualiza refer�ncias do livro
							FisLivroTG(aNfItem, nItem, nTrbGen, aNfCab, aMapForm, .T.)
						Next nTrbGen
					Endif

					//Fecha o Alias antes de sair da fun��o
					dbSelectArea(cAliasQry)
					dbCloseArea()
				EndIF

			EndIF

		ElseIf Alltrim(cCampo) == "IT_TRIBGEN"

			//Aqui far� rec�lculo de um tributo espec�fico. Ele precisa existir no IT_TRIBGEN, caso contr�rio n�o far� nenhuma a��o.
			If !Empty(cTrib) .AND. (nTrbGen	:= aScan(aNfItem[nItem][IT_TRIBGEN],{|x| AllTrim(x[TG_IT_SIGLA]) == Alltrim(cTrib)})) > 0
				//Aqui chamo a fun��o para recalcular o tributo gen�rico espec�fico, conforme passado no cTrib, bem como a propriedade passada no cExecuta
				
				//Se a regra de al�quota estiver configurada para obter al�quota por meio de tabela progressiva, ent�o preciso aqui refazer al�quota tamb�m, para enquadrar novamente na tabela progressiva
				cExecuta += Iif(!Empty(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_TAB_PROG]),"|ALQ","")
				FisCalcTG(@aNFItem, nItem, nTrbGen, cExecuta,aNfCab, aMapForm, .T.,aFunc)

				If aDic[AI_CJ2]
					//Aqui atualizarei as refer�ncias do livro, se houver
					FisLivroTG(aNfItem, nItem, nTrbGen, aNfCab, aMapForm, .T.)
				Endif
				
			EndIf

		ElseIf Alltrim(cCampo) == "DEP"

			//Aqui far� rec�lculo de um tributo espec�fico. Ele precisa existir no IT_TRIBGEN, caso contr�rio n�o far� nenhuma a��o.
			If !Empty(cTrib) .AND. (nTrbGen	:= aScan(aNfItem[nItem][IT_TRIBGEN],{|x| AllTrim(x[TG_IT_SIGLA]) == Alltrim(cTrib)})) > 0			

				If aDic[AI_CJ2]
					//Aqui atualizarei as refer�ncias do livro, se houver
					FisLivroTG(aNfItem, nItem, nTrbGen, aNfCab, aMapForm, .T.)
				Endif
	
				If cExecuta == "TG_IT_BASE"

					//Obtem o operando do valor, j� que a base foi alterada, o valor tamb�m ser� alterado e preciso refletir isso nos tributos dependentes do valor
					CalcDep(aDepTrib, aNfItem, nItem, aNfCab, aMapForm, aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_COD_FOR], "BSE",aFunc)

					//Realiza o c�lculo dos tributos que s�o dependentes do operando alterado
					CalcDep(aDepTrib, aNfItem,nItem,aNfCab,aMapForm, aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_COD_FOR],"VLR",aFunc)

					

				ElseIf cExecuta == "TG_IT_VALOR" .OR. cExecuta == "TG_IT_ALIQUOTA"
					
					//Obtem o operando do valor, j� que a base foi alterada, o valor tamb�m ser� alterado e preciso refletir isso nos tributos dependentes do valor
					CalcDep(aDepTrib, aNfItem,nItem,aNfCab,aMapForm, aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_COD_FOR], "VLR",aFunc)				

				EndIF					
				
			EndIf		
		

		Else			

			//--------------------------------------------------------------
			//Se n�o houver f�rmulas far� o c�lculo de todos os tributos
			//--------------------------------------------------------------
			IF Len(aMapForm) == 0	

				/*Aqui significa que n�o houve altera��o dos campos chaves dos perfis, nem das regras e n�o � altera��o do IT_TRIBGEN , logo a query n�o ser� refeita
				por�m todos os c�lculo dos tributos gen�ricos ser�o refeitos.*/
				For nTrbGen:= 1 to Len(aNfItem[nItem][IT_TRIBGEN])
					//Chama fun��o que interpretar� as regras de base de c�lculo, al�quota e valor. Os valores ser�o atualizados no pr�prio aNfItem
					FisCalcTG(@aNFItem, nItem, nTrbGen,,aNfCab, aMapForm,,aFunc)
				Next nTrbGen

			Else

				/*Aqui significa que n�o houve altera��o dos campos chaves dos perfis, nem das regras e n�o � altera��o do IT_TRIBGEN , logo a query n�o ser� refeita
				por�m todos os c�lculo dos tributos gen�ricos ser�o refeitos.*/
				cOperando	:= REFxOPER(cCampo)
				If !Empty(cOperando)
					For nTrbGen:= 1 to Len(aNfItem[nItem][IT_TRIBGEN])
						//Chama fun��o que interpretar� as regras de base de c�lculo, al�quota e valor. Os valores ser�o atualizados no pr�prio aNfItem
						FisCalcTG(@aNFItem, nItem, nTrbGen, Iif(!Empty(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_TAB_PROG]), "BSE|VLR|ALQ", "BSE|VLR|") ,aNfCab, aMapForm,,aFunc)
					Next nTrbGen
				Endif
				//------------------------------------------------------------------------------------------------------------
				//Se j� f�rmulas, ent�o somente far� o c�lculo dos tributos que s�o dependentes do campo alterado na nota!!!!	
				//TODO Problema, quando alterado operando primario que esta contido em ou operando primario, n�o estava refazendo calculo, causando divergencia de valor
				//------------------------------------------------------------------------------------------------------------
				
				//Obter operando atrav�s do cCampo
				/*
				cOperando	:= REFxOPER(cCampo)
				If !Empty(cOperando)

					//Obter a posi��o do operando no array de dependencia
					nPosOper	:=  AScan(aDepVlOrig, { |x| Alltrim(x[1]) == Alltrim(cOperando)})

					//Se encontrou operando continua
					If nPosOper > 0

						//La�o em todos os tributos dependentes deste operando
						For nX := 1 to Len(aDepVlOrig[nPosOper][2])
						
							//Obtem a posi��o do tributo gen�rico
							nTrbGen	:= aScan(aNfItem[nItem][IT_TRIBGEN],{|x| AllTrim(x[TG_IT_SIGLA]) == Alltrim(aDepVlOrig[nPosOper][2][nX])})

							//Se encontrou a posi��o do tributo no AnfItem continua
							IF nTrbGen > 0

								//----------------------------------------------------------
								//Recalculo o tributo que � dependente do valor de origem
								//----------------------------------------------------------								
								FisCalcTG(@aNFItem, nItem, nTrbGen, Iif(!Empty(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_TAB_PROG]), "BSE|VLR|ALQ", "BSE|VLR|") ,aNfCab, aMapForm,,aFunc)
							EndIF

						Next nX
					EndIF

				EndIF
				*/

			EndIF

		EndIF
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} QryTribGen()
Fun��o que far� query na tabela de Tributos por Opera��o, buscando
as regras considerando os perfis.
O retorno desta fun��o ser� o alias com o resultado da query.

@param cCodProd   - C�digo do produto informado no item da nota fiscal
@param cPart      - C�digo do Participante informado na nota fiscal
@param cLoja      - Loja do Participante informado na nota fiscal
@param cTpPart    - Tipo do participante. Indica se � cliente (C) ou ent�o fornecedor (F)
@param cOriProd   - Origem do produto informado no item da nota fiscal
@param cUfOrigem  - UF de origem da nota fiscal
@param cUfDestino - UF de Destino da nota fiscal
@param cCfop      - CFOP informado no item da nota fiscal
@param dDataOper  - Data da opera��o a ser considerada no enquadramento das regras
@param cTpOper    - Tipo da opera��o do documento fiscal
@param aPos    	  - Array com cache de fieldpos
@param aDic    	  - Array com cache das tabelas
@param cNCM    	  - C�digo do NCM do produto se houver
@param c1UM    	  - Primeira unidade de medida do produto
@param c2UM    	  - Segunda unidade de medida do produto
@param cCodIss	  - C�digo do ISS

@return   cAlias  - Alias da query processada

@author Erick Gon�alves Dias
@since 26/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function QryTribGen(cCodProd, cPart, cLoja, cTpPart, cOriProd, cUfOrigem, cUfDestino, cCfop, dDataOper, cTpOper, aPos, aDic, cNCM, c1UM, c2UM, cCodIss, aNFCab, aNfItem, nItem)

Local cSelect	:= ""
Local cFrom	    := ""
Local cWhere	:= ""
Local cAliasQry	:= ""
Local cMes		:= StrZero(Month(dDataOper),2)
Local cAno		:= StrZero(Year(dDataOper),4)
Local cTodosPart := PadR("TODOS", TamSX3("F22_CLIFOR")[1])
Local cTodosLoj := Replicate("Z", TamSx3("F22_LOJA")[1])
Local cUfServ	:= ""
Local cMumServ	:= ""

//---------------------------------------------------------------------------------
//IMPORTANTE - OS NOMES DOS CAMPOS DEVEM SER IGUAIS DA QUERY DA FUN��O FisLoadTG()
//---------------------------------------------------------------------------------
//Obtem UF e munic�pios do servi�o
DefMunServ(aNFCab, @cUfServ, @cMumServ, aNfItem[nItem][IT_PRD][SB_MEPLES] == "2")

//Se��o dos campos do cadastro do tributo F2B, tributo e descri��o
cSelect += "F2B.F2B_REGRA TRIBUTO_SIGLA, F2B.F2B_DESC TRIBUTO_DESCRICAO, F2B.F2B_ID TRIBUTO_ID, F2B.F2B_RFIN REGRA_FIN, F2E.F2E_IDTRIB IDTRIB, "

//Verifica se o campo existe antes de adicionar na query
If aPos[FP_F2B_RND]
	cSelect += " F2B.F2B_RND TRIBUTO_RND, "
EndIf

//Se��o dos campos da regra de base de c�lculo
cSelect += "F27.F27_CODIGO BASE_COD   , F27.F27_VALORI BASE_VALORI , F27.F27_DESCON BASE_DESCON, F27.F27_FRETE  BASE_FRETE, "
cSelect += "F27.F27_SEGURO BASE_SEGURO, F27.F27_DESPE  BASE_DESPE  , F27.F27_ICMDES BASE_ICMDES, F27.F27_ICMRET BASE_ICMRET,  "
cSelect += "F27.F27_REDBAS BASE_REDBAS, F27.F27_TPRED  BASE_TPRED  , F27.F27_UM     BASE_UM    , F27.F27_ID     BASE_ID,"

//Se��o dos campos da regra de al�quota
cSelect += "F28.F28_CODIGO ALQ_CODIGO , F28.F28_VALORI ALQ_VALORI, F28.F28_TPALIQ ALQ_TPALIQ, F28.F28_ALIQ ALQ_ALIQ, "
cSelect += "F28.F28_URF    ALQ_URF    , F28.F28_UFRPER ALQ_UFRPER, F28.F28_ID     ALQ_ID,"

IF aDic[AI_CIN]
	cSelect += " F2B.F2B_DEDPRO TABPRO, F2B.F2B_DEDDEP DEDDEP, F2B.F2B_RGGUIA RGUIA,  "
	cSelect += " F2B.F2B_TRBMAJ TRIBUTO_MAJ, "
	cSelect += " F2B.F2B_VLRMIN VLRMIN, F2B.F2B_VLRMAX VLRMAX, F2B.F2B_OPRMIN OPRLIM_MIN, F2B.F2B_OPRMAX OPRLIM_MAX,"
EndIF

//Se��o com campos da Unidade Referencial Fiscal
cSelect += "F2A.F2A_VALOR URF_VALOR,"

//Campos para que na se��o de query eu tenha os campos base de c�lculo, al�quota e valor
cSelect += "0 BASE_CALCULO, 0 BASE_QTDE, 0 ALIQUOTA, 0 VALOR, 0 DED_DEP"

//Adiciono os campos da f�rmula na se��o do select caso a tabela CIN exista.
IF aDic[AI_CIN]
	cSelect += ", CINBAS.CIN_FNPI BAS_FOR,  CINBAS.CIN_ID BAS_FOR_ID ,  CINBAS.CIN_CODIGO BAS_FOR_COD "
	cSelect += ", CINALQ.CIN_FNPI ALQ_FOR,  CINALQ.CIN_ID ALQ_FOR_ID ,  CINALQ.CIN_CODIGO ALQ_FOR_COD "
	cSelect += ", CINVAL.CIN_FNPI VAL_FOR,  CINVAL.CIN_ID VAL_FOR_ID ,  CINVAL.CIN_CODIGO VAL_FOR_COD "
	cSelect += ", CINISE.CIN_FNPI ISE_FOR,  CINISE.CIN_ID ISE_FOR_ID ,  CINISE.CIN_CODIGO ISE_FOR_COD "
	cSelect += ", CINOUT.CIN_FNPI OUT_FOR,  CINOUT.CIN_ID OUT_FOR_ID ,  CINOUT.CIN_CODIGO OUT_FOR_COD "
	cSelect += ", MVA.CIU_MARGEM MVA, MVA.CIU_MVAAUX MVA_AUX "
	cSelect += ", PAUTA.CIU_VLPAUT PAUTA "
	cSelect += ", MAJ.CIU_MAJORA MAJ, MAJ.CIU_MJAUX IND_AUX_MAJ "
	cSelect += ", ALQ_SERV.CIY_ALIQ ALQ_SERVICO"
	cSelect += ", ALQ_LEICOMP.CIT_ALIQ ALQ_SERV_LEICOMP"
	
EndIF

//Adiciona campos na se��o de select da query com campos de escritura��o
IF aDic[AI_CJ2]
	cSelect += ", CJ2.CJ2_ID ESCR_ID,  CJ2.CJ2_INCIDE INCIDE,  CJ2.CJ2_STOTNF TOTNF ,  CJ2.CJ2_PERDIF PERCDIF, CJ2.CJ2_CST CST, CJ2.CJ2_CSTCAB CSTCAB "	
	cSelect += ", CJ2.CJ2_IREDBS INC_RED"
EndIF

//From ser� executado na tabela F2B - Regras dos tributos x Opera��o
cFrom   += RetSQLName("F2B") + " F2B "

//Join com o cadastro de Tributo F2E
cFrom += "JOIN " + RetSQLName("F2E") + " F2E " + " ON (F2E.F2E_FILIAL = " + ValToSQL(xFilial("F2E")) + " AND F2E.F2E_TRIB = F2B.F2B_TRIB AND F2E.D_E_L_E_T_ = ' ') "

//Join com o perfil de origem e destino
cFrom += "JOIN " + RetSQLName("F21") + " F21 " + " ON (F21.F21_FILIAL = " + ValToSQL(xFilial("F21")) + " AND F21.F21_CODIGO = F2B.F2B_PEROD AND F21.F21_UFORI = " + ValToSQL(cUfOrigem) + " AND F21.F21_UFDEST = " + ValToSQL(cUfDestino) + " AND F21.D_E_L_E_T_ = ' ') "

//Join com o perfil de participante
cFrom += "JOIN " + RetSQLName("F22") + " F22 " + " ON (F22.F22_FILIAL = " + ValToSQL(xFilial("F22")) + " AND F22.F22_CODIGO = F2B.F2B_PERFPA AND F22.F22_TPPART = " + VAlToSql(cTpPart) + " AND ((F22.F22_CLIFOR = " + ValToSql(cPart) + " AND F22.F22_LOJA = " + ValToSql(cLoja) + ") OR (F22.F22_CLIFOR = " + ValToSql(cTodosPart) + " AND F22.F22_LOJA = " + ValToSql(cTodosLoj) + ")) AND F22.D_E_L_E_T_ = ' ') "

//Join com o perfil de opera��o
cFrom += "JOIN " + RetSQLName("F23") + " F23 " + " ON (F23.F23_FILIAL = " + ValToSQL(xFilial("F23")) + " AND F23.F23_CODIGO = F2B.F2B_PERFOP AND F23.F23_CFOP = " +  ValToSQL(cCfop) + " AND F23.D_E_L_E_T_ = ' ') "

If !Empty(cTpOper)
	//Join com o perfil de opera��o considerando o tipo de opera��o
	cFrom += "JOIN " + RetSQLName("F26") + " F26 " + " ON (F26.F26_FILIAL = " + ValToSQL(xFilial("F26")) + " AND F26.F26_CODIGO = F2B.F2B_PERFOP AND (F26.F26_TPOPER = " + ValToSQL(cTpOper) + " OR F26.F26_TPOPER= 'TODOS') AND F26.D_E_L_E_T_ = ' ') "
EndIF

If aDic[AI_CIN] .And. !Empty(cCodIss)
	//Join com o perfil de opera��o considerando o c�digo de ISS	
	cFrom += "JOIN " + RetSQLName("CIO") + " CIO " + " ON (CIO.CIO_FILIAL = " + ValToSQL(xFilial("CIO")) + " AND CIO.CIO_CODIGO = F2B.F2B_PERFOP AND (CIO.CIO_CODISS = " + ValToSQL(cCodIss) + " OR CIO.CIO_CODISS = 'TODOS') AND CIO.D_E_L_E_T_ = ' ') "
EndIF

//Join com o perfil de produto
cFrom += "JOIN " + RetSQLName("F24") + " F24 " + " ON (F24.F24_FILIAL = " + ValToSQL(xFilial("F24")) + " AND F24.F24_CODIGO = F2B.F2B_PERFPR AND (F24.F24_CDPROD = " +  ValToSQL(cCodProd) + " OR F24.F24_CDPROD = 'TODOS' ) AND F24.D_E_L_E_T_ = ' ') "

If !Empty(cOriProd)
	//Join com o perfil de origem de produto. Origem do produto somente ser� obrigat�ria se estiver informada.
	cFrom += "JOIN " + RetSQLName("F25") + " F25 " + " ON (F25.F25_FILIAL = " + ValToSQL(xFilial("F25")) + " AND F25.F25_CODIGO = F2B.F2B_PERFPR AND F25.F25_ORIGEM = " + ValToSQL(cOriProd) + " AND F25.D_E_L_E_T_ = ' ') "
EndIF

//Join com a regra de base de c�lculo. Traz sempre a regra vig�nte considerando o campo F27_ALTERA = 2
cFrom += "JOIN " + RetSQLName("F27") + " F27 " + " ON (F27.F27_FILIAL = " + ValToSQL(xFilial("F27")) + " AND F27.F27_CODIGO = F2B.F2B_RBASE AND F27.F27_ALTERA = '2' AND F27.D_E_L_E_T_ = ' ') "

//Join com a regra de al�quota. Traz sempre a regra vig�nte considerando o campo F28_ALTERA = 2
cFrom += "JOIN " + RetSQLName("F28") + " F28 " + " ON (F28.F28_FILIAL = " + ValToSQL(xFilial("F28")) + " AND F28.F28_CODIGO = F2B.F2B_RALIQ AND F28.F28_ALTERA = '2' AND F28.D_E_L_E_T_ = ' ') "

//LEFT Join com a tabela com URF. Esta tabela � LEFT pelo motivo de nem todas as al�quotas semre por URF.
cFrom += "LEFT JOIN " + RetSQLName("F2A") + " F2A " + " ON (F2A.F2A_FILIAL = " + ValToSQL(xFilial("F2A")) + " AND F2A.F2A_URF = F28.F28_URF AND F2A.F2A_ANO = " + ValToSQL(cAno) + " AND F2A.F2A_MES = " + ValToSQL(cMes) + "  AND F2A.D_E_L_E_T_ = ' ') "

//----------------------------------------------------------------------------------------------------------------------------------------
//Se a tabela CIN de f�rmulas existir, ent�o farei left join para carregar as f�rmulas das regras de base de c�lculo, al�quota e tributo
//----------------------------------------------------------------------------------------------------------------------------------------
IF aDic[AI_CIN]
	//F�rmula da base
	cFrom += "LEFT JOIN " + RetSQLName("CIN") + " CINBAS " + " ON (CINBAS.CIN_FILIAL = " + ValToSQL(xFilial("CIN")) + " AND CINBAS.CIN_IREGRA = F2B.F2B_ID AND CINBAS.CIN_TREGRA = '6 ' AND CINBAS.D_E_L_E_T_ = ' ') "
	//F�rmula da al�quota
	cFrom += "LEFT JOIN " + RetSQLName("CIN") + " CINALQ " + " ON (CINALQ.CIN_FILIAL = " + ValToSQL(xFilial("CIN")) + " AND CINALQ.CIN_IREGRA = F2B.F2B_ID AND CINALQ.CIN_TREGRA = '7 ' AND CINALQ.D_E_L_E_T_ = ' ') "
	//F�rmula do valor.
	cFrom += "LEFT JOIN " + RetSQLName("CIN") + " CINVAL " + " ON (CINVAL.CIN_FILIAL = " + ValToSQL(xFilial("CIN")) + " AND CINVAL.CIN_IREGRA = F2B.F2B_ID AND CINVAL.CIN_TREGRA = '8 ' AND CINVAL.D_E_L_E_T_ = ' ') "

	//F�rmula de Isento
	cFrom += "LEFT JOIN " + RetSQLName("CIN") + " CINISE " + " ON (CINISE.CIN_FILIAL = " + ValToSQL(xFilial("CIN")) + " AND CINISE.CIN_IREGRA = F2B.F2B_ID AND CINISE.CIN_TREGRA = '11' AND CINISE.D_E_L_E_T_ = ' ') "
	
	//F�rmula de Outros
	cFrom += "LEFT JOIN " + RetSQLName("CIN") + " CINOUT " + " ON (CINOUT.CIN_FILIAL = " + ValToSQL(xFilial("CIN")) + " AND CINOUT.CIN_IREGRA = F2B.F2B_ID AND CINOUT.CIN_TREGRA = '12' AND CINOUT.D_E_L_E_T_ = ' ') "

	//JOIN CIUxCITxCIS
	//Join com MVA
	cFrom += "LEFT JOIN " + RetSQLName("CIU") + " MVA " + " ON (MVA.CIU_FILIAL = " + ValToSQL(xFilial("CIU")) + " AND MVA.CIU_TIPO ='1' AND MVA.CIU_NCM = " + ValToSQL(cNCM)         + " AND MVA.CIU_TRIB = F2E.F2E_TRIB AND (MVA.CIU_UFORI = " + ValToSQL(cUfOrigem) + " OR MVA.CIU_UFORI = '**') AND (MVA.CIU_UFDEST = " + ValToSQL(cUfDestino) + " OR  MVA.CIU_UFDEST = '**') AND " + ValToSql(dDataOper) + " >= MVA.CIU_VIGINI AND ( " + ValToSql(dDataOper) + " <= MVA.CIU_VIGFIM OR MVA.CIU_VIGFIM = ' ' ) AND (MVA.CIU_ORIGEM = " + ValToSql(cOriProd) + " OR MVA.CIU_ORIGEM = '*')  AND MVA.D_E_L_E_T_ = ' ') "

	//Join com Pauta
	cFrom += "LEFT JOIN " + RetSQLName("CIU") + " PAUTA " + " ON (PAUTA.CIU_FILIAL = " + ValToSQL(xFilial("CIU")) + " AND PAUTA.CIU_TIPO ='2' AND PAUTA.CIU_NCM = " + ValToSQL(cNCM) + " AND PAUTA.CIU_TRIB = F2E.F2E_TRIB AND (PAUTA.CIU_UFORI = " + ValToSQL(cUfOrigem) + " OR PAUTA.CIU_UFORI = '**') AND (PAUTA.CIU_UFDEST = " + ValToSQL(cUfDestino) + " OR  PAUTA.CIU_UFDEST = '**') AND " + ValToSql(dDataOper) + " >= PAUTA.CIU_VIGINI AND ( " + ValToSql(dDataOper) + " <= PAUTA.CIU_VIGFIM OR PAUTA.CIU_VIGFIM = ' ' ) AND (PAUTA.CIU_UM = " + ValToSql(c1UM) + " OR  PAUTA.CIU_UM = " + ValToSql(c2UM) + " OR PAUTA.CIU_UM = '**') AND PAUTA.D_E_L_E_T_ = ' ') "		

	//Join com Majoracao
	cFrom += "LEFT JOIN " + RetSQLName("CIU") + " MAJ " + " ON (MAJ.CIU_FILIAL = " + ValToSQL(xFilial("CIU")) + " AND MAJ.CIU_TIPO ='3' AND MAJ.CIU_NCM = " + ValToSQL(cNCM)         + " AND MAJ.CIU_TRIB = F2E.F2E_TRIB AND (MAJ.CIU_UFORI = " + ValToSQL(cUfOrigem) + " OR MAJ.CIU_UFORI = '**') AND (MAJ.CIU_UFDEST = " + ValToSQL(cUfDestino) + " OR  MAJ.CIU_UFDEST = '**') AND " + ValToSql(dDataOper) + " >= MAJ.CIU_VIGINI AND ( " + ValToSql(dDataOper) + " <= MAJ.CIU_VIGFIM OR MAJ.CIU_VIGFIM = ' ' ) AND MAJ.D_E_L_E_T_ = ' ') "		
	
	//Join com al�quota do servi�o
	cFrom += "LEFT JOIN " + RetSQLName("CIY") + " ALQ_SERV " + " ON (ALQ_SERV.CIY_FILIAL = " + ValToSQL(xFilial("CIY")) + " AND ALQ_SERV.CIY_UF = " + ValToSQL(cUfServ) + " AND ALQ_SERV.CIY_CODMUN = " + ValToSQL(cMumServ) + " AND ALQ_SERV.CIY_TRIB = F2E.F2E_TRIB AND ALQ_SERV.CIY_CODISS = " + ValToSql(cCodIss) + "  AND ALQ_SERV.D_E_L_E_T_ = ' ') "	

	cFrom += "LEFT JOIN " + RetSQLName("CIT") + " ALQ_LEICOMP " + " ON (ALQ_LEICOMP.CIT_FILIAL = " + ValToSQL(xFilial("CIT")) + " AND ALQ_LEICOMP.CIT_TRIB = F2E.F2E_TRIB AND ALQ_LEICOMP.CIT_TIPO = '2' AND ALQ_LEICOMP.CIT_CODISS = " + ValToSQL(cCodIss) + " AND  ALQ_LEICOMP.D_E_L_E_T_ = ' ') "	

	//Join com tabela de escritura��o
	IF aDic[AI_CJ2]
		cFrom += "LEFT JOIN " + RetSQLName("CJ2") + " CJ2 " + " ON CJ2.CJ2_FILIAL = " + ValToSQL(xFilial("CJ2")) + " AND CJ2.CJ2_CODIGO  = F2B.F2B_CODESC AND CJ2.CJ2_ALTERA = '2' AND CJ2.D_E_L_E_T_ = ' ' "
	Endif

EndIf

//Se��o do Where, considerando a vig�ncia do tributo.
cWhere  += "F2B.F2B_FILIAL = " + ValToSQL( xFilial("F2B") ) + " AND "
cWhere  += ValToSql(dDataOper) + " >= F2B.F2B_VIGINI AND ( " + ValToSql(dDataOper) + " <= F2B.F2B_VIGFIM OR F2B.F2B_VIGFIM = ' ' ) AND "

//Se a tabela CIN existe preciso trazer somente F2B atual
IF aDic[AI_CIN]
	cWhere  += " F2B.F2B_ALTERA <> '1' AND "
EndIF

cWhere  += "F2B.D_E_L_E_T_ = ' '"

//Concatenar� o % e executar� a query.
cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + "%"

cAliasQry := GetNextAlias()

BeginSQL Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%

EndSQL

Return cAliasQry

//-------------------------------------------------------------------
/*/{Protheus.doc} AddTrbGen()
Fun��o que tem como objetivo a cria��o da estrutur b�sicaa de refer�ncias do
tributo gen�rico, criando os arrays e populando com as informa��es
das regras de base de c�lculo, al�quota e regra financeira dos
tributos gen�ricos.
Os valores de base de c�lculo, al�quota e valor do tributo n�o ser�o
preenchidos nesta fun��o, ser�o interpretados por outra fun��o.

@param aNfItem    - Array com todas as informa��es do item
@param nItem      - N�mero do item da nota processado
@param cAliasQry  - Alias com todas as informa��es cadastrais das regras e tributos gen�ricos
@param nTGITRef   - Tamanho do array ItemRef dos tributos gen�ricos
@param aNFCab     - Array com informa��es do cabe�alho da nota fiscal
@param aPos       - Array com cache de fieldpos
@param aDic    	  - Array com cache das tabelas
@param aMapForm 	  - HashMap com o mapeamento dos operandos e formulas

@return nTrbGen  - Posi��o do novo tributo gen�rico na refer�ncia IT_TRIBGEN

@author Erick Gon�alves Dias
@since 27/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function AddTrbGen(aNfItem, nItem, cAliasQry, nTGITRef, aNFCab, aPos, aDic, aMapForm, aDepTrib, aDepVlOrig, lLoad)

local nTrbGen		:= 0
Default aDepVlOrig	:= {}
Default aDepTrib 	:= {}

//Adiciona estrutura b�sica do tributo gen�rico na refer�ncia IT_TRIBGEN
aadd(aNfItem[nItem][IT_TRIBGEN],Array(NMAX_IT_TG))

//Obtem a posi��o do tributo gen�rico adicionado
nTrbGen := Len(aNfItem[nItem][IT_TRIBGEN])

if aDic[AI_CIN]
	dbSelectArea("CIN")
	dbSetOrder(1) //F2D_FILIAL+F2D_IDREL
EndIF

//-------------------------------------------
//Preenche as refer�ncias do tributo gen�rico
//-------------------------------------------
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ID_REGRA]					:= (cAliasQry)->TRIBUTO_ID
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_SIGLA]					:= (cAliasQry)->TRIBUTO_SIGLA
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DESCRICAO]				:= (cAliasQry)->TRIBUTO_DESCRICAO
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA]					:= (cAliasQry)->ALIQUOTA
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]					:= (cAliasQry)->VALOR
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS]				:= Array(NMAXTGBAS)
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ]				:= Array(NMAXTGALQ)
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_FIN]				:= (cAliasQry)->REGRA_FIN
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE]						:= Iif((cAliasQry)->BASE_QTDE > 0,(cAliasQry)->BASE_QTDE, (cAliasQry)->BASE_CALCULO)
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_RND]						:= aPos[FP_F2B_RND] .AND. ( (cAliasQry)->TRIBUTO_RND == "1" .OR. Empty((cAliasQry)->TRIBUTO_RND))
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC]					:= {Array(nTGITRef), Array(nTGITRef)}
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_IDTRIB]					:= (cAliasQry)->IDTRIB
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ID_F2D]					:= FWUUID("F2D") //Inicializa o ID da F2D
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DED_DEP]					:= 0
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VL_ZERO]					:= .F. //Utilizar valor zero na base ou al�quota
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ULT_AQUI]					:= .F. //Operador L�gico que Define se usou Operando de Ultima Aquisi��o
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ESTR_ULT_AQUI]			:= .F. //Operador L�gico que Define se usou Operando de Ultima Aquisi��o Estrutura de Produto

//Cria n�vel das refer�ncias com regras de escritura��o - Tabela CJ2
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR]			:= Array(NMAXRE)
//Cria n�vel das refer�cias do livro - tabela CJ3
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF]					:= Array(NMAXTGLF)


//Preenche as refer�ncias do livro do TG
IF aDic[AI_CJ2]

	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_GUIA]   		:= (cAliasQry)->RGUIA //C�digo da Regra de Guia

	//Verifica se est� realizar load dos valores j� gravados antes de preencher os valores
	If lLoad	
		
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ID_F2D]	:= (cAliasQry)->IDF2D  //ID da F2D	
		
		//Ao processar visualiza��o/carregar os valores j� gravados, as refer�cias do livro estar�o preenchidas com valores da query
		ProcEscrTG(aNfItem            , nItem                 , nTrbGen               , (cAliasQry)->LCST      , (cAliasQry)->LVALTRIB  , ;
				(cAliasQry)->LISENTO  , (cAliasQry)->LOUTROS  , (cAliasQry)->LNTRIB   , (cAliasQry)->LDIFERIDO , (cAliasQry)->LMAJORADO , ;
				(cAliasQry)->LPERCMAJ , (cAliasQry)->LPERCDIF , (cAliasQry)->LPERCRED , (cAliasQry)->LPAUTA    , (cAliasQry)->LMVA      , ;
				(cAliasQry)->LAUXMVA  , (cAliasQry)->LAUXMAJ  , (cAliasQry)->LCSTCAB  , (cAliasQry)->LBASORI)
	Else
		//Ao processar visualiza��o/carregar os valores j� gravados, as refer�cias do livro estar�o preenchidas com valores da query
		ProcEscrTG(aNfItem, nItem, nTrbGen, "", 0, ;
					0, 0, 0, 0, 0, ;
					0, 0, 0, 0, 0, ;
					0, 0, "", 0)
	EndIf
Else
	//Ao processar visualiza��o/carregar os valores j� gravados, as refer�cias do livro estar�o preenchidas com valores da query
	ProcEscrTG(aNfItem, nItem, nTrbGen, "", 0, ;
				0, 0, 0, 0, 0, ;
				0, 0, 0, 0, 0, ;
				0, 0, "", 0)

EndIF

//Adiciono a f�rmula do valor 
IF aDic[AI_CIN]

	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_MVA] 		:= (cAliasQry)->MVA			//MVA
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_AUX_MVA] 	:= (cAliasQry)->MVA_AUX		//Indice auxiliar do MVA
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_PAUTA] 	:= (cAliasQry)->PAUTA		//Pauta
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_MAJ] 		:= (cAliasQry)->MAJ			//Percentual de majora��o
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_AUX_MAJ] 	:= (cAliasQry)->IND_AUX_MAJ	//Indice auxiliar do percentual de major��o	
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_TRB_MAJ] 	:= (cAliasQry)->TRIBUTO_MAJ	//C�digo do tributo que majora tributo atual
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DED_DEP]	:= (cAliasQry)->DED_DEP
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALQ_SERV]	:= (cAliasQry)->ALQ_SERVICO //Aliquota do municipio de execu��o
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALQ_SERV_LEI_COMPL]:= (cAliasQry)->ALQ_SERV_LEICOMP //Al�quota de servi�o da lei complemetar

	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_OPR_MAX]	:= (cAliasQry)->OPRLIM_MAX
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_OPR_MIN]	:= (cAliasQry)->OPRLIM_MIN
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VL_MAX]	:= (cAliasQry)->VLRMAX
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VL_MIN]	:= (cAliasQry)->VLRMIN
	
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FOR_NPI] 		:= (cAliasQry)->VAL_FOR	 //F�rmula NPI do valor
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FOR_ISE_NPI] 	:= (cAliasQry)->ISE_FOR	 //F�rmula NPI de Isento
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FOR_OUT_NPI] 	:= (cAliasQry)->OUT_FOR	 //F�rmula NPI de Outros

	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ID_NPI] 		:= (cAliasQry)->VAL_FOR_ID		//ID da f�rmula da tabela CIN
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_COD_FOR] 		:= (cAliasQry)->VAL_FOR_COD		//C�digo da f�rmula do valor do tributo
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_TAB_PROG]	    := (cAliasQry)->TABPRO  //C�digo da regra de tabela progressiva
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_DED_DEP]:= (cAliasQry)->DEDDEP  //C�digo da regra dedu��o dependentes
		
	//Realizo o mapeamento dos operandos e suas f�rmulas.
	MapOperForm(aMapForm, (cAliasQry)->VAL_FOR_COD, (cAliasQry)->VAL_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), @aDepTrib)	
	
	//Realiza o mapeamento dos tributos que dependem dos valores de origem como frete, desconto etc
	MapValOrig((cAliasQry)->VAL_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), aDepVlOrig)


	//Realizo o mapeamento dos operandos e suas f�rmulas.
	MapOperForm(aMapForm, (cAliasQry)->ISE_FOR_COD, (cAliasQry)->ISE_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), @aDepTrib)	
	
	//Realiza o mapeamento dos tributos que dependem dos valores de origem como frete, desconto etc
	MapValOrig((cAliasQry)->ISE_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), aDepVlOrig)


	//Realizo o mapeamento dos operandos e suas f�rmulas.
	MapOperForm(aMapForm, (cAliasQry)->OUT_FOR_COD, (cAliasQry)->OUT_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), @aDepTrib)	
	
	//Realiza o mapeamento dos tributos que dependem dos valores de origem como frete, desconto etc
	MapValOrig((cAliasQry)->OUT_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), aDepVlOrig)


	//Faz aqui o mapeamento da tabela progressiva com regra da tabela F2B
	IF !Empty((cAliasQry)->TABPRO)
		LoadTabPrg( (cAliasQry)->TABPRO , aTabProg)
	EndIF	
	
	//Aqui fa�o o mapeamento da regra de dedu��o por dependentes
	IF !Empty((cAliasQry)->DEDDEP)
		LoadDedDep((cAliasQry)->DEDDEP, aTabDep)
	EndIF

EndIF

//-------------------------------------------------------
//Preenche as refer�cias com as regras da base de c�lculo
//-------------------------------------------------------
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ID]		:= (cAliasQry)->BASE_ID
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_COD]	:= (cAliasQry)->BASE_COD
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI]	:= (cAliasQry)->BASE_VALORI
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_DESCON]	:= (cAliasQry)->BASE_DESCON
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_FRETE]	:= (cAliasQry)->BASE_FRETE
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_SEGURO]	:= (cAliasQry)->BASE_SEGURO
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_DESP]	:= (cAliasQry)->BASE_DESPE
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ICMSDES]:= (cAliasQry)->BASE_ICMDES
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ICMSST]	:= (cAliasQry)->BASE_ICMRET
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_REDUCAO]:= (cAliasQry)->BASE_REDBAS
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_TPRED]	:= (cAliasQry)->BASE_TPRED
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_UM]		:= (cAliasQry)->BASE_UM

//Adiciono a f�rmula da base de c�lculo
IF aDic[AI_CIN]

	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_FOR_NPI]  := (cAliasQry)->BAS_FOR		//F�rmula NPI
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ID_NPI]   := (cAliasQry)->BAS_FOR_ID	//ID da f�rmula da tabela CIN
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_COD_FOR]  := (cAliasQry)->BAS_FOR_COD	//C�digo da f�rmula
	
	//Realizo o mapeamento dos operandos e suas f�rmulas.
	MapOperForm(aMapForm, (cAliasQry)->BAS_FOR_COD, (cAliasQry)->BAS_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), @aDepTrib)

	//Realiza o mapeamento dos tributos que dependem dos valores de origem como frete, desconto etc
	MapValOrig((cAliasQry)->BAS_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), aDepVlOrig)

EndIF

//-------------------------------------------------
//Preenche as refer�ncias com as regras de al�quota
//-------------------------------------------------
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_ID]		:= (cAliasQry)->ALQ_ID
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_COD]	:= (cAliasQry)->ALQ_CODIGO
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VLORI]	:= (cAliasQry)->ALQ_VALORI
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_TPALIQ]	:= (cAliasQry)->ALQ_TPALIQ
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_ALIQ]	:= (cAliasQry)->ALQ_ALIQ
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_CODURF]	:= (cAliasQry)->ALQ_URF
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_PERURF]	:= (cAliasQry)->ALQ_UFRPER
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VALURF]	:= (cAliasQry)->URF_VALOR

//-------------------------------------------------
//Preenche as refer�ncias com as regras de escritura��o
//-------------------------------------------------
If aDic[AI_CJ2]
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_ID]		:= (cAliasQry)->ESCR_ID
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_INCIDE]	:= (cAliasQry)->INCIDE 
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_TOTNF]		:= (cAliasQry)->TOTNF 
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_PERCDIF]	:= (cAliasQry)->PERCDIF 
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_CST]		:= (cAliasQry)->CST 
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_CSTCAB]	:= (cAliasQry)->CSTCAB
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_INC_PARC_RED]	:= (cAliasQry)->INC_RED //Incidencia parcela reduzida
Endif

//Adiciono as informa��es da f�rmula de c�lculo
IF aDic[AI_CIN]
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_FOR_NPI] := (cAliasQry)->ALQ_FOR		//F�rmula NPI
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_ID_NPI]  := (cAliasQry)->ALQ_FOR_ID		//ID da f�rmula da tabela CIN
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_COD_FOR]  := (cAliasQry)->ALQ_FOR_COD	//C�digo da f�rmula

	//Realizo o mapeamento dos operandos e suas f�rmulas.
	MapOperForm(aMapForm, (cAliasQry)->ALQ_FOR_COD, (cAliasQry)->ALQ_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), @aDepTrib)

	//Realiza o mapeamento dos tributos que dependem dos valores de origem como frete, desconto etc
	MapValOrig((cAliasQry)->ALQ_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), aDepVlOrig)

EndIF

//--------------------------------------------------------------------------
//Inicializo com zeros o controle do ItemDec do item dos tributos gen�ricos
//--------------------------------------------------------------------------
aFill(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1],0)
aFill(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2],0)

Return nTrbGen

//-------------------------------------------------------------------
/*/{Protheus.doc} FisCalcTG()
Fun��o respons�vel por interpretar as regras e efetuar o c�lculo dos
tributos gen�ricos conforme cadastrados.

@param aNfItem - Array com toda as informa��es do item da nota fiscal
@param nItem   - N�mero do item da nota fiscal
@param nTrbGen - Posi��o do tributo gen�rio na refer�ncia IT_TRIBGEN
@param cExecuta - Indica as op��es de base, al�quota e valor que dever�o ser calculadas.
@param aNFCab   - Array com informa��es do cabe�alho da nota fiscal
@param aMapForm 	  - HashMap com o mapeamento dos operandos e formulas

@author joao.pellegrini
@since 27/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FisCalcTG(aNFItem, nItem, nTrbGen, cExecuta, aNFCab,aMapForm, lEdicao, aFunc)

DEFAULT cExecuta := "BSE|ALQ|VLR"
Default lEdicao	:= .F.

//--------------------------------------------------------------------
//Adiciono nova posi��o para controle do SaveDec do tributo gen�rico
//--------------------------------------------------------------------
//Preciso verificar se o tributo j� consta no array do SaveDec, se j� existe n�o precisa adicoonar, se n�o existe ai ser� criado.		
TgSaveDec(@aNFCab, @aNfItem, nItem, nTrbGen)

//Aqui verifico se o tributo possuir f�rmula...Sem f�rmula calcular� da forma legada na primeira onda...com f�rmula executar� as fun��es de NPI
If Empty( aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FOR_NPI] )
	
	//-------
	//Legado
	//-------
	FisCalcLeg(aNFItem, nItem, nTrbGen, cExecuta, aNFCab)

ElseIF aFunc[FF_XFISTPFORM]

	//-------
	//F�rmula
	//-------	
	FisCalcForm(aNFItem, nItem, nTrbGen, cExecuta, aNFCab,aMapForm, lEdicao)

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FisLoadTG()
Fun��o respons�vel por buscar os valores dos tributos gen�ricos gravados
na CD2, para carregar estes valores e adicionar nas refer�ncias do IT_TRBGEN

@param aNfItem   - Array Com todas informa��es do aNfItem
@param nItem     - N�mero do item atual
@param cIdDevol  - ID da tabela F2D para as notas de devolu��es
@param nTGITRef  - Posi��o do Id do tributo gen�rico que dever� ser carregado
@param aNfCab    - Array Com todas informa��es do aNfCab
@param aPos      - Array com o cache de fieldpos
@param aDic    	 - Array com cache das tabelas
@param aMapForm 	  - HashMap com o mapeamento dos operandos e formulas

@author Erick Gon�alves Dias
@since 03/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FisLoadTG(aNfItem, nItem, cIdDevol, nTGITRef, aNFCab, aPos, aDic, aMapForm, lReproc)

Local cSelect		:= ""
Local cFrom	    	:= ""
Local cWhere		:= ""
Local cAliasQry		:= ""
Local cIdTrbGen		:= ""
Local nPosPrepared	:= 0 
Local cQuery	 	:= ""
Local cMD5			:= ""
Local nLen 			:= 0
Local aInsert		:= {}
Local nX 			:= 0
Default cIdDevol	:= ""

//---------------------------------------------------------------------------------
//IMPORTANTE - OS NOMES DOS CAMPOS DEVEM SER IGUAIS DA QUERY DA FUN��O QryTribGen()
//---------------------------------------------------------------------------------

//Para as devolu��es dever� considerar o ID do cIdDevol, para os demais cas
cIdTrbGen	:= Iif(!Empty(cIdDevol),cIdDevol,aNfItem[nItem][IT_ID_LOAD_TRBGEN])

//Zero o controle de SaveDEc dos tributos gen�ricos caso j� tenha sido criado
aNFCab[NF_SAVEDEC_TG]	:= {}

//Somente farei a query se o ID estiver preenchido.
If !Empty(cIdTrbGen)

	//Se��o dos campos da tabela F2D.
	cSelect := "F2D.F2D_TRIB  TRIBUTO_SIGLA, F2D.F2D_BASE  BASE_CALCULO, F2D.F2D_BASQTD BASE_QTDE , F2D.F2D_ALIQ   ALIQUOTA, "
	cSelect += "F2D.F2D_VALOR VALOR , F2D.F2D_IDCAD TRIBUTO_ID  ,F2D.F2D_ID IDF2D ,F2B.F2B_DESC TRIBUTO_DESCRICAO, F2D_VALURF URF_VALOR, "
	cSelect += "F2D.F2D_RFIN REGRA_FIN, F2E.F2E_IDTRIB IDTRIB,  "

	//Verifica se o campo existe antes de adicionar na query
	If aPos[FP_F2B_RND]
		cSelect += " F2B.F2B_RND TRIBUTO_RND, "		
	EndIf

	//Se��o dos campos da regra de base de c�lculo
	cSelect += "F27.F27_CODIGO BASE_COD   , F27.F27_VALORI BASE_VALORI , F27.F27_DESCON BASE_DESCON, F27.F27_FRETE  BASE_FRETE, "
	cSelect += "F27.F27_SEGURO BASE_SEGURO, F27.F27_DESPE  BASE_DESPE  , F27.F27_ICMDES BASE_ICMDES, F27.F27_ICMRET BASE_ICMRET,  "
	cSelect += "F27.F27_REDBAS BASE_REDBAS, F27.F27_TPRED  BASE_TPRED  , F27.F27_UM     BASE_UM    , F27.F27_ID     BASE_ID,"

	//Se��o dos campos da regra de al�quota
	cSelect += "F28.F28_CODIGO ALQ_CODIGO , F28.F28_VALORI ALQ_VALORI, F28.F28_TPALIQ ALQ_TPALIQ, F28.F28_ALIQ ALQ_ALIQ, "
	cSelect += "F28.F28_URF    ALQ_URF    , F28.F28_UFRPER ALQ_UFRPER, F28.F28_ID     ALQ_ID"
	
	//Verifica se tabela CIN existe para buscar os campos novos
	IF aDic[AI_CIN]
		cSelect += " ,F2B.F2B_DEDPRO TABPRO, F2B.F2B_DEDDEP DEDDEP, F2B.F2B_RGGUIA RGUIA,  "
		cSelect += " F2B.F2B_VLRMIN VLRMIN, F2B.F2B_VLRMAX VLRMAX, F2B.F2B_OPRMIN OPRLIM_MIN, F2B.F2B_OPRMAX OPRLIM_MAX,"
		cSelect += " F2D.F2D_MVA MVA , F2D.F2D_AUXMVA MVA_AUX, "
		cSelect += " F2D.F2D_PAUTA PAUTA, "
		cSelect += " F2D.F2D_MAJORA MAJ, F2D.F2D_AUXMAJ IND_AUX_MAJ, F2D.F2D_TRBMAJ TRIBUTO_MAJ, F2D.F2D_DEDDEP DED_DEP,"
		cSelect += " F2D.F2D_ALIQ ALQ_SERVICO, F2D.F2D_ALIQ ALQ_SERV_LEICOMP "

		cSelect += ", CINBAS.CIN_FNPI BAS_FOR,  CINBAS.CIN_ID BAS_FOR_ID ,  CINBAS.CIN_CODIGO BAS_FOR_COD "
		cSelect += ", CINALQ.CIN_FNPI ALQ_FOR,  CINALQ.CIN_ID ALQ_FOR_ID ,  CINALQ.CIN_CODIGO ALQ_FOR_COD "
		cSelect += ", CINVAL.CIN_FNPI VAL_FOR,  CINVAL.CIN_ID VAL_FOR_ID ,  CINVAL.CIN_CODIGO VAL_FOR_COD "
		cSelect += ", CINISE.CIN_FNPI ISE_FOR,  CINISE.CIN_ID ISE_FOR_ID ,  CINISE.CIN_CODIGO ISE_FOR_COD "
		cSelect += ", CINOUT.CIN_FNPI OUT_FOR,  CINOUT.CIN_ID OUT_FOR_ID ,  CINOUT.CIN_CODIGO OUT_FOR_COD "
	EndIF	

	//Adiciona campos na se��o de select da query com campos de escritura��o
	IF aDic[AI_CJ2]
		cSelect += ", CJ2.CJ2_ID ESCR_ID, CJ2.CJ2_INCIDE INCIDE,  CJ2.CJ2_STOTNF TOTNF ,  CJ2.CJ2_PERDIF PERCDIF,  CJ2.CJ2_CSTCAB CSTCAB "	
		cSelect += ", CJ2.CJ2_IREDBS INC_RED, CJ2.CJ2_CSTDEV CST_DEV"

		If !Empty(cIdDevol)
			cSelect += ", CJ2.CJ2_CSTDEV CST "
			cSelect += ", CJ2.CJ2_CSTDEV LCST " 
		Else
			cSelect += ", CJ2.CJ2_CST CST "
			cSelect += ", CJ3.CJ3_CST LCST " 
		EndIf

		//Campos do livro 
		cSelect += ", CJ3.CJ3_VLTRIB LVALTRIB  ,  CJ3.CJ3_VLISEN LISENTO   , CJ3.CJ3_VLOUTR LOUTROS "
		cSelect += ", CJ3.CJ3_VLNTRI LNTRIB  ,  CJ3.CJ3_VLDIFE LDIFERIDO ,  CJ3.CJ3_VLMAJO LMAJORADO , CJ3.CJ3_PEMAJO LPERCMAJ "
		cSelect += ", CJ3.CJ3_PEDIFE LPERCDIF,  CJ3.CJ3_PEREDU LPERCRED  ,  CJ3.CJ3_PAUTA LPAUTA     , CJ3.CJ3_MVA LMVA "
		cSelect += ", CJ3.CJ3_AUXMVA LAUXMVA ,  CJ3.CJ3_AUXMAJ LAUXMAJ	 ,  CJ3.CJ3_CSTCAB LCSTCAB "
		cSelect += ", CJ3.CJ3_BASORI LBASORI "
		
	EndIF

	//From na tabela F2D
	cFrom   += RetSQLName("F2D") + " F2D "

	//Join com a tabela de tributo F2B. Aqui est� LEFT JOIN somente por precau��o, se fosse INNER JOIN o tributo n�o seria carregado caso a F2B tivesse sido deletada indevidamente.
	//De qualquer forma o usu�rio n�o consegue deletar devido o relacionamento na X9 entre as tabelas F2D e F2B.
	cFrom += "LEFT JOIN " + RetSQLName("F2B") + " F2B " + " ON (F2B.F2B_ID = F2D.F2D_IDCAD AND F2B.D_E_L_E_T_ = ' ') "

	//Join com o cadastro de Tributo F2E
	cFrom += "LEFT JOIN " + RetSQLName("F2E") + " F2E " + " ON (F2E.F2E_FILIAL = ? AND F2E.F2E_TRIB = F2B.F2B_TRIB AND F2E.D_E_L_E_T_ = ' ') "
	Aadd(aInsert, xFilial("F2E"))

	//Join com a regra de base de c�lculo utilizada no c�lculo do tributo gen�rico
	cFrom += "LEFT JOIN " + RetSQLName("F27") + " F27 " + " ON (F27.F27_ID = F2D.F2D_IDBASE AND F27.D_E_L_E_T_ = ' ') "

	//Join com a regra de al�quota utilizada no c�lculo do tributo gen�rico
	cFrom += "LEFT JOIN " + RetSQLName("F28") + " F28 " + " ON (F28.F28_ID = F2D.F2D_IDALIQ AND F28.D_E_L_E_T_ = ' ') "

	//----------------------------------------------------------------------------------------------------------------------------------------------------------------
	//Se a tabela CIN de f�rmulas existir, ent�o farei left join para carregar as f�rmulas das regras de base de c�lculo, al�quota e tributo que foram gravadas na F2D
	//----------------------------------------------------------------------------------------------------------------------------------------------------------------
	IF aDic[AI_CIN]
		//F�rmula da base
		cFrom += "LEFT JOIN " + RetSQLName("CIN") + " CINBAS " + " ON (CINBAS.CIN_FILIAL = ? AND CINBAS.CIN_ID = F2D.F2D_IFBAS AND CINBAS.D_E_L_E_T_ = ' ') "
		Aadd(aInsert, xFilial("CIN"))

		//F�rmula da al�quota
		cFrom += "LEFT JOIN " + RetSQLName("CIN") + " CINALQ " + " ON (CINALQ.CIN_FILIAL = ? AND CINALQ.CIN_ID = F2D.F2D_IFALQ AND CINALQ.D_E_L_E_T_ = ' ') "
		Aadd(aInsert, xFilial("CIN"))
		
		//F�rmula do valor.
		cFrom += "LEFT JOIN " + RetSQLName("CIN") + " CINVAL " + " ON (CINVAL.CIN_FILIAL = ? AND CINVAL.CIN_ID = F2D.F2D_IFVAL AND CINALQ.D_E_L_E_T_ = ' ') "		
		Aadd(aInsert, xFilial("CIN"))

		//F�rmula de Isento
		cFrom += "LEFT JOIN " + RetSQLName("CIN") + " CINISE " + " ON (CINISE.CIN_FILIAL = ? AND CINISE.CIN_IREGRA = F2B.F2B_ID AND CINISE.CIN_TREGRA = '11' AND CINISE.D_E_L_E_T_ = ' ') "
		Aadd(aInsert, xFilial("CIN"))

		//F�rmula de Outros
		cFrom += "LEFT JOIN " + RetSQLName("CIN") + " CINOUT " + " ON (CINOUT.CIN_FILIAL = ? AND CINOUT.CIN_IREGRA = F2B.F2B_ID AND CINOUT.CIN_TREGRA = '12' AND CINOUT.D_E_L_E_T_ = ' ') "
		Aadd(aInsert, xFilial("CIN"))
	EndIf

	//Join com a regra de escritura��o
	IF aDic[AI_CJ2]
		cFrom += "LEFT JOIN " + RetSQLName("CJ3") + " CJ3 " + " ON CJ3.CJ3_FILIAL = ? AND CJ3.CJ3_IDF2D   = F2D.F2D_ID AND CJ3.CJ3_IDTGEN = F2D.F2D_IDREL AND CJ3.D_E_L_E_T_ = ' ' "
		Aadd(aInsert, xFilial("CJ3"))
		cFrom += "LEFT JOIN " + RetSQLName("CJ2") + " CJ2 " + " ON CJ2.CJ2_FILIAL = ? AND CJ2.CJ2_CODIGO  = F2B.F2B_CODESC AND " + Iif(lReproc, " CJ2.CJ2_ALTERA = '2' " ," CJ2.CJ2_ID = CJ3.CJ3_IDRESC ") + " AND CJ2.D_E_L_E_T_ = ' ' "
		Aadd(aInsert, xFilial("CJ2"))
	Endif

	//Condi��o do where da query para trazer as informa��es do ID em quest�o.		
	cWhere  += "F2D.F2D_IDREL =  ?  AND "
	Aadd(aInsert, cIdTrbGen)
	cWhere  += "F2D.D_E_L_E_T_ = ' '"
		
			
	cQuery := " SELECT " + cSelect + " FROM " + cFrom + " WHERE " + cWhere
	cMD5 := MD5(cQuery)
	If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0		
		Aadd(__aPrepared,{FWPreparedStatement():New(),cMD5})
		nPosPrepared := Len(__aPrepared)
		__aPrepared[nPosPrepared][1]:SetQuery(ChangeQuery(cQuery))
	EndIf 
	
	//Adiciona filtro
	nLen := Len(aInsert)
	For nX := 1 to nLen
		__aPrepared[nPosPrepared][1]:SetString(nX,aInsert[nX])	
	Next
	
	aInsert := aSize(aInsert,0)	
	
	cQuery := __aPrepared[nPosPrepared][1]:getFixQuery()
	
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)


	//Processa todos os tributos gen�ricos gravados na F2D
	Do While !(cAliasQry)->(Eof())

		//Adiciona na refer�ncia IT_TRIBGEN as informa��es do tributo gen�rico considerando as informa��es da F2D.
		AddTrbGen(@aNfItem, nItem, cAliasQry,nTGITRef,aNFCab,aPos, aDic, aMapForm,,,.T.)
		(cAliasQry)->(DbSKip())
	Enddo

	//Fecha o Alias antes de sair da fun��o
	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbCloseArea ())	

EndIF

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} xFisGrbTrbGen()
Fun��o respons�vel por realizar a grava��o dos tributos gen�ricos na tabela F2D.
A grava��o ir� considerar as informa��es contidas na refer�ncia do aNfItem IT_TRBGEN

@param aNfItem - Array com todas as informa��es do item da nota fiscal
@param nItem - N�mero do item a ser processado por esta fun��o.
@param cAlias - Alias da tabela do item que ter� gravado o ID do tributo gen�rico.
@param aDic   - Array com cache das tabelas

@return cRet - Retornar o ID utilizado na grava��o dos tributos na F2D, para que os fontes
consumidores possam gravar este ID em suas respectivas tabelas de itens, como a SD1 e SD2.

@author Erick Gon�alves Dias
@since 09/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FisGrvTrbGen(aNfItem, nItem, cAlias, aDic)

Local nTrbGen 	:= 0
Local nTrbMaj   := 0
Local cRet		:= ""

dbSelectArea("F2D")

//Percorre o array e gravar� F2B para todos os tributos gen�ricos calculados
For nTrbGen:= 1 to Len(aNfItem[nItem][IT_TRIBGEN])

	If (aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE] > 0 .And. aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR] > 0) .OR. aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DED_DEP] > 0;
	.Or. aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VL_ZERO]

		RecLock("F2D",.T.)	

		F2D->F2D_FILIAL	:=	xFilial("F2D")
		F2D->F2D_ID		:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ID_F2D]
		F2D->F2D_IDREL	:=	aNfItem[nItem][IT_ID_TRBGEN]
		F2D->F2D_TABELA	:=	cAlias
		F2D->F2D_RFIN	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_FIN]
		F2D->F2D_TRIB  	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_SIGLA]
		F2D->F2D_ALIQ  	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA]
		F2D->F2D_VALOR 	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]
		F2D->F2D_IDCAD 	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ID_REGRA]
		F2D->F2D_IDBASE :=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ID]
		F2D->F2D_IDALIQ :=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_ID]
		F2D->F2D_VALURF	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VALURF]

		//Tratamento para base de c�lculo em quantidade
		If aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '02'
			//Base de c�lculo em quantidade
			F2D->F2D_BASQTD	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE]
		Else
			//Base de c�lculo normal com valor
			F2D->F2D_BASE  	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE]
		EndIF
		
		//Se a tabela CIN existir ent�o gravar� os campos dos IDs das f�rmulas na F2D
		IF aDic[AI_CIN]
			F2D->F2D_IFBAS	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ID_NPI]
			F2D->F2D_IFALQ	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_ID_NPI]
			F2D->F2D_IFVAL	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ID_NPI]
			
			//Gravo tamb�m os campos com os �ndices de c�lculos utilizados/enquadrados.
			F2D->F2D_MVA	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_MVA]
			F2D->F2D_AUXMVA	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_AUX_MVA]
			F2D->F2D_PAUTA	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_PAUTA]
			F2D->F2D_MAJORA	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_MAJ]
			F2D->F2D_AUXMAJ	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_AUX_MAJ]
			
			//Grava os campos de valor majorado e al�quota majorada. Para isso  verificarei o tributo na refer�ncia TG_IT_TRB_MAJ
			//Posicionar o tributo, se encontrar grava os valores
			If(nTrbMaj 	:= GetPosTrib(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_TRB_MAJ] , aNfItem, nItem)) > 0
				F2D->F2D_TRBMAJ	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_TRB_MAJ]
				F2D->F2D_VALMAJ	:= aNfItem[nItem][IT_TRIBGEN][nTrbMaj][TG_IT_VALOR]
				F2D->F2D_ALQMAJ	:= aNfItem[nItem][IT_TRIBGEN][nTrbMaj][TG_IT_ALIQUOTA]
			EndIF						

			F2D->F2D_DEDDEP	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DED_DEP]

		EndIF

		cRet	:= aNfItem[nItem][IT_ID_TRBGEN]

		F2D->(MsUnLock())
		
	EndIF

Next nTrbGen

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FisGrvCJ3()

Fun��o que far� grava��o da tabela CJ3, livro Fiscal dos tributos gen�ricos

@param aNFItem 		- Array com informa��es do aNfItem
@param nItem 		- N�mero do item a ser verificado
@param nTrbGen 	    - Posi��o do tributo 

@return cIdEscrit - ID da escritura��o

@author Erick Gon�alves Dias
@since 13/08/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Function FisGrvCJ3(aNfItem, nItem, nTrbGen)

Local cIdEscrit	:= FWUUID("CJ3")

If !Empty(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_ID])
	RecLock("CJ3",.T.)

	CJ3->CJ3_FILIAL	:=	xFilial("CJ3")
	CJ3->CJ3_IDESCR	:=	cIdEscrit //ID da pr�pria tabela
	CJ3->CJ3_IDF2D	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ID_F2D] //ID de relacionamento com F2D
	CJ3->CJ3_IDRESC :=  aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_ID] //ID de relacionamento com regra de escritura��o

	//Darei prefer�ncia para o ID do IT_ID_LOAD_TRBGEN, pois trata-se ~de manter o ID j� gravado, como no caso de reprocessamento
	IF !Empty(aNfItem[nItem][IT_ID_LOAD_TRBGEN])
		CJ3->CJ3_IDTGEN	:=	 aNfItem[nItem][IT_ID_LOAD_TRBGEN] //ID dos tributos gen�ricos do item
	Else
		CJ3->CJ3_IDTGEN	:=	 aNfItem[nItem][IT_ID_TRBGEN] //ID dos tributos gen�ricos do item
	EndIf

	CJ3->CJ3_TRIB	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_SIGLA] //CST do tributo
	CJ3->CJ3_CSTCAB	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_CSTCAB]
	CJ3->CJ3_CST	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_CST]
	CJ3->CJ3_VLTRIB	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_VALTRIB]
	CJ3->CJ3_VLISEN	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_ISENTO]
	CJ3->CJ3_VLOUTR	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_OUTROS]
	CJ3->CJ3_VLNTRI	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_NAO_TRIBUTADO]
	CJ3->CJ3_VLDIFE	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_DIFERIDO]
	CJ3->CJ3_VLMAJO	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_MAJORADO]
	CJ3->CJ3_PEMAJO	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_PERC_MAJORACAO]
	CJ3->CJ3_PEDIFE	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_PERC_DIFERIDO]
	CJ3->CJ3_PEREDU	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_PERC_REDUCAO]
	CJ3->CJ3_PAUTA	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_PAUTA]
	CJ3->CJ3_MVA	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_MVA]
	CJ3->CJ3_AUXMVA	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_AUX_MVA]
	CJ3->CJ3_AUXMAJ	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_AUX_MAJORACAO]
	CJ3->CJ3_BASORI	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_BASE_ORI]

	CJ3->(MsUnLock())

EndIf

Return cIdEscrit

//-------------------------------------------------------------------
/*/{Protheus.doc} FisDelTrbGen()
Fun��o respons�vel por adicionar a data de exclus�o do registro na
tabela F2D. Esta tabela nunca ser� efetivamente deletada pois caso
o documento de origem seja cancelado/exclu�do perderia-se a rela��o
entre as tabelas.

@param cIdTribGen - ID para buscar as informa��es que ser�o deletadas

@author Erick Gon�alves Dias
@since 10/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FisDelTrbGen(cIdTrbGen)

dbSelectArea("F2D")
dbSetOrder(2) //AL+F2D_IDREL

If !Empty(cIdTrbGen)
	//Busca por tributos considerando o Id
	If F2D->(MsSeek(xFilial("F2D")+cIdTrbGen))
		//La�o para excluir todos os tributos gen�ricos do ID em quest�o
		While !F2D->(Eof()) .And. xFilial("F2D")+cIdTrbGen == F2D->F2D_FILIAL+F2D->F2D_IDREL
			RecLock("F2D",.F.)
			F2D->F2D_DTEXCL := dDataBase
			MsUnLock()
			F2D->(FkCommit())
			F2D->(dbSkip())
		EndDo
	EndIF

	//Verifica se tabela de livro dos tributos gen�ricos existe, e atualizar� a data de exclus�o
	FisXDelCJ3(cIdTrbGen, "1")

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FisChkTG()
Fun��o respons�vel por efetuar algumas valida��es para utiliza��o dos
tributos gen�ricos.

@param cAlias - Alias da tabela no qual ser� gravado o ID de relacionamento
com a tabela F2D.
@para cCampo - Campo no qual ser� gravado o ID de relacionamento com a
tabela F2D.

@author Erick Gon�alves Dias
@since 10/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FisChkTG(cAlias, cCampo)

Local lRet := cPaisLoc == "BRA" .And. AliasInDic("F2D") .And. !Empty(cAlias) .And. AliasInDic(cAlias) .AND. (cAlias)->(FieldPos(cCampo)) > 0 .AND. ;
		      FindFunction("MaFisTG") .AND. FindFunction("FisRetTG") .AND. FindFunction("FisF2F") .And. FindFunction("FisTitTG") .AND. ;
			  !Empty(MaFisScan("NF_TRIBGEN",.F.))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FisDevTrbGen()
Fun��o respons�vel por tratar as devolu��es de venda e de compra dos tributos
gen�ricos.
Esta fun��o utilizar� o RECORI da SD1/SD2 para buscar o ID do tributo gen�rico,
far� a carga dos valores e proporcionalizar� considerando a quantidade da nota
original com a nota de devolu��o.

@param aNfCab   - Array com as informa��es cabe�alho da nota fiscal
@param aNfItem  - Array com toda as informa��es do item da nota fiscal
@param nItem    - N�mero do item da nota fiscal
@param aPos    - Array com cache dos fieldpos
@param aDic    - Array com cache de aliasindic
@param cCampo  - String com o campo alterado na pilha da recall
@param nTGITRef - Tamanho do array ItemRef dos tributos gen�ricos

@author Erick Gon�alves Dias
@since 11/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FisDevTrbGen(aNfCab, aNfItem, nItem, aPos, aDic, cCampo,nTGITRef, aMapForm)

Local cIdTrbGen := ""
Local nTrbGen	:= 0
Local nQtdeOri	:= 0

//Verifica se � devolu��o de compra ou venda, posiciona no item original e busca o ID do tribGEN e quantidade
If aNFCab[NF_CLIFOR] == "C" .AND. aPos[FP_D2_IDTRIB]
	//Devolu��o de compra
	dbSelectArea("SD2")
	MsGoto(aNFItem[nItem][IT_RECORI])
	cIdTrbGen	:= SD2->D2_IDTRIB
	nQtdeOri	:= SD2->D2_QUANT
ElseIF aPos[FP_D1_IDTRIB]
	//Devolu��o de venda
	dbSelectArea("SD1")
	MsGoto(aNFItem[nItem][IT_RECORI])
	cIdTrbGen	:= SD1->D1_IDTRIB
	nQtdeOri	:= SD1->D1_QUANT
EndIF

//Zero toda a estrutura dos tributos gen�ricos, j� que os valores ser�o todos carregados da nota fiscal de origem
aNfItem[nItem][IT_TRIBGEN]	:= Nil
aNfItem[nItem][IT_TRIBGEN]	:= {}

//Verifico se o ID est� preenchido e se a tabela existe antes de fazer carga dos tributos gen�ricos da nota original
IF !Empty(cIdTrbGen) .AND. aDic[AI_F2D]
	//Somente farei a query se a quantidade devolvida for maior que zero.
	If aNfItem[nItem][IT_QUANT] > 0
		//Fun��o que faz query na F2D parra buscar os valores dos tributos gen�ricos da nota original
		FisLoadTG(@aNfItem, nItem, cIdTrbGen, nTGITRef, aNFCab, aPos, aDic, aMapForm, .F.)
	EndIF
EndIF

//Percorre o os tributos gen�ricos carregados para aplicar a proporcionalidade caso seja devolu��o parcial.
//Para devolu��o integral n�o h� necessidade de fazer proporcionalidade
If nQtdeOri <> aNfItem[nItem][IT_QUANT]
	For nTrbGen:= 1 to Len(aNfItem[nItem][IT_TRIBGEN])

		//--------------------------------------------------------------------
		//Adiciono nova posi��o para controle do SaveDec do tributo gen�rico
		//--------------------------------------------------------------------
		//Preciso verificar se o tributo j� consta no array do SaveDec, se j� existe n�o precisa adicoonar, se n�o existe ai ser� criado.		
		TgSaveDec(@aNFCab, @aNfItem, nItem, nTrbGen)

		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR] := (aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]) / nQtdeOri
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE]  := (aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE])  / nQtdeOri
	Next nTrbGen
EndIF

Return

/*/{Protheus.doc} FisRetTG()
@description Fun��o respons�vel por retornar os tributos gen�ricos pass�veis de reten��o

@param dDataOper   - Data da opera��o, para enquadrar somente as regras vigentes
@return   aRet     - Array com os tributos que possuem regras de reten��es vigentes

@author erick.dias
/*/
Function FisRetTG(dDataOper)

Local aRet	:= {}
Local cSelect	:= ""
Local cFrom	    := ""
Local cWhere	:= ""
Local cAliasQry	:= ""
Local lFinFkkVIg	:= FindFunction("FinFKKVig")

IF lFinFkkVIg
	//Se��o dos campos do cadastro do tributo F2B, tributo e descri��o
	cSelect += "F2B.F2B_REGRA TRIBUTO_SIGLA, F2B.F2B_DESC TRIBUTO_DESCRICAO, F2B.F2B_RFIN  "

	//From ser� executado na tabela F2B - Regras dos tributos x Opera��o
	cFrom   += RetSQLName("F2B") + " F2B "

	//Se��o do Where, considerando a vig�ncia do tributo.
	cWhere  += "F2B.F2B_FILIAL = " + ValToSQL( xFilial("F2B") ) + " AND "
	cWhere  += ValToSql(dDataOper) + " >= F2B.F2B_VIGINI AND ( " + ValToSql(dDataOper) + " <= F2B.F2B_VIGFIM OR F2B.F2B_VIGFIM = ' ' ) AND F2B.F2B_RFIN <> ' ' AND "
	cWhere  += "F2B.D_E_L_E_T_ = ' '"

	//Concatenar� o % e executar� a query.
	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom   + "%"
	cWhere  := "%" + cWhere  + "%"

	cAliasQry := GetNextAlias()

	BeginSQL Alias cAliasQry

		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%

	EndSQL

	//Adiciona no array sigla e descri��o dos tributos retornados
	Do While !(cAliasQry)->(Eof())

		//A fun��o posiciona na FKK corrente, considerando o c�digo da FKK e dataOper, retornando o RECNO.
		//Somente avaliar� a FKK
		If FinFKKVig((cAliasQry)->F2B_RFIN, dDataOper) > 0 .AND. !Empty(FKK->FKK_CODFKO)
			aAdd(aRet,{(cAliasQry)->TRIBUTO_SIGLA,(cAliasQry)->TRIBUTO_DESCRICAO} )
		EndIF

		(cAliasQry)->(DbSKip())
	Enddo

	//Fecha o Alias antes de sair da fun��o
	dbSelectArea(cAliasQry)
	dbCloseArea()

EndIF

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FisGetURF

Fun��o que retornar� o valor atual da URF, considerando o per�odo
e c�digo da URF.

@param dDate     - Data da opera��o, para poder enquadrar a URF vig�nte
@param cCodURF   - C�digo da URF configurada na regra de al�quota
@param nPercURF  - Percentual da URF configurada na regra de al�quota

@return nUrfAtual  - Valor da URF conforme os par�metros de entradas

@author Erick Dias
@since 06/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FisGetURF(dDate, cCodURF, nPercURF)

Local nUrfAtual		:= 0
Default nPercURF	:= 100

IF AliasIndic("F2A")
	F2A->(dbSetOrder(1))
	If !Empty(dDate) .AND. !Empty(cCodURF) .AND. F2A->(MsSeek(xFilial("F2A") + padr(cCodURF,6) + Str(Year(dDate),4) + Strzero(Month(dDate),2)))

		nUrfAtual	:= F2A->F2A_VALOR
		If nPercURF > 0
			nUrfAtual	:= nUrfAtual * (nPercURF / 100)
		EndIF

	EndIF
EndIf

Return nUrfAtual

/*/{Protheus.doc} FisHdrTG()
@description Fun��o respons�vel por montar o aHeader do folder
dos tributos gen�ricos.
@author erick.dias
/*/
Function FisHdrTG()

Local aHdrTrbGen    := {}

aAdd(aHdrTrbGen,;
{"Item",;
"ITEM",;
"@!",;
4,;
0,;
"",;
"",;
"C",;
"",;
"R",;
"",;
"",;
""})

aAdd(aHdrTrbGen,;
{"Sigla",;
"F2D_TRIB",;
PesqPict("F2D","F2D_TRIB"),;
TamSX3("F2D_TRIB")[1] + 5 ,;
TamSX3("F2D_TRIB")[2],;
"",;
"",;
"C",;
"",;
"R",;
"",;
"",;
""})

aAdd(aHdrTrbGen,;
{"Descri��o",;
"F2D_DESC",;
"@!",;
50,;
0,;
"",;
"",;
"C",;
"",;
"R",;
"",;
"",;
""})

aAdd(aHdrTrbGen,;
{"Base de C�lculo",;
"F2D_BASE",;
PesqPict("F2D","F2D_BASE"),;
TamSx3("F2D_BASE")[1],;
TamSX3("F2D_BASE")[2],;
"!Empty(GdFieldGet('F2D_TRIB',,.T.)) .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('F2D_BASE',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_IT_BASE'}, Val(GdFieldGet('ITEM',,.T.)))",;
"",;
"N",;
"",;
"R",;
"",;
"",;
""})

aAdd(aHdrTrbGen,;
{"Al�quota",;
"F2D_ALIQ",;
PesqPict("F2D","F2D_ALIQ"),;
TamSx3("F2D_ALIQ")[1],;
TamSX3("F2D_ALIQ")[2],;
"!Empty(GdFieldGet('F2D_TRIB',,.T.)) .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('F2D_ALIQ',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_IT_ALIQUOTA'}, Val(GdFieldGet('ITEM',,.T.)))",;
"",;
"N",;
"",;
"R",;
"",;
"",;
""})

aAdd(aHdrTrbGen,;
{"Valor",;
"F2D_VALOR",;
PesqPict("F2D","F2D_VALOR"),;
TamSx3("F2D_VALOR")[1],;
TamSX3("F2D_VALOR")[2],;
"!Empty(GdFieldGet('F2D_TRIB',,.T.))  .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('F2D_VALOR',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_IT_VALOR'},Val(GdFieldGet('ITEM',,.T.)))",;
"",;
"N",;
"",;
"R",;
"",;
"",;
""})

//Colunas dos campos de escritura��o no livro dos tributos gen�ricos
if AliasIndic("CJ3")

	aAdd(aHdrTrbGen,;
	{"C�digo da Situa��o Tribut�ria",;
	"CJ3_CST",;
	PesqPict("CJ3","CJ3_CST"),;
	TamSx3("CJ3_CST")[1],;
	TamSX3("CJ3_CST")[2],;
	"!Empty(GdFieldGet('F2D_TRIB',,.T.))  .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('CJ3_CST',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_LF_CST'},Val(GdFieldGet('ITEM',,.T.)))",;
	"",;
	"C",;
	"",;
	"R",;
	"",;
	"",;
	""})

	aAdd(aHdrTrbGen,;
	{"Valor Tributado",;
	"CJ3_VLTRIB",;
	PesqPict("CJ3","CJ3_VLTRIB"),;
	TamSx3("CJ3_VLTRIB")[1],;
	TamSX3("CJ3_VLTRIB")[2],;
	"!Empty(GdFieldGet('F2D_TRIB',,.T.))  .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('CJ3_VLTRIB',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_LF_VALTRIB'},Val(GdFieldGet('ITEM',,.T.)))",;
	"",;
	"N",;
	"",;
	"R",;
	"",;
	"",;
	""})

	aAdd(aHdrTrbGen,;
	{"Isento",;
	"CJ3_VLISEN",;
	PesqPict("CJ3","CJ3_VLISEN"),;
	TamSx3("CJ3_VLISEN")[1],;
	TamSX3("CJ3_VLISEN")[2],;
	"!Empty(GdFieldGet('F2D_TRIB',,.T.))  .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('CJ3_VLISEN',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_LF_ISENTO'},Val(GdFieldGet('ITEM',,.T.)))",;
	"",;
	"N",;
	"",;
	"R",;
	"",;
	"",;
	""})

	aAdd(aHdrTrbGen,;
	{"Outros",;
	"CJ3_VLOUTR",;
	PesqPict("CJ3","CJ3_VLOUTR"),;
	TamSx3("CJ3_VLOUTR")[1],;
	TamSX3("CJ3_VLOUTR")[2],;
	"!Empty(GdFieldGet('F2D_TRIB',,.T.))  .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('CJ3_VLOUTR',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_LF_OUTROS'},Val(GdFieldGet('ITEM',,.T.)))",;
	"",;
	"N",;
	"",;
	"R",;
	"",;
	"",;
	""})

	aAdd(aHdrTrbGen,;
	{"N�o Tributado",;
	"CJ3_VLNTRI",;
	PesqPict("CJ3","CJ3_VLNTRI"),;
	TamSx3("CJ3_VLNTRI")[1],;
	TamSX3("CJ3_VLNTRI")[2],;
	"!Empty(GdFieldGet('F2D_TRIB',,.T.))  .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('CJ3_VLNTRI',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_LF_NAO_TRIBUTADO'},Val(GdFieldGet('ITEM',,.T.)))",;
	"",;
	"N",;
	"",;
	"R",;
	"",;
	"",;
	""})

	aAdd(aHdrTrbGen,;
	{"Valor Diferido",;
	"CJ3_VLDIFE",;
	PesqPict("CJ3","CJ3_VLDIFE"),;
	TamSx3("CJ3_VLDIFE")[1],;
	TamSX3("CJ3_VLDIFE")[2],;
	"!Empty(GdFieldGet('F2D_TRIB',,.T.))  .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('CJ3_VLDIFE',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_LF_DIFERIDO'},Val(GdFieldGet('ITEM',,.T.)))",;
	"",;
	"N",;
	"",;
	"R",;
	"",;
	"",;
	""})

	aAdd(aHdrTrbGen,;
	{"Valor Majorado",;
	"CJ3_VLMAJO",;
	PesqPict("CJ3","CJ3_VLMAJO"),;
	TamSx3("CJ3_VLMAJO")[1],;
	TamSX3("CJ3_VLMAJO")[2],;
	"!Empty(GdFieldGet('F2D_TRIB',,.T.))  .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('CJ3_VLMAJO',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_LF_MAJORADO'},Val(GdFieldGet('ITEM',,.T.)))",;
	"",;
	"N",;
	"",;
	"R",;
	"",;
	"",;
	""})

EndIf

Return aHdrTrbGen

//-------------------------------------------------------------------
/*/{Protheus.doc} FisF2F

Funcao respons�vel por componentizar a grava��o da tabela F2F.

@param cOper      - Opera��o, indica se � inclus�o ou exclus�o do t�tulo
@param cIdNF      - ID de relacionamento com o documento fiscal, este ID � fundamental para vincular o t�tulo com a nota
@param cTabela    - Esta par�metro identifica a tabela de origem da movimenta��o que gerou este t�tulo
@param aTGCalcRec - Lista dos tributos gen�ricos calculados que dever�o ter t�tulos gerados.

@author joao.pellegrini
@since 08/10/2018
@version 11.80
/*/
//-------------------------------------------------------------------
Function FisF2F(cOper, cIdNF, cTabela, aTGCalcRec)

Local nX := 0
Local cChvF2F := ""

DEFAULT aTGCalcRec := {}

If AliasInDic("F2F") .And. !Empty(cIdNF)

	dbSelectArea("F2F")
	F2F->(dbSetOrder(1))

	// Inclusao
	If cOper == "I"

		For nX := 1 to Len(aTGCalcRec)
			// Verifico se tem ID FK7 gerado pelo financeiro, o que
			// significa que o t�tulo em quest�o foi gerado.
			If !Empty(aTGCalcRec[nX, 4])
				RecLock("F2F", .T.)
				F2F->F2F_FILIAL := xFilial("F2F")
				F2F->F2F_IDNF := cIdNF
				F2F->F2F_TABELA := cTabela
				F2F->F2F_IDFK7 := aTGCalcRec[nX, 4]
				F2F->F2F_IDF2B := aTGCalcRec[nX, 5]
				F2F->(MsUnlock())
			EndIf
		Next nX
 
	// Exclusao
	ElseIf cOper == "E"

		cChvF2F := xFilial("F2F") + cIdNF + cTabela

		If F2F->(MsSeek(cChvF2F))
			While !F2F->(EoF()) .And. F2F->(F2F_FILIAL + F2F_IDNF + F2F_TABELA) == cChvF2F
				RecLock("F2F",.F.)
				F2F->(dbDelete())
				MsUnLock()
				F2F->(FkCommit())
				F2F->(dbSkip())
			EndDo
		EndIf

	EndIf

	F2F->(dbCloseArea())

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FisTitTG

Fun��o respons�vel por retornar o n�mero do t�tulo de tributo gen�rico
a ser gerado.

@author joao.pellegrini
@since 08/10/2018
@version 11.80
/*/
//-------------------------------------------------------------------
Function FisTitTG()

Local cNumero := ""

If SX5->(dbSeek(xFilial("SX5")+"53"+"TG"))
	cNumero := "TG" + Soma1(Substr(X5Descri(),3,7),7)
	RecLock("SX5",.F.)
	SX5->X5_DESCRI  := cNumero
	SX5->X5_DESCSPA := cNumero
	SX5->X5_DESCENG := cNumero
	SX5->(MsUnlock())
EndIf

Return cNumero

//-------------------------------------------------------------------
/*/{Protheus.doc} FISFK7E1E2

Fun��o respons�vel por converter uma chave FK7 para uma chave de SE1/SE2.

@param cChaveFK7 - Chave Fk7 do t�tulo
@param cTabela   - Indica se dever� considerar SE1 ou SE2 no momento de converter a chave Fk7

@return cChvSE   - Chave do t�tulo j� convertida

@author joao.pellegrini
@since 10/10/2018
@version 11.80
/*/
//-------------------------------------------------------------------
Function FISFK7E1E2(cChaveFK7, cTabela)

Local aChvSE := {}
Local cChvSE := ""
Local aTamSE2 := {TamSX3("E2_FILIAL")[1], TamSX3("E2_PREFIXO")[1], TamSX3("E2_NUM")[1], TamSX3("E2_PARCELA")[1], TamSX3("E2_TIPO")[1], TamSX3("E2_FORNECE")[1], TamSX3("E2_LOJA")[1]}
Local aTamSE1 := {TamSX3("E1_FILIAL")[1], TamSX3("E1_PREFIXO")[1], TamSX3("E1_NUM")[1], TamSX3("E1_PARCELA")[1], TamSX3("E1_TIPO")[1], TamSX3("E1_CLIENTE")[1], TamSX3("E1_LOJA")[1]}

aChvSE := StrToKarr(cChaveFK7, "|")

If Len(aChvSE) >= 7

	cChvSE := (PadR(aChvSE[1], IIf(cTabela == "SE1", aTamSE1[1], aTamSE2[1])) +;
			   PadR(aChvSE[2], IIf(cTabela == "SE1", aTamSE1[2], aTamSE2[2])) +;
			   PadR(aChvSE[3], IIf(cTabela == "SE1", aTamSE1[3], aTamSE2[3])) +;
			   PadR(aChvSE[4], IIf(cTabela == "SE1", aTamSE1[4], aTamSE2[4])) +;
			   PadR(aChvSE[5], IIf(cTabela == "SE1", aTamSE1[5], aTamSE2[5])) +;
			   PadR(aChvSE[6], IIf(cTabela == "SE1", aTamSE1[6], aTamSE2[6])) +;
			   PadR(aChvSE[7], IIf(cTabela == "SE1", aTamSE1[7], aTamSE2[7])))

EndIf

Return cChvSE

//-------------------------------------------------------------------
/*/{Protheus.doc} FisDelTit

Fun��o respons�vel por retornar o n�mero do t�tulo de tributo gen�rico
a ser gerado.

@param cIdNF    - ID da nota fiscal que est� sendo exclu�da
@param cTabela  - Tabela de origem da movimenta��o que gerou o t�tulo
@param cOrigem  - Rotina que gerou o t�tulo
@param nOpcao   - Op��o para identificar tabela SE1 ou SE2
@param cNumTit  - N�mero do t�tulo a ser processado nesta fun��o

@return lRet  - Indica se o t�tulo pode ou n�o ser excluido. 

@author joao.pellegrini
@since 08/10/2018
@version 11.80
/*/
//-------------------------------------------------------------------
Function FisDelTit(cIdNF, cTabela, cOrigem, nOpcao, cNumTit)

Local lRet := .T.
Local cChvF2F := ""
Local cChvSE := ""
Local cMensagem	:= ""
Local aRecnoExcl := {}
Local nX := 0
Local aArea := GetArea()

Default cNumTit	:= ""

dbSelectarea("F2F")
F2F->(dbSetOrder(1))

dbSelectarea("FK7")
FK7->(dbSetOrder(1))

dbSelectarea("SE2")
SE2->(dbSetOrder(1))

dbSelectarea("SE1")
SE1->(dbSetOrder(1))

cChvF2F := xFilial("F2F") + cIdNF + cTabela

If !Empty(cIdNF) .And. F2F->(MsSeek(cChvF2F))

	// La�o na F2F para posicionar a FK7 com o campo F2F_IDFK7
	While !F2F->(Eof()) .And. F2F->(F2F_FILIAL + F2F_IDNF + F2F_TABELA) == cChvF2F

		cChvSE := ""
		cAlsSE := ""

		// Se encontrou na FK7 vou usar os campos FK7_ALIAS e FK7_CHAVE para chegar no t�tulo
		// gerado na SE1 ou SE2 conforme o caso.
		If FK7->(MsSeek(xFilial("FK7") + F2F->F2F_IDFK7))

			cAlsSE := FK7->FK7_ALIAS
			// Converte o conte�do do campo FK7_CHAVE para poder localizar a SE1/SE2.
			cChvSE := FISFK7E1E2(FK7->FK7_CHAVE, cAlsSE)

			// Verifica se h� algum t�tulo vinculado que n�o possa ser excluido pois sofreu algum tipo de baixa ou movimenta��o no financeiro.
			// Se houver paro o la�o e j� retorno .F. pois o documento em quest�o n�o pode ser exclu�do.
			If (cAlsSE)->(MsSeek(cChvSE))
				If nOpcao == 1
					If cAlsSE == "SE1"
						If !(lRet := FaCanDelCR("SE1", cOrigem, .F.))
							cNumTit := SE1->E1_NUM + "/" + SE1->E1_PREFIXO
						EndIF
					ElseIf cAlsSE == "SE2"
						IF !(lRet := FaCanDelCP("SE2", cOrigem, .F.))
							cNumTit := SE2->E2_NUM + "/" + SE2->E2_PREFIXO
						EndIF
					EndIf

					If !lRet
						cMensagem := "N�o Ser� poss�vel excluir o documento. Verifique o t�tulo " + cNumTit //
						Help(" ",1,"NAOEXCNF","NAOEXCNF",cMensagem,1,0,,,,,,{"Verifique a exist�ncia de border�s, baixas totais, parciais ou outras movimenta��es financeiras envolvendo este t�tulo."}) //
						Exit
					EndIf
				Else
					aAdd(aRecnoExcl, {cAlsSE, (cAlsSE)->(RecNo())})
				EndIf
			EndIf

		EndIf

		F2F->(dbSkip())

	EndDo

	// Exclus�o dos t�tulos...
	If lRet .And. nOpcao == 2
		For nX := 1 to Len(aRecnoExcl)
			If aRecnoExcl[nX, 1] == "SE1
				SE1->(dbGoTo(aRecnoExcl[nX, 2]))
				If FindFunction("FinGrvEx")
					FinGrvEx("R") // Gravar o hist�rico.
				EndIf
				RecLock("SE1",.F.)
				SE1->(dbDelete())
				FaAvalSE1(2)
				FaAvalSE1(3)
				MsUnLock()
			ElseIf aRecnoExcl[nX, 1] == "SE2
				SE2->(dbGoTo(aRecnoExcl[nX, 2]))
				If FindFunction("FinGrvEx")
					FinGrvEx("P") // Gravar o hist�rico.
				EndIf
				RecLock("SE2",.F.)
				SE2->(dbDelete())
				FaAvalSE2(2)
				FaAvalSE2(3)
				MsUnLock()
			EndIf
		Next nX
	EndIf

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FisRetGen

Fun��o que percorre-r� todos tributos gen�ricos verificando
se ele � pass�vel de reten��o

@param aTGCalc - Obt�m tributos gen�ricos calculados pelo motor Fiscal
@param aTGRet - Obt�m tributos gen�ricos pass�veis de reten��o
@param lFinFkk - Vari�vel que indica que a tabela Fkk do financeiro poder� ser utilizada
@param aTGCalcRet - Array para tributos pass�veis de reten��o
@param aTGCalcRec - Array para tributos de recolhimento
@param dEmissao - Data de emissao do Documento Fiscal

@author Renato Rezende
@since 28/11/2019
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function FisRetGen(aTGCalc,aTGRet,lFinFkk,aTGCalcRet,aTGCalcRec,dEmissao, cNumNf, cSerie)

Local cNumTitTG	:= ""
Local cHistRec	:= ""
Local nContTg	:= 0
Local LDESCMAJ 	:= .F. 
Default cNumNf	:= SF2->F2_DOC
Default cSerie	:= SF2->F2_SERIE

//Obt�m todos os tributos gen�ricos calculados pelo motor Fiscal
aTGCalc := MaFisRet(,"NF_TRIBGEN")

//Obt�m todos os tributos gen�ricos pass�veis de reten��o
aTGRet	:= xFisRetTG(dEmissao)

For nContTg := 1 to Len(aTGCalc)

	//procuro pelo tributo gen�rico calculado na lista dos tributos pass�veis de reten��o
	nPosTgRet	:=  AScan(aTGRet, { |x| Alltrim(x[1]) == Alltrim(aTGCalc[nContTg][1])})

	// Se o tributo consta na lista dos pass�veis de reten��o, adiciona no aTGCalcRet.
	// Caso contr�rio, trata-se de um recolhimento e os valores ser�o adicionados no aTGCalcRec.
	If nPosTgRet > 0
		If lFinFkk
			//Se o tributo est� previsto a ter reten��o, ent�o ser� adicionado no array aTGCalcRet para ser rateado entre as parcelas.
			aAdd(aTGCalcRet,{aTGCalc[nContTg][1],; //Sigla do Tributo
							aTGCalc[nContTg][2],;//Base de C�lculo Tributo
							aTGCalc[nContTg][3],;//Valor do Tributo
							aTGCalc[nContTg][4],;//C�digo da Regra FKK
							FinParcFKK(aTGCalc[nContTg][4]),;//Indica se retem integralmente na primeira parcela
							aTGCalc[nContTg][3],;//Saldo restante do tributo, � iniciado com o pr�prio valor do tributo
							aTGCalc[nContTg][2],;//Saldo restante da base de c�lculo, que � iniciado com o pr�prio valor do tributo
							aTGCalc[nContTg][5],;//ID da regra Fiscal da tabela F2B
							aTGCalc[nContTg][6],;//C�digo da URF
							aTGCalc[nContTg][7]})//Percentual aplic�vel ao valor da URF
		EndIf
	ElseIf !Empty(aTGCalc[nContTg][4])
		// Se o tributo n�o � uma reten��o, ou seja, � um recolhimento, adiciono no array aTGCalcRec para que os t�tulos
		// sejam gerados posteriormente.
		cNumTitTG := xFisTitTG()
		//TODO na onda 2 retirar a refer�ncia para F2_DOC e F2_SERIE, de forma que receba por par�metro estas informa��es
		cHistRec := AllTrim(aTGCalc[nContTg][1]) + " - NF: " + AllTrim(cNumNf) + " / " + AllTrim(cSerie)
		
		//Aqui verifico na regra de guia se deseja subtrair o valor majorado no momento de gerar guia e t�tulo.
		If AliasIndic("CJ4")
			lDesCMaj := !Empty(aTGCalc[nContTg][9]) .AND. CJ4->(MsSeek(xFilial("CJ4") + aTGCalc[nContTg][9] )) .AND. CJ4->CJ4_MODO == "1" .And. CJ4->CJ4_MAJSEP == "1"
		EndIF

		aAdd(aTGCalcRec, {aTGCalc[nContTg][4],; // C�digo da Regra FKK
						aTGCalc[nContTg][3] - Iif(lDesCMaj, aTGCalc[nContTg][10],0) ,; // Valor do tributo. Aqui pode ser subtra�do a parcela majorada se estiver configurado na regra de guia
						cNumTitTG,; // N�mero do t�tulo a ser gerado
						'',; // ID FK7 do t�tulo gerado -> S� usar como retorno.
						aTGCalc[nContTg][5],;//ID da regra Fiscal da tabela F2B
						cHistRec,; // Hist�rico para gravar no t�tulo
						aTGCalc[nContTg][1]}) //Sigla do Tributo
	EndIf

Next nContTg

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkTribLeg

Fun��o que verifica se algum tributo gen�rico com ID de tributo legado foi
calculado, e ter� como retorno booleano, indicando se existe ou n�o
tributo gen�rico calculado com ID de tribuo legado

@param aNFItem 		- Array com informa��es do aNfItem
@param nItem 		- N�mero do item a ser verificado
@param cIdtribLeg 	- ID do tributo que deseja verificar

@author Erick Dias
@since 03/12/2019
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function ChkTribLeg(aNFItem, nItem, cIdtribLeg)
Local nPosTrib	:= aScan(aNFItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[TG_IT_IDTRIB])�== Alltrim(cIdtribLeg)})
Return nPosTrib > 0 .AND. (aNFItem[nItem][IT_TRIBGEN][nPosTrib][TG_IT_VALOR]  > 0 .Or. aNfItem[nItem][IT_TRIBGEN][nPosTrib][TG_IT_VL_ZERO])

//-------------------------------------------------------------------
/*/{Protheus.doc} ListTribLeg

Fun��o que retorna lista dos tributos legados que est�o
previstos/contemplados nos tributos gen�ricos

@author Erick Dias
@since 04/12/2019
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function ListTrbLeg()

Local aTrib			:= {{TRIB_ID_AFRMM      , .F.},;
						{TRIB_ID_FABOV      , .F.},;
						{TRIB_ID_FACS       , .F.},;
						{TRIB_ID_FAMAD      , .F.},;
						{TRIB_ID_FASEMT     , .F.},;
						{TRIB_ID_FETHAB     , .F.},;
						{TRIB_ID_FUNDERSUL  , .F.},;
						{TRIB_ID_FUNDESA    , .F.},;
						{TRIB_ID_IMAMT      , .F.},;
						{TRIB_ID_SEST       , .F.},;
						{TRIB_ID_TPDP       , .F.},;
						{TRIB_ID_IPI	    , .F.},;
						{TRIB_ID_CIDE		, .F.},;
						{TRIB_ID_SENAR	    , .F.},;
						{TRIB_ID_CPRB	    , .F.},;
						{TRIB_ID_FEEF	    , .F.},;
						{TRIB_ID_FUNRUR	    , .F.},;
						{TRIB_ID_CSLL	    , .F.},;
						{TRIB_ID_PROTEG	    , .F.},;
						{TRIB_ID_FUMIPQ	    , .F.},;
						{TRIB_ID_INSS		, .F.},;
						{TRIB_ID_IR		    , .F.},;
						{TRIB_ID_II		    , .F.},;
						{TRIB_ID_PIS	    , .F.},;
						{TRIB_ID_COF	    , .F.},;
						{TRIB_ID_ISS	    , .F.},;
						{TRIB_ID_ICMS	    , .F.},;
						{TRIB_ID_PRES_ICMS  , .F.},;
						{TRIB_ID_PRES_ST    , .F.},;
						{TRIB_ID_PRODEPE    , .F.},;
						{TRIB_ID_PRES_CARGA , .F.},;
						{TRIB_ID_SECP15     , .F.},;
						{TRIB_ID_SECP20     , .F.},;
						{TRIB_ID_SECP25     , .F.},;
						{TRIB_ID_INSSPT     , .F.},;
						{TRIB_ID_DIFAL      , .F.},;
						{TRIB_ID_CMP        , .F.},;
						{TRIB_ID_ANTEC      , .F.},;
						{TRIB_ID_FECPIC     , .F.},;
						{TRIB_ID_FCPST      , .F.},;
						{TRIB_ID_FCPCMP     , .F.},;
						{TRIB_ID_COFRET     , .F.},;
						{TRIB_ID_COFST      , .F.},;						
						{TRIB_ID_PISRET     , .F.},;
						{TRIB_ID_PISST      , .F.},;							
						{TRIB_ID_ISSBI      , .F.},;
						{TRIB_ID_PISMAJ     , .F.},;
						{TRIB_ID_COFMAJ     , .F.},;
						{TRIB_ID_DEDUCAO    , .F.},;						
						{TRIB_ID_FRTAUT		, .F.},;
						{TRIB_ID_DZFICM		, .F.},;
						{TRIB_ID_DZFPIS		, .F.},;
						{TRIB_ID_DZFCOF		, .F.},;						
						{TRIB_ID_ESTICM		, .F.},;
						{TRIB_ID_ICMSST		, .F.},;
						{TRIB_ID_FRTEMB		, .F.},;
						{TRIB_ID_CRDOUT		, .F.};
						}

Return aTrib

//-------------------------------------------------------------------
/*/{Protheus.doc} ListTLegTG

Fun��o que retorna lista dos tributos legados que tamb�m
foram calculados na lista dos tributos gen�ricos

@param aNFItem 		- Array com informa��es do aNfItem
@param nItem 		- N�mero do item a ser verificado

@author Erick Dias
@since 04/12/2019
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function ListTLegTG(aNFItem, nItem)

Local nX			:= 0
Local aTrib			:= ListTrbLeg() //Obtem lista dos tributos legados que j� est� contemplados no configurador

//Percorre os tributos e atualiza as posi��es dos tributos gen�ricos que tem ID de tributos legado
For nX:= 1 to Len(aTrib)
	aTrib[nX][2]	:= ChkTribLeg(aNFItem, nItem, aTrib[nX][1])
Next nX

Return aTrib

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkCalcTLeg

Fun��o que retorna lista dos tributos legados que precisam ser recalculados
ap�s enquadramento/c�lculo dos tributos gen�ricos.

Esta fun��o receber� array com lista de tributos legados que tinha tributo gen�rico
calculado antes do c�lculo do tributo gen�rico, e tamb�m uma lsita de de tributos 
legados que tinha tributo gen�rico calculado depois do c�lculo do tributo gen�rico.

@param aTrbAntes 	- Lista dos tributos legado que tinha tributo gen�rico calculado antes do c�lculo do TG
@param aTrbDepois	- Lista dos tributos legado que tinha tributo gen�rico calculado depois do c�lculo do TG

@author Erick Dias
@since 04/12/2019
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function ChkCalcTLeg(aTrbAntes, aTrbDepois)

Local nX			:= 0
Local aTrib			:= ListTrbLeg()

//Verifico primeiro se os arrays est�o com tamanhos corretos, todos precisam ter a mesma dimens�o e quantidade
If Len(aTrib) == Len(aTrbAntes) .AND. Len(aTrib) == Len(aTrbDepois) 

	//Uma vez garantido que os arrays possuem o mesmo tamanho percorro o aTrib
	For nX:= 1 to Len(aTrib)
		
		//Verifico se o tributo legado foi calculado em algum tribugo gen�rico antes ou se o tributo legado foi calculado agora em algum tribugo gen�rico
		//Em abos os casos indico que o tributo legado precisa ser recalculado, seja para ser zerado e evitando a duplicidade, ou seja devido o motivo
		//de desemquadrar algum tributo gen�rico e refazer o tributo legado
		IF aTrbAntes[nX][2] .OR. aTrbDepois[nX][2]
			aTrib[nX][2]	:= .T.
		EndIF

	Next nX

EndIF

Return aTrib

//-------------------------------------------------------------------
/*/{Protheus.doc} FisTgArred

Fun��o que far� tratamento do arredondamento dos valores dos tributos gen�ricos.
Esta fun��o foi constru�da com base na fun��o MaItArred, seguindo a mesma linha de
racioc�nio, por�m escalando para N tributos gen�ricos.
Esta fun��o ser� chamada no final da MaItArred, ela foi criada para separar os fontes
do configurador e n�o onerar o tamanho da MATXFIS.

@param aNFCab 	- Array com informa��es do cabe�alho da nota
@param aNfItem	- Array com informa��es do item da nota
@param aSX6	    - Array com informa��es dos par�metros
@param aTGITRef	- Arrays com as refer�ncias dos tributos gen�ricos 
@param aRefs	- Array com os campos espec�ficos que foram solicitados para serem arredondados na chamada da MaItArred
@param nDec	    - N�mero da precis�o de decimal, no caso do Brasil � com dias casas decimais
@param nx	    - N�mero do item posicionado
@param lSobra	- INdica se o sistema est� configurado para controlar a Sobra(MV_SOBRA)

@author Erick Dias
@since 04/12/2019
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function FisTgArred(aNFCab, aNfItem, aSX6, aTGITRef, aRefs, nDec, nx, lSobra)

Local nZ			:= 0
Local nY			:= 0
Local nTrbGen		:= 0
Local nPosTribTg 	:= 0
Local nCampoTG		:= 0
Local nUmCentavo 	:= 0
Local nMeioCentavo 	:= 0
Local nPosTgDel		:= 0
Local nValor		:= 0		
Local nRndPrec		:= 0
Local nDifItem		:= 0
Local nDifItDel		:= 0

//Vari�veis abaixo para facilitar a leitura do c�digo
nUmCentavo		:= (1/10**nDec) //Corresponde a 1 centavo
nMeioCentavo	:= (50/(10**(nDec + 2))) //Corresponde a meio centavo
nRndPrec  		:= IIf( aSX6[MV_RNDPREC] < 3 , 10 , aSX6[MV_RNDPREC] ) // Precisao para o arredondamento

//Percorre lista dos tributos enquadrados e calculados
For nTrbGen:= 1 to Len(aNfItem[nx][IT_TRIBGEN])

	//Neste la�o percorro os campos do tributo gen�rico(Base, Al�quota, Valor) que est�o com flag para tratar arredondamento e sobra
	For nY:= 1 to Len(aTGITRef)

		If aRefs == Nil .Or. aScan( aRefs, aTGITRef[nY][1] ) <> 0

			If lSobra
				//La�o nos itens procurando itens deletados
				For nZ := 1 To Len(aNfItem)
					
					//Verifica se o item est� deletado
					If aNfItem[nZ][IT_DELETED]
	
						//Verifica se no item deletado existe este tributo calculado
						If (nPosTgDel	:= aScan(aNfItem[nZ][IT_TRIBGEN], {|x| Alltrim(x[2])�== Alltrim(aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_SIGLA])})) > 0

							If aNfItem[nZ][IT_TRIBGEN][nPosTgDel][TG_IT_ITEMDEC][1][nY] > 0
								nDifItDel += aNfItem[nZ][IT_TRIBGEN][nPosTgDel][TG_IT_ITEMDEC][1][nY]
								nDifItDel -= nUmCentavo
							Else								
								nDifItDel += aNfItem[nZ][IT_TRIBGEN][nPosTgDel][TG_IT_ITEMDEC][2][nY]
							EndIf

						EndIF						

					EndIf
				Next nZ
			EndIF

			//Verifica se este campo deve fazer tratamento de arredondamento e sobra
			If aTGITRef[nY][4]

				//Zerando variave que controla sobra ap�s a terceira casa decimal
				nDifItem	:= 0 
				
				//Obtem a posi��o do campo que ser� processado
				nCampoTG	:= aTGITRef[nY][2]
				
				//Obtem o valor bruto calculado, com todas as decimais e sobras
				nValor := aNfItem[nX][IT_TRIBGEN][nTrbGen][nCampoTG]

				//Verifica se existe valor do tributo para ser processado 
				If nValor <> 0
					
					While Int(nValor) <> Int(NoRound(NoRound(nValor,nRndPrec),nDec,nDifItem,10)) .And. nRndPrec > 2
						nRndPrec -= 1
					Enddo

					//Trunca o valor e guarda a diferen�a a partir da segunda casa decimal na vari�vel nDifItem
					aNfItem[nX][IT_TRIBGEN][nTrbGen][nCampoTG]  := NoRound(NoRound(nValor,nRndPrec),nDec,@nDifItem,10)
					
					//Verifica se existe valor a partir da terceira casa decimal, ou seja, se existe algum valor de sobra					
					If nDifItem <> 0 .AND. ;
					(nPosTribTg	:= aScan(aNFCab[NF_SAVEDEC_TG], {|x| Alltrim(x[1])�== Alltrim(aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_SIGLA])})) > 0 //Aqui verifico e busco posi��o do tributo no SaveDec que est� no aNfCab
					
						//Acumulo no SaveDec o valor do ItemDec [1]
						aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] += aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY]

						//Agora posso zerar o ItemDec [1], pois j� teve seu valor acumulado no SaveDec
						aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY]	:= 0
												
						//-----------------------------------------------------------
						//Verifica se o tributo n�o est� configurado para arredondar
						//-----------------------------------------------------------
						If !aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_RND]
							//Aqui o tributo n�o est� configurado para arredondars							
							
							aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] 			-= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY]
							aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY] 	:= nDifItem
							aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG]			+= nDifItem

							//Verifica se controla a sobra e se o valor da sobra acumulado � suficiente para descarregar no item
							If lSobra .And. ( aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] - nDifItDel ) >= nMeioCentavo
							
								aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY] 	:= nUmCentavo - nDifItem 
								aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY] 	:= 0								
								//Atualiza o SaveDec retirando 1 centavo, pois logo abaixo ser� adicionado 1 centavo no valor
								aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG]			-= nUmCentavo								
								//Aqui adiciona 1 centavo no tributo, pois j� acumulou sobra suficiente
								aNfItem[nX][IT_TRIBGEN][nTrbGen][nCampoTG] 				+= nUmCentavo

							EndIF

						//----------------------------------------------------------------------------------------------------------------------
						//Verifica se o tributo est� configurado para arredondar, se existe valor de sobra e se o valor do tributo foi calculado
						//----------------------------------------------------------------------------------------------------------------------
						ElseIF aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_RND] .And. nDifItem > 0 .And. aNfItem[nX][IT_TRIBGEN][nTrbGen][nCampoTG] > 0
							//Aqui o tributo est� configurado para arredondar							
							aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] 			-= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY]
							aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY] 	:= nDifItem
							aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG]			+= nDifItem
							
							//Verifica se controla a sobra e se o valor da sobra acumulado � suficiente para descarregar no item
							
							If ( aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] - nDifItDel ) >= nMeioCentavo						 						
								
								aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY] 	:= nUmCentavo - nDifItem 
								aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY] 	:= 0
								
								//Atualiza o SaveDec retirando 1 centavo, pois logo abaixo ser� adicionado 1 centavo no valor
								aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG]			-= nUmCentavo
								
								//Aqui adiciona 1 centavo no tributo, pois j� acumulou sobra suficiente
								aNfItem[nX][IT_TRIBGEN][nTrbGen][nCampoTG] 				+= nUmCentavo

							EndIf

						EndIF

						//Caso o controle de sobra esteja desabilitado, o savedec e itemdec ser�o zerados
						If !lSobra
							aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY]	:= 0
							aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY]	:= 0
							aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] 			:= 0
						Endif
					
					EndIF					

				EndIF

			EndIf
		EndIF
	Next nY

Next nTrbGen

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TGAjuArred

Fun��o que far� tratamento do arredondamento dos valores dos tributos gen�ricos.
Esta fun��o foi constru�da com base na fun��o MaItArred, seguindo a mesma linha de
racioc�nio, por�m escalando para N tributos gen�ricos.
Esta fun��o ser� chamada no final da MaItArred, ela foi criada para separar os fontes
do configurador e n�o onerar o tamanho da MATXFIS.

@param aNFCab 	- Array com informa��es do cabe�alho da nota
@param aNfItem	- Array com informa��es do item da nota
@param aTGITRef	- Arrays com as refer�ncias dos tributos gen�ricos 
@param nx	    - N�mero do item posicionado
@param cCampo	- Refer�ncia a ser atualizada

@author Erick Dias
@since 04/12/2019
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function TGAjuArred(aNFCab, aNfItem, aTGITRef, nx, cCampo)

Local nTrbGen		:= 0
Local nPosTribTg	:= 0
Local nY			:= 0
Local nCampoTG		:= 0

//Percorre lista dos tributos enquadrados e calculados para realizar corre��es de arredondamento
For nTrbGen:= 1 to Len(aNfItem[nx][IT_TRIBGEN])

	//Aqui verifico e busco posi��o do tributo no SaveDec que est� no aNfCab
	nPosTribTg	:= aScan(aNFCab[NF_SAVEDEC_TG], {|x| Alltrim(x[1])�== Alltrim(aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_SIGLA])})
	
	If nPosTribTg > 0

		//Rodo os campos de base, al�quota e valor do tributo gen�rico
		For nY:= 1 to Len(aTGITRef)
			
			//Verifica se o campo faz controle de arredondamento
			If aTGITRef[nY][4]
				
				nCampoTG	:= aTGITRef[nY][2]

				//Aqui verifica se o tributo est� configurador para truncar
				If !aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_RND]
						
					aNfItem[nX][IT_TRIBGEN][nTrbGen][nCampoTG] += aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY]
					aNfItem[nX][IT_TRIBGEN][nTrbGen][nCampoTG] -= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY]
					
					aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] += aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY]
					aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] -= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY]					

				Else
					//Aqui verifica se o tributo est� configurado para arredondar
					aNfItem[nX][IT_TRIBGEN][nTrbGen][nCampoTG] += aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY]
					aNfItem[nX][IT_TRIBGEN][nTrbGen][nCampoTG] -= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY]

					If !(!Empty(cCampo) .And. cCampo == aTGITRef[nY][1])
						aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] += aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY]
						aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] -= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY]
					EndIf

				EndiF
				aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY]:= 0
				aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY]:= 0

			EndIF

		NExt nY

	EndIF

Next nTrbGen

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TgSaveDec

Fun��o que adiciona-r� uma nova posi��o para controle do SaveDec do tributo gen�rico,
caso o tributo n�o conste no Array.

@param aNFCab 		- Array com informa��es do cabe�alho da nota
@param aNfItem		- Array com informa��es do item da nota
@param nItem		- N�mero do item posicionado
@param nTrbGen		- N�mero do tributo gen�rico posicionado

@author Erick Dias
@since 09/12/2019
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function TgSaveDec(aNFCab, aNfItem, nItem, nTrbGen)

//--------------------------------------------------------------------
//Adiciono nova posi��o para controle do SaveDec do tributo gen�rico
//--------------------------------------------------------------------
//Preciso verificar se o tributo j� consta no array do SaveDec, se j� existe n�o precisa adicionar, se n�o existe ai ser� criado.
If aScan(aNFCab[NF_SAVEDEC_TG], {|x| Alltrim(x[1])�== Alltrim(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_SIGLA])}) == 0
	aadd(aNFCab[NF_SAVEDEC_TG],{aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_SIGLA], Array(NMAX_IT_TG)})
	aFill(aNFCab[NF_SAVEDEC_TG] [Len(aNFCab[NF_SAVEDEC_TG])][2],0)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisExecNPI

Fun��o que processa a f�rmula NPI, e retorna o valor da f�rmula 
conforme a f�rmula enviada para esta fun��o.

Aqui apenas ser� executado a f�rmula, n�o ter� valida��o de sintaxe

Se por algu motivo o operando n�o for encontrado, n�o existir o valor 
padr�o ser� zero.

@param cFormula - F�rmula NPI a ser processada
@param aNFItem - Array com todas as informa��es do item
@param nItem - N�mero do item processado
@param aMapForm - Objeto hashmap com mapeamento dos operandos e f�rmulas

@return - valor obtido atrav�s da f�rmula indicada

@author Erick Dias
@since 17/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function xFisExecNPI(cFormula, aNFItem, nItem, aMapForm, lEdicao, lMemo, nPosTrbProc, cDetTrbPri, aNfCab)

Local nResultado	:= 0
Local nCont			:= 0
Local nContPilha	:= 0
Local nTrbGen		:= 0
Local nBaseOri		:= 0
Local aFormula		:= {}
Local aPilha		:= {}
Local cTributo		:= ""
Local cFormTemp		:= ""
Local cDetTrib		:= ""
Local cRet			:= ""

Default lEdicao := .F.
Default lMemo 	:= .F.
Default cDetTrbPri := ""

//Converte em array a f�rmula para falicitar a itera��o
aFormula	:= StrTokArr(alltrim(cFormula)," ")

//-------------------------------------------------
//La�o para percorrer todos os elementos da f�rmula
//-------------------------------------------------
 For nCont := 1 to len( aFormula )	
	
	//--------------------------
	//Verifica se � um operador
	//--------------------------
	If aFormula[nCont] $ "+-*/"
		
		//-----------------------------------------------------------------------------------
		//Se for operador ent�o far� o c�lculo com os dois �ltimos operandos do topo da pilha
		//Pega o tamanho da pilha		
		//Prote��o caso a pilha n�o tenha elementos suficiente para executar e n�o ocasionar error log
		//------------------------------------------------------------------------------------
		IF (nContPilha	:= Len( aPilha )) > 1
		
			//----------------------------------------------------------------
			//Realiza o c�lculo considerndo os dois operandos do topo da pilha
			//----------------------------------------------------------------
			Do Case
				Case aFormula[nCont] == '/'
					nResultado	:= 	aPilha[nContPilha-1] / aPilha[nContPilha]
					
				Case aFormula[nCont] == '*'
					nResultado	:= 	aPilha[nContPilha-1] * aPilha[nContPilha]
					
				Case aFormula[nCont] == '+'
					nResultado	:= 	aPilha[nContPilha-1] + aPilha[nContPilha]
					
				Case aFormula[nCont] == '-'
					nResultado	:= 	aPilha[nContPilha-1] - aPilha[nContPilha]
			EndCase
			
			//------------------------------------------------
			//Remove do Array os dois �ltimos operandos (POP)
			//------------------------------------------------
			ASize( aPilha, nContPilha - 2 ) 			
			
			//---------------------------------------------
			//Adiciona o resultado no topo da pilha (PUSH)
			//---------------------------------------------
			aadd( aPilha, nResultado )	
		
		EndiF
		
	Else			
		cTributo		:= ""
		cFormTemp		:= ""
		cDetTrib		:= ""
		cRet			:= ""
		nResultado		:= 0
		
		//Para os operandos de tributos preciso verificar se o tributo foi enquadrado antes de prosseguir
		If IsOperTrib(aFormula[nCont])
			//Regra do tributo, preciso buscar no aNfItem
			//Busca posi��o no aNfItem			
			cTributo	:= GetTribOper(aFormula[nCont])
		
			//Obtem o n�mero do item no aNfItem
			IF (nTrbGen 	:= GetPosTrib(cTributo , aNfItem, nItem)) > 0 .And. FindOper(aMapForm, aFormula[nCont], @cFormTemp)
				//Aqui estou chamando a fun��o de forma recursiva para resolver o operando composto.
				//Se o opernado contidos na f�rmula aqui for T_, ent�o buscarei da refer�ncia ao inv�s de recalcular....
				
				//Obtenho o detalhe do opernado, se � base, al�quota ou valor.
				cDetTrib	:= Left(aFormula[nCont],3)

				//Se for edi��o e memoize ent�o busco valor j� calculado na refer�ncia
				If lEdicao .And. lMemo 
					//Devo buscar o valor
					nResultado	:= RetValTrib(cDetTrib, aNFItem,nItem,nTrbGen)					
				Else
					
					//Verifica se f�rmula possuir operando MAIOR ou MENOR para ser executado.
					If "MAIOR" $ cFormTemp .Or. "MENOR" $ cFormTemp
						If "MAIOR" $ cFormTemp
							//Chama fun��o que verifica qual operando possui maior valor, e retorna operando a seguir
							cRet := ExecMaxMin(cFormTemp, aNFItem, nItem, aMapForm, nTrbGen, cDetTrib, aNfCab, "MAIOR" )
						Else
							//Chama fun��o que verifica qual operando possui menor valor, e retorna operando a seguir
							cRet := ExecMaxMin(cFormTemp, aNFItem, nItem, aMapForm, nTrbGen, cDetTrib, aNfCab, "MENOR")
						EndIf

						//Se fun��o retorno operando, ent�o cFormTemp ser� substitu�do se seguir� fluxo com menor operando
						If !Empty(cRet)
							cFormTemp := cRet
						EndIF
					EndIF
					
					//Atribuir o valor, ou base ou al�quota para refer�ncia correspondente e, chamar MaItArred().					

					//Devo calcular o valor
					nResultado	:= xFisExecNPI(cFormTemp, aNFItem, nItem, aMapForm, lEdicao, lEdicao, nTrbGen, cDetTrib, aNfCab)

					//Verifico qual refer�ncia devo atualizar do tributo dependente
					If cDetTrib == "BAS"
						
						//Atualiza a refer�ncia da base de c�lculo
						aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE] := nResultado						

						//Faz arredondamento  da base de c�lculo dos tributos gen�ricos
						MaItArred(nItem, { "TG_IT_BASE" } )

						nResultado	:= aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE]

						Conout(cTributo + " " +  cDetTrib + " TG_IT_BASE")

						//Verifico se tem redu��o de base de c�lculo
						IF aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_REDUCAO] > 0

							//Aqui indico que a base de c�lculo ser� refeita sem a redu��o
							LSEMREDUCAO	:= .T.						

							//Efetuo novamente o c�lculo para obter a base de c�lculo original
							nBaseOri:= xFisExecNPI(cFormTemp, aNFItem, nItem, aMapForm, lEdicao, lEdicao, nTrbGen, cDetTrib, aNfCab)

							//Preencho a refer�ncia do livro com base de c�lculo Original
							ProcEscrTG(aNfItem, nItem, nTrbGen, "", 0, ;
										0, 0, 0, 0, 0, ;
										0, 0, 0, 0, 0, ;
										0, 0, "", nBaseOri)
							
							//Aqui retorno o flag para op��o de c�lculo normal
							LSEMREDUCAO	:= .F.
							nBaseOri	:= 0
						
						EndIF

						//TODO 
						/*
						Verificar se base de c�lculo possui redu��o de base de c�lculo
						se ter, precisaremos obter o valor da base de c�lculo antes de aplicar a redu��o
						executaremos novamente a execu��o da base de c�lculo, mas desta vez sem o percentual de redu��o.
						*/
						

					ElseIF cDetTrib == "ALQ"
						//Atualiza a refer�ncia da base de al�quota
						aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA] := nResultado

						//Faz arredondamento  da base de c�lculo dos tributos gen�ricos
						MaItArred(nItem, { "TG_IT_ALIQUOTA" } )

						nResultado	:= aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA]

						IF aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_TPALIQ] <> '2' .AND.  EMPTY(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_CODURF])
							//Se o pr�ximo operando for de soma ou subtra��o, n�o poderei dividir por 100, estar� somando al�quota.
							IF nCont + 1 <= len(aFormula) .And. !aFormula[nCont+1] $ "+-"
								nResultado := nResultado / 100
							EndIf
						Endif

						Conout(cTributo + " " + cDetTrib + " TG_IT_ALIQUOTA")

					ElseIF cDetTrib == "VAL"
						
						nResultado	:= VlrLimite(aNFItem, nItem, nTrbGen, nResultado, nPosTrbProc, cDetTrbPri, aNfCab)

						//Atualiza a refer�ncia do valor
						aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR] := nResultado						

						MaItArred(nItem, { "TG_IT_VALOR" } )
						
						nResultado	:= aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]

						//Aqui chamo fun��o para execu��o das regras de escritura��o do livro dos tributos gen�ricos, caso possua uma regra vinculada ao tributo
						FisLivroTG(aNfItem, nItem, nTrbGen, aNfCab, aMapForm, lEdicao)
						 
						Conout(cTributo +  " " + cDetTrib + " TG_IT_VALOR")
					EndIF

					
				EndIF
			EndIF

		Else
			//Aqui executarei o operando para obter o valor de retorno
			nResultado	:= NPIxREF(aFormula[nCont], aNFItem, nItem, aMapForm, lEdicao, nPosTrbProc, cDetTrbPri, aNfCab)

			//--------------------------------------------------------------------------
			//Verifica se aFormula[nCont] � dedu��o por participante, ent�o atualizerei
			//--------------------------------------------------------------------------
			IF aFormula[nCont] == PINDCALC + "DED_DEPENDENTES" .AND. Len(aPilha) >= 1 .and. Valtype(aPilha[1]) == "N"
				//-------------------------------------------------
				//Verifico se tem valor a deduzir por participante
				//-------------------------------------------------
				//Se a base de c�lculo for maior que o valor de dedu��o, ent�o ser� utilizada integralmente
				If aPilha[1] > nResultado
					//Pode seguir normalemnte e atribuir� na refer�ncia
					aNFItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_DED_DEP]	:= nResultado
				Else
					//Se o valor de dedu��o for maior que a base, entao a base ser� zerada e a dedu��o ser� o pr�prio valor da base
					nResultado := aPilha[1]
					aNFItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_DED_DEP]	:= nResultado
				EndIF
			
			EndIF

		EndIF
		aadd(aPilha, nResultado )
					
	EndIF
	
Next nCont

aFormula	:= nil
aPilha		:= nil

Return Max(0,nResultado) //Por padr�o n�o poder� ter valores negativos.

//-------------------------------------------------------------------
/*/{Protheus.doc} NPIxREF

Fun��o que realiza o de - para dos valores de operandos da f�rmula com a
referencia correspondente.
Verifica se operando � composto e executa a f�rmula dos pr�ximos n�veis tamb�m

@param cOperando - Operndo da f�rmula
@param aNFItem - Array com todas as informa��es do item
@param nItem - N�mero do item processado
@param cTpOperando - Tipo de opera��o: 1 - base 2 - Aliquota 3 - Tributo 4 - URF 5 - Operadores prim�rios

@return valor do operando.

@author Erick Dias
@since 17/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function NPIxREF(cOperando, aNFItem, nItem,aMapForm, lEdicao, nPosTrbProc, cDetTrbPri, aNfCab)

Local nRet 			:= 0
Local cFormTemp 	:= ""
Default lEdicao 	:= .F.

//Se operando estiver vazio retorno 0
If Empty(cOperando)
	Return nRet
EndIf

// Se o primeiro d�gito for n�mero, significa que n�o � f�rmula e sim valor fixo, ent�o j� retorno o valor diretamente
If IsDigit(cOperando)	
	nRet	:= Val(StrTran(cOperando, ",", "."))

//Aqui trata-se de um operando cadastrado na CIN, � u operando composto, por este motivo preciso chamar a fun��o recursivamente para obter o valor
//Busco a f�rmula no hashmap
//Verifica se a f�rmula do operando foi encontrado no hashmap antes de continuar
ElseIf IsOperComposto(cOperando) .Or. IsOperTrib(cOperando)
	If FindOper(aMapForm, cOperando, @cFormTemp)
		//Aqui estou chamando a fun��o de forma recursiva para resolver o operando composto.
		nRet	:= xFisExecNPI(cFormTemp, aNFItem, nItem, aMapForm, lEdicao,, nPosTrbProc, cDetTrbPri, aNfCab)
	EndIF	

Else
	//Retorna o valor correspondente dos Operadores Prim�rios
	nRet := ValOperPri(cOperando, aNFItem, nItem, nPosTrbProc, cDetTrbPri, aNfCab)	

EndIF

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValOperPri

Fun��o que recebe operando prim�rio e retorna seu respectivo valor
contino no aNfItem

@param cOperando   - Operando que ser� procurado na CIN
@param aNFItem     - Array com todas as informa��es dos intens
@param nItem       - N�mero do item processado

@return - nRet - Valor do operando solicitadp

@author Erick Dias
@since 19/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------\
Static Function ValOperPri(cOperando, aNFItem, nItem, nPosTrbProc, cDetTrbPri, aNfCab )

Local nRet	:= 0
Local nPos 	:= 0
Local nVal	:= 0
Local nPosUltAqui	:= 0
Local nPosUltAqEstr := 0
Local cUmMed	:= aNFItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_BAS][TG_BAS_UM]

//Primeiro verifico se � operando primario/valor de origem
If SubString(cOperando,1,2) == xFisTpForm("0") 
	//--------------------------------------------------------------------------------------------
	//Abaixo fa�o o de-para dos operandos prim�rios com as referencias correspondentes da MATXFIS
	//--------------------------------------------------------------------------------------------
	If cOperando ==  PVALORI + "VAL_MERCADORIA"
		nRet	:= aNFItem[nItem][IT_VALMERC]

	ElseIf cOperando == PVALORI + "QUANTIDADE"
		//Obtenho a quantidade utilizando fun��o auxiliar, que analisar� se na regra foi especificada alguma unidade de medida				
		nRet := GetQtdItem(aNFItem, nItem, cUmMed)

	ElseIf cOperando == PVALORI + "VAL_CONTABIL"
		nRet	:= aNfItem[nItem][IT_LIVRO][LF_VALCONT]

	ElseIf cOperando == PVALORI + "VAL_CRED_PRESU"
		nRet	:= aNfItem[nItem][IT_LIVRO][LF_CRDPRES]

	ElseIf cOperando == PVALORI + "BASE_ICMS"
		nRet	:= aNfItem[nItem][IT_BASEICM]

	ElseIf cOperando == PVALORI + "BASE_ORIG_ICMS"
		nRet	:= aNfItem[nItem][IT_BICMORI]

	ElseIf cOperando == PVALORI + "VAL_ICMS"
		nRet	:= aNfItem[nItem][IT_VALICM]

	ElseIf cOperando == PVALORI + "FRETE"
		nRet	:= aNfItem[nItem][IT_FRETE]

	ElseIf cOperando == PVALORI + "VAL_DUPLICATA"
		nRet	:= aNfItem[nItem][IT_BASEDUP]

	ElseIf cOperando == PVALORI + "TOTAL_ITEM"
		nRet	:= aNfItem[nItem][IT_TOTAL]

	ElseIf cOperando == PVALORI + "ALQ_ICMS" .AND. aNfItem[nItem][IT_BASEICM] > 0
		nRet	:= aNfItem[nItem][IT_ALIQICM]

	ElseIf cOperando == PVALORI + "ALQ_CREDPRESU" .AND. aNfItem[nItem,IT_LIVRO,LF_CRDPRES] > 0
		nRet	:= aNFItem[nItem][IT_TS][TS_CRDPRES]

	ElseIf cOperando == PVALORI + "ALQ_ICMSST" .AND. aNfItem[nItem][IT_BASESOL] > 0
		nRet	:= aNFItem[nItem][IT_ALIQSOL]

	ElseIf cOperando == PVALORI + "DESCONTO"
		nRet	:= (aNfItem[nItem][IT_DESCONTO] + aNfItem[nItem][IT_DESCTOT])

	ElseIf cOperando == PVALORI + "SEGURO"
		nRet	:= aNfItem[nItem][IT_SEGURO]

	ElseIf cOperando == PVALORI + "DESPESAS"
		nRet	:= aNfItem[nItem][IT_DESPESA]

	ElseIf cOperando == PVALORI + "ICMS_DESONERADO"
		nRet	:= aNfItem[nItem][IT_DEDICM]

	ElseIf cOperando == PVALORI + "ICMS_RETIDO"
		nRet	:= aNfItem[nItem][IT_VALSOL]
	
	ElseIf cOperando == PVALORI + "DEDUCAO_SUBEMPREITADA"
		nRet	:= aNfItem[nItem][IT_ABVLISS]

	ElseIf cOperando == PVALORI + "DEDUCAO_MATERIAIS"
		nRet	:= aNfItem[nItem][IT_ABMATISS]

	ElseIf cOperando == PVALORI + "DEDUCAO_INSS_SUB"
		nRet	:= aNfItem[nItem][IT_ABSCINS]

	ElseIf cOperando == PVALORI + "DEDUCAO_INSS"
		nRet	:= aNfItem[nItem][IT_ABVLINSS]
	
	ElseIf cOperando == PVALORI + "BASE_IPI_TRANSFERENCIA"
		nRet	:= aNfItem[nItem][IT_PRCCF]
	
	ElseIf cOperando == PVALORI + "VAL_MANUAL_MAX"
		nRet 	:= aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_VL_MAX]

	ElseIf cOperando == PVALORI + "VAL_MANUAL_MIN"
		nRet 	:= aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_VL_MIN]
	
	ElseIf cOperando == PVALORI + "ALQ_SIMPLES_NACIONAL_ISS"
		If Len(aNfCab[NF_ALIQSN])>0
			If !Empty(AllTrim(aNfItem[nItem][IT_PRD][SB_B1GRUPO]))
				nPos := aScan(aNfCab[NF_ALIQSN], {|x| AllTrim(x[SN_GRUPO]) == AllTrim(aNfItem[nItem][IT_PRD][SB_B1GRUPO])})

			ElseIf !Empty(AllTrim(aNfItem[nItem][IT_CODISS]))
				nPos := aScan(aNfCab[NF_ALIQSN], {|x| AllTrim(x[SN_CODISS]) == AllTrim(aNfItem[nItem][IT_CODISS])})

			EndIf
			If nPos > 0
				nRet := aNfCab[NF_ALIQSN][nPos][SN_ALIQ]
			EndIf
		EndIf

	ElseIf cOperando == PVALORI + "ALQ_SIMPLES_NACIONAL_ICMS"
		If Len(aNfCab[NF_ALIQSN])>0 .And. !Empty(AllTrim(aNfItem[nItem][IT_CF]))
			nPos := aScan(aNfCab[NF_ALIQSN], {|x| AllTrim(x[SN_CFOP]) == AllTrim(aNfItem[nItem][IT_CF])})

			If nPos > 0
				nRet := aNfCab[NF_ALIQSN][nPos][SN_ALIQ]
			EndIf
		EndIf

	ElseIf cOperando == PVALORI + "CUSTO_ULT_AQUI"
		
		//Posiciona a �ltima aquisi��o para obter o valor do custo
		If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
			//(cAliasQry)->D1_CUSTO,		#02
			nRet	:= aPesqSD1[nPosUltAqui][2]
		EndIF

	ElseIf cOperando == PVALORI + "DESCONTO_ULT_AQUI"
		
		//Posiciona a �ltima aquisi��o para obter o valor do custo
		If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
			//(cAliasQry)->D1_VALDESC,	#03
			nRet	:=  aPesqSD1[nPosUltAqui][3]
		EndIF

	ElseIf cOperando == PVALORI + "MVA_ULT_AQUI"
		
		//Posiciona a �ltima aquisi��o para obter o valor do custo
		If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
			//(cAliasQry)->D1_MARGEM,  	#04
			nRet	:= 1 + (aPesqSD1[nPosUltAqui][4]/ 100)
		EndIF

	ElseIf cOperando == PVALORI + "QUANTIDADE_ULT_AQUI"

		//Posiciona a �ltima aquisi��o para obter o valor do custo
		If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
			//(cAliasQry)->D1_QUANT,		#05
			nRet	:= aPesqSD1[nPosUltAqui][5]
			//Atualiza a refer�ncia
			aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_ULT_AQUI] := .T.
		EndIF

	ElseIf cOperando == PVALORI + "VLR_UNITARIO_ULT_AQUI"
		
		//Posiciona a �ltima aquisi��o para obter o valor do custo
		If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
			//(cAliasQry)->D1_VUNIT,  	#06
			nRet	:= aPesqSD1[nPosUltAqui][6]
		EndIF
	ElseIf cOperando == PVALORI + "VLR_ANTECIPACAO_ULT_AQUI"
		
		//Posiciona a �ltima aquisi��o para obter o valor do custo
		If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
			//(cAliasQry)->D1_VALANTI, 	#07
			nRet	:= aPesqSD1[nPosUltAqui][7]
		EndIF
	ElseIf cOperando == PVALORI + "ICMS_ULT_AQUI"
		
		//Posiciona a �ltima aquisi��o para obter o valor do custo
		If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
			//(cAliasQry)->D1_VALICM,  	#08
			nRet	:= aPesqSD1[nPosUltAqui][8]
			//Atualiza a refer�ncia
			aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_ULT_AQUI] := .T.
		EndIF
	ElseIf cOperando == PVALORI + "IND_AUXILIAR_FECP_ULT_AQUI"
		
		//Posiciona a �ltima aquisi��o para obter o valor do custo
		If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
			//(cAliasQry)->D1_FCPAUX,;	#09
			nRet	:= aPesqSD1[nPosUltAqui][9]
		EndIF

	ElseIf cOperando == PVALORI + "BASE_ICMSST_ULT_AQUI"
		
		//Posiciona a �ltima aquisi��o para obter o valor do custo
		If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
			//(cAliasQry)->D1_BRICMS, 	#10
			nRet	:= aPesqSD1[nPosUltAqui][10]
		EndIF

	ElseIf cOperando == PVALORI + "ALQ_ICMSST_ULT_AQUI"
		
		//Posiciona a �ltima aquisi��o para obter o valor do custo
		If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
			//(cAliasQry)->D1_ALIQSOL, 	#11
			nRet	:= aPesqSD1[nPosUltAqui][11]
		EndIF

	ElseIf cOperando == PVALORI + "VLR_ICMSST_ULT_AQUI"
		
		//Posiciona a �ltima aquisi��o para obter o valor do custo
		If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
			//(cAliasQry)->D1_ICMSRET, 	#12
			nRet	:= aPesqSD1[nPosUltAqui][12]
		EndIF

	ElseIf cOperando == PVALORI + "BASE_FECP_ST_ULT_AQUI"
		
		//Posiciona a �ltima aquisi��o para obter o valor do custo
		If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
			//(cAliasQry)->D1_BSFCPST,;	#13
			nRet	:= aPesqSD1[nPosUltAqui][13]
		EndIF

	ElseIf cOperando == PVALORI + "ALQ_FECP_ST_ULT_AQUI"
		
		//Posiciona a �ltima aquisi��o para obter o valor do custo
		If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
			//(cAliasQry)->D1_ALFCPST,	#14
			nRet	:= aPesqSD1[nPosUltAqui][14]
		EndIF

	ElseIf cOperando == PVALORI + "VLR_FECP_ST_ULT_AQUI"

			//Posiciona a �ltima aquisi��o para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_VFECPST, 	#15
				nRet	:= aPesqSD1[nPosUltAqui][15]
			EndIF
	ElseIf cOperando == PVALORI + "BASE_ICMSST_REC_ANT_ULT_AQUI"

			//Posiciona a �ltima aquisi��o para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_BASNDES, 	#16
				nRet	:= aPesqSD1[nPosUltAqui][16]
			EndIF		

	ElseIf cOperando == PVALORI + "ALQ_ICMSST_REC_ANT_ULT_AQUI"

			//Posiciona a �ltima aquisi��o para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_ALQNDES,;	#17
				nRet	:= aPesqSD1[nPosUltAqui][17]
			EndIF

	ElseIf cOperando == PVALORI + "VLR_ICMSST_REC_ANT_ULT_AQUI"

			//Posiciona a �ltima aquisi��o para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_ICMNDES,	#18
				nRet	:= aPesqSD1[nPosUltAqui][18]
			EndIF

	ElseIf cOperando == PVALORI + "BASE_FECP_REC_ANT_ULT_AQUI"

			//Posiciona a �ltima aquisi��o para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_BFCPANT, 	#19
				nRet	:= aPesqSD1[nPosUltAqui][19]
			EndIF

	ElseIf cOperando == PVALORI + "ALQ_FECP_REC_ANT_ULT_AQUI"

			//Posiciona a �ltima aquisi��o para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_AFCPANT, 	#20
				nRet	:= aPesqSD1[nPosUltAqui][20]
			EndIF

	ElseIf cOperando == PVALORI + "VLR_FECP_REC_ANT_ULT_AQUI"

			//Posiciona a �ltima aquisi��o para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_VFCPANT		#21
				nRet	:= aPesqSD1[nPosUltAqui][21]
			EndIF
	
	ElseIf cOperando == PVALORI + "BASE_ICMS_ULT_AQUI"

			//Posiciona a �ltima aquisi��o para obter a base do icms
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_BASEICM		#22
				nRet	:= aPesqSD1[nPosUltAqui][22]
				//Atualiza a refer�ncia
				aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_ULT_AQUI] := .T.
			EndIF

	ElseIf cOperando == PVALORI + "ALQ_ICMS_ULT_AQUI"

			//Posiciona a �ltima aquisi��o para obter a al�quota do icms
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_PICM		#23
				nRet	:= aPesqSD1[nPosUltAqui][23]
				//Atualiza a refer�ncia
				aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_ULT_AQUI] := .T.
			EndIF

	ElseIf cOperando == PVALORI + "ZERO"
		nRet := 0
		//Refer�ncia para informar que o tributo tem al�quota ou base configurado na formula com valor zero
		aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_VL_ZERO] := .T.

	Elseif cOperando == PVALORI + "ALQ_CPRB"

		nRet := aNfItem[nItem][IT_PRD][SB_CG1_ALIQ]
		
	Elseif cOperando == PVALORI + "VLR_ICMS_ULT_AQUI_ESTRUTURA"

		//Posiciona a �ltima aquisi��o verificando os componentes do produto para obter o valor do ICMS.
		If (nPosUltAqEstr	:= GetCompUltAq(aNfItem[nItem][IT_PRODUTO],aNfCab,aNfItem,nItem,,,,,,1)) > 0
			nRet	:= aPesqEstr[nPosUltAqEstr][2]//ainda preciso definir a posi��o do retorno da query
			//Atualiza Referencia
			aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_ESTR_ULT_AQUI] := .T.
		EndIF
	
	EndIf



//Se n�o verifico se � operador de �ndice de c�lculo
ElseIf SubString(cOperando,1,2) == xFisTpForm("9")	
	//Se a origem da execu��o deste operando pertencer a uma f�rmula de al�quota, ent�o n�o dividirei por 100.
	//Se pertencer a f�rmula de base de c�lculo ou valor, ent�o dividirei por 100.
	//Verifica operandos dos �ndices de c�lculos
	If cOperando == PINDCALC + "MVA"
		IF aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_MVA] > 0
			nRet	:= 1 + (aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_MVA] / 100)
		EndIF

	ElseIf cOperando == PINDCALC + "INDICE_AUXILIAR_MVA"
		nRet	:= aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_AUX_MVA] / Iif(cDetTrbPri == "ALQ", 1, 100 )

	ElseIf cOperando == PINDCALC + "MAJORACAO"
		nRet	:= aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_MAJ] / Iif(cDetTrbPri == "ALQ", 1, 100 )

	ElseIf cOperando == PINDCALC + "INDICE_AUXILIAR_MAJORACAO"
		nRet	:= aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_AUX_MAJ] / Iif(cDetTrbPri == "ALQ", 1, 100 )

	ElseIf cOperando == PINDCALC + "PAUTA"
		nRet	:= aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_PAUTA]

	ElseIf cOperando == PINDCALC + "ALQ_SERVICO"
		
		//Primiro adiciono al�qutoa padr�o da lei complementar
		nRet	:= aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_ALQ_SERV_LEI_COMPL] / Iif(cDetTrbPri == "ALQ", 1, 100 )

		//Verifico se al�quota do munic�pio do prestador est� preenchida, se estiver ela sobreescreverar al�quota padr�o
		IF aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_ALQ_SERV] > 0
			nRet	:= aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_ALQ_SERV] / Iif(cDetTrbPri == "ALQ", 1, 100 )
		EndIF

	ElseIf cOperando == PINDCALC + "ALIQ_TAB_PROGRESSIVA"

		//Se encontrou a tabela progressiva correspondente		
		IF AScan(aTabProg, { |x| Alltrim(x[1]) == Alltrim( aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_TAB_PROG] )}) > 0

			//Busco valores da base de c�lculo do tributo de notas anteriores
			nVal	:= ValNfAnt(aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_SIGLA], aNfCab[NF_OPERNF], aNfCab[NF_CODCLIFOR], aNfCab[NF_LOJA], aNfCab[NF_DTEMISS], aNfCab[NF_DTEMISS], "BASE")
			
			//Pesquisa a tabela gen�rica correspondente ao operando. Irei buscar no cache, para evitar toda hora buscar no banco	
			nRet	:= PosTabPrg(aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_TAB_PROG], aNFItem, nItem, nPosTrbProc, aNFItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_BASE] + nVal )[1] 

		EndIF
	
	ElseIf cOperando == PINDCALC + "DED_TAB_PROGRESSIVA"	

		//Se encontrou a tabela progressiva correspondente
		IF AScan(aTabProg, { |x| Alltrim(x[1]) == Alltrim( aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_TAB_PROG] )}) > 0

			//Busco informa��es das notas anteriores
			nVal	:= ValNfAnt(aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_SIGLA], aNfCab[NF_OPERNF], aNfCab[NF_CODCLIFOR], aNfCab[NF_LOJA], aNfCab[NF_DTEMISS], aNfCab[NF_DTEMISS], "BASE")
			
			//Aqui eu enquadro na tabela progressiva para buscar o valor da dedu��o
			nRet	:= PosTabPrg( aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_TAB_PROG] , aNFItem, nItem, nPosTrbProc, aNFItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_BASE] + nVal)[2] 

		EndIF

	ElseIf cOperando == PINDCALC + "DED_DEPENDENTES"
		
		IF (nPos := AScan(aTabDep, { |x| Alltrim(x[1]) == Alltrim( aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_DED_DEP] )})) > 0 
			//Obtem o valor poss�vel de dedu��o por participante
			nSldDep  := aTabDep[nPos][2] * aNfCab[NF_NUMDEP]
			
			//Se houver valor para dedu��o seguir� o fluxo
			If nSldDep > 0

				//Busca informa��es das dedu��es j� utilizadas para o participante e no dia
				//E aqui irei subtrair o valor de dedu��o j� utilizada caso houver
				nSldDep -= ValNfAnt(aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_SIGLA], aNfCab[NF_OPERNF], aNfCab[NF_CODCLIFOR], aNfCab[NF_LOJA], aNfCab[NF_DTEMISS], aNfCab[NF_DTEMISS], "DEDDEP", aTabDep[nPos][3])

				nSldDep -= ValDepOutItem(aNfItem, nItem, aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_SIGLA])			
				
				//Retorna o valor de dedu��o
				nRet	:= nSldDep
				
			EndIF		

		EndIF
	ElseIf cOperando == PINDCALC + "PERC_REDUCAO_BASE"		
		/*
		Aqui retornarei o percentual de redu��o de base de c�lculo
		Aqui para faciliar a conta farei a convers�o. EXemplo:		
		
		Percentual de redu��o de 10%
		1 - (10 / 100) -> 1 - 0,1 -> 0,9
		O retorno ser� 0,9, que corresponde a parcela a ser tributada.
		Realizo isso aqui para n�o pedir ao usu�rio digitar o percentual invertido.
		*/
		IF LSEMREDUCAO
			nRet	:= 1
		Else
			nRet	:= 1 - (aNFItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_BAS][TG_BAS_REDUCAO] / 100)		
		EndIF
	ElseIf cOperando == PINDCALC + "INDICE_AUXILIAR_FCA"
		nRet	:= LoadFCA(aNfCab, aNFItem, nItem) //Indicadores Econ�micos FCA		
			
	ElseIf cOperando == PINDCALC + "PERC_DIFERIMENTO" // Percentual de diferimento contido na regra de escritura��o VALOR_DIFERIMENTO
		
		IF aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_ESCR][RE_PERCDIF] > 0
			nRet	:= 1 - (aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_ESCR][RE_PERCDIF]/100)
		Else 
			nRet	:= 0
		Endif
		
	EndIF

ELSEIF SubString(cOperando,1,2) == xFisTpForm("4")  //Valida se Operando � URF
	nRet := aNFItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_ALQ][TG_ALQ_VALURF]
EndIF

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} REFxOPER

Fun��o que faz o De - Para da refer�ncia com operando

@param cCampo   - Refer�ncia da MATXFIS

@author Erick Dias
@since 03/03/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function REFxOPER(cCampo)

Local cRet	:= ""
Local cPrefixo	:= xFisTpForm("0")

If cCampo == "IT_FRETE"
	cRet := cPrefixo + "FRETE"

ElseIf cCampo == "IT_VALMERC"
	cRet := cPrefixo + "VAL_MERCADORIA"

ElseIf cCampo == "IT_BASEICM"
	cRet := cPrefixo + "BASE_ICMS"

ElseIf cCampo == "IT_BICMORI"
	cRet := cPrefixo + "BASE_ORIG_ICMS"

ElseIf cCampo == "IT_VALICM"
	cRet := cPrefixo + "VAL_ICMS"	

ElseIf cCampo == "IT_BASEDUP"
	cRet := cPrefixo + "VAL_DUPLICATA"

ElseIf cCampo == "IT_TOTAL"
	cRet := cPrefixo + "TOTAL_ITEM"

ElseIf cCampo == "IT_ALIQICM"
	cRet := cPrefixo + "ALQ_ICMS"

ElseIf cCampo == "IT_ALIQSOL"
	cRet := cPrefixo + "ALQ_ICMSST"

ElseIf cCampo == "IT_SEGURO"
	cRet := cPrefixo + "SEGURO"	

ElseIf cCampo == "IT_DESPESA"
	cRet := cPrefixo + "DESPESAS"	

ElseIf cCampo == "IT_DEDICM"
	cRet := cPrefixo + "ICMS_DESONERADO"

ElseIf cCampo == "IT_VALSOL"
	cRet := cPrefixo + "ICMS_RETIDO"		

ElseIf cCampo == "IT_QUANT"
	cRet := cPrefixo + "QUANTIDADE"	

ElseIf cCampo == "IT_DESCONTO" .OR. cCampo == "IT_QIT_DESCTOTUANT"
	cRet := cPrefixo + "DESCONTO"

ElseIf cCampo == "IT_ABVLISS"
	cRet	:= cPrefixo + "DEDUCAO_SUBEMPREITADA"

ElseIf cCampo == "IT_ABMATISS"
	cRet	:= cPrefixo + "DEDUCAO_MATERIAIS"

ElseIf cCampo == "IT_ABSCINS"
	cRet	:= cPrefixo + "DEDUCAO_INSS_SUB"

ElseIf cCampo == "IT_ABVLINSS"
	cRet	:= cPrefixo + "DEDUCAO_INSS"

ElseIf cCampo == "IT_PRCCF"
	cRet	:= cPrefixo + "BASE_IPI_TRANSFERENCIA"

ElseIf cCampo == "LF_VALCONT"
	cRet	:= cPrefixo + "VAL_CONTABIL"

EndIF

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GetQtdItem

Fun��o auxiliar que retorna a quantidade do item, em fun��o da unidade de
medida informada na regra de base de al�quota, claro al�m de realizar a
convers�o da segunda unidade de medida se necess�rio.

@param aNFItem - Array com todas as informa��es do item
@param nItem - N�mero do item processado
@param cUmMed - Unidade de medida especificada se houver

@return Valor da quantidade

@author Erick Dias
@since 17/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function GetQtdItem(aNFItem, nItem, cUmMed)

Local nRet	  := 0

Default cUmMed  := ""

//Verifica se foi informada uma unidade de medida espec�fica para o c�lculo.
If !Empty(cUmMed)	
	// Se a primeira unidade do produto j� for a unidade cadastrada a base ser�
	// a pr�pria quantidade informada. N�o � necess�rio converter. Caso contr�rio
	// preciso efetuar a convers�o conforme o fator de convers�o informado no produto
	If cUmMed == Iif(!Empty(aNfItem[nItem][IT_B1UM]), aNfItem[nItem][IT_B1UM], "")
		nRet := aNFItem[nItem][IT_QUANT]
	ElseIf cUmMed == Iif(!Empty(aNfItem[nItem][IT_B1SEGUM]), aNfItem[nItem][IT_B1SEGUM], "")
		nRet := ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2)
	EndIf
Else
	//Se n�o houver nenhuma unidade de medida especificada ent�o retornar� a pr�pria quantidade
	nRet := aNFItem[nItem][IT_QUANT]
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MapOperForm

Fun��o que realiza o mapeamento dos operandos com suas devidas f�rmulas
Recebo o hashmap, operando atual e sua f�rmula
Esta fun��o vai verificar se operando est�  no hashmap, se n�o estiver
ent�o ela adicion�ria o operando e todas as suas dependencias, ou seja
todo as outras f�rmulas que est�o contidas dentro da f�rmula atual, independente
do n�vel de depend�ncia, j� que o processamento � recursivo.

@param aMapForm     - Objeto hashmap com o mapeamento dos operandos e f�rmulas
@param cOperando  - Operando atual
@param cFormula   - F�rmula do operando

@author Erick Dias
@since 18/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function MapOperForm(aMapForm, cOperando, cFormula, cTributo, aDepTrib)

Local nCont			:= 0
Local aFormula		:= {}
Local cFormTemp		:= ""

//Se f�rmula estiver vazia ent�o n�o seguirei com o processamento!
If Empty(cFormula)
	Return
EndIf

//Converte em array a f�rmula para falicitar a itera��o
aFormula	:= StrTokArr(alltrim(cFormula)," ")

//Primeiro come�o adicionando o operando e f�rmula no hashmap e verificarei se existe
//algum outro operando contido na f�rmula
AddOperando(aMapForm, Alltrim(cOperando),Alltrim(cFormula))

//-------------------------------------------------
//La�o para percorrer todos os elementos da f�rmula
//-------------------------------------------------
For nCont := 1 to len( aFormula )
	
	//-----------------------------------------------------------------------------------------------------
	//Aqui verifico se operando � de tributo para pode realizr o mapeamento das depend�ncias deste operando
	//Aqui realizo o mapeamento das dependencias dos tributos
	//-----------------------------------------------------------------------------------------------------
	If IsOperTrib(aFormula[ncont])
		MapDepTrib(aFormula[ncont], cTributo, aDepTrib)
	EndIF
	
	//Verifico se operando � composto, para eu verificar na CIN
	//Operadores, n�meros ou operadores prim�rios n�o precisam ser adicionados no hashmap
	//Verifico tamb�m se operando ainda n�o est� no hashmap, pois se j� estiver n�o preciso processar
	/////interceptar aqui para montar mapeamento das dependencias!!!!!!	
	If (IsOperComposto(aFormula[ncont]) .Or. IsOperTrib(aFormula[ncont])) .And. !FindOper(aMapForm,aFormula[ncont])
		
		//Posiciono a CIN para buscar a f�rmula do operado e me chamo novamente a fun��o recursivamente
		//para adicionar todos os filhos
		cFormTemp	:= GetFormCIN(aFormula[ncont])		
		
		If !Empty(cFormTemp)
			MapOperForm(aMapForm, aFormula[ncont], cFormTemp, cTributo, aDepTrib)
		EndIF
	EndIF

	
Next nCont

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddOperando

Adiciona operando no mapeamento de operandos vs formulas
Basicamente irei verificar se operando exite no hash
Se existir n�o preciso processar nada
Caso n�o exista, adicionarei 

@param aMapForm 	- Objeto com mapeamento dos oeprandos x formulas
@param cOperando - Operando que dever� ser procesado
@param cForNPI - F�rmula NPI do operando 

@author Erick Dias
@since 18/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function AddOperando(aMapForm, cOperando, cForNPI)

//Somente realizo opera��o se oeprando for enviado para fun��o
//Se array estiver vazio tamb�m n�o adicionarei
If Empty(cOperando) .Or. Empty(cForNPI)
	Return
EndIf

//Primeiro verifico se operando j� exiete no hashmap
If !FindOper(aMapForm,cOperando)
	//Operando n�o existe no hashmap, ent�o apenas adiciono	
	aAdd(aMapForm, {cOperando,cForNPI})
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FindOper

Fun��o que verifica se determinada chave existe no hashmap

@param aMapForm 	- Objeto com mapeamento dos oeprandos x formulas
@param cChave   - Chave do hashmap a ser adicionada
@param cRet   - Conte�do da chave caso esteja no hashmap

@return - Retorna .T. se encontrou a chave no hashmap

@author Erick Dias
@since 18/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function FindOper(aMap,cChave, cRet)

Local nX		:= 0
Default cRet	:= ""

//Pesquiso a f�rmula do operando solicitado
IF(nX := aScan(aMap,{|x| AllTrim(x[1]) == Alltrim(cChave)})) > 0
	cRet := aMap[nX][2] 
EndIf

Return (nX > 0)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFormCIN

Fun��o que posiciona a CIN considerando o operando enviado
e retorna a f�rmula NPI.

@param cOperando   - Operando que ser� procurado na CIN

@return - cRet - F�rmula NPI do operando enviado na fun��o

@author Erick Dias
@since 18/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static function GetFormCIN(cOperando)

//Verifico se operando est� preenchido antes de continua
If Empty(cOperando)
	Return
EndIF

//Busco a f�rmula e o tipo da regra do operando enviado para fun��o
If CIN->(MsSeek(xFilial('CIN') + Padr(cOperando,TamSx3("CIN_CODIGO")[1])  + "0" ))//Procuro com 0 indicando que quero CIN vigente, e n�o CIN hist�rica
	Return CIN->CIN_FNPI
EndIF

Return ""

//-------------------------------------------------------------------
/*/{Protheus.doc} GetValOper

Fun��o que retornar� o valor do tributo calculado do operando
enviado na fun��o

@param cOperando   - C�digo do operando que ser� processado 
@param aNfItem   - Array com as informa��es dos itens
@param nItem   - N�mero do item

@return - Valor do tributo caso tenha sido enquadrado

@author Erick Dias
@since 21/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function GetPosTrib(cOperando, aNfItem, nItem)

//Se n�o veio operando nenhum, ent�o n�o conseguirei analisar
IF Empty(cOperando)
	Return 0
EndIF

Return aScan(aNfItem[nItem][IT_TRIBGEN],{|x| AllTrim(x[TG_IT_SIGLA]) == Alltrim(cOperando)})

//-------------------------------------------------------------------
/*/{Protheus.doc} MapDepTrib

Fun��o que monta o mapeamento das dependencias entre os tributos gen�ricos
Este mapeamente vai auxiliar no momento de altera��es de base, al�quota e valores
dos tributos que incidem na base ou no valor de outros tributos.

@param cOperando  - C�digo do operando
@param cTrib    - Tributo dependentendeste operandos
@param aDepTrib  - Array com o mapeamento

@author Erick Dias
@since 28/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function MapDepTrib(cOperando, cTrib, aDepTrib)

Local nX		:= 0

//Busco pelo operando no array
IF (nX := aScan(aDepTrib,{|x| AllTrim(x[1]) == Alltrim(cOperando)})) > 0
	
	//Procuro o tributo relacionado com o operando
	IF aScan(aDepTrib[nX][2],{|x| Alltrim(x) == Alltrim(cTrib)}) == 0
		
		//Este operando ainda n�o foi vinculado com este tributo, irei vincular agora		
		//Somente adicionarei outros tributos dependentes.
		IF GetTribOper(cOperando) <> cTrib
			//Fa�o o mapeamento
			aAdd(aDepTrib[nX][2], cTrib)
		EndIF

	EndIF
Else
	//Adicionar� no array
	//Operando ainda n�o est� no array, precisa vincular operando e tributo
	//Somente adicionarei outros tributos dependentes.
	IF GetTribOper(cOperando) <> cTrib
		//Fa�o o mapeamento		
		aAdd(aDepTrib, {cOperando, {cTrib}})
	EndIF
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RetValTrib

Fun��o auxiliar que retorna o valor do tributo, utilizada para considerar
o valor j� calculado na refer�ncia, para considerar eventuais altera��es realizadas pelo usu�rio

@param cDetTrib  - Sufixo do tributo
@param aNFItem   - Array com as informa��es do item da nota
@param nItem     - N�mero do item processadp
@param nTrbGen   - Posi��o do tributo gen�rico 

@return - Valor calculado do tributo

@author Erick Dias
@since 28/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function RetValTrib(cDetTrib, aNFItem,nItem,nTrbGen)

Local nResultado	:= 0
//Devo buscar o valor
If cDetTrib == "BAS"
	nResultado	:= aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE]
ElseIf cDetTrib == "ALQ"
	nResultado	:= aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA]
	//Verifica se valor obtido � percentual
	IF aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_TPALIQ] <> '2'
		nResultado := nResultado / 100
	Endif
ElseIf cDetTrib == "VAL"	
	//Quando n�o houver escritura��o retorna valor calculado do tributo
	IF !Empty(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_ID])
		nResultado	:= aNFitem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_VALTRIB]
	Else		
		nResultado	:= aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]
	Endif	
ElseIf cDetTrib == "ISE"
	nResultado	:= aNFitem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_ISENTO]
ElseIf cDetTrib == "OUT"
	nResultado	:= aNFitem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_OUTROS]
ElseIf cDetTrib == "DIF"
	nResultado	:= aNFitem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_DIFERIDO]
EndIF

Return nResultado

//-------------------------------------------------------------------
/*/{Protheus.doc} IsOperTrib

Fun��o que identifica se opernado � de tributo

@param cOperando  - Operando a ser analizado

@return - .T. caso o operano seja de tributo

@author Erick Dias
@since 28/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function IsOperTrib(cOperando)
Return Substring(cOperando, 1, 4) $ "ALQ:|BAS:|VAL:|ISE:|OUT:|DIF:"

//-------------------------------------------------------------------
/*/{Protheus.doc} IsOperComposto

Fun��o que verifica se o tributo � composto, regra de base, al�quota tributo etc

@param cOperando  - Operando a ser analizado

@return - .T. caso o operano composto

@author Erick Dias
@since 28/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function IsOperComposto(cOperando)
Return Substring(cOperando,1,2) $ "B:|A:"

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTribOper

Fun��o que retorna o tibuto do operando de tributo

@param cOperando  - Operando a ser analizado

@return - cTribFor - Tributo do operando

@author Erick Dias
@since 28/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function GetTribOper(cOperando)
Return Right(cOperando, Len(cOperando) - 4 )

//-------------------------------------------------------------------
/*/{Protheus.doc} CalcDep

Fun��o que faz o c�lculo dos tirbutos dependentes

@param aDepTrib   - Array com mapeamento das dependencias
@param cOperando  - Operando que dever� ser verificado suas dependencias
@param aNfItem    - Array com as informa��es do item da nota
@param nItem      - N�mero do item da nota
@param aNfCab     - Array com as informa��es do cabe�alho da nota
@param aMapForm     - Hashmap com o mapeamento das f�rmulas e operandois

@author Erick Dias
@since 28/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function CalcDep(aDepTrib, aNfItem, nItem, aNfCab, aMapForm, cOperando, cExecuta,aFunc)

Local nX		:= 0
Local nY		:= 0
Local nPosTrib	:= 0

//Obtem o operando do valor, j� que a base foi alterada, o valor tamb�m ser� alterado e preciso refletir isso nos tributos dependentes do valor
If(nX := aScan(aDepTrib,{|x| AllTrim(x[1]) == Alltrim(cOperando)})) > 0

	//La�o para realizar o c�lculo de todos os tributos dependentes do operando alterado
	For nY := 1 to Len(aDepTrib[nX][2])
		//Posiciona o item e refazer c�lculo
		nPosTrib := GetPosTrib(aDepTrib[nX][2][nY] , aNfItem, nItem)			
		FisCalcTG(@aNFItem, nItem, nPosTrib, cExecuta ,aNfCab, aMapForm, .T.,aFunc)
	Next nY

EndIf

return

//-------------------------------------------------------------------
/*/{Protheus.doc} MapValOrig

Fun��o que realiza o mapeamento dos tributos dependentes dos operandos
prim�rios/valores de origem, tais como frete, desconto, seguro etc.

Este mapeamento � imporante no momento que o usuario altera algum valor, 
precisamos saber qual tributo exatamente dever� ser alterado, para n�o
peder eventuais altera��es manuais realizada pel usu�rio

@param cFormula   - F�rmula a ser analizada
@param cTributo  - Tributo a ser analisado
@param aDepVlOrig   - Array com mapeamento atual

@author Erick Dias
@since 03/03/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function MapValOrig(cFormula, cTributo, aDepVlOrig)

Local nX			:= 0
Local aFormula		:= {}
Local cFormTemp		:= ""

//Se f�rmula estiver vazia ent�o n�o seguirei com o processamento!
If Empty(cFormula)
	Return
EndIf

//Converte em array a f�rmula para falicitar a itera��o
aFormula	:= StrTokArr(alltrim(cFormula)," ")

//-------------------------------------------------
//La�o para percorrer todos os elementos da f�rmula
//-------------------------------------------------
For nX := 1 to len(aFormula)

	//Verifica se operando � composto, ou seja, formado por outrar f�rmula
	If IsOperComposto(aFormula[nX]) .Or. IsOperTrib(aFormula[nX])
		//Chamarei novamente a fun��o		

		//Obtenho a f�rmula dele para ser analisada
		cFormTemp	:= GetFormCIN(aFormula[nX])
		
		//Se tem f�rmula continuo
		If !Empty(cFormTemp)
			//Chamo novamente a fun��o de forma recursiva para analisar pr�ximo n�vel de operandos
			MapValOrig(cFormTemp, cTributo, aDepVlOrig)
		EndIf
		
	//Se n�o for operando composto, n�o for operador e n�o for n�mero est�tico, ent�o � um operando prim�rio
	Elseif !IsDigit(aFormula[nX]) .And. !SubString(aFormula[nX], 1,2)  $ "/*-+" .ANd. Alltrim(aFormula[nX]) <> "MAIOR"
		
		//Aqui fa�o o mapeamento, do tributo com operando prim�rio
		DepValOrig(aDepVlOrig, aFormula[nX], cTributo)

	EndIF

Next nX

aFormula	:= nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DepValOrig

Fun��o que atualiza o array de depend�ncias dos operandos pri�rios

Este mapeamento � imporante no momento que o usuario altera algum valor, 
precisamos saber qual tributo exatamente dever� ser alterado, para n�o
peder eventuais altera��es manuais realizada pel usu�rio

@param aDepVlOrig   - Array com mapeamento atual
@param cOperOrig   - Operador de valor de origem/prim�rio
@param cTributo  - Tributo a ser analisado


@author Erick Dias
@since 03/03/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function DepValOrig(aDepVlOrig, cOperOrig, cTributo)

Local nX := 0

//Primeiro procuro no array de depend�ncia se o operando existe
If(nX := aScan(aDepVlOrig,{|x| AllTrim(x[1]) == Alltrim(cOperOrig)})) > 0
	//Aqui o operando j� est� inclu�do, precisa verificar se para este tributo tamb�m

	//Procuro o tributo relacionado com o operando
	IF aScan(aDepVlOrig[nX][2],{|x| Alltrim(x) == Alltrim(cTributo)}) == 0
	
		//Operando j� foi adicionado no mapeamento, por�m s� n�o estava vinculado com este tributo
		aAdd(aDepVlOrig[nX][2], cTributo)

	EndIF

Else
	//Aqui n�o tem operando de valor de origem no mapeamento, ser� adicionado
	aAdd(aDepVlOrig, {cOperOrig, {cTributo}})	

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FisCalcLeg

Fun��o que faz c�lculo dos tributos da onda 1 do configurador, sem 
utiliza��o de f�rmulas

@param aNFItem   - Array com mapeamento atual
@param nItem     - Operador de valor de origem/prim�rio
@param nTrbGen   - Tributo a ser analisado
@param cExecuta  - Tributo a ser analisado
@param aNFCab    - Tributo a ser analisado

@author Erick Dias
@since 05/03/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Function FisCalcLeg(aNFItem, nItem, nTrbGen, cExecuta, aNFCab)

Local nBase 	:= 0
Local nAliquota := 0
Local nValor 	:= 0
Local cPrUm 	:= ""
Local cSgUm 	:= ""

// N�o reduzir a base quando o valor de origem for a quantidade.
Local lReduzBase := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] <> '02' .And. aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_REDUCAO] > 0

DEFAULT cExecuta := "BSE|ALQ|VLR"

//--------------------------------------------------------------------
//Adiciono nova posi��o para controle do SaveDec do tributo gen�rico
//--------------------------------------------------------------------
//Preciso verificar se o tributo j� consta no array do SaveDec, se j� existe n�o precisa adicoonar, se n�o existe ai ser� criado.		
TgSaveDec(@aNFCab, @aNfItem, nItem, nTrbGen)

//---------------------------------------
// Defini��o da base de c�lculo
//---------------------------------------
If "BSE" $ cExecuta

	Do Case

		// 01 - Valor da mercadoria
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '01'

			nBase := aNFItem[nItem][IT_VALMERC]

		// 02 - Quantidade
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '02'

			// Se for informada uma unidade de medida espec�fica para o c�lculo
			If !Empty(aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_UM])

				// Obtenho a primeira e a segunda unidade de medida informadas no produto
				cPrUm := Iif(!Empty(aNfItem[nItem][IT_B1UM]), aNfItem[nItem][IT_B1UM], "")
				cSgUm := Iif(!Empty(aNfItem[nItem][IT_B1SEGUM]), aNfItem[nItem][IT_B1SEGUM], "")

				// Se a primeira unidade do produto j� for a unidade cadastrada a base ser�
				// a pr�pria quantidade informada. N�o � necess�rio converter. Caso contr�rio
				// preciso efetuar a convers�o conforme o fator de convers�o informado no produto
				If cPrUm == aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_UM]
					nBase := aNFItem[nItem][IT_QUANT]
				ElseIf cSgUm == aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_UM]
					nBase := ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2)
				EndIf

			Else
				nBase := aNFItem[nItem][IT_QUANT]
			EndIf

		// 03 - Valor Cont�bil
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '03'

			nBase := aNfItem[nItem][IT_LIVRO][LF_VALCONT]

		// 04 - Valor do Cr�dito Presumido - OBRIGATORIO usar o gen�rico!
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '04'

			nBase := aNfItem[nItem][IT_LIVRO][LF_CRDPRES]

		// 05 - Base do ICMS
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '05'

			nBase := aNfItem[nItem][IT_BASEICM]

		// 06 - Base "original" do ICMS
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '06'

			nBase := aNfItem[nItem][IT_BICMORI]

		// 07 - Valor do ICMS
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '07'

			nBase := aNfItem[nItem][IT_VALICM]

		// 08 - Valor do Frete
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '08'

			nBase := aNfItem[nItem][IT_FRETE]

		// 09 - Valor da Duplicata
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '09'

			nBase := aNfItem[nItem][IT_BASEDUP]

		// 10 - Valor total do item
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '10'

			nBase := aNfItem[nItem][IT_TOTAL]			

	EndCase

	// Verifica configura��o para aplicar a redu��o de base antes das dedu��es/adi��es...
	If lReduzBase .And. aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_TPRED] == '1'
		nBase := (nBase * (1 - (aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_REDUCAO] / 100)))
	EndIf

	/*

	Regra geral das adi��es subtra��es:

	1 - Sem a��o
	2 - Subtrai
	3 - Soma

	*/

	// Desconto

	Do Case
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_DESCON] == '2'
			nBase -= (aNfItem[nItem][IT_DESCONTO] + aNfItem[nItem][IT_DESCTOT])
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_DESCON] == '3'
			nBase += (aNfItem[nItem][IT_DESCONTO] + aNfItem[nItem][IT_DESCTOT])
	EndCase

	// Frete

	Do Case
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_FRETE] == '2'
			nBase -= aNfItem[nItem][IT_FRETE]
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_FRETE] == '3'
			nBase += aNfItem[nItem][IT_FRETE]
	EndCase

	// Seguro

	Do Case
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_SEGURO] == '2'
			nBase -= aNfItem[nItem][IT_SEGURO]
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_SEGURO] == '3'
			nBase += aNfItem[nItem][IT_SEGURO]
	EndCase

	// Despesas

	Do Case
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_DESP] == '2'
			nBase -= aNfItem[nItem][IT_DESPESA]
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_DESP] == '3'
			nBase += aNfItem[nItem][IT_DESPESA]
	EndCase

	// ICMS Desonerado

	Do Case
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ICMSDES] == '2'
			nBase -= aNfItem[nItem][IT_DEDICM]
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ICMSDES] == '3'
			nBase += aNfItem[nItem][IT_DEDICM]
	EndCase

	// ICMS-ST

	Do Case
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ICMSST] == '2'
			nBase -= aNfItem[nItem][IT_VALSOL]
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ICMSST] == '3'
			nBase += aNfItem[nItem][IT_VALSOL]
	EndCase


	// Verifica configura��o para aplicar a redu��o de base ap�s as dedu��es/adi��es
	If lReduzBase .And. aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_TPRED] == '2'
		nBase := (nBase * (1 - (aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_REDUCAO] / 100)))
	EndIf

	// Atribuindo base "final" na refer�ncia de base do tributo.
	aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE] := nBase

EndIf

//---------------------------------------
// Defini��o da al�quota
//---------------------------------------
If "ALQ" $ cExecuta

	Do Case

		// 01 - Al�quota do ICMS
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VLORI] == '01' .AND. aNfItem[nItem][IT_BASEICM] > 0

			nAliquota := aNfItem[nItem][IT_ALIQICM]

		// 02 - Al�quota do Cr�dito Presumido
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VLORI] == '02' .AND. aNfItem[nItem,IT_LIVRO,LF_CRDPRES] > 0

			nAliquota := aNFItem[nItem][IT_TS][TS_CRDPRES]

		// 03 - Al�quota do ICMS-ST
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VLORI] == '03' .AND. aNfItem[nItem][IT_BASESOL] > 0

			nAliquota := aNFItem[nItem][IT_ALIQSOL]

		// 04 - Al�quota Informada Manualmente
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VLORI] == '04'

			nAliquota := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_ALIQ]

		// 05 - Unidade de Refer�ncia Fiscal
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VLORI] == '05'

			nAliquota := (aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VALURF] * (aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_PERURF] / 100))

	EndCase


	aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA] := nAliquota

EndIf

//---------------------------------------
// Defini��o do valor
//---------------------------------------
If "VLR" $ cExecuta

	If aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VLORI] == '04'
		// Divido por 100 caso a al�quota informada for do tipo 1 - percentual
		If aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_TPALIQ] == '1'
			nValor := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE] * (aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA] / 100)
		Else
			nValor := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE] * aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA]
		EndIf
	ElseIf aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VLORI] == '05'
		nValor := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE] * aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA]
	Else
		nValor := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE] * (aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA] / 100)
	EndIf

	aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR] := nValor

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FisCalcForm

Fun��o que faz c�lculo dos tributos por meio das f�rmulas NPI

@param aNFItem   - Array com mapeamento atual
@param nItem     - Operador de valor de origem/prim�rio
@param nTrbGen   - Tributo a ser analisado
@param cExecuta  - Tributo a ser analisado
@param aNFCab    - Tributo a ser analisado
@param aMapForm  - Mapeamento das f�rmulas da CIN
@param lEdicao    - Indica se est� realizando altera��o em alguma propriedade espec�fica do tributo

@author Erick Dias
@since 05/03/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Function FisCalcForm(aNFItem, nItem, nTrbGen, cExecuta, aNFCab, aMapForm, lEdicao)


//Se for para processar todas as propriedades do tributo, ent�o farei de uma vez por meiuo da fun��o xFisExecNPI, que j� atualizar� o valor base e al�quota.
If cExecuta == "BSE|ALQ|VLR" .AND. !Empty( aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FOR_NPI] )

	//Verifica se a unidade de medida se enquadra antes de executar
	If BaseEnq(aNFItem, nItem, nTrbGen)

		xFisExecNPI(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_COD_FOR], aNFItem, nItem, aMapForm, .F.,, nTrbGen,, aNfCab)	

	EndIF

Else

	//Caso seja alguma edi��o e que necessite calcular somente algumas propriedades do tributo, ent�o chamarei separado.	
	
	//---------------------------------------
	// Defini��o da base de c�lculo
	//---------------------------------------
	If "BSE" $ cExecuta .And. BaseEnq(aNFItem, nItem, nTrbGen) //Verifica se a unidade de medida se enquadra antes de executar

		//Aqui executo a f�rmula  NPI			
		xFisExecNPI(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_COD_FOR], aNFItem, nItem, aMapForm, lEdicao,, nTrbGen,, aNfCab)

	EndIf

	//---------------------------------------
	// Defini��o da al�quota
	//---------------------------------------
	If "ALQ" $ cExecuta
	
		//-----------------------------------------------------------------
		//Se houver f�rmua ent�o realizar� o c�lculopor meio da f�rmula NPI
		//-----------------------------------------------------------------
		xFisExecNPI(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_COD_FOR], aNFItem, nItem, aMapForm, lEdicao,, nTrbGen,, aNfCab)		

	EndIf

	//---------------------------------------
	// Defini��o do valor
	//---------------------------------------
	If "VLR" $ cExecuta
	
		//-----------------------------------------------------------------
		//Se houver f�rmua ent�o realizar� o c�lculopor meio da f�rmula NPI
		//-----------------------------------------------------------------		
		xFisExecNPI(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_COD_FOR], aNFItem, nItem, aMapForm, lEdicao,, nTrbGen,, aNfCab)	

	EndIf

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BaseEnq

Fun��o que verifica se a regra de base de c�lculo se enquadra com a unidade
do item da nota

@param aNFItem   - Array com mapeamento atual
@param nItem     - Operador de valor de origem/prim�rio
@param nTrbGen   - Tributo a ser analisado

@author Erick Dias
@since 05/03/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function BaseEnq(aNFItem, nItem, nTrbGen)


Local lRet	:= Empty(aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_UM]) .Or. ;
			   aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_UM] == Iif(!Empty(aNfItem[nItem][IT_B1UM])   , aNfItem[nItem][IT_B1UM]   , "") .Or. ;
			   aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_UM] == Iif(!Empty(aNfItem[nItem][IT_B1SEGUM]), aNfItem[nItem][IT_B1SEGUM], "")
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ExecMaxMin

Fun��o que receber� uma f�rmula no padr�o MAIOR(A, B) ou MENOR(A, B)
Esta fun��o executar� os dois operandos, e vai comparar qual 
tem o valor maior. O operando que tiver maior valor ser�
retornado para que chamou esta fun��o.

@param cFormula   - F�rmula a ser executada

@author Erick Dias
@since 03/07/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function ExecMaxMin(cFormula, aNFItem, nItem, aMapForm, nPosTrbProc, cDetTrib, aNfCab, cTipo)

Local aFormula	:= {}
Local cOperando1:= ""
Local cOperando2:= ""
Local nVal1 	:= 0
Local nVal2 	:= 0

//Verifica se a f�rmula est� preenchida antes de seguir
If Empty(cFormula)
	Return ""
EndIF

//Converte a f�rmula
aFormula	:= StrTokArr(alltrim(cFormula)," ")

//Verifica se a f�rmula est� no padr�o correto antes de seguir.
If Len(aFormula) < 4
	Return ""
EndIF

//(MAIOR A , B) // Estrutura de como estar� a f�rmula
//(MENOR A , B) // Estrutura de como estar� a f�rmula

//Obtendo os opernados
cOperando1 := aFormula[2]
cOperando2 := aFormula[4]

//Executando as f�rmulas
nVal1	   := xFisExecNPI(cOperando1, aNFItem, nItem, aMapForm, .F., .F., nPosTrbProc, cDetTrib, aNfCab)
nVal2	   := xFisExecNPI(cOperando2, aNFItem, nItem, aMapForm, .F., .F., nPosTrbProc, cDetTrib, aNfCab)

//Se valor1 for maior, retorna o opernado 1, caso contr�rio retonar o 2
If cTipo == "MAIOR"
	If nVal1 > nVal2
		return cOperando1
	EndIf
Else
	//MENOR
	If nVal1 < nVal2
		return cOperando1
	EndIf
EndIf

Return cOperando2

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadTabPrg

Fun��o que faz cache das informa��es da tabela progressiva, para que seja evitado
acesso ao banco de dados durante todo o c�lculo

@param cCodTab   - Operando a ser verificado
@param aTabProg   - Array com o cahce

@author Erick Dias
@since 14/07/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function LoadTabPrg(cCodTab, aTabProg)

Local nPos := 0

//Se c�digo estiver vazio encerra
If Empty(cCodTab)
	Return
EndIF

//Se c�digo j� foi cacheado tamb�m encerra
If AScan(aTabProg, { |x| Alltrim(x[1]) == Alltrim(cCodTab)}) > 0
	Return
EndIF

CIQ->(dbSetOrder(1)) //CIQ_FILIAL+CIQ_CODIGO
CIR->(dbSetOrder(3)) //CIR_FILIAL+CIR_IDCAB

If CIQ->(MsSeek(xFilial("CIQ") + cCodTab)) .And. !Empty(CIQ->CIQ_ID) .And. CIR->(MsSeek(xFilial("CIR") + CIQ->CIQ_ID))	

	Do While !CIR->(EOF()) .AND. CIQ->CIQ_ID == CIR->CIR_IDCAB
		//Aqui estou posicionado nos itens da tabela
		//Estrutura do Array
		/*
		-C�digo da tabela
		-Valor Inicial
		-Valor Final
		-Valor da Al�quota
		-Valor da Dedu��o
		*/
		
		//Obtenho a posi��o caso j� esteja preenchido
		nPos:= AScan(aTabProg, { |x| Alltrim(x[1]) == Alltrim(cCodTab)})
		
		//Adiciono se n�o existir
		IF nPos == 0
			aAdd(aTabProg,{cCodTab} )
			nPos := Len(aTabProg)
		EndIF		
		
		//Adiciono valores no array.
		aAdd(aTabProg[nPos],{CIR->CIR_VALINI, CIR->CIR_VALFIM, CIR->CIR_ALIQ, CIR->CIR_VALDED} )		

		CIR->(DbSKip())
	EndDo
	
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PosTabPrg

Fun��o auxiliar para buscar informa��es da tabela progressiva no cache

@param cOperando   	- Operando a ser verificado
@param aNFItem   	- Array com informa��es do item da nota
@param nItem   		- N�mero do item da nota fical
@param nPosTrbProc  - Posic��o do tributo gen�rico que est� sendo processado
@param nValorRef    - Valor de refer�ncia a ser comparado com faixas da tabela progressiva

@return Array  - Al�quota e valor da dedu��o caso se enquadre na tabela 

@author Erick Dias
@since 14/07/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function PosTabPrg(cOperando, aNFItem, nItem, nPosTrbProc, nValorRef) 

Local nPos 			:= AScan(aTabProg, { |x| Alltrim(x[1]) == Alltrim(cOperando)})
Local nX   			:= 0
//Posi��es para facilitar leitura do array
Local nPosValIni	:= 1
Local nPosValFim	:= 2
Local nPosAliq		:= 3
Local nPosDeduc		:= 4

//Verifico se a tabela est� no cache
IF nPos > 0

	//Encontrou a tabela progressiva correspondente
	For nX := 2 To Len(aTabProg[nPos])
		
		//Verifico se valor da base de c�lculo est� contida na faixa entre os valores m�nimo e m�ximo
		IF nValorRef >= aTabProg[nPos][nX][nPosValIni] .And. nValorRef <= aTabProg[nPos][nX][nPosValFim]
			//O valor foi enquadrado
			Return {aTabProg[nPos][nX][nPosAliq], aTabProg[nPos][nX][nPosDeduc]}			
			Exit
		EndIF
		
	Next nX

EndIF

//Retornarei zero caso n�o enquadre na tabela.
Return {0,0}

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadDedDep

Fun��o que faz cache das informa��es da tabela progressiva, para que seja evitado
acesso ao banco de dados durante todo o c�lculo

@param cCodTab   - Operando a ser verificado
@param aTabProg   - Array com o cahce

@author Erick Dias
@since 14/07/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function LoadDedDep(cCodTab, aTabDep)

//Se c�digo estiver vazio encerra
If Empty(cCodTab)
	Return
EndIF

//Se c�digo j� foi cacheado tamb�m encerra
If AScan(aTabDep, { |x| Alltrim(x[1]) == Alltrim(cCodTab)}) > 0
	Return
EndIF

CIV->(dbSetOrder(4)) //CIV_FILIAL+CIV_CODDEP+CIV_ALTERA

If CIV->(MsSeek(xFilial("CIV") + PADR(cCodTab, 6) + "2"))
	
	//Aqui estou posicionado nos itens da tabela
	//Estrutura do Array
	/*
	-C�digo da tabela
	-VAlor da dedu��o por dependente	
	*/
	
	//Adiciono valores no array.
	aAdd(aTabDep,{CIV->CIV_CODDEP, CIV->CIV_VALDEP, CIV->CIV_TPDATA} )
	
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ValNfAnt

Fun��o que buscar� informa��es e valores de notas anteriores, considerando
o participante e range de datas.

@param cRegraTrib   - C�digo da regra do tributo
@param cTpNF      - Tipo do doumento fiscal, nota de entrada, sa�da
@param cCodPart   - C�digo do participante
@param cLojaPart  - Loja do participante
@param dDtIni     - Data inicial do range
@param dDtFim     - Data final do range
@param cTpData	  - Tipo da data que ser� filtrado no financeiro

@return aRet      - Array com os valores retornado

@author Erick Dias
@since 14/07/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function ValNfAnt(cRegraTrib, cTpNF, cCodPart, cLojaPart, dDtIni, dDtFim, cCampoF2D, cTpData)
Local nRet		:= 0
Local nX		:= 0
Local cAliasQry := GetNextAlias()
Local cSelect	:= ""
Local cFrom		:= ""
Local cWhere	:= ""
Local cTabela 	:= Iif(cTpNF == "E", "SD1", "SD2")
Local cAliasCpo	:= Iif(cTpNF == "E", "SE2.E2", "SE1.E1")
Local cJoinFin	:= ""

Default cTpData:= ""

//Se estas infomra��es n�o estiverem preenchidas retornarei zero!
If Empty(cRegraTrib) .OR. Empty(cTpNF) .Or. Empty(cCodPart) .Or. Empty(cLojaPart) .Or. Empty(cCampoF2D)
	Return 0
EndIF

//Verifico se j� realizei a busca no array com cache das consultas SQL
/*
Estrutura do array 
1-Tributo
2-Campo F2D
3-Tipo(Entrada/sa�da)
4-Codigo participante
5-Loja participante
6-Data ini
7-Data fim
8-Valor
*/
nX := aScan(aPesqF2D,{|x| x[1] == cRegraTrib .And. ;
                          x[2] == cCampoF2D .And. ;
						  x[3] == cTpNF .And. ;
						  x[4] == cCodPart .And. ;
						  x[5] == cLojaPart .And. ;
						  x[6] == dDtIni .And. ;
						  x[7] == dDtFim })

//Verifica se query est� no cache. Se estiver basta retornar os valores
IF nX > 0
	//Aqui apenas retorno o valor
	Return	aPesqF2D[nX][8]	
Else
	
	//Aqui farei a consulta pela primeira vez e armazenarei no array de cache
	cSelect := "SUM( F2D.F2D_" + cCampoF2D + " ) VALOR"

	//From na tabela F2D
	cFrom   += RetSQLName("F2D") + " F2D "

	IF cTpNF == "E" //Entrada, farei JOIN com SD1
		//JOIN SD1/SF1
		cFrom += "JOIN " + RetSQLName("SD1") + " SD1 " + " ON (SD1.D1_FILIAL = " + ValToSQL(xFilial("SD1")) + " AND SD1.D1_IDTRIB = F2D.F2D_IDREL AND SD1.D1_FORNECE = " + ValToSQL(cCodPart) + " AND SD1.D1_LOJA = " + ValToSQL(cLojaPart) + " AND SD1.D1_EMISSAO BETWEEN " + ValToSQL(dDtIni) + " AND " + ValToSQL(dDtFim) + " AND SD1.D_E_L_E_T_ = ' ') "
		cFrom += "JOIN " + RetSQLName("SF1") + " SF1 " + " ON (SF1.F1_FILIAL = " + ValToSQL(xFilial("SF1")) + " AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA AND SF1.D_E_L_E_T_ = ' ') "
	ElseIF cTpNF == "S" //Sa�da, farei JOIN com SD2
		//JOIN SD2/SF2
		cFrom += "JOIN " + RetSQLName("SD2") + " SD2 " + " ON (SD2.D2_FILIAL = " + ValToSQL(xFilial("SD2")) + " AND SD2.D2_IDTRIB = F2D.F2D_IDREL AND SD2.D2_CLIENTE = " + ValToSQL(cCodPart) + " AND SD2.D2_LOJA = " + ValToSQL(cLojaPart) + " AND SD2.D2_EMISSAO BETWEEN " + ValToSQL(dDtIni) + " AND " + ValToSQL(dDtFim) + " AND SD2.D_E_L_E_T_ = ' ') "	
		cFrom += "JOIN " + RetSQLName("SF2") + " SF2 " + " ON (SF2.F2_FILIAL = " + ValToSQL(xFilial("SF2")) + " AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA AND SF2.D_E_L_E_T_ = ' ') "
	EndIF

	//Pesquisar no financeiro os t�tulos das notas fiscais
	If !Empty(cTpData) .AND. cTpData <> '4'

		//Adicionar o filtro de qual data ser� considerada no filtro
		If cTpData == "2" //1= Emissao; 2= Vencimento Real; 3=Data Contabilizacao
			cJoinFin += cAliasCpo + "_VENCREA  BETWEEN "+ ValToSql(FirstDay(dDataBase)) + " AND "+ValToSql(LastDay(dDataBase)) + " AND "+ Left(cAliasCpo,4) + "D_E_L_E_T_ = ' ' "
		ElseIf cTpData == "1"
			cJoinFin += cAliasCpo + "_EMISSAO  BETWEEN "+ ValToSql(FirstDay(dDataBase)) + " AND "+ValToSql(LastDay(dDataBase)) + " AND "+ Left(cAliasCpo,4) + "D_E_L_E_T_ = ' ' "
		Else
			cJoinFin += cAliasCpo + "_EMIS1  BETWEEN "+ ValToSql(FirstDay(dDataBase)) + " AND "+ValToSql(LastDay(dDataBase)) + " AND "+ Left(cAliasCpo,4) + "D_E_L_E_T_ = ' ' "
		EndIf

		IF cTpNF == "E" //Entrada, farei JOIN com SE2
			//JOIN SE2
			cFrom += "JOIN " + RetSQLName("SE2") + " SE2 " + " ON (SE2.E2_FILIAL = " + ValToSQL(xFilial("SE2")) + " AND SE2.E2_FORNECE = SF1.F1_FORNECE AND SE2.E2_LOJA = SF1.F1_LOJA AND SE2.E2_PREFIXO = SF1.F1_PREFIXO AND SE2.E2_NUM = SF1.F1_DOC AND " + cJoinFin + ") "	
		ElseIf cTpNF == "S" //Sa�da, farei JOIN com SE1
			//JOIN SE1
			cFrom += "JOIN " + RetSQLName("SE1") + " SE1 " + " ON (SE1.E1_FILIAL = " + ValToSQL(xFilial("SE1")) + " AND SE1.E1_CLIENTE = SF2.F2_CLIENTE AND SE1.E1_LOJA = SF2.F2_LOJA AND SE1.E1_PREFIXO = SF2.F2_PREFIXO AND SE1.E1_NUM = SF2.F2_DOC AND " + cJoinFin + ") "	
		EndIf
	EndIf

	//
	cWhere  += " F2D.F2D_FILIAL = " + ValToSQL(xFilial("F2D"))  + " AND "
	cWhere  += " F2D.F2D_TRIB = "   + ValToSQL(cRegraTrib)      + " AND "
	cWhere  += " F2D.F2D_TABELA = " + ValToSQL(cTabela)         + " AND "
	cWhere  += " F2D.F2D_DTEXCL = ' ' AND "
	cWhere  += " F2D.D_E_L_E_T_ = ' '"

	//Concatenar� o % e executar� a query.
	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom   + "%"
	cWhere  := "%" + cWhere  + "%"

	BeginSQL Alias cAliasQry

		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%

	EndSQL

	//La�o no resultado da query
	Do While !(cAliasQry)->(Eof())
		
		//Obtenho o valor j� somado pela query
		nRet	:= (cAliasQry)->VALOR
		
		(cAliasQry)->(DbSKip())
	Enddo

	//Fecha o Alias antes de sair da fun��o
	dbSelectArea(cAliasQry)
	dbCloseArea()
	
	//Aqui adiciono pesquisa no cache para n�o ser refeito posteriormente
	aAdd(aPesqF2D,{cRegraTrib, cCampoF2D, cTpNF, cCodPart,cLojaPart, dDtIni, dDtFim, nRet  } )

EndIF

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValDepOutItem

Fun��o auxiliar que buscar� valores de dedu��o de dependentes j� utilizados 
nos demais itens do documento fiscal

@param aNfItem   - Array com informa��es dos itens
@param nItem     - Item que est� sendo processado
@param cTrib     - Tributo que est� sendo processado

@return nRet      - Somat�rio do valor somado de todos os itens, exceto item atual

@author Erick Dias
@since 15/07/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function ValDepOutItem(aNfItem, nItem, cTrib)

Local nX		:= 0
Local nTrbGen	:= 0
Local nRet 		:= 0

//La�o nos itens
For nX :=1 To Len(aNfItem)

	//Somente linhas nao deletadas e n�o pode ser o mesmo item
	If !aNfItem[nX][IT_DELETED] .AND. nItem <> nX 
		
		//Vejo se o tributo existe no item, e obtenho a posi��o dele, j� que n�o necess�riamente ser� a mesma para todos os itens
		IF (nTrbGen	:= aScan(aNfItem[nX][IT_TRIBGEN],{|x| AllTrim(x[TG_IT_SIGLA]) == Alltrim(cTrib)})) > 0
			//Acumulo o valor de dedu��o j� utilizado nos demais itens
			nRet += aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_DED_DEP]
		EndIF
		
	Endif
Next nX						

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DefMunServ

Fun��o que retorna o c�digo de munic�pio com 7 d�gitos do estabelecimento do 
prestador de servi�o, e do local de execu��o de servi�o.

@param aNFCab   - Array com informa��es dos itens
@param cUfEP   - UF do munic�pio do estabelecimento do prestador
@param cMumEP   - Munic�pio do estabelecimento do prestador (5 d�gitos)
@param cUFLES   - UF da execu��o do servi�o
@param cMunLES   - Munic�pio da execu��o do servi�o (5 d�gitos)

@author Erick Dias
@since 21/07/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function DefMunServ(aNFCab, cUfServ, cMumServ, lLES)

Local cCodMunM0	:= Iif(Len(Alltrim(SM0->M0_CODMUN))==5, Alltrim(SM0->M0_CODMUN), Substr(Alltrim(SM0->M0_CODMUN),3,5) )

If lLES //Local de execu��o do servi�o
	//UF e munic�pio do local de execu��o do servi�o
	cUfServ		:= aNFCab[NF_UFPREISS]
	cMumServ	:= aNFCab[NF_CODMUN]
Else
	//UF e munic�pios do estabelecimento do prestador
	cUfServ	:= aNFCab[NF_UFORIGEM]
	cMumServ	:= IIf( aNfCab[NF_OPERNF] == "S" , cCodMunM0 , aNFCab[NF_CODMUN] ) //Sa�da utiliza pr�prio munic�pio, entrada utiliza do participante
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcEscrTG

Fun��o auxiliar para facilitar o preenchimento das refer�ncias do livro dos tributos gen�ricos.

@author Erick Dias
@since 21/0/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function ProcEscrTG(aNfItem, nItem, nTrbGen, cCst, vValTrib, ;
                   nIsento, nOutros, nNaotrib, nDiferido, nMajorado, ;
				   nPerMaj, nPerDif, nPerRed, nPauta, nMva, ;
				   nAuxMva, nAuxMaj, cTabCst, nBaseOri)

aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_CSTCAB]			:= cTabCst
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_CST]			:= cCst
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_VALTRIB]		:= vValTrib
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_ISENTO]			:= nIsento
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_OUTROS]			:= nOutros
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_NAO_TRIBUTADO]	:= nNaotrib
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_DIFERIDO]		:= nDiferido
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_MAJORADO]		:= nMajorado
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_PERC_MAJORACAO]	:= nPerMaj
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_PERC_DIFERIDO]	:= nPerDif
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_PERC_REDUCAO]	:= nPerRed
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_PAUTA]			:= nPauta
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_MVA]			:= nMva
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_AUX_MVA]		:= nAuxMva
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_AUX_MAJORACAO]	:= nAuxMaj
aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_BASE_ORI]	    := nBaseOri

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FisLivroTG

Fun��o que ter� as regras de defini��es da escrtura��o do livro dos 
tributos gen�ricos.
Aqui ser�o realizadas as decis�es para quais colunas os valores dever�o ser gravados

//TODO arredondamento dos valores do livro

@author Erick Dias
@since 21/0/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Function FisLivroTG(aNfItem, nItem, nTrbGen, aNfCab, aMapForm, lEdicao)

Local nIsento 	:= 0 
Local nTribut 	:= 0 
Local nOutros 	:= 0 
Local cCst	  	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_CST]
Local cTabCst  	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_CSTCAB]
Local cIncide 	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_INCIDE]
Local nPercDif	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_PERCDIF]
Local nDiferido	:= 0 
Local nNaotrib	:= 0 //pendente
Local nMajorado	:= 0 
Local nPerMaj   := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_MAJ]
Local nPerRed   := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_REDUCAO]
Local nPauta    := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_PAUTA]
Local nMva      := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_MVA]
Local nAuxMva   := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_AUX_MVA]
Local nAuxMaj   := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_AUX_MAJ]
Local nTrbMaj	:= 0
Local nParcRed	:= 0 //pendente
Local cIncideRed := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_INC_PARC_RED]
Local nBaseOri	:= 0

//----------
//Tributado
//----------
If cIncide == "1" //Tributado	

	//Aqui iniciamos o valor tributado com o resultado da f�rmula NPI
	nTribut	:= aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]
	
	//Aqui preciso verificar se exste diferimento, observando se percentual de diferimento � maior que zero
	If nPercDif > 0
		//Obtem o valor a ser diferido
		nDiferido:= (nTribut /  (1 - (aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_PERCDIF]/100))) - nTribut
	EndIf

	//Aqui posiciono no tributo que efetuou a majora��o, para obter o valor majorado
	If(nTrbMaj 	:= GetPosTrib(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_TRB_MAJ] , aNfItem, nItem)) > 0	
		nMajorado	:= aNfItem[nItem][IT_TRIBGEN][nTrbMaj][TG_IT_LF][TG_LF_VALTRIB] //Considero o valor tributado aqui
	EndIF

//----------
//ISENTO
//----------
ElseIF cIncide == "2" //Isento	
		
	//Verifico se a f�rmula est� preenchida aqui
	If Empty(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FOR_ISE_NPI])
		//Se a f�rmula estiver vazia, ent�o por padr�o ser� adotado a base de c�lculo
		nIsento	:= aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE] //elaborar f�rmula, por enquanto ser� a base de calculo	
	Else
		//Aqui a f�rmula ser� executada
		nIsento	:= xFisExecNPI(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FOR_ISE_NPI], aNFItem, nItem, aMapForm, lEdicao,.T., nTrbGen,, aNfCab)
	EndIF	

//----------
//OUTROS
//----------
ElseIf cIncide == "3" //Outros		
	
	//Verifico se a f�rmula est� preenchida aqui
	If Empty(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FOR_OUT_NPI])
		//Se a f�rmula estiver vazia, ent�o por padr�o ser� adotado a base de c�lculo
		nOutros	:= aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE] //elaborar f�rmula, por enquanto ser� a base de calculo
	Else
		//Aqui a f�rmula ser� executada
		nOutros	:= xFisExecNPI(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FOR_OUT_NPI], aNFItem, nItem, aMapForm, lEdicao,.T., nTrbGen,, aNfCab)
	EndIF

EndIf

//-------------------------------------------
//Verifico se tem redu��o de base de c�lculo
//-------------------------------------------
IF nPerRed > 0	

	//Por padr�o ser� adotado coluna outras
	cIncideRed	:= Iif(Empty(cIncideRed), "2", cIncideRed)

	//Aqui para evitar erros de arredondamento, farei a diferen�a entre a base de c�lculo sem percentual de dedu��o pelo parce�a n�o reduzida
	nBaseOri	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_BASE_ORI]

	//Obtenho a parcela reduzida.
	nParcRed	:= nBaseOri - aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE]
	
	//Se a parcela reduzida for maior que zero ent�o verifico a incid�ncia da redu
	IF nParcRed > 0
	
		If cIncideRed == "1" //Isento
			nIsento += nParcRed
		
		ElseIF cIncideRed == "2" //Outros
			nOutros += nParcRed		
		EndIF

	EndIF	

EndIf

//-------------------------------------------------------------
//Aqui atualizo as refer�ncias do livro dos tributos gen�ricos
//Somente se possuir op��o de incid�ncia definida, caso contr�rio n�o
//preencher� as refer�ncias do livro!
//-------------------------------------------------------------
If !Empty(cIncide)
	ProcEscrTG(aNfItem, nItem, nTrbGen, cCst, nTribut, ;
			nIsento, nOutros, nNaotrib, nDiferido, nMajorado, ;
			nPerMaj, nPercDif, nPerRed, nPauta, nMva, ;
			nAuxMva, nAuxMaj, cTabCst, nBaseOri )
EndIF

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} DeleteCJ3

Fun��o que faz a exclus�o dos dados da tabela CL3.
Aqui a hip�tese para exclus�o � via reprocessamento, j�
que ao excluivr/cancelar uma nota fiscal, apenas preenchemos a data de
exclus�o/cancelamento.

@author Erick Dias
@since 21/0/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Function FisXDelCJ3(cIdTrbGen, nOpcao)

//Verifica se tabela de livro dos tributos gen�ricos existe
If lAliascj3 .and. !Empty(cIdTrbGen) .And. !Empty(nOpcao)  //AliasIndic("CJ3")
	
	dbSelectArea("CJ3")
	dbSetOrder(2)
	
	//Procura pelos tributos para serem alterado como exclu�dos
	IF CJ3->(MsSeek(xFilial("CJ3")+cIdTrbGen))
		
		//La�o para excluir a escritura��o do tributo gen�rico
		While !CJ3->(Eof()) .And. xFilial("CJ3") == CJ3->CJ3_FILIAL .And. cIdTrbGen == CJ3->CJ3_IDTGEN
			
			RecLock("CJ3",.F.)

			If nOpcao == "1" //Exclus�o/cancelamento da nota, apenas atualizo a data de exclus�o
				CJ3->CJ3_DTEXCL := dDataBase
			ElseIf nOpcao == "2" //Exclus�o da CJ3(Reprocessamento)
				CJ3->(dbDelete())
			EndIf

			MsUnLock()
			CJ3->(FkCommit())
			CJ3->(dbSkip())

		EndDo
					
	EndIF

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FisSumTG

Fun��o que faz a soma do valor de cada tributo por item no total
da nota fiscal.

@author Renato Rezende
@since 28/08/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Function FisSumTG(aNfItem, nItem)

Local nTrbGen	:= 0
Local nValBDupl	:= 0

//Percorro todos os tributos gen�ricos do item para carregar os valores
For nTrbGen:= 1 to Len(aNfItem[nItem][IT_TRIBGEN])

	//Tributo gen�rico tratamento de escritura��o do valor total da nota
	//Soma total da NF
	If aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_TOTNF]	$ '5|6'
		aNfItem[nItem][IT_TOTAL] += aNFitem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]

	//Subtrai do total da NF
	ElseIf aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_TOTNF]	$ '2|3'
		aNfItem[nItem][IT_TOTAL] -= aNFitem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]
	EndIf

	//Tratamento para Base da Duplicata
	//Soma total da base da duplicata
	If aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_TOTNF]	$ '6|7'		
		nValBDupl += aNFitem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]

	//Subtrai do total da base da duplicata
	ElseIf aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_TOTNF]	$ '3|4'
		nValBDupl -= aNFitem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]

	//Gross up no total da Duplicata
	ElseIf aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_TOTNF]	$ '8'
		aNfItem[nItem][IT_BASEDUP] := aNfItem[nItem][IT_BASEDUP] / ( 1 - ( aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA] / 100 ) )
	EndIf

Next nTrbGen

//N�o � feito a soma ou a subtra��o da base da duplicata porque � preciso primeiro fazer o Gross up e depois essa opera��o
//Base da Duplicata
If nValBDupl <> 0
	aNfItem[nItem][IT_BASEDUP] += nValBDupl
EndIf

//Tratamento para evitar valor negativo
aNfItem[nItem][IT_BASEDUP]:= Max(aNfItem[nItem][IT_BASEDUP],0)
aNfItem[nItem][IT_TOTAL]:= Max(aNfItem[nItem][IT_TOTAL],0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkTgTot

Fun��o que verifica se existe ao menos algum tributo que altera o valor 
total da nota ou o valor da duplicata. Se existir ent�o retorna verdadeiro

@author Erick Dias
@since 09/03/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Function ChkTgTot(aNfItem, nItem)

Local nTrbGen	:= 0

//Percorro todos os tributos gen�ricos do item para carregar os valores
For nTrbGen:= 1 to Len(aNfItem[nItem][IT_TRIBGEN])

	//Tributo gen�rico tratamento de escritura��o do valor total da nota ou duplicata
	//Soma ou subtrai total da NF ou da duplicata
	If aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_TOTNF]	$ '2|3|4|5|6|7'
		//Se houver ao menos alguma regra que necessidade de alterar valor total ou da duplicata ent�o j� retorno verdadeiro
		Return .T.
	EndIf	

Next nTrbGen

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} xRefTotLf

Fun��o para verifica se foi alterado o total, ou a base da duplicata, 
ou o valor cont�bil para refazer os tributos dependentes das refer�ncias 

@author Renato Rezende
@since 04/09/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Function xRefTotLf(aNfCab, aNfItem, nItem, aPos, aDic, aTGITRef, aHmFor, aDepTrib, aDepVlOrig, aFunc, aUltPesqF2D, dVencReal, nTot )

Local nTotTg	:= 0
Local nTotBD	:= 0

Default nTot	:= 0

//Verifico se algum tributo gen�rico precisa alterar valor total ou de duplicata
If ChkTgTot(aNfItem, nItem)

	nTotTg	:= aNfItem[nItem][IT_TOTAL]
	nTotBD	:= aNfItem[nItem][IT_BASEDUP]	

	//Garantindo a soma no valor total de todos os tributos
	MaFisVTot(nItem)
	
	//Refaz o Livro
	MaFisLF(nItem)	

	//Verifica se o total da nota foi alterado ap�s passar na vTot e na LF
	//Somente farei se o TG alterou o valor total ou se outro tributo alterou o valor total.
	If nTotTg <> aNfItem[nItem][IT_TOTAL] .Or. (nTot > 0 .And. nTot <> aNfItem[nItem][IT_TOTAL])
		xFisTrbGen(aNfCab, @aNfItem, nItem, "IT_TOTAL",,, aPos, aDic, Len(aTGITRef), aHmFor, aDepTrib, aDepVlOrig,aFunc, aUltPesqF2D)
		xFisTrbGen(aNfCab, @aNfItem, nItem, "LF_VALCONT",,, aPos, aDic, Len(aTGITRef), aHmFor, aDepTrib, aDepVlOrig,aFunc, aUltPesqF2D)
	
		//Chama fun��es do legado para atualizar tributos legado que dependem do Total, caso algum tributp gen�rico tenha aterado
		MaFisCOFINS(nItem,"CF3")
		MaFisPIS(nItem,"PS3")
		MaFisFMPEQ(nItem)
		MaFisINSS(nItem,"BSE|VLR")
		MaFisIR(nItem,,dVencReal)
		MaFisISS(nItem)
		MaFisSENAR(nItem)
		MaFisSEST(nItem)
	EndIf

	//Verifica se o total da base da duplicata da nota foi alterado ap�s passar na vTot e na LF
	If nTotBD <> aNfItem[nItem][IT_BASEDUP]						
		xFisTrbGen(aNfCab, @aNfItem, nItem, "IT_BASEDUP",,, aPos, aDic, Len(aTGITRef), aHmFor, aDepTrib, aDepVlOrig,aFunc, aUltPesqF2D)
		
		//Chama fun��es do legado para atualizar tributos legado que dependem do BASEDUP, caso algum tributp gen�rico tenha aterado
		MaFisCIDE(nItem)
		MaFisCOFINS(nItem,"CF2")
		MaFisPIS(nItem,"PS2")
		MaFisCSLL(nItem)
		MaFisISS(nItem)
	EndIf

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisAddGNRE

Fun��o que efetua a grava��o da GNRE para os tributos gen�ricos.
Aqui buscaremos os valores calculados pelo configurador
e faremos a gera��o da SF6 conforme regras cadastradas pelo usu�rio nas
regras de GNRE do configuradr.

@param nRecnoNF - recno da nota fiscal
@param cAlias - alias da nota fiscal.

@author Erick Dias
@since 21/09/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Function xFisAddGNRE(nRecnoNF, cAlias, aTGCalcRec)

Local cDoc 	  	:= ""
Local cSerie  	:= ""
Local cPart	  	:= ""
Local cLoja	  	:= ""
Local cOperNF	:= ""
Local cSDoc		:= ""
Local cNumGNRE 	:= ""
Local cTributo  := ""
Local cTipoDoc 	:= ""
Local cIdNf     := ""
Local cTipoImp	:= "D" //Tributos gen�ricos
Local cEstNF 	:= ""
Local cEst 		:= ""
Local cEstOri 	:= ""
Local cEstDest	:= ""
Local cTipoNF	:= ""
Local cInscPart := ""
Local cInsc 	:= ""
Local cCNPJPart	:= ""
Local cCNPJ		:= ""
Local cModelo	:= ""
Local cCodrec	:= ""
Local cDetalhe	:= ""
Local cRef		:= ""
Local cMvEstado := GetNewPar("MV_ESTADO","")
Local dDtArrec  := dDataBase
Local aTGCalc	:= {}
Local aCodrec	:= {"","",""}
Local nMes		:= 0
Local nAno		:= 0
Local nValor 	:= 0
Local nX		:= 0
Local nPosTrib  := 0
Local oModel	:= Nil 
Local dDtPadrao	:= DataValida( LastDay( dDataBase ) + 1, .T.) //Inicio com padr�o do primeiro dia �til do pr�ximo m�s
Local dDtVenc	:= CTOD("//")
Local lCodrec	:= FindFunction("CodRec")

//Somente prosseguirei com o recno da nota e o alias preenchidos!
If Empty(nRecnoNF) .Or. Empty(cAlias)
	Return
EndIF

//Se o campo n�o existir n�o processarei gera��o das guias
IF !SF6->(FieldPos("F6_IDNF")) > 0
	Return
EndIF

//Verifico se o alias � algum que est� previsto nesta fun��o, caso contr�rio n�o continuara
IF cAlias <> "SF2" .AND. cAlias <> "SF1"
	Return
EndIF

//Aqui verifico se existe a refer�ncia e se ela est� preenchida antes de continuar
If Empty(MaFisScan("NF_TRIBGEN",.F.))
	Return	
EndIf

//Posiciono aqui a tabela para obter informa��es
dbSelectArea(cAlias)
MsGoto(nRecnoNF)

//A partir daqui podemos obter as informa��es necess�rias da nota para gerar a GNRE
//Por enquanto a rotina apenas trata as informa��es:
//-Nota de Sa�da
//-Nota de Entrada
IF cAlias == "SF2"
	cDoc 	 := SF2->F2_DOC
	cSerie 	 := SF2->F2_SERIE
	cPart 	 := SF2->F2_CLIENTE
	cLoja 	 := SF2->F2_LOJA	
	cEstNF 	 := SF2->F2_EST
	cTipoDoc := SF2->F2_TIPO
	cIdNf	 := SF2->F2_IDNF	     
	cTipoNf  := SF2->F2_TIPO  
 	cEstOri  := SF2->F2_UFORIG
 	cEstDest := SF2->F2_UFDEST
	cOperNF  := "2" //Sa�da
	cModelo	 := AModNot(Alltrim(SF2->F2_ESPECIE))
	nMes     := Month(SF2->F2_EMISSAO)
	nAno     := Year(SF2->F2_EMISSAO)

	If SA1->(MsSeek(xFilial("SA1")+cPart+cLoja))
		cInscPart := SA1->A1_INSCR
		cCNPJ := SA1->A1_CGC
	EndIf

ElseIF cAlias == "SF1"
	cDoc   	 := SF1->F1_DOC
	cSerie 	 := SF1->F1_SERIE
	cPart  	 := SF1->F1_FORNECE
	cLoja  	 := SF1->F1_LOJA	
	cEstNF   := SF1->F1_EST
	cTipoDoc := SF1->F1_TIPO
	cIdNf	 := SF1->F1_IDNF	
	cTipoNf  := SF1->F1_TIPO 
	cEstOri  := Iif(Empty(SF1->F1_UFORITR), SF1->F1_EST , SF1->F1_UFORITR) 
	cModelo	 := AModNot(Alltrim(SF1->F1_ESPECIE))
 	cEstDest := SF1->F1_ESTDES  
	cOperNF  := "1" //Entrada
	nMes 	 := Month(SF1->F1_EMISSAO)
	nAno 	 := Year(SF1->F1_EMISSAO)

	If SA2->(MsSeek(xFilial("SA2")+cPart+cLoja))
		cInscPart := SA2->A2_INSCR
		cCNPJ := SA2->A2_CGC
	EndIf

EndIF

//Para o tipo de devolu��o n�o gerarei GNRE
If cTipoNf == "D"
	Return 
EndIf

//Tratamento para obter o SDOC
If SerieNfId("SF6",3,"F6_SERIE") == "F6_SDOC"
	cSDoc	:=	SubStr(cSerie,1,3)
EndIf

//Obtenho o c�lculo dos tibutos gen�ricos
aTGCalc := MaFisRet(,"NF_TRIBGEN")

//La�o nos tributos gen�rico para verificar se possui regra de gera��o de GNRE
For nX := 1 to Len(aTGCalc)

	//Obtem o tributo
	cTributo	:= aTGCalc[nX][1]

	nValor	:= aTGCalc[nX][3] 
	If Len(aTGCalc[nX]) >= 10 .And. CJ4->CJ4_MAJSEP == "1"
		nValor	:= nValor -  aTGCalc[nX][10]
	EndIf

	//Primeiro vejo se tem regra de guia vinculada
	//Se tem regra de guia vinculada, preciso ent�o posicionar para certificar se a nota se enquadra na configura��o da regra
	If Len(aTGCalc[nX]) >=9 .And. EnqNFGNRE(aTGCalc[nX][9], cEstNF, cOperNF) .And. nValor > 0		

		//Irei verificar se este tributo j� gerou t�tulo de recolhimento, se sim, ent�o vou considerar o mesmo n�mero, caso contr�rio pegarei pr�ximo n�mero		
		If (nPosTrib	:=  AScan(aTGCalcRec, { |x| Len(x) >=7 .AND. Alltrim(x[7]) == Alltrim(cTributo)})) > 0
			//Estou utilizando mesmo n�mero utilizado no t�tulo de recolhimento
			cNumGNRE	:= aTGCalcRec[nPosTrib][3]
		Else
			//O tributo n�o gerou t�tulo, logo precisarei buscar o pr�ximo n�mero sequencial da SX5.
			cNumGNRE	:= FisTitTG()
		EndIf		

		//-------------------------------
		//Defini��o do vencimento da Guia
		//-------------------------------		
		dDtVenc := xFisDtGnre(dDtPadrao)
	
		//-----------------------
		//Defini��o da UF da Guia
		//-----------------------
		cEst	:= cEstNF
		If CJ4->CJ4_UF == "1"
			//UF do MV_ESTADO
			cEst	:= cMvEstado

		ElseIf CJ4->CJ4_UF == "2"
			//UF Origem
			cEst	:= cEstOri

		ElseIf CJ4->CJ4_UF == "3"
			//UF Destino
			cEst	:= cEstDest

		ElseIf CJ4->CJ4_UF == "4"
			//UF da Nota Fiscal
			cEst	:= cEstNF
			
		EndIF

		//------------------
		//Defini��o do CNPJ
		//------------------
		If CJ4->CJ4_CNPJ == "1"
			//CNPJ Participante
			cCNPJ	:= cCNPJPart
		EndIF	

		//--------------------------------
		//Defini��o da Inscri��o Estadual
		//--------------------------------
		If CJ4->CJ4_IEGUIA == "1"
			//Participante
			cInsc	:= cInscPart

		ElseIf CJ4->CJ4_IEGUIA == "2"
			//SIgamat
			cInsc := SM0->M0_INSC

		ElseIf CJ4->CJ4_IEGUIA == "3"
			//IE do Estado
			cInsc := IESubTrib(cEstDest,.T.)
		EndIF

		//Chamo fun��o responsavel por definir dados referente a C�digo de Receita
		IF lCodrec
			aCodrec  := CodRec(cTributo, cEst, cModelo)
		Endif		
		cCodrec  := aCodrec[1]
		cDetalhe := aCodrec[2]
		cRef	 := aCodrec[3]
		
		
		//Aqui tenho em m�os todas as informa��es para gerar a Guia:
		oModel    := FWLoadModel('MATA960')
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()
		
		//Para essa opera��o � preciso especificar qual o modelo que queremos inserir o valor
		oModel:SetValue("MATA960MOD","F6_NUMERO"  , cNumGNRE)
		oModel:SetValue("MATA960MOD","F6_TIPOIMP" , cTipoImp)
		oModel:SetValue("MATA960MOD","F6_VALOR"   , nValor)
		oModel:SetValue("MATA960MOD","F6_DTARREC" , dDtArrec)
		oModel:SetValue("MATA960MOD","F6_DOC"     , cDoc)
		oModel:SetValue("MATA960MOD","F6_SERIE"   , cSerie)
		oModel:SetValue("MATA960MOD","F6_CLIFOR"  , cPart)
		oModel:SetValue("MATA960MOD","F6_LOJA"    , cLoja)
		oModel:SetValue("MATA960MOD","F6_OPERNF"  , cOperNF)
		oModel:SetValue("MATA960MOD","F6_MESREF"  , nMes)		
		oModel:SetValue("MATA960MOD","F6_ANOREF"  , nAno)
		oModel:SetValue("MATA960MOD","F6_TIPODOC" , cTipoDoc)		
		oModel:SetValue("MATA960MOD","F6_TRIB"    , cTributo)
		oModel:SetValue("MATA960MOD","F6_IDNF"    , cIdNf)
		oModel:SetValue("MATA960MOD","F6_EST"     , cEst)
		oModel:SetValue("MATA960MOD","F6_DTVENC"  , Iif(Empty(dDtVenc), dDtPadrao,dDtVenc ) )
		oModel:SetValue("MATA960MOD","F6_DTPAGTO" , dDtVenc)
		oModel:SetValue("MATA960MOD","F6_INSC"    , cInsc)
		oModel:SetValue("MATA960MOD","F6_CNPJ"    , cCNPJ)
		oModel:SetValue("MATA960MOD","F6_CODREC"  , cCodrec)
		oModel:SetValue("MATA960MOD","F6_DETRECE" , cDetalhe)
		oModel:SetValue("MATA960MOD","F6_REF"  	  , cRef)
		If !Empty(cSDoc)
			oModel:SetValue("MATA960MOD","F6_SDOC"    , cSDoc)
		EndIF

		//Verifica se deseja visualizar/alterar a Guia gerada
		//Aqui posso verifica a CJ4 pois a fun��o EnqNFGNRE() j� posicionou esta tabela
		IF CJ4->CJ4_VTELA == "1" .AND. !IsBlind()
			FWExecView( cTributo ,"MATA960", MODEL_OPERATION_INSERT, , { ||.T. } ,{ || .T.},,,,,,oModel )
		Else
			If oModel:VldData()
				oModel:CommitData()
				
			Else		
				//Aqui exibo erro, pois ocorreu algum erro de valida��o do modelo
				VarInfo("",oModel:GetErrorMessage())			
			EndIf
		EndIF		

		//Desativo e destruo o objeto aqui
		oModel:DeActivate()
		oModel:Destroy()	

		//Aqui realizamos a Grava��o da CDC, caso esteja configurada na regra de Guia.
		IF !EMPTY(CJ4->CJ4_INFCOM )
			GrvCDC( Iif(cOperNF == "1", "E", "S") , cDoc, cSerie, cPart, cLoja, cNumGNRE, cEstNF, CJ4->CJ4_INFCOM)
		EndIf

	EndIf	

Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} EnqNFGNRE

Fun��o que far� enquadramento da regra de gera��o de GNRE por nota fiscal.
Aqui ser� verificado se a guia deve ou n�o ser gerada em fun��o das infora��es
da nota fiscal.

@param cCodRegra - C�digo da regra de guia
@param cEst - Estado da nota fiscal
@param cOperNF - Opera��o da NF (1- Entrada; 2- Sa�da)

@return lRet - Retorna verdadeiro se a GNRE deve ser gerada.

CJ4_MODO 1=Nota Fiscal;2=Apura��o                                                                                                        
CJ4_ORIDES 1=Somente Interestadual;2=Somente Municipal;3=Indiferente                                                                       
CJ4_IMPEXP 1=Somente Importa��o;2=Somente Exporta��o;3=Indiferente                                                                         
CJ4_IE 1=Possui IE;2=N�o Possui IE;3=Indiferente                                                                                       
CJ4_VTELA 1=Sim;2=N�o   

@author Erick Dias
@since 22/09/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function EnqNFGNRE(cCodRegra, cEst, cOperNF)

Local lRet 		:= .F.
Local cMvEstado := GetNewPar("MV_ESTADO","")

//Primeiro posiciono e verifico se a regra de guia � para nota fiscal
If !Empty(cCodRegra) .AND. CJ4->(MsSeek(xFilial("CJ4") + cCodRegra )) .AND. CJ4->CJ4_MODO == "1"

	//------------------------------------
	//Verifica��o de interno/interestadual
	//------------------------------------
	lRet	:= .F.
	If CJ4->CJ4_ORIDES == "1"
		//Aqui somente opera��es interestaduais	
		lRet	:= cMvEstado <> cEst

	ElseIf CJ4->CJ4_ORIDES == "2"
		//Aqui somente opera��es internas
		lRet	:= cMvEstado == cEst

	ElseIf CJ4->CJ4_ORIDES == "3" .OR. Empty(CJ4->CJ4_ORIDES)
		//Indiferente, este campo n�o influenciar�
		lRet	:= .T.
	EndIF

	//---------------------------------
	//Verifica��o inscrito/n�o inscrito
	//---------------------------------
	If lRet
		
		If CJ4->CJ4_IE == "1"
			//Aqui para os estados que o contribuinte � inscrito
			lRet	:=  !Empty( IESubTrib( Iif(cOperNF == "1",cMvEstado, cEst )) )

		ElseIf CJ4->CJ4_IE == "2"
			//Aqui para os estados que o contribuinte N�O � inscrito
			lRet	:=  Empty( IESubTrib( Iif(cOperNF == "1",cMvEstado, cEst )) )

		ElseIf CJ4->CJ4_IE == "3" .OR. Empty(CJ4->CJ4_IE)
			//Indiferente, este campo n�o influenciar�
			lRet	:= .T.
		EndIF

	EndIF		

	//-------------------------------------
	//Verifica��o de importa��o/exporta��o
	//-------------------------------------
	If lRet
		
		If (CJ4->CJ4_IMPEXP == "1" .AND. cOperNF == "1") .Or. (CJ4->CJ4_IMPEXP == "2" .AND. cOperNF == "2")
			//Aqui somente importa��o/exporta��o, UF destino deve ser EX
			lRet	:= cEst	== "EX"

		ElseIf CJ4->CJ4_IMPEXP == "3"  .OR. Empty(CJ4->CJ4_IMPEXP)
			//Indiferente, este campo n�o influenciar�
			lRet	:= .T.
		EndIF

	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FisDelSF6NF

Fun��o que ir� deletar as guias geradas por nota fiscal dos tributos
calculados pelo confiutador de tributos.  A fun��o receber� o ID da nota
que ser� exclu�da, e deletar� todas as guias da nota em quest�o.

@param cIdNF - Id da nota fiscal

@author Erick Dias
@since 22/09/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Function FisDelSF6NF(cIdNF)

Local cChvSF6	:= xFilial("SF6") + cIdNF
Local oModel	:= nil

//Verifico se o ID est� devidamente preenchido
If !Empty(cIdNF)

	dbSelectArea("SF6")
	SF6->(dbSetOrder(8)) //F6_FILIAL + F6_IDNF

	DbSelectArea("CDC")
	CDC->(DbSetOrder(1))//Indice CDC_FILIAL+CDC_TPMOV+CDC_DOC+CDC_SERIE+CDC_CLIFOR+CDC_LOJA+CDC_GUIA+CDC_UF

	//La�o nas guias que tiverem este ID, ser�o deletadas!
	If SF6->(MsSeek( cChvSF6 ))
		While !SF6->(EoF()) .And. SF6->(F6_FILIAL + F6_IDNF) == cChvSF6
			
			//Aqui deleto as informa��es do complemento da CDC antes de deletar a SF6.
			If CDC->(dbSeek( xFilial("CDC")+ Iif(SF6->F6_OPERNF == "1", "E", "S") + SF6->F6_DOC + SF6->F6_SERIE + SF6->F6_CLIFOR + SF6->F6_LOJA + SF6->F6_NUMERO + SF6->F6_EST ))
				RecLock("CDC", .F.)				
				CDC->(dbDelete())
				CDC->(MsUnLock())
			Endif

			//Prossigo com a dele��o da SF6.
			oModel := FWLoadModel("MATA960")
            oModel:SetOperation( MODEL_OPERATION_DELETE )
			oModel:Activate() 			
        
        	If oModel:VldData()
            	lRet := FWFormCommit( oModel )
	        EndIf
        
			oModel:Deactivate()
			SF6->(dbSkip())			
		EndDo
	EndIf

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCDC

Fun��o que far� grava��o da tabela CDC no momento de gera��o da SF6, caso 
tenha uma regra configurada para gravar o complemento.

@author Erick Dias
@since 23/09/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function GrvCDC(cTpMov, cDoc, cSerie, cPart, cLoja, cGuia, cUF, cCodInfComp)

//Verifico se para a nota em quest�o j� n�o gravou CDC.

dbSelectArea("CDC")
CDC->(DbSetOrder(1))//CDC_FILIAL+CDC_TPMOV+CDC_DOC+CDC_SERIE+CDC_CLIFOR+CDC_LOJA+CDC_GUIA+CDC_UF
If !DbSeek( xFilial("CDC") + cTpMov + cDoc + cSerie + cPart + cLoja + cGuia + cUF )
	RecLock("CDC",.T.)
	CDC_FILIAL := xFilial("CDC")
	CDC_TPMOV  := cTpMov
	CDC_DOC    := cDoc
	SerieNfId("CDC",1,"CDC_SERIE",,,,cSerie)
	CDC_CLIFOR := cPart
	CDC_LOJA   := cLoja
	CDC_GUIA   := cGuia
	CDC_UF     := cUF
	CDC_IFCOMP := cCodInfComp
	CDC->(MsUnlock())
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ObtemData

Fun��o auxiliar para realizar a soma de dias �teis na data de vencimento
da Guia

@param nQtdeDia - Quantidade de dias a ser somado
@param dDataRef - Data atual de refer�ncia

@return dDataRef - data v�lida

@author Erick Dias
@since 24/09/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function ObtemData(nQtdeDia,dDataRef) 

//Se n�o houver dias a serem somados, retorno o mesmo dia.
IF nQtdeDia == 0
	Return dDataRef
EndIf

//La�o para obter o dia v�lido
While nQtdeDia > 0

	//Verifico pr�ximo dia
	dDataRef +=1

	//Verifico se a data � v�lida
	IF DataValida(dDataRef,.T.) == dDataRef
		//Somo 1 dia e diminuo 1 dia do contador		
		nQtdeDia -=1
	EndIF

EndDo
    
Return dDataRef

//-------------------------------------------------------------------
/*/{Protheus.doc} DiaFixoSub

Fun��o auxiliar para obter o dia util fixo do m�s subsequente

@param nDia - Dia 

@return dDtVenc - data v�lida

@author Erick Dias
@since 24/09/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function DiaFixoSub(nDia, nOpc)

Local dDtVenc	:= nil
Local dDtProximo	:= MonthSum(dDatabase, 1)

//Se o dia for maior que pr�ximo m�s, por padr�o vai considerar primeiro dia �ltimo do pr�ximo m�s
IF nDia > Day(LastDay(dDtProximo))
	Return DataValida(LastDay(dDtProximo) + 1, .T.)  
EndIF

//Aqui � dia fixo do m�s Subsequente						
dDtVenc	:= CToD( cvaltochar(nDia) + "/" + StrZero(Month( dDtProximo) ,2)  + "/" + StrZero(Year( dDtProximo) ,4)  )

//Somo mais 1 m�s na data atual
dDtVenc	:= MonthSum(dDtVenc, 1)						
//Pego pr�xima data v�lida no m�s subsequente
dDtvenc := DataValida(dDtVenc, .T.)

Return dDtVenc

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisDtGnre

Fun��o auxiliar para encapsular a regra de vencimento da CJ4 

@author Erick Dias
@since 25/09/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Function xFisDtGnre(dDtPadrao)
Local dDtVenc	:= CTOD("//")

//-------------------------------
//Defini��o do vencimento da Guia
//-------------------------------		
IF CJ4->CJ4_CFVENC == "1"
	
	//Aqui � op��o de somar dias �teis
	dDtVenc := ObtemData(CJ4->CJ4_QTDDIA, dDatabase)

ElseIF CJ4->CJ4_CFVENC == "2"
	
	//Dia fixo maior que o n�mero de dias do m�s, exemplo dia 31 no m�s de novembro...ou 30 de fevereiro...
	If CJ4->CJ4_DTFIXA > Day(LastDay(dDatabase)) 						
		//Retorna primeiro dia �til do pr�ximo m�s
		dDtVenc 	:= dDtPadrao
	Else			
		//Aqui � dia fixo do m�s atual			
		dDtVenc := DataValida(CToD( cvaltochar(CJ4->CJ4_DTFIXA) + "/" + StrZero(Month(dDatabase),2) + "/" + StrZero(Year(dDatabase),4) ), .T.)			
					
		//Verifica se a data � inferior a data atual...nesse caso gerarei para pr�ximo m�s
		If dDtVenc < dDatabase			
			//Por padr�a adotar� aqui o dia fixo do m�s Subsequente						
			dDtVenc	:= DiaFixoSub(CJ4->CJ4_DTFIXA)
		EndIF

	EndIF

ElseIF CJ4->CJ4_CFVENC == "3"			
	//Aqui � dia fixo do m�s Subsequente						
	dDtVenc	:= DiaFixoSub(CJ4->CJ4_DTFIXA)			
EndIF

Return dDtVenc


//-------------------------------------------------------------------
/*/{Protheus.doc} GetUltAqui

Fun��o auxiliar para encapsular a regra de vencimento da CJ4 

@param - c�digo do produto a ser verificado

@author Erick Dias
@since 02/10/20
@version 12.1.31
/*/
//-------------------------------------------------------------------
Function GetUltAqui(cCodProd,aNfCab,aNfItem,nItem,nTrbGen,cDocSai,cSerie,cCliFor,cLoja,nCaso)

Local cSelect	:= ""
Local cFrom		:= ""
Local cWhere	:= ""
Local cQuery    := ""
Local cTpDb		:= tcgetdb()
Local cAliasQry	:= ""
Local nX		:= 0
Local nIcmsUnit := 0
Local nIcmsEst  := 0
Local aUltAq 	:= {}
Local aBind		:= {}
Local nQuantSai	:= 0
Local nItemSai	:= 0

Default cCodProd := ""
Default dDtEmiss  := "" 

//Verifico se c�digo est� preenchido
If Empty(cCodProd)
	Return 0
EndIF

//Verifica se query est� no cache. Se estiver basta retornar os valores
If (nX := aScan(aPesqSD1,{|x| x[1] == cCodProd})) > 0 .and. Alltrim(cDocSai) = ""
	
	//Aqui apenas retorno a posi��o do produto, pois  query j� foi feita para este produto.
	Return nX

Else
		
	//DO contr�rio preciusarei fazer query para buscar a �ltima aquisi��o
	cAliasQry := GetNextAlias()

	If cTpDb $ "ORACLE/POSTGRES/MYSQL"
		cSelect += "SELECT  "
	Else
		cSelect += "SELECT TOP 1 "
    Endif

	cSelect	+= " SD1.D1_CUSTO,	    SD1.D1_VALDESC, "
	cSelect	+= " SD1.D1_QUANT,  	SD1.D1_MARGEM, "
	cSelect += " SD1.D1_VUNIT, 		SD1.D1_VALANTI, "
	cSelect += " SD1.D1_BRICMS, 	SD1.D1_ICMSRET, "
	cSelect += " SD1.D1_ALIQSOL, 	SD1.D1_BASNDES, "
	cSelect += " SD1.D1_ICMNDES, 	SD1.D1_ALQNDES, "
	cSelect += " SD1.D1_FCPAUX , 	SD1.D1_VALICM,  "
	cSelect += " SD1.D1_VFCPANT, 	SD1.D1_BFCPANT, "
	cSelect += " SD1.D1_AFCPANT, 	SD1.D1_VFECPST, "
	cSelect += " SD1.D1_BSFCPST, 	SD1.D1_ALFCPST, "
	cSelect += " SD1.D1_BASEICM, 	SD1.D1_PICM,	"
	cSelect += " SD1.D1_DOC, 	    SD1.D1_SERIE,	"
	cSelect += " SD1.D1_FORNECE, 	SD1.D1_LOJA,	"
	cSelect += " SD1.D1_DTDIGIT, 	SD1.D1_LOTECTL,	"
	cSelect += " SD1.D1_UM, 	    SD1.D1_SEGUM,      SD1.D1_QTSEGUM "
		

	cFrom   += "FROM " + RetSQLName("SD1") + " SD1 "

	cWhere  += " WHERE SD1.D1_FILIAL  = ? AND "
	cWhere  += "SD1.D1_COD     = ? AND "
	cWhere  += "SD1.D1_NFORI   = ' ' AND "
	cWhere  += "SD1.D1_SERIORI = ' ' AND "
	cWhere  += "SD1.D1_TIPO = 'N' AND "
	cWhere  += "SD1.D_E_L_E_T_ = ' ' "

	cWhere  += " ORDER BY SD1.D1_DTDIGIT DESC, SD1.D1_NUMSEQ DESC "

	If cTpDb == "ORACLE"
		cWhere  += " FETCH FIRST 1 ROWS ONLY "

	ElseIF (cTpDb == "POSTGRES" .OR. cTpDb == "MYSQL")
		cWhere  += " LIMIT 1 "

	EndIf

	cQuery := cSelect + cFrom + cWhere

	aadd(aBind, xFilial("SD1"))
	aadd(aBind, cCodProd)

	dbUseArea(.T.,"TOPCONN",TcGenQry2(,,cQuery,aBind),cAliasQry,.T.,.F.)

	//Laco da query e obtem os valores da �ltima aquisi��o.
	(cAliasQry)->(DBGoTop())
	IF !(cAliasQry)->(Eof())
		
		//Preencho o array com a informa��o da �ltima entrada
		If Alltrim(cDocSai) = ""
			aAdd(aPesqSD1,{	cCodProd,; 
							(cAliasQry)->D1_CUSTO,  (cAliasQry)->D1_VALDESC, (cAliasQry)->D1_MARGEM,  (cAliasQry)->D1_QUANT,;
							(cAliasQry)->D1_VUNIT,  (cAliasQry)->D1_VALANTI, (cAliasQry)->D1_VALICM,  (cAliasQry)->D1_FCPAUX,;
							(cAliasQry)->D1_BRICMS, (cAliasQry)->D1_ALIQSOL, (cAliasQry)->D1_ICMSRET, (cAliasQry)->D1_BSFCPST,;
							(cAliasQry)->D1_ALFCPST,(cAliasQry)->D1_VFECPST, (cAliasQry)->D1_BASNDES, (cAliasQry)->D1_ALQNDES,;
							(cAliasQry)->D1_ICMNDES,(cAliasQry)->D1_BFCPANT, (cAliasQry)->D1_AFCPANT, (cAliasQry)->D1_VFCPANT,;
							(cAliasQry)->D1_BASEICM, (cAliasQry)->D1_PICM })
			nX	:= Len(aPesqSD1)
		Endif

		if !Empty(cDocSai) .and. nCaso == 1

				nQuantSai:= aNfItem[nItem][IT_QUANT]
				nItemSai := aNfItem[nItem][IT_ITEM]
				nIcmsEst := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]
				nIcmsUnit:= ((cAliasQry)->D1_VALICM / (cAliasQry)->D1_QUANT)
				
				
				Aadd(aUltAq,{(cAliasQry)->D1_DOC,;     //1
					(cAliasQry)->D1_SERIE,;   //2
					cCodProd,;   //3
					(cAliasQry)->D1_FORNECE,;   //4
					(cAliasQry)->D1_LOJA ,;   //5
					(cAliasQry)->D1_DTDIGIT,;   //6
					Alltrim((cAliasQry)->D1_LOTECTL),;   //7
					(cAliasQry)->D1_UM,;   //8
					(cAliasQry)->D1_SEGUM,;   //9
					(cAliasQry)->D1_QTSEGUM,;   //10
					"",;   //11
					0,;   //12
					"",;   //13
					nIcmsUnit,;   //14
					nIcmsEst})    //15

				GravaCJM(aUltAq, cCodProd, nQuantSai,nItemSai,aNfCab[NF_DTEMISS],cDocSai,cSerie, cCliFor ,cLoja)

		Endif

	EndIF

	//Fecho area.	
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbCloseArea())

EndIF

Return nX


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadFCA

Fun��o responsavel por indice referente a Indicadores Econ�micos FCA

@param aNfCab	 - Cabe�alho da nota
@param aNFItem	 - Itens da nota
@param nItem	 - Item em procesamento


@author Rfaael Oliveira
@since 02/10/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------

Static function LoadFCA(aNfCab, aNFItem, nItem)

Local nIndice  := 0
Local aAreaSD2 := {}
Local nX	   := 0

//Verifico se j� realizei a busca no array com cache
/*
Estrutura do array 
1-Estado destino
2-Mes opera��o
3-Ano da Opera��o
4-RECNO Origem
5-Valor
*/

nX := aScan(aPesqF0R,{|x| x[1] == aNFCab[NF_UFDEST] .And. ;
                          x[2] == Month(aNfCab[NF_DTEMISS]) .And. ;
						  x[3] == Year(aNfCab[NF_DTEMISS]) .And. ;
						  x[4] == aNFItem[nItem][IT_RECORI]})
						  

//Verifica se query est� no cache. Se estiver basta retornar os valores
IF nX > 0

	//Aqui apenas retorno o valor
	Return	aPesqF0R[nX][5]	

		// Processa somente se existir nota de Origem e indice da nota atual
Elseif !Empty(aNFItem[nItem][IT_RECORI]) .and. aNfItem[nItem][IT_INDICE] <> 0 
	
	
	//Guarda Area da SD2
	aAreaSD2   := SD2->(GetArea())

	//Se possiciona na nota de origem
	DbSelectArea("SD2")
	MsGoto(aNFItem[nItem][IT_RECORI])

	IF Month(SD2->D2_EMISSAO)  <>  Month(aNfCab[NF_DTEMISS]) .Or. Year(SD2->D2_EMISSAO)  <>  Year(aNfCab[NF_DTEMISS])

		//Localiza indice do periodo da nota de Origem
		F0R->(dbSetOrder(1)) //F0R_FILIAL+F0R_UF+F0R_PERIOD
		If F0R->(MsSeek(xFilial("F0R")+aNFCab[NF_UFDEST]+AnoMes(SD2->D2_EMISSAO)))
			nIndice := aNFCab[NF_INDICE]/F0R->F0R_INDICE
		EndIf
	Endif
		
	//Restaura a area da SD2
	RestArea(aAreaSD2)
Endif

//Aqui adiciono pesquisa no cache para n�o ser refeito posteriormente
aAdd(aPesqF0R,{aNFCab[NF_UFDEST], Month(aNfCab[NF_DTEMISS]), Year(aNfCab[NF_DTEMISS]), aNFItem[nItem][IT_RECORI], nIndice  } )

Return nIndice

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkCfgTrib

Verifica se a guia que est� sendo gerada para um tributo consta na lista do Configurador de Tributos. 

@param cOrigem	 - Rotina de Origem - MATA103 ou MATA460A
@param cImp  	 - C�digo do imposto
@param nTitICMS	 - Valor do t�tulo de ICMS
@param nTitST	 - Valor do t�tulo de ICMS-ST
@param lFECP	 - Identifica se a guia a ser gerada � de FECP Complementar
@param lDifAl	 - Identifica se a guia a ser gerada � de Difal
@param cItemNF	 - Identifica a posicao do item na nota

@author leandro.faggyas
@since 09/04/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function ChkCfgTrib(cOrigem, cImp, nTitICMS, nTitST, lFECP, lDifAl,cItemNF)
Local nValGuia  := 0
Local aTribGen  := {}
Local cIdTrib   := ""
Local lTribGen  := .F.
Local nPosTrib  := 0

Default cOrigem  := ""
Default cImp     := ""
Default nTitICMS := 0
Default nTitST   := 0
Default lFECP    := .F.
Default lDifAlq  := .F.
Default cItemNF  := ""

DbSelectArea("F2B")
F2B->(DbSetOrder(1)) //F2B_FILIAL, F2B_REGRA, F2B_VIGINI, F2B_VIGFIM, F2B_ALTERA
DbSelectArea("F2E")
F2E->(DbSetOrder(2)) //F2E_FILIAL, F2E_TRIB
DbSelectArea("CJ4")
CJ4->(DbSetOrder(1)) //CJ4_FILIAL, CJ4_CODIGO

aTribGen := MaFisRet(,"NF_TRIBGEN")
	
Do Case
	Case cImp=="IC" .And. nTitICMS > 0
		cIdTrib  := "000021" //ICMS
	Case cImp=="IC" .And. nTitST > 0 
		If lFECP
			If cOrigem == "MATA103"
				cIdTrib  := "000041" //FCPST
				nValGuia := nTitST
			Else
				cIdTrib  := "000042" //FCPCMP
				nValGuia := SF3->F3_VFCPDIF
			EndIf
		ElseIf lDifAl
			cIdTrib  := "000037" //DIFAL
			nValGuia := IIF(cOrigem == "MATA103",nTitST,SF3->F3_DIFAL)
		Else
			cIdTrib  := "000056" //ICMSST
			nValGuia := IIF(cOrigem == "MATA103",SF1->F1_ICMSRET,SF2->F2_ICMSRET)
		EndIf
	Case cImp=="IP" .Or. cImp=="SI"
		cIdTrib  := "000022" //IPI
	Case cImp=="IS"
		cIdTrib  := "000020" //ISS
	Case cImp=="FD"
		cIdTrib  := "000010" //FUNDERSUL
	Case cImp=="SE"
		cIdTrib  := "000013" //SEST/SENAT
	Case cImp=="SN"
		cIdTrib  := "000003" //SENAR					
	Case cImp=="PR"
		cIdTrib  := "000027" //PROTEGE	
	Case cImp=="FEEF"
		cIdTrib  := "000025" //FEEF
EndCase

nPosTrib := aScan(aTribGen, {|x| x[TG_NF_IDTRIB] = cIdTrib })
If nPosTrib > 0
	If cIdTrib == "000021"	//ICMS
		nValGuia := MaFisRet(,"NF_VALICM")
		If aTribGen[nPosTrib,TG_NF_VALOR] <> nValGuia  //Verifico se o valor das guias de recolhimento ser� calculado integralmente atrav�s do configurador
			nTitICMS := Abs(aTribGen[nPosTrib,TG_NF_VALOR] - nValGuia )
		Else
			lTribGen := .T.
		EndIf

	ElseIf cIdTrib $ "000037|000041|000042|000056" //DIFAL/FCPST/FCPCMP/ICMSST
		If !Empty(cItemNF) 
			lTribGen := ChkTGItem( cIdTrib, DecodSoma1(cItemNF)  )
		Else
			If aTribGen[nPosTrib,TG_NF_VALOR] <> nValGuia //Verifico se o valor das guias de recolhimento ser� calculado integralmente atrav�s do configurador
				nTitST   := Abs(aTribGen[nPosTrib,TG_NF_VALOR] - nValGuia)
			Else
				lTribGen := .T.
			EndIf
		EndIf
	Else
		lTribGen := .T.
	EndIf
EndIf

Return lTribGen

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkTGItem

Verifica se determinado imposto gen�rico est� sendo calculado para determinado item.

@param cIdTrib	 - ID do Tributo segundo o campo F2E_IDTRIB
@param nItem  	 - Numero do item a ser pesquisado.

@author leandro.faggyas
@since 29/04/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function ChkTGItem( cIdTrib, nItem  )
Local lRet      := .F.
Local aTgItem   := {}
Local nPosIt    := 0

Default cIdTrib := ""
Default nItem   := 0

If nItem > 0
	aTgItem := MaFisRet(nItem,"IT_TRIBGEN")
EndIf
						
If Len(aTgItem) > 0 .And. !Empty(cIdTrib)
	nPosIt := aScan(aTgItem, {|x| x[TG_IT_IDTRIB] == cIdTrib} )
	If nPosIt > 0
		lRet := aTgItem[nPosIt,TG_IT_VALOR] > 0
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} VlrLimite
	Fun��o que verifica a limita��o de valores do tributo
	@type  Function
	@author Erich Buttnwer
	@since 29/04/2021
	@version version
	@param aNFItem - Array de item do tributo
	 	   nItem - Posi��o do item do produto
		   nTrbGen - Posi��o do tributo calculado
		   nResultado - Valor calculado do tributo
	@return 
		   nResultado
	@example
	(examples)
	@see (links_or_references)
	/*/
Function VlrLimite (aNFItem, nItem, nTrbGen, nResultado, nPosTrbProc, cDetTrbPri, aNfCab)

Local cOprMax 	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_OPR_MAX]
Local cOprMin 	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_OPR_MIN]
Local nVlrOpMax	:= 0
Local nVlrOpMin	:= 0

cOprMax := Iif(AllTrim(cOprMax) == "O:VAL_MANUAL",AllTrim(cOprMax)+"_MAX",AllTrim(cOprMax) )
cOprMin := Iif(AllTrim(cOprMin) == "O:VAL_MANUAL",AllTrim(cOprMin)+"_MIN",AllTrim(cOprMin) )

If !Empty(AllTrim(cOprMax)) .Or. !Empty(AllTrim(cOprMin))

	nVlrOpMax := ValOperPri(cOprMax, aNFItem, nItem, nPosTrbProc, cDetTrbPri, aNfCab )
	nVlrOpMin := ValOperPri(cOprMin, aNFItem, nItem, nPosTrbProc, cDetTrbPri, aNfCab )

	If nVlrOpMax > 0 .And. nResultado > nVlrOpMax

		nResultado := nVlrOpMax
		
	ElseIf nVlrOpMin > 0 .And. nResultado < nVlrOpMin

		nResultado := 0
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VL_ZERO] := .T.
		
	EndIf

EndIf

Return nResultado

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCompUltAq

Fun��o que retorna os valores referentes a ultima aquisi��o quando o produto
de venda possui componentes na SG1

@param - c�digo do produto e quantidade a ser verificado 

@author Alexandre Esteves, Bruce Mello
@since 15/07/2022
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Function GetCompUltAq(cCodProd,aNfCab,aNfItem,nItem,nTrbGen,cDocSai,cSerie, cCliFor ,cLoja, nCaso)


Local cSelect	:= ""
Local cFrom		:= ""
Local cWhere	:= ""
Local cQuery    := ""
Local cTpDb		:= tcgetdb()
Local cAliascJM	:= ""
Local cPrdIntAnt := ""
Local nX		:= 0
Local aBind     := {}
Local nTotalEst	:= 0
Local nIcmsEst  := 0
Local nIcmsUnit := 0
Local aFillEstr	:= {}
Local aFindComp	:= {}
Local nZ 		:= 0
Local nQuantSai	:= 0
Local nItemSai	:= 0

Default cCodProd := ""
Default cDocSai	 := ""
Default cSerie   := ""
Default cCliFor  := ""
Default cLoja 	 := ""

nQuantSai := aNfItem[nItem][IT_QUANT]
nItemSai  := aNfItem[nItem][IT_ITEM]

//Verifica se query est� no cache. Se estiver basta retornar os valores
If (nX := aScan(aPesqEstr,{|x| x[1] == cCodProd .and. x[3] == nQuantSai })) > 0 .and. Alltrim(cDocSai) = ""
	
	//Aqui apenas retorno a posi��o do produto, pois  query j� foi feita para este produto
	Return nX

Elseif nCaso == 1

	cAliascJM := getNextAlias()

	cSelect := "SELECT SG1A.G1_COD, "
	If cTpDb == "ORACLE"
		cSelect += "NVL(SG1B.G1_COMP,SG1A.G1_COMP) AS G1_PRCOMP, NVL(SG1B.G1_COD,'')AS G1_PRDINT, SG1A.G1_QUANT * NVL(SG1B.G1_QUANT,1) AS G1_QTESTR, "
	ElseIf cTpDb == "POSTGRES" .OR. cTpDb == "MYSQL" 
		cSelect += "COALESCE(SG1B.G1_COMP,SG1A.G1_COMP) G1_PRCOMP, COALESCE(SG1B.G1_COD,'') G1_PRDINT, SG1A.G1_QUANT * COALESCE(SG1B.G1_QUANT,1) G1_QTESTR, "
	Else
		cSelect += "ISNULL(SG1B.G1_COMP,SG1A.G1_COMP)AS G1_PRCOMP, ISNULL(SG1B.G1_COD,'')AS G1_PRDINT, SG1A.G1_QUANT * ISNULL(SG1B.G1_QUANT,1) AS G1_QTESTR, "
	EndIf

	cSelect += "D1.D1_DOC, D1.D1_SERIE, D1.D1_QUANT, D1.D1_VALICM, D1.D1_LOTECTL, D1.D1_DTDIGIT, D1.D1_UM, D1.D1_SEGUM, D1.D1_QTSEGUM, D1.D1_FORNECE, D1.D1_LOJA  "

    cFrom   := "FROM " + RetSqlName("SG1") + " SG1A "
	cFrom   += "LEFT JOIN " + RetSqlName("SG1") + " SG1B ON (SG1A.G1_COMP = SG1B.G1_COD AND SG1B.G1_FILIAL = ? AND SG1B.G1_FIM >= ? AND SG1B.D_E_L_E_T_ = ' ' ) "
    	if cTpDb == "ORACLE"
			cFrom   += "LEFT JOIN " + RetSqlName("SD1") + " D1 ON (D1.D1_FILIAL = ? AND  D1.D1_DTDIGIT <= ? AND D1.D1_COD = NVL(SG1B.G1_COMP,SG1A.G1_COMP) AND D1.D_E_L_E_T_ =' ' AND " 
			cFrom  += " D1.D1_DOC =(SELECT SD1.D1_DOC FROM " + RetSqlName("SD1") + " SD1 WHERE SD1.D1_FILIAL = ? AND SD1.D1_COD = NVL(SG1B.G1_COMP,SG1A.G1_COMP) ORDER BY SD1.D1_DOC DESC FETCH FIRST 1 ROWS ONLY)) "		 
		elseif cTpDb == "POSTGRES" .OR. cTpDb == "MYSQL"
			cFrom   += "LEFT JOIN " + RetSqlName("SD1") + " D1 ON (D1.D1_FILIAL = ? AND D1.D1_DTDIGIT <= ? AND D1.D1_COD = COALESCE(SG1B.G1_COMP,SG1A.G1_COMP) AND D1.D_E_L_E_T_ =' ' AND " 
			cFrom  += " D1.D1_DOC =(SELECT SD1.D1_DOC FROM " + RetSqlName("SD1") + " SD1 WHERE SD1.D1_FILIAL = ? AND SD1.D1_COD = COALESCE(SG1B.G1_COMP,SG1A.G1_COMP) ORDER BY SD1.D1_DOC DESC LIMIT 1)) "
		else
			cFrom   += "LEFT JOIN " + RetSqlName("SD1") + " D1 ON (D1.D1_FILIAL = ? AND D1.D1_DTDIGIT <= ? AND D1.D1_COD = ISNULL(SG1B.G1_COMP,SG1A.G1_COMP) AND D1.D_E_L_E_T_ =' ' AND " 
			cFrom  += " D1_DOC =(SELECT TOP 1 SD1.D1_DOC FROM " + RetSqlName("SD1") + " SD1 WHERE SD1.D1_FILIAL = ? AND SD1.D1_COD = ISNULL(SG1B.G1_COMP,SG1A.G1_COMP) ORDER BY SD1.D1_DOC DESC)) "	
		endif
    cWhere  := " WHERE SG1A.G1_FILIAL = ? "     
    cWhere  += " AND SG1A.G1_COD = ? "    
	cWhere  += " AND SG1A.G1_FIM >= ? "      
    cWhere  += " AND SG1A.D_E_L_E_T_ = ' ' "

    cQuery := cSelect +  cFrom +  cWhere 

	aadd(aBind, xFilial("SG1"))
	aadd(aBind, DTOS(dDataBase))
	aadd(aBind, xFilial("SD1"))
	aadd(aBind, DTOS(dDataBase))
	aadd(aBind, xFilial("SD1"))
    aadd(aBind, xFilial("SG1"))
    aadd(aBind, cCodProd)
	aadd(aBind, DTOS(dDataBase))

    dbUseArea(.T.,"TOPCONN",TcGenQry2(,,cQuery,aBind),cAliascJM,.T.,.F.)

	//nivel 1 e nivel 2 a query principal resolve, a partir do nivel 3 temos q olhar recursivamente os niveis para encontrar a ultima entrada
	//Cuidado com rela��o as quantidades q podem aumentar de forma exponencial !!!!

	(cAliascJM)->(DBGoTop())
    While (cAliascJM)->(!EOF())
			
		If !Empty((cAliascJM)->D1_DOC)

			nIcmsEst := (((cAliascJM)->D1_VALICM / (cAliascJM)->D1_QUANT) * (cAliascJM)->G1_QTESTR ) * nQuantSai
			nIcmsUnit:= ((cAliascJM)->D1_VALICM / (cAliascJM)->D1_QUANT)

			Aadd(aFillEstr,{(cAliascJM)->D1_DOC,;     //1
				(cAliascJM)->D1_SERIE,;   //2
				(cAliascJM)->G1_PRCOMP,;   //3
				(cAliascJM)->D1_FORNECE,;   //4
				(cAliascJM)->D1_LOJA ,;   //5
				(cAliascJM)->D1_DTDIGIT,;   //6
				Alltrim((cAliascJM)->D1_LOTECTL),;   //7
				(cAliascJM)->D1_UM,;   //8
				(cAliascJM)->D1_SEGUM,;   //9
				(cAliascJM)->D1_QTSEGUM,;   //10
				(cAliascJM)->G1_PRCOMP,;   //11
				(cAliascJM)->G1_QTESTR,;   //12
				(cAliascJM)->G1_PRDINT,;   //13
				nIcmsUnit,;   //14
				nIcmsEst})     //15
		

			nTotalEst += nIcmsEst

		Else
			If Alltrim(cPrdIntAnt) <> Alltrim((cAliascJM)->G1_PRDINT)
				Aadd(aFindComp,{(cAliascJM)->G1_PRDINT})  
				cPrdIntAnt := Alltrim((cAliascJM)->G1_PRDINT)
			Endif	
		Endif
        
		(cAliascJM)->(DbSkip())
    Enddo

	dbSelectArea(cAliascJM)
    (cAliascJM)->(dbCloseArea())

	If Len(aFindComp) > 0
		
		For nZ := 1 to 97 //J� foram tratados 2 Niveis na primeira execu��o, daqui em diante � tratado o restante dos niveis.

			If nZ > Len(aFindComp)
				Exit
			
			Else
				
				aBind := {}
				cAliasCjm := GetNextAlias()
				cPrdIntAnt := ""

				aadd(aBind, xFilial("SG1"))
				aadd(aBind, DTOS(dDataBase))
				aadd(aBind, xFilial("SD1"))
				aadd(aBind, DTOS(dDataBase))
				aadd(aBind, xFilial("SD1"))
				aadd(aBind, xFilial("SG1"))
				aadd(aBind, alltrim(aFindComp[nZ][1]))
				aadd(aBind, DTOS(dDataBase))

				dbUseArea(.T.,"TOPCONN",TcGenQry2(,,cQuery,aBind),cAliascJM,.T.,.F.)
				(cAliascJM)->(DBGoTop())
				
				While (cAliascJM)->(!EOF())
				
					If !Empty((cAliascJM)->D1_DOC) .and. !Empty((cAliascJM)->G1_PRDINT)
						nIcmsEst := (((cAliascJM)->D1_VALICM / (cAliascJM)->D1_QUANT) * (cAliascJM)->G1_QTESTR ) * nQuantSai
						nIcmsUnit:= ((cAliascJM)->D1_VALICM / (cAliascJM)->D1_QUANT)

						Aadd(aFillEstr,{(cAliascJM)->D1_DOC,;     //1
						(cAliascJM)->D1_SERIE,;   //2
						(cAliascJM)->G1_PRCOMP,;   //3
						(cAliascJM)->D1_FORNECE,;   //4
						(cAliascJM)->D1_LOJA ,;   //5
						(cAliascJM)->D1_DTDIGIT,;   //6
						Alltrim((cAliascJM)->D1_LOTECTL),;   //7
						(cAliascJM)->D1_UM,;   //8
						(cAliascJM)->D1_SEGUM,;   //9
						(cAliascJM)->D1_QTSEGUM,;   //10
						(cAliascJM)->G1_PRCOMP,;   //11
						(cAliascJM)->G1_QTESTR,;   //12
						(cAliascJM)->G1_PRDINT,;   //13
						nIcmsUnit,;   //14
						nIcmsEst})     //15

						nTotalEst += nIcmsEst
					Else
						If Alltrim(cPrdIntAnt) <> Alltrim((cAliascJM)->G1_PRDINT)
							Aadd(aFindComp,{(cAliascJM)->G1_PRDINT})   
							cPrdIntAnt := Alltrim((cAliascJM)->G1_PRDINT)
						Endif	

					Endif

					(cAliascJM)->(DbSkip())

				Enddo

				dbSelectArea(cAliascJM)
				(cAliascJM)->(dbCloseArea())
			Endif

		Next nZ

	Endif

	aAdd(aPesqEstr,{cCodProd,nTotalEst,nQuantSai})
	nX	:= Len(aPesqEstr)

	if !Empty(cDocSai) .and. Len(aFillEstr) > 0
		GravaCJM(aFillEstr, cCodProd, nQuantSai,nItemSai,aNfCab[NF_DTEMISS],cDocSai,cSerie, cCliFor ,cLoja)
	Endif
			
EndIF

Return nX

//-------------------------------------------------------------------
/*/{Protheus.doc} FisDelCjm

Fun��o para Realizar a exclus�o dos registros na tabela CJM quando a 
nota de saida for (SD2,SFT) for excluida.

@param - c�digo do produto e quantidade a ser verificado 

@author Alexandre Esteves, Bruce Mello
@since 22/07/2022
@version 12.1.2210
/*/
//-------------------------------------------------------------------

Function FisDelCjm(cDocSai,cSerie, cCliFor ,cLoja)

Local cChavEx := ""

Default cDocSai := ""
Default cSerie  := ""
Default cClifor := ""
Default cLoja	:= ""

	If !Empty(cDocSai)
		cChavEx := cDocSai+cSerie+cCliFor+cLoja
		dbSelectArea("CJM")
		CJM->(dbSetOrder(1))
		//CJM_FILIAL+CJM_DOCSAI+CJM_SERSAI+CJM_CLIFOR+CJM_LOJA+CJM_ITEFIM+CJM_PRDFIM+CJM_PRCOMP                                                                           
		If CJM->(MsSeek(xFilial("CJM")+cChavEx))
			While !CJM->(Eof()) .And. xFilial("CJM")+cChavEx == CJM->(CJM_FILIAL+CJM_DOCSAI+CJM_SERSAI+CJM_CLIFOR+CJM_LOJA) 
				If Reclock("CJM", .F.)
					CJM->(DbDelete())
					CJM->(MsUnlock())
					CJM->(FkCommit())
				Endif	
				CJM->(DbSkip())
			Enddo
		Endif	
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaCJM

Fun��o para Realizar a grava��o dos registros na tabela CJM quando a 
nota de saida for (SD2,SFT) for incluida via Mata460.

@author Alexandre Esteves, Bruce Mello
@since 09/08/2022
@version 12.1.2210
/*/
//-------------------------------------------------------------------

Static Function GravaCJM(aFillEstr, cCodProd, nQuantSai,nitem,dDtEmiss,cDocSai,cSerie, cCliFor ,cLoja)

Local cFilCjm 	:= ""
Local cMsg		:= ""
Local lRet 		:= .T.
Local nX 		:= 0
Local oBulk 	:= Nil

Default cCodProd 	:= ""
Default cDocSai  	:= ""
Default cSerie   	:= ""
Default cClifor  	:= ""
Default cLoja	 	:= ""
Default nQuantSai 	:= 0
Default nItem 		:= 0
Default aFillEstr 	:= {}

cFilCjm	:= xFilial("CJM")
oBulk	:= FwBulk():New(RetSqlName("CJM"),850)

oBulk:setFields({{"CJM_FILIAL"},;
				{"CJM_DOCORI"},;
				{"CJM_SERORI"},;
				{"CJM_PRDORI"},;
				{"CJM_FORNEC"},;
				{"CJM_LOJAEN"},;
				{"CJM_DTORIG"},;
				{"CJM_LOTORI"},;
				{"CJM_UM"},;
				{"CJM_SEGUM"},;
				{"CJM_QTSEGU"  },;
				{"CJM_DOCSAI"},;
				{"CJM_SERSAI"},;
				{"CJM_CLIFOR" },;
				{"CJM_LOJA" },;
				{"CJM_ICMEST" },;
				{"CJM_PERIOD" },;
				{"CJM_PRDFIM" },;
				{"CJM_PRCOMP" },;
				{"CJM_QTESTR" },;
				{"CJM_QTDSAI" },;
				{"CJM_ITEFIM" },;
				{"CJM_PRDINT" },;
				{"CJM_ICMUNT"},;
				{"CJM_DTSAI"}})


For nX := 1 to Len(aFillEstr)

	If aFillEstr[nX][15] > 0

		lRet := oBulk:addData({ cFilCjm                		,; //CJM_FILIAL
								aFillEstr[nX][1]       		,; //CJM_DOCORI
								aFillEstr[nx][2]       		,; //CJM_SERORI
								aFillEstr[nx][3]    		,; //CJM_PRDORI
								aFillEstr[nx][4]   			,; //CJM_FORNEC
								aFillEstr[nx][5] 			,; //CJM_LOJAEN
								STOD(aFillEstr[nx][6]) 		,; //CJM_DTORIG
								Alltrim(aFillEstr[nx][7]) 	,; //CJM_LOTORI
								aFillEstr[nx][8] 			,; //CJM_UM
								aFillEstr[nx][9]            ,; //CJM_SEGUM
								aFillEstr[nx][10]     		,; //CJM_QTSEGU
								cDocSai  					,; //CJM_DOCSAI
								cSerie    					,; //CJM_SERSAI
								cClifor      				,; //CJM_CLIFOR
								cLoja   					,; //CJM_LOJA
								aFillEstr[nx][15] 			,; //CJM_ICMEST
								LEFT(DTOS(dDtEmiss),6) 		,; //CJM_PERIOD
								Alltrim(cCodProd) 			,; //CJM_PRDFIM
								aFillEstr[nx][11]			,; //CJM_PRCOMP
								aFillEstr[nx][12]           ,; //CJM_QTESTR
								nQuantSai    				,; //CJM_QTDSAI
								nitem  						,; //CJM_ITEFIM
								aFillEstr[nx][13]    		,; //CJM_PRDINT
								aFillEstr[nx][14] 			,; //CJM_ICMUNT	
								DTOS(dDtEmiss)}) 			   //CJM_DTSAI	
				
				cMsg := Iif(lRet, "", oBulk:getError())


	Endif

Next

//Se os dados estiverem corretos, faz o Close do FwBulk para inserir poss�veis registros n�o inseridos e finalizar o bulk.
If lRet 
	lRet := oBulk:Close()
	cMsg := Iif(lRet, "", oBulk:getError())
EndIf

//Limpa objeto do FwBulk para reutilizar com outra tabela.
oBulk:Destroy()
FwFreeObj(oBulk)


Return
