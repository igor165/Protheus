#INCLUDE "PROTHEUS.CH"
#INCLUDE "SCOPECNT.CH"
#INCLUDE "GPEXFUNPAR.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |GPEXFUNPARºAutor  ³Laura Medina        º Data ³ 15/01/2020  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Contiene funciones auxiliares en la localización de GPE     º±±
±±º          ³para PARAGUAY.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³Merge                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DiasFerParºAutor  ³Laura Medina        º Data ³ 15/01/2020  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Función para obtener los días derecho para Paraguay.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ DiasFerPar(cFilSRA,cMat,cPdSRF,dDateIni                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cFilSRA     = Filial del empleado                          º±±
±±º          ³ cMat        = Matrícula                         	  	    º±±
±±º          ³ cPdSrf      = Concepto de días Derecho                     º±±
±±º          ³ dDateIni    = Fecha de Admisión del empleado               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Gpea010Grv()                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DiasFerPar(cProces, dFcRecon, dAdmissa, cGpoVac)  
Local aArea	    := GetArea()
Local cCalend   := ""
Local dDateRec  := ""
Local nDiasVac  := 0
Local nAntigTot := ""
Local nAux01    := 0
Default cProces := ""
Default dFcRecon:= CTOD("//")
Default dAdmissa:= CTOD("//")
Default cGpoVac := ""

DbSelectArea( "RCJ" )
DbSetOrder( RetOrdem( "RCJ", "RCJ_FILIAL+RC_CODIGO" ) )
If  MsSeek( xFilial("RCJ") + cProces, .F. )
	If !Eof()
		cCalend := RCJ->RCJ_CALEND 
	EndIf
Endif

If  !Empty(dFcRecon) 
	dAntig := dFcRecon
Else 
	dAntig := dAdmissa                             
EndIf

If  cCalend == "1"
	nDiasAntig := Dias360(dAntig, dDatabase)
	nAntigTot  := nDiasAntig / 360 
Else
	nDiasAntig := dDatabase - dAntig + 1 
	nAntigTot  := nDiasAntig / 365
Endif  

nAux01 := FPOSTAB("S013", cGpoVac, "=", 4, nAntigTot, "<=",7)
If  nAux01 > 0 
	nDiasVac := FTABELA("S013",nAux01,8)
Endif


RestArea( aArea )

Return nDiasVac 


/*/{Protheus.doc} Dias360
Devuelve el salario y actualiza los campos necesarios. 
@author Laura Medina
@since 10/01/2020
@version 12.1.25  	
@return 	nSalario	Numerico	Salario (RA_SALARIO).  
/*/
Function fSal_PAR()
Local aArea		:= GetArea()
Local dAntig    := CTOD("//")
Local nFacCon   := 0 
Local cCalend   := ""
Local nAntigTot := 0
Local cCodFunc  := "" 
Local cCatFunc  := ""
Local cProces   := ""
Local nSalario  := 0
Local cPer      := ""
Local cNumPag   := ""
Local nAux01    := 0
Local nSalMes   := 0
Local nSalDia   := 0
Local lPer      := .T.
Local dFcRecon  := CTOD("//")
Local dFcAdmis  := CTOD("//")
Local nPorcen   := 0
Local dFcTemRCH := CTOD("//")
Local dFcIniRCH := CTOD("//")
Local dFcAniver := CTOD("//") 
Local dFcNasc   := CTOD("//")
Local nSalTemp  := 0

nSalario  := If( IsMemVar( "RA_SALARIO" ), GetMemVar( "RA_SALARIO" ) , SRA->RA_SALARIO)
cCodFunc  := If( IsMemVar( "RA_CODFUNC" ), GetMemVar( "RA_CODFUNC" ), SRA->RA_CODFUNC)
cCatFunc  := If( IsMemVar( "RA_CATFUNC" ), GetMemVar( "RA_CATFUNC" ), SRA->RA_CATFUNC)
cProces   := If( IsMemVar( "RA_PROCES" ),  GetMemVar( "RA_PROCES" ), SRA->RA_PROCES )
dFcRecon  := If( IsMemVar( "RA_DTREC" ),   GetMemVar( "RA_DTREC" ), SRA->RA_DTREC)
dFcAdmis  := If( IsMemVar( "RA_ADMISSA" ), GetMemVar( "RA_ADMISSA" ), SRA->RA_ADMISSA )
dFcNasc   := If( IsMemVar( "RA_NASC" ) ,   GetMemVar( "RA_NASC" ), SRA->RA_NASC ) 

If  Empty(dFcRecon)
	dAntig  := dFcAdmis
Else
	dAntig  := dFcRecon
Endif 

DbSelectArea( "RCJ" )
DbSetOrder( RetOrdem( "RCJ", "RCJ_FILIAL+RC_CODIGO" ) )
If  MsSeek( xFilial("RCJ") + cProces, .F. )
	If !Eof()
		cCalend := RCJ->RCJ_CALEND 
	EndIf
Endif

If  cCalend == "1"
	nDiasAntig := Dias360(dAntig, dDatabase)
	nAntigTot  := nDiasAntig / 360 
Else
	nDiasAntig := dDatabase - dAntig + 1 
	nAntigTot  := nDiasAntig / 365
Endif  

//Obtener Periodo y Numero de Pago 
cRetPer := Gp010RetCont("RCH_PER", NIL, cProces, @lPer )
If lPer
	cPer  := cRetPer
EndIf
cRetPer := Gp010RetCont("RCH_NUMPAG", NIL, cProces, @lPer )
If lPer
	cNumPag  := cRetPer
Endif
dFcTemRCH := Gp010RetCont("RCH_DTFIM", NIL, cProces, @lPer )
If lPer
	dFcIniRCH:= dFcTemRCH
Endif


//Determinar el % del salario mínimo con el que se compara

//1) Si Ley del primer empleo, Jornalero, Mensualista >= 100%
IF cCatFunc $ "1|D|M" 
   nPorcen  := 1
ENDIF

//2) Si Ley Empleo Juvenil (menor de edad, aprendiz)– Práctica Laboral >= 60%
dFcAniver :=  CTOD(STRZERO(DAY(dFcNasc),2) +"/" + STRZERO(MONTH(dFcNasc),2)+ "/" + ALLTRIM(STR(YEAR(dFcNasc)+18))) 
If  dFcIniRCH < dFcAniver .OR. cCatFunc $ "E|3"   //Menor de edad o E=Aprendiz o 3=Ley Empleo Juvenil – Práctica Laboral
	nPorcen := 0.60
Endif

//3) Si Ley de Empleo Juvenil – Capacitación Laboral y  Si Ley de Empleo Juvenil – Aprendizaje >= 70%
If  cCatFunc $ "2|5"
	nPorcen := 0.70
Endif

//4) Si Ley de Empleo Juvenil – Beca de Trabajo >= 25%
If  cCatFunc == "4" 
	nPorcen := 0.25
Endif

//5) Si Ley Empleo Juvenil - Primer Empleo Juvenil >= 65%
If  cCatFunc == "6" 
	nPorcen := 0.65
Endif

//6) Si Honorarios o Destajista >=0 %
If  cCatFunc $ "A|T"
	nPorcen := 0.00
Endif

DbSelectArea( "SRJ" )
DbSetOrder( RetOrdem( "SRJ", "SRJ_FILIAL+SRJ_FUNCAO" ) )
If  MsSeek( xFilial("SRJ") + cCodFunc )

	//Tomar de la tabla de Categorías (SRJ)
	If  SRJ->RJ_SALANT == "2" .AND. SRJ->RJ_SALTAR == "2" 
		nSalTemp := (SRJ->RJ_SALARIO * nPorcen)
		If  nSalario < 	nSalTemp				
			M->RA_SALARIO := nSalTemp
		Endif
		
    //Tomar de la tabla de Salario x Antiguedad (S003) 
    ElseIf  SRJ->RJ_SALANT == "1"   
    	nAux01 := FPOSTAB("S003", cCodFunc, "=", 4, nAntigTot, "<=",7)
    	If nAux01 > 0 
    		nSalTemp := FTABELA("S003",nAux01,8) * nPorcen
    		If  nSalario < nSalTemp	
    			M->RA_SALARIO := nSalTemp
    		Endif
    	Else
    		M->RA_SALARIO := 0
    	Endif
	      
    //Tomar de la tabla de Salario x Tareas (S070)
    ElseIf  SRJ->RJ_SALTAR == "1"    
    	IF  nSalario <> 0
		       M->RA_SALARIO := 0
		Endif
		M->RA_CATFUNC := "T"
	Endif 	
	M->RA_SALMES  := M->RA_SALARIO
	M->RA_SALDIA  := Iif(M->RA_SALARIO>0,Iif(SRJ->RJ_FACCON>0,M->RA_SALARIO / SRJ->RJ_FACCON,0) ,0)				
Endif

If !Inclui 
    M->RA_FECAUM  := CTOD("//")
    M->RA_TIPOALT := "004"
    M->RA_PERAUM  := cPer
    M->RA_PAGAUM  := cNumPag
    M->RA_DATAALT := Ddatabase 
Endif

nSalario := M->RA_SALARIO 

RestArea( aArea )
Return( nSalario )


/*/{Protheus.doc} Dias360
Devuelve la cantidad de días entre dos fechas basándose en un año de 360 días (12 meses de 30 días)
@author Laura Medina
@since 13/01/2020
@version 12.1.25
@param 		dFchIni		Date		Fecha de Antiguedad (inicial).
@param 		dFchFin		Date		Fecha actual (final).   	
@return 	nDias360	Numerico	Numero de días entre las 2 fechas, en un año de 360 días.  
/*/
Function Dias360(dFchIni, dFchFin)  //01/10/2007, 13/01/2020 
Local nDias360  := 0
Local nAnoFcIni := 0
Local nAnoFcFin := 0 
Local nAnoTotal := 0
Local nMesFcIni := 0
Local nMesFcFin := 0
Local nMesTotal := 0
Local nDayFcIni := 0 
Local nDayFcFin := 0 
Local nDayTotal := 0


Default dFchIni := CTOD("//")  
Default dFchFin := CTOD("//")   


//Año 
nAnoFcIni := YEAR(dFchIni)
nAnoFcFin := YEAR(dFchFin)

//Mes
nMesFcIni := MONTH(dFchIni)
nMesFcFin := MONTH(dFchFin)

//Día 
nDayFcIni := DAY(dFchIni)
nDayFcFin := DAY(dFchFin)

nDayFcIni := If(nDayFcIni>30, 30, Iif(nMesFcIni == 2 .And. (nDayFcIni == 28 .OR. nDayFcIni == 29), 30, nDayFcIni))
nDayFcFin := If(nDayFcFin>30, 30, Iif(nMesFcFin == 2 .And. (nDayFcFin == 28 .OR. nDayFcFin == 29), 30, nDayFcFin))

nDayTotal := nDayFcFin - nDayFcIni  //13 - 01 = 12

If  nDayTotal < 0  //Días en negativo 
	nDayFcFin += 30
	nDayTotal := nDayFcFin - nDayFcIni 
	nMesFcFin -= 1 
Endif

nMesTotal := nMesFcFin - nMesFcIni  //01 - 10 = -09

If  nMesTotal < 0  //Días en negativo 
	nMesFcFin += 12
	nMesTotal := nMesFcFin - nMesFcIni 
	nAnoFcFin -= 1 
Endif

nAnoTotal := nAnoFcFin - nAnoFcIni  //2020 - 2007 = 13

nDias360 := nDayTotal + ( nMesTotal * 30) + (nAnoTotal * 360) 


Return nDias360

/*/{Protheus.doc} Genera archivo PRX para la tabla RCM a partir de a rutina de Conceptos
Genera el archivo GPRCMPAR a partir de la  Tabla de Tipos de Ausentimos (RCM).
@author Erika Espinosa
@since 17/01/2020
@version 12.1.25
@archivo utilizado	RCM
/*/

Function GpexAusent()
Local aIniHdrRCM						// Cabecalho da tabela RCM com os campos
Local aRCMVirtual						// Campos virtuais de RCM
Local aLinesProg 	:= {}				// Array com as linhas dos programas
Local aLinesFunc 	:= {}			 	// Array com as linhas das funcoes dos itens RCM

Local cPath 		:= ""				// Caminho a gravar o arquivo
Local cArquivo 		:= ""			 	// Nome do arquivo a ser gerado
Local cProg								// string a ser enviado ao arquivo PRX
Local cTexto							// valor do campo do Header
//Local cTipoVer							// Tipo da Verba
Local cValueCampo						// montagem da string a ser enviado ao array
//Local cTipoNot		:= ""				// Tipo que nao cadastrado na tela do Box

Local nUsado							// Campos utilizados
Local nArq								// Situacao do arquivo
Local nX
Local nY
Local nPosMemo							// posicao do campo memo virtual
Local nLineMemo							// numero de linhas existentes no campo memo

//cTiposVer    := "1/2/3/4"
cArquivo 	:= ("GPRCM" + cPaisLoc + ".PRX")

aIniHdrRCM	:= RCM->( GdMontaHeader( @nUsado, @aRCMVirtual, NIL, NIL, NIL, .T.,.T.,,,,,,,.F. ) )
Begin Sequence
			  								       // MOSTRA DRIVES   MOSTRA HARD DISK RETORNA DIRETORIO
	cPath := cGetFile( "" ,OEMTOANSI(STR0005),0,,.F.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY) //"Selecione o Diretorio"
	If Empty(cPath)
		Break
	EndIf
	cArquivo := cPath + cArquivo

	If File(cArquivo)
		If !(MsgYesNo( OemToAnsi(STR0002),;	//"O Arquivo de la GPRCMPAR ja Existe! Deseja Sobrescrever?"
 		 			   OemToAnsi(STR0006) ;	//"Atenção!"
					))
			Break
		EndIf
	EndIf

	nArq := MSFCREATE(cArquivo, 0)
	IF Ferror() # 0 .And. nArq = -1
		cMsg := OemToAnsi(STR0003) + STR(Ferror(),3) //"Erro de Gravacao do Arquivo GPRCMPAR - Codigo DOS: "
		MsgInfo(cMsg, OemToAnsi(STR0006)) //"Atenção!"
		Return(.F.)
	Endif

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Cabecalho da funcao                                          ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	aAdd(aLinesProg, '#INCLUDE "PROTHEUS.CH"' + CRLF + CRLF)
	aAdd(aLinesProg, "/*/" + CRLF)
	aAdd(aLinesProg, "ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
	aAdd(aLinesProg, "³Fun??o    ³GPRCM" + cPaisLoc + "      " + "³Autor³ Gerado pelo sistema ³ Data ³" + Substr(DtoS(date()),7,2)+"/"+Substr(DtoS(date()),5,2)+"/"+Substr(DtoS(date()),1,4) + "³" + CRLF)
	aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesProg, "³Descri??o ³Verbas padroes                                              ³" + CRLF)
	aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesProg, "³Sintaxe   ³                                                            ³" + CRLF)
	aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesProg, "³Parametros³<Vide Parametros Formais>                                   ³" + CRLF)
	aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesProg, "³ Uso      ³Generico                                                    ³" + CRLF)
	aAdd(aLinesProg, "ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)
	aAdd(aLinesProg, "Function GPRCM" + cPaisLoc + "( aAusent, aRCMHeader )" + CRLF)
	aAdd(aLinesProg, "Local nPosAusent 	:= 0" + CRLF)
	aAdd(aLinesProg, 'Local lRet	  		:= .T.' + CRLF + CRLF)

	aAdd(aLinesProg, "DEFAULT aAusent 		:= {}" + CRLF)
	aAdd(aLinesProg, "DEFAULT aRCMHeader	:= {}" + CRLF + CRLF)

	aAdd(aLinesProg, "/*/" + CRLF)
	aAdd(aLinesProg, "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
	aAdd(aLinesProg, "³ Cabecalho de RCM                                           ³" + CRLF)
	aAdd(aLinesProg, "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)

	For nX := 1 To Len(aIniHdrRCM)
		cProg      := ""
		cTipoTexto := ""
		For nY := 1 To Len(aIniHdrRCM[nX])
			cTexto := If(ValType(aIniHdrRCM[nX,nY]) == "N", AllTrim(Str(aIniHdrRCM[nX,nY])),;
						   	If(ValType(aIniHdrRCM[nX,nY])=="L", Transform(aIniHdrRCM[nX, nY],"@!"),;
						   	   aIniHdrRCM[nX, nY]))
			cTexto := StrTran(cTexto, "'", '"')
			cProg += "'" + cTexto + "'"
			If nY < Len(aIniHdrRCM[nX])
				cProg += ","
			EndIf

		Next nY

		If !Empty(cProg)
			cTela := AllTrim(GetSx3Cache( aIniHdrRCM[nX][2], "X3_TELA" ))
			If !Empty(cTela) .or. !Empty(cTipoTexto)
				If !Empty(cTipoTexto)
					aAdd(aLinesProg, "IF( MV_MODFOL = '" + cTela + "', aAdd(aRCMHeader, " + '{ ' + cTipoTexto + ' })' + ", aAdd(aRCMHeader, " + '{ ' + cProg + ' })'+")" + CRLF )
				Else
					aAdd(aLinesProg, "IF( MV_MODFOL = '" + cTela + "', aAdd(aRCMHeader, " + '{ ' + cProg + ' })' + ", '')" + CRLF)
				EndIf
			Else
				aAdd(aLinesProg, "aAdd(aRCMHeader, " + '{ ' + cProg + ' })' + CRLF)
            Endif
		EndIf
	Next nX

	aAdd(aLinesProg, CRLF)

	aAdd(aLinesProg, "/*/" + CRLF)
	aAdd(aLinesProg, "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
	aAdd(aLinesProg, "³ Validar a Estrutura das Tabela RCM                           ³" + CRLF)
	aAdd(aLinesProg, "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)
	aAdd(aLinesProg, 'lRet := fNewOldSx3(aRCMHeader, NIL, "RCM", NIL, .F.)' + CRLF + CRLF)

	aAdd(aLinesProg, 'If lRet' + CRLF)

	// Gera a chamada para a funcao //
	cNameFunc :=  'ItensAusent (aAusent)'
	aAdd(aLinesProg, '		' + cNameFunc + CRLF)

	aAdd(aLinesFunc, "/*/" + CRLF)
	aAdd(aLinesFunc, "ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
	aAdd(aLinesFunc, "³Fun??o    ³"+cNameFunc + "³Autor³ Gerado pelo sistema ³ Data ³" + Substr(DtoS(date()),7,2)+"/"+Substr(DtoS(date()),5,2)+"/"+Substr(DtoS(date()),1,4) + "³" + CRLF)
	aAdd(aLinesFunc, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesFunc, "³Descri??o ³Tipos Ausent padroes da tabela RCM                                      ³" + CRLF)
	aAdd(aLinesFunc, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesFunc, "³Sintaxe   ³                                                                   ³" + CRLF)
	aAdd(aLinesFunc, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesFunc, "³Parametros³<Vide Parametros Formais>                                          ³" + CRLF)
	aAdd(aLinesFunc, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesFunc, "³ Uso      ³Generico                                                           ³" + CRLF)
	aAdd(aLinesFunc, "ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)
	aAdd(aLinesFunc, "Static Function " + cNameFunc + CRLF + CRLF)

	aAdd(aLinesFunc, "DEFAULT aAusent := {}" + CRLF + CRLF)

	//ITENS DAS TIPOS AUSENTISMOS
	RCM->(( RetOrdem( "RCM" , "RCM_FILIAL+RCM_TIPO" ) ) )
	RCM->(dbGoTop())
		While RCM->( !Eof() )

			cProg := "aAdd(aAusent, { "

			For nX := 1 To Len(aIniHdrRCM)
				cValueCampo := ""

				// CAMPO MEMO NORMAL
				If aIniHdrRCM[nX,8] == "M" .and. (aScan(aRCMVirtual, aIniHdrRCM[nX,2]) == 0)
					nLineMemo := MlCount(aIniHdrRCM[nX,2], 80)

					For nY := 1 To nLineMemo
						cValueCampo += AllTrim(MemoLine(aIniHdrRCM[nX,2], 80, nY))
						If nY < nLineMemo
							cValueCampo += ' '
						EndIf
					Next nY

				// CAMPO MEMO GRAVADO EM SYP - VIRTUAL //
				ElseIf aIniHdrRCM[nX,8] == "M" .and. (aScan(aRCMVirtual, aIniHdrRCM[nX,2]) > 0)
					If ((nPosMemo := Ascan(aRCMMemo, { |x|  Upper(x[2]) == aIniHdrRCM[nX,2] })) > 0)
						cValueCampo += MSMM(&(RCM->(aRCMMemo[nPosMemo,1])),80)
						cValueCampo := StrTran(cValueCampo, CRLF, "\13\10")
					EndIf
				ElseIF ( aScan(aRCMVirtual, aIniHdrRCM[nX,2]) > 0 )
					cValueCampo += AllToChar( CriaVar( aIniHdrRCM[nX,2] ) )
				ElseIf aIniHdrRCM[nX,8] == "N"
					cValueCampo += AllTrim(Str(RCM->(&(aIniHdrRCM[nX,2]))))
				ElseIf aIniHdrRCM[nX,8] == "D"
					cValueCampo += 'Ctod("' + DtoC(&(aIniHdrRCM[nX,2])) + '")'
				ElseIf aIniHdrRCM[nX,8] == "L"
					If &(aIniHdrRCM[nX,2])
						cValueCampo += ".T."
					Else
						cValueCampo += ".F."
					EndIf
				Else
					cValueCampo += AllTrim(RCM->(&(aIniHdrRCM[nX,2])))
				EndIf
				cValueCampo := StrTran(cValueCampo, "'", '"')

				If (aIniHdrRCM[nX,8] != "N") .and. (aIniHdrRCM[nX,8] != "D") .and. (aIniHdrRCM[nX,8] != "L")
					cValueCampo := "'" + cValueCampo
					cValueCampo += "'"
				EndIf

				cProg += cValueCampo
				If nX < Len(aIniHdrRCM)
					cProg += ","
				EndIf
			Next nX
			cProg += "} )"
			
			aAdd(aLinesFunc, cProg + CRLF)

			RCM->(dbSkip())

		Enddo
		aAdd(aLinesFunc, CRLF)
		aAdd(aLinesFunc, 'Return( NIL )')

	 	aAdd(aLinesProg, CRLF)
		aAdd(aLinesProg, 'EndIf' + CRLF + CRLF)
		aAdd(aLinesProg, 'Return( NIL )' + CRLF + CRLF)

	
			//TRANSFERIR AS LINHAS PARA DENTRO DO PROGRAMA
		    For nX := 1 To Len(aLinesProg)
			    Fwrite( nArq, aLinesProg[nX] )
			Next nX
		    For nX := 1 To Len(aLinesFunc)
			    Fwrite( nArq, aLinesFunc[nX] )
			Next nX

			MsgInfo( OemToAnsi(STR0004) + cArquivo + CRLF + OemToAnsi(STR0004)  ) // "O Programa " "para Cadastro de Tipos de Ausentismos Padroes foi Gerado com Sucesso"

		FClose(nArq)

End Sequence

Return(NIL)

/*/{Protheus.doc} Carga RCM
Carga los Registros de la Tabla de Tipos de Ausentimos RCM a partir de conceptos
@author Erika Espinosa
@since 17/01/2020
@version 12.1.25
@archivo utilizado	GPRCMPAR.PRX  
/*/

Function fCargRCM()
Local aArea		:= GetArea()
Local aAreaRCM	:= RCM->(GetArea()) 
Local aAux		:= {}
Local aRCMHeader:= {}
Local bFunc		:= {|| NIL}
Local cCampo	:= ""
Local cFilRCM	:= xFilial("RCM")
Local cAusent	:= ""
Local cFunRCM	:= ("GPRCM" + cPaisLoc)
Local cMsg 		:= ""
Local nFieldPos
Local nPosField
Local nPosAusent
Local nPosAcumul
Local nAux
Local nAuxs
Local nX
Local uCnt
Local cFiltro := 'RCM->RCM_FILIAL == "' + cFilRCM + '"' 
Local bFiltro := { || &(cFiltro) }

// Verifica a Existencia da Funcao do Pais Corrente
If FindFunction(cFunRCM)
	bFunc := __ExecMacro("{ ||  " + cFunRCM + "( @aAux , @aRCMHeader ) }")
	Eval(bFunc)
	DbSelectarea("RCM")
	DbSetOrder(1)
	RCM->(DbSetfilter( bFiltro, cFiltro ))
	RCM->(DbGoTop())
		
	//Verifica se Tabela de Tipos de Ausentismos esta Vazia, para a filial em uso -- Se estiver realizar a carga
    If RCM->(Eof())
		nPosAusent := GdFieldPos("RCM_TIPO" , aRCMHeader) 
		nAuxs := Len(aAux)
		DbSelectarea("RCM")
		DbSetOrder(1)
		For nAux := 1 To nAuxs
			cAusent := Padr(Upper(AllTrim(aAux[ nAux, nPosAusent ])),TamSX3("RCM_TIPO")[1])
			If RCM->(MsSeek(cFilRCM + cAusent))
				 RecLock("RCM",.F.,.T.)
			Else
				 RecLock("RCM",.T.,.T.)
			EndIf
			For nX := 1 To Len(aRCMHeader)
			   	cCampo := Upper(aRCMHeader[nX, 2])
				nFieldPos := RCM->(FieldPos(cCampo))
				If (nFieldPos > 0)
					If (aRCMHeader[nX, 2] == "RCM_FILIAL")
						uCnt := cFilRCM
					Else
				    	nPosField := GdFieldPos(cCampo , aRCMHeader)
				    	If (nPosField == 0)
				    		Loop
				    	EndIF
				    	uCnt := aAux[nAux , nPosField]
					Endif
					RCM->(FieldPut(nFieldPos , uCnt))
				EndIF
			Next nX
			RCM->(MsUnlock())

		Next nAux
	EndIf
EndIf

RestArea(aAreaRCM)
RestArea(aArea)

Return(NIL)

/*/{Protheus.doc} GerGpexRGX

Genera archivo PRX para la tabla RG5, RG6 y RG9 a partir de a rutina de Conceptos por proceso.
Genera el archivo GPRGX + cPaisLoc y GPRG9 + cPaisLoc a partir de la  Tabla de estandar de 
periodos y Criterios de Acumulación (RG5,RG6 y RG9).

Se mueve funcionalidad a GPEXFUMI debido que aplica para todo MI.

@author Erika Espinosa
@since 17/01/2020
@version 2.0
@archivo utilizado	RCM
/*/
Function GerGpexRGX(cPath, aListaArch)

	Local cFuncion	:= "GPEXRGXMI"

	IIf(FindFunction(cFuncion), GpexRGXMI(cPath, aListaArch), Help("", 1, "OBJECTRPO", , STR0015 + cFuncion + "().", 1, 0)) //"Rutina desactualizada, solicite paquete con actualizaciones: "

Return (Nil)

/*/{Protheus.doc} fCargRGX
Carga los Registros de las Tablas de Estandar de Periodos RG5 y RG6 a partir de conceptos por procesos

Se mueve funcionalidad a GPEXFUMI debido que aplica para todo MI.

@author Erika Espinosa
@since 17/01/2020
@version 2.0
@archivo utilizado	GPRGX + cPaisLoc + .PRX 
/*/
Function fCargRGX()

	Local cFuncion	:= "GPEXCRGRGX"

	IIf(FindFunction(cFuncion), GpexCrgRGX(), Help("", 1, "OBJECTRPO", , STR0015 + cFuncion + "().", 1, 0)) //"Rutina desactualizada, solicite paquete con actualizaciones: "

Return (Nil)

/*/{Protheus.doc} Carga RG9
Carga los Registros de la Tabla de Criterios de Acumulación RG9 a partir de conceptos por procesos.

Se mueve funcionalidad a GPEXFUMI debido que aplica para todo MI.

@author Erika Espinosa
@since 17/01/2020
@version 2.0
@archivo utilizado  GPRG9 + cPaisLoc + .PRX  
/*/
Function fCargRG9()

	Local cFuncion	:= "GPEXCRGRG9"

	IIf(FindFunction(cFuncion), GpexCrgRG9(), Help("", 1, "OBJECTRPO", , STR0015 + cFuncion + "().", 1, 0)) //"Rutina desactualizada, solicite paquete con actualizaciones: "

Return (Nil)

/*/{Protheus.doc} Inicializa estandar SRG
Inicializador estandar del campo RG_DFERVENT
@author Erika Espinosa
@since 10/03/2020
@version 12.1.25
@archivo utilizado 
/*/
Function fDferven()

Local aAreaSRF	:= SRF->(GetArea()) 
Local nAniosant := 0

DbSelectArea("SRF")
DbSetOrder(1)

If SRF->(MsSeek(xFilial("SRG") +  M->RG_MAT))

	While !SRF->(Eof()) .and. xFilial("SRG") +  M->RG_MAT == SRF->RF_FILIAL + SRF->RF_MAT

		If (RF_STATUS == "1")
			nAniosant := nAniosant + (RF_DFERVAT-RF_DFERANT)
		EndIf
	SRF->(dbSkip())
	EndDo
EndIf

RestArea(aAreaSRF)
Return(nAniosant)

/*/{Protheus.doc} Inicializa estandar SRG
Inicializador estandar del campo RG_DFERPRO
@author Erika Espinosa
@since 10/03/2020
@version 12.1.25
@archivo utilizado 
/*/
Function fDferpro()

Local aAreaSRF	:= SRF->(GetArea()) 
Local nAniospro := 0

DbSelectArea("SRF")
DbSetOrder(1)

If SRF->(MsSeek(xFilial("SRG") +  M->RG_MAT))

	While !SRF->(Eof()) .and. xFilial("SRG") +  M->RG_MAT == SRF->RF_FILIAL + SRF->RF_MAT

		If (RF_STATUS == "1")
			nAniospro := nAniospro + RF_DFERAAT
		EndIf
	SRF->(dbSkip())
	EndDo
EndIf

RestArea(aAreaSRF)
Return(nAniospro)


/*/{Protheus.doc} Inicializa estandar SRG
Inicializador estandar del campo RG_salmes
@author Erika Espinosa
@since 10/03/2020
@version 12.1.25
@archivo utilizado 
/*/
Function fSalmespar()

Local aAreaSRA	:= SRA->(GetArea()) 
Local nSalmes := 0

DbSelectArea("SRA")
DbSetOrder(1)

If SRA->(MsSeek(xFilial("SRG") +  M->RG_MAT))

	If (SRA->RA_CATFUNC $ "A|C|E|I|M|P")
		nSalmes := SRA->RA_SALARIO
	EndIf
	If (SRA->RA_CATFUNC $ "D|S")
		nSalmes := (SRA->RA_SALARIO * SRA->RA_HRSDIA) / SRA->RA_HRSMES
	EndIf
	If (SRA->RA_CATFUNC $ "G|H")
		nSalmes := SRA->RA_SALARIO * SRA->RA_HRSDIA
	EndIf
		
EndIf

RestArea(aAreaSRA)
Return(nSalmes)
		
		