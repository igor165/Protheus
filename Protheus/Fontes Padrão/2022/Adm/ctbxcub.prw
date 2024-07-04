#INCLUDE "PROTHEUS.CH"
#INCLUDE "CTBXCUB.CH"

//amarracao
//------------------------------------------------------------------------------------------------------//
// Classe que retorna a configuração (parametrizacao) de acordo a estrutura do cubo                                                               //
//------------------------------------------------------------------------------------------------------//
//AMARRACAO
CLASS Ctb_Exec_Cube
// Declaracao das propriedades da Classe

DATA Code_Cube      // codigo do cubo
DATA Currency_Cube  // Moeda
DATA Level_Cube     // Nivel do cubo
DATA Type_Of_Balance  // Tipo de Saldo
DATA Quantity_Values     // Quantidade de valores a ser retornada pela query

DATA oStructCube

DATA cDBType
DATA lQuery
DATA lOracle
DATA lPostgres
DATA lDB2
DATA lInformix
DATA cSrvType
DATA cFilCVX
DATA cOpConcat

DATA lSintetica
DATA lForceNoSint
DATA lZerado

DATA aQueryDim
DATA aQuery
DATA aArqTmp
DATA aFilesErased
DATA aDatFec
DATA aSelFil

// Declaração dos Métodos da Classe
METHOD New(cCodeCube, cCurrency, cTypeBalance, nLevel, nQtValue, aEntVazio) CONSTRUCTOR

METHOD CtbStructCube()
METHOD Ctb_Run_Struct_Cube(aEntVazio)

METHOD SetAddFilesErased(cArqTmp)
METHOD ErasedFiles()
METHOD SetAddTempFiles(cArquivo)

METHOD Set_Level_Cube( nNivel )
METHOD Set_aSelFil( _aFiliais_ )

METHOD CtbAllDatFec()
METHOD CtbDatFec(dData)

METHOD CtbCriaQueryDim()
METHOD CtbQueryDim(cQryDim)

METHOD CtbCriaQry(lMovimento, aDtIni, aDtFim, cArquivo, lAllNiveis, lFechamento)
METHOD CtbBuildQry( cArquivo, nColProc, cAlias, lAllNiveis, cWhereAdd)

METHOD CtbAddCpoQry(cAlias, lAllNiveis, nNivCubo, nMaxNivel)
METHOD CtbAddGrpQry(lAllNiveis, nNivCubo, nMaxNivel,cAlias)

METHOD CtbCriaTemp()
METHOD CtbPopulaTemp(cArquivo)
METHOD CtbQryFinal( cAliasSld,cArqTmp)

ENDCLASS

//------------------------------------------------------------------------------------------------------//
METHOD New(cCodeCube, cCurrency, cTypeBalance, nLevel, nQtValue, aEntVazio) CLASS Ctb_Exec_Cube

DEFAULT aEntVazio := {}

Self:Code_Cube := cCodeCube
Self:Currency_Cube := cCurrency
Self:Level_Cube := nLevel
Self:Type_Of_Balance := cTypeBalance
Self:Quantity_Values := nQtValue

Self:cDBType	:= Alltrim(Upper(TCGetDB()))
Self:lQuery 	:= ( TCSrvType() # "AS/400" )
Self:cSrvType := Alltrim(Upper(TCSrvType()))
Self:lOracle		:= "ORACLE"   $ Self:cDBType
Self:lPostgres 	:= "POSTGRES" $ Self:cDBType
Self:lDB2		:= "DB2"      $ Self:cDBType
Self:lInformix 	:= "INFORMIX"   $ Self:cDBType
Self:cFilCVX 	:= xFilial("CVX")
Self:cOpConcat  	:= If( Self:lOracle .Or. Self:lPostgres .Or. Self:lDB2 .Or. Self:lInformix, " || ", " + " )

Self:lSintetica := .F.
Self:lForceNoSint := .F.
Self:lZerado := .F.

Self:oStructCube := Ctb_Cfg_Struct_Cube():New(aEntVazio)

Self:CtbStructCube(aEntVazio)

Self:aQueryDim := Array(Self:oStructCube:nMaxNiveis)
Self:aQuery := Array(Self:oStructCube:nMaxNiveis)

Self:aArqTmp := {}
Self:aFilesErased := {}
Self:aDatFec := Self:CtbAllDatFec()

Self:aSelFil := {}

Return Self

//------------------------------------------------------------------------------------------------------//

METHOD Set_Level_Cube(nNivel)  CLASS Ctb_Exec_Cube
Self:Level_Cube := nNivel
Return

//------------------------------------------------------------------------------------------------------//

METHOD Set_aSelFil(_aFiliais_)  CLASS Ctb_Exec_Cube
Self:aSelFil := aClone(_aFiliais_)
Return

//------------------------------------------------------------------------------------------------------//
METHOD CtbStructCube(aEntVazio) CLASS Ctb_Exec_Cube

Self:oStructCube:Ctb_Run_Struct_Cube(Self:Code_Cube, aEntVazio)

Return

//------------------------------------------------------------------------------------------------------//

METHOD SetAddFilesErased(cArqTmp)  CLASS Ctb_Exec_Cube
aAdd(Self:aFilesErased, cArqTmp )
Return

METHOD ErasedFiles() CLASS Ctb_Exec_Cube
Local nX
Local aArea := GetArea()

For nX := 1 TO Len(Self:aFilesErased)
	If Self:aFilesErased[nX] <> NIL .And. Valtype(Self:aFilesErased[nX]) == "C" .And. !Empty(Self:aFilesErased[nX])
		If Select(Self:aFilesErased[nX]) > 0
			dbSelectArea(Self:aFilesErased[nX])
			dbCloseArea()
		EndIf
		MsErase(Self:aFilesErased[nX])
	EndIf
Next

RestArea(aArea)

Return
//------------------------------------------------------------------------------------------------------//

METHOD SetAddTempFiles(cArquivo)  CLASS Ctb_Exec_Cube
aAdd(Self:aArqTmp, cArquivo )
Return

//------------------------------------------------------------------------------------------------------//

METHOD CtbAllDatFec() CLASS Ctb_Exec_Cube
Local aDatFec := {}
Local cQuery := ""
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³query para retornar as datas de fechamento na tabela CVZ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
cQuery += " SELECT DISTINCT CVZ_DATA FROM " + RetSqlName("CVZ")+ " WHERE D_E_L_E_T_ = ' ' ORDER BY CVZ_DATA "

cQuery := ChangeQuery( cQuery  )

//abre a query com mesmo alias da dimensao
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "ArqFec", .T., .T. )

While ArqFec->(! Eof() )
	aAdd(aDatFec,ArqFec->CVZ_DATA)  //Grava as datas de fechamento no array em formato caracter AAAAMMDD
	ArqFec->(dbSkip())
EndDo

dbSelectArea("ArqFec")
dbCloseArea()

Return(aDatFec)


//------------------------------------------------------------------------------------------------------//

METHOD CtbDatFec(dData) CLASS Ctb_Exec_Cube
Local cDatFec := "19800101"  //considera data de fechamento inicial em 01/01/80
Local nZ

If Len(Self:aDatFec) > 0
	//percorre o array aDatFec do Ultimo elemento para o primeiro
	For nZ := Len(Self:aDatFec) TO 1 STEP -1
	    //verifica se data passado como parametro de entrada é maior ou igual a data de fechamento posicionada no laco for...next
		If Self:aDatFec[nZ] <= DTOS(dData)  //compara com DTOS pois o array aDatFec esta como caracter formato AAAAMMDD
			cDatFec := Self:aDatFec[nZ]     //caso atenda a condicao atribue data de fechamento e sai do laco
			Exit
		EndIf

	Next

EndIf

Return(cDatFec)  //caracter formato AAAAMMDD

//------------------------------------------------------------------------------------------------------//
METHOD CtbCriaQueryDim() CLASS Ctb_Exec_Cube

