#INCLUDE "PROTHEUS.ch"       
#INCLUDE "GPER028CHI.ch" 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función   ³GPER028CHI³ Autor ³ alfredo.medrano     ³ Data ³ 02/10/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generación de Archivo TXT Previred (Chile)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER028CHI()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generar el archivo TXT Previred para la declaración de las ³±±
±±³          ³ cotizaciones mensuales provisionales.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador   ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glez ³10/04/15³  TSCNAE   ³Se cambia  intruccion MONTH() en el³±±
±±³              ³        ³           ³query de la funcion fMovPersonal() ³±±
±±³              ³        ³           ³y se agrega filtro para los tipos  ³±±
±±³              ³        ³           ³de movimientos 1, 4, 5 en el while ³±±
±±³              ³        ³           ³de impresion.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alfred.Medrano³07/05/15³  TSI104   ³valida claves 1, 7 y 8 utilizando  ³±±
±±³              ³        ³           ³la Fecha correspondiente y filtra  ³±±
±±³              ³        ³           ³por intervalo RCH_DTINI y RCH_DTFIM³±±
±±³              ³        ³           ³Retorna str de dos caracteres      ³±±
±±³              ³        ³           ³si no hay Movimientos envia '00'   ³±±
±±³              ³        ³           ³para ausencias reporta el campo    ³±±
±±³              ³        ³           ³RCM_TPIMSS Func. fMovPersonal()    ³±±
±±³Alfred.Medrano³25/06/15³  TSI104   ³inicializan Variables privadas de  ³±±
±±³              ³        ³           ³func. fApvi() y fApvc()            ³±±
±±³              ³        ³           ³se agrega Func.FInstit() para RUT y³±±
±±³              ³        ³           ³FCotPact() para  Cotización Pactada³±±
±±³Alfred.Medrano³12/08/15³  TTCYNA   ³actualizacion func fMovPersonal()  ³±±
±±³              ³        ³           ³se modifican condiciones para filtr³±±
±±³              ³        ³           ³de Fechas en las contrataciones    ³±±
±±³Alfred.Medrano³26/08/15³  TTCYNA   ³actualizacion func fMovPersonal()  ³±±
±±³              ³        ³           ³Se retorna fecha inicio admisión o ³±±
±±³              ³        ³           ³fecha contrato y fecha fin         ³±±
±±³              ³        ³           ³vencimiento para Contra Plazo Fijo ³±±
±±³              ³        ³           ³Ausentismos se excluye si el Tipo  ³±±
±±³              ³        ³           ³de Ausencia config. es Sin Mov.    ³±±
±±³              ³        ³           ³RCM_TPIMSS <> '00'                 ³±±
±±³Jonathan Glez ³27/11/15³PCREQ-7944 ³Localizacion GPE CHI p/v12         ³±±
±±³              ³        ³           ³-Se prueba que funcione de manera  ³±±
±±³              ³        ³           ³correcta en v12, solo se realizaron³±±
±±³              ³        ³           ³cambios en diccionario             ³±±
±±³Jonathan Glez ³02/02/16³PCREQ-7944 ³Generación de archivos txt para    ³±±
±±³              ³        ³           ³todas las filiales de la empresa en³±±
±±³              ³        ³           ³la que se está haciendo login.     ³±±
±±³Alf. Medrano  ³26/04/16³TUZHQ9     ³se modifica fMovPersonal.Se informa³±±
±±³              ³        ³           ³fecha ultimo día del mes calendario³±±
±±³              ³        ³           ³para el caso de las ausencias cuya ³±±
±±³              ³        ³           ³fecha sea mayor al mes vigente.    ³±±
±±³              ³        ³           ³Se agrena parametros cCon4, cCon5 a³±±
±±³              ³        ³           ³func. fPrevi                       ³±±
±±³              ³        ³           ³Se agrega func FormFech() retorna  ³±±
±±³              ³        ³           ³Fecha con formato especificado en  ³±±
±±³              ³        ³           ³tabla S017 func fMovFini y fMovFFin³±±
±±³Alf. Medrano  ³20/07/16³TVPGOM     ³Se quitan espacios al valor entidad³±±
±±³              ³        ³           ³RC_ENTIDAD en las funciones fApvc y³±±
±±³              ³        ³           ³fApvi. La entidad se rellena con   ³±±
±±³              ³        ³           ³ceros a la izquierda en la funcion ³±±
±±³              ³        ³           ³GPER028IMP()                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
Function GPER028CHI()
	Local aArea := getArea()
	Private cPerg   		:= "GPER028CHI"
	Private cProcesso	:= "" //proceso para filtro de consulta estabndar RCH01
	Private Semana		:= "" //Num pago para filtro de consulta estabndar RCH01
	Private cProcess	:= ""
	Private cRoteiro	:= "" 
	Private cPeriodo	:= ""
	Private cNumPago	:= "" 
	Private cAliasAux   := ""
	Private cPrefixo    := ""
	
	If FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica las perguntas selecionadas      ³
   //³ Proceso?                      MV_PAR01   ³
   //³ Tipo de Nomina?               MV_PAR02   ³
   //³ Periodo ?                     MV_PAR03   ³
   //³ No de Pago?                   MV_PAR04   ³
   //³ Matricula?                    MV_PAR05   ³
   //³ Archivo de Salida?            MV_PAR06   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If pergunte(cPerg,.T.)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtiene Registros a procesar                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			GetValDtos()	
			
			
		EndIf
	Endif
	
	RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GetValDtos³ Autor ³ Alfredo Medrano       ³ Data ³17/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida y Obtiene Datos a procesar                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GetValDtos()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPER028CHI                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetValDtos()
	Local aArea		:= getArea()
	Local cProce 		:= ""
	Local cTpNom 		:= ""
	Local cPerio 		:= ""
	Local cNoPag 		:= ""
	Local cMatri 		:= ""
	Local aPerTo		:= {} 
	Local cArchS 		:= ""
	Local cFilSRY		:= xFilial("SRY")  
	Local nTotalT		:= 0
	Local cFilBkp		:= cFilAnt
	Local nRec			:= 0
	Local nPos			:= 0
	Private nTotal		:= 0	
	Private aPerAbe		:= {}
	Private aPerFec 	:= {} 
	Private nHdl		:= 0
	Private aRoteiro	:= {} 
	Private cAliasBus 	:= criatrab( nil, .f. )
	
	cProce		:= mv_par01 //  Proceso?	
	cTpNom		:= mv_par02 //  Tipo de Nomina?
	cPerio		:= mv_par03 //  Periodo ? 
	cNoPag		:= mv_par04 //  No de Pago?   			   					
	cMatri		:= mv_par05 //  Matricula? 	
	cArchS		:= mv_par06 //  Archivo de Salida?		
	nHdl 		:= fCreate(mv_par06)
	cArchS := MV_PAR06	
	If nHdl == -1
   		MsgAlert(STR0001 + space(1) + AllTrim(cArchS) + space(1) + STR0002,STR0003) //"¡El archivo de nombre"###" no se puede crear! Verifique los parametros. "¡Atención!"
    	fClose(nHdl)//Cierra el archivo
    	Return .F.
	Endif
	
	// Recorrer SM0
	DbSelectArea("SM0")
	SM0->(dbSetOrder(1)) // M0_CODIGO + M0_CODFIL

	If SM0->( dbSeek(cEmpAnt))
		nRec := SM0->(RECNO())
		While !SM0->(Eof ()) .and. (SM0->M0_CODIGO == cEmpAnt)  
			/****/
			cFilAnt := SM0->M0_CODFIL
			/****/
			DbSelectArea("SRY")
			SRY->(DBSETORDER(1))   //SRY_FILIAL+SRY_CALCULO
			SRY->(DbSeek(xFilial("SRY"))) //Tipo de Nomina
			While SRY->(!Eof()) .AND. SRY->RY_FILIAL == cFilSRY 
				Aadd(aRoteiro,{SRY->RY_CALCULO, SRY->RY_TIPO,0}) 
				SRY->(dbSkip())	
			EndDo
			If (len(aRoteiro) <= 0) 
				MsgAlert(OemToAnsi(STR0004))//"No existen Conceptos para los parametros informados."  
				Return .F.
			EndIf
		
			fRetPerComp( 	IIF(!EMPTY(mv_par03),substr(MV_PAR03,5,6),"")	,;		// Obrigatorio - Mes para localizar as informacoes
								IIF(!EMPTY(mv_par03),substr(MV_PAR03,1,4),""),;	// Obrigatorio - Ano para localizar as informacoes
								xFilial("RCH")	,;		 // Opcional - Filial a Pesquisar
									  				,;		// Opcional - Filtro por Processo
						              			,;		// Opcional - Filtro por Roteiro
								@aPerAbe	  		,;		// Por Referencia - Array com os periodos Abertos
								@aPerFec			,;		// Por Referencia - Array com os periodos Fechados
								@aPerTo    		;		// Por Referencia - Array com os periodos Abertos e Fechados em Ordem Crescente
						 )
			
			If (len(aPerTo) <= 0)
				MsgInfo(OemToAnsi(STR0005))//"No existen periodos validos para el periodo informado."			
				fClose(nHdl)//Cierra el archivo
				return .F.
			Endif
					
			If (nPos:=aScan(aPerAbe, {|x| x[1] == cPerio .And. x[2] == cNoPag .And. x[7] == cProce .And. x[8] == cTpNom})) > 0 
				cAliasAux   := "SRC"
				cPrefixo    := "RC_"	
			Elseif (nPos:=aScan(aPerFec, {|x| x[1] == cPerio .And. x[2] == cNoPag .And. x[7] == cProce .And. x[8] == cTpNom})) > 0 
				cAliasAux   := "SRD"
				cPrefixo    := "RD_"	
			Endif 
											 
			//convierte parametros tipo Range a expresion sql
			//si separador por "-" agrega un BETWEEN,  si separado por ";" agrega un IN
			MakeSqlExpr(cPerg)
			
			cMatri	:= AllTrim(mv_par05) //  Matricula? Rangos		 
			 
			cQuery := " SELECT DISTINCT SRA.R_E_C_N_O_ AS SRARECNO, SRA.RA_FILIAL, SRA.RA_MAT FROM " + RetSqlName("SRA") + " SRA "
			cQuery += " INNER JOIN " + RetSqlName(cAliasAux) + " " + cAliasAux + " ON RA_MAT = "+cPrefixo+"MAT "
			cQuery += " WHERE RA_FILIAL = '" + XFILIAL('SRA') + "' "
			cQuery += " AND " + cPrefixo+"FILIAL = '" +  XFILIAL(cAliasAux,XFILIAL('SRA')) + "' "
			cQuery += " AND SRA.D_E_L_E_T_ = ' ' "  
			cQuery += " AND "+ cAliasAux+".D_E_L_E_T_= ' ' "
			If(!Empty(cProce), cQuery += " AND " +cPrefixo+"PROCES	='" + cProce + "' ","") //Proceso
			If	!Empty( cMatri ) //Matriculas 	
				cQuery += " AND " + cMatri 
			EndIf
			If(!Empty(cTpNom), cQuery += "	AND " +cPrefixo+"ROTEIR	= '" + cTpNom + "' ","") //Tipo de Nomina
			If(!Empty(cPerio), cQuery += "	AND " +cPrefixo+"PERIODO=	'" + cPerio + "' ","") //Periodo 
			If(!Empty(cNoPag), cQuery += "	AND " +cPrefixo+"SEMANA	= 	'" + cNoPag + "' ","") //No de Pago 
			cQuery += " ORDER BY RA_FILIAL, RA_MAT "
			cQuery := ChangeQuery(cQuery)   	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasBus,.T.,.T.)
			Count to nTotal
			
			If nTotal > 0
				Processa( {|lEnd| GPER028GNR(@lEnd)}, OemToAnsi(STR0008),OemToAnsi(STR0009), .T. ) //"Favor de Aguardar....." //"Generando el Archivo .txt"
			EndIf
					
			SRY->(dbCloseArea())
			RCB->(dbCloseArea())
			If nTotal > 0
				nTotalT+= nTotal
				RCJ->(dbCloseArea())
				RCH->(dbCloseArea())
				//
			EndIf
			( cAliasBus )->(dbCloseArea())  		

			SM0->(dbSkip())
		EndDo
		If nTotalT > 0
			Msginfo(OemToAnsi(STR0011) + space(1) +  AllTrim(cArchS) + space(1) +  OemToAnsi(STR0007) )//"Archivo" // "Generado con éxito."
		Else
			Msginfo(OemToAnsi(STR0012) )//"No existe información con esos parámetros"
		EndIf
		fClose(nHdl)//Cierra el archivo	
	EndIF
	SM0->(dbGoto(nRec))
	cFilAnt := cFilBkp
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GPER028GNR³ Autor ³ Alfredo Medrano       ³ Data ³06/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carga parametros, realiza el Filtro y crea el archivo TXT  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER028GNR(ExpL1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Valor de Retorno utilizado por la funcion PROCESSA ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 = Proceso continuo = .T.  Cancela el proceso= .F.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPER028CHI                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPER028GNR(lEnd)

	Local cProce 		:= ""
	Local cTpNom 		:= ""
	Local cPerio 		:= ""
	Local cNoPag 		:= ""
	Local cMatri 		:= ""
	Local cFormu		:= ""
	Local cNomAr 		:= "S017"
	Local cFormE		:= ""
	Local cFoEOK		:= ""
	Local cQuery 		:= ""
	Local cDfaul		:= ""
	Local cAnexo		:= ""
	Local cDescr		:= ""
	Local nSec			:= 0
	Local nLongi		:= 0
	Local nInici		:= 0 
	Local nPoint		:= 0
	Local nTdBn			:= .T.
	Local aPos   		:= {,,,,,,,} 
	Local cFilRCB		:= xFilial("RCB")
	Local cFilRCC		:= xFilial("RCC")
	Local nJ			:= 0
	Local aRegis		:= {} //Array que contendra las lineas de impresion en TXT
	private nLineaM		:= 0
	private nConsRCC	:= 0
	private aRegMadre	:= {}
	Private aVerbasF	:= {} //Para uso nova funcao em modelo2
	Private aRCCE		:= {} //Array que contendra los Campos a procesar de la tabla RCC consulta S017
	Private cEntidad	:= "" 
	Private nValAPVI	:= 0 
	Private cRG1APVI	:= ""
	Private cFPaAPVI	:= ""
	Private nValAPVC	:= 0 
	Private cRG1APVC	:= ""
	Private cFPaAPVC	:= ""
	Private cFechaIn	:= ""
	Private cFechaFn	:= ""
	Private cMatricu	:= ""
	Private cFCDflt		:= ""
	Private cRUTIns		:= ""
	Private cEntPag		:= ""
	Private cTpEnti		:= ""
	Private nTope_U_F	:= 0
	Private nTope_AFC	:= 0
	Private nTopeImpon  := 0
	Private lSuperaUF   := .F.
	Private lProcOrd    := .F. 
	Private lSeguroCes  := .F.
	
	cProce		:= mv_par01 //  Proceso?	
	cTpNom		:= mv_par02 //  Tipo de Nomina?
	cPerio		:= mv_par03 //  Periodo ? 
	cNoPag		:= mv_par04 //  No de Pago?   			   					
	cMatri		:= mv_par05 //  Matricula? 								 							 
	cRoteiro	:= mv_par02
	cPeriodo	:= mv_par03
    cNumPago 	:= cNoPag 
	//Carga los ARRAYS de Posiciones y tamaño.  
	nPoint := 1//Ponteiro contador para selecionar a posicao de inicio de cada campo corretamente. 
	DbSelectArea("RCB")     
	RCB->(DbSetOrder(1))  
	RCB->(DbSeek(cFilRCB + cNomAr)) 
	While RCB->(!Eof()) .AND. cFilRCB == RCB->RCB_FILIAL .AND. RCB->RCB_CODIGO == cNomAr
		cCpo:= Alltrim(RCB->RCB_CAMPOS)
		Do Case
			Case cCpo == "DESCRICAO"  
				aPos[1]:={nPoint, RCB->RCB_TAMAN}
			Case cCpo == "ANEXO"
				aPos[2]:={nPoint, RCB->RCB_TAMAN}
			Case cCpo == "INICIO"
				aPos[3]:={nPoint, RCB->RCB_TAMAN}
			Case cCpo == "LONGITUDE"
				aPos[4]:={nPoint, RCB->RCB_TAMAN}
			Case cCpo == "FORMULA"
				aPos[5]:={nPoint, RCB->RCB_TAMAN}
			Case cCpo == "DEFAUL"
				aPos[6]:={nPoint, RCB->RCB_TAMAN}
		EndCase
		nPoint += RCB->RCB_TAMAN
		RCB->(DbSkip())
	Enddo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guarda las posiciones inicio, Tamaño y contenido dentro de las variables.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("RCC")
	RCC->(DbSetOrder(1))      
	RCC->(DbSeek(xFilial()+cNomAr))
	Do While RCC->(!Eof()) .AND. cFilRCC == RCC->RCC_FILIAL .AND. RCC->RCC_CODIGO == cNomAr
		cDescr	:= Alltrim(SubStr(RCC->RCC_CONTEU, aPos[1,1], aPos[1,2]))
		cAnexo	:= Alltrim(SubStr(RCC->RCC_CONTEU, aPos[2,1], aPos[2,2]))
		nInici	:= Val(Alltrim(SubStr(RCC->RCC_CONTEU, apos[3,1], aPos[3,2])))
		nLongi	:= Val(Alltrim(SubStr(RCC->RCC_CONTEU, aPos[4,1], aPos[4,2])))
		cFormu	:= Alltrim(SubStr(RCC->RCC_CONTEU, aPos[5,1], aPos[5,2]))
		cDfaul	:= Alltrim(SubStr(RCC->RCC_CONTEU, aPos[6,1], aPos[6,2]))
		nSec	:= RCC->RCC_SEQUEN
		AAdd(aRCCE,{cDescr,cAnexo,nInici,nLongi,cFormu,cDfaul,nSec})
		RCC->(DbSkip())	
	EndDo   
	
	(cAliasBus)->(dbgotop())//primer registro de tabla
	
	If nTotal > 0
	// selecciona datos de la tabla SRY
		If  SRY->(DbSeek(xFilial("SRY")+cTpNom)) //Tipo de Nomina
			lProcOrd := Iif(SRY->RY_ORDINAR=="1",.T.,.F.)
		Endif
		// selecciona datos de la tabla RCJ
		DbSelectArea("RCJ")
		RCJ->(DBSETORDER(1))   //RCJ_FILIAL+RCJ_CODIGO
		RCJ->(DbSeek(xFilial("RCJ")+cProce)) //Proceso
		// selecciona datos de la tabla RCJ
		DbSelectArea("RCH")
		RCH->(DBSETORDER(1))   //RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR                                                                                                             
		RCH->(DbSeek(xFilial("RCH")+cProce+cPerio+cNoPag+cTpNom)) //Processo + Cod. Periodo + Numero Pago + Tipo Nomina       
	EndIf
	/* Verificar el Tope Imponible AFC --> FDESCRCC(cCodigo,cConteudo,nPos1,nPos2,nPos3,nPos4)
	   cCodigo = codigo da tabela 
	   cConteudo = chave a ser localizada
	   nPos1 = posicao inicial do chave
	   nPos2 = tamanho da chave
	   nPos3 = posicao inicial do retorno
	   nPos4 = tamanho do retorno
	*/  
	If  lProcOrd  //Solo aplica para la n¾mina ordinaria (UF por periodo)
		nTope_U_F := Val(fDescRCC("S002",(Substr(cPeriodo,1,4)+PadL( Val(Substr(cPeriodo,5,2)),2)),1,6,7,12))	
	Endif
	WHILE ( cAliasBus )->(!eof())
		SRA->(dbGoto( (cAliasBus)->SRARECNO ))
		aRegis 	:= {}	//Limpia el array del Registro por default por cada empleado.
		aRegMadre	:= {}	//Limpa el array del registro Madre por cada empleado.
		cProcess  	:= SRA->RA_PROCES
		cMatricu	:= SRA->RA_MAT
		IncProc(OemToAnsi(STR0010) + SRA->RA_MAT) // "Procesando Empleado: " 
		nLineaM 	:= 0
		nConsRCC	:= 0
		
		lSuperaUF   := .F.
		lSeguroCes  := .F.
		nTope_AFC   := 0
		nTopeImpon  := 0
		If  (SRA->RA_SEGCESA == "1" .And. Alltrim(SRA->RA_TIPOCON) $ "1|2") .And. lProcOrd    //Solo aplica empleado con seguro cesantia (RA_SEGCESA=1-Afecto) y tipo de contrato (RA_TIPOCON)= indefinido/Plazo fijo y nomina Ordinaria 
			nTope_AFC   := Val(fDescRCC("S005",Alltrim(SRA->RA_TIPOCON),1,1,34,6))  
			If  nTope_U_F == 0 .Or. nTope_AFC == 0
				MsgInfo(OemToAnsi(STR0013+ space(1) +SRA->RA_FILIAL + space(1) +"-"+ space(1) +SRA->RA_MAT))//"No se tiene configurado un Tope Imponible AFC para el periodo en proceso. Verifique la tabla S002 e S005!"
			Else
				lSeguroCes := .T. 
				nTopeImpon := nTope_U_F*nTope_AFC
			Endif
		Endif
		//obtiene los conceptos en base a la Matricula, Proceso, Tipo Nomina, Periodo y Numero Pago
		aVerbasF	:= RetVerbasFunc(SRA->RA_FILIAL	,; 	// Filial do funcionario corrente
									SRA->RA_MAT 	,;	// Matricula do funcionario corrente
									NIL			 	,; 	// Centro Costos
									cTpNom	  		,; 	// Retorna todos os Roteiro 
									NIL			  	,; 	// Array com as verbas que deverão ser listadas. Se NIL retorna todas as verbas.
									aPerAbe		,; 	// Array com os Periodos e Numero de pagamento abertos
									aPerFec		)	// Array com os Periodos e Numero de pagamento fechados
		If Len(aVerbasF) == 0 
			(cAliasBus)->(DbSkip())  
			Loop             
		Endif 
	
		For nJ:=1 To Len(aRCCE)	//Lee el Array aRCCE  que alimentara el array de aRegis.
			nConsRCC	:= nJ 		//Guarda posicion de la instrucción obtenida de la consulta S017
			cFCDflt	:=	aRCCE[nJ][6] 	//Extrae el campo DEFAULT
			cFormE 	:= &(aRCCE[nJ][5])//Extrae la FORMULA y la ejecuta
			If ValType(cFormE) == "N" 
				cFoEOK := Str(cFormE)
			Else
				cFoEOK := cFormE
			EndIf
			If aRCCE[nJ,4] > 0 // si la LONGITUD es mayor a 0
				// Agrega informacion al vector, INICIO y prepara la información con la longitud que le corresponde 
				AAdd(aRegis,{aRCCE[nJ,3],PADR(cFoEOK,aRCCE[nJ,4])}) 
			Endif
		Next	
		//Si No Genero Movimientos, Apvi o Apvc imprime la línea estandar
		If nLineaM == 0
			aSort(aRegis,,,{|aReg1,aReg2| aReg1[1] < aReg2[1]})	//Ordena vetor.
			GPE801TXT(aRegis)		
		EndIf		
	 If lEnd 
		 Exit 
	 Endif							
	( cAliasBus )->(dbSkip())
	
	ENDDO
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fMovPersonal³ Autor ³ Alfredo Medrano       ³ Data ³06/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica si existen los movimientos de personal asignados    ³±±
±±³          ³ en el mes de proceso                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fMovPersonal()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Clave  = Retorna la Clave según el Movimiento encontrado     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Consultas S017  - GPER028GNR                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fMovPersonal()
Local aArea		:=	GetArea()
Local uResult	
Local nX			:= 0 
Local nRetorno		:= 0
Local nTotalR		:= 0
Local nClave		:= 0
Local nLinea		:= 7
Local cQuery		:= ""
Local cCondi		:= ""
Local cClave		:= ""
Local cAliasRC		:= criatrab( nil, .f. )
Local nVal 			:= 0

cFechaIn	:= "" // inicializamos variable Privada
cFechaFn	:= "" // inicializamos variable Privada
//Devuelve la nClave si encuentra registro de lo contrario regresa nClave = 0
//Recorre los 8 casos en los que el empleado puede tener Movimientos obteniendo sus fechas inicio y Fin según corresponda
For nX:= 1 to nLinea
	nClave 	:= 0
	aRegProc	:= {}
	If nx == 1 .OR. nx == 2 .OR. nx == 3 .OR. nx == 4 .OR. nx == 5 .OR. nx == 7
		if nx== 3
			cSelect:= 	" SELECT DISTINCT RA_MAT, RA_FECCONT,RCH_MES, RA_ADMISSA " 	
		Elseif nx== 4 .OR. nx== 5  
			cSelect:=	" SELECT DISTINCT " +cPrefixo+"MAT, RCH_DTINI, RCH_DTFIM "
		Elseif nx== 7 
			cSelect:= 	" SELECT DISTINCT " +cPrefixo+"MAT, RA_DEMISSA, RA_SITFOLH "	
		Else
			cSelect:= 	" SELECT DISTINCT " +cPrefixo+"MAT, RA_ADMISSA, RCH_MES, RA_DTCONIN, RA_VCTOEXP " 
		EndIf

		cInner	:=	" INNER JOIN " + RetSqlName("RCH") + " RCH ON " + cPrefixo+"PROCES = RCH_PROCES AND " + cPrefixo+"ROTEIR = RCH_ROTEIR "
		cInner +=	" AND " + cPrefixo+"PERIODO=RCH_PER AND " + cPrefixo+"SEMANA = RCH_NUMPAG " 
		
		//1 = Contratación a Plazo Indefinido. Si la fecha de Ingreso está en el mes y el Tipo de Contrato es Indefinido
		IF nx==1 
			cCondi	:= 	" RA_TIPOCON='1' "
			cCondi +=	" AND RY_TPOPAGO ='01' "
			cCondi += " AND  RCH_DTINI <= RA_ADMISSA AND RCH_DTFIM >= RA_ADMISSA "
		ElseIf nx==2  
		//7 = Contratación a Plazo Fijo. Si la fecha de Ingreso está en el mes y el Tipo de Contrato es Indefinido
			cCondi := " RA_TIPOCON IN ('2','3') " 
			cCondi +=	" AND RY_TPOPAGO ='01'
			cCondi += " AND ((RCH_DTINI <= RA_ADMISSA AND RCH_DTFIM >= RA_ADMISSA) OR  (RCH_DTINI <= RA_DTCONIN  AND RCH_DTFIM >= RA_DTCONIN )) "
		ElseIf nx==3 
		//8 = Cambio de contratación Plazo Fijo a Plazo indefinido
			cCondi := " RCH_DTINI <= RA_FECCONT  AND RCH_DTFIM >= RA_FECCONT  "
		ElseIF nx==4
		//9 = Pago de remuneración de bonos, Reliquidaciones con fecha posteriores al finiquito.
			cCondi :=	" RY_TPOPAGO <>'01' " 
			cCondi += " AND RCH_DTPAGO > RA_DEMISSA "
		ElseIF nx== 5
		//12 = Reliquidación, Periodo, Bono
			cCondi :=	" RY_TPOPAGO <>'01' " 
		ElseIf nx== 7
		//2 - Retiro 
			cCondi := " RA_SITFOLH = 'D'  AND RA_DEMISSA <> '' AND (RCH_DTINI <= RA_DEMISSA AND RCH_DTFIM >= RA_DEMISSA)"  
		EndIf
		cFildel:= 	" AND RCH_FILIAL 	= '" + XFILIAL('RCH') + "' "
		cFildel+= 	" AND RCH.D_E_L_E_T_ 	= ' ' "		
		
	ElseIf nx==6  
		//03, 04, 06 Y 11  Ausentismo
		
		cSelect:= 	" SELECT " +cPrefixo+"MAT," +cPrefixo+"PD, R8_DATAINI, R8_DATAFIM,R8_INSTPAG, RCM_TIPO, RCM_TPIMSS,RA_OBRASOC, RCJ_MUTUAL " 
		cInner	:=	" INNER JOIN " + RetSqlName("SR8") + " SR8 ON " +cPrefixo+"NUMID = R8_NUMID AND " +cPrefixo+"MAT=R8_MAT "
		cInner	+=	" INNER JOIN " + RetSqlName("RCM") + " RCM ON " +cPrefixo+"PD = RCM_PD "
		cInner	+=	" INNER JOIN " + RetSqlName("RCJ") + " RCJ ON " +cPrefixo+"PROCES = RCJ_CODIGO "  
		cCondi := " R8_PD = " +cPrefixo+"PD "
 		cCondi +=	" AND RY_TPOPAGO ='01' "
 		cCondi += " AND RCM_TPIMSS <> '00' "
		cFildel:= 	" AND R8_FILIAL 	= '" + XFILIAL('SR8') + "' "
		cFildel+= 	" AND SR8.D_E_L_E_T_ 	= ' ' "		
	EndIf


	cQuery:= cSelect + " FROM " + RetSqlName(cAliasAux) +" "+ cAliasAux + " " 
	cQuery+= " 	INNER JOIN " + RetSqlName("SRA") + " SRA  ON " +cPrefixo+"MAT = RA_MAT 
	cQuery+= " 	INNER JOIN " + RetSqlName("SRY") + " SRY ON " +cPrefixo+"ROTEIR = RY_CALCULO "
	cQuery+= cInner
	cQuery+= " WHERE " + cCondi
	If(!Empty(cMatricu), cQuery += "	AND " +cPrefixo+"MAT = '" + cMatricu + "'","")    //Matricula
	If(!Empty(cProcess), cQuery += "	AND " +cPrefixo+"PROCES =	'" + cProcess + "' ","") //Proceso
	If(!Empty(cRoteiro), cQuery += "	AND " +cPrefixo+"ROTEIR =	'" + cRoteiro + "' ","") //Tipo de Nómina 									
	If(!Empty(cPeriodo), cQuery += "	AND " +cPrefixo+"PERIODO=	'" + cPeriodo + "' ","") //Periodo 
	If(!Empty(cNumPago), cQuery += "	AND " +cPrefixo+"SEMANA	= 	'" + cNumPago + "' ","") //No de Pago 
	cQuery += " 	AND RA_FILIAL 	= '" + XFILIAL('SRA') + "' "
	cQuery += " 	AND RY_FILIAL 	= '" + XFILIAL('SRY') + "' "			
	cQuery += " 	AND " +cPrefixo+"FILIAL 	= '" + XFILIAL(cAliasAux, XFILIAL('SRA')) + "' "	
	cQuery +=	cFildel
	cQuery += " 	AND " + cAliasAux+".D_E_L_E_T_= ' ' "	
	cQuery += " 	AND SRY.D_E_L_E_T_ 	= ' ' "
	cQuery += " 	AND SRA.D_E_L_E_T_ 	= ' ' "			
	cQuery := ChangeQuery(cQuery)   	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRC,.T.,.T.)
	
	If nx==1 .OR. nx==2 .OR. nx== 3 .OR. nx== 4 .OR. nx==5 .OR. nx==7
		If 	nx== 3
			TCSetField(cAliasRC,"RA_FECCONT","D",8,0) // Formato de fecha 
		ElseIf nx== 2
			TCSetField(cAliasRC,"RA_ADMISSA",	"D",8,0) // Formato de fecha 
			TCSetField(cAliasRC,"RA_VCTOEXP",	"D",8,0) // Formato de fecha
			TCSetField(cAliasRC,"RA_DTCONIN",	"D",8,0)// Formato de fecha
		ElseIf nx== 4 .OR. nx==5
			TCSetField(cAliasRC,"RCH_DTINI","D",8,0) // Formato de fecha 
			TCSetField(cAliasRC,"RCH_DTFIM","D",8,0) // Formato de fecha 
		Elseif nx== 7
			TCSetField(cAliasRC,"RA_DEMISSA","D",8,0) // Formato de fecha 
		Else 
			TCSetField(cAliasRC,"RA_ADMISSA","D",8,0) // Formato de fecha 
		EndIf
		
		Count to nTotalR
		(cAliasRC)->(dbgotop())//primer registro de tabla
	
		If nTotalR > 0	
			If nx == 1
				nClave := 1
			ElseIf nx == 2
			 	nClave := 7
			EndIf
			
			If 	nx== 3
				nClave := 8
				cFechaIn := DTOC(( cAliasRC )-> RA_FECCONT) //convierte la fecha a char
				//Imprime Renglón
				GPER028IMP('M', STRZERO(nClave, 2) )
			Elseif 	nx== 4 .OR. nx== 5
				cFechaIn := DTOC(( cAliasRC )-> RCH_DTINI) //convierte la fecha a char
				cFechaFn := DTOC(( cAliasRC )-> RCH_DTFIM) //convierte la fecha a char
				If(nx== 4 , nClave := 9, nClave := 12)
				//Imprime Renglón
				If(nVal == 0, GPER028IMP('M', STRZERO(nClave, 2) ), )
				nVal := 1
			ElseIf nx==2
			
				
				If empty( (cAliasRC )-> RA_DTCONIN)
					cFechaIn := DTOC(( cAliasRC )-> RA_ADMISSA) 
				Else
					cFechaIn := DTOC(( cAliasRC )-> RA_DTCONIN) 
				EndIf
				cFechaFn := DTOC(( cAliasRC )-> RA_VCTOEXP)
				GPER028IMP('M', STRZERO(nClave, 2) )
			Elseif nx== 7 
				nClave := 2
				cFechaFn := DTOC(( cAliasRC )-> RA_DEMISSA) //convierte la fecha a char
				GPER028IMP('M', STRZERO(nClave, 2) )
			Else
			
				cFechaIn := DTOC(( cAliasRC )-> RA_ADMISSA) //convierte la fecha a char
				//Imprime Renglón
				GPER028IMP('M', STRZERO(nClave, 2) )
			EndIf

		EndIf	
	EndIf
	
	If nx==6 
		TCSetField(cAliasRC,"R8_DATAINI","D",8,0) // Formato de fecha 
		TCSetField(cAliasRC,"R8_DATAFIM","D",8,0) // Formato de fecha 
		Count to nTotalR
		(cAliasRC)->(dbgotop())//imprimer registro de tabla
		
		WHILE ( cAliasRC )->(!eof())	
		
			cFechaIn	:= DTOC(( cAliasRC )-> R8_DATAINI) //convierte la fecha a char
			cFechaFn	:= DTOC(( cAliasRC )-> R8_DATAFIM) //convierte la fecha a char
			nClave		:=( cAliasRC )->RCM_TPIMSS
			
			If 	( cAliasRC )-> R8_DATAFIM > RCH->RCH_DTFIM
				cFechaFn := DTOC(RCH->RCH_DTFIM) //Asigna la Fecha Fin del Periodo en proceso
				
				Else
					If 	( cAliasRC )-> R8_DATAFIM < RCH->RCH_DTINI
						cFechaFn:= DTOC(RCH->RCH_DTINI)	
					EndIf
			EndIf	
			
			If 	( cAliasRC )-> R8_DATAINI < RCH->RCH_DTINI
				cFechaIn := DTOC(RCH->RCH_DTINI) //Asigna la Fecha Inicio del Periodo en proceso
			EndIf		

			If 	( cAliasRC )-> R8_INSTPAG $ "1|2"
				cEntPag	:= ( cAliasRC )-> RCJ_MUTUAL
				cTpEnti	:= "4"
			ElseIf ( cAliasRC )-> R8_INSTPAG $ "3|4"
				cEntPag	:= ( cAliasRC )-> RA_OBRASOC
				cTpEnti	:= "2"
			EndIf
			
			//Imprime Renglón	
			GPER028IMP('M', nClave )
			( cAliasRC )->(dbSkip())
		ENDDO
		
	EndIf

	
	( cAliasRC )->(dbCloseArea())                                
