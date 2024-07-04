#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA548.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA546
Cadastro MVC do R-4099 - Fechamento dos Eventos Periódicos Série R-4000

@author Katielly Feitosa Rezende 		
@since 14/08/2019
@version 1.0
*/
Function TAFA548()

   	MsgInfo("Prezado cliente, esta rotina estará disponível após a liberação da REINF 2.0","Aviso - REINF")


/* If TAFAlsInDic( "V3W" )
	BrowseDef()
Else
	Aviso( STR0001, TafAmbInvMsg(), { STR0002 }, 3 ) //O ambiente do TAF encontra-se desatualizado. //Finalizar
EndIf
 */
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao MVC com as opcoes de menu

@author Katielly Rezende			
@since 14/08/2019
@version 1.0
/*/
/* Static Function MenuDef()
Local aFuncao as array
Local aRotina as array

aFuncao := {}
aRotina := {}

aAdd( aFuncao, { "", "xFunNewHis( 'V3W', 'TAFA548' )", "3" } )

lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )

If lMenuDif
    ADD OPTION aRotina Title "Visualizar"       				ACTION 'VIEWDEF.TAFA548' OPERATION 2 ACCESS 0
    ADD OPTION aRotina Title "Exibir Histórico de Alterações"   ACTION "xFunNewHis( 'V3W', 'TAFA548' )" OPERATION 2 ACCESS 0
Else
    //aRotina := TAFMenuReinf( "TAFA548", aFuncao )
EndIf

Return (aRotina )
 */
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao  MVC do model

@return oModel - Objeto do Modelo MVC

@author Katielly Rezende			
@since 14/08/2019
@version 1.0
/*/
/* Static Function ModelDef()
Local oStruV3W  as object
Local oModel	as object

oModel    :=  MPFormModel():New( 'TAFA548' ,,,{|oModel| SaveModel(oModel)}) 

oStruV3W  :=  FWFormStruct( 1, 'V3W' )

oModel:AddFields('MODEL_V3W',, oStruV3W)
oModel:GetModel( "MODEL_V3W" ):SetPrimaryKey( { "V3W_PERAPU" } )

Return oModel
 */
//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Katielly Rezende			
@since 14/08/2019
@version 1.0
/*/
/* Static Function ViewDef()

Local oModel	as object
Local oStruV3W	as object
Local oStruV3Wb	as object
Local oView		as object
Local cCmp	    as char
Local cCmp2	    as char
Local cCmp3	    as char
Local cCmp4	    as char
Local aCmpGrp	as array
Local nI		as numeric

oModel	:= FWLoadModel( 'TAFA548' )
oView	:= FWFormView():New()
cCmp    := ""
cCmp2   := ""
cCmp3   := ""
cCmp4   := ""
aCmpGrp	:= {}
nI		:= 0

cCmp	:= "V3W_PERAPU|"
cCmp2   := "V3W_NMRESP|V3W_CPFRES|V3W_DDDFON|V3W_FONE|V3W_EMAIL|"
cCmp3   := "V3W_RETPF|V3W_RETPJ|V3W_RETNID|"
cCmp4	:= "V3W_PROTUL|" 

oStruV3W  := FwFormStruct( 2, "V3W" )
oStruV3Wb := FwFormStruct( 2, "V3W", { |x| AllTrim( x ) + "|" $ cCmp4 } )

oStruV3W:AddGroup( "GRP_FECHA_PERIODICOS", STR0003, "", 1 ) //"Fechamento dos Eventos Periódicos"
oStruV3W:AddGroup( "GRP_RESP_INFORMAÇÕES", STR0004, "", 1 ) //"Responsável pelas informações"
oStruV3W:AddGroup( "GRP_INFO_FECHAMENTO" , STR0005, "", 1 ) //"Informações do Fechamento" 

aCmpGrp := StrToKarr( cCmp, "|" )
For nI := 1 to Len( aCmpGrp )
    oStruV3W:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_FECHA_PERIODICOS" )
Next nI

aCmpGrp := StrToKarr( cCmp2, "|" )
For nI := 1 to Len( aCmpGrp )
    oStruV3W:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_RESP_INFORMAÇÕES" )
Next nI

aCmpGrp := StrToKarr( cCmp3, "|" )
For nI := 1 to Len( aCmpGrp )
    oStruV3W:SetProperty( aCmpGrp[nI], MVC_VIEW_GROUP_NUMBER, "GRP_INFO_FECHAMENTO" )
Next nI

oStruV3W:RemoveField('V3W_ID'    )
oStruV3W:RemoveField('V3W_PROTUL')
oStruV3W:RemoveField('V3W_XMLID' )
oStruV3W:RemoveField('V3W_PROCID')

oView:SetModel( oModel )

oView:AddField( 'VIEW_V3W' , oStruV3W , 'MODEL_V3W' )
oView:AddField( 'VIEW_V3Wb', oStruV3Wb, 'MODEL_V3W' )

oView:CreateHorizontalBox( 'PAINEL', 100 )
oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL' )

oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0003 ) //"Fechamento dos Eventos Periódicos"
oView:CreateHorizontalBox( 'PAINEL_01', 100,,, 'FOLDER_SUPERIOR', 'ABA01' )

oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0006 ) //"Protocolo de Transmissão"
oView:CreateHorizontalBox( 'PAINEL_02', 100,,, 'FOLDER_SUPERIOR', 'ABA02' )

oView:SetOwnerView( 'VIEW_V3W' , 'PAINEL_01')
oView:SetOwnerView( 'VIEW_V3Wb', 'PAINEL_02')

xFunRmFStr(@oStruV3W, 'V3W')	

Return oView
 */
