#INCLUDE "RWMAKE.CH" 
#INCLUDE "TRYEXCEPTION.CH"
#INCLUDE "XMLXFUN.CH"

#DEFINE STR0001 " DEFINEFISCAL - Arquivo de Definições "
#DEFINE STR0002 " Este programa ira gerar um arquivo de definições conforme "
#DEFINE STR0003 " os registros existentes na tabela XXJ - Layout MILE "
#DEFINE STR0004 " "

#DEFINE __cArqFis "\system\definefiscal.def"

#DEFINE STR0005 " O arquivo de nome "
#DEFINE STR0006 " nao pode ser executado! VerIFique os parametros."
#DEFINE STR0007 " Atenção! "
#DEFINE STR0008 " Processando..."         

#DEFINE STR0009 " Falha ao gerar Objeto XML : "
#DEFINE STR0010 " Ocorreu um erro na gravacao do arquivo. Continua? "

Function definefiscal()

	Private oCreateDef
	
	Private cString := "XXJ"
	
	dbSelectArea("XXJ")
	dbSetOrder(1)
	
	@ 200,01 TO 380,380 DIALOG oCreateDef TITLE OemToAnsi(STR0001)
	@ 02,10  TO 080,190
	@ 10,018 Say STR0002
	@ 18,018 Say STR0003
	@ 26,018 Say STR0004
	
	@ 70,128 BMPBUTTON TYPE 01 ACTION OkCreateDef()
	@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oCreateDef)
	
	Activate Dialog oCreateDef Centered

Return


Static Function OkCreateDef

	Private cArqTxt := __cArqFis
	Private nHdl    := fCreate(cArqTxt)
	
	Private cEOL    := "CHR(13)+CHR(10)"
	
	IF Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	EndIF
	
	IF nHdl == -1
		MsgAlert(STR0005+cArqTxt+STR0006,STR0007)
		Return
	EndIF
	
	Processa({|| RunCont() },STR0008)

Return

