#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "FRETARCIBA.ch"

Static oTmpTRBn
Static oTmpTRBc

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma   ณ RTARCIBA ณ Autor ณ TOTVS                ณ Fecha ณ08/04/2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescripcionณ Genera Archivo de Retenciones                              ณฑฑ  
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso        ณ ARCIBA                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณData    ณ BOPS     ณ Motivo da Alteracao                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ  Marco A.  ณ03/01/17ณSERINN001 ณSe aplica CTREE para evitar la creacionณฑฑ
ฑฑณ            ณ        ณ-547      ณde tablas temporales de manera fisica  ณฑฑ
ฑฑณ            ณ        ณ          ณen system.                             ณฑฑ
ฑฑณAlf. Medranoณ17/03/17ณ MMI-304ณ En func RTARCIBA() se actualiza valor deณฑฑ
ฑฑณ            ณ        ณ        ณ campo EMISSAO a 8 caracteres            ณฑฑ
ฑฑณ            ณ        ณ        ณ En las func FRET(), FPER() y FAMB() se  ณฑฑ
ฑฑณ            ณ        ณ        ณ valida si comprobante es igual a A o M  ณฑฑ
ฑฑณ            ณ        ณ        ณ para obtener IVA tambi้n se asigna ordenณฑฑ
ฑฑณ            ณ        ณ        ณ por fecha. Se asignan de STR's. se sim- ณฑฑ
ฑฑณ            ณ        ณ        ณ plifican condiciones en func TipoCom    ณฑฑ
ฑฑณ            ณ05/04/17ณ MMI-304ณ Merge Main vs 12.1.14                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function RTARCIBA()

	Local aStruRETN	:= {}
	Local aStruRETC	:= {}
	Local aOrdem1	:= {}
	Local aOrdem2	:= {}
	Local aOrdem3	:= {}
	Local aOrdem4	:= {}
	
	Private cArqTrabN	:= ""
	Private cArqTrabC	:= ""		
	Private aArqTrab	:= {}
	Private cTpBco := Upper(Alltrim(TcGetDB()))

	//Estrutura para nota fiscal  normal - Informacoes para ini        
	aAdd(aStruRETN, {"TIPOPER"		, "C", 01						, 0}) //Tipo de Operaci๓n
	aAdd(aStruRETN, {"CODNOR"		, "C", 03						, 0}) //Codigo de Norma
	aAdd(aStruRETN, {"EMISSAO"		, "D", 8						, 0}) //Fecha de Retenci๓n
	aAdd(aStruRETN, {"TIPOCOM"		, "C", 02						, 0}) //Tipo de Comprobante
	aAdd(aStruRETN, {"LETRA"			, "C", 01						, 0}) //Letra de Comprobante
	aAdd(aStruRETN, {"COMPROB"		, "C", TamSX3("FE_ORDPAGO")[1]	, 0}) //Numero de Comprobante
	aAdd(aStruRETN, {"FECHA"			, "C", 10						, 0}) //Fecha de Comprobante
	aAdd(aStruRETN, {"MONTO"			, "N", 16						, 2}) //Monto
	aAdd(aStruRETN, {"NROCERT"		, "C", TamSX3("FE_NROCERT")[1]	, 0}) //Nro Certificado Proprio
	aAdd(aStruRETN, {"TIPODOC"		, "C", 01						, 0}) //Tipo de Documento
	aAdd(aStruRETN, {"DOCUM"			, "C", 11						, 0}) //Numero de Documento
	aAdd(aStruRETN, {"SITIB"			, "C", 01						, 0}) //Situaci๓n Ingresos Brutos
	aAdd(aStruRETN, {"NROIB"			, "C", 11						, 0}) //Nro. Inscrici๓n Ingresos Brutos
	aAdd(aStruRETN, {"SITIVA"		, "C", 01						, 0}) //Situaci๓n IVA
	aAdd(aStruRETN, {"RAZON"			, "C", 30						, 0}) //Raz๓n Social del Retenido
	aAdd(aStruRETN, {"OUTROSCON"	, "N", 16						, 2}) //Otros Conceptos
	aAdd(aStruRETN, {"IVA"			, "N", 16						, 2}) //IVA
	aAdd(aStruRETN, {"MONTOSU"		, "N", 16						, 2}) //Monto Sujeto a Ret./Percep.
	aAdd(aStruRETN, {"ALIQ"			, "N", 6						, 2}) //Alํcuota
	aAdd(aStruRETN, {"RETPRA"		, "N", 16						, 2}) //Ret./Percep. Practicadas
	aAdd(aStruRETN, {"MONTORET"		, "N", 16						, 2}) //Total Monto Retenido
	aAdd(aStruRETN, {"INDICE"		, "C", 1						, 0}) //utilizado na pesquisa do indice para Definir os tipos de documentos e colocar na orden de Ret e depois as percepcoes
	aAdd(aStruRETN, {"ACEPT"		, "C", 01						, 0}) //Aceptacion
	aAdd(aStruRETN, {"FECACPT"		, "D", 8						, 0}) //Fecha de Aceptacion
	

	aOrdem1 := {"INDICE", "NROCERT", "LETRA", "COMPROB", "CODNOR"}
	aOrdem2 := {"EMISSAO", "TIPOPER", "NROCERT", "LETRA", "COMPROB", "CODNOR"}
	aOrdem3 := {"EMISSAO", "NROCERT", "LETRA", "COMPROB", "CODNOR"}
	aOrdem4 := {"NROCERT", "LETRA", "COMPROB", "CODNOR"}
		
	oTmpTRBn := FWTemporaryTable():New("TRBn")
	oTmpTRBn:SetFields(aStruRETN)
	oTmpTRBn:AddIndex("IN1", aOrdem1)
	oTmpTRBn:AddIndex("IN2", aOrdem2)
	oTmpTRBn:AddIndex("IN3", aOrdem3)
	oTmpTRBn:AddIndex("IN4", aOrdem4)
	
	oTmpTRBn:Create()
	
	aAdd(aArqTrab, {'oTmpTRBn', 'TRBn'})

	//Estrutura para NF de credito
	aAdd(aStruRETC, {"TIPOPER"	, "C", 01						, 0}) //Tipo de Operaci๓n
	aAdd(aStruRETC, {"NRONFC"	, "C", 12						, 0}) //Numero da NF de credito
	aAdd(aStruRETC, {"EMISSAO"	, "D", 8						, 0}) //Fecha de NF credito    
	aAdd(aStruRETC, {"MONTO"	, "N", 16						, 2}) //monto
	aAdd(aStruRETC, {"NROCERT"	, "C", TamSX3("FE_NROCERT")[1]	, 0}) //Nro Certificado Proprio
	aAdd(aStruRETC, {"TIPOCOM"	, "C", 02						, 0}) //Tipo de Comprobante
	aAdd(aStruRETC, {"LETRA"	, "C", 01						, 0}) //Letra de Comprobante
	aAdd(aStruRETC, {"COMPROB"	, "C", 16						, 0}) //Numero de Comprobante
	aAdd(aStruRETC, {"CGC"		, "C", 11						, 0}) //Numero de CGC
	aAdd(aStruRETC, {"CODNOR"	, "C", 03						, 0}) //Codigo de Norma
	aAdd(aStruRETC, {"EMISSFE"	, "C", 10						, 0}) //Fecha de Emissao SFE 
	aAdd(aStruRETC, {"MONTPERC"	, "C", 16						, 0}) //Monto percepcao
	aAdd(aStruRETC, {"ALIQ"		, "C", 5						, 0}) //aliquota
	aAdd(aStruRETC, {"SITIB"	, "C", 01						, 0}) //Situaci๓n Ingresos Brutos

	
	aOrdem1 := {"NROCERT", "LETRA", "COMPROB"}
	aOrdem2	:= {"EMISSAO", "NROCERT", "LETRA", "COMPROB"}
		
	oTmpTRBc := FWTemporaryTable():New("TRBc")
	oTmpTRBc:SetFields(aStruRETC)
	oTmpTRBc:AddIndex("IN1", aOrdem1)
	oTmpTRBc:AddIndex("IN2", aOrdem2)
	
	oTmpTRBc:Create()
	
	aAdd(aArqTrab,{'oTmpTRBc','TRBc'})

	If _aTotal[7][1][3] == '1'//Retencao
		FRET()
	ElseIf _aTotal[7][1][3] == '2'//Percepcao
		FPER()	
	ElseIf _aTotal[7][1][3] == '3'//ambos
		FAMB()
	EndIf	

