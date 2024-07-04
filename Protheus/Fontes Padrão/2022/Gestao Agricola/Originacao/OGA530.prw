#INCLUDE "OGA530.ch"
#INCLUDE "protheus.ch"
#INCLUDE "fwmvcdef.ch"

/* {Protheus.doc} OGA530        
Painel da Instrução de Embarque

@author 	Tamyris Ganzenmueller
@since 		26/07/2017
@version 	1.0
@param 		Nil
@return 	Nil
*/
Function OGA530(cCodCtr)
		
	Local cFiltroDef := "NJR_MODELO IN ('2','3') AND NJR_STATUS IN ('A','I') AND NJR_TIPO IN ('2','4')"

	Private aCadenc  := {}
	Private oMBrowse := {}

	If  !Empty(cCodCtr)
		cFiltroDef += " AND NJR_CODCTR='"+cCodCtr+"'"
	Else
		//se não vier com o codigo do contrato, limpo todas as marcações
		While N9A->(!Eof())
			If !empty(N9A->N9A_OK) 
				If RecLock( "N9A", .F. )
					N9A->N9A_OK := ' ' //LIMPO A MARCAÇÃO												
					N9A->( MsUnLock() )
				EndIf
			EndIf
		//Retoma a área e vai para o próximo registro
		N9A->(DbSkip())
		EndDo
		
		N9A->(DbCloseArea())
		
	EndIf	

	oMBrowse := FWMarkBrowse():New()	
	oMBrowse:SetAlias("N9A")
	oMBrowse:SetDescription(STR0005) // Painel de Instrução 
	oMBrowse:SetFieldMark("N9A_OK")	 // Define o campo utilizado para a marcacao	
	oMBrowse:AddFilter(STR0018,cFiltroDef,.T.,.T.,"NJR") // "Somente contratos abertos ou iniciados"
	
	oMBrowse:oBrowse:SetAttach(.T.)
	oMBrowse:SetMenuDef( "OGA530" )
				
	oMBrowse:AddLegend("N9A_QTDINS = 0", "GREEN", STR0019) //"Saldo a Instruir"
	oMBrowse:AddLegend("N9A_SDOINS > 0 .AND. N9A_QTDINS > 0", "YELLOW", STR0020) //"Instruído parcial"	
	oMBrowse:AddLegend("N9A_SDOINS = 0", "BLUE", STR0021) //"Totalmente instruído"
	
	oMBrowse:Activate()
	
Return()

/*{Protheus.doc} MenuDef()
@type  Function
@author francisco.nunes
@since 08/06/2018
@version 1.0
*/
Static Function MenuDef()
	Local aRotina := {} 

	aAdd(aRotina, {STR0022, "PesqBrw", 0, 1, 0, .T.})  //'Pesquisar'	
	aAdd(aRotina, {STR0007, "OGA530GRV()", 0, 4, 0, Nil})  //"Instrução Embarque"
	aAdd(aRotina, {STR0014, "OGA530NFUT()", 0, 4, 0, Nil}) //"NF Operação Futura"	
	aAdd(aRotina, {STR0025, "OGA530IE()", 0, 4, 0, Nil}) //"Instrução"	
	aAdd(aRotina, {STR0026, "OGA290( ,,,N9A->N9A_CODCTR )", 0, 4, 0, Nil}) //"Contrato de Vendas"		
Return aRotina

