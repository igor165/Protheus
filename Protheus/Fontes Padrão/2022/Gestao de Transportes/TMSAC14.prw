#INCLUDE "TMSAC14.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static _oFreteBr    := Nil
Static _nOptions    := 1

/*/-----------------------------------------------------------
{Protheus.doc} ³TMSAC14()
Manuntenção Frete - FreteBras  

@author Felipe M. Barbiere 
@since 09/06/2020
@version 1.0
-----------------------------------------------------------/*/
Function TMSAC14()
Local oBrowse   := Nil 
	
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DM2')
oBrowse:SetDescription(STR0012) // Manuntenção Frete - FreteBras
oBrowse:AddLegend( "DM2->DM2_STATUS = '1' "	, "BR_AMARELO"	, STR0016  )    //-- Em Aberto	
oBrowse:AddLegend( "DM2->DM2_STATUS = '2' "	, "BR_VERDE"    , STR0017   )	//-- Concretizado
oBrowse:Activate()                                     

Return Nil

/*/-----------------------------------------------------------
{Protheus.doc} ³ModelDef()
Define o modelo de dados em MVC.

@author Felipe M. Barbiere 
@since 09/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function ModelDef()
Local oModel	:= Nil		// Objeto do Model
Local oStruDM2	:= Nil		// Recebe a Estrutura da tabela DLU
Local bCommit 	:= { |oModel| CommitMdl(oModel) }
Local bPosValid := { |oModel| PosVldMdl(oModel)}

oStruDM2:= FWFormStruct( 1, "DM2" )

oModel := MPFormModel():New( "TMSAC14",,bPosValid, bCommit , /*bCancel*/ ) 
oModel:AddFields( 'MdFieldDM2',, oStruDM2,,,/*Carga*/ ) 
oModel:GetModel( 'MdFieldDM2' ):SetDescription( STR0012 )  //	Manuntenção Frete - FreteBras
oModel:SetPrimaryKey({"DM2_FILIAL" , "DM2_FILORI", "DM2_VIAGEM"})       
oModel:SetActivate( )
     
Return oModel 

/*/-----------------------------------------------------------
{Protheus.doc} ³ViewDef()
Define a interface para cadastro

@author Felipe M. Barbiere 
@since 09/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function ViewDef()     
Local oModel	:= Nil		// Objeto do Model 
Local oStruDM2	:= Nil		// Recebe a Estrutura da tabela DM2
Local oView					// Recebe o objeto da View

oModel   := FwLoadModel("TMSAC14")
oStruDM2 := FWFormStruct( 2, "DM2" )

oView := FwFormView():New()
oView:SetModel(oModel)
oView:AddField('VwFieldDM2', oStruDM2 , 'MdFieldDM2')   
oView:CreateHorizontalBox('CABECALHO', 100)  
oView:SetOwnerView('VwFieldDM2','CABECALHO')

Return oView

/*/-----------------------------------------------------------
{Protheus.doc} MenuDef()
retorna a array com lista de aRotina  

@author Felipe M. Barbiere 
@since 09/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function MenuDef() 

Local aRotina := {}

ADD OPTION aRotina  TITLE STR0008  ACTION 'PesqBrw' 		OPERATION 1  ACCESS 0  //"Pesquisar"
ADD OPTION aRotina  TITLE STR0009  ACTION 'VIEWDEF.TMSAC14' OPERATION 2  ACCESS 0  //"Visualizar"
ADD OPTION aRotina  TITLE STR0010  ACTION 'TMSC14Mnt()'     OPERATION 3  ACCESS 0  //"Criar Frete"
ADD OPTION aRotina  TITLE STR0011  ACTION 'TMSC14Mnt(,,4)'  OPERATION 4  ACCESS 0  //"Alterar Frete"
ADD OPTION aRotina  TITLE STR0013  ACTION 'TMSC14Mnt(,,5)'  OPERATION 4  ACCESS 0  //"Concretizar Frete"
ADD OPTION aRotina  TITLE STR0015  ACTION 'VIEWDEF.TMSAC14' OPERATION 5  ACCESS 0  //"Excluir Frete"
ADD OPTION aRotina  TITLE STR0014  ACTION 'TMSC14Mnt(,,6)'  OPERATION 7  ACCESS 0  //"Renovar Frete"

