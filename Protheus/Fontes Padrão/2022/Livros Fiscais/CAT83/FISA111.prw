#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA111.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} FISA111
Cadastro MVC para cadastrar a Ficha 5G da Cat83 - Inventário de Produtos em Elaboração por Material Componente.

@author Graziele Mendonça Paro
@since 29/07/2015
@version P11

/*/
//-------------------------------------------------------------------
Function FISA111()

    Local   oBrowse := Nil

    IF  AliasIndic("CLV") 
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias("CLV")
        oBrowse:SetDescription(STR0001) //"Cadastro Ficha 5G - Cat83"
        oBrowse:Activate()
    Else
        Help("",1,"Help","Help",STR0002,1,0)  //"Tabela CLV não cadastrada no sistema!"
    EndIf
    
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Graziele Mendonça Paro
@since 29/07/2015
@version P11

/*/
//-------------------------------------------------------------------                                                                                            

Static Function MenuDef()

    Local aRotina := {}
    
    ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA111' OPERATION MODEL_OPERATION_VIEW ACCESS 0 //'Visualizar'
    ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA111' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //'Incluir'
    ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA111' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //'Alterar'
    ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA111' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //'Excluir'
    ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FISA111' OPERATION 9 ACCESS 0 //'Copiar'
        
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Graziele Mendonça Paro
@since 29/07/2015
@version P11

