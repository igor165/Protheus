#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "FATA410.CH" 

//-------------------------------------------------------------------
/*/	{Protheus.doc} Fata410
Programa de Log de Liberações do Pedido de Venda
@param		uRotAuto	-	array de dados do log para gravação
@autor  	Squad CRM/Fat
@data 		22/06/2022
@return 	
/*/
//-------------------------------------------------------------------

Function FATA410(uRotAuto)

	Static __FATA410VerLib := Nil
	Static cFunAnt 		:= Iif(cFunAnt == Nil,"",cFunAnt)

	Private aRotina 	:= MenuDef()
	Private lProdGrd 	:= MaGrade()
	Private aLogDados	:= Iif(uRotAuto == Nil,{},uRotAuto)

	If __FATA410VerLib == Nil
		__FATA410VerLib := FWLibVersion() >= "20211116"
	EndIf

	If !Empty(aLogDados)
		FA410Grava(aLogDados)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preparação do método para construir a classe ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ	
	//Else
	//	DEFINE FWMBROWSE oMBrowse ALIAS "AQ1"
	//	oMBrowse:DisableDetails()
	//	ACTIVATE FWMBROWSE oMBrowse
	EndIf

Return

//-------------------------------------------------------------------
/*/	{Protheus.doc} MenuDef
Definicao do MenuDef para o MVC
@autor  	Squad CRM/Fat
@data 		22/06/2022
@return 	aRotina - Array de Operações da Rotina
/*/
//-------------------------------------------------------------------
Static Function Menudef()

	aRotina := {}

	ADD OPTION aRotina Title STR0001 Action 'VIEWDEF.FATA410' OPERATION MODEL_OPERATION_VIEW   ACCESS 0//STR0001 - "Visualizar"

Return aRotina

//-------------------------------------------------------------------
/*/	{Protheus.doc} ModelDef
Modelo de Dados para o MVC
@autor  	Squad CRM/Fat
@data 		22/06/2022
@return 	oModel - Objeto do Modelo
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruAQ1 := FWFormStruct( 1, 'AQ1')
	Local oModel   := MPFormModel():New('FATA410',/*bPreValid*/,/*bPosValid*/,/*bCommit*/,/*Cancel*/)   

	oModel:AddFields( 'AQ1MASTER',, oStruAQ1)
	oModel:SetPrimaryKey( { "AQ1_FILIAL","AQ1_PRODUT","AQ1_PEDIDO","AQ1_ITEMPD","AQ1_SEQUEN"} )
	oModel:SetDescription(STR0006)//STR0006 - "Log de Status do Pedido de Venda"

	oStruAQ1:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)	//Retira a obrigatoriedade dos campos para o MVC poder gravar em branco

Return oModel

//-------------------------------------------------------------------
/*/	{Protheus.doc} ViewDef
Interface da aplicacao
@autor  	Squad CRM/Fat
@data 		22/06/2022
@return 	oView - Objeto da Interface
/*/
//-------------------------------------------------------------------

/*
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'FATA410' )
	Local oStruAQ1 := FWFormStruct( 2, 'AQ1')
	Local oView     

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('VIEW_AQ1',oStruAQ1,'AQ1MASTER')

Return oView
*/

