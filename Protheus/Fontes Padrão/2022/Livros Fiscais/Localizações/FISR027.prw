#include "RwMake.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "FISR027A.ch"

#define PIX_DIF_COLUNA_VALORES			350		// Pixel inicial para impressao dos tracos das colunas dinamicas
#define PIX_INICIAL_VALORES				470		// Pixel para impressao do traco vertical
#define PIX_EQUIVALENTE			  		340		// Pixel inicial para impressao das colunas dinamicas

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funci¢n ³ FISR016 ³ Autor ³ Cesar Bautista      ³ Data ³ Abril/2018    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.³ LIBRO DE RETENCION DE IVA Y LIBRO DE ISLR  -VENEZUELA        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso     ³ SIGAFIS                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³gsantacruz  ³ DMINA-3190³Sustituimos F1_NUMAUTO por F1_FORMLIB.        ³±±
±±³                        ³El archvo de IVA separador con tabulador.     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISR027()

Local olReport

Private cPerg     := "FISR027"
Private aExcel := {}

Private dFecIni	:=ctod("  /  /  ")
Private dFecFin	:=ctod("  /  /  ")
Private cAnioEnv:=''
Private cMesEnv:=''
Private cRuta:=''
Private nTipo:=0
 	
If TRepInUse()
		olReport := FISR027imp()
		olReport:SetParam(cPerg)
		olReport:PrintDialog()
		If nTipo == 1 //1 -Ret. IVA; 2 - Ret ISLR              
			GerArqI(cRuta)
		Else
			GerArqR (cRuta)
		EndIf
EndIf
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FISR027imp  ³ Autor ³ Jose Lucas         ³ Data | 18/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressão do relatorio Comprovante de IVA no formato A3.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISR023xA4(cPerg)           				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Perguntas dos parametros.                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function FISR027imp

Local clNomProg		:= FunName()
Local clTitulo 		:= ""
Local clDesc   		:= clTitulo 
Local olReport
Local lLandScape    := .T.

olReport:=TReport():New(clNomProg,clTitulo,,{|olReport| FISProc(olReport)},clDesc,lLandScape)
olReport:SetLandscape()					// Formato paisagem
olReport:oPage:nPaperSize	:= 1  		// Impressão em papel A4 - LandScape 9=a4,1=Carta,5=Oficio,8=A3
olReport:lHeaderVisible 	:= .T. 		// Não imprime cabeçalho do protheus
olReport:lFooterVisible 	:= .T.		// Não imprime rodapé do protheus
olReport:lParamPage			:= .F.		// Não imprime pagina de parametros

olReport:DisableOrientation()           // Não permite mudar o formato de impressão para Vertical, somente landscape
olReport:SetEdit(.F.)                   // Não permite personilizar o relatório, desabilitando o botão <Personalizar>
Return olReport
 
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FISProc   ³ Autor ³ Totvs              ³ Data | 06/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressão do relatorio.								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISProc( ExpC1 )         				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Objeto tReport                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FISProc( olReport )

Local nReg		 := 0 //Quantidade de registros impressos
Local nPag		 := 0 //Quantidade de paginas por pagina

Local clSql		 := ""
Local aEquivale  := { 0, 0, 0, 0, 0}
Local nTotalCols := Len( aEquivale )

Local aTotais	 := Array( nTotalCols )

Local oFont8 	 := TFont():New( "Courier New",, -08 )
Local oFont9 	 := TFont():New( "Courier New",, -09 )
Local oFont10 	 := TFont():New( "Courier New",, -10 )
Local nTrans     := 0
Local nRowStart	 := 0
Local lFirstPage := .T.

Local nPagina    := 0
Local cTmpFor:= ''
Local cTmpLoj:= ''
Local cTmpSer:= ''
Local cTmpCer:= ''

Pergunte(cPerg,.F.)
		
dFecIni	:=MV_PAR01 //Fecha inicial basada en los movimientos de la tabla SFE
dFecFin	:=MV_PAR02 //Fecha final basada en los movimientos de la tabla SFE
cAnioEnv:=MV_PAR03 //Año del periodo impositivo 
cMesEnv	:=MV_PAR04 //Mes del periodo impositivo
cRuta	:=MV_PAR05 //Lugar donde será almacenado el archivo TXT con la información requerida por SENIAT acorde a la especificación de RETENCION de ISLR o IVA.
nTipo	:=MV_PAR06 //Formato a ser generado según la selección del usuario la cual puede ser opción 1=Retención de IVA;2=Retención de ISLR



 //Titulo del Reporte
olReport:SetTitle(iIf(nTipo==1,STR0001,STR0034))//"DECLARACION INFORMATIVA RETENCION DE IVA - VENEZUELA" # "DECLARACION INFORMATIVA RETENCION DE ISLR  - VENEZUELA"
 
// Inicia o array totalizador com zero
aFill( aTotais, 0 )