/*/
//-------------------------------------------------------------------

Static Function ModelDef()

    Local oModel    := Nil
    Local oStructCab := FWFormStruct(1, "CLV",{|cCampo| COMP11STRU(cCampo,"CAB")}) 
    Local oStructItm := FWFormStruct(1, "CLV",{|cCampo| COMP11STRU(cCampo,"ITE")})    
    
    oModel  :=  MPFormModel():New('FISA111MOD',/*bPre*/, /*bPos*/,/*bDcommit{|oModel| ValidDel(oModel)}*/, /*bCancel*/)

    oModel:AddFields('FISA111MOD' ,, oStructCab ) 
        
    oModel:AddGrid('FISA111INS', 'FISA111MOD', oStructItm, /*bLine*/,{|oStructItm| Valid(oStructItm)}/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
    
    oModel:SetRelation( "FISA111INS" , { { "CLV_FILIAL" , 'xFilial("CLV")' } ,{"CLV_PERIOD", "CLV_PERIOD"},  { "CLV_PROD" , "CLV_PROD" } }, CLV->( IndexKey( 1 ) ) )
        
    oModel:SetPrimaryKey({"CLV_FILIAL"},{"CLV_PERIOD"},{"CLV_PROD"},{"CLV_PRDINS"})
    
    //oModel:GetModel( 'FISA111INS' ):SetUniqueLine( { 'CLV_PRDINS' } )
    
   // oModel:GetModel( 'FISA111MOD' ):SetUniqueLine( { 'CLV_FILIAL','CLV_PERIOD','CLV_PROD' } )
    
    oModel:GetModel("FISA111INS"):SetUniqueLine({"CLV_PRDINS"})
    
    
Return oModel 


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Graziele Mendonça Paro
@since 29/07/2015
@version P11

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

    Local oModel     := FWLoadModel( "FISA111" ) 
    Local oStructCab := FWFormStruct(2, "CLV",{|cCampo| COMP11STRU(cCampo,"CAB")}) 
    Local oStructItm := FWFormStruct(2, "CLV",{|cCampo| COMP11STRU(cCampo,"ITE")})
    Local oView := Nil
    
    oView := FWFormView():New()
    oView:SetModel( oModel )

    oView:AddField( "VIEW" , oStructCab , 'FISA111MOD') 
    
    oView:AddGrid( "VIEW_INS", oStructItm, 'FISA111INS' )

    oView:CreateHorizontalBox( "TELA" , 30 )
    
    oView:CreateHorizontalBox( "INFERIOR", 70 )

    oView:SetOwnerView( "VIEW" , "TELA" )   
    
    oView:SetOwnerView( 'VIEW_INS', 'INFERIOR' )
    
    oView:EnableTitleView('VIEW_INS',STR0008)
    
    oView:AddUserButton('Facilitador','',{|| BuscaVal(oModel)},'Facilitador') //Busca valores Iniciais de ICMS e Custo da tabela CDU
    
    
Return oView


//-------------------------------------------------------------------

/*/{Protheus.doc} COMP11STRU
Campos que serão demonstrados em cada parte da tela

@author Graziele Mendonça Paro
@since 29/07/2015
@version P11

/*/
//-------------------------------------------------------------------
Static Function COMP11STRU(cCampo,cTipo)

    Local   lRet        := .T.
    Local   cCabec      :=  ""
    Local   cItem       :=  ""

    cCabec  := "CLV_FILIAL/CLV_PERIOD/CLV_PROD/"
    cItem   := "CLV_PRDINS/CLV_QUANT/CLV_VALCUS/CLV_VALICM/"

    If cTipo = "CAB"
        If !AllTrim( cCampo ) + "/" $ cCabec
            lRet := .F.
        EndIf
    Else
        If !AllTrim( cCampo ) + "/" $ cItem
            lRet := .F.
        EndIf
    EndIf

Return(lRet)



//-------------------------------------------------------------------

/*/{Protheus.doc} Valid
Validação das informações digitadas.

@author Graziele Mendonça Paro
@since 29/07/2015
@version P11

/*/
//-------------------------------------------------------------------
Static Function Valid(oModel)

    Local lRet          :=  .T.
    Local oStructCab    :=  oModel:GetModel( 'FISA111MOD' )  
    Local oStructItm    :=  oModel:GetModel( 'FISA111INS' )  
    Local cPeriod       :=  oStructCab:GetValue('FISA111MOD','CLV_PERIOD')
    Local cProdAc       :=  oStructCab:GetValue('FISA111MOD','CLV_PROD')
    Local cInsumo       :=  oStructItm:GetValue('FISA111INS','CLV_PRDINS')
    Local nOperation    :=  oModel:GetOperation()
    Local cRegisto      := ""
    
    dbSelectArea("CLV")
    cRegisto    := CLV->(RECNO())
    
    
    If  nOperation == 3 // Incluindo novo registro
        CLV->(DbSetOrder (1))
        If CLV->(DbSeek(xFilial("F06")+DTOS(cPeriod)+cProdAc+cInsumo))                                                                                                             
            //Help("",1,"Help","Help",STR0009 + cProdAc + "!"  ,1,0)
            Alert(STR0009 + cProdAc + "!") 
            lRet := .F.
        EndIF
    EndIF
    
    /*If nOperation == 4 // Alterando registro
        CLV->(DbSetOrder (1))
        If CLV->(DbSeek(xFilial("F06")+DTOS(cPeriod)+cProdAc+cInsumo)) 
            IF CLV->(RECNO()) <> cRegisto
                Help("",1,"Help","Help",STR0009 + cProdAc + "!"  ,1,0) 
                lRet := .F.
            EndIf
        EndIf
    EndIf*/


Return lRet

//-------------------------------------------------------------------

/*/{Protheus.doc} Valid
Validação das informações digitadas.

@author Graziele Mendonça Paro
@since 30/07/2015
@version P11

/*/
//-------------------------------------------------------------------
Static Function ValidDel(oModel)

    Local lRet          :=  .T.
    Local nOperation    :=  oModel:GetOperation()

    If nOperation == 5                                                                                                           
            IF MsgYesNo(STR0010) //"Serão excluidos todos os Insumos listados. Deseja Realmente excluir?
                FWFormCommit( oModel )
            ENDIF    
    EndIF
    
Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

Preenchimento automático do Custo e Inicial Inicial - Busca valor da tabela CDU,
que já deverá ter os valores preenchidos para o Insumo

@author Graziele Mendona Paro
@since 01/12/2015
/*/
//-------------------------------------------------------------------
Function BuscaVal(oModel )
    Local lRet          := .T.
    Local oStructCab    :=  oModel:GetModel( 'FISA111MOD' )
    Local oStructItm    :=  oModel:GetModel( 'FISA111INS' )
    Local cPerCLV       :=  DTOS(oStructCab:GetValue('CLV_PERIOD'))
    Local cPerCDU       :=  Substr(cPerCLV,1,6)
    lOCAL oView         :=  FWViewActive()
    Local cAliasCDU     := ''
    Local nCustUn       := 0
    Local nICMUn        := 0
    Local oView         :=  FWViewActive()
    Local cInsumo       := ""
    Local nQuant        := 0
    Local nI            := 0
    
    
    For nI := 1 To oStructItm:Length()
        oStructItm:GoLine( nI )
        cInsumo := oStructItm:GetValue('CLV_PRDINS')
        nQuant  := oStructItm:GetValue('CLV_QUANT')
        
        cAliasCDU   :=  GetNextAlias()
        
        BeginSql Alias cAliasCDU
            
            SELECT     CDU.CDU_FILIAL,
            CDU.CDU_PERIOD,
            CDU.CDU_FICHA,
            CDU.CDU_PRODUT,
            CDU.CDU_QTDINI,
            CDU.CDU_CUSINI,
            CDU.CDU_ICMINI
            FROM       %TABLE:CDU% CDU
            WHERE      CDU.CDU_FILIAL=%XFILIAL:CDU%
            AND        CDU.%NOTDEL%
            AND        CDU.CDU_PERIOD = %EXP:cPerCDU%
            AND        CDU.CDU_PRODUT = %EXP:cInsumo%
            ORDER BY   CDU.CDU_FILIAL,
            CDU.CDU_PERIOD,
            CDU.CDU_FICHA,
            CDU.CDU_PRODUT
            
        EndSql
        DbSelectArea (cAliasCDU)
        
        nCustUn := (cAliasCDU)->CDU_CUSINI / (cAliasCDU)->CDU_QTDINI
        nICMUn  := (cAliasCDU)->CDU_ICMINI/ (cAliasCDU)->CDU_QTDINI
        nCustUn := nCustUn*nQuant
        nICMUn  := nICMUn*nQuant
        
        oStructItm:Activate()
        oStructItm:SetValue( 'CLV_VALCUS', nCustUn)
        oStructItm:SetValue( 'CLV_VALICM', nICMUn)
        oStructItm:SetValue( 'CLV_QUANT', nQuant)
        oView:SetModifield(.T.)
    Next
Return lRet