Return aArqTrab

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FRET     บ Autor ณ Totvs              บ Data ณ  03/05/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Genera Archivo de Retenciones                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ARCIBA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FRET() 	

	Local cQueryn := ""
	Local cQueryc := "" 
	Local lRg1415 := .F.
	Local lAutomato := IsBlind()

	If Substr(_aTotal[07][01][04], 1, 1) == "1" //Retencion

		//Query para Retenci๓n 
		cQueryn:=" SELECT '1' TIPOPER,CCP_VDESTI CODNOR,SFE.FE_EMISSAO EMISSAO,F1_RG1415 RG1415 ,' ' TIPOCOM,' ' LETRA,SFE.FE_ORDPAGO COMPROB,"+CRLF
		cQueryn+=" SFE.FE_EMISSAO FECHA,SFE.FE_VALBASE MONTO,SFE.FE_NROCERT NROCERT,SA2.A2_AFIP TIPODOC,SA2.A2_CGC DOCUM, SA2.A2_NIGB NIGB,"+CRLF
		cQueryn+=" CASE WHEN FH_TIPO IS NULL THEN '4'" + CRLF
		cQueryn+=" 		ELSE" + CRLF
		cQueryn+=" 			CASE SFH.FH_TIPO	WHEN 'V' THEN '2'" + CRLF
		cQueryn+="  		   				    WHEN 'N' THEN '4'" + CRLF
		cQueryn+="  		ELSE" + CRLF
		cQueryn+=" 				'1'" + CRLF
		cQueryn+=" 			END" + CRLF 
		cQueryn+=" 		END AS SITIB," + CRLF
		cQueryn+="	CASE WHEN FH_TIPO IS NULL THEN '00000000000' ELSE SA2.A2_NROIB END AS NROIB,"+CRLF
		cQueryn+="        CASE  SA2.A2_TIPO WHEN 'I' THEN '1'" + CRLF   
		cQueryn+="                          WHEN 'N' THEN '2'" + CRLF   
		cQueryn+="                          WHEN 'X' THEN '3'" + CRLF
		cQueryn+="                          WHEN 'M' THEN '4'" + CRLF 
		cQueryn+="	                        ELSE          '5'" + CRLF 
		cQueryn+="				            END SITIVA," + CRLF 
		cQueryn+=" SA2.A2_NOME RAZON,'0000000000000,00' OUTROSCON, FE_VALBASE MONTOSU,FE_ALIQ ALIQ,"+CRLF
		cQueryn+=" SFE.FE_RETENC MONTORET, SFE.FE_VALIMP AS IVA,"+ CRLF		
		cQueryn+=" '' AS ACEPT , '' AS FECACPT " + CRLF	// Pronto para receber a cria็ใo dos campos 'Aceptacion' e 'Fecha de Aceptacion'
		cQueryn+=" FROM "+RetSqlName('SFE')+" SFE"+CRLF
		cQueryn+=" LEFT JOIN "+RetSqlName('SA2')+" SA2"+CRLF 
		cQueryn+=" ON SFE.FE_FORNECE=SA2.A2_COD AND SFE.FE_LOJA=SA2.A2_LOJA AND SA2.A2_FILIAL='"+xFilial('SA2')+"' AND SA2.D_E_L_E_T_=''"+CRLF  
		cQueryn+=" LEFT JOIN (SELECT DISTINCT FH_TIPO,FH_FORNECE,FH_LOJA,FH_FILIAL,D_E_L_E_T_ FROM "+RetSqlName('SFH')+CRLF
		cQueryn+=" WHERE FH_ZONFIS='CF' AND FH_FORNECE <> '') SFH"+CRLF 
		cQueryn+=" ON SFH.FH_FORNECE = SA2.A2_COD AND SFH.FH_LOJA = SA2.A2_LOJA AND SFH.FH_FILIAL='"+xFilial('SFH')+"' AND SFH.FH_TIPO = SA2.A2_TIPO AND SFH.D_E_L_E_T_ =''"+CRLF     
        cQueryn+=" LEFT JOIN "+RetSqlName("CCP")+" ON CCP_VORIGE=SFE.FE_CFO AND "+RetSqlName('CCP')+".D_E_L_E_T_ <> '*'"+CRLF
	    cQueryn+=" LEFT JOIN "+RetSqlName("SF1")+" ON F1_DOC = FE_NFISCAL AND F1_FORNECE = FE_FORNECE AND F1_LOJA = FE_LOJA AND F1_SERIE = FE_SERIE AND "+RetSqlName('SF1')+".D_E_L_E_T_ <> '*'"+CRLF
		cQueryn+=" WHERE FE_FILIAL = '"+xFilial('SFE')+"'"+CRLF
		cQueryn+=" AND SFE.FE_FORNECE <> ''"+CRLF
		cQueryn+=" AND SFE.FE_NROCERT <> 'NORET'"+CRLF
		cQueryn+=" AND SFE.FE_TIPO='B'"+CRLF		
		cQueryn+=" AND SFE.FE_EST='CF'"+CRLF
		cQueryn+=" AND SFE.FE_VALBASE > 0"+CRLF
		cQueryn+=" AND SFE.FE_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
		cQueryn+=" AND (FE_DTESTOR='' OR FE_DTESTOR >'"+DTOS(MV_PAR02)+"')"+CRLF
		cQueryn+=" AND SFE.D_E_L_E_T_ = '' "+CRLF
		If Len(_aTotal[7][1][6]) > 0
			cQueryn+=" AND CCP_COD = '"+(_aTotal[7][1][6])+"'"+CRLF
		EndIf
		cQueryn+=" ORDER BY SFE.FE_EMISSAO"+CRLF		

		cQueryn:=ChangeQuery(cQueryn)	

		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQueryn), "TRAN", .T., .F.)

		TCSetField("TRAN","MONTO"    ,"N",16,02)
		TCSetField("TRAN","MONTOSU"  ,"N",16,02)		
		TCSetField("TRAN","ALIQ"     ,"N",06,02)
		TCSetField("TRAN","MONTORET" ,"N",16,02)
		TCSetField("TRAN","EMISSAO"  ,"D",08,00)
		TCSetField("TRAN","FECHA"    ,"D",08,00)	   	
		TCSetField("TRAN","FECACPT"  ,"D",08,00) // Pronto para receber a cria็ใo dos campos 'Aceptacion' e 'Fecha de Aceptacion'

		TRAn->(dbGotop())

	dbSelectArea("TRBn") 
	dBSEToRDER(4)// "NROCERT+LETRA+COMPROB+CODNOR" 
		While TRAn->(!Eof())

			//cria tabela temporaria para geracao do txt
			If TRBn->(Dbseek(TRAn->NROCERT+TRAn->LETRA+TRAn->COMPROB+TRAn->CODNOR))
 				RecLock("TRBn",.F.) 

				TRBn->MONTO     := TRBn->MONTO + ROUND(TRAn->MONTO,2) 
				TRBn->RETPRA    := TRBn->RETPRA + ROUND(((TRAn->MONTO*TRAn->ALIQ)/100),2)
				TRBn->MONTORET  := TRBn->MONTORET + ROUND(TRAn->MONTORET,2)
				TRBn->MONTOSU:=TRBn->MONTOSU  +ROUND(TRAn->MONTOSU,2)
			
			Else
				RecLock("TRBn",.T.) 
				TRBn->TIPOPER   := TRAn->TIPOPER
				TRBn->CODNOR    := TRAn->CODNOR
				TRBn->EMISSAO   := TRAn->EMISSAO
				lRg1415 := Val(TRAn->RG1415) > 200 
				TRBn->TIPOCOM   := IIF(lRg1415,"12","03") 
				TRBn->LETRA     := TRAn->LETRA    
				TRBn->COMPROB   := PADL(Trim(TRAn->COMPROB),Len(TRBn->COMPROB),"0")
				TRBn->FECHA     := ConvDat(TRAn->FECHA)
				TRBn->MONTO     := ROUND(TRAn->MONTO,2) 
				TRBn->NROCERT   := TRAn->NROCERT  
				SX5->(DbSeek(xFilial()+"OC"+TRAn->TIPODOC ))
				Do Case
					CASE SUBS(SX5->X5_DESCRI,1,2) == '87'
						TRBn->TIPODOC   := '1'
					CASE SUBS(SX5->X5_DESCRI,1,2) == '86'
						TRBn->TIPODOC   := '2'
					CASE SUBS(SX5->X5_DESCRI,1,2) == '80'
						TRBn->TIPODOC   := '3'
					Otherwise
						TRBn->TIPODOC   := '0' 
				EndCase
				TRBn->SITIB     := TRAn->SITIB 
				If  TRBn->SITIB == "4"
					TRBn->DOCUM     := "23000000000"//TRAn->NIGB 
				Else
					TRBn->DOCUM     := TRAn->DOCUM 
				EndIf
				TRBn->NROIB     := TRAn->NROIB
				TRBn->SITIVA    := TRAn->SITIVA
				TRBn->RAZON     := Substr(TRAn->RAZON,1,30)
				If valType(TRAN->OUTROSCON)=="C"
					TRBn->OUTROSCON := Val(TRAN->OUTROSCON)
				Else
					TRBn->OUTROSCON := TRAN->OUTROSCON
				EndIf				
				TRBn->IVA       := Iif( "A" $ alltrim(TRAn->LETRA) .OR. "M" $ alltrim(TRAn->LETRA),ROUND(TRAn->IVA,2),0)
				TRBn->MONTOSU   := ROUND(TRAn->MONTOSU,2)
				TRBn->ALIQ      := ROUND(TRAn->ALIQ,2)
				TRBn->RETPRA    := ROUND(((TRAn->MONTO*TRAn->ALIQ)/100),2)
				TRBn->MONTORET  := ROUND(TRAn->MONTORET,2)
				TRBn->ACEPT   	:= TRAn->ACEPT
				TRBn->FECACPT   := TRAn->FECACPT
			EndIf
			MsUnlock()
			TRAn->(dbSkip())
		End
		
		dbSelectArea("TRBn")
		dBSEToRDER(3)//"DTOS(EMISSAO)+NROCERT+LETRA+COMPROB+CODNOR"
    
		If !lAutomato
			If MsgYesNo(STR0001)//"ฟVerificar los datos para la exportacion?"
				TRelARCIBA('TRBn')
			EndIf
		EndIf

		TRAn->(dbCloseArea())

	ElseIf Substr(_aTotal[07][01][04], 1, 1) == "2"  

		//Query para Estorno de retencion 
		cQueryc := " SELECT '1' TIPOPER,CASE WHEN SFE.FE_ORDPAGO='' THEN SFE.FE_NFISCAL ELSE SFE.FE_ORDPAGO END NRONFC,SFE.FE_EMISSAO EMISSAO,"+CRLF
		cQueryc += " SFE.FE_VALBASE MONTO,SFE.FE_NRETORI NROCERT,F1_RG1415 RG1415 ,' ' TIPOCOM,' ' LETRA,SFE.FE_ORDPAGO COMPROB"+CRLF
		cQueryc += " FROM " + RetSqlName('SFE') + " SFE" + CRLF
		cQueryc += " LEFT JOIN "+RetSqlName("SF1")+" ON F1_DOC = FE_NFISCAL AND F1_FORNECE = FE_FORNECE AND F1_LOJA = FE_LOJA AND "+RetSqlName('SF1')+".D_E_L_E_T_ <> '*'"+CRLF
		cQueryc += " WHERE FE_FILIAL = '" + xFilial('SFE') + "'" + CRLF
		cQueryc += " AND SFE.FE_FORNECE <>''" + CRLF
		cQueryc += " AND SFE.FE_NROCERT <> 'NORET' " + CRLF
		cQueryc += " AND SFE.FE_TIPO = 'B'" + CRLF
		cQueryc += " AND SFE.FE_EST = 'CF'" + CRLF
		cQueryc += " AND SFE.FE_VALBASE < 0 " + CRLF
		cQueryc += " AND SFE.FE_DTRETOR <= '" + DTOS(MV_PAR01) + "'" + CRLF			
		cQueryc += " AND SFE.FE_DTESTOR BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'" + CRLF

		cQueryc += " AND SFE.D_E_L_E_T_ = '' " + CRLF
		cQueryc += " ORDER BY SFE.FE_NRETORI " + CRLF

		cQueryc := ChangeQuery(cQueryc)	

		dbUseArea(.T., "TOPCONN",TcGenQry( , , cQueryc), "TRAc", .T., .F.)

		TCSetField("TRAc", "MONTO"	, "N", 12, 02)
		TCSetField("TRAc", "EMISSAO", "D", 08, 00)

		TRAc->(dbGotop())



		dbSelectArea("TRBc")
		DbSetOrder(1)//"NROCERT+LETRA+COMPROB"
			
		While TRAc->(!Eof())
			If Empty(TRAc->NROCERT)        
				CTpCert := "2"
			Else
				CTpCert := "1"
			EndIf

			If TRBc->(Dbseek(CTpCert +TRAc->NROCERT+TRAc->LETRA+TRAc->COMPROB))
 				RecLock("TRBc",.F.) 
				TRBc->MONTO   :=  TRBc->MONTO +(ROUND(If(TRAc->MONTO < 0,TRAc->MONTO *(-1),TRAc->MONTO),2)  )
			ElseIf RecLock("TRBc",.T.) 
				TRBc->TIPOPER := TRAc->TIPOPER
				TRBc->NRONFC  := TRAc->NRONFC
				TRBc->EMISSAO := TRAc->EMISSAO
				TRBc->MONTO   := ROUND(IIf(TRAc->MONTO < 0, TRAc->MONTO * (-1), TRAc->MONTO), 2) 
				TRBc->NROCERT := TRAc->NROCERT 
				lRg1415 := Val(TRAc->RG1415) > 200 
				TRBc->TIPOCOM   := IIF(lRg1415,"12","03")  
				TRBc->LETRA   := TRAc->LETRA    
				TRBc->COMPROB := Padl(TRAc->COMPROB,16,"0")
			EndIf
			MsUnlock()
			TRAc->(dbSkip())
		End
	    
	    dbSelectArea("TRBc")
		DbSetOrder(2)//"DTOS(EMISSAO)+NROCERT+LETRA+COMPROB"

		If !lAutomato
			If MsgYesNo(STR0001)//"ฟVerificar los datos para la exportacion?"
				TRelARCIBA('TRBc')
			EndIf
		EndIf

		TRAc->(dbCloseArea())
	EndIf
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FPERC    บ Autor ณ Totvs              บ Data ณ  08/04/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Genera Archivo de Percepcion                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ARCIBA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FPER()

	Local cQueryn := ""
	Local cQueryc := "" 
	Local aLivros := {}
	Local aLivroM := {}
	Local nBas    := 0
	Local nAliq   := 0
	Local nVal    := 0
	Local SqlIva   := ""
	Local ValIVA  := ""
	Local lRg1415 := .F.
	Local lAutomato := IsBlind()
	//busca numero dos livros no arquivo SFB e monta o campo de acordo com on numero do livro
	aLivros := BUSCASFB()
	aLivroM:=BUSCAMONTOSFB()

	If Len(aLivros)	<> 0

		If Substr(_aTotal[07][01][04], 1, 1) == "1" 
		    If cTpBco $ "POSTGRES|ORACLE"
				SqlIva:= "SELECT CONCAT('SF3.F3_VALIMP', FB_COLVAL) AS FB_COLVAL"
		    Else
		    	SqlIva:= "Select ('SF3.F3_VALIMP' + Cast(FB_COLVAL as char(1))) as FB_COLVAL" 
		    EndIf
		    SqlIva += " FROM " + RetSqlName('SFB')+ " where FB_CODIGO = 'IVA' and FB_FILIAL = '" + xFilial('SA1')+"'"
		    
		    SqlIva:= ChangeQuery(SqlIva)	
		    dbUseArea(.T.,"TOPCONN",TcGenQry(,,SqlIva),"TRAN1",.T.,.F.)
		    ValIVA   := TRAn1->FB_COLVAL

			//Query para Percepcion 
			cQueryn := " SELECT '2' TIPOPER,CCP_VDESTI CODNOR,SF3.F3_EMISSAO EMISSAO,"+CRLF
			cQueryn += " SF3.F3_ESPECIE AS GM1, SF3.F3_SERIE GM2,"
			cQueryn += " SF3.F3_SERIE LETRA,SF3.F3_NFISCAL COMPROB,SF3.F3_EMISSAO FECHA,SF3.F3_VALCONT MONTO,SF3.F3_RG1415 RG1415,"+CRLF
			cQueryn+=" '' NROCERT,SA1.A1_AFIP TIPODOC,SA1.A1_CGC DOCUM,SA1.A1_NIGB NIGB,"+CRLF
			cQueryn += " CASE WHEN FH_TIPO IS NULL THEN '4'"+CRLF
			cQueryn += " 		ELSE"+CRLF
			cQueryn += " 			CASE SFH.FH_TIPO	WHEN 'V' THEN '2'"+CRLF
			cQueryn += "  		   				    WHEN 'N' THEN '4'"+CRLF
			cQueryn += "  		ELSE"+CRLF
			cQueryn += " 				'1'"+CRLF
			cQueryn += " 			END"+CRLF
			cQueryn += " 		END AS SITIB,"+CRLF
			cQueryn+="	CASE WHEN FH_TIPO IS NULL THEN '00000000000' ELSE SA1.A1_NROIB END AS NROIB,"+CRLF
			cQueryn += "        CASE  SA1.A1_TIPO WHEN 'I' THEN '1'"+CRLF
			cQueryn += "                          WHEN 'N' THEN '2'"+CRLF
			cQueryn += "     		                WHEN 'X' THEN '3'"+CRLF
			cQueryn += "				            WHEN 'M' THEN '4'"+CRLF
			cQueryn += "		  ELSE                            '5'"+CRLF
			cQueryn += "		  END AS SITIVA,"+CRLF
			cQueryn+=" SA1.A1_NOME RAZON, "+CRLF
			For nBas:=1 To Len(aLivroM)
		
				If nBas < Len(aLivroM)
					cQueryn+=" SF3.F3_VALIMP"+aLivroM[nBas]+"+"+CRLF
				Else	
					cQueryn+=" SF3.F3_VALIMP"+aLivroM[nBas]+" "	+CRLF
				EndIf
	
			Next		
			cQueryn+=" AS OUTROSCON,"+CRLF			
				
			// ADICIONA CAMPOS DE ACORDO COM O NUMERO DO LIVRO FISCAL EX: F3_BASIMP+1 == BASIMP1
			//CASO EXISTA MAIS DE UM LIVRO OS CAMPOS SERAO SOMADOS   EX: BASIMP1 + BASIMP2 ...    
			
			//BASE PARA IMPOSTO
			For nBas:=1 To Len(aLivros)
		
				If nBas < Len(aLivros)
					cQueryn+=" SF3.F3_BASIMP"+aLivros[nBas]+"+"+CRLF
				Else	
					cQueryn+=" SF3.F3_BASIMP"+aLivros[nBas]+" "	+CRLF
				EndIf
	
			Next		
			cQueryn+=" AS MONTOSU,"+CRLF
			
			//ALIQUOTA			
			For nAliq:=1 To Len(aLivros)
	
				If nAliq <  Len(aLivros) 
					cQueryn+=" SF3.F3_ALQIMP"+aLivros[nAliq]+"+"+CRLF
				Else
					cQueryn+=" SF3.F3_ALQIMP"+aLivros[nAliq]+" "+CRLF		
				EndIf
	
			Next	
			cQueryn+=" AS ALIQ,"+CRLF
			
			//TOTAL MONTO RETIDO 		
			For nVal:=1 To Len(aLivros)
	
				If nVal  <  Len(aLivros)  
					cQueryn+=" SF3.F3_VALIMP"+aLivros[nVal]+"+"+CRLF
				Else
					cQueryn+=" SF3.F3_VALIMP"+aLivros[nVal]+" "+CRLF
				EndIf		
	
			Next		
			cQueryn+=" AS MONTORET, "+ ValIVA +" AS IVA"+ CRLF
			
			cQueryn+=" FROM "+RetSqlName('SF3')+" SF3"+CRLF
			cQueryn+=" LEFT JOIN "+RetSqlName('SA1')+" SA1"+CRLF
	       cQueryn+=" ON SF3.F3_CLIEFOR=SA1.A1_COD AND SF3.F3_LOJA=SA1.A1_LOJA AND SA1.A1_FILIAL='"+xFilial('SA1')+"' AND SA1.D_E_L_E_T_=''"+CRLF
			cQueryn+=" LEFT JOIN (SELECT  DISTINCT FH_TIPO,FH_CLIENTE,FH_LOJA,FH_FILIAL,D_E_L_E_T_ FROM "+RetSqlName('SFH')+CRLF      
			cQueryn+=" WHERE FH_ZONFIS='CF' AND FH_CLIENTE <>'') SFH"+CRLF	
	       cQueryn+=" ON SFH.FH_CLIENTE = SA1.A1_COD AND SFH.FH_LOJA = SA1.A1_LOJA AND SFH.FH_FILIAL='"+xFilial('SFH')+"' AND SFH.D_E_L_E_T_ =''"+CRLF     
			cQueryn+=" 	LEFT JOIN "+RetSqlName('CCP')+" ON CCP_VORIGE=SF3.F3_CFO AND "+RetSqlName('CCP')+".D_E_L_E_T_ <> '*' "+CRLF
			cQueryn+=" WHERE F3_FILIAL = '"+xFilial('SF3')+"'"+CRLF
			cQueryn+=" AND F3_TIPOMOV='V'"+CRLF
			For nVal:=1 To Len(aLivros)		
				cQueryn+=" AND SF3.F3_BASIMP"+aLivros[1]+" <> 0 "+CRLF
			Next
			cQueryn+=" AND SUBSTRING(SF3.F3_ESPECIE,1,2) <> 'NC'"+CRLF
			cQueryn+=" AND SF3.F3_EMISSAO BETWEEN '"+dTOs(MV_PAR01)+ "' AND '"+dTOs(MV_PAR02)+"'"+CRLF
		    cQueryn+=" AND SF3.F3_DTCANC=''"
		    cQueryn+=" AND SF3.D_E_L_E_T_ = ''"+CRLF
		    If Len(_aTotal[7][1][5]) > 0
		      cQueryn+=" AND CCP_COD = '"+(_aTotal[7][1][5])+"'"+CRLF
		    EndIf
			cQueryn+=" ORDER BY SF3.F3_EMISSAO"+CRLF
		
			cQueryn:=ChangeQuery(cQueryn)	
	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryn),"TRAN",.T.,.F.)
			
			TCSetField("TRAN","MONTO"   ,"N",16,02)
			TCSetField("TRAN","MONTOSU" ,"N",16,02)
			TCSetField("TRAN","ALIQ"    ,"N",06,02)		
			TCSetField("TRAN","MONTORET","N",16,02)
			TCSetField("TRAN","EMISSAO" ,"D",08,00)
			TCSetField("TRAN","FECHA"   ,"D",08,00)

			TRAn->(dbGotop())

			While TRAn->(!Eof())

				dbSelectArea("TRBn")

				If (TRAn->MONTORET > 0) 
				If RecLock("TRBn",.T.) 
					TRBn->TIPOPER   := TRAn->TIPOPER
					TRBn->CODNOR    := TRAn->CODNOR
					TRBn->EMISSAO   := TRAn->EMISSAO
					lRg1415 := Val(TRAn->RG1415) > 200 
					TRBn->TIPOCOM   := IIf(SUBSTR(TRAn->GM1, 1, 2) $ "NF" .Or. lRg1415 , TipoCom(TRAn->GM1,TRAn->GM2,TRAn->RG1415), "09")
					TRBn->LETRA     := TRAn->LETRA    
					TRBn->COMPROB   := PADL(Trim(TRAn->COMPROB),Len(TRBn->COMPROB),"0")
					TRBn->FECHA     := ConvDat(TRAn->FECHA)
					TRBn->MONTO     := ROUND(TRAn->MONTO,2) 
					TRBn->NROCERT   := TRAn->NROCERT  
						
						SX5->(DbSeek(xFilial()+"OC"+TRAn->TIPODOC ))
						Do Case
							CASE SUBS(SX5->X5_DESCRI,1,2) == '87'
								TRBn->TIPODOC   := '1'
							CASE SUBS(SX5->X5_DESCRI,1,2) == '86'
								TRBn->TIPODOC   := '2'
							CASE SUBS(SX5->X5_DESCRI,1,2) == '80'
								TRBn->TIPODOC   := '3'
							Otherwise
								TRBn->TIPODOC   := '0' 
						EndCase
					TRBn->SITIB     := TRAn->SITIB
					If TRBn->SITIB == "4"
						TRBn->DOCUM     := "23000000000"//TRAn->NIGB 
					Else
						TRBn->DOCUM     := TRAn->DOCUM 
					EndIF
					TRBn->NROIB     := TRAn->NROIB
					TRBn->SITIVA    := TRAn->SITIVA
					TRBn->RAZON     := SubStr(TRAn->RAZON,1,30)
						TRBn->OUTROSCON := TRAN->OUTROSCON + ROUND(TRAn->MONTORET,2)
						TRBn->IVA       := Iif("A" $ alltrim(TRAn->LETRA) .OR. "M" $ alltrim(TRAn->LETRA),ROUND(TRAn->IVA,2),0)
					TRBn->MONTOSU   := ROUND(TRAn->MONTOSU,2)
					TRBn->ALIQ      := ROUND(TRAn->ALIQ,2)
					TRBn->RETPRA    := ROUND(TRAn->MONTORET,2)
					TRBn->MONTORET  := ROUND(TRAn->MONTORET,2)
				EndIf
				EndIf
				MsUnlock()
				TRAn->(dbSkip())
			End
			dbSelectArea("TRBn")
			DbSetOrder(2) //"EMISSAO", "TIPOPER", "NROCERT", "LETRA", "COMPROB", "CODNOR"
	       	If !lAutomato
				If MsgYesNo(STR0001)//"ฟVerificar los datos para la exportacion?"
					TRelARCIBA('TRBn')
				EndIf
			EndIf
		ElseIf Substr(_aTotal[07][01][04],1,1) == "2"

			//QUERY PARA  NF DE CREDITO
			cQueryc := " SELECT '2' TIPOPER,SF3.F3_NFISCAL NRONFC,SF3.F3_EMISSAO EMISSAO,"+CRLF
			//BASE PARA IMPOSTO
			For nBas := 1 To Len(aLivros)
				If nBas < Len(aLivros)
					cQueryc += " SF3.F3_BASIMP" + aLivros[nBas] + "+"	+ CRLF
				Else	
					cQueryc += " SF3.F3_BASIMP" + aLivros[nBas] + " " + CRLF
				EndIf
			Next	
			cQueryc+=" AS MONTO,"+CRLF	
			For nBas := 1 To Len(aLivros)
				If nBas < Len(aLivros)
					cQueryc += " SF3.F3_VALIMP" + aLivros[nBas] + "+"	+ CRLF
				Else	
					cQueryc += " SF3.F3_VALIMP" + aLivros[nBas] + " " + CRLF
				EndIf
			Next
			cQueryc+=" AS MONTPERC,"+CRLF
			For nBas := 1 To Len(aLivros)
				If nBas < Len(aLivros)
					cQueryc += " SF3.F3_ALQIMP" + aLivros[nBas] + "+"	+ CRLF
				Else	
					cQueryc += " SF3.F3_ALQIMP" + aLivros[nBas] + " " + CRLF
				EndIf
			Next	
			cQueryc+=" AS ALIQ,"+CRLF
			cQueryc+=" ' '  NROCERT,"+CRLF
			cQueryc+=" CASE WHEN EXISTS(SELECT D2_ESPECIE FROM "+RetSqlName('SD2')+" WHERE D2_DOC=SD2.D2_NFORI AND D2_SERIE=SD2.D2_SERIORI AND D2_CLIENTE=SD2.D2_CLIENTE AND D2_LOJA=SD2.D2_LOJA AND SD2.D_E_L_E_T_='' AND D2_FILIAL=SD2.D2_FILIAL " + IIf(cTpBco =="ORACLE", " AND ROWNUM = 1", "") + ") THEN"+CRLF 
			cQueryc+="      (SELECT D2_ESPECIE FROM "+RetSqlName('SD2')+" WHERE" + IIf(cTpBco =="ORACLE", " ROWNUM = 1 AND ", " ") + "D2_DOC=SD2.D2_NFORI AND D2_SERIE=SD2.D2_SERIORI AND D2_CLIENTE=SD2.D2_CLIENTE AND D2_LOJA=SD2.D2_LOJA AND SD2.D_E_L_E_T_='' AND D2_FILIAL=SD2.D2_FILIAL)"+CRLF 
			cQueryc+=" ELSE"+CRLF 
			cQueryc+="		CASE WHEN EXISTS(SELECT D2_ESPECIE FROM "+RetSqlName('SD2')+" WHERE D2_DOC=SD1.D1_NFORI AND D2_SERIE=SD1.D1_SERIORI AND D2_CLIENTE=SD1.D1_FORNECE AND D2_LOJA=SD1.D1_LOJA AND SD1.D_E_L_E_T_='' AND D2_FILIAL=SD1.D1_FILIAL " + IIf(cTpBco =="ORACLE", " AND ROWNUM = 1", "") + ") THEN"+CRLF 
			cQueryc+="  		(SELECT D2_ESPECIE FROM "+RetSqlName('SD2')+" WHERE" + IIf(cTpBco =="ORACLE", " ROWNUM = 1 AND ", " ") + "D2_DOC=SD1.D1_NFORI AND D2_SERIE=SD1.D1_SERIORI AND D2_CLIENTE=SD1.D1_FORNECE AND D2_LOJA=SD1.D1_LOJA AND SD1.D_E_L_E_T_='' AND D2_FILIAL=SD1.D1_FILIAL)"+CRLF 
			cQueryc+=" 		ELSE"+CRLF 
			cQueryc+="  		CASE WHEN EXISTS(SELECT D1_ESPECIE FROM "+RetSqlName('SD1')+" WHERE D1_DOC=SD1.D1_NFORI AND D1_SERIE=SD1.D1_SERIORI AND D1_FORNECE=SD1.D1_FORNECE AND D1_LOJA=SD1.D1_LOJA AND SD1.D_E_L_E_T_='' AND D1_FILIAL=SD1.D1_FILIAL " + IIf(cTpBco =="ORACLE", " AND ROWNUM = 1", "") + ") THEN"+CRLF 
			cQueryc+=" 				(SELECT D1_ESPECIE FROM "+RetSqlName('SD1')+" WHERE" + IIf(cTpBco =="ORACLE", " ROWNUM = 1 AND ", " ") + "D1_DOC=SD1.D1_NFORI AND D1_SERIE=SD1.D1_SERIORI AND D1_FORNECE=SD1.D1_FORNECE AND D1_LOJA=SD1.D1_LOJA AND SD1.D_E_L_E_T_='' AND D1_FILIAL=SD1.D1_FILIAL)"+CRLF 
			cQueryc+="  		ELSE"+CRLF 
			cQueryc+=" 				CASE WHEN EXISTS(SELECT D1_ESPECIE FROM "+RetSqlName('SD1')+" WHERE D1_DOC=SD2.D2_NFORI AND D1_SERIE=SD2.D2_SERIORI AND D1_FORNECE=SD2.D2_CLIENTE AND D1_LOJA=SD2.D2_LOJA AND SD2.D_E_L_E_T_='' AND D1_FILIAL=SD2.D2_FILIAL " + IIf(cTpBco =="ORACLE", " AND ROWNUM = 1", "") + ") THEN"+CRLF 
			cQueryc+=" 					(SELECT D1_ESPECIE FROM "+RetSqlName('SD1')+" WHERE" + IIf(cTpBco =="ORACLE", " ROWNUM = 1 AND ", " ") + "D1_DOC=SD2.D2_NFORI AND D1_SERIE=SD2.D2_SERIORI AND D1_FORNECE=SD2.D2_CLIENTE AND D1_LOJA=SD2.D2_LOJA AND SD2.D_E_L_E_T_='' AND D1_FILIAL=SD2.D2_FILIAL)"+CRLF 
			cQueryc+="  			ELSE"+CRLF 
			cQueryc+="  				CASE WHEN SD1.D1_ESPECIE='NCC' THEN" +CRLF
			cQueryc+=" 						' '"+CRLF 
			cQueryc+=" 			   		ELSE"+CRLF 
			cQueryc+=" 						' '"+CRLF 
			cQueryc+=" 					END"+CRLF 
			cQueryc+="  			END"+CRLF 
			cQueryc+="  		END"+CRLF 
			cQueryc+=" 		END"+CRLF 
			cQueryc+=" END AS GM1,"+CRLF 
			cQueryc+=" CASE WHEN EXISTS(SELECT D2_ESPECIE FROM "+RetSqlName('SD2')+" WHERE D2_DOC=SD2.D2_NFORI AND D2_SERIE=SD2.D2_SERIORI AND D2_CLIENTE=SD2.D2_CLIENTE AND D2_LOJA=SD2.D2_LOJA AND SD2.D_E_L_E_T_='' AND D2_FILIAL=SD2.D2_FILIAL" + IIf(cTpBco =="ORACLE", " AND ROWNUM = 1", "") + ") THEN"+CRLF
			cQueryc+="		SD2.D2_SERIORI"+CRLF 
			cQueryc+=" ELSE"+CRLF 
			cQueryc+="		CASE WHEN EXISTS(SELECT D2_ESPECIE FROM "+RetSqlName('SD2')+" WHERE D2_DOC=SD1.D1_NFORI AND D2_SERIE=SD1.D1_SERIORI AND D2_CLIENTE=SD1.D1_FORNECE AND D2_LOJA=SD1.D1_LOJA AND SD1.D_E_L_E_T_='' AND D2_FILIAL=SD1.D1_FILIAL" + IIf(cTpBco =="ORACLE", " AND ROWNUM = 1", "") + ") THEN"+CRLF 
			cQueryc+="  		SD1.D1_SERIORI"+CRLF 
			cQueryc+=" 		ELSE"+CRLF 
			cQueryc+="  		CASE WHEN EXISTS(SELECT D1_ESPECIE FROM "+RetSqlName('SD1')+" WHERE D1_DOC=SD1.D1_NFORI AND D1_SERIE=SD1.D1_SERIORI AND D1_FORNECE=SD1.D1_FORNECE AND D1_LOJA=SD1.D1_LOJA AND SD1.D_E_L_E_T_='' AND D1_FILIAL=SD1.D1_FILIAL" + IIf(cTpBco =="ORACLE", " AND ROWNUM = 1", "") + ") THEN"+CRLF 
			cQueryc+=" 				SD1.D1_SERIORI"+CRLF 
			cQueryc+="  		ELSE"+CRLF 
			cQueryc+=" 				CASE WHEN EXISTS(SELECT D1_ESPECIE FROM "+RetSqlName('SD1')+" WHERE D1_DOC=SD2.D2_NFORI AND D1_SERIE=SD2.D2_SERIORI AND D1_FORNECE=SD2.D2_CLIENTE AND D1_LOJA=SD2.D2_LOJA AND SD2.D_E_L_E_T_='' AND D1_FILIAL=SD2.D2_FILIAL" + IIf(cTpBco =="ORACLE", " AND ROWNUM = 1", "") + ") THEN"+CRLF 
			cQueryc+=" 					SD2.D2_SERIORI"+CRLF 
			cQueryc+="  			ELSE"+CRLF 
			cQueryc+="  				CASE WHEN SD1.D1_ESPECIE='NCC' THEN"+CRLF 
			cQueryc+=" 						SD1.D1_SERIE"+CRLF 
			cQueryc+=" 					ELSE"+CRLF 
			cQueryc+=" 						SD2.D2_SERIE"+CRLF 
			cQueryc+=" 					END"+CRLF 
			cQueryc+="  			END"+CRLF 
			cQueryc+="  		END"+CRLF 
			cQueryc+=" 		END"+CRLF 
			cQueryc+=" END AS GM2,"+CRLF
			cQueryc+=" CASE WHEN SF3.F3_ESPECIE ='NCC' THEN"+CRLF   
			cQueryc+=" 		CASE WHEN SD1.D1_SERIORI <> '' THEN"
			cQueryc+=" 			SD1.D1_SERIORI"
			cQueryc+=" 		ELSE"
			cQueryc+=" 			SD1.D1_SERIE"
			cQueryc+=" 		END"					
			cQueryc+=" ELSE"+CRLF 
			cQueryc+="		CASE WHEN SD2.D2_SERIORI <> '' THEN"
			cQueryc+="			SD2.D2_SERIORI"
			cQueryc+=" 		ELSE"
			cQueryc+=" 			SD2.D2_SERIE"
			cQueryc+="		END"								
			cQueryc+=" END LETRA,"+CRLF 	
			cQueryc+=" CASE WHEN SF3.F3_ESPECIE ='NCC' THEN"+CRLF   
			cQueryc+=" 		SD1.D1_NFORI"+CRLF 
			cQueryc+=" ELSE"+CRLF 
			cQueryc+=" 		SD2.D2_NFORI"+CRLF 
			cQueryc+=" END  COMPROB ,SA1.A1_CGC as CGC,CCP.CCP_VDESTI AS CODNOR,"+CRLF 
			cQueryc+=" SF3.F3_VALIMP"+aLivros[1]+" AS MONTPERC,"+CRLF 
			cQueryc+=" SF3.F3_ALQIMP"+aLivros[1]+" AS ALIQ, "+CRLF 
			cQueryc += " CASE WHEN FH_TIPO IS NULL THEN '4'"+CRLF
			cQueryc += " 		ELSE"+CRLF
			cQueryc += " 			CASE SFH.FH_TIPO	WHEN 'V' THEN '2'"+CRLF
			cQueryc += "  		   				    WHEN 'N' THEN '4'"+CRLF
			cQueryc += "  		ELSE"+CRLF
			cQueryc += " 				'1'"+CRLF
			cQueryc += " 			END"+CRLF
			cQueryc += " 		END AS SITIB "+CRLF
			cQueryc+=" FROM     "+RetSqlName('SF3')+" SF3"+CRLF 
			cQueryc+=" LEFT JOIN "+RetSqlName('SD1')+" SD1"+CRLF
			cQueryc+=" ON SD1.D1_FILIAL  =SF3.F3_FILIAL"+CRLF 
			cQueryc+=" AND SD1.D1_DOC    =SF3.F3_NFISCAL"+CRLF 
			cQueryc+=" AND SD1.D1_SERIE  =SF3.F3_SERIE"+CRLF  
			cQueryc+=" AND SD1.D1_ESPECIE=SF3.F3_ESPECIE"+CRLF  
			cQueryc+=" AND SD1.D1_FORNECE=SF3.F3_CLIEFOR"+CRLF  
			cQueryc+=" AND SD1.D1_LOJA   =SF3.F3_LOJA"  +CRLF 
			cQueryc+=" AND SD1.D_E_L_E_T_=''"+CRLF
			cQueryc+=" LEFT JOIN "+RetSqlName('SD2')+" SD2"+CRLF
			cQueryc+=" ON SD2.D2_FILIAL =SF3.F3_FILIAL"+CRLF 
			cQueryc+=" AND SD2.D2_DOC    =SF3.F3_NFISCAL"+CRLF  
			cQueryc+=" AND SD2.D2_SERIE  =SF3.F3_SERIE"+CRLF  
			cQueryc+=" AND SD2.D2_ESPECIE=SF3.F3_ESPECIE"+CRLF  
			cQueryc+=" AND SD2.D2_CLIENTE=SF3.F3_CLIEFOR"+CRLF 
			cQueryc+=" AND SD2.D2_LOJA   =SF3.F3_LOJA"+CRLF  
			cQueryc+=" AND SD2.D_E_L_E_T_=''"+CRLF
			cQueryc+=" LEFT JOIN "+RetSqlName('SA1')+" SA1"+CRLF 
			cQueryc+=" ON SA1.A1_COD  =SF3.F3_CLIEFOR"+CRLF 
			cQueryc+=" AND SA1.A1_LOJA  =SF3.F3_LOJA"+CRLF
			cQueryc+=" AND SA1.D_E_L_E_T_=''"+CRLF	
			cQueryc+=" LEFT JOIN (SELECT  DISTINCT FH_TIPO,FH_CLIENTE,FH_LOJA,FH_FILIAL,D_E_L_E_T_ FROM "+RetSqlName('SFH')+CRLF      
			cQueryc+=" WHERE FH_ZONFIS='CF' AND FH_CLIENTE <>'') SFH"+CRLF	
	        cQueryc+=" ON SFH.FH_CLIENTE = SA1.A1_COD AND SFH.FH_LOJA = SA1.A1_LOJA AND SFH.FH_FILIAL='"+xFilial('SFH')+"' AND SFH.D_E_L_E_T_ =''"+CRLF     
			cQueryc+=" LEFT JOIN "+RetSqlName('CCP')+" CCP"+CRLF
			cQueryc+=" ON CCP_COD=SF3.F3_CFO"+CRLF 
			cQueryc+=" AND CCP.D_E_L_E_T_=''"+CRLF
			cQueryc+=" WHERE F3_FILIAL = '"+xFilial('SF3')+"'"+CRLF
			cQueryc+=" AND F3_TIPOMOV='V'"+CRLF 
			cQueryc+=" AND SF3.F3_BASIMP"+aLivros[1]+" <> 0 "+CRLF
			cQueryc+=" AND SUBSTRING(F3_ESPECIE,1,2)='NC'"+CRLF 
			cQueryc+=" AND SF3.F3_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
			cQueryc+=" AND SF3.F3_DTCANC=''"+CRLF 
			cQueryc+=" AND SF3.D_E_L_E_T_ = ''"+CRLF 
	

			cQueryc := ChangeQuery(cQueryc)	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryc),"TRAc",.T.,.F.)

			TCSetField("TRAc","MONTO"  ,"N",12,02)
			TCSetField("TRAc","EMISSAO","D",08,00)

			TRAc->(dbGotop())

			While TRAc->(!Eof())

				dbSelectArea("TRBc")

				If RecLock("TRBc",.T.) 
					TRBc->TIPOPER := TRAc->TIPOPER
					TRBc->NRONFC  := TRAc->NRONFC
					TRBc->EMISSAO := TRAc->EMISSAO
					TRBc->MONTO   := ROUND(If(TRAc->MONTO < 0,TRAc->MONTO *(-1),TRAc->MONTO),2) 
					TRBc->NROCERT := TRAc->NROCERT  
					TRBc->TIPOCOM := IIf(SUBSTR(TRAc->GM1, 1, 2) = "NF", TipoCom(TRAc->GM1,TRAc->GM2), "09") //TIPOCOM(TRAc->GM1,TRAc->GM2)
					TRBc->LETRA   := TRAc->LETRA 
					If !Empty(TRAc->COMPROB)   
			      		TRBc->COMPROB := Padl(TRAc->COMPROB,16,"0")
					Else 
	                	TRBc->COMPROB := TRAc->NRONFC
					EndIf
			     	IF TRBc->SITIB == "4"
						TRBc->CGC   := "23000000000"
					Else
						TRBc->CGC   := TRAc->CGC
					EndIf
					TRBc->CODNOR   := TRAc->CODNOR
					TRBc->EMISSFE   := IIf(ValType(TRAc->EMISSAO) == "D", DtoC(TRAc->EMISSAO), TRAc->EMISSAO)
					TRBc->MONTPERC   := PadL(AllTrim(Transform(TRAc->MONTPERC,"@E 9999999999999.99")),16,"0")
					TRBc->ALIQ   := PadL(Alltrim(Transform(TRAc->ALIQ,"@E 99.99")),5,"0")
				EndIf
				MsUnlock()
				TRAc->(dbSkip())
			EndDo
			dbSelectArea("TRBc")
			DbSetOrder(2) //"EMISSAO", "TIPOPER", "NROCERT", "LETRA", "COMPROB", "CODNOR"
	       	If !lAutomato
				If MsgYesNo(STR0001)//"ฟVerificar los datos para la exportacion?"
					TRelARCIBA('TRBc')
				EndIf
			EndIf
			TRAc->(dbCloseArea())  
		EndIf
	EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FAMB     บ Autor ณ Totvs              บ Data ณ  08/04/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Genera Archivo de Retenciones/Percepciones                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ARCIBA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FAMB()

	Local cQueryn	:= ""
	Local cQueryc	:= ""    
	Local aLivros	:= {}
	Local aLivroM	:= {}
	Local nBas		:= 0
	Local nAliq		:= 0
	Local nVal		:= 0
	Local SqlIvaA	:= ""
	Local ValIVAA	:= ""
	Local lRg1415	:= .F.
	Local lAutomato := IsBlind()

	aLivros := BUSCASFB()
	aLivroM := BUSCAMONTOSFB()		

	If Len(aLivros)	<> 0
		If Substr(_aTotal[07][01][04], 1, 1) == "1"

			If cTpBco =="ORACLE"
				SqlIvaA:= "SELECT CONCAT('SF3.F3_VALIMP', FB_COLVAL) AS FB_COLVAL"
			Else
		    	SqlIvaA:= "Select ('SF3.F3_VALIMP' + Cast(FB_COLVAL as char(1))) as FB_COLVAL"		    
		    EndIf
		    SqlIvaA += " FROM " + RetSqlName('SFB')+ " where FB_CODIGO = 'IVA' and FB_FILIAL = '" + xFilial('SA1')+"'"
		    
			SqlIvaA := ChangeQuery(SqlIvaA)	
			dbUseArea(.T., "TOPCONN",TcGenQry( , , SqlIvaA), "TRAN1", .T., .F.)
			ValIVAA := TRAn1->FB_COLVAL		
			//Query para Retenci๓n do tipo normal
			cQueryn := " SELECT '1' TIPOPER,CCP_VDESTI CODNOR,SFE.FE_EMISSAO EMISSAO,' ' AS GM1, ' ' AS GM2,' ' LETRA,SFE.FE_ORDPAGO COMPROB,"+CRLF
			cQueryn += " SFE.FE_EMISSAO FECHA,SFE.FE_VALBASE MONTO,SFE.FE_NROCERT NROCERT,SA2.A2_AFIP TIPODOC,SA2.A2_CGC DOCUM, SA2.A2_NIGB NIGB,"+CRLF
			cQueryn += " CASE WHEN fh_tipo IS NULL THEN '4' "+CRLF 
			cQueryn += "   ELSE "+CRLF
			cQueryn += " CASE SFH.fh_tipo "+CRLF 
			cQueryn += "   WHEN 'I' THEN '1' "+CRLF
			cQueryn += "   WHEN 'N' THEN '4' "+CRLF
			cQueryn += "   WHEN 'X' THEN '1' "+CRLF
			cQueryn += "   WHEN 'M' THEN '5' "+CRLF
			cQueryn += "   WHEN 'V' THEN '2' "+CRLF
			cQueryn += "  ELSE '1'  "+CRLF
			cQueryn += " END "+CRLF
			cQueryn += " END  AS SITIB, "+CRLF 
			cQueryn += " CASE WHEN FH_TIPO IS NULL THEN '00000000000' ELSE SA2.A2_NROIB END AS NROIB,"+CRLF  
			cQueryn += "        CASE  SA2.A2_TIPO WHEN 'I' THEN '1'"+CRLF
			cQueryn += "                          WHEN 'N' THEN '2'"+CRLF
			cQueryn += "                          WHEN 'X' THEN '3'"+CRLF
			cQueryn += "                          WHEN 'M' THEN '4'"+CRLF 
			cQueryn += "	                        ELSE          '5'"+CRLF 
			cQueryn += "				            END SITIVA,"+CRLF 
			cQueryn += " SA2.A2_NOME RAZON,0 AS OUTROSCON,SFE.FE_VALIMP IVA,FE_VALBASE MONTOSU,FE_ALIQ ALIQ,"+CRLF
			cQueryn += " SFE.FE_RETENC MONTORET,"+CRLF
			cQueryn += " F1_RG1415 RG1415,"+CRLF
			cQueryn += " '' AS ACEPT , '' AS FECACPT " + CRLF	// Pronto para receber a cria็ใo dos campos 'Aceptacion' e 'Fecha de Aceptacion'
			cQueryn += " FROM "+RetSqlName('SFE')+" SFE"+CRLF
			cQueryn += " LEFT JOIN "+RetSqlName('SA2')+" SA2"+CRLF 
			cQueryn += " ON SFE.FE_FORNECE=SA2.A2_COD AND SFE.FE_LOJA=SA2.A2_LOJA AND SA2.A2_FILIAL='"+xFilial('SA2')+"' AND SA2.D_E_L_E_T_=''"+CRLF 
			cQueryn += " LEFT JOIN (SELECT DISTINCT FH_TIPO,FH_FORNECE,FH_LOJA,FH_FILIAL,D_E_L_E_T_ FROM "+RetSqlName('SFH')+CRLF
			cQueryn += " WHERE FH_ZONFIS='CF' AND FH_FORNECE <>'') SFH"+CRLF
			cQueryn += " ON SFH.FH_FORNECE = SA2.A2_COD AND SFH.FH_LOJA = SA2.A2_LOJA AND SFH.FH_FILIAL='"+xFilial('SFH')+"' AND SFH.D_E_L_E_T_ =''"+CRLF       
			cQueryn += " LEFT JOIN "+RetSqlName('CCP')+" ON CCP_VORIGE=SFE.FE_CFO AND "+RetSqlName('CCP')+".D_E_L_E_T_ <> '*' "+CRLF 
			cQueryn += " LEFT JOIN "+RetSqlName("SF1")+" ON F1_DOC = FE_NFISCAL AND F1_FORNECE = FE_FORNECE AND F1_LOJA = FE_LOJA AND "+RetSqlName('SF1')+".D_E_L_E_T_ <> '*'"+CRLF
			cQueryn += " WHERE FE_FILIAL = '"+xFilial('SFE')+"'"+CRLF
			cQueryn += " AND SFE.FE_FORNECE <> ''"+CRLF
			cQueryn += " AND SFE.FE_NROCERT <> 'NORET'"+CRLF
			cQueryn += " AND SFE.FE_TIPO='B'"+CRLF
			cQueryn += " AND SFE.FE_EST='CF'"+CRLF
			cQueryn += " AND SFE.FE_VALBASE > 0"+CRLF
			cQueryn += " AND SFE.FE_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
			cQueryn += " AND (FE_DTESTOR='' OR FE_DTESTOR >'"+DTOS(MV_PAR02)+"')"+CRLF
			cQueryn += " AND SFE.D_E_L_E_T_ = '' "+CRLF
			If Len(_aTotal[7][1][6]) > 0
				cQueryn += " AND CCP_COD = '" + (_aTotal[7][1][6]) + "'" + CRLF
			EndIf	
			//UNI RETENCAO COM PERCEPCAO
			cQueryn += " UNION ALL"+CRLF	
			//Query para Percepci๓n normal
			cQueryn += " SELECT '2' TIPOPER,CCP_VDESTI CODNOR,SF3.F3_EMISSAO EMISSAO,"+CRLF
			cQueryn += " SF3.F3_ESPECIE AS GM1, SF3.F3_SERIE AS GM2,"
			cQueryn += " SF3.F3_SERIE LETRA,SF3.F3_NFISCAL COMPROB,SF3.F3_EMISSAO FECHA,SF3.F3_VALCONT MONTO,"+CRLF
			cQueryn += " '' NROCERT,SA1.A1_AFIP TIPODOC,SA1.A1_CGC DOCUM, SA1.A1_NIGB NIGB,"+CRLF			
			cQueryn += " CASE WHEN fh_tipo IS NULL THEN '4' "+CRLF 
			cQueryn += "   ELSE "+CRLF
			cQueryn += " CASE SFH.fh_tipo "+CRLF 
			cQueryn += "   WHEN 'I' THEN '1' "+CRLF
			cQueryn += "   WHEN 'N' THEN '4' "+CRLF
			cQueryn += "   WHEN 'X' THEN '1' "+CRLF
			cQueryn += "   WHEN 'M' THEN '5' "+CRLF
			cQueryn += "   WHEN 'V' THEN '2' "+CRLF
			cQueryn += "  ELSE '1'  "+CRLF
			cQueryn += " END "+CRLF
			cQueryn += " END  AS SITIB, "+CRLF 
			cQueryn += " 	CASE WHEN FH_TIPO IS NULL THEN '00000000000' ELSE SA1.A1_NROIB END AS NROIB,"+CRLF
			cQueryn += " CASE  SA1.A1_TIPO WHEN 'I' THEN '1'"+CRLF
			cQueryn += "                          WHEN 'N' THEN '2'"+CRLF
			cQueryn += "     		                WHEN 'X' THEN '3'"+CRLF
			cQueryn += "				            WHEN 'M' THEN '4'"+CRLF
			cQueryn += "				            ELSE          '5'"+CRLF
			cQueryn += "				            END SITIVA,"+CRLF
			cQueryn += " SA1.A1_NOME RAZON, " + CRLF

			For nBas := 1 To Len(aLivroM)
				If nBas < Len(aLivroM)
					cQueryn += " SF3.F3_VALIMP" + aLivroM[nBas] + "+" + CRLF
				Else	
					cQueryn += " SF3.F3_VALIMP" + aLivroM[nBas] + " "	+ CRLF
				EndIf
			Next		
			cQueryn += " AS OUTROSCON," + CRLF	
			cQueryn += "  Case SUBSTRING(sf3.f3_serie, 1, 1) When 'A' THEN " + ValIVAA + " When 'M' THEN " + ValIVAA + " Else " + IIf(cTpBco =="ORACLE", "0", "'0'") + " End AS IVA, "+CRLF
			
			// ADICIONA CAMPOS DE ACORDO COM O NUMERO DO LIVRO FISCAL EX: F3_BASIMP+1 == BASIMP1
			//CASO EXISTA MAIS DE UM LIVRO OS CAMPOS SERAO SOMADOS   EX: BASIMP1 + BASIMP2 ...    

			//BASE PARA IMPOSTO
			For nBas := 1 To Len(aLivros)
				If nBas < Len(aLivros)
					cQueryn += " SF3.F3_BASIMP"+aLivros[nBas] + "+"	+ CRLF
				Else	 
					cQueryn += " SF3.F3_BASIMP"+aLivros[nBas] + " "	+ CRLF						
				EndIf
			Next		
			cQueryn += " AS MONTOSU,"+CRLF	

			//ALIQUOTA			
			For nAliq := 1 To Len(aLivros)
				If nAliq < Len(aLivros) 
					cQueryn += " SF3.F3_ALQIMP" + aLivros[nAliq] + "+" + CRLF
				Else
					cQueryn += " SF3.F3_ALQIMP" + aLivros[nAliq] + " " + CRLF			
				EndIf
			Next	
			cQueryn += " AS ALIQ,"+CRLF

			//TOTAL MONTO RETIDO 		
			For nVal := 1 To Len(aLivros)
				If nVal < Len(aLivros)  
					cQueryn += " SF3.F3_VALIMP" + aLivros[nVal] + "+" + CRLF
				Else
					cQueryn += " SF3.F3_VALIMP" + aLivros[nVal] + " " + CRLF
				EndIf		
			Next					
			cQueryn += " AS MONTORET," + CRLF
			cQueryn += " SF3.F3_RG1415 AS RG1415," + CRLF
			cQueryn += " '' AS ACEPT , '' AS FECACPT " + CRLF // Pronto para receber a cria็ใo dos campos 'Aceptacion' e 'Fecha de Aceptacion'
			cQueryn += " FROM " + RetSqlName('SF3') + " SF3" + CRLF
			cQueryn += " LEFT JOIN " + RetSqlName('SA1') + " SA1" + CRLF
			cQueryn += " ON SF3.F3_CLIEFOR = SA1.A1_COD AND SF3.F3_LOJA = SA1.A1_LOJA AND SA1.A1_FILIAL = '" + xFilial('SA1') + "' AND SA1.D_E_L_E_T_= ''" + CRLF
			cQueryn += " LEFT JOIN (SELECT  DISTINCT FH_TIPO, FH_CLIENTE, FH_LOJA, FH_FILIAL,D_E_L_E_T_ FROM " + RetSqlName('SFH') + CRLF
			cQueryn += " WHERE FH_ZONFIS = 'CF' AND FH_CLIENTE <> '') SFH" + CRLF
			cQueryn += " ON SFH.FH_CLIENTE = SA1.A1_COD AND SFH.FH_LOJA = SA1.A1_LOJA AND SFH.FH_FILIAL = '" + xFilial('SFH') + "' AND SFH.D_E_L_E_T_ = ''" + CRLF     
			cQueryn += " LEFT JOIN " + RetSqlName('CCP') + " ON CCP_VORIGE=SF3.F3_CFO AND " + RetSqlName('CCP') + ".D_E_L_E_T_ <> '*' " + CRLF 
			cQueryn += " WHERE F3_FILIAL = '" + xFilial('SF3') + "'" + CRLF
			cQueryn += " AND F3_TIPOMOV = 'V'" + CRLF
			cQueryn += " AND SF3.F3_BASIMP" + aLivros[1] + " <> 0 " + CRLF
			cQueryn += " AND SUBSTRING(SF3.F3_ESPECIE,1,2) <> 'NC'" + CRLF
			cQueryn += " AND SF3.F3_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "'" + CRLF 

			If Len(_aTotal[7][1][5]) > 0
				cQueryn += " AND CCP_COD = '" + (_aTotal[7][1][5]) + "'" + CRLF
			EndIf
			cQueryn += " AND SF3.D_E_L_E_T_ = ''" + CRLF 
			cQueryn += " AND SF3.F3_DTCANC = ''"		

			cQueryn:=ChangeQuery(cQueryn)	

			dbUseArea(.T., "TOPCONN", TcGenQry( , , cQueryn), "TRAn", .T., .F.)

			TCSetField("TRAN", "MONTO"		, "N", 16, 02)
			TCSetField("TRAN", "MONTOSU"	, "N", 16, 02)		
			TCSetField("TRAN", "ALIQ"		, "N", 06, 02)
			TCSetField("TRAN", "MONTORET"	, "N", 16, 02)
			TCSetField("TRAN", "EMISSAO"	, "D", 08, 00)
			TCSetField("TRAN", "FECHA"		, "D", 08, 00)
			TCSetField("TRAN","FECACPT"  	,"D",08,00) // Pronto para receber a cria็ใo dos campos 'Aceptacion' e 'Fecha de Aceptacion'

			TRAn->(dbGotop())
			ProcRegua(LastRec())
	
			dbSelectArea("TRBn")
			DbSetOrder(1) //"INDICE+NROCERT+LETRA+COMPROB+CODNOR"

			While TRAn->(!Eof())

				If Empty(TRAn->NROCERT)        
					CTpCert := "2"
				Else
					CTpCert := "1"
				EndIf

				If TRBn->(Dbseek(CTpCert+TRAn->NROCERT+Subs(TRAn->LETRA,1,len(TRBn->LETRA))+TRAn->COMPROB+TRAn->CODNOR))
					RecLock("TRBn",.F.) 
					TRBn->MONTOSU  := TRBn->MONTOSU + (ROUND(TRAn->MONTOSU,2))
					TRBn->RETPRA   := TRBn->RETPRA + (ROUND(TRAn->MONTORET,2))
					TRBn->MONTORET := TRBn->MONTORET + (ROUND(TRAn->MONTORET,2))
					TRBn->MONTO    := TRBn->MONTO + ROUND(TRAn->MONTO,2)
					MsUnlock()
					TRAn->(dbSkip())
				ElseIf RecLock("TRBn",.T.) 
					TRBn->TIPOPER  := TRAn->TIPOPER
					TRBn->CODNOR   := TRAn->CODNOR
					TRBn->EMISSAO  := TRAn->EMISSAO
					lRg1415 := Val(TRAn->RG1415) > 200
					If TRAn->TIPOPER == '1'
						TRBn->TIPOCOM   := IIF(lRg1415,"12","03") 
					Else
						TRBn->TIPOCOM   := IIf(SUBSTR(TRAn->GM1, 1, 2) == "NF" .Or. lRg1415 , TipoCom(TRAn->GM1,TRAn->GM2,TRAn->RG1415), "09")
					EndIf
					TRBn->LETRA    := TRAn->LETRA    
					TRBn->COMPROB  := PADL(Trim(TRAn->COMPROB),Len(TRBn->COMPROB),"0")
					TRBn->FECHA    := ConvDat(TRAn->FECHA)
					TRBn->MONTO    := ROUND(TRAn->MONTO,2)
					TRBn->NROCERT  := TRAn->NROCERT  

					SX5->(DbSeek(xFilial()+"OC"+TRAn->TIPODOC ))
					Do Case
						CASE SUBS(SX5->X5_DESCRI,1,2) == '87'
						TRBn->TIPODOC   := '1'
						CASE SUBS(SX5->X5_DESCRI,1,2) == '86'
						TRBn->TIPODOC   := '2'
						CASE SUBS(SX5->X5_DESCRI,1,2) == '80'
						TRBn->TIPODOC   := '3'
						Otherwise
						TRBn->TIPODOC   := '0' 
					EndCase
					TRBn->SITIB		:= TRAn->SITIB 
					If TRBn->SITIB == "4"
						TRBn->DOCUM		:= "23000000000"//TRAn->NIGB 
					Else
						TRBn->DOCUM		:= TRAn->DOCUM 
					EndIF
					TRBn->NROIB		:= IIf(Empty(TRAn->NROIB), "00000000000", TRAn->NROIB)
					TRBn->SITIVA	:= TRAn->SITIVA
					TRBn->RAZON		:= SubStr(TRAn->RAZON, 1, 30)
					TRBn->OUTROSCON	:= TRAN->OUTROSCON + IIf(CTpCert = '1', 0, ROUND(TRAn->MONTORET,2))
					TRBn->IVA      := Iif(CTpCert = '2' .AND.  ("A" $ alltrim(TRAn->LETRA) .OR. "M" $ alltrim(TRAn->LETRA))  ,ROUND(TRAn->IVA,2),0) 
					TRBn->MONTOSU	:= ROUND(TRAn->MONTOSU,2)
					TRBn->ALIQ		:= ROUND(TRAn->ALIQ,2)
					TRBn->RETPRA	:= ROUND(TRAn->MONTORET,2)
					TRBn->MONTORET	:= ROUND(TRAn->MONTORET,2)       
					TRBn->INDICE	:= CTpCert
					TRBn->ACEPT   	:= TRAn->ACEPT // TRAn->ACEPT   := ConvDat(TRAn->FECACPT) cambiar despues de la criacion de los campos 'Aceptacion' e 'Fecha de Aceptacion' 
					TRBn->FECACPT   := TRAn->FECACPT //ConvDat(TRAn->FECACPT) //cambiar despues de la criacion de los campos 'Aceptacion' e 'Fecha de Aceptacion'
					MsUnlock()
					TRAn->(dbSkip())
				EndIf
			End

			dbSelectArea("TRBn")        
			DbSetOrder(2) //"DTOS(EMISSAO)+TIPOPER+NROCERT+LETRA+COMPROB+CODNOR"
			If !lAutomato
				If MsgYesNo(STR0001)//"ฟVerificar los datos para la exportacion?"
					TRelARCIBA('TRBn')
				EndIf
			EndIf

		ElseIf Substr(_aTotal[07][01][04],1,1) =="2"

			//Query para retencao  de NF de Credito 
			cQueryc:=" SELECT '1' TIPOPER, CASE WHEN SFE.FE_ORDPAGO='' THEN SFE.FE_NFISCAL ELSE SFE.FE_ORDPAGO END NRONFC,SFE.FE_EMISSAO EMISSAO,"+CRLF
			cQueryc+=" SFE.FE_VALBASE AS MONTO," + IIf(cTpBco =="ORACLE", "0" ,"''") + " AS MONTPERC , " +CRLF 
			cQueryc+=" SFE.FE_ALIQ AS ALIQ,SFE.FE_NRETORI NROCERT,' ' AS GM1, ' ' AS GM2,' ' LETRA,SFE.FE_ORDPAGO COMPROB,'' AS EMISNF,"+CRLF
			cQueryc+=" '' AS CGC, '' AS CODNOR ,"+CRLF
			cQueryc += " CASE WHEN FH_TIPO IS NULL THEN '4'"+CRLF
			cQueryc += " 		ELSE"+CRLF
			cQueryc += " 			CASE SFH.FH_TIPO	WHEN 'V' THEN '2'"+CRLF
			cQueryc += "  		   				    WHEN 'N' THEN '4'"+CRLF
			cQueryc += "  		ELSE"+CRLF
			cQueryc += " 				'1'"+CRLF
			cQueryc += " 			END"+CRLF
			cQueryc += " 		END AS SITIB"+CRLF
			cQueryc+=" FROM "+RetSqlName('SFE')+" SFE"+CRLF
			cQueryc+=" LEFT JOIN "+RetSqlName('SA2')+" SA2"+CRLF 
			cQueryc+=" ON SA2.A2_COD  =SFE.FE_FORNECE"+CRLF 
			cQueryc+=" AND SA2.A2_LOJA  =SFE.FE_LOJA"+CRLF
			cQueryc+=" AND SA2.D_E_L_E_T_=''"+CRLF	
			cQueryc+=" LEFT JOIN (SELECT  DISTINCT FH_TIPO,FH_FORNECE,FH_LOJA,FH_FILIAL,D_E_L_E_T_ FROM "+RetSqlName('SFH')+CRLF      
			cQueryc+=" WHERE FH_ZONFIS='CF' AND FH_CLIENTE <>'') SFH"+CRLF	
	        cQueryc+=" ON SFH.FH_FORNECE = SA2.A2_COD AND SFH.FH_LOJA = SA2.A2_LOJA AND SFH.FH_FILIAL='"+xFilial('SFH')+"' AND SFH.D_E_L_E_T_ =''"+CRLF   
			cQueryc+=" WHERE FE_FILIAL = '"+xFilial('SFE')+"'"+CRLF
			cQueryc+=" AND SFE.FE_FORNECE <>''"+CRLF
			cQueryc+=" AND SFE.FE_NROCERT <> 'NORET' "+CRLF
			cQueryc+=" AND SFE.FE_TIPO='B'"+CRLF
			cQueryc+=" AND SFE.FE_EST='CF'"+CRLF
			cQueryc+=" AND SFE.FE_VALBASE < 0 "+CRLF
			cQueryc+=" AND SFE.FE_DTRETOR < '"+DTOS(MV_PAR01)+"'"+CRLF
			cQueryc+=" AND SFE.FE_DTESTOR BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF 
			cQueryc+=" AND SFE.D_E_L_E_T_ = '' "+CRLF
			cQueryc+=" UNION ALL "+CRLF //uniao  da retencao com a percepcao

			//QUERY PARA PERCEPCAO DE NF DE CREDITO
			cQueryc+=" SELECT '2' TIPOPER,SF3.F3_NFISCAL NRONFC,SF3.F3_EMISSAO EMISSAO,"+CRLF
			//BASE PARA IMPOSTO
			For nBas:=1 To Len(aLivros)
				If nBas < Len(aLivros)
					cQueryc+=" SF3.F3_BASIMP"+aLivros[nBas]+"+"+CRLF		
				Else	
					cQueryc+=" SF3.F3_BASIMP"+aLivros[nBas]+" "+CRLF								
				EndIf
			Next		
			cQueryc+=" AS MONTO,"+CRLF	
			
			For nBas := 1 To Len(aLivros)
				If nBas < Len(aLivros)
					cQueryc += " SF3.F3_VALIMP" + aLivros[nBas] + "+"	+ CRLF
				Else	
					cQueryc += " SF3.F3_VALIMP" + aLivros[nBas] + " " + CRLF
				EndIf
			Next
			cQueryc+=" AS MONTPERC,"+CRLF	

			For nBas := 1 To Len(aLivros)
				If nBas < Len(aLivros)
					cQueryc += " SF3.F3_ALQIMP" + aLivros[nBas] + "+"	+ CRLF
				Else	
					cQueryc += " SF3.F3_ALQIMP" + aLivros[nBas] + " " + CRLF
				EndIf
			Next	
			cQueryc+=" AS ALIQ,"+CRLF
			cQueryc+=" ' '  NROCERT,"+CRLF
			cQueryc+=" CASE WHEN EXISTS(SELECT SUBSTRING(D2_ESPECIE,1,2) FROM "+RetSqlName('SD2')+" WHERE D2_DOC=SD2.D2_NFORI AND D2_SERIE=SD2.D2_SERIORI AND D2_CLIENTE=SD2.D2_CLIENTE AND D2_LOJA=SD2.D2_LOJA AND SD2.D_E_L_E_T_='' AND D2_FILIAL=SD2.D2_FILIAL " + IIf(cTpBco =="ORACLE", " AND ROWNUM = 1", "") + ")THEN"+CRLF 
			cQueryc+="      (SELECT D2_ESPECIE FROM "+RetSqlName('SD2')+" WHERE" + IIf(cTpBco =="ORACLE", " ROWNUM = 1 AND ", " ") + "D2_DOC=SD2.D2_NFORI AND D2_SERIE=SD2.D2_SERIORI AND D2_CLIENTE=SD2.D2_CLIENTE AND D2_LOJA=SD2.D2_LOJA AND SD2.D_E_L_E_T_='' AND D2_FILIAL=SD2.D2_FILIAL)"+CRLF 
			cQueryc+=" ELSE"+CRLF 
			cQueryc+="		CASE WHEN EXISTS(SELECT SUBSTRING(D2_ESPECIE,1,2) FROM "+RetSqlName('SD2')+" WHERE D2_DOC=SD1.D1_NFORI AND D2_SERIE=SD1.D1_SERIORI AND D2_CLIENTE=SD1.D1_FORNECE AND D2_LOJA=SD1.D1_LOJA AND SD1.D_E_L_E_T_='' AND D2_FILIAL=SD1.D1_FILIAL " + IIf(cTpBco =="ORACLE", " AND ROWNUM = 1", "") + ")THEN"+CRLF 
			cQueryc+="  		(SELECT D2_ESPECIE FROM "+RetSqlName('SD2')+" WHERE" + IIf(cTpBco =="ORACLE", " ROWNUM = 1 AND ", " ") + "D2_DOC=SD1.D1_NFORI AND D2_SERIE=SD1.D1_SERIORI AND D2_CLIENTE=SD1.D1_FORNECE AND D2_LOJA=SD1.D1_LOJA AND SD1.D_E_L_E_T_='' AND SD2.D_E_L_E_T_='' AND D2_FILIAL=SD1.D1_FILIAL)"+CRLF 
			cQueryc+=" 		ELSE"+CRLF 
			cQueryc+="  		CASE WHEN EXISTS(SELECT SUBSTRING(D1_ESPECIE,1,2) FROM "+RetSqlName('SD1')+" WHERE D1_DOC=SD1.D1_NFORI AND D1_SERIE=SD1.D1_SERIORI AND D1_FORNECE=SD1.D1_FORNECE AND D1_LOJA=SD1.D1_LOJA AND SD1.D_E_L_E_T_='' AND D1_FILIAL=SD1.D1_FILIAL " + IIf(cTpBco =="ORACLE", " AND ROWNUM = 1", "") + ")THEN"+CRLF 
			cQueryc+=" 				(SELECT D1_ESPECIE FROM "+RetSqlName('SD1')+" WHERE" + IIf(cTpBco =="ORACLE", " ROWNUM = 1 AND ", " ") + "D1_DOC=SD1.D1_NFORI AND D1_SERIE=SD1.D1_SERIORI AND D1_FORNECE=SD1.D1_FORNECE AND D1_LOJA=SD1.D1_LOJA AND SD1.D_E_L_E_T_='' AND D1_FILIAL=SD1.D1_FILIAL)"+CRLF 
			cQueryc+="  		ELSE"+CRLF 
			cQueryc+=" 				CASE WHEN EXISTS(SELECT SUBSTRING(D1_ESPECIE,1,2) FROM "+RetSqlName('SD1')+" WHERE D1_DOC=SD2.D2_NFORI AND D1_SERIE=SD2.D2_SERIORI AND D1_FORNECE=SD2.D2_CLIENTE AND D1_LOJA=SD2.D2_LOJA AND SD2.D_E_L_E_T_='' AND D1_FILIAL=SD2.D2_FILIAL " + IIf(cTpBco =="ORACLE", " AND ROWNUM = 1", "") + ")THEN"+CRLF 
			cQueryc+=" 					(SELECT SUBSTRING(D1_ESPECIE,1,2) FROM "+RetSqlName('SD1')+" WHERE " + IIf(cTpBco =="ORACLE", " ROWNUM = 1 AND", "") + " D1_DOC=SD2.D2_NFORI AND D1_SERIE=SD2.D2_SERIORI AND D1_FORNECE=SD2.D2_CLIENTE AND D1_LOJA=SD2.D2_LOJA AND SD2.D_E_L_E_T_='' AND D1_FILIAL=SD2.D2_FILIAL)"+CRLF 
			cQueryc+="  			ELSE"+CRLF 
			cQueryc+="  				CASE WHEN SD1.D1_ESPECIE='NCC' THEN" +CRLF
			cQueryc+=" 						' '"+CRLF 
			cQueryc+=" 			   		ELSE"+CRLF 
			cQueryc+=" 						' '"+CRLF 
			cQueryc+=" 					END"+CRLF 
			cQueryc+="  			END"+CRLF 
			cQueryc+="  		END"+CRLF 
			cQueryc+=" 		END"+CRLF 
			cQueryc+=" END AS GM1,"+CRLF 
			cQueryc+=" CASE WHEN EXISTS(SELECT SUBSTRING(D2_ESPECIE,1,2) FROM "+RetSqlName('SD2')+" WHERE D2_DOC=SD2.D2_NFORI AND D2_SERIE=SD2.D2_SERIORI AND D2_CLIENTE=SD2.D2_CLIENTE AND D2_LOJA=SD2.D2_LOJA AND SD2.D_E_L_E_T_='' AND D2_FILIAL=SD2.D2_FILIAL" + IIf(cTpBco =="ORACLE", " AND ROWNUM = 1", "") + ") THEN"+CRLF
			cQueryc+="		SD2.D2_SERIORI"+CRLF 
			cQueryc+=" ELSE"+CRLF 
			cQueryc+="		CASE WHEN EXISTS(SELECT SUBSTRING(D2_ESPECIE,1,2) FROM "+RetSqlName('SD2')+" WHERE D2_DOC=SD1.D1_NFORI AND D2_SERIE=SD1.D1_SERIORI AND D2_CLIENTE=SD1.D1_FORNECE AND D2_LOJA=SD1.D1_LOJA AND SD1.D_E_L_E_T_='' AND D2_FILIAL=SD1.D1_FILIAL" + IIf(cTpBco =="ORACLE", " AND ROWNUM = 1", "") + ") THEN"+CRLF 
			cQueryc+="  		SD1.D1_SERIORI"+CRLF 
			cQueryc+=" 		ELSE"+CRLF 
			cQueryc+="  		CASE WHEN EXISTS(SELECT SUBSTRING(D1_ESPECIE,1,2) FROM "+RetSqlName('SD1')+" WHERE D1_DOC=SD1.D1_NFORI AND D1_SERIE=SD1.D1_SERIORI AND D1_FORNECE=SD1.D1_FORNECE AND D1_LOJA=SD1.D1_LOJA AND SD1.D_E_L_E_T_='' AND D1_FILIAL=SD1.D1_FILIAL" + IIf(cTpBco =="ORACLE", " AND ROWNUM = 1", "") + ") THEN"+CRLF 
			cQueryc+=" 				SD1.D1_SERIORI"+CRLF 
			cQueryc+="  		ELSE"+CRLF 
			cQueryc+=" 				CASE WHEN EXISTS(SELECT SUBSTRING(D1_ESPECIE,1,2) FROM "+RetSqlName('SD1')+" WHERE D1_DOC=SD2.D2_NFORI AND D1_SERIE=SD2.D2_SERIORI AND D1_FORNECE=SD2.D2_CLIENTE AND D1_LOJA=SD2.D2_LOJA AND SD2.D_E_L_E_T_='' AND D1_FILIAL=SD2.D2_FILIAL" + IIf(cTpBco =="ORACLE", " AND ROWNUM = 1", "") + ") THEN"+CRLF  
			cQueryc+=" 					SD2.D2_SERIORI"+CRLF 
			cQueryc+="  			ELSE"+CRLF 
			cQueryc+="  				CASE WHEN SD1.D1_ESPECIE='NCC' THEN"+CRLF 
			cQueryc+=" 						SD1.D1_SERIE"+CRLF 
			cQueryc+=" 					ELSE"+CRLF 
			cQueryc+=" 						SD2.D2_SERIE"+CRLF 
			cQueryc+=" 					END"+CRLF 
			cQueryc+="  			END"+CRLF 
			cQueryc+="  		END"+CRLF 
			cQueryc+=" 		END"+CRLF 
			cQueryc+=" END AS GM2,"+CRLF
			cQueryc+=" CASE WHEN SF3.F3_ESPECIE ='NCC' THEN"+CRLF   
			cQueryc+=" 		CASE WHEN SD1.D1_SERIORI<>'' THEN "+CRLF 
			cQueryc+=" 			SD1.D1_SERIORI"
			cQueryc+=" 		ELSE"
			cQueryc+=" 			SD1.D1_SERIE"
			cQueryc+=" 		END"				
			cQueryc+=" ELSE"+CRLF
			cQueryc+=" 		CASE WHEN SD2.D2_SERIORI<>'' THEN"+CRLF
			cQueryc+=" 			SD2.D2_SERIORI"
			cQueryc+=" 		ELSE"
			cQueryc+=" 			SD2.D2_SERIE"
			cQueryc+=" 		END"			
			cQueryc+=" END LETRA,"+CRLF 	
			cQueryc+=" CASE WHEN SF3.F3_ESPECIE ='NCC' THEN"+CRLF   
			cQueryc+=" 		SD1.D1_NFORI"+CRLF 
			cQueryc+=" ELSE"+CRLF 
			cQueryc+=" 		SD2.D2_NFORI"+CRLF
			cQueryc+=" END  COMPROB ,SD2AUX.D2_EMISSAO EMISNF,SA1.A1_CGC as CGC,CCP.CCP_VDESTI AS CODNOR,"+CRLF 
			cQueryc += " CASE WHEN FH_TIPO IS NULL THEN '4'"+CRLF
			cQueryc += " 		ELSE"+CRLF
			cQueryc += " 			CASE SFH.FH_TIPO	WHEN 'V' THEN '2'"+CRLF
			cQueryc += " 				    WHEN 'N' THEN '4'"+CRLF
			cQueryc += " 			ELSE"+CRLF
			cQueryc += " 				'1'"+CRLF
			cQueryc += " 			END"+CRLF
			cQueryc += " END AS SITIB"+CRLF
			cQueryc+=" FROM     "+RetSqlName('SF3')+" SF3"+CRLF			
			cQueryc+=" LEFT JOIN (SELECT  DISTINCT D1_FILIAL,D1_SERIE,D1_DOC,D1_TIPO,D1_FORNECE,D1_LOJA,D1_TES,D1_CF,D1_ESPECIE,D1_SERIORI,D1_NFORI,D_E_L_E_T_ FROM "+RetSqlName('SD1') +CRLF
			cQueryc+=" ) SD1"
			cQueryc+=" ON SD1.D1_FILIAL  =SF3.F3_FILIAL"+CRLF 
			cQueryc+=" AND SD1.D1_DOC    =SF3.F3_NFISCAL"+CRLF  
			cQueryc+=" AND SD1.D1_SERIE  =SF3.F3_SERIE"+CRLF  
			cQueryc+=" AND SD1.D1_ESPECIE=SF3.F3_ESPECIE"+CRLF  
			cQueryc+=" AND SD1.D1_FORNECE=SF3.F3_CLIEFOR"+CRLF  
			cQueryc+=" AND SD1.D1_LOJA   =SF3.F3_LOJA"+CRLF   
			cQueryc+=" AND SD1.D_E_L_E_T_=''"+CRLF			
			cQueryc+=" LEFT JOIN (SELECT  DISTINCT D2_FILIAL,D2_SERIE,D2_DOC,D2_TIPO,D2_CLIENTE,D2_LOJA,D2_TES,D2_CF,D2_ESPECIE,D2_SERIORI,D2_NFORI,D_E_L_E_T_ FROM "+RetSqlName('SD2') +CRLF
			cQueryc+=" ) SD2"
			cQueryc+=" ON SD2.D2_FILIAL =SF3.F3_FILIAL"+CRLF 
			cQueryc+=" AND SD2.D2_DOC    =SF3.F3_NFISCAL"+CRLF  
			cQueryc+=" AND SD2.D2_SERIE  =SF3.F3_SERIE"+CRLF  
			cQueryc+=" AND SD2.D2_ESPECIE=SF3.F3_ESPECIE"+CRLF  
			cQueryc+=" AND SD2.D2_CLIENTE=SF3.F3_CLIEFOR"+CRLF 
			cQueryc+=" AND SD2.D2_LOJA   =SF3.F3_LOJA"+CRLF  
			cQueryc+=" AND SD2.D_E_L_E_T_=''"+CRLF			
			cQueryc+=" LEFT JOIN "+RetSqlName('SA1')+" SA1"+CRLF 
			cQueryc+=" ON SA1.A1_COD  =SF3.F3_CLIEFOR"+CRLF 
			cQueryc+=" AND SA1.A1_LOJA  =SF3.F3_LOJA"+CRLF
			cQueryc+=" AND SA1.D_E_L_E_T_=''"+CRLF	
			cQueryc+=" LEFT JOIN (SELECT  DISTINCT FH_TIPO,FH_CLIENTE,FH_LOJA,FH_FILIAL,D_E_L_E_T_ FROM "+RetSqlName('SFH')+CRLF      
			cQueryc+=" WHERE FH_ZONFIS='CF' AND FH_CLIENTE <>'') SFH"+CRLF	
	        cQueryc+=" ON SFH.FH_CLIENTE = SA1.A1_COD AND SFH.FH_LOJA = SA1.A1_LOJA AND SFH.FH_FILIAL='"+xFilial('SFH')+"' AND SFH.D_E_L_E_T_ =''"+CRLF   
			cQueryc+=" LEFT JOIN "+RetSqlName('CCP')+" CCP"+CRLF
			cQueryc+=" ON CCP_FILIAL=SF3.F3_FILIAL"+CRLF 
			cQueryc+=" AND CCP_VORIGE=SF3.F3_CFO"+CRLF 
			cQueryc+=" AND CCP.D_E_L_E_T_=''"+CRLF
			cQueryc+=" LEFT JOIN (SELECT DISTINCT D2_EMISSAO, D2_DOC FROM "+RetSqlName('SD2')+CRLF      
			cQueryc+=" WHERE D_E_L_E_T_ = '') SD2"+ "AUX"+CRLF 	
	        cQueryc+=" ON SD2AUX.D2_DOC = D1_NFORI"+CRLF	      
			cQueryc+=" WHERE F3_FILIAL = '"+xFilial('SF3')+"'"+CRLF
			cQueryc+=" AND F3_TIPOMOV='V'"+CRLF 
			cQueryc+=" AND SF3.F3_BASIMP"+aLivros[1]+" <> 0 "+CRLF
			cQueryc+=" AND SUBSTRING(F3_ESPECIE,1,2)='NC'"+CRLF 
			cQueryc+=" AND SF3.F3_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"+CRLF
			cQueryc+=" AND SF3.F3_DTCANC=''"+CRLF 
			cQueryc+=" AND SF3.D_E_L_E_T_ = ''"+CRLF

			cQueryc:=ChangeQuery(cQueryc)	

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryc),"TRAc",.T.,.F.)

			TCSetField("TRAc","MONTO"    ,"N",16,02)
			TCSetField("TRAc","EMISSAO"  ,"D",08,00)
			TCSetField("TRAc","EMISNF"   ,"D",08,00)

			TRAc->(dbGotop())

			dbSelectArea("TRBc")
			DbSetOrder(1)//"NROCERT+LETRA+COMPROB"

			While TRAc->(!Eof())

				If TRBc->(Dbseek(TRAc->NROCERT+TRAc->LETRA+TRAc->COMPROB))
					RecLock("TRBc",.F.) 

					TRBc->MONTO   := TRBc->MONTO + ( ROUND(If(TRAc->MONTO < 0,TRAc->MONTO *(-1),TRAc->MONTO),2) )

					MsUnlock()
					TRAc->(dbSkip())

				ElseIf RecLock("TRBc",.T.) 
					TRBc->TIPOPER := TRAc->TIPOPER
					TRBc->NRONFC  := TRAc->NRONFC
					TRBc->EMISSAO := TRAc->EMISSAO
					TRBc->MONTO   := ROUND(If(TRAc->MONTO < 0,TRAc->MONTO *(-1),TRAc->MONTO),2) 
					TRBc->NROCERT := TRAc->NROCERT  
					TRBc->TIPOCOM := TIPOCOM(TRAc->GM1,TRAc->GM2)
					TRBc->LETRA   := TRAc->LETRA    
					If !Empty(TRAc->COMPROB)
						TRBc->COMPROB := Padl(TRAc->COMPROB,16,"0")
					Else
						TRBc->COMPROB := TRAc->NRONFC					
					EndIf
					IF TRAc->SITIB == "4"
						TRBc->CGC := "23000000000"
					Else
						TRBc->CGC	:= TRAc->CGC
					EndIf
					TRBc->CODNOR	:= TRAc->CODNOR
					TRBc->EMISSFE	:= IIf(ValType(TRAc->EMISNF) == "D", DtoC(TRAc->EMISNF), TRAc->EMISNF)
					TRBc->MONTPERC	:= PadL(AllTrim(Transform(TRAc->MONTPERC,"@E 9999999999999.99")),16,"0")
					TRBc->ALIQ		:= PadL(Alltrim(Transform(TRAc->ALIQ,"@E 99.99")),5,"0")
				EndIf
				MsUnlock()
				TRAc->(dbSkip())
			End

		  
			dbSelectArea("TRBc")
			DbSetOrder(2)//"DTOS(EMISSAO)+NROCERT+LETRA+COMPROB"

			If MsgYesNo(STR0001)//"ฟVerificar los datos para la exportacion?"
				TRelARCIBA('TRBc')
			EndIf
			TRAc->(dbCloseArea())
		EndIF
	EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BuscaSFB บ Autor ณ Totvs              บ Data ณ  05/05/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescrip.  ณ Busca numero dos livros de acordo para montagem dos campos บฑฑ
