#Include "PROTHEUS.CH" 
#Include "GPER1357.CH"
#Include "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออหออออออออออหอออออออหออออออออออออออออออออออออออออออออหอออออออหอออออออออออออปฑฑ
ฑฑบPrograma  บ GPER1357 บ Autor บ Laura Medina                   บ Fecha บ  19/03/2020 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออสออออออออออออออออออออออออออออออออสอออออออสอออออออออออออนฑฑ
ฑฑบDesc.     บArchivo 1357: 1-Informe 1357 y 2-Archivo .txt - Argentina                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       บ SIGAGPE                                                                 บฑฑ
ฑฑฬออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                 ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  บฑฑ
ฑฑฬออออออออออออออออหออออออออออออหออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ  Programador   บ    Data    บ   Issue    บ  Motivo da Alteracao                    บฑฑ
ฑฑฬออออออออออออออออลออออออออออออลออออออออออออลอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                บ            บ            บ                                         บฑฑ
ฑฑศออออออออออออออออสออออออออออออสออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GPER1357()
	
Local oFld		 := Nil
Local aCombo	 := {}

Private cCombo	 := ""
Private oDlg	 := Nil
Private oCombo	 := Nil
Private cProceso := ""
Private cProced  := ""
Private cPeriodo := ""
Private cNroPago := ""
Private cCodMat  := ""
Private cIniCC   := ""
Private cFinCC   := ""
Private cPerFis  := ""
Private cLugar   := ""
Private dFechEmi := ""
Private cRespons := ""
Private nTipoPre := 0
Private cSecuenc := ""
Private cRutaArc := ""
Private cPictVal := "@E 999999999999.99"
Private cPictV17 := "@E 99999999999999.99"
Private cPicSRD  := PesqPict("SRD","RD_VALOR")
Private nArchTXT := 0
Private lGenTXT  := .F.
Private nGenPDF	 := 0
Private aRubros	 := {}
Private cConceRB := GetMv("MV_1357CRB",,"")
Private nValorRB := GetMv("MV_1357VRB",,0)

	aAdd( aCombo, STR0003 ) //"1 - "Formulario 1357"
 	aAdd( aCombo, STR0004 ) //"2 - "Archivo 1357"

	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 0,0 TO 125,450 OF oDlg PIXEL //"F - 1357"

	@ 006,006 TO 045,170 LABEL STR0002 OF oDlg PIXEL //"Indique la opci๓n a generar:"
	@ 020,010 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 100,8 PIXEL OF oFld

	@ 009,180 BUTTON STR0005 SIZE 036,016 PIXEL ACTION (IIf( IIf( Subs(cCombo,1,1) == "1", Form1357(), Arch1357()),oDlg:End(),) ) //"Aceptar"
	@ 029,180 BUTTON STR0006 SIZE 036,016 PIXEL ACTION oDlg:End() //"Salir"

	ACTIVATE MSDIALOG oDlg CENTER

Return

//INICIA FORMULARIO **************************************************************************************************
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณForm1357    บAutor  ณLaura Media       บFecha ณ  19/03/2020  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funci๓n que genera el formulario 1357.                      บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Form1357()
Local cPerg		:= "GPER1357"
Local lRet		:= .T.

Pergunte( cPerg, .F. )

If  !Pergunte(cPerg,.T. )
	Return .F. 
Endif

MakeSqlExpr(cPerg)
cProceso:= MV_PAR01
cProced := MV_PAR02
cPeriodo:= MV_PAR03
cNroPago:= MV_PAR04
cCodMat := MV_PAR05
cIniCC  := MV_PAR06
cFinCC  := MV_PAR07
cPerFis := MV_PAR08
cLugar  := MV_PAR09
dFechEmi:= MV_PAR10
cRespons:= MV_PAR11
	
nGenPDF	:= 0
aRubros := cargaTabla("S044")
If  !Empty(aRubros)
	Processa({ || ProcFyA(1) })
Else
	Aviso(OemToAnsi(STR0007), OemToAnsi(STR0091), {STR0009} ) //"No se encontr๓ informaci๓n en la tabla alfanum้rica S044."
	Return .T. 
Endif

If  nGenPDF >= 1 
	Aviso( OemToAnsi(STR0007), Iif(nGenPDF==1,  OemToAnsi(STR0017), OemToAnsi(STR0110)), {STR0009} ) //"Archivo generado con ้xito!." o "Archivos generados con ้xito!." 
ElseIf nGenPDF == 0
	Aviso(OemToAnsi(STR0007), OemToAnsi(Replace(STR0018,"archivo", "formulario")), {STR0009} ) //"No se encontr๓ informaci๓n para generar el archivo 1357."
Endif


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfPrinReport บAutor  ณAdrian Perez     บFecha   ณ  18/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime Reporte       									   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function fPrinReport(aData, cPerRCH)
Local nX		:= 0
Local cPatchPDF := ""
Local nResImpr 	:= 1  //Resultado de impresi๓n
Private	nH303 	:= nH304:= nH305:= nH306:= nH307:= nH308:= nD309:= nH340:= nH341:= nH342:= nH310:= nH328:= nH311:= nH312:= nD309:= 0       
Private	nH338	:= nH343:= nH344:= nH345:= nH347:= nH346:= nH329:= nH330:= nH331:= nH332:= nH314:= nH315:= nH316:= nH317:= nH318:= 0
Private nD319	:= nD320:= nH348:= nH349:= nH350:= nH348:= nH333:= nH322:= nD323:= nD324:= nH339:= nH351:= nH352:= nH353:= nH355:= 0
Private	nH354	:= nH334:= nH335:= nH336:= nH337:= nH325:= nH326:= nH327:= 0 
Private nD403	:= nD404:= nD405:= nD406:= nD407:= nD408:= nD409:= nD410:= nD411:= nD412:= nD413:= nD414:= nD415:= nD416:= nD417:= 0
Private nD418	:= nD419:= nD420:= nD421:= nD422:= nD423:= nD424:= nD425:= nD426:= nD427:= 0
Private nD503	:= nD509:= nD506:= nD507:= nD515:= nD508:= nD516:= nD504:= nD505:= nD517:= nD518:= nD510:= nD514:= 0
Private nG603	:= nG604:= nG605:= nG606:= nD607:= nG608:= 0

Default aData 	:= {}
Default cPerRCH := ""
			
	For nX=1 to len(aData)
		If  nResImpr == 1
			GenPDFxEm(aData[nX], nX, @cPatchPDF, @nResImpr, cPerRCH)
		Else 
			nGenPDF	:= -1
			Exit
		Endif
	Next			
	If  nResImpr == 2 .And. nGenPDF == 1
		nGenPDF	:= -1
	Endif
								
Return


Static Function GenPDFxEm(aData,nX,cPatchPDF,nResImpr,cPerRCH)
Local oPrinter
Local cFileGen 	:= space(100) 

Default aData 		:= {}
Default nX			:= 0
Default cPatchPDF	:= ""
Default nResImpr 	:= 0
Default cPerRCH		:= ""

cFileGen :=  aData[1,1,4] + aData[1,1,3] + "_" + Substr(cPerRCH,1,4)

	oPrinter:= FWMSPrinter():New(cFileGen,6,.F.,GetClientDir(),Iif(nX == 1, .F., .T.))  //inicializa el objeto
	oPrinter:setDevice( IMP_PDF )   	//selecciona el medio de impresi๓n
	oPrinter:SetMargin(40,10,40,10) 	//margenes del documento
	oPrinter:SetPortrait()           	//orientaci๓n de pแgina modo retrato =  Horizontal

	If  nX == 1		
		nResImpr:= oPrinter:nModalResult 	//obtiene nModalResult=1 confimada --- nModalResult=2 cancelada
		cPatchPDF := oPrinter:CPATHPDF
	Else
		oPrinter:cPathPDF := cPatchPDF
	Endif
	
	If  nResImpr == 1
		fReport(@oPrinter,aData,nX)		
		oPrinter:SetViewPDF(.F.)
		oPrinter:Print()	
		If  File(GetClientDir() + cFileGen +".rel")	
			FERASE(GetClientDir() + cFileGen + ".rel")	
		Endif		
	Endif

