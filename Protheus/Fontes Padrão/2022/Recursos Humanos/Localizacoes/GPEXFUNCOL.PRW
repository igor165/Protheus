#INCLUDE "PROTHEUS.CH"
#INCLUDE "SCOPECNT.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |GPEXFUNCOL�Autor  �mayra.camargo       � Data � 14/11/2016  ���
�������������������������������������������������������������������������͹��
���Desc.     �Contiene funciones auxiliares en la localizaci�n del GPE    ���
���          �para COLOMBIA.                                              ���
�������������������������������������������������������������������������͹��
���Uso       �SIGAGPE                                                     ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
��� MCamargo   �08/09/16�      �Merge v12.1.13                            ���
���Diego Rivera�22/08/18�DMINA-�Replica DMINA-2716 - Se modifica func     ���
���            �        �3753  �MkNewSRFCol para generar un registro en   ���
���            �        �      �SRF por cada a�o calculado en el periodo  ���
���            �        �      �abierto / DMINA-3221 - Se elimina variable���
���            �        �      �re-definida nDaysRef en func MkNewSRFCol  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MkNewSRFCol�Autor  �Mayra Camargo      � Data �  30/09/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �Funci�n para Insertar en SRF dias derecho para Colombia     ���
�������������������������������������������������������������������������͹��
���Sintaxe   � MkNewSRFCol(cFilSRA,cMat,cPdSRF,dDateIni                   ���
�������������������������������������������������������������������������͹��
���Parametros� cFilSRA     = Filial del empleado                          ���
���          � cMat        = Matr�cula                         	  	    ���
���          � cPdSrf      = Concepto de d�as Derecho                     ���
���          � dDateIni    = Fecha de Admisi�n del empleado               ���
�������������������������������������������������������������������������͹��
���Uso       �Gpea010Grv()                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MkNewSRFCol(cFilSra, cMat, cPdSrf, dDateIni,lMod)  
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local lFound		:= .F. 
	Local lDtNova		:= .T.
	Local dDatePer	:= CToD("  /  /  ") 
	Local dDateRec	:= CToD("  /  /  ") 
	Local dDateFinish:= CToD("  /  /  ") 
	Local dDatePerAtu:= CToD("  /  /  ")
	Local cFilSRF		:= ""     
	Local cProcess	:= ""           
	Local nDaysAux	:= 0
	Local nDaysLat	:= 0
	Local nYear		:= 0
	
	//--------------//
	Local dBsEmployee, dDateFin, dtFimPer, dVigVac, dtIniPer
	Local lDefMon 		:= .T. 
	Local cGpoVac 		:= ""
	Local nDaysRef 		:= 0   //->Dias de Referencia do funcionario
	Local nI	   		:= 0   //->Contador de linhas para FTabela
	Local nYearsWorked 	:= 0   //->Anos trabalhados 
	Local nX 			:= 0		
	Local nAnt			:= 0	//Antig�edad
	Local nDfervat 		:= 0 
	Local nDferaat 		:= 0 
	//--------------//
        
	Default cPDSrf 	:= fGetCodFol("0072") 	//Verba de ferias	      
	Default lMod 		:= .F.
                          	
	If Type("cPerFeAc") == "U"
		cPerFeAc := SuperGetMv("MV_FERPAC", NIL, "N") //AD Ferias por ano civil 
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
		//Posiciona nos periodos de dia de direito do admifuncionadio
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
					dDateFinish	:= SRF->RF_DATAFIM  //04/01/2011
				EndIf
				SRF->(dbSkip())
				nI ++
			EndDo	
		
			//Checa se pelo menos uma data eh superior ao inicio do ultimo periodo cadastrado
			//esta situacao so eh possivel na primeira vez (reingresso ou reconhecimento)
			lDtNova	 := SRA->RA_DTREC >= dDatePer

        Endif
		
		If Type("SRA->RA_DTREC") # "U" .And. !Empty(SRA->RA_DTREC) //Campo s  existe ARG/MEX/BOL - ARG nao usa no fechamento
			dDateRec := SRA->RA_DTREC                  
		Else
	   		If Type("SRA->RA_FECREI") # "U" .And. !Empty(SRA->RA_FECREI) //Campo s  existe MEX/BRA
				dDateRec := SRA->RA_FECREI
			Else 
				dDateRec := SRA->RA_ADMISSA
			EndIf                              
		EndIf
		
		
		
		//Considera a data do ultimo periodo somente se nao for o primeiro reingresso ou reconhecimento
		If  Type("SRA->RA_FECREI") # "U"
			If(!Empty(dDateFinish))
				If !lDtNova .Or. ( Empty(SRA->RA_FECREI) .Or. Empty(SRA->RA_DTREC) )
					dDateIni := DaySum( dDateFinish, 1)	
				EndIf
			EndIf
	    Endif
	    
		If ((Type("SRA->RA_FECREI") # "U" .And. !Empty(SRA->RA_FECREI)))
			dDateIni := CTOD(STRZERO(Day(SRA->RA_FECREI),2)+"/"+STRZERO(Month(SRA->RA_FECREI),2)+"/"+STRZERO(Year(dDateIni),4))
		ElseIf cPerFeAc == "S"
			dDateIni := CTOD("01/01/"+STRZERO(Year(YearSum(dDateIni, 1)),4))
		Else
			dDateIni := CTOD(STRZERO(Day(SRA->RA_ADMISSA),2)+"/"+STRZERO(Month(SRA->RA_ADMISSA),2)+"/"+STRZERO(Year(dDateIni),4))
		EndIf
			    
		dDatePerAtu := cToD( STRZERO(Day(dDateIni),2)+ "/"+RCH->RCH_MES+"/"+RCH->RCH_ANO )
   		
   		nYear := val(_aPerSel[1,5])
   		If  nYear > YEAR(dDateIni)
   			
   			dDateFinish := CTOD(STRZERO(Day(dDateIni),2)+"/"+STRZERO(Month(dDateIni),2)+"/"+ _aPerSel[1,5])
   			dDateFinish := DaySub(dDateFinish, 1)
   			
   			If dDateFinish < _aPerSel[1,6]
   				dDateFinish := YearSum(dDateFinish, 1)
   			End If
   			
		ElseIF nYear == YEAR(dDateIni)
		
			dDateFinish := YearSum(dDateIni, 1) //Data mas ano incrementando  + 1
			dDateFinish := DaySub(dDateFinish, 1)
			
		ElseIF nYear < YEAR(dDateIni)		
		
			dDateFinish := YearSum(dDateIni, 2) //Data mas ano incrementando  + 2
			dDateFinish := DaySub(dDateFinish, 1)
			
		End IF
		
		nDaysRef := getDDerCol(IIF(lMod,dDateIni,dDateRec),DaySum(dDateFinish,1), SRA->RA_GPOVAC,_aPerSel[1,7],@nDaysLat)
		
		nDaysAux := IIF(DaySub(_aPerSel[1,6],1) > dDateIni ,(nDaysLat/365) * ( (_aPerSel[1,6]-dDateIni) + 1 ), 0)
		    		
		If FWModeAccess("SRF") == "C"
			cFilSRF := Space(FWGETTAMFILIAL)
		Else
			cFilSRF:= cFilSra
		EndIf
		
		lDefMon := If(cPerFeAc <> "S",( Empty(dDatePer) .Or. dateDiffMonth(dDatePer,dDatePerAtu) >= 12 ),.T.)

		
		If lDefMon
		
			dBsEmployee := IIF(lMod,dDateIni,dDateRec)
			dDateFin 	:= DaySum(dDateFinish,1)
			cGpoVac 	:= SRA->RA_GPOVAC
			dtIniPer 	:= _aPerSel[1,6]//dtini
			dtFimPer 	:= _aPerSel[1,7]//dtfim
		
			nYearsWorked:= DateDiffYear( dDateFin, dBsEmployee)
			nAnt 		:= (( dtFimPer - dBsEmployee) + 1) / 365
			
			// Informa en la tabla SRF un registro por cada a�o calculado en el periodo abierto 	
			For nI:= 1 to nYearsWorked  
				nX 			:= fPosTab("S013",cGpoVac,"=",4,nI,"<=",7)				
				nLastDays 	:= IIF( nX > 0, fTabela("S013",nX,8) , 0)
				nDaysRef 	:= nLastDays	
				
				nAnt	:= nAnt + 1
				
				If nI > 1
					dDateIni := YearSum(dDateIni, 1)
				EndIf
				
				dDateFinish := CTOD(STRZERO(Day(dDateIni),2)+"/"+STRZERO(Month(dDateIni),2)+"/"+ alltrim(str(Year(dDateIni))))
   				dDateFinish := DaySub(dDateFinish, 1)
   				dDateFinish := YearSum(dDateFinish, 1)
   				
   				If dDateFinish > dtFimPer 
   					nDfervat := 0
   				Else
   					nDfervat := nDaysRef
   				EndIf
   				
   				If dDateFinish <= dtIniPer 
   					nDferaat := 0
   				Else
   				
	   				If RCJ->RCJ_CALEND == "1" 
	   					//				rch_dtfim               fecha inicio             fecha Fin
	   					nDferaat := ((((year(dtFimPer) - year(dDateIni))*360) + ((MONTH(dtFimPer) - MONTH(dDateIni)) * 30) + ( DAY(dtFimPer) - DAY(dDateIni)) + 1 ) / 360) * nDaysRef
	   					
	   				ElseIf RCJ->RCJ_CALEND == "2" 
	   					nDferaat := (( dtFimPer - dDateIni + 1)/365) * nDaysRef
					EndIf
				
				EndIf
				
				dVigVac :=  dtFimPer - ( RCJ->RCJ_VIGVAC * 365)
		
				If !( SRF->(dbSeek( cFilSRF + SRA->RA_MAT + cPdSrf + DtoS(dDateIni))) ) 
			
					RecLock( "SRF" , .T. )                                                
				
					SRF->RF_FILIAL	:= cFilSRF
					SRF->RF_MAT		:= cMat			//Matr�cula
					SRF->RF_PD		:= cPdSrf		//Verba lancamento 
					SRF->RF_DATABAS	:= dDateIni		//Data Inicio do Periodo
					SRF->RF_DATAFIM := dDateFinish	//Data Fim do Periodo
					SRF->RF_DIASDIR := nDaysRef    	//Calculado considerando anos de empresa
					SRF->RF_DFERVAT := nDfervat     //D�as vencidos
					SRF->RF_DIASANT := 0            //D�as antecipados
					SRF->RF_DFERAAT := nDferaat		//d�as proporcionales
					SRF->RF_DFERANT := 0        	//Saldo
					SRF->RF_STATUS	:= IIf(  dVigVac <= dDateFinish , "1" , "2" )
					
					SRF->( MsUnlock() )
				EndIf
				
			Next nI
			
		EndIf
		
		RestArea( aArea )
	EndIf 
Return lRet 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �getDDerCol�Autor  �Mayra Camargo       � Data �  30/09/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �Obtienes dias derecho para Colombia                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Sintaxe   � getDDerCol(dBSEmployee,dDateFin,cGpoVac,dfFimPer,nLastDay) ���
�������������������������������������������������������������������������͹��
���Parametros� dBSEmployee = Fecha de Admisi�n o reconocimiento           ���
���          � dDateFin    = Fecha de aniversario              	  	    ���
���          � cGpoVac     = Grupo de Vacaciones del empleado             ���
���          � dfFimPer    = Fecha de t�rmino del periodo abierto nom ord.���
���          � nLastDay    = �ltimos dias obtenidos del ciclo for         ���
�������������������������������������������������������������������������͹��
���Uso       �MkNewSRFCol                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function getDDerCol	(dBsEmployee, dDateFin, cGpoVac,dtFimPer,nLastDays)  
	Local nDaysRef 		:= 0   //->Dias de Referencia do funcionario
	Local nI	   			:= 0   //->Contador de linhas para FTabela
	Local nYearsWorked 	:= 0   //->Anos trabalhados 
	Local nX 				:= 0		
	Local nAnt			:= 0	//Antig�edad
	/*
	��������������������������������������������������������������Ŀ
	�Considerando os anos trabalhados e o processo do trabalhador  �
	�ira buscar na tabela S013 os dias de direito para o retorno   �
	�da funcao 															�
	����������������������������������������������������������������*/

	nYearsWorked:= DateDiffYear( dDateFin, dBsEmployee)
	nAnt := (( dtFimPer - dBsEmployee) + 1) / 365
		
	For nI:= 1 to nYearsWorked  
		nX := fPosTab("S013",cGpoVac,"=",4,nI,"<=",7)				
		nLastDays := IIF( nX > 0, fTabela("S013",nX,8) , 0)
		nDaysRef += nLastDays	
		
		nAnt:= nAnt + 1
	Next nI
		
Return( nDaysRef )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fGetVal() �Autor  �mayra.camargo       � Data � 08/10/2013  ���
�������������������������������������������������������������������������͹��
���Desc.     �Coloca al incluir un nuevo empleado, el valor por default   ���
���          �del NIT de la ARL a la cual esta afiliada la empresa a la   ���
���          �que pertenece el empleado.                                  ���
�������������������������������������������������������������������������͹��
���Sintaxe   � fGetValARL()                                               ���
�������������������������������������������������������������������������Ķ��
���Parametros� Ninguno                                                    ���
�������������������������������������������������������������������������Ķ��
���Uso       �Campo RA_NITARL                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function fgetValARL()
	Local cDesc 	:= space(TamSX3("RA_NITARL")[1])
	Local nI 		:= 0

	IF Inclui
		fPosTab( "S012", SRA->RA_FILIAL, "==", 1,,,,,@nI)
		
		If nI == 0
			nI := 1	
		End If
		
		cDesc := FTABELA("S012",nI,4)
			
		cDesc := IIF(Empty(cDesc),space(TamSX3("RA_NITARL")[1]),cDesc)							
	End If	
Return cDesc


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �g280VldMod� mayra.camargo              � Data �  21/10/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida que al modificar/eliminar el registro de un benefi-  ���
���          �ciario, se valide que no tenga registros en SRK,RCK,SRC y   ���
���          �SRD.                                                        ���
�������������������������������������������������������������������������͹��
���Sintaxe   �lVar := gp280VldMod()                                       ���
�������������������������������������������������������������������������͹��
���Parametros�lDel := Par�metro por referencia que indica si se eliminar� ���
���          �        el registro procesado.                              ���
���          �                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � gp280Grava                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function gp280VldMod(lDel)
	Local lRet	:= .F.
	Local aArea 	:= getArea()
	
	Default lDel := .F.
	IF SRQ->RQ_TPBENEF == "3" // Si el tipo de beneficiarios en ejeutivo
				
		dbSelectArea("SRK")
		dbSetOrder(RetOrder("SRK","RK_FILIAL+RK_MAT+RK_NUMID"))

		If SRK->(dbSeek(SRA->RA_FILIAL+SRA->RA_MAT+"SRK"+SRA->(RA_FILIAL+RA_MAT)+SRQ->(RQ_VERBFOL+RQ_ORDEM)+"SRQ"))	
														
			If SRK->RK_VLSALDO <> SRK->RK_VALORTO		// Si el valor inicial es diferente al valor saldado no puede eliminarse	
				lRet := .T.	
			Else
				lDel := .T.
			End IF								
				
			// Se buscan registros en amortizaciones
			dbSelectArea("RCK")  
			RCK->(dbSetOrder(RetOrder("RCK","RCK_FILIAL+RCK_MAT+RCK_NUMID")))
			If RCK->(dbSeek(SRA->(RA_FILIAL+RA_MAT)+ "SRK"+SRA->(RA_FILIAL+RA_MAT)+SRQ->(RQ_VERBFOL+RQ_ORDEM)+"SRQ"))
			  	lRet := .T.
			  	lDel := .F.
			Endif						
		End IF
																			
	End IF
				
	IF !lRet
					
		// Si se encuentra un registro en SRC no se podr� modificar el beneficiario.
		dbSelectArea("SRC")
		SRC->(dbSetOrder(RetOrder("RC_FILIAL+RC_MAT+RC_PROCES+RC_ROTEIR+RC_PERIODO+RC_SEMANA")))
		IF SRC->(dbSeek(SRA -> RA_FILIAL + SRA -> RA_MAT + SRA -> RA_PROCES))															
			Do while !SRC->(Eof()) 
				IF SRC->RC_NUMID == SRA->RA_FILIAL+SRA->RA_MAT+"SRK"+SRA->(RA_FILIAL+RA_MAT)+SRQ->(RQ_VERBFOL+RQ_ORDEM)+"SRQ"
					lRet := .T.
					Exit
				EndIF
				SRC->(Dbskip())
			EndDo
		End IF
					//Si se cuenta con al menos un registro en SRD no se podr� modificar el beneficiario.
		dbSelectArea("SRD")
		SRD->(dbSetOrder(RetOrder("RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA")))
		IF SRD->(dbSeek(SRA -> RA_FILIAL + SRA ->  RA_MAT + SRA -> RA_PROCES))															
			Do while !SRD->(Eof()) 
				IF SRD->RD_NUMID == SRA->RA_FILIAL+SRA->RA_MAT+"SRK"+SRA->(RA_FILIAL+RA_MAT)+SRQ->(RQ_VERBFOL+RQ_ORDEM)+"SRQ"
					lRet := .T.
					Exit
				EndIF
				SRD->(Dbskip())
			EndDo
		End IF
	End IF
		
	RestArea(aArea)
Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fGetAusCont|Autor � mayra.camargo      � Data �  04/11/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �Obtiene la suma de los d�as de una incapacidad subsecuente. ���
���          �Ausencia continua                                           ���
�������������������������������������������������������������������������͹��
���Sintaxe   � fGetAusCont(cCampo,cFil,cMat,cPD)                          ���
�������������������������������������������������������������������������͹��
���Parametros�cCampo   := Campo a sumar R8_SDPAGAR/R8_SPAGAR              ���
���          �cFil     := Filial del empleado                             ���
���          �cMat     := Matr�cula del empleado                          ���
���          �cPD      := Concepto a Procesar                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �GPEXFOR1                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function fGetAusCont(cCampo,cFil,cMat,cPD)

	Local aArea		:= GetArea()
	Local aSR8Table
	
	Local cCodTip
	Local cFields
	Local cAliasSR8	:= "QSR8"
	
	Local nAusCont	:= 0
	Local nCampos
	Local cSR8Tab	:= '%'+RetSqlName('SR8')+'%'
	Local cQryDep := "" 
	Local cDelete 		:= If( !__lSrvAs400, "%D_E_L_E_T_ = ' '%", "%@DELETED@ = ' '%" )
	
	DEFAULT cFil	 := SRA->RA_FILIAL
	DEFAULT cMat 	 := SRA->RA_MAT
	
	//- Carregar somente os itens gerados pelo select
		
	If Empty( cQryDep )
		
		cFields		:= ""
		
		cFields :=  "R8_CONTINU, " 
		
		If __lSrvAs400
			cFields += "RRN("+RetSqlName('SR8')+")" + " RECNO,"
		Else
			cFields += "R_E_C_N_O_" + " RECNO,"
		EndIf
	
		cQryDep := "%" + cFields + cCampo+ "%"
	EndIf
	
	//-- Leitura dos registros por ordem de Sequencia
	BeginSql alias cAliasSR8
		SELECT %exp:cQryDep%
		FROM %exp:cSR8tab%
		WHERE R8_FILIAL = %exp:cFil%
		  AND R8_MAT = %exp:cMat%
		  AND R8_PD = %exp:cPD%//AND R8_DATAINI <= %exp:dDtFim%
		  AND (%exp:cDelete%)
		  ORDER BY R8_DATAFIM DESC
	EndSql
	
	//-- Geracao das informacoes no array de Trajetoria Laboral do Funcionario
	While (cAliasSR8)->(!Eof())
	
		If 	(cAliasSR8)-> R8_CONTINU == "1"
			nAusCont := nAusCont + (cAliasSR8)->&(cCampo)
			(cAliasSR8)->(dbSkip())
		Else
			nAusCont := nAusCont + (cAliasSR8)->&(cCampo)
			Exit
		EndIF
				
	EndDo
	(cAliasSR8)->( DbCloseArea() )
	
	RestArea(aArea)

Return nAusCont
