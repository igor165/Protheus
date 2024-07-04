#Include 'Protheus.ch'

//------------------------------------------------------------------------------
/*/{Protheus.doc} RUP_TEC()
Fun��es de compatibiliza��o e/ou convers�o de dados para as tabelas do sistema.
Sempre executar primeiro o ajuste de dicionario, entao o ajuste de dados ("update tabelas")
@sample		RUP_TEC("12", "2", "003", "005", "BRA")
@param		cVersion	- Vers�o do Protheus 
@param		cMode		- Modo de execu��o	- "1" = Por grupo de empresas / "2" =Por grupo de empresas + filial (filial completa)
@param		cRelStart	- Release de partida	- (Este seria o Release no qual o cliente est�)
@param		cRelFinish	- Release de chegada	- (Este seria o Release ao final da atualiza��o)
@param		cLocaliz	- Localiza��o (pa�s)	- Ex. "BRA"
@return		Nil
@author		Cesar Bianchi
@since		24/08/2017
@version	12
/*/
//------------------------------------------------------------------------------
 Function RUP_TEC(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

	Local aArea	   := GetArea()

	//1* Chama os ajustes de dicionario
	RupTecDic(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)  
	
	//2* Chama os ajustes de dados (alimenta campos novos, fix)
	//S� executa caso seja DBACCESS para nao capotar o Loja (Front) - POR ISSO O IFDEF TOP EM FONTE 12
	#IFDEF TOP
		RupTecTbl(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
	#ENDIF

	RestArea(aArea)

Return Nil

//====================================================================================================================�
/*/{Protheus.doc} RupTecDic(cFonte)�
Fun��o para realiza��o de ajustes no dicionario de dados.
NAO EXECUTAR NENHUM RECLOCK EM ARQUIVOS SX e XX
USAR SEMPRE AS FUNCOES DO FRAMEWORK/GCAD PARA MANIPULACAO DOS DICIONARIOS				
@param		cVersion	- Vers�o do Protheus 
@param		cMode		- Modo de execu��o	- "1" = Por grupo de empresas / "2" =Por grupo de empresas + filial (filial completa)
@param		cRelStart	- Release de partida	- (Este seria o Release no qual o cliente est�)
@param		cRelFinish	- Release de chegada	- (Este seria o Release ao final da atualiza��o)
@param		cLocaliz	- Localiza��o (pa�s)	- Ex. "BRA"
@return		Nil
@author		Cesar Bianchi
@since 	24/08/2017
@version P12�
/*/
//====================================================================================================================�
Static Function RupTecDic(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

	//******************************************************************//
	//Monta os ajustes necessarios na SX1 - Para uso na funcao do Frame //
	//******************************************************************//
	/*ATE O MOMENTO NENHUM AJUSTE NECESSARIO*/

	//******************************************************************//	
	//Monta os ajustes necessarios na SX2 - Para uso na funcao do Frame //
	//******************************************************************//
	/*ATE O MOMENTO NENHUM AJUSTE NECESSARIO*/
	
	//******************************************************************//
	//Monta os ajustes necessarios na SX3 - Para uso na funcao do Frame //
	//******************************************************************//
	 /*ATE O MOMENTO NENHUM AJUSTE NECESSARIO*/
	
	//******************************************************************//
	//Monta os ajustes necessarios na SX5 - Para uso na funcao do Frame //
	//******************************************************************//
	/*ATE O MOMENTO NENHUM AJUSTE NECESSARIO*/
	
	//******************************************************************//
	//Monta os ajustes necessarios na SX9 - Para uso na funcao do Frame //
	//******************************************************************//
	/*ATE O MOMENTO NENHUM AJUSTE NECESSARIO*/

	//******************************************************************//
	//Monta os ajustes necessarios na SIX - Para uso na funcao do Frame //
	//******************************************************************//
	/*ATE O MOMENTO NENHUM AJUSTE NECESSARIO*/
	
	//******************************************************************//
	//Executa as funcoes do Framework para ajustar dicionarios.         //
	//Obs: A cada release � necessario ajustar da funcao                //		
	//******************************************************************//		
Return Nil


//====================================================================================================================�
/*/{Protheus.doc} RupTecTbl()�
Fun��o para realiza��o de ajustes de dados em tabelas do GS. 
NAO EXECUTAR MANUTENCAO DE SXS ATRAVES DESTA FUNCAO. CARATER EXCLUSIVO PARA AJUSTE DE DADOS APENAS				
@param		cVersion	- Vers�o do Protheus 
@param		cMode		- Modo de execu��o	- "1" = Por grupo de empresas / "2" =Por grupo de empresas + filial (filial completa)
@param		cRelStart	- Release de partida	- (Este seria o Release no qual o cliente est�)
@param		cRelFinish	- Release de chegada	- (Este seria o Release ao final da atualiza��o)
@param		cLocaliz	- Localiza��o (pa�s)	- Ex. "BRA"
@return		Nil
@author		Desconhecido
@since 	24/08/2017
@version P12�
/*/
//====================================================================================================================�
Static Function RupTecTbl(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

Return Nil

//====================================================================================================================�
/*/{Protheus.doc} AjustaTEC(cFonte)�
Fun��o para realiza��o do AjustaSX3 durante release.�
Os ajustes realizados nesta fun��o devem obrigat�riamente estar contido na fun��o de migra��o RUP_TEC.�
Os ajustes realizados nesta fun��o ser�o removidos a cada release.�
@param� cFonte� - Fonte no qual o ajusta ser� realizado.�
@since 29/03/2016�
@version P12�
/*/
//====================================================================================================================�
Function AjustaTEC(cFonte) // Esse fonte e chamado no TECA753 se remover pode dar error.log na chamada
Local	lRet	:= .T.
Local 	cTmpQry	:= GetNextAlias()
Default	cFonte	:= ""

If cFonte == "TECA743"
	BeginSql Alias cTmpQry
		SELECT  TFI_COD
			   ,TFI_CONENT
			   ,TFI_CONCOL
		FROM %Table:TFI% TFI
		WHERE TFI.TFI_FILIAL   = %xFilial:TFI%
			AND TFI.TFI_CONENT = %Exp:' '% 
			OR TFI.TFI_CONCOL  = %Exp:' '% 
			AND TFI.%NotDel%
	EndSql

	DbSelectArea("TFI")
	TFI->(DbSetOrder(1))

	While (cTmpQry)->(!Eof())
		If TFI->(DbSeek(xFilial("TFI")+(cTmpQry)->TFI_COD))		

			If TFI->TFI_CONENT == " "
				Reclock("TFI",.F.)
					TFI->TFI_CONENT := "2"
				TFI->(MsUnlock())
			Endif

			If TFI->TFI_CONCOL == " "
				Reclock("TFI",.F.)
					TFI->TFI_CONCOL := "2"
				TFI->(MsUnlock())
			Endif
		Endif
		(cTmpQry)->(DbSkip())
	EndDo
	(cTmpQry)->(DbCloseArea())
Endif

Return lRet
