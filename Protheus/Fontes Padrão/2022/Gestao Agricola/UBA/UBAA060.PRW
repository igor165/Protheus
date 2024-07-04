#INCLUDE "UBAA060.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"

Static __cRet :=''
Static __cCampDX7 := "DX7_MIC,DX7_RES,DX7_FIBRA,DX7_UI,DX7_SFI,DX7_ELONG,DX7_LEAF,DX7_AREA,DX7_CSP,DX7_CG,DX7_MAISB,DX7_RD,DX7_COUNT,DX7_UHM,DX7_SCI" 

/*/{Protheus.doc} UBAA060
//Função base para a Regra de Emblocamento
@author jeferson.chaves
@since 02/05/2017
@version undefined

@type function
/*/
Function UBAA060()
	Local aArea 	:= GetArea()
	Local oBrowse
    
	If .Not. TableInDic('N80')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif	
    
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('N80')
    oBrowse:SetFilterDefault(" N80_TIPEMB == '1'")
	oBrowse:SetMenuDef('UBAA060')
    oBrowse:SetDescription(STR0001) //#Regras de Emblocamento
	oBrowse:Activate()	
	
	RestArea(aArea)
Return nil

/*/{Protheus.doc} MenuDef
//TODO Descrição auto-gerada.
@author jeferson.chaves
@since 02/05/2017
@version undefined

@type function
/*/
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.UBAA060' OPERATION 2 ACCESS 0    // 'Visualizar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.UBAA060' OPERATION 3 ACCESS 0    // 'Incluir'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.UBAA060' OPERATION 4 ACCESS 0    // 'Alterar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.UBAA060' OPERATION 5 ACCESS 0    // 'Excluir'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.UBAA060' OPERATION 8 ACCESS 0    // 'Imprimir'
	ADD OPTION aRotina TITLE STR0022 ACTION 'VIEWDEF.UBAA060' OPERATION 9 ACCESS 0 	  // 'Copiar'
	
Return aRotina

/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author jeferson.chaves
@since 02/05/2017
@version undefined

@type function
/*/
Static Function ModelDef()
	Local oModel   		:= Nil
	Local oStruN80 		:= FwFormStruct( 1, "N80" )
	Local oStruN81HVI 	:= FwFormStruct( 1, "N81" )
	Local oStrN81Con 	:= FwFormStruct( 1, "N81" )
	
	oModel := MPFormModel():New('UBAA060',/*bPre*/ , {|oModel| UBAA060POS(oModel)} /*bPos*/, {|oModel| UBAA060GRV(oModel)},)
	
	//-------------------------------------
	// Adiciona a estrutura da Field
	//-------------------------------------
	oModel:AddFields( 'MdFieldN80', /*cOwner*/, oStruN80 )
	oModel:SetPrimaryKey( { "N80_FILIAL", "N80_CODIGO" } )
	oModel:GetModel( 'MdFieldN80' ):SetDescription( STR0006 )//Regras de Emblocamento
	
	//-------------------------------------
	// Adiciona a estrutura da Grid 
	//-------------------------------------
	oModel:AddGrid( 'MdGrdN81HVI', 'MdFieldN80', oStruN81HVI)
	oModel:AddGrid( 'MdGrN81Con', 'MdFieldN80', oStrN81Con)
	
	oModel:GetModel( 'MdGrdN81HVI'):SetUniqueLine( {'N81_CODREG'} )
	oModel:GetModel( 'MdGrN81Con' ):SetUniqueLine( {'N81_CODREG'} )	

	//-------------------------------------
	// Seta campos obrigatorios
	//-------------------------------------	
	oStruN80:SetProperty( 'N80_PCTFRM' , MODEL_FIELD_OBRIGAT , .T.)
	
	If FWIsInCallStack('AGRA720')	
		oStruN80:SetProperty( 'N80_ATIVO' , MODEL_FIELD_OBRIGAT, .F.)
		oStruN80:SetProperty( 'N80_QTDFAR' , MODEL_FIELD_OBRIGAT, .T.)
	EndIf
	
	oStruN81HVI:SetProperty( 'N81_VLDE'   , MODEL_FIELD_OBRIGAT , .F.)	
	
	
	oStrN81Con:SetProperty( 'N81_CODREG' , MODEL_FIELD_TAMANHO , TamSX3('N76_CODIGO')[1])

	//-------------------------------------
	// Trigger para N81_TIPREG
	//-------------------------------------
	oStruN81HVI:SetProperty( 'N81_CODREG' , MODEL_FIELD_WHEN ,  {|| UBAA060TRH()})
	oStrN81Con:SetProperty( 'N81_CODREG' , MODEL_FIELD_WHEN ,  {|| UBAA060TRC()})
	
	oStruN81HVI:SetProperty( 'N81_CODREG' , MODEL_FIELD_VALID ,  {|| AgrHVIVld()})
	oStrN81Con:SetProperty( 'N81_CODREG' , MODEL_FIELD_VALID  ,  {|| A060VLDCTM(oModel)})
			
	//-------------------------------------
	// Seta linha unica da grid
	//-------------------------------------
	oModel:GetModel( 'MdGrdN81HVI' ):SetUniqueLine( {'N81_CODREG'} )
	oModel:GetModel( 'MdGrN81Con'  ):SetUniqueLine( {'N81_CODREG'} )
	
	oModel:GetModel( 'MdGrdN81HVI'):SetLoadFilter( , U060FiltrH()) // Carrega o filtro da grid de HVI
	oModel:GetModel( 'MdGrN81Con' ):SetLoadFilter( , U060FiltrC()) // Carrega o filtro da grid de contaminantes
	
	//-------------------------------------
	// Seta preenchimento opcional da Grid
	//-------------------------------------
	oModel:GetModel( "MdGrdN81HVI"):SetOptional( .T. )
	oModel:GetModel( "MdGrN81Con" ):SetOptional( .T. )
	
	//-------------------------------------
	// Seta relacionamento
	//-------------------------------------
	oModel:SetRelation( 'MdGrdN81HVI', { { 'N81_FILIAL', 'xFilial( "N81" )' }, { 'N81_CODEMB', 'N80_CODIGO' },{ 'N81_TIPEMB', 'N80_TIPEMB' } })
	oModel:SetRelation( 'MdGrN81Con' , { { 'N81_FILIAL', 'xFilial( "N81" )' }, { 'N81_CODEMB', 'N80_CODIGO' },{ 'N81_TIPEMB', 'N80_TIPEMB' } })  
	
	//-------------------------------------
	// Valida apos a Ativação do model
	//-------------------------------------
	oModel:SetActivate({|oModel|InitFields(oModel)}) // Inicializa os campos conforme o pergunte

