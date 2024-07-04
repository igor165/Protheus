#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEFISAFP.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} GPEFISAFP
//Exporta arquivo .INI para importação na rotina MATA950
@author  Ana Carolina Martins
@since   12/04/2019
@version 0.1
/*/
//-------------------------------------------------------------------
Static  aEmpCor 	:= FwLoadSM0()
Function GPEFISAFP()
   
    Private aLog      	:= {}
    Private aTitle    	:= {}
    Private aCampos	  	:={}
    Private	aCposCab	:= {}
    Private cAlsCABTB 	:= "aliasCAB"    
    Private cAliasTMP 	:= "aliasAFP"  
    Private oTmpTable,oTmpCab  
    
	Pergunte("GPR710A",.T.)		
	oTmpTable := fCriaTmp(@cAliasTMP, @aCampos,@cAlsCABTB)
	dbSelectArea(cAlsCABTB)
	dbSelectArea(cAliasTMP)
	
    ProcGpe( {|lEnd| ProcAFP(@cAliasTMP)},,,.T. )
    fMakeLog(aLog,aTitle,,,"TelaGeraAFP",OemToAnsi(STR0001),"M","P",,.F.) 
Return cAliasTMP

/*/{Protheus.doc} ProcAFP
//Responsável pela regra de negócio e preenchimento dos dados nas estruturas temporárias.
@author edvf8
@since 08/10/2019
@version undefined
@return return, return_description
@param cAliasTMP, characters, descricao
/*/
Static Function ProcAFP(cAliasTMP)

Local cAcessaSRA	:= &( " { || " + ChkRH( "GPEFISAFP" , "SRA" , "2" ) + " } " )
Local cInicio		:= ""
Local cFim 			:= ""
Local nSavRec
Local nSavOrdem
Local aPerAberto 	:= {}
Local aPerFechado	:= {}
Local aPerTodos		:= {}
Local aCodFol		:= {}
Local cFilAnt 		:= ""
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis para controle em ambientes TOP.                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cAlias   	:= ""
Local cQuery
Local aStruct  	:= {}
Local lQuery  	:= .F.
Local lJubilac	:= .F.
Local lMaior	:= .F.
lOCAL lVerba	:= .F.
Local cCateg  	:= ""
Local cSitu   	:= ""
Local nAux
Local cPeriodos
Local nDiasProp := 0
Local nDias 	:= 0
Local nTotDias	:= 0
Local dAdmissa	:= ""
Local dDemissa	:= ""
Local cAliasSR9 := "QSR9"
Local cTpcotiz  := ""
Local nReg		:= 1
Local lCab		:= .T.
Local aPer		:= {}
Local nCOnt		:= 1
Private cQrySRA := "SRA"
Private cQrySRD	:= "SRD"
Private nFunc 		:= 0
Private cNOVEDAD 		:= ""
Private cFechNoved	:= ""
Private cTipoCI		:= ""
Private cNumNua		:= ""
Private nVCol21     := 0
Private nVCol22     := 0
Private nVCol23     := 0
Private nVCol24     := 0
Private nVCol25     := 0
Private nVCol26     := 0
Private nVCol27     := 0
Private nVCol28     := 0
Private nCol21Tot   := 0
Private nCol22Tot   := 0
Private nCol23Tot   := 0
Private nCol24Tot   := 0
Private nCol25Tot   := 0
Private nCol26Tot   := 0
Private nCol27Tot   := 0
Private nCol28Tot   := 0
Private	lReg		:= .F.
Private aSR9    	:= {}  // Centro de Custo
Private nRDValor	:= 0

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis Utilizadas na funcao IMPR                          ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private nTipo		:= 1
Private cFilialDe   := ""
Private cFilialAte  := ""
Private cMes 		:= ""
Private cAno		:= ""
Private cMatDe      := ""
Private cMatAte     := ""
Private cCustoDe    := ""
Private cCustoAte   := ""
Private cNomeDe     := ""
Private cNomeAte    := ""
Private cSit        := ""
Private cCat        := ""
Private nQtdDias	:= 0

nTipo 		:= mv_par01
cFilialDe 	:= iif(Empty(mv_par02),"",mv_par02)
cFilialAte  := iif(Empty(mv_par03),"",mv_par03)
cMes	 	:= Left(mv_par04,02)
cAno		:= Right(mv_par04,04)
cMatDe		:= mv_par05
cMatAte     := mv_par06
cCustoDe    := mv_par07
cCustoAte   := mv_par08
cNomeDe     := mv_par09
cNomeAte    := mv_par10
cSit        := mv_par11
cCat        := mv_par12
cMesAno		:= mv_par04	

SetMnemonicos(NIL,NIL,.T.,"P_DESCFALT")

#IFDEF TOP
	lQuery := .T.
#ELSE
    cQrySRA:= "SRA"
	dbSelectArea("SRA")
	nSavRec   := RecNo()
	nSavOrdem := IndexOrd()
#ENDIF

If lQuery
	cQueryOrd := "RA_FILIAL, RA_MAT"
Else
	dbSetOrder(1)
	SRA->( dbSeek( cFilialDe + cMatDe, .T. ) )
Endif

	cInicio  := "(cQrySRA)->RA_FILIAL + (cQrySRA)->RA_MAT"
	cFim     := cFilialAte + cMatAte
	//Filtra do SRA: filial, matricula de/ate, centro de custo de/ate, categoria e situacoes
	cAlias := "SRA"
	cQrySRA := "QSRA"

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Buscar Situacao e Categoria em formato para SQL              ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cSitu   := "("
	For nAux := 1 To (Len( cSit )-1)
		cSitu += "'" + Substr( cSit, nAux, 1) + "',"
	Next nAux
	cSitu 	+= "'" + Substr( cSit, len(cSit)-1, 1) + "')"

	cCateg   := "("
	For nAux := 1 To (Len( cCat )-1)
		cCateg += "'" + Substr( cCat, nAux, 1) + "',"
	Next nAux
	cCateg	+= "'" + Substr( cCat, len(cCat)-1, 1) + "')"

	//montagem da query
	cQuery := "SELECT "
 	cQuery += " RA_FILIAL, RA_MAT, RA_PRISOBR, RA_SECSOBR, RA_PRINOME, RA_SECNOME, RA_NOME, RA_RG, RA_TIPODOC, RA_NRNUA, RA_NATURAL,"
 	cQuery += " RA_ADMISSA, RA_DEPTO, RA_DEMISSA, RA_NASC, RA_TPAFP, RA_AFPOPC, RA_HRSMES, RA_CATFUNC, RA_JUBILAC, RA_TPSEGUR, RA_APELIDO"
	cQuery += " FROM " + RetSqlName(cAlias) + " WHERE RA_FILIAL BETWEEN '" + cFilialDe + "' AND '" + cFilialAte + "'"
	cQuery += " AND RA_MAT BETWEEN '" + cMatDe + "' AND '" + cMatAte + "'"
	cQuery += " AND RA_NOME BETWEEN '" + cNomeDe + "' AND '" + cNomeAte + "'"
	cQuery += " AND RA_CC BETWEEN '" + cCustoDe + "' AND '" + cCustoAte + "'"
	cQuery += " AND RA_TPAFP = '" + iif(nTipo == 1, "1", "2") + "'"
	cQuery += " AND RA_SITFOLH IN " + cSitu
	cQuery += " AND RA_CATFUNC IN " + cCateg
	cQuery += " AND D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY " + cQueryOrd

	cQuery := ChangeQuery(cQuery)
	aStruct := (cAlias)->(dbStruct())

	If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRA,.T.,.T.)
		For nAux := 1 To Len(aStruct)
			If ( aStruct[nAux][2] <> "C" )
				TcSetField(cQrySRA,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
			EndIf
		Next nAux                                   '
	Endif

	dbSelectArea(cQrySRA)
	(cQrySRA)->(dbGoTop())



While (cQrySRA)->( !Eof() .And. &cInicio <= cFim )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Movimenta Regua de Processamento                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cFil	:= (cQrySRA)->RA_FILIAL
	cMat	:= (cQrySRA)->RA_MAT
	dAdmissa :=(cQrySRA)->RA_ADMISSA
	dDemissa :=(cQrySRA)->RA_DEMISSA

	If cFilAnt <> (cQrySRA)->RA_FILIAL       
		//carrega periodo da competencia selecionada
		cFilAux:= (cQrySRA)->RA_FILIAL
		fRetPerComp( cMes , cAno , , , , @aPerAberto , @aPerFechado , @aPerTodos )
		If len(aPerFechado) < 1
			cFilAux:= Space(FwGetTamFilial)
			fRetPerComp( cMes , cAno , cFilAux , , , @aPerAberto , @aPerFechado , @aPerTodos )
		Endif

		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Carrega Variaveis Codigos Da Folha                           ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If !fP_CodFol(@aCodFol,(cQrySRA)->RA_FILIAL)
			Return
		Endif

		nCol21Tot   :=0
		nCol22Tot   :=0
		nCol23Tot   :=0
		nCol24Tot   :=0
		nCol25Tot   :=0
		nCol26Tot   :=0
		nCol27Tot   :=0
		nCol28Tot   :=0
		nFunc:= 0
		cFilAnt := (cQrySRA)->RA_FILIAL

	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste Parametrizacao do Intervalo de Impressao            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  !lQuery .And. ( (SRA->RA_MAT <= cMatDe)   .Or. ;
		(SRA->RA_MAT >= cMatAte)   .Or. ;
		(SRA->RA_CC  <= cCustoDe) .Or. (SRA->RA_CC  >= cCustoAte)  .Or. ;
		(SRA->RA_NOME <= cNomeDe) .Or. (SRA->RA_NOME >= cNomeAte)  .Or. ;
		!(SRA->RA_CATFUNC $ cCat) .Or. !(SRA->RA_SITFOLH $ cSit)  )
			SRA->( dbSkip(1) )
			Loop
	EndIf

		//-- Buscar a maior data dos registros para retornar os registros
		cDelet := Iif(TcSrvType() != "AS/400", "%D_E_L_E_T_ = ' '%", "%@DELETED@ = ' '%" )
		BeginSql ALIAS cAliasSR9
			SELECT R9_FILIAL, R9_MAT, R9_CAMPO, R9_DESC
			FROM %table:SR9%
			WHERE R9_FILIAL = %exp:cFil%
			  AND R9_MAT = %exp:cMat%
			  AND ( R9_CAMPO = 'RA_ADMISSA' OR R9_CAMPO = 'RA_DEMISSA')
			  AND %exp:cDelet%
		EndSql

   		aSR9 := {}
		While (cAliasSR9)-> (!EOF())
			rFil	:= (cAliasSR9)->R9_FILIAL
			rMat	:= (cAliasSR9)->R9_MAT
			dCampo	:= (cAliasSR9)->R9_CAMPO
   		 	dData	:= cTod(Substr((cAliasSR9)->R9_DESC,1,2)+"/"+Substr((cAliasSR9)->R9_DESC,4,2)+"/"+Substr((cAliasSR9)->R9_DESC,7,4))

	    	Aadd (aSR9,{rFil,rMat,dCampo,dData})

		(cAliasSR9)-> (dbSkip())
		Enddo
		(cAliasSR9)->(DbCloseArea())

		For nAux = 1 to Len(aSR9)
   			If MesAno(aSR9[nAux][4]) == cAno+cMes
				If aSR9[nAux][3] == "RA_ADMISSA"
					dAdmissa := aSR9[nAux][4]
				Endif
				If aSR9[nAux][3] == "RA_DEMISSA"
					dDemissa := aSR9[nAux][4]
				Endif
           	Endif
   		Next nAux

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Consiste Filiais e Acessos                                             ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF !( (cQrySRA)->RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA ) .Or. (len(aPerFechado) < 1 .And. len(aPerAberto) < 1 )
		dbSelectArea(cQrySRA)
		(cQrySRA)->( dbSkip() )
   		Loop
	Endif

	//zera variaveis para cada funcionario
	nDiasProp	:= 0
	nTotDias	:= 0
	nVCol21     := 0
	nVCol22     := 0
	nVCol23     := 0
	nVCol24     := 0
	nVCol25     := 0
	nVCol26     := 0
	nVCol27     := 0
	nVCol28     := 0
	nRDValor	:= 0

	//quantidade de dias padrao para todos os funcionarios
	nQtdDias:= 30
  		
	If lQuery
		cQuery	:= ""
		cQrySRD := "QSRD"

		If Len(aPerFechado) > 0
			//busca periodos para formato Query
			cPeriodos   := "("
			cAlias := "SRD"
			For nAux:= 1 to (len(aPerFechado)-1)
				cPeriodos += "'" + aPerFechado[nAux][1] + "',"
			Next nAux
			cPeriodos += "'" + aPerFechado[len(aPerFechado)][1]+"')"
			If !Empty(cPeriodos)
				//montagem da query
				cQuery := "SELECT "
				cQuery += " RD_FILIAL, RD_MAT, RD_PROCES, RD_ROTEIR, RD_PERIODO, RD_SEMANA, RD_HORAS, RD_VALOR, RD_PD, RD_TIPO1 "
				cQuery += " FROM " + RetSqlName(cAlias)
				cQuery += " WHERE "
				cQuery += " RD_FILIAL = '" + cFilAnt + "'"
				cQuery += " AND "
				cQuery += " RD_MAT ='" + (cQrySRA)->RA_MAT + "'"
				cQuery += " AND "
				cQuery += " RD_PERIODO IN " + cPeriodos + CRLF
				cQuery += " AND "
				cQuery += " D_E_L_E_T_ = ' ' " + CRLF

			EndIf
		EndIF
		If len(aPerAberto) > 0
			cAlias := "SRC"
			If !Empty(cQuery) 
				cQuery	+=	"UNION ALL" + CRLF
			EndIf 
			cPeriodos:= ""
			cPeriodos   := "("
			For nAux:= 1 to (len(aPerAberto)-1)
				cPeriodos += "'" + aPerAberto[nAux][1] + "',"
			Next nAux
			cPeriodos += "'" + aPerAberto[len(aPerAberto)][1]+"')"
			If !Empty(cPeriodos)
				//MONTAGEM DA QUERY
				cQuery += "SELECT "
				cQuery += "  RC_FILIAL RD_FILIAL, RC_MAT RD_MAT, RC_PROCES RD_PROCES, RC_ROTEIR RD_ROTEIR,RC_PERIODO RD_PERIODO,RC_SEMANA RD_SEMANA,RC_HORAS RD_HORAS,RC_VALOR RD_VALOR,RC_PD RD_PD,RC_TIPO1 RD_TIPO1"
				cQuery += " FROM " + RetSqlName(cAlias) 
				cQuery += " WHERE "
				cQuery += " RC_FILIAL = '" + cFilAnt + "'"
				cQuery += " AND "
				cQuery += " RC_MAT = '" + (cQrySRA)->RA_MAT + "'"
				cQuery += " AND "
				cQuery += " RC_PERIODO IN " + cPeriodos
				cQuery += " AND "
				cQuery += " D_E_L_E_T_ = ' '
			EndIf
		EndIf
		
		If !Empty(cQuery)
			cQuery += " ORDER BY 1, 2, 3, 4, 5, 6"
		EndIf
		cQuery := ChangeQuery(cQuery)
		aStruct := (cAlias)->(dbStruct())
		If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cQrySRD,.T.,.T.)
			cQuery:= ""
			For nAux := 1 To Len(aStruct)
				If ( aStruct[nAux][2] <> "C" )
					TcSetField(cQrySRD,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
				EndIf
			Next nAux
		Endif
	Else
		dbSelectArea(cQrySRD)
		dbSetOrder(5)
	Endif
	If Len(aPerFechado) > 0
		aAdd(aPer,	aClone(aPerFechado))
	EndIf
	If Len(aPerAberto) > 0
		aAdd(aPer,	aClone(aPerAberto))
	EndIf
	nIdade := 0
	For  nCont:=1 to Len(aPer)
		For nAux:= 1 to Len(aPer[nCont]) 
			(cQrySRD)->(dbGoTop())
			If !lQuery
				dbSeek((cQrySRA)->(RA_FILIAL+RA_MAT)+ aPer[nCont][nAux][7])
			Else
				While (cQrySRD)->(!Eof()) .And. !((cQrySRA)->(RA_FILIAL+RA_MAT)+aPer[nCont][nAux][7]== (cQrySRD)->(RD_FILIAL+RD_MAT+RD_PROCES))
			   		(cQrySRD)->(dbSkip())
				End
			Endif
			nIdade:= Calc_Idade( aPer[nCont][len(aPer[nCont])][6] , (cQrySRA)->RA_NASC )
			While (cQrySRD)->(!Eof()) .And.  (cQrySRA)->(RA_FILIAL+RA_MAT)+aPer[nCont][nAux][7]== (cQrySRD)->(RD_FILIAL+RD_MAT+RD_PROCES)
	
			  /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Contribuinte de APF o campo RA_APFOPC=1 e obrigatorio, nao sendo aposentado a opcao 2 tambem se torna   ³
				³obrigatoria, aposentado e <65 anos o valor vai para a coluna 24 sendo >=65 anos vai para a coluna 23    ³
				³caso nao seja aposentado e >=65 anos vai para a coluna 22 sendo <65 vai para a coluna 21                ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				lJubilac := (cQrySRA)->RA_JUBILAC == "1"
				lMaior := nIdade >= 65
				lVerba := (cQrySRD)->RD_PD == aCodFol[731,1]
	
			    If lVerba
					nRDValor := (cQrySRD)->RD_VALOR
					If lJubilac .AND. "1" $ (cQrySRA)->RA_AFPOPC
						If !lMaior
							nVCol23 := (cQrySRD)->RD_VALOR
							lReg	:= .T.
							cTpcotiz := "C"
						Elseif lMaior
							nVCol24 := (cQrySRD)->RD_VALOR
							lReg	:= .T.
							cTpcotiz := "D"
				        EndIF
				    ElseiF !lJubilac .AND. "2" $ (cQrySRA)->RA_AFPOPC
						If !lMaior
							nVCol21 := (cQrySRD)->RD_VALOR
							lReg	 := .T.
							cTpcotiz := "1"
						Elseif lMaior
							nVCol22  := (cQrySRD)->RD_VALOR
							lReg	 := .T.
							cTpcotiz := "8"
						EndIf
					EndIf
				EndIf
	
				If(cQrySRD)->RD_PD == aCodFol[1112,1] .or. (cQrySRD)->RD_PD == aCodFol[1113,1] //armazena a verba de Contribuicao Adicional
						nVCol25 := (cQrySRD)->RD_VALOR
						lReg	:= .T.
				Endif
	
				If(cQrySRD)->RD_PD == aCodFol[0737,1]       // armazena Vivienda
						nVCol26 := (cQrySRD)->RD_VALOR
						lReg	:= .T.
				Endif
				If(cQrySRD)->RD_PD == aCodFol[1227,1] // armazena Fondo Solidario
						nVCol27 := (cQrySRD)->RD_VALOR
						lReg	:= .T.
				Endif
				If(cQrySRD)->RD_PD == aCodFol[1227,1]  .and. (cQrySRA)->RA_TPSEGUR == "M"     // armazena Fondo Solidario MINEROS
						nVCol28 := (cQrySRD)->RD_VALOR
						lReg	:= .T.
				Endif
				If  Month(dAdmissa) == Val(cMes) .OR. Month(dDemissa)== Val(cMes)  .And. Year(dAdmissa) == Val(cAno) .Or. Year(dDemissa) == Val(cAno)
					If (cQrySRD)->RD_PD == aCodFol[0031,1]   //=Tratamento para mensalistas admissao
						nDiasProp := (cQrySRD)->RD_HORAS
					Elseif (cQrySRD)->RD_PD == aCodFol[0032,1] //=Tratamento para horistas admissao
						nDias:= (cQrySRA)->RA_HRSMES / 30
						nDiasProp := (cQrySRD)->RD_HORAS / nDias
					Elseif (cQrySRD)->RD_PD == aCodFol[0048,1] //=Tratamento para mensalistas e horistas na rescisao
						nDiasProp := (cQrySRD)->RD_HORAS
					Elseif (cQrySRD)->RD_PD == aCodFol[0165,1] .OR. (cQrySRA)->RA_CATFUNC == "C"  //=Tratamento para comissionados admissao e rescisao
						If Month(dAdmissa) == Val(cMes)
							nDiasProp := ( f_UltDia(aPer[nCont][nAux][6]) -  Day(dAdmissa) + 1 )
						Else
							nDiasProp := Day( dDemissa )
						Endif
					Endif
				Endif
				//Verifica se a verba esta contida no mnemonico que armazena as verbas de Falta
				If (cQrySRD)->RD_PD $ P_DESCFALT
					If  (cQrySRD)->RD_TIPO1 $ "VD"
						nTotDias :=  (cQrySRD)->RD_HORAS
						nQtdDias := 30 - nTotDias
					Else
						nDias:= (cQrySRA)->RA_HRSMES / 30
						nTotDias := ((cQrySRD)->RD_HORAS / nDias )
						nQtdDias := 30 - nTotDias
					Endif
					If nDiasProp > 0
						nQtdDias := nDiasProp - nTotDias
					Endif
				Endif
				(cQrySRD)->(dbSkip())
			EndDo
		Next nAux
	Next nCont
	(cQrySRD)->(dbCloseArea())

	If lReg
		If lCab
		   	RecLock(cAlsCABTB, .T. )	
			    (cAlsCABTB)	->REG		  	:= (STR0002)
				(cAlsCABTB)	->RA_TIPODOC  	:= (STR0003)
				(cAlsCABTB)	->RA_RG 		:= (STR0002)
				(cAlsCABTB)	->RA_NATURAL	:= (STR0004)
				(cAlsCABTB)	->RA_NRNUA 		:= (STR0005)
				(cAlsCABTB)	->RA_PRISOBR	:= (STR0006)    
				(cAlsCABTB)	->RA_SECSOBR	:= (STR0007)  
				(cAlsCABTB)	->RA_APELIDO 	:= (STR0008) 
				(cAlsCABTB)	->RA_PRINOME	:= (STR0009)
				(cAlsCABTB)	->RA_SECNOME 	:= (STR0010)
				(cAlsCABTB)	->RA_DEPTO 		:= (STR0011)
				(cAlsCABTB)	->NOVEDAD 		:= (STR0012)		
				(cAlsCABTB)	->FECHNOVED  	:= (STR0013)
				(cAlsCABTB)	->QTEDIAS 		:= (STR0014)
				(cAlsCABTB)	->RA_TPSEGUR 	:= (STR0015)		
				(cAlsCABTB)	->TOTLGANADO 	:= (STR0016)		
				(cAlsCABTB)	->TOTLGAMA65 	:= (STR0017) 
				(cAlsCABTB)	->TOTGPENME5	:= (STR0018) 
				(cAlsCABTB)	->TOTGPENMA5	:= (STR0019) 
				(cAlsCABTB)	->COTIADICIO	:= (STR0020) 
				(cAlsCABTB)	->TOTGAFONDV	:= (STR0021) 
				(cAlsCABTB)	->TOTGAFONSL	:= (STR0022)
				(cAlsCABTB)	->TOTGAFSLMI	:= (STR0023)
			(cAlsCABTB)	->(MsUnlock())
			lCab	:= .F. 	
		EndIf
		nFunc+=1
		nCol21Tot +=  IIF((cQrySRA)->RA_AFPOPC == "1234",nRDValor,0)
		nCol22Tot +=  IIF((cQrySRA)->RA_AFPOPC == "12*4",nRDValor,0)
		nCol23Tot +=  IIF((cQrySRA)->RA_AFPOPC == "1*34",nRDValor,0)
		nCol24Tot +=  IIF((cQrySRA)->RA_AFPOPC == "1**4",nRDValor,0)
		nCol25Tot +=  nVCol25
		nCol26Tot +=  nVCol26
		nCol27Tot +=  nVCol27
		nCol28Tot +=  nVCol28

		cTipoCI := If( Empty((cQrySRA)->RA_TIPODOC) .Or. (cQrySRA)->RA_TIPODOC=="1", "CI", "PAS" )
		cNumNua := (cQrySRA)->RA_NRNUA
		cFechNoved	:= ""
		cNOVEDAD	:= "" 
		//Funcionarios admitidos no Mes/Ano de referencia
		If Month(dAdmissa) == Val(cMes) .And. Year(dAdmissa) == Val(cAno)
			cNOVEDAD := "I"
		   	cFechNoved:= DtoC(dAdmissa)
			nQtdDias := nDiasProp
		//Funcionarios demitidos no Mes/Ano de referencia
		Elseif Month(dDemissa)== Val(cMes) .And.  Year(dDemissa) == Val(cAno)
			cNOVEDAD:= "R"
			cFechNoved:= DtoC(dDemissa)
			nQtdDias := nDiasProp
		Else
			fBuscaAutr(cFil, cMat , CtoD("01/"+cMes+"/"+cAno), LastDate(CtoD("01/"+cMes+"/"+cAno)))
		Endif	
	
	    dbSelectArea(cAliasTMP)	
	    
	    RecLock(cAliasTMP, .T. )	
	    (cAliasTMP)	->REG		  	:= cValToChar(nReg)
		(cAliasTMP)	->RA_TIPODOC  	:= cTipoCI
		(cAliasTMP)	->RA_RG 		:= (cQrySRA)->RA_RG
		(cAliasTMP)	->RA_NATURAL	:= (cQrySRA)->RA_NATURAL
		(cAliasTMP)	->RA_NRNUA 		:= cNumNua
		(cAliasTMP)	->RA_PRISOBR	:= SubStr((cQrySRA)->RA_PRISOBR,1,10)    
		(cAliasTMP)	->RA_SECSOBR	:= SubStr((cQrySRA)->RA_SECSOBR,1,10)  
		(cAliasTMP)	->RA_APELIDO 	:= SubStr((cQrySRA)->RA_APELIDO,1,10)
		(cAliasTMP)	->RA_PRINOME	:= SubStr((cQrySRA)->RA_PRINOME,1,10) 
		(cAliasTMP)	->RA_SECNOME 	:= SubStr((cQrySRA)->RA_SECNOME,1,10) 
		(cAliasTMP)	->RA_DEPTO 		:= fGetDepto((cQrySRA)->RA_FILIAL)
		(cAliasTMP)	->NOVEDAD 		:= cNOVEDAD		
		(cAliasTMP)	->FECHNOVED  	:= cFechNoved
		(cAliasTMP)	->QTEDIAS 		:= cValToChar(nQtdDias)
		(cAliasTMP)	->RA_TPSEGUR 	:= (cQrySRA)->RA_TPSEGUR		
		(cAliasTMP)	->TOTLGANADO 	:= IIF((cQrySRA)->RA_AFPOPC == "1234",nRDValor,0)		
		(cAliasTMP)	->TOTLGAMA65 	:= IIF((cQrySRA)->RA_AFPOPC == "12*4",nRDValor,0)
		(cAliasTMP)	->TOTGPENME5	:= IIF((cQrySRA)->RA_AFPOPC == "1*34",nRDValor,0)
		(cAliasTMP)	->TOTGPENMA5	:= IIF((cQrySRA)->RA_AFPOPC == "1**4",nRDValor,0)
		(cAliasTMP)	->COTIADICIO	:= nVCol25
		(cAliasTMP)	->TOTGAFONDV	:= nVCol26 
		(cAliasTMP)	->TOTGAFONSL	:= nVCol27
		(cAliasTMP)	->TOTGAFSLMI	:= nVCol28
		
		
		(cAliasTMP)	->(MsUnlock()) 	
		
		lReg:= .F.
	Endif
	(cQrySRA)->(dbSkip())
	nReg++
End

If !lQuery
	dbSelectArea("SRA")
	dbSetOrder(nSavOrdem)
	dbGoTo(nSavRec)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna o alias padrao                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuery	
	If Select(cQrySRA) > 0
		(cQrySRA)->(dbCloseArea())
	Endif
EndIf
nReg := 0
Return 

/*/{Protheus.doc} fBuscaAutr
//TODO Descrição auto-gerada.
@author Ana
@since 08/10/2019
@version undefined
@return return, return_description
@param cFil, characters, descricao
@param cMat, characters, descricao
@param dDtaini, date, descricao
@param dDtafim, date, descricao
/*/
Static Function fBuscaAutr(cFil, cMat ,  dDtaini, dDtafim)

Local cAliasAnt  := Alias()
Local cQuery8	:= ""
Local cAliasSr8	 := "SR8"
Local cDtaIni	:= dtos(dDtaini)
Local cDtaFim	:= dtos(dDtafim)

Static cFilRCM

DEFAULT cFilRCM	 := FwxFilial("RCM")

	cAliasSr8 	:= "QrySR8"
	cQuery8 	:= "SELECT * "
	cQuery8 	+= "FROM "+RetSqlName("SR8")+" SR8 "
	cQuery8 	+= "WHERE SR8.R8_FILIAL='"+cMat+"' AND "
	cQuery8 	+= "SR8.R8_MAT='"+cMat+"' AND "
	cQuery8 	+= "SR8.R8_DATAINI >='" + cDtaIni + "' AND SR8.R8_DATAFIM <='" + cDtaFim + "' "
	cQuery8 	+= "AND SR8.D_E_L_E_T_ = ' ' "
	cQuery8 	+= "ORDER BY "+SqlOrder(SR8->(IndexKey()))

	If Select(cAliasSr8) > 0
		(cAliasSr8)->( dbCloseArea() )
	Endif
	
	
	cQuery8 		:= ChangeQuery(cQuery8)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery8),cAliasSr8)

	dbSelectArea(cAliasSr8)
	(cAliasSr8)->(dbgotop())

	dbSelectArea( "SR8" )
	dbSeek( cFil + cMat)


	While (!Eof() .And. (cAliasSr8)->( R8_FILIAL + R8_MAT ) == (cFil + cMat))

        DbSelectArea( "RCM" )
        DbSetOrder( RetOrder( "RCM", "RCM_FILIAL+RCM_TIPO" ) )
        DbSeek( cFilRCM + (cAliasSr8)->R8_TIPOAFA, .F. )

        If RCM->RCM_TPIMSS $ "C/A/P"
		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  | La clave para hacer la busca en las ausencias es el campo R8_DTBLEG, el importante es la  |
		  | fecha en el mes selecionado. Ej: caso tenga una ausencia con fecha inicio y fecha fin     |
		  | dentro del mes 02, pero la fecha de autori. es en mes 03, esa ausencia debera salir en el |
		  | 03.																						  ³
		  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
    		If (cAliasSr8)->R8_DTBLEG >= Dtos(dDtaini) .And. (cAliasSr8)->R8_DTBLEG <= Dtos(dDtaFim)
	           	// Qdo la Ausencia esta com fecha anterior al mes buscado informa el primero dia del mes
	           	If (cAliasSr8)->R8_DATAINI < DtoS(dDtaini)
				 	cFechNoved:= DtoC(dDtaini)
				 	nQtdDias    := 30
		           	cNOVEDAD	:="S"
		 		Else
		 			cFechNoved  := DtoC(dDtaini)
					nQtdDias    := 30 - (day(dDtaini))
		           	cNOVEDAD	:="S"					
				Endif
	        Endif
	    Else//verifica se posui Ausencia No Remunerada durante todo el periodo pesquisado
    	   	If RCM->RCM_TPIMSS == "L"
        			If (cAliasSr8)->R8_DATAFIM >= DtoS(dDtafim) .And. (cAliasSr8)->R8_DATAINI <= DtoS(dDtaini)
        				cNOVEDAD	:="L"
					 	cFechNoved  := DtoC(dDtaini)
					 	nQtdDias	:= (cAliasSr8)->R8_DURACAO
					EndIf
         	EndIf
	    Endif

	dbSelectArea(cAliasSr8)
	dbSkip()

Enddo

If Select(cAliasSr8) > 0
 	(cAliasSr8)->( dbCloseArea() )
Endif


If !EMPTY(cAliasAnt)
	dbSelectArea(cAliasAnt)
EndIf

Return()
/*/{Protheus.doc} fCriaTmp
//Cria a estrutura dos arquivos temporários.
@author edvf8
@since 08/10/2019
@version undefined
@param cAlias, characters, descricao
@param aCampos, array, descricao
@param cAlsCab, characters, descricao
@return return, return_description
/*/
Static Function fCriaTmp(cAlias, aCampos,cAlsCab)

If Select(cAlias) > 0
	If oTmpTable <> Nil   
		oTmpTable:Delete()		
		oTmpTable := Nil 
	EndIf 
EndIf 

//Array com as informações da tabela temporária para o cabeçalho do arquivo;
aadd(aCposCab,{"REG"			,'C'	,05,0}) 
aadd(aCposCab,{"RA_TIPODOC"		,'C'	,10	,0}) 
aadd(aCposCab,{"RA_RG"			,'C'	,15	,0}) 
aadd(aCposCab,{"RA_NATURAL"		,'C'	,25	,0}) 	
aadd(aCposCab,{"RA_NRNUA"		,'C'	,12	,0})
aadd(aCposCab,{"RA_PRISOBR"		,'C'	,100	,0})    
aadd(aCposCab,{"RA_SECSOBR"		,'C'	,100	,0})  
aadd(aCposCab,{"RA_APELIDO"		,'C'	,100	,0})
aadd(aCposCab,{"RA_PRINOME"		,'C'	,100	,0}) 
aadd(aCposCab,{"RA_SECNOME"		,'C'	,100	,0}) 
aadd(aCposCab,{"RA_DEPTO"		,'C'	,100	,0}) 
aadd(aCposCab,{"NOVEDAD"		,'C'	,100	,0}) 
aadd(aCposCab,{"FECHNOVED"		,'C'	,100	,0})
aadd(aCposCab,{"QTEDIAS"		,'C'	,100	,0}) 
aadd(aCposCab,{"RA_TPSEGUR"		,'C'	,100	,0})
aadd(aCposCab,{"TOTLGANADO"		,'C'	,100	,2})
aadd(aCposCab,{"TOTLGAMA65"		,'C'	,100	,2}) 
aadd(aCposCab,{"TOTGPENME5"		,'C'	,100	,2})
aadd(aCposCab,{"TOTGPENMA5"		,'C'	,100	,2})
aadd(aCposCab,{"COTIADICIO"		,'C'	,100	,2})
aadd(aCposCab,{"TOTGAFONDV"		,'C'	,100	,2})
aadd(aCposCab,{"TOTGAFONSL"		,'C'	,100	,2})
aadd(aCposCab,{"TOTGAFSLMI"		,'C'	,100	,2})

//Array com campo da tabela temporária
aadd(aCampos,{"REG"				,'C'	,03	,0}) 
aadd(aCampos,{"RA_TIPODOC"		,'C'	,03	,0}) 
aadd(aCampos,{"RA_RG"			,'C'	,15	,0}) 
aadd(aCampos,{"RA_NATURAL"		,'C'	,02	,0}) 	
aadd(aCampos,{"RA_NRNUA"		,'C'	,12	,0})
aadd(aCampos,{"RA_PRISOBR"		,'C'	,35	,0})    
aadd(aCampos,{"RA_SECSOBR"		,'C'	,35	,0})  
aadd(aCampos,{"RA_APELIDO"		,'C'	,15	,0})
aadd(aCampos,{"RA_PRINOME"		,'C'	,35	,0}) 
aadd(aCampos,{"RA_SECNOME"		,'C'	,35	,0}) 
aadd(aCampos,{"RA_DEPTO"		,'C'	,30	,0}) 
aadd(aCampos,{"NOVEDAD"			,'C'	,01	,0}) 
aadd(aCampos,{"FECHNOVED"		,'C'	,10	,0})
aadd(aCampos,{"QTEDIAS"		    ,'C'	,30	,0}) 
aadd(aCampos,{"RA_TPSEGUR"		,'C'	,25	,0})
aadd(aCampos,{"TOTLGANADO"		,'N'	,125	,2})
aadd(aCampos,{"TOTLGAMA65"		,'N'	,125	,2}) 
aadd(aCampos,{"TOTGPENME5"		,'N'	,125	,2})
aadd(aCampos,{"TOTGPENMA5"		,'N'	,125	,2})
aadd(aCampos,{"COTIADICIO"		,'N'	,125	,2})
aadd(aCampos,{"TOTGAFONDV"		,'N'	,125	,2})
aadd(aCampos,{"TOTGAFONSL"		,'N'	,125	,2})
aadd(aCampos,{"TOTGAFSLMI"		,'N'	,125	,2})

oTmpCab := FWTemporaryTable():New(cAlsCab)
oTmpCab:SetFields( aCposCab ) 
oTmpCab:Create() 

oTmpTable := FWTemporaryTable():New(cAlias)
oTmpTable:SetFields( aCampos ) 
oTmpTable:Create() 

Return oTmpTable

/*/{Protheus.doc} fGetDepto
//Faz a busca do departamento do funcionário
@author edvf8
@since 08/10/2019
@version undefined
@param cFilFunc, characters, Filial do Funcionário
@return cDdepto, String, Descrição do Departamento do funcionário, na bolívia é a localização da empresa em si.
/*/
Static Function fGetDepto(cFilFunc)

Local aArea	 	:= SM0->(GetArea())
Local cGrpEmp	:= FwGrpCompany()
Local nx     	:= 0
Local ny		:= 0
Local cFilF		:= ""
Local cDdepto	:= ""
If	Empty(xFilial("SQB")) // se SQB Compartilhado CCC, filtro fica sendo branco a ZZZ
	ny := Ascan(aEmpCor,{|x| x[1] == cGrpEmp })
	cFilF := aEmpCor[ny][2]
Else
	ny := Ascan(aEmpCor,{|x| x[1] == cGrpEmp})
	While ny <= Len(aEmpCor) .AND. aEmpCor[ny][1] == cGrpEmp
		If (RTrim(cFilFunc) == RTrim(aEmpCor[ny][3]))  .OR. (RTrim(cFilFunc) == RTrim(aEmpCor[ny][3]+aEmpCor[ny][4])) ;
			.OR. (cFilFunc == aEmpCor[ny][2])
			cFilF := aEmpCor[ny][2]
			Exit
		EndIf
		ny++ 
	EndDo
EndIf

SM0->(dbGotop())
If  SM0->(DbSeek(cGrpEmp+cFilF))
	cDdepto	:= SM0->M0_COMPENT
EndIf
RestArea(aArea)

Return cDdepto