Return(aRotina)

/*/-----------------------------------------------------------
{Protheus.doc} TMSC14Mnt()
Manutenção

@author Caio Murakami   
@since 17/06/2020
@version 1.0
-----------------------------------------------------------/*/
Function TMSC14Mnt( cFilOri , cViagem , nOpc )
Local lContinua     := .T. 
Local cIdFrt        := ""

Default cFilOri     := ""
Default cViagem     := "" 
Default nOpc        := 3 

If nOpc == 3
    _nOptions   := 1 
    lContinua   := .T. 

    FWExecView( STR0012 ,'TMSAC14',MODEL_OPERATION_INSERT,, { || .T. },{ || .T. },,,{ || .T. })
ElseIf nOpc == 4 .Or. nOpc == 5

    If !Empty(cFilOri) .And. !Empty(cViagem)
        DM2->(dbSetOrder(1))
        If DM2->( MsSeek( xFilial("DM2") + cFilOri + cViagem ))
            lContinua   := .T. 
        Else
            lContinua   := .F. 
        EndIf
    EndIf

    If nOpc == 4 
        _nOptions   := 2    //-- Altera Frete
    ElseIf nOpc == 5 
        _nOptions   := 3    //-- Concretiza Frete
    EndIf

    If lContinua .And. DM2->DM2_STATUS == '1' //-- Em Aberto
        FWExecView( STR0012 ,'TMSAC14',MODEL_OPERATION_UPDATE,, { || .T. },{ || .T. },,,{ || .T. })
    EndIf
ElseIf nOpc == 6 //-- Renovação
    If !Empty(cFilOri) .And. !Empty(cViagem)
        DM2->(dbSetOrder(1))
        If DM2->( MsSeek( xFilial("DM2") + cFilOri + cViagem )) .And. !Empty(DM2->DM2_IDFRT) .And. DM2->DM2_STATUS == '1' //-- Em Aberto
            cIdFrt      := DM2->DM2_IDFRT
            lContinua   := .T. 
        Else
            lContinua   := .F. 
        EndIf
    Else
        If DM2->DM2_STATUS == '1' .And. !Empty(DM2->DM2_IDFRT)
            cIdFrt      := DM2->DM2_IDFRT
            cFilOri     := DM2->DM2_FILORI
            cViagem     := DM2->DM2_VIAGEM
            lContinua   := .T. 
        Else
            lContinua   := .F. 
        EndIf
        
    EndIf

    If lContinua
        FWMsgRun(, {|oSay| lContinua := RenovaFrt( RTrim(cIdFrt) ) }, STR0019 , STR0014) //-- "Processando" e "Renovar Frete"

        If lContinua
             DM2->(dbSetOrder(1))
            If DM2->( MsSeek( xFilial("DM2") + cFilOri + cViagem )) 
                RecLock("DM2",.F.)
                DM2->DM2_DTFRT  := dDataBase
                DM2->( MsUnlock() )
            EndIf
        EndIf

    EndIf

EndIf

Return lContinua

/*/-----------------------------------------------------------
{Protheus.doc} PosVldMdl()
Pós validação do modelo

@author Caio Murakami   
@since 23/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function PosVldMdl( oModel )
Local lRet      := .T. 
Local cStatus   := FwFldGet("DM2_STATUS")
Local nOpc      := 3 

Default oModel  := FWModelActive()

nOpc    := oModel:GetOperation()   

If nOpc == MODEL_OPERATION_DELETE .And.  cStatus == "2"
    lRet    := .F. 
    Help('',1,'TMSAC140000001') //-- As ofertas de frete que possuem o status 2=Concretizadas não podem ser excluídas do sistema.  
EndIf

Return lRet 

/*/-----------------------------------------------------------
{Protheus.doc} CommitMdl()
Commit do modelo de dados

