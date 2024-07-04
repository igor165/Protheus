#INCLUDE "Protheus.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "GPEM830.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM830  ³ Autor ³ Guadalupe Santacruz A ³ Data ³ 03/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ GENERACION DE ARCHIVOS DE AVISOS IMSS                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM830()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³Se coloco formato a los salarios.         ³±±
±±³gsantacruz  ³28/07/11³ Corr ³                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³Se coloco formato a los salarios.         ³±±
±±³gsantacruz  ³11/10/11³ Mej  ³Se agrego la funcion GPM830DIR y GPM830RET³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³gsantacruz  ³11/10/11³ Mej  ³Se cambio el formato RCO_NUMGAV			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEM830()

Local aSays		:={ }
Local aButtons	:= { }
Local aGetArea	:= GetArea()

Local cPerg		:="GPEM830"

Local nOpca

Private aCodRpat	:= {}  

Private cCadastro 	:= OemtoAnsi(STR0001)//"Archivos IDSE"
Private cAviAlt		:= "'01','03','06'" //Tipo de avisos de Altas o reingresos
Private cAviMod		:= "'05'" //Tipo de avisos de Modificacion de salarios
Private cAviBaj		:= "'02','04'" //Tipo de avisos de bajas
Private cTipAvi		:= ''    
Private cFilIni		:= ''
Private cFilFin		:= ''
Private cMatIni		:= ''
Private cMatFin		:= ''
Private cEnviados	:= ''
Private cLisPat		:= ''
Private cLisReg		:= ''
Private cArqTXT		:= ''
Private cEOL    	:= CHR(13)+CHR(10)
Private cArchivos	:= ''

Private dFecIni		:= Ctod("  /  /  ")
Private dFecFin		:= Ctod("  /  /  ")

Private lProblema	:= .f.

Private nMax		:= 0

dbSelectArea("SRA")  //Empleados
dbSelectArea("RCO")  //Registro patronal  
dbSelectArea("RCP")  //Trayectoria laboral
DbSetOrder(1)

