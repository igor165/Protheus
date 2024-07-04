#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "CTBS300.CH"

//Compatibilização de fontes 30/05/2018

Function CTBS300() 
Local oBrowse

oBrowse := FWmBrowse():New() 

oBrowse:SetAlias( 'CV5' ) 

oBrowse:SetDescription( STR0001 ) //'Cadastro Filtro LALUR'
oBrowse:SetFilterDefault( "CV5->CV5_FILIAL=='"+xFilial('CV5')+"' .And. CV5->CV5_EMPORI==CV5->CV5_EMPDES .And. CV5->CV5_FILORI==CV5->CV5_FILDES .And. Alltrim(CV5->CV5_CT1DES) == 'LALUR'" )

oBrowse:Activate() 

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MenuDef   ºAutor  ³Microsiga           º Data ³  03/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef() 
Local aRotina := {} 

ADD OPTION aRotina Title STR0002 Action 'PesqBrw'         OPERATION 1 ACCESS 0  //'Pesquisar'
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.CTBS300' OPERATION 2 ACCESS 0  //'Visualizar'
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.CTBS300' OPERATION 3 ACCESS 0  //'Incluir'
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.CTBS300' OPERATION 4 ACCESS 0  //'Alterar'
ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.CTBS300' OPERATION 5 ACCESS 0  //'Excluir'
ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.CTBS300' OPERATION 8 ACCESS 0  //'Imprimir'

Return aRotina


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ModelDef  ºAutor  ³Microsiga           º Data ³  03/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ModelDef() 
Local oStruCV51 := FWFormStruct( 1, 'CV5', /*bAvalCampo*/, /*lViewUsado*/ ) 
Local oStruCV52 := FWFormStruct( 1, 'CV5', /*bAvalCampo*/, /*lViewUsado*/ ) 
Local oModel
Local bCommit300 := {|oModel|Ctbs300Grv(oModel)}
Local cCodCV5    := Space(Len(CV5->CV5_COD))

oStruCV52:SetProperty( 'CV5_CT1ORI' 	, MODEL_FIELD_WHEN,{||.T.})
oStruCV52:SetProperty( 'CV5_CTTORI' 	, MODEL_FIELD_WHEN,{||.T.})
oStruCV52:SetProperty( 'CV5_CTDORI' 	, MODEL_FIELD_WHEN,{||.T.})
oStruCV52:SetProperty( 'CV5_CTHORI' 	, MODEL_FIELD_WHEN,{||.T.})

oStruCV52:SetProperty( 'CV5_CT1FIM'    , MODEL_FIELD_VALID,{|| IIF(Empty(oModel:GetModel( 'CV5DETAIL' ):GetValue('CV5_CT1ORI')), .T. ,(M->CV5_CT1FIM := oModel:GetModel( 'CV5DETAIL' ):GetValue('CV5_CT1FIM'),ExistCpo("CT1",M->CV5_CT1FIM,1))) } )
oStruCV52:SetProperty( 'CV5_CTTFIM'    , MODEL_FIELD_VALID,{|| IIF(Empty(oModel:GetModel( 'CV5DETAIL' ):GetValue('CV5_CTTORI')), .T., (M->CV5_CTTFIM := oModel:GetModel( 'CV5DETAIL' ):GetValue('CV5_CTTFIM'),ExistCpo("CTT",M->CV5_CTTFIM,1)))  } )
oStruCV52:SetProperty( 'CV5_CTDFIM'    , MODEL_FIELD_VALID,{|| IIF(Empty(oModel:GetModel( 'CV5DETAIL' ):GetValue('CV5_CTDORI')), .T. ,(M->CV5_CTDFIM := oModel:GetModel( 'CV5DETAIL' ):GetValue('CV5_CTDFIM'),ExistCpo("CTD",M->CV5_CTDFIM,1)))  } )
oStruCV52:SetProperty( 'CV5_CTHFIM'    , MODEL_FIELD_VALID,{|| IIF(Empty(oModel:GetModel( 'CV5DETAIL' ):GetValue('CV5_CTHORI')), .T. ,(M->CV5_CTHFIM := oModel:GetModel( 'CV5DETAIL' ):GetValue('CV5_CTHFIM'),ExistCpo("CTH",M->CV5_CTHFIM,1)))  } )
                                                                                                 
