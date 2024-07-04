#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "FISA300H.ch" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA300H()

Rotina para cadastro dos valores mensais para cálculo da sociedade uiniprofissional,
são valores fixos estabelecidos pela prefeitura

@author Erick G. Dias
@since 02/07/2019
@version 12.1.23
/*/
//-------------------------------------------------------------------
Function FISA300H()

Local   oBrowse := Nil

//Verifico se a tabela existe antes de prosseguir
IF AliasIndic('F1U')
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F1U")
    oBrowse:SetDescription(STR0001)//"Valores Fixos da Sociedade Uniprofissional"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0)//"Dicionário desatualizado, favor verificar atualizações da apuração de ISS referente ao Bloco B da EFD ICMS/IPI."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erick G Dias
@since 02/07/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA300H" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo da rotina de cadastro

@author Erick G Dias
@since 02/07/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil

//Estrutura da tabela F1U
Local oValorFixo := FWFormStruct(1, "F1U" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA300H',/*Pre-Validacao*/,{|oModel|VALIDACAO(oModel) })

//Não permite alterar a UF, código de município e data inicial de vigência
oValorFixo:SetProperty('F1U_UF'     , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })
oValorFixo:SetProperty('F1U_CODMUN' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })
oValorFixo:SetProperty('F1U_DTINI'  , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })

//Atribuindo cabeçalho para o modelo
oModel:AddFields("FISA300H",,oValorFixo)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Erick G Dias
@since 02/07/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA300H" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oValorFixo := FWFormStruct(2, "F1U")
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField( 'VIEW_ABA' , oValorFixo , 'FISA300H' )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} VldVigencia
Função que realiza a validação de vigência do sócio.

@author Erick G Dias
@since 02/07/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function VldVigencia(cUF, cCodMun, dDtIni, dDtFim, lEdit)

Local lRet      := .F.
Local cSelect	:= ""
Local cFrom	    := ""
Local cWhere	:= ""
Local cAliasQry	:= ""

//Query filtrando o CPF
cSelect := "F1U.F1U_VALOR"
cFrom   += RetSQLName("F1U") + " F1U "
cWhere  += "F1U.F1U_FILIAL = " + ValToSQL(xFilial("F1U")) + " AND "
cWhere  += "F1U.F1U_UF = " + ValToSQL(cUF) + " AND "
cWhere  += "F1U.F1U_CODMUN = " + ValToSQL(cCodMun) + " AND "

cWhere  += "( "

//Verifica se está compreendido em cadastro somente com data inicial preenchida
cWhere  += "( " + ValToSQL(dDtIni) + " >= F1U.F1U_DTINI  AND F1U.F1U_DTFIM = ' ' ) OR"
//Verifica se a data inicial está compreenchida em algum cadastro como data inicial e final informados
cWhere  += "( " + ValToSQL(dDtIni) + " >= F1U.F1U_DTINI  AND " + ValToSQL(dDtIni) + " <= F1U.F1U_DTFIM ) "

//Tratamento para data final
IF Empty(dDtFim)
    //Se no cadastro não foi informado a data final, então verificará se já existe no cadastro alguma linha sem data final preenchida
    cWhere  += " OR ( F1U.F1U_DTFIM = ' ' ) "
ElseIf !Empty(dDtFim)
    //Caso a data final seja informada então verificaremos se está´comprendida em algum cadastro com data inicial e final preenchidos.
    cWhere  += " OR ( " + ValToSQL(dDtFim) + " >= F1U.F1U_DTINI  AND " + ValToSQL(dDtFim) + " <= F1U.F1U_DTFIM ) "
    cWhere  += " OR ( " + ValToSQL(dDtFim) + " >= F1U.F1U_DTINI  AND F1U.F1U_DTFIM = ' ') "
EndIF

cWhere  += " ) AND " 

If lEdit
    //Se for edição desconsiderarei a linha editada, para não entrar em conflito com ela mesma
    cWhere  += " F1U.R_E_C_N_O_ <> " + ValtoSql(F1U->(recno())) + " AND "
EndIF

cWhere  += "F1U.D_E_L_E_T_ = ' '"		
cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + "%"

cAliasQry := GetNextAlias()

BeginSQL Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%

EndSQL

IF !(cAliasQry)->(Eof())
    //já existe regra cadastrada para esta vigência
    lRet    := .T.
EndIF

dbSelectArea(cAliasQry)
dbCloseArea()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VALIDACAO
Validação do modelo

@author Erick G Dias
@since 02/07/2019
@version P12.1.23
/*/
//-------------------------------------------------------------------
Static Function VALIDACAO(oModel)

Local lRet          := .T.
Local cUF           := oModel:GetValue ('FISA300H',"F1U_UF" )
Local cCodMun       := oModel:GetValue ('FISA300H',"F1U_CODMUN" )
Local dDtIni        := oModel:GetValue ('FISA300H',"F1U_DTINI" )
Local dDtFim        := oModel:GetValue ('FISA300H',"F1U_DTFIM" )
Local nOperation    := oModel:GetOperation()

//Verifica se o CPF já está cadastrado com mesma data de vigência
IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

    If VldVigencia(cUF,cCodMun, dDtIni, dDtFim, nOperation == MODEL_OPERATION_UPDATE)
        lRet:= .F.
        Help( ,, 'Help',, STR0003 , 1, 0 ) //"Valor para município já cadastrado para vigência informada"
    EndIF

EndiF

Return lRet 