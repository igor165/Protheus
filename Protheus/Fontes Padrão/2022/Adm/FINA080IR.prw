#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE 'FWEDITPANEL.CH'
#Include 'FINA080IR.CH'

#DEFINE TYPE_MODEL	1
#DEFINE TYPE_VIEW   2

//-------------------------------------------
/*/{Protheus.doc}FINA080IR
Detalhamento dos rateios de Ir Progressivo
@author Vitor Duca
@since  23/12/2019
@version 12
/*/
//-------------------------------------------
Function FINA080IR()
    Local aEnableButtons	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
    Local nOK				:= 0
	Local aLGPD				:= {}
	Local lAcesso			:= .T.

	Aadd(aLGPD, "FKJ_CPF")

	If FindFunction("GetHlpLGPD")
		IF GetHlpLGPD(aLGPD)//Verifica se o usuario tem acesso aos dados protegidos pela LGPD
    		lAcesso := .F. 
		Endif
	Endif

	If lAcesso
		nOK := FWExecView( STR0001/*Rateio de IR progressivo*/,"FINA080IR", MODEL_OPERATION_VIEW,/**/,/**/,/**/,60,aEnableButtons)//"Rateio de IR progressivo"
	Endif			                                                                                                                                                                                                                                                                                                                                                                                                                                                                 

    FwFreeArray(aEnableButtons)
Return nOK

//-----------------------------
/*/{Protheus.doc}ModelDef
Modelo de dados.
@author Vitor Duca
@since  23/12/2019
@version 12
/*/
//-----------------------------
Static Function ModelDef()
    Local oModel 	:= MPFormModel():New('FINA080IR',/*Pre*/,/*Pos*/,/*Commit*/)
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

Return oModel

//---------------------------------
/*/{Protheus.doc}ViewDef
Interface.
@author Vitor Duca
@since  23/12/2019
@version 12
/*/
//---------------------------------
Static Function ViewDef()
    Local oView  		:= FWFormView():New()
    Local oModel 		:= FWLoadModel("FINA080IR")
    Local oSE2	 		:= FWFormStruct(2,'SE2', { |x| ALLTRIM(x) $ 'E2_NUM, E2_PARCELA, E2_PREFIXO, E2_TIPO, E2_FORNECE, E2_LOJA,E2_NATUREZ, E2_EMISSAO, E2_VENCREA, E2_SALDO, E2_VALOR' } )
    Local oFKJFake      := FWFormViewStruct():New()

    FCriaStru(oFKJFake,TYPE_VIEW)

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
@since 23/12/2019
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
@since 23/12/2019
@version P12
/*/
//---------------------------------------------------
Static Function LoadFkj(oGridModel, lCopy) As Array
    Local aGrid 	As Array
	Local aAux     	As Array
	Local nX		As Numeric

	//inicialização das variaveis
	aGrid     := {}
	aAux      := {}
	nX		  := 0

	For nX := 1 to Len(aRatIRF)	
		aAdd( aGrid , aRatIRF[nX][1])
		aAdd( aGrid , aRatIRF[nX][2])
		aAdd( aGrid , aRatIRF[nX][3])
		aAdd( aGrid , aRatIRF[nX][8])
		aAdd( aGrid , aRatIRF[nX][4])
		aAdd( aGrid , aRatIRF[nX][5])
		aAdd( aGrid , aRatIRF[nX][7])
		aAdd( aGrid , aRatIRF[nX][6])

		aAdd(aAux,{0, aGrid})
		aGrid := {}
	Next
	    
	FwFreeArray(aGrid)

Return aAux