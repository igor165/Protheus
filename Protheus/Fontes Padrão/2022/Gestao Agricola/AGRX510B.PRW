#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGRX510B.ch"


/*/{Protheus.doc} AGRX510B
//DE/PARA Tipo de Operação entre filiais
@author marina.muller
@since 01/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AGRX510B()
	Local aButtons 		:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0002/*"FECHAR"*/},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}

	FWExecView(STR0001, "AGRX510B", 4,/*oDlg*/,/*bCloseOnOK*/,/*bOk*/,/*nPercReducao*/,aButtons,{|| bCancelOpe()}) //"DE/PARA Tipo Operação entre Filiais"

Return .T.


/*/{Protheus.doc} bCancelOpe
//Função acionada no botão fechar
@author marina.muller
@since 01/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function  bCancelOpe()
	Local oView := FwViewActive()

	oView:oModel:lModify := .F.
	oView:lModify := .F.

Return .T.


/*/{Protheus.doc} ModelDef
//Função faz criação do modelo da tela
@author marina.muller
@since 01/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ModelDef()
	Local oModel   	 := Nil
	Local oStruN92 	 := FwFormStruct( 1, "N92" )
	Local oStrFilial := getModelStruct()
	Local bLoadGrid  := {|oGridModel, lCopy| FilialLoad(oGridModel, lCopy)}
	
	oStruN92:SetProperty( "N92_CODIGO", MODEL_FIELD_WHEN,     {|| .T.})
	oStruN92:SetProperty( "N92_CODIGO", MODEL_FIELD_VALID,    {|| AGRX510BVL()})
	
	oModel := MPFormModel():New('AGRX510B',/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/)
	oModel:SetDescription(STR0001) //"DE/PARA Tipo Operação entre Filiais"
	
	//-------------------------------------
	// Adiciona a estrutura da Field
	//-------------------------------------
	oModel:AddFields( 'MdFieldN92', /*cOwner*/, oStruN92)

	//-------------------------------------
	// Adiciona a estrutura da Grid
	//-------------------------------------
	oModel:AddGrid('MdFilial','MdFieldN92',oStrFilial, , , , , bLoadGrid )
	oModel:GetModel('MdFilial'):SetDescription('Filial')
	oModel:GetModel('MdFilial'):SetOnlyQuery(.T.)
	oModel:GetModel('MdFilial'):SetNoInsertLine(.T.)
	oModel:GetModel('MdFilial'):SetNoDeleteLine(.T.)

Return oModel


/*/{Protheus.doc} ViewDef
//Função faz criação da view da tela
@author marina.muller
@since 01/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ViewDef()
	Local oModel 	 := FWLoadModel('AGRX510B')
	Local oStruN92	 := FWFormStruct(2,'N92',{|cCampo| (Alltrim(cCampo) $ "N92_FILIAL|N92_CODIGO|N92_DESCTO|")})
	Local oStrFilial := getViewStruct()
	Local oView		 := Nil

	//------------------
	//Instancia a View
	//------------------
	oView := FwFormView():New()

	//------------------------
	//Seta o modelo de dados
	//------------------------
	oView:SetModel( oModel )
	oView:SetDescription(STR0001) //"DE/PARA Tipo Operação entre Filiais"
	
	//---------------------------------------------
	//Adiciona a estrutura do field na View
	//---------------------------------------------
	oView:AddField( 'VIEW_N92', oStruN92, 'MdFieldN92' )

	//---------------------------------------------
	//Adiciona a estrutura da Grid na View
	//---------------------------------------------
	oView:AddGrid( 'FORM_FILIAL', oStrFilial, 'MdFilial')

	//---------------------------------------------
	//Tamanho de cada view
	//---------------------------------------------	
	oView:CreateHorizontalBox( 'MAIN', 100 )
	oView:CreateVerticalBox( 'UNICO', 100, 'MAIN' )

	//Cabeçalho
	oView:CreateHorizontalBox( 'CABEC', 30, 'UNICO' )

	//Grid de pendências
	oView:CreateHorizontalBox( 'GRID' , 70, 'UNICO'  )
	oView:CreateFolder('FOLDER1','GRID')
	oView:AddSheet('FOLDER1','ABAETAPA', STR0011/*"Filiais"*/)
	oView:CreateHorizontalBox( 'BOXETAPA', 100, , , 'FOLDER1', 'ABAETAPA')

	oView:SetOwnerView( 'VIEW_N92', 'CABEC' )
	oView:SetOwnerView( 'FORM_FILIAL', 'BOXETAPA' )
	
	oStruN92:SetProperty( "N92_CODIGO", MVC_VIEW_CANCHANGE, .T.)
	oStruN92:SetProperty( "N92_DESCTO", MVC_VIEW_CANCHANGE, .F.)
	oStruN92:SetProperty( "N92_CODIGO", MVC_VIEW_LOOKUP, 'N92')
	
	oView:AddUserButton(STR0003 /*"Efetivar"*/, '', {|oModel,oView| AGRX510BPR(oModel,oView)})
	
