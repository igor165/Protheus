#INCLUDE "pcocube.ch"
#INCLUDE "PROTHEUS.CH"
Static cTipoDB
Static lQuery
Static lOracle
Static lPostgres
Static lDB2
Static lInformix
Static cFilAKT
Static _cConcSQL
Static aCpoChv
Static cModoAcesso
Static cCuboAnt
/*/
_F_U_N_C_ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³FUNCAO    ³ PCOCUBE  ³ AUTOR ³ Edson Maricate        ³ DATA ³ 07-01-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRICAO ³ Funcoes de processamento dos cubos.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ USO      ³ SIGAPCO                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³_DOCUMEN_ ³ PCOCUBE                                                      ³±±
±±³_DESCRI_  ³                                                              ³±±
±±³_FUNC_    ³                                                              ³±±
±±³          ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoRunCube(cCodCube,nQtdVal,cProcessa,cConfig,nViewCfg, lZerado, aNiveis,aFilIni,aFilFim,lReserv, aCfgCube,lProcessa,lVerAcesso,lForceNoSint,aItCfgBlq,aFiltCfg,cArqAKT,lLimpArqAKT,lVisao,lBloqueio)

Local nx,ny,nu
Local cDescAnt		:= ""
Local cBetWeen  	:= ""
Local cFim			:= ""
Local cIni			:= ""       
Local cFiltro		:= ""
Local aArea			:= GetArea()
Local aAlias		:= {}
Local aOrdem		:= {}
Local aConfig		:= {}
Local aIni			:= {}
Local aFim			:= {}
Local aCondSint		:= {}
Local aAtuSint		:= {}
Local aChave		:= {}
Local aDescRel		:= {}
Local aCodRel		:= {}
Local aDescri		:= {}
Local aConCat		:= {}
Local aF3			:= {}
Local aFaixa   		:= {}
Local aValid   		:= {}
Local aDescCfg 		:= {}
Local aParametros	:= {}
Local aRet			:= {}
Local aProcessa		:= {}
Local aTotais		:= {}
Local aVazio    	:= {}
Local aAuxTot		:= {}
Local aFiltros		:= {}
Local aTam			:= {}
Local nTam			:= 0
Local nRecno		:= 0
Local lViewCfg		:= If(nViewCfg==1,.T.,.F.)
Local nZ
Local aTeste, nNivel, nPai,cChav,cChavOri,cChaveRel,cChaveAtu,lSintetica  
Local cCampoTmp
Local bAntesWhile	:= {|nx|    dbSelectArea(aAlias[nx]), ;
			  							dbSetOrder(aOrdem[nx]), ;
										dbSeek(xFilial()+aIni[nx],.T.) }

Local aItProc	:= {}
Local bCodProc	:= MontaBlock("{|cCub,cChv|"+cProcessa+"(cCub,cChv)}")
Local lAcesso  	:= .T., nDirAcesso
Local nNivComp	:= 0	
Local nK
Local aStructAKT:= {}
Local cEntAdic  := ""


Private aNivFil   	:= {}
Private cPlano		:= "01" // Usado pela consulta padrao CV0x
Private cCodigo		:= ""   // Usado pela consulta padrao CV0x

DEFAULT lForceNoSint:= .F.
DEFAULT aFilIni		:= {}
DEFAULT aFiltCfg	:= {}
DEFAULT aFilFim		:= {}
DEFAULT lZerado		:= .F.
DEFAULT aCfgCube  	:= {}
DEFAULT lProcessa	:= .T.
DEFAULT lVerAcesso 	:= .F.
DEFAULT lLimpArqAKT := .T.
DEFAULT lVisao 		:= .F.
DEFAULT lBloqueio 	:= .F.

//carrega as variaveis static
cTipoDB	:= Upper(TCGetDB())
lQuery	:= ( TcGetDb() # "AS/400" )
	
lOracle		:= "ORACLE"   $ cTipoDB
lPostgres 	:= "POSTGRES" $ cTipoDB
lDB2		:= "DB2"      $ cTipoDB
lInformix 	:= "INFORMIX" $ cTipoDB
cFilAKT 	:= xFilial("AKT")
_cConcSQL	  	:= If( lOracle .Or. lPostgres .Or. lDB2 .Or. lInformix, " || ", " + " )

If lBloqueio
	cModoAcesso := "1"
Else
	cModoAcesso := GetNewPar("MV_PCOMCHV","1")
EndIf

If ValType(aItCfgBlq) == "A" .And. !Empty(aItCfgBlq)
	aProcessa	:=	aClone(aItCfgBlq)
	nNivComp	:=	aItCfgBlq[1,8]
Endif
Private nCtdSleep := 0

aNiveis 	:= {}
aCpoChv		:= {}
cChaveAtu 	:= ''

SaveInter()
AL4->(dbSetOrder(1))
AL3->(dbSetOrder(1))

If lVerAcesso
	If SuperGetMV("MV_PCO_AL3",.F.,"2")!="1"  //1-Verifica acesso por entidade
		lAcesso := .T.                        // 2-Nao verifica o acesso por entidade
	Else
		If Empty(cConfig)
			Aviso(STR0011,STR0012,{STR0013},2)//"Atenção"###"Obrigatorio informar a configuração do cubo. Cubo nao sera processado."###"Fechar"
			RestInter()
			Return aProcessa
		Else
		    nDirAcesso := PcoDirEnt_User("AL3",cCodCube+cConfig, __cUserID, .F.)
		    If nDirAcesso == 0 //0=bloqueado
				Aviso(STR0011,STR0014+cCodCube+cConfig+STR0015,{STR0013},2)//"Atenção"###"Fechar"###"Usuario sem acesso a configuração de cubo  - "###". Cubo nao sera processado."
				RestInter()
				Return aProcessa
			ElseIf nDirAcesso == 1 //1-visualizacao    
			    lAcesso := .F.
			ElseIf nDirAcesso >= 2 //2-alteracao
			    lAcesso := .T.
			EndIf
		EndIf	
	EndIf
Else
	lAcesso := .T.	
EndIf

aAdd(aStructAKT,{"AKT_CHAVE","C", Len(AKT->AKT_CHAVE), 00})
dbSelectArea("AKW")
dbSetOrder(1)
nx := 0
If dbSeek(xFilial()+cCodCube)
	While !Eof() .And. xFilial()+cCodCube == AKW->AKW_FILIAL+AKW->AKW_COD
		aAdd(aAlias,AKW->AKW_ALIAS)  
		aAdd(aF3,AKW->AKW_F3)
		aAdd(aOrdem,1)
		aAdd(aIni,SPACE(AKW->AKW_TAMANH))
		aAdd(aFim,Replicate("z",AKW->AKW_TAMANH))
		aAdd(aCodRel,AKW->AKW_CODREL)
		aAdd(aChave,AKW->AKW_RELAC)
		aAdd(aCondSint,AKW->AKW_CNDSIN) 
		aAdd(aAtuSint, AKW->AKW_ATUSIN) // Macro para localizar a sintetica
		aAdd(aConcat,AKW->AKW_CONCDE)
		aAdd(aDescri,AKW->AKW_DESCRI)
		aAdd(aDescRel,AKW->AKW_DESCRE)
		aAdd(aFiltros,"")
		aAdd(aTotais, .T. ) 
		aAdd(aVazio, .F. )
		aAdd(aFaixa, .T. )
		aAdd(aValid, "" )          
		aAdd(aDescCfg,"")
		nTam += AKW->AKW_TAMANH
		aAdd(aTam,nTam)
		aAdd(aStructAKT,{"CAMPO"+StrZero(Len(aTam),3),"C", AKW->AKW_TAMANH, 00})

		If AKW->(FieldPos("AKW_OBRIGA") > 0).And. AKW->AKW_OBRIGA != "1"  //se campo e opcional
			aVazio[Len(aVazio)] := .T.
		EndIf	
	
		If cConfig <> Nil .And. !Empty(cConfig)
			If AL3->( dbSeek(xFilial()+cConfig))
				aDescCfg[Len(aDescCfg)] := AllTrim(AL3->AL3_DESCRI)
			EndIf
			If AL4->(dbSeek(xFilial()+cConfig+cCodCube+AKW->AKW_NIVEL))
				aTotais[Len(aTotais)] := If(AL4->AL4_DETALH == "1",.T.,.F.)
				aIni[Len(aIni)] := Left(AL4->AL4_EXPRIN,AKW->AKW_TAMANH)
				aFim[Len(aFim)] := Left(AL4->AL4_EXPRFI,AKW->AKW_TAMANH)
				aFiltros[Len(aFiltros)] := Alltrim(AL4->AL4_FILTER)
				If AL4->(FieldPos("AL4_TPFAIX") > 0 .And. FieldPos("AL4_VALID") > 0)
					aFaixa[Len(aFaixa)] := (AL4->AL4_TPFAIX == "2")
					If !Empty(AL4->AL4_VALID)
						aValid[Len(aValid)] := Alltrim(AL4->AL4_VALID)
					EndIf
				EndIf	
			EndIf
		EndIf
		nx++
		dbSelectArea("AKW")
		dbSkip()
	End
EndIf
nMaxNiveis := nx 


For nu := 1 to nQtdVal
	aAdd(aAuxTot,0)  // Acumuladores do processamento
Next

For nx := 1 To Len(aConcat)
	If nx == 1
		aAdd(aParametros,{4,STR0001,aTotais[nx],aConcat[nx],120,,.F.}) //"Imprimir Totais : "
	Else
		aAdd(aParametros,{4,"",aTotais[nx],aConcat[nx],120,,.F.})
	EndIf
Next

If FWIsInCallStack("PCOR650") .AND. Len(aFilIni) <> Len(aIni)
	Help(" ",1,"PCO650R")//"A Estrutura da Visão está diferente da Estrutura do Cubo. / Cadastre ou altere a estrutura para que fiquem do mesmo tamanho."
	Return {}
EndIf

For nx := 1 to Len(aFilIni)
	If aFilIni[nx]<>Nil
		aIni[nx] := PadR(aFilIni[nx],Len(aIni[nX]))
	EndIf
Next

For nx := 1 to Len(aFilFim)
	If aFilFim[nx]<>Nil
		aFim[nx] := PadR(aFilFim[nx],Len(aFim[nX]))
	EndIf
Next

For nX := 1 to Len(aFiltCfg)
	If aFiltCfg[nx]<>Nil
		aFiltros[nx] := aFiltCfg[nx]
	EndIf
Next


For nx := 1 to Len(aAlias)
	If lAcesso
		If aFaixa[nX]
			aAdd(aParametros,{1,AllTrim(aDescri[nx])+STR0002,aIni[nx], "" ,"",aF3[nx],"", Len(aIni[nx])*7 ,.F.}) //" de "
			aAdd(aParametros,{1,AllTrim(aDescri[nx])+STR0003,aFim[nx], "" ,"",aF3[nx],"", Len(aFim[nx])*7 ,.F.}) //" Ate "
		Else
			cValid := If(Empty(aValid[nX]), "", aValid[nX])
			cValid := "(mv_par"+StrZero(Len(aAlias)+((nX*3)-3)+2,2)+":=mv_par"+StrZero(Len(aAlias)+((nX*3)-3)+1,2)+", "+If(Empty(cValid),".T.",cValid)+")"
			aAdd(aParametros,{1,AllTrim(aDescri[nx])+STR0002,aIni[nx], "" ,cValid,aF3[nx],"", Len(aIni[nx])*7 ,.F.}) //" de "
			aAdd(aParametros,{1,AllTrim(aDescri[nx])+STR0003,aFim[nx], "" ,"",aF3[nx],".F.", Len(aFim[nx])*7 ,.F.}) //" Ate "
		EndIf
		aAdd(aParametros,{7,STR0004+AllTrim(aDescri[nx]),aAlias[nx],aFiltros[nx]}) //"Filtro "
	Else
		aAdd(aParametros,{1,AllTrim(aDescri[nx])+STR0002,aIni[nx], "" ,"",aF3[nx],".F.", Len(aIni[nx])*7 ,.F.}) //" de "
		aAdd(aParametros,{1,AllTrim(aDescri[nx])+STR0003,aFim[nx], "" ,"",aF3[nx],".F.", Len(aFim[nx])*7 ,.F.}) //" Ate "
		aAdd(aParametros,{7,STR0004+AllTrim(aDescri[nx]),aAlias[nx],aFiltros[nx], ".F."}) //"Filtro "
	EndIf
	aAdd(aNivFil, xFilial(aAlias[nX]))
Next

aAdd(aParametros,{5,STR0005,lZerado,125,,.F.}  ) //"Processar resultados de valores zerados "

aAdd(aParametros,{5,STR0006,.F.,145,,.F.}  ) //"Mostrar resultados sintéticos a partir do segundo nivel "

//se nao permitir digitacao dos parametros considerar os padroes
If !lViewCfg
	aConfig := ARRAY(Len(aParametros))
	For nx:=1 TO Len(aParametros)
		aConfig[nx] := aParametros[nX,If(aParametros[nx,1]==7, 4, 3)]
	Next		
EndIf

If !Empty(aAlias) .And. (( lViewCfg .And. ParamBox(  aParametros ,STR0007,aConfig,,,.F.,,,,,.F.) ) .Or. !lViewCfg) //"Configuração de Saldos"
   
	aCfgCube := aClone(aConfig)
	If aItCfgBlq == Nil .OR. ( ValType(aItCfgBlq) == "A" .And. Empty(aItCfgBlq) )
		For nx := 1 to Len(aConcat)
			aTotais[nx] := aConfig[nx]
		   If aTotais[nx]
		   	aAdd(aNiveis,nx)
		   EndIf
		Next
	Else
		aFill(aTotais,.F.)
		aTotais[nNivComp]	:=	.T.
	Endif
	nu := 1
	For nx := Len(aConcat)+1 to Len(aConcat)+(Len(aAlias)*3) Step 3
		aIni[nu] := aConfig[nx]
		nu++
	Next
	nu := 1
	For nx := Len(aConcat)+2 to Len(aConcat)+(Len(aAlias)*3) Step 3
		aFim[nu] := aConfig[nx]
		nu++
	Next
	nu := 1
	For nx := Len(aConcat)+3 to Len(aConcat)+(Len(aAlias)*3) Step 3
		aFiltros[nu] := aConfig[nx]
		nu++
	Next

	aItProc := Array(nMaxNiveis)
/*	For nX:=1  TO nNivComp
		aItProc[nx] := Nil
	Next		
*/	For nX:=nNivComp+1  TO nMaxNiveis
		aItProc[nx] := aClone({})
	Next	
	lZerado	:=	aConfig[Len(aConfig)-1]
	lSintetica	:=	aConfig[Len(aConfig)]

