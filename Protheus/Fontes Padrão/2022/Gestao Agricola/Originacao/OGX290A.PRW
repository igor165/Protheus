#INCLUDE "Protheus.ch"
#INCLUDE "fwMvcDef.ch"
#INCLUDE "oga290.ch"

#DEFINE _CRLF CHR(13)+CHR(10)

Static __lMarcAllD	:= .T.

/** {Protheus.doc} OGA290NFUT
Rotina para gerar nota fiscal venda futura conforme condições do contrato. 
Apresentar grid com as regras fiscais disponíveis para geração da nota

@param: 	Nil
@return:	Nil
@author: 	Tamyris Ganzenmueller
@since: 	11/01/2018
@Uso: 		OGA290
*/
Function OGX290NFUT()
	Local aArea     := GetArea()
	Local oDlg	    := Nil
	Local oFwLayer  := Nil
	Local oPnDown   := Nil
	Local oSize     := Nil
	//Local _oBrwMrk 	:= Nil
	Local aButtons  := {}
	Local nOpcX     := 0	    
    Local aColumns  := {}
    Local lEdit     := .F.
	Private _lAutomato := IiF(IsBlind(),.T.,.F.) //automação
    Private _aRegraFut := {}
    Private _oBrwMrk   := nil
    Private _lFormProp := .T.
    Private _cCodCtr   := NJR->NJR_CODCTR

	If .not. NJR->NJR_STATUS $ "A|I"
		Help( ,,STR0031,, STR0165 , 1, 0 ) //"AJUDA"###"Operação não permitida para contrato com status diferente de Aberto ou Iniciado"
		Return .F.
	EndIf    
    
    If NJR->NJR_TIPO = "1" .AND. !_lAutomato
        _lFormProp := MsgNoYes(STR0282) //"A emissão do documento fiscal será por formulário próprio?"

        If !_lFormProp
            lEdit := .T.
        EndIf
    EndIf   
    
    fLoadRegra()

	If !_lAutomato
		oSize := FWDefSize():New(.T.)
		oSize:AddObject( "ALL", 100, 100, .T., .T. )    
		oSize:lLateral	:= .F.  // Calculo vertical	
		oSize:Process() //executa os calculos

		oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4],;
		STR0164 , , , , , CLR_BLACK, CLR_WHITE, , , .t. ) 
		
		oFwLayer := FwLayer():New()
		oFwLayer:Init( oDlg, .f., .t. )

		oFWLayer:AddLine( 'UP', 5, .F. )
		oFWLayer:AddCollumn( 'ALL' , 100, .T., 'UP' )

		oFWLayer:AddLine( 'DOWN', 95, .F. )
		oFWLayer:AddCollumn( 'ALL' , 100, .T., 'DOWN' )

		oPnDown := TPanel():New(0 , 0,,oDlg,,.F.,.F.,,,450,960,.T.,.T.)
		oPnDown:Align	:= CONTROL_ALIGN_ALLCLIENT                        

        _oBrwMrk:=FWBrowse():New(oPnDown)  
		_oBrwMrk:SetDescription( STR0164 ) 
        _oBrwMrk:SetDataArray(.T.)        
        _oBrwMrk:SetArray(_aRegraFut)        
        _oBrwMrk:SetEditCell( .T. )        

        _oBrwMrk:AddMarkColumns( { ||Iif( !Empty( _aRegraFut[_oBrwMrk:nAt,1] = "1" ),"LBOK","LBNO" ) }, { || fUPDMARK(_oBrwMrk, .f.)}  )                    
        
        fAddColumn("N9A_CODCTR", .F.,    { || _aRegraFut[_oBrwMrk:nAt, 2] }, @aColumns)       
        fAddColumn("N9A_ITEM"  , .F.,    { || _aRegraFut[_oBrwMrk:nAt, 3] }, @aColumns)       
        fAddColumn("N9A_SEQPRI", .F.,    { || _aRegraFut[_oBrwMrk:nAt, 4] }, @aColumns)       
        fAddColumn("N9A_TES"   , .F.,    { || _aRegraFut[_oBrwMrk:nAt, 5] }, @aColumns)       
        fAddColumn("N9A_TESAUX", .F.,    { || _aRegraFut[_oBrwMrk:nAt, 6] }, @aColumns)       
        fAddColumn("N9A_CODENT", .F.,    { || _aRegraFut[_oBrwMrk:nAt, 7] }, @aColumns)       
        fAddColumn("N9A_LOJENT", .F.,    { || _aRegraFut[_oBrwMrk:nAt, 8] }, @aColumns)       
        fAddColumn("N9A_NOMENT", .F.,    { || _aRegraFut[_oBrwMrk:nAt, 9] }, @aColumns)       
        fAddColumn("N9A_ENTENT", .F.,    { || _aRegraFut[_oBrwMrk:nAt, 10]}, @aColumns)       
        fAddColumn("N9A_LJEENT", .F.,    { || _aRegraFut[_oBrwMrk:nAt, 11]}, @aColumns)       
        fAddColumn("N9A_NMEENT", .F.,    { || _aRegraFut[_oBrwMrk:nAt, 12]}, @aColumns)       
        fAddColumn("N9A_CODPRO", .F.,    { || _aRegraFut[_oBrwMrk:nAt, 13]}, @aColumns)       
        fAddColumn("N9A_DESPRO", .F.,    { || _aRegraFut[_oBrwMrk:nAt, 14]}, @aColumns)       
        fAddColumn("N9A_FILORG", .F.,    { || _aRegraFut[_oBrwMrk:nAt, 15]}, @aColumns)       
        fAddColumn("N9A_QUANT ", .F.,    { || _aRegraFut[_oBrwMrk:nAt, 16]}, @aColumns)               
        fAddColumn("N9A_VLUFPR", lEdit,  { || _aRegraFut[_oBrwMrk:nAt, 17]}, @aColumns,"",{|| _aRegraFut[_oBrwMrk:nAt, 18] := _aRegraFut[_oBrwMrk:nAt, 16] * _aRegraFut[_oBrwMrk:nAt, 17] })       
        fAddColumn("N9A_VLTFPR", lEdit,  { || _aRegraFut[_oBrwMrk:nAt, 18]}, @aColumns,"",{|| _aRegraFut[_oBrwMrk:nAt, 17] := _aRegraFut[_oBrwMrk:nAt, 18] / _aRegraFut[_oBrwMrk:nAt, 16] })               
        
        If lEdit
            fAddColumn("NJJ_DOCNUM", lEdit,  { || _aRegraFut[_oBrwMrk:nAt, 19]}, @aColumns)       
            fAddColumn("NJJ_DOCSER", lEdit,  { || _aRegraFut[_oBrwMrk:nAt, 20]}, @aColumns)       
            fAddColumn("NJJ_DOCEMI", lEdit,  { || _aRegraFut[_oBrwMrk:nAt, 21]}, @aColumns)  
            fAddColumn("NJJ_DOCESP", lEdit,  { || _aRegraFut[_oBrwMrk:nAt, 22]}, @aColumns, "42", {|| fValEsp( &(ReadVar()), 22) } )  
        EndIf
		
        _oBrwMrk:SetColumns(aColumns)
        _oBrwMrk:bHeaderClick := {|| MarcaTudo( _oBrwMrk, _aRegraFut, _oBrwMrk:nAt, @__lMarcAllD, .F. ) }
        
        If lEdit
            _oBrwMrk:acolumns[17]:cReadVar := '_aRegraFut[_oBrwMrk:nAt, 17]'                  
            _oBrwMrk:acolumns[18]:cReadVar := '_aRegraFut[_oBrwMrk:nAt, 18]'                  
            _oBrwMrk:acolumns[19]:cReadVar := '_aRegraFut[_oBrwMrk:nAt, 19]'                  
            _oBrwMrk:acolumns[20]:cReadVar := '_aRegraFut[_oBrwMrk:nAt, 20]'                  
            _oBrwMrk:acolumns[21]:cReadVar := '_aRegraFut[_oBrwMrk:nAt, 21]'                  
            _oBrwMrk:acolumns[22]:cReadVar := '_aRegraFut[_oBrwMrk:nAt, 22]'                  
        EndIf

        _oBrwMrk:Activate()	
		oDlg:Activate( , , , .t., { || fValidSave() }, , { || EnchoiceBar( oDlg, {|| nOpcX := 1, oDlg:End() },{|| nOpcX := 0, oDlg:End() },, @aButtons ) } )
	EndIf
    
	If (_lAutomato .OR. nOpcX = 1) 
		GeraRom()
	EndIf

	RestArea(aArea)