@author Caio Murakami   
@since 11/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function CommitMdl(oModel)
Local lRet      := .T. 
Local nOpc      := 3 
Local cIdFrt    := FwFldGet("DM2_IDFRT")
Local aRet      := {}
Local cRet      := ""

Default oModel  := FWModelActive()

nOpc    := oModel:GetOperation()

If  ( nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE ) .And. ( _nOptions == 1 .Or. _nOptions == 2 )
    aRet    := EnviaFrete(nOpc , cIdFrt )
    
    lRet    := aRet[1]
    cRet    := aRet[2]

ElseIf nOpc == MODEL_OPERATION_UPDATE .And. _nOptions == 3
    aRet    := FechaFrt( cIdFrt ,;
                        Posicione("DA3",1,xFilial("DA3") + FwFldGet("DM2_VEIC") , "DA3_PLACA")  ,;
                        Posicione("DA4",1,xFilial("DA4") + FwFldGet("DM2_CODMOT") , "DA4_CGC")  )

    lRet    := aRet[1]
    cRet    := aRet[2]

ElseIf nOpc == MODEL_OPERATION_DELETE
    aRet    := DeletaFrt( cIdFrt )

    lRet    := aRet[1]
    cRet    := aRet[2]
EndIf

If lRet
    lRet    := FwFormCommit(oModel)
Else
    If !Empty(cRet)
        oModel:GetModel():SetErrorMessage(oModel:GetModel():GetId(),,oModel:GetModel():GetId(),,STR0012,cRet,) //-- FreteBras
    EndIf
EndIf

Return lRet 

/*/-----------------------------------------------------------
{Protheus.doc} TMSFrtBrF3()
F3 - para TMS X FreteBras

@author Caio Murakami   
@since 09/06/2020
@version 1.0
-----------------------------------------------------------/*/
Function TMSFrtBrF3(cCampo , lErro )
Local aArea     := GetArea()
Local nTmsItem  := 0 
Local lRet      := .F. 
Local aRet      := {}
Local aHeader   := {} 
Local aAux      := {}
Local nCount    := 1 
Local cRet      := ""
Local cDescri   := ""

Default cCampo  := ReadVar()
Default lErro   := .F. 

If TMSAFretBr()
    If VAR_IXB == NIL
        VAR_IXB := ""
    EndIf

    If _oFreteBr == Nil 
        _oFreteBr  := TMSBCAFreteBras():New()
        _oFreteBr:GetAccessToken() 
        _oFreteBr:SetMostraErro(lErro)
    EndIf

    If  "TIPVEI" $ cCampo
        aHeader := { STR0002 , STR0003 ,STR0004 }   //-- id,nome,categoria
        aRet    := _oFreteBr:GetTipoVeiculo()
    ElseIf "TIPCAR" $ cCampo
        aHeader := { STR0002 , STR0003 ,STR0004 }   //-- id,nome,categoria
        aRet  := _oFreteBr:GetCarroceriaVeiculo()
    ElseIf "TIPESP" $ cCampo
        aHeader := { STR0002 , STR0003 }   //-- id,nome
        aRet  := _oFreteBr:GetEspecie()
    ElseIf "TIPPRE" $ cCampo
        aHeader := { STR0002 , STR0003 }   //-- id,nome
        aRet  := _oFreteBr:GetPreco()
    EndIf

    If  "TIPESP" $ cCampo .Or.  "TIPPRE" $ cCampo 

        nTmsItem := TmsF3Array( aHeader , aRet, STR0001 ) //"Codigo"###"Descricao"

        If	nTmsItem > 0   
            VAR_IXB    := cValToChar( aRet[ nTmsItem, 1 ] )
            lRet    := .T. 
        EndIf

    ElseIf "TIPVEI" $ cCampo .Or. "TIPCAR" $ cCampo

        For nCount := 1 To Len(aRet)
            Aadd( aAux , {} )

            Aadd( aAux[Len(aAux)] ,  .F. ) 
            Aadd( aAux[Len(aAux)] ,  aRet[nCount][1] ) 
            Aadd( aAux[Len(aAux)] ,  aRet[nCount][2] ) 
            Aadd( aAux[Len(aAux)] ,  aRet[nCount][3] ) 

        Next nCount

        TMSABrowse(aAux,STR0001,,.F.,.T.,.F. ,aHeader,,)

        For nCount := 1 To Len(aAux)
            If aAux[nCount,1]
                lRet        := .T. 

                If !Empty(cRet) 
                    cRet    += ";"
                EndIf

                If !Empty(cDescri)
                    cDescri += ";"
                EndIf
                cRet    += cValToChar( aAux[nCount,2] )
                cDescri += aAux[nCount,3]

            EndIf            
        Next nCount

        VAR_IXB := cRet

    EndIf

    If nModulo == 43
        SetCampos( cCampo , aRet ,  nTmsItem , cDescri )
    EndIf