Local cFiltro		:=	""
Local cFilSintOK	:=	""
Local cBetWeen :=	""
Local cChvAux
Local aCampos
Local nZ
Local cIni
Local cFim
Local cCampoTmp
Local nTamSX3
Local cQuery  		:= ""
Local lFiltro 		:= .F.
Local lCondSint 	:= .F.
Local lVazio 		:= .F.
Local cQryVazio 	:= ""
Local aRetQry := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Traduz o filtro para ser executado na query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(Self:oStructCube:aFiltros[Self:Level_Cube])
	cFiltro	:= PcoParseFil( Self:oStructCube:aFiltros[Self:Level_Cube], Self:oStructCube:aAlias[Self:Level_Cube] )
	lFiltro := ! Empty(cFiltro)
Else
	lFiltro := .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria um filtro para nao trazer as sinteticas se nao deve processalas a aprtir do segundo nivel³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Empty(Self:oStructCube:aCondSint[Self:Level_Cube])
	If ( ! Self:lSintetica .And. Self:Level_Cube > 1 ) .Or. Self:lForceNoSint   //no primeiro nivel sempre apresenta as contas sinteticas
		cFilSintOk 	:= PcoParseFil( "!(" + Alltrim(Self:oStructCube:aCondSint[Self:Level_Cube]) + ")", Self:oStructCube:aAlias[Self:Level_Cube])
		lCondSint := ! Empty(cFilSintOk)
	Else
		lCondSint := .T.
	Endif
Else
	lCondSint := .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Converte o De-Ate em um between para ser utilizado na query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Empty(Self:oStructCube:aFim[Self:Level_Cube]) .And. ;     //se especificado filtro final ( ate )
	! ( Empty(Self:oStructCube:aIni[Self:Level_Cube]) .And. ;   // se nao for filtro de-ate = branco a ZZZZZZZZZZZZZZ
		Upper(Alltrim(Self:oStructCube:aFim[Self:Level_Cube]))==Replicate('z',Len(Alltrim(Self:oStructCube:aFim[Self:Level_Cube]))) )

	cChvAux := Alltrim( Upper( Self:oStructCube:aChave[Self:Level_Cube] ) )

	If At("DTOS(", cChvAux ) > 0
		cChvAux := StrTran( cChvAux , ")", "")
		cChvAux := StrTran( cChvAux , "DTOS(", "")
	EndIf

	aCampos	:=	Str2Arr( cChvAux , "+")  //quebra em array por delimitador "+"

	cIni := Self:oStructCube:aIni[Self:Level_Cube]
	cFim := Self:oStructCube:aFim[Self:Level_Cube]

	If Len(aCampos) == 1 .And. cIni == cFim

		//usa a variavel cBetWeen mas o conteudo sera campo = conteudo
//		cCampoTmp	:=	Alltrim( Substr(aCampos[1], At("->", aCampos[1])+2 ) )
		cCampoTmp	:=	Iif(At("->", aCampos[1]) != 0,	Alltrim( Substr(aCampos[1], At("->", aCampos[1])+2 ) ),Alltrim(aCampos[1]))
		cBetWeen 	:=	cCampoTmp + " = '" + cIni + "' AND "

	Else

		cBetWeen 	:= ""

		For nZ := 1 To Len(aCampos)

			If Len(cFim) > 0

				cCampoTmp	:= Iif(At("->", aCampos[nZ]) != 0,	Alltrim( Substr(aCampos[nZ], At("->", aCampos[nZ])+2 ) ),Alltrim(aCampos[nZ]))
				nTamSX3 	:= TamSX3(cCampoTmp)[1]
	                //constroi a clausula between para a query de acordo com os campos
				cBetWeen 	+=	cCampoTmp + " BETWEEN '"
				cBetWeen 	+=	Substr( cIni, 1, nTamSX3 )
				cBetWeen 	+=	"' AND '"
				cBetWeen 	+=	Substr(cFim, 1, nTamSX3 )
				cBetWeen 	+=	"' AND "
		    	cIni 		:=	Substr(cIni, nTamSX3+1)
		    	cFim 		:=	Substr(cFim, nTamSX3+1)

			Endif

		Next

	EndIf

EndIf

cQuery 	+= " SELECT "
cChvAux := Alltrim( StrTran( Upper( Self:oStructCube:aChave[Self:Level_Cube] ) , Self:oStructCube:aAlias[Self:Level_Cube]+"->", "") )
cChvAux := Alltrim( StrTran( cChvAux , "+", Self:cOpConcat ) )
cChvAux += " N_I_V_"+StrZero(Self:Level_Cube,2)+" "
cQuery 	+= cChvAux
cQuery 	+= " FROM "
cQuery 	+= RetSqlName(Self:oStructCube:aAlias[Self:Level_Cube]) + " " +Self:oStructCube:aAlias[Self:Level_Cube]
cQuery 	+= " WHERE "

//monta a clausula where a ser utilizado na query
If  SubStr( Self:oStructCube:aAlias[Self:Level_Cube], 1, 1) == "S"
	//se a primeira letra do alias for "S" entao
	//considera campo filial a partir da segunda exemplo tabela SA1 - campo A1_FILIAL
	cQuery 	+= SubStr( Self:oStructCube:aAlias[Self:Level_Cube], 2, 2 ) + "_FILIAL" + " = '"
	cQuery 	+= xFilial( Self:oStructCube:aAlias[Self:Level_Cube] )
	cQuery 	+= "' AND "
Else
	cQuery 	+= Self:oStructCube:aAlias[Self:Level_Cube] + "_FILIAL" + " = '"
	cQuery 	+= xFilial( Self:oStructCube:aAlias[Self:Level_Cube] )
	cQuery 	+= "' AND "
EndIf

If Self:oStructCube:aAlias[Self:Level_Cube] == "CV0" .And. !Empty(Alltrim(Self:oStructCube:aPlano[Self:Level_Cube]))
	cQuery 	+= " CV0_PLANO " + " = '"+ Self:oStructCube:aPlano[Self:Level_Cube]+"' AND "
EndIf

If ! Empty(cBetween)
	cQuery 	+= cBetween
Endif

If ! Empty(cFiltro)
	cQuery += " (" + cFiltro	+") AND "// Adiciona expressao de filtro convertida para SQL
Endif

If ! Empty(cFilSintOk)
	cQuery += " (" + cFilSintOk	+") AND "// Adiciona expressao de filtro de sinteticas convertida para SQL
Endif

cQuery += Self:oStructCube:aAlias[Self:Level_Cube]+".D_E_L_E_T_ =  ' ' "

If lFiltro .And. lCondSint .And. Self:oStructCube:aVazio[Self:Level_Cube]
	//pq se lFiltro And lCondSint vai ser chamada a rotina CtbQueryDim() que ja coloca este bloco novamente
	If Self:cSrvType == "ISERIES"
		lVazio := .T.
		//a clausula FROM soh foi colocada pq a change query acaba modificando a query quando nao tem FROM
		//entao foi feito uma select da tabela CT0 que normalmente e uma tabela com poucos registros
		//e recuperamos um unico registro com MIN(R_E_C_N_O_)
		cQryVazio 	+= " SELECT '"+Space(Self:oStructCube:aTamNiv[Self:Level_Cube])+"' N_I_V_"+StrZero(Self:Level_Cube,2)+" FROM "+RetSqlName("CT0")
		cQryVazio 	+= " WHERE CT0_FILIAL = '"+xFilial("CT0")+"' "
		cQryVazio 	+= " AND D_E_L_E_T_ = ' '"
		cQryVazio 	+= " AND R_E_C_N_O_ = ( "
		cQryVazio 	+= " SELECT MIN(R_E_C_N_O_) FROM "+RetSqlName("CT0")
		cQryVazio 	+= " WHERE CT0_FILIAL = '"+xFilial("CT0")+"' "
		cQryVazio 	+= " AND D_E_L_E_T_ = ' ' ) "
	Else
		lVazio := .F.
		cQryVazio := " "
		//a clausula FROM soh foi colocada pq a change query acaba modificando a query quando nao tem FROM
		//entao foi feito uma select da tabela CT0 que normalmente e uma tabela com poucos registros
		//e recuperamos um unico registro com MIN(R_E_C_N_O_)
		cQuery 	+= " UNION "
		cQuery 	+= " SELECT '"+Space(Self:oStructCube:aTamNiv[Self:Level_Cube])+"' N_I_V_"+StrZero(Self:Level_Cube,2)+" FROM "+RetSqlName("CT0")
		cQuery 	+= " WHERE CT0_FILIAL = '"+xFilial("CT0")+"' "
		cQuery 	+= " AND D_E_L_E_T_ = ' '"
		cQuery 	+= " AND R_E_C_N_O_ = ( "
		cQuery 	+= " SELECT MIN(R_E_C_N_O_) FROM "+RetSqlName("CT0")
		cQuery 	+= " WHERE CT0_FILIAL = '"+xFilial("CT0")+"' "
		cQuery 	+= " AND D_E_L_E_T_ = ' ' ) "
	EndIf

