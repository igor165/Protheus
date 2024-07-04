#Include "Protheus.ch"
#Include 'FWMVCDef.ch'
#Include 'FWBrowse.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFMigr004
Browse com as funcionalidades de processamento dos registros rejeitados
@author  Nicholas Washington
@since   31/03/2020
@version 1
/*/
//-------------------------------------------------------------------
Function TAFMigr004()

Local oBrowse := FWmBrowse():New()

oBrowse:SetDescription( "Migrador TAF" )
oBrowse:SetAlias("V2A")
oBrowse:SetMenuDef("TAFMigr004")

oBrowse:Activate()

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu
@author  Nicholas Washington
@since   31/03/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina  := {}

ADD OPTION aRotina Title "Pesquisar"        Action "PesqBrw"             	OPERATION 1  ACCESS  0
ADD OPTION aRotina Title "Visualizar"       Action "VIEWDEF.TAFMigr004"  	OPERATION 2  ACCESS  0
 
Return aRotina 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo
@author  Nicholas Washington
@since   31/03/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel  := Nil
Local oStruct := FWFormStruct(1, "V2A")

oModel := MPFormModel():New("MODEL_V2A", /*bPre*/, /*bTudoOk*/ ) 
oModel:AddFields("V2AMASTER",,oStruct)
  
//Setando as descrições
oModel:SetDescription("Seleção de Registros Inconsistentes")
oModel:GetModel("V2AMASTER"):SetDescription("Migrador eSocial")

oModel:SetPrimaryKey({"V2A_FILIAL", "V2A_CHVERP", "V2A_CHVGOV", "V2A_STATUS", "V2A_CNPJ" })

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Monta a view
@author  Nicholas Washington
@since   31/03/2020
@version 1
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView   := Nil
Local oStruct := FWFormStruct(2, "V2A")

Local oModel   := FWLoadModel("TAFMigr004")

//Criando a View
oView := FWFormView():New()
oView:SetModel(oModel)
 
//Adicionando os campos do cabeçalho e o grid dos filhos
oView:AddField("VIEW_V2A", oStruct, "V2AMASTER")
 
//Amarrando a view com as box
oView:CreateHorizontalBox("CABEC", 100)
oView:SetOwnerView("VIEW_V2A", "CABEC")
 
//Habilitando título
oView:EnableTitleView("VIEW_V2A","Processamento de Registros Inconsistentes")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} TafMarkBrw
FWMarkBrowse em MVC da tabela V2A
@author Nicholas Washington
@since 30/03/2020
@version 1.0
@obs Criar a coluna V2A_OK com o tamanho 2 no Configurador e deixar como não usado
/*/
//-------------------------------------------------------------------
 
Function TafMarkBrw(lProcess)

Private oMark

Default lProcess := .F.

//Criando o MarkBrow
oMark := FWMarkBrowse():New()
oMark:SetAlias('V2A')

lProcess := .F.

If FieldPos("V2A_OK") > 0
    V2A->V2A_OK
Else
    ConOut("Coluna V2A_OK não existe.")
    MsgStop( 'Coluna V2A_OK não existe. Rode o dicionário', 'Atenção' )
EndIf
    
//Setando semáforo, descrição e campo de mark
oMark:SetSemaphore(.T.)
oMark:SetDescription('Seleção de Registros Rejeitados')
oMark:SetFieldMark( 'V2A_OK' )
    
//Setando MenuDef 
oMark:SetMenuDef('TAFMIGR004')

//Adiciono filtro para trazer Somente Rejeitados.
oMark:AddFilter("Somente Rejeitados","V2A->V2A_STATUS=='6'",.T.,.T.)

//Adiciona botoes na janela
oMark:AddButton("Executar", {||IIF(VAZIO(V2A->V2A_OK), MsgStop( 'Selecione algum evento para processar.', 'Advertência' ), CloseBrowse( TAFMigr001(lProcess := .T.))  ) })
oMark:AddButton("Marcar Todos",{||FMarkAll(.T.)})
oMark:AddButton("Desmarcar Todos",{||FMarkAll(.F.)})

//Setando Legenda
oMark:AddLegend( "V2A->V2A_STATUS ==  '6'", "RED",  "Registro(s) Rejeitado(s)" )
    
//Ativando a janela
oMark:Activate()

//Fechando a tabela reservada
V2A->(DbCloseArea())
    
//Return (lProcess)

//---------------------------------------------------------------------
/*/{Protheus.doc} FMarkAll - Inverte a indicação de seleção de todos registros do Browse.
@param	lMarca - Define se deve ter a Marcar ou Desmarcar todos
@Return	Nil
@Author	Nicholas Washington
@Since		08/04/2020
@Version	1.0
/*/
//---------------------------------------------------------------------

Static Function FMarkAll(lInvert)

	Local cAlias	:= oMark:Alias()
	Local cMark		:= ""
	Local cSql	:= ""
	Local nRecno	:= (cAlias)->(Recno())

	oMark:SetInvert(lInvert)
	oMark:Refresh()

	If lInvert
		cMark := getMark()   
	Else
		cMark := '  '
	EndIf

    cSql := " UPDATE "
    cSql += " " + RetSqlName("V2A") + " "
    cSql += " SET V2A_OK = '" + cMark + "'"
    cSql += " WHERE V2A_STATUS = '6' "        

	If TCSQLExec (cSql) < 0
		MsgInfo (TCSQLError(),"Update Mark Eventos.")
	EndIf

	(cAlias)->(dbGoTo(nRecno))

Return


