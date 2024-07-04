#INCLUDE "Protheus.ch"
#INCLUDE "ATFXMI.CH"

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValIndCHI บAutor  ณMicrosiga           บ Data ณ  10/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function ValIndCHI( dInDepr, nTxVar )

	Local lResult	:= GetNewPar("MV_CCDL824",.F.)
	Local aArea		:= GetArea()

	Default dInDepr := SN3->N3_DINDEPR
	Default nTxVar	:= 1

    If FWIsInCallStack("ATFA050")

        If lResult
            If	Alltrim( str(Year(dDataBase)) )+;
            Alltrim( Strzero(Month(dDataBase),2) ) >=;
            Alltrim( str(Year(SN3->N3_AQUISIC)) )+;
            Alltrim( Strzero(Month(SN3->N3_AQUISIC),2) )
                DbSelectArea( "SNF" )
                SNF->( DbSetOrder( 1 ) )
                If Year( SN3->N3_AQUISIC ) < Year( dDataBase )
                    cSeek := Subs(DTOS(dDatabase),1,4)+"00"+Strzero(Month(dDataBase),2)
                Else
                    cSeek := Subs(DTOS(SN3->N3_AQUISIC),1,6)+Strzero(Month(dDataBase),2)
                EndIf

                If  subs(dtos(dDatabase),1,6) > subs(dtos(SN3->N3_AQUISIC),1,6) .And.;
                SNF->( DbSeek(xfilial("SNF") + cSeek  ) )
                    nTxVar := ( (Abs(SNF->NF_PERCIPC) / 100) + 1 ) * If(SNF->NF_PERCIPC < 0,-1,1)
                Else
                    nTxVar := 1
                EndIf
            EndIf
        EndIf

        RestArea( aArea )

    EndIf

    

Return ( lResult )


