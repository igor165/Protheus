#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA580D.CH"
#INCLUDE "DBTREE.CH"

#DEFINE NTAM_COD_INT  2

Static oTree	:= Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580Cons

Função para  para consulta especifica, que mostra os registros conforme o alias escolhido pelo usuario e
guarda o x2 unico do registro na variavel estatica 'cChvReg'

@sample		CRMA580Cons()
 
@param		Nenhum

@return	ExpL - Verdadeiro / Falso

@author	Jonatas Martins
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580Cons()

Local lRetorno  := .F.
Local cAlias    :=  ""
Local aDadSX2   := {}
Local oModel    := FwModelActive()
Local oMdlAOL	:= oModel:GetModel("AOLMASTER")
Local aAreaSXB	:= SXB->(GetArea())

//variavel de retorno para consulta especifica
Static _cChvReg := ""
 
If oModel <> Nil .And. oModel:cId == "CRMA580B"

	cAlias	:= oMdlAOL:GetValue("AOL_ENTIDA")

	SXB->(DbSetOrder(1))
	If SXB->(DbSeek(PadR(cAlias,6)))
		If Conpad1(,,,cAlias)
			aDadSX2  := CRMXGetSX2(cAlias)
			If Len(aDadSX2) > 0
				_cChvReg := (cAlias)->&(aDadSX2[1])
				lRetorno := .T.
			EndIf
		EndIf
	Else
		MsgAlert(STR0001) //"Não há consulta padrão para entidade do agrupador."
	EndIf

Else
	MsgAlert(STR0002)//"O Agrupadores de registro não está ativo!"
EndIf

RestArea(aAreaSXB)

