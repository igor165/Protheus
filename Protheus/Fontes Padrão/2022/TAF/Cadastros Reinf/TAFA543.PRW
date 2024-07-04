#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA543.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA543
Cadastro MVC do R-4040 - Retenï¿½ï¿½es na Fonte - Beneficiï¿½rios nï¿½o identificados 

@author Katielly Feitosa Rezende 		
@since 06/08/2019
@version 1.0
*/
Function TAFA543()

	MsgInfo("Prezado cliente, esta rotina estará disponível após a liberação da REINF 2.0","Aviso - REINF")


/* If TAFAlsInDic( "V4N" ) 
	BrowseDef()
Else
	Aviso(STR0001, TafAmbInvMsg(), { STR0002 }, 3 ) //"O ambiente do TAF encontra-se desatualizado. Para utilizaï¿½ï¿½o desta funcionalidade, serï¿½ necessï¿½rio aplicar o dicionï¿½rio de dados do REINF 2.0."                                                                                                                                                                                                                                                                                                                                                                    
EndIf
 */
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao MVC com as opcoes de menu

@author Katielly Rezende			
@since 06/08/2019
@version 1.0
/*/
/* Static Function MenuDef()
Local aFuncao as array
Local aRotina as array

aFuncao := {}
aRotina := {}

aAdd( aFuncao, { "", "xFunNewHis( 'V4N', 'TAFA543' )", "3" } )

//Linha comentada para que alguns menus nÃ£o apareÃ§am durante a WarRoom.
//lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )
	
lMenuDif := .T.

If lMenuDif
	ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA543' OPERATION 2 ACCESS 0
Else
	aRotina := TAFMenuReinf( "TAFA543", aFuncao )
EndIf

Return (aRotina ) 
 */
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao  MVC do model

@return oModel - Objeto do Modelo MVC

@author Katielly Rezende			
@since 06/08/2019
@version 1.0
/*/
/* Static Function ModelDef()
Local oStruV4N as object
Local oStruV4O as object                                                                      
Local oStruV4P as object
Local oModel   as object

oModel    :=  MPFormModel():New( 'TAFA543')

oStruV4N := FWFormStruct( 1, 'V4N')
oStruV4O := FWFormStruct( 1, 'V4O')
oStruV4P := FWFormStruct( 1, 'V4P')

oModel:AddFields( 'MODEL_V4N', , oStruV4N)
oModel:GetModel ( 'MODEL_V4N' ):SetPrimaryKey( { "V4N_PERAPU" } )

oModel:AddGrid ( 'MODEL_V4O', 'MODEL_V4N', oStruV4O)
oModel:GetModel( 'MODEL_V4O'):SetUniqueLine({ 'V4O_NATREN' })
oModel:GetModel( 'MODEL_V4O' ):SetOptional( .F. )
oModel:GetModel( 'MODEL_V4O'):SetMaxLine(2) 

oModel:AddGrid ( 'MODEL_V4P', 'MODEL_V4O', oStruV4P)
oModel:GetModel( 'MODEL_V4P'):SetUniqueLine({'V4P_DATAFG'})
oModel:GetModel( 'MODEL_V4P' ):SetOptional( .F. )
oModel:GetModel( 'MODEL_V4P'):SetMaxLine(31) 

oModel:SetRelation("MODEL_V4O",{ {"V4O_FILIAL","xFilial('V4O')"}, {"V4O_ID","V4N_ID"}, {"V4O_VERSAO","V4N_VERSAO"}} , V4O->(IndexKey(1)) )
oModel:SetRelation("MODEL_V4P",{ {"V4P_FILIAL","xFilial('V4P')"}, {"V4P_ID","V4N_ID"}, {"V4P_VERSAO","V4N_VERSAO"}  , {"V4P_NATREN" ,"V4O_NATREN"}}, V4P->(IndexKey(1)) )

Return oModel
 */
//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Katielly Rezende			
@since 06/08/2019
@version 1.0
/*/
/* Static Function ViewDef()
Local oModel   	as object
Local oView		as object
Local oStruV4N  as object
Local oStruV4Nb as object
Local oStruV4O  as object                                                                      
Local oStruV4P  as object
Local cCmpFil   as char
 
cCmpFil   := ''
oModel    := FWLoadModel( 'TAFA543' )
oView	  := FWFormView():New()
oStruV4N  := FWFormStruct( 2, 'V4N')
oStruV4O  := FWFormStruct( 2, 'V4O')
oStruV4P  := FWFormStruct( 2, 'V4P')

cCmpFil   := 'V4N_PROTUL|'
oStruV4Nb := FwFormStruct( 2, 'V4N', {|x| AllTrim( x ) + "|" $ cCmpFil } )

oStruV4N:RemoveField('V4N_ID')
oStruV4N:RemoveField('V4N_PROTUL')

oView:SetModel( oModel )

oView:AddField( "VIEW_V4N" , oStruV4N , "MODEL_V4N" )
oView:AddField( "VIEW_V4Nb", oStruV4Nb, "MODEL_V4N" )
oView:AddGrid ( "VIEW_V4O" , oStruV4O , "MODEL_V4O" )
oView:AddGrid ( "VIEW_V4P" , oStruV4P , "MODEL_V4P" )

oView:CreateHorizontalBox("PAINEL_PRINCIPAL",100)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

oView:AddSheet("FOLDER_PRINCIPAL","ideEstab", STR0003 ) //"Retenï¿½ï¿½es na Fonte - Beneficiï¿½rios nï¿½o identificado"
oView:CreateHorizontalBox("V4N",030,,,"FOLDER_PRINCIPAL","ideEstab") 

oView:EnableTitleView("VIEW_V4O", STR0004 ) //"ideNat - Identificaï¿½ï¿½o da natureza do rendimento"      
oView:CreateHorizontalBox("V4O",035,,,"FOLDER_PRINCIPAL","ideEstab")

oView:EnableTitleView("VIEW_V4P", STR0005 ) //"infoPgto - Informaï¿½ï¿½es de pagamentos"                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
oView:CreateHorizontalBox("V4P",035,,,"FOLDER_PRINCIPAL","ideEstab")

oView:AddSheet("FOLDER_PRINCIPAL","recibTrans", STR0006 )//"Recibo de Transmissï¿½o"
oView:CreateHorizontalBox("V4Nb",100,,,"FOLDER_PRINCIPAL","recibTrans")

oView:SetOwnerView( "VIEW_V4N" , "V4N" )
oView:SetOwnerView( "VIEW_V4Nb", "V4Nb")
oView:SetOwnerView( "VIEW_V4O" , "V4O" )
oView:SetOwnerView( "VIEW_V4P" , "V4P" )

oStruV4P:RemoveField("V4P_NATREN")
xFunRmFStr(@oStruV4N,"V4N")

Return (oView)
 */
//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse 

@author Katielly Rezende
@since 06/08/2019
@version 1.0
/*/
/* Static Function BrowseDef()
Local oBrw  as object

oBrw := FWmBrowse():New()	
oBrw:SetDescription( STR0007 )// "R-4040 - Retenï¿½ï¿½es na Fonte - Beneficiï¿½rios nï¿½o identificados"
oBrw:SetAlias( 'V4N')
oBrw:SetMenuDef( 'TAFA543' )	
	
DbSelectArea("V4N")
Set Filter TO &("V4N_ATIVO == '1'")

oBrw:Activate()

Return( oBrw ) */