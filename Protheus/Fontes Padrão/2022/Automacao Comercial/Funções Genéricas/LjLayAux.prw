#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "LJLAYAUX.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} LjLayAux
Modelo MVC Integrações Varejo

@type    function
@author  Rafael Tenorio da Costa
@since   23/08/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function LjLayAux()

	Local oBrowse := Nil

    //Valida o dicionario de dados
    If LjCadAuxVd()

        oBrowse := FWMBrowse():New()
        oBrowse:SetDescription(STR0001)     //"Layouts Auxiliares"
        oBrowse:SetAlias("MIG")
        oBrowse:SetLocate()

        oBrowse:SetMenuDef("LjLayAux")
        oBrowse:Activate()
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@type   function
@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author  Rafael Tenorio da Costa
@since   23/08/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, {STR0002, "PesqBrw"         , 0, 1, 0, .T. } )   //"Pesquisar"
    aAdd( aRotina, {STR0003, "VIEWDEF.LjLayAux", 0, 2, 0, NIL } )	//"Visualizar"
    aAdd( aRotina, {STR0004, "VIEWDEF.LjLayAux", 0, 3, 0, NIL } )	//"Incluir"
    aAdd( aRotina, {STR0005, "VIEWDEF.LjLayAux", 0, 4, 0, NIL } )	//"Alterar"
    aAdd( aRotina, {STR0006, "VIEWDEF.LjLayAux", 0, 5, 0, NIL } )	//"Excluir"
	aAdd( aRotina, {STR0007, "VIEWDEF.LjLayAux", 0, 8, 0, NIL } )	//"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados das Integrações Varejo