If cModoAcesso == "4" 
	If cArqAKT == NIL
		PcoCar_Query(cCodCube, aTam, @cArqAKT, aStructAKT)
		cCuboAnt := cCodCube
    /*
	ElseIf cArqAKT != NIL .And. lVisao   //se for visao ja carregou cArqAKT
							            //e o cubo eh sempre o mesmo
    */
	ElseIf cArqAKT != NIL .And. ! lVisao  //se nao for visao
	    //testa para verificar se nao mudou o cubo
		If cCuboAnt == NIL .OR. cCodCube != cCuboAnt  //se mudou tem q carregar
			MsErase(cArqAKT)
			PcoCar_Query(cCodCube, aTam, @cArqAKT, aStructAKT)
			cCuboAnt := cCodCube
		EndIf
		
	EndIf
	aQuery  	:= {}
	cQryTab 	:= ""
	cQryWhere 	:= ""
  	For nX := nNivComp+1 TO nMaxNiveis
		// Inicio do processamento 1o Nivel  
		cFiltro		:=	""
		cFilSintOK	:=	""
		If lQuery                 
			DbSelectArea(aAlias[nx])
			DbSetOrder(1)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Traduz o filtro para ser executado na query³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aFiltros[nx])  
				cFiltro	:=	PcoParseFil(aFiltros[nx],aAlias[nx])
			Endif                                                                         
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cria um filtro para nao trazer as sinteticas se nao deve processalas a aprtir do segundo nivel³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ((!lSintetica .And. nX > 1).Or.lForceNoSint ).And. !Empty(aCondSint[nX])
				cFilSintOk 	:= PcoParseFil("!("+Alltrim(aCondSint[nX])+")",aAlias[nx])
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Converte o De-Ate em um between para ser utilizado na query³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cIni	 :=	aIni[nx]
			cFim	 :=	aFim[nx]
			cBetWeen :=	""
			If !Empty(cFim) .And. !(Empty(cIni).And.Upper(cFim)==Replicate('Z',Len(cFim)))
				aCampos	:=	Str2Arr( StrTran( StrTran( Upper(aChave[nX]) , ")", "") , "DTOS(", "") , "+")
				For nZ:=1 To Len(aCampos)                             
					If Len(cFim) > 0        
						//Caso nao tenha o alias eu pego o campo inteiro						
						If At("->",aCampos[nZ]) == 0
							cCampoTmp	:=	Alltrim(aCampos[nZ])
						Else
							cCampoTmp	:=	Alltrim(Substr(aCampos[nZ],At("->",aCampos[nZ])+2))
						Endif
						
						cBetWeen	+=	" "+cCampoTMP+" BETWEEN '"+Substr(cIni,1,TamSX3(cCampoTMP)[1]) + "' AND '"+Substr(cFim,1,TamSX3(cCampoTMP)[1]) + "' AND "
				    	cFim		:=	Substr(cFim,TamSX3(cCampoTMP)[1]+1)	
				    	cIni		:=	Substr(cIni,TamSX3(cCampoTMP)[1]+1)	
				    	If Empty(cFim) // Forca o Z caso exita falta de Z no filtro
				    		cFim := StrTran(cFim, " " , "Z" )
				    	EndIf
					Endif
				Next
			EndIf
            cQuery  := ""
			cQuery 	+= If( SubStr(aAlias[nx],1,1)=="S", SubStr(aAlias[nx],2,2),aAlias[nx]) + "_FILIAL" + "='" + xFilial(aAlias[nx]) + "' AND "
			If !Empty(cBetween)
				cQuery 	+= cBetween			
			Endif
			If !Empty(cFiltro)
				cQuery += " (" + cFiltro	+") AND "// Adiciona expressao de filtro convertida para SQL
			Endif
			If !Empty(cFilSintOk)
				cQuery += " (" + cFilSintOk	+") AND "// Adiciona expressao de filtro de sinteticas convertida para SQL
			Endif
			cQuery += aAlias[nx]+".D_E_L_E_T_ =  ' ' "
			
			cQryWhere := cQuery
            cQryTab := RetSQLName(aAlias[nx]) + " " + aAlias[nx]
			
			cQuery 	:= " SELECT * "
			cQuery 	+= "  FROM " + RetSQLName(aAlias[nx]) + " " + aAlias[nx]
			cQuery 	+= "  WHERE "
			cQuery 	+= cQryWhere
			
			cQryWhere += " AND TMPAKT.CAMPO"+StrZero(nx,3)+" = "+Upper(StrTran(StrTran(aChave[nX],"+",_cConcSQL),"->","."))+" "

			aAdd(aQuery, {cQryTab, cQryWhere})
			
			cQuery += " ORDER BY  " + SqlOrder((aAlias[nx])->(IndexKey()))			
			cQuery := ChangeQuery(cQuery)                
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Fecha o alias da query, para executá-la com o mesmo alias ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea(aAlias[nx])
			DbCloseArea()
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), aAlias[nx], .T., .T. )
		Else 
			Eval(bAntesWhile, nx)
		Endif 

		While (aAlias[nx])->(!Eof() .And. If(lQuery,.T.,(xFilial() == &(If(Substr(aAlias[nx],1,1)=="S",Substr(aAlias[nx],2,2),aAlias[nx])+"_FILIAL") .And. &(aChave[nx])<=aFim[nx])))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Avalia a expresao do filtro para a entidade (em caso de nao ter sido resolvida pela query)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cFiltro) .And. !Empty(aFiltros[nx]) .And. !(&(aFiltros[nx]))
				(aAlias[nx])->(dbSkip())
 				Loop
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Avalia a expresao do filtro de sinteticas   (em caso de nao ter sido resolvida pela query)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lSintetica .And. Empty(cFilSintOK) .And. (nX > 1 .Or. lForceNoSint) .And. !Empty(aCondSint[nx]) .And. &(aCondSint[nx])
				(aAlias[nx])->(dbSkip())
 				Loop
			EndIf
			cChaveAtu  := &(aChave[nx])
			cChaveRel  := If(!Empty(aCodRel[nx]),&(aCodRel[nx]),cChaveAtu)
			If Empty(cChaveRel)
				cChaveRel := cChaveAtu
			EndIf
			nRecno := Iif(lQuery,(aAlias[nx])->R_E_C_N_O_,(aAlias[nx])->(RecNo()))
			aAdd(aItProc[nX], aClone({ nx, cChaveAtu, &(aDescRel[nx]), nRecno,  Empty(cFilSintOK) .And. If(!Empty(aCondSint[nx]),&(aCondSint[nx]),.F.),cChaveRel , MontaBlock("{|AUXCHAVE| " + aAtuSint[nX] + "}") }))
			(aAlias[nx])->(dbSkip())
		Enddo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reabre o alias da query³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lQuery
			DbCloseArea()
			DbSelectArea(aAlias[nx])
		Endif	
		If Empty(aIni[nx]) .And. aVazio[nx]
			aAdd(aItProc[nX], aClone({ nx, PadR(" ",Len(cChaveAtu)), STR0008, 0, .F.," ", nil})) //"Outros ( Nao especificado )        "
		EndIf	
	Next
   	nNivel 	:= nNivComp
	AKT->(DbSetOrder(1))

	//Monta as combinacoes dos cubos
	If Len(aProcessa) == 1
		cChavOri	:=	aProcessa[1,9]
		cChav		:=	aProcessa[1,1]
	   	nNivel 		:= 	aProcessa[1,8] 
	   	nPai 		:= 	1
	Else
		cChavOri	:=	""
		cChav		:=	""
	   	nNivel 		:= 	0
	   	nPai 		:= 	0
	Endif	
    //monta a query para passar para funcao NovaMtChvAKT
    cQuery := " SELECT * FROM "+cArqAKT+" TMPAKT "
	For nK := 1 TO Len(aQuery)
		cQuery += " , "+aQuery[nK,1]
	Next
	cQuery += " WHERE "
	For nK := 1 TO Len(aQuery)
		cQuery += aQuery[nK,2]
		cQuery += If(nK<Len(aQuery), " AND ", "")
	Next
	cQuery += " AND TMPAKT.D_E_L_E_T_ = ' '"

	Nova_Mt_ChvAKT(aProcessa, cQuery, aItProc, nQtdVal, aConcat, aAlias, aDescri, nNivel+1, nPai, nMaxNiveis, @cChav,cCodCube,lZerado,@cChavOri,lSintetica,aTam,,lProcessa,aDescCfg,aChave,aFiltros,aIni,aFim,aCondSint,aVazio)

