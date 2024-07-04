#INCLUDE "AGRX500.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//===================================================
/*****  Funções da rotina AGRA500 - Romaneios  *****/
//===================================================

/*/{Protheus.doc} A500GERAOP
//Função MsExecAuto de ordem de produção 

@author  ana.olegini
@since   29/12/2017
@version P12
@param   cNumOP, characters, Numero da Ordem de Produção
@param   oModel, object, Modelo de dados
@param   nOperac, numeric, Operação (Inclusão/Alteração/Exclusão)
@return  !lMsErroAuto, Retorna verdadeiro ou falso

/*/
Function A500GERAOP(cNumOP, cProduto, nPsLiqu, cLocal, nOperac)
	Local aArea 		:= GetArea()
	Local aCampos		:= {}
	Local nModuloAGR  	:= nModulo

	//-- Variaveis privadas das rotinas MATA250 e MATA650 - não podem ser modificadas.
	Private lMSErroAuto := .F.
	Private lMSHelpAuto := .T.

	//-- Seta para o modulo de PCP
	nModulo := 10

	If Empty(cNumOP)
		//-- Busca proxima numeração da tabela SC2 
		cNumOP := GetSXENum('SC2','C2_NUM')
		SC2->(dbSetOrder(1))
		While SC2->(MsSeek(FwXFilial("SC2")+cNumOP))
			If ( __lSx8 )
				ConfirmSX8()
			EndIf
			cNumOP := GetSxENum("SC2","C2_NUM")
		EndDo
	endIf

	//-- Campos para enviar ao MSExecAuto
	AADD(aCampos, {"C2_NUM"		, cNumOP			,Nil})
	AADD(aCampos, {"C2_ITEM"	, "01"		   		,Nil})
	AADD(aCampos, {"C2_SEQUEN" 	, "001"				,Nil})
	AADD(aCampos, {"C2_PRODUTO"	, cProduto			,Nil})
	AADD(aCampos, {"C2_QUANT"  	, nPsLiqu			,Nil})	//-- Peso Liquido
	AADD(aCampos, {"C2_LOCAL"  	, cLocal			,Nil})		
	AADD(aCampos, {"C2_DATPRI" 	, ddatabase			,Nil})
	AADD(aCampos, {"C2_DATPRF" 	, ddatabase			,Nil})
	AADD(aCampos, {"C2_EMISSAO"	, ddatabase     	,Nil})
	AADD(aCampos, {"C2_TPOP"  	, "F"           	,Nil})	//-- F-Firme
	AADD(aCampos, {'C2_BATCH'	, 'S'				,Nil})
	AADD(aCampos, {'AUTEXPLODE'	, 'N'				,Nil})

	//-- O parâmetro AUTEXPLODE, é preenchido na execução da rotina automática para definir se as OPs intermediárias
	//-- e as solicitações de compras, que ainda não foram geradas, devem ser geradas automaticamente ou não.

	//-- Executa a rotina automatica - Ordem de Produção
	MSExecAuto({|x,y| mata650(x,y)},aCampos,nOperac) // 3=Inclusao, 5=Exclusão

	If lMsErroAuto
		MostraErro()
		RollBackSx8()
	Else
		cNumOP := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)
		ConfirmSx8()
	EndIf

	//-- Retorna ao modulo do Agroindustria
	nModulo := nModuloAGR
	RestArea(aArea)
Return(!lMsErroAuto)


/*/{Protheus.doc} A500APROD
//Função MsExecAuto de apontamento de produção 

@author  ana.olegini
@since 	 29/12/2017
@version P12
@param 	 cNumApon		, characters, Numero da Ordem de Produção
@param 	 cRomaneio		, characters, Romaneio
@param 	 cProduto		, characters, Produto
@param 	 nPsLiqu		, numeric, Peso líquido do produto
@param 	 cLocal			, characters, Local do produto
@param 	 nOperac		, numeric, Operação (Inclusão/Alteração/Exclusão)
@return  !lMsErroAuto	, Retorna verdadeiro ou falso
/*/
Function A500APROD(cNumOP, cRomaneio, cProduto, nPsLiqu, cLocal, nOperac )
	//Local oFieldNJJ	 := If( IsInCallStack("AGRA500"), oModel:GetModel("AGRA500_NJJ") , Nil )
	Local aArea 	 := GetArea()
	Local aMata      := {}
	Local aVetor	 := {}
	Local cNumApon   := CriaVar("NJJ_APONOP")
	Local cTM        := SuperGetMV("MV_AGRTMPR",.F.,"")
	Local nModuloAGR := nModulo
	Local cLote		 := ""			

	//-- Variaveis privadas das rotinas MATA250 e MATA650 - não podem ser modificadas.
	Private lMSErroAuto := .F.
	Private lMSHelpAuto := .T.

	//-- Busca o numero da ordem de producao MATA650
	If nOperac == 3	//Inclusão
		cNumApon  := NextNumDoc()
	EndIf

	cUMProdt := Posicione("SB1",1,FwXFilial("SB1")+cProduto,"B1_UM")
	nPRVALID := Posicione("SB1",1,FwXFilial("SB1")+cProduto,"B1_PRVALID")

	//-- Campos para enviar ao MSExecAuto
	AADD(aMata, {"D3_TM"     , cTM           		,Nil})
	AADD(aMata, {"D3_COD"    , cProduto		  		,Nil})
	AADD(aMata, {"D3_UM"     , cUMProdt	    		,Nil})
	AADD(aMata, {"D3_QUANT"  , nPsLiqu		 		,Nil})	//-- Peso Liquido 
	AADD(aMata, {"D3_LOCAL"  , cLocal				,Nil})		
	AADD(aMata, {"D3_DOC"    , cNumApon				,Nil})
	AADD(aMata, {"D3_OP"     , cNumOP	        	,Nil})
	AADD(aMata, {"D3_EMISSAO", dDataBase     		,Nil})
	AADD(aMata, {"AUTPRTOTAL", "S"           		,Nil})

	//-- Quando produto controlar rastro
	If Rastro(cProduto)
		
		DbSelectArea("NJM")
		DbSetOrder(1) //FILIAL+ROMANEIO
		
		If NJM->(MsSeek(NJJ->NJJ_FILIAL + cRomaneio))
			cLote := NJM->NJM_LOTCTL
		EndIf
		
		NJM->(dbCloseArea())
		
		AADD(aMata, {"D3_LOTECTL", cLote ,Nil})
		If nOperac == 3
			AADD(aMata, {"D3_DTVALID", dDataBase+nPRVALID   , Nil})
		EndIf
	EndIf	

	//-- Seta para o modulo de PCP
	nModulo := 10

	//-- Operação igual a uma exclusão
	If  nOperac = 5
		DbSelectArea("SD3")
		DbSetOrder(1) //D3_FILIAL+D3_OP+D3_COD+D3_LOCAL
		MsSeek(FwXFilial("SD3") + cNumOP + cProduto + cLocal ) 
	Endif

	//-- Executa rotina a automatica - Apontamento de Produção
	MsExecAuto( { |x,y| MATA250(x,y)},aMata,nOperac )	//-- 3=Inclusao, 5=Exclusao

	//-- Operação igual a uma exclusão 
	If nOperac == 5 .And. !lMsErroAuto
		AADD(aVetor,{"C2_NUM" 		, Substr(cNumOP,1 ,TamSx3("C2_NUM")[1]), NIL}) //Numero da OP
		AADD(aVetor,{"C2_ITEM"		, SubStr(cNumOP,TamSx3("C2_NUM")[1]+1,TamSx3("C2_ITEM")[1]), NIL}) //Item da OP
		AADD(aVetor,{"C2_SEQUEN"	, SubStr(cNumOP,TamSx3("C2_ITEM")[1]+1,TamSx3("C2_SEQUEN")[1]), NIL}) //Sequencia da OP

		//-- Executa rotina a automatica - Ordem de Produção
		MSExecAuto({|x,y| mata650(x,y)},aVetor,nOperac)
	Endif

	If lMsErroAuto
		MostraErro()
		Return .F.
	ElseIf 	nOperac == 3
		//-- Não foi possivel ler o modelo do OGA250, mesmo setando o Activate ele se perde. 
		//-- Validado com a PO - que por se tratando do OGA250 ser um fonte todo customizado, 
		//-- será utilizado o RecLock para gravar as informações de ordem de produção e status.
		If !IsInCallStack("AGRX500") 
			If RecLock( "NJJ", .F. )
				NJJ->NJJ_NUMOP	:= cNumOP  			//Relaciona o numero da ordem de produção ao romaneio
				NJJ->NJJ_APONOP	:= cNumApon			//Relaciona o numero do apontamento de produção ao romaneio

				If !IsInCallStack("AX500PSVen")
					NJJ->NJJ_STATUS := '3'
				EndIf
				
				NJJ->( msUnLock() )
			EndIf
		endIf
	EndIf

	//-- Operação igual a uma exclusão
	If  nOperac = 5
		SD3->(dbCloseArea())
	EndIf	

	//-- Retorna ao modulo do Agroindustria
	nModulo := nModuloAGR
	RestArea(aArea)
	
Return(!lMsErroAuto)


/*/{Protheus.doc} A500ESTOP
//Realiza o estorno do apontamento e ordem de producao
Realizar o controle de transação(Begin Transaction) na função que chama esta função
@author carlos.augusto/ana.olegini
@since 28/05/2018
@version 12.1.21
@type function
/*/
Function A500ESTOP()
	Local lRet	 := .T.
	Local aArea	 := GetArea()
	Local aApont := {}
	Local aExclui := {}
	Local lExcluiOP := .F.
	Local cItemOP   := ""
	Local cSeqOP	:= ""
	Local cNumAx	:= ""	
	Private lMsErroAuto := .f.	
	
	    if NJJ->( NJJ_TIPO ) == "1" //entrada por produção
	       
	       	DbSelectArea("SD3")
		    SD3->( dbSetOrder( 2 ) )
		    If SD3->( dbSeek( FwxFilial( "SD3" ) + NJJ->( NJJ_APONOP ) ) )
		    
				Aadd(aApont,{"D3_DOC"	 ,SD3->D3_DOC		,Nil})
				Aadd(aApont,{"D3_OP"	 ,SD3->D3_OP		,Nil})
				Aadd(aApont,{"D3_COD"    ,SD3->D3_COD		,Nil})
				Aadd(aApont,{"D3_UM"     ,SD3->D3_UM		,Nil})
				Aadd(aApont,{"D3_QUANT"  ,SD3->D3_QUANT		,Nil}) 
				Aadd(aApont,{"D3_LOCAL"  ,SD3->D3_LOCAL		,Nil})
				Aadd(aApont,{"D3_CC"     ,SD3->D3_CC		,Nil})
				Aadd(aApont,{"D3_EMISSAO",SD3->D3_EMISSAO	,Nil}) 
				Aadd(aApont,{"D3_LOTECTL",SD3->D3_LOTECTL	,Nil})
				Aadd(aApont,{"D3_DTVALID",SD3->D3_DTVALID	,Nil}) 
				Aadd(aApont,{"D3_NUMSEQ" ,SD3->D3_NUMSEQ    ,Nil})
				Aadd(aApont,{"D3_CHAVE"	 ,SD3->D3_CHAVE		,Nil})
				aAdd(aApont,{"INDEX"     , 4        , Nil})
		    
				//MsExecAuto( {| x, y, z | MatA241( x, y, z ) }, {}, Nil, 5 )
		        MsExecAuto({|x,y| MATA250(x,y)},aApont,5)
		        If lMsErroAuto
		            MostraErro( )
		            lRet := .f.
		        EndIf
		        SD3->(dbCloseArea())
		        
		        If lRet
		        
					// Refaz o tratamento da OP
					DbSelectArea("SC2")
					
					SC2->(dbSetOrder(1))
					If SC2->( dbSeek( FwxFilial( "SC2" ) + NJJ->( NJJ_NUMOP ) ))
						cNumAx		  := SC2->C2_NUM
						cItemOP       := SC2->C2_ITEM
						cSeqOP        := SC2->C2_SEQUEN
						If A650DefLeg(2)
							lExcluiOP := .T.
						Endif				
					EndIf
					
					If lExcluiOP
						AADD(aExclui,{'C2_NUM' 		, cNumAx , NIL}) //Numero da OP
						AADD(aExclui,{'C2_ITEM'		, cItemOP, NIL}) //Item da OP
						AADD(aExclui,{'C2_SEQUEN'	, cSeqOP , NIL}) //Sequencia da OP
	
						//-----------------------------
						// Executa rotina a automatica
						//-----------------------------
						MSExecAuto({|x,y| MATA650(x,y)},aExclui, 5)
						If lMsErroAuto
							MostraErro( )
							lRet := .f.
						EndIf
						SC2->(dbCloseArea())
					Endif
		        EndIf
		    Else
		        Help( , , STR0007, , STR0051, 1, 0 ) //"AJUDA"###"Movimento de estoque nao localizado!"
		        lRet := .f.
		    EndIf
	               
	       If lRet
	           dbSelectArea( "NJJ" )
	           If RecLock( "NJJ", .f. )
	                   NJJ->( NJJ_NUMOP ) := ""
	                   NJJ->( NJJ_APONOP ) := ""
	                   NJJ->( NJJ_STATUS ) := "1"            
	               msUnLock()
	           EndIf
	       EndIf
	       
	    EndIf  

	RestArea( aArea )	
	