Return .T.

/** {Protheus.doc} FiltraMark
@param: 	Nil
@return:	Nil
@author: 	Tamyris Ganzenmueller
@since: 	11/01/2018
@Uso: 		OGA290
*/
Static Function fLoadRegra()
	Local cAliasQry := GetNextAlias()    
    
    BeginSql Alias cAliasQry
        SELECT * 
          FROM %table:N9A%
         WHERE N9A_FILIAL = %xFilial:N9A%
           AND N9A_CODCTR = %Exp:NJR->NJR_CODCTR%
           AND N9A_OPEFUT = '1'
           AND N9A_CODROM = %Exp:SPACE(TamSX3("N9A_CODROM")[1])%
           AND N9A_QUANT  > 0
           AND %notDel%
    EndSql

    While (cAliasQry)->(!Eof())
        aAdd(_aRegraFut, {"2"      , ; //[01]
            (cAliasQry)->N9A_CODCTR, ;
            (cAliasQry)->N9A_ITEM  , ;
            (cAliasQry)->N9A_SEQPRI, ;
            (cAliasQry)->N9A_TES   , ;
            (cAliasQry)->N9A_TESAUX, ;
            (cAliasQry)->N9A_CODENT, ;
            (cAliasQry)->N9A_LOJENT, ;
            POSICIONE("NJ0",1,xFilial("NJ0") + (cAliasQry)->N9A_CODENT +  (cAliasQry)->N9A_LOJENT, "NJ0_NOME"), ;
            (cAliasQry)->N9A_ENTENT, ;
            (cAliasQry)->N9A_LJEENT, ;
            POSICIONE("NJ0",1,xFilial("NJ0") + (cAliasQry)->N9A_ENTENT +  (cAliasQry)->N9A_LJEENT, "NJ0_NOME"), ;
            (cAliasQry)->N9A_CODPRO, ;
            POSICIONE("SB1",1,xFilial("SB1") + (cAliasQry)->N9A_CODPRO, "B1_DESC"), ;
            (cAliasQry)->N9A_FILORG, ;
            (cAliasQry)->N9A_QUANT , ;
            (cAliasQry)->N9A_VLUFPR, ;
            (cAliasQry)->N9A_VLTFPR, ;            
            SPACE(TamSX3("NJJ_DOCNUM")[1]), ;
            SPACE(TamSX3("NJJ_DOCSER")[1]), ;
            ctod(" / / "), ;
            SPACE(TamSX3("NJJ_DOCESP")[1]), ;
        })
        (cAliasQry)->(DbSkip())
    EndDo

    (cAliasQry)->(DbCloseArea())	