Else

	//modo normal
	For nX := nNivComp+1 TO nMaxNiveis
		// Inicio do processamento 1o Nivel  
		cFiltro		:=	""
		cFilSintOK	:=	""
		If lQuery                 
			DbSelectArea(aAlias[nx])
			DbSetOrder(1)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Traduz o filtro para ser executado na query³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aFiltros[nx])  
				cFiltro	:=	PcoParseFil(aFiltros[nx],aAlias[nx])
			Endif                                                                         
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Cria um filtro para nao trazer as sinteticas se nao deve processalas a aprtir do segundo nivel³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ((!lSintetica .And. nX > 1).Or.lForceNoSint ).And. !Empty(aCondSint[nX])
				cFilSintOk 	:= PcoParseFil("!("+Alltrim(aCondSint[nX])+")",aAlias[nx])
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Converte o De-Ate em um between para ser utilizado na query³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cIni	 :=	aIni[nx]
			cFim	 :=	aFim[nx]
			cBetWeen :=	""
			If !Empty(cFim) .And. !(Empty(cIni).And.Upper(cFim)==Replicate('Z',Len(cFim)))
				aCampos	:=	Str2Arr( StrTran( StrTran( Upper(aChave[nX]) , ")", "") , "DTOS(", "") , "+")
				For nZ:=1 To Len(aCampos)                             
					If Len(cFim) > 0
					        
						//Caso nao tenha o alias eu pego o campo inteiro
						If At("->",aCampos[nZ]) == 0
							cCampoTmp	:=	Alltrim(aCampos[nZ]) 
						Else				
							cCampoTmp	:=	Alltrim(Substr(aCampos[nZ],At("->",aCampos[nZ])+2))
						Endif

						cBetWeen	+=	cCampoTMP+" BETWEEN '"+Substr(cIni,1,TamSX3(cCampoTMP)[1]) + "' AND '"+Substr(cFim,1,TamSX3(cCampoTMP)[1]) + "' AND "
				    	cFim		:=	Substr(cFim,TamSX3(cCampoTMP)[1]+1)	
				    	cIni		:=	Substr(cIni,TamSX3(cCampoTMP)[1]+1)	
				    	If Empty(cFim) // Forca o Z caso exita falta de Z no filtro
				    		cFim := StrTran(cFim, " " , "Z" )
				    	EndIf
					Endif
				Next
			EndIf
			cQuery 	:= " SELECT * "
			cQuery 	+= "  FROM " + RetSQLName(aAlias[nx]) + " " + aAlias[nx]
			cQuery 	+= "  WHERE "
			cQuery 	+= If( SubStr(aAlias[nx],1,1)=="S", SubStr(aAlias[nx],2,2),aAlias[nx]) + "_FILIAL" + "='" + xFilial(aAlias[nx]) + "' AND "
			If !Empty(cBetween)
				cQuery 	+= cBetween			
			Endif
			If !Empty(cFiltro)
				cQuery += " (" + cFiltro	+") AND "// Adiciona expressao de filtro convertida para SQL
			Endif
			If !Empty(cFilSintOk)
				cQuery += " (" + cFilSintOk	+") AND "// Adiciona expressao de filtro de sinteticas convertida para SQL
			Endif
			
			//ALTERACAO PARA TRATAR ENTIDADES GERENCIAIS ADICIONAIS (CV0/CT0) - Renato Neves
			IF aAlias[nX] == "CV0"
				cEntAdic := GetAdvFVal("AKW","AKW_CHAVER",XFilial("AKW")+cCodCube+StrZero(nX,2),1,"")
				cEntAdic := Right(AllTrim(cEntAdic),2)
				cEntAdic := GetAdvFVal("CT0","CT0_ENTIDA",XFilial("CT0")+cEntAdic,1,"")
				cQuery += " CV0_PLANO = '"+cEntAdic+"' AND " //Filtra o plano da entidade gerencial adicional
				cQuery += " CV0_CODIGO <> '"+Space(Len(CV0->CV0_CODIGO))+ "' AND " //A tabela CV0 grava um registro com código em branco que deve ser desconsiderado na query
			EndIf
			//
			
			cQuery += " D_E_L_E_T_ <> '*' "
			cQuery += " ORDER BY  " + SqlOrder((aAlias[nx])->(IndexKey()))			
			cQuery := ChangeQuery(cQuery)                
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Fecha o alias da query, para executá-la com o mesmo alias ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea(aAlias[nx])
			DbCloseArea()
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), aAlias[nx], .T., .T. )
		Else 
			Eval(bAntesWhile, nx)
		Endif 

		While (aAlias[nx])->(!Eof() .And. If(lQuery,.T.,(xFilial() == &(If(Substr(aAlias[nx],1,1)=="S",Substr(aAlias[nx],2,2),aAlias[nx])+"_FILIAL") .And. &(aChave[nx])<=aFim[nx])))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Avalia a expresao do filtro para a entidade (em caso de nao ter sido resolvida pela query)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cFiltro) .And. !Empty(aFiltros[nx]) .And. !(&(aFiltros[nx]))
				(aAlias[nx])->(dbSkip())
 				Loop
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Avalia a expresao do filtro de sinteticas   (em caso de nao ter sido resolvida pela query)³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lSintetica .And. Empty(cFilSintOK) .And. (nX > 1 .Or. lForceNoSint) .And. !Empty(aCondSint[nx]) .And. &(aCondSint[nx])
				(aAlias[nx])->(dbSkip())
 				Loop
			EndIf
			cChaveAtu  := &(aChave[nx])
			cChaveRel  := If(!Empty(aCodRel[nx]),&(aCodRel[nx]),cChaveAtu)
			If Empty(cChaveRel)
				cChaveRel := cChaveAtu
			EndIf
			nRecno := Iif(lQuery,(aAlias[nx])->R_E_C_N_O_,(aAlias[nx])->(RecNo()))
			aAdd(aItProc[nX], aClone({ nx, cChaveAtu, &(aDescRel[nx]), nRecno,  Empty(cFilSintOK) .And. If(!Empty(aCondSint[nx]),&(aCondSint[nx]),.F.),cChaveRel , MontaBlock("{|AUXCHAVE| " + aAtuSint[nX] + "}") }))
			(aAlias[nx])->(dbSkip())
		Enddo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reabre o alias da query³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lQuery
			DbCloseArea()
			DbSelectArea(aAlias[nx])
		Endif	
		If Empty(aIni[nx]) .And. aVazio[nx]
			aAdd(aItProc[nX], aClone({ nx, PadR(" ",Len(cChaveAtu)), STR0008, 0, .F.," ", nil })) //"Outros ( Nao especificado )        "
		EndIf	
	Next
   	nNivel 	:= nNivComp
	AKT->(DbSetOrder(1))
	//Monta as combinacoes dos cubos
	If Len(aProcessa) == 1
		cChavOri	:=	aProcessa[1,9]
		cChav		:=	aProcessa[1,1]
	   	nNivel 		:= 	aProcessa[1,8] 
	   	nPai 		:= 	1
	Else
		cChavOri	:=	""
		cChav		:=	""
	   	nNivel 		:= 	0
	   	nPai 		:= 	0
	Endif	
	If lProcessa
	    If nNivel+1 <= nMaxNiveis
		  	Processa({|| MontaChv(aProcessa, aItProc, nQtdVal, aConcat, aAlias, aDescri, nNivel+1, nPai, nMaxNiveis, @cChav,cCodCube,lZerado,@cChavOri,lSintetica,aTam,,lProcessa,aDescCfg,aChave,aFiltros,aIni,aFim,aCondSint,aVazio)},STR0009) //"Gerando Cubos..."
		EndIf
	Else
	    If nNivel+1 <= nMaxNiveis
			MontaChv(aProcessa, aItProc, nQtdVal, aConcat, aAlias, aDescri, nNivel+1, nPai, nMaxNiveis, @cChav,cCodCube,lZerado,@cChavOri,lSintetica,aTam,,lProcessa,aDescCfg,aChave,aFiltros,aIni,aFim,aCondSint,aVazio)
		EndIf
	EndIf                

