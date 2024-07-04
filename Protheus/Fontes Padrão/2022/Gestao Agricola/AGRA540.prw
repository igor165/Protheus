#INCLUDE 'TOTVS.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGRA540.CH"

 
/*/{Protheus.doc} AGRA540
//Autorizacao de Carregamento
@author carlos.augusto
@since 20/02/2018
@version 12.1.20
@type function
/*/
Function AGRA540()
	Local oMBrowse := Nil
	
	//-- Proteção de Código
	If .Not. TableInDic('N8N') .OR. .Not. TableInDic('N8O') .OR. .Not. TableInDic('N9D')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "N8N" )
	oMBrowse:SetDescription( STR0001 )	//Autorização de Carregamento
	oMBrowse:DisableDetails()
	oMBrowse:SetMenuDef('AGRA540')
	oMBrowse:Activate()
	
Return()


/*/{Protheus.doc} MenuDef
//Modelo
@author carlos.augusto
@since 20/02/2018
@version 12.1.20
@type function
/*/
Static Function MenuDef()
	Local aRotina 	:= {}

	aAdd( aRotina, { STR0003 	, "PesqBrw"        	, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0004	, "ViewDef.AGRA540"	, 0, 2, 0, .T. } ) //"Visualizar"
	aAdd( aRotina, { STR0005	, "ViewDef.AGRA540"	, 0, 3, 0, .T. } ) //"Incluir"
	aAdd( aRotina, { STR0006	, "ViewDef.AGRA540"	, 0, 4, 0, .T. } ) //"Alterar"
	aAdd( aRotina, { STR0007	, "ViewDef.AGRA540"	, 0, 5, 0, .T. } ) //"Excluir"
Return( aRotina )



/*/{Protheus.doc} ModelDef
//Modelo
@author carlos.augusto
@since 20/02/2018
@version undefined
/*/
Static Function ModelDef()
	Local oStruN8N 		:= FWFormStruct( 1, "N8N" )
	Local oStruN8O 		:= FWFormStruct( 1, "N8O" )
	Local oStruN9D 		:= FWFormStruct( 1, "N9D" )
	Local oStruN8P 		:= FWFormStruct( 1, "N8P" )
	Local oModel 		:= MPFormModel():New( "AGRA540", /*<bPre >*/, {| oModel | PosModelo( oModel ) }, {|oModel| GrvModelo(oModel)}, /*<bCancel >*/ )
	Local bLinePre 		:= { |oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| AGRX540APRE( oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue ) }
	Local bPre	 		:= { |oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| PREVLDN8O( oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue ) }
	
	oStruN8N:AddTrigger( "N8N_QTDAUT", "N8N_QTDSLD", { || .T. }, { | x | FTRGN8NQTD() } )
	oStruN8O:AddTrigger( "N8O_QTD", "N8O_QTD", { || .T. }, { | x | FTRGN8OQTD() } )
	
	oModel:SetDescription( STR0001 )	//"Autorização de Carregamento
	oModel:AddFields( 'AGRA540_N8N', Nil, oStruN8N,/*<bPre >*/,/*< bPost >*/,/*< bLoad >*/)
	oModel:GetModel( 'AGRA540_N8N' ):SetDescription( STR0001 )	//"Autorização de Carregamento

	oModel:AddGrid( "AGRA540_N8O", "AGRA540_N8N", oStruN8O, bLinePre /*bLinePre*/, /*bLinePost*/,bPre /*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:GetModel( "AGRA540_N8O" ):SetDescription( STR0002 )	//"Itens da Autorização de Carregamento
	oModel:GetModel( "AGRA540_N8O" ):SetOptional( .t. )
	
	oModel:AddGrid( "AGRA540_N9D", "AGRA540_N8N", oStruN9D,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bLinePost*/,/*bLoad*/)
	oModel:GetModel( "AGRA540_N9D" ):SetDescription( STR0018 )	//Fardinhos da Autorizacao de Carregamento
	oModel:GetModel( "AGRA540_N9D" ):SetOptional( .t. )
	
	oModel:AddGrid( "AGRA540_N8P", "AGRA540_N8N", oStruN8P,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bLinePost*/,/*bLoad*/)
	oModel:GetModel( "AGRA540_N8P" ):SetDescription( STR0019 )	//Blocos da Autorização de Carregamento  
	oModel:GetModel( "AGRA540_N8P" ):SetOptional( .t. )
	
	oModel:SetRelation( "AGRA540_N8O", { { "N8O_FILIAL", "fwxFilial( 'N8O' )" }, { "N8O_CODAUT", "N8N_CODIGO" } }, N8O->( IndexKey( 1 ) ) )
	//Preciso que nao filtre por item. Deve ser tipo de movimento 10. Autorizacao de carregamento
	
	if  FWSIXUtil():ExistIndex( "N9D" , "7" ) 
		oModel:SetRelation( "AGRA540_N9D", { { "N9D_FILIAL", "fwxFilial( 'N9D' )" }, { "N9D_CODAUT", "N8N_CODIGO" }, { "N9D_TIPMOV", "'10'" }/* ,  { "N9D_ITEMAC", "N8O_ITEM" }*/ }, N9D->( IndexKey( 7 ) ) )
	Endif

	oModel:SetRelation( "AGRA540_N8P", { { "N8P_FILIAL", "fwxFilial( 'N8P' )" }, { "N8P_CODAUT", "N8N_CODIGO" } /*,  { "N9D_ITEMAC", "N8O_ITEM" }*/ }, N8P->( IndexKey( 1 ) ) )//Preciso que nao filtre por item
	
	//-------------------------------------
	// Valida ativacao do modelo
	//-------------------------------------
	oModel:SetVldActivate( { |oModel| AGRA540ACT( oModel ) } )

