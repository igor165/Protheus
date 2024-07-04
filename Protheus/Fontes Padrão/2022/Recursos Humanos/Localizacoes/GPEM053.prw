#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM053.CH"
#INCLUDE "REPORT.CH"


/*
ฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟ
ณFuno    ณ Archivos MTESS ณAutorณ  Laura M.         ณ Data ณ02/12/2019ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤด
ณDescrio ณ Generacion de Planillas MTESS(Paraguay)                    ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณSintaxe   ณ< Vide Parametros Formais >									ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณ Uso      ณGPEM053                                                     ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณ Retorno  ณa    														ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณParametrosณ< Vide Parametros Formais >									ณ
ภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Function GPEM053() // 
Private nArchivo  := 0
Private nMes      := 0
Private nAno      := 0
Private cNumPat   := ""
Private cPerg	  := "GPEM053" 
Private aEmpyOb   := {}
Private aSueyJr   := {}
Private aGralPO   := {}
Private nLastRec1 := 0
Private nLastRec2 := 0
Private nLastRec3 := 0
//Private cPictSal  := PesqPict("SRJ","RJ_SALARIO",TamSX3("RJ_SALARIO")[1])


If  Pergunte(cPerg,.T.)
	If  VldPreg()     
		If  (nArchivo == 1 .OR. nArchivo == 4)   //1=Empl y Obreros 4=Todos
			Processa( {|| GerEmpyOb()}, STR0001,STR0006, .T. ) //STR0006 "Planilla de Empleados y Obreros"
		Endif
		If  (nArchivo == 2 .OR. nArchivo == 4)   //2=Sueldos y Jor 4=Todos
			Processa( {|| GerSueyJr()}, STR0001,STR0007, .T. ) //STR0007 "Planilla de Sueldos y Jornales"
		Endif
		If  (nArchivo == 3 .OR. nArchivo == 4)   //3=Planilla de Resumen Genereal de Personas Ocupadas 4=Todos
			Processa( {|| GerGralPO()}, STR0001,STR0008, .T. ) //STR0008 "Planilla de Resumen General de Personas Ocupadas"
		Endif
		
		If  nArchivo == 4 .And. ( Empty(aEmpyOb) .And. Empty(aSueyJr) .And. Empty(aGralPO) ) 
			Aviso(STR0003, STR0030 , {STR0002} ) //Atencao, "No existen registros con esos parแmetros.", {OK}
		Endif	
	Endif
EndIf

Return(.T.)


/*
ฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟ
ณFuno    ณ VldPreg  		ณAutorณ  Laura M.         ณ Data ณ16/12/2019ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤด
ณDescrio ณValidaci๓n del grupo de preguntas (Paraguay)                ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณSintaxe   ณ< Vide Parametros Formais >									ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณ Uso      ณGPEM053                                                     ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณ Retorno  ณa    														ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณParametrosณ< Vide Parametros Formais >									ณ
ภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Static Function VldPreg() 
Local lRet  := .T. 

MakeSqlExpr(cPerg)

nArchivo:= MV_PAR01
nMes 	:= MV_PAR02
nAno  	:= MV_PAR03
cNumPat := MV_PAR04 
 
If  Empty(cNumPat)
	Aviso(STR0003, STR0004 , {STR0002}   ) //Atencao,"Indique el N๚mero Patronal", {OK} 
	lRet  := .F. 
Endif

Return(lRet)

//***PLANILLA 1- Empleados y Obreros
/*
ฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟ
ณFuno    ณ GerEmpyOb  		ณAutorณ  Laura M.     ณ Data ณ21/10/2019ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤด
ณDescrio ณ Planilla de Empleados y Obreros.                           ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณSintaxe   ณ< Vide Parametros Formais >									ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณ Uso      ณGPEM053                                                     ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณ Retorno  ณa    														ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณParametrosณ< Vide Parametros Formais >									ณ
ภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Static Function GerEmpyOb() 
Local aArea		  := GetArea()
Local cQuery	  := ""	                         
Local cAliasSRA   := GetNextAlias()
Local nCont       := 0
Local nI          := 0
Local ANOS_ANTIG  := 0 
Local FEC_NASC_MEN:= 0
Local HJOS_MENORES:= 0
Local NAUX01      := 0
Local MOTIVO_SAL  := "" 
Local cMesAno     := Alltrim(Str(nMes))+ Alltrim(Str(nAno))
Local dFchNasc    := ""

aEmpyOb  := {} 
nLastRec1 := 0
/*
nArchivo:= MV_PAR01
nMes 	:= MV_PAR02
nAno  	:= MV_PAR03
cNumPat := MV_PAR04 */

cQuery := "SELECT RA_FILIAL, RA_MAT, RA_REGISTR, RA_CIC, RA_PRINOME, RA_SECNOME, RA_PRISOBR, RA_SECSOBR, RA_SEXO, RA_ESTCIVI, " 
cQuery += "RA_NASC, RA_SERVICO, RA_ADMISSA, RA_SITFOLH, RA_TNOTRAB, RA_TIPOFIN, RA_BAIRRO, RA_ENDEREC, RA_COMPLEM, RA_DEPTO, RA_DEMISSA, "
//Nacionalidad
	cQuery  += 		"("
	cQuery  += 			"SELECT X5_DESCSPA "
	cQuery	+=			"FROM "
	cQuery	+=			RetSqlName("SX5")+ " SX5 "	
	cQuery  += 			"WHERE "
	cQuery  += 				"RA_NACIONA = SX5.X5_CHAVE AND "
	cQuery  += 				"SX5.X5_TABELA  = '34' AND "
	cQuery  += 				"SX5.X5_FILIAL = '"+xFilial("SX5")+"' AND "
	cQuery  += 				"SX5.D_E_L_E_T_= ' ' "
	cQuery	+=		") AS NACIONAL, "

//Domicilio
	cQuery  += 		"("
	cQuery  += 			"SELECT X5_DESCSPA "
	cQuery	+=			"FROM "
	cQuery	+=			RetSqlName("SX5")+ " SX5 "	
	cQuery  += 			"WHERE "
	cQuery  += 				"RA_ESTADO = SX5.X5_CHAVE AND "
	cQuery  += 				"SX5.X5_TABELA  = '12' AND "
	cQuery  += 				"SX5.X5_FILIAL = '"+xFilial("SX5")+"' AND "
	cQuery  += 				"SX5.D_E_L_E_T_= ' ' "
	cQuery	+=		") AS DOMICI, "

//Cargo
	cQuery  += 		"("
	cQuery  += 			"SELECT Q3_DESCSUM "
	cQuery	+=			"FROM "
	cQuery	+=			RetSqlName("SQ3")+ " SQ3 "	
	cQuery  += 			"WHERE "
	cQuery  += 				"RA_CARGO = SQ3.Q3_CARGO AND "
	cQuery  += 				"SQ3.Q3_FILIAL = '"+xFilial("SQ3")+"' AND "
	cQuery  += 				"SQ3.D_E_L_E_T_= ' ' "
	cQuery	+=		") AS CARGO, "

//Turno
	cQuery  += 		"("
	cQuery  += 			"SELECT R6_DESC "
	cQuery	+=			"FROM "
	cQuery	+=			RetSqlName("SR6")+ " SR6 "	
	cQuery  += 			"WHERE "
	cQuery  += 				"RA_TNOTRAB = SR6.R6_TURNO AND "
	cQuery  += 				"SR6.R6_FILIAL = '"+xFilial("SR6")+"' AND "
	cQuery  += 				"SR6.D_E_L_E_T_= ' ' "
	cQuery	+=		") AS TURNO, "

//Menor escuela
	cQuery  += 		"("
	cQuery  += 			"SELECT X5_DESCSPA "
	cQuery	+=			"FROM "
	cQuery	+=			RetSqlName("SX5")+ " SX5 "	
	cQuery  += 			"WHERE "
	cQuery  += 				"RA_GRINRAI = SX5.X5_CHAVE AND "
	cQuery  += 				"SX5.X5_TABELA  = '26' AND "
	cQuery  += 				"SX5.X5_FILIAL = '"+xFilial("SX5")+"' AND "
	cQuery  += 				"SX5.D_E_L_E_T_= ' ' "
	cQuery	+=		") AS ESCOLAR "

cQuery += "FROM "+RetSqlName("SRA")+" "					
cQuery += "WHERE "
      
//-- Activos (RA_SITFOLH <> 'D')
cQuery += "(( RA_SITFOLH <> 'D' AND "
cQuery += 	"MONTH(RA_ADMISSA)+YEAR(RA_ADMISSA) <= '"+ cMesAno +"' ) OR "
//-- Inactivos (RA_SITFOLH == 'D')
cQuery += "( RA_SITFOLH = 'D' AND "
cQuery += 	"YEAR(RA_DEMISSA) = '"+ Alltrim(Str(nAno)) +"' AND "
cQuery += 	"MONTH(RA_DEMISSA) <= '"+ Alltrim(Str(nMes)) +"' ) )"

cQuery += "AND RA_REGISTR = '"+ cNumPat +"'  "
cQuery += "AND D_E_L_E_T_<>'*' " 
cQuery += "AND RA_FILIAL = '"+xFilial("SRA")+"' "
cQuery += "ORDER BY RA_FILIAL,  RA_MAT "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRA,.T.,.T.)

Count to nCont
(cAliasSRA)->(dbGoTop())
       