NEXT
// si no hay Movimientos envia '00' default  Sin Movimiento en el Mes
cClave := cFCDflt

RestArea(aArea)
Return cClave
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GPER028IMP³ Autor ³ Alfredo Medrano       ³ Data ³15/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carga parametros, realiza el Filtro y crea el archivo TXT  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER028IMP(ExpC1,ExpU2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 M  = Movimientos Personal                            ³±±
±±³          ³       VI = Apvi                                            ³±±
±±³          ³       VC = Apvc                                            ³±±
±±³          ³ ExpU2    = Valor de retorno: Entidad/Suma Horas/Suma Valor ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³fMovPersonal(), fApvi() y fApvc()                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPER028IMP(cTipo, uClave)

Local aRegProc	:= {}
Local cDefaul		:= ""
Local cFormE		:= ""
Local cFoEOK		:= ""
Local nM			:= 0
Local nY			:= 0
Local nBan		:= 0	
Default cTipo 	:= ""  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Almacena los Movimientos encontrados, para que genere el primero movimiento ³ 
	//³ en el registro Madre, y los demás movimientos con sus fechas de incio y fin ³ 
	//³ en los registros anexos.                                                    ³
	//³ ANEXO = 'S' llenar los campos con la misma información del registro Madre.  ³ 
	//³ ANEXO = 'M' se llenan con los datos del movimiento.                         ³
	//³ ANEXO = 'N', 'I', 'C' se dejan con el contenido de la columna de DEFAUL.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	If cTipo == 'M' //<--- Mov Personal
	//Inicializa el array que contendra el Registro Madre (por Empleado)
	// y las instrucciones que quedaran con los datos Default
		If nLineaM == 0
			cDefaul := "I|C"
			aRegMadre := {} 	
		Else
			cDefaul := "N|I|C|S"
		EndIf
	
	ElseIf cTipo == 'VI' //<--- APVI
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pudiera encontrar mas de un registro, Entidades diferentes.                 ³ 
	//³ Genere el primero Registro Madre con el Entidad para el empleado,           ³
	//³ y las demás entidades con su informacion en los registros anexos.           ³
	//³ ANEXO = 'S' llenar los campos con la misma información del registro Madre.  ³ 
	//³ ANEXO = 'I' se llenan con los datos de La entidad.                          ³
	//³ ANEXO = 'N', 'C' se dejan con el contenido de la columna de DEFAUL.         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	//Inicializa el array que contendra el Registro Madre (por Empleado)
	// y las instrucciones que quedaran con los datos Default
		If nLineaM == 0
			cDefaul := "M|C"
			aRegMadre := {} 	
		Else
			cDefaul := "M|N|C|S"
		EndIf
	
	ElseIf cTipo == 'VC' //<--- APVC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pudiera encontrar mas de un registro, Entidades diferentes.                 ³ 
	//³ Genere el primero Registro Madre con el Entidad para el empleado,           ³
	//³ y las demás entidades con su informacion en los registros anexos.           ³
	//³ ANEXO = 'S' llenar los campos con la misma información del registro Madre.  ³ 
	//³ ANEXO = 'C' se llenan con los datos de La entidad.                          ³
	//³ ANEXO = 'N', 'I' se dejan con el contenido de la columna de DEFAUL.         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	//Inicializa el array que contendra el Registro Madre (por Empleado)
	// y las instrucciones que quedaran con los datos Default
		If nLineaM == 0
			cDefaul := "M|I"
			aRegMadre := {} 	
		Else
			cDefaul := "M|N|I|S"
		EndIf
		
	EndIf
	 
	For nY := 1 To Len(aRCCE)	//Lee o Array aRCCE  que alimentara a array de aRegProc.
		nBan:= 1
		//Al informar un nuevo movimiento de personal o APVI o APVC, el campo No 14 (Tipo de Línea) debe ser '01'
		If nY == 14 
			If nLineaM == 0
				cFormE := &(aRCCE[nY][5])//Extrae la FORMULA y al ejecuta
			Else
				cFormE := '01' 
			EndIf
		Else
			If !(aRCCE[nY][2] $ cDefaul)
			//Si es igual a la pocision que se esta ejecutando solo agrega la clave
				If nY == nConsRCC
					cFormE := 	uClave
				Else
					cFormE := &(aRCCE[nY][5])//Extrae la FORMULA y al ejecuta
				EndIf
			Else
				If nLineaM  == 0 .OR. aRCCE[nY][2]!='S'
					cFormE :=aRCCE[nY][6] 	//Extrae el campo DEFAULT
				Else
					nBan := 0	
				EndIf			
			EndIf
		EndIf
		If ValType(cFormE) == "N" 			// verifica si es Numerico para convertirlo en String
			cFoEOK := Str(cFormE)
		Else
			cFoEOK := cFormE
		EndIf
		If aRCCE[nY,4] > 0 .And. nBan == 1// si la LONGITUD es mayor a 0
		
			If nY == 40 .or. nY == 45 // para la Entidad fApvi o fApvc se llena de ceros a la izquierda
				cFoEOK := STRZERO(VAL(cFoEOK),aRCCE[nY,4],0)
			EndIf 
		// Agrega informacion al Array 
		// Posicion Inicio, Longitud con la info, el Anexo y la Secuencia que le corresponde 
			AAdd(aRegProc,{aRCCE[nY,3],PADR(cFoEOK,aRCCE[nY,4]),aRCCE[nY][2],aRCCE[nY][7]}) 
		Endif
	Next
	
	If nLineaM == 0
		//Clona el Array con la linea Madre
		aRegMadre := AClone(aRegProc)
		nLineaM := 1
	Else
		//Agrega al array aRegProc las lineas con ANEXO 'S' para no volver a calcularlas
		For nM:= 1 to Len(aRegMadre)
			If aRegMadre[nM,3] == 'S'
				AAdd(aRegProc,{aRegMadre[nM,1],aRegMadre[nM,2],aRegMadre[nM,3],aRegMadre[nM,4]})
			EndIf 
		Next
				
	EndIf
	aSort(aRegProc,,,{|aReg1,aReg2| aReg1[4] < aReg2[4]})//Ordena Array por su posición "4" = SECUENCIA.
	GPE801TXT(aRegProc)	//Imprime Renglon	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fMovFini    ³ Autor ³ Alfredo Medrano       ³ Data ³10/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Devuelve la Fecha de Inicio del Movimiento                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fMovFini(ExpC1)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Formato de salida para Fecha                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cLocFchIn  = Fecha en caracteres                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Consultas S017  - GPER028GNR                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fMovFini(cTipo)
	Local cLocFchIn := ""
	default cTipo:= ""
	cLocFchIn := cFechaIn // si cTipo = ""  formato por default dd/mm/aaaa
	
	If !empty(cTipo) .And. !empty(cLocFchIn)
		cLocFchIn:= FormFech(cTipo,cFechaIn)
	EndIf
	
	cFechaIn 	:= ""
Return cLocFchIn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fMovFfin    ³ Autor ³ Alfredo Medrano       ³ Data ³10/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Devuelve la Fecha de Fin del Movimiento                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fMovFfin(ExpC1)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1= Formato de salida para Fecha                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cLocFchFn= Fecha en caracteres                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Consultas S017  - GPER028GNR                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static Function fMovFfin(cTipo)
	Local cLocFchFn := ""
	default cTipo:= ""
	cLocFchFn := cFechaFn

	If !empty(cTipo) .And. !empty(cLocFchFn)
		cLocFchFn:= FormFech(cTipo,cFechaFn)
	EndIf
	cFechaFn 	:= ""
Return cLocFchFn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fCargas     ³ Autor ³ Alfredo Medrano       ³ Data ³13/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cuenta el numero de dependientes en la tabla SRB             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCargas(ExpC1)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tipo de Carga                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nCarga = Total de Registros encontrados                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Consultas S017  - GPER028GNR                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static Function fCargas(cTpoCar)
	Local aArea		:=	GetArea()
	Local nCarga		:= 0
	Local cQuery		:= ""
	Local cAliasSRB	:= criatrab( nil, .f. )
	Default cTpoCar	:= ""
	
	// cuenta el número de registros en la tabla SRB
	cQuery := " SELECT COUNT(RB_MAT) AS TOTAL FROM " + RetSqlName("SRB") + " SRB "
	cQuery += " WHERE "
	cQuery += " RB_FILIAL 	= '" + XFILIAL('SRB', XFILIAL('SRA')) + "' "	
	cQuery += " AND SRB.D_E_L_E_T_ 	= ' ' "	
	If AllTrim(cTpoCar) == 'S' 
		cQuery += " AND RB_TPOCAR ='1' "
	ElseIf AllTrim(cTpoCar) == 'I' 
		cQuery += " AND RB_TPOCAR ='3' "
	ElseIf AllTrim(cTpoCar) == 'M' 
		cQuery += " AND RB_TPOCAR ='2' "
	EndIf
	If(!Empty(cMatricu), cQuery += "	AND RB_MAT = '" + cMatricu + "'","")    //Matricula
	cQuery := ChangeQuery(cQuery)   	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRB,.T.,.T.)
	
	nCarga := ( cAliasSRB )->TOTAL
	
	( cAliasSRB )->(dbCloseArea())
	
	RestArea(aArea)
	
