#INCLUDE "PROTHEUS.CH"
#INCLUDE "TAFOBRIG.CH"

//------------------------------------------------------------------
/*/{Protheus.doc} TAFOBRIG

Rotina de Central de Obrigações.

@Author	Vitor Ferreira
@Since
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFOBRIG()

Local aAllObrig	:=	{}
Local aListFed	:=	{}
Local aListEst	:=	{}
Local aListMun	:=	{} 

If Upper(Alltrim(TCGetDB())) <> "OPENEDGE"
	//Verifica se existe algum Complemento de Empresa cadastrado
	If VldComEmp()
		aAllObrig := GetAllObg()

		//Busca todas as Obrigações por Esfera
		aListFed := GetListObg( aAllObrig, 1 )
		aListEst := GetListObg( aAllObrig, 2 )
		aListMun := GetListObg( aAllObrig, 3 )
	
		If !Empty( aListFed ) .or. !Empty( aListEst ) .or. !Empty( aListMun )
			CriaWiz( "CENTRAL",, aListFed, aListEst, aListMun )
		Else
			MsgStop( STR0001 ) //"Por favor, associe as Obrigações Fiscais a um Complemento de Empresa para ter acesso a Central de Obrigações!"
		EndIf
	Else
		MsgStop( STR0002 ) //"Por favor, cadastre um Complemento de Empresa antes de acessar a Central de Obrigações!"
	EndIf
Else
	MsgInfo( STR0022 ) //"Somente a entrega do eSocial está homologada para <b>OpenEdge / Progress</b>, as outras obrigações serão habilitadas de forma gradativa."
EndIf
 
Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} VldComEmp()

Verifica se existe algum Complemento de Empresa cadastrado.

@Author	Vitor Ferreira
@Since
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function VldComEmp()

Local lRet		:=	.F.

DBSelectArea( "C1E" )
C1E->( DBSetOrder( 3 ) )
If C1E->( MsSeek( xFilial( "C1E" ) + FWCodFil() + "1" ) )
	lRet := .T.
Endif

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAllObg

Busca as Obrigações cadastradas no Complemento de Empresa.

@Return	aList	-	Array com as Obrigações disponíveis

@Author	Vitor Ferreira
@Since
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function GetAllObg()

Local cAliasQry	:=	GetNextAlias()
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""
Local cOrderBy	:=	""
Local nCnt			:=	1
Local aList		:=	{}

cSelect := "CHW.R_E_C_N_O_ RECNO "

cFrom := RetSqlName( "C1E" ) + " C1E "

cFrom += "INNER JOIN " + RetSqlName( "CZR" ) + " CZR "
cFrom += "  ON CZR.CZR_FILIAL = C1E.C1E_FILIAL "
cFrom += " AND CZR.CZR_ID = C1E.C1E_ID "
cFrom += " AND CZR.CZR_VERSAO = C1E.C1E_VERSAO "
cFrom += " AND CZR.D_E_L_E_T_ = '' "

cFrom += "INNER JOIN " + RetSqlName( "CHW" ) + " CHW "
cFrom += "   ON CHW.CHW_FILIAL = CZR.CZR_FILIAL "
cFrom += "  AND CHW.CHW_ID = CZR.CZR_IDOBRI "
cFrom += "  AND CHW.D_E_L_E_T_ = '' "

cWhere := "    C1E.C1E_FILIAL = '" + xFilial( "C1E" ) + "' "
cWhere += "AND C1E.C1E_FILTAF = '" + FWCodFil() + "' "
cWhere += "AND C1E.C1E_ATIVO = '1' "
cWhere += "AND C1E.D_E_L_E_T_ = '' "

cOrderBy := "CHW.CHW_CODIGO "

cSelect	:= "%" + cSelect  + "%"
cFrom		:= "%" + cFrom    + "%"
cWhere		:= "%" + cWhere   + "%"
cOrderBy	:= "%" + cOrderBy + "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	ORDER BY
		%Exp:cOrderBy%

EndSql

DBSelectArea( "CHW" )

While ( cAliasQry )->( !Eof() )

	CHW->( DBGoTo( ( cAliasQry )->RECNO ) )

	aAdd( aList, {} )
	aAdd( aList[nCnt], .F. )
	aAdd( aList[nCnt], AllTrim( CHW->CHW_CODIGO ) )
	aAdd( aList[nCnt], AllTrim( CHW->CHW_DESCRI ) )
	aAdd( aList[nCnt], AllTrim( CHW->CHW_FONTE ) )
	aAdd( aList[nCnt], AllTrim( CHW->CHW_MAINFU ) )
	aAdd( aList[nCnt], AllTrim( CHW->CHW_ESFERA ) )
	aAdd( aList[nCnt], AllTrim( CHW->CHW_DESCCO ) )
	aAdd( aList[nCnt], AllTrim( CHW->CHW_DESTIN ) )
	aAdd( aList[nCnt], AllTrim( CHW->CHW_OBJETI ) ) 
	aAdd( aList[nCnt], AllTrim( CHW->CHW_PRAZO ) ) 
	aAdd( aList[nCnt], AllTrim( CHW->CHW_APPDIS ) )
	aAdd( aList[nCnt], AllTrim( CHW->CHW_VERSAO ) ) 
	aAdd( aList[nCnt], AllTrim( CHW->CHW_COMENT ) )
	nCnt ++

	( cAliasQry )->( DBSkip() )
EndDo

( "CHW" )->( DBCloseArea() )
( cAliasQry )->( DBCloseArea() )

Return( aList )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetListObg

Busca as Obrigações disponíveis para uma determinada esfera.

@Param	aAllObrig	-	Array com as Obrigações disponíveis 
		nEsfera	-	Tipo de Obrigação ( 1 - Federal, 2 - Estadual, 3 - Municipal )

@Return	aList	-	Array com as Obrigações referentes a esfera

@Author	Vitor Ferreira
@Since
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function GetListObg( aAllObrig, nEsfera )

Local nI		:=	0
Local aList	:=	{}

For nI := 1 to Len( aAllObrig )
	If aAllObrig[nI,6] == cValToChar( nEsfera )
		aAdd( aList, aAllObrig[nI] )
	EndIf
Next

Return( aList )

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaWiz

Cria a Wizard inicial da Central de Obrigações.

@Param	cNomWiz	-	Nome da Wizard que sera criada
		cNomeAnt	-	Arquivo .CFP que já possui as configurações da Wizard
		aListFed	-	Lista com Obrigações Federais cadastradas no Complemento de Empresa
		aListEst	-	Lista com Obrigações Estaduais cadastradas no Complemento de Empresa
		aListMun	-	Lista com Obrigações Municipais cadastradas no Complemento de Empresa

@Return	lRet	-	Indica se foi criada a Wizard

@Author	Felipe C. Seolin
@Since		21/10/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function CriaWiz( cNomWiz, cNomeAnt, aListFed, aListEst, aListMun )

Local cTitObj1	:=	""
Local cTitObj2	:=	""
Local cAction		:=	""
Local nPos			:=	0
Local aTxtApre	:=	{}
Local aPaineis	:=	{}
Local aItens1		:=	{}
Local aHeader		:=	{}
Local lRet			:=	.T.

Default cNomeAnt := ""

aAdd( aTxtApre, STR0003 ) //"Central de Obrigações"
aAdd( aTxtApre, "" )	
aAdd( aTxtApre, STR0004 ) //"Wizard de Obrigações Fiscais"
aAdd( aTxtApre, STR0005 ) //"Este wizard tem como objetivo ajudá-lo a gerar suas Obrigações Fiscais"

//--------------------------------------------------------------------------------------//
//                                       PAINEL 1                                       //
//--------------------------------------------------------------------------------------//
aAdd( aPaineis, {} )
nPos := Len( aPaineis )
aAdd( aPaineis[nPos], STR0003 ) //"Central de Obrigações"
aAdd( aPaineis[nPos], STR0010 ) //"Esferas Fiscais"
aAdd( aPaineis[nPos], {} )
aAdd( aPaineis[nPos], "Iif( aVarPaineis[1][3][2]:aItems[aVarPaineis[1][3][1]] == '" + STR0007 + "', ( oWizard:nPanel := 2, .T. ), Iif( aVarPaineis[1][3][2]:aItems[aVarPaineis[1][3][1]] == '" + STR0008 + "', ( oWizard:nPanel := 3, .T. ), ( oWizard:nPanel := 4, .T. ) ) )" ) //##Federal" ##"Estadual"

//--------------------------------------------------------------------------------------//
cTitObj1 := STR0006 //"Selecione uma Esfera"
cTitObj2 := ""

aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,, } )
aAdd( aPaineis[nPos,3], { 1, cTitObj2,,,,,,}  )

aItens1 := {}

//Verifica se existe Obrigação e adiciona uma opção para o Radio
If !Empty( aListFed )
	aAdd( aItens1, STR0007 ) //"Federal"
EndIf

If !Empty( aListEst )
	aAdd( aItens1, STR0008 ) //"Estadual"
EndIf

If !Empty( aListMun )
	aAdd( aItens1, STR0009 ) //"Municipal"
EndIf

aAdd( aPaineis[nPos,3], { 6,,,,, aItens1,, } )
aAdd( aPaineis[nPos,3], { 0, "",,,,,, } )
//--------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------//
//                                       PAINEL 2                                       //
//--------------------------------------------------------------------------------------//
aAdd( aPaineis, {} )
nPos := Len( aPaineis )
aAdd( aPaineis[nPos], STR0003 ) //"Central de Obrigações"
aAdd( aPaineis[nPos], STR0011 ) //"Esfera Federal"
aAdd( aPaineis[nPos], {} )

cAction := "Iif( !TAFCOVldOb( aVarPaineis[2][9][2] ),"   
cAction += "		( , .F. )," 
cAction += "		Iif( FindFunction( aVarPaineis[2][9][2]:aArray[ascan(aVarPaineis[2][9][2]:aArray,{|X| x[1]}),4] ),"
cAction += "			( TAFCOWizOb( &( 'STATICCALL( ' + aVarPaineis[2][9][2]:aArray[ascan(aVarPaineis[2][9][2]:aArray,{|X| x[1]}),4] + ', getObrigParam )' ) ), oWizard:nPanel := 1, .T. ),"
cAction += "			( MsgStop( '" + STR0015 + "' ), .F. ) ) ) " //"Obrigação não encontrada no repositório!"

aAdd( aPaineis[nPos], cAction )

cAction := "( oWizard:nPanel := 3, .T. )"

aAdd( aPaineis[nPos], cAction )

//--------------------------------------------------------------------------------------//
cTitObj1 := STR0016 //"Filtro"
cTitObj2 := STR0017 //"Busque uma Obrigação"

aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,, } )
aAdd( aPaineis[nPos,3], { 1, cTitObj2,,,,,, } )

aItens1 := {}
aAdd( aItens1, STR0018 ) //"Código"
aAdd( aItens1, STR0019 ) //"Obrigação"

cTitObj2 := Replicate( "X", 50 )

aAdd( aPaineis[nPos,3], { 3,,,,, aItens1,,} )
aAdd( aPaineis[nPos,3], { 2,, cTitObj2, 1,,,, 50,,,,, { "xFunVldWiz", "CENTRAL-PESQUISA" } } )

aAdd( aPaineis[nPos,3], { 0, "",,,,,, } )
aAdd( aPaineis[nPos,3], { 0, "",,,,,, } )
//--------------------------------------------------------------------------------------//
cTitObj1 := STR0020 //"Selecione uma Obrigação"
cTitObj2 := STR0021 //"Mais Informações"

cAction :=	"Iif( !TAFCOVldOb( aVarPaineis[2][9][2] ),"
cAction +=	"		( , .F. )," 
cAction +=	"		TAFCOModal( {	aVarPaineis[2][9][2]:aArray[aVarPaineis[2][9][2]:nAt][3],"
cAction +=	"						aVarPaineis[2][9][2]:aArray[aVarPaineis[2][9][2]:nAt][7],"
cAction +=	"						aVarPaineis[2][9][2]:aArray[aVarPaineis[2][9][2]:nAt][8],"
cAction +=	"						aVarPaineis[2][9][2]:aArray[aVarPaineis[2][9][2]:nAt][9],"
cAction +=	"						aVarPaineis[2][9][2]:aArray[aVarPaineis[2][9][2]:nAt][10],"
cAction +=	"						aVarPaineis[2][9][2]:aArray[aVarPaineis[2][9][2]:nAt][11],"
cAction +=	"						aVarPaineis[2][9][2]:aArray[aVarPaineis[2][9][2]:nAt][12],"
cAction +=	"						aVarPaineis[2][9][2]:aArray[aVarPaineis[2][9][2]:nAt][13] } ) )"

aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,, } )
aAdd( aPaineis[nPos,3], { 7, cTitObj2,,,,,,,,,,,,,,, cAction } )

aHeader := { "", STR0018, STR0019 } //##"Código" ##"Obrigação"

cAction := "aItObj1 := xFunFClTroca( aVarPaineis[2][9][2]:nAt, aItObj1 ), TAFCOVldOp( aVarPaineis[2][9][2] )"

aAdd( aPaineis[nPos,3], { 5,,,,, aListFed,,,,,,,, aHeader, 1, cAction } )
aAdd( aPaineis[nPos,3], { 0, "",,,,,,} )
//--------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------//
//                                       PAINEL 3                                       //
//--------------------------------------------------------------------------------------//
aAdd( aPaineis, {} )
nPos := Len( aPaineis )
aAdd( aPaineis[nPos], STR0003 ) //"Central de Obrigações"
aAdd( aPaineis[nPos], STR0012 ) //"Esfera Estadual"
aAdd( aPaineis[nPos], {} )

cAction := "Iif( !TAFCOVldOb( aVarPaineis[3][9][2] ),"
cAction += "		( , .F. )," 
cAction += "		Iif( FindFunction( aVarPaineis[3][9][2]:aArray[ascan(aVarPaineis[3][9][2]:aArray,{|X| x[1]}),4] ),"
cAction += "			( TAFCOWizOb( &( 'STATICCALL( ' + aVarPaineis[3][9][2]:aArray[ascan(aVarPaineis[3][9][2]:aArray,{|X| x[1]}),4] + ', getObrigParam )' ) ), oWizard:nPanel := 1, .T. ),"
cAction += "			( MsgStop( '" + STR0015 + "' ), .F. ) ) ) " //"Obrigação não encontrada no repositório!"

aAdd( aPaineis[nPos], cAction )

cAction := "( oWizard:nPanel := 3, .T. )"

aAdd( aPaineis[nPos], cAction )

//--------------------------------------------------------------------------------------//
cTitObj1 := STR0016 //"Filtro"
cTitObj2 := STR0017 //"Busque uma Obrigação"

aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,, } )
aAdd( aPaineis[nPos,3], { 1, cTitObj2,,,,,, } )

aItens1 := {}
aAdd( aItens1, STR0018 ) //"Código"
aAdd( aItens1, STR0019 ) //"Obrigação"

cTitObj2 := Replicate( "X", 50 )

aAdd( aPaineis[nPos,3], { 3,,,,, aItens1,,} )
aAdd( aPaineis[nPos,3], { 2,, cTitObj2, 1,,,, 50,,,,, { "xFunVldWiz", "CENTRAL-PESQUISA" } } )

aAdd( aPaineis[nPos,3], { 0, "",,,,,, } )
aAdd( aPaineis[nPos,3], { 0, "",,,,,, } )
//--------------------------------------------------------------------------------------//
cTitObj1 := STR0020 //"Selecione uma Obrigação"
cTitObj2 := STR0021 //"Mais Informações"

cAction :=	"Iif( !TAFCOVldOb( aVarPaineis[3][9][2] ),"
cAction +=	"		( , .F. )," 
cAction +=	"		TAFCOModal( {	aVarPaineis[3][9][2]:aArray[aVarPaineis[3][9][2]:nAt][3],"
cAction +=	"						aVarPaineis[3][9][2]:aArray[aVarPaineis[3][9][2]:nAt][7],"
cAction +=	"						aVarPaineis[3][9][2]:aArray[aVarPaineis[3][9][2]:nAt][8],"
cAction +=	"						aVarPaineis[3][9][2]:aArray[aVarPaineis[3][9][2]:nAt][9],"
cAction +=	"						aVarPaineis[3][9][2]:aArray[aVarPaineis[3][9][2]:nAt][10],"
cAction +=	"						aVarPaineis[3][9][2]:aArray[aVarPaineis[3][9][2]:nAt][11],"
cAction +=	"						aVarPaineis[3][9][2]:aArray[aVarPaineis[3][9][2]:nAt][12],"
cAction +=	"						aVarPaineis[3][9][2]:aArray[aVarPaineis[3][9][2]:nAt][13] } ) )"

aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,, } )
aAdd( aPaineis[nPos,3], { 7, cTitObj2,,,,,,,,,,,,,,, cAction } )

aHeader := { "", STR0018, STR0019 } //##"Código" ##"Obrigação"

cAction := "aItObj2 := xFunFClTroca( aVarPaineis[3][9][2]:nAt, aItObj2 ), TAFCOVldOp( aVarPaineis[3][9][2] )"

aAdd( aPaineis[nPos,3], { 5,,,,, aListEst,,,,,,,, aHeader, 1, cAction } )
aAdd( aPaineis[nPos,3], { 0, "",,,,,,} )
//--------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------//
//                                       PAINEL 4                                       //
//--------------------------------------------------------------------------------------//
aAdd( aPaineis, {} )
nPos := Len( aPaineis )
aAdd( aPaineis[nPos], STR0003 ) //"Central de Obrigações"
aAdd( aPaineis[nPos], STR0013 ) //"Esfera Municipal"
aAdd( aPaineis[nPos], {} )

cAction := "Iif( !TAFCOVldOb( aVarPaineis[4][9][2] ),"
cAction += "		(, .F. )," 
cAction += "		Iif( FindFunction( aVarPaineis[4][9][2]:aArray[ascan(aVarPaineis[4][9][2]:aArray,{|X| x[1]}),4] ),"
cAction += "			( TAFCOWizOb( &( 'STATICCALL( ' + aVarPaineis[4][9][2]:aArray[ascan(aVarPaineis[4][9][2]:aArray,{|X| x[1]}),4] + ', getObrigParam )' ) ), oWizard:nPanel := 1, .T. ),"
cAction += "			( MsgStop( '" + STR0015 + "' ), .F. ) ) ) " //"Obrigação não encontrada no repositório!"

aAdd( aPaineis[nPos], cAction )

cAction := "( oWizard:nPanel := 3, .T. )"

aAdd( aPaineis[nPos], cAction )

//--------------------------------------------------------------------------------------//
cTitObj1 := STR0016 //"Filtro"
cTitObj2 := STR0017 //"Busque uma Obrigação"

aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,, } )
aAdd( aPaineis[nPos,3], { 1, cTitObj2,,,,,, } )

aItens1 := {}
aAdd( aItens1, STR0018 ) //"Código"
aAdd( aItens1, STR0019 ) //"Obrigação"

cTitObj2 := Replicate( "X", 50 )

aAdd( aPaineis[nPos,3], { 3,,,,, aItens1,,} )
aAdd( aPaineis[nPos,3], { 2,, cTitObj2, 1,,,, 50,,,,, { "xFunVldWiz", "CENTRAL-PESQUISA" } } )

aAdd( aPaineis[nPos,3], { 0, "",,,,,, } )
aAdd( aPaineis[nPos,3], { 0, "",,,,,, } )
//--------------------------------------------------------------------------------------//
cTitObj1 := STR0020 //"Selecione uma Obrigação"
cTitObj2 := STR0021 //"Mais Informações"
 
cAction :=	"Iif( !TAFCOVldOb( aVarPaineis[4][9][2] ),"
cAction +=	"		( , .F. )," 
cAction +=	"		TAFCOModal( {	aVarPaineis[4][9][2]:aArray[aVarPaineis[4][9][2]:nAt][3],"
cAction +=	"						aVarPaineis[4][9][2]:aArray[aVarPaineis[4][9][2]:nAt][7],"
cAction +=	"						aVarPaineis[4][9][2]:aArray[aVarPaineis[4][9][2]:nAt][8],"
cAction +=	"						aVarPaineis[4][9][2]:aArray[aVarPaineis[4][9][2]:nAt][9],"
cAction +=	"						aVarPaineis[4][9][2]:aArray[aVarPaineis[4][9][2]:nAt][10],"
cAction +=	"						aVarPaineis[4][9][2]:aArray[aVarPaineis[4][9][2]:nAt][11],"
cAction +=	"						aVarPaineis[4][9][2]:aArray[aVarPaineis[4][9][2]:nAt][12],"
cAction +=	"						aVarPaineis[4][9][2]:aArray[aVarPaineis[4][9][2]:nAt][13] } ) )"

aAdd( aPaineis[nPos,3], { 1, cTitObj1,,,,,, } )
aAdd( aPaineis[nPos,3], { 7, cTitObj2,,,,,,,,,,,,,,, cAction } )

aHeader := { "", STR0018, STR0019 } //##"Código" ##"Obrigação"

cAction := "aItObj3 := xFunFClTroca( aVarPaineis[4][9][2]:nAt, aItObj3 ), TAFCOVldOp( aVarPaineis[4][9][2] )"

aAdd( aPaineis[nPos,3], { 5,,,,, aListMun,,,,,,,, aHeader, 1, cAction } )
aAdd( aPaineis[nPos,3], { 0, "",,,,,,} )



/* Criado painel 5 para apresentar o botão "AVANÇAR" quando esfera Municipal */
//--------------------------------------------------------------------------------------//
//                                       PAINEL 5                                       //
//--------------------------------------------------------------------------------------//
aAdd( aPaineis, {} )
nPos := Len( aPaineis )
aAdd( aPaineis[nPos], "ÚLTIMO PAINEL" ) 
aAdd( aPaineis[nPos], "ÚLTIMO PAINEL" ) 
aAdd( aPaineis[nPos], {} )

//--------------------------------------------------------------------------------------//

lRet := xFunWizard( aTxtApre, aPaineis, cNomWiz, cNomeAnt )

Return( lRet )