Return oModel

/*/{Protheus.doc} ViewDef
//View
@author carlos.augusto
@since 20/02/2018
@version 12.1.20
@type function
/*/
Static Function ViewDef()
	Local oStruN8N	:= FWFormStruct( 2, 'N8N' )
	Local oStruN8O	:= FWFormStruct( 2, 'N8O' )
	Local oModel  	:= FWLoadModel( 'AGRA540' )
	Local oView   	:= FWFormView():New()

	// Define qual Modelo de dados será utilizado
	oView:SetModel( oModel )

	oStruN8N:RemoveField("N8N_CODUSU")
	oStruN8N:RemoveField("N8N_DTTRAN")
	
	oStruN8O:RemoveField("N8O_CODAUT")
	oStruN8O:RemoveField("N8O_QTDFAR")
	oStruN8O:RemoveField("N8O_QTDBLC")

	// Declarando Objetos da Parte Superior
	oView:AddField( 'AGRA540_N8N', oStruN8N, 'AGRA540_N8N' )
	oView:AddGrid(  'AGRA540_N8O', oStruN8O, 'AGRA540_N8O' , /*uParam4 */, /*< bGotFocus >*/)

	oView:AddIncrementField( "AGRA540_N8O", "N8O_ITEM" )

	// Sao duas boxes. Inferior e Superior
	oView:CreateHorizontalBox( 'SUPERIOR', 35 )
	oView:CreateHorizontalBox( 'INFERIOR', 65 )

	// Uma caixa vertical para tudo
	oView:CreateVerticalBox( 'BOX_VERT', 100, 'INFERIOR'  )

	// O Box inferior vai ocupar tudo
	oView:CreateHorizontalBox( 'BOX_INF', 100, 'BOX_VERT' )	//Direito Inferior

	oView:SetOwnerView( "AGRA540_N8N" , "SUPERIOR" )
	oView:SetOwnerView( "AGRA540_N8O" , "BOX_INF" )

	oView:EnableTitleView( "AGRA540_N8N" )
	oView:EnableTitleView( "AGRA540_N8O" )

	oView:SetCloseOnOk( {||.T.} )
	
	oView:AddUserButton( STR0016, '', {|| AGRX540AVF()} ) //"Vincular Fardos"
	oView:AddUserButton( STR0017, '', {|| AGRX540BVB()} ) //"Vincular Blocos"  
	
Return oView


