#INCLUDE "PLSA112.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'  
#include "PLSMGER.CH" 

#DEFINE PLS_MODELO_CABECALHO	"VIEWDEF.PLSA112"

Function PLSA112()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('B27')
oBrowse:SetDescription(STR0001) //"Tabela de Valores"

oBrowse:Activate()

Return nil

/*/{Protheus.doc} MenuDef
menudef
@type function
@author PLS TEAM
@since 02.09.2011
@version 1.0
/*/
Static Function MenuDef()
PRIVATE aRotina := {}
AaDd( aRotina, { STR0002, 	PLS_MODELO_CABECALHO, 0, K_Visualizar } )   //"Visualizar"
AaDd( aRotina, { STR0003, 	PLS_MODELO_CABECALHO, 0, K_Incluir} )       //"Incluir"
AaDd( aRotina, { STR0004, 	PLS_MODELO_CABECALHO, 0, K_Alterar} )       //"Alterar"
AaDd( aRotina, { STR0005, 	PLS_MODELO_CABECALHO, 0, K_Excluir} )       //"Excluir"

Return aRotina

/*/{Protheus.doc} ModelDef
ModelDef
@type function
@author PLS TEAM
@since 02.09.2011
@version 1.0
/*/
Static Function ModelDef()
Local oStruB27 := FWFormStruct( 1, 'B27', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruB28 := FWFormStruct( 1, 'B28', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   := MPFormModel():New('PLSA112MD', /*bPreValidacao*/, {|oModel|Pls112Vld(oModel)}/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )


// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'B27MASTER', /*cOwner*/, oStruB27, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'B28DETAIL', 'B27MASTER', oStruB28,,{ |oGrid| bLineB28(oGrid, "NUS" ) }, /*bPreVal*/,/*bPreVal*/, {|oModel,y| GridLoad(oModel,y)}/*BLoad*/ )
oModel:GetModel("B28DETAIL"):SetUniqueLine({"B28_SEQUEN", "B28_VIGINI", "B28_VIGFIM"})

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'B28DETAIL', { 	{ 'B28_FILIAL', 'xFilial( "B28" )' },; 
									{ 'B28_CODINT', 'B27_CODINT' },; 
									{ 'B28_CODTAB', 'B27_CODTAB' }}, B28->(IndexKey(1)) )

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'B28DETAIL' ):SetOptional(.F.)

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0006 ) //"Tabela de Valorização"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'B27MASTER' ):SetDescription( STR0006 ) //"Tabela de Valorização"
oModel:GetModel( 'B28DETAIL' ):SetDescription( STR0007 ) //"Tabela de Vigências"

Return oModel

/*/{Protheus.doc} ViewDef
ViewDef
@type function
@author PLS TEAM
@since 02.09.2011
@version 1.0
/*/
Static Function ViewDef()
Local oStruB27 := FWFormStruct( 2, 'B27' )
Local oStruB28 := FWFormStruct( 2, 'B28' )
Local oModel   := FWLoadModel( 'PLSA112' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_B27', oStruB27, 'B27MASTER' )  

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_B28', oStruB28, 'B28DETAIL' )
oView:AddIncrementField("VIEW_B28","B28_SEQUEN")	

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 30 )
oView:CreateHorizontalBox( 'INFERIOR', 70 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_B27', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_B28', 'INFERIOR' )

Return oView

/*/{Protheus.doc} GridLoad
Faz a carga dos dados Ordenando as Criticas
@type function
@author PLS TEAM
@since 02.09.2011
@version 1.0
/*/
Static Function GridLoad(oModel,y)
Local aRetorno  := {}
Local aDefault  := FormLoadGrid(oModel,y)
Local aDados    := aClone(aDefault) 

If Len(aDados) > 0
	aDados := aClone(ASort(aDados,,, { |x,y| x[1] < y[1] }))
Endif

Return aDados

/*/{Protheus.doc} bLineB28
bLineB28
@type function
@author PLS TEAM
@since 02.09.2011
@version 1.0
/*/
Static Function bLineB28(oGrid)
Local aArea 	:= GetArea()
Local nX        := 0
Local nPos		:= 0
Local nLines 	:= oGrid:GetQtdLine()
Local nPosDtIni := GdFieldPos("B28_VIGINI",oGrid:aHeader)
Local nPosDtFim := GdFieldPos("B28_VIGFIM",oGrid:aHeader)
Local nOperation:= oGrid:GetOperation()
local dDtIni    := ctod('')
local dDtFim    := ctod('')
Local aAcolsAx	:= aClone(oGrid:aDataModel)
Local aMat 		:= {}
Local lRet		:= .T.