/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCalcCMCHI บAutor  ณMicrosiga           บ Data ณ  10/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function CalcCMCHI( cMoedaATF )

	Local lResult		:= .T.
	Local nDecimals		:= 0
	Local nDepr1		:= 0
	Local nDiferenca	:= 0
	Local nVlAtual		:= 0
	Local nQtPerDp		:= 0
	Local nQtDpAcm		:= 0
	Local i				:= 0
	Local nDepAtu		:= 0
	Local nDepAnt		:= 0

	// Verifica็ใo da classifica็ใo de Ativo se sofre deprecia็ใo
	Local lAtClDepr := .F.

    If FWIsInCallStack("ATFA050")
        If lResult
            nTaxaCorr	:= 0	// Taxa para as Correcoes do Bem e da Depreciacao
            nValCorr	:= 0	// N4_OCORR $ ('07')	N4_TIPOCNT $ ('1','2')		Correcao do Bem no mes
            nValCorDep	:= 0	// N4_OCORR $ ('08')	N4_TIPOCNT $ ('4','5')		Correcao da Depreciacao Acumulada
            nValCorDAC	:= 0	// N4_OCORR $ ('08')	N4_TIPOCNT $ ('8')		Depr Acum do Exercicio Anterior

            // Valida se o bem ja iniciou o tempo de depreciacao
            // Nao permitindo o calculo de Correcao no mes de aquisicao
            If	lCalcula .and.;
                ( MesAnoATF(SN3->N3_DINDEPR) <= MesAnoATF(dDataBase) )

                nTaxaCorr	:= nMVVALCORR := aTxMedia[ Val(cMoedaAtf) ]
                nVlAtual	:= N3_VORIG1 + N3_AMPLIA1 + N3_CLVRCOA	// Valor Atualizado
                nQtPerDp	:= ( 1 / aTaxaMes[ 1 ] )				// Qtd Total de Periodos de Depreciacao
                nQtDpAcm	:= GetNroDep(@nDepAnt,@nDepAtu)			// Qtd de Periodos ja calculados

                // Correcao Monetaria sobre o Custo de Aquisicao310506
                If nMVVALCORR < 0
                    nValCorr  := Abs( nVlAtual ) - Round( Abs( nVlAtual * nMVVALCORR ), nDecimals )
                Else
                    nValCorr  := Round(	Abs( nVlAtual * nMVVALCORR ), nDecimals ) - Abs( nVlAtual )
                Endif

                nVlAtual	+= nValCorr		//Corrige o Valor de aquisicao.
                nValCorr	-= N3_VRCBAL1	//Subtrai o acumulado, deixando apenas o calculo do mes.

                If nQtDpAcm > nQtPerDp
                    nValCorDep	:= Round( nVlAtual - ( N3_VRDACM1 + N3_VRCDA1 ), nDecimals )
                Else
                    nValCorDep	:= Round(((N3_CLVRDEA + (N3_VRCDA1 - N3_VRCDB1)) * (Abs(nMVVALCORR) - 1)),nDecimals)
                    If nMVVALCORR < 0
                        nValCorDep *= -1
                    Endif
                    nValCorDep -= N3_VRCDB1
                Endif

                // Extrai a Cota de Depreciacao relativa a Correcao Calculada enquanto no periodo de depreciacao
                // *******************************
                // Controle de multiplas moedas  *
                // *******************************
                If Empty( SN3->N3_FIMDEPR )
                    aValDepr := AtfMultMoe(,,{|x| aValDepr[x] := If(x == 1,(Round(((((nVlAtual - (N3_CLVRDEA + N3_VRCDA1 + nValCorDep))) / (nQtPerDp - nDepAnt)) * (nDepAtu + 1)) - N3_VRDBAL1,nDecimals)),Round( aValDepr[1] / RecMoeda(dDataBase, x/*Moeda*/),MsDecimais(x)))})

                    //Nao permite valores menores que zero
                    For i := 1 to Len( aValDepr )
                        If aValDepr[ i ] < 0
                            aValDepr[ i ] := 0
                        Endif
                    Next i

                    // Ajusta o valor da cota ao limite do residuo apurado.
                    nDiferenca :=	Round( Abs( N3_VORIG1 + N3_VRCACM1 + N3_AMPLIA1 ), X3Decimal('N3_VORIG1') ) -;
                    Round( Abs( aValDepr[1] + N3_VRDACM1 ), X3Decimal('N3_VORIG1') )
                Endif

                nTaxaDepr := nMVVALCORR
                nTaxaDepr := IIf( la30Embra, ExecBlock("A30EMBRA",.F.,.F.), nTaxaDepr )

            EndIf

            //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
            //ณ Trata os resกduos de depreciaÿao.  ณ
            //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
            If Round( nDiferenca, nDecimals ) < 0
                nDepr1 :=	Abs( N3_VORIG1 + N3_VRCACM1 + N3_AMPLIA1 ) -;
                Abs( N3_VRDACM1 + N3_VRCDA1 )
            EndIf

            // Verifica็ใo da classifica็ใo de Ativo se sofre deprecia็ใo
            lAtClDepr := AtClssVer((cAliasSn1)->N1_PATRIM)
            If ! (lAtClDepr .OR. EMPTY((cAliasSn1)->N1_PATRIM))
                // *******************************
                // Controle de multiplas moedas  *
                // *******************************
                aValDepr 	:=  AtfMultMoe(,,{|x| 0}) 
                //nValDepr1 := 0; nValDepr2 := 0; nValDepr3 := 0; nValDepr4 := 0; nValDepr5 := 0
                nValCorDep := 0
            EndIf

            If Empty(SN3->N3_CCORREC)
                nValCorr := 0
            EndIf
            If Empty(SN3->N3_CDESP)
                nValCorDep := 0
            EndIf
        Endif

    EndIf

Return ( lResult )

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetNroDep บAutor  ณMicrosiga           บ Data ณ  02/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetNroDep(nDepAnt,nDepAtu)

	Local nResult	:= 0
	Local nMesAux	:= 0
	Local nAnoAux	:= 0
	Local cDtInDepr	:= ""

	Default nDepAnt	:= 0
	Default nDepAtu	:= 0

	cDtInDepr := SubStr(Dtos(SN3->N3_DINDEPR), 1, 6)
	nAnoAux := Val(Substr(cDtInDepr, 1, 4))
	While (cDtInDepr < Substr(Dtos(dDatabase), 1, 6) )
		nResult++
		If nAnoAux < Year(dDataBase)
			nDepAnt++
		Else
			nDepAtu++
		Endif
		nMesAux		:= IIf( Val(Substr(cDtInDepr, 5, 2)) = 12, 0, Val(Substr(cDtInDepr, 5, 2)) )
		nAnoAux		:= IIf( Val(Substr(cDtInDepr, 5, 2)) = 12, Val(Substr(cDtInDepr, 1, 4)) + 1, Val(Substr(cDtInDepr, 1, 4)))
		cDtInDepr	:= StrZero( nAnoAux, 4 ) + StrZero( nMesAux + 1, 2 )
	EndDo