Return oModel

/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author jeferson.chaves
@since 02/05/2017
@version undefined

@type function
/*/
Static Function ViewDef()

	Local oStruN80		:= FWFormStruct(2,"N80")
	Local oStruN81HVI 	:= FWFormStruct(2,'N81')
	Local oStrN81Con 	:= FWFormStruct(2,'N81')
	Local oModel   		:= FWLoadModel( "UBAA060" )
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
	oView:AddGrid( 'VIEW_N81Con', oStrN81Con, 'MdGrN81Con' )
	
	//-------------------------------------------
	// Remove campos da estrurura HVI da view
	//-------------------------------------------
	oStruN81HVI:RemoveField( "N81_FILIAL" )
	oStruN81HVI:RemoveField( "N81_CODEMB" )
	oStruN81HVI:RemoveField( "N81_DESC" )
	oStruN81HVI:RemoveField( "N81_TIPREG" )
	oStruN81HVI:RemoveField( "N81_CAMPO" )
	oStruN81HVI:RemoveField( "N81_TIPEMB" )
		
	oStrN81Con:RemoveField( "N81_FILIAL" )
	oStrN81Con:RemoveField( "N81_CODEMB" )
	oStrN81Con:RemoveField( "N81_VLDE" )
	oStrN81Con:RemoveField( "N81_VLATE" )
	oStrN81Con:RemoveField( "N81_TIPREG" )
	oStrN81Con:RemoveField( "N81_CAMPO" )
	oStrN81Con:RemoveField( "N81_TIPEMB" )
	
	//-------------------------------------------
	// Remove campos da estrurura principal da view
	//-------------------------------------------
	oStruN80:RemoveField( "N80_TIPEMB" )
	oStruN80:RemoveField( "N80_PRCALT" )
	oStruN80:RemoveField( "N80_RESERV" )
	oStruN80:RemoveField( "N80_OK")
	
	
	If FWIsInCallStack('AGRA720')
		oStruN80:RemoveField( "N80_RELEVA" )
		oStruN80:RemoveField( "N80_ATIVO" )
		oStruN80:RemoveField( "N80_PCTFRM" )
	Else
		oStruN80:RemoveField( "N80_QTDFAR" )
		oStruN80:RemoveField( "N80_PSMAX" )
	EndIf
	
	oStrN81Con:SetProperty( 'N81_CODREG' , MVC_VIEW_LOOKUP, 'N76' )	/*zoom de contaminantes*/

	//----------------------
	//Cria o Box Horizontal
	//----------------------

	oView:CreateHorizontalBox( "SUPERIOR" , 40 )	
	oView:CreateHorizontalBox( 'MEIO'	  , 30 )
	oView:CreateHorizontalBox( 'RODAPE'	  , 30 )	

	// ------------
	// Cria Folder
	// ------------
	oView:CreateFolder( 'HVIFolder', 'MEIO')
	oView:AddSheet( 'HVIFolder', 'PASTA01', STR0007)
	
	oView:CreateFolder( 'ContFolder', 'RODAPE')
	oView:AddSheet( 'ContFolder', 'PASTA01', STR0013)
	
	// ----------
	// Cria Box
	// ----------
	oView:CreateHorizontalBox( 'PASTAHVI',  100, , , 'HVIFolder', 'PASTA01' )
	oView:CreateHorizontalBox( 'PASTACont', 100, , , 'ContFolder', 'PASTA01' )
	
	//----------------------
	//Seta owner da view
	//----------------------
	oView:SetOwnerView( "VwFieldN80", "SUPERIOR" )
	oView:SetOwnerView( 'VIEW_N81HVI', 'PASTAHVI' )
	oView:SetOwnerView( 'VIEW_N81Con', 'PASTACont' )
	
	
	// ---------------------------------
	// Seta o Campo incremental da Grid
	// ---------------------------------
	oView:AddIncrementField( 'VIEW_N81HVI', 'N81_SEQ' )
	oView:AddIncrementField( 'VIEW_N81Con', 'N81_SEQ' )
	
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
		If FWIsInCallStack('AGRA720')
			oModel:SetValue('MdFieldN80', 'N80_TIPEMB', '3' )
		Else
			oModel:SetValue('MdFieldN80', 'N80_TIPEMB', '1' )
		EndIf
		
	EndIf
	
	If oModel:GetOperation() == 3 /*Copiar ou Incluir vem como operation 3 */
		oModel:SetValue('MdFieldN80', 'N80_ATIVO', "1" )
		If FWIsInCallStack('AGRA720')
			oModel:SetValue('MdFieldN80', 'N80_RELEVA', 1 )
			oModel:SetValue('MdFieldN80', 'N80_CODIGO', "")
		Else
			oModel:SetValue('MdFieldN80', 'N80_RELEVA', 0 )
		EndIf
	EndIf