FreeObj(oPrinter)
oPrinter := Nil

Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfReport   บAutor  ณAdrian Perez     บFecha     ณ  18/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Estructura del reporte 									   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function fReport(oPrinter,aData,nVez)
	Local aAux		:={}
	Local nR		:=50
	Local nB		:=0	
	Local cStartPath:= GetSrvProfString("Startpath","")
	Local aDatos	:={}
	Local aAuxDat	:={}
	Local nSalto	:=0
	Local lBoxDoble	:=.T.
	Private nAncho	:=13
	Private nRR		:=10
	Private oFontP
	Private oFontT
	Default nVez	:= 0
	Default aData	:= {}
   						 
			oFontT 		:= TFont():New('Arial',,-12,.T.,.T.) //Fuente del Titulo
			oFontP 		:= TFont():New('Arial',,-10,.T.)     //Fuente del Pแrrafo
		
			oPrinter:StartPage() 
			
			//LOGO
			oPrinter:Box( nR-35,10,100, 100)
			oPrinter:SayBitmap((nR-35)+10,15,cStartPath+"lgrl"+FwCodEmp("SM0")+".bmp",80,40)
			//FIN LOGO
			nR+=5
			//"CERTIFICADO DE LIQUIDACIำN DE IMPUESTO A LAS GANANCIAS."
			oPrinter:Say(nR,110,STR0019 , oFontP) 	
			nR+=15
			//"4TA.CATEGORIA. RELACIำN DE DEPENDENCIA."
			oPrinter:Say(nR,110,STR0020 , oFontP)	
			nR+=45
			//"Fecha:"
			oPrinter:Say(nR,10,STR0021 , oFontP)
			oPrinter:Say(nR,110,DTOC(dFechEmi) , oFontP)
			
			nR+=15
			aAux:=aData[1,1]
			
			//"Benefiario:"
			oPrinter:Say(nR,10,STR0022  , oFontP)
			oPrinter:Say(nR,70,aAux[1] , oFontP)
			oPrinter:Say(nR,150,aAux[2] , oFontP)
			oPrinter:Say(nR,400,aAux[3] , oFontP)
			
			nR+=15
			//"Agente de Retenci๓n:"
			oPrinter:Say(nR,10,STR0023 , oFontP)
			oPrinter:Say(nR,120,SM0->M0_CGC , oFontP)
			oPrinter:Say(nR,250,SM0->M0_NOME , oFontP)
			
			nR+=15
			//"Periodo Fiscal:"
			oPrinter:Say(nR,10,STR0024 , oFontP)
			oPrinter:Say(nR,100,cPerFis , oFontP)
			
			nR+=50
			nB:=nR-20
			//Encabezado1: "REMUNERACIONES"
			aadd(aAuxDat,{STR0025})
			
			nSalto:=fReportHead(@nR,@nB,@oPrinter,	aAuxDat,.F.)
			
			//Encabezado2: "Abonadas por el agente de retenci๓n"
			aAuxDat:={}
			nR+=nSalto
			aadd(aAuxDat,{STR0028})
			fReportHead(@nR,@nB,@oPrinter,	aAuxDat,.F.)
			
			aAux:={}
			//REMUNERACIONES
			//1=Empleados, 2=Remuneraciones[1=Valor,2=C๓digo], 3=Deducciones, 4=Deduccion23 y 5=CalcImpto
			aAux:=aData[2]
			aDatos:={}
			If	nVez == 1
				nH303	:= aScan(aAux, {|x| x[2] == "H303"})
				nH304	:= aScan(aAux, {|x| x[2] == "H304"})
				nH305	:= aScan(aAux, {|x| x[2] == "H305"})
				nH306	:= aScan(aAux, {|x| x[2] == "H306"})
				nH307	:= aScan(aAux, {|x| x[2] == "H307"})
				nH308	:= aScan(aAux, {|x| x[2] == "H308"})
				nD309	:= aScan(aAux, {|x| x[2] == "D309"})
				nH340	:= aScan(aAux, {|x| x[2] == "H340"})
				nH341	:= aScan(aAux, {|x| x[2] == "H341"})
				nH342	:= aScan(aAux, {|x| x[2] == "H342"})
				nH310	:= aScan(aAux, {|x| x[2] == "H310"})
				nH328	:= aScan(aAux, {|x| x[2] == "H328"})
				nH311	:= aScan(aAux, {|x| x[2] == "H311"})
				nH312	:= aScan(aAux, {|x| x[2] == "H312"})
				nD309	:= aScan(aAux, {|x| x[2] == "D309"})
				nH338	:= aScan(aAux, {|x| x[2] == "H338"})
				nH343	:= aScan(aAux, {|x| x[2] == "H343"}) 
				nH344	:= aScan(aAux, {|x| x[2] == "H344"})
				nH345	:= aScan(aAux, {|x| x[2] == "H345"})
				nH347	:= aScan(aAux, {|x| x[2] == "H347"})
				nH346	:= aScan(aAux, {|x| x[2] == "H346"})
				nH329	:= aScan(aAux, {|x| x[2] == "H329"})
				nH330	:= aScan(aAux, {|x| x[2] == "H330"})
				nH331	:= aScan(aAux, {|x| x[2] == "H331"})
				nH332	:= aScan(aAux, {|x| x[2] == "H332"})										
				nH314	:= aScan(aAux, {|x| x[2] == "H314"})
				nH315	:= aScan(aAux, {|x| x[2] == "H315"})
				nH316	:= aScan(aAux, {|x| x[2] == "H316"})
				nH317	:= aScan(aAux, {|x| x[2] == "H317"})
				nH318	:= aScan(aAux, {|x| x[2] == "H318"})
				nD319	:= aScan(aAux, {|x| x[2] == "D319"})
				nD320	:= aScan(aAux, {|x| x[2] == "D320"})	
				nH348	:= aScan(aAux, {|x| x[2] == "H348"})
				nH349	:= aScan(aAux, {|x| x[2] == "H349"})
				nH350	:= aScan(aAux, {|x| x[2] == "H350"})
				nH348	:= aScan(aAux, {|x| x[2] == "H348"})
				nH333	:= aScan(aAux, {|x| x[2] == "H333"})
				nH322	:= aScan(aAux, {|x| x[2] == "H322"})		
				nD323	:= aScan(aAux, {|x| x[2] == "D323"})
				nD324	:= aScan(aAux, {|x| x[2] == "D324"})
				nH339	:= aScan(aAux, {|x| x[2] == "H339"})		
				nH351	:= aScan(aAux, {|x| x[2] == "H351"})
				nH352	:= aScan(aAux, {|x| x[2] == "H352"})
				nH353	:= aScan(aAux, {|x| x[2] == "H353"})
				nH355	:= aScan(aAux, {|x| x[2] == "H355"})
				nH354	:= aScan(aAux, {|x| x[2] == "H354"})
				nH334	:= aScan(aAux, {|x| x[2] == "H334"})
				nH335	:= aScan(aAux, {|x| x[2] == "H335"})
				nH336	:= aScan(aAux, {|x| x[2] == "H336"})
				nH337	:= aScan(aAux, {|x| x[2] == "H337"})						
				nH325	:= aScan(aAux, {|x| x[2] == "H325"})
				nH326	:= aScan(aAux, {|x| x[2] == "H326"})
				nH327	:= aScan(aAux, {|x| x[2] == "H327"}) 			
			Endif
			
			aadd(aDatos,{STR0029	,Iif(nH303 > 0,aAux[nH303,1],0)}) //"Remuneraci๓n bruta gravada"	
			aadd(aDatos,{STR0030	,Iif(nH304 > 0,aAux[nH304,1],0)}) //"Retribuciones no habituales gravadas"			
			aadd(aDatos,{STR0031	,Iif(nH305 > 0,aAux[nH305,1],0)}) //"SAC primera cuota gravado"
			aadd(aDatos,{STR0032	,Iif(nH306 > 0,aAux[nH306,1],0)}) //"SAC segunda cuota gravado"			
			aadd(aDatos,{STR0033	,Iif(nH307 > 0,aAux[nH307,1],0)}) //"Horas extras remuneraci๓n gravada"
			aadd(aDatos,{STR0034	,Iif(nH308 > 0,aAux[nH308,1],0)}) //"Movilidad y viแticos remuneraci๓n gravada"
			aadd(aDatos,{STR0035	,Iif(nD309 > 0,aAux[nD309,1],0)}) //"Material didแctico personal docente remuneraci๓n gravada"
			aadd(aDatos,{STR0026	,Iif(nH340 > 0,aAux[nH340,1],0)}) //"Bonos de productividad gravados"
			aadd(aDatos,{STR0027	,Iif(nH341 > 0,aAux[nH341,1],0)}) //"Fallos de caja gravados "
			aadd(aDatos,{STR0092	,Iif(nH342 > 0,aAux[nH342,1],0)}) //"Conceptos de similar naturaleza gravados"
			aadd(aDatos,{STR0036	,Iif(nH310 > 0,aAux[nH310,1],0)}) //"Remuneraci๓n exenta o no alcanzada"
			aadd(aDatos,{STR0094	,Iif(nH328 > 0,aAux[nH328,1],0)}) //"Retribuciones no habituales exentas o no alcanzadas"
			aadd(aDatos,{STR0037	,Iif(nH311 > 0,aAux[nH311,1],0)}) //"Horas extras remuneraci๓n exenta"
			aadd(aDatos,{STR0038	,Iif(nH312 > 0,aAux[nH312,1],0)}) //"Movilidad y viแticos remuneraci๓n exenta o no alcanzada"
			aadd(aDatos,{STR0039	,Iif(nD309 > 0,aAux[nD309,1],0)}) //"Material didแctico personal docente remuneraci๓n exenta o no alcanzada"	
			aadd(aDatos,{STR0095	,Iif(nH338 > 0,aAux[nH338,1],0)}) //"Remuneraci๓n exenta Ley 27549"
			aadd(aDatos,{STR0096	,Iif(nH343 > 0,aAux[nH343,1],0)}) //"Bonos de productividad exentos"
			aadd(aDatos,{STR0097	,Iif(nH344 > 0,aAux[nH344,1],0)}) //"Fallos de caja exentos"
			aadd(aDatos,{STR0098	,Iif(nH345 > 0,aAux[nH345,1],0)}) //"Conceptos de similar naturaleza exentos"
			aadd(aDatos,{STR0099	,Iif(nH347 > 0,aAux[nH347,1],0)}) //"Suplementos particulares artํculo 57 de la Ley 19.101 exentos"
			aadd(aDatos,{STR0100	,Iif(nH346 > 0,aAux[nH346,1],0)}) //"Compensaci๓n gastos teletrabajo exentos"
			aadd(aDatos,{STR0101	,Iif(nH329 > 0,aAux[nH329,1],0)}) //"SAC primera cuota – Exento o No alcanzado"
			aadd(aDatos,{STR0102	,Iif(nH330 > 0,aAux[nH330,1],0)}) //"SAC segunda cuota – Exento o No alcanzado"
			aadd(aDatos,{STR0103	,Iif(nH331 > 0,aAux[nH331,1],0)}) //"Ajustes perํodos anteriores - Remuneraci๓n gravada"
			aadd(aDatos,{STR0104	,Iif(nH332 > 0,aAux[nH332,1],0)}) //"Ajuste perํodos anteriores - Remuneraci๓n exenta / no alcanzada"
						
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
			
			//Encabezado3: "Otros empleos"
			aAuxDat:={}
			aadd(aAuxDat,{STR0040})
			fReportHead(@nR,@nB,@oPrinter,aAuxDat,.F.)
			aAuxDat:={}
			
			aDatos:={}			
			aadd(aDatos,{STR0029	,Iif(nH314 > 0,aAux[nH314,1],0)}) //"Remuneraci๓n bruta gravada"			
			aadd(aDatos,{STR0030	,Iif(nH315 > 0,aAux[nH315,1],0)}) //"Retribuciones no habituales gravadas"
			aadd(aDatos,{STR0031	,Iif(nH316 > 0,aAux[nH316,1],0)}) //"SAC primera cuota gravado"
			aadd(aDatos,{STR0032	,Iif(nH317 > 0,aAux[nH317,1],0)}) //"SAC segunda cuota gravado"
			aadd(aDatos,{STR0033	,Iif(nH318 > 0,aAux[nH318,1],0)}) //"Horas extras remuneraci๓n gravada"
			aadd(aDatos,{STR0034	,Iif(nD319 > 0,aAux[nD319,1],0)}) //"Movilidad y viแticos remuneraci๓n gravada"
			aadd(aDatos,{STR0035	,Iif(nD320 > 0,aAux[nD320,1],0)}) //"Material didแctico personal docente remuneraci๓n gravada"	
			aadd(aDatos,{STR0026	,Iif(nH348 > 0,aAux[nH348,1],0)}) //"Bonos de productividad gravados"
			aadd(aDatos,{STR0027	,Iif(nH349 > 0,aAux[nH349,1],0)}) //"Fallos de caja gravados "
			aadd(aDatos,{STR0092	,Iif(nH350 > 0,aAux[nH350,1],0)}) //"Conceptos de similar naturaleza gravados"
			aadd(aDatos,{STR0036	,Iif(nH348 > 0,aAux[nH348,1],0)}) //"Remuneraci๓n exenta o no alcanzada"
			aadd(aDatos,{STR0094	,Iif(nH333 > 0,aAux[nH333,1],0)}) //"Retribuciones no habituales exentas o no alcanzadas"
			aadd(aDatos,{STR0037	,Iif(nH322 > 0,aAux[nH322,1],0)}) //"Horas extras remuneraci๓n exenta"	
						
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
			
			aDatos:={}	
			aadd(aDatos,{STR0038	,Iif(nD323 > 0,aAux[nD323,1],0)}) //"Movilidad y viแticos remuneraci๓n exenta o no alcanzada"
			aadd(aDatos,{STR0039	,Iif(nD324 > 0,aAux[nD324,1],0)}) //"Material didแctico personal docente remuneraci๓n exenta o no alcanzada"
			aadd(aDatos,{STR0095	,Iif(nH339 > 0,aAux[nH339,1],0)}) //"Remuneraci๓n exenta Ley 27549"		
			aadd(aDatos,{STR0096	,Iif(nH351 > 0,aAux[nH351,1],0)}) //"Bonos de productividad exentos"
			aadd(aDatos,{STR0097	,Iif(nH352 > 0,aAux[nH352,1],0)}) //"Fallos de caja exentos"
			aadd(aDatos,{STR0098	,Iif(nH353 > 0,aAux[nH353,1],0)}) //"Conceptos de similar naturaleza exentos"
			aadd(aDatos,{STR0099	,Iif(nH355 > 0,aAux[nH355,1],0)}) //"Suplementos particulares artํculo 57 de la Ley 19.101 exentos"
			aadd(aDatos,{STR0100	,Iif(nH354 > 0,aAux[nH354,1],0)}) //"Compensaci๓n gastos teletrabajo exentos"
			aadd(aDatos,{STR0101	,Iif(nH334 > 0,aAux[nH334,1],0)}) //"SAC primera cuota – Exento o No alcanzado"
			aadd(aDatos,{STR0102	,Iif(nH335 > 0,aAux[nH335,1],0)}) //"SAC segunda cuota – Exento o No alcanzado"
			aadd(aDatos,{STR0103	,Iif(nH336 > 0,aAux[nH336,1],0)}) //"Ajustes perํodos anteriores - Remuneraci๓n gravada"
			aadd(aDatos,{STR0104	,Iif(nH337 > 0,aAux[nH337,1],0)}) //"Ajuste perํodos anteriores - Remuneraci๓n exenta / no alcanzada"				
		
			nR:=fChangePage(nR,@oPrinter)
			nB:=nR-20
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
			
			aDatos:={}
			//totales			
			aadd(aDatos,{STR0087	,Iif(nH325 > 0,aAux[nH325,1],0)}) //"TOTAL REMUNERACIำN GRAVADA"
			aadd(aDatos,{STR0088	,Iif(nH326 > 0,aAux[nH326,1],0)}) //"TOTAL REMUNERACIำN EXENTA O NO ALCANZADA"
			aadd(aDatos,{STR0089	,Iif(nH327 > 0,aAux[nH327,1],0)}) // "TOTAL REMUNERACIONES"
			
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
			
			//"DEDUCCIONES GENERALES"	
			nR+=5					
			oPrinter:Box(nR,010,nB,579)
			oPrinter:Say(nR-15,012,STR0090 , oFontT)
			
			nR+=nAncho-5
			nB+=nAncho
			
			aDatos:={}
			
			aAux:={}
			aAux:=aData[3]
			
			If	nVez == 1
				nD403	:= aScan(aAux, {|x| x[2] == "D403"})
				nD404	:= aScan(aAux, {|x| x[2] == "D404"})			
				nD405	:= aScan(aAux, {|x| x[2] == "D405"}) 
				nD406	:= aScan(aAux, {|x| x[2] == "D406"})
				nD407	:= aScan(aAux, {|x| x[2] == "D407"})
				nD408	:= aScan(aAux, {|x| x[2] == "D408"}) 
				nD409	:= aScan(aAux, {|x| x[2] == "D409"})
				nD410	:= aScan(aAux, {|x| x[2] == "D410"}) 
				nD411	:= aScan(aAux, {|x| x[2] == "D411"})
				nD412	:= aScan(aAux, {|x| x[2] == "D412"})
				nD413	:= aScan(aAux, {|x| x[2] == "D413"})
				nD414	:= aScan(aAux, {|x| x[2] == "D414"})
				nD415	:= aScan(aAux, {|x| x[2] == "D415"})
				nD416	:= aScan(aAux, {|x| x[2] == "D416"})
				nD417	:= aScan(aAux, {|x| x[2] == "D417"})
				nD418	:= aScan(aAux, {|x| x[2] == "D418"})
				nD419	:= aScan(aAux, {|x| x[2] == "D419"})
				nD420	:= aScan(aAux, {|x| x[2] == "D420"})
				nD421	:= aScan(aAux, {|x| x[2] == "D421"})
				nD422	:= aScan(aAux, {|x| x[2] == "D422"})
				nD423	:= aScan(aAux, {|x| x[2] == "D423"})
				nD424	:= aScan(aAux, {|x| x[2] == "D424"})
				nD425	:= aScan(aAux, {|x| x[2] == "D425"})
				nD426	:= aScan(aAux, {|x| x[2] == "D426"})
				nD427	:= aScan(aAux, {|x| x[2] == "D427"})
			Endif
			
			aadd(aDatos,{STR0041	,Iif(nD403 > 0,aAux[nD403,1],0)}) //"Aportes a fondos de jubilaciones, retiros, pensiones o subsidios que se destinen a cajas nacionales, provinciales o municipales"
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
		
			aDatos:={}
			aadd(aDatos,{STR0041	,0}) //"Aportes a fondos de jubilaciones, retiros, pensiones o subsidios que se destinen a cajas nacionales, provinciales o municipales"
			aadd(aDatos,{STR0042	,Iif(nD404 > 0,aAux[nD404,1],0)}) //"por otros empleos" 			
			filas(@nR,@nB,@oPrinter,aDatos,oFontP,lBoxDoble)
		
			aDatos:={}
			aadd(aDatos,{STR0043	,Iif(nD405 > 0,aAux[nD405,1],0)}) //"Aportes a obras sociales"
			aadd(aDatos,{STR0044	,Iif(nD406 > 0,aAux[nD406,1],0)}) //"Aportes a obras sociales por otros empleos "
			aadd(aDatos,{STR0045	,Iif(nD407 > 0,aAux[nD407,1],0)}) //"Cuota sindical "
			aadd(aDatos,{STR0046	,Iif(nD408 > 0,aAux[nD408,1],0)}) //"Cuota sindical por otros empleos"
			aadd(aDatos,{STR0047	,Iif(nD409 > 0,aAux[nD409,1],0)}) //"Cuotas m้dico asistenciales"
			aadd(aDatos,{STR0048	,Iif(nD410 > 0,aAux[nD410,1],0)}) //"Primas de seguro para el caso de muerte"
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
		
			aDatos:={}
			aadd(aDatos,{STR0049	,0}) //"Primas de seguro por riesgo de muerte y de ahorro de seguros mixtos, excepto para los casos de seguros de retiro privados"
			aadd(aDatos,{STR0093	,Iif(nD411 > 0,aAux[nD411,1],0)}) //"administrados por entidades sujetas al control de la Superintendencia de Seguros de la Naci๓n."
			filas(@nR,@nB,@oPrinter,aDatos,oFontP,lBoxDoble)
		
			aDatos:={}
			aadd(aDatos,{STR0050	,0}) //"Aportes a planes de seguro de retiro privados administrados por entidades sujetas al control de la Superintendencia de Seguros de"
			aadd(aDatos,{STR0105	,Iif(nD412 > 0,aAux[nD412,1],0)}) //"la Naci๓n"
			filas(@nR,@nB,@oPrinter,aDatos,oFontP,lBoxDoble)
		
			aDatos:={}
			aadd(aDatos,{STR0051	,Iif(nD413 > 0,aAux[nD413,1],0)}) //"Cuotapartes de fondos comunes de inversi๓n constituidos con fines de retiro"
			aadd(aDatos,{STR0052	,Iif(nD414 > 0,aAux[nD414,1],0)}) //"Gastos de sepelio"
			aadd(aDatos,{STR0053	,Iif(nD415 > 0,aAux[nD415,1],0)}) //"Gastos de amortizaci๓n e intereses de rodado de corredores y viajantes de comercio"
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
			
			aDatos:={}
			aadd(aDatos,{STR0054	,0}) //"Donaciones a fiscos nacionales, provinciales y municipales y a instituciones comprendidas los incisos e) y f) del artํculo 26 de la"
			aadd(aDatos,{STR0106	,Iif(nD416 > 0,aAux[nD416,1],0)}) //"Ley de Impuesto a las Ganancias"
			filas(@nR,@nB,@oPrinter,aDatos,oFontP,lBoxDoble)
		
			aDatos:={}
			aadd(aDatos,{STR0055	,Iif(nD417 > 0,aAux[nD417,1],0)}) //"Descuentos obligatorios establecidos por ley nacional, provincial o municipal"
			aadd(aDatos,{STR0056	,Iif(nD418 > 0,aAux[nD418,1],0)}) //"Honorarios por servicios de asistencia sanitaria, m้dica y param้dica"
			aadd(aDatos,{STR0057	,Iif(nD419 > 0,aAux[nD419,1],0)}) //"Intereses de cr้ditos hipotecarios"
			aadd(aDatos,{STR0058	,Iif(nD420 > 0,aAux[nD420,1],0)}) //"Aportes al capital social o al fondo de riesgo de socios protectores de sociedades de garantํa recํproca"
			aadd(aDatos,{STR0059	,Iif(nD421 > 0,aAux[nD421,1],0)}) //"Aportes a Cajas Complementarias de Previsi๓n, Fondos Compensadores de Previsi๓n o similares"
			aadd(aDatos,{STR0060	,Iif(nD422 > 0,aAux[nD422,1],0)}) //"Alquiler de inmuebles destinados a casa habitaci๓n"
			aadd(aDatos,{STR0061	,Iif(nD423 > 0,aAux[nD423,1],0)}) //"Remuneraciones y Aportes a Empleados del Servicio Dom้stico"
			aadd(aDatos,{STR0062	,Iif(nD424 > 0,aAux[nD424,1],0)}) //"Gastos de movilidad, viแticos y otras compensaciones anแlogas abonados por el empleador"
			aadd(aDatos,{STR0063	,Iif(nD425 > 0,aAux[nD425,1],0)}) //"Gastos por adquisici๓n de indumentaria y/o equipamiento de trabajo"
			aadd(aDatos,{STR0064	,Iif(nD426 > 0,aAux[nD426,1],0)}) //"Otras deducciones"
			aadd(aDatos,{STR0065	,Iif(nD427 > 0,aAux[nD427,1],0)}) //"TOTAL DEDUCCIONES GENERALES"
			
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
			
			nR+=5
			oPrinter:Box(nR,010,nB,579)
			oPrinter:Say(nR-15,012,STR0066, oFontT) //"DEDUCCIONES PERSONALES"
			
			nR+=nAncho-5
			nB+=nAncho
								
			aDatos:={}
			aAux:={}
			aAux:=aData[4]
			
			If	nVez == 1
				nD503	:= aScan(aAux, {|x| x[2] == "D503"})
				nD509	:= aScan(aAux, {|x| x[2] == "D509"})
				nD506	:= aScan(aAux, {|x| x[2] == "D506"})
				nD507	:= aScan(aAux, {|x| x[2] == "D507"})
				nD515	:= aScan(aAux, {|x| x[2] == "D515"})
				nD508	:= aScan(aAux, {|x| x[2] == "D508"})
				nD516	:= aScan(aAux, {|x| x[2] == "D516"})
				nD504	:= aScan(aAux, {|x| x[2] == "D504"})
				nD505	:= aScan(aAux, {|x| x[2] == "D505"})					
				nD517	:= aScan(aAux, {|x| x[2] == "D517"})
				nD518	:= aScan(aAux, {|x| x[2] == "D518"})			
				nD510	:= aScan(aAux, {|x| x[2] == "D510"})
				nD514	:= aScan(aAux, {|x| x[2] == "D514"})
			Endif
			
			aadd(aDatos,{STR0067	,Iif(nD503 > 0,aAux[nD503,1],0)}) //"Ganancia No Imponible"
			aadd(aDatos,{STR0070	,Iif(nD509 > 0,aAux[nD509,1],0)}) //"Cargas de Familia"
			aadd(aDatos,{STR0071	,Iif(nD506 > 0,aAux[nD506,1],0)}) //"C๓nyuge/ Uni๓n Convivencial"
			aadd(aDatos,{STR0072	,Iif(nD507 > 0,aAux[nD507,1],0)}) //"Cantidad de hijos/as e hijastros/as"
			aadd(aDatos,{STR0107	,Iif(nD515 > 0,aAux[nD515,1],0)}) //"Cantidad de hijos/as e hijastros/as incapacitados para el trabajo"
			
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
						
			nR:=fChangePage(nR,@oPrinter)
			nB:=nR-20
			
			aDatos:={}
			aadd(aDatos,{STR0073	,Iif(nD508 > 0 .And. nD516 > 0, (aAux[nD508,1] + aAux[nD516,1]) , 0)}) //"Deducci๓n total hijos/as e hijastros/as"
			aadd(aDatos,{STR0068	,Iif(nD504 > 0,aAux[nD504,1],0)}) //"Deducci๓n Especial "
			aadd(aDatos,{STR0069	,Iif(nD505 > 0,aAux[nD505,1],0)}) //"Deducci๓n Especํfica"				
			aadd(aDatos,{STR0108	,Iif(nD517 > 0,aAux[nD517,1],0)}) //"Deducci๓n Especial Incrementada Primera parte del pen๚ltimo pแrrafo del inciso c) del artํculo 30 de la ley del gravamen"
			aadd(aDatos,{STR0109	,Iif(nD518 > 0,aAux[nD518,1],0)}) //"Deducci๓n Especial Incrementada Segunda parte del pen๚ltimo pแrrafo del inciso c) del artํculo 30 de la ley del gravamen"		
			aadd(aDatos,{STR0074	,Iif(nD510 > 0,aAux[nD510,1],0)}) //"TOTAL DEDUCCIONES PERSONALES"
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
			
			oPrinter:Box(nR,010,nB,579)
			oPrinter:Say(nR-nRR,012,STR0076, oFontT) //"DETERMINACIำN DEL IMPUESTO"
			
			nR+=nAncho
			nB+=nAncho
			
			aDatos:={}
			aadd(aDatos,{STR0075	,Iif(nD514 > 0,aAux[nD514,1],0)}) //"REMUNERACIำN SUJETA A IMPUESTO"
			
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
			
			aDatos:={}
			aAux:={}
			aAux:=aData[5]
			
			If	nVez == 1
				nG603	:= aScan(aAux, {|x| x[2] == "G603"})
				nG604	:= aScan(aAux, {|x| x[2] == "G604"})
				nG605	:= aScan(aAux, {|x| x[2] == "G605"})
				nG606	:= aScan(aAux, {|x| x[2] == "G606"})
				nD607	:= aScan(aAux, {|x| x[2] == "D607"})
				nG608	:= aScan(aAux, {|x| x[2] == "G608"})
			Endif
			
			aadd(aDatos,{STR0077	,Iif(nG603 > 0,aAux[nG603,1],0)}) //"Alํcuota aplicable artํculo 94 de la ley de impuesto a las ganancias %"
			aadd(aDatos,{STR0078	,Iif(nG604 > 0,aAux[nG604,1],0)}) //"Alํcuota aplicable sin incluir horas extras %"
			aadd(aDatos,{STR0079	,Iif(nG605 > 0,aAux[nG605,1],0)}) //"IMPUESTO DETERMINADO"
			aadd(aDatos,{STR0080	,Iif(nG606 > 0,aAux[nG606,1],0)}) //"Impuesto Retenido"
			aadd(aDatos,{STR0081	,Iif(nD607 > 0,aAux[nD607,1],0)}) //"Pagos a cuenta"
			aadd(aDatos,{STR0082	,Iif(nG608 > 0,aAux[nG608,1],0)}) //"SALDO A PAGAR"
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)			
			
			nR+=nAncho
			nB+=nAncho
			
			oPrinter:Say(nR-nRR,012,STR0083, oFontT) //"Se extiende el presente certificado para constancia del interesado"
			
			nR+=nAncho+20
			nB+=nAncho+20
			
			oPrinter:Say(nR+12,012,STR0084 , oFontT) //"Lugar y Fecha:"
			oPrinter:Say(nR+12,112,DTOC(dFechEmi) , oFontT)
			
			oPrinter:Say(nR+25,012,STR0085 , oFontT) //"Firma del Responsable:"
			
			oPrinter:Say(nR+38,012,STR0086 , oFontT) //"Identificaci๓n del Responsable: "
			oPrinter:Say(nR+38,252,cRespons , oFontT)
			
			oPrinter:EndPage() //fin pag
								
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfilas  บAutor  ณAdrian Perez     บFecha ณ  18/03/2020 	   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Dibuja las filas y celdas asi como la informacion		   บฑฑ
 			  en informe 1357. 											   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/