//-------------------------------------------------------------------
/*/	{Protheus.doc} FA410Grava
Commit da tabela AQ1
@autor  	Squad CRM/Fat
@data 		22/06/2022
@return
/*/
//-------------------------------------------------------------------
Static Function FA410Grava(aLogDados)

	Local aArea			:= GetArea()
	Local oModel		:= FWLoadModel('FATA410')
	Local aGrvLog		:= {}
	Local aSeqStts		:= {} //{SEQUENCIA,STATUS,DET.BLOQUEIO}	
	Local nX        	:= 0
	Local nY			:= 0
	
	Private cSeq 		:= ""
	Private cIndChv		:= ""
	Private cSeqAnt		:= ""
	Private lContinue 	:= .T.
	Private aLogGrv		:= {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Processo para tratar o array aLogGrv antes de realizar a gravação na tabela AQ1  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aLogDados)

		aSeqStts  := AQ1LastSeq(aLogDados[nX])//Funcao para tratar o sequencial, status e detalhe do bloqueio.

		If lContinue .And. !Empty(aSeqStts[2])

			Aadd(aLogGrv,{aLogDados[nX][1],aLogDados[nX][2],aLogDados[nX][3],aLogDados[nX][4],aLogDados[nX][5],;
				aSeqStts[1],aSeqStts[2],aLogDados[nX][6],IIF(aSeqStts[2] == "1","",aLogDados[nX][7]),;
				IIF(aSeqStts[2] == "1","",aLogDados[nX][8]),aSeqStts[3],aLogDados[nX][9],aLogDados[nX][10]})

		EndIf

	Next nX

	DbSelectArea("AQ1")
	AQ1->(DbSetOrder(1))//AQ1_FILIAL, AQ1_PRODUT, AQ1_PEDIDO, AQ1_ITEMPD, AQ1_SEQUEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Processo para gravação na tabela AQ1 com o array já tratado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nY := 1 TO Len(aLogGrv)

		If !AQ1->(DbSeek(aLogGrv[nY][1]+aLogGrv[nY][4]+aLogGrv[nY][2]+aLogGrv[nY][3]+" "+aLogGrv[nY][6]))
						
			aAdd(aGrvLog,{"AQ1_FILIAL",	aLogGrv[nY][1],Nil})	//[1] AQ1_FILIAL
			aAdd(aGrvLog,{"AQ1_PEDIDO",	aLogGrv[nY][2],Nil})	//[2] AQ1_PEDIDO
			aAdd(aGrvLog,{"AQ1_ITEMPD",	aLogGrv[nY][3],Nil})	//[3] AQ1_ITEMPD
			aAdd(aGrvLog,{"AQ1_PRODUT",	aLogGrv[nY][4],Nil})	//[4] AQ1_PRODUT
			aAdd(aGrvLog,{"AQ1_QTDLIB",	aLogGrv[nY][5],Nil})	//[5] AQ1_QTDLIB
			aAdd(aGrvLog,{"AQ1_SEQUEN",	aLogGrv[nY][6],Nil})	//[6] AQ1_SEQUEN
			aAdd(aGrvLog,{"AQ1_STATUS",	aLogGrv[nY][7],Nil}) 	//[7] AQ1_STATUS
			aAdd(aGrvLog,{"AQ1_ORIGEM",	aLogGrv[nY][8],Nil})	//[8] AQ1_ORIGEM
			aAdd(aGrvLog,{"AQ1_BLQCRD",	aLogGrv[nY][9],Nil})	//[9] AQ1_BLQCRD
			aAdd(aGrvLog,{"AQ1_BLQEST",	aLogGrv[nY][10],Nil})	//[10] AQ1_BLQEST
			aAdd(aGrvLog,{"AQ1_DETBLQ",	aLogGrv[nY][11],Nil}) 	//[11] AQ1_DETBLQ
			aAdd(aGrvLog,{"AQ1_DATA",	aLogGrv[nY][12],Nil})	//[12] AQ1_DATA
			aAdd(aGrvLog,{"AQ1_HORA",	aLogGrv[nY][13],Nil})	//[13] AQ1_HORA
								
			FWMVCRotAuto(oModel,"AQ1",MODEL_OPERATION_INSERT,{{"AQ1MASTER",aGrvLog}},/*lSeek*/,.T.)
			aGrvLog := {}//Limpa o array

		EndIf

	Next nY

	AQ1->(DbCloseArea())

	oModel:DeActivate()
	oModel:Destroy()
	oModel := NIL

	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/	{Protheus.doc} AQ1LastSeq
Define o sequencial do Log da Liberação e trata o status 
@param		aLogDdGrv	-	array de dados do log para gravação
@autor  	Squad CRM/Fat
@data 		22/06/2022
@return 	cSeq - Sequencial da AQ1
			cStatus - Status da linha AQ1
