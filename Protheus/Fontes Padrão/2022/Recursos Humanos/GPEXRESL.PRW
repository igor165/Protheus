#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM040A.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³          ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ FNC            ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Leandro Dr.  ³08/01/14³M12RH01         ³Unificacao das Folhas. Projeto Versao 12  ³±±
±±³             ³        ³REQ.: 001973    ³Criacao do Fonte. Funcoes de calculo      ³±±
±±³             ³        ³                ³utilizadas na rescisao localizados        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o      ³ fDesPerAnt ³ Autor ³ Kelly Soares           ³ Data ³  20/06/2006  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o   ³ Gera verba de desconto dos dias pagos a maior no periodo anterior ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe     ³ fDesPerAnt()                   						   		  	 ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno     ³ aRetorno { Verba , Referencia , Valor }					         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fDesPerAnt()
                                        
Local aArea		:= GetArea()

Local nX
Local nValProv	:= 0
Local cRotAux	:= ""
Local cQuery	:= ""
Local cTabela	:= ""
Local cPrefixo	:= ""
Local cCpoVerba	:= ""
Local cCpoValor	:= ""
Local cFil		:= SRA->RA_FILIAL
Local cMat  	:= SRA->RA_MAT
Local cChave	:= ""
Local cCondSrv	:= ""       
Local cIndice	:= ""
Local cVerbaPro	:= ""
Local cCodiNova := aCodFol[648][1]
Local cDescNova := ""
Local cTipoNova	:= ""
Local aAberto	:= {}
Local aFechado	:= {}
Local aTodos 	:= {}
Local aRetorno	:= {}
Local aPerAux	:= {}
Local bCondSrv  := { || NIL }
                     
PosSrv(cCodiNova,xFilial("RCH"))
cDescNova := SRV->RV_DESC
cTipoNova := SRV->RV_TIPO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem periodos referentes ao mes e ano de demissao.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fRetPerComp( 	StrZero(Month(dDataDem1),2)	,;		// Mes
				StrZero(Year(dDataDem1),4)	,;		// Ano
				xFilial("RCH")				,;		// Filial
				cProcesso					,;		// Processo
				NIL							,;		// Roteiro
				@aAberto					,;		// Periodos Abertos
				@aFechado					,;		// Periodos Fechados
				@aPerAux    				)		// Periodos Abertos e Fechados em Ordem Crescente
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ignora periodos com roteiro diferente de FOL ou branco     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 to len(aPerAux)			 
	If ( aPerAux[nX][8] == fGetCalcRot('1') ) .or. ( Empty(aPerAux[nX][8] ) )
		aAdd( aTodos , aPerAux[nX] )
	EndIf
Next nX


