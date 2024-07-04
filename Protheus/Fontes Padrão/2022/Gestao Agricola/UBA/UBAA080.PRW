#INCLUDE "UBAA080.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"

Static __cRet :='' 
Static __cCampDX7 := "DX7_MIC,DX7_RES,DX7_FIBRA,DX7_UI,DX7_SFI,DX7_ELONG,DX7_LEAF,DX7_AREA,DX7_CSP,DX7_CG,DX7_MAISB,DX7_RD,DX7_COUNT,DX7_UHM,DX7_SCI" 

/*/{Protheus.doc} UBAA080
//Cadastro de Pre-Emblocamento
@author carlos.augusto
@since 02/05/2017
@version 12.1.20

@type function
/*/
Function UBAA080()
	Local aArea 	:= GetArea()
	Local oBrowse
    
	If .Not. TableInDic('N80')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif
	
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('N80')
	oBrowse:SetMenuDef('UBAA080')
	oBrowse:SetOnlyFields( { 'N80_CODIGO', 'N80_NMEMBL', 'N80_DESEMB', 'N80_RELEVA' } )
	oBrowse:SetFilterDefault(" N80_TIPEMB == '2'")
    oBrowse:SetDescription(STR0001) //#Regras de Pre-Emblocamento
	oBrowse:Activate()	
	
	RestArea(aArea)
Return nil

/*/{Protheus.doc} MenuDef
@author carlos.augusto
@since 08/06/2017
@version 12.1.20
@type function
/*/
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.UBAA080' OPERATION 2 ACCESS 0    // 'Visualizar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.UBAA080' OPERATION 3 ACCESS 0    // 'Incluir'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.UBAA080' OPERATION 4 ACCESS 0    // 'Alterar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.UBAA080' OPERATION 5 ACCESS 0    // 'Excluir'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.UBAA080' OPERATION 8 ACCESS 0    // 'Imprimir'
	
Return aRotina

/*/{Protheus.doc} ModelDef
@author jeferson.chaves
@since 09/06/2017
@version undefined

@type function
/*/
Static Function ModelDef()
	Local oModel   		:= Nil
	Local oStruN80 		:= FwFormStruct( 1, "N80" )
	Local oStruN81HVI 	:= FwFormStruct( 1, "N81" )
	
	oModel := MPFormModel():New('UBAA080',/*bPre*/ , {|oModel| UBAA080POS(oModel)} /*bPos*/, {|oModel| UBAA080GRV(oModel)},)

	//-------------------------------------
	// Adiciona a estrutura da Field
	//-------------------------------------
	oModel:AddFields( 'MdFieldN80', /*cOwner*/, oStruN80 )
	oModel:SetPrimaryKey( { "N80_FILIAL", "N80_CODIGO" } )
	oModel:GetModel( 'MdFieldN80' ):SetDescription(STR0001)//Regras de Emblocamento
	
	//-------------------------------------
	// Adiciona a estrutura da Grid 
	//-------------------------------------
	oModel:AddGrid( 'MdGrdN81HVI', 'MdFieldN80', oStruN81HVI)
	
	//-------------------------------------
	// Seta campos obrigatorios
	//-------------------------------------	
	oStruN81HVI:SetProperty( 'N81_VLDE'   , MODEL_FIELD_OBRIGAT , .F.)
	oStruN81HVI:SetProperty( 'N81_VLATE'   , MODEL_FIELD_OBRIGAT , .T.)

	//-------------------------------------
	// When para N81_CODREG
	//-------------------------------------
	oStruN81HVI:SetProperty( 'N81_CODREG' , MODEL_FIELD_WHEN ,  {|| UBAA080TRH()})
	
	//-------------------------------------
	// Valid para N81_CODREG
	//-------------------------------------
	oStruN81HVI:SetProperty( 'N81_CODREG' , MODEL_FIELD_VALID ,  {|| AgrHVIVld()})
	
	//-------------------------------------
	// Seta linha unica da grid
	//-------------------------------------
	oModel:GetModel( 'MdGrdN81HVI' ):SetUniqueLine( {'N81_CODREG'} )
	
	//-------------------------------------
	// Carrega o filtro da grid de HVI
	//-------------------------------------	
	oModel:GetModel( 'MdGrdN81HVI'):SetLoadFilter( , U080FiltrH()) 
	
	//-------------------------------------
	// Altera descricao para Pre-Emblocamento
	//-------------------------------------	
	oModel:GetModel( 'MdGrdN81HVI'):SetDescription(STR0001)
	
	//-------------------------------------
	// Seta relacionamento
	//-------------------------------------
	oModel:SetRelation( 'MdGrdN81HVI', { { 'N81_FILIAL', 'xFilial( "N81" )' }, { 'N81_CODEMB', 'N80_CODIGO' },{ 'N81_TIPEMB', 'N80_TIPEMB' } })
	
	//-------------------------------------
	// Altera descricao no modelo
	//-------------------------------------
	oModel:SetDescription(STR0001)
	
	//-------------------------------------
	// Valida apos a Ativação do model
	//-------------------------------------
	oModel:SetActivate({|oModel|InitFields(oModel)}) // Inicializa os campos conforme o pergunte

