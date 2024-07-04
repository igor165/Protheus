#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE 'FWEDITPANEL.CH'
#Include 'FINMRATIR.CH'

#DEFINE TYPE_MODEL	1
#DEFINE TYPE_VIEW   2

Static __aRateio := {}
Static __aCampos := {}

//-------------------------------------------
/*/{Protheus.doc}FINMRATIR
Detalhamento dos rateios de Ir Progressivo
@author Vitor Duca
@Param aRatIRF, Array, Matriz contendo a estrutura do rateio
@Param lBaixa, Logico, Identifica se a rotina chamadora é uma rotina de baixa
@since  07/04/2019
@version 12
/*/
//-------------------------------------------
Function FINMRATIR(aRatIRF As Array, lBaixa As Logical)
    Local aEnableButtons	As Array
    Local nOK				As Numeric
	Local lAcesso			As Logical

    Default aRatIRF := {}
    Default lBaixa  := .F.

    //Inicialização das variaveis
    nOK	 := 0
    lAcesso	:= .T.
    aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
    
    If !lBaixa
        __aCampos := {M->E2_NUM, M->E2_PARCELA ,M->E2_PREFIXO , M->E2_TIPO, M->E2_FORNECE, M->E2_LOJA, M->E2_NATUREZ, M->E2_EMISSAO, M->E2_VENCREA, M->E2_SALDO, M->E2_VALOR, M->E2_CODRET}
    Else
        __aCampos := {SE2->E2_NUM, SE2->E2_PARCELA ,SE2->E2_PREFIXO , SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NATUREZ, SE2->E2_EMISSAO, SE2->E2_VENCREA, SE2->E2_SALDO, SE2->E2_VALOR, SE2->E2_CODRET} 
    Endif 
    
    If Len(aRatIRF) > 0
        __aRateio := aClone(aRatIRF)   
    Endif

	If FindFunction("GetHlpLGPD")
		IF GetHlpLGPD({"FKJ_CPF"})//Verifica se o usuario tem acesso aos dados protegidos pela LGPD
    		lAcesso := .F. 
		Endif
	Endif

	If lAcesso
		nOK := FWExecView( STR0001/*Rateio de IR progressivo*/,"FINMRATIR", MODEL_OPERATION_VIEW,/**/,/**/,/**/,60,aEnableButtons)//"Rateio de IR progressivo"
	Endif			                                                                                                                                                                                                                                                                                                                                                                                                                                                                 

    FwFreeArray(__aRateio)
    FwFreeArray(__aCampos)
    FwFreeArray(aEnableButtons)
    __aCampos := {}
    __aRateio := {}

Return nOK

//-----------------------------
/*/{Protheus.doc}ModelDef
Modelo de dados.
@author Vitor Duca
@since  07/04/2020
@version 12
/*/
//-----------------------------
Static Function ModelDef()
    Local oModel 	:= MPFormModel():New('FINMRATIR',/*Pre*/,/*Pos*/,/*Commit*/)
    Local oSE2	 	:= FWFormStruct(1, 'SE2')
    Local oFKJFake  := FWFormModelStruct():New()
    Local bLoad     := {|oGridModel, lCopy| LoadFkj(oGridModel, lCopy)}
    Local aAuxFKJ	:= {}

    oFKJFake:AddTable('FKJDETAIL',,'FKJDETAIL')

    FCriaStru(oFKJFake,TYPE_MODEL)

    oSE2:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)

    oModel:AddFields("SE2MASTER",/*cOwner*/	, oSE2)
    oModel:AddGrid("FKJDETAIL","SE2MASTER" , oFKJFake,/*bLinePre*/,/*bLinePost*/,/*bPre*/ ,/*bLinePost*/ , bLoad /*bLoadVld*/)

    oModel:SetPrimaryKey({'E2_FILIAL','E2_PREFIXO','E2_NUM','E2_PARCELA','E2_TIPO','E2_FORNECE','E2_LOJA'})

    aAdd(aAuxFKJ, {"Codigo", "E2_FORNECE"})
    aAdd(aAuxFKJ, {"Loja", "E2_LOJA"})
    oModel:SetRelation("FKJDETAIL", aAuxFKJ , FKJ->(IndexKey(1) ) )

    oModel:SetDescription( STR0003 )//'Rateio de CPFs Ir Progressivo'

    //Define que o submodelo não será gravavél (será apenas para visualização).
    oModel:GetModel( 'FKJDETAIL' ):SetOnlyQuery( .T. )
    oModel:GetModel( 'SE2MASTER' ):SetOnlyQuery( .T. )

    oModel:GetModel( 'SE2MASTER' ):SetDescriptadion( STR0002 )//Contas a pagar                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
    oModel:GetModel( 'FKJDETAIL' ):SetDescription( STR0003 )//'Rateio de CPFs Ir Progressivo'

    oModel:SetActivate({|oModel|LoadTit( oModel )})