EndIf

	//Processa os saldos e os totalizadores
	If lProcessa
		Processa({|| NewCubeProc(aProcessa, aTotais, cCodCube, bCodProc,nMaxNiveis,lZerado,lProcessa)},STR0010)  //"Verificando saldos..."
	Else
		NewCubeProc(aProcessa, aTotais, cCodCube, bCodProc,nMaxNiveis,lZerado,lProcessa)
	EndIf
	//Elimina os totalizadores que nao devem ser processados
	If aScan(aTotais,.F.) > 0
		aRet := {}    
		For nX := 1 To Len(aProcessa)
			If aTotais[aProcessa[nX,8]]
				AAdd(aRet,aProcessa[nX])
			Endif
		Next
		aProcessa := aRet
	Endif
	//Elimina as dimensoes zeradas
	If !lZerado              
		aRet := {}
		For nX := 1 To Len(aProcessa)
			nZerado := 0
			//aEval(aProcessa[nX,2],{|x| nZerado += x})
			For nZ := 1 TO Len(aProcessa[nX,2])
				If aProcessa[nX, 2, nZ] != 0
					nZerado := 1
					Exit
				EndIf
			Next		
			If nZerado != 0
				AAdd(aRet,aProcessa[nX])
			Endif
		Next
		aProcessa := aRet
	Endif
