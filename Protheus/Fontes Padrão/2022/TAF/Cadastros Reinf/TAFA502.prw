#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA502.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA502
Cadastro MVC do R-2098 - Reabertura dos Eventos Periódicos

@author Helena Adrignoli Leal			
@since 22/03/2018
@version 1.0

/*/
//-------------------------------------------------------------------

Function TAFA502()

If TAFAlsInDic( "V1A" )
	BrowseDef()
Else
	Aviso( STR0002, TafAmbInvMsg(), { STR0003 }, 3 ) //##"Dicionário Incompatível" ##"Encerrar"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Helena Adrignoli Leal			
@since 22/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao as array
Local aRotina as array

aFuncao := {}
aRotina := {}

aAdd( aFuncao, { "", "TAF502Xml", "1" } )
aAdd( aFuncao, { "", "xFunNewHis( 'V1A', 'TAFA502' )", "3" } )
aAdd( aFuncao, { "", "TAFXmlLote( 'V1A', 'R-2098', 'evtReabreEvPer', 'TAF502Xml', 5, oBrw)", "5" } )
aAdd( aFuncao, { "", "TafViewLog( '' , 'R-2098', V1A->V1A_PERAPU )", "7" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
	ADD OPTION aRotina Title "Visualizar"       				ACTION 'VIEWDEF.TAFA502' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Exibir Histórico de Alterações"   ACTION "xFunNewHis( 'V1A', 'TAFA502' )" OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Gerar Xml Reinf"					ACTION 'TAF502Xml()' 	 OPERATION 2 ACCESS 0 //"Gerar Xml Reinf"
	ADD OPTION aRotina TITLE "Gerar Xml em Lote"				ACTION "TAFXmlLote( 'V1A', 'R-2098', 'evtReabreEvPer', 'TAF502Xml', 5, oBrw)" 	 OPERATION 2 ACCESS 0 //"Gerar Xml em Lote"	
Else
	//aRotina	:=	xFunMnuTAF( "TAFA502" , , aFuncao)
	aRotina := TAFMenuReinf( "TAFA502", aFuncao )
//	ADD OPTION aRotina Title "Incluir"       Action 'VIEWDEF.TAFA502' OPERATION 3 ACCESS 0
//	ADD OPTION aRotina Title "Alterar"       Action 'VIEWDEF.TAFA502' OPERATION 4 ACCESS 0		
EndIf

Return (aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Helena Adrignoli Leal			
@since 22/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruV1A	as object
Local oModel		as object

oStruV1A  :=  FWFormStruct( 1, 'V1A' )
oModel    :=  MPFormModel():New( 'TAFA502' ,,,{|oModel| SaveModel(oModel)}) 

//V1A – Ret. Contrib. Prev. - Serviços Tomados
oModel:AddFields('MODEL_V1A', /*cOwner*/, oStruV1A)
oModel:GetModel( "MODEL_V1A" ):SetPrimaryKey( { "V1A_PERAPU" } )


Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Helena Adrignoli Leal			
@since 22/03/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

Local oModel		as object
Local oStruV1A	as object
Local oStruV1Ap	as object
Local oView		as object

Local cCmpIden	as char
Local cCmpIden2	as char
Local cCmpIden3	as char
Local cCmpIden4	as char
Local cCmpIden5	as char

Local aCmpGrp		as array
Local nI			as numeric