//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Katielly Rezende		
@since 14/08/2019
@version 1.0
/*/
/* Static Function SaveModel( oModel )

Local nOperation	as numeric
Local lRetorno		as logical
Local cChvRegAnt	as character
Local lExcPer 		as character 

nOperation	:= oModel:GetOperation()
lExcPer		:= IsInCallStack("TAFExcReg2") 
lRetorno	:= .T.
cChvRegAnt 	:= ""

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_INSERT
		oModel:LoadValue( 'MODEL_V3W', 'V3W_VERSAO', xFunGetVer() ) 
		FwFormCommit( oModel )   
		
	ElseIf nOperation == MODEL_OPERATION_UPDATE
		TAFAltStat( 'V3W', " " ) 
		FwFormCommit( oModel )	
					
	ElseIf nOperation == MODEL_OPERATION_DELETE 
		//Se o registro ja foi transmitido não permite excluir
		If V3W->V3W_STATUS == "4" .And. !lExcPer
			TAFMsgVldOp(oModel,"4")
			lRetorno := .F.
		Elseif V3W->V3W_STATUS == "2" .And. !lExcPer
			//Não é possível excluir um registro com aguardando validação
			TAFMsgVldOp(oModel,"2")
			lRetorno := .F. 
		Else
			If !Empty(V3W->V3W_VERANT)
				cChvRegAnt := V3W->( V3W_ID + V3W_VERANT )
			EndIf	
			oModel:DeActivate()
			oModel:SetOperation( 5 ) 	
			oModel:Activate()
	
			FwFormCommit( oModel )
			
			If !Empty( cChvRegAnt )
				If nOperation == MODEL_OPERATION_DELETE
					//Funcao para setar o registro anterior como Ativo
					TAFRastro( "V3W", 1, cChvRegAnt, .T. )
				EndIf
			EndIf
		EndIf			
	EndIf
End Transaction   
     
Return (lRetorno)
 */
//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse 

@author Katielly Rezende
@since 14/08/2019
@version 1.0
/*/
/* Static Function BrowseDef()

Local oBrw	  as object 	
Local cFiltro as char

oBrw	:= FWmBrowse():New()
cFiltro := ""

If FunName() == "TAFXREINF"
    lMenuDif 	:= Iif( Type( "lMenuDif" ) == "U", .T., lMenuDif ) 
    cPerAReinf	:= Iif( Type( "cPerAReinf" ) == "U", "", cPerAReinf )

    cFiltro := "V3W_ATIVO == '1'"  + IIf( !Empty(cPerAReinf) ," .AND. V3W_PERAPU =='"+cPerAReinf+"'","" )
Else
    cFiltro := "V3W_ATIVO == '1'"
EndIf

oBrw:SetDescription( "R-4099 - " + STR0003 )	//"Fechamento dos Eventos Periódicos"
oBrw:SetAlias( 'V3W')
oBrw:SetMenuDef( 'TAFA548' )	
    
DbSelectArea("V3W")
Set Filter TO &(cFiltro)

oBrw:Activate()

Return( oBrw )
		 */