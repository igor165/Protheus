#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                                                     
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER915   ºAutor  ³Orbitas Comerciales  ºFecha ³  28/11/2017º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ COMUNICADO DE ENTREGA AL MTPE                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PERU                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function GPER915PER()
Public oReport

If TRepInUse()

	Pergunte("GPER915PER",.t.)
	/*
	cProc - Proceso
	cProcedi - Procedimiento
	MV_PAR03 - De Periodo
	MV_PAR04 - Num Pgo
	MV_PAR05 - Sucursal
	MV_PAR06 - Centro de Costo
	MV_PAR07 - Matricula
	MV_PAR08 - Situacion
	MV_PAR09 - Categoria
	*/
	oReport := ReportDef()
 	oReport:PrintDialog()
EndIf

Return

Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oSection4
    
    
oReport := TReport():New("GPER915PER","","GPER915PER",{|oReport| IMPGPER915()},"")

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
Local cQuery    := ""
local cNombre := ""   
local x:= 0
Local cFirmaRep    	:= "firmarep.bmp"	//Imagen de Firma del representante legal. Tiene que esta en el  RootPath

oReport:StartPage()
x:= 10

oFont09	:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
oFont10 := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont10n:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)   
oFont12n:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.) 
 
oSection1:Init()    
nlin := 350  
                        
					                                                                                                                                              
oSection1:say ( nlin, 600,"COMUNICACION DE ENTREGA AL MTPE DE LOS APORTES AL FONDO EMPLEO", oFont12n )
nlin+=150
cNombre := alltrim(SRA->RA_PRISOBR)+" "+alltrim(SRA->RA_SECSOBR)+" "+alltrim(SRA->RA_PRINOME)+" "+alltrim(SRA->RA_SECNOME)   //RA_NOMECMP
oSection1:say ( nlin, 080,"Señores ", oFont10 )
nlin+=50 
oSection1:say ( nlin, 080,"Ministerio de Trabajo y Promoción del Empleo ", oFont10 )
nlin+=50
oSection1:say ( nlin, 080,"Presente.- ", oFont10 )
nlin+=100
oSection1:say ( nlin, 080,alltrim(SM0->M0_NOMECOM)+", con domicilio en "+alltrim(SM0->M0_ENDENT)+" y con RUC N° "+alltrim(SM0->M0_CGC)+" debidamente representada por "+UPPER(cNomeRep), oFont10 )
nlin+=50                                                           
oSection1:say ( nlin, 080," con DNI N° "+cDNI+", se hace presente y expone:" , oFont10 )                          
nlin+=100                                                                   
oSection1:say ( nlin, 080,"De conformidad con lo dispuesto en el artículo 3° del D.Leg. N° 892 y el artículo 9° del D. S. N° 009-98-TR, modificado por el D. S. N° 017-2011-TR y dentro del plazo de ley,", oFont10 )
nlin+=50                                                                                                                              
oSection1:say ( nlin, 080,"hacemos entrega a ustedes el monto de las utilidades no entregadas a los trabajadores, consideradas como remanentes luego de aplicar el limite de 18 remuneraciones, el cual "  , oFont10 )
nlin+=50  
oSection1:say ( nlin, 080,"sera destinado al Fondo Nacional de Capacitación Laboral y de Promoción del Empleo (FONDOEMPLEO) Dicho monto es el siguiente:"   , oFont10 )
nlin+=100
oSection1:say ( nlin, 400,Transform( n26V, "@E 99,999,999,999.99"),oFont10,,,,1 )	  
oSection1:say ( nlin, 700,"("+Extenso(n26V,,,)+")",oFont10)	                                     
nlin+=50 
osection1:LINE (nlin,100,nlin,450)
oSection1:say ( nlin, 150,"(valor en números)", oFont10 )  
osection1:LINE (nlin, 700,nlin,1300)
oSection1:say ( nlin, 850,"(valor en letras)", oFont10 )
nlin+=100
oSection1:say ( nlin, 080,"Damos por cumplida nuestra obligación de acuerdo a la Ley.", oFont10 )

oSection2:Init() 
oSection3:Init() 

oSection4:Init() 
nlin+=100
oSection1:say ( nlin, 080,"LIMA, "+ AllTrim(STR(DAY(DDATABASE)))+" de " + mesextenso(month(ddatabase))+ " del "+AllTrim(str(year(ddatabase))), oFont10 )
nlin+=600                    
osection4:SayBitmap(nlin-250, 850, cFirmaRep, 500, 300,,.F.) 
osection4:LINE (nlin,750,nlin,1400)                                                              
oSection4:say ( nlin+x, 800, UPPER(cNomeRep), oFont10 )
  
