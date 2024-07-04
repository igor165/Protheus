#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "FISA210.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA210()

Esta rotina tem objetivo de realizar o cadastro das regras de apurções
para os tibutos genéricos

@author Erick G Dias
@since 30/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA210()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F2Z")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F2Z")
    oBrowse:SetDescription(STR0001)//"Ajustes de Base de Cálculo de PIS e COFINS"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0)//"Dicionário desatualizado, favor verificar atualização da EFD Contribuições"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erick G Dias
@since 30/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA210" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do cadastro das regras de apuração

@author Erick G Dias
@since 30/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai do cabeçalho da rotina
Local oCabecalho := FWFormStruct(1, "F2Z" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA210' , , , {|oModel| SaveModel(oModel)})

//Atribuindo cabeçalho para o modelo
oModel:AddFields("FISA210",,oCabecalho)

oModel:SetPrimaryKey( {"F2Z_FILIAL","F2Z_ID"} )

//Adicionando descrição ao modelo
oModel:SetDescription(STR0001)  //"Ajustes de Base de Cálculo de PIS e COFINS"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Erick G Dias    
@since 30/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA210" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "F2Z")
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho , 'FISA210' )

// Retirando campo de ID e origem da view.
oCabecalho:RemoveField( 'F2Z_ID'  )
oCabecalho:RemoveField( 'F2Z_ORIG'  )
oCabecalho:RemoveField( 'F2Z_CONSOL' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA210CDAJ
Função responsável por montar as opções do combo de ajuste da base de cálculo
de PIS e COFINS, com os códigos disponíveis na tabela 4.3.18

@author Erick G Dias    
@since 31/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA210CDAJ()                                                                                                                   

Local cRet  := ""

cRet	:= '01=Vendas Canceladas de Receitas Tributadas em períodos anteriores;'
cRet	+= '02=Devoluções de vendas tributadas em períodos anteriores;'
cRet	+= '21=ICMS a recolher sobre Operações Próprias;'
cRet	+= '41=Outros valores a exclur, vinculados a decisão judicial;'
cRet	+= '42=Outros valores a excluir, não vinculados a decisão judicial'

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@Param  oModel -> Modelo de dados

@Return .T.

@Author Anderson Costa
@Since 24/06/2014
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )
Local aArea      := GetArea()
Local nOperation := oModel:GetOperation()
Local lRet       := .T.
Local lRecLock   := nOperation == MODEL_OPERATION_INSERT
Local a1050      := {}
Local nValAjust  := 0
Local dPeriodo   := Ctod("")
Local dPerOld    := Ctod("")
Local cCodAjust  := ""
Local cCodAjOld  := ""
Local cCST       := ""
Local cCodCont   := ""
Local cCnpj      := ""
Local cCnpjOld   := ""
Local cAprop     := ""
Local cApropOld  := ""
Local cNumRec    := ""
Local cInfCompl  := ""

cCodAjust := oModel:GetValue("FISA210","F2Z_CODAJU")
dPeriodo  := oModel:GetValue("FISA210","F2Z_DTREF")
nValAjust := oModel:GetValue("FISA210","F2Z_VALAJU")
cCnpj     := oModel:GetValue("FISA210","F2Z_CNPJ")
cNumRec   := oModel:GetValue("FISA210","F2Z_NUM")
cInfCompl := oModel:GetValue("FISA210","F2Z_COMPL")
cCodCont  := oModel:GetValue("FISA210","F2Z_CODCON")
cAprop    := IIf(oModel:GetValue("FISA210","F2Z_TRIB") == "1","02","03")

// Verifico se algum campo chve da busca sofreu alteração, para utilizar o valor gravado na tabela F3P para efetuar o Seek.
dPerOld   := F2Z->F2Z_DTREF
cCodAjOld := F2Z->F2Z_CODAJU
cCnpjOld  := F2Z->F2Z_CNPJ
cApropOld := IIf(F2Z->F2Z_TRIB == "1","02","03")

If cCodAjust == "21" .Or. cCodAjOld == "21"

    If cCodAjust <> "21" // Caso o código de ajuste seja alterado, será feito somente a exclusão da F3P.
        nOperation := MODEL_OPERATION_DELETE 
    EndIf

    // Em caso de exclusão ou alteração, é feito exclusão do registro anterior
    If nOperation <> MODEL_OPERATION_INSERT

        If F3P->(MsSeek(xFilial("F3P") + dTos(dPerOld) + cCodAjOld + cCnpjOld + cApropOld))

            If nOperation == MODEL_OPERATION_DELETE 
                RecLock("F3P",lRecLock)
                F3P->(dbDelete())
                F3P->(MsUnLock())
            EndIf

        ElseIf nOperation == MODEL_OPERATION_UPDATE .And. cCodAjust == "21" //Somente será gerado o arquivo na F3P se o código de ajuste for 21.

            lRecLock := .T. //Caso o registro não seja identificado na F3P, será dado um Insert.

        EndIF

    EndIf

    If nOperation <> MODEL_OPERATION_DELETE

        // O CST abaixo está sendo preenchido de acordo com a tabela Tabela 4.3.5 – "Código de Contribuição Social Apurada” que está correlacionada com o CST.
        Do Case
            Case cCodCont $ "01|51|04|54"
                cCST := "01"
            Case cCodCont $ "02|52"
                cCST := "02"
            Case cCodCont $ "03|53"
                cCST := "03"
            Case cCodCont $ "31|32"
                cCST := "05"
        EndCase

        If !Empty(cCST)

            RecLock('F3P',lRecLock)
            F3P->F3P_FILIAL	:= xFilial("F3P")
            F3P->F3P_PER   	:= dPeriodo
            F3P->F3P_CONSOL := "2"
            F3P->F3P_CODAJU := "21"
            F3P->F3P_CNPJ   := cCnpj
            F3P->F3P_INDAP  := cAprop
            F3P->F3P_RECIBO := cNumRec
            F3P->F3P_INFCOM := cInfCompl
            F3P->F3P_TOTAJU	:= nValAjust
            If F3P->(FieldPos("F3P_AJMANU")) > 0
                F3P->F3P_AJMANU := "1"
            EndIf
            &("F3P->F3P_CST" + cCST) := nValAjust
            F3P->(MsUnLock())
        EndIf

    EndIf
EndIf

FwFormCommit( oModel )

RestArea( aArea )

Return ( lRet )