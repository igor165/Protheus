#Include "Protheus.ch"
#Include "RwMake.ch" 
#Include "TopConn.ch"
#Include "TECA353.ch"

#DEFINE INSALUBRIDADE 1
#DEFINE PERICULOSIDADE 2

#DEFINE NENHUM ""
#DEFINE MINIMO "2"
#DEFINE MEDIO "3"
#DEFINE MAXIMO "4"

#DEFINE INTEGRAL "2"
#DEFINE PROPORCIONAL "3"

#DEFINE ID_PERICULOSIDADE 		36
#DEFINE ID_INSALUBRIDADE_MAXIMA	39
#DEFINE ID_INSALUBRIDADE_MEDIA	38
#DEFINE ID_INSALUBRIDADE_MINIMA	37

#DEFINE ADICIONAIS_ADICIONAL	1
#DEFINE ADICIONAIS_TIPO			2
#DEFINE ADICIONAIS_GRAU			3
#DEFINE ADICIONAIS_HORAS		4
#DEFINE ADICIONAIS_AB9			5
#DEFINE ADICIONAIS_PREV			5

Static aCacheCFol := {}
Static a353HrRs := {}
/*------------------------------------------------------------------------------
{Protheus.doc} TECA353

@sample 	 TECA353() 
@since		 25/05/2015       
@version	 P12    
@description Envio de adicionais de periculosidade e insalubridade 
------------------------------------------------------------------------------*/

Function TECA353(lSemTela, aParams, aEmployees)
 
	Local lPerg := .F.
	Local cTpExp := SuperGetMV("MV_GSOUT", .F., "1") //1 - Integração RH protheus(Default) - 2 Ponto de Entrada - 3 Arquivo CSV
	Local lJob := .F.
	Local aRet := {.T.,{}}
	local cPerg    := "TECA353B"
	Local cParam  := 'MV_PAR01'
	Default lSemTela := IsBlind()
	Default aParams := {}
	Default aEmployees := {}
	
	lJob := lSemTela

	If !TecHasPerg(cParam,cPerg)  
		cPerg   := "TECA353"	
	Endif

	If !lJob
		lPerg := Pergunte(cPerg,.T.)
	Else
		lPerg := Pergunte(cPerg,.F.)
		If !EMPTY(aParams)
			MV_PAR01 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR01"})][2]
			MV_PAR02 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR02"})][2]
			MV_PAR03 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR03"})][2]
			MV_PAR04 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR04"})][2]
			MV_PAR05 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR05"})][2]
			MV_PAR06 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR06"})][2]
			MV_PAR07 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR07"})][2]
		EndIf
	EndIf
	
	If lPerg
		
		If  "2" $ cTpExp .and. !ExistBlock("At353EvRH")
			If !lJob
				Help(,, "At353EvRH",STR0025 ,, 1, 0)//"Ponto de Entrada At910CMa nao compilado."
			EndIf
			cTpExp := StrTran(cTpExp, "2", )
			AADD(aRet[2], STR0025)
		EndIf
		
		If "2" $ cTpExp
			ExecBlock("At353EvRH", .F., .F., {MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07})
		EndIf

		If "1" $ cTpExp
 			If !lJob
				MsgRun( STR0017,, {|| At353Gera(lJob,@aRet,aEmployees) })//"Processando..."
			Else
				At353Gera(lJob,@aRet,aEmployees)
			EndIf
		EndIf
	EndIf
