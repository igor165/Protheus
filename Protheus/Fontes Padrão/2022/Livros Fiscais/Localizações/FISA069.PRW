#INCLUDE "TOTVS.CH"
#INCLUDE "FISA069.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFISA069   บAutor  ณAntonio Trejo       บFecha ณ 05/09/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGenera en archivos de texto informacion que sera importada  บฑฑ
ฑฑบ          ณen el aplicativo web de la provincia de Mendoza (SIFERE)	  บฑฑ			                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P11                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FISA069()

	
	Local aArea		:= getArea()   
	Local oFld		:= Nil
	Private _lRegs	:= .F.
	Private oDlg	:= Nil
	
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 0,0 TO 250,450 OF oDlg PIXEL //"Porcentaje de Exenci๓n de Percepci๓n y Retenci๓n del IVA"

		@ 020,006 FOLDER oFld OF oDlg PROMPT STR0002 PIXEL SIZE 165,075 	//"&Importa็ใo de Arquivo TXT"
		
		//+----------------
		//| Campos Folder 
		//+----------------
		@ 005,005 SAY STR0003 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta rutina actualiza los porcentajes de exenci๓n de    "
		@ 015,005 SAY STR0004 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"percepci๓n y retenci๓n del IVA deacuerdo al padr๓n  "
		@ 025,005 SAY STR0005 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"emitido por la AFIP.   "                        "		

		
		//+-------------------
		//| Boton de MSDialog
		//+-------------------
		@ 055,178 BUTTON STR0006 SIZE 036,016 PIXEL ACTION RunProc() 	//"&Exportar"
		@ 075,178 BUTTON STR0007 SIZE 036,016 PIXEL ACTION oDlg:End() 		//"&Sair"

	
	ACTIVATE MSDIALOG oDlg CENTER
		
	Restarea(aArea)


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRunProc   บAutor  ณAntonio Trejo       บFecha ณ 05/09/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza el procesamiento seg๚n la o las opciones elegidas  บฑฑ
ฑฑบ          ณ en el parแmetro MV_05.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP11                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function RunProc()
	Local aDatos		:= {}
	Local cFileNameTxt 	:= ""

	AjSX1Desc()
	IF Pergunte("FISA069",.T.)
		
		IF ValidParam()
			cFileNameTxt 	:= MV_PAR05		
			If (MV_PAR04) == 1
				Processa( {|| GenArqRet(@aDatos)}		, STR0012,STR0010, .T. )
				Processa( {|| genFile(aDatos,RTRIM(cFileNameTxt) + ".txt")}	, STR0012,STR0011, .T. )
			EndIF
			IF (MV_PAR04) == 2
				aDatos := {}
				Processa( {|| GenArqPer(1,@aDatos)}, STR0012,STR0010, .T. )
				Processa( {|| genFile(aDatos,RTRIM(cFileNameTxt) + ".txt")}	, STR0012,STR0011, .T. )
			EndIF			
		End IF	
	End If
Return

//+----------------------------------------------------------------------+
//|Valida parแmetros de entrada											 |
//+----------------------------------------------------------------------+

Static Function ValidParam()
	Local lRet:=  .T.
	
	If Empty(MV_PAR01) .OR. Empty(MV_PAR02) .or. Empty(MV_PAR03) .or. Empty(MV_PAR04) .or. Empty(MV_PAR05)
		MSgAlert(STR0008) 		
		lRet := .F.
	ElseIF YEAR(MV_PAR01) <> YEAR(MV_PAR02) .AND. MONTH(MV_PAR01) <> MONTH(MV_PAR02)
		MsgAlert(STR0018)
	End IF		
	
	if Empty(MV_PAR05)
		lRet := .F.
		MsgAlert(STR0014)
	end
Return lRet