Static Function RunCont

	Local nTamLin 	:= 0
	Local nLin		:= 0
	Local cCpo		:= ""
	
	Local cError	:= ""
	Local cWarning	:= ""
	Local oXML		:= NIL
	
	Local nX		:= 0
	Local nY		:= 0
	Local nZ		:= 0
	Local nXZ2Itens	:= 0
	Local nXZ5Itens	:= 0
	Local nXZ4Itens	:= 0
	
	dbSelectArea(cString)
	dbGoTop()
	
	ProcRegua(RecCount())
	
	While !Eof()
	
		BEGIN SEQUENCE
		
		IncProc()
		
		nTamLin	:= 2
		cLin	:= Space(nTamLin)+cEOL
	
		oXml := XmlParser(XXJ->XXJ_LAYOUT,"_",@cError,@cWarning)
	
		IF (oXml == NIL )
			MsgStop(STR0009+cError+" / "+cWarning)
			Return
		EndIF
		
		// cabecalho do arquivo de definicoes
		
		fWrite(nHdl,"["+oXml:_CFGA600:_XZ1MASTER:_XZ1_DESC:_VALUE:TEXT+"-GENERAL]"+cEOL)
		
		// obterm o titulo e conteudo dos nós do XML
		
		oDetXZ1Info := oXml:_CFGA600:_XZ1MASTER
		
		IF Type("oDetXZ1Info:_XZ1_ADAPT") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_ADAPT:REALNAME+"="+oDetXZ1Info:_XZ1_ADAPT:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_DECSEP") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_DECSEP:REALNAME+"="+oDetXZ1Info:_XZ1_DECSEP:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_DESC") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_DESC:REALNAME+"="+oDetXZ1Info:_XZ1_DESC:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_DESTAB") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_DESTAB:REALNAME+"="+oDetXZ1Info:_XZ1_DESTAB:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_DETOPC") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_DETOPC:REALNAME+"="+oDetXZ1Info:_XZ1_DETOPC:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_EMULTC") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_EMULTC:REALNAME+"="+oDetXZ1Info:_XZ1_EMULTC:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_IMPEXP") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_IMPEXP:REALNAME+"="+oDetXZ1Info:_XZ1_IMPEXP:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_LAYOUT") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_LAYOUT:REALNAME+"="+oDetXZ1Info:_XZ1_LAYOUT:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_MVCMET") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_MVCMET:REALNAME+"="+oDetXZ1Info:_XZ1_MVCMET:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_MVCOPT") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_MVCOPT:REALNAME+"="+oDetXZ1Info:_XZ1_MVCOPT:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_ORDER") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_ORDER:REALNAME+"="+oDetXZ1Info:_XZ1_ORDER:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_SEPARA") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_SEPARA:REALNAME+"="+oDetXZ1Info:_XZ1_SEPARA:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_SEPFIN") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_SEPFIN:REALNAME+"="+oDetXZ1Info:_XZ1_SEPFIN:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_SEPINI") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_SEPINI:REALNAME+"="+oDetXZ1Info:_XZ1_SEPINI:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_SOURCE") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_SOURCE:REALNAME+"="+oDetXZ1Info:_XZ1_SOURCE:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_STRUC") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_STRUC:REALNAME+"="+oDetXZ1Info:_XZ1_STRUC:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_TABLE") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_TABLE:REALNAME+"="+oDetXZ1Info:_XZ1_TABLE:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_TIPDAT") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_TIPDAT:REALNAME+"="+oDetXZ1Info:_XZ1_TIPDAT:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_TYPE") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_TYPE:REALNAME+"="+oDetXZ1Info:_XZ1_TYPE:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_TYPEXA") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_TYPEXA:REALNAME+"="+oDetXZ1Info:_XZ1_TYPEXA:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_VERSIO") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_VERSIO:REALNAME+"="+oDetXZ1Info:_XZ1_VERSIO:_VALUE:TEXT+cEOL)
		EndIF                              
		IF Type("oDetXZ1Info:_XZ1_SEPINASP") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_SEPINASP:REALNAME+"="+oDetXZ1Info:_XZ1_SEPINASP:_VALUE:TEXT+cEOL)
		EndIF		
		IF Type("oDetXZ1Info:_XZ1_PRE") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_PRE:REALNAME+"="+oDetXZ1Info:_XZ1_PRE:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_POS") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_POS:REALNAME+"="+oDetXZ1Info:_XZ1_POS:_VALUE:TEXT+cEOL)	
		EndIF
		IF Type("oDetXZ1Info:_XZ1_TDATA") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_TDATA:REALNAME+"="+oDetXZ1Info:_XZ1_TDATA:_VALUE:TEXT+cEOL)
		EndIF
		IF Type("oDetXZ1Info:_XZ1_CANDO") <> "U"
			fWrite(nHdl,oDetXZ1Info:_XZ1_CANDO:REALNAME+"="+oDetXZ1Info:_XZ1_CANDO:_VALUE:TEXT+cEOL)
		EndIF			                                                                       
		
		
		// detalhes do arquivo de definicoes
		
		fWrite(nHdl,"["+oXml:_CFGA600:_XZ1MASTER:_XZ1_DESC:_VALUE:TEXT+"-DETAILS]"+cEOL)
		
		oDetXZ2Total := oXml:_CFGA600:_XZ1MASTER:_XZ2DETAIL:_ITEMS
		
		IF Type("oDetXZ2Total:_ITEM") <> "U"
			nXZ2Itens := Len(oDetXZ2Total:_ITEM) // verIFico o total de itens abaixo do nó abaixo do xz2
		EndIF
		
		For nX := 1 To nXZ2Itens
			
			IF ValType("oDetXZ2Total:_ITEM[nX]:_DELETED") <> "U"
				fWrite(nHdl,oDetXZ2Total:_ITEM[nX]:_DELETED:REALNAME+"="+oDetXZ2Total:_ITEM[nX]:_DELETED:TEXT+cEOL)
			EndIF
			IF ValType("oDetXZ2Total:_ITEM[nx]:_ID") <> "U"
				fWrite(nHdl,oDetXZ2Total:_ITEM[nx]:_ID:REALNAME+"="+oDetXZ2Total:_ITEM[nX]:_ID:TEXT+cEOL)
			EndIF
			IF ValType("oDetXZ2Total:_ITEM[nX]:_XZ2_CHANEL") <> "U"
				fWrite(nHdl,oDetXZ2Total:_ITEM[nX]:_XZ2_CHANEL:REALNAME+"="+oDetXZ2Total:_ITEM[nX]:_XZ2_CHANEL:TEXT+cEOL)
			EndIF
			IF ValType("oDetXZ2Total:_ITEM[nX]:_XZ2_SEQ") <> "U"
				fWrite(nHdl,oDetXZ2Total:_ITEM[nX]:_XZ2_SEQ:REALNAME+"="+oDetXZ2Total:_ITEM[nX]:_XZ2_SEQ:TEXT+cEOL)
			EndIF
			
			IF ValType("oDetXZ2Total:_ITEM[nX]:_XZ3DETAIL:_XZ3_CHANEL") <> "U"
				fWrite(nHdl,oDetXZ2Total:_ITEM[nX]:_XZ3DETAIL:_XZ3_CHANEL:REALNAME+"="+oDetXZ2Total:_ITEM[nX]:_XZ3DETAIL:_XZ3_CHANEL:_VALUE:TEXT+cEOL)
			EndIF
			IF ValType("oDetXZ2Total:_ITEM[nX]:_XZ3DETAIL:_XZ3_DESC") <> "U"
				fWrite(nHdl,oDetXZ2Total:_ITEM[nX]:_XZ3DETAIL:_XZ3_DESC:REALNAME+"="+oDetXZ2Total:_ITEM[nX]:_XZ3DETAIL:_XZ3_DESC:_VALUE:TEXT+cEOL)
			EndIF
			IF ValType("oDetXZ2Total:_ITEM[nX]:_XZ3DETAIL:_XZ3_IDOUT") <> "U"
				fWrite(nHdl,oDetXZ2Total:_ITEM[nX]:_XZ3DETAIL:_XZ3_IDOUT:REALNAME+"="+oDetXZ2Total:_ITEM[nX]:_XZ3DETAIL:_XZ3_IDOUT:_VALUE:TEXT+cEOL)
			EndIF
			IF ValType("oDetXZ2Total:_ITEM[nX]:_XZ3DETAIL:_XZ3_OCCURS") <> "U"
				fWrite(nHdl,oDetXZ2Total:_ITEM[nX]:_XZ3DETAIL:_XZ3_OCCURS:REALNAME+"="+oDetXZ2Total:_ITEM[nX]:_XZ3DETAIL:_XZ3_OCCURS:_VALUE:TEXT+cEOL)
			EndIF  
			IF ValType("oDetXZ2Total:_ITEM[nX]:_XZ3DETAIL:_XZ3_POS") <> "U"
				fWrite(nHdl,oDetXZ2Total:_ITEM[nX]:_XZ3DETAIL:_XZ3_POS:REALNAME+"="+oDetXZ2Total:_ITEM[nX]:_XZ3DETAIL:_XZ3_POS:_VALUE:TEXT+cEOL)
			EndIF	
			
			oDetXZ4Total := oXml:_CFGA600:_XZ1MASTER:_XZ2DETAIL:_ITEMS:_ITEM[nX]:_XZ4DETAIL
			
			IF Type("oDetXZ4Total:_ITEMS") <> "U"
				
				IF Type("oDetXZ4Total:_ITEMS:_ITEM") == "A"
					
					nXZ4Itens := Len(oDetXZ4Total:_ITEMS:_ITEM) // verIFico o total de itens abaixo do nó xz4
					
					IF nXZ4Itens > 0
						
						For nZ := 1 To nXZ4Itens
							
							oDetXZ4Itens := oXML:_CFGA600:_XZ1MASTER:_XZ2DETAIL:_ITEMS:_ITEM[nX]:_XZ4DETAIL:_ITEMS:_ITEM[nZ]
							
							IF Type("oDetXZ4Itens:_XZ4_CHANEL") <> "U"
								fWrite(nHdl,oDetXZ4Itens:_XZ4_CHANEL:REALNAME+"="+oDetXZ4Itens:_XZ4_CHANEL:TEXT+cEOL)
							EndIF
							IF Type("oDetXZ4Itens:_XZ4_COND") <> "U"
								fWrite(nHdl,oDetXZ4Itens:_XZ4_COND:REALNAME+"="+oDetXZ4Itens:_XZ4_COND:TEXT+cEOL)
							EndIF
							
							IF Type("oDetXZ4Itens:_XZ4_DESC") <> "U"
								fWrite(nHdl,oDetXZ4Itens:_XZ4_DESC:REALNAME+"="+oDetXZ4Itens:_XZ4_DESC:TEXT+cEOL)
							EndIF
							
							IF Type("oDetXZ4Itens:_XZ4_EXEC") <> "U"
								fWrite(nHdl,oDetXZ4Itens:_XZ4_EXEC:REALNAME+"="+oDetXZ4Itens:_XZ4_EXEC:TEXT+cEOL)
							EndIF
							
							IF Type("oDetXZ4Itens:_XZ4_FIELD") <> "U"
								fWrite(nHdl,oDetXZ4Itens:_XZ4_FIELD:REALNAME+"="+oDetXZ4Itens:_XZ4_FIELD:TEXT+cEOL)
							EndIF
							
							IF Type("oDetXZ4Itens:_XZ4_LAYOUT") <> "U"
								fWrite(nHdl,oDetXZ4Itens:_XZ4_LAYOUT:REALNAME+"="+oDetXZ4Itens:_XZ4_LAYOUT:TEXT+cEOL)
							EndIF
							
							IF Type("oDetXZ4Itens:_XZ4_NOVAL") <> "U"
								fWrite(nHdl,oDetXZ4Itens:_XZ4_NOVAL:REALNAME+"="+oDetXZ4Itens:_XZ4_NOVAL:TEXT+cEOL)
							EndIF
							
							IF Type("oDetXZItens:_XZ4_OBS") <> "U"
								fWrite(nHdl,oDetXZ4Itens:_XZ4_OBS:REALNAME+"="+oDetXZ4Itens:_XZ4_OBS:TEXT+cEOL)
							EndIF
							
							IF Type("oDetXZ4Itens:_XZ4_SEQ") <> "U"
								fWrite(nHdl,oDetXZ4Itens:_XZ4_SEQ:REALNAME+"="+oDetXZ4Itens:_XZ4_SEQ:TEXT+cEOL)
							EndIF
							IF Type("oDetXZ4Itens:_XZ4_SOURCE") <> "U"
								fWrite(nHdl,oDetXZ4Itens:_XZ4_SOURCE:REALNAME+"="+oDetXZ4Itens:_XZ4_SOURCE:TEXT+cEOL)
							EndIF
							
							IF Type("oDetXZ4Itens:_XZ4_TYPFLD") <> "U"
								fWrite(nHdl,oDetXZ4Itens:_XZ4_TYPFLD:REALNAME+"="+oDetXZ4Itens:_XZ4_TYPFLD:TEXT+cEOL)
							EndIF						
													
						Next Nz
						
					EndIF
					
				Else
					
					oDetXZ4Itens := oXML:_CFGA600:_XZ1MASTER:_XZ2DETAIL:_ITEMS:_ITEM[nX]:_XZ4DETAIL:_ITEMS:_ITEM				
					
					IF Type("oDetXZ4Itens:_XZ4_CHANEL") <> "U"
						fWrite(nHdl,oDetXZ4Itens:_XZ4_CHANEL:REALNAME+"="+oDetXZ4Itens:_XZ4_CHANEL:TEXT+cEOL)
					EndIF
					IF Type("oDetXZ4Itens:_XZ4_COND") <> "U"
						fWrite(nHdl,oDetXZ4Itens:_XZ4_COND:REALNAME+"="+oDetXZ4Itens:_XZ4_COND:TEXT+cEOL)
					EndIF
					
					IF Type("oDetXZ4Itens:_XZ4_DESC") <> "U"
						fWrite(nHdl,oDetXZ4Itens:_XZ4_DESC:REALNAME+"="+oDetXZ4Itens:_XZ4_DESC:TEXT+cEOL)
					EndIF
					
					IF Type("oDetXZ4Itens:_XZ4_EXEC") <> "U"
						fWrite(nHdl,oDetXZ4Itens:_XZ4_EXEC:REALNAME+"="+oDetXZ4Itens:_XZ4_EXEC:TEXT+cEOL)
					EndIF
					
					IF Type("oDetXZ4Itens:_XZ4_FIELD") <> "U"
						fWrite(nHdl,oDetXZ4Itens:_XZ4_FIELD:REALNAME+"="+oDetXZ4Itens:_XZ4_FIELD:TEXT+cEOL)
					EndIF
					
					IF Type("oDetXZ4Itens:_XZ4_LAYOUT") <> "U"
						fWrite(nHdl,oDetXZ4Itens:_XZ4_LAYOUT:REALNAME+"="+oDetXZ4Itens:_XZ4_LAYOUT:TEXT+cEOL)
					EndIF
					
					IF Type("oDetXZ4Itens:_XZ4_NOVAL") <> "U"
						fWrite(nHdl,oDetXZ4Itens:_XZ4_NOVAL:REALNAME+"="+oDetXZ4Itens:_XZ4_NOVAL:TEXT+cEOL)
					EndIF
					
					IF Type("oDetXZItens:_XZ4_OBS") <> "U"
						fWrite(nHdl,oDetXZ4Itens:_XZ4_OBS:REALNAME+"="+oDetXZ4Itens:_XZ4_OBS:TEXT+cEOL)
					EndIF
					
					IF Type("oDetXZ4Itens:_XZ4_SEQ") <> "U"
						fWrite(nHdl,oDetXZ4Itens:_XZ4_SEQ:REALNAME+"="+oDetXZ4Itens:_XZ4_SEQ:TEXT+cEOL)
					EndIF
					
					IF Type("oDetXZ4AItens:_XZ4_SOURCE") <> "U"
						fWrite(nHdl,oDetXZ4Itens:_XZ4_SOURCE:REALNAME+"="+oDetXZ4Itens:_XZ4_SOURCE:TEXT+cEOL)
					EndIF
					
					IF Type("oDetXZ4Itens:_XZ4_TYPFLD") <> "U"
						fWrite(nHdl,oDetXZ4Itens:_XZ4_TYPFLD:REALNAME+"="+oDetXZ4Itens:_XZ4_TYPFLD:TEXT+cEOL)
					EndIF												
					
				EndIF
				
			EndIF
			
			
			// tratamento do XZ5
			
			
			oDetXZ5Total := oXml:_CFGA600:_XZ1MASTER:_XZ2DETAIL:_ITEMS:_ITEM[nX]:_XZ5DETAIL
			
			IF Type("oDetXZ5Total:_ITEMS") <> "U"
				
				IF Type("oDetXZ5Total:_ITEMS:_ITEM") == "A"
					
					nXZ5Itens := Len(oDetXZ5Total:_ITEMS:_ITEM) // verIFico o total de itens abaixo do nó xz5
					
					IF nXZ5Itens > 0
						
						For nY := 1 To nXZ5Itens
							
							oDetXZ5Itens := oXML:_CFGA600:_XZ1MASTER:_XZ2DETAIL:_ITEMS:_ITEM[nX]:_XZ5DETAIL:_ITEMS:_ITEM[nY]
	
							IF Type("oDetXZ5Itens:_XZ5_EXEC") <> "U"
								fWrite(nHdl,oDetXZ5Itens:_XZ5_EXEC:REALNAME+"="+oDetXZ5Itens:_XZ5_EXEC:TEXT+cEOL)
							EndIF
	
							IF Type("oDetXZ5Itens:_XZ5_FIELD") <> "U"
								fWrite(nHdl,oDetXZ5Itens:_XZ5_FIELD:REALNAME+"="+oDetXZ5Itens:_XZ5_FIELD:TEXT+cEOL)
							EndIF
	
							IF Type("oDetXZ5Itens:_XZ5_SEQ") <> "U"
								fWrite(nHdl,oDetXZ5Itens:_XZ5_SEQ:REALNAME+"="+oDetXZ5Itens:_XZ5_SEQ:TEXT+cEOL)
							EndIF
							
							IF Type("oDetXZ5Itens:_XZ5_OBS") <> "U"
								fWrite(nHdl,oDetXZ5Itens:_XZ5_OBS:REALNAME+"="+oDetXZ5Itens:_XZ5_OBS:TEXT+cEOL)
							EndIF
							
							IF Type("oDetXZ5Itens:_XZ5_SOURCE") <> "U"
								fWrite(nHdl,oDetXZ5Itens:_XZ5_SOURCE:REALNAME+"="+oDetXZ5Itens:_XZ5_SOURCE:TEXT+cEOL)
							EndIF
							IF Type("oDetXZ5Itens:_XZ5_TYPFLD") <> "U"
								fWrite(nHdl,oDetXZ5Itens:_XZ5_TYPFLD:REALNAME+"="+oDetXZ5Itens:_XZ5_TYPFLD:TEXT+cEOL)
							EndIF
							
							IF Type("oDetXZ5Itens:_XZ5_COND") <> "U"
								fWrite(nHdl,oDetXZ5Itens:_XZ5_COND:REALNAME+"="+oDetXZ5Itens:_XZ5_COND:TEXT+cEOL)
							EndIF
							
							
							
							
						Next nY
						
					EndIF
					
				Else
					
					oDetXZ5Itens := oXML:_CFGA600:_XZ1MASTER:_XZ2DETAIL:_ITEMS:_ITEM[nX]:_XZ5DETAIL:_ITEMS:_ITEM
					
					
					IF Type("oDetXZ5Itens:_XZ5_EXEC") <> "U"
						fWrite(nHdl,oDetXZ5Itens:_XZ5_EXEC:REALNAME+"="+oDetXZ5Itens:_XZ5_EXEC:TEXT+cEOL)
					EndIF
	
					IF Type("oDetXZ5Itens:_XZ5_FIELD") <> "U"
						fWrite(nHdl,oDetXZ5Itens:_XZ5_FIELD:REALNAME+"="+oDetXZ5Itens:_XZ5_FIELD:TEXT+cEOL)
					EndIF
	
					IF Type("oDetXZ5Itens:_XZ5_SEQ") <> "U"
						fWrite(nHdl,oDetXZ5Itens:_XZ5_SEQ:REALNAME+"="+oDetXZ5Itens:_XZ5_SEQ:TEXT+cEOL)
					EndIF
							
					IF Type("oDetXZ5Itens:_XZ5_OBS") <> "U"
						fWrite(nHdl,oDetXZ5Itens:_XZ5_OBS:REALNAME+"="+oDetXZ5Itens:_XZ5_OBS:TEXT+cEOL)
					EndIF
					
					IF Type("oDetXZ5Itens:_XZ5_SOURCE") <> "U"
						fWrite(nHdl,oDetXZ5Itens:_XZ5_SOURCE:REALNAME+"="+oDetXZ5Itens:_XZ5_SOURCE:TEXT+cEOL)
					EndIF
					
					IF Type("oDetXZ5Itens:_XZ5_TYPFLD") <> "U"
						fWrite(nHdl,oDetXZ5Itens:_XZ5_TYPFLD:REALNAME+"="+oDetXZ5Itens:_XZ5_TYPFLD:TEXT+cEOL)
					EndIF
							
					IF Type("oDetXZ5Itens:_XZ5_COND") <> "U"
						fWrite(nHdl,oDetXZ5Itens:_XZ5_COND:REALNAME+"="+oDetXZ5Itens:_XZ5_COND:TEXT+cEOL)
					EndIF                                                                                 					
			
				EndIF
				
			EndIF
			
			fWrite(nHdl,cEOL)		
			
		Next nX
		
		fWrite(nHdl,"[#----------------------------#]"+cEOL)
		
		IF fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			IF !MsgAlert(STR0010,STR0007)
				BREAK
			EndIF
		EndIF
		
		dbSkip()    
		
		END SEQUENCE
		
	EndDo()
	
	fClose(nHdl)
	Close(oCreateDef)

Return

Static Function __Dummy( lRecursa )
	BEGIN SEQUENCE
		lRecursa := .F.
		IF !( lRecursa )
			BREAK
		EndIF
		DefineFiscal()
	   	lRecursa := __Dummy( lRecursa )
	END SEQUENCE
Return( lRecursa )