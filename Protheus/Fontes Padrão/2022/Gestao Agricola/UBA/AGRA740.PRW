#INCLUDE "AGRA740.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA740
Cadastro de instrução de embarque

@param: Nil
@author: Aecio Ferreira Gomes
@since: 11/09/2012
@Uso: UBA
/*/
// -------------------------------------------------------------------------------------
Function AGRA740()
	Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DXN')
	oBrowse:SetDescription( STR0001 ) //"Instrução de Embarque"
	oBrowse:Activate()
Return

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA740
Menu Pardao da Rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 31/10/2012
@Uso: AGRA740
/*/
// -------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0012 Action 'VIEWDEF.AGRA740' OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0013 Action 'VIEWDEF.AGRA740' OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina Title STR0014 Action 'VIEWDEF.AGRA740' OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina Title STR0015 Action 'VIEWDEF.AGRA740' OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina Title STR0016 Action 'VIEWDEF.AGRA740' OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA740
Retorna o modelo de Dados da rotina de Instrução de Embarque

@param: Nil
@author: Aecio Ferreira Gomes
@since: 31/10/2012
@Uso: AGRA740
/*/
// -------------------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel   	:= Nil
	Local oStruDXN 	:= FwFormStruct( 1, "DXN" )//Instrução de Embarque
	Local oStruDXO 	:= FwFormStruct( 1, "DXO" )//Itens da Instrução de Embarque

	oStruDXO:SetProperty( 'DXO_SAFRA' , MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD, "DXN->DXN_SAFRA"))
	  
	oModel := MpFormModel():New( 'AGRA740',/*cPre*/, {|oMdl| AGRA740POS(oMdl)}, {|oMdl| AGRA740GRV(oMdl)}, /*bCancel*/ )
	oModel:SetDescription( STR0002 ) //'Modelo de dados da Instrução de Embarque'

	// Adiciona estrutura do cabecallho no modelo de dados 
	oModel:AddFields( 'MdFieldDXN', /*cOwner*/, oStruDXN )
	oModel:GetModel( 'MdFieldDXN' ):SetDescription( STR0003 ) //'Dados da Instrução de Embraque'

	// Adiciona estrutura da Grid no modelo de dados   
	oModel:AddGrid( 'MdGridDXO', 'MdFieldDXN', oStruDXO, { |a,b,c,d,e,f| Prelinha(a,b,c,d,e,f) },{ || AGRA740VLD()} )
	oModel:GetModel( "MdGridDXO" ):SetDescription( STR0004 ) //'Dados dos Itens da Instrução de Embarque'

	// Seta Relacionamento
	oModel:SetRelation( 'MdGridDXO', { { 'DXO_FILIAL', 'xFilial( "DXO" )' }, { 'DXO_NUMIE', 'DXN_CODIGO' } }, DXO->( IndexKey( ) ) )

	// Seta Chave Primaria 
	oModel:SetPrimaryKey( {"DXN_FILIAL","DXN_CODIGO"} )	
	oModel:SetVldActivate({|oMdl| AGRA740PRE(oMdl)})
		
	// Valida apos a Ativação do model
	oModel:SetActivate( { |oMdl| AGR740ACTV(oMdl) } )
Return oModel

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA740
Retorna Modelo de visualização da rotina de Instrução de Embarque