EndIf

FwFreeArray(aRet)
FwFreeArray(aHeader)

RestArea( aArea )
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} SetCampos()
Seta campos do modelo

@author Caio Murakami   
@since 10/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function SetCampos( cCampo, aInfos , nOpc , cDescri )
Local oModel        := FWModelActive()
Local oMdlField     := oModel:GetModel("MdFieldDM2")
Local cConteudo     := ""

Default cCampo      := ReadVar()
Default aInfos      := {}
Default nOpc        := 0 
Default cDescri     := ""

If  Empty(cDescri) .And. nOpc > 0 
    cConteudo   := AllTrim(aInfos[nOpc,2])
ElseIf !Empty(cDescri)
    cConteudo   := AllTrim(cDescri)
EndIf

If  "TIPVEI" $ cCampo
    oMdlField:LoadValue("DM2_NOMVEI" , cConteudo )        
ElseIf "TIPCAR" $ cCampo
    oMdlField:LoadValue("DM2_CARROC" , cConteudo )   
ElseIf "TIPESP" $ cCampo
    oMdlField:LoadValue("DM2_ESPEC" , cConteudo )   
ElseIf "TIPPRE" $ cCampo
    oMdlField:LoadValue("DM2_PRECOS" , cConteudo ) 
EndIf

Return 