If Len(aTodos) > 0                                                        

	#IFDEF TOP      
			
		For nX := 1 to len(aTodos)

			cRotAux := aTodos[nX][8]
			If Empty(cRotAux)
				cRotAux := fGetCalcRot('1')
			EndIf
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Determina tabela a ser utilizada, de acordo com data de    ³
		//³ fechamento do periodo.                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If Ascan( aAberto , { |x| x[1] == aTodos[nX][1] } ) > 0
				cTabela  := "SRC"
				cPrefixo := "SRC.RC_"
			Else
				cTabela  := "SRD"
				cPrefixo := "SRD.RD_"
			EndIf						
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona apenas verbas de provento.                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			cQuery := " SELECT SUM(" + cPrefixo + "VALOR) AS TOTAL "
			cQuery += " FROM " + RetSqlName(cTabela) + " " + cTabela
			cQuery += " INNER JOIN " + RetSqlName("SRV") + " SRV ON "
			cQuery += " ( " + cPrefixo + "PD = SRV.RV_COD AND SRV.RV_TIPOCOD = '1' AND "
			cQuery += " NOT SRV.RV_REFFER = 'S' AND NOT SRV.RV_REF13 = 'S' ) "
			cQuery += " WHERE " + cPrefixo + "FILIAL  = '" + cFil          + "' AND "
			cQuery += 			  cPrefixo + "MAT     = '" + cMat          + "' AND "
			cQuery += 			  cPrefixo + "PROCES  = '" + cProcesso     + "' AND "
			cQuery += 			  cPrefixo + "PERIODO = '" + aTodos[nX][1] + "' AND "
			cQuery += 			  cPrefixo + "SEMANA  = '" + aTodos[nX][2] + "' AND "
			cQuery += 			  cPrefixo + "ROTEIR  = '" + cRotAux       + "' AND "
			cQuery +=             cTabela  + ".D_E_L_E_T_ <> '*' "
	
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QRY', .F., .T.)			

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acumula valor total de proventos do periodo.               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			nValProv += QRY->TOTAL

			dbCloseArea()
			
		Next nX

	#Else   
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta variavel "cVerbaPro" com verbas do tipo 1 - Prov. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		bCondSrv := { |e| If (ValType(e) = "C",&(e),If (ValType(e) = "B",Eval(e),.F.)) }
		cCondSrv := "SRV->RV_TIPOCOD == '1' .And. SRV->RV_REFFER != 'S' .And. SRV->RV_REF13 != 'S'"
		SRV->(dBeval({||cVerbaPro+=SRV->RV_COD+"/"},{||Eval(bCondSrv,cCondSrv)} ))
		
		For nX := 1 to len(aTodos)
		
			cRotAux := aTodos[nX][8]
			If Empty(cRotAux)
				cRotAux := fGetCalcRot('1')
			EndIf		

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Determina tabela a ser utilizada, de acordo com data de    ³
			//³ fechamento do periodo.                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If Ascan( aAberto , { |x| x[1] == aTodos[nX][1] } ) > 0
				cTabela   := "SRC"
				cPrefixo  := "SRC.RC_"
				cIndice   := "RC_FILIAL + RC_MAT + RC_PROCES + RC_ROTEIR + RC_PERIODO + RC_SEMANA"
				cCpoVerba := "SRC->RC_PD"
				cCpoValor := "SRC->RC_VALOR"
			Else
				cTabela   := "SRD"
				cPrefixo  := "SRD.RD_"
				cIndice   := "RD_FILIAL + RD_MAT + RD_PROCES + RD_ROTEIR + RD_PERIODO + RD_SEMANA"
				cCpoVerba := "SRD->RD_PD"
				cCpoValor := "SRD->RD_VALOR"
			EndIf						
					
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula valor total de proventos do periodo.               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea(cTabela)
			DbSetOrder( RetOrder( cTabela, cIndice ) )   
			cChave := cFil + cMat + cProcesso + cRotAux + aTodos[nX][1] + aTodos[nX][2]
			If DbSeek( cChave )	
				While !Eof() .and. &(cTabela + "->(" + cIndice + ")") == cChave
					If &(cCpoVerba) $ cVerbaPro
						nValProv += &(cCpoValor)
					EndIf
					DbSkip()
				Enddo		
			EndIf
		
		Next nX

	#EndIf   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Proporcionaliza valor total de proventos de acordo com     ³
	//³ dias pagos a maior.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nValProv > 0  
		nDiasDesc := 30 - Day(dDataDem1)
		If ( nValProv := ( nValProv / 30 ) * nDiasDesc ) > 0
			aAdd( aRetorno , cCodiNova )
			aAdd( aRetorno , cDescNova )
			aAdd( aRetorno , cTipoNova )
			aAdd( aRetorno , nDiasDesc )
			aAdd( aRetorno , nValProv  )
		EndIf
	EndIf

EndIf

RestArea(aArea)

Return ( aRetorno )

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o      ³ fMontSeqRes³ Autor ³ Kelly Soares           ³ Data ³  20/07/2006  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o   ³ Monta sequencia de verbas na rescisao                             ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe     ³ fMontSeqRes()                  						   		  	 ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno     ³ LOGICO                                     				         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fMontSeqRes()
                                
Local aSRRCols		:= ( oGet:aCols )
Local aColsAnt		:= aClone( aSRRCols )
Local aColsCopy		:= aClone( aSRRCols )
Local cNumSeq		:= ""
Local cStrCols 		:= ""
Local cStrCopy		:= ""
Local lRet			:= .T.
Local nX			:= 0
Local nSeq			:= 0
Local nPosOrd		:= 0
Local nPosCc		:= GdFieldPos( "RR_CC" 		)
Local nPosSe		:= GdFieldPos( "RR_SEMANA"	)
Local nPosSq		:= GdFieldPos( "RR_SEQ"		)
Local nPosPd		:= GdFieldPos( "RR_PD"		)
Local nPosMat		:= GdFieldPos( "RR_MAT"		)
Local nPosDeleted	:= GdFieldPos( "GDDELETED"	)
Local nLenCols		:= Len( aSRRCols )
Local nSvn			:= n
Local cCod			:= aSRRCols[ n , nPosPd ]

