#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA535.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA535
MVC Pagamentos das Parcelas da fatura/recibo 
Layout totvs T158 / T158AA

@author Henrique Pereira			
@since 11/06/2019
@version 1.0
  
/*/
//-------------------------------------------------------------------

Function TAFA535(cTafatura)  
Private cNumFat :=  ''
Private cFatParc    := ''
Default cTafatura   :=  ''

cNumFat :=  cTafatura

    MsgInfo("Prezado cliente, esta rotina estará disponível após a liberação da REINF 2.0","Aviso - REINF")
/*
if TAFAlsInDic("V3U")   
    browsedef()  
else
    Aviso( STR0001, STR0002, { STR0003 }, 3 )  // #Aviso , "Ambiente desatualizado para execução desta Rotina. Tabelas: V3U e V3V não existem no metadados.", {Encerrar}                                                                                                                                                                                                                                                                                                                                                                                                                 
endif
*/

return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} browsedef
Browse Pagamentos das Parcelas da fatura/recibo 

@author Henrique Pereira			
@since 11/06/2019
@version 1.0

/*/
//-------------------------------------------------------------------

/*
static function browsedef()

local oBrowse   as object

//--------------------------------------------
// Inicialização variáveis do tipo objeto
//--------------------------------------------
oBrowse := FWmBrowse():New()

DBSelectArea("V3U")
DbSetOrder(1)

oBrowse:SetDescription( STR0004 )	//"Pagamentos das Parcelas da fatura/recibo  //#STR
if !empty(cNumFat)
    oBrowse:SetFilterDefault( "V3U_NUMERO == cNumFat" ) 
endif
oBrowse:SetAlias( 'V3U')
oBrowse:SetMenuDef( 'TAFA535' )	
oBrowse:Activate()

return oBrowse
*/

