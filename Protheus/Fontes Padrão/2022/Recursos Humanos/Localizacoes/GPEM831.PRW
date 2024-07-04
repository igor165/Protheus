#INCLUDE "Protheus.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "GPEM831.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEM831  ³ Autor ³ Guadalupe Santacruz A ³ Data ³ 12/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ GENERACION DE ARCHIVOS DE PARA SUA                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM831()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Silvia Tag  ³25/08/11³TDPI39³Ajuste na data do movimento de RHF_DTMINF ³±±
±±³            ³        ³      ³para RHF_DTMOV-conforme especificacao     ³±±
±±³gsantacruz  ³19/10/11³Corr  ³En tipo de dalario en archivo de datos    ³±±
±±³            ³        ³      ³afil y en el de empleados.                ³±±
±±³gsantacruz  ³21/10/11³Corr  ³Se cambio el filtro para movimientos, en  ³±±
±±³            ³        ³      ³los tipo 02                               ³±±
±±³gsantacruz  ³24/10/11³Corr  ³Se elimino el movimiento 09-Aport Volunt. ³±±
±±³            ³        ³      ³del archivo de movtos. verificado con SUA ³±±
±±³gsantacruz  ³22/11/11³Corr  ³Para el tipo de mov. inf, 2 se trunque    ³±±
±±³            ³        ³      ³el valor infonavit a 2 posiciones.        ³±±
±±³            ³        ³      ³Se agrego al extension TXT al los archivos³±±
±±³gsantacruz  ³11/01/12³Corr  ³En el archivo de Movtos no cosidere los   ³±±
±±³            ³        ³      ³tipo 01-Ingresos. Elimino 2da $ del nombre³±±
±±³            ³        ³      ³Se agregaron los numeros como caracteres  ³±±
±±³            ³        ³      ³validos al nombre del puesto.             ³±±
±±³gsantacruz  ³13/01/12³Corr  ³Si la clave de lugar viene vacia pone 00  ³±±
±±³R.Berti     ³13/09/12³TFTLRJ³Creacion del fuente GPEM831MEX.           ³±±
±±³M.Camargo   ³28/10/15³TTQUO9³Se elimina fuente GPEM831MEX quedando sola³±±
±±³            ³        ³      ³mente este fuente como el válido.         ³±±
±±³V.Flores    ³25/03/21³DMINA-³Se modifica la funcion FormValor() para el³±±
±±³            ³        ³ 11310³caso del campo cTipInf.                   ³±±
±±³  Marco A.  ³13/06/21³DMINA-³Se realizan multiples correcciones para el³±±
±±³            ³        ³ 12350³correcto funcionamiento de la rutina.     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function GPEM831()
Local aGetArea		:= GetArea()  
Local aSays			:= { }
Local aButtons		:= { }
Local nOpca
Local nx			:= 0                
Local nCont			:= 0 
Local nInc			:= 0 
Local nInf			:= 0 
Local nDat			:= 0 
Local nMov			:= 0 
Local nRhd			:= 0

Local cPerg			:= "GPEM831"

Private cArqTXT		:= ''
Private aArcsGen  	:= {}
Private aCodRpat	:= {}   
Private aError		:= {} //Contiene los errores para el LOG

Private NTipo		:= 0
Private nHdl  		:= 1

Private cCadastro 	:= OemtoAnsi(STR0001)//"Archivos para SUA"
Private cMes		:= ''
Private cAnio		:= ''
Private cLisPat		:= ''
Private cLisReg		:= ''
Private cEOL    	:= CHR(13)+CHR(10)

Private dFecIni		:= Ctod("  /  /  ") //Fecha de inicio del mes que se calcula
Private dFecFin		:= Ctod("  /  /  ") //Fecha de final del mes que se calcula

Private lRutAuto    := isBlind() //variable utilizada para rutina automática

dbSelectArea("RHC")  //Movimientos SUA
DbSetOrder(1)

If !lRutAuto
	AADD(aSays,OemToAnsi(STR0002) ) //"Esta rutina genera los Archivos para SUA : Incapacidades/Credito Infonavit/"
	AADD(aSays,OemToAnsi(STR0003))//"Datos Afiliatorios/Datos de Empleados/Movimientos SUA. "

	AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
	AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(TodoOK(cPerg),FechaBatch(),nOpca:=0) }} )
	AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	
	FormBatch( cCadastro, aSays, aButtons )
Else //Tratamiento para automatizados.
	nOpca := 1
	Pergunte(cPerg,.F.)
	TodoOK(cPerg)
EndIf

If nOpca == 1 //Genera los archivos
	If lRutAuto //Creación de archivos para automatizados.
		nInc:=GPM831INC()  //Incapacidades
		nInf:=GPM831CINF() //Crédito INFONAVIT
		nDat:=GPM831DAT()  //Datos Afiliatoriod
		nRhd:=GPM831RHD()  //Datos del Empleado
		nMov:=GPM831MOV()  //Moviminentos de SUA
	Else
		Processa({|| nInc:=GPM831INC() },OemToAnsi(STR0004))  //"Procesando Incapacidades..."
		Processa({|| nInf:=GPM831CINF()},OemToAnsi(STR0005))  //"Procesando Credito INFONAVIT..." 
		Processa({|| nDat:=GPM831DAT() },OemToAnsi(STR0006	))  //"Procesando Datos Afiliatorios..."	
		Processa({|| nRhd:=GPM831RHD() },OemToAnsi(STR0007))  //"Procesando Datos del Empleado..."	
		Processa({|| nMov:=GPM831MOV() },OemToAnsi(STR0008))  //"Procesando Movimientos de SUA..."
	EndIf	
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Envio de pantalla con la lista de todos los archivos generados (aArcsGen)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	cArchivos:=''

	For nx:= 1 to Len(aArcsGen)          
		cArchivos += Alltrim(aArcsGen[nx])+ cEOL    
	Next
		
	IF (nCont:=nInc+nInf+nDat+nMov+nRhd)==0
		If !lRutAuto
			MsgInfo(STR0009)//"Proceso Fianlizado! No encontro registros..."
		EndIf
	Else   
		If Len(aError) > 0
			If !lRutAuto
				msgAlert(STR0010)//"Hubo errores, verifique el Log"
			EndIf
		 	ImprimeLog()
	   	Endif   
		If !lRutAuto
			MsgInfo(STR0011 + cEOL + cArchivos)   //"Proceso Finalizado, Genero los archivos: "
		EndIf
	Endif
Endif