Return .T.

/*/{Protheus.doc} UBAA060VLD
//TODO Função de validação dos campos da grid
@author silvana.torres
@since 04/05/2017
@version undefined

@type function
/*/
Function UBAA060VLD()
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


/*/{Protheus.doc} ValidMrk
Exibe markbrowse. Consulta especifica N80ES1
@author carlos.augusto
@since 18/04/2017
/*/
Function UBAA060TPC()
	Local aArea     := GetArea()
	Local oDlg	    := Nil
	Local oFwLayer  := Nil
	Local oPnDown   := Nil
	Local oSize     := Nil
	Local lRet      := .T.
	Local aCampos 	:= {'DXA_CODIGO', 'DXA_DESCRI'}
	Local oModel	:= FWModelActive()
  	Local oStruN80	:= oModel:GetModel("MdFieldN80")	
	Local oBrwMrk 	:= Nil
	
	__cRet	:=IIF(IsInCallStack("UBAA060"),oStruN80:GetValue("N80_TPCLAS"), &( ReadVar() )) //variavel private para enxergar na consulta

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3] *0.8, oSize:aWindSize[4]*0.8,;
	STR0020 , , , , , CLR_BLACK, CLR_WHITE, , , .t. ) 

	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlg, .f., .t. )

	oFWLayer:AddLine( 'UP', 10, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )

	oFWLayer:AddLine( 'DOWN', 90, .F. )
	oFWLayer:AddCollumn( 'ALL' , 100, .T., 'DOWN' )
	oPnDown := TPanel():New( oSize:GetDimension("ALL","LININI"), oSize:GetDimension("ALL","COLINI"),;
			 ,oDlg, , , , , ,oSize:GetDimension("ALL","COLEND")/1.26, oSize:GetDimension("ALL","LINEND")/1.5)

	oBrwMrk := FWMarkBrowse():New()   // Cria o objeto oMark - MarkBrowse
	oBrwMrk:SetDescription( STR0020 ) // "Tipos de Classificação Comercial" 
	oBrwMrk:SetFilterDefault("DXA->DXA_FILIAL = '" + FwXFilial("DXA") + "'")
	oBrwMrk:SetAlias("DXA") 
	oBrwMrk:SetFieldMark("DXA_OK")	// Define o campo utilizado para a marcacao
	oBrwMrk:SetOnlyFields(aCampos)			
	oBrwMrk:SetSemaphore(.F.)	// Define se utiliza marcacao exclusiva
	oBrwMrk:SetMenuDef("")	// Desabilita a opcao de imprimir
	oBrwMrk:Activate(oPnDown)	// Ativa o MarkBrowse
	MarkItens(oBrwMrk, __cRet)
	
	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar(oDlg,{|| SelTpClass( oBrwMrk ), oDlg:End(), NIL},{|| Iif(IsInCallStack("OGA290"), _lCeoga290 := .T.,), oDlg:End() },,/* @aButtons */) } )
	
	RestArea(aArea)