//--------------------------------------------------
/*/{Protheus.doc} modeldef
Model de Pagamentos das Parcelas da fatura/recibo 

@author Henrique Pereira			
@since 11/06/2019
@version 1.0

/*/
//--------------------------------------------------
/*
static function modeldef()
local oModel     as object
local oStruV3U   as object
local oStruV3V   as object
Local oStruV46   as object
local oStruV4H   as object
local oStruV4I   as object
local oStruV4J   as object
Local bValidV46

oModel           := MPFormModel():new("TAFA535")

//--------------------------------------------
// Inicialização variáveis do tipo objeto
//--------------------------------------------
oStruV3U    := FWFormStruct(1,"V3U") 
oStruV3V    := FWFormStruct(1,"V3V")
oStruV46    := FWFormStruct(1,"V46")
oStruV4H    := FWFormStruct(1,"V4H")
oStruV4I    := FWFormStruct(1,"V4I")
oStruV4J    := FWFormStruct(1,"V4J")
oModel      := MPFormModel():new("TAFA535",,{ | oModel | ValidModel( oModel ) },{|oModel| SaveModel( oModel ) })

oModel:addfields('MODEL_V3U',,oStruV3U ) // Pagamentos
oModel:GetModel('MODEL_V3U'):SetPrimaryKey( { "V3U_NUMERO", "V3U_SERIE", "V3U_IDPART", "V3U_DTEMIS", "V3U_NATTIT", "V3U_PARCEL", "V3U_DTPAGT", "V3U_SEQUEN" } )

oStruV3U:SetProperty( "*", MODEL_FIELD_WHEN, { || oModel:GetOperation( ) == MODEL_OPERATION_INSERT } )

oStruV3V:SetProperty( "V3V_CNATRE", MODEL_FIELD_VALID, { | | VldNat( @oModel ) }  ) // Validação do campo V3V_CNATRE

oModel:addgrid('MODEL_V3V','MODEL_V3U',oStruV3V,, { | | VldLineV3V( @oModel:GetModel( "MODEL_V3V" ) ) } ) // Natureza
oModel:GetModel("MODEL_V3V"):SetUniqueLine( { "V3V_CNATRE", "V3V_DECTER" } )
oModel:SetRelation("MODEL_V3V",{ {"V3V_FILIAL","xFilial('V3V')"}, {"V3V_ID","V3U_ID"} },V3V->(IndexKey(1)))

bValidV46 := { | oModelGrid, nLine, cAction, cField, xValNew, xValOld | VldV46Pre( oModelGrid, cAction, cField, xValNew, xValOld ) }

oModel:addgrid( "MODEL_V46", "MODEL_V3V", oStruV46, bValidV46 ) // Tributos
oModel:GetModel( "MODEL_V46" ):SetUniqueLine( { "V46_IDTRIB" } )
oModel:SetRelation( "MODEL_V46", { { "V46_FILIAL", "xFilial( 'V46' )" }, { "V46_ID", "V3U_ID" }, { "V46_IDNAT", "V3V_CNATRE" } }, V46->( IndexKey( 1 ) ) )
oModel:GetModel( 'MODEL_V46' ):SetOptional( .T. )

oModel:addgrid('MODEL_V4H','MODEL_V3V',oStruV4H) // Suspensao
oModel:GetModel("MODEL_V4H"):SetUniqueLine({"V4H_IDPROC","V4H_IDSUSP","V4H_IDTRIB"})
oModel:SetRelation("MODEL_V4H",{ {"V4H_FILIAL","xFilial('V4H')"}, {"V4H_ID","V3U_ID"}, { "V4H_CNATRE", "V3V_CNATRE" } },V4H->(IndexKey(1)))
oModel:GetModel( 'MODEL_V4H' ):SetOptional( .T. )

oModel:addgrid('MODEL_V4I','MODEL_V46',oStruV4I,, { | | VldLineV4I( ) } ) // Dedução
oModel:GetModel("MODEL_V4I"):SetUniqueLine({"V4I_TPDEDU"})
oModel:SetRelation("MODEL_V4I",{{"V4I_FILIAL","xFilial('V4I')"},{"V4I_ID","V3U_ID"}, {"V4I_IDTRIB","V46_IDTRIB"},  {"V4I_IDNAT","V3V_CNATRE"} },V4I->(IndexKey(1)))
oModel:GetModel( 'MODEL_V4I' ):SetOptional( .T. )

oModel:addgrid('MODEL_V4J','MODEL_V46',oStruV4J,, { | | VldLineV4J( ) } ) // Isenção
oModel:GetModel("MODEL_V4J"):SetUniqueLine({"V4J_IDTPIS"})
oModel:SetRelation("MODEL_V4J",{{"V4J_FILIAL","xFilial('V4J')"},{"V4J_ID","V3U_ID"}, {"V4J_IDNAT","V3V_CNATRE"}, {"V4J_IDTRIB","V46_IDTRIB"} },V4J->(IndexKey(1)))
oModel:GetModel( 'MODEL_V4J' ):SetOptional( .T. )

return oModel
*/
//--------------------------------------------------
/*/{Protheus.doc} viewdef
View de Pagamentos das Parcelas da fatura/recibo 

@author Henrique Pereira			
@since 11/06/2019
@version 1.0

/*/
//--------------------------------------------------
/*
static function viewdef()

local oView     as object
local oModel    as object
local oStruV3U  as object
local oStruV3V  as object
local oStruV4H  as object
local oStruV4I  as object
local oStruV4J  as object

//--------------------------------------------
// Inicialização variáveis do tipo obejeto
//--------------------------------------------
oView    := FWFormView():new()
oModel   := FWLoadModel('TAFA535')
oStruV3U := FwFormStruct(2,"V3U")
oStruV46 := FwFormStruct(2,"V46")
oStruV3V := FwFormStruct(2,"V3V")
oStruV4H := FwFormStruct(2,"V4H")
oStruV4I := FwFormStruct(2,"V4I")
oStruV4J := FwFormStruct(2,"V4J")

oView:SetModel( oModel )
oView:SetContinuousForm( .T. )

oView:AddField( "VIEW_V3U", oStruV3U, "MODEL_V3U" )
oView:EnableTitleView( "VIEW_V3U", STR0015 ) //"Pagamentos"
oView:CreateHorizontalBox( "PAINEL_SUPERIOR", 25 )
oView:SetOwnerView( "VIEW_V3U", "PAINEL_SUPERIOR" )

oView:AddGrid(  "VIEW_V3V", oStruV3V, "MODEL_V3V" )
oView:EnableTitleView( "VIEW_V3V", STR0036 ) //"Naturezas de Rendimento"
oView:CreateHorizontalBox( "PAINEL_INTERMEDIARIO", 25 )
oView:SetOwnerView( "VIEW_V3V", "PAINEL_INTERMEDIARIO" )

oView:CreateHorizontalBox( "PAINEL_INFERIOR", 50 )
oView:CreateFolder("FOLDER_INFERIOR","PAINEL_INFERIOR")

oView:AddSheet("FOLDER_INFERIOR","ABA01", STR0017 ) //"Tributos
oView:AddGrid(  "VIEW_V46", oStruV46, "MODEL_V46" )
oView:EnableTitleView( "VIEW_V46", STR0016 ) //"Tributos sobre o pagamento da parcela por Natureza de Rendimento"
oView:CreateHorizontalBox("BOXH_TRIBUTOS", 50,,,"FOLDER_INFERIOR","ABA01" )
oView:SetOwnerView( "VIEW_V46", "BOXH_TRIBUTOS" ) 

oView:AddSheet("FOLDER_INFERIOR","ABA02", STR0020) //"Suspensão"
oView:AddGrid(  "VIEW_V4H", oStruV4H, "MODEL_V4H" )
oView:EnableTitleView( "VIEW_V4H", STR0021 ) //"Suspensão de exigibilidade de tributo por natureza de rendimento"
oView:CreateHorizontalBox("BOXH_SUSPENSAO", 50,,,"FOLDER_INFERIOR","ABA02")
oView:SetOwnerView( "VIEW_V4H", "BOXH_SUSPENSAO" )   

oView:CreateHorizontalBox( 'BOX_CHILD_V46',50,,,'FOLDER_INFERIOR', 'ABA01' )
oView:CreateFolder( 'FOLDER_CHILD_V46', 'BOX_CHILD_V46' )

oView:AddSheet( 'FOLDER_CHILD_V46', 'ABA03', STR0018 ) //"Dedução"
oView:AddGrid(  "VIEW_V4I", oStruV4I, "MODEL_V4I" )
oView:EnableTitleView( "VIEW_V4I", STR0022 ) //"Dedução do Tributo por Natureza de Rendimento"
oView:CreateHorizontalBox( 'BOXH_DEDUCAO', 50,,, 'FOLDER_CHILD_V46', 'ABA03' )
oView:SetOwnerView( "VIEW_V4I", "BOXH_DEDUCAO" )

oView:AddSheet( 'FOLDER_CHILD_V46', 'ABA04', STR0019 ) //"Isenção"
oView:AddGrid(  "VIEW_V4J", oStruV4J, "MODEL_V4J" )
oView:EnableTitleView( "VIEW_V4J", STR0023 ) //"Isenção do Tributo por Natureza de Rendimento"
oView:CreateHorizontalBox( 'BOXH_ISENCAO',50,,, 'FOLDER_CHILD_V46', 'ABA04' )
oView:SetOwnerView( "VIEW_V4J", "BOXH_ISENCAO" ) 

//Removendo campos que não devem ser exibidos
oStruV3U:RemoveField( "V3U_ID"     )
oStruV3U:RemoveField( "V3U_IDPART" )
oStruV3U:RemoveField( "V3U_IDFTPC" )

oStruV3V:RemoveField( "V3V_ID"     )
oStruV3V:RemoveField( "V3V_IDPROC" )
oStruV3V:RemoveField( "V3V_CNATRE" )
oStruV3V:RemoveField( "V3V_IDFCI"  )
oStruV3V:RemoveField( "V3V_IDSCP"  )

oStruV46:RemoveField( "V46_ID"     )
oStruV46:RemoveField( "V46_IDNAT"  )
oStruV46:RemoveField( "V46_IDTRIB" )

oStruV4H:RemoveField( "V4H_ID"     )
oStruV4H:RemoveField( "V4H_IDTRIB" )
oStruV4H:RemoveField( "V4H_IDSUSP" )

oStruV4I:RemoveField( "V4I_ID"     )
oStruV4I:RemoveField( "V4I_IDTRIB" )
oStruV4I:RemoveField( "V4I_IDNAT"  )

oStruV4J:RemoveField( "V4J_ID"     )
oStruV4J:RemoveField( "V4J_IDTRIB" )
oStruV4J:RemoveField( "V4J_IDNAT"  )
oStruV4J:RemoveField( "V4J_IDTPIS" )

return oView
*/