@param: Nil
@author: Aecio Ferreira Gomes
@since: 31/10/2012
@Uso: AGRA740
/*/
// -------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FwLoadModel( "AGRA740" )
	Local oStruDXN 	:= FwFormStruct( 2, "DXN" ) // Instrução de Embarque
	Local oStruDXO 	:= FwFormStruct( 2, "DXO", {|cCampo| !(AllTRim(cCampo) $ "DXO_SAFRA" )}  ) // Itens da Instrução de Embarque

	//oStruDXN:RemoveField( 'DXN_CODUNB' ) // Remove campos da estrurura da view

	// Instancia a View
	oView := FwFormView():New()

	// Seta o model
	oView:SetModel( oModel )

	// Adiciona os campos na estrutura da View
	oView:AddField( 'VIEW_DXN', oStruDXN, 'MdFieldDXN' )
	oView:AddGrid( 'VIEW_DXO' , oStruDXO, 'MdGridDXO')

	// Cria o Box
	oView:CreateHorizontalBox( 'SUP', 20 )
	oView:CreateHorizontalBox( 'INF', 80 )

	oStruDXN:SetProperty("DXN_DATA",MVC_VIEW_CANCHANGE,.F.)
	oStruDXN:SetProperty("DXN_HORA",MVC_VIEW_CANCHANGE,.F.)

	// Seta Owner
	oView:SetOwnerView( 'VIEW_DXN', 'SUP' )
	oView:SetOwnerView( 'VIEW_DXO', 'INF' )

	// Seta o campo incremental da Grid
	oView:AddIncrementField( 'VIEW_DXO', 'DXO_ITEM' )

Return oView

/**-------------------------------------------------------------------
{Protheus.doc} PreLinha
Pré validação da grid

@author Aécio Ferreira Gomes
@since 18/12/2012
@version 1.0
-------------------------------------------------------------------**/
Static Function PreLinha(oMdGridDXO, nLine, cAction, cField, xValueNew, xValueOld)
	Local lRet 		:= .T.
	Local nOperac 	:= oMdGridDXO:GetOperation()
	
	DO CASE
		CASE nOperac == MODEL_OPERATION_UPDATE
		If cField == "DXO_CODRES"
	
			If cAction ==  "SETVALUE" .And. !Empty(xValueOld)
				If xValueNew # xValueOld
					lRet := oMdGridDXO:GetValue("DXO_QTDEMB") == 0
				EndIf
	
			ElseIf cAction == "DELETE"
				lRet := oMdGridDXO:GetValue("DXO_QTDEMB") == 0
			EndIf
	
			If !lRet
				Help("",1,STR0005,, STR0006,1,0) //'Atenção'###"O código da reserva para este item não pode ser alterado, pois já existem quantidade embarcadas."
			EndIf
	
		EndIf
	
	ENDCASE

Return(lRet)

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGR740ACTV()
Checagem de Itens Embarcados para Liberar Exclusao

@param: Nil
@author: Bruna Rocio
@since: 15/09/2016
@Uso: AGRA740
/*/
// -------------------------------------------------------------------------------------

Static Function AGR740ACTV(oModel)
	Local lRet	  := .T.
	Local aArea   := GetArea()   
	Local nOperac := oModel:GetOperation() 
	
	If nOperac == MODEL_OPERATION_INSERT
		oModel:GetModel('MdFieldDXN'):SetValue('DXN_DATA',dDatabase)
		oModel:GetModel('MdFieldDXN'):SetValue('DXN_HORA',Substr( Time(), 1, 5 ))
	EndIf
		
	RestArea(aArea)
Return lRet

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA740PRE()
Checagem de Itens Embarcados para Liberar Exclusao

@param: Nil
@author: Joaquim Burjack
@since: 19/05/2014
@Uso: AGRA740
/*/
// -------------------------------------------------------------------------------------
static Function AGRA740PRE(oModel)
	Local lRet		 := .T.
	Local nOperac 	 := oModel:GetOperation()
	Local QtdEmb     := 0

	If nOperac == MODEL_OPERATION_DELETE
		dbSelectArea("DXO")
		DXO->(dbSetOrder(1))
		DXO->(dbSeek(xFilial("DXO")+DXN->DXN_CODIGO))
		While !DXO->(Eof()) .And. DXO->DXO_FILIAL == xFilial("DXO");
		.And. DXO->DXO_NUMIE == DXN->DXN_CODIGO

			QtdEmb =+ DXO->DXO_QTDEMB
			DXO->(dbSkip())
		EndDo

		lRet:= QtdEmb == 0
		if lRet == .F.
			Help("",1,"Atenção",,"Instrução com Itens Embarcados, nao será possivel a exclusão!",1,0)
		endif
	endif

Return (lRet)

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA740POS
Gravação dos dados

