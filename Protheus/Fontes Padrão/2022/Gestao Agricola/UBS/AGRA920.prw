#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"
#INCLUDE "AGRA920.CH"

/*/{Protheus.doc} AGRA920
Rotina para montagem de layout
@param: 	Nil
@author: 	Fabiane Schulze
@since: 	10/12/2013
@Uso: 		UBS 
/*/

Function AGRA920( cAlias, nReg, nAcao )
	Local oMBrowse	:= Nil
	Private vSalCol := {}
	
	If !AGRIFDICIONA("SX3","NKV",1,.F.)
		AGRINCOMDIC("UPAGR001",,.T.)
	EndIf

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NPV" )
	oMBrowse:SetDescription( STR0001 )	//"Layout Análises"
	oMbrowse:DisableDetails()
	oMBrowse:Activate()
Return( )

/** {Protheus.doc} MenuDef
Funcao que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Fabiane Schulze
@since: 	10/12/2013
@Uso: 		AGRA920 
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0002 , "PesqBrw"			, 0, 1, 0, .T. } )	//"Pesquisar"
	aAdd( aRotina, { STR0003 , "ViewDef.AGRA920"	, 0, 2, 0, Nil } )	//"Visualizar"
	aAdd( aRotina, { STR0004 , "ViewDef.AGRA920"	, 0, 3, 0, Nil } )	//"Inluir"
	aAdd( aRotina, { STR0005 , "ViewDef.AGRA920"	, 0, 4, 0, Nil } )	//"Alterar"
	aAdd( aRotina, { STR0006 , "ViewDef.AGRA920"	, 0, 5, 0, Nil } )	//"Exluir"

Return( aRotina )

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Fabiane Schulze
@since: 	10/12/2013
@Uso: 		AGRA920
@type function
*/
Static Function ModelDef()
	Local oStruNPV := FWFormStruct( 1, "NPV" )
	Local oStruNPW := FWFormStruct( 1, "NPW" )
	Local oStruNKV := FWFormStruct( 1, "NKV" )
	Local oModel   := MPFormModel():New( "AGRA920", , {| oModel | PosModelo( oModel ) } )
	

	oStruNPW:AddTrigger( ;
	"NPW_NOME" , ; // [01] identificador (ID) do campo de origem
	'NPW_NOME2', ; // [02] identificador (ID) do campo de destino
	nil , ; // [03] Bloco de código de validação da execução do gatilho
	{||A2GR920DES()} ) // [04] Bloco de código de execução do gatilho
	
	
	oStruNPW:RemoveField( "NPW_LAYOUT" )

	oStruNPV:SetProperty( "NPV_TPLAY" , MODEL_FIELD_VALID, {| oField | fValTpLay( oField ) } )
	
	oStruNPW:SetProperty( "NPW_CODTA" 	, MODEL_FIELD_VALID , FwBuildFeature( STRUCT_FEATURE_VALID,"AGRA920LCP()") )
	 
	oStruNPW:AddField(	/*cTitulo*/					"NPW_NOME2",;
							/*cTooltip*/ 			""				,;
							/*cIdField*/			"NPW_NOME2",;
							/*cTipo*/				"C",;
							/*nTamanho*/			AGRSEEKDIC("SX3","NPW_NOME ",2,"X3_TAMANHO"),;
							/*nDecimal*/			,;
							/*bValid*/ 				,;
							/*bWhen*/ 				,;
							/*aValues*/				,;
							/*lObrigat*/			.F.,;
							/*bInit*/				{||AGR920DES()},;
							/*lKey*/				,;
							/*lNoUpd */				,;
							/*lVirtual */ .T.		)
	
	If GetRpoRelease() <= "12.1.033" .AND. Alltrim(GetSX3Cache("NKV_USUARI","X3_RELACAO")) == "USR" //trata erro expedido no dicionario, ajustado P12.1.2210
		oStruNKV:SetProperty( "NKV_USUARI" , MODEL_FIELD_INIT, {|  | '' } ) 
	EndIf

	oModel:AddFields( "NPVUNICO", Nil, oStruNPV )
	oModel:AddGrid( "NPWUNICO", "NPVUNICO", oStruNPW ,,,/*{|oModel|LineValid(@oModel)}*/)
	oModel:GetModel("NPWUNICO"):SetUniqueLine({"NPW_CODTA","NPW_CAMPO"})
	oModel:SetRelation( "NPWUNICO", { { "NPW_FILIAL", "xFilial( 'NPW' )" }, { "NPW_LAYOUT", "NPV_CODIGO" } }, NPW->( IndexKey( 1 ) ) )
	oModel:GetModel( "NPWUNICO" ):SetOptional( .t. )
	
	// NKV
	oModel:AddGrid( "NKVUNICO", "NPVUNICO", oStruNKV ,,,/*{|oModel|LineValid(@oModel)}*/)
	oModel:GetModel("NKVUNICO"):SetUniqueLine({"NKV_USUARI","NKV_LAYOUT"})
	oModel:SetRelation( "NKVUNICO", { { "NKV_FILIAL", "xFilial( 'NKV' )" }, { "NKV_LAYOUT", "NPV_CODIGO" } }, NKV->( IndexKey( 1 ) ) )
	oModel:GetModel( "NKVUNICO" ):SetOptional( .T. )
	oModel:SetDescription( STR0001 ) //"Layout Análises"