/*/{Protheus.doc} AGRA540ACT
//Valida operacoes na Autorizacao de Carregamento posicionada
@author carlos.augusto
@since 21/02/2018
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function AGRA540ACT(oModel)
	Local lRet		:= .T.
	
	//Se status da autorização for igual a 3 - Atendida, deve ser permitida apenas sua consulta
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		If N8N->N8N_STATUS == "3"
			lRet := .F.
			//"Autorização de Carregamento com Status Atendida." - "Selecione uma Autorização de Carregamento com Status diferente de Atendida para ser alterada."
			oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0008, STR0009, "", "")
		EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} PosModelo
//Valida operacoes na Autorizacao de Carregamento posicionada
@author carlos.augusto
@since 21/02/2018
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function PosModelo(oModel)
	Local lRet	     := .T.
	Local aArea      := GetArea()
	Local oMldN8N    := oModel:GetModel('AGRA540_N8N')
	Local oMldN8O    := oModel:GetModel('AGRA540_N8O')
	Local cTitIteReg := AllTrim(RetTitle("N8O_IDENTR")) //"Id Entrega"
	Local cTitCodine := AllTrim(RetTitle("N8O_CODINE")) //"Instr. Emb."
	Local cTitIteN8O := AllTrim(RetTitle("N8O_ITEM"))   //"Cód. Item."
	Local cTitCtrN8O := AllTrim(RetTitle("N8O_CODCTR")) //"Contrato"
	Local cTitIdRegr := AllTrim(RetTitle("N8O_IDREGR")) //"Id Regra"
	Local nX         := 0
	Local cDescIE    := ""
	Local cCodIt     := ""
	
	//Se status da autorização for igual a 3 - Atendida, deve ser permitida apenas sua consulta
	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		If N8N->N8N_STATUS != "1"
			lRet := .F.
			//"Não é possível realizar a exclusão da Autorização de Carregamento." - "Selecione uma Autorização de Carregamento com Status Pendente." 
			oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0010, STR0011, "", "")
		EndIf
	EndIf

		//Se Entrada, nao pode ter IE e a operação não for exclusão
	If oMldN8N:GetValue( "N8N_TIPO" ) = "2"  .And. oModel:GetOperation() <> MODEL_OPERATION_DELETE
		For nX := 1 To oMldN8O:Length()
			oMldN8O:GoLine( nX )
			If .Not. oMldN8O:IsDeleted() .And. .Not. Empty(oMldN8O:GetValue( "N8O_CODINE" )) .And. Empty(oMldN8O:GetValue( "N8O_IDENTR" ))
				cDescIE := AllTrim(Posicione("N7Q", 1, FwXfilial("N7Q")+oMldN8O:GetValue( "N8O_CODINE" ), "N7Q_DESINE"))
				cCodIt  := AllTrim(oMldN8O:GetValue( "N8O_ITEM" ))
				
				HELP(' ',1,cTitIteReg,,cTitIteReg+STR0022+cTitCodine+": "+cDescIE+", "+cTitIteN8O+": "+cCodIt+".",2,0,,,,,, {STR0023+cTitIteReg+", "+cTitCtrN8O+STR0024+cTitIdRegr+STR0025+cTitCodine+"."})
				Return .F.//"Id Entrega" ### "Id Entrega" ### " não imformado para a " ### "Instr. Emb.:" ###  "Cód. Item." ### "Os campos " ### "Id Entrega" ### "Contrato" ### " e " ### "Id Regra" ### " são obrigatórios quando informada uma " ### "Instrução Embarque" 
			EndIf
		Next nX
	EndIf

	RestArea(aArea)
Return lRet



/*/{Protheus.doc} GrvModelo
//GrvModelo
@author carlos.augusto
@since 21/02/2018
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function GrvModelo(oModel)
	Local lRet    		:= .T.
	Local oMldN8N 		:= oModel:GetModel('AGRA540_N8N')
	Local oMldN8O 		:= oModel:GetModel('AGRA540_N8O')
	Local oMldN9D 		:= oModel:GetModel('AGRA540_N9D')
	Local oMldN8P 		:= oModel:GetModel('AGRA540_N8P')
	Local nOperation	:= oModel:GetOperation()
	Local nX			:= 0
	Local nQtdN8N		:= 0
	Local nQtdN8O		:= 0
	Local aBlocos		:= {}
	Local aItemAut		:= {}
	Local cCodIE		:= ""

	//Se Entrada, nao pode ter IE
	If oMldN8N:GetValue( "N8N_TIPO" ) = "1" 
		For nX := 1 to oMldN8O:Length()
			oMldN8O:GoLine( nX )
			If .Not. oMldN8O:IsDeleted() .And. .Not. Empty(oMldN8O:GetValue( "N8O_CODINE" ))
				lRet := .F.
				//"A Autorização de Carregamento possui Instrução de Embarque." - "Favor alterar o Tipo da Autorização de Carregamento para '2-Saída' ou remover Instruções de Embarque."
				oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0012, STR0013, "", "")
			EndIf
		Next nX
	EndIf				
	
	//Quantidade Autorizada deve ser <= soma das quantidades dos itens
	If lRet .And. oMldN8N:GetValue( "N8N_TIPO" ) = "2"
		nQtdN8N := oMldN8N:GetValue( "N8N_QTDAUT" )
		For nX := 1 to oMldN8O:Length()
			oMldN8O:GoLine( nX )
			If .Not. oMldN8O:IsDeleted() //.And. .Not. Empty(oMldN8O:GetValue( "N8O_CODINE" ))
				nQtdN8O += oMldN8O:GetValue( "N8O_QTD" )
			EndIf
		Next nX
		If nQtdN8O > nQtdN8N
			lRet := .F.
			//"A quantidade da Autorização de Carregamento não pode ser menor do que a soma dos seus itens." - "Favor realizar a manutenção das Instruções de Embarque."
			oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0014, STR0015, "", "")
		EndIf
	EndIf	
	
	//Valida se a quantidade Autorizada eh maior do que a quantidade da IE
	For nX := 1 to oMldN8O:Length()
		oMldN8O:GoLine( nX )
		If .Not. oMldN8O:IsDeleted() .And. .Not. Empty(oMldN8O:GetValue( "N8O_CODINE" ))
			If A540QTDSLD( .F. ) < 0  //Saldo tem que ser maior que zero
				//#"A quantidade informada é superior ao peso líquido de saldo da Instrução de Embarque."
				//#"Verifique o peso da Instrução de Embarque autorizado na linha: "
				oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0020, STR0021 + cValToChar(nX), "", "")
				lRet := .F.
			EndIf
			
			If lRet
				Aadd(aItemAut, {oMldN8O:GetValue("N8O_FILIAL")+oMldN8O:GetValue("N8O_CODAUT")+oMldN8O:GetValue("N8O_ITEM"), oMldN8O:GetValue("N8O_CODINE")})
			EndIf
			
			//Se for necessario validar futuramente diretamente na N7S, usar a logica abaixo =)
			/*N7S_FILIAL+N7S_CODINE+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI                                                                                                            
			DbSelectArea( "N7S" )
			N7S->(DbSetOrder(1))
			If MsSeek( FwxFilial( "N7S" ) + oMldN8O:GetValue( "N8O_CODINE" ) + oMldN8O:GetValue( "N8O_CODCTR" ) + ;
					   oMldN8O:GetValue( "N8O_IDENTR" ) + oMldN8O:GetValue( "N8O_IDREGR" ) )
				If N7S->N7S_QTDDCD < oMldN8O:GetValue( "N8O_QTD" )
					lRet := .F.
					//A quantidade informada é superior ao peso líquido  da Instrução de Embarque. Verifique o peso da Instrução de Embarque.
					Help('' ,1,".AGRA54000001.", , ,1,0)
				EndIf
			EndIf */
					
		EndIf
	Next nX
	
	If lRet .And. nOperation == MODEL_OPERATION_INSERT
		oMldN8N:SetValue( "N8N_CODUSU" , RetCodUsr())
		oMldN8N:SetValue( "N8N_DTTRAN", dDataBase)
	EndIf
	
	If lRet .AND. nOperation != MODEL_OPERATION_DELETE
		AGRA540AQA()
	EndIf
	
	If lRet .AND. (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE .OR.; 
				   nOperation == MODEL_OPERATION_DELETE)
		
		For nX := 1 to oMldN9D:Length()	
			oMldN9D:GoLine(nX)
			
			If ((nOperation == MODEL_OPERATION_INSERT .AND. !oMldN9D:IsDeleted()) .OR.; 
			    nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_DELETE) .AND.;
			    !Empty(oMldN9D:GetValue("N9D_FARDO"))
				
				DbSelectArea("DXI")
				DXI->(DbSetOrder(1)) //DXI_FILIAL+DXI_SAFRA+DXI_ETIQ
				If DXI->(DbSeek(oMldN9D:GetValue("N9D_FILIAL")+oMldN9D:GetValue("N9D_SAFRA")+oMldN9D:GetValue("N9D_FARDO")))					
					If RecLock("DXI", .F.)
						DXI->DXI_DATATU := dDatabase
						DXI->DXI_HORATU := Time()
						DXI->(MsUnlock())
					EndIf					
				EndIf
				
				If AScan(aBlocos, oMldN9D:GetValue("N9D_FILIAL")+oMldN9D:GetValue("N9D_SAFRA")+oMldN9D:GetValue("N9D_BLOCO")) == 0
					Aadd(aBlocos, oMldN9D:GetValue("N9D_FILIAL")+oMldN9D:GetValue("N9D_SAFRA")+oMldN9D:GetValue("N9D_BLOCO"))
				EndIf
				
			EndIf
					
		Next nX
		
		For nX := 1 to oMldN8P:Length()			
			oMldN8P:GoLine(nX)
			
			If ((nOperation == MODEL_OPERATION_INSERT .AND. !oMldN9D:IsDeleted()) .OR.; 
			    nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_DELETE) .AND.;
			    !Empty(oMldN8P:GetValue("N8P_BLOCO")) .AND. oMldN8P:GetValue("N8P_QTDAUT") > 0
			    
			    nPosIE := AScan(aItemAut, {|x| AllTrim(x[1]) == AllTrim(oMldN8P:GetValue("N8P_FILIAL")+oMldN8P:GetValue("N8P_CODAUT")+oMldN8P:GetValue("N8P_ITEMAC"))})
			    
			    cCodIE := aItemAut[nPosIE][2]
			    
			    DbSelectArea("DXI")
				DXI->(DbSetOrder(4)) //DXI_FILIAL+DXI_SAFRA+DXI_BLOCO
				If DXI->(DbSeek(oMldN8P:GetValue("N8P_FILORG")+oMldN8P:GetValue("N8P_SAFRA")+oMldN8P:GetValue("N8P_BLOCO")))				
					While DXI->(!Eof()) .AND.;
						  DXI->DXI_FILIAL+DXI->DXI_SAFRA+DXI->DXI_BLOCO == oMldN8P:GetValue("N8P_FILORG")+oMldN8P:GetValue("N8P_SAFRA")+oMldN8P:GetValue("N8P_BLOCO")
						
						If !AllTrim(DXI->DXI_STATUS) $ "70|80|90|100" .OR. (!Empty(AllTrim(DXI->DXI_CODINE)) .AND. DXI->DXI_CODINE != cCodIE)
							DXI->(DbSkip())
							LOOP
						EndIf
										
						If RecLock("DXI", .F.)
							DXI->DXI_DATATU := dDatabase
							DXI->DXI_HORATU := Time()
							DXI->(MsUnlock())
						EndIf
						
						DXI->(DbSkip())
					EndDo					
				EndIf
			    
			    If AScan(aBlocos, oMldN8P:GetValue("N8P_FILORG")+oMldN8P:GetValue("N8P_SAFRA")+oMldN8P:GetValue("N8P_BLOCO")) == 0
					Aadd(aBlocos, oMldN8P:GetValue("N8P_FILORG")+oMldN8P:GetValue("N8P_SAFRA")+oMldN8P:GetValue("N8P_BLOCO"))
				EndIf
			    
			EndIf
			
		Next nX
		
		For nX := 1 to Len(aBlocos)
			
			DbSelectArea("DXD")
			DXD->(DbSetOrder(1)) //DXD_FILIAL+DXD_SAFRA+DXD_CODIGO
			If DXD->(DbSeek(aBlocos[nX]))					
				If RecLock("DXD", .F.)
					DXD->DXD_DATATU := dDatabase
					DXD->DXD_HORATU := Time()
					DXD->(MsUnlock())
				EndIf					
			EndIf
			
		Next nX
	EndIf
	
	If lRet
		lRet := FWFormCommit( oModel )
	EndIF
	
