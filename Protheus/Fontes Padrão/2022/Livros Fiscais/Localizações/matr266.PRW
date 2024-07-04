#INCLUDE "MATR266.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR266  ³ Autor ³ Bruno Schmidt.	    ³ Data ³ 05/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio de Controle de Materiais de Terceiros em nosso po-³±±
±±³          ³der e nosso Material em poder de Terceiros.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ MATR266(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³11/01/2017³ Luis Enríquez ³ Se realiza merge para meter los siguientes ´±±
±±³          ³               ³ cambios:                                   ´±±
±±³          ³               ³-Se modifica para usar Qry.                 ³±±
±±³          ³               ³-Corrección del campo RUC.                  ³±±
±±³          ³               ³-Se actualizó a consultar la serie de       ³±±
±±³          ³               ³ Entrada o Salida para los documentos rela- ³±±
±±³          ³               ³ cionadas de recibo de mercancía o emisión  ³±±
±±³          ³               ³ de Facturas de venta.                      ³±±
±±³          ³               ³-Se agregó bifurcación para país PERÚ en    ³±±
±±³          ³               ³ utilización de pregunta MV_PAR12.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Matr266()

Local oReport

	If FindFunction("TRepInUse") .And. TRepInUse()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Interface de impressao                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Bruno Schmidt		    ³ Data ³ 05/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(nReg)

	Local oReport 
	Local oSection1
	Local oSection2                                                     
	Local oSection3
	Local oCell         
	Local aOrdem  := {} 
	Local cTamVal := TamSX3('B6_CUSTO1' )[1]
	Local cTamQtd := TamSX3('B6_QUANT' )[1]
	Local cCGC    := ""
	Local cNOME   := ""
	Local cTIPO   := ""
	Local aArea   := ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
	//³Criacao do componente de impressao                                      ³
	//³                                                                        ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= TReport():New("MATR266",STR0009,"MTR266", {|oReport| ReportPrint(oReport)},STR0001+" "+STR0002+" "+STR0003) //"Relacao de materiais de Terceiros e em Terceiros"##"Este programa ira emitir o Relatorio de Materiais"##"de Terceiros em nosso poder e/ou nosso Material em"##"poder de Terceiros."
	oReport:SetLandscape()    
	oReport:SetTotalInLine(.F.)

	Pergunte("MTR266",.F.)

	Aadd( aOrdem, STR0004 ) //" Produto/Local " 
	Aadd( aOrdem, STR0005 ) //" Cliente/Fornecedor " 
	Aadd( aOrdem, STR0006 ) //" Dt. Mov/Produto " 

	oSection1 := TRSection():New(oReport,STR0052,{"SB6"},aOrdem) //"Relacao de materiais de Terceiros e em Terceiros"
	oSection1 :SetTotalInLine(.F.)
	oSection1 :SetReadOnly()
	oSection1 :SetLineStyle()
	oSection1 :SetHeaderPage()
	oSection1 :NCOLS:=1

	dbSelectArea("SM0")
	dbSetOrder(1)
	aArea := GetArea()

	dbSelectArea("SM0")
	dbGoTop()
	While !Eof()
		If SM0->M0_CODFIL == SB6->B6_FILIAL
			cNOME:= SM0->M0_NOMECOM
			cCGC := SM0->M0_CGC
			Exit
		EndIf
		dbSkip()
	EndDo

	dbSelectArea("SX5")
	dbSeek(xFilial()+"02"+SB1->B1_TIPO)
	cTIPO = SX5->X5_DESCRI
	dbCloseArea()
	RestArea(aArea)

	TRCell():New(oSection1,"PERÍODO"   ,"   " ,STR0117    ,/*Picture*/,30          ,/*lPixel*/,{|| DTOC(mv_par07)+' '+STR0087+' '+DTOC(mv_par08)})
	TRCell():New(oSection1,"M0_CGC"    ,"   " ,STR0113    ,/*Picture*/,30          ,/*lPixel*/,{|| cCGC })
	TRCell():New(oSection1,"M0_NOME"   ,"   " ,STR0116    ,/*Picture*/,30          ,/*lPixel*/,{|| cNOME })
	TRCell():New(oSection1,"X5_DESCRI" ,"  "  ,STR0115    ,/*Picture*/,30	        ,/*lPixel*/,{|| cTIPO })
	TRCell():New(oSection1,"B1_DESC"   ,"SB1" ,STR0120 ,/*Picture*/,30	        ,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"B1_COD"    ,"SB1" ,STR0121 ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"B6_UM"     ,"SB6" ,STR0061    ,/*Picture*/ ,/*Tamanho*/,/*lPixel*/,{|| SB6->B6_UM })

	oSection2 := TRSection():New(oSection1,STR0053,{"SB6"}) //"Relacao de materiais de Terceiros e em Terceiros"
	oSection2 :SetTotalInLine(.F.)
	oSection2 :SetReadOnly()


	TRCell():New(oSection2,"B6_EMISSAO","SB6",CRLF+CRLF+CRLF+STR0071			                                                                                 ,/*Picture*/                   ,14		    ,/*lPixel*/ ,/*{|| code-block de impressao }*/             ,"CENTER", ,"CENTER")
	TRCell():New(oSection2,"TIPO"       ,"   ",CRLF+CRLF+CRLF+STR0082+CRLF+STR0088   	                                                                         ,/*Picture*/	                 ,2	            ,/*lPixel*/ ,{|| IIf(SB6->B6_TPCF == "C",STR0018,STR0019)},"CENTER", ,"CENTER")
	TRCell():New(oSection2,SerieNfId("SB6",3,"B6_SERIE") ,"SB6",'    '+STR0089+' '+CRLF+STR0081+' '+STR0091+' '+CRLF+CRLF+STR0074+"   "                                    ,/*Picture*/	                 ,SerieNfId("SB6",6,"B6_SERIE") ,/*lPixel*/ ,/*{|| code-block de impressao }*/              ,"CENTER", ,"RIGHT")
	TRCell():New(oSection2,"B6_DOC"    ,"SB6",STR0090+CRLF+STR0118+' '+STR0075+CRLF+CRLF+'   '+STR0092                                                     ,/*Picture*/	                 ,20           ,/*lPixel*/ ,/*{|| code-block de impressao }*/              ,"CENTER", ,"LEFT",,,.F.)
	TRCell():New(oSection2,"SERIEPG"   ,"   ",STR0083+CRLF+STR0081+' '+STR0091+CRLF+CRLF+STR0074                                                            ,/*Picture*/	                 ,SerieNfId("SB6",6,"B6_SERIE"),/*lPixel*/ ,/*{|| code-block de impressao }*/              ,"CENTER", ,"CENTER")
	TRCell():New(oSection2,"DOCPG"     ,"   ",STR0093+' '+STR0084+CRLF+STR0118+' '+STR0075+CRLF+CRLF+'   '+STR0092                                        ,/*Picture*/	                 ,20		    ,/*lPixel*/ ,/*{|| code-block de impressao }*/              ,"CENTER", ,"LEFT",,,.F.)
	TRCell():New(oSection2,"DTCPG"	   ,"   ",CRLF+STR0071+' '+STR0093+CRLF+STR0094+CRLF+STR0095+CRLF+STR0096                                              ,/*Picture*/	                 ,14	        ,/*lPixel*/ ,/*{|| code-block de impressao }*/              ,"CENTER", ,"CENTER")
	TRCell():New(oSection2,"TPPES"     ,"   ",STR0097+CRLF+CRLF+CRLF+STR0082+CRLF+STR0099  					                                                 ,/*Picture*/                  ,2	            ,/*lPixel*/ ,{|| IIf(SB6->B6_TPCF == "C",STR0018,STR0019) },"CENTER", ,"CENTER")
	TRCell():New(oSection2,"B6_CLIFOR" ,"SB6",STR0098+CRLF+CRLF+STR0069+CRLF+STR0100+CRLF+STR0080+' '+STR0093+CRLF+STR0101                              ,/*Picture*/	                 ,15		    ,/*lPixel*/ ,/*{|| code-block de impressao }*/              ,"CENTER", ,"CENTER")
	TRCell():New(oSection2,"CLIFORNOME"," 	",STR0076+CRLF+CRLF+' '+STR0070+' '+STR0102+CRLF+'   '+STR0103+CRLF+STR0104+' '+STR0105+CRLF+' '+STR0106	 ,/*Picture*/	                 ,20		    ,/*lPixel*/ ,/*{|| code-block de impressao }*/              ,"CENTER", ,"LEFT")
	TRCell():New(oSection2,"QTDREC"    ,"SB6",STR0107+CRLF+CRLF+CRLF+STR0042+CRLF+STR0086	                            	                                 ,PesqPict("SB6","B6_QUANT") ,/*Tamanho*/ ,/*lPixel*/ ,{|| SB6->B6_QUANT }                               ,"CENTER", ,"CENTER") //"Quantidade"##"Original"
	TRCell():New(oSection2,"QTDDEV"    ,"   ",STR0093+' '+STR0108+CRLF+CRLF+CRLF+STR0042+CRLF+STR0079			                                             ,PesqPict("SB6","B6_QUANT") ,cTamQtd	    ,/*lPixel*/ ,/*{|| code-block de impressao }*/               ,"CENTER", ,"CENTER") //"Quantidade"##"Ja entregue"				
	TRCell():New(oSection2,"QTDVEN"    ,"   ",STR0119+CRLF+CRLF+CRLF+STR0042+CRLF+STR0078			                                                         ,'@E 99,999,999,999.99'      ,cTamVal	    ,/*lPixel*/ ,/*{|| code-block de impressao }*/               ,"CENTER", ,"CENTER") //"Total"##"N.Fiscal"
	TRCell():New(oSection2,"nSaldo"    ,"   ",STR0109+CRLF+CRLF+CRLF+'     '+STR0045+CRLF+' '+STR0110+CRLF+STR0109             			                 ,PesqPict("SB6", "B6_QUANT"),cTamQtd	    ,/*lPixel*/ ,/*{|| code-block de impressao }*/               ,"CENTER", ,"LEFT") //"Saldo"


	oSection3 := TRSection():New(oSection2,STR0054,{"SB6"})  //"Relacao de materiais de Terceiros e em Terceiros"
	oSection3 :SetTotalInLine(.F.)


	TRCell():New(oSection3,"B6_EMISSAO","SB6",STR0071+' '+STR0093+CRLF+STR0111+CRLF+STR0095+CRLF+STR0105+' '+STR0085+CRLF+STR0096                                                         ,/*Picture*/				   ,14		     ,/*lPixel*/,/*{|| code-block de impressao }*/             ,"CENTER", ,"CENTER")
	TRCell():New(oSection3,"DTCPG"	   ,"   " ,STR0071+' '+STR0093+CRLF+STR0072+' '+STR0093+CRLF+STR0112+' '+STR0089+CRLF+STR0090+' '+STR0105+CRLF+STR0083+CRLF+STR0093+' '+STR0084 ,/*Picture*/				   ,14		     ,/*lPixel*/,/*{|| code-block de impressao }*/             ,"CENTER", ,"CENTER")
	TRCell():New(oSection3,"TIPO"      ,"   " ,CRLF+CRLF+STR0082+CRLF+STR0088        		 		                                                                                                ,/*Picture*/				   ,2	         ,/*lPixel*/,{|| IIf(SB6->B6_TPCF == "C",STR0018,STR0019)},"CENTER", ,"CENTER")
	TRCell():New(oSection3,SerieNfId("SB6",3,"B6_SERIE"),"SB6",STR0089+CRLF+STR0081+' '+STR0091+CRLF+CRLF+STR0074			                                                ,/*Picture*/				   ,SerieNfId("SB6",6,"B6_SERIE"),/*lPixel*/,/*{|| code-block de impressao }*/              ,"CENTER", ,"RIGHT")
	TRCell():New(oSection3,"B6_DOC"    ,"SB6",STR0090+CRLF+STR0118+' '+STR0075+CRLF+CRLF+'   '+STR0092                                                             ,/*Picture*/				   ,20           ,/*lPixel*/,/*{|| code-block de impressao }*/             ,"CENTER", ,"LEFT",,,.F.)
	TRCell():New(oSection3,"SERIEPG"   ,"   ",STR0083+CRLF+STR0081+' '+STR0091+CRLF+CRLF+STR0074	            	                            ,/*Picture*/				   ,SerieNfId("SB6",6,"B6_SERIE"),/*lPixel*/,/*{|| code-block de impressao }*/              ,"CENTER", ,"CENTER")
	TRCell():New(oSection3,"DOCPG"     ,"   ",STR0093+' '+STR0084+CRLF+STR0118+' '+STR0076+CRLF+CRLF+STR0092                                               ,/*Picture*/				   ,20		     ,/*lPixel*/,/*{|| code-block de impressao }*/              ,"CENTER", ,"LEFT",,,.F.)
	TRCell():New(oSection3,"B6_CLIFOR" ,"SB6",STR0097+' '+STR0098+CRLF+CRLF+CRLF+STR0092+CRLF+STR0093+' '+STR0113			  			                                            ,/*Picture*/				   ,15		     ,/*lPixel*/,/*{|| code-block de impressao }*/              ,"CENTER", ,"CENTER")
	TRCell():New(oSection3,"CLIFORNOME","	" ,STR0075+CRLF+CRLF+' '+STR0070+' '+STR0102+CRLF+'   '+STR0103+CRLF+STR0104+' '+STR0105+CRLF+' '+STR0106			  		    ,/*Picture*/				   ,20		     ,/*lPixel*/,/*{|| code-block de impressao }*/              ,"CENTER", ,"LEFT")
	TRCell():New(oSection3,"QTDREC"    ,"SB6",STR0107+CRLF+CRLF+CRLF+STR0042+CRLF+STR0077			                                                ,PesqPict("SB6","B6_QUANT"),/*Tamanho*/,/*lPixel*/,{|| SB6->B6_QUANT }                               ,"CENTER", ,"CENTER") //"Quantidade"##"Original"
	TRCell():New(oSection3,"QTDDEV"    ,"   ",STR0093+' '+STR0108+CRLF+CRLF+CRLF+STR0042+CRLF+STR0079			                                                ,PesqPict("SB6","B6_QUANT"),cTamQtd	 ,/*lPixel*/,/*{|| code-block de impressao }*/              ,"CENTER", ,"CENTER")//"Quantidade"##"Ja entregue"				
	TRCell():New(oSection3,"QTDVEN"    ,"   ",STR0114+CRLF+CRLF+CRLF+STR0042+CRLF+STR0078			                                                ,'@E 99,999,999,999.99'     ,cTamVal	 ,/*lPixel*/,/*{|| code-block de impressao }*/              ,"CENTER", ,"CENTER") //"Total"##"N.Fiscal"
	TRCell():New(oSection3,"nSaldo"    ,"   ",STR0109+CRLF+CRLF+CRLF+'     '+STR0045+CRLF+' '+STR0110+CRLF+STR0109            			                        ,PesqPict("SB6", "B6_QUANT"),cTamQtd	 ,/*lPixel*/,/*{|| code-block de impressao }*/              ,"CENTER", ,"LEFT")//"Saldo"

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Bruno Schmidt		    ³ Data ³ 05/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

	Local oSection1 := oReport:Section(1) 
	Local oSection2 := oReport:Section(1):Section(1)  
	Local oSection3 := oReport:Section(1):Section(1):Section(1)  
	Local nOrdem    := oReport:Section(1):GetOrder() 
	Local lListCustM:= .T.
	Local lCusFIFO  := GetMV('MV_CUSFIFO')
	Local cProdLOCAL:= ""
	Local cCliFor   := ""
	Local cCliForAnt:= ""
	Local lImprime  := .F.
	Local aAreaSB6  := {}
	local nQtdReceb2 :=0
	Local nQtdReceb1 :=0
	Local nQtdVend2:=0
	Local nQtdVend1:=0
	//lListCustM := (mv_par16==1)

	// Arquivo TXT 
	//9.1 REGISTRO DE CONSIGNACIONES - PARA EL CONSIGNADOR - CONTROL DE BIENES ENTREGADOS EN CONSIGNACIÓN
	//9.2 REGISTRO DE CONSIGNACIONES - PARA EL CONSIGNATARIO - CONTROL DE BIENES RECIBIDOS EN CONSIGNACIÓN
	Local cDir     := ""
	Local nHdl     := 0
	Local cLin     := ""
	Local cSep     := "|"
	Local nCont    := 0
	Local cArq     := ""
	Local cQuantT  := 0
	Local cQuantTo := 0
	Local cCusInic := 0
	Local nConta   := 0 
	Local cExisten := " "
	Local lTxt := .F.

	Local cQuery       := "" 
	Local cAliasSB6  := ""
	Local cAliasSF4  := ""   
	Local lQuery     := .F.
	Local nx			:= 0 

	If cPaisloc == "PER" 
		If MV_PAR12 == 1
			IF MSGYESNO("Generar Archivo Txt?") // imprimir txt
				lTxt:= .T.
			EndIf
		EndIf
	EndIf

	If lTxt

		cDir := MV_PAR13

		FOR nCont:=LEN(AllTrim(cDir)) TO 1 STEP -1
			IF SUBSTR(cDir,nCont,1)=='\'
				cDir:=Substr(cDir,1,nCont)
				EXIT
			ENDIF

		NEXT

		// Nome do arquivo TXT a ser impresso
		cArq += "LE"                            // Fixo  'LE'
		cArq +=  AllTrim(SM0->M0_CGC)                  // Ruc
		cArq +=  AllTrim(Str(Year(MV_PAR08)))   // Ano
		cArq +=  AllTrim(Strzero(Month(MV_PAR08),2))  // Mes
		cArq +=  "00"                            // Fixo '00'
		If MV_PAR09 == 2
			cArq += "090100"                     // Fixo '090100' 9.1 REGISTRO DE CONSIGNACIONES PARA EL CONSIGNADOR
		Else
			cArq += "090200"                     // Fixo '090200' 9.2 REGISTRO DE CONSIGNACIONES PARA EL CONSIGNATARIO
		EndIf
		cArq += "00"                             // Fixo '00'
		cArq += "1"
		cArq += "1"
		cArq += "1"
		cArq += "1"
		cArq += ".TXT" // Extensao

		nHdl := fCreate(cDir+cArq)

		If nHdl <= 0
			ApMsgStop("Ocorreu um erro ao criar o arquivo.")
		EndIf

	EndIf	

	dbSelectArea("SB6")
	dbSetOrder(nOrdem)

	If nOrdem == 1
		oSection1 :SetTotalText(STR0020) //"TOTAL DESTE PRODUTO / LOCAL ------ >"
		If mv_par09 == 1
			oReport:SetTitle(STR0010) //"RELACAO DE MATERIAIS DE TERCEIROS EM NOSSO PODER - PRODUTO / LOCAL"
		ElseIf mv_par09 == 2
			oReport:SetTitle(STR0011) //"RELACAO DE MATERIAIS NOSSOS EM PODER DE TERCEIROS - PRODUTO / LOCAL"
		EndIf
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicio da impressao do fluxo do relatório                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SetMeter(SB6->(LastRec()))

	#IFDEF TOP
		lQuery     := .T.
		aStruSB6   := SB6->(dbStruct())
		cAliasSB6  := GetNextAlias()
		cAliasSF4  := GetNextAlias()        
	
		cQuery := "SELECT "+SqlOrder(SB6->(IndexKey()))+","
		For nX := 1 To Len(aStruSB6)
			If !aStruSB6[nX][1]$cQuery
				cQuery += aStruSB6[nX][1]+","
			EndIf
		Next nX
		cQuery += "SF4.F4_PODER3 "
		cQuery += " FROM "+RetSqlName("SB6")+" SB6,"+RetSqlName("SF4")+" SF4 "
		cQuery += "WHERE SB6.B6_FILIAL='"+xFilial("SB6")+"' AND "
		cQuery += "	B6_QUANT <> 0  AND "
		cQuery += "	SB6.B6_PRODUTO  BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' AND "
		cQuery += "SB6.D_E_L_E_T_=' ' AND "
		If mv_par09 == 1
			cQuery += " SB6.B6_CLIFOR BETWEEN '"+mv_par03+"' AND '"+ mv_par04+"' AND "
			cQuery += " SB6.B6_CLIFOR BETWEEN '"+mv_par01+"' AND '"+ mv_par02+"' AND "
		EndIf
		cQuery += "SB6.B6_DTDIGIT BETWEEN '"+Dtos(mv_par07)+"' AND '"+Dtos(mv_par08)+"' AND "
	
		cQuery += "SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
		cQuery += "SF4.F4_CODIGO=SB6.B6_TES AND  SF4.F4_PODER3 != 'D' AND "
		cQuery += "SF4.D_E_L_E_T_=' ' "
	
		cQuery += "ORDER BY 1,2,3,4"
	
		cQuery := ChangeQuery(cQuery)  	
	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB6,.T.,.T.)
	
		For nX := 1 To Len(aStruSB6)
			If ( aStruSB6[nX][2] <> "C" )
				TcSetField(cAliasSB6,aStruSB6[nX][1],aStruSB6[nX][2],aStruSB6[nX][3],aStruSB6[nX][4])
			EndIf
		Next nX
	#ELSE
		Do Case
			Case nOrdem == 1
			dbSelectArea("SB6")
			dbSeek(xFilial()+mv_par05,.T.)		    
			cCond := 'SB6->B6_FILIAL == xFilial("SB6")'
		EndCase			
	#ENDIF

	While !oReport:Cancel() .And. (cAliasSB6)->(!Eof())

		If oReport:Cancel()
			Exit
		EndIf

		oReport:IncMeter()

		aSaldo	:= CalcTerc((cAliasSB6)->B6_PRODUTO,(cAliasSB6)->B6_CLIFOR,(cAliasSB6)->B6_LOJA,(cAliasSB6)->B6_IDENT,(cAliasSB6)->B6_TES,,mv_par07,mv_par08)
		nSaldo  := aSaldo[1]
		nPrUnit := IIF(aSaldo[3]==0,(cAliasSB6)->B6_PRUNIT,aSaldo[3])		

		If nOrdem == 1
			cQuebra := (cAliasSB6)->B6_PRODUTO+(cAliasSB6)->B6_LOCAL
		Endif

		While !oReport:Cancel() .And. (cAliasSB6)->(!Eof()) .And. (cAliasSB6)->B6_FILIAL == xFilial("SB6") .And. cQuebra == (cAliasSB6)->B6_PRODUTO+(cAliasSB6)->B6_LOCAL
		
			If lTxt

				cLin      := ""
				cDate1    := "" //1
				cCod1     := "" //2	
				cTipo     := "" //3
				cCodBr    := "" //4
				cSegofi   := "" //5 
				cCodBr1   := "" //6
				cUmedida  := "" //7 
				cEmiss    := "01/01/0001|" //8
				cTipoOp   := "00|" //11
				cNomeR    := "" //17
				cNumCons  := "" //16
				cQtdRec   := "0.00|" //18
				cGuiaR    := "0|" //10
				cSerieR   := "0|" //9
				cSeriePag := "0|" //13
				cDocPag   := "0|" //14
				cQtdVen   := "0.00|" //20
				cDateEmis := "01/01/0001|" //12
				cDateRec  := "01/01/0001|" //15
				cIdent    := "" //21
				cQtDevo   := "0.00|" //19
				cTipDoc1  := "" //16 quando o MV_PAR09 = 02


				// 01 - Periodo
				cDate1 += SubStr(DTOS(MV_PAR08),1,6)+"00"
				cDate1 += cSep

				// 02 - Codigo catalogo Utilizado  - tabela 13
				SB1->(DbSetOrder(1))
				SB1->(MsSeek(xFilial("SB1") + (cAliasSB6)->B6_PRODUTO))    //	SB1->(MsSeek(xFilial("SB1") + SB1->B1_COD))
				If SB1->B1_CODBAR <> " "
					cCod1 += "3"
				Else
					cCod1 += "9"	
				EndIf	
				cCod1 += cSep	

				//03 - Tipo de existencia - tabela 5
				cTipo += AllTrim(SB1->B1_TIPOEX)					
				cTipo += cSep

				//04 - Codigo de la existencia  -  descrição do campo 2
				If SB1->B1_CODBAR <> " "
					cCodBr  += AllTrim("EAN-UCC")
				Else
					cCodBr  += AllTrim("OTROS")
				EndIf	
				cCodBr  += cSep		

				//06 - Nombre de la existencia - Nome do campo 03				
				SX5->(DBSetOrder(1))
				SX5->(MsSeek(xFilial("SX5")+"P7"+SB1->B1_TIPOEX))
				cExisten := IIf(SX5->(Found()),Trim(X5Descri())," ")
				cCodBr1 += cExisten

				cCodBr1 += cSep

				//07 - Código de la unidad de medida - tabela 06
				SB5->(DbSetOrder(1))
				SB5->(MsSeek(xFilial("SB5") + SB1->B1_COD))       //	SB5->(MsSeek(xFilial("SB5") + SB5->B5_COD)) 
				cUmedida += AllTrim(SB5->B5_UNSUNAT)	
				cUmedida += cSep

			EndIf
			If oReport:Cancel()
				Exit
			EndIf 
			cTipoDoc:=""
			aAreaSB6 := (cAliasSB6)->(GetArea())
			If (cAliasSB6)->B6_TES < "500"
				dbSelectArea("SD1")
				dbSetorder(1)
				If SD1->(dbSeek(xFilial("SD1")+(cAliasSB6)->B6_DOC+(cAliasSB6)->B6_SERIE+(cAliasSB6)->B6_CLIFOR+(cAliasSB6)->B6_LOJA+(cAliasSB6)->B6_PRODUTO))
					If SD1->D1_ESPECIE $ "FT|NF|"
						cTipoDoc := "FAC"
					Else
						cTipoDoc := SD1->D1_ESPECIE
					EndIf     
				EndIF
			Else 
				DbSelectArea("SD2")
				SD2 -> (DbSetOrder(3))
				If SD2->(dbSeek(xFilial("SD2")+(cAliasSB6)->B6_DOC+(cAliasSB6)->B6_SERIE+(cAliasSB6)->B6_CLIFOR+(cAliasSB6)->B6_LOJA+(cAliasSB6)->B6_PRODUTO))
					If Trim(SD2->D2_ESPECIE) $ "FT|NF"
						cTipoDoc := "FAC"
					Else
						cTipoDoc := SD2->D2_ESPECIE
					EndIf
				EndIf
			EndIf
			RestArea(aAreaSB6)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega os Tipos de Operacao ref. a tabela 10 da lei    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ALLTRIM(cTipoDoc) $ "NDI" 
				oSection2:Cell("TIPO"):SetValue("07")
				oSection3:Cell("TIPO"):SetValue("07")
			ElseIf ALLTRIM(cTipoDoc) $ "FAC|RET" 
				oSection2:Cell("TIPO"):SetValue("01")
				oSection3:Cell("TIPO"):SetValue("01")
			ElseIf ALLTRIM(cTipoDoc) $ "RFN|RCN" 
				oSection2:Cell("TIPO"):SetValue("09")
				oSection3:Cell("TIPO"):SetValue("09")
			ElseIf ALLTRIM(cTipoDoc) $ "NCC" 
				oSection2:Cell("TIPO"):SetValue("08")
				oSection3:Cell("TIPO"):SetValue("08")
			Else
				oSection2:Cell("TIPO"):SetValue("00")
				oSection3:Cell("TIPO"):SetValue("00")
			EndIf

			//Geração TXT 
			//11 - Tipo de Comprobante de Pago o Documento emitido por el consignatario, por la venta de los bienes recibidos en consignación
			If lTxt
				If ALLTRIM(cTipoDoc) $ "NDI" 
					cTipoOp := '07' 
				ElseIf ALLTRIM(cTipoDoc) $ "FAC|RET"
					cTipoOp := '01'
				ElseIf ALLTRIM(cTipoDoc) $ "RFN|RCN" 
					cTipoOp := '09'
				ElseIf ALLTRIM(cTipoDoc) $ "NCC" 
					cTipoOp := '08'
				Else
					cTipoOp := '00'
				EndIf
				cTipoOp += cSep	
			EndIf			

			aAreaSB6 := (cAliasSB6)->(GetArea())
			If (cAliasSB6)->B6_TPCF == "C" 
				dbSelectArea("SA1")
				dbSeek(xFilial("SA1")+(cAliasSB6)->B6_CLIFOR+(cAliasSB6)->B6_LOJA)
				oSection1 :SetTotalText(STR0032+STR0030) //"TOTAL DO PRODUTO NO "##"CLIENTE ---->"###"FORNECEDOR --->"
				cNomeRedz:= ""
				cNomeRedz:= SA1->A1_NREDUZ
				cRuc	 := SA1->A1_CGC
				cTPPes   := SA1->A1_TIPDOC 
				If MV_PAR09 == 2
					oSection2:Cell("CLIFORNOME"):SetValue(cNomeRedz)
					oSection2:Cell("B6_CLIFOR") :SetValue(cRuc) 
					oSection2:Cell("TPPES")	    :SetValue(cTPPes) 
					If lTxt 

						//16 - Tipo de documento de identidad del consignatario TABLA 2
						cTipDoc1 := strzero(Val(cTPPes),1)
						cTipDoc1 += cSep

						//17 - Número de RUC del consignador
						cNumCons := Right(AllTrim(cRuc),15)      //Right(AllTrim(cRuc),8)  
						cNumCons += cSep

						//18 - Apellidos y Nombres, Denominación o Razón Social del consignador
						cNomeR := AllTrim(cNomeRedz) 
						cNomeR += cSep
					EndIf					 
				Else
					oSection3:Cell("CLIFORNOME"):SetValue(cNomeRedz)
					oSection3:Cell("B6_CLIFOR") :SetValue(cRuc) 
					If lTxt // teste nota entrada beneficiamento
						//17 - Apellidos y Nombres, Denominación o Razón Social del consignador
						cNomeR  := AllTrim(cNomeRedz) 
						cNomeR  += cSep

						//16 - Número de RUC del consignador
						cNumCons := AllTrim(cRuc)
						cNumCons += cSep
					EndIf					
				EndIf  

			Else
				dbSelectArea("SA2")
				dbSeek(xFilial("SA2")+(cAliasSB6)->B6_CLIFOR+(cAliasSB6)->B6_LOJA)
				oSection1 :SetTotalText(STR0032+STR0031) //"TOTAL DO PRODUTO NO "##"FORNECEDOR --->" 
				NomeRedz:= SA2->A2_NREDUZ
				cRuc	 := If(!Empty(SA2->A2_CGC),SA2->A2_CGC,SA2->A2_PFISICA)
				cTPPes   := If(!Empty(SA2->A2_CGC),"06",SA2->A2_TIPDOC)
				If MV_PAR09 == 2
					oSection2:Cell("CLIFORNOME"):SetValue(NomeRedz)
					oSection2:Cell("B6_CLIFOR") :SetValue(cRuc)
					oSection2:Cell("TPPES")	    :SetValue(cTPPes)
					If lTxt

						//16 - Tipo de documento de identidad del consignatario TABLA 2
						cTipDoc1 := strzero(Val(cTPPes),1)
						cTipDoc1 += cSep

						//17 - Apellidos y Nombres, Denominación o Razón Social del consignador
						cNomeR := AllTrim(NomeRedz) 
						cNomeR += cSep

						//16 - Número de RUC del consignador
						cNumCons := AllTrim(cRuc) 			
						cNumCons += cSep
					EndIf					
				Else
					oSection3:Cell("CLIFORNOME"):SetValue(NomeRedz)
					oSection3:Cell("B6_CLIFOR") :SetValue(cRuc)
					If lTxt
						//17 - Apellidos y Nombres, Denominación o Razón Social del consignador
						cNomeR := AllTrim(NomeRedz) 
						cNomeR += cSep

						//16 - Número de RUC del consignador
						cNumCons := AllTrim(cRuc) 
						cNumCons += cSep
					EndIf					
				EndIf

			Endif
			RestArea(aAreaSB6)
			oReport:IncMeter()
			/*/
			SF4->(dbSeek(xFilial("SF4")+(cAliasSB6)->B6_TES))
			If SF4->F4_PODER3 == "D"
				SB6->(dbSkip())
				Loop
			EndIf

			If (cAliasSB6)->B6_TPCF == "C"
				If (cAliasSB6)->B6_CLIFOR   < mv_par01 .Or. (cAliasSB6)->B6_CLIFOR  > mv_par02
					(cAliasSB6)->(dbSkip())
					Loop
				EndIf
			Else
				If (cAliasSB6)->B6_CLIFOR   < mv_par03 .Or. (cAliasSB6)->B6_CLIFOR  > mv_par04
					SB6->(dbSkip())
					Loop
				EndIf
			Endif	

			If	SB6->B6_PRODUTO < mv_par05 .Or. SB6->B6_PRODUTO > mv_par06 .Or.;
			SB6->B6_DTDIGIT < mv_par07 .Or. SB6->B6_DTDIGIT > mv_par08 .Or.;
			SB6->B6_QUANT == 0 
				SB6->(dbSkip())
				Loop
			Endif	
			/*/
			aSaldo:=CalcTerc((cAliasSB6)->B6_PRODUTO,(cAliasSB6)->B6_CLIFOR,(cAliasSB6)->B6_LOJA,(cAliasSB6)->B6_IDENT,(cAliasSB6)->B6_TES,,mv_par07,mv_par08)
			nSaldo  := aSaldo[1]
			nPrUnit := IIF(aSaldo[3]==0,(cAliasSB6)->B6_PRUNIT,aSaldo[3])
			/*/
			If mv_par09 == 1 .And. (cAliasSB6)->B6_TIPO != "D"
				SB6->(dbSkip())
				Loop
			ElseIf mv_par09 == 2 .And. (cAliasSB6)->B6_TIPO != "E"
				SB6->(dbSkip())
				Loop
			EndIf
			/*/
			oSection1:Init()  

			If cProdLOCAL != (cAliasSB6)->B6_PRODUTO+(cAliasSB6)->B6_LOCAL
				If SB1->(dbSeek(xFilial("SB1")+(cAliasSB6)->B6_PRODUTO))
					oSection1:PrintLine()			
					cProdLOCAL := (cAliasSB6)->B6_PRODUTO+(cAliasSB6)->B6_LOCAL
				Else
					Help(" ",1,"R480PRODUT")
					dbSelectArea("SB6")
					Return .F.
				EndIf
			EndIf
			If !Empty(cProdLocal)
				If MV_PAR09 == 2
					oSection2:Init()
					nQtdReceb2:=0 
					nQtdReceb2:=(cAliasSB6)->B6_QUANT
					oSection2:Cell("QTDDEV"):Hide()
					oSection2:Cell("QTDVEN"):HIde()
					oSection2:Cell("nSaldo"):SetValue((cAliasSB6)->B6_QUANT)
					oSection2:Cell("QTDREC"):SetValue((cAliasSB6)->B6_QUANT)			   	
					oSection2:PrintLine()  
					oSection2:Cell("QTDDEV"):Show()
					oSection2:Cell("QTDVEN"):Show()
					cDocCons  :=(cAliasSB6)->B6_DOC 
					cSerieCons:=SerieNfId("SB6",2,"B6_SERIE")

					//Seleccionar si es serie ,1,2 ó 3

					SF2->( DbSetOrder(1) )
					If SF2->( DbSeek(xFilial("SF2")+(cAliasSB6)->B6_DOC+(cAliasSB6)->B6_SERIE) )
						If !Empty(SF2->F2_YSERIE)
							cSerieCons:= SF2->F2_YSERIE  // Iif(Empty(SF2->F2_YSERIE)==.F.,SF2->F2_YSERIE, iif(Empty(SF2->F2_SERIE2)==.F.,SF2->F2_SERIE2,SF2->F2_SERIE ) )
						Else
							If  !Empty(SF2->F2_SERIE2)
								cSerieCons:= SF2->F2_SERIE2 
							Else
								cSerieCons:= IIf(substr(SF2->F2_SERIE,1,2)=="00",SF2->F2_SERIE,"0"+substr(SF2->F2_SERIE,1,2)) 
							EndIf
						EndIf
					EndIf					                 

					//08 - Fecha de emisión de la guía de remisión emitida por el consignador
					cEmiss := SubStr(DTOC((cAliasSB6)->B6_EMISSAO),1,6) + SubStr(DTOS((cAliasSB6)->B6_EMISSAO),1,4) 
					cEmiss += cSep

					//19 - Cantidad de bienes entregados en consignación (la primera tupla corresponde al saldo inicial) 				
					cQtdRec := AllTrim(StrTran(Transform((cAliasSB6)->B6_QUANT,"@E 999999999.99"),",","."))
					cQtdRec += cSep

					//10 - Número de la guía de remisión emitido por el consignador, con la que se reciben los bienes o se devuelven al consignador los bienes no vendidos	
					cGuiaR := AllTrim((cAliasSB6)->B6_DOC) 
					cGuiaR += cSep

					//09 - Serie de la guía de remisión emitido por el consignador, con la que se reciben los bienes o se devuelven al consignador los bienes no vendidos		
					cSerieR := AllTrim((cAliasSB6)->B6_SERIE) 	

					//Selecciona si es serie ,1,2 ó 3
					SF2->( DbSetOrder(1) )
					If SF2->( DbSeek(xFilial("SF2")+(cAliasSB6)->B6_DOC+(cAliasSB6)->B6_SERIE) )
						If !Empty(SF2->F2_YSERIE)
							cSerieR:= SF2->F2_YSERIE  
						Else
							If  !Empty(SF2->F2_SERIE2)
								cSerieR:= SF2->F2_SERIE2 
							Else
								cSerieR:= IIf(substr(SF2->F2_SERIE,1,2)=="00",SF2->F2_SERIE,"0"+substr(SF2->F2_SERIE,1,2)) 
							EndIf
						EndIf
					EndIf				                 

					cSerieR += cSep	

					If lTxt
						cIdent := "1"
						cIdent += cSep

						//05 - Contribuyentes del Régimen General: Código Único de la Operación (CUO)
						aAreaSB6 := (cAliasSB6)->(GetArea())
						nConta++
						dbSelectarea("SF2")
						dbSetorder(1)  
						dbSeek(xFilial("SF2")+(cAliasSB6)->B6_DOC+(cAliasSB6)->B6_SERIE)
						If dbSeek(xFilial("SF2")+(cAliasSB6)->B6_DOC+(cAliasSB6)->B6_SERIE) .And. !Empty(SF2->F2_NODIA)
							cSegofi := Strzero(nConta,3) + Right(SF2->F2_NODIA,5)
							cSegofi += cSep
						Else	
							cSegofi := ""
							cSegofi := Strzero(nConta,8)
							cSegofi += cSep
						EndIf	
						RestArea(aAreaSB6)

						If MV_PAR09 == 1
							cLin += (cDate1+cCod1+cTipo+cCodBr+cSegofi+cCodBr1+cUmedida+cEmiss+cSerieR+cGuiaR+cTipoOp+cDateEmis+cSeriePag+cDocPag+cDateRec+cNumCons+cNomeR+cQtdRec+cQtDevo+cQtdVen+cIdent)
						Else
							cLin += (cDate1+cCod1+cTipo+cCodBr+cSegofi+cCodBr1+cUmedida+cEmiss+cSerieR+cGuiaR+cTipoOp+cDateEmis+cSeriePag+cDocPag+cDateRec+cTipDoc1+cNumCons+cNomeR+cQtdRec+cQtDevo+cQtdVen+cIdent)
						EndIf	
						cLin += chr(13)+chr(10)

						fWrite(nHdl,cLin)
						cLin := ""
						cQtdRec := "0.00|"

					EndIf					
				Else  				
					//Selecciona si es serie ,1,2 ó 3
					dbSelectarea("SF1")
					SF1->( DbSetOrder(1) )
					If SF1->( DbSeek(xFilial("SF1")+(cAliasSB6)->B6_DOC+(cAliasSB6)->B6_SERIE+(cAliasSB6)->B6_CLIFOR+(cAliasSB6)->B6_LOJA) )
						If !Empty(SF1->F1_YSERIE)
							cSerieCons:= SF1->F1_YSERIE  
						Else
							If  !Empty(SF1->F1_SERIE2)
								cSerieCons:= SF1->F1_SERIE2 
							Else
								cSerieCons:= SF1->F1_SERIE
							EndIf
						EndIf
					EndIf

					oSection3:Init()
					nQtdReceb1:=0
					nQtdReceb1:=(cAliasSB6)->B6_QUANT
					oSection3:Cell("QTDDEV")  :Hide() 
					oSection3:Cell("QTDVEN")  :HIde()
					oSection3:Cell("nSaldo")  :SetValue((cAliasSB6)->B6_QUANT)
					oSection3:Cell("QTDREC")  :SetValue((cAliasSB6)->B6_QUANT)
					oSection3:Cell("B6_DOC")  :SetValue((cAliasSB6)->B6_DOC)
					oSection3:Cell(SerieNfId("SB6",3,"B6_SERIE")):SetValue(SerieNfId("SB6",2,"B6_SERIE"))
					oSection3:PrintLine()  
					oSection3:Cell("QTDDEV")  :Show()
					oSection3:Cell("QTDVEN")  :Show()				
					cDocCons:=(cAliasSB6)->B6_DOC 
					cSerieCons:=SerieNfId("SB6",2,"B6_SERIE")

					If lTxt // nota de entrada normal

						//08 - Fecha de emisión de la guía de remisión emitida por el consignador
						cEmiss := SubStr(DTOC((cAliasSB6)->B6_EMISSAO),1,6) + SubStr(DTOS((cAliasSB6)->B6_EMISSAO),1,4) 
						cEmiss += cSep

						//18 - Cantidad de bienes recibidos en consignación o por devolución del cliente (la primera tupla corresponde al saldo inicial)
						cQtdRec := AllTrim(StrTran(Transform(nQtdReceb1,"@E 999999999.99"),",",".")) 
						cQtdRec += cSep

						//10 - Número de la guía de remisión emitido por el consignador, con la que se reciben los bienes o se devuelven al consignador los bienes no vendidos

						cGuiaR := AllTrim((cAliasSB6)->B6_DOC) 
						cGuiaR += cSep

						//09 - Serie de la guía de remisión emitido por el consignador, con la que se reciben los bienes o se devuelven al consignador los bienes no vendidos	

						cSerieR := AllTrim((cAliasSB6)->B6_SERIE) //debe apuntar a la serie 2 de la remision cuando exxceda mas de 3 carácteres y si es de 3 posiciones se queda valor de b6_serie... 		

						//Seleccionar si es serie ,1,2 ó 3
						SF1->( DbSetOrder(1) )
						If SF1->( DbSeek(xFilial("SF1")+(cAliasSB6)->B6_DOC+(cAliasSB6)->B6_SERIE+(cAliasSB6)->B6_CLIFOR+(cAliasSB6)->B6_LOJA) )

							If !Empty(SF1->F1_YSERIE)
								cSerieR:= SF1->F1_YSERIE  
							Else
								If  !Empty(SF1->F1_SERIE2)
									cSerieR:= SF1->F1_SERIE2 
								Else
									cSerieR:= SF1->F1_SERIE
								EndIf
							EndIf
						EndIf					                 
						cSerieR += cSep	
					EndIf

					If lTxt
						cIdent := "1"
						cIdent += cSep

						//05 - Contribuyentes del Régimen General: Código Único de la Operación (CUO)
						aAreaSB6:= (cAliasSB6)->(GetArea())
						dbSelectarea("SF1")
						dbSetorder(1)
						dbSeek(xFilial("SF1")+(cAliasSB6)->B6_DOC+(cAliasSB6)->B6_SERIE) 
						nConta++  				  
						If  !Empty(SF1->F1_NODIA)
							cSegofi := Strzero(nConta,3) + Right(SF1->F1_NODIA,5)
							cSegofi += cSep
						Else	
							cSegofi := ""
							cSegofi := Strzero(nConta,8)
							cSegofi += cSep
						EndIf
						RestArea(aAreaSB6)

						If MV_PAR09 == 1
							cLin += (cDate1+cCod1+cTipo+cCodBr+cSegofi+cCodBr1+cUmedida+cEmiss+cSerieR+cGuiaR+cTipoOp+cDateEmis+cSeriePag+cDocPag+cDateRec+cNumCons+cNomeR+cQtdRec+cQtDevo+cQtdVen+cIdent)
						Else
							cLin += (cDate1+cCod1+cTipo+cCodBr+cSegofi+cCodBr1+cUmedida+cEmiss+cSerieR+cGuiaR+cTipoOp+cDateEmis+cSeriePag+cDocPag+cDateRec+cTipDoc1+cNumCons+cNomeR+cQtdRec+cQtDevo+cQtdVen+cIdent)
						EndIf	

						cLin += chr(13)+chr(10)

						fWrite(nHdl,cLin)
						cLin := ""
						cQtdRec := "0.00|"
					EndIf										
				EndIf
			EndIf				

			If (cAliasSB6)->B6_TIPO == "D"
				aAreaSB6 := (cAliasSB6)->(GetArea()) 
				SB6->(DbSelectarea("SB6"))
				SB6->(dbSetOrder(3))
				cSeek:=xFilial("SB6")+(cAliasSB6)->B6_IDENT+(cAliasSB6)->B6_PRODUTO+"D"
				If SB6->(MsSeek(cSeek,.T.))
					Do While SB6->(!Eof()) .And. SB6->B6_FILIAL+SB6->B6_IDENT+SB6->B6_PRODUTO+SB6->B6_PODER3 == cSeek 

						If SB6->B6_DTDIGIT < mv_par10 .Or. SB6->B6_DTDIGIT > mv_par11
							SB6->(dbSkip())
							Loop
						Endif 

						nQtdVend1 :=0
						nQtdVend1 := SB6->B6_QUANT   
						AreaSB6   := SB6->(GetArea()) 

						oSection3:Cell("QTDREC")  :Hide()	
						oSection3:Cell("nSaldo")  :SetValue(nQtdReceb1 - nQtdVend1) 
						oSection3:Cell("B6_DOC")  :SetValue(cDocCons)
						oSection3:Cell(SerieNfId("SB6",3,"B6_SERIE")):SetValue(cSerieCons)
						oSection3:Cell("TIPO")    :SetValue("01")


						dbSelectarea("SF2")
						dbSetorder(1)  
						dbSeek(xfilial("SF2")+SB6->B6_DOC+SB6->B6_SERIE)
						oSection3:Cell("SERIEPG") :SetValue(SerieNfId("SF2",2,"F2_SERIE"))
						oSection3:Cell("DOCPG")   :SetValue(SF2->F2_DOC)

						If lTxt						
							//11 - Tipo de Comprobante de Pago o Documento emitido por el consignatario, por la venta de los bienes recibidos en consignación
							cTipoOp := '01'
							cTipoOp += cSep

							//13 - Serie del Comprobante de Pago emitido por el consignatario, por la venta de los bienes recibidos en consignación (1)	
							cSeriePag := IIF(EMPTY(AllTrim(SF2->F2_YSERIE))==.T.,AllTrim(SF2->F2_YSERIE),IIF(EMPTY(AllTrim(SF2->F2_SERIE2))==.T.,AllTrim(SF2->F2_SERIE2),SF2->F2_SERIE))	  //	cSeriePag := AllTrim(SF2->F2_SERIE)   modificado por César Bautista																
							cSeriePag += cSep

							//14 - Número del Comprobante de Pago emitido por el consignatario, por la venta de los bienes recibidos en consignación (2)				    	
							cDocPag := AllTrim(SF2->F2_DOC)				   	
							cDocPag += cSep
						EndIf	

						If SF2->F2_TIPO == "N"
							oSection3:Cell("QTDDEV"):Hide()
							oSection3:Cell("QTDVEN"):SetValue(SB6->B6_QUANT)
							oSection3:Cell("DTCPG") :SetValue(SB6->B6_DTDIGIT)
							If lTxt						
								//08 - Fecha de emisión de la guía de remisión emitida por el consignador
								cEmiss := SubStr(DTOC(SB6->B6_EMISSAO),1,6) + SubStr(DTOS(SB6->B6_EMISSAO),1,4)
								cEmiss += cSep

								//20 - Cantidad de bienes vendidos por el consignatario
								If Empty(AllTrim(StrTran(Transform(SB6->B6_QUANT * (-1),"@E 999999999.99"),",",".")))
									cQtdVen := "0.00"
								Else	
									cQtdVen := AllTrim(StrTran(Transform(SB6->B6_QUANT * (-1),"@E 999999999.99"),",",".")) 
								EndIf
								cQtdVen += cSep

								//12 - Fecha de emisión del comprobante emitido por el consignatario, por la venta de los bienes recibidos en consignación		
								cDateEmis := SubStr(DTOC(SB6->B6_DTDIGIT),1,6)+SubStr(DTOS(SB6->B6_DTDIGIT),1,4)						
								cDateEmis += cSep	

								//15 - Fecha de recepción, devolución o venta del bien
								cDateRec := SubStr(DTOC(SB6->B6_DTDIGIT),1,6)+SubStr(DTOS(SB6->B6_DTDIGIT),1,4)
								cDateRec += cSep				   		    
							EndIf								
						Else
							oSection3:Cell("QTDDEV"):SetValue(SB6->B6_QUANT)
							oSection3:Cell("QTDVEN"):Hide()
							If lTxt
								//19 - Cantidad de bienes devueltos al consignador
								If Empty(AllTrim(StrTran(Transform(SB6->B6_QUANT * (-1),"@E 999999999.99"),",",".")))
									cQtDevo := "0.00"
								Else	
									cQtDevo := AllTrim(StrTran(Transform(SB6->B6_QUANT * (-1),"@E 999999999.99"),",","."))
								EndIf
								cQtDevo += cSep				   					   	
							EndIf							
						EndIf
						RestArea(AreaSB6)

						oSection3:PrintLine()

						nQtdReceb1:=nQtdReceb1 - nQtdVend1
						// Limpando as Celulas
						oSection3:Cell("QTDREC")  :Show()
						oSection3:Cell("DTCPG")   :SetValue("")
						oSection3:Cell("SERIEPG") :SetValue("")
						oSection3:Cell("DOCPG")   :SetValue("")
						oSection3:Cell(SerieNfId("SB6",3,"B6_SERIE")):SetValue("")
						oSection3:Cell("B6_DOC")  :SetValue("")
						If lTxt
							cIdent := "1"
							cIdent += cSep
							//05 - Contribuyentes del Régimen General: Código Único de la Operación (CUO)			   			
							nConta++
							If !Empty(SF2->F2_NODIA)
								cSegofi := Strzero(nConta,3) + Right(SF2->F2_NODIA,5)
								cSegofi += cSep
							Else	
								cSegofi := ""
								cSegofi := Strzero(nConta,8)
								cSegofi += cSep
							EndIf	

							If MV_PAR09 == 1
								cLin += (cDate1+cCod1+cTipo+cCodBr+cSegofi+cCodBr1+cUmedida+cEmiss+cSerieR+cGuiaR+cTipoOp+cDateEmis+cSeriePag+cDocPag+cDateRec+cNumCons+cNomeR+cQtdRec+cQtDevo+cQtdVen+cIdent)
							Else
								cLin += (cDate1+cCod1+cTipo+cCodBr+cSegofi+cCodBr1+cUmedida+cEmiss+cSerieR+cGuiaR+cTipoOp+cDateEmis+cSeriePag+cDocPag+cDateRec+cTipDoc1+cNumCons+cNomeR+cQtdRec+cQtDevo+cQtdVen+cIdent)
							EndIf	

							cLin += chr(13)+chr(10)

							fWrite(nHdl,cLin)
							cLin := ""			   			
						EndIf

						SB6->(DbSelectarea("SB6"))
						SB6->(dbSkip())
					EndDo
					RestArea(aAreaSB6)
				EndIF
			EndIf   

			// Lista as devolucoes da remessa
			If (((cAliasSB6)->B6_QUANT - nSaldo) > 0) 
				aAreaSB6 := (cAliasSB6)->(GetArea())
				SB6->(dbSetOrder(3))
				cSeek:=xFilial("SB6")+(cAliasSB6)->B6_IDENT+(cAliasSB6)->B6_PRODUTO+"D"
				If SB6->(dbSeek(cSeek))
					Do While SB6->(!Eof()) .And. SB6->B6_FILIAL+SB6->B6_IDENT+SB6->B6_PRODUTO+SB6->B6_PODER3 == cSeek 

						If SB6->B6_DTDIGIT < mv_par10 .Or. SB6->B6_DTDIGIT > mv_par11
							SB6->(dbSkip())
							Loop
						Endif 

						nQtdVend2 :=0
						nQtdVend2 := SB6->B6_QUANT  
						oSection2:Cell("B6_DOC")  :SetValue(cDocCons)
						oSection2:Cell(SerieNfId("SB6",3,"B6_SERIE")):SetValue(cSerieCons)
						oSection2:Cell("nSaldo"):SetValue(nQtdReceb2 - nQtdVend2) 
						oSection2:Cell("TIPO"):SetValue("01") 
						AreaSB6 := SB6->(GetArea()) 

						dbSelectarea("SF2")
						dbSetorder(6)  
						dbSeek(xFilial("SF2")+SB6->B6_SERIE+SB6->B6_DOC)
						oSection2:Cell("DOCPG"):SetValue(SF2->F2_DOC)
						oSection2:Cell("SERIEPG"):SetValue(SerieNfId("SF2",2,"F2_SERIE"))
						If SF2->F2_TIPO == "N"
							oSection2:Cell("QTDDEV"):Hide()
							oSection2:Cell("QTDVEN"):SetValue(SB6->B6_QUANT)
							oSection2:Cell("DTCPG") :SetValue(SB6->B6_DTDIGIT)
						Else
							oSection2:Cell("QTDDEV"):SetValue(SB6->B6_QUANT)
							oSection2:Cell("QTDVEN"):Hide()
							If lTxt				   		
								//11 - Tipo de Comprobante de Pago o Documento emitido por el consignatario, por la venta de los bienes recibidos en consignación
								cTipoOp := '01'
								cTipoOp += cSep

								//19 - Cantidad de bienes devueltos al consignador
								If Empty(AllTrim(StrTran(Transform(SB6->B6_QUANT * (-1),"@E 999999999.99"),",",".")))
									cQtDevo := "0.00"
								Else	
									cQtDevo := AllTrim(StrTran(Transform(SB6->B6_QUANT * (-1),"@E 999999999.99"),",","."))
								EndIf
								cQtDevo += cSep						   							   	
							EndIf							
						EndIf
						RestArea(AreaSB6)

						oSection2:Cell("QTDREC"):Hide()
						If MV_PAR09 == 2
							oSection2:PrintLine()
							If lTxt 
								cIdent := "1"
								cIdent += cSep

								//05 - Contribuyentes del Régimen General: Código Único de la Operación (CUO)	

								nConta++ 
								If !Empty(SF1->F1_NODIA)
									cSegofi := Strzero(nConta,3) + Right(SF1->F1_NODIA,5)
									cSegofi += cSep
								Else	
									cSegofi := ""
									cSegofi := Strzero(nConta,8)
									cSegofi += cSep
								EndIf	

								If MV_PAR09 == 1
									cLin += (cDate1+cCod1+cTipo+cCodBr+cSegofi+cCodBr1+cUmedida+cEmiss+cSerieR+cGuiaR+cTipoOp+cDateEmis+cSeriePag+cDocPag+cDateRec+cNumCons+cNomeR+cQtdRec+cQtDevo+cQtdVen+cIdent)
								Else
									cLin += (cDate1+cCod1+cTipo+cCodBr+cSegofi+cCodBr1+cUmedida+cEmiss+cSerieR+cGuiaR+cTipoOp+cDateEmis+cSeriePag+cDocPag+cDateRec+cTipDoc1+cNumCons+cNomeR+cQtdRec+cQtDevo+cQtdVen+cIdent)
								EndIf	

								cLin += chr(13)+chr(10)

								fWrite(nHdl,cLin)
								cLin := ""

							EndIf							
						EndIf  

						nQtdReceb2:=nQtdReceb2 - nQtdVend2

						oSection2:Cell("DTCPG") :SetValue("") 
						oSection2:Cell("DOCPG") :SetValue("")
						oSection2:Cell("QTDVEN"):SetValue("")
						oSection2:Cell("QTDDEV"):SetValue("")    				
						oSection2:Cell("QTDREC"):Show()
						oSection2:Cell("QTDDEV"):Show()

						SB6->(dbSkip())               
					EndDo
				Else
				EndIf
				RestArea(aAreaSB6)
			EndIf					
			dbSelectArea("SB6")    
			(cAliasSB6)->(dbSkip())
			oSection2:Cell("nSaldo"):SetValue("") 
		EndDo
		oSection1:Finish()
		oSection2:Finish()
		oSection3:Finish()
	EndDo
	fClose(nHdl)

Return NIL