dbSelectArea("SM0")
cRIFAGENTE := Alltrim(M0_CGC)
cRIFAGENTE := If(Empty(cRIFAGENTE),"00000000000",cRIFAGENTE)
If nTipo == 1 // 1=Retención de IVA;
	
		clSql := "SELECT  '" + cRIFAGENTE + "' RIFAGENTE, "
		clSql += " SFE.FE_FORNECE, "
		clSql += " SFE.FE_LOJA, "
		clSql += " SFE.FE_NROCERT, "
		clSql += " SFE.FE_EMISSAO, "
		clSql += " SFE.FE_NFISCAL, "
		clSql += " SFE.FE_SERIE, "
		clSql += " SFE.FE_ORDPAGO, "
		clSql += " SFE.FE_CONCEPT, "
		clSql += " SF1.F1_NATUREZ, "
		clSql += " SFE.FE_VALIMP, "
		clSql += " SF1.F1_VALMERC , "
		clSql += " SF1.F1_FORMLIB , "
		clSql += " SFE.FE_VALBASE, "
		clSql += " SFE.FE_ALIQ   , "
		clSql += " SFE.FE_VALIMP, "
		clSql += " SFE.FE_RETENC , "
		clSql += " SFE.FE_ESPECIE, "
		clSql += " SEK.EK_EMISSAO, "
		clSql += " SFE.FE_TIPO, "
		clSql += " SFE.FE_DEDUC, "
		clSql += " SA2.A2_NOME, "
		clSql += " SA2.A2_CGC, "
		clSql += " SA2.A2_ESTADO, "
		clSql += " SA2.A2_TIPO, "
		clSql += " SFE.FE_CONCEPT, "
		clSql += " SFE.R_E_C_N_O_, "
		clSql += " SF3.F3_ALQIMP1, "
		clSql += " SF3.F3_ESPECIE, "
		clSql += " SF3.F3_EXENTAS "
		clSql += " FROM " 				+ 	RetSqlName("SFE") + " SFE "
		clSql += " LEFT OUTER JOIN " 	+ 	RetSqlName("SF1") + " SF1 "
		clSql += " ON SFE.FE_NFISCAL	=	SF1.F1_DOC 	AND "
		clSql += " SFE.FE_SERIE   		= 	SF1.F1_SERIE AND "
		clSql += " SFE.FE_FORNECE 		= 	SF1.F1_FORNECE AND "
		clSql += " SFE.FE_LOJA   		= 	SF1.F1_LOJA "
		clSql += " LEFT OUTER JOIN "	+	RetSqlName("SA2") + " SA2 "
		clSql += " ON SFE.FE_FORNECE 	= 	SA2.A2_COD AND "
		clSql += " SFE.FE_LOJA	 		= 	SA2.A2_LOJA "
		clSql += " LEFT OUTER JOIN "	+ 	RetSqlName("SEK") + " SEK "
		clSql += " ON SFE.FE_ORDPAGO 	= 	SEK.EK_ORDPAGO AND "
		clSql += " SFE.FE_FORNECE		=	SEK.EK_FORNECE "
		
		clSql += " LEFT OUTER JOIN " + 	RetSqlName("SF3") + " SF3 " 
		clSql += " ON SFE.FE_NFISCAL = SF3.F3_NFISCAL AND "
		clSql += " SFE.FE_SERIE = SF3.F3_SERIE AND "
		clSql += " SFE.FE_FORNECE = SF3.F3_CLIEFOR AND "
		clSql += " SFE.FE_LOJA = SF3.F3_LOJA AND SF3.F3_TIPOMOV = 'C' "
		
		clSql += " WHERE SFE.FE_FILIAL  = '" + xFilial("SFE") + "'"
		clSql += "  AND SFE.FE_EMISSAO BETWEEN '" + DTOS(dFecIni) + "' AND '" + DTOS(dFecFin) + "' "
		
		clSql += "  AND SFE.FE_TIPO	= 'I' "
		If TcSrvType() == "AS/400"
			clSql += " AND @SFE.DELETED@ <> '*' "
		Else
			clSql += " AND SFE.D_E_L_E_T_ <> '*' "
		EndIf
		clSql += " ORDER BY SFE.FE_FORNECE,SFE.FE_LOJA, SFE.FE_NFISCAL,SFE.FE_SERIE,SFE.FE_CONCEPT " 
		
		clSql := ChangeQuery( clSql  )
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, clSql ), "PER",.T.,.T.)
		
		TCSetField( "PER", "FE_EMISSAO",  "D", 08, 0 )
		TCSetField( "PER", "EK_EMISSAO",  "D", 08, 0 )
		TCSetField( "PER", "FE_VALBASE",  "N", TamSX3( "FE_VALBASE" )[1], TamSX3( "FE_VALBASE" )[2] )
		
		dbSelectArea( "PER" )
		PER->( dbGoTop() )
		While !PER->(Eof())
		
				cTmpFor:= PER->FE_FORNECE
				cTmpLoj:= PER->FE_LOJA
				cTmpSer:= PER->FE_SERIE
				cTmpCer:= PER->FE_NROCERT
				
	
				cRifAge:=alltrim( PER->RIFAGENTE)
				dFecEmi:=PER->FE_EMISSAO
				
				cCGC:=PER->A2_CGC
				cNfiscal:=alltrim(PER->FE_NFISCAL)
				cFORMLIB:=alltrim(PER->F1_FORMLIB)
				cNROCERT:=alltrim(PER->FE_NROCERT)
				cTmpCon:= alltrim(PER->FE_CONCEPT)
				nTOTCOM:=PER->F1_VALMERC 
				nValBase:=0
				nRetenc:=0
			  
	
				cEspecie:=PER->FE_ESPECIE
				
		       	If AllTriM(cEspecie) $ "NCP/NDP"
		            	cNFiscalOri := R085PgNC() 	//Obter numero da Nota Fiscal Original quando NCP o NDC
		        EndIF
				
				nAliq:=0;nSumExe:=0
				lVez:=.t.
				
		       While !PER->(Eof()) .AND. alltrim(cTmpFor)==alltrim(PER->FE_FORNECE) .and. alltrim(cTmpLoj)==alltrim(PER->FE_LOJA) .and. alltrim(cNfiscal)==alltrim(PER->FE_NFISCAL);
		            .AND. alltrim(cTmpSer)== alltrim(PER->FE_SERIE)
		             nTOTCOM+=PER->FE_VALIMP
					nValBase+=PER->FE_VALBASE
					nRetenc+=PER->FE_RETENC
					cTmpCon:= alltrim(PER->FE_CONCEPT)
		       		While !PER->(Eof()) .AND. alltrim(cTmpFor)==alltrim(PER->FE_FORNECE) .and. alltrim(cTmpLoj)==alltrim(PER->FE_LOJA) .and. alltrim(cNfiscal)==alltrim(PER->FE_NFISCAL);
		            		.AND. alltrim(cTmpSer)== alltrim(PER->FE_SERIE) .AND. alltrim(cTmpCon)== alltrim(PER->FE_CONCEPT)
		
		           		if lVez //solo la 1era vez suma lo  contenido en sf3
		           		 			 
		            				nSumExe+=PER->F3_EXENTAS
		            				IF PER->F3_ALQIMP1>0
										nAliq:=PER->F3_ALQIMP1
									ENDIF	
		       			endif	
          	
		            	PER->( dbSkip() )
		           enddo	
					lVez:= .f.
			   enddo	
								
					nPagina ++
		
					If olReport:Cancel()
						Exit
					EndIf
		 
		    		If lFirstPage
						FCabR085A4( olReport, nPagina ) //Impressão do cabeçalho
						lFirstPage := .F.
					EndIf
		
					// Determina o pixel vertical inicial
					nRowStart := olReport:Row()
		
					cNFiscalOri :=""
		         	
					olReport:SetMeter( RecCount() )
		
					nTrans += 1
					olReport:Say( olReport:Row(), olReport:Col()+0120, IIf(Empty(cRifAge)," ", Transform(cRifAge,"@!")),oFont8,11 ) //RIF Agente
					olReport:Say( olReport:Row(), olReport:Col()+0285, Iif(Empty(AllTrim(cAnioEnv+cMesEnv))," ", AllTrim(cAnioEnv+cMesEnv)),oFont8,6  )//Año Mes
									
					olReport:Say( olReport:Row(), olReport:Col()+0385,DtoC(dFecEmi),oFont8 )//-- 'Fecha documento  Formato AAAA-mm-DD
					cTiDoc := "  "
					If AllTrim(cEspecie) == "NF"
						cTiDoc := "01"
					ElseIf AllTrim(cEspecie) $ "NDI/NDP"
						cTiDoc := "02"
					ElseIf AllTrim(cEspecie) $ "NCI/NCP"
						cTiDoc := "03"
					Else
						cTiDoc := "04"
					EndIf
					olReport:Say( olReport:Row(), olReport:Col()+0540,"C",oFont8,1 ) //Tipo Operacion
					olReport:Say( olReport:Row(), olReport:Col()+0600,cTiDoc,oFont8,2 ) //Tipo Doc
					olReport:Say( olReport:Row(), olReport:Col()+0670,Iif(Empty(cCGC)," ", Transform(AllTrim(cCGC),"@!")),oFont8,11 )//RIF Proveedor
					olReport:Say( olReport:Row(), olReport:Col()+0820, Iif(Empty(cNFISCAL)," ", Transform(AllTrim(cNFISCAL),"@!")),oFont8,6 )//Numero documento
					olReport:Say( olReport:Row(), olReport:Col()+1000, Iif(Empty(cFORMLIB)," ", Transform(AllTrim(cFORMLIB),"@!")),oFont8,6 )//Numero de Control
					olReport:Say( olReport:Row(), olReport:Col()+1200, Iif(Empty(nTOTCOM)," ", Transform(nTOTCOM,"@E 999,999,999.99")),	oFont8,14 )//Monto Total Documento
					olReport:Say( olReport:Row(), olReport:Col()+1450, Iif(Empty(nValBase)," ", Transform(nValBase,"@E 999,999,999.99")),	oFont8,14 )// Base Imponible'
					olReport:Say( olReport:Row(), olReport:Col()+1700, Iif(Empty(nRetenc)," ", Transform(nRetenc,	"@E 999,999,999.99")),	oFont8,14 )//Monto IVA'
			
					If !Empty(cNFiscalOri)
						olReport:Say( olReport:Row(), olReport:Col()+1850, Iif(Empty(cNFiscalOri),"0", AllTrim(cNFiscalOri)),oFont8,6 )//Número da Factura Afetada'
		   			EndIf
		
					olReport:Say( olReport:Row(), olReport:Col()+2080,Iif(Empty(cNROCERT), " ", Padr(Transform(cNROCERT,"@R 9999-99-99999999"),16)),oFont8,16 )//Numero Comprobante
					olReport:Say( olReport:Row(), olReport:Col()+2340, Transform(nSumExe,"@E 999,999,999.99"),	oFont8 )//Monto excento IVA  
					olReport:Say( olReport:Row(), olReport:Col()+2580, Transform(nAliq,"@E 99.99"),oFont8,5 )// Alicuota' 
					olReport:Say( olReport:Row(), olReport:Col()+2780,"0" ,	oFont8,1 ) //Numero expediente
		
					olReport:SkipLine( 1 )
		
					olReport:OnPageBreak( { || FCabR085A4( olReport, nPagina ) } )
					If nPag	> 80
						nPag  := 0
						olReport:EndPage()
						olReport:SetRow( nRowStart )
					EndIf
			
				Aadd(aExcel,{alltrim(cRifAge),; //RIF contribuyente
						 substr(AllTrim(cAnioEnv+cMesEnv),1,6),; //Periodo impositivo
						 dFecEmi,;//Fecha documento
						 "C",; //Tipo operacion
						 Iif(Empty(cTiDoc),"0",cTiDoc),; //Tipo documento
						 Iif(Empty(cCGC),  "0",alltrim(cCGC)),; //RIF COMPRADOR
						 Iif(Empty(cNFISCAL),"0",cNFISCAL),; //NUMERO DE DOCUMENTO
						 Iif(Empty(cFORMLIB),"0",cFORMLIB),; //NUMERO DE CONTROL DE DOCUMENTO
						 strtran(alltrim(Transform(nTOTCOM, "@E 999999999999.99")),",","."),;
						 strtran(alltrim(Transform(nValBase,"@E 999999999999.99")),",","."),;
						 strtran(alltrim(Transform(nRetenc, "@E 999999999999.99")),",","."),;
						 Iif(Empty(cNFiscalOri),"0",cNFiscalOri),;
						 Iif(Empty(cNroCert), "0" ,cNroCert),;
				         strtran(alltrim(Transform(nSumExe, "@E 999999999999.99")),",",".") ,;
				         strtran(alltrim(Transform(nAliq,   "@E 99.99")),",",".") ,;
				         "0"})
					nReg++
		
		
				olReport:IncMeter()
		EndDo
		PER->( dbCloseArea() )
