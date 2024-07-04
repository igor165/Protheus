#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA541.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA541
Cadastro MVC Despesas Processuais/RRA T160
@author Leticia Campos da Silva
@since 17/07/2019
@version 1.0
/*/ 
//-------------------------------------------------------------------
Function TAFA541()

	MsgInfo("Prezado cliente, esta rotina estará disponível após a liberação da REINF 2.0","Aviso - REINF")

/*
If TAFAlsInDic("V4F")
    BrowseDef()  
Else
    Aviso( STR0001, STR0002, { STR0004 }, 3 ) //"AVISO" ##"O ambiente do TAF encontra-se desatualizado. Para utilização desta funcionalidade, será necessário aplicar o dicionário de dados do REINF 2.0." ##"Encerrar"
EndIf

*/
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Tratamento para chamada do MenuDef
@author Leticia Campos da Silva
@since 17/07/2019
@version 1.0
/*/ 
//-------------------------------------------------------------------
/* Static Function BrowseDef()
Local oBrw := FWMBrowse():New()

DBSelectArea("V4F")
DbSetOrder(1)

oBrw:SetDescription(STR0003) //"Despesas Processuais/RRA"
oBrw:SetAlias( 'V4F' ) 
oBrw:SetMenuDef( 'TAFA541' )
oBrw:Activate()

Return oBrw
 */
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Leticia Campos da Silva
@since 17/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/* Static Function MenuDef()
Local aRotina   := {}

aRotina := xFunMnuTAF("TAFA541")

Return( aRotina )
 */
//-------------------------------------------------------------------
 /*{Protheus.doc} ModelDef
Funcao generica MVC do model
@author Leticia Campos da Silva
@since 17/07/2019
@version 1.0
*/
/* Static Function ModelDef()
Local oStruV4F   := FWFormStruct( 1, 'V4F' )
Local oStruV4G   := FWFormStruct( 1, 'V4G' )
Local oModel 	 := MPFormModel():New( 'TAFA541' ,,{ |oModel| ValidModel( oModel ) },{|oModel| SaveModel( oModel ) })

oModel:AddFields('MODEL_V4F',, oStruV4F)
oModel:AddGrid('MODEL_V4G', 'MODEL_V4F', oStruV4G) 

oModel:GetModel('MODEL_V4F'):SetPrimaryKey( { "V4F_ID" } )
oModel:GetModel('MODEL_V4G'):SetOptional( .F. )
oModel:GetModel('MODEL_V4G'):SetUniqueLine( { 'V4G_DTDESP', 'V4G_TPDESP', 'V4G_IDADVG' } ) 

oModel:SetRelation('MODEL_V4G', { { "V4G_FILIAL", "xFilial( 'V4G' )" } , { "V4G_ID" , 'V4F_ID' } }, V4G->( IndexKey(1) ) )

Return (oModel)
 */
//----------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View
@return oView - Objeto da View MVC
@author Leticia Campos da Silva
@since 17/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/* Static Function ViewDef()
Local oModel    := FWLoadModel('TAFA541')
Local oStruV4F  := FWFormStruct(2, 'V4F')
Local oStruV4G 	:= FWFormStruct(2, 'V4G')
Local oView     := FWFormView():New()

oStruV4F:RemoveField('V4F_ID')
oStruV4G:RemoveField('V4G_ID')
oStruV4G:RemoveField("V4G_IDADVG")
oStruV4G:RemoveField("V4G_TPINSC")

oView:SetModel( oModel )
oView:SetContinuousForm(.T.)

oView:AddField              ('VIEW_V4F', oStruV4F, 'MODEL_V4F')
oView:CreateHorizontalBox   ('PAINEL_SUPERIOR', 50 )

oView:AddGrid               ('VIEW_V4G', oStruV4G, 'MODEL_V4G')
oView:EnableTitleView       ("VIEW_V4G", STR0005) //Detalhamento das Despesas
oView:CreateHorizontalBox   ("GRIDV4G" , 50                   ) 

oView:SetOwnerView("VIEW_V4F", "PAINEL_SUPERIOR" )
oView:SetOwnerView("VIEW_V4G", "GRIDV4G") 

Return(oView)
 */
