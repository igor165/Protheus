#INCLUDE "Protheus.ch"
#INCLUDE "GPEA450.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GPEA450   ³ Autor ³ Gpe Santacruz A       ³ Data ³ 06/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CALCULO DE SUA (ACTUALIZA TABLAS PARA SUA)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEA450()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ llam.³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Silvia Tag. ³30/08/11³TDPHIA³Correcao no campo RHF_DTMOV               ³±±
±±³R.Berti     ³28/10/11³TDW816³Corrig.error log qdo.emite no mes admis. e³±±
±±³            ³        ³      ³RCP_TPMOV=06(reingresso) p/func.s/Hist.ant³±±
±±³gsantacruz  ³17/10/11³CORR  ³Correcciones por validacion SUA (integral)³±±
±±³            ³18/10/11³Corr  ³Caso 3 Y 8                                ³±±
±±³gsantacruz  ³26/10/11³CORR  ³Tope de 7 dias a la suma de registros de  ³±±
±±³            ³        ³      ³RHE que son de  tipo Falta.               ³±±
±±³gsantacruz  ³18/11/11³CORR  ³En lo movs de baja se agregao el parametro³±±
±±³            ³        ³      ³de fecha en que inica y finaliza el movto.³±±
±±³gsantacruz  ³25/11/11³CORR  ³Cambio el algoritomo de obtener Faltas/In-³±±
±±³            ³        ³      ³capacidades.                              ³±±
±±³gsantacruz  ³01/12/11³CORR  ³Cambio el concepto 0538 por 0438          ³±±
±±³gsantacruz  ³09/12/11³CORR  ³Se corrige la rutina de SDI anterior.     ³±±
±±³gsantacruz  ³13/12/11³      ³Se corrige la rutina de SDI anterior.     ³±±
±±³            ³        ³      ³El calculo del RT se hace por los dias    ³±±
±±³            ³        ³      ³trabajados menos faltas menos incapacidade³±±
±±³gsantacruz  ³05/01/12³CORR  ³El factor de riesgo de la RCO cambio el   ³±±
±±³            ³        ³      ³dbseek de la filial para encontrarlo.     ³±±
±±³gsantacruz  ³10/01/12³CORR  ³El calculo de amortizacion de credito In- ³±±
±±³            ³        ³      ³fonavit.                                  ³±±
±±³gsantacruz  ³13/01/12³mej   ³Desconsiderar los movtos de la RCP que sea³±±
±±³            ³        ³      ³MS y el SDI sea el mismo.(Tope Salario)   ³±±
±±³gsantacruz  ³26/03/12³CORR  ³1er movto es 05, calculaba mal los dias   ³±±
±±³            ³        ³CORR  ³calculaba mal los dias del año biciesto   ³±±
±±³gsantacruz  ³03/04/12³Mej   ³El seguro de vivienda, solos e aplicara   ³±±
±±³            ³        ³      ³a la amortizacion de INFONAVIT una sola   ³±±
±±³            ³        ³      ³vez en el bimestre.                       ³±±
±±³gsantacruz  ³22/05/12³Corr  ³Se adiciono la etiqueta STR0074, se agre- ³±±
±±³            ³        ³      ³go instruccion FWModeAccess para VER11    ³±±
±±³R.Berti     ³13/09/12³TFTLRJ³Creacion del fuente GPEA450MEX;			  ³±±
±±³            ³        ³      ³Se corrije funciones para estaticas.	  ³±±
±±³ GSANTACRUZ ³10/09/12³TFSWXJ³ Se elimino  que envie al LOG de errores  ³±±
±±³            ³        ³      ³ empleados qu eno correponden a Reg Pat   ³±±
±±³M.Camargo   ³28/10/15³TTQUO9³Se elimina fuente GPEA450MEX quedando sola³±±
±±³            ³        ³      ³mente este fuente como el válido.         ³±±
±±³Alf. Medrano³15/01/16³PCREQ-³se modifica declaracion de Func.FchkCont  ³±±
±±³            ³        ³ 7944 ³se quita el Static se deja como Function  ³±±
±±³Marco Glz.  ³06/04/16³PCDEF2015 ³Se modifica declaracion de la Funcion ³±±
±±³            ³        ³_2016-3585³ gpRetSR9, se quita el Static y se    ³±±
±±³            ³        ³          ³ deja como Function.                  ³±±   
±±³Alf. Medrano³10/06/20³DMINA-9295³Se modifica fun Traduce(), se quitan  ³±±
±±³            ³        ³          ³ las comillas simples a los parametros³±±
±±³            ³        ³          ³ antes de ser asignadas nuevamente.   ³±±
±±³Marco Glz.  ³13/06/21³DMINA-    ³Se modifica la funcion GrbMvtoRCH,    ³±±
±±³            ³        ³     12350³ para evitar error log en la rutina.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEA450()

Local aSays			:={ }
Local aButtons		:= { }
Local aGetArea		:= GetArea()
Local nOpca 		:=0
Local cPerg			:="GPE450A"

Private aCodRpat	:= {}  
Private cCadastro 	:= STR0030  //"Calculo de SUA"
Private cMes:=''
Private cAnio:=''
Private cLisPat:=''
Private cLisReg:=''
Private cLisMat:=''
Private cLisSuc:=''
Private cMats:=''
Private cSucs:=''

Private dFecIni:=ctod("  /  /  ") //Fecha de inicio del mes que se calcula
Private dFecFin:=ctod("  /  /  ") //Fecha de final del mes que se calcula
Private lAutomato := isblind()

dbSelectArea("SRA")  
dbSelectArea("SRJ")  
dbSelectArea("RCO")  
dbSelectArea("SR8")  

dbSelectArea("RHB")  
dbSelectArea("RHC")  
dbSelectArea("RHD")  
dbSelectArea("RHE")  
dbSelectArea("RHF")  

dbSelectArea("RCP")  //Trayectoria laboral
DbSetOrder(1) //RCP_FILIAL+RCP_MAT+DTOS(RCP_DTMOV)+RCP_TPMOV

