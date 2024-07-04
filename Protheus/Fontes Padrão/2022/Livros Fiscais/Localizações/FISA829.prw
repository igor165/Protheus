#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA829.CH"

#DEFINE MASCARA	"Archivos de Datos ( *.TXT ) |*.TXT|Todos los archivos (*.*) |*.*"
#DEFINE _CTOKEN			';'

//Estructura de registros
//                    Orden	       Nombre del campo	                    Tipo	Long. Máx	    Formato / Observaciones
#DEFINE A_CUIT	        1	    // CUIT	                                NUMBER	11	 	
#DEFINE A_RAZSOC	    2	    // Razón Social / Denominación          CHAR	200	 	
#DEFINE A_ESTCUIT	    3	    // Estado de la CUIT	                NUMBER	1		        Valores posibles 0, 1, 2,3. Valor 0 es Inactivo
#DEFINE A_VIGEEST       4	    // Fecha vigencia del Estado	        DATE	10	            dd/mm/yyyy:	
#DEFINE A_NDFEEST	    5	    // Fecha de notificación DFE estado     DATE	10	            dd/mm/yyyy:	
#DEFINE A_CBU	        6	    // CBU	                                CHAR	22	 	        
#DEFINE A_ACTUCBU	    7	    // Fecha Actualización CBU	            DATE	19	            dd/mm/yyyy HH:MM:SS	
#DEFINE A_CODCATEG	    8	    // Cód. Categoría	                    NUMBER	2	 	        
#DEFINE A_CATEGORIA	    9	    // Categoría	                        CHAR	200	 	        
#DEFINE A_SITCATEG	    10  	// Situación Categoría	                CHAR	2	 	        Valores posibles AL/BA (ALTA/BAJA)
#DEFINE A_VIGCATEG	    11  	// Fecha Vigencia Categoría	            DATE	10	            dd/mm/yyyy:	
#DEFINE A_NDFECATEG	    12  	// Fecha Notificación DFE Categoría	    DATE	10	            dd/mm/yyyy:	
#DEFINE A_OBSERVAC	    13  	// Observaciones	                    CHAR	1000	         	
#DEFINE A_FECHAGEN	    14  	// Fecha de Generación	                DATE	9	            dd-mmm-yy (Ej 17-MAY-19)

#DEFINE A_QTDCAMPOS     14  	// Cantidad de campos que se esperan leer en un registro (usado en validación inicial)

#DEFINE _PARAM_ULT_EJEC "MV_AGSISAU"  	// Parámetro del sistema para almacenar datos de la última ejecución [usuario y fecha]

#DEFINE UE_FCH_GEN 1
#DEFINE UE_FCH_IMP 2
#DEFINE UE_USUARIO 3

/*/{Protheus.doc} AGRA305
Funcionalidad requerida por la RG 4310 – Sistema de Información Simplificado Agrícola “SISA”. 
Resolución General Conjunta N° 4.248 (Ministerio de Agroindustria - SENASA - INASE - AFIP). 
	
@type  Function
@author Alejandro Perret
@since 20/08/2019
@version 1.0		
/*/

Function FISA829()

Private oBrowse := FWMBrowse():New()
Private _cProg 	:= ProcName()

oBrowse:SetAlias("FX6")	
oBrowse:SetDescription(STR0001)
oBrowse:DisableDetails()

oBrowse:Activate()

Return()

//===================================================================================================================================
/*/{Protheus.doc} MenuDef
    Menu de la rutina

    @type  Static Function
    @author Alejandro Perret
    @since 20/08/2019
    @version 1.0
/*/
//===================================================================================================================================

Function MenuDef()     
Local aRotina	:= {}   

ADD OPTION aRotina TITLE STR0050	ACTION "VIEWDEF.FISA829"     OPERATION MODEL_OPERATION_VIEW		ACCESS 0 
ADD OPTION aRotina TITLE STR0051 	ACTION "PadSISA()"    	 OPERATION MODEL_OPERATION_INSERT	ACCESS 0


Return(aRotina)


//===================================================================================================================================
/*/{Protheus.doc} ModelDef
    Definición del modelo de datos

    @type  Static Function
    @author Alejandro Perret
    @since 20/08/2019
    @version 1.0
/*/
//===================================================================================================================================

Static Function ModelDef()
Local oStruFX6 	:= FWFormStruct(1, "FX6")
Local oModel	:= MPFormModel():New("FISA829")