else //2=Retención de ISLR 
		clSql := "SELECT DISTINCT '" + cRIFAGENTE + "' RIFAGENTE, "
		clSql += " FE_ESPECIE, "
		clSql += " FE_FORNECE, "
		clSql += " FE_LOJA, "
		clSql += " FE_NROCERT, "
		clSql += " FE_EMISSAO, "
		clSql += " F1_EMISSAO, "
		clSql += " FE_NFISCAL, "
		clSql += " FE_SERIE, "
		clSql += " F1_VALBRUT, "
		clSql += " F1_VALMERC, "
		clSql += " F1_VALIMP1, "
		clSql += " FE_VALBASE, "
		clSql += " F1_FORMLIB, "		
		clSql += " FE_TIPO, "
		clSql += " FE_ALIQ, "
		clSql += " FE_RETENC, "
		clSql += " FE_DEDUC, "
		clSql += " A2_NOME, "
		clSql += " A2_CGC, "
		clSql += " A2_END, "
		clSql += " A2_NR_END, "
		clSql += " A2_MUN, "
		clSql += " A2_TEL, "
		clSql += " A2_ESTADO, "
		clSql += " A2_TIPO, "
		clSql += " FE_CONCEPT, "
		clSql += " SFE.R_E_C_N_O_  "
		clSql += " FROM " + RetSqlName("SFE") + " SFE, "
		clSql += RetSqlName("SA2") + ", "
		clSql += RetSqlName("SF1")
		clSql += " WHERE FE_FILIAL = '" + xFilial("SFE") + "'"
		clSql += " and FE_EMISSAO >= '" + Dtos(dFecIni) + "'"
		If !Empty(dFecFin)
			clSql += " and FE_EMISSAO <= '" + Dtos(dFecFin) + "'"
		Endif
		clSql += " and FE_FORNECE 		= 	A2_COD 				"
		clSql += " and FE_LOJA	 		= 	A2_LOJA 				"
		clSql += " and FE_NFISCAL 		= 	F1_DOC      		"
		clSql += " and FE_FORNECE 		= 	F1_FORNECE  		"
		clSql += " and FE_LOJA 		= 	F1_LOJA  		"
		clSql += " and FE_SERIE   		= 	F1_SERIE    		"
		clSql += " and FE_TIPO	  		= 	'R'         		"
		clSql += " UNION "
		clSql += "SELECT DISTINCT '" + cRIFAGENTE + "' RIFAGENTE, "
		clSql += " FE_ESPECIE, "
		clSql += " FE_FORNECE, "
		clSql += " FE_LOJA, "
		clSql += " FE_NROCERT, "
		clSql += " FE_EMISSAO, "
		clSql += " F2_EMISSAO, "
		clSql += " FE_NFISCAL, "
		clSql += " FE_SERIE, "
		clSql += " F2_VALBRUT, "
		clSql += " F2_VALMERC, "
		clSql += " F2_VALIMP1, "
		clSql += " FE_VALBASE, "
		clSql += " F2_NUMAUT, "	
		clSql += " FE_TIPO, "
		clSql += " FE_ALIQ, "
		clSql += " FE_RETENC, "
		clSql += " FE_DEDUC, "
		clSql += " A2_NOME, "
		clSql += " A2_CGC, "
		clSql += " A2_END, "
		clSql += " A2_NR_END, "
		clSql += " A2_MUN, "
		clSql += " A2_TEL, "
		clSql += " A2_ESTADO, "
		clSql += " A2_TIPO, "
		clSql += " FE_CONCEPT, "
		clSql += " SFE.R_E_C_N_O_  "
		clSql += " FROM " + RetSqlName("SFE") + " SFE, "
		clSql += RetSqlName("SA2") + ", "
		clSql += RetSqlName("SF2")
		clSql += " WHERE FE_FILIAL = '" + xFilial("SFE") + "'"
		clSql += " and FE_EMISSAO >= '" + Dtos(dFecIni) + "'"
		If !Empty(dFecFin)
			clSql += " and FE_EMISSAO <= '" + Dtos(dFecFin) + "'"
		Endif
		clSql += " and FE_FORNECE 		= 	A2_COD 				"
		clSql += " and FE_LOJA	 		= 	A2_LOJA 				"
		clSql += " and FE_NFISCAL 		= 	F2_DOC      		"
		clSql += " and FE_FORNECE 		= 	F2_CLIENTE  		"
		clSql += " and FE_LOJA	 		= 	F2_LOJA  		"
		clSql += " and FE_SERIE   		= 	F2_SERIE    		"
		clSql += " and FE_TIPO	  		= 	'R'         		"
		
		If TcSrvType() == "AS/400"
			clSql += "and @SFE.DELETED@ <> '*' "
		Else
			clSql += "and SFE.D_E_L_E_T_ <> '*' "
		Endif
		
		clSql += " ORDER BY 3,4,5  "
		
		clSql := ChangeQuery( clSql  )
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, clSql ), "PER",.T.,.T.)
		
		TCSetField("PER", "FE_EMISSAO","D", 08, 0 )
		TCSetField("PER", "F1_EMISSAO","D", 08, 0 )
		TCSetField("PER", "F1_VALBRUT","N", TamSX3("F1_VALBRUT")[1], TamSX3("F1_VALBRUT")[2])
		TCSetField("PER", "F1_VALMERC","N", TamSX3("F1_VALMERC")[1], TamSX3("F1_VALMERC")[2])
		TCSetField("PER", "FE_VALBASE","N", TamSX3("FE_VALBASE")[1], TamSX3("FE_VALBASE")[2])
		TCSetField("PER", "FE_ALIQ"	  ,"N", TamSX3("FE_ALIQ")[1]   , TamSX3("FE_ALIQ")[2])
		TCSetField("PER", "FE_RETENC" ,"N", TamSX3("FE_RETENC")[1] , TamSX3("FE_RETENC")[2])
		TCSetField("PER", "FE_DEDUC"  ,"N", TamSX3("FE_DEDUC")[1]  , TamSX3("FE_DEDUC")[2])
				
		DbSelectArea( "PER" )
		PER->( dbGoTop() )
		While !PER->(Eof())

					nPagina ++
		
					If olReport:Cancel()
						Exit
					EndIf
		 
		    		If lFirstPage
						FCabR027R( olReport, nPagina ) //Impressão do cabeçalho
						lFirstPage := .F.
					EndIf
		
					// Determina o pixel vertical inicial
					nRowStart := olReport:Row()
		
					cNFiscalOri :=""
		         	//Obter numero da Nota Fiscal Original quando NCP o NDC
		         	If AllTriM(PER->FE_ESPECIE) $ "NCP/NDP"
			            cNFiscalOri := R085PgNC()
		            EndIF
					olReport:SetMeter( RecCount() )
		
					nTrans += 1
				    olReport:Say( olReport:Row(), olReport:Col()+0385,Iif(Empty(PER->A2_CGC)," ", Transform(AllTrim(PER->A2_CGC),"@!")),oFont8,11 )				
					olReport:Say( olReport:Row(), olReport:Col()+0540, Iif(Empty(PER->FE_NFISCAL)," ", Transform(AllTrim(PER->FE_NFISCAL),"@!")),oFont8,6 )//Numero Factura
					olReport:Say( olReport:Row(), olReport:Col()+0810, Iif(Empty(PER->F1_FORMLIB),"NA", Transform(AllTrim(PER->F1_FORMLIB),"@!")),oFont8,6 )//Numero Control
					
					olReport:Say( olReport:Row(), olReport:Col()+1040,DtoC(PER->FE_EMISSAO),oFont8 )//-- 'Fecha de operacion
					olReport:Say( olReport:Row(), olReport:Col()+1200, Iif(Empty(PER->FE_CONCEPT)," ", Transform(AllTrim(PER->FE_CONCEPT),"@!")),oFont8,3 )//Codigo de concepto
					
					olReport:Say( olReport:Row(), olReport:Col()+1470, Iif(Empty(Round(PER->F1_VALMERC,2)),"0.00", Transform(Round(PER->F1_VALMERC,2),"@E 99,999,999,999.99")),	oFont8,14 )//-- '10. Total de Compras incluyendo el IVA'
					olReport:Say( olReport:Row(), olReport:Col()+1830, Iif(Empty(PER->FE_ALIQ)," ", Transform(PER->FE_ALIQ,"@E 99.99")),oFont8,5 )//%Retenido
			
					olReport:SkipLine( 1 )
		
					olReport:OnPageBreak( { || FCabR027R( olReport, nPagina ) } )
					If nPag	> 80
						nPag  := 0
						olReport:EndPage()
						olReport:SetRow( nRowStart )
					EndIf
					
					Aadd(aExcel,{ substr(PER->A2_CGC,1,10),substr(PER->FE_NFISCAL,1,10), ;
					Iif(Empty(PER->F1_FORMLIB) 	,"NA",substr(PER->F1_FORMLIB,1,20)),dtoc(PER->FE_EMISSAO),substr(PER->FE_CONCEPT,1,3),;
					    Transform(Round(PER->F1_VALMERC ,2),"@E 99,999,999,999.99"),Transform(PER->FE_ALIQ,"@E 99.99")})
			
					nReg++
		  			PER->( dbSkip() )
		
					olReport:IncMeter()
		EndDo
		PER->( dbCloseArea())
