#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEXACU  ³ Autor   ³ IP Rh - Inovacao                   ³ Data ³ 19/04/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcoes Genericas para as rotinas de Acumuladores                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS/FNC   ³  Motivo da Alteracao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aldo Marini ³19/04/2012³REQ199-P12    ³Desenvolvimento Inicial                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fBuscaCrit     ºAutor  ³Microsiga           º Data ³  11/25/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o criterio e sequnencia de acumulacao da verba           º±±
±±º          ³                                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function fBuscaCrit(cCriterio , cSequencia , cAliasCri, cProcesso, cRoteiro, cVerba, cCritAux, cSeqAux)

Local aArea			:= GetArea() 
Local nPos 			:= 0 
Local lRetOk		:= .T.
Local cRotAux		:= ""
Local nTam			:= 1
Local aTamSRM		:= {}
Local aFieldLog		:= {}
Local aCriterio		:= {}

Default cAliasCri	:= cAliasSRC
Default cProcesso	:= (cAliasCri)->RC_PROCES
Default cRoteiro	:= (cAliasCri)->RC_ROTEIR
Default cVerba		:= (cAliasCri)->RC_PD
Default cCritAux	:= AllTrim((cAliasRCH)->RCH_CRITER)
Default cSeqAux		:= AllTrim((cAliasRCH)->RCH_SEQUE)