Return (nResult)


/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValIndArg บAutor  ณMicrosiga           บ Data ณ  10/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ValIndArg( dInDepr, nTxVar )

	Local lResult := .T.
    Local cIniDeprec := ""

	Default dInDepr := SN3->N3_DINDEPR
	Default nTxVar	:= 0

    If FWIsInCallStack("ATFA050")
        If lResult
            //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
            //ณ Taxa de Correcao dos bens para Argentina  ณ
            //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
            If cPaisLoc == "ARG"
                DbSelectArea( "SIE" );	SIE->( DbSetOrder( 1 ) )
                cSeek := ""
                If Month( dDataBase ) == 1
                    cSeek := Str(Year(dDatabase)-1,4) + Strzero(12,2)
                Else
                    cSeek := Str(Year(dDatabase),4) + Strzero(Month(dDatabase)-1,2)
                EndIf
                nTaxaAnt := IIf(SIE->(DbSeek(xFilial("SIE")+cSeek)), SIE->IE_INDICE, 1)
                cSeek := Str( Year(dDatabase), 4 ) + StrZero( Month(dDatabase),2,0 )
                nTaxaAtu := IIf(SIE->(DbSeek(xFilial("SIE")+cSeek)), SIE->IE_INDICE, 0)

                nTxVar :=( nTaxaAtu / nTaxaAnt )
                nTxVar -= IIf( nTxVar < 1, 0, 1 )

                If	Alltrim(    str( Year(dDataBase))) +;
                Alltrim(Strzero(Month(dDataBase), 2)) >=;
                Alltrim(    str( Year(SN3->N3_AQUISIC))) +;
                Alltrim(Strzero(Month(SN3->N3_AQUISIC), 2))
                    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
                    //ณ nNroMeses -> nro Total de meses em que o Ativo ser'a depreciado    ณ
                    //ณ nMesCalc  -> O nro de meses em que o Ativo est'a sendo depreciado  ณ
                    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
                    nNroMeses := Int((100/SN3->N3_TXDEPR1)) * 12

                    cIniDeprec := SubStr(Dtos(SN3->N3_DINDEPR), 1, 6)
                    nMesCalc := 0
                    While (cIniDeprec <= Substr(Dtos(dDatabase), 1, 6) )
                        //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
                        //ณ Ano de inicio de depreciacao e o mesmo que ano da database         ณ
                        //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
                        nMesCalc := nMesCalc + 1
                        nMesAux  := IIf( Val(Substr(cIniDeprec, 5, 2)) = 12, 0, Val(Substr(cIniDeprec, 5, 2)) )
                        nAnoAux  := IIf( Val(Substr(cIniDeprec, 5, 2)) = 12, Val(Substr(cIniDeprec, 1, 4)) + 1, Val(Substr(cIniDeprec, 1, 4)))
                        cIniDeprec  := StrZero(nAnoAux,4)+StrZero(nMesAux+1,2)
                    EndDo

                    nMesCalc := nNroMeses - nMesCalc + 1
                EndIf
            EndIf
        EndIf
    EndIf

Return ( lResult )