Return lRet


/*/{Protheus.doc} NextNumDoc
//Retorna o proximo numero de documento disponivel
@author ana.olegini
@since 29/12/2017
@version P12
/*/
Static Function NextNumDoc()
	Local aAreaAtu 	:= GetArea()
	Local cNumDoc 	:= ""
	Local cMay		:= ""

	//----------------------------------------------------
	//Inicializa o numero do Documento com o ultimo + 1 
	//----------------------------------------------------
	dbSelectArea("SD3")
	cNumDoc := NextNumero("SD3",2,"D3_DOC",.T.)
	cNumDoc := A261RetINV(cNumDoc)
	dbSetOrder(2)
	MsSeek(cFilAnt+cNumDoc)
	cMay := "SD3"+Alltrim(cFilAnt)+cNumDoc
	While SD3->(D3_FILIAL+D3_DOC) == cFilAnt + cNumDoc .Or. !MayIUseCode(cMay)
		If SD3->D3_ESTORNO # "S"
			cNumDoc := Soma1(cNumDoc)
			cMay := "SD3"+Alltrim(cFilAnt)+cNumDoc
		EndIf
		dbSkip()
	EndDo
	SD3->(dbCloseArea())

	RestArea( aAreaAtu )
Return( cNumDoc )


/*/{Protheus.doc} AGRX500DXL
//Função para salvar peso no fardão e no vínculo dele com o romaneio
@author 	brunosilva
@since 		27/03/2018
@version 	P12
@return 	lRetorno, Retorna verdadeiro ou falso
/*/
Function AGRX500DXL(nPesoLiq, lRevisaOP, cNumOP)
	Local aArea  		:= GetArea()
	Local aAreaDX0  	:= DX0->(GetArea())
	Local oModel  		:= Nil
	Local oMldNJJ 		:= Nil
	Local oMldDX0 		:= Nil
	Local lRetorno 		:= .T.
	Local nQtdVinc  	:= 0
	Local cTipo     	:= ""
	Local cCodUnb   	:= ""
	Local nX			:= 0
	Local nPesTotEst 	:= 0
	Local nPesLiqRat	:= 0
	Local lGeraOP		:= .F.
	Local cFilOri	 	:= cFilAnt	//--SALVA A FILIAL LOGADA
	Local cFilCli		:= ""
	Local cMsgHelp		:= ""
	Local lValido		:= .F.
	
	Default lRevisaOP	:= .F.	
	Default cNumOP		:= ""
	
	if EMPTY(oModel)
		oModel := IIF(IsInCallStack("AGRA500"),FWLoadModel('AGRA500'),FWLoadModel('OGA250'))
		oModel:Activate()
	Else
		oModel := FWModelActive()
	EndIf
	
	oMldNJJ 	:= IIF(FWIsInCallStack("AGRA500"),oModel:GetModel('AGRA500_NJJ'),oModel:GetModel('NJJUNICO'))
	
	cTipo     := oMldNJJ:GetValue('NJJ_TIPO')
	cCodUnb   := oMldNJJ:GetValue('NJJ_CODUNB')
	
	//--Busca no rastro do fardão se para o romaneio possui fardão vinculado.
	DbSelectArea("DX0")
	DbSetOrder(3)	//Filial + Numero do Romaneio
	If DbSeek(FWxFilial("DX0")+oMldNJJ:GetValue('NJJ_CODROM'))
		oMldDX0  := oModel:GetModel('AGRA500_DX0') 	//Vinculo FardaoxRomaneio
		nQtdVinc := oMldDX0:Length() 				//Quantidade de fardões vinculados
		lValido	 := !EMPTY(oMldDX0:GetValue('DX0_FARDAO')) //Linha está em branco
	
	//--Para os tipos de transferencias e produção - valida se fardão
	ElseIf cTipo $ "A|B|1"
		nQtdVinc := 1	//Quantidade de fardões vinculados - envia 1 para entrar no FOR.
	EndIf
	
	//--Rateiro do Peso liquido := Peso liquido do romaneio / quantidade de fardao vinculado
	nPesLiqRat := (nPesoLiq / nQtdVinc)
	
	if lValido
		For nX := 1 to nQtdVinc			
			oMldDX0:GoLine( nX )
			
			dbSelectArea("DX0")
			DX0->(dbSetOrder(1))
			If DX0->(MsSeek(FWxFilial("DX0")+oMldDX0:GetValue('DX0_CODROM')+oMldDX0:GetValue('DX0_ITEM')+oMldDX0:GetValue('DX0_NRROM')))
				If RecLock( "DX0", .F. )
					DX0->DX0_PSLIQU	:= nPesLiqRat		
					DX0->( msUnLock() )
				EndIf
			Else
				//--Quando é executado pelo GFE a função HELP não é executada.
				//--Nesse cenário devemos utilizar a função MSGINFO.		
				If FwIsInCallStack("GFEA523")		
					cMsgHelp := STR0052 //"Fardão não encontrado."
					MSGINFO(cMsgHelp,STR0053 )	//'HELP'
				Else
					Help( ,, STR0047,, STR0042, 1, 0) //"Fardão não encontrado." //"Erro"
				EndIf
				lRetorno := .F.
			EndIf		
			
			restArea(aAreaDX0)
			
			//Atualiza o valor da tabela de fardão
			dbSelectArea("DXL")
			DXL->(dbSetOrder(2))
			If DXL->(MsSeek(FWxFilial("DXL")+oMldDX0:GetValue('DX0_CODUNI')))
				If RecLock( "DXL", .F. )
					
					DXL->DXL_PSLIQU	:= nPesLiqRat	//--Pesagem do Romaneio NJJ
					
					if DXL->DXL_PSLIQU <> DXL->DXL_PSESTI
						lGeraOP := .T.
						nPesTotEst := nPesTotEst + DXL->DXL_PSESTI				
					endIf						
					
					if !(IsInCallStack('A500GerRom'))
						if cTipo $ '1|3|5|7|9|A'	
							DXL->DXL_STATUS := '3'	//--Status de disponivel	
							DXL->DXL_CODUNB := cCodUnb				
						ElseIf cTipo $ '2|4|6|8|B'	
							DXL->DXL_STATUS := '2'	//--Status de 'em romaneio de entrada'
						EndIF
					endIf
					
					DXL->( msUnLock() )
				EndIf
			Else
				//--Quando é executado pelo GFE a função HELP não é executada.
				//--Nesse cenário devemos utilizar a função MSGINFO.		
				If FwIsInCallStack("GFEA523")		
					cMsgHelp := STR0052 //"Fardão não encontrado."
					MSGINFO(cMsgHelp,STR0053 )	//'HELP'
				Else
					Help( ,, STR0047,, STR0042, 1, 0) //"Fardão não encontrado." //"Erro"
				EndIf			
				lRetorno := .F.
			EndIf
			
			DXL->(dbCloseArea())
		Next nX
	else
		//--Quando é executado pelo GFE a função HELP não é executada.
		//--Nesse cenário devemos utilizar a função MSGINFO.		
		If FwIsInCallStack("GFEA523")		
			cMsgHelp := STR0052 //"Fardão não encontrado."
			MSGINFO(cMsgHelp,STR0053 )	//'HELP'
		Else
			Help( ,, STR0047,, STR0042, 1, 0) //"Fardão não encontrado." //"Erro"
		EndIf	
		lRetorno := .F.
	endIf
	
	if lRevisaOP .AND. lGeraOP
	
		//verifica se a produção é de outra filial
		cFilCli := AGRX500POF(NJJ->NJJ_CODENT, NJJ->NJJ_LOJENT)
				
		if trim(cFilCli) <> ""
				
			//--ALTERA A FILIAL CORRENTE PARA A FILIAL DA ENTIDADE
			//================================
			cFilAnt := cFilCli			
			//================================
		endIf		
		
		For nX := 1 to nQtdVinc			
		
			oMldDX0:GoLine( nX )
			
			if nPesoLiq > nPesTotEst //deve gerar OP de complemento
				IF .NOT. Empty(NJJ->NJJ_CODPRO) .AND. .NOT. Empty(NJJ->NJJ_PSLIQU) .AND. .NOT. Empty(NJJ->NJJ_LOCAL)
					lRetorno := AX500OPCom(cNumOP, (nPesoLiq - nPesTotEst))
					
					if .NOT. lRetorno
						Return .F.
					endIf
				Endif
				exit
			elseif nPesoLiq < nPesTotEst //deve gerar estorno da OP antiga e gerar nova OP de devolução
				lRetorno := AX500Estrn(NJJ->NJJ_CODSAF, oMldDX0:GetValue('DX0_FARDAO'))
				
				if .NOT. lRetorno
					Return .F.
				endIf
				
				if nX == nQtdVinc
					IF .NOT. Empty(NJJ->NJJ_CODPRO) .AND. .NOT. Empty(NJJ->NJJ_PSLIQU) .AND. .NOT. Empty(NJJ->NJJ_LOCAL)
						AX500OPCom(cNumOP, nPesoLiq)
					endIf
				endIf
			endIf
		Next nX
		
		cFilAnt := cFilOri
	EndIf
	RestArea(aArea)

Return lRetorno


/*/{Protheus.doc} AGRX500POF
//Verifica se a entidade é de outra filial
@author silvana.torres
@since 05/02/2018
@version undefined
@param cCodEnt, characters, descricao
@param cLojEnt, characters, descricao
@type function
/*/
Function AGRX500POF(cCodEnt, cLojEnt)

	Local aArea     := GetArea()
	Local cFilCli	:= ""

	DbSelectArea("NJ0")
	NJ0->(dbSetOrder(1)) //Filial+Entidade+Loja

	if NJ0->(MsSeek(FwXFilial('NJ0')+cCodEnt+cLojEnt))
		if NJ0->NJ0_CODCRP <> ""
			cFilCli := NJ0->NJ0_CODCRP
		endIf
	endIf
	NJ0->(dbCloseArea())

	RestArea(aArea)

Return cFilCli


/*/{Protheus.doc} AGRX500ENL
//Busca a entidade e loja para gravar pendência
@author marina.muller
@since 06/03/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilTemp, characters, descricao
@type function
/*/
Function AGRX500ENL(cFilTemp)
	Local aArea   := GetArea()
	Local cCodEnt := ""
	Local cLojEnt := ""

	DbSelectArea("NJ0")
	NJ0->(dbSetOrder(5)) 

	if NJ0->(MsSeek(FwXFilial('NJ0')+cFilTemp))  //Filial + CODCRP
		cCodEnt := NJ0->NJ0_CODENT
		cLojEnt := NJ0->NJ0_LOJENT
	endIf
	NJ0->(dbCloseArea())

	RestArea(aArea)

Return {cCodEnt, cLojEnt} 


/*/{Protheus.doc} AGRX500MO
//verifica se alguma etapa do tipo de operação tem a flag movimenta origem marcada
@author silvana.torres
@since 06/02/2018
@version undefined
@param cTpOper, characters, descricao
@type function
/*/
Function AGRX500MO(cTpOper)

	Local aArea     := GetArea()
	Local lRet		:= .F.
	
	dbSelectArea("N92")	
	dbSetOrder(1)
	N92->(msSeek(FWxFilial("N92")+cTpOper))
	if N92->N92_MOVORI
		lRet := .T.
	endIf	

	RestArea(aArea)