@type    function
@return  FWFormView, Objeto com as configurações a interface do MVC
@author  Rafael Tenorio da Costa
@since   23/08/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel	 := FwLoadModel( "LjLayAux" )
	Local oStructMIG := Nil
	Local oView		 := Nil
  
	//--------------------------------------------------------------
	//Montagem da interface via dicionario de dados
	//--------------------------------------------------------------
	oStructMIG := FWFormStruct( 2, "MIG" )
    oStructMIG:RemoveField("MIG_FILIAL")

  	//--------------------------------------------------------------
	//Montagem do View normal se Container
	//--------------------------------------------------------------
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:SetDescription(STR0001)   //"Layouts Auxiliares"

	oView:AddField("MIGMASTER_VIEW", oStructMIG, "MIGMASTER" )

	oView:CreateHorizontalBox("PANEL_1", 100)

    oView:SetOwnerView("MIGMASTER_VIEW", "PANEL_1")
  
	oView:SetUseCursor(.T.)
	oView:EnableControlBar(.T.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Mode de Integrações Varejo

@type    function
@return  MpFormModel, Objeto com as configurações do modelo de dados do MVC
@author  Rafael Tenorio da Costa
@since   23/08/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

    Local oStructMIG := NIL
    Local oModel	 := NIL
   
	//-----------------------------------------
	//Monta a estrutura do formulário com base no dicionário de dados
	//-----------------------------------------
	oStructMIG := FWFormStruct(1, "MIG")

    oStructMIG:SetProperty("MIG_TIPCAD", MODEL_FIELD_WHEN, {|| INCLUI})

	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MpFormModel():New("LjLayAux", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:SetDescription(STR0001)  //"Layouts Auxiliares"

	oModel:AddFields("MIGMASTER", /*cOwner*/, oStructMIG, /*Pre-Validacao*/, /*Pos-Validacao*/)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} LjLayAuxCg
Carrega o layout dos cadastros auxiliares

@type    function
@author  Rafael Tenorio da Costa
@since   20/09/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function LjLayAuxCg()

    Local aArea     := GetArea()
    Local aAreaMIG  := MIG->( GetArea() )
    Local aCadAux   := {}
    Local nCont     := 0
    Local oJsonInteg:= LjJsonIntegrity():New()

    Aadd(aCadAux, {"PERFIL DE OPERADOR" , Perfil()      } )
    Aadd(aCadAux, {"OPERADOR DE LOJA"   , Operador()    } )
    Aadd(aCadAux, {"FORMA DE PAGAMENTO" , Pagamento()   } )
    Aadd(aCadAux, {"CADASTRO DE LOJA"   , CadLoja()     } )    
    Aadd(aCadAux, {"COMPARTILHAMENTOS"  , CompLoj()     } )
    Aadd(aCadAux, {"FECP"               , Fecp()        } )
    Aadd(aCadAux, {"PIS/COFINS"         , PisCofins()   } )
    Aadd(aCadAux, {"ICMS"               , Icms()        } )
    Aadd(aCadAux, {"MARCAS"             , Marcas()      } )
    Aadd(aCadAux, {"COMPLEM PAGAMENTO"  , CompFPag()    } )

    MIG->( DbSetOrder(1) )  //MIG_FILIAL + MIG_TIPCAD
    For nCont:=1 To Len(aCadAux)
        If !MIG->( DbSeek( xFilial("MIG") + PadR(aCadAux[nCont][1], TamSx3("MIG_TIPCAD")[1]) ) )

            RecLock("MIG", .T.)
                MIG->MIG_FILIAL := xFilial("MIG")
                MIG->MIG_TIPCAD := aCadAux[nCont][1]
                MIG->MIG_LAYOUT := aCadAux[nCont][2]
            MIG->( MsUnLock() )

        Else

            //Atualiza registro com novos componentes
            If !oJsonInteg:CheckString(aCadAux[nCont][2], MIG->MIG_LAYOUT)
                RecLock("MIG", .F.)
                    MIG->MIG_LAYOUT := oJsonInteg:GetJson(.T.)
                MIG->( MsUnLock() )
            EndIf
        EndIf
    Next nCont

    FwFreeObj(oJsonInteg)

    RestArea(aAreaMIG)
    RestArea(aArea)

Return aCadAux

//-------------------------------------------------------------------
/*/{Protheus.doc} Perfil
Layout do perfil de operador

@type    function
@return  Caractere, Layout do perfil de operador
@author  Rafael Tenorio da Costa
@since   20/09/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function Perfil()

    Local cJson := ""

    BeginContent var cJson
        {
            "Components": [
                {
                    "ContentType": "String",
                    "IdComponent": "Perfil",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "List": null,
                            "Size": "TAMSX3('MIH_DESC')[1]",
                            "F3": null,
                            "Required": false,
                            "Picture": null,
                            "Valid": null,
                            "CanChange": true,
                            "Trigger": 
                                [
                                    {
                                        "FieldTrigger": "MIH_DESC",
                                        "TargetIdField": "MIH_DESC",
                                        "SetValue": "oModel := FWModelActive(),oModel:LoadValue('MIHDETAIL', 'Perfil', M->MIH_DESC )"
                                    }
                                ]
                        },
                        "ComponentLabel": "Perfil"
                    },
                    "ComponentContent": ""
                }
            ],
            "LayoutVersion": 1.2
        }       
    EndContent

Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} Operador
Layout do operador de caixa

@type    function
@return  Caractere, Layout do operador de caixa
@author  Rafael Tenorio da Costa
@since   20/09/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function Operador()

    Local cJson := ""

    BeginContent var cJson
        {
            "Components": [
                {
                    "ContentType": "String",
                    "IdComponent": "nome",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "01",
                            "List": null,
                            "Size": 30,
                            "F3": null,
                            "Required": true,
                            "Picture": null,
                            "Valid": null,
                            "CanChange": true
                        },
                        "ComponentLabel": "Nome"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "String",
                    "IdComponent": "cpf",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "02",
                            "List": null,
                            "Size": 11,
                            "F3": null,
                            "Required": true,
                            "Picture": "@R 999.999.999-99",
                            "Valid": "Cgc(xValor)",
                            "CanChange": true
                        },
                        "ComponentLabel": "CPF"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "String",
                    "IdComponent": "login",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "03",
                            "List": null,
                            "Size": 30,
                            "F3": null,
                            "Required": true,
                            "Picture": null,
                            "Valid": null,
                            "CanChange": true
                        },
                        "ComponentLabel": "Login"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "String",
                    "IdComponent": "senha",
                    "Component": {
                        "ComponentType": "Text",
                        "Parameters": {
                            "Order": "04",
                            "List": null,
                            "Size": 10,
                            "F3": null,
                            "Required": true,
                            "Picture": "@*",
                            "Valid": null,
                            "CanChange": true
                        },
                        "ComponentLabel": "Senha"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "Logical",
                    "IdComponent": "administrador",
                    "Component": {
                        "ComponentType": "CHECKBOX",
                        "Parameters": {
                            "Order": "10",
                            "List": null,
                            "Size": 1,
                            "F3": null,
                            "Required": null,
                            "Picture": null,
                            "Valid": null,
                            "CanChange": true
                        },
                        "ComponentLabel": "Administrador"
                    },
                    "ComponentContent": false
                },
                {
                    "ContentType": "String",
                    "IdComponent": "perfil",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "05",
                            "List": null,
                            "Size": 20,
                            "F3": "{|| LjCadAuxF3('MIH', \"AllTrim(MIH->MIH_TIPCAD) == 'PERFIL DE OPERADOR' .And. MIH->MIH_ATIVO == '1'\", '1')}",
                            "Required": true,
                            "Picture": "@!",
                            "Valid": "ExistCpo('MIH', PadR('PERFIL DE OPERADOR', TamSx3('MIH_TIPCAD')[1]) + xValor, 1)",
                            "CanChange": true
                        },
                        "ComponentLabel": "Id do Perfil"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "String",
                    "IdComponent": "Vendedor",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "09",
                            "List": null,
                            "Size": 6,
                            "F3": "SA3",
                            "Required": false,
                            "Picture": "@!",
                            "Valid": "ExistCpo('SA3',xValor)",
                            "CanChange": true
                        },
                        "ComponentLabel": "Codigo de Vendedor"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "String",
                    "IdComponent": "banco",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "06",
                            "List": null,
                            "Size": 3,
                            "F3": "VRF1",
                            "Required": true,
                            "Picture": "@!",
                            "Valid": "LjAuxMsg(ExistCpo('SA6', xValor), 'banco', 'M1')",
                            "Messages": [
                                {
                                    "Id": "M1",
                                    "Message": "Ops! Código do banco inválido."
                                }
                            ],
                            "CanChange": true,
                            "Trigger": 
                                [
                                    {
                                        "TargetIdField": "agencia",
                                        "SetValue": "Posicione('SA6', 1, xFilial('SA6') + oModel:GetValue('banco'), 'A6_AGENCIA')"
                                    },
                                    {
                                        "TargetIdField": "conta",
                                        "SetValue": "Posicione('SA6', 1, xFilial('SA6') + oModel:GetValue('banco'), 'A6_NUMCON')"
                                    }                                    
                                ]


                        },
                        "ComponentLabel": "Código do Banco"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "String",
                    "IdComponent": "agencia",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "07",
                            "List": null,
                            "Size": 5,
                            "F3": null,
                            "Required": false,
                            "Picture": "@!",
                            "Valid": null,
                            "Messages": [],
                            "CanChange": false
                        },
                        "ComponentLabel": "Número da Agência"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "String",
                    "IdComponent": "conta",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "08",
                            "List": null,
                            "Size": 10,
                            "F3": null,
                            "Required": false,
                            "Picture": "@!",
                            "Valid": null,
                            "Messages": [],
                            "CanChange": false
                        },
                        "ComponentLabel": "Número da Conta"
                    },
                    "ComponentContent": ""
                }                                
            ],
            "LayoutVersion": 2.3
        }    
    EndContent

Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} Pagamento
Layout da forma de pagamento

@type    function
@return  Caractere, Layout da forma de pagamento
@author  Rafael Tenorio da Costa
@since   20/09/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function Pagamento()

    Local cJson := ""

    BeginContent var cJson
        {
            "Components": [
                {
                    "ContentType": "String",
                    "IdComponent": "forma",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "01",
                            "List": null,
                            "Size": 3,
                            "F3": "24",
                            "Required": true,
                            "Picture": null,
                            "Valid": "ExistCpo('SX5', '24' + xValor) .And. LjAuxValid('FORMA DE PAGAMENTO', 'forma', xValor)",
                            "CanChange": true,
                            "Trigger": [
                                {
                                    "TargetIdField": "descricao",
                                    "SetValue": "AllTrim( Posicione('SX5', 1, xFilial('SX5') + '24' + oModel:GetValue('forma'), 'X5_DESCRI') )"
                                }
                            ]
                        },
                        "ComponentLabel": "Forma"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "String",
                    "IdComponent": "descricao",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "02",
                            "List": null,
                            "Size": 40,
                            "F3": null,
                            "Required": false,
                            "Picture": null,
                            "Valid": null,
                            "CanChange": false,
                            "Trigger": null
                        },
                        "ComponentLabel": "Descrição"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "String",
                    "IdComponent": "descricaofiscal",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "03",
                            "List": null,
                            "Size": 20,
                            "F3": null,
                            "Required": true,
                            "Picture": null,
                            "Valid": null,
                            "CanChange": true,
                            "Trigger": null
                        },
                        "ComponentLabel": "Descrição Fiscal"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "Logical",
                    "IdComponent": "permitetroco",
                    "Component": {
                        "ComponentType": "CheckBox",
                        "Parameters": {
                            "Order": "04",
                            "List": null,
                            "Size": 1,
                            "F3": null,
                            "Required": null,
                            "Picture": null,
                            "Valid": null,
                            "CanChange": true,
                            "Trigger": null
                        },
                        "ComponentLabel": "Permite Troco"
                    },
                    "ComponentContent": false
                },
                {
                    "ContentType": "String",
                    "IdComponent": "idFormaPagamentoTroco",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "05",
                            "List": null,
                            "Size": 30,
                            "F3": "{|| LjCadAuxF3('MIH', \"AllTrim(MIH->MIH_TIPCAD) == 'FORMA DE PAGAMENTO' .And. MIH->MIH_ATIVO == '1'\", '1')}",
                            "Required": false,
                            "Picture": "@!",
                            "Valid": "Vazio() .Or. ExistCpo('MIH', PadR('FORMA DE PAGAMENTO', TamSx3('MIH_TIPCAD')[1]) + xValor, 1)",
                            "CanChange": true,
                            "Trigger": null
                        },
                        "ComponentLabel": "Forma Pagamento Troco"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "Number",
                    "IdComponent": "valorminimoaceito",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "06",
                            "List": null,
                            "Size": 16,
                            "F3": null,
                            "Required": true,
                            "Picture": "@E 9,999,999,999,999.99",
                            "Valid": null,
                            "CanChange": true,
                            "Trigger": null
                        },
                        "ComponentLabel": "Valor Minimo Aceito"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "String",
                    "IdComponent": "tipo",
                    "Component": {
                        "ComponentType": "COMBO",
                        "Parameters": {
                            "Order": "07",
                            "Size": 2,
                            "F3": null,
                            "Required": true,
                            "Picture": null,
                            "Valid": null,
                            "CanChange": true,
                            "Trigger": null,
                            "List": [
                                "",
                                "0=OUTROS",
                                "1=DINHEIRO",
                                "2=CREDITO",
                                "3=DEBITO",
                                "4=CHEQUE",
                                "5=POS",
                                "6=TROCA",
                                "8=GIFT",
                                "10=QRCODE"
                            ]
                        },
                        "ComponentLabel": "Tipo Forma Pagamento"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "String",
                    "IdComponent": "condicaoPagamento",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "08",
                            "List": null,
                            "Size": 40,
                            "F3": "{|| LjCadAuxF3('LJF3MU', '', '1', {'AE_COD', 'AE_DESC', 'Condições de Pagamento'})}",
                            "Trigger": null,
                            "Required": false,
                            "Picture": "@S20!",
                            "CanChange": true,
                            "Valid": "LjAuxMsg( At(';', xValor) > 0, 'condicaoPagamento', 'M1')",
                            "Messages": [
                                {
                                    "Id": "M1",
                                    "Message": "Ops! Condições de Pagamento fora do padrão esperado."
                                }
                            ],
                            "IniPad": null
                        },
                        "ComponentLabel": "Condições de Pagamento"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "String",
                    "IdComponent": "camposComplementares",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "09",
                            "List": null,
                            "Size": 70,
                            "F3": "{|| LjCadAuxF3('LJF3MU', \"MIH_TIPCAD = 'COMPLEM PAGAMENTO'\", '1', {'MIH_ID', 'MIH_DESC', 'Campos Complementares'})}",
                            "Trigger": null,
                            "Required": false,
                            "Picture": "@S30!",
                            "CanChange": true,
                            "Valid": "LjAuxMsg( At(';', xValor) > 0, 'camposComplementares', 'M1')",
                            "Messages": [
                                {
                                    "Id": "M1",
                                    "Message": "Ops! Campos Complementares fora do padrão esperado."
                                }
                            ],
                            "IniPad": null
                        },
                        "ComponentLabel": "Campos Complementares"
                    },
                    "ComponentContent": ""
                }
            ],
            "LayoutVersion": 2.0
        }
    EndContent

Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} CadLoja
Layout da forma de CadLoja

@type    function
@return  Caractere, Layout da forma de pagamento
@author  Rafael Tenorio da Costa
@since   20/09/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function CadLoja()

    Local cJson := ""

    BeginContent var cJson
        {
        "Components": [
            {
                "ContentType": "String",
                "IdComponent": "CodigoMaster",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "01",
                        "List": null,
                        "Size": "Len(FwCodEmp())",
                        "F3": null,
                        "Required": true,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": "FwCodEmp()",
                        "CanChange": false,
                        "Trigger": null
                    },
                    "ComponentLabel": "Codigo Master"
                },
                "ComponentContent": ""
            },
            {
                "ContentType": "String",
                "IdComponent": "NomeMaster",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "02",
                        "List": null,
                        "Size": "Len(FwGrpName())",
                        "F3": null,
                        "Required": true,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": "FwGrpName()",
                        "CanChange": false,
                        "Trigger": null
                    },
                    "ComponentLabel": "Nome Master"
                },
                "ComponentContent": ""
            },
            {
                "ContentType": "String",
                "IdComponent": "IDFilialProtheus",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "03",
                        "List": null,
                        "Size": "FWSizeFilial()",
                        "F3": "SM0",
                        "Required": true,
                        "Picture": null,
                        "Valid": "FWFilExist(,xValor) .And. LjAuxMsg(LjAuxValid('CADASTRO DE LOJA','IDFilialProtheus',xValor),'IDFilialProtheus','M1')",
                        "IniPad": null,
                        "CanChange": true,
                        "Trigger": [
                            {
                                "TargetIdField": "RazaoSocial",
                                "SetValue": "Alltrim(SM0->M0_NOMECOM)"
                            },
                            {
                                "TargetIdField": "NomeFantasia",
                                "SetValue": "Alltrim(SM0->M0_NOME)"
                            },
                            {
                                "TargetIdField": "CNPJ",
                                "SetValue": "Alltrim(SM0->M0_CGC)"
                            },
                            {
                                "TargetIdField": "InscricaoEstadual",
                                "SetValue": "Alltrim(SM0->M0_INSC)"
                            },
                            {
                                "TargetIdField": "InscricaoMunicipal",
                                "SetValue": "Alltrim(SM0->M0_INSCM)"
                            },
                            {
                                "TargetIdField": "Endereco",
                                "SetValue": "Alltrim(SM0->M0_ENDENT)"
                            },
                            {
                                "TargetIdField": "Complemento",
                                "SetValue": "Alltrim(SM0->M0_COMPENT)"
                            },
                            {
                                "TargetIdField": "Bairro",
                                "SetValue": "Alltrim(SM0->M0_BAIRENT)"
                            },
                            {
                                "TargetIdField": "Cidade",
                                "SetValue": "Alltrim(SM0->M0_CIDENT)"
                            },
                            {
                                "TargetIdField": "Estado",
                                "SetValue": "Alltrim(SM0->M0_ESTENT)"
                            },
                            {
                                "TargetIdField": "CodigoMunicipio",
                                "SetValue": "Alltrim(SM0->M0_CODMUN)"
                            },
                            {
                                "TargetIdField": "CEP",
                                "SetValue": "Alltrim(SM0->M0_CEPENT)"
                            },
                            {
                                "TargetIdField": "Telefone",
                                "SetValue": "Alltrim(SM0->M0_TEL)"
                            }
                        ],
                        "Messages": [
                            {
                                "Id": "M1",
                                "Message": "Filial Protheus já cadastrada."
                            }
                        ]
                    },
                    "ComponentLabel": "Filial"
                },
                "ComponentContent": ""
            },
            {
                "ContentType": "String",
                "IdComponent": "RazaoSocial",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "04",
                        "List": null,
                        "Size": 20,
                        "F3": "",
                        "Required": true,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": false,
                        "Trigger": null
                    },
                    "ComponentLabel": "Razao Social"
                },
                "ComponentContent": ""
            },
            {
                "ContentType": "String",
                "IdComponent": "NomeFantasia",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "05",
                        "List": null,
                        "Size": 20,
                        "F3": "",
                        "Required": true,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": false,
                        "Trigger": null
                    },
                    "ComponentLabel": "Nome Fantasia"
                },
                "ComponentContent": ""
            },
            {
                "ContentType": "String",
                "IdComponent": "CNPJ",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "06",
                        "List": null,
                        "Size": 20,
                        "F3": "",
                        "Required": true,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": false,
                        "Trigger": null
                    },
                    "ComponentLabel": "CNPJ Loja"
                },
                "ComponentContent": ""
            },
            {
                "ContentType": "String",
                "IdComponent": "InscricaoEstadual",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "07",
                        "List": null,
                        "Size": 14,
                        "F3": "",
                        "Required": false,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": true,
                        "Trigger": null
                    },
                    "ComponentLabel": "Inscrição Estadual"
                },
                "ComponentContent": ""
            },
            {
                "ContentType": "String",
                "IdComponent": "InscricaoMunicipal",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "08",
                        "List": null,
                        "Size": 25,
                        "F3": "",
                        "Required": false,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": true,
                        "Trigger": null
                    },
                    "ComponentLabel": "Inscrição Municipal"
                },
                "ComponentContent": ""
            },
            {
                "ContentType": "String",
                "IdComponent": "Endereco",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "09",
                        "List": null,
                        "Size": 60,
                        "F3": "",
                        "Required": false,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": true,
                        "Trigger": null
                    },
                    "ComponentLabel": "Endereço"
                },
                "ComponentContent": ""
            },
            {
                "ContentType": "String",
                "IdComponent": "Complemento",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "10",
                        "List": null,
                        "Size": 25,
                        "F3": "",
                        "Required": false,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": true,
                        "Trigger": null
                    },
                    "ComponentLabel": "Complemento"
                },
                "ComponentContent": ""
            },
            {
                "ContentType": "String",
                "IdComponent": "Bairro",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "11",
                        "List": null,
                        "Size": 35,
                        "F3": "",
                        "Required": false,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": true,
                        "Trigger": null
                    },
                    "ComponentLabel": "Bairro"
                },
                "ComponentContent": ""
            },
            {
                "ContentType": "String",
                "IdComponent": "Cidade",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "12",
                        "List": null,
                        "Size": 35,
                        "F3": "",
                        "Required": false,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": true,
                        "Trigger": null
                    },
                    "ComponentLabel": "Cidade"
                },
                "ComponentContent": ""
            },
            {
                "ContentType": "String",
                "IdComponent": "Estado",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "13",
                        "List": null,
                        "Size": 2,
                        "F3": "",
                        "Required": false,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": true,
                        "Trigger": null
                    },
                    "ComponentLabel": "Estado"
                },
                "ComponentContent": ""
            },
            {
                "ContentType": "String",
                "IdComponent": "CodigoMunicipio",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "14",
                        "List": null,
                        "Size": 7,
                        "F3": "",
                        "Required": false,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": true,
                        "Trigger": null
                    },
                    "ComponentLabel": "Codigo Municipio"
                },
                "ComponentContent": ""
            },
            {
                "ContentType": "String",
                "IdComponent": "CEP",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "15",
                        "List": null,
                        "Size": 8,
                        "F3": "",
                        "Required": false,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": true,
                        "Trigger": null
                    },
                    "ComponentLabel": "CEP"
                },
                "ComponentContent": ""
            },
            {
                "ContentType": "String",
                "IdComponent": "Telefone",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "16",
                        "List": null,
                        "Size": 14,
                        "F3": "",
                        "Required": false,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": true,
                        "Trigger": null
                    },
                    "ComponentLabel": "Telefone"
                },
                "ComponentContent": ""
            },
            {
                "ContentType": "String",
                "IdComponent": "CodigoIdentificacaoLoja",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "17",
                        "List": null,
                        "Size": 20,
                        "F3": "",
                        "Required": true,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": true,
                        "Trigger": null
                    },
                    "ComponentLabel": "Codigo Identificacao Loja"
                },
                "ComponentContent": ""
            },
            {
                "ContentType": "String",
                "IdComponent": "ModeloFiscal",
                "Component": {
                    "ComponentType": "COMBO",
                    "Parameters": {
                        "Order": "18",
                        "Size": 16,
                        "F3": null,
                        "Required": true,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": true,
                        "Trigger": null,
                        "List": [
                            "",
                            "Nao Configurado",
                            "SAT",
                            "NFCe",
                            "MFE"
                        ]
                    },
                    "ComponentLabel": "Modelo Fiscal"
                },
                "ComponentContent": ""
            },
            {
                "ContentType": "String",
                "IdComponent": "RegimeTributario",
                "Component": {
                    "ComponentType": "COMBO",
                    "Parameters": {
                        "Order": "19",
                        "Size": 30,
                        "F3": "",
                        "Required": true,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": "Alltrim(SuperGetMV('MV_CODREG',.F.))",
                        "CanChange": true,
                        "Trigger": null,
                        "List": [
                            "",
                            "1=Simples Nacional",
                            "2=Simples Naci Exc-Rece-Bru",
                            "3=Regime Nacional"
                        ]
                    },
                    "ComponentLabel": "Regime Tributario"
                },
                "ComponentContent": ""
            },
            {
                "ContentType": "String",
                "IdComponent": "NumeroLoja",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "20",
                        "List": null,
                        "Size": 20,
                        "F3": "",
                        "Required": true,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": true,
                        "Trigger": null
                    },
                    "ComponentLabel": "Numero da Loja"
                },
                "ComponentContent": ""
            }
        ],
        "LayoutVersion": 1.0
    }
    EndContent

Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} CompLoj
Layout da forma de Compartilhamento de Lojas

@type    function
@return  Caractere, Layout da forma de Compartilhamento de Lojas
@author  Evandro Pattaro
@since   20/09/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function CompLoj()

    Local cJson := ""

    BeginContent var cJson
        {
            "Components": [                
                {
                    "ContentType": "String",
                    "IdComponent": "IdProprietario",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "List": null,
                            "Size": 6,
                            "F3": null,
                            "Required": true,
                            "Picture": "999999",
                            "Valid": null,
                            "IniPad": "M->MIH_ID",                            
                            "CanChange": false,
                            "Trigger": null
                        },
                        "ComponentLabel": "ID Proprietário"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "String",
                    "IdComponent": "NomeCompartilha",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "List": null,
                            "Size": 30,
                            "F3": null,
                            "Required": true,
                            "Picture": null,
                            "Valid": null,
                            "CanChange": true,
                            "Trigger": null
                        },
                        "ComponentLabel": "Nome Compartilhamento"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "String",
                    "IdComponent": "nivel",
                    "Component": {
                        "ComponentType": "COMBO",
                        "Parameters": {
                            "Size": 1,
                            "F3": null,
                            "Required": true,
                            "Picture": null,
                            "Valid": "IIf (xValor == '0',LjAuxMsg(LjAuxValid('COMPARTILHAMENTOS','nivel',xValor),'nivel','M1'),IIf(xValor $ '1|2',LjAuxMsg(!LjAuxValid('COMPARTILHAMENTOS','nivel','0'),'nivel','M2'),.T.))",
                            "CanChange": true,
                            "Trigger": 
                                [
                                    {
                                        "TargetIdField": "IdRetaguardaPai",
                                        "SetValue": "IIf(oModel:GetValue('nivel') == '1',LjAuxPosic('COMPARTILHAMENTOS','nivel','0','IdProprietario'),'')"
                                    }
                                ],
                            "List": [
                                " ",
                                "0",
                                "1",
                                "2"
                            ], 
                            "Messages":
                            [
                               {
                                "Id":"M1",
                                "Message":"Compartilhamento de nível 0 já existente."
                               },
                               {"Id":"M2",
                               "Message":"Compartilhamento de nível 0 não existe."
                               }     
                            ]
                        },
                        "ComponentLabel": "Nível"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "String",
                    "IdComponent": "IdRetaguardaPai",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "List": null,
                            "Size": 6,
                            "F3": "{|| LjCadAuxF3('MIH', \"AllTrim(MIH->MIH_TIPCAD) == 'COMPARTILHAMENTOS' .And. MIH->MIH_ATIVO == '1'\", '1')}",
                            "Required": false,
                            "Picture": "999999",
                            "Valid": "IIf(oModel:GetValue('nivel') == '2',LjAuxMsg(LjAuxPosic('COMPARTILHAMENTOS','IdProprietario',xValor,'nivel') != '0','IdRetaguardaPai','M1'),.T.)",
                            "CanChange": "IIf(oModel:GetValue('nivel') == '2',.T.,.F.)",
                            "Trigger": 
                                [
                                    {
                                    "TargetIdField": "CodigoLoja",
                                    "SetValue": "IIf(oModel:GetValue('nivel') == '1','',oModel:GetValue('CodigoLoja'))"
                                    }
                                ],
                            "Messages":
                            [
                               {
                                "Id":"M1",
                                "Message":"Não é permitido IdRetaguardaPai de nível 0 quando cadastro for de nível 2"
                               }
                            ]                            
                        },
                        "ComponentLabel": "Id Retaguarda Pai"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "String",
                    "IdComponent": "CodigoLoja",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "List": null,
                            "Size": 6,
                            "F3": "{|| LjCadAuxF3('MIH', \"AllTrim(MIH->MIH_TIPCAD) == 'CADASTRO DE LOJA' .And. MIH->MIH_ATIVO == '1'\", '1')}",
                            "Required": false,
                            "Picture": null,
                            "Valid": null,
                            "CanChange": "IIf(oModel:GetValue('nivel') == '2',.T.,.F.)",
                            "Trigger": null
                        },
                        "ComponentLabel": "Codigo da Loja"
                    },
                    "ComponentContent": ""
                }
            ],
            "LayoutVersion": 1.0
        }         
    EndContent

Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} Fecp
Layout do imposto Fecp

@type    function
@return  Caractere, imposto Fecp
@author  Rafael Tenorio da Costa
@since   05/11/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function Fecp()

    Local cJson := ""

    BeginContent var cJson
        {
            "Components": [                
                {
                    "ContentType": "Number",
                    "IdComponent": "IT_ALIQFECP",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "01",
                            "List": null,
                            "Size": 4,
                            "F3": null,
                            "Required": false,
                            "Picture": "@E 99.99",
                            "Valid": null,
                            "IniPad": null,
                            "CanChange": false,
                            "Trigger": null
                        },
                        "ComponentLabel": "Alíquota FECP"
                    },
                    "ComponentContent": 0
                },
                {
                    "ContentType": "Number",
                    "IdComponent": "IT_BASFECP",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "02",
                            "List": null,
                            "Size": 14,
                            "F3": null,
                            "Required": false,
                            "Picture": "@E 99,999,999,999.99",
                            "Valid": null,
                            "IniPad": null,
                            "CanChange": false,
                            "Trigger": null
                        },
                        "ComponentLabel": "Base FECP"
                    },
                    "ComponentContent": 0
                }, 
                {
                    "ContentType": "Number",
                    "IdComponent": "IT_CODDECL",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "03",
                            "List": null,
                            "Size": 8,
                            "F3": null,
                            "Required": false,
                            "Picture": null,
                            "Valid": null,
                            "IniPad": null,
                            "CanChange": false,
                            "Trigger": null
                        },
                        "ComponentLabel": "Código Benefício Fiscal"
                    },
                    "ComponentContent": ""
                },   
            {
                "ContentType": "Number",
                "IdComponent": "LF_MOTICMS",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "04",
                        "List": null,
                        "Size": 8,
                        "F3": null,
                        "Required": false,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": false,
                        "Trigger": null
                    },
                    "ComponentLabel": "Motivo Desoneracao"
                },
                "ComponentContent": 0
            },
            {
                "ContentType": "Logical",
                "IdComponent": "descontaDesoneracaoNf",
                "Component": {
                    "ComponentType": "CheckBox",
                    "Parameters": {
                        "List": null,
                        "Size": 1,
                        "F3": null,
                        "Required": null,
                        "Picture": null,
                        "Valid": null,
                        "CanChange": true,
                        "Trigger": null
                    },
                    "ComponentLabel": "Desconta desoneração ICMS"
                },
                "ComponentContent": true
            }                                               
            ],
            "LayoutVersion": 1.0
        }         
    EndContent

Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} PisCofins
Layout do imposto PIS/COFINS

@type    function
@return  Caractere, imposto PIS/COFINS
@author  Lucas Novais (lNovais@)
@since   16/11/21
@version 12.1.37
/*/
//-------------------------------------------------------------------
Static Function PisCofins()

    Local cJson := ""

    BeginContent var cJson
        {
            "Components": [                
                {
                    "ContentType": "String",
                    "IdComponent": "LF_CSTPIS",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "01",
                            "List": null,
                            "Size": 2,
                            "F3": null,
                            "Required": false,
                            "Picture": "@E 99",
                            "Valid": null,
                            "IniPad": null,
                            "CanChange": false,
                            "Trigger": null
                        },
                        "ComponentLabel": "Sit. Trib. PIS"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "Number",
                    "IdComponent": "IT_ALIQPIS",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "02",
                            "List": null,
                            "Size": 2,
                            "F3": null,
                            "Required": false,
                            "Picture": "@E 99.99",
                            "Valid": null,
                            "IniPad": null,
                            "CanChange": false,
                            "Trigger": null
                        },
                        "ComponentLabel": "Alíquota PIS"
                    },
                    "ComponentContent": 0
                }, 
                {
                    "ContentType": "String",
                    "IdComponent": "LF_CSTCOF",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "03",
                            "List": null,
                            "Size": 2,
                            "F3": null,
                            "Required": false,
                            "Picture": "@E 99",
                            "Valid": null,
                            "IniPad": null,
                            "CanChange": false,
                            "Trigger": null
                        },
                        "ComponentLabel": "Sit. Trib. COFINS"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "Number",
                    "IdComponent": "IT_ALIQCOF",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "04",
                            "List": null,
                            "Size": 2,
                            "F3": null,
                            "Required": false,
                            "Picture": "@E 99.99",
                            "Valid": null,
                            "IniPad": null,
                            "CanChange": false,
                            "Trigger": null
                        },
                        "ComponentLabel": "Alíquota COFINS"
                    },
                    "ComponentContent": ""
                }                 
            ],
            "LayoutVersion": 1.0
        }         
    EndContent

Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} Icms
Layout do imposto ICMS