oStruCV52:SetProperty( 'CV5_EMPORI'    , MODEL_FIELD_VALID,{||.T.})
oStruCV52:SetProperty( 'CV5_FILORI'    , MODEL_FIELD_VALID,{||.T.})
oStruCV52:SetProperty( 'CV5_EMPDES'    , MODEL_FIELD_VALID,{||.T.})
oStruCV52:SetProperty( 'CV5_FILDES'    , MODEL_FIELD_VALID,{||.T.})
oStruCV52:SetProperty( 'CV5_CT1DES'    , MODEL_FIELD_VALID,{||.T.})

oStruCV52:SetProperty( 'CV5_EMPORI'    , MODEL_FIELD_WHEN,{||.T.})
oStruCV52:SetProperty( 'CV5_FILORI'    , MODEL_FIELD_WHEN,{||.T.})
oStruCV52:SetProperty( 'CV5_EMPDES'    , MODEL_FIELD_WHEN,{||.T.})
oStruCV52:SetProperty( 'CV5_FILDES'    , MODEL_FIELD_WHEN,{||.T.})
oStruCV52:SetProperty( 'CV5_CT1DES'    , MODEL_FIELD_WHEN,{||.T.})

oStruCV52:SetProperty( 'CV5_EMPORI'    , MODEL_FIELD_INIT,{||cEmpAnt})
oStruCV52:SetProperty( 'CV5_FILORI'    , MODEL_FIELD_INIT,{||cFilAnt})
oStruCV52:SetProperty( 'CV5_EMPDES'    , MODEL_FIELD_INIT,{||cEmpAnt})
oStruCV52:SetProperty( 'CV5_FILDES'    , MODEL_FIELD_INIT,{||cFilAnt})
oStruCV52:SetProperty( 'CV5_CT1DES'    , MODEL_FIELD_INIT,{||"LALUR"})

oStruCV52:SetProperty( 'CV5_COD'    	, MODEL_FIELD_OBRIGAT,.F.)

oStruCV52:AddTrigger( "CV5_CT1ORI" , "CV5_COD", {|| .T. }, {|oModel| S300AtuCod(oModel, 2, cCodCV5 ) } )
oStruCV52:AddTrigger( "CV5_CT1FIM" , "CV5_COD", {|| .T. }, {|oModel| S300AtuCod(oModel, 2, cCodCV5 ) } )

oStruCV51:SetProperty( 'CV5_COD'    , MODEL_FIELD_VALID,{|oModel| S300CodId(oModel)})
oStruCV51:SetProperty( 'CV5_COD'    , MODEL_FIELD_WHEN,{|| INCLUI })

oStruCV51:AddTrigger( "CV5_COD"    , "CV5_COD", {|| .T. }, {|oModel| S300AtuCod(oModel, 1, @cCodCV5) } )

oModel := MPFormModel():New( 'CTBS300',/*bPreValidacao*/, /*bPosValidacao*/, bCommit300, /*bCancel*/ ) 

oModel:AddFields( 'CV5MASTER', /*cOwner*/, oStruCV51, ) 
oModel:AddGrid( 'CV5DETAIL', 'CV5MASTER', oStruCV52, /*bLinePre*/, /*{||omodel:SetValue("CV5DETAIL","CV5_DESCRI","teste teste")}/*bLinePost*/, /*bPreVal*/,{|oGrid| Ctbs300TOK(oGrid)} /*bPosVal*/, /*BLoad*/ ) 

oModel:SetRelation("CV5DETAIL",{{"CV5_FILIAL","xFilial('CV5')"},{"CV5_COD","CV5_COD"}},CV5->(IndexKey()))								   								   

//oModel:SetPrimaryKey({"CV5_COD"})   

oModel:GetModel("CV5DETAIL"):SetUniqueLine({"CV5_COD","CV5_CT1ORI", "CV5_CTTORI", "CV5_CTDORI", "CV5_CTHORI"})

oModel:SetDescription( STR0001  )  //"Cadastro Filtro LALUR" 