oModel:AddFields("FX6MASTER", , oStruFX6 )
oModel:SetDescription(STR0049)
oModel:GetModel("FX6MASTER"):SetDescription(STR0001)
oModel:SetPrimaryKey({"FX6_FILIAL", "FX6_CUIT"})

Return(oModel)


//===================================================================================================================================
/*/{Protheus.doc} ViewDef
    Definición de la vista

    @type  Static Function
    @author Alejandro Perret
    @since 20/08/2019
    @version 1.0
/*/
//===================================================================================================================================

 Static Function ViewDef()

Local oModel 	:= FWLoadModel("FISA829")
Local oStruFX6 	:= FWFormStruct(2, "FX6")
Local oView 	:= FWFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_FX6", oStruFX6, "FX6MASTER")
oView:CreateHorizontalBox("TELA", 100)
oView:SetOwnerView("VIEW_FX6", "TELA")

Return(oView)


//===================================================================================================================================
/*/{Protheus.doc} PadSISA
Importación/Actualización del Padrón SISA (archivo txt) a la tabla FX6.
	
@type  Function
@author Alejandro Perret
@since 20/08/2019
@version 1.0		
/*/
//===================================================================================================================================

Function PadSISA()

Local nBtnSel 	:= 1
Local cTitulo	:= ""
Local cTexto	:= ""
Local nTam 		:= 3	//1,2,3

Private _dFchGen	:= CToD("  /  /  ")
Private _aUltEjec	:= UltimaEjec() 

cTitulo	:= STR0002  

cTexto := STR0003 + ; 	
		  STR0004 + CRLF +  ;	
		  STR0005 + CRLF + CRLF + CRLF + CRLF + CRLF + ; 	
		  STR0006 + _aUltEjec[UE_FCH_GEN] + CRLF + ;	
		  STR0007 + _aUltEjec[UE_FCH_IMP] + CRLF + ; 	
		  STR0008 + _aUltEjec[UE_USUARIO]		
			
nBtnSel := Aviso(cTitulo, cTexto, {STR0053, STR0054}, nTam)
    
Do Case
    Case nBtnSel == 1 				// Iniciar 1
        IniciaProceso()
        
    Otherwise 						// Cerrar
    
EndCase		

Return()

//===================================================================================================================================
/*/{Protheus.doc} IniciaProceso
    Inicia el proceso de lectura e importación del Padrón SISA

    @type  Static Function
    @author Alejandro Perret
    @since 20/08/2019
    @version 1.0
/*/
//===================================================================================================================================

Function IniciaProceso()

Local lOk		:= .T.
Local cFile     := Space(100)
Local cMsgOK	:= STR0009  
Local cErrores	:= ""
Local oArchivo 	:= Archivo():New() 
Local cLogInfo	:= ""
Local nE

Private _cLogGenerado   := ""
Private _aErrores 	    := {}

If Type('_cProg') == 'U'
	_cProg := "FISA829"
EndIf

If SelecArch(@cFile)
	
	DbSelectArea("FX6")
	DbCloseArea()
	
	If ChkFile("FX6",.T.)		

		If (lOk := ValidIni(cFile, oArchivo))   // Abre archivo y realiza una validación inicial
			Processa({|| lOk := ProcArch(oArchivo) }, STR0012 + CRLF + STR0013, + STR0014, .F.)   
			oArchivo:CierraTxt()
		EndIf

		If lOk 
			cLogInfo :=  STR0015 + Upper(cFile) + CRLF + CRLF + _cLogGenerado 
		Else
			cErrores :=  STR0015 + Upper(cFile) + CRLF + CRLF + _cLogGenerado 
			For nE := 1 To Len(_aErrores)
				cErrores += _aErrores[nE] + CRLF
			Next
			
		EndIf		

		If lOk
			PutMV(_PARAM_ULT_EJEC, DToC(_dFchGen) + _CTOKEN + DToC(dDataBase) + _CTOKEN +  cUserName)
			_aUltEjec := {DToC(_dFchGen), DToC(dDataBase), cUserName}
			
			MsgInfo(STR0019 + oArchivo:cNomArch + STR0020 , STR0021)	
		EndIf
	
	Else
		MsgAlert(STR0023 + CRLF + ; 
				 STR0024) 
	EndIf
	
	DbSelectArea("FX6")
	DbSetOrder(1)
	If Type('oBrowse') != 'U'
		oBrowse:Refresh(.T.)
	EndIf
	