EndIf

If lFiltro .And. lCondSint  // se filtro foi resolvido
	If lVazio  //se nao concatenou na query a opcao de vazio
		Self:aQueryDim[Self:Level_Cube] := { cQuery, cQryVazio }
	Else
		Self:aQueryDim[Self:Level_Cube] := { cQuery, "" }
	EndIf
Else
	aRetQry := Self:CtbQueryDim(cQuery)
	cQuery := aRetQry[1]
	lFiltro := aRetQry[2]
	lCondSint := aRetQry[3]
	lVazio := aRetQry[4]
	cQryVazio := aRetQry[5]

	If lVazio
		Self:aQueryDim[Self:Level_Cube] := { cQuery, cQryVazio }
	Else
		Self:aQueryDim[Self:Level_Cube] := { cQuery, "" }
	EndIf
EndIf

Return( { cQuery, lFiltro, lCondSint, lVazio, cQryVazio } )

//------------------------------------------------------------------------------------------------------//
METHOD CtbQueryDim(cQryDim) CLASS Ctb_Exec_Cube

Local cAliasDim, cAliasTmp
Local cCpoDim, nTamDim, cExpr, cExprAux
Local lVazio 	:= .F.
Local cQryVazio := ""

cAliasDim := Self:oStructCube:aAlias[Self:Level_Cube]
cExprAux :=Self:oStructCube:aChave[Self:Level_Cube]
cCpoDim := cExprAux
nTamDim := TamSx3(cCpoDim)[1]//&("Len("+cCpoDim+")")
cCpoDim := StrTran(cCpoDim, cAliasDim+"->", "")
cCpoDim := StrTran(cCpoDim, "+", "")
cCpoDim := Alltrim(PadR(cCpoDim, 10))
cAliasTmp := cAliasDim+"AUX"

cQryDim := StrTran(cQryDim, "SELECT ", "SELECT R_E_C_N_O_ RECNOAUX , ")

dbSelectArea(cAliasDim)

//cria arquivo temporario que contera as chaves validas para esta dimensao direto no banco de dados
cArqTmp := CriaTrab( , .F.)
MsErase(cArqTmp)

aStructDim := {}
aAdd(aStructDim, { cCpoDim, "C", nTamDim, 0 } )
MsCreate(cArqTmp,aStructDim, "TOPCONN")
If cPaisLoc != "RUS"
	Sleep(1000)
EndIf

Self:SetAddFilesErased(cArqTmp)

dbUseArea(.T., "TOPCONN",cArqTmp,cArqTmp/*cAlias*/,.T.,.F.)

// Cria o indice temporario
IndRegua(cArqTmp/*cAlias*/,cArqTmp,cCpoDim,,)

cQryDim := ChangeQuery( cQryDim )

//abre a query com mesmo alias da dimensao
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQryDim), cAliasTmp, .T., .T. )
While (cAliasTmp)->( ! Eof() )

	//vai para o registro da tabela original por exemplo conta orcamentaria tabela AK5
	dbSelectArea(cAliasDim)
	(cAliasDim)->(dbGoto((cAliasTmp)->RECNOAUX))

    //macro executa o filtro
	If ! Empty(Self:oStructCube:aFiltros[Self:Level_Cube]) .And. ! ( &(Self:oStructCube:aFiltros[Self:Level_Cube]) )
		dbSelectArea(cAliasTmp)
		(cAliasTmp)->( dbSkip() )
		Loop
	EndIf

    //macro executa a condicao de sintetica
    If Self:Level_Cube > 1  //porque no primeiro nivel sempre apresenta as contas sinteticas
		If ! Empty(Self:oStructCube:aCondSint[Self:Level_Cube]) .And. &(Self:oStructCube:aCondSint[Self:Level_Cube])
			dbSelectArea(cAliasTmp)
			(cAliasTmp)->( dbSkip() )
			Loop
		EndIf
	EndIf

    cExpr := (cAliasDim)->(&cExprAux)

	dbSelectArea(cArqTmp)
	RecLock(cArqTmp, .T.)
	//como so tem um campo posso usar fieldput direto com 1 fixo
	FieldPut(1, cExpr)
	MsUnLock()

	dbSelectArea(cAliasTmp)
	(cAliasTmp)->( dbSkip() )

EndDo
//Fecha o alias da query
dbSelectArea(cAliasTmp)
dbCloseArea()

cQueryDim := " SELECT " + cCpoDim + " FROM " + cArqTmp + " "

If Self:oStructCube:aVazio[Self:Level_Cube]
	If Self:cSrvType == "ISERIES"
		lVazio := .T.
		//a clausula FROM soh foi colocada pq a change query acaba modificando a query quando nao tem FROM
		//entao foi feito uma select da tabela CT0 que normalmente e uma tabela com poucos registros
		//e recuperamos um unico registro com MIN(R_E_C_N_O_)
		cQryVazio 	+= " SELECT ' ' "+cCpoDim+" FROM "+RetSqlName("CT0")
		cQryVazio 	+= " WHERE CT0_FILIAL = '"+xFilial("CT0")+"' "
		cQryVazio 	+= " AND D_E_L_E_T_ = ' '"
		cQryVazio 	+= " AND R_E_C_N_O_ = ( "
		cQryVazio 	+= " SELECT MIN(R_E_C_N_O_) FROM "+RetSqlName("CT0")
		cQryVazio 	+= " WHERE CT0_FILIAL = '"+xFilial("CT0")+"' "
		cQryVazio 	+= " AND D_E_L_E_T_ = ' ' ) "
	Else
		lVazio := .F.
		cQryVazio := " "
		//a clausula FROM soh foi colocada pq a change query acaba modificando a query quando nao tem FROM
		//entao foi feito uma select da tabela CT0 que normalmente e uma tabela com poucos registros
		//e recuperamos um unico registro com MIN(R_E_C_N_O_)
		cQueryDim 	+= " UNION "
		cQueryDim 	+= " SELECT ' '"+cCpoDim+" FROM "+RetSqlName("CT0")
		cQueryDim 	+= " WHERE CT0_FILIAL = '"+xFilial("CT0")+"' "
		cQueryDim 	+= " AND D_E_L_E_T_ = ' '"
		cQueryDim 	+= " AND R_E_C_N_O_ = ( "
		cQueryDim 	+= " SELECT MIN(R_E_C_N_O_) FROM "+RetSqlName("CT0")
		cQueryDim 	+= " WHERE CT0_FILIAL = '"+xFilial("CT0")+"' "
		cQueryDim 	+= " AND D_E_L_E_T_ = ' ' ) "
	EndIf

EndIf

Return({ cQueryDim, .F., .F., lVazio, cQryVazio })

//------------------------------------------------------------------------------------------------------//
METHOD CtbCriaTemp() CLASS Ctb_Exec_Cube

Local aStructCVX := aClone(Self:oStructCube:aStructCVX)
Local cIndTmpCVX := ""
Local nLenStruct := Len(Self:oStructCube:aStructCVX)  //usado para limitar os campos de dimensoes
Local nX

//acaba definicao da estrutura do temporario
aAdd(aStructCVX,{"CVX_ID","C", 10, 00})
aAdd(aStructCVX,{"CVX_PROC","C", 1, 00})
aAdd(aStructCVX,{"CVX_NIVEL","N", 2, 00})
aAdd(aStructCVX,{"CVX_IDPAI","C", 10, 00})

//agora adiciona campos de saldos
For nX := 1 TO Self:Quantity_Values
	aAdd(aStructCVX,{"CVX_SLCR"+StrZero(nX,2),"N", 18, 04})
	aAdd(aStructCVX,{"CVX_SLDB"+StrZero(nX,2),"N", 18, 04})
	aAdd(aStructCVX,{"CVX_SALD"+StrZero(nX,2),"N", 18, 04})
Next