ฑฑณ          ณ F3_ALQIMP,F3_VALIMP e F3_BASIMP                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ARCIBA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BuscaSFB()

	Local cQuery := "" 
	Local aLivro := {}

	cQuery:="SELECT FB_CPOLVRO LIVRO "
	cQuery+="FROM " + RetSqlName('SFB') + " SFB "
	cQuery+="WHERE FB_CLASSE = 'P'"
	cQuery+=" AND SFB.D_E_L_E_T_ = ''	
	cQuery+=" AND SFB.FB_FILIAL = '" + xFilial('SFB') + "'"	
	cQuery+=" AND SFB.FB_CLASSIF = '1'"
	cQuery+=" AND SFB.FB_ESTADO = 'CF'"

	cQuery := ChangeQuery(cQuery)		

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRA",.T.,.F.)

	While TRA->(!Eof())
		aAdd(aLivro,TRA->LIVRO)
		TRA->(dbSkip())
	EndDo

Return aLivro

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTRelARCIBAบ Autor ณ Renato Nagib       บ Data ณ  28/04/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescrip.  ณ Relatorio de conferencia para exportacao do txt ARCIBA      ฑฑ
ฑฑณ          ณ                                                             ฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ARCIBA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TRelARCIBA(cArq)

	Local olReport
	
	Private cArqTrab := cArq

	If TRepInUse()
		olReport := ReportDef()
		olReport:PrintDialog()
	EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportDef บ Autor ณ Renato Nagib       บ Data ณ  28/04/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescrip.  ณ Definicao do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ARCIBA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReportDef()

	Local olReport
	Local oSection

	olReport:=TReport():New("ARCIBAtxt",STR0002,,{|olReport| PrintReport(olReport)},STR0003) //"Datos para exportaci๓n" //"Conferencia de los datos para exportacion txt"
	
	oSection:=TRSection():new(olReport,STR0004,{cArqTrab})//"Impuestos"
	
	olReport:SetLandScape(.T.)

	If cArqTrab == 'TRBn'
		TRCell():New(oSection, "OP "			, , , "@E 9"				, 02)
		TRCell():New(oSection, "NOR "			, , , "@E 999"				, 04)
		TRCell():New(oSection, "FECHA RET "		, , , 						, 20)
		TRCell():New(oSection, "TPCOM"			, , , "@E 99"				, 07)
		TRCell():New(oSection, "LTR "			, , , "@!"					, 04)
		TRCell():New(oSection, "COMPROBANTE"	, , , "@!"					, 20)
		TRCell():New(oSection, "FECHA EMI"		, , ,						, 20)
		TRCell():New(oSection, "MONTO"			, , , "@E 999,999,999.99"	, 16)
		TRCell():New(oSection, "CERT"			, , , "@!"					, 21)
		TRCell():New(oSection, "TPDOC"			, , , "@!"					, 01)
		TRCell():New(oSection, "DOCUMENTO"		, , , "@!"					, 18)
		TRCell():New(oSection, "SIB"			, , , "@!"					, 06)
		TRCell():New(oSection,"NROIB"      ,,,"@E 99999999999" ,11)
		TRCell():New(oSection, "SIVA"			, , , "@E 9"				, 06)
		TRCell():New(oSection, "RAZON"			, , , "@!"					, 30)
		TRCell():New(oSection, "MONTSU"			, , , "@E 999,999,999.99"	, 16)
		TRCell():New(oSection, "ALIQ"			, , , "@E 99.99"			, 08)
		TRCell():New(oSection, "RETPRA"			, , , "@E 999,999,999.99"	, 16)
		TRCell():New(oSection, "MONTRET"		, , , "@E 999,999,999.99"	, 16)
		TRCell():New(oSection, " "				, , ,						, 10)
	Else
		TRCell():New(oSection, "TIPOPER"	, , , "@E 9"				, 01)		
		TRCell():New(oSection, "NRONFC"		, , , "@!"					, 16)
		TRCell():New(oSection, "FECHA"		, , , 						, 20)
		TRCell():New(oSection,"MONTO"    ,,,"@E 9,999,999,999.99",16)
		TRCell():New(oSection, "NROCERT"	, , , "@!"					, 16)
		TRCell():New(oSection, "TIPOCOM"	, , , "@E 99"				, 02)
		TRCell():New(oSection, "LETRA"		, , , "@!"					, 01)
		TRCell():New(oSection, "COMPROB"	, , , "@!"					, 15)
	EndIf
	