EndIf

Return()


//===================================================================================================================================
/*/{Protheus.doc} SelecArch
    Pantalla para selección de archivo a procesar

    @type  Static Function
    @author Alejandro Perret
    @since 20/08/2019
    @version 1.0
    /*/
//===================================================================================================================================

Function SelecArch(cFile)

Local lRet      := .F.
Local nAnchoWnd := 510/2 
Local nLargoWnd := 150/2
Local cTitu		:= STR0025
Local oDlg, oBtnAceptar, oBtnCancelar, oGetFile, oBtnBuscar

DEFINE MSDIALOG oDlg TITLE cTitu FROM 0,0 TO 150, 510 PIXEL

    @005,006 TO 035, nAnchoWnd-005 LABEL STR0026 OF oDlg PIXEL 
    @016,012 MSGET oGetFile VAR cFile SIZE 192,010 PIXEL OF oDlg 
    @016,210 BUTTON oBtnBuscar   PROMPT "&Buscar" SIZE 30,12 ACTION(cFile := cGetFile(MASCARA, STR0027 ,1,,.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE)) PIXEL OF oDlg 
	
	@ nLargoWnd-22, nAnchoWnd-114 BUTTON oBtnAceptar  PROMPT "&Procesar" 	SIZE 50,16 ACTION(Iif(lRet := ValidArch(cFile),oDlg:End(),)) 	PIXEL OF oDlg
	@ nLargoWnd-22, nAnchoWnd-054 BUTTON oBtnCancelar PROMPT "&Cancelar" 	SIZE 50,16 ACTION(lRet := .F., oDlg:End()) 	                    PIXEL OF oDlg
    
	oDlg:lEscClose	:= .T. 
	oDlg:LCENTERED 	:= .T.
    
ACTIVATE MSDIALOG oDlg CENTERED 
    
Return(lRet)


//===================================================================================================================================
/*/{Protheus.doc} ValidArch
    Validación de existencia de archivo
    
    @type  Static Function
    @author Alejandro Perret
    @since 20/08/2019
    @version 1.0
    /*/
//===================================================================================================================================

Function ValidArch(cFile)

Local lRet := .T.

If Empty(cFile)
    lRet := .F.
    MsgAlert(STR0028, STR0029) 

ElseIf !File(cFile)
    lRet := .F.
    MsgAlert(STR0030, STR0031)  
EndIf

Return(lRet)


//===================================================================================================================================
/*/{Protheus.doc} ValidIni
    Abre el archivo y realiza una validación inicial. Si no se puede abrir el archivo graba un mensaje en el log.
    
    @type  Static Function
    @author Alejandro Perret
    @since 20/08/2019
    @version 1.0
    /*/
//===================================================================================================================================

Function ValidIni(cNomArch, oArchivo)
Local lRet 		:= .T.
Local cMsgError := ""
Local aLin		:= {}
Local cLin		:= ""
Local nNumLin   := 0

Default cNomArch := ""

If oArchivo:AbreTxt(cNomArch, @cMsgError)

    While !oArchivo:EOFTxt()
        nNumLin++
		
		If nNumLin == 1
			cLin := oArchivo:LeeLinTxt()
            _dFchGen := CToD(SubStr(cLin,  AT(':', cLin) + 1, 10)) 
                                                                   
                                                                   
			If Empty(_dFchGen)
                lRet := .F.
                cMsgError := STR0032 + CRLF + ; 
                            STR0033 + CValToChar(nNumLin) + "." 
                Aadd(_aErrores, cMsgError)
				Exit
			EndIf
		EndIf

        If nNumLin > 2 
			aLin := StrTokArr2(oArchivo:LeeLinTxt(), _CTOKEN, .T.)
			
            If Len(aLin) < A_QTDCAMPOS
                lRet := .F.
                cMsgError := STR0034 + CRLF + ;  
                             STR0035 + CValToChar(nNumLin) + STR0036 + CValToChar(A_QTDCAMPOS) 
                Aadd(_aErrores, cMsgError)
            EndIf

			Exit
		EndIf

		oArchivo:AvLinTxt()
	EndDo 
	
	If !lRet
		oArchivo:CierraTxt()
	EndIf
	
	If lRet .And. (_dFchGen <= CToD(_aUltEjec[UE_FCH_GEN])) 	 
		If !MsgYesNo(STR0037 + DToC(_dFchGen) + ; 
					 STR0038 + _aUltEjec[UE_FCH_GEN] + STR0039 + ;   
					 STR0040)		
			lRet := .F.            
        EndIf  	
	EndIf