Return oModel

//---------------------------------
/*/{Protheus.doc}ViewDef
Interface.
@author Vitor Duca
@since  07/04/2020
@version 12
/*/
//---------------------------------
Static Function ViewDef()
    Local oView  		:= FWFormView():New()
    Local oModel 		:= FWLoadModel("FINMRATIR")
    Local oSE2	 		:= FWFormStruct(2,'SE2', { |x| ALLTRIM(x) $ 'E2_NUM, E2_PARCELA, E2_PREFIXO, E2_TIPO, E2_FORNECE, E2_LOJA,E2_NATUREZ, E2_EMISSAO, E2_VENCREA, E2_SALDO, E2_VALOR' } )
    Local oFKJFake      := FWFormViewStruct():New()

    FCriaStru(oFKJFake,TYPE_VIEW)

    //Valida se pode entrar na tela
	oView:SetViewCanActivate({|| CanView() } )

    oSE2:SetNoFolder()

    oFKJFake:RemoveField( 'Codigo' )
    oFKJFake:RemoveField( 'Loja' )

    oView:SetModel( oModel )
    oView:AddField("VIEWSE2",oSE2,"SE2MASTER")
    oView:AddGrid("VIEWFKJ",oFKJFake,"FKJDETAIL")

    oView:CreateHorizontalBox( 'BOXSE2', 50 )
    oView:CreateHorizontalBox( 'BOXFKJ', 50 )

    oView:SetOwnerView('VIEWSE2', 'BOXSE2')
    oView:SetOwnerView('VIEWFKJ', 'BOXFKJ')

    oView:ShowUpdateMsg(.F.)

    //Desabilita os botoes das acoes relacionadas
    oView:EnableControlBar(.F.)

    oView:EnableTitleView('VIEWSE2' , STR0002 /*'Contas a Pagar'*/ )
    oView:EnableTitleView('VIEWFKJ' , STR0003 /*'Rateio de CPFs Ir Progressivo'*/ )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FCriaStru

@param oStruct, Objeto do modelo/view 
@return nType, Tipo de criação dos fields (1 - Model, 2 - View) 