Return oView


/*/{Protheus.doc} getModelStruct
//Função cria os campos do GRID no modelo
@author marina.muller
@since 01/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function getModelStruct()
	Local oStruct := FWFormModelStruct():New()

	oStruct:AddField(''      	,''		                          , 'VT_SELEC' , 'L', 5 , 0, , , {}, .F., , .F., .F., .F., , )
	oStruct:AddField(STR0004/*'Filial'*/ ,STR0004/*'Filial'*/     , 'VT_FILIAL', 'C', 10, 0, , , {}, .F., , .F., .F., .F., , )
	oStruct:AddField(STR0005/*'Descrição'*/,STR0005/*'Descrição'*/, 'VT_NOME'  , 'C', 50, 0, , , {}, .F., , .F., .F., .F., , )	

Return oStruct


/*/{Protheus.doc} getViewStruct
//Função cria os campos do GRID na view
@author marina.muller
@since 01/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function getViewStruct()
	Local oStruct := FWFormViewStruct():New()

	oStruct:AddField( 'VT_SELEC' ,'1',''      				 ,''      				 ,, 'CHECK' ,,,	   ,.T.	,,,,,,,, )
	oStruct:AddField( 'VT_FILIAL','2',STR0004 /*'Filial'*/	 ,STR0004/*'Filial'*/	 ,, 'Get'   ,,,    ,.F.  ,,,,,,,, )
	oStruct:AddField( 'VT_NOME'  ,'3',STR0005 /*'Descrição'*/,STR0005/*'Descrição'*/ ,, 'Get'   ,,,    ,.F.  ,,,,,,,, )	

Return oStruct

/*/{Protheus.doc} FilialLoad
//Função carrega o GRID com as filiais do sistema
@author marina.muller
@since 01/03/2019
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, descricao
@param lCopy, logical, descricao
@type function
/*/
Static Function FilialLoad(oGridModel, lCopy)
	Local aArea    := GetArea()
	Local aLoad    := Array(0)
	Local aRetSM0  := FwLoadSM0()
	Local nX       := 1
	Local nPosicao :=0 

	//Adiciona os dados no array de retorno
	For nX := 1 to Len(aRetSM0)
		//verifica se filial já está no array
	    nPosicao := Ascan(aLoad,{|x| ALLTRIM(x[2][2]) == ALLTRIM(aRetSM0[nX][2])})
	    
	    If nPosicao == 0
			aAdd(aLoad, {nX,{ .F. ,;            //checkbox
			                  aRetSM0[nX][2],;  //filial
			 				  aRetSM0[nX][7]}}) //descrição
		EndIf	 				  
	Next nX

	RestArea(aArea)
Return aLoad


