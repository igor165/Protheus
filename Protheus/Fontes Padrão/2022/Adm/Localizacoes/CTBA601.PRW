#include "Protheus.ch"
#include "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "CTBA601.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออหออออออออออหอออออออหออออออออออออออออออออหออออออหอออออออออออออปฑฑ
ฑฑบPrograma  บCTBA601   บAutor  บLuis Samaniego      บFecha บ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออสออออออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     บCatalogo de Cuentas SAT                                     บฑฑ
ฑฑบ          บ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       บ SIGACTB                                                    บฑฑ
ฑฑฬออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             บฑฑ
ฑฑฬออออออออออออหออออออออหอออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador บ Data   บLlamadoบ  Motivo da Alteracao                    บฑฑ
ฑฑฬออออออออออออลออออออออลอออออออลอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบL.Samaniego บ05/07/17บMMI-   บ Contabilidad Electronica Version 1.3    บฑฑ
ฑฑบ            บ        บ  5976 บ                                         บฑฑ
ฑฑบDiego Riveraบ04/07/19บDMINA- บSe actualiza proceso de carga de Catแlogoบฑฑ
ฑฑบ            บ        บ  6982 บpara que ya no sea cargada la informaci๓nบฑฑ
ฑฑบ            บ        บ       บapartir del catแlogo hardcodeo en el     บฑฑ
ฑฑบ            บ        บ       บfuente, solamente a trav้s del archivo   บฑฑ
ฑฑบ            บ        บ       บCuentas_Sat.csv. Fue borrado el catแlogo บฑฑ
ฑฑบ            บ        บ       บhardcodeado de la funci๓n CargaSat.      บฑฑ
ฑฑบ            บ        บ       บLa funci๓n ActPlanCtas() fue borrada asํ บฑฑ
ฑฑบ            บ        บ       บcomo la secci๓n que la llamaba. (Mex)    บฑฑ
ฑฑศออออออออออออสออออออออสอออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBA601()
Local cAlias	 := "CWD"
Local cTitulo	 := STR0001 //"Cuentas del SAT"
Local cVldExc	 := "VldCWDDel()" 
Local cVldAlt	 := "VldCWDNivel()"//".T."                                                                                           
Local lEsArch    := .F.
Local cNewArch   := "Procesado_Cuentas_SAT.csv" 	  
Local cTablaZM   := SuperGetMV("MV_CTBMPAG", .T., '')

