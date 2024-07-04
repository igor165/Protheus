#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'GTPC300K.ch'


//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPC300K

Função utilizada para confirmar recurso por um periodo de data

@param		Nenhum
@since		18/04/2018
@version	P12
/*/
//------------------------------------------------------------------------------

Function GTPC300K()
	Local aButtons      := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0001},{.T.,STR0002},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Cancelar" //"Confirmar" //"Fechar"
	FWExecView( STR0003, 'VIEWDEF.GTPC300K', MODEL_OPERATION_INSERT, , { || .T. },,,aButtons,{|| GC300kFech()} )//STR0003 //"Confirmação de Recursos"

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef


@param		Nenhum
@since		18/04/2018
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function ViewDef()
Local oView			:= FwLoadView('GTPC300E')
Local oModel		:= oView:GetModel()
Local oStrGrd		:= oModel:GetModel('G55DETAIL'):GetStruct() 

oStrGrd:SetProperty('G55_MARK', MODEL_FIELD_VALID, {|oMdl,cCpo,xValue| VldRecurso(oMdl,xValue) })

oModel:SetCommit({|oMdl| Gc300kGrv(oMdl) })
SetViewStruct(oView)

oView:AddUserButton( STR0004, "", {|oView|G300kCMkAll(oView)}) //STR0004 //"Marque/Desmarque todos"

Return oView


//------------------------------------------------------------------------------
/*/{Protheus.doc} SetViewStruct

@param		Nenhum
@since		18/04/2018
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function SetViewStruct(oView)
Local oStrViwCab	:= oView:GetViewStruct('VW_GQEMASTER')
Local oStrViwGrd	:= oView:GetViewStruct('VW_G55DETAIL')
 
	oStrViwCab:AddField( 				  			  ; // Ord. Tipo Desc.
						"TPCONFIRM"  				, ; // [01] C Nome do Campo
						"99"  						, ; // [02] C Ordem
						STR0005 					, ; // [03] C Titulo do campo //"Tp Confirm?"
						STR0006 					, ; // [04] C Descrição do campo //"Tipo de Confirmação?"
						NIL   						, ; // [05] A Array com Help
						"COMBO"   					, ; // [06] C Tipo do campo
						"@!" 						, ; // [07] C Picture
						NIL    						, ; // [08] B Bloco de Picture Var
						""     						, ; // [09] C Consulta F3
						.T.    						, ; // [10] L Indica se o campo é editável
						NIL    						, ; // [11] C Pasta do campo
						NIL    						, ; // [12] C Agrupamento do campo
						GTPXCBox('GQE_TPCONF'),; // [13] A Lista de valores permitido do campo (Combo)
						NIL    						, ; // [14] N Tamanho Máximo da maior opção do combo
						NIL    						, ; // [15] C Inicializador de Browse
						.F.    						, ; // [16] L Indica se o campo é virtual
						NIL    						  ) // [17] C Picture Variável
	
	oStrViwGrd:AddField(	 				  			  ; // Ord. Tipo Desc.
						"G55_MARK",;				// [01]  C   Nome do Campo
						"00",;						// [02]  C   Ordem
						"",;						// [03]  C   Titulo do campo
						"",;						// [04]  C   Descricao do campo
						{STR0007},;					// [05]  A   Array com Help // STR0007 //"Selecionar"
						"CHECK",;					// [06]  C   Tipo do campo
						"",;						// [07]  C   Picture
						NIL,;						// [08]  B   Bloco de Picture Var
						"",;						// [09]  C   Consulta F3
						.T.,;						// [10]  L   Indica se o campo é alteravel
						NIL,;						// [11]  C   Pasta do campo
						"",;						// [12]  C   Agrupamento do campo
						NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
						NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
						NIL,;						// [15]  C   Inicializador de Browse
						.T.,;						// [16]  L   Indica se o campo é virtual
						NIL,;						// [17]  C   Picture Variavel
						.F.)						// [18]  L   Indica pulo de linha após o campo

	
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} GC300kFech