Else

	lRet := .F.
	Aadd(_aErrores, cMsgError)
	
EndIf

Return(lRet)


//===================================================================================================================================
/*/{Protheus.doc} ProcArch
    Procesamiento del archivo y grabación de tablas.
    
    @type  Static Function
    @author Alejandro Perret
    @since 21/08/2019
    @version 1.0
    /*/
//===================================================================================================================================

Function ProcArch(oArchivo)
Local lRet 		:= .T.
Local nQtdLin	:= oArchivo:CantTotLinTxt()	
Local cQtdLin	:= CValToChar(nQtdLin)
Local aLin		:= {}
Local cMsgError	:= ""
Local nNumLin	:= 0
Local cFilFX6   := xFilial("FX6")
Local cFilSA2   := xFilial("SA2")
Local cCat := ""


DbSelectArea("SA2")
DbSetOrder(3)			// A2_FILIAL+A2_CGC

DbSelectArea("FX6") 
FX6->(DbSetOrder(1))     // filial+cuit+categoria

	
ProcRegua(nQtdLin)
oArchivo:IrAlInicioTxt()	

While !oArchivo:EOFTxt()
    nNumLin++
    IncProc(STR0041 + oArchivo:cNomArch + STR0042 + cValToChar(nNumLin) + STR0043 + cQtdLin)

    If nNumLin <= 2     
        oArchivo:AvLinTxt()
        Loop
    EndIf 
	
    aLin := StrTokArr2(oArchivo:LeeLinTxt(), _CTOKEN, .T.)

    If Len(aLin) >= A_QTDCAMPOS
	
        If (CToD(aLin[A_VIGEEST]) <= dDataBase) .And. (CToD(aLin[A_VIGCATEG]) <= dDataBase) .And. aLin[A_SITCATEG] = "AL" 
           
           cCat:= Subs(aLin[A_CODCATEG],1,2)
           
           If FX6->(MSseek(cFilFX6+  aLin[A_CUIT] +  cCat  ) )
				RecLock("FX6", .F.)
				FX6_EST    := Val(aLin[A_ESTCUIT])
				FX6_VIGEST := CToD(aLin[A_VIGEEST])
				FX6_VIGCAT := CToD(aLin[A_VIGCATEG])
				FX6_DATGEN := _dFchGen	
				Msunlock()
			Else
			
				RecLock("FX6", .T.)
				FX6_FILIAL := cFilFX6
				FX6_CUIT   := aLin[A_CUIT]
				FX6_EST    := Val(aLin[A_ESTCUIT])
				FX6_VIGEST := CToD(aLin[A_VIGEEST])
				FX6_CODCAT :=  cCat
				FX6_CATEG  := aLin[A_CATEGORIA]
				FX6_SITCAT := aLin[A_SITCATEG]
				FX6_VIGCAT := CToD(aLin[A_VIGCATEG])
				FX6_DATGEN := _dFchGen	
		   
				Msunlock()
		    EndIf
			If !Empty(aLin[A_CBU]) .And. SA2->(MSseek(cFilSA2 + aLin[A_CUIT]))  
				RecLock("SA2", .F.)
					A2_CBUESP := aLin[A_CBU]
				Msunlock()	
			EndIf
		
        EndIf
    Else
        lRet := .F.
        cMsgError := STR0044 + CRLF + ; 
                    STR0045 + CValToChar(nNumLin) + STR0046 + CValToChar(A_QTDCAMPOS)  
        Aadd(_aErrores, cMsgError)
	EndIf				

	oArchivo:AvLinTxt()
EndDo 

_cLogGenerado := STR0047 + DToC(_dFchGen) + CRLF 

DbSelectArea("FX6")
DbCloseArea()
Return(lRet)


//===================================================================================================================================
/*/{Protheus.doc} VerLogCV8
    Pantalla de visuailzación de logs de procesamiento (CV8)
    
    @type  Static Function
    @author Alejandro Perret
    @since 20/08/2019
    @version 1.0
    /*/
//===================================================================================================================================