/*{Protheus.doc} OGA530GRV

@author 	Tamyris Ganzenmueller
@since 		27/07/2017
@version 	1.0
@param 		Nil
@return 	Nil
*/
Function OGA530GRV()
	
	Local lRet      := .T.
	Local aAreaN9A  := N9A->(GetArea())
	Local cVldTip   := "" // variavel para armazenar o tipo de mercado
	Local cVldTpCtr := "" // variável para armazenar o tipo de contrato
	Local cVldCodPg := "" // Variavel para armazenar a Condição de Pagamento
	Local cVldCtr	:= "" // variavel para armazenar chave de validação da seleção de varios registros
	Local lQtdSldZ  := .F.	//variavel para validar se registro tem saldo zero
	Local nInd      := 0
	Local oModel    := {}
	Local oModelN7S := {}
	Local oModelN7Q := {}
	Local nPos := 0
	Local lRestFluig := FwIsInCallStack("OGAWPUTIE")
		
	If lRestFluig //chamado pela função REST Portal Fluig
		//variavel aDadosRest definida na função REST-FLUIG
		For nInd := 1 to Len(aDadosRest)			
			DBSelectArea("N9A")
			N9A->(dbSetOrder(1))
			If N9A->(DbSeek(FWxFilial("N9A")+aDadosRest[nInd][2]+aDadosRest[nInd][3]+aDadosRest[nInd][4]))
				If !OGA530VDSG(@cVldTip,@cVldTpCtr,@cVldCodPg,@cVldCtr)
					oRespRest["content"][1]["warning"] := STR0028 //"Registros selecionados estão divergentes, selecione registros de mesmo tipo de mercado, tipo de contrato, condição de pagamento, cliente e produto."
					Return .F.
				EndIf
			EndIf
		Next nInd
		
	Else
		//se é pelo OGA530
		aCadenc := {}
		//Posiciona no topo da lista	
		N9A->(DbGoTop())
		While N9A->(!Eof())
				
			If oMBrowse:IsMark() 
				
				If N9A->N9A_SDOINS = 0
			        lQtdSldZ := .T.
			        N9A->(DbSkip())
			        LOOP
			    EndIf
			    
			    If !OGA530VDSG(@cVldTip,@cVldTpCtr,@cVldCodPg,@cVldCtr)
					Return .F.
				EndIf
				
	        EndIf
			
			N9A->(DbSkip())
		EndDo
		
		If lQtdSldZ
			MsgAlert(STR0010)
    	EndIf
    	
    	//apos a montagem da aCadenc, limpo as marcações.
    	OG530LDCAD() //movido para este bloco
    			
	EndIf

    If Len(aCadenc) > 0
    	oModel := FwLoadModel('OGA710')
    	
    	If lRestFluig //chamado pela função REST Portal Fluig
	    	// Remoção de when de campos 
			For nInd := 1 To Len(oModel:aAllSubModels)
				oModel:aAllSubModels[nInd]:GetStruct():SetProperty( "*", MODEL_FIELD_WHEN, {| oField | .T. } ) 
			Next nInd
		EndIf
    	
    	oModelN7Q := oModel:GetModel("N7QUNICO")
	    oModelN7S := oModel:GetModel("N7SUNICO")	        	
    
	    For nInd := 1 to Len(aCadenc)				
			If nInd = 1
				oModel:SetOperation(MODEL_OPERATION_INSERT)
				oModelN7S:SetNoInsertLine(.F.)
				
				If oModel:Activate()						
					oModelN7Q:LoadValue('N7Q_ENTENT', aCadenc[nInd][6])
					oModelN7Q:SetValue('N7Q_LOJENT', aCadenc[nInd][7])				
					oModelN7Q:SetValue('N7Q_IMPORT', aCadenc[nInd][15])
					oModelN7Q:SetValue('N7Q_IMLOJA', aCadenc[nInd][16])									
					oModelN7Q:SetValue("N7Q_VIA",POSICIONE('NJR',1,XFILIAL('NJR')+aCadenc[nInd][1]+aCadenc[nInd][2],'NJR_VIA')) // Seta via do contrato(NJR_VIA) para a IE(N7Q_VIA)
					oModelN7Q:SetValue("N7Q_CODSAF",POSICIONE('NJR',1,XFILIAL('NJR')+aCadenc[nInd][1]+aCadenc[nInd][2],'NJR_CODSAF')) // Seta a safra do contrato(NJR_CODSAF) para a IE(N7Q_CODSAF)
					oModelN7Q:SetValue("N7Q_CODPRO",POSICIONE('NJR',1,XFILIAL('NJR')+aCadenc[nInd][1]+aCadenc[nInd][2],'NJR_CODPRO')) // Seta Produto do contrato(NJR_CODPRO) para a IE(N7Q_CODPRO)
					oModelN7Q:SetValue("N7Q_DESPRO",POSICIONE('SB1',1,XFILIAL('SB1')+oModelN7Q:getValue("N7Q_CODPRO"),'B1_DESC')) // Seta Desc. Produto do contrato(B1_DESC) para a IE(N7Q_DESPRO)
					oModelN7Q:SetValue("N7Q_INCOTE",POSICIONE('NJR',1,XFILIAL('NJR')+aCadenc[nInd][1]+aCadenc[nInd][2],'NJR_INCOTE')) // Seta INCOTERM do contrato(NJR_INCOTE) para a IE(N7Q_INCOTE)
					oModelN7Q:SetValue("N7Q_UNIMED",POSICIONE('NJR',1,XFILIAL('NJR')+aCadenc[nInd][1]+aCadenc[nInd][2],'NJR_UM1PRO')) // Seta Unid. Med. do contrato(NJR_UM1PRO) para a IE(N7Q_UNIMED)
					oModelN7Q:SetValue("N7Q_CONDPA",POSICIONE('NJR',1,XFILIAL('NJR')+aCadenc[nInd][1]+aCadenc[nInd][2],'NJR_CONDPA')) // Seta Modalidade de pagamento do contrato(NJR_CONDPA) para a IE(N7Q_CONDPA)
					oModelN7Q:SetValue("N7Q_CONDPG",POSICIONE('NJR',1,XFILIAL('NJR')+aCadenc[nInd][1]+aCadenc[nInd][2],'NJR_CONDPG')) // Seta Condição de Pagamento do contrato(NJR_CONDPG) para IE(N&Q_CONDPG)
					oModelN7Q:SetValue("N7Q_DIASPG",POSICIONE('NJR',1,XFILIAL('NJR')+aCadenc[nInd][1]+aCadenc[nInd][2],'NJR_DIASPG')) // Seta Dias da Condição de Pagamento do contrato(NJR_DIASPG) para IE(N7Q_DIASPG)
					oModelN7Q:SetValue("N7Q_TIPCLI",POSICIONE('N9A',1,XFILIAL('N9A')+aCadenc[nInd][1]+aCadenc[nInd][2],'N9A_TIPCLI')) // Seta Tipo de Cliente da Regra Fiscal(N9A_TIPCLI) para IE(N7Q_TIPCLI)
					oModelN7Q:SetValue("N7Q_TPCTR", IIf(aCadenc[nInd][14] == "2","1","2")) // Seta tipo de contrato (1 - Venda; 2 - Armazenagem)
					oModelN7Q:SetValue("N7Q_TPMERC", POSICIONE('N9A',1,XFILIAL('N9A')+aCadenc[nInd][1]+aCadenc[nInd][2],'N9A_TIPMER')) // Seta tipo de mercado (1 - Interno; 2 - Externo)
				EndIf
			Else
				oModelN7S:AddLine()
				If oModel:IsActive() .AND. Empty(oModelN7Q:GetValue('N7Q_VIA')) //se a via ainda estiver vazia
					oModelN7Q:setValue("N7Q_VIA",POSICIONE('NJR',1,XFILIAL('NJR')+aCadenc[nInd][1]+aCadenc[nInd][2],'NJR_VIA')) //seta via do contrato(NJR_VIA) para a IE(N7Q_VIA)
				EndIf
			EndIf
						
			If oModel:IsActive()								
				oModelN7S:SetValue('N7S_CODCTR', aCadenc[nInd][1])
				oModelN7S:SetValue('N7S_ITEM',   aCadenc[nInd][2])
				oModelN7S:SetValue('N7S_DATINI', aCadenc[nInd][3])
				oModelN7S:SetValue('N7S_DATFIM', aCadenc[nInd][4])		
				oModelN7S:SetValue('N7S_QTDDCD', aCadenc[nInd][5])
				oModelN7S:SetValue('N7S_SEQPRI', aCadenc[nInd][8])
				oModelN7S:SetValue('N7S_CODFIN', aCadenc[nInd][9])
				oModelN7S:SetValue('N7S_DESFIN', Posicione('N8A',1,FWxFilial('N8A')+aCadenc[nInd][9],'N8A_DESFIN'))
				oModelN7S:SetValue('N7S_OPEFIS', aCadenc[nInd][10])
				oModelN7S:SetValue('N7S_FILORG', aCadenc[nInd][11])
				oModelN7S:SetValue('N7S_TES'   , aCadenc[nInd][13])
				oModelN7S:SetValue('N7S_CTREXT', Posicione('NJR',1,xFilial('NJR')+aCadenc[nInd][1],'NJR_CTREXT'))
				oModelN7S:SetValue('N7S_GENMOD', Posicione('NJR',1,FwxFilial('NJR')+aCadenc[nInd][1],'NJR_GENMOD'))
				oModelN7S:SetValue('N7S_OPETRI', aCadenc[nInd][17])
				oModelN7S:SetValue('N7S_OPEFUT', aCadenc[nInd][18])
				oModelN7S:SetValue('N7S_CODROM', aCadenc[nInd][19])											
			EndIf	
			
		Next nInd
		
		If lRestFluig //chamado pela função REST Portal Fluig para inclusão da IE
			//as variaveis cDesIERest,cProcessRest e oRespRest devem estar definidas na função REST-FLUIG
			oModelN7Q:SetValue('N7Q_DESINE', cDesIERest )
			oModelN7Q:SetValue('N7Q_FLUIG' , cProcessRest ) 
			
			If cIncoEXWRest == "S" .and. !Empty(Alltrim(cCodEntRest)) .and. !Empty(Alltrim(cLojEntRest)) .and.  (Alltrim(oModelN7Q:GetValue('N7Q_IMPORT')) != Alltrim(cCodEntRest) .or. Alltrim(oModelN7Q:GetValue('N7Q_IMLOJA')) != Alltrim(cLojEntRest))
				//se incoterm for EXW, via Fluig poderá ser mudado a entidade de entrega para uma das lojas da entidade, assim quando incoterm EXW o cliente irá buscar o produto na entidade de faturamento o qual será tambem a entidade de entrega
				oModelN7Q:SetValue('N7Q_IMPORT', cCodEntRest) //entidade faturamento
				oModelN7Q:SetValue('N7Q_IMLOJA', cLojEntRest)
				If !Empty(Alltrim(oModelN7Q:GetValue('N7Q_ENTENT')))
					//só grava se entidade entrega estiver preenchido, senão mantem em branco
					oModelN7Q:SetValue('N7Q_ENTENT', cCodEntRest) //entidade entrega
					oModelN7Q:SetValue('N7Q_LOJENT', cLojEntRest)	
				EndIf
					
			EndIf
			
			For nInd := 1 To oModelN7S:Length() 
				oModelN7S:GoLine(nInd)
				
				nPos :=  ASCAN( aDadosRest,{ |x| x[2]+x[3]+x[4] == oModelN7S:GetValue('N7S_CODCTR')+oModelN7S:GetValue('N7S_ITEM')+oModelN7S:GetValue('N7S_SEQPRI') })
				If nPos > 0
					If AGRTPALGOD(oModelN7Q:GetValue('N7Q_CODPRO'))
						oModelN7S:SetValue('N7S_QTDSOL', VAL(aDadosRest[nPos][6])) //qtd solicitada
					Else
						oModelN7S:SetValue('N7S_QTDVIN', VAL(aDadosRest[nPos][6])) //qtd instruida
					EndIf
					oModelN7S:SetValue('N7S_DATINI', CToD(aDadosRest[nPos][7]))
					oModelN7S:SetValue('N7S_DATFIM', CToD(aDadosRest[nPos][8]))
				EndIf
			Next nInd
			
			cCodIERest := oModelN7Q:GetValue("N7Q_CODINE") //cCodIERest VARIAVEL PRIVATE DA FUNÇÃO REST
			If oModel:VldData() //valida se esta tudo ok
				lRet := OG710GIERWS(@oModel,aDadosRest,aRestBlocos)//chama função responsavel por gravar os blocos e a IE
			Else
				lRet := .F. //erro
			EndIf
			
			If lRet
				oRespRest["content"][1]["IE"] := oModelN7Q:GetValue('N7Q_CODINE') //Codigo protheus da IE
			Else
				oRespRest["content"][1]["warning"] := oModel:GetErrorMessage()[6] + oModel:GetErrorMessage()[7] //mensagens de erro
			EndIf
			
			oModel:DeActivate()//DESATIVA O MODELO

		Else
			//OGA530
			oModelN7S:SetNoInsertLine(.T.)
	
	 		xRet := FWExecView(oModel:GetDescription(), "OGA710", MODEL_OPERATION_INSERT, , , ,0, , , , , oModel)
	 		
	 		OG530LDCAD()	
	 	EndIf	
	Else
		MsgInfo(STR0011)
	EndIf
	
	RestArea(aAreaN9A)