EndIf

If cModoAcesso == "4" .And. cArqAKT != NIL .And. lLimpArqAKT
	MsErase(cArqAKT)
	cArqAKT := NIL
EndIf

ASIZE(aItProc, 0)
aItProc := Nil

RestInter()
RestArea(aArea)

Return aProcessa

    
Static Function MontaChv(aProcessa, aItProc, nQtdVal, aConcat, aAlias, aDescri, nNivel, nPai, nMaxNiveis, cChav,cCodCube,lZerado,cChavOri,lSintetica,aTam,lSaldo,lProcessa,aDescCfg,aChave,aFiltro,aFilIni,aFilFim,aCondSint,aVazio)

Local cChvAnt	 := cChav       
Local cChvAntOri := cChavOri
Local cFilAdvpl  := aFiltro[nNivel]
Local cFilSintAdvPl := aCondSint[nNivel]       
Local nPaiAtu    := 0
Local nY         := 0
Local nLen       := 0
Local nLenChvAnt := Len(cChvAnt)
Local nTamNiv	 := aTam[nNivel]	// tamanho da chave no nivel atual (numerico)
Local aItProAux  := {}
Local aItProAux2 := {}
Local lPrimNiv   := (nNivel==1)
Local lFilAdvpl  := .T.			// Indica se deve executar a expressao de filtro em Advpl ao inves de incluir-la na Query
Local lFilSintAdvpl  := !lSintetica			// Indica se deve executar a expressao de filtro de Sintetica em Advpl ao inves de incluir-la na Query
Local aSldChave	 := {}
Local cNomeCpo	 := ""  // Nome do campo no nivel atual sem a referencia da tabela
Local nTamCpo
Local aNomeCpo	 := {}	// Array com Nomes do campo no nivel atual sem a referencia da tabela
Local aTamCpo   := {}
Local cTabNiv	 := ""	// Tabela do nivel atual do cubo                          
Local cFilSql    := ""
Local cFilSintSQL:= ""
Local cIni	 	 :=	""
Local cFim	 	 :=	""
Local cBetWeen 	 :=	""
Local aCampos 	 :=	{}
Local cCampoTMP	 :=	""
Local nZ		 :=	0
Local nTamChave	:=	0
Local nTamSx3Aux
Local nZX, cQuery := ""
Local lFaz_Join := .F.
Local lExecQry  := .T.
Local lAvanca
Local nInic
Local aAreaAux

Default lSaldo   := .T.

nTamChave := aTam[ nMaxNiveis ]   //AEval(aTam,{|x| nTamChave:=x})

If Empty(aItProc[nNivel])
	Return
EndIf	

If		cModoAcesso  == "4"
		lExecQry  := .F. 
		lFaz_Join := .T.
		 
ElseIf	cModoAcesso  == "3"
		lQuery := .F.
		
ElseIf 	cModoAcesso == "2"
		lExecQry := lQuery
		lFaz_Join := .F.

ElseIf 	cModoAcesso == "1"
		lExecQry := lQuery
		lFaz_Join := .T.

Else  //por default considera cModoAcesso -- 1
		lExecQry := lQuery
		lFaz_Join := .T.

EndIf