Return lRet

Static Function PREVLDN8O(oMldN8O, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local lRet 		:= .T.
	Local oModel	:= FwModelActive()
	Local oStrN8N	:= oModel:GetModel( "AGRA540_N8N" )
	Local nValor	:= 0
	
	If cAction == "DELETE" 
		nValor := oStrN8N:GetValue("N8N_QTDAUT") - oMldN8O:GetValue("N8O_QTD")
		oStrN8N:LoadValue("N8N_QTDAUT",nValor)
		oStrN8N:LoadValue("N8N_QTDSLD",FTRGN8NQTD()) //para atualizar saldo N8N, qdo autorização tipo saida, campo N8N_QTDAUT esta bloqueado, então setvalue e gatilho não funciona
	ElseIf cAction == "UNDELETE" 
		nValor := oStrN8N:GetValue("N8N_QTDAUT") + oMldN8O:GetValue("N8O_QTD")
		oStrN8N:LoadValue("N8N_QTDAUT",nValor)
		oStrN8N:LoadValue("N8N_QTDSLD",FTRGN8NQTD()) //para atualizar saldo N8N, qdo autorização tipo saida, campo N8N_QTDAUT esta bloqueado, então setvalue e gatilho não funciona
	EndIf

Return lRet

/*/{Protheus.doc} FTRGN8NQTD
//TODO Triger campo N8N_QTDAUT para calcular o valor para o campo N8N_QTDSLD
@author claudineia.reinert
@since 04/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function FTRGN8NQTD() 
	Local oModel	:= FwModelActive()
	Local oStrN8N	:= oModel:GetModel( "AGRA540_N8N" )
	Local nRetorno	:= 0

	nRetorno := oStrN8N:GetValue("N8N_QTDAUT") - oStrN8N:GetValue("N8N_QTDAGD")
	
Return nRetorno

/*/{Protheus.doc} FTRGN8OQTD
//TODO Triger campo N8O_QTD para calcular o valor para o campo N8N_QTDAUT
@author claudineia.reinert
@since 04/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function FTRGN8OQTD()
	
	AGRA540AQA()

Return .T.


/*/{Protheus.doc} AGRA540AQA
//TODO Atualiza campo N8N_QTDAUT e N8N_QTDSLD para tipo autorização 2-Saida
@author claudineia.reinert
@since 04/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AGRA540AQA()
	Local oModel	:= FwModelActive()
	Local oStrN8N	:= oModel:GetModel('AGRA540_N8N')
	Local oStrN8O	:= oModel:GetModel('AGRA540_N8O')
	Local nTotal	:= 0
	Local nLinha	:= 0
	Local nX	:= 0
	
	If oStrN8N:GetValue("N8N_TIPO") == "2" //2 - saida
		nLinha := oStrN8O:GetLine()
		For nX := 1 to oStrN8O:Length()
			oStrN8O:GoLine( nX )
			If .Not. oStrN8O:IsDeleted()
				nTotal += oStrN8O:GetValue( "N8O_QTD" )
			EndIf
		Next nX
		oStrN8O:GoLine( nLinha )
		oStrN8N:LoadValue("N8N_QTDAUT",nTotal)
		oStrN8N:LoadValue("N8N_QTDSLD",FTRGN8NQTD()) //para atualizar saldo N8N, qdo autorização tipo saida, campo N8N_QTDAUT esta bloqueado, então setvalue e gatilho não funciona
	EndIf

Return .T.
/*/{Protheus.doc} AGRA540IDE
//Ao alterar o ID de Entrega, os campos subsequentes serao limpados ou gatilhados 
@author carlos.augusto
@since 28/02/2018
@version undefined
@type function
/*/
Function AGRA540IDE() 
	Local lRet 		:= .F.
	Local oModel	:= FwModelActive()
	Local oMldN8O 	:= oModel:GetModel('AGRA540_N8O')
	Local aArea 	:= GetArea()

	DbSelectArea("N7S")
	N7S->(DbSetOrder(1))
	If MsSeek( FwxFilial( "N7S" ) + FwFldGet("N8O_CODINE") )
		While N7S->(!Eof()) .AND. N7S->N7S_FILIAL == FwxFilial( "N7S" ) .And. N7S->N7S_CODINE == FwFldGet("N8O_CODINE")
			If N7S->N7S_ITEM == FwFldGet("N8O_IDENTR")
				lRet := .T.
				exit
			EndIf
			N7S->(dbSkip())
		EndDo
	EndIf	

	If lRet
		//OGA710SCad(N7S->N7S_CODCTR,N7S->N7S_ITEM,N7S->N7S_SEQPRI,.T.)
		oMldN8O:LoadValue( "N8O_QTATEN", N7S->N7S_QTDVIN)
		oMldN8O:LoadValue( "N8O_QTDSLD", N7S->N7S_QTDVIN)
		A540QTDSLD()  //Atualiza o Saldo do campo N8O_QTDSLD
		oMldN8O:LoadValue( "N8O_ENTDES", Posicione("N7Q",1,FwXfilial("N7Q") + FwFldGet("N8O_CODINE"),"N7Q_ENTENT"))
		oMldN8O:LoadValue( "N8O_LOJDES", Posicione("N7Q",1,FwXfilial("N7Q") + FwFldGet("N8O_CODINE"),"N7Q_LOJENT"))
		oMldN8O:LoadValue( "N8O_NOMDES", Posicione("NJ0",1,FwXfilial("NJ0") + FwFldGet("N8O_ENTDES")+FwFldGet("N8O_LOJDES"),"NJ0_NOME"))
	Else
		AGRA540CLN()
	EndIf
	RestArea(aArea)
	
Return lRet


/*/{Protheus.doc} AGRA540CLN
//Limpa os campos N8O
@author carlos.augusto
@since 28/02/2018
@version undefined

@type function
/*/
Function AGRA540CLN()
	Local oModel	:= FwModelActive()
	Local oMldN8O 	:= oModel:GetModel('AGRA540_N8O')
	
	oMldN8O:LoadValue("N8O_IDENTR", Space(TamSX3("N8O_IDENTR")[1]))
	oMldN8O:LoadValue("N8O_CODCTR", Space(TamSX3("N8O_CODCTR")[1]))
	oMldN8O:LoadValue("N8O_IDREGR", Space(TamSX3("N8O_IDREGR")[1]))
	oMldN8O:LoadValue("N8O_FILORI", Space(TamSX3("N8O_FILORI")[1]))
	oMldN8O:LoadValue("N8O_NMFILO", Space(TamSX3("N8O_NMFILO")[1]))
	oMldN8O:LoadValue("N8O_ENTDES", Space(TamSX3("N8O_ENTDES")[1]))
	oMldN8O:LoadValue("N8O_LOJDES", Space(TamSX3("N8O_LOJDES")[1]))
	oMldN8O:LoadValue("N8O_NOMDES", Space(TamSX3("N8O_NOMDES")[1]))
	oMldN8O:SetValue("N8O_QTD", 	0) //setValue para gatilho do campo
	oMldN8O:LoadValue("N8O_QTATEN", 0)
	oMldN8O:LoadValue("N8O_QTDSLD", 0)

Return .T.                                                                                                       


/*/{Protheus.doc} AGRA540ITM
//Deleta todos fardos e blocos ao alterar a Instrucao de Embarque na tela principal
@author carlos.augusto
@since 26/02/2018
@version undefined
@type function
/*/
Function AGRA540AIT()
	Local oModel	:= FwModelActive()
	Local oMldN8O 	:= oModel:GetModel('AGRA540_N8O') //Itens da Autorizacao
	Local oMldN9D 	:= oModel:GetModel('AGRA540_N9D') //Fardos da Autorizacao
	Local oMldN8P 	:= oModel:GetModel('AGRA540_N8P') //Blocos da Autorizacao
	Local nX

	If .Not. Empty(oMldN8O:GetValue("N8O_CODINE")) .And. ExistCpo("N7Q")
		For nX := 1 to oMldN9D:Length()
			oMldN9D:GoLine( nX )
			If .Not. oMldN9D:IsDeleted()
				If oMldN9D:GetValue("N9D_ITEMAC")== oMldN8O:GetValue("N8O_ITEM")
					oMldN9D:DeleteLine()
				EndIf
			EndIf
		Next nX 
		For nX := 1 to oMldN8P:Length()
			oMldN8P:GoLine(nX)
			If .Not. oMldN8P:IsDeleted() .And. (oMldN8O:GetValue( "N8O_ITEM" ) == oMldN8P:GetValue( "N8P_ITEMAC" ))
				oMldN8P:LoadValue("N8P_DATATU" ,  dDatabase)
				oMldN8P:LoadValue("N8P_HORATU" ,  Time()   )			
				oMldN8P:DeleteLine()
			EndIf
		Next nX
		AGRA540CLN()
	ElseIf Empty(oMldN8O:GetValue("N8O_CODINE"))
		AGRA540CLN()
	EndIf
Return .T.


/*/{Protheus.doc} AGRA540VLD
//Preciso deixar o campo habilitado por causa do setvalue de gatilho.
//Ou seja, sem IE, estes campos estarao habilitados mas nao poderao ser alterados.
//Se Empty(FwFldGet("N8O_CODINE"), existira campos que nao poderao ser preenchidos. Neste caso, retorno falso.
//Mas terao campos que poderao ter valores. Neste caso, executo valid adequado, sem dados da IE 
@author carlos.augusto
@since 28/02/2018
@version undefined
@type function
/*/
Function AGRA540VLD()
	Local lRet := .T.
	Local aArea 	:= GetArea()
	
	Do Case

		Case "N8O_CODCTR" $ ReadVar()
			If .Not. Empty(FwFldGet("N8O_CODINE")) 
				lRet := ExistCpo("N7S", FwFldGet("N8O_CODINE") + FwFldGet("N8O_CODCTR") + FwFldGet("N8O_IDENTR"), 1)
			Else
				lRet := .F.
			EndIf

		Case "N8O_IDREGR" $ ReadVar()
			If .Not. Empty(FwFldGet("N8O_CODINE"))
				lRet := ExistCpo("N7S", FwFldGet("N8O_CODINE") + FwFldGet("N8O_CODCTR") + FwFldGet("N8O_IDENTR") + FwFldGet("N8O_IDREGR"), 1)
			Else
				lRet := .F.
			EndIf

		Case "N8O_QTDSLD" $ ReadVar()
			/*If .Not. Empty(FwFldGet("N8O_CODINE"))
				lRet := FwFldGet("N8O_QTDSLD") == OGA710SCad(N7S->N7S_CODCTR,N7S->N7S_ITEM,N7S->N7S_SEQPRI,.T.)
			Else
				lRet := .F.
			EndIf*/

		Case "N8O_QTATEN" $ ReadVar()
			If IsInCallStack('AGRA540')
				If .Not. Empty(FwFldGet("N8O_CODINE"))
					lRet := FwFldGet("N8O_QTATEN") == Posicione("N7S",1,FwXfilial("N7S") + FwFldGet("N8O_CODINE") + ;
					FwFldGet("N8O_CODCTR") + FwFldGet("N8O_IDENTR") + FwFldGet("N8O_IDREGR"),"N7S_QTDVIN")
				Else
					lRet := .F.
				EndIf
			EndIf	

		Case "N8O_FILORI" $ ReadVar()
			If .Not. Empty(FwFldGet("N8O_CODINE"))
				lRet := FwFldGet("N8O_FILORI") == Posicione("N7S",1,FwXfilial("N7S") + FwFldGet("N8O_CODINE") +;
				FwFldGet("N8O_CODCTR") + FwFldGet("N8O_IDENTR") + FwFldGet("N8O_IDREGR"),"N7S_FILORG")
			Else
				lRet := ExistCpo("SM0",cEmpAnt + FwFldGet("N8O_FILORI"))
			EndIf

		Case "N8O_ENTDES" $ ReadVar()
			If .Not. Empty(FwFldGet("N8O_CODINE"))
				lRet := FwFldGet("N8O_ENTDES") == Posicione("N7Q",1,FwXfilial("N7Q") + FwFldGet("N8O_CODINE"),"N7Q_ENTENT")
			Else
				lRet := ExistCpo("NJ0", FwFldGet("N8O_ENTDES"),1) 
			EndIf

		Case "N8O_LOJDES" $ ReadVar()
			If .Not. Empty(FwFldGet("N8O_CODINE"))
				lRet := FwFldGet("N8O_LOJDES") == Posicione("N7Q",1,FwXfilial("N7Q") + FwFldGet("N8O_CODINE"),"N7Q_LOJENT")
			Else
				lRet := ExistCpo("NJ0",FwFldGet("N8O_ENTDES")+FwFldGet("N8O_LOJDES"))
			EndIf
	EndCase
	RestArea(aArea)			
Return lRet


/*/{Protheus.doc} A540WhCC
Filtro da consulta CN9N8N
@author silvana.torres
@since 13/09/2018
@version undefined

@type function
/*/
Function A540WhCC()

	Local cWhere	:= ""
	
	cWhere := "@D_E_L_E_T_ = ' ' AND 									"
	cWhere += "	CN9_SITUAC  = '05'AND							  		"
	cWhere += " CN9_SALDO   > 0   AND							  		"
	cWhere += " CN9_TPCTO  IN (SELECT CN1.CN1_CODIGO					"
	cWhere += " 			     FROM " + RetSqlName("CN1") + " CN1		"
	cWhere += "					WHERE CN1.CN1_ESPCTR = '1')	AND			"
	cWhere += " CN9_NUMERO IN (SELECT CNA.CNA_CONTRA 					"  
	cWhere += "	    			 FROM " + RetSqlName("CNA") + " CNA 	" 
	cWhere += "			   INNER JOIN " + RetSqlName("CNB") + " CNB		"
	cWhere += "	 			       ON CNB.CNB_FILIAL = CNA.CNA_FILIAL 	"
	cWhere += "   				  AND CNB.CNB_CONTRA = CNA.CNA_CONTRA 	"
	cWhere += "					  AND CNB.D_E_L_E_T_ = ' '				"
	cWhere += " 		   INNER JOIN " + RetSqlName("CNL") + " CNL		"
	cWhere += "					   ON CNL.CNL_FILIAL = CNA.CNA_FILIAL 	"
	cWhere += " 				  AND CNL.CNL_CODIGO = CNA.CNA_TIPPLA 	"
	cWhere += "					  AND CNL.D_E_L_E_T_ = ' '				"
	cWhere += "  	 	   INNER JOIN " + RetSqlName("SB5") + " SB5		"
	cWhere += " 			       ON SB5.B5_COD     = CNB.CNB_PRODUT 	"
	cWhere += "					  AND SB5.D_E_L_E_T_ = ' '				"
	cWhere += "	 			    WHERE CNA.CNA_FILIAL = CN9_FILIAL		"
	cWhere += "					  AND CNL.CNL_PLSERV = '1'			  	"
	cWhere += "					  AND SB5.B5_TIPO    = '2'  )  	  		"
	
Return cWhere


/*/{Protheus.doc} OGA700N92V
// Responsável por validar 
@author brunosilva
@since 26/02/2019
@version 1.0
@param cToEtap, characters, descricao
@type function
/*/
Function AGRA540FPR(pToEtap)
	Local cFiltro   := "@ D_E_L_E_T_ = ' ' "
	Local oModel	:= FwModelActive()
	Local oModelN8N	:= oModel:GetModel( "AGRA540_N8N" )
	Local cFilSql   := fwxFilial()
	Local cToEtap	:= oModelN8N:GetValue("N8N_TOETAP")
	Local cOper     := oModel:GetOperation() // MODEL_OPERATION_UPDATE

	Local sCount    := " COUNT(*) RES "
	Local sCampo    := " NCB_CODPRO "
	Local cSqlNCB   := ""

	Default pToEtap := ""

	If cOper == MODEL_OPERATION_UPDATE
		cFilSql := oModelN8N:GetValue("N8N_FILIAL")
	EndiF

	cSqlNCB   := "FROM " + RetSqlName("NCB") + " NCB " + ;
				 "WHERE NCB_FILIAL = '" + cFilSql + "' " + ;
				 "AND NCB_CODTO = '" + cToEtap + "' " + ;
				 "AND NCB.D_E_L_E_T_ = ' ' "

	If !(Empty(GetDataSql( "SELECT " + sCount + cSqlNCB )))  //Se existe produto vinculado ao N8N_TOETAP

		cFiltro += "AND B1_COD IN (" +  "SELECT " + sCampo + cSqlNCB  + ") "
	EndIf
	
return cFiltro

Function A540QTDSLD( lAltera)
	Local oModel	:= FwModelActive()
	Local oMldN8N 	:= oModel:GetModel('AGRA540_N8N')
	Local oMldN8O 	:= oModel:GetModel('AGRA540_N8O')

	Local cCodAut   := oMldN8N:GetValue( "N8N_CODIGO")

	Local cCodIne   := oMldN8O:GetValue( "N8O_CODINE")
	Local cIdEntr   := oMldN8O:GetValue( "N8O_IDENTR")
	Local cCodCtr   := oMldN8O:GetValue( "N8O_CODCTR")
	Local cIdRegr   := oMldN8O:GetValue( "N8O_IDREGR") 

	Local nSaldo	:= 0
	Local nSumQtd   := 0
	Local nQtdAten  := 0
	Local nX        := 0

	Default lAltera := .T.

	If !Empty( cCodIne ) .AND. ;
	   !Empty( cIdEntr ) .AND. ;
	   !Empty( cCodCtr ) .AND. ;
	   !Empty( cIdRegr )

		nQtdAten := GetDataSql("SELECT N7S_QTDVIN " + ;
							"FROM " + RetSqlName("N7S")+ " N7S " + ;
							"WHERE N7S_CODINE = '" + cCodIne + "' " + ;
							  "AND N7S_ITEM   = '" + cIdEntr + "' " + ;
							  "AND N7S_CODCTR = '" + cCodCTR + "'  " + ;
							  "AND N7S_SEQPRI = '" + cIdRegr + "' " + ;
							  "AND D_E_L_E_T_ = ' ' ")	
		
		nSumQtd := GetDataSql("SELECT SUM(N8O_QTD) QTD " + ;
							"FROM " + RetSqlName("N8O") + " N8O " + ;
							"WHERE 1=1 " + ;
							"AND N8O_CODINE = '" + cCodIne + "' " +;
							"AND N8O_IDENTR = '" + cIdEntr + "' " + ;
							"AND N8O_CODCTR = '" + cCodCTR + "' " +;
							"AND N8O_IDREGR = '" + cIdRegr + "' " +;
							"AND N8O_CODAUT <> '" + cCodAut + "' " +;
							"AND D_E_L_E_T_ = ' '" )

		nLineAt := oMldN8O:GetLine()
		For nX := 1 to oMldN8O:Length()
			oMldN8O:GoLine(nX)
			If nX == nLineAt .OR. oMldN8O:IsDeleted()
				Loop
			EndIf
			If (oMldN8O:GetValue( "N8O_CODCTR") == cCodCTR) .AND. (oMldN8O:GetValue( "N8O_IDREGR") == cIdRegr)
				nSumQtd := nSumQtd + oMldN8O:GetValue( "N8O_QTD")
			EndIf?
		Next nX
		
		oMldN8O:GoLine(nLineAt) 
		nSaldo := nQtdAten - nSumQtd -  oMldN8O:GetValue( "N8O_QTD")
		oMldN8O:LoadValue( "N8O_QTDSLD", nSaldo)
	Else
		oMldN8O:LoadValue( "N8O_QTDSLD", nSaldo)
	EndIf
Return nSaldo

Function A540VLQTd()
	Local lRet    := .F.
	Local nSaldoAnt := A540QTDSLD( .F. )

	lRet := nSaldoAnt  >= 0

Return lRet