EndIF
Return olReport


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ GerArq   ³ Autor ³                     ³ Data ³16.02.2016  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Arquivo magnéticoretencion de IVA						    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cDir - Diretorio de criacao do arquivo.                    ³±±
±±³            ³ cArq - Nome do arquivo com extensao do arquivo.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal VENEZUELA Archivo Magnetico						    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GerArqI(cDir)

Local cLin			:= ""
Local cSep			:= CHR(09)//TABULADOR
Local nCont			:= 0
Local cArq			:= ""
Local dDtDigit		:= CTOD("  /  /  ")
Local cExisten		:= " "
Local cNodiaAnt		:= "XX"
Local nloop2 := 0
Local nloop := 0

Private nHdl		:= 0

FOR nCont := LEN(AllTrim(cDir)) TO 1 STEP -1
	IF SUBSTR(cDir,nCont,1)=='\'
		cDir:=Substr(cDir,1,nCont)
		EXIT
	ENDIF
NEXT
 // Nome do arquivo TXT a ser impresso
cArq += "V"+AllTrim(SM0->M0_CGC)+ AllTrim(cAnioEnv)+AllTrim(cMesEnv)+".TXT" 

nHdl := fCreate(cDir+UPPER(cArq),Nil,Nil,.F.)
If nHdl <= 0
	ApMsgStop(STR0031) //"Ha ocurrido un error al generar el archivo, intente nuevamente."