Função executada através do bloco de Cancelamento da Tela. Configura a View
como se não tivesse sido alterada. O MVC TURA067 não persiste dados em banco.

@param		Nenhum
@since		18/04/2018
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function GC300kFech() 

Local oView	:= FwViewActive()
		
oView:SetModified(.f.)
	
Return(.t.)

//------------------------------------------------------------------------------
/*/{Protheus.doc} Gc300kGrv
(long_description)
@type function
@author jacom
@since 18/04/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function Gc300kGrv(oMdl)
Local lRet			:= .F.
Local aArea			:= GetArea()

Local oMdlRec 		:= oMdl:GetModel( 'GQEMASTER' )
Local oMdlVia 		:= oMdl:GetModel( 'G55DETAIL' )

Local oMldMnt 		:= GC300GetMVC('M')
Local oViewMnt		:= GC300GetMVC('V')

Local oMdl300		:= FwLoadModel('GTPA300')
Local oMdlG55		:= oMdl300:GetModel('G55DETAIL')
Local oMdlGQE		:= oMdl300:GetModel('GQEDETAIL')

Local oMdl313		:= FwLoadModel('GTPA313')
Local oMdlGQK		:= oMdl313:GetModel('GQKMASTER')

Local oMdlMntGYN	:= Nil
Local oMdlMntG55	:= Nil
Local oMdlMntGQE	:= Nil
Local lMoAtive		:= .F.

Local aViagens		:= {}
Local n1			:= 0

Local nPosGYN		:= 0
Local nPosG55		:= 0

Local aErro			:= {}

Local lConf			:= .F.

oMdlGQK:GetStruct():SetProperty('GQK_LOCORI',MODEL_FIELD_OBRIGAT, .F.)
oMdlGQK:GetStruct():SetProperty('GQK_LOCDES',MODEL_FIELD_OBRIGAT, .F.)


If ValType( oViewMnt ) == "O" .and. oViewMnt:IsActive()
	oMdlMntGYN	:= oMldMnt:GetModel( 'GYNDETAIL' )
	oMdlMntG55	:= oMldMnt:GetModel( 'G55DETAIL' )
	oMdlMntGQE	:= oMldMnt:GetModel( 'GQEDETAIL' )
	lMoAtive	:= .T.
Endif
GYN->(DbSetOrder(1))//GYN_FILIAL+GYN_CODIGO


Begin Transaction
	For n1 := 1 to oMdlVia:Length()
		If oMdlVia:GetValue('G55_MARK',n1)
			If oMdlVia:GetValue('TABELA',n1) == 'GQE' 
				If (nPosGYN := aScan(aViagens,{|x| x[1]== oMdlVia:GetValue('G55_CODVIA',n1)})) > 0
					aAdd(aViagens[nPosGYN][2],{oMdlVia:GetValue('G55_SEQ',n1),oMdlRec:GetValue('GQE_RECURS')})
				Else
					aAdd(aViagens,{oMdlVia:GetValue('G55_CODVIA',n1),{{oMdlVia:GetValue('G55_SEQ',n1),oMdlRec:GetValue('GQE_RECURS')}}})
				Endif
			Else //GQK
				If oMdlVia:GetValue('G55TPDIA',n1) <> '1' //Se não for trabalhado (Viagem Especial)
					GQK->(DbSetOrder(1))//GQK_FILIAL, GQK_CODIGO, GQK_RECURS, GQK_TCOLAB, GQK_DTREF, GQK_DTINI, GQK_HRINI
					cChaveGQK	:= xFilial('GQK')+oMdlVia:GetValue('G55_CODVIA',n1)
				Else
					GQK->(DbSetOrder(6))//GQK_FILIAL+GQK_RECURS+DTOS(GQK_DTINI)+GQK_HRINI                                                                                                      
					cChaveGQK	:= xFilial('GQK')+SubStr(oMdlRec:GetValue('GQE_RECURS'),1,TamSx3('GQK_RECURS')[1])+;
									DtoS(oMdlVia:GetValue('G55_DTPART',n1))+oMdlVia:GetValue('G55_HRINI',n1)
									
				Endif	
					
				IF GQK->(DbSeek(cChaveGQK))
					oMdl313:SetOperation(MODEL_OPERATION_UPDATE)
					If oMdl313:Activate()
						oMdlGQK:SetValue('GQK_STATUS'	,If(oMdlRec:GetValue('TPCONFIRM') == '1','2','1' ))// 1= Não Confirmado -- diferente de 1 = confirmado
						oMdlGQK:SetValue('GQK_TPCONF'	,oMdlRec:GetValue('TPCONFIRM'))//Confirmado
						oMdlGQK:SetValue('GQK_USRCON'	,cUserName)//Login do usuário que confirmou
						If oMdl313:VldData()
							lRet := oMdl313:CommitData()
						Else
							lRet := .F.
						Endif	
						
						If !lRet
							aErro := oMdl313:GetErrormessage()
							DisarmTransaction()
							Exit
						Endif
						
						oMdl313:DeActivate()
					Else
						lRet := .F.
						aErro := oMdl313:GetErrormessage()
						DisarmTransaction()
						Exit
					Endif
				Else
					lRet := .F.
					aErro := oMdl313:GetErrormessage()
					aErro[5] := "NaoEncontrado"
					aErro[6] := STR0008 //"Não foi possivel localizar o registro informado"
				Endif
				
			Endif
		Endif
	Next
	
	For n1 := 1 to Len(aViagens)
		If GYN->(DbSeek(xFilial('GYN')+aViagens[N1][1]))
			oMdl300:SetOperation(MODEL_OPERATION_UPDATE)
			IF oMdl300:Activate()
				
				lConf := oMdlRec:GetValue('TPCONFIRM') <> '1'
				
				For nPosG55	:= 1 to Len(aViagens[N1][2])
					If oMdlG55:SeekLine({{'G55_SEQ',aViagens[N1][2][nPosG55][1]}})
						If oMdlGQE:SeekLine({{'GQE_RECURS',aViagens[N1][2][nPosG55][2]},{'GQE_TRECUR',oMdlRec:GetValue('GQE_TRECUR')},{'GQE_TERC',oMdlRec:GetValue('GQE_TERC')}} )
							lRet := oMdlGQE:SetValue('GQE_STATUS'	,IIF(lConf,'1','2' )) .and.; // 1= Não Confirmado -- diferente de 1 = confirmado
									oMdlGQE:SetValue('GQE_TPCONF'	,oMdlRec:GetValue('TPCONFIRM')) .and. ;//Confirmado
									oMdlGQE:SetValue('GQE_USRCON'	,cUserName)						//Login do usuário que confirmou
							If !lRet
								Exit
							Endif
						Endif
					Endif
				Next	
				If lRet .AND. !(oMdl300:VldData() .and. oMdl300:CommitData()) 
					lRet := .F.
				Endif	
				
				If !lRet
					aErro := oMdl300:GetErrormessage()
					DisarmTransaction()
					Exit
				EndIf
				oMdl300:DeActivate()
			Else
				lRet := .F.
				aErro := oMdl300:GetErrormessage()
				DisarmTransaction()
				Exit				
			Endif
		Endif
	Next
End Transaction

If lMoAtive
	For n1 := 1 to Len(aViagens)
		IF oMdlMntGYN:SeekLine({{'GYN_CODIGO',aViagens[n1][1]}})
			lConf := oMdlRec:GetValue('TPCONFIRM') <> '1'
			
			For nPosG55 := 1 To Len(aViagens[n1][2])
				If oMdlMntG55:SeekLine({{'G55_SEQ',aViagens[n1][2][nPosG55][1]}})
					If oMdlMntGQE:SeekLine({{'GQE_RECURS',aViagens[N1][2][nPosG55][2]},{'GQE_TRECUR',oMdlRec:GetValue('GQE_TRECUR')},{'GQE_TERC',oMdlRec:GetValue('GQE_TERC')}} )
						lRet := oMdlMntGQE:SetValue('GQE_STATUS', IIF(lConf,'1','2')) .and. oMdlMntGQE:SetValue('GQE_TPCONF', oMdlRec:GetValue('TPCONFIRM')) .and. oMdlMntGQE:SetValue('GQE_USRCON', cUserName)	
						If !lRet
							Exit
							aErro := oMldMnt:GetErrorMessage()
						Endif
					Endif
				Endif
			Next
		Endif
	Next
Endif
If !lRet
	If Len(aErro) > 0
		JurShowErro( aErro )
	EndIf
Endif

oMdl300:Destroy()
oMdl313:Destroy()

GTPDestroy(oMdl300)
GTPDestroy(oMdl313)
GTPDestroy(aErro)
RestArea(aArea)
Return lRet

/*/{Protheus.doc} G300kCMkAll
(long_description)
@type function
@author jacom
@since 18/04/2018
@version 1.0
@param oView, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function G300kCMkAll(oView)
Local oModel	:= oView:GetModel()
Local oMdlVia	:= oModel:GetModel('G55DETAIL') 
Local n1		:= 0
Local lCheck	:= If(!oMdlVia:GetValue('G55_MARK'),.T.,.F.) 

