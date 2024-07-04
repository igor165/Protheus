#INCLUDE "pcoxcub.ch"
#INCLUDE "PROTHEUS.CH"

Static cTipoDB
Static lQuery
Static lOracle
Static lPostgres
Static lDB2
Static lInformix
Static cSrvType
Static cFilAKT
Static cOpSoma
Static aCpoChv
Static cModoAcesso
Static _aTamSX3  := NIL

//------------------------------------------------------------------------------------------------------//
Function PcoInicStatic()

//carrega as variaveis static
cTipoDB	:= Alltrim(Upper(TCGetDB()))
lQuery 	:= ( TCSrvType() # "AS/400" )
cSrvType := Alltrim(Upper(TCSrvType()))
	
lOracle		:= "ORACLE"   $ cTipoDB
lPostgres 	:= "POSTGRES" $ cTipoDB
lDB2		:= "DB2"      $ cTipoDB
lInformix 	:= "INFORMIX"   $ cTipoDB
cFilAKT 	:= xFilial("AKT")
cOpSoma	  	:= If( lOracle .Or. lPostgres .Or. lDB2 .Or. lInformix, " || ", " + " )
cModoAcesso := GetNewPar("MV_PCOMCHV","1")
aCpoChv 	:= {}

Return

//------------------------------------------------------------------------------------------------------//

Function PcoVer_Acesso( cCodCube, cConfig )
Local lAcesso := .F.
Local nDirAcesso

If SuperGetMV("MV_PCO_AL3",.F.,"2")!="1"  //1-Verifica acesso por entidade
	lAcesso := .T.                        // 2-Nao verifica o acesso por entidade
	nDirAcesso := 2
Else
	If Empty(cConfig)
		Aviso(STR0011,STR0012,{STR0013},2)//"Atenção"###"Obrigatorio informar a configuração do cubo. Cubo nao sera processado."###"Fechar"
	Else
	    nDirAcesso := PcoDirEnt_User("AL3",cCodCube+cConfig, __cUserID, .F.)

		If nDirAcesso == 0 //0=bloqueado
			Aviso(STR0011,STR0014+cCodCube+cConfig+STR0015,{STR0013},2)//"Atenção"###"Fechar"###"Usuario sem acesso a configuração de cubo  - "###". Cubo nao sera processado."
		ElseIf nDirAcesso == 1 //1-visualizacao    
		    lAcesso := .T.
		ElseIf nDirAcesso >= 2 //2-alteracao
		    lAcesso := .T.
		EndIf
	EndIf
EndIf

Return( { lAcesso, nDirAcesso} )

//------------------------------------------------------------------------------------------------------//

Function PcoParametro(oStructCube, lZerado, lAcesso, nDirAcesso)
Local nX
Local aParametros	:= {}
Local aFilIni
Local aFilFim 
Local aFiltCfg

aFilIni 	:= oStructCube:aIni
aFilFim 	:= oStructCube:aFim
aFiltCfg 	:=  oStructCube:aFiltros

For nx := 1 To Len(oStructCube:aConcat)
	If nx == 1
		aAdd(aParametros,{4,STR0001	,oStructCube:aTotais[nx],oStructCube:aConcat[nx],120,,.F., "{||.F.}" }) //"Imprimir Totais : "
	Else
		aAdd(aParametros,{4,""		,oStructCube:aTotais[nx],oStructCube:aConcat[nx],120,,.F., "{||.F.}" })
	EndIf
Next

For nx := 1 to Len(aFilIni)
	If aFilIni[nx]<>Nil
		oStructCube:aIni[nx] := PadR(aFilIni[nx],Len(oStructCube:aIni[nX]))
	EndIf
Next

For nx := 1 to Len(aFilFim)
	If aFilFim[nx]<>Nil
		oStructCube:aFim[nx] := PadR(aFilFim[nx],Len(oStructCube:aFim[nX]))
	EndIf
Next

For nX := 1 to Len(aFiltCfg)
	If aFiltCfg[nx]<>Nil
		oStructCube:aFiltros[nx] := aFiltCfg[nx]
	EndIf
Next

For nx := 1 to Len(oStructCube:aAlias)
	If lAcesso
		If oStructCube:aFaixa[nX]
			aAdd(aParametros,{1,AllTrim(oStructCube:aDescri[nx])+STR0002,oStructCube:aIni[nx], "" ,"",oStructCube:aF3[nx],Iif(nDirAcesso==1,".F.",""), Len(oStructCube:aIni[nx])*7 ,.F.}) //" de "
			aAdd(aParametros,{1,AllTrim(oStructCube:aDescri[nx])+STR0003,oStructCube:aFim[nx], "" ,"",oStructCube:aF3[nx],Iif(nDirAcesso==1,".F.",""), Len(oStructCube:aFim[nx])*7 ,.F.}) //" Ate "
		Else
			cValid := If(Empty(oStructCube:aValid[nX]), "", oStructCube:aValid[nX])
			cValid := "(mv_par"+StrZero(Len(oStructCube:aAlias)+((nX*3)-3)+2,2)+":=mv_par"+StrZero(Len(oStructCube:aAlias)+((nX*3)-3)+1,2)+", "+If(Empty(cValid),".T.",cValid)+")"
			aAdd(aParametros,{1,AllTrim(oStructCube:aDescri[nx])+STR0002,oStructCube:aIni[nx], "" ,cValid,oStructCube:aF3[nx],"", Len(oStructCube:aIni[nx])*7 ,.F.}) //" de "
			aAdd(aParametros,{1,AllTrim(oStructCube:aDescri[nx])+STR0003,oStructCube:aFim[nx], "" ,"",oStructCube:aF3[nx],".F.", Len(oStructCube:aFim[nx])*7 ,.F.}) //" Ate "
		EndIf
		aAdd(aParametros,{7,STR0004+AllTrim(oStructCube:aDescri[nx]),oStructCube:aAlias[nx],oStructCube:aFiltros[nx],Iif(nDirAcesso==1,".F.","")}) //"Filtro "
	Else
		aAdd(aParametros,{1,AllTrim(oStructCube:aDescri[nx])+STR0002,oStructCube:aIni[nx], "" ,"",oStructCube:aF3[nx],".F.", Len(oStructCube:aIni[nx])*7 ,.F.}) //" de "
		aAdd(aParametros,{1,AllTrim(oStructCube:aDescri[nx])+STR0003,oStructCube:aFim[nx], "" ,"",oStructCube:aF3[nx],".F.", Len(oStructCube:aFim[nx])*7 ,.F.}) //" Ate "
		aAdd(aParametros,{7,STR0004+AllTrim(oStructCube:aDescri[nx]),oStructCube:aAlias[nx],oStructCube:aFiltros[nx], ".F."}) //"Filtro "
	EndIf
Next

aAdd(aParametros,{5,STR0005,lZerado,125,,.F.}  ) //"Processar resultados de valores zerados "

aAdd(aParametros,{5,STR0006,.F.,145,,.F.}  ) //"Mostrar resultados sintéticos a partir do segundo nivel "

Return(aParametros)

//------------------------------------------------------------------------------------------------------//

Function Pco_aConfig(aConfig, aParametros, oStructCube, lViewCfg, lContinua)
Local nX, nu
Private cPlano		:= "01" // Usado pela consulta padrao CV0x
Private cCodigo		:= ""   // Usado pela consulta padrao CV0x

SaveInter()

If lViewCfg

	If ParamBox(  aParametros ,STR0007,aConfig,,,.F.,,,,,.F.)
	
	Else	
		lContinua := .F.
	EndIf	

Else

	//se nao permitir digitacao dos parametros considerar os padroes
	aConfig := ARRAY(Len(aParametros))
	For nX:=1 TO Len(aParametros)
		aConfig[nX] := aParametros[nX,If(aParametros[nX,1]==7, 4, 3)]
	Next		

EndIf

If lContinua
	nu := 1
	For nx := Len(oStructCube:aConcat)+1 to Len(oStructCube:aConcat)+(Len(oStructCube:aAlias)*3) Step 3
		oStructCube:aIni[nu] := aConfig[nx]
		nu++
	Next
	
	nu := 1
	For nx := Len(oStructCube:aConcat)+2 to Len(oStructCube:aConcat)+(Len(oStructCube:aAlias)*3) Step 3
		oStructCube:aFim[nu] := aConfig[nx]
		nu++
	Next
	
	nu := 1
	For nx := Len(oStructCube:aConcat)+3 to Len(oStructCube:aConcat)+(Len(oStructCube:aAlias)*3) Step 3
		oStructCube:aFiltros[nu] := aConfig[nx]
		nu++
	Next

EndIf

RestInter()

Return(aConfig)

//------------------------------------------------------------------------------------------------------//

Function PcoStructCube(cCodCube, cConfig)
Local oStructCube := Pco_Struct_Cube():New()

oStructCube:Pco_Run_Struct_Cube(cCodCube, cConfig)

Return(oStructCube)

//------------------------------------------------------------------------------------------------------//
Function PcoCriaQueryDim(oStructCube, nNivel, lSintetica, lForceNoSint, lProc)

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
Local cEntAdic 		:= ""

DEFAULT lForceNoSint := .F.
DEFAULT lProc		 := .F.

If cFilAKT == NIL .Or. cFilAKT != xFilial("AKT")
	PcoInicStatic()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Traduz o filtro para ser executado na query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(oStructCube:aFiltros[nNivel])  
	cFiltro	:= PcoParseFil( oStructCube:aFiltros[nNivel], oStructCube:aAlias[nNivel] )
	lFiltro := ! Empty(cFiltro) 
Else
	lFiltro := .T.	
Endif                                                                         

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria um filtro para nao trazer as sinteticas se nao deve processalas a aprtir do segundo nivel³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Empty(oStructCube:aCondSint[nNivel])
	If ( ! lSintetica .And. nNivel > 1 ) .Or. lForceNoSint   //no primeiro nivel sempre apresenta as contas sinteticas
		cFilSintOk 	:= PcoParseFil( "!(" + Alltrim(oStructCube:aCondSint[nNivel]) + ")", oStructCube:aAlias[nNivel])
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
If ! Empty(oStructCube:aFim[nNivel]) .And. ;     //se especificado filtro final ( ate )
	! ( Empty(oStructCube:aIni[nNivel]) .And. ;   // se nao for filtro de-ate = branco a ZZZZZZZZZZZZZZ
		Upper(Alltrim(oStructCube:aFim[nNivel]))==Replicate('Z',Len(Alltrim(oStructCube:aFim[nNivel]))) )

	cChvAux := Alltrim( Upper( oStructCube:aChave[nNivel] ) )

	If At("DTOS(", cChvAux ) > 0
		cChvAux := StrTran( cChvAux , ")", "")
		cChvAux := StrTran( cChvAux , "DTOS(", "")
	EndIf
		
	aCampos	:=	Str2Arr( cChvAux , "+")  //quebra em array por delimitador "+"

	cIni := oStructCube:aIni[nNivel]
	cFim := oStructCube:aFim[nNivel]
			
	If Len(aCampos) == 1 .And. cIni == cFim

		If At("->",aCampos[1]) == 0
			cCampoTmp	:=	Alltrim( aCampos[1] )		
		Else
			cCampoTmp	:=	Alltrim( Substr(aCampos[1], At("->", aCampos[1])+2 ) )
		Endif

		//usa a variavel cBetWeen mas o conteudo sera campo = conteudo
		cBetWeen 	:=	cCampoTmp + " = '" + cIni + "' AND "

	Else
	
		cBetWeen 	:= ""
		
		For nZ := 1 To Len(aCampos)                             
	
			If Len(cFim) > 0
				If At("->",aCampos[nZ]) == 0
					cCampoTmp	:=	Alltrim( aCampos[nZ] )
				Else
					cCampoTmp	:=	Alltrim( Substr(aCampos[nZ], At("->", aCampos[nZ])+2 ) )
				Endif
				
				nTamSX3 	:= PCO_TamX3(cCampoTmp) //TamSX3(cCampoTmp)[1]
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

cQuery 	+= " SELECT  "
cChvAux := Alltrim( StrTran( Upper( oStructCube:aChave[nNivel] ) , oStructCube:aAlias[nNivel]+"->", "") )
cChvAux := Alltrim( StrTran( cChvAux , "+", cOpSoma ) )
cChvAux += " N_I_V_"+StrZero(nNivel,2)+" "
cQuery 	+= cChvAux
cQuery 	+= " FROM " 
cQuery 	+= RetSqlName(oStructCube:aAlias[nNivel]) + " " +oStructCube:aAlias[nNivel] 
cQuery 	+= " WHERE "

//monta a clausula where a ser utilizado na query
If  SubStr( oStructCube:aAlias[nNivel], 1, 1) == "S" 
	//se a primeira letra do alias for "S" entao	
	//considera campo filial a partir da segunda exemplo tabela SA1 - campo A1_FILIAL
	cQuery 	+= SubStr( oStructCube:aAlias[nNivel], 2, 2 ) + "_FILIAL" + " = '" 
	cQuery 	+= xFilial( oStructCube:aAlias[nNivel] ) 
	cQuery 	+= "' AND "
Else			
	cQuery 	+= oStructCube:aAlias[nNivel] + "_FILIAL" + " = '" 
	cQuery 	+= xFilial( oStructCube:aAlias[nNivel] ) 
	cQuery 	+= "' AND "			
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

//ALTERACAO PARA TRATAR ENTIDADES GERENCIAIS ADICIONAIS (CV0/CT0) - Renato Neves
IF oStructCube:aAlias[nNivel] == "CV0"
	cEntAdic := GetAdvFVal("AKW","AKW_CHAVER",XFilial("AKW")+oStructCube:cCodeCube+StrZero(nNivel,2),1,"")
	cEntAdic := Right(AllTrim(cEntAdic),2)
	cEntAdic := GetAdvFVal("CT0","CT0_ENTIDA",XFilial("CT0")+cEntAdic,1,"")
	cQuery += " CV0_PLANO = '"+cEntAdic+"' AND " //Filtra o plano da entidade gerencial adicional
	cQuery += " CV0_CODIGO <> '"+Space(Len(CV0->CV0_CODIGO))+ "' AND " //A tabela CV0 grava um registro com código em branco que deve ser desconsiderado na query
EndIf
//
cQuery += oStructCube:aAlias[nNivel]+".D_E_L_E_T_ =  ' ' "

If !lProc .And. lFiltro .And. lCondSint .And. oStructCube:aVazio[nNivel]
	//pq se lFiltro And lCondSint vai ser chamada a rotina PcoQueryDim() que ja coloca este bloco novamente
	If cSrvType == "ISERIES"  
		lVazio := .T.	
		//a clausula FROM soh foi colocada pq a change query acaba modificando a query quando nao tem FROM
		//entao foi feito uma select da tabela AL2 que normalmente e uma tabela com poucos registros
		//e recuperamos um unico registro com MIN(R_E_C_N_O_)
		cQryVazio 	+= " SELECT '" +Space(oStructCube:aTamNiv[nNivel]) +  "' N_I_V_"+StrZero(nNivel,2)+" FROM "+RetSqlName("AL2")
		cQryVazio 	+= " WHERE AL2_FILIAL = '"+xFilial("AL2")+"' "
		cQryVazio 	+= " AND D_E_L_E_T_ = ' '"
		cQryVazio 	+= " AND R_E_C_N_O_ = ( "
		cQryVazio 	+= " SELECT MIN(R_E_C_N_O_) FROM "+RetSqlName("AL2")
		cQryVazio 	+= " WHERE AL2_FILIAL = '"+xFilial("AL2")+"' "
		cQryVazio 	+= " AND D_E_L_E_T_ = ' ' ) "
	Else
		lVazio := .F.
		cQryVazio := " "	
		//a clausula FROM soh foi colocada pq a change query acaba modificando a query quando nao tem FROM
		//entao foi feito uma select da tabela AL2 que normalmente e uma tabela com poucos registros
		//e recuperamos um unico registro com MIN(R_E_C_N_O_)
		cQuery 	+= " UNION SELECT '" +Space(oStructCube:aTamNiv[nNivel]) +  "' N_I_V_"+StrZero(nNivel,2)+" FROM "+RetSqlName("AL2")
		cQuery 	+= " WHERE AL2_FILIAL = '"+xFilial("AL2")+"' "
		cQuery 	+= " AND D_E_L_E_T_ = ' '"
		cQuery 	+= " AND R_E_C_N_O_ = ( "
		cQuery 	+= " SELECT MIN(R_E_C_N_O_) FROM "+RetSqlName("AL2")
		cQuery 	+= " WHERE AL2_FILIAL = '"+xFilial("AL2")+"' "
		cQuery 	+= " AND D_E_L_E_T_ = ' ' ) "
	EndIf	

EndIf

If lProc
	lFiltro 	:= .F.
	lCondSint 	:= .F.
	lVazio 		:= oStructCube:aVazio[nNivel]
Endif

Return( { cQuery, lFiltro, lCondSint, lVazio, cQryVazio } )

//------------------------------------------------------------------------------------------------------//
Function PcoCriaTemp(oStructCube, cArquivo, nQtdVal, lProc)

Local aStructAKT := aClone(oStructCube:aStructAKT)
Local cIndTmpAKT := ""
Local nLenStruct := Len(oStructCube:aStructAKT)  //usado para limitar os campos de dimensoes
Local nX

Default lProc := .F.

If lProc
	For nX := 1 TO Len(aStructAKT)
		If Left(aStructAKT[nX,1], 7) == "AKT_NIV"
			aStructAKT[nX,3] := LEN(AKT->AKT_NIV01)
		EndIf
	Next
EndIf

//acaba definicao da estrutura do temporario
aAdd(aStructAKT,{"AKT_ID","C", 10, 00})
aAdd(aStructAKT,{"AKT_PROC","C", 1, 00})
aAdd(aStructAKT,{"AKT_NIVEL","N", 2, 00})
aAdd(aStructAKT,{"AKT_IDPAI","C", 10, 00})
aAdd(aStructAKT,{"AKT_TPSALD","C", 2, 00})

//agora adiciona campos de saldos
For nX := 1 TO nQtdVal
	aAdd(aStructAKT,{"AKT_CRD"+StrZero(nX,3),"N", 21, 06})
    aAdd(aStructAKT,{"AKT_DEB"+StrZero(nX,3),"N", 21, 06})
    aAdd(aStructAKT,{"AKT_SLD"+StrZero(nX,3),"N", 21, 06})
Next

//laco para montar indice a ser utilizada no indregua
For nX := 1 TO nLenStruct
	cIndTmpAKT += aStructAKT[nX, 1]
	If nX < nLenStruct
		cIndTmpAKT+="+"
	EndIf
Next

// Cria a tabela temporia direto no banco de dados	                					
cArquivo := CriaTrab( , .F.)
MsErase(cArquivo)

MsCreate(cArquivo,aStructAKT, "TOPCONN")
Sleep(400)

dbUseArea(.T., "TOPCONN",cArquivo,cArquivo/*cAlias*/,.F.,.F.)

// Cria o indice temporario
//IndRegua(cArquivo/*cAlias*/,cArquivo,cIndTmpAKT,,)                   
TcSqlExec("Create index "+Substr(cArquivo,1,7)+"A on " + cArquivo+"( " + StrTran(cIndTmpAKT, "+", ",") + " ) ")


Return

//------------------------------------------------------------------------------------------------------//
Function PcoQueryDim(oStructCube, nNivel, cArqTmp, cQryDim)			
Local cAliasDim, cAliasTmp
Local cCpoDim, nTamDim, cExpr, cExprAux
Local lVazio 	:= .F.
Local cQryVazio := ""

cAliasDim := oStructCube:aAlias[nNivel]
cExprAux :=oStructCube:aChave[nNivel] 
cCpoDim := cExprAux
nTamDim := &("Len("+cCpoDim+")")
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
Sleep(1000)

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
	If ! Empty(oStructCube:aFiltros[nNivel]) .And. ! ( &(oStructCube:aFiltros[nNivel]) )
		dbSelectArea(cAliasTmp)	 			
		(cAliasTmp)->( dbSkip() )
		Loop
	EndIf			

    //macro executa a condicao de sintetica
    If nNivel > 1  //porque no primeiro nivel sempre apresenta as contas sinteticas
		If ! Empty(oStructCube:aCondSint[nNivel]) .And. &(oStructCube:aCondSint[nNivel])
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

If oStructCube:aVazio[nNivel]
	If cSrvType == "ISERIES"
		lVazio := .T.
		//a clausula FROM soh foi colocada pq a change query acaba modificando a query quando nao tem FROM
		//entao foi feito uma select da tabela AL2 que normalmente e uma tabela com poucos registros
		//e recuperamos um unico registro com MIN(R_E_C_N_O_)
		cQryVazio 	+= " SELECT ' ' "+cCpoDim+" FROM "+RetSqlName("AL2")
		cQryVazio 	+= " WHERE AL2_FILIAL = '"+xFilial("AL2")+"' "
		cQryVazio 	+= " AND D_E_L_E_T_ = ' '"
		cQryVazio 	+= " AND R_E_C_N_O_ = ( "
		cQryVazio 	+= " SELECT MIN(R_E_C_N_O_) FROM "+RetSqlName("AL2")
		cQryVazio 	+= " WHERE AL2_FILIAL = '"+xFilial("AL2")+"' "
		cQryVazio 	+= " AND D_E_L_E_T_ = ' ' ) "
	Else
		lVazio := .F.
		cQryVazio := " "
		//acrescenta um registro com space do tamanho do nivel do cubo
		dbSelectArea(cArqTmp)
		RecLock(cArqTmp, .T.)
		//como so tem um campo posso usar fieldput direto com 1 fixo
		FieldPut(1, Space(nTamDim))
		MsUnLock()
	EndIf	

EndIf

Return({ cQueryDim, .F., .F., lVazio, cQryVazio })

//------------------------------------------------------------------------------------------------------//
Function PcoCriaQry(cCodCube, nNivel, nMoeda, cArquivo, nQtdVal, aDtSld, aQryDim, cWhere, cWhereTpSld, nNivTpSld, lMovimento, aDtIni, lAllNiveis, aCposNiv, lDebito, lCredito, lProc, aCposQry )

Local aQuery := {}
Local nY
Local nX
Local dData, dDtInic
Local cParcialQry
Local cMoeda := Str(nMoeda, 1)

DEFAULT lMovimento 	:= .F.
DEFAULT aDtIni 		:= {}
DEFAULT lAllNiveis 	:= .F.
DEFAULT aCposNiv 	:= {}
DEFAULT lDebito 	:= .F.
DEFAULT lCredito 	:= .F.
DEFAULT lProc 		:= .F.
DEFAULT aCposQry 	:= {}

If Len(aDtSld) <> nQtdVal

	MsgAlert("Erro - quantidade de datas deve ser igual a quantidade de valores. Verifique. ")

Else

	If lMovimento
	
		If Empty(aDtIni)  //quando nao for passado o parametro considera sempre inicio do mes (mensal)
			For nY := 1 TO Len(aDtSld)
				aAdd(aDtIni, STOD(Left(DTOS(aDtSld[nY]),6)+"01"))
			Next
		EndIf
	Else
	
		If Empty(aDtIni)  //quando nao for passado o parametro considera sempre inicio do mes (mensal)
			For nY := 1 TO Len(aDtSld)
				aAdd(aDtIni, STOD("19800101"))  //quando saldo acumulado considera data inicial 01/01/80
			Next
		EndIf
		
	EndIf

		//Saldo de Movimento por periodo
		For nY := 1 to nQtdVal
	
	    	dDtInic := aDtIni[nY]
	    	dData 	:= aDtSld[nY]
	    	If lProc
		    	cParcialQry := " "
		    	If nY == 1
			    	aAdd(aCposQry, "AKT_NIV" + StrZero(nNivel,2) )
					If lAllNiveis
						For nX := 1 TO Len(aCposNiv)
							cParcialQry += StrTran(aCposNiv[nX],"AKS","AKT") + " " +StrTran(aCposNiv[nX],"AKS","AKT") + ", "
							aAdd(aCposQry, "AKT_NIV" + StrZero(nNivel,2) )
						Next
					EndIf		
					For nX := 1 TO nQtdVal
						If lDebito
							aAdd(aCposQry, "AKT_DEB" + StrZero(nX, 3) )
						EndIf
						If lCredito
							aAdd(aCposQry, "AKT_CRD" + StrZero(nX, 3) )
						EndIf			
						aAdd(aCposQry, "AKT_SLD" + StrZero(nX, 3))
					Next
				EndIf
	    	Else
				cParcialQry := " SELECT AKT_NIV" + StrZero(nNivel,2) + " AKT_NIV" + StrZero(nNivel,2) + ", "
				If lAllNiveis
					For nX := 1 TO Len(aCposNiv)
						cParcialQry += StrTran(aCposNiv[nX],"AKS","AKT") + " " +StrTran(aCposNiv[nX],"AKS","AKT") + ", "
					Next
				EndIf		
	
			    //loop para montar agregados somatoria
				For nX := 1 TO nQtdVal
					If lDebito
						cParcialQry += " SUM( AKT_DEB" + StrZero(nX, 3) +" ) AKT_DEB" + StrZero(nX, 3) + ", " //soma AKS
					EndIf
					If lCredito
						cParcialQry += " SUM( AKT_CRD" + StrZero(nX, 3) +" ) AKT_CRD" + StrZero(nX, 3) + ", " //soma AKS
					EndIf			
					cParcialQry += " SUM( AKT_SLD" + StrZero(nX, 3) +" ) AKT_SLD" + StrZero(nX, 3) + " " //soma AKS
					If nX < nQtdVal
						cParcialQry += ", "
					EndIf	
				Next
			
				cParcialQry += " FROM  ( " 
				cParcialQry += CRLF
            EndIf
			cParcialQry += CRLF

			If nNivel == nNivTpSld
				cParcialQry += "SELECT AKT_TPSALD AKT_NIV" + StrZero(nNivel,2) + ", "
			Else
				cParcialQry += "SELECT AKT_NIV" + StrZero(nNivel,2) + " AKT_NIV" + StrZero(nNivel,2) + ", "
			EndIf
			If lAllNiveis
				For nX := 1 TO Len(aCposNiv)
					cParcialQry += StrTran(aCposNiv[nX],"AKS","AKT") + " " +StrTran(aCposNiv[nX],"AKS","AKT") + ", "
				Next
			EndIf		
		    //loop para montar agregados somatoria
			For nX := 1 TO nQtdVal
				If nX == nY
					If lDebito
						cParcialQry += " SUM(AKT_MVDEB"+cMoeda+") AKT_DEB" + StrZero(nX, 3) + ", " //soma AKT
					EndIf
					If lCredito
						cParcialQry += " SUM(AKT_MVCRD"+cMoeda+") AKT_CRD" + StrZero(nX, 3) + ", " //soma AKT
					EndIf
					cParcialQry += " SUM(AKT_MVCRD"+cMoeda+"-AKT_MVDEB"+cMoeda+") AKT_SLD" + StrZero(nX, 3) + " " //soma AKT
				Else
					If lDebito
						cParcialQry += "0 AKT_DEB" + StrZero(nX, 3) + ", " //soma AKT
					EndIf
					If lCredito
						cParcialQry += "0 AKT_CRD" + StrZero(nX, 3) + ", " //soma AKT
					EndIf
					cParcialQry += "0 AKT_SLD" + StrZero(nX, 3) + " "
				EndIf
				If nX < nQtdVal
					cParcialQry += ", "
				EndIf	
			Next
		
			cParcialQry += " FROM " + RetSqlName("AKT") + " AKT "
			cParcialQry += CRLF
			//---------------------------------------------------------------------------
			cParcialQry += " WHERE "
			cParcialQry += " AKT.AKT_FILIAL = '" + xFilial("AKT") + "'  AND "
			cParcialQry += CRLF
			cParcialQry += " AKT.AKT_CONFIG = '" + cCodCube + "'  AND "
			cParcialQry += CRLF
	
			//---------------------------------------------------------------------------
	        //acrescenta a query a condicao passada no parametro cWhere
	        If ! Empty(cWhere)
	        	cParcialQry += StrTran(cWhere, "AKS.AKS_", "AKT.AKT_")
				cParcialQry += CRLF
			EndIf	
	
			//---------------------------------------------------------------------------
	        //acrescenta a query a condicao passada no parametro cWhereTpSld
	        If ! Empty(cWhereTpSld)
				cParcialQry += StrTran(cWhereTpSld, "AKS.AKS_", "AKT.AKT_")
				cParcialQry += CRLF
			EndIf	
	
			//---------------------------------------------------------------------------
			/*
			//TROCAR CHAVE POR CAMPOS ESPEFICOS : AKS.AKS_NivXX IN (SELECT CCT_CUSTO FROM CTT....)
			//                                 ou AKS.AKS_NivXX between 'de' and 'ate'
			//                                    AKS.AKS_NivXX IN ('xxx','zzz','yyy') //novo campo
			*/
	
			For nX := 1 TO Len(aQryDim)
			
				If nX == nNivTpSld  .And. ! Empty(cWhereTpSld)
				   Loop  //se ja passou pelo where tipo de saldo nao precisa entrar aqui
				EndIf
				
				If nX == nNivTpSld
					cParcialQry += "AKT.AKT_TPSALD IN ( "
				Else
					If Empty(aQryDim[nX, 2])
						cParcialQry += "AKT.AKT_NIV"+StrZero(nX, 2)+ " IN ( "
					Else
						cParcialQry += " ( "
						cParcialQry += "AKT.AKT_NIV"+StrZero(nX, 2)+ " IN ( "
					EndIf	
	            EndIf

				cParcialQry += aQryDim[nX, 1]  //sub-query
				cParcialQry += " )	"
				
				If ! Empty(aQryDim[nX, 2])
					cParcialQry += " OR "
					cParcialQry += "AKT.AKT_NIV"+StrZero(nX, 2)+ " IN ( "
					cParcialQry += aQryDim[nX, 2]  //sub-query quando campo do cubo nao for obrigatorio
					cParcialQry += " ) ) "            //nao funcionava com UNION em DB2 - AS/400
				EndIf	

				cParcialQry += " AND "
				cParcialQry += CRLF
				
			Next	
			
			//---------------------------------------------------------------------------
			//saldos de movimentos diarios apos a data final do mes anterior <<->> ate a data informada
			If lMovimento
				cParcialQry += " AKT.AKT_DATA >= '"+DTOS(dDtInic)+"'  AND "
				cParcialQry += CRLF
			EndIf
			
			cParcialQry += " AKT.AKT_DATA <= '" + DTOS(dData)+ "' AND "	
			cParcialQry += CRLF
		
			//---------------------------------------------------------------------------
			cParcialQry += "	AKT.D_E_L_E_T_ = ' ' "
			cParcialQry += CRLF

			If lProc
				cParcialQry += " "
			Else
				//---------------------------------------------------------------------------
				//group by pelo nivel informado
				If nNivel == nNivTpSld
					cParcialQry += " GROUP BY AKT_TPSALD "
				Else
					cParcialQry += " GROUP BY AKT_NIV"+StrZero(nNivel, 2)
				EndIf
				If lAllNiveis
					For nX := 1 TO Len(aCposNiv)
						cParcialQry += ", "+StrTran(aCposNiv[nX],"AKS","AKT")
					Next
				EndIf		
				cParcialQry += CRLF
				//---------------------------------------------------------------------------
		        //termino das querys AKS e AKT
		
				//group by pelo nivel informado
				If lPostgres
					cParcialQry += " ) AS TMPSALDO "
				Else
					cParcialQry += " ) TMPSALDO "
				EndIf

			EndIf						
			
			If lProc .And. nNivel == nNivTpSld
				cParcialQry += " GROUP BY AKT_TPSALD "
			Else
				cParcialQry += " GROUP BY AKT_NIV"+StrZero(nNivel, 2)
			EndIf

			If lAllNiveis
				For nX := 1 TO Len(aCposNiv)
					cParcialQry += ", "+StrTran(aCposNiv[nX],"AKS","AKT")
				Next
			EndIf		
			cParcialQry += CRLF
			cParcialQry += " ORDER BY 1 "
			If lAllNiveis
				For nX := 1 TO Len(aCposNiv)
					cParcialQry += ", "+StrTran(aCposNiv[nX],"AKS","AKT")
				Next
			EndIf		
			cParcialQry += CRLF

			aAdd(aQuery, cParcialQry)
		    
		Next
	
EndIf

Return(aQuery)

//-----------------------------------------------------------------------------------------------------------//
Function PcoLimpTemp( cArqTemp )
Local aArea := GetArea()
Default cArqTemp := ''

If Select( cArqTemp ) <> 0
/*
	If TcSqlExec("DELETE FROM " + cArqTemp ) > 0
		//se nao conseguir excluir os itens deve abortar a consulta 
		MSGSTOP("ERROR")
		Return
	EndIf
	TcRefresh(cArqTemp)		
*/
	dbSelectArea(cArqTemp)
	zap
Endif	
RestArea(aArea)
Return
//-----------------------------------------------------------------------------------------------------------//
Function PcoPopulaTemp(oStructCube, cAliasTemp, aQuery, nQtdVal, lZerado, cArqAS400, lCredito, lDebito)
Local nX, nZ
Local cParcialQry 
Local nRecno
Local nPosCpo
Local nPosSld
Local nPosAux
Local lInclReg
Local nRetZerado
Local nPosDeb
Local nPosCrd

DEFAULT lDebito 	:= .F.
DEFAULT lCredito 	:= .F.

For nX := 1 TO Len(aQuery)

	If Left(aQuery[nX], 13) == "###ISERIES###"
		If TcSqlExec("DELETE FROM "+cArqAS400) > 0
			//se nao conseguir excluir os itens deve abortar a consulta
			Return
		EndIf	
		cParcialQry := StrTran(aQuery[nX], "###ISERIES###", "")
		cAliasAnt := cAliasTemp
		cAliasTemp := cArqAS400
	Else
		cParcialQry := aQuery[nX]
    EndIf
//	cParcialQry := ChangeQuery( cParcialQry )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cParcialQry), "TMPAUX", .T., .T. )

	dbSelectArea("TMPAUX")

	While ! Eof()
	
        lInclReg := .T.
        
        If ! lZerado
        	
        	nRetZerado := 0
			
			For nZ := 1 TO nQtdVal
				nPosAux := TMPAUX->(FieldPos("AKT_SLD"+StrZero(nZ,3)))
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

			For nZ := 1 TO oStructCube:nMaxNiveis
				nPosCpo := FieldPos("AKT_NIV"+StrZero(nZ,2))
				If nPosCpo > 0
					nPosAux :=  TMPAUX->(FieldPos("AKT_NIV"+StrZero(nZ,2)))
					If nPosAux > 0
						(cAliasTemp)->( FieldPut( nPosCpo, TMPAUX->(FieldGet(nPosAux))) )
					EndIf
					If nZ == oStructCube:nNivTpSld
						nPosAux :=  TMPAUX->(FieldPos("AKT_TPSALD"))  ////tratar no inicio
						If nPosAux > 0
							(cAliasTemp)->( FieldPut( nPosCpo, TMPAUX->(FieldGet(nPosAux))) )
						EndIf
					EndIf
				EndIf		
			Next

			(cAliasTemp)->AKT_ID := StrZero(nRecno,10)
			(cAliasTemp)->AKT_PROC := "0"

			For nZ := 1 TO nQtdVal

				If lDebito
					nPosDeb := FieldPos("AKT_DEB"+StrZero(nZ,3))
					If nPosDeb > 0
						nPosAux := TMPAUX->(FieldPos("AKT_DEB"+StrZero(nZ,3)))
						If nPosAux > 0
							(cAliasTemp)->( FieldPut( nPosDeb, TMPAUX->(FieldGet(nPosAux)) ) )
						EndIf
					EndIf
				EndIf
			
				If lCredito
					nPosCrd := FieldPos("AKT_CRD"+StrZero(nZ,3))
					If nPosCrd > 0
						nPosAux := TMPAUX->(FieldPos("AKT_CRD"+StrZero(nZ,3)))
						If nPosAux > 0
							(cAliasTemp)->( FieldPut( nPosCrd, TMPAUX->(FieldGet(nPosAux)) ) )
						EndIf
					EndIf
				EndIf

				nPosSld := FieldPos("AKT_SLD"+StrZero(nZ,3))
				If nPosSld > 0
					nPosAux := TMPAUX->(FieldPos("AKT_SLD"+StrZero(nZ,3)))
					If nPosAux > 0
						(cAliasTemp)->( FieldPut( nPosSld, TMPAUX->(FieldGet(nPosAux))) )
					EndIf
				EndIf		
			Next
			MsUnLock()
		EndIf

		dbSelectArea("TMPAUX")
		dbSkip() 

	EndDo

	dbSelectArea("TMPAUX")
	dbCloseArea()

	//volta para tabela temporaria original que deve ser populada
	If Left(aQuery[nX], 13) == "###ISERIES###"
		cAliasTemp := cAliasAnt
    EndIf
    
Next

Return

//-----------------------------------------------------------------------------------------------------------//
Function PcoQryFinal( oStructCube, nNivel, cAliasSld, nQtdVal, cArqTmp, lDebito, lCredito)
Local nZ
Local cQuery
Local nRecno
Local nPosCpo
Local nPosSld
Local nPosDeb
Local nPosCrd
Local nPosAux

DEFAULT lDebito := .F.
DEFAULT lCredito := .F.

cQuery := "SELECT AKT_NIV"+StrZero(nNivel,2)+" "
//adiciona demais campos na query
For nZ := 1 TO nQtdVal
	If lDebito
		cQuery += ",  SUM(AKT_DEB" + StrZero(nZ,3) +  ") AKT_DEB"+StrZero(nZ,3)
	EndIf
	If lCredito
		cQuery += ",  SUM(AKT_CRD" + StrZero(nZ,3) +  ") AKT_CRD"+StrZero(nZ,3)
	EndIf
	cQuery += ",  SUM(AKT_SLD" + StrZero(nZ,3) +  ") AKT_SLD"+StrZero(nZ,3)
Next                                        

cQuery += CRLF

cQuery += " FROM ( "

cQuery += "SELECT * FROM "+cArqTmp         //sub-query

If lPostgres
	cQuery += " ) AS TMPSALDO "
Else
	cQuery += " ) TMPSALDO "
EndIf	

cQuery += CRLF

cQuery += " GROUP BY AKT_NIV"+StrZero(nNivel,2)
cQuery += CRLF
cQuery += " ORDER BY AKT_NIV"+StrZero(nNivel, 2)
cQuery += CRLF

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAUX", .T., .T. )

dbSelectArea("TMPAUX")
dbGoTop()

While ! Eof()

	dbSelectArea(cAliasSld)
	RecLock(cAliasSld, .T.)
	nRecno := Recno()

	For nZ := 1 TO oStructCube:nMaxNiveis
		nPosCpo := FieldPos("AKT_NIV"+StrZero(nZ,2))
		If nPosCpo > 0
			nPosAux := TMPAUX->(FieldPos("AKT_NIV"+StrZero(nZ,2)))
			If nPosAux > 0
				(cAliasSld)->( FieldPut( nPosCpo, TMPAUX->(FieldGet(nPosAux))) )
			EndIf
		EndIf	
	Next

	(cAliasSld)->AKT_ID := StrZero(nRecno,10)
	(cAliasSld)->AKT_PROC := "0"
	
	For nZ := 1 TO nQtdVal
	
		If lDebito
			nPosDeb := (cAliasSld)->( FieldPos("AKT_DEB"+StrZero(nZ,3)) )
			If nPosDeb > 0
				nPosAux := TMPAUX->(FieldPos("AKT_DEB"+StrZero(nZ,3)))
				If nPosAux > 0
					(cAliasSld)->( FieldPut( nPosDeb, TMPAUX->(FieldGet(nPosAux)) ) )
				EndIf
			EndIf
		EndIf
	
		If lCredito
			nPosCrd := (cAliasSld)->( FieldPos("AKT_CRD"+StrZero(nZ,3)) )
			If nPosCrd > 0
				nPosAux := TMPAUX->(FieldPos("AKT_CRD"+StrZero(nZ,3)))
				If nPosAux > 0
					(cAliasSld)->( FieldPut( nPosCrd, TMPAUX->(FieldGet(nPosAux)) ) )
				EndIf
			EndIf
		EndIf
	
		nPosSld := (cAliasSld)->( FieldPos("AKT_SLD"+StrZero(nZ,3)) )
		If nPosSld > 0
			nPosAux := TMPAUX->(FieldPos("AKT_SLD"+StrZero(nZ,3)))
			If nPosAux > 0
				(cAliasSld)->( FieldPut( nPosSld, TMPAUX->(FieldGet(nPosAux)) ) )
			EndIf
		EndIf
	
	Next
	MsUnLock()

	dbSelectArea("TMPAUX")
	dbSkip() 

EndDo

dbSelectArea("TMPAUX")
dbCloseArea()

Return


//------------------------------------------------------------------------------------------------------//
// Classe que retorna a estrutura do cubo combinado com a configuracao selecionada                      //
//------------------------------------------------------------------------------------------------------//

CLASS Pco_Struct_Cube
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
DATA aStructAKT
DATA aNivFil
DATA nTam
DATA nMaxNiveis
DATA nNivClasse
DATA nNivTpSld
DATA cCodeCube
DATA cCfgSelec

// Declaração dos Métodos da Classe
METHOD New() CONSTRUCTOR
METHOD Pco_Run_Struct_Cube(cCodCube, cConfig) CONSTRUCTOR

ENDCLASS

//------------------------------------------------------------------------------------------------------//
// Criação do construtor, onde atribuimos os valores default 
// para as propriedades e retornamos Self
METHOD New() CLASS Pco_Struct_Cube
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
Self:aVazio 	:= {}
Self:aFaixa   	:= {}
Self:aValid   	:= {}
Self:aDescCfg 	:= {}
Self:aTam		:= {}
Self:aTamNiv	:= {}
Self:aStructAKT	:= {}
Self:aNivFil 	:= {}
Self:nTam		:= 0
Self:nMaxNiveis	:= 0
Self:nNivClasse	:= 0
Self:nNivTpSld	:= 0
Self:cCodeCube  := ""
Self:cCfgSelec  := ""
Return Self

//------------------------------------------------------------------------------------------------------//

METHOD Pco_Run_Struct_Cube(cCodCube, cConfig) CLASS Pco_Struct_Cube
Local nX := 0
Local aArea := GetArea()
Local aAreaAKW := AKW->(GetArea())
Local aAreaAL3 := AL3->(GetArea())
Local aAreaAL4 := AL4->(GetArea())

aAdd(Self:aStructAKT,{"AKT_CHAVE","C", Len(AKT->AKT_CHAVE), 00})

dbSelectArea("AKW")
dbSetOrder(1)

If dbSeek(xFilial("AKW")+cCodCube)

	While AKW->( ! Eof() .And. AKW_FILIAL+AKW_COD == xFilial("AKW")+cCodCube)

		aAdd(Self:aAlias,AKW->AKW_ALIAS)
		aAdd(Self:aF3,AKW->AKW_F3)
		aAdd(Self:aOrdem,1)
		aAdd(Self:aIni,SPACE(AKW->AKW_TAMANH))
		aAdd(Self:aFim,Replicate("z",AKW->AKW_TAMANH))
		aAdd(Self:aCodRel,AllTrim(AKW->AKW_CODREL))
		aAdd(Self:aChave,AllTrim(AKW->AKW_RELAC))
		aAdd(Self:aChaveR,AllTrim(AKW->AKW_CHAVER))
		aAdd(Self:aCondSint,AllTrim(AKW->AKW_CNDSIN))
		aAdd(Self:aConcat,AllTrim(AKW->AKW_CONCDE))
		aAdd(Self:aDescri,AllTrim(AKW->AKW_DESCRI))
		aAdd(Self:aDescRel,AllTrim(AKW->AKW_DESCRE))
		aAdd(Self:aFiltros,"")
		aAdd(Self:aTotais, .T. ) 
		aAdd(Self:aVazio, .F. )
		aAdd(Self:aFaixa, .T. )
		aAdd(Self:aValid, "" )          
		aAdd(Self:aDescCfg,"")
		Self:nTam += AKW->AKW_TAMANH
		aAdd(Self:aTam,Self:nTam)
		aAdd(Self:aTamNiv,AKW->AKW_TAMANH)

		aAdd(Self:aStructAKT,{"AKT_NIV"+StrZero(Len(Self:aTam),2),"C", AKW->AKW_TAMANH, 00})

		If AKW->(FieldPos("AKW_OBRIGA") > 0).And. AKW->AKW_OBRIGA != "1"  //se campo e opcional
			Self:aVazio[Len(Self:aVazio)] := .T.
		EndIf	
	
		If cConfig <> Nil .And. !Empty(cConfig)
			If AL3->( dbSeek(xFilial()+cConfig))
				Self:aDescCfg[Len(Self:aDescCfg)] := AllTrim(AL3->AL3_DESCRI)
			EndIf
			If AL4->(dbSeek(xFilial()+cConfig+cCodCube+AKW->AKW_NIVEL))
				Self:aTotais[Len(Self:aTotais)] 	:= If(AL4->AL4_DETALH == "1",.T.,.F.)
				Self:aIni[Len(Self:aIni)] 			:= Left(AL4->AL4_EXPRIN,AKW->AKW_TAMANH)
				Self:aFim[Len(Self:aFim)] 			:= Left(AL4->AL4_EXPRFI,AKW->AKW_TAMANH)
				Self:aFiltros[Len(Self:aFiltros)] 	:= Alltrim(AL4->AL4_FILTER)
				If AL4->(FieldPos("AL4_TPFAIX") > 0 .And. FieldPos("AL4_VALID") > 0)
					Self:aFaixa[Len(Self:aFaixa)] 	:= (AL4->AL4_TPFAIX == "2")
					If !Empty(AL4->AL4_VALID)
						Self:aValid[Len(Self:aValid)] := Alltrim(AL4->AL4_VALID)
					EndIf
				EndIf	
			EndIf
		EndIf
		//incrementa variavel nivel
		nX++
        //atribui propriedades baseado nesta variavel ( nivel )
		aAdd(Self:aNivFil, xFilial(Self:aAlias[nX]))
        If 		AKW->AKW_ALIAS == "AK6"
				Self:nNivClasse := nX 
        ElseIf 	AKW->AKW_ALIAS == "AL2"
				Self:nNivTpSld := nX 
        EndIf
        //avanca para proximo registro
		dbSelectArea("AKW")
		dbSkip()

	End

EndIf

Self:nMaxNiveis := nX 
Self:cCodeCube := cCodCube
Self:cCfgSelec := cConfig

RestArea(aAreaAKW)
RestArea(aAreaAL3)
RestArea(aAreaAL4)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  PCO_TamX3	  		³TOTVS SA            º Data ³  09/09/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna tamanho do campo - TamSX3(campo)[1]                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCO_TamX3(cCampoTmp)                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PCO_TamX3(cCampoTmp)
Local nTamCpo := 0
Local nPosElem := 0
Local aTamAux := {}
Local aArea := GetArea()

If _aTamSX3 == NIL
	_aTamSX3 := {}
EndIf

If ( nPosElem := aScan( _aTamSX3,{|x| x[1] == cCampoTmp } ) ) == 0
	aArea := GetArea()
	aTamAux := TamSX3(cCampoTmp)
	nTamCpo := aTamAux[1]
	aAdd( _aTamSX3, { cCampoTmp, aClone(aTamAux) } )
	RestArea(aArea)
Else
	aTamAux := _aTamSX3[nPosElem][2]
	nTamCpo := aTamAux[1]
EndIf

Return(nTamCpo)