//+----------------------------------------------------------------------+
//|Obtiene los datos para generar archivo de retenciones.				 |
//+----------------------------------------------------------------------+
Static Function GenArqRet(aDatos)

	Local cQuery	:= ""
	Local cTmp		:= "TRD"
	Local nRegs		:= ""
	Local cCodJur	:= ""
	aDatos := {}
	cCodJur	:=	POSICIONE("CCO",1,xFilial("CCO")+MV_PAR03,"CCO_CODJUR")	
	
	cQuery 	:= 	"SELECT "
	cQuery	+=		"A2_CGC, "
	cQuery	+=		"A2_NOME, "
	cQuery	+=		"FE_EMISSAO, "
	cQuery	+=		"FE_NFISCAL,"
	cQuery	+=		"FE_DTRETOR,"
	cQuery	+=		"FE_VALBASE, "
	cQuery	+=		"FE_ALIQ, "    // CUIT ********************
	cQuery	+=		"FE_RETENC "
	cQuery 	+=	"FROM " 
	cQuery	+=		RetSqlName("SFE")+ " SFE,"
	cQuery	+=		RetSqlName("SA2")+ " SA2 "
	cQuery	+=	"WHERE "
	cQuery	+=		"FE_FILIAL='" + xFilial("SFE")+ "' AND "
	cQuery	+=		"A2_FILIAL='" + xFilial("SA2")+ "' AND "
	cQuery	+=		"FE_EMISSAO >='" + DTOS(MV_PAR01)+ "' AND "
	cQuery	+=		"FE_EMISSAO <='" + DTOS( MV_PAR02)+ "' AND "
	cQuery	+=		"FE_TIPO='B' AND "
	cQuery	+=		"FE_EST='"+ ALLTRIM(MV_PAR03) + "' AND "
	cQuery	+=		"A2_COD=FE_FORNECE AND "
	cQuery	+=		"A2_LOJA=FE_LOJA AND "	
	cQuery	+= 		"(SFE.FE_DTESTOR <'" + DTOS(MV_PAR01)+ "' OR "
	cQuery	+=		" SFE.FE_DTESTOR >'" + DTOS(MV_PAR02)+ "' OR "
	cQuery	+=		" SFE.FE_DTESTOR = ' ' OR "
	cQuery	+=		" SFE.FE_NRETORI <> ' ' "
	cQuery	+=		") AND "
	cQuery	+=		"SA2.D_E_L_E_T_=' ' AND "
	cQuery	+=		"SFE.D_E_L_E_T_=' ' "
	
	cQuery := ChangeQuery(cQuery)                    

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 
	TcSetField( cTmp, 'FE_EMISSAO', 'D', TamSX3('FE_EMISSAO')[1], 0 )
	
	Count to nRegs
	
	ProcRegua(nRegs)
	nRegs	:= 0
	(cTmp)->(dbGoTop())
	While (cTmp)-> (!Eof())
		nRegs++
		IncProc(STR0010 + str(nRegs))		
		
		AADD(aDatos,{	TRANSFORM((cTmp)->A2_CGC,"@R 99-99999999-9"),;
					PadR((cTmp)->A2_NOME, 80),;
					strZero(DAY((cTmp)->FE_EMISSAO),2)+strZero(month((cTmp)->FE_EMISSAO),2)+strZero(YEAR((cTmp)->FE_EMISSAO),4),;
					RIGHT(strZero(VAL((cTmp)->FE_NFISCAL),12,0),12),;
					strZero(DAY((cTmp)->FE_EMISSAO),2)+strZero(month((cTmp)->FE_EMISSAO),2)+strZero(YEAR((cTmp)->FE_EMISSAO),4),;
					PADL(TRANSFORM((cTmp)->FE_VALBASE,"@! 999999999999.99"),15),;		
					TRANSFORM((cTmp)->FE_ALIQ,"@! 99.99"),;			
					PADL(TRANSFORM((cTmp)->FE_RETENC,"@! 99999999999.99"),15)})
		(cTmp)->(dbSkip())						
	End Do
	(cTmp)-> (dbCloseArea()) 
	
	
