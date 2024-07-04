#include "Protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "CTBA602.ch"

#DEFINE TAM_VALOR	20

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออหออออออออออหอออออออหออออออออออออออออออออออหออออออหอออออออออออออปฑฑ
ฑฑบPrograma  บCTBA602   บAutor  บLuis Samaniego        บFecha บ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออสออออออออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDesc.     บCatalogo de Cuentas SAT                                       บฑฑ
ฑฑบ          บ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       บ SIGACTB                                                      บฑฑ
ฑฑฬออออออออออสออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ           ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             บฑฑ
ฑฑฬออออออออออออหออออออออหอออออออออออออหอออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบProgramador บ Data   บLlamado      บ  Motivo da Alteracao                บฑฑ
ฑฑฬออออออออออออลออออออออลอออออออออออออลอออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ  Marco A.  บ01/12/16บSERINN001-109บ Se integra CTREE para quitar la     บฑฑ
ฑฑบ            บ        บ             บ generacion de tablas temporales en  บฑฑ
ฑฑบ            บ        บ             บ system.                             บฑฑ
ฑฑบL.Samaniego บ20/06/17บMMI-5976     บContabilidad Electronica versi๓n 1.3 บฑฑ
ฑฑบL.Samaniego บ12/07/17บMMI-6295     บUso de secuencias de escape en RFC   บฑฑ
ฑฑบG. Santacruzบ13/02/18บdmina-1937   บse limita la funcion CTBA602CT1 para บฑฑ
ฑฑบ            บ        บR้plica      บque solo imprima ls registros de la  บฑฑ
ฑฑบ            บ        บdmina-1623   บfilial  actual.                      บฑฑ
ฑฑบ  Marco A.  บ29/04/21บDMINA-11775  บSe elimina AllTrim() en la obtencion บฑฑ
ฑฑบ            บ        บ             บdel Calendario en la Preg. 02 (MEX)  บฑฑ
ฑฑศออออออออออออสออออออออสอออออออออออออสอออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBA602()
Local aArea			:= GetArea()
Local aSays			:={} 
Local aButtons	   	:={}
Local aTitLog     	:={} 
Local lFin		   		:= .F.
Local cCadastro		:= STR0001 
Local cPerg			:= "CTBA602"
Local nOpca			:= 0

Private aErrores    	:= {}
Private aTmpArea    	:= {}  
Private aErrPlz     	:= {}
Private lAtribOpc	  	:= SuperGetMV("MV_CTBAOPC",.T.,.F.) // .T. == Muestra atributos opciones vacios 
Private lNodoOpc	  	:= SuperGetMV("MV_NODOOPC",.T.,.F.) // .T. == Muestra Nodos opciones vacios 
Private nNivelCta   	:= SuperGetMV("MV_NIVELCT",.T.,2) //Nivel de las cuentas que formaran la Balanza
Private lSldCero   	:= SuperGetMV("MV_SLDCERO",.T.,.F.) //Incluye saldos en cero en balanza de comprobacion.
Private cRFCE		  	:= AllTrim(UPPER(SM0->M0_CGC))
Private cRFC		  	:= ""
Private cCRLF		  	:= ( chr(13)+chr(10) )
Private cXML		  	:= '<?xml version="1.0" encoding="UTF-8"?>' + cCRLF //Chr(239) + Chr(187) + Chr(191) + 
Private cNodo		  	:= '<#NomNodo# #cValAtrib#>' + cCRLF // Nodo Principal
Private cSNodo  	  	:= '<#NomNodo# #cValAtrib#/>' + cCRLF // Sub Nodo
Private cFinNodo	 	:= '</#cFinNodo#>' + cCRLF // Fin de Nodo Principal
Private cMes		 	:= ""
Private cAno		 	:= ""
Private cDir		  	:= ""
Private cNodoSup   	 := "" //Nodo
Private cSubNodo    	:= "" //SubNodo
Private nTipo		  	:= 0
Private cTipoEnvio   := ""
Private cFechaModBal := ""
Private cTipoSolicitud  := ""
Private cNumOrden  	:= ""
Private cNumTramite	:= ""
Private cPict1		:=	"@E 99999999999999.99"
Private cCadenaOr		:= ""
Private cPipe			:= "|"
Private cCertif 		:= LeeCert()
Private cNoCert 		:= SuperGetMv("MV_CFDI_CS",,"")
Private cExtXML      := ".xml"
Private cExtTMP      := ".tmp"
Private cCFDiPri 		:= SuperGetmv( "MV_CFDI_PX" , .F. , "" )						// Archivo de llave privada (.pfx)
Private cCFDiCve 		:= SuperGetmv( "MV_CFDI_CL" , .F. , "" )						// Clave de llave privada
Private cRutaSmr 		:= &(SuperGetmv( "MV_CFDSMAR" , .F. , "GetClientDir()" ))	// Ruta local en donde se procesarแn los archivos
Private nOpc     		:= 0
Private cParam		:= ""
Private cRutinaVB		:= "SelladoXml.exe "
Private aBrowse		:= {}
Private aCampos		:= {}
Private aPlzNom      := {}
Private nFila			:= 1
Private dIni         := CTOD("")
Private dFim         := CTOD("")
Private aVersion 		:= {{"1.3","1.3","1.3","1.3","1.3"}} //Versiones de Archivos {Catalogos de cuentas, balanza de comprobaci๓n, P๓lizas, Auxiliar de folios Fiscales, Auxiliar de Ctas y Subctas}
Private lCompNac     := .F.
Private nValBrut     := 0
Private cAtrbCmp     := "" //Atributos Nodo <Comprobante>
Private lSeOpc       := SuperGetmv( "MV_CTBSEOP" , .F. , .F. )
Private aSelFil      := {}
Private cTipSaldo    := SuperGetmv( "MV_CTBTSAL" , .F. , "1" )
Private cTempCT2     := GetNextAlias()
Private nMonto       := 0
Private cBcoPago    := ""
Private cCtaPago    := ""
Private lNodoTrns   := SuperGetMV("MV_CTBTRNS",.T.,.F.)
Private cCalend     := ""
Private cPerIni     := ""
Private cPerFin     := ""
Private oTmpTable   := Nil
Private cRfcHtml    :=  CodHTML(UPPER(SM0->M0_CGC), .T.)
                
	Pergunte( cPerg, .F. )
	aAdd(aSays,OemToAnsi( STR0002) ) 
	aAdd(aButtons, { 5,.T.,{ || Pergunte(cPerg,.T. ) } } )
	aAdd(aButtons, { 1,.T.,{ |o| Iif(VldTipEnv() .and. vldLn(Len(aBrowse)),(nOpca := 1, o:oWnd:End()),)}} )
	aAdd(aButtons, { 2,.T.,{ |o| nOpca := 2,o:oWnd:End() }} )             
	FormBatch( oemtoansi(cCadastro), aSays , aButtons )
	 
	If nOpca == 1
		cAno := AllTrim(MV_PAR01)
		cCalend := MV_PAR02
		cPerIni := Alltrim(MV_PAR03)
		cPerFin := Alltrim(MV_PAR04)
		cDir := If(Substr(AllTrim(MV_PAR05), Len(AllTrim(MV_PAR05)) - 1 , 1) != "\", AllTrim(MV_PAR05) + "\",  AllTrim(MV_PAR05))
		nTipo := MV_PAR06
		IIf(MV_PAR07 == 1, cTipoEnvio := "N", cTipoEnvio := "C") 
		cFechaModBal  := DTOC(MV_PAR08)
		IIf(MV_PAR09 == 1, cTipoSolicitud := "AF", "")
		IIf(MV_PAR09 == 2, cTipoSolicitud := "FC", "")
		IIf(MV_PAR09 == 3, cTipoSolicitud := "DE", "")
		IIf(MV_PAR09 == 4, cTipoSolicitud := "CO", "")
		cNumOrden := MV_PAR10
		cNumTramite := MV_PAR11
		
		If nTipo == 2 .Or. nTipo == 5
			If MV_PAR13 == 2 .And. Len( aSelFil ) <= 0  .And. !IsBlind()
				aSelFil := AdmGetFil()
				If Len( aSelFil ) <= 0
					Return
				EndIf 
			EndIf
		EndIf
		
		DbSelectArea("SF1")
		DbSelectArea("SF2")
		dbSelectArea("SA2")
		
		DBSelectArea("CT1")
		CT1->(DBSetOrder(RETORDEM("CT1","CT1_FILIAL+CT1_CONTA")))
		DbSelectArea("CWD")
		CWD->(dbSetOrder(RETORDEM("CWD","CWD_FILIAL+CWD_CODIGO")))
		dbSelectArea("CTL")
		CTL->(DBSetOrder(RETORDEM("CTL","CTL_FILIAL+CTL_LP")))
		dbSelectArea("CTO")
		CTO->(dbSetOrder(RETORDEM("CTO", "CTO_FILIAL+CTO_MOEDA")))
		dbSelectArea("CTP")
		CTP->(DBSetOrder(RETORDEM("CTP","DTOS(CTP_DATA)+CTP_MOEDA")))
		dbSelectArea("SA6")
		SA6->(DBSetOrder(RETORDEM("SA6","A6_FILIAL+A6_COD")))
		dbSelectArea("SA1")
		SA1->(DBSetOrder(RETORDEM("SA1","A1_FILIAL+A1_COD+A1_LOJA")))
		dbSelectArea("SX5")
		SX5->(DBSetOrder(RETORDEM("SX5", "X5_FILIAL+X5_TABELA")))
		dbSelectArea("CTG")
		CTG->(DBSetOrder(RETORDEM("CTG", "CTG_FILIAL+CTG_CALEND+CTG_EXERC+CTG_PERIOD")))
		dbSelectArea("AI0")
		AI0->(DBSetOrder(RETORDEM("AI0", "AI0_FILIAL+AI0_CODCLI+AI0_LOJA")))
		
		dIni := ObtFchPer(cPerIni, .T.)
		dFim := ObtFchPer(cPerFin, .F.)
		cMes := Strzero(Month(dIni),2)
		
		If nTipo == 3 .Or. nTipo == 4 .Or. nTipo == 5
			MsAguarde({ | | CreaTmpCT2()},OemToAnsi(STR0001) )	
		EndIf
		
		If lNodoTrns .And. !VldCposSA1()
			MsgAlert(STR0037)
		EndIf
		If lNodoTrns .And. !VldCposSA2()
			MsgAlert(STR0038)
		EndIf
				
		If Empty(cRFCE) 
			Aviso( OemToAnsi(STR0003), OemToAnsi(STR0004), {STR0005} )
		Else
			If nTipo == 1 .Or. nTipo == 5
				Processa({ || CTBA602CT1() })
			EndIf
			If nTipo == 2 .Or. nTipo == 5
				Processa({ || CTBA602CT7() })
				DelAreaTrab()	
			EndIf
			If nTipo == 3 .Or. nTipo == 5
				Processa({ || CTBA602CT2() })
				DelAreaTrab() 	
			EndIf
			If nTipo == 4 .Or. nTipo == 5
				Processa({ || CTBA602XF() })
				DelAreaTrab()
				Processa({ || CTBA602XC() }) 		
				DelAreaTrab()
			EndIf
			If !Empty(cTempCT2)
				If oTmpTable <> Nil
					oTmpTable:Delete()
					oTmpTable := Nil
				EndIf
			EndIf
			If Len(aErrores) > 0
				aTitLog := {}
				aAdd( aTitLog , STR0014 +Space(10)+ STR0015 +Space(11)+ STR0016 )
				ImprimeLog(STR0008, aErrores, aTitLog)
			EndIf
			If Len(aErrPlz) > 0
				aTitLog := {}
				aAdd( aTitLog , STR0018 + Space(25) + STR0016)
				ImprimeLog(STR0020, aErrPlz, aTitLog)
			EndIf
		EndIf
	EndIf
	                                                 
	Restarea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCTBA602CT1      บAutor  ณLuis Samaniego      บ Data ณ  30/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Crea archivo xml del catalogo de cuentas                         บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTBA602CT1()
Local aNodoCtas   := {}
Local aNodoCta    := {}

Local cNomArch    := cRFCE + cAno + cMes + "CT.xml"
Local cNomArchTmp    := cRFCE + cAno + cMes + "CT.tmp"
Local cXmlCtas    := cXML
Local cDeudora    := "D"
Local cAcreedora  := "A"
Local cNodoCtas   := ""
Local cNodoCta    := ""
Local cSchemaLoc  := "http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/CatalogoCuentas http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/CatalogoCuentas/CatalogoCuentas_1_3.xsd"
Local cXmlnsXsi   := "http://www.w3.org/2001/XMLSchema-instance"
Local cXmlnsCCta  := "http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/CatalogoCuentas"
Local cDesCta     := ""

Local nPos        := 0
Local nArchXML       := 0
Local nArchTmp    := 0

	cCadenaOr := ""
	nArchXML := CreaArch(cNomArch, cExtXML)
	If lSeOpc
		nArchTmp := CreaArch(cNomArchTmp, cExtTMP)
	EndIf 
	If nArchXML == -1 .Or. nArchTmp == -1  
		Return
	EndIf
	
	aNodoCtas := {{'Version="#cValor#"', aVersion[1][1], .T.},;
		{'RFC="#cValor#"', cRfcHtml, .T.},;
		{'Mes="#cValor#"', cMes, .T.},;
		{'Anio="#cValor#"', cAno, .T.},;
		{'xsi:schemaLocation="#cValor#"', cSchemaLoc, .T.},;
		{'xmlns:xsi="#cValor#"', cXmlnsXsi, .T.},;
		{'xmlns:CatalogoCuentas="#cValor#"', cXmlnsCCta, .T.}}
	
	If lSeOpc 
		AADD(aNodoCtas,{'Sello="#cValor#"', '', .F.})
		AADD(aNodoCtas,{'noCertificado="#cValor#"', cNoCert, .F.})
		AADD(aNodoCtas,{'Certificado="#cValor#"', cCertif, .F.})
	
		CreaCadena(cPipe + cPipe,aVersion[1][1])
		CreaCadena(cPipe,cRFCE)
		CreaCadena(cPipe,cMes)
		CreaCadena(cPipe,cAno)
		
		GrabaTexto(cCadenaOr, nArchTmp, , .F.)
		cCadenaOr := ""
	EndIf
	
	cNodoCtas := AddSTR(aNodoCtas)
	cNodoSup := AddXML(cNodo, 'CatalogoCuentas:Catalogo', '#NomNodo#', .T.)
	cNodoCtas := AddXML(cNodoSup, cNodoCtas, '#cValAtrib#', .T.)
  	cXmlCtas += cNodoCtas
  	
	GrabaTexto(cXmlCtas, nArchXML)
	cXmlCtas := ""
	
	CT1->(dbGoTop())
	ProcRegua(CT1->(RecCount()))
	CT1->(DBSEEK(XFILIAL("CT1")))
	While CT1->(!EOF()) .and. CT1->CT1_FILIAL == XFILIAL("CT1")
		IncProc(STR0009)
		If !Empty(CT1->CT1_CODAGR) .And. Alltrim(CT1->CT1_CODAGR) != "NO APLICA"
			If ValCodAgr(CT1->CT1_CODAGR, CT1->CT1_CONTA, .F.,CT1->CT1_NIVEL)
			
				cDesCta := CT1->(CT1_DESC01 + CT1_DESC02 + CT1_DESC03 + CT1_DESC04) 

					// NombreAtributo, ValorAtributo, Obligatorio?
					aNodoCta:={{'CodAgrup="#cValor#"', CT1->CT1_CODAGR, .T.},;
						{'NumCta="#cValor#"', CT1->CT1_CONTA, .T.},;
						{'Desc="#cValor#"', CodHTML(cDesCta, .T.), .T.},; 
						{'SubCtaDe="#cValor#"', CT1->CT1_CTASUP, .F.},;
						{'Nivel="#cValor#"', CT1->CT1_NIVEL, .T.},;
						{'Natur="#cValor#"', If(AllTrim(CT1->CT1_NORMAL) == "1", cDeudora, cAcreedora), .T.}} 
					
					If lSeOpc 
						CreaCadena(cPipe,CT1->CT1_CODAGR)
						CreaCadena(cPipe,CT1->CT1_CONTA)
						CreaCadena(cPipe,CodHTML(cDesCta))
						CreaCadena(cPipe,CT1->CT1_CTASUP,,.T.)
						CreaCadena(cPipe,CT1->CT1_NIVEL)
						CreaCadena(cPipe,If(AllTrim(CT1->CT1_NORMAL) == "1", cDeudora, cAcreedora))
						
						GrabaTexto(cCadenaOr, nArchTmp, , .F.)
						cCadenaOr := ""
					EndIf
					
					cNodoCta := AddSTR(aNodoCta)
					cSubNodo := AddXML(cSNodo, 'CatalogoCuentas:Ctas', '#NomNodo#', .T.)
					cNodoCta := AddXML(cSubNodo, cNodoCta, '#cValAtrib#', .T.)
					cXmlCtas := Space(4) + cNodoCta
					//nTotalCtas := nTotalCtas + 1
					
					GrabaTexto(cXmlCtas, nArchXML)
					cXmlCtas := ""
			EndIf
		Else
			// Se agregan las cuentas que no tienen codigo agrupador
			If Alltrim(CT1->CT1_CODAGR) != "NO APLICA"
				nPos := aScan( aErrores,{|x| CT1->CT1_CONTA $ x} )
				If nPos == 0
					aAdd( aErrores, CT1->CT1_CONTA + Space(5) + Space(Len(CT1->CT1_CODAGR)) + Space(15) + STR0006 )	
				EndIf
			EndIf
		EndIf
		CT1->(dbSkip())		
	EndDo
	CT1->(dbCloseArea())
	
	cXmlCtas := AddXML(cFinNodo, 'CatalogoCuentas:Catalogo', "#cFinNodo#", .T.)
	GrabaTexto(cXmlCtas, nArchXML, .T.)
	
	If lSeOpc
		CreaCadena(cPipe+cPipe,"",.T.)
		GrabaTexto(cCadenaOr, nArchTmp, .T., .F.)
		cParam := cDir + " " + cNomArch + " " + cNomArchTmp + " " + cCFDiPri + " " + cCFDiCve
		nOpc := WAITRUN( cRutaSmr + cRutinaVB + Trim(cParam), 0 )  
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCTBA602CT7      บAutor  ณLuis Samaniego      บ Data ณ  30/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Crea archivo xml de la balanza de comprobaci๓n                   บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTBA602CT7()
Local aNodoBlnz    := {}
Local aNodoCta     := {}
Local aSetOfBook

Local oMeter
Local oText
Local oDlg

Local lImpAntLP    := IIf(Type("MV_PAR14") == "N", IIf(MV_PAR14 == 1, .T., .F.), .F.)
Local lVlrZerado   := lSldCero
Local lImpSint     := .T.
Local lRecDesp0    := .F.
Local lEnd   

Local dDataLP      := IIf(Type("MV_PAR15") == "D", MV_PAR15, CTOD("//"))
Local dDtZeraRD    := CTOD("//")

Local cNomArch     := cRFCE + cAno + cPerIni + IIf(MV_PAR07 == 1, "BN", "BC") + ".xml"
Local cXmlBlnz     := cXML
Local cNodoBlnz    := ""
Local cNodoCta     := ""
Local cArqTmp	   := ""
Local cCtaIni      := PadR( , TamSx3("CT1_CONTA")[1], " ")
Local cCtaFin      := PadR( , TamSx3("CT1_CONTA")[1], "Z")
Local cMoneda      := "01"
Local cTipoSal     := "1"
Local cIniSeg      := PadR( , 20, " ")	//"                    "
Local cFinSeg      := PadR( , 20, "Z")	//"ZZZZZZZZZZZZZZZZZZZZ"
Local cFilSeg      := PadR( , 30, " ")	//"                              "
Local cFilUser     := ".T."
Local cRecDesp     := "         "
Local cMoedaDsc    := " "
Local cSchemaLoc   := "http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/BalanzaComprobacion http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/BalanzaComprobacion/BalanzaComprobacion_1_3.xsd"
Local cXmlnsXsi    := "http://www.w3.org/2001/XMLSchema-instance"
Local cXmlnsBCE    := "http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/BalanzaComprobacion"
Local cNomArchTmp   := cRFCE + cAno + cPerIni + IIf(MV_PAR07 == 1, "BN", "BC") + ".tmp"

Local nDivide      := 1
Local nArchXML        := 0
Local nArchTmp  := 0
Local nSaldoAnt := 0 //SALDOANT
Local nSaldoDeb := 0 //SALDODEB
Local nSaldoCrd := 0 //SALDOCRD
Local nSaldoAtu := 0 //SALDOATU

	cCadenaOr := ""
	aSetOfBook := CTBSetOf(" ")	//Obtiene matriz de configuraci๓n de Libros
                                  	
	CTGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp,;
				dIni, dFim, "CT7", "", cCtaIni, cCtaFin, , , , , , ,cMoneda,;
				cTipoSal, aSetOfBook, " ", cIniSeg, cFinSeg, cFilSeg,;
				.F., .F. ,3, , lImpAntLP, dDataLP, nDivide, lVlrZerado, , , , , , , , , , , , , , lImpSint, cFilUser, lRecDesp0,;
				cRecDesp, dDtZeraRD, , , , , , , cMoedaDsc, , aSelFil) 
	
	aAdd ( aTmpArea , "cArqTmp" )
					
	If cArqTmp->(!EOF())
	
		nArchXML := CreaArch(cNomArch, cExtXML)
		If lSeOpc
			nArchTmp := CreaArch(cNomArchTmp, cExtTMP)
		EndIf 
		If nArchXML == -1 .Or. nArchTmp == -1  
			Return
		EndIf
		
		aNodoBlnz := {{'Version="#cValor#"', aVersion[1][2], .T.},;
			{'RFC="#cValor#"', cRfcHtml, .T.},;
			{'Mes="#cValor#"', cPerIni, .T.},;
			{'Anio="#cValor#"', cAno, .T.},;
			{'TipoEnvio="#cValor#"', cTipoEnvio, .T.},;
			{'xsi:schemaLocation="#cValor#"', cSchemaLoc, .T.},;
			{'xmlns:xsi="#cValor#"', cXmlnsXsi, .T.},;
			{'xmlns:BCE="#cValor#"', cXmlnsBCE, .T.}} 
				
		If AllTrim(cFechaModBal) <> "/  /"
			AADD(aNodoBlnz,{'FechaModBal="#cValor#"', formatoFecha(cFechaModBal,1), .F. })
		EndIf
		
		If lSeOpc 
			AADD(aNodoBlnz,{'Sello="#cValor#"', '', .F.})
			AADD(aNodoBlnz,{'noCertificado="#cValor#"', cNoCert, .F.})
			AADD(aNodoBlnz,{'Certificado="#cValor#"', cCertif, .F.})
		
			CreaCadena(cPipe+cPipe,aVersion[1][2])
			CreaCadena(cPipe,cRFCE)
			CreaCadena(cPipe,cPerIni)
			CreaCadena(cPipe,cAno)
			CreaCadena(cPipe,cTipoEnvio)
			If AllTrim(cFechaModBal) <> "/  /"
				CreaCadena(cPipe,formatoFecha(cFechaModBal,1),,.T.)
			EndIf
			
			GrabaTexto(cCadenaOr, nArchTmp, , .F.)
			cCadenaOr := ""
		EndIf
		
		cNodoBlnz := AddSTR(aNodoBlnz)
		cNodoSup := AddXML(cNodo, 'BCE:Balanza', '#NomNodo#', .T.)
		cNodoBlnz := AddXML(cNodoSup, cNodoBlnz, '#cValAtrib#', .T.)
	  	cXmlBlnz += cNodoBlnz
	  	
	  	GrabaTexto(cXmlBlnz, nArchXML)
		cXmlBlnz := ""
		
	  	ProcRegua(cArqTmp->(RecCount()))
	  	cArqTmp->(DBGoTop())
	  	While cArqTmp->(!EOF())
	  		IncProc(STR0010)
	  		
	  		If ValCuenta(cArqTmp->CONTA, .T.)
	  			nSaldoAnt := ValorCTB(cArqTmp->SALDOANT,,,TAM_VALOR-2,2,.T.,cPict1,cArqTmp->NORMAL,,,,"S",,lVlrZerado,.F.)
				nSaldoDeb := ValorCTB(cArqTmp->SALDODEB,,,TAM_VALOR-2,2,.F.,cPict1,"1",,,,,,lVlrZerado,.F.)
				nSaldoCrd := ValorCTB(cArqTmp->SALDOCRD,,,TAM_VALOR-2,2,.F.,cPict1,"2",,,,,,lVlrZerado,.F.)
				nSaldoAtu := ValorCTB(cArqTmp->SALDOATU,,,TAM_VALOR-2,2,.T.,cPict1,cArqTmp->NORMAL,,,,"S",,lVlrZerado,.F.)
		  		
		  		IIf(Empty(nSaldoAnt), nSaldoAnt := "0.00", "")
		  		IIf(Empty(nSaldoDeb), nSaldoDeb := "0.00", "")
		  		IIf(Empty(nSaldoCrd), nSaldoCrd := "0.00", "")
		  		IIf(Empty(nSaldoAtu), nSaldoAtu := "0.00", "")
		  		
				// NombreAtributo, ValorAtributo, Obligatorio?
				aNodoCta:={{'NumCta="#cValor#"', cArqTmp->CONTA, .T.},;
					{'SaldoIni="#cValor#"', nSaldoAnt, .T.},;
					{'Debe="#cValor#"',nSaldoDeb, .T.},;
					{'Haber="#cValor#"', nSaldoCrd, .T.},;
					{'SaldoFin="#cValor#"', nSaldoAtu, .T.}} 
					
				If lSeOpc 
					CreaCadena(cPipe,cArqTmp->CONTA)
					CreaCadena(cPipe,nSaldoAnt)
					CreaCadena(cPipe,nSaldoDeb)
					CreaCadena(cPipe,nSaldoCrd)
					CreaCadena(cPipe,nSaldoAtu)
					
					GrabaTexto(cCadenaOr, nArchTmp, , .F.)
					cCadenaOr := ""
				EndIf
				
				cNodoCta := AddSTR(aNodoCta)
				cSubNodo := AddXML(cSNodo, 'BCE:Ctas', '#NomNodo#', .T.)
				cNodoCta := AddXML(cSubNodo, cNodoCta, '#cValAtrib#', .T.)
				cXmlBlnz := Space(4) + cNodoCta
								
				GrabaTexto(cXmlBlnz, nArchXML)
				cXmlBlnz := ""
			EndIf
			cArqTmp->(dbSkip())
	  	EndDo
			  	
	  	cXmlBlnz := AddXML(cFinNodo, 'BCE:Balanza', "#cFinNodo#", .T.)
	  	GrabaTexto(cXmlBlnz, nArchXML, .T.)
	  	
	  	If lSeOpc
			CreaCadena(cPipe+cPipe,"",.T.)
			GrabaTexto(cCadenaOr, nArchTmp, .T., .F.)
			cParam := cDir + " " + cNomArch + " " + cNomArchTmp + " " + cCFDiPri + " " + cCFDiCve
			nOpc := WAITRUN( cRutaSmr + cRutinaVB + Trim(cParam), 0 ) 
		EndIf
	
	EndIf	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCTBA602CT2      บAutor  ณLuis Samaniego      บ Data ณ  30/09/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Crea archivo xml de Polizas                                      บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTBA602CT2()