//laco para montar indice a ser utilizada no indregua
For nX := 1 TO nLenStruct
	cIndTmpCVX += aStructCVX[nX, 1]
	If nX < nLenStruct
		cIndTmpCVX+="+"
	EndIf
Next

// Cria a tabela temporia direto no banco de dados
cArquivo := CriaTrab( , .F.)
MsErase(cArquivo)

MsCreate(cArquivo,aStructCVX, "TOPCONN")
If cPaisLoc != "RUS"
	Sleep(1000)
EndIf

dbUseArea(.T., "TOPCONN",cArquivo,cArquivo/*cAlias*/,.F.,.F.)

// Cria o indice temporario
IndRegua(cArquivo/*cAlias*/,cArquivo,cIndTmpCVX,,)

Self:SetAddTempFiles(cArquivo)
Self:SetAddFilesErased(cArquivo)

Return(cArquivo)

//------------------------------------------------------------------------------------------------------//
METHOD CtbCriaQry(lMovimento, aDtIni, aDtFim, cArquivo, lAllNiveis, lFechamento) CLASS Ctb_Exec_Cube

Local nY
Local nX
Local nZ

Local dDtIni,dDtFim,dDtFec
Local cQuery
Local cQryInterna := ""
Local cGroupByQry := ""
Local nPerIni := 1
Local lUniaoQry   := .F.

DEFAULT lMovimento 	:= .F.
DEFAULT aDtIni 		:= {}
DEFAULT aDtFim		:= {}
DEFAULT lAllNiveis 	:= .F.
DEFAULT lFechamento 	:= .F.

For nX := 1 TO Self:oStructCube:nMaxNiveis
	Self:aQuery[nX] :=  {}
	For nZ := 1 to Len(aDtFim)
		aAdd(Self:aQuery[nX], {})
	Next // nZ
Next //nY

If lMovimento

	If Empty(aDtIni)  //quando nao for passado o parametro considera sempre inicio do mes (mensal)
		For nY := 1 TO Len(aDtFim)
			aAdd(aDtIni, STOD(Left(DTOS(aDtFim[nY]),6)+"01"))
		Next
	EndIf

	For nY := 1 to Len(aDtFim)

    	dDtIni := aDtIni[nY]
    	dDtFim 	:= aDtFim[nY]
		cQuery := " "
		cQryInterna := " "
		cGroupByQry := ""

        cWhereAdd := " CVX.CVX_DATA >= '"+DTOS(dDtIni)+"'  AND "
        cWhereAdd += " CVX.CVX_DATA <= '" + DTOS(dDtFim)+ "' "

		aQryAux := Self:CtbBuildQry( cArquivo, nY/*nColProc*/, "CVX"/*cAlias*/,lAllNiveis, cWhereAdd, (nY == 1 .And. Len(aDtFim) > 1))

		cQuery 		+= aQryAux[1]
		cQryInterna += aQryAux[2]
		cGroupByQry := aQryAux[3]

   		If Self:cSrvType != "ISERIES" // outros bancos de dados que nao DB2 com ambiente AS/400
                                     // ja inclui a sub query (cQryInterna) na query principal que sera executada
	         If Self:lPostgres
				cQuery += "( "+ cQryInterna + " ) AS TMPSALDO"
			Else
				cQuery += "( "+ cQryInterna + " ) TMPSALDO "
			EndIf
	    Else
	    	cQuery += " "
	    EndIf

		cQuery += CRLF

		cQuery += " GROUP BY "+cGroupByQry+"CVX_NIV"+StrZero(Self:Level_Cube, 2)"
		cQuery += Self:CtbAddGrpQry(lAllNiveis, Self:Level_Cube, Self:oStructCube:nMaxNiveis, "CVX")

		cQuery += CRLF

		cQuery += " ORDER BY CVX_NIV"+StrZero(Self:Level_Cube, 2)"
		cQuery += Self:CtbAddGrpQry(lAllNiveis, Self:Level_Cube, Self:oStructCube:nMaxNiveis, "CVX")

		cQuery += CRLF

   		If Self:cSrvType != "ISERIES" // outros bancos de dados que nao DB2 com ambiente AS/400
                                     // ja inclui a sub query na query principal que sera executada
			aAdd( Self:aQuery[Self:Level_Cube, nY], cQuery)
		Else
			aAdd( Self:aQuery[Self:Level_Cube, nY], "###ISERIES###"+cQryInterna)
			aAdd( Self:aQuery[Self:Level_Cube, nY], cQuery)
		EndIf

	Next

    // termino por movimento

