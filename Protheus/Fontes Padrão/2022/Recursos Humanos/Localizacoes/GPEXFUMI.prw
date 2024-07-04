#include 'protheus.ch'
#include 'GPEXFUMI.ch'

/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Programa  �GPEXFUMI  �Autor  �Luis E. Enr�quez Mata  �  Data �  21/11/19   ���
�����������������������������������������������������������������������������Ĵ��
���Desc.     � Funciones gen�ricas GPE Mercado Internacional.                 ���
�����������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.            	  ���
�����������������������������������������������������������������������������Ĵ��
���Programador  �Fecha   �   Issue   � Motivo de la alteraci�n                ���
���Luis Enriquez�21/11/19�DMINA-7532 �Creaci�n de funciones para carga de Ti- ���
���             �        �           �pos de ausencia (MEX)                   ���
�����������������������������������������������������������������������������Ĵ��
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/

/*/{Protheus.doc} GPXCARRCM
Ejecuci�n de funci�n GPXRCM est�ndar por pa�s.
@type function
@author luis.enr�quez
@since 21/11/2019
@version 1.0
@return Nil
/*/
Function GPXCARRCM()
	Local cFunction	:= ("GPXRCM" + cPaisLoc)
	Private aRCMEnc := {}
	Private aRCMDet := {}	
	
	If FindFunction(cFunction)
		bFunc := __ExecMacro("{ ||  " + cFunction + "() }")
		Eval(bFunc)
	EndIf
Return Nil

/*/{Protheus.doc} GPXRCMMEX
Ejecuci�n de regla de negocio para carga de tabla Tipos de Ausencia (RCM) para 
el pa�s M�xico.
@type function
@author luis.enr�quez
@since 21/11/2019
@version 1.0
@return Nil
/*/
Function GPXRCMMEX()
	Local aRCMCab  := {}
	Local aRCMDet  := {}
	Local cFunGPPD := "GPPD" + Alltrim(cPaisLoc)
	Local nTotReg  := 0
	Private aGPError  := {}
	Private nDatosErr := 0
		
	If !ChkVazio("RCM",.F.)
		If !ChkVazio("SRV",.F.)
			cMsgYesNo	:= OemToAnsi(;
								STR0001 + ;	//"No existen registros de Conceptos (SRV)"
								CRLF	+ ;	
								StrTran( STR0002, "###", STR0005 ) + ;	//"�Desea generar los ### est�ndar?" //"Conceptos"
								CRLF	+ ;
								STR0003  + cPaisLoc + STR0004 ;	//"Importante: Es necesario que el programa GPPD" //".PRX este compilado."
	                            )
			If MsgYesNo(OemToAnsi(cMsgYesNo) , OemToAnsi(STR0005)) //"Conceptos"
				If FindFunction("fCarPD")
					If FindFunction(cFunGPPD)
						Processa( { || fCarPD() } , OemToAnsi(StrTran( STR0006, "###", STR0005 )) ) //"Cargando los ### est�ndar..." //"Conceptos"
					Else
						MsgAlert(STR0007 + cFunGPPD + STR0008, OemToAnsi(STR0009)) //El programa " //".PRX no esta compilado en el repositorio." //"Atenci�n"						
					EndIf
				EndIf
		    EndIf                            
		EndIf
		
		If !ChkVazio("SRV",.F.)
			 MsgAlert(STR0010, OemToAnsi(STR0009)) //"No se encuentran cargados los Conceptos (SRV), datos requeridos para continuar con el proceso." //"Atenci�n"		
		Else			
				aRCMCab   := {"RCM_TIPO","RCM_DESCRI","RCM_PD","RCM_TPIMSS","RCM_TIPODI","RCM_TIPOAF","RCM_DIASEM","RCM_SOBREP","RCM_7MODIA","RCM_ABATAV"}
				
				aAdd(aRCMDet,{"102"	,"Incapacidad AT"               ,"102", "2", "1", "1", 999, "1", "2", "2", .F., ""})
				aAdd(aRCMDet,{"103"	,"Incapacidad EG"               ,"103", "2", "2", "1", 999, "1", "2", "2", .F., ""})
				aAdd(aRCMDet,{"104"	,"Incapacidad MT"               ,"104", "2", "2", "1", 999, "1", "2", "2", .F., ""})
				aAdd(aRCMDet,{"105"	,"Faltas Injustificadas"        ,"105", "1", "1", "1", 999, "2", "2", "2", .F., ""})
				aAdd(aRCMDet,{"106"	,"Castigo"	                    ,"106", "3", "1", "1", 999, "2", "1", "2", .F., ""})
				aAdd(aRCMDet,{"107"	,"Permiso con Goce de Sueldo" 	,"107", "3", "1", "2", 999, "2", "2", "2", .F., ""})
				aAdd(aRCMDet,{"108"	,"Permiso sin Goce de Sueldo"	,"108", "3", "1", "1", 999, "2", "2", "2", .F., ""})
				aAdd(aRCMDet,{"109"	,"Prestacion Empresa"	 		,"109", "3", "1", "2", 999, "2", "1", "2", .F., ""})
				aAdd(aRCMDet,{"110"	,"Incapacidad Empresa"			,"110", "3", "1", "2", 999, "2", "1", "2", .F., ""})
				aAdd(aRCMDet,{"111"	,"Comision Sindical"			,"111", "3", "1", "2", 999, "2", "1", "2", .F., ""})
				aAdd(aRCMDet,{"112"	,"Dias Economicos"			    ,"112", "3", "1", "2", 999, "2", "1", "2", .F., ""})
				aAdd(aRCMDet,{"113"	,"Vacaciones"	 			    ,"113", "3", "1", "4", 999, "2", "1", "2", .F., ""})
				aAdd(aRCMDet,{"119"	,"Permiso Paternidad"		    ,"119", "3", "1", "2", 999, "2", "2", "2", .F., ""})
				
				If MsgYesNo(OemToAnsi(STR0025 + ;       //"No existen registros de Tipos de Ausencia (RCM)" 
				  CRLF + StrTran( STR0002, "###", STR0011 )) , OemToAnsi(STR0011)) //"�Desea generar los ### est�ndar?" //"Tipos de Ausencia"
					nTotReg := Len(aRCMDet)
					
					Processa( { || fCarRCM(aRCMCab, aRCMDet, @nDatosErr)} , OemToAnsi(StrTran(STR0006, "###", STR0011)) ) //"Cargando los ### est�ndar..." //"Tipos de Ausencia"
					
					If MsgYesNo(OemToAnsi(IIf(nDatosErr > 0, STR0012, STR0013) + ; //"Proceso ejecutado con errores" //"Proceso ejecutado con �xito"
						CRLF + StrTran(STR0014, "###", STR0011)) , OemToAnsi(STR0011)) //"�Desea generar los ### est�ndar?" //"Tipos de Ausencia"
						GPXGENLOG(aRCMDet, STR0011, nDatosErr) //"Tipos de Ausencia"
					EndIf
				EndIf
		EndIf	
	EndIf
