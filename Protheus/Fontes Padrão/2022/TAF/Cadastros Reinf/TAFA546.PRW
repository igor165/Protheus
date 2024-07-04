#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA546.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA546
Cadastro MVC do R-4020 - Retenï¿½ï¿½es na Fonte - Pessoa Jurï¿½dica 
Tabelas espelhos

@author Katielly Feitosa Rezende 		
@since 12/08/2019
@version 1.0
*/
Function TAFA546()

   	MsgInfo("Prezado cliente, esta rotina estará disponível após a liberação da REINF 2.0","Aviso - REINF")

/* If TAFAlsInDic( "V5C" ) 
	BrowseDef()
Else
	Aviso(STR0001, TafAmbInvMsg(), { STR0002 }, 3 ) //O ambiente do TAF encontra-se desatualizado. //Finalizar
EndIf
 */
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao MVC com as opcoes de menu 

@author Katielly Rezende			
@since 12/08/2019
@version 1.0
/*/
/* Static Function MenuDef()

Local aFuncao as array
Local aRotina as array

aFuncao := {}
aRotina := {}

aAdd( aFuncao, { "", "xFunNewHis( 'V5C', 'TAFA546' )", "3" } )

//Linha comentada para que alguns menus nÃ£o apareÃ§am durante a WarRoom.
//lMenuDif := Iif( Type( "lMenuDif" ) == "U", .F., lMenuDif )
    
lMenuDif := .T.

If lMenuDif
    ADD OPTION aRotina Title "Visualizar" Action 'VIEWDEF.TAFA546' OPERATION 2 ACCESS 0
Else
    aRotina := TAFMenuReinf( "TAFA546", aFuncao )
EndIf

Return (aRotina ) 
 */
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao  MVC do model

@return oModel - Objeto do Modelo MVC