Return lRet


/*/{Protheus.doc} AGRX500LP
//verifica se alguma etapa do tipo de operação tem a flag Lança produção marcada
@author silvana.torres
@since 09/02/2018
@version undefined
@param cTpOper, characters, descricao
@type function
/*/
Function AGRX500LP(cTpOper)

	Local aArea     := GetArea()
	Local lRet		:= .F.
	
	dbSelectArea("N92")	
	dbSetOrder(1)
	N92->(msSeek(FWxFilial("N92")+cTpOper))
	if N92->N92_LANCPR
		lRet := .T.
	endIf

	RestArea(aArea)

Return lRet


/*/{Protheus.doc} AGRX500GPR
//verifica se alguma etapa do tipo de operação tem a flag Pré-romaneio marcada
@author silvana.torres
@since 09/02/2018
@version undefined
@param cTpOper, characters, descricao
@type function
/*/
Function AGRX500GPR(cTpOper)
	Local aArea     := GetArea()
	Local lRet		:= .F.
	
	dbSelectArea("N92")	
	dbSetOrder(1)
	If N92->(msSeek(FWxFilial("N92")+cTpOper))
		If N92->N92_GERROM == '1' .OR. N92->N92_GERROM == '2' 
			lRet := .T.
		EndIf
	EndIf
	RestArea(aArea)

Return lRet


/*/{Protheus.doc} AGRX500AQu
//verifica se alguma etapa do tipo de operação tem a flag Classificação marcada
@author silvana.torres
@since 26/03/2018
@version undefined
@param cTpOper, characters, descricao
@type function
/*/
Function AGRX500AQu(cTpOper)

	Local aArea     := GetArea()
	Local lRet		:= .F.
	Local cAlias	:= GetNextAlias()
	Local cQuery	:= ""

	cQuery := " SELECT 1 " 
	cQuery += "   FROM " + RetSqlName('N94')+ " N94 "
	cQuery += "  WHERE N94_FILIAL 	= '"+ FWxFilial("N94")	+"'"
	cQuery += "	   AND N94_CODTO 	= '"+ cTpOper 	+"'	"
	cQuery += "	   AND N94_ANAQUA 	= 'T' "	

	cQuery := ChangeQuery( cQuery )

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.T.,.T.)

	IF (cAlias)->(!Eof())
		lRet := .T.
	endIf

	RestArea(aArea)

Return lRet


/*/{Protheus.doc} A500LanCla
//verifica se alguma etapa do tipo de operação tem a flag Classificação marcada
@author silvana.torres
@since 26/03/2018
@version undefined
@param cCodRom, characters, descricao
@type function
/*/
Function A500LanCla(cCodRom)

	Local aArea	:= GetArea()
	Local lRet	:= .F.		
	
	DbSelectArea("NJK")
	NJK->(dbSetOrder(1)) 

	if NJK->(MsSeek(FwXFilial('NJK')+cCodRom))  //Filial + cCodRom
		lRet := .T.
	endIf
	NJK->(dbCloseArea())

	RestArea(aArea)

Return lRet


/*/{Protheus.doc} A500GerRom
//Preparação dos dados para geração de romaneio 
@author silvana.torres
@since 09/02/2018
@version undefined
@param cTpRom, characters, descricao
@param cTpOper, characters, descricao
@param cFilOri, characters, descricao
@param lCopPeso, logical, descricao
@type function
/*/
Function A500GerRom( cTpRom, cTpOper, cFilOri, lCopPeso, lAlgodao, cRomPar, oModel)
	Local oMldDX0 		:= oModel:GetModel('AGRA500_DX0') //Vinculo FardaoxRomaneio
	Local oMldNJK 		:= oModel:GetModel('NJKUNICO') 
	Local lContinua 	:= .T.
	Local aCposCab 		:= {}	//Vetor para receber dados do cabeçalho do romaneio
	Local aCposDet 		:= {}	//Vetor para receber dados dos itens do romaneio
	Local aCposFar		:= {}   //Vetor para receber dados dos itens doS fardões vinculados
	Local aCposNJK		:= {}
	Local aAux			:= {}	//Auxiliar 
	Local aFard			:= {}
	Local aNJK			:= {}
	Local cTpOpRe		:= ""
	Local cLocal		:= ""
	Local cTes			:= ""
	Local cCodEntDes	:= ""
	Local cLojEntDes	:= ""
	Local cTipoOri		:= ""
	Local nJ	
	Local cGerRom		:= ""
	Local cHrAgen		:= ""
	Local cUNBDest       := ""
	
	Default lCopPeso	:= .F.
	Default lAlgodao	:= .F.

	Private cAliasNJM	:= GetNextAlias()     // Retorna o próximo Alias disponível

	DbSelectArea("N92")
	N92->(dbSetOrder(1))
	if N92->(MsSeek(FwXFilial("N92")+cTpOper))
		cLocal  := N92->N92_LOCAL
		cTpOpRe := N92->N92_TPOPRE
		cGerRom	:= N92->N92_GERROM 
	endIf
	N92->( DbCloseArea())
	
	DbSelectArea("N92")
	N92->(dbSetOrder(1))
	if N92->(MsSeek(FwXFilial("N92")+cTpOpRe))
		aAdd( aCposCab, { 'NJJ_TIPO'	, N92->N92_TIPO  })
		cTipoOri := N92->N92_TIPO
	endIf
	N92->( DbCloseArea())
	
	DbSelectArea("NJ0")
	NJ0->(dbSetOrder(5)) //Filial+CODCRP

	if NJ0->(MsSeek(FwXFilial('NJ0')+cFilOri))
		cCodEntDes := NJ0->NJ0_CODENT
		cLojEntDes := NJ0->NJ0_LOJENT
	endIf
	NJ0->( DbCloseArea())
	
	//busca TES inteligente 
	cTes := AGRX500TIN(cTpOper,;        //tipo operação N92
	                   cTipoOri,;       //tipo romaneio N92 (E/S)
	                   cCodEntDes,;     //entidade (cliente/ fornecedor)
	                   cLojEntDes,;     //loja entidade
	                   NJJ->NJJ_CODPRO) //produto  

	aAdd( aCposCab, { 'NJJ_CODENT'	, PADR(cCodEntDes,TamSX3('NJJ_CODENT')[1]) 	  })
	aAdd( aCposCab, { 'NJJ_LOJENT'	, PADR(cLojEntDes,TamSX3('NJJ_LOJENT')[1]) 	  })
	aAdd( aCposCab, { 'NJJ_CODSAF'	, NJJ->NJJ_CODSAF })
	aAdd( aCposCab, { 'NJJ_CODPRO'	, NJJ->NJJ_CODPRO })
	aAdd( aCposCab, { 'NJJ_UM1PRO'	, NJJ->NJJ_UM1PRO })
	aAdd( aCposCab, { 'NJJ_LOCAL'	, PADR(cLocal,TamSX3('NJJ_LOCAL')[1])  })
	aAdd( aCposCab, { 'NJJ_TABELA'	, NJJ->NJJ_TABELA })
	aAdd( aCposCab, { 'NJJ_PSSUBT'	, NJJ->NJJ_PSSUBT })		
	aAdd( aCposCab, { 'NJJ_TPFORM'	, IIf( NJJ->NJJ_TPFORM = "1", "2", "1" ) }) 	//Formulario Proprio? 
	aAdd( aCposCab, { 'NJJ_NFPSER' 	, NJJ->NJJ_NFPSER })	//Serie da NF do Produtor
	aAdd( aCposCab, { 'NJJ_NFPNUM'	, NJJ->NJJ_NFPNUM })	//Numero da NF do Produtor	
	aAdd( aCposCab, { 'NJJ_QTDFIS'	, NJJ->NJJ_QTDFIS }) 		
	aAdd( aCposCab, { 'NJJ_VLRUNI'	, NJJ->NJJ_VLRUNI })	
	aAdd( aCposCab, { 'NJJ_STSCLA'	, NJJ->NJJ_STSCLA })
		
	aAdd( aCposCab, { 'NJJ_OBS'		, STR0023 + NJJ->NJJ_FILIAL + STR0001 + ": "+ NJJ->NJJ_CODROM }) //"Filial Origem:"#" Romaneio: "
	aAdd( aCposCab, { 'NJJ_TOETAP'	, PADR(cTpOpRe,TamSX3('NJJ_TOETAP')[1])       })
	
	If cGerRom = "1"
		aAdd( aCposCab, { 'NJJ_STATUS'	, "5" 			  }) //pendente de aprovação
	ElseIf cGerRom = "2"
		aAdd( aCposCab, { 'NJJ_STATUS'	, "6" 			  }) //agendamento previsto
	EndIf
	
	aAdd( aCposCab, { 'NJJ_TES'	    , PADR(cTes,TamSX3('NJJ_TES')[1])    		  })
	aAdd( aCposCab, { 'NJJ_TALHAO'	, NJJ->NJJ_TALHAO })
	aAdd( aCposCab, { 'NJJ_CODVAR'	, NJJ->NJJ_CODVAR })
	aAdd( aCposCab, { 'NJJ_FAZ' 	, NJJ->NJJ_FAZ    })

	//Busca unidade beneficiamento da filial destino somente quando for entrada
	If cTipoOri == "A"
	   cUNBDest := AGRX500UNB()
	EndIf   
	aAdd( aCposCab, { 'NJJ_CODUNB' 	, cUNBDest })
	
	if lCopPeso
		aAdd( aCposCab, { 'NJJ_DATPS1'	, NJJ->NJJ_DATPS1 })
		aAdd( aCposCab, { 'NJJ_HORPS1'	, NJJ->NJJ_HORPS1 })
		aAdd( aCposCab, { 'NJJ_PESO1'	, NJJ->NJJ_PESO1  })
		aAdd( aCposCab, { 'NJJ_MODPS1'	, NJJ->NJJ_MODPS1 })
		aAdd( aCposCab, { 'NJJ_DATPS2'	, NJJ->NJJ_DATPS2 })
		aAdd( aCposCab, { 'NJJ_HORPS2'	, NJJ->NJJ_HORPS2 })
		aAdd( aCposCab, { 'NJJ_PESO2'	, NJJ->NJJ_PESO2  })
		aAdd( aCposCab, { 'NJJ_MODPS2'	, NJJ->NJJ_MODPS2 })
		
		aAdd( aCposCab, { 'NJJ_PSBASE'	, NJJ->NJJ_PSBASE })
		aAdd( aCposCab, { 'NJJ_PSLIQU'	, NJJ->NJJ_PSLIQU })
		aAdd( aCposCab, { 'NJJ_PESO3'	, NJJ->NJJ_PESO3  })
	endIf
	
	aAdd( aCposCab, { 'NJJ_PLACA'	, NJJ->NJJ_PLACA 	})
	aAdd( aCposCab, { 'NJJ_CODTRA'	, NJJ->NJJ_CODTRA	})
	aAdd( aCposCab, { 'NJJ_CGC'		, NJJ->NJJ_CGC		})
	aAdd( aCposCab, { 'NJJ_CODMOT'	, NJJ->NJJ_CODMOT	})
	aAdd( aCposCab, { 'NJJ_TPFRET'	, NJJ->NJJ_TPFRET	})
	aAdd( aCposCab, { 'NJJ_ENTENT'	, NJJ->NJJ_ENTENT	})
	aAdd( aCposCab, { 'NJJ_ENTLOJ'	, NJJ->NJJ_ENTLOJ	})
	
	If .NOT. empty(NJJ->NJJ_DTAGEN) 
		aAdd( aCposCab, { 'NJJ_DTAGEN'	, NJJ->NJJ_DTAGEN	})
	Else
		aAdd( aCposCab, { 'NJJ_DTAGEN'	, dDatabase			})
	EndIf
	
	If .NOT. empty(NJJ->NJJ_HRAGEN)
		aAdd( aCposCab, { 'NJJ_HRAGEN'	, NJJ->NJJ_HRAGEN	})
	Else
		cHrAgen	:= IncTime(Time(), 1)
		cHrAgen	:= substring(cHrAgen,1,2) + substring(cHrAgen,4,2)
		
		aAdd( aCposCab, { 'NJJ_HRAGEN'	, cHrAgen			})
	EndIf

	//================================================================================
	// ITENS DO ROMANEIO
	//================================================================================	
	cQryNJM := " SELECT * "
	cQryNJM +=   " FROM "+ RetSqlName("NJM") + " NJM " 
	cQryNJM +=  " WHERE NJM.D_E_L_E_T_ = '' "
	//cQryNJM +=    " AND NJM.NJM_FILIAL = '" + fwxFilial( 'NJM' ) + "'"
	cQryNJM +=    " AND NJM.NJM_FILIAL = '" + cFilOri + "'"				//--Deve ser passado a filial Origem
	cQryNJM +=    " AND NJM.NJM_CODROM = '" + NJJ->NJJ_CODROM  + "'" 
	cQryNJM +=    " AND NJM.NJM_CODENT = '" + NJJ->NJJ_CODENT  + "'" 
	cQryNJM +=    " AND NJM.NJM_LOJENT = '" + NJJ->NJJ_LOJENT  + "'" 
	cQryNJM := ChangeQuery(cQryNJM)
	//-- VERIFICA SE EXISTE - SE SIM APAGA TABELA TEMP
	If Select(cAliasNJM) <> 0
		(cAliasNJM)->(dbCloseArea())
	EndIf
	//-- DEFINE UM ARQUIVO DE DADOS COMO UMA AREA DE TRABALHO DISPONIVEL NA APLICACAO
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryNJM),(cAliasNJM),.T.,.T.)

	dbSelectArea(cAliasNJM)
	(cAliasNJM)->(dbGoTop())	
	While ((cAliasNJM))->(!Eof()) 
		aAdd( aAux, { 'NJM_ITEROM' 	, (cAliasNJM)->NJM_ITEROM 					} )
		aAdd( aAux, { 'NJM_CODENT'	, PADR(cCodEntDes,TamSX3('NJJ_CODENT')[1]) 	} )
		aAdd( aAux, { 'NJM_LOJENT'	, PADR(cLojEntDes,TamSX3('NJJ_LOJENT')[1]) 	} )
		aAdd( aAux, { 'NJM_CODSAF'	, (cAliasNJM)->NJM_CODSAF 					} )
		aAdd( aAux, { 'NJM_CODPRO'	, (cAliasNJM)->NJM_CODPRO 					} )
		aAdd( aAux, { 'NJM_LOCAL'	, PADR(cLocal,TamSX3('NJM_LOCAL')[1])		} )		
		aAdd( aAux, { 'NJM_PERDIV'	, (cAliasNJM)->NJM_PERDIV 					} )
		aAdd( aAux, { 'NJM_QTDFCO'	, (cAliasNJM)->NJM_QTDFCO 					} )		
		aAdd( aAux, { 'NJM_TES'		, PADR(cTes,TamSX3('NJJ_TES')[1])			} )	
		aAdd( aAux, { 'NJM_TIPO'	, cTipoOri	  			  					} )		
		aAdd( aAux, { 'NJM_LOTCTL'	, (cAliasNJM)->NJM_LOTCTL 					} )
		aAdd( aAux, { 'NJM_NMLOT'	, (cAliasNJM)->NJM_NMLOT  					} )
		aAdd( aAux, { 'NJM_LOCLIZ'	, (cAliasNJM)->NJM_LOCLIZ 					} )
		aAdd( aAux, { 'NJM_CONDPG'	, (cAliasNJM)->NJM_CONDPG					} )	
		(cAliasNJM)->( dbSkip() )
	EndDo

	aAdd( aCposDet, aAux )	
	
	If lAlgodao
		//Achar os fardões vinculados e mandar por parametro
		For nJ := 1 to oMldDX0:Length()
			oMldDX0:GoLine( nJ )
			aFard:= {}
			aAdd(aFard, {'DX0_FILIAL', cFilAnt})
			aAdd(aFard, {'DX0_ITEM'  , oMldDX0:GetValue( "DX0_ITEM"   )})
			aAdd(aFard, {'DX0_FARDAO', oMldDX0:GetValue( "DX0_FARDAO" )})
			aAdd(aFard, {'DX0_CODPRO', oMldDX0:GetValue( "DX0_CODPRO" )})
			aAdd(aFard, {'DX0_CODVAR', oMldDX0:GetValue( "DX0_CODVAR" )})
			aAdd(aFard, {'DX0_TALHAO', oMldDX0:GetValue( "DX0_TALHAO" )})
			aAdd(aFard, {'DX0_CODUNB', cUNBDest    				       })
			aAdd(aFard, {'DX0_FAZ'   , oMldDX0:GetValue( "DX0_FAZ" 	  )})
			aAdd(aFard, {'DX0_CODUNI', oMldDX0:GetValue( "DX0_CODUNI" )})
			aAdd(aFard, {'DX0_TIPROM', cTipoOri						   })
			
			
			aAdd( aCposFar, aFard )
		Next nJ
	Else
		For nJ := 1 to oMldNJK:Length()
			oMldNJK:GoLine( nJ )
			aNJK:= {}
			aAdd(aNJK, {'NJK_FILIAL', cFilAnt})
			aAdd(aNJK, {'NJK_ITEM'  , oMldNJK:GetValue( "NJK_ITEM" 	 )})
			aAdd(aNJK, {'NJK_TPCLAS', oMldNJK:GetValue( "NJK_TPCLAS" )})
			aAdd(aNJK, {'NJK_CODDES', oMldNJK:GetValue( "NJK_CODDES" )})
			aAdd(aNJK, {'NJK_DESDES', oMldNJK:GetValue( "NJK_DESDES" )})
			aAdd(aNJK, {'NJK_BASDES', oMldNJK:GetValue( "NJK_BASDES" )})
			aAdd(aNJK, {'NJK_OBRGT' , oMldNJK:GetValue( "NJK_OBRGT"  )})
			aAdd(aNJK, {'NJK_PERDES', oMldNJK:GetValue( "NJK_PERDES" )})
			aAdd(aNJK, {'NJK_READES', oMldNJK:GetValue( "NJK_READES" )})
			aAdd(aNJK, {'NJK_QTDDES', oMldNJK:GetValue( "NJK_QTDDES" )})
			aAdd(aNJK, {'NJK_DESRES', oMldNJK:GetValue( "NJK_DESRES" )})
			aAdd(aNJK, {'NJK_RESINF', oMldNJK:GetValue( "NJK_RESINF" )})
						
			aAdd( aCposNJK, aNJK )
		Next nJ
	EndIf

	If !A500IncRom( 'NJJ', 'NJM', aCposCab, aCposDet, .T.,aCposFar, aCposNJK, lAlgodao, NJJ->NJJ_PSLIQU, cGerRom, PADR(cTpOpRe,TamSX3('NJJ_TOETAP')[1]), @cRomPar)
		lContinua := .F.
	EndIf		
	(cAliasNJM)->( DbCloseArea())

