#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "GPEM004DOM.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GPEM004DOM³ Autor ³ Flor Monroy                    ³ Data ³ 21/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generacion de Archivos Magnetico de Novedades                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM004DOM()                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³      FNC     ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Christiane V³15/02/12³0000018897/2011³Correção na impressão dos valores         ³±±
±±³            ³        ³               ³                                          ³±±
±±³Mohanad Odeh³04/07/12³0000016880/2012³Correção na impressão dos valores         ³±±
±±³            ³        ³         TFHFG7³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function GPEM004DOM()

Local aSays	      := { }
Local aButtons    := { }
Local aGetArea	  := GetArea()
Local cPerg       := "GPM004DOM"                    
Local nOpca     

Private cCadastro := OemtoAnsi(STR0001)//"Archivo Magnetico de Novedades"
Private cFilIni   := ""   //De Sucursal
Private cFilFin   := ""	  //A Sucursal
Private cProIni   := ""   //De Proceso
Private cProFin   := ""   //A Proceso
Private cMatIni   := ""   //De Matricula
Private cMatFin   := ""   //A Matricula
Private cArchivo  := ""   //Ruta y nombre del archivo
Private cMes	  := ""
Private cAnio	  := ""
Private cEOL    := CHR(13)+CHR(10)

Private nMesA     := ""   //Periodo de Aplicación de la novedad

Private lExisArc  := .F.
Private lError    := .f.

Private nMax:=0

dbSelectArea("SRA")  //Empleados
dbSelectArea("RG7")  //Historico de acumulados
dbSelectArea("SRV")  //Conceptos 
dbSelectArea("RCJ")  //Procesos
DbSetOrder(1)