Return aRet
/*------------------------------------------------------------------------------
{Protheus.doc} At353Gera
	
@since       25/05/2015
@version     12
@param             
@return           
@description Efetiva a inclusão ou exclusão de lançamentos de adicionais de 
             periculosidade e insalubridade no SIGAGPE via GPEA580
------------------------------------------------------------------------------*/
Function At353Gera(lJob,aRet,aEmployees)

	Local aAdicionais 	:= {}	
	Local nPos 			:= 0
	Local cFilFunOld 	:= ""
	Local cMatFunOld 	:= ""
	Local lErro 		:= .F.
	Local nTotReg 		:= 0
	Local cAliasA 		:= GetNextAlias()
	Local cQuery 		:= ""
	Local nX			:= 0
	Local lGerOS		:= SuperGetMV("MV_GSGEROS",.F.,"1") == "1"
	Local lProcNew		:= !lGerOS .And. ABB->( ColumnPos('ABB_ADIENV') ) > 0 //.T. Não usa O.S - .F. Usa O.S
	Local nDiasSit 		:= 0 
	Local lPeriInt 		:= .F.
	Local lInsaInt 		:= .F.
	Local lMVPar08 		:= .F.
	Local dFimMes  		:= CtoD("")

	Default lJob 		:= .F.
	Default aRet 		:= {.T.,{}}
	Default aEmployees 	:= {}

	If TecHasPerg("MV_PAR08", "TECA353") .And. MV_PAR08 == 2
		lMVPar08 := .T.
	EndIf	
	
	If lMVPar08
		MV_PAR05 := CTOD("01/"+MV_PAR05) // Obtem o primeiro dia do mês
		dFimMes :=	LastDate(MV_PAR05)	 // Obtem o último dia do mês
	Else
		MV_PAR05 := FirstDate(MV_PAR05) // Obtem o primeiro dia do mês
		dFimMes :=	LastDate(MV_PAR05)  // Obtem o último dia do mês
	EndIf


	cQuery := "SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_HRSDIA, SRA.RA_ADCINS, SRA.RA_ADCPERI, SRA.RA_PROCES, SRA.RA_HRSMES, SRA.RA_CC, SRA.RA_CODFUNC, "
	cQuery += "TFF.TFF_PERICU, TFF.TFF_INSALU, TFF.TFF_GRAUIN, "
	cQuery += "AA1.AA1_FUNFIL, AA1.AA1_CDFUNC, "
	
	If !lProcNew
		cQuery += "AB9.R_E_C_N_O_ AS RECAB9, ABA_QUANT HORAS, ABB.R_E_C_N_O_ AS RECABB"
	Else 
		cQuery += "ABB.R_E_C_N_O_ AS RECABB, ABB.ABB_HRTOT HORASABB"
	EndIf 

	cQuery += " FROM " + RetSqlName("ABB")+ " ABB "
	
	cQuery += " LEFT JOIN " + RetSqlName("AA1")+ " AA1 ON "
	cQuery += " AA1.AA1_FILIAL  = '" + xFilial("AA1") + "'"
	cQuery += " AND AA1.AA1_CODTEC  = ABB.ABB_CODTEC"
	cQuery += " AND AA1.D_E_L_E_T_  = ' '"

	cQuery += " LEFT JOIN " + RetSqlName("SRA")+ " SRA ON "
	cQuery += " SRA.RA_FILIAL   = AA1.AA1_FUNFIL"
	cQuery += " AND SRA.RA_MAT      = AA1.AA1_CDFUNC"
	cQuery += " AND SRA.D_E_L_E_T_  = ' '"

	If !lProcNew

		cQuery += " INNER JOIN " + RetSqlName("AB9")+ " AB9 ON "
		cQuery += " AB9.AB9_FILIAL  = '"+ xFilial("AB9") +"'"
		cQuery += " AND AB9.AB9_ATAUT   = ABB.ABB_CODIGO"	 
		cQuery += " AND SUBSTRING( AB9.AB9_NUMOS, 1, 6 ) = ABB.ABB_NUMOS"
		cQuery += " AND AB9.AB9_CODTEC = ABB.ABB_CODTEC"
		If Mv_par06  == 1
			If !(isInCallStack("Tec353HrRs"))
				cQuery += " AND AB9.AB9_ADIENV  = 'F'"
			EndIf
		Else
			cQuery += " AND AB9.AB9_ADIENV  = 'T'"
		EndIf

		cQuery += " AND AB9.D_E_L_E_T_ = ' '"

		cQuery += " INNER JOIN " + RetSqlName("ABA")+ " ABA ON "
		cQuery += " ABA.ABA_FILIAL = '"+ xFilial("ABA") +"'"
		cQuery += " AND ABA.ABA_CODTEC = ABB.ABB_CODTEC"
		cQuery += " AND ABA.ABA_NUMOS = AB9.AB9_NUMOS"
		cQuery += " AND ABA.ABA_SEQ = AB9.AB9_SEQ"
		cQuery += " AND ABA.D_E_L_E_T_ = ' '"
	
	EndIf

	cQuery += " INNER JOIN " + RetSqlName("ABQ")+ " ABQ ON "
	cQuery += " ABQ.ABQ_FILIAL  = '"+ xFilial("ABQ") +"'"
	cQuery += " AND ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL"
	cQuery += " AND ABQ.D_E_L_E_T_  = ' '"

	cQuery += " INNER JOIN " + RetSqlName("TFF")+ " TFF ON "
	cQuery += " TFF.TFF_FILIAL  = ABQ.ABQ_FILTFF"
	cQuery += " AND TFF.TFF_COD     = ABQ.ABQ_CODTFF"
	cQuery += " AND (TFF.TFF_PERICU <> '1' OR TFF.TFF_INSALU <> '1')"
	cQuery += " AND TFF.D_E_L_E_T_  = ' '"

	cQuery += " WHERE ABB.ABB_FILIAL  = '"+ xFilial("ABB") +"'"
	If Empty(aEmployees)
		cQuery += " AND ABB.ABB_CODTEC BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"'"
	Else
		cQuery += " AND ABB.ABB_CODTEC IN ( "
		For nX := 1 to LEN(aEmployees)
			cQuery += " '" + aEmployees[nX] + "',"
		Next nX
		cQuery := LEFT(cQuery, LEN(cQuery) - 1)
		cQuery += " ) "
	EndIf
	If !lMVPar08
		cQuery += " AND ABB.ABB_DTINI  >= '"+ DtoS(Mv_Par03) +"'"
		cQuery += " AND ABB.ABB_DTFIM  <= '"+ DtoS(Mv_Par04) +"'"
	Else
		cQuery += " AND ABB.ABB_DTINI  >= '"+ DtoS(MV_PAR05) +"'"
		cQuery += " AND ABB.ABB_DTFIM  <= '"+ DtoS(dFimMes) +"'"
	EndIf	
	cQuery += " AND ABB.ABB_CHEGOU = 'S' AND ABB.ABB_ATENDE = '1'
	cQuery += " AND ABB.ABB_ATIVO   = '1'"
	cQuery += " AND ABB.ABB_LOCAL  <> ' '"
	cQuery += " AND ABB.D_E_L_E_T_  = ' '"
	If lProcNew
		If Mv_par06  == 1
			If !(isInCallStack("Tec353HrRs"))
				cQuery += " AND ABB.ABB_ADIENV  = 'F'"
			EndIf
		Else
			cQuery += " AND ABB.ABB_ADIENV  = 'T'"
		EndIf
	EndIf	
	
	cQuery += " ORDER BY ABB.ABB_CODTEC"
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasA , .T., .T.)
	aEval( ABB->(DbStruct()),{|x| If(x[2] != "C", TcSetField(cAliasA, AllTrim(x[1]), x[2], x[3], x[4]),Nil)})

	DbSelectArea( cAliasA )
	(cAliasA)->( DbEval( { || nTotReg++ },,{ || !Eof() } ) )
	(cAliasA)->( DbGoTop() )
	
	ProcRegua( nTotReg )
 
	If nTotReg <= 0
		If !lJob
			Aviso(STR0001,STR0003, {STR0001}) // "Atenção" # "Não há dados, verifique parâmetros # "OK"
		EndIf
		aRet[1] := .F.
		AADD(aRet[2], STR0003)
		(cAliasA)->(DbCloseArea())
		Return()
	EndIf
	
	If (cAliasA)->(!EOF())
		cFilFunOld := (cAliasA)->RA_FILIAL
		cMatFunOld := (cAliasA)->RA_MAT
	EndIf

	//Verifica se existe insalubridade/periculosidade integral em algum dos postos do atendente
	While (cAliasA)->(!Eof()) .And. cFilFunOld == (cAliasA)->RA_FILIAL .OR. cMatFunOld == (cAliasA)->RA_MAT
		If (cAliasA)->TFF_PERICU == "2" .And. !lPeriInt
			lPeriInt := .T.
		EndIf

		If (cAliasA)->TFF_INSALU == "2" .And. !lInsaInt
			lInsaInt := .T.
		EndIf

		If lInsaInt .And. lPeriInt
			Exit
		EndIf

		(cAliasA)->(DbSkip())
	EndDo

	(cAliasA)->( DbGoTop() )

	While (cAliasA)->(!Eof())
	
		//Verifica se mudou funcionário e envia informações para RH.
		If cFilFunOld != (cAliasA)->RA_FILIAL .OR. cMatFunOld != (cAliasA)->RA_MAT
						
			If !At353EnvRH(cFilFunOld, cMatFunOld, aAdicionais, @aRet, lJob, lProcNew, nDiasSit)//Envia para RH
				lErro := .T.
			EndIf
						
			//Reinicia Variaveis
			aAdicionais	:= {}
			cFilFunOld := (cAliasA)->RA_FILIAL
			cMatFunOld := (cAliasA)->RA_MAT
			
		EndIf

		nDiasSit := At353Sit((cAliasA)->RA_MAT, (cAliasA)->RA_FILIAL ) 
		
		//Armazena informação relativa a horas e ao nivel de adicional (integral/proporcional,  maximo/medio/minimo)
				
		//Periculosidade
		If !Empty((cAliasA)->TFF_PERICU) .AND. (cAliasA)->TFF_PERICU != "1" 
			
			//Busca posição por tipo e grau
			nPos := aScan(aAdicionais, {|x|	x[ADICIONAIS_ADICIONAL] == PERICULOSIDADE .AND.;
													x[ADICIONAIS_TIPO] == (cAliasA)->TFF_PERICU .AND.;
													x[ADICIONAIS_GRAU] == NENHUM})
		  			
			If nPos == 0
				aAdd(aAdicionais, Array(ADICIONAIS_PREV))
				nPos := Len(aAdicionais)
				aAdicionais[nPos][ADICIONAIS_ADICIONAL] 	:= PERICULOSIDADE
				aAdicionais[nPos][ADICIONAIS_TIPO] 		:= (cAliasA)->TFF_PERICU
				aAdicionais[nPos][ADICIONAIS_GRAU] 		:= NENHUM
				If !lProcNew
					If nDiasSit > 0 .AND. (aAdicionais[nPos][2] == "2" .Or. lPeriInt) 
						aAdicionais[nPos][ADICIONAIS_HORAS] 		:= (nDiasSit * (cAliasA)->RA_HRSDIA) 
						aAdicionais[nPos][ADICIONAIS_AB9] 			:= {(cAliasA)->RECAB9}
					Else
						aAdicionais[nPos][ADICIONAIS_HORAS] 		:= (cAliasA)->HORAS
						aAdicionais[nPos][ADICIONAIS_AB9] 			:= {(cAliasA)->RECAB9}
					EndIf	
				Else 
					If nDiasSit > 0 .AND. (aAdicionais[nPos][2] == "2" .Or. lPeriInt)
						aAdicionais[nPos][ADICIONAIS_HORAS] 		:= (nDiasSit * (cAliasA)->RA_HRSDIA) 
						aAdicionais[nPos][ADICIONAIS_AB9] 			:= {(cAliasA)->RECABB}
					Else
						aAdicionais[nPos][ADICIONAIS_HORAS] 		:= Round(HoraToInt(SubStr((cAliasA)->HORASABB,6,10)),2) //(cAliasA)->HORASABB
						aAdicionais[nPos][ADICIONAIS_AB9] 			:= {(cAliasA)->RECABB}
					EndIf	
				EndIf 
			Else
				If !lProcNew
					If !(nDiasSit > 0 .AND. (aAdicionais[nPos][2] == "2" .Or. lPeriInt))
						aAdicionais[nPos][ADICIONAIS_HORAS] += (cAliasA)->HORAS
					EndIf	
					aAdd(aAdicionais[nPos][ADICIONAIS_AB9],(cAliasA)->RECAB9 )
				Else 
					If !(nDiasSit > 0 .AND. (aAdicionais[nPos][2] == "2" .Or. lPeriInt ))
						aAdicionais[nPos][ADICIONAIS_HORAS] +=  Round(HoraToInt(SubStr((cAliasA)->HORASABB,6,10)),2) //(cAliasA)->HORASABB
					EndIf	
					aAdd(aAdicionais[nPos][ADICIONAIS_AB9],(cAliasA)->RECABB )
				EndIf 	
			EndIf		
			
		EndIf
		
		
		//Insalubridade
		If !Empty((cAliasA)->TFF_INSALU) .AND. (cAliasA)->TFF_INSALU != "1" 	
			
			//Busca posição por tipo e grau
			nPos := aScan(aAdicionais, {|x| x[ADICIONAIS_ADICIONAL] == INSALUBRIDADE .AND. ;
												x[ADICIONAIS_TIPO] == (cAliasA)->TFF_INSALU .AND.;
												x[ADICIONAIS_GRAU] == (cAliasA)->TFF_GRAUIN})										
			If nPos == 0
				aAdd(aAdicionais, Array(ADICIONAIS_PREV))
				nPos := Len(aAdicionais)
				aAdicionais[nPos][ADICIONAIS_ADICIONAL] 	:= INSALUBRIDADE
				aAdicionais[nPos][ADICIONAIS_TIPO] 		:= (cAliasA)->TFF_INSALU
				aAdicionais[nPos][ADICIONAIS_GRAU] 		:= (cAliasA)->TFF_GRAUIN
				If !lProcNew
					If nDiasSit > 0 .AND. (aAdicionais[nPos][2] == "2" .Or. lInsaInt)
						aAdicionais[nPos][ADICIONAIS_HORAS] 		:= (nDiasSit * (cAliasA)->RA_HRSDIA) 
						aAdicionais[nPos][ADICIONAIS_AB9] 			:= {(cAliasA)->RECAB9}
					Else
						aAdicionais[nPos][ADICIONAIS_HORAS] 		:= (cAliasA)->HORAS
						aAdicionais[nPos][ADICIONAIS_AB9] 			:= {(cAliasA)->RECAB9}
					EndIf	
				Else 
					If nDiasSit > 0 .AND. (aAdicionais[nPos][2] == "2" .Or. lInsaInt)
						aAdicionais[nPos][ADICIONAIS_HORAS] 		:= (nDiasSit * (cAliasA)->RA_HRSDIA) 
						aAdicionais[nPos][ADICIONAIS_AB9] 			:= {(cAliasA)->RECABB}
					Else
						aAdicionais[nPos][ADICIONAIS_HORAS] 		:= Round(HoraToInt(SubStr((cAliasA)->HORASABB,6,10)),2) //(cAliasA)->HORASABB
						aAdicionais[nPos][ADICIONAIS_AB9] 			:= {(cAliasA)->RECABB}
					EndIf	
				EndIf 
			Else
				If !lProcNew
					If !(nDiasSit > 0 .AND. (aAdicionais[nPos][2] == "2" .Or. lInsaInt))
						aAdicionais[nPos][4] += 	(cAliasA)->HORAS
					EndIf
					aAdd(aAdicionais[nPos][5],(cAliasA)->RECAB9 )
				Else 
					If !(nDiasSit > 0 .AND.  (aAdicionais[nPos][2] == "2" .Or. lInsaInt))
						aAdicionais[nPos][4] += Round(HoraToInt(SubStr((cAliasA)->HORASABB,6,10)),2) //(cAliasA)->HORASABB
					EndIf
					aAdd(aAdicionais[nPos][5],(cAliasA)->RECABB )
				EndIf 	
			EndIf
			
		EndIf 
	
		(cAliasA)->(DbSkip())
	End
	
	
	//Envia ultimas informações para RH.
	If Len(aAdicionais) > 0
			
		If !At353EnvRH(cFilFunOld, cMatFunOld, aAdicionais, @aRet, lJob, lProcNew, nDiasSit)//Envia para RH
			lErro := .T.
		EndIf
		
		//Reinicia Variaveis
		aAdicionais	:= {}
		cFilFunOld 	:= ""
		cMatFunOld 	:= ""
		
	EndIf

	(cAliasA)->(DbCloseArea())
   
	If lErro
		If !lJob
			Aviso(STR0016, STR0010 + CRLF + STR0011 +TxLogPath(STR0007),  {STR0001}) // "Ocorreram erros " # "Foi gerado o log no arquivo " # ", deseja visualizar LOG?" # " Atenção"
		EndIf
		aRet[1] := .F.
		AADD(aRet[2], STR0010 + "##" + STR0011 +TxLogPath(STR0007))
	Else
		If !lJob
			Aviso(STR0016, STR0016, {STR0001}) // "Finalização" # "Processo finalizado" # "OK"
		EndIf
		AADD(aRet[2], STR0016)
	EndIf