oModel		:= FWLoadModel( 'TAFA502' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
oStruV1A	:= nil
oStruV1Ap	:= Nil
oView		:= FWFormView():New()

cCmpIden	:= ""
cCmpIden2	:= ""
cCmpIden3	:= ""
cCmpIden4	:= ""
cCmpIden5 	:= ""

aCmpGrp	:= {}
nI			:= 0

oView:SetModel( oModel )

/*-----------------------------------------------------------------------------------
							Estrutura da View do Trabalhador
-------------------------------------------------------------------------------------*/
cCmpIden	:= "V1A_PERAPU|"
cCmpIden5	:= "V1A_PROTUL|" 

cCmpFil		:= cCmpIden+cCmpIden2+cCmpIden3+cCmpIden4
oStruV1A 	:= FwFormStruct( 2, "V1A", { |x| AllTrim( x ) + "|" $ cCmpFil } )
oStruV1Ap	:= FwFormStruct( 2, "V1A", { |x| AllTrim( x ) + "|" $ cCmpIden5 } )

/*-----------------------------------------------------------------------------------
							Grupo de campos do Trabalhador
-------------------------------------------------------------------------------------*/
//"Reabertura dos Eventos Periódicos"
oStruV1A:AddGroup( "REGRA_REABERTURA_VALIDA_PERIODO_APURACAO", STR0001, "", 1 )//"Reabertura dos Eventos Periódicos" 

aCmpGrp := StrToKarr( cCmpIden, "|" )
For nI := 1 to Len( aCmpGrp )
	oStruV1A:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_FECHA_PERIODICOS" )
Next nI

//"Responsável pelas informações"
oStruV1A:AddGroup( "REGRA_VALIDA_CONTRIBUINTE", STR0006, "", 1 )//"Responsável pelas informações" 

aCmpGrp := StrToKarr( cCmpIden2, "|" )
For nI := 1 to Len( aCmpGrp )
	oStruV1A:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_RESP_INFORMAÇÕES" )
Next nI

//"Informações do Fechamento"
oStruV1A:AddGroup( "REGRA_VALIDA_ID_EVENTO", STR0005, "", 1 ) 

aCmpGrp := StrToKarr( cCmpIden4, "|" )
For nI := 1 to Len( aCmpGrp )
	oStruV1A:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "REGRA_VALIDA_ID_EVENTO" )
Next nI

oView:AddField( 'VIEW_V1A', oStruV1A , 'MODEL_V1A' )
oView:AddField( 'VIEW_V1Ap', oStruV1Ap, 'MODEL_V1A' )

oView:CreateHorizontalBox( 'PAINEL', 100 )
oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL' )
oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0001 ) //"Reabertura dos Eventos Periódicos" 
oView:CreateHorizontalBox( 'PAINEL_01', 100,,, 'FOLDER_SUPERIOR', 'ABA01' )

oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0004 ) //"Protocolo de Transmissão"
oView:CreateHorizontalBox( 'PAINEL_02', 100,,, 'FOLDER_SUPERIOR', 'ABA02' )


oView:SetOwnerView( 'VIEW_V1A' , 'PAINEL_01')
oView:SetOwnerView( 'VIEW_V1Ap', 'PAINEL_02')


lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If !lMenuDif
	xFunRmFStr(@oStruV1A, 'V1A')	
EndIf


Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Helena Adrignoli Leal			
@since 22/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation	as numeric
Local lRetorno		as logical
Local cChvRegAnt	as character
Local lExcPer		as character

nOperation	:= oModel:GetOperation()
lExcPer		:= IsInCallStack("TAFExcReg2") 
lRetorno	:= .T.
cChvRegAnt 	:= ""

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_INSERT
		oModel:LoadValue( 'MODEL_V1A', 'V1A_VERSAO', xFunGetVer() ) 
		FwFormCommit( oModel )  
		
	ElseIf nOperation == MODEL_OPERATION_UPDATE
		TAFAltStat( 'V1A', " " ) 
		FwFormCommit( oModel )	
					
	ElseIf nOperation == MODEL_OPERATION_DELETE 
		//Se o registro ja foi transmitido não permite excluir
		If V1A->V1A_STATUS == "4" .And. !lExcPer
			TAFMsgVldOp(oModel,"4")
			lRetorno := .F.
		Elseif V1A->V1A_STATUS == "2" .And. !lExcPer
			//Não é possível alterar um registro com aguardando validação
			TAFMsgVldOp(oModel,"2")
			lRetorno := .F. 
		Else
			If !Empty(V1A->V1A_VERANT)
				cChvRegAnt := V1A->( V1A_ID + V1A_VERANT )
			EndIf	
			oModel:DeActivate()
			oModel:SetOperation( 5 ) 	
			oModel:Activate()
	
			FwFormCommit( oModel )
			
			If !Empty( cChvRegAnt )
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso a operacao seja uma exclusao...³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nOperation == MODEL_OPERATION_DELETE
					//Funcao para setar o registro anterior como Ativo
					TAFRastro( "V1A", 1, cChvRegAnt, .T. )
				EndIf
		
			EndIf
		EndIf			
	EndIf