Return nCarga 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fPrevi     ³ Autor ³ Alfredo Medrano       ³ Data ³06/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Busca los valores para imprimir en el docto de Texto         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fPrevi(ExpC1,ExpC2,ExpC3,ExpC4,ExpC5)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = 'E' ->  para obtener entidad.                        ³±±
±±³          ³  		  'H' y 'V' -> Obtener el Total de registros de los    ³±±
±±³          ³  		   Conceptos cCon1 y cCon2                             ³±±
±±³          ³ ExpC2 = Concepto a procesar                                  ³±±
±±³          ³ ExpC3 = Concepto a procesar (opcional)                       ³±±
±±³          ³ ExpC4 = Concepto a procesar (opcional)                       ³±±
±±³          ³ ExpC5 = Concepto a procesar (opcional)                       ³±±
±±³          ³ ExpC6 = Numero de columna                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ uResult  = Numerico -> total de Registros                    ³±±
±±³          ³         = Caracter -> RC_ENTIDAD                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Consultas S017 de las Tabla RCC procesadas por la Función    ³±±
±±³          ³ GPER028GNR                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fPrevi(cTipo,cCon1, cCon2, cCon3, cCon4, cCon5, nColum)

Local aArea		:=	GetArea()
Local uResult		 
Local nX			:= 0 
Local nRetorno	:= 0
Local nTotalR		:= 0
Local cConIn		:= ""
Local cAliasRC	:= criatrab( nil, .f. )
DEFAULT cTipo	:= NIL
DEFAULT cCon1	:= NIL
DEFAULT cCon2	:= NIL
DEFAULT nColum  := 0
uResult := 0
//Verifica que el array aVerbasF contiene movimientos y las variables cTipo, cCon1 no esten vacias.   
If (len(aVerbasF)>0) .AND. !empty(cCon1) .AND. !empty(cTipo) .AND. cTipo $ ("VHE")
	
	IF cTipo!= 'E'
	uResult := 0
	//V o H devolverá la suma de los registros de los dos conceptos cCon1 cCon2 cCon3 cCon4 cCon5 
		For nX := 1 to Len(aVerbasF)
			nRetorno	:= aScan(aRoteiro,{|x|x[1]==aVerbasF[nX,11]})
			If (aVerbasF[nX,3] == cCon1 .OR. aVerbasF[nX,3] == cCon2 .OR. aVerbasF[nX,3] == cCon3 .OR. aVerbasF[nX,3] == cCon4 .OR. aVerbasF[nX,3] == cCon5) .and. nRetorno > 0
				If cTipo == "V"
					uResult +=  aVerbasF[nX,7]
				ElseIf cTipo == "H"	
					uResult +=  aVerbasF[nX,6]
				Endif
		 	Endif
		Next nX
		If  lSeguroCes
			If  nColum == 100
				If  uResult > nTopeImpon   //Sino supera se debe seguir mostrando igual.
					//Si supera el Tope Imponible solo debe mostrar el concepto 661.
					uResult := 0
					lSuperaUF := .T.
					For nX := 1 to Len(aVerbasF)
						nRetorno	:= aScan(aRoteiro,{|x|x[1]==aVerbasF[nX,11]})
						If (aVerbasF[nX,3] == "661") .and. nRetorno > 0
							If  cTipo == "V"
								uResult +=  aVerbasF[nX,7]
							Endif
					 	Endif
					Next nX 
				Endif	    
			Elseif nColum == 101 .And. lSuperaUF 
				uResult := 0
			Elseif nColum == 102 .And. lSuperaUF 
				uResult := 0
				For nX := 1 to Len(aVerbasF)
					nRetorno	:= aScan(aRoteiro,{|x|x[1]==aVerbasF[nX,11]})
					If (aVerbasF[nX,3] == "663") .and. nRetorno > 0
						If  cTipo == "V"
							uResult +=  aVerbasF[nX,7]
						Endif
				 	Endif
				Next nX 
			Endif  
		Endif  
	Else
		cConIn := "'" + cCon1 + "'"
		If !Empty(cCon2)
			cConIn +=",'" + cCon2 + "'"
		EndIf
		If !Empty(cCon3)
			cConIn +=",'" + cCon3 + "'"
		EndIf
		If !Empty(cCon4)
			cConIn +=",'" + cCon4 + "'"
		EndIf
		If !Empty(cCon5)
			cConIn +=",'" + cCon5 + "'"
		EndIf
		

		//E  debe retornar el valor de SRC->RC_ENTIDAD
		cQuery := " SELECT " +cPrefixo+"ENTIDAD AS RC_ENTIDAD, " +cPrefixo+"PD "
		cQuery += " FROM " + RetSqlName(cAliasAux) +" "+ cAliasAux + " " 
		cQuery += " 	WHERE " 
		cQuery += " " +cPrefixo+"PD	 IN ( "+ cConIn +" )" //Conceptos
		If(!Empty(cMatricu), cQuery += "	AND " +cPrefixo+"MAT = '" + cMatricu + "'","")    //Matricula
		If(!Empty(cProcess), cQuery += "	AND " +cPrefixo+"PROCES =	'" + cProcess + "' ","") //Proceso
		If(!Empty(cRoteiro), cQuery += "	AND " +cPrefixo+"ROTEIR =	'" + cRoteiro + "' ","") //Tipo de Nómina 									
		If(!Empty(cPeriodo), cQuery += "	AND " +cPrefixo+"PERIODO=	'" + cPeriodo + "' ","") //Periodo 
		If(!Empty(cNumPago), cQuery += "	AND " +cPrefixo+"SEMANA	= 	'" + cNumPago + "' ","") //No de Pago 
		cQuery += " 	AND " +cPrefixo+"FILIAL 	= '" + XFILIAL(cAliasAux, XFILIAL('SRA')) + "' "	
		cQuery += " 	AND " +cAliasAux+".D_E_L_E_T_ 	= ' ' "	
		cQuery := ChangeQuery(cQuery)   
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRC,.T.,.T.)	
		Count to nTotalR
		(cAliasRC)->(dbgotop())//primer registro de tabla
		
		//En caso de encontrar mas de un renglón en la SRC para el Concepto, pero mietras el campo RC_ENTIDAD es el mismo, devuelve solo el campo.
		WHILE ( cAliasRC )->(!eof())
						
			If !Empty(( cAliasRC )-> RC_ENTIDAD)
				uResult :=  VAL(AllTrim(( cAliasRC )-> RC_ENTIDAD))
			EndIf
			
			( cAliasRC )->(dbSkip())
		ENDDO	
		
		( cAliasRC )->(dbCloseArea())
	EndIf
	                                    