Return lRet

/*{Protheus.doc} OGA530VlIE

@author 	Francisco Kennedy Nunes Pinheiro
@since 		31/07/2017
@version 	1.0
@param 		Nil
@return 	Nil
*/
Function OGA530VlIE(cCodCtr, cItemCad, cItemReg)

	nVlIEM := 0

	//--- Qtd Instruída ---//
	cAlias2 := GetNextAlias()
	cQry2 := " SELECT SUM(N7S_QTDVIN) AS QTDVIN FROM " + RetSqlName("N7S") + " N7S "
	cQry2 += "  WHERE N7S.N7S_FILIAL  = '" + xFilial("N7S") + "' " 
	cQry2 += "    AND N7S.N7S_CODCTR  = '" + cCodCtr + "' " 
	cQry2 += "    AND N7S.N7S_ITEM    = '" + cItemCad + "' " 
	cQry2 += "    AND N7S.N7S_SEQPRI    = '" + cItemReg + "' " 
	cQry2 += "    AND N7S.D_E_L_E_T_ = ' ' "	
	
	cQry2 := ChangeQuery(cQry2)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry2),cAlias2, .F., .T.) 
	DbselectArea( cAlias2 )
	DbGoTop()
	If (cAlias2)->( !Eof() )
	
		nVlIEM := (cAlias2)->QTDVIN			
	EndIf
	(cAlias2)->(DbCloseArea())
	