/*
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCalcCMARG บAutor  ณMicrosiga           บ Data ณ  10/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CalcCMARG( cMoedaATF )

	Local lResult		:= .T.
	Local nDecimals		:= X3Decimal('N3_VORIG' + cMoedaAtf)
	Local nDepr1		:= 0
	Local nDiferenca	:= 0
	Local lAtClDepr 	:= .F.

    If FWIsInCallStack("ATFA050")
        If lResult
            nTaxaCorr	:= 0	// Taxa para as Correcoes do Bem e da Depreciacao
            nValCorr	:= 0	// N4_OCORR $ ('07')	N4_TIPOCNT $ ('1','2')		Correcao do Bem no mes
            nValCorDep	:= 0	// N4_OCORR $ ('08')	N4_TIPOCNT $ ('4','5')		Correcao da Depreciacao Acumulada
            nValCorDAC	:= 0	// N4_OCORR $ ('08')	N4_TIPOCNT $ ('8')		Depr Acum do Exercicio Anterior
            // Valida se o bem ja iniciou o tempo de depreciacao
            // Nao permitindo o calculo de Correcao no mes de aquisicao
            If	lCalcula .and. ( MesAnoATF(SN3->N3_DINDEPR) <= MesAnoATF(dDataBase) )
                nTaxaCorr := nMVVALCORR := aTxMedia[ Val(cMoedaAtf) ]
                // Correcao Monetaria sobre o Custo de Aquisicao
                If nMVVALCORR < 0
                    nValCorr  := 	Abs(( N3_VRCACM1 + N3_VORIG1 + N3_AMPLIA1 )) - Round(Abs(( N3_VORIG1 + N3_VRCACM1 + N3_AMPLIA1) * nMVVALCORR ), nDecimals )
                Else
                    nValCorr  := Round(	Abs(( N3_VORIG1 + N3_VRCACM1 + N3_AMPLIA1) * nMVVALCORR ), nDecimals ) - Abs(( N3_VRCACM1 + N3_VORIG1 + N3_AMPLIA1 ))
                Endif
                // Extrai a Cota de Depreciacao relativa a Correcao Calculada enquanto no periodo de depreciacao
                // ********************************
                // Controle de multiplas moedas  *
                // ********************************
                If Empty(SN3->N3_FIMDEPR)
                    nValCorDep := Round( nValCorr * aTaxaMes[1], nDecimals ) + Round( N3_VRDACM1 * ( aTxMedia[Val(cMoedaATF)] - 1 ), nDecimals)
                    aValDepr := AtfMultMoe(,,{|x|	aValDepr[ x ] += If( x==1, nValCorDep, Round( (nValCorDep / RecMoeda( dDataBase, x /*Moeda*/)) * aTaxaMes[ x ], nDecimals ) ) })
                    nValCorDep += Round( N3_VRCACM1 * aTaxaMes[1], nDecimals )
                    // Ajusta o valor da cota ao limite do residuo apurado.
                    nDiferenca :=	Round( Abs( N3_VORIG1 + N3_VRCACM1 + N3_AMPLIA1 ), X3Decimal('N3_VORIG1') ) - Round( Abs( aValDepr[1] + N3_VRDACM1 ), X3Decimal('N3_VORIG1') )
                Endif
                nTaxaDepr := nMVVALCORR
                nTaxaDepr := IIf( la30Embra, ExecBlock("A30EMBRA",.F.,.F.), nTaxaDepr )
            EndIf
            //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
            //ณ Trata os resกduos de depreciaÿao.                                     ณ
            //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
            If Round( nDiferenca, nDecimals ) < 0
                nDepr1 :=	Abs( N3_VORIG1 + N3_VRCACM1 + N3_AMPLIA1 ) -;
                Abs( N3_VRDACM1 + N3_VRCDA1 )
            EndIf
            // Verifica็ใo da classifica็ใo de Ativo se sofre deprecia็ใo
            lAtClDepr := AtClssVer((cAliasSn1)->N1_PATRIM)
            If ! ( lAtClDepr .OR. EMPTY((cAliasSn1)->N1_PATRIM) )
                // ********************************
                // Controle de multiplas moedas  *
                // ********************************
                aValDepr 	:=  AtfMultMoe(,,{|x| 0}) 
                nValCorDep := 0
            EndIf
            If Empty(SN3->N3_CCORREC)
                nValCorr := 0
            EndIf
            If Empty(SN3->N3_CDESP)
                nValCorDep := 0
            EndIf
        Endif
    EndIf

Return(lResult)