RestArea(aGetArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TodoOK    ºAutor  ³Microsiga           º Data ³  12/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacion de los datos antes de Ejecutar el proceso        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TodoOK(cPerg)

Local nCont		:=0                                     
Local nTamReg	:= TamSX3("RCO_CODIGO")[1]

Pergunte(cPerg,.F.)

cMes	:= StrZero(Val(Left(MV_PAR01,2)),2)
cAnio	:= Right(MV_PAR01,4)

cLisReg	:= Alltrim(MV_PAR02)
nTipo	:= MV_PAR03 
cArqTXT	:= MV_PAR04

If !lRutAuto
	If Empty(cMes + cAnio)
		MsgInfo(STR0049) //"El año mes es requerido!"
	Endif

	If Val(cMes) < 1 .Or. Val(cMes) > 12
		Msginfo(STR0050)//"El mes debe ser de 1 a 12!"
		Return .F.
	Endif	             

	If Val(cAnio) < 1900
		Msginfo(STR0012)  //"El año debe ser mayor a 1900!"
		Return .F.
	Endif	             

	If Empty(cLisReg)
		Msginfo(STR0013)//"Debe seleccionar al menos un registro patronal!"
		Return .F.
	Endif	             

	If Empty(cArqTXT)
		Msginfo(STR0014)//"Debe seleccionar la carpeta para los archivos a generar!"
		Return .F.
	Endif	 
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

dFecIni:=ctod("01/" + cmes + "/" + Substr(cAnio,3,2) + "/" )
dFecFin:=ctod(StrZero(f_UltDia(dFecIni),02) + "/" + cMes+"/" + Substr(cAnio,3,2))

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPM831INC ³ Autor ³ Gpe Santacruz         ³ Data ³23/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Generacion de los archivo de Incapacidades                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPM831INC                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM831                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GPM831INC

Local cQuery		:= ''
Local cAliasTmp		:= Criatrab(nil,.F.)
Local cTipRies		:= ''   
Local cRESINC		:= ' '  
Local nMax			:= 0
Local lErrorFile	:= .F.

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleccion de Información³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

cQuery := "SELECT RHE_FILIAL, RHE_MAT,RA_RG, RHE_CODRPA,RHE_NCERIN, RHE_DATAIN, RHE_DATAFI, RHE_DURACA , RHE_TIPORS, RHE_RESINC, RHE_CTRLIN, RCO_NREPAT, rhe_rama FROM "
cQuery += InitSqlName("RHE")+" RHE, "+ InitSqlName("SRA")+" SRA, "+ InitSqlName("RCO")+" RCO  "
cQuery += " WHERE  RHE_CODRPA IN ("+cLisPat+") and RHE_TIPOAU = 'I'"
cQuery += " AND RHE_ANOMES = '" + cAnio + cMes + "'  AND RHE_FILIAL= '" +xFilial("RHE")+"' AND RA_FILIAL= RHE_FILIAL "
cQuery += " AND	RHE_MAT=RA_MAT  AND RHE_CODRPA= RCO_CODIGO AND RCO_FILIAL= '"  + xFilial("RCO" , RHE->RHE_FILIAL) +"' "
cQuery += " AND RHE.D_E_L_E_T_ = ' '  AND SRA.D_E_L_E_T_ = ' ' AND RCO.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY RHE_FILIAL,RHE_CODRPA,RHE_MAT"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
TCSetField(cAliasTmp, "RHE_DATAIN", "D")
TCSetField(cAliasTmp, "RHE_DATAFI", "D")

Count TO nMax
ProcRegua(nMax) // Número de registros a procesar

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Genera archivo por cada registro patronal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

(cAliasTmp)->(dbGoTop())
nMax:=0

While !(cAliasTmp)->(Eof()) .And. !lErrorFile
    
	cFilTmp:=(cAliasTmp)->RHE_FILIAL
	cRegPat:=(cAliasTmp)->RHE_CODRPA   
	
	CreaArc("Incap",(cAliasTmp)->RCO_NREPAT ) //Abre el nuevo archivo
	nTamLin := 57

	Do While !(cAliasTmp)->(Eof()) .and. cFilTmp+cRegPat==(cAliasTmp)->RHE_FILIAL+(cAliasTmp)->RHE_CODRPA .And. !lErrorFile
		nMax++
	
		IncProc()
		If VldIncap(cAliasTmp,(cAliasTmp)->RHE_MAT)
			cLin    := Space(nTamLin)
			cLin := Stuff(cLin,01,11,alltrim((cAliasTmp)->RCO_NREPAT))
			cLin := Stuff(cLin,12,11,alltrim((cAliasTmp)->RA_RG))
			cLin := Stuff(cLin,23,1,'0')
			cLin := Stuff(cLin,24,8,FORFECHA((cAliasTmp)->RHE_DATAIN))
			cLin := Stuff(cLin,32,8,upper(alltrim((cAliasTmp)->RHE_NCERIN)))
			
			cLin := Stuff(cLin,40,3,strzero((cAliasTmp)->RHE_DURACA,3))
			cLin := Stuff(cLin,43,3,'000')
			cLin := Stuff(cLin,46,1,alltrim((cAliasTmp)->RHE_RAMA))
			
			cTipRies:='0'
			cRESINC:='0'
			If (cAliasTmp)->RHE_RAMA=='1'
				cRESINC:=(cAliasTmp)->RHE_RESINC
				Do Case
					Case RHE_TIPORS=='1'
						cTipRies:='2'
					Case RHE_TIPORS=='2'
						cTipRies:='1'
					Case RHE_TIPORS=='3'
						cTipRies:='3'
					Case empty(RHE_TIPORS)
						cTipRies:='0'
				EndCase
			Endif
			cLin := Stuff(cLin,47,1,cTipRies)
			cLin := Stuff(cLin,48,1,cRESINC)
			cLin := Stuff(cLin,49,1,(cAliasTmp)->RHE_CTRLIN)
			cLin := Stuff(cLin,50,8,FORFECHA((cAliasTmp)->RHE_DATAFI))
			cLin +=cEOL
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grabacion en el archivo texto. Comprueba errores durante la grabacion de la   ³
			//³ linea montada.                                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !MsgAlert(STR0010, STR0054)//10-"Ocurrió un error en la grabación del archivo. ¿Continúa?",11-"¡Atención!"
					lErrorFile := .T.
					Exit
				Endif
			Endif
		Endif
		(cAliasTmp)->(dbSkip())
	EndDo
    fClose(nHdl)
EndDo

(cAliasTmp)->(dbclosearea())

Return   nMax               

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPM831CINF³ Autor ³ Gpe Santacruz         ³ Data ³23/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Generacion de los archivo de INFONAVIT                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPM831CINF                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM831                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GPM831CINF()

Local cQuery		:= ''
Local cAliasTmp		:= CriaTrab(nil,.f.)
Local nMax			:= 0
Local lErrorFile	:= .F.

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleccion de Información³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
   
cQuery := "SELECT RA_RG, RA_VALINF, RA_TIPINF,RA_DTCINF, RA_MAT, RHF.*,RCO_NREPAT  FROM "
cQuery += InitSqlName("RHF")+" RHF, "+ InitSqlName("SRA")+" SRA , "+ InitSqlName("RCO")+" RCO  "
cQuery += " WHERE  RHF_CODRPA IN ("+ cLisPat +") "
cQuery += " AND RHF_ANOMES = '" + cAnio+cMes + "'  AND RHF_FILIAL= '" + xFILIAL("RHF")+"' AND RA_FILIAL= RHF_FILIAL "
cQuery += " AND	RHF_MAT=RA_MAT AND RHF_CODRPA= RCO_CODIGO AND RCO_FILIAL= '"  + xFilial("RCO" , RHF->RHF_FILIAL) +"' "
cQuery += " AND RHF.D_E_L_E_T_ = ' '  AND SRA.D_E_L_E_T_ = ' ' AND RCO.D_E_L_E_T_ = ' '""
cQuery += " ORDER BY RHF_FILIAL,RHF_CODRPA,RHF_MAT"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
TCSetField(cAliasTmp,"RHF_DTMOV ","D")
TCSetField(cAliasTmp,"RA_DTCINF","D")

Count TO nMax
ProcRegua(nMax) // Número de registros a procesar

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Genera archivo por cada registro patronal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

(cAliasTmp)->(dbgotop())
nMax:=0

While !(cAliasTmp)->(EOF()) .And. !lErrorFile           
    
	cFilTmp:=(cAliasTmp)->RHF_FILIAL
	cRegPat:=(cAliasTmp)->RHF_CODRPA   
	
	CreaArc("Cred",(cAliasTmp)->RCO_NREPAT ) //Abre el nuevo archivo
	nTamLin := 52

	Do While !(cAliasTmp)->(Eof()) .and. cFilTmp+cRegPat==(cAliasTmp)->RHF_FILIAL+(cAliasTmp)->RHF_CODRPA .And. !lErrorFile
		nMax++
	
		IncProc()
		If VldInfo(cAliasTmp,(cAliasTmp)->RA_MAT )
			cLin    := Space(nTamLin)
			cLin := Stuff(cLin,01,11,alltrim((cAliasTmp)->RCO_NREPAT))
			cLin := Stuff(cLin,12,11,alltrim((cAliasTmp)->RA_RG))
			cLin := Stuff(cLin,23,10,PADr(Substr((cAliasTmp)->RHF_NUMINF,1,10),10,"0"))
			
			cLin := Stuff(cLin,33,2,alltrim((cAliasTmp)->RHF_TPMINF))
			cLin := Stuff(cLin,35,8,FORFECHA((cAliasTmp)->RHF_DTMOV))
			cLin := Stuff(cLin,43,1,alltrim((cAliasTmp)->RHF_TIPINF))

			cLin := Stuff(cLin,44,8,FormValor((cAliasTmp)->RHF_TIPINF,(cAliasTmp)->RHF_VALINF) )

			If  (cAliasTmp)->RA_TIPINF=='1' .AND. (cAliasTmp)->RA_DTCINF > CTOD("31/01/1998")
				cLin := Stuff(cLin,52,1,"N")
			Else
				If (cAliasTmp)->RA_TIPINF=='1' .AND. (cAliasTmp)->RA_DTCINF <= CTOD("31/01/1998")
					cLin := Stuff(cLin,52,1,"S")
				Else
					cLin := Stuff(cLin,52,1,"N")
				Endif
			Endif
			
			cLin +=cEOL
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grabacion en el archivo texto. Comprueba errores durante la grabacion de la   ³
			//³ linea montada.                                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !MsgAlert(STR0010,STR0054)//10-"Ocurrió un error en la grabación del archivo. ¿Continúa?",11-"¡Atención!"
					lErrorFile := .T.
					Exit
				Endif
			Endif
		Endif
		(cAliasTmp)->(dbSkip())
	EndDo
    fClose(nHdl)
EndDo

(cAliasTmp)->(dbclosearea())

Return nMax               

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPM831DAT ³ Autor ³ Gpe Santacruz         ³ Data ³23/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Generacion de los archivo de Datos Afiliatorios SUA        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPM831DAT                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM831                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GPM831DAT()

Local cQuery		:= ''
Local cAliasTmp		:= CriaTrab(nil,.f.)
Local nMax			:= 0
Local lErrorFile	:= .F.

dbSelectArea("SX5")
dbSetOrder(1)

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleccion de Información³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

cQuery := "SELECT rhd_filial,RCO_NREPAT,RA_RG, RA_CEP, RA_NASC, RA_SEXO,RA_NATURAL, RA_UMEDFAM,RHD_CODRPA,RHD_DESCFU,RHD_TEIMSS,RHD_HRDIA,rhd_mat,rhd_tsimss  FROM "
cQuery += initsqlname("RHD")+" RHD, "+ initsqlname("SRA")+" SRA, "+ initsqlname("RCO")+" RCO  "
cQuery += " WHERE  RHD_CODRPA IN ("+CLISPAT+") "
cQuery += " AND RHD_ANOMES = '" + cAnIO+cMes + "'  AND RHD_FILIAL= '" +XFILIAL("RHD")+"' AND RA_FILIAL= RHD_FILIAL "
cQuery += " AND	RHD_MAT=RA_MAT  AND RHD_CODRPA= RCO_CODIGO AND RCO_FILIAL= '"  + xFilial("RCO" , RHD->RHD_FILIAL) +"' "
cQuery += " AND RHD.D_E_L_E_T_ = ' '  AND SRA.D_E_L_E_T_ = ' ' AND RCO.D_E_L_E_T_ = ' '"
If ntipo==2  //mes
	cQuery += " AND RA_ADMISSA BETWEEN '"+DTOS(dFecIni)+"' and '"+dtos(dFEcFin)+"' "
Endif

cQuery += " ORDER BY RHD_FILIAL,RHD_CODRPA,RHD_MAT"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
TCSetField(cAliasTmp,"RA_NASC","D")

COUNT TO nMax
ProcRegua(nMax) // Número de registros a procesar

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Genera archivo por cada registro patronal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

(cAliasTmp)->(dbgotop())
nMax:=0

While !(cAliasTmp)->(Eof()) .And. !lErrorFile           
    
	cFilTmp:=(cAliasTmp)->RHD_FILIAL
	cRegPat:=(cAliasTmp)->RHD_CODRPA   
	
	CreaArc("Afil",(cAliasTmp)->RCO_NREPAT ) //Abre el nuevo archivo
	nTamLin := 80

	Do While !(cAliasTmp)->(Eof()) .and. cFilTmp+cRegPat==(cAliasTmp)->RHD_FILIAL+(cAliasTmp)->RHD_CODRPA .And. !lErrorFile
		nMax++

	    IncProc()   
	    
	    If VldDatAfi(cAliasTmp,(cAliasTmp)->RHD_MAT )                                                
		
			cLin    := Space(nTamLin)
			cLin := Stuff(cLin,01,11,substr(alltrim((cAliasTmp)->RCO_NREPAT),1,11))//... ?
			cLin := Stuff(cLin,12,11,alltrim((cAliasTmp)->RA_RG))    //..?
			
			cLin := Stuff(cLin,23,5,STRZERO( val((cAliasTmp)->RA_CEP),5))
			
			cLin := Stuff(cLin,28,8,FORFECHA((cAliasTmp)->RA_NASC))
			cDesc:=SPACE(25)
			
			If SX5->(DBSEEK(XFILIAL("SX5")+'12'+(cAliasTmp)->RA_natural))
				cDesc  := padr(substr(upper(X5Descri()),1,25),25," ")
			EndIf
			
			cLin := Stuff(cLin,36,25,cDesc)
			cDato:='00'
			
			IF FPOSTAB("S017",(cAliasTmp)->RA_NATURAL,"=",4) >0
				cDato:=padr(substr(FTABELA("S017",FPOSTAB("S017",(cAliasTmp)->RA_NATURAL,"=",4),6),1,2),2," ")
			ENDIF
			
			cLin := Stuff(cLin,61,2,cDato)
			cLin := Stuff(cLin,63,3,STRZERO(VAL(SUBSTR((cAliasTmp)->RA_UMEDFAM,1,3)),3))
			
			cDescFunc:= LimpiaStr(	(cAliasTmp)->RHD_DESCFU)
			
			cLin := Stuff(cLin,66,12,PADr(upper(substr(cDescFunc,1,12)),12," "))
			//cLin := Stuff(cLin,66,12,PADr(upper(substr((cAliasTmp)->RHD_DESCFU,1,12)),12," "))			
			cLin := Stuff(cLin,78,1,(cAliasTmp)->RA_SEXO)
			cLin := Stuff(cLin,79,1, (cAliasTmp)->RHD_TSIMSS)
			cLin := Stuff(cLin,80,1,strzero((cAliasTmp)->RHD_HRDIA,1))
			cLin +=cEOL
	
		    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		    //³ Grabacion en el archivo texto. Comprueba errores durante la grabacion de la   ³
		    //³ linea montada.                                                                ³
		    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If lRutAuto
					lErrorFile := .T.
					Exit
				Else
					If !MsgAlert(STR0010,STR0054)//10-"Ocurrió un error en la grabación del archivo. ¿Continúa?",11-"¡Atención!"
						lErrorFile := .T.
						Exit
					Endif
				EndIf
			Endif
		Endif			     
	    (cAliasTmp)->(dbSkip())
    Enddo
    fClose(nHdl)
EndDo

(cAliasTmp)->(dbCloseArea())

Return nMax               

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPM831RHD ³ Autor ³ Gpe Santacruz         ³ Data ³24/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Generacion de los archivo de Datos del Empleado            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPM831RHD                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM831                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GPM831RHD()

Local cQuery		:= ''
Local cAliasTmp		:= CriaTrab(nil,.f.)
Local nMax			:= 0
Local lErrorFile	:= .F.

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleccion de Información³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

cQuery := "SELECT RHD_FILIAL,RHD_CODRPA , RHD_MAT,RA_FILIAL, RA_MAT,RA_RG, RA_CIC, RA_CURP, RA_PRISOBR, RA_SECSOBR, RA_PRINOME, "
cQuery += "	RA_SECNOME, RCO_NREPAT, RHD_TEIMSS, RHD_TJRNDA, RA_ADMISSA, RHD_SDI, RHD_NUMINF, RHD_DTCINF, RHD_TIPINF,RHD_VALINF  FROM "
cQuery += InitSqlName("RHD")+" RHD, "+ InitSqlName("SRA")+" SRA, "+ InitSqlName("RCO")+" RCO  "
cQuery += " WHERE  RHD_CODRPA IN ("+cLisPat+") "
cQuery += " AND RHD_ANOMES = '" + cAnio+cMes + "'  AND RHD_FILIAL= '" +XFILIAL("RHD")+"' AND RA_FILIAL= RHD_FILIAL "
cQuery += " AND	RHD_MAT=RA_MAT  AND RHD_CODRPA= RCO_CODIGO AND RCO_FILIAL= '"  + xFilial("RCO" , RHD->RHD_FILIAL) +"' "
cQuery += " AND RHD.D_E_L_E_T_ = ' '  AND SRA.D_E_L_E_T_ = ' ' AND RCO.D_E_L_E_T_ = ' '"

If nTipo == 2  //mes
	cQuery += " AND RA_ADMISSA BETWEEN '"+DTOS(dFecIni)+"' and '"+dtos(dFEcFin)+"' "
Endif

cQuery += " ORDER BY RHD_FILIAL,RHD_CODRPA,RHD_MAT"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
TCSetField(cAliasTmp,"RHD_DTCINF","D")
TCSetField(cAliasTmp,"RA_ADMISSA","D")

COUNT TO nMax
ProcRegua(nMax) // Número de registros a procesar

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Genera archivo por cada registro patronal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

(cAliasTmp)->(dbgotop())
nMax:=0

While !(cAliasTmp)->(EOF()) .And. !lErrorFile      
    
	cFilTmp:=(cAliasTmp)->RHD_FILIAL
	cRegPat:=(cAliasTmp)->RHD_CODRPA   
	
	CreaArc("Empl",(cAliasTmp)->RCO_NREPAT ) //Abre el nuevo archivo
	nTamLin := 164

	Do While !(cAliasTmp)->(Eof()) .and. cFilTmp+cRegPat==(cAliasTmp)->RHD_FILIAL+(cAliasTmp)->RHD_CODRPA .And. !lErrorFile
		nMax++
	    
	    IncProc()                                                                                    
   	    If VldEmpDat(cAliasTmp,(cAliasTmp)->RHD_MAT )                                                
		  		
			nSaldia:= (cAliasTmp)->RHD_SDI*100
			cLin    := Space(nTamLin)
			cLin := Stuff(cLin,01,11,alltrim((cAliasTmp)->RCO_NREPAT))
			cLin := Stuff(cLin,12,11,alltrim((cAliasTmp)->RA_RG))
			
			cLin := Stuff(cLin,23,13,padr(substr( (cAliasTmp)->RA_CIC,1,13),13," "))
			cLin := Stuff(cLin,36,18,padr(SUBSTR((cAliasTmp)->RA_CURP,1,18),18," "))                                                                                                                                     
			if !empty((cAliasTmp)->RA_SECNOME)
				cLin := Stuff(cLin,54,50,padr(UPPER(SUBSTR(ALLTRIM((cAliasTmp)->RA_PRISOBR)+"$"+ALLTRIM((cAliasTmp)->RA_SECSOBR)+"$"+ALLTRIM((cAliasTmp)->RA_PRINOME)+" "+ALLTRIM((cAliasTmp)->RA_SECNOME),1,50)),50," "))
			else
				cLin := Stuff(cLin,54,50,padr(UPPER(SUBSTR(ALLTRIM((cAliasTmp)->RA_PRISOBR)+"$"+ALLTRIM((cAliasTmp)->RA_SECSOBR)+"$"+ALLTRIM((cAliasTmp)->RA_PRINOME),1,50)),50," "))
			endif	
			
			cLin := Stuff(cLin,104,1,(cAliasTmp)->RHD_TEIMSS)
			cLin := Stuff(cLin,105,1,(cAliasTmp)->RHD_TJRNDA)
			cLin := Stuff(cLin,106,8,FORFECHA( (cAliasTmp)->RA_ADMISSA))
			cLin := Stuff(cLin,114,7,STRzero(nsaldia,7))
			
			cLin := Stuff(cLin,121,17,padr(Substr(alltrim((cAliasTmp)->RA_FILIAL)+alltrim((cAliasTmp)->RA_MAT),1,17),17," "))
			If !Empty((cAliasTmp)->RHD_NUMINF)
				cLin := Stuff(cLin,138,10,padr(substr((cAliasTmp)->RHD_NUMINF,1,10),10," "))
				cLin := Stuff(cLin,148,8,FORFECHA((cAliasTmp)->RHD_DTCINF))
				cLin := Stuff(cLin,156,1,(cAliasTmp)->RHD_TIPINF)
				cLin := Stuff(cLin,157,8,FormValor((cAliasTmp)->RHD_TIPINF,(cAliasTmp)->RHD_VALINF))
			Else
				cLin := Stuff(cLin,138,27,SPACE(27)	)
			Endif
			cLin +=cEOL
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grabacion en el archivo texto. Comprueba errores durante la grabacion de la   ³
			//³ linea montada.                                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If lRutAuto
					lErrorFile := .T.
					Exit
				Else
					If !MsgAlert(STR0010,STR0054)//10-"Ocurrió un error en la grabación del archivo. ¿Continúa?",11-"¡Atención!"
						lErrorFile := .T.
						Exit
					Endif
				EndIf
			Endif
	     Endif
	    (cAliasTmp)->(dbSkip())
    Enddo
    fClose(nHdl)
EndDo

(cAliasTmp)->(dbclosearea())

Return nMax               

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPM831MOV ³ Autor ³ Gpe Santacruz         ³ Data ³24/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Generacion de los archivo de Movimientos SUA               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPM831MOV                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM831                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GPM831MOV()

Local nSaldia		:= 0
Local nMax			:= 0
Local cQuery		:= ''
Local cAliasTmp		:= CriaTrab(nil,.f.)
Local cAliasRHE		:= CriaTrab(nil,.f.) 
Local ctMov			:= ''
Local lErrorFile	:= .F.

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleccion de Información³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
cQuery := "SELECT RHC_FILIAL, RHC_CODRPA, RHC_MAT,RA_RG, RCO_NREPAT, RHC_TPMOV, RHC_DTMOV, RHC_SALDII,RHC_CFPAT, RA_ADMISSA FROM "
cQuery += InitSqlName("RCO")+" RCO, "+ InitSqlName("SRA")+" SRA, "+InitSqlName("RHC")+" RHC "

cQuery += " WHERE  RHC_CODRPA IN ("+cLisPat+") AND RHC_TPMOV not in ('00','01')  "
cQuery += " AND RHC_ANOMES = '" + cAnio+cMes + "'  AND RHC_FILIAL= '" +XFILIAL("RHC")+"' AND RA_FILIAL= RHC_FILIAL "
cQuery += " AND	RHC_MAT=RA_MAT  AND RHC_CODRPA= RCO_CODIGO AND RCO_FILIAL= '"  + xFilial("RCO" , RHC->RHC_FILIAL) +"' "
cQuery += " AND RHC.D_E_L_E_T_ = ' '  AND SRA.D_E_L_E_T_ = ' ' AND RCO.D_E_L_E_T_ = ' '"

cQuery += " ORDER BY RHC_FILIAL,RHC_CODRPA,RHC_MAT"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
TCSetField(cAliasTmp,"RHC_DTMOV","D")

COUNT TO nMax
ProcRegua(nMax) // Número de registros a procesar

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Genera archivo por cada registro patronal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

(cAliasTmp)->(dbgotop())
nMax:=0

While !(cAliasTmp)->(EOF()) .And. !lErrorFile
    
	cFilTmp:=(cAliasTmp)->RHC_FILIAL
	cRegPat:=(cAliasTmp)->RHC_CODRPA   
	
	CreaArc("Mov",(cAliasTmp)->RCO_NREPAT ) //Abre el nuevo archivo
	nTamLin := 49

	Do While !(cAliasTmp)->(EOF()) .and. cFilTmp+cRegPat==(cAliasTmp)->RHC_FILIAL+(cAliasTmp)->RHC_CODRPA .And. !lErrorFile
		nMax++
		IF  (cAliasTmp)->RHC_CFPAT==0 .and. (cAliasTmp)->RHC_TPMOV<>'02'
		else
			IncProc()
			If VldMov1(cAliasTmp,(cAliasTmp)->RHC_MAT )
				nSaldia:=0
				IF (cAliasTmp)->RHC_TPMOV=='05' .OR. (cAliasTmp)->RHC_TPMOV=='06' .OR. (cAliasTmp)->RHC_TPMOV=='01'
					nSaldia:= (cAliasTmp)->RHC_SALDII *100  //SE MULTIPLICA POR 100, PARA QUE DE EL FORMATO REQUERIDO POR LAYOUT
				Endif
				cLin    := Space(nTamLin)
				
				cLin := Stuff(cLin,01,11,alltrim((cAliasTmp)->RCO_NREPAT))
				cLin := Stuff(cLin,12,11,alltrim((cAliasTmp)->RA_RG))
				
				ctMov:='  '
				If (cAliasTmp)->RHC_TPMOV=='02' .OR. (cAliasTmp)->RHC_TPMOV=='04'
					ctMov:="02"
				Endif
				If (cAliasTmp)->RHC_TPMOV=='05'  //Modificacion de salario 
					ctMov:="07"
				Endif
				If (cAliasTmp)->RHC_TPMOV=='06' .OR. (cAliasTmp)->RHC_TPMOV=='01'  //reingreso o alta
					ctMov:="08"
				Endif
				cLin := Stuff(cLin,23,2,ctMov)
				cLin := Stuff(cLin,25,8,FORFECHA((cAliasTmp)->RHC_DTMOV))
				cLin := Stuff(cLin,33,8,SPACE(8))
				cLin := Stuff(cLin,41,2,"00")
				cLin := Stuff(cLin,43,7,strzero(nSalDia,7))
				cLin +=cEOL
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grabacion en el archivo texto. Comprueba errores durante la grabacion de la   ³
				//³ linea montada.                                                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					If lRutAuto
						lErrorFile := .T.
						Exit
					Else
						If !MsgAlert(STR0010,STR0054)//10-"Ocurrió un error en la grabación del archivo. ¿Continúa?",11-"¡Atención!"
							lErrorFile := .T.
							Exit
						Endif
					EndIf
				Endif
			Endif
		Endif
		(cAliasTmp)->(dbSkip())
	Enddo
    
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄ¿
	//³Ausentismo³
	//ÀÄÄÄÄÄÄÄÄÄÄÙ
	*/

	lErrorFile := .F.

	cQuery := "SELECT RHE_FILIAL,RHE_CODRPA,RA_RG, RCO_NREPAT, RHE_TIPOAU, RHE_DATAIN, RHE_NCERIN, RHE_DURACA,rhe_mat, RA_ADMISSA FROM "
	cQuery += initsqlname("RCO")+" RCO, "+ initsqlname("SRA")+" SRA, "+initsqlname("RHE")+" RHE "
	cQuery += " WHERE  RHE_CODRPA ='"+cRegPat+"' AND RHE_FILIAL='"+cFilTmp+"' "
	cQuery += " AND RHE_ANOMES = '" + cAnIO+cMes + "'  AND  RA_FILIAL= RHE_FILIAL "
	cQuery += " AND	RHE_MAT=RA_MAT  AND RHE_CODRPA= RCO_CODIGO AND RCO_FILIAL= '"  + xFilial("RCO" , RHE->RHE_FILIAL) +"' "
	cQuery += " AND RHE.D_E_L_E_T_ = ' '  AND SRA.D_E_L_E_T_ = ' ' AND RCO.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY RHE_FILIAL,RHE_CODRPA,RHE_MAT"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),caliasRHE,.T.,.T.)
	TCSetField(caliasRHE,"RHE_DATAIN","D")
			
	Do While !(caliasRHE)->(EOF()) .and. cFilTmp+cRegPat==(caliasRHE)->RHE_FILIAL+(caliasRHE)->RHE_CODRPA .And. !lErrorFile
		If VldMov2(caliasRHE,(caliasRHE)->RHE_MAT )
			cLin    := Space(nTamLin)
			
			cLin := Stuff(cLin,01,11,alltrim((caliasRHE)->RCO_NREPAT))
			cLin := Stuff(cLin,12,11,alltrim((caliasRHE)->RA_RG))
			ctMov:='  '
			If (caliasRHE)->RHE_TIPOAU=='I'//INCAPACIDAD
				ctMov:="12"
			Endif
			If (caliasRHE)->RHE_TIPOAU=='F'//FALTA
				ctMov:="11"
			Endif
			cLin := Stuff(cLin,23,2,ctMov)
			cLin := Stuff(cLin,25,8,FORFECHA((caliasRHE)->RHE_DATAIN))
			
			If (caliasRHE)->RHE_TIPOAU=='I'//INCAPACIDAD
				cLin := Stuff(cLin,33,8,SUBSTR(ALLTRIM((caliasRHE)->RHE_NCERIN),1,8))
			Else
				cLin := Stuff(cLin,33,8,SPACE(8))
			Endif
			cLin := Stuff(cLin,41,2,STRZERO((caliasRHE)->RHE_DURACA,2))
			cLin := Stuff(cLin,43,7,"0000000")
			cLin +=cEOL
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grabacion en el archivo texto. Comprueba errores durante la grabacion de la   ³
			//³ linea montada.                                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If lRutAuto
					lErrorFile := .T.
					Exit
				Else
					If !MsgAlert(STR0010,STR0054)//10-"Ocurrió un error en la grabación del archivo. ¿Continúa?",11-"¡Atención!"
						lErrorFile := .T.
						Exit
					Endif
				EndIf
			Endif
		Endif
		(caliasRHE)->(dbSkip())
	Enddo
	(caliasRHE)->(dbclosearea())
	
    fClose(nHdl)
