#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "GPER900.CH" 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                                                     
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER900   ºAutor  ³Cesa Bautista        ºFecha ³ 20/12/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Certificado de Compensación por tiempo                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PERU                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPER900()

Private cPerg   	:= "GPR900"
Private  cProcesso 	:= ""
Private cProcedi 	:= ""
Private cMes 	  	:= ""
Private cAno 	  	:= ""
Private cFilialDe 	:= ""
Private cMatDe		:= ""
Private cCeco       := "" 
Private cUnOr		:= "" 
Private cAliasX		:= GetNextAlias() 
Private cFiltro		:= ""  
Private cOrdem 		:= ""
Private cSemana		:= ""
Private cPeriodo     := ""
Private AVERBASCTS:={}
Private oReport		:= 	nil

If TRepInUse()
	Pergunte(cPerg,.t.)
	oReport := ReportDef()
 	oReport:PrintDialog()
EndIf

Return

Static Function ReportDef()


Local oSection1
Local oSection2
Local oSection3
Local oSection4

  
cProcedi	:= mv_par02
cMes 	  	:= Substr(mv_par03, 5, 2)
cAno 	  	:= Substr(mv_par03, 1, 4)
cPeriodo    := mv_par03
cSemana 	:= mv_par04
cFilialDe 	:= mv_par05
cCeco       := mv_par06
cMatDe		:= ALLTRIM(mv_par07)
cNome    	:= ALLTRIM(mv_par08)
cUnOr		:= mv_par09


	MakeSqlExpr("GPR900")
	If !Empty(mv_par01)
		cFiltro += If( !Empty(cFiltro), " AND " + MV_PAR01, MV_PAR01 )
	EndIf	
	If !Empty(mv_par05)
		cFiltro += If( !Empty(cFiltro), " AND " + MV_PAR05, MV_PAR05 )
	EndIf 
	If !Empty(mv_par06)
		cFiltro += If( !Empty(cFiltro), " AND " + MV_PAR06, MV_PAR06 )
	EndIf
	If !Empty(mv_par07)
		cFiltro += If( !Empty(cFiltro), " AND " + MV_PAR07, MV_PAR07 )
	EndIf 
   	If !Empty(mv_par09)
		cFiltro += If( !Empty(cFiltro), " AND " + MV_PAR09, MV_PAR09 )
	EndIf 
	
	cFiltro := If( !Empty(cFiltro), "% " + cFiltro + " AND %", "%%" )

oReport := TReport():New("GPER900","","GPR900",{|oReport| IMPGPER900()},"")

oSection1 := TRSection():New(oReport,"","")	                          
oSection2 := TRSection():New(oSection1,"", "") 

oSection3 := TRSection():New(oSection2, "") 
oSection4 := TRSection():New(oSection3, "") 
oSection5 := TRSection():New(oSection4, "") 

oSection1:PrintLine()                                                                                     
oSection2:PrintLine()                                                                                     
oSection3:PrintLine()                                                                                     
oSection4:PrintLine()                                                                                     
oSection5:PrintLine()

                                                                                     
Return oReport



Static Function PrintReport(oReport)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local oSection3 := oReport:Section(1):Section(1):Section(1)
Local oSection4 := oReport:Section(1):Section(1):Section(1):Section(1)
Local oSection5 := oReport:Section(1):Section(1):Section(1):Section(1):Section(1)
Local cQry      := ""
Local cQuery    := ""
Local cCliente  := ""
Local cTienda   := ""
Local nCodPag   := 0
local nTotVal := nTotSal := NVALORC := 0
local cNOMVEN := "" 
local cNOmbre := ""   
Local cCodban1   := ""
Local cAgencBco1 := ""
Local cNomBco1 := "" 
Local cMoneda := ""
Local cNomMoneda := ""              
local cDescVer  := ""
local x:= 0
local nTotConc := 0
Local cMvctsdias := GETMV("MV_CTSDIAS") //ESPCECT IGUAL
Local cMvctsdiaC :=GETMV("MV_CTSDIAC") //ESPECT MV_CTSDIACOM
Local cMvctsmesc :=GETMV("MV_CTSMESC") //ESPECT MV_CTSMESCOM
Local cMvctsrein :=GETMV("MV_CTSREIN") //ESPECT MV_CTSREINT
Local cMvctsmoe2 :=GETMV("MV_CTSMOE2") //ESPECT IGUAL
Local nTotctsds := 0
Local nTotctsdc := 0
Local nTotctsmc := 0
Local nTotctsrn := 0
Local nTotctsm2 := 0
Local cNomCargo := ""