cNumSeq		:= PosSrv( aSRRCols[ n , nPosPD ] , SRA->RA_FILIAL, "RV_QTDLANC" )
cStrCols 	:= aSRRCols[ n , nPosPd ] + aSRRCols[ n , nPosCc ] + aSRRCols[ n , nPosSe ]

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³O Numero Minimo de Lancamentos Permitidos e sempre "1"        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
// Se a verba tem a opcao de lancamento diario, nao tratar sequencia.
// So podera ter um lancamento da verba por dia.
cLcto := PosSRV(cCod , cFilial , "RV_LCTODIA" )

// Foi desativado a validacao de Lancamento diario pois nao existe o campo de Data de Referencia
If ( Empty( cNumSeq ) .or. ( cNumSeq == "1" ) .or. Empty( cCod ) )  
	If Val(cNumSeq) <= 1 
		If ( cLcto == "S" )
			aCposKey := { "RR_PD" , "RR_DATA"}
		Else
			aCposKey := { "RR_PD" , "RR_CC" , "RR_SEQ", "RR_DATA" }
		EndIf
		
		If !( GdCheckKey( aCposKey , 4 ) )
			Return( .F. )
		EndIf
	EndIf
EndIf	

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Salva Sequencia inicial de aCols para poder restaura-la na mes³
³ma ordem.                                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
For nX := 1 To nLenCols
	aAdd( aColsCopy[ nX ] , StrZero( nX , 4 ) )
Next nX

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Posicao da Ordem de Entrada								   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nPosOrd := Len( aColsCopy[ nX - 1 ] )

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Ordena aColsCopy com as Chaves Respectivas                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aSort(aColsCopy, NIL, NIL, { |x,y|	x[nPosPd] + x[nPosCc] + x[nPosSe] + IIF(Empty(x[nPosSq]), Replicate("Z", aHeader[nPosSq, 4]), x[nPosSq]) + x[nPosOrd] <;
						 			y[nPosPd] + y[nPosCc] + y[nPosSe] + IIF(Empty(y[nPosSq]), Replicate("Z", aHeader[nPosSq, 4]), y[nPosSq]) + y[nPosOrd];
							} )

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Renumera Sequencia de Lancamentos                             ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cStrCols:= "*"
For nX := 1 To nLenCols				
	If (aColsCopy[nX, nPosDeleted] )
		aColsCopy[nX, nPosSq] := Space(aHeader[nPosSq, 4] )
		Loop
	EndIf
		
	cStrCopy := aColsCopy[nX, nPosPd] + aColsCopy[nX, nPosCc] + aColsCopy[nX, nPosSe]			
		
	If (nX == 1) .OR. cStrCopy != cStrCols
		cStrCols:= cStrCopy
		cNumSeq	:= PosSrv(aColsCopy[nX, nPosPd], SRA->RA_FILIAL, "RV_QTDLANC")
		nSeq	:= 0
	EndIf		

	nSeq++
			
	If (nSeq <= Val(cNumSeq) )
		If (((nX == nLenCols) .OR. (cStrCopy != aColsCopy[nX+1, nPosPd] + aColsCopy[nX+1, nPosCc] + aColsCopy[nX+1, nPosSe])) .AND.;
			 (nSeq == 1))
			aColsCopy[nX, nPosSq] := Space(aHeader[nPosSq, 4])		
		Else
			aColsCopy[nX, nPosSq] := StrZero(nSeq, aHeader[nPosSq, 4] )
		EndIf
	Else
		Help(" ", 1, "A090MAXSEQ")
		Return .F. 
	EndIf
Next nX

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Restaura Sequencia original de aColsCopy                      ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aSort( aColsCopy ,,, { |x,y| x[ nPosOrd  ] < y[ nPosOrd  ] } )

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Atualiza a Sequencia de Lancamentos                           ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
For nX := 1 To Len( aSRRCols )
	//T// Ajuste devido a loopping
	If len(aColsOld) == Len( aSRRCols )
		aColsOld[ nX , nPosSq ] := aColsCopy[ nX , nPosSq ]
	EndIf
	aSRRCols[ nX , nPosSq ] := aColsCopy[ nX , nPosSq ]
Next nX

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Verifica se Existe o Objeto oGet:oBrowse para o Refresh()	   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If ( Type("oGet:oBrowse") == "O" )
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Compara o Conteudo para verificar se Houve Alteracao          ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If !ArrayCompare( aColsAnt , aSRRCols )
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Repintando o Browse da GetDados							   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		oGet:oBrowse:Refresh()
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Restaura Posicao de n Apos Refresh do Browse da GetDados	   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		n := nSvn
	EndIf	
EndIf
	
Return( lRet )