ProcRegua(nCont) 
While (cAliasSRA)->(!EOF())     
	nI++
   	IncProc(STR0005 + STR0006 + str(nI)) //"Procesando... " "Planilla de Empleados y Obreros"
   	
   	dFchNasc     := Iif(!Empty((cAliasSRA)->RA_NASC),SUBSTRING((cAliasSRA)->RA_NASC,1,4)+"-"+SUBSTRING((cAliasSRA)->RA_NASC,5,2)+"-"+SUBSTRING((cAliasSRA)->RA_NASC,7,2),"")
   	dFchAdmi     := Iif(!Empty((cAliasSRA)->RA_ADMISSA),SUBSTRING((cAliasSRA)->RA_ADMISSA,1,4)+"-"+SUBSTRING((cAliasSRA)->RA_ADMISSA,5,2)+"-"+SUBSTRING((cAliasSRA)->RA_ADMISSA,7,2),"")
   	ANOS_ANTIG	 := nAno - YEAR(STOD((cAliasSRA)->RA_NASC)) - Iif(nMes<MONTH(STOD((cAliasSRA)->RA_NASC)),1,0)
   	FEC_NASC_MEN := Iif(ANOS_ANTIG < 18, dFchNasc , "")
   	HJOS_MENORES := ObtNroHjs((cAliasSRA)->RA_FILIAL,(cAliasSRA)->RA_MAT) 
   	NAUX01   	 := Iif(!Empty((cAliasSRA)->RA_TIPOFIN),FPOSTAB("S005",(cAliasSRA)->RA_TIPOFIN,"=",4),0)
   	MOTIVO_SAL   := Iif(NAUX01>0,FTABELA("S005",NAUX01,5),"")

   	Aadd(aEmpyOb,  {(cAliasSRA)->RA_REGISTR,;
   					(cAliasSRA)->RA_CIC,;
   					RTRIM(Alltrim((cAliasSRA)->RA_PRINOME) +' '+(cAliasSRA)->RA_SECNOME ),;   					
   					RTRIM(Alltrim((cAliasSRA)->RA_PRISOBR) +' '+(cAliasSRA)->RA_SECSOBR ),;   					
    				(cAliasSRA)->RA_SEXO,;  					
    				(cAliasSRA)->RA_ESTCIVI,;  					
   			   		dFchNasc,;		
     				(cAliasSRA)->NACIONAL,;  					
    				SUBSTRING(  Iif(Empty((cAliasSRA)->DOMICI),"",   RTRIM((cAliasSRA)->DOMICI) + " + " ) +;
    				 			Iif(Empty((cAliasSRA)->RA_BAIRRO),"",RTRIM((cAliasSRA)->RA_BAIRRO) + " + " )+;
    				 			RTRIM((cAliasSRA)->RA_ENDEREC)+ " " +RTRIM((cAliasSRA)->RA_COMPLEM), 1, 100) ,;  					
   			   		FEC_NASC_MEN,;
   			   		HJOS_MENORES,;
   			   		(cAliasSRA)->CARGO,;
   			   		(cAliasSRA)->RA_SERVICO,; 
   			   		dFchAdmi,;   		
   			   		Iif(!Empty(FEC_NASC_MEN),(cAliasSRA)->TURNO,""),; 
   			   		Iif(!Empty(FEC_NASC_MEN),dFchAdmi,""),;
   			   		Iif(!Empty(FEC_NASC_MEN),(cAliasSRA)->ESCOLAR,""),;
   			   		Iif(!Empty((cAliasSRA)->RA_SITFOLH=="D"),Iif(!Empty((cAliasSRA)->RA_DEMISSA),SUBSTRING((cAliasSRA)->RA_DEMISSA,1,4)+"-"+SUBSTRING((cAliasSRA)->RA_DEMISSA,5,2)+"-"+SUBSTRING((cAliasSRA)->RA_DEMISSA,7,2),""),""),; 
   			   		Iif(!Empty((cAliasSRA)->RA_SITFOLH=="D"), MOTIVO_SAL ,""),;
   			   		""} )
   	(cAliasSRA)->(dbSkip())	    
EndDo
If  Len(aEmpyOb) > 0 
	nLastRec1 := (cAliasSRA)->(LastRec())
EndIf	
(cAliasSRA)->(dbCloseArea()) 
 
If  Len(aEmpyOb) > 0 
	oReport:= ReportDef(aEmpyOb)
	oReport:PrintDialog()
ElseIf  nArchivo !=4 
	Aviso(STR0003, STR0030 , {STR0002} ) //Atencao, "No existen registros con esos parแmetros.", {OK}
Endif

RestArea(aArea)   
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportDef  บAutor  ณLaura Medina        บFecha ณ  17/12/19   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define reporte                                              บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportDef(aReport)
Local oReport
Local oSectionA
Local cNomeProg := "1-Planilla Empl y Obr"
Local cTitulo   := STR0006

DEFINE REPORT oReport NAME cNomeProg TITLE cTitulo PARAMETER ""/*cPerg2*/ ACTION {|oReport| PrintReport(oReport,oSectionA,aReport) } DESCRIPTION STR0006 //"Planilla de Empleados y Obreros"
oReport:SetTotalInLine(.T.)
oReport:SetLandscape(.T.)
oReport:lHeaderVisible := .T.
oReport:lParampage := .F.  	
oReport:lHeaderVisible := .F.
oReport:lFooterVisible := .F.

//DEFINE O TOTAL DA REGUA DA TELA DE PROCESSAMENTO DO RELATORIO
oReport:SetMeter(nLastRec1)        

DEFINE SECTION oSectionA OF oReport TITLE OemToAnsi(STR0006) TABLES "SRA" //"Planilla de Empleados y Obreros"
	DEFINE CELL NAME "NROPATRON"  	OF oSectionA TITLE OemToAnsi(STR0010) SIZE TamSX3("RA_REGISTR")[1] HEADER ALIGN LEFT 	
	DEFINE CELL NAME "DOCUMENTO" 	OF oSectionA TITLE OemToAnsi(STR0011) SIZE TamSX3("RA_CIC")[1] HEADER ALIGN LEFT
	DEFINE CELL NAME "NOMBRE" 		OF oSectionA TITLE OemToAnsi(STR0012) SIZE 50 HEADER ALIGN LEFT
	DEFINE CELL NAME "APELLIDO" 	OF oSectionA TITLE OemToAnsi(STR0013) SIZE 50 HEADER ALIGN LEFT
	DEFINE CELL NAME "SEXO"  	 	OF oSectionA TITLE OemToAnsi(STR0014) SIZE TamSX3("RA_SEXO")[1]+10 HEADER ALIGN LEFT
	DEFINE CELL NAME "ESTADOCIV" 	OF oSectionA TITLE OemToAnsi(STR0015) SIZE TamSX3("RA_ESTCIVI")[1]+10 HEADER ALIGN LEFT
	DEFINE CELL NAME "FECHANAC" 	OF oSectionA TITLE OemToAnsi(STR0016) SIZE TamSX3("RA_NASC")[1] HEADER ALIGN LEFT
	DEFINE CELL NAME "NACIONALI"	OF oSectionA TITLE OemToAnsi(STR0017) SIZE 20 HEADER ALIGN LEFT
	DEFINE CELL NAME "DOMICILIO"	OF oSectionA TITLE OemToAnsi(STR0018) SIZE 100 HEADER ALIGN LEFT
	DEFINE CELL NAME "FECHANACM"	OF oSectionA TITLE OemToAnsi(STR0019) SIZE TamSX3("RA_NASC")[1] HEADER ALIGN LEFT
	DEFINE CELL NAME "HIJOSMENO"	OF oSectionA TITLE OemToAnsi(STR0020) SIZE 1+10 HEADER ALIGN LEFT
	DEFINE CELL NAME "CARGO" 		OF oSectionA TITLE OemToAnsi(STR0021) SIZE TamSX3("Q3_DESCSUM")[1] HEADER ALIGN LEFT
	DEFINE CELL NAME "PROFESION" 	OF oSectionA TITLE OemToAnsi(STR0022) SIZE TamSX3("RA_SERVICO")[1] HEADER ALIGN LEFT
	DEFINE CELL NAME "FECHAENTR" 	OF oSectionA TITLE OemToAnsi(STR0023) SIZE TamSX3("RA_ADMISSA")[1] HEADER ALIGN LEFT
	DEFINE CELL NAME "HORARIOTR"	OF oSectionA TITLE OemToAnsi(STR0024) SIZE TamSX3("R6_DESC")[1] HEADER ALIGN LEFT
	DEFINE CELL NAME "MENORESCA" 	OF oSectionA TITLE OemToAnsi(STR0025) SIZE TamSX3("RA_ADMISSA")[1] HEADER ALIGN LEFT
	DEFINE CELL NAME "MENORESCO" 	OF oSectionA TITLE OemToAnsi(STR0026) SIZE 20 HEADER ALIGN LEFT
	DEFINE CELL NAME "FECHASALI" 	OF oSectionA TITLE OemToAnsi(STR0027) SIZE TamSX3("RA_DEMISSA")[1] HEADER ALIGN LEFT
	DEFINE CELL NAME "MOTIVOSAL" 	OF oSectionA TITLE OemToAnsi(STR0028) SIZE 100 HEADER ALIGN LEFT
	DEFINE CELL NAME "ESTADO" 		OF oSectionA TITLE OemToAnsi(STR0029) SIZE 1+10 HEADER ALIGN LEFT
	
oSectionA:SetHeaderPage(.F.)
oSectionA:SetHeaderSection(.F.) 
oSectionA:SetHeaderBreak(.F.)			
Return oReport


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrintReport บAutor  ณLaura Medina        บFecha ณ  17/12/19  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define reporte                                              บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrintReport(oReport,oSectionA,aReport)
Local nLoop     := 0

If Len(aReport) > 0
	oReport:StartPage()
	oReport:SetPageNumber(1)
	
	oSectionA:Init()
	oSectionA:Cell("NROPATRON"):SetTitle("")
	oSectionA:Cell("DOCUMENTO"):SetTitle("")
	oSectionA:Cell("NOMBRE"):SetTitle("")
	oSectionA:Cell("APELLIDO"):SetTitle("")
	oSectionA:Cell("SEXO"):SetTitle("")
	oSectionA:Cell("ESTADOCIV"):SetTitle("")
	oSectionA:Cell("FECHANAC"):SetTitle("")
	oSectionA:Cell("NACIONALI"):SetTitle("")
	oSectionA:Cell("DOMICILIO"):SetTitle("")
	oSectionA:Cell("FECHANACM"):SetTitle("")
	oSectionA:Cell("HIJOSMENO"):SetTitle("")
	oSectionA:Cell("CARGO"):SetTitle("")
	oSectionA:Cell("PROFESION"):SetTitle("")
	oSectionA:Cell("FECHAENTR"):SetTitle("")
	oSectionA:Cell("HORARIOTR"):SetTitle("")
	oSectionA:Cell("MENORESCA"):SetTitle("")	
	oSectionA:Cell("MENORESCO"):SetTitle("")
	oSectionA:Cell("FECHASALI"):SetTitle("")
	oSectionA:Cell("MOTIVOSAL"):SetTitle("")
	oSectionA:Cell("ESTADO"):SetTitle("")

	oSectionA:Cell("NROPATRON"):SetValue(OemToAnsi(STR0010))
	oSectionA:Cell("DOCUMENTO"):SetValue(OemToAnsi(STR0011))
	oSectionA:Cell("NOMBRE"):SetValue(OemToAnsi(STR0012))
	oSectionA:Cell("APELLIDO"):SetValue(OemToAnsi(STR0013))
	oSectionA:Cell("SEXO"):SetValue(OemToAnsi(STR0014))
	oSectionA:Cell("ESTADOCIV"):SetValue(OemToAnsi(STR0015))
	oSectionA:Cell("FECHANAC"):SetValue(OemToAnsi(STR0016))
	oSectionA:Cell("NACIONALI"):SetValue(OemToAnsi(STR0017))
	oSectionA:Cell("DOMICILIO"):SetValue(OemToAnsi(STR0018))
	oSectionA:Cell("FECHANACM"):SetValue(OemToAnsi(STR0019))
	oSectionA:Cell("HIJOSMENO"):SetValue(OemToAnsi(STR0020))
	oSectionA:Cell("CARGO"):SetValue(OemToAnsi(STR0021))
	oSectionA:Cell("PROFESION"):SetValue(OemToAnsi(STR0022))
	oSectionA:Cell("FECHAENTR"):SetValue(OemToAnsi(STR0023))
	oSectionA:Cell("HORARIOTR"):SetValue(OemToAnsi(STR0024))
	oSectionA:Cell("MENORESCA"):SetValue(OemToAnsi(STR0025))
	oSectionA:Cell("MENORESCO"):SetValue(OemToAnsi(STR0026))
	oSectionA:Cell("FECHASALI"):SetValue(OemToAnsi(STR0027))
	oSectionA:Cell("MOTIVOSAL"):SetValue(OemToAnsi(STR0028))
	oSectionA:Cell("ESTADO"):SetValue(OemToAnsi(STR0029))

	oSectionA:PrintLine()
	oReport:ThinLine()	