Private cArquivo    	:= "firmarec.bmp" //"firmaPer.bmp"	//Nome do arquivo Bitmap que sera impresso na primeira pagina


IF EMPTY(AVERBASCTS)
	RETURN
ENDIF
If !File(cArquivo)
	MsgAlert(OemToAnsi(STR0013)+cArquivo)	//-"Arquivo não encontrado -> "
	Return
EndIf      
cArquivoC	:= fLoadLogo(cArquivo)
oReport:StartPage()

FOR X:= 1 TO LEN(aVerbasCTS)        
	IF averbasCts[x][1] $ cMvctsdias
		nTotctsds := nTotctsds + averbasCts[x][2] //HORAS
	ENDIF
      
	IF averbasCts[x][1] $ cMvctsdiaC
		nTotctsdc := nTotctsdc + averbasCts[x][3] //VALOR
	ENDIF
	
	IF averbasCts[x][1] $ cMvctsmesc
		nTotctsmc := nTotctsmc + averbasCts[x][3] //VALOR
	ENDIF
	
	IF averbasCts[x][1] $ cMvctsrein
		nTotctsrn := nTotctsrn + averbasCts[x][3] //VALOR
	ENDIF
	
	IF averbasCts[x][1] $ cMvctsmoe2
		nTotctsm2 := nTotctsm2 + averbasCts[x][2] //HORAS
	ENDIF
NEXT X 


x:= 10

oFont09	:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
oFont10 := TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
oFont10n:= TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)   
oFont12n:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.) 
oFont14n:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.) 

oBrush1 := TBrush():New( , CLR_GRAY )	 
oBrush2 := TBrush():New( , CLR_YELLOW )
oBrush3 := TBrush():New( , CLR_GRAY )
oBrush4 := TBrush():New( , CLR_RED )
oSection1:Init()    
oSection1:say ( 0080, 0500, "LIQ. COMPENSACIÓN POR TIEMPO DE SERVICIOS(DEP. SEMESTRAL)", oFont14n )
oSection1:say ( 0250, 0900, "D.L.N. 650 Y NORMAS COMPLEMENTARIAS", oFont10n )
oSection1:say ( 0300, 0900, "PERIODO " + " "+ cMesIni + " a " + cMesFin, oFont10n )

nlin := 350  
ncolmax := 2100 
osection1:BOX (nlin,050,nlin+50,ncolmax)
osection1:BOX (nlin,800,nlin+50,1100)                                    
oSection1:say ( nlin, 080,SM0->M0_NOME, oFont10 )
oSection1:say ( nlin, 910,cRuc, oFont10 )
oSection1:say ( nlin, 1150,SM0->M0_ENDENT, oFont10 )

nlin+=50   
osection1:FillRect( {nlin,050,nlin+50,ncolmax}, oBrush3 ) 
osection1:BOX (nlin,050,nlin+50,ncolmax)
osection1:BOX (nlin,800,nlin+50,1100)

oSection1:say ( nlin, 080,"EMPLEADOR", oFont10n )
oSection1:say ( nlin, 900,"RUC", oFont10n )
oSection1:say ( nlin, 1400,"DIRECCIÓN", oFont10n )                                      
nlin+=50
cNOmbre := alltrim((cAliasX)->RA_PRISOBR)+" "+alltrim((cAliasX)->RA_SECSOBR)+" "+alltrim((cAliasX)->RA_PRINOME)+" "+alltrim((cAliasX)->RA_SECNOME)
osection1:BOX (nlin,050,nlin+50,ncolmax)
osection1:BOX (nlin,195,nlin+50,495)    //
osection1:BOX (nlin,1055,nlin+50,1555) //
oSection1:say ( nlin+x, 080,(cAliasX)->RA_MAT, oFont10 )
oSection1:say ( nlin+x, 200,(cAliasX)->RA_DEPTO, oFont10 )
oSection1:say ( nlin+x, 500,cNOmbre, oFont10 )
oSection1:say ( nlin+x, 1080,substr((cAliasX)->RA_ADMISSA,1,4)+"-"+substr((cAliasX)->RA_ADMISSA,5,2)+"-"+substr((cAliasX)->RA_ADMISSA,7,2), oFont10 ) //STOD((cAliasX)->RA_ADMISSA)