Return
//+----------------------------------------------------------------------+
//|Realiza el proceso para obtener los registrso de percepciones    	 |
//+----------------------------------------------------------------------+
//|Parแmetros	|nTipo:	Tipo de archivo a generar   					 |
//|				|	1.-Percepciones Clientes							 |
//|				|	2.-Percepciones Proveedores							 |
//|				|aDatos													 |
//|				|	Array en d๓nde serแn almacenados los datos antes     |
//|				|	de generar el txt.									 | 
//+-------------+--------------------------------------------------------+

Static Function GenArqPer(nTipo,aDatos)
	
	
	Local cCpo := ""
	
	cCpo	:=  GetCpoImp()
	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	
	IF cCpo <> ""
		PerSF3(1,@aDatos,cCpo)
		PerSF3(2,@aDatos,cCpo)
	End IF	
Return

//+----------------------------------------------------------------------+
//|Obtiene informaci๓n de SF3 para archivo de percepciones				 |
//+----------------------------------------------------------------------+
//|Parแmetros	|nTipo:	Tipo de archivo a generar   					 |
//|				|	1.-Percepciones Clientes							 |
//|				|	2.-Percepciones Proveedores							 |
//|				|aDatos													 |
//|				|	Array en d๓nde serแn almacenados los datos antes     |
//|				|	de generar el txt.									 | 
//|				|cCpo												     |
//|				|	Campo configurado para obtener el valor del importe  |
//|				|	en SF3.												 | 
//+-------------+--------------------------------------------------------+
Static function PerSF3(nTipo,aData,cCpo)
	
	Local aArea		:= getArea()
	Local cQuery	:= ""
	Local cTmp		:= "TRD"
	Local nRegs		:= ""
	Local cCodJur	:= ""
	Local cTipoCom	:= ""
	Local aSA6		:= {}
	Local _aArea	:= ""
	Local cClaveSA6	:= ""
	Local cDesp		:= ""
	Local cCuit := ""
	Local cNome := ""
	Local cEspecieV	:= ""
	Local cEspecieC	:= ""
	Local nSinal:=1
	
	If nTipo == 1
        cEspecieV	:= "'NF','NDC','NCC','NDE','NCE'"
	Else
        cEspecieC  := "'NF','NDP','NCP','NDI','NCI'"
	EndIf
	
	cCodJur	:=	POSICIONE("CCO",1,xFilial("CCO")+MV_PAR03,"CCO_CODJUR")	
	
	cQuery 	:= 	"SELECT "
	cQuery	+=		"F3_EMISSAO ,"
	cQuery	+=		"F3_NFISCAL ,"
	cQuery	+=		"F3_ENTRADA,"
	cQuery	+=		"F3_ESPECIE,"
	cQuery	+=		"F3_BASIMP" + cCpo + ","
	cQuery	+=		"F3_ALQIMP" + cCpo + ","
	cQuery	+=		"F3_VALIMP" + cCpo + ","
	If nTipo == 1
		cQuery	+=	"A1_CGC, A1_NOME	"
	Else
		cQuery 	+=	"A2_CGC, A2_NOME "		
	End IF
	cQuery 	+=	"FROM " 
	cQuery	+=		RetSqlName("SF3")+ " SF3,"
	
	If nTipo == 1
		cQuery	+=		RetSqlName("SA1")+ " SA1 "
	Else
		cQuery	+=		RetSqlName("SA2")+ " SA2 "
	End IF
	
	cQuery	+=	"WHERE "
	cQuery	+=	"F3_FILIAL='" + xFilial("SF3")+ "' AND "
	
	If nTipo == 1
		cQuery	+=	"A1_FILIAL='" + xFilial("SA1")+ "' AND "
	Else
		cQuery	+=	"A2_FILIAL='" + xFilial("SA2")+ "' AND "
	End If
	
	cQuery	+=		"F3_EMISSAO >='" + DTOS(MV_PAR01)+ "' AND "
	cQuery	+=		"F3_EMISSAO <='" + DTOS(MV_PAR02)+ "' AND "	
	cQuery	+=		"F3_VALIMP"+cCpo+"<>0 AND "
	If nTipo == 1	// Percepciones Clientes
		cQuery	+=	"F3_TIPOMOV='V' AND "
		cQuery 	+=	"F3_ESPECIE IN ("+cEspecieV+") AND "
		cQuery	+=	"A1_COD =F3_CLIEFOR  AND "
		cQuery	+=	"A1_LOJA=F3_LOJA  AND "
		cQuery	+=	"SA1.D_E_L_E_T_=' ' AND "
	Else
		cQuery 	+= 	"F3_TIPOMOV='C' AND "
		cQuery 	+=	"F3_ESPECIE IN ("+cEspecieC+") AND "
		
		Do Case
			Case nTipo == 2	// Percepciones Proveedores
				cQuery += "A2_TIPROV='P' AND "
			Case nTipo == 3 // Percepciones Aduanas
				cQuery += "A2_TIPROV='A' AND "				
			Case nTipo == 4 // Percepciones Bancarias
				cQuery += "A2_TIPROV='B' AND "					
		End Do
	
		cQuery	+=	"A2_COD =F3_CLIEFOR  AND "
		cQuery	+=	"A2_LOJA=F3_LOJA  AND "
		cQuery	+=	"SA2.D_E_L_E_T_=' ' AND "			
		
	End If
	
	cQuery	+=		"SF3.D_E_L_E_T_=' ' "
	
	cQuery := ChangeQuery(cQuery)                    

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.) 
	TcSetField( cTmp, 'F3_EMISSAO', 'D', TamSX3('F3_EMISSAO')[1], 0 )
	TcSetField( cTmp, 'F3_ENTRADA', 'D', TamSX3('F3_ENTRADA')[1], 0 )
	
	Count to nRegs
	
	ProcRegua(nRegs)
	nRegs	:= 0
	(cTmp)-> (dbgotop())
	While (cTmp)-> (!Eof())
		nRegs++
		IncProc(STR0010 + str(nRegs))					
	
		If nTipo == 1
			cCuit 	:= TRANSFORM((cTmp)->A1_CGC,"@R 99-99999999-9")
			cNome 	:= PadR((cTmp)->A1_NOME, 80)
		else
			cCuit 	:= TRANSFORM((cTmp)->A2_CGC,"@R 99-99999999-9")
			cNome 	:= PadR((cTmp)->A2_NOME, 80)
		end if
		
		nSinal:=1
		If Alltrim((cTmp)->F3_ESPECIE) $ "NCC|NCI"
			nSinal:=-1
		EndIf
		AADD(aData,{	cCuit,;
					cNome,;
					strZero(DAY((cTmp)->F3_EMISSAO),2)+strZero(month((cTmp)->F3_EMISSAO),2)+strZero(YEAR((cTmp)->F3_EMISSAO),4),;
					RIGHT(strZero(VAL((cTmp)->F3_NFISCAL),12,0),12),;
					strZero(DAY((cTmp)->F3_ENTRADA),2)+strZero(month((cTmp)->F3_ENTRADA),2)+strZero(YEAR((cTmp)->F3_ENTRADA),4),;
					PADL(TRANSFORM((cTmp)->&("F3_BASIMP"+cCpo),"@! 999999999999.99"),15),;		
					TRANSFORM((cTmp)->&("F3_ALQIMP"+cCpo),"@! 99.99"),;		
					PADL(TRANSFORM((cTmp)->&("F3_VALIMP"+cCpo)*nSinal ,"@! 99999999999.99"),15)})
		(cTmp)-> (dbSkip())
	End Do
	(cTmp)-> (dbCloseArea()) 	
	RestArea(aArea)