AADD(aSays,OemToAnsi(STR0031) ) //"Esta rutina hace los calculos necesario para formar las tablas de SUA"
AADD(aSays,OemToAnsi(STR0032) )//"Tomando como base la Trayectoria labora, el Historico de Credito INFONAVIT "
AADD(aSays,OemToAnsi(STR0070) )//"y el Ausentismo de cada Empleado."
AADD(aSays,OemToAnsi(STR0071) )//"Después de este proceso, se podran ejecutar los reportes Bimestral y Anual."

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(TodoOK(cPerg),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

If !lAutomato	
	FormBatch( cCadastro, aSays, aButtons )

	If nOpca == 1 //Ejecuta el proceso
		Processa({|| GPA450GERA() },OemToAnsi(STR0033)) //"Procesando..." 
	Endif
Else
	Pergunte(cPerg, .T.)
	If TodoOK(cPerg)
		GPA450GERA()
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
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TodoOK(cPerg)
Local nCont:=0                                     
Local nTamReg:= TamSX3("RCO_CODIGO")[1]

Pergunte(cPerg,.F.)

cMes	:= StrZero(Val(Left(MV_PAR01,2)),2)
cAnio	:= Right(MV_PAR01,4)
cLisReg	:= MV_PAR02
cLismat	:= AllTrim(MV_PAR03)
cMats	:= AllTrim(MV_PAR03)
cLisSuc	:= AllTrim(MV_PAR04)
cSucs	:= AllTrim(MV_PAR04)
   	
If Val(cMes)< 1 .Or. Val(cMes) > 12
	MsgInfo(STR0034) //"El mes debe ser de 1 a 12!"
	Return .f.
Endif	             

If Val(cAnio) < 1900
	Msginfo(STR0035)//"El año debe ser mayor a 1900!"
	Return .f.
Endif	             

If Empty(cLisReg)
	Msginfo(STR0036)//"Debe seleccionar al menos un registro patronal!"
	Return .f.
Endif	             

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Genera lista de registros patronales para usar despues en Query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLisPat:=""

For nCont := 1 To Len( cLisReg ) Step nTamReg       
	IF EMPTY(SubStr( cLisReg , nCont , nTamReg ))
	   EXIT
	ENDIF   
    cLisPat+="'"+SubStr( cLisReg , nCont , nTamReg )+"',"
Next       

cLisPat:=substr(cLisPat,1,len(cLisPat)-1)                                   

If !Empty(cLisMat)
    cLisMat:=Traduce(cLismat)
Endif

If !Empty(cLisSuc)
    cLisSuc:=Traduce(cLisSuc)
Endif

dFecIni := Ctod("01/"+ cmes+ "/" +Substr(cAnio,3,2)+"/")
dFecFin := Ctod(StrZero(f_UltDia(dFecIni),02)+ "/"+cMes+"/"+substr(cAnio,3,2))

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPA450GERA³ Autor ³ Gpe Santacruz         ³ Data ³06/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calculo del SUA                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CALSUAGERA                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA450                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPA450GERA()

Local aDias		:= {}
Local cQuery	:= ''
Local cAliasTmp	:= Criatrab(Nil,.f.)
Local cMat		:= ''
Local cMattmp	:= ''
Local cFiltRCP	:= ''

Local nMax		:=0
Local nx 		:= 0
Local nDiasCot	:= (dFecFin - dFecini) + 1                      
Local nPosSal	:=0
Local nValor	:=0
Local nUMA		:= 0  //Valor UMA (Tabla alfanumerica S006 - Salarios minimos)

Local lBiciesto	:= .T.

Private aSalAnt	:= {} //contiene el salario diario anterior
Private aFalInc	:= {} //contiene las faltas e incapacidades
Private aInfonavit:= {} //Contien los movtos de Infonavit.
Private aError	:= {} //Contiene los errores para el LOG

//Tipos de movimento que se usaran
Private cTipMovI:= '00'  	    //Movimiento de registro inicial
Private cTipMovA:= '01,03,06'    //01-Alta  03-Cambio por registro patronal  06-Reingreso
Private cTipMovB:= '02,04'       //02-Baja; 04-Baja por registro patronal
Private cTipMovM:= '05'         //Modificacion de salario

Private nTotEmp	:= 0
Private nTotMov	:= 0
Private nEmpPro	:= 0

Private nSMGDF 	:= 0    //Salario minimo general DF
Private nFac4	:= 0
Private nFac5	:= 0
Private nFac6	:= 0
Private nFac7	:= 0
Private nFac8	:= 0
Private nFac9	:= 0
Private nFac10	:= 0
Private nFac11	:= 0
Private nFac12	:= 0
Private nFac13	:= 0
Private nFac14	:= 0
Private nFac15	:= 0
Private nFac16	:= 0
Private nFac17	:= 0
Private nFac18	:= 0
Private nSec	:= 0
Private nDiasBim:= 0         
Private cFilRcp:=''  
Private cFilSRA:=''  
Private l1VezEmpInf:=.t. //Bandera para actualizar solo el 1er registro de infornavit del empleado aumentando los 15 dias de seguro de vivienda

RCO->(dBSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Elimina Movimientos de SUA que ya estuvieran generados para ese rango³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !BorraSUA()
   MsgAlert(STR0037)//"Proceso detenido, por errores en la limpieza de tablas. Verifique los errores"
   Return
Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Arma Filtros que se usaran en todas las querys ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cFiltRCP :=''
cFiltRCP += RangosDinamicos("RA")    
cFiltRCP += " AND (RA_SITFOLH <> 'D' OR  RA_DEMISSA>='"+DTOS(DfECINI)+"' ) "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Genera Salario diario anterior³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

GPA450SANT(cFiltRCP)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Genera faltas e incapacidades³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Gpa450FalInc(cFiltRCP)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Genera Infonavit             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                  
GPA450INFO(cFiltRCP)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleccion de Información Query principal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IncProc(STR0038)//"Seleccionando  Movimiento para SUA..."
                      
/* bajo esta premisa 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³NOTA:Cuando cambias a un empleado de sucursal, en la SRA te deja 2 registros, uno con cada sucursal uno activo y uno inactivo³
//³y en la trayectoria laboral igual                                                                                            ³
//³digamos que copia y pega, pero con la nueva sucursal                                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
cQuery := "SELECT   RA_FILIAL,RCP_FILIAL, RCP_MAT,RA_MAT,RCP_CODRPA,RCP_TPMOV, RCP_DTMOV,RCP_SALDII,RCP_SALIVC, "
cQuery += "  RA_TEIMSS,RA_TSIMSS,RA_TJRNDA, RA_NUMINF,RA_DTCINF,RA_TIPINF,RA_VALINF,RA_CODFUNC	,RA_HRSEMAN ,RA_CODRPAT,RA_ADMISSA "
cQuery += " FROM "+InitSqlname("SRA")+" SRA LEFT OUTER JOIN " + Initsqlname("RCP") + " RCP ON  "
cQuery += " RA_MAT=RCP_MAT and RA_FILIAL=RCP_FILIAL AND RCP.D_E_L_E_T_ = ' '"
cQuery += " AND RCP_DTMOV  BETWEEN '"+DTOS(dFecini)+"' AND '"+DTOS(dFecFin)+"' AND RCP_CODRPA IN("+CLISPAT+")  "+ RangosDinamicos("RCP")  
cQuery += " WHERE  "
cQuery += "   RA_ADMISSA <= '"+DTOS(dFecFin) + "' AND SRA.D_E_L_E_T_ = ' '  "
cQuery += cFiltRCP

cQuery += " ORDER BY  RA_MAT,RA_CODRPAT,RCP_MAT,RCP_CODRPA,RCP_DTMOV"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

TCSetField(cAliasTmp,"RCP_DTMOV","D")  
TCSetField(cAliasTmp,"RA_DTCINF","D")  
TCSetField(cAliasTmp,"RA_ADMISSA","D")  

Count TO nMax               

ProcRegua(nMax) // Número de registros a procesar

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Genera archivos de SUA                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF nMax>0
	IncProc(STR0039)//"Inicia generación de Movimiento para SUA..."
	//Salario minimo del DF
	nSMGDF :=IF ((FPOSTAB("S006","A","=",4))>0, FTABELA("S006",FPOSTAB("S006","A","=",4),5), 0)	
	nUMA   :=IF ((FPOSTAB("S006","U","=",4))>0, FTABELA("S006",FPOSTAB("S006","U","=",4),5), 0)	//Se graba el valor de la UMA ("U")
	//Prepara Factores
	nFac4 :=iif(!Empty(nValor := fTabela("S007",1,4)) ,nValor,0) 
	nFac5 :=iif(!Empty(nValor := fTabela("S007",1,5)) ,nValor,0)
	nFac6 :=iif(!Empty(nValor := fTabela("S007",1,6)) ,nValor,0)
	nFac7 :=iif(!Empty(nValor := fTabela("S007",1,7)) ,nValor,0)
	nFac8 :=iif(!Empty(nValor := fTabela("S007",1,8)) ,nValor,0)
	nFac9 :=iif(!Empty(nValor := fTabela("S007",1,9)) ,nValor,0)
	nFac10:=iif(!Empty(nValor := fTabela("S007",1,10)),nValor,0)
	nFac11:=iif(!Empty(nValor := fTabela("S007",1,11)),nValor,0)   
	nFac12:=iif(!Empty(nValor := fTabela("S007",1,12)),nValor,0)  
	nFac13:=iif(!Empty(nValor := fTabela("S007",1,13)),nValor,0) 
	nFac14:=iif(!Empty(nValor := fTabela("S007",1,14)),nValor,0)     
	nFac15:=iif(!Empty(nValor := fTabela("S007",1,15)),nValor,0)
	nFac16:=iif(!Empty(nValor := fTabela("S007",1,16)),nValor,0)  
	nFac17:=iif(!Empty(nValor := fTabela("S007",1,17)),nValor,0)      
	nFac18:=iif(!Empty(nValor := fTabela("S007",1,18)),nValor,0)
   
    If MOD(Val(cAnio),4) == 0
       lBiciesto :=.T.
    Endif  
    
	//Dias del bimestre   
    Do Case
       Case cMes == '01'
            nDiasBim := iif(lBiciesto,60, 59)
       Case cMes == '02'
            nDiasBim := iif(lBiciesto,60, 59)
       Case cMes == '03'
            nDiasBim := 61
       Case cMes == '04'
            nDiasBim := 61
       Case cMes == '05'
            nDiasBim := 61
       Case cMes == '06'
            nDiasBim := 61
       Case cMes == '07'
            nDiasBim := 62
       Case cMes == '08'
            nDiasBim := 62
       Case cMes == '09'
            nDiasBim := 61
       Case cMes == '10'
            nDiasBim := 61
       Case cMes == '11'
            nDiasBim := 61
       Case cMes == '12'
            nDiasBim := 61
    EndcAse
    
	cMatTmp := ''
Endif

(cAliasTmp)->(DbGoTop())

nMax:=0

Do While !(cAliasTmp)->(Eof())  
     if Empty((cAliasTmp)->RCP_MAT) 
        IF  !((cAliasTmp)->RA_CODRPAT $ CLISPAT)
	        (cAliasTmp)->(DBSKIP())
        ENDIF
     ENDIF   

	 l1VezEmpInf:= .t. 
	 cFilsra:=(cAliasTmp)->RA_FILIAL 
	 cMat := (cAliasTmp)->RCP_MAT 
 	 cPat := (cAliasTmp)->RCP_CODRPA
 	 
 	 IF  CVERSAO == '10'
 	 	cFilRcp:=IIF (EMPTY(CMAT),cFilsra,iif (EMPTY((cAliasTmp)->RCP_FILIAL),cfilsra,(cAliasTmp)->RCP_FILIAL))  //(cAliasTmp)->RCP_FILIAL
 	 ELSE	
	 	 cFilRcp:=IIF (EMPTY(CMAT),cFilsra,iif (FWModeAccess("RCP") == "C",cfilsra,(cAliasTmp)->RCP_FILIAL))  //(cAliasTmp)->RCP_FILIAL 	 
	 ENDIF	 
	 	 
     nSec := 1; cSecMov := '1'   

	//****  
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No considera los empleados que tiene MS en la RCP y³
	//³el SDI no cambio.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	lPasa:= .t.
	if Empty((cAliasTmp)->RCP_MAT)        
	   lPasa:= .f.
	else   
		IF (cAliasTmp)->RCP_TPMOV == cTipMovM         
    		nPosSal := aScan(aSalAnt,{|x| Alltrim(x[1]) == Alltrim(cMat).And. Alltrim(x[3]) == Alltrim(cPat)})
			If nPosSal == 0
				nEmpPro++
				AADD(aError,STR0040 + cMat +STR0074+dtoc((cAliasTmp)->RA_ADMISSA)+". "+ STR0041)//"Error, no encontro salarios anterior del empleado: " ## " Y no genero movimientos"
				RecorreSRA(cAliastmp,cMat,nMax,aDias[nx,5],"RCP")
				Exit
			Endif
			nSaldia:=aSalAnt[nPosSal,2]
			if (cAliasTmp)->RCP_SALDII==nSaldia
				lPasa:=.f.
			endif	
		ENDIF	
	endif	
	
   	if lPasa //Si hay movtos en RCP...
		aDias:=GenDias(cAliasTmp,cMat,cPat) //Mete todos los movimiento del empleado a un arreglo para su analisis    y los ordena por fecha 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Datos del arreglo aDias  : 	³
		//³1. Tipo de Movimiento 		³
		//³2. Fecha     		        ³
		//³3. Salario           		³
		//³4. Cod Puesto     	        ³
		//³5. RCP_CODRPA          		³
		//³6. RA_TEIMSS	     			³
		//³7. RA_TSIMSS   		        ³
		//³8. RA_TJRNDA           		³
		//³9. RA_NUMINF					³
		//³10. RA_DTCINF     		    ³
		//³11. RA_TIPINF          		³
		//³12. RA_VALINF 				³
		//³13. RCO_FATRSC    		    ³
		//³14. RA_HRSEMAN        		³
		//³14. RA_ADMISSA        		³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len(aDias)
			If nX == 1//Genera movimiento '00'
				If (aDias[nx,2] > dFecIni  .and. !aDias[nx,1]$'0106') .OR. ;
					(aDias[nx,2] >= dFecIni  .and. aDias[nx,1]$'02')     
					nPosSal := aScan(aSalAnt,{|x| Alltrim(x[1]) == Alltrim(cMat).And. Alltrim(x[3]) == Alltrim(cPat)})
					If nPosSal == 0
						nEmpPro++
						AADD(aError,STR0040 + cMat +STR0074+dtoc((cAliasTmp)->RA_ADMISSA)+". "+ STR0041)//"Error, no encontro salarios anterior del empleado: " ## "Fecha Admisión "##" Y no genero movimientos"
						RecorreSRA(cAliastmp,cMat,nMax,aDias[nx,5],"RCP")
						Exit
					Endif
					
					nSaldia:=aSalAnt[nPosSal,2]
					
					If nx == Len(aDias) // si no hay mas registros
						IF aDias[nx,1]=='02'
							GrbMvtoRCH(cSecMov,cTipMovI, cMat,DFECINI,nSalDia,aDias[nx,2]-dFecIni+1,  nSalDia,dFecIni,aDias[nx,2]-1,  aDias,nx,,nUMA)
						else
							GrbMvtoRCH(cSecMov,cTipMovI, cMat,DFECINI,nSalDia,aDias[nx,2]-dFecIni,  nSalDia,dFecIni,aDias[nx,2]-1,  aDias,nx,,nUMA)
						endif
					Else                     
					   IF aDias[nx,1]=='02' .OR. aDias[nx,1]=='05'
	   					   IF aDias[nx,1]=='02' 
							   GrbMvtoRCH(cSecMov,cTipMovI, cMat,DFECINI,nSalDia,aDias[nx,2]-dFecIni+1,nSalDia,dFecIni,aDias[nx+1,2]-1,aDias,nx,,nUMA)
							ELSE  //Si 05  <260312>                                                                                                                
								GrbMvtoRCH(cSecMov,cTipMovI, cMat,DFECINI,nSalDia,aDias[nx,2]-dFecIni,nSalDia,dFecIni,aDias[nx+1,2]-1,aDias,nx,,nUMA)
							ENDIF   
					   ELSE
							GrbMvtoRCH(cSecMov,cTipMovI, cMat,DFECINI,nSalDia,aDias[nx+1,2]-dFecIni,nSalDia,dFecIni,aDias[nx+1,2]-1,aDias,nx,,nUMA)
					   ENDIF	
					Endif
					nSec++;cSecMov:=ALLTRIM(str(nSec))
				Endif                                  
				
			Endif
			
			If aDias[nx,1] $ cTipMovA
				If nx == Len(aDias) // si no hay mas registros
					GrbMvtoRCH(cSecMov,aDias[nx,1], cMat,aDias[nx,2],aDias[nx,3],dFecFin-aDias[nx,2]+1     ,aDias[nx,3],aDias[nx,2],dFecFin,      aDias,nx,,nUMA)
				Else
					GrbMvtoRCH(cSecMov,aDias[nx,1], cMat,aDias[nx,2],aDias[nx,3],aDias[nx+1,2] -aDias[nx,2],aDias[nx,3],aDias[nx,2],aDias[nx+1,2],aDias,nx,,nUMA)
				Endif
			Else
				If aDias[nx,1] $ cTipMovB
				    if len(aDias)>1 .or. nx== len(adias)
						GrbMvtoRCH(cSecMov,aDias[nx,1], cMat,aDias[nx,2],aDias[nx,3],0,aDias[nx,3],	dFecIni,	aDias[nx,2],aDias,nx,,nUMA)  
					endif	
					
				Else
					If aDias[nx,1] == cTipMovM //modificacion de salario
						If nx == Len(aDias) // si no hay mas registros
							GrbMvtoRCH(cSecMov,aDias[nx,1],cMat,aDias[nx,2],aDias[nx,3],dFecFin-aDias[nx,2]+1       ,aDias[nx,3],aDias[nx,2],dFecFin       ,aDias,nx,,nUMA)
						Else                      
						   IF aDias[nx+1,1]==cTipMovM//Si el que sigue es modificacion de salario
	   							GrbMvtoRCH(cSecMov,aDias[nx,1], cMat,aDias[nx,2],aDias[nx,3],aDias[nx+1,2]-aDias[nx,2],aDias[nx,3],aDias[nx,2],aDias[nx+1,2],aDias,nx,,nUMA)
						   ELSE
								GrbMvtoRCH(cSecMov,aDias[nx,1], cMat,aDias[nx,2],aDias[nx,3],aDias[nx+1,2]-aDias[nx,2]+1,aDias[nx,3],aDias[nx,2],aDias[nx+1,2],aDias,nx,,nUMA)
						   ENDIF	
						Endif
					Endif
				Endif
			Endif
			nSec++;cSecMov:=ALLTRIM(str(nSec))
			nMax++
			IncProc(STR0042)//"Generando Movimiento para SUA..."
		Next
	Else 
		nPosSal:=aScan(aSalAnt,{|x| ALLTRIM(x[1])==ALLTRIM((cAliasTmp)->RA_MAT) .and. ALLTRIM(x[3])==ALLTRIM((cAliasTmp)->RA_CODRPAT)})
		If nPosSal==0
			//No hay en trayetoria y su actual registro patronal no esta dentro del rango seleccionado, entonces no envia error
		    if  (cAliasTmp)->RA_CODRPAT $ clispat
				AADD(aError,STR0040+(cAliasTmp)->RA_MAT +STR0074+dtoc((cAliasTmp)->RA_ADMISSA)+". "+STR0041)//"Error, no encontro salarios anterior del empleado: "## " Fecha Admisión " ##" Y no genero movimientos"
			endif
			nEmpPro++
			RecorreSRA(cAliastmp,(cAliasTmp)->RA_MAT,nmax,(cAliasTmp)->RA_CODRPAT,"SRA")
			
		Else//Cuando no hay ningun movimiento en el mes en la Trayectoria laboral
			nSaldia:=aSalAnt[nPosSal,2]
			GrbMvtoRCH(cSecMov,cTipMovI, (cAliasTmp)->RA_MAT,dFecIni,nSalDia,nDiasCot,nSalDia,dFecIni,dFecFin,,0,cAliasTmp,nUMA)
			nMax++
			IncProc(STR0042) //"Generando Movimiento para SUA..."
			(cAliasTmp)->(dbskip())
		Endif	
	Endif				      	
EndDo

(cAliasTmp)->(DbCloseArea())

if !lAutomato
	If nMax==0
	   msgInfo(STR0043)//"Proceso Finalizado! No encontro registros..."
	Else
		If Len(aError)>0
	 		MsgAlert(STR0044) //"Proceso finalizado, con errores generados"
	   		ImprimeLog()
	   	Else
			msgInfo(STR0045+CHR(13)+CHR(10)+transform(ntotemp,"999,999")+ STR0046+ CHR(13)+CHR(10)+transform(ntotmov,"999,999")+STR0047)   //"Proceso Finalizado con Exito! "  ## " Empleados y "## " Movimientos Generados para SUA"
	   	Endif
	Endif
Else
	If nMax == 0
	   CONOUT(STR0043)//"Proceso Finalizado! No encontro registros..."
	Else
		If Len(aError) > 0
	 		CONOUT(STR0044) //"Proceso finalizado, con errores generados"
	   	Else
			CONOUT(STR0045+CHR(13)+CHR(10)+transform(ntotemp,"999,999")+ STR0046+ CHR(13)+CHR(10)+transform(ntotmov,"999,999")+STR0047)   //"Proceso Finalizado con Exito! "  ## " Empleados y "## " Movimientos Generados para SUA"
	   	Endif
	Endif
Endif

Return                  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GrbMvtoRCH³ Autor ³ Gpe Santacruz         ³ Data ³10/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Graba movimientos de SUA y Empleados SUA                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GrbMvtoRCH(cExp1,cExp2,cExp3,dExp1,nExp1,nExp2,nExp3,dExp2 ³±±
±±³          ³               dExp2,dExp3,aExp1,nExp4,xExp4)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  											              ³±±
±±³          ³ cExp1.-Consecutivo del movimiento por empleado             ³±±
±±³          ³ cExp2.-Tipo de movimiento a grabar                         ³±±
±±³          ³ cExp3.-Matricula del empleado                              ³±±
±±³          ³ dExp4.-Fecha del movimiento                                ³±±
±±³          ³ nExp5.-Salario diario                                      ³±±
±±³          ³ nExp6.-Numero de dias cotizados                            ³±±
±±³          ³ nExp7.-Salario Infonavit                                   ³±±
±±³          ³ dExp8.-Fecha de inicia del movimiento                      ³±±
±±³          ³ dExp9.-Fecha de fin del movimiento                         ³±±
±±³          ³ aExp10.-Arreglo de dias por empleado por segmento          ³±±
±±³          ³ nExp11.-Posicion actual en aExp1                           ³±±
±±³          ³ cExp12.-Alias                                              ³±±
±±³          ³ cExp13.-UMA (Tabla S006)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA450                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GrbMvtoRCH(cSecMov,cTipMov, cMat,dFecMov,nSalDia,nDiasCot,nSalIvc,dFecI,dFecF,;
							aDias,nP,cAliasTmp,nUMA)

Local aDiaAus	:= {0,0}
Local cDescSRJ	:= ''
Local cCodFunc	:= ''
Local cCodPat	:= ''
Local cTeIMSS	:= ''
Local cTsIMSS	:= ''
Local cTJRnda	:= ''
Local cNumINF	:= ''
Local cTipInf	:= ''
Local nFATRSC	:= 0
Local cHRSeman	:= ''
Local cTPMInf	:= ''

Local nDBC2		:= 0
Local nDBC3		:= 0
Local nDBC1		:= 0
Local nBase		:= 0
Local nPos		:= 0
Local nDias		:= 0
Local nVALINF	:= 0
Local nRegRHD	:= 0
Local nUlt		:= 0

Local dDTCINF	:= Ctod("  /  /  ")
Local dFecMI 	:= Ctod("  /  /  ")
Local dFecAdm   := Ctod("  /  /  ")

Local lClona	:= .F. 
Local lInicial	:= .F.
Local lGenRHD	:= .F.

Default cAliasTmp:=''
Default nUMA	:= 0

If Empty(cAliasTmp)
	cCodFunc	:= aDias[np,4]
	cCodPat		:= aDias[np,5]
	cTEIMSS		:= aDias[np,6]
	cTSIMSS		:= aDias[np,7]
	cTJRNDA		:= aDias[np,8]
	cNumInf		:= aDias[np,9]
	dDTCInf		:= aDias[np,10]
	cTIPInf		:= aDias[np,11]
	nVALInf		:= aDias[np,12]
	nFATRSC		:= aDias[np,13]
	cHRSeman	:= aDias[np,14]     
	dFecAdm		:=aDias[np,15] 
Else
	cCodFunc:=(cAliasTmp)->RA_CODFUNC
	cCodPat:=(cAliasTmp)->RA_CODRPAT
	cTeIMSS:=(cAliasTmp)->RA_TEIMSS
	cTsIMSS:=(cAliasTmp)->RA_TSIMSS
	cTJRNDA:=(cAliasTmp)->RA_TJRNDA
	cNumInf:=(cAliasTmp)->RA_NUMINF
	dDTCInf:=(cAliasTmp)->RA_DTCINF
	cTIPInf:=(cAliasTmp)->RA_TIPINF
	nVALInf:=(cAliasTmp)->RA_VALINF
	cHRSeman:=(cAliasTmp)->RA_HRSEMAN
	dFecAdm:=(cAliasTmp)->RA_ADMISSA
	nFATRSC:=0
	
	If RCO->(DbSeeK(xFilial("RA_FILIAL" , (cAliasTmp)->RA_FILIAL)+(cAliasTmp)->RA_CODRPAT))
		nFATRSC:=RCO->RCO_FATRSC
	Endif
Endif

If nDiasCot>0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Busca faltas e incapacidades³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	aDiaAus:=GPA450FI(cCodPat,cMat,dFecI,dFecF)
Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Graba Empleados SUA³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
If 	cSecMov=='1'          
	nTotEmp++	
	nEmpPro++
    cDescSRJ:=STR0048 //"No existe"
    
    SRJ->(DbSetOrder(1))
    IF SRJ->(DbSeek(xFilial("SRJ")+cCODFunc)) 
	    cDescSRJ := SRJ->RJ_DESC	   
	Else
	    Aadd(aError,STR0049 +" "+ cCODFUNC +" "+ STR0050 + " "+cMat)   //"Error, No encontro puesto "##" para el empleado :"
	Endif
	    
	Reclock("RHD",.T.) 
	RHD->RHD_FILIAL	:= CFILRCP
	RHD->RHD_MAT	:= cMat   
	RHD->RHD_ANOMES	:= cAnio+cMes
	RHD->RHD_CODRPA	:= cCodPat
	RHD->RHD_TEIMSS	:= cTEIMSS
	RHD->RHD_TSIMSS	:= cTSIMSS
	RHD->RHD_TJRNDA	:= cTJRNDA
	RHD->RHD_SDI	:= nSalDia
	RHD->RHD_ADMISS	:= dFecAdm

	//revisar si estas actualizaciones cambiaron en el nuevo docto.
	RHD->RHD_FATRSC	:= nFATRSC	
	RHD->RHD_DESCFUN:= cDescSRJ
	RHD->RHD_HRDIA	:= If(cTJRNDA=='6',(cHRSEMAN/7), 8 )

	RHD->(MSUNLOCK())
    nRegRHD:=RHD->(RECNO())
Endif

//Calculos de dias para los movimientos del SUA

nDBC2 := nDiasCot - aDiaAus[2]
nDBC3 := nDiasCot - aDiaAus[1]    
nDBC1 := nDiasCot -  aDiaAus[2]- aDiaAus[1]    
nBase := If(nSalDia > (3 * nUMA), (nSalDia - (3 * nUMA)), 0)    //????

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca movimientos de INFONAVIT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Infonavit
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³aInfonavit:                        ³
//³1-Bandera de si ya esta en RCH o no³
//³2-Registro patronal                ³
//³3-Matricula                        ³
//³4-Fecha de movto.                  ³
//³5-TPMINF                           ³
//³6-TIPINF                           ³
//³7-VALINF                           ³
//³8-NUMINF                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nPos:=aScan(aInfonavit,{|x|  ALLTRIM(x[3])==ALLTRIM(cMat) .and. ALLTRIM(x[2])==ALLTRIM(cCodPat) .and. x[1]=='1' })

If nPos==0
	Reclock("RHC",.T.)
	RHC->RHC_FILIAL	:=CFILRCP
	RHC->RHC_MAT	:= cMat
	RHC->RHC_ANOMES	:= cAnio + cMes
	RHC->RHC_SEQMVT	:= cSecMov
	RHC->RHC_CODRPA	:= cCodPat
	RHC->RHC_TPMOV	:= cTipMov
	RHC->RHC_DTMOV	:= dFecMov
	RHC->RHC_SALDII	:= nSalDia
	RHC->RHC_SALIVC	:= nSalIvc
	RHC->RHC_NDTRAB	:= nDiasCot
	RHC->RHC_NDINC	:= aDiaAus[2]
	RHC->RHC_NDFAL	:= aDiaAus[1]
	RHC->RHC_CFPAT  := nFac4 / 100 * nUMA  * nDBC2
	RHC->RHC_EXEPAT := nFac5 / 100 * nBase * nDBC2
	RHC->RHC_EXETRA := nFac6 / 100 * nBase * nDBC2
	RHC->RHC_PDPAT  := nFac7 / 100 * nSalDia * nDBC2
	RHC->RHC_PDTRA  := nFac8 / 100 * nSalDia * nDBC2
	RHC->RHC_GMPPAT := nFac9 / 100 * nSalDia * nDBC2
	RHC->RHC_GMPTRA := nFac10/ 100 * nSalDia * nDBC2
	RHC->RHC_RTPAT  := nFATRSC/100 * nSalDia * nDBC1
	RHC->RHC_IVPAT  := nFac11/100 * nSalDia * nDBC1
	RHC->RHC_IVTRA  := nFac12/100 * nSalDia * nDBC1
	RHC->RHC_GPSPAT := nFac13/100 * nSalDia * nDBC1
	RHC->RHC_RETPAT := nFac14/100 * nSalDia * nDBC3
	RHC->RHC_CYVPAT := nFac16/100 * nSalDia * nDBC1
	RHC->RHC_CYVTRA := nFac17/100 * nSalDia * nDBC1
	RHC->RHC_INFONA := nFac15/100 * nSalDia * nDBC3
	RHC->(MsUnLock())
Else   
	lClona 	:= .F.
	lGenRHD	:= .F.
	lGenRHC	:= .T.
	
	cTIPINF	:= ''
	NVALINF	:= 0
	cNUMINF	:= ''
	dFecMI 	:= ctod("  /  /  ")
	cTPMINF	:= ''
	
	lInicial:= .F.
	nUlt:=0

	Do While nPos <= Len(aInfonavit) .and.  AllTrim(aInfonavit[nPos,3])==Alltrim(cMat) .and. Alltrim(aInfonavit[npos,2])==Alltrim(cCodPat)  .and. aInfonavit[npos,4]<= dFecF
				 
 		If aInfonavit[npos,4]<= dFecI 
 			If aInfonavit[npos,4]< dFecIni //Solo si el movimiento es menor que el inicio del periodo 
				lGenRHD:=.t.
  			Endif	    

			If nPos == Len(aInfonavit) .Or. aInfonavit[nPos+1,2] <> cCodPat .or. aInfonavit[nPos+1,3]<>cMat //Si, no hay mas registros
				aDiaAus := Gpa450FI(cCodPat,cMat,dFecI,dFecF)  
				nDias := dFecF-dFecI + 1 - aDiaAus[1]      		       		
       		Else                                                          
				dDS := aInfonavit[nPos + 1,4 ]
				If aInfonavit[npos+1,4] > dFecF
					dDS := dFecF + 1
				Endif       

				aDiaAus := GPA450FI(cCodPat,cMat,dFecI,dDS)  
				nDias := dDS - dFecI - aDiaAus[1]
			Endif

			If aInfonavit[nPos,5] == '16' //suspension
				nAmort	:= 0
				cTipInf	:= aInfonavit[npos,6]
				nValInf	:= aInfonavit[npos,7]
				cNumInf	:= aInfonavit[npos,8]
				dFecMI 	:= ctod("  /  /  ")
				cTPMInf	:= ''
			Else
				cTipInf	:=	aInfonavit[nPos,6]
				nValInf	:=	aInfonavit[nPos,7]
				nAmort	:=	GPA450Amt(cTipInf,nValInf,nSalDia,dDTCInf,nDias,cmat,cfilsra,cfilrcp)
				cNumInf	:=	aInfonavit[nPos,8]
				
				If aInfonavit[nPos,4]== dFecI
					dFecMI :=aInfonavit[nPos,4]
					cTPMINF:=aInfonavit[nPos,5]
				Endif
			Endif
		Else
			lClona:=.t.
			lBan:= .t.
			If nPos == Len(aInfonavit) .or. aInfonavit[nPos+1,2] <> cCodPat .or. aInfonavit[nPos+1,3] <> cMat //Si, no hay mas registros
				If dFecF == dFecFin .and. dFecI==dFecIni .and. lGenRHC .and. (aInfonavit[nPos,5]=='17' .or. aInfonavit[nPos,5] == '15')
					aDiaAus := GPA450FI(cCodPat,cMat,dFecI,aInfonavit[nPos,4])
					nDias := aInfonavit[nPos,4]-dFecI-aDiaAus[1]
					
					dFecMI := ctod("  /  /  ")
					cTPMINF := ''
					nAmort := GPA450Amt(cTipInf,nValInf,nSalDia,dDTCInf,nDias,cmat,cfilsra,cfilrcp)
					If aInfonavit[nPos,5]=='15'
						cTipInf := ""
						nValInf := 0
						cNumInf := ""
					Endif
					//nPos--
					lClona := .F.
					lBan := .F.
				Else
					aDiaAus:=GPA450FI(cCodPat,cMat,aInfonavit[nPos,4],dFecF)
					nDias:=dFecF-aInfonavit[nPos,4]+1-aDiaAus[1]
				Endif
			Else
				dDS	:=	aInfonavit[nPos + 1,4]
				If aInfonavit[nPos+1,4] > dFecF
					dDS	:= dFecF + 1
				Endif
				aDiaAus := GPA450FI(cCodPat, cMat, aInfonavit[nPos,4],dDS )
				nDias := dDS - aInfonavit[nPos,4]- aDiaAus[1]
			Endif
									      		      
			If aInfonavit[nPos,5 ] == '16' //suspension
				nAmort := 0
				
				cTipInf := aInfonavit[nPos,6]
				nValInf := aInfonavit[nPos,7]
				cNumInf := aInfonavit[nPos,8]
				dFecMI  := aInfonavit[nPos,4]
				cTpMINF := aInfonavit[nPos,5]
			Else
				If lBan
					nAmort	:= GPA450Amt(cTipInf,nValInf,nSalDia,dDTCINF,nDias,cmat,cfilsra,cfilrcp)
					dFecMI 	:= aInfonavit[nPos,4]
					cTPMINF	:= aInfonavit[nPos,5]
					
					cTipInf	:= aInfonavit[nPos,6]
					nValInf	:= aInfonavit[nPos,7]
					cNumInf	:= aInfonavit[nPos,8]
				Endif
			Endif
		Endif   
						
		If nRegRHD > 0 .And. lGenRHD
		    RHD->(DbGoTo(nRegRHD))
		    If !RHD->(Eof())           
		        RECLOCK("RHD",.F.)
				RHD->RHD_NUMINF := cNumInf
				RHD->RHD_TIPINF := cTipInf	
				RHD->RHD_VALINF := nValInf
				RHD->RHD_DTCINF := dDTCInf
				RHD->(MSUNLOCK())      
				lGenRHD:=.f.
			Endif	
		Endif		
		If lGenRHC
			Reclock("RHC",.T.)
			RHC->RHC_FILIAL	:= CFILRCP
			RHC->RHC_MAT   	:= cMat
			RHC->RHC_ANOMES	:= cAnio+cMes
			RHC->RHC_SEQMVT	:= cSecMov
			RHC->RHC_CODRPA	:= cCodPat
			RHC->RHC_TPMOV	:= cTipMov
			RHC->RHC_DTMOV	:= dFecMov
			RHC->RHC_SALDII	:= nSalDia
			RHC->RHC_SALIVC	:= nSalIvc
			RHC->RHC_NDTRAB	:= nDiasCot
			RHC->RHC_NDINC	:= aDiaAus[2]
			RHC->RHC_NDFAL	:= aDiaAus[1]
			RHC->RHC_CFPAT  := nFac4 / 100 * nUMA  * nDBC2
			RHC->RHC_EXEPAT := nFac5 / 100 * nBase * nDBC2
			RHC->RHC_EXETRA := nFac6 / 100 * nBase * nDBC2
			RHC->RHC_PDPAT  := nFac7 / 100 * nSalDia * nDBC2
			RHC->RHC_PDTRA  := nFac8 / 100 * nSalDia * nDBC2
			RHC->RHC_GMPPAT := nFac9 / 100 * nSalDia * nDBC2
			RHC->RHC_GMPTRA := nFac10 / 100 * nSalDia * nDBC2
			RHC->RHC_RTPAT  := nFATRSC/ 100 * nSalDia * nDBC1
			RHC->RHC_IVPAT  := nFac11 / 100 * nSalDia * nDBC1
			RHC->RHC_IVTRA  := nFac12 / 100 * nSalDia * nDBC1
			RHC->RHC_GPSPAT := nFac13 / 100 * nSalDia * nDBC1
			RHC->RHC_RETPAT := nFac14 / 100 * nSalDia * nDBC3
			RHC->RHC_CYVPAT := nFac16 / 100 * nSalDia * nDBC1
			RHC->RHC_CYVTRA := nFac17 / 100 * nSalDia * nDBC1
								
			If lClona
				RHC->RHC_AMORCF :=0
				RHC->RHC_INFONA := nFac15 / 100 * nSalDia * nDias
			Else
				RHC->RHC_AMORCF :=nAmort
				RHC->RHC_INFONA := nFac15/100*nSalDia*nDias
				RHC->RHC_TPMINF  :=cTPMINF
				RHC->RHC_DTMINF  :=dFecMI
				RHC->RHC_NUMINF  :=cNUMINF
				RHC->RHC_TIPINF  :=cTIPINF
				RHC->RHC_VALINF  :=nVALINF
			Endif
			RHC->(MsUnLock())
	   	    lGenRHC:=.f.
		Endif
	
		If lClona
			nSec++;cSecMov:=ALLTRIM(str(nSec))
			Reclock("RHC",.T.)
			 RHC->RHC_FILIAL  :=CFILRCP
			RHC->RHC_MAT     := cMat
			RHC->RHC_ANOMES  := cAnio + cMes
			RHC->RHC_SEQMVT  := cSecMov
			RHC->RHC_CODRPA  := cCodPat
			RHC->RHC_TPMOV   := cTipMov
			RHC->RHC_DTMOV   := dFecMov
			RHC->RHC_SALDII  := nSalDia
			RHC->RHC_SALIVC	 := nSalIvc
			RHC->RHC_NDTRAB  := 0
			RHC->RHC_AMORCF  := nAmort
			RHC->RHC_INFONA  := nFac15 / 100 * nSalDia * nDias
			RHC->RHC_TPMINF  := cTPMINF
			RHC->RHC_DTMINF  := dFecMI
			RHC->RHC_NUMINF  := cNumInf
			RHC->RHC_TIPINF  := cTipInf
			RHC->RHC_VALINF  := nValInf
			RHC->(MSUNLOCK())
		Endif
		
		nUlt := nPos
		aInfonavit[nPos,1] := "0"
		nPos++
	EndDo

	If nUlt == 0
		nUlt := nPos
	Endif

	aInfonavit[nUlt,1]:="1"

	If nPos <= Len(aInfonavit) 
	   If aInfonavit[nPos,4] == dFecF+1 .And. Alltrim(aInfonavit[nPos,3])==Alltrim(cMat) .and. Alltrim(aInfonavit[nPos,2])==Alltrim(cCodPat)  
			aInfonavit[nUlt,1] := "0"
	      	aInfonavit[nPos,1] := "1"
	   Endif
	Endif 
Endif
//  Aqui Termina Seccion de calculo de infonavit
nTotmov++

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPA450Amt ³ Autor ³ Gpe Santacruz         ³ Data ³16/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calculo de amortizacion de INFONAVIT                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPA450Amt(cExp1,nExp1,nExp2,dExp1,nExp3)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  											              ³±±
±±³          ³ cExp1.-Tipo de credito INFONAVIT                           ³±±
±±³          ³ nExp1.-Valor del descuento credito INFONAVIT               ³±±
±±³          ³ nExp2.-Salario Diario del empleado                         ³±±
±±³          ³ dExp1.-Fecha del movimiento INFONAVIT                      ³±±
±±³          ³ nExp3.-Dias de Infonavit                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GrbMvtoRCH                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static function GPA450Amt(cTipInf,nValInf,nSalDia,dFecMI,nDias,cmat,cfilsra,cfilrcp)
Local nAmortiza:=0
Local nAux01:=0
Local nAux02:=0   
Local nPorc:=0
Local nRegTmp:=0
Local cMesAnt:= strzero(val(cMes)-1,2)
Do Case
	Case cTipInf=='1'
	     nPorc := nValInf/100
	     If dFecMI < ctod("30/01/1998")
		     nAux01 := nSalDia / nSMGDF
		     nAux02 := fPosTab("S019",nAux01,"<",5)
		     Do Case
		        Case nValInf == 20
		        	nPorc := IF(nAux01 > 0, fTabela("S019",nAux01,6), 0)
		        Case nValInf == 25
		         	nPorc := IF(nAux01 > 0, fTabela("S019",nAux01,7), 0)
		        Case nValInf == 30
		         	nPorc := IF(nAux01 > 0, fTabela("S019",nAux01,8), 0)
		     EndCase
		 Endif     
	     nAmortiza := nPorc * nSalDia * nDias
	Case cTipInf == '2'     
	     nAmortiza := (nValInf * 2 / nDiasBim) * nDias
   	Case cTipInf == '3'
	     nAmortiza :=(nValInf * nSMGDF * 2 / nDiasBim) * nDias
EndCase         


if l1VezEmpInf                  
	//nAmortiza += ROUND ((nFac18 / nDiasBim) * nDias,0)
	IF  cMes $ "01/03/05/07/09/11" //Si es el mes uno del bimestre
		nAmortiza += nFac18
	else  //Si calcula el segundo mes del bimestre, verifica que no exista ya un registro del mes pesado, si existe no agrega el 15 de seguro de vivienda
	   nRegTmp:=RHC->(RECNO())
	   RHC->(DBSETORDER(2))     

	   IF !RHC->(dbSeek(cFilRcp+cMat + cAnio + cMesAnt)) 
		   	nAmortiza += nFac18
	   ENDIF	   	           
   	   RHC->(DBGOTO(nRegTmp))
	endif	
    l1VezEmpInf:= .f.
endif	

Return nAmortiza

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GenDias     Autor ³ Gpe Santacruz         ³ Data ³10/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Genera un arreglo de los movimientos, por Empleado         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GenDias(cExp1,cExp2,cExp3)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.-Alias                                               ³±±
±±³          ³ cExp2.-Nombre del alias del query principal                ³±±
±±³          ³ cExp3.-Matricula del empleado                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GrbMvtoRCH                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GenDias (caliasTmp,CMAT,cRPat)

Local aD		:= {}   
Local nFATRSC	:= 0

RCO->(DbSetOrder(1))

Do While !(cAliasTmp)->(Eof()) .and. ALLTRIM(cRPat)==alltrim((cAliasTmp)->RCP_CODRPA) .and. alltrim(cMat)==alltrim((cAliasTmp)->RCP_MAT)
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Datos del arreglo aDias  : 	³
	//³1. Tipo de Movimiento 		³
	//³2. Fecha     		        ³
	//³3. Salario           		³
	//³4. Cod Puesto     	        ³
	//³5. RCP_CODRPA         		³
	//³6. TRA_TEIMSS				³
	//³7. RA_TSIMSS   		        ³
	//³8. RA_TJRNDA           		³
	//³9. RA_NUMINF					³
	//³10. RA_DTCINF     		    ³
	//³11. RA_TIPINF          		³
	//³12. RA_VALINF 				³
	//³13. RCO_FATRSC    		    ³
	//³14. RA_HRSEMAN        		³
	//³15. RA_ADMISSA        		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
//    If RCO->(DbSeek(xFilial("RA_FILIAL" ,(cAliasTmp)->RA_FILIAL)+(cAliasTmp)->RCP_CODRPA))
      If RCO->(DbSeek(xFilial("RCP_FILIAL" ,(cAliasTmp)->RCP_FILIAL)+(cAliasTmp)->RCP_CODRPA)) //ANTES CFILRCP
		nFATRSC := RCO->RCO_FATRSC
    Endif
    		
    AADD(aD,{(cAliasTmp)->RCP_TPMOV,(cAliasTmp)->RCP_DTMOV,(cAliasTmp)->RCP_SALDII,(cAliasTMP)->RA_CODFUNC,(cAliasTMP)->RCP_CODRPA,;
    		  (cAliasTMP)->RA_TEIMSS,(cAliasTMP)->RA_TSIMSS,(cAliasTMP)->RA_TJRNDA, (cAliasTMP)->RA_NUMINF,(cAliasTMP)->RA_DTCINF,;
    		  (cAliasTMP)->RA_TIPINF,(cAliasTMP)->RA_VALINF,nFATRSC,IF ((cAliasTMP)->RA_TJRNDA=='6',((cAliasTMP)->RA_HRSEMAN/7),8),(cAliasTMP)->RA_ADMISSA	})
    		  
   (cAliasTmp)->(DbSkip())
EndDo

Return aD

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o     GPA450SANT  Autor ³ Gpe Santacruz         ³ Data ³10/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Genera arreglo con el Salario Diario previo al mes de      ³±±
±±³          ³ calculo.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPA450SANT (cExp1 )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.-Filtro de caurdo al query principal                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPA450GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


Static function GPA450SANT(cFiltRCP)
     
Local cQuery	:= ''
Local cAliasSal	:= criatrab(nil,.f.)
local cMat		:= ''
Local cRpat		:= ''
Local nMax		:= 0
Local dFecTmp	:=ctod("  /  /  ")
Local nPos		:=0
IncProc(STR0051) //"Generando Salario Diario Anterior..."

cQuery := "SELECT RCP_SALDII, RCP_MAT,RCP_SALIVC,RCP_CODRPA,RCP_DTMOV "
cQuery += " FROM "+ initsqlname("RCP") + " RCP," +initsqlname("SRA") + " SRA  WHERE  "
cQuery += " RA_MAT=RCP_MAT and RA_FILIAL=RCP_FILIAL "
cQuery += " AND RCP_DTMOV  < '"+DTOS(dFecini)+"'  "
cQuery += cFiltRCP										
cQuery += "  AND RCP_CODRPA IN ("+CLISPAT+") "
cQuery += " AND  RCP.D_E_L_E_T_ = ' '  AND  SRA.D_E_L_E_T_ = ' '" 
cQuery += " ORDER BY RCP_CODRPA,RA_MAT,RCP_DTMOV ASC "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSal,.T.,.T.)
TCSetField(cAliasSal,"RCP_DTMOV","D")  
COUNT TO nMax               

ProcRegua(nMax) // Número de registros a procesar

If nMax==0
    Aadd(aError,STR0052)//"No existen registros para Salarios (RCP) previos al periodo!."
Endif

(cAliasSal)->(DbGoTop())
nMax:=0

aSalAnt:={}

Do While !(cAliasSal)->(Eof())
  // AADD(aSalAnt,{(cAliasSal)->RCP_MAT ,(cAliasSal)->RCP_SALDII,(cAliasSal)->RCP_CODRPA})
   cMat :=(cAliasSal)->RCP_MAT 
   cRPat:=(cAliasSal)->RCP_CODRPA
	dFecTmp:=ctod("  /  /  ")
   Do While !(cAliasSal)->(Eof())  .AND. alltrim(cRPat)==alltrim((cAliasSal)->RCP_CODRPA) .AND. alltrim(cMat)==alltrim((cAliasSal)->RCP_MAT )
       if (cAliasSal)->RCP_DTMOV> dFecTmp  
	       if (nPos:=aScan(aSalAnt,{|x|  Alltrim(x[1]) == Alltrim((cAliasSal)->RCP_MAT) .AND. Alltrim(x[3]) == Alltrim((cAliasSal)->RCP_CODRPA)  }))==0
			    AADD(aSalAnt,{(cAliasSal)->RCP_MAT ,(cAliasSal)->RCP_SALDII,(cAliasSal)->RCP_CODRPA})
		    ELSE      
			    aSalAnt[npos,2]:=(cAliasSal)->RCP_SALDII
		    ENDIF	    
		    dFecTmp:=(cAliasSal)->RCP_DTMOV
       endif
	 	nMax++                                                                            
	    IncProc(STR0053) //"Generando Salario Diario Anterior..."
	   (cAliasSal)->(dbSkip())
   EndDo	   
Enddo

(cAliasSal)->(dbclosearea())

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    GPA450FALINC       ³ Gpe Santacruz         ³ Data ³10/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Genera arreglo Faltas e Incapacidades, y guarda en la      ³±±
±±³          ³ tabla del mismo (RHE)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPA450FALINC (cExp1 )                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.-Filtro de acurrdo al query principal                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPA450GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GPA450FALINC(cFiltSR8)

Local cQuery	:= ''
Local cAliasSR8	:= criatrab(nil,.f.)
Local nMax		:=0                   
Local aDFalta:={}  //Registros de tipo falta, para controlar el tope de 7 dias en la tabla RHE
Local nx:=0
Local aRHE:={} //Registros previos a grabar en rhe
Local cLlave:=''


aDFalta:=aSort(aDFalta,,,{|x,y| x[1]+x[2] <= y[1]+y[]})	 //registro patronal, matricula 
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selecciona Faltas e Incapacidades
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
IncProc(STR0054) //"Seleccionando Faltas e Incapacidades..."

ProcRegua(0) // Inicio de barra de avance

cQuery := "SELECT R8_FILIAL,R8_MAT,R8_DATAINI,R8_DATAFIM,R8_NCERINC,R8_CODRPAT,R8_DURACAO,R8_TIPOAFA,R8_PRORSC,R8_CONTINC,R8_TIPORSC,R8_DNAPLIC,RCM_TPIMSS,R8_RESINC,RV_CODFOL "
cQuery += " FROM "+initsqlname("SRA") + " SRA, "+ initsqlname("SR8") + " SR8, "+initsqlname("RCM") + " RCM, "+initsqlname("SRV") + " SRV "
cQuery += " WHERE RA_MAT=R8_MAT AND RA_FILIAL = R8_FILIAL  "

cQuery += " AND (R8_DATAINI BETWEEN  '"+DTOS(dFecini)+"' AND '"+DTOS(dFecFin)+"' or R8_DATAFIM BETWEEN  '"+DTOS(dFecini)+"' AND '"+DTOS(dFecFin)+"'  "
cQuery += " OR R8_DATAINI <  '"+DTOS(dFecini)+"' AND R8_DATAFIM >'"+DTOS(dFecini)+"')  " //Si es una ausencia que inicia antes del mes seleccionado y termina despues del mes seleccionado
cQuery += " AND R8_DURACAO > 0 "
cQuery += " AND	R8_TIPOAFA = RCM_TIPO AND RCM_FILIAL='"+XFILIAL("RCM")+"' AND RCM_TPIMSS IN ('1','2')  "
cQuery += " AND	RV_COD=R8_PD AND RV_FILIAL='"+XFILIAL("SRV")+"' "
cQuery += cFiltSR8   //FILTRO DEL RANGO DE EMPLEADOS, FILIALES Y EMPLEADOS ACTIVOS 
cQuery += " AND R8_CODRPAT IN ("+CLISPAT+") "
cQuery += " AND  SR8.D_E_L_E_T_ = ' ' AND  SRA.D_E_L_E_T_ = ' ' AND  RCM.D_E_L_E_T_ = ' ' AND  SRV.D_E_L_E_T_ = ' ' "
cQuery += " order by   R8_CODRPAT, R8_MAT, R8_DATAINI, RCM_TPIMSS  "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSR8,.T.,.T.)
TCSetField(cAliasSR8,"R8_DATAINI","D")
TCSetField(cAliasSR8,"R8_DATAFIM","D")
COUNT TO nMax
ProcRegua(nMax) // Número de registros a procesar

(cAliasSR8)->(dbgotop())
nMax:=0
aFalInc:={}
Do While !(cAliasSR8)->(Eof())                    
	
//**********************           
    cLlave:=(cAliasSR8)->R8_FILIAL+(cAliasSR8)->R8_CODRPAT+cAnio+cMes+(cAliasSR8)->R8_MAT
	Do While !(cAliasSR8)->(Eof()) .AND. cLlave==(cAliasSR8)->R8_FILIAL+(cAliasSR8)->R8_CODRPAT+cAnio+cMes+(cAliasSR8)->R8_MAT                   
       if empty((cAliasSR8)->R8_NCERINC) .and. (cAliasSR8)->RCM_TPIMSS == '2'
	       AADD(aError,STR0072+(cAliasSR8)->R8_MAT)//"Error: Tiene incapacidades sin folio, y no se procesaron algunos registros del empleado :"
       else
	    
	     cRama:=''
		 Do Case
					Case (cAliasSR8)->RV_CODFOL == '0439'  //	Riesgo de Trabajo
						cRama:='1'
					Case (cAliasSR8)->RV_CODFOL == '0583'    //	Enfermedad General
						cRama:='2'
					Case (cAliasSR8)->RV_CODFOL == '0438'  //	Maternidad
						cRama:='3'
		 EndCase                                                              
		 cCONTINC:=If (Empty((cAliasSR8)->R8_CONTINC),"0",(cAliasSR8)->R8_CONTINC) 
		 cTPIMSS:=If((cAliasSR8)->RCM_TPIMSS == '1',"F","I")
		 cRESINC:=If (Empty((cAliasSR8)->R8_RESINC),"0",(cAliasSR8)->R8_RESINC)
		 
         if empty(crama) .AND.  (cAliasSR8)->RCM_TPIMSS == '2'
				AADD(aError,STR0073+(cAliasSR8)->R8_MAT)         //"Error: Ausencia sin rama definida, puede haber inconsistencias en el ausentismo del empleado :"
         else
         
			     nx:=1
				 if len(aRhe)==0			
                    
					     AADD(ARHE,{(cAliasSR8)->R8_FILIAL,(cAliasSR8)->R8_CODRPAT,cAnio+cMes,(cAliasSR8)->R8_MAT,(cAliasSR8)->R8_DATAINI,(cAliasSR8)->R8_DATAFIM,;
								     (cAliasSR8)->R8_NCERINC,cTPIMSS,(cAliasSR8)->R8_DNAPLIC,(cAliasSR8)->R8_TIPORSC,cRESINC,;
								     (cAliasSR8)->R8_PRORSC,cCONTINC,cRama,'' }) 
			     
			     else 
			         lBan:= .f.
			         do while nx<=len(aRHE)
			           //busca traslapes   
							 if ((cAliasSR8)->R8_DATAINI >=  aRHE[nx,5]  .and. (cAliasSR8)->R8_DATAINI <=  aRHE[nx,6])  .OR.;
							    ((cAliasSR8)->R8_DATAFIM >=  aRHE[nx,5]  .and. (cAliasSR8)->R8_DATAFIM <=  aRHE[nx,6])
							    lBan:= .t.
							    //Caso 1
							    if (cAliasSR8)->R8_DATAINI > aRHE[nx,5]  .and. (cAliasSR8)->R8_DATAFIM <  aRHE[nx,6]
							         if aRHE[nx,8]== "F" .and. cTPIMSS=='I' 
									        AADD(ARHE,{(cAliasSR8)->R8_FILIAL,(cAliasSR8)->R8_CODRPAT,cAnio+cMes,(cAliasSR8)->R8_MAT,(cAliasSR8)->R8_DATAFIM+1,aRHE[nx,6],;
								     			ARHE[nx,7],ARHE[nx,8],ARHE[nx,9],ARHE[nx,10],ARHE[nx,11],;
								     			ARHE[nx,12],ARHE[nx,13],ARHE[nx,14],'' }) 
							     			aRHE[nx,6]:=(cAliasSR8)->R8_DATAINI-1     
						     			 	AADD(ARHE,{(cAliasSR8)->R8_FILIAL,(cAliasSR8)->R8_CODRPAT,cAnio+cMes,(cAliasSR8)->R8_MAT,(cAliasSR8)->R8_DATAINI,(cAliasSR8)->R8_DATAFIM,;
													     (cAliasSR8)->R8_NCERINC,cTPIMSS,(cAliasSR8)->R8_DNAPLIC,(cAliasSR8)->R8_TIPORSC,cRESINC,;
													     (cAliasSR8)->R8_PRORSC,cCONTINC,cRama,'' }) 
								         
							         endif
							         Exit
							   	 ENDIF  
							   	 //Caso 2
							   	 if (cAliasSR8)->R8_DATAINI > aRHE[nx,5]  .and. (cAliasSR8)->R8_DATAFIM >  aRHE[nx,6]
								   	 if aRHE[nx,8]== "F" .and. cTPIMSS=='I' 
							   			aRHE[nx,6]:=(cAliasSR8)->R8_DATAINI-1 
						   				AADD(ARHE,{(cAliasSR8)->R8_FILIAL,(cAliasSR8)->R8_CODRPAT,cAnio+cMes,(cAliasSR8)->R8_MAT,(cAliasSR8)->R8_DATAINI,(cAliasSR8)->R8_DATAFIM,;
													     (cAliasSR8)->R8_NCERINC,cTPIMSS,(cAliasSR8)->R8_DNAPLIC,(cAliasSR8)->R8_TIPORSC,cRESINC,;
													     (cAliasSR8)->R8_PRORSC,cCONTINC,cRama,'' }) 
								        
									 endif
									 if (aRHE[nx,8]== "I" .and. cTPIMSS=='F') .or. (aRHE[nx,8]== "I" .and. cTPIMSS=='I')
									 	AADD(ARHE,{(cAliasSR8)->R8_FILIAL,(cAliasSR8)->R8_CODRPAT,cAnio+cMes,(cAliasSR8)->R8_MAT,aRHE[nx,6]+1,(cAliasSR8)->R8_DATAFIM,;
													     (cAliasSR8)->R8_NCERINC,cTPIMSS,(cAliasSR8)->R8_DNAPLIC,(cAliasSR8)->R8_TIPORSC,cRESINC,;
													     (cAliasSR8)->R8_PRORSC,cCONTINC,cRama,'' }) 
										
									 endif  
									 if aRHE[nx,8]== "F" .and. cTPIMSS=='F' 
									 	aRHE[nx,6]:=(cAliasSR8)->R8_DATAFIM
									 	
									 ENDIF                                  
									 Exit
								 ENDIF	 
								 //Caso 3
								 if (cAliasSR8)->R8_DATAINI < aRHE[nx,5]  .and. (cAliasSR8)->R8_DATAFIM <  aRHE[nx,6]
								     if aRHE[nx,8]== "F" .and. cTPIMSS=='I' 
								         aRHE[nx,5]:=(cAliasSR8)->R8_DATAFIM+1
								         	AADD(ARHE,{(cAliasSR8)->R8_FILIAL,(cAliasSR8)->R8_CODRPAT,cAnio+cMes,(cAliasSR8)->R8_MAT,(cAliasSR8)->R8_DATAINI,(cAliasSR8)->R8_DATAFIM,;
													     (cAliasSR8)->R8_NCERINC,cTPIMSS,(cAliasSR8)->R8_DNAPLIC,(cAliasSR8)->R8_TIPORSC,cRESINC,;
													     (cAliasSR8)->R8_PRORSC,cCONTINC,cRama,'' }) 
										  		     
								     endif                                   
								     if (aRHE[nx,8]== "I" .and. cTPIMSS=='F' ) .OR. ( aRHE[nx,8]== "I" .and. cTPIMSS=='I' )
										     AADD(ARHE,{(cAliasSR8)->R8_FILIAL,(cAliasSR8)->R8_CODRPAT,cAnio+cMes,(cAliasSR8)->R8_MAT,(cAliasSR8)->R8_DATAINI,aRHE[nx,5]-1,;
													     (cAliasSR8)->R8_NCERINC,cTPIMSS,(cAliasSR8)->R8_DNAPLIC,(cAliasSR8)->R8_TIPORSC,cRESINC,;
													     (cAliasSR8)->R8_PRORSC,cCONTINC,cRama,'' }) 
										
								     ENDIF
								     if aRHE[nx,8]== "F" .and. cTPIMSS=='F' 
									     aRHE[nx,5]:=(cAliasSR8)->R8_DATAINI
									     
								     ENDIF
								     Exit
								 endif
							 	//Caso 4
								 if (cAliasSR8)->R8_DATAINI < aRHE[nx,5]  .and. (cAliasSR8)->R8_DATAFIM >  aRHE[nx,6]
									 if aRHE[nx,8]== "F" .and. cTPIMSS=='I'   
										   aRHE[NX,5]:=(cAliasSR8)->R8_DATAINI
										   aRHE[NX,6]:=(cAliasSR8)->R8_DATAFIM
   								     	   aRHE[NX,7]:=	(cAliasSR8)->R8_NCERINC
								     	   aRHE[NX,8]:=cTPIMSS
										   aRHE[NX,9]:=(cAliasSR8)->R8_DNAPLIC
   								     	   aRHE[NX,10]:=(cAliasSR8)->R8_TIPORSC
								     	   aRHE[NX,11]:=cRESINC								     	   
								     	   aRHE[NX,12]:=(cAliasSR8)->R8_PRORSC								     	   
								     	   aRHE[NX,13]:=cCONTINC								     	   								     	   								     	   
								     	   aRHE[NX,14]:=cRama
								     	
									 
									 ENDIF 
									 if aRHE[nx,8]== "I" .and. cTPIMSS=='F'
									      AADD(ARHE,{(cAliasSR8)->R8_FILIAL,(cAliasSR8)->R8_CODRPAT,cAnio+cMes,(cAliasSR8)->R8_MAT,(cAliasSR8)->R8_DATAINI,aRHE[nx,5]-1,;
													     (cAliasSR8)->R8_NCERINC,cTPIMSS,(cAliasSR8)->R8_DNAPLIC,(cAliasSR8)->R8_TIPORSC,cRESINC,;
													     (cAliasSR8)->R8_PRORSC,cCONTINC,cRama,'' }) 
									      AADD(ARHE,{(cAliasSR8)->R8_FILIAL,(cAliasSR8)->R8_CODRPAT,cAnio+cMes,(cAliasSR8)->R8_MAT,aRHE[nx,6]+1,(cAliasSR8)->R8_DATAFIM,;
													     (cAliasSR8)->R8_NCERINC,cTPIMSS,(cAliasSR8)->R8_DNAPLIC,(cAliasSR8)->R8_TIPORSC,cRESINC,;
													     (cAliasSR8)->R8_PRORSC,cCONTINC,cRama,'' }) 
										
									 endif  
									 if (aRHE[nx,8]== "I" .and. cTPIMSS=='I' ) .OR. (aRHE[nx,8]== "F" .and. cTPIMSS=='F' )
										   aRHE[NX,5]:=(cAliasSR8)->R8_DATAINI
										   aRHE[NX,6]:=(cAliasSR8)->R8_DATAFIM
   								     	   aRHE[NX,7]:=	(cAliasSR8)->R8_NCERINC
								     	   aRHE[NX,8]:=cTPIMSS
										   aRHE[NX,9]:=(cAliasSR8)->R8_DNAPLIC
   								     	   aRHE[NX,10]:=(cAliasSR8)->R8_TIPORSC
								     	   aRHE[NX,11]:=cRESINC								     	   
								     	   aRHE[NX,12]:=(cAliasSR8)->R8_PRORSC								     	   
								     	   aRHE[NX,13]:=cCONTINC								     	   								     	   								     	   
								     	   aRHE[NX,14]:=cRama
								     	 
								     ENDIF	   
								     Exit
								 ENDIF 
								 //Caso 5
								 if (cAliasSR8)->R8_DATAINI ==aRHE[nx,5]  .and. (cAliasSR8)->R8_DATAFIM ==  aRHE[nx,6]
								     IF aRHE[nx,8]== "F" .and. cTPIMSS=='I'
										   aRHE[NX,5]:=(cAliasSR8)->R8_DATAINI
										   aRHE[NX,6]:=(cAliasSR8)->R8_DATAFIM
   								     	   aRHE[NX,7]:=	(cAliasSR8)->R8_NCERINC
								     	   aRHE[NX,8]:=cTPIMSS
										   aRHE[NX,9]:=(cAliasSR8)->R8_DNAPLIC
   								     	   aRHE[NX,10]:=(cAliasSR8)->R8_TIPORSC
								     	   aRHE[NX,11]:=cRESINC								     	   
								     	   aRHE[NX,12]:=(cAliasSR8)->R8_PRORSC								     	   
								     	   aRHE[NX,13]:=cCONTINC								     	   								     	   								     	   
								     	   aRHE[NX,14]:=cRama
								     
								     ENDIF
									 Exit
								 ENDIF     
								//Caso 6
								 if (cAliasSR8)->R8_DATAINI ==aRHE[nx,5]  .and. (cAliasSR8)->R8_DATAFIM >  aRHE[nx,6]	 
									  IF aRHE[nx,8]== "F" .and. cTPIMSS=='I'
										   aRHE[NX,5]:=(cAliasSR8)->R8_DATAINI
										   aRHE[NX,6]:=(cAliasSR8)->R8_DATAFIM
   								     	   aRHE[NX,7]:=	(cAliasSR8)->R8_NCERINC
								     	   aRHE[NX,8]:=cTPIMSS
										   aRHE[NX,9]:=(cAliasSR8)->R8_DNAPLIC
   								     	   aRHE[NX,10]:=(cAliasSR8)->R8_TIPORSC
								     	   aRHE[NX,11]:=cRESINC								     	   
								     	   aRHE[NX,12]:=(cAliasSR8)->R8_PRORSC								     	   
								     	   aRHE[NX,13]:=cCONTINC								     	   								     	   								     	   
								     	   aRHE[NX,14]:=cRama

									  endif                                  
									  IF (aRHE[nx,8]== "I" .and. cTPIMSS=='F') .OR. (aRHE[nx,8]== "I" .and. cTPIMSS=='I')
										  	AADD(ARHE,{(cAliasSR8)->R8_FILIAL,(cAliasSR8)->R8_CODRPAT,cAnio+cMes,(cAliasSR8)->R8_MAT,aRHE[nx,6]+1,(cAliasSR8)->R8_DATAFIM,;
													     (cAliasSR8)->R8_NCERINC,cTPIMSS,(cAliasSR8)->R8_DNAPLIC,(cAliasSR8)->R8_TIPORSC,cRESINC,;
													     (cAliasSR8)->R8_PRORSC,cCONTINC,cRama,'' }) 
													     
									  endif 
									  IF aRHE[nx,8]== "F" .and. cTPIMSS=='F'
									     aRHE[nx,6]:=(cAliasSR8)->R8_DATAFIM
									  ENDIF
									  Exit
								 endif     
								 //Caso 7
								 if (cAliasSR8)->R8_DATAINI <aRHE[nx,5]  .and. (cAliasSR8)->R8_DATAFIM =  aRHE[nx,6]	 
								     IF aRHE[nx,8]== "F" .and. cTPIMSS=='I'
								     	   aRHE[NX,5]:=(cAliasSR8)->R8_DATAINI
										   aRHE[NX,6]:=(cAliasSR8)->R8_DATAFIM
   								     	   aRHE[NX,7]:=	(cAliasSR8)->R8_NCERINC
								     	   aRHE[NX,8]:=cTPIMSS
										   aRHE[NX,9]:=(cAliasSR8)->R8_DNAPLIC
   								     	   aRHE[NX,10]:=(cAliasSR8)->R8_TIPORSC
								     	   aRHE[NX,11]:=cRESINC								     	   
								     	   aRHE[NX,12]:=(cAliasSR8)->R8_PRORSC								     	   
								     	   aRHE[NX,13]:=cCONTINC								     	   								     	   								     	   
								     	   aRHE[NX,14]:=cRama
								     ENDIF 
								     IF aRHE[nx,8]== "I" .and. cTPIMSS=='I'
								     	AADD(ARHE,{(cAliasSR8)->R8_FILIAL,(cAliasSR8)->R8_CODRPAT,cAnio+cMes,(cAliasSR8)->R8_MAT,(cAliasSR8)->R8_DATAINI,aRHE[nx,5]-1,;
													     (cAliasSR8)->R8_NCERINC,cTPIMSS,(cAliasSR8)->R8_DNAPLIC,(cAliasSR8)->R8_TIPORSC,cRESINC,;
													     (cAliasSR8)->R8_PRORSC,cCONTINC,cRama,'' }) 
								     ENDIF   
								     IF aRHE[nx,8]== "F" .and. cTPIMSS=='F'
									     aRHE[NX,5]:=(cAliasSR8)->R8_DATAINI
								     ENDIF
								     Exit
								 ENDIF 
								 //Caso 8
								 if (cAliasSR8)->R8_DATAINI == aRHE[nx,5]  .and. (cAliasSR8)->R8_DATAFIM <  aRHE[nx,6]	 
								     IF aRHE[nx,8]== "F" .and. cTPIMSS=='I'  
								     	aRHE[nx,5]:=(cAliasSR8)->R8_DATAFIM+1   
								     	AADD(ARHE,{(cAliasSR8)->R8_FILIAL,(cAliasSR8)->R8_CODRPAT,cAnio+cMes,(cAliasSR8)->R8_MAT,(cAliasSR8)->R8_DATAINI,(cAliasSR8)->R8_DATAFIM,;
													     (cAliasSR8)->R8_NCERINC,cTPIMSS,(cAliasSR8)->R8_DNAPLIC,(cAliasSR8)->R8_TIPORSC,cRESINC,;
													     (cAliasSR8)->R8_PRORSC,cCONTINC,cRama,'' }) 
								    
								     ENDIF
								     Exit
								 ENDIF    
								 //Caso 9
								 if (cAliasSR8)->R8_DATAINI > aRHE[nx,5]  .and. (cAliasSR8)->R8_DATAFIM ==  aRHE[nx,6]	 
									 IF aRHE[nx,8]== "F" .and. cTPIMSS=='I'
										 aRHE[nx,6]:=(cAliasSR8)->R8_DATAINI-1   
										 AADD(ARHE,{(cAliasSR8)->R8_FILIAL,(cAliasSR8)->R8_CODRPAT,cAnio+cMes,(cAliasSR8)->R8_MAT,(cAliasSR8)->R8_DATAINI,(cAliasSR8)->R8_DATAFIM,;
													     (cAliasSR8)->R8_NCERINC,cTPIMSS,(cAliasSR8)->R8_DNAPLIC,(cAliasSR8)->R8_TIPORSC,cRESINC,;
													     (cAliasSR8)->R8_PRORSC,cCONTINC,cRama,'' }) 
									 ENDIF
									 Exit
								 ENDIF
							 
							 endif
					 	nx++
					 enddo	         
					 if !lBan    
					 	AADD(ARHE,{(cAliasSR8)->R8_FILIAL,(cAliasSR8)->R8_CODRPAT,cAnio+cMes,(cAliasSR8)->R8_MAT,(cAliasSR8)->R8_DATAINI,(cAliasSR8)->R8_DATAFIM,;
								     (cAliasSR8)->R8_NCERINC,cTPIMSS,(cAliasSR8)->R8_DNAPLIC,(cAliasSR8)->R8_TIPORSC,cRESINC,;
								     (cAliasSR8)->R8_PRORSC,cCONTINC,cRama,'' }) 
					 endif
			     endif			 
		endif		     
	endif
//*******************	    
	nMax++                                                                            
	IncProc(STR0055) //"Generando Faltas e Incapacidades..."

	(cAliasSR8)->(DbSkip())
  ENDDO
  
  
   //--------
            
                 //considera que no debe exceder de 7 dias de faltas
                 ndiaFal:=0
                 for nx:=1 to len(aRhe)
                     if   aRhe[nx,8 ]=='F'                               
	                     if aRhe[nx,5]<dFEcini   
		                     aRhe[nx,5]:=dFEcini
	                     endif           
	                     if aRhe[nx,6]>dFEcFin 
		                     aRhe[nx,6]:=dFEcFin
	                     endif                   
	                     if ndiaFal>=7
	                        aRhe[nx,15]:='B'
	                     endif
	                     if  (aRhe[nx,6]-aRhe[nx,5]+1)>7
		                     aRhe[nx,6 ]:=aRhe[nx,5]+6
		                     ndiaFal+=aRhe[nx,6]-aRhe[nx,5]+1
		                 else               
			                 ndiaFal+=aRhe[nx,6]-aRhe[nx,5]+1
	                     endif              
                     endif
                 next
	             for nx:=1 to len(aRhe)
	                 if (aRhe[nx,6]-aRhe[nx,5]+1)> 0 .and. aRhe[nx,15]<>'B'
		                 if aRhe[nx,5]>= dFecIni

		                    RECLOCK("RHE",.T.)
					        RHE->RHE_FILIAL	:=  aRhe[nx,1 ]
					        RHE->RHE_CODRPA	:=  aRhe[nx,2 ]
							RHE->RHE_ANOMES	:=  aRhe[nx,3 ]				        
						    RHE->RHE_MAT	:=  aRhe[nx,4 ]
						    
							
							RHE->RHE_DATAIN	:=  aRhe[nx,5 ]
							RHE->RHE_DATAFI	:=  aRhe[nx,6 ]
							RHE->RHE_NCERIN	:=  aRhe[nx,7 ]
							RHE->RHE_TIPOAU	:=  aRhe[nx,8 ]
							RHE->RHE_DNAPLI	:=  aRhe[nx,9 ]
							RHE->RHE_TIPORS	:=  aRhe[nx,10]
							RHE->RHE_RESINC :=  aRhe[nx,11]
							RHE->RHE_PRORSC :=  aRhe[nx,12]
							RHE->RHE_CTRLIN	:=  aRhe[nx,13]
							RHE->RHE_RAMA   :=  aRhe[nx,14]
							RHE->RHE_DURACA:=aRhe[nx,6]-aRhe[nx,5]+1
							RHE->(MSUNLOCK())       
						
							/*
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³aFalInc:             ³
							//³1-Matricula          ³
							//³2-Tipo de movimiento ³
							//³3-Fecha de inicio    ³
							//³4-Fecha de fin       ³
							//³5-Registro patronal  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							*/                        
					   	endif
					  		AADD(aFalInc,{aRhe[nx,4 ] ,if(aRhe[nx,8 ]=="F",'1','2'), aRhe[nx,5 ],aRhe[nx,6 ],aRhe[nx,2 ]})
					
					 endif	
	             next               

             aRhe:={}


     //-----	
EndDo

aFalInc:=aSort(aFalInc,,,{|x,y| x[5]+x[1]+x[2]+dtos(x[3]) <= y[5]+y[1]+y[2]+dtos(y[3])})	 //registro patronal, matricula y tipo de ausencia 1-Falta 2-Ausencia, y Fecha de inicio
(cAliasSR8)->(dbclosearea())

Return                                                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o     GPA450INFO        ³ Gpe Santacruz         ³ Data ³13/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Genera arreglo Movimiento de Infonavit y guarda en la      ³±±
±±³          ³ tabla RHF                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPA450INFO (cExp1 )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.-Filtro de acurrdo al query principal                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPA450GERA                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GPA450INFO(cFiltRHB)

Local cQuery	:= ''
Local cAliasRHB	:= criatrab(nil,.f.)
Local ctipo		:= ''
Local nj		:= 0
Local nMax		:= 0

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Selecciona Movto de Infonavit    
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
	
IncProc(STR0056) //"Seleccionando movtos de Infonavit..."
ProcRegua(0) // Inicio de barra de avance

cQuery := "SELECT * "
cQuery += " FROM "+initsqlname("SRA") + " SRA, "+ initsqlname("RHB") + " RHB "
cQuery += " WHERE RA_MAT=RHB_MAT AND RA_FILIAL = RHB_FILIAL "
cQuery += " AND RHB_DTMINF <  '"+DTOS(dFecFin)+"'    "
cQuery += cFiltRHB   //FILTRO DEL RANGO DE EMPLEADOS, FILIALES Y EMPLEADOS ACTIVOS
cQuery += " AND RHB_CODRPA IN ("+CLISPAT+") "
cQuery += " AND  RHB.D_E_L_E_T_ = ' ' AND  SRA.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY  RHB_CODRPA, RHB_MAT, RHB_DTMINF "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRHB,.T.,.T.)
TCSetField(cAliasRHB,"RHB_DTMINF","D")

COUNT TO nMax
ProcRegua(nMax) // Número de registros a procesar

(cAliasRHB)->(dbgotop())
nMax:=0
aInfonavit:={}
	
Do While !(cAliasRHB)->(Eof())                    
	If (cAliasRHB)->RHB_DTMINF <= dFecIni     //Busca guardar el movimiento  inmediato anterior a la fecha de inicio
		nj:=aScan(aInfonavit,{|x|  Alltrim(x[3]) == Alltrim((cAliasRHB)->RHB_MAT) .AND. Alltrim(x[2]) == Alltrim((cAliasRHB)->RHB_CODRPA)  })
		If nj==0
			AADD(aInfonavit,{"1",(cAliasRHB)->RHB_CODRPA,(cAliasRHB)->RHB_MAT ,(cAliasRHB)->RHB_DTMINF,(cAliasRHB)->RHB_TPMINF,;
			(cAliasRHB)->RHB_TIPINF,(cAliasRHB)->RHB_VALINF,(cAliasRHB)->RHB_NUMINF })
		Else
			If  (cAliasRHB)->RHB_DTMINF > aInfonavit[nj,4]
				aInfonavit[nj,1] := "1"
				aInfonavit[nj,4] := (cAliasRHB)->RHB_DTMINF
				aInfonavit[nj,5] := (cAliasRHB)->RHB_TPMINF
				aInfonavit[nj,6] := (cAliasRHB)->RHB_TIPINF
				aInfonavit[nj,7] := (cAliasRHB)->RHB_VALINF
				aInfonavit[nj,8] := (cAliasRHB)->RHB_NUMINF
			Endif
		Endif
	Else
		nj := aScan(aInfonavit,{|x| ALLTRIM(x[3])==ALLTRIM((cAliasRHB)->RHB_MAT) .AND. ALLTRIM(x[2])==ALLTRIM((cAliasRHB)->RHB_CODRPA)  })
		If nj == 0
			cTipo := "1"
		Else
			cTipo := "2"
		Endif
		AADD(aInfonavit,{cTipo,(cAliasRHB)->RHB_CODRPA,(cAliasRHB)->RHB_MAT ,(cAliasRHB)->RHB_DTMINF,(cAliasRHB)->RHB_TPMINF,;
		(cAliasRHB)->RHB_TIPINF,(cAliasRHB)->RHB_VALINF,(cAliasRHB)->RHB_NUMINF })
	Endif

	IF (cAliasRHB)->RHB_DTMINF >= dFecIni .AND. (cAliasRHB)->RHB_DTMINF <= dFecFin
		RECLOCK("RHF",.T.)
		RHF->RHF_FILIAL := (cAliasRHB)->RHB_FILIAL
		RHF->RHF_ANOMES := cAnio+cMes
		RHF->RHF_MAT    := (cAliasRHB)->RHB_MAT
		RHF->RHF_CODRPA := (cAliasRHB)->RHB_CODRPA
		RHF->RHF_TPMINF := (cAliasRHB)->RHB_TPMINF
		RHF->RHF_DTMOV  := (cAliasRHB)->RHB_DTMINF
		RHF->RHF_NUMINF := (cAliasRHB)->RHB_NUMINF
		RHF->RHF_TIPINF := (cAliasRHB)->RHB_TIPINF
		RHF->RHF_VALINF := (cAliasRHB)->RHB_VALINF
		RHF->(MSUNLOCK())
	ENDIF
	nMax++

	IncProc(STR0057) //"Generando movtos. de Infonavit..."
	(cAliasRHB)->(dbskip())
EndDo

aInfonavit:=aSort(aInfonavit,,,{|x,y| x[2]+x[3]+DTOS(x[4]) <= y[2]+y[3]+DTOS(y[4])})	 
(cAliasRHB)->(dbclosearea())

Return                                                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPA450FI  ³Autor  ³ Gpe Santacruz         ³ Data ³11/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Extrae numero de Faltas o Incapacidades por empleado       ³±±
±±³          ³ por movimiento                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPA450FI (cExp1,cExp2,dExp1,dExp2 )                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.-Codigo de Registro patronal                         ³±±
±±³          ³ dExp1.-Codigo de empleado                                  ³±±
±±³          ³ dExp1.-Fecha de inicio del movimiento                      ³±±
±±³          ³ dExp2.-Fecha de Fin    del movimiento                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GrbMvtoRCH                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GPA450FI(cCodPat,cMat,dFecI,dFecF)

Local aDiaAus:={0,0}      
Local nPosFal:=aScan(aFalInc,{|x| ALLTRIM(x[1])==ALLTRIM(cMat) .AND. ALLTRIM(x[2])=='1' .AND. ALLTRIM(x[5])==ALLTRIM(cCodPat)  })
Local nPosInc:=aScan(aFalInc,{|x| ALLTRIM(x[1])==ALLTRIM(cMat) .AND. ALLTRIM(x[2])=='2' .AND. ALLTRIM(x[5])==ALLTRIM(cCodPat)})

If nPosFal>0   
   GPEA450AUS(cCodPat,cMat,nposFal,@aDiaAus,dFecI,dFecF,1,'1')
   If aDiaAus[1]>7
	   aDiaAus[1]:=7 //Topa a 7 dias las faltas
   Endif
endif     

If nPosInc>0       
   GPEA450AUS(cCodPat,cMat,nPosInc,@aDiaAus,dFecI,dFecF,2,'2')   
Endif

Return aDiaAus

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o     GPEA450AUS        ³ Gpe Santacruz         ³ Data ³13/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analiza para extraer el numero de Faltas o Incapacidades   ³±±
±±³          ³ por movimiento                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExtraeAusencia (cExp1,cExp2,nExp1,aExp1,dExp1,dExp2        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.-Matricula del empleado                              ³±±
±±³          ³ nExp1.-Posicion en la que iniciara la lectura del arreglo  ³±±
±±³          ³ aExp1.-Arreglo con el numero de dias de falas/incap.       ³±±
±±³          ³ dExp1.-Fecha de inicio del movimiento                      ³±±
±±³          ³ dExp2.-Fecha de fin del movimiento                         ³±±
±±³          ³ nExp2.-1-Falta 2 -Incapacidad                              ³±±
±±³          ³ cExp2.-1-Falta 2 -Incapacidad                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPA450FI                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GPEA450AUS(cCodPat,cMat,nx,aDiaAus,dFecI,dFecF,nTp,cTp)

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³aFalInc:             ³
//³1-Matricula          ³
//³2-Tipo de movimiento ³
//³3-Fecha de inicio    ³
//³4-Fecha de fin       ³
//³5-Registro patronal  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
Do While nx <= Len(aFalInc) .and. Alltrim(aFalinc[nx,1]) == Alltrim(cMat) .and. Alltrim(aFalinc[nx,5])==Alltrim(cCodPat) .and. Alltrim(aFalinc[nx,2])==Alltrim(cTp)
	If (aFalinc[nx,3] >= dFecI .and. aFalinc[nx,3] <= dFecF ) .OR. (aFalinc[nx,4] >= dFecI .and. aFalinc[nx,4]  <= dFecF) ;//Si el rango de ausencia si esta dentro del periodo que se calcula
		.Or. (aFalinc[nx,3] >= dFecI .and. aFalinc[nx,4]  <= dFecF ) //Si las fechas de ausencia estan a los extremos del periodo a calcular
		If aFalinc[nx,3] >= dFecI .and. aFalinc[nx,4] <= dFecF
			aDiaAus[nTp] += aFalinc[nx,4]-aFalinc[nx,3]+1
		Else
			If aFalinc[nx,3] >= dFecI .and. aFalinc[nx,4] >= dFecF
				aDiaAus[nTp] +=dFecF - aFalinc[nx,3]+1
			Else
				If aFalinc[nx,3] < dFecI .and. aFalinc[nx,4] < dFecF
					aDiaAus[nTp] += aFalinc[nx,4] - dfeci+1
				Else
					If aFalinc[nx,3] < dFecI .and. aFalinc[nx,4] > dFecF
						aDiaAus[nTp] += dFecf-dFeci + 1
					Endif
				Endif
			Endif
		Endif
	Endif
	nx++
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RecorreSRA        ³ Gpe Santacruz         ³ Data ³11/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Avanza el cursor del query principal, de los empleados     ³±±
±±³          ³ que por algun error no se procesaran.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RecorreSRA (cExp1,cExp2,nExp1)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.-Nombre del alias del query principal                ³±±
±±³          ³ cExp2.-Matricula del empleado                              ³±±
±±³          ³ nExp1.-Contador de los movtos. a procesar                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPA45gera                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static function RecorreSRA(cAliastmp,cmatX,nmax,cRpat,cTipo)
Local cFilBor:=CFILRCP //iif (empty(cFilRcp),cfilsra,cfilrcp)
If cTipo=="SRA"

	Do While !(cAliasTmp)->(Eof()) .and. cFilBor==(cAliasTmp)->RA_FILIAL .and. Alltrim(cRpat)==Alltrim((cAliasTmp)->RA_CODRPAT) .AND. Alltrim(cMatX) == Alltrim((cAliasTmp)->RA_MAT )
		nMax++                                                                            
		IncProc(STR0058)//"Generando Movimiento para SUA..."
		(cAliasTmp)->(DbSkip())
	EndDo
Else       

	Do While !(cAliasTmp)->(Eof())  .and. cFilBor==(cAliasTmp)->RCP_FILIAL .and. 	  alltrim(cRpat)==alltrim((cAliasTmp)->RCP_CODRPA) .AND.   ALLTRIM(cMatX)==ALLTRIM((cAliasTmp)->RCP_MAT )
		nMax++                                                                            
		IncProc(STR0059)//"Generando Movimiento para SUA..."
		(cAliasTmp)->(dbskip())
	EndDo                         
Endif

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Borra de Historico de ausencias al empleado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
RHE->(DBSETORDER(1)) 

Do While .t.
	If RHE->(DbSeek(cFilBor+cRpat+cAnio+cMes+cMatx))
		RECLOCK("RHE",.F.)
		RHE->(DBDELETE())
		RHE->(MSUNLOCK())
	Else
		Exit
	Endif
EndDo
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Borra de Historico de Infonavit           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
RHF->(DbSetOrder(1)) 

Do While .t.
	If RHF->(DbSeek(cFilBor+cRpat+cAnio+cMes+cMatx))
		RECLOCK("RHF",.F.)
		RHF->(DBDELETE())
		RHF->(MSUNLOCK())
	Else
		Exit
	Endif
EndDo
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³BorraSUA    Autor ³ Gpe Santacruz         ³ Data ³11/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Limpia todas las tablas deñ SUA de acuero a la pregunta    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ BorraSUA ()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPA45gera                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function BorraSUA()    

Local lRet:= .t.

IncProc(STR0060) //"Limpiando tabla de Movtos. SUA..."
dbSelectArea("RHC")

cQueryDel := "DELETE FROM " + RetSqlName("RHC")
cQueryDel += " WHERE RHC_CODRPA IN ("+CLISPAT+") "
cQueryDel += " AND RHC_ANOMES = '" + cAnIO+cMes + "'   "
cQueryDel += RangosDinamicos("RHC")

If (TcSqlExec( cQueryDel ) ) <> 0
	MsgAlert(TcSqlError())
	lRet:= .f.
Endif

IncProc(STR0061)  //"Limpiando tabla de Empleados SUA..."
dbSelectArea("RHD")

cQueryDel := "DELETE FROM " + RetSqlName("RHD")
cQueryDel += " WHERE  RHD_CODRPA IN ("+CLISPAT+")  "
cQueryDel += " AND RHD_ANOMES = '" + cAnIO+cMes + "'   "
cQueryDel +=RangosDinamicos("RHD")

If (TcSqlExec( cQueryDel ) ) <> 0
	MsgAlert(TcSqlError())
	lRet:= .f.
Endif

IncProc(STR0062) //"Limpiando tabla de Faltas e Incapacidades..."
dbSelectArea("RHE")

cQueryDel := "DELETE FROM " + RetSqlName("RHE")
cQueryDel += " WHERE RHE_CODRPA IN  ("+CLISPAT+") "
cQueryDel += " AND RHE_ANOMES = '" + cAnIO+cMes + "'  "
cQueryDel +=RangosDinamicos("RHE")

If (TcSqlExec( cQueryDel ) )<>0
	MsgAlert(TcSqlError())
	lRet:= .f.
Endif

IncProc(STR0063) //"Limpiando tabla de Infonavit..."
dbSelectArea("RHE")

cQueryDel := "DELETE FROM " + RetSqlName("RHF")
cQueryDel += " WHERE RHF_CODRPA IN ("+CLISPAT+")  "
cQueryDel += " AND RHF_ANOMES = '" + cAnio+cMes + "'   "
cQueryDel +=RangosDinamicos("RHF")

If (TcSqlExec( cQueryDel ) ) <> 0
	MsgAlert(TcSqlError())
	lRet:= .f.
Endif

Return	lRet

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
Local cTitulo		:= STR0064+cMes+"/"+cAnio //"LOG de Calculo de SUA del :"

Local aNewLog		:= {}
Local nTamLog		:= 0

aadd(aError," ")
aadd(aError," ")
aadd(aError,STR0065 + Transform(Len( aError)-2,"999,999"))//" Total de Errores encontrados : "
aadd(aError," ")
aadd(aError,STR0066 + Transform(nEmpPro,"999,999"))//" Total de Empleados Procesados :"
aadd(aError,STR0067 + Transform(nTotEmp,"999,999")) //" Total de Empleados Generados a SUA :"
aadd(aError,STR0068 + Transform(nTotMov,"999,999")) //" Total de Movimientos Generados a SUA :"

aNewLog		:= aClone(aError)
nTamLog		:= Len( aError)

aLog := {}

If !Empty( aNewLog )
	aAdd( aTitLog , "E")
	aAdd( aLog , aClone( aNewLog ) )
Endif

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

MsAguarde( { ||fMakeLog( aLog , , , .T. , FunName() , cTitulo , cTamanho , "P" , aReturn, .F. )},STR0069)//"Generando Log de Calculo de SUA..."

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Traduce     Autor ³ Gpe Santacruz         ³ Data ³10/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Convierte las variables de las preguntas que son de tipo   ³±±
±±³          ³ rango, a expresiones para usarse en querys.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Traduce (cExp1 )                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1.-Parametro de la pregunta                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GrbMvtoRCH                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Traduce(cVari)    

Local aMats	:= {}
Local nx	:=0
Local cTxtMat1 := ""
Local cTxtMat2 := ""

If  ";" $ cVari
	aMats := Separa(Alltrim(cVari),";")
	If Len(aMats) > 0
		cVari :=''
		For nx:=1 To Len(aMats)
			If !Empty(aMats[nx])
				cTxtMat1 := STRTRAN(Alltrim(aMats[nx]),"'","")
				cVari+="'" + cTxtMat1+"',"
			Endif
		Next
		cVari:=substr(cVari,1,Len(cVari)-1)
	Endif
Else
	If "-" $ cVari
		aMats:= Separa(Alltrim(cVari),"-")
		If Len(aMats) > 0
			cTxtMat1 := STRTRAN(Alltrim(aMats[1]),"'","")
			cTxtMat2 := STRTRAN(Alltrim(aMats[2]),"'","")
			cVari:="'" + cTxtMat1+"' AND '" + cTxtMat2+"'"
		Endif
	Endif
Endif

Return 	cVari

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    |RangosDinamicos   ³ Gpe Santacruz         ³ Data ³10/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³    														  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RangosDinamicos(cAliasTab,nCual)     

Local cFiltro	:= ''
Default nCual	:= 0

If nCual == 0
	If !Empty(cLisMat)
		If ";" $ cMats
			cFiltro += " AND "+cAliasTab+"_MAT  IN ("+CLISMAT+") "
		Else
			If "-" $ cMats	
				cFiltro += " AND "+cAliasTab+"_MAT BETWEEN "+CLISMAT+" "
			Else                                             
				cFiltro += " AND "+cAliasTab+"_MAT = '"+cmats+"' "
			Endif	
		Endif	
	Endif	
Endif
	
If !Empty(cLisSuc)
	If ";" $ cSucs
		cFiltro += " AND "+cAliasTab+"_FILIAL  IN ("+cLisSuc+") "
	Else
		If "-" $ cSucs	
			cFiltro += " AND "+cAliasTab+"_FILIAL BETWEEN "+cLisSuc+" "
		Else                                             
			cFiltro += " AND "+cAliasTab+"_FILIAL = '"+cLisSuc+"' "
		Endif	
	Endif	
Endif	   

Return cFiltro

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPEA450OLD Autor ³ Silvia Taguti         ³ Data ³ 04/04/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ GERACAO ARQUIVO SUA                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEA450OLD()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEA450_ANT()

Local nOpca
Local aSays			:={ }, aButtons:= { } //<== arrays locais de preferencia
Local aGetArea		:= GetArea()
Local nCont			:= 1
Local nA       	:= 0
Local cQueryDel	:= ""
Local cCod 			:= ""

Private aGrava		:=	{}         
Private cMsg		:= ""
Private lOk			:= .T.
Private cMesAno	:=	""  
Private cRegPat	:= ""
Private cCadastro := OemtoAnsi(STR0003)//"Atualizacao Cargos/Funcoes dos funcionarios"
Private nDel		:= 0
Private aCodRpat  := {}   
Private cAnoMes      

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Funcao verifica se existe alguma restrição de acesso para o³
³usuário que impeça a execução da rotina.                   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If (FindFunction("fValidFun()"))
	If !(fValidFun({"RCP","RCQ","SRA","SR3","SR7","SR8","SR9"}))
		RestArea(aGetArea)
		Return
	Endif	
EndIf

dbSelectArea("RCO")
DbSetOrder(1)

Pergunte("GPEA450",.F.)

AADD(aSays,OemToAnsi(STR0001) ) //"Este rotina gera as informacoes do registro Patronal"                 
AADD(aSays,OemToAnsi(STR0002) ) //" de funcionarios num determinado periodo." 

AADD(aButtons, { 5,.T.,{|| Pergunte("GPEA450",.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(gp450Conf(),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
	
FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1
	cMesAno 	:= mv_par01 //- Mes/Ano de Processamento
	cAnoMes  := Right(cMesAno,4)+Left(cMesAno,2)
	
	dbSelectArea("RCO")
	DbSetOrder(1)
	
	For nCont := 1 To Len( mv_par02 ) Step 4
		If dbSeek(xFilial("RCO")+SubStr( mv_par02 , nCont , 4 ))
			AADD(aCodRPat,{SubStr( mv_par02 , nCont , 4 ),RCO->RCO_NREPAT})
		Endif
	Next nCont
	
	If Len(aCodRPat)== 0
		Return
	Endif
	
	For nA := 1 to Len(aCodRPat)
		cCod += "'"+Alltrim(aCodRPat[nA,2])+"',"
	Next nA
	cCod := Substr(cCod,1,(Len(cCod)-1) )
	
	dbSelectArea("RCQ")
	
	#IFNDEF TOP
		Processa( {|| fDeleRCQ( aCodRPat,cAnoMes, @nDel ) } , STR0016 )  //"Aguarde..."
	#ELSE
		IF TcSrvType() != "AS/400"
			cQueryDel := "DELETE FROM " + RetSqlName("RCQ")
			cQueryDel += " WHERE RCQ_NREPAT IN (" + cCod + ") AND"
			cQueryDel += " RCQ_ANOMES = '" + cAnoMes + "'"
			
			MsgRun(OemToAnsi(STR0016),,{|| TcSqlExec( cQueryDel ) } ) //"Aguarde..."
		Else
			Processa( {|| fDeleRCQ( aCodRPat,cAnoMes, @nDel ) } , STR0016 )  //"Aguarde..."
		Endif
	#ENDIF
	
	Processa({|lEnd|GP450LeArq() } )
	
	IF nDel > 0
		Chk_Pack( "RCQ" , -1 , 1 )
	EndIF
	
Endif

RestArea(aGetArea)

Return Nil                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GP450Conf ºAutor  ³Microsiga           º Data ³  28/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Confirmacao de execucao da geracao dos dados                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Gp450Conf()

Return (MsgYesNo(OemToAnsi(STR0018),OemToAnsi(STR0017)))  //"Confirma configura‡„o dos parƒmetros?"###"Aten‡„o"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FDELERCQ  ºAutor  ³Silvia Taguti       º Data ³  04/25/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Deleta dados no mes referencia                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fDeleRcq( aCodRPat, cData , nDel )

Local nb := 0

dbSelectArea("RCQ")
dbSetOrder(2)
dbGotop()

ProcRegua( RCQ->( RecCount() ) )

For nb := 1 to Len(aCodRPat)
	IF dbSeek( aCodRPat[nb,2] )
		While RCQ->( !Eof() .and. RCQ_NREPAT == aCodRPat[nb,2])
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Deletando Registros                                          ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			IF RCQ->RCQ_ANOMES == cData  
				RecLock( "RCQ" , .F. , .T. )
				dbDelete()
				nDel++
				MsUnlock()
			EndIF
			dbSelectArea( "RCQ" )
			dbSkip()
		Enddo
   EndIF
Next nb

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GP450LeArqºAutor  ³Silvia Taguti       º Data ³  29/11/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Le arquivos RCP                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA450                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GP450LeArq()

Local cArqNtx	:=	""
Local nx			:= 0
LOCAL cQuery   := ""
Local aStru		:= {}      //Estrutura da Query
Local aRCPVirtGd		:= {}				// vetor com os campos virtuais. (variavel para getdados da tabela RCP)
Local aRCPVisualGD	:= {} 				// vetor com os campos visuais. (variavel para getdados da tabela RCP)
Local aRCPNotFields	:= {}				// vetor com os campos que nao seria visualizados. (variavel para getdados da tabela RCP)

Local cMatAnt 	:= ""  
Local cFilAt 	:= ""
Local cRPatAnt	:= "" 

Local nY := 0      
Local nA := 0 
Local nPosAcols := 0     
Local lQuery := .F.

Private cAliasRCP:= ""
Private aLog	:=	{}
Private aHeaderRCP	:= {}					// vetor com o cabecalho da GetDados RCP. (variavel para getdados da tabela RCP)
Private nRCPUsado		:= 0.00 			// variavel que retorna a quantidade de campos da tabela. (variavel para getdados da tabela RCP)
Private aRCPColsRec	:= {}				// vetor que contem os Recnos da tabela. (variavel para getdados da tabela RCP)
Private aRCPCols		:= {}
Private nSeq    		:= 0   
Private lFuncDem		:= .F.
Private dDataRef    	:= ctod("//")
Private aTotRegs:= array(25)
Private aTitle	:= 	{} 
Private lLog   := .F.
Private lFalSua := GetNewPar('MV_FALSUA',"S") // O pagamento das Ferias deve ser separado da Folha de Pag.

cFilDe      := space(fwSizeFilial())
cFilAte     := Replicate("z", fwSizeFilial() )

aFill(aTotRegs,0)     

dDataRef := Ctod("01/"+Left(cMesAno,2)+"/"+ Right(cMesAno,4))           
             
dbSelectArea("RCP")
dbSetOrder(3)
cAliasRCP := "RCP"	   

aHeaderRCP := GdMontaHeader( @nRCPUsado	,;	//01 -> Por Referencia contera o numero de campos em Uso
						@aRCPVirtGd		,;	//02 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Virtuais
						@aRCPVisualGd	,;	//03 -> Por Referencia contera os Campos do Cabecalho da GetDados que sao Visuais
						"RCP"   		,;	//04 -> Opcional, Alias do Arquivo Para Montagem do aHeader
						aRCPNotFields	,;	//05 -> Opcional, Campos que nao Deverao constar no aHeader
						.T.       		,;	//06 -> Opcional, Carregar Todos os Campos
						NIL         	,;	//07 -> Nao Carrega os Campos Virtuais
						.T.         	,;	//08 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
						.F.           	,;	//09 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
						.T.       		,;	//10 -> Verifica se Deve Checar se o campo eh usado
						.T.      		,;	//11 -> Verifica se Deve Checar o nivel do usuario
						.T.         	,;	//12 -> Utiliza Numeracao na GhostCol
						.T.      		 ;	//13 -> Carrega os Campos de Usuario
					   )
					   
aEmptyRCP := GdRmkaCols(aHeaderRCP,.F.,.T.,.T.)					   

For nx := 1 to Len(aCodRPat)
	cCodRPat := aCodRPat[nx,1]
	cRegPat := aCodRPat[nx,2]	
	#IFDEF TOP     
		IF TcSrvType() != "AS/400"
			aStru := RCP->(dbStruct())		
            
			//-->Obtem a posicao dos campos para a clausula ORDER BY
			nPosFil := cValToChar( aScan( aStru, { |x| x[1] == "RCP_FILIAL"} ) ) //Posicao da Filial
			nPosMat := cValToChar( aScan( aStru, { |x| x[1] == "RCP_MAT"} ) )    //Posicao da Matricula
			nPosDtM := cValToChar( aScan( aStru, { |x| x[1] == "RCP_DTMOV"} ) )  //Posicao da Data Movimentacao
			nPosRpa := cValToChar( aScan( aStru, { |x| x[1] == "RCP_CODRPA"} ) ) //Posicao do Codigo Registro Patronal
		
			lQuery := .T.
			cAliasRCP := "QRCP"			    
			cQuery := "SELECT * FROM " + RetSqlName("RCP") + " RCP1  
			cQuery += "WHERE RCP1.RCP_CODRPA <> '"+ cCodRPat+ "' AND "
			cQuery += "      (RCP1.RCP_TPMOV = '01' OR RCP1.RCP_TPMOV = '02') AND "
			cQuery += "      RCP1.D_E_L_E_T_ = ' ' AND "
			cQuery += "      EXISTS (SELECT * FROM " + RetSqlName("RCP") + " RCP2         
			cQuery += "              WHERE RCP2.RCP_CODRPA = '"+ cCodRPat+ "' AND "
			cQuery += "                    RCP2.RCP_TPMOV = '06' AND "
			cQuery += "                    RCP2.RCP_FILIAL  between '" + cFilDe + "' AND '" + cFilAte + "' AND "
			cQuery += "                    RCP2.RCP_DTMOV <='" + cAnoMes+'31' + "' AND "
			cQuery += "                    RCP2.D_E_L_E_T_ = ' ' AND "
			cQuery += "                    RCP2.RCP_FILIAL = RCP1.RCP_FILIAL AND RCP2.RCP_MAT = RCP1.RCP_MAT) "
			cQuery += "UNION "
			cQuery += "SELECT * FROM " + RetSqlName("RCP") + " RCP "
			cQuery += " WHERE RCP.RCP_FILIAL  between '" + cFilDe + "' AND '" + cFilAte + "'"
			cQuery += " AND RCP.RCP_CODRPA ='"+ cCodRPat+ "' AND "
			cQuery += " RCP.RCP_DTMOV <='" + cAnoMes+'31' + "' AND "
			cQuery += "  D_E_L_E_T_ = ' ' "
			cQuery += " ORDER BY " + nPosFil + "," + nPosMat +  "," + nPosDtM + "," + nPosRpa			

			cQuery := ChangeQuery( cQuery )
            
			If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cAliasRCP,.T.,.T.)
				For nA := 1 To Len(aStru)
					If ( aStru[nA][2] <> "C" )
						TcSetField(cAliasRCP,aStru[nA][1],aStru[nA][2],aStru[nA][3],aStru[nA][4])
					EndIf
				Next nA
			Endif
		Else
			dbSetOrder(3)
			DbSeek(cFilDe+cCodRPat,.T.)
		Endif	
	#ELSE
		dbSetOrder(3)
		DbSeek(cFilDe+cCodRPat,.T.)
	#ENDIF
	
	ProcRegua((cAliasRCP)->(RecCount()))
	
	While (cAliasRCP)->(!EOF()) .And. 	(cAliasRCP)->(RCP_FILIAL) <= cFilAte .And. ;
	    ( (cAliasRCP)->RCP_CODRPA == cCodRPat .Or. (cAliasRCP)->RCP_TPMOV == "01" )
		If (cAliasRCP)->(RCP_FILIAL+RCP_CODRPA+RCP_MAT)==(cFilAt + cRPatAnt + cMatAnt)
			(cAliasRCP)->(dbSkip())
			Loop
		Endif
		If AnoMes((cAliasRCP)->RCP_DTMOV) > cAnoMes
			(cAliasRCP)->(dbSkip())
			Loop
		Endif	
                         
		cFilAt  := (cAliasRCP)->RCP_FILIAL
		cRPatAnt:= (cAliasRCP)->RCP_CODRPA
		cMatAnt := (cAliasRCP)->RCP_MAT
		lFuncDem := .F.
		aRCPCols		:= {}
		nSeq			:= 0
		lLog 			:= .F.

		/*dbselectArea("SRA")  		
		SRA->(dbSetOrder(RetOrdem("SRA","RA_FILIAL+RA_MAT")))
		If SRA->( dbSeek(cFilAt + cMatAnt) )
			If SRA->RA_RESCRAI $ '30/31'
				(cAliasRCP)->(dbSkip())
				Loop
			EndIf
		EndIf*/

		nPosAcols := Len(aRCPCols)
		While (cAliasRCP)->( !Eof() ) .And. ;
			(cAliasRCP)->(RCP_FILIAL+RCP_MAT) == cFilAt+cMatAnt 			
			If	AnoMes((cAliasRCP)->RCP_DTMOV) > cAnoMes
				(cAliasRCP)->(dbSkip())
				Loop
			Endif		
			aadd(aRCPCols, aClone(aEmptyRCP[1] ) )
			nPosAcols++
			For ny:= 1 to Len(aHeaderRCP)
				cCampo := aHeaderRCP[ny,2]
				If ascan(aRCPVirtGd,{|x|x = cCampo}) == 0
					aRCPCols[nPosAcols,ny] := (cAliasRCP)->(&cCampo)
				Endif
			Next ny
			(cAliasRCP)->(dbSkip())					
		Enddo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Critica funcionario Demitidos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aRCPCols) > 0
			lFuncDem := GpValDem()
		Endif
		If !lFuncDem
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Critica Movimentos da Trajetoria Laboral³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aRCPCols) > 0
				GpValTGer(aRCPCols,.T.)
			Endif
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida arquivo SRA para campos que serao usados³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aRCPCols) > 0
				ValidaSRA()
			Endif	
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica arquivo SR8 de Ausentismos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Gp450Ause()
		Endif	
	Enddo
	dbSelectARea(cAliasRCP)
	dbCloseArea()
	dbSelectArea("RCP")
Next nx

If Len(aGrava) > 0
	f450Organ(@aGrava) 
	
	GP450GrvRCQ()
Endif	

RCP->(RetIndex())

If File(cArqNtx+OrdBagExt())
   FERASE(cArqNtx+OrdBagExt())
Endif
RCP->( dbSetOrder(1)) 


IF !( lOk := Empty( aLog ))
	//"Ocorreram Inconsistências durante o Processo de Transferência. Deseja consultar o LOG"
	//Atenção
	IF ( MsgNoYes( OemToAnsi( STR0013 )  , OemToAnsi( STR0011 ) ) )
	  fMakeLog(aLog,aTitle,,,,STR0014,"M","P",,.F.) //"Log de ocorrencias
	EndIF
EndIF        
                                                           
RETURN .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPVALDEM  ºAutor  ³Microsiga           º Data ³  04/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se o funcionario esta demitido                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GpValDem()

Local nPosTpM  	:= GdFieldPos( "RCP_TPMOV" , aHeaderRCP )	
Local nPosDtM  	:= GdFieldPos( "RCP_DTMOV" , aHeaderRCP )	
Local nTam        := Len(aRCPCols)                                                    
Local lRet			:= .F.
                     
If aRCPCols[nTam,nPosTpm] $ "02|04"  .And. AnoMes(aRCPCols[nTam,nPosDtM]) < cAnoMes
	lRet := .T.
Endif

Return lRet        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VALIDASRA ºAutor  ³Microsiga           º Data ³  04/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o preenchimento de determinados campos no cadastro   º±±
±±º          ³de funcionarios                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ValidaSRA()

Local aGetArea	:= GetArea()
Local nPosMat  	:= GdFieldPos( "RCP_MAT"	 , aHeaderRCP )	
Local nPosFil  	:= GdFieldPos( "RCP_FILIAL" , aHeaderRCP )	
Local nPosSal  	:= GdFieldPos( "RCP_SALDII" , aHeaderRCP )	
Local nPosIVC  	:= GdFieldPos( "RCP_SALIVC" , aHeaderRCP )	
Local nPosTei  	:= GdFieldPos( "RCP_TEIMSS" , aHeaderRCP )	
Local nPosTsi  	:= GdFieldPos( "RCP_TSIMSS" , aHeaderRCP )	
Local nPosTjr  	:= GdFieldPos( "RCP_TJRNDA" , aHeaderRCP )	
Local nPosTpM  	:= GdFieldPos( "RCP_TPMOV"  , aHeaderRCP )	
Local nPosDtI  	:= GdFieldPos( "RCP_DTIMSS" , aHeaderRCP )	
Local nPosHrI  	:= GdFieldPos( "RCP_HRIMSS" , aHeaderRCP )	
Local nPosDtM  	:= GdFieldPos( "RCP_DTMOV " , aHeaderRCP )	
Local nDesconto := 0
Local nVolunt	:= 0
Local n := 0
Local cSeq    		:= ""    
Local dDataPag 		:= ctod("//")       
Local cInfonavit 	:= ""
Local dDataIn		:= ctod("//")
Local cTpInfo		:= ""
Local nSalIntAtu	:= 0
Local nSalIvAtu		:= 0
Local nPos			:= 0 
Local dDataPar		:= ctod("//")
Local cMesPar    	:= "02|04|06|08|10|12"
Local nMes 			:= 0
Local nAno			:= 0
Local nPosRe	   	:= 0
Local dDataInicio 	:= ctod("//")
Local aDemis 		:= {}
Local lGeraInfo 	:= .F.
Local nSalMinInt	:= 0
Local dDtValAlt		:= CTOD("//")
Local nFatorSM  	:= GetNewPar('MV_SALMINI',1.04520)
Local cUltTpMov 	:= "  "
nMes := Month(dDataRef) - 1
nAno := Year(dDataRef)
If nMes == 0
	nMes := 1
	nAno := nAno - 1
Endif

dDataPar := Ctod("01/"+StrZero(nMes,2)+"/"+StrZero(nAno,4))

dbSelectArea("SRA")
SRA->(dbSetOrder(1))

If SRA->(dbSeek(aRCPCols[1,1]+aRCPCols[1,2]))
	If !FChkCont(SRA->RA_NOME,"C")
		lLog := .T.
		If aTotRegs[21]== 0
			cLog := STR0024 //"Nome do empregado possui caracteres especiais"
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[21] := len(aLog)
		Endif	
		Aadd(aLog[aTotRegs[21]],Space(10)+SRA->RA_MAT + "-" + SRA->RA_NOME)  
	EndIf
	
	If Empty(SRA->RA_PRISOBR)
		lLog := .T.
		If aTotRegs[22]== 0
			cLog := STR0025 //"Apelido paterno nao pode estar em branco"
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[22] := len(aLog)
		Endif	
		Aadd(aLog[aTotRegs[22]],Space(10)+SRA->RA_MAT + "-" + SRA->RA_NOME)  
	EndIf

	If Empty(SRA->RA_CODRPAT)
		lLog := .T.
		If aTotRegs[1]== 0
			cLog := STR0004 //"Codigo del Registro Patronal no esta llenada"
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[1] := len(aLog)
		Endif	
		Aadd(aLog[aTotRegs[1]],Space(10)+SRA->RA_MAT + "-" + SRA->RA_NOME)  
	Endif

	If Empty(SRA->RA_RG)
		lLog := .T.
		If aTotRegs[2]== 0
			cLog := STR0005 //"Codigo de IMSS no esta llenada"
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[2] := len(aLog)
		Endif	
		Aadd(aLog[aTotRegs[2]],Space(10)+SRA->RA_MAT + "-" + SRA->RA_NOME )    
	Else
		If !FChkCont(SRA->RA_RG,"N")
			lLog := .T.
			If aTotRegs[23]== 0
				cLog := STR0026 //"Codigo de IMSS deve conter apenas numeros"
				Aadd(aTitle,cLog)  	
				Aadd(aLog,{})
				aTotRegs[23] := len(aLog)
			Endif	
			Aadd(aLog[aTotRegs[23]],Space(10)+SRA->RA_MAT + "-" + SRA->RA_NOME )    
		EndIf        
		
		If !CHKIMSS(SRA->RA_RG, .F.)
			lLog := .T.
			If aTotRegs[24]== 0
				cLog := STR0027 //"O digito verificador do Codigo de IMSS nao coincide"
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[24] := len(aLog)
			Endif	
			Aadd(aLog[aTotRegs[24]],Space(10)+SRA->RA_MAT + "-" + SRA->RA_NOME )    
		EndIf 
	Endif
	                                                       
	/*If Empty(SRA->RA_CURP)
		lLog := .T.
		If aTotRegs[7]== 0
			cLog := STR0006 	//"Codigo de CURP no esta llenada"
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[7] := len(aLog)
		Endif	
		Aadd(aLog[aTotRegs[7]],Space(10)+SRA->RA_MAT + "-" + SRA->RA_NOME)    
	Endif*/
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄH¿
	//³Se o Numero de Infonavit estiver preenchido, a data e o tipo³
	//³devem estar prrenchidos. Foi retirado o controle de Meses   ³
	//³pares, pois o valor do INFONAVIT passou a ser tratado no re-³
	//³gistro do RCQ e nao do cadastro de funcionarios.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄHÙ
	//If StrZero(Month(dDataRef),2) $ cMesPar
	If !Empty(SRA->RA_NUMINF)
		If StrZero(Month(dDataRef),2) $ cMesPar
			lGeraInfo := .T.
		EndIf
			cInfonavit := Alltrim(SRA->RA_NUMINF)
			If Empty(SRA->RA_DTCINF)
				lLog := .T.
				If aTotRegs[4]== 0
					cLog := STR0007 	//"Data de Credito Infonavit nao esta preenchida"
					Aadd(aTitle,cLog)  
					Aadd(aLog,{})
					aTotRegs[4] := len(aLog)
				Endif	
				Aadd(aLog[aTotRegs[4]],Space(10)+SRA->RA_MAT + "-" + SRA->RA_NOME)  
			Else
				dDataIn := SRA->RA_DTCINF
			Endif
			If Empty(SRA->RA_TIPINF)
				lLog := .T.
				If aTotRegs[5]== 0
					cLog := STR0008	//"Tipo de Infonavit nao esta preenchida"
					Aadd(aTitle,cLog)  
					Aadd(aLog,{})
					aTotRegs[5] := len(aLog)
				Endif	
				Aadd(aLog[aTotRegs[5]],Space(10)+SRA->RA_MAT + "-" + SRA->RA_NOME)    
			Else
				cTpInfo := SRA->RA_TIPINF
			Endif
			
			If !Empty(cTpInfo) 		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Busca o valor do Infonavit na tabela de Acumulados³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If cTpInfo $ "1|2|3"
           		nValor 	:= gpRetSR9("SR9", dDataRef, "RA_VALINF", @dDtValAlt)
            	If !Empty(dDtValAlt) .And. dDtValAlt <= dDataRef .and. !Empty(nValor)
     	       		nDesconto := nValor
     	       	Else	
     	       		nDesconto := SRA->RA_VALINF 
					EndIf
				EndIf
	
				If nDesconto = 0 
					If ((mesano(SRA->RA_DTCINF) <= mesano(dDataRef) .and. ;
				      ((!Empty(SRA->RA_DTISINF) .and. (mesano(SRA->RA_DTISINF) >= mesano(dDataRef))) .or. Empty(SRA->RA_DTISINF))) .or.;
				      (!Empty(SRA->RA_DTRDINF) .and. (mesano(SRA->RA_DTRDINF) <= mesano(dDataPar))))
							lLog := .T.
							If aTotRegs[6]== 0
								cLog := STR0019	//"Valor de desconto Infonavit Invalido"
								Aadd(aTitle,cLog)  
								Aadd(aLog,{})
			  					aTotRegs[6] := len(aLog)
					  		Endif	
							Aadd(aLog[aTotRegs[6]],Space(10)+SRA->RA_MAT + "-" + SRA->RA_NOME)    
					EndIf
				Endif	
			// Mesmo o funcionario possuindo credito infonavit suspenso, 
			// Liberar a geracao da parte patronal do INFONAVIT //				
			If nDesconto > 0 
				If MesAno(SRA->RA_DTCINF) > MesAno(dDataRef) .or. ;
		     		(!Empty(SRA->RA_DTISINF) .and. (MesAno(SRA->RA_DTISINF) < MesAno(dDataPar)) .and. ;
		      		(Empty(	SRA->RA_DTRDINF) .or. (!Empty(SRA->RA_DTRDINF) .and. (MesAno(SRA->RA_DTRDINF) > MesAno(dDataRef)))))
					nDesconto := 0
				EndIf
			EndIf
		Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Aporte Voluntario Infonavit³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nVolunt := ABS(fBuscaAcm(fGetCodFol("491"),,dDataPar,dDataRef,"V"))
			nVolunt := Round(nVolunt / 2, MsDecimais(1))
			If nVolunt > 0
				dbSelectArea("SRD")                                                   
				dbSeek(SRA->RA_FILIAL+SRA->RA_MAT + cAnoMes,.T.)
	         dDataPag := SRD->RD_DATPGT
   	   Endif   
   	Endif	   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ<¿
	//³Verifica se o tipo de Salario   esta preeenchido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ<Ù
	For n:= 1 to Len(aRCPCols)
		If Empty(aRCPCols[n,nPosTsi])
			lLog := .T.
			If aTotRegs[18]== 0
				cLog := STR0021 //"Tipo de Salario no esta preenchido"
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[18] := len(aLog)
			Endif	
			Aadd(aLog[aTotRegs[18]],Space(10)+SRA->RA_MAT + "-" + SRA->RA_NOME)  
			Exit
		Endif
	Next n
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ<¿
	//³Verifica se o tipo de Empregado esta preeenchido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ<Ù
	For n:= 1 to Len(aRCPCols)
		If Empty(aRCPCols[n,nPosTei])
			lLog := .T.
			If aTotRegs[17]== 0
				cLog := STR0020 //"Tipo de Empregado no esta preenchido"
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[17] := len(aLog)
			Endif	
			Aadd(aLog[aTotRegs[17]],Space(10)+SRA->RA_MAT + "-" + SRA->RA_NOME)  
			Exit
		Endif  
	Next n	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o tipo de Jornada esta preeenchido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For n:= 1 to Len(aRCPCols)
		If Empty(aRCPCols[n,nPosTjr])
			lLog := .T.
			If aTotRegs[19]== 0
				cLog := STR0021 //"Tipo de Jornada no esta preenchida"
				Aadd(aTitle,cLog)  
				Aadd(aLog,{})
				aTotRegs[19] := len(aLog)
			Endif	
			Aadd(aLog[aTotRegs[19]],Space(10)+SRA->RA_MAT + "-" + SRA->RA_NOME)  
		Endif
   Next

   For n:= 1 to Len(aRCPCols)
   	If AnoMes(aRCPCols[n,nPosDtM]) < cAnoMes .And. aRCPCols[n,nPosTpm] == "06"
   		nPosRe := n
   	Endif	   
      // Se houver reingresso no mes de geracao, gerar tambem a demissao anterior
   	If AnoMes(aRCPCols[n,nPosDtM]) == cAnoMes .And. aRCPCols[n,nPosTpm] == "06" .And. n > 1
		If aRCPCols[n-1,nPosTpm] == "02"
			AADD(aDemis, {aRCPCols[n-1,nPosTpm], aRCPCols[n-1,nPosDtM]})
		Endif	
   	Endif
   Next     
   //Se a Data do Infonavit for menor que a data de admissao usar a data do mes de geracao
   If dDataIn <> ctod("//") 
	   For n:= 1 to Len(aRCPCols)
			If aRCPCols[n,nPosTpm] == "01"
				If dDataIn < aRCPCols[n,nPosDtM]
			   	dDataIn :=	Ctod("01/"+Substr(cMesAno,1,2)+"/"+Substr(cMesAno,3,4))
			   Endif	
		      Exit
		   Endif   
	   Next     
   Endif
   
   //Salario Integrado     
   For n:= 1 to Len(aRCPCols)
		dDataRef := aRCPCols[n,nPosDtM]
      If AnoMes(dDataRef) == cAnoMes
		   nSalMinInt:= FPosTab("S006", SRA->RA_CVEZON, "=", 4, NIL, NIl, NIL, 5) * nFatorSM
			If aRCPCols[n,nPosSal] < nSalMinInt
				lLog := .T.
				If aTotRegs[25]== 0
					cLog := STR0028 //"Salario Integrado menor que o Salario Minimo Integrado"
					Aadd(aTitle,cLog)  
					Aadd(aLog,{})
					aTotRegs[25] := len(aLog)
				Endif	
				Aadd(aLog[aTotRegs[25]],Space(10)+SRA->RA_MAT + "-" + SRA->RA_NOME)  
				exit
			EndIf
   	Endif
   Next     
   
Endif	                 

If nPosRe > 0 
	//Quando o funcionario possuir reingresso anterior ao mes de geracao, os dados de Admissao devem ser substituidos
	//pelos dados de Reingresso
	nPos01 := Ascan(aRCPCols,{ |X| x[nPosTpm]== "01"}) 
	If nPos01 > 0
		aRCPCols[nPos01,nRCPUsado+1] := .T.
		aRCPCols[nPosRe,nPosTpm] := "01"
	Else
		cLog := OemToAnsi( STR0029 ) //"Funcionario nao possui Ingresso para o Registro Patronal selecionado"
		Aadd(aTitle,cLog)  
		Aadd(aLog,{})
		aTotRegs[25] := len(aLog)
		Aadd(aLog[aTotRegs[25]],Space(10)+SRA->RA_MAT + "-" + SRA->RA_NOME)  
	EndIf
Endif

If !lLog
	nSalIntAtu	:= 0
	nSalIvAtu	:= 0 
   
   //Grava os movimentos do mes/movimento de alta / ultima baixa qdo houver reingreso no mes
	For n:= 1 to Len(aRCPCols) 
		cUltTpMov := aRCPCols[n,nPosTpM]
		If AnoMes(aRCPCols[n,nPosDtM]) == cAnoMes .or. (aRCPCols[n,nPosTpM]=="01" .And. aRCPCols[n,nRCPUsado+1] <> .T.);
			.or. Ascan(aDemis ,{ |X| x[1]== aRCPCols[n,nPosTpM] .And. x[2]== aRCPCols[n,nPosDtM]}) > 0
			nSeq ++
			cSeq := StrZero(nSeq,2)
			
			//Só gera desconto de infonavit caso a data maior que o credito infonavit
			If aRCPCols[n,nPosDtM] <= SRA->RA_DTCINF
				If lGeraInfo
					If ( aRCPCols[n,nPosTpm] == "01" )
						nDescInf := 0
					Else 
						nDescInf := SRA->RA_VALINF 
					EndIf
				Else
					nDescInf := 0
				EndIf
			Else
				nDescInf := nDesconto
			EndIf
			aAdd(aGrava,{		aRCPCols[n,nPosFil]	,;		//01-Filial
								aRCPCols[n,nPosMat]	,;		//02-Matricula
								cRegPat				,;		//03-Registro Patronal
								aRCPCols[n,nPosSal]	,;		//04-Salario Diario Integrado
								aRCPCols[n,nPosTei]	,;		//05-Tipo de Empregado IMSS
								aRCPCols[n,nPosTsi]	,;		//06-Tipo de Salario IMSS
								aRCPCols[n,nPosTjr] ,;		//07-Tipo de Jornada IMSS
								SRA->RA_KEYLOC		,;		//08-Localidade de Pago
								cInfonavit    		,;		//09-Numero de Credito Infonavit
								dDataIn       		,;		//10-Data de Credito Infonavit
								cTpInfo       		,;		//11-Tipo de Infonavit
								nDescInf     		,;		//12-Valor Desconto Infonavit
								aRCPCols[n,nPosTpm]	,; 		//13-Tipo de Movimento
								cAnoMes				,;		//14-Ano-Mes Processamento
								cSeq				,;		//15-Sequencia de Movimento
								aRCPCols[n,nPosDtI]	,; 		//16-Data de Envio IMSS
								aRCPCols[n,nPosHrI]	,; 		//17-Hora de Envio IMSS
								0      				,;		//18-Numero de Dias Trabalhados no mes
								0					,;		//19-Numero de dias de Faltas/Incap.
								aRCPCols[n,nPosDtM]	,;		//20-Data do Movimento
								""					,;		//21-Numero do Folio
								Alltrim(SRA->RA_PRISOBR)+" "+Alltrim(SRA->RA_SECSOBR)+" "+	;
								Alltrim(SRA->RA_PRINOME)+" "+Alltrim(SRA->RA_SECNOME),		;	//22-Nome do Funcionario
								aRCPCols[n,nPosIVC]	,; 		//23-Salario Diario IVCV        
								0					 ;		//24-Numero de Dias Totais de Faltas/Aus.
								})
		Endif
		If aRCPCols[n,nPosTpM] == "01"  .And. aRCPCols[n,nRCPUsado+1] == .F.
			dDataInicio := aRCPCols[n,nPosDtM]
		Endif	   	
		//Guarda o valor do salario para atualizar o tipo de movimento 01
		If aRCPCols[n,nRCPUsado+1] == .F. .And. ((AnoMes(aRCPCols[n,nPosDtM])<> cAnomes .And. aRCPCols[n,nPosTpM]== "05" ;
			.And. !Empty(dDataInicio) .And. dDataInicio < aRCPCols[n,nPosDtM] ) .or. (nSalIntAtu == 0 .And.;
			aRCPCols[n,nPosTpM]<> "05"))
			nSalIntAtu	:= aRCPCols[n,nPosSal]
			nSalIvAtu	:= aRCPCols[n,nPosIVC]
		Endif	
	Next n
	             
	//Verifica se deve gerar Infonavit 
	// apenas para mes par e para funcionario com numero de credito Infonavit informado
	If lGeraInfo
		//Gera registro Infonavit - registro de 15 a 20
		gp450Info(dDataPar)
	EndIf

	cInfonavit 	:= ""
	dDataIn		:= Ctod("//")
   cTpInfo		:= "" 
	
	nPos := 0
	nPos := Ascan(aGrava,{ |X| x[1]==aRCPCols[1,nPosFil] .And. x[2]==aRCPCols[1,nPosMat] .And. x[3]==cRegPat .And. x[13] == "01" }) 
	//Atualiza o salario quando o ultimo movimento da trajetorio nao for uma admissao nem um reingresso
	If nPos > 0 .And. cUltTpMov <> "01" 
		aGrava[nPos,4]:= nSalIntAtu
		aGrava[nPos,23]:= nSalIvAtu
	Endif

	If nVolunt > 0 .And. SRA->RA_CODRPAT == cCodRPat
		nSeq ++
		cSeq := StrZero(nSeq,2)
		aAdd(aGrava,{	SRA->RA_FILIAL			,;		//01-Filial
							SRA->RA_MAT			,;		//02-Matricula
							cRegPat				,;		//03-Registro Patronal
							nVolunt				,;    	//04-Salario Diario Integrado
							SRA->RA_TIPINF  	,;		//05-Tipo de Empregado IMSS
							SRA->RA_TSIMSS 		,;		//06-Tipo de Salario IMSS
							SRA->RA_TJRNDA 		,;		//07-Tipo de Jornada IMSS
							SRA->RA_KEYLOC		,;		//08-Localidade de Pago
							""            		,;		//09-Numero de Credito Infonavit
							Ctod("//")    		,;		//10-Data de Credito Infonavit
							""            		,;		//11-Tipo de Infonavit
							nDesconto      		,;		//12-Valor Desconto Infonavit
							"09"				,; 		//13-Tipo de Movimento
							cAnoMes				,;		//14-Ano/Mes Processamento
							cSeq				,;		//15-Sequencia de Movimento
							Ctod("//")       	,; 		//16-Data de Envio IMSS
							""      			,; 		//17-Hora de Envio IMSS
							0   				,;		//18-Numero de Dias Trabalhados no mes
							0					,;		//19-Numero de dias de Faltas/Incap.
							dDataPag  			,;    	//20-Data do Movimento
							""					,;	   	//21-Numero do Folio
							Alltrim(SRA->RA_PRISOBR)+" "+Alltrim(SRA->RA_SECSOBR)+" "+	;
							Alltrim(SRA->RA_PRINOME)+" "+Alltrim(SRA->RA_SECNOME),		;	 //22-Nome do Funcionario		
							0 					,;		//23-Salario IVCV
							0					 ;		//24-Numero de Dias Totais de Faltas/Aus.
							})									
	Endif
Endif

RestArea(aGetArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GP450AUSE ºAutor  ³Microsiga           º Data ³  04/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica arquivo de Ausencias e grava no array             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                       
Static Function Gp450Ause()

Local cAliasSR8 := ""
Local nUltdia  := 0                                        
Local nFaltas := 0
Local nIncapa := 0
Local cTipoMov := ""
Local nPosSal  	:= GdFieldPos( "RCP_SALDII"	 , aHeaderRCP )	
Local nPosIvc  	:= GdFieldPos( "RCP_SALIVC"	 , aHeaderRCP )	
Local nPosTei  	:= GdFieldPos( "RCP_TEIMSS" , aHeaderRCP )	
Local nPosTsi  	:= GdFieldPos( "RCP_TSIMSS" , aHeaderRCP )	
Local nPosTjr  	:= GdFieldPos( "RCP_TJRNDA" , aHeaderRCP )	
Local nPosMat  	:= GdFieldPos( "RCP_MAT"	 , aHeaderRCP )	
Local nSalDiario  := 0
Local nSalIVC		:= 0
Local	cTipoEmp    := ""
Local	cTipoSal    := ""
Local	cTipoJor    := ""
Local cMat		   := ""
Local nDiaAusSeg := 0
Local cTipoIm := If(lFalSua == "S","1*2*3","2*3" )
Local nDias 		:= 0                                       	
Local lModSal  := .F.
Local aDataMod := {}
Local ny:= 0
Local dDataIni := ctod("//")
Local dDataFim := ctod("//")
Local nDuracao := 0
#IFDEF TOP     
	Local cQuery    := ""
	Local aStru		:= {}      //Estrutura da Query
	Local n := 0
#ENDIF

dDataRef := Ctod("01/"+Left(cMesAno,2)+"/"+ Right(cMesAno,4))           
nUltDia := F_ULTDIA(dDataRef)

If Len(aRCPCols) > 0
	nSalDiario := aRCPCols[Len(aRCPCols),nPosSal]	
	cTipoEmp   := aRCPCols[Len(aRCPCols),nPosTei]	
	cTipoSal   := aRCPCols[Len(aRCPCols),nPosTsi]	
	cTipoJor   := aRCPCols[Len(aRCPCols),nPosTjr] 
	cMat		  := aRCPCols[Len(aRCPCols),nPosMat] 
	nSalIVC    := aRCPCols[Len(aRCPCols),nPosIVC]	
Endif

dbSelectArea("RCM")
dbSetOrder(1)

dbSelectArea("SR8")
dbSetOrder(RetOrdem("SR8","R8_FILIAL+R8_CODRPAT+R8_MAT+DTOS(R8_DATA)"))

cAliasSR8 := "SR8"

#IFDEF TOP
	IF TcSrvType() != "AS/400"
		aStru := SR8->(dbStruct())

		//-->Obtem a posicao dos campos para a clausula ORDER BY
		nPosFil := cValToChar( aScan( aStru, { |x| x[1] == "R8_FILIAL"} ) )   //Posicao da Filial
		nPosRPt := cValToChar( aScan( aStru, { |x| x[1] == "R8_CODRPAT"} ) )  //Posicao do Registro Patronal
		nPosMat := cValToChar( aScan( aStru, { |x| x[1] == "R8_MAT"} ) )      //Posicao do Codigo Registro Patronal
	
		cAliasSR8 := "QSR8"
		cQuery := "SELECT * "
		cQuery += " FROM " +	RetSqlName("SR8")
		cQuery += " WHERE R8_FILIAL ='"+SRA->RA_FILIAL+ "' AND "
		cQuery += "R8_MAT ='"+SRA->RA_MAT + "' AND "
		cQuery += "R8_CODRPAT ='"+cCodRPat + "' AND "
		cQuery += "D_E_L_E_T_<> '*' " 
		cQuery += "ORDER BY " + nPosFil + "," + nPosRPt + "," + nPosMat
		
		cQuery := ChangeQuery( cQuery )
		
		If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cAliasSR8,.T.,.T.)
			For n := 1 To Len(aStru)
				If ( aStru[n][2] <> "C" )
					TcSetField(cAliasSR8,aStru[n][1],aStru[n][2],aStru[n][3],aStru[n][4])
				EndIf
			Next n
		Endif
	Else
		dbSelectArea("SR8")
		(cAliasSR8)->(dbSetOrder(RetOrdem("SR8","R8_FILIAL+R8_CODRPAT+R8_MAT+DTOS(R8_DATA)")))
		dbSeek(xFilial(cAliasSR8)+cCodRPat+cMat )
	Endif	
#ELSE	
	dbSelectArea("SR8")
	(cAliasSR8)->(dbSetOrder(RetOrdem("SR8","R8_FILIAL+R8_CODRPAT+R8_MAT+DTOS(R8_DATA)")))
	dbSeek(xFilial(cAliasSR8)+cCodRPat+cMat )
#ENDIF
	
ProcRegua((cAliasSR8)->(RecCount()))

While (cAliasSR8)->(!EOF()) .And. (cAliasSR8)->(R8_FILIAL + R8_CODRPAT+R8_MAT) == SRA->RA_FILIAL+cCodRPat+cMat
	If (!Empty((cAliasSR8)->R8_DATAFIM) .And. MesAno((cAliasSR8)->R8_DATAFIM) < MesAno(dDataRef)) .or.;
		(MesAno((cAliasSR8)->R8_DATAINI) > MesAno(dDataRef) .Or. MesAno((cAliasSR8)->R8_DATAINI) < MesAno(dDataRef)) .Or. (cAliasSR8)->R8_DURACAO == 0
		(cAliasSR8)->(dbSkip())
		Loop
	Endif
		
	nDias 	:= nFaltas := nIncapa:=  0
	nDuracao := 0
	lModSal 	:= .F.
	aDataMod := {}
	dbSelectArea("RCM")
	RCM->(dbSetOrder(1))
	If RCM->( dbSeek(xFilial("RCM")+(cAliasSR8)->R8_TIPOAFA))
		If !(RCM->RCM_TPIMSS $ cTipoIm)
			(cAliasSR8)->(dbSkip())
			Loop
		Endif
		cTipoDia := gp240RetCont("RCM",1,"  "+(cAliasSR8)->R8_TIPOAFA,"RCM_TIPODI","(RCM->RCM_TIPO = '" + (cAliasSR8)->R8_TIPOAFA+ "')")
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica os dias de ausencias do Funcionario, mas sempre considerando que os dias sao corridos, mesmo ³
		//³ que no cadastro esteja como dias uteis, caso esteja como dias uteis considerar somente a data inicial³
		//³ e a duracao da ausencia                                                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AnoMes((cAliasSR8)->R8_DATAINI + (cAliasSR8)->R8_DURACAO) >= AnoMes(dDataRef)
			dDataIni := (cAliasSR8)->R8_DATAINI
			dDataFim := ((cAliasSR8)->R8_DATAINI + (cAliasSR8)->R8_DURACAO)-1
			GpVerMod(@lModSal, @aDataMod, dDataIni, dDataFim , (cAliasSR8)->R8_MAT )
	   Endif
	   If AnoMes((cAliasSR8)->R8_DATAINI) == AnoMes(dDataRef)
			nDuracao := (cAliasSR8)->R8_DURACAO
	   EndIf
         	
		For ny:= 1 to Len(aDataMod)-1
      	GpRetDia(@nDias, "2", aDataMod[ny,1], aDataMod[ny+1,1]-1)
         aDataMod[ny,2]:= If(nDias <= 7, nDias, 7)

			If RCM->RCM_TPIMSS == "1"
				nFaltas   := aDataMod[ny,2]
			ElseIf RCM->RCM_TPIMSS == "2"
				nIncapa   := nDias
			Endif
           
			If nFaltas + nIncapa > 0  .And. !lLog
				nSeq ++           
				cSeq := StrZero(nSeq,2)
  	   		cTipoMov :=If(nFaltas > 0,"11","12")

		      nDiaAusSeg :=If(nFaltas > 0,nFaltas,nIncapa)
				aAdd(aGrava,{(cAliasSR8)->R8_FILIAL				,;		//01-Filial
								(cAliasSR8)->R8_MAT 			,;		//02-Matricula
								cRegPat							,;		//03-Registro Patronal
								nSalDiario          			,; 		//04-Salario Diario Integrado
								cTipoEmp            			,;		//05-Tipo de Empregado IMSS
								cTipoSal           				,;		//06-Tipo de Salario IMSS
								cTipoJor             			,;		//07-Tipo de Jornada IMSS
								SRA->RA_KEYLOC					,;		//08-Localidade de Pago
								""            					,;		//09-Numero de Credito Infonavit
								Ctod("//")    					,;		//10-Data de Credito Infonavit
								""            					,; 		//11-Tipo de Infonavit
								0             					,;		//12-Valor Desconto Infonavit
								cTipoMov            			,; 		//13-Tipo de Movimento
								cAnoMes							,;		//14-Ano-Mes Processamento
								cSeq							,;		//15-Sequencia de Movimento
								Ctod("//")  			      	,; 		//16-Data de Envio IMSS
								"" 			       				,; 		//17-Hora de Envio IMSS
								nUltDia							,;		//18-Numero de Dias Trabalhados no mes
								nDiaAusSeg						,;		//19-Numero de dias de Faltas/Aus. mes
								aDataMod[ny,1]           		,; 		//20-Data do Movimento
								(cAliasSR8)->R8_NCERINC			,;	   	//21-Numero do Folio
								Alltrim(SRA->RA_PRISOBR)+" "+Alltrim(SRA->RA_SECSOBR)+" "+;
								Alltrim(SRA->RA_PRINOME)+" "+Alltrim(SRA->RA_SECNOME),;//22-Nome do Funcionario			
								nSalIVC             			,; 		//23-Salario IVCV
								nDuracao						 ;    	//24-Numero de Dias Totais de Faltas/Aus.
								})									 
			Endif
		Next
   Endif
	(cAliasSR8)->(dbSkip())
Enddo

dbSelectArea(cAliasSR8)
dbClosearea()

dbSelectArea("SR8")
dbSetOrder(1)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPVerMod  ºAutor  ³Microsiga           º Data ³  08/18/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se ocorreu uma modificacao salarial entre a Data  º±±
±±º          ³ Inicial e data Final da Licenca                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GpVerMod(lModSal,aDataMod,dDtIniAus,dDtFimAus,cMatr)

Local nx
Default lModSal := .F.

AADD(aDataMod,{dDtIniAus, 0})

For nx:= 1 to Len(aRCPCols)
	If aRCPCols[nx,1] == xFilial("SR8") .And.;
		aRCPCols[nx,2] == cMatr .And.;         
		aRCPCols[nx,4] == '05' .And.;
		aRCPCols[nx,3] > dDtIniAus .And.;
		aRCPCols[nx,3] < dDtFimAus
		lModSal := .T. 
		AADD(aDataMod,{aRCPCols[nx,3], 0})
	Endif	
Next 

AADD(aDataMod,{dDtFimAus+1, 0})

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPRetDia  ºAutor  ³Microsiga           º Data ³  08/18/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna a Quantidade de Dias de Licenca                    º±±
±±º          ³ Tipo 1 - Dias uteis                                        º±±
±±º          ³ Tipo 2 - Dias Corridos                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GpRetDia(nDias,cTipoDia,dDtIniAus,dDtFimAus)

If (cTipoDia == "2")
	nDias 	:= dDtFimAus - (dDtIniAus-1)
ElseIf cTipoDia == "1"
	LocGHabRea(dDtIniAus 	,; //Data Inicial
				  dDtFimAus	,; //Data Final
				  @nDias	,; //Retorna num. dias uteis
  	  			  NIL		,; //Retorna num. dias totais
				  .F.		,; //Retorna a diferenca entre o num. dias totais e num. dias uteis
				  NIL		,; //Num. horas
				  .T.		)  //Desconsiderar Sabado como dia util
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GP450GrvRCQºAutor  ³Microsiga           º Data ³  04/11/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava informacoes no arquivo RCQ - Historico SUA            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GP450GrvRCQ()
       
Local nx := 0

For nx := 1 to len(aGrava)                              
	dbSelectArea("RCQ")
	If Reclock("RCQ",.T.)
 		RCQ->RCQ_FILIAL := aGrava[nx,1] 
		RCQ->RCQ_MAT	:= aGrava[nx,2] 
		RCQ->RCQ_NREPAT	:= aGrava[nx,3] 
		RCQ->RCQ_SALDII := aGrava[nx,4] 
		RCQ->RCQ_TEIMSS := aGrava[nx,5] 
		RCQ->RCQ_TSIMSS	:= aGrava[nx,6] 
		RCQ->RCQ_TJRNDA	:= aGrava[nx,7] 
		RCQ->RCQ_KEYLOC	:= aGrava[nx,8] 
		RCQ->RCQ_NUMINF	:= aGrava[nx,9] 
		RCQ->RCQ_DTCINF := aGrava[nx,10] 
		RCQ->RCQ_TIPINF	:= aGrava[nx,11] 
		RCQ->RCQ_VALINF	:= aGrava[nx,12] 
		RCQ->RCQ_TPMOV 	:= aGrava[nx,13] 
		RCQ->RCQ_ANOMES	:= aGrava[nx,14] 
		RCQ->RCQ_SEQMVT	:= aGrava[nx,15] 
		RCQ->RCQ_DTIMSS	:= aGrava[nx,16] 
		RCQ->RCQ_HRIMSS	:= aGrava[nx,17] 
		RCQ->RCQ_NDTRAB	:= aGrava[nx,18] 
		RCQ->RCQ_NDIF 	:= aGrava[nx,19] 
		RCQ->RCQ_DTMOV 	:= aGrava[nx,20] 
		RCQ->RCQ_FOLIO 	:= aGrava[nx,21] 
		RCQ->RCQ_NOME	:= aGrava[nx,22]
		RCQ->RCQ_SALIVC	:= aGrava[nx,23]      
		RCQ->RCQ_NDIFT	:= aGrava[nx,24]
	 	MsUnlock()
	Endif	
		If aTotRegs[9]== 0
			cLog := STR0015 //"Empleado Gravado"
			Aadd(aTitle,cLog)  
			Aadd(aLog,{})
			aTotRegs[9] := len(aLog)
		Endif	
		Aadd(aLog[aTotRegs[9]],Space(10)+ aGrava[nx,3]+ "  " +aGrava[nx,2]+ ;
		"  "+PadR(aGrava[nx,22],40)+"  "+aGrava[nx,13]+ "  " + dtoc(aGrava[nx,20]) )
Next nx      

Return( NIL )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³f450Organ ºAutor  ³Silvia Taguti       º Data ³  12/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Organiza o array aGrava em ordem de Registro patronal,   . º±±
±±º          ³matricula, anomes, seqmovto e tipo de moviemento            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA450                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function f450Organ(aGrava)

Asort( aGrava,,,{|x,y|x[3]+x[2]+x[14]+x[15]+x[13] < y[3]+y[2]+y[14]+y[15]+y[13]}) //

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ Gp450Infoº Autor ³ Tatiane Matias     º Data ³  06/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Geracao do arquivo Infonavit                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA450 - Mexico                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp450Info(dDataPar)

Local nReg 			:= 0
Local aInfo			:= {}
Local cTpMov   		:= ""   
Local dDtAux		:= CTOD("//")
Local nDesconto		:= 0 
Local dDtValAlt		:= CTOD("//")
Local dDtTpAlt		:= CTOD("//")   
Local cTipo			:= ""           
Local nValor		:= 0
Local nSalario		:= 0			//Salario Integrado
Local nSalIVC		:= 0			//Salario Diario 
Local cTpJrda		:= ""
Local cTeIMSS		:= ""
Local cTsIMSS		:= ""
//Obter informações do histórico, da tabela RCP
Local nPosRCP		:= 0
Local nPosFil  		:= GdFieldPos( "RCP_FILIAL"	 , aHeaderRCP )
Local nPosMat  		:= GdFieldPos( "RCP_MAT"	 , aHeaderRCP )
Local nPosDta		:= GdFieldPos( "RCP_DTMOV"	 , aHeaderRCP )
Local nPosSal		:= GdFieldPos( "RCP_SALINS"	 , aHeaderRCP )
Local nPosSalIVC	:= GdFieldPos( "RCP_SALIVC"	 , aHeaderRCP )
Local nTpJrda		:= GdFieldPos( "RCP_TJRNDA"	 , aHeaderRCP )
Local nTeIMSS		:= GdFieldPos( "RCP_TEIMSS"	 , aHeaderRCP )
Local nTsIMSS		:= GdFieldPos( "RCP_TSIMSS"	 , aHeaderRCP )
dDataRef := Ctod("01/"+Left(cMesAno,2)+"/"+ Right(cMesAno,4))           
      
	//Verifica se teve alteracao no valor para gerar registro tipo "19"
	nValor 	:= gpRetSR9("SR9", dDataRef, "RA_VALINF", @dDtValAlt)
	cTipo 	:= gpRetSR9("SR9", dDataRef, "RA_TIPINF", @dDtTpAlt)     
	nDesconto := If(Empty(nValor), SRA->RA_VALINF, nValor )
                            
	//Cria array com as informacoes necessarias para gerar o registro no RCQ
	gp450GerInfo(@aInfo)
                 
	/*
	aInfo[n, 1] - Tipo de Movimento
	aInfo[n, 2] - Data da Alteracao
	aInfo[n, 3] - Data de inicio de Credito Infonavit 
	aInfo[n, 4] - Data de inicio de Suspensao 
	aInfo[n, 5] - Data de Reinicio de Desconto 
	aInfo[n, 6] - Data de modificacao do tipo de desconto Nro Credito
	aInfo[n, 7] - Data de modificacao do nro do credito
	aInfo[n, 8] - Tipo de Desconto 
	aInfo[n, 9] - Nro Credito Infonavit 
	aInfo[n,10] - Valor do Infonavit (Representa o percentual de desconto) - Igor (23/07/2009)
	*/ 

	For nReg := 1 to Len(aInfo)   
		cTpMov := aInfo[nReg, 1]
		While ("*" $ cTpMov)
			cTpAux := Substr(cTpMov, 1, (AT("*", cTpMov) - 1))
			cTpMov := Substr(cTpMov, (AT("*", cTpMov) + 1))
			nDesconto := If(Empty(aInfo[ nReg, 10 ]), SRA->RA_VALINF, aInfo[ nReg, 10 ] ) //Desconto do historico - Igor (23/07/2009)
			nSalario := 0
			nSalIVC  := 0
			cTpJrda  := ""
			cTeIMSS  := ""
			cTsIMSS	 := ""
			dDtAux := If(cTpAux == "15", aInfo[nReg, 3], ;
						    If(cTpAux == "16", aInfo[nReg, 4],;
						    If(cTpAux == "17", aInfo[nReg, 5],;
						    If(cTpAux == "18", aInfo[nReg, 6],;
						    If(cTpAux == "20", aInfo[nReg, 7], CTOD("//")))))) 
						    
			nSeq ++
			cSeq := StrZero(nSeq,2)
			// A parte de dias da suspensao nao devem ser calculados, pois ja pertence ao primeiro registro //
			If cTpAux == "16"
				nDesconto := 0
			EndIf
			If MesAno(dDtAux) >= MesAno(dDataPar) .and. MesAno(dDtAux) <= MesAno(dDataRef)
				//Consiste informações da tabela RCP, considerar campos do histórico e não do SRA
				//Exemplo: Salario - Considera modificações a partir de uma data
				For nPosRCP := 1 To Len(aRCPCols)
					If (	aRCPCols[ nPosRCP, nPosFil ] == SRA->RA_FILIAL .and. ;
							aRCPCols[ nPosRCP, nPosMat ] == SRA->RA_MAT .and. ;
							aRCPCols[ nPosRCP, nPosDta ] <= dDtAux )
						nSalario := aRCPCols[ nPosRCP, nPosSal ]
						nSalIVC  := aRCPCols[ nPosRCP, nPosSalIVC ]
						cTpJrda  := aRCPCols[ nPosRCP, nTpJrda ]
						cTeIMSS  := aRCPCols[ nPosRCP, nTeIMSS ]
						cTsIMSS	 := aRCPCols[ nPosRCP, nTsIMSS ]
					EndIf
				Next
				//Caso não obtenha exito na busca 				
				If ( nSalario == 0 )
					nSalario := SRA->RA_SALINT
				EndIf
				
				If ( nSalIVC == 0 )
					nSalIVC := SRA->RA_SALIVC
				EndIf   
								
				If ( cTpJrda == "" )
					cTpJrda	:= SRA->RA_TJRNDA
				EndIf
				 
				If ( cTeIMSS == "" )
					cTeIMSS := SRA->RA_TEIMSS
				EndIf
				
				If ( cTsIMSS == "" )
					cTsIMSS := SRA->RA_TSIMSS
				EndIf
	  			aAdd(aGrava,{	SRA->RA_FILIAL			,;		//Filial
		 	 					   SRA->RA_MAT			,;		//Matricula
		 		 				   cRegPat				,;		//Registro Patronal
				 					nSalario			,;		//Salario Diario Integrado
			  						cTeIMSS		 		,;		//Tipo de Empregado IMSS
			  						cTsIMSS		 		,;		//Tipo de Salario IMSS
									cTpJrda		 		,;		//Tipo de Jornada IMSS
									SRA->RA_KEYLOC		,;		//Localidade de Pago
						  			aInfo[nReg, 9]   	,;		//Numero de Credito Infonavit
									aInfo[nReg, 3]		,;		//Data de Credito Infonavit
									aInfo[nReg, 8]  	,; 	//Tipo de Infonavit
									nDesconto		  	,;		//Valor Desconto Infonavit
									cTpAux				,; 		//Tipo de Movimento
									cAnoMes				,;		//Ano-Mes Processamento
									cSeq				,;		//Sequencia de Movimento
									Ctod("//")     		,; 		//Data de Envio IMSS
									""      			,; 		//Hora de Envio IMSS
									0      				,;		//Numero de Dias Trabalhados no mes
									0					,;		//Numero de dias de Faltas/Incap.
									dDtAux				,; 	//Data do Movimento
									""					,;	 	// Numero do Folio
									Alltrim(SRA->RA_PRISOBR)+" "+Alltrim(SRA->RA_SECSOBR)+" "+;
									Alltrim(SRA->RA_PRINOME)+" "+Alltrim(SRA->RA_SECNOME),;//Nome do Funcionario
									nSalIVC				,; 	//Salario Diario IVCV
									0						 ;		//Numero de Dias Totais de Faltas/Aus.
								})
			EndIf
		EndDo	
	Next nReg
	
Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ gp450GerInfoº Autor ³ Tatiane Matias     º Data ³  06/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Geracao do arquivo Infonavit                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA450 - Mexico                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function gp450GerInfo(aDados)
/*
Retorno:        
aDados[n, 1] - Tipo de Movimento
aDados[n, 2] - Data da Alteracao
aDados[n, 3] - Data de inicio de Credito Infonavit 
aDados[n, 4] - Data de inicio de Suspensao 
aDados[n, 5] - Data de Reinicio de Desconto 
aDados[n, 6] - Data de modificacao do tipo de desconto Nro Credito
aDados[n, 7] - Data de modificacao do nro do credito
aDados[n, 8] - Tipo de Desconto 
aDados[n, 9] - Nro Credito Infonavit 
*/
               
Local dDtAlt   := CTOD("//")
Local dDtIni   := CTOD("//")
Local dDtSusp  := CTOD("//")
Local dDtRein  := CTOD("//")
Local dDtModTp	:= CTOD("//")
Local dDtModNr	:= CTOD("//")   
Local cTpMov	:= ""       
Local cTpInfo	:= ""    
Local cInfo		:= ""
Local nDescInfo := 0				//Valor de desconto de infonavit - Igor (23/07/2009)
Local cAliasSR9:= "SR9"   
                                                         
	#IFDEF TOP
		Local cQuery	:= ""   
		Local aStru		:= {} 
		Local n			:= 0
		IF TcSrvType() != "AS/400"
			cAliasSR9 := "QSR9"
		
			cQuery := "SELECT * "
			cQuery += " FROM " +	RetSqlName("SR9")
			cQuery += " WHERE R9_FILIAL ='"+ SRA->RA_FILIAL + "' AND "
			cQuery += "R9_MAT ='"+SRA->RA_MAT + "' AND "
			cQuery += "D_E_L_E_T_<> '*' " 
			cQuery += "ORDER BY R9_FILIAL, R9_MAT, R9_DATA, R9_CAMPO"
			
			cQuery := ChangeQuery( cQuery )
			aStru := SR9->(dbStruct())
			
			If  MsOpenDbf(.T.,"TOPCONN",TcGenQry(, ,cQuery),cAliasSR9,.T.,.T.)
				For n := 1 To Len(aStru)
					If ( aStru[n][2] <> "C" )
						TcSetField(cAliasSR9,aStru[n][1],aStru[n][2],aStru[n][3],aStru[n][4])
					EndIf
				Next n
			Endif
		Else
			dbSelectArea("SR9")       
			(cAliasSR9)->( dbSetOrder(2) )
			(cAliasSR9)->( dbSeek(SRA->RA_FILIAL + SRA->RA_MAT) )
		Endif	
	#ELSE	                 
		dbSelectArea("SR9")       
		(cAliasSR9)->( dbSetOrder(2) )
		(cAliasSR9)->( dbSeek(SRA->RA_FILIAL + SRA->RA_MAT) )
	#ENDIF

	While (cAliasSR9)->( !Eof() .and. R9_FILIAL + R9_MAT == SRA->RA_FILIAL + SRA->RA_MAT)
		If Empty(dDtAlt)
			dDtAlt := (cAliasSR9)->R9_DATA 
		EndIf

		Do Case
			Case ( AllTrim((cAliasSR9)->R9_CAMPO) == "RA_DTCINF" ) 		
				dDtIni := CTOD((cAliasSR9)->R9_DESC)
				cTpMov += "15*"
			Case ( Alltrim((cAliasSR9)->R9_CAMPO) == "RA_DTISINF" )
				dDtSusp := CTOD((cAliasSR9)->R9_DESC)
				cTpMov  += "16*"
			Case ( Alltrim((cAliasSR9)->R9_CAMPO) == "RA_DTRDINF" )
				dDtRein := CTOD((cAliasSR9)->R9_DESC)
				cTpMov  += "17*"
			Case ( Alltrim((cAliasSR9)->R9_CAMPO) == "RA_DTMDINF" )
				dDtModTp	:= CTOD((cAliasSR9)->R9_DESC)
				cTpMov   += "18*"
			Case ( Alltrim((cAliasSR9)->R9_CAMPO) == "RA_DTMNINF" )
				dDtModNr	:= CTOD((cAliasSR9)->R9_DESC)
				cTpMov   += "20*"
			Case ( Alltrim((cAliasSR9)->R9_CAMPO) == "RA_TIPINF" )
				cTpInfo	:= (cAliasSR9)->R9_DESC   
			Case ( Alltrim((cAliasSR9)->R9_CAMPO) == "RA_NUMINF" )
				cInfo	:= (cAliasSR9)->R9_DESC  
			Case ( Alltrim((cAliasSR9)->R9_CAMPO) == "RA_VALINF" ) 
				nDescInfo := Val((cAliasSR9)->R9_DESC)
		End Case
		dbSkip()

		If dDtAlt <> (cAliasSR9)->R9_DATA
			If !Empty(dDtAlt) .and. !Empty(cTpMov)
			                       
				If Empty(dDtIni) 
					//Pegar a data de inicio no historico - SR9. 
					// Caso nao tenho essa informacao no SR9, buscar do SRA
					dDtIni 	:= gpRetSR9(cAliasSR9, dDtAlt, "RA_DTCINF")
				EndIf
				
				If Empty(dDtSusp)
					//Pegar a data de suspensao no historico - SR9. 
					// Caso nao tenho essa informacao no SR9, retornar data vazia
					dDtSusp := gpRetSR9(cAliasSR9, dDtAlt, "RA_DTISINF")
				EndIf
				
				If Empty(dDtRein) .and. !("17" $ cTpMov)
					//Pegar a data de reinicio no historico - SR9. 
					// Caso nao tenho essa informacao no SR9, retornar data vazia
					dDtRein 	:= gpRetSR9(cAliasSR9, dDtAlt, "RA_DTRDINF")
				EndIf
				
				If Empty(cTpInfo)
					//Pegar o tipo de desconto no historico - SR9. 
					// Caso nao tenho essa informacao no SR9, buscar do SRA
					cTpInfo	:= gpRetSR9(cAliasSR9, dDtAlt, "RA_TIPINF")
				EndIf
				If Empty(dDtModTp)
					//Pegar a data de modificacao do tipo de desconto no historico - SR9. 
					// Caso nao tenho essa informacao no SR9, retornar data vazia
					dDtModTp := gpRetSR9(cAliasSR9, dDtAlt, "RA_DTMDINF")
				EndIf
				
				If Empty(cInfo)  
					//Pegar o numero de credito no historico - SR9. 
					// Caso nao tenho essa informacao no SR9, buscar do SRA
					cInfo 	:= gpRetSR9(cAliasSR9, dDtAlt, "RA_NUMINF")
				EndIf
				If Empty(dDtModNr)
					//Pegar a data de modificacao do numero de credito no historico - SR9. 
					// Caso nao tenho essa informacao no SR9, retornar data vazia
					dDtModNr := gpRetSR9(cAliasSR9, dDtAlt, "RA_DTMNINF")
				EndIf
				
				If Empty(nDescInfo)
					nDescInfo := gpRetSR9(cAliasSR9, dDtAlt, "RA_VALINF")
				EndIf
				aAdd(aDados, {cTpMov, dDtAlt, dDtIni, dDtSusp, dDtRein, dDtModTp, dDtModNr, cTpInfo, cInfo, nDescInfo })
			EndIf             
			
			dDtAlt := (cAliasSR9)->R9_DATA 
			dDtIni	:= CTOD("//")
			dDtSusp	:= CTOD("//")
			dDtRein	:= CTOD("//")
			dDtModTp	:= CTOD("//")
			dDtModNr	:= CTOD("//")
			cTpMov	:= ""
			cTpInfo	:= ""
			cInfo		:= ""
		EndIf
		
	EndDo

	#IFDEF TOP
		dbSelectArea(cAliasSR9)
		dbClosearea()
	#ENDIF

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ gpRetSR9    º Autor ³ Tatiane Matias     º Data ³  08/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Retorna o conteudo do campo passado como parametro do SR9     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPEA450 - Mexico                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function gpRetSR9( cAlias, dDataAlt, cCampo, dDtAltRet )

Local aArea 		:= (cAlias)->( GetArea() )
Local uConteudo
Local cAliasSR9		:= "SR9"   
Local cTipo 		:= " "
	                                 
dbSelectArea("SR9")   

(cAliasSR9)->( dbSetOrder(1) )
(cAliasSR9)->( DbGoTop() )
(cAliasSR9)->( dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + cCampo) )

dDtAltRet := CTOD("//")

While (cAliasSR9)->( !Eof() .and. AllTrim(R9_FILIAL + R9_MAT + R9_CAMPO) == AllTrim(SRA->RA_FILIAL + SRA->RA_MAT + cCampo))
	If dDataAlt >= (cAliasSR9)->R9_DATA
		uConteudo := (cAliasSR9)->R9_DESC 
		dDtAltRet := (cAliasSR9)->R9_DATA
		cTipo     := GetSx3Cache( Upper( AllTrim( (cAliasSR9)->R9_CAMPO ) ) , "X3_TIPO" )
		If cTipo == "D"
			uConteudo :=  Ctod(AllTrim( (uConteudo )))
		ElseIf cTipo == "N"
			uConteudo := Val( replace(uConteudo,",","." )) 
		Else
			uConteudo := uConteudo
		Endif
	Else
		If cCampo $ "RA_TIPINF*RA_NUMINF" .and. Empty(uConteudo)
			uConteudo := (cAliasSR9)->R9_DESC 
			dDtAltRet := (cAliasSR9)->R9_DATA
			cTipo     := GetSx3Cache( Upper( AllTrim( (cAliasSR9)->R9_CAMPO ) ) , "X3_TIPO" )
			If cTipo == "D"
				uConteudo :=  Ctod(AllTrim( (uConteudo )))
			ElseIf cTipo == "N"
				uConteudo :=  Val( replace(uConteudo,",","." ))
			Else
				uConteudo := uConteudo
			Endif
		EndIf
		Exit				
	EndIf		
	dbSkip()
EndDo

If Empty(uConteudo)
	Do Case
		Case cCampo == "RA_DTCINF"
			uConteudo := SRA->RA_DTCINF
		Case cCampo == "RA_TIPINF"
			uConteudo := SRA->RA_TIPINF
		Case cCampo == "RA_NUMINF"
			uConteudo := SRA->RA_NUMINF
		Case cCampo $ "RA_DTISINF*RA_DTRDINF*RA_DTMDINF*RA_DTMNINF"
			uConteudo := CTOD("//")
		Case cCampo == "RA_NUMINF"
			uConteudo := SRA->RA_VALINF			
		Case cCampo == "RA_KEYLOC"
			uConteudo := SRA->RA_KEYLOC
		Case cCampo == "RA_HRSMES"
			uConteudo := SRA->RA_HRSMES
		Case cCampo == "RA_DEPIR"
			uConteudo := SRA->RA_DEPIR
		Case cCampo == "RA_PERCSAT"
			uConteudo := SRA->RA_PERCSAT
		Case cCampo == "RA_DEPSF"
			uConteudo := SRA->RA_DEPSF
	End Case
EndIF	

RestArea(aArea)

Return ( uConteudo )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FChkCont      ³ Autor ³ Tatiane Matias   ³ Data ³ 17/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que valida o conteudo do campo. Verifica se o campo ³±±
±±³          ³ possue caracter especial ou se o campo soh tem numeros.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FChkCont()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. Quando o conteudo esta correto                         ³±±
±±³          ³ .F. Quando o conteudo estiver invalido                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA450                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FChkCont(cTexto,cTpValid)

Local aChrValidos	:={}
Local cChrTexto 	:= Space(01)
Local nPos			:= 0
Local j				:= 0  
Local lRet			:= .T.
                                  
DEFAULT cTpValid := "C"
// "C" - validar caracter especial
// "N" - validar numero

If cPaisLoc == "MEX"
	If cTpValid == "C"
		aChrValidos := {"A","B","C","D","E","F","G","H","I",;
				  	 		 "J","K","L","M","N","O","P","Q","R",;
					 		 "S","T","U","V","X","Z","W","Y"," ",;
							 "a","b","c","d","e","f","g","h","i",;
							 "j","k","l","m","n","o","p","q","r",;
							 "s","t","u","v","x","z","w","y",;
							 "ä",; //"„"
							 "á",; //" "
							 "à",; //"…"
							 "â",; //"ƒ"
							 "ã",; //"~a"
							 "ª",; //"¦"
							 "†",;
							 "Ä",; //""	  
							 "Á",; //"'A"
							 "À",; //"`A"
							 "Â",; //"^A"
							 "Ã",; //"~A"
							  "",;
							 "ë",; //"‰"
							 "é",; //"‚"
							 "è",; //"Š"
							 "ê",; //"ˆ"
							 "Ë",; //"‰" maiusculo
							 "É",; //""
							 "È",; //"`E"
							 "Ê",; //"^E"
							 "ï",; //"‹"
							 "í",; //"¡"
							 "ì",; //""
							 "î",; //"Œ"
							 "Ï",; //"‹" maiusculo
							 "Í",; //"'I"
							 "Ì",; //"`I"
							 "Î",; //"^I"
							 "ö",; //"”"
							 "ó",; //"¢"
							 "ò",; //"•"
							 "ô",; //"“"
							 "õ",; //"~o"
							 "º",; //"§"
							 "Ö",; //"™"
							 "Ó",; //"'O"
							 "Ò",; //"`O"
							 "Ô",; //"^O"
							 "Õ",; //"~O"
							 "ü",; //"š" minusculo
							 "ú",; //"£"
							 "ù",; //"—"
							 "û",; //"–"
							 "Ü",; //"š"
							 "Ú",; //"'U"
							 "Ù",; //"`U"
							 "Û",; //"^U"
							 "Ç",; //"€"
							 "ç",; //"‡"
							 "ñ",; //"¤"
							 "Ñ",; //"¥"
							 ".",; //"."
							 "#"}
					 		 
	Else
		aChrValidos := {"0","1","2","3","4","5","6","7","8","9"}
	EndIf

	For j:=1 TO Len(AllTrim(cTexto))
		cChrTexto	:=SubStr(cTexto,j,1)
		nPos 	:= Ascan(aChrValidos,cChrTexto)
		If nPos = 0
			lRet := .F.
			exit
		EndIf
	Next j
EndIf

Return lRet