SQ3->(DBSELECTAREA("SQ3"))
SQ3->(DBSETORDER(1))
cNomCargo := ""
IF SQ3->(DBSEEK(XFILIAL("SQ3")+(cAliasX)->RA_CARGO))
	cNomCargo := SQ3->Q3_DESCSUM
ENDIF
oSection1:say ( nlin+x, 1560,cNomCargo, oFont10 )
nlin+=50                                                  
osection1:FillRect( {nlin,050,nlin+50,ncolmax}, oBrush3 ) 
osection1:BOX (nlin,050,nlin+50,ncolmax)
osection1:BOX (nlin,195,nlin+50,495)    //
osection1:BOX (nlin,1055,nlin+50,1555) //


oSection1:say ( nlin+x, 080,"Codigo", oFont10n )
oSection1:say ( nlin+x, 210,"Unidad", oFont10n )
oSection1:say ( nlin+x, 600,"Nombre del trabajador", oFont10n ) 
oSection1:say ( nlin+x, 1080,"Fecha Ingreso", oFont10n ) 
oSection1:say ( nlin+x, 1700,"Ocupación", oFont10n ) 
nlin+=50


oSection2:Init() 
nlin+=50    

osection2:BOX (nlin,050,nlin+50,ncolmax)
osection2:BOX (nlin,280,nlin+50,495)
osection2:BOX (nlin,795,nlin+50,1150)
osection2:BOX (nlin,1600,nlin+50,ncolmax)  

cNomBco1 := ""
cNomBco1 := AllTrim(FDESCRCC("S005",(cAliasX)->RA_CODFGT,1,2,3,28)) 

//cCodban1   := Substr((cAliasX)->RA_BCDPFGT,1,3)
//cAgencBco1 := Substr((cAliasX)->RA_BCDPFGT,4,5) 		         
cMoneda := (cAliasX)->RA_MOEFGT                                             
cNomMoneda := POSICIONE("CTO",1,xfilial("CTO")+ cMoneda,"CTO_DESC")


//cNomBco1 := POSICIONE("SA6",1,xfilial("SA6")+ cCodban1+ cAgencBco1,"A6_NREDUZ")
oSection2:say ( nlin+x, 080, cDataPago, oFont10 )
oSection2:say ( nlin+x, 300, " ", oFont10 ) 
oSection2:say ( nlin+x, 0500, Transform( (cAliasX)->RA_SALARIO, "@E 99,999,999,999.99") , oFont10 )
oSection2:say ( nlin+x, 0800, cNomBco1, oFont10 )
oSection2:say ( nlin+x, 1200, (cAliasX)->RA_CTDPFGT, oFont10 )
oSection2:say ( nlin+x, 1700, cNomMoneda, oFont10 )
nlin+=50                                                                                   
osection2:FillRect( {nlin,050,nlin+50,ncolmax}, oBrush3 )                                                                               
osection2:BOX (nlin,050,nlin+50,ncolmax)
osection2:BOX (nlin,280,nlin+50,495)
osection2:BOX (nlin,795,nlin+50,1150)
osection2:BOX (nlin,1600,nlin+50,ncolmax)
oSection2:say ( nlin+x, 080, "Fecha deposito", oFont10 )
oSection2:say ( nlin+x, 300, "Sección", oFont10 ) 
oSection2:say ( nlin+x, 0500, "Remuneración Básica", oFont10 )
oSection2:say ( nlin+x, 0800, "Entidad depositada", oFont10 )
oSection2:say ( nlin+x, 1200, "Numero de cuenta", oFont10 )
oSection2:say ( nlin+x, 1700, "Tipo de moneda", oFont10 )
nlin+=50

oSection3:Init() 
nlin+=50    
osection3:FillRect( {nlin,050,nlin+50,ncolmax}, oBrush3 )                                                                               
osection3:BOX (nlin,050,nlin+50,ncolmax)

        
oSection3:say ( nlin+x, 800, "REMUNERACIONES COMPUTABLES", oFont10n )  
nlin+=50 
osection3:BOX (nlin,050,nlin+50,1495)
osection3:BOX (nlin,1500,nlin+50,ncolmax)
oSection3:say ( nlin+x, 550, "Concepto", oFont10n ) 
oSection3:say ( nlin+x, 1800, "Monto", oFont10n )
FOR X:= 1 TO LEN(aVerbasCTS)        


	cDatoValid := POSICIONE("SRV",1,xfilial("SRV")+ averbasCts[x][1],"RV_FGTS")
	