Return olReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  PrintReportบ Autor ณ Renato Nagib       บ Data ณ  28/04/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescrip.  ณ Impressao do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ARCIBA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrintReport(olReport)

	Local olSection := olReport:Section(1)

	If cArqTrab == 'TRBn'
		olReport:Section(1):Cell("OP "        ):SetBlock({|| TRBn->TIPOPER  })	
		olReport:Section(1):Cell("NOR"        ):SetBlock({|| TRBn->CODNOR   })	
		olReport:Section(1):Cell("FECHA RET"  ):SetBlock({|| TRBn->EMISSAO  })	
		olReport:Section(1):Cell("TPCOM"      ):SetBlock({|| TRBn->TIPOCOM  })	
		olReport:Section(1):Cell("LTR"        ):SetBlock({|| TRBn->LETRA    })	
		olReport:Section(1):Cell("COMPROBANTE"):SetBlock({|| TRBn->COMPROB  })	
		olReport:Section(1):Cell("FECHA EMI"  ):SetBlock({|| TRBn->FECHA    })	
		olReport:Section(1):Cell("MONTO"      ):SetBlock({|| TRBn->MONTO    })	
		olReport:Section(1):Cell("CERT"       ):SetBlock({|| TRBn->NROCERT  })	
		olReport:Section(1):Cell("TPDOC"      ):SetBlock({|| TRBn->TIPODOC  })	
		olReport:Section(1):Cell("DOCUMENTO"  ):SetBlock({|| TRBn->DOCUM    })	
		olReport:Section(1):Cell("SIB"        ):SetBlock({|| TRBn->SITIB    })	
		olReport:Section(1):Cell("NROIB"      ):SetBlock({|| TRBn->NROIB    })	
		olReport:Section(1):Cell("SIVA"       ):SetBlock({|| TRBn->SITIVA   })	
		olReport:Section(1):Cell("RAZON"      ):SetBlock({|| TRBn->RAZON    })	
		olReport:Section(1):Cell("MONTSU"     ):SetBlock({|| TRBn->MONTOSU  })	
		olReport:Section(1):Cell("ALIQ"       ):SetBlock({|| TRBn->ALIQ     })	
		olReport:Section(1):Cell("RETPRA"     ):SetBlock({|| TRBn->RETPRA   })	
		olReport:Section(1):Cell("MONTRET"    ):SetBlock({|| TRBn->MONTORET })	
		olReport:Section(1):Cell(" "          ):SetBlock({|| " "            })
	Else
		olReport:Section(1):Cell("TIPOPER"  ):SetBlock({|| TRBc->TIPOPER  })		
		olReport:Section(1):Cell("NRONFC"   ):SetBlock({|| TRBc->NRONFC  })	
		olReport:Section(1):Cell("FECHA"    ):SetBlock({|| TRBc->EMISSAO  })	
		olReport:Section(1):Cell("MONTO"    ):SetBlock({|| TRBc->MONTO    })	
		olReport:Section(1):Cell("NROCERT"  ):SetBlock({|| TRBc->NROCERT  })	
		olReport:Section(1):Cell("TIPOCOM"  ):SetBlock({|| TRBc->TIPOCOM  })	
		olReport:Section(1):Cell("LETRA"    ):SetBlock({|| TRBc->LETRA    })	
		olReport:Section(1):Cell("COMPROB"  ):SetBlock({|| TRBc->COMPROB  })	
	EndIf
	olSection:Print()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  PrintReportบ Autor ณ Renato Nagib       บ Data ณ  28/04/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescrip.  ณ Exclui o arquivo temporario processado                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ARCIBA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/      
