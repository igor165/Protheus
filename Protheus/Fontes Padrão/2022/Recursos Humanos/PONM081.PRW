#INCLUDE "PONM081.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PONM081  ³ Autor ³ Marcelo Silveira      ³ Data ³ 06/05/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apuracao Banco de Horas para o eSocial                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPON                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/   
/*/{Protheus.doc} PONM081
Apurar e gerar os dados do banco de horas para o eSocial, para demonstracao na folha de pagamento
@Author.....: Marcelo Silveira
@Since......: 06/06/2018
@Version....: 1.0
@Return.....: Nil
/*/
Function PONM081

Local nX			:= 0
Local aSays 		:= {}
Local aButtons		:= {}
Local aCodFol		:= {}
Local cMsg			:= ""
Local cPerg			:= "PNM081R"
Local cSvFilAnt		:= cFilAnt
Local lContinua		:= .F.
Local lBarG1ShowTm 	:= .F.
Local lBarG2ShowTm 	:= .F.
Local nOpcA			:= 0.00

Private aPdBcoHor	:= {}
Private lAbortPrint := .F.
Private cCadastro   := OemToAnsi( STR0001 ) //"Apuracao do Banco de Horas para o e-Social"

Private aFldRot 	:= {'RA_NOME'}
Private aOfusca	 	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
Private lOfuscaNom 	:= .F. 
Private aFldOfusca 	:= {}

If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
		lOfuscaNom := FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
EndIf

//Carrega verbas
Fp_CodFol(@aCodFol, cFilAnt, .F., .F.)

If Len(aCodFol) >= 1551 
	lContinua := !Empty( aCodFol[1549,1] ) .And. !Empty( aCodFol[1550,1] ) .And. !Empty( aCodFol[1551,1] )
EndIf 

If !lContinua
	cMsg := OemToAnsi( STR0004 ) + CRLF + CRLF	//"Para executar essa rotina é obrigatório o cadastro das verbas (Tipo 3 - Base Provento) dos seguintes identificadores:"
	cMsg += OemToAnsi( STR0005 ) + CRLF		//"1549 - Saldo de banco de horas anterior ao esocial"
	cMsg += OemToAnsi( STR0006 ) + CRLF		//"1550 - Horas debitadas em banco de horas no mes"
	cMsg += OemToAnsi( STR0007 ) 	//"1551 - Horas creditadas em banco de horas no mes"
	MsgInfo( cMsg )
	Return()