/*/-----------------------------------------------------------
{Protheus.doc} EnviaFrete()
Envia frete

@author Caio Murakami   
@since 10/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function EnviaFrete( nOpc , cFreteId )
Local aArea     := GetArea()
Local lRet      := .F. 
Local cRet      := ""
Local cUfOri    := ""
Local cMunOri   := ""
Local cUfDes    := ""
Local cMunDes   := ""
Local oModel    := FWModelActive()
Local lComple   := .F. 
Local oMdlField := Nil 
Local aTipVei   := {}
Local aTipCar   := {}
Local nAux      := 0 

Default nOpc        :=  3 
Default cFreteId    := ""

If TMSAFretBr()
    
    If _oFreteBr == Nil 
        _oFreteBr  := TMSBCAFreteBras():New()
        _oFreteBr:GetAccessToken() //objeto:nomedométodo() 
        _oFreteBr:SetMostraErro(.F.)
    EndIf

    //-- Converte UF e Municipio para código do IBGE
    cUfOri  := TMS120CdUf( FwFldGet("DM2_UFORIG") , "1" )
    cMunOri := cUfOri + FwFldGet("DM2_MUNORI") 
    cUfDes  := TMS120CdUf( FwFldGet("DM2_UFDEST") , "1" )
    cMunDes := cUfDes + FwFldGet("DM2_MUNDES")
    aTipVei := StrToKarr( FwFldGet("DM2_TIPVEI") , ";" )
    aTipCar := StrToKarr( FwFldGet("DM2_TIPCAR") , ";" )
    
    For nAux := 1 To Len(aTipVei)
        aTipVei[nAux]   := Val( aTipVei[nAux] )
    Next nAux 

     For nAux := 1 To Len(aTipCar)
        aTipCar[nAux]   := Val( aTipCar[nAux] )
    Next nAux 

    If FwFldGet("DM2_VOLUME") > 0 .Or.  FwFldGet("DM2_PESO") > 0 .Or. FwFldGet("DM2_DIMENS") > 0 
        lComple := .T. 
    EndIf

    _oFreteBr:SetOrigemDestino( cUfOri , cMunOri , cUfDes , cMunDes )
    _oFreteBr:SetCarga( RTrim(FwFldGet("DM2_PROD")) , lComple , Val(FwFldGet("DM2_TIPESP")) )
    _oFreteBr:SetVolume( FwFldGet("DM2_VOLUME") , FwFldGet("DM2_PESO") , FwFldGet("DM2_DIMENS") )
    _oFreteBr:SetPreco( Val(FwFldGet("DM2_TIPPRE")) , FwFldGet("DM2_FRETE") )
    _oFreteBr:SetInfoAdic( Iif(FwFldGet("DM2_PEDPAG")=="1",.T.,.F.) ,  AllTrim( FwFldGet("DM2_INFOAD") ) , Iif( FwFldGet("DM2_RASTRE") == "1",.T.,.F.)  )
    _oFreteBr:SetVeiculos( aClone(aTipVei) , aClone(aTipCar) )

    If nOpc == 3 
        lRet    := _oFreteBr:CriaFrete() 
    ElseIf nOpc == 4 
        lRet    := _oFreteBr:AlteraFrete( cFreteId ) 
    EndIf

    If lRet
        cRet := _oFreteBr:GetFreteId()
        oMdlField   := oModel:GetModel("MdFieldDM2")
        oMdlField:LoadValue("DM2_IDFRT", cRet )
        oMdlField:LoadValue("DM2_DTFRT", dDataBase )
        oMdlField:LoadValue("DM2_STATUS" ,"1" ) //-- Em Aberto
    Else
        cRet  := AllTrim( _oFreteBr:GetError() )    
    EndIf

    FwFreeArray( aTipVei )
    FwFreeArray( aTipCar )

EndIf

RestArea( aArea )
Return { lRet , cRet } 

/*/-----------------------------------------------------------
{Protheus.doc} FechaFrt()
Fecha frete

@author Caio Murakami   
@since 16/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function FechaFrt( cIdFrt , cPlaca, cCPF )
Local aArea     := GetArea()
Local lRet      := .F. 
Local oModel    := FWModelActive()
Local oMdlField := Nil 
Local cRet      := ""

Default cIdFrt  := ""
Default cPlaca  := ""
Default cCPF    := ""

If TMSAFretBr()    
    If _oFreteBr == Nil 
        _oFreteBr  := TMSBCAFreteBras():New()
        _oFreteBr:GetAccessToken() 
        _oFreteBr:SetMostraErro(.F.)
    EndIf    
    _oFreteBr:SetPlacaCPF( RTrim(cPlaca) , RTrim(cCPF) )
    If _oFreteBr:FechaFrete( RTrim(cIdFrt) )
        lRet    := .T. 
    EndIf
    
    If lRet
        oMdlField   := oModel:GetModel("MdFieldDM2")
        oMdlField:LoadValue("DM2_DTFRT", dDataBase )
        oMdlField:LoadValue("DM2_STATUS" ,"2" ) //-- Concretizado
    Else
        cRet  := AllTrim( _oFreteBr:GetError() )
    EndIf
EndIf

RestArea(aArea)
Return { lRet , cRet }