Return Nil


/*/{Protheus.doc} GPXRCMCOL
Ejecuci�n de regla de negocio para carga de tabla Tipos de Ausencia (RCM) para 
el pa�s Colombia.
@type function
@author diego.rivera
@since 23/11/2020
@version 1.0
@return Nil
/*/
Function GPXRCMCOL()
	Local aRCMCab  := {}
	Local aRCMDet  := {}
	Local cFunGPPD := "GPPD" + Alltrim(cPaisLoc)
	Local nTotReg  := 0
	Private aGPError  := {}
	Private nDatosErr := 0
		
	If !ChkVazio("RCM",.F.)
		If !ChkVazio("SRV",.F.)
			cMsgYesNo	:= OemToAnsi(;
								STR0001 + ;	//"No existen registros de Conceptos (SRV)"
								CRLF	+ ;	
								StrTran( STR0002, "###", STR0005 ) + ;	//"�Desea generar los ### est�ndar?" //"Conceptos"
								CRLF	+ ;
								STR0003  + cPaisLoc + STR0004 ;	//"Importante: Es necesario que el programa GPPD" //".PRX este compilado."
	                            )
			If MsgYesNo(OemToAnsi(cMsgYesNo) , OemToAnsi(STR0005)) //"Conceptos"
				If FindFunction("fCarPD")
					If FindFunction(cFunGPPD)
						Processa( { || fCarPD() } , OemToAnsi(StrTran( STR0006, "###", STR0005 )) ) //"Cargando los ### est�ndar..." //"Conceptos"
					Else
						MsgAlert(STR0007 + cFunGPPD + STR0008, OemToAnsi(STR0009)) //El programa " //".PRX no esta compilado en el repositorio." //"Atenci�n"						
					EndIf
				EndIf
		    EndIf                            
		EndIf
		
		If !ChkVazio("SRV",.F.)
			 MsgAlert(STR0010, OemToAnsi(STR0009)) //"No se encuentran cargados los Conceptos (SRV), datos requeridos para continuar con el proceso." //"Atenci�n"		
		Else			
				aRCMCab   := {"RCM_TIPO","RCM_DESCRI","RCM_PD","RCM_TIPODI","RCM_TIPOAF","RCM_TPIMSS","RCM_SOBREP","RCM_SUBPOS"} //,"RCM_DIASEM","RCM_7MODIA","RCM_ABATAV"}
				
				aAdd(aRCMDet,{"001"	,"Enfermedad Com�n"               				 	,"002", "2", "1", "G", "2", "1"})
				aAdd(aRCMDet,{"002"	,"Accidente Com�n"               				 	,"002", "2", "1", "G", "2", "1"})
				aAdd(aRCMDet,{"003"	,"Accidente Trabajo"               				 	,"006", "2", "1", "A", "2", "1"})
				aAdd(aRCMDet,{"004"	,"Enfermedad Profesional"        				 	,"006", "2", "1", "A", "2", "1"})
				aAdd(aRCMDet,{"005"	,"Maternidad (126 d�as)"	                     	,"008", "2", "1", "M", "2", "2"})
				aAdd(aRCMDet,{"006"	,"Paternidad por Fallecimiento Madre  (126 d�as)"	,"008", "2", "1", "M", "2", "1"})
				aAdd(aRCMDet,{"007"	,"Descanso Remunerado x Aborto (2-4 semanas)"		,"008", "2", "1", "M", "2", "1"})
				aAdd(aRCMDet,{"008"	,"Licencia Paternidad (8 d�as)"	 					,"010", "1", "1", "P", "2", "1"})
				aAdd(aRCMDet,{"009"	,"Licencia no Remunerada"							,"016", "1", "2", "L", "2", "2"})
				aAdd(aRCMDet,{"010"	,"Sanci�n"											,"014", "1", "2", "L", "2", "2"})
				aAdd(aRCMDet,{"011"	,"Ausencia no Justificada"						    ,"016", "1", "1", "L", "2", "1"})
				aAdd(aRCMDet,{"012"	,"Licencia Remunerada"				 			    ,"015", "1", "1", "R", "2", "2"})
				aAdd(aRCMDet,{"013"	,"Licencia por Luto (5 d�as)"					    ,"015", "1", "1", "R", "2", "1"})
				aAdd(aRCMDet,{"014"	,"Permiso Remunerado"							    ,"015", "1", "1", "R", "2", "1"})
				aAdd(aRCMDet,{"015"	,"Permiso Calamidad Dom�stica (3 d�as)"			    ,"015", "1", "1", "R", "2", "1"})
				aAdd(aRCMDet,{"016"	,"Permiso por Matrimonio (3 d�as)"				    ,"015", "1", "1", "R", "2", "1"})
				aAdd(aRCMDet,{"017"	,"Suspensi�n Temporal del Contrato"				    ,"015", "1", "1", "R", "2", "1"})
				aAdd(aRCMDet,{"018"	,"Vacaciones"									    ,"018", "1", "1", "V", "2", "1"})
				
				If MsgYesNo(OemToAnsi(STR0025 + ;       //"No existen registros de Tipos de Ausencia (RCM)" 
				  CRLF + StrTran( STR0002, "###", STR0011 )) , OemToAnsi(STR0011)) //"�Desea generar los ### est�ndar?" //"Tipos de Ausencia"
					nTotReg := Len(aRCMDet)
					
					Processa( { || fCarRCM(aRCMCab, aRCMDet, @nDatosErr)} , OemToAnsi(StrTran(STR0006, "###", STR0011)) ) //"Cargando los ### est�ndar..." //"Tipos de Ausencia"
					
					If MsgYesNo(OemToAnsi(IIf(nDatosErr > 0, STR0012, STR0013) + ; //"Proceso ejecutado con errores" //"Proceso ejecutado con �xito"
						CRLF + StrTran(STR0014, "###", STR0011)) , OemToAnsi(STR0011)) //"�Desea generar los ### est�ndar?" //"Tipos de Ausencia"
						GPXGENLOG(aRCMDet, STR0011, nDatosErr) //"Tipos de Ausencia"
					EndIf
				EndIf
		EndIf	
	EndIf
