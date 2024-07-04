#INCLUDE "PROTHEUS.CH"  
#INCLUDE "GPER003DOM.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GPER003DOM³ Autor ³  FMonroy                      ³ Data ³ 12/07/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reporte DGT 5                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER863()                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³      FNC      ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Christiane V³06/02/12³0000018891/2011³ Correção do error log                     ³±±
±±³Christiane V³07/02/12³0000018891/2011³ Impressão da data de admissão             ³±±
±±³            ³        ³               ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


Function GPER003DOM() 
 
    Local cPerg      :="GPR003DOM"   
    Local oReport 
	Local aGetArea   := GetArea()
	
	Private cNomeProg :="GPER003DOM"
	Private cAliasSRA:=criatrab(nil,.f.)
	Private cSucI	:=	""
	Private cSucF	:=	""
	Private cProI	:=	""
	Private cProF	:=	""
	Private cMatI	:=	""
	Private cMatF	:=	""
	Private cObser	:=	""
	Private cMes	:=	""
	Private cAnio	:=	""
	
	Private nMesA	:=	0
	Private nLin	:=  38

	Pergunte(cPerg,.F.)
	
	oReport:=ReportDef(cPerg)  
	oReport:PrintDialog() 

	RestArea(aGetArea)	
	
Return ( Nil )   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ReportDef   Autor ³ FMonroy               ³ Data ³29/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  Def. Reporte DGT 5.                                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ReportDef(cExp1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp1.-Nombre de la pregunta                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER863                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef(cPerg) 
	
Local aArea      := GetArea() 

Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oSection4
Local oSection5
Local oSection6 

Private cTitulo	:=OEMTOANSI(STR0078)//"Reporte DGT 5" 
 
cTitulo := Trim(cTitulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:=TReport():New(cNomeProg,OemToAnsi(cTitulo), cPerg  ,{|oReport| PrintReport(oReport)})	
oReport:nColSpace:= 0
oReport:nFontBody	:= 5 // Define o tamanho da fonte.
oReport:CFONTBODY:="COURIER NEW"
oReport:Setlandscape(.T.)//Pag Horizontal  
oReport:lHeaderVisible:=.f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Creación de la Primera Sección:  Encabezado                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

oSection1:= TRSection():New(oReport,/*"Enc"*/,,,/*Campos do SX3*/,/*Campos do SIX*/)
oSection1:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection1:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao
oSection1:SetLeftMargin(3)

TRCell():New(oSection1,"TITLE"   ,, ,,/*Tamañano de la hoja*/)//"Atención"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Creación de la Segunda Sección:  Encabezado 2                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection2:= TRSection():New(oReport,/*"Enc"*/,,,/*Campos do SX3*/,/*Campos do SIX*/)
oSection2:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection2:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao
oSection2:SetLeftMargin(3)

TRCell():New(oSection2,"TITLE1"   ,, ,,)
TRCell():New(oSection2,"TITLE2"   ,, ,,)
TRCell():New(oSection2,"TITLE3"   ,, ,,)     

oSection1:nLinesBefore:=0
oSection2:nLinesBefore:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Creación de la Tercera Sección:  Encabezado 3                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection3:= TRSection():New(oReport,/*"Enc"*/,,,/*Campos do SX3*/,/*Campos do SIX*/)
oSection3:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection3:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao
oSection3:SetLeftMargin(3)

TRCell():New(oSection3,"DI1"   ,, ,,70)
TRCell():New(oSection3,"DI2"   ,, ,,20)
TRCell():New(oSection3,"DI3"   ,, ,,70)     
TRCell():New(oSection3,"DI4"   ,, ,,20)     

oSection3:nLinesBefore:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Creación de la Cuarta Sección:  Encabezado del Detalle 4                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection4:= TRSection():New(oReport,/*"Enc"*/,,,/*Campos do SX3*/,/*Campos do SIX*/)
oSection4:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection4:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao
oSection4:SetLeftMargin(3)
oSection4:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor


TRCell():New(oSection4,"No",			,  , 		   ,3)	
TRCell():New(oSection4,"Nombre",		,  , 		   ,TamSx3("RA_NOME")[1])
TRCell():New(oSection4,"Cedula",		,  , 		   ,TamSx3("RA_CIC")[1])
TRCell():New(oSection4,"FechaN",	    ,  ,           ,10)
TRCell():New(oSection4,"SDSS",	        ,  ,           ,12)
TRCell():New(oSection4,"M" ,			,  ,           ,2)
TRCell():New(oSection4,"F" ,			,  , 	       ,2)
TRCell():New(oSection4,"Nacionalidad",  ,  ,		   ,12)
TRCell():New(oSection4,"Ocupacion",	    ,  ,		   ,TamSx3("RJ_DESC")[1])
TRCell():New(oSection4,"Ent",		,  , 		       ,7)	
TRCell():New(oSection4,"TurnoHorario", ,  ,		       ,TamSx3("RA_TNOTRAB")[1])
TRCell():New(oSection4,"DiasT",			,  ,		   ,12)
TRCell():New(oSection4,"SalD",	    ,  ,               ,17)
					
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Creación de la Quinta Sección: Detalle 5                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection5:=TRSection():New(oReport,/*"Enc"*/,,,/*Campos do SX3*/,/*Campos do SIX*/)
oSection5:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection5:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao
oSection5:SetLeftMargin(3)
oSection5:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
	
TRCell():New(oSection5,"No",			,  , 		   ,3)	
TRCell():New(oSection5,"Nombre",		,  , 		   ,TamSx3("RA_NOME")[1])
TRCell():New(oSection5,"Cedula",		,  , 		   ,TamSx3("RA_CIC")[1])
TRCell():New(oSection5,"FechaN",	    ,  ,           ,10)
TRCell():New(oSection5,"SDSS",	        ,  ,           ,12)
TRCell():New(oSection5,"M" ,			,  ,           ,2)
TRCell():New(oSection5,"F" ,			,  , 	       ,2)
TRCell():New(oSection5,"Nacionalidad",  ,  ,		   ,12)
TRCell():New(oSection5,"Ocupacion",	    ,  ,		   ,TamSx3("RJ_DESC")[1])
TRCell():New(oSection5,"Ent",		,   , 		       ,7)	
TRCell():New(oSection5,"TurnoHorario",  ,  ,		   ,TamSx3("RA_TNOTRAB")[1])
TRCell():New(oSection5,"DiasT",			,  ,"999,999,999.99"    ,12)
TRCell():New(oSection5,"SalD",	        ,  ,"999,999,999,999.99",17)
						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Creación de la Sexta Sección:  Firmas                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection6:= TRSection():New(oReport,/*"Enc"*/,,,/*Campos do SX3*/,/*Campos do SIX*/)
oSection6:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection6:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao
oSection6:SetLeftMargin(3)

TRCell():New(oSection6,"FIR1"   ,, ,,60)
TRCell():New(oSection6,"FIR2"   ,, ,,10)
TRCell():New(oSection6,"FIR3"   ,, ,,29)    
TRCell():New(oSection6,"FIR4"   ,, ,,60)    
	
oSection1:nLinesBefore:=0
oSection2:nLinesBefore:=0	
oSection3:nLinesBefore:=0	
oSection4:nLinesBefore:=0	
oSection5:nLinesBefore:=0	
oSection6:nLinesBefore:=0	
			
Return ( oReport )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PrintReport Autor ³ FMonroy               ³ Data ³29/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³   Impresión del Informe                                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³    PrintReport(oExp1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  oExp1.-Objeto del reporte                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER863                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrintReport(oReport) 

Local oSection5  := oReport:Section(5)

Local cTitle	 := 	""     
Local cFilPro    :=  	""
Local cSelect    :=		""
Local cFilSRV    := xFilial( "SRV", RG7->RG7_FILIAL)
Local cRj_desc	 :=		""
Local nTotal     :=  0                                 
Local nI:=0  
Local nX		 := 0      
Local aStruSRA	 := {}                                  

TodoOk()
Pergunte(oReport:GetParam(),.F.)                        

aStruSRA := SRA->( dbStruct() )

#IFDEF TOP
			
	cSelect :="%"
	cSelect +="  SRA.RA_FILIAL,RG7.RG7_PROCES, RG7.RG7_MAT,SRA.RA_NACIONA,SRA.RA_NASC,SRA.RA_SEXO,SRA.RA_NOME,SRA.RA_CIC,SRA.RA_NSEGURO,"
	cSelect +=" SRA.RA_CODFUNC,SRA.RA_ADMISSA,SRA.RA_TNOTRAB,RV_COD,SRA.RA_NACIONA,RG7.RG7_ACUM"+cMes+" ACUM,RG7.RG7_HRS"+cMes+" HRS"
	cSelect +="%"

	cFILPRO :=  "%"    
	CFILPRO += " SRA.RA_TIPOADM ='0002' "
	CFILPRO += " AND SRV.RV_CODFOL='0047' "
	CFILPRO += " AND RG7.RG7_CODCRI='01' "
	CFILPRO += " AND SUBSTRING(SRA.RA_ADMISSA, 1, 6)='"	+ cAnio +cMes+"' "
	CFILPRO += " AND RG7.RG7_FILIAL BETWEEN '"+ cSucI + "' AND '"+ cSucF+"'"
	CFILPRO += " AND RG7.RG7_PROCES BETWEEN '"+ cProI + "' AND '"+ cProF+"'"
	CFILPRO += " AND RG7.RG7_MAT BETWEEN '"	+ cMatI + "' AND '"+ cMatF+"'"
	CFILPRO += " AND RG7.RG7_ANOINI= '"	+cAnio+"'"
	cFILPRO += " %"    
	
	BeginSql alias cAliasSRA
	
	
		SELECT	%exp:cSelect% 			
		FROM %table:RG7% RG7    
		INNER JOIN  %table:SRA% SRA 
	    ON  SRA.RA_FILIAL  = RG7.RG7_FILIAL AND
			SRA.RA_MAT     = RG7.RG7_MAT
		INNER JOIN 	%table:SRV% SRV
		ON		SRV.RV_FILIAL = %exp:cFilSRV%	AND
				SRV.RV_COD    = RG7.RG7_PD	   
		WHERE	
				%exp:cFilPro% 
				AND  SRA.%notDel% 
				AND  RG7.%notDel%  
				AND  SRV.%notDel%  
				 
	  ORDER BY SRA.RA_FILIAL,RG7.RG7_PROCES, RG7.RG7_MAT
		
	EndSql 
    
		
#ELSE

	MSGERROR(STR0001)//"No esta disponible para DBF"
	
#ENDIF	
Begin Sequence  

	 dbSelectArea( cAliasSRA )
	 count to nTotal
	 oReport:SetMeter(nTotal) 
	 (cAliasSRA)->(DbGoTop()) 
	 If (cAliasSRA)->(!Eof())   
	 
		For nX := 1 To Len(aStruSRA)
			If ( aStruSRA[nX][2] <> "C" )
				TcSetField(cAliasSRA,aStruSRA[nX][1],aStruSRA[nX][2],aStruSRA[nX][3],aStruSRA[nX][4])
			EndIf
		Next nX  
			 
		oReport:Skipline(2)
		While (cAliasSRA)->(!Eof())
		 	cSucActu:=(cAliasSRA)->RA_FILIAL
			nI:=0		
			
			While (cAliasSRA)->(!Eof()) .and. cSucActu==(cAliasSRA)->RA_FILIAL  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime Encabezado   1                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			 GPER863En(oReport)		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime Encabezado   2                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			 GPER863En2(oReport,1,(cAliasSRA)->RA_FILIAL )
			 oReport:skipline(2)
			 GPER863En4(oReport,(cAliasSRA)->RA_FILIAL)
			 oReport:skipline(2)
			 oSection5:init() 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime Encabezado   3                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			 GPER863En3(oReport)
			 oreport:fatline()		                   
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime Detalle                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			nlc:=0
				While (cAliasSRA)->(!Eof()) .and. cSucActu==(cAliasSRA)->RA_FILIAL  .and. nlc<nLin      
				
					nI++
					nlc++
					
					oSection5:cell("No"):SETVALUE(ALLTRIM(STR(nI)))
					oSection5:cell("Nombre"):SETVALUE((cAliasSRA)->RA_NOME)
					oSection5:cell("Cedula"):SETVALUE((cAliasSRA)->RA_CIC)
					oSection5:cell("FechaN"):SETVALUE((cAliasSRA)->RA_NASC)
					oSection5:cell("SDSS"):SETVALUE((cAliasSRA)->RA_NSEGURO)
			
					If (cAliasSRA)->RA_SEXO =="M"
						oSection5:cell("M"):SETVALUE("X")
						oSection5:cell("F"):SETVALUE(" ")
					Else
						oSection5:cell("F"):SETVALUE("X")
						oSection5:cell("M"):SETVALUE(" ")
					EndIf
			
					oSection5:cell("Nacionalidad"):SETVALUE(SUBSTR(posicione("SX5",1,XFILIAL("SX5")+'34'+PADR((cAliasSRA)->RA_NACIONA,TamSx3("X5_CHAVE")[1]," "),"X5_DESCRI"),1,3))
					cRj_desc:=posicione("SRJ",1,XFILIAL("SRJ",SRA->RA_FILIAL)+(cAliasSRA)->RA_CODFUNC,"RJ_DESC")
					oSection5:cell("Ocupacion"):SETVALUE(IIF(EMPTY(cRj_desc),STR0079,cRj_desc))//"No Existe"
					oSection5:cell("Ent"):SETVALUE(SUBSTR(DTOS((cAliasSRA)->RA_ADMISSA),7,2))
					oSection5:cell("TurnoHorario"):SETVALUE((cAliasSRA)->RA_TNOTRAB)
			
					oSection5:cell("DiasT"):SETVALUE((cAliasSRA)->HRS)
					oSection5:cell("SalD"):SETVALUE((cAliasSRA)->ACUM)						
					(cAliasSRA)->(dbSkip())
					oReport:IncMeter() 
					oSection5:PrintLine() 
		
				EndDo // Misma Linea
			iif((cAliasSRA)->(Eof()) .or. cSucActu!=(cAliasSRA)->RA_FILIAL ,"",oReport:EndPage())
			EndDo //Misma Sucursal
				oReport:Skipline(1)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Imprime Píe de Página (Firmas)                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
				GPER863En2(oReport,2,cSucActu)
				oSection5:Finish() 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Imprime Observaciones                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
				GPER863Ob(OREPORT)
				oReport:EndPage()

		 EndDo // FIN DE ARCHIVO
	EndIf //If fin de archivo 
End Sequence
(cAliasSRA)->(dbCloseArea()) 
Return (Nil)  
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPER863En ³ Autor ³ FMonroy               ³ Data ³05/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Encabezado                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GPER863En(oExp1)    			     					      ³±±
±±³          ³                      		     					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oExp1: Objeto Treport   		     	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER863                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GPER863En(oReport)

Local oSection1:=oReport:Section(1)
oSection1:Init()	
oReport:Skipline()
oReport:Skipline()
oSection1:cell("TITLE"):SetSize(oReport:GetWidth(),.t.)
oSection1:cell("TITLE"):SETVALUE(SPACE(((oReport:GetWidth()-(LEN(STR0003)*12))/2)/12)+STR0003+SPACE(((oReport:GetWidth()-(LEN(STR0003)*12))/2)/12))//Republica Dominicana
oSection1:Printline()
oSection1:cell("TITLE"):SETVALUE(SPACE(((oReport:GetWidth()-(LEN(STR0004)*12))/2)/12)+STR0004+SPACE(((oReport:GetWidth()-(LEN(STR0004)*12))/2)/12))//"SECRETARIA DE ESTADO DE TRABAJO"
oSection1:Printline()
oSection1:cell("TITLE"):SETVALUE(SPACE(((oReport:GetWidth()-(LEN(STR0005)*12))/2)/12)+STR0005+SPACE(((oReport:GetWidth()-(LEN(STR0005)*12))/2)/12))//"DIRECCION GENERAL DE TRABAJO"
oSection1:Printline()
oSection1:cell("TITLE"):SETVALUE(SPACE(((oReport:GetWidth()-(LEN(STR0006)*12))/2)/12)+STR0006+SPACE(((oReport:GetWidth()-(LEN(STR0006)*12))/2)/12))//"Av. Jiménez Moya, Centro de los Héroes, Santo Domingo, República Dominicana"
oSection1:Printline()
oSection1:cell("TITLE"):SETVALUE(SPACE(((oReport:GetWidth()-(LEN(STR0007)*12))/2)/12)+STR0007+SPACE(((oReport:GetWidth()-(LEN(STR0007)*12))/2)/12))//"Teléfono: (809)535-4404 – Fax (809) 535-4590. Correo Electrónico : secret.trabajo@codetel.net.do - www.set.gov.do"
oSection1:Printline()
oSection1:cell("TITLE"):SETVALUE(SPACE(((oReport:GetWidth()-(LEN(STR0008)*12))/2)/12)+STR0008+SPACE(((oReport:GetWidth()-(LEN(STR0008)*12))/2)/12))//"RELACIÓN DE PERSONAL MÓVIL U OCASIONAL"
oSection1:Printline()
oSection1:cell("TITLE"):SETVALUE(SPACE(((oReport:GetWidth()-(LEN(STR0009)*12))/2)/12)+STR0009+SPACE(((oReport:GetWidth()-(LEN(STR0009)*12))/2)/12))//"(De conformidad con los Art.  18 del Reglamento No. 258-93 DEL Código del Trabajo)"
oSection1:Printline()
oSection1:Finish()

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPER863En2³ Autor ³ FMonroy               ³ Data ³05/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Encabezado                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GPER863En2(oExp1,nExp1)     	     					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oExp1: Objeto Treport   		     					      ³±±
±±³          ³nExp1: Bandera(1 Imprime Encabezado 2 Imprime Pie de Pag.)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER863                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GPER863En2(oReport,nT,cFilialRa)

Local oSection2:=oReport:Section(2)
Local oSection1:=oReport:Section(1)
Local oSection6:=oReport:Section(6)

Local nPosS012:=0
Local nPosS112:=0
Local nPosS001:=0

Local cFilOri	:= SM0->M0_CODFIL

dbSelectArea("SM0")
SM0->(dbSeek(cEmpAnt+cFilialRa,.T.))

nPosS001:=FPOSTAB("S001",VAL(ALLTRIM(SM0->M0_CEPENT)),"=",4)
	
nPosS012:=FPOSTAB("S012",CFILIALRA,"=",1)
If nPosS012 == 0
	nPosS012 := FPOSTAB("S012",Space(Len(xfilial("RCB"))),"=",1)
Endif

nPosS112:=FPOSTAB("S112",CFILIALRA,"=",1)
If nPosS112 == 0
	nPosS112:=FPOSTAB("S112",Space(Len(xfilial("RCB"))),"=",1)
Endif

IF nt==1
	oSection2:Init()	
	oSection1:Init()
	oSection2:cell("TITLE1"):SetSize((oReport:GetWidth()/3)/14)
	oSection2:cell("TITLE2"):SetSize((oReport:GetWidth()/2.5)/14)
	oSection2:cell("TITLE3"):SetSize((oReport:GetWidth()/4)/14)
	
	oSection2:cell("TITLE1"):SETVALUE(STR0010+" : " + IIf(!nPosS012 == 0, AllTrim(STR(FTABELA("S012",NPOSS012,5))), " " ) )//"R.N.C. No." FTABELA("S012",NPOSTAB,5)
	oSection2:cell("TITLE2"):SETVALUE(space(((oReport:GetWidth()/3)/14)))
	oSection2:cell("TITLE3"):SETVALUE(STR0011)//"Registro Nacional Laboral RNL"
	oSection2:Printline()
	oSection2:cell("TITLE1"):SETVALUE(STR0012+" : " + IIf(!nPosS012 == 0, FTABELA("S012",NPOSS012,7) , " " ))//"No.de Seguridad Social"FTABELA("S012",NPOSTAB,7)
	oSection2:cell("TITLE2"):SETVALUE(space(((oReport:GetWidth()/3)/14)))
	oSection2:cell("TITLE3"):SETVALUE(SPACE(((oReport:GetWidth()/3-LEN(STR0013)*12)/2)/12)+STR0013+SPACE(((oReport:GetWidth()/3-LEN(STR0013)*12)/2)/12))//"SOLO PARA USO DE LA SET"
	oSection2:Printline()
		
	oSection2:cell("TITLE1"):SETVALUE(STR0014+" : " + cMes+SPACE(5)+STR0015+ " : " + cAnio )//"Mes Reportado"##"Año"
	oSection2:cell("TITLE2"):SETVALUE(space((oReport:GetWidth()/3)/14))
	oSection2:cell("TITLE3"):SETVALUE(STR0016+" : ")//"Registro de Planilla No."
	oSection2:Printline()

	//Razón Social de la empresa: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX	Nombre del empleador: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX		Cédula: XXXXXXXXXX			Rama de Actividad No.:	
		
	oSection2:cell("TITLE1"):SETVALUE(STR0017+" : "+SM0->M0_NOMECOM)//"Razón Social de la empresa"
	oSection2:cell("TITLE2"):SETVALUE(STR0018+" : " + IIf(!nPosS012 == 0 ,FTABELA("S012",NPOSS012,9)+SPACE(5), " " ))//"Nombre del empleador"
	oSection2:cell("TITLE3"):SETVALUE(STR0019+" : ")//"Rama de Actividad No."
	oSection2:Printline()

	//Nombre del establecimiento: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX	Nombre del representante: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX		Cédula: XXXXXXXXXX			Sucursal: S o N			

	oSection2:cell("TITLE1"):SETVALUE(STR0020+" : " + IIf(!nPosS012 == 0, FTABELA("S012",NPOSS012,9), " " ) )//"Nombre del establecimiento"
	oSection2:cell("TITLE2"):SETVALUE(STR0021+" : " + IIf(!nPosS012 == 0, FTABELA("S012",NPOSS012,11)+SPACE(5), " " ))//"Nombre del representante" "
	oSection2:cell("TITLE3"):SETVALUE(STR0022+" : " + IIf(!nPosS012 == 0, FTABELA("S012",NPOSS012,14), " " ))//"Sucursal"
	oSection2:Printline()
	//Dirección (Ave./C y #):  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX	Sector: XXXXXXXXXXXXXXXXXXXXXXXXX		Municipio: XXXXXXXXXXXXXXXXXXXXXXXXXXX	Sección: XXXXXXXXXXXXXXXXXXXXXXXXXXXXX	Provincia: XXXXXXXXXXXXXXXXXXXXXX	
	oSection1:cell("TITLE"):SetSize(oReport:GetWidth())
		
	oSection1:cell("TITLE"):SetValue(STR0023+":"+space(1)+SM0->M0_ENDCOB+space(1)+STR0024+":"+space(1)+ IIf(!nPosS012 == 0, FTABELA("S012",NPOSS012,13), " " )+space(5)+STR0025+":"+ space(1)+IIf(!nPosS001 == 0, FTABELA("S001",NPOSS001,6), " ") +space(1)+STR0026+":"+space(1)+IIf(!nPosS001 == 0, FTABELA("S001",NPOSS001,5), " " )	)//"Dirección (Ave./C y #)"##"Sector"##"Municipio"##""##"Provincia"
	oSection1:Printline()
	//Teléfono: 99999999999	Fax: 99999999999999	Correo electrónico: 	www.XXXXXXXXXXXXXXXXXX    Zona Franca: S o N		Parque: XXXXXXXXXXXXXXXXXXXXXXX	
	oSection1:cell("TITLE"):SetValue(STR0027+":"+space(2) + SM0->M0_TEL+space(2)+STR0028+":"+space(1)+ SM0->M0_FAX+space(5)+IIf(!nPosS112 == 0, FTABELA("S112",NPOSS112,4), " " )+ space(5)+STR0029+":"+ space(1)+ IIf(!nPosS112 == 0, FTABELA("S112",NPOSS112,5), " ")+SPACE(2)+STR0030+" : "+ IIf(!nPosS012 == 0, FTABELA("S012",NPOSS012,6), " ")+space(5)+STR0031+":"+space(1)+ IIf(!nPosS112 == 0, FTABELA("S112",NPOSS112,6), " "))//"Teléfono"##"Fax"##"Correo electrónico"##"WWW "##"Zona Franca"##"Parque"
	oSection1:Printline()

	//A que se dedica la empresa	S112?Ocupacion substring(RCC_CONTEU,178,60)	
	oSection1:cell("TITLE"):SetValue(STR0032+" : "+ IIf(!nPosS112 == 0, FTABELA("S112",NPOSS112,13), " ")+space(10)+STR0033+" : "+ IIf(!nPosS112 == 0, transform(FTABELA("S112",NPOSS112,7),"999,999,999,999.99" ), " " ))//"A que se dedica la empresa"  ## "Valor de las instalaciones y/o existencias (en RD$)"
	oSection1:Printline()
	oSection1:Finish()
	oSection2:Finish()
ELSE
	oSection6:init()
	oSection6:cell("FIR1"):SetValue(REPLICATE('_',60))
	oSection6:cell("FIR2"):SetValue(SPACE(1))
	oSection6:cell("FIR3"):SetValue(STR0034+" : ")//Comprobación efectuada por
	oSection6:cell("FIR4"):SetValue(REPLICATE('_',60))
	oSection6:Printline()
	oSection6:cell("FIR1"):SetValue( STR0035 )//"Firma del director General del Trabajo o Representante Legal"
	oSection6:cell("FIR2"):SetValue(SPACE(1))
	oSection6:cell("FIR3"):SetValue(space(1))//"Firma del Inspector"
	oSection6:cell("FIR4"):SetValue(space(15)+ STR0036)//"Nombre del Inspector"/*
	oSection6:Printline()
	oSection6:Finish()
ENDIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Volta a empresa anteriormente selecionada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SM0")
SM0->(dbSeek(cEmpAnt+cFilOri,.T.))
cFilAnt := SM0->M0_CODFIL
Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPER863En4³ Autor ³ FMonroy               ³ Data ³05/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime Encabezado                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GPER863En4(oExp1, cExp2)  	     					      ³±±
±±³          ³                      		     					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oExp1: Objeto Treport   		     	                      ³±±
±±³          ³cExp2: Sucursal en Impresión	     	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³GPER863                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GPER863En4(oReport, cSucT)

Local oSection3:=oReport:Section(3)

Local dData
Local nRet:=0
Local nTMovil:=0
Local nTDom:=0
LOcal nTExt:=0
Local nTAcum:=0
Local nTAcumD:=0
Local nTAcumMo:=0
Local nTM:=0
Local nTF:=0
Local nT16:=0
Local cSelect:=""
Local cFilPro:=""
Local cAliasT:=criatrab(nil,.f.)
Local cFilSRV     := xFilial( "SRV", RG7->RG7_FILIAL)
oSection3:Init()	
dData := CtoD( StrZero(F_ULTDIA( stod(cAnio+cMes+"01") ),2,0) +"/"+cMes +"/"+ cAnio ) 
	
cSelect :="%"
cSelect +=" SRA.RA_FILIAL,RG7.RG7_PROCES, RG7.RG7_MAT,SRA.RA_NACIONA,SRA.RA_NASC,SRA.RA_SEXO,SRA.RA_NOME,SRA.RA_CIC,SRA.RA_NSEGURO,"
cSelect +=" SRA.RA_CODFUNC,SRA.RA_ADMISSA,SRA.RA_TNOTRAB,RV_COD,SRA.RA_NACIONA,RG7.RG7_ACUM"+cMes+" ACUM,RG7.RG7_HRS"+cMes+" HRS"
cSelect +="%"

cFILPRO :=  "%"    
CFILPRO += " SRA.RA_TIPOADM ='0002' "
CFILPRO += " AND SRV.RV_CODFOL='0047' "
CFILPRO += " AND RG7.RG7_CODCRI='01' "
CFILPRO += " AND SUBSTRING(SRA.RA_ADMISSA, 1, 6)='"	+ cAnio +cMes+"' "
CFILPRO += " AND RG7.RG7_FILIAL = '"+ cSucT + "'"
CFILPRO += " AND RG7.RG7_PROCES BETWEEN '"+ cProI + "' AND '"+ cProF+"'"
CFILPRO += " AND RG7.RG7_MAT BETWEEN '"	+ cMatI + "' AND '"+ cMatF+"'"
CFILPRO += " AND RG7.RG7_ANOINI ='"	+ cAnio+"'"
cFILPRO +=  " %"  
BeginSql alias cAliasT

	SELECT	%exp:cSelect% 			
	FROM %table:RG7% RG7    
	INNER JOIN  %table:SRA% SRA 
	ON  SRA.RA_FILIAL  = RG7.RG7_FILIAL AND
		SRA.RA_MAT     = RG7.RG7_MAT
	INNER JOIN 	%table:SRV% SRV
	ON		SRV.RV_FILIAL = %exp:cFilSRV%	AND
			SRV.RV_COD    = RG7.RG7_PD	   
	WHERE	
			%exp:cFilPro% 
			AND  SRA.%notDel% 
			AND  RG7.%notDel%  
			AND  SRV.%notDel%  
			
	ORDER BY SRA.RA_FILIAL,RG7.RG7_PROCES, RG7.RG7_MAT
			 	
EndSql 
    
dbSelectArea( cAliasT )
	 
(cAliasT)->(DbGoTop()) 

 If (cAliasT)->(!Eof())
	While (cAliasT)->(!Eof())
		//Total de Empleados Moviles	
		nTMovil++
		nTAcum+=( cAliasT )->ACUM
		IF( cAliasT )->RA_NACIONA=='26'
			//Total Nacional
			nTDom++
			//Total de Salario Nacioal 
			nTAcumD+=( cAliasT )->ACUM
		ELSE
			//Total de Extranjeros
			nTExt++
			
			//Total de Salario EXt.
			nTAcumMo:=( cAliasT )->ACUM
		ENDIF
		IF ( cAliasT )->RA_SEXO=="M"
			nTM++
		ELSE
			nTF++
		ENDIF
		nRet:=Year(dData)-year( STOD(( cAliasT )->RA_NASC))-If(Substr(Dtos(dData),5,4) <= Substr((cAliasT )->RA_NASC,5,4),1,0 )
		IF nRet<16
			nT16++
		EndIf
		(cAliasT)->(dbSkip())
	EndDo
	oSection3:cell("DI1"):SetValue(STR0037)//"DISTRIBUCION DEL PERSONAL MOVIL U OCASIONAL"
	oSection3:cell("DI2"):SetValue(space(1))
	oSection3:cell("DI3"):SetValue(STR0038)//"CANTIDAD DE TRABAJADORES MOVILES U OCASIONALES"
	oSection3:cell("DI4"):SetValue(space(1))
	oSection3:Printline()

	oSection3:cell("DI1"):SetValue(STR0039)//"Proporción del personal dominicano"
	oSection3:cell("DI2"):SetValue(transform((nTDom/nTMovil)*100,"999,999,999,999.99")+" %")
	oSection3:cell("DI3"):SetValue(STR0040)//"Cantidad de trabajadores mujeres"
	oSection3:cell("DI4"):SetValue(transform((nTF/nTMovil)*100,"999,999,999,999.99")+" %")
	oSection3:Printline()

	oSection3:cell("DI1"):SetValue(STR0041)//"Proporción del personal extranjero"
	oSection3:cell("DI2"):SetValue(transform((nTExt/nTMovil)*100,"999,999,999,999.99")+" %")
	oSection3:cell("DI3"):SetValue(STR0042)//"Cantidad de trabajadores hombres"
	oSection3:cell("DI4"):SetValue(transform((nTM/nTMovil)*100,"999,999,999,999.99")+" %")
	oSection3:Printline()

	oSection3:cell("DI1"):SetValue(" ")
	oSection3:cell("DI2"):SetValue(space(1))
	oSection3:cell("DI3"):SetValue(STR0043 +" :")//"Total de trabajadores móviles u ocasionales" 
	oSection3:cell("DI4"):SetValue(transform(nTMovil,"999,999,999,999.99"))
	oSection3:Printline()

	oSection3:cell("DI1"):SetValue(STR0044)//"DISTRIBUCION DEL SALARIO DEL PERSONAL MOVIL U OCASIONAL "
	oSection3:cell("DI2"):SetValue(space(1))
	oSection3:cell("DI3"):SetValue(STR0045)//"Suma mensual total pagada a trabajadores móviles u ocasionales (RD$)"
	oSection3:cell("DI4"):SetValue(transform(nTAcum,"999,999,999,999.99"))
	oSection3:Printline()

	oSection3:cell("DI1"):SetValue(STR0046)//"Proporción del salario recibido por dominicanos"
	oSection3:cell("DI2"):SetValue(transform((nTAcumD/nTAcum)*100,"999,999,999,999.99")+" %")
	oSection3:cell("DI3"):SetValue(STR0047+":")//"Cantidad de trabajadores móviles u ocasionales extranjeros"
	oSection3:cell("DI4"):SetValue(transform(nTMovil,"999,999,999,999.99"))
	oSection3:Printline()

	oSection3:cell("DI1"):SetValue(STR0048)//
	oSection3:cell("DI2"):SetValue(transform((nTAcumMo/nTAcum)*100,"999,999,999,999.99")+" %")
	oSection3:cell("DI3"):SetValue(STR0049+" :")//"Cantidad de trabajadors móviles u ocasionales menores de 16 años"
	oSection3:cell("DI4"):SetValue(transform(nT16,"999,999,999,999.99"))
	oSection3:Printline()

EndIf
(cAliasT)->(dbCloseArea()) 


oSection3:Finish()

Return ( Nil )



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPER863En3³ Autor ³ FMonroy               ³ Data ³05/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Encabezado                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GPER863En3(oExp1)    			     					      ³±±
±±³          ³                      		     					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oExp1: Objeto Treport   		     	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER863                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GPER863En3(oReport)

Local oSection4:=oReport:Section(4)
	
oSection4:Init()	

oSection4:cell("No"):SETVALUE(STR0050)//"No."
oSection4:cell("Nombre"):SETVALUE(STR0051)//"Nombres y Apellidos"
oSection4:cell("Cedula"):SETVALUE(STR0052)//"Cedula de"
oSection4:cell("FechaN"):SETVALUE(STR0053)//"Fecha de"
oSection4:cell("SDSS"):SETVALUE(STR0054)//"Sistema"
oSection4:cell("M"):SETVALUE(STR0055)//""M
oSection4:cell("F"):SETVALUE(STR0056)//"F"
oSection4:cell("Nacionalidad"):SETVALUE(STR0057)//"Nacionalidad"
oSection4:cell("Ocupacion"):SETVALUE(STR0058)//"Ocupación"
oSection4:cell("Ent"):SETVALUE(STR0059)//"Entrada"
oSection4:cell("TurnoHorario"):SETVALUE(STR0060)//"Turno"
oSection4:cell("DiasT"):SETVALUE(STR0061)//"Dias"
oSection4:cell("SalD"):SETVALUE(STR0062)//"Salario Devengado"
oSection4:Printline()

oSection4:cell("No"):SETVALUE(space(1))
oSection4:cell("Nombre"):SETVALUE(STR0063)//"del Trabajador"
oSection4:cell("Cedula"):SETVALUE(STR0064)//"identidad"
oSection4:cell("FechaN"):SETVALUE(STR0065)//"Nacimiento"
oSection4:cell("SDSS"):SETVALUE(STR0066)//"Dominicano"
oSection4:cell("M"):SETVALUE(space(1))
oSection4:cell("F"):SETVALUE(space(1))
oSection4:cell("Nacionalidad"):SETVALUE(space(1))
oSection4:cell("Ocupacion"):SETVALUE(space(1))
oSection4:cell("Ent"):SETVALUE(STR0067)//"(dd)"
oSection4:cell("TurnoHorario"):SETVALUE(STR0068)//"Horario"
oSection4:cell("DiasT"):SETVALUE(STR0069)//"Trabajados"
oSection4:cell("SalD"):SETVALUE(STR0070)//"en el Mes(RD$)"
oSection4:Printline()

oSection4:cell("No"):SETVALUE(space(1))
oSection4:cell("Nombre"):SETVALUE(Space(1))
oSection4:cell("Cedula"):SETVALUE(STR0071)//"y Electoral"
oSection4:cell("FechaN"):SETVALUE(STR0072)//"(dd/mm/aa)"
oSection4:cell("SDSS"):SETVALUE(STR0073)//"de Seguridad"
oSection4:cell("M"):SETVALUE(space(1))
oSection4:cell("F"):SETVALUE(space(1))
oSection4:cell("Nacionalidad"):SETVALUE(space(1))
oSection4:cell("Ocupacion"):SETVALUE(space(1))
oSection4:cell("Ent"):SETVALUE(Space(1))
oSection4:cell("TurnoHorario"):SETVALUE(space(1))
oSection4:cell("DiasT"):SETVALUE(Space(1))
oSection4:cell("SalD"):SETVALUE(Space(1))
oSection4:Printline()

oSection4:cell("No"):SETVALUE(space(1))
oSection4:cell("Nombre"):SETVALUE(Space(1))
oSection4:cell("Cedula"):SETVALUE(Space(1))
oSection4:cell("FechaN"):SETVALUE(Space(1))
oSection4:cell("SDSS"):SETVALUE(STR0074)//"Social SDSS"
oSection4:cell("M"):SETVALUE(space(1))
oSection4:cell("F"):SETVALUE(space(1))
oSection4:cell("Nacionalidad"):SETVALUE(space(1))
oSection4:cell("Ocupacion"):SETVALUE(space(1))
oSection4:cell("Ent"):SETVALUE(Space(1))
oSection4:cell("TurnoHorario"):SETVALUE(space(1))
oSection4:cell("DiasT"):SETVALUE(Space(1))
oSection4:cell("SalD"):SETVALUE(Space(1))
oSection4:Printline()

oSection4:Finish()

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPER863Ob ³ Autor ³ FMonroy               ³ Data ³05/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Observaciones                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GPER863Ob(oExp1)    			     					      ³±±
±±³          ³                      		     					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³oExp1: Objeto Treport   		     	                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER863                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GPER863Ob(oReport)

Local oSection1:=oReport:Section(1)
oSection1:Init()	
oReport:Skipline()
oReport:Skipline()
oSection1:cell("TITLE"):SetSize(oReport:GetWidth(),.t.)
oSection1:cell("TITLE"):SETVALUE(STR0075+" : "+cObser)//"Observaciones"
oSection1:Printline()
oSection1:cell("TITLE"):SETVALUE(SPACE(len(STR0075)+3)+replicate("_",len(cObser)) )
oSection1:Printline()
OREPORT:SKIPLINE()
OREPORT:SKIPLINE()
oSection1:cell("TITLE"):SETVALUE(STR0076)
oSection1:Printline()

oSection1:Finish()

Return (Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GPR03DOM01³ Autor ³ FMonroy               ³ Data ³05/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacion de las preguntas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER86301()											      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Ninguno						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ X1_VALID - GPER863 En X1_ORDEM = 7                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPR03DOM01() 
                                   
Local	cMes:=SUBSTR(strZERO(MV_PAR07,6),1,2)
	
IF val(cMes)<1 .or.val(cMes)>12
	msginfo(STR0077)//"El mes debe ser de 1 a 12!"
	Return .F.
ENDIF                  

Return (.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TodoOK    ºAutor  ³Microsiga           º Data ³  05/07/11   º±±
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

	Pergunte(cPerg,.F.)

	cSucI	:=	MV_PAR01
	cSucF	:=	MV_PAR02
	cProI	:=	MV_PAR03
	cProF	:=	MV_PAR04
	cMatI	:=	MV_PAR05
	cMatF	:=	MV_PAR06
	cObser	:=	MV_PAR08
	cMes	:=	SUBSTR(strZERO(MV_PAR07,6),1,2)
	cAnio	:=	SUBSTR(strZERO(MV_PAR07,6),3,4)
	nMesA	:=	MV_PAR07

Return (.T.)