Return lRet


/*/{Protheus.doc} SelTpClass
//Realiza o preenchimento do campo de tipos de classificacao comercial conforme preenchimento
//na consulta especifica N80ES1
@author carlos.augusto
@since 05/05/2017
@version undefined
@param oBrwMrk
@type function
/*/
Static Function SelTpClass(oBrwMrk)
	Local lRet 			:= .T.
	Local aArea			:= GetArea()
    Local cTiposClas	:= ""
    
	DXA->(dbGoTop())
	While .Not. DXA->(Eof())
		If oBrwMrk:IsMark()
			If !Empty(cTiposClas)
				cTiposClas += " OU "
			EndIf
			cTiposClas += DXA->DXA_CODIGO
		EndIf
		DXA->(dbSkip())
	EndDo

	__cRet := cTiposClas
	
	RestArea(aArea)
	oBrwMrk:Refresh()
	oBrwMrk:GoTop()
Return lRet


/*/{Protheus.doc} MarkItens
//Realiza a pre-marcacao dos itens ao abrir a consulta especifica N80ES1
@author carlos.augusto
@since 08/05/2017
@type function
/*/	
Static Function MarkItens(oBrwMrk,cTiposClas)
	Local aArea			:= GetArea()
    Local aClass		:= STRTOKARR (cTiposClas , " OU " )
    Local nI
    
    If .Not. Empty(cTiposClas) 
            
		DXA->(dbGoTop())
		While .Not. DXA->(Eof())
		
			For nI := 1 To Len(aClass)
				If aClass[nI] = DXA->DXA_CODIGO
					oBrwMrk:MarkRec()
					Exit
				EndIf
			Next nI
		
			DXA->(dbSkip())
		EndDo
	
	EndIf
	
	RestArea(aArea)
	oBrwMrk:Refresh()
	oBrwMrk:GoTop()
	
Return .T.
	
/*/{Protheus.doc} UBAA060RET
//Retorno da Consulta especifica N80ES1
@author carlos.augusto
@since 08/05/2017
@type function
/*/	
Function UBAA060RET()
Return(__cRet)