Return( oModel )


static function A2GR920DES
Local cDescricao
if !Empty(FWFldGet("NPW_CODTA"))
	cDescricao := Posicione("NPT",1,xFilial("NPT")+FWFldGet("NPW_CODTA"),"NPT_DESCRI")
else 
	cDescricao := AGRSEEKDIC("SX3",FWFldGet("NPW_CAMPO"),2,"X3_TITULO")
endif
return cDescricao


static function AGR920DES
Local cDescricao
if !Empty(NPW->NPW_CODTA)
	cDescricao := Posicione("NPT",1,xFilial("NPT")+NPW->NPW_CODTA,"NPT_DESCRI")
else 
	cDescricao := AGRSEEKDIC("SX3",NPW->NPW_CAMPO,2,"X3_TITULO")
endif
return cDescricao


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: Nil
@return:	oView - View do modelo de dados
@author: 	Fabiane Schulze
@since: 	13/12/2013
@Uso: 		AGRA920 
*/
Static Function ViewDef()
	Local oStruNPV  := FWFormStruct( 2, "NPV" )
	Local oStruNPW  := FWFormStruct( 2, "NPW" )
	Local oStruNKV  := FWFormStruct( 2, "NKV" )
	Local oModel    := FWLoadModel( "AGRA920" )
	local aField	:= {}  	
	local nx
	
	oView  := FWFormView():New()

	oStruNPW:RemoveField( "NPW_LAYOUT" )
	//Campo virtual para mostar a descrição da  análise da NPU					
	oStruNPW:AddField(/*cIdField*/			"NPW_NOME2",;
						/*cOrdem*/			strzero((VAL(AGRSEEKDIC("SX3","NPW_NOME ",2,"X3_ORDEM")))+1,2),;
						/*cTitulo*/			STR0020,;
						/*cDescric*/		AGRSEEKDIC("SX3","NPU_DESVA ",2,"X3_DESCRIC") ,;
						/*aHelp*/			,;
						/*cType*/			"C",;
						/*cPicture*/		,;
						/*bPictVar*/		,;
						/*cLookUp*/			,;  
						/*lCanChange*/		.F.,;
						/*cFolder*/			,;
						/*cGroup*/			,;
						/*aComboValues*/	,;
						/*nMaxLenCombo*/	,;
						/*cIniBrow*/		,;
						/*lVirtual*/		.T.,;
						/*cPictVar*/		,;
						/*lInsertLine*/		,;
						/*nWidth*/			)
							
	aField	:= ASORT(oStruNPW:AFIELDS, , , { | x,y | x[2] < y[2] } )	
	
	for nx := 1 to len(oStruNPW:AFIELDS)					
		oStruNPW:SetProperty(oStruNPW:AFIELDS[nx,1],MVC_VIEW_ORDEM,strzero(nx,2))
	next
		
	oView:SetModel( oModel )
	oView:AddField( "VIEW_NPV", oStruNPV, "NPVUNICO" )
	oView:AddGrid( "VIEW_NPW",  oStruNPW, "NPWUNICO" )
	oView:AddGrid( "VIEW_NKV",  oStruNKV, "NKVUNICO" )

	oView:CreateHorizontalBox( "SUPERIOR" , 25 )
	oView:CreateHorizontalBox( "INFERIOR" , 50 )

	//NKV
	oView:CreateHorizontalBox( "INFERIOR2" , 25 )
	oView:CreateFolder( "GRADES2", "INFERIOR2")
	oView:AddSheet( "GRADES2", "PASTA02", "Usuarios")
	oView:CreateHorizontalBox( "PASTA_NKV", 100, , , "GRADES2", "PASTA02" )
	oView:SetOwnerView( "VIEW_NKV", "PASTA_NKV" )
	oView:EnableTitleView( "VIEW_NKV" )


	oView:CreateFolder( "GRADES", "INFERIOR")
	oView:AddSheet( "GRADES", "PASTA01", "Classificação")

	oView:CreateHorizontalBox( "PASTA_NPW", 100, , , "GRADES", "PASTA01" )

	oView:SetOwnerView( "VIEW_NPV", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_NPW", "PASTA_NPW" )

	oView:EnableTitleView( "VIEW_NPV" )
	oView:EnableTitleView( "VIEW_NPW" )
	
	//não reabre a tela apos a inclusao/ateração
	oView:SetCloseOnOk( {|| .T. } )

Return( oView )

/** {Protheus.doc} AGRA920LAY
Carrega o código do layout e o nome do usuário 

@param: 	Nil
@return:	.T.
@author: 	Inácio Luiz Kolling
@since: 	01/10/2014 
@Uso: 		AGRA920 
*/
Function AGRA920LAY()
	Local oModel	:= FWModelActive()
	Local oStruNKV 	:= oModel:GetModel( "NKVUNICO" )
	Local oStruNPV 	:= oModel:GetModel( "NPVUNICO" )
	oStruNKV:LoadValue("NKV_LAYOUT",oStruNPV:GetValue("NPV_CODIGO"))
	oStruNKV:LoadValue("NKV_NOME",UsrRetName(oStruNKV:GetValue("NKV_USUARI")))
Return .t.

/** {Protheus.doc} ViewDef
Função para a confirmação da grid

@param: 	oModel
@return:	lRetorno [.T./.F.]
@author: 	Fabiane Schulze
@since: 	13/12/2013
@Uso: 		AGRA920 
*/
Static Function PosModelo (oModel)
	
	Local nX,nW,nY
	Local oGrdNPW		:= oModel:GetModel( "NPWUNICO" )
	Local lRetorno		:= .T.
	Local lLote, lProd 	:= .F.
	Local lCol 			:= .T.
	Local lInfFisOK 	:= .T.     
	

	For nX := 1 To oGrdNPW:Length()
		oGrdNPW:GoLine( nX )
		If .Not. oGrdNPW:IsDeleted()
			
			If oGrdNPW:GetValue( "NPW_CAMPO" ) == PADR('NP9_LOTE', TamSX3('NPW_CAMPO')[1])
				lLote := .T.
			Endif
			
		 	If oGrdNPW:GetValue( "NPW_CAMPO" ) == PADR('NP9_PROD', TamSX3('NPW_CAMPO')[1])
				lProd := .T.
			Endif
			
			If oGrdNPW:GetValue( "NPW_COL") == 0
				lCol := .F.
			EndIf
			
			IF oGrdNPW:GetValue( "NPW_INFFIS") == 'S'  .and.  ! FwFldget('NPV_TPLAY') = '2' //Somente boletins de nf podem ter npw_inffis = 'S'
			   lInfFisOK :=.F.
			EndIF 
			
		EndIf
		
	Next Nx
	
	If .Not. lprod
		Help( , , STR0007 , , STR0019, 1, 0 )	//"AJUDA"###"Campo Produto não foi informado"
		lRetorno := .F.
	EndIf
	
	If .Not. lLote
		Help( , , STR0007 , , STR0008, 1, 0 )	//"AJUDA"###"Campo Lote não foi informado"
		lRetorno := .F.
	EndIf
	
	If .Not. lCol
		Help( , , STR0007, , STR0009, 1, 0 )	//"AJUDA"###"Campo Coluna não foi informado"
		lRetorno := .F.
	EndIf
	
	If .Not. lInfFisOK
		Help( , , STR0007, , STR0010 + RetTitle('NPW_INFFIS') + STR0011, 1, 0 )		//"AJUDA"###"O Campo: "###" deve conter NÂO para o tipo de boletim informado"
		lRetorno := .F.
	EndIf
	
	//Verifica o valor do campo NPW_COL
	If .Not. oGrdNPW:IsDeleted()
		If lRetorno 
			While lRetorno
				For nY := 1 To oGrdNPW:Length()
					oGrdNPW:GoLine( nY )
					nCol := oGrdNPW:GetValue( "NPW_COL")
					For nW := nY+1 To oGrdNPW:Length()
						oGrdNPW:GoLine( nW )
						IF nCol = oGrdNPW:GetValue( "NPW_COL")
							Help(,,STR0007,, STR0012,1,0)	//"AJUDA"###"Não pode haver dois campos utilizando a mesma numeração de coluna!"
							lRetorno := .F.
							Exit
						EndIf	
					Next nW
					If lRetorno = .F.
						Exit
					EndIf
				Next nY	
				If ny > oGrdNPW:Length()
					Exit
				EndIf
			EndDo
		EndIf
	EndIf
Return lRetorno

Return lRetorno

/** {Protheus.doc} ViewDef
Função para a confirmação da grid

@param: 	oModel
@return:	lRetorno [.T./.F.]
@author: 	Fabiane Schulze
@since: 	13/12/2013
@Uso: 		AGRA920 
*/
Function AGRA920F3()
	Local oModel    := FWModelActive()
	Local oView     := FWViewActive()
	Local aCpos     := {}       	//Array com os dados
	Local aRet      := {}       	//Array do retorno da opcao selecionada
	Local oDlg                  	//Objeto Janela
	Local oLbx                  	//Objeto List box
	Local cTitulo   := STR0013
	Local nX        := 1
	Local oStruNP9  := FWFormStruct( 1, "NP9" )
	Local oStruSB8  := FWFormStruct( 1, "SB8" )

	Public __CAMPOT1 := FWFldGet('NPW_CAMPO')
	Public __CAMPOT2 := FWFldGet('NPW_NOME')

	If !Empty(oModel:GetValue('NPWUNICO', 'NPW_CODTA'))

		DbSelectArea("NPT")
		NPT->(dbSetOrder(1))
		NPT->(dbSeek(xFilial("NPT") + oModel:GetValue('NPWUNICO', 'NPW_CODTA')	))
		While !NPT->(Eof()) .And. NPT->(NPT_FILIAL) == xFilial("NPT") .And. NPT->(NPT_CODTA) == oModel:GetValue('NPWUNICO', 'NPW_CODTA')

			DbSelectArea("NPU")
			NPU->(dbSetOrder(1))
			NPU->(dbSeek(xFilial("NPU")+NPT->NPT_CODTA))
			//Carrega o vetor com os campos da tabela selecionada
			While !NPU->(Eof()) .and. NPU->(NPU_FILIAL) == xFilial("NPU") .And. NPU->(NPU_CODTA) == NPT->(NPT_CODTA)
	
				aAdd( aCpos, { NPU->NPU_CODTA, NPT->NPT_DESCRI, NPU->NPU_CODVA, NPU->NPU_DESVA } )
	   
				NPU->(DbSkip())
			EndDo
			NPT->(DbSkip())
		Enddo
	Else
		//Busca campos da tabela NP9
		aStruct := oStruNP9:aFields
		For nX := 1 To Len(aStruct)
			If (X3USADO(aStruct[nX,3]) .or. (aStruct[nX,3] = "NP9_FORMUL") .OR. (aStruct[nX,3] = "NP9_FORMUV"))
				aAdd( aCpos, { "", "", aStruct[nX,3], aStruct[nX,1] } )
			EndIf
		Next nX

		//Busca campos da tabela SB8 - saldo de lotes
		aStruct := oStruSB8:aFields		
		For nX := 1 To Len(aStruct)
			If aStruct[nX,3] == "B8_SALDO" .AND. X3USADO(aStruct[nX,3]) .AND. AGRRETCTXT("SB8", "B8_SALDO") <> "V"
				aAdd( aCpos, { "", "", aStruct[nX,3], aStruct[nX,1] } )
			EndIf
		Next nX


	EndIf

	If Len( aCpos ) > 0

		DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 325,580 PIXEL
	
		@ 10,10 LISTBOX oLbx FIELDS HEADER STR0014, STR0015, STR0016, STR0017 SIZE 270,120 OF oDlg PIXEL	//"Layout"###"Descrição"###"Campo"###"Título"
	
		oLbx:SetArray( aCpos )
		oLbx:bLine     	:= {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3], aCpos[oLbx:nAt,4]}}
		oLbx:bLDblClick := {|| {oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4]}}}

		DEFINE SBUTTON FROM 134,250 TYPE 1 ACTION (oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4]})  ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTER
	
	
		If len(aRet) > 0
			__CAMPOT1 := aRet[1]
			__CAMPOT2 := aRet[2]
			oModel:GetModel( "NPWUNICO" ):loadvalue("NPW_CAMPO",__CAMPOT1)
			oModel:GetModel( "NPWUNICO" ):loadvalue("NPW_NOME",__CAMPOT2)
		EndIf
	
	EndIf

	oView:Refresh()
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRA920VNPU
Função para validação  de analise
@author Maicol Lange
@since 06/02/2014
/*/
//-------------------------------------------------------------------
Function AGRA920VNPU ()
	Local lRetorno := .t.
	Local cTipoAnalise := FWFldGet('NPW_CODTA')
	Local cVariAnalise := FWFldGet('NPW_CAMPO')
	//só faz a validação de analise se  tiver com o compo preenchido
	If !Empty(cTipoAnalise)
		lRetorno := EXISTCPO("NPU",cTipoAnalise+cVariAnalise)
	EndIf
Return (lRetorno)


/** {Protheus.doc} fValLay
Função que Valida o Tipo de Layout. no intuito de garantir
q so exista um layout de imp. de nfe por filial
@param:   Produto
Retorno:  .t. ou .f. Indicando que ok pode continuar;
@author: 	Emerson Coelho
@since: 	02/10/2014
@Uso: 		SIGAARM - Originação de Grãos
*/
Static Function fValTpLay( oField )

	Local aAreaAtu := GetArea()
	Local cTpLay	  := FwFldget('NPV_TPLAY')
	Local cLayout   := FwFldget('NPV_CODIGO')
	Local lRetorno := .T.

	IF cTPLay = '2' //Indica que é um Layout de Imp. Nf.
		BeginSql Alias "QryNPV"
			Select *
			From %table:NPV% NPV
			Where NPV.NPV_FILIAL = %xFilial:NPV%  and NPV.%NotDel% and NPV.NPV_TPLAY ='2'
		EndSql
		If .Not. QryNPV->( Eof() )
			IF ! Alltrim(QryNPV->NPV_CODIGO) = Alltrim(cLayout)
				Help(,,STR0007,,STR0018 + Alltrim(QryNPV->NPV_CODIGO)+"." ,1,0) //"Não pode haver dois Layouts de Impressao de NF. para a mesma empresa.Verifique o Layout:"
				lRetorno := .F.
			EndIF
		EndIf

		QryNPV->( dbCloseArea( ) )
	EndIF
		
	RestArea(aAreaAtu)

Return( lRetorno )

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRA920LCP
Apos a alteracao do campo NPW_CODTA, resetar cadastro da linha
@author carlos.augusto
@since 20/12/2016
/*/
//-------------------------------------------------------------------
Function AGRA920LCP()
	Local lRetorno := .T.
	Local oModel    := FWModelActive()

	oModel:GetModel( "NPWUNICO" ):loadvalue("NPW_CAMPO","")
	oModel:GetModel( "NPWUNICO" ):loadvalue("NPW_NOME","")
	oModel:GetModel( "NPWUNICO" ):loadvalue("NPW_NOME2","")
	oModel:GetModel( "NPWUNICO" ):loadvalue("NPW_COL",0)
	oModel:GetModel( "NPWUNICO" ):loadvalue("NPW_INFFIS",'N')
	oModel:GetModel( "NPWUNICO" ):loadvalue("NPW_DESRES","")

	lRetorno := Vazio() .Or. ExistCPO("NPU")
Return( lRetorno )