/* 
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carrega todos os criterios e sequencias de acumulacao        ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cCritAux	:= AllTrim(cCritAux)
cSeqAux		:= AllTrim(cSeqAux)

While nTam < Len(cCritAux) 
	aadd(aCriterio, {substr(cCritAux,nTam,2) , substr(cSeqAux,nTam,2) } ) 
	nTam +=3 
Enddo 

If (cPaisLoc $ "MEX|DOM|COS|ARG")	//#/COL
	/* 
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Traz qual o criterio de acumuladao da verba x processo x Rot ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	dbSelectArea("SRM")
	dbSetorder(3) 
	
	cSequencia := ""
	
	If dbSeek(xFilial("SRM") + cProcesso + cRoteiro + cVerba ) 
		cCriterio	:= SRM->RM_CODCRI 
		//Se para o roteiro indicar que nao deve acumular deixar criterio em branco para nao gravar no RG7.
		IF SRM->(Type("RM_GERAACU")) # "U" .AND. SRM->RM_GERAACU = "2"
			cCriterio := ""
		Endif		
		If !Empty( cCriterio )  .and. ;
		   ( nPos:= ( Ascan(aCriterio, {|x| x[1] = cCriterio }  )  ))  > 0  
			cSequencia := aCriterio[nPos,2] 
		Endif
	Else
		//Se nao econtrou o registro, verifica se o roteiro e de rescisao=finiquitos
		If ( fGetCalcRot("A") == cRoteiro )
			
			cRotAux := fGetCalcRot("4")
			
			If ( dbSeek(xFilial("SRM") + cProcesso + cRotAux + cVerba ) )
				cCriterio	:= SRM->RM_CODCRI 
				//Se para o roteiro indicar que nao deve acumular deixar criterio em branco para nao gravar no RG7.
				IF SRM->(Type("RM_GERAACU")) # "U" .AND. SRM->RM_GERAACU = "2"
					cCriterio := ""
				Endif		
				If !Empty( cCriterio )  .and. ;
				   ( nPos:= ( Ascan(aCriterio, {|x| x[1] = cCriterio }  )  ))  > 0  
					cSequencia := aCriterio[nPos,2] 
				Endif				
			Else
				//Gerar Log
				If Empty(aLogErros[8])
					aFieldLog := { "RM_FILIAL", "RM_PROCES", "RM_CALCULO", "RM_VERBA" }
					aAdd( aLogErros[8], Gp120CabLog( "SRM", aFieldLog, @aTamSRM ) ) 		// Cabecalho do Log de Erros
					aAdd( aLogErros[8], "" )
				EndIf

				aAdd( aLogErros[8],	xFilial("SRM") + cProcesso + cRoteiro + cVerba)	
				
			EndIf
					
		Else

			cCriterio	:= SRM->RM_CODCRI 
			//Se para o roteiro indicar que nao deve acumular deixar criterio em branco para nao gravar no RG7.
			IF SRM->(Type("RM_GERAACU")) # "U" .AND. SRM->RM_GERAACU = "2"
				cCriterio := ""
			Endif		
			If !Empty( cCriterio )  .and. ;
			   ( nPos:= ( Ascan(aCriterio, {|x| x[1] = cCriterio }  )  ))  > 0  
				cSequencia := aCriterio[nPos,2] 
			Endif		
		
		EndIf
		
	Endif
	
	If Empty(cSequencia)  
		lRetOk:= .F.                      
	Endif 
Else    
	cSequencia := ""                      
	dbSelectArea("SRV")
	dbSetOrder(1)
	If dbSeek(xFilial("SRV") + cVerba )
	   If !Empty(SRV->RV_CODCRI)
	      cCriterio := SRV->RV_CODCRI
	      If !Empty( cCriterio )  .and. ( nPos:= ( Ascan(aCriterio, {|x| x[1] = cCriterio } ) )) > 0
			 cSequencia := aCriterio[nPos,2] 
		  Endif
	   Endif
	Endif	   	  
	If Empty(cSequencia) .And. cPaisLoc <> "COL"
		lRetOk:= .F.                      
	Endif 
Endif	

RestArea(aArea) 
Return(lRetOk)
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGrvAcumulador ºAutor  ³Microsiga           º Data ³  11/25/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua a gravacao dos campos de acumuladores                    º±±
±±º          ³                                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
function fGrvAcumulador( cCriterio , cSequencia , lRecriar , cAliasArq , aMesesAcu , lApagaAcu, cMesProc, cAnoProc, lGeraLog )

Local lAchou 		:= .T. 
Local cAnoIni 		:= ""
Local cAnoFim		:= ""
Local cMesIni		:= "" 
Local cOrder 		:= ""
Local cWhere 		:= ""
Local cAliasQry 	:= ""
Local cPrefCpo		:= PrefixoCpo("SRC")
Local nX			:= 0

Default lRecriar	:= .F.
Default cAliasArq	:= cAliasSRC
Default aMesesAcu	:= {}
Default lApagaAcu	:= .F.
If cPaisLoc == "BRA"
	Default cMesProc	:= ( cAliasRCH )->RCH_MES 
	Default cAnoProc	:= ( cAliasRCH )->RCH_ANO 
EndIf
Default lGeraLog	:= .F.

cAnoIni := cAnoProc
cAnoFim	:= cAnoProc

If lRecriar 
	cPrefCPO := PrefixoCpo("SRD")
Endif

#IFDEF TOP

		cAliasQry := GetNextAlias()
		
		cOrder := "% RG9.RG9_FILIAL, RG9.RG9_CODCRI %"
		cWhere := "% RG9.RG9_FILIAL = '" + xFilial("RG9") +"' AND RG9.RG9_CODCRI = '" + cCriterio + "' AND %"
		
		cFromTable := "% "+RetSqlName("RG9")+" RG9 %"
				
		BeginSql alias cAliasQry			
			SELECT 		RG9.RG9_MESINI
			FROM 		%exp:cFromTable%
			WHERE 		%exp:cWhere%
						RG9.%NotDel%
			ORDER BY    %exp:cOrder%				
		EndSql
		
		cMesIni	:= (cAliasQry)->(RG9_MESINI)
		
		(cAliasQry)->(dbCloseArea())	

#ELSE

	//Filial + Processo + Roteiro+ Anofim + AnoIni + Mat + Pd + CodCri + Sequencia 
	DbSelectArea("RG9")
	If dbSeek( xFilial("RG9") + cCriterio ) 
		cMesIni	:= RG9->RG9_MESINI 
	Endif

#ENDIF

DbSelectArea("RG7")
dbSetOrder(3)               

If Val(cMesIni) > 1
	If Val(cMesProc) >= Val(cMesIni)
		cAnoFim := STRZERO( Val(cAnoProc)+ 1 ,4) 
	Else
		cAnoIni := STRZERO( Val(cAnoProc)- 1 ,4) 
	EndiF
EndIf

#IFDEF TOP

		cAliasQry := GetNextAlias()
		
		cOrder := "%"
		cOrder += " RG7.RG7_FILIAL, RG7.RG7_PROCES, RG7.RG7_ANOFIM, RG7.RG7_ANOINI, RG7.RG7_MAT, "
		cOrder += " RG7.RG7_PD, RG7.RG7_CODCRI "
		cOrder += "%"

		cWhere := "%"
		cWhere += " RG7.RG7_FILIAL = '" + &(cAliasArq+"->"+cPrefCPO+"_FILIAL " ) + "' AND "
		cWhere += " RG7.RG7_PROCES = '" + &(cAliasArq+"->"+cPrefCPO+"_PROCES " ) + "' AND " 
		cWhere += " RG7.RG7_ANOFIM = '" + cAnoFim + "' AND "
		cWhere += " RG7.RG7_ANOINI = '" + cAnoIni + "' AND "
		cWhere += " RG7.RG7_MAT    = '" + &(cAliasArq+"->"+cPrefCPO+"_MAT " ) + "' AND "
		cWhere += " RG7.RG7_PD     = '" + &(cAliasArq+"->"+cPrefCPO+"_PD" ) + "' AND "
		cWhere += " RG7.RG7_CODCRI = '" + cCriterio + "' AND "
		cWhere += "%"

		cFromTable := "% "+RetSqlName("RG7")+" RG7 %"
				
		BeginSql alias cAliasQry			
			SELECT 		RG7.R_E_C_N_O_ NRECNO
			FROM 		%exp:cFromTable%
			WHERE 		%exp:cWhere%
						RG7.%NotDel%
			ORDER BY    %exp:cOrder%				
		EndSql
		
		If ( (cAliasQry)->NRECNO == 0 )
			lAchou := .F.
		Else
			RG7->(dbGoTo((cAliasQry)->NRECNO))
		EndIf
		
		(cAliasQry)->(dbCloseArea())
		
#ELSE

	If !RG7->(dbSeek(  &(cAliasArq+"->"+cPrefCPO+"_FILIAL " ) + ;
						&(cAliasArq+"->"+cPrefCPO+"_PROCES " ) + ;
						cAnoFim + cAnoIni + ;
						&(cAliasArq+"->"+cPrefCPO+"_MAT " ) + ;
						&(cAliasArq+"->"+cPrefCPO+"_PD" ) + cCriterio ) )
		lAchou := .F.
	EndIf

#ENDIF
	
If Empty(cSequencia)
	cSequencia := cMesIni
EndIf

If !lAchou 
	RecLock("RG7",.T.)
	RG7->RG7_FILIAL	:= &(cAliasArq+"->"+cPrefCPO+"_FILIAL " )
	RG7->RG7_PROCES	:= &(cAliasArq+"->"+cPrefCPO+"_PROCES " )
	RG7->RG7_ANOINI	:= cAnoIni   
	RG7->RG7_ANOFIM	:= cAnoFim
	RG7->RG7_MAT	:= &(cAliasArq+"->"+cPrefCPO+"_MAT " )
	RG7->RG7_PD		:= &(cAliasArq+"->"+cPrefCPO+"_PD" )
	RG7->RG7_CODCRI	:= cCriterio 
	RG7->RG7_SEQACU	:= cMesIni
Else 
	RecLock("RG7",.F.,.T.)
Endif 

If lRecriar
	RG7->RG7_USUARI := UsrRetName(RetCodUsr())
	RG7->RG7_DTATUA :=	DtoC(Date())
	RG7->RG7_ORIGEM := "G"
Endif

If lApagaAcu
	For nX := 1 to Len(aMesesAcu)
		&("RG7->RG7_HRS" + aMesesAcu[ nX ] ) := 0		
		&("RG7->RG7_ACUM" + aMesesAcu[ nX ] ) := 0
	Next
Endif

If Val(cSequencia ) == 1 
	RG7->RG7_HRS01  += &(cAliasArq+"->"+cPrefCPO+"_HORAS"  )
	RG7->RG7_ACUM01 += &(cAliasArq+"->"+cPrefCPO+"_VALOR"  )
ElseIf 	Val(cSequencia ) == 2 
	RG7->RG7_HRS02  += &(cAliasArq+"->"+cPrefCPO+"_HORAS"  )
	RG7->RG7_ACUM02 += &(cAliasArq+"->"+cPrefCPO+"_VALOR"  )
ElseIf 	Val(cSequencia ) == 3 
	RG7->RG7_HRS03  += &(cAliasArq+"->"+cPrefCPO+"_HORAS"  )
	RG7->RG7_ACUM03 += &(cAliasArq+"->"+cPrefCPO+"_VALOR"  )
ElseIf 	Val(cSequencia ) == 4 
	RG7->RG7_HRS04  += &(cAliasArq+"->"+cPrefCPO+"_HORAS"  )
	RG7->RG7_ACUM04 += &(cAliasArq+"->"+cPrefCPO+"_VALOR"  )
ElseIf Val(cSequencia ) == 5	
	RG7->RG7_HRS05  += &(cAliasArq+"->"+cPrefCPO+"_HORAS"  )
	RG7->RG7_ACUM05 += &(cAliasArq+"->"+cPrefCPO+"_VALOR"  )
ElseIf 	Val(cSequencia ) == 6
	RG7->RG7_HRS06  += &(cAliasArq+"->"+cPrefCPO+"_HORAS"  )
	RG7->RG7_ACUM06 += &(cAliasArq+"->"+cPrefCPO+"_VALOR"  )
ElseIf 	Val(cSequencia ) == 7
	RG7->RG7_HRS07  += &(cAliasArq+"->"+cPrefCPO+"_HORAS"  )
	RG7->RG7_ACUM07 += &(cAliasArq+"->"+cPrefCPO+"_VALOR"  )
ElseIf Val(cSequencia ) == 8	
	RG7->RG7_HRS08  += &(cAliasArq+"->"+cPrefCPO+"_HORAS"  )
	RG7->RG7_ACUM08 += &(cAliasArq+"->"+cPrefCPO+"_VALOR"  )
ElseIf 	Val(cSequencia ) == 9
	RG7->RG7_HRS09  += &(cAliasArq+"->"+cPrefCPO+"_HORAS"  )
	RG7->RG7_ACUM09 += &(cAliasArq+"->"+cPrefCPO+"_VALOR"  )
ElseIf 	Val(cSequencia ) == 10
	RG7->RG7_HRS10  += &(cAliasArq+"->"+cPrefCPO+"_HORAS"  )
	RG7->RG7_ACUM10 += &(cAliasArq+"->"+cPrefCPO+"_VALOR"  )
ElseIf 	Val(cSequencia ) == 11
	RG7->RG7_HRS11  += &(cAliasArq+"->"+cPrefCPO+"_HORAS"  )
	RG7->RG7_ACUM11 += &(cAliasArq+"->"+cPrefCPO+"_VALOR"  )
ElseIf 	Val(cSequencia ) == 12
	RG7->RG7_HRS12  += &(cAliasArq+"->"+cPrefCPO+"_HORAS"  )
	RG7->RG7_ACUM12 += &(cAliasArq+"->"+cPrefCPO+"_VALOR"  )
ElseIf Val(cSequencia ) == 13
	RG7->RG7_HRS13  += &(cAliasArq+"->"+cPrefCPO+"_HORAS"  )
	RG7->RG7_ACUM13 += &(cAliasArq+"->"+cPrefCPO+"_VALOR"  )
Endif 

If 	cPaisLoc $ "PAR"
	RG7->RG7_ORIGEM := &(cAliasArq+"->"+cPrefCPO+"_TIPO2" )
Endif

MsUnlock()

If lGeraLog
	// Campos da tabela SQS a serem enviadas para o Log
	//Filial			RG7_FILIAL
	//Matrícula			RG7_MAT+"-"+RA_NOME
	//Processo			RG7_PROCES
	//Verba				RG7_PD
	//Ano Inicial		RG7_ANOINI
	//Ano Final			RG7_ANOFIM
	//Critério			RG7_CODCRI
	//Seq. Acumulação	RG7_SEQACU

	If Ascan(aLogDet, {|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7]+x[8] = RG7->RG7_FILIAL+RG7->RG7_MAT+RG7->RG7_PROCES+RG7->RG7_PD+RG7->RG7_ANOINI+RG7->RG7_ANOFIM+RG7->RG7_CODCRI+RG7->RG7_SEQACU }  ) == 0
		aAdd( aLogDet , { RG7->RG7_FILIAL,RG7->RG7_MAT,RG7->RG7_PROCES,RG7->RG7_PD,RG7->RG7_ANOINI,RG7->RG7_ANOFIM,RG7->RG7_CODCRI,RG7->RG7_SEQACU }  )
	Endif
Endif

Return ( Nil ) 