oReport:Endpage()
Return 
    
  
Static Function ImpGPER915(cFiltro)
Local nI := 0
Local nCont:=0
Local cOrdem :=''
Local cFiltro :=''
Local cAliasX:=GetNextAlias()

Private cProcedi 	:= ""
Private cMes 	  	:= ""
Private cAno 	  	:= ""
Private cSemana		:= "" 
Private cSituacao	:=""
Private cCategoria	:=""

Private aPerFechado:= {}
Private aPerAberto := {}
Private aPerTodos  := {}

Private aInfo		:= {} 
Private aVerbasCTS  := {} 

Private cNomeRep := ""
Private cDNI	 := ""


Private cRuc := ""
Private  c26 := ""
Private n26V := 0


Private oFont09, oFont10, oFont10n, oFont12n


oFont09	:= TFont():New("Courier New",09,09,,.F.,,,,.T.,.F.)
oFont10 := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
oFont10n:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)     //Negrito//
oFont12n:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)     //Negrito//

Pergunte("GPER915PER",.f.)

cProcedi	:= mv_par02
cMes 	  	:= Substr(mv_par03, 1, 2)
cAno 	  	:= Substr(mv_par03, 3, 4)
cSemana 	:= mv_par04

cSituacao  	:=  mv_par08	// Situacao do Funcionario
cCategoria 	:=  mv_par09 	// Categoria do Funcionario   

//-- Situacao do Funcionario
	cSitQuery := ""
	For nCont:=1 to Len(cSituacao)
		cSitQuery += "'"+Subs(cSituacao,nCont,1)+"'"
		If ( nCont+1 ) <= Len(cSituacao)
			cSitQuery += "," 
		Endif
	Next nCont     
	cSitQuery := "%" + cSitQuery + "%"
	

//-- Categoria do Funcionario
	cCatQuery := ""
	For nCont:=1 to Len(cCategoria)
		cCatQuery += "'"+Subs(cCategoria,nCont,1)+"'"
		If ( nCont+1 ) <= Len(cCategoria)
			cCatQuery += "," 
		Endif
	Next nCont
	cCatQuery := "%" + cCatQuery + "%"
	
MakeSqlExpr(oReport:uParam)

if !empty(MV_PAR01) 
	IIf (!empty(cFiltro), cFiltro+=" AND ",)
 	cFiltro += MV_PAR01 
 endif
if !empty(MV_PAR05)
    IIf (!empty(cFiltro), cFiltro+=" AND ",)
 	cFiltro += MV_PAR05 
endif 	 
if !empty(MV_PAR06)
	 IIf (!empty(cFiltro), cFiltro+=" AND ",)
 	 cFiltro += MV_PAR06 
 endif
 if !empty(MV_PAR07)
 	IIf (!empty(cFiltro), cFiltro+=" AND ",)
 	cFiltro +=  MV_PAR07
endif 	
if !empty(cFiltro)
	cFiltro := "%" + cFiltro + "%"
endif	

cAliasX:=GetNextAlias()

cOrdem	:= "%RA_FILIAL, RA_MAT%"
 			
	BeginSql alias cAliasX
		SELECT RA_FILIAL, RA_MAT, RA_PROCES,RA_PRISOBR, RA_SECSOBR, RA_PRINOME,RA_SECNOME,RA_NOMECMP
		FROM %table:SRA% SRA
		WHERE %exp:cFiltro%  AND
				SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) 	AND
			    SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) 	AND
			   SRA.%notDel%   
		ORDER BY %exp:cOrdem%     

	EndSql