Return 

//+----------------------------------------------------------------------+
//|Obtiene el campo del cuแl se obtendrแ el importe de las percepciones	 |
//+----------------------------------------------------------------------+

Static Function GetCpoImp()

	Local aArea		:= getArea()
	Local cQuery	:= ""
	Local cTmp		:= "TRX"
	Local cCpo		:= ""
	
	cQuery	:= 	"SELECT " 
	cQuery	+=		"FB_CPOLVRO "
	cQuery	+=	"FROM "
	cQuery	+=		RetSqlName("SFB") + " SFB "
	cQuery	+=	"WHERE "
	cQuery	+=		"FB_FILIAL='"+ xFilial("SFB")+"' AND "		
	cQuery	+=		"FB_ESTADO='" + ALLTRIM(MV_PAR03) +"' AND " ///provincia
	cQuery	+=		"FB_CLASSIF='1' AND "
	cquery	+=		"FB_CLASSE='P' AND "
	cQuery	+=		"D_E_L_E_T_=' ' "	
	
	cQuery := ChangeQuery(cQuery)                    

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
	(cTmp)-> (dbgotop())	 
	While (cTmp)-> (!Eof())
		cCpo := (cTmp)->FB_CPOLVRO
		(cTmp)->(dbskip())
	EndDo
	(cTmp)->(dbCloseArea())
	