oModel:GetModel( 'CV5MASTER' ):SetDescription( 'Master' ) 
oModel:GetModel( 'CV5DETAIL' ):SetDescription( 'Detail'  ) 

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ViewDef   ºAutor  ³Microsiga           º Data ³  03/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ViewDef() 
Local oStruCV51 := FWFormStruct( 2, 'CV5' ) 
Local oStruCV52 := FWFormStruct( 2, 'CV5' ) 
Local oModel   :=  FWLoadModel( 'CTBS300' ) 
Local oView
Local nX
Local cCampo
Local aCposNao := {}
Local cCposNao := 'CV5_COD|CV5_EMPORI|CV5_FILORI|CV5_EMPDES|CV5_FILDES|CV5_CT1DES|CV5_CTTDES|CV5_CTDDES|CV5_CTHDES|CV5_CT1IGU|CV5_CTTIGU|CV5_CTDIGU|CV5_CTHIGU'

cCposNao += "|CV5_CTDORI|CV5_CTDFIM|CV5_CTHORI|CV5_CTHFIM"

If CV5->(ColumnPos("CV5_DESCRI")) > 0
	cCposNao += "|CV5_DESCRI"
EndIf

//adiciona campos que serao removidos MASTER
For nX := 1 TO Len(oStruCV51:aFields)
	cCampo := Alltrim( oStruCV51:aFields[nX,1] )
	If CV5->(ColumnPos("CV5_DESCRI")) > 0
		If !( cCampo $ 'CV5_COD|CV5_DESCRI') 
			aAdd(aCposNao, cCampo )  
		EndIf
	Else
		If cCampo != 'CV5_COD' 
			aAdd(aCposNao, cCampo )  
		EndIf
	EndIf
Next nX
// Remove campos da estrutura MASTER
For nX := 1 TO Len(aCposNao)
	oStruCV51:RemoveField( aCposNao[nX] )
Next nX

aCposNao := {}
//adiciona campos que serao removidos DETAIL
For nX := 1 TO Len(oStruCV52:aFields)
	cCampo := Alltrim( oStruCV52:aFields[nX,1] )
	If cCampo $ cCposNao  
		aAdd(aCposNao, cCampo )  
	EndIf
Next nX

// Remove campos da estrutura DETAIL
For nX := 1 TO Len(aCposNao)
	oStruCV52:RemoveField( aCposNao[nX] )
Next nX

oStruCV52:SetProperty( 'CV5_CTTFIM'    , MVC_VIEW_LOOKUP  ,"CTT" )

oView := FWFormView():New() 
oView:SetModel( oModel ) 

oView:AddField( 'VIEW_CV51', oStruCV51, 'CV5MASTER' ) 
oView:AddGrid(  'VIEW_CV52', oStruCV52, 'CV5DETAIL' ) 

oView:CreateHorizontalBox( 'EMCIMA'  , 15 ) 
oView:CreateHorizontalBox( 'MEIO'    , 85 ) 

oView:SetOwnerView( 'VIEW_CV51', 'EMCIMA'   ) 
oView:SetOwnerView( 'VIEW_CV52', 'MEIO'     )   

Return oView        


Static Function Ctbs300Grv(oModel)
Local cCodigo 
Local nY
Local nOperation := oModel:GetOperation()
Local oModelDetail := oModel:GetModel('CV5DETAIL')
Local lContinua := .T.
Local nI := 0
Local cDescri := ""

If nOperation == MODEL_OPERATION_DELETE 

	FWFormCommit(oModel)