Static function filas(nR,nB,oPrinter,aDatos,oFont,lBoxDoble)
Local nX		:=1
Local nCentro 	:=0
Local cVlrImp	:= ""

Default nR		:= 0
Default nB  	:= 0
Default aDatos	:= {}
Default lBoxDoble := .F. //Serแn 2 registros en aDatos

 	For nX:= 1 to len(aDatos) 
 		If  lBoxDoble 
 			If  nX == 1
 				nR+=13
 				//nB+=13
 				oPrinter:Box(nR,010,nB,579) 
 			Endif
 			oPrinter:Say(nR-(nRR+13),012,aDatos[nX][1] , oFont)
 		Else
			oPrinter:Box(nR,010,nB,579)
			oPrinter:Say(nR-nRR,012,aDatos[nX][1] , oFont)			
		Endif

		cVlrImp := PADL(Alltrim(Transform(Iif(!Empty(aDatos[nX][2]),aDatos[nX][2],0.00),cPicSRD)),14," ")

		nCentro:=5*(len(cVlrImp))
		
		If  lBoxDoble
			If  nX == 1
				oPrinter:Box(nR,480,nB,579)
			Else
				oPrinter:Say(nR-25,500,cVlrImp, oFont)
				oPrinter:Say(nR-25,483,"$", oFont)
				nR-=13
			Endif
		Else
			oPrinter:Box(nR,480,nB,579)
			oPrinter:Say(nR-nRR,500,cVlrImp, oFont)
			oPrinter:Say(nR-nRR,483,"$", oFont)		
		Endif
				
		nCentro:=0
		nR+=nAncho
		nB+=nAncho
	Next
	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfReportHead   บAutor  ณAdrian Perez     บFecha ณ  18/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Insertar un encabezado de 3 celdas en Informe Archivo 1357. บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static function fReportHead(nR,nB,oPrinter,aDatos,lSalto)
