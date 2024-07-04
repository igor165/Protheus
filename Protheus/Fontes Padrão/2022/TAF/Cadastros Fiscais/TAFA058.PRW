#INCLUDE "Protheus.CH"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "TAFA058.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA058
Cadastro MVC de Bens ou Componentes do Ativo Imobilizado

@author Fabio V. Santana
@since 23/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA058()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Cadastro de Bens ou Componentes do Ativo Imobilizado
oBrw:SetAlias( 'C2L')
oBrw:SetMenuDef( 'TAFA058' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V. Santana
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()   
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf058Vld" , "2" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA058' OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA058" , , aFuncao)
EndIf                                     

Return( aRotina )  
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC2L 	:= 	FWFormStruct( 1, 'C2L' )        
Local oModel 	    := MPFormModel():New( 'TAFA058' ,,,{ |oModel| SaveModel( oModel ) } )         

oModel:AddFields('MODEL_C2L', /*cOwner*/, oStruC2L)  
oModel:GetModel( "MODEL_C2L" ):SetPrimaryKey( { "C2L_CODBEM", "C2L_IDENTM" } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA058' )
Local 	oStruC2L 	:= 	FWFormStruct( 2, 'C2L' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C2L', oStruC2L, 'MODEL_C2L' )

oView:EnableTitleView( 'VIEW_C2L', STR0001 ) //Cadastro de Bens ou Componentes do Ativo Imobilizado
oView:CreateHorizontalBox( 'FIELDSC2L', 100 )
oView:SetOwnerView( 'VIEW_C2L', 'FIELDSC2L' )

If TamSX3("C2L_CODCTA")[1] == 36
	oStruC2L:RemoveField("C2L_CODCTA")
	oStruC2L:SetProperty("C2L_CTACTB", MVC_VIEW_ORDEM, "08")	
	oStruC2L:SetProperty("C2L_DCODCT", MVC_VIEW_ORDEM, "09")
	oStruC2L:SetProperty("C2L_NRPARC", MVC_VIEW_ORDEM, "10")
	oStruC2L:SetProperty("C2L_CODCUS", MVC_VIEW_ORDEM, "11")
	oStruC2L:SetProperty("C2L_DCODCU", MVC_VIEW_ORDEM, "12")
	oStruC2L:SetProperty("C2L_FUNC",   MVC_VIEW_ORDEM, "13")
	oStruC2L:SetProperty("C2L_VIDAUT", MVC_VIEW_ORDEM, "14")	
EndIf

Return oView	           

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo
                                                                                                                               
@param  oModel -> Modelo de dados
@return .T.

@author Paulo Sérgio V.B. Santana
@since 12/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local 	nOperation 	:= 	oModel:GetOperation()  

Begin Transaction
	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( 'C2L', " " ) //Limpa o Status do Registro, tornando possível nova validação.
	Endif          
	FwFormCommit( oModel )			
End Transaction

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf058Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões 

lJob - Informa se foi chamado por Job

@return .T.

@author Paulo V.B. Santana
@since 17/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf058Vld( cAlias, nRecno, nOpc, lJob )

Local cChave   := ""
Local cTipoCC  := ""
Local aLogErro := {}
Local aAreaAnt := {}

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C2L->( Recno() )

If C2L->C2L_STATUS $ " 1"

	If Empty( C2L->C2L_CODPRN )
		If C2L->C2L_IDENTM == "2"
			aAdd( aLogErro, { "C2L_CODPRN", "000583", "C2L", nRecno } ) //"Se a identificação do tipo de mercadoria for 'componente'('Cod.Ident' igual a '2'), este campo deve obrigatoriamente estar preenchido com o código do bem principal."
		EndIf
	Else
		aAreaAnt := C2L->( GetArea() )

		C2L->( DBSetOrder( 3 ) )
		If C2L->( MsSeek( xFilial("C2L") + C2L->C2L_CODPRN ) )
			If C2L->C2L_STATUS $ " 1" .or. C2L->C2L_IDENTM <> "1"
				aAdd( aLogErro, { "C2L_CODPRN", "000584", "C2L", nRecno } ) //"O conteúdo deste campo deve se referir a outro registro não cadastrado com identificação do tipo de mercadoria 'componente'('Cod.Ident' igual a '2').
			EndIf
		EndIf

		RestArea( aAreaAnt )
	EndIf
	
	If Empty( C2L->C2L_CODBEM )
		aAdd( aLogErro, { "C2L_CODBEM", "000010", "C2L", nRecno } ) //"Campo Inconsistente ou Vazio"
	EndIf
	
	If Empty( C2L->C2L_DESCRI )
		aAdd( aLogErro, { "C2L_DESCRI", "000010", "C2L", nRecno } ) //"Campo Inconsistente ou Vazio"
	EndIf
	
	If Empty( C2L->C2L_NRPARC )
		aAdd( aLogErro, { "C2L_NRPARC", "000010", "C2L", nRecno } ) //"Campo Inconsistente ou Vazio"
	EndIf
	
	If Empty( C2L->C2L_FUNC )
		aAdd( aLogErro, { "C2L_FUNC", "000010", "C2L", nRecno } ) //"Campo Inconsistente ou Vazio"
	EndIf
	
	If Empty( C2L->C2L_IDENTM )
		aAdd( aLogErro, { "C2L_IDENTM", "000010", "C2L", nRecno } ) //"Campo Inconsistente ou Vazio"
	EndIf
	
	If Empty( C2L->C2L_CODCTA )
		aAdd( aLogErro, { "C2L_CODCTA", "000010", "C2L", nRecno } ) //"Campo Inconsistente ou Vazio"
	Else
		cChave := C2L->C2L_CODCTA
		If xValRegTab( "C1O", cChave, 3,, @aLogErro,, { "C2L", "C2L_CODCTA", nRecno } )
			cTipoCC := Posicione( "C2R", 3, xFilial("C2R") + C1O->C1O_CODNAT, "C2R_CODIGO" )
			If cTipoCC <> "01"
				aAdd( aLogErro, { "C2L_CODCTA", "000585", "C2L", nRecno } ) //"O conteúdo informado deve ser conta do ativo ('Cod.Nat' igual a '01') do cadastro de Plano de Contas Contábeis."
			EndIf
		EndIf
	EndIf

	If !Empty( C2L->C2L_CODCUS )
		cChave := C2L->C2L_CODCUS
		xValRegTab( "C1P", cChave, 3,, @aLogErro,, { "C2L", "C2L_CODCUS", nRecno } )
	EndIf

	//Atualizo o Status do Registro
	If Len( aLogErro ) > 0
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos Usados
		If RecLock( "C2L", .F. )
			C2L->C2L_STATUS := "1"
			C2L->( MsUnlock() )
		EndIf
	Else
		If RecLock( "C2L", .F. )
			C2L->C2L_STATUS := "0"
			C2L->( MsUnlock() )
		EndIf
	EndIf

Else
	aAdd( aLogErro, { "C2L_ID", "000305", "C2L", nRecno } ) //Registros válidos não podem ser validados novamente
EndIf

If !lJob
	xValLogEr( aLogErro )
EndIf

Return( aLogErro )