Else		
	For  nloop := 1  to Len(aExcel)
		cLin:=""
		For  nloop2 := 1  to 16			
			If nloop2 == 3
				cLin += SubStr(DTOS(aExcel[nloop,nloop2]),1,4)+"-"+SubStr(DTOS(aExcel[nloop,nloop2]),5,2)+"-"+SubStr(DTOS(aExcel[nloop,nloop2]),7,2)
			else
				cLin += aExcel[nloop,nloop2]
			End
			cLin += cSep
		Next
			cLin += chr(13)+chr(10) // QUEBRA LINHA 
			fWrite(nHdl,cLin)
	Next	
	fClose(nHdl)
	MsgInfo(STR0033+ " en "+alltrim(cRuta), STR0032) //"¡Archivo texto generado con éxito!" - "Generación de Archivo Magnético"
EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao     ³ GerArq   ³ Autor ³                     ³ Data ³16.02.2016  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao  ³ Arquivo magnéticoretencion de IVA						    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametros ³ cDir - Diretorio de criacao do arquivo.                    ³±±
±±³            ³ cArq - Nome do arquivo com extensao do arquivo.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno    ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso        ³ Fiscal VENEZUELA Archivo Magnetico						    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GerArqR(cDir)

Local cLin			:= ""
Local cSep			:= "|"
Local nCont			:= 0
Local cArq			:= ""
Local dDtDigit		:= CTOD("  /  /  ")
Local cExisten		:= " "
Local cNodiaAnt		:= "XX"
Local nloop2 := 0
Local nloop := 0