/*/-----------------------------------------------------------
{Protheus.doc} RenovaFrt()
Renova frete

@author Caio Murakami   
@since 16/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function RenovaFrt( cIdFrt )
Local aArea     := GetArea()
Local lRet      := .F. 
Local cError    := ""

Default cIdFrt  := ""

If TMSAFretBr()    
    If _oFreteBr == Nil 
        _oFreteBr  := TMSBCAFreteBras():New()
        _oFreteBr:GetAccessToken() 
        _oFreteBr:SetMostraErro(.F.)
    EndIf
    
    If _oFreteBr:RenovaFrete( cIdFrt )
        lRet    := .T. 
    Else
        cError  := AllTrim( _oFreteBr:GetError() )
        Help( ,, 'HELP',, cError , 1, 0 )
    EndIf
EndIf

RestArea(aArea)
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} DeletaFrt()
Deleta frete

@author Caio Murakami   
@since 18/06/2020
@version 1.0
-----------------------------------------------------------/*/
Static Function DeletaFrt( cIdFrt )
Local lRet      := .F. 
Local aArea     := GetArea()
Local cRet      := ""

Default cIdFrt  := ""

If TMSAFretBr()    
    If _oFreteBr == Nil 
        _oFreteBr  := TMSBCAFreteBras():New()
        _oFreteBr:GetAccessToken() 
        _oFreteBr:SetMostraErro(.F.)
    EndIf
    
    If _oFreteBr:DeletaFrete( cIdFrt )
        lRet    := .T. 
    Else         
        cRet  := AllTrim( _oFreteBr:GetError() )
    EndIf
EndIf

RestArea( aArea )
Return { lRet , cRet } 

/*/-----------------------------------------------------------
{Protheus.doc} TMSC14When()
When dos campos

@author Caio Murakami   
@since 17/06/2020
@version 1.0
-----------------------------------------------------------/*/
Function TMSC14When()
Local lRet      := .F. 
Local cCampo    := ReadVar()
Local oModel    := FWModelActive()
Local nOpc      := oModel:GetOperation()

If 'DM2_FILORI' $ cCampo .Or. 'DM2_VIAGEM' $ cCampo 
    If nOpc == MODEL_OPERATION_INSERT 
        If IsInCallStack("A144FretBr")
            lRet    := .F. 
        Else
            lRet    := .T. 
        EndIf
    EndIf
ElseIf 'DM2_CODMOT' $ cCampo .Or. 'DM2_VEIC' $ cCampo  
    If nOpc == MODEL_OPERATION_UPDATE .And. _nOptions == 3 //-- Concretização Frete
        lRet    := .T. 
    EndIf
ElseIf 'DM2_IDFRT' $ cCampo .Or.  'DM2_DTFRT' $ cCampo  .Or. 'DM2_STATUS' $ cCampo 
    lRet    := .F. 
ElseIf 'DM2_MUNDES' $ cCampo .Or. 'DM2_MUNORI' $ cCampo .Or. 'DM2_UFDEST' $ cCampo .Or. 'DM2_UFORIG' $ cCampo 
    If nOpc == MODEL_OPERATION_INSERT  .Or. ( nOpc == MODEL_OPERATION_UPDATE .And. _nOptions == 2 )
        lRet    := .T. 
    EndIf
ElseIf 'DM2_PROD'  $ cCampo .Or. 'DM2_INFOAD' $ cCampo 
     If nOpc == MODEL_OPERATION_INSERT  .Or. ( nOpc == MODEL_OPERATION_UPDATE .And. _nOptions == 2 )
        lRet    := .T. 
    EndIf
ElseIf 'DM2_FRETE' $ cCampo .Or. 'DM2_PESO'  $ cCampo .Or. 'DM2_VOLUME' $ cCampo  .Or. 'DM2_DIMENS' $ cCampo
     If nOpc == MODEL_OPERATION_INSERT  .Or. ( nOpc == MODEL_OPERATION_UPDATE .And. _nOptions == 2 )
        lRet    := .T. 
    EndIf
ElseIf 'DM2_LOTAC' $ cCampo .Or. 'DM2_RASTRE' $ cCampo .Or. 'DM2_PEDPAG' $ cCampo 
     If nOpc == MODEL_OPERATION_INSERT  .Or. ( nOpc == MODEL_OPERATION_UPDATE .And. _nOptions == 2 )
        lRet    := .T. 
    EndIf