Function DelARCIBA(aArqTrab)

	Local nArq := 0

	For nArq := 1 To Len(aArqTrab)
		dbSelectArea(aArqTrab[nArq, 2])
		dbCloseArea()
		&(aArqTrab[nArq, 1]):Delete()
		&(aArqTrab[nArq, 1]) := Nil
	Next	

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ TipCom   บ Autor ณ Ivan Haponczuk     บ Data ณ  03/01/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescrip.  ณ Retorna o tipo do comprovante de acordo com o tipo da nota บฑฑ
ฑฑณ          ณ e a serie.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ARCIBA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TipoCom(clGM1,clGM2,cRG1415)

	Local clTipoCom := ""
	Local nRG1415 := 0
	
	Default clGM1   := ""
	Default clGM2   := ""
	Default cRG1415 := ""
	
	clGM1 := AllTrim(clGM1)
	clGM2 := SubStr(AllTrim(clGM2), 1, 1)
	clGM3 := clGM1 + "|" + clGM2
	nRG1415 := Val(cRG1415)

	If !Empty(clGM1)
		Do Case
			Case clGM3 == "NF|A"	.OR. clGM3 == "NF|B" .OR. clGM3 == "NF|C" .OR. clGM3 == "NF|M"
				If nRG1415 > 200 
					clTipoCom := "10"
				Else
					clTipoCom := "01"
				Endif	
          	Case clGM3 == "NDC|A".OR. clGM3 == "NCE|A"			
				If nRG1415 > 200 
					clTipoCom := "13"
				Else
					clTipoCom := "02"
				Endif
          	Case clGM3 == "NCC|A".OR. clGM3 == "NDE|A"
              clTipoCom := "03"
          	Case clGM3 == "NDC|B".OR. clGM3 == "NCE|B" 				
				If nRG1415 > 200 
					clTipoCom := "13"
				Else
					clTipoCom := "07"
				Endif			
          	Case clGM3 == "NCC|B".OR. clGM3 == "NDE|B"
              clTipoCom := "08" 
          	Case clGM3 == "NDC|C".OR. clGM3 == "NCE|C"
				If nRG1415 > 200 
					clTipoCom := "13"
				Else
					clTipoCom := "12"
				Endif
          	Case clGM3 == "NCC|C".OR. clGM3 == "NDE|C"
              clTipoCom := "13"
          	Case clGM3 == "NDC|M".OR. clGM3 == "NCE|M"
				If nRG1415 > 200 
					clTipoCom := "13"
				Else
					clTipoCom := "52"
				Endif
          	Case clGM3 == "NCC|M".OR. clGM3 == "NDE|M"
              clTipoCom := "53"                               
          	Case clGM3 == "CF|A"	.OR. clGM3 == "CF|B"
              clTipoCom := "01"                  
		EndCase
	Else
		Do Case
			Case clGM2 == "A"
			clTipoCom := "01"
			Case clGM2 == "B"
			clTipoCom := "06"
			Case clGM2 == "C"
			clTipoCom := "11"
			Case clGM2 == "M"
			clTipoCom := "51"
		EndCase
	EndIf

	If Empty(clGM1) .And. Empty(clGM2)
		clTipoCom := "03"
	EndIf