/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ M040ResM2		³Autor³ Mauricio Takakura ³ Data ³25/03/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Funcao de Calculo Rescisao para o Modelo 2 Folha Mexico     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEM040                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function M040ResM2(cAlias,nReg,nOpcx)
                  
Local cProces
Local cRoteir  	:= fGetCalcRot('4')	// Rescisao
Local nPosStatus  
Private lResM2 := .F.

//Verificar se esta com Calculo de Finiquito ou calculo de Aplicacion de Finiquito
DbSelectArea("SRC")
DbSetOrder(RetOrdem("SRC","RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA"))
DbSeek(SRA->(RA_FILIAL+RA_MAT+RA_PROCES)+cRoteir, .F.)
If SRC->(Eof())
  	cSvRoteir := cRoteir 
  	cRoteir := fGetCalcRot('A')	// Aplicacao de Rescisao
   	DbSeek(SRA->(RA_FILIAL+RA_MAT+RA_PROCES)+cRoteir, .F.)
   	If SRC->(Eof())
   	   cRoteir := cSvRoteir
   	EndIf
EndIf
              
If nOpcx == 2
	cProces   := SRA->RA_PROCES  
	nPosStatus:= If( SRA->RA_SITFOLH = 'D', 2, 1)
  	If fGetTipoRot( cRoteir ) == "4"	
		GPEM022(cProces, cRoteir, nPosStatus, .T., SRA->RA_MAT,,,, .T.)
	Else
		cHelp := OemToAnsi( STR0004 ) + CRLF + OemToAnsi( STR0005 ) // "Ja existe um calculo de Aplicaçao"  ##  "de Rescisao para esse Funcionario!"
		Help(' ',1,"GPM040CAL",, cHelp , 1 , 0)
	EndIf

ElseIf nOpcx == 3 .Or. nOpcx == 4

	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³ Inicializa o filtro utilizando a funcao FilBrowse, Faltara um filtro   ³
	  ³ da tabela SRC que sera executado depois do dbSetOrder pois o dbSetOrder|
	  ³ elimina o filtro do FilBrowse                                          |
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
  	aArray := {"SRA", "SRV", "SRC" }
	lResM2:= .T.
	Gpea090Mnt( cAlias, nReg, nOpcx-1,, cRoteir, 2, .T. )
	lResM2:= .F.
EndIf
Return()

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³fRotOrdPer³Autor³Gisele Varandas            ³Data³29/07/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Verificar existencia de periodo para roteiro ordinario		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³GPEM040				     				             	   	³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function fRotOrdPer( cProcesso, cPeriodo, cNumPag, cRotOrdinar )

Local aArea		:= GetArea()
Local cFilRCH
Local lRet 		:= .F.

Begin Sequence

 	If Empty( cProcesso ) 
 		lRet := .F.
		Break
	EndIf

	cFilRCH	:= xFilial("RCH")
	DbSelectArea("RCH")
	RCH->( dbsetOrder( Retorder( "RCH" , "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR" ) ) )
	RCH->( dbSeek( cFilRCH + cProcesso + cPeriodo + cNumPag, .F. ) )

	While RCH->( !Eof() .and. ((RCH_FILIAL + RCH_PROCES + RCH_PER + RCH_NUMPAG) == (cFilRCH + cProcesso + cPeriodo + cNumPag )))	
			If RCH->(( RCH_ROTEIR == cRotOrdinar .and. Empty( RCH_DTFECH )) .Or.;
						(Empty( RCH_ROTEIR ) .and. Empty( RCH_DTFECH )))
				lRet := .T.
				Exit
			EndIf
			RCH->( dbSkip() )
	EndDo

End Sequence

RestArea( aArea )
		
Return( lRet )  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LiqResAnt ºAutor  ³Microsiga           º Data ³  07/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LiqResAnt()

Local nRegAnt		:= 0

If !Empty(nRegSrg)
	nRegAnt	:= SRG->(Recno())
	SRG->(DbGoTo(nRegSrg))
	SRR->(DbSetOrder(1)) //RR_FILIAL+RR_MAT+RR_TIPO3+DTOS(RR_DATA)+RR_PD+RR_CC
EndIf

If SRR->(DbSeek(SRG->RG_FILIAL + SRG->RG_MAT + "R" + DtoS(SRG->RG_DTGERAR) + aCodFol[303,1] ))
    fo_ADD(@oSRR,{"RR_PD", "RR_VALOR"}, { fGetCodFol("0303") , SRR->RR_VALOR } )                                                                                           
EndIf

If !Empty(nRegAnt)
	SRG->(DbGoTo(nRegAnt))
EndIf

Return(.T.) 