EndIf
RestArea(aArea)
Return (uResult) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fApvi      ³ Autor ³ Alfredo Medrano       ³ Data ³09/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Busca los valores para imprimir en el docto de Texto         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fApvi(ExpC1,ExpC2,ExpC3)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = 'E' ->  para obtener entidad.                        ³±±
±±³          ³  		  'V' -> Obtener el Total de la misma Entidad       ³±±
±±³          ³  		   		  del renglón que esté generando            ³±±
±±³          ³  		  'F' -> retorna el valor de RG1->RG1_FORPAG        ³±±
±±³          ³ ExpC2 = Concepto a procesar                                  ³±±
±±³          ³ ExpC3 = Concepto a procesar (opcional)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ uResult  = Numerico -> total de Registros                    ³±±
±±³          ³         = Caracter -> RC_ENTIDAD                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Consultas S017 de las Tabla RCC procesadas por la Función    ³±±
±±³          ³ GPER028GNR                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fApvi(cTipo,cCon1, cCon2)

Local aArea		:=	GetArea()
Local uResult	  
Local nX			:= 0 
Local nTotalR		:= 0	
Local cConIn		:= ""
Local cAliasRC	:= criatrab( nil, .f. )
DEFAULT cTipo	:= NIL
DEFAULT cCon1	:= NIL
DEFAULT cCon1	:= NIL

