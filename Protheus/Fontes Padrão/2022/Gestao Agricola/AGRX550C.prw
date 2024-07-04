#INCLUDE 'TOTVS.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGRX550.CH"

//=======================================================
/*****  Funções relacionadas ao agendamento AGRO  *****/
//=======================================================

/*/{Protheus.doc} AGRX550AGD
//Função para criar o agendamento AGRO via agendamento do GFE (GFEA517) 
@author marina.muller
@since 15/06/2018
@version 1.0
@return ${return}, ${return_description}
@param cEmit, characters, descricao
@param cDtAgen, characters, descricao
@param cHrAgen, characters, descricao
@param cNrAgen, characters, descricao
@param cVeic, characters, descricao
@type function
/*/
Function AGRX550AGD(cEmit, cDtAgen, cHrAgen, cNrAgen, cVeic)
	Local aArea    := GetArea()
	Local lRet	   := .T.
	Local cTransp  := ""
	Local cPlaca   := ""
	Local cCodPro  := ""
	Local cCodSaf  := ""
	Local cTipo    := ""
	Local oModel   := Nil
	Local cIdfed   := ""
	Local oMdlN9E  := Nil
	Local nCount   := 0
	Local QryN8O := GetNextAlias()
	Local QryN92 := GetNextAlias()

	Private _lAltIE  := .F.
	Private _cTpOpRe	:= IIF(FWIsInCallStack("OGWSPUTATU"),_cTpOpRe,"") //Verifica se o model foi ativado pela rotina REST
	
	//valida se o fonte nao está vindo do AGRA550 para evitar recursividade.
	If IsInCallStack("AGRA550")
		Return lRet
	EndIf

	//busca o tipo operação e produto do F12 (AGRA550)
	Pergunte( "AGRA550001", .F.)

	//Instancia o Model do AGRA550 (romaneio AGRO)
	oModel := FwLoadModel("AGRA550")

	//Seta operação de Inclusão
	oModel:SetOperation(3)

	//Ativa o modelo
	oModel:Activate()
	
	oMdlN9E := oModel:getModel("AGRA550_N9E")

	//se parâmetro do produto estiver preenchido 
	If !Empty(MV_PAR01)
		cCodPro := MV_PAR01
		oModel:SetValue('AGRA550_NJJ','NJJ_CODPRO',cCodPro) //Cod. Produto
	EndIf

	//se parâmetro do tipo operação estiver preenchido
	If !Empty(MV_PAR02)
		cTipo := MV_PAR02
		oModel:SetValue('AGRA550_NJJ','NJJ_TOETAP',cTipo) //Tipo
	EndIf

	oModel:SetValue('AGRA550_NJJ','NJJ_DTAGEN',cDtAgen) //Dt. Agend.
	oModel:SetValue('AGRA550_NJJ','NJJ_HRAGEN',cHrAgen) //Hr. Agend.
	oModel:LoadValue('AGRA550_NJJ','NJJ_NRAGEN',cNrAgen) //Agendamento

	//busca transportadora pelo código do emitente
	If !Empty(cEmit)
		//Posiciona no registro e pega o CNPJ/CPF dele
		GU3->(dbSetOrder(1))
		If GU3->(DbSeek(FWxFilial("GU3")+cEmit)) //FILIAL + CDEMIT
			cIdfed := GU3->(GU3_IDFED)
		EndIf

		if !Empty(cIdfed)
			//Com o CNPJ/CPF, acha o codigo da transportadora.
			SA4->(dbSetOrder(3))
			If SA4->(DbSeek(FWxFilial("SA4")+cIdfed)) //FILIAL + CGC
				cTransp := SA4->A4_COD
			EndIf

			if !Empty(cTransp)
				SA4->(dbSetOrder(1))
				oModel:SetValue('AGRA550_NJJ','NJJ_CODTRA',cTransp) //Cod. Transp.
			endIF
		endIf
	EndIf   

	//busca placa pelo código do veiculo
	If !Empty(cVeic)
		dbSelectArea("DA3")
		DA3->(dbSetOrder(1))
		If DA3->(DbSeek(FWxFilial("DA3")+cVeic)) //FILIAL + VEICULO
			cPlaca := DA3->DA3_PLACA
		EndIf
		DA3->(dbCloseArea())

		oModel:SetValue('AGRA550_NJJ','NJJ_PLACA',cPlaca) //Placa
	EndIf

	dbSelectArea('GWN')
	dbSetOrder(1)
	If dbSeek(fwxFilial('GWN')+M->GWV_NRROM)

		dbSelectArea('GXS')
		GXS->(dbSetOrder(2))    	
		If GXS->(MsSeek(fwxFilial('GWN')+GWN->GWN_NRCT)) //GXS_FILCT+GXS_NRCT

			//busca filtrando pelo ID da requisição os código das IE´s 
			dbSelectArea('N9R')
			N9R->(dbSetOrder(3))    	
			If N9R->(MsSeek(GXS->GXS_FILIAL+GXS->GXS_IDREQ)) //N9R_FILORI+N9R_IDREQ

				//busca filtrando pelos códigos IE´s para buscar safra/ entidade/ loja/ produto
				dbSelectArea('N7Q')
				N7Q->(dbSetOrder(1))    	
				If N7Q->(MsSeek(FwxFilial("N7Q")+N9R->N9R_CODINE)) //N7Q_FILIAL+N7Q_CODINE		

					//busca filtrando pelos códigos IE´s para buscar regra
					dbSelectArea('N7S')
					N7S->(dbSetOrder(3))    	
					If N7S->(MsSeek(FwxFilial("N7S")+N9R->N9R_CODINE+N9R->N9R_FILORI)) //N7S_FILIAL+N7S_CODINE+N7S_FILORG
						While N7S->(!Eof())  				.And.;
						N7S->N7S_FILIAL == FwxFilial("N7S") .AND.;						 
						N7S->N7S_CODINE == N9R->N9R_CODINE .AND.;
						N7S->N7S_FILORG == N9R->N9R_FILORI 								

							//posicionar na N8O e buscar autorização e código por IE e Id Entrega
							BeginSql Alias QryN8O
								Select N8O_CODAUT, N8O_ITEM, N8O_QTATEN
								From %table:N8O% N8O
								Where N8O.N8O_FILIAL = %xFilial:N8O%
								And N8O.N8O_CODINE = %exp:N7S->N7S_CODINE%
								And N8O.N8O_IDENTR = %exp:N7S->N7S_ITEM% 
								And N8O.N8O_CODCTR = %exp:N7S->N7S_CODCTR%
								And N8O.%notDel%
							EndSql

							DbselectArea( QryN8O )
							(QryN8O)->(dbGoTop())
							
							nCount++
							if nCount <= oMdlN9E:Length() 
								oMdlN9E:GoLine( nCount )
							Else
								oMdlN9E:AddLine()
								oMdlN9E:GoLine( oMdlN9E:Length() )
							EndIf					

							oMdlN9E:SetValue('N9E_CODAUT', (QryN8O)->N8O_CODAUT)  //código autorização carregamento
							oMdlN9E:SetValue('N9E_ITEMAC', (QryN8O)->N8O_ITEM)    //código item			  	
							oMdlN9E:SetValue('N9E_CODINE', N7S->N7S_CODINE)       //3 - IE
							oMdlN9E:SetValue('N9E_ITEM'  , N7S->N7S_ITEM)         //4 - ID entrega
							oMdlN9E:SetValue('N9E_CODCTR', N9R->N9R_CODCTR)       //5 - contrato
							oMdlN9E:SetValue('N9E_SEQPRI', N7S->N7S_SEQPRI)    	  //7 - ID regra
							oMdlN9E:SetValue('N9E_CLIFOR', N7Q->N7Q_ENTENT)    	  //8 - entidade destino
							oMdlN9E:SetValue('N9E_LOJA'  , N7Q->N7Q_LOJENT)       //9 - loja destino	
							oMdlN9E:SetValue('N9E_QTDAGD', (QryN8O)->N8O_QTATEN)  //4 - ID entrega			
							
							(QryN8O)->(dbCloseArea())

							cCodSaf := N7Q->N7Q_CODSAF
							cCodPro := N7Q->N7Q_CODPRO 															

							N7S->( dbSkip() )
							
						endDo
					EndIf
					N7S->(dbCloseArea())
				EndIf
				N7Q->(dbCloseArea())				
			EndIf
			N9R->(dbCloseArea())
		Endif

		oModel:SetValue('AGRA550_NJJ','NJJ_CODPRO',cCodPro) //Cod. Produto
		oModel:SetValue('AGRA550_NJJ','NJJ_CODSAF',cCodSaf) //Cod. Saf
	Endif

	//Posicionar na N92 pela operação do GFE GWV_CDOPER e GWV_SEQ
	BeginSql Alias QryN92
		Select N92_CODIGO
		From %table:N92% N92
		Where N92.N92_FILIAL = %xFilial:N92%
		And N92.N92_CDOPER = %exp:GWV->GWV_CDOPER%
		And N92.N92_SEQOP  = %exp:GWV->GWV_SEQ% 
		And N92.%notDel%
	EndSql

	DbselectArea( QryN92 )
	(QryN92)->(dbGoTop())
	If ( QryN92 )->( !Eof() )	  
		oModel:SetValue('AGRA550_NJJ','NJJ_TOETAP',(QryN92)->N92_CODIGO) //Tipo 
	Endif
	(QryN92)->(dbCloseArea())	


	If ( lRet := oModel:VldData() )
		lRet := FWFormCommit(oModel)
	Else
		// Se os dados não foram validados obtemos a descrição do erro para gerar
		// LOG ou mensagem de aviso
		AutoGrLog(oModel:GetErrorMessage()[6])
		AutoGrLog(oModel:GetErrorMessage()[7])
		If !Empty(oModel:GetErrorMessage()[2]) .And. !Empty(oModel:GetErrorMessage()[9])
			AutoGrLog(oModel:GetErrorMessage()[2] + " = " + oModel:GetErrorMessage()[9])
		EndIf

		MostraErro()
	EndIf

	// Desativamos o Model
	oModel:DeActivate()

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} AXCTRFRT
//Função recebe filial/nota/serie do GFE e retorna filial/requisição para eles buscarem contrato logistico
@author marina.muller
@since 01/02/2019
@version 1.0
@return ${return}, ${return_description}
@param cFilNF, characters, descricao
@param cNumNF, characters, descricao
@param cSerNF, characters, descricao
@type function
/*/
Function AXCTRFRT(cFilNF, cNumNF, cSerNF)
	Local aArea     := GetArea()
	Local cAliasCTR := GetNextAlias()	
	Local cQry		:= ''
	Local cFilReq   := ""
	Local cReqFre   := ""

	cQry := " SELECT N9R.N9R_FILORI, N9R.N9R_IDREQ "
	cQry += "   FROM " + RetSqlName("N9R") + " N9R " 
	cQry += "  INNER JOIN " + RetSqlName("N9E") + " N9E "
	cQry += "     ON N9E.N9E_CODINE = N9R.N9R_CODINE "
	cQry += "    AND N9E.N9E_CODCTR = N9R.N9R_CODCTR "
	cQry += "    AND N9E.N9E_ITEM   = N9R.N9R_ITEM " 
	cQry += "    AND N9E.D_E_L_E_T_ = ' ' "
	cQry += "  INNER JOIN " + RetSqlName("NJM") + " NJM " 
	cQry += "     ON NJM.NJM_FILIAL = N9E.N9E_FILIAL "
	cQry += "    AND NJM.NJM_CODROM = N9E.N9E_CODROM "
	cQry += "    AND NJM.D_E_L_E_T_ = ' ' "   
	cQry += "  WHERE N9R.D_E_L_E_T_ = ' ' "  
	cQry += "    AND NJM.NJM_FILIAL = '" + cFilNF + "' "
	cQry += "    AND NJM.NJM_DOCNUM = '" + cNumNF + "' "
	cQry += "    AND NJM.NJM_DOCSER = '" + cSerNF + "' "

	//--Identifica se tabela esta aberta e fecha
	If Select(cAliasCTR) <> 0
		(cAliasCTR)->(dbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasCTR,.F.,.T.)
	IF (cAliasCTR)->(!Eof())
		cFilReq := (cAliasCTR)->N9R_FILORI 
		cReqFre := (cAliasCTR)->N9R_IDREQ
	EndIf
	(cAliasCTR)->(dbCloseArea())
	
	RestArea(aArea)

Return {cFilReq, cReqFre}

/*/{Protheus.doc} GFEAGR002
//Função gatilha valores para serem incluídos na GXT colunas GXT_CODCTR, GXT_CODCLI, GXT_TOMFRT, GXT_DTIENT
@author marina.muller
@since 06/02/2019
@version 1.0
@return ${return}, ${return_description}
@param cFilReq, characters, descricao
@param cReqFrt, characters, descricao
@type function
/*/
Function GFEAGR002(cFilReq, cReqFrt)
	Local cEntNNY := ""
	Local cLojNNY := ""
	Local cCodCtr := ""
	Local cEntN9A := ""
	Local cLojN9A := ""
	Local cCodCli := ""
	Local cTomFrt := "1" //1 - contratante
	Local dtIEnt
			
	//busca filtrando pelo ID da requisição os código das IE´s 
	N9R->(dbSelectArea('N9R'))
	N9R->(dbSetOrder(3))    	
	If N9R->(MsSeek(cFilReq+cReqFrt)) //N9R_FILORI+N9R_IDREQ

		//busca filtrando pelos códigos IE´s para buscar regra
		N7S->(dbSelectArea('N7S'))
		N7S->(dbSetOrder(3))    	
		If N7S->(MsSeek(FwxFilial("N7S")+N9R->N9R_CODINE+N9R->N9R_FILORI)) //N7S_FILIAL+N7S_CODINE+N7S_FILORG
			
			//busca pela entidade/loja origem o emitente (contratante)
		    cEntNNY := POSICIONE('NNY',1,FWxFilial('NNY')+N7S->N7S_CODCTR+N7S->N7S_ITEM, "NNY_ENTORI")
		    cLojNNY := POSICIONE('NNY',1,FWxFilial('NNY')+N7S->N7S_CODCTR+N7S->N7S_ITEM, "NNY_LOJORI")
		    cCodCtr := POSICIONE('NJ0',1,FWxFilial('NJ0')+cEntNNY+cLojNNY, "NJ0_CGC")

		    //busca pela entidade/loja entrega o emitente (destinatário)
		    cEntN9A := POSICIONE('N9A',1,FWxFilial('N9A')+N7S->N7S_CODCTR+N7S->N7S_ITEM+N7S->N7S_SEQPRI, "N9A_ENTENT")
		    cLojN9A := POSICIONE('N9A',1,FWxFilial('N9A')+N7S->N7S_CODCTR+N7S->N7S_ITEM+N7S->N7S_SEQPRI, "N9A_LJEENT")
		    cCodCli := POSICIONE('NJ0',1,FWxFilial('NJ0')+cEntN9A+cLojN9A, "NJ0_CGC")
		    
		    //data inicio de entrega contrato transporte
		    dtIEnt := N7S->N7S_DATINI
		EndIf
		N7S->(dbCloseArea())
	
	EndIf
	N9R->(dbCloseArea())

Return {cCodCtr, cCodCli, cTomFrt, dtIEnt}
 