Else

	// por saldo
	nPerIni := 1
   	dDtFec 	:= CtoD("01/01/80")

	If lFechamento
	    dDtFec 	:= StoD( Self:CtbDatFec(aDtFim[Len(aDtFim)]) )  //Converte para data pois no array Self:aDataFec esta como caracter no formato AAAAMMDD
	    //tratamento para data de fechamento - se data de fechamento estiver no range array aDtFim
		If ! Empty(dDtFec) .And. dDtFec >= aDtFim[1] .And. dDtFec <= aDtFim[Len(aDtFim)]
			//varre o array aDatFim e pega periodo inicial quando aDtFim[nX] maior ou igual data de fechamento
			For nX := 1 TO Len(aDatFim)
				If aDtFim[nX] >= dDtFec
					nPerIni := nX
					Exit
				EndIf
			Next //nX

		EndIf
	EndIf

	If nPerIni > 1
		Aviso(STR0001, STR0002+ DtoC(dDtFec)+".", {"Ok"})  //"Atencao"##"Sera processado a partir da data de fechamento "
	EndIf

	// por saldo na data
	For nY := nPerIni to Len(aDtFim)

    	dDtFim := aDtFim[nY]
    	aQryAux := {}
    	cQuery := ""
    	cQryInterna := ""

		If lFechamento .And. ! Empty(dDtFec) //saldo anterior

            cWhereAdd := cQryInterna += " CVZ.CVZ_DATA = '" + DtoS(dDtFec)+"' "

			aQryAux := Self:CtbBuildQry( cArquivo, nY/*nColProc*/, "CVZ"/*cAlias*/,lAllNiveis, cWhereAdd)

			If dDtFim == dDtFec

				cQuery 		:= aQryAux[1]
				cQryInterna := aQryAux[2]
				cGroupByQry := aQryAux[3]


		   		If Self:cSrvType != "ISERIES" // outros bancos de dados que nao DB2 com ambiente AS/400
		                                     // ja inclui a sub query (cQryInterna) na query principal que sera executada
		            If Self:lPostgres
						cQuery += "( "+ cQryInterna + " ) AS TMPSALDO"
					Else
						cQuery += "( "+ cQryInterna + " ) TMPSALDO "
					EndIf
			    Else
			    	cQuery += " "
			    EndIf

				cQuery += CRLF

				cQuery += " GROUP BY "+cGroupByQry+"CVZ_NIV"+StrZero(Self:Level_Cube, 2)"
				cQuery += Self:CtbAddGrpQry(lAllNiveis, Self:Level_Cube, Self:oStructCube:nMaxNiveis, "CVX")
				cQuery += CRLF

				cQuery += " ORDER BY CVX_NIV"+StrZero(Self:Level_Cube, 2)"
				cQuery += Self:CtbAddGrpQry(lAllNiveis, Self:Level_Cube, Self:oStructCube:nMaxNiveis, "CVX")
				cQuery += CRLF

	    		If Self:cSrvType != "ISERIES" // outros bancos de dados que nao DB2 com ambiente AS/400
                                     // ja inclui a sub query na query principal que sera executada
					aAdd( Self:aQuery[ Self:Level_Cube, nY], cQuery)
				Else
					aAdd( Self:aQuery[ Self:Level_Cube, nY], "###ISERIES###"+cQryInterna)
					aAdd( Self:aQuery[ Self:Level_Cube, nY], cQuery)
				EndIf

				Loop //retorna para FOR e vai para proxima data fim

            Else

				cQryInterna := aQryAux[2]

				//aberto parenteses apos UNION ALL pois a changequery nao retornava a query corretamente
				//verifique que a mesma e fechada apos a concatenacao da sub-select
				cQryInterna += " UNION ALL ( "
				cQryInterna += CRLF

            EndIf

		    If dDtFec != LastDay(dDtFec)   //se nao for ultimo dia do mes deve correr tabela de saldo diario > fechamento ate fim do mes de fechamento

	            cWhereAdd := cQryInterna += " CVX.CVX_DATA > '" + DtoS(dDtFec)+"' AND "
	            cWhereAdd += cQryInterna += " CVX.CVX_DATA <= '" + DtoS(LastDay(dDtFec))+"' "

				aQryAux := Self:CtbBuildQry( cArquivo, nY/*nColProc*/, "CVX"/*cAlias*/,lAllNiveis, cWhereAdd)

				cQryInterna += aQryAux[2]

				//aberto parenteses apos UNION ALL pois a changequery nao retornava a query corretamente
				//verifique que a mesma e fechada apos a concatenacao da sub-select
				lUniaoQry   := .T.
				cQryInterna += " UNION ALL ( "
				cQryInterna += CRLF

		    EndIf

		EndIf

        //Somar tabela mensal CVY_DATA > Data de fechamento e menor data fim
        cWhereAdd := " CVY.CVY_DATA > '" + DtoS(LastDay(dDtFec))+"' AND "
        cWhereAdd += " CVY.CVY_DATA < '" + DtoS(dDtFim)+"' "

		aQryAux := Self:CtbBuildQry( cArquivo, nY/*nColProc*/, "CVY"/*cAlias*/,lAllNiveis, cWhereAdd )

		cQryInterna += aQryAux[2]
		cGroupByQry := aQryAux[3]

		//aberto parenteses apos UNION ALL pois a changequery nao retornava a query corretamente
		//verifique que a mesma e fechada apos a concatenacao da sub-select
		If lUniaoQry
			cQryInterna += " ) "
		EndIf

		cQryInterna += " UNION ALL ( "
		cQryInterna += CRLF

        //Somar tabela diaria CVX_DATA > Data de fechamento e maior ou igual ao 1o. dia do mes da data fim e menor ou igual data fim
        cWhereAdd := " CVX.CVX_DATA >= '" + Left(DtoS(dDtFim),6)+"01' AND "
        cWhereAdd += " CVX.CVX_DATA <= '" + DtoS(dDtFim)+"' "

		aQryAux := Self:CtbBuildQry( cArquivo, nY/*nColProc*/, "CVX"/*cAlias*/,lAllNiveis, cWhereAdd )

		cQuery 		+= aQryAux[1]
		cQryInterna += aQryAux[2]
		cGroupByQry := aQryAux[3]
		//Fechamento do UNION ALL
		cQryInterna += " ) "

   		If Self:cSrvType != "ISERIES" // outros bancos de dados que nao DB2 com ambiente AS/400
                                     // ja inclui a sub query (cQryInterna) na query principal que sera executada
            If Self:lPostgres
				cQuery += "( "+ cQryInterna + " ) AS TMPSALDO"
			Else
				cQuery += "( "+ cQryInterna + " ) TMPSALDO "
			EndIf
	    Else
	    	cQuery += " "
	    EndIf

		cQuery += CRLF

		cQuery += " GROUP BY "+StrTran(cGroupByQry,"CVY","CVX")+"CVX_NIV"+StrZero(Self:Level_Cube, 2)"
		cQuery += Self:CtbAddGrpQry(lAllNiveis, Self:Level_Cube, Self:oStructCube:nMaxNiveis, "CVX")
		cQuery += CRLF

		cQuery += " ORDER BY CVX_NIV"+StrZero(Self:Level_Cube, 2)"
		cQuery += Self:CtbAddGrpQry(lAllNiveis, Self:Level_Cube, Self:oStructCube:nMaxNiveis, "CVX")
		cQuery += CRLF

   		If Self:cSrvType != "ISERIES" // outros bancos de dados que nao DB2 com ambiente AS/400
                                     // ja inclui a sub query na query principal que sera executada
			aAdd( Self:aQuery[ Self:Level_Cube, nY], cQuery)
		Else
			aAdd( Self:aQuery[ Self:Level_Cube, nY], "###ISERIES###"+cQryInterna)
			aAdd( Self:aQuery[ Self:Level_Cube, nY], cQuery)
		EndIf

	Next

    // termino por saldo
EndIf

Return

//-----------------------------------------------------------------------------------------------------------//

METHOD CtbBuildQry( cArquivo, nColProc, cAlias, lAllNiveis, cWhereAdd, lSldAnt)   CLASS Ctb_Exec_Cube

Local cCode_Cube 		:= Self:Code_Cube
Local cCurrency_Cube 	:= Self:Currency_Cube
Local cType_Of_Balance := Self:Type_Of_Balance
Local nNivCubo 			:= Self:Level_Cube
Local aQueryDim 		:= Self:aQueryDim
Local nQtdValues 		:= Self:Quantity_Values
Local nMaxNivel 		:= Self:oStructCube:nMaxNiveis

Local cQuery := ""
Local cQryInterna := ""
Local nX
Local cGroupBy	:= ""
Local cTmpFil

DEFAULT lSldAnt			:= .F.

cQuery += " SELECT "

cQuery += Self:CtbAddCpoQry("CVX", lAllNiveis, nNivCubo, nMaxNivel)

//loop para montar agregados somatoria
For nX := 1 TO nQtdValues
	cQuery += ", SUM( CVX_SLDB"+StrZero(nX,2) +" ) CVX_SLDB"+StrZero(nX,2)
	cQuery += ", SUM( CVX_SLCR"+StrZero(nX,2) +" ) CVX_SLCR"+StrZero(nX,2)
	cQuery += ", SUM( CVX_SALD"+StrZero(nX,2) +" ) CVX_SALD"+StrZero(nX,2)
Next

If Alltrim(Upper(TCSrvType())) != "ISERIES" //outros bancos de dados que nao DB2 com ambiente AS/400
	cQuery += " FROM  "
	cQuery += CRLF

Else //banco de dados DB2 em ambiente AS/400
	cQuery += " FROM  ###ARQUIVO###"
	cQuery += CRLF

EndIf

cQryInterna := " SELECT "

cQryInterna += Self:CtbAddCpoQry(cAlias, lAllNiveis, nNivCubo, nMaxNivel)

// Colombia/Perú: CTR051QCol() - Balance parcial por entidad - Tratamiento para excluir saldos anteriores en cuentas de resultados
If !( cPaisLoc $ "COL|PER" .And. lSldAnt .And. FunName() == "CTBR051" .And. FindFunction("CTR051QCol") .And. CTR051QCol(nColProc, nQtdValues, cAlias, @cQryInterna) )
	//loop para montar agregados somatoria
	For nX := 1 TO nQtdValues
		cQryInterna += If( nX == nColProc, ", SUM("+cAlias+"."+cAlias+"_SLDDEB)",", 0")+" CVX_SLDB"+StrZero(nX,2)
		cQryInterna += If( nX == nColProc, ", SUM("+cAlias+"."+cAlias+"_SLDCRD)",", 0")+" CVX_SLCR"+StrZero(nX,2)
		cQryInterna += If( nX == nColProc, ", SUM("+cAlias+"."+cAlias+"_SLDCRD-"+cAlias+"."+cAlias+"_SLDDEB)",", 0")+" CVX_SALD"+StrZero(nX, 2)
	Next
EndIf

cQryInterna += " FROM " + RetSqlName(cAlias) + " "+cAlias+"  "
cQryInterna += CRLF
//---------------------------------------------------------------------------
cQryInterna += " WHERE "

cQryFil := GetRngFil( Self:aSelFil, cAlias, .T., @cTmpFil )   ////cQryInterna += " "+cAlias+"."+cAlias+"_FILIAL = '" + xFilial(cAlias) + "' AND "
Self:SetAddFilesErased(cTmpFil)
cQryInterna += " "+cAlias+"."+cAlias+"_FILIAL " + cQryFil + " AND "

cQryInterna += CRLF
cGroupBy	+= cAlias+"_FILIAL,"
cQryInterna += " "+cAlias+"."+cAlias+"_CONFIG = '" + cCode_Cube + "' AND "
cQryInterna += CRLF
cGroupBy	+= cAlias+"_CONFIG,"
cQryInterna += " "+cAlias+"."+cAlias+"_MOEDA = '" + cCurrency_Cube + "' AND "
cQryInterna += CRLF
cGroupBy	+= cAlias+"_MOEDA,"
cQryInterna += " "+cAlias+"."+cAlias+"_TPSALD = '" + cType_Of_Balance + "' AND "
cQryInterna += CRLF