@author Vitor Duca
@since 07/04/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function FCriaStru(oStruct As Object, nType As Numeric)

	If nType == TYPE_MODEL
		//----------------Estrutura para criação do campo-----------------------------
		// [01] C Titulo do campo
		// [02] C ToolTip do campo
		// [03] C identificador (ID) do Field
		// [04] C Tipo do campo
		// [05] N Tamanho do campo
		// [06] N Decimal do campo
		// [07] B Code-block de validação do campo
		// [08] B Code-block de validação When do campo
		// [09] A Lista de valores permitido do campo
		// [10] L Indica se o campo tem preenchimento obrigatório
		// [11] B Code-block de inicializacao do campo
		// [12] L Indica se trata de um campo chave
		// [13] L Indica se o campo pode receber valor em uma operação de update.
		// [14] L Indica se o campo é virtual

        oStruct:AddField(STR0004,"",STR0004,"C",TAMSX3("FKJ_COD")[1],0,/*bValid*/,{||.F.},/*aValues*/,.T.,/*bInit*/,/*Key*/,/*lAlter*/,.T.) //Codigo 
        oStruct:AddField(STR0005,"",STR0005,"C",TAMSX3("FKJ_LOJA")[1],0,/*bValid*/,{||.F.},/*aValues*/,.T.,/*bInit*/,/*Key*/,/*lAlter*/,.T.) //Loja
		oStruct:AddField("CPF","","CPF","C",TAMSX3("FKJ_CPF")[1],0,/*bValid*/,{||.F.},/*aValues*/,.T.,/*bInit*/,/*Key*/,/*lAlter*/,.T.)
		oStruct:AddField(STR0006,"",STR0006,"C",TAMSX3("FKJ_NOME")[1],0,/*bValid*/,{||.F.},/*aValues*/,.T.,/*bInit*/,/*Key*/,/*lAlter*/,.T.) //Nome
        oStruct:AddField(STR0007,"",STR0007,"C",TAMSX3("FKJ_PERCEN")[1],0,/*bValid*/,{||.F.},/*aValues*/,.T.,/*bInit*/,/*Key*/,/*lAlter*/,.T.) //Percentual
        oStruct:AddField(STR0008,"",STR0008,"N",16,2,/*bValid*/,{||.F.},/*aValues*/,.T.,/*bInit*/,/*Key*/,/*lAlter*/,.T.) //Base de rendimento
        oStruct:AddField(STR0010,"",STR0010,"N",16,2,/*bValid*/,{||.F.},/*aValues*/,.T.,/*bInit*/,/*Key*/,/*lAlter*/,.T.) //Imposto retido
		oStruct:AddField(STR0009,"",STR0009,"N",16,2,/*bValid*/,{||.F.},/*aValues*/,.T.,/*bInit*/,/*Key*/,/*lAlter*/,.T.) //Imposto a ser retido

	Elseif nType == TYPE_VIEW
		//----------------Estrutura para criação do campo-----------------------------
		// [01] C Nome do Campo
		// [02] C Ordem
		// [03] C Titulo do campo
		// [04] C Descrição do campo
		// [05] A Array com Help
		// [06] C Tipo do campo
		// [07] C Picture
		// [08] B Bloco de Picture Var
		// [09] C Consulta F3
		// [10] L Indica se o campo é evitável
		// [11] C Pasta do campo
		// [12] C Agrupamento do campo
		// [13] A Lista de valores permitido do campo (Combo)
		// [14] N Tamanho Maximo da maior opção do combo
		// [15] C Inicializador de Browse
		// [16] L Indica se o campo é virtual
		// [17] C Picture Variável

        oStruct:AddField(STR0004,"01",STR0004,STR0004,,"C","@!",Nil,Nil,.F.,Nil,,,,,.T.)//Codigo 
        oStruct:AddField(STR0005,"02",STR0005,STR0005,,"C","@!",Nil,Nil,.F.,Nil,,,,,.T.)//Loja
		oStruct:AddField("CPF","03","CPF","CPF",,"C","@!",Nil,Nil,.F.,Nil,,,,,.T.)
		oStruct:AddField(STR0006,"04",STR0006,STR0006,,"C","@!" ,Nil,Nil,.F.,Nil,,,,,.T.)//Nome
        oStruct:AddField(STR0007,"05",STR0007,STR0007,,"N","999.99" ,Nil,Nil,.F.,Nil,,,,,.T.)//Percentual
        oStruct:AddField(STR0008,"06",STR0008,STR0008,,"N","9999999999999.99" ,Nil,Nil,.F.,Nil,,,,,.T.)//Base de rendimento
        oStruct:AddField(STR0010,"07",STR0010,STR0010,,"N","9999999999999.99" ,Nil,Nil,.F.,Nil,,,,,.T.)//"Imposto retido"
		oStruct:AddField(STR0009,"08",STR0009,STR0009,,"N","9999999999999.99" ,Nil,Nil,.F.,Nil,,,,,.T.)//Imposto a ser retido

	Endif	

Return

//----------------------------------------------------
/*/{Protheus.doc} LoadFkj
Efetua o carregamento dos campos do Detail fake, para
que ocorra o correto relacionamento com a SE2

@Param oGridModel, Objeto do model que ira receber as informações carregadas
@Param lCopy, Indica se é uma operação de copia
@Return aAux, Matriz contendo as informações que serão usadas na View
@author Vitor Duca
@example
    Estrutura do retorno aAux
        aAux[1] - Codigo do fornecedor 
        aAux[1] - Loja do fornecedor
        aAux[1] - CPF dos socios  
        aAux[2] - Nome dos socios 
        aAux[3] - Percentual do rateio entre os socios 
        aAux[4] - Base de rendimento total do periodo
        aAux[5] - Impostos retidos
        aAux[6] - Impostos calculados (Em processamento)

@since 08/04/2020
@version P12
/*/
//---------------------------------------------------
Static Function LoadFkj(oGridModel As Object, lCopy As Logical) As Array
    Local aGrid 	As Array
	Local aAux     	As Array
	Local nX		As Numeric

	//inicialização das variaveis
	aGrid     := {}
	aAux      := {}
	nX		  := 0

    If Len(__aRateio) > 0
        For nX := 1 to Len(__aRateio)	
            aAdd( aGrid , __aRateio[nX][1])
            aAdd( aGrid , __aRateio[nX][2])
            aAdd( aGrid , __aRateio[nX][3])
            aAdd( aGrid , __aRateio[nX][8])
            aAdd( aGrid , __aRateio[nX][4])
            aAdd( aGrid , __aRateio[nX][5])
            aAdd( aGrid , __aRateio[nX][7])
            aAdd( aGrid , __aRateio[nX][6])

            aAdd(aAux,{0, aGrid})
            aGrid := {}
        Next nX
    Endif

	FwFreeArray(aGrid)