While (cAliasX)->( !EOF() )   
	  fInfo(@aInfo, ("SRA")->RA_FILIAL)
	  cNomeRep  := RTRIM(LTRIM(fTabela("S002", 01, 7))) + " " + RTRIM(LTRIM(fTabela("S002", 01, 8)))+ " " + RTRIM(LTRIM(fTabela("S002", 01, 9))) 
	  cDNI		:= fTabela("S002", 01, 6)
	  cRuc 		:= fTabela("S002", 01, 01)     
 	  c26:= fDescRCC("S019","000926", 1,6,7,90)
 	  
	  fRetPerComp( cMes, cAno, , (cAliasX)->RA_PROCES,cProcedi , @aPerAberto, @aPerFechado,@aPerTodos )//Obtiene periodos abierto y cerrados
	  
	  If !( len(aPerFechado) < 1 )
		  	aSort(aPerFechado,,,{|x,y| x[2] < y[2] })
  			aVerbasCTS:= BuscaPercerrado(aPerFechado[1,9] , aPerFechado[1,7], aPerFechado[1,8], (cAliasX)->RA_MAT)	 //Obtiene la suma de importes del los conceptos de periodos cerrados
	  Endif
      If !( len(aPerAberto) < 1 )
		  	aSort(aPerAberto,,,{|x,y| x[2] < y[2] })
		 	aVerbasCTS:= BuscaPerAberto( aPerAberto[1,1],aPerAberto[1,7] ,aPerAberto[1,8],(cAliasX)->RA_MAT)//Obtiene la suma de importes del los conceptos de periodos abierto	
	  Endif
      For nI := 1 TO LEN(aVerbasCTS)        
			IF ALLTRIM(aVerbasCts[nI][1]) $ ALLTRIM(c26)
					n26V := n26V + aVerbasCts[nI][3]
			ENDIF
	  NEXT nI
	  (cAliasX)->(dbSkip())
EndDo
(cAliasX)->(dbclosearea())
PrintReport(oReport)
Return

static function BuscaPercerrado( dFecPgo,Proceso,roteir,mat )

Local cQuery := ""
LOCAL aVerbasAc := {} 
Local cFilSRD := MV_PAR05

cFilSRD := STRTRAN(cFilSRD,"RA_","RD_")

cAliasSRD 	:= "QSRD"
cQuery := "SELECT RD_PD,SUM(RD_HORAS) AS HORAS,SUM(RD_VALOR) AS VALOR "
cQuery +=  " FROM  "  +RetSqlName("SRD") + " SRD" 
cQuery +=  " WHERE  " + cFilSRD 
cQuery +=  " AND  SRD.RD_MAT    = '"+MAT+"' "
cQuery +=  " AND  SRD.RD_PROCES = '"+Proceso+"' "	
cQuery +=  " AND  (SRD.RD_DATPGT BETWEEN '"+dtos(dFecPgo)+"' AND '"+dtos(dFecPgo)+"') "	
cQuery +=  " AND  SRD.RD_ROTEIR    = '"+Roteir+"' "	
cQuery +=  " AND D_E_L_E_T_ <> '*'  "
cQuery +=  " GROUP BY SRD.RD_PD   "
cQuery +=  " ORDER BY SRD.RD_PD  "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSRD, .F., .T.)

While (cAliasSrD)->( !EOF() )
	aadd(aVerbasAc,;
		{(cAliasSrd)->RD_PD,;
		 (cAliasSrd)->HORAS,;
		 (cAliasSrd)->VALOR})
	
	(cAliasSrD)->( dbSkip() )
ENDDO
(cAliasSrD)->( dbCLOSEAREA() )

Return(aVerbasAc)	

static function BuscaPerAberto( cPeriodo,cProceso,cRoteir,cMat )

Local cQuery := ""
Local aVerbasAc := {}
Local cFilSRC := MV_PAR05

cFilSRC := STRTRAN(cFilSRC,"RA_","RC_")


cAliasSRC 	:= "QSRC"
cQuery := "SELECT RC_PD, RC_HORAS, RC_VALOR "
cQuery +=  " FROM  "  +RetSqlName("SRC") + " SRC"
cQuery +=  " WHERE  " + cFilSRC 
cQuery +=  " AND  SRC.RC_MAT    	= '"+cMat	 +"' "
cQuery +=  " AND  SRC.RC_PROCES    	= '"+cProceso+"' "	
cQuery +=  " AND  SRC.RC_PERIODO    = '"+cPeriodo+"' "	
cQuery +=  " AND  SRC.RC_ROTEIR    	= '"+cRoteir +"' "	
cQuery +=  " AND D_E_L_E_T_ <> '*'  "
cQuery +=  " ORDER BY SRC.RC_PD  "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasSRC, .F., .T.)

While (cAliasSrc)->( !EOF() )
	aadd(aVerbasAc,;
		{(cAliasSrc)->RC_PD,;
		 (cAliasSrc)->RC_HORAS,;
		 (cAliasSrc)->RC_VALOR})
	
	(cAliasSrc)->( dbSkip() )

ENDDO
(cAliasSrc)->( dbCLOSEAREA() )
Return(aVerbasAc)	
 


                                                                                            