cGroupBy	+= cAlias+"_TPSALD,"

If !Empty(cWhereAdd)
	cQryInterna += cWhereAdd
EndIf
cQryInterna += CRLF

For nX := 1 TO Len(aQueryDim)
	cQryInterna += " AND "
	If Empty(aQueryDim[nX, 2])
		cQryInterna += ""+cAlias+"."+cAlias+"_NIV"+StrZero(nX, 2)+ " IN ( "
		cQryInterna += aQueryDim[nX, 1]  //sub-query ja contemplando qdo campo do cubo nao for obrigatorio
		cQryInterna += " ) "
	Else
		cQryInterna += " ( "
		cQryInterna += ""+cAlias+"."+cAlias+"_NIV"+StrZero(nX, 2)+ " IN ( "
		cQryInterna += aQueryDim[nX, 1]  //sub-query
		cQryInterna += " ) "
		cQryInterna += " OR "
		cQryInterna += ""+cAlias+"."+cAlias+"_NIV"+StrZero(nX, 2)+ " IN ( "
		cQryInterna += aQueryDim[nX, 2]  //sub-query quando campo do cubo nao for obrigatorio
		cQryInterna += " ) ) "
	EndIf

Next

cQryInterna += CRLF
//---------------------------------------------------------------------------
cQryInterna += " AND "+cAlias+".D_E_L_E_T_ = ' ' "
cQryInterna += CRLF
//---------------------------------------------------------------------------
//group by pelo nivel informado
cQryInterna += " GROUP BY "+cGroupBy+cAlias+"_NIV"+StrZero(nNivCubo, 2)
cQryInterna += Self:CtbAddGrpQry(lAllNiveis, nNivCubo, nMaxNivel,cAlias, cAlias)
cQryInterna += CRLF

Return( { cQuery, cQryInterna,cGroupBy } )

//-----------------------------------------------------------------------------------------------------------//

METHOD CtbAddCpoQry(cAlias, lAllNiveis, nNivCubo, nMaxNivel) CLASS Ctb_Exec_Cube
Local nX
Local cQueryAux	 := ""

cQueryAux	 += +cAlias+"_FILIAL CVX_FILIAL, "+cAlias+"_CONFIG CVX_CONFIG, "+cAlias+"_MOEDA CVX_MOEDA, "+cAlias+"_TPSALD CVX_TPSALD, "
cQueryAux	 += " "+cAlias+"_NIV" + StrZero(nNivCubo,2) + " CVX_NIV" + StrZero(nNivCubo,2)

If lAllNiveis
	For nX := 1 TO nMaxNivel
		If nX <> nNivCubo
			cQueryAux += ", "+cAlias+"_NIV"+StrZero(nX, 2)+  " CVX_NIV"+StrZero(nX, 2)
		EndIf
	Next
EndIf

Return(cQueryAux)

//-----------------------------------------------------------------------------------------------------------//

METHOD CtbAddGrpQry(lAllNiveis, nNivCubo, nMaxNivel,cAlias) CLASS Ctb_Exec_Cube
Local nX
Local cQueryAux	:= ""

If lAllNiveis
	For nX := 1 TO nMaxNivel
		If nX <> nNivCubo
			cQueryAux += ", "+cAlias+"_NIV"+StrZero(nX, 2)
		EndIf
	Next
EndIf

Return(cQueryAux)

//-----------------------------------------------------------------------------------------------------------//
METHOD CtbPopulaTemp(cArquivo) CLASS Ctb_Exec_Cube
Local nX, nZ
Local cQuery
Local nRecno
Local nPosCpo
Local nPosSld
Local nPosAux
Local lInclReg
Local nRetZerado
Local nPosDeb
Local nPosCrd
Local cArqAS400

For nX := 1 TO Len(Self:aQuery[Self:Level_Cube])

	If Left(Self:aQuery[Self:Level_Cube][nX][1], 13) == "###ISERIES###"

		//cria arquivo e coloca na query
		cArqAS400 := Self:CtbCriaTemp()

		cQuery := StrTran(Self:aQuery[Self:Level_Cube][nX][1], "###ISERIES###", "")
		cAliasAnt := cArquivo
		cAliasTemp := cArqAS400

		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAUX", .T., .T. )

		dbSelectArea("TMPAUX")
//		dbGoTop()
		While ! Eof()

	        lInclReg := .T.

	        If ! Self:lZerado

	        	nRetZerado := 0

				For nZ := 1 TO Self:Quantity_Values
					nPosAux := TMPAUX->(FieldPos("CVX_SLCR"+StrZero(nZ,2)))
					If nPosAux > 0
						nRetZerado += If( TMPAUX->(FieldGet(nPosAux)) == 0, 0, 1)
					EndIf

					nPosAux := TMPAUX->(FieldPos("CVX_SLDB"+StrZero(nZ,2)))
					If nPosAux > 0
						nRetZerado += If( TMPAUX->(FieldGet(nPosAux)) == 0, 0, 1)
					EndIf
					nPosAux := TMPAUX->(FieldPos("CVX_SALD"+StrZero(nZ,2)))
					If nPosAux > 0
						nRetZerado += If( TMPAUX->(FieldGet(nPosAux)) == 0, 0, 1)
					EndIf
				Next

	            If nRetZerado == 0
					lInclReg := .F.
				EndIf

	        EndIf

			If lInclReg
				dbSelectArea(cAliasTemp)
				RecLock(cAliasTemp, .T.)
				nRecno := (cAliasTemp)->(Recno())

				For nZ := 1 TO Len( Self:oStructCube:aStructCVX )

					nPosCpo := FieldPos( Self:oStructCube:aStructCVX[nZ,1] )
					nPosAux :=  TMPAUX->(FieldPos( Self:oStructCube:aStructCVX[nZ,1] ))

					If nPosCpo > 0 .And. nPosAux > 0
							(cAliasTemp)->( FieldPut( nPosCpo, TMPAUX->(FieldGet(nPosAux))) )
					EndIf

				Next

				(cAliasTemp)->CVX_ID := StrZero(nRecno,10)
				(cAliasTemp)->CVX_PROC := "0"

				For nZ := 1 TO Self:Quantity_Values

					nPosDeb := FieldPos("CVX_SLDB"+StrZero(nX,2))
					nPosAux := TMPAUX->(FieldPos("CVX_SLDB"+StrZero(nX,2)))

					If nPosDeb > 0 .And. nPosAux > 0
						(cAliasTemp)->( FieldPut( nPosDeb, TMPAUX->(FieldGet(nPosAux)) ) )
					EndIf

					nPosCrd := FieldPos("CVX_SLCR"+StrZero(nX,2))
					nPosAux := TMPAUX->(FieldPos("CVX_SLCR"+StrZero(nX,2)))

					If nPosCrd > 0 .And. nPosAux > 0
						(cAliasTemp)->( FieldPut( nPosCrd, TMPAUX->(FieldGet(nPosAux)) ) )
					EndIf

					nPosSld := FieldPos("CVX_SALD"+StrZero(nZ,2))
					nPosAux := TMPAUX->(FieldPos("CVX_SALD"+StrZero(nZ,2)))
					If nPosSld > 0 .And. nPosAux > 0
						(cAliasTemp)->( FieldPut( nPosSld, TMPAUX->(FieldGet(nPosAux))) )
					EndIf

				Next
				MsUnLock()
			EndIf

			dbSelectArea("TMPAUX")
			dbSkip()

		EndDo

		dbSelectArea("TMPAUX")
		dbCloseArea()

		//se tiver a tag "###ARQUIVO###" coloca na query o nome da tabela criada
		cQuery := Self:aQuery[Self:Level_Cube][nX][2]
		cQuery := StrTran(cQuery, "###ARQUIVO###", cAliasTemp)

		//volta para tabela temporaria original que deve ser populada
		cAliasTemp := cAliasAnt
	Else

		cAliasTemp := cArquivo
		cQuery := Self:aQuery[Self:Level_Cube][nX][1]

    EndIf

//	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAUX", .T., .T. )

	dbSelectArea("TMPAUX")