Local nSalto:=0

Default nR	:= 0
Default nB  := 0
Default aDatos	:= {}
Default lSalto	:= .T.

	if lSalto
		nSalto:=50
	EndIf
	oPrinter:Box(nR+nSalto,010,nB,579)
	oPrinter:Say((nR-nRR),012,aDatos[1][1] , oFontT)
	
	nR+=nAncho
	nB+=nAncho+nSalto
	
return nSalto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfChangePage   บAutor  ณAdrian Perez     บFecha ณ  18/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funci๓n que cambia de pagina para Informe Archivo 1357.     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/

Static Function fChangePage(nRow,oPrinter)

Default nRow := 0

	If (nRow) >= 740
		nRow := 80
		oPrinter:EndPage()
		oPrinter:StartPage()
	EndIf
		
Return nRow
//TERMINA FORMULARIO **************************************************************************************************

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณArch1357   บAutor  ณLaura Medina        บFecha ณ  19/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funci๓n que genera el Archivo 1357.                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Arch1357()
Local cPerg		:= "GPER1357A"
Local lRet		:= .T.

Pergunte( cPerg, .F. )

If  !Pergunte(cPerg,.T. )
	Return .F. 
Endif 

MakeSqlExpr(cPerg) 
cProceso:= MV_PAR01
cProced := MV_PAR02
cPeriodo:= MV_PAR03
cNroPago:= MV_PAR04
cCodMat := MV_PAR05
cIniCC  := MV_PAR06
cFinCC  := MV_PAR07
nTipoPre:= MV_PAR08
cSecuenc:= MV_PAR09
cRutaArc:= Alltrim(MV_PAR10)