/*/{Protheus.doc} AGRX510BPR
//Função acionada botão "efetivar"
@author marina.muller
@since 01/03/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@param oView, object, descricao
@type function
/*/
Static Function AGRX510BPR(oModel,oView)
	Local aSaveArea := GetArea()
	Local lRet		:= .T.
	Local oModN92   := Nil
	
	If !(oModel:IsActive())
		oModel:Activate()
	EndIf
	
	oModN92   := oModel:GetModel( "MdFieldN92" )
	
	//se tipo de operação estiver em branco
	If Empty(oModN92:GetValue("N92_CODIGO"))
		ApMsgAlert(STR0012) //"Tipo de operação deve ser informado."
		lRet := .F. 
	Endif
	
	If lRet
		lRet := ValidGRID(oModel)
		
		If !lRet
			ApMsgAlert(STR0006) //"Não foi marcada nenhuma filial para cópia."
		EndIf
	EndIf
	
	If lRet	
		If MsgYesNo(STR0007)//"Se tipo de operação já existir na filial selecionada será desconsiderado. Deseja continuar?"
			//-- INICIO TRANSACAO --//
			BEGIN TRANSACTION
		
				//função que irá gravar os registros
				Processa({|| lRet := AGRX510BGR(oModel)}, STR0008, STR0009)//"Efetivando cópia...", "Aguarde" 
		
			    If !(lRet)
				   DisarmTransaction()
				EndIf
		
			END TRANSACTION
			//-- FINAL TRANSACAO --//
			
			If lRet 
		       StartTela(oModel)
		       ApMsgAlert(STR0010) //"Cópia tipo operação entre filiais realizada com sucesso."	   
			EndIf   
		EndIf	
	EndIf
   	
	RestArea( aSaveArea )

Return lRet