Return clTipoCom

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ConvDat  บ Autor ณ Ivan Haponczuk     บ Data ณ  05/01/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescrip.  ณ Converte a data para o formato padrao do arquivo ARCIBA    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ARCIBA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ConvDat(dData)

	Local cData := DTOS(dData)

	cData := SubStr(cData,7,2) + "/" + SubStr(cData,5,2) + "/" + SubStr(cData,1,4)

Return cData

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBuscaMONTOSFBบ Autor ณ Ivan Haponczuk  บ Data ณ  05/01/2011 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescrip.  ณ Funcion que busca Montos en la tabla SFB                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ARCIBA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BuscaMONTOSFB()

Local cQuery := "" 
Local aLivroMO := {}
		
cQuery:=" SELECT FB_CPOLVRO LIVRO "
cQuery+=" FROM "+RetSqlName('SFB') + " SFB "
cQuery+=" WHERE SFB.D_E_L_E_T_<>'*' "	
cQuery+=" AND SFB.FB_FILIAL='"+xFilial('SFB')+"'"
cQuery+=" AND ((FB_CODIGO <> 'IVA') AND (FB_CODIGO <> 'IBP')) "	
	//cQuery+=" AND ((FB_ESTADO <> 'CF' AND FB_CLASSIF = '1') OR (FB_CLASSIF = '3')) "
	
If cTpBco $ "ORACLE|POSTGRES"
	cQuery+=" AND LENGTH(LTRIM(RTRIM(FB_CPOLVRO)))>0
Else
	cQuery+=" AND LEN(RTRIM(LTrim(FB_CPOLVRO))) > 0 "
EndIf
cQuery := ChangeQuery(cQuery)		
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRAM",.T.,.F.)

While TRAM->(!Eof())
	aAdd(aLivroMO,TRAM->LIVRO)
	TRAM->(dbSkip())
End

Return aLivroMO