@param: Nil
@author: Aecio Ferreira Gomes
@since: 01/11/2012
@Uso: AGRA740
/*/
// -------------------------------------------------------------------------------------
Static Function AGRA740POS(oModel)
	Local lRet 			:= .T.
	Local oMdGridDXO	:= oModel:GetModel("MdGridDXO")
	Local nOperac 		:= oModel:GetOperation()
	Local nX			:= 0
	Local cAliasDXT     := GetNextAlias()
	Local lDXT          := .F.

	For nX := 1 To oMdGridDXO:Length()

		If oMdGridDXO:isDeleted(nX)

			If Select(cAliasDXT) > 0
				(cAliasDXT)->(dbCloseArea())
			EndIf

			BeginSql Alias cAliasDXT
			Select * From 
			%Table:DXT% DXT
			WHERE DXT.%notDel%
			AND DXT_FILIAL = %xFilial:DXK%
			AND DXT_NUMIE  = %exp:FwFldGet("DXN_CODIGO")%
			AND DXT_ITEMIE = %exp:oMdGridDXO:GetValue("DXO_ITEM")%
			EndSQL

			dbSelectArea(cAliasDXT)
			(cAliasDXT)->( dbGoTop() )

			If (cAliasDXT)->(!Eof())
				lDXT := .T.
			End	

			(cAliasDXT)->( DbCloseArea() )

			If lDXT
				lRet := .F.
				Help(,,STR0018,, STR0019,1,0) 
			Endif
		Endif

		Do Case
			Case nOperac == MODEL_OPERATION_INSERT
			// Posiciona no item da reserva e valida o saldo disponivel
			If DXQ->(dbSeek(xFilial("DXQ")+oMdGridDXO:GetValue("DXO_CODRES")+oMdGridDXO:GetValue("DXO_ITEMRS") ) )
				If oMdGridDXO:GetValue("DXO_QTDFD") > DXQ->DXQ_SLDISP
					lRet := .F.
					Help(,,'Atenção',, STR0007,1,0) //"O saldo da instrução de embarque não pode ser superior ao saldo disponivel da reserva"
				EndIf
			EndIf

			Case nOperac == MODEL_OPERATION_UPDATE
			// Posiciona no item atual
			If DXO->(dbSeek(xFilial("DXO")+FwFldGet("DXN_CODIGO")+oMdGridDXO:GetValue("DXO_ITEM")))
				// Válida se houve alteração no item para calcular a diferença de saldos da instrução
				If oMdGridDXO:GetValue("DXO_CODRES")+oMdGridDXO:GetValue("DXO_ITEMRS") ==  DXO->(DXO_CODRES+DXO_ITEMRS)
					nDif	:= (oMdGridDXO:GetValue("DXO_QTDFD") - DXO->DXO_QTDFD)
					nQuant	:= nDif
				Else
					nQuant	:= oMdGridDXO:GetValue("DXO_QTDFD")
				EndIf
			Else
				nQuant	:= oMdGridDXO:GetValue("DXO_QTDFD")
			EndIf

			// Posiciona no item da reserva e valida o saldo disponivel
			If DXQ->(dbSeek(xFilial("DXQ")+oMdGridDXO:GetValue("DXO_CODRES")+oMdGridDXO:GetValue("DXO_ITEMRS") ) )
				If nQuant > DXQ->DXQ_SLDISP
					lRet := .F.
					Help(,,'Atenção',, STR0007,1,0) //"O saldo da instrução de embarque não pode ser superior ao saldo disponivel da reserva"
				EndIf
			EndIf

		EndCase

	Next nX

Return(lRet)
// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA740GRV
Gravação dos dados

@param: Nil
@author: Aecio Ferreira Gomes
@since: 01/11/2012
@Uso: AGRA740
/*/
// -------------------------------------------------------------------------------------
Static Function AGRA740GRV(oModel)
	Local aAreaDXQ	:= DXQ->(GetArea())
	Local aAreaDXO	:= DXO->(GetArea())
	Local oMdGridDXO:= oModel:GetModel("MdGridDXO")
	Local nOperac 	:= oModel:GetOperation()
	Local lRet		:= .T.
	Local nX		:= 0

	lRet := AGRA740VLD()
	If lRet
		
		DXQ->(dbSetOrder(1)) //Reserva+Item
		DXO->(dbSetOrder(1)) //IE+ITEM	
		BEGIN TRANSACTION

			For nX := 1 To oMdGridDXO:Length()
				oMdGridDXO:GoLine( nX )
				Do Case
					Case nOperac == MODEL_OPERATION_INSERT

						// Atualiza o Saldo da Reserva
						If DXQ->( dbSeek( xFilial("DXQ")+oMdGridDXO:GetValue("DXO_CODRES")+oMdGridDXO:GetValue("DXO_ITEMRS") ) )
							RecLock("DXQ", .F.)
							If !oMdGridDXO:IsDeleted()
								DXQ_SLDISP := ( DXQ->DXQ_SLDISP - oMdGridDXO:GetValue("DXO_QTDFD") )
							EndIf
							MsUnlock()
						EndIf

						

					Case nOperac == MODEL_OPERATION_UPDATE
						
						//Posiciona no item da instrução
						If DXO->(dbSeek(xFilial("DXO")+FwFldGet("DXN_CODIGO")+oMdGridDXO:GetValue("DXO_ITEM"))) // Intrução+Item
	
							// Valida se a reserva foi alterada
							If oMdGridDXO:GetValue("DXO_CODRES", nX)+oMdGridDXO:GetValue("DXO_ITEMRS", nX) ==  DXO->(DXO_CODRES+DXO_ITEMRS)
	
								// Atualiza o saldo da reserva
								If DXQ->(dbSeek(xFilial("DXQ")+DXO->(DXO_CODRES+DXO_ITEMRS)))
									RecLock("DXQ", .F.)
									If oMdGridDXO:IsDeleted()
										DXQ_SLDISP := ( DXQ->DXQ_SLDISP + oMdGridDXO:GetValue("DXO_QTDFD") )
									Else
										DXQ_SLDISP := (DXQ->DXQ_SLDISP - (oMdGridDXO:GetValue("DXO_QTDFD") - DXO->DXO_QTDFD ) )
									EndIf
									MsUnlock()
								EndIf
	
							Else
	
								// Atualiza o Saldo da Reserva
								If DXQ->( dbSeek( xFilial("DXQ")+oMdGridDXO:GetValue("DXO_CODRES")+oMdGridDXO:GetValue("DXO_ITEMRS") ) )
									RecLock("DXQ", .F.)
									If oMdGridDXO:IsDeleted()
										DXQ_SLDISP := ( DXQ->DXQ_SLDISP + oMdGridDXO:GetValue("DXO_QTDFD") )
									Else
										DXQ_SLDISP := ( DXQ->DXQ_SLDISP - oMdGridDXO:GetValue("DXO_QTDFD") )
									EndIf
									MsUnlock()
								EndIf
	
							EndIf
						EndIf

					Case nOperac == MODEL_OPERATION_DELETE

					// Posiciona na reserva para atualizar o saldo disponivel
					If DXQ->(dbSeek(xFilial("DXQ")+oMdGridDXO:GetValue("DXO_CODRES")+oMdGridDXO:GetValue("DXO_ITEMRS")))
						RecLock("DXQ",.F.)
						DXQ_SLDISP := ( DXQ->DXQ_SLDISP + oMdGridDXO:GetValue("DXO_QTDFD") )
						MsUnlock()
					EndIf
				EndCase

			Next nX

			FWFormCommit( oModel )

		END TRANSACTION()
		RestArea(aAreaDXQ)
		RestArea(aAreaDXO)
	Endif
