#INCLUDE "CRMA620.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//----------------------------------------------------------------------------
/*/{Protheus.doc} CRMA620

Amarracao dos Subsegmentos com as entidades Clientes, Prospects e Suspects

@sample	(aAOVMark, cEntidade, cCodigo, cLoja, cCodSegPri, nOperation)

@param		aAOVMark - Array com os segmentos de negocio (Referência) 
			cEntidade 	- Tipo da Entidade
			cCodigo 	- Codigo da Entidade
			cLoja		- Loja da Entidade
			cCodSegPri	- Segmento Primario
			nOperation	- Tipo de Operacao - (Visualizar ou Alterar)
			
@author		Anderson Silva
@since		04/07/2015
@version	P12 
/*/
//----------------------------------------------------------------------------
Function CRMA620(aAOVMark, cEntidade, cCodigo, cLoja, cCodSegPri, nOperation)

	Local oExecView 	:= Nil
	Local oView			:= Nil
	Local oModel		:= Nil
	Local oMdlAOVPri	:= Nil
	Local oMdlAOVAll	:= Nil
	Local oMdlStack		:= FwModelActivate()
	Local oViewStack	:= FwViewActivate()
	Local lRelation 	:= .F.
	Local aButtons		:= {}
	Local cTiTulo		:= ""
		
	Default aAOVMark  	:= {}
	Default cEntidade	:= ""
	Default cCodigo		:= ""
	Default cLoja		:= ""
	Default cCodSegPri	:= ""
	Default nOperation	:= MODEL_OPERATION_UPDATE
	
	//Forca alteracao para fazer o bLoad
	If nOperation == MODEL_OPERATION_INSERT
		nOperation := MODEL_OPERATION_UPDATE
	EndIf
	
	//Define o titulo da view
	If nOperation  == MODEL_OPERATION_VIEW
		cTitulo  := STR0001+Upper(STR0002)//"Segmentos - "//"Visualizar"
		//Na visualizacao nao faz cache.
		aAOVMark := {}
	ElseIf nOperation  == MODEL_OPERATION_UPDATE
		cTitulo := STR0004+Upper(STR0003)	//"Alterar"//"Segmentos - "
	EndIf
 
	DbSelectArea("AOV")
	AOV->( DbSetOrder( 1 ) )
	
	If AOV->( DbSeek( xFilial("AOV")+cCodSegPri ) )
		
		lRelation := Aviso(STR0005,STR0006,{STR0007,STR0008},2) == 2 //STR0005//"Inclusao dos Subsegmentos, todos os segmentou ou somente o relacionado."//"Relacionado"//"Todos"//"Atenção"//"Deseja visualizar somente os subsegmentos relacionados ao segmento primário?"//"Não"//"Sim"
			
		oModel		:= FWLoadModel( "CRMA620" ) 
		oModel:SetOperation(nOperation)
		oMdlAOVPri	:= oModel:GetModel("AOVMASTER")
		oMdlAOVAll	:= oModel:GetModel("AOVDETAIL")
		
		//Carrega o cabeçalho.
		oMdlAOVPri:bLoad := {|| {AOV->AOV_FILIAL, AOV->AOV_CODSEG, AOV->AOV_DESSEG} }
		oMdlAOVAll:bLoad := {|| CRM620LAOV(oMdlAOVAll, aAOVMark, cCodSegPri, cEntidade, cCodigo, cLoja, lRelation, nOperation) }	
		oModel:bCommit   := {|oModel| ( CRMA620GetAOV(oModel, aAOVMark),.T.) }
		
		oModel:GetModel("AOVDETAIL"):SetNoDeleteLine(.T.)
		oModel:GetModel("AOVDETAIL"):SetNoInsertLine(.T.)
		
		oModel:Activate()
		
		oView := FWLoadView( "CRMA620" )
		oView:SetModel(oModel)
		oView:SetOperation(nOperation)
		
		aButtons := { {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
					  {.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},;
					  {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }
			
		oExecView := FWViewExec():New()
		oExecView:SetTitle(cTitulo)
		oExecView:SetView(oView)
		oExecView:SetModal(.F.)
		oExecView:SetOperation(nOperation)
		oExecView:SetButtons(aButtons)
		oExecView:SetSize(450,450)
		oExecView:OpenView(.F.)
		
		If oMdlStack <> Nil .And. oViewStack <> Nil
			oMdlStack:lModify 	:= .T.
			oViewStack:lModify  := .T.
		EndIf
	Else
		MsgAlert(STR0009)		//"Código do segmento primário não informado!"
	EndIf
	
Return Nil

//----------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Monta modelo de dados da Conta x Segmentos

@sample		ModelDef()

@param		Nenhum

@return		ExpO - Modelo de Dados

@author		Anderson Silva
@since		04/07/2015
@version	12
/*/
//----------------------------------------------------------------------------------------
Static Function ModelDef()

	Local bAvalCampo	:= {|cCampo| AllTrim(cCampo)+"|" $ "AOV_FILIAL|AOV_CODSEG|AOV_DESSEG|"}
	Local oStrAOVPri	:= FWFormStruct( 1, "AOV", bAvalCampo, /*lViewUsado*/ )
	Local oStrAOVAll	:= FWFormStruct( 1, "AOV", bAvalCampo, /*lViewUsado*/ )
	Local oModel 	 	:= Nil
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campo de marca  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	oStrAOVAll:AddField("","","AOV_MARK","L",1,0,{|oMdlAOVAll| CRMA620MrkDel(oMdlAOVAll) },Nil,Nil,Nil,Nil,Nil,Nil,.T.)
	
	oStrAOVAll:AddField("","","AOV_MRKDEL","L",1,0,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)
	
	oModel := MPFormModel():New( "CRMA620", /*bPreValidacao*/, /*bPosVldMdl*/, /*bCommitMdl*/, /*bCancel*/ )
	
	oModel:AddFields("AOVMASTER", /*cOwner*/, oStrAOVPri, /*bPreValidacao*/, /*bPosVldMdl*/, /*bCarga*/ )
	oModel:AddGrid("AOVDETAIL","AOVMASTER",oStrAOVAll,/*bLinPre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVldGrid*/,/*bLoad*/)
	
	oModel:SetRelation("AOVDETAIL",{ {"AOW_FILIAL", "xFilial('AOW')"} },AOV->(IndexKey(1)))
	
	oModel:SetDescription( STR0010 ) //"Segmentos"

Return( oModel )

//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Monta interface da Conta x Segmentos

@sample		ViewDef()

@param		Nenhum

@return		ExpO - Interface MVC

@author		Anderson Silva
@since		04/07/2015
@version	12
/*/
//-----------------------------------------------------------------------------------------
Static Function ViewDef()

	Local bAvalCampo	:= {|cCampo| AllTrim(cCampo)+"|" $ "AOV_FILIAL|AOV_CODSEG|AOV_DESSEG|"}
	Local oStrAOVPri	:= FWFormStruct( 2, "AOV", bAvalCampo, /*lViewUsado*/ )
	Local oStrAOVAll	:= FWFormStruct( 2, "AOV", bAvalCampo, /*lViewUsado*/ )
	Local oModel   		:= FWLoadModel( "CRMA620" )
	Local oView	 		:= Nil
	
	oStrAOVPri:SetProperty("AOV_DESSEG" ,MVC_VIEW_CANCHANGE, .F. )
	oStrAOVAll:SetProperty("AOV_DESSEG" ,MVC_VIEW_CANCHANGE, .F. )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campo de marca ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oStrAOVAll:AddField("AOV_MARK","01","","",{},"L","@BMP",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	oView:AddField( "VIEW_AOV", oStrAOVPri, "AOVMASTER" )
	
	oView:AddGrid("VIEW_AOVALL",oStrAOVAll,"AOVDETAIL")
	
	oView:CreateHorizontalBox( "SUPERIOR", 25 )
	
	oView:CreateHorizontalBox( "INFERIOR", 75)
	
	oView:EnableTitleView("VIEW_AOV",STR0011) //"Segmento Primário"
	oView:SetOwnerView( "VIEW_AOV", "SUPERIOR" )
	
	oView:EnableTitleView("VIEW_AOVALL",STR0012) //"Subsegmentos"
	oView:SetOwnerView( "VIEW_AOVALL", "INFERIOR" )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grid - Seta algumas propriedades na View ³
	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oView:SetViewProperty("VIEW_AOVALL","ENABLENEWGRID")
	oView:SetViewProperty("VIEW_AOVALL","GRIDFILTER",{.T.})
	oView:SetViewProperty("VIEW_AOVALL","GRIDSEEK",{.T.})

Return( oView )

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRM620LAOV

Carrega a tabela de segmentos no ModelGrid - Segmentos

@sample	CRM620LAOV(oMdlAOVAll, aAOVMark, cCodSegPri, cEntidade, cCodigo, cLoja, lRelation, nOperation)

@param		oMdlAOVAll	- ModelGrid - Segmentos
			aAOVMark	- Array com os segmentos de negocio (Referencia) 
			cEntidade 	- Tipo da Entidade
			cCodigo 	- Codigo da Entidade
			cLoja		- Loja da Entidade
			cCodSegPri	- Segmento Primario
			lRelaction	- Filtra somente os subsegmentos relacionados
			nOperation - Operação (inclusão, alteração, visualização, exclusão)
			
@return	aLoadAOV - array de subsegmentos
			
@author		Anderson Silva
@since		04/07/2015
@version	P12 
/*/
//------------------------------------------------------------------------------------------------
Static Function CRM620LAOV(oMdlAOVAll, aAOVMark, cCodSegPri, cEntidade, cCodigo, cLoja, lRelation, nOperation)

	Local aLoadAOV   := {}
	Local oStructAOV := oMdlAOVAll:GetStruct()
	Local aCampos    := oStructAOV:GetFields()
	Local cMacro     := ""
	Local cCampo	 := ""
	Local nY		 := 0 
	Local nPos		 := 0
	Local lAOVCache	 := .F.
	Local lSeekMark	 := .F.
	Local lViewLine	 := .T.
	
	Private INCLUI 	:= .F.
	
	If nOperation == 1 .Or. AOV->AOV_MSBLQL <> "1"		//	Só carregar subsegmentos se for visualizacao OU para selecao se o PAI não está bloqueado

	DbSelectArea( "AOV" )
	AOV->( DbSetOrder(1) )
	
	If AOV->( DbSeek( xFilial("AOV") ) )
	
		DbSelectArea("AOW")
		AOW->( DbSetOrder(1) )	//AOW_FILIAL+AOW_ENTIDA+AOW_FILENT+AOW_CODCNT+AOW_LOJCNT+AOW_CODSEG+AOW_SUBSEG                                                                                            
		
		lAOVCache := !Empty(aAOVMark)
		
		While AOV->(!Eof()) .And. AOV->AOV_FILIAL == xFilial("AOV")
				
					If ( AOV->AOV_CODSEG <> cCodSegPri .And.  !lRelation ) .Or. ( lRelation .And. AOV->AOV_PAI == cCodSegPri .And. AOV->AOV_MSBLQL <> "1" )
			
				lSeekMark := AOW->( DbSeek(xFilial("AOW")+cEntidade+xFilial(cEntidade)+cCodigo+cLoja+cCodSegPri+AOV->AOV_CODSEG) )
				
				If nOperation == MODEL_OPERATION_VIEW
					lViewLine := lSeekMark
				Else
					lViewLine := .T.
				EndIf 
				
				If lViewLine
				
					aAdd(aLoadAOV,{AOV->(Recno()) ,{} })	
					
					For nY := 1 To Len(aCampos)	
						cCampo := AllTrim(aCampos[nY][MODEL_FIELD_IDFIELD])
						If !aCampos[nY][MODEL_FIELD_VIRTUAL]
							cMacro := "AOV->"+cCampo 
						Else
							If cCampo == "AOV_MARK" .Or. cCampo == "AOV_MRKDEL" 
								If lAOVCache
									nPos := aScan(aAOVMark,{|x| x[2] == AOV->AOV_CODSEG})
									If nPos > 0
										cMacro := IIF(cCampo == "AOV_MARK",cValToChar(aAOVMark[nPos][1]),cValToChar(aAOVMark[nPos][3]))
									Else
										cMacro := ".F."	
									EndIf
								Else
									If cCampo == "AOV_MARK"
										If lSeekMark
											cMacro := ".T."
										Else
											cMacro := ".F."	
										EndIf
									Else
										cMacro := ".F."	
									EndIf
								EndIf			
							Else
								cMacro := AllTrim(aCampos[nY][MODEL_FIELD_INIT])
							EndIf
						EndIf
							
						aAdd(aLoadAOV[Len(aLoadAOV),2] ,&(cMacro) )
						
					Next nY
				
				EndIf
			
			EndIf
			
			AOV->(DbSkip())
			  
			End	
			
		EndIf
		
	EndIf

Return(aLoadAOV)

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA620GetAOV

Busca os subsementos marcados pelo usuario.

@sample		CRMA620GetAOV(oModel ,aAOVMark )

@param		oModel	 - MPFormModel - Subsegmentos
			aAOVMark - Array para armazenar os segmentos marcados.
	
@return		aAOVMark - array de marcacao
			
@author		Anderson Silva
@since		04/07/2015
@version	P12 
/*/
//-------------------------------------------------------------------
Static Function CRMA620GetAOV(oModel ,aAOVMark )
	
	Local oMdlAOVPri := oModel:GetModel( "AOVMASTER" )
	Local oMdlAOVAll := oModel:GetModel( "AOVDETAIL" )
	Local nX		 := 0
	
	//Limpa o array de marcacao para nova carga.
	If !Empty(aAOVMark)
		aAOVMark := {}
	EndIf
	
	For nX := 1 To oMdlAOVAll:Length()
		oMdlAOVAll:GoLine( nX ) 
		aAdd( aAOVMark ,{oMdlAOVAll:GetValue( "AOV_MARK" ), oMdlAOVAll:GetValue( "AOV_CODSEG" ) ,oMdlAOVAll:GetValue( "AOV_MRKDEL" ) ,oMdlAOVPri:GetValue( "AOV_CODSEG" ) } )
	Next nX

Return( aAOVMark )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA620GrvAOW

Grava a amarracao do Subsegmentos x Entidade.

@sample	CRMA620GrvAOW(aAOVMark, cEntidade, cCodigo, cLoja, cCodSegPri, lDeleted)

@param		aAOVMark	- Array com os segmentos de negocio (Referencia) 
			cEntidade 	- Tipo da Entidade
			cCodigo 	- Codigo da Entidade
			cLoja		- Loja da Entidade
			cCodSegPri	- Segmento Primario
			lDeleted	- Flag que define se amarracao subsegmentos x entidade será deletada.
			
@return		nulo
			
@author		Anderson Silva
@since		04/07/2015
@version	P12 
/*/
//---------------------------------------------------------------------------------------
Function CRMA620GrvAOW(aAOVMark, cEntidade, cCodigo, cLoja, cCodSegPri, lDeleted)

	Local nX 		 	:= 0
	Local nPos			:= 0
	Local lInclui		:= .F.
	
	Default lDeleted	:= .F.
	
	If lDeleted  
		
		DbSelectArea("AOW")
		AOW->(DbSetOrder(1)) //AOW_FILIAL+AOW_ENTIDA+AOW_FILENT+AOW_CODCNT+AOW_LOJCNT+AOW_CODSEG+AOW_SUBSEG                                                                                    
		
		If AOW->( DbSeek(xFilial("AOW")+cEntidade+xFilial(cEntidade)+cCodigo+cLoja) )
		
			While ( AOW->( !Eof() ) .And. AOW->AOW_FILIAL == xFilial("AOW") .And. AOW->AOW_ENTIDA == cEntidade .And.;
				    AOW->AOW_FILENT == xFilial(cEntidade) .And. AOW->AOW_CODCNT == cCodigo .And. AOW->AOW_LOJCNT == cLoja ) 
					
					RecLock("AOW", .F.)
		  			AOW->( DbDelete() )
			  		AOW->( MsUnlock() )
				  			
				AOW->( DbSkip() )
			End
			
		EndIf
	
	Else
		
		DbSelectArea("AOW")
		AOW->( DbSetOrder(1) )	//AOW_FILIAL+AOW_ENTIDA+AOW_FILENT+AOW_CODCNT+AOW_LOJCNT+AOW_CODSEG+AOW_SUBSEG                                                                                    
		
		//Faz a inclusao dos novos subsegmentos marcados.	
		For nX  := 1 To Len(aAOVMark)
			
			If aAOVMark[nX][1]
				If !AOW->( DbSeek(xFilial("AOW")+cEntidade+xFilial(cEntidade)+cCodigo+cLoja+cCodSegPri+aAOVMark[nX][2]) )
					lInclui := .T.
				EndIf
				RecLock("AOW" ,lInclui)	
				AOW_FILIAL := xFilial("AOW")
				AOW_FILENT := xFilial(cEntidade)			
				AOW_ENTIDA := cEntidade
				AOW_CODCNT := cCodigo		
				AOW_LOJCNT := cLoja
				AOW_CODSEG := cCodSegPri
				AOW_SUBSEG := aAOVMark[nX][2]
			Else
				If aAOVMark[nX][3]
					If AOW->( DbSeek( xFilial("AOW")+cEntidade+xFilial(cEntidade)+cCodigo+cLoja+cCodSegPri+aAOVMark[nX][2] ) )
						RecLock("AOW" ,.F.)
						AOW->(DbDelete())
						AOW->(MsUnlock())	
					EndIf	
				EndIf
			EndIf 
			
			AOW->( MsUnlock() )	
			
			lInclui := .F.
			
		Next nX
		
		//Exclui os segmentos que nao pertence ao segmento primario.
		AOW->( DbSetOrder(1) ) //AOW_FILIAL+AOW_ENTIDA+AOW_FILENT+AOW_CODCNT+AOW_LOJCNT+AOW_CODSEG+AOW_SUBSEG                                                                                    
		
		If AOW->( DbSeek(xFilial("AOW")+cEntidade+xFilial(cEntidade)+cCodigo+cLoja ) ) 
		
			While ( AOW->( !Eof() ) .And. AOW->AOW_FILIAL == xFilial("AOW") .And. AOW->AOW_ENTIDA == cEntidade .And.;
				    AOW->AOW_FILENT == xFilial(cEntidade) .And. AOW->AOW_CODCNT == cCodigo .And. AOW->AOW_LOJCNT == cLoja ) 
				
				If AOW->AOW_CODSEG <> cCodSegPri
					RecLock("AOW", .F.)
			  		AOW->( DbDelete() )
				  	AOW->( MsUnlock() )
				EndIf
				  			
				AOW->( DbSkip() )
			End
		
		EndIf
			
	EndIf
	
	//Limpa o array com os subsegmentos.
	aAOVMark := {}

Return Nil 

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA620MrkDel

Define que o subsegmento será deletado, caso o usuario desmarcar o mesmo na interface.

@sample	CRMA620MrkDel(oMdlAOVAll)

@param		oMdlAOVAll	- ModelGrid - Segmentos
		
@return		lRetorno - Verdadeiro / Falso
		
@author		Anderson Silva
@since		04/07/2015
@version	P12 
/*/
//------------------------------------------------------------------------------------------------
Static Function CRMA620MrkDel(oMdlAOVAll)
	Local lRetorno := .T.
	lRetorno := oMdlAOVAll:SetValue("AOV_MRKDEL",!oMdlAOVAll:GetValue("AOV_MARK"))
Return( lRetorno )

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA620VdPai

Valida o segmento pai.

@sample	CRMA620VdPai()

@param		Nenhum

@return		lRetorno - Verdadeiro / Falso
		
@author		Anderson Silva
@since		04/07/2015
@version	P12 
/*/
//------------------------------------------------------------------------------------------------
Function CRMA620VdPai()

	Local aArea		:= GetArea()
	Local aAreaAOV	:= AOV->( GetArea() )
	Local lRetorno	:= .T. 
	
	If FwFldGet("AOV_PRINC") <> "1"
		If FwFldGet("AOV_CODSEG") == FwFldGet("AOV_PAI")
			Help(,,"CRMA620VLD", ,STR0013 ,1 ,0 )	//"Segmento pai não pode ser igual ao Codigo do segmento."//"Segmento pai não pode ser igual ao código do segmento."
			lRetorno := .F. 
		EndIf
	Endif
	
	If	lRetorno	
	
		DbSelectArea("AOV")
		AOV->( DbSetOrder(1) )
			
		If	!AOV->( DbSeek(xFilial("AOV")+FwFldGet("AOV_PAI") ) )
			Help(,,"CRMA620VLD",,STR0014 ,1 ,0)	//STR0014//"Segmento pai não cadastrado."
			lRetorno := .F. 
		Else
			If AOV->AOV_PRINC == "2" .Or. AOV->AOV_MSBLQL == "1"
				Help(,,"CRMA620",,STR0015 ,1 ,0) //STR0015//"Código do Segmento invalido."
				lRetorno := .F. 
			EndIf
		EndIf
		
	EndIf	
	
	RestArea( aAreaAOV )
	RestArea( aArea )

Return(lRetorno)

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA620TOkSeg

Verifica se codigo do segmento esta igual ao segmento que foi atrelado no cad de amarração.

@sample		CRMA620TOkSeg(cCodSeg, aAOVMark)

@param		cCodSeg  - Codigo do segmento.
			aAOVMark - Array com os subsegmentos.

@return		lRetorno - Verdadeiro / Falso
		
@author		Anderson Silva
@since		04/07/2015
@version	P12 
/*/
//------------------------------------------------------------------------------------------------
Function CRMA620TOkSeg(cCodSeg, aAOVMark)

	Local lRetorno := .T.
	
	Default cCodSeg := ""
	
	IF !Empty(cCodSeg) .And. !Empty(aAOVMark) .And. aAOVMark[1][4] <> AllTrim(cCodSeg)
		Help( ,,"CRMA620VLD",,STR0016, 1, 0 ) //"Codigo do segmento diferente do segmento no cadastro da amarração."//"Código do segmento diferente do segmento no cadastro da amarração."
		lRetorno := .F.
	Endif				

Return(lRetorno) 


//----------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA620Blq
Valida se o Segmento está bloqueado para uso

@sample		CRMA620Blq(cCodSeg)

@param		   cCodSeg - codigo do segmento
				nCmpRet - campo para retorno - 1=codigo; 2=descricao

@return		cRetorno - codigo ou descricao do segmento
		
@author		Norberto Frassi Jr
@since		10/07/2015
@version	12
/*/
//----------------------------------------------------------------------------------------
Function CRMA620Blq(cCodSeg,nCmpRet)
	Local aArea    := GetArea()
	Local aAreaAOV := AOV->(GetArea())
	Local cRetorno := ""

	Default cCodSeg := ""
	Default nCmpRet := 1
	
	DbSelectArea("AOV")
	DbSetOrder(1)
	
	IF !Empty(cCodSeg) .And. MsSeek(xFilial("AOV")+cCodSeg) .And. AOV->AOV_MSBLQL <> "1"
		cRetorno := IIF(nCmpRet==1,cCodSeg,AOV->AOV_DESSEG) 
	Endif

	RestArea(aAreaAOV)
	RestArea(aArea)				

Return(cRetorno)

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA620Vld

Validaçao do Segmento.

@sample	CRMA620Vld(cCodSegPri)

@param		cCodSegPri  - Codigo do segmento.

@return	lRet - Verdadeiro / Falso
		
@author	Anderson Silva
@since		04/07/2015
@version	P12 
/*/
//------------------------------------------------------------------------------------------------

Function CRMA620Vld(cCodSegPri)
	
	Local lRet := .T.

	Default cCodSegPri := ""

	DbSelectArea("AOV")
	AOV->(DbSetOrder(1))	
	AOV->(DbSeek(xFilial("AOV")+cCodSegPri))
	If	AOV->AOV_PRINC == "2" .Or. AOV->AOV_MSBLQL == "1"
		Help( ,,STR0018,,STR0017, 1, 0 )	//"Atenção"//"Código do Segmento invalido."
		lRet := .F. 
	EndIf

Return(lRet)