For n1 := 1 To oMdlVia:Length()
	oMdlVia:GoLine(n1)
	oMdlVia:SetValue('G55_MARK',lCheck)
Next 

oModel:GetErrorMessage(.T.)	

oMdlVia:GoLine(1)

Return

/*/{Protheus.doc} VldRecurso
(long_description)
@type function
@author jacom
@since 14/04/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param xValue, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldRecurso(oMdl,xValue)
Local lRet := .T.
Local oModel		:= oMdl:GetModel()
Local oMdlCab		:= oModel:GetModel("GQEMASTER")
Local oMdlGrd		:= oModel:GetModel("G55DETAIL")
Local aRetLog		:= {}
Local cRetLog		:= ""
Local cTabela		:= oMdlGrd:GetValue("TABELA")
Local lTerceiro		:= oMdlCab:GetValue('GQE_TERC') == '1'
Local cTpConf		:= oMdlCab:GetValue("TPCONFIRM")
Local cLinha		:= GYN->(GetAdvFVal("GYN","GYN_LINCOD",XFilial("GYN") + oMdlGrd:GetValue("G55_CODVIA"),1,""))
Local cMsgSol		:= ""

If oMdlGrd:GetValue("GYN_FINAL") == "1" 
	lRet  := .F.
	cRetLog := "Viagem se encontra finalizada, não é possivel realizar a alteração"
Endif

If lRet .and. xValue .and. cTpConf <> '1'
	If cTabela == 'GQE'
		If oMdlCab:GetValue("GQE_TRECUR") == '1' .AND. !lTerceiro
			lRet :=  GTP409ColConf(oMdlCab:GetValue("GQE_RECURS"),oMdlGrd:GetValue("GQE_DTREF"),cLinha,,@aRetLog)
			cRetLog := aRetLog[2]
			cMsgSol := aRetLog[3]
		Else		
			lRet :=  GTP409ConfVei(oMdlCab:GetValue("GQE_RECURS"),oMdlGrd:GetValue("G55_DTPART"),oMdlGrd:GetValue("G55_DTCHEG"),@cRetLog,oMdlGrd:GetValue("G55_HRINI"),oMdlGrd:GetValue("G55_HRFIM"),cLinha,@cMsgSol,.f.)
		Endif
	Endif
Endif

If !lRet
	oMdl:GetModel():SetErrorMessage(oMdl:GetId(),"GQE_STATUS",oMdl:GetId(),"GQE_STATUS",'VldRecurso',STR0009+cRetLog,cMsgSol ) //"Houve uma inconsistência na confirmação do Recurso: "
Endif

GTPDestroy(aRetLog)

Return lRet