Return oModel

/*/{Protheus.doc} ViewDef
@author carlos.augusto
@since 09/06/2017
@version 12.1.20

@type function
/*/
Static Function ViewDef()

	Local oStruN80		:= FWFormStruct(2,"N80")
	Local oStruN81HVI 	:= FWFormStruct(2,'N81')
	Local oModel   		:= FWLoadModel( "UBAA080" )
	Local oView    		:= FWFormView():New()
		
	oView:SetModel( oModel )
	
	//---------------------------------------------
	//Adiciona a estrutura do field na View
	//---------------------------------------------
	oView:AddField( "VwFieldN80", oStruN80, "MdFieldN80" )
	
	//---------------------------------------------
	//Adiciona a estrutura da Grid na View
	//---------------------------------------------
	oView:AddGrid( 'VIEW_N81HVI', oStruN81HVI, 'MdGrdN81HVI' )
	
	//-------------------------------------------
	// Remove campos da estrurura principal
	//-------------------------------------------
	oStruN80:RemoveField( "N80_PCTFRM" )
	oStruN80:RemoveField( "N80_TPCLAS" )
	oStruN80:RemoveField( "N80_TIPEMB" )
	
	oStruN80:RemoveField( "N80_RESERV" )
	oStruN80:RemoveField( "N80_QTDFAR" )
	oStruN80:RemoveField( "N80_PSMAX" )
	oStruN80:RemoveField( "N80_OK")
	
	//-------------------------------------------
	// Remove campos da estrurura HVI da view
	//-------------------------------------------
	oStruN81HVI:RemoveField( "N81_FILIAL" )
	oStruN81HVI:RemoveField( "N81_CODEMB" )
	oStruN81HVI:RemoveField( "N81_DESC" )
	oStruN81HVI:RemoveField( "N81_TIPREG" )
	oStruN81HVI:RemoveField( "N81_CAMPO" )
	oStruN81HVI:RemoveField( "N81_TIPEMB" )
	
	//----------------------
	//Cria o Box Horizontal
	//----------------------

	oView:CreateHorizontalBox( "SUPERIOR" , 60 )	
	oView:CreateHorizontalBox( 'MEIO'	  , 40 )

	// ------------
	// Cria Folder
	// ------------
	oView:CreateFolder( 'HVIFolder', 'MEIO')
	oView:AddSheet( 'HVIFolder', 'PASTA01', STR0007)
	
	// ----------
	// Cria Box
	// ----------
	oView:CreateHorizontalBox( 'PASTAHVI',  100, , , 'HVIFolder', 'PASTA01' )
	
	//----------------------
	//Seta owner da view
	//----------------------
	oView:SetOwnerView( "VwFieldN80", "SUPERIOR" )
	oView:SetOwnerView( 'VIEW_N81HVI', 'PASTAHVI' )
	
	// ---------------------------------
	// Seta o Campo incremental da Grid
	// ---------------------------------
	oView:AddIncrementField( 'VIEW_N81HVI', 'N81_SEQ' )
	
	oView:EnableTitleView( "VwFieldN80" )
	
	oView:SetCloseOnOk( {||.t.} )
