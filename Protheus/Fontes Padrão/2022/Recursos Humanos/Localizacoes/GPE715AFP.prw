#Include "PROTHEUS.CH"
#INCLUDE "GPER715.CH"


/*/{Protheus.doc} GPE715AFP
//Geração de CSV com base no arquivo magnético de Aportes Fondo Solidario
@author eduardo.vicente
@since 16/10/2019
@version undefined
@return return, return_description
@history Criação de Fonte baseado no fonte GPER715, para a extração dos dados em CSV com base no arquivo magnético.
/*/
Function GPE715AFP()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Locais (Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cDesc1 		:= STR0024		//"Planilla de Aportes AFP´s"
Local cDesc2 		:= STR0002		//"Se imprimira de acuerdo con los parametros solicitados por el usuario."
Local cDesc3 		:= STR0003		//"Obs.: Debe imprimirse un Formulario Mensual para cada Filial."
Local aOrd      	:= {STR0004,STR0005,STR0006}		//"Sucursal + Matricula"###"Sucursal + C. Costo"###"Sucural + Nombre"
Local lEnd			:= .T.

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Define Variaveis Private(Basicas)                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Private nomeprog	:= "GPER715"
Private aReturn 	:={ , 1,, 2, 2, 1,"",1 }
Private nLastKey 	:= 0
Private cPerg   	:= "GPR715"
Private aInfo 		:= {}

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
Private aCampos	  	:={}
Private	aCposCab	:= {}
Private cAlsCABTB 	:= "aliasCAB"    
Private cAliasTMP 	:= "aliasAFP"  
Private oTmpTable,oTmpCab  

Pergunte(cPerg,.T.)		

//Checa se o campo RA_NRNUA existe no dicionario de dados
If !fValDic()
	Return()
EndIf

oTmpTable := fCriaTmp()
dbSelectArea(cAlsCABTB)
dbSelectArea(cAliasTMP)

If nLastKey = 27
	Return
Endif


/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis utilizadas para parametros                         ³
³ mv_par01        //  Tipo de Relatorio(AFP Prevision ou Futuro³
³ mv_par02        //  Filial De						           ³
³ mv_par03        //  Filial Ate					           ³
³ mv_par04        //  Mes/Ano Competencia Inicial?             |
³ mv_par05        //  Matricula De                             ³
³ mv_par06        //  Matricula Ate                            ³
³ mv_par07        //  Centro de Custo De                       ³
³ mv_par08        //  Centro de Custo Ate                      ³
³ mv_par09        //  Nome De                                  ³
³ mv_par10        //  Nome Ate                                 ³
³ mv_par11        //  Situações a imp?                         ³
³ mv_par12        //  Categorias a imp?                        ³
³ mv_par13        //  Processos ?              				   ³
³ mv_par14        //  Roteiro ?                          	   ³
³ mv_par15        //  Data de Pagamento ?                      ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nOrdem   := aReturn[8]

nTipo 		:= mv_par01
cFilialDe 	:= mv_par02
cFilialAte  := mv_par03
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
cAnoMes		:= cAno+cMes
cProcessos	:= If( Empty(mv_par13),"", ConvQry(alltrim(mv_par13),"RA_PROCES"))
cProcedi	:= If( Empty(mv_par14),"'FOL'", ConvQry(AllTrim(mv_par14),"RD_ROTEIR"))
cFechaPgt	:= If( Empty(mv_par15),"", substr(dtos(mv_par15),7,2)+"/"+substr(dtos(mv_par15),5,2)+"/"+substr(dtos(mv_par15),1,4))


IMPFUT(@lEnd)

	

Return cAliasTMP


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPFUT    ºAutor  ³Erika Kanamori      º Data ³  03/19/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/{Protheus.doc} IMPFUT
//Rotina de impressão dos dados no relatório
@since 16/10/2019
/*/
Static Function IMPFUT(lEnd )

Local cInicio		:= ""
Local cFim 			:= ""
Local aPerAberto 	:= {}
Local aPerFechado	:= {}
Local aPerTodos		:= {}
Local aCodFol		:= {}
Local cFilAnt 		:= ""
Local cFilAux
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis para controle em ambientes TOP.                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cQuery
Local aStruct  	:= {}
Local lQuery  	:= .F.
Local cQryOrd 	:= ""
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
Local cProcS  	:= ""
Local cProcD  	:= ""

Local cQuerySra := ""
Local cSitQuery	:= ""
Local cCatQuery	:= ""

Local aAfast    := {}

Local dDtaini   := ctod("//")
Local dDtafim   := ctod("//")

Local cMnProces	:= ""
Local cMxProces	:= "ZZZZZ"
Local lCab		:= .T.
//-- Logico
Local lAllProCs		:= .F.

Local  	cAlias   := "SRA"
Private cAliasSra:= ""


//variaveis para impressão
Private nFunc 		:= 0
Private cIRLS 		:= ""
Private cFechNovedad:= ""
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
Private NVDESAP1    := 0
Private NVDESAP2    := 0
Private NVDESAP3    := 0

Private	lReg		:= .F.
Private aSR9    	:= {}  // Centro de Custo

Private nTabS011	:= 0
Private nVPriPor	:= 0
Private nVPriVal	:= 0
Private nVPriCon	:= 0

Private nVSegPor	:= 0
Private nVSegVal	:= 0
Private nVSegCon	:= 0

Private nVTerPor	:= 0
Private	nVTerVal	:= 0
Private nVTerCon	:= 0

Private nTabS007	:= 0
Private cACTIVI		:= ""
Private cCORREO		:= ""
Private cREPLEG		:= ""
Private cIDREPLEG	:= ""
Private cDOCREPLEG	:= ""
Private cCASILLA	:= ""

Private cTime		:= Time()
Private nPag		:= 0

//Inicializa o mnemonico que ira armazenar as verbas de faltas a serem consideradas no tratamento.
SetMnemonicos(NIL,NIL,.T.,"P_DESCFALT")


If nOrdem == 1
	cQueryOrd := "RA_FILIAL, RA_MAT"
	dbSetOrder(1)
	SRA->( dbSeek( cFilialDe + cMatDe, .T. ) )
	cInicio   := "(cAliasSra)->RA_FILIAL + (cAliasSra)->RA_MAT"
	cFim      := cFilialAte + cMatAte
Else
	If nOrdem == 2
		cQueryOrd := "RA_FILIAL, RA_CC, RA_MAT"
		dbSetOrder(2)
		SRA->( dbSeek( cFilialDe + cCustoDe + cMatDe, .T. ) )
		cInicio   := "(cAliasSra)->RA_FILIAL + (cAliasSra)->RA_CC + (cAliasSra)->RA_MAT"
		cFim      := cFilialAte + cCustoAte + cMatAte

	Elseif nOrdem == 3
		cQueryOrd := "RA_FILIAL + RA_NOME + RA_MAT"
		dbSetOrder(3)
		SRA->( dbSeek( cFilialDe + cNomeDe + cMatDe, .T.) )
		cInicio	  := "(cAliasSra)->RA_FILIAL + (cAliasSra)->RA_NOME + (cAliasSra)->RA_MAT"
		cFim	  := cFilialAte + cNomeAte + cMatAte
	Endif
Endif


// Tabela S001 - Fondo Solidario
nTabS011	:= FPOSTAB("S011",'001',"=",3)                   // linea 1 = 13.000
NVDESAP1 	:= IF(nTabS011>0, FTABELA("S011",nTabS011,6),0)
nVPriPor	:= IF(nTabS011>0, FTABELA("S011",nTabS011,5),0)
nVPriVal	:= IF(nTabS011>0, FTABELA("S011",nTabS011,6),0)
nVPriCon	:= IF(nTabS011>0, FTABELA("S011",nTabS011,7),0)


nTabS011	:= FPOSTAB("S011",'002',"=",3)                   // linea 2 = 25.000
NVDESAP2 	:= IF(nTabS011>0,FTABELA("S011",nTabS011,6),0)
nVSegPor	:= IF(nTabS011>0,FTABELA("S011",nTabS011,5),0)
nVSegVal	:= IF(nTabS011>0,FTABELA("S011",nTabS011,6),0)
nVSegCon	:= IF(nTabS011>0,FTABELA("S011",nTabS011,7),0)


nTabS011	:= FPOSTAB("S011",'003',"=",3)                    // linea 3 = 35.000
NVDESAP3 	:= IF(nTabS011>0,FTABELA("S011",nTabS011,6),0)
nVTerPor	:= IF(nTabS011>0,FTABELA("S011",nTabS011,5), 0)
nVTerVal	:= IF(nTabS011>0,FTABELA("S011",nTabS011,6), 0)
nVTerCon	:= IF(nTabS011>0,FTABELA("S011",nTabS011,7), 0)


// Tabela S007 - Informaciones Legales
nTabS007 := FPOSTAB("S007",'001',"=",3)

cActivi		:= IF (nTabS007>0, FTABELA("S007",nTabS007,8), "")
cCorreo		:= IF (nTabS007>0, FTABELA("S007",nTabS007,9), "")
cRepleg		:= IF (nTabS007>0, FTABELA("S007",nTabS007,10),"")
cIdRepleg	:= IF (nTabS007>0, FTABELA("S007",nTabS007,11),"")
cDocRepleg	:= IF (nTabS007>0, FTABELA("S007",nTabS007,13),"")
cCasilla	:= IF (nTabS007>0, FTABELA("S007",nTabS007,14),"")


	//Filtra do SRA: filial, matricula de/ate, centro de custo de/ate, categoria e situacoes, Processos, Roteiros
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Buscar Situacao/Categoria/Proceso/Roteiro em formato para SQL³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	For nAux := 1 to Len(cSit)
		cSitQuery += "'"+Subs(cSit,nAux,1)+"'"
		If ( nAux+1 ) <= Len(cSit)
			cSitQuery += ","
		Endif
	Next nAux

	For nAux := 1 to Len(cCat)
		cCatQuery += "'"+Subs(cCat,nAux,1)+"'"
		If ( nAux+1 ) <= Len(cCat)
			cCatQuery += ","
		Endif
	Next nAux

    // Verifica el Proceso
	lAllProCs 	:= Iif(AllTrim( cProcessos ) == "*" .Or. Empty(cProcessos), .F., .T.)

	// Montagem da query
	cAliasSra 	:= "QrySRA"
	cQuerySra	:= "SELECT * FROM "	+ RetSqlName( "SRA" ) + " SRA1 "
	cQuerySra	+= " Where RA_FILIAL>= '"	+ cFilialDe	+"' "
	cQuerySra	+= "AND   RA_FILIAL	<= '"	+ cFilialAte+"' "
	cQuerySra	+= "AND   RA_MAT	>= '"	+ cMatDe	+"' "
	cQuerySra	+= "AND   RA_MAT	<= '"	+ cMatAte	+"' "
	cQuerySra	+= "AND   RA_CC		>= '"	+ cCustoDe 	+"' "
	cQuerySra	+= "AND   RA_CC		<= '"	+ cCustoAte	+"' "
	cQuerySra	+= "AND   RA_SITFOLH IN ("	+ cSitQuery	+") "
	cQuerySra	+= "AND   RA_CATFUNC IN ("	+ cCatQuery	+") "
	If !(lAllProCs)
		cQuerySra 	+= "AND RA_PROCES BETWEEN '" + cMnProces + "' AND '" + cMxProces + "'"
	Else
		cQuerySra	+= "AND   RA_PROCES  IN ("	+ cProcessos+") "
	Endif
	cQuerySra   += "AND RA_TPAFP = '" + If(nTipo = 1, "1", "2") + "'"
	cQuerySra   += "AND D_E_L_E_T_ <> '*'
	cQuerySra   += " ORDER BY " + cQueryOrd


	IF Select(cAliasSra) > 0
		(cAliasSra)->( dbCloseArea() )
	Endif

	cQuerySra	:= ChangeQuery(cQuerySra)

	If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuerySra),cAliasSra,.T.,.T.)
		For nAux := 1 To Len(aStruct)
			If ( aStruct[nAux][2] <> "C" )
				TcSetField(cQuerySra,aStruct[nAux][1],aStruct[nAux][2],aStruct[nAux][3],aStruct[nAux][4])
			EndIf
		Next nAux                                   '
	Endif

	(cAliasSra)->( dbgotop() )


	While (cAliasSra)->( !EOF()  .And. &cInicio <= cFim )

		cFil	 := (cAliasSra)->RA_FILIAL
		cMat	 := (cAliasSra)->RA_MAT
   		dAdmissa := stod((cAliasSra)->RA_ADMISSA)
   		dDemissa := stod((cAliasSra)->RA_DEMISSA)

		IF (cAliasSra)->RA_SITFOLH == "D"
           	dDtaini := Max( SToD((cAliasSra)->RA_ADMISSA) , CTOD( "01/"+Substr(cAnoMes,5,2) + "/" + Substr(cAnoMes,1,4) ) )
           	dDtafim := SToD( (cAliasSra)->RA_DEMISSA )
        ELSE
          	dDtaini := Max( SToD((cAliasSra)->RA_ADMISSA ), CTOD( "01/"+Substr(cAnoMes,5,2) + '/' + Substr(cAnoMes,1,4) ) )
          	dDtafim := CTOD( Alltrim(STR(f_UltDia(dDtaini))) + '/' +Substr(cAnoMes,5,2) + '/' + Substr(cAnoMes,1,4) )
        Endif

		//zera variaveis para cada funcionario
		nDiasProp	:= 0
		nTotDias	:= 0

		//-- Buscar a maior data caso alterada La data de admision
		cDelet := "%D_E_L_E_T_ = ' '%"
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
					dAdmissa := (aSR9[nAux][4])
  				Endif
				If aSR9[nAux][3] == "RA_DEMISSA"
					dDemissa := (aSR9[nAux][4])
				Else
					dDemissa := ctod("  /  /    ")
				Endif

           	Endif
   		Next nAux


		//quantidade de dias padrao para todos os funcionarios
		nQtdDias:= 30

		// Busca no acumulado
		cAlias := fBuscaDesc( (cAliasSra)->RA_FILIAL , (cAliasSra)->RA_MAT , cAnoMes , cProcedi )

		If Select(cAlias) > 0
			(cAlias)->( dbgotop() )

			fInfo(@aInfo,(cAliasSra)->RA_FILIAL)				//Carrega array com informacoes da Filial

			nVCol21     := 0
			nVCol22     := 0
			nVCol23     := 0
			nVCol24     := 0

			While (cAlias)->( !eof() )

					IF (cAlias)->PD == FGETCODFOL("1227")  //Base Fondo Solidario

						nVCol21 := (cAlias)->VALOR
						nVCol24 := nVCol21 - NVDESAP1         //  - 13.000
						nVCol23 := nVCol21 - NVDESAP2         //  - 25.000
						nVCol22 := nVCol21 - NVDESAP3         //  - 35.000
						If nVCol24 < 0
							nVCol24 := 0
						Endif
						If nVCol23 < 0
							nVCol23 := 0
						Endif
						If nVCol22 < 0
							nVCol22 := 0
						Endif

						cAnoMes := (cAlias)->PERIODO

						lReg	:= .T.
					Endif

					If  Month(dAdmissa) == Val(cMes) .OR. Month(dDemissa)== Val(cMes)  .And. Year(dAdmissa) == Val(cAno) .Or. Year(dDemissa) == Val(cAno)
						If (cAlias)->PD == FGETCODFOL("0031")   //=Tratamento para mensalistas admissao
							nDiasProp := (cAlias)->HORAS
						Elseif (cAlias)->PD == FGETCODFOL("0032") //=Tratamento para horistas admissao
							nDias:= (cAliasSra)->RA_HRSMES / 30
							nDiasProp := (cAlias)->HORAS / nDias
						Elseif (cAlias)->PD == FGETCODFOL("0048") //=Tratamento para mensalistas e horistas na rescisao
							nDiasProp := (cAlias)->HORAS
						Elseif (cAlias)->PD == FGETCODFOL("0165") .OR. (cAliasSra)->RA_CATFUNC == "C"  //=Tratamento para comissionados admissao e rescisao
							If Month(dAdmissa) == Val(cMes)
								nDiasProp := ( f_UltDia(dAdmissa) -  Day(dAdmissa) + 1 )
							Else
								nDiasProp := Day( dDemissa)
							Endif
						Endif
					Endif

					//Verifica se a verba esta contida no mnemonico que armazena as verbas de Falta
					If (cAlias)->PD $ P_DESCFALT
						If  (cAlias)->TIPO1 $ "VD"
							nTotDias :=  (cAlias)->HORAS
							nQtdDias := 30 - nTotDias
						Else
							nDias:= (cAliasSra)->RA_HRSMES / 30
							nTotDias := ((cAlias)->HORAS / nDias )
							nQtdDias := 30 - nTotDias
						Endif
						If nDiasProp > 0
							nQtdDias := nDiasProp - nTotDias
						Endif
					Endif
			(cAlias)->(dbSkip())
			End
        Endif

        (cAlias)->(dbCloseArea())

    	If nVcol21 < NVDESAP1
	      lReg := .F.
    	Endif

		If lCab
			ImpCabec()
			lCab	:= .F.
		Endif
		If lReg
			nFunc+=1
			nCol21Tot +=  nVCol21
			nCol22Tot +=  nVCol22
			nCol23Tot +=  nVCol23
			nCol24Tot +=  nVCol24
			cIRLS	  := ""

			cTipoCI := If( Empty((cAliasSra)->RA_TIPODOC) .Or. (cAliasSra)->RA_TIPODOC=="1", "CI", "PAS" )
			cNumNua := (cAliasSra)->RA_NRNUA

			/*BEGINDOC
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
			//³Busca las ausencias                                                                                                               ³
			//³Columna 11                                                                                                                        ³
			//³Si RA_ADMISSA está en el mes reportado, colocar "I"                                                                               ³
			//³Si RA_DEMISSA está en el mes reportado, colocar "R"                                                                               ³
			//³Si tiene un ausentismo no remunerado (SR8) que abarque todo el periodo (R8_DTINI y R8_DTFIM) colocar 'L'                          ³
			//³Si tiene un ausentismo (SR8) autorizado de accidente de trabajo, o enfermedad profesional, o enfermedad 							 ³
			//³con (RCM_TPIMSS IN ('CAP')) en el mes (R8_DTBLEG se encuentre en el mes) colocar un "S".                                          ³
			//³				                                                                                                                     ³
			//³Columna 12                                                                                                                        ³
			//³Si tiene novedad "I" colocar RA_ADMISSA                                                                                           ³
			//³Si tiene novedad "R" colocar RA_DEMISSA                                                                                           ³
			//³Si tiene novedad "L" colocar el primer dia del mes                                                                                ³
			//³Si tiene novedad "S" colocar la fecha de inicio de la incapacidad o el primer día del mes en caso de que esta sea anterior al mes.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄe
			ENDDOC*/

			//Retorna os afastamentos para o relatorio
		   	fBuscaAutrz(cFil, cMat , dDtaini, dDtafim, cAnoMes )

		  	//Funcionarios demitidos no Mes/Ano de referencia
	 		If ( Month(dDemissa)== Val(cMes) .And.  Year(dDemissa) == Val(cAno) )
				cIRLS		:= "R"
				cFechNovedad:= DtoC(dDemissa)
				nQtdDias 	:= nDiasProp
			//Funcionarios admitidos no Mes/Ano de referencia
			ElseIf Month(dAdmissa) == Val(cMes) .And. Year(dAdmissa) == Val(cAno)
				cIRLS 		:= "I"
			   	cFechNovedad:= DtoC(dAdmissa)
				nQtdDias 	:= nDiasProp
            // Busca Afastamentos
			ElseIf empty(cIRLS)
			   cIRLS 		:= ""
			   cFechNovedad:= ""
		    Endif

			
			ImpInfFunc()
			lReg:= .F.

		Endif

	(cAliasSra)->(dbSkip())

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Zera Variaveis para a prox. geracao                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nCol21Tot   := 0
	nCol22Tot   := 0
	nCol23Tot   := 0
	nCol24Tot   := 0
	nCol25Tot   := 0
	nFunc		:= 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna o alias padrao                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF SELECT(cAlias) > 0
		(cAlias)->( dbclosearea() )
	Endif

	IF SELECT(cAliasSra) > 0
  		(cAliasSra)->( dbCloseArea() )
 	Endif

Return


/*/{Protheus.doc} ImpCabec
//Preenchimento do cabeçalho com a descrição dos títulos
@author edvf8
@since 16/10/2019
@version undefined
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ImpCabec()

RecLock(cAlsCABTB, .T. )	
	(cAlsCABTB)->REG		:= 	STR0034 //"No"
	(cAlsCABTB)->TIPO		:= 	STR0035 //"TIPO"
	(cAlsCABTB)->NRO		:=	STR0034 //"No"
	(cAlsCABTB)->EXTEN		:=	STR0036 //"EXTENSION"
	(cAlsCABTB)->NUACUA		:=	STR0037 //"NUA/CUA"
	(cAlsCABTB)->APELPAT	:=	STR0038 //"1er. APELLIDO (PATERNO)" 
	(cAlsCABTB)->APELMAT	:= 	STR0039 //"2do. APELLIDO (MATERNO)" 
	(cAlsCABTB)->CASADA		:=  STR0040 //"APELLIDO CASADA"
	(cAlsCABTB)->PRINOMBRE	:= 	STR0041 //"PRIMER NOMBRE"
	(cAlsCABTB)->SEGNOMBRE	:= 	STR0042 //"SEGUNDO NOMBRE"
	(cAlsCABTB)->DEPTO		:= 	STR0043 //"DEPARTAMENTO"
	(cAlsCABTB)->NOVEDAD	:= 	STR0044 //"NOVEDAD  I/R/L/S"
	(cAlsCABTB)->FECHNOVID	:= 	STR0045 //"FECH-NOVEDAD" 
	(cAlsCABTB)->DIASCOTIZ	:= 	STR0046 //"DIAS COTIZADOS" 
	(cAlsCABTB)->TGANDSLMIN	:= 	STR0047 //"TOTAL GANADO SOLIDARIO (SIN CONSIDERAR TOPE DE 60 SALARIOS MÍNIMOS NACIONALES)" 
	(cAlsCABTB)->TOTGDEMO13	:= 	STR0048 //"TOTAL GANADO SOLIDARIO MENOS BS. 13,000 (SI LA DIFERENCIA ES POSITIVA)"
	(cAlsCABTB)->TOTGDEMN25	:=  STR0049 //"TOTAL GANADO SOLIDARIO MENOS BS. 25,000 (SI LA DIFERENCIA ES POSITIVA)"
	(cAlsCABTB)->TOTGDEMO35	:=  STR0050 //"TOTAL GANADO SOLIDARIO MENOS BS. 35,000 (SI LA DIFERENCIA ES POSITIVA)"
(cAlsCABTB)->(msUnlock())

Return



/*/{Protheus.doc} ImpInfFunc
//Rotina de preenchimento do alias temporário.
@since 16/10/2019
@version undefined
@return return, return_description
/*/
Static Function ImpInfFunc()

Local cApelPat	:= SubStr((cAliasSra)->RA_PRISOBR,1,30)
Local cApelMat	:= SubStr((cAliasSra)->RA_SECSOBR,1,30)
Local cApelCas	:= SubStr((cAliasSra)->RA_APELIDO,1,30)
Local cPriNom	:= SubStr((cAliasSra)->RA_PRINOME,1,30)
Local cSegNom	:= SubStr((cAliasSra)->RA_SECNOME,1,30)

RecLock(cAliasTMP, .T. )	
	(cAliasTMP)->REG		:= 	nFunc					//"No"
	(cAliasTMP)->TIPO		:= 	cTipoCI					//"TIPO"
	(cAliasTMP)->NRO		:=	(cAliasSra)->RA_RG		//"NUMERO"
	(cAliasTMP)->EXTEN		:=	(cAliasSra)->RA_NATURAL //"EXT"
	(cAliasTMP)->NUACUA		:=	cNumNua					//"NUA/CUA"
	(cAliasTMP)->APELPAT	:=	cApelPat 				//"1er. APELLIDO (PATERNO)"
	(cAliasTMP)->APELMAT	:= 	cApelMat 				//"2do. APELLIDO (MATERNO)"
	(cAliasTMP)->CASADA		:=  cApelCas				//"APELLIDO CASADA"
	(cAliasTMP)->PRINOMBRE	:= 	cPriNom					//"PRIMER NOMBRE"
	(cAliasTMP)->SEGNOMBRE	:= 	cSegNom					//"SEGUNDO NOMBRE"
	(cAliasTMP)->DEPTO		:= 	SubStr(aInfo[5],1,10)	//"DEPARTAMENTO"
	(cAliasTMP)->NOVEDAD	:= 	cIRLS					//"NOVEDAD  I/R/L/S"
	(cAliasTMP)->FECHNOVID	:= 	cFechNovedad 			//"FECH-NOVEDAD"
	(cAliasTMP)->DIASCOTIZ	:= 	nQtdDias				//"DIAS COTIZADOS"
	(cAliasTMP)->TGANDSLMIN	:= 	nVCol21					//"TOTAL GANADO SOLIDARIO (SIN CONSIDERAR TOPE DE 60 SALARIOS MÍNIMOS NACIONALES)"
	(cAliasTMP)->TOTGDEMO13	:= 	nVCol24					//"TOTAL GANADO SOLIDARIO MENOS BS. 13,000 (SI LA DIFERENCIA ES POSITIVA)"
	(cAliasTMP)->TOTGDEMN25	:=  nVCol23					//"TOTAL GANADO SOLIDARIO MENOS BS. 25,000 (SI LA DIFERENCIA ES POSITIVA)"
	(cAliasTMP)->TOTGDEMO35	:=  nVCol22					//"TOTAL GANADO SOLIDARIO MENOS BS. 35,000 (SI LA DIFERENCIA ES POSITIVA)"

(cAliasTMP)->(MsUnlock())

Return



/*/{Protheus.doc} fValDic
//Validacao de Dicionarios Atualizados por UPDATE  
@since 16/10/2019
@version undefined
@return return, return_description
/*/
Static Function fValDic()

Local lRet	:= .T.

    IF SRA->(ColumnPos("RA_NRNUA")) <= 0
		Aviso(OemToAnsi(STR0031), OemToAnsi(STR0030), {"OK"})	//"Atencao!"##"Antes de prosseguir, é necessário executar a atualização 'Cálculo de Cota Sindical - Portugal', disponível para o módulo SIGAGPE no compatibilizador RHUPDMOD."
    	lRet := .F.
	Else
	    If SR8->(ColumnPos("R8_DTBLEG"))  <= 0  .Or. RCM->(ColumnPos("RCM_TPIMSS"))  <= 0 .or. SR8->(ColumnPos("R8_RESINC")) <= 0
			Aviso(OemToAnsi(STR0031), OemToAnsi(STR0033), {"OK"})	//"Antes de continuar, es necesario ejecutar la actualizacion '229' disponible para el modulo SIGAGPE en el compatibilizador RHUPDMOD."
    		lRet := .F.
    	Endif
	Endif


Return(lRet)

/*/{Protheus.doc} fBuscaDesc
//Função que busca valores do acumulado
@author Tiago Malta 
@since 16/10/2019
@version undefined
@return return, return_description
@param cFil, characters, descricao
@param cMat, characters, descricao
@param cPer, characters, descricao
@param cRot, characters, descricao
/*/
Static Function fBuscaDesc( cFil , cMat ,  cPer , cRot )

Local cQuery	:= ""
Local cAliasSRD := ""

	cAliasSRD 	:= "QrySRD"
	cQuery 		:= "SELECT RD_PERIODO PERIODO, RD_MAT MAT,RD_PD PD, RD_VALOR VALOR, RD_HORAS HORAS"
	cQuery 		+= "FROM "	+ RetSqlName( "SRD" )	+ " SRD1 "
	cQuery 		+= "WHERE RD_FILIAL	= '"	+ cFil	+"' "
	cQuery 		+= "AND   RD_MAT	= '"	+ cMat	+"' "
	cQuery 		+= "AND   RD_PERIODO= '"	+ cPer	+"' "
	cQuery 		+= "AND   RD_ROTEIR	IN ("	+ cRot  +") "
	cQuery 		+= "AND SRD1.D_E_L_E_T_ = ' ' "

	cQuery += " UNION ALL "

	cQuery 		+= "SELECT RC_PERIODO PERIODO, RC_MAT MAT,RC_PD PD, RC_VALOR VALOR, RC_HORAS HORAS"
	cQuery 		+= "FROM "	+ RetSqlName( "SRC" )	+ " SRC1 "
	cQuery 		+= "WHERE RC_FILIAL	= '"	+ cFil	+"' "
	cQuery 		+= "AND   RC_MAT	= '"	+ cMat	+"' "
	cQuery 		+= "AND   RC_PERIODO= '"	+ cPer	+"' "
	cQuery 		+= "AND   RC_ROTEIR	IN ("	+ cRot  +") "
	cQuery 		+= "AND SRC1.D_E_L_E_T_ = ' ' "

	IF Select(cAliasSRD) > 0
		(cAliasSRD)->( dbCloseArea() )
	Endif
	cQuery 		:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRD)

	dbSelectArea(cAliasSRD)
	(cAliasSRD)->(dbgotop())

Return(cAliasSRD)


/*/{Protheus.doc} ConvQry
//Convertir a expreción sql un campo informado con un listbox
@since 16/10/2019
@return return, return_description
@param cLista, characters, descricao
@param cCampo, characters, descricao
/*/
Static Function ConvQry(cLista,cCampo)
Local cTxt:=''
Local nTamReg := TamSX3(cCampo)[1]
Local nCont:=0
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Genera texto para usar  para usar despues en Query             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
cLista:=alltrim(cLista)


For nCont := 1 To Len( cLista ) Step nTamReg
    cTxt+="'"+SubStr( cLista , nCont , nTamReg )+"',"
NEXT
cTxt:=substr(cTxt,1,len(cTxt)-1)
Return ( cTxt )


/*/{Protheus.doc} fBuscaAutrz
// Retorna os afastamentos de acordo com a data de autorizacao
@author eduardo.vicente
@since 16/10/2019
@return return, return_description
@param cFil, characters, descricao
@param cMat, characters, descricao
@param dDtaini, date, descricao
@param dDtafim, date, descricao
@param cAnoMes, characters, descricao

/*/
Static Function fBuscaAutrz(cFil, cMat ,  dDtaini, dDtafim, cAnoMes )

Local cAliasAnt  := Alias()
Local cQuery8	:= ""
Local cAliasSr8	 := "SR8"
Local cDtaIni	:= dtos(dDtaini)
Local cDtaFim	:= dtos(dDtafim)

Static cFilSrm

DEFAULT cFilSrm	 := FwxFilial("RCM")

	cAliasSr8 	:= "QrySR8"
	cQuery8 	:= "SELECT * "
	cQuery8 	+= "FROM "+RetSqlName("SR8")+" SR8 "
	cQuery8 	+= "WHERE SR8.R8_FILIAL='"+(cAliasSra)->RA_FILIAL+"' AND "
	cQuery8 	+= "SR8.R8_MAT='"+(cAliasSra)->RA_MAT+"' AND "
//	cQuery8 	+= "SR8.R8_DTBLEG BETWEEN '" + cDtaIni + "' AND '" + cDtaFim + "'"
	cQuery8 	+= " SR8.D_E_L_E_T_ = ' ' "
	cQuery8 	+= "ORDER BY "+SqlOrder(SR8->(IndexKey()))

	If Select(cAliasSr8) > 0
		(cAliasSr8)->( dbCloseArea() )
	Endif

	cQuery8 		:= ChangeQuery(cQuery8)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery8),cAliasSr8)



	dbSelectArea(cAliasSr8)
	(cAliasSr8)->(dbgotop())

	dbSelectArea( "SR8" )
	dbSeek( (cAliasSra)->RA_FILIAL + (cAliasSra)->RA_MAT)


	While !Eof() .And. (cAliasSr8)->( R8_FILIAL + R8_MAT ) = (cAliasSra)->( RA_FILIAL + RA_MAT )

        DbSelectArea( "RCM" )
        DbSetOrder( RetOrder( "RCM", "RCM_FILIAL+RCM_TIPO" ) )
        DbSeek( cFilSrm + (cAliasSr8)->R8_TIPOAFA, .F. )

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
				 	cFechNovedad:= DtoC(dDtaini)
				 	nQtdDias    := 30
		           	cIRLS		:= "S"
		 		Else
		 			cFechNovedad:= DtoC(dDtaini)
					nQtdDias    := 30 - (day(dDtaini))
		           	cIRLS		:="S"
				Endif
	        Endif
	    Else//verifica se posui Ausencia No Remunerada durante todo el periodo pesquisado
	    	   	If RCM->RCM_TPIMSS == "L"
	        			If (cAliasSr8)->R8_DATAFIM >= DtoS(dDtafim) .And. (cAliasSr8)->R8_DATAINI <= DtoS(dDtaini)
	        				cIRLS		:="L"
						 	cFechNovedad:= DtoC(dDtaini)
						 	nQtdDias	:= ""
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
@author eduardo.vicente
@since 08/10/2019
@version undefined
@param cAlias, characters, descricao
@param aCampos, array, descricao
@param cAlsCab, characters, descricao
@return return, return_description
/*/
Static Function fCriaTmp()

If Select(cAliasTMP) > 0
	If oTmpTable <> Nil   
		oTmpTable:Delete()		
		oTmpTable := Nil 
	EndIf 
	If oTmpCab <> Nil   
		oTmpCab:Delete()		
		oTmpCab := Nil 
	EndIf 
EndIf 

aadd(aCposCab,{"REG"			,'C'	,03,0})//"No"
aadd(aCposCab,{"TIPO"          	,'C'	,05,0})//"TIPO"
aadd(aCposCab,{"NRO"           	,'C'	,10,0})//"NUMERO"
aadd(aCposCab,{"EXTEN"     		,'C'	,03,0})//"EXT"
aadd(aCposCab,{"NUACUA"        	,'C'	,10,0})//"NUA/CUA"
aadd(aCposCab,{"APELPAT"   		,'C'	,30,0})//"1er. APELLIDO (PATERNO)" 
aadd(aCposCab,{"APELMAT"   		,'C'	,30,0})//"2do. APELLIDO (MATERNO)" 
aadd(aCposCab,{"CASADA"        	,'C'	,30,0})//"APELLIDO CASADA"
aadd(aCposCab,{"PRINOMBRE"  	,'C'	,30,0})//"PRIMER NOMBRE"
aadd(aCposCab,{"SEGNOMBRE" 		,'C'	,30,0})//"SEGUNDO NOMBRE"
aadd(aCposCab,{"DEPTO"  		,'C'	,30,0})//"DEPARTAMENTO"
aadd(aCposCab,{"NOVEDAD"       	,'C'	,20,0})//"NOVEDAD  I/R/L/S"
aadd(aCposCab,{"FECHNOVID"		,'C'	,15,0})//"FECH-NOVEDAD"
aadd(aCposCab,{"DIASCOTIZ"     	,'C'	,16,0})//"DIAS COTIZADOS"
aadd(aCposCab,{"TGANDSLMIN"   	,'C'	,90,0})//"TOTAL GANADO SOLIDARIO (SIN CONSIDERAR TOPE DE 60 SALARIOS MÍNIMOS NACIONALES)"
aadd(aCposCab,{"TOTGDEMO13"   	,'C'	,90,0})//"TOTAL GANADO SOLIDARIO MENOS BS. 13,000 (SI LA DIFERENCIA ES POSITIVA)"
aadd(aCposCab,{"TOTGDEMN25"   	,'C'	,90,0})//"TOTAL GANADO SOLIDARIO MENOS BS. 25,000 (SI LA DIFERENCIA ES POSITIVA)"
aadd(aCposCab,{"TOTGDEMO35"   	,'C'	,90,0})//"TOTAL GANADO SOLIDARIO MENOS BS. 35,000 (SI LA DIFERENCIA ES POSITIVA)"


aadd(aCampos,	{"REG"			 ,'N'	,03,0})//"No"
aadd(aCampos,	{"TIPO"          ,'C'	,03,0})//"TIPO"
aadd(aCampos,	{"NRO"           ,'C'	,10,0})//"NUMERO"
aadd(aCampos,	{"EXTEN"     	 ,'C'	,03,0})//"EXT"
aadd(aCampos,	{"NUACUA"        ,'C'	,10,0})//"NUA/CUA"
aadd(aCampos,	{"APELPAT"   	 ,'C'	,30,0})//"1er. APELLIDO (PATERNO)" 
aadd(aCampos,	{"APELMAT"   	 ,'C'	,30,0})//"2do. APELLIDO (MATERNO)" 
aadd(aCampos,	{"CASADA"        ,'C'	,30,0})//"APELLIDO CASADA"
aadd(aCampos,	{"PRINOMBRE"     ,'C'	,30,0})//"PRIMER NOMBRE"
aadd(aCampos,	{"SEGNOMBRE"     ,'C'	,30,0})//"SEGUNDO NOMBRE"
aadd(aCampos,	{"DEPTO"  		 ,'C'	,30,0})//"DEPARTAMENTO"
aadd(aCampos,	{"NOVEDAD"       ,'C'	,16 ,0})//"NOVEDAD  I/R/L/S"
aadd(aCampos,	{"FECHNOVID"   	,'C'	,10,0})//"FECH-NOVEDAD"
aadd(aCampos,	{"DIASCOTIZ"     ,'N'	,03,0})//"DIAS COTIZADOS"
aadd(aCampos,	{"TGANDSLMIN"   ,'N'	,12,2})//"TOTAL GANADO SOLIDARIO (SIN CONSIDERAR TOPE DE 60 SALARIOS MÍNIMOS NACIONALES)"
aadd(aCampos,	{"TOTGDEMO13"   ,'N'	,12,2})//"TOTAL GANADO SOLIDARIO MENOS BS. 13,000 (SI LA DIFERENCIA ES POSITIVA)"
aadd(aCampos,	{"TOTGDEMN25"   ,'N'	,12,2})//"TOTAL GANADO SOLIDARIO MENOS BS. 25,000 (SI LA DIFERENCIA ES POSITIVA)"
aadd(aCampos,	{"TOTGDEMO35"   ,'N'	,12,2})//"TOTAL GANADO SOLIDARIO MENOS BS. 35,000 (SI LA DIFERENCIA ES POSITIVA)"

oTmpCab := FWTemporaryTable():New(cAlsCABTB)
oTmpCab:SetFields( aCposCab ) 
oTmpCab:AddIndex( cAlsCABTB, {"REG","TIPO","NRO"} )
oTmpCab:Create() 

oTmpTable := FWTemporaryTable():New(cAliasTMP)
oTmpTable:SetFields( aCampos ) 
oTmpTable:AddIndex( cAliasTMP, {"REG","TIPO","NRO"} )
oTmpTable:Create() 

Return oTmpTable