Else
	aPdBcoHor := { {aCodFol[1549,1],""}, {aCodFol[1550,1],""}, {aCodFol[1551,1],""} }	
	For nX := 1 To Len(aPdBcoHor)
		PosSrv( aPdBcoHor[nX,1], cFilAnt )
		aPdBcoHor[nX,2] := SRV->RV_TIPO
	Next nX
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ So Executa se os Modos de Acesso dos Arquivos Relacionados es³
³ tiverm OK													   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF ValidArqPon()

	aAdd(aSays,OemToAnsi( STR0002 )) 	//"Este programa tem como objetivo gerar os Débitos e Créditos do banco de Horas no mês"
	aAdd(aSays,OemToAnsi( STR0003 ))	//"e também poderá gerar o Saldo do Banco de Horas anterior ao e-Social."
	aAdd(aSays, CRLF)    				// " "
	aAdd(aSays,OemToAnsi( STR0011 ))	//"Somente serão considerados os funcionários com o campo B.H p/ Folh 
	aAdd(aSays,OemToAnsi( STR0012 ))    //"(Banco de horas para folha) preenchido com SIM, caso contrário,"
	aAdd(aSays,OemToAnsi( STR0013 ))    //"os funcionários serão desconsiderados."
	
	aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
	aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(),FechaBatch(),nOpcA:=0 ) }} )
	aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	
	FormBatch( cCadastro, aSays, aButtons )
	
	IF ( nOpcA == 1 )
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Verifica se deve Mostrar Calculo de Tempo nas BarGauge			 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		lBarG1ShowTm := ( SuperGetMv("MV_PNSWTG1",NIL,"N") == "S" )
		lBarG2ShowTm := ( SuperGetMv("MV_PNSWTG2",NIL,"S") == "S" )
		/*                               
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Executa o Processo de Fechamento do Banco de Horas				 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		Proc2BarGauge(  {|| PNM081Processa( cPerg ) }, OemToAnsi( STR0001 ), NIL , NIL , .T. , lBarG1ShowTm , lBarG2ShowTm )  //"Apuracao do Banco de Horas para o e-Social"
	EndIF
	
EndIF
	
cFilAnt := cSvFilAnt

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PONM080Processa ³ Autor ³ Aldo Marini jr ³ Data ³ 03/12/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa o Fechamento do Banco de Horas                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso  	 ³ SIGAPON							             			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PNM081Processa( cPerg )

Local nX			:= 0
Local nAt			:= 0
Local nReg			:= 0
Local nValPd		:= 0
Local nTFil			:= 0
Local nTMat			:= 0
Local nSaldoP     	:= 0.00            
Local nSaldoD     	:= 0.00            
Local nSaldoA     	:= 0.00
Local nUtiHoras  	:= 0
Local cChave		:= ""
Local cFilFun 		:= ""
Local cMatFun 		:= ""
Local cProcFun 		:= ""
Local cDtIni    	:= ""
Local cDtFim    	:= ""
Local cDtIniMov    	:= ""
Local cDtFimMov    	:= ""
Local cDtIniSaldo  	:= ""
Local cDtFimSaldo  	:= ""
Local cTpCod		:= ""
Local cWhereSRA		:= ""
Local cWhereSPI		:= ""
Local cSituacao		:= ""
Local cCategoria	:= ""  
Local cSitQuery 	:= ""
Local cCatQuery 	:= ""
Local cAnoMes		:= ""
Local cPdBh			:= ""
Local cAliasSRA		:= getNextAlias()
Local cAliasSPI		:= getNextAlias()
Local aCodFol		:= {}
Local lAddNew		:= .F.
Local lGeraSaldo	:= .F. 
Local lGrv			:= .F.
Local lFirst		:= .T.

Private aLogDet		:= {}
Private aLogTitle	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando as Perguntas                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte( cPerg, .F. )

cSituacao  			:= If( !Empty(mv_par05), mv_par05, ' ADFT' )
cCategoria 			:= If( !Empty(mv_par06), mv_par06, 'CDHMST' )
nTpEvento  			:= If( !Empty(mv_par08), mv_par08, 3 ) //-- 1=Autorizados 2=Nao Autorizados 3=Ambos
dDtPagFol			:= mv_par13
cAnoMes				:= AnoMes( dDtPagFol )

MakeSqlExpr( cPerg )

cSitQuery	:= ""
For nReg :=1 to Len(cSituacao)
	cSitQuery += "'"+Subs(cSituacao,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cSituacao)
		cSitQuery += "," 
	Endif
Next nReg     

cCatQuery	:= ""
For nReg:=1 to Len(cCategoria)
	cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cCategoria)
		cCatQuery += "," 
	Endif
Next nReg

//Filial
If !Empty(mv_par01)
	cWhereSRA += mv_par01
EndIf

//Centro de Custos
If !Empty(mv_par02)
	cWhereSRA += Iif(!Empty(cWhereSRA)," AND ","")
	cWhereSRA += mv_par02
EndIf

//Turno   
If !Empty(mv_par03)
	cWhereSRA += Iif(!Empty(cWhereSRA)," AND ","")
	cWhereSRA	+= mv_par03
EndIf

//Matricula   
If !Empty(mv_par04)
	cWhereSRA += Iif(!Empty(cWhereSRA)," AND ","")
	cWhereSRA += mv_par04
EndIf

//Eventos
If !Empty(mv_par07)
	nAt := At("P9_CODIGO", mv_par07 )
	cWhereSPI := Stuff( mv_par07, nAt, 10, "PI_PD " )
EndIf

//Data inicial - Movimento Mes   
If !Empty(mv_par09)
	cDtIniMov := DTOS( mv_par09 )
EndIf

//Data Final - Movimento Mes   
If !Empty(mv_par10)
	cDtFimMov := DTOS( mv_par10 )
EndIf

//Data inicial - Saldo Anterior   
If !Empty(mv_par11)
	cDtIniSaldo := DTOS( mv_par11 )
EndIf

//Data Final - Saldo Anterior   
If !Empty(mv_par12)
	cDtFimSaldo := DTOS( mv_par12 )
EndIf

If ValType(mv_par14) == "N"
	nUtiHoras	:= mv_par14
Else
	nUtiHoras	:= 1
EndIf

cSitQuery := "%" + cSitQuery + "%"
cCatQuery := "%" + cCatQuery + "%"
cWhereSRA := "%" + If( Empty(cWhereSRA), "", " AND " ) + cWhereSRA + "%"
cWhereSPI := "%" + If( Empty(cWhereSPI), "", " AND " ) + cWhereSPI + "%"

//Quando é para gerar saldo tem que levar na query o maior periodo possivel considerando os 4 perguntes 
If !Empty(mv_par11) .And. !Empty(mv_par11)
	aData := { cDtIniMov, cDtFimMov, cDtIniSaldo, cDtFimSaldo }
	aSort(aData)
	cDtIni := aData[1] 
	cDtFim := aData[4]
	lGeraSaldo := .T.
Else
	cDtIni := cDtIniMov 
	cDtFim := cDtFimMov
EndIf 

Begin Sequence

	If Select(cAliasSRA) > 0
		(cAliasSRA)->(dbcloseArea())
	Endif
			
	BeginSql alias cAliasSRA
	SELECT 
		RA_FILIAL, RA_MAT, RA_NOME, RA_CC, RA_PROCES, RA_TNOTRAB, RA_SEQTURN, RA_REGRA, RA_ADMISSA, RA_CODFUNC, 
		RA_DEMISSA, RA_CATFUNC, RA_SITFOLH, RA_SINDICA, RA_BHFOL, RA_POSTO, RA_DEPTO, RA_ITEM, RA_CLVL
	FROM 
		%table:SRA% SRA 				
	WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
			SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND			
			SRA.RA_BHFOL = 'S'
			%exp:cWhereSRA% AND SRA.%notDel%
	
		ORDER BY 
			SRA.RA_FILIAL,SRA.RA_MAT
	EndSql
	dbSelectArea(cAliasSRA)

	While (cAliasSRA)->( !Eof() )
	
		cFilFun := (cAliasSRA)->RA_FILIAL
		cMatFun := (cAliasSRA)->RA_MAT
		cNomFun := SubStr((cAliasSRA)->RA_NOME,1,30)
		cNomFun := If(lOfuscaNom,Replicate('*',30),cNomFun)
		cProcFun:= (cAliasSRA)->RA_PROCES
		
		If lFirst
			nTFil  := 10 - Len(cFilFun)
			nTMat  := 15 - Len(cMatFun)
			lFirst := .F.
		EndIf
		nTNom := (35-Len(cNomFun))
		
		If Select(cAliasSPI) > 0
			(cAliasSPI)->(dbcloseArea())
		Endif	
	
		BeginSql alias cAliasSPI
			SELECT PI_FILIAL, PI_MAT, PI_PD, PI_QUANT, PI_QUANTV, PI_CC, PI_DATA, PI_STATUS
			FROM %table:SPI% SPI
			WHERE 	SPI.PI_FILIAL = %exp:cFilFun% AND 
					SPI.PI_MAT = %exp:cMatFun% AND 
					SPI.PI_DATA BETWEEN (%exp:cDtIni%) AND (%exp:cDtFim%) AND 
					SPI.PI_STATUS <> 'B'
					%exp:cWhereSPI% AND SPI.%notDel%
			ORDER BY 
				SPI.PI_FILIAL,SPI.PI_MAT,SPI.PI_DATA	
		EndSql	
	
		nSaldoA := 0.00
		nSaldoP := 0.00
		nSaldoD := 0.00
		cTpCod  := ""
		lGrv	:= .F.
	
		While (cAliasSPI)->( !Eof() )
	
			If nTpEvento <> 3
				If !fBscEven( (cAliasSPI)->PI_PD, 2, nTpEvento )
					(cAliasSPI)->( dbSkip() )
					Loop
				EndIF
			EndIf

			PosSP9( (cAliasSPI)->PI_PD, cFilFun)
			cTpCod := SP9->P9_TIPOCOD 
			
			If lGeraSaldo
				//Gera o saldo Anterior
				If (cAliasSPI)->PI_DATA >= cDtIniSaldo .And. (cAliasSPI)->PI_DATA <= cDtFimSaldo
					If nUtiHoras == 1
						nSaldoA := If( cTpCod $ "1*3", __TimeSum( nSaldoA, (cAliasSPI)->PI_QUANT ), __TimeSub( nSaldoA, (cAliasSPI)->PI_QUANT ) ) 
					Else
						nSaldoA := If( cTpCod $ "1*3", __TimeSum( nSaldoA, (cAliasSPI)->PI_QUANTV ), __TimeSub( nSaldoA, (cAliasSPI)->PI_QUANTV ) ) 
					EndIf
				EndIf
			EndIf
			 
			//Gera os Creditos e Debitos do Banco de Horas - So avalia a data quando existe geracao de saldo anterior		 
			If !lGeraSaldo .Or. (cAliasSPI)->PI_DATA >= cDtIniMov .And. (cAliasSPI)->PI_DATA <= cDtFimMov
				If cTpCod $ "1*3"
					If nUtiHoras == 1
						nSaldoP := __TimeSum( nSaldoP, (cAliasSPI)->PI_QUANT )
					Else
						nSaldoP := __TimeSum( nSaldoP, (cAliasSPI)->PI_QUANTV )
					EndIf
				Else
					If nUtiHoras == 1
						nSaldoD := __TimeSum( nSaldoD, (cAliasSPI)->PI_QUANT )
					Else
						nSaldoD := __TimeSum( nSaldoD, (cAliasSPI)->PI_QUANTV )
					EndIf
				EndIf
			EndIf
			
			(cAliasSPI)->(DbSkip())
		End

		(cAliasSPI)->(dbcloseArea())

		//Ajusta o saldo anterior negativo para gerar como horas compensadas no mês.
		If nSaldoA < 0
			nSaldoD := __TimeSub( nSaldoD, nSaldoA )
			nSaldoA := 0				
		EndIf
		
		If nSaldoP > 0 .Or. nSaldoD > 0 .Or. nSaldoA > 0

			dbSelectArea("RGB")
			dbSetOrder(1)		                                                                                              
		
			For nX := 1 To Len( aPdBcoHor )
			
				Do Case
					Case nX == 1	//Saldo anterior ao eSocial
						nValPd := nSaldoA := fConvHr(nSaldoA, "D")
					Case nX == 2	//Horas debitadas no mes
						nValPd := nSaldoD := fConvHr(nSaldoD, "D")
					Case nX == 3	//Horas creditadas no mes
						nValPd := nSaldoP := fConvHr(nSaldoP, "D")
				EndCase

				cChave	:= cFilFun + cMatFun +  aPdBcoHor[nX,1] + cAnoMes + "01" //RGB_FILIAL+RGB_MAT+RGB_PD+RGB_PERIOD+RGB_SEMANA+RGB_SEQ
				lAddNew := !RGB->( dbSeek( cChave ) )                                                                                               
	
				If nValPd > 0
				
					RecLock( "RGB", lAddNew )
						RGB->RGB_FILIAL 	:= cFilFun
						RGB->RGB_PROCES		:= cProcFun
						RGB->RGB_PERIOD		:= cAnoMes
						RGB->RGB_SEMANA		:= "01"
						RGB->RGB_ROTEIR		:= "FOL"
						RGB->RGB_ROTORI		:= "PON"
						RGB->RGB_MAT		:= cMatFun
						RGB->RGB_PD			:= aPdBcoHor[nX,1]
						RGB->RGB_TIPO1 		:= aPdBcoHor[nX,2]
						RGB->RGB_HORAS		:= 0.00
						RGB->RGB_VALOR		:= nValPd
						RGB->RGB_DTREF		:= dDtPagFol
						RGB->RGB_CC			:= (cAliasSRA)->RA_CC
						RGB->RGB_TIPO2		:= "E"
						RGB->RGB_CODFUN		:= (cAliasSRA)->RA_CODFUNC
						RGB->RGB_POSTO		:= (cAliasSRA)->RA_POSTO
						RGB->RGB_DEPTO		:= (cAliasSRA)->RA_DEPTO
						RGB->RGB_ITEM		:= (cAliasSRA)->RA_ITEM
						RGB->RGB_CLVL		:= (cAliasSRA)->RA_CLVL				
					RGB->( MsUnlock() )
				    
					lGrv := .T.
				
				ElseIf !lAddNew
					
					//Exclui o registro quando encontra a verba mas o valor atual é negativo ou zero
					RecLock( "RGB", lAddNew )
						RGB->( dbDelete() )
					RGB->( MsUnlock() )
									
				EndIf
				
			Next nX
			
			If lGrv
				cValA := Transform(nSaldoA,'@E 99999.99')
				cValD := Transform(nSaldoD,'@E 99999.99')
				cValP := Transform(nSaldoP,'@E 99999.99')
				aAdd( aLogDet, cFilFun + Space(nTFil) + cMatFun + Space(nTMat) + cNomFun + Space(nTNom) + cValA + Space(15-Len(cValA)) + cValD + Space(15-Len(cValD)) + cValP  )
			EndIf
		
		EndIf
	
		(cAliasSRA)->(DbSkip())
	End	
	
	(cAliasSRA)->(DbCloseArea())
	
	If lGrv
		aAdd( aLogDet, ""  )
		aAdd( aLogDet, STR0014 ) //"Observação: o Saldo Anterior quando negativo é lançado como Horas Debitadas no Mês (determinação do MOS)."
	EndIf

End Sequence
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Gera o Log de Processamento                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !Empty( aLogDet )
	aAdd( aLogTitle, OemToAnsi(STR0008) ) //"Filial    Matricula      Nome                               Saldo Ant.     Hr. Deb. Mes   Hr. Cred. Mes" )	
	fMakeLog( { aLogDet } , aLogTitle , cPerg )
EndIF

Return( NIL )