Return oView


/*/{Protheus.doc} InitFields
//Inicializa o tipo do emblocamento
@author carlos.augusto
@since 16/06/2017
@version undefined

@type function
/*/
Static Function InitFields(oModel)

	If oModel:GetOperation() !=  MODEL_OPERATION_VIEW .And. oModel:GetOperation() !=  MODEL_OPERATION_DELETE
		oModel:SetValue('MdFieldN80', 'N80_TIPEMB', '2' )
	EndIf

Return .T.

/*/{Protheus.doc} UBAA080VLD
//TODO Função de validação dos campos da grid
@author silvana.torres
@since 04/05/2017
@version undefined

@type function
/*/
Function UBAA080VLD()
	Local lRet    	:= .T.
	Local oModel   		:= FWModelActive()
	Local oStruN81HVI 	:= oModel:GetModel( 'MdGrdN81HVI' )	
 
	If "N81_VLDE" $ ReadVar()
		if (!Empty(oStruN81HVI:GetValue('N81_VLDE')) .And. oStruN81HVI:GetValue('N81_VLATE') > 0)
		 	if ( oStruN81HVI:GetValue('N81_VLDE') > oStruN81HVI:GetValue('N81_VLATE') )  
		 		oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0008, STR0009, "", "") /*Valor inválido*/ /*Informe um valor inicial menor que o valor final"*/
		 		lRet := .F.
		 	endIf
		 endIf
	EndIf

	If "N81_VLATE" $ ReadVar()
		if (!Empty(oStruN81HVI:GetValue('N81_VLATE'))) 
		 	if ( oStruN81HVI:GetValue('N81_VLATE') < oStruN81HVI:GetValue('N81_VLDE') )  
		 		oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0008, STR0010, "", "") /*Informe um valor final maior que o valor inicial."*/
		 		lRet := .F.
		 	endIf
		 endIf
	EndIf            
	
Return lRet


/*{Protheus.doc} U080FiltrH
(Filtro das grids)
@type function
@author silvana.torres
@since 04/05/2017
@version 1.0
@return ${Character}, ${Query}
*/
Static Function U080FiltrH()
	Local cQry      := ""
	
	cQry  := " N81_TIPREG = '1' "
		
Return cQry


Function UBAA080TRH()
	Local oModel	:= FWModelActive()
	
	oModel:SetValue('MdGrdN81HVI', 'N81_TIPREG', '1 ')
	oModel:SetValue('MdGrdN81HVI', 'N81_TIPEMB', '2' )

Return .T.


/*{Protheus.doc} UBAA080POS
(Pós Modelo para gravação dos dados)
@type function
@author silvana.torres
@since 15/05/2017
@version 1.0
@param oModel, objeto, (Modelo de Dados)
@return ${Logico}, ${.T. = Ok}
*/
Static Function UBAA080POS(oModel)
	Local nOperation 		:= oModel:GetOperation()
	Local nI				:= 0
	Local oStruN81HVI 		:= oModel:GetModel( 'MdGrdN81HVI' )	
	Local nLines			:= 0
	Local nDelLin			:= 0
	Local nSeq				:= 0
	Local lRet				:= .T.
	
	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
	
		// Realiza reordenação devido a linhas deletadas - HVI		
		nLines := oStruN81HVI:Length()
		nDelLin := 0
		For nI := 1 To nLines
			If !Empty(oStruN81HVI:GetValue("N81_CODREG",1))
				If oStruN81HVI:IsDeleted(nI)
					nDelLin++
				Else
					oStruN81HVI:GoLine(nI)
					nSeq := Val(oStruN81HVI:GetValue("N81_SEQ")) - nDelLin
					oStruN81HVI:LoadValue("N81_SEQ", PadL(AllTrim(Str(nSeq)), TamSx3('N81_SEQ')[1], "0"))					
				EndIf
			endIf
		Next	
		
		
		nLines := oStruN81HVI:Length()
		For nI := 1 To nLines
			oStruN81HVI:GoLine(nI)
			If !Empty(oStruN81HVI:GetValue("N81_CODREG",nI))
				If !oStruN81HVI:IsDeleted(nI)
					if oStruN81HVI:GetValue("N81_VLATE") <= 0
					     oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0008, STR0011, "", "")	 /*Há análises HVI sem valor final informado*/
					     lRet := .F.
					endIf					
				EndIf
			endIf
		Next	
		
		if lRet == .T.
			For nI := 1 To nLines
				oStruN81HVI:GoLine(nI)
				If Empty(oStruN81HVI:GetValue("N81_CODREG",nI))				
					oStruN81HVI:DeleteLine()
				endIf
			Next
			
		endIf	
	endIf	
	