//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Função de validação da inclusão dos dados, chamada no final, no momento da gravação do modelo.
@return .T. ou .F.
@author Leticia Campos da Silva
@since 26/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/* Static Function ValidModel( oModel )
Local lRet          := .T.
Local cIndRRA       := FwFldGet("V4F_INDRRA")
Local cTpProc       := FwFldGet("V4F_TPPROC")
Local cNrProc       := FwFldGet("V4F_NRPROC")
Local cId           := FwFldGet("V4F_ID")

    DBSelectArea("V4F")
    DbSetOrder(2)

    If DBSeek(xFilial("V4F") + cIndRRA + cTpProc + cNrProc )
        if V4F->V4F_ID <> cId
            Help( ,, 'Help',, STR0019, 1, 0 ) // "Registro já cadastrado na base de dados"
            lRet := .F.
        endif
    ElseIf FwFldGet("V4F_INDRRA") == '1'
        if Empty( FwFldGet("V4F_TPPROC") )
            oModel:SetErrorMessage( ,,,,, STR0008, STR0009,, ) //"O tipo de processo se torna obrigatório quando o Indicativo de RRA é a opção 1-Sim."#"Informe um código válido."
            lRet := .F.
        elseif Empty( FwFldGet("V4F_DESCRI") )
            oModel:SetErrorMessage( ,,,,, STR0010, STR0011,, ) //"A descrição do processo judicial ou dos rendimentos recebidos acumuladamente se torna obrigatório quando o Indicativo de RRA é a opção 1-Sim."#"Informe uma descrição." 
            lRet := .F.
        elseif Empty( FwFldGet("V4F_QTDMES") )
            oModel:SetErrorMessage( ,,,,, STR0012, STR0013,, ) //"O número de meses relativo aos rendimentos recebidos acumuladamente se torna obrigatório quando o Indicativo de RRA é a opção 1-Sim."#"Informe a quantidade de meses" 
            lRet := .F.
        elseif Empty( FwFldGet("V4F_CNPJOR") ) .And. FwFldGet("V4F_INDORI") == '2'
            oModel:SetErrorMessage( ,,,,, STR0014, STR0015,, ) //"O CNPJ da empresa origem que repassou recursos se torna obrigatório quando o Indicativo de RRA é a opção 1-Sim e a Origem de Recursos a opção é 2-Recursos de terceiros."#"Informe um CNPJ válido" 
            lRet := .F.
        endif
    EndIf

    If FwFldGet("V4F_INDRRA") == '0' .And. Empty( FwFldGet("V4F_CNPJOR") )
        oModel:SetErrorMessage( ,,,,, STR0016, STR0015,, )//"O CNPJ da empresa origem que repassou recursos se torna obrigatório quando o Indicativo de RRA é a opção 0-Não."#"Informe um CNPJ válido" 
        lRet := .F.
    EndIf

    If FwFldGet("V4G_TPDESP") == '1' .And. Empty( FwFldGet("V4G_NRINSC") )
        oModel:SetErrorMessage( ,,,,, STR0017, STR0018,, ) //"O Número de Inscrição do advogado se torna obrigatório quando o tipo de despesa for a opção 1-Com Advogados."#"Informe o número de inscrição do advogado."
        lRet := .F.
    EndIf


Return( lRet )
 */
//--------------------------------------------------
 /*{Protheus.doc} SaveModel 
Salva o modelo e realiza validações antes de gravar
@author Leticia Campos da Silva
@since 17/07/2019
@version 1.0
*/
/* Static Function SaveModel(oModel)

FWFormCommit( oModel )

Return .T.
 */
//--------------------------------------------------
 /*{Protheus.doc} TAFVald
Realiza a validação do CNPJ
@author Leticia Campos da Silva
@since  17/07/2019
@version 1.0
*/
/* Function TAFVald()
Local cCNPJ := FwFldGet("V4F_CNPJOR")
Local lOk   := .F.

If CGC( FwFldGet("V4F_CNPJOR") )   
    DBSelectArea("V4F")
    DbSetOrder(2)
    If DBSeek(xFilial("V4F") + cCNPJ)
        Help("",1,"Help","Help",STR0006, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0007}) // "Informe outro CNPJ" / "Número de CNPJ já cadastrado na base de dados"
        lOk := .F.
    Else
        lOk := .T.   
    EndIf
EndIf
Return lOk
 */
//-------------------------------------------------------------------
/*/	{Protheus.doc} TAFDespRRA
Realiza validações para cada campo
@author Leticia Campos da Silva
@since  17/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
/* Function TAFDespRRA(cCampo)
Local lOk := .T.

Default cCampo := "0"

If cCampo == '1'
    if FwFldGet("V4F_INDRRA") == '1' .And. Empty( FwFldGet("V4F_TPPROC") )
        Help("",1,"Help","Help",STR0008, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0009}) //"O código correspondente ao tipo de processo se torna obrigatório quando o Indicativo de RRA é a opção 1-Sim."#"Informe um código válido."
        lOk := .F.
    endif
ElseIf cCampo == '2'
    if FwFldGet("V4F_INDRRA") == '1' .And. Empty( FwFldGet("V4F_DESCRI") )
        Help("",1,"Help","Help",STR0010, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0011})//"A descrição do processo judicial ou dos rendimentos recebidos acumuladamente se torna obrigatório quando o Indicativo de RRA é a opção 1-Sim."#"Informe uma descrição." 
        lOk := .F.
    endif
ElseIf cCampo == '3'
    if FwFldGet("V4F_INDRRA") == '1' .And. Empty( FwFldGet("V4F_QTDMES") )
        Help("",1,"Help","Help",STR0012, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0013})//"O número de meses relativo aos rendimentos recebidos acumuladamente se torna obrigatório quando o Indicativo de RRA é a opção 1-Sim."#"Informe a quantidade de meses" 
        lOk := .F.
    endif    
ElseIf cCampo == '4'
    if FwFldGet("V4F_INDRRA") == '1' .And. Empty( FwFldGet("V4F_CNPJOR") ) .And. FwFldGet("V4F_INDORI") == '2'
        Help("",1,"Help","Help",STR0014, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0015})//"O CNPJ da empresa origem que repassou recursos se torna obrigatório quando o Indicativo de RRA é a opção 1-Sim e a Origem de Recursos a opção é 2-Recursos de terceiros."#"Informe um CNPJ válido" 
        lOk := .F.
    elseif FwFldGet("V4F_INDRRA") == '0' .And. Empty( FwFldGet("V4F_CNPJOR") )
        Help("",1,"Help","Help",STR0016, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0015})//"O CNPJ da empresa origem que repassou recursos se torna obrigatório quando o Indicativo de RRA é a opção 0-Não."#"Informe um CNPJ válido" 
        lOk := .F.
    endif
ElseIf cCampo == '5'
    if FwFldGet("V4G_TPDESP") == '1' .And. Empty( FwFldGet("V4G_NRINSC") )
        Help("",1,"Help","Help",STR0017, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0009}) //"O código correspondente ao tipo de processo se torna obrigatório quando o Indicativo de RRA é a opção 1-Sim."#"Informe um código válido."
        lOk := .F.
    endif
EndIf
Return lOk */