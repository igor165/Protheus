#Include "PLSMGER.CH"
#Include "PROTHEUS.CH"

static lAutoSt := .F.

//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSA982Cal
Validacoes antes de Calcular o Auto-Gerado
@author Thiago Machado Correa
@since 08/2004
@version P12 
/*/
//-------------------------------------------------------------------
Function Plsa982Cal(lAuto)

Local cOperad := ""
Local cAno    := ""
Local cMes    := ""
Local cRdaIni := ""
Local cRdaFim := "" 
Local cModali := ""
Local cSequen := ""
LOCAL dDataDe := ctod("")
LOCAL dDataAte:= ctod("")
LOCAL nArred  := "1"
default lAuto := .F.

lAuto := iif( valtype(lAuto) <> "L", .f., lAuto )	

lAutoSt := lAuto

// Atualiza as variaveis do pergunte...
If lAuto
	Pergunte("PLA982",.F.)
else
	If !Pergunte("PLA982")
		Return
	EndIf	   
endif
cOperad := mv_par01
cAno    := mv_par02
cMes    := mv_par03
cRdaIni := mv_par04
cRdaFim := mv_par05
cModali := mv_par06
dDataDe := mv_par07
dDataAte:= mv_par08
nArred  := mv_par09
 
If lAuto
	cOperad := "0001"
	cAno    := "2020"
	cMes    := "12"
	cRdaIni := "      "
	cRdaFim := "ZZZZZZ"
	cModali := "PP"
	dDataDe := CtoD("01/12/2020")
	dDataAte:= CtoD("31/12/2020")
	nArred  := 1
endif

// Valida o pergunte...
If !lAuto .AND. Len(alltrim(cAno)) == 0
	MsgAlert("Informe o Ano!")
	Return
Endif

If !lAuto .AND. Len(alltrim(cMes)) == 0
	MsgAlert("Informe o Mes!")
	Return
Endif

If !lAuto .AND. Len(alltrim(cRdaIni+cRdaFim)) == 0
	MsgAlert("Informe a Rda!")
	Return
Endif

If !lAuto .AND. Len(alltrim(cModali)) == 0
	MsgAlert("Informe a Modalidade!")
	Return
Endif

// Valida Sequencial...
cSQL := " SELECT MAX(BYM_SEQUEN) MAX FROM " + RetSqlName("BYM")
cSQL += " WHERE BYM_FILIAL = '" + xFilial("BYM") + "' AND "
cSQL +=       " BYM_COMPET = '" + cAno + cMes + "' AND "
cSQL += " D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSQL),"TRBBYM", .F., .T.)

If !lAuto .AND. TRBBYM->MAX == "99"
	MsgAlert("Limite de Lotes de Auto-Gerados esgotado para esta competencia.") 
    TRBBYM->(DbCloseArea())
	Return
Else
	cSequen := strzero((val(TRBBYM->MAX)+1),2)
Endif

TRBBYM->(DbCloseArea())

If !lAuto .AND. MsgYesNo("Confirma geracao do Lote de Auto-Gerados?")
	RptStatus( {|| PLSA983Cal(cOperad,cAno,cMes,cRdaIni,cRdaFim,cModali,cSequen,dDataDe,dDataAte,nArred) },"Lote de Auto-Gerado","Processando...")
elseif lAuto
	PLSA983Cal(cOperad,cAno,cMes,cRdaIni,cRdaFim,cModali,cSequen,dDataDe,dDataAte,nArred)
Endif
Return


//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSA983Cal
Calcula o Auto-Gerado
@author Thiago Machado Correa
@since 09/2004
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSA983Cal(cOperad,cAno,cMes,cRdaIni,cRdaFim,cModali,cSequen,dDataDe,dDataAte,nArred)

Local cQuery1 := ""
Local cQuery2 := ""
Local cSql    := ""
Local cCodRda := ""
Local cCodEsp := ""
Local cCodSol := ""
Local cChave  := ""
Local cChaBD6 := ""
Local nQtdCon := 0
Local nTotCon := 0
Local nTmp    := 0
Local nQtdMax := 0
Local nPos    := 0
Local nReg    := 0
Local nTotRda := 0
Local nNiveis := 0
Local nFor    := 0   
Local nDifere := 0
Local nQtdBlq := 0
Local nQtdDes := 0            
Local nTipoAG := 0
Local aRetQ   := {}
Local aProc   := {}
Local aReg    := {}
Local aProRes := {}
Local aPresta := {} 
Local aAGNive := {}
Local aCopRes := {}
Local lContin := .T.
Local lBD7	  := .T.
Local lAchou  := .T.                   
Local lGrava  := .T.
Local lPLS982IG := ExistBlock("PLS982IG")

Local lQryBD7 	:= .T.
Local cQryBD7	:= ""
Local cChvBD7	:= ""
Local cTrbBD7	:= ""
Local cTabBD7	:= ""
Local nRetBD7	:= 0
Local aCampos	:= {}
local oTempTable := nil

aRetQ := PLSRQCon("BD6_CODPAD","BD6_CODPRO")

cQuery1 := aRetQ[1]
cQuery2 := aRetQ[2]

// Ordena arquivos...
BYM->(DbSetOrder(1)) //Lote de Auto-Gerado
BMY->(DbSetOrder(1)) //Regras de Auto-Gerado x Especialidade
BD6->(DbSetOrder(1)) //Itens das Contas
BD7->(DbSetOrder(1)) //Itens de Pagamento das Contas
BAU->(DbSetOrder(1)) //Rda
BT5->(DbSetOrder(1)) //Contrato
BI3->(DbSetOrder(1)) //Produto
BB0->(DbSetOrder(4)) // Profissional da Saude

// Seleciona registros para regua...
cSQL := " SELECT COUNT(*) QTD FROM " + RetSqlName("BBF")
cSQL += " WHERE BBF_FILIAL = '"  + xFilial("BBF") + "' AND "
cSQL +=       " BBF_CODINT =  '" + cOperad + "' AND "
cSQL +=       " BBF_CODIGO >= '" + cRdaIni + "' AND "
cSQL +=       " BBF_CODIGO <= '" + cRdaFim + "' AND "
cSQL += " D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSQL),"TRBBBF", .F., .T.)

// Prepara Regua...
If !lAutoSt
	SetRegua(TRBBBF->QTD)
endif

// Fecha Temporario...
TRBBBF->(DbCloseArea())

// Seleciona todas Rda X Especialidade da Operadora...
cSQL := " SELECT BBF_CODIGO, BBF_CDESP FROM " + RetSqlName("BBF")
cSQL += " WHERE BBF_FILIAL = '"  + xFilial("BBF") + "' AND "
cSQL +=       " BBF_CODINT =  '" + cOperad + "' AND "
cSQL +=       " BBF_CODIGO >= '" + cRdaIni + "' AND "
cSQL +=       " BBF_CODIGO <= '" + cRdaFim + "' AND "
cSQL += " D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY BBF_CODIGO,BBF_CODINT,BBF_CDESP "
dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSQL),"TRBBBF", .F., .T.)


//Criação da Tabela Temporária
cTrbBD7 := getNextAlias()
oTempTable := FWTemporaryTable():New( cTrbBD7 )

//--------------------------
//Monta os campos da tabela
//--------------------------
aCampos := {}
aadd(aCampos,{"BD7_FILIAL","C",TamSX3("BD7_FILIAL")[1],0})
aadd(aCampos,{"BD7_CODOPE","C",TamSX3("BD7_CODOPE")[1],0})
aadd(aCampos,{"BD7_CODLDP","C",TamSX3("BD7_CODLDP")[1],0})
aadd(aCampos,{"BD7_CODPEG","C",TamSX3("BD7_CODPEG")[1],0})
aadd(aCampos,{"BD7_NUMERO","C",TamSX3("BD7_NUMERO")[1],0})
aadd(aCampos,{"BD7_ORIMOV","C",TamSX3("BD7_ORIMOV")[1],0})
aadd(aCampos,{"BD7_SEQUEN","C",TamSX3("BD7_SEQUEN")[1],0})
aadd(aCampos,{"BD7_CODESP","C",TamSX3("BD7_CODESP")[1],0})
aadd(aCampos,{"BD7_CODPAD","C",TamSX3("BD7_CODPAD")[1],0})
aadd(aCampos,{"BD7_CODPRO","C",TamSX3("BD7_CODPRO")[1],0})

oTemptable:SetFields( aCampos )
oTempTable:AddIndex("01", {"BD7_CODESP","BD7_CODPAD","BD7_CODPRO"} )
oTempTable:Create()

//Recuperar o nome fisico da tabela temporaria criada no Banco de Dados
cTabBD7 := oTempTable:GetRealName()

While TRBBBF->(!Eof())
	
	aProc   := {}
	aReg    := {}
   	cCodRDA := TRBBBF->BBF_CODIGO
    cCodEsp := TRBBBF->BBF_CDESP
	
	// Incrementa Regua...
	If !lAutoSt
		IncRegua()
	endif
	
	nPos := Ascan(aPresta, cCodRda)
	
	If nPos == 0
		aadd(aPresta,cCodRda)
	Endif

	// Posiciona BAU...
	BAU->(DbSetOrder(1))
    If ! BAU->(DbSeek(xFilial("BAU")+cCodRda))
    	TRBBBF->(DbSkip())
    	Loop		    	
    Endif          
	
	// Verifica RDA parametrizada para nao ser tratada no auto-gerado
    If  BAU->BAU_AUTGER == "0"
    	TRBBBF->(DbSkip())
    	Loop		    	
    Endif          
    
	BAU->(DbSetOrder(5))

  	cCodSol := BAU->BAU_CODBB0
    
	// Seleciona todas as regras de Auto-Gerado para a Especialidade...
    If lautoSt .OR. BMY->(DbSeek(xFilial("BMY")+cOperad+cCodEsp))
    	
		For nFor := 1 To 2
			If nFor == 1
				
				// Pessoa Juridica...
				cSQL := " UPDATE " + RetSqlName("BD6") + " SET BD6_LOTEAG = '" + cSequen+cAno+cMes + "' "
				cSQL += " WHERE R_E_C_N_O_ IN ("
				cSQL += " 	SELECT BD6.R_E_C_N_O_ "
				cSQL += " 	FROM " + RetSqlName("BD6") + " BD6 "
				//--------------------------------------------------------
				cSQL += " 	INNER JOIN " + RetSqlName("BT5") + " BT5 "
				cSQL += "		ON  BT5_FILIAL = '" + xFilial("BT5") + "' "
				cSQL += "		AND BT5_CODINT = BD6_OPEUSR "
				cSQL += "		AND BT5_CODIGO = BD6_CODEMP "
				cSQL += "		AND BT5_NUMCON = BD6_CONEMP "
				cSQL += "		AND BT5_VERSAO = BD6_VERCON "
				If !("IN" $ cModali)
					cSQL += "	AND NOT (BT5_INTERC =  '1') "
				EndIf
				cSQL += "		AND BT5.D_E_L_E_T_ = '' "
				//--------------------------------------------------------
				cSQL += " 	INNER JOIN " + RetSqlName("BI3") + " BI3 "
				cSQL += "		ON  BI3_FILIAL = '" + xFilial("BI3") + "' "
				cSQL += "		AND BI3_CODINT = BD6_OPEUSR "
				cSQL += "		AND BI3_CODIGO = BD6_CODPLA "
				If !("PP" $ cModali)
					cSQL += "	AND NOT (BI3_MODPAG =  '1') "
				EndIf
				If !("CO" $ cModali)
					cSQL += "	AND NOT (BI3_MODPAG <> '1') "
				EndIf
				cSQL += "		AND BI3.D_E_L_E_T_ = '' "
				//--------------------------------------------------------
				cSQL += " 	WHERE BD6_FILIAL = '" + xFilial("BD6") 	+ "' AND "
				cSQL += " 		BD6_CODOPE =  '" + cOperad 			+ "' AND "
				cSQL += " 		BD6_CODESP =  '" + cCodEsp 			+ "' AND "
				cSQL += " 		BD6_OPERDA =  '" + cOperad 			+ "' AND "
				cSQL += " 		BD6_CODRDA =  '" + cCodRDA 			+ "' AND "
				cSQL += " 		BD6_MESPAG =  '" + cMes    			+ "' AND "
				cSQL += " 		BD6_ANOPAG =  '" + cAno    			+ "' AND "
				cSQL += " 		BD6_DATPRO >= '" + dtos(dDataDe)	+ "' AND "
				cSQL += " 		BD6_DATPRO <= '" + dtos(dDataAte)	+ "' AND "
				cSQL += " 		BD6_CONEMP <> ' ' AND "
				cSQL += " 		BD6_LOTEAG =  '        ' AND "
				cSQL += " 		BD6_OPELOT =  '    ' AND "
				cSQL += " 		BD6_FASE   =  '3' AND "
				cSQL += " 		BD6_SITUAC =  '1' AND "
				cSQL += cQuery1 + " AND " + cQuery2 + " AND "
				cSQL += " BD6.D_E_L_E_T_ = ' ' )"
				
				If TCSQLExec(cSQL) < 0
					FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', "TCSQLError() " + TCSQLError() , 0, 0, {})
				ElseIf SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
					TCSQLExec("COMMIT")
				EndIf
			Else
			
				// Pessoa Fisica...													 
				cSQL := " UPDATE " + RetSqlName("BD6") + " SET BD6_LOTEAG = '" + cSequen+cAno+cMes + "' "
				cSQL += " WHERE R_E_C_N_O_ IN ("
				cSQL += " 	SELECT BD6.R_E_C_N_O_ "
				cSQL += " 	FROM " + RetSqlName("BD6") + " BD6 "
				//--------------------------------------------------------
				cSQL += " 	INNER JOIN " + RetSqlName("BI3") + " BI3 "
				cSQL += "		ON  BI3_FILIAL = '" + xFilial("BI3") + "' "
				cSQL += "		AND BI3_CODINT = BD6_OPEUSR "
				cSQL += "		AND BI3_CODIGO = BD6_CODPLA "
				If !("PP" $ cModali)
					cSQL += "	AND NOT (BI3_MODPAG =  '1') "
				EndIf
				If !("CO" $ cModali)
					cSQL += "	AND NOT (BI3_MODPAG <> '1') "
				EndIf
				cSQL += "		AND BI3.D_E_L_E_T_ = '' "
				//--------------------------------------------------------
				cSQL += " 	WHERE BD6_FILIAL = '" + xFilial("BD6") 	+ "' AND "
				cSQL += " 		BD6_CODOPE =  '" + cOperad 			+ "' AND "
				cSQL += " 		BD6_CODESP =  '" + cCodEsp 			+ "' AND "
				cSQL += " 		BD6_OPERDA =  '" + cOperad 			+ "' AND "
				cSQL += " 		BD6_CODRDA =  '" + cCodRDA 			+ "' AND "
				cSQL += " 		BD6_MESPAG =  '" + cMes    			+ "' AND "
				cSQL += " 		BD6_ANOPAG =  '" + cAno    			+ "' AND "
				cSQL += " 		BD6_DATPRO >= '" + dtos(dDataDe)	+ "' AND "
				cSQL += " 		BD6_DATPRO <= '" + dtos(dDataAte)	+ "' AND "
				cSQL += " 		BD6_CONEMP =  ' ' AND "
				cSQL += " 		BD6_LOTEAG =  '        ' AND "
				cSQL += " 		BD6_OPELOT =  '    ' AND "
				cSQL += " 		BD6_FASE   =  '3' AND "
				cSQL += " 		BD6_SITUAC =  '1' AND "
				cSQL += cQuery1 + " AND " + cQuery2 + " AND "
				cSQL += " BD6.D_E_L_E_T_ = ' ' )"
				
				If TCSQLExec(cSQL) < 0
					FWLogMsg('ERROR',, 'SIGAPLS', funName(), '', '01', "TCSQLError() " + TCSQLError() , 0, 0, {})
				ElseIf SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
					TCSQLExec("COMMIT")
				EndIf
			EndIf
		Next nFor
			
		// Verifica o nro de consultas da Rda naquela Especialidade...
		cSQL := " SELECT SUM(BD6.BD6_QTDPRO) AS QTDPRO "
		cSQL += " FROM " + RetSqlName("BD6") + " BD6 "
		cSQL += " WHERE BD6.BD6_FILIAL = '" + xFilial("BD6") 	+ "' AND "
		cSQL += "		BD6.BD6_LOTEAG = '" + cSequen+cAno+cMes	+ "' AND "
		cSQL += " 		BD6.D_E_L_E_T_ = ' ' "
		dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSQL),"TRBBD6", .F., .T.)
		If TRBBD6->(!Eof())
			nQtdCon := TRBBD6->QTDPRO - nTotCon
		Else
			nQtdCon := 0
		EndIf
		nTotCon += nQtdCon
		
		// Fecha Temporario...
        TRBBD6->(DbCloseArea())

		// Verifica exames auto-gerados...
		cSQL := " SELECT BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, BD6_SEQUEN, BD6_CODPAD, BD6_CODPRO, BD6_QTDPRO, BD6_DATPRO, BD6_OPEUSR, BD6_CODEMP, BD6_CONEMP, BD6_VERCON, BD6_CODPLA, R_E_C_N_O_ REG FROM " + RetSqlName("BD6")
		cSQL += " WHERE BD6_FILIAL = '" + xFilial("BD6") + "' AND "
		cSQL +=       " BD6_CODOPE = '" + cOperad + "' AND "
		cSQL +=       " BD6_CODESP = '" + cCodEsp + "' AND "
		cSQL +=       " BD6_OPERDA = '" + cOperad + "' AND "
		cSQL +=       " BD6_CDPFSO = '" + cCodSol + "' AND "
		cSQL +=       " BD6_MESPAG = '" + cMes    + "' AND "
		cSQL +=       " BD6_ANOPAG = '" + cAno    + "' AND "
		cSQL +=       " BD6_DATPRO >= '"+dtos(dDataDe)+"'  AND "
		cSQL +=       " BD6_DATPRO <= '"+dtos(dDataAte)+"' AND "
		cSQL +=       " BD6_OPELOT = '    ' AND "
		cSQL +=       " BD6_FASE = '3' AND "
		cSQL +=       " BD6_SITUAC = '1' AND "
		cSQL += " (NOT(" + cQuery1 + " AND " + cQuery2 + ")) AND "
		cSQL += " D_E_L_E_T_ = ' ' "
		dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSQL),"TRBPRO", .F., .T.)

		While TRBPRO->(!Eof())        
			
			// Verifica Modalidade de Cobranca...
			If BT5->(DbSeek(xFilial("BT5")+TRBPRO->(BD6_OPEUSR+BD6_CODEMP+BD6_CONEMP+BD6_VERCON)))
				
				If BT5->BT5_INTERC == "1"
					
					// Intercambio...
					If ! ("IN" $ cModali)
						TRBPRO->(DbSkip())
						Loop
					Endif
				Else
					
					// Pessoa Juridica...
					If BI3->(DbSeek(xFilial("BI3")+TRBPRO->(BD6_OPEUSR+BD6_CODPLA)))
						
						If alltrim(BI3->BI3_MODPAG) == "1"
							If ! ("PP" $ cModali)
								TRBPRO->(DbSkip())
								Loop
							Endif
						Else
							If ! ("CO" $ cModali)
								TRBPRO->(DbSkip())
								Loop
							Endif
						Endif
						
					Else
						TRBPRO->(DbSkip())
						Loop
					Endif
				Endif
				
			Else
				
				// Pessoa Fisica...
				If BI3->(DbSeek(xFilial("BI3")+TRBPRO->(BD6_OPEUSR+BD6_CODPLA)))
					
					If alltrim(BI3->BI3_MODPAG) == "1"
						If ! ("PP" $ cModali)
							TRBPRO->(DbSkip())
							Loop
						Endif
					Else
						If ! ("CO" $ cModali)
							TRBPRO->(DbSkip())
							Loop
						Endif
					Endif
					
				Else
					TRBPRO->(DbSkip())
					Loop
				Endif
			Endif
   
            If lPLS982IG
               If ! ExecBlock("PLS982IG",.F.,.F.,{TRBPRO->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN),TRBPRO->(BD6_CODPLA),TRBPRO->(BD6_CODPAD+BD6_CODPRO)})
                  TRBPRO->(DbSkip())
                  Loop            
               Endif
            Endif
               
			lGrava := .F.
			cChave := (xFilial("BD7") + TRBPRO->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN))

			BD7->(DbSeek(cChave))

			While ! BD7->(Eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == cChave
				
				If ( (BD7->BD7_BLOPAG <> "1") .and. (BD7->BD7_FASE == "3") .and. (BD7->BD7_SITUAC == "1") .and. (Empty(BD7->BD7_LOTEAG))  .and.;
				     (BD7->BD7_CDPFPR == cCodSol) )

					lGrava := .T.

					// Marca exame como lido...
					BD7->(RecLock("BD7",.F.)) 
					BD7->BD7_LOTEAG := cSequen+cAno+cMes
					BD7->(MsUnlock())								

			    Endif
			    
				BD7->(DbSkip())
			EndDo

			If lGrava
				aadd(aProc,{TRBPRO->BD6_CODPAD, TRBPRO->BD6_CODPRO, TRBPRO->BD6_QTDPRO })
				aadd(aReg,{ len(aProc), TRBPRO->(REG) })
			Endif
			
			TRBPRO->(DbSkip())
	    EndDo

		// Fecha Temporario...
        TRBPRO->(DbCloseArea())

    Else
		TRBBBF->(DbSkip())
		Loop
    Endif
   
	// Cria array agrupando os procedimentos...
	aProRes := {}
	
	For nTmp := 1 to Len(aProc)
	
		nPos := Ascan(aProRes, {|x| x[1] = aProc[nTmp][1] .And. x[2] = aProc[nTmp][2] })
		
		If nPos > 0
			aProRes[nPos][3] += aProc[nTmp][3]
		Else
	    	aadd(aProRes,{})
	    	aProRes[Len(aProRes)] := aClone(aProc[nTmp])
	    Endif
	    
	Next

	// Verifica se os procedimentos possuem regra cadastrada...
   	For nTmp := 1 to Len(aProRes)
   	
		aAGNive := PLSEspNiv(aProRes[nTmp][1])
		nNiveis := (aAGNive[1]+1)
		lAchou  := .F.
		
		// Busca conforme o nivel do procedimento cadastrado na regra...
		For nFor := 1 To nNiveis
		
			If nFor == 1
		    	If BMY->(DbSeek(xFilial("BMY")+cOperad+cCodEsp+aProRes[nTmp][1]+aProRes[nTmp][2]))
		    		If BMY->BMY_NIVEL == strzero(nNiveis,1)
			    		lAchou  := .T.                      
			    		nTipoAG := val(BMY->BMY_ACAO)
			    	Endif	
				Endif
			Else
				If ! lAchou
			    	If BMY->(DbSeek(xFilial("BMY")+cOperad+cCodEsp+aProRes[nTmp][1]+Substr(aProRes[nTmp][2],aAGNive[2,(nFor-1),1],aAGNive[2,(nFor-1),2])))
			    		If aAGNive[2,(nFor-1),3] == BMY->BMY_NIVEL
				    		lAchou  := .T.
				    		nTipoAG := val(BMY->BMY_ACAO)
				    	Endif	
					Endif
				Endif	
			Endif
			
		Next

    	If lAchou
			 
			// Calcula o nro maximo de exames...
			nQtdMax := ((BMY->BMY_PERCEN/100)*(nQtdCon))
			
			// Trata arredondamento
            Do Case
               Case nArred == 1 // arredondamento padrao
		            nQtdMax := round(nQtdMax,0) 
               Case nArred == 2 // arredonda para cima
			        If  nQtdMax > int(nQtdMax)
			            nQtdMax := int(nQtdMax) + 1
			        Else
			            nQtdMax := int(nQtdMax)
			        Endif
               Case nArred == 3 // arredonda para baixo
		            nQtdMax := int(nQtdMax) 
            EndCase

			// Calcula a Diferenca..
			If aProRes[nTmp][3] > nQtdMax
				nDifere := aProRes[nTmp][3] - nQtdMax
				If nDifere < 0.5
					nDifere := 0
				Endif
			Else
				nDifere := nQtdMax - aProRes[nTmp][3]
				If nDifere < 0.5
					nDifere := 0
				Endif
			Endif	
            
			// Verifica se a diferenca eh valida...
 			If nDifere > 0
 			
				// Verifica se ultrapassou o Limite...
				If aProRes[nTmp][3] > nQtdMax
					
					lContin := .T.
					
					// Calcula a quantidade a descontar...
		            nDifere := aProRes[nTmp][3] - nQtdMax
		            nDifere := round(nDifere,0)
		            
					While lContin
						
						nPos := Ascan(aProc, {|x| x[1] = aProRes[nTmp][1] .And. x[2] = aProRes[nTmp][2] })

						If nPos <> 0
							
							If round(aProc[nPos][3],0) <= nDifere
								
								lBD7 := .T.
								
								While lBD7
								
									// Procura proximo registro...
									nReg := Ascan(aReg, {|x| x[1] = nPos })
                                    
                                    If nReg == 0
                                    	lBD7 := .F.
                                    Else
                                    
										// Posiciona BD6...
										BD6->(DbGoTo(aReg[nReg][2]))
										
										cChaBD6 := BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
										BD7->(DbSeek(cChaBD6))
										
										While BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)==cChaBD6 .and. ! BD7->(Eof())
                                        
											If BD7->BD7_LOTEAG == (cSequen+cAno+cMes)
												
												// Grava historico - BYN...
												BYN->(RecLock("BYN",.T.))
												BYN->BYN_FILIAL := xFilial("BYN")
												BYN->BYN_CODOPE := BD7->BD7_CODOPE
												BYN->BYN_CODLDP := BD7->BD7_CODLDP
												BYN->BYN_CODPEG := BD7->BD7_CODPEG
												BYN->BYN_NUMERO := BD7->BD7_NUMERO
												BYN->BYN_ORIMOV := BD7->BD7_ORIMOV
												BYN->BYN_SEQUEN := BD7->BD7_SEQUEN
												BYN->BYN_BLOPAG := BD7->BD7_BLOPAG
												BYN->BYN_PERBLQ := BD7->BD7_PERBLQ
												BYN->BYN_SEQBLQ := BD7->BD7_SEQBLQ
												BYN->BYN_PERDES := BD7->BD7_PERDES
												BYN->BYN_SEQDES := BD7->BD7_SEQDES
												BYN->BYN_BLQAUG := BD7->BD7_BLQAUG
												BYN->BYN_OBRPGT := BD7->BD7_OBRPGT
												BYN->BYN_BLQORI := cAno + cMes
												BYN->BYN_BLQSEQ := cSequen
												BYN->BYN_DESORI := Space(6)
												BYN->BYN_DESSEQ := Space(2)
												BYN->(MsUnlock())								
												
												// Glosa a Nota...
												BD7->(RecLock("BD7",.F.))
												BD7->BD7_BLOPAG := "1"
												BD7->BD7_VLRBLO := BD7->BD7_VLRPAG
												BD7->BD7_VLRPAG := 0.00
												BD7->BD7_PERBLQ := cAno + cMes
												BD7->BD7_SEQBLQ := cSequen
												If nTipoAG == 1
													BD7->BD7_BLQAUG := "2"
												Else
													BD7->BD7_BLQAUG := "1"
												Endif	
												BD7->(MsUnlock())								
											
											Endif
												
											// Alimenta controle...
											aReg[nReg][1] := 0
											
											
										    BD7->(DbSkip())
										EndDo
								    Endif

								EndDo
                                
								// Acumula totalizador...
								nQtdBlq += aProc[nPos][3]
								
								// Desfaz controle...	
								lBD7 := .T.
								
								While lBD7
									
									nReg := Ascan(aReg, {|x| x[1] = 0 })
									
									If nReg <> 0
										aReg[nReg][1] := nPos
									Else
										lBD7 := .F.
									Endif
									
								EndDo	

								// Atualiza valor da diferenca...	
								nDifere := (nDifere - aProc[nPos][3])
								
							Endif

							aProc[nPos][1] := "XX"
							
						Else
							lContin := .F.
						Endif
		            
					EndDo

					lContin := .T.

					// Desfaz controle criado anteriormente...	
					While lContin
						
						nPos := Ascan(aProc, {|x| x[1] = "XX" })

						If nPos <> 0
							aProc[nPos][1] := aProRes[nTmp][1]
						Else
							lContin := .F.
						Endif
							
					EndDo
	
				Else
					
					// Calcula a quantidade a recuperar...	
		            nDifere := nQtdMax - aProRes[nTmp][3]
		            nDifere := round(nDifere,0)
		            
		            If cChvBD7 <> cOperad+cCodSol+cCodRda
		            	lQryBD7 := .T.
		            	cChvBD7 := cOperad+cCodSol+cCodRda
		            Else
		            	lQryBD7 := .F.
		            EndIf
					If lQryBD7 .OR. Empty(cTabBD7)
						
						// Verifica procedimentos glosados pela rotina do AG...
						cQryBD7 := " SELECT BD7_FILIAL, BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_ORIMOV, BD7_SEQUEN, BD7_CODESP, BD7_CODPAD, BD7_CODPRO "
						cQryBD7 += " FROM " + RetSqlName("BD7") 
						cQryBD7 += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND "
						cQryBD7 +=       " BD7_CODOPE = '" + cOperad + "' AND "
						cQryBD7 +=       " BD7_CDPFPR = '" + cCodSol + "' AND "
						cQryBD7 +=       " BD7_CODRDA = '" + cCodRda + "' AND "
						cQryBD7 +=       " BD7_OPELOT = '    ' AND "
						cQryBD7 +=       " BD7_BLOPAG = '1' AND "
						cQryBD7 +=       " BD7_BLQAUG = '1' AND "
						cQryBD7 += " D_E_L_E_T_ = ' ' "
						cQryBD7 += " GROUP BY BD7_FILIAL, BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_ORIMOV, BD7_SEQUEN, BD7_CODESP, BD7_CODPAD, BD7_CODPRO "

						TCSQLEXEC( 'truncate table ' + cTabBD7 )		
						cSql := " INSERT INTO " + cTabBD7 + " (BD7_FILIAL,BD7_CODOPE,BD7_CODLDP,BD7_CODPEG,BD7_NUMERO,BD7_ORIMOV,BD7_SEQUEN,BD7_CODESP,BD7_CODPAD,BD7_CODPRO) "
						cSql += cQryBD7
						 
						nRetBD7 := TcSQLExec(cSql)
						lQryBD7 := .F.
					EndIf
					
					// Verifica procedimentos glosados pela rotina do AG...				 
					cSQL := " SELECT BD7_FILIAL, BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_ORIMOV, BD7_SEQUEN, BD7_CODPAD, BD7_CODPRO "
					cSQL += " FROM " + cTabBD7 + " " 
					cSQL += " WHERE BD7_CODESP = '" + cCodEsp + "' AND "
					cSQL +=       " BD7_CODPAD = '" + aProRes[nTmp][1] 	+ "' AND "
					cSQL +=       " BD7_CODPRO = '" + aProRes[nTmp][2] 	+ "' "
					cSQL += " GROUP BY BD7_FILIAL, BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_ORIMOV, BD7_SEQUEN, BD7_CODPAD, BD7_CODPRO "
					dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSQL),"TRBPRO", .F., .T.)
					
					While TRBPRO->(!Eof())
						 
						// Posiciona BD6...
						BD6->(DbSeek(xFilial("BD6")+TRBPRO->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)))
						
						If round(BD6->BD6_QTDPRO,0) <= nDifere
						
							// Posiciona BD7...	
							BD7->(DbSeek(xFilial("BD7")+TRBPRO->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)))
							
							While (BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)==TRBPRO->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)) .and. ! BD7->(Eof())
							
								If (BD7->BD7_CDPFPR == cCodSol) .and. (BD7->BD7_CODESP == cCodEsp) .and. (BD7->BD7_CODRDA == cCodRda)
								
									// Grava historico - BYN...	
									BYN->(RecLock("BYN",.T.))  
									BYN->BYN_FILIAL := xFilial("BYN")
									BYN->BYN_CODOPE := BD7->BD7_CODOPE
									BYN->BYN_CODLDP := BD7->BD7_CODLDP
									BYN->BYN_CODPEG := BD7->BD7_CODPEG
									BYN->BYN_NUMERO := BD7->BD7_NUMERO
									BYN->BYN_ORIMOV := BD7->BD7_ORIMOV
									BYN->BYN_SEQUEN := BD7->BD7_SEQUEN
									BYN->BYN_BLOPAG := BD7->BD7_BLOPAG
									BYN->BYN_PERBLQ := BD7->BD7_PERBLQ
									BYN->BYN_SEQBLQ := BD7->BD7_SEQBLQ
									BYN->BYN_PERDES := BD7->BD7_PERDES
									BYN->BYN_SEQDES := BD7->BD7_SEQDES
									BYN->BYN_BLQAUG := BD7->BD7_BLQAUG
									BYN->BYN_OBRPGT := BD7->BD7_OBRPGT
									BYN->BYN_BLQORI := BD7->BD7_PERBLQ
									BYN->BYN_BLQSEQ := BD7->BD7_SEQBLQ
									BYN->BYN_DESORI := cAno + cMes
									BYN->BYN_DESSEQ := cSequen
									BYN->(MsUnlock())								
									
									// Reativa a Nota...	
									BD7->(RecLock("BD7",.F.))
									BD7->BD7_BLOPAG := "0"
									BD7->BD7_VLRPAG := BD7->BD7_VLRBLO
									BD7->BD7_VLRBLO := 0.00
									BD7->BD7_PERDES := cAno + cMes
									BD7->BD7_SEQDES := cSequen
									BD7->BD7_OBRPGT := "1"
									BD7->(MsUnlock())								
									
                                Endif
                                
								BD7->(DbSkip())
							EndDo
							
							// Atualiza valor da diferenca...	
							nDifere := (nDifere - BD6->BD6_QTDPRO)

							// Acumula totalizador...	
							nQtdDes += BD6->BD6_QTDPRO
							
						Endif								
						
						TRBPRO->(DbSkip())
				    EndDo
		
					// Fecha Temporario...
			        TRBPRO->(DbCloseArea())
					
				Endif
				
			Endif
			
	   	Endif
	   	
   	Next
   	
	// Verifica os Exames nao solicitados no mes...	
	aCopRes := aClone(aProRes)
	aProc   := {} 
	aProRes := {}
	aReg    := {}

	// Verifica procedimentos glosados pela rotina do AG...
	cSQL := " SELECT BD7_FILIAL, BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_ORIMOV, BD7_SEQUEN, BD7_CODPAD, BD7_CODPRO, R_E_C_N_O_ FROM " + RetSqlName("BD7") 
	cSQL += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND "
	cSQL +=       " BD7_CODOPE = '" + cOperad + "' AND "
	cSQL +=       " BD7_CDPFPR = '" + cCodSol + "' AND "
	cSQL +=       " BD7_CODRDA = '" + cCodRda + "' AND "
	cSQL +=       " BD7_CODESP = '" + cCodEsp + "' AND "
	cSQL +=       " BD7_OPELOT = '    ' AND "
	cSQL +=       " BD7_BLOPAG = '1' AND "
	cSQL +=       " BD7_BLQAUG = '1' AND "
	cSQL += " D_E_L_E_T_ = ' ' "
	cSQL += " ORDER BY BD7_FILIAL, BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_ORIMOV, BD7_SEQUEN, BD7_CODPAD, BD7_CODPRO "
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSQL),"TRBPRO", .F., .T.)

	While TRBPRO->(!Eof())

		// Posiciona BD6...	
		BD6->(DbSeek(xFilial("BD6")+TRBPRO->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)))

		aadd(aProc,{BD6->BD6_CODPAD, BD6->BD6_CODPRO, BD6->BD6_QTDPRO })

		cChave := TRBPRO->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

		// Grava aReg...
		While TRBPRO->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)==cChave .and. TRBPRO->(!Eof())

			aadd(aReg,{ len(aProc), TRBPRO->R_E_C_N_O_ })

			TRBPRO->(DbSkip())
		EndDo
		
    EndDo

	// Fecha Temporario...
    TRBPRO->(DbCloseArea())
    
	// Cria array agrupando os procedimentos...
	aProRes := {}
	
	For nTmp := 1 to Len(aProc)
	    
		nPos := Ascan(aCopRes, {|x| x[1] = aProc[nTmp][1] .And. x[2] = aProc[nTmp][2] })

		// Serao analisados somente os procedimentos nao analisados anteriormente...
		If nPos == 0
		
			nPos := Ascan(aProRes, {|x| x[1] = aProc[nTmp][1] .And. x[2] = aProc[nTmp][2] })
			
			If nPos > 0
				aProRes[nPos][3] += aProc[nTmp][3]
			Else
		    	aadd(aProRes,{})
		    	aProRes[Len(aProRes)] := aClone(aProc[nTmp])
		    Endif
		    
	    Endif
	    
	Next

	// Verifica se os procedimentos possuem regra cadastrada...
   	For nTmp := 1 to Len(aProRes)
   	
		aAGNive := PLSEspNiv(aProRes[nTmp][1])
		nNiveis := (aAGNive[1]+1)
		lAchou  := .F.
		
		// Busca conforme o nivel do procedimento cadastrado na regra...
		For nFor := 1 To nNiveis
		
			If nFor == 1
		    	If BMY->(DbSeek(xFilial("BMY")+cOperad+cCodEsp+aProRes[nTmp][1]+aProRes[nTmp][2]))
		    		If BMY->BMY_NIVEL == strzero(nNiveis,1)
			    		lAchou := .T.
			    	Endif	
				Endif
			Else
				If ! lAchou
			    	If BMY->(DbSeek(xFilial("BMY")+cOperad+cCodEsp+aProRes[nTmp][1]+Substr(aProRes[nTmp][2],aAGNive[2,(nFor-1),1],aAGNive[2,(nFor-1),2])))
			    		If aAGNive[2,(nFor-1),3] == BMY->BMY_NIVEL
				    		lAchou := .T.
				    	Endif	
					Endif
				Endif	
			Endif
			
		Next

    	If lAchou
	
			// Calcula o nro maximo de exames...
			nQtdMax := ((BMY->BMY_PERCEN/100)*(nQtdCon))
			
			// Trata arredondamento   
            Do Case
               Case nArred == 1 // arredondamento padrao
		            nQtdMax := round(nQtdMax,0) 
               Case nArred == 2 // arredonda para cima
			        If  nQtdMax > int(nQtdMax)
			            nQtdMax := int(nQtdMax) + 1
			        Else
			            nQtdMax := int(nQtdMax)
			        Endif
               Case nArred == 3 // arredonda para baixo
		            nQtdMax := int(nQtdMax) 
            EndCase

			// Calcula a quantidade a recuperar...
			nDifere := nQtdMax
            nDifere := round(nDifere,0)            
			
			If nDifere < 0.5
				nDifere := 0
			Endif

 			If nDifere > 0
 			
 				lContin := .T.

				While lContin

					nPos := Ascan(aProc, {|x| x[1] = aProRes[nTmp][1] .And. x[2] = aProRes[nTmp][2] })

					If nPos <> 0
						
						If round(aProc[nPos][3],0) <= nDifere
							
							lBD7 := .T.
							
							While lBD7
							
								// Procura proximo registro...
								nReg := Ascan(aReg, {|x| x[1] = nPos })
                                    
                                If nReg == 0
                                  	lBD7 := .F.
                                Else
                                    
									// Posiciona BD7...														 
									BD7->(DbGoTo(aReg[nReg][2]))
									
									// Grava historico - BYN...												 
									BYN->(RecLock("BYN",.T.))  
									BYN->BYN_FILIAL := xFilial("BYN")
									BYN->BYN_CODOPE := BD7->BD7_CODOPE
									BYN->BYN_CODLDP := BD7->BD7_CODLDP
									BYN->BYN_CODPEG := BD7->BD7_CODPEG
									BYN->BYN_NUMERO := BD7->BD7_NUMERO
									BYN->BYN_ORIMOV := BD7->BD7_ORIMOV
									BYN->BYN_SEQUEN := BD7->BD7_SEQUEN
									BYN->BYN_BLOPAG := BD7->BD7_BLOPAG
									BYN->BYN_PERBLQ := BD7->BD7_PERBLQ
									BYN->BYN_SEQBLQ := BD7->BD7_SEQBLQ
									BYN->BYN_PERDES := BD7->BD7_PERDES
									BYN->BYN_SEQDES := BD7->BD7_SEQDES
									BYN->BYN_BLQAUG := BD7->BD7_BLQAUG
									BYN->BYN_OBRPGT := BD7->BD7_OBRPGT
									BYN->BYN_BLQORI := BD7->BD7_PERBLQ
									BYN->BYN_BLQSEQ := BD7->BD7_SEQBLQ
									BYN->BYN_DESORI := cAno + cMes
									BYN->BYN_DESSEQ := cSequen
									BYN->(MsUnlock())									
									
									// Reativa a Nota..
									BD7->(RecLock("BD7",.F.))
									BD7->BD7_BLOPAG := "0"
									BD7->BD7_VLRPAG := BD7->BD7_VLRBLO
									BD7->BD7_VLRBLO := 0.00
									BD7->BD7_PERDES := cAno + cMes
									BD7->BD7_SEQDES := cSequen
									BD7->BD7_OBRPGT := "1"
									BD7->(MsUnlock())

									// Alimenta controle...													 
									aReg[nReg][1] := 0
									
							    Endif

							EndDo
                                
							// Acumula totalizador...												 	 
							nQtdDes += aProc[nPos][3]
							
							// Desfaz controle...													 	 
							lBD7 := .T.
							
							While lBD7
								
								nReg := Ascan(aReg, {|x| x[1] = 0 })
								
								If nReg <> 0
									aReg[nReg][1] := nPos
								Else
									lBD7 := .F.
								Endif
								
							EndDo	

							// Atualiza valor da diferenca...											 
							nDifere := (nDifere - aProc[nPos][3])
							
						Endif

						aProc[nPos][1] := "XX"
						
					Else
						lContin := .F.
					Endif
	            
				EndDo

				lContin := .T.
				
				// Desfaz controle criado anteriormente...									    
				While lContin
					
					nPos := Ascan(aProc, {|x| x[1] = "XX" })

					If nPos <> 0
						aProc[nPos][1] := aProRes[nTmp][1]
					Else
						lContin := .F.
					Endif
						
				EndDo
 				
            Endif
            
        Endif

	Next

	TRBBBF->(DbSkip())
EndDo   

// Fecha Temporario...													 
TRBBBF->(DbCloseArea())

nTotRda := Len(aPresta)

// Grava o Lote...															 
BYM->(RecLock("BYM",.T.))
BYM->BYM_FILIAL := xFilial("BYM")
BYM->BYM_CODOPE := cOperad
BYM->BYM_COMPET := cAno + cMes
BYM->BYM_SEQUEN := cSequen
BYM->BYM_USUARI := Upper(PLRETOPE())
BYM->BYM_DATA   := Date()
BYM->BYM_HORA   := Time()
BYM->BYM_ESTTRB := GetComputerName()
BYM->BYM_QTDRDA := nTotRda
BYM->BYM_QTDBLQ := nQtdBlq
BYM->BYM_QTDDES := nQtdDes
BYM->(MsUnlock())

If !EMPTY(cTrbBD7) .AND. ( Select(cTrbBD7) > 0 )
	(cTrbBD7)->(dbCloseArea())
	oTempTable:Delete()
EndIf

Return


//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSA982Exc
Funcao para exclusao dos arquivos relacionados ao processo
@author Thiago Machado Correa
@since 08/2004
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSA982Exc(nRecno)

Local cSql    := "" 
Local cCompet := ""
Local cSequen := ""
Local cOperad := ""  
Local cQuery  := ""
Local cChave  := ""    
Local cChaYN  := ""
Local nBlqQtd := 0
Local nDesQtd := 0
Local nReg    := 0
Local lCnt    := .T.      
Local lDelBYN := .F.
Local cBD7    := RetSqlName("BD7")
Local cBYM    := RetSqlName("BYM")

// Exibe mensagem...                                                        
If !lAutoSt
	MsProcTXT("Excluindo...")
endif

// Posiciona BYM...														 
BYM->(DbGoTo(nRecno))

cCompet := BYM->BYM_COMPET
cSequen := BYM->BYM_SEQUEN
cOperad := BYM->BYM_CODOPE
nBlqQtd := BYM->BYM_QTDBLQ
nDesQtd := BYM->BYM_QTDDES

If (nBlqQtd+nDesQtd) > 0

	// Verifica se eh a ultima competencia...									  
	cSql := " SELECT MAX(BYM_COMPET) MAX FROM " + cBYM
	cSql += " WHERE BYM_FILIAL = '" + xFilial("BYM") + "' AND "
	cSql +=       " BYM_CODOPE = '" + cOperad + "' AND "
	cSql += " D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSQL),"TRB", .F., .T.)
	
	If BYM->BYM_COMPET <> TRB->MAX
		TRB->(DbCloseArea())
		MsgAlert("Somente o ultimo Lote pode ser excluido!")
		Return
	Endif
	
	TRB->(DbCloseArea())
	
	// Verifica se eh o ultimo sequencial...									  
	cSql := " SELECT MAX(BYM_SEQUEN) MAX FROM " + cBYM
	cSql += " WHERE BYM_FILIAL = '" + xFilial("BYM") + "' AND "
	cSql +=       " BYM_CODOPE = '" + cOperad + "' AND "
	cSql +=       " BYM_COMPET = '" + cCompet + "' AND "
	cSql += " D_E_L_E_T_ = ' ' "
	
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSQL),"TRB", .F., .T.)
	
	If !lAutoSt .AND. BYM->BYM_SEQUEN <> TRB->MAX
		TRB->(DbCloseArea())
		MsgAlert("Somente o ultimo Lote pode ser excluido!")
		Return
	Endif
	
	TRB->(DbCloseArea())
	
Endif

// Ordena arquivos...														 
BD6->(DbSetOrder(1))
BD7->(DbSetOrder(1))

// Faz validacoes...														 
If ! LoteAGLiberado(cOperad,cCompet,cSequen) .AND. !lAutoSt
	MsgAlert("Pagamento ja realizado. Lote nao pode ser excluido.")
	Return
Endif	

// Busca registros...														 
cSql := " SELECT BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_ORIMOV, BD7_SEQUEN, BD7_PERBLQ, BD7_SEQBLQ, BD7_PERDES, BD7_SEQDES FROM " + cBD7
cSql += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND "
cSql +=       " BD7_CODOPE = '" + cOperad + "' AND "
cSql += " ( ( BD7_PERBLQ = '" + cCompet+ "' AND BD7_SEQBLQ = '" + cSequen + "' ) OR "
cSql += "   ( BD7_PERDES = '" + cCompet+ "' AND BD7_SEQDES = '" + cSequen + "' ) ) AND "
cSql += " D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSQL),"TRBBD7", .F., .T.)

// Deleta regristros...													 
While TRBBD7->(!Eof())

	// Posiciona BD7...														 
	lCnt := BD7->(DbSeek(xFilial("BD7")+TRBBD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)))

	While lCnt
	
		// Posiciona BYN...														 
		cChaYN := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_PERBLQ+BD7_SEQBLQ+BD7_PERDES+BD7_SEQDES)
		
		If BYN->(DbSeek(xFilial("BYN")+cChaYN))
			
			lDelBYN := .F.
			nReg    := BD7->(Recno())
			cChave  := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
			
			// Restaura BD7...														 	 
			While BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)==cChave .and. !TRBBD7->(Eof())
			
				If ( BD7->BD7_PERBLQ = cCompet .and. BD7->BD7_SEQBLQ = cSequen ) .or. ;
				   ( BD7->BD7_PERDES = cCompet .and. BD7->BD7_SEQDES = cSequen ) 
		
					BD7->(RecLock("BD7",.F.))
					BD7->BD7_PERBLQ := BYN->BYN_PERBLQ
					BD7->BD7_SEQBLQ := BYN->BYN_SEQBLQ
					BD7->BD7_PERDES := BYN->BYN_PERDES
					BD7->BD7_SEQDES := BYN->BYN_SEQDES
					BD7->BD7_BLQAUG := BYN->BYN_BLQAUG
					BD7->BD7_OBRPGT := BYN->BYN_OBRPGT
					If BYN->BYN_BLOPAG == "0" .and. BD7->BD7_BLOPAG == "1"
						BD7->BD7_VLRPAG := BD7->BD7_VLRBLO
						BD7->BD7_VLRBLO := 0.00
					Else
						If BYN->BYN_BLOPAG == "1" .and. BD7->BD7_BLOPAG == "0"
							BD7->BD7_VLRBLO := BD7->BD7_VLRPAG
							BD7->BD7_VLRPAG := 0.00
						Endif
					Endif	
					BD7->BD7_BLOPAG := BYN->BYN_BLOPAG
					BD7->(MsUnlock())
					
					lDelBYN := .T.
					
				Endif
				
				BD7->(DbSkip())
            EndDo             
            
            BD7->(DbGoTo(nReg))
            
			// Exclui BYN...
			If lDelBYN
				BYN->(DbSeek(xFilial("BYN")+cChaYN))
			    While BYN->(BYN_CODOPE+BYN_CODLDP+BYN_CODPEG+BYN_NUMERO+BYN_ORIMOV+BYN_SEQUEN+BYN_BLQORI+BYN_BLQSEQ+BYN_DESORI+BYN_DESSEQ)==cChaYN .and. ! BYN->(Eof())
			
					BYN->(RecLock("BYN"))
					BYN->(DbDelete())
					BYN->(MsUnlock())
			
			    	BYN->(DbSkip())
			    EndDo
			Else
		    	lCnt := .F.
			Endif
	    Else
	    	lCnt := .F.
	    Endif
	
	EndDo

	TRBBD7->(DbSkip())		
EndDo

TRBBD7->(DbCloseArea())

// Desmarca as consultas...											 	  
cQuery := " UPDATE " + RetSqlName("BD6") + " SET BD6_LOTEAG = '        ' " 
cQuery += " WHERE BD6_FILIAL = '" + xFilial("BD6") + "' AND "
cQuery +=       "	BD6_CODOPE = '" + cOperad + "' AND "
cQuery +=       "	BD6_LOTEAG = '" + cSequen + cCompet + "' AND "
cQuery += " D_E_L_E_T_ = ' ' "
TcSqlExec(cQuery)

// Desmarca as consultas...											 	 
cQuery := " UPDATE " + RetSqlName("BD7") + " SET BD7_LOTEAG = '        ' " 
cQuery += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND "
cQuery +=       "	BD7_CODOPE = '" + cOperad + "' AND "
cQuery +=       "	BD7_LOTEAG = '" + cSequen + cCompet + "' AND "
cQuery += " D_E_L_E_T_ = ' ' "
TcSqlExec(cQuery)

// Exclui BYM...														 	   
BYM->(RecLock("BYM"))
BYM->(DbDelete())
BYM->(MsUnlock())

Return .T.


//-------------------------------------------------------------------
/*/ {Protheus.doc} LoteAGLiberado
Funcao para verificar se o lote pode ser excluido
@author Thiago Machado Correa
@since 08/2004
@version P12 
/*/
//-------------------------------------------------------------------
Function LoteAGLiberado(cOperad,cCompet,cSequen)

Local cSql := ""
Local lRet := .T.
Local cBD7 := RetSqlName("BD7")

cSql := " SELECT COUNT(*) QTD FROM " + cBD7
cSql += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND "
cSql +=       " BD7_CODOPE = '" + cOperad + "' AND "
cSql += " ( ( BD7_PERBLQ = '" + cCompet+ "' AND BD7_SEQBLQ = '" + cSequen + "' AND BD7_PGTBLQ <> '    ') OR "
cSql += "   ( BD7_PERDES = '" + cCompet+ "' AND BD7_SEQDES = '" + cSequen + "' AND BD7_PGTDES <> '    ') ) AND "
cSql += " D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN", TCGenQry(,,cSQL),"TRB", .F., .T.)

If TRB->QTD > 0
	lRet := .F.
Endif

TRB->(DbCloseArea())

Return lRet


//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSTIPCON
Usado na pesquisa padrão do F3
@author Thiago Machado Correa
@since 09/2004
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSTIPCON(cDado)
LOCAL oDlg
LOCAL nOpca     := 0
LOCAL bOK       := { || nOpca := K_OK, oDlg:End() }
LOCAL bCancel   := { || oDlg:End() }
LOCAL oCritica
LOCAL aCritica  := {}
LOCAL nInd
Local lRet := .F.
cDado := AllTrim(cDado)

aadd(aCritica,{"CO", "Custo Operacional", Iif("CO" $ cDado,.T.,.F.)}) //"CUSTO OPERACIONAL"
aadd(aCritica,{"PP", "Pré-pagamento" 	, Iif("PP" $ cDado,.T.,.F.)}) //"PRE PAGAMENTO"
aadd(aCritica,{"IN", "Intercâmbio" 		, Iif("IN" $ cDado,.T.,.F.)}) //"INTERCAMBIO"

DEFINE MSDIALOG oDlg TITLE "Tipos De Modalidade" FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault() //"Tipos de Modalidades"

@ 020,012 SAY oSay PROMPT "Seleccione o(s) tipo(s)" SIZE 050,010 OF oDlg PIXEL COLOR CLR_HBLUE //"Selecione o(s) tipo(s)"

oCritica := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

oCritica:AddColumn(TcColumn():New(" ",{ || IF(aCritica[oCritica:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },;
"@!",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))

oCritica:AddColumn(TcColumn():New("Código",{ || OemToAnsi(aCritica[oCritica:nAt,1]) },; //"Codigo"
"@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))

oCritica:AddColumn(TcColumn():New("Descrição",{ || OemToAnsi(aCritica[oCritica:nAt,2]) },; //"Descricao"
"@!",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))

oCritica:SetArray(aCritica)
oCritica:bLDblClick := { || aCritica[oCritica:nAt,3] := IF(aCritica[oCritica:nAt,3],.F.,.T.) }

ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

If nOpca == K_OK
	
	cDado := ""
	For nInd := 1 To Len(aCritica)
		If aCritica[nInd,3]
			cDado += aCritica[nInd,1]+","
		Endif
	Next
	
Endif
lRet := ! empty(cDado)
Return(lRet)