Private nHdl		:= 0

FOR nCont := LEN(AllTrim(cDir)) TO 1 STEP -1
	IF SUBSTR(cDir,nCont,1)=='\'
		cDir:=Substr(cDir,1,nCont)
		EXIT
	ENDIF
NEXT
 // Nome do arquivo TXT a ser impresso
cArq += "R"+AllTrim(SM0->M0_CGC)+AllTrim(cAnioEnv)+AllTrim(cMesEnv)+ ".TXT" 

nHdl := fCreate(cDir+UPPER(cArq),Nil,Nil,.F.)
If nHdl <= 0
	ApMsgStop(STR0031) //"Ha ocurrido un error al generar el archivo, intente nuevamente."
Else		
	For  nloop := 1  to Len(aExcel)
		cLin:=""
		For  nloop2 := 1  to 7			
			// - 01 Periodo
			cLin += aExcel[nloop,nloop2]
			cLin += cSep
		Next
			cLin += chr(13)+chr(10) // QUEBRA LINHA 
			fWrite(nHdl,cLin)
	Next	
	fClose(nHdl)
	MsgInfo(STR0033+ " en "+alltrim(cRuta), STR0032) //"¡Archivo texto generado con éxito!" - "Generación de Archivo Magnético"
EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ R085PgNC  ºAutor  ³Jose Lucas         º Data ³  10/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retornar o numero da nota fiscal original.                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ R085PgNC                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R085PgNC()
LOCAL aSavArea := GetArea()
LOCAL cNFOrig  := ""