Return Nil

/*/{Protheus.doc} fCarRCM
Llenado de tabla Tipos de Ausencia (RCM)
@type function
@author luis.enr�quez
@since 21/11/2019
@version 1.0
@param aRCMCab, array, Arreglo con nombre de campos de la tabla RCM.
@param aRCMDet, array, Arreglo con los valores para los campos de la tabla RCM.
@param nDatosErr, numerico, Contador con n�mero de registros que tuvieron error al insertar en la tabla RCM.
@return Nil
/*/
Function fCarRCM(aRCMCab, aRCMDet, nDatosErr)
	Local nI := 0
	Local nY := 0
	Local cFilRCM := xFilial("RCM")
	Local cFilSRV := xFilial("SRV")
	Local lError  := .F.
	
	ProcRegua(Len(aRCMDet))
	
	BEGIN TRANSACTION
		For nI := 1 to Len(aRCMDet)
			IncProc(Alltrim(aRCMDet[nI,1]) + Alltrim(aRCMDet[nI,2]))
			RCM->(dbSetOrder(1)) //RCM_FILIAL + RCM_TIPO
			If !RCM->( dbSeek( cFilRCM + aRCMDet[nI,1]))
				RCM->(RecLock("RCM" , .T.))
				RCM->RCM_FILIAL := cFilRCM
				For nY := 1 to Len(aRCMCab)
					lError  := .F.
					If aRCMCab[nY] == "RCM_PD"
						dbSelectArea("SRV")
						SRV->(dbSetOrder(1)) //RV_FILIAL + RV_COD
						If SRV->(dbSeek(cFilSRV + aRCMDet[nI,nY]))
							RCM->(&(aRCMCab[nY])) := aRCMDet[nI,nY]
						Else
							aRCMDet[nI,12] += STR0015 + Alltrim(aRCMDet[nI,3]) + STR0016 //"El c�digo del Concepto " //" para el tipo de ausencia no existe."
							lError := .T. 
						EndIf
					Else
						RCM->(&(aRCMCab[nY])) := aRCMDet[nI,nY]
					EndIf
					If lError
						aRCMDet[nI,11] := .T. 
						nDatosErr += 1
					EndIf
				Next nY
				RCM->(MsUnLock())  
			EndIf
		Next nI
			
		If nDatosErr > 0
			DisarmTransaction()
		EndIf		
	END TRANSACTION
Return Nil

/*/{Protheus.doc} GPXGENLOG
Generaci�n de la impresi�n del LOG del proceso.
@type function
@author luis.enr�quez
@since 21/11/2019
@version 1.0
@param aProcesa, array, Arreglo con los registros procesados.
@param cTipo, string, Nombre de los datos procesados (Ej. "Conceptos", "Tipos de Ausencia")
@param nDatosErr, numerico, Contador con n�mero de registros que tuvieron error al insertar en la tabla RCM.
@return Nil
/*/
Static function GPXGENLOG(aProcesa, cTipo, nDatosErr)
	Local aReturn	:= {"xxxx", 1, "yyy", 2, 2, 1, "",1 }
	Local cTamanho	:= "M"
	Local cTitulo	:= STR0017 + cTipo //"LOG generaci�n de "
	Local nX		:= 1
	Local aNewLog	:= {}
	Local nTamLog	:= 0
	Local aLogTitle	:= { STR0018, STR0019 }   //"Tipo Descripci�n                  Observaciones" //"Resumen del proceso"
	Local aLog		:= {}
	Local cEsp		:= Chr(9) + Chr(9)+ Chr(9)
	Local aLogRes	:= {}
	Local cObs      := ""
	Local nPos 		:= 1
	Local nC		:= 0
	Local nError    := 0
	
	Private wCabec1 := STR0020 + cTipo  //"Datos procesados: "
	
	ASORT(aProcesa, , , { | x,y | x[1] + x[2]  > y[1] + y[2] } )
	
	For nX :=1 To Len(aProcesa)                 
		cObs := ""
		nPos := 1
		If Len(aProcesa[nX,12]) > 84
			For nC:= 1 to (Len(aProcesa[nX,12]) / 84) + 1				 
				cObs += SubStr(aProcesa[nX,12], nPos, 84)  + (Chr(13) + Chr(10)) + Space(40)
				nPos += 84
			Next nC			
		Else
			cObs := aProcesa[nX,12]
		EndIF
		                           
	    aAdd(aLog, aProcesa[nx,1] + Space(2) + ;   //Tipo
	    		   aProcesa[nX,2] + Space(16) + ;  //Descripci�n
	    		   cObs )                         // Detalle	 	    		 
	Next nX
		
	aAdd(aLogRes," ")
	If nDatosErr > 0
		aadd(aLogRes,STR0021 + Transform(Len(aProcesa),"9999"))    //"Registros V�lidos:"
		aadd(aLogRes,STR0022 + Transform(nDatosErr,"9999"))		//"Registros Err�neos:"
	Else
		aadd(aLogRes,STR0023 + Transform(Len(aProcesa),"9999"))  //"Registros Generados:"
	EndIf

	aNewLog		:= aClone(aLog)
	nTamLog		:= Len( aLog)	
	aLog := {}
	
	If !Empty( aNewLog )	
		aAdd( aLog , aClone( aNewLog ) )
	Endif
	
	aAdd(aLog, aLogRes)
	/*
		1 -	aLogFile 	//Array que contem os Detalhes de Ocorrencia de Log
		2 -	aLogTitle	//Array que contem os Titulos de Acordo com as Ocorrencias
		3 -	cPerg		//Pergunte a Ser Listado
		4 -	lShowLog	//Se Havera "Display" de Tela
		5 -	cLogName	//Nome Alternativo do Log
		6 -	cTitulo		//Titulo Alternativo do Log
		7 -	cTamanho	//Tamanho Vertical do Relatorio de Log ("P","M","G")
		8 -	cLandPort	//Orientacao do Relatorio ("P" Retrato ou "L" Paisagem )
		9 -	aRet		//Array com a Mesma Estrutura do aReturn
		10-	lAddOldLog	//Se deve Manter ( Adicionar ) no Novo Log o Log Anterior
	*/
	Processa( { ||fMakeLog( aLog ,aLogTitle , , .t. , FunName() , cTitulo , cTamanho , "P" , aReturn, .F. )}, STR0024 + cTipo) //"Generando Log de creaci�n de "	
