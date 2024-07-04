#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA094.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA094
Cadastro MVC de Inventario

@author Fabio V Santana
@since 15/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA094
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription(STR0001)//Inventario
oBrw:SetAlias( 'C5A')
oBrw:SetMenuDef( 'TAFA094' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V Santana
@since 15/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf094Vld" , "2" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA094' OPERATION 2 ACCESS 0
Else
	aRotina	:=	xFunMnuTAF( "TAFA094" , , aFuncao)
EndIf

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V Santana
@since 15/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC5A 	:= 	FWFormStruct( 1, 'C5A' )
Local oStruC5B 	:= 	FWFormStruct( 1, 'C5B' )
Local oStruC5C 	:= 	FWFormStruct( 1, 'C5C' )

Local oModel 	:= 	MPFormModel():New( 'TAFA094',,, { |oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_C5A', /*cOwner*/, oStruC5A)

oModel:AddGrid('MODEL_C5B', 'MODEL_C5A', oStruC5B)
oModel:GetModel( 'MODEL_C5B' ):SetUniqueLine({ 'C5B_CODITE','C5B_UNID','C5B_INDPRO','C5B_CODPAR '})

oModel:AddGrid('MODEL_C5C', 'MODEL_C5B', oStruC5C)
oModel:GetModel( 'MODEL_C5C' ):SetUniqueLine({ 'C5C_CSTICM'})

oModel:SetRelation( 'MODEL_C5B' , { { 'C5B_FILIAL' , 'xFilial( "C5B" )' } , { 'C5B_ID' , 'C5A_ID' } } , C5B->( IndexKey( 1 ) ) )
oModel:GetModel( 'MODEL_C5B' ):SetOptional( .T. )

oModel:SetRelation( 'MODEL_C5C' , { { 'C5C_FILIAL' , 'xFilial( "C5C" )' } , { 'C5C_ID' , 'C5A_ID' } , { 'C5C_CODITE', 'C5B_CODITE' } , { 'C5C_UNID', 'C5B_UNID' } , { 'C5C_INDPRO', 'C5B_INDPRO' } , { 'C5C_CODPAR', 'C5B_CODPAR' } } , C5C->( IndexKey( 1 ) ) )
oModel:GetModel( 'MODEL_C5C' ):SetOptional( .T. )

oModel:GetModel( "MODEL_C5A" ):SetPrimaryKey( { "C5A_DTINV", "C5A_MOTINV" } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V Santana
@since 15/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA094' )
Local oStruC5A 	:= 	FWFormStruct( 2, 'C5A' )
Local oStruC5B 	:= 	FWFormStruct( 2, 'C5B' )
Local oStruC5C 	:= 	FWFormStruct( 2, 'C5C' )
Local oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C5A', oStruC5A, 'MODEL_C5A' )
oView:EnableTitleView( 'VIEW_C5A', STR0001) //Inventario

oView:AddGrid ( 'VIEW_C5B', oStruC5B, 'MODEL_C5B' )
oView:EnableTitleView( 'VIEW_C5B', STR0002) //Itens do Inventario

oView:AddGrid ( 'VIEW_C5C', oStruC5C, 'MODEL_C5C' )
oView:EnableTitleView( 'VIEW_C5C', STR0003) //Informação Complementar do Inventario

oView:CreateHorizontalBox( 'FIELDSC5A', 40 )

oView:CreateHorizontalBox( 'GRIDC5B', 30,,,,)
oView:CreateHorizontalBox( 'GRIDC5C', 30,,,,)

oView:SetOwnerView( 'VIEW_C5A', 'FIELDSC5A' )
oView:SetOwnerView( 'VIEW_C5B', 'GRIDC5B' )
oView:SetOwnerView( 'VIEW_C5C', 'GRIDC5C' )

If TamSX3("C5A_ID")[1] == 36
	oStruC5A:RemoveField("C5A_ID")
EndIf
If TamSX3("C5B_CODCTA")[1] == 36
	oStruC5B:RemoveField("C5B_CODCTA")		
	oStruC5B:SetProperty("C5B_CTACTB", 	MVC_VIEW_ORDEM, "15")
	oStruC5B:SetProperty("C5B_DCODCT", 	MVC_VIEW_ORDEM, "16")	
	oStruC5B:SetProperty("C5B_VITEIR", 	MVC_VIEW_ORDEM, "17")
EndIf

If TamSX3("C5B_CODPAR")[1] == 36
	oStruC5B:SetProperty("C5B_CPARTI", MVC_VIEW_ORDEM, "11" )
	oStruC5B:RemoveField("C5B_CODPAR")
EndIf
If TamSX3("C5B_CODITE")[1] == 36
	oStruC5B:SetProperty("C5B_ITEM", MVC_VIEW_ORDEM, "03" )
	oStruC5B:RemoveField("C5B_CODITE")
EndIf


Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Paulo Sérgio V.B. Santana
@since 20/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )
Local 	nOperation 	:= 	oModel:GetOperation()
Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
		TAFAltStat( 'C5A', " " ) //Limpa o Status do Registro, tornando possível nova validação.
	Endif

	FwFormCommit( oModel )

End Transaction


Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf094Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões

lJob - Informa se foi chamado por Job

@return .T.

@author Paulo V.B. Santana
@since 20/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function Taf094Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro  := {}
Local cChave    := ""

Local cC5BKey		:= ""
Local cC5CKey		:= ""

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C5A->( Recno() )

If (C5A->C5A_STATUS $ (' 1'))

	If Empty(C5A->C5A_DTINV)
		aAdd(aLogErro,{"C5A_DTINV","000010","C5A",nRecno}) //"Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5A->C5A_VINV)
		aAdd(aLogErro,{"C5A_VINV","000010","C5A",nRecno}) //"Campo Inconsistente ou Vazio"
	EndIf

	//Valída o Conteúdo da Tabela Filho referente ao campo da "C5A"
	If Empty(C5A->C5A_MOTINV)
		aAdd(aLogErro,{"C5A_MOTINV","000010","C5A",nRecno}) //"Campo Inconsistente ou Vazio"
	Else
		cChave := C5A->C5A_MOTINV
		xValRegTab("C5D",cChave,3,,@aLogErro,, { "C5A", "C5A_MOTINV", nRecno } )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³INICIO C5B³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	//Valída o conteúdo da Grid " Itens do Iventário"
	C5B->( DBSetOrder(1) )

	cC5BKey := C5A->C5A_ID
	If C5B->( MsSeek( xFilial("C5B") + cC5BKey ) )

		Do While !C5B->( Eof() ) .And. cC5BKey == C5B->C5B_ID
			//---------------------
			// Campos obrigatórios
			//---------------------
    		If Empty(C5B->C5B_CODITE)
				aAdd(aLogErro,{"C5B_CODITE","000010","C5A",nRecno}) //"Campo Inconsistente ou Vazio"
			Else
				cChave := C5B->C5B_CODITE
  				xValRegTab("C1L",cChave,3,,@aLogErro,, { "C5A", "C5B_CODITE", nRecno })
   			EndIf

        	If Empty(C5B->C5B_UNID)
				aAdd(aLogErro,{"C5B_UNID","000010","C5A",nRecno}) //"Campo Inconsistente ou Vazio"
			Else
				cChave := C5B->C5B_UNID
  				xValRegTab("C1J",cChave,3,,@aLogErro,, { "C5A", "C5B_UNID", nRecno })
   			EndIf

			If Empty(C5B->C5B_QTD)
				aAdd(aLogErro,{"C5B_QTD","000010","C5B",nRecno}) //"Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C5B->C5B_VUNIT)
				aAdd(aLogErro,{"C5B_VUNIT","000010","C5B",nRecno}) //"Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C5B->C5B_VITEM)
				aAdd(aLogErro,{"C5B_VITEM","000010","C5B",nRecno}) //"Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C5B->C5B_INDPRO)
				aAdd(aLogErro,{"C5B_INDPRO","000010","C5A",nRecno}) //"STR0010 - Campo Inconsistente ou Vazio"
			ElseIf !(C5B->C5B_INDPRO $("012"))
				aAdd(aLogErro,{"C5B_INDPRO","000006","C5A",nRecno})  //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
			EndIf

			If !Empty(C5B->C5B_CODPAR)
				cChave := C5B->C5B_CODPAR
  				xValRegTab("C1H",cChave,5,,@aLogErro,, { "C5A", "C5B_CODPAR", nRecno })
   			EndIf

   			If !Empty(C5B->C5B_CODCTA)
				cChave := C5B->C5B_CODCTA
  				xValRegTab("C1O",cChave,3,,@aLogErro,, { "C5A", "C5B_CODCTA", nRecno })
   			EndIf   			
   			   			
   			If TAFColumnPos( "C5B_INCICM" )
	   			If !Empty(C5B->C5B_INCICM)
		   			If !(C5B->C5B_INCICM $ ("1|2|3"))
						AADD(aLogErro,{"C5B_INCICM","000006","C1H", nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"
					EndIF
				EndIf
			EndIf   			

			//ÚÄÄÄÄÄÄÄÄÄÄ¿
			//³INICIO C5C³
			//ÀÄÄÄÄÄÄÄÄÄÄÙ
			C5C->( DBSetOrder(1) )

			cC5CKey := C5B->(C5B_ID+C5B_CODITE+C5B_UNID+C5B_INDPRO+C5B_CODPAR)
			If C5C->( MsSeek( xFilial("C5C") + cC5CKey ) )

				Do While !C5C->( Eof() ) .And. cC5CKey == C5C->(C5C_ID+C5C_CODITE+C5C_UNID+C5C_INDPRO+C5C_CODPAR)
					//---------------------
					// Campos obrigatórios
					//---------------------
   					If Empty(C5C->C5C_CSTICM)
   						aAdd(aLogErro,{"C5C_CSTICM","000010","C5A",nRecno}) //"STR0010 - Campo Inconsistente ou Vazio"
					Else
						cChave := C5C->C5C_CSTICM
  						xValRegTab("C14",cChave,3,,@aLogErro,, { "C5A", "C5C_CSTICM", nRecno } )
					EndIf

   				    If Empty(C5C->C5C_ORIGEM)
   						aAdd(aLogErro,{"C5C_ORIGEM","000010","C5A",nRecno}) //"STR0010 - Campo Inconsistente ou Vazio"
					Else
						cChave := C5C->C5C_ORIGEM
  						xValRegTab("C03",cChave,3,,@aLogErro,, { "C5A", "C5C_ORIGEM", nRecno } )
					EndIf

					If Empty(C5C->C5C_BCICMS)
						aAdd(aLogErro,{"C5C_BCICMS","000010","C5C",nRecno}) //"Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C5C->C5C_VICMS)
						aAdd(aLogErro,{"C5C_VICMS","000010","C5C",nRecno}) //"Campo Inconsistente ou Vazio"
					EndIf

					C5C->( DbSkip() )
				EndDo
			EndIf
			//ÚÄÄÄÄÄÄÄ¿
			//³FIM C5C³
			//ÀÄÄÄÄÄÄÄÙ

			C5B->( DbSkip() )
		EndDo
	EndIf
	//ÚÄÄÄÄÄÄÄ¿
	//³FIM C5B³
	//ÀÄÄÄÄÄÄÄÙ

	//ATUALIZO O STATUS DO REGISTRO
	If Len(aLogErro)>0
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS
		RecLock("C5A",.F.)
		C5A->C5A_STATUS := "1"
		C5A->( MsUnlock() )
	Else
		RecLock("C5A",.F.)
		C5A->C5A_STATUS := "0"
		C5A->( MsUnlock() )
	EndIf
Else
	AADD(aLogErro,{"C5A_ID","000305", "C5A", nRecno })   //Registros válidos não podem ser validados novamente
EndIf

If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)
