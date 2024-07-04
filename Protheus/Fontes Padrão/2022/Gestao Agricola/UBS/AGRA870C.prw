#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"

Static lAG870C01 := ExistBlock("AG870C01") //Ponto de Entrada para adicionar novo botões na AGRA870C
Static lAG870C02 := ExistBlock("AG870C02") //Ponto de Entrada para adicionar Campos no Select do browse

/** {Protheus.doc} AGRA870C
Rotina para Inclusão de Lotes a partir da Carga montada
@param: 	Nil
@author: 	Ricardo Mendes	
@since: 	22/08/2020
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function AGRA870C()
	
	Local nX     		:= ''
	Local cAliasBrw 	:= GetNextAlias()
	Local aCposFiltr	:= {}
	Local aColumns		:= {}
	Local cQuery        := ''
	Local cCposUser     := ''
	Local aCposUser     := {}
	
	Private _oBrw

  cQuery:= fMontaQuery(@cQuery, @cCposUser)

///EECVIEW(cQuery,'XXX')

	//Define as colunas do Browse de Acordo com SX3 Para Buscar Tamanho,decimais Etc;
	aCposBrowse := {"DAK_COD", "DAK_SEQCAR","DAK_ROTEIR","DAK_CAMINH", "DAK_MOTORI","DAK_PESO","DAK_VALOR","DAK_DATA","DAK_HORA","DAK_TRANSP"}

		//Define as colunas do Browse de Acordo com a Qry para Identificar os Dados
	aCposQry	:= {"DAK_COD", "DAK_SEQCAR","DAK_ROTEIR","DAK_CAMINH", "DAK_MOTORI","DAK_PESO","DAK_VALOR","DAK_DATA","DAK_HORA","DAK_TRANSP"}

	//Adicionando campos de usuario
	IF !Empty(cCposuser)
	   aCposUser:= StrTokArr( cCposuser, ',')
		For nX=1 to Len( aCposUser )
		   aadd(aCposBrowse,Alltrim(acPosUser[nX]))
		   aAdd(aCposQry,Alltrim(acPosUser[nX]) )
		next nX
	EndIF


	for nX := 1 to Len(aCposQry)
	  //Nome,Titulo,Tp. dado, tamanho,decimais,picture
	   aAdd(aCposFiltr,{aCposQry[nX],FWX3Titulo(aCposQry[nX]),TamSX3(aCposQry[nX])[3],TamSX3(aCposQry[nX])[1],TamSX3(aCposQry[nX])[2],X3PICTURE(aCposQry[nX]) } )
	nExt nX

	//Definindo as colunas do Browse
	
	For nX:= 1 to Len ( aCposBrowse )
	
		AAdd(aColumns,FWBrwColumn():New())


	///	aColumns[nX]:SetData( &("{|| sTod(AD1_DTINI) }") )

///		&("{||STOD("+aCposBrowse[ nX ]+")}")

		aColumns[Len(aColumns)]:SetData( If(TamSx3(aCposBrowse[nX])[3] == "D",&("{||STOD("+aCposBrowse[ nX ]+")}"),&("{||"+aCposBrowse[ nX ]+"}")) )
		//aColumns[Len(aColumns)]:SetData( &("{||"+aCposBrowse[ nX ]+"}"))
		aColumns[Len(aColumns)]:SetTitle( AllTrim(RetTitle( aCposBrowse[nX]) )) 
		aColumns[Len(aColumns)]:SetSize(TamSx3(aCposBrowse[nX])[1])
		aColumns[Len(aColumns)]:SetDecimal(TamSx3(aCposBrowse[nX])[2])
		aColumns[Len(aColumns)]:SetPicture(X3PICTURE(aCposBrowse[nX]))
		aColumns[Len(aColumns)]:SetAlign( If(TamSx3(aCposBrowse[nX])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento
	
	nExt nX

	aIndex		:= {"DAK_COD", "DAK_SEQCAR" }

	_oBrw    := fwmBrowse():New() //fwBrowse():New()
	////_oBrw:SetOwner( oPanel )
	_oBrw:SetDataQuery(.T.)           
	_oBrw:SetAlias(cAliasBrw)
	_oBrw:SetQuery(cquery)
	_oBrw:SetColumns(aColumns)
	_oBrw:SetQueryIndex(aIndex)
	///_oBrw:SetUniqueKey({'C6_RECNO' })
	_oBrw:SetDescription( "Separação de Lotes por Carga" )
	_oBrw:SetMenuDef( 'AGRA870C')
	_oBrw:DisableConfig(.t.)
	_oBrw:DisableDetails()
	_oBrw:SetProfileID( "AGRA870C" )
	_oBrw:SetFieldFilter(aCposFiltr)
	_oBrw:Activate()

Return()

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina
@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Ricardo Mendes
@since: 	22/08/2020
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function MenuDef()
	Local aRotina	:= {}
	Local aRetM		:= {}
	Local nX		:= 0
	
	aAdd( aRotina, { "Inclusão"		, "AGRA870INC()" , 0, 4, 0, Nil } )
	aAdd( aRotina, { "Alteração"	, "AGRA870ALT()" , 0, 4, 0, Nil } )
	aAdd( aRotina, { "Pesquisar"	, 'PesqBrw'      , 0, 1, 0, .T. } )
	
	IF lAG870C01
		aRetM := ExecBlock('AG870C01',.F.,.F.)
		If ValType(aRetM) == 'A'
			For nX := 1 To Len(aRetM)
				Aadd(aRotina,aRetM[nX])
			Next nX 
		EndIf
	EndIF

Return aRotina

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina
@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Ricardo Mendes
@since: 	22/08/2020
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function ModelDef()
	Local oStruDAK := FWFormStruct( 1, "DAK" )
	Local oModel := MPFormModel():New( "AGR870C" )

	oModel:AddFields( 'DAKUNICO', Nil, oStruDAK )
	oModel:SetDescription( "Separação de Lotes" ) 
	oModel:GetModel( 'DAKUNICO' ):SetDescription( "Separação de Lotes" ) 

Return oModel

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina
@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Ricardo Mendes	
@since: 	22/08/2020
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function ViewDef()
	Local oStruDAK := FWFormStruct( 2, 'DAK' )
	Local oModel   := FWLoadModel( 'AGR870C' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_DAK', oStruDAK, 'NJ6UNICO' )
	oView:CreateHorizontalBox( 'UM'  , 100 )
	oView:SetOwnerView( 'VIEW_DAK', 'UM'   )

Return oView

/** {Protheus.doc} AGRA870INC
Função para chamar a tela de seleção de lotes para inclusão por carga
@param: 	Nil
@return:	Nil
@author: 	Ricardo Mendes	
@since: 	22/08/2020
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function AGRA870INC()
Return AGRA870DAK("I")

/** {Protheus.doc} AGRA870DAK
Função para chamar a tela de seleção de lotes para alteração por carga
@param: 	Nil
@return:	Nil
@author: 	Ricardo Mendes	
@since: 	22/08/2020
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function AGRA870ALT()
Return AGRA870DAK("A")

/** {Protheus.doc} AGRA870DAK
Função para chamar a tela de seleção de lotes para inclusão/Alteração por carga
@param: 	Nil
@return:	Nil
@author: 	Ricardo Mendes	
@since: 	22/08/2020
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function AGRA870DAK(cTipo)
	Local aChaveNJ6 := {}
	Default cTipo := "I"
	
	IF cTipo == "I"
		///DbSelectArea("NJ6")
		///NJ6->(DbSetOrder(1))
		///If NJ6->(dbseek(fwxfilial('DAK') + (_oBrw:Alias())->DAK_COD + (_oBrw:Alias())->DAK_SEQCAR)) 
		IF Alltrim ( (_oBrw:Alias())->CrgaTemLte ) == 'S'
			Help(,, 'Help AGRA870C',, "Já existe registros relacionados a seleção de lotes para essa carga.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Utilizar a opção de alterar seleção de lotes"})
		Else
			aChaveNJ6 := {fwxfilial('DAK'),(_oBrw:Alias())->DAK_COD , (_oBrw:Alias())->DAK_SEQCAR}
			AGRA870B(aChaveNJ6)
		EndIf
	Else
	    IF Alltrim ( (_oBrw:Alias())->CrgaTemLte ) == 'N'
		   Help(,, 'Help AGRA870C',, "Carga Selecionada não possui lotes.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Utilize a opção de Incluir Lotes."})
		//ElseIF !fVldGFEMv(fwxfilial('DAK'),(_oBrw:Alias())->DAK_COD , (_oBrw:Alias())->DAK_SEQCAR)
		Else
			aChaveNJ6 := {fwxfilial('DAK'),(_oBrw:Alias())->DAK_COD , (_oBrw:Alias())->DAK_SEQCAR}
			AGRA870B(aChaveNJ6)
		//Else
		//	Help(,, 'Help AGRA870C',, "Seleção de Lote já encontra-se com movimentação no GFE.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Utilizar a opção de alterar seleção de lotes dentro da estrutura do GFE"})
		EndIF
	EndIF

	///(_oBrw:Alias())->( dBGotop() )

	_oBrw:Refresh(.t.)

Return .T.

//Função para validar se carga já encontra-se dentro do GFE.
Static Function fVldGFEMv(cTmpFil, cTmpCar, cTmpSeq)
	Local lRetGFE := .F.
	Local cAliasGFE	:= GetNextAlias()
	Local aAreaGFE 	:= GetArea()
	
	BeginSQL Alias cAliasGFE
		Select COUNT(GWV_NRROM) REGISTRO 
		FROM
			%table:DAK5% DAK
		INNER JOIN %table:GWN% GWN 
			ON GWN.%notDel% 						
			AND GWN.GWN_FILIAL	= DAK.DAK_FILIAL 	
			AND GWN.GWN_NRROM	= DAK.DAK_COD||DAK.DAK_SEQCAR
		INNER JOIN %table:GWV%  GWV 
			ON GWN.%notDel% 	
			AND GWN.GWN_FILIAL = GWV.GWV_FILIAL
			AND GWN.GWN_NRROM  = GWV.GWV_NRROM
			AND GWV.GWV_SIT = '1'
		WHERE 
			DAK.%notDel%
			AND	DAK.DAK_FILIAL	= %exp:cTmpFil%
			AND DAK.DAK_COD		= %exp:cTmpCar%
			AND DAK.DAK_SEQCAR	= %exp:cTmpSeq%
	EndSQL
		
	lRetGFE := ( (cAliasGFE)->REGISTRO > 0 )

	(cAliasGFE)->(dbclosearea())   
	RestArea(aAreaGFE)	
		
Return lRetGFE


/** {Protheus.doc} fmontaQuery
Rotina Que monta a query do Browse
@param: 	@cQuery,
            @cCposUser
@author: 	AgroIndustria
@since: 	22/08/2020
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function fMontaQuery(cQuery, cCposUser)

	Local lSair			:=.f.


While(.t.)
	//Itendifica se tem lote vinculado na  Carga
	cQuery := " SELECT DAK_COD, DAK_SEQCAR,DAK_ROTEIR,DAK_CAMINH,DAK_MOTORI,DAK_PESO,DAK_VALOR,DAK_DATA,DAK_HORA,DAK_TRANSP,"
	IF .Not. Empty( cCposUser )
		cQuery += cCposUser + ", " //Adiciona possiveis campos de usuario na query 
	EndIF
	cQuery += " ("
	cQuery += "    	Select "
	cQuery += " 		CASE COALESCE( COUNT(NJ6.NJ6_CODCAR), 0) "
	cQuery += " 			WHEN  0 THEN 'N' "
	cQuery += "     		ELSE 'S'	"
	cQuery += "         END
	cQuery += " 	FROM " + RetSqlName( "NJ6" )   + " NJ6 "
	cQuery += " 	WHERE   NJ6.D_E_L_E_T_ = ' ' "
	cQuery += " 	AND NJ6.NJ6_FILIAL = '" + xFilial('NJ6')  + "'"
	cQuery += " 	AND NJ6.NJ6_CODCAR = DAK.DAK_COD "
	cQuery += " 	AND NJ6.NJ6_SEQCAR = DAK.DAK_SEQCAR ) CrgaTemLte, "

	//Itentifica se a carga ja esta movimentada no patios e portarias
	cQuery += " ( "
	cQuery += " 	SELECT  "
	cQuery += " 		CASE COALESCE( COUNT(GX3_NRMOV), 0 )	"
	cQuery += "            WHEN  0 THEN 'N'	"
	cQuery += "            ELSE 'S'	"
	cQuery += "          END "
	cQuery += "		FROM " + RetSqlName( "GWN" )   + " GWN "
	cQuery += " 		INNER JOIN "  + RetSqlName( "GWV" )    + " GWV "
	cQuery += " 			ON GWN.D_E_L_E_T_ = ' '	"
	cQuery += " 			AND GWN.GWN_FILIAL = GWV.GWV_FILIAL	"
	cQuery += " 			AND GWN.GWN_NRROM  = GWV.GWV_NRROM	"
	cQuery += " 			AND GWV.GWV_SIT <> '3'	"
	cQuery += "        INNER JOIN " + RetSqlName( "GX3" )   + " GX3 "
	cQuery += " 			ON  GX3_FILIAL = GWV_FILIAL	"
	cQuery += " 			AND GX3_NRMOV = GWV_NRMOV	"
	cQuery += " 			AND GX3.D_E_L_E_T_ = ' ' 	"
	cQuery += " WHERE GWN.D_E_L_E_T_ = ' '	"
	cQuery += " AND GWN.GWN_FILIAL	= DAK.DAK_FILIAL 	"
	cQuery += " AND GWN.GWN_NRROM= DAK.DAK_COD||DAK.DAK_SEQCAR) CONSTA_GFE "
	cQuery += " FROM " + RetSqlName( "DAK" )   + " DAK "
	cQuery += " WHERE DAK.D_E_L_E_T_ = ' ' "
	cQuery += " AND DAK.DAK_FILIAL = '" + xFilial('DAK')  + "'"
		////cQuery += " AND DAK_COD = '010192' " //Carregamento de teste
	cQuery += " AND DAK.DAK_FEZNF  <> '1' " //Não possuem nf emitida

	// Listar somente cargas que ainda não estão dentro do patios e portaria
	cQuery += " AND ( "
	cQuery += " 	SELECT  "
	cQuery += " 		CASE COALESCE( COUNT(GX3_NRMOV), 0 )	"
	cQuery += "            WHEN  0 THEN 'N'	"
	cQuery += "            ELSE 'S'	"
	cQuery += "          END "
	cQuery += "		FROM " + RetSqlName( "GWN" )   + " GWN "
	cQuery += " 		INNER JOIN "  + RetSqlName( "GWV" )    + " GWV "
	cQuery += " 			ON GWN.D_E_L_E_T_ = ' '	"
	cQuery += " 			AND GWN.GWN_FILIAL = GWV.GWV_FILIAL	"
	cQuery += " 			AND GWN.GWN_NRROM  = GWV.GWV_NRROM	"
	cQuery += " 			AND GWV.GWV_SIT <> '3'	"
	cQuery += "        INNER JOIN " + RetSqlName( "GX3" )   + " GX3 "
	cQuery += " 			ON  GX3_FILIAL = GWV_FILIAL	"
	cQuery += " 			AND GX3_NRMOV = GWV_NRMOV	"
	cQuery += " 			AND GX3.D_E_L_E_T_ = ' ' 	"
	cQuery += " WHERE GWN.D_E_L_E_T_ = ' '	"
	cQuery += " AND GWN.GWN_FILIAL	= DAK.DAK_FILIAL 	"
	cQuery += " AND GWN.GWN_NRROM= DAK.DAK_COD||DAK.DAK_SEQCAR) = 'N' "
	cquery := Changequery(cQuery)

	//Ponto de entrada que permite adicionar campos na query dos dados do browse
	//passo a query para o usuario saber quais tabelas estão na query
	IF lAG870C02 .and. !lSair
		cCposUser := ExecBlock("AG870C02",.F.,.F.,{cquery})

		IF ValType(cCposUser) == "C" .AND. !Empty(cCposUser)
		lSair :=.t.		
		Loop //Adicionando os campos do usuario na query
		EndIF
	EndIF

	Exit

EndDO

Return ( cQuery )