//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu para Pagamentos das Parcelas da fatura/recibo 

@author Henrique Pereira			
@since 11/06/2019
@version 1.0

/*/
//--------------------------------------------------
/*
Static Function MenuDef()

Local aRotina as array

//--------------------------------------------
// Inicialização variáveis do tipo array
//--------------------------------------------
aRotina := {}

ADD OPTION aRotina Title "Visualizar"  Action 'VIEWDEF.TAFA535' OPERATION 2 ACCESS 0 //"Visualizar" #str
ADD OPTION aRotina Title "Incluir"     Action 'VIEWDEF.TAFA535' OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title "Alterar"     Action 'VIEWDEF.TAFA535' OPERATION 4 ACCESS 0 //"Alterar" #str
ADD OPTION aRotina Title "Excluir"     Action 'VIEWDEF.TAFA535' OPERATION 5 ACCESS 0 //"Excluir" 

Return(aRotina)
*/

//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu para Pagamentos das Parcelas da fatura/recibo 

@author Henrique Pereira			
@since 11/06/2019
@version 1.0

/*/
//--------------------------------------------------

/*
static function SaveModel(oModel)

Local nOper := oModel:getOperation( )

If  ( nOper == MODEL_OPERATION_UPDATE ) .OR. ( nOper == MODEL_OPERATION_INSERT )
    AmarraFat( oModel )
EndIf

FWFormCommit( oModel )

return .T.
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} AmarraFat

Função de validação da inclusão dos dados, chamada
no final, no momento da gravação do modelo.

@Param		oModel	- Modelo de dados

@Return	.T. ou .F.

@Author	Henrique Pereira
@Since		14/06/2019
@Version	1.0
/*/
//-------------------------------------------------------------------
/*
Static Function AmarraFat( oModel )
Local oModelV3U     as object 
Local cIdFatParc    as character
Local cNumero       as character
Local cSerie        as character
Local cIdPart       as character
Local dDtEmiss      as character
Local cNatTit       as character
Local cParcel       as character

//-----------------------------------------------
// Inicialização variáveis do tipo objeto
//-----------------------------------------------
oModelV3U   :=  oModel:GetModel('MODEL_V3U')

//-----------------------------------------------
// Inicialização variáveis do tipo caracter
//-----------------------------------------------
cIdFatParc := oModelV3U:GetValue("V3U_IDFTPC")

If Empty( cIdFatParc )

    cNumero     :=  oModelV3U:GetValue("V3U_NUMERO")
    cSerie      :=  oModelV3U:GetValue("V3U_SERIE")
    cIdPart     :=  oModelV3U:GetValue("V3U_IDPART")
    dDtEmiss    :=  oModelV3U:GetValue("V3U_DTEMIS")
    cNatTit     :=  oModelV3U:GetValue("V3U_NATTIT")
    cParcel     :=  oModelV3U:GetValue("V3U_PARCEL")
    cFatParc    :=  ExistFat(cNumero, cSerie, cIdPart, dDtEmiss, cNatTit, cParcel )

    oModel:LoadValue( 'MODEL_V3U', 'V3U_IDFTPC', cFatParc)

EndIf

Return
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} ExistFat 

Função de busca da fatura existente na base com base nos valores digitado na tela ou mesmo vindo de integração
no final, no momento da gravação do modelo.

@Return	.T. ou .F.

@Author	Henrique Pereira
@Since		14/06/2019
@Version	1.0
/*/
//-------------------------------------------------------------------
/*
function ExistFat(cNumero, cSerie, cIdPart, dDtEmiss, cNatTit, cParcel )

Local cRet      as character
Local cAlias    as character

default cNumero  := ''
default cSerie   := '' 
default cIdPart  := ''
default dDtEmiss := '' 
default cNatTit  := ''
default cParcel  := ''

if TAFAlsInDic("V3U")   
    //-----------------------------------------------
    // Inicialização variáveis do tipo caracter
    //-----------------------------------------------
    cAlias      :=  getnextalias()
    cRet    := ''

        if len(cIdPart) < 36 .and. !empty(cIdPart)
            cIdPart := POSICIONE("C1H",1,XFILIAL("C1H")+cIdPart,"C1H_ID") 
        endif

        beginsql alias cAlias
            SELECT LEM.LEM_ID AS ID, T51.T51_NUMPAR AS NUMPAR 
            FROM %TABLE:LEM% LEM
            INNER JOIN %TABLE:T51% T51
            ON  T51.D_E_L_E_T_    <> %Exp:'*'% 
            AND T51.T51_FILIAL   =  %xFilial:T51%
            AND T51.T51_ID       =  LEM.LEM_ID
            WHERE LEM.D_E_L_E_T_        <> %Exp:'*'% 
                AND LEM.LEM_FILIAL    = %xFilial:LEM%
                AND LEM.LEM_NUMERO    = %Exp:cNumero%
                AND LEM.LEM_PREFIX    = %Exp:cSerie%
                AND LEM.LEM_IDPART    = %Exp:cIdPart% 
                AND LEM.LEM_DTEMIS    = %Exp:dDtEmiss%
                AND LEM.LEM_NATTIT    = %Exp:cNatTit% 
                AND T51.T51_NUMPAR    = %Exp:cParcel%
        endsql 

        (cAlias)->(DbGoTop())
        if (cAlias)->(!EOF())
            cRet := (cAlias)->ID
            cRet += (cAlias)->NUMPAR 
        endif
endif
return(cRet)
*/
//-------------------------------------------------------------------
/*{Protheus.doc} TAF535Cbox
Função de combo box para o campo V4I_TPDEDU, necessário pois as opções ultrapassam o tamanho máx. 

@author Denis Souza
@since 17/07/2019
@version 1.0
*/
/*
Function TAF535Cbox()

Local cString	:=	""

cString := "1=" + STR0024 //"Previdência Oficial;"
cString += "2=" + STR0025 //"Previdência Privada;"
cString += "3=" + STR0026 //"Fapi;"
cString += "4=" + STR0027 //"Funpresp;" 
cString += "5=" + STR0028 //"Pensão Alimentícia;"
cString += "6=" + STR0029 //"Contribuição do ente público patrocinador;"
cString += "7=" + STR0030 //"Dependentes;"

Return( cString )
*/