Return Nil

/*/{Protheus.doc} GpexRGXMI
	Funci�n utilizada para ejecutar las funciones que generan los PRX de MI,
	correspondientes a Estandar de Periodos y Criterios de Acumulaci�n.
	Los archivos generados depender�n del pa�s. GPRGX + cPaisLoc + .prx y 
	GPRG9 + cPaisLoc+ .prx

	@type  Function
	@author marco.rivera
	@since 25/09/2022
	@version 1.0
	@example
	GpexRGXMI()
	/*/
Function GpexRGXMI(cPath, aListaArch)

	Local aLinesProg 	:= {}	// array com as linhas dos programas  
	Local aLinProg2     := {}	// array com as linhas dos programas
	Local aIniHdrRG5	:= {}	// cabecalho da tabela RG5 com os campos
	Local aRG5Virtual	:= {}	// campos virtuais de RG5
	Local aIniHdrRG6	:= {}	// cabecalho da tabela RG6 com os campos
	Local aRG6Virtual	:= {}	// campos virtuais de RG6
	Local aIniHdrRG9	:= {}	// cabecalho da tabela RG9 com os campos
	Local aRG9Virtual	:= {}	// campos virtuais de RR9

	Local cArquivo 		:= ""	// nome do arquivo a ser gerado
	Local cArquivo2     := ""   // nome do arquivo a ser gerado

	Local cMsg			:= ""	// mensagem de erro na geracao do arquivo PRX
	Local cProg			:= ""	// string a ser enviado ao arquivo PRX
	Local cValueCampo	:= ""	// montagem da string a ser enviado ao array
	Local cTexto		:= ""	// valor do campo do Header

	Local nArq		// situacao do arquivo
	Local nArq2		// situacao do arquivo
	Local nUsado	// campos utilizados

	Local nX			:= 0
	Local nY			:= 0

	Local cNomArch1		:= ""
	Local cNomArch2		:= ""

	Default	cPath		:= "" //Ruta donde se grabar�n los archivos
	Default aListaArch	:= {} //Contiene la lista de archivos que fueron generados previamente

	cArquivo 	:= ("GPRGX" + cPaisLoc + ".PRX")
	cArquivo2 	:= ("GPRG9" + cPaisLoc + ".PRX")
	cNomArch1	:= cArquivo
	cNomArch2	:= cArquivo2

	aIniHdrRG5	:= RG5->( GdMontaHeader( @nUsado, @aRG5Virtual, NIL, NIL, NIL, .T.,.T. ) )
	aIniHdrRG6	:= RG6->( GdMontaHeader( @nUsado, @aRG6Virtual, NIL, NIL, NIL, .T.,.T. ) ) 
	aIniHdrRG9	:= RG9->( GdMontaHeader( @nUsado, @aRG9Virtual, NIL, NIL, NIL, .T.,.T. ) )

	Begin Sequence
	
	cArquivo  := cPath + cArquivo
	cArquivo2 := cPath + cArquivo2	

	If File(cArquivo)
		If !(MsgYesNo(STR0026 + cNomArch1 + STR0027 + cArquivo, STR0028)) //"�El archivo " - " ya existe!, �Desea sobreescribir? " - "�Atenci�n!"
			Break
		EndIf
	EndIf 

	If File(cArquivo2)
		If !(MsgYesNo(STR0026 + cNomArch2 + STR0027 + cArquivo2, + STR0028)) //"�El archivo " - " ya existe!, �Desea sobreescribir? " - "�Atenci�n!"
			Break
		EndIf
	EndIf
	
	nArq := MSFCREATE(cArquivo, 0)
	If Ferror() # 0 .And. nArq = -1
		cMsg := STR0029 + STR(Ferror(),3) //"Error en la grabaci�n del archivo - C�digo DOS: "
		MsgInfo(cMsg, STR0028)
		Return(.F.)
	EndIf

	nArq2 := MSFCREATE(cArquivo2, 0)
	If Ferror() # 0 .And. nArq2 = -1
		cMsg := STR0029 + STR(Ferror(),3) //"Error en la grabaci�n del archivo - C�digo DOS: "
		MsgInfo(cMsg, STR0028)
		Return(.F.)
	EndIf

	// Encabezado de la Funci�n
	aAdd(aLinesProg, '#INCLUDE "PROTHEUS.CH"' + CRLF + CRLF)
	aAdd(aLinesProg, "/*/" + CRLF)
	aAdd(aLinesProg, "�����������������������������������������������������������������������Ŀ" + CRLF)
	aAdd(aLinesProg, "�Fun��o    �GpRGX" + cPaisLoc + "      " + "�Autor� TOTVS       � Data �" + SubStr(DtoS(date()),7,2)+"/"+SubStr(DtoS(date()),5,2)+"/"+SubStr(DtoS(date()),1,4) + "        �" + CRLF)
	aAdd(aLinesProg, "�����������������������������������������������������������������������Ĵ" + CRLF)
	aAdd(aLinesProg, "�Descri��o �Est�ndar de Periodos                                        �" + CRLF)
	aAdd(aLinesProg, "�����������������������������������������������������������������������Ĵ" + CRLF)
	aAdd(aLinesProg, "�Sintaxe   �                                                            �" + CRLF)
	aAdd(aLinesProg, "�����������������������������������������������������������������������Ĵ" + CRLF)
	aAdd(aLinesProg, "�Parametros�Ver par�metros formales                                     �" + CRLF)
	aAdd(aLinesProg, "�����������������������������������������������������������������������Ĵ" + CRLF)
	aAdd(aLinesProg, "� Uso      �Gen�rico                                                    �" + CRLF)
	aAdd(aLinesProg, "�������������������������������������������������������������������������/*/" + CRLF)
	aAdd(aLinesProg, "Function GpRGX" + cPaisLoc + "(aItensRG6, aRG6Header, aItensRG5, aRG5Header)" + CRLF +  CRLF)
	
	aAdd(aLinesProg, "Local lRet		:= .T." + CRLF + CRLF)
	
	aAdd(aLinesProg, "Default aItensRG6   := {}" + CRLF)
	aAdd(aLinesProg, "Default aRG6Header  := {}" + CRLF)
	aAdd(aLinesProg, "Default aItensRG5   := {}" + CRLF)
	aAdd(aLinesProg, "Default aRG5Header  := {}" + CRLF + CRLF)	
	
	aAdd(aLinesProg, "/*/" + CRLF)
	aAdd(aLinesProg, "��������������������������������������������������������������Ŀ" + CRLF)
	aAdd(aLinesProg, "� Encabezado de RG6 generado por el Procedimiento est�ndar     �" + CRLF)
	aAdd(aLinesProg, "����������������������������������������������������������������/*/" + CRLF)

	For nX := 1 To Len(aIniHdrRG6)
		cProg      := ""
		For nY := 1 To Len(aIniHdrRG6[nX])
			cTexto := If(ValType(aIniHdrRG6[nX,nY])=="N", AllTrim(Str(aIniHdrRG6[nX,nY])),;
						   	If(ValType(aIniHdrRG6[nX,nY])=="L", Transform(aIniHdrRG6[nX, nY],"@!"),;
						   	   aIniHdrRG6[nX, nY]))
			cTexto := StrTran(cTexto, "'", '"')
			cProg += "'" + cTexto + "'"
			If nY < Len(aIniHdrRG6[nX])
				cProg += ","
			EndIf
		Next nY
		If !Empty(cProg)
			cTela := AllTrim(GetSx3Cache( aIniHdrRG6[nX][2], "X3_TELA" ))
			If !Empty(cTela)
				aAdd(aLinesProg, "IIf( MV_MODFOL = '" + cTela + "', aAdd(aRG6Header, " + '{ ' + cProg + ' })' + ", '')" + CRLF)
			Else
				aAdd(aLinesProg, "aAdd(aRG6Header, " + '{ ' + cProg + ' })' + CRLF)
			EndIf
		EndIf
	Next nX

	aAdd(aLinesProg, CRLF)

    //�tems de RG6
	DbSelectArea("RG6")
	RG6->(DBSetOrder(1)) //RG6_FILIAL+RG6_PDPERI+RG6_CODIGO+RG6_NUMPAG
	RG6->(DBGoTop())

	While !RG6->(EoF())

	 	cProg := "	aAdd(aItensRG6, { "
		For nX := 1 To Len(aIniHdrRG6)
			cValueCampo := ""

			If aIniHdrRG6[nX,8] == "N"
				cValueCampo += AllTrim(Str(&(aIniHdrRG6[nX,2])))
			ElseIf "FILIAL" $ aIniHdrRG6[nX,2]
				cValueCampo += ""
			Else
				cValueCampo += &(aIniHdrRG6[nX,2])
			EndIf

			cValueCampo := StrTran(cValueCampo, "'", '"')
	
			If (aIniHdrRG6[nX,8] != "N") .and. (aIniHdrRG6[nX,8] != "D") .and. (aIniHdrRG6[nX,8] != "L")
				cValueCampo := "'" + cValueCampo
				cValueCampo += "'"
			EndIf
	
			cProg += cValueCampo
			If nX < Len(aIniHdrRG6)
				cProg += ","
			EndIf
		Next nX
		cProg += "} )"
		aAdd(aLinesProg, cProg + CRLF)
		RG6->(dbSkip())

	EndDo
	
	aAdd(aLinesProg, "" + CRLF)
	aAdd(aLinesProg, "" + CRLF)
	aAdd(aLinesProg, "" + CRLF)

	//Monta encabezado de RG5
	For nX := 1 To Len(aIniHdrRG5)
		cProg := ""
		For nY := 1 To Len(aIniHdrRG5[nX])
			cTexto := If(ValType(aIniHdrRG5[nX,nY])=="N", AllTrim(Str(aIniHdrRG5[nX,nY])),;
						   	If(ValType(aIniHdrRG5[nX,nY])=="L", Transform(aIniHdrRG5[nX, nY],"@!"),;
						   	   aIniHdrRG5[nX, nY]))
			cTexto := StrTran(cTexto, "'", '"')
			cProg += "'" + cTexto + "'"
			If nY < Len(aIniHdrRG5[nX])
				cProg += ","
			EndIf
		Next nY
		If !Empty(cProg)
			aAdd(aLinesProg, "aAdd(aRG5Header, " + '{ ' + cProg + ' })' + CRLF)
		EndIf
	Next nX
	aAdd(aLinesProg, CRLF)
	
	//�tems de RG5
	DbSelectArea("RG5")
	RG5->(dbGoTop())
	RG5->(dbSetOrder(RetOrder("RG5", "RG5_FILIAL+RG5_PDPERI")))

	While !RG5->(Eof())

	 	cProg := "	aAdd(aItensRG5, { "
		For nX := 1 To Len(aIniHdrRG5)
			cValueCampo := ""

			If "FILIAL" $ aIniHdrRG5[nX,2]
				cValueCampo += ""
			Else
				cValueCampo += &(aIniHdrRG5[nX,2])
			EndIf

			cValueCampo := StrTran(cValueCampo, "'", '"')

			If (aIniHdrRG5[nX,8] != "N") .and. (aIniHdrRG5[nX,8] != "D") .and. (aIniHdrRG5[nX,8] != "L")
				cValueCampo := "'" + cValueCampo
				cValueCampo += "'"
			EndIf
	
			cProg += cValueCampo
			If nX < Len(aIniHdrRG5)
				cProg += ","
			EndIf
		Next nX
		cProg += "} )"
		aAdd(aLinesProg, cProg + CRLF)
		RG5->(dbSkip())

	EndDo

	aAdd(aLinesProg, CRLF)
	aAdd(aLinesProg, 'Return ( lRet )' + CRLF)  

	//Encabezado de la Funci�n
	aAdd(aLinProg2, '#INCLUDE "PROTHEUS.CH"' + CRLF + CRLF)
	aAdd(aLinProg2, "/*/" + CRLF)
	aAdd(aLinProg2, "�����������������������������������������������������������������������Ŀ" + CRLF)
	aAdd(aLinProg2, "�Fun��o    �GpRG9" + cPaisLoc + "     " + "�Autor� TOTVS � Data �" + SubStr(DtoS(date()),7,2)+"/"+SubStr(DtoS(date()),5,2)+"/"+SubStr(DtoS(date()),1,4) + "               �" + CRLF)
	aAdd(aLinProg2, "�����������������������������������������������������������������������Ĵ" + CRLF)
	aAdd(aLinProg2, "�Descri��o �Criterios de Acumulaci�n                                    �" + CRLF)
	aAdd(aLinProg2, "�����������������������������������������������������������������������Ĵ" + CRLF)
	aAdd(aLinProg2, "�Sintaxe   �                                                            �" + CRLF)
	aAdd(aLinProg2, "�����������������������������������������������������������������������Ĵ" + CRLF)
	aAdd(aLinProg2, "�Parametros�Ver par�metros formales                                     �" + CRLF)
	aAdd(aLinProg2, "�����������������������������������������������������������������������Ĵ" + CRLF)
	aAdd(aLinProg2, "� Uso      �Gen�rico                                                    �" + CRLF)
	aAdd(aLinProg2, "�������������������������������������������������������������������������/*/" + CRLF)
	aAdd(aLinProg2, "Function GpRG9" + cPaisLoc + "(aItensRG9, aRG9Header)" + CRLF + CRLF)
	
	aAdd(aLinProg2, "Local lRet		:= .T." + CRLF + CRLF)
	
	aAdd(aLinProg2, "Default aItensRG9	:= {}" + CRLF)
	aAdd(aLinProg2, "Default aRG9Header	:= {}" + CRLF + CRLF)                          
	
	aAdd(aLinProg2, "/*/" + CRLF)
	aAdd(aLinProg2, "��������������������������������������������������������������Ŀ" + CRLF)
	aAdd(aLinProg2, "� Encabezado de RG9 generado por el Procedimiento est�ndar    �" + CRLF)
	aAdd(aLinProg2, "����������������������������������������������������������������/*/" + CRLF)

	For nX := 1 To Len(aIniHdrRG9)
		cProg := ""
		For nY := 1 To Len(aIniHdrRG9[nX])
			cTexto := If(ValType(aIniHdrRG9[nX,nY])=="N", AllTrim(Str(aIniHdrRG9[nX,nY])),;
						   	If(ValType(aIniHdrRG9[nX,nY])=="L", Transform(aIniHdrRG9[nX, nY],"@!"),;
						   	   aIniHdrRG9[nX, nY]))
			cTexto := StrTran(cTexto, "'", '"')
			cProg += "'" + cTexto + "'"
			If nY < Len(aIniHdrRG9[nX])
				cProg += ","
			EndIf
		Next nY
		If !Empty(cProg)
			aAdd(aLinProg2, "aAdd(aRG9Header, " + '{ ' + cProg + ' })' + CRLF)
		EndIf
	Next nX

	aAdd(aLinProg2, CRLF)

	//�tems de Tipo de C�lculo
	DbSelectArea("RG9")
	RG9->(DBSetOrder(1)) //RG9_FILIAL+ RG9_CODCRI
	RG9->(DBGoTop())
		
	While !RG9->(Eof())
	 
	 	cProg := "	aAdd(aItensRG9, { "
		For nX := 1 To Len(aIniHdrRG9)
			cValueCampo := ""
	
			If aIniHdrRG9[nX,8] == "N"
				cValueCampo += AllTrim(Str(&(aIniHdrRG9[nX,2])))
			ElseIf "FILIAL" $ aIniHdrRG9[nX,2]
				cValueCampo += ""
			Else
				cValueCampo += &(aIniHdrRG9[nX,2])
			EndIf

			cValueCampo := StrTran(cValueCampo, "'", '"')
	
			If (aIniHdrRG9[nX,8] != "N") .and. (aIniHdrRG9[nX,8] != "D") .and. (aIniHdrRG9[nX,8] != "L")
				cValueCampo := "'" + cValueCampo
				cValueCampo += "'"
			EndIf

			cProg += cValueCampo
			If nX < Len(aIniHdrRG9)
				cProg += ","
			EndIf
		Next nX
		cProg += "} )"
		aAdd(aLinProg2, cProg + CRLF)
		RG9->(dbSkip())

	EndDo

	aAdd(aLinProg2, "" + CRLF)

	aAdd(aLinProg2, CRLF)
	aAdd(aLinProg2, 'Return ( lRet )' + CRLF + CRLF)

	//Transfiere las l�neas al programa
    For nX := 1 To Len(aLinesProg)
	    Fwrite( nArq, aLinesProg[nX] )
	Next nX

	FClose(nArq)  

	//Transfiere las l�neas al programa
    For nX := 1 To Len(aLinProg2)
	    Fwrite( nArq2, aLinProg2[nX] )
	Next nX

	FClose(nArq2)

	aAdd(aListaArch, cNomArch1) //"GPRGX" + cPaisLoc + ".PRX"
	aAdd(aListaArch, cNomArch2) //"GPRG9" + cPaisLoc + ".PRX"

	End Sequence