Return()


/*/{Protheus.doc} At353EnvRH
Aplica regras de hierarquia de beneficios e realiza o envio dos adicionais para o RH. 
@since 26/06/2015
@version 1.0
@param cFilFun, String, Filial do Funcionário
@param cMatFun, String, Matricula do funcionário
@param aAdicionais, Array, Adicionais a serem enviados
@param lProcNew, Indica se usa o processo sem O.S .T. - Sem O.S, .F. - Com O.S
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function at353EnvRH(cFilFun, cMatFun, aAdicionais, aRet, lSemTela,lProcNew, nDiasSit)
	Local lRet := .T.	
	Local aAB9 := {}	
	Local lLogSuccess := (MV_PAR07 == 1) //Gera Log Total
	Local aCabec := {}
	Local aItens := {}	
	Local lGera := .T.
	Local cRoteiro := ""
	Local cPeriodo := ""
	Local cNumPagto := ""
	Local aPerAtual := {}
	Local aCodFol := {}
	Local cTxtLog := ""
	Local nPerInt := 0
	Local nPerProp := 0
	Local nInsIntMax := 0
	Local nInsIntMed := 0
	Local nInsIntMin := 0
	Local nInsPrpMax := 0
	Local nInsPrpMed := 0
	Local nInsPrpMin := 0
	Local nOpc      := Iif(MV_PAR06 == 1, 3, 5)//Inclusão ou estorno
	Local cErro := ""
	Local nI := 0
	Local nY := 0
	Local cCRLF
	Local nModo			:= 1
	Local lMV_GSLOG   := SuperGetMV('MV_GSLOG',,.F.)
	Local nA
	Local lAlteraRH := ExistBlock("TEC353Al")
	Local aCabItens := {}
	
	Private lMsHelpAuto    := .F.
	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	
	Default aRet := {.T.,{}}
	Default lSemTela := .F.
	Default nDiasSit := 0 
	
	cCRLF := IIF(lSemTela,"##",CRLF)
	
	SRA->(DbSetOrder(1))
	
	If SRA->(DbSeek(cFilFun+cMatFun))
	
		cTxtLog 	:= STR0004+" "+SRA->RA_MAT +" / "+SRA->RA_NOME + CRLF  //"Funcionário"
		cRoteiro 	:= At353GtRot()
		aCodFol := At353GetPd(SRA->RA_FILIAL)//Carrega aCodFol da Filial
		
		If Len(aCodFol) == 0
			TxLogFile(STR0007,cTxtLog+ CRLF + STR0008 +CRLF)  // "Funcionário " # "Erro ao carregar o roteiro de calculo"
			lGera := .F.	
		EndIf
			
		If Empty(cRoteiro)//VErifica roteiro da Folha
			TxLogFile(STR0007,cTxtLog+ CRLF + STR0008 +CRLF)  // "Funcionário " # "Erro ao carregar o roteiro de calculo"
			lGera := .F.	
		EndIF
		
		//Verifica periodo
		If fGetPerAtual( @aPerAtual, NIL, SRA->RA_PROCES, cRoteiro )				
			cPeriodo 	:= aPerAtual[1,1]
			cNumPagto	:= aPerAtual[1,2]				
		Else
			TxLogFile(STR0007,cTxtLog+ CRLF + STR0018 +CRLF)  // "Funcionário " # "Erro ao carregar o periodo atual"
			lGera := .F.	
		EndIf
	
		// pagamento de periculosidade configurada pelo cadastro de funcionários
		If  SRA->RA_ADCPERI <> '1' .AND. !(isInCallStack("Tec353HrRs"))
			TxLogFile(STR0007,cTxtLog + CRLF + STR0005 +CRLF)  // "Funcionário" # "Pagamento de periculosidade configurada pelo cadastro de funcionários"
			lGera    := .F.				
		EndIf

		// pagamento de insalubridade configurada pelo cadastro de funcionários
		If SRA->RA_ADCINS <> '1' .AND. !(isInCallStack("Tec353HrRs"))
			TxLogFile(STR0007,cTxtLog + CRLF + STR0006 +CRLF) // "Funcionário" # "Pagamento de insalubridade configurada pelo cadastro de funcionários"
			lGera    := .F.			
		EndIf

		If lGera
			//Identifica configurações
			nPerInt	:= aScan(aAdicionais, {|x| x[ADICIONAIS_ADICIONAL] == PERICULOSIDADE .AND. x[ADICIONAIS_TIPO] == INTEGRAL })
			nPerProp 	:= aScan(aAdicionais, {|x| x[ADICIONAIS_ADICIONAL] == PERICULOSIDADE .AND. x[ADICIONAIS_TIPO] == PROPORCIONAL })
			
			nInsIntMax	:= aScan(aAdicionais, {|x| x[ADICIONAIS_ADICIONAL] == INSALUBRIDADE .AND. x[ADICIONAIS_TIPO] == INTEGRAL .AND. x[ADICIONAIS_GRAU] == MAXIMO })
			nInsIntMed	:= aScan(aAdicionais, {|x| x[ADICIONAIS_ADICIONAL] == INSALUBRIDADE .AND. x[ADICIONAIS_TIPO] == INTEGRAL .AND. x[ADICIONAIS_GRAU] == MEDIO })
			nInsIntMin	:= aScan(aAdicionais, {|x| x[ADICIONAIS_ADICIONAL] == INSALUBRIDADE .AND. x[ADICIONAIS_TIPO] == INTEGRAL .AND. x[ADICIONAIS_GRAU] == MINIMO })
			nInsPrpMax	:= aScan(aAdicionais, {|x| x[ADICIONAIS_ADICIONAL] == INSALUBRIDADE .AND. x[ADICIONAIS_TIPO] == PROPORCIONAL .AND. x[ADICIONAIS_GRAU] == MAXIMO })
			nInsPrpMed	:= aScan(aAdicionais, {|x| x[ADICIONAIS_ADICIONAL] == INSALUBRIDADE .AND. x[ADICIONAIS_TIPO] == PROPORCIONAL .AND. x[ADICIONAIS_GRAU] == MEDIO })
			nInsPrpMin	:= aScan(aAdicionais, {|x| x[ADICIONAIS_ADICIONAL] == INSALUBRIDADE .AND. x[ADICIONAIS_TIPO] == PROPORCIONAL .AND. x[ADICIONAIS_GRAU] == MINIMO })
		
			//PRIORIDADE DE ENVIO PERICULOSIDADE
			//1-Periculosidade Integral
			//2-Periculosidade Proporcional		
			
			//PRIORIDADE DE ENVIO INSALUBRIDADE
			//Insalubridade Integral Maxima
			//Insalubridade Integral Media
			//Insalubridade Integral Minima
			//Insalubridade Proporcinal conforme Grau
		
			If nPerInt > 0
				If At353ChkId(aCodFol, ID_PERICULOSIDADE)	
					If nDiasSit > 0		
						aItens := At353AddIt(aItens, aCodFol[ID_PERICULOSIDADE,1],  aAdicionais[nPerInt][ADICIONAIS_HORAS], cNumPagto)
					Else
						aItens := At353AddIt(aItens, aCodFol[ID_PERICULOSIDADE,1], SRA->RA_HRSMES, cNumPagto)
					EndIf	
				Else
					TxLogFile(STR0007,cTxtLog + CRLF + STR0019 +CRLF) // "Funcionário" # "ID de Calculo de Periculosidade não configurado no módulo de Gestão de Pessoal"
					lRet := .F.
				EndIf
			ElseIf nPerProp > 0
				If At353ChkId(aCodFol, ID_PERICULOSIDADE)
					aItens := At353AddIt(aItens, aCodFol[ID_PERICULOSIDADE,1], aAdicionais[nPerProp][ADICIONAIS_HORAS], cNumPagto)
				Else
					TxLogFile(STR0007,cTxtLog + CRLF + STR0019 +CRLF) // "Funcionário" # "ID de Calculo de Periculosidade não configurado no módulo de Gestão de Pessoal"
					lRet := .F.
				EndIf		
			EndIf
		
			
			If nInsIntMax > 0 //Adiciona Insalubridade Integral Maxima
				If At353ChkId(aCodFol, ID_INSALUBRIDADE_MAXIMA)
					If nDiasSit > 0
						aItens := At353AddIt(aItens, aCodFol[ID_INSALUBRIDADE_MAXIMA,1], aAdicionais[nInsIntMax][ADICIONAIS_HORAS], cNumPagto)
					Else
						aItens := At353AddIt(aItens, aCodFol[ID_INSALUBRIDADE_MAXIMA,1], SRA->RA_HRSMES, cNumPagto)
					EndIf	
				Else
					TxLogFile(STR0007,cTxtLog + CRLF + STR0022 +CRLF) // "Funcionário" # "ID de Calculo de Insalubridade Máxima não configurado no módulo de Gestão de Pessoal"
					lRet := .F.
				EndIf
			
			ElseIf nInsIntMed > 0 //Adiciona Insalubridade Integral Media
				If At353ChkId(aCodFol, ID_INSALUBRIDADE_MEDIA)
					If nDiasSit > 0
						aItens := At353AddIt(aItens, aCodFol[ID_INSALUBRIDADE_MEDIA,1], aAdicionais[nInsIntMed][ADICIONAIS_HORAS], cNumPagto)
					Else
						aItens := At353AddIt(aItens, aCodFol[ID_INSALUBRIDADE_MEDIA,1], SRA->RA_HRSMES, cNumPagto)
					EndIf
				Else
					TxLogFile(STR0007,cTxtLog + CRLF + STR0021 +CRLF) // "Funcionário" # "ID de Calculo de Insalubridade Média não configurado no módulo de Gestão de Pessoal"
					lRet := .F.
				EndIf
			
			ElseIf nInsIntMin > 0 //Adiciona Insalubridade Integral Minima
				If At353ChkId(aCodFol, ID_INSALUBRIDADE_MINIMA)
					If nDiasSit > 0
						aItens := At353AddIt(aItens, aCodFol[ID_INSALUBRIDADE_MINIMA,1], aAdicionais[nInsIntMin][ADICIONAIS_HORAS], cNumPagto)
					Else
						aItens := At353AddIt(aItens, aCodFol[ID_INSALUBRIDADE_MINIMA,1], SRA->RA_HRSMES, cNumPagto)
					EndIf	
				Else
					TxLogFile(STR0007,cTxtLog + CRLF + STR0020 +CRLF) // "Funcionário" # "ID de Calculo de Insalubridade Minima não configurado no módulo de Gestão de Pessoal"
					lRet := .F.
				EndIf	
			Else
				If nInsPrpMax > 0	 //Adiciona Proporcional Maxima			
					If At353ChkId(aCodFol, ID_INSALUBRIDADE_MAXIMA)
						aItens := At353AddIt(aItens, aCodFol[ID_INSALUBRIDADE_MAXIMA,1], aAdicionais[nInsPrpMax][ADICIONAIS_HORAS], cNumPagto)
					Else
						TxLogFile(STR0007,cTxtLog + CRLF + STR0022 +CRLF) // "Funcionário" # "ID de Calculo de Insalubridade Máxima não configurado no módulo de Gestão de Pessoal"
						lRet := .F.
					EndIf
				EndIf
				
				If nInsPrpMed > 0 //Adiciona Proporcional Media
					If At353ChkId(aCodFol, ID_INSALUBRIDADE_MEDIA)
						aItens := At353AddIt(aItens, aCodFol[ID_INSALUBRIDADE_MEDIA,1], aAdicionais[nInsPrpMed][ADICIONAIS_HORAS], cNumPagto)
					Else
						TxLogFile(STR0007,cTxtLog + CRLF + STR0021 +CRLF) // "Funcionário" # "ID de Calculo de Insalubridade Média não configurado no módulo de Gestão de Pessoal"
						lRet := .F.
					EndIf
				EndIf
				
				If nInsPrpMin > 0 //Adiciona Proporcional Minima
					If At353ChkId(aCodFol, ID_INSALUBRIDADE_MINIMA)
						aItens := At353AddIt(aItens, aCodFol[ID_INSALUBRIDADE_MINIMA,1], aAdicionais[nInsPrpMin][ADICIONAIS_HORAS], cNumPagto)
					Else
						TxLogFile(STR0007,cTxtLog + CRLF + STR0020 +CRLF) // "Funcionário" # "ID de Calculo de Insalubridade Minima não configurado no módulo de Gestão de Pessoal"
						lRet := .F.
					EndIf
				EndIf		
			EndIf
		
			If Len(aItens) > 0
				
				aadd(aCabec,{'RA_FILIAL' , SRA->RA_FILIAL, Nil })
				aadd(aCabec,{'RA_MAT'    , SRA->RA_MAT, Nil })
				aadd(aCabec,{'CPERIODO'  , cPeriodo            , Nil })
				aadd(aCabec,{'CROTEIRO'  , cRoteiro            , Nil })
				aadd(aCabec,{'CNUMPAGTO' , cNumPagto           , Nil })	
				
				If nOpc == 3
					nOpc := At353BenVa(SRA->RA_FILIAL,SRA->RA_MAT,SRA->RA_PROCES,cPeriodo,cRoteiro)
				EndIf
  
				If nOpc == 5
					nModo := 2
				Endif
				If lMV_GSLOG
					oGsLog  := GsLog():new()
					oGsLog:addLog("TECA353", STR0027 + SRA->RA_FILIAL )
					oGsLog:addLog("TECA353", STR0028 + SRA->RA_MAT )
					oGsLog:addLog("TECA353", STR0029 + cPeriodo )
					oGsLog:addLog("TECA353", STR0030 + cRoteiro )
					oGsLog:addLog("TECA353", STR0031 + cNumPagto )
					For nA := 1 To LEN(aItens)
						oGsLog:addLog("TECA353", STR0032 + aItens[nA][4][2] )
						oGsLog:addLog("TECA353", STR0033 + cValToChar(aItens[nA][6][2]) )
					Next nA
					oGsLog:addLog("TECA353", "----------" )
					oGsLog:printLog("TECA353")
				Endif
				If lAlteraRH
					aCabItens := ACLONE(EXECBLOCK("TEC353Al", .F., .F.,{ aCabec, aItens, nOpc}  ))
					aCabec := aCabItens[1]
					aItens := aCabItens[2]
				EndIf	
				If !(isInCallStack("Tec353HrRs"))
					MsExecAuto({|w,x,y,z,t,u| GPEA580(w,x,y,z,t,u)} , nil ,aCabec, aItens, nOpc, nModo, "GS" ) // 3 - Inclusão, 4 - Alteração, 5 - Exclusão
				Else
					a353HrRs := ACLONE(aItens)
				EndIf
				If lMsErroAuto
					cErro := ""
					aEval(GetAutoGRLog(),{|x| cErro +=  x + cCRLF })							
					TxLogFile(STR0007, cTxtLog + cErro)   // "Adicionais"
					AADD(aRet[2], cTxtLog + cErro)
					lRet := .F.
					aRet[1] := .F.
				Else
					If !(isInCallStack("Tec353HrRs"))
						If !lProcNew
							For nI:=1 To Len(aAdicionais)
								For nY:=1 To Len(aAdicionais[nI][ADICIONAIS_AB9])
									AB9->(DbGoTo( aAdicionais[nI][ADICIONAIS_AB9][nY] ))
									If AB9->(!EOF())
										RecLock("AB9", .F.)
										AB9->AB9_ADIENV := MV_PAR06 == 1
										MsUnLock()
									EndIf															
								Next nY										
							Next nI
						Else 
							For nI:=1 To Len(aAdicionais)
								For nY:=1 To Len(aAdicionais[nI][ADICIONAIS_AB9])
									ABB->(DbGoTo( aAdicionais[nI][ADICIONAIS_AB9][nY] ))
									If ABB->(!EOF())
										RecLock("ABB", .F.)
										ABB->ABB_ADIENV := MV_PAR06 == 1
										MsUnLock()
									EndIf															
								Next nY										
							Next nI
						EndIf 
					EndIf
					If lLogSuccess
						If nOpc == 5
							TxLogFile(STR0007,cTxtLog + cCRLF + STR0024 + cCRLF)   //"Funcionário # "Estorno realizado com sucesso"
							AADD(aRet[2], cTxtLog + cCRLF + STR0024 + cCRLF)								
						Else
							TxLogFile(STR0007,cTxtLog + cCRLF + STR0009 + cCRLF)   //"Funcionário # "Lançamento realizado com sucesso"
							AADD(aRet[2], cTxtLog + cCRLF + STR0009 + cCRLF)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return lGera .AND. lRet

/*/{Protheus.doc} At353AddIt
Realiza a inclusão de um novo item na estrutura de itens da RGB
@since 26/06/2015