If Val(cDatoValid) > 0 .and. !(AllTrim(averbasCts[x][1]) $ "356")
		cDescVer := POSICIONE("SRV",1,xfilial("SRV")+ averbasCts[x][1],"RV_DESC")
		nlin+=50                                 
		osection3:BOX (nlin,050,nlin+50,1495)
		osection3:BOX (nlin,1500,nlin+50,ncolmax)                                                  
		oSection3:say ( nlin+x,150, UPPER(cDescVer) , oFont10n )
		oSection3:say ( nlin+x, 1800, Transform(averbasCts[x][3],"@R 999,999,999,999.99"), oFont10n )     
		nTotConc := nTotConc+ averbasCts[x][3]
	ENDIF

NEXT X 
nlin+=50                                 
osection3:BOX (nlin,1500,nlin+50,ncolmax)                                                  
oSection3:say ( nlin+x, 1800, Transform(nTotConc,"@R 999,999,999,999.99"), oFont10n )     

oSection4:Init() 
nlin+=100    
osection4:FillRect( {nlin,050,nlin+50,ncolmax}, oBrush3 )                                                                               
osection4:BOX (nlin,050,nlin+50,ncolmax)

        
oSection4:say ( nlin+x, 800, "LIQUIDACIÓN DE LA CTS CON EFECTO CANCELATORIO", oFont10n )  
nlin+=50      
osection4:BOX (nlin,050,nlin+50,ncolmax)
osection4:BOX (nlin,280,nlin+50,510)
osection4:BOX (nlin,740,nlin+50,970)
osection4:BOX (nlin,1200,nlin+50,1430)
osection4:BOX (nlin,1660,nlin+50,1890)                     
oSection4:say ( nlin+x, 120, cdataini, oFont10 ) 
oSection4:say ( nlin+x, 350, cdatafim, oFont10 )   
oSection4:say ( nlin+x, 600,  Transform(nTotctsds,"@R 999,999.99"), oFont10 )   
oSection4:say ( nlin+x, 750,  Transform(nTotctsdc,"@R 999,999.99"), oFont10 )   
oSection4:say ( nlin+x, 1000, Transform(nTotctsmc,"@R 999,999.99"), oFont10 )   
oSection4:say ( nlin+x, 1200, Transform(nTotctsrn,"@R 999,999,999,999.99"), oFont10 )   
oSection4:say ( nlin+x, 1450, Transform(nTotctsdc+nTotctsmc,"@R 999,999,999,999.99"), oFont10 )   
oSection4:say ( nlin+x, 1700, Transform(nTotctsm2,"@R 999,999,999,999.99"), oFont10 )   
oSection4:say ( nlin+x, 1900, Transform((nTotctsm2/100),"@R 999,999,999.9999"), oFont10 )   
nlin+=50   
osection4:FillRect( {nlin,050,nlin+50,ncolmax}, oBrush3 )     
osection4:BOX (nlin,050,nlin+50,ncolmax)
osection4:BOX (nlin,280,nlin+50,510)
osection4:BOX (nlin,740,nlin+50,970)
osection4:BOX (nlin,1200,nlin+50,1430)
osection4:BOX (nlin,1660,nlin+50,1890)
oSection4:say ( nlin+x, 120, "Del", oFont10n ) 
oSection4:say ( nlin+x, 350, "Al", oFont10n ) 
oSection4:say ( nlin+x, 600, "Dias", oFont10n ) 
oSection4:say ( nlin+x, 750, "Dias Comp. S/", oFont10n ) 
oSection4:say ( nlin+x,1000, "Meses Comp S/", oFont10n ) 
oSection4:say ( nlin+x,1250, "Reintegro S/", oFont10n ) 
oSection4:say ( nlin+x,1450, "Total Neto S/", oFont10n ) 
oSection4:say ( nlin+x,1700, "Monto en  US/", oFont10n ) 
oSection4:say ( nlin+x,1900, "T. Cambio S/", oFont10n ) 
nlin+=50