lGenTXT  := .F.

If  Vl1537(cPeriodo,nTipoPre)
	aRubros := cargaTabla("S044")
	If  !Empty(aRubros)
		Processa({ || ProcFyA(2) })
	Else
		Aviso(OemToAnsi(STR0007), OemToAnsi(STR0091), {STR0009} ) //"No se encontr๓ informaci๓n en la tabla alfanum้rica S044."
		Return .T. 
	Endif
	
	If  lGenTXT
		Aviso( OemToAnsi(STR0007), OemToAnsi(STR0017), {STR0009} ) //"Archivo generado con ้xito!."
	Else
		Aviso(OemToAnsi(STR0007), OemToAnsi(STR0018), {STR0009} ) //"No se encontr๓ informaci๓n para generar el archivo 1357."
	Endif
	FCLOSE(nArchTXT)
Else
	lRet := .F.	
Endif
	
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณObtDatos   บAutor  ณLaura Medina        บFecha ณ  23/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funci๓n para obtener los datos de la SRC o SRD.             บฑฑ
ฑฑบ          ณ 1. Formulario 1357 y  2.Archivo  1357                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcFyA(nOpc)
Local nPos  	:= 0 
Local cAliasAux := ""
Local cPrefixo  := ""
Local cQuery	:= ""
Local cTmp		:= GetNextAlias()
Local lProcesa  := .T.
Local aRemunera := Array(27)
Local aDeduccio := Array(27)
Local aDeducc23 := Array(11)
Local aCalcImpt := Array(8)
Local nLoop     := 0
Local nRegs     := 0
Local nPos2		:= 0
Local nCounReg1 := 0
Local lVerifRB  := !Empty(cConceRB) .And. nValorRB>0 