@param aItens}, Array, array que será adicionado o item
@param cVerba, String, Código da verba
@param nHoras, Integer, Quantidade de horas
@param cNumPagto, String, Numero de pagamento

@return aItens, Array com o item incluído

/*/
Static Function At353AddIt(aItens, cVerba, nHoras, cNumPagto)
	Local aAux := {}
	Local cCodInter := ""

	aAdd(aAux,{"RGB_FILIAL" , xFilial("RGB") , Nil })
	aAdd(aAux,{"RGB_MAT"    , SRA->RA_MAT    , Nil })
	aAdd(aAux,{"RGB_PROCESS", SRA->RA_PROCES , Nil })
	aAdd(aAux,{"RGB_PD"     , cVerba         , Nil })
	aAdd(aAux,{"RGB_TIPO1"  , "H"            , Nil })
	aAdd(aAux,{"RGB_HORAS"  , nHoras		, Nil })
	aAdd(aAux,{"RGB_CC"     , SRA->RA_CC     , Nil })
	aAdd(aAux,{"RGB_CODFUN" , SRA->RA_CODFUNC, Nil })
	aAdd(aAux,{"RGB_SEMANA" , cNumPagto, Nil })
	aAdd(aAux,{"RGB_CLVL" , SRA->RA_CLVL, Nil })
	aAdd(aAux,{"RGB_ITEM" , SRA->RA_ITEM, Nil })
	aAdd(aAux,{"RGB_NUMID" , "GS", Nil })

	If (SRA->RA_TPCONTR == "3")
		cCodInter := At353Int(SRA->RA_MAT)
		aAdd(aAux,{"RGB_CONVOC" , cCodInter, Nil })
	EndIf	
	aadd(aItens, aAux)

Return aItens

Static Function At353GtRot()

Return fGetRotOrdinar()

/*/{Protheus.doc} At353GetPd

Realiza otimização do carregamento das verbas por filial

@since 25/06/2015
@version 1.0
@param aCods, Array, Cache para controle de verbas por ID de calculo
@return aCodFol, Array com identificadores de calculo da filial

/*/
Static Function At353GetPd( cFil)
	Local aRet := {}
	Local nPos := 0
	Local aCodFol := {}

	nPos := aScan(aCacheCFol, {|x| x[1] == cFil})
	If nPos == 0	
		Fp_CodFol(@aCodFol, cFil)
		
		aAdd(aCacheCFol, {cFil, aClone(aCodFol)}) 		
	Else
		aCodFol := aClone(aCacheCFol[nPos][2])
	EndIf
	
Return aCodFol

/*/{Protheus.doc} At353ChkId
Verifica se id é existende em aCodFol

@since 26/06/2015
@param aCodFol, Array, COdigos de identificadores de calculo
@param nId, Integer, id do identificador de calculo
@return Boolean
/*/
Static Function At353ChkId(aCodFol, nId)
	Local lRet := .T.
	
	lRet := !Empty(aCodFol[nId][1])
	
Return lRet

/*/{Protheus.doc} At353BenVa

Verifica se há um lançamento para o funcionario, para chamar execauto como alteração