/*/{Protheus.doc} AGRX510BGR
//Função com SQL nas tabelas do tipo de operação e gravação
@author marina.muller
@since 01/03/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function AGRX510BGR(oModel)
	Local lRet		:= .T.
	Local aSaveArea := GetArea()
	Local cAliasN92 := GetNextAlias()	
	Local cAliasN93 := GetNextAlias()
	Local cAliasN94 := GetNextAlias()
	Local cAliasN95 := GetNextAlias()
	Local cAliasNCB := GetNextAlias()
	Local oModel	:= FwModelActive()
	Local oModN92   := oModel:GetModel("MdFieldN92")
	Local oModFil   := oModel:GetModel("MdFilial")
	Local cFilTpOp  := oModN92:GetValue("N92_FILIAL")
	Local cTpOper   := oModN92:GetValue("N92_CODIGO")
	Local cFilGRID  := ""
	Local cQry		:= ""
	Local nX        := 1
	Local lExiste   := .F.
	
	//loop em todas as filiais do GRID 
	For nX := 1 to oModFil:Length()
		oModFil:GoLine(nX)

		//verifica se checkbox do GRID está marcado
		If oModFil:GetValue("VT_SELEC") == .T.
			//atribui filial do GRID
			cFilGRID := oModFil:GetValue("VT_FILIAL")
			lExiste  := .F. 
			cQry := ""

			//verifica se o tipo de operação já existe na filial destino ignora registro
		    N92->(dbSelectArea('N92'))
			N92->(dbSetOrder(1))    	
			If (N92->(DbSeek(cFilGRID+cTpOper))) //N92_FILIAL+N92_CODIGO
				lExiste := .T.
			EndIf  
			N92->(dbCloseArea())
			
			// se não existir tipo de operação na filial destino
			If !(lExiste)
		
				//---------------------------------------------------------//
				//principal
				cQry := " SELECT N92.* "
				cQry += "   FROM " + RetSqlName("N92") + " N92 " 
				cQry += "  WHERE N92.D_E_L_E_T_ = ' ' "  
				cQry += "    AND N92.N92_FILIAL = '" + cFilTpOp + "' "
				cQry += "    AND N92.N92_CODIGO = '" + cTpOper  + "' "
			
				//--Identifica se tabela esta aberta e fecha
				If Select(cAliasN92) <> 0
					(cAliasN92)->(dbCloseArea())
				EndIf
			
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasN92,.F.,.T.)
				IF (cAliasN92)->(!Eof())
					If RecLock('N92', .T.)
						N92->N92_FILIAL  :=  cFilGRID 
						N92->N92_CODIGO  :=  (cAliasN92)->N92_CODIGO
						N92->N92_DESCTO  :=  (cAliasN92)->N92_DESCTO
						N92->N92_TIPO    :=  (cAliasN92)->N92_TIPO  
						N92->N92_MDEXEC  :=  (cAliasN92)->N92_MDEXEC
						N92->N92_TPOPRE  :=  (cAliasN92)->N92_TPOPRE
						N92->N92_LOCAL   :=  (cAliasN92)->N92_LOCAL 
						N92->N92_AUTOMA  :=  (cAliasN92)->N92_AUTOMA
						N92->N92_CDOPER  :=  (cAliasN92)->N92_CDOPER
						N92->N92_SEQOP   :=  (cAliasN92)->N92_SEQOP 
						N92->N92_GSTFD1  :=  ConvType((cAliasN92)->N92_GSTFD1)
						N92->N92_GSTFD2  :=  ConvType((cAliasN92)->N92_GSTFD2)
						N92->N92_LANCPR  :=  ConvType((cAliasN92)->N92_LANCPR)
						N92->N92_PREROM  :=  ConvType((cAliasN92)->N92_PREROM)
						N92->N92_AUTCNF  :=  ConvType((cAliasN92)->N92_AUTCNF)
						N92->N92_AUTPEN  :=  ConvType((cAliasN92)->N92_AUTPEN)
						N92->N92_MOVORI  :=  ConvType((cAliasN92)->N92_MOVORI)
						N92->N92_GERROM  :=  (cAliasN92)->N92_GERROM
						N92->N92_AUTATU  :=  ConvType((cAliasN92)->N92_AUTATU)
						N92->N92_TESINT  :=  (cAliasN92)->N92_TESINT
						N92->N92_BLQTAB  :=  ConvType((cAliasN92)->N92_BLQTAB)
						N92->N92_MSBLOQ  :=  (cAliasN92)->N92_MSBLOQ

						N92->( msUnLock() )
					Endif
				EndIf
				(cAliasN92)->(dbCloseArea())
				//---------------------------------------------------------//
				
				cQry := ""
				
				//---------------------------------------------------------//
				//etapas
				cQry := " SELECT N93.* "
				cQry += "   FROM " + RetSqlName("N93") + " N93 " 
				cQry += "  WHERE N93.D_E_L_E_T_ = ' ' "  
				cQry += "    AND N93.N93_FILIAL = '" + cFilTpOp + "' "
				cQry += "    AND N93.N93_CODTO = '"  + cTpOper  + "' "
			
				//--Identifica se tabela esta aberta e fecha
				If Select(cAliasN93) <> 0
					(cAliasN93)->(dbCloseArea())
				EndIf
			
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasN93,.F.,.T.)
				IF (cAliasN93)->(!Eof())
					While (cAliasN93)->(!Eof())
						If RecLock('N93', .T.)
							N93->N93_FILIAL  :=  cFilGRID
							N93->N93_CODTO   :=  (cAliasN93)->N93_CODTO 
							N93->N93_OK      :=  ConvType((cAliasN93)->N93_OK)    
							N93->N93_ORDEM   :=  (cAliasN93)->N93_ORDEM 
							N93->N93_CODIGO  :=  (cAliasN93)->N93_CODIGO
							N93->N93_DESETP  :=  (cAliasN93)->N93_DESETP
							N93->N93_CDPTCT  :=  (cAliasN93)->N93_CDPTCT
							N93->N93_CDPERG  :=  (cAliasN93)->N93_CDPERG

							N93->( msUnLock() )
						Endif
					
						(cAliasN93)->(dbSkip())
					EndDo
				EndIf
				(cAliasN93)->(dbCloseArea())
				//---------------------------------------------------------//
				
				cQry := ""
				
				//---------------------------------------------------------//
				//processos etapas
				cQry := " SELECT N94.* "
				cQry += "   FROM " + RetSqlName("N94") + " N94 " 
				cQry += "  WHERE N94.D_E_L_E_T_ = ' ' "  
				cQry += "    AND N94.N94_FILIAL = '" + cFilTpOp + "' "
				cQry += "    AND N94.N94_CODTO = '"  + cTpOper  + "' "
			
				//--Identifica se tabela esta aberta e fecha
				If Select(cAliasN94) <> 0
					(cAliasN94)->(dbCloseArea())
				EndIf
			
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasN94,.F.,.T.)
				IF (cAliasN94)->(!Eof())
					While (cAliasN94)->(!Eof())
						If RecLock('N94', .T.)
							N94->N94_FILIAL  :=  cFilGRID
							N94->N94_CODTO   :=  (cAliasN94)->N94_CODTO 
							N94->N94_CODETP  :=  (cAliasN94)->N94_CODETP
							N94->N94_CODIGO  :=  (cAliasN94)->N94_CODIGO
							N94->N94_DADBAS  :=  ConvType((cAliasN94)->N94_DADBAS)
							N94->N94_QTCPES  :=  ConvType((cAliasN94)->N94_QTCPES)
							N94->N94_ANAQUA  :=  ConvType((cAliasN94)->N94_ANAQUA)
							N94->N94_DADTRA  :=  ConvType((cAliasN94)->N94_DADTRA)
							N94->N94_QTSPES  :=  ConvType((cAliasN94)->N94_QTSPES)
							N94->N94_DADAGD  :=  ConvType((cAliasN94)->N94_DADAGD)
							N94->N94_DADLAV  :=  ConvType((cAliasN94)->N94_DADLAV)
							N94->N94_DADAUT  :=  ConvType((cAliasN94)->N94_DADAUT)
							N94->N94_DADFIS  :=  ConvType((cAliasN94)->N94_DADFIS)

							N94->( msUnLock() )
						Endif

						(cAliasN94)->(dbSkip())
					EndDo
				EndIf
				(cAliasN94)->(dbCloseArea())
				//---------------------------------------------------------//
				
				cQry := ""
				
				//---------------------------------------------------------//
				//campos etapa
				cQry := " SELECT N95.* "
				cQry += "   FROM " + RetSqlName("N95") + " N95 " 
				cQry += "  WHERE N95.D_E_L_E_T_ = ' ' "  
				cQry += "    AND N95.N95_FILIAL = '" + cFilTpOp + "' "
				cQry += "    AND N95.N95_CODTO = '"  + cTpOper  + "' "
			
				//--Identifica se tabela esta aberta e fecha
				If Select(cAliasN95) <> 0
					(cAliasN95)->(dbCloseArea())
				EndIf
			
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasN95,.F.,.T.)
				IF (cAliasN95)->(!Eof())
					While (cAliasN95)->(!Eof())
						If RecLock('N95', .T.)
							N95->N95_FILIAL  :=  cFilGRID
							N95->N95_CODTO   :=  (cAliasN95)->N95_CODTO 
							N95->N95_CODETP  :=  (cAliasN95)->N95_CODETP
							N95->N95_CODIGO  :=  (cAliasN95)->N95_CODIGO
							N95->N95_CAMPO   :=  (cAliasN95)->N95_CAMPO 
							N95->N95_TITULO  :=  (cAliasN95)->N95_TITULO
							N95->N95_OBRIGA  :=  (cAliasN95)->N95_OBRIGA
							N95->N95_ORDEM   :=  (cAliasN95)->N95_ORDEM 
							
							N95->( msUnLock() )
						Endif
						
						(cAliasN95)->(dbSkip())
					EndDo
				EndIf
				(cAliasN95)->(dbCloseArea())
				//---------------------------------------------------------//
				
				cQry := ""
				
				//---------------------------------------------------------//
				//produtos
				cQry := " SELECT NCB.* "
				cQry += "   FROM " + RetSqlName("NCB") + " NCB " 
				cQry += "  WHERE NCB.D_E_L_E_T_ = ' ' "  
				cQry += "    AND NCB.NCB_FILIAL = '" + cFilTpOp + "' "
				cQry += "    AND NCB.NCB_CODTO = '"  + cTpOper  + "' "
			
				//--Identifica se tabela esta aberta e fecha
				If Select(cAliasNCB) <> 0
					(cAliasNCB)->(dbCloseArea())
				EndIf
			
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasNCB,.F.,.T.)
				IF (cAliasNCB)->(!Eof())
					While (cAliasNCB)->(!Eof())
						If RecLock('NCB', .T.)
							NCB->NCB_FILIAL  :=  cFilGRID
							NCB->NCB_CODTO   :=  (cAliasNCB)->NCB_CODTO 
							NCB->NCB_CODPRO  :=  (cAliasNCB)->NCB_CODPRO
							
							NCB->( msUnLock() )
						Endif

						(cAliasNCB)->(dbSkip())
					EndDo
				EndIf
				(cAliasNCB)->(dbCloseArea())
				//---------------------------------------------------------//
			EndIf
		EndIf	
	Next nX
		
	RestArea( aSaveArea )

Return lRet


/*/{Protheus.doc} AGRX510BVL
//Valid da descrição do tipo de operação
@author marina.muller
@since 01/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AGRX510BVL()
	Local lRet 		:= .T.
	Local aArea  	:= GetArea()
	Local oModel	:= FwModelActive()
	Local oModN92   := oModel:GetModel( "MdFieldN92" )
	
	If !Empty(oModN92:GetValue("N92_CODIGO"))
		oModN92:LoadValue('N92_DESCTO', POSICIONE("N92",1,fwxFilial("N92")+oModN92:GetValue( "N92_CODIGO"),"N92_DESCTO"))
	EndIf
	
	RestArea(aArea)
	