EndDo

(cAliasTmp)->(dbclosearea())

Return nMax               

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CreaArc   ³ Autor ³ Gpe Santacruz           Data ³23/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Crea el archivo                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CreaArc(cExp1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Registro patronal                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM831GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function CreaArc(cArc,cNomPat)

Local cPath		:= AllTrim(cArqTxt)
Local cNomArc	:= ""

Default cArc	:= ""
Default cNomPat	:= ""

cNomArc := cArc + AllTrim(cNomPat) + "_" + cMes + cAnio + ".TXT"

nHdl := fCreate(cPath + cNomArc)

If nHdl == -1
	If !lRutAuto
    	MsgAlert(STR0055 + AllTrim(cNomArc) + STR0056 + AllTrim(Str(FError())), STR0054)//"El archivo " -  ", no ha sido creado. Revise el error e intentenuevamente: " - "Atención!"
	EndIf
    Return
Endif

aAdd(aArcsGen, cNomArc)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LimpiaStr ³ Autor ³ Gpe Santacruz           Data ³24/11/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Limpia de caracteres raros la descripcion del puesto       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LimpiaStr(cExp1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Texto a validar                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lExp1.-Falso si encuentra errores                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM831GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static function LimpiaStr(cTexto)

Local j:=0
Local cNewName:=''
cTexto:=alltrim(upper(ctexto))
aChrValidos := {"A","B","C","D","E","F","G","H","I",;
		 		 "J","K","L","M","N","O","P","Q","R",;
		 		 "S","T","U","V","W","X","Y","Z"," ","1","2","3","4","5","6","7","8","9","0","&"}
		
For j:=1 TO Len(AllTrim(cTexto))
	cChrTexto	:=SubStr(cTexto,j,1)
	nPos 	:= Ascan(aChrValidos,cChrTexto)
	If nPos >0
	   cNewName+=substr(cTexto,j,1)	
	EndIf
Next j		
					 		 
Return cNewName

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
±±³ Uso      ³ GPM831GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  

STATIC FUNCTION ForFecha(dFec)

Local cFec:=dtoc(dFec)
Local cAni:=alltrim(str(year(dFec)))        

cFec:=substr(cFec,1,2)+substr(cFec,4,2)+cAni

Return cFec

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FormValor ³ Autor ³ Gpe Santacruz           Data ³04/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Formatea un valor numerico a EEEEDDDD)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FormValor(nExp1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp1.- Valor                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cExp1.-Valor formateado                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM831GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static function FormValor(cTipInf,nValInf)

Local nPunto	:=0
Local cValor	:=''
Local cEnt		:=''
Local cDec		:=''                         
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Si RHF_TPINF = 1 el VD = 00EEDD00³
//³Si RHF_TPINF = 2 el VD = 0EEEEDD0³
//³Si RHF_TPINF = 3 el VD = 0EEEDDDD³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/       

cValor:=alltrim(str(nValInf))
nPunto:=AT(".",cValor)         
If nPunto <> 0
	cEnt := Substr(cValor,1,nPunto-1)
	IF alltrim(cTipInf) $ '12' //trunca a 2 decimales                
		cDec := Substr(cValor,nPunto+1,2)
	else
		cDec := Substr(cValor,nPunto+1,len(cValor))	
	endif
Else                               
	cEnt := cValor                             
	cDec := "0000"
Endif	
                       
IF alltrim(cTipInf) $ '2'
	cValor:=PADL(cEnt,5,"0")+PADR(cDec,3,"0")
Else
	cValor:=PADL(cEnt,4,"0")+substr(PADR(cDec,4,"0"),1,4)
EndIf 
Return cValor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImprimeLog  ³ Autor ³GSANTACRUZ          ³ Data ³ 11/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ejecuta rutina para Visualizar/Imprimir log del proceso.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³      													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function ImprimeLog()

Local aReturn		:= {"xxxx", 1, "yyy", 2, 2, 1, "",1 }	//"Zebrado"###"Administra‡„o"
Local aTitLog		:= {}  
Local cTamanho		:= "M"
Local cTitulo		:= STR0015+cMes+"/"+cAnio //"LOG  Generación Archivos SUA "
Local aNewLog		:= {}
Local nTamLog		:= 0

aAdd(aError," ")
aAdd(aError," ")
aAdd(aError," ")

aNewLog	:= aClone(aError)
nTamLog	:= Len( aError)

aLog := {}

IF !Empty( aNewLog )
	aAdd( aTitLog , "E")
	aAdd( aLog , aClone( aNewLog ) )
EndIF
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
MsAguarde( { ||fMakeLog( aLog , , , .T. , FunName() , cTitulo , cTamanho , "P" , aReturn, .F. )},STR0016)//"Generando Log de Calculo de SUA..."

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VldIncap  ³ Autor ³ Gpe Santacruz           Data ³04/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida los datos de Incpacidades                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VldIncap(cExp1,cExp2)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Alias                                              ³±±
±±³          ³ cExp1.- Matricula                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lExp1.-Falso si encuentra errores                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM831GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
STATIC FUNCTION VldIncap(cAliasTmp,cMat) 

Local lRet:= .t.

Default cMat := ""

lRet:=VldNSS((cAliasTmp)->RA_RG,cMat,(cAliasTmp)->RCO_NREPAT,11)    //Valida registro y numero de imss

If Empty((cAliasTmp)->RHE_NCERIN	)
	aadd(aError,STR0017+cMat+STR0018)//"Empleado " ##" Sin Numero de Incapacidad! "
	lRet:= .f.
Else
	lRet:=VldFolIncap((cAliasTmp)->RHE_NCERIN,cMat)   //Dos caracteres en mayúsculas seguidos por seis números: XX999999,
Endif

If !(cAliasTmp)->RHE_RAMA $ "123"
	aadd(aError,STR0017+cMat+STR0019+(cAliasTmp)->RHE_RAMA)//"Empleado "##" La Rama debe ser 1,2 o 3! "
	lRet:= .f.
Endif

If Type((cAliasTmp)->RHE_RESINC) <> "N"
	aadd(aError, STR0051 + cMat + STR0052 + RTrim(FWX3Titulo("RHE_RESINC")) + STR0053) //"¡El empleado: " - ", tiene una incapacidad errónea, la consecuencia informada en el campo " - " (RHE_RESINC) debe tener valores entre  0 a 9!"
	lRet:= .f.
Endif

If Type((cAliasTmp)->RHE_CTRLIN)<>"N"
	aadd(aError,STR0017+cMat+STR0021+(cAliasTmp)->RHE_CTRLIN)	//"Empleado "##" El valor del Control de Incap.  debe ser de 0 a 9! "
	lRet:= .f.
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VldInfo   ³ Autor ³ Gpe Santacruz           Data ³04/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida los datos de INFONAVIT                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VldInfo(cExp1,cExp2)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Alias                                              ³±±
±±³          ³ cExp1.- Matricula                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lExp1.-Falso si encuentra errores                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM831GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
STATIC FUNCTION VldInfo(cAliasTmp,cMat)

Local lRet:= .t.

lRet:=VldNSS((cAliasTmp)->RA_RG,CMAT,(cAliasTmp)->RCO_NREPAT,11)    //Valida registro y numero de imss

If type((cAliasTmp)->RHF_TPMINF)<>"N"
	AADD(aError,STR0017+CMAT+STR0022+(cAliasTmp)->RHF_TPMINF)//"Empleado "##" El tipo de movto. Infonavit es incorrecto! "
Else
	If Val((cAliasTmp)->RHF_TPMINF)<15 .OR. VAL((cAliasTmp)->RHF_TPMINF)>20
		AADD(aError,STR0017+CMAT+STR0023+(cAliasTmp)->RHF_TPMINF)//"Empleado "##" El tipo de movto. Infonavit debe ir de 15 a 20! "
	Endif
Endif

If !alltrim((cAliasTmp)->RHF_TIPINF) $ "123"
	aadd(aError,STR0017+CMAT+STR0024+(cAliasTmp)->RHF_TIPINF) //"Empleado "##" Tipo de Descuento debe ser 1,2 o 3! "
	lRet:= .f.
Endif

If (cAliasTmp)->RHF_VALINF > 99999.9999
	aadd(aError,STR0017+CMAT+STR0025+alltrim(str((cAliasTmp)->RHF_VALINF)) )//"Empleado "##" con valor de descuento mayor a 99999.9999! "
	lRet:= .f.
Endif

Return lRet
           
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VLDDATAFI ³ Autor ³ Gpe Santacruz           Data ³04/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida los datos de Datos Afiliatorios                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VLDDATAFI(cExp1,cExp2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Alias                                              ³±±
±±³          ³ cExp1.- Matricula                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lExp1.-Falso si encuentra errores                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM831GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
STATIC FUNCTION VLDDATAFI(cAliasTmp,cMat)

Local lRet:= .t.

lRet := VldNSS((cAliasTmp)->RA_RG,cMat, Substr((cAliasTmp)->RCO_NREPAT,1,10),10)    //Valida registro y numero de imss

If Empty((cAliasTmp)->RA_CEP)
	Aadd(aError,STR0017 + cMat + STR0026) //"Empleado "##" Sin codigo postal! "
	lRet:= .F.
Endif

If Empty((cAliasTmp)->RA_SEXO)
	Aadd(aError,STR0017 + cMat + STR0027) //"Empleado "##"" Sin codigo de Sexo! "
	lRet:= .F.
Endif

If Empty((cAliasTmp)->RA_NASC)
	Aadd(aError,STR0017 + cMat + STR0028)//"Empleado "##" Sin fecha de nacimiento! "
	lRet:= .F.
Endif

If Empty((cAliasTmp)->RHD_TEIMSS)
	Aadd(aError,STR0017 + cMat + STR0030) //"Empleado "##" " No tiene Tipo de Salario! "
	lRet:= .F.
Endif
	  
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VldEmpdat ³ Autor ³ Gpe Santacruz           Data ³04/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida los datos de Datos del Empleado                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VldEmpdat(cExp1,cExp2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Alias                                              ³±±
±±³          ³ cExp1.- Matricula                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lExp1.-Falso si encuentra errores                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM831GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static function VldEmpdat(cAliasTmp,cMat)

Local lRet:= .t. 
Local cNombre:=UPPER( ALLTRIM((cAliasTmp)->RA_PRISOBR)+ALLTRIM((cAliasTmp)->RA_SECSOBR)+ALLTRIM((cAliasTmp)->RA_PRINOME)+ALLTRIM((cAliasTmp)->RA_SECNOME))

lRet:=VldNSS((cAliasTmp)->RA_RG,CMAT,(cAliasTmp)->RCO_NREPAT,11)    //Valida registro y numero de imss

If !ValString(cNombre)
	Aadd(aError,STR0017+CMAT+STR0031+cNombre) //"Empleado "##" El nombre del empleado tiene caracteres raros! "
	lRet:= .f.
Endif                   

If (cAliasTmp)->RHD_SDI*100>9999999
	Aadd(aError,STR0017+cMat+STR0032+transform((cAliasTmp)->RHD_SDI*100,"999,999,999.99")) //"Empleado "##" tiene un salario diario mayor a 99999.99! "
 	lRet:= .f.
Endif                    

If Empty((cAliasTmp)->RA_CIC)
	Aadd(aError,STR0017+cMat+STR0033) //"Empleado "##" no tiene RFC! "
 	lRet:= .f.
Endif                    

If Empty((cAliasTmp)->RA_CURP)  
	Aadd(aError,STR0017+cMat+STR0034) //"Empleado "##" no tiene CURP! "
	lRet:= .f.
Endif                    

If !((cAliasTmp)->RHD_TEIMSS $ "123")
 	Aadd(aError,STR0017+cMat+STR0035+(cAliasTmp)->RHD_TEIMSS ) //"Empleado "##" con tipo de trabajador inválido (1,2,3)! "
  	lRet:= .f.
Endif
                    
If !((cAliasTmp)->RHD_TJRNDA $ "0123456")
	Aadd(aError,STR0017+cMat+STR0036+(cAliasTmp)->RHD_TJRNDA ) //"Empleado "##" con tipo de jornada inválido (0..6)! "
  	lRet:= .f.
endif      

If !empty((cAliasTmp)->RHD_NUMINF ) .and. !((cAliasTmp)->RHD_TIPINF $ "123")
	Aadd(aError,STR0017+cMat+STR0037+(cAliasTmp)->RHD_TIPINF ) //"Empleado "##" con tipo de Descuento inválido (1,2,3)! "
 	lRet:= .f.
Endif                    

If !empty((cAliasTmp)->RHD_NUMINF ) .and. ((cAliasTmp)->RHD_VALINF > 99999.9999)
	Aadd(aError,STR0017+cMat+STR0038+alltrim(str((cAliasTmp)->RHD_VALINF) )) //"Empleado "##" con valor de descuento mayor a 99999.9999! "
	lRet:= .f.
Endif                               

If empty((cAliasTmp)->RHD_NUMINF ) 
	If !Empty((cAliasTmp)->RHD_TIPINF) .OR. !EMPTY (RHD_DTCINF ) .OR. RHD_VALINF > 0
		aadd(aError,STR0017+cMat+STR0039) //"Empleado "##" con valores  en datos de credito infonavit, pero sin numero de credito! "
	 	lRet:= .f.
	Endif
Endif                               

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VldMov1   ³ Autor ³ Gpe Santacruz           Data ³04/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida los datos de Movtos SUA (RHC)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VldMov1(cExp1,cExp2)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Alias                                              ³±±
±±³          ³ cExp1.- Matricula                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lExp1.-Falso si encuentra errores                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM831GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  

Static Function VldMov1 (cAliasTmp,cMat)

Local lRet:= .T.

lRet:=VldNSS((cAliasTmp)->RA_RG,cMat,(cAliasTmp)->RCO_NREPAT,11)    //Valida registro y numero de imss

If (cAliasTmp)->RHC_TPMOV == '05' .OR. (cAliasTmp)->RHC_TPMOV == '06'  
   If (cAliasTmp)->RHC_SALDII*100 > 9999999
        aadd(aError,STR0017 + cMat + STR0040 + Transform((cAliasTmp)->RHC_SALDII,"999,999,999.99")) //"Empleado "## " con salario diario mayor a 9999999 "
	 	lRet:= .F.
	Endif	
Endif	   

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VldMov2   ³ Autor ³ Gpe Santacruz           Data ³04/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida los datos de Movtos SUA (RHE)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VldMov1(cExp1,cExp2)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Alias                                              ³±±
±±³          ³ cExp1.- Matricula                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lExp1.-Falso si encuentra errores                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM831GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function VldMov2 (cAliasTmp,cMat)

Local lRet:= .t.

lRet:=VldNSS((cAliasTmp)->RA_RG,CMAT,(cAliasTmp)->RCO_NREPAT,11)    //Valida registro y numero de imss

If (cAliasTmp)->RHE_TIPOAU =='I'
	If  Empty((cAliasTmp)->RHE_NCERIN	)
		aadd(aError,STR0017+CMAT+STR0041) //"Empleado "##" Sin Numero de Incapacidad! "
		lRet:= .f.
	Else
		lRet:=VldFolIncap((cAliasTmp)->RHE_NCERIN,CMAT)   //Dos caracteres en mayúsculas seguidos por seis números: XX999999,
	Endif
Endif

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ValString ³ Autor ³ Gpe Santacruz           Data ³04/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida que el string solo tenga letras o espacios          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ValString(cExp1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Texto a validar                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lExp1.-Falso si encuentra errores                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM831GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static function ValString(cTexto)

Local lRet:= .t.               
Local j:=0

cTexto:=alltrim(ctexto)
aChrValidos := {"A","B","C","D","E","F","G","H","I",;
		 		 "J","K","L","M","N","O","P","Q","R",;
		 		 "S","T","U","V","W","X","Y","Z","Ñ"," "}
		
For j:=1 TO Len(AllTrim(cTexto))
	cChrTexto	:=SubStr(cTexto,j,1)
	nPos 	:= Ascan(aChrValidos,cChrTexto)
	If nPos = 0
		lRet := .F.
		exit
	EndIf
Next j		
					 		 
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VldNSS    ³ Autor ³ Gpe Santacruz           Data ³04/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida Numero se seg. social y Registro patronal           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VldNSS(cExp1,cExp2,cExp3)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- NSS                                                ³±±
±±³          ³ cExp2.- Matricula                                          ³±±
±±³          ³ cExp3.- Registro patronal                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lExp1.-Falso si encuentra errores                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM831GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VldNSS(cNum,cMat,cRepPat,nTam)

Local lRet:= .t.               

If len(alltrim(cRepPat))<>  nTam         
	aadd(aError,STR0017+CMAT+STR0043+ALLTRIM(STR(NTAM))+STR0047+cRepPat) //"Empleado "##" El Reg. Patronal debe ser de " ## " caracteres! "
	lRet:= .f.
Endif

If Empty(cNum)
	aadd(aError,STR0017+cMat+STR0044) //"Empleado "##" sin NSS! "
	lRet:= .f.
Else                     
	If Len(alltrim(cNum))<> 11
	   aadd(aError,STR0017+cMat+STR0045+cNum) //"Empleado "##" El NSS  no es de 11 digitos! "
	   lRet:= .f.
	Endif   
	If Type(cNum)<>"N"        //no debe tener signos OJO                                     
	   aadd(aError,STR0017+cMat+STR0046+cNum) //"Empleado "##" El NSS debe ser numerico! "
	   lRet:= .f.   
	Endif   
Endif
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VldFolIncap Autor ³ Gpe Santacruz           Data ³04/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida Numero de Folio de la Incapacidad                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VldFolIncap(cExp1,cExp2)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.- Folio de la incapacidad                            ³±±
±±³          ³ cExp2.- Matricula                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lExp1.-Falso si encuentra errores                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPM831GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function VldFolIncap(cFolIncap,cMat)

Local lRet:= .t.                     

cFolIncap:=upper(alltrim(cFolIncap))

If Type(substr(cFolIncap,1,1))=="N" .OR. type(substr(cFolIncap,2,1))=="N" .or. type(substr(cFolIncap,3,6))<>"N" .or.  len(cFolIncap)<>8
   aadd(aError,STR0017+cMat+STR0047+cFolIncap  ) //"Empleado "##" el Folio de Incapacidad es incorrecto! "
   lRet:= .f.
Endif   

Return lRet
