#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA150.ch"

Static lPosCIA	:= AliasIndic("CIA")
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA150()

Cadastro dos Anexos do Simples Nacional, com detalhamento das faixas,
alíquotas nominais, rateios dos tributos e rateio do ISS.

@author Erick G. Dias
@since 27/02/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA150()

Local   oBrowse := Nil

IF	AliasIndic("F10") .AND. AliasIndic("F11")

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F10")
    oBrowse:SetDescription(STR0001) // Cadastro de Anexos do Simples Nacional
    oBrowse:AddLegend( "Empty(F10_FIMVIG) .OR. F10_FIMVIG >= dDatabase" , "GREEN", STR0014 ) // Vigente
	oBrowse:AddLegend( "!Empty(F10_FIMVIG) .OR. F10_FIMVIG < dDatabase ", "RED",   STR0015 ) // Não vigente
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0005,1,0) // Dicionário desatualizado, verifique as atualizações da Apuração do Simples Nacional
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Erick G Dias
@since 27/02/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------

Static Function MenuDef()
Return FWMVCMenu( "FISA150" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Erick G Dias
@since 27/02/2017
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel	:= Nil

//Estrutura Pai corres,ndente a tabela de Anexo F10
Local oPai	    := FWFormStruct(1, "F10" )
//Estrutura Filho correspondente a tabela de faixas F11
Local oFilho	:= FWFormStruct(1, "F11" )
Local oFilhoCIA	

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA150',/*Pre-Validacao*/,{|oModel|VALIDACAO(oModel) })

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA150",,oPai)
//Adiciona o Grid ao modelo
oModel:AddGrid( 'FISA150FAIXA', 'FISA150', oFilho)
If lPosCIA
    oFilhoCIA  := FWFormStruct(1, "CIA" )
    oModel:AddGrid( 'FISA150IMPOSTO', 'FISA150FAIXA', oFilhoCIA)
EndIf
oModel:GetModel( 'FISA150FAIXA' ):SetUseOldGrid()

//Deixará desabilitado os campos abaixo
oPai:SetProperty('F10_DESCR'  , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
oPai:SetProperty('F10_ANEXO'  , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
oPai:SetProperty('F10_INIVIG' , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })
oFilho:SetProperty('F11_FAIXA'  , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })

//Define para não repetir o número da faixa
oModel:GetModel( 'FISA150FAIXA' ):SetUniqueLine( { 'F11_FAIXA' } )
oModel:SetPrimaryKey({})
oModel:SetRelation( 'FISA150FAIXA', { { 'F11_FILIAL', 'xFilial( "F11" )' }, { 'F11_IANEXO', 'F10->F10_ID' } }, F11->F11_FAIXA )

If lPosCIA
    oModel:GetModel( 'FISA150IMPOSTO' ):SetUniqueLine( { 'CIA_TIPO' } )
    oModel:SetRelation( 'FISA150IMPOSTO', { { 'CIA_FILIAL', 'xFilial( "CIA" )' }, { 'CIA_ANEXO', 'F11_IANEXO' } , {'CIA_FAIXA','F11_ID'} }, CIA->(IndexKey(2)) )
    oModel:GetModel( 'FISA150IMPOSTO' ):SetOptional( .T. )
EndIf


//Adicionando descrição ao modelo
oModel:SetDescription(STR0001) // Cadastro de Anexos do Simples Nacional

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Erick G Dias
@since 27/02/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA150" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oPai	    	:= FWFormStruct(2, "F10")
Local oFilho		:= FWFormStruct(2, "F11")
Local oFilhoCIA

Local oView := Nil
Local cVersao 	:= GetVersao(.F.)

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField( 'VIEW_ANEXO'   , oPai    , 'FISA150'      )
oView:AddGrid(  'VIEW_FAIXA'   , oFilho  , 'FISA150FAIXA' )
If lPosCIA
    oFilhoCIA   := FWFormStruct(2, "CIA")
    oFilhoCIA:RemoveField( 'CIA_ANEXO' )
    oFilhoCIA:RemoveField( 'CIA_FAIXA' )
    oFilhoCIA:RemoveField( 'CIA_ID' )
    oView:AddGrid(  'VIEW_IMPOSTO'   , oFilhoCIA  , 'FISA150IMPOSTO' )
EndIf

//Retira da view os campos de ID
oPai:RemoveField( 'F10_ID' )
oFilho:RemoveField( 'F11_ID'     )
oFilho:RemoveField( 'F11_IANEXO' )

//Cria os grupos
oPai:AddGroup( 'GRUPO_ANEXO'    , STR0012 , '' , 2 )    //'Identificação do Anexo'
oPai:AddGroup( 'GRUPO_ISS'      , STR0013 , '' , 2 )    //'Percentuais de Rateio de Iss (Quando Superior a 5%)'

//Define os campos do grupo do Anexo
oPai:SetProperty( 'F10_ANEXO'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ANEXO' )
oPai:SetProperty( 'F10_DESCR'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ANEXO' )
oPai:SetProperty( 'F10_INIVIG'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ANEXO' )
oPai:SetProperty( 'F10_FIMVIG'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ANEXO' )

//Define os campos do grupo do Rateio de ISS
oPai:SetProperty( 'F10_RIIRPJ'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ISS' )
oPai:SetProperty( 'F10_RICSLL'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ISS' )
oPai:SetProperty( 'F10_RICOF'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ISS' )
oPai:SetProperty( 'F10_RIPIS'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ISS' )
oPai:SetProperty( 'F10_RICPP'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ISS' )


If lPosCIA
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox( 'SUPERIOR'  , 25 )
    oView:CreateHorizontalBox( 'MEDIO'  , 50 )
    oView:CreateHorizontalBox( 'INFERIOR'  , 25 )
        //O formulário da interface será colocado dentro do container
    oView:SetOwnerView( 'VIEW_ANEXO'   , 'SUPERIOR'   )
    oView:SetOwnerView( 'VIEW_FAIXA'   , 'MEDIO'   )
    oView:SetOwnerView( 'VIEW_IMPOSTO'   , 'INFERIOR'   )
    oView:EnableTitleView('VIEW_IMPOSTO' , STR0019 ) //Redução de Base de Cálculo por Anexo e Faixa
Else
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox( 'SUPERIOR'  , 40 )
    oView:CreateHorizontalBox( 'INFERIOR'  , 60 )
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView( 'VIEW_ANEXO'   , 'SUPERIOR'   )
    oView:SetOwnerView( 'VIEW_FAIXA'   , 'INFERIOR'   )
EndIf


//Colocando título do formulário
oView:EnableTitleView('VIEW_FAIXA' , STR0011 ) //"Informaçoes das Faixas do Anexo"

IF cVersao == '12'
	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty( "*", "GRIDNOORDER" )
EndIF

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ExisteAnexo
Função que fará verificação se já existe anexos criados na tabela F10.
Se houver então retornará verdadeiro, caso contrário retornará falso.

@Return     lRet    - Boolean  - Retorna .T. caso exista ao menos 1 anexo cadastrado.

@author Erick G Dias
@since 28/02/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ExisteAnexo()

Local lRet:= .F.

dbSelectArea('F10')
dbSetOrder(1)

//Se houver ao menos uma linha criada na tabela F10, a rotina não fará a carga inicial dos anexos.
If	F10->( MsSeek ( xFilial('F10') ) )
    lRet:= .T.
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvAnexo
Função responsável por incluir nova linha na tabela de Anexo F10

@param		cOp	        - String  -  Opção, 1=Inclusão, 2=Edição
@param		cNumAnexo	- String  -  Número do Anexo
@param		cDescr	    - String  -  Descrição do Anexo
@param		dDtIni	    - Date    -  Data inicial de vigência
@param		dDtFim	    - Date    -  Data Final de vigência
@param		nIrpj	    - Integer -  Percentual de rateio de ISS para IRPJ
@param		nCsll	    - Integer -  Percentual de rateio de ISS para CSLL
@param		nCOFINS	    - Integer -  Percentual de rateio de ISS para COFINS
@param		nPis	    - Integer -  Percentual de rateio de ISS para PIS
@param		nCPP	    - Integer -  Percentual de rateio de ISS para CPP

@Return     cIdAnexo    - String  - Id da linha adicionada na tabela de Anexo F10

@author Erick G Dias
@since 28/02/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function GrvAnexo( cOp, cNumAnexo, cDescr, dDtIni, dDtFim, nIrpj, nCsll, nCOFINS, nPis, nCPP )

Local cIdAnexo    := FWUUID("F10")

//Inclusão
If cOp == "1"
    RecLock('F10',.T.)

    F10->F10_FILIAL     := xFilial("F10")
    F10->F10_ID         := cIdAnexo
    F10->F10_ANEXO      := cNumAnexo
    F10->F10_DESCR      := cDescr
    F10->F10_INIVIG     := dDtIni
    F10->F10_FIMVIG     := dDtFim
    F10->F10_RIIRPJ     := nIrpj
    F10->F10_RICSLL     := nCsll
    F10->F10_RICOF      := nCOFINS
    F10->F10_RIPIS      := nPis
    F10->F10_RICPP      := nCPP

    F10->(msUnlock())

EndIf

Return cIdAnexo

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvFaixa
Função responsável por incluir nova linha na tabela de Faixa F11

@param		cOp	        - String  -  Opção, 1=Inclusão, 2=Edição
@param		cIdAnexo	- String  -  Id do Anexo
@param		nFaixa	    - Integer -  Número da Faixa
@param		nRecIni	    - Integer -  Valor da Receita Inicial
@param		nRecFim	    - Integer -  Valor da Receita Final
@param		nAlqSn	    - Integer -  Alíquota integral do Simples Nacional
@param		nValDed	    - Integer -  Valor da Dedução da Faixa
@param		nIrpj	    - Integer -  Percentual de rateio do IRPJ
@param		nCSll	    - Integer -  Percentual de rateio da CSLL
@param		nConfins	- Integer -  Percentual de rateio da COFINS
@param		nPis	    - Integer -  Percentual de rateio do PIS
@param		nCpp	    - Integer -  Percentual de rateio do CPP
@param		nIcms	    - Integer -  Percentual de rateio do ICMS
@param		nIss	    - Integer -  Percentual de rateio do Iss
@param		nIpi	    - Integer -  Percentual de rateio do IPI

@author Erick G Dias
@since 28/02/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function GrvFaixa( cOp, cIdAnexo, cFaixa, nRecIni, nRecFim, nAlqSn, nValDed, nIrpj, nCSll, nConfins, nPis, nCpp, nIcms, nIss, nIpi )

//Inclusão
If cOp == "1"
    RecLock('F11',.T.)

    F11->F11_FILIAL     := xFilial( "F11" )
    F11->F11_ID         := FWUUID ( "F11" )
    F11->F11_IANEXO     := cIdAnexo
    F11->F11_FAIXA      := cFaixa
    F11->F11_RECINI     := nRecIni
    F11->F11_RECFIM     := nRecFim
    F11->F11_ALIQSN     := nAlqSn
    F11->F11_VALDED     := nValDed
    F11->F11_IRPJ       := nIrpj
    F11->F11_CSLL       := nCSll
    F11->F11_COFINS     := nConfins
    F11->F11_PIS        := nPis
    F11->F11_CPP        := nCpp
    F11->F11_ICMS       := nIcms
    F11->F11_ISS        := nIss
    F11->F11_IPI        := nIpi

    F11->(msUnlock())

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA150ANEX
Função que fará chamdas da criação dos anexos e das faixas

@author Erick G Dias
@since 27/02/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA150ANEX()

Local aFil      := {}
Local cId1      := ""
Local cId2      := ""
Local cId3      := ""
Local cId4      := ""
Local cId5      := ""
Local cIdAnexo  := ""
local nX        := 0
Local aAreaSM0 	:= SM0->(GetArea())

//Se não houver nenhum anexo cadastrado, então fará a carga das informações dos anexos e faixas.
If !ExisteAnexo()

    //Popula Anexo I
    cId1    := CriAnexo1()

    //Popula Anexo II
    cId2    := CriAnexo2()

    //Popula Anexo III
    cId3    := CriAnexo3()

    //Popula Anexo IV
    cId4    := CriAnexo4()

    //Popula Anexo V
    cId5    := CriAnexo5()

    //Fará carga das faixas para todas as filiais da empresa, pois a tabela F11 é exclusiva
    aFil:= MatFilCalc( .F. )

    For nX  := 1 to Len( aFil )
        SM0->(DbGoTop ())
		SM0->(MsSeek (cEmpAnt +aFil[nX][2], .T.))
		cFilAnt := FWGETCODFILIAL

        //Gravará as faixas dos anexos para todas as filiais
        ProcessaFaixa( cId1, cId2, cId3, cId4, cId5)

    Next nX

    RestArea (aAreaSM0)
	cFilAnt := FWGETCODFILIAL

Else    
    //Caso exista anexo cadastrado, verificará se existe faixa 
    //Verifica se existe ao menos uma faixa cadastrada
    cId1    := GetidAnexo( "01" )

    IF !ExisteFaixa( cId1 )
        //Se não existir ao menos uma faixa, a caraga inicial será executada
         //Fará carga das faixas para todas as filiais da empresa, pois a tabela F11 é exclusiva
        cId2    := GetidAnexo( "02" )
        cId3    := GetidAnexo( "03" )
        cId4    := GetidAnexo( "04" )
        cId5    := GetidAnexo( "05" )
        
        aFil:= MatFilCalc( .F. )

        For nX  := 1 to Len( aFil )
            SM0->(DbGoTop ())
            SM0->(MsSeek (cEmpAnt +aFil[nX][2], .T.))
            cFilAnt := FWGETCODFILIAL

            //Gravará as faixas dos anexos para todas as filiais
            ProcessaFaixa( cId1, cId2, cId3, cId4, cId5)

        Next nX

        RestArea (aAreaSM0)
        cFilAnt := FWGETCODFILIAL

    EndIF

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CriAnexo1
Função que irá popular as informações do Anexo I

@author Erick G Dias
@since 28/02/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function CriAnexo1()

Local INCLUSAO      := "1"
Local cIdAnexo      := ""

//Adiciona Anexo I
cIdAnexo    :=  GrvAnexo( INCLUSAO, "01", "Anexo I - LC 123/06 - Comércio", STOD( "20180101") , STOD( space( 8 ) ) , /*IRPJ*/0, /*CSLL*/0,/*COF*/0,/*PIS*/0, /*CPP*/0 )

Return cIdAnexo

//-------------------------------------------------------------------
/*/{Protheus.doc} CriAnexo2
Função que irá popular as informações do Anexo II

@author Erick G Dias
@since 28/02/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function CriAnexo2()

Local INCLUSAO      := "1"
Local cIdAnexo      := ""

//Adiciona Anexo II
cIdAnexo    :=  GrvAnexo( INCLUSAO, "02", "Anexo II - LC 123/06 - Indústria", STOD( "20180101") , STOD( space( 8 ) ) , /*IRPJ*/0,/*CSLL*/0,/*COF*/0,/*PIS*/0,/*CPP*/0 )

Return cIdAnexo

//-------------------------------------------------------------------
/*/{Protheus.doc} CriAnexo3
Função que irá popular as informações do Anexo III

@author Erick G Dias
@since 28/02/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function CriAnexo3()

Local INCLUSAO      := "1"
Local cIdAnexo      := ""

 //Adiciona Anexo III
cIdAnexo    :=  GrvAnexo( INCLUSAO, "03", "Anexo III - LC 123/06 - Loc. de bens móveis e prest. de serv. não relacionados no §5º-C do art. 18", STOD( "20180101") , STOD( space( 8 ) ) , /*IRPJ*/6.02, /*CSLL*/ 5.26,/*COF*/ 19.28,/*PIS*/ 4.18, /*CPP*/65.26 )

Return cIdAnexo


//-------------------------------------------------------------------
/*/{Protheus.doc} CriAnexo4
Função que irá popular as informações do Anexo IV

@author Erick G Dias
@since 28/02/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function CriAnexo4()

Local INCLUSAO      := "1"
Local cIdAnexo      := ""

 //Adiciona Anexo IV
cIdAnexo    :=  GrvAnexo( INCLUSAO, "04", "Anexo IV - LC 123/06 - Prestação de serviços relacionados no §5º-C do art. 18", STOD( "20180101") , STOD( space( 8 ) ) , /*IRPJ*/31.33, /*CSLL*/32.00,/*COF*/ 30.13,/*PIS*/ 06.54, /*CPP*/0 )

Return cIdAnexo

//-------------------------------------------------------------------
/*/{Protheus.doc} CriAnexo5
Função que irá popular as informações do Anexo V

@author Erick G Dias
@since 28/02/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function CriAnexo5()

Local INCLUSAO      := "1"
Local cIdAnexo      := ""

 //Adiciona Anexo V
cIdAnexo    :=  GrvAnexo( INCLUSAO, "05", "Anexo V - LC 123/06 - Prestação de serviços relacionados no § 5º-I do art. 18", STOD( "20180101") , STOD( space( 8 ) ) , /*IRPJ*/0,/*CSLL*/0,/*COF*/0,/*PIS*/0,/*CPP*/0 )

Return cIdAnexo

//-------------------------------------------------------------------
/*/{Protheus.doc} VALIDACAO
Função que realiza as validações do modelo
@param		oModel	    - Objeto  -  Objeto do modelo FISA150
@Return     lRet       - Booleano - REtorno com validação, .T. pode gravar, .F. não poderá gravar.
@author Erick G Dias
@since 05/03/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function VALIDACAO(oModel)

Local nOperation 	:= oModel:GetOperation()
Local cAnexo 		:= oModel:GetValue ('FISA150',"F10_ANEXO")
Local dDtIni 		:= oModel:GetValue ('FISA150',"F10_INIVIG")
Local dDtFim 		:= oModel:GetValue ('FISA150',"F10_FIMVIG")
Local lRet          := .T.
Local cAliasF13     := ""
Local cFiltro       := ""

IF nOperation == MODEL_OPERATION_INSERT
    If	F10->( MsSeek ( xFilial('F10') + cAnexo + dTos(dDtIni) ) )
        //Já existe anexo cadastrado com mesmo início de vigência
        lRet:= .F.
        Help( ,, 'Help',, STR0016, 1, 0 ) //"Anexo já cadastrado para este início de vigência."
    EndIF
EndIf

If nOperation == MODEL_OPERATION_DELETE

    cFiltro := "F13.F13_ANEXO = " + ValToSql(cAnexo) + " OR F13.F13_ASUB = " + ValToSql(cAnexo) + " AND "
    cFiltro += "F13.D_E_L_E_T_ = ' '"
    CFiltro := "%" + cFiltro + "%"

    cAliasF13	:=	GetNextAlias()

    BeginSql Alias cAliasF13

        SELECT
        F13.F13_ID

        FROM
        %Table:F13% F13

        WHERE
        %Exp:cFiltro%

    EndSql

    DbSelectArea (cAliasF13)
    (cAliasF13)->(DbGoTop())

    // Se não for EOF significa que o anexo foi relacionado a alguma subatividade
    If !(cAliasF13)->(Eof())
        Help( ,, 'Help',, STR0018, 1, 0 ) // "Anexo já vinculado ao detalhamento de uma subatividade. O registro não pode ser excluído."
        lRet := .F.
    EndIf

    (cAliasF13)->(DbCloseArea())

EndIf

//Verifica se a data final é menor que data inicial
IF !Empty(dDtFim) .AND. dDtFim  < dDtIni
    lRet:= .F.
    Help( ,, 'Help',, STR0017, 1, 0 ) // "Data de vigência final inferior a data inicial."
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcessaFaixa
Função que fará chamada das gravaçõs das faixas dos Anexos na caraga inicial da rotina

@author Erick G Dias
@since 17/03/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ProcessaFaixa( cId1, cId2, cId3, cId4, cId5)

Local INCLUSAO      := "1"
Local cIdAnexo      := ""

//-----------------------
//Faixas do Anexo I
//-----------------------
//Primeira Faixa
GrvFaixa( INCLUSAO, cId1, /*Faixa*/ "01", /*RecIni*/ 0          , /*RecFin*/ 180000 , /*AliSn*/04.00,/*VAlDed*/ 0     ,/*IRJP*/05.50,/*CSLL*/03.50,/*COF*/12.74,/*PIS*/02.76,/*CPP*/41.50,/*ICMS*/34.00,/*ISS*/0,/*IPI*/0 )

//Segunda Faixa
GrvFaixa( INCLUSAO, cId1, /*Faixa*/ "02", /*RecIni*/ 180000.01  , /*RecFin*/360000 , /*AliSn*/ 07.30,/*VAlDed*/ 5940  ,/*IRJP*/05.50,/*CSLL*/03.50,/*COF*/12.74,/*PIS*/02.76,/*CPP*/41.50,/*ICMS*/34.00,/*ISS*/0,/*IPI*/0 )

//Terceira Faixa
GrvFaixa( INCLUSAO, cId1, /*Faixa*/ "03", /*RecIni*/ 360000.01  , /*RecFin*/720000 , /*AliSn*/ 09.50,/*VAlDed*/ 13860 ,/*IRJP*/05.50,/*CSLL*/03.50,/*COF*/12.74,/*PIS*/02.76,/*CPP*/42.00,/*ICMS*/33.50,/*ISS*/0,/*IPI*/0 )

//Quarta Faixa
GrvFaixa( INCLUSAO, cId1, /*Faixa*/ "04", /*RecIni*/ 720000.01  , /*RecFin*/1800000, /*AliSn*/ 10.70,/*VAlDed*/ 22500 ,/*IRJP*/05.50,/*CSLL*/03.50,/*COF*/12.74,/*PIS*/02.76,/*CPP*/42.00,/*ICMS*/33.50,/*ISS*/0,/*IPI*/0 )

//Quinta Faixa
GrvFaixa( INCLUSAO, cId1, /*Faixa*/ "05", /*RecIni*/ 1800000.01 , /*RecFin*/3600000, /*AliSn*/ 14.30,/*VAlDed*/ 87300 ,/*IRJP*/05.50,/*CSLL*/03.50,/*COF*/12.74,/*PIS*/02.76,/*CPP*/42.00,/*ICMS*/33.50,/*ISS*/0,/*IPI*/0 )

//Sexta Faixa
GrvFaixa( INCLUSAO, cId1, /*Faixa*/ "06", /*RecIni*/ 3600000.01  , /*RecFin*/4800000, /*AliSn*/ 19.00,/*VAlDed*/ 378000,/*IRJP*/13.50,/*CSLL*/10.00,/*COF*/28.27,/*PIS*/06.13,/*CPP*/42.10,/*ICMS*/00.00,/*ISS*/0,/*IPI*/0 )


//-----------------------
//Faixas do Anexo II
//-----------------------
//Primeira Faixa
GrvFaixa( INCLUSAO, cId2, /*Faixa*/ "01", /*RecIni*/ 0          , /*RecFin*/ 180000 ,/*AliSn*/ 04.50,/*VAlDed*/ 0     ,/*IRJP*/05.50,/*CSLL*/03.50,/*COF*/11.51,/*PIS*/02.49,/*CPP*/37.50,/*ICMS*/32.00,/*ISS*/0,/*IPI*/07.50 )

//Segunda Faixa
GrvFaixa( INCLUSAO, cId2, /*Faixa*/ "02", /*RecIni*/ 180000.01  , /*RecFin*/360000 , /*AliSn*/ 07.80,/*VAlDed*/ 5940  ,/*IRJP*/05.50,/*CSLL*/03.50,/*COF*/11.51,/*PIS*/02.49,/*CPP*/37.50,/*ICMS*/32.00,/*ISS*/0,/*IPI*/07.50 )

//Terceira Faixa
GrvFaixa( INCLUSAO, cId2, /*Faixa*/"03", /*RecIni*/ 360000.01  , /*RecFin*/720000 , /*AliSn*/ 10.00,/*VAlDed*/ 13860 ,/*IRJP*/05.50,/*CSLL*/03.50,/*COF*/11.51,/*PIS*/02.49,/*CPP*/37.50,/*ICMS*/32.00,/*ISS*/0, /*IPI*/07.50 )

//Quarta Faixa
GrvFaixa( INCLUSAO, cId2, /*Faixa*/ "04", /*RecIni*/ 720000.01  , /*RecFin*/1800000, /*AliSn*/ 11.20,/*VAlDed*/ 22500 ,/*IRJP*/05.50,/*CSLL*/03.50,/*COF*/11.51,/*PIS*/02.49,/*CPP*/37.50,/*ICMS*/32.00,/*ISS*/0, /*IPI*/07.50 )

//Quinta Faixa
GrvFaixa( INCLUSAO, cId2, /*Faixa*/ "05", /*RecIni*/ 1800000.01 , /*RecFin*/3600000, /*AliSn*/ 14.70,/*VAlDed*/ 85500 ,/*IRJP*/05.50,/*CSLL*/03.50,/*COF*/11.51,/*PIS*/02.49,/*CPP*/37.50,/*ICMS*/32.00,/*ISS*/0, /*IPI*/07.50 )

//Sexta Faixa
GrvFaixa( INCLUSAO, cId2, /*Faixa*/ "06", /*RecIni*/ 3600000.01  , /*RecFin*/4800000, /*AliSn*/ 30.00,/*VAlDed*/ 720000,/*IRJP*/08.50,/*CSLL*/07.50,/*COF*/20.96,/*PIS*/04.54,/*CPP*/23.50,/*ICMS*/00.00,/*ISS*/0, /*IPI*/35.00 )



//-----------------------
//Faixas do Anexo III
//-----------------------
//Primeira Faixa
GrvFaixa( INCLUSAO, cId3, /*Faixa*/ "01", /*RecIni*/ 0          , /*RecFin*/ 180000 , /*AliSn*/ 6      ,/*VAlDed*/ 0     ,/*IRJP*/ 4, /*CSLL*/ 3.5 ,/*COF*/ 12.82,/*PIS*/ 2.78 , /*CPP*/ 43.40 , /*ICMS*/ 0, /*ISS*/ 33.50, /*IPI*/ 0 )

//Segunda Faixa
GrvFaixa( INCLUSAO, cId3, /*Faixa*/ "02", /*RecIni*/ 180000.01  , /*RecFin*/360000 , /*AliSn*/ 11.20  ,/*VAlDed*/ 9360  , /*IRJP*/4  , /*CSLL*/ 3.5 ,  /*COF*/14.05,/*PIS*/ 3.05 , /*CPP*/43.40   ,/*ICMS*/ 0, /*ISS*/32   ,/*IPI*/ 0 )

//Terceira Faixa
GrvFaixa( INCLUSAO, cId3, /*Faixa*/ "03", /*RecIni*/ 360000.01  , /*RecFin*/720000 , /*AliSn*/ 13.50 ,/*VAlDed*/ 17640  ,/*IRJP*/ 4  ,/*CSLL*/ 3.5 ,  /*COF*/13.64, /*PIS*/2.96 , /*CPP*/43.40   ,/*ICMS*/ 0, /*ISS*/ 32.50, /*IPI*/0 )

//Quarta Faixa
GrvFaixa( INCLUSAO, cId3, /*Faixa*/ "04", /*RecIni*/ 720000.01  , /*RecFin*/1800000, /*AliSn*/ 16    ,/*VAlDed*/ 35640  , /*IRJP*/4  ,/*CSLL*/ 3.5 ,  /*COF*/13.64, /*PIS*/2.96 , /*CPP*/43.40   ,/*ICMS*/ 0, /*ISS*/32.50, /*IPI*/0 )

//Quinta Faixa
GrvFaixa( INCLUSAO, cId3, /*Faixa*/ "05", /*RecIni*/ 1800000.01 , /*RecFin*/3600000, /*AliSn*/ 21    ,/*VAlDed*/ 125640 ,/*IRJP*/ 4  ,/*CSLL*/ 3.5 ,  /*COF*/12.82, /*PIS*/2.78 ,/*CPP*/ 43.40   ,/*ICMS*/ 0,/*ISS*/ 33.50, /*IPI*/0 )

//Sexta Faixa
GrvFaixa( INCLUSAO, cId3, /*Faixa*/ "06", /*RecIni*/ 3600000.01  , /*RecFin*/4800000, /*AliSn*/ 33    ,/*VAlDed*/ 648000 , /*IRJP*/35 ,/*CSLL*/ 15  , /*COF*/ 16.03, /*PIS*/3.47 , /*CPP*/30.50   , /*ICMS*/0 , /*ISS*/0   , /*IPI*/0 )

//-----------------------
//Faixas do Anexo IV
//-----------------------
//Primeira Faixa
GrvFaixa( INCLUSAO, cId4, /*Faixa*/ "01", /*RecIni*/ 0          , /*RecFin*/ 180000 , /*AliSn*/ 04.50 ,/*VAlDed*/ 0     ,/*IRJP*/18.80,/*CSLL*/15.20,/*COF*/17.67,/*PIS*/03.83,/*CPP*/0,/*ICMS*/0,/*ISS*/44.50,/*IPI*/0 )

//Segunda Faixa
GrvFaixa( INCLUSAO, cId4, /*Faixa*/ "02", /*RecIni*/ 180000.01  , /*RecFin*/360000 , /*AliSn*/ 09.00  ,/*VAlDed*/ 8100  ,/*IRJP*/19.80,/*CSLL*/15.20,/*COF*/20.55,/*PIS*/04.45,/*CPP*/0,/*ICMS*/0,/*ISS*/40.00,/*IPI*/0 )

//Terceira Faixa
GrvFaixa( INCLUSAO, cId4, /*Faixa*/ "03", /*RecIni*/ 360000.01  , /*RecFin*/720000 , /*AliSn*/ 10.20  ,/*VAlDed*/ 12420  ,/*IRJP*/20.80,/*CSLL*/15.20,/*COF*/19.73,/*PIS*/04.27,/*CPP*/0,/*ICMS*/0,/*ISS*/40.00,/*IPI*/0 )

//Quarta Faixa
GrvFaixa( INCLUSAO, cId4, /*Faixa*/ "04", /*RecIni*/ 720000.01  , /*RecFin*/1800000, /*AliSn*/ 14.00  ,/*VAlDed*/ 39780  ,/*IRJP*/17.80,/*CSLL*/19.20,/*COF*/18.90,/*PIS*/04.10,/*CPP*/0,/*ICMS*/0,/*ISS*/40.00,/*IPI*/0 )

//Quinta Faixa
GrvFaixa( INCLUSAO, cId4, /*Faixa*/ "05", /*RecIni*/ 1800000.01 , /*RecFin*/3600000, /*AliSn*/ 22.00  ,/*VAlDed*/ 183780 ,/*IRJP*/18.80,/*CSLL*/19.20,/*COF*/18.08,/*PIS*/03.92,/*CPP*/0,/*ICMS*/0,/*ISS*/40.00,/*IPI*/0 )

//Sexta Faixa
GrvFaixa( INCLUSAO, cId4, /*Faixa*/ "06", /*RecIni*/ 3600000.01  , /*RecFin*/4800000, /*AliSn*/ 33.00  ,/*VAlDed*/ 828000 ,/*IRJP*/53.50,/*CSLL*/21.50,/*COF*/20.55,/*PIS*/04.45,/*CPP*/0,/*ICMS*/0,/*ISS*/00.00,/*IPI*/0 )


//-----------------------
//Faixas do Anexo V
//-----------------------
//Primeira Faixa
GrvFaixa( INCLUSAO, cId5, /*Faixa*/"01",/*RecIni*/0         , /*RecFin*/ 180000 , /*AliSn*/ 15.50 ,/*VAlDed*/ 0     ,/*IRJP*/25.00,/*CSLL*/15.00,/*COF*/14.10,/*PIS*/03.05,/*CPP*/28.85,/*ICMS*/0,/*ISS*/14.00,/*IPI*/0 )

//Segunda Faixa
GrvFaixa( INCLUSAO, cId5, /*Faixa*/"02",/*RecIni*/180000.01 , /*RecFin*/360000 , /*AliSn*/ 18.00  ,/*VAlDed*/ 4500  ,/*IRJP*/23.00,/*CSLL*/15.00,/*COF*/14.10,/*PIS*/03.05,/*CPP*/27.85,/*ICMS*/0,/*ISS*/17.00,/*IPI*/0 )

//Terceira Faixa
GrvFaixa( INCLUSAO, cId5, /*Faixa*/"03",/*RecIni*/360000.01 , /*RecFin*/720000 , /*AliSn*/ 19.50 ,/*VAlDed*/ 9900   ,/*IRJP*/24.00,/*CSLL*/15.00,/*COF*/14.92,/*PIS*/03.23,/*CPP*/23.85,/*ICMS*/0,/*ISS*/19.00,/*IPI*/0 )

//Quarta Faixa
GrvFaixa( INCLUSAO, cId5, /*Faixa*/"04",/*RecIni*/720000.01 , /*RecFin*/1800000, /*AliSn*/ 20.50 ,/*VAlDed*/ 17100  ,/*IRJP*/21.00,/*CSLL*/15.00,/*COF*/15.74,/*PIS*/03.41,/*CPP*/23.85,/*ICMS*/0,/*ISS*/21.00,/*IPI*/0 )

//Quinta Faixa
GrvFaixa( INCLUSAO, cId5, /*Faixa*/"05",/*RecIni*/1800000.01, /*RecFin*/3600000, /*AliSn*/ 23.00 ,/*VAlDed*/ 62100  ,/*IRJP*/23.00,/*CSLL*/12.50,/*COF*/14.10,/*PIS*/03.05,/*CPP*/23.85,/*ICMS*/0,/*ISS*/23.50,/*IPI*/0 )

//Sexta Faixa
GrvFaixa( INCLUSAO, cId5, /*Faixa*/"06",/*RecIni*/3600000.01 , /*RecFin*/4800000, /*AliSn*/ 30.50 ,/*VAlDed*/ 540000 ,/*IRJP*/35.00,/*CSLL*/15.50,/*COF*/16.44,/*PIS*/03.56,/*CPP*/29.50,/*ICMS*/0,/*ISS*/00.00,/*IPI*/0 )

Return


Static Function GetidAnexo( cAnexo )

Local cIdRet    := ''

If F10->( MsSeek ( xFilial('F10') + cAnexo ) )
    cIdRet  := F10->F10_ID
EndIF

Return cIdRet


Static Function ExisteFaixa( cIdAnexo )

Local lRet:= F11->( MsSeek ( xFilial('F11')  + cIdAnexo ) )

Return lRet