//-------------------------------------------------------------------
/*{Protheus.doc} VldLineV4I
Função que realiza a validação dos campos da tabela V4I

@author Denis Souza / Wesley Pinheiro
@since 07/11/2019
@version 1.0
*/
/*
Static Function VldLineV4I( )

    Local lOk := .T.

    If FwFldGet("V4I_TPDEDU") $ '234' .And. Empty( FwFldGet("V4I_NUMPRE") )
		Help("",1,"Help","Help",STR0031, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0033}) //"O N° de Inscrição da Previdência se torna obrigatório quando o Tipo Dedução é igual 2, 3 ou 4."#"Informe um conteúdo válido."
		lOk := .F.
	EndIf

Return lOk
*/
//-------------------------------------------------------------------
/*{Protheus.doc} VldLineV4J
Função que realiza a validação dos campos da tabela V4J

@author Denis Souza / Wesley Pinheiro
@since 07/11/2019
@version 1.0
*/
/*
Static Function VldLineV4J( )

    Local lOk := .T.

    If FwFldGet("V4J_CDTPIS") $ '99' .And. Empty( FwFldGet("V4J_DRENDI") )
		Help("",1,"Help","Help",STR0032, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0033}) //"A descrição da isenção se torna obrigatória quando o Tipo da Isenção é igual 99=Outros"#"Informe um conteúdo válido."
		lOk := .F.
	EndIf

Return lOk
*/
//-------------------------------------------------------------------
 /*{Protheus.doc} VldLineV3V
Valida linha V3V - Natureza
@author Wesley Pinheiro 
@since 17/10/2019
@version 1.0
*/
/*
Static Function VldLineV3V( oModelV3V )

    Local cIdProc := oModelV3V:GetValue( "V3V_IDPROC" )
    Local cIndRRA := ""
	Local cTpProc := ""
	Local cNrProc := ""
    Local lRet    := .T.

    cIndRRA := oModelV3V:GetValue( "V3V_INDRRA" )
    cTpProc := oModelV3V:GetValue( "V3V_TPCRRA" )
    cNrProc := oModelV3V:GetValue( "V3V_NRPROC" )

    If !Empty( cIndRRA ) .Or. !Empty( cTpProc ) .Or. !Empty( cNrProc ) 
        DBSelectArea( "V4F" )
        V4F->( DbSetOrder( 2 ) ) // V4F_FILIAL + V4F_INDRRA + V4F_TPPROC + V4F_NRPROC

        If V4F->( DbSeek( xFilial( "V4F" ) + Alltrim( cIndRRA ) + Alltrim( cTpProc ) + cNrProc ) )
            oModelV3V:LoadValue( "V3V_IDPROC", V4F->V4F_ID )
        Else
            lRet := .F.
            oModelV3V:GetModel():SetErrorMessage( ,,,, STR0034, STR0037, STR0038 ) // #"ATENÇÃO!", #"A Despesa Processsual informada não existe." , #"Verifique se os campos: Num.processo, Indicat.RRA e Tp.Proc. RRA forma preenchidos corretamente."
        EndIf
    EndIf

Return lRet
*/
//-------------------------------------------------------------------
 /*{Protheus.doc} VldNat
Função que verifica se a natureza de rendimento não é tributável
@author Wesley Pinheiro 
@since 17/10/2019
@version 1.0
*/
/*
Static Function VldNat( oModel )

    Local oModelV46
    Local cNatRen   := oModel:GetModel( "MODEL_V3V" ):GetValue( "V3V_CNATRE" )
    Local nI        := 0
    Local nLinhas   := 0
    Local lRet      := .T.
    Local lEmptyV46 := .F.
    Local lNotTrib  := .F.
    Local cCodNat   := ""

    If !Empty( cNatRen )

        lNotTrib := Empty( GetAdvFVal( "V3O", "V3O_TRIB", xFilial( "V3O" ) + cNatRen, 2 ) ) // V3O_FILIAL + V3O_ID

        If lNotTrib
            oModelV46 := oModel:GetModel( "MODEL_V46" )
            nLinhas   := oModelV46:Length( )

            for nI := 1 to nLinhas // É feito a verificação da grid V46 ( Tributos ) porque o usuário pode alterar a grid V3V ( Naturezas ) para uma natureza não tributável

                oModelV46:GoLine( nI )
                
                If oModelV46:IsDeleted( )
                    Loop
                EndIf

                if  (; 
                    Empty( FwFldGet( "V46_DESTRI", nI ) ).and. Empty( FwFldGet( "V46_IDTRIB", nI ) ) .and.;
                    Empty( FwFldGet( "V46_BASE"  , nI ) ).and. Empty( FwFldGet( "V46_VALOR" , nI ) ) .and.;
                    Empty( FwFldGet( "V46_ALIQ"  , nI ) );
                    )
                        lEmptyV46 := .T.
                EndIf

                If !lEmptyV46
                    cCodNat := GetAdvFVal( "V3O", "V3O_CODIGO", xFilial( "V3O" ) + cNatRen, 2 )
                    oModel:SetErrorMessage( ,,,, STR0034, STR0035 + " " + cCodNat, STR0039 + " " + cCodNat ) // #"ATENÇÃO", #"A Natureza de Rendimento selecionada não possui tributação. Cod: ", #"Não preencha a aba tributos para a Natureza de Rendimento"
                    lRet := .F.
                    exit
                endif

            Next nI

        EndIf

    EndIf

Return lRet
*/
//-------------------------------------------------------------------
 /*{Protheus.doc} VldV46Pre 
Função que verifica se a natureza de rendimento não é tributável
@author Wesley Pinheiro
@since 17/10/2019
@version 1.0
*/
/*
Static Function VldV46Pre( oModelGrid, cAction, cField, xValNew, xValOld )

    Local oModel	:= FWModelActive( )
    Local cNatRen   := oModel:GetModel( "MODEL_V3V" ):GetValue( "V3V_CNATRE" )
    Local lRet      := .T.
    Local lEmptyV46 := .F.
    Local lNotTrib  := .F.
    Local cCodNat   := ""


    If ( cAction == "CANSETVALUE" ) .and. !Empty( cNatRen )

        lNotTrib := Empty( GetAdvFVal( "V3O", "V3O_TRIB", xFilial( "V3O" ) + cNatRen, 2 ) ) // V3O_FILIAL + V3O_ID

        If lNotTrib
            
            cCodNat := GetAdvFVal( "V3O", "V3O_CODIGO", xFilial( "V3O" ) + cNatRen, 2 )

            if isBlind( )
                 oModel:SetErrorMessage( ,,,, STR0034, STR0035 + " " + cCodNat, STR0039 + " " + cCodNat ) //"ATENÇÃO!"  #"A Natureza de Rendimento selecionada não possui tributação. Cod: "
            Else
                MsgAlert(  STR0035 + " " + cCodNat, STR0034 ) //#"A Natureza de Rendimento selecionada não possui tributação. Cod: " #"ATENÇÃO!"                 
            EndIf
            
            lRet := .F.

        EndIf
    
    EndIf

Return lRet
*/
//-------------------------------------------------------------------
/*{Protheus.doc} ValidModel

Função utilizada para validar a gravação do Model.
Validação: Evitar gravar fatura/recibo com os mesmos valores da chave mais forte da tabela V3U
indice 2 -> V3U_FILIAL + V3U_NUMERO + V3U_SERIE + V3U_IDPART + V3U_DTEMIS + V3U_NATTIT + V3U_PARCEL + V3U_DTPAGT + V3U_SEQUEN

@return lRet .T. = Gravação será realizada ( Não existe chave ) / .F. = Gravação não será realizada ( existe chave )

@author Wesley Pinheiro
@since 29/10/2019
@version 1.0
*/
//-------------------------------------------------------------------
/*
Static Function ValidModel( oModel )
	Local cNum  		as Character
	Local cSerie     	as Character
	Local cIdPartic		as Character
	Local cDtEmiss 		as Character
    Local cNatTit  		as Character
    Local cParcela      as Character
    Local cDtPgto       as Character
    Local cSequen       as Character
    Local cKeyV3U       as Character

	Local oModelV3U 	as Object

	Local lRet			as Logical

	Local aAreaV3U		as Array

	oModelV3U  := oModel:GetModel( "MODEL_V3U" )
	aAreaV3U   := V3U->( GetArea( ) )
	lRet       := .T.
    cNum       := ""
    cSerie     := ""
    cIdPartic  := ""
    dDtEmiss   := Ctod( "//" )
    cNatTit    := ""
    cParcela   := ""
    dDtPgto    := Ctod( "//" )
    cSequen    := ""
	
	If oModel:GetOperation( ) == MODEL_OPERATION_INSERT

		V3U->( DbSetOrder( 2 ) ) //  V3U_FILIAL + V3U_NUMERO + V3U_SERIE + V3U_IDPART + V3U_DTEMIS + V3U_NATTIT + V3U_PARCEL + V3U_DTPAGT + V3U_SEQUEN

        cNum      := oModelV3U:GetValue( "V3U_NUMERO" )
        cSerie    := oModelV3U:GetValue( "V3U_SERIE"  )
        cIdPartic := oModelV3U:GetValue( "V3U_IDPART" )
        cDtEmiss  := Dtos( oModelV3U:GetValue( "V3U_DTEMIS" ) )
        cNatTit   := oModelV3U:GetValue( "V3U_NATTIT" )
        cParcela  := oModelV3U:GetValue( "V3U_PARCEL" )
        cDtPgto   := Dtos( oModelV3U:GetValue( "V3U_DTPAGT" ) )
        cSequen   := oModelV3U:GetValue( "V3U_SEQUEN" )
		
        If V3U->( DbSeek( xFilial( "V3U" ) + cNum + cSerie + cIdPartic + cDtEmiss + cNatTit + cParcela + cDtPgto + cSequen ) )
            lRet := .F.
            Help( ,1, "HELP",, STR0040, 1, 0,,,,,,{ STR0041 } ) // #"Já existe um Pagamento com as informações de: Série, Cod.Partic., Dt. Emissão, Natureza, Num. Parcela, Dt Pagto e Sequencial." #"Altere o conteúdo dos campos informados acima!"
        EndIf
    
	EndIf

	RestArea( aAreaV3U )

Return lRet
*/
//-------------------------------------------------------------------
/*{Protheus.doc} SX7CabV3U

Gatilha as informações do cabeçalho da rotina de pagamento de fatura/recibo, desde que exista fatura ( tabela LEM )

@param  cNumFat - Número da fatura
@return cSerie  - Número de séria fatura/recibo

@author Wesley Pinheiro
@since 05/11/2019
@version 1.0
*/
//-------------------------------------------------------------------
/*
Function SX7CabV3U( cNumFat )

    Local aAreaLEM  := LEM->( GetArea( "LEM" ) )
    Local aAreaC1H  := C1H->( GetArea( "C1H" ) )
    Local oModel    := FWModelActive( )
    Local oModelV3U := oModel:GetModel( "MODEL_V3U" )
    Local cSerie    := ""

    LEM->( DbSetOrder( 4 ) ) // LEM_FILIAL + LEM_NUMERO

    If LEM->( DbSeek( xFilial( "C1H" ) + cNumFat ) )

        cSerie := LEM->LEM_PREFIX
        oModelV3U:LoadValue( "V3U_DTEMIS" , LEM->LEM_DTEMIS )
        oModelV3U:LoadValue( "V3U_NATTIT" , LEM->LEM_NATTIT )

        C1H->( DbSetOrder( 5 ) ) // C1H_FILIAL + C1H_ID
        C1H->( DbSeek( xFilial( "C1H" ) + LEM->LEM_IDPART ) )
        oModelV3U:LoadValue( "V3U_CODPAR", C1H->C1H_CODPAR )
        oModelV3U:LoadValue( "V3U_IDPART", C1H->C1H_ID     )
        oModelV3U:LoadValue( "V3U_DESPAR", C1H->C1H_NOME   )

    Else

        oModelV3U:LoadValue( "V3U_DTEMIS" , Ctod( "" ) )
        oModelV3U:LoadValue( "V3U_NATTIT" , "" )
        oModelV3U:LoadValue( "V3U_CODPAR" , "" )
        oModelV3U:LoadValue( "V3U_IDPART" , "" )
        oModelV3U:LoadValue( "V3U_DESPAR" , "" )

    EndIf

    RestArea( aAreaC1H )
    RestArea( aAreaLEM )

Return cSerie
*/