Else
	//alteracao deleta todos os registros e inclui novamente pois nao tem identificador de item e esta na mesma tabela cabecalho/item	
	If CV5->(ColumnPos("CV5_DESCRI")) > 0
		cDescri := oModel:GetValue( 'CV5MASTER', 'CV5_DESCRI')
	EndIf
	cCodigo := oModel:GetValue( 'CV5MASTER', 'CV5_COD') 
	CV5->( dbSeek( xFilial("CV5")+cCodigo ) ) 

	If nOperation == MODEL_OPERATION_INSERT 
		If CV5->( Found() )
			lContinua := .F.
		EndIf
	EndIf

	If lContinua
	
		While CV5->( ! Eof() .And. CV5_FILIAL+CV5_COD == xFilial("CV5")+cCodigo )
			CV5->( RecLock("CV5", .F. ) ) 
			CV5->( dbDelete() )
			CV5->( MsUnLock() )
			CV5->( dbSkip() )
		EndDo

		For nI := 1 To oModelDetail:Length()
			oModelDetail:GoLine( nI )
			
			If ! oModelDetail:IsDeleted()

				CV5->( RecLock("CV5", .T. ) ) 
			
				For nY := 1 TO Len(oModelDetail:aHeader)
					CV5->( FieldPut( nY, oModelDetail:GetValue( FieldName(nY) ) ) )
				Next
				CV5->CV5_FILIAL := xFilial("CV5")
				CV5->CV5_COD := cCodigo
				If CV5->(ColumnPos("CV5_DESCRI")) > 0
					CV5->CV5_DESCRI := cDescri
				EndIf
				CV5->( MsUnLock() )

			EndIf
			
		Next nI

	EndIf
	
EndIf

Return( lContinua )


Static Function S300AtuCod(oModel, nOpc, cCodigo)

If nOpc == 1
	cCodigo := oModel:GetValue( 'CV5_COD') 
Else
	oModel:SetValue( 'CV5_COD', cCodigo )
	oModel:LoadValue( 'CV5_EMPORI', cEmpAnt )
	oModel:LoadValue( 'CV5_FILORI', cFilAnt )
	oModel:LoadValue( 'CV5_EMPDES', cEmpAnt )
	oModel:LoadValue( 'CV5_FILDES', cFilAnt )
	oModel:LoadValue( 'CV5_CT1DES', "LALUR" )
EndIf

Return

Static Function S300CodId(oModel)
Local lRet := .T.
Local nOperation := oModel:GetOperation()
Local cCodigo

cCodigo := oModel:GetValue( 'CV5_COD') 

CV5->( dbSeek( xFilial("CV5")+cCodigo ) ) 

If nOperation == MODEL_OPERATION_INSERT 
	If CV5->( Found() )
		Help(" ",1,"JAGRAVADO")
		lRet := .F.
	EndIf
ElseIf nOperation == MODEL_OPERATION_UPDATE
	If ! CV5->( Found() )
		lRet := .F.
	EndIf
EndIf

Return( lRet )

Static Function Ctbs300TOK(oGrid) 
Local lRet := .T.
Local nI := 0
Local nOperation := oGrid:GetOperation()
Local oGridDetail := oGrid  

If nOperation == MODEL_OPERATION_UPDATE
		For nI := 1 To oGridDetail:Length()
			oGridDetail:GoLine( nI )
			
			If ! oGridDetail:IsDeleted()

				If Empty( oGridDetail:GetValue( "CV5_CT1ORI" ) )  .And. ;
					Empty( oGridDetail:GetValue( "CV5_CT1FIM" ) )  .And. ;
					Empty( oGridDetail:GetValue( "CV5_CTTORI" ) )  .And. ;
					Empty( oGridDetail:GetValue( "CV5_CTTFIM" ) )
					lRet := .F.

				ElseIf !Empty( oGridDetail:GetValue( "CV5_CT1ORI" ) )  .And. ;
						Empty( oGridDetail:GetValue( "CV5_CT1FIM" ) )
						lRet := .F.

				ElseIf !Empty( oGridDetail:GetValue( "CV5_CTTORI" ) )  .And. ;
						Empty( oGridDetail:GetValue( "CV5_CTTFIM" ) )
						lRet := .F.
				
				ElseIf !Empty( oGridDetail:GetValue( "CV5_CTDORI" ) )  .And. ;
						Empty( oGridDetail:GetValue( "CV5_CTDFIM" ) )
						lRet := .F.

				ElseIf !Empty( oGridDetail:GetValue( "CV5_CTHORI" ) )  .And. ;
						Empty( oGridDetail:GetValue( "CV5_CTHFIM" ) )
						lRet := .F.
				EndIf
			
				If !lRet
					Help(NIL, NIL, "NAOVAZIO", NIL,(STR0010 + STR0008 + Alltrim(Str(ni)) + STR0009), 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0011})	
					Exit
				EndIf  
			
			EndIf

		Next nI
EndIf

Return( lRet )