Local aEmpleados:={}
Local aData:={}
Local cPerRCH	 := ""

Private aPerAbe	:= {} //Periodo Abierto
Private aPerFec	:= {} //Periodo Cerrado

Default nOpc	:= 1

RetPerAbertFech(cProceso,; // Processo selecionado na Pergunte.
				cProced,; // Roteiro selecionado na Pergunte.
				cPeriodo,; // Periodo selecionado na Pergunte.
				cNroPago,; // Numero de Pagamento selecionado na Pergunte.
				NIL		,; // Periodo Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um periodo.
				NIL		,; // Numero de Pagamento Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um numero de pagamento.
				@aPerAbe,; // Retorna array com os Periodos e NrPagtos Abertos
				@aPerFec ) // Retorna array com os Periodos e NrPagtos Fechados

If  Empty(aPerAbe) .And. Empty(aPerFec)
	Aviso( OemToAnsi(STR0007), OemToAnsi(STR0012), {STR0009} ) //"No fue encontrado ningun periodo. Verifique los parแmetros!"
	Return 
Endif

If (nPos:=aScan(aPerAbe, {|x| x[1] == cPeriodo .And. x[2] == cNroPago})) > 0 
	cAliasAux   := "SRC"
	cPrefixo    := "RC_"	
	cPerRCH		:= Alltrim(Str(Year(aPerAbe[1,5]))) + cNroPago
Elseif (nPos:=aScan(aPerFec, {|x| x[1] == cPeriodo .And. x[2] == cNroPago})) > 0 
	cAliasAux   := "SRD"
	cPrefixo    := "RD_"	
	cPerRCH		:= Alltrim(Str(Year(aPerFec[1,5]))) + cNroPago
Endif 

cQuery 	:= 	"SELECT RA_FILIAL, RA_MAT, RA_CIC, RA_ACTTRAN, RA_ADMISSA, RA_PRINOME, RA_PRISOBR, RA_SECSOBR, RA_ZONDES, SUM("+cPrefixo+"VALOR) RC_VALOR "
cQuery	+=	"FROM "
cQuery	+=	RetSqlName("SRA") + " SRA,  "	
cQuery  +=	RetSqlName(cAliasAux) +" "+ cAliasAux + " " 
cQuery  += 	"WHERE SRA.D_E_L_E_T_= ' ' AND "
cQuery +=		cAliasAux+".D_E_L_E_T_= ' ' AND "
cQuery  += 		"SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND "
cQuery  += 		cAliasAux+"."+cPrefixo+"FILIAL	= '" +   xFilial("SRA") + "'  AND "
cQuery  +=		"SRA.RA_CC BETWEEN '"+ cIniCC +"' AND '"+ cFinCC +"' AND " 
If  !Empty(cCodMat)
	cQuery  +=	cCodMat +" AND "
Endif
cQuery += 		cAliasAux+"."+cPrefixo+"MAT    = RA_MAT  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"FILIAL = RA_FILIAL  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"PROCES	= '" +  cProceso+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"ROTEIR	= '" +  cProced+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"PERIODO	= '" +  cPeriodo+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"SEMANA	= '" +  cNroPago+ "'  AND "
//PDF4: Solo activos ?
cQuery +=		"RA_SITFOLH <> 'D' " 
cQuery +=	"GROUP BY RA_FILIAL, RA_MAT, RA_CIC, RA_ACTTRAN, RA_ADMISSA, RA_PRINOME, RA_PRISOBR, RA_SECSOBR, RA_ZONDES "
cQuery +=	"ORDER BY RA_FILIAL, RA_MAT"


cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
TcSetField(cTmp, "RA_ADMISSA", "D", 08, 0)

Count to nRegs

ProcRegua(nRegs)
(cTmp)->(dbGoTop())

If  nOpc == 2 .And. nRegs > 0 //Archivo 1357
	If  !GenArch(cPerRCH)  //Crea el archivo.
		lProcesa := .F. 
	Endif
Endif

While (cTmp)-> (!Eof()) .And. lProcesa
	IncProc(STR0013 + Iif(nOpc==1,STR0014,STR0015)) //IncProc(STR0013 + STR0015) // "Generando " 1 "formulario 1357... " o 2 "archivo 1357... " 
	
	If  Iif(lVerifRB, ObtMov("", cAliasAux, cPrefixo,(cTmp)->RA_FILIAL,(cTmp)->RA_MAT,2,cConceRB) >= nValorRB, .T.)

		aRemunera := Array(55)
		aDeduccio := Array(31)
		aDeducc23 := Array(18)	
		aCalcImpt := Array(19)
		nCounReg1 ++
		
		//REMUNERACIONES
		aRemunera[1]:= {"03",""}
		aRemunera[2]:= {PADL((cTmp)->RA_CIC, 11, " "),""}
		For nloop := 3 to 55
			If (nPos2:= aScan(aRubros, {|x| x[2] == 3 .And. x[3] == nloop}) )> 0
				aRemunera[nloop]:= {ObtMov(aRubros[nPos2,1], cAliasAux, cPrefixo,(cTmp)->RA_FILIAL,(cTmp)->RA_MAT,1),aRubros[nPos2,1]}
			Else
				aRemunera[nloop]:= {0,""}
			Endif
		Next
		
		//DEDUCCIONES
		aDeduccio[1]:= {"04",""}
		aDeduccio[2]:= {PADL((cTmp)->RA_CIC, 11, " "),""}
		For nloop := 3 to 31
			If (nPos2:= aScan(aRubros, {|x| x[2] == 4 .And. x[3] == nloop}) )> 0
				aDeduccio[nloop]:= {ObtMov(aRubros[nPos2,1], cAliasAux, cPrefixo,(cTmp)->RA_FILIAL,(cTmp)->RA_MAT,1),aRubros[nPos2,1]}
			Else
				aDeduccio[nloop]:= {0,""}
			Endif
		Next
		
		//DEDUCCIONES ART. 23
		aDeducc23[1]:= {"05",""}
		aDeducc23[2]:= {PADL((cTmp)->RA_CIC, 11, " "),""}
		For nloop := 3 to 18
			If (nPos2:= aScan(aRubros, {|x| x[2] == 5 .And. x[3] == nloop}) )> 0
				aDeducc23[nloop]:= {ObtMov(aRubros[nPos2,1], cAliasAux, cPrefixo,(cTmp)->RA_FILIAL,(cTmp)->RA_MAT,1),aRubros[nPos2,1]}
			Else
				aDeducc23[nloop]:= {0,""}
			Endif
		Next
		
		//CALCULO DE IMPUESTO
		aCalcImpt[1]:= {"06",""}
		aCalcImpt[2]:= {PADL((cTmp)->RA_CIC, 11, " "),""}
		For nloop := 3 to 19
			If (nPos2:= aScan(aRubros, {|x| x[2] == 6 .And. x[3] == nloop}) )> 0
				aCalcImpt[nloop]:= {ObtMov(aRubros[nPos2,1], cAliasAux, cPrefixo,(cTmp)->RA_FILIAL,(cTmp)->RA_MAT,1),aRubros[nPos2,1]}
			Else
				aCalcImpt[nloop]:= {0,""}
			Endif
		Next
		
		//Archivo 1357 
		If  nOpc==2 
			If  nCounReg1 == 1 //Solo se imprime una vez el registro 01
				GrabaReg01(cPerRCH) //Longitud de 38
			Endif
			//Solo en caso de tener registros positivo se va a grabar el registro02...06
			GrabaReg02((cTmp)->RA_ADMISSA,(cTmp)->RA_ACTTRAN,(cTmp)->RA_CIC,(cTmp)->RA_ZONDES,cPerRCH) //Longitud de 37
			GrabaRegXX(aRemunera,3) //Longitud de 570 -> 810
			GrabaRegXX(aDeduccio,4) //Longitud de 450
			GrabaRegXX(aDeducc23,5) //Longitud de 180 -> 227
			GrabaRegXX(aCalcImpt,6) //Longitud de 240
			lGenTXT := .T. 			
		ElseIf  nOpc==1 //PDF 1357
				//aadd(aEmpleados,{"8888999","empleado"+str(nX),"Mat"+str(nX),"CUIT EM"+str(nX),"RAZON ESP"+str(nX),"Periodo202"+str(nX)})
				aadd(aEmpleados,{(cTmp)->RA_CIC,ALLTRIM((cTmp)->RA_PRISOBR)+" "+ALLTRIM((cTmp)->RA_SECSOBR)+" "+(cTmp)->RA_PRINOME,(cTmp)->RA_MAT,(cTmp)->RA_FILIAL})
				aadd(aData,{aEmpleados,aRemunera,aDeduccio,aDeducc23,aCalcImpt})
				aEmpleados:={}
				nGenPDF ++
		Endif
	Endif	
	(cTmp)->(DbSkip())	
EndDo
(cTmp)->(dbCloseArea())	
If  nOpc==1 .And. nGenPDF >= 1
	fPrinReport(aData, cPerRCH)
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGenArch   บAutor  ณLaura Medina         บFecha ณ  19/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Generar archivo y registro 01                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GenArch(cPerRCH)
Local lRet   	:= .T.
Local cNomArch	:= "F1357."+Alltrim(STRTRAN(SM0->M0_CGC,"-",""))+"."+substr(cPerRCH,1,4)+"0000."+StrZero(Val(cSecuenc),4)+".txt"  //PDF1
Local cDrive	:= ""
Local cDir      := ""
Local cExt      := ""
Local cNewFile	:= ""

Default cPerRCH := ""

IIf (!(Substr(cNomArch,Len(cNomArch) - 2, 3) $ "txt|TXT"), cNomArch += ".TXT", "")

cNewFile := cRutaArc + cNomArch

SplitPath(cNewFile,@cDrive,@cDir,@cNomArch,@cExt)
cDir 	 := cDrive + cDir

Makedir(cDir,,.F.) //Crea el directorio en caso de no existir

cNewFile := cDir + cNomArch + cExt   
nArchTXT := FCreate (cNewFile,0)

If nArchTXT == -1
	Aviso( OemToAnsi(STR0007), OemToAnsi(STR0008 + cNomArch), {STR0009} ) //"Atencion" - "No se pudo crear el archivo " - "OK"
	lRet   := .F.
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrabaReg01 บAutor  ณLaura Medina        บFecha ณ  19/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณArchivo 1357 | Registro 01 |                                 บฑฑ
ฑฑบ          ณEl registro cabecera debe ser el primer registro del archivo,บฑฑ
ฑฑบ          ณcon una longitud de 38 (treinta y ocho) caracteres.          บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrabaReg01(cPerRCH) 
//Longitud de 38 caracteres
Local cLinea	:= ""
Local aFilAtu	:= FWArrFilAtu()
Default cPerRCH := ""