AADD(aSays,OemToAnsi(STR0002) ) //"Esta rutina genera los Archivos de Avisos para el IMSS, "de:  Altas /Reingresos/Modificación de Salario y Bajas, "	
AADD(aSays,OemToAnsi(STR0003) ) //"de Empleados de un determinado periodo."		

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(TodoOK(cPerg),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	
FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1 //Ejecuta el proceso
	Processa({|| GPM830GERA() },OemToAnsi(STR0004))  //"Procesando..."
	If lProblema
	    Msgalert(STR0008)//"Hubo problemas durante el proceso, y el archivo generado puede tener inconsistencias!!"
    Else	                      

		If nMax==0
		   msgInfo(STR0009)//"Proceso Fianlizado! No encontro registros..."
		Else
		   msgInfo(STR0010+cEOL+cArchivos)   //"Proceso Finalizado, Genero los archivos: "
		Endif
	EndIf	
EndIf

RestArea(aGetArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TodoOK    ºAutor  ³Microsiga           º Data ³  03/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacion de los datos antes de Ejecutar el proceso        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TodoOK(cPerg)

	Local nCont		:= 0                                     
	Local nTamReg	:= TamSX3("RCO_CODIGO")[1]

	Pergunte(cPerg,.F.)
    cTipAvi		:= Alltrim(Str(MV_PAR01))
	cFilIni		:= MV_PAR02
	cFilFin		:= MV_PAR03
	cMatIni		:= MV_PAR04
	cMatFin		:= MV_PAR05
	dFecIni		:= MV_PAR06
	dFecFin		:= MV_PAR07
	cEnviados	:= Alltrim(str(MV_PAR08))
	cLisReg		:= Alltrim(MV_PAR09)
	cArqTXT		:= MV_PAR10

	If Empty(cLisReg)
		Msginfo(STR0014)//"Debe seleccionar al menos un registro patronal!"
		Return(.F.)
	EndIf

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Genera lista de registros patronales para usar despues en Query³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	cLisPat:=""
	For nCont := 1 To Len( cLisReg ) Step nTamReg
	    cLisPat+="'"+SubStr( cLisReg , nCont , nTamReg )+"',"
	Next
	cLisPat:=substr(cLisPat,1,len(cLisPat)-1)                                   

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPM830GERA³ Autor ³ Gpe Santacruz         ³ Data ³03/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Generacion de los archivos                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPM830GERA                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM830                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Gpm830Gera()

Local aControl:={}

Local cQuery	:= ''
Local cAliasTmp	:= Criatrab(nil,.f.)

Local nx		:= 0
Local nNum		:= 0
Local nNUMGAV	:= 0

Private aArcsGen:= {}

Private nHdl  	:= 1

lProblema := .F.

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Seleccion de Información³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cQuery := "SELECT RA_RG, RA_PRISOBR, RA_SECSOBR, RA_PRINOME, RA_SECNOME, RA_CURP, RA_UMEDFAM,  RCO_NUMGAV, RCO_NREPAT,RCP_CODRPA, RCP_SALDII,RCP_SALIVC, "
cQuery += " RCP_FILIAL, RCP.R_E_C_N_O_ RCPRECNO,RCP_MAT, RCP_TEIMSS,RCP_TSIMSS,RCP_TJRNDA,RCP_DTMOV,RCP_CBIMSS "
cQuery += " FROM " + initsqlname("RCP") + " RCP, "+initsqlname("SRA")+" SRA , "+initsqlname("RCO")+" RCO WHERE "
cQuery += " RCP_FILIAL  BETWEEN '"+cFilIni+"' AND '"+cFilFin+"' "
cQuery += "AND RCP_MAT=RA_MAT AND RCP_CODRPA=RCO_CODIGO "
cQuery += "AND RCP_MAT  BETWEEN '"+cMatIni+"' AND '"+cMatFin+"' "
cQuery += "AND RCP_DTMOV  BETWEEN '"+DTOS(dFecini)+"' AND '"+DTOS(dFecFin)+"' "
cQuery += "AND RCP_CODRPA IN ("+CLISPAT+") "
cQuery += "AND  RCP_FILIAL = RA_FILIAL AND RCO_FILIAL= '"  + xFilial("RCO" , SRA->RA_FILIAL) +"' "
Do case
   Case cTipAvi == '1'//Altas 
		cQuery += " AND   RCP_TPMOV IN ("+cAviAlt+") "
   Case cTipAvi == '2' //Bajas
		cQuery += " AND   RCP_TPMOV IN ("+cAviBaj+") "
   Case cTipAvi =='3' //Modificaciones
		cQuery += " AND   RCP_TPMOV IN ("+cAviMod+") "
EndCase
If cEnviados == '1' //Enviados    
	cQuery += " AND   RCP_DTIMSS <>' ' AND  RCP_HRIMSS <> '  ' "
Else //por enviar                                              
	cQuery += " AND   RCP_DTIMSS = ' ' AND  RCP_HRIMSS = '  ' "
EndIf
cQuery += " AND RCP.D_E_L_E_T_ = ' ' AND SRA.D_E_L_E_T_ = ' ' AND RCO.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY RCP_FILIAL,RCP_CODRPA,RCP_MAT"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
TCSetField(cAliasTmp,"RCP_DTMOV","D")  
Count TO nMax               
ProcRegua(nMax) // Número de registros a procesar

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Genera archivo por cada registro patronal³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
(cAliasTmp)->(dbgotop())
nMax := 0

While !(cAliasTmp)->(EOF())           
    
    nNum	:= 0
    nNUMGAV	:= 0
    
	cFilTmp	:= (cAliasTmp)->RCP_FILIAL
	cRegPat	:= (cAliasTmp)->RCP_CODRPA   
	
	CreaArc((cAliasTmp)->RCO_NREPAT) //Abre el nuevo archivo
	nTamLin := 168
	Do while !(cAliasTmp)->(EOF()) .and. cFilTmp+cRegPat==(cAliasTmp)->RCP_FILIAL+(cAliasTmp)->RCP_CODRPA
		nMax++;nNum++                                                                               
	    cLin    := Space(nTamLin)

  	    nNUMGAV:= (cAliasTmp)->RCO_NUMGAV
   		Do case
		   Case cTipAvi=='1'//Altas 
				ArcAltas(@cLin,cAliasTmp)
		   Case cTipAvi=='2' //Bajas
				ArcBajas(@cLin,cAliasTmp)
		   Case cTipAvi=='3' //Modificaciones
				ArcMods(@cLin,cAliasTmp)
		EndCase        

		cLin +=cEOL

	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³ Grabacion en el archivo texto. Comprueba errores durante la grabacion de la   ³
	    //³ linea montada.                                                                ³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
	        If !MsgAlert(STR0005,STR0006)//10-"Ocurrió un error en la grabación del archivo. ¿Continúa?",11-"¡Atención!"
		        lProblema:= .t.
	            Exit
	        EndIf
	    EndIf
	    
	    If cEnviados=='2'
		     aadd(aControl,(cAliasTmp)->RCPRECNO)
		EndIf     
	    IncProc()	     
	    (cAliasTmp)->(dbSkip())
    Enddo

	Gpm830Cifra(nNum,nNUMGAV)

	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgAlert(STR0005,STR0006)//"Ocurrió un error en la grabación del archivo. ¿Continúa?","¡Atención!"
			lProblema:= .t.
			Exit
		Endif
    EndIf
    fClose(nHdl)
    
EndDo

(cAliasTmp)->(dbclosearea())

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Actualiza RCP si la opcion fue de los pendiente por Enviar³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
ProcRegua(Len(aControl)) // Número de registros a procesar

For nx := 1 To Len(aControl)
    Incproc(STR0007)//"Actualizando Trayectoria Laboral"
    
    RCP->(dbgoto(aControl[nx]))
    If !RCP->(EOF())
        Reclock("RCP",.f.)
        RCP->RCP_DTIMSS:=DDATABASE
        RCP->RCP_HRIMSS:=TIME()
        RCP->(MSUNLOCK())
    EndIf
Next

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Envio de pantalla con la lista de todos los archivos generados (aArcsGen)³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cArchivos:=''
For nx:=1 to len(aArcsGen)          
	cArchivos+=alltrim(aArcsGen[nx])+cEOL
Next

Return                  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ArcAltas  ³ Autor ³ Gpe Santacruz         ³ Data ³03/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Formato de Archivo de Altas o Reingresos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ArcAltas (cExp1,cExp2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Linea a generar en el archivo                      ³±±
±±³          ³ cExp2.- Nombre del alias                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM830GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ArcAltas(cLin,cAliasTmp)	
	
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Registro patronal	N(10)	1 a 10	substring(RCO_NREPAT,1,10)                              			³
³Digito verificador	N(1)	11	substring(RCO_NREPAT,11,1)                                  			³
³Número de seguridad social	N(10)	12 a 21	substring(RA_RG,1,10)                          				³
³Dígito verificador NSS	N(1)	22	substring(RA_RG,11,1)                                   			³
³Apellido paterno	C(27)	23 a 49	substring(RA_PRISOBR,1,27)                                  		³
³Apellido materno	C(27)	50 a 76	substring(RA_SECSOBR,1,27)                                    		³
³Nombre del asegurado	C(27)	77 a 103	substring((rtrim(RA_PRINOME)+" "+rtrim(RA_SECNOME)),1,27)	³
³Salario diario integrado	N(6)	104 a 109	RCP_SALDII                                           	³
³Salario INFONAVIT	N(6)	110 a 115	RCP_SALIVC                                                  	³
³Tipo de trabajador	N(1)	116	RCP_TEIMSS                                                       		³
³Tipo de salario	N(1)	117	RCP_TSIMSS                                                          	³
³Reducción / Tipo de pago	N(1)	118	RCP_TJRNDA                                                 		³
³Fecha de movimiento	N(8)	119 a 126	RCP_DTMOV                                               	³
³Unidad de Medicina Familiar	N(3)	127 a 129	RA_UMEDFAM                                        	³
³Filler	C(2)	130 a 131	SPACE(2)                                                               		³
³Tipo de movimiento	N(2)	132 a 133	"08"                                                       		³
³Guía	N(5)	134 a 138	RCO_NUMGAV                                                               	³
³Clave del trabajador	N(10)	139 a 148	RCP_MAT+SPACE(4)                                        	³
³Filler	C(1)	149	SPACE(1)                                                                     		³
³Clave Única de Registro de Población	C(18)	150 a 167	RA_CURP                                 	³
³Identificador de Formato	N(1)	168	"9"                                                        		³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/ 
cLin := Stuff(cLin,01,10,substr((cAliasTmp)->RCO_NREPAT,1,10))
cLin := Stuff(cLin,11,1,substr((cAliasTmp)->RCO_NREPAT,11,1))
cLin := Stuff(cLin,12,10,substr((cAliasTmp)->RA_RG,1,10))
cLin := Stuff(cLin,22,1,substr((cAliasTmp)->RA_RG,11,1))
cLin := Stuff(cLin,23,27,substr((cAliasTmp)->RA_PRISOBR,1,27))
cLin := Stuff(cLin,50,27,substr((cAliasTmp)->RA_SECSOBR,1,27))
cLin := Stuff(cLin,77,27,padr(substr((alltrim(RA_PRINOME)+" "+alltrim(RA_SECNOME)),1,27),27))
   
cLin := Stuff(cLin,104,6,FormatSal((cAliasTmp)->RCP_SALDII))                                       
cLin := Stuff(cLin,110,6,FormatSal((cAliasTmp)->RCP_SALIVC))
cLin := Stuff(cLin,116,1,alltrim((cAliasTmp)->RCP_TEIMSS))
cLin := Stuff(cLin,117,1,alltrim((cAliasTmp)->RCP_TSIMSS))
cLin := Stuff(cLin,118,1,alltrim((cAliasTmp)->RCP_TJRNDA))
cLin := Stuff(cLin,119,8,ForFecha((cAliasTmp)->RCP_DTMOV))
cLin := Stuff(cLin,127,3,substr((cAliasTmp)->RA_UMEDFAM,1,3))
cLin := Stuff(cLin,130,2,space(2))
cLin := Stuff(cLin,132,2,"08")
cLin := Stuff(cLin,134,5,strzero((cAliasTmp)->RCO_NUMGAV,5))  
//cLin := Stuff(cLin,134,5,SUBSTR(ALLTRIM(STR((cAliasTmp)->RCO_NUMGAV)),1,5))
cLin := Stuff(cLin,139,10,PADR((cAliasTmp)->RCP_MAT,10))                                  
cLin := Stuff(cLin,149,1,space(1))
cLin := Stuff(cLin,150,18,(cAliasTmp)->RA_CURP)
cLin := Stuff(cLin,168,1,"9")  

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ArcMods   ³ Autor ³ Gpe Santacruz         ³ Data ³03/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Formato de Archivo de Modificacion de Salario              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ArcMods(cExp1,cExp2)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Linea a generar en el archivo                      ³±±
±±³          ³ cExp2.- Nombre del alias                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM830GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ArcMods(cLin,cAliasTmp)	

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Registro patronal	C(10)	1 a 10	substring(RCO_NREPAT,1,10)                                    		³
³Dígito verificador	N(1)	11	substring(RCO_NREPAT,11,1)                                        		³
³Número de seguridad social	N(10)	12 a 21	substring(RA_RG,1,10)                              	 		³
³Dígito verificador del NSS	N(1)	22	substring(RA_RG,11,1)                                     		³
³Apellido paterno	C(27)	23 a 49	substring(RA_PRISOBR,1,27)                                    		³
³Apellido materno	C(27)	50 a 76	substring(RA_SECSOBR,1,27)                                    		³
³Nombre del asegurado	C(27)	77 a 103	substring((rtrim(RA_PRINOME)+" "+rtrim(RA_SECNOME)),1,27)	³
³Salario diario integrado	N(6)	104 a 109	RCP_SALDII                                           	³
³Salario INFONAVIT	N(6)	110 a 115	RCP_SALIVC                                                  	³
³Tipo de trabajador	N(1)	116	RCP_TEIMSS                                                       		³
³Tipo de salario	N(1)	117	RCP_TSIMSS                                                          	³
³Reducción / Tipo de pago	N(1)	118	RCP_TJRNDA                                                 		³
³Fecha de movimiento	N(8)	119 a 126	RCP_DTMOV                                                 	³
³Filler	C(5)	127 a 131	SPACE(5)                                                               		³
³Tipo de movimiento	N(2)	132 a 133	"07"                                                       		³
³Guía	N(5)	134 a 138	RCO_NUMGAV                                                               	³
³Clave del trabajador	N(10)	139 a 148	RCP_MAT+SPACE(4)                                        	³
³Filler	C(1)	149	SPACE(1)                                                                     		³
³Clave Única de Registro de Población	C(18)	150 a 167	RA_CURP                                 	³
³Identificador de Formato	N(1)	168	"9"                                                        		³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cLin := Stuff(cLin,01,10,substr((cAliasTmp)->RCO_NREPAT,1,10))
cLin := Stuff(cLin,11,1,substr((cAliasTmp)->RCO_NREPAT,11,1))
cLin := Stuff(cLin,12,10,substr((cAliasTmp)->RA_RG,1,10))
cLin := Stuff(cLin,22,1,substr((cAliasTmp)->RA_RG,11,1))
cLin := Stuff(cLin,23,27,substr((cAliasTmp)->RA_PRISOBR,1,27))
cLin := Stuff(cLin,50,27,substr((cAliasTmp)->RA_SECSOBR,1,27))
cLin := Stuff(cLin,77,27,padr(substr((alltrim(RA_PRINOME)+" "+alltrim(RA_SECNOME)),1,27),27))
cLin := Stuff(cLin,104,6,FormatSal((cAliasTmp)->RCP_SALDII))
cLin := Stuff(cLin,110,6,FormatSal((cAliasTmp)->RCP_SALIVC))
cLin := Stuff(cLin,116,1,alltrim((cAliasTmp)->RCP_TEIMSS))
cLin := Stuff(cLin,117,1,alltrim((cAliasTmp)->RCP_TSIMSS))
cLin := Stuff(cLin,118,1,alltrim((cAliasTmp)->RCP_TJRNDA))
cLin := Stuff(cLin,119,8,ForFecha((cAliasTmp)->RCP_DTMOV))
cLin := Stuff(cLin,127,3,substr((cAliasTmp)->RA_UMEDFAM,1,3))
cLin := Stuff(cLin,130,2,space(2))
cLin := Stuff(cLin,132,2,"07")                                     
cLin := Stuff(cLin,134,5,strzero((cAliasTmp)->RCO_NUMGAV,5))  
//cLin := Stuff(cLin,134,5,SUBSTR(ALLTRIM(STR((cAliasTmp)->RCO_NUMGAV)),1,5))
cLin := Stuff(cLin,139,10,PADR((cAliasTmp)->RCP_MAT,10))
cLin := Stuff(cLin,149,1,space(1))
cLin := Stuff(cLin,150,18,(cAliasTmp)->RA_CURP)
cLin := Stuff(cLin,168,1,"9")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ArcBajas  ³ Autor ³ Gpe Santacruz         ³ Data ³03/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Formato de Archivo de Bajas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ArcBajas(cExp1,cExp2)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Linea a generar en el archivo                      ³±±
±±³          ³ cExp2.- Nombre del alias                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM830GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/       
Static Function ArcBajas(cLin,cAliasTmp)	

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Registro patronal	C(10)	1 a 10	substring(RCO_NREPAT,1,10)                                    		³
³Dígito verificador	N(1)	11	substring(RCO_NREPAT,11,1)                                        		³
³Número de seguridad social	N(10)	12 a 21	substring(RA_RG,1,10)                               		³
³Dígito verificador NSS	N(1)	22	substring(RA_RG,11,1)                                         		³
³Apellido paterno	C(27)	23 a 49	substring(RA_PRISOBR,1,27)                                    		³
³Apellido materno	C(27)	50 a 76	substring(RA_SECSOBR,1,27)                                    		³
³Nombre del asegurado	C(27)	77 a 103	substring((rtrim(RA_PRINOME)+" "+rtrim(RA_SECNOME)),1,27)	³
³Filler	N(15)	104 a 118	Space(15)                                                             		³
³Fecha de movimiento	N(8)	119 a 126	RCP_DTMOV                                                 	³
³Filler	C(5)	127 a 131	SPACE(5)                                                               		³
³Tipo de movimiento	N(2)	132 a 133	"02"                                                       		³
³Guía	N(5)	134 a 138	RCO_NUMGAV                                                               	³
³Clave del trabajador	N(10)	139 a 148	RCP_MAT+SPACE(4)                                        	³
³Causa de baja	N(1)	149	RCP_CBIMSS                                                            		³
³Filler	C(1)	150 a 167	Space(18)                                                              		³
³Identificador de Formato	N(1)	168	"9"                                                        		³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cLin := Stuff(cLin,01,10,substr((cAliasTmp)->RCO_NREPAT,1,10))
cLin := Stuff(cLin,11,1,substr((cAliasTmp)->RCO_NREPAT,11,1))
cLin := Stuff(cLin,12,10,substr((cAliasTmp)->RA_RG,1,10))
cLin := Stuff(cLin,22,1,substr((cAliasTmp)->RA_RG,11,1))
cLin := Stuff(cLin,23,27,substr((cAliasTmp)->RA_PRISOBR,1,27))
cLin := Stuff(cLin,50,27,substr((cAliasTmp)->RA_SECSOBR,1,27))
cLin := Stuff(cLin,77,27,padr(substr((alltrim(RA_PRINOME)+" "+alltrim(RA_SECNOME)),1,27),27))
cLin := Stuff(cLin,104,15,space(15))
cLin := Stuff(cLin,119,8,ForFecha((cAliasTmp)->RCP_DTMOV))
cLin := Stuff(cLin,127,5,space(5))
cLin := Stuff(cLin,132,2,"02")
//cLin := Stuff(cLin,134,5,SUBSTR(ALLTRIM(STR((cAliasTmp)->RCO_NUMGAV)),1,5))
cLin := Stuff(cLin,134,5,strzero((cAliasTmp)->RCO_NUMGAV,5))  
cLin := Stuff(cLin,139,10,PADR((cAliasTmp)->RCP_MAT,10))
cLin := Stuff(cLin,149,1,SUBSTR(ALLTRIM((cAliasTmp)->RCP_CBIMSS),1,1))
cLin := Stuff(cLin,150,18,space(18))
cLin := Stuff(cLin,168,1,"9")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPM830CIFRA ³ Autor ³ Gpe Santacruz       ³ Data ³03/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cifras de Cosntrol                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPM830CIFRA(nExp1,nExp2)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp1.- Numero totol de registro contenido en el archivo   ³±±
±±³          ³ nExp2.- Guia del Patron                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM830GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/       
Static Function Gpm830Cifra(nNum,nNumGav)  
      
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Asteriscos	C(13)	1 a 13	"*************"                                                                    		³
³Filler	C(43)	14 a 56	Space(43)                                                                             		³
³Total de reingresos	N(6)	57 a 62	Número  total de registro que contiene el archivo  (por registro patronal)	³
³Filler	C(71)	63 a 133	Space(71)                                                                            	³
³Guía	N(5)	134 a 138	RCO_NUMGAV                                                                             	³
³Filler	C(29)	139 a 167	Space(29)                                                                           	³
³Identificador de Formato	N(1)	168	"9"                                                                      	³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cLin := Stuff(cLin,1,13,replicate("*",13))  
cLin := Stuff(cLin,14,43,space(43))  
cLin := Stuff(cLin,57,6,strzero(nNum,6))  
cLin := Stuff(cLin,63,71,space(71))   
//cLin := Stuff(cLin,134,5,SUBSTR(ALLTRIM(STR(nNumGav)),1,5)   )
cLin := Stuff(cLin,134,5,strzero(nNUMGAV,5)   )
cLin := Stuff(cLin,139,29,space(29))  
cLin := Stuff(cLin,168,1,"9")  


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CreaArc   ³ Autor ³ Gpe Santacruz           Data ³03/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Crea el archivo                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CreaArc(cExp1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Registro patronal                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM830GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function CreaArc(cNomPat)

Local cNomArc:=alltrim(cArqTxt)

Do Case
   Case cTipAvi=='1'//Altas
	     cNomArc    +="Reingresos_"+alltrim(cNomPat)+"_"+ForFecha(ddatabase)+"_"+substr(strtran(time(),":",""),1,4)//
   Case cTipAvi=='2'//Bajas
	     cNomArc    +="Bajas_"+alltrim(cNomPat)+"_"+ForFecha(ddatabase)+"_"+substr(strtran(time(),":",""),1,4)//
   Case cTipAvi=='3'//Modificacion
	    cNomArc    +="Modificacion_"+alltrim(cNomPat)+"_"+ForFecha(ddatabase)+"_"+substr(strtran(time(),":",""),1,4)//
EndCase

nHdl    := fCreate(cNomArc)
//If Empty(cEOL)
//    cEOL := CHR(13)+CHR(10)
//Else
//    cEOL := Trim(cEOL)
//    cEOL := &cEOL
//EndIf
If nHdl == -1
    MsgAlert(STR0011+alltrim(cArqTxt)+STR0012,STR0006)//20-"El archivo  "," no puede ser creado! .","Atención!"
    Return
EndIf
aadd(aArcsGen,cNomArc)

Return        
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ForFecha  ³ Autor ³ Gpe Santacruz           Data ³04/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Formatea una Fecha a DDMMAAAA (string)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ForFecha(dExp1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dExp1.- Fecha a tranformar                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cExp1.-Fecha en formato DDMMAAAA                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM830GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function ForFecha(dFec)

cFec	:=	Dtoc(dFec)
cAnio	:=	Alltrim(str(year(dFec)))
cFec	:=	Substr(cFec,1,2)+substr(cFec,4,2)+cAnio

Return( cFec )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FormatSal ³ Autor ³ Gpe Santacruz           Data ³28/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Formatea los Salarios a 6 pisiciones                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FormatSal(nExp1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp1.- Salario a tranformar  9999.99999                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cExp1.-Salario formato 999999                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM830GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
static function FormatSal(nSalario)

Local cSalar:=transform(round(nSalario,2)  ,"9999.99")
Local cSaldia:=padl(alltrim(substr(csalar,1,4)),4,"0")+substr(csalar,6,2)

return cSaldia

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GPM830RPAT  ³ Autor ³Gpe Santacruz A.     ³ Data ³ 05/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Genera el arreglo con los Registros Patronales  para la     ³±±
±±³          ³ consulta en la pregunta                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lExp1.- .t. Valido .f. No valido                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³x1_valid   pregunta GPEM830                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Gpm830RPat()

Local aBim := {}

Local cTitulo:=  STR0013 //"Registro Patronal"

Local lRet

Local MvPar
Local MvParDef:=""

Local nCampo	:= TamSx3("RCO_CODIGO")[1] //4

MvPar := &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
mvRet := Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

RCO->(DbSetOrder(1))
If RCO->(DbSeek(xFilial("RCO")))       
   Do While !RCO->(Eof())
       aAdd(aBim, RCO->RCO_CODIGO+" "+alltrim(RCO->RCO_NOME))
       MvParDef += RCO->RCO_CODIGO
	   RCO->(DbSkip())
   EndDo
EndIf


If f_Opcoes(@MvPar,cTitulo,aBim,MvParDef,,,.f.,nCampo)  // Chama funcao f_Opcoes
                                          
	&MvRet := StrTran(mvpar,"*","")	//regresa resultado eliminando todos los asteriscos

EndIf

Return  lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GPM830DIR   ³ Autor ³Gpe Santacruz A.     ³ Data ³ 07/10/11 ³±±
±±³          ³GPM830RET   ³       ³                     ³      ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta especial MEXDIR, permite selecciona el directorio  ³±±
±±³          ³ unicamente, sin obligar a colocar un archivo               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MEXDIR  -SXB                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±            w
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Function GPM830DIR()

 Local aArea	   := GetArea()
 Local cTipo			 := ""
 Local cCpoVld  := ReadVar()

 &(cCpoVld) := cGetFile( cTipo , OemToAnsi("Selecione o Directorio"),,,.F.,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY)

 RestArea(aArea)
Return(.T.)

Function GPM830RET()
Return( &(ReadVar()) )