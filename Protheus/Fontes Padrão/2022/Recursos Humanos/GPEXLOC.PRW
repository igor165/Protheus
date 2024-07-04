#INCLUDE "gpexloc.ch"  
#INCLUDE "PROTHEUS.CH"
#DEFINE MESES_REM_VAR	6      //Maximo 12, sino reveer calculo
 
#DEFINE _FERIAS      1
#DEFINE _AGUINALDO 	 2
#DEFINE _PGINDE      3
#DEFINE _DCINDE      4
#DEFINE _PGAVISO     5
#DEFINE _DCAVISO     6

#DEFINE _LIMSF1   1
#DEFINE _VALSF1   2
#DEFINE _LIMSF2   3
#DEFINE _VALSF2   4
#DEFINE _LIMSF3   5
#DEFINE _VALSF3   6
#DEFINE _DIASMIN  7

// Defines para reliquidacao (Chile)
#DEFINE _TABRL		3

#DEFINE _SLMIN		1
#DEFINE _UTMUF		2
#DEFINE _APOPA		3
#DEFINE _SLFAM		4
#DEFINE _IMPUN		5
#DEFINE _CMPMS		6
#DEFINE _AFP		7
#DEFINE _SGCES		8


STATIC lPagofer,nMesAntec13
Static aIRAdic
Static aSinDic
Static aMedic
Static aFerPag
Static nBaseIRRes
Static aPdTemp
Static aPdRes
Static aSegCesa
Static aApolices,aDadosBSE
Static aIRDedAno
Static aIRAno
Static lSalFp
Static lSalFd

Static nBsBpsAuxUru

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOGPExloc ³Autor  ³Microsiga                     ³Fecha ³  07/20/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcoes do LOC usadas em localizacoes                                 º±±
±±º          ³                                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                                  º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±º         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                       º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±ºProgramador ³ Data     ³ Nr. FNC        ³  Motivo da Alteracao                   º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±ºLeandro Dr. ³27/09/2012³M12RH01 		   ³Unificao da Folha. Projeto Versao 12    º±± 
±±º            ³          ³RHU210_04_01	   ³                                        º±±
±±ºCícero Alves³04/03/2015³		 		   ³Retirada das funções AjustaSx6 e  		º±± 
±±º            ³          ³				   ³AcertHlp                                º±±
±±³Marcos Cout.³08/03/2017³MRH-7420  	   ³Realizar ajustes de compatibilização    ³±±
±±³            ³          ³                ³dos progra³mas para Mercado Internacional±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCSALFAM ºAutor  ³Microsiga           ºFecha ³  07/20/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do salario Familiar                                 º±±
±±º          ³Ex asalfam.prx                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOCSALFAM()
Local nMeses
Local nDif
Local nValSF	:=	0
Local nIndSF	:=	1
Local cDataIni	:="      "
Local cDataFim	:="      "
Local nTopeBase	:=	0     
Local nTotPreNatal   :=	0                                        
Local nTotAyuda 		:=	0
Local nPos1	
Local nPos2 
Local nPos3	
Local nPosA	        
Local   nSalAux 	:= salario 
Local nSalFamAnt := 0 
Local llDepSf		:= Iif(SRA->(FieldPos("RA_DEPSF"))>0,.T.,.F.)

If Type("nDiasFer") == "U" 
	nDiasFer := 0
EndIf

SetPrvt("NBASESALFA")
SetPrvt("NMES,NANO,NTOTDISC,NTOTHIJO,CCALCSF,NBASFAMES,")
nBaseSalfa := 0
nMes       := 0
nAno       := 0
nTotDisc   := 0
nTotHijo   := 0
nBasFaMes  := 0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao calcula se nao tiver dependente de salario familia informado      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If llDepSf
	If Val(SRA->RA_DEPSF) == 0
		Return
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para funcion rios recebem quinzenalmente,deve ser calculado somente   ³
//³ na segunda quinzena semana do mˆs                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SRA->RA_TIPOPGT == "S" .And. !lUltSemana .And. cPaisLoc <> "ARG"
	Return
EndIf

If cPaisLoc == "ARG"
 	nPos1	:=	Ascan(aSalFamArg,{|x| x[1]=='1'})
 	nPos2 :=	Ascan(aSalFamArg,{|x| x[1]=='2'})
 	nPos3	:=	Ascan(aSalFamArg,{|x| x[1]=='3'})
 	nPosA	:=	Ascan(aSalFamArg,{|x| x[1]=='A'})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao calcula se nao tiver dependente de salario familia informado      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPos3*nPos1*nPos2*nPosA == 0
		If GetRemoteType() == -1
			MsgLogGrid( Ap5GetHelp("GPEXSFAM"), .F. ) // Retornar string da funcao Help
		Else
	  		Help(" ",1,"GPEXSFAM")
	 	EndIf
		Return ( .F. )                                                  
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existem dependentes                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SRB" )
	dbSetOrder(1)
	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
	While !Eof() .And. SRB->RB_FILIAL + SRB->RB_MAT == SRA->RA_FILIAL + SRA->RA_MAT
		//Verificar se o filho ja nasceu (para ficar prevenido em calculos retroativos).
		If (SRB->RB_DTNASC <= dDataBase)
			If SRB->RB_TIPSF == "1"
				nTotDisc++
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verificar si corresponde pagar de acurdo con la edad del hijo³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SRB->RB_TIPSF == "2"
				IF CALC_IDADE(dDataBase,SRB->RB_DTNASC) <=  aSalFamArg[nPos2][3]
					nTotHijo++
				Endif
				IF AnoMes(SRB->RB_DTESCOL)==AnoMes(dDataBase) .And. CALC_IDADE(dDataBase,SRB->RB_DTNASC) <=  aSalFamArg[nPosA][3]
					nTotAyuda++
				Endif
			Endif
		Else
			If SRB->RB_TIPSF == "3"
				nMes	:=	Month(SRB->RB_DTNASC)-Month(dDataBase)
            nMes 	:=	IIf(nMes<0,nMes+12,nMes) 
            nMes	:=	9-nMEs
				If nMes == 4    
					nTotPreNatal += 4 
				ElseIf nMes > 4
					nTotPreNatal++
				Endif
			Endif
		Endif
		dbSkip()
	Enddo
	
	If (nTotHijo + nTotDisc + nTotPreNatal + nTotAyuda) > 0
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Somar as incidencias para apurar a base salario familiar       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aeval( aPd ,{ |X| SomaInc(X,21,@nBaseSalFa,,,,,,.T.,aCodfol) })  // Incidencia Salario Familia
		
		// SOMA O SALARIO BASE AUTOMATICAMENTE NA BASE SAL.FAMILIA		
		nBaseSalFa += If(nDiasMat > 0 .And. PosSrv(aCodFol[040,1],SRA->RA_FILIAL,"RV_SALFAMI") == "S", nSalAux / 30 * DiasTrab, nSalAux )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Semanalistas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SRA->RA_TIPOPGT == "S" 
			Aeval( aPD,{ |X| nSalFamAnt   += If(X[1] == aCodFol[34,1] .And. X[3] < cSemana .And. MesAno(dData_pgto) == MesAno(X[10]) .And. X[9] # "D",X[5],0)} )
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Encuentra el rango del promedio salarial y calcula³
		//³la asigancion para hijo                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTotHijo > 0
			nPosFaixa	:=	Ascan(aSalFamArg[nPos2][2],{|x| nBaseSalFa <= x[1] })
			If nPosfaixa > 0
				FGeraVerba(aCodFol[034,1],(aSalFamArg[nPos2][2][nPosFaixa][2]*(nTotHijo)) - nSalFamAnt,nTotHijo)
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Encuentra el rango del promedio salarial y calcula³
		//³la asignacion para pre-natal                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTotPreNatal > 0
			nPosFaixa	:=	Ascan(aSalFamArg[nPos3][2],{|x| nBaseSalFa <= x[1] })
			If nPosfaixa > 0
				FGeraVerba(aCodFol[034,1],(aSalFamArg[nPos3][2][nPosFaixa][2]*(nTotPreNatal)) - nSalFamAnt,nTotPreNatal)
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Encuentra el rango del promedio salarial y calcula³
		//³la asigancion para hijo discapacitado             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTotDisc > 0
			nPosFaixa	:=	Ascan(aSalFamArg[nPos1][2],{|x| nBaseSalFa <= x[1] })
			If nPosFaixa > 0
				FGeraVerba(aCodFol[034,1],(aSalFamArg[nPos1][2][nPosFaixa][2]*nTotDisc) - nSalFamAnt,nTotDisc)
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Encuentra el rango del promedio salarial y calcula³
		//³la asigancion para ayuda escolar                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTotAyuda > 0
			nPosFaixa	:=	Ascan(aSalFamArg[nPosA][2],{|x| nBaseSalFa <= x[1] })
			If nPosFaixa > 0
				FGeraVerba(aCodFol[204,1],(aSalFamArg[nPosA][2][nPosFaixa][2]*nTotAyuda) - nSalFamAnt,nTotAyuda)
			Endif
		Endif
	Endif
ElseIf cPaisLoc == "PAR"
	
	If Type("lSalFp") == "U" .Or. Type("lSalFd") == "U"
		lSalFp := SuperGetmv("MV_SALFP", .F., "S")
		lSalFd := SuperGetmv("MV_SALFD", .F., "S")
	EndIf	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somar as incidencias para apurar a base de salario familiar    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aeval( aPd ,{ |X| SomaInc(X,21,@nBaseSalFa,,,,,,.T.,aCodfol) })  // Incidencia Salario Familia
	
	//Verificar se o valor do salario nao excede o valor maximo para pagamento
	// de asignacao familiar
	If nBaseSalFa	<= ((nLimSF1/100) * VAL_SALMIN)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Obedece a tabela pre-definida                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea( "SRB" )
		dbSetOrder(1)
		dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
		While !Eof() .And. SRB->RB_FILIAL + SRB->RB_MAT == SRA->RA_FILIAL + SRA->RA_MAT
			//Verificar se o filho ja nasceu (para ficar prevenido em calculos retroativos).
			If (SRB->RB_DTNASC <= dDataBase)
				If SRB->RB_TIPSF == "1"
					nTotHijo := nTotHijo + 1
					//Verificar se o filho ja fez 17 anos
				ElseIf SRB->RB_TIPSF == "2"
					IF Year(dDataBase) - Year(SRB->RB_DTNASC) <= nLimSF2-1  .Or. ;
						(Year(dDataBase) - Year(SRB->RB_DTNASC) == nLimSF2 .And.;
						Substr(Dtos(dDataBase),5,4) <=Substr(Dtos(SRB->RB_DTNASC),5,4))
						nTotHijo := nTotHijo + 1
					Endif
				Endif
			Endif
			dbSkip()
		Enddo
		If lSalFp == "S"
			DiasFamil := DiasBase := If(lSalFd == "S",nUlt_dia,30)
			If YEAR(SRA->RA_ADMISSA) = YEAR(dDataBase) .AND. MONTH(SRA->RA_ADMISSA) = MONTH(dDataBase).AND. DAY(SRA->RA_ADMISSA) # 1
				Diasfamil := DiasFamil - Day(SRA->RA_ADMISSA) + 1
				If !Empty(dDatadem)
					Diasfamil := (Day(dDatadem) - Day(SRA->RA_ADMISSA)+1)
				EndIf
			Elseif  ! Empty(dDataDem)
				DiasFamil := Day(dDataDem)
			EndIf
			ValTot := ((VAL_SALMIN * (nVAL_SF1/100))*(nTotHijo))
			FGeraVerba(aCodFol[034,1], Round( ((ValTot / DiasBase) * DiasFamil),MsDecimais(1)),nTotHijo )	
		ElseIf (nTotHijo > 0) 
			//O calculo no paraguai eh uma porcentagem acima do salario minimo
			FGeraVerba(aCodFol[034,1], Round((VAL_SALMIN* (nVAL_SF1/100))*(nTotHijo),MsDecimais(1)),nTotHijo)
		Endif
	Endif
ElseIf cPaisLoc == "CHI"
	//Carrega os valores do salario familiar
	//Quando trabalha menos que um mínimo determinado por causa de doenca
	//o pagamento do salario Familiar eh proporcional.
	If c__Roteiro == "RES"
		If Max((Day(dDataDem)-(nDiasAfas - nDiasFer)),0 ) < aSalFam[_DIASMIN]
			nIndSF	:=	Max((Day(dDataDem) - (nDiasAfas-nDiasFer)),0) / 30
		EndIf
	ElseIf Max((30 - (nDiasAfas - nDiasFer)),0) < aSalFam[_DIASMIN]
		nIndSF	:=	Max((30-(nDiasAfas- nDiasFer)),0) / 30
	Endif
	If Empty(SRA->RA_TRAMFAM)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calculo Pro-Medio                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nMes := 1
		nAno := Year(dDataBase)
		If Month(dDataBase)	<= 6
			nAno--
		Endif
		cDataIni := Strzero(nAno,4) + Strzero(nMes,2)
		cDataFim := Strzero(nAno,4) + '06'
		dbSelectArea( "SRD" )
		dbSetOrder(1)
		MsSeek( xFILIAL() + SRA->RA_MAT + cDataIni , .T. )
		//Nao tem historico Valido
		If Eof() .Or. SRD->RD_DATARQ > StrZero(nAno,4)+'06'
			nMeses	:=	 0
			//Foi admitido em este mes, desconsidero para o promedio
		ElseIf Val(SRD->RD_MES) == Month(SRA->RA_ADMISSA) .And. Day(SRA->RA_ADMISSA) > 1
			nMeses	:=	6 - Val(SRD->RD_MES)
			cDataIni	:=	Strzero(nAno,4)+StrZero(Val(SRD->RD_MES)+1,2)
		Else		//Considerar os 6 meses (ou os meses desde que foi admitido)
			nMeses	:=	6 - (Val(SRD->RD_MES) + 1)
			cDataIni	:=	Strzero(nAno,4)+SRD->RD_MES
		Endif
		
		If nMeses > 0
			cDataIni := Strzero(nAno,4) + Strzero(nMeses,2)
			MsSeek( xFilial() + SRA->RA_MAT + cDataIni)
			
			While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT .And.SRD->RD_DATARQ <= cDataFim
				If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_SALFAMI") == "S"
					nBaseSalFa := nBaseSalFa + SRD->RD_VALOR
				Endif
				dbSkip()
			Enddo
			nBaseSalfa /=	nMeses
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Somar as incidencias para apurar a base Salario familia        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Aeval( aPd ,{ |X| SomaInc(X,21,@nBaseSalFa,,,,,,.T.,aCodfol) })  // Incidencia Salario Familia
			nBaseSalFa := nBaseSalFa
		Endif
		Do Case
			Case nBaseSalFa <= aSalFam[_LIMSF1]
				nValSF	:=	aSalFam[_VALSF1]
			Case nBaseSalFa > aSalFam[_LIMSF1] .And. nBaseSalFa <= aSalFam[_LIMSF2]
				nValSF	:=	aSalFam[_VALSF2]
			Case nBaseSalFa > aSalFam[_LIMSF2] .And. nBaseSalFa <= aSalFam[_LIMSF3]
				nValSF	:=	aSalFam[_VALSF3]
		EndCase
	Else
		Do Case
			Case SRA->RA_TRAMFAM == "1"
				nValSF	:=	aSalFam[_VALSF1]
			Case SRA->RA_TRAMFAM == "2"
				nValSF	:=	aSalFam[_VALSF2]
			Case SRA->RA_TRAMFAM == "3"
				nValSF	:=	aSalFam[_VALSF3]
		EndCase
	Endif
	If nValSF	>	0
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Obedece a tabela pre-definida                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea( "SRB" )
		dbSetOrder(1)
		dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
		While !Eof() .And. SRB->RB_FILIAL + SRB->RB_MAT == SRA->RA_FILIAL + SRA->RA_MAT
			//Verificar se o filho ja nasceu (para ficar prevenido em calculos retroativos).
			If (SRB->RB_DTNASC <= dDataBase)
				If SRB->RB_TIPSF == "1"   //Sem limite de idade
					nTotHijo := nTotHijo + 1
				ElseIf SRB->RB_TIPSF == "2" // ate os 18 anos
					IF Year(dDataBase) - Year(SRB->RB_DTNASC) <= 18  .Or. ;
						(Year(dDataBase) - Year(SRB->RB_DTNASC) == 19 .And.;
						Substr(Dtos(dDataBase),5,4) <=Substr(Dtos(SRB->RB_DTNASC),5,4))
						nTotHijo := nTotHijo + 1
					Endif
				ElseIf SRB->RB_TIPSF == "3" //Ate os 24 anos
					IF Year(dDataBase) - Year(SRB->RB_DTNASC) <= 24  .Or. ;
						(Year(dDataBase) - Year(SRB->RB_DTNASC) == 25 .And.;
						Substr(Dtos(dDataBase),5,4) <=Substr(Dtos(SRB->RB_DTNASC),5,4))
						nTotHijo := nTotHijo + 1
					Endif
				ElseIf SRB->RB_TIPSF == "4" //Filho discapacitado
					nTotHijo := nTotHijo + 2
				Endif
			Endif
			If Substr(Dtos(SRB->RB_DTNASC),1,6) >= Substr(Dtos(dDataBase),1,6)
				If SRB->RB_TIPSF == "5" 		//Maternidade, ainda nao nasceu
					nTotHijo := nTotHijo + 1
				Endif
			Endif
			dbSkip()
		Enddo
		If nTotHijo > 0
			FGeraVerba(aCodFol[034,1], Round(nValSF*nTotHijo*nIndSF,MsDecimais(1)),nTotHijo)
		Endif
	Endif
ElseIf cPaisLoc == "URU"
	//Carrega os valores do salario familiar
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somar as incidencias para apurar a base de salario familiar    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aeval( aPd ,{ |X| SomaInc(X,21,@nBaseSalFa,,,,,,.T.,aCodfol) })  // Incidencia Salario Familia
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Obedece a tabela pre-definida                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SRB" )
	dbSetOrder(1)
	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
	While !Eof() .And. SRB->RB_FILIAL + SRB->RB_MAT == SRA->RA_FILIAL + SRA->RA_MAT
		//Verificar se o filho ja nasceu (para ficar prevenido em calculos retroativos).
		If (SRB->RB_DTNASC <= dDataBase)
			If SRB->RB_TIPSF == "1"
				nTotHijo := nTotHijo + 1
				//Verificar se o filho ja fez 17 anos
			ElseIf SRB->RB_TIPSF == "2"
				IF Year(dDataBase) - Year(SRB->RB_DTNASC) <= aSalFam[9]-1  .Or. ;
					(Year(dDataBase) - Year(SRB->RB_DTNASC) == aSalFam[9] .And.;
					Substr(Dtos(dDataBase),5,4) <=Substr(Dtos(SRB->RB_DTNASC),5,4))
					nTotHijo := nTotHijo + 1
				Endif
			Endif
		Endif
		dbSkip()
	Enddo
	If nTotHijo > 0 .and. aSalFam[2] > 0
		nTopeBase := aSalFam[1] + (aSalFam[2] * nTotHijo)
	Endif
	If nBaseSalFa	<= nTopeBase
		If nTotHijo > 0
			If nTotHijo <= aSalFam[3]
				FGeraVerba(aCodFol[034,1], Round(aSalFam[4] *(nTotHijo),MsDecimais(1)),nTotHijo)
			ElseIf nTotHijo <= aSalFam[5]
				FGeraVerba(aCodFol[034,1], Round(aSalFam[6] *(nTotHijo),MsDecimais(1)),nTotHijo)
			ElseIf nTotHijo <= aSalFam[7]
				FGeraVerba(aCodFol[034,1], Round(aSalFam[8] *(nTotHijo),MsDecimais(1)),nTotHijo)
			Endif
		Endif
	Endif
Endif
Return(nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCGerVac ºAutor  ³Microsiga           ºFecha ³  07/20/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo de ferias                                           º±±
±±º          ³Ex GerVacac.prx                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LOCGERVAC()        // incluido pelo assistente de conversao do AP5 IDE em 09/01/01
Local lIni		:= .F.
Local nDiasCorr	:= 0
Local nMesAtu	:= 0
Local nPos		:= 0
Local nMesSeg	:= 0
Local cSeq		:= " "
Local nAno		:= 0
Local nMes		:= 0
Local nDias		:= 0
Local cDataIni	:= ""
Local nRemVar	:= 0
Local nMediaOut	:= 0
Local nMediaHrs	:= 0
Local nMedia13s := 0
Local nAntec13o := 0
Local nPosVerb	:= 0
Local nPosSem   := 0
Local nOutAdic  := 0
Local lSabNUtil := .F. 
Local lParSab   := .F.
Local dDtBusFer
Local cTipoCod       
Local cIDVerba

SetPrvt("CACHOU,DDATABAS,NRECSRH,NDIASMES,NDIASMSE,NHORPROMED")
SetPrvt("NVALPROMED,NPROMEDIO,NVACACIONES,CARQDBF,CARQNTX,NPOS")
SetPrvt("LGERASEMANA,")
cAchou      := "N"
dDataBas    := ""
nRecSrh     := 0
nDiasMes    := 0
nDiasMse    := 0
nHorProMed  := 0
nValProMed  := 0
nProMedio   := 0
nVacaciones := 0
cArqDbf     := ""
cArqNtx     := ""
nPos        := 0
lGeraSemana := .F.

If cPaisLoc == "PAR"
	If SRA->(FieldPos('RA_SABUTIL')) > 0
  		lParSab := If(SRA->RA_SABUTIL == "1",.T.,.F.)
  	Endif	
Endif
If cPaisLoc $ "CHI" 
   lSabNUtil := .T.         
   nOutAdic  := 0        
ElseIf cPaisLoc == "PAR" .And. !lParSab
 	lSabNUtil := .T.
Endif
If SRA->RA_SITFOLH #"F"
	Return
Endif
If (SRA->RA_CATFUNC ="S" .Or. (SRA->RA_CATFUNC = "H" .AND. SRA->RA_TIPOPGT ="S"))
	nPosSem := Ascan(aPeriodo,{|X| x[2] == cSemana})
Endif	

dbSelectArea("SRH")
nRecSrh := Recno()
dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )

If cPaisLoc == "ARG"
	cDifFer	:= "N"  
	cAchou      := "N"
	While !Eof() .And. SRA->RA_FILIAL+SRA->RA_MAT == SRH->RH_FILIAL+SRH->RH_MAT
		If Month(SRH->RH_DTRECIB)==Month(dDatabase) .And. Year(SRH->RH_DTRECIB) == Year(dDatabase)
			If (SRA->RA_CATFUNC ="S" .Or. (SRA->RA_CATFUNC = "H" .AND. SRA->RA_TIPOPGT ="S")) .And. nPosSem > 0 
				If SRH->RH_DTRECIB >= aPeriodo[nPosSem,3] .And. SRH->RH_DTRECIB <= aPeriodo[ nPosSem,4] 
					cAchou	:= "S"
				Endif
				//--So gera a diferenca de ferias para semanalista na ultima semana do mes
				If (lUltSemana .and. !lDissidio) 
					cDifFer	:= "S"
				Endif	
			Else   // Mensalista
				cAchou	:= "S"
				cDifFer := "S"
			Endif	
			nDiasMes := SRH->RH_DFERIAS
			If cAchou = "S" 
				dbSelectArea("SRR")
				dBSetOrder(1)
				If dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+'F'+Dtos(SRH->RH_DTRECIB) )
					While !Eof() .And. SRA->RA_FILIAL+SRA->RA_MAT == SRR->RR_FILIAL+SRR->RR_MAT ;
						.And. SRH->RH_DTRECIB == SRR->RR_DATA .And. SRR->RR_TIPO3 == 'F'
						
						If (nPosVerb	:=	AScan(aPd,{|x| x[1] == SRR->RR_PD .And. x[9] <> "D" } )) > 0
							cSeq	:=	Soma1(aPd[nPosVerb][11])
						Else
							cSeq	:=	'1'
						Endif
						
						FMatriz(SRR->RR_PD,SRR->RR_VALOR,SRR->RR_HORAS,,,,"K",,,dData_Pgto,.T.,cSeq)
						dbSelectArea("SRR")
						dbSkip()
					Enddo
				Endif
			Endif	
		ElseIf Month(SRH->RH_DATAINI)==Month(dDatabase) .And. Year(SRH->RH_DATAINI) == Year(dDatabase)
			cDifFer := "S"
			nDiasMes := SRH->RH_DFERIAS
		Endif
		DbSelectArea("SRH")
		If cDifFer == "S"
			Aadd(aDifFer,{ Recno() , nDiasMes , nDiasMse })
		Endif	
		dbSkip()
	Enddo
ElseIf cPaisLoc $ "PAR/CHI"
	DEFAULT lPagoFer	:=	GetNewPar('MV_FERANT',.F.)
	lPagoFer	:= If(cPaisLoc == "CHI"	,.F.,lPagoFer)
	While !Eof() .And. SRA->RA_FILIAL+SRA->RA_MAT == SRH->RH_FILIAL+SRH->RH_MAT
		cDifFer	:= "N"
		lIni	:=	.F.
		If (Month(SRH->RH_DATAINI)==Month(dDatabase) .And. Year(SRH->RH_DATAINI) == Year(dDatabase) ).Or.;
			(Month(SRH->RH_DATAFIM)==Month(dDatabase) .And. Year(SRH->RH_DATAFIM) == Year(dDatabase) ).Or.;
			(dDataBase >= SRH->RH_DATAINI .And.	dDataBase <= SRH->RH_DATAFIM )
			
			//As ferias comecam e acabam no mesmo mes
			If Month(SRH->RH_DATAINI)==Month(SRH->RH_DATAFIM) .And. Year(SRH->RH_DATAINI) == Year(SRH->RH_DATAFIM)
				LocGHabRea(SRH->RH_DATAINI,SRH->RH_DATAFIM,@nMesAtu,@nDiasCorr,,,lSabNUtil)
				lIni	:=	.T.
				//As ferias comecam neste mes
			ElseIf (Month(SRH->RH_DATAINI)==Month(dDatabase) .And. Year(SRH->RH_DATAINI) == Year(dDatabase) )
				LocGHabRea(SRH->RH_DATAINI,Ctod(StrZero(F_ULTDIA(dDataBase),2)+"/"+Strzero(Month(dDataBase),2)+"/"+right(str(Year(dDataBase)),2),"ddmmyy"),@nMesAtu,@nDiasCorr,,,lSabNUtil)
				If !lPagoFer
					nMesSeg := (SRH->RH_DATAFIM - SRH->RH_DATAINI+1 )- nDiasCorr
				Else
					nMesSeg := SRH->RH_DFERIAS - nMesAtu
				Endif		
				lIni	:=	.T.
				//As ferias acabam neste mes
			ElseIf (Month(SRH->RH_DATAFIM)==Month(dDatabase) .And. Year(SRH->RH_DATAFIM) == Year(dDatabase) )
				LocGHabRea( Ctod("01/"+Strzero(Month(dDataBase),2)+"/"+right(str(Year(dDataBase)),2),"ddmmyy"),SRH->RH_DATAFIM,@nMesAtu,@nDiasCorr,,,,lSabNUtil)
				//As ferias comecaram antes e acabam depois deste mes
			Else
				LocGHabRea(Ctod("01/"+SubStr(DTOC(dDataBase),4)), Ctod(StrZero(F_ULTDIA(dDataBase),2)+"/"+Strzero(Month(dDataBase),2)+"/"+right(str(Year(dDataBase)),2),"ddmmyy"),@nMesAtu,@nDiasCorr,,,,lSabNUtil)
				If Month(dDataBase)+1 > 12
					nMesSeg	:=	LocFimFer(Ctod("01/01/"+right(str(Year(dDataBase)+1),2),"ddmmyy"),,"2",.T.)
				Else
					nMesSeg	:=	LocFimFer(Ctod("01/"+StrZero(Month(dDataBase)+1,2)+"/"+right(str(Year(dDataBase)),2),"ddmmyy"),,"2",.T.)
				Endif
			Endif
			
			cSeq := " "
			nPos := Ascan(aPd,{ |x| x[1] == aCodfol[72,1] .And. x[9] # 'D' .And. x[11] == cSeq} )
			If nPos > 0
				cSeq := Str( Val(cSeq)+1 ,1)
			Endif
			dbSelectArea("SRR")
			If dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+'F'+Dtos(SRH->RH_DTRECIB) )
				While !Eof() .And. SRA->RA_FILIAL+SRA->RA_MAT == SRR->RR_FILIAL+SRR->RR_MAT ;
					.And. SRH->RH_DTRECIB == SRR->RR_DATA .And. SRR->RR_TIPO3 == 'F'
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Descuento de Vacaciones         1                             ³
					//³ - No Paraguai o valor das ferias eh o mesmo que o valor de um³
					//³ dia trabalhado normal, e os Impostos sao calculados acima do ³
					//³ salario inteiro e nao sao calculados nas ferias.Por iso o sa-³
					//³ lario sera sempre pelos 30 dias e as ferias serao mais um    ³
					//³ desconto. Bruno 25/10/2001                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SRR->RR_PD == aCodfol[072,1]
						If lPagoFer
							If lIni
								FGeraVerba(aCodFol[060,1],Round((SRR->RR_VALOR/SRH->RH_DFERIAS)*nMesAtu,MsDecimais(1)),nMesAtu)
							Else
								FGeraVerba(aCodFol[164,1],Round((SRR->RR_VALOR/SRH->RH_DFERIAS)*nMesAtu,MsDecimais(1)),nMesAtu)
							Endif
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Previsao de desconto do proximo mes                          ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If nMesSeg	>	0
								FGeraVerba(aCodFol[089,1],Round((SRR->RR_VALOR/SRH->RH_DFERIAS)*nMesSeg,MsDecimais(1)),nMesSeg)
							Endif
						Else
						   If cPaisLoc == "CHI"
								FGeraVerba(aCodFol[072,1],Round((SRR->RR_VALOR/(SRH->RH_DATAFIM-SRH->RH_DATAINI+1))*nDiasCorr,MsDecimais(1)),nDiasCorr,,,,,,,,,cSeq)
							Else
								FGeraVerba(aCodFol[072,1],Round((SRR->RR_VALOR/SRH->RH_DFERIAS)*nMesAtu,MsDecimais(1)),nMesAtu)
							Endif	
						Endif
					ElseIf SRR->RR_PD == aCodfol[224,1]
						If lPagoFer
							FGeraVerba(aCodFol[060,1],Round((SRR->RR_VALOR/SRH->RH_DFERIAS)*nMesAtu,MsDecimais(1)),nMesAtu)
						Else
							FGeraVerba(aCodFol[224,1],Round((SRR->RR_VALOR/SRH->RH_DFERIAS)*nMesAtu,MsDecimais(1)),nMesAtu)
						Endif
					ElseIf SRR->RR_PD == aCodFol[369,1]
						FGeraVerba(aCodFol[369,1],Round(SRR->RR_VALOR,MsDecimais(1)),SRR->RR_HORAS)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Codigo de Liquido Pago em Ferias						     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ElseIf SRR->RR_PD == aCodfol[102,1] 
						If cPaisLoc == "CHI"
							FGeraVerba(aCodFol[102,1],Round((SRR->RR_VALOR),MsDecimais(1)),,,,,,,,,,cSeq)			
						Endif	
					Else   
						If cPaisLoc == "CHI"  
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Outros Codigos de Adicionais								 ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cTipoCod := PosSrv(SRR->RR_PD,SRA->RA_FILIAL,"RV_TIPOCOD")
							If ( cTipoCod == "1" )		//Provento
								nOutAdic := nOutAdic + SRR->RR_VALOR
								dDtPgFe  := fDtBusFer()							
							ElseIf ( cTipoCod == "2" )  //Desconto
								nOutAdic := nOutAdic - SRR->RR_VALOR
							Endif
						Endif
					Endif
					dbSelectArea("SRR")
					dbSkip()
				Enddo
			Endif
		Endif	
		If cPaisLoc == "CHI"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Outros adicionais Gera na Matriz						     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOutAdic > 0.00
				FGeraVerba(aCodFol[084,1],Round((nOutAdic),MsDecimais(1)),,,,,,,,,dDtPgFe,cSeq)			
			Endif   
		Endif	
		DbSelectArea("SRH")
		If cDifFer == "S"
			Aadd(aDifFer,{ Recno() , nDiasMes , nDiasMse })
		Endif	
		nRecSRH	:=	Recno()
		dbSkip()
	Enddo
ElseIf cPaisLoc == "URU"
	While !Eof() .And. SRA->RA_FILIAL+SRA->RA_MAT == SRH->RH_FILIAL+SRH->RH_MAT
		lIni	:=	.F.
		lFim	:=	.F.
		If (Month(SRH->RH_DATAINI)==Month(dDatabase) .And. Year(SRH->RH_DATAINI) == Year(dDatabase) ).Or.;
			(Month(SRH->RH_DATAFIM)==Month(dDatabase) .And. Year(SRH->RH_DATAFIM) == Year(dDatabase) ).Or.;
			(dDataBase >= SRH->RH_DATAINI .And.	dDataBase <= SRH->RH_DATAFIM )
			
			//As ferias comecam e acabam no mesmo mes
			If Month(SRH->RH_DATAINI)==Month(SRH->RH_DATAFIM) .And. Year(SRH->RH_DATAINI) == Year(SRH->RH_DATAFIM)
				LocGHabRea(SRH->RH_DATAINI,SRH->RH_DATAFIM,@nMesAtu,@nDiasCorr)
				lIni	:=	.T.
				lFim	:=	.T.
				//As ferias comecam neste mes
			ElseIf (Month(SRH->RH_DATAINI)==Month(dDatabase) .And. Year(SRH->RH_DATAINI) == Year(dDatabase) )
				LocGHabRea(SRH->RH_DATAINI,Ctod(StrZero(F_ULTDIA(dDataBase),2)+"/"+Strzero(Month(dDataBase),2)+"/"+right(str(Year(dDataBase)),2),"ddmmyy"),@nMesAtu,@nDiasCorr)
				nMesSeg := SRH->RH_DFERIAS - nMesAtu
				lIni	:=	.T.
				//As ferias acabam neste mes
			ElseIf (Month(SRH->RH_DATAFIM)==Month(dDatabase) .And. Year(SRH->RH_DATAFIM) == Year(dDatabase) )
				LocGHabRea( Ctod("01/"+Strzero(Month(dDataBase),2)+"/"+right(str(Year(dDataBase)),2),"ddmmyy"),SRH->RH_DATAFIM,@nMesAtu,@nDiasCorr)
				lFim	:=	.T.
				//As ferias comecaram antes e acabam depois deste mes
			Else
				LocGHabRea(Ctod("01/"+SubStr(DTOC(dDataBase),4)), Ctod(StrZero(F_ULTDIA(dDataBase),2)+"/"+Strzero(Month(dDataBase),2)+"/"+right(str(Year(dDataBase)),2),"ddmmyy"),@nMesAtu,@nDiasCorr)
				If Month(dDataBase)+1 > 12
					nMesSeg	:=	LocFimFer(Ctod("01/01/"+right(str(Year(dDataBase)+1),2),"ddmmyy"),,"2",.T.)
				Else
					nMesSeg	:=	LocFimFer(Ctod("01/"+StrZero(Month(dDataBase)+1,2)+"/"+right(str(Year(dDataBase)),2),"ddmmyy"),,"2",.T.)
				Endif
			Endif
			If SRA->RA_TIPOPGT == "M"
				cSeq := " "
				nPos := Ascan(aPd,{ |x| x[1] == aCodfol[72,1] .And. x[9] # 'D' .And. x[11] == cSeq} )
				
				If nPos > 0
					cSeq := Str( Val(cSeq)+1 ,1)
				Endif
				nVacaciones	:=	Round(SALDIA*nMesAtu,MsDecimais(1))
				If nVacaciones > 0
					FGeraVerba(aCodFol[072,1],nVacaciones,nMesAtu)
				Endif
				//Gera verba por outros adicionais
				dbSelectArea("SRR")
				/*
				If dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+'F'+Dtos(SRH->RH_DTRECIB)+aCodFol[75,1] )
					FGeraVerba(aCodFol[084,1],SRR->RR_VALOR*nMesAtu,nMesAtu)
				Endif  */
			ElseIf lIni
				//Gerar proventos das ferias e desconto o neto pago nas ferias,
				//para recalcular os impostos, dado que existem proventos pagos
				//nas ferias que devem ser gravados junto com o salario total.
				SRV->(DbSetOrder(1))
				dbSelectArea("SRR")
				dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+'F'+Dtos(SRH->RH_DTRECIB) )
				While !Eof() .And. SRA->RA_FILIAL+SRA->RA_MAT == SRR->RR_FILIAL+SRR->RR_MAT ;
					.And. SRH->RH_DTRECIB == SRR->RR_DATA .And. SRR->RR_TIPO3 == 'F'
					
					SRV->(DbSeek(xFilial()+SRR->RR_PD))
					If  (SRV->(FOUND()).And.SRV->RV_TIPOCOD == "1") .Or. SRR->RR_PD == aCodFol[102,1]
						FGeraVerba(SRR->RR_PD,SRR->RR_VALOR,SRR->RR_HORAS)
					Endif
					DbSkip()
				Enddo
			Endif
		Endif
		DbSelectArea("SRH")
		nRecSRH	:=	Recno()
		dbSkip()
	Enddo
Endif
DbSelectArea("SRH")
dbGoTo(nRecSrh)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LOCPRESENT³ Autor ³ MARCOS STIEFANO       ³ Data ³ 19/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula Premio Presentismo                                 ³±±
±±³          ³ Ex presente.prx                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOCPRESENT()
Local nBaseSind	:=	0
Local aSindTmp		:=	{}
Local nVlPresAnt  := 0

If cPaisLoc == "ARG" .And. !Empty(aCodFol[325,1])
	aSindTmp	:=	SetSindLoc(SRA->RA_SINDICA)
	If Len(aSindTmp) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Somar as incidencias para apurar a base aporte sindical        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aeval( aPd ,{ |X| SomaInc(X,20,@nBaseSind,,,,,,.T.,aCodfol) })  // Incidencia Contrib. Sindical
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Semanalistas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SRA->RA_TIPOPGT == "S" 
			Aeval( aPD,{ |X| nVlPresAnt += If(X[1] == aCodFol[325,1] .And. X[3] < cSemana .And. MesAno(dData_pgto) == MesAno(X[10]) .And. X[9] # "D",X[5],0)} )
		EndIf

		FGeraVerba(aCodFol[325,1],(nBaseSind*aSindTmp[10]/100)-nVlPresAnt ,aSindTmp[10])
	Endif
Endif
Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LOCLICESP ³ Autor ³ Bruno Sobieski        ³ Data ³ 11/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula las licencias especiales (Argentina)               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOCLICESP()
Local nDiasFer		:= 0
Local nVacaciones :=	0
Local cSeq			:=	'1'
Local aVerbas		:=	''
Local nValorVar	:=	0
If cPaisLoc == "ARG" 
	DbSelectArea('SR8')
	DbSetOrder(1)
	DbSeek(xFilial()+SRA->RA_MAT+Substr(DToS(dDataBase),1,6),.T.)
   While !EOF() .And. xFilial()+SRA->RA_MAT+Substr(DToS(dDataBase),1,6) == ;
	   		R8_FILIAL+R8_MAT+Substr(DToS(R8_DATAINI),1,6)

		If SR8->R8_TIPO == 'E' .And. !Empty(SR8->R8_LICESP)
			aVerbas	:=	GetLicEsp(SRA->RA_SINDICA,SR8->R8_LICESP)		
			If Len(aVerbas) > 0 
				nDiasfer	:=	SR8->R8_DATAFIM-SR8->R8_DATAINI + 1
				nVacaciones := ( ( SALMES / 25 ) * nDiasFer )
				If cSeq == '1'
					nValorVar	:=	GetRemVarD(dDataBase)*30/25
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Graba el valor de sueldo los dias de vacaciones³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FMatriz(aVerbas[1],nVacaciones,nDiasFer,,,,'C',,,,.F.,cSeq)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Graba el valor de valores variables de vac.    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FMatriz(aVerbas[2],nValorVar*nDiasFer,nDiasFer,,,,'C',,,,.F.,cSeq)
				cSeq	:=	Soma1(cSeq)
			Endif
		Endif
		DbSelectArea('SR8')
		DbSkip()
	EndDo
	
Endif
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GetLICESP ³ Autor ³ Bruno Sobieski        ³ Data ³ 11/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Pega as verbas das lic. especiais da tabela de parametros   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetLicEsp(cSindica,cTipoLic)
Local aVerbas	:=	{}
If FPHIST82( xFilial("SRX") , "70" , cSindica+cTipoLic)
	aVerbas	:=	{Substr(SRX->RX_TXT ,  27 , 03),Substr(SRX->RX_TXT ,  30 , 03) }
ElseIf FPHIST82( xFilial("SRX") , "70" , "  "+cTipoLic)
	aVerbas	:=	{Substr(SRX->RX_TXT ,  27 , 03),Substr(SRX->RX_TXT ,  30 , 03) }
Else
	MsgStop(STR0008+cTipoLic,STR0009+SRA->RA_MAT)
Endif

Return aVerbas

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOCJUBILA³ Autor ³ MARCOS STIEFANO       ³ Data ³ 19/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula Aporte Jubilatorio                                 ³±±
±±³          ³ EX aporteju.prx                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOCJUBILA()
Local nBsFrlFo	:= 0  
Local nBsFrlFe	:= 0  
Local nBsFrl13	:= 0  
Local nBsBpsFo 	:= 0
Local nBsBpsFe 	:= 0
Local nBsBps13 	:= 0
Local nFerMesFun:= 0    
Local nPos     := 0 
Local nPerPa   := 0
Local nMinPa   := 0
Local nMaxPa   := 0
Local nPerEm   := 0
Local nMinEm   := 0
Local nMaxEm   := 0
Local nBsApJub1	:= 0
Local nBsApJub2	:= 0
Local nBsBseFo	:= 0
Local nBsBseFe := 0
Local nBsBse13 := 0
Local nX	   := 0

Local nBaseJub1Ant := 0
Local nValApAnt := 0
Local nBaseJub2Ant := 0
Local nValPtAnt := 0
Local nFundDes	 := 0         
Local nAnosCasa := 0
Local nPercFun	 := 0      
Local nBasFunAnt:= 0
SetPrvt("NBASEAPJUB,NVALAPJUB,NVALPTJUB,NVALTOPE,NPERBA,NPERSJ,NPERSF,NPEREM,")
nBaseApJub := 0
nValApJub  := 0
nValPtJub  := 0
SetPrvt("NVALAPFRL,NVALPTFRL")

If cPaisLoc == "ARG"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtener los valores de :                                               ³
	//³nPerPA : Porcentaje de pago patronal                                   ³
	//³nMinPA : Base minima para el calculo de aporte patronal (en MOPREs)    ³
	//³nMaxPA : Base maxima para el calculo de aporte patronal (en MOPREs)    ³
	//³nPerEM : Porcentaje de deduccion al empleado                           ³
	//³nMinEM : Base minima para el calculo de aporte del empleado (en MOPREs)³
	//³nMaxEM : Base maxima para el calculo de aporte del empleado (en MOPREs)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FPHIST82( xFilial("SRX") , "60" , RhTamFilial(xFilial("SRA"))+MesAno(dDataBase))  .Or. FPHIST82( xFilial("SRX") , "60" , RhTamFilial(xFilial("SRA"))+"      ")
		nPerPA := Val( SubStr ( SRX->RX_TXT ,  01 , 05 ) )
		nMinPA := Val( SubStr ( SRX->RX_TXT ,  06 , 05 ) )
		nMaxPA := Val( SubStr ( SRX->RX_TXT ,  11 , 06 ) )
		nPerEM := Val( SubStr ( SRX->RX_TXT ,  17 , 05 ) )
		nMinEM := Val( SubStr ( SRX->RX_TXT ,  22 , 05 ) )
		nMaxEM := Val( SubStr ( SRX->RX_TXT ,  27 , 06 ) )
		If SRA->RA_SISTJUB=='2'
			nPerEM	:=	Val( SubStr ( SRX->RX_TXT ,  33 , 05 ) )
		Endif	
	Else
		Return .F.
	Endif
	nMinEM	*=	(nMOPRE*IIf(c__Roteiro$'131/132',0.5,IIf(c__Roteiro=="RES",diastrab/30,1)))
	nMaxEM	*=	(nMOPRE*IIf(c__Roteiro$'131/132',0.5,IIf(c__Roteiro=="RES",diastrab/30,1)))
	nMinPA  	*=	(nMOPRE*IIf(c__Roteiro$'131/132',0.5,IIf(c__Roteiro=="RES",diastrab/30,1)))
	nMaxPA	*=	(nMOPRE*IIf(c__Roteiro$'131/132',0.5,IIf(c__Roteiro=="RES",diastrab/30,1)))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somar as incidencias para apurar a base aporte jubilacion      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aeval( aPd ,{ |X| SomaInc(X,4,@nBaseApJub,,,,,,.T.,aCodfol) })  // Incidencia INSS
	
	nBsApJub1	:=	 nBaseApJub
	nBsApJub2	:=	 nBaseApJub
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ajustar minimo e maximos para o funcionario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nBsApJub1 < nMinEM
		nBsApJub1 := 0
	ElseIf nBsApJub1 > nMaxEM
		nBsApJub1 := nMaxEM
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ajustar minimo e maximos para o empregador ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nBsApJub2 < nMinPA
		nBsApJub2 := 0
	ElseIf nBsApJub2 > nMaxPA
		nBsApJub2 := nMaxPA
	Endif
	
	nValApJub := ( nBsApJub1* nPerEM ) / 100
	
	nValPtJub := ( nBsApJub2* nPerPA ) / 100
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Semanalistas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SRA->RA_TIPOPGT == "S" 
		If  c__Roteiro <> "FER"
			Aeval( aPD,{ |X| nBaseJub1Ant += If(X[1] == aCodFol[221,1] .And. X[3] < cSemana .And. X[9] # "D",X[5],0)} )
			Aeval( aPD,{ |X| nValApAnt   += If(X[1] == aCodFol[64,1] .And. X[3] < cSemana  .And. X[9] # "D",X[5],0)} )
			Aeval( aPD,{ |X| nBaseJub2Ant += If(X[1] == aCodFol[412,1] .And. X[3] < cSemana .And. X[9] # "D",X[5],0)} )
			Aeval( aPD,{ |X| nValPtAnt   += If(X[1] == aCodFol[148,1] .And. X[3] < cSemana  .And. X[9] # "D",X[5],0)} )
			Aeval( aPD,{ |X| nBasFunAnt  += If(X[1] == aCodFol[677,1] .And. X[3] < cSemana  .And. X[9] # "D",X[5],0)} )
		Else
			dbSelectArea("SRC")
			dbSetOrder(1)
			dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
			While SRC->( !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == RC_FILIAL + RC_MAT )
				If SRC->RC_PD == aCodFol[221,1] 
					nBaseJub1Ant += SRC->RC_VALOR
				ElseIf SRC->RC_PD == aCodFol[064,1]	 
					nValApAnt += SRC->RC_VALOR
				Endif	
				SRC->(dbSkip())
			Enddo
		Endif
	Endif
	
	If (nPos:= Ascan(aPd, { |X| X[1] = aCodfol[065,1] .And. X[9] # "D"})) > 0
		nFerMesFun := aPd[nPos,5]
	Endif
	If c__Roteiro == "FER"
		If nValApJub > 0
			If !Empty(aCodFol[013,1])
				FGeraVerba(aCodFol[013,1],nBsApJub1 - nBaseJub1Ant,0.00)  //Base Jub.Empregado Ferias
			Endif
			FGeraVerba(aCodFol[065,1],nValApJub - nValApAnt,nPerEM)    //Jubilacion Ferias
      Endif
   Else
   	If nValApJub - nFerMesFun > 0
			If !Empty(aCodFol[221,1])
				FGeraVerba(aCodFol[221,1],nBsApJub1- nBaseJub1Ant,0.00)
			Endif
			If !Empty(aCodFol[412,1])
				FGeraVerba(aCodFol[412,1],nBsApJub2 - nBaseJub2Ant,0.00)
			Endif
			FGeraVerba(aCodFol[064,1],nValApJub-nFerMesFun-nValApAnt,nPerEM)
			FGeraVerba(aCodFol[148,1],nValPtJub-nValPtAnt,nPerPA)
		Endif	
	Endif
	// Calculo de Fundo Desemprego
	If SRA->RA_MODALID == "24"
		For nx := 1 to Len(aPD)
			If aPd[nx,9] == "D"  
				Loop
			EndIf                
			//Valores de 13 Salario nao devem ser somados na Base de Fundo Desemprego
			If (aPd[nX,1] == aCodFol[22,1] .Or. aPd[nX,1] == aCodFol[24,1]).And. PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_INSS") == "S"
				nBaseApJub -= aPd[nx,5]
         Endif
			If PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_HE" ) == "S" .And. PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_INSS") == "S"
				nBaseApJub -= aPd[nx,5]
				nPerc := PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_PERC")	
				If nPerc > 0
					nBaseApjub += (aPd[nx,5] / nPerc * 100)
				Endif	
         Endif
		Next 
		nAnosCasa := fAnosCasa(dDataBase, SRA->RA_ADMISSA)
		If nAnosCasa < 1
			nPercFun := 12
		Else
			nPercFun := 8
		Endif	
		nFundDes := ((nBaseApJub -nBasFunAnt) * nPercFun /100)
					
		FGeraVerba(aCodFol[676,1], nFundDes, nPercFun)
		FGeraVerba(aCodFol[677,1], (nBaseApJub-nBasFunAnt), 0.00)
	Endif
ElseIf cPaisLoc == "PAR"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somar as incidencias para apurar a base aporte jubilacion      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aeval( aPd ,{ |X| SomaInc(X,4,@nBaseApJub,,,,,,.F.,aCodfol) })  // Incidencia IPS
	
	If nBaseApJub > 0
		If !Empty(aCodFol[221,1])
			FGeraVerba(aCodFol[221,1],nBaseApJub,0.00)
		Endif
		FGeraVerba(aCodFol[064,1],Round(nBaseApJub*nIPSFunc/100,MsDecimais(1)),0.00)
		FGeraVerba(aCodFol[148,1],Round(nBaseApJub*nIPSPatr/100,MsDecimais(1)),0.00)
	Endif
ElseIf cPaisLoc == "URU"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somar as incidencias para apurar a base aporte BPS             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
	If c__Roteiro $ "FOL|FER|RES"
		Aeval( aPd ,{ |X| SomaInc(X,4,@nBsBpsFo,11,'N',,,,.F.,aCodfol) })  // Incidencia FRL
	
		Aeval( aPd ,{ |X| SomaInc(X,4,@nBsBpsFe,11,'S',,,,.F.,aCodfol) })  // Incidencia BPS
    Else
		Aeval( aPd ,{ |X| SomaInc(X,4,@nBsBps13,11,'N',12,'S',,.F.,aCodfol) })  // Incidencia BPS
	Endif
	nBsBpsFo	:=	If(nBsBpsFo > nBPSCot,nBPSCot,nBsBpsFo)
	nBsBpsFe	:=	If(nBsBpsFe > nBPSCot,nBPSCot,nBsBpsFe)
	nBsBps13	:=	If(nBsBps13 > nBPSCot,nBPSCot,nBsBps13)
	nBsBpsAuxUru := nBsBpsFo
	
		//Calculo BPS para Estrangeiros
	IF !( SRA->RA_NACIONA $ "10*20" ) .AND. c__Roteiro $ "FOL|FER|131|132"
   		IF SRA->RA_OPSEGSO == "2"
   			Return(nil)
	    ENDIF
	ENDIF
		
	If c__Roteiro == "131" .or. c__Roteiro == "132"
		If nBsBps13 > 0
			If nBsBps13 >= (nBPSCot / 2)
				nBsBps13 := nBPSCot/2
			Endif
		    FGeraVerba(aCodFol[019,1],nBsBps13,0.00,,,,,,,,dData_Pgto)
			FGeraVerba(aCodFol[070,1],Round(nBsBps13*nBPSFunc/100,MsDecimais(1)),nBPSFunc,,,,,,,dData_Pgto)
			FGeraVerba(aCodFol[290,1],Round(nBsBps13*nBPSPatr/100,MsDecimais(1)),nBPSPatr,,,,,,,dData_Pgto)
			
			IF !EMPTY(SRA->RA_CATCONS) .AND. !EMPTY(aCodFol[930,1])
				FGeraVerba(aCodFol[930,1],Round(nBsBps13*nBPSConsC/100,MsDecimais(1)),nBPSConsC,,,,,,,dData_Pgto)
			ENDIF
		Endif
	Else	
		If nBsBpsFo > 0		
			FGeraVerba(aCodFol[013,1],nBsBpsFo,0.00)                                        //Base
			FGeraVerba(aCodFol[064,1],Round(nBsBpsFo*nBPSFunc/100,MsDecimais(1)),nBPSFunc) //Funci
			FGeraVerba(aCodFol[148,1],Round(nBsBpsFo*nBPSPatr/100,MsDecimais(1)),nBPSPatr) //Patro
			
			IF !EMPTY(SRA->RA_CATCONS) .AND. !EMPTY(aCodFol[930,1])
				FGeraVerba(aCodFol[930,1],Round(nBsBpsFo*nBPSConsC/100,MsDecimais(1)),nBPSConsC,,,,,,,dData_Pgto)
			ENDIF
        Endif
		If nBsBpsFe > 0		
			FGeraVerba(aCodFol[014,1],nBsBpsFe,0.00)                                        //Base
			FGeraVerba(aCodFol[375,1],Round(nBsBpsFe*nBPSFunc/100,MsDecimais(1)),nBPSFunc)
			FGeraVerba(aCodFol[288,1],Round(nBsBpsFe*nBPSPatr/100,MsDecimais(1)),nBPSPatr) //Patro
			
			IF !EMPTY(SRA->RA_CATCONS) .AND. !EMPTY(aCodFol[930,1])
				FGeraVerba(aCodFol[930,1],Round(nBsBpsFe*nBPSConsC/100,MsDecimais(1)),nBPSConsC,,,,,,,dData_Pgto)
			ENDIF
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somar as incidencias para apurar a base aporte FRL             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If c__Roteiro $ "FOL|FER|RES"
		Aeval( aPd ,{ |X| SomaInc(X,6,@nBsFrlFo,11,'N',,,,.F.,aCodfol) })  // Incidencia FRL

		Aeval( aPd ,{ |X| SomaInc(X,6,@nBsFrlFe,11,'S',,,,.F.,aCodfol) })  // Incidencia FRL
    Else
		Aeval( aPd ,{ |X| SomaInc(X,6,@nBsFrl13,12,'S',,,,.F.,aCodfol) })  // Incidencia FRL
    Endif
	If nBsFrlFo > 0
		FGeraVerba(aCodFol[305,1],nBsFrlFo,0.00)
		FGeraVerba(aCodFol[306,1],Round(nBsFrlFo*nFrlFunc/100,MsDecimais(1)),nFRLFunc,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))
		FGeraVerba(aCodFol[307,1],Round(nBsFrlFo*nFrlPatr/100,MsDecimais(1)),nFRLPatr,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))
	Endif
	If nBsFrlFe > 0
		FGeraVerba(aCodFol[017,1],nBsFrlFe,0.00)
		FGeraVerba(aCodFol[018,1],Round(nBsFrlFe*nFrlFunc/100,MsDecimais(1)),nFRLFunc,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))
		FGeraVerba(aCodFol[118,1],Round(nBsFrlFe*nFrlPatr/100,MsDecimais(1)),nFRLPatr,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))
	Endif
	If nBsFrl13 > 0
		FGeraVerba(aCodFol[108,1],nBsFrl13,0.00,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil),.T.)
		FGeraVerba(aCodFol[109,1],Round(nBsFrl13*nFrlFunc/100,MsDecimais(1)),nFRLFunc,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil),.T.)
		FGeraVerba(aCodFol[119,1],Round(nBsFrl13*nFrlPatr/100,MsDecimais(1)),nFRLPatr,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil),.T.)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somar as incidencias para apurar a base aporte BSE             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	For nX:=1 To Len(aPd)
		If aPd[nX,9] == "D"  
			Loop
		EndIf                
		If !Empty(aPd[nX,3]) .And. aPd[nX,3] <> cSemana
			Loop
		Endif	
		If PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_BSE") == "1" 
			If c__Roteiro $ "FOL|RES" .And. PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_REFFER") $ " N"
			   nBsBseFo += aPd[nX,5]
			ElseIf c__Roteiro $ "FER|RES" .And. PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_REFFER") == "S" 
				nBsBseFe += aPd[nX,5]
			Endif	
			If PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_REF13") == "S" .And. c__Roteiro $ "131|132"
				nBsBse13 += aPd[nX,5]
			Endif
		Endif	
    Next
	
	If c__Roteiro == "131" .or. c__Roteiro == "132"
		If nBsBse13 > 0
		   FGeraVerba(aCodFol[415,1],nBsBse13,0.00,,,,,,,,dData_Pgto)
		Endif
	Else	
		If nBsBseFo > 0		
			FGeraVerba(aCodFol[413,1],nBsBseFo,0.00)                                        //Base
     	Endif
		If nBsBseFe > 0		
			FGeraVerba(aCodFol[414,1],nBsBseFe,0.00)                                        //Base
		Endif
	Endif
Endif

Return(nil)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOCDISSE ³ Autor ³ SILVIA TAGUTI         ³ Data ³ 28/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula Seguro de Enfermedad                               ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tiago Malta ³ 24/06/10 ³      ³ Alteração do nome da função Locdisse.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/ 

Function LOCFONASA()
Local nBsFonasFo  := 0
Local nBsFonasFe  := 0
Local nBsFonas13  := 0
Local nTpDesc	  := nFonasFunc
Local cSemAnt     := ""
Local nValAntF    := 0  
Local nValAntP    := 0  
Local nUltRegF    := 0
Local nUltRegP    := 0 
Local iX          := 0
Local iY          := 0
Local aTabBPC     := {}
Local nValBpc     := 0
Local lDepen      := .F.

If cPaisLoc == "URU" 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somar as incidencias para apurar a base aporte Cuota Mutual    |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If c__Roteiro $ "FOL|FER|RES"
		Aeval( aPd ,{ |X| SomaInc(X,14,@nBsFonasFo,11,'N',,,,.T.,aCodfol) })  // Incidencia Cuota Mutual
		Aeval( aPd ,{ |X| SomaInc(X,14,@nBsFonasFe,11,'S',,,,.T.,aCodfol) })  // Incidencia Cuota Mutual
   Else
		Aeval( aPd ,{ |X| SomaInc(X,14,@nBsFonas13,12,'S',,,,.T.,aCodfol) })  // Incidencia Cuota Mutual
   Endif
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Carrega o valor do BPC |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   	fCarrTab( @aTabBPC   , "S003", Nil)
	// Valor do Bpc
	IF Len(aTabBPC) > 0
		nValBpc   := fTabela("S003", 1 , 4 )
	Endif
   
	IF nValBpc > 0 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Definir a aliquota do imposto Disse a ser aplicada             |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SRA->RA_TIPOPGT == "M" .And. SRA->RA_SALARIO > (nValBpc * 2.5)
			dbSelectArea( "SRA" )
			If SRA->RA_SALARIO > (nValBpc * 2.5)
				dbSelectArea( "SRB" )
				dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
				//Verificar se existe dependentes
				While !Eof() .And. SRB->RB_FILIAL + SRB->RB_MAT == SRA->RA_FILIAL + SRA->RA_MAT
					If (SRB->RB_GRAUPAR == "F")
						If DateDiffYear(SRB->RB_DTNASC,dDataBase) < 18 .Or. DateDiffYear(SRB->RB_DTNASC,dDataBase) > 18 .And. (SRB->RB_TIPIR == "1")
				   			nTpDesc := nFonasDep //Se apenas um atender a condicao o valor sera aplicado
				   			lDepen  := .T.
				   			Exit
						Endif
					Endif
					dbSkip()
				Enddo
			Else
				nTpDesc	:= nFonasSM
			Endif
		Else
			If ( nBsFonasFo > (nValBpc * 2.5) ) .Or. ( nBsFonasFe > (nValBpc * 2.5) )
				dbSelectArea( "SRB" )
				dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
				//Verificar se existe dependentes
				While !Eof() .And. SRB->RB_FILIAL + SRB->RB_MAT == SRA->RA_FILIAL + SRA->RA_MAT
					If (SRB->RB_GRAUPAR == "F")
						If DateDiffYear(SRB->RB_DTNASC,dDataBase) < 18 .Or. DateDiffYear(SRB->RB_DTNASC,dDataBase) > 18 .And. (SRB->RB_TIPIR == "1")
				   			nTpDesc := nFonasDep //Se apenas um atender a condicao o valor sera 4plicado
				   			lDepen  := .T.
				   			Exit
						Endif
					Endif
					dbSkip()
				Enddo
			Else
				nTpDesc	:= nFonasSM
			Endif		
		Endif
	ENDIF
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento Aliquota Fonasa com dependentes ou sem dependentes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF lDepen
		nTpDesc += nFonasDep
	ELSE
		nTpDesc += nFonasSDep 
	ENDIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somente para semanalistas e se a semana estiver informada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cSemana) .And. SRA->RA_TIPOPGT = "S"	

		nX := Len(aPd)   
		nY := Nx
		           
		// Soma desconto Disse das semanas anteriores para abater na semana atual (gera valor negativo)
	    For iX:=1 To nX
	    	nPos :=  aScan( aPd, { |x| x[1] = aCodfol[309,1] .And. x[3] <> cSemana})
				If nPos > 0
					cSemAnt  := aPd[nPos,3] 
					If nPos <> nUltRegF 
						nValAntF := FBuscaPd("302","V",cSemAnt)       
						nUltRegF := nPos                                   
					Else
						Exit
					EndIf 
				Else
					Exit
				EndIf         
		Next nX    
		       
		// Soma base Disse Patronal das semanas anteriores para abater na semana atual (gera valor positivo)
		For iY:=1 To nY
        	nPos :=  aScan( aPd, { |x| x[1] = aCodfol[309,1] .And. x[3] <> cSemana})
				If nPos > 0
					cSemAnt  := aPd[nPos,3] 
					If nPos <> nUltRegP
						nValAntP := FBuscaPd("704","V",cSemAnt)       
						nUltRegP := nPos                                   
					Else
						Exit
					EndIf  
				Else
					Exit
				EndIf         
		Next nY  
	
   EndIf
         

   If nBsFonasFo > 0
        FGeraVerba(aCodFol[308,1],nBsFonasFo,0.00)
        FGeraVerba(aCodFol[309,1],(Round(nBsFonasFo*nTpDesc/100,MsDecimais(1)) + nValAntF),nTpDesc) //abate desconto Disse (soma o valor negativo)
        FGeraVerba(aCodFol[303,1],(Round(nBsFonasFo*nFonasPatr/100,MsDecimais(1)) - nValAntP),nFonasPatr) //abate base Disse		
		
   Endif
   If nBsFonasFe > 0
        FGeraVerba(aCodFol[355,1],nBsFonasFe,0.00)
        FGeraVerba(aCodFol[356,1],(Round(nBsFonasFe*nTpDesc/100,MsDecimais(1)) + nValAntF),nTpDesc) //abate desconto Disse (soma o valor negativo)
        FGeraVerba(aCodFol[357,1],(Round(nBsFonasFe*nFonasPatr/100,MsDecimais(1)) - nValAntP),nFonasPatr) //abate base Disse		
   Endif
	If nBsFonas13 > 0
		FGeraVerba(aCodFol[358,1],nBsFonas13,0.00,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil),.T.)
		FGeraVerba(aCodFol[359,1],Round(nBsFonas13*nTpDesc/100,MsDecimais(1)),nTpDesc,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil),.T.)
	Endif
   
Endif

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOCOBRSOC³ Autor ³ MARCOS STIEFANO       ³ Data ³ 19/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula Obra Social                                        ³±±
±±³          ³ EX obrasoci.prx                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LOCOBRSOC()
Local nBaseObSoc:= 0
Local nBasePatr   := 0
Local nOSPat	:= 0
Local nOSEmp	:= 0
Local nExcPat  	:= 0
Local nExcEmp   := 0
Local nAnsPat   := 0
Local nAnsEmp   := 0
Local nDifObSoc	:= 0
Local nPerOS	:= 0
Local cConBas	:= "   "
Local cConPat	:= "   "
Local cConOS	:= "   "
Local cConExE	:= "   "
Local cConExP	:= "   "
Local cConAnE	:= "   "
Local cConAnP	:= "   "
Local nLim1  	:= 0
Local nPerLim1	:= 0
Local nLim2  	:= 0
Local nPerLim2	:= 0
Local nLim3  	:= 0
Local nPerLim3	:= 0
Local nPerTit	:= 0
Local nPerDep	:= 0
Local nPerPat	:= 0
Local nMinBas	:= 0
Local nMaxBas	:= 999999
Local nFerOsFun   := 0    
Local nFerANFun   := 0 
Local nFerExFun   := 0
Local cConOSV		:= "   "
Local cConExV		:= "   "
Local cConAnV		:= "   "
Local nPos        := 0
Local nMinBasPat  := 0
Local nMaxBasPat  := 0
Local nPerOSPat	:=	0
Local nBsObSoc1 	:= 0
Local nBsObSoc2 	:= 0 
Local cConBasPat  := "   "
//Semanalistas
Local nBsObSoc1Ant:= 0
Local	nBsObSoc2Ant:= 0
Local nConOsAnt   := 0
Local nConAnEAnt  := 0
Local nConPatAnt  := 0
Local nConAnPAnt 	:= 0
Local nConExPAnt 	:= 0
Local nConExEAnt 	:= 0

If cPaisLoc == "ARG"
	If !Empty(SRA->RA_ASMEDIC)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cargar los siguientes valores de la obra social del empleado :   ³
		//³nLIM1   : Limite uno para escala de % OS vs ANSSAL               ³
		//³nPerLim1: % destinado a la OS hasta el limite 1                  ³
		//³nLIM2   : Limite dos para escala de % OS vs ANSSAL               ³
		//³nPerLim2: % destinado a la OS hasta el limite 2                  ³
		//³nLIM3   : Limite tres para escala de % OS vs ANSSAL              ³
		//³nPerLim3: % destinado a la OS hasta el limite 3                  ³
		//³cConBas : Concepto para la base de calculo Empleado              ³
		//³cConOS  : Concepto para el valor descontado al empleado para OS  ³
		//³cConPat : Concepto para el aporte patronal a la OS               ³
		//³cConExE : Concepto para la diferencia descontada al empleado     ³
		//³cConExP : Concepto para la diferencia aportada por la empresa    ³
		//³cConAnE : Concepto para el descuento de ANSSAL al empleado       ³
		//³cConAnP : Concepto para el aporte de ANSSAL por la empresa       ³
		//|cConOSV : Concepto desconto do funcionario para OS - Ferias      ³
		//|cConExV : Concepto para la diferencia descontada al empleado-Fer.³
		//|cConAnV : Concepto de desconto de ANSSAL do funcionario - Ferias ³
		//³cConBasPat: Concepto para la base de calculo Patronal            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FPHIST82( xFilial("SRX") , "22" ,  RhTamFilial(SRA->RA_FILIAL)+SRA->RA_ASMEDIC+"1" )
			nLim1  	:= Val( SubStr ( SRX->RX_TXT ,  21 , 14 ) )
			nPerLim1	:= Val( SubStr ( SRX->RX_TXT ,  35 , 05 ) )
			nLim2  	:= Val( SubStr ( SRX->RX_TXT ,  40 , 14 ) )
			nPerLim2	:= Val( SubStr ( SRX->RX_TXT ,  54 , 05 ) )
			DbSelectArea('SRX')
			DbSeek( xFilial("SRX")+"22"+RhTamFilial(SRA->RA_FILIAL)+SRA->RA_ASMEDIC+"2" )
			nLim3  	:= Val( SubStr ( SRX->RX_TXT ,  01 , 14 ) )
			nPerLim3	:= Val( SubStr ( SRX->RX_TXT ,  15 , 05 ) )
			cConBas:= SubStr ( SRX->RX_TXT ,  20 , 03 )
			cConOS := SubStr ( SRX->RX_TXT ,  23 , 03 )
			cConPat:= SubStr ( SRX->RX_TXT ,  26 , 03 )
			cConExE:= SubStr ( SRX->RX_TXT ,  29 , 03 )
			cConExP:= SubStr ( SRX->RX_TXT ,  32 , 03 )
			cConAnE:= SubStr ( SRX->RX_TXT ,  35 , 03 )
			cConAnP:= SubStr ( SRX->RX_TXT ,  38 , 03 )
			cConOSV :=SubStr ( SRX->RX_TXT ,  41 , 03 )
			cConExV:= SubStr ( SRX->RX_TXT ,  44 , 03 )
			cConAnV:= SubStr ( SRX->RX_TXT ,  47 , 03 )
			DbSelectArea('SRX')
			DbSeek( xFilial("SRX")+"22"+RhTamFilial(SRA->RA_FILIAL)+SRA->RA_ASMEDIC+"3" )
			cConBasPat:= SubStr ( SRX->RX_TXT ,  1 , 03 )
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cargar los siguientes valores de la conf. de obras sociales  :³
		//³nPerTit : Alicuota de deduccion al empleado por TITULAR       ³
		//³nPerDep : Alic. de deduccion al empleado por cada DEPENDENTE  ³
		//³nPerPat : Alic. que aportara el empleador.                    ³
		//³nPerExc : Porcentual de la diferencia que cubre el empleador  ³
		//³nMinBas: Base minima para el calculo (en MOPREs) Empleado     ³
		//³nMaxBas: Base maxima para el calculo (en MOPREs) Empleado     ³
		//³nMinBasPat: Base minima para el calculo (en MOPREs) Patronal  ³
		//³nMaxBasPat: Base maxima para el calculo (en MOPREs) Patronal  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FPHIST82( xFilial("SRX") , "64" ,  MesAno(dDataBase) ) .Or. FPHIST82( xFilial("SRX") , "64" , "      " )
			nPerTit:= Val( SubStr ( SRX->RX_TXT ,  1 , 6 ) )
			nPerDep:= Val( SubStr ( SRX->RX_TXT ,  7 , 6 ) )
			nPerPat:= Val( SubStr ( SRX->RX_TXT , 13 , 6 ) )
			nPerExc:= Val( SubStr ( SRX->RX_TXT , 19 , 6 ) )
			nMinBas:= Val( SubStr ( SRX->RX_TXT , 25 , 5 ) )
			nMaxBas:= Val( SubStr ( SRX->RX_TXT , 30 , 5 ) )
			nMinBasPat:= Val( SubStr ( SRX->RX_TXT , 35 , 5 ) )
			nMaxBasPat:= Val( SubStr ( SRX->RX_TXT , 40 , 5 ) )
		Endif
		nMinBas		*=	(nMopre*IIf(c__Roteiro$'131/132',0.5,IIf(c__Roteiro=="RES",diastrab/30,1)))
		nMaxBas		*=	(nMopre*IIf(c__Roteiro$'131/132',0.5,IIf(c__Roteiro=="RES",diastrab/30,1)))
		nMinBasPat 	*= (nMopre*IIf(c__Roteiro$'131/132',0.5,IIf(c__Roteiro=="RES",diastrab/30,1)))
		nMaxBasPat 	*= (nMopre*IIf(c__Roteiro$'131/132',0.5,IIf(c__Roteiro=="RES",diastrab/30,1)))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Somar as incidencias para apurar a base obra social            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		Aeval( aPd ,{ |X| SomaInc(X,6,@nBaseObSoc,,,,,,.T.,aCodfol) }) // Incidencia FGTS
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ajusta los minimos y maximos imponibles³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nBasePatr	:=	nBaseObSoc
		nBsObSoc1 := nBaseObSoc
		nBsObSoc2 := nBaseObSoc

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ajustar minimo e maximos para o funcionario³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nBsObSoc1 < nMinBas
			nBsObSoc1 := nMinBas
		ElseIf nBsObSoc1 > nMaxBas
			nBsObSoc1 := nMaxBas
		Endif    
		
		If nBsObSoc1 <= nLim1
			nPerOS	:=	nPerLim1
		ElseIf nBsObSoc1 <= nLim2
			nPerOS	:=	nPerLim2
		ElseIf nBsObSoc1 <= nLim3
			nPerOS	:=	nPerLim3
		Endif    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ajustar minimo e maximos para o empregador ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nBsObSoc2 < nMinBasPat
			nBsObSoc2 := nMinBasPat
		ElseIf nBsObSoc2 > nMaxBasPat
			nBsObSoc2 := nMaxBasPat
		Endif

		If nBsObSoc2 <= nLim1
			nPerOSPat :=	nPerLim1
		ElseIf nBsObSoc2 <= nLim2
			nPerOSPat	:=	nPerLim2
		ElseIf nBsObSoc2 <= nLim3
			nPerOSPat	:=	nPerLim3
		Endif    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Semanalistas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SRA->RA_TIPOPGT == "S" 
			If c__Roteiro <> "FER"
				Aeval( aPD,{ |X| nBsObSoc1Ant += If(X[1] == cConBas .And. X[3] < cSemana .And. X[9] # "D",X[5],0)} )
				Aeval( aPD,{ |X| nBsObSoc2Ant += If(X[1] == cConBasPat .And. X[3] < cSemana .And. X[9] # "D",X[5],0)} )
				Aeval( aPD,{ |X| nConOsAnt   += If(X[1] == cConOS .And. X[3] < cSemana  .And. X[9] # "D",X[5],0)} )
				Aeval( aPD,{ |X| nConAnEAnt  += If(X[1] == cConAnE .And. X[3] < cSemana  .And. X[9] # "D",X[5],0)} )
				Aeval( aPD,{ |X| nConPatAnt  += If(X[1] == cConPat .And. X[3] < cSemana  .And. X[9] # "D",X[5],0)} )
				Aeval( aPD,{ |X| nConAnPAnt += If(X[1] == cConAnP .And. X[3] < cSemana  .And. X[9] # "D",X[5],0)} )
				Aeval( aPD,{ |X| nConExPAnt += If(X[1] == cConExP .And. X[3] < cSemana  .And. X[9] # "D",X[5],0)} )
				Aeval( aPD,{ |X| nConExEAnt += If(X[1] == cConExE .And. X[3] < cSemana  .And. X[9] # "D",X[5],0)} )
			Else
				dbSelectArea("SRC")
				dbSetOrder(1)
				SRC->( dbGoTop() )
				dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
				While SRC->( !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == RC_FILIAL + RC_MAT )
					If SRC->RC_PD == cConOS 
						nConOsAnt += SRC->RC_VALOR
					ElseIf SRC->RC_PD == cConAnE 
						nConAnEAnt += SRC->RC_VALOR
					Endif	
					SRC->(dbSkip())
				Enddo
			Endif	
		Endif	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo de deduccion al empleado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOSEmp    := (nBsObSoc1 * (nPerTit+(nPerDep*Val(SRA->RA_DPASSME)))) / 100
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Genera el concepto de deduccion de OS del empleado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nPos:= Ascan(aPd, { |X| X[1] = cConOSV .And. X[9] # "D"})) > 0
			nFerOsFun:= aPd[nPos][5]                		         //OS de Ferias
		Endif
		If c__Roteiro == "FER"
	      FGeraVerba(cConOSV,(nOSEmp*nPerOS/100)- nConOsAnt,(nPerTit+(nPerDep*Val(SRA->RA_DPASSME)))*nPerOS/100)
		Else
			//Genera a verba de deducao de OS do funcionario descontando OS de ferias e semanas anteriores
			FGeraVerba(cConOS,(nOSEmp*nPerOS/100)-nFerOsFun-nConOsAnt,(nPerTit+(nPerDep*Val(SRA->RA_DPASSME)))*nPerOS/100)
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Genera el concepto de deduccion de ANSSAL del empleado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nPos:= Ascan(aPd, { |X| X[1] = cConAnV .And. X[9] # "D"})) > 0
			nFerANFun:= aPd[nPos][5]                       
		Endif
		If c__Roteiro == "FER"	
	      FGeraVerba(cConAnV,(nOSEmp*(100-nPerOS)/100)-nConAnEAnt,(nPerTit+(nPerDep*Val(SRA->RA_DPASSME)))*(100-nPerOS)/100)		
      Else
         //Gera verba de deducao de ANSSAL do funcionario descontando ANSSAL de ferias e semanas anteriores
			FGeraVerba(cConAnE,(nOSEmp*(100-nPerOS)/100)-nFerAnFun-nConAnEAnt,(nPerTit+(nPerDep*Val(SRA->RA_DPASSME)))*(100-nPerOS)/100)		
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo de aporte del empleador³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOSPat := (nBsObSoc2 * nPerPat) / 100
		If c__Roteiro <> "FER"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Genera el concepto de aporte de OS del empleador   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FGeraVerba(cConPat,(nOSPat*nPerOSPat/100)-nConPatAnt ,nPerPat*nPerOSPat/100)		

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Genera el concepto de aporte de OS del empleado,   ³
			//³cuando la base de calculo es menor que el minimo,  ³
			//³el empleado asume la diferencia del porcentaje del ³
			//³empleador. Cuando opta por tener OS.               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

         If nBsObSoc2 <> nBsObSoc1
				FMatriz(cConOS,((nPerPat/100)*(nBsObSoc1-nBsObSoc2)) - nConOSAnt,,,,,'C',,,,,'1')
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Genera el concepto de aporte de ANSSAL del empleador  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FGeraVerba(cConAnP,(nOSPat*(100-nPerOSPat)/100) - nConAnPAnt ,nPerPat*(100-nPerOSPat)/100)		
		Endif	
		
		If c__Roteiro $ "FOL|FER" 
			nDifObSoc := SRA->RA_VLOBSOC - ((nPerPat+nPerTit+(nPerDep*Val(SRA->RA_DPASSME)))*nBsObSoc1/100) * nPerOS/100
			If nDifObSoc > 0
				If SRA->RA_ABS_OS > 0
					nPerExc	:=	SRA->RA_ABS_OS
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Genera el concepto de diferencia cubierto por el empleador  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If c__Roteiro == "FOL"
					If SRA->RA_TIPOPGT <> "S" .Or. (SRA->RA_TIPOPGT == "S" .And. lUltSemana)
						FGeraVerba(cConExP,(nDifObSoc*nPerExc/100) - nConExPAnt,nPerExc )
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Genera el concepto de diferencia no cubierto por el empleador³
						//³como deduccion al empleado.                                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (nPos	:=	AScan(aPd,{|x| x[1] == cConExV .And. x[9] <> "D" } )) > 0
							nFerExFun:= aPd[nPos][5]
						Endif	                       
						FGeraVerba(cConExE,(nDifObSoc*(100-nPerExc)/100)-nFerExFun-nConExEAnt, (100-nPerExc ))
					Endif	
				Else
					FGeraVerba(cConExV,(nDifObSoc*(100-nPerExc)/100)- nConExEAnt,(100-nPerExc ))
				Endif	
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Genera el concepto de base de calculo  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If c__Roteiro <> "FER"
			FGeraVerba(cConBas,nBsObSoc1 - nBsObSoc1Ant ,0.00)
			FGeraVerba(cConBasPat,nBsObSoc2 - nBsObSoc1Ant ,0.00)
		Endif
	Endif
Endif
Return(nil)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LOCAPLEY1 ³ Autor ³ MARCOS STIEFANO       ³ Data ³ 19/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula Aporte Ley 19.032                                  ³±±
±±³          ³ EX aportele.prx                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOCAPLEY1()

Local nBaseApLey	:=	0
Local nValApLey		:=	0
Local nValPtLey 	:=	0
Local nPerEmp   	:=	0
Local nPerPat   	:=	0
Local nMinBas   	:=	0
Local nMaxBas   	:=	0
Local cConBas   	:=	""
Local cConVlr   	:=	""
Local cConPat   	:=	""
Local cConVlV   	:=	""
Local nFerMesFun 	:= 0
Local nPos 			:= 0
Local nMinBasPat  := 0
Local nMaxBasPat  := 0
Local nBsApLey1	:=	0
Local nBsApLey2	:=	0
Local cConBasPat 	:=	""
//Semanalistas
Local nBsApLey1Ant:=	0
Local nValApLeyAnt:=	0
Local nBsApLey2Ant:=	0
Local nValPtLeyAnt:=	0

If cPaisLoc == "ARG"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtener los valores de :                                               ³
	//³nPerEmp: Porcentaje de deduccion al empleado                           ³
	//³nPerPat: Porcentaje de pago patronal                                   ³
	//³nMinBas: Base minima para el calculo (en MOPREs) del empleado          ³
	//³nMaxBas: Base maxima para el calculo (en MOPREs) del empleado          ³
	//³cConVlr : Concepto para el valor                                       ³
	//³cConBas : Concepto para la base                                        ³
	//³cConPat : Concepto para el aporte patronal                             ³
	//³cConVlV : Concepto para el valor de vacaciones                         ³
	//³nMinBasPat: Base minima para el calculo (en MOPRES) Patronal           ³
	//³nMaxBasPat: Base maxima para el calculo (en MOPREs) Patronal           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FPHIST82( xFilial("SRX"), "65" , MesAno(dDataBase) )  .Or. FPHIST82( xFilial("SRX") 	, "65" , "      " )
		nPerEmp:= 	Val( SubStr ( SRX->RX_TXT ,  01 , 6 ) )
		nPerPat:= 	Val( SubStr ( SRX->RX_TXT ,  07 , 6 ) )
		nMinBas:= 	Val( SubStr ( SRX->RX_TXT ,  13 , 6 ) )
		nMaxBas:= 	Val( SubStr ( SRX->RX_TXT ,  19 , 6 ) )
		cConBas:=	SubStr ( SRX->RX_TXT ,  25 , 3 )
		cConVlr:= 	SubStr ( SRX->RX_TXT ,  28 , 3 )
		cConPat:= 	SubStr ( SRX->RX_TXT ,  31 , 3 )
		cConVlV:= 	SubStr ( SRX->RX_TXT ,  34 , 3 ) 
		nMinBasPat:= Val( SubStr ( SRX->RX_TXT ,  37 , 6 ) )
		nMaxBasPat:= Val( SubStr ( SRX->RX_TXT ,  43 , 6 ) )
		cConBasPat:= SubStr ( SRX->RX_TXT ,  49 , 3 )
	Endif
	nMinBas		*=	(nMopre*IIf(c__Roteiro$'131/132',0.5,IIf(c__Roteiro=="RES",diastrab/30,1)))
	nMaxBas		*=	(nMopre*IIf(c__Roteiro$'131/132',0.5,IIf(c__Roteiro=="RES",diastrab/30,1)))
	nMinBasPat 	*= (nMopre*IIf(c__Roteiro$'131/132',0.5,IIf(c__Roteiro=="RES",diastrab/30,1)))
	nMaxBasPat 	*= (nMopre*IIf(c__Roteiro$'131/132',0.5,IIf(c__Roteiro=="RES",diastrab/30,1)))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somar as incidencias para apurar a base aporte ley 19.032      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aeval( aPd ,{ |X| SomaInc(X,14,@nBaseApLey,,,,,,.T.,aCodfol) }) //Incidencia sobre LEY 10.032 (RV_RAIS)
	
	nBsApLey1 := nBaseApLey
	nBsApLey2 := nBaseApLey

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ajustar minimo e maximos para o funcionario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nBsApLey1 < nMinBas
		nBsApLey1 := 0
	ElseIf nBsApLey1 > nMaxBas
		nBsApLey1 := nMaxBas
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ajustar minimo e maximos para o empregador ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nBsApLey2 < nMinBasPat
		nBsApLey2 := 0
	ElseIf nBsApLey2 > nMaxBasPat
		nBsApLey2 := nMaxBasPat
	Endif
	//Verifica se o funcionarios tem concepto de ferias
	If (nPos:= Ascan(aPd, { |X| X[1] = cConVlV .And. X[9] # "D"})) > 0
		nFerMesFun := aPd[nPos,5]
	Endif

	nValApLey := ( ( nBsApLey1 * nPerEmp) / 100 )
	nValPtLey := ( ( nBsApLey2 * nPerPat) / 100 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Semanalistas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SRA->RA_TIPOPGT == "S" 
		If c__Roteiro <> "FER"
			Aeval( aPD,{ |X| nBsApLey1Ant += If(X[1] == cConBas .And. X[3] < cSemana .And. X[9] # "D",X[5],0)} )
			Aeval( aPD,{ |X| nValApLeyAnt += If(X[1] == cConVlr .And. X[3] < cSemana  .And. X[9] # "D",X[5],0)} )
			Aeval( aPD,{ |X| nBsApLey2Ant += If(X[1] == cConBasPat .And. X[3] < cSemana .And. X[9] # "D",X[5],0)} )
			Aeval( aPD,{ |X| nValPtLeyAnt   += If(X[1] == cConPat .And. X[3] < cSemana  .And. X[9] # "D",X[5],0)} )
		Else
			dbSelectArea("SRC")
			dbSetOrder(1)
			SRC->( dbGoTop() )
			dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
			While SRC->( !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == RC_FILIAL + RC_MAT )
				If SRC->RC_PD == cConVlr 
					nValApLeyAnt += SRC->RC_VALOR
				Endif	
				SRC->(dbSkip())
			Enddo
		Endif	
	EndIf
	If c__Roteiro == "FER"
		If nValApLey > 0
			FGeraVerba(cConVlV,nValApLey - nValApLeyAnt,nPerEmp)  //Aporte Ferias
		Endif
	Else
		If nValApLey > 0
			If !Empty(cConBas)
				FGeraVerba(cConBas,nBsApLey1 - nBsApLey1Ant,0.00)
			Endif
			//Caso haja valor de ferias, eh descontado na folha de pagamento
			FGeraVerba(cConVlr,(nValApLey - nFerMesFun - nValApLeyAnt),nPerEmp)
		Endif
		If nValPtLey > 0  
			If !Empty(cConBasPat)
				FGeraVerba(cConBasPat,nBsApLey2-nBsApLey2Ant,0.00)
			Endif
			FGeraVerba(cConPat,nValPtLey-nValPtLeyAnt,nPerPat)
		Endif                
	Endif
Endif
Return(nil)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOC_ART  ³ Autor ³ CALCULO DE ART        ³ Data ³ 19/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula el vcalor que la empresa debe aportar por ART      ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOC_ART()
Local nBaseART	:=	0
Local nArt		:=	0
Local nValFixo	:=	0
Local nMinPA	:=	0
Local nMaxPA 	:=	0
Local cConBas	:=	""
Local cConVal	:=	""
Local lContinua	:=	.T.

Local nBaseARTAnt := 0
Local nValARTAnt := 0
If cPaisLoc == "ARG"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somar as incidencias para apurar a base de ART                 |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aeval( aPd ,{ |X| SomaInc(X,16,@nBaseART,,,,,,.T.,aCodfol) })  // Incidencia ART  RV_DSRHE
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtener los valores de :                                               ³
	//³nART   : Porcentaje de pago patronal                                   ³
	//³nValFixo:Porcentaje de deduccion al empleado                           ³
	//³nMinPA : Base minima para el calculo de ART    patronal (en MOPREs)    ³
	//³nMaxPA : Base maxima para el calculo de ART    patronal (en MOPREs)    ³
	//³cConBas: Concepto para la base de calculo                              ³
	//³cConVal: Concepto para el valor                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FPHIST82( xFilial("SRX") , "66" , RhTamFilial(SRA->RA_FILIAL)+MesAno(dDataBase)) .Or. ;
		FPHIST82( xFilial("SRX") , "66" , RhTamFilial(SRA->RA_FILIAL)+"      ")	.Or. ;
		FPHIST82( xFilial("SRX") , "66" , RhTamFilial(FWGETTAMFILIAL)+MesAno(dDataBase)) .Or. ;
		FPHIST82( xFilial("SRX") , "66" , RhTamFilial(FWGETTAMFILIAL)+"      ")
		nART 		:= Val( SubStr ( SRX->RX_TXT ,  01 , 06 ) )
		nValFixo := Val( SubStr ( SRX->RX_TXT ,  07 , 12 ) )
		nMinPA	:= Val( SubStr ( SRX->RX_TXT ,  19 , 06 ) )
		nMaxPA 	:= Val( SubStr ( SRX->RX_TXT ,  25 , 06 ) )
		cConBas	:= SubStr ( SRX->RX_TXT ,  31 , 03 )
		cConVal	:= SubStr ( SRX->RX_TXT ,  34 , 03 )
	Else
		lContinua	:=	.F.
	Endif
	If lContinua
		nMinPA  	*=	(nMOPRE*IIf(c__Roteiro$'131/132',0.5,IIf(c__Roteiro=="RES",diastrab/30,1)))
		nMaxPA	*=	(nMOPRE*IIf(c__Roteiro$'131/132',0.5,IIf(c__Roteiro=="RES",diastrab/30,1)))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ajustar minimo e maximos                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nBaseART    < nMinPA
			nBaseART    := 0
		ElseIf nBaseART    > nMaxPA
			nBaseART    := nMaxPA
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Semanalistas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SRA->RA_TIPOPGT == "S" 
			Aeval( aPD,{ |X| nBaseARTAnt += If(X[1] == cConBas .And. X[3] < cSemana .And. X[9] # "D",X[5],0)} )
			Aeval( aPD,{ |X| nValARTAnt += If(X[1] == cConVal .And. X[3] < cSemana  .And. X[9] # "D",X[5],0)} )
		EndIf
			
		If !Empty(cConBas)
			FGeraVerba(cConBas,nBaseART - nBaseARTAnt,0.00)
		Endif
		FGeraVerba(cConVal,Round((nValFixo+(nBaseART*nART/100))-nValARTAnt,MsDecimais(1)))
	Endif
Endif
Return(nil)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LOCSINDIC ³ Autor ³ MARCOS STIEFANO       ³ Data ³ 19/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula Sindicato                                          ³±±
±±³          ³ Ex sindical.prx                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOCSINDIC()
Local nBaseSind	:= 0
Local aSindTmp	:= {}
Local nVlFunAnt := 0
Local nVlEmpAnt := 0
Local nVlCGAnt := 0
Local nVlFijopAnt := 0
If cPaisLoc == "ARG"
	aSindTmp	:=	SetSindLoc(SRA->RA_SINDICA)
	If Len(aSindTmp) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Somar as incidencias para apurar a base aporte sindical        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aeval( aPd ,{ |X| SomaInc(X,20,@nBaseSind,,,,,,.T.,aCodfol) })  // Incidencia Contrib. Sindical
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Semanalistas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SRA->RA_TIPOPGT == "S" 
			Aeval( aPD,{ |X| nVlFunAnt += If(X[1] == aSindTmp[5] .And. X[3] < cSemana .And. X[9] # "D",X[5],0)} )
			Aeval( aPD,{ |X| nVlEmpAnt += If(X[1] == aSindTmp[6] .And. X[3] < cSemana  .And. X[9] # "D",X[5],0)} )
			Aeval( aPD,{ |X| nVlCGAnt += If(X[1] == aSindTmp[7] .And. X[3] < cSemana  .And. X[9] # "D",X[5],0)} )
			Aeval( aPD,{ |X| nVlFijopAnt += If(X[1] == aSindTmp[8] .And. X[3] < cSemana  .And. X[9] # "D",X[5],0)} )
		EndIf
		
		FGeraVerba(aSindTmp[5],(nBaseSind*aSindTmp[1]/100) - nVlFunAnt,aSindTmp[1]) //Porcentagem funcionario
		FGeraVerba(aSindTmp[6],(nBaseSind*aSindTmp[2]/100) - nVlEmpant,aSindTmp[2]) //Porcentagem empregador
		If !Empty(aSindTmp[7]) .And. aSindTmp[3] > 0
			FGeraVerba(aSindTmp[7],(nBaseSind*aSindTmp[3]/100) - nVlCGAnt,aSindTmp[3]) //Porcentagem para CG
		Endif
		If aSindTmp[4] > 0
			FGeraVerba(aSindTmp[8],aSindTmp[4] - nVlFijopAnt) //Valor fijo
		Endif	
	Endif
Endif
Return(nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOCANSES ³ Autor ³ MARCOS STIEFANO       ³ Data ³ 19/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula ANSES  (so para Argentina)                         ³±±
±±³          ³ EX apoanses.prx                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOCANSES()
Local nBaseANSESAnt := 0
Local nValANSESAnt := 0
SetPrvt("NBASEANSES,NVALANSES,")
nBaseANSES := 0
nValANSES  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Somar as incidencias para apurar a base aporte jubilacion      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aeval( aPd ,{ |X| SomaInc(X,24,@nBaseANSES,,,,,,.T.,aCodfol) })  // Incidencia Convencao Coletiva

nValANSES := ( ( nBaseANSES * 9 ) / 100 )

If SRA->RA_TPCONTR == "2"
	nValANSES := ( ( nValANSES * 50 ) / 100 )
Elseif SRA->RA_VIEMRAI == "80"
	nValANSES := 0
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Semanalistas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SRA->RA_TIPOPGT == "S" 
	Aeval( aPD,{ |X| nBaseANSESAnt += If(X[1] == "787" .And. X[3] < cSemana .And. X[9] # "D",X[5],0)} )
	Aeval( aPD,{ |X| nValANSESAnt += If(X[1] == "788" .And. X[3] < cSemana .And. X[9] # "D",X[5],0)} )
	nBaseANSES -= nBaseANSESAnt   
	nValANSES -= nValANSESAnt
Endif

FGeraVerba("787",nBaseANSES,0)
FGeraVerba("788",nValANSES,9.00)

Return(nil)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LOCAGUINAL³ Autor ³ MARCOS STIEFANO       ³ Data ³ 19/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula Aguinaldo                                          ³±±
±±³          ³ Ex Aguinald.prx                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOCAGUINAL()
Local nBaseSal		:=	0
Local nBaseOtros	:=	0
Local nPromedio   	:=	12
Local nAntic		:=	0
Local aUltSal		:=	{0,0,0}
Local nMeses		:=	0
Local cMesAnt		:=	""
Local nTpAgui		:=	GetNewPar('MV_TPAGUI',1) //Promedio del ultimo ano
Local nRealFunc	:=	0
Local nRealAno	:=	0
Local cMesAgui          
Local nContSem 		:= 0
Local nAdeAgui 		:= 0

//nTpAgui == 1 -> Promedio del ultimo ano
//nTpAgui == 2 -> Ultimo salari

//DEFAULT nMesAntec13	:=	GetNewPar("MV_MES131",0)

nMesAntec13	:=	0	//Estudar tratamento para quando tem adiantamento de 13ro.

SetPrvt("NMES,NANO,N13SAL,NDIATRAB,NAGUINALD,CDATAINI,CDATAFIM")
SetPrvt("APOSICAO1,APOSICAO2,N1SEMESTRE,N2SEMESTRE,_NX,CDATA")
SetPrvt("NACHOU,")
nMes        := 0
nAno        := 0
n13Sal      := 0
nDiaTrab    := 0
nAguinald   := 0
cDataIni    := "    "
aPosicao1   := {}
aPosicao2   := {}
n1Semestre  := 0
n2Semestre  := 0
_NX         := 0
cData       := " "

If cPaisLoc == "ARG"
	
	lRemAtu	:= GetNewPar('MV_REMATU',.F.)

	nMes := ( Month(dDataRef) - 6 ) + 1
	nAno := Year(dDataRef)
	If nMes < 0
		nMes := 12 - (nMes * -1)
		nAno := nAno - 1
	Endif
	
	cDataIni := Strzero(nAno,4) + Strzero(nMes,2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pegar a melhor remuneracao do semestre                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SRD" )
	dbSetOrder(1)
	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cDataIni , .T. )
	While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT
		If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_MED13") == "S "
			nAchou := Ascan( aPosicao1, { |X| X[1] = SRD->RD_DATARQ } )
			If nAchou == 0
				Aadd( aPosicao1,{ SRD->RD_DATARQ,(SRD->RD_VALOR * If(PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "1",1,IF(PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "2",-1,0)))} )
			Else
				aPosicao1[nAchou,2] := aPosicao1[nAchou,2] + (SRD->RD_VALOR * If(PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "1",1,IF(PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "2",-1,0)))
			Endif
		Endif
		dbSkip()
	Enddo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Incluir remuneracao atual na checagem do semestre                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRemAtu
		dbSelectArea( "SRC" )
		dbSetOrder(1)
		dbSeek( SRA->RA_FILIAL + SRA->RA_MAT , .T. )
		While !Eof() .And. SRC->RC_FILIAL + SRC->RC_MAT == SRA->RA_FILIAL + SRA->RA_MAT
			If PosSrv(SRC->RC_PD,SRC->RC_FILIAL,"RV_MED13") == "S "
				nAchou := Ascan( aPosicao1, { |X| X[1] = LEFT(DTOS(SRC->RC_DATA),6) } )
				If nAchou == 0
					Aadd( aPosicao1,{ LEFT(DTOS(SRC->RC_DATA),6),(SRC->RC_VALOR * If(PosSrv(SRC->RC_PD,SRC->RC_FILIAL,"RV_TIPOCOD") == "1",1,IF(PosSrv(SRC->RC_PD,SRC->RC_FILIAL,"RV_TIPOCOD") == "2",-1,0)))} )
				Else
					aPosicao1[nAchou,2] := aPosicao1[nAchou,2] + (SRC->RC_VALOR * If(PosSrv(SRC->RC_PD,SRC->RC_FILIAL,"RV_TIPOCOD") == "1",1,IF(PosSrv(SRC->RC_PD,SRC->RC_FILIAL,"RV_TIPOCOD") == "2",-1,0)))
				Endif
			Endif
			dbSkip()
		Enddo
	Endif
		
	If Len(aPosicao1) == 0
		Return
	Endif
	
	aPosicao2 := ASort(aPosicao1,,,{|x,y| x[2] > y[2] }) // Sorteando Arrays
	
	nAguinald := ( aPosicao2[1][2] / 2 )
	
	If c__Roteiro ==	"131"
		//Calcular os dias uteis do ano
		nRealAno := DateDiffDay( Ctod('01/01/'+StrZero(Year(dDataBase))),Ctod('30/06/'+StrZero(Year(dDataBase))))+1
		//Calcular os dias uteis do ano para o funcionario
		nRealFunc := DateDiffDay(Max(SRA->RA_ADMISSA,Ctod('01/01/'+StrZero(Year(dDataBase),4))),Ctod('30/06/'+StrZero(Year(dDataBase))))+1
		
		//Tirar as faltas e afastamentos do funcionario
		nRealFunc	-=	LocAfast(Ctod('01/01/'+StrZero(Year(dDataBase),4)),Ctod('30/06/'+StrZero(Year(dDataBase))),SRA->RA_MAT,{aCodFol[054,1],aCodFol[203,1],aCodFol[242,1]},{'X','Q','R'},.F.)
		
		FGeraVerba(aCodfol[22,1],nAguinald*nRealFunc/nRealAno,nRealFunc/nRealAno)

	ElseIf c__Roteiro =="132"
		//Calcular os dias uteis do ano
		nRealAno := DateDiffDay(Ctod('01/07/'+StrZero(Year(dDataBase))),Ctod('31/12/'+StrZero(Year(dDataBase))))+1
		//Calcular os dias uteis do ano para o funcionario
		nRealFunc:= DateDiffDay(Max(SRA->RA_ADMISSA,Ctod('01/07/'+StrZero(Year(dDataBase),4))),Ctod('31/12/'+StrZero(Year(dDataBase))))+1
		
		//Tirar as faltas e afastamentos do funcionario
		nRealFunc	-=	LocAfast(Ctod('01/07/'+StrZero(Year(dDataBase),4)),Ctod('31/12/'+StrZero(Year(dDataBase))),SRA->RA_MAT,{aCodFol[054,1],aCodFol[203,1],aCodFol[242,1]},{'X','Q','R'},.F.)
		
		FGeraVerba(aCodfol[24,1],nAguinald*nRealFunc/nRealAno,nRealFunc/nRealAno)
	Endif
ElseIf cPaisLoc == "PAR"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pegar a remuneracao total do ultimo ano                               ³
	//³ - No paraguai o calculo de 13ro e a 12va parte do total da remunera-  ³
	//³ coes recebidfos no ano em conceito de salario, nao importa a data de  ³
	//³ demissao ou a darta de admissao. Eh indispensavel que esteja calculado³
	//³ e fechado o mes de dezembro.Bruno 26/10/01                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cMesAnt	:=	""
	nMeses	:=	0
	cDataIni := Strzero(Year(dDataRef),4)+ "01"
	cDataFim := AnoMes(dDataRef)
	dbSelectArea( "SRD" )
	dbSetOrder(1)
	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cDataIni , .T. )
	While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT ;
		.And. (SRD->RD_DATARQ >=cDataIni .And. SRD->RD_DATARQ <=cDataFim)
		If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_REF13") == "S"
			If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "1"
				If SRD->RD_PD == aCodFol[31,1]
					nBaseSal		+=	 SRD->RD_VALOR
				Else
					nBaseOtros	+=	 SRD->RD_VALOR
				Endif
			ElseIf PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "2"
				nBaseSal		-=	 SRD->RD_VALOR
			Endif
			If SRD->RD_DATARQ ==  AnoMes(dDataRef)
				If SRD->RD_PD == aCodFol[31,1]
					aUltSal[1]	+=	SRD->RD_VALOR
				ElseIf PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "1"
					aUltSal[2]	+=	SRD->RD_VALOR
				ElseIf PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "2"
					aUltSal[3]	+=	SRD->RD_VALOR
				Endif
			Endif
		Endif
		If cMesAnt	<>	SRD->RD_DATARQ
			nMeses++
			cMesAnt	:=	SRD->RD_DATARQ
		Endif
		dbSkip()
	Enddo
	DbSkip(-1)
	
	//Controlo se nao fechou dezembro, nesta caso, tambem pego o acumulado
	// do mes atual
	If SRD->RD_DATARQ <> AnoMes(dDataRef)
		SRC->(DbSetOrder(1))
		SRC->(DbSeek(xFilial()+SRA->RA_MAT ))
		While !SRC->(Eof()) .And. SRC->RC_FILIAL + SRC->RC_MAT == SRA->RA_FILIAL + SRA->RA_MAT
			If PosSrv(SRC->RC_PD,SRC->RC_FILIAL,"RV_REF13") == "S"
				If PosSrv(SRC->RC_PD,SRC->RC_FILIAL,"RV_TIPOCOD") == "1"
					If SRC->RC_PD == aCodFol[31,1]
						nBaseSal		+=	 SRC->RC_VALOR
					Else
						nBaseOtros	+=	 SRC->RC_VALOR
					Endif
				ElseIf PosSrv(SRC->RC_PD,SRC->RC_FILIAL,"RV_TIPOCOD") == "2"
					nBaseSal		-=	 SRC->RC_VALOR
				Endif
				If SRC->RC_PD == aCodFol[31,1]
					aUltSal[1]	+=	SRC->RC_VALOR
				ElseIf PosSrv(SRC->RC_PD,SRC->RC_FILIAL,"RV_TIPOCOD") == "1"
					aUltSal[2]	+=	SRC->RC_VALOR
				ElseIf PosSrv(SRC->RC_PD,SRC->RC_FILIAL,"RV_TIPOCOD") == "2"
					aUltSal[3]	+=	SRC->RC_VALOR
				Endif
			Endif
			SRC->(dbSkip())
		Enddo
		nMeses++
	Endif
	If c__Roteiro == "132"
		dbSelectArea( "SRD" )
		dbSetOrder(1)
		If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + StrZero(Year(dDataRef),4)+"13"+	aCodFol[022,1])
			nAdeAgui := SRD->RD_VALOR
		Endif	
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Avaliar o criterio do salario referencia para a aguinaldo                  ³
	//³pode ser o ultoimo salario ou  o promedio do  ultimo ano calendario        ³
	//³Independentemente do parametro, nunca posso pagar menos do que marca a lei,³
	//³que eh o promedio dos ultimo ano calendario                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTpAgui==2 .And. (aUltSal[1] -aUltSal[3] + aUltSal[2]  ) * nMeses >= nBaseSal+nBaseOtros
		nBaseSal		:=	(aUltSal[1] -aUltSal[3] ) * nMeses
		nBaseOtros	:=	(aUltSal[2]  ) * nMeses
	Endif
	
	If c__Roteiro	==	"131"
		FGeraVerba(aCodfol[22,1],Round((nBaseSal+nBaseOtros)/12,MsDecimais(1)),0)
	ElseIf c__Roteiro	==	"132"
		FGeraVerba(aCodfol[24,1],Round(((nBaseSal+nBaseOtros)/12)- nAdeAgui,MsDecimais(1)),12)
	Endif
ElseIf cPaisLoc == "URU"
	nMes := ( Month(dDataRef) - 6 )+1   //A referencia para o calculo eh a partir de 12/XX
	nAno := Year(dDataRef)              //para 1 parcela e 06/XX para segunda parcela 
	If nMes <= 0
		nMes := 12 - (nMes * -1)
		nAno := nAno - 1
	Endif
	
	cDataIni := Strzero(nAno,4) + Strzero(nMes,2)
	If nMes > 6
		cDataFim := StrZero(nAno+1,4) + StrZero(nMes-7,2)
	Else
		cDataFim := StrZero(nAno,4) + StrZero(nMes+5,2)
	Endif
	
	dbSelectArea( "SRD" )
	dbSetOrder(1)
	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cDataIni , .T. )
	While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT;
		.And. (SRD->RD_DATARQ >=cDataIni .And. SRD->RD_DATARQ <=cDataFim)
		If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_REF13") = "S" .And.;
			SRD->RD_PD <> aCodFol[22,1] .And. SRD->RD_PD <> aCodFol[24,1] //desconsidera 1a e 2a parcela
			If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "1"
				If SRD->RD_PD == aCodFol[31,1] .or. SRD->RD_PD == aCodFol[32,1]
					nBaseSal		+=	 SRD->RD_VALOR
				Else
					nBaseOtros	+=	 SRD->RD_VALOR
				Endif
			ElseIf PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "2"
				nBaseSal		-=	 SRD->RD_VALOR
			Endif
			
			If c__Roteiro ==	"131"
				If SRD->RD_DATARQ ==  Strzero(Year(dDataRef),4)+"05"
					If SRD->RD_PD == aCodFol[31,1].or. SRD->RD_PD == aCodFol[32,1]
						aUltSal[1]	+=	SRD->RD_VALOR
					ElseIf PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "1"
						aUltSal[2]	+=	SRD->RD_VALOR
					ElseIf PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "2"
						aUltSal[3]	+=	SRD->RD_VALOR
					Endif
				Endif
			ElseIf c__Roteiro ==	"132"
				If SRD->RD_DATARQ ==  Strzero(Year(dDataRef),4)+"11"
					If SRD->RD_PD == aCodFol[31,1] .or. SRD->RD_PD == aCodFol[32,1]
						aUltSal[1]	+=	SRD->RD_VALOR
					ElseIf PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "1"
						aUltSal[2]	+=	SRD->RD_VALOR
					ElseIf PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "2"
						aUltSal[3]	+=	SRD->RD_VALOR
					Endif
				Endif
			Endif
		Endif
		If SRD->RD_PD == aCodFol[363,1]
			nAdeAgui := SRD->RD_VALOR
		Endif
		dbSkip()
	Enddo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Avaliar o criterio do salario referencia para a aguinaldo                  ³
	//³pode ser o ultimo salario ou  o promedio do  ultimo ano calendario         ³
	//³Independentemente do parametro, nunca posso pagar menos do que marca a lei,³
	//³que eh o promedio dos ultimo ano calendario                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTpAgui==2 .And. (aUltSal[1] -aUltSal[3] + aUltSal[2]  ) * nMeses > nBaseSal+nBaseOtros
		nBaseSal		:=	(aUltSal[1] -aUltSal[3] ) * nMeses
		nBaseOtros	:=	(aUltSal[2]  ) * nMeses
	Endif
	
	If c__Roteiro ==	"131"
		FGeraVerba(aCodfol[22,1],Round(((nBaseSal+nBaseOtros)/12),MsDecimais(1)),0,,,,,,,dData_Pgto)
	ElseIf c__Roteiro =="132"
		FGeraVerba(aCodfol[24,1],Round(((nBaseSal+nBaseOtros)/12),MsDecimais(1)),0,,,,,,,dData_Pgto)
	Endif     
	If nAdeAgui > 0
		FGeraVerba(aCodfol[23,1],Round(nAdeAgui,MsDecimais(1)),0,,,,,,,dData_Pgto)
	Endif
ElseIf cPaisLoc == "DOM"
	If AnoMes(SRA->RA_DTENTRA) > Strzero(Year(dDataBase),4)+"01"
		cMesAgui := StrZero(Month(SRA->RA_DTENTRA),2)
	Else
		cMesAgui := "01"
	Endif	
	cMesAnt	:=	""
	dbSelectArea( "SRD" )
	dbSetOrder(1)
	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + Strzero(Year(dDataBase),4) + cMesAgui , .T. )
	While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT .And. Substr(SRD->RD_DATARQ,1,4) == Strzero(Year(dDataRef),4)
		If SRD->RD_PD == aCodFol[318,1]         //Calcula o promedio pelo salario base
			nBaseSal		+=	 SRD->RD_VALOR
		Endif
		dbSkip()
	Enddo
	DbSkip(-1)

	If SRD->RD_DATARQ <> Strzero(Year(dDataRef),4)+"12"
		SRC->(DbSetOrder(1))
		SRC->(DbSeek(xFilial()+SRA->RA_MAT ))
		While !SRC->(Eof()) .And. SRC->RC_FILIAL + SRC->RC_MAT == SRA->RA_FILIAL + SRA->RA_MAT
			If SRC->RC_PD == aCodFol[318,1]
				nBaseSal		+=	 SRC->RC_VALOR
				nContSem += 1
			Endif
			SRC->(dbSkip())
		Enddo
		If nContSem = 0
			nBaseSal += SalMes 
		ElseIf nContSem =1
			nBaseSal += SalMes /2
		Endif		
	Endif

	If c__Roteiro	==	"132"
		FGeraVerba(aCodfol[24,1],Round(nBaseSal/12,MsDecimais(1)),,If(SRA->RA_TIPOPGT == "S","02","  "))
	Endif
ElseIf cPaisLoc == "CHI"
	If c__Roteiro == "131"
		n13Sal :=  ( ( Salmes / 12 * nAvos)) * nPercentual  
		n13Sal := n13Sal - nAntec13
		fGeraVerba(aCodFol[22,1],Round(n13Sal,MsDecimais(1)),0,,,,,,,dData_Pgto)
		If	lGeraDesc = .T.
			FGeraVerba(aCodfol[23,1],Round(n13Sal,MsDecimais(1)),,Semana)
		Endif	
	ElseIf c__Roteiro == '132'
		n13Sal :=  SalMes / 12 * nAvos
		FGeraVerba(aCodfol[24,1],Round(n13Sal,MsDecimais(1)),nAvos)
	Endif	
Endif
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LOCFERIAS ³ Autor ³ MARCOS STIEFANO       ³ Data ³ 19/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula Vacaciones                                         ³±±
±±³          ³ Ex Vacacion.prx                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOCFERIAS(dDataIni)        // incluido pelo assistente de conversao do AP5 IDE em 09/01/01
Local nDif			:=	0
Local nMeses		:=	0
Local nDias			:=	0
Local nRemVar		:=	0
Local nX			:=	0
Local nPosPdv		:=	0
Local nProMedio 	:= 	0
Local nVacaciones	:= 	0
Local nValNTrab 	:= 	0
Local cDataIni  	:= 	"    "
Local nHabilesFunc	:=	0
Local nDiaSalVac	:=	0
Local nPropSalVac	:=	0
Local aMediaHrs		:= {}           
Local nTotVar   	:= 	0
Local nDiasNDesc	:= 	0
Local nDescSalVac 	:= 	0
Local cMesAno		:=	''
Local nDiasFer		:=	0 
Local cAno
Local cMes  
Local aMesesVar   :={}
Local nBaseSal    := 0
Local nBaseOtros  := 0
Local nBaseVar    := 0
DEFAULT dDataIni	:=	M->RH_DATABAS

If cPaisLoc == "ARG"
	If SRA->RA_TIPOPGT == "M"
		nRemVar	:=	nMediaOut+nMediaHrs
		RCE->(DbSetOrder(1))
		If RCE->(MsSeek( If(Empty(xFilial("RCE")), xFilial("RCE"), SRA->RA_FILIAL) + SRA->RA_SINDICA )).And.(RCE->RCE_HABCOR == "1")
  			nDiasFer :=	M->RH_DATAFIM - M->RH_DATAINI + 1 
   	Else
			nDiasFer	:=	M->RH_DFERIAS
		Endif
	
		nValNTrab   :=	( ( M->RH_SALMES 	/ 30 ) * nDiasFer )
		nAdicFer		:=	( ( M->RH_SALMES	/ 25 ) * nDiasFer ) - nValNTrab
		nAdicFer		+=	(nRemVar/25)*nDiasFer - (nRemVar/30*nDiasFer)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Graba el valor de sueldo los dias de vacaciones³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FGeraVerba(aCodFol[072,1],nValNTrab,nDiasFer) //Vacaciones
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Graba el valor de adicional de vacaciones      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FGeraVerba(aCodFol[077,1],nAdicFer,nDiasFer) //Adicional de vacaciones
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Graba el valor de valores variables de vac.    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FGeraVerba(aCodFol[084,1],(nRemVar/25*nDiasFer),nDiasFer) //Vacaciones sobre remuneracion variable
	ElseIf SRA->RA_TIPOPGT == "S"
		//Para semanalistas deve ser revisado o calculo de remuneracao variavel, e definir
		//se podem ser usadas as medias padrao do sistema.
		
		nValNTrab   := ( M->RH_SALDIA * M->RH_DFERIAS )
		FGeraVerba(aCodFol[072,1],nValNTrab,M->RH_DFERIAS) //Vacaciones
		//Remuneracion variable
		nRemVar	:=	nMediaOut+nMediaHrs
		RCE->(DbSetOrder(1))
		If RCE->(MsSeek( If(Empty(xFilial("RCE")), xFilial("RCE"), SRA->RA_FILIAL) + SRA->RA_SINDICA )).And.(RCE->RCE_HABCOR == "1")
  			nDiasFer :=	M->RH_DATAFIM - M->RH_DATAINI + 1 
   	Else
			nDiasFer	:=	M->RH_DFERIAS
		Endif
		FGeraVerba(aCodFol[084,1],(nRemVar/25 *nDiasFer),nDiasFer) //Vacaciones sobre remuneracion variable
		nAdicFer		:=	( ( M->RH_SALMES	/ 25 ) * nDiasFer ) - nValNTrab
		nAdicFer		+=	(nRemVar/25)*nDiasFer - (nRemVar/30*nDiasFer)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Graba el valor de adicional de vacaciones      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FGeraVerba(aCodFol[077,1],nAdicFer,nDiasFer) //Adicional de vacaciones
	Endif
ElseIf cPaisLoc == "CHI"
	cMes	:=	STRZero(Month(dDataBase),2)
	cAno	:=	STRZero(Year(dDataBase),4)
	//Achar os ultimos 3 meses em que o funcionário trabalhou 30 dias para calcular a base de IPD
	dbSelectArea( "SRD" )
	dbSetOrder(1)
	While Len(aMesesVar) < 3 .And. (cAno+cMes) >= AnoMes(SRA->RA_ADMISSA)
		If cMes == '01'
			cMes 	:= '12'
			cAno	:= Tira1(cAno)
		Else
			cMes	:= Tira1(cMes)
		Endif	
		If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + (cAno+cMes) +aCodFol[31,1]) .And. SRD->RD_HORAS==30
			Aadd(aMesesVar,SRD->RD_DATARQ)
		Endif
	Enddo

	For nX:= 1 To Len(aMesesVar)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pegar o promedio de remuneracao dos ultimos 3 meses                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea( "SRD" )
		dbSetOrder(1)
		dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + aMesesVar[nX] , .T. )
		While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT .And. SRD->RD_DATARQ == aMesesVar[nX]
			If SRD->RD_PD == aCodFol[31,1] .And. nBaseSal == 0 //Pega salario do ultimo mes
			   nBaseSal := SRD->RD_VALOR                 
			Endif
			If Alltrim(PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_MEDFER")) == "S"
				nBaseOtros	+=	SRD->RD_VALOR * If(PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "1",1,IF(PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "2",-1,0))
			Endif
			dbSkip()
		Enddo
	Next
	If Len(aMesesVar) > 0
		nBaseVar	:=	(nBaseOtros/Len(aMesesVar))+nBaseSal
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para funcionarios com remuneracao variavel, a base de calculo deve ser o salario + 	³
	//|as outras remuneracoes																					³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   //Se o final das ferias termina na sexta-feira deve ser prorrogado para domingo
   While Dow(M->RH_DATAFIM) == 6 .or. Dow(M->RH_DATAFIM) == 7
   	M->RH_DATAFIM += 1
   Enddo
   If nBaseVar > 0
   	nVacaciones := Round( ( nBaseVar / 30 ) * (M->RH_DATAFIM - M->RH_DATAINI + 1),MsDecimais(1) )
	Else
		nVacaciones := Round( ( M->RH_SALMES / 30 ) * (M->RH_DATAFIM - M->RH_DATAINI + 1),MsDecimais(1) )
	Endif	
	If nVacaciones > 0
		FGeraVerba(aCodFol[072,1],nVacaciones,(M->RH_DATAFIM - M->RH_DATAINI + 1))
	Endif
ElseIf cPaisLoc == "PAR"
	//Las vacaciones se calculan en base al valor maximo entre el salario actual y
	//el salario minimo, no EXISTE NINGUN ACRESCIMO O DESCUENTO en el valor pago para el mensualista.
	nVacaciones := Round(  Max(M->RH_SALMES,VAL_SALMIN)/If(SRA->RA_CATFUNC == "M",30,26)  * M->RH_DFERIAS ,MsDecimais(1))
	FGeraVerba(aCodFol[072,1],nVacaciones,M->RH_DFERIAS)
	
ElseIf cPaisLoc == "URU"
	//Verba que sera usada para mensalista ou horista(base em dias)
	cCodDias 	:=	If(SRA->RA_TIPOPGT <> "M",aCodFol[360][1],aCodFol[031][1])
	//Calcula os dias trabalhados no ano(Jornadas)
	nDias	:=	DiasTrabAno(MesAno(M->RH_DATABAS),Substr(MesAno(M->RH_DATABAS),1,4)+"12",cCodDias,.T.)
	//Calcula os dias de Ferias no Ano Anterior
	nDiasFer:=DiasTrabAno(MesAno(M->RH_DATABAS),Substr(MesAno(M->RH_DATABAS),1,4)+"12",aCodFol[072][1],.T.)
   //Verifica se houve faltas no descontables(Sin Citacion) para entrar no calculo
   DiasNoDesc(M->RH_DATABAS,Ctod('31/12/'+StrZero(Year(M->RH_DATABAS))),@nDiasNDesc)

	//Somatoria dos Dias Trabalhados com os Dias Sin Citacion + Dias de Ferias
	nDias := nDias+nDiasNDesc+nDiasFer
	//Media de Horas Extras e adicionais,comissoes, premios..3892.112
	MedHrsFer(@aMediaHrs,@nMediaOut)   
	
 	//Acumula a Media de Horas Extras e os percentuais para cada tipo de hora extra
   For nX := 1 to Len(aMediaHrs)
   	nRemVar := Round(((aMediaHrs[nX][1] / nDias)*M->RH_DFERIAS) * M->RH_SALHRS, MsDecimais(1))  
      nTotVar += (nRemVar * aMediaHrs[nX][2])/100
   Next
	//Se o usuario informou outro valor de Media de Ferias, respeitar o do usuario
	If Ascan(aPd, { |X| X[1] = aCodfol[082,1] .And. X[9] # "D"}) = 0
		FGeraVerba(aCodFol[082,1],nTotVar)
	Endif
   //Soma o valor de ferias com os adicionais
   nVacaciones := Round(M->RH_SALDIA * M->RH_DFERIAS, MsDecimais(1))
   //Variavel sera utilizada no calculo de salario vacacional
   nVacMens    := nVacaciones  
   //Para mensalistas que pagam as ferias junto com a folha 
	If (lPagFerSe .And. SRA->RA_CATFUNC == "M") .or. SRA->RA_CATFUNC <> "M"
		//Se o usuario informou outro valor de ferias, respeitar o do usuario
		If Ascan(aPd, { |X| X[1] = aCodfol[072,1] .And. X[9] # "D"}) = 0
			FGeraVerba(aCodFol[072,1],nVacaciones,M->RH_DFERIAS)
		Endif
	Endif	
	/*
	//Se o usuario informou outro valor de adicional ferias, respeitar o do usuario
	//Gera o valor de outros adicionais de ferias,
	If Ascan(aPd, { |X| X[1] = aCodfol[075,1] .And. X[9] # "D"}) = 0
		FGeraVerba(aCodFol[075,1],Round(((nMediaOut * 12) / nDias)*M->RH_DFERIAS ,MsDecimais(1) ))
	Endif */

ElseIf cPaisLoc == "DOM"
	nVacaciones := Round( ( M->RH_SALMES / 30 ) * M->RH_DFERIAS,MsDecimais(1) )
	If nVacaciones > 0
		FGeraVerba(aCodFol[072,1],nVacaciones,If(lDiaHora,M->RH_DFERIAS,(Round(M->RH_DFERIAS * SRA->RA_HRSMES,2))/(Round(SRA->RA_HRSMES/SRA->RA_HRSDIA,2))))
	Endif

	If SRA->RA_TIPOPGT = "S" .And. SRA->RA_CATFUNC == "M"
 		If Day(M->RH_DATAINI) <= 15
  			nDiasProp:=  Day(M->RH_DATAINI)-1                  
			If nDiasProp > 0
				FMatriz(aCodfol[31,1], Round(M->RH_SALDIA * nDiasProp,MsDecimais(1)),If(lDiaHora,nDiasProp,(Round(nDiasProp*SRA->RA_HRSMES,2))/(Round(SRA->RA_HRSMES/SRA->RA_HRSDIA,2))))
		   Endif	
		Else 
 			nDiasProp:= Day(M->RH_DATAINI) - 16                 
			If nDiasProp > 0
				FMatriz(aCodfol[31,1], Round(M->RH_SALDIA * nDiasProp,MsDecimais(1)),If(lDiaHora,nDiasProp,(Round(nDiasProp*SRA->RA_HRSMES,2))/(Round(SRA->RA_HRSMES/SRA->RA_HRSDIA,2))))
			Endif
		Endif		      
	ElseIf SRA->RA_TIPOPGT == "M"
 		nDiasProp:=  Day(M->RH_DATAINI)-1                  
		If nDiasProp > 0
			FMatriz(aCodfol[31,1], Round(M->RH_SALDIA * nDiasProp,MsDecimais(1)),If(lDiaHora,nDiasProp,(Round(nDiasProp*SRA->RA_HRSMES,2))/(Round(SRA->RA_HRSMES/SRA->RA_HRSDIA,2))))
		Endif	
	Endif
Endif
Return(nil)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LOCDIFAGUI³ Autor ³ MARCOS STIEFANO       ³ Data ³ 11/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula Diferenca Aguinaldo                                ³±±
±±³          ³ Ex Difaguin.prx                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LOCDIFAGUI()
Local _Nx

SetPrvt("NMES,NANO,N13SAL,NDIATRAB,NAGUINALD,CDATAINI")
SetPrvt("APOSICAO1,APOSICAO2,N1SEMESTRE,N2SEMESTRE,_NX,CDATA")
SetPrvt("NVAL13PAG,NACHOU,cMesAgui")
nMes        := 0
nAno        := 0
n13Sal      := 0
nDiaTrab    := 0
nAguinald   := 0
cDataIni    := "    "
aPosicao1   := {}
aPosicao2   := {}
n1Semestre  := 0
n2Semestre  := 0
_NX         := 0
cData       := " "
nVal13Pag   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para funcion rios recebem quinzenalmente,deve ser calculado somente   ³
//³ na segunda quinzena semana do mˆs                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SRA->RA_TIPOPGT == "S" .And. !lUltSemana
	Return
EndIf
If cPaisLoc == "ARG"
	nMes := ( Month(dDataBase) - 6 )
	nAno := Year(dDataBase)
	If nMes <= 0
		nMes := 12 - (nMes * -1)
		nAno := nAno - 1
	Endif
	
	cDataIni := Strzero(nAno,4) + Strzero(nMes,2)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pegar a melhor remuneracao do semestre                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SRD" )
	dbSetOrder(1)
	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cDataIni , .T. )
	While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT
		If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_REF13") == "S" .And. SubStr(SRD->RD_DATARQ,3,2) <= "06"
			nAchou := Ascan( aPosicao1, { |X| X[1] = SRD->RD_DATARQ } )
			If nAchou == 0
				Aadd( aPosicao1, { SRD->RD_DATARQ , SRD->RD_VALOR } )
			Else
				aPosicao1[nAchou,2] := aPosicao1[nAchou,2] + SRD->RD_VALOR
			Endif
		Endif
		If (nMes <= 6 .and. SRD->RD_PD == aCodfol[22,1] ) .or.;
			(nMes > 6 .and. SRD->RD_PD == aCodfol[24,1] )
			nVal13Pag := nVal13Pag + SRD->RD_VALOR
		Endif
		dbSkip()
	Enddo
	
	If Len(aPosicao1) == 0 .Or. nVal13Pag == 0
		Return
	Endif
	
	aPosicao2 := ASort(aPosicao1,,,{|x,y| x[2] > y[2] }) // Sorteando Arrays
	
	nAguinald := ( aPosicao2[1][2] / 2 )
	
	For _NX := 1 To 12
		cData := "01/"+StrZero(_NX,2)+"/"+GetAno2(dDataBase)
		If _NX < 7
			n1Semestre := n1Semestre + Day(LastDay(CtoD(cData)))
		Else
			n2Semestre := n2Semestre + Day(LastDay(CtoD(cData)))
		Endif
	Next
	
	If Year(SRA->RA_ADMISSA) == Year(dDataBase)
		nDiaTrab := dDataBase - SRA->RA_ADMISSA
		If Month(dDataBase) > 6
			n13Sal := ( nAguinald * nDiaTrab ) / n2Semestre
		Else
			n13Sal := ( nAguinald * nDiaTrab ) / n1Semestre
		Endif
	Else
		n13Sal := nAguinald
	Endif
	
	If nVal13Pag > 0
		If n13Sal > nVal13Pag
			n13Sal := n13Sal - nVal13Pag
			If n13Sal > 0
				FGeraVerba(aCodfol[28,1],n13Sal,,cSemana)
			Endif
		Endif
	Endif
ElseIf cPaisLoc == "DOM"
	dbSelectArea("SRI")
	DbSetOrder(1)
	DbSeek(xFilial()+SRA->RA_MAT)
	While !Eof() .And. xFilial()+SRA->RA_MAT == SRI->RI_FILIAL+SRI->RI_MAT
		If MesAno(dDataBase) >= MesAno(SRI->RI_DATA)
			If SRI->RI_PD == aCodFol[24,1]      //13 SALARIO
				nVal13Pag := SRI->RI_VALOR
			Endif
		Endif
		dbSkip()
	Enddo

	If AnoMes(SRA->RA_DTENTRA) > Strzero(Year(dDataBase),4)+"01"
		cMesAgui := StrZero(Month(SRA->RA_DTENTRA),2)
	Else
		cMesAgui := "01"
	Endif	
	dbSelectArea( "SRD" )
	dbSetOrder(1)
	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + Strzero(Year(dDataBase),4) + cMesAgui , .T. )
	While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT .And. Substr(SRD->RD_DATARQ,1,4) == Strzero(Year(dDataBase),4)
		If SRD->RD_PD == aCodFol[318,1]         //Calcula o promedio pelo salario base
			n13Sal+=	 SRD->RD_VALOR
		Endif
		dbSkip()
	Enddo
	n13Sal := Round(n13Sal / 12,MsDecimais(1))
	If nVal13Pag > 0
		If n13Sal > nVal13Pag
			n13Sal := n13Sal - nVal13Pag
			If n13Sal > 0
				FGeraVerba(aCodfol[28,1],n13Sal,,cSemana)
			Endif
		Endif
	Endif
Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOCLIQUID³ Autor ³ MARCOS STIEFANO       ³ Data ³ 19/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula Liquidacion Final                                  ³±±
±±³          ³ EX Liquidac.prx                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOCLIQUID()
Local nMeses
Local nSalProm		:= 	0
Local nVlrIPD		:=	0
Local nBaseIPD 		:= 	0
Local aMeses		:=	{}
Local nTotal 		:=	0
Local nVacaciones 	:= 	0
Local nBaseSal		:=	0
Local nBaseOtros	:=	0
Local aUltSal		:=	{0,0,0}
Local nSalInde := 0                  
Local nSalInde2:= 0 
Local nSalBrut	:= 0          
Local nPromConv:= 0
Local dDtDobra
Local nDias 	 	:= 	0
Local aJornada 		:= 	{}
Local nAguiIPD		:=	0
Local nTpInde		:=	GetNewPar('MV_TPINDE',1) //Promedio de los ultimos 6 meses
Local nTpAgui		:=	GetNewPar('MV_TPAGUI',1) //Promedio del ultimo ano
Local nPosPdv		:=	0
Local nSalVac		:=	0
Local nJornadas		:=	0
Local cCodDias		:=	0
Local nRemVar		:=	0
Local nFerVen		:=	0
Local nFerPro		:=	0
Local aPdAnt		:=	{}
Local nFatorFer		:=	0
Local nMediaOut		:=	0
Local nMediaHrs		:=	0
Local cMesAnt		:=	""
Local nMesAgui		:=	0
Local nAnoAgui 		:= 	0
Local nProMedio   	:= 	0
Local nMes        	:= 	0
Local nAno        	:= 	0
Local nMesFim     	:= 	0
Local nAnoFim     	:= 	0
Local cDataIni    	:= 	"      "
Local cDataFim    	:= 	"      "
Local aSemanas    	:= 	{}
Local aPosicao1   	:= 	{}
Local aPosicao2   	:= 	{}
Local nMesi       	:= 	0
Local nAnoi       	:= 	0
Local nMesf       	:= 	0
Local nAnof       	:= 	0
Local dDataIni    	:= 	""
Local cDataI      	:= 	"      "
Local cDataF      	:= 	"      "
Local nDiaTrab    	:= 	0
Local nMesTrab    	:= 	0
Local nAnoTrab    	:= 	0
Local nAvanco     	:= 	0
Local n12Salario  	:= 	0
Local nIndeniz    	:= 	0
Local nPreAviso   	:= 	0
Local nDiasVac    	:= 	0
Local cData       	:= 	" "
Local nRealAno			:=	0
Local nRealFunc		:=	0
Local aAviso		:= 	{}
Local nMesesCasa
Local dDataCes 		:= 	""
Local aDiaCes 		:= 	{}
Local nDiaCes     	:= 	0
Local nContSem 		:= 	0
Local nBaseCes 		:= 	0
Local nMesCes 		:= 	0                
Local nSalDia 		:= 	0
Local cDataMed		:= 	""
Local nDiasNDesc  	:= 	0
Local nTotVar     	:= 	0
Local aMediaHrs   	:= 	{}           
Local cDataIAg    	:= 	""
Local cDataFAg    	:= 	""
Local nBaseMes    	:= 	0            
Local nSalProv    	:= 	0
Local nPropSalVac 	:= 	0     
Local nVlrIPdTot  	:= 	0       
Local nBaseFer    	:= 	0
Local cDataIniIpd 	:= 	""
Local cDataFimIpd 	:= 	""
Local aIPC			:=	{}
Local nIPCAtu 		:= 	0
Local aMesesIPD		:= 	{}
Local Nx			:= 	0
Local nY			:=	0	
Local	aSindTmp	      
Local cMesRemVar	:=	''
Local cRemVarIni	:=	''
Local nMesesRemVar:= 0
Local nValRemVar	:=	0         
Local nValDia
Local dDataModif  := Ctod('02/10/1998')//Data em que mudou a lei referente a demissoes na argentina               
Local nParcial    := 0
Local nAnoTrabAnt := 0    
Local nRemun89  	:= 0
Local nValUF89		:= 0
Local nBaseAtu    := 0  
Local nBase1      := 0
Local nBase2 		:= 0
Local nIndVol		:= 0
Local nIndLegal   := 0
Local nIncProv    := 0
Local nAnoTrabInd := 0
Local aJornadaTr := {}
Local	nDiasUltAno:= 0
Local	cDtFimInd := ""
Local nJornInd  := 0
Local aMesesVar   :={}
Local cAno
Local cMes  
Local nBaseVar    := 0
Local nValor13		:=	0
Local nBaseAvi    := 0
Local nBaseRes		:= 0
Local nAdeAgui := 0
Local lTopInd		:= GetNewPar('MV_TOPEREN',.T.)
Local nBaseExc 		:= 	0
Local nQtdIPD		:= 1
Private nVlrDesc  	:= 0
//nTpInde == 1 -> Promedio dos ultimos 6 meses
//nTpInde == 2 -> Ultimo salario
//nTpAgui == 1 -> Promedio del ultimo ano
//nTpAgui == 2 -> Ultimo salario

If cPaisLoc == "ARG"
	cSindic	:=	If(Valtype("cSindic")=="U",SRA->RA_SINDICA,cSindic)
	nMes := Month(dDataDem) - 12
	nAno := Year(dDataDem)
	If nMes == 0
		nMes := 1
		nAno := nAno - 1
	Endif
	If nMes < 0
		nMes := 12 - ( nMes * -1 )
		nAno := nAno - 1
	Endif
	cDataIni := StrZero(nAno,4) + StrZero(nMes,2)
	cDataFim := StrZero(Year(dDataDem),4) + StrZero(Month(dDataDem),2)
	If Month(dDataDem) <= 6
		cIniSac	:=	StrZero(Year(dDataDem),4) + "01"
	Else
		cIniSac	:=	StrZero(Year(dDataDem),4) + "07"
	Endif
	
	nMes := Month(dDataDem) - MESES_REM_VAR
	nAno := Year(dDataDem)
	If nMes <= 0
		nMes := 12 - ( nMes * -1 )
		nAno := nAno - 1
	Endif
	cIniRemVar	:= StrZero(nAno,4) + StrZero(nMes,2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pegar a melhor remuneracao do ultimos 12 meses                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SRD" )
	dbSetOrder(1)
	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cDataIni , .T. )
	While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT
		If SRD->RD_DATARQ > cDataFim
			dbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procurar melhor salario para Aguinaldo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SRD->RD_DATARQ >= cIniSac .And. PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_MED13") == "S "
			nAchou := Ascan( aPosicao1, { |X| X[1] = SRD->RD_DATARQ } )
			If nAchou == 0
				Aadd( aPosicao1, { SRD->RD_DATARQ , SRD->RD_VALOR } )
			Else
				aPosicao1[nAchou,2] := aPosicao1[nAchou,2] + SRD->RD_VALOR
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procurar media de remuneracoes variaveis ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SRD->RD_DATARQ >= cIniRemVar 
			If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_REMVAR") == "S"
				nValRemVar += SRD->RD_VALOR
			Endif
			If SRD->RD_DATARQ <> cMesRemVar .And. SRD->RD_MES<='12'
				cMesRemVar	:= SRD->RD_DATARQ
				nMesesRemVar++
			Endif	
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procurar melhor salario para Indenizacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_REMUNE") == "S"
			nAchou := Ascan( aPosicao2, { |X| X[1] = SRD->RD_DATARQ } )
			If nAchou == 0
				Aadd( aPosicao2, { SRD->RD_DATARQ , SRD->RD_VALOR } )
			Else
				aPosicao2[nAchou,2] := aPosicao2[nAchou,2] + SRD->RD_VALOR
			Endif
		Endif
		dbSkip()
	Enddo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcular Dias, Meses e Anos Trabalhado                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nMesI    := Month(SRA->RA_ADMISSA)
	nAnoI    := Year(SRA->RA_ADMISSA)
	cDataI   := StrZero(nAnoI,4) + StrZero(nMesI,2)
	nMesF    := Month(dDataDem)
	nAnoF    := Year(dDataDem)
	cDataF   := StrZero(nAnoF,4) + StrZero(nMesF,2)
	
	dDataIni := SRA->RA_ADMISSA
	While cDataI != cDataF
		AADD(aMeses,dDataIni)
		nAvanco  := 1 + (Day(LastDay(dDataIni))-Day(dDataIni))
		dDataIni := dDataIni+nAvanco
		nMesI    := nMesI + 1
		IF nMesI > 12
			nMesI := 1
			nAnoI := nAnoI + 1
		EndIF
		cDataI := StrZero(nAnoI,4) + StrZero(nMesI,2)
	Enddo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Considera fracao maior a dez 10 como um mes                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (dDataDem - dDataIni) > 10 .Or. SRA->RA_ADMISSA <= dDataModif
		AADD(aMeses,dDataIni)
	Endif
	nDiaTrab := dDataDem - SRA->RA_ADMISSA
	nMesTrab := Len(aMeses)
	nAnoTrab := ( Len(aMeses) / 12 )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sueldo Del Mes                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Reemplazado por fSaldoSal no roteiro de calculo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcular Indenizacion                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aIncRes[01] == "S"
		aSindTmp	:=	SetSindLoc(cSindic)
		nPromConv:=	aSindTmp[9]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obter o valor maximo do ultimo ano para estabelecer o valor do  ³
		//³salario para pagar a indemnizacao                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aPosicao2) > 0
			aPosicao2  	:= ASort(aPosicao2,,,{|x,y| x[2] > y[2] }) // Sorteando Arrays
			nSalInde 	:= ( aPosicao2[1][2] )
			nSalInde2	:=	nSalInde/12
			nSalBrut		:=	nSalInde
		Endif
		//Deve ser verificado o topo do salario indenizatorio de acordo com o sindicato, categoria, etc.
		If SRA->RA_ADMISSA <= dDataModif
			If nSalInde > nPromConv
				nSalInde	:=	nPromConv	
			Endif
			If (Int(nAnoTrab) + Iif(Mod(nMesTrab,12) > 3 ,1,0)) > 0 .And. nSalInde > 0
				nIndeniz := nSalInde * (Int(nAnoTrab) + Iif(Mod(nMesTrab,12) > 3 ,1,0))
			Endif           
			If nIndeniz < 2*nSalBrut
				nIndeniz := 2*nSalBrut
			Endif
			FGeraVerba(aCodFol[028,1],nIndeniz,(Int(nAnoTrab) + Iif(Mod(nMesTrab,12) > 3 ,1,0)))
		Else
			If nSalInde2 > nPromConv/12
				nSalInde2 :=nPromConv/12	
			Endif
			If  nMesTrab  > 0 .And. nSalInde2 > 0
				nIndeniz := (nSalInde2 *  nMesTrab)
			Endif           
			If nIndeniz < 2*nSalBrut/12
				nIndeniz := 2*nSalBrut/12
			Endif
			FGeraVerba(aCodFol[028,1],nIndeniz,nMesTrab)
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcular Pre Aviso                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aIncRes[02] == "S" .Or. aIncRes[03] == "S" .Or. aIncRes[07] == "S"
		If nDiasAv+nDiasSalAv	> 0
			nValRemVar	/=	nMesesRemVar
			nValDia		:=	(SALMES+nValRemVar)*12/360
			If aIncRes[02] == "S"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Genera pre-aviso no trabajado                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FGeraVerba(aCodFol[111,1],Round((nDiasAv-nDiasSalAv)*nValDia,MsDecimais(1)),nDiasAv-nDiasSalAv)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Genera composicion de salario                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SRA->RA_ADMISSA < dDataModif
					FGeraVerba(aCodFol[329,1],Round(nDiasSalAv*nValDia,MsDecimais(1)),nDiasSalAv)
				Endif
			ElseIf aIncRes[03] == "S"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Genera pre-aviso descontado                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FGeraVerba(aCodFol[113,1],Round(nDiasSalAv*nValDia,MsDecimais(1)),nDiasAv)
			ElseIF aIncRes[7]== "S" 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Genera pre-aviso trabalhado                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					IF aScan(aPd,{ |X| X[1] = aCodfol[112,1] .and. X[9] # "D" } ) = 0
					FGeraVerba(aCodFol[112,1],Round(nDiasAv*nValDia,MsDecimais(1)),nDiasAv)
				EndIF
			Endif
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aguinaldo                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aIncRes[04] == "S"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obter o valor maximo do ultimo semestre, e proporcionalizar aos ³
		//³dias trabalhados                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aPosicao1) > 0
			aPosicao1  := ASort(aPosicao1,,,{|x,y| x[2] > y[2] }) // Sorteando Arrays
			n12Salario := ( aPosicao1[1][2]/2 )
		Else
			n12Salario := ( SALMES/2 )
		Endif
		
		If n12Salario > 0
			//Calcular os dias uteis do ano
			nRealAno := DateDiffDay(Ctod('01/'+SubStr(cIniSac,5,2)+"/"+SubStr(cIniSac,1,4)),;
			Ctod(Iif(Substr(cIniSac,5,2)=="01","30/06/","31/12/")+SubStr(cIniSac,1,4)))+1

			//Calcular os dias uteis do ano para o funcionario
			nRealFunc:= DateDiffDay( MAX(SRA->RA_ADMISSA,Ctod('01/'+SubStr(cIniSac,5,2)+"/"+SubStr(cIniSac,1,4))),;
			dDataDem+nDiasSalAv)+1
			//Tirar as faltas e afastamentos do funcionario
			nRealFunc	-=	LocAfast(Ctod('01/01/'+StrZero(Year(dDataBase),4)),Ctod('30/06/'+StrZero(Year(dDataBase))),SRA->RA_MAT,{aCodFol[054,1],aCodFol[203,1],aCodFol[242,1]},{'X','Q','R'},.F.)

			nValor13	:=	n12Salario*nRealFunc/nRealAno
			If aIncRes[02] == "S" .And.(nDiasAv-nDiasSalAv) > 0
				
				nRealAno := DateDiffDay(Ctod('01/'+SubStr(cIniSac,5,2)+"/"+SubStr(cIniSac,1,4)),;
				Max(dDataDem+nDiasAv-nDiasSalAv,Ctod(Iif(Substr(cIniSac,5,2)=="01","30/06/","31/12/")+SubStr(cIniSac,1,4))))+1
				nRealFunc	:=	0
				//Calcular os dias uteis do ano para o funcionario
				nRealFunc:= DateDiffDay( dDataDem,dDataDem+nDiasAv-nDiasSalAv)+1
				
				FGeraVerba(aCodFol[115,1],n12Salario*nRealFunc/nRealAno ,(nRealFunc)/nRealAno 	)
			Endif
		Endif
		FGeraVerba(aCodFol[114,1],nValor13,nRealFunc/nRealAno)
	Endif
	
ElseIf cPaisLoc == "PAR"
	nMes := Month(dDataDem) - 6
	nAno := Year(dDataDem)
	If nMes == 0
		nMes := 12
		nAno := nAno - 1
	Endif
	If nMes < 0
		nMes := 12 -( nMes * -1 )
		nAno := nAno - 1
	Endif
	cDataIni := StrZero(nAno,4) + StrZero(nMes,2)
	cDataFim := StrZero(Year(dDataDem),4) + StrZero(Month(dDataDem),2)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pegar o promedio de remuneracao dos ultimos 6 meses                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SRD" )
	dbSetOrder(1)
	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cDataIni , .T. )
	While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT .And. SRD->RD_DATARQ <= cDataFim
		If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_REF13") == "S"
			nTotal	+=	SRD->RD_VALOR * If(PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "1",1,IF(PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "2",-1,0))
			If SRD->RD_DATARQ == cDataFim
				If SRD->RD_PD == aCodFol[31,1]
					aUltSal[1]	+=	SRD->RD_VALOR
				ElseIf PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "1"
					aUltSal[2]	+=	SRD->RD_VALOR
				ElseIf PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "2"
					aUltSal[3]	+=	SRD->RD_VALOR
				Endif
			Endif
		Endif
		dbSkip()
	Enddo
	If nTotal > 0
		nSalProm	:=	nTotal/6
		nBaseAvi	:= nTotal/6
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcular Dias, Meses e Anos Trabalhado                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nMesI    := Month(SRA->RA_ADMISSA)
	nAnoI    := Year(SRA->RA_ADMISSA)
	cDataI   := StrZero(nAnoI,4) + StrZero(nMesI,2)
	nMesF    := Month(dDataDem)
	nAnoF    := Year(dDataDem)
	cDataF   := StrZero(nAnoF,4) + StrZero(nMesF,2)
	
	dDataIni := SRA->RA_ADMISSA
	While cDataI != cDataF
		nAvanco  := 1 + (Day(LastDay(dDataIni))-Day(dDataIni))
		dDataIni := dDataIni+nAvanco
		AADD(aMeses,dDataIni)
		nMesI    := nMesI + 1
		IF nMesI > 12
			nMesI := 1
			nAnoI := nAnoI + 1
		EndIF
		cDataI := StrZero(nAnoI,4) + StrZero(nMesI,2)
	Enddo 
	nDiaTrab := dDataDem - SRA->RA_ADMISSA
	nMesTrab := Len(aMeses)
	nAnoTrab := Round( Len(aMeses) / 12 ,0)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Vacaciones                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aIncRes[_FERIAS] == "S"
		If M->RG_DFERVEN > 0
			SRF->(DbSetOrder(1))
			IF SRF->(DbSeek(xFilial()+SRA->RA_MAT))
				If Month(SRF->RF_DATABAS) <= 6
					dDtDobra := CtOD(Subs(Dtoc(SRF->RF_DATABAS),1,3)+STRZERO(Month(SRF->RF_DATABAS)+6,2)+'/'+StrZero(Year(SRF->RF_DATABAS)+1,4) ) - 1
				Else
					dDtDobra := CtOD(Subs(Dtoc(SRF->RF_DATABAS),1,3)+STRZERO(Month(SRF->RF_DATABAS)-6,2)+'/'+StrZero(Year(SRF->RF_DATABAS)+2,4) ) - 1
				Endif
				
				IF dDataDem > dDtDobra
					//Gerar ferias dobradas, pois veceram ha mais de 6 meses
					FGeraVerba(aCodFol[086,1],Round(  Max(M->RG_SALMES,VAL_SALMIN)/If(SRA->RA_CATFUNC == "M",30,26)  * M->RG_DFERVEN ,MsDecimais(1)),M->RG_DFERVEN)
					FGeraVerba(aCodFol[224,1],Round(  Max(M->RG_SALMES,VAL_SALMIN)/If(SRA->RA_CATFUNC == "M",30,26)  * M->RG_DFERVEN ,MsDecimais(1)),M->RG_DFERVEN)
				Else
					FGeraVerba(aCodFol[086,1],Round(  Max(M->RG_SALMES,VAL_SALMIN)/If(SRA->RA_CATFUNC == "M",30,26)  * M->RG_DFERVEN,MsDecimais(1)) ,M->RG_DFERVEN)
				Endif
			Endif
		Endif
		If M->RG_DFERPRO > 0
			FGeraVerba(aCodFol[087,1],round(  Max(M->RG_SALMES,VAL_SALMIN)/If(SRA->RA_CATFUNC == "M",30,26)  * M->RG_DFERPRO,MsDecimais(1)) ,M->RG_DFERPRO)
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcular Indenizacion                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aIncRes[_PGINDE] == "S"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Avaliar o criterio do salario referencia para a indemnizacao               ³
		//³pode ser o ultoimo salario oyu o promedio dos ultimos 6 meses.             ³
		//³Independentemente do parametro, nunca posso pagar menos do que marca a lei,³
		//³que eh o promedio dos ultimos 6 meses.                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nSalInde	:=	If(nTpInde==2,Max(aUltSal[1]+aUltSal[2]-aUltSal[3],nSalProm),nSalProm)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for funcionario "estable" (mais de 10 anos de casa) o valor ³
		//³da indenizacao e o dobro                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nAnoTrab >= 10
			FGeraVerba(aCodFol[110,1],Round((nSalInde/2)*nAnoTrab*2,MsDecimais(1)),(nAnoTrab*15)*2)
		Else
			FGeraVerba(aCodFol[110,1],Round((nSalInde/2)*nAnoTrab,MsDecimais(1)),(nAnoTrab*15))
		Endif
	ElseIf aIncRes[_DCINDE] == "S"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³O valor da indenizacao eh a metade do que deveria pagar o empre³
		//³gador se tive demitido sem justa causa.                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FGeraVerba(aCodFol[298,1],Round(nSalProm*nAnoTrab/2,MsDecimais(1)),Round(nAnoTrab/2*15,0))
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcular Pre Aviso                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aIncRes[_PGAVISO] == "S"
		nPreAviso	:=	0
		Do Case
			Case Len(aMeses)/12 <= 1 .And. SRA->RA_VCTOEXP <= dDataDem
				nPreAviso := 30
			Case Len(aMeses)/12 > 1 .And. (Len(aMeses)/12) <= 5
				nPreAviso := 45
			Case Len(aMeses)/12 > 5 .And. (Len(aMeses)/12) <= 10
				nPreAviso := 60
			Case Len(aMeses)/12 > 10
				nPreAviso := 90
		EndCase
		
		If !Empty(SRA->RA_AVPREVI) .And. SRA->RA_AVPREVI < dDataDem
			nPreAviso	-=	(dDataDem-SRA->RA_AVPREVI)
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³O Aviso Previo pode ser pelo ultimo salario ou media dos ultimos 6 meses³
		//³Usar o identificador de calculo 111 para Ultimo salario e 250 para media³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF aCodfol[111,1] <> "   " .And. nPreAviso > 0
			FGeraVerba(aCodFol[111,1],Round(nPreAviso * SALDIA,MsDecimais(1)),nPreAviso)
		ElseIf aCodFol[250,1] <>	"   " .And. nPreAviso > 0
			FGeraVerba(aCodFol[250,1],Round((nBaseAvi/30) * nPreAviso,MsDecimais(1)),nPreAviso)
		Endif
	ElseIf aIncRes[_DCAVISO] == "S"
		nPreAviso	:=	0
		Do Case
			Case Len(aMeses)/12 <= 1 .And. SRA->RA_VCTOEXP <= dDataDem
				nPreAviso := 30
			Case Len(aMeses)/12 > 1 .And. (Len(aMeses)/12) <= 5
				nPreAviso := 45
			Case Len(aMeses)/12 > 5 .And. (Len(aMeses)/12) <= 10
				nPreAviso := 60
			Case Len(aMeses)/12 > 10
				nPreAviso := 90
		EndCase
		
		If !Empty(SRA->RA_AVPREVI) .And. SRA->RA_AVPREVI < dDataDem
			nPreAviso	-=	(dDataDem-SRA->RA_AVPREVI)
		Endif

		FGeraVerba(aCodFol[113,1],Round(SALMES/30*nPreAviso/2,MsDecimais(1)),0)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aguinaldo                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aIncRes[_AGUINALDO] == "S"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pegar a remuneracao total do ultimo ano                               ³
		//³ - No paraguai o calculo de 13ro e a 12va parte do total da remunera-  ³
		//³ coes recebidfos no ano em conceito de salario, nao importa a data de  ³
		//³ demissao ou a darta de admissao. Eh indispensavel que esteja calculado³
		//³ e fechado o mes de dezembro.Bruno 26/10/01                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		cMesAnt	:=	""
		nMesAgui	:=	0
		nBaseOtros := 0
		dbSelectArea( "SRD" )
		dbSetOrder(1)
		dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + Strzero(Year(dDataDem),4) + "01" , .T. )
		While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT
			If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_REF13") == "S"
				If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "1"
					If SRD->RD_PD $ aCodFol[31,1]+"/"+aCodFol[72,1]
						nBaseSal		+=	 SRD->RD_VALOR
					Else
						nBaseOtros	+=	 SRD->RD_VALOR
					Endif
				ElseIf PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "2"
					nBaseSal		-=	 SRD->RD_VALOR
				Endif
			Endif
			If cMesAnt	<>	SRD->RD_DATARQ
				nMesAgui++
				cMesAnt	:=	SRD->RD_DATARQ
			Endif
			//Buscar se o funcionario ja recebeu a primeira parcela do Aguinaldo
			If SRD->RD_DATARQ == StrZero(Year(dDataDem),4)+"13" .And. SRD->RD_PD == aCodFol[022,1]
				nAdeAgui := SRD->RD_VALOR
			Endif
			dbSkip()
		Enddo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Avaliar o criterio do salario referencia para a aguinaldo                  ³
		//³pode ser o ultoimo salario ou  o promedio do  ultimo ano calendario        ³
		//³Independentemente do parametro, nunca posso pagar menos do que marca a lei,³
		//³que eh o promedio dos ultimo ano calendario                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nTpAgui==2 .And. (aUltSal[1] -aUltSal[3] + aUltSal[2]  ) * (Month(dDataDem)-1) > nBaseSal+nBaseOtros
			nBaseSal		:=	(aUltSal[1] -aUltSal[3] ) * (Month(dDataDem)-1)
			nBaseOtros	:=	(aUltSal[2]  ) * (Month(dDataDem)-1)
		Endif
		
		Aeval( aPd ,{ |X| SomaInc(X,12,@nBaseRes,,,,,,.T.,aCodfol) })  // Incidencia 13 Salario Rescisao
		
		FGeraVerba(aCodfol[19,1],nBaseSal  ,0,If(SRA->RA_TIPOPGT == "S",Semana,"  "))
		FGeraVerba(aCodfol[20,1],nBaseOtros+nBaseRes,0,If(SRA->RA_TIPOPGT == "S",Semana,"  "))
		FGeraVerba(aCodFol[114,1],Round(((nBaseSal+nBaseOtros+nBaseRes)/12) - nAdeAgui,MsDecimais(1)),12)
	Endif
ElseIf cPaisLoc == "CHI"
	//Pegar salario promedio dos ultimos 'nProMed' meses.
	nAno 	:= Year(dDataDem)
	nMes	:=	Month(dDataDem)
	
	If nProMed	>= 12
		nAno 		-= Int(nProMed/12)
		nProMed	:=	Mod(nProMed,12)
	Endif
	
	While nProMed > 0
		nMes--
		nProMed--
		If nMes == 0
			nMes	:=	12
			nAno--
		Endif
	EndDo
	
	cDataIni := StrZero(nAno,4) + StrZero(nMes,2)
	cDataFim := StrZero(Year(dDataDem),4) +  StrZero(Month(dDataDem),2)
	If !GetIPC(@aIPC,cDataIni,cDataFim)  
		If GetRemoteType() == -1
			MsgLogGrid( STR0006+cDataIni+STR0007+cDataFim, .F. ) // Retornar string da funcao Help
		Else
			MsgStop(STR0006+cDataIni+STR0007+cDataFim) //"Nao foi posivel achar todos os valores de IPC que devem ser usados entre os periodos: " ## " e "
		EndIf
		Return .f.
	Endif
	nIpcAtu	:= aIPC[Len(aIPC)][2]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pegar o promedio de remuneracao dos ultimos 24 meses                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SRD" )
	dbSetOrder(1)
	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cDataIni , .T. )
	cMesAnt	:=	""
	nMeses	:=	0
	While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT .And. SRD->RD_DATARQ < cDataFim
		If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_INDEN") == "S"
         nValor	:=	SRD->RD_VALOR * If(PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "1",1,IF(PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "2",-1,0))
         nValCorr	:=	nValor * Round(nIPCAtu/aIpc[Ascan(aIpc,{|x| x[1] == If(Substr(SRD->RD_DATARQ,5,2)<> "13",SRD->RD_DATARQ,MesAno(SRD->RD_DATPGT))})][2],3)
			nTotal	+=	nValCorr
		Endif
		If cMesAnt	<>	SRD->RD_DATARQ
			nMeses++
			cMesAnt	:=	SRD->RD_DATARQ
		Endif
		dbSkip()
	Enddo
	If nMeses > 0
		nSalProm	:=	Round(nTotal/nMeses,MsDecimais(1))
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcular Dias, Meses e Anos Trabalhado                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nMesI    := Month(SRA->RA_ADMISSA)
	nAnoI    := Year(SRA->RA_ADMISSA)
	cDataI   := StrZero(nAnoI,4) + StrZero(nMesI,2)
	nMesF    := Month(dDataDem)
	nAnoF    := Year(dDataDem)
	cDataF   := StrZero(nAnoF,4) + StrZero(nMesF,2)
	dDataIni := SRA->RA_ADMISSA
	While cDataI != cDataF
		AADD(aMeses,dDataIni)
		nAvanco  := 1 + (Day(LastDay(dDataIni))-Day(dDataIni))
		dDataIni := dDataIni+nAvanco
		nMesI    := nMesI + 1
		IF nMesI > 12
			nMesI := 1
			nAnoI := nAnoI + 1
		EndIF
		cDataI := StrZero(nAnoI,4) + StrZero(nMesI,2)
	Enddo
	AADD(aMeses,dDataIni)
	nMesTrab := Len(aMeses)
	//Mais de 6 meses considera ano completo e menos de um ano nao considera
	nParcial :=  If((nMesTrab / 12) - Int(nMesTrab / 12) > 0.5,1,0) 
	nAnoTrab := If(nMesTrab < 12,0,Int(nMesTrab / 12)) + nParcial
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula anos trabalhados anteriores a 12/1989³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Year(SRA->RA_ADMISSA) < 1990
		aMeses:=	{}
		nMesI    := Month(SRA->RA_ADMISSA)
		nAnoI    := Year(SRA->RA_ADMISSA)
		cDataI   := StrZero(nAnoI,4) + StrZero(nMesI,2)
		cDataF   := "198912"
		While cDataI != cDataF
			AADD(aMeses,dDataIni)
			nAvanco  := 1 + (Day(LastDay(dDataIni))-Day(dDataIni))
			dDataIni := dDataIni+nAvanco
			nMesI    := nMesI + 1
			IF nMesI > 12
				nMesI := 1
				nAnoI := nAnoI + 1
			EndIF
			cDataI := StrZero(nAnoI,4) + StrZero(nMesI,2)
		Enddo
		AADD(aMeses,dDataIni)
		nMesTrab := Len(aMeses)
		nParcial :=  If((nMesTrab / 12) - Int(nMesTrab / 12) > 0.5,1,0) 
		nAnoTrabAnt := If(nMesTrab < 12,0,Int(nMesTrab / 12) + nParcial)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Vacaciones                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aIncRes[1] == "S"    
		nBaseSal := nBaseOtros := 0
		cMes	:=	STRZero(Month(dDataDem),2)
		cAno	:=	STRZero(Year(dDataDem),4)
		//Achar os ultimos 3 meses em que o funcionário trabalhou 30 dias para calcular a base de IPD
		dbSelectArea( "SRD" )
		dbSetOrder(1)
		While Len(aMesesVar) < 3 .And. (cAno+cMes) >= AnoMes(SRA->RA_ADMISSA)
			If cMes == '01'
				cMes 	:= '12'
				cAno	:= Tira1(cAno)
			Else
				cMes	:= Tira1(cMes)
			Endif	
			If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + (cAno+cMes) +aCodFol[31,1]) .And. SRD->RD_HORAS==30
				Aadd(aMesesVar,SRD->RD_DATARQ)
			Endif
		Enddo

		For nX:= 1 To Len(aMesesVar)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pegar o promedio de remuneracao dos ultimos 3 meses                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea( "SRD" )
			dbSetOrder(1)
			dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + aMesesVar[nX] , .T. )
			While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT .And. SRD->RD_DATARQ == aMesesVar[nX]
				If Alltrim(PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_MEDFER")) == "S"
					nBaseOtros	+=	SRD->RD_VALOR * If(PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "1",1,IF(PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "2",-1,0))
				Endif
				dbSkip()
			Enddo
		Next
		
		If Len(aMesesVar) > 0
			nBaseVar	:=	(nBaseOtros/Len(aMesesVar))
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para funcionarios com remuneracao variavel, a base de calculo deve ser o salario + 	³
		//|as outras remuneracoes																					³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If M->RG_DFERVEN > 0
			nDias	:=	(LOCFimFer(M->RG_DATADEM+1,M->RG_DFERVEN,'1',.T.,.T.,.T.)-M->RG_DATADEM)-1
			FGeraVerba(aCodFol[086,1],Round( ( If(nBaseVar > 0,nBaseVar,M->RG_SALMES) / 30 ) * nDias ,MsDecimais(1)) ,nDias)
      Endif
		If M->RG_DFERPRO > 0
			nDias	:=	(LOCFimFer(M->RG_DATADEM+1,M->RG_DFERPRO,'1',.T.,.T.,.T.)-M->RG_DATADEM)-1
			//Para ferias proporcionais com decimais, manter as decimais no calculo
			If nDias > 0 .And. (M->RG_DFERPRO - INT(M->RG_DFERPRO)) > 0
				nDias := (nDias - 1)+ (M->RG_DFERPRO - INT(M->RG_DFERPRO))
			Endif
			FGeraVerba(aCodFol[087,1],Round( ( If(nBaseVar > 0,nBaseVar,M->RG_SALMES) / 30 ) * nDias ,MsDecimais(1)) ,nDias)
      Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Base de IPD sera utilizada para Indenizacao e Aviso Previo            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aIncRes[3] == "S" .or. aIncRes[2] == "S"
		nBaseSal := nBaseOtros := 0
		cMes	:=	STRZero(Month(dDataDem),2)
		cAno	:=	STRZero(Year(dDataDem),4)
		//Achar os ultimos 3 meses em que o funcionário trabalhou 30 dias para calcular a base de IPD
		dbSelectArea( "SRD" )
		dbSetOrder(1)
		While Len(aMesesIPD) < 3 .And. (cAno+cMes) >= AnoMes(SRA->RA_ADMISSA)
			If cMes == '01'
				cMes 	:= '12'
				cAno	:= Tira1(cAno)
			Else
				cMes	:= Tira1(cMes)
			Endif	
			If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + (cAno+cMes) +aCodFol[31,1]) .And. SRD->RD_HORAS==30
				Aadd(aMesesIPD,SRD->RD_DATARQ)
			Endif
		Enddo

		For nX:= 1 To Len(aMesesIPD)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pegar o promedio de remuneracao dos ultimos 3 meses                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea( "SRD" )
			dbSetOrder(1)
			dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + aMesesIPD[nX] , .T. )
			While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT .And. SRD->RD_DATARQ == aMesesIPD[nX]
				If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_INDEN") == "S"
					nBaseOtros	+=	SRD->RD_VALOR * If(PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "1",1,IF(PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "2",-1,0))
				Endif
				dbSkip()
			Enddo
		Next
		If Len(aMesesIPD) > 0
			nBaseIPD	:=	Round((nBaseOtros/Len(aMesesIPD)),MsDecimais(1))
			nBaseAvi := nBaseIPD
		Endif
	Endif
	If aIncRes[3] == "S"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se for funcionario for anterior a 08/1981   nao existe limite  ³
		//³para meses de indenizacao.                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AnoMes(SRA->RA_ADMISSA) > "198108"
			nAnoTrab	:=	Min(nAnoTrab,Val(aIncRes[4]))
		Endif
	  	
	  	If AnoMes(SRA->RA_ADMISSA) > "198103"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Aplicar o fator para tirar o incremento provisional³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(SRA->RA_INCPROV)
				If FPHIST82(xFilial("SRX") , "57" , SRA->RA_INCPROV)
				   nIncProv := Val(Substr( SRX->RX_TXT ,31 ,9 ) )
				Endif				
				nBaseIPD := Round(nBaseIPD / nIncProv,MsDecimais(1))
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se a base de calculo ultrapassou o top de UFs ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nBaseIPD > (nValUF * Val(aIncRes[5]))
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se media dos ultimos 24 meses for maior que o top de UFs,      ³
			//³calcular diferenca a tributar pela media (base total - media)  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
				If (nSalProm > (nValUF * Val(aIncRes[5]))) 
					nBaseExc := nBaseIPD - nSalProm
 	            Else
					nBaseExc := nBaseIPD - (nValUF * Val(aIncRes[5])) 
 	            EndIf

 				nBaseIPD := (nValUF * Val(aIncRes[5])) // Valor ate o teto
			
			Endif
      	Endif
		
		//A Indenizacao voluntaria deve ser informada pelo usuario      
		If (nPos:= Ascan(aPd, { |X| X[1] = aCodfol[395,1] .And. X[9] # "D"})) > 0
			nIndVol := aPd[nPos,5]
		Endif

		nIndLegal := ( Round(nBaseIPD,MsDecimais(1)) * nAnoTrab ) 

		FGeraVerba(aCodFol[110,1],Round(nIndLegal,MsDecimais(1)),nAnoTrab)  
        
        If !lTopInd
			FGeraVerba(aCodFol[922,1],Round((nBaseExc * nAnoTrab),MsDecimais(1)),nAnoTrab)  
		EndIf	
		
	Endif  
	If nIndLegal + nIndVol > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calcula a base de IR Indenizacao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If FPHIST82(xFilial("SRX") , "64" , "198912")
			nValUF89	:= Val( SubStr( SRX->RX_TXT ,  19 , 18 ) )
		Endif
		//Salario do funcionario em Dez/1989
		nRemun89 := SRA->RA_SALINDE
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento da Base de calculo ate 12/1989³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nAnoTrabAnt > 0
			nBase89 := nRemun89 * nAnoTrabAnt
			//Deve obedecer ao tope de Ufs e ao tope de anos trabalhados
			nBaseRem89:= If(nRemun89 <= (nValUF89 * Val(aIncRes[7])),nRemun89,Round(nValUF89 * Val(aIncRes[7]),MsDecimais(1))) * If(nAnoTrabAnt > Val(aIncRes[6]),Val(aIncRes[6]),nAnoTrabAnt)
			nBase1 := Round(nBase89 - nBaseRem89,MsDecimais(1))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Tratamento da Base de Indenizacao a partir de 12/1989³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nBaseAtu:=((nBaseIPD - nRemun89) * nAnoTrabAnt) + (nBaseIPD * (nAnoTrab - nAnoTrabAnt))
			nBaseAtu := nBaseAtu + nIndVol
			nBase2 := Round((nBaseAtu * nSalProm * nAnoTrab) / (nIndLegal + nIndVol),MsDecimais(1)) 
	 		nBase2 := nBaseAtu - nBase2    
     
			nBaseIRRes := Round(nBase1 + nBase2,MsDecimais(1))
		Else 
		  nBaseIrRes := Round((nIndLegal + nIndVol)- (nSalProm * nAnoTrab),MsDecimais(1) ) 
		Endif
		nBaseIRRes := If(nBaseIRRes > 0,nBaseIRRes,0)
	Endif	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcular Pre Aviso                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aIncRes[2] == "S" .And. nDiasAv > 0                                     
		If !Empty(M->RG_DTAVISO)
			nDiasAv 		-= (dDatadem - M->RG_DTAVISO)
		EndIf
		FGeraVerba(aCodFol[111,1],Round(nDiasAv *(nBaseAvi/30),MsDecimais(1)),nDiasAv)
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		//³ Calcular Gratificacao Indenizada                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nBaseIPD>0 
			FGeraVerba(aCodFol[368,1],Round(nDiasAv *(nBaseIPD/30),MsDecimais(1)))		
		ElseIf nBasevar>0
			FGeraVerba(aCodFol[368,1],Round(nDiasAv *(nBaseVar/30),MsDecimais(1)))				
		Endif
	Endif
ElseIf cPaisLoc == "URU"
	//Calcular salario vacacional (usado nas ferias e no IPD)
	For nX:=1	To	Len(aPdTemp)
		nPosPdv	:=	Ascan(aPdv,{|x| x[1] == aPdTemp[nX][1]})
		If nPosPdv > 0 .And. aPdv[nPosPdv][27] <> "3"
			nSalVac	+=	aPdTemp[nX][5] * If(aPdv[nPosPdv][27] == "1",1,-1)
		Endif
		If SRA->RA_CATFUNC $ "H" .And. (aPdTemp[nX][1] == aCodFol[032,1] .Or. aPdTemp[nX][1] == aCodFol[311,1])
			nJornadas	+=	aPdTemp[nX][4]
		Endif
	Next
	//Zera o array temporario
	aPdTemp	:=	Nil     
	nDiaSalVac	:=	nSalVac/If(nJornadas > 0,nJornadas,30)
	//Calcula o valor do salario vacacional por dia de ferias
    nPropSalVac := nDiaSalVac / SALDIA
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcular Dias, Meses e Anos Trabalhado                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nMesI    := Month(SRA->RA_ADMISSA)
	nAnoI    := Year(SRA->RA_ADMISSA)
	cDataI   := StrZero(nAnoI,4) + StrZero(nMesI,2)
	nMesF    := Month(dDataDem)
	nAnoF    := Year(dDataDem)
	cDataF   := StrZero(nAnoF,4) + StrZero(nMesF,2)
	dDataIni := SRA->RA_ADMISSA
	
	While cDataI != cDataF
		AADD(aMeses,dDataIni)
		nAvanco  := 1 + (Day(LastDay(dDataIni))-Day(dDataIni))
		dDataIni := dDataIni+nAvanco
		nMesI    := nMesI + 1
		IF nMesI > 12
			nMesI := 1
			nAnoI := nAnoI + 1
		EndIF
		cDataI := StrZero(nAnoI,4) + StrZero(nMesI,2)
	Enddo
	AADD(aMeses,dDataIni)
	nDiaTrab := dDataDem - SRA->RA_ADMISSA
	nMesTrab := Len(aMeses)
	If Len(aMeses) /12 > Int(Len(aMeses)/12) //Quando o func.trabalha alguns meses no
		nAnoTrab := Int(Len(aMeses)/12) + 1   //Ano, e considerado como 1 ano inteiro
	Else
		nAnoTrab := Len(aMeses) /12
	Endif
	//Calcula o fator de ferias (quantos dias de ferias correspondem por mes)
	If nAnoTrab >= 5
		nFatorFer	:=	(20+Int(nAnoTrab/4))/12
	Else
		nFatorFer	:=	20/12
	Endif
	nAnoTrabInd := nAnoTrab
	If nAnoTrab >= 6
		nAnoTrab := 6
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aguinaldo                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aIncRes[_AGUINALDO] == "S"
		If Month(dDataDem) > 5  .And. Month(dDataDem) < 12
			nMesAgui := 6  //A referencia para o calculo eh a partir de 12/XX
			nAnoAgui := Year(dDataDem)              //para 1 parcela e 06/XX para segunda parcela 
		ElseIf Month(dDataDem) <=  5  
			nMesAgui := 12             
			nAnoAgui := Year(dDataDem) - 1
		Else
			nMesAgui := 12             
			nAnoAgui := Year(dDataDem)
		Endif
	
		cDataIAg := Strzero(nAnoAgui,4) + Strzero(nMesAgui,2)
		dbSelectArea( "SRD" )
		dbSetOrder(1)
		dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cDataIAg , .T. )
		While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT;
			.And. (SRD->RD_DATARQ >=cDataIAg) // .And. SRD->RD_DATARQ <=cDataFAg)
			If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_REF13") = "S"  .And.;
			 	SRD->RD_PD <> aCodFol[22,1] .And. SRD->RD_PD <> aCodFol[24,1] //desconsidera 1a e 2a parcela
				If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "1"
					If SRD->RD_PD == aCodFol[31,1] .or. SRD->RD_PD == aCodFol[32,1]
						nBaseSal		+=	 SRD->RD_VALOR
					Else
						nBaseOtros	+=	 SRD->RD_VALOR
					Endif
				ElseIf PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "2"
					nBaseSal		-=	 SRD->RD_VALOR
				Endif
			Endif	
			dbSkip()
		Enddo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso existir alguma verba no mes, somar no acumulado	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SRC->(DbSetOrder(1))
		SRC->(DbSeek(xFilial()+SRA->RA_MAT ))
		While !SRC->(Eof()) .And. SRC->RC_FILIAL + SRC->RC_MAT == SRA->RA_FILIAL + SRA->RA_MAT
			If PosSrv(SRC->RC_PD,SRC->RC_FILIAL,"RV_REF13") = "S"  		
				If PosSrv(SRC->RC_PD,SRC->RC_FILIAL,"RV_TIPOCOD") == "1"
					If SRC->RC_PD == aCodFol[31,1] .or. SRC->RC_PD == aCodFol[32,1]
						nBaseSal		+=	 SRC->RC_VALOR
					Else
						nBaseOtros	+=	 SRC->RC_VALOR
					Endif
				Endif
			Endif
			SRC->(dbSkip())
		Enddo 
      For nX:=1 to Len(aPd)      //Somar as verbas da rescisao
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ N„o deve valorizar verbas Deletadas                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aPd[nX,9] == "D" .or. aPd[nX,3] <> cSemana
				Loop
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Soma os valores nao habituais                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_REF13") $ "S" 
      		If PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_TIPOCOD") == "1"
		    		nBaseSal += aPd[nX,5]
		    	ElseIf PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_TIPOCOD") == "2"
		    		nBaseSal -= aPd[nX,5]
		    	Endif	
			Endif
		Next        
		FGeraVerba(aCodfol[25,1],Round((nBaseSal+nBaseOtros)/12,MsDecimais(1)),0)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³IPD - Indemnizacion por Despido           |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aIncRes[_PGINDE] == "S" .or. aIncRes[_FERIAS] == "S"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo do IPD para Salario Mensal - Uruguai Ley 10489³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SRA->RA_CATFUNC $ "M*C*D*E" .And. SRA->RA_TIPOPGT == "M"
			nMes := Month(dDataDem)-1
			nAno := Year(dDataDem)
			If nMes == 0
				nMes := 12
				nAno--
			Endif
			//Data Inicial para calcular a base do IPD
			cDataIniIPD	:=	Strzero(nAno,4) + StrZero(nMes,2)
			dbSelectArea( "SRD" )
			dbSetOrder(1)
			dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cDataIniIPD , .T. )
			While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT;
				.And. (SRD->RD_DATARQ >=cDataIniIPD )
				If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_IPD") == "S"
					//Ultimo Salario Mensalista
					If SRD->RD_PD $ aCodfol[31,1]+"/"+aCodfol[219,1]
						aUltSal[1] :=	SRD->RD_VALOR
					ElseIf PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "1"
						nBaseIPD		+=	 SRD->RD_VALOR
					ElseIf PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "2"
						nBaseIPD		-=	 SRD->RD_VALOR
					Endif
				Endif
				dbSkip()
			Enddo
			//valor de IPD mensal=Ultimo Salario + verbas com incidencia de IPD
			nQtdIpd := If(Val(aIncRes[8]) <> 0, Val(aIncRes[8]), 1 )
			nVlrIpd	:=	(aUltSal[1] + nBaseIPD)
			nBaseFer := nVlrIpd 
			If aIncRes[_PGINDE] == "S" 
				nVlrIpdTot := nVlrIpd * nAnoTrab * nQtdIpd
				If nVlrIpdTot > 0
					FGeraVerba(aCodFol[110,1],Round(nVlrIpdTot,MsDecimais(1)),nAnoTrab)
				Endif
				//Incrementar ao IPD o correspondente a "Aguinaldo"
		        If aIncRes[5]== "S" 
					FGeraVerba(aCodFol[380,1],Round((nVlrIpd / 12) * nAnoTrab * nQtdIpd ,MsDecimais(1)),nAnoTrab)
				Endif	
				//Incrementar ao IPD o valor correspondente as ferias
		        If aIncRes[6]== "S" 
					FGeraVerba(aCodFol[381,1],Round((nVlrIpd /30) * (nFatorFer*nAnoTrab*nQtdIpd),MsDecimais(1)),nAnoTrab)
			    Endif
				//Incrementar ao IPD o valor correspondente ao salario vacacional,
		        If aIncRes[7]== "S" 
					FGeraVerba(aCodFol[382,1],Round((nSalVac /30)* (nFatorFer * nAnoTrab * nQtdIpd),MsDecimais(1)),nAnoTrab)
			    Endif
			Endif	
		Else
			If aIncRes[_PGINDE] == "S"		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calculo do IPD para Salario Horista - Uruguai ley 10.570³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nQtdIpd := If(Val(aIncRes[8]) <> 0, Val(aIncRes[8]), 1 )
				
				nMes := Month(dDataDem)-1
				nAno := Year(dDataDem)
				If nMes == 0
					nMes := 12
					nAno--
				Endif
				//Data Inicial para calcular a base do IPD
				cDataIniIPD	:=	Strzero(nAno,4) + StrZero(nMes,2)
				dbSelectArea( "SRD" )
				dbSetOrder(1)
				dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cDataIniIPD , .T. )
				While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT;
					.And. (SRD->RD_DATARQ >=cDataIniIPD )
					If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_IPD") == "S"
						//Ultimo Salario Horista  e Base IPD
						If SRD->RD_PD == aCodfol[32,1]
							aUltSal[1] :=	SRD->RD_VALOR
						ElseIf PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "1"
							nBaseIPD		+=	 SRD->RD_VALOR
						ElseIf PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "2"
							nBaseIPD		-=	 SRD->RD_VALOR
						Endif
					Endif
					dbSkip()
				Enddo

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calcula Jornadas Trabalhadas³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dDataPro := dDataDem
				For nx := 1 to nAnoTrabInd 
					nMes := Month(dDataPro) - 11
					nAno := Year(dDataPro)
					If nMes == 0
						nMes := 1
						nAno := nAno - 1
					Endif
					If nMes < 0
						nMes := 12 - ( nMes * -1 )
						nAno := nAno - 1
					Endif
					cDataIni := Strzero(nAno,4) + Strzero(nMes,2)
					nMesFim  := Month(dDataPro)
					nAnoFim  := Year(dDataPro)
					If nMesFim == 0
						nMesFim := 12
						nAnoFim := nAnoFim -1
					Endif
					cDataFim := Strzero(nAnoFim,4) + Strzero(nMesFim,2)
					dDataPro := dDataPro - 365
				
					dbSelectArea( "SRD" )
					dbSetOrder(1)
					dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cDataIni , .T. )
					cMesAnt	:=	""
					nMeses	:=	0
					While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT .And. SRD->RD_DATARQ <= cDataFim
						If SRD->RD_PD == aCodFol[360,1] //Dias trabalhados por horista
							nDias     +=  SRD->RD_HORAS
						Endif
						If SRD->RD_PD == aCodFol[072,1]//Dias de Ferias
							nDias += SRD->RD_HORAS
						Endif 
						dbSkip()
					Enddo
					//Dias Feriado
					DiasNoDesc(Ctod('01/'+Right(cDataIni,2)+"/"+Left(cDataIni,4)),Ctod('01/'+Right(cDataFim,2)+"/"+Left(cDataFim,4)),@nDiasNDesc)
					nDias += nDiasNDesc    //Somar os dias de Feriado Pago
					
					If cDataFim == AnoMes(dDataDem) 
						DbSelectArea("SRC")
						SRC->(DbSetOrder(1))
						SRC->(DbSeek(xFilial()+SRA->RA_MAT ))
						While !SRC->(Eof()) .And. SRC->RC_FILIAL + SRC->RC_MAT == SRA->RA_FILIAL + SRA->RA_MAT
							If SRC->RC_PD == aCodFol[360,1]   
								nDias += SRC->RC_VALOR
							Endif
							SRC->(dbSkip())
						EndDo
					   nDiasUltAno := nDias
					Endif	
				    AADD(aJornada,nDias)
					nDias  := 	nDiasNDesc := 0
				Next
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ordenar as Jornadas de forma descrescente de dias trabalhados   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aJornadaTr := ASort(aJornada,,,{|x,y| x > y })				
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calcular promedio³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                                      
				For nX := 1 to If(Len(aJornadaTr) <= 6, Len(aJornadaTr), 6)
					nTotDias += aJornadaTr[nX]
				Next
				nPromedio := nTotDias / If(Len(aJornadaTr)<= 6,Len(aJornadaTr), 6)
				If nTotDias >= Iif(aIncRes[4] <> Nil,Val(aIncRes[4]),0)
					//Ley 10.570 e 12.597
					For nY := If(Len(aJornadaTr)<= 6,Len(aJornadaTr), 6) to 1 STEP -1
						//Caso I) no ultimo ano tem 240 jornais
						If aJornadaTr[nY] >=240
							nVlrIpd	+= 25 * SALDIA
							nJornInd += 25
							//Caso II) no ultimo ano nao tem 240 jornais mais o promedio e superior a 240
						Elseif aJornadaTr[nY] < 240 .and. nPromedio >= 240
							nVlrIpd	+= 25 * SALDIA
							nJornInd += 25
							//Caso III) se nao tem 240 jornadas em algum ano, correspondem
							// 2 a cada 25 jornais nos anos que que nao chega aos 240
						Else
							nVlrIpd += NoRound(aJornadaTr[nY] /25) * (SALDIA *2)
							nJornInd += 25
						Endif
					Next
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Promedio de Indenizacao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aMediaHrs:= {}					
				//Media de Horas Extras e adicionais,comissoes, premios..3892.112

				MedHrsFer(@aMediaHrs,@nMediaOut)   
	
 				//Acumula a Media de Horas Extras e os percentuais para cada tipo de hora extra
				If nDiasUltano > 0
				   For nX := 1 to Len(aMediaHrs)
				   	  nRemVar := Round((aMediaHrs[nX][1] / nDiasUltAno) * SALHORA , MsDecimais(1))  
				      nTotVar += ((nRemVar * aMediaHrs[nX][2])/100) * nJornInd
				   Next                  
			   	//Gera media de horas de Indenizacao
//					FGeraVerba(aCodFol[250,1],nTotVar)				
				Endif	
				If nVlrIpd + nTotVar + nBaseIpd > 0 
					nBaseIpd := nBaseIpd * If(len(aJornadaTr)<=6,Len(aJornadaTr),6) * nQtdIpd
					FGeraVerba(aCodFol[110,1],Round(nVlrIpd+nTotVar+nBaseIpd ,MsDecimais(1)))				
				Endif
			Endif 
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Vacaciones                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aIncRes[_FERIAS] == "S"
		nDias := 0
		If M->RG_DFERVEN + M->RG_DFERPRO > 0
			If SRA->RA_CATFUNC $ "M*C*D" .And. SRA->RA_TIPOPGT = "M"
				cCodDias	:= aCodFol[031][1]
			ElseIf SRA->RA_CATFUNC $ "E" .And. SRA->RA_TIPOPGT = "M"
				cCodDias	:= aCodFol[219][1]
			Elseif SRA->RA_CATFUNC $ "H"
				cCodDias	:= aCodFol[360][1]  //Base de dias trabalhados para horista
			Endif

			//Pega medias de ferias
			aMediaHrs:= {}					
			MedHrsFer(@aMediaHrs,@nMediaOut)   			

			If M->RG_DFERVEN > 0 
				nDias := nDiasFer := nDiasNDesc := nRemVar := nTotVar := nVlIr:=0
				//Calcula os dias trabalhados no ano
				nDias	:=	 DiasTrabAno(STR(Year(M->RG_DATADEM)-1,4)+'01',STR(Year(M->RG_DATADEM)-1,4)+"12",cCodDias,.T.)
				//Calcula os dias de Ferias no Ano Anterior
				nDiasFer:=DiasTrabAno(STR(Year(M->RG_DATADEM)-1,4)+'01',STR(Year(M->RG_DATADEM)-1,4)+"12",aCodFol[072][1],.T.)
		   	//Verifica se houve faltas no descontables(Sin Citacion) para entrar no calculo
	   		DiasNoDesc(SRF->RF_DATABAS,Ctod('31/12/'+StrZero(Year(SRF->RF_DATABAS))),@nDiasNDesc)
				//Somatoria dos Dias Trabalhados com os Dias Sin Citacion + Dias de Ferias
				nDias := nDias+nDiasNDesc+nDiasFer
	 			//Acumula a Media de Horas Extras e os percentuais para cada tipo de hora extra
			   For nX := 1 to Len(aMediaHrs)
			   	If aMediaHrs[nX][3] == '1'        //Media de Horas do ano anterior
   					nRemVar := Round(((aMediaHrs[nX][1] / nDias)*M->RG_DFERVEN) * SALHORA, MsDecimais(1))  
		   	   	nTotVar += (nRemVar * aMediaHrs[nX][2])/100
		   	   Endif
			   Next                              
			   //Gera Media de Horas Extras - Ferias Vencidas
			   FGeraVerba(aCodFol[248,1],nTotVar)
				//Gera Media de Horas Extras - Salario Vacacional
         Endif
			If M->RG_DFERPRO > 0
				nDias := nDiasFer := nDiasNDesc := nRemVar := nTotVar := nVlIr:=0
				//Calcula os dias trabalhados no ano
				nDias	:=	 DiasTrabAno(STR(Year(M->RG_DATADEM),4)+'01',AnoMes(M->RG_DATADEM),cCodDias,.T.)
				//Calcula os dias de Ferias no Ano Anterior
				nDiasFer:=DiasTrabAno(STR(Year(M->RG_DATADEM),4)+'01',AnoMes(M->RG_DATADEM),aCodFol[072][1],.T.)
			   //Verifica se houve faltas no descontables(Sin Citacion) para entrar no calculo
	   		DiasNoDesc(Ctod('01/01/'+StrZero(Year(M->RG_DATADEM))),Ctod('31/12/'+StrZero(Year(M->RG_DATADEM))),@nDiasNDesc)
				//Somatoria dos Dias Trabalhados com os Dias Sin Citacion + Dias de Ferias
				nDias := nDias+nDiasNDesc+nDiasFer+DiasTrab
 				//Acumula a Media de Horas Extras e os percentuais para cada tipo de hora extra

			   For nX := 1 to Len(aMediaHrs)
			   	If aMediaHrs[nX][3] == '2'       //Tipo 2 - Media de Horas do ano
   					nRemVar := Round(((aMediaHrs[nX][1] / nDias)*M->RG_DFERPRO) * SALHORA, MsDecimais(1))  
			      	nTotVar += (nRemVar * aMediaHrs[nX][2])/100
			      Endif
		   	Next          
				//Media de Horas Extras - Ferias Proporcionais
				FGeraVerba(aCodFol[249,1],nTotVar)           
			Endif
			//Gera ferias vencidas
			If (.F.) .And. SRA->RA_CATFUNC $ "M*C*D*E" .And. SRA->RA_TIPOPGT == "M"
				nFerVen := Round(nBaseFer/30 * M->RG_DFERVEN,MsDecimais(1) )
			Else
				nFerVen := Round(SALDIA * M->RG_DFERVEN,MsDecimais(1) )
			Endif
			If nFerVen > 0
				FGeraVerba(aCodFol[086,1],nFerVen,M->RG_DFERVEN)
		   Endif
			//Gera ferias Proporcionais
			If (.F.) .And. SRA->RA_CATFUNC $ "M*C*D*E" .And. SRA->RA_TIPOPGT == "M"
				nFerPro := Round(nBaseFer/30 * M->RG_DFERPRO,MsDecimais(1) )
			Else
				nFerPro := Round(SALDIA * M->RG_DFERPRO,MsDecimais(1) )
			Endif
			If nFerPro > 0
				FGeraVerba(aCodFol[087,1],nFerPro,M->RG_DFERPRO)
         Endif
		Endif
	Endif
ElseIf cPaisLoc == "DOM"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo da media do salario no ultimo ano ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nMes := Month(dDataDem) - 12
	nAno := Year(dDataDem)
	If nMes == 0
		nMes := 1
		nAno := nAno - 1
	Endif
	If nMes < 0
		nMes := 12 - ( nMes * -1 )
		nAno := nAno - 1
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for liquidacao anual eh usado a data de entrada ou usado a data do ultimo ano³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	If lTipCes == "S"         	
	   cDataMed := If(!Empty(SRA->RA_DTENTRA),StrZero(Year(SRA->RA_DTENTRA),4)+StrZero(Month(SRA->RA_DTENTRA),2),(StrZero(nAno,4) + StrZero(nMes,2)))
	Else                       
		cDataMed := (StrZero(nAno,4) + StrZero(nMes,2))
	Endif
	dbSelectArea( "SRD" )
	dbSetOrder(1)
	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cDataMed, .T. )
	cMesAnt	:=	""
	While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT ;
		.And. SRD->RD_DATARQ <= AnoMes(dDataDem)
		If SRD->RD_PD == aCodFol[318,1]         //Calcula o promedio pelo salario base
			nBaseCes		+=	 SRD->RD_VALOR
		Endif
		If cMesAnt	<>	SRD->RD_DATARQ
			nMesCes++
			cMesAnt	:=	SRD->RD_DATARQ
		Endif
		dbSkip()
	Enddo
	DbSkip(-1)

	If SRD->RD_DATARQ <> Strzero(Year(dDatadem),4)+StrZero(Month(dDataDem),2)
		SRC->(DbSetOrder(1))
		SRC->(DbSeek(xFilial()+SRA->RA_MAT ))
		While !SRC->(Eof()) .And. SRC->RC_FILIAL + SRC->RC_MAT == SRA->RA_FILIAL + SRA->RA_MAT
			If SRC->RC_PD == aCodFol[318,1]
				nBaseCes		+=	 SRC->RC_VALOR
			 	nContSem += 1
			Endif
			SRC->(dbSkip())
		Enddo 
		If	aIncRes[07] == "N"
			If nContSem = 0
				nBaseCes += SalMes 
			ElseIf nContSem =1
				nBaseCes += SalMes /2
			Endif	
		Endif		
		nMesCes++
	Endif
	nBaseCes := nBaseCes / 12
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O Salario Diario eh calculado pelo promedio ou pelo ultimo salario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF nTpAgui == 1  
		nSalDia  := nBaseCes / (Round(SRA->RA_HRSMES/SRA->RA_HRSDIA,2))
	Else 
		nSalDia := SALDIA
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcular Dias, Meses e Anos Trabalhado                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	If lTipCes == "S"         	//Se for liquidacao anual pego a data da ultima rescisao
	   dDataCes := If(!Empty(SRA->RA_DTENTRA),SRA->RA_DTENTRA,SRA->RA_ADMISSA)
	Else
		dDataCes := SRA->RA_ADMISSA
	Endif
	nMesI    := Month(dDataCes)
	nAnoI    := Year(dDataCes)
	cDataI   := StrZero(nAnoI,4) + StrZero(nMesI,2)
	nMesF    := Month(dDataDem)
	nAnoF    := Year(dDataDem)
	cDataF   := StrZero(nAnoF,4) + StrZero(nMesF,2)
	
	dDataIni := dDataCes
	While cDataI != cDataF
		AADD(aMeses,dDataIni)
		nAvanco  := 1 + (Day(LastDay(dDataIni))-Day(dDataIni))
		dDataIni := dDataIni+nAvanco
		nMesI    := nMesI + 1
		IF nMesI > 12
			nMesI := 1
			nAnoI := nAnoI + 1
		EndIF
		cDataI := StrZero(nAnoI,4) + StrZero(nMesI,2)
	Enddo
	AADD(aMeses,dDataIni)
	nDiaTrab := dDataDem - dDataCes
	nMesTrab := Len(aMeses)
	nAnoTrab := ( Len(aMeses) / 12 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcular Indenizacion  - auxilio de cessantia                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LocCesant( @aDiaCes, MesAno(dDataDem))
	
	If aIncRes[01] == "S"
		If nMesTrab >= aDiaCes[1] .And. nMesTrab <= aDiaCes[3]     //3-6 meses
			nIndeniz	:= aDiaCes[2] * nSalDia
			nDiaCes := aDiaCes[2]                      					//5
		ElseIf nMesTrab > aDiaCes[3] .And. nMesTrab <= aDiaCes[5]  //6-12meses
			nIndeniz	:= aDiaCes[4] * nSalDia                    		
			nDiaCes := aDiaCes[4]                      					//13
		ElseIf nMesTrab > aDiaCes[5] .And. nMesTrab <= aDiaCes[7]  //1 , 5 anos
			nIndeniz	:= aDiaCes[6] * nSalDia * INT(nAnoTrab)        
			nDiaCes := aDiaCes[6]                      					//21
			If Mod(nMesTrab,12) > 0
				If Mod(nMesTrab,12) >= aDiaCes[1] .And. Mod(nMesTrab,12) < aDiaCes[3]
					nIndeniz	+= aDiaCes[2] * nSalDia
					nDiaCes += aDiaCes[2]                      			
				ElseIf Mod(nMesTrab,12) > aDiaCes[3] .And. Mod(nMesTrab,12) < aDiaCes[5]
					nIndeniz	+= aDiaCes[4] * nSalDia
					nDiaCes += aDiaCes[4]                      			
				Endif
			Endif		
		ElseIf nMesTrab > aDiaCes[7]                               //5
			nIndeniz	:= aDiaCes[8] * nSalDia * INT(nAnoTrab)
			nDiaCes := aDiaCes[8]                      					//23
			If Mod(nMesTrab,12) > 0
				If Mod(nMesTrab,12) >= aDiaCes[1] .And. Mod(nMesTrab,12) < aDiaCes[3]
					nIndeniz	+= aDiaCes[2] * nSalDia
					nDiaCes += aDiaCes[2]                      //6
				ElseIf Mod(nMesTrab,12) > aDiaCes[3] .And. Mod(nMesTrab,12) < aDiaCes[5]
					nIndeniz	+= aDiaCes[4] * nSalDia
			  		nDiaCes += aDiaCes[4]                      //6
			Endif	
			Endif	
		Endif		                  
		FGeraVerba(aCodFol[110,1],nIndeniz,If(lDiaHora,nDiaCes,(Round(nDiaCes*SRA->RA_HRSMES,2))/(Round(SRA->RA_HRSMES/SRA->RA_HRSDIA,2))))
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcular Indenizacion  - auxilio de cessantia  Morte/Invalidez                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aIncRes[06] == "S"
		If nMesTrab >= aDiaCes[1] .And. nMesTrab < aDiaCes[3]     //3 , 6
			nIndeniz	:= 5 * nSalDia
		ElseIf nMesTrab > aDiaCes[3] .And. nMesTrab < aDiaCes[5]  //6 12
			nIndeniz	:= 10 * nSalDia
		ElseIf nAnoTrab > 1 
			nIndeniz	:= 15 * nSalDia * INT(nAnoTrab)
			If Mod(nMesTrab,12) > 0
				If nMesTrab >= aDiaCes[1] .And. nMesTrab < aDiaCes[3]     //3 , 6
					nIndeniz	+= 5 * nSalDia
				ElseIf nMesTrab > aDiaCes[3] .And. nMesTrab < aDiaCes[5]  //6, 12
					nIndeniz	+= 10 * nSalDia
				Endif
			Endif		
		Endif		
		FGeraVerba(aCodFol[110,1],nIndeniz,If(lDiaHora,nMesTrab,(nMesTrab*SRA->RA_HRSMES)/30))
	Endif	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcular Pre Aviso                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aIncRes[02] == "S" .Or. aIncRes[05] == "S" 
		If nDiasAv = 0
			If FPHIST82(xFilial("SRX") , "66" , MesAno(dDataBase)).Or. FPHIST82(xFilial("SRX") , "66" , "      ")
				aAviso := Array(6)
				aAviso[1] := Val(SubStr( SRX->RX_TXT ,  01, 2 ))
				aAviso[2] := Val(SubStr( SRX->RX_TXT ,  03, 2 ))
				aAviso[3] := Val(SubStr( SRX->RX_TXT ,  05, 2 ))
				aAviso[4] := Val(SubStr( SRX->RX_TXT ,  07, 2 ))
				aAviso[5] := Val(SubStr( SRX->RX_TXT ,  09, 2 ))
				aAviso[6] := Val(SubStr( SRX->RX_TXT ,  11, 2 ))
		   Endif
			nMesesCasa:= (Year(dDataDem)*12)-(Year(SRA->RA_ADMISSA)*12)+Month(dDataDem)-Month(SRA->RA_ADMISSA)	
	   
		   If nAnosCasa >= aAviso[5]/12
		   	nDiasAv   := aAviso[6]
			ElseIf nMesesCasa > aAviso[1] .And. nMesesCasa <= aAviso[3]
				nDiasAv 	:= aAviso[2]
			ElseIf nMesesCasa > aAviso[3] .And. nMesesCasa  < aAviso[5]
				nDiasAv := aAviso[4]
			Else
				nDiasAv := 0	
			Endif 
      Endif
		If nDiasAv > 0
			If aIncRes[02] == "S"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Genera pre-aviso no trabajado                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FGeraVerba(aCodFol[112,1],Round(nDiasAv * nSalDia,MsDecimais(1)),If(lDiaHora,nDiasAv,(Round(nDiasAv*SRA->RA_HRSMES,2))/(Round(SRA->RA_HRSMES/SRA->RA_HRSDIA,2))))
			ElseIf aIncRes[05] == "S"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Genera pre-aviso descontado                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FGeraVerba(aCodFol[113,1],Round(nDiasAv * nSalDia,MsDecimais(1)),If(lDiaHora,nDiasAv,(Round(nDiasAv*SRA->RA_HRSMES,2))/(Round(SRA->RA_HRSMES/SRA->RA_HRSDIA,2))))
			Endif
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aguinaldo                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aIncRes[03] == "S"
	   nMesAgui := 0
		If AnoMes(SRA->RA_DTENTRA) > Strzero(Year(dDataBase),4)+"01"
			cMesAgui := StrZero(Month(SRA->RA_DTENTRA),2)
		Else
			cMesAgui := "01"
		Endif	
		cMesAnt	:=	""
	
		dbSelectArea( "SRD" )
		dbSetOrder(1)
		dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + Strzero(Year(dDataBase),4) + cMesAgui , .T. )
		cMesAnt	:=	""
		While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT .And. Substr(SRD->RD_DATARQ,1,4) == Strzero(Year(dDatadem),4);
			.And. SRD->RD_DATARQ <= AnoMes(dDataDem)
			If SRD->RD_PD == aCodFol[318,1]         //Calcula o promedio pelo salario base
				nBaseSal		+=	 SRD->RD_VALOR
			Endif
			If cMesAnt	<>	SRD->RD_DATARQ
				nMesAgui++
				cMesAnt	:=	SRD->RD_DATARQ
			Endif
			dbSkip()
		Enddo
		DbSkip(-1)

		If SRD->RD_DATARQ <> Strzero(Year(dDatadem),4)+StrZero(Month(dDataDem),2)
			SRC->(DbSetOrder(1))
			SRC->(DbSeek(xFilial()+SRA->RA_MAT ))
			While !SRC->(Eof()) .And. SRC->RC_FILIAL + SRC->RC_MAT == SRA->RA_FILIAL + SRA->RA_MAT
				If SRC->RC_PD == aCodFol[318,1]
					nBaseSal		+=	 SRC->RC_VALOR
				 	nContSem += 1
				Endif
				SRC->(dbSkip())
			Enddo 
			If	aIncRes[07] == "N"
				If nContSem = 0
					nBaseSal += SalMes 
				ElseIf nContSem =1
					nBaseSal += SalMes /2
				Endif	
			Endif		
			nMesAgui++
		Endif
		If nTpAgui == 2
			If SRA->RA_CATFUNC == "M"
				nBaseSal := (SRA->RA_SALARIO) * nMesAgui
			ElseIf SRA->RA_CATFUNC == "H"
				nBaseSal := (SRA->RA_SALARIO * SRA->RA_HRSMES) * nMesAgui 
			ElseIf SRA->RA_CATFUNC == "D"
				nBaseSal := (SRA->RA_SALARIO * (Round(SRA->RA_HRSMES/SRA->RA_HRSDIA,2))) * nMesAgui
			Endif
		Endif

      For nX:=1 to Len(aPd)      //Somar as verbas da rescisao
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ N„o deve valorizar verbas Deletadas                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aPd[nX,9] == "D" .or. aPd[nX,3] <> cSemana
				Loop
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Soma os valores nao habituais                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_REF13") $ "S" 
      		If PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_TIPOCOD") == "1"
		    		nBaseSal += aPd[nX,5]
		    	ElseIf PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_TIPOCOD") == "2"
		    		nBaseSal -= aPd[nX,5]
		    	Endif	
			Endif
		Next        
		FGeraVerba(aCodfol[25,1],Round((nBaseSal)/12,MsDecimais(1)))
	Endif              
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Vacaciones                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  	If aIncRes[04] == "S"
		If M->RG_DFERVEN + M->RG_DFERPRO > 0
			If M->RG_DFERVEN > 0
				nFerVen := Round( If(nTpAgui==1,nSalDia,M->RG_SALMES / (Round(SRA->RA_HRSMES /SRA->RA_HRSDIA,2)))*M->RG_DFERVEN,MsDecimais(1))
				FGeraVerba(aCodFol[072,1],nFerVen,If(lDiaHora,M->RG_DFERVEN,(Round(M->RG_DFERVEN*SRA->RA_HRSMES,2))/(Round(SRA->RA_HRSMES /SRA->RA_HRSDIA,2))))
			Endif
			If M->RG_DFERPRO > 0
				//Gera ferias Proporcioanis
				nFerPro := Round( If(nTpAgui==1,nSalDia,M->RG_SALMES /(Round(SRA->RA_HRSMES /SRA->RA_HRSDIA,2)))*M->RG_DFERPRO,MsDecimais(1))
				FGeraVerba(aCodFol[087,1],nFerPro,If(lDiaHora,M->RG_DFERPRO,(Round(M->RG_DFERPRO*SRA->RA_HRSMES,2))/(Round(SRA->RA_HRSMES /SRA->RA_HRSDIA,2))))
			Endif
		Endif		
	Endif    
Endif
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LOCGANANC ³ Autor ³ MARCOS STIEFANO       ³ Data ³ 05/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula Imposto Ganancias                                  ³±±
±±³          ³ Ex Imposgan.prx                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOCGANANC()
Local nPos			:=	0
Local nBaseCalc		:=	0
Local nIR			:=	0
Local lAchou		:=	.F.
Local nBaseIrpFo	:= 0
Local nBaseIrpFe	:= 0
Local nBaseIrp13	:= 0
Local nValApIrp 	:= 0
Local nVlApIrpF 	:= 0
Local nValPtIrp 	:= 0
Local nBaseMinima	:= 0
Local nVal			:= 0
Local nX 			:= 0
Local nGanNetMes  	:= 0
Local nImpGanan   	:= 0
Local nGanNetMAn  	:= 0
Local nRetEfeMAn  	:= 0
Local nNumConyuge 	:= 0
Local nNumHijo    	:= 0
Local nNumOtras   	:= 0
Local nNImponible 	:= 0
Local nConyuge    	:= 0
Local nHijo       	:= 0
Local nOtras      	:= 0
Local nPrimaSeg   	:= 0
Local nDifPrimaSeg	:= 0
Local nDedEspecial	:= 0
Local nCargasFamil	:= 0
Local nPerc			:= 0
Local nRetencion  	:= 0
Local nAno			:= 0
Local nMes			:= 0
Local nNaoHabitual	:= 0
Local cDataIni		:= ""
Local nRatNaoHab	:= 0
Local nBaseAnual 	:= 0
Local nVlExced  	:= 0 
Local nBaseAnt 		:= 0 
Local lPago 		:= .F.
Local nIRLiq 		:= 0                
Local nVlrIrAnt 	:= 0
Local nVlr13Liq 	:= 0
Local nFerMesFun	:= 0
Local cRatNaoHab	:=	'3' //Quando superar a porcentagem
Local dDataIni		:=	Ctod('')
Local dDataFim		:=	Ctod('')
Local nGastSep		:= 0
Local nDifGastSep	:= 0
Local nSegRetiro  	:= 0
Local nDifSegRet  	:= 0
Local nCredHipo		:= 0
Local nDifCrHip		:= 0
Local nDoacoes		:= 0
Local nDifDoac		:= 0
Local nInsSaud		:= 0
Local nDifSaude		:= 0
Local nHonorMed		:= 0
Local nDifHonMed	:= 0
Local nApObrJub		:= 0
Local nApJubPri		:= 0
Local nObSocObr		:= 0		
Local nCoProp		:= 0
Local nTopDedDon  	:= 0
Local nTopDedSau  	:= 0
Local nTopDedHon  	:= 0 
Local nVlPrePag   	:= 0
Local nDifObra		:= 0
Local cConExE		:= "   "
Local cConExP		:= "   "
Local cConExV		:= "   "
Local nDifObrAcum 	:= 0
Local nPagEmpDom  	:= 0
Local nDifEmpDom  	:=	0
Local nGanMesAnt	:= 0
Local nRetenAnt		:= 0             
Local nBsLiqAnt 	:= 0
Local nPrimSegSem 	:= 0
Local nGastSepSem 	:= 0
Local nSegRetSem	:= 0
Local nCredHipSem 	:= 0
Local nPgDomSem 	:= 0
Local nCarFmSem 	:= 0
Local nDedEsSem 	:= 0
Local nNImpoSem 	:= 0
Local nImpGaSem 	:= 0
Local nDifDoSem 	:= 0
Local nDifSaSem 	:= 0   
Local nDifHonSem	:= 0 
Local nVlPPagSem	:= 0 
Local nBaseIrpAnt 	:= 0
Local nVlIrpAnt   	:= 0
Local nVlIrpPatAnt	:= 0
Local nVlIrpAdAnt 	:= 0
Local cVerba		:= ""
Local nBasIR		:= 0
Local nDesIR		:= 0

If cPaisLoc == "CHI"

	fSetRlq( @nBaseCalc, 5 ) // Monta base para calculo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca base e desconto do acumulado(SRD) e de reliquidacoes 	   ³
	//³ anteriores para composicao da base total e abatimento no 	   ³
	//³ calculo final                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type ( "lReliq" ) # "U" .And. lReliq
		nBasIR		:= Abs( fBuscaAcm( aCodFol[015,1] , , dDataBase, dDataBase, "V" ) )
		nDesIR		:= Abs( fBuscaAcm( aCodFol[066,1] , , dDataBase, dDataBase, "V" ) )
		nBasIR		+= fBuscaRlq( aCodFol[015,1] )
		nDesIR		+= fBuscaRlq( aCodFol[066,1] )
		nBaseCalc	:= nBasIR + nBaseCalc
	EndIf

	nPos	:=	1
	While nPos	<= Len(aIR)
		If  (nBaseCalc <= aIR[nPos][01])
			lAchou	:=	.T.
			Exit
		EndIf
		nPos++
	Enddo

	If lAchou
		nIR	:=	Round((nBaseCalc*aIR[nPos][2])-aIR[nPos][3],MsDecimais(1))

		If Type ( "lReliq" ) # "U" .And. lReliq
			nBaseCalc := ( nBaseCalc - nBasIR )
			fGeraRlq( aCodFol[015,1], nBaseCalc, , .T. ) // Gera/soma verba de reliquidacao no aPd

			nIR := ( nIR - nDesIR )
			fGeraRlq( aCodFol[066,1], nIR, , .T. ) // Gera/soma verba de reliquidacao no aPd
		Else
			FGeraVerba(aCodFol[015,1],nBaseCalc,0)
			FGeraVerba(aCodFol[066,1],nIR, aIR[nPos][2]*100)
		EndIf
	EndIf
	
	fCalaPd( 3 ) // Ajuste do aPd das verbas reliquidadas (assume o valor original)
ElseIf cPaisLoc ==  "URU"
	
	If SRA->RA_TIPOPGT == "S" .And. !lUltSemana .And. c__Roteiro == "FOL"
		Return
	EndIf
	If c__Roteiro == "FOL"
		If (nPos:= Ascan(aPd, { |X| X[1] = aCodfol[016,1] .And. X[9] # "D"})) > 0
			nBaseIrpAnt := aPd[nPos,5]
		EndIf
		If (nPos:= Ascan(aPd, { |X| X[1] = aCodfol[067,1] .And. X[9] # "D"})) > 0
			nVlIrpAnt := aPd[nPos,5]
		EndIf
		If (nPos:= Ascan(aPd, { |X| X[1] = aCodfol[646,1] .And. X[9] # "D"})) > 0
			nVlIrpPatAnt := aPd[nPos,5]
		EndIf
		If (nPos:= Ascan(aPd, { |X| X[1] = aCodfol[100,1] .And. X[9] # "D"})) > 0
			nVlIrpAdAnt := aPd[nPos,5]
		EndIf
	EndIf	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somar as incidencias para apurar a base aporte jubilacion      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If c__Roteiro $ "FOL|RES"
		Aeval( aPd ,{ |X| SomaInc(X,5,@nBaseIrpFo,,,,,,.T.,aCodfol) })  // Incidencia Irp Folha
   	ElseIf c__Roteiro = "FER"
		Aeval( aPd ,{ |X| SomaInc(X,5,@nBaseIrpFe,11,"S",,,,.F.,aCodfol) })  // Incidencia Irp Ferias
   	Else
		Aeval( aPd ,{ |X| SomaInc(X,5,@nBaseIrp13,12,"S",,,,.T.,aCodfol) })  // Incidencia Irp 13salario
   	EndIf
	If nBaseIrpFo > 0
		nPos	:=	1
		While nPos	<= Len(aIR) - 1
			If  (nBaseIRPFo <= aIR[nPos][01])
				lAchou	:=	.T.
				Exit
			EndIf
			nPos++
		Enddo
		If lAchou
			//Base Imposto de Renda Folha
			FGeraVerba(aCodFol[15,1],nBaseIrpFo - nBaseIrpAnt,0.00,,,,,,,,)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verificar se o base de calculo menos o retido é menor que o mesmo calculo                   ³
			//³para o tope da faixa anterior, se for, o imposto sera de um valor tal que o valor a receber ³
			//³nao supere seja inferior ao que receberia so estivesse no tope da faixa anterior            ³
			//³Exemplo : Teto Faixa 1 11700.00 aliquota Faixa 1 7.50%                                      ³
			//³          Teto faixa 2 17550.00 aliquota Faixa 2 9.00%                                      ³
			//³          BASE DE CALCULO 11750.00                                                          ³
			//³ Base Calculo    11750.00 - 11750.00 * 9 /100 = 10692.50 (valor 1) (imposto 1057.50)        ³
			//³ Teto Faixa ant. 11700.00 - 11700.00 * 7.5 /100 = 10822.50 (valor 2)                        ³
			//³ Como valor a receber 1 e menor que valor a receber 2 o valor da retencao deve ser calculado³
			//³ por diferenca:                                                                             ³
			//³     11750.00-10822.50 = 927.50 = Valor de IRP                                              ³
			//³ Isto eh chamado de IRP Variavel                                                            ³
			//³                                                                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPos > 1
				nBaseMinima	:=	aIR[nPos-1][1]-(aIR[nPos-1][1]*aIR[nPos-1][2])
			EndIf
			nVal			:=	nBaseIrpFo - (nBaseIrpFo*aIR[nPos][2])
			
			// Imposto de Renda - Folha					
			If nBaseMinima > nVal 		  
				FGeraVerba(aCodFol[066,1],Round(nBaseIrpFo-nBaseMinima,MsDecimais(1)),aIR[nPos][2]*100,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))
			Else
				FGeraVerba(aCodFol[066,1],Round((nBaseIrpFo*aIR[nPos][2])-nVlIrpAnt,MsDecimais(1)),aIR[nPos][2]*100,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))
			EndIf	
			//Imposto de Renda Patronal Folha
			If nBaseIrpFo > 0 .And. Len(aIr)> 0
		    	FGeraVerba(aCodFol[304,1],Round((nBaseIrpFo*aIR[Len(aIR)])-nVlIrpPatAnt,MsDecimais(1)),aIR[Len(aIR)]*100,,,,,,,,.T.)
         	EndIf
		EndIf
		If aIRAdic <> Nil
			lAchou	:=	.F.
			nPos	:=	1
			While nPos	<= Len(aIRAdic)
				If  (nBaseIRPFo <= aIRAdic[nPos][01])
					lAchou	:=	.T.
					Exit
				EndIf
				nPos++
			Enddo
			If lAchou      
			   //IR - Adicional
				FGeraVerba(aCodFol[310,1],Round((nBaseIrpFo*aIRAdic[nPos][2])-nVlIrpAdAnt,MsDecimais(1)),aIRAdic[nPos][2]*100,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))
			EndIf
		EndIf
	EndIf
	If nBaseIrpFe > 0
		nPos	:=	1
		While nPos	<= Len(aIR) - 1
			If  (nBaseIRPFe <= aIR[nPos][01])
				lAchou	:=	.T.
				Exit
			EndIf
			nPos++
		Enddo
		If lAchou
		   // Base de Imposto de Renda - Ferias
			FGeraVerba(aCodFol[16,1],nBaseIrpFe,0.00,,,,,,,)
			If nPos > 1
				nBaseMinima	:=	aIR[nPos-1][1]-(aIR[nPos-1][1]*aIR[nPos-1][2])
			EndIf
			nVal			:=	nBaseIrpFe - (nBaseIrpFe*aIR[nPos][2])
			//Imposto de Renda - Ferias
			If nBaseMinima > nVal 								
				FGeraVerba(aCodFol[067,1],Round(nBaseIrpFe-nBaseMinima,MsDecimais(1)),aIR[nPos][2]*100,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))
			Else
				FGeraVerba(aCodFol[067,1],Round(nBaseIrpFe*aIR[nPos][2],MsDecimais(1)),aIR[nPos][2]*100,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))
			EndIf	
		   nBaseMinima := 0
			//Imposto de Renda Patronal - Ferias
	 		If nBaseIrpFe > 0 .And. Len(aIr)> 0
		 		FGeraVerba(aCodFol[646,1],Round((nBaseIrpFe*aIR[Len(aIR)]),MsDecimais(1)),aIR[Len(aIR)]*100,,,,,,,,.T.)
			EndIf
		EndIf
		If aIRAdic <> Nil
			lAchou	:=	.F.
			nPos	:=	1
			While nPos	<= Len(aIRAdic)
				If  (nBaseIrpFe <= aIRAdic[nPos][01])
					lAchou	:=	.T.
					Exit
				EndIf
				nPos++
			Enddo
			If lAchou
				FGeraVerba(aCodFol[100,1],Round(nBaseIrpFe*aIRAdic[nPos][2],MsDecimais(1)),aIRAdic[nPos][2]*100,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))
			EndIf
		EndIf
	EndIf
	If nBaseIrp13 > 0
		nPos	:=	1
		While nPos	<= Len(aIR) - 1
			If  (nBaseIRP13 <= aIR[nPos][01])
				lAchou	:=	.T.
				Exit
			EndIf
			nPos++
		Enddo
		If lAchou
		   // Base de Imposto de Renda - 13       
			FGeraVerba(aCodFol[27,1],nBaseIrp13,0.00,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))
			If nPos > 1
				nBaseMinima	:=	aIR[nPos-1][1]-(aIR[nPos-1][1]*aIR[nPos-1][2])
			EndIf
			nVal			:=	nBaseIrp13 - (nBaseIrp13*aIR[nPos][2])
			//Imposto de Renda - 13         
			If nBaseMinima > nVal 								
				FGeraVerba(aCodFol[071,1],Round(nBaseIrp13-nBaseMinima,MsDecimais(1)),aIR[nPos][2]*100,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))
			Else
				FGeraVerba(aCodFol[071,1],Round(nBaseIrp13*aIR[nPos][2],MsDecimais(1)),aIR[nPos][2]*100,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))
			EndIf	
		   	nBaseMinima := 0
			//Imposto de Renda Patronal - 13       
			If nBaseIrp13 > 0 .And. Len(aIr)> 0
	    		FGeraVerba(aCodFol[647,1],Round(nBaseIrp13*aIR[Len(aIR)],MsDecimais(1)),aIR[Len(aIR)]*100,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))
			EndIf
		EndIf
		If aIRAdic <> Nil
			lAchou	:=	.F.
			nPos	:=	1
			While nPos	<= Len(aIRAdic)
				If  (nBaseIrp13 <= aIRAdic[nPos][01])
					lAchou	:=	.T.
					Exit
				EndIf
				nPos++
			Enddo
			If lAchou
				FGeraVerba(aCodFol[302,1],Round(nBaseIrp13*aIRAdic[nPos][2],MsDecimais(1)),aIRAdic[nPos][2]*100,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))
			EndIf
		EndIf
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOC_SEGSOC Autor ³ Silvia                ³ Data ³ 23.03.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Seguro Social AFP  										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOC_SEGSOC(aAFP)

Local nCateg := 0
Local cCateg   

If cPaisLoc == "CHI" 

	If !Empty(SRA->RA_AFP)
		aAFP := Array(14)
		If FPHIST82(xFilial("SRX") , "62" , MesAno(dDataBase)+SRA->RA_AFP+"1" ).Or. FPHIST82(xFilial("SRX") , "62" , "      "+SRA->RA_AFP+"1"  )
			aAFP[1] := Val( SubStr( SRX->RX_TXT ,  22 , 5 ) )
			aAFP[2] := Val( SubStr( SRX->RX_TXT ,  27 , 5 ) )
			aAFP[3] := SubStr( SRX->RX_TXT ,  32 , 3 ) 
			aAFP[4] := SubStr( SRX->RX_TXT ,  35 , 3 ) 
			aAFP[5] := SubStr( SRX->RX_TXT ,  38 , 3 ) 
			aAFP[6] := SubStr( SRX->RX_TXT ,  41 , 3 ) 
			aAFP[7] := SubStr( SRX->RX_TXT ,  44 , 3 ) 
			aAFP[8] := Val( SubStr( SRX->RX_TXT ,  47 , 6 ) )
			aAFP[9] := SubStr( SRX->RX_TXT ,  54 , 3 )
			aAFP[10]:= SubStr( SRX->RX_TXT ,  57 , 3 )
			If FPHIST82(xFilial("SRX") , "62" , MesAno(dDataBase)+SRA->RA_AFP+"2" ).Or. FPHIST82(xFilial("SRX") , "62" , "      "+SRA->RA_AFP+"2"  )
				aAFP[11] := Val( SubStr( SRX->RX_TXT ,  10 , 6 ) )
				aAFP[12] := SubStr( SRX->RX_TXT ,  16 , 3 )
				aAFP[13] := SubStr( SRX->RX_TXT ,  19 , 3 )
				aAFP[14] := Val(SubStr( SRX->RX_TXT ,  22 , 6 ))
		   	Else
				lContinua	:=	.F.
			Endif
		Else
			If GetRemoteType() == -1
				MsgLogGrid( Ap5GetHelp("GPEXAFP"), .F. ) // Retornar string da funcao Help
			Else
				Help(" ",1,"GPEXAFP")
			EndIf
			Return ( .F. )
		Endif
	Endif	
ElseIf cPaisLoc == "DOM"
	aAFP := Array(23,12)
	For nCateg := 1 to 23
		cCateg := StrZero(nCateg,2)
		If FPHIST82(xFilial("SRX"), "62" ,MesAno(dDataBase)+ cCateg+ "1") .Or. FPHIST82(xFilial("SRX") ,"62" ,"      "+cCateg+ "1")	 
			aAFP[nCateg][1] :=  Val( SubStr( SRX->RX_TXT , 01 , 12 ) )
			aAFP[nCateg][2] :=  Val( SubStr( SRX->RX_TXT , 13 , 12 ) )
			aAFP[nCateg][3] :=  Val( SubStr( SRX->RX_TXT , 25 , 08 ) )
			aAFP[nCateg][4] :=  Val( SubStr( SRX->RX_TXT , 33 , 08 ) )
			aAFP[nCateg][5] :=  Val( SubStr( SRX->RX_TXT , 41 , 08 ) )
			aAFP[nCateg][6] :=  Val( SubStr( SRX->RX_TXT , 49 , 08 ) )
			dbSelectArea( "SRX" )
			If FPHIST82(xFilial("SRX"), "62" ,MesAno(dDataBase)+cCateg+ "2") .Or. FPHIST82(xFilial("SRX") ,"62" ,"      "+ cCateg+ "2")	 
				aAFP[nCateg][7] :=  Val( SubStr( SRX->RX_TXT , 01 , 08 ) )
				aAFP[nCateg][8] :=  Val( SubStr( SRX->RX_TXT , 09 , 08 ) )
				aAFP[nCateg][9] :=  Val( SubStr( SRX->RX_TXT , 17 , 08 ) )
				aAFP[nCateg][10] :=  Val( SubStr( SRX->RX_TXT , 25 , 08 ) )
				aAFP[nCateg][11] :=  Val( SubStr( SRX->RX_TXT , 32 , 08 ) )
				aAFP[nCateg][12] :=  Val( SubStr( SRX->RX_TXT , 40 , 08 ) )
      		Endif  
		EndIf
	Next
Endif
Return ( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SEGSOC   ³ Autor ³ MARCOS STIEFANO       ³ Data ³ 19/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula Seguro Social AFP                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LOCSEGSOC()
Local aAFP 		:= Array(14)
Local lContinua := .T.
Local nBaseCalc := 0
Local nBaseInv  := 0
Local nValSIS	:= 0
Local nValFJ	:= 0
Local nValVol	:= 0
Local nValCTV	:= 0
Local nFator 	:= 1
Local nValAfil
Local nValEmp
Local nBaseSeg
Local nX		:= 0
Local cMes
Local cAno
Local cDataIni
Local nBaseCeAnt := 0
Local nSemMes := 1
Local nSegSocEmp := 0
Local nSegSocPat := 0
Local cDataCes   := ""       
Local nDiasTrab  := 0
Local cUbiCtv	
Local cSegInv 	 := SuperGetMv("MV_20255", , "S"	 ,SRA->RA_FILIAL) 
Local nPercSeg	 := 0
Local cBsRlqSI	:= ""
Local cCodSis	:= ""
Local nOldBas	:= 0
Local nOldDes	:= 0
Local nOldSDes	:= 0
Local nOldNDes	:= 0
Local nPercFJ	:= 0
Local nPercSIS	:= 0
Local nPRlq		:= 0
Local lRet		:=	.F.

SetMnemonicos("PERCSEG",NIL,.T.)  

nPercSeg := PERCSEG

If Type("nDiasFer") == "U" 
	nDiasFer := 0
EndIf
	
aAFP	:= Array(14)

If cPaisLoc == "CHI" 

	cUbiCtv	 :=	SRA->RA_UBICTV
	
	If !Empty(SRA->RA_AFP)

		lRet := GXLocRlq( _AFP, , , @nPRlq, SRA->RA_AFP )
		
		If !lRet
			SRX->(DbSetOrder(1))
			If FPHIST82(xFilial("SRX") , "62" , MesAno(dDataBase)+SRA->RA_AFP+"1" ).Or. FPHIST82(xFilial("SRX") , "62" , "      "+SRA->RA_AFP+"1"  )
				aAFP[1] := Val( SubStr( SRX->RX_TXT ,  22 , 5 ) )
				aAFP[2] := Val( SubStr( SRX->RX_TXT ,  27 , 5 ) )
				aAFP[3] := SubStr( SRX->RX_TXT ,  32 , 3 )
				aAFP[4] := SubStr( SRX->RX_TXT ,  35 , 3 )
				aAFP[5] := SubStr( SRX->RX_TXT ,  38 , 3 )
				aAFP[6] := SubStr( SRX->RX_TXT ,  41 , 3 )
				aAFP[7] := SubStr( SRX->RX_TXT ,  44 , 3 )
				aAFP[8] := Val( SubStr( SRX->RX_TXT ,  47 , 6 ) )
				aAFP[9] := SubStr( SRX->RX_TXT ,  54 , 3 )
				aAFP[10]:= SubStr( SRX->RX_TXT ,  57 , 3 )
				If FPHIST82(xFilial("SRX") , "62" , MesAno(dDataBase)+SRA->RA_AFP+"2" ).Or. FPHIST82(xFilial("SRX") , "62" , "      "+SRA->RA_AFP+"2"  )
					aAFP[11] := Val( SubStr( SRX->RX_TXT ,  10 , 6 ) )
					aAFP[12] := SubStr( SRX->RX_TXT ,  16 , 3 ) 
				   	aAFP[13] := SubStr( SRX->RX_TXT ,  19 , 3 ) 
				   	aAFP[14] := Val(SubStr( SRX->RX_TXT ,  22 , 6 )) 
				   	
				   	GXLocRlq( _AFP, .F., { { 'aAFP', aClone(aAFP), SRA->RA_AFP } }, nPRlq )
				Else
					lContinua := .F.
				Endif
			Else
				lContinua := .F.
			Endif
		EndIf
	Else
		lContinua := .F.
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega valores da tabela de seguro de cesantia³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetValSeg()

	If lContinua

		fSetRlq( @nBaseCalc, 4 ) // Monta base para calculo
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca base e desconto do acumulado para abatimento             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type ( "lReliq" ) # "U" .And. lReliq
			nPercFJ		:= Abs( fBuscaAcm( aAFP[3] , , dDataBase, dDataBase, "H" ) )
			
			If MesAno( dDatabase ) <= "200906"
				nPercSIS	:= Abs( fBuscaAcm( aCodFol[923,1] + "/" + aCodFol[924,1], , dDataBase, dDataBase, "H" ) ) // Nunca tem as duas no mesmo mes
			Else
				nPercSIS	:= Abs( fBuscaAcm( aAFP[4], , dDataBase, dDataBase, "H" ) )
			EndIf

			nBaseSeg	:= nBaseCalc
			nOldBas		:= Abs( fBuscaAcm( aAFP[7] , , dDataBase, dDataBase, "V" ) ) / (nPercFJ / 100)
			nOldBas		+= fBuscaRlq( aAFP[7] )
			nBaseCalc	+= nOldBas
		Else
			nPercFJ		:= aAFP[1]
			nPercSIS	:= aAFP[2]
			nBaseSeg	:= nBaseCalc
		EndIf
		
		If c__Roteiro == "RES" 
			If lAdmissao      
				nFator := Max((Day(dDataDem)-Day(SRA->RA_ADMISSA)) - (nDiasAfas - nDiasFer),0) / 30 
			Else	
				nFator := Max( Day(dDataDem) - (nDiasAfas - nDiasFer),0) /30   
			EndIf	
		Else
			nFator := Max((DiasTrab + nDiasFer), 0 ) / 30						   
		EndIf
        // Verifica qual o sistema de pensão o funcionario esta filiado para calcular o Tope.
        
        If SRA->RA_SISPENS == "2"
			If nBaseCalc > nValUF*aAFP[8]
				nBaseCalc   := (nValUF*aAFP[8])
			Endif
		Else  
		 	If nBaseCalc > nValUF*aAFP[14]
				nBaseCalc   := (nValUF*aAFP[14])
			Endif                             
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculo do Seguro de Invalidez                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc == "CHI" .And. MesAno( dDatabase ) > "200906"
			nPercSeg:= ( nPercSeg / 100 )
			
			If Type ( "lReliq" ) # "U" .And. lReliq
				nOldSDes	:= Abs( fBuscaAcm( aCodFol[923,1], , dDataBase, dDataBase, "V" ) )
				nOldNDes	:= Abs( fBuscaAcm( aCodFol[924,1], , dDataBase, dDataBase, "V" ) )
				nOldSDes	+= fBuscaRlq( aCodFol[923,1] )
				nOldNDes	+= fBuscaRlq( aCodFol[924,1] )
					
				If nOldSDes > 0 // As duas verbas nunca existirao simultaneamente dentro da mesma competencia para o funcionario
					cBsRlqSI	:= aCodFol[923,1]
				Else
					cBsRlqSI	:= aCodFol[924,1]
				EndIf
				
				nOldDes	:= nOldSDes + nOldNDes
				
				fGeraRlq( cBsRlqSI, Round( nBaseCalc * nPercSeg, MsDecimais(1) ) - nOldDes, nPercSeg, .T., .T. ) // Gera/soma verba de reliquidacao no aPd
			Else
			     If cSegInv == "S"
			     	FGeraVerba(aCodFol[923,1],Round(nBaseCalc*nPercSeg,MsDecimais(1)))    //Base Seguro de Invalidez
			     Else
			     	FGeraVerba(aCodFol[924,1],Round(nBaseCalc*nPercSeg,MsDecimais(1)))    //Descuento Seguro Invalidez   
			     Endif
			 EndIf
		Endif
		
		nValFJ	:= nBaseCalc * (nPercFJ / 100)
		nValSIS	:= nBaseCalc * (nPercSIS / 100)
	
		If SRA->RA_AFPVOL > 0 .And. !Empty(SRA->RA_TIPOAFP)
			nValVol := If(SRA->RA_TIPOAFP=='1',(SRA->RA_AFPVOL),IIf(SRA->RA_TIPOAFP=='2',(SRA->RA_AFPVOL*nValUF),(nBaseCalc  * (SRA->RA_AFPVOL / 100))))
		Endif
		If SRA->RA_AFPCTV > 0 .And. !Empty(SRA->RA_TIPOCTV)
			nValCTV := If(SRA->RA_TIPOCTV=='1',(SRA->RA_AFPCTV),IIf(SRA->RA_TIPOCTV=='2',(SRA->RA_AFPCTV*nValUF),(nBaseCalc  * (SRA->RA_AFPCTV / 100))))
		Endif

		If Type ( "lReliq" ) # "U" .And. lReliq
			If nValFJ > 0
				nOldDes	:= Abs( fBuscaAcm( aAFP[3] , , dDataBase, dDataBase, "V" ) )
				nOldDes	+= fBuscaRlq( aAFP[3] )
				fGeraRlq( aAFP[3], Round( nValFJ, MsDecimais(1) ) - nOldDes, nPercFJ, .T., .T. ) // Gera/soma verba de reliquidacao no aPd
			Endif
			If nValSIS > 0
				If MesAno( dDatabase ) <= "200906"
					cCodSis	:= aCodFol[923,1] + "/" + aCodFol[924,1] // Nunca tem as duas no mesmo mes
				Else
					cCodSis	:= aAFP[4]
				EndIf

				nOldDes	:= Abs( fBuscaAcm( cCodSis , , dDataBase, dDataBase, "V" ) )
				nOldDes	+= fBuscaRlq( cCodSis )
				fGeraRlq( aAFP[4], Round( nValSIS, MsDecimais(1) ) - nOldDes, nPercSIS, .T., .T. ) // Gera/soma verba de reliquidacao no aPd
			Endif
			If nValVol > 0 .And. !Empty(aAFP[5])
				nOldDes	:= Abs( fBuscaAcm( aAFP[5] , , dDataBase, dDataBase, "V" ) )
				nOldDes	+= fBuscaRlq( aAFP[5] )
				fGeraRlq( aAFP[5], Round( nValVol, MsDecimais(1) ) - nOldDes, , .T., .T. ) // Gera/soma verba de reliquidacao no aPd
			Endif
	    Else
			If nValFJ > 0
				FGeraVerba(aAFP[3],Round((nValFJ),MsDecimais(1)),nPercFJ)
			Endif
			If nValSIS > 0
				FGeraVerba(aAFP[4],Round((nValSIS),MsDecimais(1)),nPercSIS)
			Endif
			If nValVol > 0 .And. !Empty(aAFP[5])
				FGeraVerba(aAFP[5],Round((nValVol),MsDecimais(1)))
			Endif
	    EndIf
	    
		If nValCTV > 0
			nTopeUF := Round(nValUF*aAFP[11],MsDecimais(1)) //  UF$50 Tope de afecto a impuesto.
			If Type ( "lReliq" ) # "U" .And. lReliq
				If nValCTV > nTopeUF
					nOldDes	:= Abs( fBuscaAcm( If(cUbiCtv=="1",aAFP[6],aAFP[12]) , , dDataBase, dDataBase, "V" ) )
					nOldDes	+= fBuscaRlq( If(cUbiCtv=="1",aAFP[6],aAFP[12]) )
					fGeraRlq( If( cUbiCtv == "1", aAFP[6], aAFP[12] ), Round( nTopeUF, MsDecimais(1) ) - nOldDes, , .T., .T. ) // Gera/soma verba de reliquidacao no aPd
					
					nOldDes	:= Abs( fBuscaAcm( If(cUbiCtv=="1",aAFP[9],aAFP[13]) , , dDataBase, dDataBase, "V" ) )
					nOldDes	+= fBuscaRlq( If(cUbiCtv=="1",aAFP[9],aAFP[13]) )
					fGeraRlq( If( cUbiCtv == "1", aAFP[9], aAFP[13] ), Round( nValCTV - nTopeUF, MsDecimais(1) ) - nOldDes, , .T., .T. ) // Gera/soma verba de reliquidacao no aPd
				Else
					nOldDes	:= Abs( fBuscaAcm( If(cUbiCtv=="1",aAFP[6],aAFP[12]) , , dDataBase, dDataBase, "V" ) )
					nOldDes	+= fBuscaRlq( If(cUbiCtv=="1",aAFP[6],aAFP[12]) )
					fGeraRlq( If( cUbiCtv == "1", aAFP[6], aAFP[12] ), Round( nValCTV, MsDecimais(1) ) - nOldDes, , .T., .T. ) // Gera/soma verba de reliquidacao no aPd
				EndIf
			Else
				If nValCTV > nTopeUF
					FGeraVerba(IIF(cUbiCtv=="1",aAFP[6],aAFP[12]),Round(nTopeUF,MsDecimais(1)))
					FGeraVerba(IIF(cUbiCtv=="1",aAFP[9],aAFP[13]),Round(nValCTV-nTopeUF,MsDecimais(1)))
				Else
					FGeraVerba(IIF(cUbiCtv=="1",aAFP[6],aAFP[12]),Round(nValCTV,MsDecimais(1)))
				Endif
			EndIf
		Endif
	
		If nValVol+nValFJ+nValSIS > 0 .And. !Empty(aAFP[7])
			If Type ( "lReliq" ) # "U" .And. lReliq
				nOldDes	:= Abs( fBuscaAcm( aAFP[7], , dDataBase, dDataBase, "V" ) )
				nOldDes	+= fBuscaRlq( aAFP[7] )
				fGeraRlq( aAFP[7], Round( nBaseCalc, MsDecimais(1) ) - nOldDes, , .T., .T. ) // Gera/soma verba de reliquidacao no aPd
			Else
				FGeraVerba(aAFP[7],Round(nBaseCalc,MsDecimais(1)))
			EndIf
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calculo del seguro de cesantia                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nFator < 1
			//Utilizar o ultimo mes completo que o funcionario trabalhou
			cMes := StrZero(Month(If(c__Roteiro == "RES", dDataDem, dDataBase)),2) 
			cAno := StrZero(Year(If(c__Roteiro == "RES", dDataDem, dDataBase)),4)   
			dbSelectArea( "SRD" )
			dbSetOrder(1)
			While Empty(cDataCes) .And. (cAno+cMes) >= AnoMes(SRA->RA_ADMISSA)
				If cMes == '01'
					cMes 	:= '12'
					cAno	:= Tira1(cAno)
				Else
					cMes	:= Tira1(cMes)
				Endif	
				If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + (cAno+cMes)+aCodFol[31,1]) .And. SRD->RD_HORAS==30
					While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT + (cAno+cMes) == SRD->RD_FILIAL+SRD->RD_MAT+SRD->RD_DATARQ
						If SRD->RD_PD == aCodFol[31,1] .or. SRD->RD_PD == aCodFol[72,1]
							nDiasTrab += SRD->RD_HORAS
						Endif
						cDataCes := SRD->RD_DATARQ
						SRD->(DbSkip())
					EndDo	
					If nDiasTrab < 30
						cDataCes := ""
					Endif
					nDiasTrab := 0	
				Endif
			Enddo

			dbSelectArea( "SRD" )
			dbSetOrder(1)
			dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cDataCes +aSegCesa[06] )
			If Found()
				nBaseCeAnt := SRD->RD_VALOR
			Endif
		Endif

		If Type ( "lReliq" ) # "U" .And. lReliq
			nBaseSeg	+= Abs( fBuscaAcm( aSegCesa[06], , dDataBase, dDataBase, "V" ) )
			nBaseSeg	+= fBuscaRlq( aSegCesa[06] )
		EndIf

		If SRA->RA_SEGCESA $ '1S'

			If nBaseSeg > nValUF*aSegCesa[07]
				nBaseCalc := If((nValUF*aSegCesa[07]*nfator) > 0,(nValUF*aSegCesa[07]*nfator),(nValUF*aSegCesa[07]))
			Else
				nBaseCalc := nBaseSeg	
			Endif	
			
			nValAfil  := Round(nBaseCalc  * (aSegCesa[03] / 100),0)
			nValEmp  := Round(If(nBaseCeAnt > 0,nBaseCeAnt,nBaseCalc)  * ((aSegCesa[01]+aSegCesa[08]) / 100),0)
			nBaseCalc := If(nBaseCalc <> 0,nBaseCalc ,nBaseCeAnt)
		
			If Type ( "lReliq" ) # "U" .And. lReliq
				nOldDes	:= Abs( fBuscaAcm( aSegCesa[06], , dDataBase, dDataBase, "V" ) )
				nOldDes	+= fBuscaRlq( aSegCesa[06] )
				fGeraRlq( aSegCesa[06], Round( nBaseCalc, MsDecimais(1) ) - nOldDes, , .T., .T. ) // Gera/soma verba de reliquidacao no aPd
				
				nOldDes	:= Abs( fBuscaAcm( aSegCesa[04], , dDataBase, dDataBase, "V" ) )
				nOldDes	+= fBuscaRlq( aSegCesa[04] )
				fGeraRlq( aSegCesa[04], Round( nValAfil, MsDecimais(1) ) - nOldDes, aSegCesa[03], .T., .T. ) // Gera/soma verba de reliquidacao no aPd
				
				nOldDes	:= Abs( fBuscaAcm( aSegCesa[02], , dDataBase, dDataBase, "V" ) )
				nOldDes	+= fBuscaRlq( aSegCesa[02] )
				fGeraRlq( aSegCesa[02], Round( nValEmp / ( aSegCesa[01] + aSegCesa[08] ) * aSegCesa[01], MsDecimais(1) ) - nOldDes, aSegCesa[01], .T., .T. ) // Gera/soma verba de reliquidacao no aPd
				
				If !( c__Roteiro == "RES" ) .Or. ( Type("SRA->RA_CALINDM") # "U" .And. SRA->RA_CALINDM == "1" )
					nOldDes	:= Abs( fBuscaAcm( aSegCesa[09], , dDataBase, dDataBase, "V" ) )
					fGeraRlq( aSegCesa[09], Round( nValEmp / ( aSegCesa[01] + aSegCesa[08] ) * aSegCesa[08], MsDecimais(1) ) - nOldDes, aSegCesa[08], .T., .T. ) // Gera/soma verba de reliquidacao no aPd
				EndIf
			Else
				FGeraVerba(aSegCesa[06],Round(nBaseCalc,MsDecimais(1)))
				FGeraVerba(aSegCesa[04],Round(nValAfil,MsDecimais(1)),aSegCesa[03])
				FGeraVerba(aSegCesa[02],Round(nValEmp/(aSegCesa[01]+aSegCesa[08])*aSegCesa[01] ,MsDecimais(1)),aSegCesa[01])
				
				If !( c__Roteiro == "RES" ) .Or. ( Type("SRA->RA_CALINDM") # "U" .And. SRA->RA_CALINDM == "1" )
					FGeraVerba(aSegCesa[09],Round(nValEmp/(aSegCesa[01]+aSegCesa[08])*aSegCesa[08] ,MsDecimais(1)),aSegCesa[08])
				EndIf
			EndIf
		EndIf

		If SRA->RA_SEGCESA $ '2F'

			If nBaseSeg > nValUF*aSegCesa[07]
				nBaseCalc := If((nValUF*aSegCesa[07]*nfator) > 0,(nValUF*aSegCesa[07]*nfator),(nValUF*aSegCesa[07]))
			Else
				nBaseCalc := nBaseSeg	
			EndIf
			nValAfil  := Round(nBaseCalc  * (aSegCesa[03] / 100),0)
			//nValEmp  := round(If(nBaseCeAnt > 0,nBaseCeAnt,nBaseCalc) * (aSegCesa[05]/ 100),0)
			nBaseCalc := If(nBaseCalc <> 0,nBaseCalc ,nBaseCeAnt)
			
			If Type ( "lReliq" ) # "U" .And. lReliq
				nOldDes	:= Abs( fBuscaAcm( aSegCesa[06], , dDataBase, dDataBase, "V" ) )
				nOldDes	+= fBuscaRlq( aSegCesa[06] )
				fGeraRlq( aSegCesa[06], Round( nBaseCalc, MsDecimais(1) ) - nOldDes, , .T., .T. ) // Gera/soma verba de reliquidacao no aPd

				nOldDes	:= Abs( fBuscaAcm( aSegCesa[04], , dDataBase, dDataBase, "V" ) )
				nOldDes	+= fBuscaRlq( aSegCesa[04] )
				fGeraRlq( aSegCesa[04], Round( nValAfil, MsDecimais(1) ) - nOldDes, aSegCesa[03], .T., .T. ) // Gera/soma verba de reliquidacao no aPd

			Else
				FGeraVerba(aSegCesa[06],Round(nBaseCalc ,MsDecimais(1)))
				FGeraVerba(aSegCesa[04],Round(nValAfil,MsDecimais(1)),aSegCesa[03])
			EndIf
		EndIf
	EndIf
	
	fCalaPd( 3 ) // Ajuste do aPd das verbas reliquidadas (assume o valor original)
	
ElseIf cPaisLoc == "DOM"
	lPago := LocVerFer()
	If lPago
		Return
	Endif	 
  	LocSemana(@nSemMes,MesAno(dDataBase)) // quantidade  de semanas no mes
	If nSemMes == 1
		nSemana := 3
	ElseIf nSemMes == 2
		nSemana := 5
	ElseIf nSemMes == 3
		nSemana := 7
	ElseIf nSemMes == 4
		nSemana := 9
	ElseIf nSemMes == 5
		nSemana := 11   
	Endif	
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somar as incidencias para apurar a base Seguro Social - IDSS   ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aeval( aPd ,{ |X| SomaInc(X,4,@nBaseCalc,,,,,,.F.,aCodfol) })  // Incidencia IDSS

	If nBaseCalc > 0 
		If SRA->RA_TIPOPGT == "M"  
			nBaseMes := nBaseCalc 
		Else
			If c__Roteiro $ '132|RES'
				nBaseMes := nBaseCalc 			 
			Else	
				nBaseMes := nBaseCalc * 2
			Endif	
		Endif	   
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para quinzenalistas, na primeira quinzena se utiliza o valor da tabela de idss,³
		//³semana2 e para a segunda quinzena é utilizado a semana4 ou semana5 dependendo  ³
		//³ da quantidade de semanas no mes																 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aSegSoc) > 0  
			If SRA->RA_TIPOPGT == "S" .And. !lUltSemana
				If nBaseMes > 0 .And. nBaseMes <= aSegSoc[01][02]  
					nSegSocPat := aSegSoc[01][05]
					nSegSocEmp := aSegSoc[01][06]
				Endif
				For nX := 1 to (Len(aSegSoc) -1)                          
					If nBaseMes > aSegSoc[nX][02] .And. nBaseMes <= aSegSoc[nX+1][02]
						nSegSocPat := aSegSoc[nX+1][05]
						nSegSocEmp := aSegSoc[nX+1][06] 
					Endif
				Next	
				If nBaseMes > aSegSoc[Len(aSegSoc)][02]
					nSegSocPat := aSegSoc[Len(aSegSoc)][05]
					nSegSocEmp := aSegSoc[Len(aSegSoc)][06] 
				Endif	
			ElseIf SRA->RA_TIPOPGT == "S" .And. lUltSemana
				If nBaseMes > 0 .And. nBaseMes <= aSegSoc[01][02]  
					If nSemMes == 4
						nSegSocPat := aSegSoc[01][09] - aSegSoc[01][05] //Tab.Semana4 - Semana2 por que ja foi descontado antes
						nSegSocEmp := aSegSoc[01][10] - aSegSoc[01][06]
					ElseIf nSemMes == 5
						nSegSocPat := aSegSoc[01][11] - aSegSoc[01][05]
						nSegSocEmp := aSegSoc[01][12] - aSegSoc[01][06]
					Endif
				Endif	
				For nX := 1 to (Len(aSegSoc) -1)                          
					If nBaseMes > aSegSoc[nX][02] .And. nBaseMes <= aSegSoc[nX+1][02]
						If nSemMes == 4
							nSegSocPat := aSegSoc[nX+1][09] - aSegSoc[nX+1][05]
							nSegSocEmp := aSegSoc[nX+1][10] - aSegSoc[nX+1][06]
						ElseIf nSemMes == 5
							nSegSocPat := aSegSoc[nX+1][11] - aSegSoc[nX+1][05]
							nSegSocEmp := aSegSoc[nX+1][12] - aSegSoc[nX+1][06]
						Endif
					Endif
				Next		
				If nBaseMes > aSegSoc[Len(aSegSoc)][02]
					If nSemMes == 4
						nSegSocPat := aSegSoc[Len(aSegSoc)][09] - aSegSoc[Len(aSegSoc)][05]
						nSegSocEmp := aSegSoc[Len(aSegSoc)][10] - aSegSoc[Len(aSegSoc)][06]
					ElseIf nSemMes == 5
						nSegSocPat := aSegSoc[Len(aSegSoc)][11] - aSegSoc[Len(aSegSoc)][05]
						nSegSocEmp := aSegSoc[Len(aSegSoc)][12] - aSegSoc[Len(aSegSoc)][06]
					Endif					
				Endif	
			ElseIf SRA->RA_TIPOPGT == "M"						
				If nBaseMes > 0 .And. nBaseMes <= aSegSoc[01][02]  
					If nSemMes == 4
						nSegSocPat := aSegSoc[01][09]
						nSegSocEmp := aSegSoc[01][10]
					ElseIf nSemMes == 5
						nSegSocPat := aSegSoc[01][11]
						nSegSocEmp := aSegSoc[01][12]
					Endif					
				Endif	 
				For nX := 1 to (Len(aSegSoc) -1)                          
					If nBaseMes > aSegSoc[nX][02] .And. nBaseMes <= aSegSoc[nX+1][02]
						If nSemMes == 4
							nSegSocPat := aSegSoc[nX+1][09]
							nSegSocEmp := aSegSoc[nX+1][10]
						ElseIf nSemMes == 5
							nSegSocPat := aSegSoc[nX+1][11]
							nSegSocEmp := aSegSoc[nX+1][12]
						Endif					
					Endif
				Next	    
				If nBaseMes > aSegSoc[Len(aSegSoc)][02]
					If nSemMes == 4
						nSegSocPat := aSegSoc[Len(aSegSoc)][09]
						nSegSocEmp := aSegSoc[Len(aSegSoc)][10]
					ElseIf nSemMes == 5
						nSegSocPat := aSegSoc[Len(aSegSoc)][11]
						nSegSocEmp := aSegSoc[Len(aSegSoc)][12]
					Endif					
				Endif
			Endif		 
			
			If c__Roteiro $'131/132'
				FGeraVerba(aCodFol[019,1],Round(nBaseCalc,MsDecimais(1)))    //Base IDS - 13
				FGeraVerba(aCodFol[070,1],Round(nSegSocEmp,MsDecimais(1)))   //IDS Empregado - 13
				FGeraVerba(aCodFol[197,1],Round(nSegSocPat,MsDecimais(1)))   //IDS Empresa - 13
			Else
				FGeraVerba(aCodFol[221,1],Round(nBaseCalc,MsDecimais(1)))    //Base IDS 
				FGeraVerba(aCodFol[064,1],Round(nSegSocEmp,MsDecimais(1)))  // IDS Empregado
				FGeraVerba(aCodFol[148,1],Round(nSegSocPat,MsDecimais(1)))  // IDS Empresa
			Endif
		Endif	
	Endif 	
Endif	

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOCSALUD ³ Autor ³ Bruno Sobieski        ³ Data ³ 14/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula Salud                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso      ³ Folha CHILE                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LOCSALUD(dDataDem)
Local nBaseCalc	:=	0 //SALMES
Local nSalud	:=	0
Local nAdic		:=	0
Local nAlqDic	:=	0
Local aVerbas
Local nFator	:=	1
Local nIsapBase	:= 0
Local nFixo 	:= 0
Local nBase 	:= 0
Local nAdiExen  := 0
Local nPlanSalud:= 0
Local nOldBas	:= 0
Local nOldDes	:= 0
Local lDemissao	:= If (dDataDem # Nil, .T.,.F.)
Local cDsRlqISA	:= ""
Local nValFunc	:= 0
Local nPlanFunc := 0
Local nValEmp	:= 0
Local nValDif	:= 0
Local nPlaDif	:= 0
Local nTopeSalud := 0

If !Empty(SRA->RA_OBRASOC)

	aVerbas	:=	GetMedic(SRA->RA_OBRASOC)

	fSetRlq( @nBaseCalc, 22 ) // Monta base para calculo

	If Type ( "lReliq" ) # "U" .And. lReliq
		nOldDes		:= Abs( fBuscaAcm( aVerbas[2] , , dDataBase, dDataBase, "V" ) )
		nOldBas		:= nOldDes * 100 / aISAPRE[2]
		nOldDes		+= fBuscaRlq( aVerbas[2] )
		nOldBas		+= fBuscaRlq( aVerbas[2] ) * 100 / aISAPRE[2]
		nBaseCalc	+= nOldBas
	EndIf

	//A base de calculo é o minimo entre o determinado em UFs no parametro 60 e
	//a base calculado no salario
	nDiasEnf  := If(nDiasEnf > 30,30,nDiasEnf)
	nFator    := (30-nDiasEnf) / 30        

	If SRA->RA_SISPENS == "2"
		If nBaseCalc > nValUF*aISAPRE[1]       //Tope em RA_SISPENS Novo
			nBaseCalc := (nValUF*aISAPRE[1] * nFator) 
			nTopeSalud	:= Round((nValUF*aISAPRE[1]) * (aISAPRE[2] / 100 * nFator),MsDecimais(1))
		Endif	
    Else
	    If nBaseCalc > nValUF*aISAPRE[4]       //Tope em RA_SISPENS Antigo
			nBaseCalc := (nValUF*aISAPRE[4] * nFator) 
			nTopeSalud	:= Round((nValUF*aISAPRE[4]) * (aISAPRE[2] / 100 * nFator),MsDecimais(1))
		Endif	
	EndIf	
                     
	
   //valor do funcionario
	nValFunc    := Round(nBaseCalc *(aISAPRE[2] / 100),MsDecimais(1))  
	nValEmp		:= Round(nBaseCalc *(aISAPRE[3] / 100),MsDecimais(1))  
	                                             
	If Diastrab < 1 .And. c__Roteiro == "RES"
		nBaseCalc:=0
		Aeval( aPd ,{ |X| SomaInc(X,22,@nBaseCalc,,,,,,.T.,aCodfol) })
	Else
   		If SRA->RA_ADICISA == '1'		
			If SRA->RA_ISAVAL > 0  .And. SRA->RA_ISAVAL <= 8
				If   SRA->RA_ISATIPO =='1'
					nPlanSalud:=SRA->RA_ISAVAL
				Else
					nPlanSalud:=SRA->RA_ISAVAL * nValUF
				endif     
				
				If MesAno(SRA->RA_ADMISSA)=MesAno(dData_pgto)
					nplansalud	*= diastrab/30
					nFator		:=	(diastrab-nDiasEnf) / diastrab
				Endif
		
				If lDemissao
					nplansalud	*= diastrab/30
					nFator		:= 1
				Endif
				nPlanSalud:=round(nPlansalud*nFator,MsDecimais(1))
			ElseIf SRA->RA_ISAVAL > 8  //Caso seja acima de 7% + 1% Excedente
				If   SRA->RA_ISATIPO =='1'
					nPlanSalud:=SRA->RA_ISAVAL
				Else
					nPlaDif	  := ( ( SRA->RA_ISAVAL - 8) * nValUF )
					nPlanFunc := (  nValUF * 8 )
					nPlanSalud:= nPlaDif + nPlanFunc
				endif     
				
				If MesAno(SRA->RA_ADMISSA)=MesAno(dData_pgto)
					nplansalud	*= diastrab/30
					nFator		:=	(diastrab-nDiasEnf) / diastrab
				Endif
		
				If lDemissao
					nplansalud	*= diastrab/30
					nFator		:= 1
				Endif
				nPlanSalud:=round(nPlansalud*nFator,MsDecimais(1))
			Endif
		EndIf	
	EndIf

	nValDif :=  nPlanSalud - (nValFunc+nValEmp)
	nSalud	:=	max( nValFunc,nPlanSalud)		
					
	If nSalud > 0
	
		If Len(aVerbas) > 0
			nAdiSal  :=nSalud - nValFunc
			
			If Type ( "lReliq" ) # "U" .And. lReliq
				fGeraRlq( aVerbas[2], Round( nValFunc, MsDecimais(1) ) - nOldDes, aISAPRE[2], .T., .T. ) // Gera/soma verba de reliquidacao no aPd
			Else
				FGeraVerba(aVerbas[2],Round(nValFunc ,MsDecimais(1)),aISAPRE[2])  
				//Conc Excedente 471   valor Com Ecedente do valor da empresa.
				If SRA->RA_ISATIPO=='1'
				   	FGeraVerba(aVerbas[3],Round(nPlansalud - nValFunc ,MsDecimais(1)))
				ElseIf SRA->RA_ISATIPO=='2'
					FGeraVerba(aVerbas[3],Round( nAdiSal ,MsDecimais(1)))
				EndIf   	
				// Adic Afecto 470
				If !empty( aVerbas[4] )
					If nPlansalud>nTopeSalud 
						FGeraVerba(aVerbas[4],Round(nTopeSalud - nValFunc,MsDecimais(1)))
					Else
						FGeraVerba(aVerbas[4],Round(nPlansalud - nValFunc,MsDecimais(1)))
					Endif
				EndIf	
				//Adic No Afect 472 
				If !Empty(aVerbas[6])
					FGeraVerba(aVerbas[6],Round( nPlansalud- nTopeSalud,MsDecimais(1)))
    			EndIf
    			
				FGeraVerba(aVerbas[7],Round( nBaseCalc,MsDecimais(1)) )

				FGeraVerba(aVerbas[8],Round( nValEmp,MsDecimais(1)),aISAPRE[3] )
			EndIf
		Endif
	Endif
	
	fCalaPd( 3 ) // Ajuste do aPd das verbas reliquidadas (assume o valor original)
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ APORTEPA ³ Autor ³ MARCOS STIEFANO       ³ Data ³ 19/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula Aporte Patronal                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LOCAPORTEPA()
Local nBaseCalc		:= 0
Local nFator 		:= 1
Local nOldBas		:= 0
Local nOldDes		:= 0

If cPaisLoc == "CHI"
	
	fSetRlq( @nBaseCalc, 14 ) // Monta base para calculo
	nFator  := (30-nDiasEnf) / 30
	
	If Type ( "lReliq" ) # "U" .And. lReliq
		nOldBas		:= Abs( fBuscaAcm( aAporte[5] , , dDataBase, dDataBase, "V" ) )
		nOldBas		+= fBuscaRlq( aAporte[5] )
		nBaseCalc	+= nOldBas
	EndIf
	If SRA->RA_SISPENS =="2"
		If nBaseCalc > nValUF*aAporte[6]
			nBaseCalc := If((nValUF*aAporte[6]*nfator) > 0,(nValUF*aAporte[6]*nfator),(nValUF*aAporte[6]))
		Endif
	Else	
		If nBaseCalc > nValUF*aAporte[7]
			nBaseCalc := If((nValUF*aAporte[7]*nfator) > 0,(nValUF*aAporte[7]*nfator),(nValUF*aAporte[7]))
		Endif
    endif
	If nBaseCalc > 0				
		If Type ( "lReliq" ) # "U" .And. lReliq
			nOldDes	:= Abs( fBuscaAcm( aAporte[5], , dDataBase, dDataBase, "V" ) )
			nOldDes	+= fBuscaRlq( aAporte[5] )
			fGeraRlq( aAporte[5], Round( nBaseCalc, MsDecimais(1) ) - nOldDes, , .T., .T. ) // Gera/soma verba de reliquidacao no aPd
			
			If aAporte[3]==aAporte[4]
				nOldDes	:= Abs( fBuscaAcm( aAporte[3], , dDataBase, dDataBase, "V" ) )
				nOldDes	+= fBuscaRlq( aAporte[3] )
				fGeraRlq( aAporte[3], Round( nBaseCalc * ( aAporte[1] + aAporte[2] ) / 100, MsDecimais(1) ) - nOldDes, aAporte[1] + aAporte[2], .T., .T. ) // Gera/soma verba de reliquidacao no aPd
			Else
				nOldDes	:= Abs( fBuscaAcm( aAporte[3], , dDataBase, dDataBase, "V" ) )
				nOldDes	+= fBuscaRlq( aAporte[3] )
				fGeraRlq( aAporte[3], Round( nBaseCalc * aAporte[1] / 100, MsDecimais(1) ) - nOldDes, aAporte[1], .T., .T. ) // Gera/soma verba de reliquidacao no aPd

				nOldDes	:= Abs( fBuscaAcm( aAporte[4], , dDataBase, dDataBase, "V" ) )
				nOldDes	+= fBuscaRlq( aAporte[4] )
				fGeraRlq( aAporte[4], Round( nBaseCalc * aAporte[2] / 100, MsDecimais(1) ) - nOldDes, aAporte[2], .T., .T. ) // Gera/soma verba de reliquidacao no aPd
			Endif
		Else
			FGeraVerba(aAporte[5],Round(nBaseCalc,MsDecimais(1)),)
			If aAporte[3]==aAporte[4]
				FGeraVerba(aAporte[3],Round(nBaseCalc*(aAporte[1]+aAporte[2])/100,MsDecimais(1)),aAporte[1]+aAporte[2])
			Else
				FGeraVerba(aAporte[3],Round(nBaseCalc*aAporte[1]/100,MsDecimais(1)),aAporte[1])
				FGeraVerba(aAporte[4],Round(nBaseCalc*aAporte[2]/100,MsDecimais(1)),aAporte[2])
			Endif
		EndIf
	Endif
	
	fCalaPd( 3 ) // Ajuste do aPd das verbas reliquidadas (assume o valor original)
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOC_IPS  ³ Autor ³ Mauro                 ³ Data ³ 23.03.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Variaveis com as aliquota de IPS (PARAGUAI)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nAlqPAtr = Aliquota a pagar do empregador                  ³±±
±±³          ³ nAlqFunc = Alicuota do Funcionario                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOC_IPS(nAlqPatr,nAlqFunc,cAnoMes)
If FPHIST82(xFilial("SRX") , "60" , cAnoMes )
	nAlqPatr := Val( SubStr( SRX->RX_TXT ,  1 , 5 ) )
	nAlqFunc := Val( SubStr( SRX->RX_TXT ,  6 , 5 ) )
ElseIf FPHIST82(xFilial("SRX") , "60" , "      " )
	nAlqPatr := Val( SubStr( SRX->RX_TXT ,  1 , 5 ) )
	nAlqFunc := Val( SubStr( SRX->RX_TXT ,  6 , 5 ) )
Else
	If GetRemoteType() == -1
		MsgLogGrid( Ap5GetHelp("GPEXIPS"), .F. ) // Retornar string da funcao Help
	Else
		Help(" ",1,"GPEXIPS")
	EndIf
	Return ( .F. )
EndIf
Return ( .T. )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SETIRLOC ³ Autor ³ Bruno Sobieski        ³ Data ³ 15.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Variaveis com as aliquota de IR  (CHILE)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SETIRLOC()
Local cChaveIR	:=	""
Local nDeduc	:= 0
Local nX		:= 0
Local cTabela
Local cMesRef
Local cSeek
Local nAliqIRPF := 0
Local aTabBPC	:= {}
Local nPRlq		:= 0
Local nVlBPC    := 0

If cPaisLoc == "CHI"

	If GXLocRlq( _IMPUN, , , @nPRlq )
		Return .T.
	EndIf
	
	aIR	:=	Array(11)
	SRX->(DbSetOrder(1))
	If FPHIST82(cFilial, "63" , MesAno(dDataBase)+"1" ) .Or. FPHIST82(cFilial , "63" , "      "+"1" )
		cChaveIR	:=	SRX->RX_TIP
		//TRAMO 1
		//Cada tramo tem a seguinte estrutura
		//aIR[x][1] = Valor do teto
		//aIR[x][2] = Aliquota que dev ser aplicada
		//aIR[x][3] = Deducao
		aIR[01] := {Val( SubStr( SRX->RX_TXT ,  1 , 6 ) ) * nValUTM,0,0}
		
		aIR[02] := {Val( SubStr( SRX->RX_TXT ,  7 , 6 ) ) * nValUTM,Val( SubStr( SRX->RX_TXT ,  13, 6 ) ) /100,0}
		aIR[2][3]	:=	aIR[1][1]*(aIR[2][2]-aIR[1][2]) + aIR[1][3]
		
		aIR[03] := {Val( SubStr( SRX->RX_TXT ,  19, 6 ) ) * nValUTM,Val( SubStr( SRX->RX_TXT ,  25, 6 ) ) /100,0}
		aIR[3][3]	:=	aIR[2][1]*(aIR[3][2]-aIR[2][2]) + aIR[2][3]
		
		aIR[04] := {Val( SubStr( SRX->RX_TXT ,  31, 6 ) ) * nValUTM,Val( SubStr( SRX->RX_TXT ,  37, 6 ) ) /100,0}
		aIR[4][3]	:=	aIR[3][1]*(aIR[4][2]-aIR[3][2]) + aIR[3][3]
		
		aIR[05] := {Val( SubStr( SRX->RX_TXT ,  43, 6 ) ) * nValUTM,Val( SubStr( SRX->RX_TXT ,  49, 6 ) ) /100,0}
		aIR[5][3]	:=	aIR[4][1]*(aIR[5][2]-aIR[4][2]) + aIR[4][3]
		
		dbSelectArea( "SRX" )
		If dbSeek( cFilial + cChaveIR + MesAno(dDataBase) + "2" ) .Or. dbSeek( cFilial + cChaveIR + "      "+ "2" )
			aIR[06] := {Val( SubStr( SRX->RX_TXT ,  1, 6 ) ) * nValUTM,Val( SubStr( SRX->RX_TXT ,  7, 6 ) ) /100,0}
			aIR[6][3]	:=	aIR[5][1]*(aIR[6][2]-aIR[5][2]) + aIR[5][3]
			
			aIR[07] := {Val( SubStr( SRX->RX_TXT ,  13, 6 ) ) * nValUTM,Val( SubStr( SRX->RX_TXT ,  19, 6 ) ) /100,0}
			aIR[07][3]	:=	aIR[6][1]*(aIR[07][2]-aIR[6][2]) + aIR[6][3]
			
			aIR[08] := {Val( SubStr( SRX->RX_TXT ,  25, 6 ) ) * nValUTM,Val( SubStr( SRX->RX_TXT ,  31, 6 ) ) /100,0}
			aIR[08][3]	:=	aIR[7][1]*(aIR[08][2]-aIR[7][2]) + aIR[7][3]
			
			aIR[09] := {Val( SubStr( SRX->RX_TXT ,  37, 6 ) ) * nValUTM,Val( SubStr( SRX->RX_TXT ,  43, 6 ) ) /100,0}
			aIR[09][3]	:=	aIR[8][1]*(aIR[09][2]-aIR[8][2]) + aIR[8][3]
			
			dbSelectArea( "SRX" )
			If dbSeek( cFilial + cChaveIR + MesAno(dDataBase) + "3" ) .Or. dbSeek( cFilial + cChaveIR + "      "+ "3" )
				aIR[10] := {Val( SubStr( SRX->RX_TXT ,  1, 6 ) ) * nValUTM,Val( SubStr( SRX->RX_TXT ,  7, 6 ) ) /100,0}
				aIR[10][3]	:=	aIR[9][1]*(aIR[10][2]-aIR[9][2]) + aIR[9][3]
				
				aIR[11] := {Val( SubStr( SRX->RX_TXT , 13, 6 ) ) * nValUTM,Val( SubStr( SRX->RX_TXT , 19, 6 ) ) /100,0}
				aIR[11][3]	:=	aIR[10][1]*(aIR[11][2]-aIR[10][2]) + aIR[10][3]
				
				nDeduc := (Val( SubStr( SRX->RX_TXT ,  25, 8 ) ) * nValUTM) / 100
			Endif
		EndIf
		For nX:=1	To	Len(aIR)
			aIR[nX][3]	+=	nDeduc
		Next nX
	Else
		If GetRemoteType() == -1
			MsgLogGrid( Ap5GetHelp("GPENTABIR"), .F. ) // Retornar string da funcao Help
		Else
			Help(" ",1,"GPENTABIR")
		EndIf
		Return  .F.
	EndIf
	
	GXLocRlq( _IMPUN, .F., { { 'aIR', aClone(aIR) } }, nPRlq )
ElseIf cPaisLoc == 'URU'
   	fCarrTab( @aTabBPC   , "S003", Nil)
	IF Len(aTabBPC) > 0
		nVlBPC   := Round(fTabela("S003", 1 , 4 ), 2) // Valor do Bpc
	Endif
	
	nAliqIRPF := If(MesAno(dDataBase) < "072007" ,VAL_SALMIN, nVlBPC)
	aIR   := Array(12)
	If (FPHIST82(cFilial, "62" , MesAno(dDataBase)+"1" ) .Or. FPHIST82(cFilial , "62" , "      "+"1" )) .And. nVlBPC > 0
		cChaveIR	:=	SRX->RX_TIP
		//TRAMO 1
		//Cada tramo tem a seguinte estrutura
		//aIR[x][1] = Valor do teto
		//aIR[x][2] = Aliquota que dev ser aplicada
			aIR[01] := {Val( SubStr( SRX->RX_TXT ,  1 , 6 ) ) * nAliqIRPF,0}
			aIR[02] := {Val( SubStr( SRX->RX_TXT ,  7 , 6 ) ) * nAliqIRPF,Val( SubStr( SRX->RX_TXT ,  13, 6 ) ) /100}
			aIR[03] := {Val( SubStr( SRX->RX_TXT ,  19, 6 ) ) * nAliqIRPF,Val( SubStr( SRX->RX_TXT ,  25, 6 ) ) /100}
			aIR[04] := {Val( SubStr( SRX->RX_TXT ,  31, 6 ) ) * nAliqIRPF,Val( SubStr( SRX->RX_TXT ,  37, 6 ) ) /100}
			aIR[05] := {Val( SubStr( SRX->RX_TXT ,  43, 6 ) ) * nAliqIRPF,Val( SubStr( SRX->RX_TXT ,  49, 6 ) ) /100}
			dbSelectArea( "SRX" )
			If dbSeek( cFilial + cChaveIR + MesAno(dDataBase) + "2" ) .Or. dbSeek( cFilial + cChaveIR + "      "+ "2" )
				aIR[06] := {Val( SubStr( SRX->RX_TXT ,  1, 6 ) ) * nAliqIRPF,Val( SubStr( SRX->RX_TXT ,  7, 6 ) ) /100}
				aIR[07] := {Val( SubStr( SRX->RX_TXT ,  13, 6 ) ) * nAliqIRPF,Val( SubStr( SRX->RX_TXT ,  19, 6 ) ) /100}
				aIR[08] := {Val( SubStr( SRX->RX_TXT ,  25, 6 ) ) * nAliqIRPF,Val( SubStr( SRX->RX_TXT ,  31, 6 ) ) /100}
				aIR[09] := {Val( SubStr( SRX->RX_TXT ,  37, 6 ) ) * nAliqIRPF,Val( SubStr( SRX->RX_TXT ,  43, 6 ) ) /100}
				dbSelectArea( "SRX" )
				If dbSeek( cFilial + cChaveIR + MesAno(dDataBase) + "3" ) .Or. dbSeek( cFilial + cChaveIR + "      "+ "3" )
					aIR[10] := {Val( SubStr( SRX->RX_TXT ,  1, 6 ) ) * nAliqIRPF,Val( SubStr( SRX->RX_TXT ,  7, 6 ) ) /100}
					aIR[11] := {Val( SubStr( SRX->RX_TXT , 13, 6 ) ) * nAliqIRPF,Val( SubStr( SRX->RX_TXT , 19, 6 ) ) /100}
					aIR[12] :=  Val( SubStr( SRX->RX_TXT , 25, 6 ) ) / 100
				Endif
			EndIf
	Else
		If GetRemoteType() == -1
			MsgLogGrid( Ap5GetHelp("GPENTABIR"), .F. ) // Retornar string da funcao Help
		Else
			Help(" ",1,"GPENTABIR")
		EndIf
		Return ( .F. )
	EndIf
	
	If MesAno(dDataBase) >= "200707"
		aIRDed   := Array(05)
		If (FPHIST82(cFilial, "83" , MesAno(dDataBase)+"1" ) .Or. FPHIST82(cFilial , "83" , "      "+"1" )) .And. nVlBPC > 0
			//TRAMO 1
			//Cada tramo tem a seguinte estrutura
			//aIR[x][1] = Valor do teto
			//aIR[x][2] = Aliquota que dev ser aplicada
			aIRDed[01] := {Val( SubStr( SRX->RX_TXT ,  1 , 6 ) ) * nAliqIRPF,Val( SubStr( SRX->RX_TXT ,   7, 6 ) ) /100}
			aIRDed[02] := {Val( SubStr( SRX->RX_TXT ,  13, 6 ) ) * nAliqIRPF,Val( SubStr( SRX->RX_TXT ,  19, 6 ) ) /100}
			aIRDed[03] := {Val( SubStr( SRX->RX_TXT ,  25, 6 ) ) * nAliqIRPF,Val( SubStr( SRX->RX_TXT ,  31, 6 ) ) /100}
			aIRDed[04] := {Val( SubStr( SRX->RX_TXT ,  37, 6 ) ) * nAliqIRPF,Val( SubStr( SRX->RX_TXT ,  43, 6 ) ) /100}
			aIRDed[05] := {Val( SubStr( SRX->RX_TXT ,  49, 6 ) ) * nAliqIRPF,Val( SubStr( SRX->RX_TXT ,  55, 6 ) ) /100}
		Else
			Help(" ",1,"GPETABIRDED")
			Return ( .F. )
		EndIf
	Endif
	If FPHIST82(cFilial, "65" , MesAno(dDataBase)+"1" ) .Or. FPHIST82(cFilial , "65" , "      "+"1" )
		aIRAdic	:=	Array(9)
		cChaveIR	:=	SRX->RX_TIP
		//TRAMO 1
		//Cada tramo tem a seguinte estrutura
		//aIR[x][1] = Valor do teto
		//aIR[x][2] = Aliquota que dev ser aplicada
		aIRAdic[01] := {Val( SubStr( SRX->RX_TXT ,  1 , 6 ) ) * VAL_SALMIN,0}
		aIRAdic[02] := {Val( SubStr( SRX->RX_TXT ,  7 , 6 ) ) * VAL_SALMIN,Val( SubStr( SRX->RX_TXT ,  13, 6 ) ) /100}
		aIRAdic[03] := {Val( SubStr( SRX->RX_TXT ,  19, 6 ) ) * VAL_SALMIN,Val( SubStr( SRX->RX_TXT ,  25, 6 ) ) /100}
		aIRAdic[04] := {Val( SubStr( SRX->RX_TXT ,  31, 6 ) ) * VAL_SALMIN,Val( SubStr( SRX->RX_TXT ,  37, 6 ) ) /100}
		aIRAdic[05] := {Val( SubStr( SRX->RX_TXT ,  43, 6 ) ) * VAL_SALMIN,Val( SubStr( SRX->RX_TXT ,  49, 6 ) ) /100}
		dbSelectArea( "SRX" )
		If dbSeek( cFilial + cChaveIR + MesAno(dDataBase) + "2" ) .Or. dbSeek( cFilial + cChaveIR + "      "+ "2" )
			aIRAdic[06] := {Val( SubStr( SRX->RX_TXT ,  1, 6 ) ) * VAL_SALMIN,Val( SubStr( SRX->RX_TXT ,  7, 6 ) ) /100}
			aIRAdic[07] := {Val( SubStr( SRX->RX_TXT ,  13, 6 ) ) * VAL_SALMIN,Val( SubStr( SRX->RX_TXT ,  19, 6 ) ) /100}
			aIRAdic[08] := {Val( SubStr( SRX->RX_TXT ,  25, 6 ) ) * VAL_SALMIN,Val( SubStr( SRX->RX_TXT ,  31, 6 ) ) /100}
			aIRAdic[09] := {Val( SubStr( SRX->RX_TXT ,  37, 6 ) ) * VAL_SALMIN,Val( SubStr( SRX->RX_TXT ,  43, 6 ) ) /100}
		EndIf
	EndIf
	          
	If c__Roteiro == "FOL" .And. Substr(GETMV('MV_FOLMES'),5,2) = '12'	
		If SETIRANUALLOC()
			If Len(aIrAno) == 0 
				cHelp := OemToAnsi( STR0015) //"Tabela de Imposto de Renda Anual (S015) nao cadastrada"
				If GetRemoteType() == -1
					MsgLogGrid( cHelp, .F. ) // Retornar string da funcao Help
				Else
					Help(" ",1,"GPENTABIR" , , cHelp , 1 , 0 )
				EndIf
				Return ( .F. )		
			ElseIf Len(aIrDedAno) == 0
				cHelp := OemToAnsi( STR0016) //"Tabela de Deduções de Imposto de Renda Anual(S016) nao cadastrada"
				If GetRemoteType() == -1
					MsgLogGrid( cHelp, .F. ) // Retornar string da funcao Help
				Else
					Help(" ",1,"GPENTABIR" , , cHelp , 1 , 0 )
				EndIf
				Return ( .F. )		
			Endif    
		Else           
			If GetRemoteType() == -1
				MsgLogGrid( Ap5GetHelp("GPEXBPC"), .F. ) // Retornar string da funcao Help
			Else
				Help(" ",1,"GPEXBPC")
			EndIf		
			Return ( .F. )
		Endif
	Endif
ElseIf cPaisLoc == "ARG"
	If c__Roteiro == "RES"
		dData_Pgto	:= If(!Empty(dDataDem),dDataDem,dDataDem1)
	ElseIf c__Roteiro == "FER"
		dData_Pgto	:= dDataBase
	Endif               
	If Empty(dData_Pgto) 
		dData_Pgto	:= dDataBase
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona Variaveis para Leitura da Tabela de Ganancias (SFD)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTabela := StrZero(Month(dData_Pgto),6)
	cMesRef := StrZero(Month(dData_Pgto),2)+GetAno2(dData_Pgto)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega Valores da Tabela de Ganancias (SFD) no Array          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SFD")
	cSeek := ( xFilial("SFD") + cTabela + cMesRef )
	dbSeek( cSeek )
	aIR	:=	{}
	While !Eof() .And. SFD->FD_FILIAL + SFD->FD_NUM + SFD->FD_MESREF == cSeek
			Aadd( aIR, { FD_ITEM,;          			//Item
							  FD_FXDE,;         			//A partir da faixa $
							  FD_FXATE,;        			//Faixa Ate $
							  FD_RETENC,;       			//Valor Retencao
							  FD_PERC,;         			//% Retencao
							  FD_EXCEDE,;       			//Excedente 
							  FD_IMPORTE,;      			//Valor Sujeito Imp.
				   		  FD_CARGA,;        			//Salario Familia Conjuge
				   		  FD_CARGA1,;       			//Salario Familia Filhos
				   		  FD_CARGA2,;       			//Salario Familia Outros
				   		  FD_DEDESP1,;          	//Deducoes Especiais 1
				   		  FD_DEDESP2,;          	//Deducoes Especiais 2
				   		  FD_PRIMSEG,;          	//Primas de Seguros
				   		  FD_GASTSEP,;          	//Gastos de Sepelio
				   		  FD_PSOBSFA,;          	//%Deducao Familia
				   		  FD_ANEXODE,;          	//Anexo Desde
				   		  FD_ANEXOAT,;          	//Anexo Ate
				   		  FD_SEGRET,;           	//Seguro de Retiro
				   		  FD_CREDHIP,;          	//Credito Hipotecario
				   		  FD_PDEDDOA,;          	//% Deducao Doacoes
				   		  FD_PDEDSAL,;          	//% Deducao Saude
				   		  FD_PDEDHON,;          	//% Deducao Honorarios Medicos
				   		  FD_EMPRDOM } )        	// Pagamento Empregadas Domesticas
		dbSkip()
	EndDo
	If Len(aIR) == 0
		cHelp := OemToAnsi( STR0010) //"Tabela de Imposto de Renda(SFD) nao cadastrada"
		If GetRemoteType() == -1
			MsgLogGrid( cHelp, .F. ) // Retornar string da funcao Help
		Else
			Help(" ",1,"GPENTABIR" , , cHelp , 1 , 0 )
		EndIf
		Return ( .F. )
	Endif
ElseIf cPaisLoc == "DOM"
	aIR   := Array(10)
	If FPHIST82(cFilial, "60" , MesAno(dDataBase)+ "1") .Or. FPHIST82(cFilial , "60" , "      "+"1")
		cChaveIR	:=	SRX->RX_TIP
		aIR[1]	:= Val( SubStr( SRX->RX_TXT ,  1 , 12 ) )		//Isento
		aIR[2]	:= Val( SubStr( SRX->RX_TXT ,  13, 12 ) )    //Rendimento 1
		aIR[3]	:= Val( SubStr( SRX->RX_TXT ,  25, 10 ) )    //Valor desconto fixo
		aIR[4]	:= Val( SubStr( SRX->RX_TXT ,  35, 06 ) )    // % sobre o excedente
		aIR[5]	:= Val( SubStr( SRX->RX_TXT ,  41, 12 ) )    //Rendimento 2
		dbSelectArea( "SRX" )
		If dbSeek( cFilial + cChaveIR + MesAno(dDataBase) + "2" ) .Or. dbSeek( cFilial + cChaveIR + "      "+ "2" )
			aIR[6]	:= Val( SubStr( SRX->RX_TXT ,  1 , 10 ) ) //Valor desconto fixo 2
			aIR[7]	:= Val( SubStr( SRX->RX_TXT ,  11, 06 ) ) // % sobre o excedente 2
			aIR[8]	:= Val( SubStr( SRX->RX_TXT ,  17, 12 ) ) //Rendimento 3
			aIR[9]	:= Val( SubStr( SRX->RX_TXT ,  29, 10 ) ) //valor desconto fixo 3
			aIR[10]	:= Val( SubStr( SRX->RX_TXT ,  39, 06 ) ) // % sobre o excedente 3
		Endif
	Else
		If GetRemoteType() == -1
			MsgLogGrid( Ap5GetHelp("GPETABIRDO"), .F. ) // Retornar string da funcao Help
		Else
			Help(" ",1,"GPETABIRDO")
		EndIf
		Return ( .F. )
	EndIf
Endif

Return  .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SETSALFAM ³ Autor ³ Bruno Sobieski        ³ Data ³ 14.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega parametros de salario familiar   (CHILE)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SetSalFam(aSalFam)

Local cAnoMes	:=	MesAno(dDataBAse)
Local nPRlq		:= 0

If cPaisLoc == "CHI"
	If GXLocRlq( _SLFAM, , , @nPRlq )
		Return .T.
	EndIf

	aSalFam	:=Array(7)
	If FPHIST82(xFilial("SRX") , "10" , cAnoMes )
		aSalFam[1]	:= Val( SubStr( SRX->RX_TXT ,  1 , 10 ) )
		aSalFam[2]	:= Val( SubStr( SRX->RX_TXT ,  11, 09 ) )
		aSalFam[3]	:= Val( SubStr( SRX->RX_TXT ,  20, 10 ) )
		aSalFam[4]	:= Val( SubStr( SRX->RX_TXT ,  30, 09 ) )
		aSalFam[5]	:= Val( SubStr( SRX->RX_TXT ,  39, 10 ) )
		aSalFam[6]	:= Val( SubStr( SRX->RX_TXT ,  49, 09 ) )
		aSalFam[7]	:= Val( SubStr( SRX->RX_TXT ,  58,  2 ) )
	ElseIf FPHIST82(xFilial("SRX") , "10" , "      " )
		aSalFam[1]	:= Val( SubStr( SRX->RX_TXT ,  1 , 10 ) )
		aSalFam[2]	:= Val( SubStr( SRX->RX_TXT ,  11, 09 ) )
		aSalFam[3]	:= Val( SubStr( SRX->RX_TXT ,  20, 10 ) )
		aSalFam[4]	:= Val( SubStr( SRX->RX_TXT ,  30, 09 ) )
		aSalFam[5]	:= Val( SubStr( SRX->RX_TXT ,  39, 10 ) )
		aSalFam[6]	:= Val( SubStr( SRX->RX_TXT ,  49, 09 ) )
		aSalFam[7]	:= Val( SubStr( SRX->RX_TXT ,  58,  2 ) )
	Else
		If GetRemoteType() == -1
			MsgLogGrid( Ap5GetHelp("GPEXSFAM"), .F. ) // Retornar string da funcao Help
		Else
			Help(" ",1,"GPEXSFAM")
		EndIf
		Return ( .F. )
	EndIf
	
	GXLocRlq( _SLFAM, .F., { { 'aSalFam', aClone(aSalFam) } }, nPRlq )
ElseIf cPaisLoc == 'URU'
	aSalFam	:=Array(9)
	If FPHIST82(xFilial("SRX") , "10" , cAnoMes )
		aSalFam[1]	:= Val( SubStr( SRX->RX_TXT ,  1 , 11 ) )
		aSalFam[2]  := Val( SubStr( SRX->RX_TXT , 12 , 10 ) )
		aSalFam[3]	:= Val( SubStr( SRX->RX_TXT , 22 , 02 ) )
		aSalFam[4]	:= Val( SubStr( SRX->RX_TXT , 24 , 07 ) )
		aSalFam[5]  := Val( SubStr( SRX->RX_TXT , 31 , 02 ) )
		aSalFam[6]	:= Val( SubStr( SRX->RX_TXT , 33 , 07 ) )
		aSalFam[7]	:= Val( SubStr( SRX->RX_TXT , 40 , 02 ) )
		aSalFam[8]	:= Val( SubStr( SRX->RX_TXT , 42 , 07 ) )
		aSalFam[9]	:= Val( SubStr( SRX->RX_TXT , 49 , 02 ) )
	ElseIf FPHIST82(xFilial("SRX") , "10" , "      " )
		aSalFam[1]	:= Val( SubStr( SRX->RX_TXT ,  1 , 11 ) )
		aSalFam[2]  := Val( SubStr( SRX->RX_TXT , 12 , 10 ) )
		aSalFam[3]  := Val( SubStr( SRX->RX_TXT , 22 , 02 ) )
		aSalFam[4]	:= Val( SubStr( SRX->RX_TXT , 24 , 07 ) )
		aSalFam[5]  := Val( SubStr( SRX->RX_TXT , 31 , 02 ) )
		aSalFam[6]	:= Val( SubStr( SRX->RX_TXT , 33 , 07 ) )
		aSalFam[7]  := Val( SubStr( SRX->RX_TXT , 40 , 02 ) )
		aSalFam[8]	:= Val( SubStr( SRX->RX_TXT , 42 , 07 ) )
		aSalFam[9]	:= Val( SubStr( SRX->RX_TXT , 49 , 02 ) )
	Else
		If GetRemoteType() == -1
			MsgLogGrid( Ap5GetHelp("GPEXSFAM"), .F. ) // Retornar string da funcao Help
		Else
			Help(" ",1,"GPEXSFAM")
		EndIf
		Return ( .F. )
	EndIf
Endif
Return ( .T. )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SetAportePa Autor ³ Bruno Sobieski        ³ Data ³ 14.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega parametros do Aporte Patronal    (CHILE)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SetAportePa(aAporte)
Local cAnoMes	:=	MesAno(dDataBAse)
Local nPRlq		:= 0

If GXLocRlq( _APOPA, , , @nPRlq )
	Return .T.
EndIf

If FPHIST82(xFilial("SRX") , "65" , cAnoMes+cFilAnt ).Or. FPHIST82(xFilial("SRX") , "65" , "      "+cFilAnt )
	aAporte	:=Array(7)
	aAporte[1]	:= Val( SubStr( SRX->RX_TXT ,  1 , 06 ) )
	aAporte[2]	:= Val( SubStr( SRX->RX_TXT ,  7 , 06 ) )
	aAporte[3]	:= SubStr( SRX->RX_TXT ,  13 , 03 )
	aAporte[4]	:= SubStr( SRX->RX_TXT ,  16 , 03 )
	aAporte[5]	:= SubStr( SRX->RX_TXT ,  19 , 03 )
	aAporte[6]	:= Val(SubStr( SRX->RX_TXT ,  22 , 05 ) )
	aAporte[7]	:= Val(SubStr( SRX->RX_TXT ,  27 , 06 ) )
Else
	If GetRemoteType() == -1
		MsgLogGrid( Ap5GetHelp("GPEXAPO"), .F. ) // Retornar string da funcao Help
	Else
		Help(" ",1,"GPEXAPO")
	EndIf
	Return ( .F. )
EndIf

GXLocRlq( _APOPA, .F., { { 'aAporte', aClone(aAporte) } }, nPRlq )

Return ( .T. )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SETISAPRE³ Autor ³ Mauro                 ³ Data ³ 23.03.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Tabela de Isapre                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aIsapre  = Limite,Aliquota do Isapre e Adicional           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SetISAPRE(aISAPRE)

aISAPRE	:=	Array(4)
If FPHIST82( xFilial("SRX") , "60" , MesAno(dDatabase))
	aISAPRE[1] := Val( SubStr ( SRX->RX_TXT ,  1 , 15 ) )
	aISAPRE[2] := Val( SubStr ( SRX->RX_TXT ,  16, 06 ) )
	aISAPRE[3] := Val( SubStr ( SRX->RX_TXT ,  22, 06 ) )
	aISAPRE[4] := Val( SubStr ( SRX->RX_TXT ,  29, 06 ) )
ElseIf FPHIST82( xFilial("SRX") , "60" , "      " )
	aISAPRE[1] := Val( SubStr ( SRX->RX_TXT ,  1 , 15 ) )
	aISAPRE[2] := Val( SubStr ( SRX->RX_TXT ,  16, 06 ) )
	aISAPRE[3] := Val( SubStr ( SRX->RX_TXT ,  22, 06 ) )
	aISAPRE[4] := Val( SubStr ( SRX->RX_TXT ,  29, 06 ) )
Else
	If GetRemoteType() == -1
		MsgLogGrid( Ap5GetHelp("GPEXISA"), .F. ) // Retornar string da funcao Help
	Else
		Help(" ",1,"GPEXISA")
	EndIf
	Return ( .F. )
Endif

Return ( .T. )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOC_BPS  ³ Autor ³ Silvia Taguti         ³ Data ³ 23.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Variaveis com as aliquota de BPS (URUGUAI)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nAlqPAtr = Aliquota a pagar do empregador                  ³±±
±±³          ³ nAlqFunc = Alicuota do Funcionario                         ³±±
±±³          ³ nTopCot  = Top de Cotizacion                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOC_BPS(nAlqPatr,nAlqFunc,nAlqConsC,nTopCot,cAnoMes)
If FPHIST82(xFilial("SRX") , "60" , cAnoMes )
	nAlqPatr := Val( SubStr( SRX->RX_TXT ,  1 , 5 ) )
	nAlqFunc := Val( SubStr( SRX->RX_TXT ,  6 , 5 ) )
	nAlqConsC:= Val( SubStr( SRX->RX_TXT , 11 , 5 ) )
	nTopCot  := Val( SubStr( SRX->RX_TXT , 16 , 10 ) )
ElseIf FPHIST82(xFilial("SRX") , "60" , "      " )
	nAlqPatr := Val( SubStr( SRX->RX_TXT ,  1 , 5 ) )
	nAlqFunc := Val( SubStr( SRX->RX_TXT ,  6 , 5 ) )
	nAlqConsC:= Val( SubStr( SRX->RX_TXT , 11 , 5 ) )
	nTopCot  := Val( SubStr( SRX->RX_TXT , 16 , 10 ) )
Else
	If GetRemoteType() == -1
		MsgLogGrid( Ap5GetHelp("GPEXBPS"), .F. ) // Retornar string da funcao Help
	Else
		Help(" ",1,"GPEXBPS")
	EndIf
	Return ( .F. )
EndIf
Return ( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOC_IRP  ³ Autor ³ Silvia Taguti         ³ Data ³ 26.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Variaveis com as aliquota de IRP (URUGUAI)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nAlqPAtr = Aliquota a pagar do empregador                  ³±±
±±³          ³ nAlqFunc = Alicuota do Funcionario                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOC_IRP(aAliqIRP,cAnoMes)

If FPHIST82(xFilial("SRX") , "62" , cAnoMes )
	Aadd(aAliqIRP,{ SubStr(SRX->RX_TXT,1,3),SubStr(SRX->RX_TXT,4,3),SubStr(SRX->RX_TXT,7,3),SubStr(SRX->RX_TXT,10,3)})
	Aadd(aAliqIRP,{ SubStr(SRX->RX_TXT,13,3),SubStr(SRX->RX_TXT,16,3),SubStr(SRX->RX_TXT,19,3),SubStr(SRX->RX_TXT,22,3)})
	Aadd(aAliqIRP,{ SubStr(SRX->RX_TXT,25,3),SubStr(SRX->RX_TXT,28,3),SubStr(SRX->RX_TXT,31,3),SubStr(SRX->RX_TXT,34,3)})
ElseIf FPHIST82(xFilial("SRX") , "62" , "      " )
	Aadd(aAliqIRP,{ SubStr(SRX->RX_TXT,1,3),SubStr(SRX->RX_TXT,4,3),SubStr(SRX->RX_TXT,7,3),SubStr(SRX->RX_TXT,10,3)})
	Aadd(aAliqIRP,{ SubStr(SRX->RX_TXT,13,3),SubStr(SRX->RX_TXT,16,3),SubStr(SRX->RX_TXT,19,3),SubStr(SRX->RX_TXT,22,3)})
	Aadd(aAliqIRP,{ SubStr(SRX->RX_TXT,25,3),SubStr(SRX->RX_TXT,28,3),SubStr(SRX->RX_TXT,31,3),SubStr(SRX->RX_TXT,34,3)})
Else
	If GetRemoteType() == -1
		MsgLogGrid( Ap5GetHelp("GPEXIRL"), .F. ) // Retornar string da funcao Help
	Else
		Help(" ",1,"GPEXIRL")
	EndIf
	Return ( .F. )
EndIf

Return ( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOC_FRL  ³ Autor ³ Silvia Taguti         ³ Data ³ 28.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Variaveis com as aliquota de FRL (URUGUAI)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nAlqPAtr = Aliquota a pagar do empregador                  ³±±
±±³          ³ nAlqFunc = Alicuota do Funcionario                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOC_FRL(nAlqPatr,nAlqFunc,cAnoMes)
If FPHIST82(xFilial("SRX") , "63" , cAnoMes )
	nAlqPatr := Val( SubStr( SRX->RX_TXT ,  1 , 5 ) )
	nAlqFunc := Val( SubStr( SRX->RX_TXT ,  6 , 5 ) )
ElseIf FPHIST82(xFilial("SRX") , "63" , "      " )
	nAlqPatr := Val( SubStr( SRX->RX_TXT ,  1 , 5 ) )
	nAlqFunc := Val( SubStr( SRX->RX_TXT ,  6 , 5 ) )
Else
	If GetRemoteType() == -1
		MsgLogGrid( Ap5GetHelp("GPEXFRL"), .F. ) // Retornar string da funcao Help
	Else
		Help(" ",1,"GPEXFRL")
	EndIf
	Return ( .F. )
EndIf
Return ( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOC_DISSE³ Autor ³ Silvia Taguti         ³ Data ³ 28.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Variaveis com as aliquota de DISSE(URUGUAI)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nAlqPAtr = Aliquota a pagar do empregador                  ³±±
±±³          ³ nAlqFunc = Alicuota do Funcionario                         ³±±
±±³          ³ nVlrCota = Valor da Cota Mutual                            ³±±
±±³          ³ nAlqDep  = Alicuota do Dependente                          ³±±
±±³          ³ nAlqSM   = Alicuota ate 2.5 Salarios Minimos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ BOPS ³  Motivo da Alteracao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tiago Malta ³ 24/06/10 ³      ³ Alteração do nome da função Loc_disse. ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOC_FONASA(nVlrCota,nAlqPatr,nAlqFunc,cAnoMes,cCCCuota,nAlqDep,nAlqSM,nAlqSDep)
If FPHIST82(xFilial("SRX") , "64" , cAnoMes )
	nVlrCota := Val( Substr( SRX->RX_TXT ,  1 , 7 ) )
	nAlqPatr := Val( SubStr( SRX->RX_TXT ,  8 , 5 ) )
	nAlqFunc := Val( SubStr( SRX->RX_TXT , 13 , 5 ) )
	cCCCuota :=      Substr( SRX->RX_TXT , 18 , 9 )  
    nAlqDep	 := Val( SubStr( SRX->RX_TXT , 27 , 5 ) )
    nAlqSM	 := Val( SubStr( SRX->RX_TXT , 32 , 5 ) )
    nAlqSDep := Val( SubStr( SRX->RX_TXT , 37 , 5 ) )
ElseIf FPHIST82(xFilial("SRX") , "64" , "      " )
	nVlrCota := Val( Substr( SRX->RX_TXT ,  1 , 7 ) )
	nAlqPatr := Val( SubStr( SRX->RX_TXT ,  8 , 5 ) )
	nAlqFunc := Val( SubStr( SRX->RX_TXT , 13 , 5 ) )
	cCCCuota :=      Substr( SRX->RX_TXT , 18 , 9 )
    nAlqDep	 := Val( SubStr( SRX->RX_TXT , 27 , 5 ) )
    nAlqSM	 := Val( SubStr( SRX->RX_TXT , 32 , 5 ) )
    nAlqSDep := Val( SubStr( SRX->RX_TXT , 37 , 5 ) )	
Else
	If GetRemoteType() == -1
		MsgLogGrid( Ap5GetHelp("GPEXDISSE"), .F. ) // Retornar string da funcao Help
	Else
		Help(" ",1,"GPEXDISSE")
	EndIf
	Return ( .F. )
EndIf
Return ( .T. )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LOCFIMFER³ Autor ³ Bruno Sobieski        ³ Data ³ 24.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula a data de finalizacao das ferias contando os dias  ³±±
±±³          ³ uteis a partir de uma data (tira os domingos), ou os dias  ³±±
±±³          ³ uteis ate o final do mes ou do comeco ate a data informada ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dReferen = Data de referencia                              ³±±
±±³          ³ nDias    = Dias totais                                     ³±±
±±³          ³ cTipo    = "1" - Calcula a data  de finalizacao            ³±±
±±³          ³            "2" - Calcula os dias uteis ate o final do mes  ³±±
±±³          ³            "3" - Calcula os dias uteis do comeco do mes ate³±±
±±³          ³                  dReferencia                               ³±±
±±³          ³ lDomingo = Indica se deve considerar os Domingos como dias ³±±
±±³          ³              nao uteis                                     ³±±
±±³          ³ lFeriados= Indica se deve considerar os feriados como dias ³±±
±±³          ³              nao uteis                                     ³±±
±±³          ³ lSabado  = Indica se deve considerar os Sabado   como dias ³±±
±±³          ³              nao uteis                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOCFimFer(dReferen,nDias,cTipo,lDomingo,lFeriados,lSabado)
Local bWhile
Local bDo
Local bRet
Local aFeriados	:=	RetFeriados()

nDias	:=	If(nDias==Nil,0,nDias)
cTipo	:=	If(cTipo==Nil,"1",cTipo)
lDomingo	:=	If(lDomingo ==Nil,.T.,lDomingo)
lFeriados:=	If(lFeriados==Nil,.T.,lFeriados)
lSabado:=	If(lSabado==Nil,.T.,lSabado)

If cTipo == "1"
	bWhile 	:=	{|| nDias > 0 }
	bDo	 	:=	{|| nDias--   }
	bRet		:=	{|| dReferen  }
ElseIf cTipo == "2"
	bWhile 	:=	{|| Month(dReferen)== Month(dDataBase)}
	bDo	 	:=	{|| nDias++   }
	bRet		:=	{|| nDias     }
Else
	dFim		:=	dReferen
	dReferen :=	Ctod("01/"+SubStr(DTOC(dReferen),4))
	bWhile :=	{|| dReferen  <= dFim }
	bDo	 :=	{|| nDias++   }
	bRet		:=	{|| nDias     }
Endif

While Eval(bWhile)
	//Se nao for feriado e nao for domingo...
	If ((!lFeriados .Or. Ascan(aFeriados,DTOS(dReferen)) == 0) .And. (!lDomingo.Or. Dow(dReferen) <> 1) .And.;
		(!lSabado .Or. Dow(dReferen) <> 7) )
		Eval(bDo)
	Endif
	dReferen++
Enddo

Return Eval(bRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LOChecData³ Autor ³ Bruno Sobieski        ³ Data ³ 24.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a data digitada eh uma segunda feira ou proximo³±±
±±³          ³ dia util no caso de ser feriado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dInicial = Data Inicial                                    ³±±
±±³          ³ nDias    = Dias totais                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocChecData(dInicial)
Local lRet		:=	.F.
Local aFeriados	:=	RetFeriados()

Do Case
	CASE Dow(dInicial) == 2
		lRet	:=	.T.
	CASE Dow(dInicial) == 3 .And.  Ascan(aFeriados,DTOS(dInicial-1)) > 0
		lRet	:=	.T.
	CASE Dow(dInicial) == 4 .And.  Ascan(aFeriados,DTOS(dInicial-2)) > 0
		lRet	:=	.T.
	CASE Dow(dInicial) == 5 .And.  Ascan(aFeriados,DTOS(dInicial-3)) > 0
		lRet	:=	.T.
	CASE Dow(dInicial) == 6 .And.  Ascan(aFeriados,DTOS(dInicial-4)) > 0
		lRet	:=	.T.
	CASE Dow(dInicial) == 7 .And.  Ascan(aFeriados,DTOS(dInicial-5)) > 0
		lRet	:=	.T.
EndCase

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocGHabReaºAutor  ³Bruno Sobieski      ºFecha ³  10/30/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula os dias uteis emtre dois datas                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ dInicial = Data Inicial                                    ³±±
±±³          ³ dFinal   = Data Final                                      ³±±
±±º          ³ nHabiles = Dias habiles(pasar por referencia)              º±±
±±º          ³ nReales  = Dias reales (pasar por referencia)              º±±
±±º          ³ lDif 		= Retorna a diferenca entre os dias hab e reais.  º±±
±±³          ³ lSabado  = Indica se deve considerar os Sabado   como dias ³±±
±±³          ³              nao uteis                                     ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocGHabRea(dInicial,dFinal,nHabiles,nReales,lDif,nHoras,lSabado)
Local nRet		:=	0
Local aFeriados	:=	RetFeriados()

nHabiles	:=	0
nReales	:=	0
nHoras  := 0
DEFAULT lDif	:=	.F.
lSabado:=If(lSabado==Nil,.F.,lSabado)

While dInicial <= dFinal
	If DOW(dInicial) <> 1 .And.  Ascan(aFeriados,DTOS(dInicial)) == 0 .And. ;
		If(cPaisLoc == "DOM", Dow(dInicial) <> 7, .T.) .And. If(lSabado, Dow(dInicial) <> 7, .T. )
		nHabiles++
		If Dow(dInicial) <> 7
			nHoras := nHoras + 8
		Else
			nHoras := nHoras + 5
		Endif
	Endif
	nReales++
	dInicial++
Enddo
If lDif
	nRet	:=	nReales - nHabiles
Endif
If cPaisLoc <> "CHI"
	nReales	:=	If(nReales <= 30,nReales,30)
Endif	

Return	nRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCSETNIL()ºAutor ³Bruno Sobieski Chavez Data ³  02/14/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Setea em Nil as variaveis usadas no calculo de folha.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM020                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOCSetNil()
aSalFam	:=	Nil
aISAPRE	:=	Nil
nValUF	:=	Nil
aIR		:=	Nil
nValUTM	:=	Nil
aAporte	:=	Nil
aMedic	:=	Nil
aIRADic	:=	Nil
aFerPag	:=	Nil
nMOPRE	:=	Nil
aSindic	:=	Nil
aSegCesa	:=	Nil
aApolices:=	Nil
aDadosBSE:=	Nil
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCGPEVal()ºAutor ³Bruno Sobieski Chavez Data ³  25/02/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para pegar os valores das variaveis static do GPE    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM020                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOCGPEVal(cVar)
Local xRet	:=	Nil

If !Empty(cVar)
	xRet	:=	&(cVar)
Endif
Return xRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SETVALUNS  ºAutor ³Bruno Sobieski Chavez Data ³  02/14/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Setea o valor do UF e do UTM                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM020                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SetValUNS(nValUF,nValUtm,dDataRef)

Local nPRlq			:= 0

DEFAULT dDataRef	:=	dDataBase

If GXLocRlq( _UTMUF, , , @nPRlq )
	Return .T.
EndIf

If FPHIST82(xFilial("SRX") , "64" , MesAno(dDataRef))
	nValUtm 	:= Val( SubStr( SRX->RX_TXT ,   1 , 18 ) )
	nValUF 	:= Val( SubStr( SRX->RX_TXT ,  19 , 18 ) )
ElseIf FPHIST82(xFilial("SRX") , "64" , "      ")
	nValUtm 	:= Val( SubStr( SRX->RX_TXT ,  1 , 18 ) )
	nValUF 	:= Val( SubStr( SRX->RX_TXT ,  19 , 18 ) )
Else
	nValUTM := 0
	If GetRemoteType() == -1
		MsgLogGrid( Ap5GetHelp("GPEXUNS"), .F. ) // Retornar string da funcao Help
	Else
		Help(" ",1,"GPEXUNS")
	EndIf
	Return ( .F. )
Endif

GXLocRlq( _UTMUF, .F., { { 'nValUtm', nValUtm }, { 'nValUF', nValUF } }, nPRlq )

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SETVALSEG  ºAutor ³Bruno Sobieski Chavez Data ³  23/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Setea o valor do array de seguro de cesantia                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CHILE                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SetValSeg(dData)

Local nPRlq		:= 0

DEFAULT dData	:=	dDataBase

If GXLocRlq( _SGCES, , , @nPRlq )
	Return
EndIf

If aSegCesa ==	Nil
	If cPaisLoc == "CHI"
		aSegCesa	:=	{0,'',0,'',0,'',0,0,''}
	Else
		aSegCesa	:=	{0,'',0,'',0,'',0}
	EndIf
	If FPHIST82(xFilial("SRX") , "69" , MesAno(dDataBase)) .Or. FPHIST82(xFilial("SRX") , "69" , "      ")
		aSegCesa[1] := Val( SubStr( SRX->RX_TXT ,   1 , 4 ) ) //Alicuota empresa
		aSegCesa[2] := SubStr( SRX->RX_TXT ,   5 , 3 )        //Concepto empresa
		aSegCesa[3] := Val( SubStr( SRX->RX_TXT ,   8 , 4 ) ) //Alicuota afiliado
		aSegCesa[4] := SubStr( SRX->RX_TXT ,   12 , 3 )       //Concepto afiliado
		aSegCesa[5] := Val( SubStr( SRX->RX_TXT ,   15 , 4 ) )//Alicuota integral
		aSegCesa[6] := SubStr( SRX->RX_TXT ,   19 , 3 )       //Concepto base
		aSegCesa[7] := Val( SubStr( SRX->RX_TXT ,   22 , 5 ) )//Limite en UF para base
		If cPaisLoc == "CHI"
			aSegCesa[8] := Val( SubStr( SRX->RX_TXT ,   27 , 4 ) ) //Alicuota Indemnizacion opcional
			aSegCesa[9] := SubStr( SRX->RX_TXT ,   31 , 3 )        //Concepto del indemnizacion
		EndIf
	Else
		If GetRemoteType() == -1
			MsgLogGrid( Ap5GetHelp("GPEXCES"), .F. ) // Retornar string da funcao Help
		Else
			Help(" ",1,"GPEXCES")
		EndIf
		Return ( .F. )
	Endif
Endif

GXLocRlq( _SGCES, .F., { { 'aSegCesa', aClone(aSegCesa) } }, nPRlq )

Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GETISAPRE  ºAutor ³Bruno Sobieski Chavez Data ³  02/14/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega os parametros de cada instituicao de saude.         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM020                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetMedic(cMedic)
Local nPos	:=	0
Local aRet	:=	{'','','','','',''}

If aMedic == Nil .Or. (nPos	:=	Ascan(aMedic,{|x| x[1] == cMedic})) == 0
	aMedic	:=	If(aMedic == Nil,{},aMedic)
	If FPHIST82(xFilial("SRX") , "66" , cMedic)
		AAdd(aMedic,{SubStr( SRX->RX_COD ,  01 , 03 ),;
		SubStr( SRX->RX_TXT ,  26 , 03 ),;
		SubStr( SRX->RX_TXT ,  29 , 03 ),;
		SubStr( SRX->RX_TXT ,  39 , 03 ),;
		SubStr( SRX->RX_TXT ,  35 , 01 ),;
		SubStr( SRX->RX_TXT ,  42 , 03 ),;
		SubStr( SRX->RX_TXT ,  36 , 03 ),;
		SubStr( SRX->RX_TXT ,  56 , 03 )})
	Endif
	If Len(aMedic) > 0
		aRet	:=	aClone(aMedic[Len(aMedic)])
	Endif
Else
	aRet	:=	aClone(aMedic[nPos])
Endif

Return aClone(aRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocGPEPar  ºAutor ³Bruno Sobieski Chavez Data ³  02/21/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida as verbas digitadas nos parametros que definen verbasº±±
±±º          ³para gerar.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA150                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocGpePar(cPar,cConteudo,cTipo)
Local lRet		:=	.T.
Local cTabela	:=	""

DEFAULT cConteudo	:=	&(ReadVar())
DEFAULT cTipo		:=	""
If lRet
	SRV->(DbSetOrder(1))
	SRV->(DbSeek(xFilial()+cConteudo))
	If (!Empty(cTipo) .And. SRV->RV_TIPOCOD <> cTipo)
		lRet	:=	.F.
		cTabela :="1"
	ElseIf !Empty(SRV->RV_CODFOL)
		lRet	:=	.F.
		cTabela :="2"
	Endif
Endif
If cPaisLoc == "CHI"
	If cPar	<>	'X62' .And. lRet
		SRX->(dbsetorder(1))
		If FPHIST82( xFilial("SRX") , "62" )
			SRX->(dbsetorder(1))
			While SRX->RX_TIP == "62" .And. lRet
				If cConteudo == SubStr ( SRX->RX_TXT ,  32 , 3 ) .Or.;
					cConteudo == SubStr ( SRX->RX_TXT ,  35 , 3 ).Or.;
					cConteudo == SubStr ( SRX->RX_TXT ,  38 , 3 ) .Or.;
					cConteudo == SubStr ( SRX->RX_TXT ,  41 , 3 ) .Or.;
					cConteudo == SubStr ( SRX->RX_TXT ,  44 , 3 )
					lRet	:=	.F.
					SR5->(DbSeek(RhTamFilial(xFilial("SR5"))+'X62' ))
					cTabela :=	SR5->R5_DESCRIC
				Endif
				SRX->(DbSkip())
			Enddo
		Endif
	Endif
	If cPar	<>	'X66' .And. lRet
		SRX->(dbsetorder(1))
		If FPHIST82( xFilial("SRX") , "66" )
			SRX->(dbsetorder(1))
			While SRX->RX_TIP == "66" .And. lRet
				If cConteudo == SubStr ( SRX->RX_TXT ,  26 , 3 ) .Or.;
					cConteudo == SubStr ( SRX->RX_TXT ,  29 , 3 ).Or.;
					cConteudo == SubStr ( SRX->RX_TXT ,  32 , 3 )
					lRet	:=	.F.
					SR5->(DbSeek(RhTamFilial(xFilial("SR5"))+'X66' ))
					cTabela :=	SR5->R5_DESCRIC
				Endif
				SRX->(DbSkip())
			Enddo
		Endif
	Endif
	
	If cPar <> "X65" .And. lRet
		SRX->(dbsetorder(1))
		If FPHIST82( xFilial("SRX") , "65" )
			SRX->(dbsetorder(1))
			While SRX->RX_TIP == "65" .And. lRet
				If cConteudo == SubStr ( SRX->RX_TXT ,  13 , 3 ) .Or.;
					cConteudo == SubStr ( SRX->RX_TXT ,  16 , 3 )
					lRet	:=	.F.
					SR5->(DbSeek(RhTamFilial(xFilial("SR5"))+'X65' ))
					cTabela :=	SR5->R5_DESCRIC
				Endif
				SRX->(DbSkip())
			Enddo
		Endif
	Endif
Endif
If !lRet
	If cTabela == "1"
		If GetRemoteType() == -1
			MsgLogGrid( Ap5GetHelp("NOVALIDO") + "  " + STR0001, .F. ) // Retornar string da funcao Help
		Else
			Help("",1,"NOVALIDO","",STR0001,1) //"Tipo de concepto invalido"
		EndIf
	ElseIf cTabela == "2"
		If GetRemoteType() == -1
			MsgLogGrid( Ap5GetHelp("NOVALIDO") + "  " + STR0002, .F. ) // Retornar string da funcao Help
		Else
			Help("",1,"NOVALIDO","",STR0002,1) //"No pueden ser utilizados conceptos atribuidos a un indentificador de calculo"
		EndIf
	Else
		If GetRemoteType() == -1
			MsgLogGrid( Ap5GetHelp("NOVALIDO") + "  " + STR0003, .F. ) // Retornar string da funcao Help
		Else
			Help("",1,"NOVALIDO","",STR0003+cTabela,1) //"El concepto utilizado ya esta siendo utilizado en la tabla de "
		EndIf
	Endif
Endif
Return lRet

Static Function GetAno2(dData)
Return Right(Str(Year(dData),0),2)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCChkGpe ºAutor  ³Bruno Sobieski      ºFecha ³  02/26/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existem todos os campos necesario da localizacaoº±±
±±º          ³para o pais                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocChkGPE()
Local lRet	:=	.T.

If cPaisLoc == "CHI"
	If SRA->(FieldPos('RA_AFP'))*SRA->(FieldPos('RA_AFPVOL'))*SRA->(FieldPos('RA_TIPOAFP'))*;
		SRA->(FieldPos('RA_AFPCTV'))*SRA->(FieldPos('RA_TIPOCTV'))*;
		SRA->(FieldPos('RA_OBRASOC'))*SRA->(FieldPos('RA_ISAVAL'))*SRA->(FieldPos('RA_ADICISA'))* ;
		SRV->(FieldPos('RV_IMPLBRE'))*SRV->(FieldPos('RV_POSLBRE'))  == 0
		If GetRemoteType() == -1
			MsgLogGrid( Ap5GetHelp("NAOLOCAL") + "  " + STR0004, .F. ) // Retornar string da funcao Help
		Else
			Help("",1,"NAOLOCAL","",STR0004,1) //"Por favor chequee la actualizacion de diccionarios necesaria para usar el modulo en CHILE."
		EndIf		
		lRet	:=	.F.
	Endif
ElseIf cPaisLoc =="URU"
	If SRV->(FieldPos('RV_IPD'))  == 0
		If GetRemoteType() == -1
			MsgLogGrid( Ap5GetHelp("NAOLOCAL")+ "  " + STR0005 , .F. ) // Retornar string da funcao Help
		Else
			Help("",1,"NAOLOCAL","",STR0005,1) //"Por favor chequee la actualizacion de diccionarios necesaria para usar el modulo en URUGUAY"
		EndIf
		lRet	:=	.F.
	Endif
Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocDiaHoraºAutor  ³Silvia Taguti       ºFecha ³  14/02/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula os dias uteis no mes de ferias                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ dInicial = Data Inicial                                    ³±±
±±³          ³ dFinal   = Data Final                                      ³±±
±±º          ³ dIniFer  = Data Inicial Ferias                             ³±±
±±º          ³ dFimFer  = Data Final Ferias                               ³±±
±±º          ³ nHabiles = Dias uteis                                      º±±
±±º          ³ nHoras   = Horas Trabalhadas                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocDiaHora(dInicial,dFinal,dIniFer,dFimFer,nHabiles,nHoras)
Local nRet		:=	0
Local aFeriados := RetFeriados()

nHabiles	:=	0
nReales	:=	0
nHoras  := 0

While dInicial <= dFinal
	If (dInicial < dIniFer .or. dInicial > dFimFer) .and. (dFinal < dIniFer .or. dFinal > dFimFer)
		If Ascan(aFeriados,Dtos(dInicial)) == 0 .And. Dow(dInicial) <> 1
			nHabiles++
			If Dow(dInicial) <> 7
				nHoras := nHoras + 8
			Else
				nHoras := nHoras + 5
			Endif
		Endif
	Endif
	dInicial++
Enddo

Return	nRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocFerPag ºAutor  ³Bruno Sobieski      ºFecha ³  08/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existem feriados pagos no periodo informado     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ dInicial = Data Inicial                                    ³±±
±±³          ³ dFinal   = Data Final                                      ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocFerPag(dInicial,dFinal)
Local nRet	:=	0
Local nX	:=	0
Local lFer := .F.

If aFerPag == Nil
	aFerPag :=	{}
	If FPHIST82( xFilial("SRX") , "66" )
		SRX->(dbsetorder(1))
		While SRX->RX_TIP == "66"
			AAdd(aFerPag,CTOD(Substr(SRX->RX_COD,3,2)+"/"+Substr(SRX->RX_COD,1,2)+"/"+Str(Year(dInicial),4),'ddmmyy'))
			If Year(dInicial) <> Year(dFinal)
				AAdd(aFerPag,CTOD(Substr(SRX->RX_COD,3,2)+"/"+Substr(SRX->RX_COD,1,2)+"/"+Str(Year(dFinal),4),'ddmmyy'))
			Endif
			SRX->(DbSkip())
		Enddo
	Endif
Endif
For nX:=1	To	Len(aFerPag)
	If dInicial <= aFerPag[nX]  .And. aFerPag[nX] <= dFinal
   	lFer := .F.
		dbSelectArea("SR8")
		dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
		While ! Eof() .And. SR8->R8_Filial+SR8->R8_MAT = SRA->RA_FILIAL+SRA->RA_MAT
			If SR8->R8_TIPO == 'F'.And. aFerPag[nX] >= SR8->R8_DataIni .And. aFerPag[nX] < SR8->R8_DataFim
				lFer := .T.
				Exit
			Endif	
			SR8->(dbSkip())
		EndDo		
		If !lFer
			nRet++ 
		Endif
	Endif
Next
Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocSimVac ºAutor  ³Bruno Sobieski      ºFecha ³  08/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava ou restaura o conteudo do aPd no caclulo de ferias    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ nOpcao   = 1 - Guarda                                      ³±±
±±³          ³            2 - Restaura                                    ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocSimVac(nOpcao)
Local aAux	:=	{}

If nOpcao == 1
	aPdTemp	:=	aClone(aPd)
	aPd		:=	{}
Else
	aAux	:=	aClone(aPd)
	aPd	:=	aClone(aPdTemp)
	//Neste array estao agora as simulacoes de folha para
	//Calcular o salario vacaional
	aPdTemp:=	aClone(aAux)
Endif
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DiasTrabAnoºAutor  ³Bruno Sobieski     ºFecha ³  08/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula os dias trabalhado de um entre dois meses.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ cDataIni = MesAno Inicial                                  ³±±
±±³          ³ cDataFim = MesAno Final                                    ³±±
±±³          ³ cCodDias = Verba  para os dias                             ³±±
±±³          ³ lFaltas  = Se tira as faltas ou nao                        ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DiasTrabAno(cIni,cFim,cCodDias,lFaltas)
Local nDias 	:= 0
Local nAno		:=	Val(Substr(cIni,1,4))
Local nMes		:=	Val(Substr(cIni,5,2))
Local cDataIni	:=	cIni
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procurar quantas jornadas trabalhou no periodo    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SRD")
DbSetOrder(1)
DbSeek(xFilial()+SRA->RA_MAT+cDataIni+cCodDias ,.T.)
While !SRD->(EOF()).And. SRA->RA_MAT==SRD->RD_MAT .And. SRD->RD_DATARQ <= cFim
	//Faço um while pois posso ter varias semanas no mesmo mes
	While xFilial()+SRA->RA_MAT+cDataIni+cCodDias == ;
		RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD
		nDias	+=	SRD->RD_HORAS
		DbSkip()
	Enddo
	nMes++
	IF nMes > 12
		nMes := 1
		nAno := nAno + 1
	EndIF
	cDataIni	:=	Strzero(nAno,4) + Strzero(nMes,2)
	DbSeek(xFilial()+SRA->RA_MAT+cDataIni+cCodDias,.T.)
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Vou procurar as faltas do ano todo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nAno		:=	Val(Substr(cIni,1,4))
nMes		:=	Val(Substr(cIni,5,2))
cDataIni	:=	cIni
DbSeek(xFilial()+SRA->RA_MAT+cDataIni+aCodFol[54,1],.T.)
While !SRD->(EOF()).And. SRA->RA_MAT==SRD->RD_MAT .AND. SRD->RD_DATARQ <= cFim
	//Faço um while pois posso ter varias semanas no mesmo mes
	While xFilial()+SRA->RA_MAT+cDataIni+aCodFol[54,1] == ;
		RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD
		nDias	-=	SRD->RD_HORAS
		DbSkip()
	Enddo
	nMes++
	IF nMes > 12
		nMes := 1
		nAno := nAno + 1
	EndIF
	cDataIni	:=	Strzero(nAno,4) + Strzero(nMes,2)
	DbSeek(xFilial()+SRA->RA_MAT+cDataIni+aCodFol[54,1],.T.)
Enddo
//Somar os dias trabalhados no mes de rescisao
If If(Type("c__Roteiro")="U",.F.,c__Roteiro == "RES") 
	If cFim == AnoMes(dDataDem)
		dbSelectArea("SRC")
		SRC->(DbSetOrder(1))
		SRC->(DbSeek(xFilial()+SRA->RA_MAT ))
		While !SRC->(Eof()) .And. SRC->RC_FILIAL + SRC->RC_MAT == SRA->RA_FILIAL + SRA->RA_MAT
			If cCodDias == SRC->RC_PD
				nDias	+=	SRC->RC_HORAS
			Endif
			SRC->(dbSkip())
		Enddo
	Endif	
Endif	

Return nDias

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCCMCURU  ºAutor  ³Bruno Sobieski     ºFecha ³  12/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula o complemento a cuota mutual                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Observa.: ³ MUITO IMPORTANTE : Este imposto eh soi pago pela empresa e ³±±
±±³          ³ se deve pagar se todo o que descontou e pagou em conceito  ³±±
±±³          ³ DISSE nao ultrapassa a cota minima de Cuota Mutual que esta³±±
±±³          ³ cadastrada no parametro DISSE.                             ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOCCMCURU()

Local nFonasCot := 0
                   
If !LOC_FONASA(@nFonasCot,,,Right(cAnoMesRef,2)+Left(cAnoMesRef,4),@cCCCuota)
	Return
EndIf

//Gerar somente quando a funcao for chamada do fechamento da contabilizacao
If Type("lFolPgto") == "U" .And. Type("lFol13Sl")== "U"
	Return
Endif
If Type("lAgui") == "U"
	lAgui := .F.
Endif           
If Type("nTot13") == "U"
	nTot13 := 0
Endif

//Montar Base cuota mutual do funcionario e cuota mutual da empresa
If nRelat == 2
	lFolha := .T.
	nTotFol := 0 
	nFuncFol := nFuncs
	aEval(aFilB,{ |x| nTotFol += If ( X[1]$ aCodFol[303,1] ,x[3],0.00) }) //Patronal - Folha
	aEval(aFilD,{ |x| nTotFol += If ( X[1]$ aCodFol[309,1] ,x[3],0.00) }) //Funciona - Folha
ElseIf nRelat == 3 .or. nRelat == 4
	lAgui := .T.
	nTot13 := 0
	aEval(aFilD,{ |x| nTot13 += If ( X[1]$ aCodFol[359,1] ,x[3],0.00) }) //Funciona - Aguina
Endif                                 
//Soh gera o complemento de cuota mutual quando totalizar folha e/ou 13 salario
If (lFolPgto .And. lFol13Sl .And. lFolha .And. lAgui) .or. (lFolPgto .And. !lFol13Sl .And.;
	 lFolha .And. !lAgui).or. (!lFolPgto .And. lFol13Sl .And. !lFolha .And. lAgui)
	If (nTotFol+nTot13) < (nFonasCot * nFuncFol)
		LocSoma(aCodFol[312,1],(nFonasCot * nFuncFol) - (nTotFol+nTot13),aFilB )  // Complemento de CM por filial
		LocSoma(aCodFol[312,1],(nFonasCot * nFuncFol) - (nTotFol+nTot13),aEmpB )  // Complemento de CM por empresa
	Endif
Endif	

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCBSEURU  ºAutor  ³Bruno Sobieski     ºFecha ³  12/03/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula os valores de BSE para contabilizacao e relatorio   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOCBSEURU(aBase)
Local nTotFol	:=	0
Local nTmp		:=	0             
Local nCSocial :=	0
Local nBseFixo :=	0
Local nBSeIva  :=	0
Local nAliqBSE :=	0
Local	nPrima	:=	0
Local	nImposto	:=	0
Local	nIVA		:=	0
Local aArea		:=	GetArea()
Local aAreaCTT	:=	CTT->(GetArea())
Static nTotPrimas	
If nTotPrimas == Nil
	nTotPrimas := 0
Endif	
DbSelectArea('CTT')
DbSetOrder(1)
If MsSeek(xFilial()+cCCAnt).And.!Empty(CTT->CTT_POLIZA)
	//Pegar configuracoes do BSE
	LOC_BSE(@nCSocial,@nBseFixo,@nBseIva,cAnoMesRef)
	LOC_BSE2(CTT->CTT_POLIZA,@nAliqBSE)

	//Soma a base do BSE, consideradno a base do BPS
	aEval(aBase,{ |x| nTotFol += If ( X[1]$ aCodFol[413,1]+"*"+aCodFol[414,1]+"*"+aCodFol[415,1] ,x[3],0.00) }) //Patronal - Folha
	If nTotFol > 0
		nPrima	:=	nTotFol*nAliqBSE/100
		nImposto	:=	nPrima * nBseFixo/100
		nIVA		:=	(nPrima+nImposto)*nBseIva/100
		LocSoma(aCodFol[398,1],nPrima		,aBase )  //Prima
		LocSoma(aCodFol[399,1],nImposto	,aBase )  //Imposto 
		LocSoma(aCodFol[400,1],nIva		,aBase )  //IVA 
	Endif	
Endif                             
RestArea(aAreaCTT)
RestArea(aArea)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SETVALMOPREºAutor ³Bruno Sobieski Chavez Data ³  17/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Setea o valor do MOPRE                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM020                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SetValMopre(nMOPRE,dData)
DEFAULT dData	:=	dDataBase

If FPHIST82(xFilial("SRX") , "63" , MesAno(dDataBase))
	nMOPRE  	:= Val( SubStr( SRX->RX_TXT ,   1 , 18 ) )
ElseIf FPHIST82(xFilial("SRX") , "63" , "      ")
	nMOPRE  	:= Val( SubStr( SRX->RX_TXT ,  1 , 18 ) )
Else
	nMOPRE	:=	0
Endif

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SETSINDLOC ºAutor ³Bruno Sobieski Chavez Data ³  21/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega os parametros do sidicato                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM020                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SetSindLoc(cSindic)
Local	aSindTmp:=	{}
DEFAULT aSindic	:=	{}

If (nPosSind	:=	Ascan(aSindic,{|x| x[1]==cSindic})) > 0
	aSindTmp	:=	aClone(aSindic[nPosSind][2])
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtener los valores de :                                         ³
	//³1: Porcentaje de deduccion al empleado                           ³
	//³2: Porcentaje de pago patronal                                   ³
	//³3: Porcentaje de deduccion al empleado para la confederacion     ³
	//³4: Valor fijo a ser descontado                                   ³
	//³5: Concepto para la deduccion  al empleado                       ³
	//³6: Concepto para el aporte del empleador                         ³
	//³7: Concepto para la deduccion  al empleado para la conf.         ³
	//³8: Concepto para el valor fijo                                   ³
	//³9: Porcentaje de presentismo                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aSindic,{cSindic,{0,0,0,0,"","","","",0,0}})
	RCE->(DbSetORder(1))
	If RCE->(DbSeek(xFilial()+cSindic))
		aSindic[Len(aSindic)][2][1]:= RCE->RCE_PORFUN
		aSindic[Len(aSindic)][2][2]:= RCE->RCE_POREMP
		aSindic[Len(aSindic)][2][3]:= RCE->RCE_PORFED
		aSindic[Len(aSindic)][2][4]:= RCE->RCE_VALFIX
		aSindic[Len(aSindic)][2][5]:= RCE->RCE_VERFUN 
		aSindic[Len(aSindic)][2][6]:= RCE->RCE_VEREMP
		aSindic[Len(aSindic)][2][7]:= RCE->RCE_VERFED 
		aSindic[Len(aSindic)][2][8]:= RCE->RCE_VERFIX
		aSindic[Len(aSindic)][2][9]:= RCE->RCE_SALPRO
		aSindic[Len(aSindic)][2][10]	:=	RCE->RCE_PORPRE
	Endif
	aSindTmp	:=	aClone(aSindic[Len(aSindic)][2])
Endif
Return aSindTmp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCREMVAR  ºAutor ³Bruno Sobieski Chavez Data ³  22/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula el valor diario de Remuneracion variable, para cal- º±±
±±º          ³culo de vacaciones para trabajadores no mensualistas        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM020                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LOCREMVAR()

Local nMes
Local nAno
Local cDataIni
Local nHorasNor	:=	0
Local nRemVar	:=	0

nMes := Month(dDataBase)
If nMes > MESES_REM_VAR
	nMes 	:=	nMes - MESES_REM_VAR
	nAno 	:= Year(dDataBase)
Else
	nAno 	:= Year(dDataBase) - 1
	nMes	:= 12 + (nMes - MESES_REM_VAR)
Endif

cDataIni := Strzero(nAno,4) + Strzero(nMes,2)

dbSelectArea( "SRD" )
dbSetOrder(1)
dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cDataIni , .T. )

While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT
	If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_REFFER") == "S"
		nHorasNor	+= (SRD->RD_HORAS) //Sumar horas normales
	Endif
	If SRA->RA_TIPOPGT == "S"
		If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_REMVAR") == "S"
			nRemVar += (SRD->RD_HORAS	* PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_PERC")/100) //Sumar horas variables
		Endif
	Endif
	dbSkip()
Enddo

If SRA->RA_TIPOPGT == "S"  .And. nHorasNor > 0 .And. (nRemVar/nHorasNor) > 0
	//	El calculo es el siguiente :
	//Cantidad de horas ("especiales"+Horas normales)/ horas normales = Coeficiente
	//Al valor de la hora normal se lo multiplica por este coeficiente, y la diferencia
	//entre este resultado y la hora normal, da el valor de la remuneracion variable por hora.
	//Ejemplo :
	//Valor hora normal = 2,00
	// Horas especiales  50
	// Horas normales   100
	// Coeficiente	= 100+50/100 = 1,5
	//	Remuneracion variable hora = (2,00 * 1,5) - 	2,0 = 1,00
	nRemVarDia	:=  (((nRemVar/nHorasNor)*SRA->RA_SALARIO)) * (SRA->RA_HRSMES/30)
	FGeraVerba("760",nRemVarDia,0,cSemana)
	
Endif
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCAFAST  ºAutor  ³Bruno Sobieski      ºFecha ³  01/22/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula faltas e afastamentos de um funcionario entre duas  º±±
±±º          ³datas                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ dDataIni = Data de inicio                                  ³±±
±±³          ³ dDataFim = Data   Final                                    ³±±
±±³          ³ cMat     = Funcionario                                     ³±±
±±³          ³ aCodFalta= Array com os codigos que sera considerados falta³±±
±±³          ³ aTipAfast= Array com os tipos de afastamento que devem ser ³±±
±±³          ³             considerados                                   ³±±
±±³          ³ lHabiles = .T. se deve considerar so dias uteis do afast.  ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LocAfast(dDataIni,dDataFim,cMat,aCodFalta,aTipAfas,lHabile)
Local nX		:=	0
Local cDataIni	:=	MesAno(dDataIni)
Local cDataFim	:=	MesAno(dDataFim)
Local cDatTmp	:=	cDataIni
Local nDias		:=	0
Local nMes		:=	Val(Substr(cDataIni,5))
Local nAno		:=	Val(Substr(cDataIni,1,4))
Local nAfast	:=	0
Default lHabile := .T.

If Type("aCodFol") <> "A" .Or. Len(aCodFol) == 0
	aCodFol	:=	{}
	FP_CODFOL(@aCodFol,SRA->RA_FILIAL)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Vou procurar as faltas do Periodo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SRD")
DbSetOrder(1)
For nX:= 1 To Len(aCodFalta)
	cDataIni	:=	cDatTmp
	nMes		:=	Val(Substr(cDataIni,5))
	nAno		:=	Val(Substr(cDataIni,1,4))
	DbSeek(xFilial()+cMat+cDataIni+aCodFalta[nX],.T.)
	While !SRD->(EOF()).And. cMat==SRD->RD_MAT .AND. SRD->RD_DATARQ <= cDataFim
		//Faço um while pois posso ter varias semanas no mesmo mes
		While !SRD->(EOF()) .And. xFilial()+cMat+cDataIni+aCodFalta[nX] == ;
			RD_FILIAL+RD_MAT+RD_DATARQ+RD_PD
			nDias	+=	SRD->RD_HORAS
			DbSkip()
		Enddo
		nMes++
		If nMes > 12
			nMes	:=	1
			nAno++
		Endif
		cDataIni	:=	Strzero(nAno,4) + Strzero(nMes,2)
		DbSeek(xFilial()+cMat+cDataIni+aCodFalta[nX],.T.)
	Enddo
Next
If cPaisLoc  <> "DOM"
	cDataIni	:=	MesAno(dDataIni)
	DbSelectArea('SR8')
	DbSetOrder(1)
	MsSeek(xFilial()+cMat+cDataIni,.F.)
	DbSkip(-1)
	//Verifico se o registro anterior, se refere a um afastamento que acabou no periodo atual
	If !(SR8->R8_FILIAL == xFilial() .And. cMat == SR8->R8_MAT .And. MesAno(SR8->R8_DATAFIM) >= cDataIni )
		DbSkip()
	Endif
	While !EOF() .And. xFilial()==SR8->R8_FILIAL .And. cMat == SR8->R8_MAT .And. SR8->R8_DATAINI <= dDataFim
		If Ascan(aTipAfas,SR8->R8_TIPO) > 0
			If lHabile
				LocGHabRea(Max(SR8->R8_DATAINI,dDataIni),Min(SR8->R8_DATAFIM,dDataFim),@nAfast)
			Else
				LocGHabRea(Max(SR8->R8_DATAINI,dDataIni),Min(SR8->R8_DATAFIM,dDataFim),,@nAfast)
			Endif	
			nDias	+=	nAfast
			nAfast	:=	0
		Endif
		DbSkip()
	Enddo
Else 
	DbSelectArea('SR8')
	DbSetOrder(1)
	MsSeek(xFilial()+SRA->RA_MAT)
	While ! Eof() .And. SR8->R8_Filial+SR8->R8_MAT = SRA->RA_FILIAL+SRA->RA_MAT
		If MesAno(SR8->R8_DataIni) = MesAno(dDataBase) .And. MesAno(SR8->R8_DataFim) = MesAno(dDataBase)
			LocGHabRea(SR8->R8_DATAINI,SR8->R8_DATAFIM,@nAfast)
			nDias	+=	nAfast
		ElseIf MesAno(SR8->R8_DataIni) = MesAno(dDataBase)
			LocGHabRea(SR8->R8_DATAINI, f_Ultdia(dDataBase),@nAfast)
			nDias	+=	nAfast
		ElseIf MesAno(SR8->R8_DataFim) = MesAno(dDataBase)
			LocGHabRea(Ctod("01/"+Strzero(Month(dDataBase),2)+"/"+right(str(Year(dDataBase)),2),"ddmmyy") ,SR8->R8_DATAFIM,@nAfast)
			nDias	+=	nAfast
		ElseIf MesAno(SR8->R8_DataIni) < MesAno(dDataBase) .And. Empty(SR8->R8_DataFim)
			LocGHabRea(Ctod("01/"+Strzero(Month(dDataBase),2)+"/"+right(str(Year(dDataBase)),2),"ddmmyy"),f_Ultdia(dDataBase),@nAfast)
			nDias	+=	nAfast
	   Endif
   	dbSkip()
	Enddo			
Endif

Return nDias

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocCntNLabºAutor  ³Bruno Sobieski      ºFecha ³  24/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula os dias nao laboraveis entre duas datas             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ dInicial = Data Inicial                                    ³±±
±±³          ³ dFinal   = Data Final                                      ³±±
±±º          ³ aDias    = Dias que deve considerar como nao laboraveis    º±±
±±º          ³ lFeriados= Indice se deve considerar os feriados como nao  º±±
±±º          ³            laboraveis .                                    º±±
±±º          ³ nOpcao   = 1.Indica que deve retornar dias laboraveis      º±±
±±º          ³            2.Indica que deve retornar dias nao laboraveis  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocCntNLab(dInicial,dFinal,aDias,lFeriados,nOpcao)
Local nDias		:=	0
Local nHoras	:=	0
Local aFeriados	:=	RetFeriados()

DEFAULT lFeriados	:=	.T.
DEFAULT aDias		:= {1} //Domingo

While dInicial <= dFinal
	If (nOpcao == 1 .And. (Ascan(aDias,DOW(dInicial)) == 0  .And. (!lFeriados .Or. Ascan(aFeriados,DTOS(dInicial)) == 0 ))) .Or.;
		(nOpcao == 2 .And. !(Ascan(aDias,DOW(dInicial)) == 0  .And. (!lFeriados .Or. Ascan(aFeriados,DTOS(dInicial)) == 0 )))
		nDias++
		If Dow(dInicial) <> 7
			nHoras := nHoras + 8
		Else
			nHoras := nHoras + 5
		Endif
	Endif
	dInicial++
Enddo

Return {nDias,nHoras}


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocIRSRK  ºAutor  ³Bruno Sobieski      ºFecha ³  26/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Apaga os registros gerados em outro calculo, e gera novo    º±±
±±º          ³lancamento, referente a valores futuros para compor a base  º±±
±±º          ³do IR.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cFil	= Filial 		                                      º±±
±±º			 ³ cMAT	= Matricula 										  º±±
±±º			 ³ dDPGT = Data de Pagamento								  º±±
±±º			 ³ cCCT	= Centro de Custo 									  º±±
±±º			 ³ nvAL	= Valor do Lancamento								  º±±
±±º			 ³ cItem = Item Contabil  									  º±±
±±º			 ³ nvAL	= Classe de Valor									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso		 ³ Generico 												  º±±
±±ÀÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function LocIRSRK(cFil,cMAT,dDPGT,cCCT,nVAL,aCodFolLoc,cItem,cClvl)

Local cAlias   := "SRK"  
Local cDoc     := "000001" 
Local cVerba   := fGetCodFol("0327")
Local cVerba1  := fGetCodFol("0326")  
Local aArea	   := GetArea()
Local cNumId , cAliasSRK , cQuery       
Local aDocs    := {} 
Local nValParc := 0 
Local nValorBus:= 0
Local lItemClvl:= SuperGetMv( "MV_ITMCLVL", .F., "2" ) == "1"

DEFAULT cItem:=""
DEFAULT cClvl:=""

If lItemClvl
	If Empty(cItem)
		cItem:=SRA->RA_ITEM
	EndIf
	If Empty(cClvl)
		cClvl:=SRA->RA_CLVL  
	EndIf	
EndIf

If aCodFolLoc == Nil
	aCodFolLoc := {}

	IF !Fp_CodFol(@aCodFolLoc,SRA->RA_FILIAL)
   		Return(.F.)
	EndIF
Endif	

#IFDEF TOP
    
	cAliasSRK := "SRK1"
	
    cQuery    := " SELECT RK_DOCUMEN FROM " + RetSqlName("SRK")
	cQuery    += " WHERE D_E_L_E_T_ = ' ' AND RK_FILIAL = '"+xFilial("SRK")+"' AND RK_MAT = '"+cMAT+"' "
	cQuery    += " ORDER BY RK_DOCUMEN DESC"
	
	cQuery    := ChangeQuery( cQuery ) 
	
	IF SELECT(cAliasSRK) > 0
		(cAliasSRK)->( DBCLOSEAREA() )
	ENDIF
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasSRK, .F., .T. )
	
	(cAliasSRK)->( dbGoTop() )
	IF !EMPTY( (cAliasSRK)->RK_DOCUMEN )
		cDoc     := Soma1( (cAliasSRK)->RK_DOCUMEN )
	ENDIF
	
#ELSE	

	dbSelectArea("SRK")
	SRK->( dbSetOrder(1) )
	IF SRK->( dbSeek( xFilial("SRK") + cMAT ) )//RK_FILIAL+RK_MAT+RK_PD+RK_CC
		While SRK->( !EOF() ) .AND. SRK->RK_FILIAL == xFilial("SRK") .AND. SRK->RK_MAT == cMAT
			aAdd( aDocs , SRK->RK_DOCUMEN )
		SRK->( DBSKIP() )
		Enddo
	ENDIF  
	
	IF LEN( aDocs ) > 0
   		aSort(aDocs,,,{|x,y| x > y })
   		
		cDoc     := Soma1(aDocs[1])
	ENDIF
	
#ENDIF

cNumId            := "SRK" + cFil + cMAT + cVerba + cDoc

/*dbSetOrder(1)
If dbSeek(cFil+cMat+aCodFolLoc[327,1]+MesAno(dDPGT))
	RecLock(cAlias,.F.,.T.)
	nVal	+=	SRK->RK_VALORTO	
	dbDelete()
	MsUnLock()
	RecLock(cAlias,.T.,.T.)
Elseif nVal # 0.00
	RecLock(cAlias,.T.,.T.)
Else
	Return
Endif */

If nVal > 0
	RecLock(cAlias,.T.,.T.)
	SRK->RK_FILIAL    := cFil
	SRK->RK_MAT       := cMat
	SRK->RK_PD        := cVerba
	SRK->RK_VALORTO   := nVal
	SRK->RK_PARCELA   := 12-Month(dDPGT)
	SRK->RK_VALORPA   := Round(SRK->RK_VALORTO/(12-Month(dDPGT)),MsDecimais(1))
	SRK->RK_VALORAR   := SRK->RK_VALORTO - (SRK->RK_VALORPA * SRK->RK_PARCELA)
	SRK->RK_DTVENC    := dDPGT+1 //Debe ser considerada hasta el mes 12
	SRK->RK_DTMOVI    := dDataBase
	SRK->RK_CC        := cCCT
	If lItemClvl	
		SRK->RK_ITEM      := cItem
		SRK->RK_CLVL      := cClvl		
	EndIf
	SRK->RK_PERINI    := cPeriodo
	SRK->RK_NUMPAGO   := cNumPag
	SRK->RK_PROCES    := cProces     
	SRK->RK_VLSALDO   := nVal
	SRK->RK_STATUS    := "2" 
	
	// Gravação do Numero do Documento e o Numero do Id..
	SRK->RK_DOCUMEN   := cDoc  
	SRK->RK_NUMID     := cNumId
	///////////////////////////////////
	MsUnLock()
	
	nValParc := Round(SRK->RK_VALORTO/(12-Month(dDPGT)),MsDecimais(1))
	nValorBus:= nVal - nValParc
	
	dbSelectArea("SRD")
	SRD->( dbSetOrder(6) ) 
	
	SRD->( dbSeek( xFilial("SRD") + cMAT + cVerba ) )
	While SRD->( !EOF() ) .AND. SRD->RD_FILIAL == xFilial("SRD") .AND. SRD->RD_MAT == cMAT .AND. SRD->RD_PD == cVerba
		IF SRD->RD_DATPGT == dDPGT .AND. SRD->RD_VALOR == nValParc
	    	Reclock("SRD",.F.)
	    	SRD->RD_NUMID     := cNumId
	    	MsUnlock()
		ENDIF
		SRD->( DBSKIP() )
	Enddo
	
	SRD->( dbSeek( xFilial("SRD") + cMAT + cVerba1 ) )
	While SRD->( !EOF() ) .AND. SRD->RD_FILIAL == xFilial("SRD") .AND. SRD->RD_MAT == cMAT .AND. SRD->RD_PD == cVerba1
		IF SRD->RD_DATPGT == dDPGT .AND. SRD->RD_VALOR == nValorBus 
	    	Reclock("SRD",.F.)
	    	SRD->RD_NUMID     := cNumId
	    	MsUnlock()
		ENDIF
		SRD->( DBSKIP() )
	Enddo
	
Endif

RestArea(aArea)	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocJaCalc ºAutor  ³ Bruno Sobieski     ºFecha ³  01/27/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Indica se foi efetuado o calculo para o periodo atual.      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocJaCalc(cRotina)
Local lRet	:=	.F.

If !Empty(GetMV('MV_SEM'+cRotina))
	lRet	:=	.T.
Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocDiasAv ºAutor  ³ Bruno Sobieski     ºFecha ³  01/29/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna os dias que devem ser pagos por aviso previo, e os  º±±
±±º          ³dias de saldo de salario, dado que o aviso previo comeca    º±±
±±º          ³a contar a partir do dia 1ro do proximo mes.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LocDiasAv(dDataAv,nDiasAv,nDiasSalAv)

If Empty(dDataDem)
	dDataDem := dDataDem1
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ate 5 anos trabalhados corresponde 1 mes de aviso previo,³
//³ com mais de 5 anos correspondem 2 meses de aviso previo,³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nAnosCasa < 5
	nDiasAv   := 30
Else
	nDiasAv   := 60
Endif
nDiasSalAv	:=	0

If !Empty(dDataAv) .And. Month(dDataAv) <> Month(dDataDem)
	If  aIncRes[6]<>'S' .Or. Day(dDataAv) == F_UltDia(dDataAv)
		nDiasAv		-=	(dDataDem-dDataAv)
	Else
		nDiasAv		-=	(dDataDem - CTOD( StrZero(F_UltDia(dDataAv),2)+"/"+SubStr(DToS(dDataAv),5,2)+"/"+SubStr(DToS(dDataAv),1,4)))
	Endif
Else
	If Day(dDataDem) <> F_UltDia(dDataDem).And. aIncRes[6]=='S'
		nDiasSalAv	+=	( F_UltDia(dDataDem) - (Day(dDataDem)+1) )
		nDiasAv		+=	nDiasSalAv
	Endif
Endif


nDiasAv	:=	Max(nDiasAv,0)
nDiasAv	-= IIf(aIncRes[03]=="S",nDiasSalAv,0)


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCSEMANA ºAutor  ³Silvia Taguti       º Data ³  13/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Quantidade de semanas no mes                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     
Static Function LOCSEMANA(nSemMes,cAnoMes)

If FPHIST82(xFilial("SRX") , "67" , cAnoMes )
	nSemMes	:= Val( SubStr( SRX->RX_TXT ,  21 , 1 ) )
Endif         

Return (.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCALIME  ºAutor  ³Microsiga           º Data ³  03/20/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo de Pagamento de Servico de Alimentacao             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LOCALIME()

Local cAnoMes 	:= MesAno(dDataBase)
Local nDiaAlim 	:= 0
Local aFeriados	:=	RetFeriados()
Local dInicial	
Local dFinal
Local dIniAfas  
Local lPago 	:= .F.
Local nPosAlim
Local nVlrAlim := 0

If FPHIST82(xFilial("SRX") , "68" , SRA->RA_CESTAB) 
	nVlrAlim := Val( SubStr( SRX->RX_TXT ,  21 ,10 ) )
Endif  

If SRA->RA_TIPOPGT = "S"   
	If Type( "aPeriodo" ) = "U"
		aPeriodo := {}
	EndIf
	nPos     := Ascan( aPeriodo, { |X| X[2] == cSemana } )
	If nPos > 0
  		If AnoMes(SRA->RA_ADMISSA)== AnoMes(dDataBase)
  	   	dInicial :=If(SRA->RA_ADMISSA > aPeriodo[ nPos,3],SRA->RA_ADMISSA,aPeriodo[nPos,3])
  		Else
  			dInicial := aPeriodo[nPos,3]
  		Endif	
		dIniAfas := dInicial
		dFinal   := aPeriodo[nPos,4]
	Endif
Else
  	If AnoMes(SRA->RA_ADMISSA)== AnoMes(dDataBase)
  	   dInicial := SRA->RA_ADMISSA
  	Else
  		dInicial := Ctod("01/"+Strzero(Month(dDataBase),2)+"/"+right(str(Year(dDataBase)),2),"ddmmyy")
	Endif
	dFinal   := Ctod(StrZero(F_ULTDIA(dDataBase),2)+"/"+Strzero(Month(dDataBase),2)+"/"+right(str(Year(dDataBase)),2),"ddmmyy")
	dIniAfas := dInicial 
	If SRA->RA_TIPOPGT = "M" .And. c__Roteiro == "FER"
		Return
	Endif	
Endif
                  
lPago := LocVerFer()
If lPago
	Return
Endif	

If !Empty(SRA->RA_CESTAB)
	While dInicial <= dFinal
		If DOW(dInicial) <> 1  .And. DOW(dInicial) <> 7 .And.  Ascan(aFeriados,DTOS(dInicial)) == 0
			nDiaAlim++
		Endif
		dInicial++
 	Enddo
	nDiaAlim	-=	LocAfast(dIniAfas,dFinal,SRA->RA_MAT,{aCodFol[054,1]},{'X','Q','R','F','O','P'})
	If nVlrAlim * nDiaAlim > 0
		nPosAlim:= Ascan(aPd, { |x|   x[01] = aCodFol[156,1] .And. X[3] = cSemana .and. x[09] # "D"})
		IF !Empty( nPosAlim)
			cTipo		:= aPd[nPosAlim,6]				//Salva  o Tipo   da Verba
			cOrigem	:= aPd[nPosAlim,7]				//Salva  a Origem da Verba
		Endif
				
		//--Quando For lancado quantidade utiliza a Lancada.
		If nPosAlim > 0 .And. aPd[nPosAlim,6] == "D"
			nDiaAlim		:= aPd[nPosAlim,4]
			aPd[nPosAlim,9]	:= "D"				//Deleta a Verba  em aPd para Regravar
		Endif           
		FMatriz(aCodFol[156,1],Round((nVlrAlim * nDiaAlim),MsDecimais(1)),nDiaAlim)	
	Endif			
Endif    

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCCESANT ºAutor  ³Silvia Taguti       º Data ³  13/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Seta dias de cesantia                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     
Function LOCCESANT(aDiaCes,cAnoMes)

If FPHIST82(xFilial("SRX") , "65" , cAnoMes) .or. FPHIST82(xFilial("SRX") , "65" , "      ")
   aDiaCes := Array(8)
	aDiaCes[1] := Val( SubStr( SRX->RX_TXT ,  1 , 2 ) )
	aDiaCes[2] := Val( SubStr( SRX->RX_TXT ,  3 , 2 ) )
	aDiaCes[3] := Val( SubStr( SRX->RX_TXT ,  5 , 2 ) )
	aDiaCes[4] := Val( SubStr( SRX->RX_TXT ,  7 , 2 ) )
	aDiaCes[5] := Val( SubStr( SRX->RX_TXT ,  9 , 2 ) )
	aDiaCes[6] := Val( SubStr( SRX->RX_TXT ,  11, 2 ) )
	aDiaCes[7] := Val( SubStr( SRX->RX_TXT ,  13, 2 ) )
	aDiaCes[8] := Val( SubStr( SRX->RX_TXT ,  15, 2 ) )
Endif         

Return (.T.)


		
		
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCLUCRO  ºAutor  ³Microsiga           º Data ³  03/27/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Participacao nos Lucros                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOCLUCRO()

Local nVlrRateio:= nSalReceb:= 0           
Local nMesTrab:=nAnoTrab:=nDiaTrab:= 0
Local nSalDia := 0
Local nPercFunc1 := 0
Local nMontoFunc := 0    
Local nDiaBonif := 0 
Local	nMesAdPro := 0
Local	nAnoAdPro := 0
Local	nMesDeAnt := 0
Local	nAnoDeAnt := 0
Local	dDataAdPro:= Ctod("//") 
Local dDataDeAnt:= Ctod("//")

Private cDataIni
Private cDataFim
Private nMonTotal := 0
Private dDataIni
Private dDataFim

cDataIni := StrZero(nAnoIni,4) + StrZero(nMesIni,2)
cDataFim := StrZero(nAnoFim,4) + StrZero(nMesFim,2)
dDataIni := Ctod("01/"+StrZero(nMesIni,2)+"/"+StrZero(nAnoIni,4))
dDataFim := Ctod("30/"+StrZero(nMesFim,2)+"/"+StrZero(nAnofim,4))

DbSelectArea("SRA")
If lPrimeiro
	nMontante := MontaTotal()
	nFactor := nValorRat / nMontante
   lPrimeiro := .F.
Endif	
DbSelectArea("SRA")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Proximo Mes de Admissao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SRA->RA_ADMISSA >= dDataIni
	nMesAdPro := Month(SRA->RA_ADMISSA) + 1
	nAnoAdPro := Year(SRA->RA_ADMISSA)
	If nMesAdPro == 13
		nMesAdPro := 1
		nAnoAdPro := nAnoAdPro + 1
	Endif
	dDataAdPro := Ctod("01/"+StrZero(nMesAdPro,2)+"/"+StrZero(nAnoAdPro,4))
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Mes anterior a data de demissao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SRA->RA_DEMISSA <= dDataFim 
	nMesDeAnt := Month(SRA->RA_DEMISSA) - 1
	nAnoDeAnt := Year(SRA->RA_DEMISSA)
	If nMesDeAnt == 0
		nMesDeAnt := 12
		nAnoDeAnt := nAnoDeAnt - 1
	Endif
	If nMesDeAnt < 0
		nMesDeAnt := 12 - ( nMesDeAnt * -1 )
		nAnoDeAnt := nAnoDeAnt - 1
	Endif
	dDataDeAnt := Ctod(If(nMesDeAnt<> 2,"30/","28/")+StrZero(nMesDeAnt,2)+"/"+StrZero(nAnoDeAnt,4))
Endif

If SRA->RA_ADMISSA < dDataIni .And. (Empty(SRA->RA_DEMISSA) .or. SRA->RA_DEMISSA > dDataFim )
	nMesTrab := Round((dDataFim - SRA->RA_ADMISSA) / 30,0)
ElseIf SRA->RA_ADMISSA >= dDataIni .And. (Empty(SRA->RA_DEMISSA) .or. SRA->RA_DEMISSA > dDataFim )
	nMesTrab := Round((dDataFim - dDataAdPro) / 30,0)
	nMesTrab+=((30-If(Day(SRA->RA_ADMISSA)==F_ULTDIA(SRA->RA_ADMISSA),30,Day(SRA->RA_ADMISSA)))+1 )/30
ElseIf SRA->RA_ADMISSA < dDataIni .And.  SRA->RA_DEMISSA <= dDataFim
	nMesTrab:= Round((dDataDeAnt - SRA->RA_ADMISSA+If(Month(dDataDeAnt)==2,2,0))/30,0)
	nMesTrab+= If(Day(SRA->RA_DEMISSA)==F_ULTDIA(SRA->RA_DEMISSA),30,Day(SRA->RA_DEMISSA)) / 30
ElseIf SRA->RA_ADMISSA >= dDataIni .And. SRA->RA_DEMISSA <= dDataFim
	nMesTrab:= Round((dDataDeAnt - dDataAdPro+If(Month(dDataDeAnt)==2,2,0))/30,0)
	nMesTrab+= ((30-If(Day(SRA->RA_ADMISSA)==F_ULTDIA(SRA->RA_ADMISSA),30,Day(SRA->RA_ADMISSA)))+1 )/30
	nMesTrab+= If(Day(SRA->RA_DEMISSA)==F_ULTDIA(SRA->RA_DEMISSA),30,Day(SRA->RA_DEMISSA)) / 30
Endif

nAnoTrab := nMesTrab /12

If SRA->RA_CATFUNC == "M"
	nSalDia := Round((SRA->RA_SALARIO/SRA->RA_HRSMES)*SRA->RA_HRSDIA,2)
	nSalMes := (SRA->RA_SALARIO)
ElseIf SRA->RA_CATFUNC == "H"
	nSaldia :=Round(SRA->RA_SALARIO * SRA->RA_HRSDIA,2)
	nSalMes := (SRA->RA_SALARIO * SRA->RA_HRSMES)
ElseIf SRA->RA_CATFUNC == "D"
	nSalDia:= SRA->RA_SALARIO
	nSalMes:= SRA->RA_SALARIO * Round(SRA->RA_HRSMES/SRA->RA_HRSDIA,2)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula meses trabalhados no periodo de apuracao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SRA->RA_ADMISSA < dDataIni .And. (Empty(SRA->RA_DEMISSA) .or. SRA->RA_DEMISSA > dDataFim)
	nMesTFun1 := Round((dDataFim - dDataIni) / 30,0)
ElseIf SRA->RA_ADMISSA >= dDataIni .And. (Empty(SRA->RA_DEMISSA) .or. SRA->RA_DEMISSA > dDataFim)
	nMesTFun1 := Round((dDataFim - dDataAdPro) / 30,0)
	nMesTFun1+=  ((30 - Day(SRA->RA_ADMISSA))+1)/30
ElseIf SRA->RA_ADMISSA < dDataIni .And.  SRA->RA_DEMISSA <= dDataFim
	nMesTFun1:= Round((dDataDeAnt - dDataIni+If(Month(dDataDeAnt)==2,2,0))/30,0)
	nMesTFun1+= Day(SRA->RA_DEMISSA)/30
ElseIf SRA->RA_ADMISSA >= dDataIni .And. SRA->RA_DEMISSA <= dDataFim
	nMesTFun1:= Round((dDataDeAnt - dDataAdPro+If(Month(dDataDeAnt)==2,2,0))/30,0)
	nMesTFun1+= ((30 - Day(SRA->RA_ADMISSA))+1)/30
	nMesTFun1+= Day(SRA->RA_DEMISSA)/30
Endif

nPercFunc1 := nMesTFun1 * 100 /nMesesApur

If nAnoTrab >= 3 
	nMontoFunc :=((nSalDia * 60) * nPercFunc1 ) /100
	nDiaBonif  := 60
ElseIf nAnoTrab > 1 .And. nAnoTrab < 3 
	nMontoFunc := ((nSalDia * 45)* nPercFunc1 ) /100
	nDiaBonif := 45
ElseIf nAnoTrab <= 1
	nMontoFunc := nSalMes * nMesTrab /12
	nDiaBonif := Round(nMesTrab,MsDecimais(1)) 
Endif

If nMontoFunc > 0
	nVlrRateio := nMontoFunc * nFactor
   If nVlrRateio > 0                          
		FGeraVerba(aCodFol[151,1],Round(nVlrRateio,MsDecimais(1)),nDiaBonif,,,,,,,dDataPgto)
	Endif
Endif		

Return   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontaTotalºAutor  ³Microsiga           º Data ³  03/27/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Participacao nos Lucros                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  */

Static Function MontaTotal()
            
Local aAreaLoc 	:= Getarea()
Local nMonto 	:= 0   
Local nMonTotal := 0   
Local nMesTFun 	:= 0
Local nMesAdPro := 0
Local nAnoAdPro := 0
Local nMesDeAnt := 0
Local nAnoDeAnt := 0
Local dDataAdPro:= Ctod("//") 
Local dDataDeAnt:= Ctod("//") 

dBSelectArea("SRA")
dbSetOrder( 1 )
SRA->( dbGoTop() )
While !Eof()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Proximo Mes de Admissao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SRA->RA_ADMISSA >= dDataIni
		nMesAdPro := Month(SRA->RA_ADMISSA) + 1
		nAnoAdPro := Year(SRA->RA_ADMISSA)
		If nMesAdPro == 13
			nMesAdPro := 1
			nAnoAdPro := nAnoAdPro + 1
		Endif
		dDataAdPro := Ctod("01/"+StrZero(nMesAdPro,2)+"/"+StrZero(nAnoAdPro,4))
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Mes anterior a data de demissao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SRA->RA_DEMISSA <= dDataFim 
		nMesDeAnt := Month(SRA->RA_DEMISSA) - 1
		nAnoDeAnt := Year(SRA->RA_DEMISSA)
		If nMesDeAnt == 0
			nMesDeAnt := 12
			nAnoDeAnt := nAnoDeAnt - 1
		Endif
		If nMesDeAnt < 0
			nMesDeAnt := 12 - ( nMesDeAnt * -1 )
			nAnoDeAnt := nAnoDeAnt - 1
		Endif
		dDataDeAnt := Ctod(If(nMesDeAnt<> 2,"30/","28/")+StrZero(nMesDeAnt,2)+"/"+StrZero(nAnoDeAnt,4))
   Endif 

	If SRA->RA_ADMISSA < dDataIni .And. (Empty(SRA->RA_DEMISSA) .or. SRA->RA_DEMISSA > dDataFim )
      nMesTrab := Round((dDataFim - SRA->RA_ADMISSA)/ 30,0)
   ElseIf SRA->RA_ADMISSA >= dDataIni .And. (Empty(SRA->RA_DEMISSA) .or. SRA->RA_DEMISSA > dDataFim )
      nMesTrab := Round((dDataFim - dDataAdPro) / 30,0)
      nMesTrab+=((30-If(Day(SRA->RA_ADMISSA)==F_ULTDIA(SRA->RA_ADMISSA),30,Day(SRA->RA_ADMISSA)))+1 )/30
   ElseIf SRA->RA_ADMISSA < dDataIni .And.  SRA->RA_DEMISSA <= dDataFim 
      nMesTrab:= Round((dDataDeAnt - SRA->RA_ADMISSA+If(Month(dDataDeAnt)==2,2,0))/30,0)
		nMesTrab+= If(Day(SRA->RA_DEMISSA)==F_ULTDIA(SRA->RA_DEMISSA),30,Day(SRA->RA_DEMISSA)) / 30
   ElseIf SRA->RA_ADMISSA >= dDataIni .And. SRA->RA_DEMISSA <= dDataFim 
      nMesTrab:= Round((dDataDeAnt - dDataAdPro+If(Month(dDataDeAnt)==2,2,0))/30,0)
      nMesTrab+= ((30-If(Day(SRA->RA_ADMISSA)==F_ULTDIA(SRA->RA_ADMISSA),30,Day(SRA->RA_ADMISSA)))+1 )/30
		nMesTrab+= If(Day(SRA->RA_DEMISSA)==F_ULTDIA(SRA->RA_DEMISSA),30,Day(SRA->RA_DEMISSA)) / 30
   Endif   
   nAnoTrab := nMesTrab /12

	If SRA->RA_CATFUNC == "M"
		nSalDia := Round((SRA->RA_SALARIO/SRA->RA_HRSMES)*SRA->RA_HRSDIA,2)
		nSalMes := (SRA->RA_SALARIO)
	ElseIf SRA->RA_CATFUNC == "H"
		nSaldia := Round(SRA->RA_SALARIO * SRA->RA_HRSDIA,2)
		nSalMes := (SRA->RA_SALARIO * SRA->RA_HRSMES)
	ElseIf SRA->RA_CATFUNC == "D"
		nSalDia:= SRA->RA_SALARIO
		nSalMes:= SRA->RA_SALARIO * Round(SRA->RA_HRSMES/SRA->RA_HRSDIA,2)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula meses trabalhados no periodo de apuracao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SRA->RA_ADMISSA < dDataIni .And. (Empty(SRA->RA_DEMISSA) .or. SRA->RA_DEMISSA > dDataFim )
      nMesTFun := Round((dDataFim - dDataIni) / 30,0)
   ElseIf SRA->RA_ADMISSA >= dDataIni .And. (Empty(SRA->RA_DEMISSA) .or. SRA->RA_DEMISSA > dDataFim )
      nMesTFun := Round((dDataFim - dDataAdPro) / 30,0)
      nMesTFun+=  ((30 - Day(SRA->RA_ADMISSA))+1)/30
   ElseIf SRA->RA_ADMISSA < dDataIni .And.  SRA->RA_DEMISSA <= dDataFim 
      nMesTFun:= Round((dDataDeAnt - dDataIni+If(Month(dDataDeAnt)==2,2,0))/30,0)
		nMesTFun+= Day(SRA->RA_DEMISSA)/30
   ElseIf SRA->RA_ADMISSA >= dDataIni .And. SRA->RA_DEMISSA <= dDataFim 
      nMesTFun:= Round((dDataDeAnt - dDataAdPro+If(Month(dDataDeAnt)==2,2,0))/30,0)
      nMesTFun+= ((30 - Day(SRA->RA_ADMISSA))+1)/30
		nMesTFun+= Day(SRA->RA_DEMISSA)/30
   Endif   
	
   nPercFunc := nMesTFun * 100 /nMesesApur
   If nPercFunc > 0
		If nAnoTrab >= 3 
			nMonto :=((nSalDia * 60) * nPercFunc ) /100
		ElseIf nAnoTrab > 1 .And. nAnoTrab < 3 
			nMonto := ((nSalDia * 45) * nPercFunc ) /100
		ElseIf nAnoTrab <= 1
			nMonto := (nSalMes * nMesTrab) /12
		Endif
	Endif	
	nMonTotal += nMonto		
	nMonto := 0
	dbSelectArea( "SRA" )
	dbSkip()
Enddo	  

RestArea( aAreaLoc )
Return(nMonTotal)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fDiasAfast³ Autor ³ Equipe Rh - Mauro     ³ Data ³02/05/96  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Dias Afastados                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LocDiaAfas(nDiasAfas,Diastrab,dDtPesq,lSemanal)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LocDiaAfas(nDiasAfas,DiasTrab,dDtPesq,lSemanal,cPgMater,cListAfas)
Local nDias     := 0
Local nDiaAd    := 0   //Dias da Semana de Desc. Afastado
Local nDAfas_OP := 0   // Dias de afastamento por Doenca ou Acidente
Local nUltD
Local dDtUltAd 	:= CTOD("  /  /  ")
Local dDataIni
Local dDataFim

dDtPesq 	:= If (dDtPesq 	== Nil , dDataBase , dDtPesq)
lSemanal	:= If (lSemanal	== Nil , .T. , lSemanal)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variavel com ultimo dia para calculo dos afastamentos        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUltD := 30


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata Dias Trabalhados para Afastamentos e Ferias            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nDiasAfas := nDiasMat := nDiasEnf := nDiasAc := nDiasAd := nDiaAd   := nDiasFer := 0

dbSelectArea("SR8")
dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
While ! Eof() .And. SR8->R8_Filial+SR8->R8_MAT = SRA->RA_FILIAL+SRA->RA_MAT
	nDias := 0        
	If MesAno(dDtPesq)=MesAno(SR8->R8_DataIni) .Or. ;
		MesAno(dDtPesq)=MesAno(SR8->R8_DataFim) .Or. Empty(SR8->R8_DataFim) .Or.;
		MesAno(SR8->R8_DATAFIM) > MesAno(dDtPesq)
		If MesAno(SR8->R8_DataIni) = MesAno(dDtPesq) .And. MesAno(SR8->R8_DataFim) = MesAno(dDtPesq)
			If SR8->R8_TIPO $ "F|O|P|Q|Y" .AND. SRA->RA_TIPOPGT == "S"
				If cSemana == "01" 
				 	If Day(SR8->R8_DataIni) > 15
				 		nDias:=0
				 	Else
				 		nDias := If(Day(SR8->R8_DataFim) < 15,(Day(SR8->R8_DataFim) - Day(SR8->R8_DataIni))+1,(15-Day(SR8->R8_DataIni))+1)
				 		If SR8->R8_TIPO == "F"
				 			DiasTrab := 0    //Recebe dias trab junto com ferias
				 		Endif	
				 	Endif	
				ElseIf cSemana == "02"
				 	If Day(SR8->R8_DataIni) < 15 .And. Day(SR8->R8_DataFim) < 15
				 	 	nDias:= 0
				 	ElseIf Day(SR8->R8_DataIni) < 15 .And. Day(SR8->R8_DataFim) > 15 
				 		nDias := If(Day(SR8->R8_Datafim)==F_ULTDIA(dDtPesq),30-15,Day(SR8->R8_DataFim)-15)
				 	ElseIf Day(SR8->R8_DataIni) > 15 .And. Day(SR8->R8_DataFim) > 15
				 		nDias := If(Day(SR8->R8_Datafim)==F_ULTDIA(dDtPesq),(30-Day(SR8->R8_DataIni))+1,;
				 				   (Day(SR8->R8_DataFim)-Day(SR8->R8_DataIni))+1) 
				 		If SR8->R8_TIPO == "F"
				 			DiasTrab := 0    //Recebe dias trab junto com ferias
					 	Endif 	
				 	Endif	
				Endif
			ElseIf SR8->R8_TIPO $ "F|O|P|Q|Y" .AND. SRA->RA_TIPOPGT == "M"
   			nDias     := If(Day(SR8->R8_Datafim)==F_ULTDIA(dDtPesq),30,Day(SR8->R8_Datafim)) 
			Endif											
			dDataIni	:=	SR8->R8_DataINI
			dDataFim	:=	SR8->R8_DataFim
		ElseIf MesAno(SR8->R8_DataIni) = MesAno(dDtPesq)
			If SR8->R8_TIPO $ "F|O|P|Q|Y" .AND. SRA->RA_TIPOPGT == "S"
				If cSemana == "01" 
				 	If Day(SR8->R8_DataIni) > 15
				 	 	nDias:=0 
				 	Else
				 	 	nDias := (15 - Day(SR8->R8_DataIni))+1
				 		If SR8->R8_TIPO == "F"
				 			DiasTrab := 0    //Recebe dias trab junto com ferias
					 	Endif 	
					Endif	 	
				ElseIf cSemana == "02"
				 	If Day(SR8->R8_DataIni) <= 15
				 	 	nDias:= 15
				 	Else
				 	 	nDias:=nUltD - (Day(SR8->R8_DataIni)+ 1)    
				 		If SR8->R8_TIPO == "F"
				 			DiasTrab := 0    //Recebe dias trab junto com ferias
					 	Endif 	
				 	Endif 	
				Endif
			ElseIf SR8->R8_TIPO $ "F|O|P|Q|Y" .AND. SRA->RA_TIPOPGT == "M"
				nDias := 30       
			Endif											
			dDataIni		:=	SR8->R8_DataINI
			dDataFim		:=	Ctod(StrZero(F_ULTDIA(dDtPesq),2)+"/"+Strzero(Month(dDtPesq),2)+"/"+right(str(Year(dDtPesq)),2),"ddmmyy")
		ElseIf MesAno(SR8->R8_DataFim) = MesAno(dDtPesq)
			If SR8->R8_TIPO $ "F|O|P|Q|Y" .AND. SRA->RA_TIPOPGT == "S"
				If cSemana == "01" 
				 	If Day(SR8->R8_DataFim) > 15
				 	 	nDias:=15
				 	Else
				 	 	nDias := Day(SR8->R8_DataFim)
				 		If SR8->R8_TIPO == "F"
				 			DiasTrab := Round(SRA->RA_HRSMES/SRA->RA_HRSDIA,2) / 2   //Recebe dias trab junto com ferias
					 	Endif 	
				 	Endif 	
				ElseIf cSemana == "02"
				 	If Day(SR8->R8_DataFim) <= 15
				 	 	nDias:= 0
				 	Else
				 	 	nDias:= If(Day(SR8->R8_Datafim)==F_ULTDIA(dDtPesq),30-15,(Day(SR8->R8_Datafim)-15)) 
				 		If SR8->R8_TIPO == "F"
				 			DiasTrab := 0    //Recebe dias trab junto com ferias
					 	Endif 	
        			Endif
				Endif
			ElseIf SR8->R8_TIPO $ "F|O|P|Q|Y" .AND. SRA->RA_TIPOPGT == "M"
  				nDias     := Day(SR8->R8_DataFim) 
			Endif											
			dDataIni	 := (SR8->R8_DataFim - Day(SR8->R8_DataFim)) +1
			dDataFim	 := SR8->R8_DataFim
		ElseIf MesAno(SR8->R8_DataIni) < MesAno(dDtPesq) .And. Empty(SR8->R8_DataFim)
			If SR8->R8_TIPO $ "F|O|P|Q|Y" .AND. SRA->RA_TIPOPGT == "S"		
				nDias     :=  15
			ElseIf SR8->R8_TIPO $ "F|O|P|Q|Y" .AND. SRA->RA_TIPOPGT == "M"
				nDias 	 := 30
			Endif	
		ElseIf MesAno(SR8->R8_DataIni) < MesAno(dDtPesq) .And. MesAno(SR8->R8_DataFim) > MesAno(dDtPesq)
			If SR8->R8_TIPO $ "F|O|P|Q|Y" .AND. SRA->RA_TIPOPGT == "S"		
				nDias     :=  15
			ElseIf SR8->R8_TIPO $ "F|O|P|Q|Y" .AND. SRA->RA_TIPOPGT == "M"
				nDias 	 := 30
			Endif	
			dDataFim	 := Ctod(StrZero(F_ULTDIA(dDtPesq),2)+"/"+Strzero(Month(dDtPesq),2)+"/"+right(str(Year(dDtPesq)),2),"ddmmyy")
			dDataIni	 := Ctod("01/"+Strzero(Month(dDtPesq),2)+"/"+right(str(Year(dDtPesq)),2),"ddmmyy")
		EndIf
		nDias := (nDias *(Round(SRA->RA_HRSMES/SRA->RA_HRSDIA,2)) / 30)
		nDiasAfas += nDias
		nDAfas_OP += If(SR8->R8_TIPO $ "O*P", nDias, 0)
		nDiasEnf := 0

		If SR8->R8_TIPO $ "O*P" 
			If MesAno(SR8->R8_DataIni) < MesAno(dDtPesq)
				nDiasEnf := nDAfas_OP						
			Elseif MesAno(SR8->R8_DataIni) = MesAno(dDtPesq)
				nDiasEnf := nDAfas_OP						
			Endif				
		ElseIf SR8->R8_TIPO == "Q"
			nDiasMat := nDias
		   nDiasEnf := 0
		Endif
	Endif
	If SR8->R8_Tipo = "F"
		nDiasFer += nDias			
	ElseIf SR8->R8_TIPO $ "O|P|Q|Y"
		If (SR8->R8_DATAINI + 183) >= dDataBase
			If SR8->R8_TIPO $ "O|P|Y"			
				nDiasAd := nDiasEnf
			Endif	
		Endif 
	Endif
	If SR8->R8_TIPO $ 'O|P'
		dDtUltAd := SR8->R8_DATAFIM
	Endif
	
	dbSelectArea("SR8")
	dbSkip()
Enddo
//-- Abate os Dias Afastados dos Dias Trabalhados
DiasTrab -= nDiasAfas
DiasTrab := If(DiasTrab<0,0,DiasTrab)

fVarRot("DiasTrab",nDias,"A") //-- Funcao para guardar ou retornar conterudo de variavel no array aVarRot
fVarRot("DiasDsr",nDias,"A")  //-- Funcao para guardar ou retornar conterudo de variavel no array aVarRot

Return
                      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCVERFER ºAutor  ³Microsiga           º Data ³  04/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se o funcionario saiu de ferias na segunda quinze-º±±
±±º          ³ na no mes                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

FUNCTION LOCVERFER()

lPago := .F.
dbSelectArea("SR8")
dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
While ! Eof() .And. SR8->R8_Filial+SR8->R8_MAT = SRA->RA_FILIAL+SRA->RA_MAT
	If SR8->R8_TIPO = 'F'.And. MesAno(dDataBase)=MesAno(SR8->R8_DataIni) 
		If SRA->RA_TIPOPGT == "S"
			If Day(SR8->R8_DATAINI) > 15
				lPago := .T.			 				
			Endif
		Endif	
	Endif
	dbSkip()
EndDo		
Return lPago
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocDiasAv ºAutor  ³ Bruno Sobieski     ºFecha ³  01/29/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna os dias que devem ser pagos por aviso previo, e os  º±±
±±º          ³dias de saldo de salario, dado que o aviso previo comeca    º±±
±±º          ³a contar a partir do dia 1ro do proximo mes.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LocDiasAnt(dIniPer,dDataPesq,dFimPer)
Local nDias	:=	0

DEFAULT dFimPer	:=	dDataPesq

If FPHIST82( xFilial("SRX") , "68",MesAno(dDataPesq)+cSemana )
	dDataCorte	:=	CTOD(Substr(SRX->RX_TXT,7,2)+"/"+Substr(SRX->RX_TXT,5,2)+"/"+Substr(SRX->RX_TXT,1,4))
	If dDataCorte <= dIniPer
		If MesAno(dFimPer) > MesAno(dDataCorte)
			nDias		:=	F_ULTDIA(dDataCorte) - Day(dIniPer)  + 1
		Else
			nDias		:=	dFimPer - dIniPer  + 1
		Endif	
	Endif
Endif	
Return nDias

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCGratif ºAutor  ³Silvia Taguti       º Data ³  10/31/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo de Gratificacion - Chile                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocGratif()
Local nFactor 	:= 0
Local nPropFol 	:= 1
Local nGratif   := 0
Local nBaseGrat := 0
Local nValGratif:= 0
Local nMsPropAv	:= 12	//Avos Proporcionais
Local nMsPrDiA	:= 0 	//Dias Proporcionais a Admissao para funcionarios admitidos e demitidos no ano base
Local nMsPrDiD	:= 0	//Dias Proporcionais a Demissao para funcionarios admitidos e demitidos no ano base
Local nValMens	:= 0	//Valor Mensal
Local nValAvos	:= 0 	//Calculo do Valor sobre Avos
Local nValDias	:= 0 	//Calculo do Valor sobre Dias
Local nValPag	:= 0 	//Valor a Pagar
Local nTotMes	:= 0
Local dBase		:= Ctod("")
Local cCompGrt	:= ""

If SRA->RA_GRATIFI <> "1"
	Return
Endif

If FPHIST82( xFilial("SRX"), "11", MesAno(dDataBase) ) .or. ;
	FPHIST82( xFilial("SRX"), "11", "      " )
	nFactor := Val( Substr( SRX->RX_TXT, 13, 5 ) )  
	nGratif := Val( Substr( SRX->RX_TXT, 18, 6 ) )  
Else
	Return
Endif               

Aeval( aPd ,{ |X| SomaInc(X,6,@nBaseGrat,,,,,,.T.,aCodfol) })  // Incidencia IR

aGrtRlq := {}

If VAL_SALMIN > 0 .And. nFactor > 0  .And. nBaseGrat > 0

	nPropFol 	:= 1
	nValGratif	:= Round( Min( ( nBaseGrat * nGratif / 100 ), ( (Val_SalMin * nFactor) / 12 ) ), MsDecimais(1) )

	// Funcionarios admitidos e demitidos no mesmo ano da data base informada 
	If Year(SRA->RA_ADMISSA) == Year(dDataBase) .And. Year(dDataDem) ==  Year(dDataBase)
		nMsPropAv	:= DateDiffMonth( dDataDem, Max( SRA->RA_ADMISSA, Stod( StrZero( Year(dDataDem), 4 ) + "0101" ) ) )
		dBase 		:= Ctod( StrZero( f_UltDia(SRA->RA_ADMISSA), 2 ) + "/" + Substr( MesAno(SRA->RA_ADMISSA), 5, 2 ) + "/" + Substr( MesAno(SRA->RA_ADMISSA), 1, 4 ) )
		nMsPrDiA	:= DateDiffDay( SRA->RA_ADMISSA, dBase ) + 1
		dBase 		:= Ctod( StrZero( f_UltDia(dDataDem), 2 ) + "/" + Substr( MesAno(dDataDem), 5, 2 ) + "/" + Substr( MesAno(dDataDem), 1, 4 ) )
		nMsPrDiD    := DateDiffDay( dDataDem, dBase ) + 1
	// Funcionarios admitidos no mesmo ano da data base informada
	ElseIf Year(SRA->RA_ADMISSA) == Year(dDataBase)
		//Admissao no primeiro dia do mes
		If Day(SRA->RA_ADMISSA) == 1 .Or. Month(SRA->RA_ADMISSA) == Month(dDataBase)
			nMsPropAv	:= DateDiffMonth( SRA->RA_ADMISSA , dDataBase )
		Else
			nMsPropAv	:= DateDiffMonth( SRA->RA_ADMISSA , dDataBase ) 
			dBase 		:= Ctod( StrZero( f_UltDia(SRA->RA_ADMISSA), 2 ) + "/" + Substr( MesAno(SRA->RA_ADMISSA), 5, 2 ) + "/" + Substr( MesAno(SRA->RA_ADMISSA), 1, 4 ) )
			nMsPrDiA	:= DateDiffDay( SRA->RA_ADMISSA, dBase ) + 1
		EndIf
	// Funcionarios demitidos no mesmo ano da data base informada
	ElseIf Year(dDataDem) == Year(dDataBase)
		If Day(dDataDem) < f_UltDia(dDataDem) // Demissao menor que o ultimo dia do mes
			nMsPropAv	:= DateDiffMonth( dDataDem , Max( SRA->RA_ADMISSA, Stod( Strzero( Year(dDataDem), 4 ) + "0101" ) ) )
			dBase 		:= Ctod( StrZero( f_UltDia(dDataDem), 2 ) + "/" + Substr( MesAno(dDataDem), 5, 2 ) + "/" + Substr( MesAno(dDataDem), 1, 4 ) )
			nMsPrDiD	:= DateDiffDay( dDataDem, dBase ) + 1 
		Else // Demissao no ultimo dia do mes
			nMsPropAv	:= DateDiffMonth( dDataDem , Max( SRA->RA_ADMISSA, Stod( StrZero( Year(dDataDem), 4 ) + "0101" ) ) ) + 1
		EndIf
   	EndIf

	// Calcula gratificacao total
	nValMens	:= nValGratif
	nValAvos	:= nValMens * nMsPropAv
	nValDias	:= nValMens / 30
	nValPag		:= nValAvos + ( nValDias * ( nMsPrDiA + nMsPrDiD ) )
	nValGratif	:= nValPag
    If nValPag > nValMens 
    	nValGratif	:= 	nValMens
	EndIf
	
	// Monta ultima competencia de referencia de calculo da gratificacao
	If Empty(dDataDem)
		cCompGrt	:= Left( MesAno(dDatabase), 4 ) + "12"
	Else
		cCompGrt	:= Alltrim( Str( Min( Val( MesAno(dDataDem) ), Val( Left( MesAno(dDatabase), 4 ) + "12" ) ) ) )
	EndIf
	
	// Total de meses sobre os quais foi calculada a gratificacao
	nTotMes		:= nMsPropAv + Min( nMsPrDiA, 1 ) + Min( nMsPrDiD, 1 )

	// Alimenta array com valores da gratificacao por competencia para uso na reliquidacao - LOCRELIQ()
	While nTotMes > 0
	
		aAdd( aGrtRlq, { cCompGrt, 0 } )
		
		If cCompGrt == MesAno(dDataDem) .And. nMsPrDiD > 0
			aGrtRlq[ Len(aGrtRlq), 2 ] := nValDias * nMsPrDiD
		ElseIf cCompGrt == MesAno(SRA->RA_ADMISSA) .And. nMsPrDiA > 0
			aGrtRlq[ Len(aGrtRlq), 2 ] := nValDias * nMsPrDiA
		Else
			aGrtRlq[ Len(aGrtRlq), 2 ] := nValMens
		EndIf
		
		cCompGrt := SubMesAno(cCompGrt)
		nTotMes--
	EndDo
	
	aSort( aGrtRlq, , , { |x,y| x[1] < y[1] } ) // Ordena do menor para o maior mes/ano.
	   	
	If c__Roteiro $ "FOL/ADI"
		FGeraVerba( aCodFol[368,1], Round( nValGratif, MsDecimais(1) ) )
	ElseIf c__Roteiro == "FER"
		nPropFol := M->RH_DFERIAS / 30
		FGeraVerba( aCodFol[369,1], Round( Min( ( nBaseGrat * nGratif / 100 * nPropFol ), ( Val_SalMin * nFactor / 12 * nPropFol ) ), MsDecimais(1) ), 0 )
	ElseIf c__Roteiro == "RES"
		FGeraVerba( aCodFol[370,1], Round( nValGratif, MsDecimais(1) ) )
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCDIARES ºAutor  ³Microsiga           º Data ³  05/29/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Dias Trabalhados na rescisao                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                        
Function LOCDIARES()

If SRA->RA_CATFUNC$ "M*C" .And. SRA->RA_TIPOPGT == "M" 
	DiasTrab := If(Day(dDatadem)==F_ULTDIA(dDataBase),30,Day(dDatadem)) 
ElseIf SRA->RA_CATFUNC$ "M*C" .And. SRA->RA_TIPOPGT == "S" 
	If cSemana == "01" 
		If Day(dDataDem) <= 15
	 		DiaTrab:= Day(dDataDem)
		Else
			DiasTrab := Day(dDataDem)-15
		Endif	
	ElseIf cSemana == "02"
		DiasTrab := Day(dDataDem)-15
	Endif	
Endif

DiasTrab := (DiasTrab * Round(SRA->RA_HRSMES/SRA->RA_HRSDIA,2)) /30

Return	
	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocVerbaSaºAutor  ³Microsiga           º Data ³  05/31/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava Verba de Base de Salario para acumulacao no 13salarioº±±
±±º          ³ da Republica Dominicana                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                                                                                     
Function LocVerbaSal()

Local nDias := 0

If MesAno(dDataBase)==MesAno(SRA->RA_ADMISSA)
  	If SRA->RA_TIPOPGT == "M"
  		nDias := (30 - Day(SRA->RA_ADMISSA)) *(Round(SRA->RA_HRSMES/SRA->RA_HRSDIA,2))/30
	Else
		If cSemana == "01" 
		 	If Day(SRA->RA_ADMISSA) > 15
				nDias := 0
			Else
			 	nDias := (15 - Day(SRA->RA_ADMISSA) + 1) *(Round(SRA->RA_HRSMES/SRA->RA_HRSDIA,2))/30
			Endif
		ElseIf cSemana == "02"
		 	If Day(SRA->RA_ADMISSA) <= 15
				nDias := Round(SRA->RA_HRSMES/SRA->RA_HRSDIA,2) / 2
			Else
				nDias := (30 - Day(SRA->RA_ADMISSA) + 1	) *(Round(SRA->RA_HRSMES/SRA->RA_HRSDIA,2))/30
			Endif	
		Else
			nDias := 0
		Endif 	 	
  	Endif 
  	fGeraVerba(aCodFol[318,1],SalDia*nDias)
Else
	fGeraVerba(aCodFol[318,1],SalMes/2)
Endif	  	
  			
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCACURES ºAutor  ³Microsiga           º Data ³  06/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava Valores da Rescisao no SRC para Fechamento            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
                        
Function LOCACURES()

dbSelectArea( "SRR" )
IF SRR->( dbSeek( SRA->( RA_FILIAL + RA_MAT ) ) )
	While SRR->( !Eof() .and. SRA->( RA_FILIAL + RA_MAT ) == RR_FILIAL + RR_MAT )
		dbSelectArea( "SRC" )
		RecLock( "SRC" , .T. )
		SRC->RC_FILIAL  := SRR->RR_FILIAL
		SRC->RC_MAT     := SRR->RR_MAT
		SRC->RC_PD      := SRR->RR_PD
		SRC->RC_DATA    := SRR->RR_DATAPAG   
		SRC->RC_TIPO1   := SRR->RR_TIPO1
		SRC->RC_TIPO2   := SRR->RR_TIPO2
		SRC->RC_HORAS   := SRR->RR_HORAS
		SRC->RC_VALOR   := SRR->RR_VALOR
		SRC->RC_SEMANA  := SRR->RR_SEMANA
		SRC->RC_CC		:= SRR->RR_CC
		MsUnlock()
		dbSelectarea( "SRR" )
		dbSkip()
	Enddo
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCLiqAdtoºAutor  ³Bruno Sobieski      º Data ³  13/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula valor base de calculo liquido para adiantamento do  º±±
±±º          ³ CHILE                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM010                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocLiqSal()
Local nRet	:=	0
Local nX	:=	0

For	nX:=1  To Len(aPd)
	If aPd[nX][9] <> "D"
		PosSrv(aPD[nX][1],SRA->RA_FILIAL)
		If SRV->RV_TIPOCOD == "1" // PROVENTO
			nRet	+=	aPd[nX][5]
		ElseIf SRV->RV_TIPOCOD == "2" // DESCONTO
			nRet 	-=	aPd[nX][5]
		Endif	
	Endif
Next

Return nRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCSOMA   ºAutor  ³Microsiga           º Data ³  10/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adiciona a verba no array que sera gravado no arquivo SRZ  º±±
±±º          ³ Uruguai                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOCCMURU                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LocSoma(cCod,nVal2,aBase)

If cCod # Space(3) .And. nVal2 # 0
	//-- Array Filial
	nRet := aScan( aBase,{|X| x[1] == cCod } )   // Testa se ja existe
	If nRet == 0
		Aadd(aBase,{cCod,0.00,nVal2,0.00,1})      // se nao cria elemento
	Else
		aBase[nRet,3] += nVal2
		aBase[nRet,5] ++
	Endif
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCATSER  ºAutor  ³Microsiga           º Data ³  10/03/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula o Adicional por Tempo de Servico - Uruguai          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                        
Function LOCATSER()

Local nMesI
Local nAnoI
Local cDataI 
Local nMesF  
Local nAnoF  
Local cDataF 
Local dDataIni 
Local nAvanco
Local aMeses 	:= {}
Local nAnoTrab 	:= 0                                             
Local nPercAd  	:= 0
Local aPrima   	:= {} 
Local nBaseCalc := 0
Local nValPrima := 0
Local nX		:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para funcion rios que recebem semanalmente, deve ser calculado  ³
//³ somente na £ltima semana do mˆs                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If c__Roteiro == "FOL" .And. SRA->RA_TIPOPGT = "S" .And. ! lUltSemana
	Return( .T. )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna se "N" contido em RA_ADTPOSER (nao tem adicional)	    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If "N" $ SRA->RA_ADTPOSE
	Return( .T. )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Base de Calculo para Prima Antiguedad tipo "Base" ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aeval( aPd ,{ |X| SomaInc(X,19,@nBaseCalc, , , , , ,.T.,aCodFol) })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcular Dias, Meses e Anos Trabalhado                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nMesI    := Month(SRA->RA_ADMISSA)
nAnoI    := Year(SRA->RA_ADMISSA)
cDataI   := StrZero(nAnoI,4) + StrZero(nMesI,2)
nMesF    := If(c__Roteiro == "RES",Month(dDataDem),Month(dDataBase))
nAnoF    := If(c__Roteiro == "RES",Year(dDataDem),Year(dDataBase))
cDataF   := StrZero(nAnoF,4) + StrZero(nMesF,2)
dDataIni := SRA->RA_ADMISSA
	
While cDataI != cDataF
	nAvanco  := 1 + (Day(LastDay(dDataIni))-Day(dDataIni))
	dDataIni := dDataIni+nAvanco
	AADD(aMeses,dDataIni)
	nMesI    := nMesI + 1
	IF nMesI > 12
		nMesI := 1
		nAnoI := nAnoI + 1
	EndIF
	cDataI := StrZero(nAnoI,4) + StrZero(nMesI,2)
Enddo
nAnoTrab := ( Len(aMeses) / 12 )
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso o funcionario tenha mais de um ano de trabalho, calcular a Prima Antiguedad³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Int(nAnoTrab) > 0
	If FPHIST82(xFilial("SRX") , "76") 
		SRX->(dbsetorder(1))
		While SRX->RX_TIP == "76"
			AAdd(aPrima,{Substr(SRX->RX_COD,1,2),Substr(SRX->RX_COD,3,2),Substr(SRX->RX_TXT,1,1),;
			     Substr(SRX->RX_TXT,2,6),If(!Empty(Substr(SRX->RX_TXT,8,12)),Substr(SRX->RX_TXT,8,12),"0")})
			SRX->(DbSkip())
		Enddo
      //Ano Trab. Inicial
      //Ano Trab.Final
      //Tipo de Calculo F/M/B
      //Aliquota
      //Valor Fixo
  	Endif
   For nx:= 1 to Len(aPrima)
   	If Int(nAnoTrab) >= Val(aPrima[nX][01]) .And. Int(nAnoTrab) <=Val(aPrima[nX][02])
	   	If aPrima[nx][03] == "F"                                         //Valor Fixo
	   		nValPrima := Val(aPrima[nX][05]) * Int(nAnoTrab) 
	   		nPercAd   := 0
	   	ElseIf aPrima[nX][03] == "M"                                     //Salario minimo
	   		nValPrima:= (VAL_SALMIN * Val(aPrima[nX][04])) / 100
	   		nPercAd  :=Val(aPrima[nX][04]) 
	   	ElseIf aPrima[nX][03] == "B"                                     //Base de calculo
	   		nValPrima := (nBaseCalc * Val(aPrima[nX][04])) / 100	
	   		nPercAd  :=Val(aPrima[nX][04]) 
	   	Endif
	   Endif
	Next  
	If nValPrima > 0
		FGeraVerba(aCodFol[001,1],nValPrima,nPercAd)
	Endif	
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MEDHRSFER ºAutor  ³Microsiga           º Data ³  10/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Horas Extras e Adicionais do funcionario                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MedHrsFer(aMediaFer,nMediaOut,nTipo)

Local lHrFeriado := .F.
Default nTipo := 3

DbSelectArea(cTBLXMED)
dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
If nTipo == 1
	While !Eof() .And. SRA->RA_FILIAL+SRA->RA_MAT == (cTBLXMED)->RP_FILIAL+(cTBLXMED)->RP_MAT
		If (cTBLXMED)->RP_TIPO == "1" .And. (cTBLXMED)->RP_PD <> "999" .And. Alltrim((cTBLXMED)->RP_DATARQ) == "9998"
			If (cTBLXMED)->RP_PD <> Space(3)
				PosSrv((cTBLXMED)->RP_PD,(cTBLXMED)->RP_FILIAL) 
				lHrFeriado := If((cTBLXMED)->RP_PD == aCodFol[311,1],.T.,.F.)
      		Aadd( aMediaFer, { (cTBLXMED)->RP_HORAS*If(lHrFeriado,(SRA->RA_HRSMES /25),1), SRV->RV_PERC,(cTBLXMED)->RP_TIPO } )
			Endif	
		Endif
	   dbSkip()
	Enddo 
ElseIf nTipo == 2
	While !Eof() .And. SRA->RA_FILIAL+SRA->RA_MAT == (cTBLXMED)->RP_FILIAL+(cTBLXMED)->RP_MAT
		If (cTBLXMED)->RP_TIPO == "2" .And. (cTBLXMED)->RP_PD <> "999" .And. Alltrim((cTBLXMED)->RP_DATARQ) == "9998"
			If (cTBLXMED)->RP_PD <> Space(3)
				PosSrv((cTBLXMED)->RP_PD,(cTBLXMED)->RP_FILIAL) 
				lHrFeriado := If((cTBLXMED)->RP_PD == aCodFol[311,1],.T.,.F.)
      		Aadd( aMediaFer, { (cTBLXMED)->RP_HORAS*If(lHrFeriado,(SRA->RA_HRSMES /25),1), SRV->RV_PERC,(cTBLXMED)->RP_TIPO } )
			Endif	
		Endif
	   dbSkip()
	Enddo                     
Else	
	While !Eof() .And. SRA->RA_FILIAL+SRA->RA_MAT == (cTBLXMED)->RP_FILIAL+(cTBLXMED)->RP_MAT
		If (cTBLXMED)->RP_TIPO $ "1|2" .And. (cTBLXMED)->RP_PD <> "999" .And. Alltrim((cTBLXMED)->RP_DATARQ) == "9998"
			If (cTBLXMED)->RP_PD <> Space(3)
				PosSrv((cTBLXMED)->RP_PD,(cTBLXMED)->RP_FILIAL) 
				lHrFeriado := If((cTBLXMED)->RP_PD == aCodFol[311,1],.T.,.F.)
      		Aadd( aMediaFer, { (cTBLXMED)->RP_HORAS*If(lHrFeriado,(SRA->RA_HRSMES /25),1), SRV->RV_PERC,(cTBLXMED)->RP_TIPO } )
			Endif	
		Endif
	   dbSkip()
	Enddo                     
Endif	
      
If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"1"+"999"+"97MD")   // Outros Adic.
	nMediaOut := (cTBLXMED)->RP_VALATU
Elseif dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"2"+"999"+"97MD")  //.And.;
	nMediaOut := (cTBLXMED)->RP_VALATU
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIASNODESCºAutor  ³Silvia Taguti       º Data ³  10/14/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo de dias Nao descontados - Uruguai                  º±±
±±º          ³ Afastamento sem remuneracao                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                   
Function DiasNoDesc(dIni,dFim,nDiasN)
                          
Local cDtIni
Local dDtIni 
Local cDtFim
Local dDtFim 

dbSelectArea("SR8")
dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
While ! Eof() .And. SR8->R8_FILIAL+SR8->R8_MAT == SRA->RA_FILIAL+SRA->RA_MAT
	If ( MesAno(SR8->R8_DATAINI) >= MesAno(dIni)  .And. ;
		  MesAno(SR8->R8_DATAINI) <= MesAno(dFim) ) .Or. ;
		( MesAno(SR8->R8_DATAFIM) >= MesAno(dIni)  .And. ;
   	  MesAno(SR8->R8_DATAFIM) <= MesAno(dFim) ) .Or. ;
	   ( MesAno(SR8->R8_DATAINI) <= MesAno(dIni)  .And. ;
   	  MesAno(SR8->R8_DATAFIM) >= MesAno(dFim) ) .Or. ;
			Empty(SR8->R8_DATAFIM)
  		If SR8->R8_TIPO == "X"          //Sin Remuneracion
			dDtIni := SR8->R8_DATAINI
			dDtIni := If(dDtIni < dIni ,dIni,dDtIni )
			dDtFim := If(SR8->R8_DATAFIM > dFim .Or. Empty(SR8->R8_DATAFIM),dFim,SR8->R8_DATAFIM )
			cDtIni := MesAno(dDtIni)
			cDtFim := MesAno(dDtFim)
  			nDiasN += (dDtFim - dDtIni) + 1
		Endif
	Endif
	DbSkip()
Enddo

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCADEAGUIºAutor  ³Silvia Taguti       º Data ³  10/27/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca verba de Adiantamento de 13o.(Especie)               º±±
±±º          ³ Gera verba de desconto de adiantamento 13o.(Especie)-URU   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
                                                                   
Function LocAdeAgui()
Local nPos
Local nDescAgui:= 0

//Busca se existe uma verba de adiantamento de 13o. Salario em especie
nPos := Ascan(aPd,{ |x| x[1] == aCodfol[363,1] } )

//Caso encontre a verba, gera uma verba de desconto que sera utilizada no calculo de 13o.
//Estas verbas nao devem possuir nenhuma incidencia.
If nPos > 0 .And. aPd[nPos,9] <> "D"
   nDescAgui := aPd[nPos,5]
	FGeraVerba(aCodFol[364,1],nDescAgui,0)
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCSUSCAR ºAutor  ³Silvia Taguti       º Data ³  10/28/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo de Sustutivo de Carne - Uruguai                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
                                                      
Function LocSuscar(nTipo)
                
Local nTetoSCarne 	:= 0
Local nTetoHrTrab 	:= 0
Local nTotHrs 		:= 0
Local nVlrSust		:= 0  
Local nSusVac 		:= 0   
Local nTotDes := 0
Local nX			:= 0
Local nDiasFer := 0
Local nDiasVen := 0
Local nDiasPro := 0
Local nDias    := 0      
Local nHrFeria := 0
Local nHoraDia := 0   

If SRA->RA_TIPOPGT == "S" .And. !lUltSemana .And. c__Roteiro == "FOL"
	Return
EndIf

If SRA->RA_SUSCARN <> "1"
	Return
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega valores do sustutivo de carne³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FPHIST82(xFilial("SRX"),"77",MesAno(dDataBase)) .Or. FPHIST82(xFilial("SRX"),"77","      ")
	nTetoSCarne:= Val(Substr(SRX->RX_TXT, 1,12))
	nTetoHrTrab  := Val(Substr(SRX->RX_TXT,13,12))
Else
	Return ( .F. )
Endif                                          
//Calcula quantidade de horas trabalhadas pelo funcionario por dia
nHoraDia := SRA->RA_HRSMES / If(SRA->RA_CATFUNC == "H", 25 , 30)
If nTipo == 1
	For nX:=1 to Len(aPd)  //Verificar as horas trabalhadas no mes do calculo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ N„o deve valorizar verbas Deletadas ou semanas superiores ao calculo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aPd[nX,9] == "D" .or. aPd[nX,3] > cSemana
			Loop
		EndIf
		If PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_SUSCARN") $ "S"
			If PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_TIPOCOD") == "1"
				If aPd[nX,6] == 'H' .And. aPd[nX,4] > 0
					nTotHrs+= aPd[nX,4]
				ElseIf aPd[nX,6] <> 'H' .And. aPd[nX,4] > 0
					nTotHrs+= (SRA->RA_HRSMES/30) * aPd[nX,4] //transf. dias em horas
				Endif
			ElseIf PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_TIPOCOD") == "2"
				If aPd[nX,6] == 'H' .And. aPd[nX,4] > 0
					nTotHrs-= aPd[nX,4]
				ElseIf aPd[nX,6] <> 'H' .And. aPd[nX,4] > 0
					nTotHrs-= (SRA->RA_HRSMES/30) * aPd[nX,4]  //transf. dias em horas
				Endif
			Endif
		Endif
	Next
	//Verifica se existe hora feriado e transforma dia em horas    
	If SRA->RA_CATFUNC $ "H"
		If (nPos:= Ascan(aPd, { |X| X[1] = aCodfol[311,1] .And. X[9] # "D"})) > 0
			nHrFeria := (SRA->RA_HRSMES /25) * aPd[nPos,4]
			nTotHrs+= nHrFeria
		Endif
	Endif	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a existencia de Sustutivo de Carne no calculo de ferias³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SRH")
	dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
	While !Eof() .And. SRA->RA_FILIAL+SRA->RA_MAT == SRH->RH_FILIAL+SRH->RH_MAT
		If Month(SRH->RH_DATAINI)==Month(dDatabase) .And. Year(SRH->RH_DATAINI) == Year(dDatabase)
			dbSelectArea("SRR")
			dBSetOrder(1)
			If dbSeek( SRA->RA_FILIAL+SRA->RA_MAT+'F'+Dtos(SRH->RH_DTRECIB) )
				While !Eof() .And. SRA->RA_FILIAL+SRA->RA_MAT == SRR->RR_FILIAL+SRR->RR_MAT ;
					.And. SRH->RH_DTRECIB == SRR->RR_DATA .And. SRR->RR_TIPO3 == 'F'
           		If SRR->RR_PD == aCodfol[366,1]  //Sustutivo de Carne - Vacaciones
           			nSusVac := SRR->RR_VALOR
           		Endif
					dbSelectArea("SRR")
           		dbSkip()
           	Enddo
			Endif           			
      Endif
		dbSelectArea("SRH")
      dbSkip()
   Enddo 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso o funcionario ja tenha recebido o sustutivo de carne nas ferias, ³
	//³a soma desse sustutivo com o do mes nao deve ultrapassar o teto.      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTotHrs > 0 
		If nTotHrs >= nTetoHrTrab //Se as hrs trabalhadas ultrapassar o teto de horas      
		   nTotHrs := nTetoHrTrab //deve ser utilizada o teto
		Endif 
		nVlrSust := (nTetoSCarne / nTetoHrTrab) * nTotHrs
		If nSusVac + nVlrSust > nTetoSCarne
			FGeraVerba(aCodFol[365,1],nTetoSCarne - nSusVac)
		Else	
			FGeraVerba(aCodFol[365,1],nVlrSust)
		Endif
	Endif
Elseif nTipo == 2 .or. nTipo == 3 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula os dias de Feriados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipo == 2
	   //Verifica se houve faltas no descontables(Sin Citacion) para entrar no calculo
   	DiasNoDesc(M->RH_DATABAS,Ctod('31/12/'+StrZero(Year(M->RH_DATABAS))),@nDiasFer)
	ElseIf nTipo == 3                                                                  
		If M->RG_DFERVEN > 0
   		DiasNoDesc(SRF->RF_DATABAS,Ctod('31/12/'+StrZero(Year(SRF->RF_DATABAS))),@nDiasVen)
	   Endif
		If M->RG_DFERPRO > 0
   		DiasNoDesc(Ctod('01/01/'+StrZero(Year(M->RG_DATADEM))),Ctod('31/12/'+StrZero(Year(M->RG_DATADEM))),@nDiasPro)
	   Endif
	Endif
	If If(nTipo == 2,M->RH_DFERIAS,(M->RG_DFERVEN+M->RG_DFERPRO)) > 0 
		//Sustutivo de Carne - Licencia
		nTotHrs := If(nTipo == 2,(M->RH_DFERIAS+nDiasFer),(M->RG_DFERVEN+M->RG_DFERPRO+nDiasVen+nDiasPro)) * nHoraDia
		If nTotHrs >= nTetoHrTrab //Se as hrs de ferias ultrapassarem o teto de horas      
		   nTotHrs := nTetoHrTrab //devera ser utilizada o teto
		Endif 
		nVlrSust := (nTetoSCarne / nTetoHrTrab) * nTotHrs
		If nVlrSust > nTetoSCarne
			nVlrSust := nTetoSCarne
		Endif
		nSusMens := nVlrSust     //Variavel sera utilizada no calculo do salario vacacional
	   //Para mensalistas o sustutivo eh pago na folha 
		If nTipo == 2
			If (lPagFerSe .And. SRA->RA_CATFUNC == "M") .or. SRA->RA_CATFUNC <> "M" .or. nTipo == 3
				FGeraVerba(aCodFol[366,1],Round(nVlrSust,MsDecimais(1))) 
			Endif	
		Else
			FGeraVerba(aCodFol[404,1],Round(nVlrSust,MsDecimais(1))) 
		Endif	
	Endif
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCSALVAC ºAutor  ³Silvia Taguti       º Data ³  12/04/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula o Valor do Desconto para Salario Vacacional        º±±
±±º          ³ Uruguai                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                      
Function LocSalVac()

Local nPos        := 0
Local nSalFerVenc := 0
Local nSalFerProp := 0
Local nVlrDesc    := 0   
Local nBaseIrp    := 0
Local nPercIr     := 0
Local nX          := 0  
Local nTpDesc     := 0
Local nBaseDed 	:= 0                  
Local nVlImp		:= 0
Local nVlDedImp	:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Apos 072007, segue nova legislação do calculo de IR para o Uruguai³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If MesAno(dDataBase) < "200707"	
	Aeval( aPd ,{ |X| SomaInc(X,5,@nBaseIrp,11,"S",,,,.F.,aCodfol) })  // Incidencia Irp Ferias
Else
	Aeval( aPd ,{ |X| SomaInc(X,5,@nBaseIrp,27,"1",11,"S",,.F.,aCodfol) })  // Incidencia Irp Ferias
	Aeval( aPd ,{ |X| SomaInc(X,5,@nBaseDed,27,"2",11,"S",,.F.,aCodfol) })  // Incidencia Irp Ferias
	nBaseDed *= (-1)
Endif	

//Se o calculo das ferias for junto com a folha, somar as ferias e outras verbas para 
//o percentual que sera aplicado no salario vacacional
If !lPagFerSe .And. SRA->RA_CATFUNC == "M"
	If PosSrv(aCodFol[072,1],SRA->RA_FILIAL,"RV_IR") == "S" .And. c__Roteiro == "FER"
		nBaseIrp += nVacMens
	Endif
	If PosSrv(aCodFol[366,1],SRA->RA_FILIAL,"RV_IR") == "S"
		nBaseIrp += nSusMens
	Endif
Endif    
//As verbas de Ferias Vencidas/Prop. entram na base para IRP do Salario Vacacional
//mas as proprias verbas nao pagam IRP, nao podem ter incidencia
If c__Roteiro == "RES"
	For nX:=1	To Len(aPd)
		If (aPd[nX,1] == aCodfol[86,1] .or. aPd[nX,1]==aCodfol[87,1]) .And. aPd[nX,3] == cSemana .And. aPd[nX,9] # "D"
			nBaseIrp	+=	aPd[nX,5]
		Endif
	Next
Endif	

If nBaseIrp > 0
	If MesAno(dDataBase) < "200707"	
		nPos	:=	1
		While nPos	<= Len(aIR) - 1
			If  (nBaseIRP <= aIR[nPos][01])
				nPercIR := aIR[nPos][02] * 100
				Exit
			Endif
			nPos++
		Enddo
	Else 
		If nBaseIrp > 0
		 	LocIRPFCalc(nBaseIrp, aIR, @nVlImp)
		Endif 	
		If nBaseDed > 0
		 	LocIRPFCalc(nBaseDed, aIRDed, @nVlDedImp)
		Endif 	
	Endif	
Endif
If SRA->RA_SALARIO > (Val_SalMin * 2.5)
	dbSelectArea( "SRB" )
	dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
	//Verificar se existe dependentes
	While !Eof() .And. SRB->RB_FILIAL + SRB->RB_MAT == SRA->RA_FILIAL + SRA->RA_MAT
		If (SRB->RB_GRAUPAR == "F")
			If DateDiffYear(SRB->RB_DTNASC,dDataBase) < 18 .Or. DateDiffYear(SRB->RB_DTNASC,dDataBase) > 18 .And. (SRB->RB_TIPIR == "1")
				nTpDesc := nFonasDep //Se apenas um atender a condicao o valor sera aplicado
				Exit
 			Endif
		Endif
		dbSkip()
	Enddo	
Else
	nTpDesc	:= nFonasSM  //Sem dependentes e menor de 2.5 Salarios Minimos
Endif

nVlrDesc := (nBpsFunc+nFrlFunc+nTpDesc+nPercIr) / 100

If c__Roteiro == "FER"
	//Gera Salario Vacacional - Ferias
	If nVacMens > 0
		FGeraVerba(aCodFol[077,1],Round(nVacMens-(nVacMens*nVlrDesc)-(nVlImp-nVlDedImp),MsDecimais(1)),M->RH_DFERIAS)
	Endif	 
Endif	 

//Gera a Media de Horas - Salario Vacacional
nPos := Ascan(aPd,{ |x| x[1] == aCodfol[82,1] } )
If nPos > 0 .And. aPd[nPos,9] <> "D"
	FGeraVerba(aCodFol[361,1],Round(aPd[nPos,5]-(aPd[nPos,5]*nVlrDesc),MsDecimais(1)),aPd[nPos,4] )
Endif	 

//Gera Media de Horas Extras - Ferias Vencidas - Salario Vacacional
nPos := Ascan(aPd,{ |x| x[1] == aCodfol[248,1] } )
If nPos > 0 .And. aPd[nPos,9] <> "D"
	FGeraVerba(aCodFol[371,1],Round(aPd[nPos,5]-(aPd[nPos,5]*nVlrDesc),MsDecimais(1)),aPd[nPos,4] )
Endif	 
//Gera Media de Horas Extras - Salario Vacacional
nPos := Ascan(aPd,{ |x| x[1] == aCodfol[249,1] } )
If nPos > 0 .And. aPd[nPos,9] <> "D"
	FGeraVerba(aCodFol[372,1],Round(aPd[nPos,5]-(aPd[nPos,5]*nVlrDesc),MsDecimais(1)),aPd[nPos,4] )
Endif	 
                                  
//Gera Salario Vacacional - Ferias Vencidas/Proporcionais
nPos := Ascan(aPd,{ |x| x[1] == aCodfol[086,1] } )
If nPos > 0 .And. aPd[nPos,9] <> "D"
	nSalFerVenc := aPd[nPos,5] 
Endif
nPos := Ascan(aPd,{ |x| x[1] == aCodfol[87,1] } )
If nPos > 0 .And. aPd[nPos,9] <> "D"
	nSalFerProp := aPd[nPos,5] 
Endif
FGeraVerba(aCodFol[125,1],Round((nSalFerVenc+nSalFerProp)-((nSalFerVenc+nSalFerProp)*nVlrDesc),MsDecimais(1)) )

//Sustutivo de Carne - Salario Vacacional
If nSusMens > 0
	FGeraVerba(aCodFol[367,1],Round(nSusMens-(nSusMens*nVlrDesc),MsDecimais(1)) )
Endif	 

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCTOTCON ºAutor  ³Silvia Taguti       º Data ³  12/08/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ GERA AS VERBAS DE BASES - CHILE                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                             
Function LocTotCon()

Local nTotDesc 	:= 0
Local nTotProv 	:= 0
Local nDesImp	:= 0
Local nDesNoImp	:= 0
Local nHabImp	:= 0
Local nHabNoImp	:= 0
Local aTot     	:=	ARRAY(7)
Local nX     	:= 0

If FPHIST82(xFilial("SRX") , "70" )
	aTot[1] := SubStr( SRX->RX_TXT , 01, 3 )
	aTot[2] := SubStr( SRX->RX_TXT , 04, 3 )
	aTot[3] := SubStr( SRX->RX_TXT , 07, 3 )
	aTot[4] := SubStr( SRX->RX_TXT , 10, 3 )
	aTot[5] := SubStr( SRX->RX_TXT , 13, 3 )
	aTot[6] := SubStr( SRX->RX_TXT , 16, 3 )
	aTot[7] := SubStr( SRX->RX_TXT , 19, 3 )
Else
	If GetRemoteType() == -1
		MsgLogGrid( Ap5GetHelp("GPEXTOTCON"), .F. ) // Retornar string da funcao Help
	Else
		Help(" ",1,"GPEXTOTCON")
	EndIf
	Return(.F.)
Endif              

For nX := 1 to Len(aPd)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ N„o deve valorizar verbas de outras semanas ou Verbas Deletadas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aPd[nX,3] # cSemana .Or. aPd[nX,9] == "D"
		Loop
	EndIf

	If PosSrv( aPd[nX,1], SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
		nTotProv += aPd[nX,5]
		If PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_IR") == "S"
			If cPaisLoc == "CHI" .And. !Empty( aARlqPd ) .And. ( nPos := aScan( aARlqPd, { |x| x[1] == aPd[nX,1] } ) ) > 0
				nHabImp += aARlqPd[ nPos, 2 ] // Soma valor de apenas 1 avo
			Else
				nHabImp += aPd[nX,5]
			EndIf
		Else                   
			nHabNoImp += aPd[nX,5]		
		Endif
	ElseIf PosSrv( aPd[nX,1], SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"
		nTotDesc += aPd[nX,5]
		If PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_IR") == "S"
			nDesImp += aPd[nX,5]
		Else                   
			nDesNoImp += aPd[nX,5]		
		Endif
	Endif
Next	

fGeraVerba(aTot[1],Round(nTotProv,MsDecimais(1)),,,,,,,,,.F.)
fGeraVerba(aTot[2],Round(nHabImp,MsDecimais(1)),,,,,,,,,.F.)
fGeraVerba(aTot[3],Round(nHabNoImp,MsDecimais(1)),,,,,,,,,.F.)
fGeraVerba(aTot[4],Round(nTotDesc,MsDecimais(1)),,,,,,,,,.F.)
fGeraVerba(aTot[5],Round(nDesImp,MsDecimais(1)),,,,,,,,,.F.)
fGeraVerba(aTot[6],Round(nDesNoImp,MsDecimais(1)),,,,,,,,,.F.)
fGeraVerba(aTot[7],Round(nTotProv - nDesImp,MsDecimais(1)),,,,,,,,,.F.)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetIPC    ºAutor  ³Bruno Sobieski      ºFecha ³  01/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pegar os indices de IPC entre duas datas                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetIPC(aIPC,cDataIni,cDataFim)  
Local cMes	:=	SubStr(cDataIni,5,2)
Local cAno	:=	SubStr(cDataIni,1,4)
Local lOk	:=	.T.
Local nIPC  := 0
aIPC	:=	{}                       

If cMes == '01'
	cMes 	:= '12'
	cAno	:= Tira1(cAno)
Else
	cMes	:= Tira1(cMes)
Endif	
//No aIPC os fatores ficaram desfasados um 1 mes, porque no calculo sempre se utiliza o fator do mes anterior,
//assim no mes 02/2003 estara o indice de 01/2003
DbSelectArea('SRX')
DbSetOrder(1)
DbSeek(xFilial("SRX") + "64" + cAno+cMes,.T.)
While RX_FILIAL == xFilial("SRX") .And. Substr(RX_COD,1,6)<cDataFim .And. lOk
	If Substr(RX_COD,1,6) == cAno+cMes
		If cMes == '12'
			cMes	:=	'01'
			cAno	:=	Soma1(cAno)
		Else
			cMes	:=	Soma1(cMes)
		Endif		             
		//Se o fator do IPC for menor ou igual a zero, deve considerar como 1		             
		nIPC := If(Val(SubStr( SRX->RX_TXT , 37, 18 )) > 0,Val(SubStr( SRX->RX_TXT , 37, 18 )),1)
		AAdd(aIPC,{cAno+cMes,nIPC})
	Else
		If cMes == '12'
			cMes	:=	'01'
			cAno	:=	Soma1(cAno)
		Else
			cMes	:=	Soma1(cMes)
		Endif		             
		AAdd(aIPC,{cAno+cMes,0})	
		lOk	:=	.F.
	Endif	         
	DbSkip()
Enddo

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetRemVarD ºAutor ³Bruno Sobieski Chavez Data ³  16/03/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula el valor diario de Remuneracion variable, para cal- º±±
±±º          ³culo de vacaciones para trabajadores mensualistas           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEM030/GPEM040                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GetRemVarD(dDataIni,nMedia,lFerias,lHorista,nRetorno,nQtdHor,cTipoHD )
Local cDataIni		:=	''
Local cMesAno		:=	''
Local nMeses		:=	0
Local nTotalAno	:=	0
Local nHabilesFunc:=	0      
Local lVarDiaUtil	:=	.F.
Local	nMes			:=	0
Local	nAno			:=	0
Local cCampoInc	:=	"RV_MEDFER"   
Local aArea	:=	GetArea()

DEFAULT lFerias	:=	.T.
DEFAULT nMedia		:=	Iif(lFerias,GetNewPar("MV_MEDFERI",12),12)
Default lHorista := .F.
Default nRetorno := 0
Default nQtdHor := 0
Default cTipoHD := "D"


nMes			:=	Month(dDataIni)-nMedia
nAno			:=	Year(dDataIni)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³So se aplica para calculo de remuneracao variavel para ferias³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lVarDiaUtil	:=	lVarDiaUtil.And.lFerias

If nMes <= 0
	nAno--
	nMes	+= 12   
Endif
cDataIni	:=	Strzero(nAno,4) + Strzero(nMes,2)
nMeses	:=	0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pegar Promedio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "SRD" )
dbSetOrder(1)
dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cDataIni , .T. )
While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT .And.  ;
	SRD->RD_DATARQ < AnoMes(dDataIni)
	If !(SRD->RD_TIPO2 $ 'PS')//Ignorar 13ro
		If Alltrim(PosSrv(SRD->RD_PD,SRD->RD_FILIAL,cCampoInc)) == "S"
			nTotalAno	+= SRD->RD_VALOR
		Endif  
		If lHorista
			If SRD->RD_PD == fGetCodFol("0032")
			   nQtdHor += SRD->RD_VALOR
			   If SRD->RD_TIPO1 == "D"
		   		  cTipoHD := "D"
			   Else
			   	  cTipoHD := "H"
			   Endif	  		  
			Endif    
		Endif	
		If cMesAno <> SRD->RD_DATARQ
			cMesAno	:=	SRD->RD_DATARQ
			nMeses++
		Endif
	Endif
	dbSkip()
Enddo

If lVarDiaUtil
	//Calcular os dias uteis do ano para o funcionario
	LocGHabRea(Max(SRA->RA_ADMISSA,Ctod('01/'+StrZero(nMes,4)+'/'+StrZero(nAno,4))),Ctod('31/12/'+StrZero(nAno,4)),@nHabilesFunc)

	//Tirar as faltas e afastamentos do funcionario
	nHabilesFunc	-=	LocAfast(Max(SRA->RA_ADMISSA,Ctod('01/'+StrZero(nMes,4)+'/'+StrZero(nAno,4))),Ctod('31/12/'+StrZero(nAno,4)),SRA->RA_MAT,{aCodFol[054,1],aCodFol[203,1],aCodFol[242,1]},{'X'})
	nRetorno	:=	nTotalAno/nHabilesFunc //ja tem incorporado o equivalente a 25/30avos
Else
//	nRetorno	:=	(nTotalAno/nMeses)/30 //nao tem incorporado o equivalente a 25/30avos
	nRetorno	:=	nTotalAno
Endif	

RestArea(aArea)                      

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOC_BSE1  ºAutor  ³Silvia Taguti       º Data ³  04/26/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega Variaveis com aliquotas do BSE e C.Social           º±±
±±º          ³URUGUAI                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
                      
Function LOC_BSE(nCSocial,nBseFixo,nBseIva,cAnoMes)
Local nPos	:=	0

If aDadosBSE <> Nil .And. (nPos := Ascan(aDadosBSE,{|x| x[1] == cAnoMes}))> 0
	nCSocial	:=	aDadosBSE[nPos][2]
	nBSEFixo	:=	aDadosBSE[nPos][3]
	nBSEIva 	:=	aDadosBSE[nPos][4]
Else
	If FPHIST82(xFilial("SRX") , "57" , cAnoMes )
		nCSocial := Val( SubStr( SRX->RX_TXT ,  1 , 9 ) )
		nBseFixo := Val( SubStr( SRX->RX_TXT , 10 , 5 ) )
		nBseIva  := Val( SubStr( SRX->RX_TXT , 15 , 5 ) )
	ElseIf FPHIST82(xFilial("SRX") , "57" , "      " )
		nCSocial := Val( SubStr( SRX->RX_TXT ,  1 , 9 ) )
		nBseFixo := Val( SubStr( SRX->RX_TXT , 10 , 5 ) )
		nBseIva  := Val( SubStr( SRX->RX_TXT , 15 , 5 ) )
	Else
		If GetRemoteType() == -1
			MsgLogGrid( Ap5GetHelp("GPEXBSE"), .F. ) // Retornar string da funcao Help
		Else
			Help(" ",1,"GPEXBSE")
		EndIf
		Return ( .F. )
	EndIf
	aDadosBSE	:=	IIf(aDadosBSE <> Nil,aDadosBSE,{})
	Aadd(aDadosBSE,{cAnoMes,nCSocial,nBSEFixo,nBSEIva})
Endif
Return ( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOC_BSE2  ºAutor  ³Silvia Taguti       º Data ³  04/26/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega a aliquota de BSE para a apolice contratada         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOC_BSE2(cApolice,nAliqBSE)
Local lRet := .F.                         
Local nPos	:=	0

If aApolices <> Nil .And. (nPos:=Ascan(aApolices,{|x| x[1] == cApolice })) > 0
	nAliqBSE	:= aApolices[nPos][2]
	lRet	:=	.T.
ElseIf FPHIST82(xFilial("SRX") , "78" , cApolice )
 	nAliqBSE := Val( Substr( SRX->RX_TXT , 1 , 7 ) )
	aApolices	:= 	IIf(aApolices<>Nil,aApolices,{})
	AAdd(aApolices,{cApolice, nAliqBSE})
 	lRet := .T.
EndIf
 
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCBASNOM ºAutor  ³Silvia Taguti       º Data ³  08/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula Base Nominal conforme lei 17.829 - Uruguai         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                                 

Function LocBasNom()

Local nDesconto:= 0
Local nX			:= 0                 
Local nBaseNom := 0
Local nDescLeg := 0
 
nInsBasNom := 0 
      
For nx:= 1 to Len(aPd)
	If aPd[nX,9] == "D" .or. aPd[nX,3] <> cSemana
		Loop
	Endif	
		If PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_TIPOCOD") == "1" 
		   nBaseNom += aPd[nX,5]
		ElseIf PosSrv(aPd[nX,1],SRA->RA_FILIAL,"RV_TIPOCOD") == "2"
			If (aPd[nX,1] == aCodFol[064,1]) .Or.;
			   (aPd[nX,1] == aCodFol[066,1]) .Or.;
				(aPd[nX,1] == aCodFol[306,1]) .Or. (aPd[nX,1] == aCodFol[309,1]) .Or.;
				(aPd[nX,1] == aCodFol[310,1]) .or.;
			   (aPd[nX,1] == aCodFol[018,1]) .Or.;
			   (aPd[nX,1] == aCodFol[067,1]) .Or.;
				(aPd[nX,1] == aCodFol[356,1]) .Or.;
				(aPd[nX,1] == aCodFol[375,1]) .Or. (aPd[nX,1] == aCodFol[376,1]) .Or.;
				(aPd[nX,1] == aCodFol[377,1]) .Or. (aPd[nX,1] == aCodFol[378,1]) .Or.;
				(aPd[nX,1] == aCodFol[379,1])
				nDescLeg += aPd[nX,5]
			Else 
			   If aPd[nX,1] <> aCodFol[007,1] .And. aPd[nX,1] <> aCodFol[102,1] .And. aPd[nX,1] <> aCodFol[164,1];
			   	.And. aPd[nX,1] <> aCodFol[046,1]
					nDesconto += aPd[nX,5]
				Endif	
			Endif		
		Endif	
Next
nBaseNom := ((nBaseNom - nDescLeg) * 70 )/100

If nBaseNom - nDesconto <= 0
	nInsBasNom := Round(Abs(nBaseNom - nDesconto),MsDecimais(1))
	FMatriz( aCodFol[045,1], nInsBasNom )
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Loc_provArg Autor ³Silvia Taguti       º Data ³  05/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega tabela de obrigacoes patronais, calculadas         º±±
±±º          ³ na provisao - Argentina                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Loc_ProvArg(aObraSoc,aJubila,aLey)
Local nPerPat := 0
Local nMinBas := 0
Local nMaxBas := 0
Local nMopre := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando a Tabela de Valor do Modulo Previsional	   	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !SetValMOPRE(@nMopre)
  	Return (.F.)
Endif    

SRX->(DbSetOrder(1))

//Obras Sociais
If FPHIST82( xFilial("SRX") , "64" ,  MesAno(dDataBase) ) .Or. FPHIST82( xFilial("SRX") , "64" , "      " )
	nPerPat:= Val( SubStr ( SRX->RX_TXT , 13 , 6 ) )
	nMinBas:= Val( SubStr ( SRX->RX_TXT , 35 , 5 ) )
	nMaxBas:= Val( SubStr ( SRX->RX_TXT , 40 , 5 ) )
	AADD(aObraSoc, { nPerPat, (nMinBas * nMopre), (nMaxBas * nMopre) } )
Else
	Return(.F.)
Endif
nPerPat := nMinBas := nMaxBas := 0

//Jubilacion
If FPHIST82( xFilial("SRX") , "60" , RhTamFilial(xFilial("SRA"))+MesAno(dDataBase)) .Or. FPHIST82( xFilial("SRX") , "60" , RhTamFilial(xFilial("SRA"))+"      ")
	nPerPat := Val( SubStr ( SRX->RX_TXT ,  01 , 05 ) )
	nMinBas := Val( SubStr ( SRX->RX_TXT ,  06 , 05 ) )
	nMaxBas := Val( SubStr ( SRX->RX_TXT ,  11 , 05 ) )
	AADD(aJubila, { nPerPat, (nMinBas * nMopre), (nMaxBas * nMopre) } )
Else
	Return(.F.)
Endif    
nPerPat := nMinBas := nMaxBas := 0

//Ley 19032
If FPHIST82( xFilial("SRX") 		, "65" , MesAno(dDataBase) ) .Or. FPHIST82( xFilial("SRX") 	, "65" , "      " )
	nPerPat:= 	Val( SubStr ( SRX->RX_TXT ,  07 , 6 ) )
	nMinBas:= Val( SubStr ( SRX->RX_TXT ,  37 , 6 ) )
	nMaxBas:= Val( SubStr ( SRX->RX_TXT ,  43 , 6 ) )
	AADD(aLey, { nPerPat, (nMinBas * nMopre), (nMaxBas * nMopre) } )
Else
	Return(.F.)
Endif
nPerPat := nMinBas := nMaxBas := 0

Return (.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCalcEncLoc Autor ³Silvia Taguti       º Data ³  05/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula valor da Obrigacao Patronal - Provisao Argentina    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function fCalcEncLoc(nBase, aObrPatr)

Local nValor := 0

If (nBase) < aObrPatr[1,2]      						//Base Menor que o Minimo
	nValor := 0
ElseIf (nBase) > aObrPatr[1,3]            			//Base Maior que o Maximo
	nValor := (aObrPatr[1,3] * aObrPatr[1,1]) /100
ElseIf (nBase) <= aObrPatr[1,3]
	nValor := (nBase * aObrPatr[1,1])/100
Endif

Return nValor
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCalAd13    Autor ³Silvia Taguti       º Data ³  03/08/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula Adicional de Aguinaldo - Provisao Paraguai          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function fLocCalAd13()

Local nBaseOutr := 0
Local aArea		:=	GetArea()
Local cDataIni
Local cDatafim                
Local lFechMes := .T.

cDataIni := Strzero(Year(dDataRef),4)+ "01"
cDataFim := AnoMes(dDataRef)
dbSelectArea( "SRD" )
dbSetOrder(1)
dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cDataIni , .T. )
While !Eof() .And. SRD->RD_FILIAL + SRD->RD_MAT == SRA->RA_FILIAL + SRA->RA_MAT ;
	.And. (SRD->RD_DATARQ >=cDataIni .And. SRD->RD_DATARQ <=cDataFim)
	If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_REF13") == "S"
		If PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "1"
			If SRD->RD_PD <> aCodFol[31,1]
				nBaseOutr	+=	 SRD->RD_VALOR
			Endif
		ElseIf PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "2"
			nBaseOutr		-=	 SRD->RD_VALOR
		Endif
	Endif
	SRD->(dbSkip())
Enddo
If ( lFechMes := ( GetMv( "MV_FOLMES",,"") <= MesAno(dDataRef) ) )
	SRC->(DbSetOrder(1))
	SRC->(DbSeek(xFilial()+SRA->RA_MAT ))
	While !SRC->(Eof()) .And. SRC->RC_FILIAL + SRC->RC_MAT == SRA->RA_FILIAL + SRA->RA_MAT
		If PosSrv(SRC->RC_PD,SRC->RC_FILIAL,"RV_REF13") == "S"
			If PosSrv(SRC->RC_PD,SRC->RC_FILIAL,"RV_TIPOCOD") == "1"
				If SRC->RC_PD <> aCodFol[31,1]
					nBaseOutr	+=	 SRC->RC_VALOR
				Endif
			ElseIf PosSrv(SRC->RC_PD,SRC->RC_FILIAL,"RV_TIPOCOD") == "2"
				nBaseOutr		-=	 SRC->RC_VALOR
			Endif
		Endif
		SRC->(dbSkip())
	Enddo
Endif	

RestArea(aArea)

Return nBaseOutr

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCIRPF   ºAutor  ³Silvia Taguti       º Data ³  21/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula IRPF - Uruguai                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                            
Function LocIRPF()

Local nBaseIrpAnt := 0
Local nVlIrpAnt   := 0
Local nVlIrpPatAnt:= 0
Local nVlIrpAdAnt := 0
Local nPos 		  := 0
Local nBaseIrpFo  := 0
Local nBaseIrpFe  := 0
Local nBaseIrp13  := 0
Local nVlImp	  := 0
Local nBaseDedFo  := 0
Local nBaseDedFe  := 0
Local nBaseDed13  := 0
Local nVlDedImp	  := 0
Local nVlrIngr	  := 0
Local nVlrDed     := 0
Local nDedHijos   := 0
Local aTabBPC     := {}
Local nVlBPC	  := 0 //GetNewPar('MV_VLBPC',1636.00) //Promedio del ultimo ano
Local nPosD		  := 0         
Local cCodExc	  := aCodfol[067,1]+"|"+aCodFol[102,1]                                     '
Local cTab, nLinha
Local nPercNucleo := 0
Local nValIRNR    := 0

	If SRA->RA_TIPOPGT == "S" .And. !lUltSemana .And. c__Roteiro == "FOL"    
		Return
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Carrega o valor do BPC |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   	fCarrTab( @aTabBPC   , "S003", Nil)
	// Valor do Bpc
	IF Len(aTabBPC) > 0
		nVlBPC   := fTabela("S003", 1 , 4 )
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega Dependentes                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SRB")
	dbSetOrder(1)
	dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
	While !Eof() .And. SRB->RB_FILIAL + SRB->RB_MAT == SRA->RA_FILIAL + SRA->RA_MAT
		If SRB->RB_TIPIR == "1"  		//Sin Limite de Edad - discapacitado
			nDedHijos += nVlBPC /12 * 6.5 *2 
		ElseIf SRB->RB_TIPIR == "2"  				//Menor
			nDedHijos += (nVlBPC /12 * 6.5) 
		Endif			
		SRB->(dbSkip())
	EndDo
	
	If c__Roteiro == "FOL"
		If (nPos:= Ascan(aPd, { |X| X[1] = aCodfol[016,1] .And. X[9] # "D"})) > 0
			nBaseIrpAnt := aPd[nPos,5]
		Endif
		If (nPos:= Ascan(aPd, { |X| X[1] = aCodfol[067,1] .And. X[9] # "D"})) > 0
			nVlIrpAnt := aPd[nPos,5]
		Endif
		If (nPos:= Ascan(aPd, { |X| X[1] = aCodfol[646,1] .And. X[9] # "D"})) > 0
			nVlIrpPatAnt := aPd[nPos,5]
		Endif
		If (nPos:= Ascan(aPd, { |X| X[1] = aCodfol[100,1] .And. X[9] # "D"})) > 0
			nVlIrpAdAnt := aPd[nPos,5]
		Endif
	Endif	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somar as incidencias para apurar a base aporte jubilacion      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If c__Roteiro $ "FOL|RES"
		Aeval( aPd ,{ |X| SomaInc(X,5,@nBaseIrpFo,27,"1",,,,.T.,aCodfol) })  // Incidencia Irp Folha
		Aeval( aPd ,{|X| If(!X[1] $ cCodExc ,SomaInc(X,5,@nBaseDedFo,27,"2",,,,.T.,aCodfol),"")}) // Incidencia Irp Folha
		nBaseDedFo *= (-1)
  	ElseIf c__Roteiro = "FER"
		Aeval( aPd ,{ |X| SomaInc(X,5,@nBaseIrpFe,27,"1",11,"S",,.F.,aCodfol) })  // Incidencia Irp Ferias
		Aeval( aPd ,{ |X| SomaInc(X,5,@nBaseDedFe,27,"2",11,"S",,.F.,aCodfol) })  // Incidencia Irp Ferias
		nBaseDedFe *= (-1)
    Else
		Aeval( aPd ,{ |X| SomaInc(X,5,@nBaseIrp13,27,"1",12,"S",,.T.,aCodfol) })  // Incidencia Irp 13salario
		Aeval( aPd ,{ |X| SomaInc(X,5,@nBaseDed13,27,"2",12,"S",,.T.,aCodfol) })  // Incidencia Irp 13salario
		nBaseDed13 *= (-1)
  	Endif
   
	If SRA->RA_CATFUNC == "A"
    	nBaseIrpFo := nBaseIrpFo - ((nBaseIrpFo * 30)/100)
    	nBaseDedFo := 0
    Endif 
    
	//Fondo de Solidaridad
	If (nPosD:= Ascan(aPd, { |X| X[1] = aCodfol[709,1]  .And. X[3] = cSemana .And. X[9] # "D"})) > 0 
		nBaseDedFo += Round((aPd[nPosD,5] / 12),0)
	Endif
   //Aporte Mensual a CJPPU
	If (nPosD:= Ascan(aPd, { |X| X[1] = aCodfol[710,1]  .And. X[3] = cSemana .And. X[9] # "D"})) > 0 
		nBaseDedFo += aPd[nPosD,5]
	Endif
   //Otras Deducciones
	If (nPosD:= Ascan(aPd, { |X| X[1] = aCodfol[711,1]  .And. X[3] = cSemana .And. X[9] # "D"})) > 0 
		nBaseDedFo += aPd[nPosD,5]
	Endif

	//No mês de dezembro o IRPF deverá ser calculado pela rotina de Ajuste Anual
	If c__Roteiro == "FOL" .And. Substr(GETMV('MV_FOLMES'),5,2) = '12'
		LocAjusteIRPF(nBaseIrpFo, nBaseDedFo)
		Return	
	Endif	
	
	
   If c__Roteiro $ "FOL|RES"
		If nBaseIrpFo > 0
		 	LocIRPFCalc(nBaseIrpFo, aIR, @nVlImp)
		Endif 	
		If nBaseDedFo + nDedHijos > 0
		 	LocIRPFCalc(nBaseDedFo+nDedHijos, aIRDed, @nVlDedImp)
		Endif 
	
		If nBaseIrpFo - nBaseIrpAnt > 0
			FGeraVerba(aCodFol[15,1],nBaseIrpFo - nBaseIrpAnt,0.00,,,,,,,,)
		Endif
		If nBaseDedFo + nDedHijos > 0
		 	FGeraVerba(aCodFol[937,1],nBaseDedFo + nDedHijos,0.00,,,,,,,,)
		Endif 		
		
		//Tratamento para geração do IR Folha para funcionarios não residentes.
		IF !( SRA->RA_NACIONA $ "10*20" )
			IF SRA->RA_OPSEGSO == "2"		
				IF SRA->RA_OPIRNR == "1"				
					IF Len(aTabBPC) > 0 					
						nValIRNR   := fTabela("S003", 1 , 11 )
						IF nValIRNR > 0 .AND. !EMPTY(aCodFol[942,1])
							FGeraVerba(aCodFol[942,1],(nBaseIrpFo-nBaseDedFo) * ( nValIRNR / 100 ), nValIRNR ,,,,,,,,.T.)						
						ENDIF
					Endif
					//Imposto de Renda Patronal - Folha
					If nBaseIrpFo - nBaseDedFo > 0 .And. Len(aIr) > 0
	    				FGeraVerba(aCodFol[304,1],Round(((nBaseIrpFo-nBaseDedFo)*aIR[Len(aIR)])-nVlIrpPatAnt,MsDecimais(1)),aIR[Len(aIR)]*100,,,,,,,,.T.)
        			Endif
        			// Sai da função para nao calcular o IRPF
        			Return()
				ENDIF
			ENDIF
		ENDIF         
		
		//Verificar se o funcionario tem nucleo familiar
		If (!Empty(SRA->RA_DTNCFAM) .And. GetMv( "MV_FOLMES") >= MesAno(SRA->RA_DTNCFAM)) .And. (Empty(SRA->RA_DTFNCFM) .Or. GetMv( "MV_FOLMES") <= MesAno(SRA->RA_DTFNCFM) )  
	        // Busca Tabela Relacionada - Valor do Desconto de Núcleo Familiar
    	    cTab   := "S003"			
	        If ( nLinha := fPosTab(cTab, xFilial('SRM'), "=", 1) ) > 0
		        nPercNucleo := fTabela(cTab,nLinha,9)
		        
		        nVlImp    := nVlImp * ((100 - nPercNucleo) / 100)
		        nVlDedImp := nVlDedImp * ((100 - nPercNucleo) / 100)
	        Endif
		Endif
			
		If (nVlImp - nVlDedImp) - nVlIrpAnt > 0
			FGeraVerba(aCodFol[066,1],Round((nVlImp-nVlDedImp) -nVlIrpAnt,MsDecimais(1)),,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))
      	Endif
        //Imposto de Renda Patronal - Folha
		If nBaseIrpFo - nBaseDedFo > 0 .And. Len(aIr) > 0
	    	FGeraVerba(aCodFol[304,1],Round(((nBaseIrpFo-nBaseDedFo)*aIR[Len(aIR)])-nVlIrpPatAnt,MsDecimais(1)),aIR[Len(aIR)]*100,,,,,,,,.T.)
        Endif
   ElseIf c__Roteiro = "FER"
		If nBaseIrpFe > 0
		 	LocIRPFCalc(nBaseIrpFe, aIR, @nVlImp)
		Endif 	

		If nBaseDedFe > 0
		 	LocIRPFCalc(nBaseDedFe, aIRDed, @nVlDedImp)
		Endif 	

		//Tratamento para geração do IR Ferias para funcionarios não residentes.
		IF !( SRA->RA_NACIONA $ "10*20" )   		
			IF SRA->RA_OPSEGSO == "2"		
				IF SRA->RA_OPIRNR == "1"				
					IF Len(aTabBPC) > 0 					
						nValIRNR   := fTabela("S003", 1 , 11 )
						IF nValIRNR > 0 .AND. !EMPTY(aCodFol[942,1])
							FGeraVerba(aCodFol[942,1],(nBaseIrpFe-nBaseDedFe) * ( nValIRNR / 100 ), nValIRNR ,,,,,,,,.T.)						
						ENDIF
					Endif
					//Imposto de Renda Patronal - Ferias
				 	If nBaseIrpFe-nBaseDedFe > 0 .And. Len(aIr)> 0
						FGeraVerba(aCodFol[646,1],Round(((nBaseIrpFe-nBaseDedFe)*aIR[Len(aIR)]),MsDecimais(1)),aIR[Len(aIR)]*100,,,,,,,,.T.)
					Endif
		  			// Sai da função para nao calcular o IRPF
        			Return()
				ENDIF
			ENDIF
		ENDIF 
				
		//Verificar se o funcionario tem nucleo familiar
		If (!Empty(SRA->RA_DTNCFAM) .And. GetMv( "MV_FOLMES") >= MesAno(SRA->RA_DTNCFAM)) .And. (Empty(SRA->RA_DTFNCFM) .Or. GetMv( "MV_FOLMES") <= MesAno(SRA->RA_DTFNCFM) )  
	        // Busca Tabela Relacionada - Valor do Desconto de Núcleo Familiar
    	    cTab   := "S003"			
	        If ( nLinha := fPosTab(cTab, xFilial('SRM'), "=", 1) ) > 0
		        nPercNucleo := fTabela(cTab,nLinha,9)
		        
		        nVlImp    := nVlImp * ((100 - nPercNucleo) / 100)
		        nVlDedImp := nVlDedImp * ((100 - nPercNucleo) / 100)
	        Endif
		Endif
		
		FGeraVerba(aCodFol[16,1],nBaseIrpFe,0.00,,,,,,,)
		FGeraVerba(aCodFol[067,1],Round((nVlImp-nVlDedImp),MsDecimais(1)),,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))

		//Imposto de Renda Patronal - Ferias
	 	If nBaseIrpFe-nBaseDedFe > 0 .And. Len(aIr)> 0
			FGeraVerba(aCodFol[646,1],Round(((nBaseIrpFe-nBaseDedFe)*aIR[Len(aIR)]),MsDecimais(1)),aIR[Len(aIR)]*100,,,,,,,,.T.)
		Endif
   Else
		If nBaseIrp13 > 0
		 	LocIRPFCalc(nBaseIrp13, aIR, @nVlImp)
		Endif 	
		If nBaseDed13 > 0
		 	LocIRPFCalc(nBaseDed13, aIRDed, @nVlDedImp)
		Endif 	

		//Tratamento para geração do IR 13º para funcionarios não residentes.
		IF !( SRA->RA_NACIONA $ "10*20" )   		
			IF SRA->RA_OPSEGSO == "2"		
				IF SRA->RA_OPIRNR == "1"				
					IF Len(aTabBPC) > 0 					
						nValIRNR   := fTabela("S003", 1 , 11 )
						IF nValIRNR > 0 .AND. !EMPTY(aCodFol[942,1])
							FGeraVerba(aCodFol[942,1],(nBaseIrp13-nBaseDed13) * ( nValIRNR / 100 ), nValIRNR ,,,,,,,,.T.)						
						ENDIF
					Endif
					//Imposto de Renda Patronal - 13       
					If nBaseIrp13- nBaseDed13 > 0 .And. Len(aIr)> 0
    					FGeraVerba(aCodFol[647,1],Round((nBaseIrp13-nBaseDed13)*aIR[Len(aIR)],MsDecimais(1)),aIR[Len(aIR)]*100,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))
					Endif
		  			// Sai da função para nao calcular o IRPF
        			Return()					
				ENDIF
			ENDIF
		ENDIF 
		
		//Verificar se o funcionario tem nucleo familiar
		If (!Empty(SRA->RA_DTNCFAM) .And. GetMv( "MV_FOLMES") >= MesAno(SRA->RA_DTNCFAM)) .And. (Empty(SRA->RA_DTFNCFM) .Or. GetMv( "MV_FOLMES") <= MesAno(SRA->RA_DTFNCFM) )  
	        // Busca Tabela Relacionada - Valor do Desconto de Núcleo Familiar
    	    cTab   := "S003"			
	        If ( nLinha := fPosTab(cTab, xFilial('SRM'), "=", 1) ) > 0
		        nPercNucleo := fTabela(cTab,nLinha,9)
		        
		        nVlImp    := nVlImp * ((100 - nPercNucleo) / 100)
		        nVlDedImp := nVlDedImp * ((100 - nPercNucleo) / 100)
	        Endif
		Endif

		FGeraVerba(aCodFol[27,1],nBaseIrp13,0.00,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil), .T.)
		FGeraVerba(aCodFol[938,1],nBaseDed13,0.00,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil), .T.)
		If c__Roteiro = "131"
	  		FGeraVerba(aCodFol[71,1],Round((nVlImp-nVlDedImp),MsDecimais(1)),,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))
		Endif
		//	//Imposto de Renda Patronal - 13       
		If nBaseIrp13- nBaseDed13 > 0 .And. Len(aIr)> 0
    		FGeraVerba(aCodFol[647,1],Round((nBaseIrp13-nBaseDed13)*aIR[Len(aIR)],MsDecimais(1)),aIR[Len(aIR)]*100,,,,,,,Iif(c__Roteiro=="131".Or.c__Roteiro=="132",dData_Pgto,Nil))
		Endif
   Endif

Return
                                           
     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocIrpfCalc Autor  ³Microsiga          º Data ³  06/29/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo do IRPF                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LocIRPFCalc(nBasIngDed, aImposto, nVlImp)

Local nx := 0

If nBasIngDed > 0
	For nx := 1 to Len(aImposto)
		If nx == 1
			If nBasIngDed > (aImposto[nx,1] - 0) 
	  			nVlImp   += (aImposto[nx,1] - 0) * aImposto[nx,2]
		  		nBasIngDed -= (aImposto[nx,1] - 0) 
	      	Else
		   		nVlImp += nBasIngDed * aImposto[nx,2]
		  	   	Exit	
		  	Endif	
		Else	
		   If nBasIngDed > (aImposto[nx,1] - aImposto[nx-1,1]) 
		   		nVlImp   += (aImposto[nx,1] - aImposto[nx-1,1]) * aImposto[nx,2]
		  		nBasIngDed -= (aImposto[nx,1] - aImposto[nx-1,1]) 
		   Else
		   		nVlImp += nBasIngDed * aImposto[nx,2]
		   		Exit	
		   Endif	   
		Endif   
	Next             
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCarRotRelºAutor  ³Mauricio Takakura   º Data ³  02/11/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Determina os itens dos roteiros a executar para a execucao º±±
±±º          ³ do roteiro de reliquidacao                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEXLOC - Chile                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fCarRotRel( aItens, lResc, cRot )

DEFAULT aItens	:= {}
DEFAULT lResc	:= .F.
DEFAULT cRot	:= "FOL"

If cRot == "FOL"
	If lResc
		aAdd( aItens,'NI347' ) //"Carrega Tabelas de Calculo - S_CARGA TABELAS"
	Else
		aAdd( aItens,'NI347' ) //"Carrega Tabelas de Calculo - S_CARGA TABELAS"
		aAdd( aItens,'NI463' ) //"DIAS TRABAJADOS - FDiasTrab(@DiasTrab,cDiasMes,@lAdmissao)"
		aAdd( aItens,'NI464' ) //"DIAS DE LICENCIA - FDiasAfast(@nDiasAfas,@DiasTrab)"
		aAdd( aItens,'NI468' ) //"Valoriza Verbas - FValoriza(@aPd,aCodFol,@SalMes,@SalDia,@SalHora,Val_SalMin,DiasTrab,,,lPropTarefa)"
		aAdd( aItens,'NI469' ) //"CALCULO LICENCIAS - FAfastados(aCodFol)"
		aAdd( aItens,'NI473' ) //"CALCULO SALUD - LOCSalud()"
		aAdd( aItens,'NI474' ) //"SEGURO SOCIAL AFP - LOCSegSoc()"
		aAdd( aItens,'NI476' ) //"IMPUESTO A LA RENTA - LOCGananc()"
		aAdd( aItens,'NI477' ) //"APORTE PATRONAL - LOCAportePa()"
	EndIf
ElseIf cRot == "RES"
	aAdd( aItens,'NI385' ) //"DIAS TRABAJADOS - SRA->RA_CATFUNC$ "M*C" .And. Day(dDatadem) >= If(Month(dDatadem)==2, If((Mod(Year(dDatadem),4)==0), 29, 28), 30)"
	aAdd( aItens,'NI386' ) //"CALCULO DE DIAS - FDiasAfast(@nDiasAfas,@DiasTrab,dDataDem,,cPgSalMat)"
	aAdd( aItens,'NI384' ) //"VALORIZA CONCEPTOS - FValoriza(aPd,aCodfol,,Saldia,Salhora)"
	aAdd( aItens,'NI335' ) //"CALCULO SALUD - LOCSalud()"
	aAdd( aItens,'NI336' ) //"SEGURO SOCIAL AFP - LOCSegSoc()"
	aAdd( aItens,'NI397' ) //"IMPUESTO A LA RENTA - LOCGananc()"
	aAdd( aItens,'NI382' ) //"APORTE PATRONAL - LOCAportePa()"
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fSetRlq   ºAutor  ³Jonatas A. T. Alves º Data ³  08/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta base para calculo da reliquidacao.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEXLOC - Chile    		                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fSetRlq( nBaseCalc, nInc )

Local nPdv			:= 0

DEFAULT nBaseCalc	:= 0
DEFAULT nInc		:= 5

If Type ( "lReliq" ) # "U" .And. lReliq
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento das incidencias de reliquidacion para as verbas 	 ³
	//³ da tabela RCY.								 				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nPdv := 1 To Len( aPdv )
		If aScan( aARlqPd, { |x| x[1] == aPdv[nPdv,1] } ) > 0
			aPdv[nPdv,nInc] := "S"
		Else
			aPdv[nPdv,nInc] := "N"
		EndIf
	Next
EndIf

fCalaPd() // Ajuste do aPd das verbas reliquidadas (assume 1 avo do total)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Somar as incidencias para apurar a base de calculo             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aEval( aPd, { |X| SomaInc( X, nInc, @nBaseCalc, , , , , , .T., aCodfol ) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Conversao da UTM atual para a UTM antiga                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type ( "lReliq" ) # "U" .And. lReliq
	nBaseCalc := nBaseCalc / nNewVUtm * nValUtm
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCalaPd   ºAutor  ³Jonatas A. T. Alves º Data ³  26/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Assume o valor da verba como 1 avo do total calculado ou   º±±
±±º          ³ restaura aPd das verbas reliquidas com o valor original.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEXLOC - Chile    		                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fCalaPd( nPosVlr )

Local nTotRlq	:= 0

DEFAULT nPosVlr	:= 2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento das verbas reliquidadas. Assume valor de 1 avo do ³
//³ total reliquidado.		 									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( aARlqPd )
	For nTotRlq := 1 To Len( aARlqPd )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Despreza verbas que nao sao reliquidadas no mes processado.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( nPos := aScan( aPd, { |x| x[1] == aARlqPd[ nTotRlq, 1 ] .And. x[9] # "D" } ) ) > 0
			aPd[ nPos, 5 ] := aARlqPd[ nTotRlq, nPosVlr ] // 2=Assume valor de apenas 1 avo; 3=Restaura valor original
		EndIf
	Next
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGeraRlq  ºAutor  ³Jonatas A. T. Alves º Data ³  09/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera/soma verba de reliquidacao no aPd.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEXLOC - Chile    		                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGeraRlq( cPdRlq, nValRlq, nPdRef, lConvUTM, lRound )

Local cCodRlq		:= ""
Local nPosRlq		:= 0
Local nValRGV		:= 0

DEFAULT lConvUTM	:= .F.
DEFAULT lRound		:= .F.
DEFAULT nPdRef		:= 0
DEFAULT nValRlq		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ So gera verbas utilizadas e com codigo de reliquidacao.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( cPdRlq ) .Or. Empty( cCodRlq := PosSrv( cPdRlq, SRA->RA_FILIAL, "RV_RELIQ", , .F. ) )
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena valor referenciado na UTM da epoca p/ gravar na RGV.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nValRGV := nValRlq

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Converte da UTM antiga para a UTM atual.                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lConvUTM
	nValRlq := nValRlq / nValUtm * nNewVUtm
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Arredonda valores gerados.                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRound
	nValRlq := Round( nValRlq, MsDecimais(1) )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera/soma no aPd.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nValRlq > 0
	If ( nPosRlq := aScan( aPd, { |x| x[1] == cCodRlq .And. x[9] # "D" } ) ) == 0
		fGeraVerba( cCodRlq, nValRlq, nPdRef, , , , , , , dSvData_Pgto )
	ElseIf aPd[nPosRlq,7] # "I"
		aPd[nPosRlq,5] += nValRlq
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inclui verba no array para gravacao na tabela de impostos     ³
	//³reliquidados (RGV).                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aImpRlq, { cCodRlq, nPdRef, nValRGV, AnoMes(dDataBase) } )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fBuscaRlq ºAutor  ³Jonatas A. T. Alves º Data ³  10/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca valores de reliquidacao na tabela RGV.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEXLOC - Chile    		                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fBuscaRlq( cPdRlq )

Local cQuery	:= ""
Local cAliasRlq	:= "RGV"
Local cDatArq	:= AnoMes(dDatabase)
Local cCodRlq	:= ""
Local cChave	:= SRA->( RA_FILIAL + RA_MAT )
Local nValRlq	:= 0
Local nPosCpo	:= 0
Local nVez		:= 0

Static aStruRGV	:= {}

DEFAULT	cPdRlq	:= ""

If Empty(aChave)

	aChave	:= Array( 01 , 07 )
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Carrega informacoes atuais do Funcionario em aChave.          ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aChave[ 01 , 01 ] :=  cEmpAnt		; aChave[ 01 , 02 ] := cChave 
	aChave[ 01 , 03 ] :=  SRA->RA_CC	; aChave[ 01 , 04 ] := cEmpAnt
	aChave[ 01 , 05 ] :=  cChave 		; aChave[ 01 , 06 ] := SRA->RA_CC
	aChave[ 01 , 07 ] :=  Stod( cFolMes + Alltrim( Str( f_UltDia( Stod( cFolMes + "01" ) ) ) ) )
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Seleciona o Arquivo de Transferencias e Retorna Todas as Trans³
	³ferencias do Funcionario.                                     ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF fTransf(@aChave,,,,,,,.T.)
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Grava em aTransf a Situacao Atual do Funcionario              ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF aScan( aChave,{ |x| ( x[1] + x[2] ) == ( cEmpAnt + cChave ) } ) == 0 .or. ;
		   aScan( aChave,{ |x| cEmpAnt != x[4] } ) > 0	
	    	SRA->( aAdd(aChave,{									 ;
	    						cEmpAnt								,; // 01 - Empresa Origem
	    						cChave            					,; // 02 - Filial + Matricula Origem  
	    						RA_CC								,; // 03 - Centro de Custo Origem
	    						cEmpAnt								,; // 04 - Empresa Destino
	    						cChave              				,; // 05 - Filial + Matricula Destino
	    						RA_CC								,; // 06 - Centro de Custo Destino
								( aChave[ Len( aChave ) , 7 ] + 1 ),; // 07 - Data da Transferencia
	                   		    ""						  			,; // 08 - Filial de Origem
	                      		""									,; // 09 - Matricula de Origem
	                            ""									,; // 10 - Filial de Destino
	                            ""									,; // 11 - Matricula de Destino
	                            ""									,; // 12 - Mes/Ano ( Ano/Mes ) da Transferencia 	
	                            0									 ; // 13 - Mes/Ano ( Ano/Mes ) da Transferencia 	
	    						}									 ;
	    				)											 ;
	    		  )
	    EndIF
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Ordena o Array aChave em Ordem Decrescente de Data            ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If Len( aChave ) > 0 .and. Len( aChave[1] ) > 12
			aSort( aChave ,,, { |x,y| DTOS(x[7]) + StrZero(x[13],15) > DTOS(y[7]) + StrZero(y[13],15) } )
		Else
			aSort( aChave ,,, { |x,y| x[7] > y[7] } )
		EndIf
	EndIF
EndIf

Begin Sequence

	If Empty(cPdRlq)
		Break
	EndIf

	If cPaisLoc == "CHI" .And. !( Sx2ChkTable( "RGV"  ) )
		Break
	EndIf
	
	If Empty(aStruRGV)
		aStruRGV := RGV->( dbStruct() )
	EndIf

	For nVez := 1 To Len(aChave)
	
		cChave := aChave[ nVez , 2 ]
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Sai do For/Next Quando Encontrar a Primeira Transferencia   de³
		³Empresa.                                                      ³	
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF !( aChave[ nVez , 4 ] == NIL ) .And. !( aChave[ nVez , 1 ] == cEmpAnt )
	    	Loop
	    EndIF
	    
		cAliasRlq := GetNextAlias()
			
		cQuery	:= "SELECT RGV_FILIAL, RGV_MAT, RGV_DATARQ, RGV_PD, RGV_ANOMES, RGV_VALOR, RGV_EFETIV "
		cQuery	+= "FROM "	+ RetSqlname("RGV")		+ " RGV, " + RetSqlname("SRV") + " SRV "
		cQuery	+= "WHERE	RGV_FILIAL		= '" 	+ SubStr(cChave,1,FWGETTAMFILIAL)	+ "'	AND "
		cQuery	+= "		RGV_MAT			= '" 	+ SubStr(cChave,FWGETTAMFILIAL+1) 	+ "'	AND "
		cQuery	+= "      	RGV_DATARQ		= '" 	+ cDatArq			+ "'	AND "
		cQuery	+= "      	RGV_PD			= RV_RELIQ	 				 	AND "
		cQuery	+= "		RGV_EFETIV		IN(' ','S')						AND "
		cQuery	+= "		RGV_ANOMES		< '" 	+ cFolMes			+ "'	AND "
		cQuery	+= "      	RGV.D_E_L_E_T_	= ' ' AND "
		cQuery	+= "		RV_FILIAL		= '" 	+ xFilial("SRV", SRA->RA_FILIAL) + "' AND "
		cQuery	+= "		RV_COD			= '" 	+ cPdRlq			+ "'	AND "
		cQuery	+= "      	SRV.D_E_L_E_T_	= ' ' "
		cQuery	+= "ORDER BY 1,2,3,4,5 "
		cQuery	:= ChangeQuery(cQuery)
			
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasRlq )
			
		If ( nPosCpo := Ascan( aStruRGV, { |x| x[1] = "RGV_VALOR" } ) ) > 0
			TcSetField( cAliasRlq, aStruRGV[nPosCpo][1], aStruRGV[nPosCpo][2], aStruRGV[nPosCpo][3], aStruRGV[nPosCpo][4] )
		EndIf
			
		cCodRlq	:= (cAliasRlq)->RGV_PD
		lBusRlq	:= !(cAliasRlq)->(Eof())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Varre RGV p/ busca de todas as reliquidacoes do mes calculado,³
		//³desprezando o mes corrente(cFolMes) e as rescioes simuladas.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lBusRlq
			While (cAliasRlq)->( !Eof() .And. RGV_FILIAL + RGV_MAT == cChave .And. RGV_DATARQ == cDatArq .And. RGV_PD == cCodRlq .And. RGV_ANOMES < cFolMes )
				If (cAliasRlq)->RGV_EFETIV $ " *S"
					nValRlq += (cAliasRlq)->RGV_VALOR
				EndIf
				(cAliasRlq)->( dbSkip() )
			EndDo
		EndIf
		
		(cAliasRlq)->( dbCloseArea() )

	Next nVez

End Sequence

Return(nValRlq)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GXLocRlq ºAutor  ³Jonatas A. T. Alves º Data ³  23/02/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Armazena/carrega tabela de impostos na reliquidacao.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nImp     - Posicao do imposto no array aTabRlq             º±±
±±º          ³ lCarga   - Tipo de operacao (armazenamento ou carga)       º±±
±±º          ³ aVarImp  - Array com descricao e conteudo das variaveis    º±±
±±º          ³ nPRlq    - Posicao da chave Filial + Ano/Mes em aTabRlq    º±±
±±º          ³ uCondSRA - Condicao complementar para busca em aTabRlq     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEXLOC/GPEXFUN/GPEXFORM/GPEXFUN1 - Chile                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GXLocRlq( nImp, lCarga, aVarImp, nPRlq, uCondSRA )

/*
///////////////////////////////////////////
// Posicao dos impostos no 3o. elemento  //
// do array aTabRlq 					 //
///////////////////////////////////////////
// SALARIO MINIMO	01					 //
// UTM/UF			02					 //
// APORTE PATRONAL	03					 //
// SALARIO FAMILIA	04					 //
// IMPOSTO UNICO	05					 //
// COMPOSICAO MES	06					 //
// TABELA AFP		07					 //
// SEGURO CESANTIA	08					 //
///////////////////////////////////////////
*/

Local cCmpImp	:= ""
Local lRet		:= .F.
Local lAtuTab	:= .F.
Local nI		:= 0

DEFAULT lCarga		:= .T.	// .F.=Armazena imposto no array; .T.=Carrega imposto do array

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa apenas na reliquidacao.                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type ( "lReliq" ) # "U" .And. lReliq	
	
	cCmpImp	:= AnoMes(dDatabase)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua carga dos impostos do array principal.                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCarga
		If !Empty(aTabRlq)
			If ( nPRlq := aScan( aTabRlq, { |x| x[1] == SRA->RA_FILIAL .And. x[2] == cCmpImp } ) ) > 0
				If aTabRlq[ nPRlq, _TABRL, nImp ] <> Nil
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Carrega cada uma das variaveis do imposto selecionado p/ a   ³
					//³ competencia a calcular.                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nI := 1 To Len( aTabRlq[ nPRlq, _TABRL, nImp ] )
						If uCondSRA == Nil .Or. uCondSRA == aTabRlq[ nPRlq, _TABRL, nImp, nI, 3 ]
							If ValType( aTabRlq[ nPRlq, _TABRL, nImp, nI, 2 ] ) == "A"
								&( aTabRlq[ nPRlq, _TABRL, nImp, nI, 1 ] ) := aClone( aTabRlq[ nPRlq, _TABRL, nImp, nI, 2 ] )
							Else
								&( aTabRlq[ nPRlq, _TABRL, nImp, nI, 1 ] ) := aTabRlq[ nPRlq, _TABRL, nImp, nI, 2 ]
							EndIf

							lRet := .T.
						EndIf
					Next nI
				EndIf
			EndIf
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nao encontrou a chave Filial + Ano/Mes, adiciona em aTabRlq. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPRlq == 0
			aAdd( aTabRlq, { SRA->RA_FILIAL, cCmpImp, Array(8) } )
			nPRlq := Len(aTabRlq)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inclui as variaveis do imposto em aTabRlq.                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aTabRlq[ nPRlq, _TABRL, nImp ] := aClone(aVarImp)
	EndIf
EndIf

Return( lRet )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AcertHlp	 ³ Autor ³ Jonatas A. T. Alves  ³ Data ³ 25/03/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna mensagem para criacao das tabelas RCY/RGV.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPEM040/GPEM630/GPEXFORM                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GxLocRGV()
//"Antes de prosseguir, é necessário executar a atualização '59-Criação de campos - RCY/RGV - Reliquidação', disponível para o módulo SIGAGPE no compatibilizador RHUPDMOD."
Return(STR0014)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LocTicketAlim ºAutor ³ Christiane Vieira ºData ³ 17/06/2010º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo de Ticket Alimentacao para o URUGUAI               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P11                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LocTicketAlim(aCodfol)
Local dDtRef	:= ""
Local nVlrCalc  := 0  
Local nVlrAlim  := 0  // Valor Fixo para Calculo do Ticket Alimentacao
Local nPercAlim := 0  // Percentual para de Calculo do Ticket
Local nPercMax  := 0

// Variaveis Totalizadoras
Local nQtRef    := 0
 
// Verba Utilizada no Calculo
Local cPdTktAlim
Local nBusca, cTab, nLinha

If !FP_CODFOL(@aCodFol,SRA->RA_FILIAL)
	Return
Endif

cPdTktAlim := aCodFol[050,1]		//-- Ticket Alimentacao
 
If aCodFol[50,1] # Space( 03 ) .And. SRA->RA_TIPTKAL # Space( 01 )
    If ( c__Roteiro == "RES" .And. ( cCompl # "S" .Or. ( cCompl == "S" .And. MesAno(GetMemVar("RG_DATADEM")) == MesAno(GetMemVar("RG_DTGERAR")) ) )) .Or. ;
       ( c__Roteiro == "FOL" .And. ( SRA->RA_TIPOPGT # "S" .Or. ( SRA->RA_TIPOPGT == "S" .And. lUltSemana)) )
       
        // Busca Tabela Relacionada - Valor do Teto de Desconto
        cTab   := "S003"
        If ( nLinha := fPosTab(cTab, xFilial("SRM"), "=", 1) ) > 0
	        nPercMax := fTabela(cTab,nLinha,6)
        Endif
        
		//Verificar a data final do periodo 
		If c__Roteiro == "RES"
			// para rescisao a data final para o controle de dias uteis será a data da demissao
			dDtRef := RG_DATADEM
		Else
			dbSelectArea( "RCF" )
			dbSetOrder(1)
			If dbSeek( xFilial() + cFolMes + SRA->RA_TNOTRAB + mv_par08 )
				dDtRef := RCF->RCF_DTFIM
			ElseIf dbSeek( xFilial() + cFolMes + Space(Len(SRA->RA_TNOTRAB)) + mv_par08 )
				dDtRef := RCF->RCF_DTFIM
			Else
				dDtRef := dDt_Pgto
			Endif        
		Endif
                                                                       
		//Verificar os dias uteis do periodo
   		FTrabCalen(dDtRef,@nQtRef,,,,,,,,,,,,.F.,.T. ) 
		
        // Busca Tabela Relacionada
		If SRA->RA_TIPTKAL == "1"   		//Calculo por valor Fixo
       		cTab   := "S001"        
		ElseIf SRA->RA_TIPTKAL == "2" 		//Calculo por percentual 
			cTab   := "S002"
        Endif             
        nBusca := SALMES        
        
        // Calculo do Ticket Alimentacao
        If ( nLinha := fPosTab(cTab,nBusca,"<=",4) ) > 0
        	If cTab == "S001"       
        		nVlrAlim := fTabela(cTab,nLinha,5)
        		nVlrCalc := nVlrAlim * nQtRef
        	ElseIf cTab == "S002"
	        	nPercAlim := If(fTabela(cTab,nLinha,5) > nPercMax, nPercMax / 100, fTabela(cTab,nLinha,5)/ 100)
	        	nVlrCalc := nBusca * nPercAlim	
        	Endif
        	
        	//Verificar se o valor calculado é superior ao limite para pagto 
        	If nVlrCalc > SALMES * nPercMax / 100
				nVlrCalc := SALMES * nPercMax / 100
        	Endif
		Endif
		
		If nVlrCalc  > 0
		    // Grava o valor do Ticket Alimentação
			fGeraVerba(cPdTktAlim,nVlrCalc,nQtRef,,,,,,,,.T.)
		EndIf
	Endif
Endif

Return
                  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LocSeguro   º Autor  ³ Christiane Vieira ºData ³ 05/07/2010º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo de Seguro de Vida para o URUGUAI                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P11                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocSeguro(aCodfol)
Local nPercSeg := 0  // Percentual para de Calculo do Seguro
Local nPercMax  := 0

// Verba Utilizada no Calculo
Local cPdSeguro
Local nBusca, cTab, nLinha

If !FP_CODFOL(@aCodFol,SRA->RA_FILIAL)
	Return
Endif

cPdSeguro := aCodFol[154,1]		//-- Seguro de Vida
 
If aCodFol[154,1] # Space( 03 ) .And. SRA->RA_SEGUROV # Space( 02 )
    If  c__Roteiro == "FOL" .And. ( SRA->RA_TIPOPGT # "S" .Or. ( SRA->RA_TIPOPGT == "S" .And. lUltSemana)) 
        // Busca Tabela Relacionada - Valor do Teto de Seguro
        cTab   := "S003"
        If ( nLinha := fPosTab(cTab, xFilial(), "=", 1) ) > 0
	        nPercMax := fTabela(cTab,nLinha,7)
        Endif                                                                                              
        
        // Busca Tabela Relacionada
    	cTab   := "S006"        
	    nBusca := SRA->RA_SEGUROV

        // Calculo do Seguro de Vida
        If ( nLinha := fPosTab(cTab,nBusca,"<=",4) ) > 0
       		nPercSeg := fTabela(cTab,nLinha,6)
       		
       		If nPercSeg > nPercMax  //Verificar se o % do seguro é superior ao teto
       			nPergSeg := nPercMax
       		Endif
       		
			nVlrCalc := SALMES * nPercSeg / 100
       	Endif
		
		If nVlrCalc  > 0
		    // Grava o valor do Seguro de Vida
			fGeraVerba(cPdSeguro,nVlrCalc,,,,,,,,,.T.)
		EndIf
	Endif
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LocExceso     ºAutor ³ Christiane Vieira ºData ³ 05/07/2010º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo de Excesso de Beneficios Isentos, para o URUGUAI   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P11                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocExceso(aCodfol)

Local cVerbasBen       // Verbas referentes aos beneficios
Local cPdDifBenP	   // Diferença de Beneficios - Provento
Local cPdDifBenD	   // Diferença de Beneficios - Desconto

Local nPercMax  := 0
Local nTotBen	:= 0
Local nLimBen	:= 0
Local nDifBen	:= 0

Local cTab, nLinha

If !FP_CODFOL(@aCodFol,SRA->RA_FILIAL)
	Return
Endif

cVerbasBen := aCodFol[154,1] + '|' + aCodFol[050,1] + '|' + aCodFol[213,1] + '|' + aCodFol[725,1] + '|'
cVerbasBen += aCodFol[726,1] + '|' + aCodFol[717,1] + '|' + aCodFol[718,1] + '|' + aCodFol[719,1] + '|'

cPdDifBenP := aCodFol[931,1]		//-- Diferença de Beneficios - Provento
cPdDifBenD := aCodFol[932,1]		//-- Diferença de Beneficios - Desconto

If aCodFol[931,1] # Space( 03 ) .And. aCodFol[932,1] # Space( 03 )
    If  c__Roteiro == "FOL" .And. ( SRA->RA_TIPOPGT # "S" .Or. ( SRA->RA_TIPOPGT == "S" .And. lUltSemana)) 
        // Busca Tabela Relacionada - Valor do Teto de Seguro
        cTab   := "S003"
        If ( nLinha := fPosTab(cTab, xFilial(), "=", 1) ) > 0
	        nPercMax := fTabela(cTab,nLinha,8)
	        nLimBen := nBsBpsAuxUru * nPercMax / 100
	        
	        aEval(aPd,{ |X| nTotBen += If ( X[1] $ cVerbasBen, X[5] ,0)}) 
	        
	        nDifBen := nTotBen - nLimBen //Verifica se o total dos beneficios é superior ao limite 
	        If nDifBen > 0
				fGeraVerba(cPdDifBenP,nDifBen,,,,,,,,,.T.)	//Grava verba de Diferença de Benefícios - Provento
				fGeraVerba(cPdDifBenD,nDifBen,,,,,,,,,.T.)	//Grava verba de Diferença de Benefícios - Desconto
	        Endif
        Endif                                                                                             
    Endif
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocCJPPU  ºAutor  ³Tiago Malta         º Data ³  22/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função de calculo do CJPPU.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocCJPPU()

Local nBaseBps   := 0
Local aTabCJPPU  := {}
Local nQtdMes    := 0
Local nPosTab    := 0
Local nCJPPU     := 0

    
	IF SRA->RA_CJPPU $ "1" .AND. !EMPTY(SRA->RA_DTINICJ)
		 
		nQtdMes := DateDiffMonth( SRA->RA_DTINICJ , dDataBase )
	    
	    Aeval( aPd ,{ |X| SomaInc(X,4,@nBaseBps,,,,,,,aCodfol) })
	    
		fCarrTab( @aTabCJPPU, "S004", Nil)
		
		IF len(aTabCJPPU) > 0
		
			IF nQtdMes >= 12
			
				nPosTab:= fPosTab("S004", nBaseBps , "<=", 5)
				
				IF nBaseBps > 0 
					IF nPosTab == 0 .and. ( nBaseBps >= fTabela("S004", Len(aTabCJPPU)  , 5 ) )
						nCJPPU	:= fTabela("S004", Len(aTabCJPPU)  , 8 )
					ElseIF nPosTab == 1 // Tratamento para nao usar a categoria especial 
						nCJPPU  := fTabela("S004", 2               , 8 )
					Else
						nCJPPU  := fTabela("S004", nPosTab         , 8 )	
					Endif 
				ENDIF
				
			Else
		   		nCJPPU := fTabela("S004", 1        , 8 )
			Endif
			
			IF nCJPPU > 0 .AND. !EMPTY(aCodFol[710,1])
				FGeraVerba( aCodFol[710,1], nCJPPU )
			ENDIF
			
		ENDIF
		
	Endif  

Return()     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocFonSol ºAutor  ³Tiago Malta         º Data ³  23/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função de calculo do Fundo de Solidariedade.               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocFonSol()

Local cCodTab    := SRA->RA_FONSOL
Local aTabFonSol := {}
Local aTabBPC    := {}
Local nPosTab    := 0
Local nVlCota    := 0
Local nVlCotAd   := 0
Local nValBpc    := 0
Local nQtdBpc    := 0
Local nTBpc      := 0 
Local nBaseBps   := 0
Local nTBpcAd    := 0
                     
	IF !EMPTY(cCodTab)
		
		// Busca as verbas com incidencia em bps. 
	    Aeval( aPd ,{ |X| SomaInc(X,4,@nBaseBps,,,,,,,aCodfol) })	    
	    //Carrega Tabela de Fondo Solidariedad
		fCarrTab( @aTabFonSol, "S005", Nil)   
		//Carrega Tabela de Tetos
		fCarrTab( @aTabBPC   , "S003", Nil)
				
		IF ( len(aTabFonSol) > 0 ) .and. ( len(aTabBPC) > 0 )
            
           // Valor do Bpc
			nValBpc   := fTabela("S003", 1 , 4 )
		   // Conversao de Bps para Bpc
			nQtdBpc   := nBaseBps / nValBpc
			
			nPosTab := fPosTab("S005", cCodTab , "=", 4)
			
			IF nPosTab > 0 .and. nQtdBpc > 0
			   
				nTBpc := fTabela("S005", nPosTab , 6 )
				
				IF nQtdBpc >= nTBpc
					
					IF Month(dDataBase) == 9
						nVlCota := fTabela("S005", nPosTab , 8 )
					ELSEIF Month(dDataBase) == 10
						nVlCota := fTabela("S005", nPosTab , 9 )
					ELSEIF Month(dDataBase) == 11                  
						nVlCota := fTabela("S005", nPosTab , 10 )
					ELSEIF Month(dDataBase) == 12                  
						nVlCota := fTabela("S005", nPosTab , 11 )
					Endif
				
					nTBpcAd := fTabela("S005", nPosTab , 12 )
					
					IF nQtdBpc >= nTBpcAd .and. nTBpcAd <> 0
						
						IF Month(dDataBase) == 5
							nVlCotAd := fTabela("S005", nPosTab , 14 )
						ELSEIF Month(dDataBase) == 6
							nVlCotAd := fTabela("S005", nPosTab , 15 )
						ELSEIF Month(dDataBase) == 7                  
							nVlCotAd := fTabela("S005", nPosTab , 16 )
						ELSEIF Month(dDataBase) == 8                  
							nVlCotAd := fTabela("S005", nPosTab , 17 )
						Endif
					
					ENDIF
					
				ENDIF			
					
			ENDIF 
				
			IF nVlCota > 0 .and. !EMPTY(aCodFol[709,1])
				FGeraVerba( aCodFol[709,1], nVlCota )
			ENDIF
			
			IF nVlCotAd > 0 .and. !EMPTY(aCodFol[929,1])
				FGeraVerba( aCodFol[929,1], nVlCotAd )
			ENDIF
			
		ENDIF
		
	Endif

Return()       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocFocer  ºAutor  ³Tiago Malta         º Data ³  05/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função de calculo do Focer.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocFocer()

Local aTabFoc    := {}
Local cTpContr   := SRA->RA_TPCONTR
Local nPosTab    := 0
Local nBaseBps   := 0 
Local nPercPat   := 0
Local nPercObr   := 0
Local nValPatr   := 0    
Local nValObre   := 0
Local lIPDGer    := .F.
Local nSemanas   := 0
Local nMeses     := 0
        
	IF !EMPTY(SRA->RA_CATCONS)
		// Busca as verbas com incidencia em bps. 
	    Aeval( aPd ,{ |X| SomaInc(X,4,@nBaseBps,,,,,,,aCodfol) })	     
	    // Carrega Tabela Focer
		fCarrTab( @aTabFoc   , "S007", Nil)
				
		IF ( len(aTabFoc) > 0 ) 
			
			IF cTpContr == "1" .AND. c__Roteiro == "RES" 
				IF SRA->RA_CATFUNC == "M"
					nMeses   := DateDiffMonth(SRA->RA_ADMISSA,dDataBase)	
					IF nMeses >=  24
						nPosTab  := fPosTab("S007", cTpContr , "=", 4, "S" , "=", 7 )
						IF nPosTab == 0
							nPosTab  := fPosTab("S007", cTpContr , "=", 4)
						Endif
					Endif
				ELSEIF SRA->RA_CATFUNC <> "M"
					nSemanas := DateDiffDay(SRA->RA_ADMISSA,dDataBase) / 7 
					IF nSemanas >= 50
						nPosTab  := fPosTab("S007", cTpContr , "=", 4, "1" , "=", 7 )
						IF nPosTab == 0
							nPosTab  := fPosTab("S007", cTpContr , "=", 4)
						Endif					
					Endif
				Endif	 
			Else
				nPosTab  := fPosTab("S007", cTpContr , "=", 4) 
			Endif  

			IF nPosTab > 0
	   			nPercPat := fTabela("S007", nPosTab , 5 )
   				nPercObr := fTabela("S007", nPosTab , 6 )
   				
   				IF nPercPat > 0 .AND. !EMPTY(aCodFol[933,1])
   		   			nValPatr   := nBaseBps * ( nPercPat / 100 )
					FGeraVerba( aCodFol[933,1], nValPatr , nPercPat )
   				ENDIF  
   				
   				IF nPercObr > 0 .AND. !EMPTY(aCodFol[934,1])
   					nValObre   := nBaseBps * ( nPercObr / 100 )
   					FGeraVerba( aCodFol[934,1], nValObre , nPercObr )
   				ENDIF   				
   				
   			ENDIF 
   			
		ENDIF
		
	Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocFosvoc  ºAutor  ³Tiago Malta        º Data ³  07/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função de calculo do Fosvoc.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocFosvoc()

Local aTabFos    := {}
Local nBaseFos   := 0 
Local nPercPat   := 0
Local nPercObr   := 0
Local nValPatr   := 0    
Local nValObre   := 0
        
	IF !EMPTY(SRA->RA_CATCONS)
		// Busca as verbas com incidencia em Base Construção Civil. 
	    Aeval( aPd ,{ |X| SomaInc(X,33,@nBaseFos,,,,,,,aCodfol) })  
	    	     
	    // Carrega Tabela Fosvoc
		fCarrTab( @aTabFos   , "S010", Nil)
				
		IF ( len(aTabFos) > 0 )  

	   			nPercPat := fTabela("S010", 1 , 4 )
   				nPercObr := fTabela("S010", 1 , 5 )
   				
   				IF nPercPat > 0 .AND. !EMPTY(aCodFol[935,1])
   		   			nValPatr   := nBaseFos * ( nPercPat / 100 )
					FGeraVerba( aCodFol[935,1], nValPatr , nPercPat )
   				ENDIF  
   				
   				IF nPercObr > 0 .AND. !EMPTY(aCodFol[936,1])
   					nValObre   := nBaseFos * ( nPercObr / 100 )
   					FGeraVerba( aCodFol[936,1], nValObre , nPercObr )
   				ENDIF   				
   			
		ENDIF
		
	Endif

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LocAjusteIRPF ºAutor ³ Christiane Vieira ºData ³ 20/07/2010º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo de Ajuste Anual de Imposto de Renda, para o URUGUAIº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P11                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocAjusteIRPF(nBaseMes, nDedMes)
Local sCompIni  := Substr(GETMV('MV_FOLMES'),1,4) + '01'
Local sCompFim  := Substr(GETMV('MV_FOLMES'),1,4) + '11'
Local sComp13	:= Substr(GETMV('MV_FOLMES'),1,4) + '13'
Local nBaseIR   := 0
Local nDedIR    := 0
Local nRetIR    := 0
Local nVlDedImp := 0
Local nVlImp	:= 0
Local nValIR	:= 0                 
Local nTetoPerc	:= 0
Local nTetoVal	:= 0
Local nBaseIR13	:= 0
Local cVerbas	:= ""
Local nPercNucleo := 0
Local cAliasIR , cQuery, cTab, nLinha   

	cVerbas		:= "'" + aCodFol[015,1] + "', '" + aCodFol[066,1] + "', '" + aCodFol[937,1] + "', '" + aCodFol[027,1] + "', '" + aCodFol[071,1] + "', '" + aCodFol[938,1] + "'"

	cAliasIR 	:= GetNextAlias()                     
	
	cQuery		:= "SELECT SRD.RD_PD AS VERBA, SRD.RD_VALOR AS VALOR, SRD.RD_DATPGT AS DTPGTO FROM " + RetSqlName("SRD") + " SRD "
	cQuery 		+= "WHERE SRD.RD_FILIAL ='"	+ SRA->RA_FILIAL	+ "' AND "
	cQuery 		+= "SRD.RD_MAT ='"	   	+ SRA->RA_MAT		+ "' AND "
	cQuery 		+= "(SRD.RD_DATARQ BETWEEN '"	+ sCompIni		+ "' AND '" + sCompFim + "' OR SRD.RD_DATARQ = '" + sComp13 + "') AND "
	cQuery 		+= "SRD.RD_PD IN (" + cVerbas + ") AND "	
	cQuery 		+= "SRD.D_E_L_E_T_	= ' ' "
	
	cQuery		+= "UNION ALL ( SELECT SRI.RI_PD AS VERBA, SRI.RI_VALOR AS VALOR, SRI.RI_DATA AS DTPGTO FROM " + RetSqlName("SRI") + " SRI "
	cQuery 		+= "WHERE SRI.RI_FILIAL ='"	+ SRA->RA_FILIAL	+ "' AND "
	cQuery 		+= "SRI.RI_MAT ='"	   	+ SRA->RA_MAT		+ "' AND "
	cQuery 		+= "SRI.RI_PD IN (" + cVerbas + ") AND "
	cQuery 		+= "SRI.D_E_L_E_T_	= ' ' ) "	
	
	cQuery 		:= ChangeQuery( cQuery )		
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasIR )

	//Verificar os valores de: Base IRRF, Dedução e Retenção de IRRF de janeiro a novembro
	dbSelectArea( cAliasIR )
	While !( cAliasIR )->( Eof() )
		If (cAliasIR)->VERBA == aCodFol[015,1] .Or. (cAliasIR)->VERBA == aCodFol[027,1] //Base de IRRF
			nBaseIR += (cAliasIR)->VALOR
            If Substr((cAliasIR)->DTPGTO,5,2) == '12'      //Base de IRRF de dezembro
            	nBaseIR13 += (cAliasIR)->VALOR
            Endif
		ElseIf (cAliasIR)->VERBA == aCodFol[937,1] .Or. (cAliasIR)->VERBA == aCodFol[938,1] //Deduções de IRRF
			nDedIR += (cAliasIR)->VALOR			
		ElseIf (cAliasIR)->VERBA == aCodFol[066,1] .Or. (cAliasIR)->VERBA == aCodFol[071,1] //Retenção de IRRF 
			nRetIR += (cAliasIR)->VALOR		
		EndIf
		(cAliasIR)->( dbSkip() )
	Enddo
	(cAliasIR)->( dbCloseArea() )       
	
    //Somar as bases de IRRF e Deduções de IRRF do mês de dezembro
	nBaseIR += nBaseMes
	nDedIR  += nDedMes
	
	If nBaseIR > 0
	 	LocIRPFCalc(nBaseIR, aIRAno, @nVlImp)
	Endif 	
	If nDedIR > 0
	 	LocIRPFCalc(nDedIR, aIRDedAno, @nVlDedImp)
	Endif
	
	nValIr := Round(nVlImp - nVlDedImp, MsDecimais(1))
	
	//Verificar se o funcionario tem nucleo familiar na competência
	If (!Empty(SRA->RA_DTNCFAM) .And. GetMv( "MV_FOLMES") >= MesAno(SRA->RA_DTNCFAM)) .And. (Empty(SRA->RA_DTFNCFM) .Or. GetMv( "MV_FOLMES") <= MesAno(SRA->RA_DTFNCFM) )  
        // Busca Tabela Relacionada - Valor do Desconto de Núcleo Familiar
   	    cTab   := "S003"			
        If ( nLinha := fPosTab(cTab, xFilial('SRM'), "=", 1) ) > 0
	        nPercNucleo := Round(fTabela(cTab,nLinha,9), MsDecimais(1))
	        
	        nValIr    := nValIr * ((100 - nPercNucleo) / 100)
        Endif
	Endif	
	
	//O valor do IR de Dezembro será o valor devido no ano - o valor retido até novembro
	nValIr -= nRetIr
	
	//Verificar se o funcionario teve nucleo familiar no exercício
	If !Empty(SRA->RA_DTNCFAM) .And. MesAno(SRA->RA_DTNCFAM) >= sCompIni
        // Busca Tabela Relacionada - Valor do Desconto de Núcleo Familiar
   	    cTab   := "S003"			
        If ( nLinha := fPosTab(cTab, xFilial('SRM'), "=", 1) ) > 0
	        nTetoPerc := fTabela(cTab,nLinha,10)
	        
	        nTetoVal := (nBaseMes + nBaseIR13) * (nTetoPerc / 100)     
        Endif	
        
        //Verificar se o valor do IR encontrado é superior ao limite de desconto 
        If nTetoVal > 0 .And. nValIr > nTetoVal
  			nValIr := nTetoVal      
        Endif
	Endif
	
	If nBaseIR  > 0
		FGeraVerba(aCodFol[15,1],Round(nBaseIR,MsDecimais(1)),0.00,,,,,,,,)
	Endif
	If nDedIR  > 0
	 	FGeraVerba(aCodFol[937,1],Round(nDedIR,MsDecimais(1)),0.00,,,,,,,,)
	Endif 		
	If nValIR  > 0
	 	FGeraVerba(aCodFol[066,1],Round(nValIR,MsDecimais(1)),0.00,,,,,,,,)
	Endif 				
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SETIRANUALLOC ³ Autor ³ Christiane Vieira³ Data ³ 21.07.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega Variaveis com as aliquotas de IR Anual (URUGUAI)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SETIRANUALLOC()
Local aIrAux	:= {}
Local nX		:= 1             
Local aTabBPC   := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Carrega o valor do BPC |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
   	fCarrTab( @aTabBPC   , "S003", Nil)
	
	IF Len(aTabBPC) > 0
		nVlBPC   := Round(fTabela("S003", 1 , 4 ), 2) // Valor do Bpc
	Endif

	If nVlBPC > 0
		aIrAno	  := {}
		aIrDedAno := {}	
	                                                                 
		fCarrTab( @aIrAux,"S015")
		For nX := 1 to Len(aIrAux)	
			Aadd(aIRAno, { aIRAux[nX, 6] * nVlBPC , aIRAux[nX, 7] / 100 } )
		Next
	
		aIrAux	:= {}
		fCarrTab( @aIrAux,"S016")
		For nX := 1 to Len(aIrAux)	
			Aadd(aIrDedAno, { aIRAux[nX, 6] * nVlBPC , aIRAux[nX, 7] / 100 } )
		Next	
		Return ( .T. )		
	Else
		Return ( .F. )
	Endif
Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LocIndeniza   ³ Autor ³ Christiane Vieira³ Data ³ 29.07.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o valor da indenização para funcionárias demitidas ³±±
±±³          ³ durante a gravidez ou período de licensa maternidade - URU ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LocIndeniza(aCodfol)
Local cPdIndeniza	:= ""
Local nIndMat		:= 0
Local nValInd		:= 0

If !FP_CODFOL(@aCodFol,SRA->RA_FILIAL)
	Return
Endif

cPdIndeniza := aCodFol[939,1]		//-- Indenização de Maternidade

If !aIncRes[09] == 'N'
	nIndMat := Val(aIncRes[09])
	nValInd := SalMes * nIndMat
	
	If nValInd  > 0
	    // Grava o valor do Seguro de Vida
		fGeraVerba(cPdIndeniza,nValInd,nIndMat,,,,,,,,.T.)
	EndIf	
Endif
Return

    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ F103IR	³ Autor ³ Tania Bronzeri		³ Data ³ 12/07/2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Busca bases e valores de IR para impressao Rel. F103	  	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ 		 	 	 	 	 	 	 	 	 	 	 	 	 	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 1 - Ano da Competência (AAAA)				 	 	 	    ³±±
±±³          ³ 2 - Mes da Competência (MM) 				  	 	 	 	    ³±±
±±³          ³ 	   	 	 	 	 	 	 	 	 	 	 	 	 	 	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com o seguinte conteudo:             	 	 	 	    ³±±
±±³          ³ 1 - Somatoria das verbas de Base do IR.		 	 	 	    ³±±
±±³          ³ 2 - Somatoria dos valores retidos de Base do IR.		        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico	 	 	 	 	 	 	 	 	 	 	 	 	    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function F103IR(cAno, cMes)
Local aSaveArea		:= GetArea()       
Local aRetorno		:= {0,0}
Local c302Verbas	:= ""
Local c352Verbas	:= ""  
Local cQry302		:= "%"
Local cQry352		:= "%" 
Local cQryDat		:= "%'"+cAno+cMes+"'%"
Local cAliasQry		:= GetNextAlias()
Local nI			:= 0

dbSelectArea( "RCA" )
dbSetOrder(1)
If dbSeek(xFilial("RCA") + "P_F103C302" )
	c302Verbas := Alltrim(&(RCA->RCA_CONTEU))
EndIf
If dbSeek(xFilial("RCA") + "P_F103C352" )
	c352Verbas := Alltrim(&(RCA->RCA_CONTEU))
EndIf
                         
For nI = 1 To Len(c302Verbas) Step 3
	cQry302 += Subs(c302Verbas,nI,3)
	If (nI+3) <= Len(c302Verbas)
		cQry302	+= "," 
	EndIf
Next                                  
For nI = 1 To Len(c352Verbas) Step 3
	cQry352 += "'" + Subs(c352Verbas,nI,3) + "'"
	If (nI+3) <= Len(c352Verbas)
		cQry352	+= "," 
	EndIf
Next                                  
                            
If !Empty(cQry302)
	cQry302 += "%"
EndIf
If !Empty(cQry352)
	cQry352 += "%"
EndIf

BeginSql alias cAliasQry                             
	
	SELECT SUM(BASE) BASEIR, SUM(VALIR) VALORIR 
	FROM (
		SELECT SUM(SRC1.RC_VALOR) BASE, 0 VALIR 
		FROM %table:SRC% SRC1 
		WHERE SRC1.RC_PD IN (%exp:cQry302%) AND LEFT(SRC1.RC_DATA,6) = %exp:cQryDat% AND SRC1.%notDel%
		
		UNION ALL
		
		SELECT 0 BASE, SUM(SRC2.RC_VALOR) 
		FROM %table:SRC% SRC2 
		WHERE SRC2.RC_PD IN (%exp:cQry352%) AND LEFT(SRC2.RC_DATA,6) = %exp:cQryDat% AND SRC2.%notDel%
	
		UNION ALL
	
		SELECT SUM(SRD1.RD_VALOR) BASE, 0 VALIR 
		FROM %table:SRD% SRD1 
		WHERE SRD1.RD_PD IN (%exp:cQry302%) AND LEFT(SRD1.RD_DATPGT,6) = %exp:cQryDat% AND SRD1.%notDel%
		
		UNION ALL
		
		SELECT 0 BASE, SUM(SRD2.RD_VALOR) VALIR 
		FROM %table:SRD% SRD2 
		WHERE SRD2.RD_PD IN (%exp:cQry352%) AND LEFT(SRD2.RD_DATPGT,6) = %exp:cQryDat% AND SRD2.%notDel%
	) BASEVALIR
	
EndSql                  
 
DbSelectArea(cAliasQry)
       
aRetorno[1]	:= (cAliasQry)->BASEIR
aRetorno[2] := (cAliasQry)->VALORIR

RestArea(aSaveArea)

Return (aRetorno)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LocFonSoc  ºAutor  ³Tiago Malta        º Data ³  28/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função de calculo dos Fondos Sociales .                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LocFonSoc()

Local aTFonSoc    := {}
Local nBaseCC   := 0 
Local nPercPat   := 0
Local nPercObr   := 0
Local nValPatr   := 0    
Local nValObre   := 0
        
	IF !EMPTY(SRA->RA_CATCONS)
		// Busca as verbas com incidencia em Base Construção Civil. 
	    Aeval( aPd ,{ |X| SomaInc(X,33,@nBaseCC,,,,,,,aCodfol) })  
	    	     
	    // Carrega Tabela Fondos Sociales
		fCarrTab( @aTFonSoc   , "S011", Nil)
				
		IF ( len(aTFonSoc) > 0 )  

	   			nPercPat := fTabela("S011", 1 , 4 )
   				nPercObr := fTabela("S011", 1 , 5 )
   				
   				IF nPercPat > 0 .AND. !EMPTY(aCodFol[940,1])
   		   			nValPatr   := nBaseCC * ( nPercPat / 100 )
					FGeraVerba( aCodFol[940,1], nValPatr , nPercPat )
   				ENDIF  
   				
   				IF nPercObr > 0 .AND. !EMPTY(aCodFol[941,1])
   					nValObre   := nBaseCC * ( nPercObr / 100 )
   					FGeraVerba( aCodFol[941,1], nValObre , nPercObr )
   				ENDIF   				
   			
		ENDIF
		
	Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCalHeFator ºAutor  ³Marcelo Silveira  º Data ³  11/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula o salario DIA/Hora para o calculo de Horas         º±±
±±º          ³ Extraordinarias - Chile                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fCalHeFator()

Local nTipoPgt	:= 0
Local nJornada	:= 0
Local nFator	:= 0
Local AuxSalMes	:= 0
Local AuxSalDia	:= 0
Local nSalHE	:= SalMes

If Empty( dDataRef )
	dDataRef := cToD( "01/" + SubStr( cFolMes, 5, 2 ) + "/" + SubStr( cFolMes, 1, 4 ) )
EndIf

If Empty( aFatorHe )
	fCarrTab( @aFatorHe, "S001", dDataRef ) //Carrega fatores para calculo de Hora Extra
EndIf

nTipoPgt := If( SRA->RA_TIPOPGT=='S', 7, 6 )
nJornada := SRA->RA_HRSEMAN
                                
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Nao existe tratamento para diarista. Caso seja implementado, sera    ³
³preciso criar um campo na SRA para indicar a jornada de 5 ou 6 dias  ³
³para utilizacao dos campos 8 e 9 da tabela de fatores - S001         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

//Valor da hora para pagamento de Hora Extra
If Len(aFatorHe) > 0
	nFator := Ascan( aFatorHe, { |x| x[5]==nJornada  } )
	If nFator > 0
		nSalHE := SalMes * aFatorHe[nFator, nTipoPgt]
	EndIf
EndIf

//Valor do dia para pagamento de Hora Extra
If SRA->RA_TIPOPGT = "M" .And. SRA->RA_CATFUNC $ "M*C*P*A*E*I"
	AuxSalMes  := nSalHE * SRA->RA_HRSMES
	AuxSalDia  := AuxSalMes / 30
ElseIf SRA->RA_TIPOPGT = "S" .And. SRA->RA_CATFUNC $ "S*T"
	AuxSalMes  := nSalHE * 7 * 30
	AuxSalDia  := AuxSalMes * 7	
EndIf	

//Se nao encontrar o fator utiliza o salario sem aplicacao do fator
SalHora	:= If( nSalHE > 0, nSalHE, SalHora )
Saldia	:= If( AuxSalDia > 0, AuxSalDia, Saldia )

Return(.T.)