/*/
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFA050   บAutor  ณMicrosiga           บ Data ณ  25/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que verifica a condi็ใo para o Fim da Deprecia็ใo   บฑฑ
ฑฑบ          ณ da moeda Fiscal - Uso exclusivo para o pais PTG            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AtFimDeprF                                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ sem parametro de entrada                                   บฑฑ
ฑฑบ          ณ Retorno: .T. / Continuidade do calculo de depreciacao      บฑฑ
ฑฑบ          ณ          .F. / Limite encontrado para o calculo depreciacaoบฑฑ
ฑฑบMelhoria  ณ sem parametro de entrada                                   บฑฑ
ฑฑบFrancisco ณ------------------------------------------------------------บฑฑ
ฑฑบJr - 06/10ณModificacao para uso do valor maximo de depreciacao         บฑฑ
ฑฑบ          ณn3_vmxdepr                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
*/
Function AtFimDeprF()

	Local cMoedaAtf	:= GetMV("MV_ATFMOED")
	Local lResult	:= .T.
	Local nAnosMax	:=0
	Local nMes		:=0

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ   Condi็๕es no calculo de depreciacao na Moeda Fiscal                                  ณ
	//ณ   definido pelo governo de Portugal                                                    ณ
	//ณ   cPaisLoc == "PTG", condicao utilizada antes da chamada                               ณ
	//ณ                                                                                        ณ
	//ณ1- Vlr acumulado + Vlr Acumulado da Taxa Perdida >= valor do bem                        ณ
	//ณ2- Vlr acumulado >= Vlr maximo de deprecia็a๕o (nao considera a taxa perdida acumulada) ณ
	//ณ3- Tempo de deprecia็ใo utilizado at้ o momento > (Tempo de deprecia็ใo usual * 2)      ณ
	//ณ4- Continuidade do calculo de deprecia็ใo Fiscal                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

    If FWIsInCallStack("ATFA050")    
        If ABS(&("SN3->N3_VRDACM"+cMoedaAtf))+ ABS(SN3->N3_VLACTXP) >= ABS(&("SN3->N3_VORIG"+cMoedaAtf)) 	//1-
            lResult	:= .F.
        Else
            If (cPaisLoc == "PTG")
                If !Empty(SN1->N1_PRZDEPR)
                    nAnosMax := Year(SN3->N3_DINDEPR) + (SN1->N1_PRZDEPR * 2)
                    nMonth   := Month(SN3->N3_DINDEPR)
                    dDataMax := cTod( "01/" + StrZero(nMonth,2) + "/" + cValTochar( nAnosMax ) )
                    If dDatabase > dDataMax
                        lResult	:= .F.
                    EndIf
                Endif
            Endif
        Endif
    EndIf
Return lResult



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF010ACVCLบAutor  ณTOTVS			    บ Data ณ  13/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza as opera็ใoes de conversao de tipos para localiza  บฑฑ
ฑฑบ          ณ ็ใo da colombia                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA010                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF010ACVCL(cAlias,nReg,nOpc)
Local lRet 		:= .T.
//encontrada fun็ใo nas branchs 103, trazido para o ATFXMI conforme chamada no ATFXOLD.
If nOpc == 1 // Converter
	lRet := MsgYesNo(STR0001)//"Deseja converter o bem ? "
	If lRet
		MsgRun(STR0002,"",{|| AF010ACVDP() })//"Convertendo Bem Aguarde"
	EndIf
Else // Cancelar a conversใo
	lRet := MsgYesNo(STR0003) //"Deseja cancelar a conversใo do bem ?"
	If lRet
		MsgRun(STR0004,"",{|| AF010ACNDP() })// "Cancelando a conversใo do bem Aguarde"
	EndIf