Local aAtrbXml    := {} //Atributos Xml
Local aAtrbPlz    := {} //Atributos Nodo <Poliza>
Local aPlzCta     := {}

Local lPoliza     := .F.
Local lCtaSAT     := .F.
Local lNodoPlz    := .F.

Local cNomArch    := cRFCE + cAno + cMes + "PL.xml"
Local cAtrbXml    := "" //Atributos Xml
Local cAtrbPlz    := "" //Atributos Nodo <Poliza>
Local cMoneda     := ""
Local cQuery      := ""
Local cConcepto   := ""
Local cAtrbTrn    := ""
Local cNodoPlz    := ""
Local cNumUnIdenPol := ""
Local cNomArchTmp   := cRFCE + cAno + cMes + "PL.tmp"

Local cSchemaLoc  := "http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/PolizasPeriodo http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/PolizasPeriodo/PolizasPeriodo_1_3.xsd"
Local cXmlnsXsi   := "http://www.w3.org/2001/XMLSchema-instance"
Local cXmlnsPLZ   := "http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/PolizasPeriodo"

Local nPos        := 0 

Private nArchTmp   := 0
Private nArchXML  := 0
Private cAlias    := CriaTrab(Nil, .F.)
Private cXMLPlz   := cXML
Private lPlzNomina := .F.
	
	cCadenaOr := ""
	cQuery := " SELECT * "
	cQuery += " FROM " + RetSQLName("CT2") 
	cQuery += " WHERE CT2_DATA BETWEEN '" + DTOS(dIni) + "' AND '" + DTOS(dFim) + "' AND "
	cQuery += " CT2_FILIAL = '" + xFilial("CT2") + "' AND" 
	cQuery += " CT2_DC <> '4' AND" 
	cQuery += " CT2_TPSALD IN (" + cTipSaldo + ")"
	cQuery += " AND D_E_L_E_T_ = ''"
	cQuery += " ORDER BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_EMPORI, CT2_FILORI, CT2_MOEDLC, CT2_SEQIDX ASC"//R_E_C_N_O_	ASC"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.) 
	
	aAdd ( aTmpArea , cAlias )
	
	(cAlias)->(dbGoTop())
	If !(cAlias)->(EOF())
		
		nArchXML := CreaArch(cNomArch, cExtXML)
		If lSeOpc
			nArchTmp := CreaArch(cNomArchTmp, cExtTMP)
		EndIf 
		If nArchXML == -1 .Or. nArchTmp == -1  
			Return
		EndIf
		
		aAtrbXml := {{'Version="#cValor#"', aVersion[1][3], .T.},;
				{'RFC="#cValor#"', cRfcHtml, .T.},;
				{'Mes="#cValor#"', cMes, .T.},;
				{'Anio="#cValor#"', cAno, .T.},;
				{'TipoSolicitud="#cValor#"', cTipoSolicitud, .T.},;
				{'xsi:schemaLocation="#cValor#"', cSchemaLoc, .T.},;
				{'xmlns:xsi="#cValor#"', cXmlnsXsi, .T.},;
				{'xmlns:PLZ="#cValor#"', cXmlnsPLZ, .T.}}
	  	
		IF !Empty(cNumOrden) .and. AllTrim(cNumOrden) <> "/"
			AADD(aAtrbXml,{'NumOrden="#cValor#"', CodHTML(cNumOrden, .T.), .F.})
		EndIf
		
		IF !Empty(cNumTramite)
			AADD(aAtrbXml,{'NumTramite="#cValor#"', CodHTML(cNumTramite, .T.), .F.})
		EndIf
		
		If lSeOpc 
			AADD(aAtrbXml,{'Sello="#cValor#"', '', .F.})
			AADD(aAtrbXml,{'noCertificado="#cValor#"', cNoCert, .F.})
			AADD(aAtrbXml,{'Certificado="#cValor#"', cCertif, .F.})
			
		
			CreaCadena(cPipe+cPipe,aVersion[1][3])
			CreaCadena(cPipe,cRFCE)
			CreaCadena(cPipe,cMes)
			CreaCadena(cPipe,cAno)
			CreaCadena(cPipe,cTipoSolicitud)
			IF !Empty(cNumOrden) .and. AllTrim(cNumOrden) <> "/"
				CreaCadena(cPipe,CodHTML(cNumOrden),,.T.)
			EndIf
			IF !Empty(cNumTramite)
				CreaCadena(cPipe,CodHTML(cNumTramite),,.T.)
			EndIf
			
			GrabaTexto(cCadenaOr, nArchTmp, , .F.)
			cCadenaOr := ""
		EndIF
		
		cAtrbXml := AddSTR(aAtrbXml)
		cNodoSup := AddXML(cNodo, 'PLZ:Polizas', '#NomNodo#', .T.)
		cAtrbXml := AddXML(cNodoSup, cAtrbXml, '#cValAtrib#', .T.)
		cXMLPlz += Space(4) + cAtrbXml
		
		GrabaTexto(cXMLPlz, nArchXML)
		cXMLPlz := ""
		
		
		ProcRegua((cAlias)->(RecCount()))
		While !(cAlias)->(Eof())
			IncProc(STR0026)	
			
			If!Empty(Alltrim((cAlias)->CT2_DEBITO))
				lCtaSAT := ValCuenta((cAlias)->CT2_DEBITO, .F.)
			EndIf       
			If !Empty(Alltrim((cAlias)->CT2_CREDIT))
				lCtaSAT := ValCuenta((cAlias)->CT2_CREDIT, .F.)	
			EndIf
			
			If lCtaSAT
			
				cAtrbTrn := ""
				nPos := aScan( aPlzCta,{|x| x == (cAlias)->CT2_LOTE + (cAlias)->CT2_SBLOTE + (cAlias)->CT2_DOC + (cAlias)->CT2_DATA} ) //+ (cAlias)->CT2_SEQUEN
				
				cConcepto := ObtConcepto((cAlias)->CT2_HIST, (cAlias)->CT2_LOTE, (cAlias)->CT2_SBLOTE, (cAlias)->CT2_DOC, (cAlias)->CT2_DATA) //(cAlias)->CT2_SEQUEN
				
				If 	npos == 0
					If Len(aPlzCta) > 0 .And. lNodoPlz
						cNodoPlz := Space(8) + AddXML(cFinNodo, 'PLZ:Poliza', "#cFinNodo#", .T.)
						GrabaTexto(cNodoPlz, nArchXML)
						cNodoPlz := ""
					EndIf	
						
					cNumUnIdenPol := CodHTML((cAlias)->(CT2_LOTE + CT2_SBLOTE + CT2_DOC))
					
					// NombreAtributo, ValorAtributo, Obligatorio?
					aAtrbPlz := {{'NumUnIdenPol="#cValor#"', cNumUnIdenPol , .T.},; 
								{'Fecha="#cValor#"', formatoFecha((cAlias)->CT2_DATA), .T.},;
								{'Concepto="#cValor#"', CodHTML(cConcepto, .T.), .T.}}
					
					If lSeOpc
						CreaCadena(cPipe,cNumUnIdenPol)
						CreaCadena(cPipe,formatoFecha((cAlias)->CT2_DATA))
						CreaCadena(cPipe,CodHTML(cConcepto))
					EndIf
									
					cAtrbPlz := AddSTR(aAtrbPlz)
					cNodoSup := AddXML(cNodo, 'PLZ:Poliza', '#NomNodo#', .T.)
					cAtrbPlz := AddXML(cNodoSup, cAtrbPlz, '#cValAtrib#', .T.)
					cNodoPlz := Space(8) + cAtrbPlz
					cMoneda := (cAlias)->CT2_MOEDLC 
					aAdd (aPlzCta, (cAlias)->CT2_LOTE + (cAlias)->CT2_SBLOTE + (cAlias)->CT2_DOC + (cAlias)->CT2_DATA) //(cAlias)->CT2_SEQUEN
					
					If !Empty(cNumUnIdenPol)
						lPoliza  := .T.
						lNodoPlz := .F.
					EndIf
					lPlzNomina := .F.
				EndIf
				
				If !Empty(Alltrim((cAlias)->CT2_DEBITO)) .And. (cMoneda == (cAlias)->CT2_MOEDLC) // Cuenta de Debito
					cAtrbTrn := CTBTrans("D", cConcepto, @lPoliza, @cNodoPlz)	//Debito
					
					If !Empty(cAtrbTrn) .And. lPoliza
						cNodoPlz += cAtrbTrn
						
						GrabaTexto(cNodoPlz, nArchXML)
						cNodoPlz := ""
						If lSeOpc
							GrabaTexto(cCadenaOr, nArchTmp, , .F.)
							cCadenaOr := ""
						EndIf
						lNodoPlz := .T.
					ElseIf lPlzNomina
						lNodoPlz := .T.
					EndIf
				EndIf
				If !Empty(Alltrim((cAlias)->CT2_CREDIT)) .And. (cMoneda == (cAlias)->CT2_MOEDLC) //Cuenta de Credito
					cAtrbTrn := CTBTrans("C", cConcepto, @lPoliza, @cNodoPlz)	//Credito
					
					If !Empty(cAtrbTrn) .And. lPoliza
						cNodoPlz += cAtrbTrn
						
						GrabaTexto(cNodoPlz, nArchXML)
						cNodoPlz := ""
						If lSeOpc
							GrabaTexto(cCadenaOr, nArchTmp, , .F.)
							cCadenaOr := ""
						EndIf
						lNodoPlz := .T.
					ElseIf lPlzNomina
						lNodoPlz := .T.
					EndIf
				EndIf 
			
			EndIf
			(cAlias)->(dbSkip())
		EndDo
	
		If lNodoPlz
			cXMLPlz += Space(8) + AddXML(cFinNodo, 'PLZ:Poliza', "#cFinNodo#", .T.)
		EndIf
		cXMLPlz += Space(4) + AddXML(cFinNodo, 'PLZ:Polizas', "#cFinNodo#", .T.)
		
		GrabaTexto(cXMLPlz, nArchXML, .T.)
		
		If lSeOpc
			CreaCadena(cPipe+cPipe,"",.T.)
			cParam := cDir + " " + cNomArch + " " + cNomArchTmp + " " + cCFDiPri + " " + cCFDiCve
			GrabaTexto(cCadenaOr, nArchTmp, .T., .F.)
			nOpc := WAITRUN( cRutaSmr + cRutinaVB + Trim(cParam), 0 ) 
		EndIf
		aPlzNom := {}
		aEval(aBrowse,{|x| x[9]:= "" })
	EndIf	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCTBTrans        บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCrea nodo 'PLZ:Transaccion'                                       บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTBTrans(cTipoMov, cConcepto, lPoliza, cNodoPlz)