Return (nVlIEM)

/*
{Protheus.doc} OGA530POS
Função criada para setar os valores corretamente nos campos o valor para inicializar os campos

@author thiago.rover
@since 11/04/2018
@version undefined
@param cCampo, characters, descricao
@type function
*/
Function OGA530POS(cCampo)

	Local cRetorno
	Local nInd := 0
	
	For nInd := 1 To Len(aCadenc)

	    If(cCampo == "M->N7S_OPETRI")
	       cRetorno := Posicione("N9A",1,xFilial("N9A")+aCadenc[nInd][1]+aCadenc[nInd][2]+aCadenc[nInd][8],"N9A_OPETRI")
	    ElseIf(cCampo == "M->N7S_OPEFUT")
	       cRetorno := Posicione("N9A",1,xFilial("N9A")+aCadenc[nInd][1]+aCadenc[nInd][2]+aCadenc[nInd][8],"N9A_OPEFUT")
	    ElseIf(cCampo == "M->N7S_CODROM")
	       cRetorno := Posicione("N9A",1,xFilial("N9A")+aCadenc[nInd][1]+aCadenc[nInd][2]+aCadenc[nInd][8],"N9A_CODROM")
	    EndIf
			    
	Next nInd

Return cRetorno

/*
{Protheus.doc} OG530DESPG
Retorna a descrição da condição de pagamento do contrato

@author francisco.nunes
@since 09/06/2018
@version 1.0
@param cFilCtr, characters, Filial do Contrato
@param cCodCtr, characters, Código do Contrato
@type function
*/
Function OG530DESPG(cFilCtr, cCodCtr)

	Local cRetorno := ""
	Local aAreaNJR := NJR->(GetArea())
	
	DbSelectArea("NJR")
	NJR->(DbSetOrder(1)) // NJR_FILIAL+NJR_CODCTR
	If NJR->(DbSeek(cFilCtr+cCodCtr))
		cRetorno := MSMM(Posicione('SY6',1,FWxFilial("SY6")+NJR->NJR_CONDPG+STR(NJR->NJR_DIASPG,AVSX3("NJR_DIASPG",3)),'Y6_DESC_P'))
	EndIf
	
	RestArea(aAreaNJR)	