EndIf 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF010ACNDPบAutor  ณTOTVS			    บ Data ณ  13/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza o cancelamento da conversao dos tipos da localiza  บฑฑ
ฑฑบ          ณ ็ใo da Colombia                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF010ACNDP()
    Local aArea			:= GetArea()
    Local aAreaSN3		:= SN3->(GetArea())
    Local lRet			:= .F.
    Local cFunBaixa	 	:= GetNewPar("MV_ATFRTBX", "ATFA030" ) 
    Local dMVUltDepr	:= GetMV("MV_ULTDEPR")

    Private cMoedaAtf := GetMV("MV_ATFMOEDA")
    Private cMoeda
    Private lPrimlPad := .T.
    Private nTotal := 0
    Private nHdlPrv := 0
    Private LUSAMNTAT  := .F.
    Private lAuto		:= .T.

    dbSelectArea("SN3")
    dbSetOrder( 1 )

    // Realiza o cancelamento da baixa do tipo 52
    If SN3->(dbSeek( xFilial("SN3") + SN1->N1_CBASE + SN1->N1_ITEM + "50" )) .And. SN3->N3_BAIXA = '0'
    
        // Realiza o cancelamento da baixa do tipo 52
        If SN3->(dbSeek( xFilial("SN3") + SN1->N1_CBASE + SN1->N1_ITEM + "52" )) .And. SN3->N3_BAIXA >= '1'
            If SN3->N3_DTBAIXA > dMVUltDepr
            If ALLTRIM(cFunBaixa) == "ATFA030"
                lRet := AF030Cance("SN3",SN3->(Recno()),,,.T.)
            Else
                lRet := AF035Cance("SN3",SN3->(Recno()),,,.T.)
            EndIf
        Else
                Help("  ",1,"AF010CVNBA") //"Operacao invalida. Existe calculo de depreciacao posterior a baixa."
            EndIf
        Else
            Help("  ",1,"AF010CVNB") //"Este bem nao possui um item de depreciacao por Reducao de Saldos baixado."
        EndIf
        
        // Apaga e contabiliza a exclusใo do tipo 50
        If lRet .And. SN3->(dbSeek( xFilial("SN3") + SN1->N1_CBASE + SN1->N1_ITEM + "50" ))
            If VerPadrao('80B')
                nHdlPrv := HeadProva(cLoteAtf,AllTrim(cFunBaixa),Substr(cUsername,1,6),@cArquivo)
                nTotal += DetProva(nHdlPrv,'80B',AllTrim(cFunBaixa),cLoteAtf)
                If nHdlPrv > 0 .And. ( nTotal > 0 )
                    RodaProva(nHdlPrv, nTotal)
                    cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,.T.,.F.)
                Endif
            Endif
            RecLock("SN3",.F.)
            SN3->(dbDelete())
            MsUnlock()
        EndIf
        
    Else
        Help("  ",1,"AF010CVNC") //"Este bem nao possui um item depreciacao por M้todo Linear para cancelamento."
    EndIf


    RestArea(aAreaSN3)
    RestArea(aArea)

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF010ACVDPบAutor  ณTOTVS			    บ Data ณ  13/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a conversao dos tipos 52 para 50 para localizacao  บฑฑ
ฑฑบ          ณ de Colombia                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF010ACVDP() 
Local nTaxa			:= 0    
Local nPeriodo 		:= 1 
Local aStru			:= {}
Local dUltDepr		:= GetMV("MV_ULTDEPR")+1
Local cCalcDep		:= SuperGetMv("MV_CALCDEP",.F.,"")
Local i				:= 0
Local nI			:= 0
Local aDados		:= {}
Local aArea			:= GetArea()
Local aAreaSN3		:= SN3->(GetArea())
Local lRet			:= .T.
Local nQtdOrig 		:= IIF(SN1->N1_QUANTD == 0,1,SN1->N1_QUANTD)
Local nHdlPrv		:= 0
Local nTotal		:= 0
Local cFunBaixa	 	:= GetNewPar("MV_ATFRTBX", "ATFA030" )
Local __nQuantas	:= If(lMultMoed,AtfMoedas(),5)
Local cMoed			:= ""
Local aRecAtf 		:= {}
Local cIDMOV	:= ""    
Local cTpSaldo	:= ""
Local lSN3Saldo := SN3->(FieldPos("N3_TPSALDO")) > 0
Local cOcorr 	:= ""
Local aDadosComp :={}
Local aValores   := {} 

Private	dBaixa030	:= dDataBase
Private nValCorr	:= 0
Private aVlrAtual	:= If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
Private aVlResid 	:= If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
Private aValBaixa	:= If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
Private aValDepr 	:= If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
Private aDepr 		:= If(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} )
Private dDindepr
Private lUmaVez		:= .T.
Private lAuto		:= .T.
Private nValCorDep	:= 0
Private lSN7      	:= .F.
Private lUsaMntAt	:= .F.
Private cMotivo		:= "08"
Private nPercBaixa	:= 100
Private lQuant		:= .F.
Private lPrim		:= .T.
Private cLoteAtf 	:= LoteCont("ATF")

//AVP2
//Verifica implementacao do AVP e AVP parcela
If lAvpAtf2 == NIL
	lAvpAtf2 := If(FindFunction("AFAvpAtf2"),AFAvpAtf2(),.F.)
Endif

aStru := SN3->(dbStruct())
dbSelectArea("SN3")
dbSetOrder( 1 )