Return Nil

/*/{Protheus.doc} GpexDelRGX
	Funci�n utilizada para eliminar registros de las tablas RG5, RG6 y RG9; para
	preparar la carga de informaci�n est�ndar.

	@type  Static Function
	@author marco.rivera
	@since 28/09/2022
	@version 1.0
	@example
	GpexDelRGX()
/*/
Function GpexDelRGX()

	Local cModFol	:= SuperGetMV("MV_MODFOL", .F., "2") //Par�metro para determinar el modelo de la rutina.

	RG9->(DbGoTop())
	RG9->(DbSetOrder(1)) //RG9_FILIAL+RG9_CODCRI

	While RG9->(!EoF())

		RG6->(DbGoTop())
		RG6->(DbSetOrder(1)) //RG6_FILIAL+RG6_PDPERI+RG6_CODIGO+RG6_NUMPAG

		While RG6->( !Eof())
			If RG6->(RG6_FILIAL+AllTrim(RG6_CRITER)) == RG9->(RG9_FILIAL+RG9_CODCRI)
				If (cModFol == "2") //Si es Modelo 2, borra registros de RG5
					RG5->(DbSeek(RG6->( RG6_FILIAL + RG6_PDPERI ) , .F. ) )
					While RG5->( !Eof() ) .And. (RG5->(RG5_FILIAL + RG5_PDPERI) == RG6->(RG6_FILIAL + RG6_PDPERI))
						If RG5->(RecLock("RG5", .F. , .F.))
							RG5->(DBDelete())
							RG5->(MsUnLock())
						EndIf
						RG5->(DBSkip())
					EndDo
				EndIf
				If RG6->(RecLock( "RG6", .F., .F.))
					RG6->(DBDelete())
					RG6->(MsUnLock())
				EndIf
			EndIf
			RG6->(DBSkip())
		EndDo
		If RG9->(RecLock("RG9", .F., .F.))
			RG9->(DBDelete())
			RG9->(MsUnLock())
		EndIf
	 	RG9->( DBSkip() )
	EndDo
	