Return cRetorno

/*{Protheus.doc} OGA530NFUT

@author 	Tamyris Ganzenmueller
@since 		02/04/2018
@version 	1.0
@param 		Nil
@return 	Nil
*/
Function OGA530NFUT()
	Local lTemReg := .F.
	
	//Posiciona no topo da lista	
	N9A->(DbGoTop())
	While N9A->(!Eof())

		If oMBrowse:IsMark() 		
						
			/*Validações*/
			If N9A->N9A_OPEFUT = '1' .And. Empty(N9A->N9A_CODROM) .And. N9A->N9A_QUANT > 0
				NJR->(DbGoTop())
				NJR->(DbSetorder(1)) //NJR_FILIAL + NJR_CODCTR 
				NJR->(DbSeek(N9A->N9A_FILIAL+N9A->N9A_CODCTR))
			
		        MsgRun(STR0015, STR0016, {|| OGX290InRom()}) //Gerando Romaneio Global ## AGUARDE
		        lTemReg := .T.
	        EndIf
        EndIf
                                      
		//Retoma a área e vai para o próximo registro
		N9A->(DbSkip())
	EndDo	
		
	If !lTemReg
		Help(" ",1,".OGA530000001.")
 		Return .F.
	EndIf
	
	If lTemReg
		OG530LDCAD()
	EndIf
	