@author Katielly Rezende			
@since 12/08/2019
@version 1.0
/*/
/* Static Function ModelDef()

Local oModel    As object
Local oStrV5C   As object
Local oStrV5Da  As object
Local oStrV5Db  As object
Local oStrV5Dc  As object
Local oStrV4Sa  As object
Local oStrV4Sb  As object
Local oStrV4Sc  As object
Local oStrV4Sd  As object
Local oStrV4Se  As object
Local oStrV4Sf  As object
Local oStrV4Sg  As object
Local oStrV4Sh  As object
Local oStrV4Si  As object
Local oStrV4Sj  As object
Local oStrV5F   As object
Local oStrV5G   As object

Local cGrpV5Db  As Character
Local cGrpV5Dc  As Character
Local cGrpV4Sb  As Character
Local cGrpV4Sc  As Character
Local cGrpV4Sd  As Character
Local cGrpV4Se  As Character
Local cGrpV4Sf  As Character
Local cGrpV4Sg  As Character
Local cGrpV4Sh  As Character
Local cGrpV4Si  As Character
Local cGrpV4Sj  As Character

oModel := MPFormModel():New( 'TAFA546' )

oStrV5C  := FWFormStruct( 1, 'V5C' )

oModel:AddFields( 'MODEL_V5C',, oStrV5C)
oModel:GetModel ( 'MODEL_V5C'):SetPrimaryKey( { 'V5C_PERAPU' } )

//idePgto
oStrV5Da := FWFormStruct( 1, 'V5D' )
oModel:AddGrid ( 'MODEL_V5DA', 'MODEL_V5C', oStrV5Da )
oModel:GetModel( 'MODEL_V5DA' ):SetUniqueLine({ 'V5D_IDNTRE', 'V5D_PAISRE' })
oModel:GetModel( 'MODEL_V5DA' ):SetOptional( .F. )
oModel:GetModel( 'MODEL_V5DA' ):SetMaxLine( 100 )

//infoPgtoExt/endExt
cGrpV5Db := "V5D_LOGRAD|V5D_NRLOGR|V5D_COMPLE|V5D_BAIRRO|V5D_CIDADE|V5D_ESTADO|V5D_CEP|V5D_TELEF|"
oStrV5Db := FwFormStruct( 1, 'V5D', {|x| AllTrim( x ) + "|" $ cGrpV5Db} )    
oModel:AddGrid ( 'MODEL_V5DB', 'MODEL_V5DA', oStrV5Db )
oModel:GetModel( 'MODEL_V5DB' ):SetOptional( .F. )
oModel:GetModel( 'MODEL_V5DB' ):SetMaxLine( 1 )

//infoPgtoExt/infoFiscal
cGrpV5Dc := "V5D_INDNIF|V5D_NIF|V5D_CTRIB|V5D_DTRIB|V5D_RELPGT|V5D_IDRELP|V5D_DRELPG|V5D_IDTRIB|"
oStrV5Dc := FwFormStruct( 1, 'V5D', {|x| AllTrim( x ) + "|" $ cGrpV5Dc} )
oModel:AddGrid ( 'MODEL_V5DC', 'MODEL_V5DA', oStrV5Dc )    
oModel:GetModel( 'MODEL_V5DC' ):SetOptional( .F. )
oModel:GetModel( 'MODEL_V5DC' ):SetMaxLine( 1 )

//infoPgto
oStrV4Sa := FWFormStruct( 1, 'V4S' )
oModel:AddGrid ( 'MODEL_V4SA', 'MODEL_V5DA', oStrV4Sa )
oModel:GetModel( 'MODEL_V4SA' ):SetUniqueLine({ 'V4S_DATAFG' })
oModel:GetModel( 'MODEL_V4SA' ):SetOptional( .F. )
oModel:GetModel( 'MODEL_V4SA' ):SetMaxLine( 999 )

//ir
cGrpV4Sb  := "V4S_BASEIR|V4S_VLRIR|V4S_BASNIR|V4S_VLRNIR|V4S_VLDPIR|"
oStrV4SB := FWFormStruct( 1, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sb} )
oModel:AddGrid ( 'MODEL_V4SB', 'MODEL_V4SA', oStrV4SB)
oModel:GetModel( 'MODEL_V4SB' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V4SB' ):SetMaxLine( 1 )

//csll
cGrpV4Sc := "V4S_BCSLL|V4S_VLCSLL|V4S_BNCSLL|V4S_VLNCSL|V4S_VLDCSL|"
oStrV4Sc := FwFormStruct( 1, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sc} )
oModel:AddGrid ( 'MODEL_V4SC', 'MODEL_V4SA', oStrV4Sc )
oModel:GetModel( 'MODEL_V4SC' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V4SC' ):SetMaxLine( 1 )

//cofins
cGrpV4Sd := "V4S_BCOFIN|V4S_VCOFIN|V4S_VBNCOF|V4S_VLNCOF|V4S_DCOFIN|"
oStrV4Sd := FwFormStruct( 1, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sd} )
oModel:AddGrid ( 'MODEL_V4SD', 'MODEL_V4SA', oStrV4Sd )
oModel:GetModel( 'MODEL_V4SD' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V4SD' ):SetMaxLine( 1 )

//pp
cGrpV4Se := "V4S_BASEPP|V4S_VLRPP|V4S_VLRBPP|V4S_VLRNPP|V4S_VLRDPP|"
oStrV4Se := FwFormStruct( 1, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Se} )
oModel:AddGrid ( 'MODEL_V4SE', 'MODEL_V4SA', oStrV4Se )
oModel:GetModel( 'MODEL_V4SE' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V4SE' ):SetMaxLine( 1 )

//fci
cGrpV4Sf := "V4S_NRFCI|"
oStrV4Sf := FwFormStruct( 1, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sf} )
oModel:AddGrid ( 'MODEL_V4SF', 'MODEL_V4SA', oStrV4Sf )
oModel:GetModel( 'MODEL_V4SF' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V4SF' ):SetMaxLine( 1 )

//scp
cGrpV4Sg := "V4S_NRSCP|V4S_PERSCP|"
oStrV4Sg := FwFormStruct( 1, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sg} )
oModel:AddGrid ( 'MODEL_V4SG', 'MODEL_V4SA', oStrV4Sg )
oModel:GetModel( 'MODEL_V4SG' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V4SG' ):SetMaxLine( 1 )

//infoProcRet
oStrV5F  := FWFormStruct( 1, 'V5F' ) 
oModel:AddGrid ( 'MODEL_V5F', 'MODEL_V4SA', oStrV5F)
oModel:GetModel( 'MODEL_V5F' ):SetUniqueLine({ 'V5F_TPPROC', 'V5F_NRPROC' })
oModel:GetModel( 'MODEL_V5F' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V5F' ):SetMaxLine( 99 )

//infoProcJud
cGrpV4Sh := "V4S_NRPROC|V4S_ORIREC|V4S_DESCRI|"
oStrV4Sh := FwFormStruct( 1, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sh} )    
oModel:AddGrid ( 'MODEL_V4SH', 'MODEL_V4SA', oStrV4Sh )
oModel:GetModel( 'MODEL_V4SH' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V4SH' ):SetMaxLine( 1 )

//despProcJud
cGrpV4Si := "V4S_VLRCUS|V4S_VLRADV|"
oStrV4Si := FwFormStruct( 1, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Si} )
oModel:AddGrid ( 'MODEL_V4SI', 'MODEL_V4SH', oStrV4Si )
oModel:GetModel( 'MODEL_V4SI' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V4SI' ):SetMaxLine( 1 )

//ideAdv
oStrV5G  := FWFormStruct( 1, 'V5G' )
oModel:AddGrid ( 'MODEL_V5G', 'MODEL_V4SI', oStrV5G )
oModel:GetModel( 'MODEL_V5G' ):SetUniqueLine({ 'V5G_TPINSC', 'V5G_NRINSC' })
oModel:GetModel( 'MODEL_V5G' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V5G' ):SetMaxLine( 99 ) 

//origemRec
cGrpV4Sj := "V4S_CGCORI|"
oStrV4Sj := FwFormStruct( 1, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sj} )
oModel:AddGrid ( 'MODEL_V4SJ', 'MODEL_V4SA', oStrV4Sj )
oModel:GetModel( 'MODEL_V4SJ' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_V4SJ' ):SetMaxLine( 1 )

//idePgto
oModel:SetRelation("MODEL_V5DA", { {"V5D_FILIAL","xFilial('V5D')"}, {"V5D_ID","V5C_ID"}, {"V5D_VERSAO","V5C_VERSAO"}}, V5D->(IndexKey(1)) )
//endExt
oModel:SetRelation("MODEL_V5DB", { {"V5D_FILIAL","xFilial('V5D')"}, {"V5D_ID","V5C_ID"}, {"V5D_VERSAO","V5C_VERSAO"}, {"V5D_IDNTRE", "V5D_IDNTRE"}, {"V5D_PAISRE", "V5D_PAISRE"}}, V5D->(IndexKey(1)) )
//infoFiscal
oModel:SetRelation("MODEL_V5DC", { {"V5D_FILIAL","xFilial('V5D')"}, {"V5D_ID","V5C_ID"}, {"V5D_VERSAO","V5C_VERSAO"}, {"V5D_IDNTRE", "V5D_IDNTRE"}, {"V5D_PAISRE", "V5D_PAISRE"}}, V5D->(IndexKey(1)) )

//ideInfo    
oModel:SetRelation("MODEL_V4SA", { {"V4S_FILIAL","xFilial('V4S')"}, {"V4S_ID","V5C_ID"}, {"V4S_VERSAO","V5C_VERSAO"}, {"V4S_IDNTRE" ,"V5D_IDNTRE"}, {"V4S_PAISRE", "V5D_PAISRE"}}, V4S->(IndexKey(1)) )
//infoPgto\ir
oModel:SetRelation("MODEL_V4SB", { {"V4S_FILIAL","xFilial('V4S')"}, {"V4S_ID","V5C_ID"}, {"V4S_VERSAO","V5C_VERSAO"}, {"V4S_IDNTRE" ,"V5D_IDNTRE"}, {"V4S_PAISRE", "V5D_PAISRE"}, {"V4S_DATAFG", "V4S_DATAFG"} }, V4S->(IndexKey(1)) )
//infoPgto\csll
oModel:SetRelation("MODEL_V4SC", { {"V4S_FILIAL","xFilial('V4S')"}, {"V4S_ID","V5C_ID"}, {"V4S_VERSAO","V5C_VERSAO"}, {"V4S_IDNTRE" ,"V5D_IDNTRE"}, {"V4S_PAISRE", "V5D_PAISRE"}, {"V4S_DATAFG", "V4S_DATAFG"} }, V4S->(IndexKey(1)) )
//infoPgto\cofins
oModel:SetRelation("MODEL_V4SD", { {"V4S_FILIAL","xFilial('V4S')"}, {"V4S_ID","V5C_ID"}, {"V4S_VERSAO","V5C_VERSAO"}, {"V4S_IDNTRE" ,"V5D_IDNTRE"}, {"V4S_PAISRE", "V5D_PAISRE"}, {"V4S_DATAFG", "V4S_DATAFG"} }, V4S->(IndexKey(1)) )
//infoPgto\pp
oModel:SetRelation("MODEL_V4SE", { {"V4S_FILIAL","xFilial('V4S')"}, {"V4S_ID","V5C_ID"}, {"V4S_VERSAO","V5C_VERSAO"}, {"V4S_IDNTRE" ,"V5D_IDNTRE"}, {"V4S_PAISRE", "V5D_PAISRE"}, {"V4S_DATAFG", "V4S_DATAFG"} }, V4S->(IndexKey(1)) )
//infoPgto\fci
oModel:SetRelation("MODEL_V4SF", { {"V4S_FILIAL","xFilial('V4S')"}, {"V4S_ID","V5C_ID"}, {"V4S_VERSAO","V5C_VERSAO"}, {"V4S_IDNTRE" ,"V5D_IDNTRE"}, {"V4S_PAISRE", "V5D_PAISRE"}, {"V4S_DATAFG", "V4S_DATAFG"} }, V4S->(IndexKey(1)) )
//infoPgto\scp
oModel:SetRelation("MODEL_V4SG", { {"V4S_FILIAL","xFilial('V4S')"}, {"V4S_ID","V5C_ID"}, {"V4S_VERSAO","V5C_VERSAO"}, {"V4S_IDNTRE" ,"V5D_IDNTRE"}, {"V4S_PAISRE", "V5D_PAISRE"}, {"V4S_DATAFG", "V4S_DATAFG"} }, V4S->(IndexKey(1)) )
//infoPgto\prodJud
oModel:SetRelation("MODEL_V4SH", { {"V4S_FILIAL","xFilial('V4S')"}, {"V4S_ID","V5C_ID"}, {"V4S_VERSAO","V5C_VERSAO"}, {"V4S_IDNTRE" ,"V5D_IDNTRE"}, {"V4S_PAISRE", "V5D_PAISRE"}, {"V4S_DATAFG", "V4S_DATAFG"} }, V4S->(IndexKey(1)) )
//prodJud\despProcJud
oModel:SetRelation("MODEL_V4SI", { {"V4S_FILIAL","xFilial('V4S')"}, {"V4S_ID","V5C_ID"}, {"V4S_VERSAO","V5C_VERSAO"}, {"V4S_IDNTRE" ,"V5D_IDNTRE"}, {"V4S_PAISRE", "V5D_PAISRE"}, {"V4S_DATAFG", "V4S_DATAFG"} }, V4S->(IndexKey(1)) )
//prodJud\origemRec
oModel:SetRelation("MODEL_V4SJ", { {"V4S_FILIAL","xFilial('V4S')"}, {"V4S_ID","V5C_ID"}, {"V4S_VERSAO","V5C_VERSAO"}, {"V4S_IDNTRE" ,"V5D_IDNTRE"}, {"V4S_PAISRE", "V5D_PAISRE"}, {"V4S_DATAFG", "V4S_DATAFG"} }, V4S->(IndexKey(1)) )

//infoPgto\procRet
oModel:SetRelation("MODEL_V5F" , { {"V5F_FILIAL","xFilial('V5F')"}, {"V5F_ID","V5C_ID"}, {"V5F_VERSAO","V5C_VERSAO"}, {"V5F_IDNTRE" ,"V5D_IDNTRE"}, {"V5F_PAISRE", "V5D_PAISRE"}, {"V5F_DATAFG", "V4S_DATAFG"} }, V5F->(IndexKey(1)) )

//infoPgto\procJud\despProcJud\IdeAdv
oModel:SetRelation("MODEL_V5G" , { {"V5G_FILIAL","xFilial('V5G')"}, {"V5G_ID","V5C_ID"}, {"V5G_VERSAO","V5C_VERSAO"}, {"V5G_IDNTRE" ,"V5D_IDNTRE"}, {"V5G_PAISRE", "V5D_PAISRE"}, {"V5G_DATAFG", "V4S_DATAFG"} }, V5G->(IndexKey(1)) )

Return oModel
 */