Return 

/** {Protheus.doc} GeraRom
Rotina para gerar nota fiscal venda futura conforme condições do contrato.
@return:	Nil
@author: 	Tamyris Ganzenmueller
@since: 	11/01/2018
@Uso: 		OGA290
*/
Static Function GeraRom()
    Local nLinha   := 0
    Local lRet     := .F.    

    NJR->(dbSetorder(1))
    N9A->(dbSetorder(1))
    If NJR->(dbSeek(xFilial("NJR") + _cCodCtr))
    
        //Posiciona no topo da lista	
        For nLinha := 1 To Len(_aRegraFut)
            If _lAutomato .OR. _aRegraFut[nLinha,1] == "1" 
                If N9A->(dbSeek( xFilial('N9A')+_aRegraFut[nLinha, 2] + _aRegraFut[nLinha, 3] + _aRegraFut[nLinha, 4]))                                        
                    MsgRun( STR0171, STR0170, {|| lRet := OGX290InRom(nLinha) } ) //Gerando Romaneio Global ## AGUARDE  
                    If !lRet                        
                        exit
                    EndIf
                EndIf
            EndIf
        Next nX
    EndIf

    If lRet .and. !_lAutomato
        MsgInfo(STR0281) //"Romaneio(s) gerado(s) com sucesso."
    EndIf	    

Return