@since 13/07/2020
@version 1.0
@param cFilAux, Caracter, Filial
@param cMatricula, Caracter, Matricula do Funcionario a ser pesquisado
@param cProcesso, Caracter, Codigo do Processo do Funcionario
@param cCodPer, Caracter, Codigo do Periodo
@param cCodRot, Caracter, Codigo do Roteiro
@return nOpc - Retorna o modo para a excauto - Inclusão ou Alteração
/*/
Static Function At353BenVa(cFilAux,cMatricula,cProcesso,cCodPer,cCodRot)
Local cQry 			:= GetNextAlias()

BeginSQL Alias cQry
	SELECT 1 REC
	FROM %Table:RGB% RGB
	WHERE RGB.RGB_FILIAL = %Exp:cFilAux%
		AND RGB.%NotDel%
		AND RGB.RGB_PROCES = %Exp:cProcesso%
		AND RGB.RGB_PERIOD = %Exp:cCodPer%
		AND RGB.RGB_ROTEIR = %Exp:cCodRot%
		AND RGB.RGB_MAT = %Exp:cMatricula%
EndSQL

lInclusao := (cQry)->(EOF())
(cQry)->(DbCloseArea())

dBSelectArea("RGB")
dbSetorder(3) // RGB_FILIAL, RGB_PROCES, RGB_MAT, RGB_PERIOD
RGB->(dbSeek(cFilAux+cProcesso+cMatricula+cCodPer))

Return Iif(lInclusao,3,4)

/*/{Protheus.doc} At353Int

Busca o código do atendente intermitente para adicionar no array de itens 

@since 27/10/2020
@autor Junior Santos
/*/
Function At353Int(cCodMat)
Local cQry 			:= GetNextAlias()
Local cCodInter     := ""

BeginSQL Alias cQry
	SELECT  V7_COD FROM %Table:SV7% SV7
	INNER JOIN %Table:SRA% SRA
	ON RA_MAT = V7_MAT 
	WHERE RA_MAT = %Exp:cCodMat%
	AND((V7_DTINI <=  %Exp:MV_PAR03% OR V7_DTINI BETWEEN  %Exp:MV_PAR03% AND  %Exp:MV_PAR04% )
 	AND ( V7_DTFIM >=  %Exp:MV_PAR04% OR V7_DTFIM BETWEEN  %Exp:MV_PAR03% AND  %Exp:MV_PAR04%) )
	AND RA_FILIAL = %Exp:SRA->RA_FILIAL%
	AND SV7.%NotDel%
	AND SRA.%NotDel%

EndSQL

(cQry)->( DbGoTop() )
If !(cQry)->(EOF())
	cCodInter := (cQry)->V7_COD
EndIf	

(cQry)->(DbCloseArea())
Return cCodInter

/*/{Protheus.doc} At353Sit

Verifica se o atendente possui admissão, demissão, afastamento ou férias no periódo do envio de periculosidade/insalubridade 