Return(lContinua)


/*/{Protheus.doc} A500IncRom
//Geração do romaneio
@author silvana.torres
@since 09/02/2018
@version undefined
@param cMaster, characters, descricao
@param cDetail, characters, descricao
@param aCpoMaster, array, descricao
@param aCpoDetail, array, descricao
@param lGrava, logical, descricao
@type function
/*/
Static Function A500IncRom( cMaster, cDetail, aCpoMaster, aCpoDetail, lGrava, aCposFar, aCposNJK, lAlgodao, lPsLiqu, cGerRom, cTpOpRe, cRomPar)
	Local oModel, oAux, oStruct
	Local nI 			:= 0
	Local nJ 			:= 0	
	Local nPos 			:= 0
	Local nItErro 		:= 0
	Local nFarErro  	:= 0
	Local nNJKErro		:= 0
	Local aAux 			:= {}
	Local lContinua		:= .T.
	Local lAux 			:= .T.
	Local aArea			:= GetArea()
	Local cDesModNJJ	:= ""
	Local cDesModNJM	:= ""
	Local cDesModDX0	:= ""
	Local cDesModNJK	:= ""
	
	Private _cTpOpRe	:= "" 

	dbSelectArea( cDetail )
	dbSetOrder( 1 )
	dbSelectArea( cMaster )
	dbSetOrder( 1 )

	If cGerRom = "2"
		oModel 		:= FWLoadModel( 'AGRA550' )
		cDesModNJJ	:= "AGRA550_NJJ" 
		cDesModNJM	:= "AGRA550_NJM"
		cDesModDX0	:= "AGRA550_DX0"
		cDesModNJK  := "AGRA550_NJK"
		_cTpOpRe	:= cTpOpRe
	Else
		oModel 		:= FWLoadModel( 'AGRA500' )
		cDesModNJJ	:= "AGRA500_NJJ"
		cDesModNJM	:= "AGRA500_NJM"
		cDesModDX0	:= "AGRA500_DX0"
		cDesModNJK  := "NJKUNICO"
	EndIf
	// definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
	oModel:SetOperation( 3 )
	oModel:Activate()
	
	If cGerRom = "2"
		oModel:LoadValue( cDesModNJJ, "NJJ_TOETAP", _cTpOpRe)
	EndIf

	//parte do modelo referente aos dados de cabeçalho
	oAux := oModel:GetModel( cDesModNJJ  )   // Modelo da NJJ Cab. Romaneio = NJJUNICO, dos Itens == NJMUnico
	
	oStruct := oAux:GetStruct()
	aAux := oStruct:GetFields()
	
	If lContinua
		For nI := 1 To Len( aCpoMaster )
			// Verifica se os campos passados existem na estrutura do cabeçalho
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoMaster[nI][1] ) } ) ) > 0
				// È feita a atribuição do dado aos campo do Model do cabeçalho
				If !( lAux := oModel:LoadValue( cDesModNJJ, aCpoMaster[nI][1],aCpoMaster[nI][2] ) )
					// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
					// o método SetValue retorna .F.
					lContinua := .F.
					Exit
				EndIf
			EndIf
		Next
	EndIf

	If lContinua
		// parte do modelo referente aos dados do item
		oAux := oModel:GetModel( cDesModNJM )

		oStruct := oAux:GetStruct()
		aAux    := oStruct:GetFields()
		nItErro := 0
		For nI := 1 To Len( aCpoDetail )
			// Incluímos uma linha nova
			// ATENÇÃO: O itens são criados em uma estrutura de grid (FORMGRID), portanto já é criada uma primeira linha
			//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
			If nI > 1
				// Incluímos uma nova linha de item
				If ( nItErro := oAux:AddLine() ) <> nI
					// Se por algum motivo o método AddLine() não consegue incluir a linha, // ele retorna a quantidade de linhas já // existem no grid. Se conseguir retorna a quantidade mais 1
					lContinua := .F.
					Exit
				EndIf
			EndIf
			For nJ := 1 To Len( aCpoDetail[nI] )
				// Verifica se os campos passados existem na estrutura de item
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoDetail[nI][nJ][1] ) } ) ) > 0
					If !( lAux := oModel:LoadValue( cDesModNJM, aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2] ) )
						// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
						// o método SetValue retorna .F.
						lContinua := .F.
						nItErro := nI
						Exit
					EndIf
				EndIf
			Next
			If !lContinua
				Exit
			EndIf
		Next
	EndIf
	
	If lContinua .AND. lAlgodao
		oAux     := oModel:GetModel(cDesModDX0)
		oStruct  := oAux:GetStruct()
		aAux     := oStruct:GetFields()
		nFarErro := 0
		
		For nI := 1 To Len( aCposFar )
			// Incluímos uma linha nova
			// ATENÇÃO: O itens são criados em uma estrutura de grid (FORMGRID), portanto já é criada uma primeira linha
			//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
			If nI > 1
				// Incluímos uma nova linha de item
				If ( nFarErro := oAux:AddLine() ) <> nI
					// Se por algum motivo o método AddLine() não consegue incluir a linha, // ele retorna a quantidade de linhas já // existem no grid. Se conseguir retorna a quantidade mais 1
					lContinua := .F.
					Exit
				EndIf
			EndIf
			For nJ := 1 To Len( aCposFar[nI] )
				// Verifica se os campos passados existem na estrutura de item
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCposFar[nI][nJ][1] ) } ) ) > 0
					If !( lAux := oModel:LoadValue( cDesModDX0, aCposFar[nI][nJ][1], aCposFar[nI][nJ][2] ) )
						// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
						// o método SetValue retorna .F.
						lContinua := .F.
						nFarErro  := nI
						Exit
					EndIf
				EndIf
			Next
			If !lContinua
				Exit
			EndIf
		NExt
	Else
		If lContinua .AND. .NOT. lAlgodao
			oModel:GetModel(cDesModNJK):SetNoInsert( .f. )
			oAux     := oModel:GetModel(cDesModNJK)
			oStruct  := oAux:GetStruct()
			aAux     := oStruct:GetFields()
			nNJKErro := 0
			
			For nI := 1 To Len( aCposNJK )
				// Incluímos uma linha nova
				// ATENÇÃO: O itens são criados em uma estrutura de grid (FORMGRID), portanto já é criada uma primeira linha
				//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
				If nI > 1
					// Incluímos uma nova linha de item
					If ( nNJKErro := oAux:AddLine() ) <> nI
						// Se por algum motivo o método AddLine() não consegue incluir a linha, // ele retorna a quantidade de linhas já // existem no grid. Se conseguir retorna a quantidade mais 1
						lContinua := .F.
						Exit
					EndIf
				EndIf
				For nJ := 1 To Len( aCposNJK[nI] )
					// Verifica se os campos passados existem na estrutura de item
					If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCposNJK[nI][nJ][1] ) } ) ) > 0
						If !( lAux := oModel:LoadValue( cDesModNJK, aCposNJK[nI][nJ][1], aCposNJK[nI][nJ][2] ) )
							// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
							// o método SetValue retorna .F.
							lContinua := .F.
							nNJKErro  := nI
							Exit
						EndIf
					EndIf
				Next
				If !lContinua
					Exit
				EndIf
			NExt
		EndIf
	EndIf

	If lContinua
		// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
		// neste momento os dados não são gravados, são somente validados.
		If ( lContinua := oModel:VldData() )
			// Se o dados foram validados faz-se a gravação efetiva dos
			// dados (commit)
			If lGrava
				lContinua := oModel:CommitData()
			EndIf
		EndIf
	EndIf
	If !lContinua
		// Se os dados não foram validados obtemos a descrição do erro para gerar
		// LOG ou mensagem de aviso
		aErro := oModel:GetErrorMessage()
		// A estrutura do vetor com erro é:
		// [1] identificador (ID) do formulário de origem
		// [2] identificador (ID) do campo de origem
		// [3] identificador (ID) do formulário de erro
		// [4] identificador (ID) do campo de erro
		// [5] identificador (ID) do erro
		// [6] mensagem do erro
		// [7] mensagem da solução
		// [8] Valor atribuído
		// [9] Valor anterior		
		//AutoGrLog( STR0024 )		//"A Entidade utilizada realiza a geração de Romaneio em outra Filial."
		//AutoGrLog( STR0025 )		//"Favor verificar cadastros."
		AutoGrLog( "" )
		AutoGrLog( STR0026 + ' [' + AllToChar( aErro[1] ) + ']' )		//"Id do formulário de origem: "
		AutoGrLog( STR0027 + ' [' + AllToChar( aErro[2] ) + ']' )		//"Id do campo de origem.....: "
		AutoGrLog( STR0028 + ' [' + AllToChar( aErro[3] ) + ']' )		//"Id do formulário de erro..: "
		AutoGrLog( STR0029 + ' [' + AllToChar( aErro[4] ) + ']' )		//"Id do campo de erro.......: "
		AutoGrLog( STR0030 + ' [' + AllToChar( aErro[5] ) + ']' )		//"Id do erro................: "
		AutoGrLog( STR0031 + ' [' + AllToChar( aErro[6] ) + ']' )		//"Mensagem do erro..........: "
		AutoGrLog( STR0032 + ' [' + AllToChar( aErro[7] ) + ']' )		//"Mensagem da solução.......: "
		AutoGrLog( STR0033 + ' [' + AllToChar( aErro[8] ) + ']' )		//"Valor atribuído...........: "
		AutoGrLog( STR0034 + ' [' + AllToChar( aErro[9] ) + ']' )		//"Valor anterior............: "
		If nItErro > 0
			AutoGrLog( STR0035 + ' [' + AllTrim( AllToChar( nItErro ) ) + ']' )	//"Erro no Item..............: "
		EndIf
		MostraErro()
	EndIf
	
	cRomPar := oModel:GetValue(cDesModNJJ, "NJJ_CODROM")
	// Desativamos o Model
	oModel:DeActivate()
	RestArea(aArea)