/*{Protheus.doc} OGX290InRom
Criação do romaneio - Faturamento da Nota Global Entrega Futura 
@author Tamyris Ganzenmueller
@since 16/01/2018
@type function
*/
Function OGX290InRom(nLinha)
	Local oModelNJJ	:= Nil
	Local oAux 		:= Nil
	Local oStruct	:= Nil
	Local nI 		:= 0
	Local nJ 		:= 0
	Local nPos 		:= 0
	Local lRet 		:= .T.
	Local aAux 		:= {}
	Local nItErro 	:= 0
	Local lAux 		:= .T.
	Local cTpMov    := SuperGetMV("MV_AGRO010",.F.,'') //Tipo de movimento para Venda Futura
	
	Local nRecnoNJR	:= NJR->(Recno())
	Local nRecnoN9A := N9A->(Recno())
	
	Private __cIdMov := ''
	Private _lAltIE := .T. //oga250 usa esta variavel - realiza análise de crédito
    Private _lFutura := .T.

	BEGIN TRANSACTION
		//para criar registro na filial informada na Regra fiscal
		cFilCor := cFilAnt
		If !Empty(N9A->N9A_FILORG)
			cFilAnt := N9A->N9A_FILORG
		EndIf

		IF !Empty(cTpMov)   
			__cIdMov := fGerMvID( cTpMov )
		EndIF

		//apropriar valores nas tabelas correspondentes
		aFldNJJ := {}
		aFldNJM := {}
		aFldN9E := {}

		CarrRomArr(@aFldNJJ, @aFldNJM, @aFldN9E, nLinha) //carregar dados da tabela de contrato
		
		DbSelectArea("NJR")  
		NJR->( DbGoTo( nRecnoNJR ) )
		
		DbSelectArea("N9A")  
		N9A->( DbGoTo( nRecnoN9A ) )
		
		//coloca numa transação? yeah
		oModelNJJ := FWLoadModel( 'OGA250' )
		// Temos que definir qual a operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão
		oModelNJJ:SetOperation( 3 )
		// Antes de atribuirmos os valores dos campos temos que ativar o modelo
		oModelNJJ:Activate()

		// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
		oAux := oModelNJJ:GetModel( 'NJJUNICO' )   
		// Obtemos a estrutura de dados do cabeçalho
		oStruct := oAux:GetStruct()
		aAux    := oStruct:GetFields()

		If lRet
			If _lAutomato
				oStruct:SetProperty( "NJJ_QTDFIS" , MODEL_FIELD_WHEN, {||.T.} )
			EndIf
			For nI := 1 To Len( aFldNJJ )
				// Verifica se os campos passados existem na estrutura do cabeçalho
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aFldNJJ[nI][1] ) } ) ) > 0
					// È feita a atribuição do dado aos campo do Model do cabeçalho
					If !( lAux := oModelNJJ:SetValue( 'NJJUNICO', aFldNJJ[nI][1],aFldNJJ[nI][2] ) )
						// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
						// o método SetValue retorna .F.
						lRet := .F.
						Exit
					EndIf
				EndIf
			Next
		EndIf

		/*Comercialização*/
		If lRet
			// Instanciamos apenas a parte do modelo referente aos dados do item
			oAux := oModelNJJ:GetModel( 'NJMUNICO' )
			// Obtemos a estrutura de dados do item
			oStruct := oAux:GetStruct()
			aAux := oStruct:GetFields()
			nItErro := 0
			For nI := 1 To Len( aFldNJM )
				// Incluímos uma linha nova
				// ATENÇÃO: O itens são criados em uma estrutura de grid (FORMGRID), portanto já é criada uma primeira linha
				//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
				If nI > 1
					// Incluímos uma nova linha de item
					If ( nItErro := oAux:AddLine() ) <> nI
						// Se por algum motivo o método AddLine() não consegue incluir a linha, // ele retorna a quantidade de linhas já // existem no grid. Se conseguir retorna a quantidade mais 1
						lRet := .F.
						Exit
					EndIf
				EndIf
				For nJ := 1 To Len( aFldNJM[nI] )
					If aFldNJM[nI][nJ][1] == 'NJM_TRANS'
						aFldNJM[nI][nJ][2] :=  '1'
					ElseIf aFldNJM[nI][nJ][1] == 'NJM_TIPMOV'
						aFldNJM[nI][nJ][2] :=  '1'
					EndIf
					// Verifica se os campos passados existem na estrutura de item
					If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aFldNJM[nI][nJ][1] ) } ) ) > 0
						If !( lAux := oModelNJJ:SetValue( 'NJMUNICO', aFldNJM[nI][nJ][1], aFldNJM[nI][nJ][2] ) )
							// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
							// o método SetValue retorna .F.
							If oModelNJJ:CanSetValue('NJMUNICO', aFldNJM[nI][nJ][1])
								lRet := .F.
								nItErro := nI
								Exit
							EndIf
						EndIf
					EndIf
				Next nJ
				If !lRet
					Exit
				EndIf
			Next nI
		EndIf	

		/*Integração*/
		If lRet
			// Instanciamos apenas a parte do modelo referente aos dados do item
			oAux := oModelNJJ:GetModel( 'N9EUNICO' )
			// Obtemos a estrutura de dados do item
			oStruct := oAux:GetStruct()
			aAux := oStruct:GetFields()
			nItErro := 0
			For nI := 1 To Len( aFldN9E )
				// Incluímos uma linha nova
				// ATENÇÃO: O itens são criados em uma estrutura de grid (FORMGRID), portanto já é criada uma primeira linha
				//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
				If nI > 1
					// Incluímos uma nova linha de item
					If ( nItErro := oAux:AddLine() ) <> nI
						// Se por algum motivo o método AddLine() não consegue incluir a linha, // ele retorna a quantidade de linhas já // existem no grid. Se conseguir retorna a quantidade mais 1
						lRet := .F.
						Exit
					EndIf
				EndIf
				For nJ := 1 To Len( aFldN9E[nI] )
					// Verifica se os campos passados existem na estrutura de item
					If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aFldN9E[nI][nJ][1] ) } ) ) > 0
						If !( lAux := oModelNJJ:SetValue( 'N9EUNICO', aFldN9E[nI][nJ][1], aFldN9E[nI][nJ][2] ) )
							// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
							// o método SetValue retorna .F.
							lRet := .F.
							nItErro := nI
							Exit
						EndIf
					EndIf
				Next nJ
				If !lRet
					Exit
				EndIf
			Next nI
		EndIf		

		If lRet
			// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
			// neste momento os dados não são gravados, são somente validados.
			If ( lRet := oModelNJJ:VldData() ) 
				// Se o dados foram validados faz-se a gravação efetiva dos
				// dados (commit)
				//guarda o código do contrato a ser gravado 				
				lRet := oModelNJJ:CommitData()
			EndIf

		EndIf

		If !lRet			
			
			// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
			aErro := oModelNJJ:GetErrorMessage()

			AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1] ) + ']' )
			AutoGrLog( "Id do campo de origem: " + ' [' + AllToChar( aErro[2] ) + ']' )
			AutoGrLog( "Id do formulário de erro: " + ' [' + AllToChar( aErro[3] ) + ']' )
			AutoGrLog( "Id do campo de erro: " + ' [' + AllToChar( aErro[4] ) + ']' )
			AutoGrLog( "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' )
			AutoGrLog( "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' )
			AutoGrLog( "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' )
			AutoGrLog( "Valor atribuído: " + ' [' + AllToChar( aErro[8] ) + ']' )
			AutoGrLog( "Valor anterior: " + ' [' + AllToChar( aErro[9] ) + ']' )
			If nItErro > 0
				AutoGrLog( "Erro no Item: " + ' [' + AllTrim( AllToChar( nItErro ) ) + ']' )
			EndIf

			If !_lAutomato
				MostraErro()
			EndIf

			lRet := .F.

			Help( ,,STR0031,,STR0169, 1, 0 ) //"AJUDA"##"Não foi possivel gerar o romaneio."

		EndIf
		
		If !lRet
			DisarmTransaction()
			break
		EndIf
	END TRANSACTION	
		
	// Desativamos o Model
    oModelNJJ:DeActivate()

	//Volta para filial corrente
	cFilAnt := cFilCor
	
	//Atualização/Confirmação do romaneio retirado da TRANSACAO pois no momento do envio da NF
	// o pedido de venda e a NF referentes já devem estar gravadas.
	if lRet
		DbSelectArea("NJR")  
		NJR->( DbGoTo( nRecnoNJR ) )
		
		DbSelectArea("N9A")  
		N9A->( DbGoTo( nRecnoN9A ) )
			
		//Valida se o produto é algodão
		If AGRTPALGOD(NJR->NJR_CODPROD)		
			//Gera movimento fardos - em transito		
			MovFardos()
		EndIf
		
		lRet := OGA250ATUC( Alias(), Recno(), 4, .t. )

		//Se retornar .F., excluo o romaneio e não permito que faça o vinculo nas regras fiscais(N9A)
		If !lRet
			oModelNJJ:SetOperation(5)             
		    If oModelNJJ:Activate()
				If oModelNJJ:VldData()

					oModelNJJ:CommitData()

					If !_lAutomato
                        MsgAlert(STR0236) 
                    EndIf
					//"Romaneio não pode ser atualizado devido a pendencias apresentadas e será excluido.")
	
				EndIf
				oModelNJJ:DeActivate()
			EndIf
		Else		
			DbSelectArea("N9A")  
			N9A->( DbGoTo( nRecnoN9A ) ) //REPOSICIONA NOVAMENTE NO REGISTRO			
			If RecLock( "N9A", .f. )
				N9A->N9A_CODROM := NJJ->NJJ_CODROM
				N9A->( MsUnLock() )
			EndIf
		EndIf
		
		
	endIf
	
return (lRet)

/*{Protheus.doc} CarrRomArr
CarRega o array de dados para geração do romaneio
@author Tamyris Ganzenmueller
@since 16/01/2018
@param aFldNJJ, array campos NJJ
@param aFldNNY, array campos NJM
@type function
*/
Static Function CarrRomArr(aFldNJJ, aFldNJM, aFldN9E, nLinha)
	Local aAux	    := {}
	Local cLocal    := ''
	Local nItRom	:= 0
	Local nQuant    := 0
    Local cTipoRom  := ""
    Local cSubTipo  := ""
    Local nValUnit  := 0
    Local aDadosNF  := {}

	dbSelectArea( "NJ0" )
	dbSetOrder( 1 )
	If .Not. dbSeek( xFilial( "NJ0" ) + N9A->( N9A_CODENT + N9A_LOJENT) ) /*verificar*/
		Help( ,,STR0031,,STR0169, 1, 0 ) //"AJUDA"##"Não foi possivel gerar o romaneio."
		Return( .f. )
	EndIf

	DbSelectArea('SB1')
	SB1->( DbSetOrder(1) )
	IF SB1->(DbSeek(Fwxfilial('SB1') + NJR->NJR_CODPRO ))
		cLocal := SB1->B1_LOCPAD
	EndIf
	
	nQuant := IIf(N9A->N9A_QTDTKP > 0, N9A->N9A_QTDTKP , N9A->N9A_QUANT )

	/*Dados Tipo Romaneio*/
    If NJR->NJR_TIPO == "2"
	    cTipoRom := "4" 
        cSubTipo := "43"
    else
        cTipoRom := "5"
        cSubTipo := "51"
    EndIf 
    
    aAdd( aFldNJJ, { 'NJJ_TIPO'  , cTipoRom} ) 
    
    If _lFormProp
	    aAdd( aFldNJJ, { 'NJJ_TPFORM', "1" } )
    else
        aAdd( aFldNJJ, { 'NJJ_TPFORM', "2" } )
        aAdd( aFldNJJ, { 'NJJ_DOCNUM', _aRegraFut[nLinha, 19] } )
        aAdd( aFldNJJ, { 'NJJ_DOCSER', _aRegraFut[nLinha, 20] } )
        aAdd( aFldNJJ, { 'NJJ_DOCEMI', _aRegraFut[nLinha, 21] } )
        aAdd( aFldNJJ, { 'NJJ_DOCESP', _aRegraFut[nLinha, 22] } )

        aAdd( aFldNJJ, { 'NJJ_VLRUNI', _aRegraFut[nLinha, 17] } )
        aAdd( aFldNJJ, { 'NJJ_VLRTOT', _aRegraFut[nLinha, 18] } )        
		aDadosNF := {_aRegraFut[nLinha, 19], ; //[01] Nota Fiscal
                     _aRegraFut[nLinha, 20], ; //[02] Serie
                     _aRegraFut[nLinha, 21], ; //[03] Data
                     _aRegraFut[nLinha, 22], ; //[04] Espécie                     
                     _aRegraFut[nLinha, 18], ;  //[05] Valor total
					 _aRegraFut[nLinha, 17], ;  //[06] Valor unitario
					 nQuant }  //peso fiscal
    EndIf

	aAdd( aFldNJJ, { 'NJJ_TIPENT', "2" } ) 
	/*Dados do Contrato*/
	aAdd( aFldNJJ, { 'NJJ_FILORG', NJR->NJR_FILIAL} )
	aAdd( aFldNJJ, { 'NJJ_CODCTR', NJR->NJR_CODCTR} )
	aAdd( aFldNJJ, { 'NJJ_CODSAF', NJR->NJR_CODSAF} )
	aAdd( aFldNJJ, { 'NJJ_CODPRO', NJR->NJR_CODPRO} )
	aAdd( aFldNJJ, { 'NJJ_UM1PRO', NJR->NJR_UM1PRO} )	
	aAdd( aFldNJJ, { 'NJJ_TES'   , N9A->N9A_TES	  } )
	aAdd( aFldNJJ, { 'NJJ_LOCAL' , cLocal         } )
	/*Dados da Entidade*/
	aAdd( aFldNJJ, { 'NJJ_CODENT', NJ0->NJ0_CODENT} )
	aAdd( aFldNJJ, { 'NJJ_LOJENT', NJ0->NJ0_LOJENT} )
	aAdd( aFldNJJ, { 'NJJ_ENTENT', NJ0->NJ0_CODENT} )
	aAdd( aFldNJJ, { 'NJJ_ENTLOJ', NJ0->NJ0_LOJENT} )
	/*Dados Quantidade*/
	aAdd( aFldNJJ, { 'NJJ_PSSUBT', nQuant 	 } )
	aAdd( aFldNJJ, { 'NJJ_PSBASE', nQuant 	 } )
	aAdd( aFldNJJ, { 'NJJ_PSLIQU', nQuant 	 } )
	aAdd( aFldNJJ, { 'NJJ_PESO3' , nQuant	 } )
	aAdd( aFldNJJ, { 'NJJ_QTDFIS', nQuant	 } )

	/*Dados Pesagem*/
	aAdd( aFldNJJ, { 'NJJ_DATA'  , dDataBase         } )
	aAdd( aFldNJJ, { 'NJJ_DATPS1', dDataBase 		 } )
	aAdd( aFldNJJ, { 'NJJ_HORPS1', Substr(Time(), 1,5) } )
	aAdd( aFldNJJ, { 'NJJ_PESO1' , nQuant  	 } )
	aAdd( aFldNJJ, { 'NJJ_DATPS2', dDataBase 		 } )
	aAdd( aFldNJJ, { 'NJJ_HORPS2', Substr(Time(), 1,5) } )
	/*Dados Fixos*/
	aAdd( aFldNJJ, { 'NJJ_TRSERV', "0" } )
	aAdd( aFldNJJ, { 'NJJ_STSPES', "1" } )
	aAdd( aFldNJJ, { 'NJJ_STATUS', "1" } )
	aAdd( aFldNJJ, { 'NJJ_STSCLA', "1" } )
	aAdd( aFldNJJ, { 'NJJ_STAFIS', "1" } )
	aAdd( aFldNJJ, { 'NJJ_STACTR', "2" } ) 
	aAdd( aFldNJJ, { 'NJJ_TPFRET', "C" } )
	
	/*Integração Romaneio*/
	aAux := {}
	
	aAdd(aAux, {'N9E_CODCTR', NJR->NJR_CODCTR  })
	aAdd(aAux, {'N9E_ITEM'  , N9A->N9A_ITEM    })
	aAdd(aAux, {'N9E_SEQPRI', N9A->N9A_SEQPRI  })
	aAdd(aAux, {'N9E_ORIGEM', '4'          })		
	
	aAdd( aFldN9E, aAux )	

    nValUnit := _aRegraFut[nLinha,17]
		
	// Monta o array da NJM
	If !OG250DCNJM(@nItRom, @aFldNJM, '', '', NJR->NJR_FILIAL, '', NJR->NJR_CODCTR, N9A->N9A_ITEM, N9A->N9A_SEQPRI, nQuant, nQuant, nValUnit, N9A->N9A_CODENT, N9A->N9A_LOJENT, cLocal, __cIdMov, '', '', 1, cSubTipo, cTipoRom, , , aDadosNF)
		Return .F.
	EndIf
			
return .T.

/** {Protheus.doc} fGerMvID()
Função que Gera um registro de movto na tabela de movtos do OG.
@param: 	Tipo do Movto.
@Return:    o id do movto a ser Gerado;
@author: 	Tamyris Ganzenmueller
@since: 	31/01/2018
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fGerMvID( cNKMTpMv)
	//Local cIdMv := ''/
	Local cMsg	:= ''

	oMdlNKM := FWLoadModel( "OGA440" )
	oMdlNKM:SetOperation( MODEL_OPERATION_INSERT )
	oMdlNKM:Activate()
	oNKM:= oMdlNKM:GetModel( "NKMUNICO" )


	lRet:= oNKM:SetValue( "NKM_FILIAL"  ,   fwXfilial("NKM")	)
	lRet:= oNKM:LoadValue( "NKM_TIPOMV"  ,   cNKMTpMv 			)

	If ( lRet:=oMdlNKM:VldData() )
		oMdlNKM:CommitData()
		lContinua := .t.
		cIdMV := FWFLDGET('NKM_IDMOV')   // Identificando o Id do Movto a Ser Gerado
	Else
		cMsg := oMdlNKM:GetErrorMessage()[3] + oMdlNKM:GetErrorMessage()[6]
		Help( ,,STR0009,,cMsg, 1, 0 ) //"Ajuda"
		lContinua := .F.
	EndIf
	oMdlNKM:DeActivate()

Return ( cIdMV )


/*{Protheus.doc} MovFardos
Cria movimento fardos para o romaneio global - Tipo 07 - Em transito
@author Tamyris Ganzenmueller
@since 05/04/2018
@type function */
Static Function MovFardos()
	Local aFardos := {}
	Local aAux    := {}
	Local aFrdSts := {}

	dbSelectArea("N9D") 
	N9D->(dbSetOrder(4)) //N9D_FILORG + N9D_CODCTR + N9D_ITEETG + N9D_ITEREF + N9D_TIPMOV
	If N9D->(dbSeek(N9A->N9A_FILIAL+N9A->N9A_CODCTR+N9A->N9A_ITEM+N9A->N9A_SEQPRI+'02' )) 		
		While !N9D->(Eof()) .AND. N9D->N9D_FILORG + N9D->N9D_CODCTR + N9D->N9D_ITEETG + N9D->N9D_ITEREF + N9D->N9D_TIPMOV + N9D->N9D_STATUS == ;
	                              N9A->N9A_FILIAL + N9A->N9A_CODCTR + N9A->N9A_ITEM   + N9A->N9A_SEQPRI + '02' + '2'
						
			aAux := {{"N9D_FILIAL", N9D->N9D_FILIAL },;
				     {"N9D_SAFRA" , N9D->N9D_SAFRA  },;
				     {"N9D_FARDO" , N9D->N9D_FARDO  },;
					 {"N9D_FILORG", NJJ->NJJ_FILIAL },;
					 {"N9D_CODROM", NJJ->NJJ_CODROM },;
					 {"N9D_ITEROM", NJM->NJM_ITEROM },;
					 {"N9D_TIPMOV", "07"	  },;
					 {"N9D_DATA"  , dDatabase },;
					 {"N9D_STATUS", "2"		  }}
					 
			aAdd( aFardos, aAux )
			
			aAdd( aFrdSts, { N9D->N9D_FILIAL, N9D->N9D_SAFRA, N9D->N9D_FARDO } )
											                          
            N9D->(DbSkip())
		EndDo 
	EndIF 	 
	
	//incluir(1) status do fardo na DXI(DXI_STATUS)
	AGRXFNSF( 1 , "RomaneioFut", aFrdSts ) //romaneio - global futura
	
	//cria movimento do fardo na N9D - romaneio
	aRet := AGRMOVFARD(aFardos, 1)

Return .T.



/*{Protheus.doc} fUPDMARK
//TODO Descrição auto-gerada.
@author rafael.voltz
@since 23/01/2019
@version undefined
@param objBrowser, object, descricao
@type function
*/
static function fUPDMARK(objBrowser, lUpdAll, nLine) //tratamento de refresh	
	Default lUpdAll := .t.
	Default nLine   := 0
	
	_aRegraFut[objBrowser:nAt,1] := IIF(_aRegraFut[objBrowser:nAt,1] == "1", "2", "1")
	
	if lUpdAll
        
		objBrowser:UpdateBrowse() //reconstroi tudo	
		
		if nLine > 0 //posiciona na linha
			objBrowser:GoTo(nLine)
		endif
	else	
		objBrowser:LineRefresh() //só refaz a linha
	endif
	
	objBrowser:GoColumn(1)	
	
return .t.

/*/{Protheus.doc} fAddColumn
    Função para criar as colunas no browse.
    @type  Static Function
    @author user
    @since 09/07/2020
    @version version
    @param cColuna,     char,       Nome da coluna
    @param lEdit,       boolean,    Indica se o campo é editável
    @param bBlocoSet,   block,      Bloco de código do SetDat
    @param aColumns,    array,      Array de referência para adicionar a nova coluna
    @param cF3,         char,       Consulta Padrão
    @param bValid,      block,      Bloco de código de validação do capo
    @return None    
    /*/
Static Function fAddColumn(cColuna,lEdit,bBlocoSet, aColumns,cF3, bValid)                  
    
    Local aPropCampo := TamSX3(cColuna)
    Default cF3      := ""

    //_oBrwMrk:AddColumn( { RetTitle(cColuna) , bBlocoSet, aPropCampo[3],PesqPict(substr(cColuna,1,3),cColuna),1,aPropCampo[1],aPropCampo[2] ,lEdit,,,} )                                    
    AAdd( aColumns,FWBrwColumn():New() )
    aColumns[ Len(aColumns) ]:SetData( bBlocoSet   )
    aColumns[ Len(aColumns) ]:SetType( aPropCampo[3]                        )       
    aColumns[ Len(aColumns) ]:SetTitle( RetTitle(cColuna)                 )
    aColumns[ Len(aColumns) ]:SetSize(aPropCampo[1]                  )
    aColumns[ Len(aColumns) ]:SetDecimal(aPropCampo[2]                   )
    aColumns[ Len(aColumns) ]:SetPicture( PesqPict(substr(cColuna,1,3),cColuna)                  )       
    aColumns[ Len(aColumns) ]:SetEdit(lEdit)
    aColumns[ Len(aColumns) ]:SetF3(cF3)
    aColumns[ Len(aColumns) ]:SetValid(bValid)
    
Return 

/*/{Protheus.doc} fValEsp
    Função para validar a Espécie do documento fiscal que foi digitada.
    @type  Static Function
    @author user
    @since 09/07/2020
    @version version
    @param cConteudo, char, Conteúdo digitado no campo Espécie
    @param nLinha, numeric, Linha corrente    
    /*/
Static Function fValEsp(cConteudo, nLinha)
    
    If !ExistCpo('SX5','42'+cConteudo) 
         _aRegraFut[_oBrwMrk:nAt, nLinha] := SPACE(TamSX3("NJJ_DOCESP")[1])
        Return .F.
    EndIf    
    
Return .T.

/*/{Protheus.doc} fValidSave
    Função para realizar validações ao salvar os dados
    @type  Static Function
    @author user
    @since 09/07/2020
    @version version
    @param None
    @return None
    /*/
Static Function fValidSave()
    Local nLinha   := 0    
    Local lMarcado := .F.
    Local cQuery   := ""
    Local cAlias   := GetNextAlias()
    Local nPsMin   := 0
    
    For nLinha := 1 To len(_aRegraFut)
        If _lAutomato .OR. _aRegraFut[nLinha,1] == "1" 
            lMarcado := .T.
            If !_lFormProp  .AND. ( Empty(_aRegraFut[nLinha,17]) .or. ;
			    Empty(_aRegraFut[nLinha,18]) .or. ;
				Empty(_aRegraFut[nLinha,19]) .or. ;
                Empty(_aRegraFut[nLinha,20]) .or. ;
                Empty(_aRegraFut[nLinha,21]) .or. ;
                Empty(_aRegraFut[nLinha,22]) )
                AgrHelp(STR0031,STR0279 +_aRegraFut[nLinha,3]+"/"+_aRegraFut[nLinha,4], STR0280) //"Não foram infomados todos os dados do documento fiscal para a previsão de entrega/regra fiscal: " //"Quando a emissão não é por formulário próprio deve-se informar o número, série, data e espécie do documento fiscal."
                Return .F.
            EndIf            

            If NJR->NJR_TIPO == "2" .AND. AGRTPALGOD(_aRegraFut[nLinha, 13]) //SE PRODUTO FOR ALGODÃO
                If N9A->(dbSeek( xFilial('N9A')+_aRegraFut[nLinha, 2] + _aRegraFut[nLinha, 3] + _aRegraFut[nLinha, 4]))
                    
                    //Verifica se a quantidade\peso do take-up dos fardos é igual a regra fiscal,
                    //ou se esta dentro da tolerancia quando no contrato for informado tolerancia da entrega                    
                    nPsMin := N9A->N9A_QUANT - (N9A->N9A_QUANT * (NJR->NJR_TOLENT / 100)) //Calcula o peso minimo de take-up para a regra fiscal considerando a tolerancia no contrato
                    If 	N9A->N9A_QTDTKP < nPsMin
                        Help(" ", 1, ".OGA290000004.") //"PROBLEMA: Há itens selecionados que não possuem quantidade de reserva/take-up de fardos suficiente para atender a quantidade do item."
                        Return .F.					   //"SOLUÇÃO: Verifique na regra fiscal do contrato a quantidade da regra fiscal e a quantidade de take-up realizado, e se necessário realizei o take-up até a quantidade da regra fiscal, ou, informe um percentual de tolerância no contrato."	
                    EndIf    
                    
                    //Verifica se todos os fardos das regras fiscais selecionadas estão com preço fixado
                    cQuery := "	    SELECT DXI.DXI_TIPPRE FROM " + RetSqlName("N9D") + " N9D "
                    cQuery += "	INNER JOIN " + RetSqlName("DXI") + " DXI ON DXI_ETIQ = N9D_FARDO "
                    cQuery += "	       AND N9D_FILIAL = DXI_FILIAL "
                    cQuery += "	       AND N9D_SAFRA  = DXI_SAFRA "
                    cQuery += "	       AND DXI.D_E_L_E_T_ = '' "
                    cQuery += "	     WHERE N9D_FILIAL = '" + N9A->N9A_FILORG + "'"
                    cQuery += "	       AND N9D_CODCTR = '" + N9A->N9A_CODCTR + "'"
                    cQuery += "	       AND N9D_ITEETG = '" + N9A->N9A_ITEM + "'"
                    cQuery += "	       AND N9D_TIPMOV = '02' "
                    cQuery += "	       AND N9D_STATUS = '2' "
                    cQuery += "	       AND N9D.D_E_L_E_T_ = '' "

                    cQuery := ChangeQuery(cQuery)
                    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.) 
                    DbselectArea( cAlias)
                    DbGoTop()
                    If (cAlias)->( !Eof() )
                        While (cAlias)->(!EoF())

                            If (cAlias)->(DXI_TIPPRE) <> '1'
                                Help(" ", 1, ".OGA290000003.") //"Problema: Há fardos sem preço fixado."
                                Return .F.                     //"Solução: Verificar precificação dos fardos."
                            EndIf

                            (cAlias)->(dbSkip())
                        EndDo	
                    EndIf
                    (cAlias)->(DbCloseArea())
                EndIf
            EndIf
        EndIf
    Next nLinha

    If !lMarcado
        AgrHelp(STR0031,STR0277,STR0278) //Nenhum registro foi marcado. //"Por favor, marque um ou mais registros para utilizar esta opção."
        Return .F.
    EndIf
    
Return .T.


/*/{Protheus.doc} MarcaTudo
//Rotina para marcar/desmarcar todos os itens.
@author 
@since 23/01/2019
@version undefined
@param oBrwMrk, object, descricao
@param aItsMrk, array, descricao
@param nLinMrk, numeric, descricao
@param lMark, logical, descricao
@param lDir, logical, descricao
@type function
/*/
Static Function MarcaTudo( oBrwMrk, aItsMrk, nLinMrk, lMark, lDir )
	Local nX	 := 0
	
	Default lMark := .T.
	For nX := 1 to Len( aItsMrk )                 

		If aItsMrk[ nX, 1 ] $ "1|2"
			aItsMrk[ nX, 1 ] := If(lMark, "1", "2")
		EndIf
	Next nX

	oBrwMrk:Refresh()
	lMark := !lMark
	
Return