If nOperation == 3 .or. nOperation == 4 
                                              	
	// Essas são as datas da linha atual.
	dDtIni := oGrid:GetValue("B28_VIGINI",oGrid:nLine)
	dDtFim := oGrid:GetValue("B28_VIGFIM",oGrid:nLine)

	//Se data inicio for maior que final nao permite									 
	if ! empty(dDtFim) .and. dDtIni > dDtFim
		
        Help(,,"PLSANAFAI2")	
		lRet := .F.

	Endif
	
    if oGrid:GetValue("B28_VALOR",oGrid:nLine) == 0
		Help("",1,'Informe um valor!')	
		lRet := .F.
    EndIf

	If lRet

		For nX := 1 To nLines

			// Desconsidera a propria linha.
			If nX == oGrid:nLine
				Loop
			Endif
		 
		 	// Atualiza a linha do grid para futuras verificações
			If (!Empty(oGrid:GetValue("B28_VIGINI", nX)) .OR. !Empty(oGrid:GetValue("B28_VIGFIM", nX))) .and. !oGrid:IsDeleted(nX) .AND. oGrid:GetValue("B28_PTANES", nX) == oGrid:GetValue("B28_PTANES", oGrid:nLine)
				AaDd( aMat,{ aAcolsAx[nX][1][1][nPosDtIni],aAcolsAx[nX][1][1][nPosDtFim] } )
			Endif

		Next	

		If Len(aMat) > 0 

			//Verifica se ja cadastrado												 
			nPos := AsCan(aMat,{ |x| Empty(x[2])} )
		
			//Se tem vigencia com data final em aberta verifica se a data final e menor que a inicial
			If nPos > 0 

				If Empty(dDtFim) 
					Help("",1,'Há outra vigência com data final em aberto para este porte anestésico!')	// OK
					lRet := .F.
				EndIf
				
				If lRet .and. dDtFim >= aMat[nPos,1]
					Help(" ",1,'Há uma vigência aberta que contempla o período desta vigência')	// NAO OK
					lRet := .F.
				EndIf
			
				nPos := AsCan(aMat,{ |x| dDtIni >= x[1] .And. dDtIni <= x[2] .Or. dDtIni < x[1] .And. dDtFim > x[1] } )
				
                If lRet .and. nPos > 0
					Help(" ",1,'PLSA112C')
					lRet := .F.
				EndIf
			
				nPos := AsCan(aMat,{ |x| dDtIni >= x[1] .And. dDtFim <= x[2]  } )
				
                If lRet .and. nPos > 0
					Help(" ",1,'PLSA112C')
					lRet := .F.
				EndIf

			Else
				
                //Se e valido o intervalo																   
				nPos := AsCan(aMat,{ |x| dDtIni <= x[2]  } )
				If lRet .and. nPos > 0
					Help(" ",1,'O início da Vigência ocorre antes do término da anterior')	// OK
					lRet := .F.
				EndIf

			EndIf

		Endif

	Endif

Endif

RestArea(aArea)

Return(lRet)	

/*/{Protheus.doc} Pls112Vld
Pls112Vld
@type function
@author PLS TEAM
@since 02.09.2011
@version 1.0
/*/
Static Function Pls112Vld(oModel)
Local nOperation:= oModel:GetOperation()
Local lRet      := .T.
Local cSql      := ""
Local cCampoVld := ""

// Excluir
If nOperation == 5 
    
    // Valida US
	If B27->B27_TIPO == "1" 

		cCampoVld := "B23_CDTBUS"
	
    // Valida FILME
	Elseif B27->B27_TIPO == "2" 

		cCampoVld := "B23_CDTBFM"
	
    // Valida UCO
	Elseif B27->B27_TIPO == "3" 

		cCampoVld := "B23_CDTBUC"
	
	Endif

	If ! Empty(cCampoVld)

		cSql := " SELECT B23_CODINT FROM " + RetSqlName("B23")
        cSql += " WHERE B23_FILIAL      = '" + xFilial("B23") + "' "
		cSql += " AND B23_CODINT        = '" + B27->B27_CODINT + "' "
		cSql += " AND " + cCampoVld + " = '" + B27->B27_CODTAB + "' "
		cSql += " AND D_E_L_E_T_ = ' '"
		
        dbUseArea(.t.,"TOPCONN",tcGenQry(,,changeQuery(cSql)),"Trb112V",.f.,.t.)

		If ! Trb112V->( Eof() ) 	
			Help(" ",1,'PLSA112E')
			lRet := .F.		
		Endif
		
		Trb112V->( dbCloseArea() )	

	Endif

Endif

Return( lRet )

/*/{Protheus.doc} PLS28WEN
PLS28WEN
@type function
@author PLS TEAM
@since 02.09.2011
@version 1.0
/*/
function PLS28WEN()
local lRet := .t.
return(lRet)

/*/{Protheus.doc} PLS112PA
Verifica porte anestésico
@type function
@author PLS TEAM
@since 02.09.2011
@version 1.0
/*/
function PLS112PA(x, y)
Local lRet := .F.

BKF->(DbSetOrder(1))
BKF->(MsSeek(xFilial("BKF") + x))

While !lRet .AND. BKF->BKF_CODINT == x .AND. !(BKF->(EoF()))

	If BKF->BKF_SEQPOR == y
		lRet := .T.
	EndIf

	BKF->(Dbskip())

EndDo

return lRet