Local cCuenta    := ""
Local nVlrDebe   := 0
Local nVlrHaber  := 0

Local aAtrbTrn   := {} //Atributos Nodo <Transaccion>
Local aAtrbCmp   := {} //Atributos Nodo <Comprobante>

Local cAtrbTrn   := "" //Atributos Nodo <Transaccion>
Local cAtrbDet   := "" //Atributos detalle (<Transferencia>, <Cheque>)
Local cDesCta    := ""


Private cMoeSat    := ""
Private cTipCam    := ""

	lCompNac   := .F.
	
	If cTipoMov == "D" //Debido - Debe
		cCuenta := (cAlias)->CT2_DEBITO
		nVlrDebe := (cAlias)->CT2_VALOR 
	ElseIf cTipoMov == "C" //Credito - Haber
		cCuenta := (cAlias)->CT2_CREDIT
		nVlrHaber := (cAlias)->CT2_VALOR
	EndIf
	
	cDesCta := ObtDescCta(cCuenta)
	
	// NombreAtributo, ValorAtributo, Obligatorio?
	aAtrbTrn := {{'NumCta="#cValor#"', cCuenta, .T.},;
				{'DesCta="#cValor#"', CodHTML(cDesCta, .T.), .T.},;
				{'Concepto="#cValor#"', CodHTML(cConcepto, .T.), .T.},;
				{'Debe="#cValor#"', nVlrDebe, .T.},;
				{'Haber="#cValor#"', nVlrHaber, .T.}}
	
	If lSeOpc
		CreaCadena(cPipe,cCuenta)
		CreaCadena(cPipe,CodHTML(cConcepto))
		CreaCadena(cPipe,nVlrDebe)
		CreaCadena(cPipe,nVlrHaber)
	EndIf
	
		cRFC:= (cAlias)->CT2_RFC
		lCompNac := VldNacional((cAlias)->CT2_RFC)
	
	cAtrbTrn := AddSTR(aAtrbTrn)
	
	If lNodoOpc 
		cAtrbDet := CTBDetalle(@lPoliza)
	EndIf
	
	If !Empty(cAtrbTrn) .And. (Empty(cAtrbCmp) .Or. Empty(cAtrbDet))
		lPlzNomina := VldFolRN(.T., cAtrbTrn, @cNodoPlz, cCuenta)
	EndIf
	
	If !lPlzNomina .And. (!Empty(cAtrbTrn) .And. Empty(cAtrbCmp))
		If !Empty((cAlias)->CT2_RFC) .And. !Empty((cAlias)->CT2_UUID)
			Comprobante((cAlias)->CT2_UUID, (cAlias)->CT2_VALOR, .F.)
		EndIf
	EndIf
	
	If lNodoOpc .And. (!Empty(cAtrbCmp) .Or. !Empty(cAtrbDet)) .And. !lPlzNomina
		cNodoSup := AddXML(cNodo, 'PLZ:Transaccion', '#NomNodo#', .T.)
	   	cAtrbTrn := AddXML(cNodoSup, cAtrbTrn, '#cValAtrib#', .T.)
	   	cAtrbTrn := Space(12) + cAtrbTrn
	   	
	   	If !Empty(cAtrbCmp)
	   		cAtrbTrn += Space (16) + cAtrbCmp
	   	EndIf
	   	If !Empty(cAtrbDet)
	   		cAtrbTrn += Space(16) + cAtrbDet
	   	EndIf
	   	
	   	cAtrbTrn += Space(12) + AddXML(cFinNodo, 'PLZ:Transaccion', "#cFinNodo#", .T.)     
	ElseIf lPlzNomina 
		cAtrbTrn := ""
	Else  		
	   	cSubNodo := AddXML(cSNodo, 'PLZ:Transaccion', '#NomNodo#', .T.)
		cAtrbTrn := AddXML(cSubNodo, cAtrbTrn, '#cValAtrib#', .T.)
	   	cAtrbTrn := Space(12) + cAtrbTrn	
	EndIf
Return cAtrbTrn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCTBDetalle      บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณForma los nodos PLZ:Transferencia, PLZ:Cheque, RepAux:ComprExt y  บฑฑ
ฑฑบ          ณPLZ:OtrMetodoPago                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTBDetalle(lPoliza, lRepAux)
Local cTabOri      := ""	
Local cKey         := ""
Local cTablas      := "SE5|SEK|SEL|SF1|SF2"
Local cCtaOri      := ""
Local cBancoOri    := ""
Local cFecha       := ""
Local cCtaDest     := ""
Local cBancoDest   := ""
Local cBenef       := ""
Local cNum         := ""
Local cBanco       := ""
Local cNumFactExt  := ""
Local cMetPag      := ""
Local cBcoOriExt   := ""
Local cBcoDesExt   := ""                            

Local cProctra   := ""
Local lTransf    := .F.
Local lCheque    := .F.
Local lCompExt   := .F. 
Local lOtrMetP   := .F.

Local aAtrbDet := "" //Atributos detalle (<Transferencia>, <Cheque>)
Local cAtrbDet := "" //Atributos detalle (<Transferencia>, <Cheque>)
Local nValBrut := ""