/*/{Protheus.doc} UBAA060BLO
//Valida o preenchimento do campo de Tipos de Classificacao Comercial
@author carlos.augusto
@since 08/05/2017
@type function
/*/
Function UBAA060BLO(cFieldTip)
	Local lRet 			:= .F.
	Local oModel 	    := FWModelActive()
  	Local oStruN80		:= oModel:GetModel("MdFieldN80")
    Local cTiposClas	:= IIF(FwIsInCallStack("UBAA060") .Or. FwIsInCallStack("UBAA130SXB"),oStruN80:GetValue("N80_TPCLAS"), cFieldTip) //variavel private para enxergar na consulta
    Local aClass		:= STRTOKARR (cTiposClas , "OU" )
    Local aClClass		:= aClone(aClass)
    Local nI
	Local nX
    Local nPos
    Local nLenTxt		:=	Len( RTRIM(cTiposClas ))
    Local nNum1			:= 1
    Local nNum2			:= 2
    Local nTraco		:= 3
    Local nNum3			:= 4
    Local nEspac1		:= 5
    Local nNumOu		:= 6
    Local lExistItem	:= .F.

    If Empty(cTiposClas)
    	Return .T.
    ElseIf Len(AllTrim(cTiposClas)) > 252
    	Help('' ,1,".UBAA06000001.", , ,1,0) /* Quantidade de tipos de classificação excedida. É possível selecionar até 31 tipos de classificação. */
	    Return .F.
    EndIf
    
    //Verifica se o ultimo caracter e numero
    If !IsDigit( Substr( cTiposClas, nLenTxt, 1 ))
    	Help( , , STR0015, , STR0016 + STR0019 , 1, 0 )
	    Return .F. //#Atencao, Preenchimento invalido. Exemplo de preenchimento: 11-1 OU 21-1 OU 31-1
    EndIf
    
    //Valida cada caractere preenchido no campo
    For nPos := 1 to nLenTxt
    
	    If nNum1  == nPos .And. !IsDigit( Substr( cTiposClas, nPos, 1 )) .Or.;   //Digito 1
	       nNum2  == nPos .And. !IsDigit( Substr( cTiposClas, nPos, 1 )) .Or.;   //Digito 2
	       nTraco == nPos .And. ("-" !=  Substr( cTiposClas, nPos, 1 ))  .Or.;   //Digito 3 
	       nNum3  == nPos .And. !IsDigit( Substr( cTiposClas, nPos, 1 )) .Or.;   //Digito 4
	       nEspac1== nPos .And. (" " !=  Substr( cTiposClas, nPos, 1 ))  .Or.;   //Digito 5
	       nNumOu == nPos .And. ("OU" !=  UPPER(Substr( cTiposClas, nPos, 2 )))  //Digito 6 
	    
	    	Help( , , STR0015, , STR0016 + STR0019 , 1, 0 ) 
	    	Return .F. //#Atencao, Preenchimento invalido. Exemplo de preenchimento: 11-1 OU 21-1 OU 31-1
	    EndIf
	    
	    If Mod(nPos, 8) == 0
	        nNum1		+= 8
	        nNum2		+= 8
    		nTraco		+= 8
    		nNum3		+= 8
    		nEspac1		+= 8
    		nNumOu		+= 8
	    EndIf
    Next nPos
    
    //Valida cada tipo preenchido. Se ele existe na base
    If .Not. Empty(cTiposClas) 

		For nI := 1 To Len(aClass)
			lExistItem := .F.
		    dbSelectArea("DXA")
			dbsetorder(1)
			If Len(AllTrim(aClass[nI])) == 4 .And. dbSeek(FwXFilial("DXA") + AllTrim(aClass[nI]))
				lRet := .T.
			Else
				Help( , , STR0015, , STR0016 +  STR0018 + aClass[nI], 1, 0 ) 
				Return .F.  //#Atencao, Preenchimento invalido. Tipo de classificação inexistente: 
			EndIf
			
			//Valida se esta duplicado
			For nX := 1 To Len(aClClass)
				If lExistItem .And. AllTrim(aClass[nI]) == AllTrim(aClClass[nX])
					Help( , , STR0015, , STR0016 + STR0017 + aClass[nI], 1, 0 ) //#Atencao
					Return .F.
				EndIf
			
				If AllTrim(aClass[nI]) == AllTrim(aClClass[nX])
					lExistItem := .T. //#Atencao, Preenchimento invalido. Tipo de classificação duplicado:
					
				EndIf
			Next nX
		Next nI
		
	EndIf

Return lRet

/*{Protheus.doc} U060FiltrH
(Filtro das grids)
@type function
@author silvana.torres
@since 04/05/2017
@version 1.0
@return ${Character}, ${Query}
*/
Static Function U060FiltrH()
	
	Local cQry      := ""
	
	cQry  := " N81_TIPREG = '1' "
	
		
Return cQry

/*{Protheus.doc} U060FiltrC
(Filtro da grid de contaminante)
@type function
@author silvana.torres
@since 04/05/2017
@version 1.0
@return ${Character}, ${Query}
*/
Static Function U060FiltrC()
	
	Local cQry      := ""
	
	cQry  := " N81_TIPREG = '2' "	
		
Return cQry