If lQuery .And. lExecQry

	If Empty(aCpoChv)  //variavel estatica que vai fazer tamsx3 dos campos
    	PcoTamChv(aChave, aCpoChv, aAlias)
	EndIf	
	cTabNiv   := aAlias[nNivel]
	//Somente o primeiro campo
	cNomeCpo  := aCpoChv[nNivel, 1, 1]
	nTamCpo   := aCpoChv[nNivel, 1, 2]
    //todos os campos
	aNomeCpo  := {}
	For nZX := 1 TO Len(aCpoChv[nNivel])
		aAdd(aNomeCpo, aCpoChv[nNivel, nZX, 1])
		aAdd(aTamCpo, aCpoChv[nNivel, nZX, 2])
	Next	

	If lFaz_Join	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Converte o De-Ate em um between para ser utilizado na query³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cIni	 :=	aFilIni[nNivel]
		cFim	 :=	aFilFim[nNivel]
		cBetWeen :=	""
		
		//se cIni >> cFim for de branco a ZZZZZZZZZZZZZ pega o 1o. e ultimo elem do nivel 
		If  ( Empty(cIni) .And. Upper(cFim) == Replicate('Z',Len(cFim)) )
			cIni := aItProc[nNivel, 1, 2]
			cFim := aItProc[nNivel, Len(aItProc[nNivel]), 2]
		EndIf

		//Se preeenchido | cFim |  e  | (preenchido cIni e cFim nao for ZZZZZZZZZZZZ) |
		If  !Empty(cFim) .And. !(Empty(cIni).And.Upper(cFim)==Replicate('Z',Len(cFim)))
	
			aCampos	:=	aCpoChv[nNivel]
			For nZ:=1 To Len(aCampos)
			
				If Len(cFim) > 0        
	
					cCampoTmp	:=	aCampos[nZ,1]
	
					If cIni == cFim   //faixa inicial e final igual
						cBetWeen+=	" AND "+cTabNiv+"."+cCampoTMP+" = '"+Substr(cIni,1,aCampos[nZ,2]) + "' "
					Else
						cBetWeen+=	" AND "+cTabNiv+"."+cCampoTMP+" BETWEEN '"+Substr(cIni,1,aCampos[nZ,2]) + "' AND '"+Substr(cFim,1,aCampos[nZ,2]) + "' "
					Endif
					
					//atribui novamente cFim e cIni para casos que dimensao tem campos compostos (2)
					//como por exemplo PLANILHA + VERSAO
			    	cFim	:=	Substr(cFim,aCampos[nZ,2]+1)	
			    	cIni	:=	Substr(cIni,aCampos[nZ,2]+1)	
			    	If Empty(cFim) // Forca o Z caso exita falta de Z no filtro
			    		cFim := StrTran(cFim, " " , "Z" )
			    	EndIf	
				Endif
	
			Next
	
		EndIf                            

	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se foi incluso um filtro para o nivel, converte a expressao Advpl para SQL ANSI ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( cFilAdvpl )
		cFilSql := PcoParseFil( cFilAdvpl, cTabNiv )
    Endif                
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria um filtro para nao trazer as sinteticas se nao deve processalas a aprtir do segundo nivel³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lSintetica .And. !lPrimNiv .And. !Empty(cFilSintAdvPl)
		cFilSintSQL := PcoParseFil("!("+Alltrim(cFilSintAdvPl)+")",cTabNiv)
	Endif
	
	If lFaz_Join
		lFaz_Join := !Empty(cBetween) .OR. !Empty(cFilSintSQL) .OR. !Empty(cFilSQL)
    EndIf
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca os saldos no nivel do cubo atual ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := " FROM " 
	cQuery += RetSqlName("AKT") + " AKT " 
    
	If ! lFaz_Join
		cNomeCPOIni	:=	"'"+aFilIni[nNivel]+"'"
		cNomeCPOFim	:=	"'"+aFilFim[nNivel]+"'"
		nTamSX3Aux := nTamCpo
	Else
		//pega os nomes dos campos para usar no join
	 	cNomeCpoIni := ""
	 	nTamSx3Aux := 0          
		For nZ := 1 To Len(aNomeCpo)
			cNomeCpoIni += cTabNiv + "." + aNomeCpo[nZ]
			nTamSX3Aux += aTamCpo[nZ]
			If nZ < Len(aNomeCpo)
				cNomeCpoIni += _cConcSQL
			EndIf
		Next nZ 
		cNomeCpoFim	:=	cNomeCpoIni

		//aqui faz o join com a tabela de origem do nivel do cubo
		//por exemplo com Centro de Custo CTT ou Conta Orcamentaria AK5
		cQuery += "," + RetSQLName( cTabNiv ) + " " + cTabNiv + " " 
		
	Endif	
    
	//condicao normal da tabela de saldos diarios
	cQuery += " WHERE "
	cQuery += " AKT.AKT_FILIAL = '" + cFilAKT + "'"
	cQuery += " AND AKT_CONFIG = '" + cCodCube + "' "

	//Incluida amarracao com a tabela principal
	cQuery += " AND ( AKT_CHAVE BETWEEN "        
       
	If lPrimNiv
		cQuery += cNomeCpoIni
		cQuery += " AND " + cNomeCpoFim
	Else	
		cQuery += "'" + cChvAntOri + "'"
		cQuery += _cConcSQL + cNomeCpoIni + " AND '" + cChvAntOri + "'" + _cConcSQL + "RTRIM("+cNomeCpoFim+") "	
	EndIf

	If nNivel == nMaxNiveis .And. ( nTamChave-nTamNiv == 0)
		cQuery += _cConcSQL + "'Z'"  // somente no ultimo nivel do cubo
	Else	
		cQuery += _cConcSQL + "'" + Replicate( "Z", nTamChave-nTamNiv ) + "'"
	EndIf	

	//Incluir WHERE para trazer todos os registros onde esta chave esta vazia
	If !aVazio[nNivel] 
		cQuery += " )"	
	Else
		cQuery += " OR AKT_CHAVE BETWEEN "
		If lPrimNiv
			cQuery += "'"+Replicate(" ",nTamSx3Aux)+"' "
			cQuery += " AND '" + Replicate(" ",nTamSx3Aux)+"' "
		Else
			cQuery += "'" + cChvAntOri + "'" 
			cQuery += _cConcSQL + "'" + Replicate( " ", nTamNiv-Len(cChvAntOri) ) + "' "
			cQuery += " AND '"	+ cChvAntOri + "'" 
			cQuery += _cConcSQL + "'" + Replicate( " ", nTamNiv-Len(cChvAntOri) ) + "' "
		EndIf
		If nTamChave >= nTamNiv
			cQuery += _cConcSQL + "'" + Replicate( "Z", nTamChave-nTamNiv ) + "' ) "
		Endif
	Endif

	//Ate aqui a query devera ficar assim :
	//( AKT_CHAVE BETWEEN 'xxxxxxx'||AK5_CO And 'xxxxxxx'||AK5_CO||'ZZZZZZZZZZZZZZZZZZZ' OR --Aqui pega amarrado pelo filtro da AK5
    //	AKT_CHAVE BETWEEN 'xxxxxxx'||'          ' And 'xxxxxxx'||'          '||'ZZZZZZZZZZZZZZZZZZZ' )  --Aqui traz os que tem CO em branco
	//  Acrescenta o filtro dos campos feitos na tela de configuracao

	If lFaz_Join
		// Acrescenta expressao de filtro convertida de Advpl para Sql, inclusa na tela de configuracao
		cQuery += " AND " + cTabNiv + "." 
		If Substr(cTabNiv,1,1)=="S"		
			cQuery += Substr(cTabNiv,2,2)
		Else
			cQuery += cTabNiv
		EndIf	
		cQuery += "_FILIAL = '" + aNivFil[nNivel] /*xFilial(cTabNiv)*/ + "' "
		
		If !Empty(cBetWeen)	
			cQuery += cBetWeen
		Endif	      

		If !Empty(cFilSql)
			cQuery += " AND ("+cFilSql+")"
		Endif         
	
		// Acrescenta expressao de filtro convertida de Advpl para Sql, inclusa na tela de configuracao
		If !Empty(cFilSintSQL)
			cQuery += " AND ("+cFilSintSQL+")"
		Endif
		//acrescenta expressao para tabela do Join
		cQuery += " AND " + cTabNiv + ".D_E_L_E_T_ = ' ' "    
	Endif                                                                    
	
	cQuery += " AND AKT.D_E_L_E_T_ = ' ' "

	// Verifica se deve filtrar pela expressao Advpl e retira o alias para comparar com a tabela da query
	lFilAdvpl := Empty(cFilSql) .And. !Empty(cFilAdvpl)
	
	If lFilAdvpl
		cFilAdvpl := StrTran(cFilAdvpl, cTabNiv + "->", "" )
	EndIf

	// Verifica se deve filtrar sintetica pela expressao Advpl e retira o alias para comparar com a tabela da query
	lFilSintAdvpl := !lPrimNiv .And. Empty(cFilSintSQL) .And. !Empty(cFilSintAdvPl)
	
	If lFilSintAdvpl
		cFilSintAdvpl := StrTran(cFilSintAdvPl, cTabNiv + "->", "" )
	EndIf       
	
	If lFilSintAdvpl .Or. lFilAdvpl                               
		If lFaz_Join
			cQuery := "SELECT AKT.AKT_CHAVE, " + cTabNiv + ".*" + cQuery
		Else
			cQuery := "SELECT DISTINCT AKT.AKT_CHAVE AKT_CHAVE " + cQuery
		EndIf
	Else                  
		cQuery := "SELECT DISTINCT AKT.AKT_CHAVE AKT_CHAVE " + cQuery
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona no array aSldChave as chaves do cubo que tem saldo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Retirado para melhoria de performance
	//cQuery := ChangeQuery( cQuery )
	If lInformix
		cQuery := StrTran(cQuery, "RTRIM(", "TRIM(")
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAKT", .T., .T. )
	dbSelectArea("TMPAKT")
        
	If lFilAdvpl .Or. lFilSintAdvpl

		Do While ! Eof()
	
			If aScan( aSldChave, Left( AKT_CHAVE, nTamNiv ) ) == 0
				lAvanca := .F.
               
				If lFilAdvpl
					If lFaz_Join
						lAvanca := ! &(cFilAdvpl)
                    Else
                    	//posicionar na tabela da dimensao correspondente
                    	aAreaAux := GetArea()
                    	dbSelectArea(cTabNiv)
                    	dbSetOrder(1)
                    	//pesquisar a chave
                    	nInic := (aTam[nNivel]-nTamCpo)+1
                    	cChvPesq := xFilial(cTabNiv)
                    	cChvPesq += Subs( TMPAKT->AKT_CHAVE, nInic, nTamCpo ) 
                    	If dbSeek(cChvPesq)
                    		//executar a macro
							lAvanca := ! &(cFilAdvpl)
						EndIf
						RestArea(aAreaAux)
					EndIf	
				EndIf
               
				If Empty(cFilSintSQL) .And. lFilSintAdvpl .And. !Empty(cFilSintAdvpl)
					If ! lAvanca
						If lFaz_Join
							lAvanca :=  ! &(cFilSintAdvpl)
				        Else
	                    	//posicionar na tabela da dimensao correspondente
	                    	aAreaAux := GetArea()
    	                	dbSelectArea(cTabNiv)
        	            	dbSetOrder(1)
    	                	//pesquisar a chave
	                    	nInic := (aTam[nNivel]-nTamCpo)+1
    	                	cChvPesq := xFilial(cTabNiv)
        	            	cChvPesq += Subs( TMPAKT->AKT_CHAVE, nInic, nTamCpo ) 
            	        	If dbSeek(cChvPesq)
	        	            	//executar a macro
								lAvanca :=  ! &(cFilSintAdvpl)
							EndIf
							RestArea(aAreaAux)
				        EndIf
					EndIf
                EndIf

				If lAvanca
					dbSkip() 
					Loop
				EndIf
				AAdd( aSldChave, Left( AKT_CHAVE, nTamNiv ) ) 
			EndIf
		    
			dbSkip() 
			
		EndDo
	
	Else
	    
		Do While ! Eof()
	
			If aScan( aSldChave, Left( AKT_CHAVE, nTamNiv ) ) == 0
				AAdd( aSldChave, Left( AKT_CHAVE, nTamNiv ) ) 
			EndIf
		    
			dbSkip() 
		EndDo
	
	EndIf

	TMPAKT->(dbCloseArea())
	dbSelectArea("AKT")