uResult:=0
//Verifica que las variables cTipo y cCon1 no esten vacias.   
If   !empty(cTipo) .AND. cTipo $ ("EVF")                      
	
	If cTipo == 'E' .AND. !empty(cCon1)
		cConIn := "'" + cCon1 + "'"
		If !Empty(cCon2)
			cConIn +=",'" + cCon2 + "'"
		EndIf
		//E  debe retornar el valor de SRC->RC_ENTIDAD
		cQuery := " SELECT " +cPrefixo+"ENTIDAD AS RC_ENTIDAD, SUM("+cPrefixo+"VALOR) VALTOTAL, RG1_CONTRA, RG1_FORPAG "
		cQuery += " FROM " + RetSqlName(cAliasAux) +" "+ cAliasAux + " INNER JOIN " + RetSqlName("RG1") + " RG1 "
		cQuery += " ON "+ cPrefixo+"NUMID = RG1_NUMID AND "+ cPrefixo+"MAT=RG1_MAT "
		cQuery += " 	WHERE " 
		cQuery += " "+cPrefixo+"PD	 IN ( "+ cConIn +" )" //Conceptos
		If(!Empty(cMatricu), cQuery += "	AND " +cPrefixo+"MAT = '" + cMatricu + "'","")    //Matricula
		If(!Empty(cProcess), cQuery += "	AND " +cPrefixo+"PROCES =	'" + cProcess + "' ","") //Proceso
		If(!Empty(cRoteiro), cQuery += "	AND " +cPrefixo+"ROTEIR =	'" + cRoteiro + "' ","") //Tipo de Nómina 									
		If(!Empty(cPeriodo), cQuery += "	AND " +cPrefixo+"PERIODO=	'" + cPeriodo + "' ","") //Periodo 
		If(!Empty(cNumPago), cQuery += "	AND " +cPrefixo+"SEMANA	= 	'" + cNumPago + "' ","") //No de Pago 
		cQuery += " 	AND " +cPrefixo+"FILIAL 	= '" + XFILIAL(cAliasAux, XFILIAL('SRA')) + "' "	
		cQuery += " 	AND " +cPrefixo+"FILIAL 	= '" + XFILIAL('RG1', XFILIAL('SRA')) + "' "	
		cQuery += " 	AND " +cAliasAux+".D_E_L_E_T_ 	= ' ' "	
		cQuery += " 	AND RG1.D_E_L_E_T_ 	= ' ' "	
		CQuery += " GROUP BY "+cPrefixo+"ENTIDAD, RG1_CONTRA,RG1_FORPAG "
		cQuery := ChangeQuery(cQuery)   	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRC,.T.,.T.)
		Count to nTotalR
		(cAliasRC)->(dbgotop())//primer registro de tabla
		
		//En caso de encontrar mas de un renglón en la SRC para el Concepto, pero mietras el campo RC_ENTIDAD es el mismo, devuelve solo el campo.
		WHILE ( cAliasRC )->(!eof())
			
			nValAPVI:= ( cAliasRC )-> VALTOTAL 
			cRG1APVI:= ( cAliasRC )-> RG1_CONTRA
			cFPaAPVI:= ( cAliasRC )-> RG1_FORPAG
			//Envia La línea a impresión
			GPER028IMP('VI', ALLTRIM(( cAliasRC )-> RC_ENTIDAD) )
			
			( cAliasRC )->(dbSkip())
		ENDDO	
		
		( cAliasRC )->(dbCloseArea())
		
	ElseIf cTipo == 'V'
		uResult := nValAPVI
		nValAPVI := 0
	ElseIf cTipo == 'F'	
		uResult := Val(cFPaAPVI)
		cFPaAPVI := ""
	EndIf