//	dbGoTop()
	While ! Eof()

        lInclReg := .T.

        If ! Self:lZerado

        	nRetZerado := 0

			For nZ := 1 TO Self:Quantity_Values
				nPosAux := TMPAUX->(FieldPos("CVX_SLCR"+StrZero(nZ,2)))
				If nPosAux > 0
					nRetZerado += If( TMPAUX->(FieldGet(nPosAux)) == 0, 0, 1)
				EndIf

				nPosAux := TMPAUX->(FieldPos("CVX_SLDB"+StrZero(nZ,2)))
				If nPosAux > 0
					nRetZerado += If( TMPAUX->(FieldGet(nPosAux)) == 0, 0, 1)
				EndIf
				nPosAux := TMPAUX->(FieldPos("CVX_SALD"+StrZero(nZ,2)))
				If nPosAux > 0
					nRetZerado += If( TMPAUX->(FieldGet(nPosAux)) == 0, 0, 1)
				EndIf
			Next

            If nRetZerado == 0
				lInclReg := .F.
			EndIf

        EndIf

		If lInclReg
			dbSelectArea(cAliasTemp)
			RecLock(cAliasTemp, .T.)
			nRecno := (cAliasTemp)->(Recno())

			For nZ := 1 TO Len( Self:oStructCube:aStructCVX )

				nPosCpo := FieldPos( Self:oStructCube:aStructCVX[nZ,1] )
				nPosAux :=  TMPAUX->(FieldPos( Self:oStructCube:aStructCVX[nZ,1] ))

				If nPosCpo > 0 .And. nPosAux > 0
						(cAliasTemp)->( FieldPut( nPosCpo, TMPAUX->(FieldGet(nPosAux))) )
				EndIf

			Next

			(cAliasTemp)->CVX_ID := StrZero(nRecno,10)
			(cAliasTemp)->CVX_PROC := "0"

			For nZ := 1 TO Self:Quantity_Values

				nPosDeb := FieldPos("CVX_SLDB"+StrZero(nX,2))
				nPosAux := TMPAUX->(FieldPos("CVX_SLDB"+StrZero(nX,2)))

				If nPosDeb > 0 .And. nPosAux > 0
					(cAliasTemp)->( FieldPut( nPosDeb, TMPAUX->(FieldGet(nPosAux)) ) )
				EndIf

				nPosCrd := FieldPos("CVX_SLCR"+StrZero(nX,2))
				nPosAux := TMPAUX->(FieldPos("CVX_SLCR"+StrZero(nX,2)))

				If nPosCrd > 0 .And. nPosAux > 0
					(cAliasTemp)->( FieldPut( nPosCrd, TMPAUX->(FieldGet(nPosAux)) ) )
				EndIf

				nPosSld := FieldPos("CVX_SALD"+StrZero(nZ,2))
				nPosAux := TMPAUX->(FieldPos("CVX_SALD"+StrZero(nZ,2)))
				If nPosSld > 0 .And. nPosAux > 0
					(cAliasTemp)->( FieldPut( nPosSld, TMPAUX->(FieldGet(nPosAux))) )
				EndIf

			Next
			MsUnLock()
		EndIf

		dbSelectArea("TMPAUX")
		dbSkip()

	EndDo

	dbSelectArea("TMPAUX")
	dbCloseArea()

	If Left(Self:aQuery[Self:Level_Cube][nX][1], 13) == "###ISERIES###"
		MsErase(cArqAS400,,"TOPCONN")
	EndIf

Next

Return

//-----------------------------------------------------------------------------------------------------------//
METHOD CtbQryFinal( cAliasSld,cArqTmp) CLASS Ctb_Exec_Cube
Local nZ
Local cQuery
Local nRecno
Local nPosCpo
Local nPosSld
Local nPosDeb
Local nPosCrd
Local nPosAux

cQuery := "SELECT CVX_NIV"+StrZero(Self:Level_Cube,2)+" "

//adiciona demais campos na query
For nZ := 1 TO Self:Quantity_Values
	cQuery += ",  SUM(CVX_SLDB"+StrZero(nX,2) +  ") CVX_SLDB"+StrZero(nX,2)
	cQuery += ",  SUM(CVX_SLCR"+StrZero(nX,2) +  ") CVX_SLCR"+StrZero(nX,2)
	cQuery += ",  SUM(CVX_SALD"+StrZero(nZ,2) +  ") CVX_SALD"+StrZero(nZ,2)
Next

cQuery += CRLF

cQuery += " FROM ( "

cQuery += "SELECT * FROM "+cArqTmp         //sub-query

If "POSTGRES" $ Self:cDBType
	cQuery += " ) AS TMPSALDO "
Else
	cQuery += " ) TMPSALDO "
EndIf

cQuery += CRLF

cQuery += " GROUP BY CVX_NIV"+StrZero(Self:Level_Cube,2)
cQuery += CRLF
cQuery += " ORDER BY CVX_NIV"+StrZero(Self:Level_Cube, 2)
cQuery += CRLF

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAUX", .T., .T. )

dbSelectArea("TMPAUX")
//dbGoTop()

While ! Eof()

	dbSelectArea(cAliasSld)
	RecLock(cAliasSld, .T.)
	nRecno := Recno()

	For nZ := 1 TO Self:oStructCube:nMaxNiveis
		nPosCpo := FieldPos("CVX_NIV"+StrZero(nZ,2))
		nPosAux := TMPAUX->(FieldPos("CVX_NIV"+StrZero(nZ,2)))
		If nPosCpo > 0 .And. nPosAux > 0
			(cAliasSld)->( FieldPut( nPosCpo, TMPAUX->(FieldGet(nPosAux))) )
		EndIf
	Next

	(cAliasSld)->CVX_ID := StrZero(nRecno,10)
	(cAliasSld)->CVX_PROC := "0"

	For nZ := 1 TO Self:Quantity_Values

		nPosDeb := (cAliasSld)->( FieldPos("CVX_SLDB"+StrZero(nX,2)) )
		nPosAux := TMPAUX->(FieldPos("CVX_SLDB"+StrZero(nX,2)))

		If nPosDeb > 0 .And. nPosAux > 0
			(cAliasSld)->( FieldPut( nPosDeb, TMPAUX->(FieldGet(nPosAux)) ) )
		EndIf

		nPosCrd := (cAliasSld)->( FieldPos("CVX_SLCR"+StrZero(nX,2)) )
		nPosAux := TMPAUX->(FieldPos("CVX_SLCR"+StrZero(nX,2)))

		If nPosCrd > 0 .And. nPosAux > 0
			(cAliasSld)->( FieldPut( nPosCrd, TMPAUX->(FieldGet(nPosAux)) ) )
		EndIf

		nPosSld := (cAliasSld)->( FieldPos("CVX_SALD"+StrZero(nZ,2)) )
		nPosAux := TMPAUX->(FieldPos("CVX_SALD"+StrZero(nZ,2)))

		If nPosSld > 0 .And. nPosAux > 0
			(cAliasSld)->( FieldPut( nPosSld, TMPAUX->(FieldGet(nPosAux)) ) )
		EndIf

	Next
	MsUnLock()

	dbSelectArea("TMPAUX")
	dbSkip()

EndDo

dbSelectArea("TMPAUX")
dbCloseArea()

Return

/* ----------------------------------------------------------------------------

_CTBSLDCUBE()

Função dummy para permitir a geração de patch deste arquivo fonte.

---------------------------------------------------------------------------- */
Function _CTBSLDCUBE()
Return Nil


/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                       classe configuracao de cubos                    ³
//³ Classe para configuracao de cubos utilizados para extracao dos saldos ³
//³                                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

//------------------------------------------------------------------------------------------------------//
// Classe que retorna a configuração (parametrizacao) de acordo a estrutura do cubo                                                               //
//------------------------------------------------------------------------------------------------------//

CLASS Ctb_Cfg_Struct_Cube
// Declaracao das propriedades da Classe
DATA aAlias
DATA aF3
DATA aOrdem
DATA aIni
DATA aFim
DATA aCodRel
DATA aChave
DATA aChaveR
DATA aCondSint
DATA aConCat
DATA aDescri
DATA aDescRel
DATA aFiltros
DATA aTotais
DATA aVazio
DATA aFaixa
DATA aValid
DATA aDescCfg
DATA aTam
DATA aTamNiv
DATA aStructCVX
DATA aNivel
DATA aNivFil
DATA nTam
DATA nMaxNiveis
DATA cCodeCube
DATA cCfgSelec
DATA aPlano