oSection4:say ( nlin+x, 050, "La empresa otorga al Sr.(a) "+cNombre+ "" +"la presente Constancia de deposito de compensación de"  , oFont10n )  
nlin+=50 
oSection4:say ( nlin+x, 050, "Tiempo de Servicio (CTS) correspondiente al perido desde: "+ cdataini + " al " + cdatafim + ",por el monto de S/ " + Transform(nTotctsdc+nTotctsmc,"@R 999,999.99") + " " + cNomMoneda , oFont10n )  
nlin+=50 
oSection5:Init() 
nlin+=800
osection4:SayBitmap(nlin-250, 050, cArquivoC, 500, 300,,.F.) //Tem que estar abaixo do RootPath
osection4:LINE (nlin,050,nlin,700)                                                              
osection4:LINE (nlin,1400,nlin,ncolmax)     
oSection4:say ( nlin+x, 100, UPPER(cNomeRep), oFont10 )
oSection4:say ( nlin+x, 1500, cNombre, oFont10 )
nlin+=50 
oSection4:say ( nlin+x, 100, SM0->M0_NOME, oFont10 )
  
oReport:Endpage()

Return 
    
  
Static Function ImpGPER900()

Local dData
Local x :=0 
Local aMes :={"Enero","Febrero","Marzo","Abril", "Marzo","Abril","Mayo","Junio", "Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"}

Private aPerFechado:= {}
Private aPerAberto := {}
Private aPerTodos  := {}
Private aVerbasCTS := {} 
Private aVerbasFUNC := {}

//Vaviaveis private para impressao
Private aInfo:= {}
Private cCargoRep:= ""
Private cNomeRep := ""
Private cDataPago:= ""
Private cEntCTS  := ""
Private nVerbaSal:= 0
Private nAsignFam:= 0
Private nAlimPrin:= 0
Private nBonifica:= 0
Private nComissao:= 0
Private nHoraExtr:= 0
Private nGratific:= 0
Private nOutros  := 0
Private nBaseCTS := 0
Private nValCTS  := 0
Private nMontoCTS:= 0
Private nAnos	 := 0
Private nMeses	 := 0
Private nDias	 := 0
Private nMontoMes:= 0
Private nMontoDia:= 0
Private dDataIni :=ctod("  /  /  ")
Private dDataFim :=ctod("  /  /  ")
Private cDataIni := ""
Private cDataFim := ""

Private cRuc := ""   
Private cMesFin := ""
Private cMesIni := ""


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Objetos para Impressao Grafica - Declaracao das Fontes Utilizadas.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oFont09, oFont10, oFont10n, oFont12n


oFont09	:= TFont():New("Courier New",09,09,,.F.,,,,.T.,.F.)
oFont10 := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
oFont10n:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)     //Negrito//
oFont12n:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)     //Negrito//

nEpoca:= SET(5,1910)

//-- MUDAR ANO PARA 4 DIGITOS
SET CENTURY ON
SRA->( dbCloseArea() )
cOrdem 		:= "%RA_FILIAL, RA_MAT%"		
BeginSql alias cAliasX
		SELECT *
		FROM %table:SRA% SRA
		WHERE %exp:cFiltro% 
			   SRA.%notDel%   
		ORDER BY %exp:cOrdem%       
EndSql


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Regua de Processamento                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetPrc(0,0)
(cAliasX)->(dbgotop())
	