Return lRet


/*/{Protheus.doc} ValidGRID
//Verifica se foi marcado alguma filial no GRID para processamento
@author marina.muller
@since 01/03/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function ValidGRID(oModel)
	Local lRet	    := .F.
	Local oGridFil  := oModel:GetModel('MdFilial')
	Local nX
	
	For nX := 1 to oGridFil:Length()
		oGridFil:GoLine(nX)

		//verifica se checkbox do GRID está marcado
		If oGridFil:GetValue("VT_SELEC") == .T.
			lRet := .T.
			Exit
		EndIf
	Next nX

Return lRet
 
 
/*/{Protheus.doc} ConvType
//Converte os campos de checkbox de string para lógico 
@author marina.muller
@since 01/03/2019
@version 1.0
@return ${return}, ${return_description}
@param cVlCampo, characters, descricao
@type function
/*/
Static Function ConvType(cVlCampo)
	Local lRet := .F.  
	
	If cVlCampo == "T"
		lRet := .T.
	EndIf
	
Return lRet


/*/{Protheus.doc} StartTela
//Limpa os campos da tela após efetivação
@author marina.muller
@since 01/03/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function StartTela(oModel)
	Local oModN92   := oModel:GetModel("MdFieldN92")
	Local oGridFil  := oModel:GetModel('MdFilial')
	Local nX
	
	oModN92:LoadValue('N92_CODIGO', "")
	oModN92:LoadValue('N92_DESCTO', "")
	
	For nX := 1 to oGridFil:Length()
		oGridFil:GoLine(nX)
		oGridFil:LoadValue('VT_SELEC', .F.)
	Next nX
	
	//posiciona na primeira linha GRID
	oGridFil:GoLine(1)
Return .T.