ElseIf 'DM2_TIPCAR' $ cCampo .Or. 'DM2_TIPESP' $ cCampo .Or. 'DM2_TIPPRE' $ cCampo .Or. 'DM2_TIPVEI' $ cCampo 
     If nOpc == MODEL_OPERATION_INSERT  .Or. ( nOpc == MODEL_OPERATION_UPDATE .And. _nOptions == 2 )
        lRet    := .T. 
    EndIf
EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSC14Init()
Inicializador padrão dos campos

@author Caio Murakami   
@since 24/06/2020
@version 1.0
-----------------------------------------------------------/*/
Function TMSC14Init()
Local xRet      := ""
Local cCampo    := ReadVar()
Local xRet          := "" 
Local oDadosViag    := Nil 
Local aDocs         := {} 
Local nCount        := 0 
Local cCampo        := ReadVar()
Local nQtdVol       := 0 
Local nPeso         := 0 
Local nPesoM3       := 0 
Local cUfOri        := ""
Local cMunOri       := ""
Local cUfDes        := ""
Local cMunDes       := ""
Local cCliDes       := ""
Local cLojDes       := ""
Local aSM0          := {} 

If IsInCallStack("A144FretBr")
    If "DM2_FILORI" $ cCampo
        xRet    :=  DTQ->DTQ_FILORI
    ElseIf "DM2_VIAGEM" $ cCampo
        xRet    :=  DTQ->DTQ_VIAGEM
    Else 

        oDadosViag	:= TMSBCADadosTMS():New(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,,.F.)
        oDadosViag:AddCustomerTrip(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM)			
        oDadosViag:AddDocs(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM)	
        aDocs 		:= oDadosViag:GetDocs()

        For nCount := 1 To Len(aDocs)

            nQtdVol += GetInfoArr(aDocs[nCount],"QTDVOL",3)
            nPeso   += GetInfoArr(aDocs[nCount],"PESO",3)
            nPesoM3 += GetInfoArr(aDocs[nCount],"PESOM3",3)

            cCliDes := GetInfoArr(aDocs[nCount],"CLIDES",3)
            cLojDes := GetInfoArr(aDocs[nCount],"LOJDES",3)

        Next nCount 
                
        If "DM2_UFORIG" $ cCampo        
            aSM0    := FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_ESTENT" } )  

            If Len(aSM0) > 0 
                xRet    := aSM0[1,2]
            EndIf 
        ElseIf "DM2_MUNORI" $ cCampo           
            aSM0    := FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CODMUN" } )

             If Len(aSM0) > 0 
                xRet    := SubStr( aSM0[1,2] , 3 ) 
            EndIf 
        ElseIf "DM2_UFDEST" $ cCampo
            xRet    := Posicione("SA1",1,xFilial("SA1") + cCliDes + cLojDes, "A1_EST")
        ElseIf "DM2_MUNDES" $ cCampo
            xRet    := Posicione("SA1",1,xFilial("SA1") + cCliDes + cLojDes, "A1_COD_MUN")
        ElseIf "DM2_VOLUME" $ cCampo
            xRet    := nQtdVol
        ElseIf "DM2_PESO" $ cCampo
            xRet    := nPeso
        ElseIf "DM2_DIMENS" $ cCampo
            xRet    := nPesoM3
        EndIf
    EndIf 
EndIf

Return xRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GetInfoArr()
Obtém dados do array

@author Caio Murakami
@since 25/08/2019
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function GetInfoArr( aAux  , cLabel , nPosSeek , nPosRet , nCount )
Local xRet      := nil 

Default aAux        := {}
Default cLabel      := ""
Default nPosSeek    := 1
Default nPosRet     := 2
Default nCount      := 1

For nCount := 1 To Len(aAux)
    If AllTrim( aAux[nCount][nPosSeek] ) == AllTrim( cLabel )
        xRet    := aAux[nCount][nPosRet]
        exit
    EndIf
Next nCount

Return xRet


