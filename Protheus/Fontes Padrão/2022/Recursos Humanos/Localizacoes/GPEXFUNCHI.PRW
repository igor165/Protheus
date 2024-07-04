#INCLUDE "PROTHEUS.CH"
#INCLUDE "SCOPECNT.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MkNewPerSRFºAutor  ³Microsiga          º Data ³  08/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cálculo días derecho para chile                             º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³   BOPS/FNC   ³  Motivo da Alteracao           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Camargo   ³25/11/2015³TTLRYO        ³Cambio condiciones para generar ³±±
±±³            ³          ³              ³nuevo registro				  ³±±
±±³M.Camargo   ³08/09/2016³              ³Merge v12.1.13                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MkNewSRFCHI(cFilSra, cMat, cPdSrf, dDateIni,lMod,lProg)  
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local lFound	:= .F. 
	Local lDtNova	:= .T.
	Local nDaysRef	:= 0 
	Local dDatePer	:= CToD("  /  /  ") 
	Local dDateRec	:= CToD("  /  /  ") 
	Local dDateFinish := CToD("  /  /  ") 
	Local dDatePerAtu := CToD("  /  /  ")
	Local cFilSRF	:= ""     
	Local cProcess	:= ""
	Local cPDProg		:= fGetCodFol("1383")    //Id días progresivos
	Local cZonaExt	:= ""             
	Local dRFDTFim	:= CtOD(" / / ")              
	Default cPDSrf 	:= fGetCodFol("0072") 	//Verba de ferias	      
	Default lMod := .F.	                        
	Default lProg := .F.	                           
	If Type("cPerFeAc") == "U"
		cPerFeAc := SuperGetMv("MV_FERPAC", NIL, "N") // Ferias por ano civil 
	EndIf

	If(!(SRA->(RA_FILIAL+RA_MAT)) ==(cFilSra + cMat))
		DbSelectArea("SRA")        
		SRA->(DbSetOrder( RetOrdem("SRA", "RA_FILIAL+RA_MAT") ))
		lFound := SRA->(DbSeek(cFilSra + cMat))
	Else
		lFound := .T.
	EndIf
	
	If(lFound) .and. !(SRA->RA_SITFOLH == "D") .And. dDateIni >= SRA->RA_ADMISSA
		cProcess := SRA->RA_PROCES			
		//Posiciona nos periodos de dia de direito do funcionadio
		DbSelectArea("SRF")
		SRF->(DbSetOrder( RetOrdem( "SRF", "RF_FILIAL+RF_MAT+RF_PD+DTOS(RF_DATABAS)" ) ))  
	
		If FWModeAccess("SRF") == "C"
			cFilSRF := Space(FWGETTAMFILIAL)
		Else
			cFilSRF:= cFilSra
		EndIf
	
		lFound := SRF->(DbSeek( cFilSrf + cMat + cPdSRF ))
		
		dDateFinish := CToD("  /  /  ")
		If(lFound)   
			nI := 1       
			While ((SRF->( RF_FILIAL + RF_MAT + RF_PD )) == (cFilSrf + cMat + cPdSRF))
				//Nao considera periodos vencidos ou pagos
				If Empty(SRF->RF_STATUS) .Or. SRF->RF_STATUS == "1"
					dDatePer	:= SRF->RF_DATABAS
					dRFDTFim	:= SRF->RF_DATAFIM  //04/01/2011
				EndIf
				SRF->(dbSkip())
				nI ++
			EndDo	
		
			//Checa se pelo menos uma data eh superior ao inicio do ultimo periodo cadastrado
			//esta situacao so eh possivel na primeira vez (reingresso ou reconhecimento)
			If (cPaisLoc # "ARG") .And. (Type("SRA->RA_FECREI") # "U" .And. !Empty(SRA->RA_FECREI))
				lDtNova	 := SRA->RA_FECREI >= dDatePer .Or. SRA->RA_DTREC >= dDatePer
			EndIf 
        Endif
		If cPaisLoc # "ARG" 
			If Type("SRA->RA_DTREC") # "U" .And. !Empty(SRA->RA_DTREC) //Campo só existe ARG/MEX/BOL - ARG nao usa no fechamento
				dDateRec := SRA->RA_DTREC                  
			Else
	   			If Type("SRA->RA_FECREI") # "U" .And. !Empty(SRA->RA_FECREI) //Campo só existe MEX/BRA
					dDateRec := SRA->RA_FECREI
				Else 
					dDateRec := SRA->RA_ADMISSA
				EndIf                              
			EndIf
		EndIf
		
		
		//Considera a data do ultimo periodo somente se nao for o primeiro reingresso ou reconhecimento
		If (cPaisLoc # "ARG") .And. Type("SRA->RA_FECREI") # "U"
			If(!Empty(dDateFinish))
				If !lDtNova .Or. ( Empty(SRA->RA_FECREI) .Or. Empty(SRA->RA_DTREC) )
					dDateIni := DaySum( dDateFinish, 1)	
				EndIf
			EndIf
	    Endif
	    
		If (cPaisLoc # "ARG") .And. ((Type("SRA->RA_FECREI") # "U" .And. !Empty(SRA->RA_FECREI)))
			dDateIni := CTOD(STRZERO(Day(SRA->RA_FECREI),2)+"/"+STRZERO(Month(SRA->RA_FECREI),2)+"/"+STRZERO(Year(dDateIni),4))
		ElseIf cPerFeAc == "S"
			dDateIni := CTOD("01/01/"+STRZERO(Year(YearSum(dDateIni, 1)),4))
		Else
			If (STRZERO(Day(SRA->RA_ADMISSA),2)) == "01" .AND.  STRZERO(Month(SRA->RA_ADMISSA),2) == "01"
				dDateIni := CTOD(STRZERO(Day(SRA->RA_ADMISSA),2)+"/"+STRZERO(Month(SRA->RA_ADMISSA),2)+"/"+STRZERO(Year(dDateIni) + 1 ,4))
			Else
				dDateIni := CTOD(STRZERO(Day(SRA->RA_ADMISSA),2)+"/"+STRZERO(Month(SRA->RA_ADMISSA),2)+"/"+STRZERO(Year(dDateIni),4))
			EndIf
		EndIf
			    
		dDatePerAtu := cToD( STRZERO(Day(dDateIni),2)+ "/"+RCH->RCH_MES+"/"+RCH->RCH_ANO )
   		dDateFinish := YearSum(dDateIni, 1) //Data RCH_DTINI, mas ano incrementando  + 1
		dDateFinish := DaySub(dDateFinish, 1)

		cZonaExt := POSICIONE("RGC",1,XFILIAL("RGC")+SRA->RA_KEYLOC,"RGC_EXTREM")
		cZonaExt := iif(cZonaExt <> "S", "N",cZonaExt)
		
	   nDaysRef := GetDDCHI(IIF(lMod,RCH->RCH_DTFIM,dDateRec),SRA->RA_FECVAC , cZonaExt,.F.)

			    		
		If FWModeAccess("SRF") == "C"
			cFilSRF := Space(FWGETTAMFILIAL)
		Else
			cFilSRF:= cFilSra
		EndIf
		
		//Checa se o periodo jah existe, e tambem se jah se passou 12 meses do ultimo periodo valido.
		If !( SRF->(dbSeek( cFilSRF + SRA->RA_MAT + cPdSrf + DtoS(dDateIni))) ) .And. ;
			If(cPerFeAc <> "S",( Empty(dDatePer) .Or. (dRFDTFim <= RCH->RCH_DTFIM) ),.T.)
		
			If !lProg  .or. (lMod .and. !lProg)
				RecLock( "SRF" , .T. )                                                
			
				SRF->RF_FILIAL	:= cFilSRF
				SRF->RF_MAT		:= cMat
				SRF->RF_PD		:= cPdSrf				//Verba lancamento 
				SRF->RF_DATABAS := dDateIni				//Data Inicio do Periodo
				SRF->RF_DATAFIM := dDateFinish			//Data Fim do Periodo
				SRF->RF_DIASDIR := nDaysRef    			//Calculado considerando anos de empresa
				SRF->RF_DFERVAT := 0	        		//Dias vencidos
				SRF->RF_DIASANT := 0             		//Dias antecipados
				SRF->RF_DFERANT := 0        			//Saldo
				SRF->RF_STATUS	:= "1"
				SRF->RF_FERCOLE := "N"
				SRF->( MsUnlock() )
			EndIf			
			If (lMod .and. lProg) .or. (!lmod .and. !lProg)
				// Días Progresivos
				nDaysRef := GetDDCHI(IIF(lMod,RCH->RCH_DTFIM,dDateRec),SRA->RA_FECVAC , cZonaExt,.T.)
				
				// Si el empleado tiene días progresivos, se genera registro en SRF por estos días.
				If nDaysRef > 0
					RecLock( "SRF" , .T. )                                                
			
					SRF->RF_FILIAL	:= cFilSRF
					SRF->RF_MAT		:= cMat
					SRF->RF_PD			:= cPdProg				//Verba lancamento 
					SRF->RF_DATABAS 	:= dDateIni				//Data Inicio do Periodo
					SRF->RF_DATAFIM 	:= dDateIni				//Data Fim do Periodo
					SRF->RF_DIASDIR 	:= nDaysRef    			//CDías progresivos
					SRF->RF_DFERVAT 	:= IIF(lMod,nDaysRef,0)	//Dias vencidos
					SRF->RF_DIASANT 	:= 0             		//Dias antecipados
					SRF->RF_DFERANT 	:= 0        			//Saldo
					SRF->RF_STATUS		:= "1"
					SRF->RF_FERCOLE 	:= "N"
					SRF->( MsUnlock() )
				 EndIf
			End If			
		EndIf		
		RestArea( aArea )
	EndIf 
Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetDDCHI  ºAutor  ³Mayra Camargo       º Data ³  08/09/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna os dias de referencia (dias de direito) para o func.º±±
±±º          ³e periodo informado.                                        º±±
±±º          ³cPar01 -> Periodo de referencia para busca dos dias de ref. º±±
±±º          ³cPar02 -> Numero de pagamento para busca dos dias de ref.   º±±
±±º          ³cPar03 -> Dato de b´suqueda                                 º±±
±±º          ³cPar04 -> Filial do funcionario                             º±±
±±º          ³cPar05 -> Matricula do funcionario                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetDDCHI(dBsEmployee, dDateFin, cZoneExt,lProg)  
	Local nDaysRef 		:= 0 //->Dias de Referencia do funcionario
	Local nI	   		   := 0 //->Contador de linhas para FTabela
	Local nYearsWorked 	:= 0 //->Anos trabalhados 
	Local nYearS008		:= 0 //->Anos tabela S008
	Local nYearGet		:= 0 // Variavel de auxilio para definicao De/Ate

	Default lProg:= .F.	   	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Considerando os anos trabalhados e o processo do trabalhador³
	³ira buscar na tabela S008 os dias de direito para o retorno ³
	³da funcao                                                   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	nYearsWorked:= DateDiffYear( dDateFin, dBsEmployee)
	
	fPosTab( "S008", cZoneExt, "==", 4,,,,,@nI)
	If Empty(nI)
		nI := 0
	EndIf

	While (cZoneExt == fTabela( "S008", nI , 4 ))
			nYearS008 := fTabela( "S008", nI , 5 )  // Representa Ate
			
			If nYearsWorked >= nYearGet .and. nYearsWorked <= nYearS008	
				iF !lProg		
					nDaysRef := fTabela( "S008", nI , 6)
				Else
					nDaysRef := fTabela( "S008", nI , 7)
				EndIF				
				Exit
			Else
				nYearGet := nYearS008
			EndIf
			nI++
	EndDo
                                  
Return( nDaysRef )