/*/
//-------------------------------------------------------------------
Static Function AQ1LastSeq(aLogDdGrv)

	Local aArea		:= GetArea()
	Local cAliasAQ1 := GetNextAlias()
	Local cQuery 	:= ""
	Local oQryAQ1 	:= Nil
	Local lAtuSeq	:= .T.//Determina atualizacao do Sequencial
	Local lAtuStts	:= .T.//Determina atualizacao do Status
	Local cAtribui	:= "" //Variavel de determina a Atribuicao (:= ou +=)
	Local cDetBlq	:= STR0018 //Detalhe de Bloqueio (Inicio Padrao: "Em Carteira")
	Local cStatus	:= ""
	Local lFontLib 	:= aLogDdGrv[13] $ "MAGRAVASC9|A450GRAVA|MAAVALSC9|MAPVL2SD2|MA450PROCES" //Funcoes de Liberacao
	Local lFontEst	:= aLogDdGrv[13] $ "A460ESTORNA" //Funcoes de Estorno
	Local lSeqAnt   := .F.
	Local cSeqQuery	:= ""
	Local lTipoPed	:= IIF(SC5->C5_TIPO $ "C|I|P",.T.,IIF(aLogDdGrv[5] > 0,.T.,.F.)) //Valida o tipo do pedido de venda ou se possui quantidade para liberar.

	//Retorna valor padrao
	lContinue := .T.

	//Validacao de combinacao de chamada de funcoes que gravam em duplicidade
	If cFunAnt == "MAGRAVASC9" .And. aLogDdGrv[13] == "A450GRAVA"
		lContinue := .F.
	EndIf

	//Validacao de sequencial para prosseguir onde o numero parou, caso o processo tratar registros com a mesma chave do indice.
	If cIndChv == aLogDdGrv[1]+aLogDdGrv[2]+aLogDdGrv[3]
		lSeqAnt := .T.
		cSeq 	:= cSeqAnt
	Else
		cSeq := "000000001"
	EndIf

	//Valida se o produto possui grade atraves do parametro e pelo campo C6_GRADE do item. Pois mesmo tratando-se de produto 
	//de grade, somente validando pelo parametro nao e suficiente devidamente pois o parametro pode estar vazio pode por default igual a .F.
	//Caso o produto utilizar grade, sera tratado apenas depois da query para seguir com a soma do sequencial.

	//Valida se trata-se de fontes que sao de liberacao

	//Caso a chamada da funcao for primeiro da liberacao e vier como inclusao, entende-se que não 
	//existe o primeiro registro com o status "Em Carteira" e portanto sera necessario gravar antes.

	If !lProdGrd .And. lFontLib .And. aLogDdGrv[11] == 1

		If SC6->C6_GRADE == "N" .Or. Empty(SC6->C6_GRADE)
	
			DbSelectArea("AQ1")
			AQ1->(DbSetOrder(1))//AQ1_FILIAL, AQ1_PRODUT, AQ1_PEDIDO, AQ1_ITEMPD, AQ1_SEQUEN

			If !AQ1->(DbSeek(aLogDdGrv[1]+aLogDdGrv[4]+aLogDdGrv[2]+aLogDdGrv[3]+" "))

				Aadd(aLogGrv,{aLogDdGrv[1],aLogDdGrv[2],aLogDdGrv[3],aLogDdGrv[4],aLogDdGrv[5],cSeq,"1",aLogDdGrv[6],"","",STR0018,aLogDdGrv[9],aLogDdGrv[10]})

				cSeq 	:= Soma1(cSeq)//Atualiza o sequencial novamente para poder gravar o item origem.
				lAtuSeq := .F.

			EndIf

			AQ1->(DbCloseArea())

		EndIf

	EndIf

	//Query para verificar o ultimo sequencial de acordo com os dados do item do pedido
	cQuery := " SELECT TOP 1 MAX(AQ1_SEQUEN) SEQ_MAX, AQ1_STATUS STATUS, AQ1_PRODUT PRODUTO, AQ1_QTDLIB QTDLIB "
	cQuery += " FROM "+RetSqlName("AQ1")+ " AQ1 "
	cQuery += " WHERE AQ1_FILIAL = ? "
	cQuery += " AND AQ1_PEDIDO = ? "
	cQuery += " AND AQ1_ITEMPD = ? "
	cQuery += " AND D_E_L_E_T_= ? GROUP BY AQ1_STATUS,  AQ1_PRODUT , AQ1_QTDLIB ORDER BY 1 DESC "
	cQuery := ChangeQuery(cQuery)

	oQryAQ1 := IIf(__FATA410VerLib,FwExecStatement():New(cQuery),FWPreparedStatement():New(cQuery))

	oQryAQ1:SetString(1,aLogDdGrv[1])	//AQ1_FILIAL
	oQryAQ1:SetString(2,aLogDdGrv[2])	//AQ1_PEDIDO
	oQryAQ1:SetString(3,aLogDdGrv[3])	//AQ1_ITEMPD
	oQryAQ1:SetString(4,' ')			//D_E_L_E_T_

	If __FATA410VerLib
		cAliasAQ1 := oQryAQ1:OpenAlias()
	Else
		cQuery := oQryAQ1:GetFixQuery()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAQ1,.T.,.T.)
	EndIf

	//Guarda o sequencial da query
	cSeqQuery := (cAliasAQ1)->SEQ_MAX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratativa para gravação do primeiro log com status "Em cateira" para cada item caso o produto utilizar Grade. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If lProdGrd .And. SC6->C6_GRADE == "S"

		If lFontLib .And. (aLogDdGrv[11] == 1 .Or. aLogDdGrv[11] == 2)
		
			//Atualiza o sequencial devido utilizacao da grade do produto e por ja existir um registro de log com a chave unica 
			//igual. Desta forma sera necessario seguir com o sequencial normalmente para nao dar chave duplicada.
			cSeq := Soma1(IIF(lSeqAnt,cSeq,cSeqQuery))

			DbSelectArea("AQ1")
			AQ1->(DbSetOrder(1))//AQ1_FILIAL, AQ1_PRODUT, AQ1_PEDIDO, AQ1_ITEMPD, AQ1_SEQUEN

			If !AQ1->(DbSeek(aLogDdGrv[1]+aLogDdGrv[4]+aLogDdGrv[2]+aLogDdGrv[3]+" "))

				Aadd(aLogGrv,{aLogDdGrv[1],aLogDdGrv[2],aLogDdGrv[3],aLogDdGrv[4],aLogDdGrv[5],cSeq,"1",aLogDdGrv[6],"","",STR0018,aLogDdGrv[9],aLogDdGrv[10]})

				cSeq := Soma1(cSeq)//Atualiza o sequencial novamente para gravar o mesmo item, porem com o status atualizado.

			EndIf

			lAtuSeq := .F. // Variavel que impede a atualização do sequencial novamente.

			AQ1->(DbCloseArea())

		EndIf

	ElseIf SC6->C6_GRADE == "N" .Or. Empty(SC6->C6_GRADE)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para atualizar status do antigo item em caso de alteração de Produto ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//Caso houver apenas a troca do codigo do produto, inclui um novo registro com status "Em Carteira" 
		//com o produto atualizado, seguindo o sequencial normalmente.

		If !Empty((cAliasAQ1)->PRODUTO) .And. (cAliasAQ1)->PRODUTO <> aLogDdGrv[4] .And. ;
			(cAliasAQ1)->STATUS <> "3" .And. !aLogDdGrv[12]

			cSeq 	:= Soma1(IIF(lSeqAnt,cSeq,cSeqQuery))//Pega o sequencial do item com o produto anterior e soma o sequencial
			cStatus := "1" //Carteira
			cDetBlq := STR0018 //"Em Carteira"
			lAtuSeq := .F. //Nao atualiza o sequencial

			If lFontLib

				DbSelectArea("AQ1")
				AQ1->(DbSetOrder(1))//AQ1_FILIAL, AQ1_PRODUT, AQ1_PEDIDO, AQ1_ITEMPD, AQ1_SEQUEN

				If !AQ1->(DbSeek(aLogDdGrv[1]+aLogDdGrv[4]+aLogDdGrv[2]+aLogDdGrv[3]+" "))

					Aadd(aLogGrv,{aLogDdGrv[1],aLogDdGrv[2],aLogDdGrv[3],aLogDdGrv[4],aLogDdGrv[5],cSeq,"1",aLogDdGrv[6],"","",STR0018,aLogDdGrv[9],aLogDdGrv[10]})

					cSeq := Soma1(cSeq)//Atualiza o sequencial novamente para gravar o mesmo item, porem com o produto atual.

				EndIf

			EndIf

			lAtuSeq := .F. // Variavel que impede a atualização do sequencial novamente.

		EndIf
		
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para atualizar o status caso o item estiver deletado ou se for uma exclusao do Pedido de Venda³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aLogDdGrv[12] .Or. aLogDdGrv[11] == 3 //Caso o item do pedido estiver deletado ou for uma operacao de exclusao

		//Caso a operacao de exclusao for de documento de saida e o retorno do pedido de venda estiver selecionado "Carteira"
		If aLogDdGrv[13] == "MADELNFS"

			//Atualiza o cStatus para "Em Carteira".
			cStatus := "1"
			//Limpa o conteudo dos campos AQ1_BLQCRD e AQ1_BLQEST para poder gravar corretamente com o status "Em Carteira"
			aLogDdGrv[7] := "" 
			aLogDdGrv[8] := ""
			//Atualiza o sequencial
			cSeq := Soma1(IIF(lSeqAnt,cSeq,cSeqQuery))
			lAtuSeq := .F. //Impede de atualizar novamente o sequencial
			lAtuStts := .F. //Impede de atualizar o status

		ElseIf lAtuSeq

			If Empty((cAliasAQ1)->STATUS) .And. aLogDdGrv[13] == "A410GRAVA"

				//Caso o valor do campo status estiver vazio e constar como item deletado, 
				//indica que foi excluido na inclusao apos salvar o pedido de venda e portanto 
				//nao sera necessario gravar o log.
				lContinue := .F. 

			Else	

				If aLogDdGrv[12]
				
					cStatus  := "3"			//Caso a linha for deletada, alterar o status para "Deletado".
					cDetBlq  := STR0017 	//Caso a linha for deletada, alterar o Detalhe do Bloqueio para "Deletado".
					lAtuStts := .F.			//Impede de atualizar novamente o Status
					lAtuSeq	 := .F.			//Impede de atualizar novamente o sequencial
					cSeq	 := Soma1(IIF(lSeqAnt,cSeq,cSeqQuery)) //Atualiza o sequencial
					
				
						//Caso o produto for de grade ou caso o produto for diferente, sera necessario atualizar o sequencial
				ElseIf ((lProdGrd .Or. SC6->C6_GRADE == "S") .Or. (cAliasAQ1)->PRODUTO <> aLogDdGrv[4]) .And. aLogDdGrv[11] == 3

					cSeq := Soma1(IIF(lSeqAnt,cSeq,cSeqQuery))
					cStatus := "1"
					lAtuSeq := .F.
				
				EndIf

			EndIf
			
		EndIf	

	EndIf

	If lContinue 

		If lFontLib .And. lAtuSeq

			If ((cAliasAQ1)->(Eof()) .And. aLogDdGrv[11] == 2) .Or. ((cAliasAQ1)->PRODUTO <> aLogDdGrv[4])

				DbSelectArea("AQ1")
				AQ1->(DbSetOrder(1))//AQ1_FILIAL, AQ1_PRODUT, AQ1_PEDIDO, AQ1_ITEMPD, AQ1_SEQUEN

				//Verifica se ja existe registro com a chave do indice 1. Caso nao encontrar, entende-se que nao existe o status "Em Carteira" e contudo sera 
				//necessario inserir antes de gravar o status da liberacao.

				If !AQ1->(DbSeek(aLogDdGrv[1]+aLogDdGrv[4]+aLogDdGrv[2]+aLogDdGrv[3]+" "))

					cSeq := Soma1(IIF(lSeqAnt,cSeq,cSeqQuery))//Atualiza o sequencial com base no ultimo sequencial encontrado pela query

					Aadd(aLogGrv,{aLogDdGrv[1],aLogDdGrv[2],aLogDdGrv[3],aLogDdGrv[4],aLogDdGrv[5],cSeq,"1",aLogDdGrv[6],"","",STR0018,aLogDdGrv[9],aLogDdGrv[10]})
			
					cSeq := Soma1(cSeq)//Atualiza o sequencial com base no ultimo sequencial utilizado no registro recem adicionado no array
				
				Else

					cSeq := Soma1(IIF(lSeqAnt,cSeq,cSeqQuery))//Atualiza o sequencial com base no ultimo sequencial encontrado pela query

				EndIf

				AQ1->(DbCloseArea())

			Else

				//Atualiza o sequencial com base no ultimo sequencial encontrado pela query
				cSeq := Soma1(IIF(lSeqAnt,cSeq,cSeqQuery))

			EndIf

			lAtuSeq := .F.

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para atualizar o Status do Log³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAtuStts 

			If aLogDdGrv[13] <> "A410GRAVA"
			
				If (cStatus <> "3" .And. aLogDdGrv[11] <> 3) .Or. (cAliasAQ1)->PRODUTO <> aLogDdGrv[4] .And. !lFontEst

					cAtribui := Iif(!Empty(aLogDdGrv[7]),"+=",":=" )//Determina qual tipo de atribuicao utilizar

					If aLogDdGrv[7] $ "01|02|04|05|06|09" .Or. aLogDdGrv[8] $ "02|03"
					
						cStatus := "6" //Atuliza o Status como "Bloqueado"

						//Tratamento para o Detalhe do Bloqueio para o campo C9_BLCRED
						If !Empty(aLogDdGrv[7])

							If aLogDdGrv[7] == "01"
								cDetBlq := aLogDdGrv[7]+" - "+STR0007 //Bloqueado p/ Credito
							ElseIf aLogDdGrv[7] == "02"
								cDetBlq := aLogDdGrv[7]+" - "+STR0008 //Por Estoque - MV_BLQCRED = T
							ElseIf aLogDdGrv[7] == "04"
								cDetBlq := aLogDdGrv[7]+" - "+STR0009 //Limite de Credito Vencido
							ElseIf aLogDdGrv[7] == "05"
								cDetBlq := aLogDdGrv[7]+" - "+STR0010 //Bloqueio Crédito por Estorno
							ElseIf aLogDdGrv[7] == "09"
								cDetBlq := aLogDdGrv[7]+" - "+STR0011 //Rejeitado
							EndIf

						EndIf

						//Tratamento para o Detalhe do Bloqueio para o campo C9_BLEST
						If !Empty(aLogDdGrv[8])

							&("cDetBlq "+cAtribui+"'"+IIF(cAtribui == "+="," / ","")+aLogDdGrv[8]+" - "+"'")

							If aLogDdGrv[8] == "02"
								cDetBlq += STR0013//Bloqueio de Estoque
							ElseIf aLogDdGrv[8] == "03"
								cDetBlq += STR0014//Bloqueio Manual
							EndIf

						EndIf

					ElseIf  Empty(aLogDdGrv[7]) .And. Empty(aLogDdGrv[8])

						If lTipoPed .And. lFontLib
							cStatus := "4" //Atuliza o Status como "Apto a Faturar"
							cDetBlq := STR0015 //Liberado
						Else
							//Caso nao possuir bloqueio e nao for uma liberacao, mantem o status "Em carteira"
							//Caso for um estorno, limpa o status pois a liberacao sera feita atraves do fonte de liberacao.
							cStatus := IIF(FunName()== "MATA460A","1",IIF(lFontEst,"","1"))
							cDetBlq := STR0018 //Em Carteira
						EndIf 

					ElseIf aLogDdGrv[7] == "10" .Or. aLogDdGrv[8] == "10"

						cStatus := "5" //Atuliza o Status como "Faturado"
						cDetBlq := aLogDdGrv[7]+" - "+STR0016 //Já Faturado

					EndIf

				EndIf

			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para gravacao de Pedidos de Venda
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aLogDdGrv[13] == "A410GRAVA" .And. Empty(aLogDdGrv[5]) .And. !lFontLib

			If !(cAliasAQ1)->(Eof()) .And. lAtuSeq//Se existir registro e se precisar validar o sequecial

				//Caso a variavel cStatus for diferente do ultimo registro, entende que sera um novo registro 
				//e portanto ira seguir como a proxima numeracao do sequencial.
				cSeq := Iif((cAliasAQ1)->STATUS == cStatus, IIF(lSeqAnt,cSeq,cSeqQuery), Soma1(IIF(lSeqAnt,cSeq,cSeqQuery)))

			Elseif lAtuStts

				If SC6->C6_GRADE == "S" .And. aLogDdGrv[11] == 1

					DbSelectArea("AQ1")
					AQ1->(DbSetOrder(1))//AQ1_FILIAL, AQ1_PRODUT, AQ1_PEDIDO, AQ1_ITEMPD, AQ1_SEQUEN

					If !AQ1->(DbSeek(aLogDdGrv[1]+aLogDdGrv[4]+aLogDdGrv[2]+aLogDdGrv[3]+" "))

						cSeq := Soma1(IIF(lSeqAnt,cSeq,cSeqQuery))

						Aadd(aLogGrv,{aLogDdGrv[1],aLogDdGrv[2],aLogDdGrv[3],aLogDdGrv[4],aLogDdGrv[5],cSeq,"1",aLogDdGrv[6],"","",STR0018,aLogDdGrv[9],aLogDdGrv[10]})

					EndIf

				Else

					cStatus := "1"//Por ser o primeiro registro, o status sera gravado como "Em Carteira".

				EndIf

			Endif

		EndIf
		
	EndIf

	//Guarda dados anteriores para validar com os processos/registros a seguir
	cFunAnt := aLogDdGrv[13]
	cIndChv := aLogDdGrv[1]+aLogDdGrv[2]+aLogDdGrv[3]
	cSeqAnt := cSeq

	(cAliasAQ1)->(DBCloseArea()) //Fecha tabela da query

	oQryAQ1:Destroy()

	RestArea(aArea)
	
Return {cSeq,cStatus,cDetBlq}