//Obter numero da Nota Fiscal Original quando NCP o NDC
If  AllTriM(PER->FE_ESPECIE) $ "NCP"
	SD2->(dbSetOrder(3))
	If SD2->(dbSeek(xFilial("SD2")+PER->FE_NFISCAL+PER->FE_SERIE+PER->FE_FORNECE+PER->FE_LOJA))
	 	While SD2->(!Eof()) .and. SD2->D2_FILIAL == xFilial("SD2") .and.;
	 		  SD2->D2_DOC == PER->FE_NFISCAL .and. SD2->D2_SERIE == PER->FE_SERIE .and.;
	 	  	  SD2->D2_CLIENTE == PER->FE_FORNECE .and. SD2->D2_LOJA == PER->FE_LOJA

	  		If !Empty(SD2->D2_NFORI) .and. Empty(cNFOrig)
	  			cNFOrig := SD2->D2_NFORI	//+"-"+SD2->D2_SERIORI
			EndIf
			SD2->(dbSkip())
		End
	EndIf
ElseIf  AllTriM(PER->FE_ESPECIE) $ "NDP"
	SD1->(dbSetOrder(1))
	If SD1->(dbSeek(xFilial("SD1")+PER->FE_NFISCAL+PER->FE_SERIE+PER->FE_FORNECE+PER->FE_LOJA))
	 	While SD1->(!Eof()) .and. SD2->D2_FILIAL == xFilial("SD2") .and.;
		 	  SD1->D1_DOC == PER->FE_NFISCAL .and. SD1->D1_SERIE == PER->FE_SERIE .and.;
	 	  	  SD1->D1_FORNECE == PER->FE_FORNECE .and. SD1->D1_LOJA == PER->FE_LOJA

	  		If !Empty(SD1->D1_NFORI) .and. Empty(cNFOrig)
	  			cNFOrig := SD1->D1_NFORI	//+"-"+SD1->D1_SERIORI
			EndIf
			SD1->(dbSkip())
		End
    EndIf
EndIf
RestArea(aSavArea)
Return cNFOrig
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FCabR085A4  ³ Autor ³ Jose Lucas          ³ Data | 19/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cabeçalho do relatorio no formato A4. IVA   			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FCabR085A4(Expo1,ExpN1,ExpA1)				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 = Objeto tReport                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FCabR085A4( olReport, nPagina )
//                            1    2    3    4     5     6     7     8     9     10    11    12    13    14
Local oFont8B 		:= TFont():New( "Courier New",, -08,,.T. )
Local oFont9 		:= TFont():New( "Courier New",, -09 )
Local oFont10 		:= TFont():New( "Courier New",, -10 )
Local oFont10B 		:= TFont():New( "Courier New",, -10,,.T. )
Local oFont11B 		:= TFont():New( "Courier New",, -11,,.T. )


//Box 9. Titulos das colunas
//1a. linha do titulo

olReport:Box(olReport:Row()+360, olReport:Col()+0100, olReport:Row()+420, olReport:Col()+3050 )
olReport:Say(olReport:Row()+115, olReport:Col()+0131, STR0002	 		, oFont8B ) //"RIF"
olReport:Say(olReport:Row()+115, olReport:Col()+0285, STR0003	 		, oFont8B ) //"Periodo"
olReport:Say(olReport:Row()+115, olReport:Col()+0405, STR0004	 		, oFont8B ) //"Fecha"
olReport:Say(olReport:Row()+115, olReport:Col()+0540, STR0005			, oFont8B ) //"Tipo"
olReport:Say(olReport:Row()+115, olReport:Col()+0600, STR0005			, oFont8B ) //Tipo
olReport:Say(olReport:Row()+115, olReport:Col()+0670, STR0002			, oFont8B )//"RIF"
olReport:Say(olReport:Row()+115, olReport:Col()+0800, STR0006			, oFont8B )//"Número"
olReport:Say(olReport:Row()+115, olReport:Col()+1000, STR0006			, oFont8B )//"Número"
olReport:Say(olReport:Row()+115, olReport:Col()+1200, STR0007			, oFont8B )//"Monto Total"
olReport:Say(olReport:Row()+115, olReport:Col()+1450, STR0008			, oFont8B )//"Base"
olReport:Say(olReport:Row()+115, olReport:Col()+1710, STR0009			, oFont8B )//"Monto"
olReport:Say(olReport:Row()+115, olReport:Col()+1920, STR0010			, oFont8B )//"Documento"