// Declaração dos Métodos da Classe
METHOD New(aEntVazio) CONSTRUCTOR
METHOD Ctb_Run_Struct_Cube(cCodCube, aEntVazio)

METHOD Ctb_Get_Configuration()

METHOD Ctb_Set_IniParam(nNivel, cConteudo)
METHOD Ctb_Get_IniParam(nNivel)

METHOD Ctb_Set_FimParam(nNivel, cConteudo)
METHOD Ctb_Get_FimParam(nNivel)

ENDCLASS

//------------------------------------------------------------------------------------------------------//
// Criação do construtor, onde atribuimos os valores default
// para as propriedades e retornamos Self
METHOD New(aEntVazio) CLASS Ctb_Cfg_Struct_Cube

DEFAULT aEntVazio := {}

Self:aAlias		:= {}
Self:aF3		:= {}
Self:aOrdem		:= {}
Self:aIni		:= {}
Self:aFim		:= {}
Self:aCodRel	:= {}
Self:aChave		:= {}
Self:aChaveR	:= {}
Self:aCondSint	:= {}
Self:aConCat	:= {}
Self:aDescri	:= {}
Self:aDescRel	:= {}
Self:aFiltros	:= {}
Self:aTotais 	:= {}
If Empty(aEntVazio)
	Self:aVazio 	:= {}
Else
	Self:aVazio 	:= aEntVazio
EndIf
Self:aFaixa   	:= {}
Self:aValid   	:= {}
Self:aDescCfg 	:= {}
Self:aTam		:= {}
Self:aTamNiv	:= {}
Self:aStructCVX	:= {}
Self:aNivel 	:= {}
Self:aNivFil 	:= {}
Self:nTam		:= 0
Self:nMaxNiveis	:= 0
Self:cCodeCube  := ""
Self:cCfgSelec  := ""
Self:aPlano 	:= {}

Return Self

//------------------------------------------------------------------------------------------------------//
METHOD Ctb_Get_Configuration() CLASS Ctb_Cfg_Struct_Cube
Return Self

//------------------------------------------------------------------------------------------------------//
METHOD Ctb_Set_IniParam(nNivel, cConteudo) CLASS Ctb_Cfg_Struct_Cube
Self:aIni[nNivel] := cConteudo
Return

//------------------------------------------------------------------------------------------------------//
METHOD Ctb_Get_IniParam(nNivel) CLASS Ctb_Cfg_Struct_Cube
Return( Self:aIni[nNivel] )

//------------------------------------------------------------------------------------------------------//
METHOD Ctb_Set_FimParam(nNivel, cConteudo) CLASS Ctb_Cfg_Struct_Cube
Self:aFim[nNivel] := cConteudo
Return

//------------------------------------------------------------------------------------------------------//
METHOD Ctb_Get_FimParam(nNivel) CLASS Ctb_Cfg_Struct_Cube
Return( Self:aFim[nNivel] )

//------------------------------------------------------------------------------------------------------//

METHOD Ctb_Run_Struct_Cube(cCodeCube, aEntVazio) CLASS Ctb_Cfg_Struct_Cube
Local nNivel := 0
Local aArea := GetArea()
Local nTamCpo
Local cCpoDeb
Local cCpoCrd
Local oLstCubo
Local oLstStruct
Local nX
Local aCposCVX := { 	"CVX_FILIAL",;
						"CVX_CONFIG",;
						"CVX_MOEDA", ;
						"CVX_TPSALD" }

DEFAULT aEntVazio := {}

For nX := 1 TO Len(aCposCVX)
	nTamCpo := 	nTamCpo := TamSX3( aCposCVX[nX] )[1]
	aAdd(Self:aStructCVX, { aCposCVX[nX], "C", nTamCpo, 00 } )
Next

oLstCubo := Ctb_SetCube(cCodeCube)

oLstStruct  := CtbCubeStruct(cCodeCube)

If oLstCubo:CountRecords() == 1
	oLstCubo:SetPosition(1)
	oLstCubo:SetRecord()

	nNivMax := Val(CT0->CT0_ID)

Else

	Aviso(STR0001, STR0003,{"Ok"})  //"Atencao"##"Deve ser selecionado um cubo valido."
	Return

EndIf

For nNivel := 1 TO nNivMax

	oLstStruct:SetPosition(nNivel)
	oLstStruct:SetRecord()

	cCpoDeb := CtbCposCrDb(CT0->CT0_ALIAS, "D", CT0->CT0_ID)
	cCpoCrd := CtbCposCrDb(CT0->CT0_ALIAS, "C", CT0->CT0_ID)
	nTamCpo := TamSX3( cCpoDeb )[1]

	aAdd(Self:aAlias, CT0->CT0_ALIAS/*_ALIAS_*/)
	aAdd(Self:aF3, CT0->CT0_F3ENTI/*_F3_*/)
	aAdd(Self:aOrdem,1) //a principio sempre sera a ordem 1
	aAdd(Self:aIni,SPACE( nTamCpo/*_TAMANHO_*/))
	aAdd(Self:aFim,Replicate("z", nTamCpo/*_TAMANHO_*/))
	aAdd(Self:aChave,AllTrim( CT0->CT0_CPOCHV /*_RELAC_*/)) //código da tabela principal por exemplo no plano de contas CT1_CONTA
	aAdd(Self:aChaveR,{ cCpoDeb /*debito*/, cCpoCrd/*credito*/}/*_CHAVER_*/)  //array de campos na posicao 1 = debitoo e a 2 = credito
	aAdd(Self:aCondSint,AllTrim(""/*_CNDSINT*/))  //expressao que determina se a entidade eh sintetica
	aAdd(Self:aDescri,AllTrim(CT0->CT0_DESC/*_DESCRI_*/))  //descricao do nivel atual
	aAdd(Self:aConcat,AllTrim(""/*_CONCDE*/))  //descricao concatenada por exemplo conta+centro custo+item+classe de valor
	aAdd(Self:aCodRel,""/*_CODREL_*/)   //código a ser impresso em relatorio e consultas a principio nao utilizaremos
	aAdd(Self:aDescRel,""/*AllTrim(_DESCRE_)*/)  //descricao a ser impresso em relatorios e consultas  ""     ""
	aAdd(Self:aFiltros,"")
	aAdd(Self:aTotais, .T. ) //sempre totaliza

	If Empty( aEntVazio )  //somente adiciona na propriedade aVazio quando nao instanciado na criacao do objeto
		aAdd(Self:aVazio, .F. )  //nunca eh vazio
	EndIf

	aAdd(Self:aFaixa, .T. )  //sempre por faixa de...ate
	aAdd(Self:aValid, "" )   //valida
	aAdd(Self:aDescCfg,"")    //descricao da configuracao do filtro
	aAdd(Self:aNivel,nNivel)
	aAdd(Self:aNivFil, xFilial(CT0->CT0_ALIAS))
	aAdd(Self:aTamNiv, nTamCpo/*_TAMANHO*/)
	aAdd(Self:aStructCVX, { "CVX_NIV"+StrZero(Val(CT0->CT0_ID),2), "C", nTamCpo, 00 }/*_CPOTABSLD_*/)  //array utilizado no criatrab


	If Empty( aEntVazio )  //somente adiciona na propriedade aVazio quando nao instanciado na criacao do objeto
		If CT0->(FieldPos("CT0_OBRIGA") > 0).And. CT0->CT0_OBRIGA != "1"  //se campo e opcional
			Self:aVazio[Len(Self:aVazio)] := .T.
		EndIf
	EndIf
	aAdd(Self:aPlano, CT0->CT0_ENTIDA )

Next

Self:nMaxNiveis := nNivMax
Self:cCodeCube := CT0->CT0_ID
Self:cCfgSelec := ""

RestArea(aArea)

Return

/* ----------------------------------------------------------------------------

__CTB_CFGCUBE()

Função dummy para permitir a geração de patch deste arquivo fonte.

---------------------------------------------------------------------------- */
Function __CTB_CFGCUBE()
Return Nil