Private cPath    := Alltrim(SuperGetMV("MV_CTBPATH",,"C:\Temp\Contabilidad\"))   //C:\Temp\Contabilidad\   
Private cArchivo := "Cuentas_SAT.csv" 
Private cPathArc := Iif(!Empty(cPath),Iif((Substr(cPath,len(cPath),1)=="\"),cPath,cPath+"\")+cArchivo,cArchivo)
Private aCuentas := {}     
Private oTmpTable := Nil
Private cFilCWD  := xFilial("CWD")

//Cargar Metodos de Pago
If  !Empty(cTablaZM)
	CTBMPgoSAT(cTablaZM)
EndIf

DbSelectArea("CWD")
DbSetOrder(1) //CWD_FILIAL+CWD_CODIGO

If  !Empty(cPath) .And. File(cPathArc)  //Existe la ruta y el archivo "Cuentas_SAT.CSV"
	If !CWD->(dbSeek(cFilCWD+"NO APLICA")) //Si no existe informacion
		lEsArch  := .T.   
	Else //Existe informaci๓n
		If  Msgyesno(STR0020)  //ฟProcede a actualizar el catalogo de cuentas?
			lEsArch  := .T.   
		Endif
	Endif
	
	If lEsArch
		Processa( {|| CargaCtas() }, STR0022, "",.F.) //"Leyendo catแlogo de cuentas SAT..."
	EndIf
	
Else
	If !CWD->(dbSeek(cFilCWD+"NO APLICA")) //Si no existe archivo y no existe informaci๓n
		MsgAlert(STR0021) //"Configure el parแmetro MV_CTBPATH con la ruta donde se encuentra el archivo Cuentas_SAT.csv y verifique que dicho archivo estแ en esa ruta."
	Endif
Endif

If  len(aCuentas)>0  
	
	DbSelectArea("CWD")
	DbSetOrder(1) //CWD_FILIAL+CWD_CODIGO
	//Elimina el catแlogo (Limpia tabla CWD).
	BorraCat("CWD","")
		
	Processa( {|| CargaCwd(aCuentas) }, STR0023, "",.F.) //"Cargando catแlogo de cuentas SAT..."
	
	//Renombrar el archivo
	cNewArch := Iif(!Empty(cPath),Iif((Substr(cPath,len(cPath),1)=="\"),cPath,cPath+"\")+cNewArch,cNewArch)
    FRename(cPathArc,cNewArch)
	 
EndIf 

dbSelectArea(cAlias)
dbsetorder(1) //CWD_FILIAL+CWD_CODIGO  
AxCadastro(cAlias,cTitulo,cVldExc)

Return                                         

  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldCWDExistบAutor ณLuis Samaniego      บFecha ณ  24/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Al incluir un nuevo registro valida que el codigo no       บฑฑ
ฑฑบ          ณ existe.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTB                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VldCWDExist()  				  	 
Local lr      := .T.  
Local cCod    := &(Alltrim(ReadVar())) //M->CWD_CODIGO para que aplique para Cuenta y Subcuenta
Local cVarCOD :=  Alltrim(ReadVar())
    
	If !Empty(cCod) 
		If "CWD_CODIGO" $ cVarCOD	//Codigo Agrupador
			Dbselectarea("CWD")	  
			CWD->(DBSETORDER(RETORDEM("CWD","CWD_FILIAL+CWD_CODIGO")))
			If CWD->(DBSEEK( XFILIAL("CWD") + cCod ))	
		  		Aviso( OemToAnsi(STR0003), OemToAnsi(STR0004), {STR0002} ) //OemToAnsi("Atenci๓n"), OemToAnsi("กEl C๓digo ya existe!."), {"OK"}
		  		lr := .f.
			Endif    
		ElseIf	"CT1_CODAGR" $ cVarCOD	//SubCuenta De
			Dbselectarea("CWD")	  
			CWD->(DBSETORDER(RETORDEM("CWD","CWD_FILIAL+CWD_CODIGO")))
			If  !CWD->(DBSEEK( XFILIAL("CWD") + cCod ))	 
				Aviso( OemToAnsi(STR0003), OemToAnsi(STR0012), {STR0002} ) //OemToAnsi("Atenci๓n"), OemToAnsi("El Codigo no existe, verifique!"), {"OK"}
				lr := .F.
			Endif     
		Endif
	ElseIf "CWD_CODIGO" $ cVarCOD
		Aviso( OemToAnsi(STR0003), OemToAnsi(STR0005), {STR0002} )  //"กEl c๓digo es un dato obligatorio!"
		lr := .F.	 
    Endif
Return lr             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldCWDDel บAutor  ณLuis Samaniego      บFecha ณ  24/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Al borrar valida que el codigo en la tabla CWD no este     บฑฑ
ฑฑบ          ณ referenciada a algun registro en CT1 en el campo CT1_CODAGRบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VldCWDDel()   
Local lr   := .T.  
Local cCod := CWD->CWD_CODIGO
Local nNo := 0													
	
	dbselectarea("CT1")	  
	CT1->(DBSETORDER(RETORDEM("CT1","CT1_FILIAL+CT1_CODAGR")))
	If CT1->(DBSEEK( XFILIAL("CT1") + cCod ))	
  		Aviso( OemToAnsi(STR0003), OemToAnsi(STR0006 + CRLF + STR0007), {STR0002} )
  		lr := .F. 
  	EndIf   
  	
  	If lr
		nNo := Aviso( OemToAnsi(STR0003), OemToAnsi(STR0008 + Alltrim(cCod)+" - "+ Alltrim(CWD->CWD_DESCRI) + "?"), {STR0009,STR0010} )  //"ฟEstแ seguro de querer borrar la cuenta " "Si","No"
	  	
	  	If nNo == 2
			lr := .F.	
		EndIf
	Endif  
Return lr 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VldCTBMesบAutor  ณLuis Samaniego      บFecha ณ  24/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica que numero de mes sea valido.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VldCTBMes(cValMes)
Local lr        := .F. 
	If cValMes $("01|02|03|04|05|06|07|08|09|10|11|12")
		lr := .T.	
	EndIf
Return lr

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VldCTBAnoบAutor  ณLuis Samaniego      บFecha ณ  24/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica que numero de a๑o sea valido.                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VldCTBAno(cValAno)
Local lr        := .F.  
	If Val(cValAno) >= 2013 .And. Val(cValAno) <= 2099
		lr := .T.	
	EndIf
Return lr

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMonedaSAT บAutor  ณ Luis Samaniego       บ Data ณ  03/10/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ  													        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 				                                           	    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBMoedSAT(cTabla)
Local nI         := 0
Local lEsArch    := .F.
Local cNewArch   := "Procesado_Monedas_SAT.csv" 	  

Private cPath    := Alltrim(SuperGetMV("MV_CTBPATH",,"C:\Temp\Contabilidad\"))   //C:\Temp\Contabilidad\   
Private cArchivo := "Monedas_SAT.csv" 
Private cPathArc := Iif(!Empty(cPath),Iif((Substr(cPath,len(cPath),1)=="\"),cPath,cPath+"\")+cArchivo,cArchivo)
Private aSX5     := {}

DbSelectArea("SX5")
SX5->(DbSetOrder(1))

If  !Empty(cPath) .And. File(cPathArc)  //Existe la ruta y el archivo "Cuentas_SAT.CSV", se debe cargar
	CargaMon(1,cTabla) //Lee el archivo y lo carga
	lEsArch  := .T.
Else
	If !dbSeek( Space(Len(SX5->X5_FILIAL)) + cTabla )     //Si no existe informacion se carga
		CargaMon(2,cTabla) //Carga el contenido	  	
	Elseif dbSeek(xFilial("SX5")+cTabla+Padr('1',TAMSX3("X5_CHAVE")[1]))  //Encuentra el catalogo anterior	
		CargaMon(2,cTabla) //Carga el contenido	 
	Endif
Endif

If  len(aSX5)>0 
	DbSelectArea("SX5")
	SX5->(DbSetOrder(1))
	
	//Elimina solo esta vez el catalogo
	If dbSeek(xFilial("SX5")+cTabla+Padr('1',TAMSX3("X5_CHAVE")[1]))   
	   BorraCat("SX5"," X5_TABELA ='00' AND X5_CHAVE = '"+Padr(cTabla,TAMSX3("X5_CHAVE")[1])+"'" )
	   BorraCat("SX5"," X5_TABELA ='"+Padr(cTabla,TAMSX3("X5_CHAVE")[1])+"'" )
	Endif                         
	
	Begin Transaction
		For nI := 1 To Len(aSX5)
			If !dbSeek(xFilial("SX5")+aSX5[nI][02]+aSX5[nI][03])
				RecLock("SX5",.T.)
				Replace X5_FILIAL		With aSX5[nI][1]
				Replace X5_TABELA		With aSX5[nI][2]
				Replace X5_CHAVE 		With aSX5[nI][3]
				Replace X5_DESCSPA 	    With aSX5[nI][4]
				Replace X5_DESCENG   	With aSX5[nI][5]
				Replace X5_DESCRI		With aSX5[nI][6]
				MsUnLock()
			EndIf
		Next
	End Transaction
		
	If  lEsArch    //Renombrar el archivo
		cNewArch := Iif(!Empty(cPath),Iif((Substr(cPath,len(cPath),1)=="\"),cPath,cPath+"\")+cNewArch,cNewArch)
	    FRename(cPathArc,cNewArch)
	Endif

EndIf 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMonedaSAT  บAutor  ณ Luis Samaniego      บ Data ณ  03/10/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ  															บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 				                                           	    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/      
Function CTBBancSAT(cTabla)
Local aSX5     := {}
Local nI       := 0  

	DbSelectArea("SX5")
	SX5->(DbSetOrder(1))
	If !dbSeek( Space(Len(SX5->X5_FILIAL)) + cTabla )
	
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), "00", cTabla, "Catแlogo de Bancos SAT", "Catแlogo de Bancos SAT", "Catแlogo de Bancos SAT" })
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "002", "Banco Nacional de M้xico", "Banco Nacional de M้xico", "Banco Nacional de M้xico"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "006", "Bancomext", "Bancomext", "Bancomext"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "009", "Banobras", "Banobras", "Banobras"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "012", "BBVA Bancomer", "BBVA Bancomer", "BBVA Bancomer"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "014", "Banco Santander", "Banco Santander", "Banco Santander"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "019", "Banco Nacional del Ej้rcito, Fuerza A้rea y Armada", "Banco Nacional del Ej้rcito, Fuerza A้rea y Armada", "Banco Nacional del Ej้rcito, Fuerza A้rea y Armada"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "021", "HSBC", "HSBC", "HSBC"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "030", "Banco del Bajํo", "Banco del Bajํo", "Banco del Bajํo"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "032", "IXE Banco", "IXE Banco", "IXE Banco"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "036", "Banco Inbursa", "Banco Inbursa", "Banco Inbursa"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "037", "Banco Interacciones", "Banco Interacciones", "Banco Interacciones"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "042", "Banca Mifel", "Banca Mifel", "Banca Mifel"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "044", "Scotiabank Inverlat", "Scotiabank Inverlat", "Scotiabank Inverlat"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "058", "Banco Regional de Monterrey", "Banco Regional de Monterrey", "Banco Regional de Monterrey"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "059", "Banco Invex", "Banco Invex", "Banco Invex"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "060", "Bansi", "Bansi", "Bansi"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "062", "Banca Afirme", "Banca Afirme", "Banca Afirme"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "072", "Banco Mercantil del Norte", "Banco Mercantil del Norte", "Banco Mercantil del Norte"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "102", "The Royal Bank", "The Royal Bank", "The Royal Bank"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "103", "American Express Bank", "American Express Bank", "American Express Bank"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "106", "Bank of Am้rica", "Bank of Am้rica", "Bank of Am้rica"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "108", "Bank of Tokyo-Mitsubichi", "Bank of Tokyo-Mitsubichi", "Bank of Tokyo-Mitsubichi"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "110", "Banco J.P. Morgan", "Banco J.P. Morgan", "Banco J.P. Morgan"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "112", "Banco Monex", "Banco Monex", "Banco Monex"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "113", "Banco Ve Por Mas", "Banco Ve Por Mas", "Banco Ve Por Mas"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "116", "ING Bank", "ING Bank", "ING Bank"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "124", "Deutsche Bank M้xico", "Deutsche Bank M้xico", "Deutsche Bank M้xico"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "126", "Banco Credit Suisse", "Banco Credit Suisse", "Banco Credit Suisse"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "127", "Banco Azteca", "Banco Azteca", "Banco Azteca"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "128", "Banco Autofin M้xico", "Banco Autofin M้xico", "Banco Autofin M้xico"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "129", "Barclays Bank M้xico", "Barclays Bank M้xico", "Barclays Bank M้xico"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "130", "Banco Compartamos", "Banco Compartamos", "Banco Compartamos"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "131", "Banco Famsa", "Banco Famsa", "Banco Famsa"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "132", "Banco Multiva", "Banco Multiva", "Banco Multiva"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "133", "Banco Actinver", "Banco Actinver", "Banco Actinver"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "134", "Banco Wal-Mart de M้xico AdeLante", "Banco Wal-Mart de M้xico AdeLante", "Banco Wal-Mart de M้xico AdeLante"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "135", "Nacional Financiera", "Nacional Financiera", "Nacional Financiera"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "136", "Inter Banco", "Inter Banco", "Inter Banco"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "137", "BanCoppel", "BanCoppel", "BanCoppel"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "138", "ABC Capital", "ABC Capital", "ABC Capital"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "139", "UBS Bank M้xico", "UBS Bank M้xico", "UBS Bank M้xico"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "140", "Consubanco", "Consubanco", "Consubanco"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "141", "VolksWagen Bank", "VolksWagen Bank", "VolksWagen Bank"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "143", "CIBanco", "CIBanco", "CIBanco"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "145", "Banco Base", "Banco Base", "Banco Base"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "166", "Banco del Ahorro Nacional y Servicios Financieros", "Banco del Ahorro Nacional y Servicios Financieros", "Banco del Ahorro Nacional y Servicios Financieros"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "168", "Sociedad Hipotecaria Federal", "Sociedad Hipotecaria Federal", "Sociedad Hipotecaria Federal"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "600", "Monex Casa de Bolsa", "Monex Casa de Bolsa", "Monex Casa de Bolsa"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "601", "GBM Grupo Bursแtil Mexicano", "GBM Grupo Bursแtil Mexicano", "GBM Grupo Bursแtil Mexicano"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "602", "Masari Casa de Bolsa", "Masari Casa de Bolsa", "Masari Casa de Bolsa"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "605", "Value", "Value", "Value"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "606", "Estructuradores del Mercado de Valores Casa de Bolsa", "Estructuradores del Mercado de Valores Casa de Bolsa", "Estructuradores del Mercado de Valores Casa de Bolsa"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "607", "Casa de Cambio Tiber", "Casa de Cambio Tiber", "Casa de Cambio Tiber"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "608", "Vector Casa de Bolsa", "Vector Casa de Bolsa", "Vector Casa de Bolsa"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "610", "B y B Casa de Cambio", "B y B Casa de Cambio", "B y B Casa de Cambio"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "614", "Acciones y Valores Banamex", "Acciones y Valores Banamex", "Acciones y Valores Banamex"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "615", "Merrill Lynch M้xico", "Merrill Lynch M้xico", "Merrill Lynch M้xico"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "616", "Casa de Bolsa Finamex", "Casa de Bolsa Finamex", "Casa de Bolsa Finamex"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "617", "Vaores Mexicanos Casa de Bolsa", "Vaores Mexicanos Casa de Bolsa", "Vaores Mexicanos Casa de Bolsa"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "618", "Unica Casa de Cambio", "Unica Casa de Cambio", "Unica Casa de Cambio"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "619", "Mapfre Tepeyac", "Mapfre Tepeyac", "Mapfre Tepeyac"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "620", "Profuturo G.N.P.", "Profuturo G.N.P.", "Profuturo G.N.P."})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "621", "Actinver Casa de Bolsa", "Actinver Casa de Bolsa", "Actinver Casa de Bolsa"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "622", "Operadora Actinver", "Operadora Actinver", "Operadora Actinver"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "623", "Skandia Vida ", "Skandia Vida ", "Skandia Vida "})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "626", "Deutsche Securities Casa de Bolsa", "Deutsche Securities Casa de Bolsa", "Deutsche Securities Casa de Bolsa"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "627", "Zurich Compa๑ํa de Seguros", "Zurich Compa๑ํa de Seguros", "Zurich Compa๑ํa de Seguros"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "628", "Zurich Vida, Compa๑ํa de Seguros", "Zurich Vida, Compa๑ํa de Seguros", "Zurich Vida, Compa๑ํa de Seguros"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "629", "Hipotecaria Su Casita", "Hipotecaria Su Casita", "Hipotecaria Su Casita"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "630", "Intercam Casa de Bolsa", "Intercam Casa de Bolsa", "Intercam Casa de Bolsa"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "631", "CI Casa de Bolsa", "CI Casa de Bolsa", "CI Casa de Bolsa"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "632", "Bulltick Casa de Bolsa", "Bulltick Casa de Bolsa", "Bulltick Casa de Bolsa"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "633", "Sterling Casa de Cambio", "Sterling Casa de Cambio", "Sterling Casa de Cambio"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "634", "Fincom๚n, Servicios Financieros Comunitarios", "Fincom๚n, Servicios Financieros Comunitarios", "Fincom๚n, Servicios Financieros Comunitarios"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "636", "HDI Seguros", "HDI Seguros", "HDI Seguros"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "637", "Order Express Casa de Cambio", "Order Express Casa de Cambio", "Order Express Casa de Cambio"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "638", "Akala Sociedad Financiera Popular", "Akala Sociedad Financiera Popular", "Akala Sociedad Financiera Popular"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "640", "J.P. Morgan casa de Bolsa", "J.P. Morgan casa de Bolsa", "J.P. Morgan casa de Bolsa"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "642", "Operadora de Recursos Reforma", "Operadora de Recursos Reforma", "Operadora de Recursos Reforma"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "646", "Sistema de Trasferencias y Pagos STP", "Sistema de Trasferencias y Pagos STP", "Sistema de Trasferencias y Pagos STP"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "647", "Telecomunicaciones de M้xico", "Telecomunicaciones de M้xico", "Telecomunicaciones de M้xico"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "648", "Evercore Casa de Bolsa", "Evercore Casa de Bolsa", "Evercore Casa de Bolsa"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "649", "Skandia Operadora de Fondos", "Skandia Operadora de Fondos", "Skandia Operadora de Fondos"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "651", "Seguros Monterrey New York Life", "Seguros Monterrey New York Life", "Seguros Monterrey New York Life"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "652", "Soluciones Asea", "Soluciones Asea", "Soluciones Asea"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "653", "Kuspit Casa de Bolsa", "Kuspit Casa de Bolsa", "Kuspit Casa de Bolsa"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "655", "J.P. Sofiexpress", "J.P. Sofiexpress", "J.P. Sofiexpress"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "656", "Unagra ", "Unagra ", "Unagra "})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "659", "Opciones Empresariales del Noreste", "Opciones Empresariales del Noreste", "Opciones Empresariales del Noreste"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "670", "Libertad Servicios Financieros", "Libertad Servicios Financieros", "Libertad Servicios Financieros"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "901", "Cls Bank International", "Cls Bank International", "Cls Bank International"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "902", "SD Indeval", "SD Indeval", "SD Indeval"})
		
		Begin Transaction
			For nI := 1 To Len(aSX5)
				If !dbSeek(xFilial("SX5")+aSX5[nI][02]+aSX5[nI][03])
					RecLock("SX5",.T.)
					Replace X5_FILIAL		With aSX5[nI][1]
					Replace X5_TABELA		With aSX5[nI][2]
					Replace X5_CHAVE 		With aSX5[nI][3]
					Replace X5_DESCSPA 	With aSX5[nI][4]
					Replace X5_DESCENG 	With aSX5[nI][5]
					Replace X5_DESCRI		With aSX5[nI][6]
					MsUnLock()
				EndIf
			Next
		End Transaction
		
	EndIf	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldCWDNivelบAutor ณLuis Samaniego      บFecha ณ  24/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validar el nivel de la cuenta                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTB                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VldCWDNivel()  				  	 
Local lr      := .T.  
Local cNivel    := M->CT1_NIVEL
Local cSubCtaDe    := M->CT1_CTASUP
Local aAreaCT1  := CT1->(GetArea())

    
    If Empty(cSubCtaDe)
    	If cNivel # "1"
    		Aviso( OemToAnsi(STR0003), OemToAnsi(STR0014), {STR0002} )
			lr := .F.	
		EndIf
	Else 
		If !(cNivel $ "2|3|4|5|6|7|8|9")
			Aviso( OemToAnsi(STR0003), OemToAnsi(STR0015), {STR0002} )
			lr := .F.
		Else 
			CT1->(dbselectarea("CT1"))   
			CT1->(DbSetOrder(RETORDEM("CT1","CT1_FILIAL+CT1_CONTA")))
			CT1->(DbGoTop())
			
			If CT1->(Dbseek(xFilial("CT1")+cSubCtaDe))
				If !Val(cNivel)-1 == Val(CT1->CT1_NIVEL)
					Aviso( OemToAnsi(STR0003), OemToAnsi(STR0018), {STR0002} )
					lr := .F.
				EndIf
			Else
				Aviso( OemToAnsi(STR0003), OemToAnsi(STR0019), {STR0002} )
				lr := .F.
			EndIf
		EndIf 	
    EndIf
   CT1->(RestArea(aAreaCT1))
Return lr 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCargaCtas บAutor  ณLaura Medina        บFecha ณ  09/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncion para cargar las cuentas del SAT por medio de archivoบฑฑ
ฑฑบ          ณCSV                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTB                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CargaCtas()  
Local aStruTmp := {} 
Local cArchivo := ""
Local nloop    := 0	

aCuentas := {}

Begin Sequence                              
	aAdd(aStruTmp,{ "NIVEL",	"C", 1,  0})
	aAdd(aStruTmp,{ "CODIGO",	"C", 10, 0})
	aAdd(aStruTmp,{ "DESCRI",	"C", 150,0})
	
	oTmpTable := FWTemporaryTable():New("TMP")
	oTmpTable:SetFields( aStruTmp )
	oTmpTable:Create()
	
	dbSelectArea("TMP")
	Append From (cPathArc) Delimited With ","
	dbGoTop()

	//Inicia regla de procesamiento
	ProcRegua( Reccount() )

	Do  While !TMP->(Eof())
		IncProc()

		//Inicializa campos y arreglos para items                                                                    //Subcuenta   //No tiene Subcuenta
  		aAdd(aCuentas,{cFilCWD,TMP->CODIGO,TMP->DESCRI,TMP->NIVEL})    
		TMP->(dbSkip())
	Enddo
	If len(aCuentas)>0 //Se agrega la cuenta NO APLICA
		aAdd(aCuentas,{cFilCWD,"NO APLICA","No aplica SAT","1" })
	Endif    
	
	If oTmpTable <> Nil
		oTmpTable:Delete()
		oTmpTable := Nil
	EndIf
	
End Sequence      
 
Return       


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCargaMon  บAutor  ณLaura Medina        บFecha ณ  09/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncion para cargar las monedas del SAT por medio de archivoบฑฑ
ฑฑบ          ณCSV                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTB                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CargaMon(nOpc,cTabla)  
Local aStruTmp := {} 
Local cArchivo := ""
Local nloop    := 0	  

aSX5 := {}
		
If  nOpc == 1

	Begin Sequence                              
		aAdd(aStruTmp,{ "CLAVE",	"C", 6,  0})
		aAdd(aStruTmp,{ "DESCRI",	"C", 150,0})
	   
		oTmpTable := FWTemporaryTable():New("TMP")
		oTmpTable:SetFields( aStruTmp )
		oTmpTable:Create()
		
		dbSelectArea("TMP")
		Append From (cPathArc) Delimited With ","
		dbGoTop()
	
		//Inicia regla de procesamiento
		ProcRegua( Reccount() )
	
		Do  While !TMP->(Eof())
			IncProc()
	
			//Inicializa campos y arreglos para items                                                                    
	  		aAdd(aSX5,{Space(Len(SX5->X5_FILIAL)),cTabla,TMP->CLAVE,TMP->DESCRI,TMP->DESCRI,TMP->DESCRI})    
			TMP->(dbSkip())
		Enddo	
		
		If len(aSX5)>0 //Se agrega la tabla (Encabezado)
			aAdd(aSX5,{Space(Len(SX5->X5_FILIAL)),"00",cTabla,"Catแlogo de Monedas SAT", "Catแlogo de Monedas SAT", "Catแlogo de Monedas SAT"})
		Endif    
		
		If oTmpTable <> Nil
			oTmpTable:Delete()
			oTmpTable := Nil
		EndIf
	
	End Sequence      

Elseif nOpc == 2       
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),"00",cTabla,"Catแlogo de Monedas SAT","Catแlogo de Monedas SAT","Catแlogo de Monedas SAT" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"AED","Dirham de los Emiratos มrabes Unidos","Dirham de los Emiratos มrabes Unidos","Dirham de los Emiratos มrabes Unidos" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"AFN","Afgani afgano","Afgani afgano","Afgani afgano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"ALL","Lek alban้s","Lek alban้s","Lek alban้s" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"AMD","Dram armenio","Dram armenio","Dram armenio" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"ANG","Florํn antillano neerland้s","Florํn antillano neerland้s","Florํn antillano neerland้s" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"AOA","Kwanza angole๑o","Kwanza angole๑o","Kwanza angole๑o" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"ARS","Peso argentino","Peso argentino","Peso argentino" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"AUD","D๓lar australiano","D๓lar australiano","D๓lar australiano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"AWG","Florํn arube๑o","Florํn arube๑o","Florํn arube๑o" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"AZN","Manat azerbaiyano","Manat azerbaiyano","Manat azerbaiyano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"BAM","Marco convertible de Bosnia-Herzegovina","Marco convertible de Bosnia-Herzegovina","Marco convertible de Bosnia-Herzegovina" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"BBD","D๓lar de Barbados","D๓lar de Barbados","D๓lar de Barbados" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"BDT","Taka de Banglad้s","Taka de Banglad้s","Taka de Banglad้s" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"BGN","Lev b๚lgaro","Lev b๚lgaro","Lev b๚lgaro" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"BHD","Dinar bahreinํ","Dinar bahreinํ","Dinar bahreinํ" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"BIF","Franco burund้s","Franco burund้s","Franco burund้s" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"BMD","D๓lar de Bermuda","D๓lar de Bermuda","D๓lar de Bermuda" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"BND","D๓lar de Brun้i","D๓lar de Brun้i","D๓lar de Brun้i" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"BOB","Boliviano","Boliviano","Boliviano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"BOV","Mvdol boliviano (c๓digo de fondos)","Mvdol boliviano (c๓digo de fondos)","Mvdol boliviano (c๓digo de fondos)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"BRL","Real brasile๑o","Real brasile๑o","Real brasile๑o" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"BSD","D๓lar bahame๑o","D๓lar bahame๑o","D๓lar bahame๑o" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"BTN","Ngultrum de Butแn","Ngultrum de Butแn","Ngultrum de Butแn" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"BWP","Pula de Botsuana","Pula de Botsuana","Pula de Botsuana" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"BYR","Rublo bielorruso","Rublo bielorruso","Rublo bielorruso" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"BZD","D๓lar de Belice","D๓lar de Belice","D๓lar de Belice" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"CAD","D๓lar canadiense","D๓lar canadiense","D๓lar canadiense" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"CDF","Franco congole๑o","Franco congole๑o","Franco congole๑o" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"CHF","Franco suizo","Franco suizo","Franco suizo" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"CLF","Unidades de fomento chilenas (c๓digo de fondos)","Unidades de fomento chilenas (c๓digo de fondos)","Unidades de fomento chilenas (c๓digo de fondos)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"CLP","Peso chileno","Peso chileno","Peso chileno" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"CNY","Yuan chino","Yuan chino","Yuan chino" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"COP","Peso colombiano","Peso colombiano","Peso colombiano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"COU","Unidad de valor real colombiana (a๑adida al COP)","Unidad de valor real colombiana (a๑adida al COP)","Unidad de valor real colombiana (a๑adida al COP)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"CRC","Col๓n costarricense","Col๓n costarricense","Col๓n costarricense" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"CSD","Dinar serbio (Reemplazado por RSD el 25 de octubre de 2006)","Dinar serbio (Reemplazado por RSD el 25 de octubre de 2006)","Dinar serbio (Reemplazado por RSD el 25 de octubre de 2006)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"CUP","Peso cubano","Peso cubano","Peso cubano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"CUC","Peso cubano convertible","Peso cubano convertible","Peso cubano convertible" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"CVE","Escudo caboverdiano","Escudo caboverdiano","Escudo caboverdiano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"CZK","Koruna checa","Koruna checa","Koruna checa" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"DJF","Franco yibutiano","Franco yibutiano","Franco yibutiano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"DKK","Corona danesa","Corona danesa","Corona danesa" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"DOP","Peso dominicano","Peso dominicano","Peso dominicano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"DZD","Dinar argelino","Dinar argelino","Dinar argelino" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"EGP","Libra egipcia","Libra egipcia","Libra egipcia" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"ERN","Nakfa eritreo","Nakfa eritreo","Nakfa eritreo" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"ETB","Birr etํope","Birr etํope","Birr etํope" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"EUR","Euro","Euro","Euro" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"FJD","D๓lar fiyiano","D๓lar fiyiano","D๓lar fiyiano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"FKP","Libra malvinense","Libra malvinense","Libra malvinense" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"GBP","Libra esterlina (libra de Gran Breta๑a)","Libra esterlina (libra de Gran Breta๑a)","Libra esterlina (libra de Gran Breta๑a)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"GEL","Lari georgiano","Lari georgiano","Lari georgiano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"GHS","Cedi ghan้s","Cedi ghan้s","Cedi ghan้s" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"GIP","Libra de Gibraltar","Libra de Gibraltar","Libra de Gibraltar" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"GMD","Dalasi gambiano","Dalasi gambiano","Dalasi gambiano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"GNF","Franco guineano","Franco guineano","Franco guineano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"GTQ","Quetzal guatemalteco","Quetzal guatemalteco","Quetzal guatemalteco" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"GYD","D๓lar guyan้s","D๓lar guyan้s","D๓lar guyan้s" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"HKD","D๓lar de Hong Kong","D๓lar de Hong Kong","D๓lar de Hong Kong" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"HNL","Lempira hondure๑o","Lempira hondure๑o","Lempira hondure๑o" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"HRK","Kuna croata","Kuna croata","Kuna croata" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"HTG","Gourde haitiano","Gourde haitiano","Gourde haitiano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"HUF","Forint h๚ngaro","Forint h๚ngaro","Forint h๚ngaro" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"IDR","Rupiah indonesia","Rupiah indonesia","Rupiah indonesia" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"ILS","Nuevo sh้quel israelํ","Nuevo sh้quel israelํ","Nuevo sh้quel israelํ" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"INR","Rupia india","Rupia india","Rupia india" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"IQD","Dinar iraquํ","Dinar iraquํ","Dinar iraquํ" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"IRR","Rial iranํ","Rial iranํ","Rial iranํ" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"ISK","Kr๓na islandesa","Kr๓na islandesa","Kr๓na islandesa" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"JMD","D๓lar jamaicano","D๓lar jamaicano","D๓lar jamaicano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"JOD","Dinar jordano","Dinar jordano","Dinar jordano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"JPY","Yen japon้s","Yen japon้s","Yen japon้s" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"KES","Chelํn keniata","Chelํn keniata","Chelํn keniata" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"KGS","Som kirguํs (de Kirguistแn)","Som kirguํs (de Kirguistแn)","Som kirguํs (de Kirguistแn)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"KHR","Riel camboyano","Riel camboyano","Riel camboyano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"KMF","Franco comoriano (de Comoras)","Franco comoriano (de Comoras)","Franco comoriano (de Comoras)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"KPW","Won norcoreano","Won norcoreano","Won norcoreano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"KRW","Won surcoreano","Won surcoreano","Won surcoreano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"KWD","Dinar kuwaitํ","Dinar kuwaitํ","Dinar kuwaitํ" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"KYD","D๓lar caimano (de Islas Caimแn)","D๓lar caimano (de Islas Caimแn)","D๓lar caimano (de Islas Caimแn)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"KZT","Tenge kazajo","Tenge kazajo","Tenge kazajo" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"LAK","Kip lao","Kip lao","Kip lao" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"LBP","Libra libanesa","Libra libanesa","Libra libanesa" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"LKR","Rupia de Sri Lanka","Rupia de Sri Lanka","Rupia de Sri Lanka" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"LRD","D๓lar liberiano","D๓lar liberiano","D๓lar liberiano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"LSL","Loti lesotense","Loti lesotense","Loti lesotense" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"LTL","Litas lituano","Litas lituano","Litas lituano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"LVL","Lat let๓n","Lat let๓n","Lat let๓n" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"LYD","Dinar libio","Dinar libio","Dinar libio" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"MAD","Dirham marroquํ","Dirham marroquํ","Dirham marroquํ" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"MDL","Leu moldavo","Leu moldavo","Leu moldavo" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"MGA","Ariary malgache","Ariary malgache","Ariary malgache" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"MKD","Denar macedonio","Denar macedonio","Denar macedonio" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"MMK","Kyat birmano","Kyat birmano","Kyat birmano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"MNT","Tughrik mongol","Tughrik mongol","Tughrik mongol" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"MOP","Pataca de Macao","Pataca de Macao","Pataca de Macao" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"MRO","Ouguiya mauritana","Ouguiya mauritana","Ouguiya mauritana" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"MUR","Rupia mauricia","Rupia mauricia","Rupia mauricia" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"MVR","Rufiyaa maldiva","Rufiyaa maldiva","Rufiyaa maldiva" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"MWK","Kwacha malauํ","Kwacha malauํ","Kwacha malauํ" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"MXN","Peso mexicano","Peso mexicano","Peso mexicano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"MXV","Unidad de Inversi๓n (UDI) mexicana (c๓digo de fondos)","Unidad de Inversi๓n (UDI) mexicana (c๓digo de fondos)","Unidad de Inversi๓n (UDI) mexicana (c๓digo de fondos)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"MYR","Ringgit malayo","Ringgit malayo","Ringgit malayo" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"MZN","Metical mozambique๑o","Metical mozambique๑o","Metical mozambique๑o" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"NAD","D๓lar namibio","D๓lar namibio","D๓lar namibio" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"NGN","Naira nigeriana","Naira nigeriana","Naira nigeriana" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"NIO","C๓rdoba nicaragüense","C๓rdoba nicaragüense","C๓rdoba nicaragüense" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"NOK","Corona noruega","Corona noruega","Corona noruega" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"NPR","Rupia nepalesa","Rupia nepalesa","Rupia nepalesa" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"NZD","D๓lar neozeland้s","D๓lar neozeland้s","D๓lar neozeland้s" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"OMR","Rial omanํ","Rial omanํ","Rial omanํ" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"PAB","Balboa paname๑a","Balboa paname๑a","Balboa paname๑a" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"PEN","Nuevo sol peruano","Nuevo sol peruano","Nuevo sol peruano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"PGK","Kina de Pap๚a Nueva Guinea","Kina de Pap๚a Nueva Guinea","Kina de Pap๚a Nueva Guinea" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"PHP","Peso filipino","Peso filipino","Peso filipino" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"PKR","Rupia pakistanํ","Rupia pakistanํ","Rupia pakistanํ" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"PLN","zloty polaco","zloty polaco","zloty polaco" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"PYG","Guaranํ paraguayo","Guaranํ paraguayo","Guaranํ paraguayo" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"QAR","Rial qatarํ","Rial qatarํ","Rial qatarํ" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"RON","Leu rumano","Leu rumano","Leu rumano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"RUB","Rublo ruso","Rublo ruso","Rublo ruso" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"RWF","Franco ruand้s","Franco ruand้s","Franco ruand้s" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"SAR","Riyal saudํ","Riyal saudํ","Riyal saudํ" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"SBD","D๓lar de las Islas Salom๓n","D๓lar de las Islas Salom๓n","D๓lar de las Islas Salom๓n" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"SCR","Rupia de Seychelles","Rupia de Seychelles","Rupia de Seychelles" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"SDG","Dinar sudan้s","Dinar sudan้s","Dinar sudan้s" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"SEK","Corona sueca","Corona sueca","Corona sueca" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"SGD","D๓lar de Singapur","D๓lar de Singapur","D๓lar de Singapur" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"SHP","Libra de Santa Helena","Libra de Santa Helena","Libra de Santa Helena" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"SLL","Leone de Sierra Leona","Leone de Sierra Leona","Leone de Sierra Leona" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"SOS","Chelํn somalํ","Chelํn somalํ","Chelํn somalํ" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"SRD","D๓lar surinam้s","D๓lar surinam้s","D๓lar surinam้s" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"STD","Dobra de Santo Tom้ y Prํncipe","Dobra de Santo Tom้ y Prํncipe","Dobra de Santo Tom้ y Prํncipe" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"SYP","Libra siria","Libra siria","Libra siria" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"SZL","Lilangeni suazi","Lilangeni suazi","Lilangeni suazi" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"THB","Baht tailand้s","Baht tailand้s","Baht tailand้s" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"TJS","Somoni tayik (de Tayikistแn)","Somoni tayik (de Tayikistแn)","Somoni tayik (de Tayikistแn)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"TMT","Manat turcomano","Manat turcomano","Manat turcomano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"TND","Dinar tunecino","Dinar tunecino","Dinar tunecino" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"TOP","Pa'anga tongano","Pa'anga tongano","Pa'anga tongano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"TRY","Lira turca","Lira turca","Lira turca" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"TTD","D๓lar de Trinidad y Tobago","D๓lar de Trinidad y Tobago","D๓lar de Trinidad y Tobago" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"TWD","D๓lar taiwan้s","D๓lar taiwan้s","D๓lar taiwan้s" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"TZS","Chelํn tanzano","Chelํn tanzano","Chelํn tanzano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"UAH","Grivna ucraniana","Grivna ucraniana","Grivna ucraniana" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"UGX","Chelํn ugand้s","Chelํn ugand้s","Chelํn ugand้s" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"USD","D๓lar estadounidense","D๓lar estadounidense","D๓lar estadounidense" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"USN","D๓lar estadounidense (Siguiente dํa) (c๓digo de fondos)","D๓lar estadounidense (Siguiente dํa) (c๓digo de fondos)","D๓lar estadounidense (Siguiente dํa) (c๓digo de fondos)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"USS","D๓lar estadounidense (Mismo dํa) (c๓digo de fondos)","D๓lar estadounidense (Mismo dํa) (c๓digo de fondos)","D๓lar estadounidense (Mismo dํa) (c๓digo de fondos)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"UYU","Peso uruguayo","Peso uruguayo","Peso uruguayo" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"UZS","Som uzbeko","Som uzbeko","Som uzbeko" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"VEF","Bolํvar fuerte venezolano","Bolํvar fuerte venezolano","Bolํvar fuerte venezolano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"VND","Dong vietnamita","Dong vietnamita","Dong vietnamita" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"VUV","Vatu vanuatense","Vatu vanuatense","Vatu vanuatense" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"WST","Tala samoana","Tala samoana","Tala samoana" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"XAF","Franco CFA de มfrica Central","Franco CFA de มfrica Central","Franco CFA de มfrica Central" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"XAG","Onza de plata","Onza de plata","Onza de plata" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"XAU","Onza de oro","Onza de oro","Onza de oro" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"XBA","European Composite Unit (EURCO) (unidad del mercado de bonos)","European Composite Unit (EURCO) (unidad del mercado de bonos)","European Composite Unit (EURCO) (unidad del mercado de bonos)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"XBB","European Monetary Unit (E.M.U.-6) (unidad del mercado de bonos)","European Monetary Unit (E.M.U.-6) (unidad del mercado de bonos)","European Monetary Unit (E.M.U.-6) (unidad del mercado de bonos)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"XBC","European Unit of Account 9 (E.U.A.-9) (unidad del mercado de bonos)","European Unit of Account 9 (E.U.A.-9) (unidad del mercado de bonos)","European Unit of Account 9 (E.U.A.-9) (unidad del mercado de bonos)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"XBD","European Unit of Account 17 (E.U.A.-17) (unidad del mercado de bonos)","European Unit of Account 17 (E.U.A.-17) (unidad del mercado de bonos)","European Unit of Account 17 (E.U.A.-17) (unidad del mercado de bonos)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"XCD","D๓lar del Caribe Oriental","D๓lar del Caribe Oriental","D๓lar del Caribe Oriental" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"XDR","Derechos Especiales de Giro (FMI)","Derechos Especiales de Giro (FMI)","Derechos Especiales de Giro (FMI)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"XFO","Franco de oro (Special settlement currency)","Franco de oro (Special settlement currency)","Franco de oro (Special settlement currency)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"XFU","Franco UIC (Special settlement currency)","Franco UIC (Special settlement currency)","Franco UIC (Special settlement currency)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"XOF","Franco CFA de มfrica Occidental","Franco CFA de มfrica Occidental","Franco CFA de มfrica Occidental" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"XPD","Onza de paladio","Onza de paladio","Onza de paladio" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"XPF","Franco CFP","Franco CFP","Franco CFP" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"XPT","Onza de platino","Onza de platino","Onza de platino" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"XTS","Reservado para pruebas","Reservado para pruebas","Reservado para pruebas" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"XXX","Sin divisa","Sin divisa","Sin divisa" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"YER","Rial yemenํ (de Yemen)","Rial yemenํ (de Yemen)","Rial yemenํ (de Yemen)" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"ZAR","Rand sudafricano","Rand sudafricano","Rand sudafricano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"ZMW","Kwacha zambiano","Kwacha zambiano","Kwacha zambiano" })
	aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)),cTabla,"ZWL","D๓lar zimbabuense","D๓lar zimbabuense","D๓lar zimbabuense" })