Return .T.

/*{Protheus.doc} OG530LDCAD
Desmarca as regras fiscais

@author 	francisco.nunes
@since 		09/06/2018
@version 	1.0
@param 		Nil
@return 	Nil
*/
Static Function OG530LDCAD()

	//Posiciona no topo da lista	
	N9A->(DbGoTop())
	While N9A->(!Eof())
	
		If oMBrowse:IsMark()
			// Desmarca a regra fiscal
	        oMBrowse:MarkRec()
		EndIf
	
		//Retoma a área e vai para o próximo registro
		N9A->(DbSkip())
	EndDo
	

Return .T.


/*{Protheus.doc} OGA530IE
Filtra as IEs pela regra fiscal

@author 	Christopher.miranda
@since 		14/09/2018
@version 	1.0
@param 		Nil
@return 	Nil
*/
Function OGA530IE()
	Local aIE := {}

	If N9A->N9A_QTDINS = 0

		Help( , , STR0023, , STR0024, 1, 0 )

	Else
		DbSelectArea("N7S")
		N7S->(DbSetorder(2)) //N7S_FILIAL+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI
		If (N7S->(DbSeek(fWxFilial("N7S")+N9A->N9A_CODCTR+N9A->N9A_ITEM+N9A->N9A_SEQPRI)))

			While N7S->(!Eof()) .AND. N7S->(N7S_FILIAL+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI) == N9A->(N9A_FILIAL+N9A_CODCTR+N9A_ITEM+N9A_SEQPRI)

					aAdd(aIE,N7S->(N7S_CODINE))

				N7S->(DbSkip())

			EndDo

			if len(aIE) > 0

				OGA710("",aIE)

			EndIf

		EndIf
	
	EndIf

Return