Return cCpo


//+----------------------------------------------------------------------+
//|Genera el archivo de texto 											 |
//+----------------------------------------------------------------------+
//|Parแmetros	|aArq:	Array con los datos a registrar en el archivo	 |
//|				|	de Texto.											 |
//|				|cNameFile												 |
//|				|	Nombre del archivo que s erแ generado.     			 |
//|				|	de generar el txt.									 |  
//+-------------+--------------------------------------------------------+
Static Function genFile(aArq,cNameFile)
	
	Local cLinea	:= ""
	Local nI		:= 0
	Local nJ		:= 0
	Local nArcLog	:= 0
	Local cFileName	:= ""
	
	if Len(aArq) > 0
	
		cFileName := cNameFile
		If File(cNameFile)	
			FErase(cNameFile) 
		End If
			
		nArqLog	:= MSfCreate(cFileName, 0)
			
		ProcRegua(Len(aArq))		
		
		For nI:=1 To Len(aArq)
			
			IncProc(STR0013 + str(nI))	
			For nJ:= 1 to Len(aArq[nI])
				cLinea	+= aArq[nI,nJ]					
			Next nJ
			
			FWrite(nArqLog,cLinea+Chr(13)+Chr(10))		
			cLinea:= ""
		Next nI  
	
		FClose(nArqLog)
		
		MSGINFO(STR0017)
	else
		MSGALERT(STR0019)
	end if	
Return .T. 

/*
 ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
 ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
 ฑฑบPrograma  ณfisa069   บAutor  ณMicrosiga           บ Data ณ  11/04/2017 บฑฑ
 ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
 ฑฑบDesc.     ณ                                                            บฑฑ
 ฑฑบ          ณ                                                            บฑฑ
 ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
 ฑฑบUso       ณ AP                                                         บฑฑ
 ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
 ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
 */

 Static Function AjSX1Desc()

 dbSelectArea("SX1")
 dbSetOrder(1)

 If dbSeek(PadR("FISA069", Len(SX1->X1_GRUPO))+"04")
     If ! ("Retenciones" $ Alltrim(SX1->X1_DEF01) )
         RecLock("SX1", .F.)
         SX1->X1_DEF01   := "Retenciones"
         SX1->X1_DEFSPA1 := "Retenciones"
         SX1->X1_DEFENG1 := "Retenciones"
         SX1->X1_DEF02   := "Percepciones"
         SX1->X1_DEFSPA2 := "Percepciones"
         SX1->X1_DEFENG2 := "Percepciones"
         MsUnlock()
     EndIf
 EndIf

 Return