EndIf
RestArea(aArea)
Return (uResult) 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FApviC     ³ Autor ³ Alfredo Medrano       ³ Data ³10/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna el valor de RG1->RG1_CONTRA para APVI                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FApviC()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ RG1->RG1_CONTRA  = Numero de Contrato                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Consultas S017  - GPER028GNR                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function fApviC()
	Local cCntRG := ""
	cCntRG := cRG1APVI
	cRG1APVI := ""
Return cCntRG
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fApvc      ³ Autor ³ Alfredo Medrano       ³ Data ³10/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Busca los valores para imprimir en el docto de Texto         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fApvc(ExpC1,ExpC2,ExpC3)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = 'E' ->  para obtener entidad.                        ³±±
±±³          ³  		  'V' -> Obtener el Total de la misma Entidad          ³±±
±±³          ³  		   		  del renglón que esté generando                ³±±
±±³          ³  		  'F' -> retorna el valor de RG1->RG1_FORPAG           ³±±
±±³          ³ ExpC2 = Concepto a procesar                                  ³±±
±±³          ³ ExpC3 = Concepto a procesar (opcional)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ uResult  = Numerico -> total de Registros                    ³±±
±±³          ³         = Caracter -> RC_ENTIDAD                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Consultas S017 de las Tabla RCC procesadas por la Función    ³±±
±±³          ³ GPER028GNR                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fApvc(cTipo,cCon1, cCon2)
Local aAreaRC		:=	GetArea()
Local uResult	  
Local nX			:= 0 
Local nTotalR		:= 0
Local cConIn		:= ""
Local cAliasRCc	:= criatrab( nil, .f. )
DEFAULT cTipo	:= NIL
DEFAULT cCon1	:= NIL
DEFAULT cCon1	:= NIL
uResult:=0
//Verifica que las variables cTipo y cCon1 no esten vacias.    
If  !empty(cTipo) .AND. cTipo $ ("EVF")
	                        
	IF cTipo == 'E' .and. !empty(cCon1)
		cConIn := "'" + cCon1 + "'"
		If !Empty(cCon2)
			cConIn +=",'" + cCon2 + "'"
		EndIf
		//E  debe retornar el valor de SRC->RC_ENTIDAD
		cQuery := " SELECT " +cPrefixo+"ENTIDAD AS RC_ENTIDAD, SUM("+cPrefixo+"VALOR) VALTOTAL, RG1_CONTRA, RG1_FORPAG, "+cPrefixo+"PD "
		cQuery += " FROM " + RetSqlName(cAliasAux) +" "+ cAliasAux + " INNER JOIN " + RetSqlName("RG1") + " RG1 " 
		cQuery += " ON " +cPrefixo+"NUMID = RG1_NUMID AND " +cPrefixo+"MAT=RG1_MAT "
		cQuery += " 	WHERE " 
		cQuery += " " +cPrefixo+"PD	 IN ( "+ cConIn +" )" //Conceptos
		If(!Empty(cMatricu), cQuery += "	AND " +cPrefixo+"MAT = '" + cMatricu + "'","")    //Matricula
		If(!Empty(cProcess), cQuery += "	AND " +cPrefixo+"PROCES =	'" + cProcess + "' ","") //Proceso
		If(!Empty(cRoteiro), cQuery += "	AND " +cPrefixo+"ROTEIR =	'" + cRoteiro + "' ","") //Tipo de Nómina 									
		If(!Empty(cPeriodo), cQuery += "	AND " +cPrefixo+"PERIODO=	'" + cPeriodo + "' ","") //Periodo 
		If(!Empty(cNumPago), cQuery += "	AND " +cPrefixo+"SEMANA	= 	'" + cNumPago + "' ","") //No de Pago 
		cQuery += " 	AND " +cPrefixo+"FILIAL 	= '" + XFILIAL(cAliasAux, XFILIAL('SRA')) + "' "	
		cQuery += " 	AND " +cPrefixo+"FILIAL 	= '" + XFILIAL('RG1', XFILIAL('SRA')) + "' "	
		cQuery += " 	AND " +cAliasAux+".D_E_L_E_T_ 	= ' ' "	
		cQuery += " 	AND RG1.D_E_L_E_T_ 	= ' ' "
		CQuery += " GROUP BY " +cPrefixo+"ENTIDAD, RG1_CONTRA,RG1_FORPAG, " +cPrefixo+"PD"	
		cQuery := ChangeQuery(cQuery)   	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRCc,.T.,.T.)
		Count to nTotalR
		(cAliasRCc)->(dbgotop())//primer registro de tabla
		
		//En caso de encontrar mas de un renglón en la SRC para el Concepto, pero mietras el campo RC_ENTIDAD es el mismo, devuelve solo el campo.
		WHILE ( cAliasRCc )->(!eof())
			
			nValAPVC:= ( cAliasRCc )-> VALTOTAL 
			cRG1APVC:= ( cAliasRCc )-> RG1_CONTRA
			cFPaAPVC:= ( cAliasRCc )-> RG1_FORPAG
			//Envia La línea a impresión
			GPER028IMP('VC', ALLTRIM(( cAliasRCc )-> RC_ENTIDAD) )
			
			( cAliasRCc )->(dbSkip())
		ENDDO	
		
		( cAliasRCc )->(dbCloseArea())
		
	ElseIf cTipo == 'V'
		uResult := nValAPVC
		nValAPVC := 0
	ElseIf cTipo == 'F'	
		uResult := Val(cFPaAPVC)
		cFPaAPVC := ""
	EndIf