@type    function
@return  Caractere, imposto ICMS
@author  Danilo Rodrigues
@since   17/11/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function Icms()

    Local cJson := ""

    BeginContent var cJson
    {
        "Components": [                
            {
                "ContentType": "Number",
                "IdComponent": "IT_ALIQICM",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "01",
                        "List": null,
                        "Size": 4,
                        "F3": null,
                        "Required": false,
                        "Picture": "@E 99.99",
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": false,
                        "Trigger": null
                    },
                    "ComponentLabel": "Alíquota Tributo"
                },
                "ComponentContent": 0
            },
			{
                "ContentType": "String",
                "IdComponent": "Tipo",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "02",
                        "List": [
                            "",
                            "0=ICMS",
                            "1=ISS"
                        ],
                        "Size": 20,
                        "F3": null,
                        "Required": false,
                        "Picture": "@!",
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": false,
                        "Trigger": null
                    },
                    "ComponentLabel": "Tipo"
                },
                "ComponentContent": "0"
            },
            {
                "ContentType": "String",
                "IdComponent": "Modalidade",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "03",
                        "List": null,
                        "Size": 30,
                        "F3": null,
                        "Required": false,
                        "Picture": "@!",
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": false,
                        "Trigger": null
                    },
                    "ComponentLabel": "Modalidade"
                },
                "ComponentContent": ""
            }, 
            {
                "ContentType": "Number",
                "IdComponent": "IT_PREDIC",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "04",
                        "List": null,
                        "Size": 4,
                        "F3": null,
                        "Required": false,
                        "Picture": "@E 99.99",
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": false,
                        "Trigger": null
                    },
                    "ComponentLabel": "Redução Base de Calculo"
                },
                "ComponentContent": ""
            },
			{
                "ContentType": "String",
                "IdComponent": "Simbolo",
                "Component": {
                    "ComponentType": "GET",
                    "Parameters": {
                        "Order": "05",
                        "List": null,
                        "Size": 8,
                        "F3": null,
                        "Required": false,
                        "Picture": null,
                        "Valid": null,
                        "IniPad": null,
                        "CanChange": false,
                        "Trigger": null
                    },
                    "ComponentLabel": "Simbolo"
                },
                "ComponentContent": ""
            }               
        ],
        "LayoutVersion": 1.0
    }         
    EndContent

Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} Marcas
Layout de marcas