Return lRet

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGR740WHEN()
Validação de edição dos campos

@param: Nil
@author: Aecio Ferreira Gomes
@since: 01/11/2012
@Uso: AGRA740
/*/
// -------------------------------------------------------------------------------------
Function AGR740WHEN()
	Local oModel    := FwModelActive()
	Local aHeader 	:= oModel:GetModel("MdGridDXO"):aHeader
	Local aCols		:= oModel:GetModel("MdGridDXO"):aCols
	Local nPosRes	:= aScan(aHeader, {|x| x[2] == "DXO_CODRES"})
	Local lRet 		:= .T.

	If ValType(oModel) <> "o" .And. nPosRes > 0

		lRet := !aScan(aCols, {|x| !Empty(x[nPosRes]) } ) > 0

	EndIf

Return(lRet)

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA740FLT()
Filtro da Consulta padrão DXQDXO

@param: Nil
@author: Aecio Ferreira Gomes
@since: 19/04/2013
@Uso: AGRA740
/*/
// -------------------------------------------------------------------------------------
Function AGRA740FLT()
	Local lRet := .T.

	lRet := DXQ->DXQ_SLDISP > 0

	If lRet .And. (lRet := DXP->(dbSeek(xFilial("DXP")+DXQ->DXQ_CODRES)) )
		lRet := AllTrim(FwFldGet("DXN_CLIENT"))+ AllTrim(FwFldGet("DXN_LOJA"))+ AllTrim(FwFldGet("DXN_SAFRA")) /*+ FwFldGet("DXO_BLOCO")*/ = AllTrim( DXP->DXP_CLIENT) + AllTrim(DXP->DXP_LJCLI) + AllTrim(DXP->DXP_SAFRA) /*+ DXQ->(DXQ_BLOCO)*/
	EndIf

Return(lRet)

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA740CPO()
Filtro da Consulta padrão DXQDXO