EndIf

RestArea(aAreaRC)
Return (uResult)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fApvcC     ³ Autor ³ Alfredo Medrano       ³ Data ³14/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna el valor de RG1->RG1_CONTRA para APVC                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fApvcC()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ RG1->RG1_CONTRA  = Numero de Contrato                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Consultas S017  - GPER028GNR                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function fApvcC()
	Local cCntRG := ""
	cCntRG := cRG1APVC
	cRG1APVC := ""
Return cCntRG
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPE801TXT  ³ Autor ³ Alfredo Medrano       ³ Data ³14/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Graba la información enviada en un archivo de texto          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPE801TXT(ExpA1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 := Array con la informacion                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER028IMP()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPE801TXT(aRegis)
Local nX		:= 0 
Local cLin 	:= ""

	For nX :=1 To Len(aRegis)
		cLin += aRegis[nX,2] 	   
	Next nX
	cLin += CRLF
	
   //Verifica que no haya errores durante la grabación de la línea.
    If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
        If !MsgAlert(OemToAnsi(STR0006),OemToAnsi(STR0003)) //"Ocurrio un error en la grabacion del archivo.¿Continua?","Atención!""
        Endif
    Endif
    
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RetVerbasFunc³Autor ³Alfredo Medrano        ³ Data ³07/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Retorna los conceptos del Empleado.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPE801TXT(ExpC1,ExpC2,ExpC3,ExpC4,ExpA1,ExpA2,ExpA3)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1        - Filial                                        ³±±
±±³          ³ ExpC2        - Matricula                                     ³±±
±±³          ³ ExpC3        - Centro de Custo da verba (opcional)           ³±±
±±³          ³ ExpC4        - Roteiro                                       ³±±
±±³          ³ ExpA1        - Array com as verbas que deverão ser listadas. ³±±
±±³          ³               (opcional).                                    ³±±
±±³          ³ ExpA2        - Array com os periodos (abertos). Sera utili-  ³±±
±±³          ³               zado para filtro no SRC.                       ³±±
±±³          ³               aPerAberto[n][1] - Periodo       	    	      ³±±
±±³          ³               aPerAberto[n][2] - Nro de pagamento(opcional)  ³±±
±±³          ³               Se esse elemento nao existir, sera             ³±±
±±³          ³		        selecionado todos os numeros de pagamento      ³±±
±±³          ³		        do periodo - aPerAberto[n][1]                  ³±±
±±³          ³ ExpA3        - Array com os periodos (fechados). Sera utili- ³±±
±±³          ³               zado para filtro no SRD.    				      ³±±
±±³          ³               aPerAberto[n][1] - Periodo       	    	      ³±±
±±³          ³               aPerAberto[n][2] - Nro de pagamento(opcional)  ³±±
±±³          ³               Se esse elemento nao existir, sera             ³±±
±±³          ³		        selecionado todos os numeros de pagamento      ³±±
±±³          ³		        do periodo - aPerAberto[n][1]                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER028GNR()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetVerbasFunc(cFil		,;	//-01
								cMatricula		,;	//-02
								cCCusto		,;	//-03
								cRoteiro		,;	//-04
								aVerbas		,;	//-05
								aPerAberto		,;	//-06
								aPerFechado	)	//-07
														 		          
Local aArea			:= GetArea()
Local aAreaSRC		:= SRC->(GetArea())
Local aAreaSRD		:= SRD->(GetArea())
Local cKey			:= ""
Local bSkip			:= {}
Local aQueryCond		:= {}
Local aCols			:= {}
Local aHeader			:= {}
Local nUsado			:= 0
Local aVirtual		:= {}
Local aVisual			:= {}
Local aRecnos			:= {}
Local nPosPd			:= ""
Local nPosTipo		:= ""
Local nPosQtdSem		:= ""
Local nPosHoras		:= ""
Local nPosValor		:= ""
Local nPosSemana		:= ""
Local nPosParcela	:= ""
Local nPosPeriodo	:= 0
Local nPosRoteiro	:= ""
Local nPosCc			:= ""
Local nPosData		:= ""
Local nPosDtRef		:= ""
Local nReg			:= 0
Local aVerbasFunc	:= {}
Local aAlias			:= {}
Local aStrut			:= {}
Local cAlias			:= ""
Local cAliasQry		:= "Q"
Local cPrefixo		:= ""
Local cQuery			:= ""
Local cPerPag			:= ""
Local nPer			:= 0
Local nIndex			:= 0
Local nRegAlias		:= 0
Local nFields			:= 0
Local nPosTipo2		:= "" 
Local cDtIni			:= ""
Local cDtFim			:= ""
DEFAULT cCCusto		:= ""
DEFAULT cRoteiro		:= ""
DEFAULT aVerbas		:= {} 
DEFAULT aPerAberto	:= {} 
DEFAULT aPerFechado	:= {} 
                                
	If 	cAliasAux == "SRC"
		aAdd( aAlias, {"SRC", ( PrefixoCpo( "SRC" ) + "_" ), 6} )
	ElseIf cAliasAux == "SRD"
		aAdd( aAlias, {"SRD", ( PrefixoCpo( "SRD" ) + "_" ), 6} )
	EndIf
                                    
	If Len(aAlias) > 0
		For nRegAlias := 1 to Len(aAlias)    
			aHeader		:= {}
			aCols		:= {}
			cPerPag		:= ""
			cAlias		:= aAlias[nRegAlias,1]
			cPrefixo	:= aAlias[nRegAlias,2]
			nIndex		:= aAlias[nRegAlias,3]
				aHeader := GdMontaHeader(;
							@nUsado		,;	//01 -> Por Referencia contera o numero de campos em Uso
		   					@aVirtual		,;	//02 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Virtuais
							@aVisual		,;	//03 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Visuais
							cAlias			,;	//04 -> Opcional, Alias do Arquivo Para Montagem do aHeader
							NIL				,;	//05 -> Opcional, Campos que nao Deverao constar no aHeader
							NIL				,;	//06 -> Opcional, Carregar Todos os Campos
							.T.				,;	//07 -> Nao Carrega os Campos Virtuais
							NIL				,;	//08 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
							NIL				,;	//09 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
							NIL				,;	//10 -> Verifica se Deve Checar se o campo eh usado
							NIL				,;	//11 -> Verifica se Deve Checar o nivel do usuario
							NIL				,;	//12 -> Utiliza Numeracao na GhostCol
							NIL		 		)	//13 -> Carrega os Campos de Usuario							   			
                                                             
				cAliasQry += cAlias
				cQuery := "SELECT "

				For nFields := 1 to nUsado
					If Ascan(aVirtual,{|x| x = aHeader[nFields,2]}) = 0
						cQuery += AllTrim(aHeader[nFields,2])
	    				If nFields < nUsado
							cQuery += ", "
						Endif
					Endif
				Next nFields
				If  !(AT("ENTIDAD",cQuery) > 0)
					cQuery += ", " + cPrefixo + "ENTIDAD "
				Endif
				cQuery += " FROM " + RetSqlName(cAlias)
				cQuery += " WHERE "
				cQuery += " " + cPrefixo + "FILIAL = '" + cFil + "'"
				cQuery += "  AND "
				cQuery += " " + cPrefixo + "MAT = '" + cMatricula + "'" 
				
				If(!Empty(cProcess), cQuery += "	AND " + cPrefixo + "PROCES=	'" + cProcess + "' ","") //Proceso
				If(!Empty(cRoteiro), cQuery += "	AND " + cPrefixo + "ROTEIR=	'" + cRoteiro + "' ","") //Tipo de Nómina 									
				If(!Empty(cPeriodo), cQuery += "	AND " + cPrefixo + "PERIODO=	'" + cPeriodo + "' ","") //Periodo Actual
				If(!Empty(cNumPago), cQuery += "	AND " + cPrefixo + "SEMANA	= 	'" + cNumPago + "' ","") //No de Pago Actual
				cQuery += " AND D_E_L_E_T_=' ' "
				cQuery := ChangeQuery(cQuery)  
				If ( Select( cAliasQry ) > 0 )
					( cAliasQry )->( dbCloseArea() )
				EndIf 
				aStrut := (cAlias)->(dbStruct())
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)				
				For nFields := 1 To Len(aStrut)
					If ( aStrut[nFields][2] <> "C" )
						TcSetField(cAliasQry,aStrut[nFields][1],aStrut[nFields][2],aStrut[nFields][3],aStrut[nFields][4])
					EndIf
				Next nFields 
				
				nPosQtdSem	:= GdFieldPos(cPrefixo + "QTDSEM"	, aHeader)
				While !(cAliasQry)->(Eof())
					
					If Len(aVerbas) = 0
						nMyPos := 0
					Else
						nMyPos := aScan(aVerbas, { |x| x[1] == (cAliasQry)->(&(cPrefixo + "PD")) } )
					EndIf
					If 	(Empty(cCCusto)  	.OR. (!Empty(cCCusto)  .AND. (cAliasQry)->(&(cPrefixo + "CC")) == cCCusto)) ;
					    .AND. ;
						(Len(aVerbas) == 0 	.OR. (Len(aVerbas) > 0 .AND. nMyPos > 0 ))
							
							aAdd(aVerbasFunc, {	cFil,;										//-01
												cMatricula,;									//-02
												(cAliasQry)->(&(cPrefixo + "PD")),;		//-03
												(cAliasQry)->(&(cPrefixo + "TIPO1")),;		//-04 
												If (nPosQtdSem > 0, (cAliasQry)->(&(cPrefixo + "QTDSEM")), 0),;		//-05
												(cAliasQry)->(&(cPrefixo + "HORAS")),;		//-06
												(cAliasQry)->(&(cPrefixo + "VALOR")),;		//-07
												(cAliasQry)->(&(cPrefixo + "SEMANA")),;	//-08
												Iif(cAliasQry == "QSRC", (cAliasQry)->(&(cPrefixo + "PARCELA")), 0),;	//-09
												(cAliasQry)->(&(cPrefixo + "PERIODO")),;	//-10
												(cAliasQry)->(&(cPrefixo + "ROTEIR")),;	//-11
												(cAliasQry)->(&(cPrefixo + "CC")),;		//-12
												Iif(cAliasQry=="QSRC",(cAliasQry)->(&(cPrefixo + "DATA")),(cAliasQry)->(&(cPrefixo + "DATPGT"))),;	//-13
												Iif(cAliasQry=="QSRC",(cAliasQry)->(&(cPrefixo + "DTREF")),(cAliasQry)->(&(cPrefixo + "DATARQ"))),;	//-14
												(cAliasQry)->(&(cPrefixo + "SEQ")),;		//-15
												(cAliasQry)->(&(cPrefixo + "NUMID")),;		//-16
												(cAliasQry)->(&(cPrefixo + "TIPO2")),;		//-17
												(cAliasQry)->(&(cPrefixo + "ENTIDAD")) })	//-18							                
					EndIf                  
					(cAliasQry)->(DbSkip())
				EndDo
				(cAliasQry)->(DbCloseArea())
				
		Next nRegAlias
	EndIf	