Endif 
	

For  nLoop:=1 to Len(aReport)
	If  oReport:Cancel()
		Exit
	EndIf
	oSectionA:Cell("NROPATRON"):SetValue(aReport[nLoop,1])
	oSectionA:Cell("DOCUMENTO"):SetValue(aReport[nLoop,2]) 
	oSectionA:Cell("NOMBRE"):SetValue(aReport[nLoop,3])
	oSectionA:Cell("APELLIDO"):SetValue(aReport[nLoop,4])
	oSectionA:Cell("SEXO"):SetValue(aReport[nLoop,5])		
	oSectionA:Cell("ESTADOCIV"):SetValue(aReport[nLoop,6])
	oSectionA:Cell("FECHANAC"):SetValue(aReport[nLoop,7])
	oSectionA:Cell("NACIONALI"):SetValue(aReport[nLoop,8])
	oSectionA:Cell("DOMICILIO"):SetValue(aReport[nLoop,9])
	oSectionA:Cell("FECHANACM"):SetValue(aReport[nLoop,10]) 
	oSectionA:Cell("HIJOSMENO"):SetValue(aReport[nLoop,11])
	oSectionA:Cell("CARGO"):SetValue(aReport[nLoop,12])		
	oSectionA:Cell("PROFESION"):SetValue(aReport[nLoop,13])
	oSectionA:Cell("FECHAENTR"):SetValue(aReport[nLoop,14])
	oSectionA:Cell("HORARIOTR"):SetValue(aReport[nLoop,15])
	oSectionA:Cell("MENORESCA"):SetValue(aReport[nLoop,16])
	oSectionA:Cell("MENORESCO"):SetValue(aReport[nLoop,17]) 
	oSectionA:Cell("FECHASALI"):SetValue(aReport[nLoop,18])
	oSectionA:Cell("MOTIVOSAL"):SetValue(aReport[nLoop,19])
	oSectionA:Cell("ESTADO"):SetValue(aReport[nLoop,20])	
	
	oSectionA:PrintLine()
Next 
oReport:ThinLine()

oReport:EndPage()//Finaliza reporte
oReport:EndReport()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณObtNroHjs  บAutor  ณLaura Medina        บFecha ณ  17/12/19   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtener el consecutivo de secuencia.                        บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtNroHjs(cFilSRA,cMatri) 
Local aAreaSRB    := SRB->(GetArea())
Local cQuery	  := ""	                 
Local cAliasSRB   := GetNextAlias() 
Local nANOS_ANTIG := 0
Local nHjsMen     := 0

cQuery := "SELECT RB_DTNASC " 
cQuery += "FROM "+RetSqlName("SRB")+" "					
cQuery += "WHERE "
cQuery += "D_E_L_E_T_<>'*' " 
cQuery += "AND RB_FILIAL = '"+cFilSRA+"' "
cQuery += "AND RB_MAT = '"+cMatri+"' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRB,.T.,.T.)

(cAliasSRB)->(dbGoTop())
While (cAliasSRB)->(!EOF()) 
  	nANOS_ANTIG	    := nAno - YEAR(STOD((cAliasSRB)->RB_DTNASC)) - Iif(nMes<MONTH(STOD((cAliasSRB)->RB_DTNASC)),1,0)
   	nHjsMen += Iif(nANOS_ANTIG < 18, 1,0) 
   	(cAliasSRB)->(dbSkip())	    
EndDo
SRB->(RestArea(aAreaSRB))

Return nHjsMen



//***PLANILLA 2- Sueldos y Jornaleros
/*
ฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟ
ณFuno    ณ GerSueyJr  		ณAutorณ  Laura M.     ณ Data ณ17/12/19  ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤด
ณDescrio ณ Funci๓n principal para el cambio de salario (Paraguay)     ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณSintaxe   ณ< Vide Parametros Formais >									ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณ Uso      ณGPEM053                                                     ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณ Retorno  ณa    														ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณParametrosณ< Vide Parametros Formais >									ณ
ภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Static Function GerSueyJr() 
Local aArea		:= GetArea()
Local cQuery	:= ""	                         
Local cAliasSRA := GetNextAlias()
Local nCont     := 0
Local nI        := 0
Local cMesAno   := Alltrim(Str(nMes))+ Alltrim(Str(nAno))
Local cEmpAnt	:= 0
Local nHRSIU	:= 0
Local nHRS01	:= 0
Local nACU01	:= 0  
Local nHRS02	:= 0
Local nACU02	:= 0  
Local nHRS03	:= 0
Local nACU03	:= 0  
Local nHRS04	:= 0
Local nACU04	:= 0   
Local nHRS05	:= 0  
Local nACU05	:= 0   
Local nHRS06	:= 0  
Local nACU06	:= 0    
Local nHRS07	:= 0  
Local nACU07	:= 0    
Local nHRS08	:= 0
Local nACU08	:= 0    
Local nHRS09	:= 0  
Local nACU09	:= 0  
Local nHRS10	:= 0  
Local nACU10	:= 0  
Local nHRS11	:= 0 
Local nACU11	:= 0    
Local nHRS12	:= 0 
Local nACU12	:= 0 
Local nHRS50	:= 0 
Local nACU50	:= 0 
Local nHRS100	:= 0 
Local nACU100	:= 0
Local nS_AGUINAL:= 0
Local nS_BENEFIC:= 0
Local nS_BONIFIC:= 0
Local nS_VACACIO:= 0 
Local nSigno    := 0
Local cID_0638	:= '0638' //Horas Efectivamente Trabajadas para Paraguay 
Local cRA_CIC	:= ''
Local nRA_FACTOR:= 0

aSueyJr  := {} 
nLastRec2 := 0
/*
nArchivo:= MV_PAR01
nMes 	:= MV_PAR02
nAno  	:= MV_PAR03
cNumPat := MV_PAR04 */

cQuery := "SELECT RA_FILIAL, RA_MAT, RV_INCORP, RV_TIPOCOD, RA_SITFOLH, RA_ADMISSA, RA_DEMISSA, "
cQuery += "RA_CODFUNC, RA_SALARIO, RA_CIC, RV_CODFOL, " 
//Factor conv
cQuery  += 		"("
cQuery  += 			"SELECT RJ_FACCON "
cQuery	+=			"FROM "
cQuery	+=			RetSqlName("SRJ")+ " SRJ "	
cQuery  += 			"WHERE "
cQuery  += 				"RA_CODFUNC = SRJ.RJ_FUNCAO AND "
cQuery  += 				"SRJ.RJ_FILIAL = '"+xFilial("SRJ")+"' AND "
cQuery  += 				"SRJ.D_E_L_E_T_= ' ' "
cQuery	+=		") AS FACTOR, "
 
cQuery += " SUM(RG7_HRS01) AS HRS01, SUM(RG7_ACUM01) AS ACU01, "
cQuery += " SUM(RG7_HRS02) AS HRS02, SUM(RG7_ACUM02) AS ACU02, "
cQuery += " SUM(RG7_HRS03) AS HRS03, SUM(RG7_ACUM03) AS ACU03, "
cQuery += " SUM(RG7_HRS04) AS HRS04, SUM(RG7_ACUM04) AS ACU04, "
cQuery += " SUM(RG7_HRS05) AS HRS05, SUM(RG7_ACUM05) AS ACU05, "
cQuery += " SUM(RG7_HRS06) AS HRS06, SUM(RG7_ACUM06) AS ACU06, "
cQuery += " SUM(RG7_HRS07) AS HRS07, SUM(RG7_ACUM07) AS ACU07, "
cQuery += " SUM(RG7_HRS08) AS HRS08, SUM(RG7_ACUM08) AS ACU08, "
cQuery += " SUM(RG7_HRS09) AS HRS09, SUM(RG7_ACUM09) AS ACU09, "
cQuery += " SUM(RG7_HRS10) AS HRS10, SUM(RG7_ACUM10) AS ACU10, "
cQuery += " SUM(RG7_HRS11) AS HRS11, SUM(RG7_ACUM11) AS ACU11, "
cQuery += " SUM(RG7_HRS12) AS HRS12, SUM(RG7_ACUM12) AS ACU12 "

cQuery += "FROM "+RetSqlName("SRA")+" SRA, "+RetSqlName("RG7")+" RG7, "+RetSqlName("SRV")+" SRV "				
cQuery += "WHERE RA_MAT = RG7_MAT AND RA_FILIAL = RG7_FILIAL "
cQuery += "AND RG7_PD = RV_COD  "
cQuery += "AND RG7_ANOINI = '"+ Alltrim(Str(nAno)) +"' "
cQuery += "AND RA_REGISTR = '"+ cNumPat +"'  AND "
    
//-- Activos (RA_SITFOLH <> 'D')
cQuery += "(( RA_SITFOLH <> 'D' AND "
cQuery += 	"MONTH(RA_ADMISSA)+YEAR(RA_ADMISSA) <= '"+ cMesAno +"' ) OR "
//-- Inactivos (RA_SITFOLH == 'D')
cQuery += "( RA_SITFOLH = 'D' AND "
cQuery += 	"YEAR(RA_DEMISSA) = '"+ Alltrim(Str(nAno)) +"' AND "
cQuery += 	"MONTH(RA_DEMISSA) <= '"+ Alltrim(Str(nMes)) +"' ) ) "