AADD(aSays,OemToAnsi(STR0002) )//"Esta rutina genera los Archivos Magnéticos de Novedades"

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(TodoOK(cPerg),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	
FormBatch( cCadastro, aSays, aButtons )

If  nOpca == 1 //Ejecuta el proceso
	Processa({|| GPM799GERA() },OemToAnsi(STR0003))  //"Procesando..."
	If  lError
	    Msgalert(STR0004) //"Hubo problemas durante el proceso, y el archivo generado puede tener inconsistencias!!"
    Else	                      
		If  nMax==0             
			If  !lExisArc
		   		msgInfo(STR0005)//"Proceso Fianlizado! No encontro registros..."
		 	Endif
		Else
		   msgInfo(STR0006+cEOL+cArchivo)   //"Proceso Finalizado, Genero los archivos: "
		Endif
	ENDIF	
Endif

RestArea(aGetArea)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³ GPM799GERA³ Autor ³ Laura Medina        ³ Data ³ 13/07/11 ³±±                
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Generacion de los archivos de Bonificacion Infotep.       ³±± 
±±³           ³                                                           ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ GPM799GERA()			                                  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±  
±±³Parametros ³  Ninguno                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ GPEM799                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GPM799GERA
Local aNovedad := {}
//Obtener los registros con los cuales se va a generar el archivo de Bonificacion
aNovedad := ObtNove()
If !Empty(aNovedad)  //Encontro registros para procesar
	GenArch(aNovedad)  //Rutina que genera el archivo de Bonificacion
Endif

Return ( Nil )                  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³ ObtNove   ³ Autor ³ Flor Monroy         ³ Data ³ 13/07/11 ³±±                
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Obtiene Novvedades                                        ³±± 
±±³           ³                                                           ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ ObtNove()   		                                      ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³  Ninguno                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ GPEM799                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ObtNove()       
Local cAliasTmp := CriaTrab(Nil,.F.)	   
Local cSRAName  := InitSqlName("SRA")    
Local cRG7Name  := InitSqlName("RG7")
Local cSRVName  := InitSqlName("SRV")
Local cSR7Name  := InitSqlName("SR7")
Local cQuery    := "" 
Local cCriterio := 	'01'  
Local cCodFol   := 	"'0019','1040','0015','0443','1118','0565','0477','1179'"     
Local cEmpleado := 	Space(TAMSX3("RA_FILIAL")[1]+TAMSX3("RA_MAT")[1])
Local cFilSRV   := 	xFilial( "SRV", RG7->RG7_FILIAL)                                                                                   
Local cFilRG7   := 	xFilial( "RG7", SRA->RA_FILIAL)                                                                                   
Local cIniMes   := 	DTOS( CTOD( '01/'+cMes+'/'+cAnio) ) 
Local cFinMes   := 	DTOS( ctod(StrZero(F_UltDia(CTOD("01/" + cMes + "/" + cAnio)),2,0)+ "/"+cMes+"/"+cAnio) )
   
Local nReg 		:= 0   
Local nPos      := 0

Local aAusencias:=ObtAusen()// {ALLTRIM(R8_FILIAL)+ALLTRIM(R8_MAT),R8_FILIAL,R8_MAT,R8_DATAINI,R8_DATAFIM,'VC'(Tipo de Novedad)}
Local aNovedades:={}

cQuery := " SELECT SRA.RA_FILIAL,   SRA.RA_MAT,      SRA.RA_NUMINSC,  SRA.RA_ADMISSA, " + cEOL
cQuery += "		   SRA.RA_DEMISSA,  SRA.RA_CIC,      SRA.RA_NSEGURO, " + cEOL
cQuery += "        SRA.RA_PASSPOR,  SRA.RA_NOME,     SRA.RA_PRINOME,  SRA.RA_SECNOME, " + cEOL
cQuery += "		   SRA.RA_PRISOBR,  SRA.RA_SECSOBR,  SRA.RA_SEXO,     SRA.RA_NASC, " + cEOL
cQuery += "        RG7.RG7_ACUM"+cMes+"   RG7_ACUMXX, " + cEOL
cQuery += "        SRV.RV_CODFOL,   SRA.RA_TIPOADM, SR7.R7_DATA" + cEOL
cQuery += " FROM   "+cSRAName+" SRA INNER JOIN "+cRG7Name+ " RG7 " + cEOL
cQuery += " ON SRA.RA_MAT = RG7.RG7_MAT AND SRA.RA_PROCES = RG7.RG7_PROCES " + cEOL
cQuery += " INNER JOIN "+cSRVName+ " SRV " + cEOL
cQuery += " ON SRV.RV_COD=RG7.RG7_PD " + cEOL
cQuery += " LEFT JOIN "+cSR7Name+" SR7 ON " + cEOL
cQuery += "		   SRA.RA_FILIAL = SR7.R7_FILIAL AND SRA.RA_MAT = SR7.R7_MAT AND SR7.D_E_L_E_T_=' ' " + cEOL
cQuery += " WHERE " + cEOL
cQuery += "		       SRA.RA_FILIAL BETWEEN '" + cFilIni+ "' AND '"+ cFilFin+ "' "  + cEOL
cQuery += "	       AND SRA.RA_MAT  BETWEEN '" + cMatIni+ "' AND '"+ cMatFin+ "' " + cEOL
cQuery += "	       AND SRA.RA_PROCES  BETWEEN '" + cProIni+ "' AND '"+ cProFin+ "' " + cEOL
cQuery += "		   AND RG7.RG7_FILIAL = '"+ cFilRG7+ "' "  + cEOL
cQuery += "		   AND RG7.RG7_CODCRI  = '"+ cCriterio+ "' " + cEOL
cQuery += "		   AND (  " + cEOL
cQuery += "				    (SRA.RA_ADMISSA  BETWEEN '" + cIniMes+ "' AND '"+ cFinMes+ "' ) " + cEOL
cQuery += "				OR  (SRA.RA_DEMISSA  BETWEEN '" + cIniMes+ "' AND '"+ cFinMes+ "' ) " + cEOL
cQuery += "				OR  (SR7.R7_DATA     BETWEEN '" + cIniMes+ "' AND '"+ cFinMes+ "' ) )" + cEOL
cQuery += "	       AND SRV.RV_FILIAL='"+cFilSRV+"' " + cEOL
cQuery += "	       AND SRV.RV_CODFOL IN ("+cCodFol+") " + cEOL
cQuery += "	       AND SRV.D_E_L_E_T_=' ' " + cEOL
cQuery += " 	   AND RG7.D_E_L_E_T_=' ' " + cEOL
cQuery += "        AND SRA.D_E_L_E_T_=' ' " + cEOL
cQuery += " ORDER BY SRA.RA_FILIAL, SRA.RA_NUMINSC, SRA.RA_MAT "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
Count to nReg
	
	(cAliasTmp)->(dbgotop())
	ProcRegua(nReg)   
	While  (cAliasTmp)->(!EOF())
		IncProc()          
	    cEmpleado := (cAliasTmp)->RA_FILIAL+(cAliasTmp)->RA_MAT
		
		If((cAliasTmp)->RA_ADMISSA <=cFinMes .And. (cAliasTmp)->RA_ADMISSA >=cIniMes,cNov:="IN",)
		If((cAliasTmp)->RA_DEMISSA <=cFinMes .And. (cAliasTmp)->RA_DEMISSA >=cIniMes,cNov:="SA",)
		If((cAliasTmp)->R7_DATA    <=cFinMes .And. (cAliasTmp)->R7_DATA    >=cIniMes,cNov:="AD",)

		aAdd(aNovedades,{(cAliasTmp)->RA_FILIAL,;
					(cAliasTmp)->RA_MAT,;
					(cAliasTmp)->RA_ADMISSA,;
					(cAliasTmp)->RA_DEMISSA,;
					(cAliasTmp)->R7_DATA,;
					 "",; //R8_DATAINI
					 "",; //R8_DATAFIM
					(cAliasTmp)->RA_NUMINSC,;   
					(cAliasTmp)->RA_CIC,; 
					(cAliasTmp)->RA_NSEGURO,;    
					(cAliasTmp)->RA_PASSPOR,;     
					(cAliasTmp)->RA_PRINOME,; 
					(cAliasTmp)->RA_SECNOME,; 
					(cAliasTmp)->RA_PRISOBR,; 
					(cAliasTmp)->RA_SECSOBR,; 
					(cAliasTmp)->RA_SEXO,; 
					(cAliasTmp)->RA_NASC,; 
					IIF(STOD((cAliasTmp)->RA_ADMISSA)>CTOD('01/01'+cMes),'0004',(cAliasTmp)->RA_TIPOADM),;
					(cAliasTmp)->RV_CODFOL,;
					0 ,;//RV_CODFOL == '0019'//20 
					0 ,;//RV_CODFOL == '1040'//21
					0 ,;//RV_CODFOL == '0015'//22
					0 ,;//RV_CODFOL == '0443'//23
					0 ,;//RV_CODFOL == '1118'//24
					0 ,;//RV_CODFOL == '0565'//25
					0 ,;//RV_CODFOL == '0477'//26
					0 ,;//RV_CODFOL == '1179'//27
					cNov,;
					}) //28 
										
		While (cAliasTmp)->(!EOF()).And. cEmpleado == (cAliasTmp)->RA_FILIAL+(cAliasTmp)->RA_MAT
		
			Do Case
				Case	(cAliasTmp)->RV_CODFOL=='0019'
					aNovedades[len(aNovedades),20]:= (cAliasTmp)->RG7_ACUMXX 
				Case 	(cAliasTmp)->RV_CODFOL=='1040'
					aNovedades[len(aNovedades),21]:= (cAliasTmp)->RG7_ACUMXX 
				Case	(cAliasTmp)->RV_CODFOL=='0015'
					aNovedades[len(aNovedades),22]:= (cAliasTmp)->RG7_ACUMXX 
				Case	(cAliasTmp)->RV_CODFOL=='0443' 
					aNovedades[len(aNovedades),23]:= (cAliasTmp)->RG7_ACUMXX 
				Case	(cAliasTmp)->RV_CODFOL=='1118' 
					aNovedades[len(aNovedades),24]:= (cAliasTmp)->RG7_ACUMXX 
				Case	(cAliasTmp)->RV_CODFOL=='0565' 
					aNovedades[len(aNovedades),25]:= (cAliasTmp)->RG7_ACUMXX 
				Case	(cAliasTmp)->RV_CODFOL=='0477' 
					aNovedades[len(aNovedades),26]:= (cAliasTmp)->RG7_ACUMXX 
				Case	(cAliasTmp)->RV_CODFOL=='1179' 
					aNovedades[len(aNovedades),27]:= (cAliasTmp)->RG7_ACUMXX 
			EndCase
			
			(cAliasTmp)->(dbSkip())
		EndDo
		
        If !Empty(aAusencias)
		    If (nPos:=aScan(aAusencias,{|aVal|aVal[1]==cEmpleado}))>0 
				While nPos<=len(aAusencias).And. cEmpleado==aAusencias[nPos][1]
					aAdd(aNovedades,{aAusencias[nPos,2],;
					aAusencias[nPos,3],;
					aNovedades[len(aNovedades),3],;
					aNovedades[len(aNovedades),4],;
					aNovedades[len(aNovedades),5],;
					aAusencias[nPos,4],; //R8_DATAINI
					aAusencias[nPos,5],; //R8_DATAFIM
					aNovedades[len(aNovedades),8],;   
					aNovedades[len(aNovedades),9],; 
					aNovedades[len(aNovedades),10],;    
					aNovedades[len(aNovedades),11],;     
					aNovedades[len(aNovedades),12],; 
					aNovedades[len(aNovedades),13],; 
					aNovedades[len(aNovedades),14],; 
					aNovedades[len(aNovedades),15],; 
					aNovedades[len(aNovedades),16],; 
					aNovedades[len(aNovedades),17],; 
					'0004',;
					aNovedades[len(aNovedades),19],;
					aNovedades[len(aNovedades),20] ,;
					aNovedades[len(aNovedades),21],;
					aNovedades[len(aNovedades),22],;
					aNovedades[len(aNovedades),23],;
					aNovedades[len(aNovedades),24] ,;
					aNovedades[len(aNovedades),25] ,;
					aNovedades[len(aNovedades),26] ,;
					aNovedades[len(aNovedades),27] ,;
					aAusencias[nPos,6],;
					}) 
				    nPos++
					If	nPos>len(aAusencias)
						exit 
					EndIf
				EndDo	
			EndIf
		EndIf

	Enddo
	(cAliasTmp)->( dbCloseArea()) 	
Return ( aNovedades )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GenArch  ³ Autor ³ FMonroy               ³ Data ³ 13/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion que va a generar los registros para el archivo TXT ³±±  
±±³          ³ dependiendo de los paráetros selecccionados.               ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GenArch(aExp1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  aExp1.-Registros que se colocaran en el archivo de salida ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM799GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function GenArch(aAcumula)       
Local lRet      := .T.
Local lCedula   := .F.

Local nArchivo   := 0
Local nIdx      := 0 
Local nloop     := 0   
Local nEnc      :=0
   
Local cTipoDoc  := ""
Local cDocto    := ""  
Local cCedula   := ""  


Local dDataI
Local dDataF

cArchivo  := Iif(At(".txt",cArchivo)>0,cArchivo,Alltrim(cArchivo)+'.txt')
lExisArc  := .F.

If  File(cArchivo)  //Si el archivo ya existe
	If  MsgYesNo(oemtoansi(STR0008+Alltrim(cArchivo)+STR0009))   //"El archivo "+XXX+" ya existe, ¿Desea eliminarlo?"
		FErase(cArchivo) 		
	Else 
		lRet     := .F.   
		lExisArc := .T.  
		fClose(nArchivo) 
	EndIf 
Endif     

If  lRet  
	//Creacion de archivo
	nArchivo  := MSfCreate(cArchivo,0)
  
	ProcRegua(len(aAcumula))    
	nloop:=1
	nEnc:=0
	While nloop<=len(aAcumula) 
		IncProc()           
		lCedula   := .F.
		cSucursal :=aAcumula[nloop,1]
		nIdx      :=FPOSTAB("S012",cSucursal,"=",1)
		If nIdx == 0
			nIdx  :=FPOSTAB("S012",Space(Len(xfilial("RCB"))),"=",1)
		Endif
		cCedula   := If( nIdx > 0, fTabela("S012",nIdx,5),"")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Escribe Encabezado                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ          
		FWrite(nArchivo,"E"+"NV"+PADR(cCedula,11)+cMes+cAnio+cEOL)
		nEnc++         
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Escribe Detalle (Misma Sucursal)                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While nloop<=len(aAcumula) .and. cSucursal ==aAcumula[nloop,1]
		
			Do Case
			    Case aAcumula[nloop,28] =='IN'
					dDataI:=SUBSTR(aAcumula[nloop,3],7,2)+SUBSTR(aAcumula[nloop,3],5,2)+SUBSTR(aAcumula[nloop,3],1,4)
					dDataF:=""
			    Case aAcumula[nloop,28] =='SA'
					dDataI:=SUBSTR(aAcumula[nloop,4],7,2)+SUBSTR(aAcumula[nloop,4],5,2)+SUBSTR(aAcumula[nloop,4],1,4)
					dDataF:=""
			    Case aAcumula[nloop,28] =='AD'
					dDataI:=SUBSTR(aAcumula[nloop,5],7,2)+SUBSTR(aAcumula[nloop,5],5,2)+SUBSTR(aAcumula[nloop,5],1,4)
					dDataF:=""
			    Case aAcumula[nloop,28] =='LV' .Or. aAcumula[nloop,28] =='LM' .Or. aAcumula[nloop,28] =='LD' .Or. aAcumula[nloop,28] =='VC'
					dDataI:=SUBSTR(aAcumula[nloop,6],7,2)+SUBSTR(aAcumula[nloop,6],5,2)+SUBSTR(aAcumula[nloop,6],1,4)
					dDataF:=SUBSTR(aAcumula[nloop,7],7,2)+SUBSTR(aAcumula[nloop,7],5,2)+SUBSTR(aAcumula[nloop,7],1,4)
			EndCase
				//	Validar si es Cedula de identidad/No. Seg social/No. Pasaporte                      
			If !Empty(aAcumula[nloop,9])
				cDocto   := RTrim(aAcumula[nloop,9])
				cTipoDoc := 'C'  
				lCedula  := .T.
			Elseif  !Empty(aAcumula[nloop,10])
				cDocto:= RTrim(aAcumula[nloop,10])
				cTipoDoc := 'N'
			Elseif !Empty(aAcumula[nloop,11])
				cDocto:= RTrim(aAcumula[nloop,11])
				cTipoDoc := 'P'
			Endif
		
			FWrite(nArchivo,"D"+;
					Strzero(val(transform(aAcumula[nloop,8],"999")),3)+;
					Alltrim(aAcumula[nloop,28])+;
					dDataI+;
					PADR(dDataF,8)+;
					PADR(cTipoDoc,1)+;
					PADL(cDocto,25)+;
					Iif(lCedula,PADR("",50),PADR(Alltrim(aAcumula[nloop,12])+" "+Alltrim(aAcumula[nloop,13]),50))+;
					Iif(lCedula,PADR("",40),PADR(aAcumula[nloop,14],40))+;
					Iif(lCedula,PADR("",40),PADR(aAcumula[nloop,15],40))+;
					Iif(lCedula,PADR("",1), PADR(aAcumula[nloop,16],1))+;
					Iif(lCedula,PADR("",8), SUBSTR(aAcumula[nloop,17],7,2)+SUBSTR(aAcumula[nloop,17],5,2)+SUBSTR(aAcumula[nloop,17],1,4))+;
					Substr(Strzero((val(transform(aAcumula[nloop,20],"9999999999999.99"))*100),15),1,13)+"."+Substr(Strzero((val(transform(aAcumula[nloop,20],"9999999999999.99"))*100),15),14,15)+;
					Substr(Strzero((val(transform(aAcumula[nloop,21],"9999999999999.99"))*100),15),1,13)+"."+Substr(Strzero((val(transform(aAcumula[nloop,21],"9999999999999.99"))*100),15),14,15)+;
					Substr(Strzero((val(transform(aAcumula[nloop,22],"9999999999999.99"))*100),15),1,13)+"."+Substr(Strzero((val(transform(aAcumula[nloop,22],"9999999999999.99"))*100),15),14,15)+;
					Substr(Strzero((val(transform(aAcumula[nloop,23],"9999999999999.99"))*100),15),1,13)+"."+Substr(Strzero((val(transform(aAcumula[nloop,23],"9999999999999.99"))*100),15),14,15)+;
					PADR("",11)+;
					Substr(Strzero((val(transform(aAcumula[nloop,24],"9999999999999.99"))*100),15),1,13)+"."+Substr(Strzero((val(transform(aAcumula[nloop,24],"9999999999999.99"))*100),15),14,15)+;
					Substr(Strzero((val(transform(aAcumula[nloop,25],"9999999999999.99"))*100),15),1,13)+"."+Substr(Strzero((val(transform(aAcumula[nloop,25],"9999999999999.99"))*100),15),14,15)+;
					Substr(Strzero((val(transform(aAcumula[nloop,26],"9999999999999.99"))*100),15),1,13)+"."+Substr(Strzero((val(transform(aAcumula[nloop,26],"9999999999999.99"))*100),15),14,15)+;
					Substr(Strzero((val(transform(aAcumula[nloop,27],"9999999999999.99"))*100),15),1,13)+"."+Substr(Strzero((val(transform(aAcumula[nloop,27],"9999999999999.99"))*100),15),14,15)+;
					aAcumula[nloop,18]+cEOL)	
					nLoop++
	   EndDo
    EndDo
    
   	//Para cerrar el archivo creado
	If  Len(aAcumula)>0  
		//Registro sumario
		FWrite(nArchivo,"S"+strzero(len(aAcumula)+nEnc+1,6)+cEOL)
		fClose(nArchivo)  
		nMax:=Len(aAcumula)   
	Endif         
Endif            

Return ( Nil )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ObtAusen ³ Autor ³ Flor Monroy           ³ Data ³ 22/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene las Ausencias con forme a los parametros de entrada³±±  
±±³          ³                                                            ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ObtAusen()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM796GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function ObtAusen()
Local cAliasTmp := 	CriaTrab(Nil,.F.)	   
Local cSR8Name  := 	InitSqlName("SR8")     
Local cSRVName  := 	InitSqlName("SRV")     
Local cFilSRV   := 	xFilial( "SRV", SR8->R8_FILIAL)
Local cQuery    := 	""                                                                                     
Local cIniMes   := 	DTOS( CTOD( '01/'+cMes+'/'+cAnio) )
Local cFinMes   := 	DTOS( ctod(StrZero(F_UltDia(CTOD("01/" + cMes + "/" + cAnio)),2,0)+ "/"+cMes+"/"+cAnio) )
Local cId       :=	"'0072','0442','0040','0439','0583'"

Local aAus      :=  {}

cQuery := " SELECT SR8.R8_FILIAL, SR8.R8_MAT, SRV.RV_CODFOL, SR8.R8_DATAINI,SR8.R8_DATAFIM " 
cQuery += " FROM "+cSR8Name+" SR8, "+cSRVName+" SRV "
cQuery += " WHERE "
cQuery += "			SR8.R8_FILIAL BETWEEN '"+ cFilIni+ "' AND '"+ cFilFin+ "'"  
cQuery += "		AND SR8.R8_MAT  BETWEEN  '"+ cMatIni+ "' AND '"+ cMatFin+ "' "
cQuery += "		AND SR8.R8_PROCES  BETWEEN  '"+ cProIni+ "' AND '"+ cProFin+ "' "
cQuery += "		AND ( (SR8.R8_DATAINI  BETWEEN '" + cIniMes+ "' AND '"+ cFinMes+ "' )  "
cQuery += "		OR (SR8.R8_DATAFIM  BETWEEN '" + cIniMes+ "' AND '"+ cFinMes+ "' ) )" 
cQuery += "	    AND SRV.RV_COD=SR8.R8_TIPOAFA"
cQuery += "	    AND SRV.RV_FILIAL='"+cFilSRV+"'"
cQuery += "	    AND SRV.RV_CODFOL IN ("+cId+")"
cQuery += "	    AND SRV.D_E_L_E_T_=' '"
cQuery += " 		AND SR8.D_E_L_E_T_=' '"    
cQuery += " ORDER BY SR8.R8_FILIAL, SR8.R8_MAT, SR8.R8_DATAINI,SRV.RV_CODFOL"    
cQuery := ChangeQuery(cQuery)      

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)  
   
While (cAliasTmp)->(!EOF())
	Do Case
		Case	(cAliasTmp)->RV_CODFOL=='0072'
			aAdd(aAus,{ALLTRIM((cAliasTmp)->R8_FILIAL)+ALLTRIM((cAliasTmp)->R8_MAT),(cAliasTmp)->R8_FILIAL,(cAliasTmp)->R8_MAT,(cAliasTmp)->R8_DATAINI,(cAliasTmp)->R8_DATAFIM, 'VC'})	
		Case 	(cAliasTmp)->RV_CODFOL=='0442'
			aAdd(aAus,{ALLTRIM((cAliasTmp)->R8_FILIAL)+ALLTRIM((cAliasTmp)->R8_MAT),(cAliasTmp)->R8_FILIAL,(cAliasTmp)->R8_MAT,(cAliasTmp)->R8_DATAINI,(cAliasTmp)->R8_DATAFIM, 'LV'})	
		Case	(cAliasTmp)->RV_CODFOL=='0040'
			aAdd(aAus,{ALLTRIM((cAliasTmp)->R8_FILIAL)+ALLTRIM((cAliasTmp)->R8_MAT),(cAliasTmp)->R8_FILIAL,(cAliasTmp)->R8_MAT,(cAliasTmp)->R8_DATAINI,(cAliasTmp)->R8_DATAFIM, 'LM'})	
		Case	(cAliasTmp)->RV_CODFOL=='0439' .OR. (cAliasTmp)->RV_CODFOL=='0583'
			aAdd(aAus,{ALLTRIM((cAliasTmp)->R8_FILIAL)+ALLTRIM((cAliasTmp)->R8_MAT),(cAliasTmp)->R8_FILIAL,(cAliasTmp)->R8_MAT,(cAliasTmp)->R8_DATAINI,(cAliasTmp)->R8_DATAFIM, 'LD'})	
	EndCase
		
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->( dbCloseArea()) 

Return ( aAus )    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TodoOK   ³ Autor ³ Laura Medina          ³ Data ³ 13/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion que valida los parámetros de entrada para la obten-³±±  
±±³          ³ ción de la informacion.                                    ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TodoOK(cExp1)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  cExp1.-Nombre de grupo de pregunta                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM799GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function TodoOK(cPerg)
Local lRet := .T.             
Pergunte(cPerg,.F.)

cFilIni   := MV_PAR01   //De Sucursal
cFilFin   := MV_PAR02	//A Sucursal
cProIni   := MV_PAR03   //De Proceso
cProFin   := MV_PAR04   //A Proceso
cMatIni   := MV_PAR05   //De Matricula
cMatFin   := MV_PAR06   //A Matricula
cMes		 :=	SUBSTR(strZERO(MV_PAR07,6),1,2)
cAnio	 :=	SUBSTR(strZERO(MV_PAR07,6),3,4)
nMesA	 :=	MV_PAR07      //Periodo de Aplicación de la novedad
cArchivo  := MV_PAR08   //Ubicación del archivo de salida

If  Empty(cArchivo)
	msginfo(STR0007)//"Debe proporcionar la ruta y nombre del archivo!"
	lRet := .F. 
EndIf
	
Return ( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPM04DOM01³ Autor ³ FMonroy               ³ Data ³05/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacion de las preguntas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPM04DOM01()											      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X1_VALID - GPEM799 En X1_ORDEM = 7                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPM04DOM01() 
                                   
Local  cMes:=SUBSTR(STRZERO(MV_PAR07,6),1,2)
                
IF  val(cMes)<1 .or.val(cMes)>13
	msginfo(STR0010) //"El mes debe ser de 1 a 12!"
    Return .F.
ENDIF                  

Return (.T.)