While (cAliasX)->( !EOF() )   
	cProcesso := (cAliasX)->RA_PROCES
	If (cAliasX)->RA_TIPOSAL == "1"
	  	  fInfo(@aInfo, (cAliasX)->RA_FILIAL)

		  //carrega periodos do mes selecionado
		  fbusperCTS( cPeriodo,cSemana , cProcesso,cProcedi , @aPerAberto, @aPerFechado,@aPerTodos )

		  If !( len(aPerTodos) < 1 )
		  		aSort(aPerTodos,,,{|x,y| x[2] < y[2] })
		  		cDataPago:= substr(aPerTodos[1,9],1,4)+ "-" + substr(aPerTodos[1,9],5,2) + "-" + substr(aPerTodos[1,9],7,2) //aPerTodos[1,9] //DtoC(aPerTodos[1,9])                                                                                 
	
		  		aVerbasCTS := BuscaPerAbCr( aPerTodos[1,1],aPerTodos[1,2],aPerTodos[1,7] ,aPerTodos[1,8],(cAliasX)->RA_MAT,aPerTodos[1,13])
		  Endif
  		 		
		  //carrega parametros da empresa
		  cNomeRep  := RTRIM(LTRIM(fTabela("S002", 01, 7))) + " " + RTRIM(LTRIM(fTabela("S002", 01, 8)))+ " " + RTRIM(LTRIM(fTabela("S002", 01, 9))) //cNomeRep  := fTabela("S002", 01, 10)
		  cCargoRep := fTabela("S002", 01, 10)
		  cRuc 		:= fTabela("S002", 01, 04)     
	 	
		  nVerbaSal:= nAsignFam:= nAlimPrin:= nBonifica:= 0
		  nComissao:= nHoraExtr:= nGratific:= nOutros  := 0
		  nBaseCTS := nValCTS  := nMontoCTS:= nAnos	   := 0
		  nMeses   := nDias	   := nMontoMes:= nMontoDia:= 0
		  dDataIni := dDataFim := CtoD("//")

		  nPos:= fPosTab("S005", (cAliasX)->RA_CODFGT , "==", 04)
		  If nPos > 0
		  		cEntCTS:= fTabela("S005", nPos, 05)
		  Endif
			    dData :=   ctod(substr(aPerTodos[1,5],7,2)+"/"+substr(aPerTodos[1,5],5,2)+"/"+substr(aPerTodos[1,5],1,4)) //CtoD("01/"+cMes+"/"+cAno)
		  
		  If Empty(dDataIni)
				dDataIni:= dData 
		  Endif
				
		  dDataFim:=  ctod(substr(aPerTodos[1,6],7,2)+"/"+substr(aPerTodos[1,6],5,2)+"/"+substr(aPerTodos[1,6],1,4)) 

		  If !Empty((cAliasX)->RA_DEMISSA) .And. Month(ctod(substr((cAliasX)->RA_DEMISSA,7,2)+"/"+substr((cAliasX)->RA_DEMISSA,5,2)+"/"+substr((cAliasX)->RA_DEMISSA,1,4))) == Month(dDataFim)
				dDataFim:= ctod(substr((cAliasX)->RA_DEMISSA,7,2)+"/"+substr((cAliasX)->RA_DEMISSA,5,2)+"/"+substr((cAliasX)->RA_DEMISSA,1,4))//(cAliasX)->RA_DEMISSA
		  Endif

		  If !(ctod(substr((cAliasX)->RA_ADMISSA,7,2)+"/"+substr((cAliasX)->RA_ADMISSA,5,2)+"/"+substr((cAliasX)->RA_ADMISSA,1,4)) < dData) //MonthSub(dData, 6))
		       	dDataIni:= ctod(substr((cAliasX)->RA_ADMISSA,7,2)+"/"+substr((cAliasX)->RA_ADMISSA,5,2)+"/"+substr((cAliasX)->RA_ADMISSA,1,4)) //(cAliasX)->RA_ADMISSA
		  EndIf
                
          cDataIni	:= dtoc(dDataIni)
          cDataIni 	:= substr(cDataIni,7,4) +"-"+ substr(cDataIni,4,2) + "-"+substr(cDataIni,1,2)
          cDataFim	:= dtoc(dDataFim)
          cDataFim 	:= substr(cDataFim,7,4) +"-"+ substr(cDataFim,4,2) + "-"+substr(cDataFim,1,2)
          
                  
                cMesFin := " "
                If Month(dDataFim) == 1
                cMesFin := "Enero "+ AllTrim(Str(year(dDataFim)))
                Elseif Month(dDataFim) == 2
                cMesFin := "Febrero "+ AllTrim(Str(year(dDataFim)))
                Elseif Month(dDataFim) == 3
                cMesFin := "Marzo "+ AllTrim(Str(year(dDataFim)))
                Elseif Month(dDataFim) == 4
                cMesFin := "Abril "+ AllTrim(Str(year(dDataFim)))
                Elseif Month(dDataFim) == 5
                cMesFin := "Mayo "+ AllTrim(Str(year(dDataFim)))
                Elseif Month(dDataFim) == 6
                cMesFin := "Junio "+ AllTrim(Str(year(dDataFim)))
                Elseif Month(dDataFim) == 7
                cMesIni := "Julio "+ AllTrim(Str(year(dDataFim)))
                Elseif Month(dDataFim) == 8
                cMesFin := "Agosto "+ AllTrim(Str(year(dDataFim)))
                Elseif Month(dDataFim) == 9
                cMesFin := "Septiembre "+ AllTrim(Str(year(dDataFim)))
                Elseif Month(dDataFim) == 10
                cMesFin := "Octubre "+ AllTrim(Str(year(dDataFim)))
                Elseif Month(dDataFim) == 11
                cMesFin := "Noviembre "+ AllTrim(Str(year(dDataFim)))
                Elseif Month(dDataFim) == 12
                cMesFin := "Diciembre "+ AllTrim(Str(year(dDataFim)))
                EndIF

                cMesIni := " "
                If Month(dDataIni) == 1
                cMesIni := "Enero "+ AllTrim(Str(year(dDataIni)))
                Elseif Month(dDataIni) == 2
                cMesIni := "Febrero "+ AllTrim(Str(year(dDataIni)))
                Elseif Month(dDataIni) == 3
                cMesIni := "Marzo "+ AllTrim(Str(year(dDataIni)))
                Elseif Month(dDataIni) == 4
                cMesIni := "Abril "+ AllTrim(Str(year(dDataIni)))
                Elseif Month(dDataIni) == 5
                cMesIni := "Mayo "+ AllTrim(Str(year(dDataIni)))
                Elseif Month(dDataIni) == 6
                cMesIni := "Junio "+ AllTrim(Str(year(dDataIni)))
                Elseif Month(dDataIni) == 7
                cMesIni := "Julio "+ AllTrim(Str(year(dDataIni)))
                Elseif Month(dDataIni) == 8
                cMesIni := "Agosto "+ AllTrim(Str(year(dDataIni)))
                Elseif Month(dDataIni) == 9
                cMesIni := "Septiembre "+ AllTrim(Str(year(dDataIni)))
                Elseif Month(dDataIni) == 10
                cMesIni := "Octubre "+ AllTrim(Str(year(dDataIni)))
                Elseif Month(dDataIni) == 11
                cMesIni := "Noviembre "+ AllTrim(Str(year(dDataIni)))
                Elseif Month(dDataIni) == 12
                cMesIni := "Diciembre "+ AllTrim(Str(year(dDataIni)))
                EndIF
          
          PrintReport(oReport)
		
	Endif
	(cAliasX)->(dbSkip())

