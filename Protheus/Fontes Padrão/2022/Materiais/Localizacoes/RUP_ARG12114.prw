#Include 'Protheus.ch'

//------------------------------------------------------------------------------
/*/{Protheus.doc} RUP_ARG12114()

Compatibilizador para Argentina, aplica los cambios realizados en la estabilizacion de 12.1.14

@sample		RUP_ARG12114("12", "2", "003", "005", "BRA")

@param		cVersion	- Versão do Protheus 
@param		cMode		- Modo de execução		- "1" = Por grupo de empresas / "2" =Por grupo de empresas + filial (filial completa)
@param		cRelStart	- Release de partida	- (Este seria o Release no qual o cliente está)
@param		cRelFinish	- Release de chegada	- (Este seria o Release ao final da atualização)
@param		cLocaliz	- Localização (país)	- Ex. "BRA"

@return		Nil

@author	Guadalupe Santacruz
@since		20/04/17
@version	12
/*/
/*
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS    ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Raul Ortiz M  ³25/08/17³DMICNS-66³Se actualizan tamaños de los campos     ³±±
±±³              ³        ³         ³ALQIMP para SD2, SF3 y SC7              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
*/

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------
Function RUP_ARG12114( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
Local cFile 	 := ''
Local lAct		 := .f.
Local nx:=0
Private cTexto :=''
Private aArqUpd  := {}

If ( cVersion == "12" ) .AND. cPaisLoc == "ARG" .AND.  (cRelStart== '006' .or. cRelStart== '007' .OR. cRelStart== '014' .OR. cRelStart== '016' .OR. cRelFinish== '016' .OR. cRelStart== '017' .OR. cRelFinish== '017'  ).and.  cMode=="1"
       //Actualizaciones realizadas en la estabilizacion de 12.1.14 para Argentina 
       lAct:=.t.
		UpdSX1()
		UpdSX2()
		UpdSIX()
		UpdSX3()
		UpdSX5()
		UpdSX6()
		UpdSXB()
		UpdSX7()
		UpdSX9()
		UHELPS()
endif
If ( cVersion == "12" ) .AND. cPaisLoc == "ARG"  .and. cMode=="1"
     // Actualiza en sx3  los alqimp basimp valim
     lAct:=.t.
	  ActImp()
endif


if lAct
	//Genera la estructura fisica de la BD
		
			__SetX31Mode(.F.)
			For nX := 1 To Len(aArqUpd)
		
				//	IF !(aArqUpd[nX] $ "SD2")		
						dbSelecTArea(aArqUpd[nX])
						dbCloseArea()
				
						X31UpdTable(aArqUpd[nX])
						If __GetX31Error()
							Alert(__GetX31Trace())
							cTexto += "Falla en la actualizacion de la estructura fisica del archivo "+aArqUpd[nX]+CRLF//"Falha ao atualizar estrutura física do arquivo "
						else
							cTexto += "Actualizada la estructura fisica de "+aArqUpd[nX]+CRLF
						EndIf
					//ENDIF		
				
			Next nx
	
	
	cFile := 'UPDARG'+dtos(ddatabase)+'.LOG'
	lRet := MemoWrite(cFile, cTexto)
	//Aviso("RUP_ARGENTINA 12.1.14", " Este LOG se grabo automáticamente como "+cFile+" en el directorio de los SXs.", {'Ok'})
endif

Return

//--------------------------------------------------Correcciones de 12.1.14 MI------------------------------------------------------------------------------------------------------------------
Static Function UPDSX1()
Local aSX1   := {}
Local aEstrut:= {}
Local i      := 0
Local j      := 0
Local lSX1	 := .F.
Local cContenido:=''
Local cConRec:=''
Local lDif:= .f.
Local cAlias := ""

aEstrut := { "X1_GRUPO"  ,"X1_ORDEM"  ,"X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO"   ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL",;
"X1_GSC"    ,"X1_VALID"  ,"X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01"  ,"X1_VAR02"  ,"X1_DEF02"  ,;
"X1_DEFSPA2","X1_DEFENG2","X1_CNT02"  ,"X1_VAR03" ,"X1_DEF03"  ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03"  ,"X1_VAR04"  ,"X1_DEF04",;
"X1_DEFSPA4","X1_DEFENG4","X1_CNT04"  ,"X1_VAR05" ,"X1_DEF05"  ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05"  ,"X1_F3"     ,"X1_GRPSXG","X1_PYME"}

aAdd(aSX1,{'GPEA015','01','Processo ?','¿Proceso ?','?','MV_CH1','C',5,0,0,'G','Gpr040Valid(MV_PAR01)','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','RCJ','','S'})
aAdd(aSX1,{'GPEA015','02','Matrícula De ?','¿De Matricula?','?','MV_CH2','C',6,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','SRA02','','S'})
aAdd(aSX1,{'GPEA015','03','Matrícula Até ?','¿A Matricula ?','?','MV_CH3','C',6,0,0,'G','NaoVazio()','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','SRA02','','S'})
aAdd(aSX1,{'GPEA015','04','Filial De ?','¿De Filial?','?','MV_CH4','C',8,0,0,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','XM0','','S'})
aAdd(aSX1,{'GPEA015','05','Filial Até ?','¿A Filial?','?','MV_CH5','C',8,0,0,'G','NaoVazio()','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','XM0','','S'})
aAdd(aSX1,{'GPEA015','06','Departamento De ?','¿De Departamento ?','?','MV_CH6','C',9,0,0,'G','','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','SQB','','S'})
aAdd(aSX1,{'GPEA015','07','Departamento Até ?','¿A Departamento ?','?','MV_CH7','C',9,0,0,'G','NaoVazio()','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','','SQB','','S'})

aAdd(aSX1,{'MT468A','04','Ate o Cliente ?','¿A Cliente ?','To Customer ?','mv_ch4','C',6,0,0,'G','','mv_par04','','','','000002','','','','','','','','','','','','','','','','','','','','','CLI','001','S'})
aAdd(aSX1,{'MT468A','05','Do Loja ?','¿De tienda ?','From Store ?','MV_CH5','C',2,0,0,'G','','mv_par05','','','','','','','','','','','','','','','','','','','','','','','','','','002','S'})
aAdd(aSX1,{'MT468A','06','Ate Loja ?','¿A tienda ?','To Store ?','MV_CH6','C',2,0,0,'G','','mv_par06','','','','ZZ','','','','','','','','','','','','','','','','','','','','','','002','S'})

aAdd(aSX1,{'ARGBCRA','01','?','¿Fecha Inicial ?','?','MV_CH1','D',8,0,0,'G','','mv_par01','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
aAdd(aSX1,{'ARGBCRA','02','?','¿Fecha Final ?','?','MV_CH2','D',8,0,0,'G','','mv_par02','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
aAdd(aSX1,{'ARGBCRA','03','Moeda ?','¿Moneda ?','Currency ?','MV_CH3','N',1,0,1,'C','','mv_par03','Moeda 01','Moneda 01','Currency 01','','','Moeda 02','Moneda 02','Currency 02','','','Moeda 03','Moneda 03','Currency 03','','','Moeda 04','Moneda 04','Currency 04','','','Moeda 05','Moneda 05','Currency 0','','','',''})
aAdd(aSX1,{'ARGBCRA','04','Converte valor por ?','¿Convierte valor por ?','Convert amount by ?','MV_CH4','N',1,0,1,'C','','mv_par04','Taxa do dia','Tasa del día','Daily rate','','','Taxa do Mov.','Tasa del Mov.','Trans.rate','','','','','','','','','','','','','','','','','','',''})


aAdd(aSX1,{'ARCARF','01','Contribuinte ?','¿Contribuyente ?','Taxpayer ?','MV_CH0','N',1,0,0,'C','','MV_PAR01','Fornecedores','Proveedores','Suppliers','','','Clientes','Clientes','Customers','','','Ambos','Ambos','Both','','','','','','','','','','','','','','S'})
aAdd(aSX1,{'ARCARF','02','Registros ?','¿Registros ?','Records ?','MV_CH0','N',1,0,0,'C','','MV_PAR02','Retenção','Retención','Withholding','','','Percepção','Percepción','Perception','','','Ambos','Ambos','Both','','','','','','','','','','','','','','S'})
aAdd(aSX1,{'ARCARF','03','Tipo Contribuinte ?','¿Tipo contribuyente ?','Taxpayer Type ?','MV_CH0','N',1,0,0,'C','','MV_PAR03','Risco','Riesgo','Risk','','','Simplificado','Simplificado','Simplified','','','','','','','','','','','','','','','','','','','S'})
aAdd(aSX1,{'ARCARF','04','Início de Vigência ?','¿Inicio de vigencia ?','Validity Start ?','MV_CH4','D',8,0,0,'G','VldContSim()','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','','',''})


aAdd(aSX1,{'MTRAR1B','01','Data Inicial ?','¿Fecha Inicial ?','Initial date ?','MV_CH0','D',8,0,0,'G','','MV_PAR01','','','','20170220','','','','','','','','','','','','','','','','','','','','','','',''})
aAdd(aSX1,{'MTRAR1B','02','Data Final ?','¿Fecha Final ?','Final date ?','MV_CH0','D',8,0,0,'G','','MV_PAR02','','','','20171231','','','','','','','','','','','','','','','','','','','','','','',''})
aAdd(aSX1,{'MTRAR1B','03','Incluir ?','¿Incluir ?','Add ?','MV_CH0','N',1,0,1,'C','','MV_PAR03','Ativos','Activos','Assets','','','Anulados','Anulados','Annulment','','','Todos','Todos','All','','','','','','','','','','','','','',''})
aAdd(aSX1,{'MTRAR1B','04','Estilo ?','¿Estilo ?','Style ?','MV_CH0','N',1,0,1,'C','','MV_PAR04','Analitico','Analitico','Analytical','','','Resumido','Resumido','Summarized','','','','','','','','','','','','','','','','','','',''})
aAdd(aSX1,{'MTRAR1B','05','Seleciona filiais ?','¿Selecciona sucursales ?','Select branches ?','MV_CH5','C',1,0,1,'C','','mv_par05','Não','No','No','','','Sim','Sí','Yes','','','','','','','','','','','','','','','','','','',''})
aAdd(aSX1,{'MTRAR1B','06','Totais IVA ?','¿Totales IVA ?','IVA All ?','MV_CH0','N',1,0,1,'C','','MV_PAR06','Imprimir','Imprimir','Print','','','Nao Imprimir','No Imprimir','Do not print','','','','','','','','','','','','','','','','','','',''})
aAdd(aSX1,{'MTRAR1B','07','?','¿Resumen DDJJ-IVA ?','?','MV_CH0','N',1,0,1,'C','','MV_PAR07','Bienes y Serv.','Bienes y Serv.','Bienes y Serv.','','','Act. Declarada','Act. Declarada','Act. Declarada','','','Producto','Producto','Producto','','','Act. Dec./Prod.','Act. Dec./Prod.','Act. Dec./Prod.','','','Nao Imprimir','No Imprimir','Not Printe','','','',''})
aAdd(aSX1,{'MTRAR1B','08','Pagina Inicial ?','¿Pagina Inicial ?','Initial Page ?','MV_CH0','N',6,0,0,'G','','MV_PAR08','','','','1','','','','','','','','','','','','','','','','','','','','','','',''})
aAdd(aSX1,{'MTRAR1B','09','Ordem ?','¿Orden ?','Order ?','MV_CH0','N',1,0,1,'C','','MV_PAR09','DtEnt + NFiscal','FchEnt + Fact.','EntDt + Invoice','','','DtEmi + NFiscal','FchEmi + Fact.','IssDt + Invoice','','','','','','','','','','','','','','','','','','',''})

aAdd(aSX1,{'FISA806','01','Contribuinte ?','¿Contribuyente ?','Taxpayer ?','MV_CH1','C',1,0,0,'C','','MV_PAR01','Fornecedores','Proveedores','Suppliers','','','Clientes','Clientes','Customers','','','Ambos','Ambos','Both','','','','','','','','','','','','','',''})
aAdd(aSX1,{'FISA806','02','Data de Vigência ?','¿Fecha Vigencia ?','Validity Date ?','MV_CH2','D',8,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
aAdd(aSX1,{'FISA806','03','Cadastro Padrão ?','¿Archivo Padron ?','Standard Register ?','MV_CH3','C',60,0,0,'C','FGetDir806()','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','','',''})

aAdd(aSX1,{'FISA075','01','?','¿Archivo estándar ?','?','MV_CH1','C',90,0,0,'G','SelArch()','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','',''})
aAdd(aSX1,{'FISA075','02','?','¿Tabla de actividad ?','?','MV_CH2','C',4,0,0,'G','NaoVazio()  .AND. ExistCpo("CCP",MV_PAR02)','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','CCP','',''})
aAdd(aSX1,{'FISA075','03','Módulo ?','¿Módulo ?','Module ?','MV_CH3','N',1,0,3,'C','','MV_PAR03','Clientes','Clientes','Customers','','','Fornecedores','Proveedores','Suppliers','','','Ambos','Ambos','Both','','','','','','','','','','','','','',''})

aAdd(aSX1,{'FIN87A','01','Mostra Lanctos ?','¿Muestra Asientos?','Displays Entries ?','mv_ch1','N',1,0,2,'C','','mv_par01','Sim','Si','Yes','','','Nao','No','No','','','','','','','','','','','','','','','','','','','S'})
aAdd(aSX1,{'FIN87A','02','Aglutina Lanctos ?','¿Agrupa Asientos?','Accrues Entries ?','mv_ch2','N',1,0,2,'C','','mv_par02','Sim','Si','Yes','','','Nao','No','No','','','','','','','','','','','','','','','','','','','S'})

aAdd(aSX1,{'MTRAR2B2','05','Filial ?','¿Sucursal ?','Branch ?','MV_CH5','C',1,0,1,'C','','MV_PAR05','Não','No','No','','','Sim','Si','Yes','','','','','','','','','','','','','','','','','','',''})
aAdd(aSX1,{'MTRAR2B2','07','Resumo DDJJ_IVA ?','¿Resumen DDJJ_IVA ?','Summary DDJJ_IVA ?','MV_CH7','N',1,0,1,'C','','MV_PAR07','Bens e Serv.','Bienes y Serv.','Assets and Serv','','','Ativ. Declarada','Act. Declarada','Declared Activi','','','Produtos','Productos','Products','','','Ativ Decl/Prod.','Act. Dec./Prod.','Decl/Prod. Acti','','','Não Imprimir','No Imprimir','Do not Pri','','','',''})

aAdd(aSX1,{'FIR13X','14','Considera Recibos ?','¿Considera recibos ?','Consider Receipts ?','MV_CHE','N',1,0,0,'C','','mv_par14','Sim','Sí','Yes','','','Não','No','No','','','Ambos','Ambos','Both','','','','','','','','','','','','','',''})

aAdd(aSX1,{'MT468B','05','Da Loja ?','¿De tienda ?','From Store ?','MV_CH5','C',2,0,0,'G','','mv_par05','','','','','','','','','','','','','','','','','','','','','','','','','','002','S'})
aAdd(aSX1,{'MT468B','06','Ate Loja ?','¿A tienda ?','To Store ?','MV_CH6','C',2,0,0,'G','','mv_par06','','','','ZZ','','','','','','','','','','','','','','','','','','','','','','002','S'})

nAtuParci := 0
//oMtParci:nTotal := Len(aSX1)
dbSelectArea("SX1")
dbSetOrder(1)
cTexto += "----------  Inicia actualizacion de Grupo de Preguntas (SX1)  ----------"+CRLF+ CRLF
For i:= 1 To Len(aSX1)
	If !Empty(aSX1[i][1]) //cuando no encuentra la genera
		If !dbSeek(padr(aSX1[i,1],10)+aSX1[i,2])
			lSX1 := .T.
			cAlias+= aSX1[i,1]+" "+aSX1[i,2] +chr(13)+chr(10)
			RecLock("SX1",.T.)
			For j:=1 To Len(aSX1[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX1[i,j])
				EndIf
			Next j
			dbCommit()
			MsUnLock()
			cTexto += "Incluyo en el Grupo de Preguntas "+aSX1[i,1] +" la pregunta "+aSX1[i,2]+CRLF
		else	
			For j:=1 To Len(aSX1[i])
			    if alltrim(aEstrut[j])<>"X1_CNT01"
					    ldif:= .f.
					    cContenido:=&("SX1->"+aEstrut[j])
						 cConRec:=aSX1[i,j]
					    if valtype(aSX1[i,j])=="N"
					    	if alltrim(STR(&("SX1->"+aEstrut[j]))) <> alltrim(STR(aSX1[i,j]))
					    	   lDif:= .T.
					    	ENDIF
					    	cContenido:=alltrim(str(&("SX1->"+aEstrut[j])))
						    cConRec:=alltrim(str(aSX1[i,j]))
					    else
					    	if alltrim(&("SX1->"+aEstrut[j])) <> alltrim(aSX1[i,j])
					    	   lDif:= .T.
					    	ENDIF   
					    endif
					    
						if ldif
							 
						    cTexto += "No actualizó el Grupo de Preguntas "+aSX1[i,1] +" en la pregunta "+aSX1[i,2]+ ". Contenido actual de "+aEstrut[j]+ ":"+ALLTRIM(cContenido)+" Contenido recomendado:"+ ALLTRIM(cConRec)+CRLF
						EndIf
				endif
			Next j

			
		EndIf
	EndIf
	//oMtParci:Set(++nAtuParci); SysRefresh()
Next i

cTexto += CRLF+ "Finalizo actualizacion de Grupo de Preguntas (SX1)"+CRLF+ CRLF 

Return 

Static Function UPDSX2()
Local aSX2   	 := {}
Local aEstrut	 := {}
Local i      	 := 0 
Local j      	 := 0

Local lSX2	 := .F.
Local cContenido:=''
Local cConRec:=''
Local lDif:= .f.
Local cAlias := ""
Local cPath	 := ""
Local cNome	 := ""
SX2->(dbSetOrder(1))
SX2->(dbSeek("SA1"))
cPath := SX2->X2_PATH
cNome := Substr(SX2->X2_ARQUIVO,4,5)
aEstrut := {"X2_CHAVE","X2_PATH","X2_ARQUIVO","X2_NOME","X2_NOMESPA","X2_NOMEENG",       "X2_ROTINA","X2_MODO","X2_MODOUN","X2_MODOEMP","X2_DELET","X2_TTS","X2_PYME","X2_MODULO","X2_DISPLAY","X2_SYSOBJ","X2_USROBJ","X2_POSLGT","X2_CLOB","X2_AUTREC","X2_TAMFIL","X2_TAMUN","X2_TAMEMP"}

 aAdd(aSx2,{'CGF',cPath,'CGF'+cNOME,   'Reserva Mex','Reserva Mex','Mex Reservation','',       'E',        'E',         'E',          0,      '',      'S'         ,9,       '',         '',         '',         '1',           '2',        '2',          0,          0,    0})
 aAdd(aSx2,{'FVC',cPath,'FVC'+cNOME,'Retenções Ordem Pagamento Prév','Retenciones Orden Pago Previa','Withh. Prev. Payment Order','',       'E',        'E',         'E',          0,      '',      'S'         ,9,       '',         '',         '',         '1',           '2',        '2',          0,          0,    0})

 	


cTexto += "----------  Inicia actualizacion de Tablas (SX2)  ----------"+CRLF+ CRLF
nAtuParci := 0
//oMtParci:nTotal := Len(aSX2)
sx2->(dbgotop())
For i:= 1 To Len(aSX2)
	If !Empty(aSX2[i][1])
		If !sx2->(dbSeek(aSX2[i,1]))  //si no la encuentra la incluye
			lSX2	:= .T.
			If !(aSX2[i,1]$cAlias)
				cAlias += aSX2[i,1]+"-"+aSX2[i,4]+Chr(13)+Chr(10) 
			EndIf  
			RecLock("SX2",.T.)
			For j:=1 To Len(aSX2[i])
				If FieldPos(aEstrut[j]) > 0
					FieldPut(FieldPos(aEstrut[j]),aSX2[i,j])
				EndIf
			Next j
			SX2->X2_PATH 	:= cPath
			SX2->X2_ARQUIVO	:= aSX2[i,1]+cNome
			dbCommit()   
			MsUnLock()
			cTexto += "Incluyo en la tabla "+aSX2[i,1]+CRLF
		ELSE
			For j:=1 To Len(aSX2[i])
					    ldif:= .f.
					    cContenido:=&("SX2->"+aEstrut[j])
						 cConRec:=aSX2[i,j]
					    if valtype(aSX2[i,j])=="N"
					    	if alltrim(STR(&("SX2->"+aEstrut[j]))) <> alltrim(STR(aSX2[i,j]))
					    	   lDif:= .T.
					    	ENDIF
					    	cContenido:=alltrim(str(&("SX2->"+aEstrut[j])))
						    cConRec:=alltrim(str(aSX2[i,j]))
					    else
					    	if alltrim(&("SX2->"+aEstrut[j])) <> alltrim(aSX2[i,j])
					    	   lDif:= .T.
					    	ENDIF   
					    endif
					    
						if ldif

				   			 cTexto += "No actualizó la tabla "+aSX2[i,1] + ". Contenido actual de "+aEstrut[j]+ ":"+ALLTRIM(cContenido)+" Contenido recomendado :"+ALLTRIM(cConRec)+CRLF
						EndIf
			Next j
		EndIf
	
	EndIf
	//oMtParci:Set(++nAtuParci); SysRefresh()
Next i

cTexto += "Finalizo actualizacion de Tablas (SX2)"+CRLF+ CRLF 

Return

Static Function UPDSIX()

Local lSIX	 := .F.
Local lNew	 := .F.
Local aSIX   := {}
Local aEstrut:= {}
Local i      := 0
Local j      := 0
Local cAlias := ""
aEstrut :={"INDICE","ORDEM","CHAVE","DESCRICAO","DESCSPA","DESCENG","PROPRI","SHOWPESQ"}
aAdd(aSIX,{'SD1','K','D1_FILIAL+D1_SERIORI+D1_NFORI','Serie Orig. + Doc.Original','Serie Orig. + Doc.Original','Series + Original Doc',"",'S'})
aAdd(aSIX,{'SD1','L','D1_FILIAL+D1_SERIREM+D1_REMITO','Serie + N§ Remito','Serie + Nro. Remito','Series + Remito No.',"",'S'})
aAdd(aSIX,{'SD2','H','D2_FILIAL+D2_SERIREM+D2_REMITO','Serie + N§ Remito','Serie + Nro. Remito','Series + Remito No.',"",'S'})
aAdd(aSIX,{'CGF','1','CGF_FILIAL+CGF_COD+CGF_LOJA+CGF_ZONFIS+CGF_IMPOST+CGF_CODACT+CGF_CFO','Código + Loja + Zona Fiscal + Imposto + Cód. Ativ. + Cód. Fiscal','Codigo + Tienda + Zona Fiscal + Impuesto + Cod. Activid + Cod Fiscal','Code + Store + Fiscal Zone + Tax + Activity Cod + Fiscal Code',"",'S'})
aAdd(aSIX,{'CGF','2','CGF_FILIAL+CGF_COD+CGF_LOJA+CGF_ZONFIS+CGF_IMPOST+CGF_CFO+CGF_CODACT','Código + Loja + Zona Fiscal + Imposto + Cód. Fiscal + Cód. Ativ.','Codigo + Tienda + Zona Fiscal + Impuesto + Cod Fiscal + Cod. Activid','Code + Store + Fiscal Zone + Tax + Fiscal Code + Activity Cod',"",'S'})
aAdd(aSIX,{'CGF','3','CGF_FILIAL+CGF_CODCLI+CGF_LOJA+CGF_ZONFIS+CGF_IMPOST+CGF_CODACT+CGF_CFO','Cliente + Loja + Zona Fiscal + Imposto + Cód. Ativ. + Cód. Fiscal','Cliente + Tienda + Zona Fiscal + Impuesto + Cod. Activid + Cod Fiscal','Customer + Store + Fiscal Zone + Tax + Activity Cod + Fiscal Code',"",'S'})
aAdd(aSIX,{'CGF','4','CGF_FILIAL+CGF_CODCLI+CGF_LOJA+CGF_ZONFIS+CGF_IMPOST+CGF_CFO+CGF_CODACT','Cliente + Loja + Zona Fiscal + Imposto + Cód. Fiscal + Cód. Ativ.','Cliente + Tienda + Zona Fiscal + Impuesto + Cod Fiscal + Cod. Activid','Customer + Store + Fiscal Zone + Tax + Fiscal Code + Activity Cod',"",'S'})
aAdd(aSIX,{'CGF','5','CGF_FILIAL+CGF_FORNEC','Fornecedor','Proveedor','Supplier',"",'S'})
aAdd(aSIX,{'FVC','1','FVC_FILIAL+FVC_PREOP+FVC_TIPO','Nº Pré OP + Tipo','Num. Pre OP + Tipo','Pre PO no. + Type',"",'S'})
aAdd(aSIX,{'FVC','2','FVC_FILIAL+FVC_PREOP+FVC_FORNEC+FVC_LOJA','Nº Pré OP + Forncedor + Filial','Num. Pre OP + Proveedor + Sucursal','Pre PO no. + Supplier + Branch',"",'S'})
aAdd(aSIX,{'FVC','3','FVC_FILIAL+FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC_SERIE+FVC_TIPO+FVC_CONCEP','Forncedor + Filial + Nota Fiscal + Série + Tipo + Verba','Proveedor + Sucursal + Factura + Serie + Tipo + Concepto','Supplier + Branch + Invoice + Series + Type + Funds',"",'S'})

nAtuParci := 0
cTexto += "----------  Inicia actualizacion de Indices (SIX)  ----------"+CRLF+ CRLF
//oMtParci:nTotal := Len(aSIX)
dbSelectArea("SIX")
dbSetOrder(1)
For i:= 1 To Len(aSIX)
	
		If !SIX->(dbSeek(aSIX[i,1]+aSIX[i,2]))
			RecLock("SIX",.T.)
			For j:=1 To Len(aSIX[i])
				If FieldPos(aEstrut[j])>0
					FieldPut(FieldPos(aEstrut[j]),aSIX[i,j])
				EndIf
			Next j
			dbCommit()
			MsUnLock()
			cTexto += "Incluyo en la tabla "+aSIX[i,1]+" el indice "+aSIX[i,2]+ " como : "+aSIX[i,3]+CRLF

		else
		   //Forza actualizacion de indices
			RecLock("SIX",.f.)
			For j:=1 To Len(aSIX[i])
				//if alltrim(&("SIX->"+aEstrut[j])) <>alltrim(aSIX[i,j])
				    cTexto += "Actualizó el indice "+aSIX[i,2]+ "de la tabla "+aSIX[i,1]+". Contenido actual de "+aEstrut[j]+ ":"+alltrim(&("SIX->"+aEstrut[j]))+" Reemplazado con : "+ alltrim(aSIX[i,j])+CRLF
				//EndIf
				If FieldPos(aEstrut[j])>0
					FieldPut(FieldPos(aEstrut[j]),aSIX[i,j])
				EndIf
				
			Next j
			dbCommit()
			MsUnLock()
			
			
		EndIf

	
	//oMtParci:Set(++nAtuParci); SysRefresh()
Next i

cTexto += "Finalizo actualizacion de Indices (SIX)"+CRLF+ CRLF 
 
Return

Static Function UPDSX3()
Local aSX3   	 := {}
Local aEstrut	 := {}
Local i      	 := 0 
Local j      	 := 0
Local cAlias 	 := "" 
Local cOrdem     := "00"

Local cContenido:=''
Local cConRec:=''
Local lDif:= .f.

aEstrut := {"X3_ARQUIVO","X3_ORDEM","X3_CAMPO","X3_TIPO","X3_TAMANHO","X3_DECIMAL","X3_TITULO","X3_TITSPA","X3_TITENG","X3_DESCRIC","X3_DESCSPA","X3_DESCENG","X3_PICTURE","X3_VALID","X3_USADO","X3_RELACAO","X3_F3","X3_NIVEL","X3_RESERV","X3_CHECK","X3_TRIGGER","X3_PROPRI","X3_BROWSE","X3_VISUAL","X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER","X3_CBOX","X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN","X3_INIBRW","X3_GRPSXG","X3_FOLDER","X3_PYME","X3_CONDSQL","X3_CHKSQL"}
SX3->(dbSetOrder(1))
SX3->(dbSeek("RG1"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="RG1" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
aAdd(aSx3,{'RG1',cOrdem ,'RG1_DINIPG','D',8,0,'Dt.Ini.Pagto','Fc.Ini.Pago','Pmt.Strt.Dt.','Data Inicio do Pagto','Fecha Inicio de Pago','Payment Start Date','','','€€€€€€€€€€€€€€ ','dDatabase','',1,'ÇÀ','','',"" ,'S','A','R','','','','','','','Gpea550When()','','','','S','',''})

SX3->(dbSetOrder(2))
If !SX3->(dbSeek("RG1_DINIPG"))
     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'RG1',cOrdem ,'RG1_LIBPAG','D',8,0,'Dt.Lib.Pagto','Fc.Lib.Pago','Pmt.Rel.Date','Data Liberação do Pagto','Fecha Liberación de Pago','Payment Release Date','','VAZIO() .OR. M->RG1_LIBPAG >= GDFIELDGET( "RG1_DINIPG" )','€€€€€€€€€€€€€€ ','CTOD("")','',1,'ÖÀ','','',"" ,'S','A','R','','','','','','','Gpea550When()','','','','S','',''})
If !SX3->(dbSeek("RG1_LIBPAG"))
     cOrdem := Soma1(cOrdem)
EndIf

cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("SRA"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="SRA" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
aAdd(aSx3,{'SRA',cOrdem ,'RA_DVACANT','N',6,1,'Fér Per Ant','Vac Per Ant.','Prv Per Vac','Férias Períodos Anteriore','Vac Periodos Ant.','Previous Periods Vacation','@E 9,999.9','','€€€€€€€€€€€€€€ ','','',1,'ÆÀ','','',"" ,'S','V','R','','','','','','','','','','','S','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("RA_DVACANT"))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'SRA',cOrdem ,'RA_DVACACT','N',6,1,'Fér Per Act','Vac Per Act.','Cur Per Vac','Férias Período Actual','Vac Periodo Act.','Current Period Vacation','@E 9,999.9','','€€€€€€€€€€€€€€ ','','',1,'ÆÀ','','',"" ,'S','V','R','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("RA_DVACACT"))
     
     cOrdem := Soma1(cOrdem)
EndIf

aAdd(aSx3,{'SRA',cOrdem ,'RA_JORNRED','N',1,0,'Jorn. Reduz.','Jorn. Reduc.','','Jornada Reduzida','Jornada Reducida','','@E 9','Pertence("12")','€€€€€€€€€€€€€€ ','2','',1,'þÀ','','',"" ,'N','A','R','','','1=Sim;2=Não','1=Si;2=No','','','','','','','S','',''})
If !SX3->(dbSeek("RA_JORNRED"))

     cOrdem := Soma1(cOrdem)
EndIf


cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("SRJ"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="SRJ" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
aAdd(aSx3,{'SRJ',cOrdem ,'RJ_SALMIN','N',12,2,'Sdo. Mín p/O','Sdo. Min p/O','','Sdo Mínimo p/Contrib O.S.','Sdo Minimo p/Aporte O.S.','','@E 999,999,999.99','','€€€€€€€€€€€€€€ ','','',1,'ÞÀ','','',"" ,'N','A','R','','','','','','','','','','','S','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("RJ_SALMIN "))

     cOrdem := Soma1(cOrdem)
EndIf


cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("SD2"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="SD2" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
aAdd(aSx3,{'SD2',cOrdem ,'D2_COD','C',15,0,'Produto','Producto','Product','Codigo do Produto','Codigo del Producto','Product Code','@!','vazio() .or. (ExistCpo("SB1") .And. ALocPrdGrd(.F.) .And. MaFisRef("IT_PRODUTO","MT100",M->D2_COD))','€€€€€€€€€€€€€€ ','','SB1',1,'ƒ€','','S',"" ,'S','','','','','','','','','','','030','','S','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("D2_COD    "))
     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'SD2',cOrdem ,'D2_PROVENT','C',2,0,'Est. Entrega','Est. Entrega','Deliv.Forec.','Est. Entr. ou Prest. Serv','Est. Entr. o Prest. Serv','Deliv.Forec.or Serv.Rend.','@!','LocProEnIt() .And. MaFisRef("IT_PROVENT","MT100",M->D2_PROVENT)','€€€€€€€€€€€€€€ ','GetProvEnt("SD2")','',1,'ÞÀ','','',"" ,'','','','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("D2_PROVENT"))
     
     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'SD2',cOrdem ,'D2_QUANT','N',11,2,'Quantidade','Cantidad','Quantity','Quantidade do Produto','Cantidad del producto','Quantity of Product','@E 99999999.99','Positivo().and. A100SegUm().And.MaFisRef("IT_QUANT","MT100",M->D2_QUANT)','€€€€€€€€€€€€€€ ','','',1,'›€','','',"" ,'S','','','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("D2_QUANT  "))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'SD2',cOrdem ,'D2_RATEIO','C',1,0,'Rateio','Prorrateo','Apportion','Rateio','Prorrateo','Apportion','@!','Pertence("12") .And. NCPRATCC(M->D2_RATEIO)','€€€€€€€€€€€€€€ ','"2"','',1,'ÆÀ','','',"" ,'','','','','','1=Sim;2=Nao','1=Sí;2=No','1=Yes;2=No','','','','','','S','',''})
If !SX3->(dbSeek("D2_RATEIO "))
     
     cOrdem := Soma1(cOrdem)
EndIf

cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("SF2"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="SF2" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
aAdd(aSx3,{'SF2',cOrdem ,'F2_XMLNFE','M',10,0,'XML de envio','Xml de Envio','Deliv XML','XML de envio','Xml de Envio','Delivery XML','@!','','€€€€€€€€€€€€€€ ','','',1,'ÆÀ','','',"" ,'N','A','R','','','','','','','','','','','S','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("F2_XMLNFE "))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'SF2',cOrdem ,'F2_DTCANC','D',8,0,'Dta. Canc R','Fch Anulac.R','R Canc Dt','Data de Cancelamento Remi','Fecha de Anulacion Remito','Remi Cancel Date','','','€€€€€€€€€€€€€€ ','','',1,'Þ€','','',"" ,'S','A','R','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("F2_DTCANC "))
     
     cOrdem := Soma1(cOrdem)
EndIf
     aAdd(aSx3,{'SF2',cOrdem ,'F2_OBSERV','C',30,0,'Observac.','Observac.','Note','Mensagem em Livro Fiscal','Mensaje en Libro Fiscal','Tax Record Message','@!','','€€€€€€€€€€€€€€ ','','',1,'Þ€','','',"" ,'N','A','R','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("F2_OBSERV "))

     cOrdem := Soma1(cOrdem)
EndIf

cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("SFP"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="SFP" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
aAdd(aSx3,{'SFP',cOrdem ,'FP_ESPECIE','C',1,0,'Especie','Clase','Type','Especie da NF','Clase de factura','Type of invoice','@!','Pertence("1234567")','€€€€€€€€€€€€€€ ','','',1,'„€','','',"" ,'S','A','R','','','1=NF;2=NCI;3=NDI;4=NCC;5=NDC;6=RFN;7=RFD','1=Fac;2=NCI;3=NDI;4=NCC;5=NDC;6=RFN;7=RFD','1=NF;2=NCI;3=NDI;4=NCC;5=NDC;6=RFN;7=RFD','','M992TpFact()','','','','S','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("FP_ESPECIE"))
     
     cOrdem := Soma1(cOrdem)
EndIf

cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("CCO"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="CCO" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
     aAdd(aSx3,{'CCO',cOrdem ,'CCO_RPROAG','C',1,0,'Ret. Prov.','Ret. Prov.','Prov. Ret.','Ret. Prov. entre agentes','Ret. Prov. entre agentes','Ret. Prov. between agents','@!','Pertence("SN")','€€€€€€€€€€€€€€ ','','',1,'„€','','',"" ,'S','A','R','','','S=SIM;N=Não','S=Si;N=No','S=YES;N=NO','','','','','','S','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("CCO_RPROAG"))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'CCO',cOrdem ,'CCO_CPERNC','C',1,0,'Perc. FC/NC','Perc. FC/NC','FC/NC Perc.','Calc. Percepcao FC/NC','Cálc. Percepción FC/NC','FC/NC Perception Calc.','@!','Pertence ("1234567890")','€€€€€€€€€€€€€€ ','"1"','',1,'ÇÀ','','',"" ,'','','','','','#fBoxCPERNC()','#fBoxCPERNC()','#fBoxCPERNC()','','','','','','S','',''})
If !SX3->(dbSeek("CCO_CPERNC"))
     
     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'CCO',cOrdem ,'CCO_TPCALC','C',1,0,'Tip Cál Ret','Tip Cal Ret','','Tipo cálculo retenciones','Tipo Cálculo Retenciones','','@!','Vazio() .Or. Pertence("12")','€ €€€€€€€€€€€€€','','',1,'„€','','',"" ,'','A','R','','','1=Por parcela;2=Por total','1=Por cuota;2=Por total','','','','','','','S','',''})
If !SX3->(dbSeek("CCO_TPCALC"))

     cOrdem := Soma1(cOrdem)
EndIf

cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("SFF"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="SFF" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
aAdd(aSx3,{'SFF',cOrdem ,'FF_REDBASE','N',6,2,'Reduc. Base','Reduc. Base','Base Reduc.','Porc. de Reduc. de Base','Porc. de Reduc. de Base','Percent. of Base Reduct.','@E 999.99','IIf(FindFunction("A994VdRBase"),A994VdRBase(),.F.)','€€€€€€€€€€€€€€ ','','',1,'†À','','',"" ,'S','A','R','','','','','','','','','','','S','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("FF_REDBASE"))
     
     cOrdem := Soma1(cOrdem)
EndIf
     aAdd(aSx3,{'SFF',cOrdem ,'FF_RET_MUN','C',5,0,'Cód Ret Mun','Cod. Ret Mun','Cit Withh Cd','Cód. Ret. Municipal','Cod. Ret Municipal','City Withholding Code','@!','Vazio() .Or. ExistCpo("SX5","S1"+M->FF_RET_MUN)','€€€€€€€€€€€€€€ ','','S1',1,'Æ€','','',"" ,'N','A','R','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("FF_RET_MUN"))

     cOrdem := Soma1(cOrdem)
EndIf

aAdd(aSx3,{'SFF',cOrdem ,'FF_TPLIM','C',1,0,'Qual. Limite','Cal. Límit','Qual. Limit','Qualif. Limite','Calif. Límite','Qualification Limit','@!','ertence(" 01234") .And. If(FindFunction("A994VldLim"),A994VldLim(),.T.)','‚ €€€€ €€€€€€€€','','',1,'Ä€','','',"" ,'S','A','R','','','#fBoxTPLIM()','#fBoxTPLIM()','','','','','','','S','',''})
If !SX3->(dbSeek("FF_TPLIM  "))
     
     cOrdem := Soma1(cOrdem)
EndIf



cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("SF1"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="SF1" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
     aAdd(aSx3,{'SF1',cOrdem ,'F1_XMLNFE','M',10,0,'XML de envio','Xml de Envio','Deliv XML','XML de envio','Xml de Envio','Delivery XML','','','€€€€€€€€€€€€€€ ','','',1,'ÆÀ','','',"" ,'N','A','R','','','','','','','','','','','S','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("F1_XMLNFE "))

     cOrdem := Soma1(cOrdem)
EndIf
cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("AI0"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="AI0" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
aAdd(aSx3,{'AI0',cOrdem ,'AI0_PADRBA','C',1,0,'Padrão ARBA','Pad. ARBA','ARBA Stndrd','Padrão ARBA','Padrón ARBA','ARBA Standard','@!','Vazio() .Or. Pertence("SN")','€€€€€€€€€€€€€€ ','','',1,'Æ€','','',"" ,'','','','','','S=Sim;N=Não','S=Si;N=No','S=Yes;N=No','','','','','','S','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("AI0_PADRBA"))
     
     cOrdem := Soma1(cOrdem)
EndIf
cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("SA2"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="SA2" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
     aAdd(aSx3,{'SA2',cOrdem ,'A2_DTFCALG','D',8,0,'Dat Fin Publ','Fch.Fin.Publ','Publi end dt','Data final publicação','Fecha final publicación','Publication end date','','','€€€€€€€€€€€€€€ ','','',1,'€€','','',"" ,'','A','R','','','','','','','','','','','S','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("A2_DTFCALG"))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'SA2',cOrdem ,'A2_DTICALG','D',8,0,'Dat Ini Publ','Fch.Ini.Publ','Publi srt dt','Data de publicação','Fecha de publicación','Publication date','','','€€€€€€€€€€€€€€ ','','',1,'„€','','',"" ,'','A','R','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("A2_DTICALG"))
     
     cOrdem := Soma1(cOrdem)
EndIf
     aAdd(aSx3,{'SA2',cOrdem ,'A2_SITUACA','C',1,0,'Situação','Situacion','Status','Situac. Atual Fornecedor','Situac. actual Proveedor','Current status of supplie','@!','Pertence("1234")','€€€€€€€€€€€€€€ ','"1"','',1,'†À','','',"" ,'N','A','R','','','1=Normal;2=Risco;3=Monocontribuinte;4=NFs Apócrifas','1=Normal;2=Riesgo;3=Monotributista;4=Facturas Apocrifas','1=Regular;2=Risk;3=Single taxpayer;4=Apocryphal Invoices','','','','','','S','',''})
If !SX3->(dbSeek("A2_SITUACA"))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'SA2',cOrdem ,'A2_PADRBA','C',1,0,'Padrão ARBA','Pad. ARBA','ARBA Stndrd','Padrão ARBA','Padrón ARBA','ARBA Standard','@!','Vazio() .Or. Pertence("SN")','€€€€€€€€€€€€€€ ','','',1,'Æ€','','',"" ,'','','','','','S=Sim;N=Não','S=Si;N=No','S=Yes;N=No','','','','','','S','',''})
If !SX3->(dbSeek("A2_PADRBA "))
     
     cOrdem := Soma1(cOrdem)
EndIf
cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("SA1"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="SA1" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
     aAdd(aSx3,{'SA1',cOrdem ,'A1_SITUACA','C',1,0,'Situação','Situacion','Status','Situação atual do cliente','Situacion actual cliente','Current status of custome','@!','Pertence("1234")','€€€€€€€€€€€€€€ ','"1"','',1,'†À','','',"" ,'','A','R','','','1=Normal;2=Risco;3=Monocontribuinte;4=NFs Apócrifas','1=Normal;2=Riesgo;3=Monotributista;4=Facturas Apocrifas','1=Regular;2=Risk;3=Single taxpayer;4=Apocryphal Invoices','','','','','','S','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("A1_SITUACA"))

     cOrdem := Soma1(cOrdem)
EndIf
cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("DBA"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="DBA" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
aAdd(aSx3,{'DBA',cOrdem ,'DBA_DTHAWB','D',8,0,'Dt Processo','Fch Proceso','Process Dt.','Dt. Processo','Fch. Proceso','Process Date','','','€€€€€€€€€€€€€€ ','','',1,'‡€','','',"" ,'S','A','R','','','','','','','','','','1','N','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("DBA_DTHAWB"))
     
     cOrdem := Soma1(cOrdem)
EndIf
     aAdd(aSx3,{'DBA',cOrdem ,'DBA_DESP','C',3,0,'Cod. Despach','Cod. Despach','Broker Cd.','Despachante','Despachante','Broker','@!','Vazio().Or.ExistCpo("DB9")','€€€€€€€€€€€€€€ ','','DB9',1,'‡€','','S',"" ,'N','A','R','','','','','','','','','','1','N','',''})
If !SX3->(dbSeek("DBA_DESP  "))

     cOrdem := Soma1(cOrdem)
EndIf
cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("DBB"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="DBB" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
     aAdd(aSx3,{'DBB',cOrdem ,'DBB_SERIE','C',3,0,'Serie','Serie','Series','Serie do Documento','Serie del documento','Document Series','!!!','','€€€€€€€€€€€€€€ ','','',1,'šÀ','','',"" ,'N','A','R','','','','','','','','','094','','N','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("DBB_SERIE "))

     cOrdem := Soma1(cOrdem)
EndIf
cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("SF3"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="SF3" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
aAdd(aSx3,{'SF3',cOrdem ,'F3_ALQIMP1','N',6,2,'Aliq. Imp. 1','Alic. Imp. 1','Tax Rate 1','Aliquota do Imposto 1','Alicuota del Impuesto 1','Income Tax Rate 1','@E 999.99','','€€€€€€€€€€€€€€ ','','',1,'œÀ','','',"" ,'N','','','','','','','','','','','','','S','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("F3_ALQIMP1"))
     
     cOrdem := Soma1(cOrdem)
EndIf

//******
cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("AI0"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="AI0" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
aAdd(aSx3,{'AI0',cOrdem ,'AI0_ADIC5','C',5,0,'Dado Oper.','Dato Oper.','Oper Data','Dado Operação','Dato Operacion','Operation Data','@!','Vazio() .Or. EXISTCPO("SX5","XJ"+M->AI0_ADIC5)','€€€€€€€€€€€€€€ ','','XJ',1,'„€','','',"" ,'S','A','R','','','','','','','','','','','S','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("AI0_ADIC5 "))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'AI0',cOrdem ,'AI0_ADIC61','C',5,0,'Dado ID Doc','Dato ID Doc.','Doc ID Data','Dado ID documento','Dato ID documento','Document ID Data','@!','Vazio() .Or. EXISTCPO("SX5","OC"+M->AI0_ADIC61)','€€€€€€€€€€€€€€ ','','OC',1,'„€','','',"" ,'S','A','R','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("AI0_ADIC61"))
     
     cOrdem := Soma1(cOrdem)
EndIf
     aAdd(aSx3,{'AI0',cOrdem ,'AI0_ADIC62','C',20,0,'Nº de Doc','Num. de Doc','Doc No','Número de documento','Numero de documento','Document Number','@!','','€€€€€€€€€€€€€€ ','','',1,'„€','','',"" ,'S','A','R','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("AI0_ADIC62"))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'AI0',cOrdem ,'AI0_ADIC7','C',5,0,'Assinante','Suscriptor','Signee','Assinante','Suscriptor','Signee','@!','Vazio() .Or. EXISTCPO("SX5","XK"+M->AI0_ADIC7)','€€€€€€€€€€€€€€ ','','XK',1,'„€','','',"" ,'S','A','R','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("AI0_ADIC7 "))
     
     cOrdem := Soma1(cOrdem)
EndIf
     aAdd(aSx3,{'AI0',cOrdem ,'AI0_DESDE','D',8,0,'Data Início','Fch. Inicio','St Date','Data de Início','Fecha de inicio','Start Date','','VldFch()','€€€€€€€€€€€€€€ ','','',1,'„€','','',"" ,'S','A','R','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("AI0_DESDE "))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'AI0',cOrdem ,'AI0_HASTA','D',8,0,'Data Final','Fch. Final','End Date','Data Final da Vigência','Fecha de fin de vigencia','Validity End Date','','VldFch()','€€€€€€€€€€€€€€ ','','',1,'„€','','',"" ,'S','A','R','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("AI0_HASTA "))
     
     cOrdem := Soma1(cOrdem)
EndIf
cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("SL1"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="SL1" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
aAdd(aSx3,{'SL1',cOrdem ,'L1_ADIC5','C',5,0,'Dado Oper.','Dato Operaci','Oper Data','Dado Operação','Dato Operación','Operation Data','@!','Vazio() .Or. EXISTCPO("SX5","XJ"+M->L1_ADIC5)','€€€€€€€€€€€€€€ ','','XJ',1,'„€','','',"" ,'S','A','R','','','','','','','','','','','S','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("L1_ADIC5  "))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'SL1',cOrdem ,'L1_ADIC7','C',5,0,'Assinante','Suscriptor','Signee','Assinante','Suscriptor','Signee','@!','Vazio() .Or. EXISTCPO("SX5","XK"+M->L1_ADIC7)','€€€€€€€€€€€€€€ ','','XK',1,'„€','','',"" ,'S','A','R','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("L1_ADIC7  "))
     
     cOrdem := Soma1(cOrdem)
EndIf
     aAdd(aSx3,{'SL1',cOrdem ,'L1_ADIC61','C',5,0,'Dado ID Doc','Dato ID docu','Doc ID Data','Dado ID documento','Dato ID documento','Document ID Data','@!','Vazio() .Or. EXISTCPO("SX5","OC"+M->L1_ADIC61)','€€€€€€€€€€€€€€ ','','OC',1,'„€','','',"" ,'S','A','R','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("L1_ADIC61 "))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'SL1',cOrdem ,'L1_ADIC62','C',20,0,'Nº de Doc','Nro. de Doc.','Doc No','Número de documento','Numero de documento','Document Number','@!','','€€€€€€€€€€€€€€ ','','',1,'„€','','',"" ,'S','A','R','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("L1_ADIC62 "))
     
     cOrdem := Soma1(cOrdem)
EndIf
cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("SLQ"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="SLQ" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
     aAdd(aSx3,{'SLQ',cOrdem ,'LQ_ADIC61','C',5,0,'Dado ID Doc','Dato ID docu','Doc ID Data','Dado ID documento','Dato ID documento','Document ID Data','@!','Vazio() .Or. EXISTCPO("SX5","OC"+M->LQ_ADIC61)','€€€€€€€€€€€€€€ ','','OC',1,'„€','','',"" ,'S','A','R','','','','','','','','','','','S','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("LQ_ADIC61 "))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'SLQ',cOrdem ,'LQ_ADIC7','C',5,0,'Assinante','Suscriptor','Signee','Assinante','Suscriptor','Signee','@!','Vazio() .Or. EXISTCPO("SX5","XK"+M->LQ_ADIC7)','€€€€€€€€€€€€€€ ','','XK',1,'„€','','',"" ,'S','A','R','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("LQ_ADIC7  "))
     
     cOrdem := Soma1(cOrdem)
EndIf
     aAdd(aSx3,{'SLQ',cOrdem ,'LQ_ADIC5','C',5,0,'Dado Oper.','Dato Operaci','Oper Data','Dado Operação','Dato Operación','Operation Data','@!','Vazio() .Or. EXISTCPO("SX5","XJ"+M->LQ_ADIC5)','€€€€€€€€€€€€€€ ','','XJ',1,'„€','','',"" ,'S','A','R','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("LQ_ADIC5  "))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'SLQ',cOrdem ,'LQ_ADIC62','C',20,0,'Nº de Doc','Nro. de Doc.','Doc No','Número de documento','Numero de documento','Document Number','@!','','€€€€€€€€€€€€€€ ','','',1,'„€','','',"" ,'S','A','R','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("LQ_ADIC62 "))
     
     cOrdem := Soma1(cOrdem)
EndIf
cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("SE5"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="SE5" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
aAdd(aSx3,{'SE5',cOrdem ,'E5_RG104','C',1,0,'RG104/2004','RG104/2004','RG104/2004','Distrib. Conv. RG104/2004','Distrib. Conv. RG104/2004','RG104/2004 Conv. Distrib','@!','Pertence("SN")','€€€€€€€€€€€€€€ ','','',1,'—À','','',"" ,'S','A','R','','','S=Sim;N=Não','S=Si;N=No','S=Yes;N=No','','','','','','S','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("E5_RG104  "))

     cOrdem := Soma1(cOrdem)
EndIf
     aAdd(aSx3,{'SE5',cOrdem ,'E5_FORMAPG','C',5,0,'FORMA PAGTO','FORMA PAGO','PAYM TERM','FORMA DE PAGAMENTO','FORMA DE PAGO','PAYMENT TEM','@!','','€€€€€€€€€€€€€€€','','',1,'†À','','',"" ,'N','','R','','','','','','','','','','','N','',''})
If !SX3->(dbSeek("E5_FORMAPG"))

     cOrdem := Soma1(cOrdem)
EndIf
cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("SEU"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="SEU" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
aAdd(aSx3,{'SEU',cOrdem ,'EU_NROADIA','C',10,0,'Numero Adia.','Numero Antec','Adv. Number','Numero adiant.relacionado','Numero del Anticipo Rel.','Advanc. Related Number','9999999999','','€€€€€€€€€€€€€€ ','','',1,'–€','','',"" ,'N','A','R','','','','','','','','','','','S','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("EU_NROADIA"))
     
     cOrdem := Soma1(cOrdem)
EndIf
cOrdem     := "00"
SX3->(dbSetOrder(1))
SX3->(dbSeek("SF1"))
While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO =="SF1" 
       cOrdem := SX3->X3_ORDEM
       SX3->(DBSKIP())
Enddo
cOrdem := Soma1(cOrdem)
     aAdd(aSx3,{'SF1',cOrdem ,'F1_NUMDES','C',16,0,'N§ Despacho','Nr.Despacho','Dispatch Nr.','No. do Despacho','Nro.del Despacho','Dispatch Number','@!','','€€€€€€€€€€€€€€','','',1,'úÀ','','',"" ,'S','','','','','','','','','','','','','N','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("F1_NUMDES "))

     cOrdem := Soma1(cOrdem)
EndIf

cOrdem := "00"
aAdd(aSx3,{'FVC',cOrdem ,'FVC_FILIAL','C',8,0,'Filial','Filial','Branch','Filial do Sistema','Filial de Sistema','System branch','','','€€€€€€€€€€€€€€€','','',1,'„€','','',"" ,'N','','','','','','','','','','','033','','S','',''})
SX3->(dbSetOrder(2))
If !SX3->(dbSeek("FVC_FILIAL"))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'FVC',cOrdem ,'FVC_PREOP','C',12,0,'Nº Pré OP','Num. Pre OP','Pre PO no.','Nº Ordem Pagamento Prévia','Num. Orden Pago Previa','Prev. Payment Order No.','@!','','€€€€€€€€€€€€€€ ','','',1,'„€','','',"" ,'','','','','','','','','','','','015','','S','',''})
If !SX3->(dbSeek("FVC_PREOP "))
   
     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'FVC',cOrdem ,'FVC_FORNEC','C',6,0,'Forncedor','Proveedor','Supplier','Código do Fornecedor','Código del Proveedor.','Supplier Code','@!','','€€€€€€€€€€€€€€ ','','',1,'†€','','',"" ,'S','','','','','','','','','','','001','','S','',''})
If !SX3->(dbSeek("FVC_FORNEC"))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'FVC',cOrdem ,'FVC_LOJA','C',2,0,'Filial','Sucursal','Branch','Filial','Sucursal','Branch','@!','','€€€€€€€€€€€€€€ ','','',1,'–€','','',"" ,'S','','','','','','','','','','','002','','S','',''})
If !SX3->(dbSeek("FVC_LOJA  "))
     
     cOrdem := Soma1(cOrdem)
EndIf
     aAdd(aSx3,{'FVC',cOrdem ,'FVC_TIPO','C',1,0,'Tipo','Tipo','Type','Tipo de Imposto','Tipo de Impuesto','Tax Type','@!','Pertence("IBG")','€€€€€€€€€€€€€€ ','','',1,'–€','','',"" ,'S','','','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("FVC_TIPO  "))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'FVC',cOrdem ,'FVC_CONCEP','C',2,0,'Verba','Concepto','Funds','Verba p/Líq de IR','Concepto p/neto de IR','Funds f/ net inc. tax','@!','','€€€€€€€€€€€€€€ ','','',1,'”€','','',"" ,'','A','','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("FVC_CONCEP"))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'FVC',cOrdem ,'FVC_CFO','C',3,0,'Cód. Fiscal','Cod. Fiscal','Tax Code','Código Fiscal Operação','Código Fiscal Operación','Operation Tax Code','999','ExistCpo("SX5","13"+M->FVC_CFO)','€€€€€€€€€€€€€€ ','','',1,'„€','','',"" ,'S','','','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("FVC_CFO   "))
     
     cOrdem := Soma1(cOrdem)
EndIf
     aAdd(aSx3,{'FVC',cOrdem ,'FVC_NFISC','C',12,0,'Nota Fiscal','Factura','Invoice','Número da Nota Fiscal','Numero de la Factura','Invoice number','@!','','€€€€€€€€€€€€€€ ','','',1,'†€','','',"" ,'','','','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("FVC_NFISC "))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'FVC',cOrdem ,'FVC_SERIE','C',3,0,'Série','Serie','Series','Série da Nota Fiscal','Serie de la Factura','Invoice series','@!','','€€€€€€€€€€€€€€ ','','',1,'–€','','',"" ,'','','','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("FVC_SERIE "))
     
     cOrdem := Soma1(cOrdem)
EndIf
     aAdd(aSx3,{'FVC',cOrdem ,'FVC_PARCEL','C',1,0,'Quota','Cuota','Quota','Quota da Nota Fiscal','Cuota de la Factura','Invoice quota','@!','','€€€€€€€€€€€€€€ ','','',1,'–À','','',"" ,'','V','','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("FVC_PARCEL"))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'FVC',cOrdem ,'FVC_VALBAS','N',12,2,'Valor Base','Valor Base','Base Value','Valor Base Disponível','Valor Base Disponible','Available Base Value','@E 999,999,999.99','','€€€€€€€€€€€€€€ ','','',1,'–€','','',"" ,'','','','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("FVC_VALBAS"))
     
     cOrdem := Soma1(cOrdem)
EndIf
     aAdd(aSx3,{'FVC',cOrdem ,'FVC_ALIQ','N',6,2,'Alíquota','Alicuota','Rate','Alíquota Imposto/Retenção','Alicuota Impuesto/Retenci','Withh/Tax Rate','@E 999.99','','€€€€€€€€€€€€€€ ','','',1,'–À','','',"" ,'','','','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("FVC_ALIQ  "))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'FVC',cOrdem ,'FVC_DEDUC','N',16,2,'Dedução','Deducción','Deduction','Valor da Dedução','Valor de la  Deducción','Deduction Amount','@E 9,999,999,999,999.99','','€€€€€€€€€€€€€€ ','','',1,'þÀ','','',"" ,'','A','','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("FVC_DEDUC "))
     
     cOrdem := Soma1(cOrdem)
EndIf
     aAdd(aSx3,{'FVC',cOrdem ,'FVC_PORCR','N',6,2,'% de Retenç','% de Retenc.','Withh %','% de não Ret. da Retenção','% de no Ret. de la Retenc','Non withh % of withholdin','@E 999.99','','€€€€€€€€€€€€€€ ','','',1,'žÀ','','',"" ,'','A','','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("FVC_PORCR "))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'FVC',cOrdem ,'FVC_EST','C',2,0,'Estado','Estado','State','Estado','Estado','State','@!','ExistCpo("SX5","12"+M->FVC_EST)','€€€€€€€€€€€€€€ ','','',1,'–À','','',"" ,'','A','R','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("FVC_EST   "))
     
     cOrdem := Soma1(cOrdem)
EndIf
     aAdd(aSx3,{'FVC',cOrdem ,'FVC_DESGR','N',6,2,'Desoneração','Desgravamen','Exoneration','Porcentagem de desoneraçã','Porcentaje de Desgravamen','Exoneration percentage','@E 999.99','','€€€€€€€€€€€€€€ ','','',1,'„€','','',"" ,'S','A','R','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("FVC_DESGR "))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'FVC',cOrdem ,'FVC_RETENC','N',16,2,'Retenção','Retención','Withholding','Valor da Retenção','Valor de la Retención','Withholding value','@E 9,999,999,999,999.99','','€€€€€€€€€€€€€€ ','','',1,'–À','','',"" ,'','','','','','','','','','','','','','S','',''})
If !SX3->(dbSeek("FVC_RETENC"))
     
     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'FVC',cOrdem ,'FVC_FORCON','C',6,0,'Forn. Cond.','Prov. Cond','Condo Supp','Fornecedor Condomínio','Proveedor condominio','Condominium Supplier','@!','','€€€€€€€€€€€€€€ ','','',1,'ÖÀ','','',"" ,'','A','R','','','','','','','','','001','','S','',''})
If !SX3->(dbSeek("FVC_FORCON"))

     cOrdem := Soma1(cOrdem)
EndIf
aAdd(aSx3,{'FVC',cOrdem ,'FVC_LOJCON','C',2,0,'Lja. Cond.','Tda Cond.','Condo Store','Loja Condomínio','Tienda condominio','Condominium Store','@!','','€€€€€€€€€€€€€€ ','','',1,'ÆÀ','','',"" ,'','','','','','','','','','','','002','','S','',''})
If !SX3->(dbSeek("FVC_LOJCON"))
     
     cOrdem := Soma1(cOrdem)
EndIf






nAtuParci := 0
cTexto += "----------  Inicia  actualizacion de Campos (SX3)  ----------"+CRLF+ CRLF
//oMtParci:nTotal := Len(aSX3)
dbSelectArea("SX3")
dbSetOrder(2)
For i:= 1 To Len(aSX3)
	if !SX3->(dbSeek(aSX3[i,3]))
		RecLock("SX3",.T.)
		For j:=1 To Len(aSX3[i])
			If FieldPos(aEstrut[j])>0 
				FieldPut(FieldPos(aEstrut[j]),aSX3[i,j])
			EndIf
		Next j
		dbCommit() 
		MsUnLock()
		cTexto += "Incluyo el campo "+aSX3[i,3]+CRLF
		IF(AScan( aArqUpd,aSX3[i,1])==0) 	//Guarda en el arreglo aArqUpd, las tablas que deberan regenerar estructura en la BD
				AADD(aArqUpd,aSX3[i,1])
		ENDIF
	else
	 		lDif2:= .f.
			For j:=1 To Len(aSX3[i])
				
				 ldif:= .f.
			    cContenido:=&("SX3->"+aEstrut[j])
				 cConRec:=aSX3[i,j]
			    if valtype(aSX3[i,j])=="N"
			    	if alltrim(STR(&("SX3->"+aEstrut[j]))) <> alltrim(STR(aSX3[i,j]))
			    	   lDif:= .T.
			    	ENDIF
			    	cContenido:=alltrim(str(&("SX3->"+aEstrut[j])))
				    cConRec:=alltrim(str(aSX3[i,j]))
			    else
			    	if alltrim(&("SX3->"+aEstrut[j])) <> alltrim(aSX3[i,j])
			    	   lDif:= .T.
			    	ENDIF   
			    endif
			    
				if ldif
				    cTexto += "No Actualizó el campo "+alltrim(aSX3[i,3])+ " de la tabla "+alltrim(aSx3[i,1])+". Contenido actual de "+alltrim(aEstrut[j])+ ":"+alltrim(cContenido)+" Contenido recomendado :"+ alltrim(cConRec)+CRLF
				    lDif2:= .t. 
				EndIf
			next	
			if !lDif2
					cTexto += "Verificó el campo "+alltrim(aSX3[i,3])+ " de la tabla "+alltrim(aSx3[i,1])+", ya existe en el ambiente y son iguales."+CRLF
			endif
	endif	
		

Next i
cTexto += "Finalizo actualizacion de Campos (SX3)"+CRLF+ CRLF 
Return



Static Function UPDSX5()
Local aSX5   := {}  
Local aEstrut:= {}
Local i      := 0
Local j      := 0
Local lDif   := .f.

aEstrut := { "X5_FILIAL","X5_TABELA","X5_CHAVE","X5_DESCRI","X5_DESCSPA","X5_DESCENG"}
aAdd(aSX5,{'','00','XM    ','CÓD. PONTO VENDA','COD PUNTO VENTA','SALES POINT CODE'})
aAdd(aSX5,{'','XM','L     ','0000/0008/0009','0000/0008/0009','0000/0008/0009'})
aAdd(aSX5,{'','XM','M     ','2705/0003/0015/0023','2705/0003/0015/0023','2705/0003/0015/0023'})
aAdd(aSX5,{'','XM','N     ','0012/0018','0012/0018','0012/0018'})
aAdd(aSX5,{'','XM','O     ','0401/0006/0013','0401/0006/0013','0401/0006/0013'})
aAdd(aSX5,{'','XM','P     ','0001/0004/0014/0028','0001/0004/0014/0028','0001/0004/0014/0028'})
aAdd(aSX5,{'','XM','Q     ','0002/0019/0020','0002/0019/0020','0002/0019/0020'})
aAdd(aSX5,{'','XM','R     ','0003/0016/0017','0003/0016/0017','0003/0016/0017'})

aAdd(aSX5,{'','SF','V','CONVÊNIO MULTILATERAL','CONVENIO MULTILATERAL','MULTILATERAL AGREEMENT'})
aAdd(aSX5,{'','G0','15','Estorna Liquidação','Revierte Liquidación','Reverse Settlement'})
nAtuParci := 0
cTexto += "----------  Inicia actualizacion de Tablas Genericas (SX5)  ----------"+CRLF+ CRLF
//oMtParci:nTotal := Len(aSX5)
dbSelectArea("SX5")
dbSetOrder(1)
lSX5:=.f.
cAlias:=""
For i:= 1 To Len(aSX5)

		If !SX5->(dbSeek(XFILIAL("SX5")+aSX5[i,2]+aSX5[i,3]))
			RecLock("SX5",.T.)
			For j:=1 To Len(aSX5[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX5[i,j])
				EndIf
			Next j
			dbCommit()  
			MsUnLock()
			cTexto += "Incluyo en la tabla "+aSX5[i,2]+" la llave "+aSX5[i,3]+CRLF
		else	
		    lDif:= .f.
			For j:=1 To Len(aSX5[i])
				if ALLTRIM(&("SX5->"+aEstrut[j])) <> ALLTRIM(aSX5[i,j])
				    cTexto += "No Actualizó la Tabla Generica "+aSX5[i,2]+ " de la llave "+aSx5[i,3]+". Contenido actual de "+aEstrut[j]+ ":"+ALLTRIM(&("SX5->"+aEstrut[j]))+" Contenido recomendado :"+ ALLTRIM(aSx5[i,j])+CRLF
				    lDif:= .t.
				EndIf
			next
			if !lDif
				cTexto += "No Actualizó la Tabla Generica "+aSX5[i,2]+ " de la llave "+aSx5[i,3]+", ya existe"+CRLF
			endif	
		EndIf


Next i
cTexto +=  CRLF+"Finalizo actualizacion de Tablas Genericas (SX5)"+CRLF+ CRLF 
Return



Static Function UPDSX6()
Local aSX6   := {} 
Local aEstrut:= {}
Local i      := 0
Local j      := 0
Local lSX6	 := .F.

Local cAlias := ""
aEstrut := {"X6_FIL","X6_VAR","X6_TIPO","X6_DESCRIC","X6_DSCSPA","X6_DSCENG","X6_DESC1","X6_DSCSPA1","X6_DSCENG1","X6_DESC2","X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME"}
aAdd(aSX6,{'','MV_CODPF','C','Código Ponto de Faturamento','Codigo Punto de Facturacion','Billing Point Code','','','','','','','XM','XM','XM',"",'S'})
aAdd(aSX6,{'','MV_ESTORDT','C','Define se o saldo bancário após o estorno','Define si el Saldo Bancario tras la Reversion','Defines whether bank balance after reversal','da OP é criado com datas do Mov. de Estorno de','de Op se crea con fechas del Mov. de Rev. de','of PO is created w/ dates of Reversal Transactn of','OP. S = Sim / N = Não (Processo Normal).','OP. S = Si / N = No (Proceso Normal).','PO. Y=Yes/N=No (Regular Process)','N','N','N',"",'S'})
aAdd(aSX6,{'','MV_FCHINSC','D','Data de Inscrição','Fecha de Inscripción','Registration Date','','','','','','','','','',"",'S'})
aAdd(aSX6,{'','MV_FOLINSC','C','Fólio de Inscrição','Folio de Inscripción','Registration folio','','','','','','','','','',"",'S'})
aAdd(aSX6,{'','MV_LIBINSC','C','Livro Inscrição','Libro Inscripción','Registration Book','','','','','','','','','',"",'S'})
aAdd(aSX6,{'','MV_LIMCUOT','N','Indica a quantidade máxima de parcelas a emitir','Indica la cantidad máxima de cuotas a otorgar','Indicates the maximum number of installments to is','conforme o Regime Especial de Facilidades de','de acuerdo al Régimen Especial de Facilidades de','sue according to the Special System of Payment','Pagamento','Pago','Facilities','120','120','120',"",'N'})
aAdd(aSX6,{'','MV_NROINSC','C','Número de Inscrição','Número de Inscripción','Registration Number','','','','','','','','','',"",'S'})

aAdd(aSX6,{'','MV_RETMZFC','C','Última data do processo de importação do padrão','Última fecha del proceso de importación del padrón','Last date of standard import process','de IIBB da província de Mendoza','de IIBB de la provincia de Mendoza','of IIBB of the province of Mendoza','','','','','','',"",'S'})
aAdd(aSX6,{'','MV_RG3806','N','Regime especial facilidades pagamento','Régimen Especial Facilidades Pago','Payment facilities special system','','','','','','','0','0','0',"",'S'})
aAdd(aSX6,{'','MV_RG99401','N','Número de apresentação (Valores entre 0 e 9)','Número Presentación (Valores entre 0 y 9)','Presentation number (Values between 0 and 9)','','','','','','','','','',"",'N'})
aAdd(aSX6,{'','MV_TOMINSC','C','Volume Inscrição','Tomo Inscripción','Registration Volume','','','','','','','','','',"",'S'})
aAdd(aSX6,{'','MV_TPSINSC','C','Tipo Sociedade Inscrição','Tipo Sociedad Inscripción','Registration Corp Type','','','','','','','','','',"",'S'})
aAdd(aSX6,{'','MV_VARINSC','C','Vários Inscrição','Varios Inscripción','Registration Various','','','','','','','','','',"",'S'})
aAdd(aSX6,{'','MV_ATFRSLD','L','','.T. = Determina si el control de las fechas de Ci','','','erre de Saldos en rutinas de Activo Fijo como Cier','','','e Anual/Calculo Mensual/Descalculo.','','.T.','.T.','.T.',"",''})
aAdd(aSX6,{'','MV_PERDEPR','C','','Calendario Fiscal Contable. Formato MM/DD|MM|DD.','','','Ejemplo 01/01|12/31.','','','','','7/01|06/30','7/01|06/30','7/01|06/30',"",''})

nAtuParci := 0
cTexto += "----------  Inicia actualizacion de Parametros (SX6)  ----------"+CRLF+ CRLF

dbSelectArea("SX6")
dbSetOrder(1)
For i:= 1 To Len(aSX6)
	If !Empty(aSX6[i][2])
		If !SX6->(dbSeek("        "+aSX6[i,2]))
			lSX6	:= .T.
			If !(aSX6[i,2]$cAlias)
				cAlias += aSX6[i,2] 
			EndIf
			RecLock("SX6",.T.)
			For j:=1 To Len(aSX6[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX6[i,j])
				EndIf
			Next j
			dbCommit()  
			MsUnLock()
			cTexto += "Incluyo el parametro "+aSX6[i,2]+CRLF
		Else
			For j:=1 To Len(aSX6[i])
				if ALLTRIM(&("SX6->"+aEstrut[j])) <>ALLTRIM(aSX6[i,j])
				    cTexto += "No Actualizó el parametro "+aSX6[i,2]+". Contenido actual de "+aEstrut[j]+ ":"+ALLTRIM(&("SX6->"+aEstrut[j]))+" Contenido recomendado :"+ ALLTRIM(aSx6[i,j])+CRLF
				EndIf
			next
			
		EndIf
	EndIf
//	oMtParci:Set(++nAtuParci); SysRefresh()
Next i
cTexto += "Finalizo actualizacion de Parametros (SX6)"+CRLF+ CRLF 
Return


Static Function UPDSX9()
Local aSX9   	 := {}
Local aEstrut	 := {}
Local i      	 := 0 
Local j      	 := 0
Local lExiste:= .f.
Local lDif:= .f.

aEstrut := {"X9_DOM","X9_IDENT","X9_CDOM","X9_EXPDOM","X9_EXPCDOM","X9_PROPRI","X9_LIGDOM","X9_LIGCDOM","X9_CONDSQL","X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR"}
aAdd(aSx9,{'DB9','001','DBA','DB9_COD','DBA_DESP','S','1','N','','S','S','2','2'})

aAdd(aSx9,{'SX5','001','AI0','X5_TABELA+X5_CHAVE',"'OC'+AI0_ADIC61",'S','1','N','','S','S','2','2'})
aAdd(aSx9,{'SX5','002','AI0','X5_TABELA+X5_CHAVE',"'XJ'+AI0_ADIC5",'S','1','N','','S','S','2','2'})
aAdd(aSx9,{'SX5','003','AI0','X5_TABELA+X5_CHAVE',"'XK'+AI0_ADIC7",'S','1','N','','S','S','2','2'})

aAdd(aSx9,{'SX5','004','SL1','X5_TABELA+X5_CHAVE',"'OC'+L1_ADIC61",'S','1','N','','S','S','2','2'})
aAdd(aSx9,{'SX5','005','SL1','X5_TABELA+X5_CHAVE',"'XJ'+L1_ADIC5",'S','1','N','','S','S','2','2'})
aAdd(aSx9,{'SX5','006','SL1','X5_TABELA+X5_CHAVE',"'XK'+L1_ADIC7",'S','1','N','','S','S','2','2'})

aAdd(aSx9,{'SX5','007','SLQ','X5_TABELA+X5_CHAVE',"'OC'+LQ_ADIC61",'S','1','N','','S','S','2','2'})
aAdd(aSx9,{'SX5','008','SLQ','X5_TABELA+X5_CHAVE',"'XJ'+LQ_ADIC5",'S','1','N','','S','S','2','2'})
aAdd(aSx9,{'SX5','009','SLQ','X5_TABELA+X5_CHAVE',"'XK'+LQ_ADIC7",'S','1','N','','S','S','2','2'})

cTexto += "----------  Inicia actualizacion de Relaciones (SX9)  ----------"+CRLF+ CRLF
nAtuParci := 0

sx9->(dbsetorder(2))
For i:= 1 To Len(aSX9)
		If !sx9->(dbSeek(aSX9[i,3]+aSX9[i,1]))  //si no la encuentra la incluye
			  
				RecLock("SX9",.T.)
				For j:=1 To Len(aSX9[i])
					If FieldPos(aEstrut[j]) > 0
						FieldPut(FieldPos(aEstrut[j]),aSX9[i,j])
					EndIf
				Next j
			
			dbCommit()   
			MsUnLock()
			cTexto += "Incluyo la relacion "+aSX9[i,1]+" "+aSX9[i,3]+CRLF
		ELSE
		   lExiste:= .f.
		   do while !(sx9->(eof())) .and. aSX9[i,3]+aSX9[i,1]==SX9->X9_CDOM+SX9->X9_DOM
		       if SX9->X9_IDENT == aSX9[i,2]
		           lExiste:= .t.
		           exit
		       endif
		       sx9->(dbskip())
		   enddo
		   if !lExiste
		   		RecLock("SX9",.T.)
				For j:=1 To Len(aSX9[i])
					If FieldPos(aEstrut[j]) > 0
						FieldPut(FieldPos(aEstrut[j]),aSX9[i,j])
					EndIf
				Next j
				dbCommit()   
				MsUnLock()
				cTexto += "Incluyo la relacion "+aSX9[i,1]+" "+aSX9[i,3]+CRLF
			else	
	   			lDif:= .f.
				For j:=1 To Len(aSX9[i])
					if ALLTRIM(&("SX9->"+aEstrut[j])) <> ALLTRIM(aSX9[i,j])
					    cTexto += "No actualizó la relacion "+aSX9[i,1] + " "+aSX9[i,3]+". Contenido actual de "+aEstrut[j]+ ":"+ALLTRIM(&("SX9->"+aEstrut[j]))+" Contenido recomendado :"+ ALLTRIM(aSX9[i,j])+CRLF
					    lDif:= .t.
					EndIf
					
				Next j
				if !ldif
	    			cTexto += "No actualizó la relacion "+aSX9[i,1] + " "+aSX9[i,3]+".Ya existe"+CRLF
	    		endif					
			endif	
		EndIf
	
	

Next i

cTexto += CRLF+"Finalizo actualizacion de Relaciones (SX9)"+CRLF+ CRLF 

Return


Static Function UPDSXB()
Local aSXB   := {}
Local aEstrut:= {}
Local i      := 0
Local j      := 0
Local lDif:= .f.
Local cAlias := ""
Local lSXB   := .F.
aEstrut :={"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM"}
aAdd(aSXB,{'CCP','1','01','DB','Tabela Equivalência','Tabla  Equivalencia','Equivalence Table','CCP'})
aAdd(aSXB,{'CCP','2','01','01','Código + Val. Origem','Codigo + Vlr. Origen','Code + Orig Val',''})
aAdd(aSXB,{'CCP','4','01','01','Código','Código','Code','CCP_COD'})
aAdd(aSXB,{'CCP','4','01','02','Descrição','Descripción','Description','CCP_DESCR'})
aAdd(aSXB,{'CCP','4','01','03','Val. Origem','Vlr. Origen','Orig Val','CCP_VORIGE'})
aAdd(aSXB,{'CCP','4','01','04','V. Destino','V. Destino','Target Val','CCP_VDESTI'})
aAdd(aSXB,{'CCP','5','01','','','','','CCP_COD'})
aAdd(aSXB,{'FI065P','1','01','RE','Estados','Provincias','States','SX5'})
aAdd(aSXB,{'FI065P','2','01','01','','','','FI065P()'})
aAdd(aSXB,{'FI065P','5','01','','','','','cProvi'})

aAdd(aSXB,{'FRE090','1','01','DB','Talonário de Cheques','Talon de Cheques','Checkbook','FRE'})
aAdd(aSXB,{'FRE090','2','01','01','BANCO+AGÊNCIA+CONTA','BANCO+AGENCIA+CUENTA','BANK+BRNCH+ACCNT',''})
aAdd(aSXB,{'FRE090','4','01','01','BANCO','BANCO','BANK','FRE_BANCO'})
aAdd(aSXB,{'FRE090','4','01','02','CONTA','CUENTA','ACCOUNT','FRE_CONTA'})
aAdd(aSXB,{'FRE090','4','01','03','TALONÁRIOS','TALON','CHECKBOOKS','FRE_TALAO'})
aAdd(aSXB,{'FRE090','5','01','','','','','FRE_TALAO'})
aAdd(aSXB,{'FRE090','6','01','','','','','(Alltrim(FRE->FRE_BANCO) == Alltrim(cBcoSub) .AND. Alltrim(FRE->FRE_AGENCI) == Alltrim(cAgeSub) .AND. Alltrim(FRE->FRE_CONTA) == Alltrim(cCtaSub) .AND. Alltrim(FRE->FRE_TIPO) == Alltrim(cTipoTalao))'})

aAdd(aSXB,{'SA1AZ0','1','01','DB','Clientes','Clientes','Customers','SA1'})
aAdd(aSXB,{'SA1AZ0','2','01','01','Codigo+Loja','Código+Tienda','Code+Store',''})
aAdd(aSXB,{'SA1AZ0','4','01','01','Código do Cliente','Código del cliente','Customer Code','A1_COD'})
aAdd(aSXB,{'SA1AZ0','4','01','02','Loja do Cliente','Tienda del cliente','Customer Store','A1_LOJA'})
aAdd(aSXB,{'SA1AZ0','4','01','03','Nome do Cliente','Nombre del cliente','Customer Name','A1_NOME'})
aAdd(aSXB,{'SA1AZ0','5','01','','','','','SA1->A1_COD'})
aAdd(aSXB,{'SA1AZ0','5','02','','','','','SA1->A1_LOJA'})


nAtuParci := 0
cTexto += "----------  Inicia actualizacion de Consultas (SXB)  ----------"+CRLF+ CRLF

dbSelectArea("SXB")
dbSetOrder(1)
For i:= 1 To Len(aSXB)
	
		If !dbSeek(Padr(aSXB[i,1], Len(SXB->XB_ALIAS))+aSXB[i,2]+aSXB[i,3]+aSXB[i,4])
			RecLock("SXB",.T.)
			For j:=1 To Len(aSXB[i])	
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSXB[i,j])
				EndIf
			Next j
			dbCommit() 
			MsUnLock()
			cTexto += "Incluyo la Consulta "+aSXB[i,1]+CRLF
		else
		   lDif:= .f.
			For j:=1 To Len(aSXB[i])
				if alltrim(&("SXB->"+aEstrut[j])) <> alltrim(aSXB[i,j])
				    cTexto += "No Actualizó la consulta "+aSXB[i,1]+". Contenido actual de "+aEstrut[j]+ ":"+ALLTRIM(&("SXB->"+aEstrut[j]))+" Contenido recomendado :"+ ALLTRIM(aSxB[i,j])+CRLF
				    lDif:= .t.
				EndIf
				
			next
			
			if !lDif
					cTexto += "No Actualizó la consulta "+aSXB[i,1]+". Ya existe"+CRLF
			endif
		EndIf
	
	
Next i
cTexto += CRLF +"Finalizo actualizacion de Consultas (SXB)"+CRLF+ CRLF 
Return


//***********************************************Campos VALIM ALQIM BASIM ARGENTINA****************************************************************************************

Static Function ActImp()
Local aSX3      := {}
Local aEstrut   := {}
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )
Local cUsado     := ''
local cAlias    := ''
Local cAliasAtu := ''
Local cSeqAtu   := ''
Local nSeqAtu   := 0


aEstrut := { 'X3_ARQUIVO', 'X3_ORDEM'  , 'X3_CAMPO'  , 'X3_TIPO'   , 'X3_TAMANHO', 'X3_DECIMAL', ;
             'X3_TITULO' , 'X3_TITSPA' , 'X3_TITENG' , 'X3_DESCRIC', 'X3_DESCSPA', 'X3_DESCENG', ;
             'X3_PICTURE', 'X3_VALID'  , 'X3_USADO'  , 'X3_RELACAO', 'X3_F3'     , 'X3_NIVEL'  , ;
             'X3_RESERV' , 'X3_CHECK'  , 'X3_TRIGGER', 'X3_PROPRI' , 'X3_BROWSE' , 'X3_VISUAL' , ;
             'X3_CONTEXT', 'X3_OBRIGAT', 'X3_VLDUSER', 'X3_CBOX'   , 'X3_CBOXSPA', 'X3_CBOXENG', ;
             'X3_PICTVAR', 'X3_WHEN'   , 'X3_INIBRW' , 'X3_GRPSXG' , 'X3_FOLDER' , 'X3_PYME'   }

//--Pesquisa um campo existente para gravar o Reserv e o Usado
dbSelectArea("SX3")
nTamSeek  := Len( SX3->X3_CAMPO )
SX3->(DbSetOrder(2))
If SX3->(MsSeek("C7_ALQIMP1"))
	cUsado  := SX3->X3_USADO
EndIf

// ............
// Tabela SD1
// ...........


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'I4'																	, ; //X3_ORDEM
	'D1_ALQIMPB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. B'															, ; //X3_TITULO
	'Alic Imp. B'															, ; //X3_TITSPA
	'Alic Imp. B'															, ; //X3_TITENG
	'Alic Imp. B'															, ; //X3_DESCRIC
	'Alic Imp. B'															, ; //X3_DESCSPA
	'Alic Imp. B'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVB","MT100",M->D1_ALQIMPB)'							, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'I5'																	, ; //X3_ORDEM
	'D1_ALQIMPC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. C'															, ; //X3_TITULO
	'Alic Imp. C'															, ; //X3_TITSPA
	'Alic Imp. C'															, ; //X3_TITENG
	'Alic Imp. C'															, ; //X3_DESCRIC
	'Alic Imp. C'															, ; //X3_DESCSPA
	'Alic Imp. C'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVC","MT100",M->D1_ALQIMPC)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'I6'																	, ; //X3_ORDEM
	'D1_ALQIMPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. D'															, ; //X3_TITULO
	'Alic Imp. D'															, ; //X3_TITSPA
	'Alic Imp. D'															, ; //X3_TITENG
	'Alic Imp. D'															, ; //X3_DESCRIC
	'Alic Imp. D'															, ; //X3_DESCSPA
	'Alic Imp. D'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVD","MT100",M->D1_ALQIMPD)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'I7'																	, ; //X3_ORDEM
	'D1_ALQIMPF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. F'															, ; //X3_TITULO
	'Alic Imp. F'															, ; //X3_TITSPA
	'Alic Imp. F'															, ; //X3_TITENG
	'Alic Imp. F'															, ; //X3_DESCRIC
	'Alic Imp. F'															, ; //X3_DESCSPA
	'Alic Imp. F'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVF","MT100",M->D1_ALQIMPF)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'I8'																	, ; //X3_ORDEM
	'D1_ALQIMPG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. G'															, ; //X3_TITULO
	'Alic Imp. G'															, ; //X3_TITSPA
	'Alic Imp. G'															, ; //X3_TITENG
	'Alic Imp. G'															, ; //X3_DESCRIC
	'Alic Imp. G'															, ; //X3_DESCSPA
	'Alic Imp. G'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVG","MT100",M->D1_ALQIMPG)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'I9'																	, ; //X3_ORDEM
	'D1_ALQIMPJ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. J'															, ; //X3_TITULO
	'Alic Imp. J'															, ; //X3_TITSPA
	'Alic Imp. J'															, ; //X3_TITENG
	'Alic Imp. J'															, ; //X3_DESCRIC
	'Alic Imp. J'															, ; //X3_DESCSPA
	'Alic Imp. J'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVJ","MT100",M->D1_ALQIMPJ)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'J0'																	, ; //X3_ORDEM
	'D1_ALQIMPK'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. K'															, ; //X3_TITULO
	'Alic Imp. K'															, ; //X3_TITSPA
	'Alic Imp. K'															, ; //X3_TITENG
	'Alic Imp. K'															, ; //X3_DESCRIC
	'Alic Imp. K'															, ; //X3_DESCSPA
	'Alic Imp. K'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVK","MT100",M->D1_ALQIMPK)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'J1'																	, ; //X3_ORDEM
	'D1_ALQIMPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. L'															, ; //X3_TITULO
	'Alic Imp. L'															, ; //X3_TITSPA
	'Alic Imp. L'															, ; //X3_TITENG
	'Alic Imp. L'															, ; //X3_DESCRIC
	'Alic Imp. L'															, ; //X3_DESCSPA
	'Alic Imp. L'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVL","MT100",M->D1_ALQIMPL)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'J2'																	, ; //X3_ORDEM
	'D1_ALQIMPM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. M'															, ; //X3_TITULO
	'Alic Imp. M'															, ; //X3_TITSPA
	'Alic Imp. M'															, ; //X3_TITENG
	'Alic Imp. M'															, ; //X3_DESCRIC
	'Alic Imp. M'															, ; //X3_DESCSPA
	'Alic Imp. M'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVM","MT100",M->D1_ALQIMPM)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'J3'																	, ; //X3_ORDEM
	'D1_ALQIMPN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. N'															, ; //X3_TITULO
	'Alic Imp. N'															, ; //X3_TITSPA
	'Alic Imp. N'															, ; //X3_TITENG
	'Alic Imp. N'															, ; //X3_DESCRIC
	'Alic Imp. N'															, ; //X3_DESCSPA
	'Alic Imp. N'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVN","MT100",M->D1_ALQIMPN)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'J4'																	, ; //X3_ORDEM
	'D1_ALQIMPO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. O'															, ; //X3_TITULO
	'Alic Imp. O'															, ; //X3_TITSPA
	'Alic Imp. O'															, ; //X3_TITENG
	'Alic Imp. O'															, ; //X3_DESCRIC
	'Alic Imp. O'															, ; //X3_DESCSPA
	'Alic Imp. O'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVO","MT100",M->D1_ALQIMPO)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'J5'																	, ; //X3_ORDEM
	'D1_ALQIMPP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. P'															, ; //X3_TITULO
	'Alic Imp. P'															, ; //X3_TITSPA
	'Alic Imp. P'															, ; //X3_TITENG
	'Alic Imp. P'															, ; //X3_DESCRIC
	'Alic Imp. P'															, ; //X3_DESCSPA
	'Alic Imp. P'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVP","MT100",M->D1_ALQIMPP)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'J6'																	, ; //X3_ORDEM
	'D1_ALQIMPQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. Q'															, ; //X3_TITULO
	'Alic Imp. Q'															, ; //X3_TITSPA
	'Alic Imp. Q'															, ; //X3_TITENG
	'Alic Imp. Q'															, ; //X3_DESCRIC
	'Alic Imp. Q'															, ; //X3_DESCSPA
	'Alic Imp. Q'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVQ","MT100",M->D1_ALQIMPQ)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'J7'																	, ; //X3_ORDEM
	'D1_ALQIMPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. R'															, ; //X3_TITULO
	'Alic Imp. R'															, ; //X3_TITSPA
	'Alic Imp. R'															, ; //X3_TITENG
	'Alic Imp. R'															, ; //X3_DESCRIC
	'Alic Imp. R'															, ; //X3_DESCSPA
	'Alic Imp. R'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVR","MT100",M->D1_ALQIMPR)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'J8'																	, ; //X3_ORDEM
	'D1_ALQIMPS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. S'															, ; //X3_TITULO
	'Alic Imp. S'															, ; //X3_TITSPA
	'Alic Imp. S'															, ; //X3_TITENG
	'Alic Imp. S'															, ; //X3_DESCRIC
	'Alic Imp. S'															, ; //X3_DESCSPA
	'Alic Imp. S'															, ; //X3_DESCENG
	'@e 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVS","MT100",M->D1_ALQIMPS)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'J9'																	, ; //X3_ORDEM
	'D1_ALQIMPT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. T'															, ; //X3_TITULO
	'Alic Imp. T'															, ; //X3_TITSPA
	'Alic Imp. T'															, ; //X3_TITENG
	'Alic Imp. T'															, ; //X3_DESCRIC
	'Alic Imp. T'															, ; //X3_DESCSPA
	'Alic Imp. T'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVT","MT100",M->D1_ALQIMPT)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'K0'																	, ; //X3_ORDEM
	'D1_ALQIMPU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. U'															, ; //X3_TITULO
	'Alic Imp. U'															, ; //X3_TITSPA
	'Alic Imp. U'															, ; //X3_TITENG
	'Alic Imp. U'															, ; //X3_DESCRIC
	'Alic Imp. U'															, ; //X3_DESCSPA
	'Alic Imp. U'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVU","MT100",M->D1_ALQIMPU)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'K1'																	, ; //X3_ORDEM
	'D1_ALQIMPV'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. V'															, ; //X3_TITULO
	'Alic Imp. V'															, ; //X3_TITSPA
	'Alic Imp. V'															, ; //X3_TITENG
	'Alic Imp. V'															, ; //X3_DESCRIC
	'Alic Imp. V'															, ; //X3_DESCSPA
	'Alic Imp. V'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVV","MT100",M->D1_ALQIMPV)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'K2'																	, ; //X3_ORDEM
	'D1_ALQIMPW'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. W'															, ; //X3_TITULO
	'Alic Imp. W'															, ; //X3_TITSPA
	'Alic Imp. W'															, ; //X3_TITENG
	'Alic Imp. W'															, ; //X3_DESCRIC
	'Alic Imp. W'															, ; //X3_DESCSPA
	'Alic Imp. W'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVW","MT100",M->D1_ALQIMPW)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'K3'																	, ; //X3_ORDEM
	'D1_ALQIMPX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. X'															, ; //X3_TITULO
	'Alic Imp. X'															, ; //X3_TITSPA
	'Alic Imp. X'															, ; //X3_TITENG
	'Alic Imp. X'															, ; //X3_DESCRIC
	'Alic Imp. X'															, ; //X3_DESCSPA
	'Alic Imp. X'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVX","MT100",M->D1_ALQIMPX)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'K4'																	, ; //X3_ORDEM
	'D1_ALQIMPY'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. Y'															, ; //X3_TITULO
	'Alic Imp. Y'															, ; //X3_TITSPA
	'Alic Imp. Y'															, ; //X3_TITENG
	'Alic Imp. Y'															, ; //X3_DESCRIC
	'Alic Imp. Y'															, ; //X3_DESCSPA
	'Alic Imp. Y'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVY","MT100",M->D1_ALQIMPY)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'K5'																	, ; //X3_ORDEM
	'D1_ALQIMPA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. A'															, ; //X3_TITULO
	'Alic Imp. A'															, ; //X3_TITSPA
	'Alic Imp. A'															, ; //X3_TITENG
	'Alic Imp. A'															, ; //X3_DESCRIC
	'Alic Imp. A'															, ; //X3_DESCSPA
	'Alic Imp. A'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVA","MT100",M->D1_ALQIMPA)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'K6'																	, ; //X3_ORDEM
	'D1_ALQIMPE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. E'															, ; //X3_TITULO
	'Alic Imp. E'															, ; //X3_TITSPA
	'Alic Imp. E'															, ; //X3_TITENG
	'Alic Imp. E'															, ; //X3_DESCRIC
	'Alic Imp. E'															, ; //X3_DESCSPA
	'Alic Imp. E'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVE","MT100",M->D1_ALQIMPE)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'K7'																	, ; //X3_ORDEM
	'D1_BASIMPA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. A'															, ; //X3_TITULO
	'Base Imp. A'															, ; //X3_TITSPA
	'Base Imp. A'															, ; //X3_TITENG
	'Base Imp. A'															, ; //X3_DESCRIC
	'Base Imp. A'															, ; //X3_DESCSPA
	'Base Imp. A'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVA","MT100",M->D1_BASIMPA)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'K8'																	, ; //X3_ORDEM
	'D1_BASIMPB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. B'															, ; //X3_TITULO
	'Base Imp. B'															, ; //X3_TITSPA
	'Base Imp. B'															, ; //X3_TITENG
	'Base Imp. B'															, ; //X3_DESCRIC
	'Base Imp. B'															, ; //X3_DESCSPA
	'Base Imp. B'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVB","MT100",M->D1_BASIMPB)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'K9'																	, ; //X3_ORDEM
	'D1_BASIMPC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. C'															, ; //X3_TITULO
	'Base Imp. C'															, ; //X3_TITSPA
	'Base Imp. C'															, ; //X3_TITENG
	'Base Imp. C'															, ; //X3_DESCRIC
	'Base Imp. C'															, ; //X3_DESCSPA
	'Base Imp. C'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVC","MT100",M->D1_BASIMPC)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'L0'																	, ; //X3_ORDEM
	'D1_BASIMPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. D'															, ; //X3_TITULO
	'Base Imp. D'															, ; //X3_TITSPA
	'Base Imp. D'															, ; //X3_TITENG
	'Base Imp. D'															, ; //X3_DESCRIC
	'Base Imp. D'															, ; //X3_DESCSPA
	'Base Imp. D'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVD","MT100",M->D1_BASIMPD)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'L1'																	, ; //X3_ORDEM
	'D1_BASIMPE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. E'															, ; //X3_TITULO
	'Base Imp. E'															, ; //X3_TITSPA
	'Base Imp. E'															, ; //X3_TITENG
	'Base Imp. E'															, ; //X3_DESCRIC
	'Base Imp. E'															, ; //X3_DESCSPA
	'Base Imp. E'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVE","MT100",M->D1_BASIMPE)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'L2'																	, ; //X3_ORDEM
	'D1_BASIMPF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. F'															, ; //X3_TITULO
	'Base Imp. F'															, ; //X3_TITSPA
	'Base Imp. F'															, ; //X3_TITENG
	'Base Imp. F'															, ; //X3_DESCRIC
	'Base Imp. F'															, ; //X3_DESCSPA
	'Base Imp. F'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVF","MT100",M->D1_BASIMPF)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'L3'																	, ; //X3_ORDEM
	'D1_BASIMPG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. G'															, ; //X3_TITULO
	'Base Imp. G'															, ; //X3_TITSPA
	'Base Imp. G'															, ; //X3_TITENG
	'Base Imp. G'															, ; //X3_DESCRIC
	'Base Imp. G'															, ; //X3_DESCSPA
	'Base Imp. G'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVG","MT100",M->D1_BASIMPG)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'L4'																	, ; //X3_ORDEM
	'D1_BASIMPJ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. J'															, ; //X3_TITULO
	'Base Imp. J'															, ; //X3_TITSPA
	'Base Imp. J'															, ; //X3_TITENG
	'Base Imp. J'															, ; //X3_DESCRIC
	'Base Imp. J'															, ; //X3_DESCSPA
	'Base Imp. J'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVJ","MT100",M->D1_BASIMPJ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'L5'																	, ; //X3_ORDEM
	'D1_BASIMPK'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. K'															, ; //X3_TITULO
	'Base Imp. K'															, ; //X3_TITSPA
	'Base Imp. K'															, ; //X3_TITENG
	'Base Imp. K'															, ; //X3_DESCRIC
	'Base Imp. K'															, ; //X3_DESCSPA
	'Base Imp. K'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVK","MT100",M->D1_BASIMPK)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'L6'																	, ; //X3_ORDEM
	'D1_BASIMPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. L'															, ; //X3_TITULO
	'Base Imp. L'															, ; //X3_TITSPA
	'Base Imp. L'															, ; //X3_TITENG
	'Base Imp. L'															, ; //X3_DESCRIC
	'Base Imp. L'															, ; //X3_DESCSPA
	'Base Imp. L'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVL","MT100",M->D1_BASIMPL)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'L7'																	, ; //X3_ORDEM
	'D1_BASIMPM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. M'															, ; //X3_TITULO
	'Base Imp. M'															, ; //X3_TITSPA
	'Base Imp. M'															, ; //X3_TITENG
	'Base Imp. M'															, ; //X3_DESCRIC
	'Base Imp. M'															, ; //X3_DESCSPA
	'Base Imp. M'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVM","MT100",M->D1_BASIMPM)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'L8'																	, ; //X3_ORDEM
	'D1_BASIMPN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. N'															, ; //X3_TITULO
	'Base Imp. N'															, ; //X3_TITSPA
	'Base Imp. N'															, ; //X3_TITENG
	'Base Imp. N'															, ; //X3_DESCRIC
	'Base Imp. N'															, ; //X3_DESCSPA
	'Base Imp. N'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVN","MT100",M->D1_BASIMPN)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'L9'																	, ; //X3_ORDEM
	'D1_BASIMPO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. O'															, ; //X3_TITULO
	'Base Imp. O'															, ; //X3_TITSPA
	'Base Imp. O'															, ; //X3_TITENG
	'Base Imp. O'															, ; //X3_DESCRIC
	'Base Imp. O'															, ; //X3_DESCSPA
	'Base Imp. O'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVO","MT100",M->D1_BASIMPO)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'M0'																	, ; //X3_ORDEM
	'D1_BASIMPP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. P'															, ; //X3_TITULO
	'Base Imp. P'															, ; //X3_TITSPA
	'Base Imp. P'															, ; //X3_TITENG
	'Base Imp. P'															, ; //X3_DESCRIC
	'Base Imp. P'															, ; //X3_DESCSPA
	'Base Imp. P'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVP","MT100",M->D1_BASIMPP)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'M1'																	, ; //X3_ORDEM
	'D1_BASIMPQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. Q'															, ; //X3_TITULO
	'Base Imp. Q'															, ; //X3_TITSPA
	'Base Imp. Q'															, ; //X3_TITENG
	'Base Imp. Q'															, ; //X3_DESCRIC
	'Base Imp. Q'															, ; //X3_DESCSPA
	'Base Imp. Q'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVQ","MT100",M->D1_BASIMPQ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'M2'																	, ; //X3_ORDEM
	'D1_BASIMPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. R'															, ; //X3_TITULO
	'Base Imp. R'															, ; //X3_TITSPA
	'Base Imp. R'															, ; //X3_TITENG
	'Base Imp. R'															, ; //X3_DESCRIC
	'Base Imp. R'															, ; //X3_DESCSPA
	'Base Imp. R'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVR","MT100",M->D1_BASIMPR)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'M3'																	, ; //X3_ORDEM
	'D1_BASIMPS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. S'															, ; //X3_TITULO
	'Base Imp. S'															, ; //X3_TITSPA
	'Base Imp. S'															, ; //X3_TITENG
	'Base Imp. S'															, ; //X3_DESCRIC
	'Base Imp. S'															, ; //X3_DESCSPA
	'Base Imp. S'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVS","MT100",M->D1_BASIMPS)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'M4'																	, ; //X3_ORDEM
	'D1_BASIMPT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. T'															, ; //X3_TITULO
	'Base Imp. T'															, ; //X3_TITSPA
	'Base Imp. T'															, ; //X3_TITENG
	'Base Imp. T'															, ; //X3_DESCRIC
	'Base Imp. T'															, ; //X3_DESCSPA
	'Base Imp. T'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVT","MT100",M->D1_BASIMPT)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'M5'																	, ; //X3_ORDEM
	'D1_BASIMPU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. U'															, ; //X3_TITULO
	'Base Imp. U'															, ; //X3_TITSPA
	'Base Imp. U'															, ; //X3_TITENG
	'Base Imp. U'															, ; //X3_DESCRIC
	'Base Imp. U'															, ; //X3_DESCSPA
	'Base Imp. U'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVU","MT100",M->D1_BASIMPU)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'M6'																	, ; //X3_ORDEM
	'D1_BASIMPV'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. V'															, ; //X3_TITULO
	'Base Imp. V'															, ; //X3_TITSPA
	'Base Imp. V'															, ; //X3_TITENG
	'Base Imp. V'															, ; //X3_DESCRIC
	'Base Imp. V'															, ; //X3_DESCSPA
	'Base Imp. V'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVV","MT100",M->D1_BASIMPV)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'M7'																	, ; //X3_ORDEM
	'D1_BASIMPW'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. W'															, ; //X3_TITULO
	'Base Imp. W'															, ; //X3_TITSPA
	'Base Imp. W'															, ; //X3_TITENG
	'Base Imp. W'															, ; //X3_DESCRIC
	'Base Imp. W'															, ; //X3_DESCSPA
	'Base Imp. W'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVW","MT100",M->D1_BASIMPW)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'M8'																	, ; //X3_ORDEM
	'D1_BASIMPX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. X'															, ; //X3_TITULO
	'Base Imp. X'															, ; //X3_TITSPA
	'Base Imp. X'															, ; //X3_TITENG
	'Base Imp. X'															, ; //X3_DESCRIC
	'Base Imp. X'															, ; //X3_DESCSPA
	'Base Imp. X'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVX","MT100",M->D1_BASIMPX)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'M9'																	, ; //X3_ORDEM
	'D1_BASIMPY'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. Y'															, ; //X3_TITULO
	'Base Imp. Y'															, ; //X3_TITSPA
	'Base Imp. Y'															, ; //X3_TITENG
	'Base Imp. Y'															, ; //X3_DESCRIC
	'Base Imp. Y'															, ; //X3_DESCSPA
	'Base Imp. Y'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVY","MT100",M->D1_BASIMPY)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'N0'																	, ; //X3_ORDEM
	'D1_VALIMPA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. A'															, ; //X3_TITULO
	'Valor Imp. A'															, ; //X3_TITSPA
	'Valor Imp. A'															, ; //X3_TITENG
	'Valor Imp. A'															, ; //X3_DESCRIC
	'Valor Imp. A'															, ; //X3_DESCSPA
	'Valor Imp. A'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVA","MT100",M->D1_VALIMPA)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'N1'																	, ; //X3_ORDEM
	'D1_VALIMPB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. B'															, ; //X3_TITULO
	'Valor Imp. B'															, ; //X3_TITSPA
	'Valor Imp. B'															, ; //X3_TITENG
	'Valor Imp. B'															, ; //X3_DESCRIC
	'Valor Imp. B'															, ; //X3_DESCSPA
	'Valor Imp. B'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVB","MT100",M->D1_VALIMPB)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'N2'																	, ; //X3_ORDEM
	'D1_VALIMPC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. C'															, ; //X3_TITULO
	'Valor Imp. C'															, ; //X3_TITSPA
	'Valor Imp. C'															, ; //X3_TITENG
	'Valor Imp. C'															, ; //X3_DESCRIC
	'Valor Imp. C'															, ; //X3_DESCSPA
	'Valor Imp. C'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVC","MT100",M->D1_VALIMPC)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'N3'																	, ; //X3_ORDEM
	'D1_VALIMPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. D'															, ; //X3_TITULO
	'Valor Imp. D'															, ; //X3_TITSPA
	'Valor Imp. D'															, ; //X3_TITENG
	'Valor Imp. D'															, ; //X3_DESCRIC
	'Valor Imp. D'															, ; //X3_DESCSPA
	'Valor Imp. D'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVD","MT100",M->D1_VALIMPD)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'N4'																	, ; //X3_ORDEM
	'D1_VALIMPE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. E'															, ; //X3_TITULO
	'Valor Imp. E'															, ; //X3_TITSPA
	'Valor Imp. E'															, ; //X3_TITENG
	'Valor Imp. E'															, ; //X3_DESCRIC
	'Valor Imp. E'															, ; //X3_DESCSPA
	'Valor Imp. E'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVE","MT100",M->D1_VALIMPE)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'N5'																	, ; //X3_ORDEM
	'D1_VALIMPF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. F'															, ; //X3_TITULO
	'Valor Imp. F'															, ; //X3_TITSPA
	'Valor Imp. F'															, ; //X3_TITENG
	'Valor Imp. F'															, ; //X3_DESCRIC
	'Valor Imp. F'															, ; //X3_DESCSPA
	'Valor Imp. F'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVF","MT100",M->D1_VALIMPF)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'N6'																	, ; //X3_ORDEM
	'D1_VALIMPG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. G'															, ; //X3_TITULO
	'Valor Imp. G'															, ; //X3_TITSPA
	'Valor Imp. G'															, ; //X3_TITENG
	'Valor Imp. G'															, ; //X3_DESCRIC
	'Valor Imp. G'															, ; //X3_DESCSPA
	'Valor Imp. G'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVG","MT100",M->D1_VALIMPG)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'N7'																	, ; //X3_ORDEM
	'D1_VALIMPJ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. J'															, ; //X3_TITULO
	'Valor Imp. J'															, ; //X3_TITSPA
	'Valor Imp. J'															, ; //X3_TITENG
	'Valor Imp. J'															, ; //X3_DESCRIC
	'Valor Imp. J'															, ; //X3_DESCSPA
	'Valor Imp. J'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVJ","MT100",M->D1_VALIMPJ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'N8'																	, ; //X3_ORDEM
	'D1_VALIMPK'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. K'															, ; //X3_TITULO
	'Valor Imp. K'															, ; //X3_TITSPA
	'Valor Imp. K'															, ; //X3_TITENG
	'Valor Imp. K'															, ; //X3_DESCRIC
	'Valor Imp. K'															, ; //X3_DESCSPA
	'Valor Imp. K'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVK","MT100",M->D1_VALIMPK)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'N9'																	, ; //X3_ORDEM
	'D1_VALIMPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. L'															, ; //X3_TITULO
	'Valor Imp. L'															, ; //X3_TITSPA
	'Valor Imp. L'															, ; //X3_TITENG
	'Valor Imp. L'															, ; //X3_DESCRIC
	'Valor Imp. L'															, ; //X3_DESCSPA
	'Valor Imp. L'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVL","MT100",M->D1_VALIMPL)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'O0'																	, ; //X3_ORDEM
	'D1_VALIMPM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. M'															, ; //X3_TITULO
	'Valor Imp. M'															, ; //X3_TITSPA
	'Valor Imp. M'															, ; //X3_TITENG
	'Valor Imp. M'															, ; //X3_DESCRIC
	'Valor Imp. M'															, ; //X3_DESCSPA
	'Valor Imp. M'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVM","MT100",M->D1_VALIMPM)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'O1'																	, ; //X3_ORDEM
	'D1_VALIMPN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. N'															, ; //X3_TITULO
	'Valor Imp. N'															, ; //X3_TITSPA
	'Valor Imp. N'															, ; //X3_TITENG
	'Valor Imp. N'															, ; //X3_DESCRIC
	'Valor Imp. N'															, ; //X3_DESCSPA
	'Valor Imp. N'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVN","MT100",M->D1_VALIMPN)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'O2'																	, ; //X3_ORDEM
	'D1_VALIMPO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. O'															, ; //X3_TITULO
	'Valor Imp. O'															, ; //X3_TITSPA
	'Valor Imp. O'															, ; //X3_TITENG
	'Valor Imp. O'															, ; //X3_DESCRIC
	'Valor Imp. O'															, ; //X3_DESCSPA
	'Valor Imp. O'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVO","MT100",M->D1_VALIMPO)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'O3'																	, ; //X3_ORDEM
	'D1_VALIMPP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. P'															, ; //X3_TITULO
	'Valor Imp. P'															, ; //X3_TITSPA
	'Valor Imp. P'															, ; //X3_TITENG
	'Valor Imp. P'															, ; //X3_DESCRIC
	'Valor Imp. P'															, ; //X3_DESCSPA
	'Valor Imp. P'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVP","MT100",M->D1_VALIMPP)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'O4'																	, ; //X3_ORDEM
	'D1_VALIMPQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. Q'															, ; //X3_TITULO
	'Valor Imp. Q'															, ; //X3_TITSPA
	'Valor Imp. Q'															, ; //X3_TITENG
	'Valor Imp. Q'															, ; //X3_DESCRIC
	'Valor Imp. Q'															, ; //X3_DESCSPA
	'Valor Imp. Q'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVQ","MT100",M->D1_VALIMPQ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'O5'																	, ; //X3_ORDEM
	'D1_VALIMPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. R'															, ; //X3_TITULO
	'Valor Imp. R'															, ; //X3_TITSPA
	'Valor Imp. R'															, ; //X3_TITENG
	'Valor Imp. R'															, ; //X3_DESCRIC
	'Valor Imp. R'															, ; //X3_DESCSPA
	'Valor Imp. R'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVR","MT100",M->D1_VALIMPR)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'O6'																	, ; //X3_ORDEM
	'D1_VALIMPS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. S'															, ; //X3_TITULO
	'Valor Imp. S'															, ; //X3_TITSPA
	'Valor Imp. S'															, ; //X3_TITENG
	'Valor Imp. S'															, ; //X3_DESCRIC
	'Valor Imp. S'															, ; //X3_DESCSPA
	'Valor Imp. S'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVS","MT100",M->D1_VALIMPS)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'O7'																	, ; //X3_ORDEM
	'D1_VALIMPT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. T'															, ; //X3_TITULO
	'Valor Imp. T'															, ; //X3_TITSPA
	'Valor Imp. T'															, ; //X3_TITENG
	'Valor Imp. T'															, ; //X3_DESCRIC
	'Valor Imp. T'															, ; //X3_DESCSPA
	'Valor Imp. T'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVT","MT100",M->D1_VALIMPT)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'O8'																	, ; //X3_ORDEM
	'D1_VALIMPU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. U'															, ; //X3_TITULO
	'Valor Imp. U'															, ; //X3_TITSPA
	'Valor Imp. U'															, ; //X3_TITENG
	'Valor Imp. U'															, ; //X3_DESCRIC
	'Valor Imp. U'															, ; //X3_DESCSPA
	'Valor Imp. U'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVU","MT100",M->D1_VALIMPU)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'O9'																	, ; //X3_ORDEM
	'D1_VALIMPV'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. V'															, ; //X3_TITULO
	'Valor Imp. V'															, ; //X3_TITSPA
	'Valor Imp. V'															, ; //X3_TITENG
	'Valor Imp. V'															, ; //X3_DESCRIC
	'Valor Imp. V'															, ; //X3_DESCSPA
	'Valor Imp. V'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVV","MT100",M->D1_VALIMPV)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'P0'																	, ; //X3_ORDEM
	'D1_VALIMPW'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. W'															, ; //X3_TITULO
	'Valor Imp. W'															, ; //X3_TITSPA
	'Valor Imp. W'															, ; //X3_TITENG
	'Valor Imp. W'															, ; //X3_DESCRIC
	'Valor Imp. W'															, ; //X3_DESCSPA
	'Valor Imp. W'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVW","MT100",M->D1_VALIMPW)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'P1'																	, ; //X3_ORDEM
	'D1_VALIMPX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. X'															, ; //X3_TITULO
	'Valor Imp. X'															, ; //X3_TITSPA
	'Valor Imp. X'															, ; //X3_TITENG
	'Valor Imp. X'															, ; //X3_DESCRIC
	'Valor Imp. X'															, ; //X3_DESCSPA
	'Valor Imp. X'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVX","MT100",M->D1_VALIMPX)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD1'																	, ; //X3_ARQUIVO
	'P2'																	, ; //X3_ORDEM
	'D1_VALIMPY'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. Y'															, ; //X3_TITULO
	'Valor Imp. Y'															, ; //X3_TITSPA
	'Valor Imp. Y'															, ; //X3_TITENG
	'Valor Imp. Y'															, ; //X3_DESCRIC
	'Valor Imp. Y'															, ; //X3_DESCSPA
	'Valor Imp. Y'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVY","MT100",M->D1_VALIMPY)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


// ..........
// Tabela SD2
// ..........
aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'H7'																	, ; //X3_ORDEM
	'D2_VALIMPA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. A'															, ; //X3_TITULO
	'Valor Imp. A'															, ; //X3_TITSPA
	'Valor Imp. A'															, ; //X3_TITENG
	'Valor Imp. A'															, ; //X3_DESCRIC
	'Valor Imp. A'															, ; //X3_DESCSPA
	'Valor Imp. A'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVA","MT100",M->D2_VALIMPA)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'H8'																	, ; //X3_ORDEM
	'D2_ALQIMPA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. A'															, ; //X3_TITULO
	'Alic Imp. A'															, ; //X3_TITSPA
	'Alic Imp. A'															, ; //X3_TITENG
	'Alic Imp. A'															, ; //X3_DESCRIC
	'Alic Imp. A'															, ; //X3_DESCSPA
	'Alic Imp. A'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVA","MT100",M->D2_ALQIMPA)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'H9'																	, ; //X3_ORDEM
	'D2_BASIMPA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. A'															, ; //X3_TITULO
	'Base Imp. A'															, ; //X3_TITSPA
	'Base Imp. A'															, ; //X3_TITENG
	'Base Imp. A'															, ; //X3_DESCRIC
	'Base Imp. A'															, ; //X3_DESCSPA
	'Base Imp. A'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVA","MT100",M->D2_BASIMPA)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'I0'																	, ; //X3_ORDEM
	'D2_VALIMPB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. B'															, ; //X3_TITULO
	'Valor Imp. B'															, ; //X3_TITSPA
	'Valor Imp. B'															, ; //X3_TITENG
	'Valor Imp. B'															, ; //X3_DESCRIC
	'Valor Imp. B'															, ; //X3_DESCSPA
	'Valor Imp. B'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVB","MT100",M->D2_VALIMPB)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'I1'																	, ; //X3_ORDEM
	'D2_ALQIMPB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. B'															, ; //X3_TITULO
	'Alic Imp. B'															, ; //X3_TITSPA
	'Alic Imp. B'															, ; //X3_TITENG
	'Alic Imp. B'															, ; //X3_DESCRIC
	'Alic Imp. B'															, ; //X3_DESCSPA
	'Alic Imp. B'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVB","MT100",M->D2_ALQIMPB)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'I2'																	, ; //X3_ORDEM
	'D2_BASIMPB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. B'															, ; //X3_TITULO
	'Base Imp. B'															, ; //X3_TITSPA
	'Base Imp. B'															, ; //X3_TITENG
	'Base Imp. B'															, ; //X3_DESCRIC
	'Base Imp. B'															, ; //X3_DESCSPA
	'Base Imp. B'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVB","MT100",M->D2_BASIMPB)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'I3'																	, ; //X3_ORDEM
	'D2_VALIMPC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. C'															, ; //X3_TITULO
	'Valor Imp. C'															, ; //X3_TITSPA
	'Valor Imp. C'															, ; //X3_TITENG
	'Valor Imp. C'															, ; //X3_DESCRIC
	'Valor Imp. C'															, ; //X3_DESCSPA
	'Valor Imp. C'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVC","MT100",M->D2_VALIMPC)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'I4'																	, ; //X3_ORDEM
	'D2_ALQIMPC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. C'															, ; //X3_TITULO
	'Alic Imp. C'															, ; //X3_TITSPA
	'Alic Imp. C'															, ; //X3_TITENG
	'Alic Imp. C'															, ; //X3_DESCRIC
	'Alic Imp. C'															, ; //X3_DESCSPA
	'Alic Imp. C'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVC","MT100",M->D2_ALQIMPC)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'I5'																	, ; //X3_ORDEM
	'D2_BASIMPC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. C'															, ; //X3_TITULO
	'Base Imp. C'															, ; //X3_TITSPA
	'Base Imp. C'															, ; //X3_TITENG
	'Base Imp. C'															, ; //X3_DESCRIC
	'Base Imp. C'															, ; //X3_DESCSPA
	'Base Imp. C'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVC","MT100",M->D2_BASIMPC)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'I6'																	, ; //X3_ORDEM
	'D2_VALIMPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. D'															, ; //X3_TITULO
	'Valor Imp. D'															, ; //X3_TITSPA
	'Valor Imp. D'															, ; //X3_TITENG
	'Valor Imp. D'															, ; //X3_DESCRIC
	'Valor Imp. D'															, ; //X3_DESCSPA
	'Valor Imp. D'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVD","MT100",M->D2_VALIMPD)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'I7'																	, ; //X3_ORDEM
	'D2_ALQIMPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. D'															, ; //X3_TITULO
	'Alic Imp. D'															, ; //X3_TITSPA
	'Alic Imp. D'															, ; //X3_TITENG
	'Alic Imp. D'															, ; //X3_DESCRIC
	'Alic Imp. D'															, ; //X3_DESCSPA
	'Alic Imp. D'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVD","MT100",M->D2_ALQIMPD)'							, ; //X3_VALID
	cUsado				, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'I8'																	, ; //X3_ORDEM
	'D2_BASIMPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. D'															, ; //X3_TITULO
	'Base Imp. D'															, ; //X3_TITSPA
	'Base Imp. D'															, ; //X3_TITENG
	'Base Imp. D'															, ; //X3_DESCRIC
	'Base Imp. D'															, ; //X3_DESCSPA
	'Base Imp. D'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVD","MT100",M->D2_BASIMPD)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'I9'																	, ; //X3_ORDEM
	'D2_VALIMPE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. E'															, ; //X3_TITULO
	'Valor Imp. E'															, ; //X3_TITSPA
	'Valor Imp. E'															, ; //X3_TITENG
	'Valor Imp. E'															, ; //X3_DESCRIC
	'Valor Imp. E'															, ; //X3_DESCSPA
	'Valor Imp. E'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVE","MT100",M->D2_VALIMPE)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'J0'																	, ; //X3_ORDEM
	'D2_ALQIMPE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. E'															, ; //X3_TITULO
	'Alic Imp. E'															, ; //X3_TITSPA
	'Alic Imp. E'															, ; //X3_TITENG
	'Alic Imp. E'															, ; //X3_DESCRIC
	'Alic Imp. E'															, ; //X3_DESCSPA
	'Alic Imp. E'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVE","MT100",M->D2_ALQIMPE)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'J1'																	, ; //X3_ORDEM
	'D2_BASIMPE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. E'															, ; //X3_TITULO
	'Base Imp. E'															, ; //X3_TITSPA
	'Base Imp. E'															, ; //X3_TITENG
	'Base Imp. E'															, ; //X3_DESCRIC
	'Base Imp. E'															, ; //X3_DESCSPA
	'Base Imp. E'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVE","MT100",M->D2_BASIMPE)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'J2'																	, ; //X3_ORDEM
	'D2_VALIMPF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. F'															, ; //X3_TITULO
	'Valor Imp. F'															, ; //X3_TITSPA
	'Valor Imp. F'															, ; //X3_TITENG
	'Valor Imp. F'															, ; //X3_DESCRIC
	'Valor Imp. F'															, ; //X3_DESCSPA
	'Valor Imp. F'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVF","MT100",M->D2_VALIMPF)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'J3'																	, ; //X3_ORDEM
	'D2_ALQIMPF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. F'															, ; //X3_TITULO
	'Alic Imp. F'															, ; //X3_TITSPA
	'Alic Imp. F'															, ; //X3_TITENG
	'Alic Imp. F'															, ; //X3_DESCRIC
	'Alic Imp. F'															, ; //X3_DESCSPA
	'Alic Imp. F'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVF","MT100",M->D2_ALQIMPF)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'J4'																	, ; //X3_ORDEM
	'D2_BASIMPF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. F'															, ; //X3_TITULO
	'Base Imp. F'															, ; //X3_TITSPA
	'Base Imp. F'															, ; //X3_TITENG
	'Base Imp. F'															, ; //X3_DESCRIC
	'Base Imp. F'															, ; //X3_DESCSPA
	'Base Imp. F'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVF","MT100",M->D2_BASIMPF)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'J5'																	, ; //X3_ORDEM
	'D2_VALIMPG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. G'															, ; //X3_TITULO
	'Valor Imp. G'															, ; //X3_TITSPA
	'Valor Imp. G'															, ; //X3_TITENG
	'Valor Imp. G'															, ; //X3_DESCRIC
	'Valor Imp. G'															, ; //X3_DESCSPA
	'Valor Imp. G'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVG","MT100",M->D2_VALIMPG)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'J6'																	, ; //X3_ORDEM
	'D2_ALQIMPG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. G'															, ; //X3_TITULO
	'Alic Imp. G'															, ; //X3_TITSPA
	'Alic Imp. G'															, ; //X3_TITENG
	'Alic Imp. G'															, ; //X3_DESCRIC
	'Alic Imp. G'															, ; //X3_DESCSPA
	'Alic Imp. G'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVG","MT100",M->D2_ALQIMPG)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'J7'																	, ; //X3_ORDEM
	'D2_BASIMPG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. G'															, ; //X3_TITULO
	'Base Imp. G'															, ; //X3_TITSPA
	'Base Imp. G'															, ; //X3_TITENG
	'Base Imp. G'															, ; //X3_DESCRIC
	'Base Imp. G'															, ; //X3_DESCSPA
	'Base Imp. G'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVG","MT100",M->D2_BASIMPG)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'J8'																	, ; //X3_ORDEM
	'D2_VALIMPJ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. J'															, ; //X3_TITULO
	'Valor Imp. J'															, ; //X3_TITSPA
	'Valor Imp. J'															, ; //X3_TITENG
	'Valor Imp. J'															, ; //X3_DESCRIC
	'Valor Imp. J'															, ; //X3_DESCSPA
	'Valor Imp. J'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVJ","MT100",M->D2_VALIMPJ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'J9'																	, ; //X3_ORDEM
	'D2_ALQIMPJ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. J'															, ; //X3_TITULO
	'Alic Imp. J'															, ; //X3_TITSPA
	'Alic Imp. J'															, ; //X3_TITENG
	'Alic Imp. J'															, ; //X3_DESCRIC
	'Alic Imp. J'															, ; //X3_DESCSPA
	'Alic Imp. J'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVJ","MT100",M->D2_ALQIMPJ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'K0'																	, ; //X3_ORDEM
	'D2_BASIMPJ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. J'															, ; //X3_TITULO
	'Base Imp. J'															, ; //X3_TITSPA
	'Base Imp. J'															, ; //X3_TITENG
	'Base Imp. J'															, ; //X3_DESCRIC
	'Base Imp. J'															, ; //X3_DESCSPA
	'Base Imp. J'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVJ","MT100",M->D2_BASIMPJ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'K1'																	, ; //X3_ORDEM
	'D2_VALIMPK'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. K'															, ; //X3_TITULO
	'Valor Imp. K'															, ; //X3_TITSPA
	'Valor Imp. K'															, ; //X3_TITENG
	'Valor Imp. K'															, ; //X3_DESCRIC
	'Valor Imp. K'															, ; //X3_DESCSPA
	'Valor Imp. K'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVK","MT100",M->D2_VALIMPK)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'K2'																	, ; //X3_ORDEM
	'D2_ALQIMPK'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. K'															, ; //X3_TITULO
	'Alic Imp. K'															, ; //X3_TITSPA
	'Alic Imp. K'															, ; //X3_TITENG
	'Alic Imp. K'															, ; //X3_DESCRIC
	'Alic Imp. K'															, ; //X3_DESCSPA
	'Alic Imp. K'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVK","MT100",M->D2_ALQIMPK)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'K3'																	, ; //X3_ORDEM
	'D2_BASIMPK'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. K'															, ; //X3_TITULO
	'Base Imp. K'															, ; //X3_TITSPA
	'Base Imp. K'															, ; //X3_TITENG
	'Base Imp. K'															, ; //X3_DESCRIC
	'Base Imp. K'															, ; //X3_DESCSPA
	'Base Imp. K'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVK","MT100",M->D2_BASIMPK)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'K4'																	, ; //X3_ORDEM
	'D2_VALIMPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. L'															, ; //X3_TITULO
	'Valor Imp. L'															, ; //X3_TITSPA
	'Valor Imp. L'															, ; //X3_TITENG
	'Valor Imp. L'															, ; //X3_DESCRIC
	'Valor Imp. L'															, ; //X3_DESCSPA
	'Valor Imp. L'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVL","MT100",M->D2_VALIMPL)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'K5'																	, ; //X3_ORDEM
	'D2_ALQIMPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. L'															, ; //X3_TITULO
	'Alic Imp. L'															, ; //X3_TITSPA
	'Alic Imp. L'															, ; //X3_TITENG
	'Alic Imp. L'															, ; //X3_DESCRIC
	'Alic Imp. L'															, ; //X3_DESCSPA
	'Alic Imp. L'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVL","MT100",M->D2_ALQIMPL)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'K6'																	, ; //X3_ORDEM
	'D2_BASIMPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. L'															, ; //X3_TITULO
	'Base Imp. L'															, ; //X3_TITSPA
	'Base Imp. L'															, ; //X3_TITENG
	'Base Imp. L'															, ; //X3_DESCRIC
	'Base Imp. L'															, ; //X3_DESCSPA
	'Base Imp. L'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVL","MT100",M->D2_BASIMPL)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'K7'																	, ; //X3_ORDEM
	'D2_VALIMPM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. M'															, ; //X3_TITULO
	'Valor Imp. M'															, ; //X3_TITSPA
	'Valor Imp. M'															, ; //X3_TITENG
	'Valor Imp. M'															, ; //X3_DESCRIC
	'Valor Imp. M'															, ; //X3_DESCSPA
	'Valor Imp. M'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVM","MT100",M->D2_VALIMPM)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'K8'																	, ; //X3_ORDEM
	'D2_ALQIMPM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. M'															, ; //X3_TITULO
	'Alic Imp. M'															, ; //X3_TITSPA
	'Alic Imp. M'															, ; //X3_TITENG
	'Alic Imp. M'															, ; //X3_DESCRIC
	'Alic Imp. M'															, ; //X3_DESCSPA
	'Alic Imp. M'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVM","MT100",M->D2_ALQIMPM)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'K9'																	, ; //X3_ORDEM
	'D2_BASIMPM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. M'															, ; //X3_TITULO
	'Base Imp. M'															, ; //X3_TITSPA
	'Base Imp. M'															, ; //X3_TITENG
	'Base Imp. M'															, ; //X3_DESCRIC
	'Base Imp. M'															, ; //X3_DESCSPA
	'Base Imp. M'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVM","MT100",M->D2_BASIMPM)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'L0'																	, ; //X3_ORDEM
	'D2_VALIMPN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. N'															, ; //X3_TITULO
	'Valor Imp. N'															, ; //X3_TITSPA
	'Valor Imp. N'															, ; //X3_TITENG
	'Valor Imp. N'															, ; //X3_DESCRIC
	'Valor Imp. N'															, ; //X3_DESCSPA
	'Valor Imp. N'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVN","MT100",M->D2_VALIMPN)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'L1'																	, ; //X3_ORDEM
	'D2_ALQIMPN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. N'															, ; //X3_TITULO
	'Alic Imp. N'															, ; //X3_TITSPA
	'Alic Imp. N'															, ; //X3_TITENG
	'Alic Imp. N'															, ; //X3_DESCRIC
	'Alic Imp. N'															, ; //X3_DESCSPA
	'Alic Imp. N'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVN","MT100",M->D2_ALQIMPN)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'L2'																	, ; //X3_ORDEM
	'D2_BASIMPN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. N'															, ; //X3_TITULO
	'Base Imp. N'															, ; //X3_TITSPA
	'Base Imp. N'															, ; //X3_TITENG
	'Base Imp. N'															, ; //X3_DESCRIC
	'Base Imp. N'															, ; //X3_DESCSPA
	'Base Imp. N'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVN","MT100",M->D2_BASIMPN)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'L3'																	, ; //X3_ORDEM
	'D2_VALIMPO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. O'															, ; //X3_TITULO
	'Valor Imp. O'															, ; //X3_TITSPA
	'Valor Imp. O'															, ; //X3_TITENG
	'Valor Imp. O'															, ; //X3_DESCRIC
	'Valor Imp. O'															, ; //X3_DESCSPA
	'Valor Imp. O'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVO","MT100",M->D2_VALIMPO)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'L4'																	, ; //X3_ORDEM
	'D2_ALQIMPO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. O'															, ; //X3_TITULO
	'Alic Imp. O'															, ; //X3_TITSPA
	'Alic Imp. O'															, ; //X3_TITENG
	'Alic Imp. O'															, ; //X3_DESCRIC
	'Alic Imp. O'															, ; //X3_DESCSPA
	'Alic Imp. O'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVO","MT100",M->D2_ALQIMPO)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'L5'																	, ; //X3_ORDEM
	'D2_BASIMPO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. O'															, ; //X3_TITULO
	'Base Imp. O'															, ; //X3_TITSPA
	'Base Imp. O'															, ; //X3_TITENG
	'Base Imp. O'															, ; //X3_DESCRIC
	'Base Imp. O'															, ; //X3_DESCSPA
	'Base Imp. O'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVO","MT100",M->D2_BASIMPO)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'L6'																	, ; //X3_ORDEM
	'D2_VALIMPP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. P'															, ; //X3_TITULO
	'Valor Imp. P'															, ; //X3_TITSPA
	'Valor Imp. P'															, ; //X3_TITENG
	'Valor Imp. P'															, ; //X3_DESCRIC
	'Valor Imp. P'															, ; //X3_DESCSPA
	'Valor Imp. P'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVP","MT100",M->D2_VALIMPP)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'L7'																	, ; //X3_ORDEM
	'D2_ALQIMPP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. P'															, ; //X3_TITULO
	'Alic Imp. P'															, ; //X3_TITSPA
	'Alic Imp. P'															, ; //X3_TITENG
	'Alic Imp. P'															, ; //X3_DESCRIC
	'Alic Imp. P'															, ; //X3_DESCSPA
	'Alic Imp. P'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVP","MT100",M->D2_ALQIMPP)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'L8'																	, ; //X3_ORDEM
	'D2_BASIMPP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. P'															, ; //X3_TITULO
	'Base Imp. P'															, ; //X3_TITSPA
	'Base Imp. P'															, ; //X3_TITENG
	'Base Imp. P'															, ; //X3_DESCRIC
	'Base Imp. P'															, ; //X3_DESCSPA
	'Base Imp. P'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVP","MT100",M->D2_BASIMPP)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'L9'																	, ; //X3_ORDEM
	'D2_VALIMPQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. Q'															, ; //X3_TITULO
	'Valor Imp. Q'															, ; //X3_TITSPA
	'Valor Imp. Q'															, ; //X3_TITENG
	'Valor Imp. Q'															, ; //X3_DESCRIC
	'Valor Imp. Q'															, ; //X3_DESCSPA
	'Valor Imp. Q'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVQ","MT100",M->D2_VALIMPQ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'M0'																	, ; //X3_ORDEM
	'D2_ALQIMPQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. Q'															, ; //X3_TITULO
	'Alic Imp. Q'															, ; //X3_TITSPA
	'Alic Imp. Q'															, ; //X3_TITENG
	'Alic Imp. Q'															, ; //X3_DESCRIC
	'Alic Imp. Q'															, ; //X3_DESCSPA
	'Alic Imp. Q'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVQ","MT100",M->D2_ALQIMPQ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'M1'																	, ; //X3_ORDEM
	'D2_BASIMPQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. Q'															, ; //X3_TITULO
	'Base Imp. Q'															, ; //X3_TITSPA
	'Base Imp. Q'															, ; //X3_TITENG
	'Base Imp. Q'															, ; //X3_DESCRIC
	'Base Imp. Q'															, ; //X3_DESCSPA
	'Base Imp. Q'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVQ","MT100",M->D2_BASIMPQ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'M2'																	, ; //X3_ORDEM
	'D2_VALIMPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. R'															, ; //X3_TITULO
	'Valor Imp. R'															, ; //X3_TITSPA
	'Valor Imp. R'															, ; //X3_TITENG
	'Valor Imp. R'															, ; //X3_DESCRIC
	'Valor Imp. R'															, ; //X3_DESCSPA
	'Valor Imp. R'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVR","MT100",M->D2_VALIMPR)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'M3'																	, ; //X3_ORDEM
	'D2_ALQIMPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. R'															, ; //X3_TITULO
	'Alic Imp. R'															, ; //X3_TITSPA
	'Alic Imp. R'															, ; //X3_TITENG
	'Alic Imp. R'															, ; //X3_DESCRIC
	'Alic Imp. R'															, ; //X3_DESCSPA
	'Alic Imp. R'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVR","MT100",M->D2_ALQIMPR)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'M4'																	, ; //X3_ORDEM
	'D2_BASIMPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. R'															, ; //X3_TITULO
	'Base Imp. R'															, ; //X3_TITSPA
	'Base Imp. R'															, ; //X3_TITENG
	'Base Imp. R'															, ; //X3_DESCRIC
	'Base Imp. R'															, ; //X3_DESCSPA
	'Base Imp. R'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVR","MT100",M->D2_BASIMPR)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'M5'																	, ; //X3_ORDEM
	'D2_VALIMPS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. S'															, ; //X3_TITULO
	'Valor Imp. S'															, ; //X3_TITSPA
	'Valor Imp. S'															, ; //X3_TITENG
	'Valor Imp. S'															, ; //X3_DESCRIC
	'Valor Imp. S'															, ; //X3_DESCSPA
	'Valor Imp. S'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVS","MT100",M->D2_VALIMPS)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'M6'																	, ; //X3_ORDEM
	'D2_ALQIMPS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. S'															, ; //X3_TITULO
	'Alic Imp. S'															, ; //X3_TITSPA
	'Alic Imp. S'															, ; //X3_TITENG
	'Alic Imp. S'															, ; //X3_DESCRIC
	'Alic Imp. S'															, ; //X3_DESCSPA
	'Alic Imp. S'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVS","MT100",M->D2_ALQIMPS)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'M7'																	, ; //X3_ORDEM
	'D2_BASIMPS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. S'															, ; //X3_TITULO
	'Base Imp. S'															, ; //X3_TITSPA
	'Base Imp. S'															, ; //X3_TITENG
	'Base Imp. S'															, ; //X3_DESCRIC
	'Base Imp. S'															, ; //X3_DESCSPA
	'Base Imp. S'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVS","MT100",M->D2_BASIMPS)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'M8'																	, ; //X3_ORDEM
	'D2_VALIMPT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. T'															, ; //X3_TITULO
	'Valor Imp. T'															, ; //X3_TITSPA
	'Valor Imp. T'															, ; //X3_TITENG
	'Valor Imp. T'															, ; //X3_DESCRIC
	'Valor Imp. T'															, ; //X3_DESCSPA
	'Valor Imp. T'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVT","MT100",M->D2_VALIMPT)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'M9'																	, ; //X3_ORDEM
	'D2_ALQIMPT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. T'															, ; //X3_TITULO
	'Alic Imp. T'															, ; //X3_TITSPA
	'Alic Imp. T'															, ; //X3_TITENG
	'Alic Imp. T'															, ; //X3_DESCRIC
	'Alic Imp. T'															, ; //X3_DESCSPA
	'Alic Imp. T'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVT","MT100",M->D2_ALQIMPT)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'N0'																	, ; //X3_ORDEM
	'D2_BASIMPT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. T'															, ; //X3_TITULO
	'Base Imp. T'															, ; //X3_TITSPA
	'Base Imp. T'															, ; //X3_TITENG
	'Base Imp. T'															, ; //X3_DESCRIC
	'Base Imp. T'															, ; //X3_DESCSPA
	'Base Imp. T'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVT","MT100",M->D2_BASIMPT)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'N1'																	, ; //X3_ORDEM
	'D2_VALIMPU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. U'															, ; //X3_TITULO
	'Valor Imp. U'															, ; //X3_TITSPA
	'Valor Imp. U'															, ; //X3_TITENG
	'Valor Imp. U'															, ; //X3_DESCRIC
	'Valor Imp. U'															, ; //X3_DESCSPA
	'Valor Imp. U'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVU","MT100",M->D2_VALIMPU)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'N2'																	, ; //X3_ORDEM
	'D2_ALQIMPU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. U'															, ; //X3_TITULO
	'Alic Imp. U'															, ; //X3_TITSPA
	'Alic Imp. U'															, ; //X3_TITENG
	'Alic Imp. U'															, ; //X3_DESCRIC
	'Alic Imp. U'															, ; //X3_DESCSPA
	'Alic Imp. U'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVU","MT100",M->D2_ALQIMPU)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'N3'																	, ; //X3_ORDEM
	'D2_BASIMPU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. U'															, ; //X3_TITULO
	'Base Imp. U'															, ; //X3_TITSPA
	'Base Imp. U'															, ; //X3_TITENG
	'Base Imp. U'															, ; //X3_DESCRIC
	'Base Imp. U'															, ; //X3_DESCSPA
	'Base Imp. U'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVU","MT100",M->D2_BASIMPU)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'N4'																	, ; //X3_ORDEM
	'D2_VALIMPV'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. V'															, ; //X3_TITULO
	'Valor Imp. V'															, ; //X3_TITSPA
	'Valor Imp. V'															, ; //X3_TITENG
	'Valor Imp. V'															, ; //X3_DESCRIC
	'Valor Imp. V'															, ; //X3_DESCSPA
	'Valor Imp. V'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVV","MT100",M->D2_VALIMPV)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'N5'																	, ; //X3_ORDEM
	'D2_ALQIMPV'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. V'															, ; //X3_TITULO
	'Alic Imp. V'															, ; //X3_TITSPA
	'Alic Imp. V'															, ; //X3_TITENG
	'Alic Imp. V'															, ; //X3_DESCRIC
	'Alic Imp. V'															, ; //X3_DESCSPA
	'Alic Imp. V'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVV","MT100",M->D2_ALQIMPV)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'N6'																	, ; //X3_ORDEM
	'D2_BASIMPV'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. V'															, ; //X3_TITULO
	'Base Imp. V'															, ; //X3_TITSPA
	'Base Imp. V'															, ; //X3_TITENG
	'Base Imp. V'															, ; //X3_DESCRIC
	'Base Imp. V'															, ; //X3_DESCSPA
	'Base Imp. V'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVV","MT100",M->D2_BASIMPV)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'N7'																	, ; //X3_ORDEM
	'D2_VALIMPW'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. W'															, ; //X3_TITULO
	'Valor Imp. W'															, ; //X3_TITSPA
	'Valor Imp. W'															, ; //X3_TITENG
	'Valor Imp. W'															, ; //X3_DESCRIC
	'Valor Imp. W'															, ; //X3_DESCSPA
	'Valor Imp. W'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVW","MT100",M->D2_VALIMPW)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'N8'																	, ; //X3_ORDEM
	'D2_BASIMPW'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. W'															, ; //X3_TITULO
	'Base Imp. W'															, ; //X3_TITSPA
	'Base Imp. W'															, ; //X3_TITENG
	'Base Imp. W'															, ; //X3_DESCRIC
	'Base Imp. W'															, ; //X3_DESCSPA
	'Base Imp. W'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVW","MT100",M->D2_BASIMPW)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'N9'																	, ; //X3_ORDEM
	'D2_ALQIMPW'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. W'															, ; //X3_TITULO
	'Alic Imp. W'															, ; //X3_TITSPA
	'Alic Imp. W'															, ; //X3_TITENG
	'Alic Imp. W'															, ; //X3_DESCRIC
	'Alic Imp. W'															, ; //X3_DESCSPA
	'Alic Imp. W'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVW","MT100",M->D2_ALQIMPW)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'O0'																	, ; //X3_ORDEM
	'D2_VALIMPX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. X'															, ; //X3_TITULO
	'Valor Imp. X'															, ; //X3_TITSPA
	'Valor Imp. X'															, ; //X3_TITENG
	'Valor Imp. X'															, ; //X3_DESCRIC
	'Valor Imp. X'															, ; //X3_DESCSPA
	'Valor Imp. X'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVX","MT100",M->D2_VALIMPX)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'O1'																	, ; //X3_ORDEM
	'D2_BASIMPX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. X'															, ; //X3_TITULO
	'Base Imp. X'															, ; //X3_TITSPA
	'Base Imp. X'															, ; //X3_TITENG
	'Base Imp. X'															, ; //X3_DESCRIC
	'Base Imp. X'															, ; //X3_DESCSPA
	'Base Imp. X'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVX","MT100",M->D2_BASIMPX)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'O2'																	, ; //X3_ORDEM
	'D2_ALQIMPX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. X'															, ; //X3_TITULO
	'Alic Imp. X'															, ; //X3_TITSPA
	'Alic Imp. X'															, ; //X3_TITENG
	'Alic Imp. X'															, ; //X3_DESCRIC
	'Alic Imp. X'															, ; //X3_DESCSPA
	'Alic Imp. X'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVX","MT100",M->D2_ALQIMPX)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'O3'																	, ; //X3_ORDEM
	'D2_VALIMPY'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. Y'															, ; //X3_TITULO
	'Valor Imp. Y'															, ; //X3_TITSPA
	'Valor Imp. Y'															, ; //X3_TITENG
	'Valor Imp. Y'															, ; //X3_DESCRIC
	'Valor Imp. Y'															, ; //X3_DESCSPA
	'Valor Imp. Y'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVY","MT100",M->D2_VALIMPY)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'O4'																	, ; //X3_ORDEM
	'D2_BASIMPY'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. Y'															, ; //X3_TITULO
	'Base Imp. Y'															, ; //X3_TITSPA
	'Base Imp. Y'															, ; //X3_TITENG
	'Base Imp. Y'															, ; //X3_DESCRIC
	'Base Imp. Y'															, ; //X3_DESCSPA
	'Base Imp. Y'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVY","MT100",M->D2_BASIMPY)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SD2'																	, ; //X3_ARQUIVO
	'O5'																	, ; //X3_ORDEM
	'D2_ALQIMPY'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. Y'															, ; //X3_TITULO
	'Alic Imp. Y'															, ; //X3_TITSPA
	'Alic Imp. Y'															, ; //X3_TITENG
	'Alic Imp. Y'															, ; //X3_DESCRIC
	'Alic Imp. Y'															, ; //X3_DESCSPA
	'Alic Imp. Y'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVY","MT100",M->D2_ALQIMPY)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

// ...........
// Tabela SF1
// ..........

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'D7'																	, ; //X3_ORDEM
	'F1_VALIMPA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. A'															, ; //X3_TITULO
	'Valor Imp. A'															, ; //X3_TITSPA
	'Valor Imp. A'															, ; //X3_TITENG
	'Valor Imp. A'															, ; //X3_DESCRIC
	'Valor Imp. A'															, ; //X3_DESCSPA
	'Valor Imp. A'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVA","MT100",M->F1_VALIMPA)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'D8'																	, ; //X3_ORDEM
	'F1_BASIMPA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. A'															, ; //X3_TITULO
	'Base Imp. A'															, ; //X3_TITSPA
	'Base Imp. A'															, ; //X3_TITENG
	'Base Imp. A'															, ; //X3_DESCRIC
	'Base Imp. A'															, ; //X3_DESCSPA
	'Base Imp. A'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVA","MT100",M->F1_BASIMPA)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'D9'																	, ; //X3_ORDEM
	'F1_VALIMPB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. B'															, ; //X3_TITULO
	'Valor Imp. B'															, ; //X3_TITSPA
	'Valor Imp. B'															, ; //X3_TITENG
	'Valor Imp. B'															, ; //X3_DESCRIC
	'Valor Imp. B'															, ; //X3_DESCSPA
	'Valor Imp. B'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVB","MT100",M->F1_VALIMPB)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'E0'																	, ; //X3_ORDEM
	'F1_BASIMPB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. B'															, ; //X3_TITULO
	'Base Imp. B'															, ; //X3_TITSPA
	'Base Imp. B'															, ; //X3_TITENG
	'Base Imp. B'															, ; //X3_DESCRIC
	'Base Imp. B'															, ; //X3_DESCSPA
	'Base Imp. B'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVB","MT100",M->F1_BASIMPB)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'E1'																	, ; //X3_ORDEM
	'F1_VALIMPC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. C'															, ; //X3_TITULO
	'Valor Imp. C'															, ; //X3_TITSPA
	'Valor Imp. C'															, ; //X3_TITENG
	'Valor Imp. C'															, ; //X3_DESCRIC
	'Valor Imp. C'															, ; //X3_DESCSPA
	'Valor Imp. C'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVC","MT100",M->F1_VALIMPC)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'E2'																	, ; //X3_ORDEM
	'F1_BASIMPC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. C'															, ; //X3_TITULO
	'Base Imp. C'															, ; //X3_TITSPA
	'Base Imp. C'															, ; //X3_TITENG
	'Base Imp. C'															, ; //X3_DESCRIC
	'Base Imp. C'															, ; //X3_DESCSPA
	'Base Imp. C'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVC","MT100",M->F1_BASIMPC)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'E3'																	, ; //X3_ORDEM
	'F1_VALIMPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. D'															, ; //X3_TITULO
	'Valor Imp. D'															, ; //X3_TITSPA
	'Valor Imp. D'															, ; //X3_TITENG
	'Valor Imp. D'															, ; //X3_DESCRIC
	'Valor Imp. D'															, ; //X3_DESCSPA
	'Valor Imp. D'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVD","MT100",M->F1_VALIMPD)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'E4'																	, ; //X3_ORDEM
	'F1_BASIMPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. D'															, ; //X3_TITULO
	'Base Imp. D'															, ; //X3_TITSPA
	'Base Imp. D'															, ; //X3_TITENG
	'Base Imp. D'															, ; //X3_DESCRIC
	'Base Imp. D'															, ; //X3_DESCSPA
	'Base Imp. D'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVD","MT100",M->F1_BASIMPD)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'E5'																	, ; //X3_ORDEM
	'F1_VALIMPE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. E'															, ; //X3_TITULO
	'Valor Imp. E'															, ; //X3_TITSPA
	'Valor Imp. E'															, ; //X3_TITENG
	'Valor Imp. E'															, ; //X3_DESCRIC
	'Valor Imp. E'															, ; //X3_DESCSPA
	'Valor Imp. E'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVE","MT100",M->F1_VALIMPE)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'E6'																	, ; //X3_ORDEM
	'F1_BASIMPE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. E'															, ; //X3_TITULO
	'Base Imp. E'															, ; //X3_TITSPA
	'Base Imp. E'															, ; //X3_TITENG
	'Base Imp. E'															, ; //X3_DESCRIC
	'Base Imp. E'															, ; //X3_DESCSPA
	'Base Imp. E'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVE","MT100",M->F1_BASIMPE)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'E7'																	, ; //X3_ORDEM
	'F1_VALIMPF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. F'															, ; //X3_TITULO
	'Valor Imp. F'															, ; //X3_TITSPA
	'Valor Imp. F'															, ; //X3_TITENG
	'Valor Imp. F'															, ; //X3_DESCRIC
	'Valor Imp. F'															, ; //X3_DESCSPA
	'Valor Imp. F'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVF","MT100",M->F1_VALIMPF)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'E8'																	, ; //X3_ORDEM
	'F1_BASIMPF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. F'															, ; //X3_TITULO
	'Base Imp. F'															, ; //X3_TITSPA
	'Base Imp. F'															, ; //X3_TITENG
	'Base Imp. F'															, ; //X3_DESCRIC
	'Base Imp. F'															, ; //X3_DESCSPA
	'Base Imp. F'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVF","MT100",M->F1_BASIMPF)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'E9'																	, ; //X3_ORDEM
	'F1_VALIMPG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. G'															, ; //X3_TITULO
	'Valor Imp. G'															, ; //X3_TITSPA
	'Valor Imp. G'															, ; //X3_TITENG
	'Valor Imp. G'															, ; //X3_DESCRIC
	'Valor Imp. G'															, ; //X3_DESCSPA
	'Valor Imp. G'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVG","MT100",M->F1_VALIMPG)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'F0'																	, ; //X3_ORDEM
	'F1_BASIMPG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. G'															, ; //X3_TITULO
	'Base Imp. G'															, ; //X3_TITSPA
	'Base Imp. G'															, ; //X3_TITENG
	'Base Imp. G'															, ; //X3_DESCRIC
	'Base Imp. G'															, ; //X3_DESCSPA
	'Base Imp. G'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVG","MT100",M->F1_BASIMPG)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'F1'																	, ; //X3_ORDEM
	'F1_VALIMPJ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. J'															, ; //X3_TITULO
	'Valor Imp. J'															, ; //X3_TITSPA
	'Valor Imp. J'															, ; //X3_TITENG
	'Valor Imp. J'															, ; //X3_DESCRIC
	'Valor Imp. J'															, ; //X3_DESCSPA
	'Valor Imp. J'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVJ","MT100",M->F1_VALIMPJ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'F2'																	, ; //X3_ORDEM
	'F1_BASIMPJ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. J'															, ; //X3_TITULO
	'Base Imp. J'															, ; //X3_TITSPA
	'Base Imp. J'															, ; //X3_TITENG
	'Base Imp. J'															, ; //X3_DESCRIC
	'Base Imp. J'															, ; //X3_DESCSPA
	'Base Imp. J'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVJ","MT100",M->F1_BASIMPJ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'F3'																	, ; //X3_ORDEM
	'F1_VALIMPK'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. K'															, ; //X3_TITULO
	'Valor Imp. K'															, ; //X3_TITSPA
	'Valor Imp. K'															, ; //X3_TITENG
	'Valor Imp. K'															, ; //X3_DESCRIC
	'Valor Imp. K'															, ; //X3_DESCSPA
	'Valor Imp. K'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVK","MT100",M->F1_VALIMPK)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'F4'																	, ; //X3_ORDEM
	'F1_BASIMPK'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. K'															, ; //X3_TITULO
	'Base Imp. K'															, ; //X3_TITSPA
	'Base Imp. K'															, ; //X3_TITENG
	'Base Imp. K'															, ; //X3_DESCRIC
	'Base Imp. K'															, ; //X3_DESCSPA
	'Base Imp. K'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVK","MT100",M->F1_BASIMPK)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'F5'																	, ; //X3_ORDEM
	'F1_VALIMPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. L'															, ; //X3_TITULO
	'Valor Imp. L'															, ; //X3_TITSPA
	'Valor Imp. L'															, ; //X3_TITENG
	'Valor Imp. L'															, ; //X3_DESCRIC
	'Valor Imp. L'															, ; //X3_DESCSPA
	'Valor Imp. L'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVL","MT100",M->F1_VALIMPL)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'F6'																	, ; //X3_ORDEM
	'F1_BASIMPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. L'															, ; //X3_TITULO
	'Base Imp. L'															, ; //X3_TITSPA
	'Base Imp. L'															, ; //X3_TITENG
	'Base Imp. L'															, ; //X3_DESCRIC
	'Base Imp. L'															, ; //X3_DESCSPA
	'Base Imp. L'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVL","MT100",M->F1_BASIMPL)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'F7'																	, ; //X3_ORDEM
	'F1_VALIMPM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. M'															, ; //X3_TITULO
	'Valor Imp. M'															, ; //X3_TITSPA
	'Valor Imp. M'															, ; //X3_TITENG
	'Valor Imp. M'															, ; //X3_DESCRIC
	'Valor Imp. M'															, ; //X3_DESCSPA
	'Valor Imp. M'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVM","MT100",M->F1_VALIMPM)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'F8'																	, ; //X3_ORDEM
	'F1_BASIMPM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. M'															, ; //X3_TITULO
	'Base Imp. M'															, ; //X3_TITSPA
	'Base Imp. M'															, ; //X3_TITENG
	'Base Imp. M'															, ; //X3_DESCRIC
	'Base Imp. M'															, ; //X3_DESCSPA
	'Base Imp. M'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVM","MT100",M->F1_BASIMPM)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'F9'																	, ; //X3_ORDEM
	'F1_VALIMPN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. N'															, ; //X3_TITULO
	'Valor Imp. N'															, ; //X3_TITSPA
	'Valor Imp. N'															, ; //X3_TITENG
	'Valor Imp. N'															, ; //X3_DESCRIC
	'Valor Imp. N'															, ; //X3_DESCSPA
	'Valor Imp. N'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVN","MT100",M->F1_VALIMPN)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'G0'																	, ; //X3_ORDEM
	'F1_BASIMPN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. N'															, ; //X3_TITULO
	'Base Imp. N'															, ; //X3_TITSPA
	'Base Imp. N'															, ; //X3_TITENG
	'Base Imp. N'															, ; //X3_DESCRIC
	'Base Imp. N'															, ; //X3_DESCSPA
	'Base Imp. N'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVN","MT100",M->F1_BASIMPN)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'G1'																	, ; //X3_ORDEM
	'F1_VALIMPO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. O'															, ; //X3_TITULO
	'Valor Imp. O'															, ; //X3_TITSPA
	'Valor Imp. O'															, ; //X3_TITENG
	'Valor Imp. O'															, ; //X3_DESCRIC
	'Valor Imp. O'															, ; //X3_DESCSPA
	'Valor Imp. O'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVO","MT100",M->F1_VALIMPO)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'G2'																	, ; //X3_ORDEM
	'F1_BASIMPO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. O'															, ; //X3_TITULO
	'Base Imp. O'															, ; //X3_TITSPA
	'Base Imp. O'															, ; //X3_TITENG
	'Base Imp. O'															, ; //X3_DESCRIC
	'Base Imp. O'															, ; //X3_DESCSPA
	'Base Imp. O'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVO","MT100",M->F1_BASIMPO)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'G3'																	, ; //X3_ORDEM
	'F1_VALIMPP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. P'															, ; //X3_TITULO
	'Valor Imp. P'															, ; //X3_TITSPA
	'Valor Imp. P'															, ; //X3_TITENG
	'Valor Imp. P'															, ; //X3_DESCRIC
	'Valor Imp. P'															, ; //X3_DESCSPA
	'Valor Imp. P'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVP","MT100",M->F1_VALIMPP)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'G4'																	, ; //X3_ORDEM
	'F1_BASIMPP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. P'															, ; //X3_TITULO
	'Base Imp. P'															, ; //X3_TITSPA
	'Base Imp. P'															, ; //X3_TITENG
	'Base Imp. P'															, ; //X3_DESCRIC
	'Base Imp. P'															, ; //X3_DESCSPA
	'Base Imp. P'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVP","MT100",M->F1_BASIMPP)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'G5'																	, ; //X3_ORDEM
	'F1_VALIMPQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. Q'															, ; //X3_TITULO
	'Valor Imp. Q'															, ; //X3_TITSPA
	'Valor Imp. Q'															, ; //X3_TITENG
	'Valor Imp. Q'															, ; //X3_DESCRIC
	'Valor Imp. Q'															, ; //X3_DESCSPA
	'Valor Imp. Q'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVQ","MT100",M->F1_VALIMPQ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'G6'																	, ; //X3_ORDEM
	'F1_BASIMPQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. Q'															, ; //X3_TITULO
	'Base Imp. Q'															, ; //X3_TITSPA
	'Base Imp. Q'															, ; //X3_TITENG
	'Base Imp. Q'															, ; //X3_DESCRIC
	'Base Imp. Q'															, ; //X3_DESCSPA
	'Base Imp. Q'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVQ","MT100",M->F1_BASIMPQ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'G7'																	, ; //X3_ORDEM
	'F1_VALIMPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. R'															, ; //X3_TITULO
	'Valor Imp. R'															, ; //X3_TITSPA
	'Valor Imp. R'															, ; //X3_TITENG
	'Valor Imp. R'															, ; //X3_DESCRIC
	'Valor Imp. R'															, ; //X3_DESCSPA
	'Valor Imp. R'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVR","MT100",M->F1_VALIMPR)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'G8'																	, ; //X3_ORDEM
	'F1_BASIMPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. R'															, ; //X3_TITULO
	'Base Imp. R'															, ; //X3_TITSPA
	'Base Imp. R'															, ; //X3_TITENG
	'Base Imp. R'															, ; //X3_DESCRIC
	'Base Imp. R'															, ; //X3_DESCSPA
	'Base Imp. R'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVR","MT100",M->F1_BASIMPR)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'G9'																	, ; //X3_ORDEM
	'F1_VALIMPS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. S'															, ; //X3_TITULO
	'Valor Imp. S'															, ; //X3_TITSPA
	'Valor Imp. S'															, ; //X3_TITENG
	'Valor Imp. S'															, ; //X3_DESCRIC
	'Valor Imp. S'															, ; //X3_DESCSPA
	'Valor Imp. S'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVS","MT100",M->F1_VALIMPS)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'H0'																	, ; //X3_ORDEM
	'F1_BASIMPS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. S'															, ; //X3_TITULO
	'Base Imp. S'															, ; //X3_TITSPA
	'Base Imp. S'															, ; //X3_TITENG
	'Base Imp. S'															, ; //X3_DESCRIC
	'Base Imp. S'															, ; //X3_DESCSPA
	'Base Imp. S'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVS","MT100",M->F1_BASIMPS)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'H1'																	, ; //X3_ORDEM
	'F1_VALIMPT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. T'															, ; //X3_TITULO
	'Valor Imp. T'															, ; //X3_TITSPA
	'Valor Imp. T'															, ; //X3_TITENG
	'Valor Imp. T'															, ; //X3_DESCRIC
	'Valor Imp. T'															, ; //X3_DESCSPA
	'Valor Imp. T'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVT","MT100",M->F1_VALIMPT)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'H2'																	, ; //X3_ORDEM
	'F1_BASIMPT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. T'															, ; //X3_TITULO
	'Base Imp. T'															, ; //X3_TITSPA
	'Base Imp. T'															, ; //X3_TITENG
	'Base Imp. T'															, ; //X3_DESCRIC
	'Base Imp. T'															, ; //X3_DESCSPA
	'Base Imp. T'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVT","MT100",M->F1_BASIMPT)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'H3'																	, ; //X3_ORDEM
	'F1_VALIMPU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. U'															, ; //X3_TITULO
	'Valor Imp. U'															, ; //X3_TITSPA
	'Valor Imp. U'															, ; //X3_TITENG
	'Valor Imp. U'															, ; //X3_DESCRIC
	'Valor Imp. U'															, ; //X3_DESCSPA
	'Valor Imp. U'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVU","MT100",M->F1_VALIMPU)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'H4'																	, ; //X3_ORDEM
	'F1_BASIMPU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. U'															, ; //X3_TITULO
	'Base Imp. U'															, ; //X3_TITSPA
	'Base Imp. U'															, ; //X3_TITENG
	'Base Imp. U'															, ; //X3_DESCRIC
	'Base Imp. U'															, ; //X3_DESCSPA
	'Base Imp. U'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVU","MT100",M->F1_BASIMPU)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'H5'																	, ; //X3_ORDEM
	'F1_VALIMPV'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. V'															, ; //X3_TITULO
	'Valor Imp. V'															, ; //X3_TITSPA
	'Valor Imp. V'															, ; //X3_TITENG
	'Valor Imp. V'															, ; //X3_DESCRIC
	'Valor Imp. V'															, ; //X3_DESCSPA
	'Valor Imp. V'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVV","MT100",M->F1_VALIMPV)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'H6'																	, ; //X3_ORDEM
	'F1_BASIMPV'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. V'															, ; //X3_TITULO
	'Base Imp. V'															, ; //X3_TITSPA
	'Base Imp. V'															, ; //X3_TITENG
	'Base Imp. V'															, ; //X3_DESCRIC
	'Base Imp. V'															, ; //X3_DESCSPA
	'Base Imp. V'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVV","MT100",M->F1_BASIMPV)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'H7'																	, ; //X3_ORDEM
	'F1_VALIMPW'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. W'															, ; //X3_TITULO
	'Valor Imp. W'															, ; //X3_TITSPA
	'Valor Imp. W'															, ; //X3_TITENG
	'Valor Imp. W'															, ; //X3_DESCRIC
	'Valor Imp. W'															, ; //X3_DESCSPA
	'Valor Imp. W'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVW","MT100",M->F1_VALIMPW)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'H8'																	, ; //X3_ORDEM
	'F1_BASIMPW'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. W'															, ; //X3_TITULO
	'Base Imp. W'															, ; //X3_TITSPA
	'Base Imp. W'															, ; //X3_TITENG
	'Base Imp. W'															, ; //X3_DESCRIC
	'Base Imp. W'															, ; //X3_DESCSPA
	'Base Imp. W'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVW","MT100",M->F1_BASIMPW)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'H9'																	, ; //X3_ORDEM
	'F1_VALIMPX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. X'															, ; //X3_TITULO
	'Valor Imp. X'															, ; //X3_TITSPA
	'Valor Imp. X'															, ; //X3_TITENG
	'Valor Imp. X'															, ; //X3_DESCRIC
	'Valor Imp. X'															, ; //X3_DESCSPA
	'Valor Imp. X'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVX","MT100",M->F1_VALIMPX)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'I0'																	, ; //X3_ORDEM
	'F1_BASIMPX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. X'															, ; //X3_TITULO
	'Base Imp. X'															, ; //X3_TITSPA
	'Base Imp. X'															, ; //X3_TITENG
	'Base Imp. X'															, ; //X3_DESCRIC
	'Base Imp. X'															, ; //X3_DESCSPA
	'Base Imp. X'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVX","MT100",M->F1_BASIMPX)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'I1'																	, ; //X3_ORDEM
	'F1_VALIMPY'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. Y'															, ; //X3_TITULO
	'Valor Imp. Y'															, ; //X3_TITSPA
	'Valor Imp. Y'															, ; //X3_TITENG
	'Valor Imp. Y'															, ; //X3_DESCRIC
	'Valor Imp. Y'															, ; //X3_DESCSPA
	'Valor Imp. Y'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVY","MT100",M->F1_VALIMPY)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF1'																	, ; //X3_ARQUIVO
	'H2'																	, ; //X3_ORDEM
	'F1_BASIMPY'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. Y'															, ; //X3_TITULO
	'Base Imp. Y'															, ; //X3_TITSPA
	'Base Imp. Y'															, ; //X3_TITENG
	'Base Imp. Y'															, ; //X3_DESCRIC
	'Base Imp. Y'															, ; //X3_DESCSPA
	'Base Imp. Y'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVY","MT100",M->F1_BASIMPY)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME



// ..........
// Tabela SF2
// ..........

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'H3'																	, ; //X3_ORDEM
	'F2_VALIMPA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. A'															, ; //X3_TITULO
	'Valor Imp. A'															, ; //X3_TITSPA
	'Valor Imp. A'															, ; //X3_TITENG
	'Valor Imp. A'															, ; //X3_DESCRIC
	'Valor Imp. A'															, ; //X3_DESCSPA
	'Valor Imp. A'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVA","MT100",M->F2_VALIMPA)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'H4'																	, ; //X3_ORDEM
	'F2_BASIMPA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. A'															, ; //X3_TITULO
	'Base Imp. A'															, ; //X3_TITSPA
	'Base Imp. A'															, ; //X3_TITENG
	'Base Imp. A'															, ; //X3_DESCRIC
	'Base Imp. A'															, ; //X3_DESCSPA
	'Base Imp. A'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVA","MT100",M->F2_BASIMPA)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'H5'																	, ; //X3_ORDEM
	'F2_VALIMPB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. B'															, ; //X3_TITULO
	'Valor Imp. B'															, ; //X3_TITSPA
	'Valor Imp. B'															, ; //X3_TITENG
	'Valor Imp. B'															, ; //X3_DESCRIC
	'Valor Imp. B'															, ; //X3_DESCSPA
	'Valor Imp. B'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVB","MT100",M->F2_VALIMPB)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'H6'																	, ; //X3_ORDEM
	'F2_BASIMPB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. B'															, ; //X3_TITULO
	'Base Imp. B'															, ; //X3_TITSPA
	'Base Imp. B'															, ; //X3_TITENG
	'Base Imp. B'															, ; //X3_DESCRIC
	'Base Imp. B'															, ; //X3_DESCSPA
	'Base Imp. B'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVB","MT100",M->F2_BASIMPB)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'H7'																	, ; //X3_ORDEM
	'F2_VALIMPC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. C'															, ; //X3_TITULO
	'Valor Imp. C'															, ; //X3_TITSPA
	'Valor Imp. C'															, ; //X3_TITENG
	'Valor Imp. C'															, ; //X3_DESCRIC
	'Valor Imp. C'															, ; //X3_DESCSPA
	'Valor Imp. C'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVC","MT100",M->F2_VALIMPC)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'H8'																	, ; //X3_ORDEM
	'F2_BASIMPC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. C'															, ; //X3_TITULO
	'Base Imp. C'															, ; //X3_TITSPA
	'Base Imp. C'															, ; //X3_TITENG
	'Base Imp. C'															, ; //X3_DESCRIC
	'Base Imp. C'															, ; //X3_DESCSPA
	'Base Imp. C'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVC","MT100",M->F2_BASIMPC)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'H9'																	, ; //X3_ORDEM
	'F2_VALIMPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. D'															, ; //X3_TITULO
	'Valor Imp. D'															, ; //X3_TITSPA
	'Valor Imp. D'															, ; //X3_TITENG
	'Valor Imp. D'															, ; //X3_DESCRIC
	'Valor Imp. D'															, ; //X3_DESCSPA
	'Valor Imp. D'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVD","MT100",M->F2_VALIMPD)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'I0'																	, ; //X3_ORDEM
	'F2_BASIMPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. D'															, ; //X3_TITULO
	'Base Imp. D'															, ; //X3_TITSPA
	'Base Imp. D'															, ; //X3_TITENG
	'Base Imp. D'															, ; //X3_DESCRIC
	'Base Imp. D'															, ; //X3_DESCSPA
	'Base Imp. D'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVD","MT100",M->F2_BASIMPD)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'I1'																	, ; //X3_ORDEM
	'F2_VALIMPE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. E'															, ; //X3_TITULO
	'Valor Imp. E'															, ; //X3_TITSPA
	'Valor Imp. E'															, ; //X3_TITENG
	'Valor Imp. E'															, ; //X3_DESCRIC
	'Valor Imp. E'															, ; //X3_DESCSPA
	'Valor Imp. E'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVE","MT100",M->F2_VALIMPE)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'I2'																	, ; //X3_ORDEM
	'F2_BASIMPE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. E'															, ; //X3_TITULO
	'Base Imp. E'															, ; //X3_TITSPA
	'Base Imp. E'															, ; //X3_TITENG
	'Base Imp. E'															, ; //X3_DESCRIC
	'Base Imp. E'															, ; //X3_DESCSPA
	'Base Imp. E'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVE","MT100",M->F2_BASIMPE)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'I3'																	, ; //X3_ORDEM
	'F2_VALIMPF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. F'															, ; //X3_TITULO
	'Valor Imp. F'															, ; //X3_TITSPA
	'Valor Imp. F'															, ; //X3_TITENG
	'Valor Imp. F'															, ; //X3_DESCRIC
	'Valor Imp. F'															, ; //X3_DESCSPA
	'Valor Imp. F'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVF","MT100",M->F2_VALIMPF)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'I4'																	, ; //X3_ORDEM
	'F2_BASIMPF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. F'															, ; //X3_TITULO
	'Base Imp. F'															, ; //X3_TITSPA
	'Base Imp. F'															, ; //X3_TITENG
	'Base Imp. F'															, ; //X3_DESCRIC
	'Base Imp. F'															, ; //X3_DESCSPA
	'Base Imp. F'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVF","MT100",M->F2_BASIMPF)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'I5'																	, ; //X3_ORDEM
	'F2_VALIMPG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. G'															, ; //X3_TITULO
	'Valor Imp. G'															, ; //X3_TITSPA
	'Valor Imp. G'															, ; //X3_TITENG
	'Valor Imp. G'															, ; //X3_DESCRIC
	'Valor Imp. G'															, ; //X3_DESCSPA
	'Valor Imp. G'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVG","MT100",M->F2_VALIMPG)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'I6'																	, ; //X3_ORDEM
	'F2_BASIMPG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. G'															, ; //X3_TITULO
	'Base Imp. G'															, ; //X3_TITSPA
	'Base Imp. G'															, ; //X3_TITENG
	'Base Imp. G'															, ; //X3_DESCRIC
	'Base Imp. G'															, ; //X3_DESCSPA
	'Base Imp. G'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVG","MT100",M->F2_BASIMPG)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'I7'																	, ; //X3_ORDEM
	'F2_VALIMPJ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. J'															, ; //X3_TITULO
	'Valor Imp. J'															, ; //X3_TITSPA
	'Valor Imp. J'															, ; //X3_TITENG
	'Valor Imp. J'															, ; //X3_DESCRIC
	'Valor Imp. J'															, ; //X3_DESCSPA
	'Valor Imp. J'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVJ","MT100",M->F2_VALIMPJ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'I8'																	, ; //X3_ORDEM
	'F2_BASIMPJ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. J'															, ; //X3_TITULO
	'Base Imp. J'															, ; //X3_TITSPA
	'Base Imp. J'															, ; //X3_TITENG
	'Base Imp. J'															, ; //X3_DESCRIC
	'Base Imp. J'															, ; //X3_DESCSPA
	'Base Imp. J'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVJ","MT100",M->F2_BASIMPJ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'I9'																	, ; //X3_ORDEM
	'F2_VALIMPK'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. K'															, ; //X3_TITULO
	'Valor Imp. K'															, ; //X3_TITSPA
	'Valor Imp. K'															, ; //X3_TITENG
	'Valor Imp. K'															, ; //X3_DESCRIC
	'Valor Imp. K'															, ; //X3_DESCSPA
	'Valor Imp. K'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVK","MT100",M->F2_VALIMPK)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'J0'																	, ; //X3_ORDEM
	'F2_BASIMPK'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. K'															, ; //X3_TITULO
	'Base Imp. K'															, ; //X3_TITSPA
	'Base Imp. K'															, ; //X3_TITENG
	'Base Imp. K'															, ; //X3_DESCRIC
	'Base Imp. K'															, ; //X3_DESCSPA
	'Base Imp. K'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVK","MT100",M->F2_BASIMPK)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'J1'																	, ; //X3_ORDEM
	'F2_VALIMPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. L'															, ; //X3_TITULO
	'Valor Imp. L'															, ; //X3_TITSPA
	'Valor Imp. L'															, ; //X3_TITENG
	'Valor Imp. L'															, ; //X3_DESCRIC
	'Valor Imp. L'															, ; //X3_DESCSPA
	'Valor Imp. L'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVL","MT100",M->F2_VALIMPL)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'J2'																	, ; //X3_ORDEM
	'F2_BASIMPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. L'															, ; //X3_TITULO
	'Base Imp. L'															, ; //X3_TITSPA
	'Base Imp. L'															, ; //X3_TITENG
	'Base Imp. L'															, ; //X3_DESCRIC
	'Base Imp. L'															, ; //X3_DESCSPA
	'Base Imp. L'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVL","MT100",M->F2_BASIMPL)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'J3'																	, ; //X3_ORDEM
	'F2_VALIMPM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. M'															, ; //X3_TITULO
	'Valor Imp. M'															, ; //X3_TITSPA
	'Valor Imp. M'															, ; //X3_TITENG
	'Valor Imp. M'															, ; //X3_DESCRIC
	'Valor Imp. M'															, ; //X3_DESCSPA
	'Valor Imp. M'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVM","MT100",M->F2_VALIMPM)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'J4'																	, ; //X3_ORDEM
	'F2_BASIMPM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. M'															, ; //X3_TITULO
	'Base Imp. M'															, ; //X3_TITSPA
	'Base Imp. M'															, ; //X3_TITENG
	'Base Imp. M'															, ; //X3_DESCRIC
	'Base Imp. M'															, ; //X3_DESCSPA
	'Base Imp. M'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVM","MT100",M->F2_BASIMPM)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'J5'																	, ; //X3_ORDEM
	'F2_VALIMPN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. N'															, ; //X3_TITULO
	'Valor Imp. N'															, ; //X3_TITSPA
	'Valor Imp. N'															, ; //X3_TITENG
	'Valor Imp. N'															, ; //X3_DESCRIC
	'Valor Imp. N'															, ; //X3_DESCSPA
	'Valor Imp. N'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVN","MT100",M->F2_VALIMPN)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'J6'																	, ; //X3_ORDEM
	'F2_BASIMPN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. N'															, ; //X3_TITULO
	'Base Imp. N'															, ; //X3_TITSPA
	'Base Imp. N'															, ; //X3_TITENG
	'Base Imp. N'															, ; //X3_DESCRIC
	'Base Imp. N'															, ; //X3_DESCSPA
	'Base Imp. N'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVN","MT100",M->F2_BASIMPN)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'J7'																	, ; //X3_ORDEM
	'F2_VALIMPO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. O'															, ; //X3_TITULO
	'Valor Imp. O'															, ; //X3_TITSPA
	'Valor Imp. O'															, ; //X3_TITENG
	'Valor Imp. O'															, ; //X3_DESCRIC
	'Valor Imp. O'															, ; //X3_DESCSPA
	'Valor Imp. O'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVO","MT100",M->F2_VALIMPO)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'J8'																	, ; //X3_ORDEM
	'F2_BASIMPO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. O'															, ; //X3_TITULO
	'Base Imp. O'															, ; //X3_TITSPA
	'Base Imp. O'															, ; //X3_TITENG
	'Base Imp. O'															, ; //X3_DESCRIC
	'Base Imp. O'															, ; //X3_DESCSPA
	'Base Imp. O'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVO","MT100",M->F2_BASIMPO)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'J9'																	, ; //X3_ORDEM
	'F2_VALIMPP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. P'															, ; //X3_TITULO
	'Valor Imp. P'															, ; //X3_TITSPA
	'Valor Imp. P'															, ; //X3_TITENG
	'Valor Imp. P'															, ; //X3_DESCRIC
	'Valor Imp. P'															, ; //X3_DESCSPA
	'Valor Imp. P'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVP","MT100",M->F2_VALIMPP)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'K0'																	, ; //X3_ORDEM
	'F2_BASIMPP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. P'															, ; //X3_TITULO
	'Base Imp. P'															, ; //X3_TITSPA
	'Base Imp. P'															, ; //X3_TITENG
	'Base Imp. P'															, ; //X3_DESCRIC
	'Base Imp. P'															, ; //X3_DESCSPA
	'Base Imp. P'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVP","MT100",M->F2_BASIMPP)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'K1'																	, ; //X3_ORDEM
	'F2_VALIMPQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. Q'															, ; //X3_TITULO
	'Valor Imp. Q'															, ; //X3_TITSPA
	'Valor Imp. Q'															, ; //X3_TITENG
	'Valor Imp. Q'															, ; //X3_DESCRIC
	'Valor Imp. Q'															, ; //X3_DESCSPA
	'Valor Imp. Q'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVQ","MT100",M->F2_VALIMPQ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'K2'																	, ; //X3_ORDEM
	'F2_BASIMPQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. Q'															, ; //X3_TITULO
	'Base Imp. Q'															, ; //X3_TITSPA
	'Base Imp. Q'															, ; //X3_TITENG
	'Base Imp. Q'															, ; //X3_DESCRIC
	'Base Imp. Q'															, ; //X3_DESCSPA
	'Base Imp. Q'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVQ","MT100",M->F2_BASIMPQ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'K3'																	, ; //X3_ORDEM
	'F2_VALIMPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. R'															, ; //X3_TITULO
	'Valor Imp. R'															, ; //X3_TITSPA
	'Valor Imp. R'															, ; //X3_TITENG
	'Valor Imp. R'															, ; //X3_DESCRIC
	'Valor Imp. R'															, ; //X3_DESCSPA
	'Valor Imp. R'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVR","MT100",M->F2_VALIMPR)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'K4'																	, ; //X3_ORDEM
	'F2_BASIMPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. R'															, ; //X3_TITULO
	'Base Imp. R'															, ; //X3_TITSPA
	'Base Imp. R'															, ; //X3_TITENG
	'Base Imp. R'															, ; //X3_DESCRIC
	'Base Imp. R'															, ; //X3_DESCSPA
	'Base Imp. R'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVR","MT100",M->F2_BASIMPR)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'K5'																	, ; //X3_ORDEM
	'F2_VALIMPS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. S'															, ; //X3_TITULO
	'Valor Imp. S'															, ; //X3_TITSPA
	'Valor Imp. S'															, ; //X3_TITENG
	'Valor Imp. S'															, ; //X3_DESCRIC
	'Valor Imp. S'															, ; //X3_DESCSPA
	'Valor Imp. S'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVS","MT100",M->F2_VALIMPS)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'K6'																	, ; //X3_ORDEM
	'F2_BASIMPS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. S'															, ; //X3_TITULO
	'Base Imp. S'															, ; //X3_TITSPA
	'Base Imp. S'															, ; //X3_TITENG
	'Base Imp. S'															, ; //X3_DESCRIC
	'Base Imp. S'															, ; //X3_DESCSPA
	'Base Imp. S'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVS","MT100",M->F2_BASIMPS)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'K7'																	, ; //X3_ORDEM
	'F2_VALIMPT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. T'															, ; //X3_TITULO
	'Valor Imp. T'															, ; //X3_TITSPA
	'Valor Imp. T'															, ; //X3_TITENG
	'Valor Imp. T'															, ; //X3_DESCRIC
	'Valor Imp. T'															, ; //X3_DESCSPA
	'Valor Imp. T'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVT","MT100",M->F2_VALIMPT)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'K8'																	, ; //X3_ORDEM
	'F2_BASIMPT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. T'															, ; //X3_TITULO
	'Base Imp. T'															, ; //X3_TITSPA
	'Base Imp. T'															, ; //X3_TITENG
	'Base Imp. T'															, ; //X3_DESCRIC
	'Base Imp. T'															, ; //X3_DESCSPA
	'Base Imp. T'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVT","MT100",M->F2_BASIMPT)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'K9'																	, ; //X3_ORDEM
	'F2_VALIMPU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. U'															, ; //X3_TITULO
	'Valor Imp. U'															, ; //X3_TITSPA
	'Valor Imp. U'															, ; //X3_TITENG
	'Valor Imp. U'															, ; //X3_DESCRIC
	'Valor Imp. U'															, ; //X3_DESCSPA
	'Valor Imp. U'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVU","MT100",M->F2_VALIMPU)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'L0'																	, ; //X3_ORDEM
	'F2_BASIMPU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. U'															, ; //X3_TITULO
	'Base Imp. U'															, ; //X3_TITSPA
	'Base Imp. U'															, ; //X3_TITENG
	'Base Imp. U'															, ; //X3_DESCRIC
	'Base Imp. U'															, ; //X3_DESCSPA
	'Base Imp. U'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVU","MT100",M->F2_BASIMPU)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'L1'																	, ; //X3_ORDEM
	'F2_VALIMPV'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. V'															, ; //X3_TITULO
	'Valor Imp. V'															, ; //X3_TITSPA
	'Valor Imp. V'															, ; //X3_TITENG
	'Valor Imp. V'															, ; //X3_DESCRIC
	'Valor Imp. V'															, ; //X3_DESCSPA
	'Valor Imp. V'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVV","MT100",M->F2_VALIMPV)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'L2'																	, ; //X3_ORDEM
	'F2_BASIMPV'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. V'															, ; //X3_TITULO
	'Base Imp. V'															, ; //X3_TITSPA
	'Base Imp. V'															, ; //X3_TITENG
	'Base Imp. V'															, ; //X3_DESCRIC
	'Base Imp. V'															, ; //X3_DESCSPA
	'Base Imp. V'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVV","MT100",M->F2_BASIMPV)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'L3'																	, ; //X3_ORDEM
	'F2_VALIMPW'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. W'															, ; //X3_TITULO
	'Valor Imp. W'															, ; //X3_TITSPA
	'Valor Imp. W'															, ; //X3_TITENG
	'Valor Imp. W'															, ; //X3_DESCRIC
	'Valor Imp. W'															, ; //X3_DESCSPA
	'Valor Imp. W'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVW","MT100",M->F2_VALIMPW)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'L4'																	, ; //X3_ORDEM
	'F2_BASIMPW'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. W'															, ; //X3_TITULO
	'Base Imp. W'															, ; //X3_TITSPA
	'Base Imp. W'															, ; //X3_TITENG
	'Base Imp. W'															, ; //X3_DESCRIC
	'Base Imp. W'															, ; //X3_DESCSPA
	'Base Imp. W'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVW","MT100",M->F2_BASIMPW)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'L5'																	, ; //X3_ORDEM
	'F2_VALIMPX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. X'															, ; //X3_TITULO
	'Valor Imp. X'															, ; //X3_TITSPA
	'Valor Imp. X'															, ; //X3_TITENG
	'Valor Imp. X'															, ; //X3_DESCRIC
	'Valor Imp. X'															, ; //X3_DESCSPA
	'Valor Imp. X'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVX","MT100",M->F2_VALIMPX)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'L6'																	, ; //X3_ORDEM
	'F2_BASIMPX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. X'															, ; //X3_TITULO
	'Base Imp. X'															, ; //X3_TITSPA
	'Base Imp. X'															, ; //X3_TITENG
	'Base Imp. X'															, ; //X3_DESCRIC
	'Base Imp. X'															, ; //X3_DESCSPA
	'Base Imp. X'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVX","MT100",M->F2_BASIMPX)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'L7'																	, ; //X3_ORDEM
	'F2_VALIMPY'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. Y'															, ; //X3_TITULO
	'Valor Imp. Y'															, ; //X3_TITSPA
	'Valor Imp. Y'															, ; //X3_TITENG
	'Valor Imp. Y'															, ; //X3_DESCRIC
	'Valor Imp. Y'															, ; //X3_DESCSPA
	'Valor Imp. Y'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_VALIVY","MT100",M->F2_VALIMPY)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF2'																	, ; //X3_ARQUIVO
	'L8'																	, ; //X3_ORDEM
	'F2_BASIMPY'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. Y'															, ; //X3_TITULO
	'Base Imp. Y'															, ; //X3_TITSPA
	'Base Imp. Y'															, ; //X3_TITENG
	'Base Imp. Y'															, ; //X3_DESCRIC
	'Base Imp. Y'															, ; //X3_DESCSPA
	'Base Imp. Y'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("NF_BASEIVY","MT100",M->F2_BASIMPY)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


// ..........
// Tabela SF3
// ..........


aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'C8'																	, ; //X3_ORDEM
	'F3_VALIMPA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. A'															, ; //X3_TITULO
	'Valor Imp. A'															, ; //X3_TITSPA
	'Valor Imp. A'															, ; //X3_TITENG
	'Valor Imp. A'															, ; //X3_DESCRIC
	'Valor Imp. A'															, ; //X3_DESCSPA
	'Valor Imp. A'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'C9'																	, ; //X3_ORDEM
	'F3_ALQIMPA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. A'															, ; //X3_TITULO
	'Alic Imp. A'															, ; //X3_TITSPA
	'Alic Imp. A'															, ; //X3_TITENG
	'Alic Imp. A'															, ; //X3_DESCRIC
	'Alic Imp. A'															, ; //X3_DESCSPA
	'Alic Imp. A'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'D0'																	, ; //X3_ORDEM
	'F3_BASIMPA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. A'															, ; //X3_TITULO
	'Base Imp. A'															, ; //X3_TITSPA
	'Base Imp. A'															, ; //X3_TITENG
	'Base Imp. A'															, ; //X3_DESCRIC
	'Base Imp. A'															, ; //X3_DESCSPA
	'Base Imp. A'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'D1'																	, ; //X3_ORDEM
	'F3_VALIMPB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. B'															, ; //X3_TITULO
	'Valor Imp. B'															, ; //X3_TITSPA
	'Valor Imp. B'															, ; //X3_TITENG
	'Valor Imp. B'															, ; //X3_DESCRIC
	'Valor Imp. B'															, ; //X3_DESCSPA
	'Valor Imp. B'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'D2'																	, ; //X3_ORDEM
	'F3_ALQIMPB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. B'															, ; //X3_TITULO
	'Alic Imp. B'															, ; //X3_TITSPA
	'Alic Imp. B'															, ; //X3_TITENG
	'Alic Imp. B'															, ; //X3_DESCRIC
	'Alic Imp. B'															, ; //X3_DESCSPA
	'Alic Imp. B'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'D3'																	, ; //X3_ORDEM
	'F3_BASIMPB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. B'															, ; //X3_TITULO
	'Base Imp. B'															, ; //X3_TITSPA
	'Base Imp. B'															, ; //X3_TITENG
	'Base Imp. B'															, ; //X3_DESCRIC
	'Base Imp. B'															, ; //X3_DESCSPA
	'Base Imp. B'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'D4'																	, ; //X3_ORDEM
	'F3_VALIMPC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. C'															, ; //X3_TITULO
	'Valor Imp. C'															, ; //X3_TITSPA
	'Valor Imp. C'															, ; //X3_TITENG
	'Valor Imp. C'															, ; //X3_DESCRIC
	'Valor Imp. C'															, ; //X3_DESCSPA
	'Valor Imp. C'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'D5'																	, ; //X3_ORDEM
	'F3_ALQIMPC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. C'															, ; //X3_TITULO
	'Alic Imp. C'															, ; //X3_TITSPA
	'Alic Imp. C'															, ; //X3_TITENG
	'Alic Imp. C'															, ; //X3_DESCRIC
	'Alic Imp. C'															, ; //X3_DESCSPA
	'Alic Imp. C'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'D6'																	, ; //X3_ORDEM
	'F3_BASIMPC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. C'															, ; //X3_TITULO
	'Base Imp. C'															, ; //X3_TITSPA
	'Base Imp. C'															, ; //X3_TITENG
	'Base Imp. C'															, ; //X3_DESCRIC
	'Base Imp. C'															, ; //X3_DESCSPA
	'Base Imp. C'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'D7'																	, ; //X3_ORDEM
	'F3_VALIMPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. D'															, ; //X3_TITULO
	'Valor Imp. D'															, ; //X3_TITSPA
	'Valor Imp. D'															, ; //X3_TITENG
	'Valor Imp. D'															, ; //X3_DESCRIC
	'Valor Imp. D'															, ; //X3_DESCSPA
	'Valor Imp. D'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'D8'																	, ; //X3_ORDEM
	'F3_ALQIMPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. D'															, ; //X3_TITULO
	'Alic Imp. D'															, ; //X3_TITSPA
	'Alic Imp. D'															, ; //X3_TITENG
	'Alic Imp. D'															, ; //X3_DESCRIC
	'Alic Imp. D'															, ; //X3_DESCSPA
	'Alic Imp. D'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'D9'																	, ; //X3_ORDEM
	'F3_BASIMPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. D'															, ; //X3_TITULO
	'Base Imp. D'															, ; //X3_TITSPA
	'Base Imp. D'															, ; //X3_TITENG
	'Base Imp. D'															, ; //X3_DESCRIC
	'Base Imp. D'															, ; //X3_DESCSPA
	'Base Imp. D'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'E0'																	, ; //X3_ORDEM
	'F3_VALIMPE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. E'															, ; //X3_TITULO
	'Valor Imp. E'															, ; //X3_TITSPA
	'Valor Imp. E'															, ; //X3_TITENG
	'Valor Imp. E'															, ; //X3_DESCRIC
	'Valor Imp. E'															, ; //X3_DESCSPA
	'Valor Imp. E'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'E1'																	, ; //X3_ORDEM
	'F3_ALQIMPE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. E'															, ; //X3_TITULO
	'Alic Imp. E'															, ; //X3_TITSPA
	'Alic Imp. E'															, ; //X3_TITENG
	'Alic Imp. E'															, ; //X3_DESCRIC
	'Alic Imp. E'															, ; //X3_DESCSPA
	'Alic Imp. E'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'E2'																	, ; //X3_ORDEM
	'F3_BASIMPE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. E'															, ; //X3_TITULO
	'Base Imp. E'															, ; //X3_TITSPA
	'Base Imp. E'															, ; //X3_TITENG
	'Base Imp. E'															, ; //X3_DESCRIC
	'Base Imp. E'															, ; //X3_DESCSPA
	'Base Imp. E'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'E3'																	, ; //X3_ORDEM
	'F3_VALIMPF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. F'															, ; //X3_TITULO
	'Valor Imp. F'															, ; //X3_TITSPA
	'Valor Imp. F'															, ; //X3_TITENG
	'Valor Imp. F'															, ; //X3_DESCRIC
	'Valor Imp. F'															, ; //X3_DESCSPA
	'Valor Imp. F'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'E4'																	, ; //X3_ORDEM
	'F3_ALQIMPF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. F'															, ; //X3_TITULO
	'Alic Imp. F'															, ; //X3_TITSPA
	'Alic Imp. F'															, ; //X3_TITENG
	'Alic Imp. F'															, ; //X3_DESCRIC
	'Alic Imp. F'															, ; //X3_DESCSPA
	'Alic Imp. F'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'E5'																	, ; //X3_ORDEM
	'F3_BASIMPF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. F'															, ; //X3_TITULO
	'Base Imp. F'															, ; //X3_TITSPA
	'Base Imp. F'															, ; //X3_TITENG
	'Base Imp. F'															, ; //X3_DESCRIC
	'Base Imp. F'															, ; //X3_DESCSPA
	'Base Imp. F'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'E6'																	, ; //X3_ORDEM
	'F3_VALIMPG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. G'															, ; //X3_TITULO
	'Valor Imp. G'															, ; //X3_TITSPA
	'Valor Imp. G'															, ; //X3_TITENG
	'Valor Imp. G'															, ; //X3_DESCRIC
	'Valor Imp. G'															, ; //X3_DESCSPA
	'Valor Imp. G'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'E7'																	, ; //X3_ORDEM
	'F3_ALQIMPG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. G'															, ; //X3_TITULO
	'Alic Imp. G'															, ; //X3_TITSPA
	'Alic Imp. G'															, ; //X3_TITENG
	'Alic Imp. G'															, ; //X3_DESCRIC
	'Alic Imp. G'															, ; //X3_DESCSPA
	'Alic Imp. G'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'E8'																	, ; //X3_ORDEM
	'F3_BASIMPG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. G'															, ; //X3_TITULO
	'Base Imp. G'															, ; //X3_TITSPA
	'Base Imp. G'															, ; //X3_TITENG
	'Base Imp. G'															, ; //X3_DESCRIC
	'Base Imp. G'															, ; //X3_DESCSPA
	'Base Imp. G'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'E9'																	, ; //X3_ORDEM
	'F3_VALIMPJ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. J'															, ; //X3_TITULO
	'Valor Imp. J'															, ; //X3_TITSPA
	'Valor Imp. J'															, ; //X3_TITENG
	'Valor Imp. J'															, ; //X3_DESCRIC
	'Valor Imp. J'															, ; //X3_DESCSPA
	'Valor Imp. J'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'F0'																	, ; //X3_ORDEM
	'F3_ALQIMPJ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. J'															, ; //X3_TITULO
	'Alic Imp. J'															, ; //X3_TITSPA
	'Alic Imp. J'															, ; //X3_TITENG
	'Alic Imp. J'															, ; //X3_DESCRIC
	'Alic Imp. J'															, ; //X3_DESCSPA
	'Alic Imp. J'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'F1'																	, ; //X3_ORDEM
	'F3_BASIMPJ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. J'															, ; //X3_TITULO
	'Base Imp. J'															, ; //X3_TITSPA
	'Base Imp. J'															, ; //X3_TITENG
	'Base Imp. J'															, ; //X3_DESCRIC
	'Base Imp. J'															, ; //X3_DESCSPA
	'Base Imp. J'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'F2'																	, ; //X3_ORDEM
	'F3_VALIMPK'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. K'															, ; //X3_TITULO
	'Valor Imp. K'															, ; //X3_TITSPA
	'Valor Imp. K'															, ; //X3_TITENG
	'Valor Imp. K'															, ; //X3_DESCRIC
	'Valor Imp. K'															, ; //X3_DESCSPA
	'Valor Imp. K'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'F3'																	, ; //X3_ORDEM
	'F3_ALQIMPK'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. K'															, ; //X3_TITULO
	'Alic Imp. K'															, ; //X3_TITSPA
	'Alic Imp. K'															, ; //X3_TITENG
	'Alic Imp. K'															, ; //X3_DESCRIC
	'Alic Imp. K'															, ; //X3_DESCSPA
	'Alic Imp. K'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'F4'																	, ; //X3_ORDEM
	'F3_BASIMPK'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. K'															, ; //X3_TITULO
	'Base Imp. K'															, ; //X3_TITSPA
	'Base Imp. K'															, ; //X3_TITENG
	'Base Imp. K'															, ; //X3_DESCRIC
	'Base Imp. K'															, ; //X3_DESCSPA
	'Base Imp. K'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'F5'																	, ; //X3_ORDEM
	'F3_VALIMPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. L'															, ; //X3_TITULO
	'Valor Imp. L'															, ; //X3_TITSPA
	'Valor Imp. L'															, ; //X3_TITENG
	'Valor Imp. L'															, ; //X3_DESCRIC
	'Valor Imp. L'															, ; //X3_DESCSPA
	'Valor Imp. L'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'F6'																	, ; //X3_ORDEM
	'F3_ALQIMPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. L'															, ; //X3_TITULO
	'Alic Imp. L'															, ; //X3_TITSPA
	'Alic Imp. L'															, ; //X3_TITENG
	'Alic Imp. L'															, ; //X3_DESCRIC
	'Alic Imp. L'															, ; //X3_DESCSPA
	'Alic Imp. L'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'F7'																	, ; //X3_ORDEM
	'F3_BASIMPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. L'															, ; //X3_TITULO
	'Base Imp. L'															, ; //X3_TITSPA
	'Base Imp. L'															, ; //X3_TITENG
	'Base Imp. L'															, ; //X3_DESCRIC
	'Base Imp. L'															, ; //X3_DESCSPA
	'Base Imp. L'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'F8'																	, ; //X3_ORDEM
	'F3_VALIMPM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. M'															, ; //X3_TITULO
	'Valor Imp. M'															, ; //X3_TITSPA
	'Valor Imp. M'															, ; //X3_TITENG
	'Valor Imp. M'															, ; //X3_DESCRIC
	'Valor Imp. M'															, ; //X3_DESCSPA
	'Valor Imp. M'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'F9'																	, ; //X3_ORDEM
	'F3_ALQIMPM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. M'															, ; //X3_TITULO
	'Alic Imp. M'															, ; //X3_TITSPA
	'Alic Imp. M'															, ; //X3_TITENG
	'Alic Imp. M'															, ; //X3_DESCRIC
	'Alic Imp. M'															, ; //X3_DESCSPA
	'Alic Imp. M'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'G0'																	, ; //X3_ORDEM
	'F3_BASIMPM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. M'															, ; //X3_TITULO
	'Base Imp. M'															, ; //X3_TITSPA
	'Base Imp. M'															, ; //X3_TITENG
	'Base Imp. M'															, ; //X3_DESCRIC
	'Base Imp. M'															, ; //X3_DESCSPA
	'Base Imp. M'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'G1'																	, ; //X3_ORDEM
	'F3_VALIMPN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. N'															, ; //X3_TITULO
	'Valor Imp. N'															, ; //X3_TITSPA
	'Valor Imp. N'															, ; //X3_TITENG
	'Valor Imp. N'															, ; //X3_DESCRIC
	'Valor Imp. N'															, ; //X3_DESCSPA
	'Valor Imp. N'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'G2'																	, ; //X3_ORDEM
	'F3_ALQIMPN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. N'															, ; //X3_TITULO
	'Alic Imp. N'															, ; //X3_TITSPA
	'Alic Imp. N'															, ; //X3_TITENG
	'Alic Imp. N'															, ; //X3_DESCRIC
	'Alic Imp. N'															, ; //X3_DESCSPA
	'Alic Imp. N'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'G3'																	, ; //X3_ORDEM
	'F3_BASIMPN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. N'															, ; //X3_TITULO
	'Base Imp. N'															, ; //X3_TITSPA
	'Base Imp. N'															, ; //X3_TITENG
	'Base Imp. N'															, ; //X3_DESCRIC
	'Base Imp. N'															, ; //X3_DESCSPA
	'Base Imp. N'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'G4'																	, ; //X3_ORDEM
	'F3_VALIMPO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. O'															, ; //X3_TITULO
	'Valor Imp. O'															, ; //X3_TITSPA
	'Valor Imp. O'															, ; //X3_TITENG
	'Valor Imp. O'															, ; //X3_DESCRIC
	'Valor Imp. O'															, ; //X3_DESCSPA
	'Valor Imp. O'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'G5'																	, ; //X3_ORDEM
	'F3_ALQIMPO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. O'															, ; //X3_TITULO
	'Alic Imp. O'															, ; //X3_TITSPA
	'Alic Imp. O'															, ; //X3_TITENG
	'Alic Imp. O'															, ; //X3_DESCRIC
	'Alic Imp. O'															, ; //X3_DESCSPA
	'Alic Imp. O'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado				   													, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'G6'																	, ; //X3_ORDEM
	'F3_BASIMPO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. O'															, ; //X3_TITULO
	'Base Imp. O'															, ; //X3_TITSPA
	'Base Imp. O'															, ; //X3_TITENG
	'Base Imp. O'															, ; //X3_DESCRIC
	'Base Imp. O'															, ; //X3_DESCSPA
	'Base Imp. O'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'G7'																	, ; //X3_ORDEM
	'F3_VALIMPP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. P'															, ; //X3_TITULO
	'Valor Imp. P'															, ; //X3_TITSPA
	'Valor Imp. P'															, ; //X3_TITENG
	'Valor Imp. P'															, ; //X3_DESCRIC
	'Valor Imp. P'															, ; //X3_DESCSPA
	'Valor Imp. P'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'G8'																	, ; //X3_ORDEM
	'F3_ALQIMPP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. P'															, ; //X3_TITULO
	'Alic Imp. P'															, ; //X3_TITSPA
	'Alic Imp. P'															, ; //X3_TITENG
	'Alic Imp. P'															, ; //X3_DESCRIC
	'Alic Imp. P'															, ; //X3_DESCSPA
	'Alic Imp. P'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'G9'																	, ; //X3_ORDEM
	'F3_BASIMPP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. P'															, ; //X3_TITULO
	'Base Imp. P'															, ; //X3_TITSPA
	'Base Imp. P'															, ; //X3_TITENG
	'Base Imp. P'															, ; //X3_DESCRIC
	'Base Imp. P'															, ; //X3_DESCSPA
	'Base Imp. P'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado				   													, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'H0'																	, ; //X3_ORDEM
	'F3_VALIMPQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. Q'															, ; //X3_TITULO
	'Valor Imp. Q'															, ; //X3_TITSPA
	'Valor Imp. Q'															, ; //X3_TITENG
	'Valor Imp. Q'															, ; //X3_DESCRIC
	'Valor Imp. Q'															, ; //X3_DESCSPA
	'Valor Imp. Q'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'H1'																	, ; //X3_ORDEM
	'F3_ALQIMPQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. Q'															, ; //X3_TITULO
	'Alic Imp. Q'															, ; //X3_TITSPA
	'Alic Imp. Q'															, ; //X3_TITENG
	'Alic Imp. Q'															, ; //X3_DESCRIC
	'Alic Imp. Q'															, ; //X3_DESCSPA
	'Alic Imp. Q'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'H2'																	, ; //X3_ORDEM
	'F3_BASIMPQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. Q'															, ; //X3_TITULO
	'Base Imp. Q'															, ; //X3_TITSPA
	'Base Imp. Q'															, ; //X3_TITENG
	'Base Imp. Q'															, ; //X3_DESCRIC
	'Base Imp. Q'															, ; //X3_DESCSPA
	'Base Imp. Q'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'H3'																	, ; //X3_ORDEM
	'F3_VALIMPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. R'															, ; //X3_TITULO
	'Valor Imp. R'															, ; //X3_TITSPA
	'Valor Imp. R'															, ; //X3_TITENG
	'Valor Imp. R'															, ; //X3_DESCRIC
	'Valor Imp. R'															, ; //X3_DESCSPA
	'Valor Imp. R'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'H4'																	, ; //X3_ORDEM
	'F3_ALQIMPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. R'															, ; //X3_TITULO
	'Alic Imp. R'															, ; //X3_TITSPA
	'Alic Imp. R'															, ; //X3_TITENG
	'Alic Imp. R'															, ; //X3_DESCRIC
	'Alic Imp. R'															, ; //X3_DESCSPA
	'Alic Imp. R'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'H5'																	, ; //X3_ORDEM
	'F3_BASIMPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. R'															, ; //X3_TITULO
	'Base Imp. R'															, ; //X3_TITSPA
	'Base Imp. R'															, ; //X3_TITENG
	'Base Imp. R'															, ; //X3_DESCRIC
	'Base Imp. R'															, ; //X3_DESCSPA
	'Base Imp. R'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'H6'																	, ; //X3_ORDEM
	'F3_VALIMPS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. S'															, ; //X3_TITULO
	'Valor Imp. S'															, ; //X3_TITSPA
	'Valor Imp. S'															, ; //X3_TITENG
	'Valor Imp. S'															, ; //X3_DESCRIC
	'Valor Imp. S'															, ; //X3_DESCSPA
	'Valor Imp. S'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'H7'																	, ; //X3_ORDEM
	'F3_ALQIMPS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. S'															, ; //X3_TITULO
	'Alic Imp. S'															, ; //X3_TITSPA
	'Alic Imp. S'															, ; //X3_TITENG
	'Alic Imp. S'															, ; //X3_DESCRIC
	'Alic Imp. S'															, ; //X3_DESCSPA
	'Alic Imp. S'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'H8'																	, ; //X3_ORDEM
	'F3_BASIMPS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. S'															, ; //X3_TITULO
	'Base Imp. S'															, ; //X3_TITSPA
	'Base Imp. S'															, ; //X3_TITENG
	'Base Imp. S'															, ; //X3_DESCRIC
	'Base Imp. S'															, ; //X3_DESCSPA
	'Base Imp. S'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'H9'																	, ; //X3_ORDEM
	'F3_VALIMPT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. T'															, ; //X3_TITULO
	'Valor Imp. T'															, ; //X3_TITSPA
	'Valor Imp. T'															, ; //X3_TITENG
	'Valor Imp. T'															, ; //X3_DESCRIC
	'Valor Imp. T'															, ; //X3_DESCSPA
	'Valor Imp. T'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'I0'																	, ; //X3_ORDEM
	'F3_ALQIMPT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. T'															, ; //X3_TITULO
	'Alic Imp. T'															, ; //X3_TITSPA
	'Alic Imp. T'															, ; //X3_TITENG
	'Alic Imp. T'															, ; //X3_DESCRIC
	'Alic Imp. T'															, ; //X3_DESCSPA
	'Alic Imp. T'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'I1'																	, ; //X3_ORDEM
	'F3_BASIMPT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. T'															, ; //X3_TITULO
	'Base Imp. T'															, ; //X3_TITSPA
	'Base Imp. T'															, ; //X3_TITENG
	'Base Imp. T'															, ; //X3_DESCRIC
	'Base Imp. T'															, ; //X3_DESCSPA
	'Base Imp. T'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'I2'																	, ; //X3_ORDEM
	'F3_VALIMPU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Valor Imp. U'															, ; //X3_TITULO
	'Valor Imp. U'															, ; //X3_TITSPA
	'Valor Imp. U'															, ; //X3_TITENG
	'Valor Imp. U'															, ; //X3_DESCRIC
	'Valor Imp. U'															, ; //X3_DESCSPA
	'Valor Imp. U'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'I3'																	, ; //X3_ORDEM
	'F3_ALQIMPU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. U'															, ; //X3_TITULO
	'Alic Imp. U'															, ; //X3_TITSPA
	'Alic Imp. U'															, ; //X3_TITENG
	'Alic Imp. U'															, ; //X3_DESCRIC
	'Alic Imp. U'															, ; //X3_DESCSPA
	'Alic Imp. U'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'I4'																	, ; //X3_ORDEM
	'F3_BASIMPU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. U'															, ; //X3_TITULO
	'Base Imp. U'															, ; //X3_TITSPA
	'Base Imp. U'															, ; //X3_TITENG
	'Base Imp. U'															, ; //X3_DESCRIC
	'Base Imp. U'															, ; //X3_DESCSPA
	'Base Imp. U'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'I5'																	, ; //X3_ORDEM
	'F3_VALIMPV'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. V'															, ; //X3_TITULO
	'Valor Imp. V'															, ; //X3_TITSPA
	'Valor Imp. V'															, ; //X3_TITENG
	'Valor Imp. V'															, ; //X3_DESCRIC
	'Valor Imp. V'															, ; //X3_DESCSPA
	'Valor Imp. V'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'I6'																	, ; //X3_ORDEM
	'F3_ALQIMPV'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. V'															, ; //X3_TITULO
	'Alic Imp. V'															, ; //X3_TITSPA
	'Alic Imp. V'															, ; //X3_TITENG
	'Alic Imp. V'															, ; //X3_DESCRIC
	'Alic Imp. V'															, ; //X3_DESCSPA
	'Alic Imp. V'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'I7'																	, ; //X3_ORDEM
	'F3_BASIMPV'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. V'															, ; //X3_TITULO
	'Base Imp. V'															, ; //X3_TITSPA
	'Base Imp. V'															, ; //X3_TITENG
	'Base Imp. V'															, ; //X3_DESCRIC
	'Base Imp. V'															, ; //X3_DESCSPA
	'Base Imp. V'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'I8'																	, ; //X3_ORDEM
	'F3_VALIMPW'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. W'															, ; //X3_TITULO
	'Valor Imp. W'															, ; //X3_TITSPA
	'Valor Imp. W'															, ; //X3_TITENG
	'Valor Imp. W'															, ; //X3_DESCRIC
	'Valor Imp. W'															, ; //X3_DESCSPA
	'Valor Imp. W'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'I9'																	, ; //X3_ORDEM
	'F3_BASIMPW'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. W'															, ; //X3_TITULO
	'Base Imp. W'															, ; //X3_TITSPA
	'Base Imp. W'															, ; //X3_TITENG
	'Base Imp. W'															, ; //X3_DESCRIC
	'Base Imp. W'															, ; //X3_DESCSPA
	'Base Imp. W'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'J0'																	, ; //X3_ORDEM
	'F3_ALQIMPW'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. W'															, ; //X3_TITULO
	'Alic Imp. W'															, ; //X3_TITSPA
	'Alic Imp. W'															, ; //X3_TITENG
	'Alic Imp. W'															, ; //X3_DESCRIC
	'Alic Imp. W'															, ; //X3_DESCSPA
	'Alic Imp. W'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'J1'																	, ; //X3_ORDEM
	'F3_VALIMPX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. X'															, ; //X3_TITULO
	'Valor Imp. X'															, ; //X3_TITSPA
	'Valor Imp. X'															, ; //X3_TITENG
	'Valor Imp. X'															, ; //X3_DESCRIC
	'Valor Imp. X'															, ; //X3_DESCSPA
	'Valor Imp. X'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'J2'																	, ; //X3_ORDEM
	'F3_BASIMPX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. X'															, ; //X3_TITULO
	'Base Imp. X'															, ; //X3_TITSPA
	'Base Imp. X'															, ; //X3_TITENG
	'Base Imp. X'															, ; //X3_DESCRIC
	'Base Imp. X'															, ; //X3_DESCSPA
	'Base Imp. X'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'J3'																	, ; //X3_ORDEM
	'F3_ALQIMPX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. X'															, ; //X3_TITULO
	'Alic Imp. X'															, ; //X3_TITSPA
	'Alic Imp. X'															, ; //X3_TITENG
	'Alic Imp. X'															, ; //X3_DESCRIC
	'Alic Imp. X'															, ; //X3_DESCSPA
	'Alic Imp. X'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'J4'																	, ; //X3_ORDEM
	'F3_VALIMPY'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. Y'															, ; //X3_TITULO
	'Valor Imp. Y'															, ; //X3_TITSPA
	'Valor Imp. Y'															, ; //X3_TITENG
	'Valor Imp. Y'															, ; //X3_DESCRIC
	'Valor Imp. Y'															, ; //X3_DESCSPA
	'Valor Imp. Y'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'J5'																	, ; //X3_ORDEM
	'F3_BASIMPY'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. Y'															, ; //X3_TITULO
	'Base Imp. Y'															, ; //X3_TITSPA
	'Base Imp. Y'															, ; //X3_TITENG
	'Base Imp. Y'															, ; //X3_DESCRIC
	'Base Imp. Y'															, ; //X3_DESCSPA
	'Base Imp. Y'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SF3'																	, ; //X3_ARQUIVO
	'J6'																	, ; //X3_ORDEM
	'F3_ALQIMPY'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. Y'															, ; //X3_TITULO
	'Alic Imp. Y'															, ; //X3_TITSPA
	'Alic Imp. Y'															, ; //X3_TITENG
	'Alic Imp. Y'															, ; //X3_DESCRIC
	'Alic Imp. Y'															, ; //X3_DESCSPA
	'Alic Imp. Y'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	''																		, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

// ..........
// Tabela sc7
// ..........


aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'G7'																	, ; //X3_ORDEM
	'C7_VALIMPA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. A'															, ; //X3_TITULO
	'Valor Imp. A'															, ; //X3_TITSPA
	'Valor Imp. A'															, ; //X3_TITENG
	'Valor Imp. A'															, ; //X3_DESCRIC
	'Valor Imp. A'															, ; //X3_DESCSPA
	'Valor Imp. A'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVA","MT120",M->C7_VALIMPA)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'G8'																	, ; //X3_ORDEM
	'C7_ALQIMPA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. A'															, ; //X3_TITULO
	'Alic Imp. A'															, ; //X3_TITSPA
	'Alic Imp. A'															, ; //X3_TITENG
	'Alic Imp. A'															, ; //X3_DESCRIC
	'Alic Imp. A'															, ; //X3_DESCSPA
	'Alic Imp. A'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVA","MT120",M->C7_ALQIMPA)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'G9'																	, ; //X3_ORDEM
	'C7_BASIMPA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. A'															, ; //X3_TITULO
	'Base Imp. A'															, ; //X3_TITSPA
	'Base Imp. A'															, ; //X3_TITENG
	'Base Imp. A'															, ; //X3_DESCRIC
	'Base Imp. A'															, ; //X3_DESCSPA
	'Base Imp. A'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVA","MT120",M->C7_BASIMPA)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'H0'																	, ; //X3_ORDEM
	'C7_VALIMPB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. B'															, ; //X3_TITULO
	'Valor Imp. B'															, ; //X3_TITSPA
	'Valor Imp. B'															, ; //X3_TITENG
	'Valor Imp. B'															, ; //X3_DESCRIC
	'Valor Imp. B'															, ; //X3_DESCSPA
	'Valor Imp. B'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVB","MT120",M->C7_VALIMPB)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'H1'																	, ; //X3_ORDEM
	'C7_ALQIMPB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. B'															, ; //X3_TITULO
	'Alic Imp. B'															, ; //X3_TITSPA
	'Alic Imp. B'															, ; //X3_TITENG
	'Alic Imp. B'															, ; //X3_DESCRIC
	'Alic Imp. B'															, ; //X3_DESCSPA
	'Alic Imp. B'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVB","MT120",M->C7_ALQIMPB)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'H2'																	, ; //X3_ORDEM
	'C7_BASIMPB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. B'															, ; //X3_TITULO
	'Base Imp. B'															, ; //X3_TITSPA
	'Base Imp. B'															, ; //X3_TITENG
	'Base Imp. B'															, ; //X3_DESCRIC
	'Base Imp. B'															, ; //X3_DESCSPA
	'Base Imp. B'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVB","MT120",M->C7_BASIMPB)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'H3'																	, ; //X3_ORDEM
	'C7_VALIMPC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. C'															, ; //X3_TITULO
	'Valor Imp. C'															, ; //X3_TITSPA
	'Valor Imp. C'															, ; //X3_TITENG
	'Valor Imp. C'															, ; //X3_DESCRIC
	'Valor Imp. C'															, ; //X3_DESCSPA
	'Valor Imp. C'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVC","MT120",M->C7_VALIMPC)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'H4'																	, ; //X3_ORDEM
	'C7_ALQIMPC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. C'															, ; //X3_TITULO
	'Alic Imp. C'															, ; //X3_TITSPA
	'Alic Imp. C'															, ; //X3_TITENG
	'Alic Imp. C'															, ; //X3_DESCRIC
	'Alic Imp. C'															, ; //X3_DESCSPA
	'Alic Imp. C'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVC","MT120",M->C7_ALQIMPC)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'H5'																	, ; //X3_ORDEM
	'C7_BASIMPC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. C'															, ; //X3_TITULO
	'Base Imp. C'															, ; //X3_TITSPA
	'Base Imp. C'															, ; //X3_TITENG
	'Base Imp. C'															, ; //X3_DESCRIC
	'Base Imp. C'															, ; //X3_DESCSPA
	'Base Imp. C'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVC","MT120",M->C7_BASIMPC)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'H6'																	, ; //X3_ORDEM
	'C7_VALIMPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. D'															, ; //X3_TITULO
	'Valor Imp. D'															, ; //X3_TITSPA
	'Valor Imp. D'															, ; //X3_TITENG
	'Valor Imp. D'															, ; //X3_DESCRIC
	'Valor Imp. D'															, ; //X3_DESCSPA
	'Valor Imp. D'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVD","MT120",M->C7_VALIMPD)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'H7'																	, ; //X3_ORDEM
	'C7_ALQIMPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. D'															, ; //X3_TITULO
	'Alic Imp. D'															, ; //X3_TITSPA
	'Alic Imp. D'															, ; //X3_TITENG
	'Alic Imp. D'															, ; //X3_DESCRIC
	'Alic Imp. D'															, ; //X3_DESCSPA
	'Alic Imp. D'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVD","MT120",M->C7_ALQIMPD)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'H8'																	, ; //X3_ORDEM
	'C7_BASIMPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. D'															, ; //X3_TITULO
	'Base Imp. D'															, ; //X3_TITSPA
	'Base Imp. D'															, ; //X3_TITENG
	'Base Imp. D'															, ; //X3_DESCRIC
	'Base Imp. D'															, ; //X3_DESCSPA
	'Base Imp. D'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVD","MT120",M->C7_BASIMPD)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'I0'																	, ; //X3_ORDEM
	'C7_VALIMPE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. E'															, ; //X3_TITULO
	'Valor Imp. E'															, ; //X3_TITSPA
	'Valor Imp. E'															, ; //X3_TITENG
	'Valor Imp. E'															, ; //X3_DESCRIC
	'Valor Imp. E'															, ; //X3_DESCSPA
	'Valor Imp. E'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVE","MT120",M->C7_VALIMPE)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'I1'																	, ; //X3_ORDEM
	'C7_ALQIMPE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. E'															, ; //X3_TITULO
	'Alic Imp. E'															, ; //X3_TITSPA
	'Alic Imp. E'															, ; //X3_TITENG
	'Alic Imp. E'															, ; //X3_DESCRIC
	'Alic Imp. E'															, ; //X3_DESCSPA
	'Alic Imp. E'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVE","MT120",M->C7_ALQIMPE)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'I2'																	, ; //X3_ORDEM
	'C7_BASIMPE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. E'															, ; //X3_TITULO
	'Base Imp. E'															, ; //X3_TITSPA
	'Base Imp. E'															, ; //X3_TITENG
	'Base Imp. E'															, ; //X3_DESCRIC
	'Base Imp. E'															, ; //X3_DESCSPA
	'Base Imp. E'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVE","MT120",M->C7_BASIMPE)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'I3'																	, ; //X3_ORDEM
	'C7_VALIMPF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. F'															, ; //X3_TITULO
	'Valor Imp. F'															, ; //X3_TITSPA
	'Valor Imp. F'															, ; //X3_TITENG
	'Valor Imp. F'															, ; //X3_DESCRIC
	'Valor Imp. F'															, ; //X3_DESCSPA
	'Valor Imp. F'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE               
	'MaFisRef("IT_VALIVF","MT120",M->C7_VALIMPF)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'I4'																	, ; //X3_ORDEM
	'C7_ALQIMPF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. F'															, ; //X3_TITULO
	'Alic Imp. F'															, ; //X3_TITSPA
	'Alic Imp. F'															, ; //X3_TITENG
	'Alic Imp. F'															, ; //X3_DESCRIC
	'Alic Imp. F'															, ; //X3_DESCSPA
	'Alic Imp. F'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVF","MT120",M->C7_ALQIMPF)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'I5'																	, ; //X3_ORDEM
	'C7_BASIMPF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. F'															, ; //X3_TITULO
	'Base Imp. F'															, ; //X3_TITSPA
	'Base Imp. F'															, ; //X3_TITENG
	'Base Imp. F'															, ; //X3_DESCRIC
	'Base Imp. F'															, ; //X3_DESCSPA
	'Base Imp. F'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVF","MT120",M->C7_BASIMPF)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'I6'																	, ; //X3_ORDEM
	'C7_VALIMPG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. G'															, ; //X3_TITULO
	'Valor Imp. G'															, ; //X3_TITSPA
	'Valor Imp. G'															, ; //X3_TITENG
	'Valor Imp. G'															, ; //X3_DESCRIC
	'Valor Imp. G'															, ; //X3_DESCSPA
	'Valor Imp. G'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVG","MT120",M->C7_VALIMPG)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'I7'																	, ; //X3_ORDEM
	'C7_ALQIMPG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. G'															, ; //X3_TITULO
	'Alic Imp. G'															, ; //X3_TITSPA
	'Alic Imp. G'															, ; //X3_TITENG
	'Alic Imp. G'															, ; //X3_DESCRIC
	'Alic Imp. G'															, ; //X3_DESCSPA
	'Alic Imp. G'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVG","MT120",M->C7_ALQIMPG)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'I8'																	, ; //X3_ORDEM
	'C7_BASIMPG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. G'															, ; //X3_TITULO
	'Base Imp. G'															, ; //X3_TITSPA
	'Base Imp. G'															, ; //X3_TITENG
	'Base Imp. G'															, ; //X3_DESCRIC
	'Base Imp. G'															, ; //X3_DESCSPA
	'Base Imp. G'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVG","MT120",M->C7_BASIMPG)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'I9'																	, ; //X3_ORDEM
	'C7_VALIMPJ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. J'															, ; //X3_TITULO
	'Valor Imp. J'															, ; //X3_TITSPA
	'Valor Imp. J'															, ; //X3_TITENG
	'Valor Imp. J'															, ; //X3_DESCRIC
	'Valor Imp. J'															, ; //X3_DESCSPA
	'Valor Imp. J'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVJ","MT120",M->C7_VALIMPJ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'J0'																	, ; //X3_ORDEM
	'C7_ALQIMPJ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. J'															, ; //X3_TITULO
	'Alic Imp. J'															, ; //X3_TITSPA
	'Alic Imp. J'															, ; //X3_TITENG
	'Alic Imp. J'															, ; //X3_DESCRIC
	'Alic Imp. J'															, ; //X3_DESCSPA
	'Alic Imp. J'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVJ","MT120",M->C7_ALQIMPJ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'J1'																	, ; //X3_ORDEM
	'C7_BASIMPJ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. J'															, ; //X3_TITULO
	'Base Imp. J'															, ; //X3_TITSPA
	'Base Imp. J'															, ; //X3_TITENG
	'Base Imp. J'															, ; //X3_DESCRIC
	'Base Imp. J'															, ; //X3_DESCSPA
	'Base Imp. J'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVJ","MT120",M->C7_BASIMPJ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'J2'																	, ; //X3_ORDEM
	'C7_VALIMPK'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. K'															, ; //X3_TITULO
	'Valor Imp. K'															, ; //X3_TITSPA
	'Valor Imp. K'															, ; //X3_TITENG
	'Valor Imp. K'															, ; //X3_DESCRIC
	'Valor Imp. K'															, ; //X3_DESCSPA
	'Valor Imp. K'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVK","MT120",M->C7_VALIMPK)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'J3'																	, ; //X3_ORDEM
	'C7_ALQIMPK'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. K'															, ; //X3_TITULO
	'Alic Imp. K'															, ; //X3_TITSPA
	'Alic Imp. K'															, ; //X3_TITENG
	'Alic Imp. K'															, ; //X3_DESCRIC
	'Alic Imp. K'															, ; //X3_DESCSPA
	'Alic Imp. K'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVK","MT120",M->C7_ALQIMPK)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'J4'																	, ; //X3_ORDEM
	'C7_BASIMPK'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. K'															, ; //X3_TITULO
	'Base Imp. K'															, ; //X3_TITSPA
	'Base Imp. K'															, ; //X3_TITENG
	'Base Imp. K'															, ; //X3_DESCRIC
	'Base Imp. K'															, ; //X3_DESCSPA
	'Base Imp. K'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVK","MT120",M->C7_BASIMPK)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'J5'																	, ; //X3_ORDEM
	'C7_VALIMPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. L'															, ; //X3_TITULO
	'Valor Imp. L'															, ; //X3_TITSPA
	'Valor Imp. L'															, ; //X3_TITENG
	'Valor Imp. L'															, ; //X3_DESCRIC
	'Valor Imp. L'															, ; //X3_DESCSPA
	'Valor Imp. L'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVL","MT120",M->C7_VALIMPL)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'J6'																	, ; //X3_ORDEM
	'C7_ALQIMPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. L'															, ; //X3_TITULO
	'Alic Imp. L'															, ; //X3_TITSPA
	'Alic Imp. L'															, ; //X3_TITENG
	'Alic Imp. L'															, ; //X3_DESCRIC
	'Alic Imp. L'															, ; //X3_DESCSPA
	'Alic Imp. L'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVL","MT120",M->C7_ALQIMPL)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'J7'																	, ; //X3_ORDEM
	'C7_BASIMPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. L'															, ; //X3_TITULO
	'Base Imp. L'															, ; //X3_TITSPA
	'Base Imp. L'															, ; //X3_TITENG
	'Base Imp. L'															, ; //X3_DESCRIC
	'Base Imp. L'															, ; //X3_DESCSPA
	'Base Imp. L'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVL","MT120",M->C7_BASIMPL)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'J8'																	, ; //X3_ORDEM
	'C7_VALIMPM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. M'															, ; //X3_TITULO
	'Valor Imp. M'															, ; //X3_TITSPA
	'Valor Imp. M'															, ; //X3_TITENG
	'Valor Imp. M'															, ; //X3_DESCRIC
	'Valor Imp. M'															, ; //X3_DESCSPA
	'Valor Imp. M'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVM","MT120",M->C7_VALIMPM)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'J9'																	, ; //X3_ORDEM
	'C7_ALQIMPM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. M'															, ; //X3_TITULO
	'Alic Imp. M'															, ; //X3_TITSPA
	'Alic Imp. M'															, ; //X3_TITENG
	'Alic Imp. M'															, ; //X3_DESCRIC
	'Alic Imp. M'															, ; //X3_DESCSPA
	'Alic Imp. M'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVM","MT120",M->C7_ALQIMPM)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'K0'																	, ; //X3_ORDEM
	'C7_BASIMPM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. M'															, ; //X3_TITULO
	'Base Imp. M'															, ; //X3_TITSPA
	'Base Imp. M'															, ; //X3_TITENG
	'Base Imp. M'															, ; //X3_DESCRIC
	'Base Imp. M'															, ; //X3_DESCSPA
	'Base Imp. M'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVM","MT120",M->C7_BASIMPM)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'K1'																	, ; //X3_ORDEM
	'C7_VALIMPN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. N'															, ; //X3_TITULO
	'Valor Imp. N'															, ; //X3_TITSPA
	'Valor Imp. N'															, ; //X3_TITENG
	'Valor Imp. N'															, ; //X3_DESCRIC
	'Valor Imp. N'															, ; //X3_DESCSPA
	'Valor Imp. N'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVN","MT120",M->C7_VALIMPN)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'K2'																	, ; //X3_ORDEM
	'C7_ALQIMPN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. N'															, ; //X3_TITULO
	'Alic Imp. N'															, ; //X3_TITSPA
	'Alic Imp. N'															, ; //X3_TITENG
	'Alic Imp. N'															, ; //X3_DESCRIC
	'Alic Imp. N'															, ; //X3_DESCSPA
	'Alic Imp. N'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVN","MT120",M->C7_ALQIMPN)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'K3'																	, ; //X3_ORDEM
	'C7_BASIMPN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. N'															, ; //X3_TITULO
	'Base Imp. N'															, ; //X3_TITSPA
	'Base Imp. N'															, ; //X3_TITENG
	'Base Imp. N'															, ; //X3_DESCRIC
	'Base Imp. N'															, ; //X3_DESCSPA
	'Base Imp. N'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVN","MT120",M->C7_BASIMPN)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'K4'																	, ; //X3_ORDEM
	'C7_VALIMPO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. O'															, ; //X3_TITULO
	'Valor Imp. O'															, ; //X3_TITSPA
	'Valor Imp. O'															, ; //X3_TITENG
	'Valor Imp. O'															, ; //X3_DESCRIC
	'Valor Imp. O'															, ; //X3_DESCSPA
	'Valor Imp. O'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVO","MT120",M->C7_VALIMPO)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'K5'																	, ; //X3_ORDEM
	'C7_ALQIMPO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. O'															, ; //X3_TITULO
	'Alic Imp. O'															, ; //X3_TITSPA
	'Alic Imp. O'															, ; //X3_TITENG
	'Alic Imp. O'															, ; //X3_DESCRIC
	'Alic Imp. O'															, ; //X3_DESCSPA
	'Alic Imp. O'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVO","MT120",M->C7_ALQIMPO)'							, ; //X3_VALID
	cUsado				   													, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'K6'																	, ; //X3_ORDEM
	'C7_BASIMPO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. O'															, ; //X3_TITULO
	'Base Imp. O'															, ; //X3_TITSPA
	'Base Imp. O'															, ; //X3_TITENG
	'Base Imp. O'															, ; //X3_DESCRIC
	'Base Imp. O'															, ; //X3_DESCSPA
	'Base Imp. O'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVO","MT120",M->C7_BASIMPO)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'K7'																	, ; //X3_ORDEM
	'C7_VALIMPP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. P'															, ; //X3_TITULO
	'Valor Imp. P'															, ; //X3_TITSPA
	'Valor Imp. P'															, ; //X3_TITENG
	'Valor Imp. P'															, ; //X3_DESCRIC
	'Valor Imp. P'															, ; //X3_DESCSPA
	'Valor Imp. P'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVP","MT120",M->C7_VALIMPP)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'K8'																	, ; //X3_ORDEM
	'C7_ALQIMPP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. P'															, ; //X3_TITULO
	'Alic Imp. P'															, ; //X3_TITSPA
	'Alic Imp. P'															, ; //X3_TITENG
	'Alic Imp. P'															, ; //X3_DESCRIC
	'Alic Imp. P'															, ; //X3_DESCSPA
	'Alic Imp. P'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVP","MT120",M->C7_ALQIMPP)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'K9'																	, ; //X3_ORDEM
	'C7_BASIMPP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. P'															, ; //X3_TITULO
	'Base Imp. P'															, ; //X3_TITSPA
	'Base Imp. P'															, ; //X3_TITENG
	'Base Imp. P'															, ; //X3_DESCRIC
	'Base Imp. P'															, ; //X3_DESCSPA
	'Base Imp. P'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVP","MT120",M->C7_BASIMPP)'							, ; //X3_VALID
	cUsado				   													, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'L0'																	, ; //X3_ORDEM
	'C7_VALIMPQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. Q'															, ; //X3_TITULO
	'Valor Imp. Q'															, ; //X3_TITSPA
	'Valor Imp. Q'															, ; //X3_TITENG
	'Valor Imp. Q'															, ; //X3_DESCRIC
	'Valor Imp. Q'															, ; //X3_DESCSPA
	'Valor Imp. Q'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVQ","MT120",M->C7_VALIMPQ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'L1'																	, ; //X3_ORDEM
	'C7_ALQIMPQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. Q'															, ; //X3_TITULO
	'Alic Imp. Q'															, ; //X3_TITSPA
	'Alic Imp. Q'															, ; //X3_TITENG
	'Alic Imp. Q'															, ; //X3_DESCRIC
	'Alic Imp. Q'															, ; //X3_DESCSPA
	'Alic Imp. Q'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVQ","MT120",M->C7_ALQIMPQ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'L2'																	, ; //X3_ORDEM
	'C7_BASIMPQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. Q'															, ; //X3_TITULO
	'Base Imp. Q'															, ; //X3_TITSPA
	'Base Imp. Q'															, ; //X3_TITENG
	'Base Imp. Q'															, ; //X3_DESCRIC
	'Base Imp. Q'															, ; //X3_DESCSPA
	'Base Imp. Q'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVQ","MT120",M->C7_BASIMPQ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'L3'																	, ; //X3_ORDEM
	'C7_VALIMPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. R'															, ; //X3_TITULO
	'Valor Imp. R'															, ; //X3_TITSPA
	'Valor Imp. R'															, ; //X3_TITENG
	'Valor Imp. R'															, ; //X3_DESCRIC
	'Valor Imp. R'															, ; //X3_DESCSPA
	'Valor Imp. R'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVR","MT120",M->C7_VALIMPR)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'L4'																	, ; //X3_ORDEM
	'C7_ALQIMPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. R'															, ; //X3_TITULO
	'Alic Imp. R'															, ; //X3_TITSPA
	'Alic Imp. R'															, ; //X3_TITENG
	'Alic Imp. R'															, ; //X3_DESCRIC
	'Alic Imp. R'															, ; //X3_DESCSPA
	'Alic Imp. R'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVR","MT120",M->C7_ALQIMPR)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'L5'																	, ; //X3_ORDEM
	'C7_BASIMPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. R'															, ; //X3_TITULO
	'Base Imp. R'															, ; //X3_TITSPA
	'Base Imp. R'															, ; //X3_TITENG
	'Base Imp. R'															, ; //X3_DESCRIC
	'Base Imp. R'															, ; //X3_DESCSPA
	'Base Imp. R'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVR","MT120",M->C7_BASIMPR)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'L6'																	, ; //X3_ORDEM
	'C7_VALIMPS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. S'															, ; //X3_TITULO
	'Valor Imp. S'															, ; //X3_TITSPA
	'Valor Imp. S'															, ; //X3_TITENG
	'Valor Imp. S'															, ; //X3_DESCRIC
	'Valor Imp. S'															, ; //X3_DESCSPA
	'Valor Imp. S'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVS","MT120",M->C7_VALIMPS)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'L7'																	, ; //X3_ORDEM
	'C7_ALQIMPS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. S'															, ; //X3_TITULO
	'Alic Imp. S'															, ; //X3_TITSPA
	'Alic Imp. S'															, ; //X3_TITENG
	'Alic Imp. S'															, ; //X3_DESCRIC
	'Alic Imp. S'															, ; //X3_DESCSPA
	'Alic Imp. S'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVS","MT120",M->C7_ALQIMPS)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'L8'																	, ; //X3_ORDEM
	'C7_BASIMPS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. S'															, ; //X3_TITULO
	'Base Imp. S'															, ; //X3_TITSPA
	'Base Imp. S'															, ; //X3_TITENG
	'Base Imp. S'															, ; //X3_DESCRIC
	'Base Imp. S'															, ; //X3_DESCSPA
	'Base Imp. S'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVS","MT120",M->C7_BASIMPS)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'L9'																	, ; //X3_ORDEM
	'C7_VALIMPT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. T'															, ; //X3_TITULO
	'Valor Imp. T'															, ; //X3_TITSPA
	'Valor Imp. T'															, ; //X3_TITENG
	'Valor Imp. T'															, ; //X3_DESCRIC
	'Valor Imp. T'															, ; //X3_DESCSPA
	'Valor Imp. T'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVT","MT120",M->C7_VALIMPT)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'M0'																	, ; //X3_ORDEM
	'C7_ALQIMPT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. T'															, ; //X3_TITULO
	'Alic Imp. T'															, ; //X3_TITSPA
	'Alic Imp. T'															, ; //X3_TITENG
	'Alic Imp. T'															, ; //X3_DESCRIC
	'Alic Imp. T'															, ; //X3_DESCSPA
	'Alic Imp. T'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVT","MT120",M->C7_ALQIMPT)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'M1'																	, ; //X3_ORDEM
	'C7_BASIMPT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. T'															, ; //X3_TITULO
	'Base Imp. T'															, ; //X3_TITSPA
	'Base Imp. T'															, ; //X3_TITENG
	'Base Imp. T'															, ; //X3_DESCRIC
	'Base Imp. T'															, ; //X3_DESCSPA
	'Base Imp. T'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVT","MT120",M->C7_BASIMPT)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'M2'																	, ; //X3_ORDEM
	'C7_VALIMPU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Valor Imp. U'															, ; //X3_TITULO
	'Valor Imp. U'															, ; //X3_TITSPA
	'Valor Imp. U'															, ; //X3_TITENG
	'Valor Imp. U'															, ; //X3_DESCRIC
	'Valor Imp. U'															, ; //X3_DESCSPA
	'Valor Imp. U'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVU","MT120",M->C7_VALIMPU)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'M3'																	, ; //X3_ORDEM
	'C7_ALQIMPU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. U'															, ; //X3_TITULO
	'Alic Imp. U'															, ; //X3_TITSPA
	'Alic Imp. U'															, ; //X3_TITENG
	'Alic Imp. U'															, ; //X3_DESCRIC
	'Alic Imp. U'															, ; //X3_DESCSPA
	'Alic Imp. U'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVU","MT120",M->C7_ALQIMPU)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'M4'																	, ; //X3_ORDEM
	'C7_BASIMPU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. U'															, ; //X3_TITULO
	'Base Imp. U'															, ; //X3_TITSPA
	'Base Imp. U'															, ; //X3_TITENG
	'Base Imp. U'															, ; //X3_DESCRIC
	'Base Imp. U'															, ; //X3_DESCSPA
	'Base Imp. U'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVU","MT120",M->C7_BASIMPU)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'M5'																	, ; //X3_ORDEM
	'C7_VALIMPV'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. V'															, ; //X3_TITULO
	'Valor Imp. V'															, ; //X3_TITSPA
	'Valor Imp. V'															, ; //X3_TITENG
	'Valor Imp. V'															, ; //X3_DESCRIC
	'Valor Imp. V'															, ; //X3_DESCSPA
	'Valor Imp. V'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVV","MT120",M->C7_VALIMPV)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'M6'																	, ; //X3_ORDEM
	'C7_ALQIMPV'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. V'															, ; //X3_TITULO
	'Alic Imp. V'															, ; //X3_TITSPA
	'Alic Imp. V'															, ; //X3_TITENG
	'Alic Imp. V'															, ; //X3_DESCRIC
	'Alic Imp. V'															, ; //X3_DESCSPA
	'Alic Imp. V'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVV","MT120",M->C7_ALQIMPV)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'M7'																	, ; //X3_ORDEM
	'C7_BASIMPV'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. V'															, ; //X3_TITULO
	'Base Imp. V'															, ; //X3_TITSPA
	'Base Imp. V'															, ; //X3_TITENG
	'Base Imp. V'															, ; //X3_DESCRIC
	'Base Imp. V'															, ; //X3_DESCSPA
	'Base Imp. V'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVV","MT120",M->C7_BASIMPV)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'M8'																	, ; //X3_ORDEM
	'C7_VALIMPW'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. W'															, ; //X3_TITULO
	'Valor Imp. W'															, ; //X3_TITSPA
	'Valor Imp. W'															, ; //X3_TITENG
	'Valor Imp. W'															, ; //X3_DESCRIC
	'Valor Imp. W'															, ; //X3_DESCSPA
	'Valor Imp. W'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVW","MT120",M->C7_VALIMPW)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'M9'																	, ; //X3_ORDEM
	'C7_BASIMPW'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. W'															, ; //X3_TITULO
	'Base Imp. W'															, ; //X3_TITSPA
	'Base Imp. W'															, ; //X3_TITENG
	'Base Imp. W'															, ; //X3_DESCRIC
	'Base Imp. W'															, ; //X3_DESCSPA
	'Base Imp. W'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVW","MT120",M->C7_BASIMPW)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'N0'																	, ; //X3_ORDEM
	'C7_ALQIMPW'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. W'															, ; //X3_TITULO
	'Alic Imp. W'															, ; //X3_TITSPA
	'Alic Imp. W'															, ; //X3_TITENG
	'Alic Imp. W'															, ; //X3_DESCRIC
	'Alic Imp. W'															, ; //X3_DESCSPA
	'Alic Imp. W'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVW","MT120",M->C7_ALQIMPW)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'N1'																	, ; //X3_ORDEM
	'C7_VALIMPX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. X'															, ; //X3_TITULO
	'Valor Imp. X'															, ; //X3_TITSPA
	'Valor Imp. X'															, ; //X3_TITENG
	'Valor Imp. X'															, ; //X3_DESCRIC
	'Valor Imp. X'															, ; //X3_DESCSPA
	'Valor Imp. X'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVX","MT120",M->C7_VALIMPX)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'N2'																	, ; //X3_ORDEM
	'C7_BASIMPX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. X'															, ; //X3_TITULO
	'Base Imp. X'															, ; //X3_TITSPA
	'Base Imp. X'															, ; //X3_TITENG
	'Base Imp. X'															, ; //X3_DESCRIC
	'Base Imp. X'															, ; //X3_DESCSPA
	'Base Imp. X'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVX","MT120",M->C7_BASIMPX)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'N3'																	, ; //X3_ORDEM
	'C7_ALQIMPX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. X'															, ; //X3_TITULO
	'Alic Imp. X'															, ; //X3_TITSPA
	'Alic Imp. X'															, ; //X3_TITENG
	'Alic Imp. X'															, ; //X3_DESCRIC
	'Alic Imp. X'															, ; //X3_DESCSPA
	'Alic Imp. X'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVX","MT120",M->C7_ALQIMPX)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'N4'																	, ; //X3_ORDEM
	'C7_VALIMPY'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. Y'															, ; //X3_TITULO
	'Valor Imp. Y'															, ; //X3_TITSPA
	'Valor Imp. Y'															, ; //X3_TITENG
	'Valor Imp. Y'															, ; //X3_DESCRIC
	'Valor Imp. Y'															, ; //X3_DESCSPA
	'Valor Imp. Y'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVY","MT120",M->C7_VALIMPY)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'N5'																	, ; //X3_ORDEM
	'C7_BASIMPY'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. Y'															, ; //X3_TITULO
	'Base Imp. Y'															, ; //X3_TITSPA
	'Base Imp. Y'															, ; //X3_TITENG
	'Base Imp. Y'															, ; //X3_DESCRIC
	'Base Imp. Y'															, ; //X3_DESCSPA
	'Base Imp. Y'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVY","MT120",M->C7_BASIMPY)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SC7'																	, ; //X3_ARQUIVO
	'N6'																	, ; //X3_ORDEM
	'C7_ALQIMPY'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. Y'															, ; //X3_TITULO
	'Alic Imp. Y'															, ; //X3_TITSPA
	'Alic Imp. Y'															, ; //X3_TITENG
	'Alic Imp. Y'															, ; //X3_DESCRIC
	'Alic Imp. Y'															, ; //X3_DESCSPA
	'Alic Imp. Y'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVY","MT120",M->C7_ALQIMPY)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME
//Tabla DBC

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'I4'																	, ; //X3_ORDEM
	'DBC_ALIMPB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. B'															, ; //X3_TITULO
	'Alic Imp. B'															, ; //X3_TITSPA
	'Alic Imp. B'															, ; //X3_TITENG
	'Alic Imp. B'															, ; //X3_DESCRIC
	'Alic Imp. B'															, ; //X3_DESCSPA
	'Alic Imp. B'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVB","MT120",M->DBC_ALIMPB)'							, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'I5'																	, ; //X3_ORDEM
	'DBC_ALIMPC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. C'															, ; //X3_TITULO
	'Alic Imp. C'															, ; //X3_TITSPA
	'Alic Imp. C'															, ; //X3_TITENG
	'Alic Imp. C'															, ; //X3_DESCRIC
	'Alic Imp. C'															, ; //X3_DESCSPA
	'Alic Imp. C'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVC","MT120",M->DBC_ALIMPC)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'I6'																	, ; //X3_ORDEM
	'DBC_ALIMPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. D'															, ; //X3_TITULO
	'Alic Imp. D'															, ; //X3_TITSPA
	'Alic Imp. D'															, ; //X3_TITENG
	'Alic Imp. D'															, ; //X3_DESCRIC
	'Alic Imp. D'															, ; //X3_DESCSPA
	'Alic Imp. D'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVD","MT120",M->DBC_ALIMPD)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	'@E 999.99'																, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'I7'																	, ; //X3_ORDEM
	'DBC_ALIMPF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. F'															, ; //X3_TITULO
	'Alic Imp. F'															, ; //X3_TITSPA
	'Alic Imp. F'															, ; //X3_TITENG
	'Alic Imp. F'															, ; //X3_DESCRIC
	'Alic Imp. F'															, ; //X3_DESCSPA
	'Alic Imp. F'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVF","MT120",M->DBC_ALIMPF)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'I8'																	, ; //X3_ORDEM
	'DBC_ALIMPG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. G'															, ; //X3_TITULO
	'Alic Imp. G'															, ; //X3_TITSPA
	'Alic Imp. G'															, ; //X3_TITENG
	'Alic Imp. G'															, ; //X3_DESCRIC
	'Alic Imp. G'															, ; //X3_DESCSPA
	'Alic Imp. G'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVG","MT120",M->DBC_ALIMPG)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'I9'																	, ; //X3_ORDEM
	'DBC_ALIMPJ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. J'															, ; //X3_TITULO
	'Alic Imp. J'															, ; //X3_TITSPA
	'Alic Imp. J'															, ; //X3_TITENG
	'Alic Imp. J'															, ; //X3_DESCRIC
	'Alic Imp. J'															, ; //X3_DESCSPA
	'Alic Imp. J'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVJ","MT120",M->DBC_ALIMPJ)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'J0'																	, ; //X3_ORDEM
	'DBC_ALIMPK'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. K'															, ; //X3_TITULO
	'Alic Imp. K'															, ; //X3_TITSPA
	'Alic Imp. K'															, ; //X3_TITENG
	'Alic Imp. K'															, ; //X3_DESCRIC
	'Alic Imp. K'															, ; //X3_DESCSPA
	'Alic Imp. K'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVK","MT120",M->DBC_ALIMPK)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'J1'																	, ; //X3_ORDEM
	'DBC_ALIMPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. L'															, ; //X3_TITULO
	'Alic Imp. L'															, ; //X3_TITSPA
	'Alic Imp. L'															, ; //X3_TITENG
	'Alic Imp. L'															, ; //X3_DESCRIC
	'Alic Imp. L'															, ; //X3_DESCSPA
	'Alic Imp. L'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVL","MT120",M->DBC_ALIMPL)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'J2'																	, ; //X3_ORDEM
	'DBC_ALIMPM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. M'															, ; //X3_TITULO
	'Alic Imp. M'															, ; //X3_TITSPA
	'Alic Imp. M'															, ; //X3_TITENG
	'Alic Imp. M'															, ; //X3_DESCRIC
	'Alic Imp. M'															, ; //X3_DESCSPA
	'Alic Imp. M'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVM","MT120",M->DBC_ALIMPM)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'J3'																	, ; //X3_ORDEM
	'DBC_ALIMPN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. N'															, ; //X3_TITULO
	'Alic Imp. N'															, ; //X3_TITSPA
	'Alic Imp. N'															, ; //X3_TITENG
	'Alic Imp. N'															, ; //X3_DESCRIC
	'Alic Imp. N'															, ; //X3_DESCSPA
	'Alic Imp. N'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVN","MT120",M->DBC_ALIMPN)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'J4'																	, ; //X3_ORDEM
	'DBC_ALIMPO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. O'															, ; //X3_TITULO
	'Alic Imp. O'															, ; //X3_TITSPA
	'Alic Imp. O'															, ; //X3_TITENG
	'Alic Imp. O'															, ; //X3_DESCRIC
	'Alic Imp. O'															, ; //X3_DESCSPA
	'Alic Imp. O'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVO","MT120",M->DBC_ALIMPO)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'J5'																	, ; //X3_ORDEM
	'DBC_ALIMPP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. P'															, ; //X3_TITULO
	'Alic Imp. P'															, ; //X3_TITSPA
	'Alic Imp. P'															, ; //X3_TITENG
	'Alic Imp. P'															, ; //X3_DESCRIC
	'Alic Imp. P'															, ; //X3_DESCSPA
	'Alic Imp. P'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVP","MT120",M->DBC_ALIMPP)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'J6'																	, ; //X3_ORDEM
	'DBC_ALIMPQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. Q'															, ; //X3_TITULO
	'Alic Imp. Q'															, ; //X3_TITSPA
	'Alic Imp. Q'															, ; //X3_TITENG
	'Alic Imp. Q'															, ; //X3_DESCRIC
	'Alic Imp. Q'															, ; //X3_DESCSPA
	'Alic Imp. Q'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVQ","MT120",M->DBC_ALIMPQ)'							, ; //X3_VALID
	cUsado																	, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'J7'																	, ; //X3_ORDEM
	'DBC_ALIMPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. R'															, ; //X3_TITULO
	'Alic Imp. R'															, ; //X3_TITSPA
	'Alic Imp. R'															, ; //X3_TITENG
	'Alic Imp. R'															, ; //X3_DESCRIC
	'Alic Imp. R'															, ; //X3_DESCSPA
	'Alic Imp. R'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVR","MT120",M->DBC_ALIMPR)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'J8'																	, ; //X3_ORDEM
	'DBC_ALIMPS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. S'															, ; //X3_TITULO
	'Alic Imp. S'															, ; //X3_TITSPA
	'Alic Imp. S'															, ; //X3_TITENG
	'Alic Imp. S'															, ; //X3_DESCRIC
	'Alic Imp. S'															, ; //X3_DESCSPA
	'Alic Imp. S'															, ; //X3_DESCENG
	'@e 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVS","MT120",M->DBC_ALIMPS)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'J9'																	, ; //X3_ORDEM
	'DBC_ALIMPT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. T'															, ; //X3_TITULO
	'Alic Imp. T'															, ; //X3_TITSPA
	'Alic Imp. T'															, ; //X3_TITENG
	'Alic Imp. T'															, ; //X3_DESCRIC
	'Alic Imp. T'															, ; //X3_DESCSPA
	'Alic Imp. T'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVT","MT120",M->DBC_ALIMPT)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'K0'																	, ; //X3_ORDEM
	'DBC_ALIMPU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. U'															, ; //X3_TITULO
	'Alic Imp. U'															, ; //X3_TITSPA
	'Alic Imp. U'															, ; //X3_TITENG
	'Alic Imp. U'															, ; //X3_DESCRIC
	'Alic Imp. U'															, ; //X3_DESCSPA
	'Alic Imp. U'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVU","MT120",M->DBC_ALIMPU)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'K1'																	, ; //X3_ORDEM
	'DBC_ALIMPV'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. V'															, ; //X3_TITULO
	'Alic Imp. V'															, ; //X3_TITSPA
	'Alic Imp. V'															, ; //X3_TITENG
	'Alic Imp. V'															, ; //X3_DESCRIC
	'Alic Imp. V'															, ; //X3_DESCSPA
	'Alic Imp. V'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVV","MT120",M->DBC_ALIMPV)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'K2'																	, ; //X3_ORDEM
	'DBC_ALIMPW'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. W'															, ; //X3_TITULO
	'Alic Imp. W'															, ; //X3_TITSPA
	'Alic Imp. W'															, ; //X3_TITENG
	'Alic Imp. W'															, ; //X3_DESCRIC
	'Alic Imp. W'															, ; //X3_DESCSPA
	'Alic Imp. W'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVW","MT120",M->DBC_ALIMPW)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'K3'																	, ; //X3_ORDEM
	'DBC_ALIMPX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. X'															, ; //X3_TITULO
	'Alic Imp. X'															, ; //X3_TITSPA
	'Alic Imp. X'															, ; //X3_TITENG
	'Alic Imp. X'															, ; //X3_DESCRIC
	'Alic Imp. X'															, ; //X3_DESCSPA
	'Alic Imp. X'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVX","MT120",M->DBC_ALIMPX)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'K4'																	, ; //X3_ORDEM
	'DBC_ALIMPY'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. Y'															, ; //X3_TITULO
	'Alic Imp. Y'															, ; //X3_TITSPA
	'Alic Imp. Y'															, ; //X3_TITENG
	'Alic Imp. Y'															, ; //X3_DESCRIC
	'Alic Imp. Y'															, ; //X3_DESCSPA
	'Alic Imp. Y'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVY","MT120",M->DBC_ALIMPY)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'K5'																	, ; //X3_ORDEM
	'DBC_ALIMPA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. A'															, ; //X3_TITULO
	'Alic Imp. A'															, ; //X3_TITSPA
	'Alic Imp. A'															, ; //X3_TITENG
	'Alic Imp. A'															, ; //X3_DESCRIC
	'Alic Imp. A'															, ; //X3_DESCSPA
	'Alic Imp. A'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVA","MT120",M->DBC_ALIMPA)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'K6'																	, ; //X3_ORDEM
	'DBC_ALIMPE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Alic Imp. E'															, ; //X3_TITULO
	'Alic Imp. E'															, ; //X3_TITSPA
	'Alic Imp. E'															, ; //X3_TITENG
	'Alic Imp. E'															, ; //X3_DESCRIC
	'Alic Imp. E'															, ; //X3_DESCSPA
	'Alic Imp. E'															, ; //X3_DESCENG
	'@E 999.99'																, ; //X3_PICTURE
	'MaFisRef("IT_ALIQIVE","MT120",M->DBC_ALIMPE)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'K7'																	, ; //X3_ORDEM
	'DBC_BSIMPA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. A'															, ; //X3_TITULO
	'Base Imp. A'															, ; //X3_TITSPA
	'Base Imp. A'															, ; //X3_TITENG
	'Base Imp. A'															, ; //X3_DESCRIC
	'Base Imp. A'															, ; //X3_DESCSPA
	'Base Imp. A'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVA","MT120",M->DBC_BSIMPA)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'K8'																	, ; //X3_ORDEM
	'DBC_BSIMPB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. B'															, ; //X3_TITULO
	'Base Imp. B'															, ; //X3_TITSPA
	'Base Imp. B'															, ; //X3_TITENG
	'Base Imp. B'															, ; //X3_DESCRIC
	'Base Imp. B'															, ; //X3_DESCSPA
	'Base Imp. B'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVB","MT120",M->DBC_BSIMPB)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME


aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'K9'																	, ; //X3_ORDEM
	'DBC_BSIMPC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. C'															, ; //X3_TITULO
	'Base Imp. C'															, ; //X3_TITSPA
	'Base Imp. C'															, ; //X3_TITENG
	'Base Imp. C'															, ; //X3_DESCRIC
	'Base Imp. C'															, ; //X3_DESCSPA
	'Base Imp. C'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVC","MT120",M->DBC_BSIMPC)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'L0'																	, ; //X3_ORDEM
	'DBC_BSIMPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. D'															, ; //X3_TITULO
	'Base Imp. D'															, ; //X3_TITSPA
	'Base Imp. D'															, ; //X3_TITENG
	'Base Imp. D'															, ; //X3_DESCRIC
	'Base Imp. D'															, ; //X3_DESCSPA
	'Base Imp. D'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVD","MT120",M->DBC_BSIMPD)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'L1'																	, ; //X3_ORDEM
	'DBC_BSIMPE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. E'															, ; //X3_TITULO
	'Base Imp. E'															, ; //X3_TITSPA
	'Base Imp. E'															, ; //X3_TITENG
	'Base Imp. E'															, ; //X3_DESCRIC
	'Base Imp. E'															, ; //X3_DESCSPA
	'Base Imp. E'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVE","MT120",M->DBC_BSIMPE)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'L2'																	, ; //X3_ORDEM
	'DBC_BSIMPF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. F'															, ; //X3_TITULO
	'Base Imp. F'															, ; //X3_TITSPA
	'Base Imp. F'															, ; //X3_TITENG
	'Base Imp. F'															, ; //X3_DESCRIC
	'Base Imp. F'															, ; //X3_DESCSPA
	'Base Imp. F'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVF","MT120",M->DBC_BSIMPF)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'L3'																	, ; //X3_ORDEM
	'DBC_BSIMPG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. G'															, ; //X3_TITULO
	'Base Imp. G'															, ; //X3_TITSPA
	'Base Imp. G'															, ; //X3_TITENG
	'Base Imp. G'															, ; //X3_DESCRIC
	'Base Imp. G'															, ; //X3_DESCSPA
	'Base Imp. G'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVG","MT120",M->DBC_BSIMPG)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'L4'																	, ; //X3_ORDEM
	'DBC_BSIMPJ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. J'															, ; //X3_TITULO
	'Base Imp. J'															, ; //X3_TITSPA
	'Base Imp. J'															, ; //X3_TITENG
	'Base Imp. J'															, ; //X3_DESCRIC
	'Base Imp. J'															, ; //X3_DESCSPA
	'Base Imp. J'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVJ","MT120",M->DBC_BSIMPJ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'L5'																	, ; //X3_ORDEM
	'DBC_BSIMPK'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. K'															, ; //X3_TITULO
	'Base Imp. K'															, ; //X3_TITSPA
	'Base Imp. K'															, ; //X3_TITENG
	'Base Imp. K'															, ; //X3_DESCRIC
	'Base Imp. K'															, ; //X3_DESCSPA
	'Base Imp. K'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVK","MT120",M->DBC_BSIMPK)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'L6'																	, ; //X3_ORDEM
	'DBC_BSIMPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. L'															, ; //X3_TITULO
	'Base Imp. L'															, ; //X3_TITSPA
	'Base Imp. L'															, ; //X3_TITENG
	'Base Imp. L'															, ; //X3_DESCRIC
	'Base Imp. L'															, ; //X3_DESCSPA
	'Base Imp. L'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVL","MT120",M->DBC_BSIMPL)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'L7'																	, ; //X3_ORDEM
	'DBC_BSIMPM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. M'															, ; //X3_TITULO
	'Base Imp. M'															, ; //X3_TITSPA
	'Base Imp. M'															, ; //X3_TITENG
	'Base Imp. M'															, ; //X3_DESCRIC
	'Base Imp. M'															, ; //X3_DESCSPA
	'Base Imp. M'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVM","MT120",M->DBC_BSIMPM)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'L8'																	, ; //X3_ORDEM
	'DBC_BSIMPN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. N'															, ; //X3_TITULO
	'Base Imp. N'															, ; //X3_TITSPA
	'Base Imp. N'															, ; //X3_TITENG
	'Base Imp. N'															, ; //X3_DESCRIC
	'Base Imp. N'															, ; //X3_DESCSPA
	'Base Imp. N'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVN","MT120",M->DBC_BSIMPN)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'L9'																	, ; //X3_ORDEM
	'DBC_BSIMPO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. O'															, ; //X3_TITULO
	'Base Imp. O'															, ; //X3_TITSPA
	'Base Imp. O'															, ; //X3_TITENG
	'Base Imp. O'															, ; //X3_DESCRIC
	'Base Imp. O'															, ; //X3_DESCSPA
	'Base Imp. O'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVO","MT120",M->DBC_BSIMPO)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'M0'																	, ; //X3_ORDEM
	'DBC_BSIMPP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. P'															, ; //X3_TITULO
	'Base Imp. P'															, ; //X3_TITSPA
	'Base Imp. P'															, ; //X3_TITENG
	'Base Imp. P'															, ; //X3_DESCRIC
	'Base Imp. P'															, ; //X3_DESCSPA
	'Base Imp. P'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVP","MT120",M->DBC_BSIMPP)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'M1'																	, ; //X3_ORDEM
	'DBC_BSIMPQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. Q'															, ; //X3_TITULO
	'Base Imp. Q'															, ; //X3_TITSPA
	'Base Imp. Q'															, ; //X3_TITENG
	'Base Imp. Q'															, ; //X3_DESCRIC
	'Base Imp. Q'															, ; //X3_DESCSPA
	'Base Imp. Q'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVQ","MT120",M->DBC_BSIMPQ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'M2'																	, ; //X3_ORDEM
	'DBC_BSIMPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. R'															, ; //X3_TITULO
	'Base Imp. R'															, ; //X3_TITSPA
	'Base Imp. R'															, ; //X3_TITENG
	'Base Imp. R'															, ; //X3_DESCRIC
	'Base Imp. R'															, ; //X3_DESCSPA
	'Base Imp. R'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVR","MT120",M->DBC_BSIMPR)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'M3'																	, ; //X3_ORDEM
	'DBC_BSIMPS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. S'															, ; //X3_TITULO
	'Base Imp. S'															, ; //X3_TITSPA
	'Base Imp. S'															, ; //X3_TITENG
	'Base Imp. S'															, ; //X3_DESCRIC
	'Base Imp. S'															, ; //X3_DESCSPA
	'Base Imp. S'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVS","MT120",M->DBC_BSIMPS)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'M4'																	, ; //X3_ORDEM
	'DBC_BSIMPT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. T'															, ; //X3_TITULO
	'Base Imp. T'															, ; //X3_TITSPA
	'Base Imp. T'															, ; //X3_TITENG
	'Base Imp. T'															, ; //X3_DESCRIC
	'Base Imp. T'															, ; //X3_DESCSPA
	'Base Imp. T'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVT","MT120",M->DBC_BSIMPT)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'M5'																	, ; //X3_ORDEM
	'DBC_BSIMPU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. U'															, ; //X3_TITULO
	'Base Imp. U'															, ; //X3_TITSPA
	'Base Imp. U'															, ; //X3_TITENG
	'Base Imp. U'															, ; //X3_DESCRIC
	'Base Imp. U'															, ; //X3_DESCSPA
	'Base Imp. U'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVU","MT120",M->DBC_BSIMPU)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'M6'																	, ; //X3_ORDEM
	'DBC_BSIMPV'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. V'															, ; //X3_TITULO
	'Base Imp. V'															, ; //X3_TITSPA
	'Base Imp. V'															, ; //X3_TITENG
	'Base Imp. V'															, ; //X3_DESCRIC
	'Base Imp. V'															, ; //X3_DESCSPA
	'Base Imp. V'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVV","MT120",M->DBC_BSIMPV)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'M7'																	, ; //X3_ORDEM
	'DBC_BSIMPW'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. W'															, ; //X3_TITULO
	'Base Imp. W'															, ; //X3_TITSPA
	'Base Imp. W'															, ; //X3_TITENG
	'Base Imp. W'															, ; //X3_DESCRIC
	'Base Imp. W'															, ; //X3_DESCSPA
	'Base Imp. W'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVW","MT120",M->DBC_BSIMPW)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'M8'																	, ; //X3_ORDEM
	'DBC_BSIMPX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. X'															, ; //X3_TITULO
	'Base Imp. X'															, ; //X3_TITSPA
	'Base Imp. X'															, ; //X3_TITENG
	'Base Imp. X'															, ; //X3_DESCRIC
	'Base Imp. X'															, ; //X3_DESCSPA
	'Base Imp. X'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVX","MT120",M->DBC_BSIMPX)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'M9'																	, ; //X3_ORDEM
	'DBC_BSIMPY'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Base Imp. Y'															, ; //X3_TITULO
	'Base Imp. Y'															, ; //X3_TITSPA
	'Base Imp. Y'															, ; //X3_TITENG
	'Base Imp. Y'															, ; //X3_DESCRIC
	'Base Imp. Y'															, ; //X3_DESCSPA
	'Base Imp. Y'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_BASEIVY","MT120",M->DBC_BSIMPY)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'N0'																	, ; //X3_ORDEM
	'DBC_VLIMPA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. A'															, ; //X3_TITULO
	'Valor Imp. A'															, ; //X3_TITSPA
	'Valor Imp. A'															, ; //X3_TITENG
	'Valor Imp. A'															, ; //X3_DESCRIC
	'Valor Imp. A'															, ; //X3_DESCSPA
	'Valor Imp. A'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVA","MT120",M->DBC_VLIMPA)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'N1'																	, ; //X3_ORDEM
	'DBC_VLIMPB'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. B'															, ; //X3_TITULO
	'Valor Imp. B'															, ; //X3_TITSPA
	'Valor Imp. B'															, ; //X3_TITENG
	'Valor Imp. B'															, ; //X3_DESCRIC
	'Valor Imp. B'															, ; //X3_DESCSPA
	'Valor Imp. B'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVB","MT120",M->DBC_VLIMPB)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'N2'																	, ; //X3_ORDEM
	'DBC_VLIMPC'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. C'															, ; //X3_TITULO
	'Valor Imp. C'															, ; //X3_TITSPA
	'Valor Imp. C'															, ; //X3_TITENG
	'Valor Imp. C'															, ; //X3_DESCRIC
	'Valor Imp. C'															, ; //X3_DESCSPA
	'Valor Imp. C'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVC","MT120",M->DBC_VLIMPC)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'N3'																	, ; //X3_ORDEM
	'DBC_VLIMPD'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. D'															, ; //X3_TITULO
	'Valor Imp. D'															, ; //X3_TITSPA
	'Valor Imp. D'															, ; //X3_TITENG
	'Valor Imp. D'															, ; //X3_DESCRIC
	'Valor Imp. D'															, ; //X3_DESCSPA
	'Valor Imp. D'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVD","MT120",M->DBC_VLIMPD)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'N4'																	, ; //X3_ORDEM
	'DBC_VLIMPE'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. E'															, ; //X3_TITULO
	'Valor Imp. E'															, ; //X3_TITSPA
	'Valor Imp. E'															, ; //X3_TITENG
	'Valor Imp. E'															, ; //X3_DESCRIC
	'Valor Imp. E'															, ; //X3_DESCSPA
	'Valor Imp. E'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVE","MT120",M->DBC_VLIMPE)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'N5'																	, ; //X3_ORDEM
	'DBC_VLIMPF'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. F'															, ; //X3_TITULO
	'Valor Imp. F'															, ; //X3_TITSPA
	'Valor Imp. F'															, ; //X3_TITENG
	'Valor Imp. F'															, ; //X3_DESCRIC
	'Valor Imp. F'															, ; //X3_DESCSPA
	'Valor Imp. F'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVF","MT120",M->DBC_VLIMPF)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'N6'																	, ; //X3_ORDEM
	'DBC_VLIMPG'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. G'															, ; //X3_TITULO
	'Valor Imp. G'															, ; //X3_TITSPA
	'Valor Imp. G'															, ; //X3_TITENG
	'Valor Imp. G'															, ; //X3_DESCRIC
	'Valor Imp. G'															, ; //X3_DESCSPA
	'Valor Imp. G'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVG","MT120",M->DBC_VLIMPG)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'N7'																	, ; //X3_ORDEM
	'DBC_VLIMPJ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. J'															, ; //X3_TITULO
	'Valor Imp. J'															, ; //X3_TITSPA
	'Valor Imp. J'															, ; //X3_TITENG
	'Valor Imp. J'															, ; //X3_DESCRIC
	'Valor Imp. J'															, ; //X3_DESCSPA
	'Valor Imp. J'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVJ","MT120",M->DBC_VLIMPJ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'N8'																	, ; //X3_ORDEM
	'DBC_VLIMPK'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. K'															, ; //X3_TITULO
	'Valor Imp. K'															, ; //X3_TITSPA
	'Valor Imp. K'															, ; //X3_TITENG
	'Valor Imp. K'															, ; //X3_DESCRIC
	'Valor Imp. K'															, ; //X3_DESCSPA
	'Valor Imp. K'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVK","MT120",M->DBC_VLIMPK)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'N9'																	, ; //X3_ORDEM
	'DBC_VLIMPL'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. L'															, ; //X3_TITULO
	'Valor Imp. L'															, ; //X3_TITSPA
	'Valor Imp. L'															, ; //X3_TITENG
	'Valor Imp. L'															, ; //X3_DESCRIC
	'Valor Imp. L'															, ; //X3_DESCSPA
	'Valor Imp. L'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVL","MT120",M->DBC_VLIMPL)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'O0'																	, ; //X3_ORDEM
	'DBC_VLIMPM'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. M'															, ; //X3_TITULO
	'Valor Imp. M'															, ; //X3_TITSPA
	'Valor Imp. M'															, ; //X3_TITENG
	'Valor Imp. M'															, ; //X3_DESCRIC
	'Valor Imp. M'															, ; //X3_DESCSPA
	'Valor Imp. M'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVM","MT120",M->DBC_VLIMPM)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'O1'																	, ; //X3_ORDEM
	'DBC_VLIMPN'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. N'															, ; //X3_TITULO
	'Valor Imp. N'															, ; //X3_TITSPA
	'Valor Imp. N'															, ; //X3_TITENG
	'Valor Imp. N'															, ; //X3_DESCRIC
	'Valor Imp. N'															, ; //X3_DESCSPA
	'Valor Imp. N'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVN","MT120",M->DBC_VLIMPN)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'O2'																	, ; //X3_ORDEM
	'DBC_VLIMPO'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. O'															, ; //X3_TITULO
	'Valor Imp. O'															, ; //X3_TITSPA
	'Valor Imp. O'															, ; //X3_TITENG
	'Valor Imp. O'															, ; //X3_DESCRIC
	'Valor Imp. O'															, ; //X3_DESCSPA
	'Valor Imp. O'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVO","MT120",M->DBC_VLIMPO)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'O3'																	, ; //X3_ORDEM
	'DBC_VLIMPP'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. P'															, ; //X3_TITULO
	'Valor Imp. P'															, ; //X3_TITSPA
	'Valor Imp. P'															, ; //X3_TITENG
	'Valor Imp. P'															, ; //X3_DESCRIC
	'Valor Imp. P'															, ; //X3_DESCSPA
	'Valor Imp. P'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVP","MT120",M->DBC_VLIMPP)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'O4'																	, ; //X3_ORDEM
	'DBC_VLIMPQ'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. Q'															, ; //X3_TITULO
	'Valor Imp. Q'															, ; //X3_TITSPA
	'Valor Imp. Q'															, ; //X3_TITENG
	'Valor Imp. Q'															, ; //X3_DESCRIC
	'Valor Imp. Q'															, ; //X3_DESCSPA
	'Valor Imp. Q'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVQ","MT120",M->DBC_VLIMPQ)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'O5'																	, ; //X3_ORDEM
	'DBC_VLIMPR'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. R'															, ; //X3_TITULO
	'Valor Imp. R'															, ; //X3_TITSPA
	'Valor Imp. R'															, ; //X3_TITENG
	'Valor Imp. R'															, ; //X3_DESCRIC
	'Valor Imp. R'															, ; //X3_DESCSPA
	'Valor Imp. R'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVR","MT120",M->DBC_VLIMPR)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'O6'																	, ; //X3_ORDEM
	'DBC_VLIMPS'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. S'															, ; //X3_TITULO
	'Valor Imp. S'															, ; //X3_TITSPA
	'Valor Imp. S'															, ; //X3_TITENG
	'Valor Imp. S'															, ; //X3_DESCRIC
	'Valor Imp. S'															, ; //X3_DESCSPA
	'Valor Imp. S'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVS","MT120",M->DBC_VLIMPS)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'O7'																	, ; //X3_ORDEM
	'DBC_VLIMPT'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. T'															, ; //X3_TITULO
	'Valor Imp. T'															, ; //X3_TITSPA
	'Valor Imp. T'															, ; //X3_TITENG
	'Valor Imp. T'															, ; //X3_DESCRIC
	'Valor Imp. T'															, ; //X3_DESCSPA
	'Valor Imp. T'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVT","MT120",M->DBC_VLIMPT)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'O8'																	, ; //X3_ORDEM
	'DBC_VLIMPU'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. U'															, ; //X3_TITULO
	'Valor Imp. U'															, ; //X3_TITSPA
	'Valor Imp. U'															, ; //X3_TITENG
	'Valor Imp. U'															, ; //X3_DESCRIC
	'Valor Imp. U'															, ; //X3_DESCSPA
	'Valor Imp. U'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVU","MT120",M->DBC_VLIMPU)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'O9'																	, ; //X3_ORDEM
	'DBC_VLIMPV'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. V'															, ; //X3_TITULO
	'Valor Imp. V'															, ; //X3_TITSPA
	'Valor Imp. V'															, ; //X3_TITENG
	'Valor Imp. V'															, ; //X3_DESCRIC
	'Valor Imp. V'															, ; //X3_DESCSPA
	'Valor Imp. V'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVV","MT120",M->DBC_VLIMPV)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'P0'																	, ; //X3_ORDEM
	'DBC_VLIMPW'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. W'															, ; //X3_TITULO
	'Valor Imp. W'															, ; //X3_TITSPA
	'Valor Imp. W'															, ; //X3_TITENG
	'Valor Imp. W'															, ; //X3_DESCRIC
	'Valor Imp. W'															, ; //X3_DESCSPA
	'Valor Imp. W'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVW","MT120",M->DBC_VLIMPW)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'P1'																	, ; //X3_ORDEM
	'DBC_VLIMPX'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. X'															, ; //X3_TITULO
	'Valor Imp. X'															, ; //X3_TITSPA
	'Valor Imp. X'															, ; //X3_TITENG
	'Valor Imp. X'															, ; //X3_DESCRIC
	'Valor Imp. X'															, ; //X3_DESCSPA
	'Valor Imp. X'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVX","MT120",M->DBC_VLIMPX)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'DBC'																	, ; //X3_ARQUIVO
	'P2'																	, ; //X3_ORDEM
	'DBC_VLIMPY'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	14																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Valor Imp. Y'															, ; //X3_TITULO
	'Valor Imp. Y'															, ; //X3_TITSPA
	'Valor Imp. Y'															, ; //X3_TITENG
	'Valor Imp. Y'															, ; //X3_DESCRIC
	'Valor Imp. Y'															, ; //X3_DESCSPA
	'Valor Imp. Y'															, ; //X3_DESCENG
	'@E 99,999,999,999.99'													, ; //X3_PICTURE
	'MaFisRef("IT_VALIVY","MT120",M->DBC_VLIMPY)'							, ; //X3_VALID
	cUsado					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME



//
// Atualizando dicionário
//
aSort( aSX3,,, { |x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] } )



cAliasAtu := ''
cTexto += CRLF+'----------  Inicia actualización de campos para impuestos (SX3) 09/08/2018  ----------' + CRLF + CRLF
dbSelectArea("SX3")
SX3->(dbSetOrder(2))

For nI:= 1 To Len(aSX3)

	If !SX3->(dbSeek(aSX3[nI,3]))

		If !( aSX3[nI][1] $ cAlias )
			cAlias += aSX3[nI][1] + '/'

		EndIf
		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][1] <> cAliasAtu )
			cSeqAtu   := '00'
			cAliasAtu := aSX3[nI][1]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + 'ZZ', .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( 'SX3', .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == 2    // Ordem
				FieldPut( FieldPos( aEstrut[nJ] ), cSeqAtu )

			ElseIf FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()
		cTexto += "Incluyo el campo "+aSX3[ni,3]+CRLF
		IF(AScan( aArqUpd,aSX3[Ni,1])==0) 	//Guarda en el arreglo aArqUpd, las tablas que deberan regenerar estructura en la BD
				AADD(aArqUpd,aSX3[Ni,1])
		ENDIF		
   else 
   		cTexto += "No Incluyo el campo "+aSX3[ni,3]+" ya existe en el ambiente" + CRLF
	EndIf

	

Next nI

cTexto += CRLF+ 'Finalizo actualización de campos para impuestos (SX3)' + CRLF+ CRLF

Return 



Static Function UPDSX7()
Local aSX7   := {}
Local aEstrut:= {}
Local i      := 0
Local j      := 0

aEstrut:= {"X7_CAMPO","X7_SEQUENC","X7_REGRA","X7_CDOMIN","X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE","X7_PROPRI","X7_CONDIC"}
aAdd(aSX7,{'LQ_CLIENTE','002','ObtCpoRG3668()','LQ_ADIC5','P','N','',0,'',"",''})
aAdd(aSX7,{'LQ_LOJA','002','ObtCpoRG3668()','LQ_ADIC5','P','N','',0,'',"",''})
cTexto += CRLF+'----------  Inicia actualización de Gatillos (SX7)   ----------' + CRLF + CRLF
dbSelectArea("SX7")
dbSetOrder(1)
For i:= 1 To Len(aSX7)
		If !dbSeek(padr(aSX7[i,1],10)+aSX7[i,2])
			RecLock("SX7",.T.)
			For j:=1 To Len(aSX7[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX7[i,j])
				EndIf
			Next j
			dbCommit()
			MsUnLock()
			cTexto += "Incluyo el gatillo "+aSX7[i,1]+CRLF
		ELSE	
			cTexto += "No actualizó el gatillo "+aSX7[i,1]+ " ya existe en el ambiente."+CRLF
		EndIf
Next i
cTexto += CRLF+ 'Finalizo actualización de Gatillos(SX7)' + CRLF+ CRLF
Return cTexto



Static Function UHELPS()
Local aHelp   := {}
Local cCampo   := ""
cTexto += CRLF+'----------  Inicia actualización de Helps   ----------' + CRLF + CRLF
//del MMI-278
aHelp:={}
aadd(aHelp,"Indique el certificado SIRE            ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"CERTSUSSVAZIO",aHelp,aHelp,aHelp,.t.) 
cTexto += "Actualizo el HELP : CERTSUSSVAZIO"+ CRLF
 
aHelp:={}
aadd(aHelp,"Indique código de seguridad SIRE       ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"SEGSUSSVAZIO",aHelp,aHelp,aHelp,.t.) 
cTexto += "Actualizo el HELP : SEGSUSSVAZIO"+ CRLF

aHelp:={}
aadd(aHelp,"Certificado SIRE invalido!             ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"CERTSUSSVALID",aHelp,aHelp,aHelp,.t.)
cTexto += "Actualizo el HELP : CERTSUSSVALID"+ CRLF
 
 //del MMI-150
aHelp:={}
aadd(aHelp,"Campos donde constará la jornada       ")
aadd(aHelp,"reducida, solicitada por el servidor y ")
aadd(aHelp,"válida en este momento.                ")
PutSX1Help("P"+"RA_JORNERD",aHelp,aHelp,aHelp,.t.) 
cTexto += "Actualizo el HELP del campo : RA_JORNERD" +CRLF

aHelp:={}
aadd(aHelp,"Indicar el valor del sueldo mínimo para")
aadd(aHelp,"el aporte de la Obra Social.           ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"RJ_SALMIN",aHelp,aHelp,aHelp,.t.)
cTexto += "Actualizo el HELP del campo : RJ_SALMIN" +CRLF

 //del MMI-167
aHelp:={}
aadd(aHelp,"Informe el proceso a considerar        ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+".GPEA0151.",aHelp,aHelp,aHelp,.t.) 
cTexto += "Actualizo el HELP  : GPEA0151" +CRLF

aHelp:={}
aadd(aHelp,"Informe el rango de matriculas a       ")
aadd(aHelp,"procesar.                              ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+".GPEA0152.",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP  : GPEA0152" +CRLF

aHelp:={}
aadd(aHelp,"Informe el rango de sucursales a       ")
aadd(aHelp,"procesar.                              ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+".GPEA0153.",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP  : GPEA0153" +CRLF

aHelp:={}
aadd(aHelp,"Informe el rango de departamentos a    ")
aadd(aHelp,"procesar.                              ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+".GPEA0154.",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP  : GPEA0154" +CRLF  
  //del MMI-333
aHelp:={}
aadd(aHelp," Informe el proceso que se considerará.")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+".GPEA01501.",aHelp,aHelp,aHelp,.t.) 
cTexto += "Actualizo el HELP  : GPEA01501" +CRLF

aHelp:={}
aadd(aHelp,"Informe el rango de matriculas que se  ")
aadd(aHelp,"procesarán.                            ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+".GPEA01502.",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP  : GPEA01502" +CRLF

aHelp:={}
aadd(aHelp,"Informe el proceso a considerar.       ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+".GPEA0151.",aHelp,aHelp,aHelp,.t.)
cTexto += "Actualizo el HELP  : GPEA0151" +CRLF

aHelp:={}
aadd(aHelp,"Informe el rango de matriculas a       ")
aadd(aHelp,"procesar.                              ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+".GPEA0152.",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP  : GPEA0152" +CRLF

aHelp:={}
aadd(aHelp,"Informe el rango de sucursales a       ")
aadd(aHelp,"procesar.                              ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+".GPEA0153.",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP  : GPEA0153" +CRLF

aHelp:={}
aadd(aHelp," Informe el rango de departamentos a   ")
aadd(aHelp,"procesar.                              ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+".GPEA0154.",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP  : GPEA0154" +CRLF

aHelp:={}
aadd(aHelp,"Vacaciones pendientes del periodo      ")
aadd(aHelp,"actual.                                ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"RA_DVACACT",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : RA_DVACACT" +CRLF

aHelp:={}
aadd(aHelp,"Vacaciones pendientes de periodos      ")
aadd(aHelp,"anteriores.                            ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"RA_DVACANT",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : RA_DVACANT" +CRLF
//del MMI-281
aHelp:={}
aadd(aHelp,"Seleccione las filiales deseadas. De lo")
aadd(aHelp,"contrario, sólo la filial actual será  ")
aadd(aHelp,"afectada.                              ")
PutSX1Help("P"+".MTRAR1B05.",aHelp,aHelp,aHelp,.t.) 
cTexto += "Actualizo el HELP  : MTRAR1B05" +CRLF
//del MMI-4889
aHelp:={}
aadd(aHelp,"Digite el peso de la tasa prevista.    ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"DBA_PESOTX",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : DBA_PESOTX" +CRLF

aHelp:={}
aadd(aHelp,"Describe otros tipos de contenedor     ")
aadd(aHelp,"diferentes de 20 o 40 pies.            ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"DBA_OUT_CT",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : DBA_OUT_CT" +CRLF

aHelp:={}
aadd(aHelp,"Existe facturas sin items digitados.   ")
aadd(aHelp,"Registre los ítems para las facturas en")
aadd(aHelp,"esta condición.                        ")
PutSX1Help("P"+"A143NOITEM",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP  : A143NOITEM" +CRLF

aHelp:={}
aadd(aHelp,"Es posible que los campos de cantidad y")
aadd(aHelp,"valor unitario este en ceros ó el item ")
aadd(aHelp,"no tega Purche Order.                  ")
PutSX1Help("P"+"SA143NOITEM",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP  : SA143NOITEM" +CRLF
aHelp:={}
aadd(aHelp,"No es posible borrar un sol item de una")
aadd(aHelp,"factura.                               ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"PA143OBR3",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP  : PA143OBR3" +CRLF  

 aHelp:={}
aadd(aHelp,"Llene correctamente el ítem de la       ")
aadd(aHelp,"factura.                               ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"SA143OBR3",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP  : SA143OBR3" +CRLF

//del MMI-4417
aHelp:={}
aadd(aHelp,"Fecha final de publicación.            ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"A2_DTFCALG",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : A2_DTFCALG" +CRLF

aHelp:={}
aadd(aHelp,"Fecha inicial de publicación.            ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"A2_DTICALG",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : A2_DTICALG" +CRLF


//del MMI-4938
aHelp:={}
aadd(aHelp,"Alicuota Impuesto/Retención            ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"FVC_ALIQ",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : FVC_ALIQ  " +CRLF

aHelp:={}
aadd(aHelp,"Código Fiscal Operación                ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"FVC_CFO",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : FVC_CFO   " +CRLF

aHelp:={}
aadd(aHelp," Concepto p/neto de IR                 ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"FVC_CONCEP",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : FVC_CONCEP   " +CRLF

aHelp:={}
aadd(aHelp,"Valor de la  Deducción		            ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"FVC_DEDUC",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : FVC_DEDUC " +CRLF

aHelp:={}
aadd(aHelp,"Porcentaje de Desgravamen              ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"FVC_DESGR",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : FVC_DESGR  " +CRLF

aHelp:={}
aadd(aHelp,"Estado      ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"FVC_EST",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : FVC_EST  " +CRLF

aHelp:={}
aadd(aHelp,"Informe la sucursal                     ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"FVC_FILIAL",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : FVC_FILIAL   " +CRLF

aHelp:={}
aadd(aHelp,"Proveedor Condominio		            ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"FVC_FORCON",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : FVC_FORCON   " +CRLF

aHelp:={}
aadd(aHelp,"Código del Proveedor            ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"FVC_FORNEC",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : FVC_FORNEC   " +CRLF

aHelp:={}
aadd(aHelp,"Tienda del Proveedor             ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"FVC_LOJA",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : FVC_LOJA     " +CRLF

aHelp:={}
aadd(aHelp," Tienda Condominio                     ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"FVC_LOJCON",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : FVC_LOJCON     " +CRLF

aHelp:={}
aadd(aHelp,"Numero de la Factura             ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"FVC_NFISC",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : FVC_NFISC     " +CRLF

aHelp:={}
aadd(aHelp,"Cuota de la Factura            ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"FVC_PARCEL",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : FVC_PARCEL     " +CRLF

aHelp:={}
aadd(aHelp," % de no Ret. de la Retención            ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"FVC_PORCR ",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : FVC_PORCR      " +CRLF

aHelp:={}
aadd(aHelp,"Número de la Orden de Pago Previa             ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"FVC_PREOP",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : FVC_PREOP     " +CRLF

aHelp:={}
aadd(aHelp,"Valor de la Retención             ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"FVC_RETENC",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : FVC_RETENC     " +CRLF

aHelp:={}
aadd(aHelp,"Serie de la Factura           ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"FVC_SERIE",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : FVC_SERIE     " +CRLF

aHelp:={}
aadd(aHelp," Tipo de Impuesto             ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"FVC_TIPO",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : FVC_TIPO     " +CRLF

aHelp:={}
aadd(aHelp,"Valor Base Disponible             ")
aadd(aHelp,"                                       ")
aadd(aHelp,"                                       ")
PutSX1Help("P"+"FVC_VALBAS",aHelp,aHelp,aHelp,.t.)  
cTexto += "Actualizo el HELP de Campo : FVC_VALBAS     " +CRLF

cTexto+=CRLF+ "Finalizó actualización de Helps "+ CRLF + CRLF 
Return 