Return lContinua


/*/{Protheus.doc} A500NFLRec
//Verifica se a NF já foi lançada no recebimento
@author silvana.torres
@since 14/02/2018
@version undefined
@param cDocNum, characters, descricao
@param cDocSer, characters, descricao
@param cCodEnt, characters, descricao
@param cLojEnt, characters, descricao
@type function
/*/
Function A500NFLRec(cDocNum, cDocSer, cCodEnt, cLojEnt)

	Local aAreaAtu	:= GetArea()
	Local lRet 	:= .F.
	Local cForn := ""
	Local cLoja := ""

	//-------------------------------------------------
	// Busca cliente e fornecedor amarrado ao produtor
	//-------------------------------------------------

	dbSelectArea("NJ0")
	NJ0->(dbSetOrder(1))
	If NJ0->(MsSeek(fwxFilial("NJ0")+cCodEnt+ cLojEnt))
		cForn := NJ0->NJ0_CODFOR 
		cLoja := NJ0->NJ0_LOJFOR 
	EndIf 
	NJ0->( DbCloseArea())

	DbSelectArea("SF1")
	SF1->(dbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	if SF1->(MsSeek(FwXFilial("SF1")+cDocNum+cDocSer+cForn+cLoja+"N"))
		lRet :=	.T.
	endIf
	SF1->( DbCloseArea())

	RestArea( aAreaAtu )

Return lRet


/*/{Protheus.doc} A500LancNF
//Lança NF no recebimento
@author silvana.torres
@since 14/02/2018
@version undefined
@param cCodRom, characters, descricao
@param cTpOper, characters, descricao
@param cDocNum, characters, descricao
@param cDocSer, characters, descricao
@param cCodEnt, characters, descricao
@param cLojEnt, characters, descricao
@param dDocEmi, date, descricao
@param cDocEsp, characters, descricao
@param cChvNFE, characters, descricao
@param cPlaca, characters, descricao
@param cCodTra, characters, descricao
@param cTpFret, characters, descricao
@param nPsLiqu, numeric, descricao
@param nPsSubt, numeric, descricao
@type function
/*/
function A500LancNF(cCodRom, cTpOper, cDocNum, cDocSer, cCodEnt, cLojEnt, dDocEmi, cDocEsp, cChvNFE, ;
	cPlaca, cCodTra, cTpFret, nPsLiqu, nPsSubt )

	Local lRet 			:= .T.
	Local aCab          := {}		//--Array de cabeçalho para geração da nota fiscal SF1 
	Local aItens        := {}		//--Array de itens para geração da nota fiscal SD1

	Local (cAliasNJM) 	:= GetNextAlias()
	Local cQueryNJM		:= ""

	Local aSelNfs		:= {}		//--Array retorno dos complementos

	/** Variaveis do Cabeçalho do Documento de Entrada */
	Local cFornecedor   := ""
	Local cLoja         := ""
	Local cUF           := ""
	Local nPSLiq        := 0
	Local nPSubt        := 0
	Local cNFPNum       := ""
	Local cNFPSer       := ""
	Local cEsp1         := ""
	Local cMsgNF        := ""
	Local cMsgNFAux     := ""   
	Local cTpFrete      := ""
	Local nFrete        := 0
	Local nSeguro       := 0
	Local nDespesa      := 0    

	/** Variaveis dos Itens do Documento de Entrada */
	Local cItemSeq      := ""
	Local cProduto      := ""
	Local nQuant        := 0
	Local nPreco        := 0
	Local nTotal        := 0
	Local cTes          := ""
	Local cLocal        := ""
	Local cCodSaf       := ""	//NJM->( NJM_CODSAF )
	Local cCodCtr       := ""	//NJM->( NJM_CODCTR )
	Local cIteRom       := ""
	Local nItens        := 1
	Local dVcntDAP      := ""
	Local cIncetDAP    	:= ""	//--Incentivo DAP 	- Cadastro de Entidades
	Local cITVDAP      	:= "2"	//--Incent. DAP 	- Possui o Incentivo DAP - 1=Sim;2=Nao
	Local cTxMoeda      := 0
	Local cMoeda        := 0
	Local cClassVlr     := ""
	Local nX            := 0

	Local cModAtu       := cModulo
	Local nModAtu       := nModulo

	Private lMsErroAuto := .F.	//Mensagem de erro das funções execauto

	//--Agrupa para geração do Documento de compra
	cQueryNJM := " SELECT * "
	cQueryNJM +=   " FROM "+RetSqlName("NJM")+" NJM "
	cQueryNJM +=  " WHERE NJM.NJM_FILIAL = '"+ FWxFilial("NJM") +"'"
	cQueryNJM +=    " AND NJM.NJM_CODROM = '"+ cCodRom + "'"
	cQueryNJM +=    " AND NJM.NJM_CODENT = '"+ cCodEnt +"'"
	cQueryNJM +=    " AND NJM.NJM_LOJENT = '"+ cLojEnt +"'"
	cQueryNJM +=    " AND NJM.NJM_DOCNUM = '"+ cDocNum +"'"
	cQueryNJM +=    " AND NJM.NJM_DOCSER = '"+ cDocSer +"'"
	cQueryNJM +=    " AND NJM.NJM_TIPMOV = '1'"	 
	cQueryNJM +=    " AND NJM.NJM_STAFIS = '1' "
	cQueryNJM +=    " AND NJM.D_E_L_E_T_ = '' "

	cQueryNJM := ChangeQuery(cQueryNJM)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryNJM),(cAliasNJM),.F.,.T.)

	dbSelectArea((cAliasNJM))
	((cAliasNJM))->( dbGoTop() )

	While ((cAliasNJM))->( .NOT. Eof() )

		//-------------------------------------------------
		// Busca cliente e fornecedor amarrado ao produtor
		//-------------------------------------------------
		dbSelectArea("NJ0")
		NJ0->(dbSetOrder(1))
		If NJ0->(MsSeek(fwxFilial("NJ0")+(cAliasNJM)->( NJM_CODENT )+ (cAliasNJM)->( NJM_LOJENT )))
			cFornecedor := NJ0->NJ0_CODFOR 
			cLoja		:= NJ0->NJ0_LOJFOR 
		EndIf

		cUF  := Posicione( "SA2", 1, FWxFilial( "SA2" ) + cFornecedor + cLoja, "A2_EST" )

		cIncetDAP	:= Posicione( "NJ0", 1, FWxFilial('NJ0') + (cAliasNJM)->( NJM_CODENT ) + (cAliasNJM)->( NJM_LOJENT ), "NJ0_ITVDAP" )		//--Possui o Incentivo DAP   
		dVcntDAP    := Posicione( "NJ0", 1, FWxFilial('NJ0') + (cAliasNJM)->( NJM_CODENT ) + (cAliasNJM)->( NJM_LOJENT ), "NJ0_DTVDAP" )  	//--Data Vencimento DAP

		//--Se entidade não estiver com vinculo de fornecedor/cliente
		If Empty(cFornecedor) .or. Empty(cLoja)
			Help( ,, "Fornecedor e Loja da Entidade não pode ser branco.",, "Erro", 1, 0) //'Erro'###"Fornecedor e Loja da Entidade não pode ser branco."
			Exit
			Return .F.
		EndIf

		cProduto	:= (cAliasNJM)->( NJM_CODPRO )
		nQuant     	:= (cAliasNJM)->( NJM_QTDFIS )
		nPreco     	:= (cAliasNJM)->( NJM_VLRUNI )
		nTotal     	:= (cAliasNJM)->( NJM_VLRTOT )
		cLocal     	:= (cAliasNJM)->( NJM_LOCAL  )
		cCodCtr 	:= (cAliasNJM)->( NJM_CODCTR )
		cCodRom 	:= (cAliasNJM)->( NJM_CODROM )
		cIteRom 	:= (cAliasNJM)->( NJM_ITEROM )
		cNFPNum 	:= (cAliasNJM)->( NJM_NFPNUM )
		cNFPSer 	:= (cAliasNJM)->( NJM_NFPSER )
		cTes        := (cAliasNJM)->( NJM_TES    )
		cCodSaf  	:= (cAliasNJM)->( NJM_CODSAF )
		cLoteCtl	:= (cAliasNJM)->( NJM_LOTCTL )
		cClassVlr  	:= (cAliasNJM)->( NJM_CLVL   )
		nPerDiv		:= (cAliasNJM)->( NJM_PERDIV )
		cCondPg		:= (cAliasNJM)->( NJM_CONDPG )

		nFrete      += (cAliasNJM)->( NJM_FRETE )
		nSeguro 	+= (cAliasNJM)->( NJM_SEGURO )
		nDespesa    += (cAliasNJM)->( NJM_DESPES )


		cMsgAux := ""
		dbSelectArea( "NJR" )
		NJR->( dbSetOrder( 1 ) )
		If NJR->( MsSeek( FWxFilial( "NJR" ) + cCodCtr ) )
			If Empty(cEsp1)
				cEsp1   := NJR->( NJR_TIPEMB )
			EndIf
			If !Empty(NJR->( NJR_MSGNFS ))
				cMsgNFAux   := NJR->NJR_MSGNFS
			EndIf
			cTpFrete	:= NJR->NJR_TPFRET  	//--Vai pegar o Tipo de frete do contrato do ultimo item do njm
			cMoeda   	:= NJR->NJR_MOEDA
			cTxMoeda 	:= NJR->NJR_TXMOED
		EndIf

		//--Ajustando a mensagem da NF                                                                 --//
		//--Se existe Mensagem de NF. no romaneio considera o romaneio, senão Considera do Ctrato.     --//
		IF .NOT. Empty( NJM->NJM_MSGNFS )
			cMsgNF	+= Alltrim( NJM->NJM_MSGNFS )
		Else
			cMsgNF	+= Alltrim( cMsgNFAux )
		EndIF  

		If (cAliasNJM)->( NJM_TIPMOV ) = "2"
			nQuant	:= 0
		EndIf

		//--Produto Adicional
		dbSelectArea("NJV")
		NJV->( dbSetOrder( 1 ) )
		If NJV->( MsSeek( xFilial( "NJV" ) + cProduto ) )
			//--Se entidade controla incentivo DAP 
			//--E a data de vencimento do DAP é maior ou igual a emissão
			//--E não vazio o codigo Produto Adicional 
			//--E tipo do romaneio igual a Entrada por Compra
			If cIncetDAP == "1" .And. dVcntDAP >= dEmissao .And. !Empty(NJV->( NJV_CODSPD )) .And. NJM->( NJM_TIPO ) $ "5"
				_lInctDAP 	:= .T.

				cProduto    := NJV->( NJV_CODSPD )
				nPreco      := NJV->( NJV_VALOR )
				nTotal      := Round( ( nQuant * nPreco ), TamSX3( "D1_VUNIT" )[2] )
				cITVDAP   	:= "1"
				cLoteCtl    := ''				
			EndIf
		Endif

		For nX := 1 to If(Len( aSelNfs ) > 0, Len( aSelNfs ), 1)
			//cTipoNF     := "N"
			cItemSeq    := StrZero( nItens, TamSX3( "D1_ITEM" )[1] )

			//----Alimenta o array para geração da NF
			aLinha := {}
			If cPaisLoc == "PAR" //Paraguai
				aAdd( aLinha, { "D1_UM"         , Posicione('SB1',1,xFilial('SB1')+cProduto,'B1_UM'), Nil } )
				aAdd( aLinha, { "D1_CF"         , Posicione('SF4',1,xFilial('SF4')+cTes,'F4_CF'), Nil } )
			EndIf

			aAdd( aLinha, { "D1_ITEM"       , cItemSeq          , Nil } )	
			aAdd( aLinha, { "D1_COD"        , cProduto          , Nil } )

			IF nQuant > 0  
				aAdd( aLinha, { "D1_QUANT"      , nQuant            , Nil } )	//_lCtrlDVl  _lCtrlCom 
			EndIf

			aAdd( aLinha, { "D1_VUNIT"      , nPreco            , Nil } )
			aAdd( aLinha, { "D1_TOTAL"      , nTotal            , Nil } )
			aAdd( aLinha, { "D1_LOCAL"      , cLocal            , Nil } )
			aAdd( aLinha, { "D1_TES"        , cTes              , Nil } )
			aAdd( aLinha, { "D1_CTROG"      , cCodCtr           , Nil } )
			aAdd( aLinha, { "D1_CODSAF"     , cCodSaf           , Nil } )
			aAdd( aLinha, { "D1_CODROM"     , cCodRom           , Nil } )
			aAdd( aLinha, { "D1_ITEROM"     , cIteRom           , Nil } )
			aAdd( aLinha, { "D1_NFPNUM"     , cNFPNum           , Nil } )
			aAdd( aLinha, { "D1_NFPSER"     , cNFPSer           , Nil } )
			aAdd( aLinha, { "D1_PLACA"      , cPlaca            , Nil } )

			aAdd( aLinha, { "D1_LOTECTL"    , cLoteCtl          , Nil } )
			aAdd( aLinha, { "D1_CLVL"       , cClassVlr         , Nil } )
			aAdd( aItens, aLinha )

			nItens++

		Next nX

		nPSLiq  += nPsLiqu * (cAliasNJM)->( NJM_PERDIV ) / 100
		nPSubt  += nPsSubt * (cAliasNJM)->( NJM_PERDIV ) / 100

		dbSelectArea("NJM")
		NJM->( dbSetOrder(1) )

		if NJM->( MsSeek(FWxFilial("NJM")+cCodRom+(cAliasNJM)->(NJM_ITEROM)) )
			If Reclock("NJM",.F.)
				NJM->NJM_STAFIS := "2"
				NJM->NJM_DTRANS := dDatabase
				NJM->(MsUnLock()) 
			endIf			
		endIf

		(cAliasNJM)->( dbSkip() )
	EndDo

	(cAliasNJM)->( dbCloseArea() )

	aAdd( aCab, { "F1_TIPO"     , "N" 		} )
	aAdd( aCab, { "F1_FORMUL"   , "N"   		} )
	aAdd( aCab, { "F1_SERIE"    , PadR(Alltrim(cDocSer),TamSx3('F1_SERIE')[1] )        } )
	aAdd( aCab, { "F1_DOC"      , cDocNum       } )
	aAdd( aCab, { "F1_EMISSAO"  , dDocEmi      	} )
	aAdd( aCab, { "F1_FORNECE"  , cFornecedor   } )
	aAdd( aCab, { "F1_LOJA"     , cLoja       	} )
	aAdd( aCab, { "F1_ESPECIE"  , cDocEsp      	} )
	aAdd( aCab, { "F1_COND"     , cCondPg 		} )
	aAdd( aCab, { "F1_UF"       , cUf           } )
	aAdd( aCab, { "F1_CHVNFE"   , cChvNFE       } )
	aAdd( aCab, { "F1_CODROM"   , cCodRom 		} )

	If .Not. Empty(  cEsp1 )
		aAdd( aCab, { "F1_ESPECI1"  , cEsp1  } )
	endIf

	If .Not. Empty( cMsgNF )
		aAdd( aCab, { "F1_MENNOTA"  , OemToansi( AllTrim(cMsgNF) ) } )
	endIf

	nPSLiq  += (nPsLiqu * nPerDiv / 100)
	nPSubt  += (nPsSubt  * nPerDiv / 100)

	If nPSLiq > 0
		aAdd( aCab, { "F1_PLIQUI"       , nPSLiq        } )
	EndIf

	If nPSubt > 0
		aAdd( aCab, { "F1_PBRUTO"       , nPSubt        } )
	EndIf

	If .Not. Empty( cPlaca )
		aAdd( aCab, { "F1_PLACA"        , cPlaca        } )
	endIf

	If .Not. Empty( cCodTra )
		aAdd( aCab, { "F1_TRANSP"       , cCodTra       } )
	endIf

	IF nFrete > 0
		cTpFrete := IF( !Empty(cTpFret), cTpFret, cTpFrete )

		aAdd( aCab, {"F1_TPFRETE"   , cTpFrete      , Nil } )
		aAdd( aCab, {"F1_FRETE"     , nFrete        , Nil } )
	Else
		aAdd( aCab, {"F1_TPFRETE"   , cTpFrete      , Nil } )
	EndIF

	if nSeguro > 0
		aAdd( aCab, {"F1_SEGURO"    , nSeguro       , Nil } )
	EndIF
	IF nDespesa > 0
		aAdd( aCab, {"F1_DESPESA"   , nDespesa      , Nil } )
	EndIF

	/* Necessitamos solicitar o modulo pois alguns campos como LOTE e DTLOTE
	não estao setados para trabalhar com o SIGAAGR */
	cModulo := "COM"
	nModulo := 2

	If Len( aCab ) > 0 .And. Len( aItens ) > 0
		aCab   := FWVetByDic(aCab, 'SF1')
		aItens := FWVetByDic(aItens, 'SD1',.T.)

		MSExecAuto( { | x, y, z | Mata103( x, y, z ) }, aCab, aItens, 3 ) //Opção desejada: 3-Inclusão; 4-Alteração ; 5-Exclusão
	EndIf

	//Retornando o modulo do SIGAAGR
	cModulo := cModAtu
	nModulo := nModAtu

	If lMsErroAuto
		MostraErro()
		lRet := .F. 
	endif