EndDo

//--Retornar Set Epoch Padrao
SET(5,nEpoca)

Return
                                                                                            
static function BuscaPerAbCr( Periodo,Semana,Proceso,roteir,mat,dFecCie )

Local cQuery    := ""
Local aVerbasAc := {}
Local cAliasSRC := GetNextAlias()

If empty(dFecCie) 


	cQuery := "SELECT SRC.RC_PD AS RCD_PD,SRC.RC_HORAS AS RCD_HORAS,SRC.RC_VALOR AS RCD_VALOR"
	cQuery +=  " FROM  "  +RetSqlName("SRC") + " SRC" 
	cQuery +=  " WHERE  SRC.RC_MAT    = '"+mat+"' "
	cQuery +=  " AND  SRC.RC_PROCES    = '"+Proceso+"' "	
	cQuery +=  " AND  SRC.RC_PERIODO    = '"+Periodo+"' "	
	cQuery +=  " AND  SRC.RC_ROTEIR    = '"+Roteir+"' "	
	cQuery +=  " AND  SRC.RC_SEMANA    = '"+Semana+"' "	
	cQuery +=  " AND D_E_L_E_T_ <> '*'  "
	cQuery +=  " ORDER BY SRC.RC_PD  "
Else

	cQuery := "SELECT SRD.RD_PD AS RCD_PD,SRD.RD_HORAS AS RCD_HORAS,SRD.RD_VALOR AS RCD_VALOR "
	cQuery +=  " FROM  "  +RetSqlName("SRD") + " SRD" 
	cQuery +=  " WHERE  SRD.RD_MAT    = '"+mat+"' "
	cQuery +=  " AND  SRD.RD_PROCES    = '"+Proceso+"' "	
	cQuery +=  " AND  SRD.RD_PERIODO    = '"+Periodo+"' "	
	cQuery +=  " AND  SRD.RD_ROTEIR    = '"+Roteir+"' "	
	cQuery +=  " AND  SRD.RD_SEMANA    = '"+Semana+"' "	
	cQuery +=  " AND D_E_L_E_T_ <> '*'  "
	cQuery +=  " ORDER BY SRD.RD_PD  "