Return(lRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580RChv

Função para retornar o valor da variavel 'cChvReg' obtido na consulta padrão (especifica) CRMA580Cons.

@sample	CRMA580RChv()

@param		Nenhum

@return	_cChvReg - Chave do Registro

@author	Jonatas Martins
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580RChv()
Return (_cChvReg)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM580Tree

Cria o objeto DbTree.

@sample	CRM580Tree(oPanel,oViewActive,oMdlActive)

@param		ExpO1 - Panel AddOtherObject
			ExpO2 - FWFormView Ativa
			ExpO3 - MPFormModel Ativo
			ExpL4 - Cria um componente para avaliar o agrupador logico no Tree.

@return	Nenhum

@author	Jonatas Martins
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRM580DTree(oPnlMvc,oViewActive,oMdlActive,lEvalLogic)

Local oMenuPop 		:= Nil
Local aMenuPop 		:= {}
Local oMdlAOLGrid		:= Nil
Local oMdlAOLField	:= Nil
Local oMdlAOMGrid		:= oMdlActive:GetModel("AOMDETAIL")
Local cAOLResumo		:= ""
Local oPnlLogic		:= Nil
Local oPnlTree		:= Nil

Default oPnlMvc		:= Nil
Default oViewActive	:= Nil
Default oMdlActive	:= Nil
Default lEvalLogic	:= .F.

If IsInCallStack("CRMA580E")
	oMdlAOLGrid := oMdlActive:GetModel("AOLDETAIL")
	cAOLResumo :=  oMdlAOLGrid:GetValue("AOL_RESUMO")
	If lEvalLogic
		oPnlLogic	:= TPanel():New(01,01,"",oPnlMvc,,,,CLR_WHITE,CLR_WHITE,25,25)
		oPnlLogic:Align := CONTROL_ALIGN_TOP
		oPnlTree	:= TPanel():New(01,01,"",oPnlMvc,,,,CLR_WHITE,CLR_WHITE,100,100)	
		oPnlTree:Align := CONTROL_ALIGN_ALLCLIENT
	Else
		oPnlTree := oPnlMVC
	EndIf
Else
	oMdlAOLField 	:= oMdlActive:GetModel("AOLMASTER")
	cAOLResumo		:= oMdlAOLField:GetValue("AOL_RESUMO")	
	oPnlTree		:= oPnlMVC
EndIf

oTree := DBTree():New(0,0,000,000,oPnlTree,{|| .T. },{|| .T. },.T.)	// Adiciona a tree na view
oTree:Align := CONTROL_ALIGN_ALLCLIENT
oTree:AddItem( cAOLResumo+Space(200), CRMA580Root(), "FOLDER12", "FOLDER13",,,1)  // RAIZ //"Entidades

If !( oMdlAOMGrid:IsEmpty() )
	oTree:BeginUpdate() 
	Processa( {|| CRMA580DLdTree( oMdlActive ) }, STR0016, "" ) //"Carregando níveis do agrupador..."
	oTree:EndUpdate()
EndIf

MENU oMenuPop POPUP OF oTree

AAdd(aMenuPop,MenuAddItem(STR0003,,,.T.,,,,oMenuPop,{|| CRM580MntItem(oViewActive,oMdlActive,MODEL_OPERATION_VIEW)},,,,,{||.T.})) 	//"Visualizar"
AAdd(aMenuPop,MenuAddItem(STR0004,,,.T.,,,,oMenuPop,{|| CRM580MntItem(oViewActive,oMdlActive,MODEL_OPERATION_INSERT)},,,,,{||.T.})) //"Adicionar"
AAdd(aMenuPop,MenuAddItem(STR0005,,,.T.,,,,oMenuPop,{|| CRM580MntItem(oViewActive,oMdlActive,MODEL_OPERATION_UPDATE)},,,,,{||.T.}))	//"Alterar"
AAdd(aMenuPop,MenuAddItem(STR0006,,,.T.,,,,oMenuPop,{|| CRM580MntItem(oViewActive,oMdlActive,MODEL_OPERATION_DELETE)},,,,,{||.T.}))	//"Excluir"

ENDMENU

//Clique com botao esquerdo do mouse
oTree:BLClicked	:= {|| CRMA580DTClick(oViewActive,oMdlActive) }

If IsInCallStack("CRMA580E")
	If lEvalLogic
		CRMA580FComp(oPnlLogic,oTree,oMdlActive,oViewActive)	
		oTree:SetDisable()
	EndIf
Else
	// Bloco de change do Tree
	oTree:bChange	:= {|| CRM580TChange(oMdlActive) }
	// Posição x,y em relação a Dialog
	oTree:BrClicked := {|oTree,x,y| oMenuPop:Activate( x, y-180, oTree ) }
EndIf

oTree:EndTree()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM580MntItem

Controla a Operação CRUD do Tree.

@sample	CRM580MntItem(oViewActive,oMdlActive,nOperation)

@param		ExpO1 - FwFormView do Agrupador de Registros
			ExpO2 - MPFormModel do Agrupador de Registros
			ExpN3 - Operacao CRUD

@return	ExpL - Verdadeiro / Falso

@author	Anderson Silva
@since		21/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580MntItem(oViewActive,oMdlActive,nOperation)
	Local oAOLModel		:= oMdlActive:GetModel("AOLMASTER")
	Local oMdlAOMGrid	:= Nil
	Local oMdlAOMField	:= Nil
	Local oModelCad		:= Nil
	Local oStructAOM	:= Nil
	Local oViewStruct	:= Nil
	Local aCampos		:= {}
	Local oView			:= Nil
	Local oExecView		:= Nil
	Local nX			:= 0
	Local lRetorno		:= .T.
	Local lSublevel		:= .T. 
	Local aLdAOMField	:= {}
	Local cOperation	:= ""
	Local nLinAtu		:= 0
	Local lAllLinesDel	:= .T.
	Local aButtons		:= {}
	
	//-------------------------------------------------------------------
	// Verifica se um nível pode ter subníveis.  
	//-------------------------------------------------------------------	
	If AOL->(FieldPos("AOL_SUBNIV")) > 0 
		lSublevel := ! ( oAOLModel:GetValue("AOL_SUBNIV") == "2" )
	EndIf
	
	If AllTrim(oTree:GetCargo()) == CRMA580Root() .AND. ! (nOperation == MODEL_OPERATION_INSERT)
		If nOperation == MODEL_OPERATION_VIEW
			FWExecView(Upper(STR0008),'VIEWDEF.CRMA580',nOperation,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/) //"Visualizar"
		ElseIf nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_DELETE
			MsgAlert( STR0007 ) //"Operação não permitida!"
		EndIf
	Else
		//-------------------------------------------------------------------
		// Verifica se pode ser feita a manutenção do nível.  
		//-------------------------------------------------------------------
		If ! ( lSublevel ) .And. ( nOperation == MODEL_OPERATION_INSERT ) .And. ! ( AllTrim( oTree:GetCargo() ) == CRMA580Root() )
			MsgAlert( STR0017 )	//"A inclusão de subníveis foi desabilitada para este agrupador!"
		Else
			oMdlAOMGrid	:= oMdlActive:GetModel("AOMDETAIL")
			nLinAtu		:= oMdlAOMGrid:GetLine()
					
			For nX := 1 To oMdlAOMGrid:Length()
				oMdlAOMGrid:GoLine(nX)
				If !oMdlAOMGrid:IsDeleted() 
					lAllLinesDel := .F.
					Exit
				EndIf
			Next nX
					
			//------------------------------------------------------------------------------------
			// Faz um change no componente DbTree para aplicar as regras vinculada no componente.
			//------------------------------------------------------------------------------------
			oMdlAOMGrid:GoLine(nLinAtu)
			CRM580TChange(oMdlActive)
			
			If (lAllLinesDel .OR. oTree:Total() == 1 .OR. nOperation <> MODEL_OPERATION_INSERT .OR. CRMA580VldMdl(oMdlActive) )
				oMdlAOMGrid	:= oMdlActive:GetModel("AOMDETAIL")
				oModelCad:= FWLoadModel("CRMA580C")
				oMdlAOMField := oModelCad:GetModel("AOMMASTER")
				oStructAOM	 := oMdlAOMField:GetStruct()
				aCampos		 := oStructAOM:GetFields()
				
				oModelCad:SetOperation(nOperation)
				
				If nOperation <> MODEL_OPERATION_INSERT
					If !oMdlAOMGrid:SeekLine({{"AOM_CODNIV",AllTrim(oTree:GetCargo())}})
						lRetorno := .F.
					EndIf
				EndIf
				
				If lRetorno
					For nX := 1 To Len(aCampos)
						aAdd(aLdAOMField,oMdlAOMGrid:GetValue(aCampos[nX][MODEL_FIELD_IDFIELD]))
					Next nX
				
					oMdlAOMField:bLoad := {|| aLdAOMField }
					oModelCad:Activate()
					
					oView := FWLoadView("CRMA580C")
					oView:SetModel(oModelCad)
					oView:SetOperation(nOperation)
					oViewStruct := oView:GetViewStruct( "AOMMASTER" )	
					
					//-------------------------------------------------------------------
					// Verifica se o código do nível é automático.  
					//-------------------------------------------------------------------	
					If AOL->(FieldPos("AOL_DIGNIV")) == 0 .Or. ( ! oMdlActive:GetModel("AOLMASTER"):GetValue("AOL_DIGNIV") == "2" )		
						//-------------------------------------------------------------------
						// Remove o campo AOM_CODNIV do formulário.  
						//-------------------------------------------------------------------	
						oViewStruct:RemoveField( "AOM_CODNIV" )
					Else	
						If ! ( nOperation == MODEL_OPERATION_INSERT )
							//-------------------------------------------------------------------
							// Desabilita o campo AOM_CODNIV.  
							//-------------------------------------------------------------------
							oViewStruct:SetProperty( "AOM_CODNIV", MVC_VIEW_CANCHANGE, .F. )
						EndIf 	
					EndIf 

					Do Case
						Case nOperation == MODEL_OPERATION_VIEW
							cOperation := STR0008  //"Visualizar"
						Case nOperation == MODEL_OPERATION_INSERT
							cOperation := STR0009 //"Incluir"
						Case nOperation == MODEL_OPERATION_UPDATE
							cOperation := STR0010 //"Alterar"
						Case nOperation == MODEL_OPERATION_DELETE
							cOperation := STR0011 //"Excluir"
					EndCase
					
					aButtons := { {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}	,;
					{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil}				,;
					{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }
					
					oExecView := FWViewExec():New()
					oExecView:SetTitle(STR0012+Upper(cOperation))
					oExecView:SetView(oView)
					oExecView:SetModal(.T.)
					oExecView:SetOK({|| CRM580DAtuGrd(oViewActive,oMdlActive,oModelCad,nOperation) })
					oExecView:SetCloseOnOK({|| .T. })
					oExecView:SetOperation(MODEL_OPERATION_UPDATE)
					oExecView:SetButtons(aButtons)
					oExecView:SetReduction(75)
					oExecView:OpenView(.F.)
				Else
					MsgStop(STR0013)  //"Registro não localizado!"
				EndIf
			EndIf
		EndIf
	EndIf
	
	oViewActive:Refresh()
	oTree:SetFocus()
Return(lRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM580DAtuGrd

Replica a operacao CRUD feita no DbTree para grid.

@sample	CRM580DAtuGrd(oMdlActive,oMdlAOMField,nOperation)

@param		ExpO1 - FwFormView do Agrupador de Registros
			ExpO2 - MPFormModel do Agrupador de Registros
			ExpO3 - MPFormModel do Cadastro do Nivel
			ExpN4 - Operacao CRUD

@return	ExpL - Verdadeiro / Falso

@author	Anderson Silva
@since		21/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580DAtuGrd(oViewActive,oMdlActive,oModelCad,nOperation)
	Local oMdlAOMField	:= oModelCad:GetModel("AOMMASTER")
	Local oMdlAOMGrid	:= oMdlActive:GetModel("AOMDETAIL")
	Local oMdlAONGrid	:= oMdlActive:GetModel("AONDETAIL")
	Local oStructAOM	:= oMdlAOMGrid:GetStruct()
	Local aCampos		:= oStructAOM:GetFields()
	Local aError		:= {}
	Local cCodNivel		:= ""
	Local cCodIntPos	:= ""
	Local cCodInt		:= ""
	Local cCodIntSup	:= ""
	Local cCodNivSup	:= ""
	Local nY			:= 0
	Local nX			:= 0
	Local nPosition		:= 0
	Local cCodPaiPos	:= 0
	Local nNewNvlId		:= 	0
	Local lOk 			:= .T.

	If ! ( nOperation == MODEL_OPERATION_DELETE )
		//-------------------------------------------------------------------
		// Valida o modelo de dados do formulário.  
		//-------------------------------------------------------------------
		lOk := ( oMdlAOMField:VldData() )
	
		If ( lOk )
			//-------------------------------------------------------------------
			// Verifica se o código do nível é informado manualmente.  
			//-------------------------------------------------------------------	
			If AOL->(FieldPos("AOL_DIGNIV")) > 0 .And. ( oMdlActive:GetModel("AOLMASTER"):GetValue("AOL_DIGNIV") == "2" )
				//-------------------------------------------------------------------
				// Recupera o código do nível.  
				//-------------------------------------------------------------------				
				cCodNivel := oMdlAOMField:GetValue( "AOM_CODNIV" )
	
				//-------------------------------------------------------------------
				// Valida o código informado para o nível.  
				//-------------------------------------------------------------------	
				If( nOperation == MODEL_OPERATION_INSERT )
					//-------------------------------------------------------------------
					// Recupera a posição do grid. 
					//-------------------------------------------------------------------
					nPosition	:= oMdlAOMGrid:GetLine()	
			
					//-------------------------------------------------------------------
					// Verifica se o código informado está em uso. 
					//-------------------------------------------------------------------
					lOk := ! Empty( oMdlAOMField:GetValue( "AOM_CODNIV" ) )

					If ( lOk )		
						lOk := ! ( cCodNivel == CRMA580Root() )
						
						If ( lOk )		
							lOk := ! ( oMdlAOMGrid:SeekLine( { { "AOM_CODNIV", cCodNivel } } ) )
						
							If ! ( lOk )
								lOk := Empty( oMdlAOMGrid:GetValue("AOM_DESCRI") ) 
							EndIf
						EndIf				
					EndIf
					
					//-------------------------------------------------------------------
					// Retorna o grid para a posição original. 
					//-------------------------------------------------------------------
					oMdlAOMGrid:GoLine( nPosition )
				EndIf	
			EndIf	
	
			If ( lOk )
				//-------------------------------------------------------------------
				// Recupera a posição do grid. 
				//-------------------------------------------------------------------
				nPosition := oMdlAOMGrid:GetLine()
			
				//-------------------------------------------------------------------
				// Recupera o ID inteligente e o ID do nível selecionado.  
				//-------------------------------------------------------------------	
				If ( oMdlAOMGrid:SeekLine( { { "AOM_CODNIV", AllTrim( oTree:GetCargo() ) } } ) )
					cCodIntPos := AllTrim(oMdlAOMGrid:GetValue("AOM_IDINT"))
					cCodPaiPos := AllTrim(oMdlAOMGrid:GetValue("AOM_CODNIV"))
				EndIf
		
				//-------------------------------------------------------------------
				// Retorna o grid para a posição original. 
				//-------------------------------------------------------------------
				oMdlAOMGrid:GoLine( nPosition )
		
				//-------------------------------------------------------------------
				// Insere a nova linha no grid. 
				//-------------------------------------------------------------------
				If ( nOperation == MODEL_OPERATION_INSERT )
					oMdlAOMGrid:GoLine(oMdlAOMGrid:Length(.T.))
					
					If ( oMdlAOMGrid:IsDeleted() .Or. ! Empty( oMdlAOMGrid:GetValue("AOM_DESCRI") ) )
						oMdlAOMGrid:AddLine( .T. )
						oViewActive:Refresh()
						//-------------------------------------------------------------------
						// Recupera a posição do grid. 
						//-------------------------------------------------------------------
						nPosition := oMdlAOMGrid:GetLine()
					EndIf
				EndIf
		
				//-------------------------------------------------------------------
				// Recupera o ID incremental do nível se o código não for informado.  
				//-------------------------------------------------------------------	
				If ( Empty( cCodNivel ) )
					cCodNivel	:= oMdlAOMGrid:GetValue("AOM_CODNIV")
				EndIf
		
				//-------------------------------------------------------------------
				// Atribui o conteúdo dos campos do nível.  
				//-------------------------------------------------------------------
				For nX := 1 To Len(aCampos)
					If ! (aCampos[nX][MODEL_FIELD_IDFIELD] $ "AOM_MARK|AOM_CODAGR|")
						If ( aCampos[nX][MODEL_FIELD_IDFIELD] == "AOM_NIVPAI")
							//-------------------------------------------------------------------
							// Atribui o nível superior.  
							//-------------------------------------------------------------------
							If ( nOperation == MODEL_OPERATION_INSERT )
								oMdlAOMGrid:SetValue(aCampos[nX][MODEL_FIELD_IDFIELD],Alltrim(oTree:GetCargo()))
							EndIf 
						ElseIf aCampos[nX][MODEL_FIELD_IDFIELD] == "AOM_IDINT"
							//-------------------------------------------------------------------
							// Atribui o ID Inteligente.  
							//-------------------------------------------------------------------
							If ! ( nOperation == MODEL_OPERATION_UPDATE )
								oMdlAOMGrid:SetValue(aCampos[nX][MODEL_FIELD_IDFIELD],CRM580GrIdInt(cCodPaiPos,cCodIntPos,oMdlAOMGrid))
							Else
								oMdlAOMGrid:SetValue(aCampos[nX][MODEL_FIELD_IDFIELD], cCodIntPos )
							EndIf
						Else
							//-------------------------------------------------------------------
							// Atribui o código do nível.  
							//-------------------------------------------------------------------
							If ( aCampos[nX][MODEL_FIELD_IDFIELD] == "AOM_CODNIV" )
								oMdlAOMGrid:SetValue(aCampos[nX][MODEL_FIELD_IDFIELD], cCodNivel )	
							Else
								//-------------------------------------------------------------------
								// Atribui os demais campos.  
								//-------------------------------------------------------------------
								oMdlAOMGrid:SetValue(aCampos[nX][MODEL_FIELD_IDFIELD],oMdlAOMField:GetValue(aCampos[nX][MODEL_FIELD_IDFIELD]))
							EndIf
						EndIf
					EndIf
				Next nX
		
				If ( nOperation == MODEL_OPERATION_INSERT )
					//-------------------------------------------------------------------
					// Insere uma nova folha na árvore.  
					//-------------------------------------------------------------------
					oTree:AddItem( AllTrim( oMdlAOMGrid:GetValue("AOM_CODNIV") ) + " - " + oMdlAOMGrid:GetValue("AOM_DESCRI"), cCodNivel, "LBNO", "LBNO",,, 2 )
					
					//------------------------------------------------------------------------
					// Marca automaticamente o nivel criado e atualiza as regras de negocio.
					//------------------------------------------------------------------------
					oTree:TreeSeek(cCodNivel)
					oTree:Click()
					
					//-------------------------------------------------------------------
					// Retorna o grid para a posição original. 
					//-------------------------------------------------------------------
					oMdlAOMGrid:GoLine( nPosition )
					
					//------------------------------------------------------------------------------------
					// Faz um change no componente DbTree para aplicar as regras vinculada no componente.
					//------------------------------------------------------------------------------------
					CRM580TChange(oMdlActive)
					
				ElseIf nOperation == MODEL_OPERATION_UPDATE
					//-------------------------------------------------------------------
					// Atualiza uma nova folha existente.  
					//-------------------------------------------------------------------					
					oTree:ChangePrompt( AllTrim( oMdlAOMGrid:GetValue("AOM_CODNIV") ) + " - " + oMdlAOMGrid:GetValue("AOM_DESCRI"), cCodNivel )
					
					If ( oMdlAOMGrid:GetValue("AOM_MSBLQL") == "1" )
						oTree:ChangeBmp("LBNO","LBNO",,,cCodNivel)
					EndIf
				EndIf
			Else
				oModelCad:GetModel():SetErrorMessage(,, oModelCad:GetId(),, "", "O código informado para o nível não é válido ou já está em uso neste agrupador.", "Informe outro valor para o campo nível!" ) //"O nível informado já existe."###"Informe outro valor para o campo nível!" 
			EndIf 
		EndIf
		
		//-------------------------------------------------------------------
		// Exibe mensagem de erro na manutenção dos níveis.  
		//-------------------------------------------------------------------	
		If ! ( lOK )
			aError := oModelCad:GetErrorMessage()
			Help("",1,"CRMA580VLD",,aError[6],1)
		EndIf
	
		oMdlAOMGrid:GoLine( nPosition )
	ElseIf oMdlAOMGrid:SeekLine({{"AOM_CODNIV",AllTrim(oTree:GetCargo())}})
		cCodInt	:= AllTrim(oMdlAOMGrid:GetValue("AOM_IDINT"))
		nPosition	:= oMdlAOMGrid:GetLine()
	
		//Procura os filhos do nó pai para deletar.
		For nY := 1 To oMdlAOMGrid:Length()
			oMdlAOMGrid:GoLine(nY)
			If SubStr(AllTrim(oMdlAOMGrid:GetValue("AOM_IDINT")),1,Len(cCodInt)) == cCodInt
				oMdlAOMGrid:DeleteLine()
				If oMdlActive:GetId() == "CRMA580B"
					// Deleta os registros filhos da AON
					For nX := 1 To oMdlAONGrid:Length()
						oMdlAONGrid:GoLine(nX)
						oMdlAONGrid:DeleteLine()
					Next
				EndIf
			EndIf
		Next nY
		
		//Deleta o registro pai
				oMdlAOMGrid:GoLine( nPosition )
		oMdlAOMGrid:DeleteLine()
		
		If oMdlActive:GetId() == "CRMA580B"
			// Deleta os registros filhos da AON
			For nX := 1 To oMdlAONGrid:Length()
				oMdlAONGrid:GoLine(nX)
				oMdlAONGrid:DeleteLine()
			Next
		EndIf
		
		//Recria o Identificador inteligente do no excluido.
		cCodIntSup := AllTrim(SubStr(cCodInt,1,Len(cCodInt)-NTAM_COD_INT))
		If oMdlAOMGrid:SeekLine({{"AOM_IDINT",cCodIntSup}})
			cCodNivSup := oMdlAOMGrid:GetValue("AOM_CODNIV")
			For nY := 1 To oMdlAOMGrid:Length()
				oMdlAOMGrid:GoLine(nY)
				If !oMdlAOMGrid:IsDeleted() .AND. oMdlAOMGrid:GetValue("AOM_NIVPAI") == cCodNivSup
					nNewNvlId++
					oMdlAOMGrid:SetValue("AOM_IDINT",cCodIntSup+StrZero(nNewNvlId,NTAM_COD_INT))
				EndIf
			Next nY
		EndIf
		
		oTree:DelItem()
	EndIf
Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM580GrIdInt

Gera o codigo inteligente do nivel

@sample	CRM580GrIdInt(cCodPaiPos,cCodIntPos,oMdlAOMGrid)

@param		ExpC1 - Nível Pai posicionado
			ExpC2 - Codigo Inteligente posicionado
			ExpO3 - ModelGrid da Tabela AOM

@return	ExpC - Codigo Inteligente

@author	Anderson Silva
@since		31/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580GrIdInt( cCodPaiPos, cCodIntPos, oMdlAOMGrid )
	Local cCodInt		:= ""
	Local nLenNo		:= 0

	If ( oTree:GetCargo() == CRMA580Root() )
		nLenNo	:= CRM580DLNiv( oMdlAOMGrid, CRMA580Root() )
		cCodInt	:= StrZero( nLenNo, NTAM_COD_INT )
	Else
		nLenNo 	:= CRM580DLNiv( oMdlAOMGrid, cCodPaiPos )
		cCodInt	:= AllTrim( cCodIntPos + StrZero( nLenNo, 2) )
	EndIf
Return cCodInt 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM580DLNiv

Retorna quantos nó um nível pai possui.

@sample	CRM580DLNiv(oMdlAOMGrid,cCodPai)

@param		ExpO1 - ModelGrid da Tabela AOM
			ExpC2 - Nível Pai posicionado

@return	ExpN - Retorna quantos níveis o nó pai possui.

@author	Anderson Silva
@since		31/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580DLNiv( oMdlAOMGrid, cCodPai )
	Local nLenNo	:= 0
	Local nX		:= 0
	Local nLinAtu	:= oMdlAOMGrid:GetLine()
	
	For nX := 1 To oMdlAOMGrid:Length()
		oMdlAOMGrid:GoLine(nX)
		
		If !oMdlAOMGrid:IsDeleted() .AND. oMdlAOMGrid:GetValue("AOM_NIVPAI") == cCodPai
			nLenNo++
		EndIf
	Next nX
	
	oMdlAOMGrid:GoLine(nLinAtu)
Return(nLenNo)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM580TChange

Bloco de Change do componente DbTree.

@sample	CRM580TChange(oMdlActive,oViewActive)

@param		ExpO1 - MPFormModel do Agrupador de Registros

@return	Nenhum

@author	Anderson Silva
@since		31/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580TChange(oMdlActive)

Local oMdlAOMGrid	:= oMdlActive:GetModel("AOMDETAIL")
Local cIdTree	 	:= AllTrim(oTree:GetCargo())

If cIdTree <> CRMA580Root() .And. oMdlAOMGrid:SeekLine({{"AOM_CODNIV",cIdTree}})

	//--------------------------------------
	// Limpa os filtros aplicado no browse.
	//--------------------------------------
	If oMdlActive:GetId() == "CRMA580A"
		//------------------------------------
		// Tratamento para agrupadro Dinamico 
		//------------------------------------
		CRMA580AFClr()
	ElseIf oMdlActive:GetId() == "CRMA580F"
		//----------------------------------
		// Tratamento para agrupadro lógico
		//----------------------------------
		CRMA580FFClr()
	EndIf
	
	If oMdlAOMGrid:GetValue("AOM_MARK")
		Do Case
			Case oMdlActive:GetId() == "CRMA580A"
				//------------------------------------
				// Tratamento para agrupadro Dinamico 
				//------------------------------------
				CRMA580ALFil(oTree,oMdlActive)
			Case oMdlActive:GetId() == "CRMA580B"
				//------------------------------------
				// Tratamento para agrupadro Fixo 
				//------------------------------------
				CRMA580BAONTop(oMdlActive)
			Case oMdlActive:GetId() == "CRMA580F"
				//----------------------------------
				// Tratamento para agrupadro lógico
				//----------------------------------
				CRMA580FNFil(oTree,oMdlActive)
		EndCase
	EndIf
	
ElseIf oTree:Total() == 1 .And. cIdTree == CRMA580Root()
	
	//--------------------------------------
	// Limpa os filtros aplicado no browse.
	//--------------------------------------
	If oMdlActive:GetId() == "CRMA580A"
		//------------------------------------
		// Tratamento para agrupadro Dinamico 
		//------------------------------------
		CRMA580AFClr()
	ElseIf oMdlActive:GetId() == "CRMA580F"
		//----------------------------------
		// Tratamento para agrupadro lógico
		//----------------------------------
		CRMA580FFClr()
	EndIf
	
EndIf

oTree:SetFocus()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580DTClick

Funcao que marca e desmarca o DbTree

@sample	CRMA580DTClick(oViewActive,oMdlActive)

@param		ExpO1 - FwFormView do Agrupador de Registros
			ExpO2 - MPFormModel do Agrupador de Registros

@return	Nenhum

@author	Anderson Silva
@since		31/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580DTClick(oViewActive,oMdlActive)

Local oMdlAOMGrid	:= oMdlActive:GetModel("AOMDETAIL")
Local cIdTree		:= AllTrim(oTree:GetCargo())
Local cCodIntPos	:= ""
Local lMarkAll 		:= CRMA580EMrkAll()
Local nLinAtu		:= 0

If cIdTree <> CRMA580Root() .AND. oMdlAOMGrid:SeekLine({{"AOM_CODNIV",cIdTree}})
	
	If oMdlAOMGrid:GetValue("AOM_MSBLQL") == "2"
		
		nLinAtu	:= oMdlAOMGrid:GetLine()
		
		cCodIntPos	:= AllTrim(oMdlAOMGrid:GetValue("AOM_IDINT"))
		
		If !lMarkAll 
	
			CRM580ClrAll(oMdlAOMGrid)
			
			If oMdlAOMGrid:GetValue("AOM_MARK")
				oTree:ChangeBmp("LBNO","LBNO",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
				oMdlAOMGrid:SetValue("AOM_MARK",.F.)
				CRM580DClrChildren(oMdlAOMGrid,cCodIntPos,(nLinAtu+1))
			Else
				oTree:ChangeBmp("LBOK","LBOK",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
				oMdlAOMGrid:SetValue("AOM_MARK",.T.)
				
				Do Case
					Case oMdlActive:GetId() == "CRMA580A"
						//------------------------------------
						// Tratamento para agrupadro Dinamico 
						//------------------------------------
						CRMA580ALFil(oTree,oMdlActive)
					Case oMdlActive:GetId() == "CRMA580B"
						//------------------------------------
						// Tratamento para agrupadro Fixo 
						//------------------------------------
						CRMA580BAONTop(oMdlActive)
					Case oMdlActive:GetId() == "CRMA580F"
						//----------------------------------
						// Tratamento para agrupadro lógico
						//----------------------------------
						CRMA580FNFil(oTree,oMdlActive)
				EndCase
				
				If Len(cCodIntPos) > NTAM_COD_INT
					CRM580DMrkParents(oMdlAOMGrid,cCodIntPos)
				EndIf
				
			EndIf
			
		Else
			
			If oMdlAOMGrid:GetValue("AOM_MARK")
				oTree:ChangeBmp("LBNO","LBNO",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
				oMdlAOMGrid:SetValue("AOM_MARK",.F.)
				CRM580DClrChildren(oMdlAOMGrid,cCodIntPos,(nLinAtu+1))
			Else
				oTree:ChangeBmp("LBOK","LBOK",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
				oMdlAOMGrid:SetValue("AOM_MARK",.T.)
				If Len(cCodIntPos) > NTAM_COD_INT
					CRM580DMrkParents(oMdlAOMGrid,cCodIntPos)
				EndIf
			EndIf
			
		EndIf
		
		oMdlAOMGrid:GoLine(nLinAtu)
		
	Else
		MsgAlert(STR0015) //"Registro Bloqueado!"
	EndIf
	
EndIf

oViewActive:Refresh()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM580ClrAll
Desmarca todos os subniveis marcados.

@sample	CRM580ClrAll(oMdlAOMGrid)

@param		ExpO1 - ModelGrid Nível do Agrupador

@return	Nenhum

@author	Anderson Silva
@since		31/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580ClrAll(oMdlAOMGrid)

Local nLinAtu := oMdlAOMGrid:GetLine()
Local nX	  := 0

For nX := 1 To oMdlAOMGrid:Length()
	oMdlAOMGrid:GoLine(nX)
	If oMdlAOMGrid:GetValue("AOM_MARK")
		oTree:ChangeBmp("LBNO","LBNO",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
		oMdlAOMGrid:SetValue("AOM_MARK",.F.)
	EndIf
Next nX

oMdlAOMGrid:GoLine(nLinAtu)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM580DClrChildren

Desmarca todos os filhos

@sample	CRM580DClrChildren(oMdlAOMGrid,cCodIntPos,nLinStart)

@param		ExpO1 - ModelGrid Nível do Agrupador
			ExpC2 - Codigo Inteligente posicionado
			ExpN3 - Linha do grid que será iniciada no For.

@return	Nenhum

@author	Anderson Silva
@since		31/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580DClrChildren(oMdlAOMGrid,cCodIntPos,nLinStart)

Local nX 		:= 0
Local cCodInt	:= ""
Local nLinAtu	:= oMdlAOMGrid:GetLine()

For nX := nLinStart To oMdlAOMGrid:Length()
	oMdlAOMGrid:GoLine(nX)
	cCodInt := AllTrim(oMdlAOMGrid:GetValue("AOM_IDINT"))
	If cCodIntPos == SubStr(cCodInt,1,Len(cCodIntPos))
		oTree:ChangeBmp("LBNO","LBNO",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
		oMdlAOMGrid:SetValue("AOM_MARK",.F.)
	EndIf
Next nX

oMdlAOMGrid:GoLine(nLinAtu)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM580DMrkParents

Marca os pais do nível selecionado.

@sample	CRM580DMrkParents(oMdlAOMGrid,cCodIntPos)

@param		ExpO1 - ModelGrid Nível do Agrupador
			ExpC2 - Codigo inteligente posicionado

@return	Nenhum

@author	Anderson Silva
@since		31/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM580DMrkParents(oMdlAOMGrid,cCodIntPos)

Local nX 			:= 0
Local nLenLinGrid	:= oMdlAOMGrid:Length()
Local cCodInt		:= ""
Local nLinAtu		:= oMdlAOMGrid:GetLine()

For nX := nLenLinGrid To 1  Step -1
	oMdlAOMGrid:GoLine(nX)
	cCodInt := AllTrim(oMdlAOMGrid:GetValue("AOM_IDINT"))
	If SubStr(cCodInt,1,NTAM_COD_INT) == SubStr(cCodIntPos,1,NTAM_COD_INT) .AND. cCodInt $ cCodIntPos
		oTree:ChangeBmp("LBOK","LBOK",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
		oMdlAOMGrid:SetValue("AOM_MARK",.T.)
	EndIf
Next nX

oMdlAOMGrid:GoLine(nLinAtu)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580DLdTree
Carrega o componente DbTree com os Níveis do Agrupador.

@sample		CRMA580DLdTree(oMdlActive)
@param		ExpO1 - MPFormModel do agrupador de registros
@return	Nenhum

@author	Anderson Silva
@since		31/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580DLdTree( oModelActive )
	Local oAOMGrid		:= Nil 
	Local oAOLGrid		:= Nil
	Local oAOLField		:= Nil
	Local aFather		:= {}
	Local aMark			:= {}
	Local cCargo		:= ""
	Local cFather		:= ""
	Local nLevel		:= 0
	Local aLevelFil		:= "" 
	
	Default oModelActive := FWModelActive()

	//-------------------------------------------------------------------
	// Recupera o modelo de dados.    
	//-------------------------------------------------------------------
	oAOMGrid 	:= oModelActive:GetModel("AOMDETAIL")

	//-------------------------------------------------------------------
	// Identifica a origem da requisição.    
	//-------------------------------------------------------------------
	If ( IsInCallStack("CRMA580E") )
		oAOLGrid	:= oModelActive:GetModel("AOLDETAIL")
		
		oTree:Reset()
		oTree:AddItem( oAOLGrid:GetValue("AOL_RESUMO"), CRMA580Root(), "FOLDER12" ,"FOLDER13",,, 1 )
	EndIf

	//-------------------------------------------------------------------
	// Define o tamanho da régua de processamento.    
	//-------------------------------------------------------------------
	ProcRegua( oAOMGrid:Length() )
	
	//-------------------------------------------------------------------
	// Verifica se existe níveis a serem filtrados
	//-------------------------------------------------------------------	
	aLevelFil := CRMA580EGFil()	
	
	//-------------------------------------------------------------------
	// Percorre todos os níveis do agrupador.    
	//-------------------------------------------------------------------
	For nLevel := 1 To oAOMGrid:Length()
		oAOMGrid:GoLine( nLevel )
	
		//-------------------------------------------------------------------
		// Incrementa a régua de processamento.    
		//-------------------------------------------------------------------
		IncProc( oAOMGrid:GetValue("AOM_CODNIV") + " - " + oAOMGrid:GetValue("AOM_DESCRI") )
	
		//-------------------------------------------------------------------
		// Define a imagem de acordo com o status do nó.    
		//-------------------------------------------------------------------	
		If ( oAOMGrid:GetValue("AOM_MARK") )
			aAdd( aMark, oAOMGrid:GetValue("AOM_CODNIV") )
			cImage 	:= "LBOK"
		Else
			cImage 	:= "LBNO"
		EndIf
 	
		//-------------------------------------------------------------------
		// Localiza o nó pai.    
		//-------------------------------------------------------------------			
		If ! ( cFather == oAOMGrid:GetValue("AOM_NIVPAI") )	
			aAdd( aFather, oAOMGrid:GetValue("AOM_CODNIV") )
			cFather := oAOMGrid:GetValue("AOM_NIVPAI")
			oTree:TreeSeek( cFather )
		EndIf 

		//-------------------------------------------------------------------
		// Adiciona o nó filho.    
		//-------------------------------------------------------------------	
		If ( Empty(aLevelFil) .Or. aScan(aLevelFil,{|x| x == oAOMGrid:GetValue("AOM_NIVPAI")}) > 0 )	
			oTree:AddItem( AllTrim( oAOMGrid:GetValue("AOM_CODNIV") ) + " - " + oAOMGrid:GetValue("AOM_DESCRI"), oAOMGrid:GetValue("AOM_CODNIV"), cImage, cImage,,,2 )
		Endif
	Next nLevel
	
	//-------------------------------------------------------------------
	// Limpa array de filtros     
	//-------------------------------------------------------------------
	CRMA580EClF()
	
	//-------------------------------------------------------------------
	// Fecha os nós da árvore.    
	//-------------------------------------------------------------------
	aSort( aFather,,,{|x,y| x > y } )
	
	For nLevel := 1 To Len( aFather )
		oTree:TreeSeek( aFather[nLevel] )
		oTree:PTCollapse()
	Next nLevel

	//-------------------------------------------------------------------
	// Seleciona os nós marcados.    
	//-------------------------------------------------------------------	
	For nLevel := 1 To Len( aMark )
		oTree:TreeSeek( aMark[nLevel] )
	Next nLevel	
	
	//------------------------------------------------------
	// Posiciona na primeira linha do Nivel do Agrupador.    
	//------------------------------------------------------	
	oAOMGrid:GoLine(1)
Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580DSTree
Função que atribui ao objeto DbTree as alterações efetuadas em outras rotinas.

@return lOk, Indica se recuperou o objeto da árvore de níveis. 

@author	Jonatas Martins
@version	12
@since		11/03/2015
/*/
//------------------------------------------------------------------------------
Function CRMA580DSTree( oObj )
	Local lOk 	:= .F.

	lOk := ( ValType( oObj ) == "O" )

	If ( lOk )
		oTree := oObj
	EndIf
Return lOk 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580DGTree
Função que retorna o objeto Tree como parâmetro.

@return oTree, Objeto da árvore de níveis. 

@author	Jonatas Martins
@version	12
@since		11/03/2015
/*/
//------------------------------------------------------------------------------
Function CRMA580DGTree()
Return oTree