Return lRet

/*/{Protheus.doc} AGRX500STT
//Função atualiza status da pendência para finalizada
@author marina.muller
@since 07/02/2018
@version 1.0
@return ${return}, ${return_description}
@param aPendN9C, array, descricao
@param cSafra, characters, descricao
@param cEntidade, characters, descricao
@param cLojEnt, characters, descricao
@param cProduto, characters, descricao
@param cFilStatus, characters, descricao
@type function
/*/
Function AGRX500STT(aPendN9C, cSafra, cEntidade, cLojEnt, cTipo)
	Local aArea   := GetArea()
	Local lRet    := .T.
	Local cFilPen := ""
	Local cRomPen := ""
	Local cProd   := ""

	cProd := aPendN9C[8][1]  

	//se tipo de pendência for complemento(1)/devolução(3) fisica
	If aPendN9C[7][1] == '1' .Or. aPendN9C[7][1] == '3' 
		cFilPen := aPendN9C[6][1] //filial romaneio
		cRomPen := aPendN9C[1][1] //código romaneio

		//se tipo de pendência for complemento(2) fiscal
	ElseIf aPendN9C[7,1] == '2'
		If cTipo = "DESTINO"
			cFilPen := aPendN9C[3][1] //filial pendencia
			cRomPen := aPendN9C[1][1] //código romaneio pendencia
		Else
			cFilPen := aPendN9C[4][1] //filial romaneio origem
			cRomPen := aPendN9C[1][1] //código romaneio pendencia
		EndIf  

	ElseIf aPendN9C[7,1] = '4'
		If cTipo = "DESTINO"
			cFilPen := aPendN9C[6][1] //filial pendencia
			cRomPen := aPendN9C[1][1] //código romaneio pendencia
		Else
			cFilPen := aPendN9C[4][1] //filial romaneio origem
			cRomPen := aPendN9C[1][1] //código romaneio pendencia
		EndIf

	EndIf 

	DbSelectArea('N9C')
	N9C->(DbSetOrder(2))
	If N9C->(MsSeek(cFilPen+cSafra+cEntidade+cLojEnt+cProd+cRomPen)) //filial+safra+entidade+loja+produto+romaneio
		If RecLock( "N9C",.F.)
			N9C->N9C_STATUS := '2'  //status 2=Finalizada
			N9C->( msUnLock() )
		Else
			Help( ,, STR0045,, STR0019, 1, 0) //'Erro'###"Problema atualização status pendência física/fiscal."
			lRet := .F.
		EndIf
	Else
		Help( ,, STR0045,, STR0019, 1, 0) //'Erro'###"Problema atualização status pendência física/fiscal."
		lRet := .F.
	EndIf	

	N9C->(dbCloseArea())	
	RestArea(aArea)

Return lRet