If SN3->(dbSeek( xFilial("SN3") + SN1->N1_CBASE + SN1->N1_ITEM + "52" ))
	
	dDinDepr := SN3->N3_DINDEPR
	cSeq	 := SN3->N3_SEQ
	If (cCalcDep == "0" .and. !(dDataBase >= dUltDepr .and. dDataBase <= LastDay(dUltDepr))) .OR.;
		(cCalcDep == "1" .and. !(Year(dDataBase) == Year(dUltDepr)))
		Help("  ",1,"AF010CVDT") //"Periodo para conversao invalido."
		lRet := .F.
	Endif
	
	If lRet .And. (SN3->N3_VRDACM1+SN3->N3_VLSALV1) >= (SN3->N3_VORIG1)
		Help("  ",1,"AF010CVBI") //"Este bem ja esta totalmente depreciado"
		lRet := .F.
	Endif
	
	If lRet
		For i := 1 to Len(aStru)
			AAdd(aDados,{ aStru[i,1] , SN3->&(aStru[i,1]) })
		Next
		
		For i:= 1 to __nQuantas
			cMoed := Alltrim(Str(i))
			aValBaixa[i] := Abs(SN3->&("N3_VORIG"+cMoed))
			aVlrAtual[i] := aValBaixa[i]
		Next
		
		nPeriodo += ((Year(dDataBase)*12+Month(dDataBase)) - (Year(dDinDepr)*12+Month(dDinDepr)))
		
		nTaxa := Round(100/((SN3->N3_PERDEPR-nPeriodo)/12),X3Decimal("N3_TXDEPR1"))
		
		lRet := AF030DtBx(dDataBase)
		
		If lRet
			If ALLTRIM(cFunBaixa) == "ATFA030"
				Af030Calc("SN3", "", "", .F.,0,nQtdOrig,.T.)
			Else
				Af035Grava("SN3", "", "", .F.,0,nQtdOrig,.T.)
			EndIf
			
			Reclock("SN3",.T.)
			For nI := 1 to Len(aDados)
				SN3->(&(aDados[nI][1])) := aDados[nI][2]
			Next nX
			
			SN3->N3_TIPO 	:= "50"
			SN3->N3_DINDEPR	:= dUltDepr
			If SN3->(FieldPos("N3_VLSALV1")) > 0
				SN3->N3_VLSALV1 := 0
			EndIf
			If SN3->(FieldPos("N3_PERDEPR")) > 0
				SN3->N3_PERDEPR := 0
			EndIf
			SN3->N3_SEQ		:= Soma1(cSeq)
			
			For i:= 1 to __nQuantas
				cMoed := Alltrim(Str(i))
				SN3->&("N3_VORIG" +cMoed)	:= SN3->&("N3_VORIG"+cMoed)+SN3->&("N3_AMPLIA"+cMoed)-SN3->&("N3_VRDACM"+cMoed)
				SN3->&("N3_TXDEPR"+cMoed)	:= nTaxa
				SN3->&("N3_VRDMES"+cMoed)	:= 0
				SN3->&("N3_VRDACM"+cMoed)	:= 0
				SN3->&("N3_VRDBAL"+cMoed)	:= 0
			Next
			
			MsUnlock()
			cOcorr 	   := "05"
			aDadosComp := ATFXCompl( 0 , &(If(Val(cMoedaAtf)>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf),/*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, IIf(SN3->(FieldPos("N3_PRODMES"))>0,SN3->N3_PRODMES,0) )
			aValorMoed := AtfMultMoe(,,{|x| SN3->&("N3_VORIG" + Alltrim(Str(x)) ) })
			If lSN3Saldo
				cTpSaldo := SN3->N3_TPSALDO
			EndIf
			ATFXMOV(cFilAnt,@cIDMOV,dDataBase,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,cSeq,SN3->N3_SEQREAV,"1",SN1->N1_QUANTD,cTpSaldo,,aValorMoed,aDadosComp,,.T.)
			
			Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao

			ATFSaldo(SN3->N3_CCONTAB,dDataBase,"1",SN3->N3_VORIG1,SN3->N3_VORIG2,SN3->N3_VORIG3,;
			SN3->N3_VORIG4,SN3->N3_VORIG5,"+",,SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValBaixa )
			
			If VerPadrao("80A")
				nHdlPrv := HeadProva(cLoteAtf,AllTrim(cFunBaixa),Substr(cUsername,1,6),@cArquivo)
				nTotal += DetProva(nHdlPrv,"80A",AllTrim(cFunBaixa),cLoteAtf)
				
				If nHdlPrv > 0 .And. ( nTotal > 0 )
					RodaProva(nHdlPrv, nTotal)
					cA100Incl(cArquivo,nHdlPrv,3,cLoteAtf,.T.,.F.)
				Endif
			Endif
		EndIf
	Endif
Else
	Help("  ",1,"AF010CVNI") //"Este bem nao possui depreciacao por Reducao de Saldos"
EndIf

RestArea(aAreaSN3)
RestArea(aArea)

Return