@since 04/11/2020
@autor Junior Santos
@return nDiasSit - Quantiadde de dias para cálculo da folha caso tenha admissão ou demissão ou afastamento ou férias no periódo do envio de periculosidade/insalubridade
/*/

Function At353Sit(cCodMat,cCodFil)

Local cAliasTmp	:= GetNextAlias()
Local nDiasSit := 0
Local lMVPar08 := .F. 
Local dFimMes  := CtoD("")
Local nAdmDem  := 0
Local nDiaFim  := 0
Local dMenorDt := MV_PAR03
Local cMenorDt := ""

Default cCodMat := ""
Default cCodFil := ""

If TecHasPerg("MV_PAR08", "TECA353") .And. MV_PAR08 == 2
	lMVPar08 := .T.
	dFimMes :=	LastDate(MV_PAR05)
	nDiaFim := 	Last_Day(MV_PAR05)
	If MV_PAR05 < dMenorDt
		dMenorDt := MV_PAR05
	EndIf
EndIf	

cMenorDt := DTOS(dMenorDt)

BeginSql Alias cAliasTmp
	
	COLUMN RA_ADMISSA AS DATE
	COLUMN RA_DEMISSA AS DATE
	COLUMN RF_DATAINI AS DATE
	COLUMN RF_DATINI2 AS DATE
	COLUMN RF_DATINI3 AS DATE
	COLUMN RH_DATABAS AS DATE
	COLUMN RH_DBASEAT AS DATE
	COLUMN R8_DATAINI AS DATE
	COLUMN R8_DATAFIM AS DATE
	COLUMN V7_DTINI   AS DATE
	COLUMN V7_DTFIM   AS DATE 
	COLUMN TXB_DTINI  AS DATE
	COLUMN TXB_DTFIM  AS DATE 

	SELECT DISTINCT
		  COALESCE( SRA.RA_MAT		, ' ' ) RA_MAT
		, COALESCE( SRA.RA_CODFUNC	, ' ' ) RA_CODFUNC
		, COALESCE( SRA.RA_ADMISSA	, ' ' ) RA_ADMISSA
		, COALESCE( SRA.RA_DEMISSA	, ' ' ) RA_DEMISSA
		, COALESCE( SRF.RF_MAT		, ' ' ) RF_MAT
		, COALESCE( SRF.RF_DATAINI	, ' ' ) RF_DATAINI
		, COALESCE( SRF.RF_DFEPRO1	, 0 ) RF_DFEPRO1
		, COALESCE( SRF.RF_DATINI2	, ' ' ) RF_DATINI2
		, COALESCE( SRF.RF_DFEPRO2	, 0 ) RF_DFEPRO2
		, COALESCE( SRF.RF_DATINI3	, ' ' ) RF_DATINI3
		, COALESCE( SRF.RF_DFEPRO3	, 0 ) RF_DFEPRO3
		, COALESCE( SRH.RH_MAT		, ' ' ) RH_MAT
		, COALESCE( SRH.RH_DATABAS	, ' ' ) RH_DATABAS
		, COALESCE( SRH.RH_DBASEAT	, ' ' ) RH_DBASEAT
		, COALESCE( SR8.R8_MAT		, ' ' ) R8_MAT
		, COALESCE( SR8.R8_DATAINI	, ' ' ) R8_DATAINI
		, COALESCE( SR8.R8_DATAFIM	, ' ' ) R8_DATAFIM
		, COALESCE( SV7.V7_MAT	    , ' ' ) V7_MAT
		, COALESCE( SV7.V7_DTINI	, ' ' ) V7_DTINI
		, COALESCE( SV7.V7_DTFIM	, ' ' ) V7_DTFIM
		, COALESCE(TXB.TXB_CODTEC   , ' ') TXB_CODTEC
		, COALESCE(TXB.TXB_DTINI    , ' ') TXB_DTINI
		, COALESCE(TXB.TXB_DTFIM    , ' ') TXB_DTFIM
	FROM %Table:SRA% SRA
		LEFT JOIN %Table:AA1% AA1 ON AA1.AA1_FUNFIL = SRA.RA_FILIAL AND AA1.AA1_CDFUNC = SRA.RA_MAT AND AA1.%NotDel%
		
		LEFT JOIN %Table:SRH% SRH ON SRH.RH_FILIAL=%xFilial:SRH% AND SRH.RH_MAT=SRA.RA_MAT AND SRH.%NotDel%
		
		LEFT JOIN %Table:SRF% SRF ON SRF.RF_FILIAL=%xFilial:SRF% AND SRF.RF_MAT=SRA.RA_MAT AND SRF.%NotDel%
			AND ( SRF.RF_DATAINI >= %Exp:cMenorDt% OR SRF.RF_DATINI2 >= %Exp:cMenorDt% OR SRF.RF_DATINI3 >= %Exp:cMenorDt% )

		LEFT JOIN %Table:SR8% SR8 ON SR8.R8_FILIAL=%xFilial:SR8% AND SR8.R8_MAT=SRA.RA_MAT AND SR8.%NotDel% 
			AND SR8.R8_DATAFIM >= %Exp:cMenorDt%

		LEFT JOIN %Table:SV7% SV7 ON SV7.V7_FILIAL=%xFilial:SV7% AND SV7.V7_MAT=SRA.RA_MAT AND SV7.%NotDel%

		LEFT JOIN %Table:TXB% TXB ON TXB.TXB_FILIAL=%xFilial:TXB% AND TXB.TXB_CODTEC=AA1.AA1_CODTEC AND TXB.%NotDel%
		
	WHERE
		SRA.RA_FILIAL = %Exp:cCodFil% 
	 	AND SRA.RA_MAT= %Exp:cCodMat% 
		AND SRA.%NotDel%
EndSql

While (cAliasTmp)->(!EOF())

	If !lMVPar08// Caso não tenha o parâmetro ou esteja como não, a rotina funcionará com os mesmos critérios antigos.
		If nAdmDem == 0 // caso tenha admissão ou demissão no período e ter dois afastamentos, calcular somente uma vez a demissão/admissão.
			If !Empty((cAliasTmp)->RA_ADMISSA)  .And. !Empty((cAliasTmp)->RA_DEMISSA) .And.; // caso seja admitido e demitido durante o período 
				((cAliasTmp)->RA_ADMISSA > MV_PAR03 .and.  (cAliasTmp)->RA_DEMISSA <= MV_PAR04)
				nDiasSit := (((cAliasTmp)->RA_DEMISSA - (cAliasTmp)->RA_ADMISSA ) +1) 

			ElseIf !Empty((cAliasTmp)->RA_ADMISSA)  .AND. ((cAliasTmp)->RA_ADMISSA > MV_PAR03 .AND. (cAliasTmp)->RA_ADMISSA <= MV_PAR04) //caso tenha sido admitido no período 
				nDiasSit := (30 - (((cAliasTmp)->RA_ADMISSA) - MV_PAR03))
			
			ElseIf !Empty((cAliasTmp)->RA_DEMISSA) .AND. ( (cAliasTmp)->RA_DEMISSA > MV_PAR03 .AND. (cAliasTmp)->RA_DEMISSA <= MV_PAR04) //caso tenha sido demitido no período
				nDiasSit := (( (cAliasTmp)->RA_DEMISSA - MV_PAR03) +1)
			EndIf
			nAdmDem++
		EndIf
		// Validação nas datas da SRH - Férias
		If !Empty((cAliasTmp)->RH_MAT) .And. ;  // Exista informação na SRH 
			!Empty((cAliasTmp)->RH_DATABAS)  .And. !Empty((cAliasTmp)->RH_DBASEAT) .And.; //caso a data de início e fim estejam dentro do período  
			(cAliasTmp)->RH_DATABAS >= MV_PAR03 .and. (cAliasTmp)->RH_DBASEAT <= MV_PAR04

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= ( ( (cAliasTmp)->RH_DBASEAT - (cAliasTmp)->RH_DATABAS) +1)
			Else
				nDiasSit := (30 - ( ( (cAliasTmp)->RH_DBASEAT - (cAliasTmp)->RH_DATABAS) +1) )
			EndIf

		ElseIf !Empty((cAliasTmp)->RH_DATABAS)  .And. ; //caso a data de início esteja entre os peródos e a data final sendo maior do que a do período.
			((cAliasTmp)->RH_DATABAS >= MV_PAR03 .And. (cAliasTmp)->RH_DATABAS <= MV_PAR04 .AND. (cAliasTmp)->RH_DBASEAT >= MV_PAR04)
				
			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (30 - ((cAliasTmp)->RH_DATABAS - MV_PAR03) )
			Else
				nDiasSit := ( 30 -(30 - ((cAliasTmp)->RH_DATABAS - MV_PAR03) ) )
			EndIf
			
		ElseIf !Empty((cAliasTmp)->RH_DBASEAT) .AND.; // caso a data fim esteja entre os peródos e a data inical sendo menor do que a do período.
			( (cAliasTmp)->RH_DATABAS <= MV_PAR03 .And. (cAliasTmp)->RH_DBASEAT >= MV_PAR03 .AND. (cAliasTmp)->RH_DBASEAT <= MV_PAR04) 

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( (cAliasTmp)->RH_DBASEAT - MV_PAR03) +1)
			Else
				nDiasSit := (30 -(( (cAliasTmp)->RH_DBASEAT - MV_PAR03) +1))
			EndIf

		EndIf

		//Validação na SRF para a data inicial 
		If !Empty((cAliasTmp)->RF_MAT) .And. ;  // Exista informação na SRF
			!Empty((cAliasTmp)->RF_DATAINI) .And. ; //caso a data de início e fim estejam dentro do período  
			((cAliasTmp)->RF_DATAINI >= MV_PAR03 .and. ( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 ) <= MV_PAR04)

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( ( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 ) - (cAliasTmp)->RF_DATAINI) +1)
			Else
				nDiasSit := (30 - (( ( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 ) - (cAliasTmp)->RF_DATAINI) +1))
			EndIf

		ElseIf !Empty((cAliasTmp)->RF_DATAINI)  .And. ; //caso a data de início esteja entre os peródos e a data final sendo maior do que a do período.
			((cAliasTmp)->RF_DATAINI >= MV_PAR03 .And. ( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 ) <= MV_PAR04 .AND. ( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 ) >= MV_PAR04)
				
			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (30 - ((cAliasTmp)->RF_DATAINI - MV_PAR03) ) 
			Else
				nDiasSit := ( 30 -(30 - ((cAliasTmp)->RF_DATAINI - MV_PAR03) ) )
			EndIf
			
		ElseIf !Empty(( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 )) .AND.; // caso a data fim esteja entre os peródos e a data inical sendo menor do que a do período.
			( (cAliasTmp)->RF_DATAINI <= MV_PAR03 .And. ( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 ) >= MV_PAR03 .AND. ( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 ) <= MV_PAR04) 
			
			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( ( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 ) - MV_PAR03) +1)
			Else
				nDiasSit := (30 - (( ( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 ) - MV_PAR03) +1))  
			EndIf

		EndIf
		//Validação na SRF para a data inicial 2
		If !Empty((cAliasTmp)->RF_MAT) .And. ;  // Exista informação na SRF
			!Empty((cAliasTmp)->RF_DATINI2) .And. ; //caso a data de início e fim estejam dentro do período  
			((cAliasTmp)->RF_DATINI2 >= MV_PAR03 .and. ( (cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 ) <= MV_PAR04)

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( ( (cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 ) - (cAliasTmp)->RF_DATINI2) +1)
			Else
				nDiasSit := (30 - (( ( (cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 ) - (cAliasTmp)->RF_DATINI2) +1))
			EndIf

		ElseIf !Empty((cAliasTmp)->RF_DATINI2)  .And. ; //caso a data de início esteja entre os peródos e a data final sendo maior do que a do período.
			((cAliasTmp)->RF_DATINI2 >= MV_PAR03 .And. ( (cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 ) <= MV_PAR04 .AND. ( (cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 ) >= MV_PAR04)
				
			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (30 - ((cAliasTmp)->RF_DATINI2 - MV_PAR03) ) 
			Else
				nDiasSit := ( 30 -(30 - ((cAliasTmp)->RF_DATINI2 - MV_PAR03) ) )
			EndIf
			
		ElseIf !Empty( ((cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 )) .AND.; // caso a data fim esteja entre os peródos e a data inical sendo menor do que a do período.
			((cAliasTmp)->RF_DATINI2 <= MV_PAR03 .And. ( (cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 ) >= MV_PAR03 .AND. ( (cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 ) <= MV_PAR04) 

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( ( (cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 ) - MV_PAR03) +1)
			Else
				nDiasSit := (30 - (( ( (cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 ) - MV_PAR03) +1))  
			EndIf

		EndIf

		//Validação na SRF para a data inicial 3 
		If !Empty((cAliasTmp)->RF_MAT) .And. ;  // Exista informação na SRF
			!Empty((cAliasTmp)->RF_DATINI3) .And. ; //caso a data de início e fim estejam dentro do período  
			((cAliasTmp)->RF_DATINI3 >= MV_PAR03 .and. ( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 ) <= MV_PAR04)

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( ( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 ) - (cAliasTmp)->RF_DATINI3) +1)
			Else
				nDiasSit := (30 - (( ( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 ) - (cAliasTmp)->RF_DATINI3) +1))
			EndIf

		ElseIf !Empty((cAliasTmp)->RF_DATINI3)  .And. ; //caso a data de início esteja entre os peródos e a data final sendo maior do que a do período.
			((cAliasTmp)->RF_DATINI3 >= MV_PAR03 .And. ( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 ) <= MV_PAR04 .AND. ( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 ) >= MV_PAR04)
				
			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (30 - ((cAliasTmp)->RF_DATINI3 - MV_PAR03) ) 
			Else
				nDiasSit := ( 30 -(30 - ((cAliasTmp)->RF_DATINI3 - MV_PAR03) ) )
			EndIf
			
		ElseIf !Empty(( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 )) .AND.; // caso a data fim esteja entre os peródos e a data inical sendo menor do que a do período.
			((cAliasTmp)->RF_DATINI3 <= MV_PAR03 .And. ( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 ) >= MV_PAR03 .AND. ( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 ) <= MV_PAR04) 

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( ( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 ) - MV_PAR03) +1)
			Else
				nDiasSit := (30 - (( ( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 ) - MV_PAR03) +1))  
			EndIf

		EndIf

		// Validação nas datas da SR8
		If !Empty((cAliasTmp)->R8_MAT) .And. ;  // Exista informação na SR8 
		!Empty((cAliasTmp)->R8_DATAINI)  .And. !Empty((cAliasTmp)->R8_DATAFIM) .And.; //caso a data de início e fim estejam dentro do período  
			(cAliasTmp)->R8_DATAINI >= MV_PAR03 .and. (cAliasTmp)->R8_DATAFIM <= MV_PAR04

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= ( ( (cAliasTmp)->R8_DATAFIM - (cAliasTmp)->R8_DATAINI) +1)
			Else
				nDiasSit := (30 - ( ( (cAliasTmp)->R8_DATAFIM - (cAliasTmp)->R8_DATAINI) +1) )
			EndIf

		ElseIf !Empty((cAliasTmp)->R8_DATAINI)  .And. ; //caso a data de início esteja entre os peródos e a data final sendo maior do que a do período.
			((cAliasTmp)->R8_DATAINI >= MV_PAR03 .And. (cAliasTmp)->R8_DATAINI <= MV_PAR04 .AND. ((cAliasTmp)->R8_DATAFIM >= MV_PAR04 .OR. EMPTY((cAliasTmp)->R8_DATAFIM)))
				
			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (30 - ((cAliasTmp)->R8_DATAINI - MV_PAR03) ) 
			Else
				nDiasSit := ( 30 -(30 - ((cAliasTmp)->R8_DATAINI - MV_PAR03) ) )
			EndIf
			
		ElseIf !Empty((cAliasTmp)->R8_DATAFIM) .AND.; // caso a data fim esteja entre os peródos e a data inical sendo menor do que a do período.
			( (cAliasTmp)->R8_DATAINI <= MV_PAR03 .And. (cAliasTmp)->R8_DATAFIM >= MV_PAR03 .AND. (cAliasTmp)->R8_DATAFIM <= MV_PAR04) 

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( R8_DATAFIM - MV_PAR03) +1)
			Else
				nDiasSit := (30 - (( (cAliasTmp)->R8_DATAFIM - MV_PAR03) +1))
			EndIf

		EndIf

		// Validação nas datas da SV7
		If !Empty((cAliasTmp)->V7_MAT) .And. ;  // Exista informação na SV7 intermitente
		!Empty((cAliasTmp)->V7_DTINI)  .And. !Empty((cAliasTmp)->V7_DTFIM) .And.; //caso a data de início e fim estejam dentro do período  
			(cAliasTmp)->V7_DTINI >= MV_PAR03 .and. (cAliasTmp)->V7_DTFIM <= MV_PAR04

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= ( ( (cAliasTmp)->V7_DTFIM - (cAliasTmp)->V7_DTINI) +1)
			Else
				nDiasSit := (30 - ( ( (cAliasTmp)->V7_DTFIM - (cAliasTmp)->V7_DTINI) +1) )
			EndIf

		ElseIf !Empty((cAliasTmp)->V7_DTINI)  .And. ; //caso a data de início esteja entre os peródos e a data final sendo maior do que a do período.
			((cAliasTmp)->V7_DTINI >= MV_PAR03 .And. (cAliasTmp)->V7_DTINI <= MV_PAR04 .AND. ((cAliasTmp)->V7_DTFIM >= MV_PAR04 .OR. EMPTY((cAliasTmp)->V7_DTFIM)) )
				
			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (30 - ((cAliasTmp)->V7_DTINI - MV_PAR03) ) 
			Else
				nDiasSit := ( 30 -(30 - ((cAliasTmp)->V7_DTINI - MV_PAR03) ) )
			EndIf
			
		ElseIf !Empty((cAliasTmp)->V7_DTFIM) .AND.; // caso a data fim esteja entre os peródos e a data inical sendo menor do que a do período.
			( (cAliasTmp)->V7_DTINI <= MV_PAR03 .And. (cAliasTmp)->V7_DTFIM >= MV_PAR03 .AND. (cAliasTmp)->V7_DTFIM <= MV_PAR04) 
			
			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( V7_DTFIM - MV_PAR03) +1)
			Else
				nDiasSit := (30 - (( (cAliasTmp)->V7_DTFIM - MV_PAR03) +1))
			EndIf

		EndIf

		// Validação nas datas da TXB
		If !Empty((cAliasTmp)->TXB_CODTEC) .And. ;  // Exista informação na TXB restrição de RH  
		!Empty((cAliasTmp)->TXB_DTINI)  .And. !Empty((cAliasTmp)->TXB_DTFIM) .And.; //caso a data de início e fim estejam dentro do período  
			(cAliasTmp)->TXB_DTINI >= MV_PAR03 .and. (cAliasTmp)->TXB_DTFIM <= MV_PAR04

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= ( ( (cAliasTmp)->TXB_DTFIM - (cAliasTmp)->TXB_DTINI) +1)
			Else
				nDiasSit := (30 - ( ( (cAliasTmp)->TXB_DTFIM - (cAliasTmp)->TXB_DTINI) +1) )
			EndIf

		ElseIf !Empty((cAliasTmp)->TXB_DTINI)  .And. ; //caso a data de início esteja entre os peródos e a data final sendo maior do que a do período.
			((cAliasTmp)->TXB_DTINI >= MV_PAR03 .And. (cAliasTmp)->TXB_DTINI <= MV_PAR04 .AND. ((cAliasTmp)->TXB_DTFIM >= MV_PAR04 .OR. EMPTY((cAliasTmp)->TXB_DTFIM)) )
				
			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (30 - ((cAliasTmp)->TXB_DTINI - MV_PAR03) ) 
			Else
				nDiasSit := ( 30 -(30 - ((cAliasTmp)->TXB_DTINI - MV_PAR03) ) )
			EndIf
			
		ElseIf !Empty((cAliasTmp)->TXB_DTFIM) .AND.; // caso a data fim esteja entre os peródos e a data inical sendo menor do que a do período.
			( (cAliasTmp)->TXB_DTINI <= MV_PAR03 .And. (cAliasTmp)->TXB_DTFIM >= MV_PAR03 .AND. (cAliasTmp)->TXB_DTFIM <= MV_PAR04) 

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( TXB_DTFIM - MV_PAR03) +1)
			Else
				nDiasSit := (30 - (( (cAliasTmp)->TXB_DTFIM - MV_PAR03) +1))
			EndIf

		EndIf
	Else

		If nAdmDem == 0 //caso tenha admissão ou demissão no período e ter dois afastamentos, calcular somente uma vez a demissão/admissão
			// a rotina funcionará diante do primeiro e último dia do MV_PAR05 
			If !Empty((cAliasTmp)->RA_ADMISSA)  .And. !Empty((cAliasTmp)->RA_DEMISSA) .And.; // caso seja admitido e demitido durante o período 
				((cAliasTmp)->RA_ADMISSA > MV_PAR05 .and.  (cAliasTmp)->RA_DEMISSA <= dFimMes)
				nDiasSit := (((cAliasTmp)->RA_DEMISSA - (cAliasTmp)->RA_ADMISSA ) +1) 

			ElseIf !Empty((cAliasTmp)->RA_ADMISSA)  .AND. ((cAliasTmp)->RA_ADMISSA > MV_PAR05 .AND. (cAliasTmp)->RA_ADMISSA <= dFimMes) //caso tenha sido admitido no período 
				nDiasSit := (nDiaFim - (((cAliasTmp)->RA_ADMISSA) - MV_PAR05))
			
			ElseIf !Empty((cAliasTmp)->RA_DEMISSA) .AND. ( (cAliasTmp)->RA_DEMISSA > MV_PAR05 .AND. (cAliasTmp)->RA_DEMISSA <= dFimMes) //caso tenha sido demitido no período
				If ( (cAliasTmp)->RA_DEMISSA - MV_PAR05) == 30
					nDiasSit := 30
				Else
					nDiasSit := (( (cAliasTmp)->RA_DEMISSA - MV_PAR05) +1)
				EndIf			
			EndIf

			nAdmDem++
		EndIf

		// Validação nas datas da SRH - Férias
		If !Empty((cAliasTmp)->RH_MAT) .And. ;  // Exista informação na SRH 
		!Empty((cAliasTmp)->RH_DATABAS)  .And. !Empty((cAliasTmp)->RH_DBASEAT) .And.; //caso a data de início e fim estejam dentro do período  
			(cAliasTmp)->RH_DATABAS >= MV_PAR05 .and. (cAliasTmp)->RH_DBASEAT <= dFimMes

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= ( ( (cAliasTmp)->RH_DBASEAT - (cAliasTmp)->RH_DATABAS) +1)
			Else
				nDiasSit := (nDiaFim - ( ( (cAliasTmp)->RH_DBASEAT - (cAliasTmp)->RH_DATABAS) +1) )
			EndIf

		ElseIf !Empty((cAliasTmp)->RH_DATABAS)  .And. ; //caso a data de início esteja entre os peródos e a data final sendo maior do que a do período.
			((cAliasTmp)->RH_DATABAS >= MV_PAR05 .And. (cAliasTmp)->RH_DATABAS <= dFimMes .AND. (cAliasTmp)->RH_DBASEAT >= dFimMes)
				
			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (nDiaFim - ((cAliasTmp)->RH_DATABAS - MV_PAR05) ) 
			Else
				nDiasSit := ( 30 - (nDiaFim - (((cAliasTmp)->RH_DATABAS - MV_PAR05) +1 ) +1) )
			EndIf
			
		ElseIf !Empty((cAliasTmp)->RH_DBASEAT) .AND.; // caso a data fim esteja entre os peródos e a data inical sendo menor do que a do período.
			( (cAliasTmp)->RH_DATABAS <= MV_PAR05 .And. (cAliasTmp)->RH_DBASEAT >= MV_PAR05 .AND. (cAliasTmp)->RH_DBASEAT <= MV_PAR05) 

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( (cAliasTmp)->RH_DBASEAT - MV_PAR05) +1)
			Else
				nDiasSit := (30 - (( (cAliasTmp)->RH_DBASEAT - MV_PAR05) +1))
			EndIf

		EndIf

		//Validação na SRF para a data inicial 
		If !Empty((cAliasTmp)->RF_MAT) .And. ;  // Exista informação na SRF
		!Empty((cAliasTmp)->RF_DATAINI) .And. ; //caso a data de início e fim estejam dentro do período  
			((cAliasTmp)->RF_DATAINI >= MV_PAR05 .and. ( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 ) <= dFimMes)
			
			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( ( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 ) - (cAliasTmp)->RF_DATAINI) +1)
			Else
				nDiasSit := (nDiaFim - (( ( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 ) - (cAliasTmp)->RF_DATAINI) +1))
			EndIf
			
		ElseIf !Empty((cAliasTmp)->RF_DATAINI)  .And. ; //caso a data de início esteja entre os peródos e a data final sendo maior do que a do período.
			((cAliasTmp)->RF_DATAINI >= MV_PAR05 .And. ( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 ) <= dFimMes .AND. ( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 ) >= dFimMes)
				
			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (nDiaFim - ((cAliasTmp)->RF_DATAINI - MV_PAR05) ) 
			Else
				nDiasSit := ( 30 - (nDiaFim - (((cAliasTmp)->RF_DATAINI - MV_PAR05) +1 ) +1) )
			EndIf
			
		ElseIf !Empty(( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 )) .AND.; // caso a data fim esteja entre os peródos e a data inical sendo menor do que a do período.
			( (cAliasTmp)->RF_DATAINI <= MV_PAR05 .And. ( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 ) >= MV_PAR05 .AND. ( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 ) <= dFimMes) 

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( ( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 ) - MV_PAR05) +1)
			Else
				nDiasSit := (30 - (( ( (cAliasTmp)->RF_DATAINI + (cAliasTmp)->RF_DFEPRO1 ) - MV_PAR05) +1))  
			EndIf

		EndIf
		//Validação na SRF para a data inicial 2
		If !Empty((cAliasTmp)->RF_MAT) .And. ;  // Exista informação na SRF
		!Empty((cAliasTmp)->RF_DATINI2) .And. ; //caso a data de início e fim estejam dentro do período  
			((cAliasTmp)->RF_DATINI2 >= MV_PAR05 .and. ( (cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 ) <= dFimMes)

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( ( (cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 ) - (cAliasTmp)->RF_DATINI2) +1)
			Else
				nDiasSit := (nDiaFim - (( ( (cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 ) - (cAliasTmp)->RF_DATINI2) +1))
			EndIf

		ElseIf !Empty((cAliasTmp)->RF_DATINI2)  .And. ; //caso a data de início esteja entre os peródos e a data final sendo maior do que a do período.
			((cAliasTmp)->RF_DATINI2 >= MV_PAR05 .And. ( (cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 ) <= dFimMes .AND. ( (cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 ) >= dFimMes)
				
			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (nDiaFim - ((cAliasTmp)->RF_DATINI2 - MV_PAR05) ) 
			Else
				nDiasSit := ( 30 - (nDiaFim - (((cAliasTmp)->RF_DATINI2 - MV_PAR05) +1 ) +1) )
			EndIf
			
		ElseIf !Empty( ((cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 )) .AND.; // caso a data fim esteja entre os peródos e a data inical sendo menor do que a do período.
			((cAliasTmp)->RF_DATINI2 <= MV_PAR05 .And. ( (cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 ) >= MV_PAR05 .AND. ( (cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 ) <= dFimMes) 

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( ( (cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2 ) - MV_PAR05) +1)
			Else
				nDiasSit := (30 - (( ( (cAliasTmp)->RF_DATINI2 + (cAliasTmp)->RF_DFEPRO2) - MV_PAR05) +1))  
			EndIf

		EndIf

		//Validação na SRF para a data inicial 3 
		If !Empty((cAliasTmp)->RF_MAT) .And. ;  // Exista informação na SRF
		!Empty((cAliasTmp)->RF_DATINI3) .And. ; //caso a data de início e fim estejam dentro do período  
			((cAliasTmp)->RF_DATINI3 >= MV_PAR05 .and. ( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 ) <= dFimMes)

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( ( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 ) - (cAliasTmp)->RF_DATINI3) +1)
			Else
				nDiasSit := (nDiaFim - (( ( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 ) - (cAliasTmp)->RF_DATINI3) +1))
			EndIf

		ElseIf !Empty((cAliasTmp)->RF_DATINI3)  .And. ; //caso a data de início esteja entre os peródos e a data final sendo maior do que a do período.
			((cAliasTmp)->RF_DATINI3 >= MV_PAR05 .And. ( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 ) <= dFimMes .AND. ( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 ) >= dFimMes)
				
			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (nDiaFim - ((cAliasTmp)->RF_DATINI3 - MV_PAR05) ) 
			Else
				nDiasSit := ( 30 - (nDiaFim - (((cAliasTmp)->RF_DATINI3 - MV_PAR05) +1 ) +1) )
			EndIf
			
		ElseIf !Empty(( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 )) .AND.; // caso a data fim esteja entre os peródos e a data inical sendo menor do que a do período.
			((cAliasTmp)->RF_DATINI3 <= MV_PAR05 .And. ( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 ) >= MV_PAR05 .AND. ( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 ) <= dFimMes) 

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( ( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3 ) - MV_PAR05) +1)
			Else
				nDiasSit := (30 - (( ( (cAliasTmp)->RF_DATINI3 + (cAliasTmp)->RF_DFEPRO3) - MV_PAR05) +1))  
			EndIf

		EndIf

		// Validação nas datas da SR8
		If !Empty((cAliasTmp)->R8_MAT) .And. ;  // Exista informação na SR8 
		!Empty((cAliasTmp)->R8_DATAINI)  .And. !Empty((cAliasTmp)->R8_DATAFIM) .And.; //caso a data de início e fim estejam dentro do período  
			(cAliasTmp)->R8_DATAINI >= MV_PAR05 .and. (cAliasTmp)->R8_DATAFIM <= dFimMes

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= ( ( (cAliasTmp)->R8_DATAFIM - (cAliasTmp)->R8_DATAINI) +1)
			Else
				nDiasSit := (nDiaFim - ( ( (cAliasTmp)->R8_DATAFIM - (cAliasTmp)->R8_DATAINI) +1) )
			EndIf

		ElseIf !Empty((cAliasTmp)->R8_DATAINI)  .And. ; //caso a data de início esteja entre os peródos e a data final sendo maior do que a do período.
			((cAliasTmp)->R8_DATAINI >= MV_PAR05 .And. (cAliasTmp)->R8_DATAINI <= dFimMes .AND. ((cAliasTmp)->R8_DATAFIM >= dFimMes .OR. EMPTY((cAliasTmp)->R8_DATAFIM)) )
				
			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (nDiaFim - ((cAliasTmp)->R8_DATAINI - MV_PAR05) ) 
			Else
				nDiasSit := ( 30 - (nDiaFim - (((cAliasTmp)->R8_DATAINI - MV_PAR05) +1 ) +1) )
			EndIf
			
		ElseIf !Empty((cAliasTmp)->R8_DATAFIM) .AND.; // caso a data fim esteja entre os peródos e a data inical sendo menor do que a do período.
			( (cAliasTmp)->R8_DATAINI <= MV_PAR05 .And. (cAliasTmp)->R8_DATAFIM >= MV_PAR05 .AND. (cAliasTmp)->R8_DATAFIM <= dFimMes) 

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( (cAliasTmp)->R8_DATAFIM - MV_PAR05) +1)
			Else
				nDiasSit := (30 -(( (cAliasTmp)->R8_DATAFIM - MV_PAR05) +1))
			EndIf

		EndIf

		// Validação nas datas da SV7
		If !Empty((cAliasTmp)->V7_MAT) .And. ;  // Exista informação na SV7 intermitente
		!Empty((cAliasTmp)->V7_DTINI)  .And. !Empty((cAliasTmp)->V7_DTFIM) .And.; //caso a data de início e fim estejam dentro do período  
			(cAliasTmp)->V7_DTINI >= MV_PAR05 .and. (cAliasTmp)->V7_DTFIM <= dFimMes

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= ( ( (cAliasTmp)->V7_DTFIM - (cAliasTmp)->V7_DTINI) +1)
			Else
				nDiasSit := (nDiaFim - ( ( (cAliasTmp)->V7_DTFIM - (cAliasTmp)->V7_DTINI) +1) )
			EndIf

		ElseIf !Empty((cAliasTmp)->V7_DTINI)  .And. ; //caso a data de início esteja entre os peródos e a data final sendo maior do que a do período.
			((cAliasTmp)->V7_DTINI >= MV_PAR05 .And. (cAliasTmp)->V7_DTINI <= dFimMes .AND. ((cAliasTmp)->V7_DTFIM >= dFimMes .OR. EMPTY((cAliasTmp)->V7_DTFIM)) )
				
			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (nDiaFim - ((cAliasTmp)->V7_DTINI - MV_PAR05) ) 
			Else
				nDiasSit := ( 30 - (nDiaFim - (((cAliasTmp)->V7_DTINI - MV_PAR05) +1 ) +1) )
			EndIf
			
		ElseIf !Empty((cAliasTmp)->V7_DTFIM) .AND.; // caso a data fim esteja entre os peródos e a data inical sendo menor do que a do período.
			( (cAliasTmp)->V7_DTINI <= MV_PAR05 .And. (cAliasTmp)->V7_DTFIM >= MV_PAR05 .AND. (cAliasTmp)->V7_DTFIM <= dFimMes) 
			
			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( (cAliasTmp)->V7_DTFIM - MV_PAR05) +1)
			Else
				nDiasSit := (30 -(( (cAliasTmp)->V7_DTFIM - MV_PAR05) +1))
			EndIf

		EndIf

		// Validação nas datas da TXB
		If !Empty((cAliasTmp)->TXB_CODTEC) .And. ;  // Exista informação na TXB restrição de RH  
		!Empty((cAliasTmp)->TXB_DTINI)  .And. !Empty((cAliasTmp)->TXB_DTFIM) .And.; //caso a data de início e fim estejam dentro do período  
			(cAliasTmp)->TXB_DTINI >= MV_PAR05 .and. (cAliasTmp)->TXB_DTFIM <= dFimMes

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= ( ( (cAliasTmp)->TXB_DTFIM - (cAliasTmp)->TXB_DTINI) +1)
			Else
				nDiasSit := (nDiaFim - ( ( (cAliasTmp)->TXB_DTFIM - (cAliasTmp)->TXB_DTINI) +1) )
			EndIf

		ElseIf !Empty((cAliasTmp)->TXB_DTINI)  .And. ; //caso a data de início esteja entre os peródos e a data final sendo maior do que a do período.
			((cAliasTmp)->TXB_DTINI >= MV_PAR05 .And. (cAliasTmp)->TXB_DTINI <= dFimMes .AND. ((cAliasTmp)->TXB_DTFIM >= dFimMes .OR. EMPTY((cAliasTmp)->TXB_DTFIM)))
				
				If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (nDiaFim - ((cAliasTmp)->TXB_DTINI - MV_PAR05) ) 
			Else
				nDiasSit := ( 30 - (nDiaFim - (((cAliasTmp)->TXB_DTINI - MV_PAR05) +1 ) +1) )
			EndIf
			
		ElseIf !Empty((cAliasTmp)->TXB_DTFIM) .AND.; // caso a data fim esteja entre os peródos e a data inical sendo menor do que a do período.
			( (cAliasTmp)->TXB_DTINI <= MV_PAR05 .And. (cAliasTmp)->TXB_DTFIM >= MV_PAR05 .AND. (cAliasTmp)->TXB_DTFIM <= dFimMes) 

			If nDiasSit > 0 // caso seja maior que 0 será o nDiasSit - dias de restrição
				nDiasSit -= (( (cAliasTmp)->TXB_DTFIM - MV_PAR05) +1)
			Else
				nDiasSit := (30 -(( (cAliasTmp)->TXB_DTFIM - MV_PAR05) +1))
			EndIf

		EndIf

	EndIf	

	(cAliasTmp)->(DbSkip())
EndDo	

(cAliasTmp)->(DbCloseArea())

Return nDiasSit 

//-------------------------------------------------------------------
/*/{Protheus.doc} VldComp
Função para validação da competência