Endif    

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBorraCat  บAutor  ณLaura Medina        บFecha ณ  10/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncion para borrar catalogos, solo mientras tengan constan-บฑฑ
ฑฑบ          ณtes cambios.    b                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTB                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BorraCat(cAliasElm,cWhere)
Local cQuery := ""

	cQuery := "DELETE FROM " +RetSqlName(cAliasElm) +"  "
	If  !Empty(cWhere)
		cQuery += " WHERE ("+cWhere+") " 
	Endif
	
	If TcSqlExec(cQuery) <> 0  
	   MsgAlert(TcSqlError()) 
	Endif

Return  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBMPgoSATบAutor  ณ Laura Medina         บ Data ณ  03/10/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ  															บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 				                                           	    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/      
Function CTBMPgoSAT(cTabla)
Local aSX5 := {}
Local nI := 0

	DbSelectArea("SX5")
	SX5->(DbSetOrder(1))
	If !dbSeek( Space(Len(SX5->X5_FILIAL)) + cTabla )
	    
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), "00", cTabla, "Catแlogo de m้todos de pago SAT", "Catแlogo de m้todos de pago SAT", "Catแlogo de m้todos de pago SAT" })
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "01", "EF - Efectivo", "EF - Efectivo", "EF - Efectivo"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "02", "CH - Cheque", "CH - Cheque", "CH - Cheque"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "03", "TF - Transferencia", "TF - Transferencia", "TF - Transferencia"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "04", "Tarjetas de cr้dito", "Tarjetas de cr้dito", "Tarjetas de cr้dito"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "05", "Monederos electr๓nicos", "Monederos electr๓nicos", "Monederos electr๓nicos"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "06", "Dinero electr๓nico", "Dinero electr๓nico", "Dinero electr๓nico"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "07", "Tarjetas digitales", "Tarjetas digitales", "Tarjetas digitales"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "08", "Vales de despensa", "Vales de despensa", "Vales de despensa"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "09", "Bienes", "Bienes", "Bienes"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "10", "Servicio", "Servicio", "Servicio"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "11", "Por cuenta de tercero", "Por cuenta de tercero", "Por cuenta de tercero"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "12", "Daci๓n en pago", "Daci๓n en pago", "Daci๓n en pago"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "13", "Pago por subrogaci๓n", "Pago por subrogaci๓n", "Pago por subrogaci๓n"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "14", "Pago por consignaci๓n", "Pago por consignaci๓n", "Pago por consignaci๓n"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "15", "Condonaci๓n", "Condonaci๓n", "Condonaci๓n"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "16", "Cancelaci๓n", "Cancelaci๓n", "Cancelaci๓n"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "17", "CP - Compensaci๓n", "CP - Compensaci๓n", "CP - Compensaci๓n"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "98", "NA", "NA", "NA"})
		aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "99", "Otros", "Otros", "Otros"})			
		
		Begin Transaction
			For nI := 1 To Len(aSX5)
				If !dbSeek(xFilial("SX5")+aSX5[nI][02]+aSX5[nI][03])
					RecLock("SX5",.T.)
					Replace X5_FILIAL		With aSX5[nI][1]
					Replace X5_TABELA		With aSX5[nI][2]
					Replace X5_CHAVE 		With aSX5[nI][3]
					Replace X5_DESCSPA 		With aSX5[nI][4]
					Replace X5_DESCENG 		With aSX5[nI][5]
					Replace X5_DESCRI		With aSX5[nI][6]
					MsUnLock()
				EndIf
			Next
		End Transaction
	Else
		If SX5->(!dbSeek(xFilial("SX5")+cTabla+"01"))
			aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "01", "EF - Efectivo", "EF - Efectivo", "EF - Efectivo"})
			aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "02", "CH - Cheque", "CH - Cheque", "CH - Cheque"})
			aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "03", "TF - Transferencia", "TF - Transferencia", "TF - Transferencia"})
			aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "04", "Tarjetas de cr้dito", "Tarjetas de cr้dito", "Tarjetas de cr้dito"})
			aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "05", "Monederos electr๓nicos", "Monederos electr๓nicos", "Monederos electr๓nicos"})
			aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "06", "Dinero electr๓nico", "Dinero electr๓nico", "Dinero electr๓nico"})
			aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "07", "Tarjetas digitales", "Tarjetas digitales", "Tarjetas digitales"})
			aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "08", "Vales de despensa", "Vales de despensa", "Vales de despensa"})
			aAdd( aSX5, { Space(Len(SX5->X5_FILIAL)), cTabla, "09", "Bienes", "Bienes", "Bienes"})	
			
			For nI := 1 To Len(aSX5)
				If SX5->(dbSeek(xFilial("SX5")+aSX5[nI][02]+ PADR(Substr(aSX5[nI][03],2,1),TAMSX3("X5_CHAVE")[1])))
					RecLock("SX5",.F.)
						SX5->X5_CHAVE := aSX5[nI][3]
					MsUnLock()	
				EndIf 	
			Next
		EndIf
		
	EndIf	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VldCTBNomบAutor  ณRaul Ortiz	       บFecha ณ  22/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica si se va a utilizar contabilidad de nomina        บฑฑ