Default lRepAux := .F.
	
	cAtrbCmp := ""
	
	If CTL->(MsSeek( xFilial("CTL") + Alltrim((cAlias)->CT2_LP)))
		If Alltrim(CTL->CTL_ALIAS) $ (cTablas)
			cTabOri  := Alltrim(CTL->CTL_ALIAS)
			cKey     := Alltrim(CTL->CTL_KEY)
			
			dbSelectArea(cTabOri)
			(cTabOri)->(DBSetOrder(RETORDEM((cTabOri), (cKey))))
			If (cTabOri)->(MsSeek(AllTrim((cAlias)->CT2_KEY)))
				If cTabOri $ ("SE5") .And. !lRepAux
					If Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPODOC")) == "TR" //Transferencia 
						
						cProctra := (cTabOri)->E5_PROCTRA
						
						(cTabOri)->(DBSetOrder(RETORDEM("SE5","E5_FILIAL+E5_PROCTRA")))
						(cTabOri)->(MsSeek( xFilial(cTabOri) + cProctra)) 
						
						While (cTabOri)->(E5_PROCTRA) == cProctra
						    If (cTabOri)->E5_RECPAG == "P"
						    	cCtaOri := (cTabOri)->E5_CONTA
						    	cBancoOri := ObtBancoSAT((cTabOri)->E5_BANCO, @lPoliza, @cBcoOriExt)
						    ElseIf (cTabOri)->E5_RECPAG == "R"
						    	cCtaDest := (cTabOri)->E5_CONTA
						    	cBancoDest := ObtBancoSAT((cTabOri)->E5_BANCO, @lPoliza, @cBcoDesExt)	
						    EndIf
						    
						    cFecha := (cTabOri)->E5_DATA
						    cBenef := (cTabOri)->E5_BENEF
						    cRFC := SM0->M0_CGC
						    nMonto := (cTabOri)->E5_VALOR
						    cMoeSat := ObtMonedaSat((cAlias)->CT2_MOEDLC, @lPoliza)
						    cTipCam := (cTabOri)->E5_TXMOEDA
						    
							(cTabOri)->(dbSkip())
						EndDo     
						lTransf := .T.
						
					ElseIf Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPO")) $ "CH|TF|EF|CA" .Or.; //Cheque 
						Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPODOC")) $ "CP|ES"				//Compensacion y cancelacion        
					
						cNum := (cTabOri)->E5_NUMCHEQ 
						cBanco := ObtBancoSAT((cTabOri)->E5_BANCO, @lPoliza, @cBcoOriExt)
						cCtaOri := (cTabOri)->E5_CONTA
						cFecha := (cTabOri)->E5_DATA 
						nMonto := (cTabOri)->E5_VALOR
						cMoeSat := ObtMonedaSat(Strzero(Val((cTabOri)->E5_MOEDA), 2), @lPoliza)
						cTipCam := (cTabOri)->E5_TXMOEDA 
						
						If !Empty((cTabOri)->E5_CLIENTE) 
							ObtRFC((cTabOri)->E5_CLIENTE, (cTabOri)->E5_LOJA, "1", @cRFC, @cBenef) //Cliente
						ElseIf !Empty((cTabOri)->E5_FORNECE) 
							ObtRFC((cTabOri)->E5_FORNECE, (cTabOri)->E5_LOJA, "2", @cRFC, @cBenef) //Proveedor
						EndIf 
						
						If Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPO")) $ "CH|CA"    
							lCheque := .T.
						ElseIf Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPO")) $ "TF|EF"
							cMetPag := ObtMetPago(Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPO")))
							lOtrMetP := .T.
						ElseIf Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPODOC")) $ "CP|ES"
							cMetPag := ObtMetPago(Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPODOC")))
							lOtrMetP := .T.
						EndIf 
						
					EndIf	
				ElseIf cTabOri $ ("SEK")
					If (Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPO")) $ "CH|TF|EF|CA" .Or.; //Cheque 
						Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPODOC")) $ "CP|ES") .And. !lRepAux			//Compensacion y cancelacion 
					
						cNum := (cTabOri)->EK_NUM 
						cBanco := ObtBancoSAT((cTabOri)->EK_BANCO, @lPoliza, @cBcoOriExt)
						cCtaOri := (cTabOri)->EK_CONTA
						cFecha := (cTabOri)->EK_EMISSAO 
						nMonto := (cTabOri)->EK_VALOR
						
						cMoeSat := ObtMonedaSat(Strzero(Val((cTabOri)->EK_MOEDA), 2), @lPoliza)
						If cMoeSat == "MXN"
							cTipCam := "1.00"
						Else
							If (cTabOri)->(FieldPos("EK_TXMOE" + Strzero(Val((cTabOri)->EK_MOEDA), 2))) > 0
								cTipCam := &("SEK->EK_TXMOE" + Strzero(Val((cTabOri)->EK_MOEDA), 2))
							EndIf
						EndIf
						
						If !Empty((cTabOri)->EK_ENTRCLI)
							ObtRFC((cTabOri)->EK_ENTRCLI, (cTabOri)->EK_LOJCLI, "1", @cRFC, @cBenef) //Cliente
						ElseIf !Empty((cTabOri)->EK_FORNEPG)
							ObtRFC((cTabOri)->EK_FORNEPG, (cTabOri)->EK_LOJAPG, "2", @cRFC, @cBenef) //Proveedor	
						EndIf
						
						If Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPO")) $ "CH|CA"    
							lCheque := .T.
						ElseIf Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPO")) $ "TF|EF"
							If lNodoTrns .And. !Empty(cBcoPago) .And. !Empty(cCtaPago)
								cCtaOri := (cTabOri)->EK_CONTA
								cBancoOri := ObtBancoSAT((cTabOri)->EK_BANCO, @lPoliza, @cBcoOriExt)
								cCtaDest := cCtaPago
								cBancoDest := ObtBancoSAT(cBcoPago, @lPoliza, @cBcoDesExt)
								lTransf := .T.
							Else
								cMetPag := ObtMetPago(Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPO")))
								lOtrMetP := .T.
							EndIf
						ElseIf Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPODOC")) $ "CP|ES"
							cMetPag := ObtMetPago(Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPODOC")))
							lOtrMetP := .T.
						EndIf
						
					ElseIf Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPO")) $ "NF|NDP|NCI"
					
							ObtRFC((cTabOri)->EK_FORNEPG, (cTabOri)->EK_LOJAPG, "2", @cRFC, @cBenef) //Proveedor	
							
							SF1->(dbSetOrder(RETORDEM("SF1","F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA")))
							
							If SF1->(MsSeek(xFilial("SF1")+(cTabOri)->EK_NUM+(cTabOri)->EK_PREFIXO+(cTabOri)->EK_FORNEPG+(cTabOri)->EK_LOJAPG))
								lCompNac := VldNacional(cRFC)
								cMoeSat := ObtMonedaSat(Strzero(SF1->F1_MOEDA, 2), @lPoliza)
								cTipCam := SF1->F1_TXMOEDA
								
								If lCompNac 
									If !Empty(SF1->F1_UUID) .And.  !Empty(Str(SF1->F1_VALBRUT)) .And. !Empty(cRFC) .And. lNodoOpc
										Comprobante(SF1->F1_UUID,SF1->F1_VALBRUT,lRepAux)
									EndIf
								Else
									cNumFactExt  := SF1->(Alltrim(F1_SERIE) + AllTrim(F1_DOC))
									nValBrut := SF1->F1_VALBRUT 
									lCompExt     := .T.
								EndIf		
							EndIf
							
					ElseIf Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPO")) $ "NCP|NDI"
							ObtRFC((cTabOri)->EK_ENTRCLI, (cTabOri)->EK_LOJCLI, "2", @cRFC, @cBenef) //Proveedor	
							
							SF2->(dbSetOrder(RETORDEM("SF2","F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA")))
							
							If SF2->(MsSeek(xFilial("SF2")+(cTabOri)->EK_NUM+(cTabOri)->EK_PREFIXO+(cTabOri)->EK_FORNEPG+(cTabOri)->EK_LOJAPG))
								lCompNac := VldNacional(cRFC)
								cMoeSat := ObtMonedaSat(Strzero(SF2->F2_MOEDA, 2), @lPoliza)
								cTipCam := SF2->F2_TXMOEDA
										
								If lCompNac 
									If !Empty(SF2->F2_UUID) .And.  !Empty(Str(SF2->F2_VALBRUT)) .And. !Empty(cRFC) .And. lNodoOpc
										Comprobante(SF2->F2_UUID,SF2->F2_VALBRUT,lRepAux)
									EndIf
								Else
									cNumFactExt  := SF2->(Alltrim(F2_SERIE) + AllTrim(F2_DOC))
									nValBrut := SF2->F2_VALBRUT 
									lCompExt     := .T.
								EndIf			
							EndIf
							
					EndIf
				ElseIf cTabOri $ ("SEL") 
					If (Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPO")) $ "CH|TF|EF|CA" .Or.; //Cheque 
						Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPODOC")) $ "CP|ES") .And. !lRepAux			//Compensacion y cancelacion  
						
						cNum := (cTabOri)->EL_NUMERO 
						cBanco := ObtBancoSAT((cTabOri)->EL_BANCO, @lPoliza, @cBcoOriExt)
						cCtaOri := (cTabOri)->EL_CONTA
						cFecha := (cTabOri)->EL_EMISSAO 
						nMonto := (cTabOri)->EL_VALOR 
						
						cMoeSat := ObtMonedaSat(Strzero(Val((cTabOri)->EL_MOEDA), 2), @lPoliza)
						
						If cMoeSat == "MXN"
							cTipCam := "1.00"
						Else
							If (cTabOri)->(FieldPos("EL_TXMOE" + Strzero(Val((cTabOri)->EL_MOEDA), 2))) > 0
								cTipCam := &("SEL->EL_TXMOE" + Strzero(Val((cTabOri)->EL_MOEDA), 2))
							EndIf
						EndIf
						
						If !Empty((cTabOri)->EL_CLIENTE)
							ObtRFC((cTabOri)->EL_CLIENTE, (cTabOri)->EL_LOJA, "1", @cRFC, @cBenef) //Cliente	
						EndIf
						
						If Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPO")) $ "CH|CA"    
							lCheque := .T.
						ElseIf Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPO")) $ "TF|EF"
							If lNodoTrns .And. !Empty(cBcoPago) .And. !Empty(cCtaPago)
								cBenef := SM0->M0_NOME
								cRFC   := SM0->M0_CGC
								cCtaOri := cCtaPago
								cBancoOri := ObtBancoSAT(cBcoPago, @lPoliza, @cBcoOriExt)
								cCtaDest := (cTabOri)->EL_CONTA
								cBancoDest := ObtBancoSAT((cTabOri)->EL_BANCO, @lPoliza, @cBcoDesExt)
								lTransf := .T.
							Else
								cMetPag := ObtMetPago(Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPO")))
								lOtrMetP := .T.
							EndIf
						ElseIf Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPODOC")) $ "CP|ES"
							cMetPag := ObtMetPago(Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPODOC")))
							lOtrMetP := .T.
						EndIf
						
					ElseIf Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPO")) $ "NF|NDC|NCE"
							
							If !Empty((cTabOri)->EL_CLIENTE)
								ObtRFC((cTabOri)->EL_CLIENTE, (cTabOri)->EL_LOJA, "1", @cRFC, @cBenef) //Cliente	
							EndIf
							
							SF2->(dbSetOrder(RETORDEM("SF2","F2_FILIAL+F2_DOC+F2_SERIE+F2_FORNECE+F2_LOJA")))
							
							If SF2->(MsSeek(xFilial("SF2")+(cTabOri)->EL_NUMERO+(cTabOri)->EL_PREFIXO+(cTabOri)->EL_CLIENTE+(cTabOri)->EL_LOJA))
								If !Empty(SF2->F2_UUID) .And.  !Empty(Str(SF2->F2_VALBRUT)) .And. !Empty(cRFC) .And. lNodoOpc
									cMoeSat := ObtMonedaSat(Strzero(SF2->F2_MOEDA, 2), @lPoliza)
									cTipCam := SF2->F2_TXMOEDA
									Comprobante(SF2->F2_UUID,SF2->F2_VALBRUT,lRepAux)
								EndIf		
							EndIf
							
					ElseIf Alltrim((cTabOri)-> & (SubStr(cTabOri, 2, 2)+"_TIPO")) $ "NDE|NCC"
					
							If !Empty((cTabOri)->EL_CLIENTE)
								ObtRFC((cTabOri)->EL_CLIENTE, (cTabOri)->EL_LOJA, "1", @cRFC, @cBenef) //Cliente
							EndIf
							
							SF1->(dbSetOrder(RETORDEM("SF1","F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA")))
							
							If SF1->(MsSeek(xFilial("SF1")+(cTabOri)->EL_NUMERO+(cTabOri)->EL_PREFIXO+(cTabOri)->EL_CLIENTE+(cTabOri)->EL_LOJA))
								If !Empty(SF1->F1_UUID) .And.  !Empty(Str(SF1->F1_VALBRUT)) .And. !Empty(cRFC) .And. lNodoOpc
									cMoeSat := ObtMonedaSat(Strzero(SF1->F1_MOEDA, 2), @lPoliza)
									cTipCam := SF1->F1_TXMOEDA
									Comprobante(SF1->F1_UUID,SF1->F1_VALBRUT,lRepAux)
								EndIf		
							EndIf
							
					EndIf
				ElseIf cTabOri $ ("SF1")
					cMoeSat := ObtMonedaSat(Strzero((cTabOri)->F1_MOEDA, 2), @lPoliza)
					cTipCam := (cTabOri)->F1_TXMOEDA
					
					If !lCompNac
						cNumFactExt  := (cTabOri)->(Alltrim(F1_SERIE) + AllTrim(F1_DOC))
						nValBrut := (cTabOri)->F1_VALBRUT
						lCompExt     := .T.
					Else
						If !Empty((cTabOri)->F1_UUID) .And.  !Empty(Str((cTabOri)->F1_VALBRUT)) .And. lNodoOpc
							Comprobante((cTabOri)->F1_UUID,(cTabOri)->F1_VALBRUT,lRepAux)
						EndIf
					EndIf
				ElseIf cTabOri $ ("SF2") 
					cMoeSat := ObtMonedaSat(Strzero((cTabOri)->F2_MOEDA, 2), @lPoliza)
					cTipCam := (cTabOri)->F2_TXMOEDA
					
					If lCompNac
						If !Empty((cTabOri)->F2_UUID) .And.  !Empty(Str((cTabOri)->F2_VALBRUT)) .And. lNodoOpc
							Comprobante((cTabOri)->F2_UUID,(cTabOri)->F2_VALBRUT,lRepAux)
						EndIf
					Else
						cNumFactExt  := (cTabOri)->(Alltrim(F2_SERIE) + AllTrim(F2_DOC)) 
						nValBrut := (cTabOri)->F2_VALBRUT
						lCompExt     := .T.
					EndIf
				EndIf
				
				If lTransf
					// NombreAtributo, ValorAtributo, Obligatorio?
					aAtrbDet := {{'CtaOri="#cValor#"', cCtaOri, .F.},;
						 			{'BancoOriNal="#cValor#"', cBancoOri, .T.},;
						 			{'BancoOriExt="#cValor#"', CodHTML(cBcoOriExt, .T.), .F.},;
						 			{'CtaDest="#cValor#"', cCtaDest, .T.},; 
						 			{'BancoDestNal="#cValor#"', cBancoDest, .T.},;
						 			{'BancoDestExt="#cValor#"', CodHTML(cBcoDesExt, .T.), .F.},; 
						 			{'Fecha="#cValor#"', formatoFecha(cFecha,1), .T.},;
						 			{'Benef="#cValor#"', CodHTML(cBenef, .T.), .T.},;
						 			{'RFC="#cValor#"', CodHTML(UPPER(cRFC), .T.), .T.},;
						 			{'Monto="#cValor#"', nMonto, .T.},;
						 			{'Moneda="#cValor#"', cMoeSat, .F.},;
						 			{'TipCamb="#cValor#"', cTipCam, .F.}}				 			
					
					If lSeOpc
						CreaCadena(cPipe,cCtaOri,,.T.)
						CreaCadena(cPipe,cBancoOri)
						CreaCadena(cPipe,CodHTML(cBcoOriExt),,.T.)
						CreaCadena(cPipe,cCtaDest)
						CreaCadena(cPipe,cBancoDest)
						CreaCadena(cPipe,CodHTML(cBcoDesExt),,.T.)
						CreaCadena(cPipe,formatoFecha(cFecha,1))
						CreaCadena(cPipe,CodHTML(cBenef))
						CreaCadena(cPipe,CodHTML(UPPER(cRFC)))
						CreaCadena(cPipe,nMonto)
						CreaCadena(cPipe,cMoeSat,,.T.)
						CreaCadena(cPipe,cTipCam,,.T.)
					EndIf
						 			 
					cAtrbDet := AddSTR(aAtrbDet)
					
					cSubNodo := AddXML(cSNodo, 'PLZ:Transferencia', '#NomNodo#', .T.)
					cAtrbDet := AddXML(cSubNodo, cAtrbDet, '#cValAtrib#', .T.)
					cAtrbDet := cAtrbDet
			
				ElseIf lCheque
					// NombreAtributo, ValorAtributo, Obligatorio?
					aAtrbDet := {{'Num="#cValor#"', cNum, .T.},;
						 			{'BanEmisNal="#cValor#"', cBanco, .T.},;
						 			{'BanEmisExt="#cValor#"', CodHTML(cBcoOriExt, .T.), .F.},;
						 			{'CtaOri="#cValor#"', cCtaOri, .T.},;
						 			{'Fecha="#cValor#"', formatoFecha(cFecha,1), .T.},;
						 			{'Benef="#cValor#"', CodHTML(cBenef, .T.), .T.},; 
						 			{'RFC="#cValor#"', CodHTML(UPPER(cRFC), .T.), .T.},;
						 			{'Monto="#cValor#"', nMonto, .T.},;
						 			{'Moneda="#cValor#"', cMoeSat, .F.},;
						 			{'TipCamb="#cValor#"', cTipCam, .F.}}
						 			
					If lSeOpc
						CreaCadena(cPipe,cNum)
						CreaCadena(cPipe,cBanco)
						CreaCadena(cPipe,CodHTML(cBcoOriExt),,.T.)
						CreaCadena(cPipe,cCtaOri)
						CreaCadena(cPipe,formatoFecha(cFecha,1))
						CreaCadena(cPipe,CodHTML(cBenef),,.T.)
						CreaCadena(cPipe,CodHTML(UPPER(cRFC)))
						CreaCadena(cPipe,nMonto)
						CreaCadena(cPipe,cMoeSat,,.T.)
						CreaCadena(cPipe,cTipCam,,.T.) 
					EndIf
					 
					cAtrbDet := AddSTR(aAtrbDet)
					
					cSubNodo := AddXML(cSNodo, 'PLZ:Cheque', '#NomNodo#', .T.)
					cAtrbDet := AddXML(cSubNodo, cAtrbDet, '#cValAtrib#', .T.)
					cAtrbDet := cAtrbDet	
				ElseIf lCompExt
					// NombreAtributo, ValorAtributo, Obligatorio?
					aAtrbDet := {{'NumFactExt="#cValor#"', cNumFactExt , .T.},;
									{'TaxID="#cValor#"', cRFC , .F.},;
									{'MontoTotal="#cValor#"', nValBrut , .T.},;
									{'Moneda="#cValor#"', cMoeSat, .F.},;
									{'TipCamb="#cValor#"', cTipCam, .F.}}
					
					If lSeOpc
						If lRepAux
							CreaCadena(cPipe, cNumUnIdenPol)
							CreaCadena(cPipe,formatoFecha((cAlias)->CT2_DATA))
						EndIf				
						CreaCadena(cPipe,cNumFactExt)
						If lRepAux
							CreaCadena(cPipe,nValBrut)
							CreaCadena(cPipe,cMoeSat,,.T.)
							CreaCadena(cPipe,cTipCam,,.T.)
						EndIf
					EndIf
					
					cAtrbDet := AddSTR(aAtrbDet)

					cSubNodo := AddXML(cSNodo, Iif(lRepAux, 'RepAux:ComprExt', 'PLZ:CompExt'), '#NomNodo#', .T.)
					cAtrbDet := AddXML(cSubNodo, cAtrbDet, '#cValAtrib#', .T.)
					cAtrbDet := cAtrbDet
				ElseIf lOtrMetP
					// NombreAtributo, ValorAtributo, Obligatorio?
					aAtrbDet := {{'MetPagoPol="#cValor#"', cMetPag, .T.},;
									{'Fecha="#cValor#"', formatoFecha(cFecha,1), .T.},;
									{'Benef="#cValor#"', CodHTML(cBenef, .T.), .T.},;
									{'RFC="#cValor#"', CodHTML(UPPER(cRFC), .T.), .T.},;
									{'Monto="#cValor#"', nMonto, .T.},;
									{'Moneda="#cValor#"', cMoeSat, .F.},;
									{'TipCamb="#cValor#"', cTipCam, .F.}}
					
					If lSeOpc
						CreaCadena(cPipe,cMetPag)
						CreaCadena(cPipe,formatoFecha(cFecha,1))
						CreaCadena(cPipe,CodHTML(cBenef))
						CreaCadena(cPipe,CodHTML(UPPER(cRFC)))
						CreaCadena(cPipe,nMonto)
						CreaCadena(cPipe,cMoeSat,,.T.)
						CreaCadena(cPipe,cTipCam,,.T.)
					EndIf
					
					cAtrbDet := AddSTR(aAtrbDet)
									
					cSubNodo := AddXML(cSNodo, 'PLZ:OtrMetodoPago', '#NomNodo#', .T.)
					cAtrbDet := AddXML(cSubNodo, cAtrbDet, '#cValAtrib#', .T.)
					cAtrbDet := cAtrbDet	
				EndIf
				
			EndIf
		EndIf	
	EndIf	
	
Return cAtrbDet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณValCodAgr       บAutor  ณLuis Samaniego      บ Data ณ  30/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValCodAgr(cCodAgr, cCuenta, lValNivel,cNivel)
Local lCodOK  := .F.
Local nPos    := 0

	If CWD->(MsSeek( xFilial("CWD") + (cCodAgr)))
		If !Empty(cNivel)
			lCodOK := .T.
		Else
			nPos := aScan( aErrores,{|x| cCuenta $ x} )
			If nPos == 0
				aAdd( aErrores, cCuenta + Space(5) + cCodAgr + Space(15) + STR0007 )
			EndIf	
		EndIf
	Else
		nPos := aScan( aErrores,{|x| cCuenta $ x} )
		If nPos == 0
			aAdd( aErrores, cCuenta + Space(5) + cCodAgr + Space(15) + STR0012 )
		EndIf
	EndIf
	
	If lValNivel .And. lCodOK 
		If Val(cNivel) > nNivelCta
			lCodOK := .F.
		EndIf
	EndIf
Return lCodOK

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณValCuenta      บAutor  ณLuis Samaniego      บ Data ณ  30/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValCuenta(cCuenta, lValNivel)
Local lCtaOK  := .F.
Local nPos    := 0

	If CT1->(MsSeek( xFilial("CT1") + cCuenta ))
		If Alltrim(CT1->CT1_CODAGR) != "NO APLICA"
			If !Empty(Alltrim(CT1->CT1_CODAGR))
				lCtaOK := ValCodAgr(CT1->CT1_CODAGR, CT1->CT1_CONTA, lValNivel,CT1->CT1_NIVEL)
			Else
				nPos := aScan( aErrores,{|x| cCuenta $ x} )
				If nPos == 0
					aAdd( aErrores, CT1->CT1_CONTA + Space(5) + Space(Len(CT1->CT1_CODAGR)) + Space(15) + STR0006 )
				EndIf
			EndIf
		EndIf
	Else
		nPos := aScan( aErrores,{|x| cCuenta $ x} )
		If nPos == 0
			aAdd( aErrores, cCuenta + Space(5) + Space(Len(CT1->CT1_CODAGR)) + Space(15) + STR0013 )
		EndIf
	EndIf
Return lCtaOK


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณAddXML          บAutor  ณLuis Samaniego      บ Data ณ  30/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AddXML(cNomAtrib, cValAtrib, cValRep, lOblig)
Local cNewValAtb := ""
	If Valtype(cValAtrib) == "N" 
		If lOblig .Or. (!lOblig .And. !EmpTy(AllTrim(Str(cValAtrib)))) .Or. (lAtribOpc)
			If cNomAtrib $ 'SaldoIni="#cValor#"|Debe="#cValor#"|Haber="#cValor#"|SaldoFin="#cValor#"|Monto="#cValor#"|TipCamb="#cValor#"|TipCamb="#cValor#"|MontoTotal="#cValor#"'
				cValAtrib := Transform(cValAtrib, cPict1)
			EndIf
			If Valtype(cValAtrib) == "N"
				IIf(Alltrim(Str(cValAtrib)) == "", cValAtrib := "0.00", "")
				cNewValAtb := Strtran(cNomAtrib, cValRep, AllTrim(Str(cValAtrib))) + Space(1) // Valor Atributos
			Else
				IIf(Alltrim(cValAtrib) == "", cValAtrib := "NA", "")
				cNewValAtb := Strtran(cNomAtrib, cValRep, AllTrim(cValAtrib)) + Space(1) // Valor Atributos      
			EndIf
		EndIf
	Else
		If lOblig .Or. (!lOblig .And. !EmpTy(AllTrim(cValAtrib))) .Or. (lAtribOpc)  
			IIf(Alltrim(cValAtrib) == "", cValAtrib := "NA", "")
			cNewValAtb := Strtran(cNomAtrib, cValRep, AllTrim(cValAtrib)) + Space(1) // Valor Atributos
		ElseIf cNomAtrib == 'Sello="#cValor#"' .And. lSeOpc .And. !lAtribOpc
			cNewValAtb := Strtran(cNomAtrib, cValRep, AllTrim(cValAtrib)) + Space(1) // Valor Atributos	
		EndIf
	EndIF 
Return cNewValAtb

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณAddSTR          บAutor  ณLuis Samaniego      บ Data ณ  30/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AddSTR(aDatos)
Local cCadena := ""
Local nLoop   := 0

  	For nLoop := 1 To Len(aDatos)
  		If Len(aDatos[nLoop]) > 0
	  		If Empty(cCadena)
	  			cCadena := AddXML(aDatos[nLoop][1], aDatos[nLoop][2], '#cValor#', aDatos[nLoop][3])
	  		Else
	  			cCadena += AddXML(aDatos[nLoop][1], aDatos[nLoop][2], '#cValor#', aDatos[nLoop][3])
	  		EndIf
	  	EndIf	
  	Next
Return cCadena

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณGrabaTexto      บAutor  ณLuis Samaniego      บ Data ณ  30/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrabaTexto(cArcXml, nHdle, lClose, lEncode)
Default lClose := .F.
Default lEncode := .T.
   
    If lEncode
		cArcXml := ENCODEUTF8(cArcXml)
	EndIf
	FWrite(nHdle, cArcXml)
	If lClose
		FClose (nHdle)
	EndIf
Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCreaArch        บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCrea archivo XML/TMP                                              บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CreaArch(cNomArch, cExt)
Local nHdle     := 0
Local cDrive    := ""
Local cNewFile  := cDir + cNomArch

	SplitPath(cNewFile,@cDrive,@cDir,@cNomArch,@cExt)
	cDir := cDrive + cDir
	Makedir(cDir)
	cNomArc := cDir + cNomArch + cExt   

	nHdle := FCreate (cNomArc,0)
	If nHdle == -1
		Aviso( OemToAnsi(STR0003), OemToAnsi(STR0011 + cNomArc), {STR0005} )
	EndIf
Return nHdle

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ ImprimeLog  ณ Autor ณLuis Samaniego      ณ Data ณ 15/01/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Ejecuta rutina para Visualizar/Imprimir log del proceso.   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ																	 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Static Function ImprimeLog(cLeyenda,aLog, aTitLog)
Local aReturn		:= {"xxxx", 1, "yyy", 2, 2, 1, "",1 }	//"Zebrado"###"Administrao"
Local aNewLog		:= aClone(aLog)
Local cTamanho		:= "M"
Local cTitulo		:= cLeyenda

aLog := {}
IF !Empty( aNewLog )
	aAdd( aLog , aClone( aNewLog ) )
EndIF


/*1 -	aLogFile 	//Array que contem os Detalhes de Ocorrencia de Log
  2 -	aLogTitle	//Array que contem os Titulos de Acordo com as Ocorrencias
  3 -	cPerg		//Pergunte a Ser Listado
  4 -	lShowLog	//Se Havera "Display" de Tela
  5 -	cLogName	//Nome Alternativo do Log
  6 -	cTitulo		//Titulo Alternativo do Log
  7 -	cTamanho	//Tamanho Vertical do Relatorio de Log ("P","M","G")
  8 -	cLandPort	//Orientacao do Relatorio ("P" Retrato ou "L" Paisagem )
  9 -	aRet		//Array com a Mesma Estrutura do aReturn
  10-	lAddOldLog	//Se deve Manter ( Adicionar ) no Novo Log o Log Anterior */

MsAguarde( { ||fMakeLog( aLog , aTitLog , , .T. , FunName() , cTitulo , cTamanho , "P" , aReturn, .F. )}, STR0017)
Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณGetDirCWD       บAutor  ณLuis Samaniego      บ Data ณ  25/08/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GetDirCWD()
Local lRuta := .F.
Local cRuta := ""

	cRuta := cGetFile( '|(*.*)|' , 'Seleccione Diret๓rio', 0 , "C:\", .F., GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_RETDIRECTORY  )
	
	If !Empty(cRuta)
		MV_PAR05 := cRuta
		lRuta := .T.
	EndIf
Return lRuta

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณObtMonedaSat    บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณObtener codigo de moneda SAT                                      บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtMonedaSat(cMoneda, lPoliza)
Local cMoeSat := ""
Local nPos := 0 

	If CTO->(MsSeek( xFilial("CTO") + cMoneda ))
		cMoeSat := Alltrim(CTO->CTO_MOESAT)
	EndIf  
	
	nPos := aScan( aErrPlz,{|x| CTO->CTO_MOEDA $ x} )
	If Empty(cMoeSat) .And. nPos == 0
		aAdd(aErrPlz, STR0025 + Space(10 - Len(STR0025)) + Alltrim(CTO->CTO_MOEDA) + Space(5 - Len(Alltrim(CTO->CTO_MOEDA))) + Alltrim(CTO->CTO_DESC) + Space(17 - Len(Alltrim(CTO->CTO_DESC))) + STR0019)	
	EndIf
	If Empty(cMoeSat)
		lPoliza := .F.
	EndIf
Return cMoeSat

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณObtBancoSAT     บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณObtener codigo de banco SAT                                       บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtBancoSAT(cBanco, lPoliza, cBancoEx)
Local cBcoSat := ""	
Local nPos := 0
Default cBancoEx := ""

	If SA6->(MsSeek( xFilial("SA6") + cBanco))
		cBcoSat := SA6->A6_BCOSAT
		If Alltrim(SA6->A6_EST) == "EX"
			cBancoEx := SA6->A6_NOME
		EndIf
	EndIf	
	
	nPos := aScan( aErrPlz,{|x| SA6->A6_COD $ x} )
	If Empty(cBcoSat) .And. nPos == 0
		aAdd(aErrPlz, STR0023 + Space(10 - Len(STR0023)) + Alltrim(SA6->A6_COD) + Space(5 - Len(Alltrim(SA6->A6_COD))) + Alltrim(SA6->A6_NOME) + Space(17 - Len(Alltrim(SA6->A6_NOME))) + STR0020)	
	EndIf	
	If Empty(cBcoSat)
		lPoliza := .F.
	EndIf
Return cBcoSat 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณObtRFC          บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณObtener RFC Cliente/Proveedor                                     บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtRFC(cCliFor, cLoja, cTipo, cRFC, cBenef)

	If cTipo $ "1" //Cliente
		If SA1->(MsSeek( xFilial("SA1") + cCliFor + cLoja))
			cRFC := SA1->A1_CGC
			cBenef := SA1->A1_NOME
			If AI0->(FieldPos("AI0_BCOPAG"))>0 .And. AI0->(FieldPos("AI0_CTAPAG"))>0
				If AI0->(MsSeek( xFilial("AI0") + cCliFor + cLoja))
					cBcoPago := AI0->AI0_BCOPAG
					cCtaPago := AI0->AI0_CTAPAG
				EndIf
			EndIf
		EndIf
	EndIf
	If cTipo $ "2" //Proveedor
		SA2->(DBSetOrder(RETORDEM("SA2","A2_FILIAL+A2_COD+A2_LOJA")))
		If SA2->(MsSeek( xFilial("SA2") + cCliFor + cLoja))
			cRFC := SA2->A2_CGC
			cBenef := SA2->A2_NOME 	
			If SA2->(FieldPos("A2_BCOPAGO"))>0 .And. SA2->(FieldPos("A2_CTAPAGO"))>0
				cBcoPago := SA2->A2_BCOPAGO
				cCtaPago := SA2->A2_CTAPAGO
			EndIf
		EndIf
	EndIf 
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณObtConcepto     บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณObtener informacion de concepto                                   บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtConcepto(cConcepto, cLote, cSBLote, cDoc, cFecha)//nRecNo
Local lSalir := .F.	

	If (cTempCT2)->(DbSeek(xFilial("CT2") + cLote + cSbLote + cDoc + cFecha))
		While !(cTempCT2)->(Eof()) .And. (cTempCT2)->(CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_DATA) == (cLote + cSBLote + cDoc + cFecha) .And. !lSalir
			If (cTempCT2)->CT2_DC = '4'
				cConcepto += (cTempCT2)->CT2_HIST
				lSalir := .T.	
			EndIf
			(cTempCT2)->(dbSkip())
		EndDo
	EndIf
	cConcepto := Substr(cConcepto, 1, 299)
Return cConcepto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณDelAreaTrab     บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณElimina tablas temporales                                         บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function  DelAreaTrab()
Local nI := 0

	For nI := 1 To Len(aTmpArea)
		(aTmpArea[nI])->(dbCloseArea())
	Next
	aTmpArea := {}
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณVldTipEnv       บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida parametros                                                 บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldTipEnv()
Local lr      := .T.
	If (MV_PAR06 == 2 .Or. MV_PAR06 == 5) .And. MV_PAR07 == 2
		If Empty(MV_PAR08)
			Aviso( OemToAnsi(STR0003), OemToAnsi(STR0027), {STR0005} )
			lr := .F.
		EndIf
	EndIf
	If (MV_PAR06 == 3 .Or. MV_PAR06 == 4 .Or. MV_PAR06 == 5) .And. (MV_PAR09 == 1 .Or. MV_PAR09 == 2)
		If Empty(MV_PAR10) .or. AllTrim(MV_PAR10) == "/"
			Aviso( OemToAnsi(STR0003), OemToAnsi(STR0029), {STR0005} )
			lr := .F.
		ElseIf Len(AllTrim(MV_PAR10)) < 13
			Aviso( OemToAnsi(STR0003), OemToAnsi(STR0035), {STR0005} )
			lr := .F.
		EndIf
	EndIf
	If (MV_PAR06 == 3 .Or. MV_PAR06 == 4 .Or. MV_PAR06 == 5) .And. (MV_PAR09 == 3 .Or. MV_PAR09 == 4)
		If Empty(MV_PAR11)
			Aviso( OemToAnsi(STR0003), OemToAnsi(STR0030), {STR0005} )
			lr := .F.
		ElseIf Len(AllTrim(MV_PAR11)) < 10
			Aviso( OemToAnsi(STR0003), OemToAnsi(STR0036), {STR0005} )
			lr := .F.
		EndIf
	EndIf
Return lr 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCodHTML         บAutor  ณLuis Samaniego      บ Data ณ  30/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function CodHTML(cTexto, lCodHtml)
Local cRet   := ""                    
Local nChar	 :=	0
Default lCodHtml := .F.

	If !Empty(cTexto)
		// SUPRIMO DOBLES ESPACIOS EN BLANCO CONTENIDOS EN LA CADENA DE TEXTO
		For nChar=1 to Len(cTexto)     
			If nChar<Len(cTexto)
				If Substr(cTexto,nChar,1)==" " .and. Substr(cTexto,nChar,1)==Substr(cTexto,nChar+1,1)
					Loop
				Else
					cRet:=cRet+Substr(cTexto,nChar,1)
				Endif
			Else
				cRet:=cRet+Substr(cTexto,nChar,1)	      
			Endif
		Next
		cRet := Alltrim(cRet)
	Endif
	
	If lCodHtml
		cRet := Replace(cRet, '&', '&amp;')
		cRet := Replace(cRet, "‘", '&apos;')
		cRet := Replace(cRet, '"', '&quot;')
		cRet := Replace(cRet, '<', '&lt;')
		cRet := Replace(cRet, '>', '&gt;')
	EndIf
	
Return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCreaCadena      บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCrea cadena original                                              บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CreaCadena(cCaracter,cDato,lFin,lOpc)
Default lFin := .F.
Default lOpc := .F.

	If lOpc .And. !lAtribOpc .And. Empty(cDato)
		Return
	ElseIf lOpc .and. Empty(cDato) .and. lAtribOpc
		cDato := "NA"
	EndIf
	
	If !lFin
		cCadenaOr += cCaracter + AllTrim(IIF(ValType(cDato)== "N",TRANSFORM(cDato, cPict1),cDato))
	Else
		cCadenaOr += cCaracter
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณLeeCert         บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณObtiene el certificado                                            บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LeeCert()

	Local cBuffer	:= ""
	Local nHandle
	Local lRet      := .F.
	Local cLinea    := ""
	Local cTipo	:= ""
	Local cFile := &(SuperGetMv("MV_CFDDIRS",,""))+SuperGetMv("MV_CFDI_CP",,"")

	nHandle := FT_FUse(cFile)
// Se hay error al abrir el archivo
	If  nHandle = -1
		MsgAlert(STR0028 + cFile)  //"El archivo" padron "no puede abrirse."
	return ""
	Endif
	// Se posiciona en la primera lํnea
	FT_FGoTop()
	
	
	While !FT_FEOF()
	
		nRecno 	:= FT_FRecno()
		cLinea := FT_FReadLn() // lee cada lํnea del archivo
		If Alltrim(cLinea) <> "-----BEGIN CERTIFICATE-----" .And. Alltrim(cLinea) <> "-----END CERTIFICATE-----"
			cBuffer += Alltrim(cLinea)
		EndIf
		FT_FSKIP() // Salta a siguiente lํnea

	End
	
		
// Fecha o Arquivo
	FT_FUSE()
		
Return cBuffer

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณObtDescCta      บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณObtene descripcion de cuenta contable                             บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtDescCta(cCuenta)
Local cDesc := ""
	If CT1->(MsSeek( xFilial("CT1") + cCuenta))
		cDesc := CT1->(CT1_DESC01 + CT1_DESC02 + CT1_DESC03 + CT1_DESC04)
	EndIf
Return cDesc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณVldNacional     บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida nacionalidad de proveedor                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldNacional(cRFC)
Local lNac := .T.

	SA2->(DBSetOrder(RETORDEM("SA2","A2_FILIAL+A2_CGC")))
	If SA2->(MsSeek( xFilial("SA2") + Alltrim(cRFC)))
		If Alltrim(SA2->A2_EST) == "EX"
			lNac := .F.
		EndIf
	EndIf
	
Return lNac

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณObtMetPago      บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณObtiene el metodo de pago                                         บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtMetPago(cTipo)
Local cMetodo := ""
Local cTabla  := SuperGetMV("MV_CTBMPAG",.T.,'')
Local lOK     := .F.

	If SX5->(MsSeek( xFilial("SX5") + cTabla))
		Do While SX5->X5_TABELA == cTabla .And. !lOK	
			If SubStr(Alltrim(SX5->X5_DESCRI), 1 , 2) == cTipo
				cMetodo := SX5->X5_CHAVE
				lOK := .T.
			EndIf
			SX5->(dbSkip())
		EndDo
	EndIf
Return cMetodo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณObtNomina       บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณObtener folios fiscales de nomina                                 บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ObtNomina(cPerIni, cPerFin)
	Local cQuery := ""
		
	Private cAlias    := CriaTrab(Nil, .F.)

	If Len(aBrowse) == 0 .or. IIf(Len(aBrowse)<> 0 .and. (aBrowse[1][8] <> cPerIni .Or. aBrowse[1][8] <> cPerFin),.T., .F.)
	
		aBrowse = {}
		cQuery := " SELECT"
		cQuery += " RCH_PER, RCH_PROCES, RCH_ROTEIR, RCH_NUMPAG, RCH_FILIAL"
		cQuery += " FROM " + RetSQLName("RCH") 
		cQuery += " WHERE RCH_PER BETWEEN " + cPerIni + " AND " + cPerFin
		cQuery += " AND D_E_L_E_T_ = ''"
		cQuery += " ORDER BY RCH_PER, RCH_PROCES, RCH_NUMPAG"
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.) 
		
		(cAlias)->(dbGoTop())
		While !(cAlias)->(EOF())
			AADD(aBrowse,{(cAlias)->RCH_FILIAL,(cAlias)->RCH_PROCES,(cAlias)->RCH_ROTEIR,(cAlias)->RCH_NUMPAG,"      ","   ","      ",(cAlias)->RCH_PER,"" })
			(cAlias)->(dbskip())
		Enddo
	EndIf
	
   	If Len(aBrowse)<> 0       
   		 
   		getCampos()      
	    DEFINE DIALOG oDlg TITLE cPerIni + " - " + cPerFin FROM 180,180 TO 500,760 PIXEL
	    oBrowse := TCBrowse():New( 01 , 01, 350, 136,,;
	                              {'Filial',aCampos[1],aCampos[2],aCampos[3],aCampos[4],aCampos[5],aCampos[6]},{30,30,30,30,30,30,30},;
	                              oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	                                                       
	    oBrowse:SetArray(aBrowse) 
	    
	    oBrowse:AddColumn( TCColumn():New('Filial',{ || aBrowse[oBrowse:nAt,1] },,,,"LEFT",,.F.,.T.,,,,.F.,) ) 
	    oBrowse:AddColumn( TCColumn():New(aCampos[1],{ || aBrowse[oBrowse:nAt,2] },,,,"LEFT",,.F.,.T.,,,,.F.,) ) 
	    oBrowse:AddColumn( TCColumn():New(aCampos[2]  ,{ || aBrowse[oBrowse:nAt,3] },,,,"LEFT",,.F.,.T.,,,,.F.,) ) 
	    oBrowse:AddColumn( TCColumn():New(aCampos[3] ,{ || aBrowse[oBrowse:nAt,4] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	    oBrowse:AddColumn( TCColumn():New(aCampos[4],{ || aBrowse[oBrowse:nAt,5] },,,,"LEFT",,.F.,.T.,,,,.F.,) ) 
	    oBrowse:AddColumn( TCColumn():New(aCampos[5]  ,{ || aBrowse[oBrowse:nAt,6] },,,,"LEFT",,.F.,.T.,,,,.F.,) ) 
	    oBrowse:AddColumn( TCColumn():New(aCampos[6] ,{ || aBrowse[oBrowse:nAt,7] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	
	   
	    oBrowse:bLDblClick   := {|z,x| Iif(oBrowse:ColPos == 7 .or. oBrowse:ColPos == 5 .or. oBrowse:ColPos == 6 ,(nFila := oBrowse:NROWPOS, lEditCell(@aBrowse,oBrowse,'@!',oBrowse:ColPos)),Alert("No permitido")) }                                
	    
	    oBrowse:bValid		:= {||vldLn(Len(aBrowse))}
	    TSay():New(142,01,{||'Ingresar: Lote, Sublote y N๚mero de P๓liza, para las n๓minas'},oDlg,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	    TSay():New(152,01,{||'a considerar en el reporte de Folios Fiscales'},oDlg,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
        TButton():New( 142, 192, "Cancelar", oDlg,{|| aBrowse := {},oDlg:End(), MV_PAR12 := 1 },40,010,,,.F.,.T.,.F.,,.F.,,,.F.)
	    TButton():New( 142, 242, 'Confirmar', oDlg,{|| oDlg:End() },40, 010,,,.F.,.T.,.F.,,.F.,,,.F. )
	  ACTIVATE DIALOG oDlg CENTERED 
  Else
  		Alert(OemToAnsi(STR0031))
  EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณvldLn           บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida informacion de poliza de nomina                            บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static Function vldLn(nLinea)
	Local lRet := .F.
	Local nI := 0
	Local cMsg := OemToAnsi(STR0032)
	
	IF !Empty(aBrowse)
		For nI := 1 to nLinea
			If (Empty(aBrowse[nI][7]) .and. Empty(aBrowse[nI][5]) .and. Empty(aBrowse[nI][6])) .or. (!Empty(aBrowse[nI][7]) .and. !Empty(aBrowse[nI][5]) .and. !Empty(aBrowse[nI][6]))
				lRet := .T.
			Else
				cMsg += STR(nI)
				Alert(cMsg)
				Return .F.		
			EndIf
		Next 
	Else
		lRet := .T.
	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCTBA602XF       บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCrea archivo XML de Auxiliar de Folios Fiscales                   บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTBA602XF()
Local aAtrbXml         := {} //Atributos Xml
Local aAtrbAuxF        := {} //Atributos Nodo 
Local aPlzCta          := {}
Local aAtrbCmp         := {}
Local aFoliosFis		  := {}


Local lPoliza     := .F.
Local lCtaSAT     := .F.
//Local lCompNac    := .F.

Local cNomArch    := cRFCE + cAno + cMes + "XF.xml"
Local cAtrbXml    := "" //Atributos Xml
Local cAtrbAuxF    := "" //Atributos Nodo <Poliza>
Local cMoneda     := ""
Local cQuery      := ""
Local cNodoPlz    := ""
Local cNomArchTmp   := cRFCE + cAno + cMes + "XF.tmp"
Local cAtrbCEx   := ""
//Local cAtrbCmp   := ""

Local cSchemaLoc  := "http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/AuxiliarFolios http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/AuxiliarFolios/AuxiliarFolios_1_3.xsd"
Local cXmlnsXsi   := "http://www.w3.org/2001/XMLSchema-instance"
Local cXmlnsXF    := "http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/AuxiliarFolios"

Local nPos        := 0 
Local nPosU		:= 0

Private cNumUnIdenPol := ""
Private cAlias    := CriaTrab(Nil, .F.)
Private cAliasRN  := ""
Private cXMLAuxF   := cXML
Private cMoeSat    := ""
Private cTipCam    := ""
Private nArchXML    := 0
Private nArchTmp    := 0
	
	cAtrbCmp    := ""
	lCompNac    := .F.
	
	cCadenaOr := ""
	cQuery := " SELECT * "
	cQuery += " FROM " + RetSQLName("CT2") 
	cQuery += " WHERE CT2_DATA BETWEEN '" + DTOS(dIni) + "' AND '" + DTOS(dFim) + "' AND "
	cQuery += " CT2_FILIAL = '" + xFilial("CT2") + "' AND" 
	cQuery += " CT2_DC <> '4' AND"
	cQuery += " CT2_TPSALD IN (" + cTipSaldo + ")" 
	cQuery += " AND D_E_L_E_T_ = ''"
	cQuery += " ORDER BY CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_EMPORI, CT2_FILORI, CT2_MOEDLC, CT2_SEQIDX ASC"//" ORDER BY CT2_SEQUEN	ASC"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.) 
	
	aAdd ( aTmpArea , cAlias )
	
	(cAlias)->(dbGoTop())
	If !(cAlias)->(EOF())
		
		nArchXML := CreaArch(cNomArch, cExtXML)
		If lSeOpc
			nArchTmp := CreaArch(cNomArchTmp, cExtTMP) 
		EndIf
		If nArchXML == -1 .Or. nArchTmp == -1  
			Return
		EndIf
		
		aAtrbXml := {{'Version="#cValor#"', aVersion[1][4], .T.},;
				{'RFC="#cValor#"', cRfcHtml, .T.},;
				{'Mes="#cValor#"', cMes, .T.},;
				{'Anio="#cValor#"', cAno, .T.},;
				{'TipoSolicitud="#cValor#"', cTipoSolicitud, .T.},;
				{'xsi:schemaLocation="#cValor#"', cSchemaLoc, .T.},;
				{'xmlns:xsi="#cValor#"', cXmlnsXsi, .T.},;
				{'xmlns:RepAux="#cValor#"', cXmlnsXF, .T.}}
	  	
		IF !Empty(cNumOrden) .and. AllTrim(cNumOrden) <> "/"
			AADD(aAtrbXml,{'NumOrden="#cValor#"', CodHTML(cNumOrden, .T.), .F.})
		EndIf
		
		IF !Empty(cNumTramite)
			AADD(aAtrbXml,{'NumTramite="#cValor#"', CodHTML(cNumTramite, .T.), .F.})
		EndIf
		
		If lSeOpc 
			AADD(aAtrbXml,{'Sello="#cValor#"', '', .F.})
			AADD(aAtrbXml,{'noCertificado="#cValor#"', cNoCert, .F.})
			AADD(aAtrbXml,{'Certificado="#cValor#"', cCertif, .F.})	
		
			CreaCadena(cPipe+cPipe,aVersion[1][4])
			CreaCadena(cPipe,cRFCE)
			CreaCadena(cPipe,cMes)
			CreaCadena(cPipe,cAno)
			CreaCadena(cPipe,cTipoSolicitud)
			IF !Empty(cNumOrden) .and. AllTrim(cNumOrden) <> "/"
				CreaCadena(cPipe,CodHTML(cNumOrden),,.T.)
			EndIf
			IF !Empty(cNumTramite)
				CreaCadena(cPipe,CodHTML(cNumTramite),,.T.)
			EndIf
			GrabaTexto(cCadenaOr, nArchTmp, , .F.)
			cCadenaOr := ""
		EndIf
		
		cAtrbXml := AddSTR(aAtrbXml)
		cNodoSup := AddXML(cNodo, 'RepAux:RepAuxFol', '#NomNodo#', .T.)
		cAtrbXml := AddXML(cNodoSup, cAtrbXml, '#cValAtrib#', .T.)
		cXMLAuxF += Space(4) + cAtrbXml
		
		GrabaTexto(cXMLAuxF, nArchXML) 
		cXMLAuxF := ""
		
		
		ProcRegua((cAlias)->(RecCount()))
		While !(cAlias)->(Eof())
			IncProc(STR0033)	
			
			If!Empty(Alltrim((cAlias)->CT2_DEBITO))
				lCtaSAT := ValCuenta((cAlias)->CT2_DEBITO, .F.)
			EndIf       
			If !Empty(Alltrim((cAlias)->CT2_CREDIT))
				lCtaSAT := ValCuenta((cAlias)->CT2_CREDIT, .F.)	
			EndIf
			
			If lCtaSAT
			
				nPos := aScan( aPlzCta,{|x| x == (cAlias)->CT2_LOTE + (cAlias)->CT2_SBLOTE + (cAlias)->CT2_DOC + (cAlias)->CT2_DATA} ) // + (cAlias)->CT2_SEQUEN
				
				If 	npos == 0	
					cNumUnIdenPol := AllTrim((cAlias)->(CT2_LOTE + CT2_SBLOTE + CT2_DOC))
					
					// NombreAtributo, ValorAtributo, Obligatorio?
					aAtrbAuxF := {{'NumUnIdenPol="#cValor#"', cNumUnIdenPol , .T.},; 
								{'Fecha="#cValor#"', formatoFecha((cAlias)->CT2_DATA), .T.}}
					
					cAtrbAuxF := AddSTR(aAtrbAuxF)			
					cMoneda := (cAlias)->CT2_MOEDLC 			
					
					If !Empty(cNumUnIdenPol)
						lPoliza  := .T.
					EndIf
				
			       cRFC := (cAlias)->CT2_RFC 
					lCompNac := VldNacional((cAlias)->CT2_RFC)
					
					If (cMoneda == (cAlias)->CT2_MOEDLC) 
						If !Empty((cAlias)->CT2_UUID) .And.  !Empty(Str((cAlias)->CT2_VALOR)) .And. !Empty((cAlias)->CT2_RFC) .And. lCompNac
							nPosU := aScan( aFoliosFis,{|x| x == (cAlias)->CT2_UUID + cNumUnIdenPol} ) 
					
							If 	nPosU == 0	
								CTBDetalle(@lPoliza, .T.)
								If (Empty(cAtrbCmp) .And. !Empty((cAlias)->CT2_RFC) .And. !Empty((cAlias)->CT2_UUID))
									Comprobante((cAlias)->CT2_UUID, (cAlias)->CT2_VALOR, .T.)
								EndIf
							EndIf
						Else
							cAtrbCEx := CTBDetalle(@lPoliza, .T.) 
						EndIf
					EndIf
				EndIf
				If (!Empty(cAtrbCmp) .Or. !Empty(cAtrbCEx)) 
					aAdd (aPlzCta, (cAlias)->CT2_LOTE + (cAlias)->CT2_SBLOTE + (cAlias)->CT2_DOC + (cAlias)->CT2_DATA) // + (cAlias)->CT2_SEQUEN
					cNodoSup := AddXML(cNodo, 'RepAux:DetAuxFol', '#NomNodo#', .T.)
					cAtrbAuxF := AddXML(cNodoSup, cAtrbAuxF, '#cValAtrib#', .T.)
					cNodoPlz := Space(8) + cAtrbAuxF
				   	
				   	If !Empty(cAtrbCmp)
				   		cNodoPlz += Space (12) + cAtrbCmp
				   		AADD(aFoliosFis, (cAlias)->CT2_UUID + cNumUnIdenPol)
				   	EndIf
				   	If !Empty(cAtrbCEx)
				   		cNodoPlz += Space(12) + cAtrbCEx
				   	EndIf 
				   	
				   	cNodoPlz += Space(8) + AddXML(cFinNodo, 'RepAux:DetAuxFol', "#cFinNodo#", .T.) 
				   	GrabaTexto(cNodoPlz, nArchXML) 
					If lSeOpc
						GrabaTexto(cCadenaOr, nArchTmp, , .F.)
						cCadenaOr  := ""
					EndIF
				ElseIf Empty((cAlias)->CT2_UUID) .And. Empty((cAlias)->CT2_RFC)
					/*Folios Fiscales de Nomina*/
					VldFolRN()	 
				EndIf
				cNodoPlz   := ""
				cAtrbAuxF  := ""
				cAtrbCmp   := ""
				cAtrbCEx   := ""  
			EndIf
			(cAlias)->(dbSkip())
		EndDo		
		
		cXMLAuxF := Space(4) + AddXML(cFinNodo, 'RepAux:RepAuxFol', "#cFinNodo#", .T.)
		GrabaTexto(cXMLAuxF, nArchXML, .T.)
		
		If lSeOpc
			CreaCadena(cPipe+cPipe,"",.T.)
			cParam := cDir + " " + cNomArch + " " + cNomArchTmp + " " + cCFDiPri + " " + cCFDiCve
			GrabaTexto(cCadenaOr, nArchTmp, .T., .F.)
			nOpc := WAITRUN( cRutaSmr + cRutinaVB + Trim(cParam), 0 )	
		EndIf
		
	EndIf	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCTBA602XC       บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCrea archivo XML de Auxiliar de Cuentas                           บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CTBA602XC()
Local aSelFil      := { FWGETCODFILIAL } 
Local aAtrbXml     := {}
Local aNodoCta     := {}
Local aSetOfBook

Local oMeter
Local oText
Local oDlg

Local lImpAntLP    := IIf(Type("MV_PAR14") == "N", IIf(MV_PAR14 == 1, .T., .F.), .F.)
Local lVlrZerado   := lSldCero
Local lImpSint     := .T.
Local lRecDesp0    := .F.
Local lEnd   

Local dDataLP      := IIf(Type("MV_PAR15") == "D", MV_PAR15, CTOD("//"))
Local dDtZeraRD    := CTOD("//")

Local cNomArch     := cRFCE + cAno + cMes + "XC.xml"
Local cNomArchTmp   := cRFCE + cAno + cMes + "XC.tmp"
Local cXmlAuxC     := cXML
Local cNodoCta     := ""
Local cArqTmp	     := ""
Local cCtaIni      := PadR( , TamSx3("CT1_CONTA")[1], " ")
Local cCtaFin      := PadR( , TamSx3("CT1_CONTA")[1], "Z")
Local cMoneda      := "01"
Local cTipoSal     := "1"
Local cIniSeg      := PadR( , 20, " ")	//"                    "
Local cFinSeg      := PadR( , 20, "Z")	//"ZZZZZZZZZZZZZZZZZZZZ"
Local cFilSeg      := PadR( , 30, " ")	//"                              "
Local cFilUser     := ".T."
Local cRecDesp     := "         "
Local cMoedaDsc    := " "          

Local cSchemaLoc   := "http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/AuxiliarCtas http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/AuxiliarCtas/AuxiliarCtas_1_3.xsd"
Local cXmlnsXsi    := "http://www.w3.org/2001/XMLSchema-instance"
Local cXmlnsXC     := "http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/AuxiliarCtas"
Local cQuery       := ""
Local cAtrbXml    := ""
Local cDesCta      := "" 
Local nDivide      := 1

Private nArchXML     := 0
Private nArchTmp     := 0
Private cAliasXC  := ""

	cCadenaOr := ""
	aSetOfBook := CTBSetOf(" ")	//Obtiene matriz de configuraci๓n de Libros
                                  	
	CTGerPlan(oMeter, oText, oDlg, @lEnd, @cArqTmp,;
				dIni, dFim, "CT7", "", cCtaIni, cCtaFin, , , , , , ,cMoneda,;
				cTipoSal, aSetOfBook, " ", cIniSeg, cFinSeg, cFilSeg,;
				.F., .F. ,3, , lImpAntLP, dDataLP, nDivide, lVlrZerado, , , , , , , , , , , , , , lImpSint, cFilUser, lRecDesp0,;
				cRecDesp, dDtZeraRD, , , , , , , cMoedaDsc, , aSelFil) 
				
	If cArqTmp->(!EOF())
		
		nArchXML := CreaArch(cNomArch, cExtXML)
		If lSeOpc
			nArchTmp := CreaArch(cNomArchTmp, cExtTMP) 
		EndIf
		If nArchXML == -1 .Or. nArchTmp == -1  
			Return
		EndIf
			
		aAtrbXml := {{'Version="#cValor#"', aVersion[1][5], .T.},;
				{'RFC="#cValor#"', cRfcHtml, .T.},;
				{'Mes="#cValor#"', cMes, .T.},;
				{'Anio="#cValor#"', cAno, .T.},;
				{'TipoSolicitud="#cValor#"', cTipoSolicitud, .T.},;
				{'xsi:schemaLocation="#cValor#"', cSchemaLoc, .T.},;
				{'xmlns:xsi="#cValor#"', cXmlnsXsi, .T.},;
				{'xmlns:AuxiliarCtas="#cValor#"', cXmlnsXC, .T.}}
	  	
		
		IF !Empty(cNumOrden) .and. AllTrim(cNumOrden) <> "/"
			AADD(aAtrbXml,{'NumOrden="#cValor#"', CodHTML(cNumOrden, .T.), .F.})
		EndIf
		IF !Empty(cNumTramite)
			AADD(aAtrbXml,{'NumTramite="#cValor#"', CodHTML(cNumTramite, .T.), .F.})
		EndIf
		
		If lSeOpc 
			AADD(aAtrbXml,{'Sello="#cValor#"', '', .F.})
			AADD(aAtrbXml,{'noCertificado="#cValor#"', cNoCert, .F.})
			AADD(aAtrbXml,{'Certificado="#cValor#"', cCertif, .F.})
		
			CreaCadena(cPipe+cPipe,aVersion[1][5])
			CreaCadena(cPipe,cRFCE)
			CreaCadena(cPipe,cMes)
			CreaCadena(cPipe,cAno)
			CreaCadena(cPipe,cTipoSolicitud)
			IF !Empty(cNumOrden) .and. AllTrim(cNumOrden) <> "/"
				CreaCadena(cPipe,CodHTML(cNumOrden),,.T.)
			EndIf
			IF !Empty(cNumTramite)
				CreaCadena(cPipe,CodHTML(cNumTramite),,.T.)
			EndIf
			
			GrabaTexto(cCadenaOr, nArchTmp, , .F.)
			cCadenaOr := ""
		EndIf
		
		cAtrbXml := AddSTR(aAtrbXml)
		cNodoSup := AddXML(cNodo, 'AuxiliarCtas:AuxiliarCtas', '#NomNodo#', .T.)
		cAtrbXml := AddXML(cNodoSup, cAtrbXml, '#cValAtrib#', .T.)
	  	cXmlAuxC += cAtrbXml
	  	
	  	GrabaTexto(cXmlAuxC, nArchXML) 
		
		cXmlAuxC := ""
	  	
	  	ProcRegua(cArqTmp->(RecCount()))
	  	cArqTmp->(DBGoTop())
	  	While cArqTmp->(!EOF())
	  		IncProc(STR0034)
	  		
	  		If ValCuenta(cArqTmp->CONTA, .F.)
	  		
	  			cAliasXC  := CriaTrab(Nil, .F.)
	  			cDesCta := ObtDescCta(cArqTmp->CONTA)
		  		
		  		DelAreaTrab()
		  		
				// NombreAtributo, ValorAtributo, Obligatorio?
				aNodoCta:={{'NumCta="#cValor#"', cArqTmp->CONTA, .T.},;
					{'DesCta="#cValor#"', CodHTML(cDesCta, .T.), .T.},;
					{'SaldoIni="#cValor#"', cArqTmp->SALDOANT, .T.},;
					{'SaldoFin="#cValor#"', cArqTmp->SALDOATU, .T.}}
					
				cQuery := " SELECT * "
				cQuery += " FROM " + RetSQLName("CT2") 
				cQuery += " WHERE CT2_DATA BETWEEN '" + DTOS(dIni) + "' AND '" + DTOS(dFim) + "' AND "
				cQuery += " CT2_FILIAL = '" + xFilial("CT2") + "' AND" 
				cQuery += " CT2_DC <> '4' AND"
				cQuery += " CT2_TPSALD IN (" + cTipSaldo + ") AND"
				cQuery += " (CT2_DEBITO = '" + Alltrim(cArqTmp->CONTA) + "' OR"
				cQuery += " CT2_CREDIT = '" + Alltrim(cArqTmp->CONTA) + "') AND"
				cQuery += " CT2_MOEDLC = '01' AND"
				cQuery += " D_E_L_E_T_ = ''"
				cQuery += " ORDER BY R_E_C_N_O_	ASC" 
				
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasXC,.F.,.T.) 
				
				aAdd ( aTmpArea , cAliasXC )
				
				(cAliasXC)->(dbGoTop())
				If !(cAliasXC)->(EOF()) 
					
					cNodoCta := AddSTR(aNodoCta)
					cNodoSup := AddXML(cNodo, 'AuxiliarCtas:Cuenta', '#NomNodo#', .T.)
					cNodoCta := AddXML(cNodoSup, cNodoCta, '#cValAtrib#', .T.)  
					cNodoCta := Space(4) + cNodoCta  
					
					If lSeOpc
						CreaCadena(cPipe,cArqTmp->CONTA) 
						CreaCadena(cPipe,CodHTML(cDesCta))
						CreaCadena(cPipe,cArqTmp->SALDOANT)
						CreaCadena(cPipe,cArqTmp->SALDOATU)
						GrabaTexto(cCadenaOr, nArchTmp, , .F.)
						cCadenaOr := "" 
					EndIf
					
					GrabaTexto(cNodoCta, nArchXML) 
					cNodoCta := "" 
					
					While !(cAliasXC)->(Eof())
						nVlrDebe := 0
						nVlrHaber := 0
													
						If !Empty(Alltrim((cAliasXC)->CT2_DEBITO))
							ObtNodoTrans("D")
						EndIf
						If !Empty(Alltrim((cAliasXC)->CT2_CREDIT))
							ObtNodoTrans("C")
						EndIf 
						
						(cAliasXC)->(dbSkip())
					EndDo
					
					cNodoCta := Space(4) + AddXML(cFinNodo, 'AuxiliarCtas:Cuenta', "#cFinNodo#", .T.)
					GrabaTexto(cNodoCta, nArchXML)
					If lSeOpc
						GrabaTexto(cCadenaOr, nArchTmp, , .F.)
						cCadenaOr := ""
					EndIf
					cNodoCta := ""   
					
				EndIf 
				
			EndIf
			cArqTmp->(dbSkip())
	  	EndDo
	  	
	  	cNodoCta := AddXML(cFinNodo, 'AuxiliarCtas:AuxiliarCtas', "#cFinNodo#", .T.)
		
		GrabaTexto(cNodoCta, nArchXML, .T.)
		If lSeOpc
			CreaCadena(cPipe+cPipe,"",.T.)
			GrabaTexto(cCadenaOr, nArchTmp, .T., .F.)
			cParam := cDir + " " + cNomArch + " " + cNomArchTmp + " " + cCFDiPri + " " + cCFDiCve
			nOpc := WAITRUN( cRutaSmr + cRutinaVB + Trim(cParam), 0 )
		EndIf
		
		aAdd ( aTmpArea , "cArqTmp" )
		
	EndIf 		

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณObtNodoTrans    บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCrea el nodo 'AuxiliarCtas:DetalleAux'                            บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtNodoTrans(cTipoMov)
Local aAtrbAuxC      := {} 
Local nVlrDebe       := 0
Local nVlrHaber      := 0   
Local cAtrbAuxC      := ""
Local cConcepto      := "" 
Local cNumUnIdenPol  := ""

	If cTipoMov == "D" 
		nVlrDebe := (cAliasXC)->CT2_VALOR 
	ElseIf cTipoMov == "C"
		nVlrHaber := (cAliasXC)->CT2_VALOR 
	EndIf
	
	cNumUnIdenPol := AllTrim((cAliasXC)->(CT2_LOTE + CT2_SBLOTE + CT2_DOC))		
	cConcepto := ObtConcepto((cAliasXC)->CT2_HIST, (cAliasXC)->CT2_LOTE, (cAliasXC)->CT2_SBLOTE, (cAliasXC)->CT2_DOC, (cAliasXC)->CT2_DATA) // (cAliasXC)->CT2_SEQUEN
	
	aAtrbAuxC := {{'NumUnIdenPol="#cValor#"', cNumUnIdenPol , .T.},; 
								{'Fecha="#cValor#"', formatoFecha((cAliasXC)->CT2_DATA), .T.},;
								{'Concepto="#cValor#"', CodHTML(cConcepto, .T.), .T.},;
								{'Debe="#cValor#"', nVlrDebe, .T.},;
								{'Haber="#cValor#"', nVlrHaber, .T.}}    
		
		If lSeOpc		
			CreaCadena(cPipe,formatoFecha((cAliasXC)->CT2_DATA))
			CreaCadena(cPipe,cNumUnIdenPol)
			CreaCadena(cPipe,nVlrDebe)
			CreaCadena(cPipe,nVlrHaber)
			GrabaTexto(cCadenaOr, nArchTmp, , .F.)
			cCadenaOr := ""
		EndIf
		
		cAtrbAuxC := AddSTR(aAtrbAuxC)
		cSubNodo := AddXML(cSNodo, 'AuxiliarCtas:DetalleAux', '#NomNodo#', .T.)
		cAtrbAuxC := AddXML(cSubNodo, cAtrbAuxC, '#cValAtrib#', .T.) 		
   		cAtrbAuxC := Space(8) + cAtrbAuxC
   				
   		GrabaTexto(cAtrbAuxC, nArchXML) 
		cAtrbAuxC := ""	
					
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณgetCampos       บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEstructura para ventana de parametros (Poliza de nomina)          บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function getCampos()
	If Len(aCampos) == 0
		AADD(aCampos,AllTrim(POSICIONE("SX3", 2, "RIW_PROCES" , "X3_TITSPA")))
		AADD(aCampos,AllTrim(POSICIONE("SX3", 2, "RIW_ROTEIR" , "X3_TITSPA")))
		AADD(aCampos,AllTrim(POSICIONE("SX3", 2, "RIW_NUMPAG" , "X3_TITSPA")))
		AADD(aCampos,AllTrim(POSICIONE("SX3", 2, "CT2_LOTE" , "X3_TITSPA")))
		AADD(aCampos,AllTrim(POSICIONE("SX3", 2, "CT2_SBLOTE" , "X3_TITSPA")))
		AADD(aCampos,AllTrim(POSICIONE("SX3", 2, "CT2_DOC" , "X3_TITSPA")))
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณformatoFecha    บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDa formato a atributos de tipo fecha                              บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function formatoFecha(cData,nOp)
Local cFechaF := ""
Default nOp = 0

	If ValType(cData) == "D"
		cData = DTOC(cData)
	EndIf

	If nOp == 0
		cFechaF = substr(cData,1,4) + "-" + substr(cData,5,2) + "-" + substr(cData,7)
	Else 
		cFechaF = substr(cData,7,4) + "-" + substr(cData,4,2) + "-" + substr(cData,1,2)
	EndIf

Return cFechaF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณComprobante     บAutor  ณLuis Samaniego      บ Data ณ  01/08/15   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณForma los nodo 'PLZ:CompNal' y 'RepAux:ComprNal'                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function Comprobante(cUUID,nValor,lRepAux)
Local aAtrbCmp   := {} //Atributos Nodo <Comprobante>

IIf(Empty(cMoeSat), cMoeSat := "MXN", "")
IIf(Empty(cTipCam), cTipCam := "1.00", "")
			
	// NombreAtributo, ValorAtributo, Obligatorio?
	aAtrbCmp := {{'UUID_CFDI="#cValor#"', cUUID , .T.},;
				{'RFC="#cValor#"', CodHTML(UPPER(cRFC), .T.) , .T.},;
				{'MontoTotal="#cValor#"', nValor , .F.},;
				{'Moneda="#cValor#"', cMoeSat, .T.},;
				{'TipCamb="#cValor#"', cTipCam, .F.}}
	
	If lSeOpc
		If lRepAux
			CreaCadena(cPipe,cNumUnIdenPol)
			CreaCadena(cPipe,formatoFecha((cAlias)->CT2_DATA))	
		EndIf		
		CreaCadena(cPipe,cUUID )
		If lRepAux
			//CreaCadena(cPipe,cUUID)
			CreaCadena(cPipe,CodHTML(UPPER(cRFC)))
			CreaCadena(cPipe,nValor)
			CreaCadena(cPipe,cMoeSat,,.T.) 
			CreaCadena(cPipe,cTipCam,,.T.)
		EndIf
	EndIf
	
	cAtrbCmp := AddSTR(aAtrbCmp)
	cSubNodo := AddXML(cSNodo, IIF(!lRepAux,'PLZ:CompNal','RepAux:ComprNal'), '#NomNodo#', .T.)
	cAtrbCmp := AddXML(cSubNodo, cAtrbCmp, '#cValAtrib#', .T.)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCreaTmpCT2      บAutor  ณLuis Samaniego      บ Data ณ  30/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CreaTmpCT2()
	
	Local cQuery      := ""
	Local aCposCT2    := {}
	Local aOrdem      := {}

	cQuery := " SELECT CT2_FILIAL, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_HIST, CT2_DATA, CT2_DC, CT2_TPSALD, R_E_C_N_O_"
	cQuery += " FROM " + RetSQLName("CT2") 
	cQuery += " WHERE CT2_DATA BETWEEN '" + DTOS(dIni) + "' AND '" + DTOS(dFim) + "' AND "
	cQuery += " CT2_FILIAL = '" + xFilial("CT2") + "' AND" 
	cQuery += " CT2_DC = '4' AND"
	cQuery += " CT2_MOEDLC = '01' AND" 
	cQuery += " CT2_TPSALD IN (" + cTipSaldo + ")"
	cQuery += " AND D_E_L_E_T_ = ''"
	cQuery += " ORDER BY R_E_C_N_O_	ASC"

	AADD(aCposCT2,{ "CT2_FILIAL",  "C", TamSX3("CT2_FILIAL")[1], TamSX3("CT2_FILIAL")[2] })
	AADD(aCposCT2,{ "CT2_LOTE",    "C", TamSX3("CT2_LOTE")[1],   TamSX3("CT2_LOTE")[2] })
	AADD(aCposCT2,{ "CT2_SBLOTE",  "C", TamSX3("CT2_SBLOTE")[1], TamSX3("CT2_SBLOTE")[2] })
	AADD(aCposCT2,{ "CT2_DOC",     "C", TamSX3("CT2_DOC")[1],    TamSX3("CT2_DOC")[2] })
	AADD(aCposCT2,{ "CT2_LINHA",  "C", TamSX3("CT2_LINHA")[1], TamSX3("CT2_LINHA")[2] })
	AADD(aCposCT2,{ "CT2_HIST",    "C", TamSX3("CT2_HIST")[1],   TamSX3("CT2_HIST")[2] })
	AADD(aCposCT2,{ "CT2_DATA",    "C", TamSX3("CT2_DATA")[1],   TamSX3("CT2_DATA")[2] })
	AADD(aCposCT2,{ "CT2_DC",      "C", TamSX3("CT2_DC")[1],     TamSX3("CT2_DC")[2] })
	AADD(aCposCT2,{ "CT2_TPSALD",  "C", TamSX3("CT2_TPSALD")[1], TamSX3("CT2_TPSALD")[2] })
	AADD(aCposCT2,{ "CT2_RECNO",   "N", 10, 0 })
	
	aOrdem := {"CT2_FILIAL","CT2_LOTE","CT2_SBLOTE","CT2_DOC","CT2_DATA","CT2_LINHA"}
	
	oTmpTable := FWTemporaryTable():New(cTempCT2)
	oTmpTable:SetFields(aCposCT2)
	oTmpTable:AddIndex("1", aOrdem)
	oTmpTable:Create()
	
	SqlToTrb(cQuery, aCposCT2, cTempCT2)
	
	DBSelectArea(cTempCT2)
	(cTempCT2)->(dbSetOrder(1)) //CT2_FILIAL+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_DATA+CT2_LINHA
	(cTempCT2)->(dbGoTop())
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณVldFolRN        บAutor  ณLuis Samaniego      บ Data ณ  30/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldFolRN(lXmlPlz, cAtrbTrn, cNodPlz, cCuenta)
Local aAtrbAuxF   := {} //Atributos Nodo 
Local aAtrbCmp    := {}

Local cAtrbAuxF   := "" //Atributos Nodo <Poliza>
Local cQuery      := ""
Local cNodoPlz    := ""

Local nI          := 0
Local nPos        := 0
Local lPlzNomina  := .F.

Default cAtrbTrn := ""
Default lXmlPlz  := .F.
Default cNodPlz  := ""
Default cCuenta := ""
	
	nPos := aScan( aPlzNom,{|x| x == (cAlias)->CT2_LOTE + (cAlias)->CT2_SBLOTE + (cAlias)->CT2_DOC + (cAlias)->CT2_DATA + Alltrim(cCuenta)} ) // + (cAlias)->CT2_SEQUEN 
	
	If lXmlPlz 
		nI   := aScan( aBrowse,{|x| Alltrim(x[5]) == Alltrim((cAlias)->CT2_LOTE) .And. Alltrim(x[6]) == Alltrim((cAlias)->CT2_SBLOTE) .And. x[7] == Alltrim((cAlias)->CT2_DOC) } ) 
	Else
		nI   := aScan( aBrowse,{|x| Alltrim(x[5]) == Alltrim((cAlias)->CT2_LOTE) .And. Alltrim(x[6]) == Alltrim((cAlias)->CT2_SBLOTE) .And. x[7] == Alltrim((cAlias)->CT2_DOC) .And. x[9] == "" } )
	EndIf	
		
	If nI > 0 .And. nPos == 0
		If !Empty(aBrowse[nI][5]) .And. !Empty(aBrowse[nI][6]) .And. !Empty(aBrowse[nI][7]) .And. (aBrowse[nI][9] != "Procesado" .Or. lXmlPlz)
			If (Alltrim(aBrowse[nI][5]) + Alltrim(aBrowse[nI][6]) + Alltrim(aBrowse[nI][7]) == Alltrim((cAlias)->CT2_LOTE) + Alltrim((cAlias)->CT2_SBLOTE) + Alltrim((cAlias)->CT2_DOC))
				
				aBrowse[nI][9] := "Procesado"
				aAdd(aPlzNom, (cAlias)->CT2_LOTE + (cAlias)->CT2_SBLOTE + (cAlias)->CT2_DOC + (cAlias)->CT2_DATA + Alltrim(cCuenta)) // + (cAlias)->CT2_SEQUEN		
				cAliasRN  := CriaTrab(Nil, .F.)
				
				cQuery := " SELECT * "
				cQuery += " FROM " + RetSQLName("RIW") 
				cQuery += " WHERE RIW_FILIAL = '" + xFilial("RIW") + "' AND"
				cQuery += " RIW_PROCES = '" + aBrowse[nI][2] + "' AND"
				cQuery += " RIW_ROTEIR = '" + aBrowse[nI][3] + "' AND"
				cQuery += " RIW_NUMPAG = '" + aBrowse[nI][4] + "' AND"
				cQuery += " RIW_PER = '" + aBrowse[nI][8] + "' AND"
				cQuery += " D_E_L_E_T_ = ''" 
				
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRN,.F.,.T.) 
				
				aAdd ( aTmpArea , cAliasRN )
				
				(cAliasRN)->(dbGoTop())
				If !(cAliasRN)->(EOF())
					
					If lXmlPlz
						cNodoSup := AddXML(cNodo, 'PLZ:Transaccion', '#NomNodo#', .T.)
					   	cAtrbTrn := AddXML(cNodoSup, cAtrbTrn, '#cValAtrib#', .T.)
					   	cNodoPlz := cNodPlz + Space(12) + cAtrbTrn
						GrabaTexto(cNodoPlz, nArchXML)
						lPlzNomina := .T.
						cAtrbTrn := ""
						cNodoPlz := ""
						cNodPlz  := ""
						
						If lSeOpc
							GrabaTexto(cCadenaOr, nArchTmp, , .F.)
							cCadenaOr  := ""
						EndIf
					Else
						cNumUnIdenPol := aBrowse[nI][5] + aBrowse[nI][6] + aBrowse[nI][7]
			
						// NombreAtributo, ValorAtributo, Obligatorio?
						aAtrbAuxF := {{'NumUnIdenPol="#cValor#"', cNumUnIdenPol , .T.},; 
									{'Fecha="#cValor#"', formatoFecha((cAlias)->CT2_DATA), .T.}}
						
						cAtrbAuxF := AddSTR(aAtrbAuxF)			
						cNodoSup := AddXML(cNodo, 'RepAux:DetAuxFol', '#NomNodo#', .T.)
						cAtrbAuxF := AddXML(cNodoSup, cAtrbAuxF, '#cValAtrib#', .T.)
						cNodoPlz := Space(8) + cAtrbAuxF
						  
						GrabaTexto(cNodoPlz, nArchXML)
						cNodoPlz   := "" 
						cCadenaOr  := ""
						cAtrbAuxF  := ""
						cAtrbCmp   := "" 
						
						If lSeOpc
							CreaCadena(cPipe,cNumUnIdenPol)
							CreaCadena(cPipe,formatoFecha((cAlias)->CT2_DATA))
							GrabaTexto(cCadenaOr, nArchTmp, , .F.)
							cCadenaOr  := ""		
						EndIf
					EndIf
					
					While !(cAliasRN)->(Eof())
							// NombreAtributo, ValorAtributo, Obligatorio?
							aAtrbCmp := {{'UUID_CFDI="#cValor#"', (cAliasRN)->RIW_UUID , .T.},;
										{'MontoTotal="#cValor#"', (cAliasRN)->RIW_VALOR , .T.},;
										{'RFC="#cValor#"', CodHTML(UPPER((cAliasRN)->RIW_RFC), .T.) , .T.},;
										{'Moneda="#cValor#"', "MXN", .F.},;
										{'TipCamb="#cValor#"', "1.00", .F.}}
										
							cAtrbCmp := AddSTR(aAtrbCmp)
							cSubNodo := AddXML(cSNodo, IIf(lXmlPlz, 'PLZ:CompNal','RepAux:ComprNal'), '#NomNodo#', .T.)
							cAtrbCmp := AddXML(cSubNodo, cAtrbCmp, '#cValAtrib#', .T.) 
							cNodoPlz := IIf(lXmlPlz,Space(16), Space (12)) + cAtrbCmp 
							
							If lSeOpc
								If lXmlPlz
									CreaCadena(cPipe,(cAliasRN)->RIW_UUID)
									GrabaTexto(cCadenaOr, nArchTmp, , .F.)
									cCadenaOr  := ""
								Else
									CreaCadena(cPipe,(cAliasRN)->RIW_UUID)
									CreaCadena(cPipe,CodHTML(UPPER((cAliasRN)->RIW_RFC)))
									CreaCadena(cPipe,(cAliasRN)->RIW_VALOR)
									CreaCadena(cPipe,"MXN",,.T.) 
									CreaCadena(cPipe,"1.00",,.T.)
									GrabaTexto(cCadenaOr, nArchTmp, , .F.)
									cCadenaOr  := ""
								EndIf
							EndIf
					   		
					   		GrabaTexto(cNodoPlz, nArchXML) 
					   		cNodoPlz   := ""
							cAtrbAuxF  := ""
							cAtrbCmp   := ""
							
						(cAliasRN)->(dbSkip())
					EndDo
					
					If lXmlPlz
						cNodoPlz := Space(12) + AddXML(cFinNodo, 'PLZ:Transaccion', "#cFinNodo#", .T.)
					Else
						cNodoPlz := Space(8) + AddXML(cFinNodo, 'RepAux:DetAuxFol', "#cFinNodo#", .T.) 
					EndIf
				   	GrabaTexto(cNodoPlz, nArchXML)
					If lSeOpc
						If !Empty(cCadenaOr)
							GrabaTexto(cCadenaOr, nArchTmp, , .F.)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf	
	EndIf
Return (lPlzNomina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณVldBcoSA6       บAutor  ณLuis Samaniego      บ Data ณ  27/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida que exista el banco en la tabla SA6                        บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VldBcoSA6()
Local cCampo := ReadVar()
Local lRet   := .F.
	If SA6->(MsSeek( xFilial("SA6") + Alltrim(&cCampo)))
		lRet := .T.
	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณVldCposSA1      บAutor  ณLuis Samaniego      บ Data ณ  27/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida que existan los campos A1_BCOPAGO y A1_CTAPAGO             บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldCposSA1()
Local lCpos := .F.
	If AI0->(FieldPos("AI0_BCOPAG"))>0 .And. AI0->(FieldPos("AI0_CTAPAG"))>0
		lCpos := .T.
	EndIf
Return lCpos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณVldCposSA2      บAutor  ณLuis Samaniego      บ Data ณ  27/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida que existan los campos A2_BCOPAGO y A2_CTAPAGO             บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldCposSA2()
Local lCpos := .F.
	If SA2->(FieldPos("A2_BCOPAGO"))>0 .Or. SA2->(FieldPos("A2_CTAPAGO"))>0
		lCpos := .T.
	EndIf
Return lCpos

Function VldCTGCal(cCalCTG)
Local lRet   := .F.
	DbSelectArea("CTG")
	CTG->(DbSetOrder(1))
	If CTG->(MsSeek( xFilial("CTG") + cCalCTG + MV_PAR01))
		lRet := .T.
	EndIf
Return lRet

Function VldCTGPer(cCalCTG, cPerCTG)
Local lRet   := .F.
	DbSelectArea("CTG")
	CTG->(DbSetOrder(1))
	If CTG->(MsSeek( xFilial("CTG") + cCalCTG + MV_PAR01 + cPerCTG))
		lRet := .T.
	EndIf
Return lRet

Static Function ObtFchPer(cPeriodo, lInicio)
Local dFecha := CTOD("")

	If CTG->(MsSeek(xFilial("CTG") + cCalend + cAno + cPeriodo))
		If lInicio
			dFecha := CTG->CTG_DTINI
		Else
			dFecha := CTG->CTG_DTFIM
		EndIf
	EndIf
Return dFecha