@param: Nil
@author: Aecio Ferreira Gomes
@since: 19/04/2013
@Uso: AGRA740
/*/
// -------------------------------------------------------------------------------------
Function AGRA740CPO()
	Local aArea		  := GetArea()
	Local oModel	  := FwModelActive()
	Local oMdFieldDXN := oModel:GetModel("MdFieldDXN")
	Local oMdGridDXO  := oModel:GetModel("MdGridDXO")
	Local aLines	  := FwSaveRows()
	Local nCont		  := 0
	Local nX		  := 0
	Local lRet		  := .T.

	Local cCodRes	:= FwFldGet("DXO_CODRES")
	Local cItemRes	:= FwFldGet("DXO_ITEMRS")
	Local cBloco    := FwFldGet("DXO_BLOCO")
	Local cSafra	:= oMdFieldDXN:GetValue("DXN_SAFRA")
	Local cCodCli   := oMdFieldDXN:GetValue("DXN_CLIENT")
	Local cLojCli 	:= oMdFieldDXN:GetValue("DXN_LOJA")

	oMdGridDXO:LoadValue("DXO_SAFRA",FwFldGet("DXN_SAFRA"))
	DO CASE
		CASE "DXO_CODRES" $ ReadVar()

			If !Empty(FwFldGet("DXO_CODRES"))
	
				// Valida se o registro informado existe na base de dados
				lRet := ExistCPO("DXQ",FwFldGet("DXO_CODRES")+If( !Empty( FwFldGet("DXO_ITEMRS") ), FwFldGet("DXO_ITEMRS"), ""), 1)
				oMdGridDXO:LoadValue("DXO_SAFRA",FwFldGet("DXN_SAFRA"))
	
				// Valida se a reserva informada pertence ao cliente+loja+safra da instrução de embarque
				If lRet .And. (lRet := DXP->(dbSeek(xFilial("DXP")+oMdGridDXO:GetValue("DXO_CODRES"))) )
	
					lRet := Alltrim(FwFldGet("DXN_CLIENT")) + Alltrim(FwFldGet("DXN_LOJA")) + Alltrim(FwFldGet("DXN_SAFRA")) == AllTrim(DXP->DXP_CLIENT) + AllTrim(DXP->DXP_LJCLI) + AllTrim(DXP->DXP_SAFRA)
		
					If !lRet
						Help(,,'Atenção',, STR0008,1,0) //"A reserva informada não pertence o cliente da instrução de embarque"
					EndIf
				EndIf
	
				// Valida o saldo disponivel da resreva
				If lRet .And. DXQ->( dbSeek( xFilial("DXQ")+cCodRes+cItemRes ) )
					If !(lRet := DXQ->DXQ_SLDISP > 0)
						Help(,,'Atenção',, STR0009,1,0) //"Não Existem saldos disponiveis da reserva!"
					EndIf
				EndIf
	
				// Valida para não permitir incluir mais que um registro de uma mesma reserva e item
				If lRet
					For nX := 1 To oMdGridDXO:Length()
	
						oMdGridDXO:Goline(nX)
	
						If oMdGridDXO:IsDeleted()
							Loop
						EndIf
	
						If oMdGridDXO:GetValue("DXO_CODRES")+oMdGridDXO:GetValue("DXO_ITEMRS") == cCodRes+cItemRes
							nCont++
						EndIf
	
						If !(lRet := nCont <= 1)
							Help(,,'Atenção',, STR0010,1,0)	//"Esta reserva já pertence a instrução de embarque!"
						EndIf
					Next
				EndIf
			Endif

		CASE "DXO_ITEMRS" $ ReadVar()

			// Valida se o registro existe na base de dados
			lRet := ExistCPO("DXQ",cCodRes+cItemRes, 1)
			oMdGridDXO:LoadValue("DXO_SAFRA",FwFldGet("DXN_SAFRA"))
	
			// Valida o saldo da resreva
			If lRet .And. DXQ->( dbSeek( xFilial("DXQ")+cCodRes+cItemRes  ) )
				If !(lRet := DXQ->DXQ_SLDISP > 0)
					Help(,,'Atenção',, STR0009,1,0) //"Não Existem saldos disponiveis da reserva!"
				EndIf
			EndIf
	
			// Valida para não permitir incluir mais que um registro de uma mesma reserva e item
			If lRet
				For nX := 1 To oMdGridDXO:Length()
					oMdGridDXO:Goline(nX)
	
					If oMdGridDXO:IsDeleted()
						Loop
					EndIf
	
					If oMdGridDXO:GetValue("DXO_CODRES")+oMdGridDXO:GetValue("DXO_ITEMRS") == cCodRes+cItemRes
						nCont++
					EndIf
	
					If !(lRet := nCont <= 1)
						Help(,,'Atenção',, STR0010,1,0) //"Esta reserva já pertence a instrução de embarque!"
					EndIf
				Next
			EndIf

			If lRet
				FwFldPut("DXO_QTDFD"  , DXQ->DXQ_SLDISP	)
			EndIf
		CASE "DXO_BLOCO" $ ReadVar()


			IF (lRet := EXISTCPO("DXD",M->DXN_SAFRA +M->DXO_BLOCO,1))
				oMdGridDXO:LoadValue("DXO_SAFRA",FwFldGet("DXN_SAFRA"))
			
				DbSelectArea("DXD")
				dbsetorder(1)
				if (dbSeek(xFilial("DXD")+M->DXN_SAFRA +M->DXO_BLOCO))
					FwFldPut("DXO_TIPO"  , DXD->DXD_CLACOM)				
				endif
	
				// Valida para não permitir incluir mais que um registro de uma mesma reserva e item
				If lRet
					For nX := 1 To oMdGridDXO:Length()
						oMdGridDXO:Goline(nX)
	
						If oMdGridDXO:IsDeleted()
							Loop
						EndIf
	
						If oMdGridDXO:GetValue("DXO_BLOCO") == cBloco .And. oMdGridDXO:GetValue("DXO_CODRES")+oMdGridDXO:GetValue("DXO_ITEMRS") == cCodRes+cItemRes 
							nCont++
						EndIf
	
						If !(lRet := nCont <= 1)
							Help(,,'Atenção',, STR0010,1,0) //"Esta reserva já pertence a instrução de embarque!"
						EndIf
					Next
				EndIf
	
				If lRet
	
					If Select("TRB001") > 0
						TRB001->(dbCloseArea())
					Endif
					cQuery := ""		
					cQuery += "SELECT DXP_CODIGO, DXQ_ITEM, DXP_CLIENT, DXP_LJCLI, DXQ_TIPO, DXQ_SLDISP" 
					cQuery += " FROM " + RETSQLNAME("DXP")+ " DXP " 
					cQuery += " INNER JOIN " +  RETSQLNAME("DXQ") + " DXQ ON (DXP_FILIAL = DXQ_FILIAL AND DXP_CODIGO = DXQ_CODRES) "
					cQuery += " INNER JOIN " +  RETSQLNAME("DXD") + " DXD ON (DXQ_FILIAL = DXD_FILIAL AND DXP_SAFRA = DXD_SAFRA AND DXQ_BLOCO = DXD_CODIGO) "
					cQuery += " Where "
					cQuery += " DXP.D_E_L_E_T_  = ' ' AND DXQ.D_E_L_E_T_ = ' ' AND DXD.D_E_L_E_T_ = ' '  AND DXP_FILIAL = '"+xFILIAL("DXP")+ "' "
					cQuery += " AND DXP_CLIENT = '" + cCodCli + "'"
					cQuery += " AND DXP_LJCLI = '" + cLojCli + "'"
					cQuery += " AND DXD_SAFRA = '" + cSafra + "'"
					cQuery += " AND DXQ_BLOCO = '" + cBloco + "'"
					cQuery += " AND DXQ_CODRES = '" + cCodRes + "'"
					cQuery := ChangeQuery(cQuery)
	
					dbUseArea(.t., 'TOPCONN', TCGenQry(,,cQuery),'TRB001', .f., .t.)
					dbGoTop()
					If .Not. TRB001->(Eof())
						nCount := 0
						While .Not. TRB001->(Eof())
							nCount ++
							TRB001->(dbSkip())
						EndDo
	
						If nCount = 1
							TRB001->(dbGoTop())
							FwFldPut("DXO_CODRES"  , TRB001->( DXP_CODIGO )	)
							FwFldPut("DXO_ITEMRS"  , TRB001->( DXQ_ITEM )	)
							FwFldPut("DXO_QTDFD"   , TRB001->(DXQ_SLDISP)	)
							FwFldPut("DXO_CODCTP"  , Space(TamSx3("DXO_CODCTP")[1] )	)
							FwFldPut("DXO_ITECTP"  , Space(TamSx3("DXO_ITECTP")[1] )	)
						Else
							FwFldPut("DXO_CODRES"  , Space(TamSx3("DXO_CODRES")[1] )	)
							FwFldPut("DXO_ITEMRS"  , Space(TamSx3("DXO_ITEMRS")[1] )	)
							FwFldPut("DXO_QTDFD"   , 0	)
							FwFldPut("DXO_CODCTP"  , Space(TamSx3("DXO_CODCTP")[1] )	)
							FwFldPut("DXO_ITECTP"  , Space(TamSx3("DXO_ITECTP")[1] )	)
							MsgInfo("Este bloco possui mais de uma reserva. Favor verificar a reserva a ser escolhida.")
						Endif
					Endif
	
					TRB001->(dbCloseArea())
				EndIf
			Endif
		CASE "DXO_QTDFD" $ ReadVar()
			oMdGridDXO:LoadValue("DXO_SAFRA",FwFldGet("DXN_SAFRA"))
			If !( lRet :=  oMdGridDXO:GetValue("DXO_QTDFD") >= oMdGridDXO:GetValue("DXO_QTDEMB") )
				Help(,,'ATENÇÃO',, STR0011,1,0) //"A quantidade de fardos da instrução não pode ser inferior a quantidade de fardos embarcados!"
			EndIf
		
	ENDCASE
	
	RestArea(aArea)
	FwRestRows(aLines)
Return(lRet)


/*/{Protheus.doc} AGRA740VLD
//Validação de Limite de Fardos
@author bruna.rocio
@since 30/08/2016
@version undefined