/*/{Protheus.doc} AGRX500RAS
//Função faz gravação do rastro na DXB
@author marina.muller/ silvana.torres
@since 01/02/2018
@version 1.0
@return ${return}, ${return_description}
/*/
Function AGRX500RAS(cNumOP, aPendN9C, CRotina)
	
	Local aArea    		:= GetArea()
	Local lRet     		:= .T.
	Local nQtdFard 		:= 0
	Local cRomPen 		:= ""
	Local oMdAGRA605	:= FwLoadModel('AGRA605')
	Local oGridDXB		:= oMdAGRA605:GetModel('AGRA605_DXB')
	Local cFilOP		:= fwxFilial('SD3')

	//se tipo de pendência for complemento(1)/devolução(3) fisica
	If aPendN9C[7][1] == "1" .Or. aPendN9C[7][1] == "3" 
		cRomPen := aPendN9C[1][1] //código romaneio

		//se tipo de pendência for complemento(2) fiscal
	ElseIf aPendN9C[7][1] == "2"
		cRomPen := aPendN9C[5][1] //código romaneio origem
		cFilOP	:= aPendN9C[4][1]
		
	ElseIf aPendN9C[7][1] == "4"
		cRomPen := aPendN9C[1][1] //código romaneio origem
		cFilOP	:= aPendN9C[4][1]
	EndIf 

	//busca quantidade de fardões do romaneio para ratear quantidade da pendência
	DbSelectArea('DX0')
	DX0->(DbSetOrder(3))

	If DX0->(MsSeek(cFilOP+cRomPen)) //FILIAL + ROMANEIO

		While DX0->(!Eof()) .And.;
		DX0->DX0_FILIAL = cFilOP .And.;
		DX0->DX0_NRROM  = cRomPen	  

			nQtdFard += 1
			DX0->(dbSkip())	
		endDo      
	EndIf
	DX0->(dbCloseArea())    				 		  

	DbSelectArea('DX0')
	DX0->(DbSetOrder(3))

	If DX0->(MsSeek(cFilOP+cRomPen)) //FILIAL + ROMANEIO

		While DX0->(!Eof()) .And.;
			  DX0->DX0_FILIAL = cFilOP .And.;
			  DX0->DX0_NRROM  = cRomPen	  	
		
			oMdAGRA605:SetOperation(3) // Seta a operação do modelo como INCLUSÃO
	
			If oMdAGRA605:Activate() 																

				DbSelectArea('NJJ')
				NJJ->(DbSetOrder(1))

				If NJJ->(MsSeek(cFilOP+cRomPen)) //FILIAL + ROMANEIO					
					oGridDXB:LoadValue("DXB_SAFRA" ,NJJ->NJJ_CODSAF)
					oGridDXB:LoadValue("DXB_PRDTOR",NJJ->NJJ_CODENT)
					oGridDXB:LoadValue("DXB_LJPRO" ,NJJ->NJJ_LOJENT)
					oGridDXB:LoadValue("DXB_FAZ"   ,NJJ->NJJ_FAZ )					  
				EndIf
				NJJ->(dbCloseArea())

				oGridDXB:LoadValue("DXB_FARDAO",DX0->DX0_FARDAO)
				oGridDXB:LoadValue("DXB_CODUNI",DX0->DX0_CODUNI)

				DbSelectArea('SD3')
				SD3->(DbSetOrder(1))
				
				If SD3->(MsSeek(cFilOP+cNumOP))

					oGridDXB:LoadValue("DXB_FILIAL",cFilOP)
					oGridDXB:LoadValue("DXB_EMISSA",dDataBase)
					oGridDXB:LoadValue("DXB_OP"    ,PadR(Alltrim(SD3->D3_OP),TamSx3('DXB_OP')[1] ))
					oGridDXB:LoadValue("DXB_CODPRO",SD3->D3_COD)
					oGridDXB:LoadValue("DXB_LOTCTL",SD3->D3_LOTECTL)
					oGridDXB:LoadValue("DXB_NMLOT" ,SD3->D3_NUMLOTE)
					oGridDXB:LoadValue("DXB_LOCLIZ",SD3->D3_LOCALIZ)
					oGridDXB:LoadValue("DXB_DOC"   ,SD3->D3_DOC)
					oGridDXB:LoadValue("DXB_LOCAL" ,SD3->D3_LOCAL)
					oGridDXB:LoadValue("DXB_NUMSEQ",SD3->D3_NUMSEQ)
					oGridDXB:LoadValue("DXB_CF"    ,SD3->D3_CF)
					oGridDXB:LoadValue("DXB_TM"    ,SD3->D3_TM)
					oGridDXB:LoadValue("DXB_QUANT",(SD3->D3_QUANT/nQtdFard) )//faz rateio da quantidade por fardo
					oGridDXB:LoadValue("DXB_ROTINA",CRotina)
				EndIf

				SD3->(dbCloseArea())
									
				If (lRet := oMdAGRA605:VldData())
					lRet := oMdAGRA605:CommitData()
				Else
					oMdAGRA605:SetErrorMessage( , , , , , oMdAGRA605:GetErrorMessage()[6])			
				EndIf
			Endif	
			
			oMdAGRA605:DeActivate()

			DX0->(dbSkip())
		endDo
	else
		Help( ,, STR0046,, STR0019, 1, 0) //'Erro'###"Problema gravação rastro - DXB."
		lRet := .F.
	endIf

	DX0->(dbCloseArea())	

	RestArea(aArea)

Return lRet


/*/{Protheus.doc} AGRA520LOC
//Função para buscar informações do romaneio na NJJ, produto (SB1), tipo de operação (N92)
@author marina.muller / silvana.torres
@since 21/02/2018
@version 1.0
@return ${return}, ${return_description}
@param aPendN9C, array, descricao
@param cFilOri, characters, descricao
@type function
/*/
Function AGRX500LOC(aPendN9C, cFilOri)

	Local aArea     := GetArea()
	Local cFilNJJ   := ""
	Local cLocalOri := ""
	Local cLocalDes := ""
	Local cUnMed    := ""
	Local nConv	   	:= 0
	Local cTesNJJ   := ""
	Local cTesN92   := ""
	Local cTipo     := ""
	Local cFilPen 	:= ""
	Local cRomPen 	:= ""
	Local cLotCtl 	:= ""
	Local cNmLot 	:= ""
	Local cLocliz 	:= ""
	Local cTpOpRe   := ""
	Local cTipoOri  := ""
	Local cCodEnt   := "" 
	Local cLojEnt   := ""

	//se array tiver mais que 3 posições veio da gestão de pendência
	If len(aPendN9C) > 3
		//se tipo de pendência for complemento(1)/devolução(3) fisica
		If aPendN9C[7][1] == "1" .Or. aPendN9C[7][1] == "3" 
			cFilPen := aPendN9C[6][1] //filial romaneio
			cRomPen := aPendN9C[1][1] //código romaneio

			//se tipo de pendência for complemento(2) fiscal
		ElseIf aPendN9C[7][1] == "2" .OR. aPendN9C[7][1] == "4"
			cFilPen := aPendN9C[4][1] //filial romaneio origem
			cRomPen := aPendN9C[5][1] //código romaneio origem
		EndIf
	Else
		//senão veio saída por transferência
		cFilPen := aPendN9C[1][3]
		cRomPen := aPendN9C[1][1]
	EndIf		 

	DbSelectArea('NJJ')
	DbSetOrder(1)
	If MsSeek(cFilPen+cRomPen) //filial + romaneio
		cFilNJJ  	:= NJJ->NJJ_FILIAL
		cTesNJJ  	:= NJJ->NJJ_TES
		cLocalOri   := NJJ->NJJ_LOCAL
		
		DbSelectArea("NJM")
		DbSetOrder(1) //FILIAL+ROMANEIO
		
		If NJM->(MsSeek(cFilPen + cRomPen))
			cLotCtl := NJM->NJM_LOTCTL
			cNmLot 	:= NJM->NJM_NMLOT
			cLocliz := NJM->NJM_LOCLIZ
		EndIf
		
		NJM->(dbCloseArea())
	EndIf

	//Unidade de medida do produto e fator de conversão   
	DbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(FwXFilial("SB1")+NJJ->NJJ_CODPRO))
		//cLocal   	:= SB1->B1_LOCPAD  
		cUnMed   	:= SB1->B1_UM     
		nConv	   	:= SB1->B1_CONV
	EndIf
	SB1->( DbCloseArea())
	
	//busca com tipo de operação do romaneio origem
	DbSelectArea("N92")
	N92->(dbSetOrder(1))
	If N92->(MsSeek(FwXFilial("N92")+NJJ->NJJ_TOETAP))
		cTipo   	:= N92->N92_TIPO  
		cLocalDes	:= N92->N92_LOCAL
		cTpOpRe     := N92->N92_TPOPRE
	EndIf
	N92->( DbCloseArea())
	
	//busca com tipo de operação destino
	DbSelectArea("N92")
	N92->(dbSetOrder(1))
	if N92->(MsSeek(FwXFilial("N92")+cTpOpRe))
		cTipoOri := N92->N92_TIPO
	endIf
	N92->( DbCloseArea())
	
	//busca entidade/loja do destino
	DbSelectArea("NJ0")
	NJ0->(dbSetOrder(5)) //Filial+CODCRP
	if NJ0->(MsSeek(FwXFilial('NJ0')+cFilOri))
		cCodEnt := NJ0->NJ0_CODENT
		cLojEnt := NJ0->NJ0_LOJENT
	endIf
	NJ0->( DbCloseArea())
	
	//busca TES inteligente 
	cTesN92 := AGRX500TIN(NJJ->NJJ_TOETAP,; //tipo operação N92
	                      cTipoOri,;        //tipo romaneio N92 (E/S)
	                      cCodEnt,;         //entidade (cliente/ fornecedor)
	                      cLojEnt,;         //loja entidade
	                      NJJ->NJJ_CODPRO)  //produto  
	
	NJJ->(dbCloseArea())
	RestArea(aArea)

Return {cFilNJJ, cLocalOri, cUnMed, cTesNJJ, cTesN92, cTipo, nConv, cLocalDes, cLotCtl, cNmLot, cLocliz}


/*/{Protheus.doc} AGRX500ROM
//Função para buscar a filial e romaneio de origem
@author marina.muller
@since 07/03/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AGRX500ROM()
	Local aArea     := GetArea()
	Local cAliasNJJ := GetNextAlias()
	Local cQuery	   := ""
	Local cFilRom   := ""
	Local cRomOri   := "" 

	If !Empty(NJJ->NJJ_DOCNUM) .And. !Empty(NJJ->NJJ_DOCSER) 
		cQuery := " SELECT NJJ_FILIAL, NJJ_CODROM "
		cQuery +=   " FROM "+RetSqlName("NJJ")+" NJJ 				   "
		cQuery +=  " WHERE NJJ.NJJ_DOCNUM 	= '"+ NJJ->NJJ_DOCNUM + "' "
		cQuery +=    " AND NJJ.NJJ_DOCSER   = '"+ NJJ->NJJ_DOCSER + "' "
		cQuery +=    " AND NJJ.NJJ_CODROM  <> '"+ NJJ->NJJ_CODROM + "' "
		cQuery +=    " AND NJJ.D_E_L_E_T_   = ''  					   "
		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),(cAliasNJJ),.F.,.T.)		
		dbSelectArea(cAliasNJJ)

		(cAliasNJJ)->( dbGoTop() )		

		If (cAliasNJJ)->(.NOT. Eof())
			cFilRom := (cAliasNJJ)->NJJ_FILIAL
			cRomOri := (cAliasNJJ)->NJJ_CODROM			
		endIf

		(cAliasNJJ)->( dbCloseArea())
	EndIf

	RestArea(aArea)

Return {cFilRom, cRomOri}


/*/{Protheus.doc} AGRX500PIM
//Informa se ao clicar em confirmar, deve integrar com o PIMS de acordo com o Tipo de Operacao de Romaneio
@author carlos.augusto
@since 05/04/2018
@version undefined
@param cTpOper, characters, Tipo de Operacao de Romaneio
@param cEtapaRom, characters, Etapa em que o Romaneio esta
@type function
/*/
Function AGRX500PIM(cTpOper, cEtapaRom)
	Local aArea		:= GetArea()
	Local cModoExec := "2" //Unico
	Local cEtapaN94 := ""
	Local lIntPIMS	:= .F.
	
	dbSelectArea('N92')
	N92->(dbSetOrder(1))
	N92->(dbSeek(FWxFilial("N92") + cTpOper))
	If !N92->(EOF())
		cModoExec := N92->N92_MDEXEC
	EndIf

	dbSelectArea('N94')
	N94->(dbSetOrder(1))
	N94->(msSeek(FWxFilial("N94") + cTpOper))
	While !N94->(EOF())  .AND. N94->N94_FILIAL = FWxFilial("N94") .And. N94->N94_CODTO = cTpOper
		cEtapaN94 := N94->N94_CODETP
		lIntPIMS  := N94->N94_INTPIM
		If cModoExec == "1" .And. cEtapaN94 == cEtapaRom
			exit
		ElseIf cModoExec == "2" .And. lIntPIMS
			exit
		EndIf
		N94->(dbSkip())
	End

	N92->(dbCloseArea())
	N94->(dbCloseArea())
	RestArea(aArea)

Return lIntPIMS


/*/{Protheus.doc} AX500OPCom
Gera OP de complemento
@author silvana.torres
@since 10/04/2018
@version undefined

