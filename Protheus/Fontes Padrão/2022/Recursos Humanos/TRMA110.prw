#Include 'Protheus.ch'
#Include 'TRMA110.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TRMA110()
Cadastro de Categorias de Cursos (AIQ)

@author DiegoSantos
@since 31/05/2016
@version P12.1.7
/*/
//-------------------------------------------------------------------

Function TRMA110()

Local cAlias  := "AIQ"
Local cTitulo := STR0001 //"Cadastro de Categorias de Cursos"
Local cVldExc := "DELTRMA110()"
Local cVldAlt := ".T." 

If AliasInDic( "AIQ" )
	dbSelectArea( "AIQ" )
	AIQ->(dbSetOrder(1))	
	AxCadastro( cAlias, cTitulo, cVldExc, cVldAlt )
Else
	MsgAlert( STR0002 )	   		//"Tabela de Cadastro de Categorias de Cursos (AIQ) não encontrada!"
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DELTRMA110()
Valida a Exclusão de Categorias de Cursos (AIQ)

@author Diego Santos
@since 31/05/2016
@version P12.1.7
/*/
//-------------------------------------------------------------------

Function DELTRMA110

Local cQuery 	:= ""
Local cAliasQry := "EXCAIQ"
Local lRet 		:= .T.

//Verifica a utilizacao da categoria na RA1
cQuery := "SELECT * FROM "+RetSqlName("RA1")+" RA1 "
cQuery += "WHERE "
cQuery += "RA1.RA1_FILIAL = '"+xFilial("RA1")+"' AND "
cQuery += "RA1.RA1_CATEG = '"+AIQ->AIQ_CODIGO+"' AND "
cQuery += "RA1.D_E_L_E_T_ = '' "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
If (cAliasQry)->(!Eof())
	lRet := .F.
EndIf
(cAliasQry)->(DbCloseArea())

If lRet
	//Verifica a utilizacao da categoria na SQT
	cQuery := "SELECT * FROM "+RetSqlName("SQT")+" SQT "
	cQuery += "WHERE "
	cQuery += "SQT.QT_FILIAL = '"+xFilial("SQT")+"' AND "
	cQuery += "SQT.QT_CATEG = '"+AIQ->AIQ_CODIGO+"' AND "
	cQuery += "SQT.D_E_L_E_T_ = '' "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	If (cAliasQry)->(!Eof())
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())
EndIf

If !lRet
	MsgAlert( STR0003, STR0004 ) //"Existem cursos vinculados a esta categoria, não sendo permitida então a exclusão da mesma."###"Atenção"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AIQRA1()
Consulta especifica de categoria de cursos (RA4_CATCUR).

@author Diego Santos
@since 01/06/2016
@version P12.1.12
/*/
//-------------------------------------------------------------------

Function AIQRA1()

Local lRet 		:= .T.
Local nPosCateg

nPosCateg := aScan( aHeader , { |x| AllTrim(x[2]) == "RA4_CATCUR" })

lRet := RA1->RA1_CATEG == aCols[n][nPosCateg]

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} AIQSQT()
Consulta especifica de categoria de cursos (Q9_CATCUR).

@author Diego Santos
@since 01/06/2016
@version P12.1.12
/*/
//-------------------------------------------------------------------

Function AIQSQT()

Local lRet 		:= .T.
Local nPosCateg

nPosCateg := aScan( aHeader , { |x| AllTrim(x[2]) == "Q9_CATCUR" })

lRet := SQT->QT_CATEG == aCols[n][nPosCateg]

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GATCUR()
Condição de gatilho para que o usuário não altere a categoria e permaneça um
preenchido no aCols (TRMA100) um curso não pertencente a essa categoria.

@author Diego Santos
@since 01/06/2016
@version P12.1.12
/*/
//-------------------------------------------------------------------

Function GATCUR

Local nPosCurso := aScan( aHeader , { |x| AllTrim(x[2]) == "RA4_CURSO" })
Local nPosDesc	:= aScan( aHeader , { |x| AllTrim(x[2]) == "RA4_DESCCU" })

Local lRet := .T.

If Posicione("RA1", 1, xFilial("RA1")+aCols[n][nPosCurso], "RA1_CATEG" ) == M->RA4_CATCUR
	lRet := .F. 
EndIf

If lRet
	aCols[n][nPosDesc] := ""
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GATCEX()
Condição de gatilho para que o usuário não altere a categoria e permaneça um
preenchido no aCols (TRMA100) um curso externo não pertencente a essa categoria.

@author Diego Santos
@since 01/06/2016
@version P12.1.12
/*/
//-------------------------------------------------------------------

Function GATCEX

Local nPosCurso := aScan( aHeader , { |x| AllTrim(x[2]) == "Q9_CURSO" })
Local nPosDesc	:= aScan( aHeader , { |x| AllTrim(x[2]) == "Q9_DESCRIC" })
Local lRet 		:= .T.

If Posicione("SQT", 1, xFilial("SQT")+aCols[n][nPosCurso], "QT_CATEG" ) == M->Q9_CATCUR
	lRet := .F. 
EndIf

If lRet
	aCols[n][nPosDesc] := ""
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} INIRA4CAT()
Inicializador padrão do campo RA4_CATDES

@author Diego Santos
@since 01/06/2016
@version P12.1.12
/*/
//-------------------------------------------------------------------

Function INIRA4CAT

Local cCateg
Local cRet 	 := "" 

If !Inclui
	cCateg := Posicione("RA1", 1, xFilial("RA1")+RA4->RA4_CURSO, "RA1_CATEG")
	cRet   := Posicione("AIQ", 1, xFilial("AIQ")+cCateg, "AIQ_DESCRI")
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} INIQ9CAT()
Inicializador padrão do campo Q9_CATDES

@author Diego Santos
@since 01/06/2016
@version P12.1.12
/*/
//-------------------------------------------------------------------

Function INIQ9CAT

Local cCateg
Local cRet 	 := "" 

If !Inclui
	cCateg := Posicione("SQT", 1, xFilial("SQT")+SQ9->Q9_CURSO, "QT_CATEG")
	cRet   := Posicione("AIQ", 1, xFilial("AIQ")+cCateg, "AIQ_DESCRI")
EndIf

Return cRet