cQuery += "AND RA_FILIAL = '"+xFilial("SRA")+"' "
cQuery += "AND RV_FILIAL = '"+xFilial("SRV")+"' "
cQuery += "AND SRA.D_E_L_E_T_ <>'*' "
cQuery += "AND SRV.D_E_L_E_T_ <>'*' " 
cQuery += "AND RG7.D_E_L_E_T_ <>'*' "  
cQuery += "GROUP BY RA_FILIAL, RA_MAT, RV_INCORP, RV_TIPOCOD, RA_SITFOLH, RA_ADMISSA, RA_DEMISSA, "
cQuery += "RA_CODFUNC, RA_SALARIO, RA_CIC, RV_CODFOL "
cQuery += "ORDER BY RA_FILIAL, RA_MAT, RV_INCORP, RV_TIPOCOD, RA_SITFOLH, RA_ADMISSA, RA_DEMISSA, "
cQuery += "RA_CODFUNC, RA_SALARIO, RA_CIC, RV_CODFOL  "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRA,.T.,.T.)

Count to nCont
(cAliasSRA)->(dbGoTop())
       
ProcRegua(nCont) 
While (cAliasSRA)->(!EOF())     
	nI++
   	IncProc(STR0005 + STR0007 + str(nI)) //"Procesando... "... "Planilla de Sueldos y Jornales"

   	If  (cAliasSRA)->RV_INCORP =="1"  .OR. (cAliasSRA)->RV_CODFOL == cID_0638 
   		nSigno  := Iif((cAliasSRA)->RV_TIPOCOD $ "1|3", 1, Iif((cAliasSRA)->RV_TIPOCOD $ "2|4", -1 , 0) ) 
	   	
	   	If  (cAliasSRA)->RV_INCORP =="1" 
		   	nACU01  := nACU01 + (nSigno * (cAliasSRA)->ACU01 ) 	
		   	nACU02  := nACU02 + (nSigno * (cAliasSRA)->ACU02 )
		   	nACU03  := nACU03 + (nSigno * (cAliasSRA)->ACU03 )
		   	nACU04  := nACU04 + (nSigno * (cAliasSRA)->ACU04 )
		   	nACU05  := nACU05 + (nSigno * (cAliasSRA)->ACU05 )
		   	nACU06  := nACU06 + (nSigno * (cAliasSRA)->ACU06 )
		   	nACU07  := nACU07 + (nSigno * (cAliasSRA)->ACU07 )
		  	nACU08  := nACU08 + (nSigno * (cAliasSRA)->ACU08 )
		   	nACU09  := nACU09 + (nSigno * (cAliasSRA)->ACU09 )
			nACU10  := nACU10 + (nSigno * (cAliasSRA)->ACU10 )		
			nACU11  := nACU11 + (nSigno * (cAliasSRA)->ACU11 )		
			nACU12  := nACU12 + (nSigno * (cAliasSRA)->ACU12 )	
			nHRSIU  := nHRSIU + (nSigno * (cAliasSRA)->&("HRS" + StrZero(nMes, 2)) )
		Endif
		If  (cAliasSRA)->RV_CODFOL == cID_0638 	
			nHRS01  := nHRS01 + (nSigno * (cAliasSRA)->HRS01 )
			nHRS02  := nHRS02 + (nSigno * (cAliasSRA)->HRS02 )
			nHRS03  := nHRS03 + (nSigno * (cAliasSRA)->HRS03 )
			nHRS04  := nHRS04 + (nSigno * (cAliasSRA)->HRS04 )
			nHRS05  := nHRS05 + (nSigno * (cAliasSRA)->HRS05 )
			nHRS06  := nHRS06 + (nSigno * (cAliasSRA)->HRS06 )
			nHRS07  := nHRS07 + (nSigno * (cAliasSRA)->HRS07 )
			nHRS08  := nHRS08 + (nSigno * (cAliasSRA)->HRS08 )
			nHRS09	:= nHRS09 + (nSigno * (cAliasSRA)->HRS09 )
			nHRS10  := nHRS10 + (nSigno * (cAliasSRA)->HRS10 )
			nHRS11  := nHRS11 + (nSigno * (cAliasSRA)->HRS11 )
			nHRS12  := nHRS12 + (nSigno * (cAliasSRA)->HRS12 )
		Endif
		
	Elseif  (cAliasSRA)->RV_INCORP =="2" 	
		nSigno  := Iif((cAliasSRA)->RV_TIPOCOD $ "1|3", 1, Iif((cAliasSRA)->RV_TIPOCOD $ "2|4", -1 , 0) )
		nHRS50  := nHRS50 + ( nSigno * ( (cAliasSRA)->HRS01+(cAliasSRA)->HRS02+(cAliasSRA)->HRS03+(cAliasSRA)->HRS04+(cAliasSRA)->HRS05+(cAliasSRA)->HRS06+;
				   			  			 (cAliasSRA)->HRS07+(cAliasSRA)->HRS08+(cAliasSRA)->HRS09+(cAliasSRA)->HRS10+(cAliasSRA)->HRS11+(cAliasSRA)->HRS12 ))
	   	nACU50  := nACU50 + ( nSigno * ( (cAliasSRA)->ACU01+(cAliasSRA)->ACU02+(cAliasSRA)->ACU03+(cAliasSRA)->ACU04+(cAliasSRA)->ACU05+(cAliasSRA)->ACU06+;
	   									 (cAliasSRA)->ACU07+(cAliasSRA)->ACU08+(cAliasSRA)->ACU09+(cAliasSRA)->ACU10+(cAliasSRA)->ACU11+(cAliasSRA)->ACU12 ))	
	Elseif  (cAliasSRA)->RV_INCORP =="3" 	
		nSigno  := Iif((cAliasSRA)->RV_TIPOCOD $ "1|3", 1, Iif((cAliasSRA)->RV_TIPOCOD $ "2|4", -1 , 0) )
		nHRS100 := nHRS100 + ( nSigno * ( (cAliasSRA)->HRS01+(cAliasSRA)->HRS02+(cAliasSRA)->HRS03+(cAliasSRA)->HRS04+(cAliasSRA)->HRS05+(cAliasSRA)->HRS06+;
				   			  			 (cAliasSRA)->HRS07+(cAliasSRA)->HRS08+(cAliasSRA)->HRS09+(cAliasSRA)->HRS10+(cAliasSRA)->HRS11+(cAliasSRA)->HRS12 ))
	   	nACU100 := nACU100 + ( nSigno * ( (cAliasSRA)->ACU01+(cAliasSRA)->ACU02+(cAliasSRA)->ACU03+(cAliasSRA)->ACU04+(cAliasSRA)->ACU05+(cAliasSRA)->ACU06+;
	   									 (cAliasSRA)->ACU07+(cAliasSRA)->ACU08+(cAliasSRA)->ACU09+(cAliasSRA)->ACU10+(cAliasSRA)->ACU11+(cAliasSRA)->ACU12 ))	  
   	Elseif  (cAliasSRA)->RV_INCORP =="4" 	
		nSigno    := Iif((cAliasSRA)->RV_TIPOCOD $ "1|3", 1, Iif((cAliasSRA)->RV_TIPOCOD $ "2|4", -1 , 0) )
	   	nS_AGUINAL:= nS_AGUINAL + ( nSigno * ( (cAliasSRA)->ACU01+(cAliasSRA)->ACU02+(cAliasSRA)->ACU03+(cAliasSRA)->ACU04+(cAliasSRA)->ACU05+(cAliasSRA)->ACU06+;
	   									 (cAliasSRA)->ACU07+(cAliasSRA)->ACU08+(cAliasSRA)->ACU09+(cAliasSRA)->ACU10+(cAliasSRA)->ACU11+(cAliasSRA)->ACU12 ))	  
 	Elseif  (cAliasSRA)->RV_INCORP =="5" 	
		nSigno    := Iif((cAliasSRA)->RV_TIPOCOD $ "1|3", 1, Iif((cAliasSRA)->RV_TIPOCOD $ "2|4", -1 , 0) )
	   	nS_BENEFIC:= nS_BENEFIC + ( nSigno * ( (cAliasSRA)->ACU01+(cAliasSRA)->ACU02+(cAliasSRA)->ACU03+(cAliasSRA)->ACU04+(cAliasSRA)->ACU05+(cAliasSRA)->ACU06+;
	   									 (cAliasSRA)->ACU07+(cAliasSRA)->ACU08+(cAliasSRA)->ACU09+(cAliasSRA)->ACU10+(cAliasSRA)->ACU11+(cAliasSRA)->ACU12 ))	  
 	Elseif  (cAliasSRA)->RV_INCORP =="6" 	
		nSigno    := Iif((cAliasSRA)->RV_TIPOCOD $ "1|3", 1, Iif((cAliasSRA)->RV_TIPOCOD $ "2|4", -1 , 0) )
	   	nS_BONIFIC:= nS_BONIFIC + ( nSigno * ( (cAliasSRA)->ACU01+(cAliasSRA)->ACU02+(cAliasSRA)->ACU03+(cAliasSRA)->ACU04+(cAliasSRA)->ACU05+(cAliasSRA)->ACU06+;
	   									 (cAliasSRA)->ACU07+(cAliasSRA)->ACU08+(cAliasSRA)->ACU09+(cAliasSRA)->ACU10+(cAliasSRA)->ACU11+(cAliasSRA)->ACU12 ))	  
 	Elseif  (cAliasSRA)->RV_INCORP =="7" 	
		nSigno    := Iif((cAliasSRA)->RV_TIPOCOD $ "1|3", 1, Iif((cAliasSRA)->RV_TIPOCOD $ "2|4", -1 , 0) )
	   	nS_VACACIO:= nS_VACACIO + ( nSigno * ( (cAliasSRA)->ACU01+(cAliasSRA)->ACU02+(cAliasSRA)->ACU03+(cAliasSRA)->ACU04+(cAliasSRA)->ACU05+(cAliasSRA)->ACU06+;
	   									 (cAliasSRA)->ACU07+(cAliasSRA)->ACU08+(cAliasSRA)->ACU09+(cAliasSRA)->ACU10+(cAliasSRA)->ACU11+(cAliasSRA)->ACU12 ))	   	
   	Endif 
   	
   	cEmpAnt := (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT
   	cRA_CIC	:= (cAliasSRA)->RA_CIC
   	nRA_FACTOR:= (cAliasSRA)->FACTOR

   	(cAliasSRA)->(dbSkip())	 
   	
   	If  cEmpAnt != (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT
   	
   	  	Aadd(aSueyJr, { cNumPat,; 
   	  	   			cRA_CIC,;
   					Iif(nRA_FACTOR == 28,"J","M"),;   					
   					Iif(&("nAcu"+ StrZero(nMes, 2)) > 0 .And. nHRSIU > 0, ROUND(&("nAcu"+ StrZero(nMes, 2)) / nHRSIU , 0) , 0),; 
   					Iif(1 <= nMes, ROUND(nHRS01,0) ,0), Iif(1 <= nMes, ROUND(nACU01,0), 0),; 
    				Iif(2 <= nMes, ROUND(nHRS02,0) ,0), Iif(2 <= nMes, ROUND(nACU02,0), 0),;
    				Iif(3 <= nMes, ROUND(nHRS03,0) ,0), Iif(3 <= nMes, ROUND(nACU03,0), 0),; 
    				Iif(4 <= nMes, ROUND(nHRS04,0) ,0), Iif(4 <= nMes, ROUND(nACU04,0), 0),;
    				Iif(5 <= nMes, ROUND(nHRS05,0) ,0), Iif(5 <= nMes, ROUND(nACU05,0), 0),; 
    				Iif(6 <= nMes, ROUND(nHRS06,0) ,0), Iif(6 <= nMes, ROUND(nACU06,0), 0),;
    				Iif(7 <= nMes, ROUND(nHRS07,0) ,0), Iif(7 <= nMes, ROUND(nACU07,0), 0),;
    				Iif(8 <= nMes, ROUND(nHRS08,0) ,0), Iif(8 <= nMes, ROUND(nACU08,0), 0),;
    				Iif(9 <= nMes, ROUND(nHRS09,0) ,0), Iif(9 <= nMes, ROUND(nACU09,0), 0),;
    				Iif(10 <= nMes, ROUND(nHRS10,0),0), Iif(10 <= nMes, ROUND(nACU10,0), 0),;
    				Iif(11 <= nMes, ROUND(nHRS11,0),0), Iif(11 <= nMes, ROUND(nACU11,0), 0),;
    				Iif(12 <= nMes, ROUND(nHRS12,0),0), Iif(12 <= nMes, ROUND(nACU12,0), 0),;   					
    				ROUND(nHRS50,0),;
    				ROUND(nACU50,0),;
    				ROUND(nHRS100,0),;
    				ROUND(nACU100,0),;
    				ROUND(nS_AGUINAL,0),;
    				ROUND(nS_BENEFIC,0),;
    				ROUND(nS_BONIFIC,0),;
    				ROUND(nS_VACACIO,0) } )
   	
   		nHRS01  := nACU01  := nHRS02  := nACU02  := 0
		nHRS03  := nACU03  := nHRS04  := nACU04  := 0   			
		nHRS05  := nACU05  := nHRS06  := nACU06  := 0		   	
   		nHRS07  := nACU07  := nHRS08  := nACU08  := 0
   		nHRS08  := nACU09  := nHRS10  := nACU10  := 0   			
		nHRS11  := nACU11  := nHRS12  := nACU12  := 0
		nHRS50  := nACU50  := nHRS100 := nACU100 := 0	
		nHRSIU	:= 0	
		nS_AGUINAL:= nS_BENEFIC:= nS_BONIFIC:= nS_VACACIO:= 0 
		cRA_CIC	:= ''
		nRA_FACTOR:= 0
    Endif
EndDo
If  Len(aSueyJr) > 0 
	nLastRec2 := (cAliasSRA)->(LastRec())
EndIf	
(cAliasSRA)->(dbCloseArea()) 
 
If  Len(aSueyJr) > 0 
	oReport:= Report2Def(aSueyJr)
	oReport:PrintDialog()
ElseIf  nArchivo !=4 
	Aviso(STR0003, STR0030 , {STR0002} ) //Atencao, "No existen registros con esos parแmetros.", {OK}
Endif

RestArea(aArea)   
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReport2Def บAutor  ณLaura Medina        บFecha ณ  17/12/19   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define reporte                                              บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Report2Def(aReport)
Local oReport
Local oSectionA
Local cNomeProg := "2-Planilla Sueldos y Jor"
Local cTitulo   := STR0007

DEFINE REPORT oReport NAME cNomeProg TITLE cTitulo PARAMETER ""/*cPerg2*/ ACTION {|oReport| Print2Report(oReport,oSectionA,aReport) } DESCRIPTION STR0007 //"Planilla de Sueldos y Jornales"
oReport:SetTotalInLine(.T.)
oReport:SetLandscape(.T.)
oReport:lHeaderVisible := .T.
oReport:lParampage := .F.  	
oReport:lHeaderVisible := .F.
oReport:lFooterVisible := .F.

oReport:SetMeter(nLastRec2)        

DEFINE SECTION oSectionA OF oReport TITLE OemToAnsi(STR0007) TABLES "SRA" //"Planilla de Sueldos y Jornales"
	DEFINE CELL NAME "NROPATRON"	OF oSectionA TITLE OemToAnsi(STR0010) SIZE TamSX3("RA_REGISTR")[1] HEADER ALIGN LEFT 	
	DEFINE CELL NAME "DOCUMENTO" 	OF oSectionA TITLE OemToAnsi(STR0011) SIZE TamSX3("RA_CIC")[1] HEADER ALIGN LEFT
	DEFINE CELL NAME "FORMADEPAGO" 	OF oSectionA TITLE OemToAnsi(STR0031) SIZE 1+10 HEADER ALIGN LEFT
	DEFINE CELL NAME "IMPORTEUNITARIO" OF oSectionA TITLE OemToAnsi(STR0032) SIZE TamSX3("RA_SALARIO")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "H_ENE"  		OF oSectionA TITLE OemToAnsi(STR0033) SIZE TamSX3("RG7_HRS01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "S_ENE" 		OF oSectionA TITLE OemToAnsi(STR0034) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "H_FEB" 		OF oSectionA TITLE OemToAnsi(STR0035) SIZE TamSX3("RG7_HRS01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "S_FEB"		OF oSectionA TITLE OemToAnsi(STR0036) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "H_MAR"		OF oSectionA TITLE OemToAnsi(STR0037) SIZE TamSX3("RG7_HRS01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "S_MAR"		OF oSectionA TITLE OemToAnsi(STR0038) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "H_ABR"		OF oSectionA TITLE OemToAnsi(STR0039) SIZE TamSX3("RG7_HRS01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "S_ABR" 		OF oSectionA TITLE OemToAnsi(STR0040) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "H_MAY" 		OF oSectionA TITLE OemToAnsi(STR0041) SIZE TamSX3("RG7_HRS01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "S_MAY" 		OF oSectionA TITLE OemToAnsi(STR0042) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "H_JUN"		OF oSectionA TITLE OemToAnsi(STR0043) SIZE TamSX3("RG7_HRS01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "S_JUN" 		OF oSectionA TITLE OemToAnsi(STR0044) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "H_JUL" 		OF oSectionA TITLE OemToAnsi(STR0045) SIZE TamSX3("RG7_HRS01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "S_JUL" 		OF oSectionA TITLE OemToAnsi(STR0046) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "H_AGO" 		OF oSectionA TITLE OemToAnsi(STR0047) SIZE TamSX3("RG7_HRS01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "S_AGO" 		OF oSectionA TITLE OemToAnsi(STR0048) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT	
	DEFINE CELL NAME "H_SET" 		OF oSectionA TITLE OemToAnsi(STR0049) SIZE TamSX3("RG7_HRS01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "S_SET" 		OF oSectionA TITLE OemToAnsi(STR0050) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "H_OCT" 		OF oSectionA TITLE OemToAnsi(STR0051) SIZE TamSX3("RG7_HRS01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "S_OCT"		OF oSectionA TITLE OemToAnsi(STR0052) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "H_NOV" 		OF oSectionA TITLE OemToAnsi(STR0053) SIZE TamSX3("RG7_HRS01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "S_NOV" 		OF oSectionA TITLE OemToAnsi(STR0054) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "H_DIC" 		OF oSectionA TITLE OemToAnsi(STR0055) SIZE TamSX3("RG7_HRS01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "S_DIC" 		OF oSectionA TITLE OemToAnsi(STR0056) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "H_50" 		OF oSectionA TITLE OemToAnsi(STR0057) SIZE TamSX3("RG7_HRS01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "S_50" 		OF oSectionA TITLE OemToAnsi(STR0058) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "H_100" 		OF oSectionA TITLE OemToAnsi(STR0059) SIZE TamSX3("RG7_HRS01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "S_100" 		OF oSectionA TITLE OemToAnsi(STR0060) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "AGUINALDO" 	OF oSectionA TITLE OemToAnsi(STR0061) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "BENEFICIOS"	OF oSectionA TITLE OemToAnsi(STR0062) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "BONIFICACIONES" OF oSectionA TITLE OemToAnsi(STR0063) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "VACACIONES" 	OF oSectionA TITLE OemToAnsi(STR0064) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "TOTAL_H" 		OF oSectionA TITLE OemToAnsi(STR0065) SIZE TamSX3("RG7_HRS01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "TOTAL_S" 		OF oSectionA TITLE OemToAnsi(STR0066) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "TOTALGENERAL" OF oSectionA TITLE OemToAnsi(STR0067) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	
oSectionA:SetHeaderPage(.F.)
oSectionA:SetHeaderSection(.F.) 
oSectionA:SetHeaderBreak(.F.)			
Return oReport


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrintReportบAutor  ณLaura Medina        บFecha ณ  17/12/19   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define reporte                                              บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Print2Report(oReport,oSectionA,aReport)
Local nLoop     := 0
Local nTotal_H  := 0
Local nTotal_S  := 0
Local nTotGRAL  := 0

If Len(aReport) > 0
	oReport:StartPage()
	oReport:SetPageNumber(1)
	
	oSectionA:Init()
	oSectionA:Cell("NROPATRON"):SetTitle("")
	oSectionA:Cell("DOCUMENTO"):SetTitle("")
	oSectionA:Cell("FORMADEPAGO"):SetTitle("")
	oSectionA:Cell("IMPORTEUNITARIO"):SetTitle("")
	oSectionA:Cell("H_ENE"):SetTitle("")
	oSectionA:Cell("S_ENE"):SetTitle("")
	oSectionA:Cell("H_FEB"):SetTitle("")
	oSectionA:Cell("S_FEB"):SetTitle("")
	oSectionA:Cell("H_MAR"):SetTitle("")
	oSectionA:Cell("S_MAR"):SetTitle("")
	oSectionA:Cell("H_ABR"):SetTitle("")
	oSectionA:Cell("S_ABR"):SetTitle("")
	oSectionA:Cell("H_MAY"):SetTitle("")
	oSectionA:Cell("S_MAY"):SetTitle("")
	oSectionA:Cell("H_JUN"):SetTitle("")
	oSectionA:Cell("S_JUN"):SetTitle("")	
	oSectionA:Cell("H_JUL"):SetTitle("")
	oSectionA:Cell("S_JUL"):SetTitle("")
	oSectionA:Cell("H_AGO"):SetTitle("")
	oSectionA:Cell("S_AGO"):SetTitle("")
	oSectionA:Cell("H_SET"):SetTitle("")
	oSectionA:Cell("S_SET"):SetTitle("")
	oSectionA:Cell("H_OCT"):SetTitle("")
	oSectionA:Cell("S_OCT"):SetTitle("")
	oSectionA:Cell("H_NOV"):SetTitle("")
	oSectionA:Cell("S_NOV"):SetTitle("")
	oSectionA:Cell("H_DIC"):SetTitle("")
	oSectionA:Cell("S_DIC"):SetTitle("")
	oSectionA:Cell("H_50"):SetTitle("")
	oSectionA:Cell("S_50"):SetTitle("")
	oSectionA:Cell("H_100"):SetTitle("")
	oSectionA:Cell("S_100"):SetTitle("")
	oSectionA:Cell("AGUINALDO"):SetTitle("")
	oSectionA:Cell("BENEFICIOS"):SetTitle("")
	oSectionA:Cell("BONIFICACIONES"):SetTitle("")
	oSectionA:Cell("VACACIONES"):SetTitle("")
	oSectionA:Cell("TOTAL_H"):SetTitle("")
	oSectionA:Cell("TOTAL_S"):SetTitle("")
	oSectionA:Cell("TOTALGENERAL"):SetTitle("")
	
	oSectionA:Cell("NROPATRON"):SetValue(OemToAnsi(STR0010))
	oSectionA:Cell("DOCUMENTO"):SetValue(OemToAnsi(STR0011))
	oSectionA:Cell("FORMADEPAGO"):SetValue(OemToAnsi(STR0031))
	oSectionA:Cell("IMPORTEUNITARIO"):SetValue(OemToAnsi(STR0032))
	oSectionA:Cell("H_ENE"):SetValue(OemToAnsi(STR0033))
	oSectionA:Cell("S_ENE"):SetValue(OemToAnsi(STR0034))
	oSectionA:Cell("H_FEB"):SetValue(OemToAnsi(STR0035))
	oSectionA:Cell("S_FEB"):SetValue(OemToAnsi(STR0036))
	oSectionA:Cell("H_MAR"):SetValue(OemToAnsi(STR0037))
	oSectionA:Cell("S_MAR"):SetValue(OemToAnsi(STR0038))
	oSectionA:Cell("H_ABR"):SetValue(OemToAnsi(STR0039))
	oSectionA:Cell("S_ABR"):SetValue(OemToAnsi(STR0040))
	oSectionA:Cell("H_MAY"):SetValue(OemToAnsi(STR0041))
	oSectionA:Cell("S_MAY"):SetValue(OemToAnsi(STR0042))
	oSectionA:Cell("H_JUN"):SetValue(OemToAnsi(STR0043))
	oSectionA:Cell("S_JUN"):SetValue(OemToAnsi(STR0044))
	oSectionA:Cell("H_JUL"):SetValue(OemToAnsi(STR0045))
	oSectionA:Cell("S_JUL"):SetValue(OemToAnsi(STR0046))
	oSectionA:Cell("H_AGO"):SetValue(OemToAnsi(STR0047))
	oSectionA:Cell("S_AGO"):SetValue(OemToAnsi(STR0048))
	oSectionA:Cell("H_SET"):SetValue(OemToAnsi(STR0049))
	oSectionA:Cell("S_SET"):SetValue(OemToAnsi(STR0050))
	oSectionA:Cell("H_OCT"):SetValue(OemToAnsi(STR0051))
	oSectionA:Cell("S_OCT"):SetValue(OemToAnsi(STR0052))
	oSectionA:Cell("H_NOV"):SetValue(OemToAnsi(STR0053))
	oSectionA:Cell("S_NOV"):SetValue(OemToAnsi(STR0054))
	oSectionA:Cell("H_DIC"):SetValue(OemToAnsi(STR0055))
	oSectionA:Cell("S_DIC"):SetValue(OemToAnsi(STR0056))
	oSectionA:Cell("H_50"):SetValue(OemToAnsi(STR0057))
	oSectionA:Cell("S_50"):SetValue(OemToAnsi(STR0058))
	oSectionA:Cell("H_100"):SetValue(OemToAnsi(STR0059))
	oSectionA:Cell("S_100"):SetValue(OemToAnsi(STR0060))
	oSectionA:Cell("AGUINALDO"):SetValue(OemToAnsi(STR0061))
	oSectionA:Cell("BENEFICIOS"):SetValue(OemToAnsi(STR0062))
	oSectionA:Cell("BONIFICACIONES"):SetValue(OemToAnsi(STR0063))
	oSectionA:Cell("VACACIONES"):SetValue(OemToAnsi(STR0064))
	oSectionA:Cell("TOTAL_H"):SetValue(OemToAnsi(STR0065))
	oSectionA:Cell("TOTAL_S"):SetValue(OemToAnsi(STR0066))
	oSectionA:Cell("TOTALGENERAL"):SetValue(OemToAnsi(STR0067))

	oSectionA:PrintLine()
	oReport:ThinLine()	
Endif 
	

For  nLoop:=1 to Len(aReport)
	If  oReport:Cancel()
		Exit
	EndIf

	nTotal_H  := aReport[nLoop,5] + aReport[nLoop,7]   + aReport[nLoop,9]  + aReport[nLoop,11] + aReport[nLoop,13] + aReport[nLoop,15] +;
				 aReport[nLoop,17] + aReport[nLoop,19] + aReport[nLoop,21] + aReport[nLoop,23] + aReport[nLoop,25] + aReport[nLoop,27] + ;
				 aReport[nLoop,29] + aReport[nLoop,31]
	nTotal_S  := aReport[nLoop,6] + aReport[nLoop,8]   + aReport[nLoop,10] + aReport[nLoop,12] + aReport[nLoop,14] + aReport[nLoop,16] +;
				 aReport[nLoop,18] + aReport[nLoop,20] + aReport[nLoop,22] + aReport[nLoop,24] + aReport[nLoop,26] + aReport[nLoop,28] + ;
				 aReport[nLoop,30] + aReport[nLoop,32]
	nTotGRAL  := nTotal_S + aReport[nLoop,33] + aReport[nLoop,34] + aReport[nLoop,35] + aReport[nLoop,36]
	
	oSectionA:Cell("NROPATRON"):SetValue(aReport[nLoop,1])
	oSectionA:Cell("DOCUMENTO"):SetValue(aReport[nLoop,2]) 
	oSectionA:Cell("FORMADEPAGO"):SetValue(aReport[nLoop,3])
	oSectionA:Cell("IMPORTEUNITARIO"):SetValue(aReport[nLoop,4])
	oSectionA:Cell("H_ENE"):SetValue(aReport[nLoop,5])		
	oSectionA:Cell("S_ENE"):SetValue(aReport[nLoop,6])
	oSectionA:Cell("H_FEB"):SetValue(aReport[nLoop,7])
	oSectionA:Cell("S_FEB"):SetValue(aReport[nLoop,8])
	oSectionA:Cell("H_MAR"):SetValue(aReport[nLoop,9])
	oSectionA:Cell("S_MAR"):SetValue(aReport[nLoop,10]) 
	oSectionA:Cell("H_ABR"):SetValue(aReport[nLoop,11])
	oSectionA:Cell("S_ABR"):SetValue(aReport[nLoop,12])		
	oSectionA:Cell("H_MAY"):SetValue(aReport[nLoop,13])
	oSectionA:Cell("S_MAY"):SetValue(aReport[nLoop,14])
	oSectionA:Cell("H_JUN"):SetValue(aReport[nLoop,15])
	oSectionA:Cell("S_JUN"):SetValue(aReport[nLoop,16])
	oSectionA:Cell("H_JUL"):SetValue(aReport[nLoop,17]) 
	oSectionA:Cell("S_JUL"):SetValue(aReport[nLoop,18])
	oSectionA:Cell("H_AGO"):SetValue(aReport[nLoop,19])
	oSectionA:Cell("S_AGO"):SetValue(aReport[nLoop,20])	
	oSectionA:Cell("H_SET"):SetValue(aReport[nLoop,21])
	oSectionA:Cell("S_SET"):SetValue(aReport[nLoop,22]) 
	oSectionA:Cell("H_OCT"):SetValue(aReport[nLoop,23])
	oSectionA:Cell("S_OCT"):SetValue(aReport[nLoop,24])
	oSectionA:Cell("H_NOV"):SetValue(aReport[nLoop,25])
	oSectionA:Cell("S_NOV"):SetValue(aReport[nLoop,26]) 
	oSectionA:Cell("H_DIC"):SetValue(aReport[nLoop,27])
	oSectionA:Cell("S_DIC"):SetValue(aReport[nLoop,28])
	oSectionA:Cell("H_50"):SetValue(aReport[nLoop,29])
	oSectionA:Cell("S_50"):SetValue(aReport[nLoop,30]) 
	oSectionA:Cell("H_100"):SetValue(aReport[nLoop,31])
	oSectionA:Cell("S_100"):SetValue(aReport[nLoop,32])	
	oSectionA:Cell("AGUINALDO"):SetValue(aReport[nLoop,33])
	oSectionA:Cell("BENEFICIOS"):SetValue(aReport[nLoop,34]) 
	oSectionA:Cell("BONIFICACIONES"):SetValue(aReport[nLoop,35])
	oSectionA:Cell("VACACIONES"):SetValue(aReport[nLoop,36])
	oSectionA:Cell("TOTAL_H"):SetValue(nTotal_H)
	oSectionA:Cell("TOTAL_S"):SetValue(nTotal_S) 
	oSectionA:Cell("TOTALGENERAL"):SetValue(nTotGRAL)

	oSectionA:PrintLine()
Next 
oReport:ThinLine()

oReport:EndPage()
oReport:EndReport()

Return


//***PLANILLA 3- Resumen General de Personas Ocupadas*****************************************

/*
ฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟ
ณFuno    ณ GerGralPO  		ณAutorณ  Laura M.     ณ Data ณ18/12/2019ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤด
ณDescrio ณ Planilla de Empleados y Obreros.                           ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณSintaxe   ณ< Vide Parametros Formais >									ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณ Uso      ณGPEM053                                                     ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณ Retorno  ณa    														ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณParametrosณ< Vide Parametros Formais >									ณ
ภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Static Function GerGralPO() 
Local aArea		  := GetArea()

aGralPO  := {} 
nLastRec3:= 0  

AgregaEyS("1") 

If  Len(aGralPO)>0
	AgregaIyH("2")
	AgregaIyH("3")
	AgregaEyS("4")
	AgregaEyS("5")	
Endif
 
If  Len(aGralPO) > 0 
	oReport:= Report3Def(aGralPO)
	oReport:PrintDialog()
ElseIf  nArchivo !=4 
	Aviso(STR0003, STR0030 , {STR0002} ) //Atencao, "No existen registros con esos parแmetros.", {OK}
Endif

RestArea(aArea)   
Return(.T.)


/*
ฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟ
ณFuno    ณ AgregaIyH  		ณAutorณ  Laura M.     ณ Data ณ19/12/2019ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤด
ณDescrio ณ Planilla General de Personas Ocupadas                      ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณSintaxe   ณ< Vide Parametros Formais >									ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณ Uso      ณGPEM053                                                     ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณ Retorno  ณa    														ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณParametrosณ< Vide Parametros Formais >									ณ
ภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Static Function AgregaIyH(nOpc) 
Local aArea		  := GetArea()
Local cQuery	  := ""	                         
Local cAliasSRA   := GetNextAlias()
Local nCont       := 0
Local nI          := 0
Local cMesAno     := Alltrim(Str(nMes))+ Alltrim(Str(nAno))
Local nHSupJfeM   := 0 
Local nHSupJfeF   := 0 
Local nHEmpleaM   := 0 
Local nHEmpleaF   := 0
Local nHObreroM   := 0
Local nHObreroF   := 0    
Local nHMenoreM   := 0
Local nHMenoreF   := 0
Local nSigno      := 0   
Local cCodFolHT   := "0638" 

If nOpc == "2"  //2. Total de horas trabajadas
	cQuery := "SELECT RA_TEIMSS, RA_SEXO, RV_TIPOCOD, SUM(RG7_HRS01) + SUM(RG7_HRS02) + SUM(RG7_HRS03) + SUM(RG7_HRS04) + SUM(RG7_HRS05) + SUM(RG7_HRS06) + SUM(RG7_HRS07) + SUM(RG7_HRS08) + SUM(RG7_HRS09) + SUM(RG7_HRS10) + SUM(RG7_HRS11) + SUM(RG7_HRS12) AS HRSTRAB "	
Elseif nOpc == "3"  //3. Total de Importe percibido  
	cQuery := "SELECT RA_TEIMSS, RA_SEXO, RV_TIPOCOD, SUM(RG7_ACUM01) + SUM(RG7_ACUM02) + SUM(RG7_ACUM03) + SUM(RG7_ACUM04) + SUM(RG7_ACUM05) +  SUM(RG7_ACUM06) +  "
	cQuery += "SUM(RG7_ACUM07) + SUM(RG7_ACUM08) + SUM(RG7_ACUM09) + SUM(RG7_ACUM10)+ SUM(RG7_ACUM11) + SUM(RG7_ACUM12) AS HRSTRAB"
Endif
    cQuery += "FROM "+RetSqlName("SRA")+" SRA, "+RetSqlName("RG7")+" RG7, "+RetSqlName("SRV")+" SRV "						
	cQuery += "WHERE RA_MAT = RG7_MAT AND RA_FILIAL = RG7_FILIAL "
If  nOpc == "2"
	cQuery += "AND RG7_PD = RV_COD  AND RV_CODFOL = '"+ cCodFolHT +"'  "
Elseif nOpc == "3"
	cQuery += "AND RG7_PD = RV_COD  AND RV_INCORP <> '0'   "
Endif

	cQuery += "AND RG7_ANOINI = '"+ Alltrim(Str(nAno)) +"' "
	cQuery += "AND RA_REGISTR = '"+ cNumPat +"'  AND "
	    	
	//-- Activos (RA_SITFOLH <> 'D')
	cQuery += "(( RA_SITFOLH <> 'D' AND "
	cQuery += 	"MONTH(RA_ADMISSA)+YEAR(RA_ADMISSA) <= '"+ cMesAno +"' ) OR "
	//-- Inactivos (RA_SITFOLH == 'D')
	cQuery += "( RA_SITFOLH = 'D' AND "
	cQuery += 	"YEAR(RA_DEMISSA) = '"+ Alltrim(Str(nAno)) +"' AND "
	cQuery += 	"MONTH(RA_DEMISSA) <= '"+ Alltrim(Str(nMes)) +"' ) )"
	cQuery += "AND RA_FILIAL = '"+xFilial("SRA")+"' "
	cQuery += "AND RV_FILIAL = '"+xFilial("SRV")+"' "
	cQuery += "AND SRA.D_E_L_E_T_ <>'*' "
	cQuery += "AND SRV.D_E_L_E_T_ <>'*' " 
	cQuery += "AND RG7.D_E_L_E_T_ <>'*' " 
	cQuery += "GROUP BY RA_TEIMSS, RA_SEXO, RV_TIPOCOD"
	cQuery += "ORDER BY RA_TEIMSS, RA_SEXO, RV_TIPOCOD "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRA,.T.,.T.)
	
	Count to nCont
	(cAliasSRA)->(dbGoTop())
	
	ProcRegua(nCont) 
	While (cAliasSRA)->(!EOF())     
		nI++
	   	IncProc(STR0005 + STR0008 + str(nI)) //"Procesando... " "Planilla de Resumen General de Personas Ocupadas"
	   	If  nOpc == "2"
	   		nSigno  := Iif((cAliasSRA)->RV_TIPOCOD $ "1|3", 1, Iif((cAliasSRA)->RV_TIPOCOD $ "2|4", -1 , 0) )
	   	Elseif nOpc == "3"
	   		nSigno  := Iif((cAliasSRA)->RV_TIPOCOD $ "1", 1, Iif((cAliasSRA)->RV_TIPOCOD $ "2", -1 , 0) ) 
	   	Endif 
	   	//RA_TEIMSS == 1 
		If  (cAliasSRA)->RA_TEIMSS == "1" .AND. (cAliasSRA)->RA_SEXO == "M"		
			nHSupJfeM    := nHSupJfeM + (nSigno * (cAliasSRA)->HRSTRAB)
		Endif
		If  (cAliasSRA)->RA_TEIMSS == "1" .AND. (cAliasSRA)->RA_SEXO == "F"
			nHSupJfeF    := nHSupJfeF + (nSigno * (cAliasSRA)->HRSTRAB)
		Endif	
		//RA_TEIMSS == 2
		If  (cAliasSRA)->RA_TEIMSS == "2" .AND. (cAliasSRA)->RA_SEXO == "M"
			nHEmpleaM    := nHEmpleaM + (nSigno * (cAliasSRA)->HRSTRAB)
		Endif
		If  (cAliasSRA)->RA_TEIMSS == "2" .AND. (cAliasSRA)->RA_SEXO == "F"
			nHEmpleaF    := nHEmpleaF + (nSigno * (cAliasSRA)->HRSTRAB)
		Endif
		//RA_TEIMSS == 3
		If  (cAliasSRA)->RA_TEIMSS == "3" .AND. (cAliasSRA)->RA_SEXO == "M"
			nHObreroM    := nHObreroM + (nSigno * (cAliasSRA)->HRSTRAB)
		Endif
		If  (cAliasSRA)->RA_TEIMSS == "3" .AND. (cAliasSRA)->RA_SEXO == "F"
			nHObreroF    := nHObreroF + (nSigno * (cAliasSRA)->HRSTRAB)
		Endif
		//RA_TEIMSS == 4
		If  (cAliasSRA)->RA_TEIMSS == "4" .AND. (cAliasSRA)->RA_SEXO == "M"
			nHMenoreM    := nHMenoreM + (nSigno * (cAliasSRA)->HRSTRAB)
		Endif
		If  (cAliasSRA)->RA_TEIMSS == "4" .AND. (cAliasSRA)->RA_SEXO == "F"
			nHMenoreF    := nHMenoreF + (nSigno * (cAliasSRA)->HRSTRAB)
		Endif 	
	   	(cAliasSRA)->(dbSkip())	    
	EndDo
	If  Len(aGralPO) > 0 
		nLastRec3 := (cAliasSRA)->(LastRec())
	EndIf	
	(cAliasSRA)->(dbCloseArea()) 
	
	Aadd(aGralPO,{cNumPat,nAno,nHSupJfeM,nHSupJfeF,nHEmpleaM,nHEmpleaF,nHObreroM,nHObreroF,nHMenoreM,nHMenoreF,nOpc})

	
RestArea(aArea)  
Return 



/*
ฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟ
ณFuno    ณ AgregaEyS  		ณAutorณ  Laura M.     ณ Data ณ19/12/2019ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤด
ณDescrio ณ Planilla General de Personas Ocupadas                      ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณSintaxe   ณ< Vide Parametros Formais >									ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณ Uso      ณGPEM053                                                     ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณ Retorno  ณa    														ณ
รฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
ณParametrosณ< Vide Parametros Formais >									ณ
ภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Static Function AgregaEyS(nOpc) 
Local aArea		  := GetArea()
Local cQuery	  := ""	                         
Local cAliasSRA   := GetNextAlias()
Local nCont       := 0
Local nI          := 0
Local cMesAno     := Alltrim(Str(nMes))+ Alltrim(Str(nAno))
Local nHSupJfeM   := 0 
Local nHSupJfeF   := 0 
Local nHEmpleaM   := 0 
Local nHEmpleaF   := 0
Local nHObreroM   := 0
Local nHObreroF   := 0    
Local nHMenoreM   := 0
Local nHMenoreF   := 0   
Local lInserta    := .F. 

//4. Cantidad de Entradas y 5. Cantidad de Salidas
cQuery := "SELECT RA_TEIMSS, RA_SEXO, COUNT(*) AS ENTRADAS "
cQuery += "FROM "+RetSqlName("SRA")+" SRA "					
cQuery += "WHERE "    
If  nOpc == "1"
	//-- Activos (RA_SITFOLH <> 'D')
	cQuery += "(( RA_SITFOLH <> 'D' AND "
	cQuery += 	"MONTH(RA_ADMISSA)+YEAR(RA_ADMISSA) <= '"+ cMesAno +"' ) OR "
Endif
If  nOpc $ "1|5"
	If  nOpc == "5"
		cQuery += "( "
	Endif
	cQuery += "( RA_SITFOLH = 'D' AND "
	cQuery += 	"YEAR(RA_DEMISSA) = '"+ Alltrim(Str(nAno)) +"' AND "
	cQuery += 	"MONTH(RA_DEMISSA) <= '"+ Alltrim(Str(nMes)) +"' ) )"	
Endif
If   nOpc == "4"
	cQuery += 	"( YEAR(RA_ADMISSA) = '"+ Alltrim(Str(nAno)) +"' AND "
	cQuery += 	"MONTH(RA_ADMISSA) <= '"+ Alltrim(Str(nMes)) +"' ) "
Endif

cQuery += "AND RA_REGISTR = '"+ cNumPat +"'  "
cQuery += "AND D_E_L_E_T_<>'*' " 
cQuery += "AND RA_FILIAL = '"+xFilial("SRA")+"' "
cQuery += "GROUP BY RA_TEIMSS, RA_SEXO "
cQuery += "ORDER BY RA_TEIMSS, RA_SEXO "
	
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRA,.T.,.T.)
	
Count to nCont
(cAliasSRA)->(dbGoTop())
	       
ProcRegua(nCont) 

While (cAliasSRA)->(!EOF())     
	nI++
   	IncProc(STR0005 + STR0008 + str(nI)) //"Procesando... " "Planilla de Resumen General de Personas Ocupadas"
		   	
	//RA_TEIMSS == 1 
	If  (cAliasSRA)->RA_TEIMSS == "1" .AND. (cAliasSRA)->RA_SEXO == "M"
		nHSupJfeM    += (cAliasSRA)->ENTRADAS
	Endif
	If  (cAliasSRA)->RA_TEIMSS == "1" .AND. (cAliasSRA)->RA_SEXO == "F"
		nHSupJfeF    += (cAliasSRA)->ENTRADAS
	Endif	
	//RA_TEIMSS == 2
	If  (cAliasSRA)->RA_TEIMSS == "2" .AND. (cAliasSRA)->RA_SEXO == "M"
		nHEmpleaM    += (cAliasSRA)->ENTRADAS
	Endif
	If  (cAliasSRA)->RA_TEIMSS == "2" .AND. (cAliasSRA)->RA_SEXO == "F"
		nHEmpleaF    += (cAliasSRA)->ENTRADAS
	Endif
	//RA_TEIMSS == 3
	If  (cAliasSRA)->RA_TEIMSS == "3" .AND. (cAliasSRA)->RA_SEXO == "M"
		nHObreroM    += (cAliasSRA)->ENTRADAS
	Endif
	If  (cAliasSRA)->RA_TEIMSS == "3" .AND. (cAliasSRA)->RA_SEXO == "F"
		nHObreroF    += (cAliasSRA)->ENTRADAS
	Endif
	//RA_TEIMSS == 4
	If  (cAliasSRA)->RA_TEIMSS == "4" .AND. (cAliasSRA)->RA_SEXO == "M"
		nHMenoreM    += (cAliasSRA)->ENTRADAS
	Endif
	If  (cAliasSRA)->RA_TEIMSS == "4" .AND. (cAliasSRA)->RA_SEXO == "F"
		nHMenoreF    += (cAliasSRA)->ENTRADAS
	Endif 
	
   	(cAliasSRA)->(dbSkip())	    
EndDo
(cAliasSRA)->(dbCloseArea()) 

If 	nOpc $ "4|5" .Or. (nOpc == "1" .And. (nHSupJfeM>0 .OR. nHSupJfeF>0 .OR. nHEmpleaM>0 .OR. nHEmpleaF>0 .OR. nHObreroM>0 .OR. nHObreroF>0 .OR. nHMenoreM>0 .OR. nHMenoreF>0 ) ) 
	lInserta := .T. 
Endif

If lInserta
	Aadd(aGralPO,{cNumPat,nAno,nHSupJfeM,nHSupJfeF,nHEmpleaM,nHEmpleaF,nHObreroM,nHObreroF,nHMenoreM,nHMenoreF,nOpc})
Endif
	
RestArea(aArea)  
Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReport3Def บAutor  ณLaura Medina        บFecha ณ  17/12/19   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define reporte                                              บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Report3Def(aReport)
Local oReport
Local oSectionA
Local cNomeProg := "3-Planilla Resumen Gral"
Local cTitulo   := STR0008

DEFINE REPORT oReport NAME cNomeProg TITLE cTitulo PARAMETER ""/*cPerg2*/ ACTION {|oReport| Print3Report(oReport,oSectionA,aReport) } DESCRIPTION STR0008 //"Planilla de Resumen General de Personas Ocupadas"
oReport:SetTotalInLine(.T.)
oReport:SetLandscape(.T.)
oReport:lHeaderVisible := .T.
oReport:lParampage := .F.  	
oReport:lHeaderVisible := .F.
oReport:lFooterVisible := .F.

oReport:SetMeter(nLastRec3)        

DEFINE SECTION oSectionA OF oReport TITLE OemToAnsi(STR0006) TABLES "SRA" //"Planilla de Empleados y Obreros"
	DEFINE CELL NAME "NROPATRON"	OF oSectionA TITLE OemToAnsi(STR0010) SIZE TamSX3("RA_REGISTR")[1] HEADER ALIGN LEFT 	
	DEFINE CELL NAME "NANO" 		OF oSectionA TITLE OemToAnsi(STR0068) SIZE 10 HEADER ALIGN LEFT
	DEFINE CELL NAME "NHSUPJFEM"	OF oSectionA TITLE OemToAnsi(STR0069) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "NHSUPJFEF"	OF oSectionA TITLE OemToAnsi(STR0070) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "NHEMPLEAM"	OF oSectionA TITLE OemToAnsi(STR0071) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "NHEMPLEAF"	OF oSectionA TITLE OemToAnsi(STR0072) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT	
	DEFINE CELL NAME "NHOBREROM"	OF oSectionA TITLE OemToAnsi(STR0073) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT	
	DEFINE CELL NAME "NHOBREROF"	OF oSectionA TITLE OemToAnsi(STR0074) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "NHMENOREM"	OF oSectionA TITLE OemToAnsi(STR0075) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "NHMENOREF"	OF oSectionA TITLE OemToAnsi(STR0076) SIZE TamSX3("RG7_ACUM01")[1]+5 HEADER ALIGN LEFT
	DEFINE CELL NAME "ORDEN" 		OF oSectionA TITLE OemToAnsi(STR0077) SIZE 10 HEADER ALIGN LEFT
		
oSectionA:SetHeaderPage(.F.)
oSectionA:SetHeaderSection(.F.) 
oSectionA:SetHeaderBreak(.F.)			
Return oReport


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrint2ReportบAutor  ณLaura Medina        บFecha ณ  17/12/19  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define reporte                                              บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Print3Report(oReport,oSectionA,aReport)
Local nLoop     := 0

If Len(aReport) > 0
	oReport:StartPage()
	oReport:SetPageNumber(1)
	
	oSectionA:Init()
	oSectionA:Cell("NROPATRON"):SetTitle("")
	oSectionA:Cell("NANO"):SetTitle("")
	oSectionA:Cell("NHSUPJFEM"):SetTitle("")
	oSectionA:Cell("NHSUPJFEF"):SetTitle("")
	oSectionA:Cell("NHEMPLEAM"):SetTitle("")
	oSectionA:Cell("NHEMPLEAF"):SetTitle("")
	oSectionA:Cell("NHOBREROM"):SetTitle("")
	oSectionA:Cell("NHOBREROF"):SetTitle("")
	oSectionA:Cell("NHMENOREM"):SetTitle("")
	oSectionA:Cell("NHMENOREF"):SetTitle("")
	oSectionA:Cell("ORDEN"):SetTitle("")

	oSectionA:Cell("NROPATRON"):SetValue(OemToAnsi(STR0010))
	oSectionA:Cell("NANO"):SetValue(OemToAnsi(STR0068))
	oSectionA:Cell("NHSUPJFEM"):SetValue(OemToAnsi(STR0069))
	oSectionA:Cell("NHSUPJFEF"):SetValue(OemToAnsi(STR0070))
	oSectionA:Cell("NHEMPLEAM"):SetValue(OemToAnsi(STR0071))
	oSectionA:Cell("NHEMPLEAF"):SetValue(OemToAnsi(STR0072))
	oSectionA:Cell("NHOBREROM"):SetValue(OemToAnsi(STR0073))
	oSectionA:Cell("NHOBREROF"):SetValue(OemToAnsi(STR0074))
	oSectionA:Cell("NHMENOREM"):SetValue(OemToAnsi(STR0075))
	oSectionA:Cell("NHMENOREF"):SetValue(OemToAnsi(STR0076))
	oSectionA:Cell("ORDEN"):SetValue(OemToAnsi(STR0077))

	oSectionA:PrintLine()
	oReport:ThinLine()	
Endif 

For  nLoop:=1 to Len(aReport)
	If  oReport:Cancel()
		Exit
	EndIf
	oSectionA:Cell("NROPATRON"):SetValue(aReport[nLoop,1])
	oSectionA:Cell("NANO"):SetValue(aReport[nLoop,2]) 
	oSectionA:Cell("NHSUPJFEM"):SetValue(ROUND(aReport[nLoop,3],0))
	oSectionA:Cell("NHSUPJFEF"):SetValue(ROUND(aReport[nLoop,4],0))
	oSectionA:Cell("NHEMPLEAM"):SetValue(ROUND(aReport[nLoop,5],0))		
	oSectionA:Cell("NHEMPLEAF"):SetValue(ROUND(aReport[nLoop,6],0))
	oSectionA:Cell("NHOBREROM"):SetValue(ROUND(aReport[nLoop,7],0))
	oSectionA:Cell("NHOBREROF"):SetValue(ROUND(aReport[nLoop,8],0))
	oSectionA:Cell("NHMENOREM"):SetValue(ROUND(aReport[nLoop,9],0))
	oSectionA:Cell("NHMENOREF"):SetValue(ROUND(aReport[nLoop,10],0)) 
	oSectionA:Cell("ORDEN"):SetValue(aReport[nLoop,11])

	oSectionA:PrintLine()
Next 
oReport:ThinLine()

oReport:EndPage()
oReport:EndReport()

Return
 