@type function
/*/
Function AGRA740VLD()
	Local oModel    		:= FwModelActive()
	Local oMdGridDXO		:= oModel:GetModel("MdGridDXO")
	Local oMdFieldDXN		:= oModel:GetModel("MdFieldDXN")
	Local nOperac 	 		:= oModel:GetOperation()
	Local nX  := 0
	Local Qtd 		:= 0
	Local lRet 	:= .T.

	If nOperac != MODEL_OPERATION_DELETE
	
		For nX := 1 To oMdGridDXO:Length()
			oMdGridDXO:GoLine( nX )
			oMdGridDXO:LoadValue('DXO_SAFRA',oMdFieldDXN:GetValue("DXN_SAFRA"))
			if !oMdGridDXO:isdeleted( nX )
				Qtd += oMdGridDXO:GetValue("DXO_QTDFD", nX)
			endif
		Next (nX)
		lRet:= Qtd <= val(alltrim(oMdFieldDXN:GetValue("DXN_QTD")))
		
		If !lRet
			Help("",1,"Atenção",,"Ultrapassado o limite de fardos!",1,0)
		Endif
	EndIf
Return(lRet)


/*/{Protheus.doc} AGRA740CTR
//Filtro de Contrato de Parceria
@author bruna.rocio
@since 30/08/2016
@version undefined
@param _cCodCtr, , descricao
@type function
/*/
Function AGRA740CTR(_cCodCtr)
	Local oModel    		:= FwModelActive()
	Local oMdGridDXO		:= oModel:GetModel("MdGridDXO")
	Local oMdFieldDXN		:= oModel:GetModel("MdFieldDXN")
	Local nLinha 			:= oMdGridDXO:nLine
	Local cTipoAlg			:= ""
	Local cCodCli			:= oMdFieldDXN:GetValue("DXN_CLIENT")
	Local cLojCli			:= oMdFieldDXN:GetValue("DXN_LOJA")
	Local cRet 				:= ""

	oMdGridDXO:GoLine( nLinha )
	cTipoAlg := oMdGridDXO:GetValue("DXO_TIPO")

	cRet := "@#ADB_CODCLI = '" + cCodCli + "' .And. ADB_LOJCLI = '" + cLojCli + "'@#"

Return(cRet)


/*/{Protheus.doc} AGRA740DXD
//Função de consulta de Blocos
@author bruna.rocio
@since 30/08/2016
@version undefined
@param _cAlias, , descricao
@type function
/*/
Function AGRA740DXD(_cAlias)

	Local oModel        := FwModelActive()

	Local oMdFieldDXN	:= oModel:GetModel("MdFieldDXN")
	Local cCodCli		:= oMdFieldDXN:GetValue("DXN_CLIENT")
	Local cLojCli		:= oMdFieldDXN:GetValue("DXN_LOJA")
	Local cSafra		:= oMdFieldDXN:GetValue("DXN_SAFRA")
	Local nOpcao		:= 0
	Local aAreaAtu      := GetArea()
	Private oDlg        := Nil
	Private oBrowse     := Nil
	Private aItens      := Array(1, 7)

	Private cCampo		:= ReadVar()
	Public __cCodigo	:= &( cCampo )
	Public __cTipo		:= Space(TamSx3("DXQ_TIPO")[1])
	Default _cAlias 	:= Alias()

	DEFINE MSDIALOG oDlg TITLE "Blocos Reservados" PIXEL FROM 180,180 TO 550,700

	oBrowse := TCBrowse():New( 01, 01, 260, 156, , {'Codigo', 'Safra', 'Tipo', 'Produtor', 'Loja', 'Quantidade',''} ,{50,50,50,50,50,50,50},oDlg,,,,,{|| nOpcao := oBrowse:nAt, oDlg:End() },,,,,,,.F.,,.T.,,.F.,,, )

	oBrowse:AddColumn( TCColumn():New( 'Codigo' 		, { || aItens[oBrowse:nAt,1] }	,,,,"LEFT",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TCColumn():New( 'Safra'   		, { || aItens[oBrowse:nAt,2] }	,,,,"LEFT",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TCColumn():New( 'Tipo'			, { || aItens[oBrowse:nAt,3] }	,,,,"LEFT",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TCColumn():New( 'Produtor'		, { || aItens[oBrowse:nAt,4] }	,,,,"LEFT",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TCColumn():New( 'Loja' 			, { || aItens[oBrowse:nAt,5] }	,,,,"LEFT",,.F.,.T.,,,,.F.,) )

	AGRA740ITS( cCodCli, cLojCli, cSafra )

	TButton():New( 170, 012, "Confirmar"		, oDlg,{|| nOpcao := oBrowse:nAt, oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	TButton():New( 170, 054, "Cancelar"			, oDlg,{|| nOpcao := 0,           oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )


	ACTIVATE DIALOG oDlg CENTERED

	If nOpcao > 0
		__cCodigo := aItens[ nOpcao, 1 ]
		__cTipo   := aItens[ nOpcao, 3 ]
	EndIf

	RestArea(aAreaAtu)
Return(.t.)


/*/{Protheus.doc} AGRA740ITS
@author bruna.rocio
@since 30/08/2016
@version undefined
@param cCodCli, characters, descricao
@param cLojCli, characters, descricao
@param cSafra, characters, descricao
@type function
/*/
Static Function AGRA740ITS(cCodCli, cLojCli, cSafra)
	Local aAreaAtu := GetArea()
	Local cQuery   := ''
	Local aTempo   := Array( 0 )
	Local nX      := 1

	If Select("TRB001") > 0
		TRB001->(dbCloseArea())
	Endif

	cQuery += "SELECT DISTINCT DXP_CLIENT, DXP_LJCLI, DXQ_TIPO, " 
	cQuery += " DXD_SAFRA, DXD_CODIGO, DXD_CLACOM, DXD_QTDMAX, DXD_PRDTOR, DXD_LJPRO "
	cQuery += " FROM " + RETSQLNAME("DXP")+ " DXP " 
	cQuery += " INNER JOIN " +  RETSQLNAME("DXQ") + " DXQ ON (DXP_FILIAL = DXQ_FILIAL AND DXP_CODIGO = DXQ_CODRES) "
	cQuery += " INNER JOIN " +  RETSQLNAME("DXD") + " DXD ON (DXQ_FILIAL = DXD_FILIAL AND DXP_SAFRA = DXD_SAFRA AND DXQ_BLOCO = DXD_CODIGO) "
	cQuery += " Where "
	cQuery += " DXP.D_E_L_E_T_ = ' ' AND DXQ.D_E_L_E_T_ = ' ' AND DXD.D_E_L_E_T_ <> '*' AND DXP_FILIAL = '"+xFILIAL("DXP")+ "' "
	cQuery += " AND DXP_CLIENT = '" + cCodCli + "'"
	cQuery += " AND DXP_LJCLI = '" + cLojCli + "'"
	cQuery += " AND DXD_SAFRA = '" + cSafra + "'"
	cQuery += " AND DXQ_SLDISP > 0 "
	cQuery += " Order by"
	cQuery += " DXD_CODIGO, DXD_SAFRA"

	dbUseArea(.t., 'TOPCONN', TCGenQry(,,cQuery),'TRB001', .f., .t.)
	dbGoTop()
	While .Not. Eof()

		aAdd( aTempo, {} )
		aAdd( aTempo[nX], DXD_CODIGO ) 			// [1] Codigo Bloco
		aAdd( aTempo[nX], DXD_SAFRA ) 			// [2] Safra
		aAdd( aTempo[nX], DXQ_TIPO ) 			// [3] Tipo
		aAdd( aTempo[nX], DXD_PRDTOR ) 			// [4] Produtor
		aAdd( aTempo[nX], DXD_LJPRO ) 			// [5] Loja

		nX++
		dbSkip()
	EndDo
	dbCloseArea()

	aItens := aClone( aTempo )
	oBrowse:SetArray( aItens )

	RestArea( aAreaAtu )
Return