/*/{Protheus.doc} OGA530VDSG
//TODO Na inclusão da IE via painel, valida os dados selecioandos no painel e preenche a variavel responsavel por setar os dados na instrução de embarque 
@author claudineia.reinert
@since 08/11/2018
@version 1.0
@return ${return}, ${return_description}
@param cVldTip, characters, tipo de mercado, deve ser passado por referencia 
@param cVldTpCtr, characters, tipo de contrato,, deve ser passado por referencia 
@param cVldCodPg, characters, condição de pagamento, deve ser passado por referencia 
@param cVldCtr, characters, string validação N9A, deve ser passado por referencia 
@type function
/*/
Function OGA530VDSG(cVldTip,cVldTpCtr,cVldCodPg,cVldCtr)

	Local cTes := ""

	// Validar se as regra fiscais selecionadas são do mesmo tipo de mercado  (Interno e Externo)
	If Empty(cVldTip)
		cVldTip := N9A->N9A_TIPMER
	ElseIf cVldTip != N9A->N9A_TIPMER
		// Pré-instrução com tipos de mercado diferentes (Interno e Externo)
		aCadenc := {}
		Help(" ",1,"OGA530ValTip")
		Return .F.
	EndIf
	
	// Validar se as regra fiscais selecionadas selecionadas são do mesmo tipo de contrato (Venda e Armazenagem)
	If Empty(cVldTpCtr)
		cVldTpCtr := N9A->N9A_TIPCTR
	ElseIf cVldTpCtr != N9A->N9A_TIPCTR
		// Pré-instrução com tipos de contrato diferentes (Venda e Armazenagem)
		aCadenc   := {}
		Help(" ",1,"OGA530VALCTR")
		Return .F.
	EndIf
			
	// Validar se as regra fiscais selecionadas são do mesmo Tipo de Pagamento
	If Empty(cVldCodPg)
		cVldCodPg := N9A->N9A_CONDPG
	ElseIf cVldCodPg != N9A->N9A_CONDPG
		//Pré-instrução com Tipo de Pagamento diferentes 
		aCadenc   := {}
		Help(" ",1,"OGA530VALPAG")
		Return .F.
	EndIf
					
	// Validar se as regra fiscais selecionadas são da mesma Entidade / Icoterm e Produto
	If Empty(cVldCtr) 
		cVldCtr := Alltrim(N9A->N9A_CODENT+N9A->N9A_LOJENT+N9A->N9A_INCOTE+N9A->N9A_CODPRO)              
	ElseIf cVldCtr != Alltrim(N9A->N9A_CODENT+N9A->N9A_LOJENT+N9A->N9A_INCOTE+N9A->N9A_CODPRO)
		// Se as entregas selecionadas forem de cliente ou produto ou icoterm diferente, 
		// não permite gerar a instrução de embarque     
		aCadenc   := {}
		Help(" ",1,"OGA530VALCADIE")
		Return .F.
	EndIf
	
	//valida verificando se a regra fiscal possui TES
	If Empty(N9A->N9A_TES) 
		// não permite gerar a instrução de embarque     
		aCadenc   := {}
		Help(" ",1,"OGA530VALTESIE")
		Return .F.
	EndIf
	
	If N9A->N9A_OPEFUT = "1" 
		cTes := N9A->N9A_TESAUX  //Se for operação futura utilizo a TES de Remessa para N7S
	Else
		cTes := N9A->N9A_TES
	Endif

	//se tudo ok, grava na variavel private aCadenc os dados
	Aadd(aCadenc, {N9A->N9A_CODCTR,;
					N9A->N9A_ITEM,;
					N9A->N9A_DATINI,;
					N9A->N9A_DATFIM,;
					N9A->N9A_SDOINS,;
					N9A->N9A_ENTENT,;
					N9A->N9A_LJEENT,;
					N9A->N9A_SEQPRI,;
					N9A->N9A_CODFIN,;
					N9A->N9A_OPEFIS,;
					N9A->N9A_FILORG,;
					N9A->N9A_CODPRO,;
					cTes,;
					N9A->N9A_TIPCTR,;
					N9A->N9A_CODENT,;
					N9A->N9A_LOJENT,;
					N9A->N9A_OPETRI,;
					N9A->N9A_OPEFUT,;
					N9A->N9A_CODROM,;		 										
					N9A->N9A_VLUFPR,;
					N9A->N9A_VLTFPR,;
					N9A->N9A_TIPMER})		

Return .T.