@type function
/*/
Static Function AX500OPCom(cNumOP, nPeso)

	Local lRet	:= .T.
	
	if Empty(cNumOP)
		Processa({|| lRet := A500GERAOP(@cNumOP, NJJ->NJJ_CODPRO, nPeso, NJJ->NJJ_LOCAL, 3) }, STR0002 , STR0004)	//"Gerando Ordem de Produção..."###"Aguarde"
	endIf
		
	//-- Realiza o apontamento da OP 
	If lRet
		Processa({|| lRet := A500APROD(cNumOP, NJJ->NJJ_CODROM, NJJ->NJJ_CODPRO, nPeso, NJJ->NJJ_LOCAL, 3) }, STR0003, STR0004 ) //"Movimentando Ordem de Produção..."###"Aguarde"
	EndIf
	
Return lRet

/*/{Protheus.doc} AX500Estrn
Gera estorno da OP antiga e gera nova OP com o valor correto
@author silvana.torres
@since 10/04/2018
@version undefined

@type function
/*/
Static Function AX500Estrn(cSafra, cfardao)

	Local lRet	:= .T.
	Local cAliasFar
	Local cQuery2
	Local cNumOP
	Local cAponOP
	Local cProd
	Local cNumAx
	
	cAliasFar := GetNextAlias()
	                
	//busca o numéro da OP e o número do apontamento de produção para cada fardão
	cQuery2 := "SELECT * FROM  " + RetSqlName('DXB')+ " DXB " 
	cQuery2 += " WHERE DXB.D_E_L_E_T_ = ''              
	cQuery2 += " 	AND DXB.DXB_FILIAL = '"+ fwxFilial('DXB') +"'" 
	cQuery2 += "  	AND DXB.DXB_FARDAO = '" + cfardao+ "'"
	cQuery2 += "  	AND DXB.DXB_SAFRA  = '" + cSafra + "'   "
 	cQuery2 += " 	AND DXB.DXB_ROTINA = 'AGRA601' "
	cQuery2    := ChangeQuery(cQuery2)

	//--Identifica se tabela esta aberta e fecha
	If Select(cAliasFar) <> 0
		(cAliasFar)->(dbCloseArea())
	EndIf
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery2 ), cAliasFar, .F., .T. )

	While (cAliasFar)->(!Eof())
	
		cNumOP 	:= (cAliasFar)->DXB_OP
		cAponOP := (cAliasFar)->DXB_DOC
		cProd   := (cAliasFar)->DXB_CODPRO
		
		cNumAx := SubStr(cNumOP,1,len(SC2->C2_NUM))
		
		if .NOT. AX500EstOP(cNumAx, cProd, cAponOP)
			return .F.
		endIf		
		
		(cAliasFar)->(dbSkip())	
	endDo
	
Return lRet


/*/{Protheus.doc} AGRX500BLT
//Retorna boletin para o fardao integrado
//Se ja foi gerado, retorna o mesmo por integridade com o PIMS
@author carlos.augusto
@since 21/04/2018
@version undefined

@type function
/*/
Function AGRX500BLT(cCodUni)
	Local nBoletim := 0
	Local aArea		 := GetArea()
	Local cQry		 := ""
	Local cAliasQry  := ""
	
	//Procura o Boletim gerado na ultima integracao ALTERACAO
	cAliasQry := GetNextAlias()
	cQry := " SELECT DX0.DX0_BOLETI "
	cQry += "	     FROM " + RetSqlName("DX0") + " DX0 "
	cQry += "	     WHERE DX0.DX0_FILIAL = '"+ FwXfilial("DX0") +"' "
	cQry += "		AND DX0.DX0_CODUNI = '"+ cCodUni +"' AND DX0.DX0_BOLETI <> 0 " //Pode estar deletado tambem
	cQry := ChangeQuery(cQry)	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.F.,.T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	
	If (cAliasQry)->(.Not. Eof())
		nBoletim := (cAliasQry)->DX0_BOLETI
	EndIf
	(cAliasQry)->(DbCloseArea())	
	
	//Se nao teve, gera Boletin
	If nBoletim = 0
		nBoletim := Val(GetSXENum('DX0','DX0_BOLETI'))
		EndIf
	RestArea(aArea)

Return nBoletim


Function AGRX500UNB()
	Local cUNBDest := ""
	Local cFilDest := ""
	Local nCont    := 0
    
    //Busca filial da entidade/loja do romaneio de saída por transferência
	DbSelectArea("NJ0")
	NJ0->(dbSetOrder(1)) //Filial+Entidade+Loja

	If NJ0->(MsSeek(FwXFilial('NJ0')+NJJ->NJJ_CODENT+NJJ->NJJ_LOJENT))
	   cFilDest := NJ0->NJ0_CODCRP	
	EndIf
	NJ0->( DbCloseArea())
	
	//Busca unidade de beneficiamento do romaneio de entrada por transferência
	DbSelectArea("DX3")
	DX3->(dbSetOrder(1)) //Filial+UNB

	If DX3->(MsSeek(cFilDest))
	   //Verifica quantas UNB tem para filial
	   While !DX3->(Eof()) .And. DX3->DX3_FILIAL == cFilDest  
		   nCont++
		   cUNBDest := DX3->DX3_CODIGO	
		   DX3->(dbSkip())
	   EndDo 	
	EndIf
	DX3->( DbCloseArea())
    
    //Se tiver mais de uma UNB por filial manda em branco
    If nCont > 1 	
	   cUNBDest := ""
	EndIf   
	
Return cUNBDest

/*/{Protheus.doc} AGRX500TIN
//Função busca TES inteligente
@author marina.muller
@since 30/08/2018
@version 1.0
@return ${return}, ${return_description}
@param cTpOper, characters, descricao
@param cTipoOri, characters, descricao
@param cCodEnt, characters, descricao
@param cLjEnt, characters, descricao
@param cProduto, characters, descricao
@type function
/*/
Function AGRX500TIN(cTpOper, cTipoOri, cCodEnt, cLjEnt, cProduto)
	Local aArea     := GetArea()
	Local cTesInt   := "" 
	Local cTipoCF   := ""
	Local cTpOpTes  := ""
	Local cClieFor  := ""
	Local cLoja     := ""
	Local nEntSai   := 0
	
	//se for romaneio de saída (sempre cliente)
	If cTipoOri == "B"
		cTipoCF := "C"            //cliente
		nEntSai := 2              //documento de saída
		
		//busca cliente/loja pela entidade/loja  
		dbSelectArea("NJ0")
		NJ0->(dbSetOrder(1))
		If NJ0->(MsSeek(fwxFilial("NJ0")+cCodEnt+ cLjEnt)) //NJ0_FILIAL+NJ0_CODENT+NJ0_LOJENT
			cClieFor := NJ0->NJ0_CODCLI 
			cLoja    := NJ0->NJ0_LOJCLI 
		EndIf 
		NJ0->( DbCloseArea())
		
	//se for romaneio de entrada (sempre fornecedor)
	ElseIf cTipoOri == "A"
		cTipoCF := "F"            //fornecedor 
		nEntSai := 1              //documento de entrada

		//busca fornecedor/loja pela entidade/loja  
		dbSelectArea("NJ0")
		NJ0->(dbSetOrder(1))
		If NJ0->(MsSeek(fwxFilial("NJ0")+cCodEnt+ cLjEnt)) //NJ0_FILIAL+NJ0_CODENT+NJ0_LOJENT
			cClieFor := NJ0->NJ0_CODFOR 
			cLoja    := NJ0->NJ0_LOJFOR 
		EndIf 
		NJ0->( DbCloseArea())
	EndIf
	
	//busca o ID da regra da TES associado ao tipo de operação
	DbSelectArea("N92")
	N92->(dbSetOrder(1))
	If N92->(MsSeek(FwXFilial("N92")+cTpOper)) //N92_FILIAL+N92_CODIGO
		cTpOpTes := N92->N92_TESINT
	EndIf
	N92->( DbCloseArea())
		
	//chama função responsável por retornar TES inteligente (MARA089.prw)
	cTesInt := MaTesInt(nEntSai,;   //Documento de 1-Entrada / 2-Saída
	                    cTpOpTes,;  //Tipo de Operação FM_TIPO
	                    cClieFor,;  //Código do Cliente ou Fornecedor
	                    cLoja,;     //Loja do Cliente ou Fornecedor
	                    cTipoCF,;   //Tipo C-Cliente / F-Fornecedor
	                    cProduto)   //Código do Produto
	
	RestArea(aArea)

Return cTesInt
 
 /*/{Protheus.doc} AX500PRTP
//Função faz filtro do produto pelo tipo de operação no AGRA540/AGRA550 consulta padrão N92SB1
@author marina.muller
@since 19/02/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AX500PRTP()
	Local aArea     := GetArea()
	Local cAliasCTR := GetNextAlias()	
	Local oModel	:= FwModelActive()
	Local oMldN8N 	:= Nil
	Local oMldNJJ   := Nil
	Local cQry		:= ""
	Local cWhere	:= ""
	Local cProduto  := ""
	Local cTpOper   := "" 
	
	//chamado pela autorização carregamento
	If FWIsInCallStack('AGRA540')
		oMldN8N 	:= oModel:GetModel('AGRA540_N8N')
		cTpOper     := oMldN8N:GetValue("N8N_TOETAP")
		
	//chamado pelo agendamento AGRO
	ElseIf FWIsInCallStack('AGRA550')
		oMldNJJ 	:= oModel:GetModel('AGRA550_NJJ')
		cTpOper     := oMldNJJ:GetValue("NJJ_TOETAP")
	EndIf
	
	If  !Empty(cTpOper)

		cQry := " SELECT DISTINCT NCB.NCB_CODPRO "
		cQry += "   FROM " + RetSqlName("NCB") + " NCB "
		cQry += "  INNER JOIN " + RetSqlName("N92") + " N92 "
        cQry += "     ON N92.N92_CODIGO = NCB.NCB_CODTO "
        cQry += "    AND N92.D_E_L_E_T_ = ' ' "
        cQry += "    AND N92.N92_MSBLOQ <> '1' "
        cQry += "  WHERE NCB.D_E_L_E_T_ = ' ' " 
        cQry += "    AND NCB.NCB_CODTO = '" + cTpOper + "' "
        
		//--Identifica se tabela esta aberta e fecha
		If Select(cAliasCTR) <> 0
			(cAliasCTR)->(dbCloseArea())
		EndIf
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasCTR,.F.,.T.)
		IF (cAliasCTR)->(!Eof())
			While (cAliasCTR)->(!Eof())
				cProduto +=  "'" + ALLTRIM((cAliasCTR)->NCB_CODPRO) + "'"
				
				(cAliasCTR)->(dbSkip())
				
				If (cAliasCTR)->(!Eof())
					cProduto += ", "
				EndIf
			EndDo	
		EndIf
		(cAliasCTR)->(dbCloseArea())
	    
	    If !Empty(cProduto)
	    	cWhere := "@D_E_L_E_T_ = ' ' AND "
	    	cWhere += " B1_COD IN (" +  cProduto +")"
	    EndIf
	EndIf
	
	RestArea(aArea)
	    
Return cWhere
 