EndIf

If cModoAcesso == '4' .And. ! lExecQry

//	aSldChave := aNivAKT
		
EndIf 
	                      
If lPrimNiv.And.lProcessa
	ProcRegua(len(aItProc[nNivel]))
EndIf	

VarRef( aItProAux, aItProc[nNivel] )

nLen := len(aItProAux)
If !lQuery .Or. (lZerado .Or. Len(aSldChave) > 0)

	For ny := 1 TO nLen
	
		If lPrimNiv.And.lProcessa
			IncProc()
		EndIf
		If !aItProAux[nY,5] .Or. lPrimNiv .Or. lSintetica 
			VarRef(aItProAux2,aItProAux[nY])
			cChavOri := Padr(cChvAntOri+aItProAux2[2],nTamNiv)
			cChav    := cChvAnt+If(!Empty(aItProAux2[6]),aItProAux2[6],PadR(aItProAux2[2],nTamNiv-nLenChvAnt))
			If !lZerado
				If lQuery .Or. !lExecQry
					lSaldo := (aScan(aSldChave,cChavOri) # 0)
				Else 	
					lSaldo := AKT->(MsSeek(cFilAKT+cCodCube+cChavOri))
				EndIf
				If lSaldo
				  	aAdd(aProcessa, {cChav, ;
			  					Array(nQtdVal), ;
			  					aConcat[nNivel], ;
			  					aAlias[nNivel], ;
			  					aDescri[nNivel], ;
			  					aItProAux2[3],;
			  					aItProAux2[4],;
			  					nNivel,;
			  					cChavOri,;
			  					aItProAux2[5],;
			  					nPai,;
			  					lSaldo,;
			  					aDescCfg[nNivel],;
								If(!Empty(aItProAux2[6]),aItProAux2[6],PadR(aItProAux2[2],nTamNiv-nLenChvAnt)),;
								(aScan(aSldChave,PadR( cChavOri, Len( AKT->AKT_CHAVE ) ) ) # 0),;
								If(Len(aItProAux2)>=7 .and. VALTYPE(aItProAux2[7])="B",Eval(aItProAux2[7],aItProAux2[6]),"") })

				    If nNivel+1 <= nMaxNiveis
					    nPaiAtu := Len(aProcessa)
					    MontaChv(aProcessa, aItProc, nQtdVal, aConcat, aAlias, aDescri, nNivel+1, nPaiAtu, nMaxNiveis, @cChav,cCodCube,lZerado,@cChavOri,lSintetica,aTam,lSaldo,lProcessa,aDescCfg,aChave,aFiltro,aFilIni,aFilFim,aCondSint,aVazio)
					EndIf
				Endif
			Else                                    
				If lSaldo
					If lQuery .OR. !lExecQry
						lSaldo := (aScan(aSldChave,cChavOri) # 0)
  					Else  
						lSaldo := AKT->(MsSeek(cFilAKT+cCodCube+cChavOri))
					EndIf 
				EndIf
                
				aAdd(aProcessa, {cChav, ;
			  					Array(nQtdVal), ;
			  					aConcat[nNivel], ;
			  					aAlias[nNivel], ;
			  					aDescri[nNivel], ;
			  					aItProAux2[3],;
			  					aItProAux2[4],;
			  					nNivel, ;
			  					cChavOri,;
			  					aItProAux2[5],;
			  					nPai,;
			  					lSaldo,;
			  					aDescCfg[nNivel],;
								If(!Empty(aItProAux2[6]),aItProAux2[6],PadR(aItProAux2[2],nTamNiv-nLenChvAnt)),;
								lSaldo,;
								If(Len(aItProAux2)>=7 .and. VALTYPE(aItProAux2[7])="B",Eval(aItProAux2[7],aItProAux2[6]),"") })

			    If nNivel+1 <= nMaxNiveis
				    nPaiAtu := Len(aProcessa)
				    MontaChv(aProcessa, aItProc, nQtdVal, aConcat, aAlias, aDescri, nNivel+1, nPaiAtu, nMaxNiveis, @cChav,cCodCube,lZerado,@cChavOri,lSintetica,aTam,lSaldo,lProcessa,aDescCfg,aChave,aFiltro,aFilIni,aFilFim,aCondSint,aVazio)
				EndIf
			EndIf
		EndIf
		
	Next

Endif

Return


Static Function NewCubeProc(aProcessa, aTotais, cCodCube, bCodProc, nMaxNiveis,lZerado,lProcregua)
Local nX              
Local nCtdSleep := 0
Local lProcessa	:=	.T.
Local aProcAux  := {}
Local lExecCodBlock := .T.

AKT->(DbSetOrder(1))

If lProcregua
	ProcRegua(Len(aProcessa)/100)
EndIf

For nX := 1 TO Len(aProcessa)
	
	If lProcregua
   		If  (Mod(nX,100)==0).And.lProcRegua
			IncProc()
		EndIf                                      
	EndIf
	
	VarRef(aProcAux, aProcessa[nX])
                 
	// Se nao pediu saldos zerados, processa somente com saldo
	If !lZerado  
		lProcessa := aProcAux[12]		// Tem saldo? (.T./.F.)
	Endif	

	If lProcessa
		If nCtdSleep > 5
			Sleep(1)
		   	nCtdSleep := 0	
		Else
	    	nCtdSleep++
		EndIf	
		
		If  cModoAcesso == '4' .And. Len(aProcessa[nX]) > 14
			lExecCodBlock := aProcessa[nX,15]
		EndIf
		
		If lExecCodBlock
			aRet := Eval(bCodProc, cCodCube, aProcessa[nX,9])
		Else
			aRet := Array(Len(aProcessa[nX,2]))
			aFill(aRet, 0)
		EndIf
		Cubo_Totaliza(aProcessa, aTotais, nX, aClone(aRet),Len(aRet),lZerado)
	Endif
Next

Return

Static Function Cubo_Totaliza(aProcessa, aTotais, nX, aRet,nQtdVal, lZerado)
Local nZerado
Local nu

If nX > 0
	nZerado := 0
	
	If !lZerado
		//aEval(aRet,{|x| nZerado += x}) 
		For nu := 1 TO Len(aRet)
			If aRet[nu] != 0
				nZerado := 1
				Exit
			EndIf
		Next
	Else
		nZerado := 1
	EndIf		
	
	If Len(aProcessa[nX,2]) > 0 .And. aProcessa[nX,2,1] == Nil
		aFill(aProcessa[nX,2],0)
	Endif	
	
	If nZerado != 0 
		If aTotais[aProcessa[nX,8]]
			For nU := 1 to Len(aProcessa[nX,2])
				aProcessa[nX,2,nu] += aRet[nU]
			Next
		EndIf
	
		If aProcessa[nX,11] > 0.And. !aProcessa[nX,10] 
			Cubo_Totaliza(aProcessa, aTotais, aProcessa[nX,11], If(aProcessa[nX,10], aClone(aProcessa[nX,2]), aClone(aRet)),nQtdVal, lZerado)
		EndIf
	EndIf

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoTamChv  ºAutor ³Paulo Carnelossi      º Data ³ 25/09/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna no array aCpoChv o nome do campo e tamanho         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PcoTamChv(aChave, aCpoChv, aAlias)
Local nX, nY
Local cNomeCpo, aNomeCpo, cTabNiv

For nX := 1 TO Len(aChave)

	cTabNiv   := aAlias[nX]
	cNomeCpo  := Alltrim(aChave[nX])
	cNomeCpo  := Alltrim(StrTran(cNomeCpo, cTabNiv+"->", ""))
	aNomeCpo  := Str2Arr( StrTran( StrTran( Upper(cNomeCpo) , ")", "") , "DTOS(", "") , "+")
    If Len(aNomeCpo) == 1
		aAdd(aCpoChv, aClone({{/*nomeCampo*/,/*Tamanho*/,/*elemento original*/}}) )
		aCpoChv[nX,1,1] := aNomeCpo[1]
		aCpoChv[nX,1,2] := TamSX3(aNomeCpo[1])[1]
		aCpoChv[nX,1,3] := aChave[nX]
	Else
		aAdd(aCpoChv, aClone({}) )
		For nY := 1 TO Len(aNomeCpo)
			aAdd(aCpoChv[nX], aClone({/*nomeCampo*/,/*Tamanho*/,/*elemento original*/}) )
			aCpoChv[nX,nY,1] := aNomeCpo[nY]
			aCpoChv[nX,nY,2] := TamSX3(aNomeCpo[nY])[1]
			aCpoChv[nX,nY,3] := aChave[nX]
		Next
	EndIf	
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Nova_Mt_ChvAKT ºAutor ³Paulo Carnelossi  º Data ³ 25/09/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Utilizada somente com parametro MV_PCOMCHV == "4"          º±±
±±º          ³ Para montar as chaves de acordo com os filtros e tabela    º±±
±±º          ³ com os saldos envolvidos na configuração                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Nova_Mt_ChvAKT(aProcessa, cQuery, aItProc, nQtdVal, aConcat, aAlias, aDescri, nNivel, nPai, 	nMaxNiveis, cChav, cCodCube, lZerado, cChavOri, lSintetica, aTam, lSaldo, lProcessa, aDescCfg, aChave, aFiltros, aIni, aFim, aCondSint, aVazio)
Local cChave, nPos, nX, cBusca
Local aItProAux := {}
Local aItProAux2:= {}
cQuery += " ORDER BY AKT_CHAVE"
cQuery := ChangeQuery( cQuery )

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPSLD", .T., .T. )

While ! Eof()
	For nX := 1 TO nMaxNiveis
		If At("CAMPO"+StrZero(nX,3),cQuery) > 0
			cBusca := FieldGet(FieldPos("CAMPO"+StrZero(nX,3)))
			nPos := ASCAN(aItProc[nX], {|aVal| Alltrim(aVal[2]) == Alltrim(cBusca) })

			If nPos == 0
				dbSkip()  //nao considera pula
			EndIf
		EndIf	
	Next		
	If !Eof()	
		cChave := Padr( AKT_CHAVE, Len( AKT->AKT_CHAVE ) )
		Carga_aProcessa( aProcessa, aItProc, nQtdVal, aConcat, aAlias, aDescri, nMaxNiveis/*nNivel*/, nPai, nMaxNiveis, cChave,cCodCube,lZerado,cChavOri,lSintetica,aTam,,lProcessa,aDescCfg,aChave,aFiltros,aIni,aFim,aCondSint,aVazio)
		dbSkip()
	EndIf	

EndDo

dbSelectArea("TMPSLD")
dbCloseArea()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Carga_aProcessaºAutor ³Paulo Carnelossi  º Data ³ 25/09/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega o Array aProcessa com as chaves em todos os        º±±
±±º          ³ niveis                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Carga_aProcessa(aProcessa, aItProc, nQtdVal, aConcat, aAlias, aDescri, nNivel, nPai, nMaxNiveis, cChav,cCodCube,lZerado,cChavOri,lSintetica,aTam,lSaldo,lProcessa,aDescCfg,aChave,aFiltros,aIni,aFim,aCondSint,aVazio)
Local aItProAux := {}
Local aItProAux2:= {}
Local lPrimNiv
Local cChave 	:= ""	
Local nPos, nProc
Local nTamNiv
Local nLenChvAnt

If nNivel == 0  //nMaxNiveis-1  
	nPai := 0
	Return
Else	
	Carga_aProcessa(aProcessa, aItProc, nQtdVal, aConcat, aAlias, aDescri, nNivel-1, @nPai, nMaxNiveis, cChav, cCodCube,lZerado,@cChavOri,lSintetica,aTam,,lProcessa,aDescCfg,aChave,aFiltros,aIni,aFim,aCondSint,aVazio)
EndIf

//Qdo sair da recursividade 	
lPrimNiv  := (nNivel==1)

VarRef( aItProAux, aItProc[nNivel] )

If lPrimNiv.And.lProcessa
	IncProc()
EndIf
    
nTamNiv	 := aTam[nNivel]	// tamanho da chave no nivel atual (numerico)
cChave := PadR(cChav, nTamNiv)
cChavOri := Alltrim(cChave)
cChvXyz := Alltrim(FieldGet(FieldPos("CAMPO"+StrZero(nNivel,3))))
nPos := ASCAN(aItProAux, {|aVal| aVal[2] = cChvXyz })
    nProc := ASCAN(aProcessa, {|aVal| aVal[9] = cChavOri })
  
    If nPos > 0 .And. nProc == 0
    If nNivel > 1
		nLenChvAnt := aTam[nNivel-1]    
    Else
		nLenChvAnt := 0
	EndIf
		
	If !aItProAux[nPos,5] .Or. lPrimNiv .Or. lSintetica 

		VarRef(aItProAux2,aItProAux[nPos])
	  	aAdd(aProcessa, {	PadR(cChave, nTamNiv), ;
	  						Array(nQtdVal), ;
		  					aConcat[nNivel], ;
		  					aAlias[nNivel], ;
	  						aDescri[nNivel], ;
	  						aItProAux2[3],;
		  					aItProAux2[4],;
		  					nNivel,;
	  						cChavOri,;
	  						aItProAux2[5],;
	  						nPai,;
		  					.T.,;
		  					aDescCfg[nNivel],;
							If(!Empty(aItProAux2[6]),aItProAux2[6],PadR(aItProAux2[2],nTamNiv-nLenChvAnt)),;
							( nNivel  == nMaxNiveis ),;
							If(Len(aItProAux2)>=7 .and. VALTYPE(aItProAux2[7])="B",Eval(aItProAux2[7],aItProAux2[6]),"") })
		nPai := Len(aProcessa)
	EndIf
Else
	If nProc > 0
		nPai := nProc
	EndIf	
EndIf

Return