ฑฑบ          ณ y manda a llamar la funcion                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VldCTBNom(nValNom)
Local lr       := .T.
Local cPerIni  := Alltrim(MV_PAR01) + Alltrim(MV_PAR03)
Local cPerFin  := Alltrim(MV_PAR01) + Alltrim(MV_PAR04)

	If RCH->(FieldPos("RCH_FILIAL")) > 0 
		If nValNom == 2 .and. AllTrim(cPerIni) <> '' .And. AllTrim(cPerFin) <> ''
			ObtNomina(cPerIni, cPerFin)
		EndIf
	EndIf
Return lr

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ getNivel บAutor  ณRaul Ortiz          บFecha ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtiene el codigo y nivel de la cuenta superior            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static Function getNivel(cCtaSup,cContaSup,cNivel)
	
	CT1->(dbselectarea("CT1"))   
	CT1->(DbSetOrder(RETORDEM("CT1","CT1_FILIAL+CT1_CONTA")))
	CT1->(DbGoTop())
	
	If CT1->(Dbseek(xFilial("CT1")+cCtaSup))
		cContaSup := cCtaSup
		cNivel := CT1->CT1_NIVEL
	EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCargaCwd  บAutor  ณ Diego Abel Rivera  บFecha ณ  08/07/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncion para cargar tabla CWD a partir del array aCuentas   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTB                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CargaCwd(aCuentas)
Local nI := 0

	ProcRegua(Len(aCuentas))
	For nI := 1 To Len(aCuentas)
	    IncProc()
		If !CWD->(dbSeek(cFilCWD+aCuentas[nI][02]))  //Se carga informacion 
			RecLock('CWD',.T.)
			CWD->CWD_FILIAL := aCuentas[nI][01]
			CWD->CWD_CODIGO := aCuentas[nI][02]
			CWD->CWD_DESCRI := aCuentas[nI][03]
			CWD->CWD_NIVEL  := aCuentas[nI][04]                                            
			CWD->(MsUnLock())           
		Endif
	Next

Return