Return lRet

/*{Protheus.doc} UBAA080GRV
Função que grava o modelo de dados após a confirmação
@type function
@author silvana.torres
@since 02/06/2017
@version 1.0
@param oModel, objeto, (Modelo de Dados)
@return ${Logico}, ${.T. = Ok}
*/
Static Function UBAA080GRV(oModel)
	Local nOperac 	:= oModel:GetOperation()
	Local lRet		:= .T.
	
	If nOperac == MODEL_OPERATION_INSERT .Or. nOperac == MODEL_OPERATION_UPDATE	
		lRet := oModel:VldData()		
	EndIf
	
	// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
	if lRet 
		lRet := FWFormCommit(oModel)
	endIf
	
Return lRet

/*{Protheus.doc} UBAA080WHN
(When para os campos De e Ate)
@type function
@author carlos.augusto
@since 04/05/2017
@version 1.0
*/
Function UBAA080WHN()
	Local lRet 		:= .T.
	Local oModel   	:= FWModelActive()
	Local oModelHVI := oModel:GetModel( 'MdGrdN81HVI' )
	
	If Empty(oModelHVI:GetValue('N81_CODREG'))
		lRet := .F.
	EndIf

Return lRet

/*{Protheus.doc} AgrHVIVld
(Valid para o campo de HVI)
@type function
@author carlos.augusto
@since 04/05/2017
@version 1.0
*/
Static Function AgrHVIVld()
	Local lRet 		:= .T.
	Local oModel   	:= FWModelActive()
	Local oModelHVI := oModel:GetModel( 'MdGrdN81HVI' )
	Local oStruDX7	:= Nil
	Local nIt		:= 0
	
	oModelHVI:LoadValue('N81_VLDE',0)
	oModelHVI:LoadValue('N81_VLATE',0)

	oStruDX7 := FwFormStruct(1, "DX7", {|cCampo| ALLTRIM(cCampo) $ __cCampDX7}) // Obtem a estrutura da DX7
	
	For nIt := 1 To Len(oStruDX7:AFIELDS)	// Percore os campos da DX7
		// Comapara os Titulos dos campos a fim de encontrar o campo informado na N7F_HVIDES	 
		If UPPER(AllTrim(oStruDX7:AFIELDS[nIt][1])) == UPPER(AllTrim(FwFldGet("N81_CODREG")))
			// Se os valor encontrado é diferente do que contem no campo, preenche o campo
			If AllTrim(oStruDX7:AFIELDS[nIt][3]) != AllTrim(FwFldGet("N81_CAMPO")) 
				FwFldPut('N81_CAMPO', oStruDX7:AFIELDS[nIt][3], , , , .T.)
				lRet := .T.
				Exit
			Else // Senão o valor ja está contido no campo
				lRet := .T.
				Exit
			EndIf
		Else // Caso não encontrar o campo, o valor informado é invalido
			lRet := .F.
		EndIf
	Next nIt
	If Empty(FwFldGet("N81_CODREG")) // Se o campo informado estiver vazio, limpa o campo hvi
		FwFldPut('N81_CAMPO', "", , , , .T.)
		lRet := .T.
	
	EndIf	
	
Return lRet