cLinea := "01"
cLinea += PADR(STRTRAN(aFilAtu[18],"-",""), 11, " ")
cLinea += IIf(nTipoPre==1 .Or. nTipoPre==4, Substr(cPerRCH,1,4)+"00", cPeriodo) 
cLinea += StrZero(Val(cSecuenc),2)
cLinea += PADR(GetMv("MV_1357IMP",,""),4)
cLinea += PADR(GetMv("MV_1357CON",,""),3)
cLinea += PADR(GetMv("MV_1357FOR",,""),4)
cLinea += Alltrim(Str(nTipoPre))
cLinea += PADR(GetMv("MV_1357SIS",,""),5)
FWrite(nArchTXT, cLinea)
cLinea := ""

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrabaReg02 บAutor  ณLaura Medina        บFecha ณ  19/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Archivo 1357 | Registro 02 |                                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrabaReg02(dAdmissa,nActTran,cCIC,cZonDes,cPerRCH)
//Longitud de 37 caracteres
Local cLinea	:= ""
Local cAnoIng   := ALLTRIM(STR(YEAR(dAdmissa)))  //A๑o de la fecha de Admisi๓n 
Local cPerIni   := ""
Default dAdmissa:= CTOD("//")
Default nActTran:= "0"
Default cCIC	:= ""
Default cZonDes := ""
Default cPerRCH := ""

cPerIni := Iif(cAnoIng < Substr(cPerRCH,1,4),Substr(cPerRCH,1,4)+"0101",Substr(cPerRCH,1,4)+STRZERO(MONTH(dAdmissa),2)+"01")

cZonDes := Alltrim(cZonDes)

cLinea := CRLF 
cLinea += "02"
cLinea += PADR(cCIC, 11, " ")
cLinea += cPerIni   //Periodo - DESDE
cLinea += Substr(cPerRCH,1,4)+"1231" //Periodo - HASTA *PDF5 
cLinea += "12"  //Meses *PDF7
cLinea += Iif(Empty(cZonDes),"1",Iif(len(cZonDes)==1,cZonDes,substr(cZonDes,2,1)))  //Beneficio (RA_ZONDES) *PDF6	
cLinea += Iif(nActTran!= "1", "0", nActTran) //PDF9
cLinea += "0"
cLinea += "0"
cLinea += "0"
cLinea += "0"
FWrite(nArchTXT, cLinea)
cLinea := ""

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrabaRegXX บAutor  ณLaura Medina        บFecha ณ  19/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Archivo 1357 | Registro 03, 04 Y 05 |                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑบParametrosณ aRegistroX:= Arreglo con los movimientos (RC/RD_VALOR).     บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrabaRegXX(aRegistroX,nReg)
Local nLoop	  := 0 
Local nInicio := 3
Local cLinea  := ""

cLinea := CRLF 
cLinea += aRegistroX[1,1]
cLinea += aRegistroX[2,1]
If  nReg == 6
	nInicio := 5
	cLinea += Tabla_Aliq(aRegistroX[3,1])
	cLinea += Tabla_Aliq(aRegistroX[4,1])
Endif

For nLoop := nInicio To Len(aRegistroX)
	If  nReg == 5 .And. (nLoop == 7 .Or. nLoop == 15) 
		cLinea +=  StrZero(aRegistroX[nLoop,1],2)
	Else
		If  nLoop <> 27
			cLinea += PADL(STRTRAN(AllTrim(STRTRAN(Transform(aRegistroX[nLoop,1], cPictVal),",","")),".",""), 15, "0")
		Else
			cLinea += PADL(STRTRAN(AllTrim(STRTRAN(Transform(aRegistroX[nLoop,1], cPictV17),",","")),".",""), 17, "0")
		Endif
	Endif
Next
FWrite(nArchTXT, cLinea)
cLinea := ""
		
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVl1537     บAutor  ณLaura Medina        บFecha ณ  19/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validaci๓n del periodo, debe ser mayor o igual a 2018       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Vl1537(cPerVld, nTipPr)
Local lRet := .T. 
Default nTipPr := 0

If  (nTipPr == 1 .Or. nTipPr == 4) .And. Substr(cPerVld,1,4)< "2020" 
	lRet := .F.
	Aviso( OemToAnsi(STR0007), OemToAnsi(STR0010), {STR0009} ) //"Atencion" - "Informe un periodo valido (a partir del 2020)."  
Elseif (nTipPr == 2 .OR. nTipPr == 3) .And. cPerVld < "202101" 
	lRet := .F. //PDF1,2,3
	Aviso( OemToAnsi(STR0007), OemToAnsi(STR0016), {STR0009} ) //"Informe un periodo valido (a partir del 202101)." 
Endif

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณObtMov     บAutor  ณLaura Medina        บFecha ณ  24/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtener movimientos para el concepto.                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtMov(cCod1357, cAliasAux, cPrefixo, cFilMov, cMatMov, nOpc, cConcep)
Local cQuery	:= ""
Local cTmp		:= GetNextAlias()
Local nRenumera := 0
Default nOpc	:= 1
Default cConcep := ""


cQuery := 	"SELECT SUM("+cPrefixo+"VALOR) "+cPrefixo+"VALOR "
cQuery +=	"FROM "
cQuery +=	RetSqlName(cAliasAux) +" "+ cAliasAux + ", "  +RetSqlName("SRV")+ " SRV " 
cQuery += 	"WHERE "+ cAliasAux+"."+cPrefixo+"MAT = '" +cMatMov + "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"FILIAL	= '" +  cFilMov+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"PROCES	= '" +  cProceso+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"ROTEIR	= '" +  cProced+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"PERIODO	= '" +  cPeriodo+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"SEMANA	= '" +  cNroPago+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"PD = SRV.RV_COD AND "
//RV_COD1357 G603, G604,...D619
If  nOpc ==1
	cQuery += 		"SRV.RV_COD1357 = '" + cCod1357 + "'  AND "
Elseif nOpc == 2
	cQuery += 		"SRV.RV_COD = '" + cConcep + "'  AND "
Endif
cQuery +=		cAliasAux+".D_E_L_E_T_= ' ' AND "
cQuery +=		"SRV.D_E_L_E_T_= ' ' AND "
cQuery +=		"SRV.RV_FILIAL = '" + xFilial("SRV")+ "' ""
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)

If (cTmp)-> (!Eof())
	nRenumera := abs((cTmp)->&((cPrefixo)+"VALOR"))
Endif
(cTmp)->(dbCloseArea())	

Return nRenumera


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Tabla_Aliq บAutor  ณLaura Medina       บFecha ณ  15/04/2021 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtener el valor que corresponde.                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tabla_Aliq(cAliq)
Local cValor  := ""
Default cAliq := "0"

cAliq := Alltrim(str(cAliq))

Do Case
	Case cAliq == "0"
		 cValor := "0"
	Case cAliq == "5"
		 cValor := "1"
	Case cAliq == "9"
		 cValor := "2"
	Case cAliq == "12"
		 cValor := "3"
	Case cAliq == "15"
		 cValor := "4"
	Case cAliq == "19"
		 cValor := "5"
	Case cAliq == "23"
		 cValor := "6"
	Case cAliq == "27"
		 cValor := "7"	
	Case cAliq == "31"
		 cValor := "8"
	Case cAliq == "35"
		 cValor := "9"		 
	OtherWise
		 cValor := "0"
	EndCase

Return cValor


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcargaTabla บAutor  ณLaura Medina        บFecha ณ  17/04/2021 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtener los rubros de la tabla alfanum้rica S044.           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function cargaTabla(cTabla)
Local aTablaS044 := {}
Default cTabla 	 := ""


DbSelectArea("RCC")    
RCC->(dbSetOrder(1)) //"RCC_FILIAL+RCC_CODIGO+RCC_FIL+RCC_CHAVE+RCC_SEQUEN"

If  RCC->(MsSeek(xFilial("RCC") + cTabla ))
	While !Eof() .And. RCC->RCC_FILIAL + RCC->RCC_CODIGO == xFilial("RCC") + cTabla
			aAdd(aTablaS044, {Substr(RCC->RCC_CONTEU,1,4),Val(Substr(RCC->RCC_CONTEU,2,1)),Val(Substr(RCC->RCC_CONTEU,3,2)) } )
	RCC->(dbSkip())	
	EndDo
Endif

Return aTablaS044