//Ordenar por Filial, MAtricula y Concepto
aSort( aVerbasFunc ,,, { |x,y| x[1] + x[2] + x[3] < y[1] + y[2] + y[3] } )
RestArea( aArea )
RestArea( aAreaSRC )
Return ( aVerbasFunc )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ForFecha   ³ Autor ³ Alfredo Medrano       ³ Data ³25/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna la fecha (Mes años)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ForFecha()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³dFchMes = Fecha para obtener el mes                           ³±±
±±³          ³dFchAnio= Fecha para obtener el Año                           ³±±
±±³          ³nTam    = tamaño de cadena                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Mes + Año                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Consultas S017  - GPER028GNR                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function ForFecha(dFchMes,dFchAnio, nTam)
	default dFchMes	:= CTOD('//') 
	default dFchAnio	:= CTOD('//')
	default nTam := 0
	
	cFecha := STRZERO(VAL(CVALTOCHAR(MONTH(dFchMes)) + CVALTOCHAR(YEAR(dFchAnio))),nTam,0 )    
		
Return cFecha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FInstit    ³ Autor ³ Alfredo Medrano       ³ Data ³10/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Devuelve el RUT o dígito verificador del RUT de la institución³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FInstit(ExpC1)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := define el tipo de Rut                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ uResult := La Rut de la institución                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Consultas S017  - GPER028GNR                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function FInstit(cTipo)
Local aArea		:=	GetArea()
Local uResult		 
Local cRut		:= ""
DEFAULT cTipo	:= NIL

uResult := 0
//Verifica que las variables cTipo no esten vacias.   
If !empty(cTipo) .AND. cTipo $ ("RD")

	IF empty(cRUTIns)
		//La Rut de la institución se enuentra en dos lugares RCO 
		cRut := POSICIONE("RCO",4,XFILIAL("RCO")+cTpEnti+cEntPag ,"RCO_NREPAT")
		If !empty(cRut)	
			cRUTIns := cRut
		EndIf
	EndIf
		
	If cTipo == 'R' .AND. !empty(cRUTIns)
		uResult := Substr( cRUTIns, 1, 8 )
	ElseIf cTipo == 'D' .AND. !empty(cRUTIns)
		uResult := Substr( cRUTIns, 9, 1 )
		cRUTIns := ""
		cTpEnti := ""
		cEntPag := ""
	EndIf
	                                
EndIf
RestArea(aArea)
Return (uResult) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FCotPact   ³ Autor ³ Alfredo Medrano       ³ Data ³11/06/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cotización Pactada                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FCotPact(ExpC1)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Concepto                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cReturn: Valor                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Consultas S017  - GPER028GNR                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function FCotPact(cConc)
	Local cReturn := ""
	default cConc := ""
	
	If !Empty(cConc) 
		If SRA->RA_ISATIPO == '2'
			cReturn	:= TRANSFORM(SRA->RA_ISAUF, "99.99999")   
		Else
			cReturn	:= STRZERO(FPREVI('V',cConc),8,0)
		EndIf
	EndIf
	
Return cReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FormFech   ³ Autor ³ Alfredo Medrano       ³ Data ³15/04/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Convierte fecha a formato especificado                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FormFech(ExpC1, ExpC2)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Formato de Fecha ejemplo: 'dd-mm-aaaa' etc..         ³±±
±±³          ³ ExpC2 = Fecha en cartacter                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cFecha: caracter de Fecha con Formato                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³fMovFini y fMovFFin                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FormFech(cDtIn,cFchS)
Local nConta		:= 0 
Local cCaden		:=''
Local cCarS		:=''
Local cSprd		:=''
Local	nY			:= 0
Local	nNumC	   := 0
Local cFecha		:= ''
default cDtIn	:=''

nNumC:=Len(cDtIn) //número caracteres de Formato enviado
For nY := 1 to nNumC
	cCar:= Substr(LOWER(cDtIn),nY,1) // obtiene el carácter
	cCaden := cCaden + cCar
	nConta++
	
	If nConta > 1 
	
		If cCar != cCarS .OR. nY == nNumC 
		
			If !(cCar $ 'd|m|a') // si es difierente entonces es un separador(alfanumerico)
				nConta := 0
				cSprd := cCar
			Else
				cSprd := ""
			EndIf
			
			if nY != nNumC
				cCaden:= SubStr(cCaden,1,len(cCaden)-1)
			EndIf
			
			//Verifica si es dia, mes o año(con dos o cuatro digitos)
			//El formato por default de la fecha de entrada (cFecha) es dd/mm/aaaa
			Do Case
				Case cCaden == 'dd'
					cFecha := cFecha + Substr(cFchS,1,2) + cSprd 
				Case cCaden == 'mm'
					cFecha := cFecha + Substr(cFchS,4,2) + cSprd 
				Case cCaden == 'aa'
					cFecha := cFecha + Substr(cFchS,9,2) + cSprd 
				Case cCaden == 'aaaa'
					cFecha := cFecha + Substr(cFchS,7,4) + cSprd 	
			End Case
			cCaden:=''
			
			If cSprd ==""
				cCaden:= cCar
			EndIf
			
		EndIf
		
	EndIf

	cCarS:= cCar
	cSprd:= ""
Next

Return cFecha