End Transaction    
     
Return (lRetorno)

//-------------------------------------------------------------------	
/*/{Protheus.doc} TAF502Xml
Retorna o Xml do Registro Posicionado 
	
@author Helena Adrignoli Leal			
@since 22/03/2018
@version 1.0

@Param:
lJob - Informa se foi chamado por Job

@return
cXml - Estrutura do Xml do Layout S-2098
/*/
//-------------------------------------------------------------------
Function TAF502Xml(cAlias,nRecno,nOpc,lJob)
Local cXml    	as char
Local cLayout 	as char
Local cReg    	as char
Local cPeriodo	as char
Local cNumDoc	as char
Local cNameXSD  as char

Default lJob 	:= .F.
Default cAlias 	:= "V1A"
Default nRecno	:= 1
Default nOpc	:= 1

cLayout 	:= "2098"
cXml    	:= ""
cReg    	:= "ReabreEvPer" 
cPeriodo	:= Substr(V1A->V1A_PERAPU,3) +"-"+ Substr(V1A->V1A_PERAPU,1,2)
cNameXSD	:= 'ReabreEvPer'

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Estrutura do cabecalho³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cXml := TAFXmlReinf( cXml, "V1A", cLayout, cReg, cPeriodo,, cNameXSD)


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Executa gravacao do registro³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !lJob
	xTafGerXml(cXml,cLayout,,,,,,"R-" )
EndIf

	
Return(cXml)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF502Vld
Valida os registros conforme leiaute

@author Helena Adrignoli Leal			
@since 22/03/2018
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF502Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro   as array
Local aDadosUtil as array
Local lValida    as logical   

Default lJob := .F.

aLogErro   := {}
aDadosUtil := {}
lValida    := V1A->V1A_STATUS $ ( " |1" )

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := V1A->( Recno() )

If !lValida
	aAdd( aLogErro, { "V1A_ID", "000305", "V1A", nRecno } ) //Registros que já foram transmitidos ao Fisco, não podem ser validados
Else
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cStatus := Iif( Len( aLogErro ) > 0, "1", "0" )
	Begin Transaction 
		If RecLock( "V1A", .F. )
			V1A->V1A_STATUS := cStatus
			V1A->( MsUnlock() )
		EndIf
	End Transaction 
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao apresento o alert quando utilizo o JOB para validar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lJob
	xValLogEr( aLogErro )
EndIf

Return(aLogErro)

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Roberto Souza
@since 23/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()

	Private oBrw	as object

	If FunName() == "TAFXREINF"
		lMenuDif := Iif( Type( "lMenuDif" ) == "U", .T., lMenuDif ) 
		cPerAReinf	:= Iif( Type( "cPerAReinf" ) == "U", "", cPerAReinf )

		cFiltro := "V1A_ATIVO == '1'"  + IIf( !Empty(cPerAReinf) ," .AND. V1A_PERAPU =='"+cPerAReinf+"'","" )
	Else
		cFiltro := "V1A_ATIVO == '1'"
	EndiF	

	oBrw	:=	FWMBrowse():New()
	oBrw:SetDescription( "R-2098 - "+STR0001 )	//"Reabertura dos Eventos Periódicos"
	oBrw:SetAlias( 'V1A')
	oBrw:SetMenuDef( 'TAFA502' )	
	oBrw:SetFilterDefault( "V1A_ATIVO == '1'" )

	//DbSelectArea("V1A")
	//Set Filter TO &(cFiltro)
	
	If FindFunction("TAFLegReinf")
		TAFLegReinf( "V1A", oBrw)
	Else
		TafLegend(2,"V1A",@oBrw)
	EndIf
	
	oBrw:Activate()

Return( oBrw )