Return aAux

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadTit
Função chamada antes da abertura da tela, com o model ja ativo.
Deixa os campos pre-preenchidos com os valores da tela 

@param omodel, model ativo

@author Vitor Duca
@since 07/04/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function LoadTit(oModel As Object)
	
	oModel:LoadValue("SE2MASTER","E2_NUM",__aCampos[1])
	oModel:LoadValue("SE2MASTER","E2_PARCELA",__aCampos[2])
    oModel:LoadValue("SE2MASTER","E2_PREFIXO",__aCampos[3])
    oModel:LoadValue("SE2MASTER","E2_TIPO",__aCampos[4])
    oModel:LoadValue("SE2MASTER","E2_FORNECE",__aCampos[5])
    oModel:LoadValue("SE2MASTER","E2_LOJA",__aCampos[6])
    oModel:LoadValue("SE2MASTER","E2_NATUREZ",__aCampos[7])
    oModel:LoadValue("SE2MASTER","E2_EMISSAO",__aCampos[8])
    oModel:LoadValue("SE2MASTER","E2_VENCREA",__aCampos[9])
    oModel:LoadValue("SE2MASTER","E2_SALDO",__aCampos[10])
    oModel:LoadValue("SE2MASTER","E2_VALOR",__aCampos[11])

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CanView
Pre-Validação para permitir acessar a tela.

@return lRet, Logico, Verifica as permissões para acessar a tela
@author Vitor Duca
@since 08/04/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function CanView()
	Local lRet      As Logical 
    Local aArea     As Array
    Local aAreaSA2  As Array
    Local aAreaFKJ  As Array
    Local cCdRetIRRt As Character
    
    lRet        := .T.
    aArea       := GetArea()
    aAreaSA2    := SA2->(GetArea())
    aAreaFKJ    := FKJ->(GetArea()) 
    aAreaSED    := SED->(GetArea())   
    cCdRetIRRt  := SuperGetMv("MV_RETIRRT",.T.,"3208")

    SA2->(DbSetOrder(1))
    FKJ->(DbSetOrder(1))
    SED->(DbSetOrder(1))

    If SED->(DbSeek(xFilial("SED")+__aCampos[7]))
        lRet := SED->ED_CALCIRF == "S"
    Else
        lRet := .F.
    Endif

    If !lRet
		Help( ,,"NATURIRRF",,STR0015, 1, 0,,,,,,{STR0016})
	EndIf        

    If lRet 
        If SA2->(DBSeek(xFilial("SA2")+__aCampos[5]+__aCampos[6]))
            If !FKJ->(DbSeek(xFilial("FKJ")+__aCampos[5]+__aCampos[6]))
	            lRet := .F.
            EndIf
        Else
            lRet := .F.
        Endif

        If !lRet
		    Help( ,,"NORATEIOIR",,STR0011, 1, 0,,,,,,{STR0012})
	    EndIf
    EndIf    

    If lRet .and. !__aCampos[12] $ cCdRetIRRt
        Help( ,,"CODRATEIOIR",,STR0013, 1, 0,,,,,,{STR0014})
        lRet := .F.
    Endif    

    RestArea(aAreaSA2)
    RestArea(aAreaSED)
    RestArea(aAreaFKJ)
    RestArea(aArea)

    FwFreeArray(aAreaSA2)
    FwFreeArray(aAreaSED)
    FwFreeArray(aAreaFKJ)
    FwFreeArray(aArea)

Return lRet