@author Junior.Santos
@since 17/11/2020
@version P12
/*/
//-------------------------------------------------------------------
Function VldComp()
Local lRet	:= .T.

If (Vazio() .Or. Substr(MV_PAR05,1,2) > "12" .Or. Len(AllTrim(Substr(MV_PAR05,4))) < 4)
	Help(" ",1,"VldComp",,STR0026,1,0) // Competência de início inválida
	lRet := .F.
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} Tec353HrRs
Retorna a quantidade de horas de um determinado atendente

@author boiani
@since 20/11/2020
/*/
//-------------------------------------------------------------------
Function Tec353HrRs(cFilSRA, cMat, dDtIni, dDtFim)
Local cQry := GetNextAlias()
Local aRet := {}
Local nX
Local aAreaRGB := RGB->(getArea())
Local aArea := GetArea()

a353HrRs := {}

BeginSQL Alias cQry
	SELECT AA1.AA1_CODTEC
	FROM %Table:AA1% AA1
	WHERE AA1.AA1_FILIAL = %xFilial:AA1%
		AND AA1.%NotDel%
		AND AA1.AA1_CDFUNC = %Exp:cMat%
		AND AA1.AA1_FUNFIL = %Exp:cFilSRA%
EndSQL

If !(cQry)->(EOF())
	MV_PAR01 := (cQry)->(AA1_CODTEC)
	MV_PAR02 := (cQry)->(AA1_CODTEC)
	MV_PAR03 := dDtIni
	MV_PAR04 := dDtFim
	MV_PAR05 := STRZERO(Month(dDtIni),2) + "/" + LEFT(DTOS(dDtIni),4)
	MV_PAR06 := 1
	MV_PAR07 := 2
	MV_PAR08 := 1
	At353Gera(.T.)
	If !EMPTY(a353HrRs)
		For nX := 1 To LEN(a353HrRs)
			If a353HrRs[nX][1][2] == cFilSRA .AND. a353HrRs[nX][2][2] == cMat
				If EMPTY(aRet) .OR. (nAux := ASCAN(aRet, {|a| a[1] == a353HrRs[nX][4][2]})) == 0
					AADD(aRet, {a353HrRs[nX][4][2], a353HrRs[nX][6][2]})
				Else
					aRet[nAux][2] += a353HrRs[nX][6][2]
				EndIf
			EndIf
		Next nX
	EndIf
EndIf
(cQry)->(DbCloseArea())

RestArea(aAreaRGB)
RestArea(aArea)

Return aRet