Function VerLogCV8(cNomProc)
Local aArea	:= GetArea()
Local cProc	:= ""

Default cNomProc := ""

cProc := PadR(cNomProc,Len(CV8->CV8_PROC)) 
MyProcLogV(, cProc)
RestArea(aArea)
Return()


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Programa   ³ MyProcLo ³ Autor ³ Alejandro Perret      ³ Fecha³ 21/11/2018 ³
ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´
³Descrip.   ³ Modifico la estandar porque para la version actual no        ³
³           ³ funciona como lo esperado.                                   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 

Function MyProcLogV(cFilProc,cProc,cSubProc,cIdCV8)
Local aAreaAnt  := GetArea()
Local cFilterIni:= ""
Local cFilterFin:= ""   
Local cChave	:= "" 

Private aRotina 	:= {{ STR0050  ,STR0056, Recno() , 2}}  
Default cProc 		:= __BatchProc  
Default cSubProc 	:= ""
Default cFilProc 	:= cFilAnt

If Type("cCadastro") != "C"
	cCadastro := ""
EndIf


__BatchProc := cProc

//Criado parametro para filtro
DbSelectArea("CV8")
DbGoBottom()

If !Empty(cIdCV8) .And. CV8->(ColumnPos("CV8_IDMOV")) > 0
	dbSetOrder(5) //CV8_FILIAL+CV8_IDMOV
	cFilterIni := 'xFilial("CV8","'+cFilProc+'")+"'+cIdCV8+'"'
	cFilterFin := 'xFilial("CV8","'+cFilProc+'")+"'+cIdCV8+'"'
	cChave := xFilial("CV8")+cIdCV8
ElseIf !Empty(cSubProc) .And. CV8->(ColumnPos("CV8_SBPROC")) > 0
	dbSetOrder(4) //CV8_FILIAL+CV8_PROC+CV8_SBPROC+CV8_USER+DTOS(CV8_DATA)+CV8_HORA
	cProc := Padr( cProc,TamSx3("CV8_PROC")[1])
	cFilterIni := 'xFilial("CV8","'+cFilProc+'")+"'+cProc+cSubProc+'"'
	cFilterFin := 'xFilial("CV8","'+cFilProc+'")+"'+cProc+cSubProc+'"' 
	cChave := xFilial("CV8")+cProc+cSubProc
Else
	dbSetOrder(1) //CV8_FILIAL+CV8_PROC+DTOS(CV8_DATA)+CV8_HORA
	cProc := Padr( cProc,TamSx3("CV8_PROC")[1])
	cFilterIni :='xFilial("CV8")+"'+cProc+'"'
	cFilterFin :='xFilial("CV8")+"'+cProc+'zzzzzzzzzzz"'                    
	cChave := xFilial("CV8")+cProc
EndIf 

MaWndBrowse(0,0,500,920,"Log de Procesos","CV8",,aRotina,"CV8->CV8_INFO=='4'",;
cFilterIni,;
cFilterFin,;
.T.,{{"OK","Ok"},{"CANCEL","Error"}},2,{{"Sucursal+Proceso+Fecha",1}}, cChave ,,,,,,,,,,,,,,,, ".F." )  //"Avisos"##"Erro de processamento"##"Data+Hora"##"Usuario+Data+Hora"

RestArea(aAreaAnt)
Return


//===================================================================================================================================
/*/{Protheus.doc} UltimaEjec
    Devuelve datos de la última ejecución de la rutina
    
    @type  Static Function
    @author Alejandro Perret
    @since 28/08/2019
    @version 1.0
    /*/
//===================================================================================================================================

Function UltimaEjec()

Local aArea := GetArea()
Local aRet 	:= {"  /  /  ", "  /  /  ", "N/A"}
Local cCont	:= AllTrim(GetMV(_PARAM_ULT_EJEC)) 

If Empty(cCont)
	DbSelectArea("SX6")
	DbSetOrder(1)
	If !MSseek(xFilial("SX6") + _PARAM_ULT_EJEC)
		PUTMV("MV_AGSISAU", _PARAM_ULT_EJEC)
	EndIf		
Else
	aRet := StrTokArr(cCont, _CTOKEN)
	If Len(aRet) < 3
		Aadd(aRet, " ")
		Aadd(aRet, " ")
	EndIf
	
EndIf

RestArea(aArea)
Return(aRet)