EndIF
cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSRC, .F., .T.)
	
While (cAliasSrc)->( !EOF() )
	
	aadd(aVerbasAc,;
	{(cAliasSrc)->RCD_PD,;
	(cAliasSrc)->RCD_HORAS,;
	(cAliasSrc)->RCD_VALOR})
	
	(cAliasSrc)->( dbSkip() )
	
ENDDO
(cAliasSrc)->( dbCLOSEAREA() )

Return(aVerbasAc)	

Static Function fLoadLogo(cNomeArq)

	Local cStartPath := GetSrvProfString("Startpath","") 

	If Substr(cStartPath, Len(cStartPath), 1) == "\"
		cImagem := cStartPath + cNomeArq        
	Else
		cImagem := cStartPath + "\" + cNomeArq    
	Endif

Return cImagem

//Retorna array periodos abertos e fechados de uma competencia

static Function fbusperCTS(cPeriodo	,;		//Obrigatorio - periodo para localizar as informacoes
						cSemana		,;		//Opcional - semana a Pesquisar
						cProcesso	,;		//Obrigatorio - Filtro por Processo
						cRoteiro	,;		//Opcional - Filtro por Roteiro
						aPerAberto	,;		//Por Referencia - Array com os periodos Abertos
						aPerFechado,;		//Por Referencia - Array com os periodos Fechados
						aPerTodos  )		//Por Referencia - Array com os periodos Abertos e Fechados em Ordem Crescente

Local aArea			:= GetArea()
Local cAliasRCH 	:= ""
Local cWhereRCH   	:= ""
Local cCamposRCH  	:= "" 
Local nCnt
Local cQuery        := {}

DEFAULT cProcesso 	:= ""
DEFAULT cRoteiro	:= ""
DEFAULT cPeriodo    := ""
DEFAULT cSemana     := ""

If Empty(cPeriodo)
	Return(NIL)
EndIf

aPerAberto 	:= {}
aPerFechado	:= {}
aPerTodos	:= {}

cAliasRCH  := GetNextAlias()
		
cCamposRCH := "%RCH_DTPAGO, RCH_PER, RCH_NUMPAG, RCH_MES, RCH_ANO, "
cCamposRCH += "RCH_DTINI, RCH_DTFIM, RCH_DTFECH, RCH_PROCES, RCH_ROTEIR, "
cCamposRCH += "RCH_DTPAGO, RCH_DTCORT, RCH_DTINTE, RCH_COMPL%"
		
cWhereRCH := " RCH.RCH_PER = '" + cPeriodo + "' "
cWhereRCH += " AND RCH.RCH_NUMPAG = '" + cSemana + "' "
		
If !Empty(cProcesso)
	cWhereRCH += " AND RCH.RCH_PROCES = '" + cProcesso + "' "
EndIf

If !Empty(cRoteiro)
	cWhereRCH += " AND RCH.RCH_ROTEIR = '" + cRoteiro + "' "
EndIf

cWhereRCH := "%" + cWhereRCH + "%"		
		
BeginSql alias cAliasRCH
			SELECT DISTINCT %Exp:cCamposRCH% 
			FROM  %Table:RCH% RCH
			WHERE %Exp:cWhereRCH% AND RCH.%NotDel%
			ORDER BY 6,5 //Ordenação por ano e mês
EndSql

cquery := getlastquery()

If ((cAliasRCH)->( !EOF() ))
	While (cAliasRCH)->( !EOF() )
		aAdd(aPerTodos, (cAliasRCH)->({RCH_PER, RCH_NUMPAG, RCH_MES, RCH_ANO, RCH_DTINI, RCH_DTFIM, RCH_PROCES, RCH_ROTEIR, RCH_DTPAGO, RCH_DTCORT, RCH_DTINTE,RCH_COMPL,RCH_DTFECH}))
		(cAliasRCH)->( DbSkip())
	EndDo
EndIf
(cAliasRCH)->(DbCloseArea())
RestArea( aArea )

Return ( NIL )