Return Nil

/*/{Protheus.doc} GpexCrgRGX
	Funci�n utilizada para cargar los registros de las Tablas de Estandar de Periodos 
	RG5 y RG6 a partir de conceptos por procesos.

	@type  Function
	@author marco.rivera
	@since 28/09/2022
	@version 1.0
	@example
	GpexCrgRGX()
	/*/
Function GpexCrgRGX()

	Local aArea		:= GetArea()
	Local aAreaRG5	:= RG5->(GetArea())
	Local aAreaRG6	:= RG6->(GetArea())  
	Local aAux		:= {}
	Local aAuxRG5   := {}
	Local aRG5Header:= {}
	Local aRG6Header:= {}
	Local bFunc		:= {|| NIL}
	Local cCampo	:= ""
	Local cFilRG5	:= xFilial("RG5")
	Local cFilRG6	:= xFilial("RG6")
	Local cEstper	:= ""
	Local cEstped   := ""
	Local cFunRGX	:= ("GPRGX" + cPaisLoc)
	Local nFieldPos
	Local nPosField
	Local nPosEstPer
	Local nPosEstPed
	Local nPosEstCod
	Local nPosEstNum
	Local nAux
	Local nAuxRG6
	Local nAuxs
	Local nAuxsRG6
	Local nX
	Local uCnt
	Local cFiltro := 'RG5->RG5_FILIAL == "' + cFilRG5+ '"' 
	Local cFiltro1 := 'RG6->RG6_FILIAL == "' + cFilRG6 + '"' 
	Local bFiltro := { || &(cFiltro) }
	Local bFiltro1 := { || &(cFiltro1) }

	//Valida que exista la funci�n del pa�s actual
	If FindFunction(cFunRGX)
		bFunc := __ExecMacro("{ ||  " + cFunRGX + "( @aAux , @aRG6Header, @aAuxRG5 , @aRG5Header ) }")
		Eval(bFunc)
		DbSelectarea("RG5")
		RG5->(DbSetOrder(1)) //RG5_FILIAL+RG5_PDPERI
		DbSelectarea("RG6")
		RG6->(DbSetOrder(1)) //RG6_FILIAL+RG6_PDPERI+RG6_CODIGO+RG6_NUMPAG
		RG5->(DbSetfilter( bFiltro, cFiltro ))
		RG5->(DbGoTop())
		RG6->(DbSetfilter( bFiltro1, cFiltro1 ))
		RG6->(DbGoTop())
			
		//Verifica si la tabla est�ndar de periodos est� vac�a, para la sucursal en uso -- Se estiver realizar a carga
		If RG5->(Eof())
			nPosEstPer := GdFieldPos("RG5_PDPERI" , aRG5Header) 
			nAuxs := Len(aAuxRG5)
			DbSelectarea("RG5")
			RG5->(DbSetOrder(1)) //RG5_FILIAL+RG5_PDPERI
			For nAux := 1 To nAuxs
				cEstper := Padr(Upper(AllTrim(aAuxRG5[ nAux, nPosEstPer ])),TamSX3("RG5_PDPERI")[1])
				
				RecLock("RG5", IIf(RG5->(MsSeek(cFilRG5 + cEstper)), .F., .T.), .T.)

				For nX := 1 To Len(aRG5Header)
					cCampo := Upper(aRG5Header[nX, 2])
					nFieldPos := RG5->(FieldPos(cCampo))
					If (nFieldPos > 0)
						If (aRG5Header[nX, 2] == "RG5_FILIAL")
							uCnt := cFilRG5
						Else
							nPosField := GdFieldPos(cCampo , aRG5Header)
							uCnt := aAuxRG5[nAux , nPosField]
						Endif
						RG5->(FieldPut(nFieldPos , uCnt))
					EndIF
				Next nX
				RG5->(MsUnlock())

			Next nAux
		EndIf

		//Verifica si la tabla Detalle Est�ndar de Periodos est� vac�a para la sucursal en uso.
		If RG6->(Eof())
			nPosEstPed := GdFieldPos("RG6_PDPERI" , aRG6Header) 
			nPosEstCod := GdFieldPos("RG6_CODIGO" , aRG6Header) 
			nPosEstNum := GdFieldPos("RG6_NUMPAG" , aRG6Header) 
			nAuxsRG6 := Len(aAux)
			DbSelectarea("RG6")
			RG6->(DbSetOrder(1)) //RG6_FILIAL+RG6_PDPERI+RG6_CODIGO+RG6_NUMPAG
			For nAuxRG6 := 1 To nAuxsRG6
				cEstped := Padr(Upper(AllTrim(aAux[ nAuxRG6, nPosEstPed ])),TamSX3("RG6_PDPERI")[1])
				cEstped += Padr(Upper(AllTrim(aAux[ nAuxRG6, nPosEstCod ])),TamSX3("RG6_CODIGO")[1])
				cEstped += Padr(Upper(AllTrim(aAux[ nAuxRG6, nPosEstNum ])),TamSX3("RG6_NUMPAG")[1])

				RecLock("RG6", IIf(RG6->(MsSeek(cFilRG6 + cEstped)), .F., .T.), .T.)

				For nX := 1 To Len(aRG6Header)
					cCampo := Upper(aRG6Header[nX, 2])
					nFieldPos := RG6->(FieldPos(cCampo))
					If (nFieldPos > 0)
						If (aRG6Header[nX, 2] == "RG6_FILIAL")
							uCnt := cFilRG6
						Else
							nPosField := GdFieldPos(cCampo , aRG6Header)
							uCnt := aAux[nAuxRG6 , nPosField]
						Endif
						RG6->(FieldPut(nFieldPos , uCnt))
					EndIF
				Next nX
				RG6->(MsUnlock())
			Next nAuxRG6
		EndIf
	EndIf

	RestArea(aAreaRG5)
	RestArea(aAreaRG6)
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} GpexCrgRG9
	Funci�n utilizada para arga los Registros de la Tabla de 
	Criterios de Acumulaci�n (RG9) a partir de conceptos por proceso.

	@type  Function
	@author marco.rivera
	@since 28/09/2022
	@version 1.0
	@example
	GpexCrgRG9()
	/*/
Function GpexCrgRG9()

	Local aArea		:= GetArea()
	Local aAreaRG9	:= RG9->(GetArea()) 
	Local aAux		:= {}
	Local aRG9Header:= {}
	Local bFunc		:= {|| NIL}
	Local cCampo	:= ""
	Local cFilRG9	:= xFilial("RG9")
	Local cAusent	:= ""
	Local cFunRG9	:= ("GPRG9" + cPaisLoc)
	Local nFieldPos
	Local nPosField
	Local nPosAusent
	Local nAux
	Local nAuxs
	Local nX
	Local uCnt
	Local cFiltro := 'RG9->RG9_FILIAL == "' + cFilRG9 + '"' 
	Local bFiltro := { || &(cFiltro) }

	//Valida que exista la funci�n del pa�s actual
	If FindFunction(cFunRG9)
		bFunc := __ExecMacro("{ ||  " + cFunRG9 + "( @aAux , @aRG9Header ) }")
		Eval(bFunc)
		DbSelectarea("RG9")
		RG9->(DbSetOrder(1)) //RG9_FILIAL+ RG9_CODCRI
		RG9->(DbSetfilter( bFiltro, cFiltro ))
		RG9->(DbGoTop())
		
		//Verifica si la tabla de Criterios de Acumulaci�n est� vac�a para la sucursal en uso.
		If RG9->(Eof())
			nPosAusent := GdFieldPos("RG9_CODCRI" , aRG9Header) 
			nAuxs := Len(aAux)
			DbSelectarea("RG9")
			RG9->(DbSetOrder(1)) //RG9_FILIAL+ RG9_CODCRI
			For nAux := 1 To nAuxs
				cAusent := Padr(Upper(AllTrim(aAux[ nAux, nPosAusent ])),TamSX3("RG9_CODCRI")[1])

				RecLock("RG9", IIf(RG9->(DBSeek(cFilRG9 + cAusent)), .F., .T.), .T.)

				For nX := 1 To Len(aRG9Header)
					cCampo := Upper(aRG9Header[nX, 2])
					nFieldPos := RG9->(FieldPos(cCampo))
					If (nFieldPos > 0)
						If (aRG9Header[nX, 2] == "RG9_FILIAL")
							uCnt := cFilRG9
						Else
							nPosField := GdFieldPos(cCampo , aRG9Header)
							uCnt := aAux[nAux , nPosField]
						Endif
						RG9->(FieldPut(nFieldPos , uCnt))
					EndIF
				Next nX
				RG9->(MsUnlock())
			Next nAux
		EndIf
	EndIf

	RestArea(aAreaRG9)
	RestArea(aArea)
	
Return Nil