Function UBAA060TRH()
	Local oModel	:= FWModelActive()
	
	oModel:SetValue('MdGrdN81HVI', 'N81_TIPREG', '1 ' )
	
	If FWIsInCallStack('AGRA720')
		oModel:SetValue('MdGrdN81HVI', 'N81_TIPEMB', '3' )
	Else 
		oModel:SetValue('MdGrdN81HVI', 'N81_TIPEMB', '1' )
	EndIf
	
Return .T.


Function UBAA060TRC()
	Local oModel	:= FWModelActive()
	
	oModel:SetValue('MdGrN81Con', 'N81_TIPREG', '2 ' )
	
	If FWIsInCallStack('AGRA720')
		oModel:SetValue('MdGrN81Con', 'N81_TIPEMB', '3' )
	Else
		oModel:SetValue('MdGrN81Con', 'N81_TIPEMB', '1' )
	EndIf
	
	
Return .T.

Function A060VLDCTM(oModel)
	Local lRet   := .T. 
	Local oMDCTM := oModel:GetModel('MdGrN81Con')
	Local aArea  := GetArea()

	dbSelectArea('N76')
	dbSetOrder(1)
	
	lRet := N76->(dbSeek(xFilial('N76') + oMDCTM:GetValue('N81_CODREG')))

	Restarea(aArea)

Return lRet

/*{Protheus.doc} UBAA060POS
(Pós Modelo para gravação dos dados)
@type function
@author silvana.torres
@since 15/05/2017
@version 1.0
@param oModel, objeto, (Modelo de Dados)
@return ${Logico}, ${.T. = Ok}
*/
Static Function UBAA060POS(oModel)

	Local nOperation 		:= oModel:GetOperation()
	Local nI				:= 0
	Local oStruN80	 		:= oModel:GetModel( 'MdFieldN80' )
	Local oStruN81HVI 		:= oModel:GetModel( 'MdGrdN81HVI' )	
	Local oStrN81Con 		:= oModel:GetModel( 'MdGrN81Con' )	
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
		
		// Realiza reordenação devido a linhas deletadas - Contaminante
		nLines 	:= oStrN81Con:Length()
		nDelLin := 0
		For nI := 1 To nLines
			If !Empty(oStrN81Con:GetValue("N81_CODREG",1))
				If oStrN81Con:IsDeleted(nI)
					nDelLin++
				Else
					oStrN81Con:GoLine(nI)
					nSeq := Val(oStrN81Con:GetValue("N81_SEQ")) - nDelLin
					oStrN81Con:LoadValue("N81_SEQ", PadL(AllTrim(Str(nSeq)), TamSx3('N81_SEQ')[1], "0"))
				EndIf
			endIf
		Next
		
		nLines := oStruN81HVI:Length()
		For nI := 1 To nLines
			oStruN81HVI:GoLine(nI)
			If !Empty(oStruN81HVI:GetValue("N81_CODREG",nI))
				If !oStruN81HVI:IsDeleted(nI)
					if oStruN81HVI:GetValue("N81_VLATE") <= 0
					     oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0008, STR0021, "", "")	 /*Há análises HVI sem valor final informado*/
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
			
			nLines := oStrN81Con:Length()
			For nI := 1 To nLines
				oStrN81Con:GoLine(nI)
				If Empty(oStrN81Con:GetValue("N81_CODREG",nI))				
					oStrN81Con:DeleteLine()
				endIf
			Next
		endIf
	endIf
	
	If FWIsInCallStack('AGRA720') .And. nOperation == MODEL_OPERATION_DELETE
		If oStruN80:GetValue("N80_TIPEMB") = "1" .Or. oStruN80:GetValue("N80_TIPEMB") = "2"
			//"Não é possível excluir uma regra diferente de específica a partir dessa rotina. Favor selecionar uma regra específica para exclusão." 
			oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0023, STR0024, "", "")
			lRet := .F.	 
		EndIf
	EndIf	
	
Return lRet

/*{Protheus.doc} UBAA060GRV
Função que grava o modelo de dados após a confirmação
@type function
@author silvana.torres
@since 02/06/2017
@version 1.0
@param oModel, objeto, (Modelo de Dados)
@return ${Logico}, ${.T. = Ok}
*/
Static Function UBAA060GRV(oModel)

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

/*{Protheus.doc} UBAA060WHN
(When para os campos De e Ate)
@type function
@author carlos.augusto
@since 04/05/2017
@version 1.0
*/
Function UBAA060WHN()
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