//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Katielly Rezende / Denis Souza
@since 12/08/2019
@version 1.0
/*/
/* Static Function ViewDef()

Local oModel   As Object
Local oView	   As Object
Local oStrV5Ca As Object
Local oStrV5Cb As Object
Local oStrV5Da As Object
Local oStrV5Db As Object
Local oStrV5Dc As Object
Local oStrV4Sa As Object
Local oStrV4Sb As Object
Local oStrV4Sc As Object
Local oStrV4Sd As Object
Local oStrV4Se As Object
Local oStrV4Sf As Object
Local oStrV4Sg As Object
Local oStrV4Sh As Object
Local oStrV4Si As Object
Local oStrV4Sj As Object
Local oStrV5F  As Object
Local oStrV5G  As Object

Local cGrpV5Cb As Character
Local cGrpV5Da As Character
Local cGrpV5Db As Character
Local cGrpV5Dc As Character
Local cGrpV4Sa As Character
Local cGrpV4Sb As Character
Local cGrpV4Sc As Character
Local cGrpV4Sd As Character
Local cGrpV4Se As Character
Local cGrpV4Sf As Character
Local cGrpV4Sg As Character
Local cGrpV4Sh As Character
Local cGrpV4Si As Character
Local cGrpV4Sj As Character
Local cGrpV5F  As Character
Local cGrpV5G  As Character
Local cGrpCom1 As Character
Local cGrpCom2 As Character
Local aCmpGrp1 As Array
Local aCmpGrp2 As Array
Local nI       As Numeric

oModel   := FWLoadModel( 'TAFA546' )
oView    := FWFormView():New()
oStrV5Ca := FWFormStruct( 2, 'V5C')

oStrV5Ca:AddGroup( "GRP_01", "ideEstab ( Identificaï¿½ï¿½o do Estabelecimento )", "", 1 ) //"ideEstab ( Identificaï¿½ï¿½o do Estabelecimento )"
oStrV5Ca:AddGroup( "GRP_02", "ideBenef ( Identificaï¿½ï¿½o do Beneficiï¿½rio do Rendimento )", "", 1 ) //"ideBenef ( Identificaï¿½ï¿½o do Beneficiï¿½rio do Rendimento )"

cGrpCom1 := "V5C_VERSAO|V5C_VERANT|V5C_PROTPN|V5C_EVENTO|V5C_ATIVO|V5C_PERAPU|V5C_IDESTA|V5C_DESTAB|V5C_TPINSC|V5C_NRINSC|"
aCmpGrp1 := StrToKArr(cGrpCom1, "|")
For nI := 1 To Len( aCmpGrp1 )
    oStrV5Ca:SetProperty( aCmpGrp1[nI], MVC_VIEW_GROUP_NUMBER, "GRP_01" )
Next nI

cGrpCom2 := "V5C_IDPART|V5C_CNPJBN|V5C_NMBENE|V5C_ISEIMU|"
aCmpGrp2 := StrToKArr(cGrpCom2,"|")
For nI := 1 To Len( aCmpGrp2 )
    oStrV5Ca:SetProperty( aCmpGrp2[nI], MVC_VIEW_GROUP_NUMBER, "GRP_02" )
Next nI

oStrV5Ca:RemoveField( "V5C_ID"     )
oStrV5Ca:RemoveField( "V5C_PROTUL" )
oStrV5Ca:RemoveField( "V5C_XMLID"  )
oStrV5Ca:RemoveField( "V5C_IDPART" )

cGrpV5Cb := "V5C_PROTUL|"
oStrV5Cb := FwFormStruct( 2, 'V5C', {|x| AllTrim( x ) + "|" $ cGrpV5Cb} )

cGrpV5Da := "V5D_CNATRE|V5D_DNATRE|V5D_PAISRE|V5D_OBSERV|"
oStrV5Da := FwFormStruct( 2, 'V5D', {|x| AllTrim( x ) + "|" $ cGrpV5Da} )

cGrpV5Db := "V5D_LOGRAD|V5D_NRLOGR|V5D_COMPLE|V5D_BAIRRO|V5D_CIDADE|V5D_ESTADO|V5D_CEP|V5D_TELEF|"
oStrV5Db := FwFormStruct( 2, 'V5D', {|x| AllTrim( x ) + "|" $ cGrpV5Db} )

cGrpV5Dc := "V5D_INDNIF|V5D_NIF|V5D_CTRIB|V5D_DTRIB|V5D_RELPGT|V5D_DRELPG|"
oStrV5Dc := FwFormStruct( 2, 'V5D', {|x| AllTrim( x ) + "|" $ cGrpV5Dc} )

cGrpV4Sa := "V4S_VLRTOT|V4S_VLRCRE|V4S_DATAFG|"
oStrV4Sa := FwFormStruct( 2, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sa} )

cGrpV4Sb := "V4S_BASEIR|V4S_VLRIR|V4S_BASNIR|V4S_VLRNIR|V4S_VLDPIR|"
oStrV4Sb := FwFormStruct( 2, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sb} )

cGrpV4Sc := "V4S_BCSLL|V4S_VLCSLL|V4S_BNCSLL|V4S_VLNCSL|V4S_VLDCSL|"
oStrV4Sc := FwFormStruct( 2, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sc} )

cGrpV4Sd := "V4S_BCOFIN|V4S_VCOFIN|V4S_VBNCOF|V4S_VLNCOF|V4S_DCOFIN|"
oStrV4Sd := FwFormStruct( 2, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sd} )

cGrpV4Se := "V4S_BASEPP|V4S_VLRPP|V4S_VLRBPP|V4S_VLRNPP|V4S_VLRDPP|"
oStrV4Se := FwFormStruct( 2, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Se} )

cGrpV4Sf := "V4S_NRFCI|"
oStrV4Sf := FwFormStruct( 2, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sf} )

cGrpV4Sg := "V4S_NRSCP|V4S_PERSCP|"
oStrV4Sg := FwFormStruct( 2, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sg} )

cGrpV4Sh := "V4S_NRPROC|V4S_ORIREC|V4S_DESCRI|"
oStrV4Sh := FwFormStruct( 2, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sh} )

cGrpV4Si := "V4S_VLRCUS|V4S_VLRADV|"
oStrV4Si := FwFormStruct( 2, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Si} )

cGrpV4Sj := "V4S_CGCORI|"
oStrV4Sj := FwFormStruct( 2, 'V4S', {|x| AllTrim( x ) + "|" $ cGrpV4Sj} )

cGrpV5F  := "V5F_TPPROC|V5F_NRPROC|V5F_CODSUS|V5F_VLRNIR|V5F_VDEPIR|V5F_VLNCSL|V5F_VDCSLL|V5F_VNRCOF|V5F_VDPCOF|V5F_VLNRPP|V5F_VLDPPP|"
oStrV5F  := FwFormStruct( 2, 'V5F', {|x| AllTrim( x ) + "|" $ cGrpV5F} )

cGrpV5G  := "V5G_TPINSC|V5G_NRINSC|V5G_VLRADV|"
oStrV5G  := FwFormStruct( 2, 'V5G', {|x| AllTrim( x ) + "|" $ cGrpV5G} )

oView:SetModel( oModel )
oView:SetContinuousForm( .T. )

//-------------------------------------------------
// Nï¿½vel 3( IdeEstab ) e Nï¿½vel 4( IdeBenef )
//-------------------------------------------------
oView:CreateHorizontalBox( "BOXH_MASTER", 100 )
oView:CreateFolder( "FOLDER_MASTER", "BOXH_MASTER" )
oView:AddSheet( "FOLDER_MASTER", "SHEET_MASTER", STR0012 ) //"R-4020"
oView:AddSheet( "FOLDER_MASTER", "SHEET_PROTUL", STR0013 ) //"Recibo"

oView:AddField( "VIEW_V5CA", oStrV5Ca, "MODEL_V5C" )
oView:EnableTitleView( "VIEW_V5CA", STR0014 ) //"R-4020 - Retenï¿½ï¿½es na Fonte - Pessoa Jurï¿½dica"
oView:CreateHorizontalBox( "PAINEL_SUPERIOR", 30, , , "FOLDER_MASTER", "SHEET_MASTER" ) //A All 100 Used 30 Remaining 70
oView:SetOwnerView( "VIEW_V5CA", "PAINEL_SUPERIOR" )

oView:AddField( "VIEW_V5CB", oStrV5Cb, "MODEL_V5C" )
oView:EnableTitleView( "VIEW_V5CB", STR0015 ) //"Recibo R-4020 - Retenï¿½ï¿½es na Fonte - Pessoa Jurï¿½dica"
oView:CreateHorizontalBox( "PAINEL_SUPERIORB", 100, , ,"FOLDER_MASTER","SHEET_PROTUL" )
oView:SetOwnerView( "VIEW_V5CB", "PAINEL_SUPERIORB" )

//-------------------------------------------------
// Nï¿½vel 5( IdePgto )
//-------------------------------------------------
oView:CreateHorizontalBox( "1BOXH_IDEBENEF", 70, , , "FOLDER_MASTER", "SHEET_MASTER" ) //A All 70 Used 70 Remaining 0
oView:CreateFolder( "FOLDER_IDEBENEF", "1BOXH_IDEBENEF" )   
oView:AddSheet( "FOLDER_IDEBENEF", "SHEET_IDEPGTO", STR0016 ) //"IdePgto"

oView:CreateHorizontalBox( "BOXH_IDEPGTO", 30, , , "FOLDER_IDEBENEF", "SHEET_IDEPGTO") //B All 100 Used 30 Remaining 70
oView:AddGrid( "VIEW_V5DA", oStrV5Da, "MODEL_V5DA" )
oView:EnableTitleView( "VIEW_V5DA", STR0017 ) //"Identificaï¿½ï¿½o do rendimento"
oView:SetOwnerView( "VIEW_V5DA", "BOXH_IDEPGTO" )

//-------------------------------------------------
// Nï¿½vel 6( infoPgto / infoPgtoExt )
//-------------------------------------------------
oView:CreateHorizontalBox( "1BOXH_IDEPGTO", 70, , , "FOLDER_IDEBENEF", "SHEET_IDEPGTO" ) //B All 70 Used 70 Remaining 0
oView:CreateFolder( "FOLDER_IDEPGTO", "1BOXH_IDEPGTO" )
oView:AddSheet( "FOLDER_IDEPGTO", "SHEET_INFOPGTO", STR0018 ) //"infoPgto"

oView:CreateHorizontalBox( "BOXH_INFOPGTO", 40, , , "FOLDER_IDEPGTO", "SHEET_INFOPGTO" ) //C All 100 Used 40 Remaining 60
oView:AddGrid( "VIEW_V4SA", oStrV4Sa, "MODEL_V4SA" )
oView:EnableTitleView( "VIEW_V4SA", STR0019 ) //"Informaï¿½ï¿½es relativas ao pagamento efetuado"
oView:SetOwnerView( "VIEW_V4SA", "BOXH_INFOPGTO" )

oView:CreateHorizontalBox( "1BOXH_INFOPGTO", 30, , ,"FOLDER_IDEPGTO", "SHEET_INFOPGTO" ) //C All 60 Used 30 Remaining 30 
oView:CreateFolder( "FOLDER_INFOPGTO", "1BOXH_INFOPGTO" )

oView:AddSheet( "FOLDER_IDEPGTO", "SHEET_INFOPGTOEX", STR0020 ) //"infoPgtoExt"
oView:CreateHorizontalBox( "BOXH_INFOPGTOEX", 30, , , "FOLDER_IDEPGTO", "SHEET_INFOPGTOEX" ) //C All 30 Used 30 Remaining 0

// //-------------------------------------------------
// // Nï¿½vel 7( endExt / infoFiscal )
// //-------------------------------------------------
oView:CreateFolder( "FOLDER_INFOPGTOEX", "BOXH_INFOPGTOEX" )
oView:AddSheet( "FOLDER_INFOPGTOEX", "SHEET_ENDEXT", STR0021 ) //"endExt"
oView:AddSheet( "FOLDER_INFOPGTOEX", "SHEET_INFOFISCAL", STR0022 ) //"infoFiscal"
oView:CreateHorizontalBox( "BOX_ENDEXT", 100, , , "FOLDER_INFOPGTOEX", "SHEET_ENDEXT" )
oView:CreateHorizontalBox( "BOX_INFOFISCAL", 100, , , "FOLDER_INFOPGTOEX", "SHEET_INFOFISCAL" )

oView:AddGrid( "VIEW_V5DB", oStrV5Db, "MODEL_V5DB" )
oView:EnableTitleView( "VIEW_V5DB", STR0023 ) //"Endereï¿½o do beneficiï¿½rio residente ou domiciliado no exterior"
oView:SetOwnerView( "VIEW_V5DB", "BOX_ENDEXT" )

oView:AddGrid( "VIEW_V5DC", oStrV5Dc, "MODEL_V5DC" )
oView:EnableTitleView( "VIEW_V5DC", STR0024 ) //"Informaï¿½ï¿½es fiscais do beneficiï¿½rio residente ou domiciliado no exterior"
oView:SetOwnerView( "VIEW_V5DC", "BOX_INFOFISCAL" )

//-------------------------------------------------
// Nï¿½vel 7( IR / CSLL / COFINS / PP )
//-------------------------------------------------
oView:AddSheet( "FOLDER_INFOPGTO", "SHEET_IR", "IR" ) //"IR"
oView:CreateHorizontalBox( "BOXH_IR", 100, , , "FOLDER_INFOPGTO", "SHEET_IR" )
oView:AddGrid( "VIEW_V4SB", oStrV4Sb, "MODEL_V4SB" )
oView:EnableTitleView( "VIEW_V4SB", STR0025 ) //"Informaï¿½ï¿½es Relativas Ao Imposto de Renda"
oView:SetOwnerView( "VIEW_V4SB", "BOXH_IR" )

oView:AddSheet( "FOLDER_INFOPGTO", "SHEET_CSLL", "CSLL" ) //"CSLL"
oView:CreateHorizontalBox( "BOXH_CSLL", 100, , , "FOLDER_INFOPGTO", "SHEET_CSLL" )
oView:AddGrid( "VIEW_V4SC", oStrV4Sc, "MODEL_V4SC" )
oView:EnableTitleView( "VIEW_V4SC", STR0026 ) //"Informaï¿½ï¿½es Relativas ï¿½ CSLL"
oView:SetOwnerView( "VIEW_V4SC", "BOXH_CSLL" )

oView:AddSheet( "FOLDER_INFOPGTO", "SHEET_COFINS", "COFINS" ) //"COFINS"
oView:CreateHorizontalBox( "BOXH_COFINS", 100, , , "FOLDER_INFOPGTO", "SHEET_COFINS" )
oView:AddGrid( "VIEW_V4SD", oStrV4Sd, "MODEL_V4SD" )
oView:EnableTitleView( "VIEW_V4SD", STR0027 ) //"Informaï¿½ï¿½es Relativas ï¿½ COFINS"
oView:SetOwnerView( "VIEW_V4SD", "BOXH_COFINS" )

oView:AddSheet( "FOLDER_INFOPGTO", "SHEET_PP", "PP" ) //"PP"
oView:CreateHorizontalBox( "BOXH_PP", 100, , , "FOLDER_INFOPGTO", "SHEET_PP" )
oView:AddGrid( "VIEW_V4SE", oStrV4Se, "MODEL_V4SE" )
oView:EnableTitleView( "VIEW_V4SE", STR0028 ) //"Informaï¿½ï¿½es Relativas ao PIS/PASEP"
oView:SetOwnerView( "VIEW_V4SE", "BOXH_PP" )

// //-------------------------------------------------
// // Nï¿½vel 7( FCI / SCP / infoProcRet / infoProcJud )
// //-------------------------------------------------
oView:AddSheet( "FOLDER_INFOPGTO", "SHEET_FCI", "FCI" ) //"FCI"
oView:CreateHorizontalBox( "BOXH_FCI", 100, , , "FOLDER_INFOPGTO", "SHEET_FCI" )
oView:AddGrid( "VIEW_V4SF", oStrV4Sf, "MODEL_V4SF" )
oView:EnableTitleView( "VIEW_V4SF", STR0029 ) //"Fundo ou Clube de Investimento no qual o beneficiï¿½rio faï¿½a parte e seja administrado pelo declarante"
oView:SetOwnerView( "VIEW_V4SF", "BOXH_FCI" )

oView:AddSheet( "FOLDER_INFOPGTO", "SHEET_SCP", "SCP" ) //"SCP"
oView:CreateHorizontalBox( "BOXH_SCP", 100, , , "FOLDER_INFOPGTO", "SHEET_SCP" )
oView:AddGrid( "VIEW_V4SG", oStrV4Sg, "MODEL_V4SG" )
oView:EnableTitleView( "VIEW_V4SG", STR0030 ) //"Sociedade em conta de Participaï¿½ï¿½o do qual o beneficiï¿½rio faï¿½a parte e o declarante seja Sï¿½cio Ostensivo"
oView:SetOwnerView( "VIEW_V4SG", "BOXH_SCP" )

oView:AddSheet( "FOLDER_INFOPGTO", "SHEET_INFOPRET", "infoProcRet" ) //"infoProcRet"
oView:CreateHorizontalBox( "BOXH_INFOPRET", 100, , , "FOLDER_INFOPGTO", "SHEET_INFOPRET" )
oView:AddGrid( "VIEW_V5F", oStrV5F, "MODEL_V5F" )
oView:EnableTitleView( "VIEW_V5F", STR0031 ) //"Informaï¿½ï¿½es de processos relacionados a nï¿½o retenï¿½ï¿½o de tributos ou depï¿½sitos judiciais"
oView:SetOwnerView( "VIEW_V5F", "BOXH_INFOPRET" )

oView:AddSheet( "FOLDER_INFOPGTO", "SHEET_INFOPJUD", "infoProcJud" ) //"infoProcJud"
oView:CreateHorizontalBox( "BOXH_INFOPJUD", 50, , , "FOLDER_INFOPGTO", "SHEET_INFOPJUD" ) //D All 100 Used 50 Remaining 50
oView:AddGrid( "VIEW_V4SH", oStrV4Sh, "MODEL_V4SH" )
oView:EnableTitleView( "VIEW_V4SH", STR0032 ) //"Informaï¿½ï¿½es complementares relativas a rendimentos decorrentes de decisï¿½o judicial"
oView:SetOwnerView( "VIEW_V4SH", "BOXH_INFOPJUD" )

// //-------------------------------------------------
// // Nï¿½vel 8 ( despProcJud / origemRec )
// //-------------------------------------------------
oView:CreateHorizontalBox( "1BOXH_INFOPJUD", 50, , ,"FOLDER_INFOPGTO", "SHEET_INFOPJUD" ) //D All 50 Used 50 Remaining 0
oView:CreateFolder( "FOLDER_INFOPJUD", "1BOXH_INFOPJUD" )
oView:AddSheet( "FOLDER_INFOPJUD", "SHEET_DESPJUD", STR0033 ) //"despProcJud"
oView:AddSheet( "FOLDER_INFOPJUD", "SHEET_ORGREC" , STR0034 ) //"origemRec"
oView:CreateHorizontalBox( "BOX_DESPJUD", 50, , , "FOLDER_INFOPJUD", "SHEET_DESPJUD" ) //E All 100 Used 50 Remaining 50
oView:CreateHorizontalBox( "BOX_ORGREC" , 100, , , "FOLDER_INFOPJUD", "SHEET_ORGREC" )

oView:AddGrid( "VIEW_V4SI", oStrV4Si, "MODEL_V4SI" )
oView:EnableTitleView( "VIEW_V4SI", STR0035 ) //"Detalhamento das despesas com processo judicial"
oView:SetOwnerView( "VIEW_V4SI", "BOX_DESPJUD" )

oView:AddGrid( "VIEW_V4SJ", oStrV4Sj, "MODEL_V4SJ" )
oView:EnableTitleView( "VIEW_V4SJ", STR0036 ) //"Identificaï¿½ï¿½o da Origem dos Recursos"
oView:SetOwnerView( "VIEW_V4SJ", "BOX_ORGREC" )

// //-------------------------------------------------
// // Nï¿½vel 9 ( ideAdv )
// //-------------------------------------------------
oView:CreateHorizontalBox( "BOXH_IDEADV", 50, , , "FOLDER_INFOPJUD", "SHEET_DESPJUD" ) //E All 50 Used 50 Remaining 0
oView:CreateFolder( "FOLDER_IDEADV", "BOXH_IDEADV" )
oView:AddSheet( "FOLDER_IDEADV", "SHEET_IDEADV", STR0037 ) //"ideAdv"
oView:CreateHorizontalBox( "1BOXH_IDEADV", 100, , , "FOLDER_IDEADV", "SHEET_IDEADV" )
oView:AddGrid( "VIEW_V5G", oStrV5G, "MODEL_V5G" )
oView:EnableTitleView( "VIEW_V5G", STR0038 ) //"Identificaï¿½ï¿½o do Advogado"
oView:SetOwnerView( "VIEW_V5G", "1BOXH_IDEADV" )

xFunRmFStr( @oStrV5Ca, "V5C" ) 

Return ( oView )
 */
//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse 

@author Katielly Rezende
@since 12/08/2019
@version 1.0
/*/
/* Static Function BrowseDef()
Local oBrw  as object

oBrw := FWmBrowse():New()	
oBrw:SetDescription( STR0003 )// "R-4020 - Retenï¿½ï¿½es na Fonte - Pessoa Jurï¿½dica
oBrw:SetAlias( 'V5C')
oBrw:SetMenuDef( 'TAFA546' )	
    
DbSelectArea("V5C")
Set Filter TO &("V5C_ATIVO == '1'")

oBrw:Activate()

Return( oBrw ) */