olReport:Say(olReport:Row()+115, olReport:Col()+2100, STR0006			, oFont8B )//"Número"
olReport:Say(olReport:Row()+115, olReport:Col()+2350, STR0011			, oFont8B )//"Monto Excento"
olReport:Say(olReport:Row()+115, olReport:Col()+2550, STR0012			, oFont8B )//"Alicuota"
olReport:Say(olReport:Row()+115, olReport:Col()+2710, STR0006 + STR0013	, oFont8B )//"Número"+" de"

//2a. linha do título
olReport:Say(olReport:Row()+140, olReport:Col()+0130, STR0014	 		, oFont8B )//"Agente"
olReport:Say(olReport:Row()+140, olReport:Col()+0285, STR0015 	 		, oFont8B )//"Imp."
olReport:Say(olReport:Row()+140, olReport:Col()+0405, STR0016	 		, oFont8B )//"Doc"
olReport:Say(olReport:Row()+140, olReport:Col()+0540, STR0017 			, oFont8B )//"Op."
olReport:Say(olReport:Row()+140, olReport:Col()+0600, STR0016		 	, oFont8B )//"Doc"


olReport:Say(olReport:Row()+140, olReport:Col()+0670, STR0018			, oFont8B )//"Proveedor"
olReport:Say(olReport:Row()+140, olReport:Col()+0800, STR0010	 		, oFont8B )//"Documento"
olReport:Say(olReport:Row()+140, olReport:Col()+1000, STR0019	 		, oFont8B )//"Control"
olReport:Say(olReport:Row()+140, olReport:Col()+1200, STR0010			, oFont8B )//"Documento"
olReport:Say(olReport:Row()+140, olReport:Col()+1450, STR0020			, oFont8B )//"Imponible"
olReport:Say(olReport:Row()+140, olReport:Col()+1710, STR0021			, oFont8B )//"IVA"
olReport:Say(olReport:Row()+140, olReport:Col()+1920, STR0023			, oFont8B )//"Afectado"
olReport:Say(olReport:Row()+140, olReport:Col()+2100, STR0024			, oFont8B )//"Comprobante"
olReport:Say(olReport:Row()+140, olReport:Col()+2350, STR0021			, oFont8B )//"IVA"	
olReport:Say(olReport:Row()+140, olReport:Col()+2710, STR0025			, oFont8B )//"Expediente"

olReport:SkipLine( 7 )

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FCabR085A4  ³ Autor ³ Jose Lucas          ³ Data | 19/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cabeçalho do relatorio no formato A4.	IR      		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FCabR027R(Expo1,ExpN1,ExpA1)				                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1 = Objeto tReport                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FCabR027R( olReport, nPagina )
//                            1    2    3    4     5     6     7     8     9     10    11    12    13    14
Local oFont8B 		:= TFont():New( "Courier New",, -08,,.T. )
Local oFont9 		:= TFont():New( "Courier New",, -09 )
Local oFont10 		:= TFont():New( "Courier New",, -10 )
Local oFont10B 		:= TFont():New( "Courier New",, -10,,.T. )
Local oFont11B 		:= TFont():New( "Courier New",, -11,,.T. )


//Box 9. Titulos das colunas
//1a. linha do titulo
olReport:Box(olReport:Row()+360, olReport:Col()+0100, olReport:Row()+420, olReport:Col()+3000 )

//olReport:Say(olReport:Row()+115, olReport:Col()+0131, STR0002 	 		, oFont8B )//"RIF"
//olReport:Say(olReport:Row()+115, olReport:Col()+0280, STR0003	 		, oFont8B )//"Periodo"
olReport:Say(olReport:Row()+115, olReport:Col()+0400, STR0002	 		, oFont8B )//"RIF"
olReport:Say(olReport:Row()+115, olReport:Col()+0550, STR0006			, oFont8B )//"Número"
olReport:Say(olReport:Row()+115, olReport:Col()+0800, STR0006			, oFont8B )//"Número"
olReport:Say(olReport:Row()+115, olReport:Col()+1210, STR0026			, oFont8B )//"Codigo"
olReport:Say(olReport:Row()+115, olReport:Col()+1500, STR0009			, oFont8B )//"Monto"
olReport:Say(olReport:Row()+115, olReport:Col()+1800, STR0027			, oFont8B )//"Porcentaje"

//2a. linha do título
//olReport:Say(olReport:Row()+140, olReport:Col()+0130, STR0014 		, oFont8B )//"Agente"
olReport:Say(olReport:Row()+140, olReport:Col()+0280, " " 	 		, oFont8B )
olReport:Say(olReport:Row()+140, olReport:Col()+0400, STR0022		, oFont8B )//"Retenido"
olReport:Say(olReport:Row()+140, olReport:Col()+0550, STR0028 		, oFont8B )//"Factura"
olReport:Say(olReport:Row()+140, olReport:Col()+0800, STR0019	 	, oFont8B )//"Control"

olReport:Say(olReport:Row()+140, olReport:Col()+1050, STR0004	 	, oFont8B ) //"Fecha"

olReport:Say(olReport:Row()+140, olReport:Col()+1210, STR0029		, oFont8B )//"Concepto"
olReport:Say(olReport:Row()+140, olReport:Col()+1500, STR0030	 	, oFont8B )//"Operación"
olReport:Say(olReport:Row()+140, olReport:Col()+1800, STR0022	 	, oFont8B )//"Retenido"


olReport:SkipLine( 7 )

Return