@type    function
@return  Caractere, marcas
@author  Bruno Almeida
@since   25/11/21
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function Marcas()

    Local cJson := ""

    BeginContent var cJson
        {
            "Components": [                
                {
                    "ContentType": "String",
                    "IdComponent": "Marca",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "01",
                            "List": null,
                            "Size": "TamSx3('B5_MARCA')[1]",
                            "F3": null,
                            "Required": false,
                            "Picture": "@!",
                            "Valid": null,
                            "IniPad": null,
                            "CanChange": false,
                            "Trigger": null
                        },
                        "ComponentLabel": "Marca"
                    },
                    "ComponentContent": ""
                }               
            ],
            "LayoutVersion": 1.0
        }         
    EndContent

Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} Complemento de Forma de Pagamento
Layout Complemento de Forma de Pagamento

@type    function
@return  Caractere, marcas
@author  Danilo Rodrigues
@since   30/05/22
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function CompFPag()

    Local cJson := ""

    BeginContent var cJson
        {
            "Components": [
                {
                    "ContentType": "String",
                    "IdComponent": "descricao",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "01",
                            "List": null,
                            "Size": 30,
                            "Trigger": null,
                            "F3": null,
                            "Required": true,
                            "Picture": null,
                            "CanChange": true,
                            "Valid": null,
                            "IniPad": null
                        },
                        "ComponentLabel": "Descrição"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "String",
                    "IdComponent": "tipo",
                    "Component": {
                        "ComponentType": "COMBO",
                        "Parameters": {
                            "Order": "02",                            
                            "Size": 1,
                            "F3": null,
                            "Required": true,
                            "Picture": null,
                            "Valid": null,
                            "CanChange": true,
                            "Trigger": null,
                            "List": [
                                "",
                                "0=Alfanumerico",
                                "1=Numerico",
                                "2=Data",
                                "3=ListaSelecao"
                            ]
                        },
                        "ComponentLabel": "Tipo"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "Number",
                    "IdComponent": "tamanho",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "03",                            
                            "Size": 5,
                            "F3": null,
                            "Required": true,
                            "Picture": "@E 99999",
                            "Valid": null,
                            "CanChange": true,
                            "Trigger": null,
                            "List": null
                        },
                        "ComponentLabel": "Tamanho"
                    },
                    "ComponentContent": ""
                },                
                {
                    "ContentType": "String",
                    "IdComponent": "obrigatorio",
                    "Component": {
                        "ComponentType": "COMBO",
                        "Parameters": {
                            "Order": "04",                            
                            "Size": 1,
                            "F3": null,
                            "Required": true,
                            "Picture": null,
                            "Valid": null,
                            "CanChange": true,
                            "Trigger": null,
                            "List": [
                                "",
                                "0=Sim",
                                "1=Não"
                            ]
                        },
                        "ComponentLabel": "Obrigatorio"
                    },
                    "ComponentContent": ""
                },
                {
                    "ContentType": "String",
                    "IdComponent": "campoProtheus",
                    "Component": {
                        "ComponentType": "GET",
                        "Parameters": {
                            "Order": "05",
                            "List": null,
                            "Size": 10,
                            "F3": "SX3SL4",
                            "Trigger": null,
                            "Required": true,
                            "Picture": "@!",
                            "CanChange": true,
                            "Valid": "LjAuxMsg( SL4->( ColumnPos(xValor) ) > 0, 'campoProtheus', 'M1')",
                            "Messages": [
                                {
                                    "Id": "M1",
                                    "Message": "Ops! Campo inválido, apenas são permitidos campos que existem na tabela SL4."
                                }
                            ],
                            "IniPad": null
                        },
                        "ComponentLabel": "Campo para Gravação"
                    },
                    "ComponentContent": ""
                }
            ],
            "LayoutVersion": 2.0
        }
    EndContent

Return cJson