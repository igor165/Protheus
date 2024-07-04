#include "Protheus.ch"
#include "TopConn.ch"
#include "RwMake.ch"
#include "FISR010.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FISR010 ¦ Autor ¦ Rafael de Paula Goncalves¦ Data ¦ 11.11.09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Programa que Imprime relatorio de ISC/IGV   (PERU)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Menu Livros Fiscais: Atualizacoes->Relatorios->Listagens de   ³±±
±±³          ³Conferencia->Relatorio PDT                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISR010()
    
	Local olReport	:= NIL
	Private	apTxt	:= {{"P",""},{"R",""}}
	Private apTaxa	:= {}
	
	// Determina o uso dos campos _SERIE2 para o Peru
	Private lSerie2 := GetNewPar("MV_LSERIE2",.F.)

	If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
		Pergunte("FISR010",.F.)
		olReport := GeraReport()
		olReport:SetParam("FISR010")
		olReport:PrintDialog()
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GeraReport ¦ Autor ¦ Rafael de Paula Goncalves¦ Data ¦ 16.11.09		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera o objeto olReport e as secoes para impressao.            		³±±
±±³          ³Retornando objeto olReport.							          		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Chamado na funcao FISR010.									   		³±±
±±³          ³								                                   		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function GeraReport()
    Local olReport	:= NIL
					
	/*
	####################
	# Lista de Strings #
	####################
	STR0001 "Geracao do relatorio para preenchimento do PDT 0615 - Impuesto Selectivo al Consumo"
	STR0002 "NCM"
	STR0003 "Descricao"
	STR0004 "Quantidade"
	STR0005 "Valor por Unidade"
	STR0006 "Imposto"
	STR0007 "Fatura Original"
	STR0008 "Base Imponivel"
	STR0009 "Taxa"
	STR0010 "Total"
	STR0011 "Geracao do relatorio para preenchimento do PDT 0621 - IGV Renda Mensual"
	STR0012 "Data Emissao"
	STR0013 "Fatura"
	STR0014 "Serie"
	STR0015 "Tipo"
	STR0016 "Cliente"
	STR0017 "Valor Total"
	STR0018 "Base de Calculo"
	STR0019 "Total de devolucoes do Periodo:"
	STR0020 "Total de devolucoes do Periodo Anteriores:"
	STR0021 "Total geral de devolucoes:"
	STR0022 "Valor do Imposto"
	STR0023 "Emissao Original"
	STR0024 "Valor nao gravado"
	STR0025 "Data de Entrada"
	STR0026 "Fornecedor"
	STR0027 "Nacional/Importada"
	STR0028 "Totalizar:"
	STR0029 "Nacional:"
	STR0030 "Bases de Calculo por aliquota:"
	STR0031 "Valor isento:"
	STR0032 "Importada:"
	STR0033	"RUC"
	STR0034 "Tipo Comprovante"
	STR0035 " Comprovante"
	STR0036 "Numero Comprovante"
	STR0037 "Emissao Comprovante"
	STR0038 "Valor Percepcao"
	STR0039 "Serie da Fatura"
	STR0040 "Numero da Fatura"
	STR0041 "Emissao da Fatura"
	STR0042 "Valor da Fatura"
	STR0043 "Arquivos Gerados"
	STR0044	"No período informado, foram processados movimentos "
	STR0045 "de retenção de IGV. "
	STR0046 "de percepção de IGV. "
	STR0047 "de retenção e percepção de IGV. "
	STR0048 "No programa PDT existe a opção de importação destas movimentações. Para tanto, "
	STR0049 "foi gerado o arquivo "	
	STR0050 "foram gerados os arquivos "
	STR0051 " para as retenções e "
	STR0052	" para as percepções "
	STR0053 " no diretório "
	STR0054 " que pode(m) ser utilizado(s) para esta importação."
	STR0055 "Apendice III"
	STR0056 "Apendice IV - Sistema por valor"
	STR0057 "Apendice IV - Sistema especifico"
	STR0058 "Vendas Brutas"
	STR0059 "Desc. Concedidos e/ou Devolucoes de Venda"
	STR0060 "Vendas assumidas pelo Estado"
	STR0061 "Desc. Concedidos e/ou Devolucoes de Venda(Vendas Assumidas)"
	STR0062 "Vendas Lei 27037"
	STR0063 "Desc. Concedidos e/ou Devolucoes de Venda Lei 27037"
	STR0064 "Vendas nao gravadas(sem considerar exportacoes)"
	STR0065 "Destinadas a vendas - Nacionais e Importadas" 
	STR0066 "Aba Percepcao de IGV"
	STR0067 "Aba Retencao de IGV"
	*/
	
	olReport	:= TReport():New("FISR010",SubStr(STR0001,1,At("0",STR0001)-1),"FISR010",{|olReport|PrintReport(olReport)},"")   
                                                                
Return olReport
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PrintReport ¦ Autor ¦ Rafael de Paula Goncalves¦ Data ¦ 16.11.09		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera as querys que sao usadas nas secoes criadas, e lacos de totali-	³±±
±±³			 ³zacao e impressao das secoes. Chamadas da funcao GeraTxt().			³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Chamado na funcao GeraReport. 		 						  		³±±
±±³          ³								                                   		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PrintReport(olReport)                                  

	Local olSec1 		:= olReport:Section(1)
	Local olSec2 		:= olReport:Section(2)
	Local olSec3 		:= olReport:Section(3)
	Local olSec4 		:= olReport:Section(4)
	Local olSec5 		:= olReport:Section(5)
	Local olSec6 		:= olReport:Section(6)	
	Local olSec7 		:= olReport:Section(7)		
	Local olSec8 		:= olReport:Section(8)			
	Local olSec9 		:= olReport:Section(9)
	Local olSec10 		:= olReport:Section(10)
	Local nlLin			:= 0
	Local nlI			:= 1
	Local nlTotQtd		:= 0
	Local nlTotImp		:= 0
	Local nlTotVal		:= 0
	Local nlTotBas		:= 0
	Local nlTotPer		:= 0
	Local nlTotPerA		:= 0
	Local nlTotDev		:= 0
	Local alTotNI		:= {{0,0},{0,0}}
	Local alTotAlq		:= {}
	Local clQry1   		:= ""
	Local clQry2   		:= ""
	Local clQry3		:= "" 
	Local clQry4   		:= ""
	Local clQry5   		:= ""
	Local clQry6		:= ""
	Local clQry7		:= ""
	Local clQry8		:= ""
	Local clQry9		:= ""
	Local clQry10		:= ""
    Local nlCont		:= 1
    Local clTxt			:= "" 
	Local olBreak2	:= NIL
	Local nlCliente	:= TamSx3("A1_COD")[1]
	Local nlLjCli   := TamSx3("A1_LOJA")[1]     
	Local nlNomCli  := TamSx3("A1_NOME")[1]
	Local nlForn	:= TamSx3("A2_COD")[1]+TamSx3("A2_LOJA")[1]+TamSx3("A2_NOME")[1]
	Local lUsaNewKey:= TamSX3("F3_SERIE")[1] == 14  
    Local cSerF3	:= SerieNfId("SF3",3,"F3_SERIE")
	Local cSerF1	:= SerieNfId("SF1",3,"F1_SERIE")
    
	//Caso seja ISC	
	If mv_par01 == 1			
		
		olSec1 := TRSection():New(olReport,,{"QRY1"})       
			olSec1:SetTotalInLine(.F.)
			olSec1:SetTotalText(STR0010)
			TRCell():New(olSec1,"YD_TEC"    ,"QRY1",STR0002,PesqPict("SYD","YD_TEC"    ),  ,   )
			TRCell():New(olSec1,"YD_DESC_P" ,"QRY1",STR0003,PesqPict("SYD","YD_DESC_P" ),  ,   )
			TRCell():New(olSec1,"D2_QUANT"  ,"QRY1",STR0004,PesqPict("SD2","D2_QUANT"  ),  ,   )
			TRCell():New(olSec1,"D2_PRCVEN" ,"QRY1",STR0005,PesqPict("SD2","D2_PRCVEN" ),  ,   )
			TRCell():New(olSec1,"D2_VALIMP2","QRY1",STR0006,PesqPict("SD2","D2_VALIMP2"),  ,   )				    
			TRFunction():New(olSec1:Cell("D2_QUANT")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,PesqPict("SD2","D2_QUANT"  ),/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
			TRFunction():New(olSec1:Cell("D2_VALIMP2")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,PesqPict("SD2","D2_VALIMP2"  ),/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)			
		olSec2 := TRSection():New(olReport,,{"QRY2"})                          	
			olSec2:SetTotalInLine(.F.)
			olSec2:SetTotalText(STR0070)
			TRCell():New(olSec2,"YD_TEC"    ,"QRY2",STR0002,PesqPict("SYD","YD_TEC"    ),  ,   )
			TRCell():New(olSec2,"YD_DESC_P"	 ,"QRY2",STR0003,PesqPict("SB1","B1_DESC"   ),  ,   )
			TRCell():New(olSec2,"D2_BASIMP2","QRY2",STR0008,PesqPict("SD2","D2_BASIMP2"),  ,   )
			TRCell():New(olSec2,"D2_ALQIMP2","QRY2",STR0009,PesqPict("SD2","D2_ALQIMP2"),  ,   )
			TRCell():New(olSec2,"D2_VALIMP2","QRY2",STR0006,PesqPict("SD2","D2_VALIMP2"),14,.F.)
			olBreak2 := TRBreak():New(olSec2,olSec2:Cell("D2_ALQIMP2"),STR0010+ " "+STR0009,.F.) 
			TRFunction():New(olSec2:Cell("D2_BASIMP2")	,/* cID */,"SUM",olBreak2,/*cTitle*/,PesqPict("SD2","D2_BASIMP2"  ),/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
			TRFunction():New(olSec2:Cell("D2_VALIMP2")	,/* cID */,"SUM",olBreak2,/*cTitle*/,PesqPict("SD2","D2_VALIMP2"  ),/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)			
			
		olSec3 := TRSection():New(olReport,,{"QRY3"})
			olSec3:SetTotalInLine(.F.)
			olSec3:SetTotalText(STR0010)
			TRCell():New(olSec3,"YD_TEC"    	,"QRY3",STR0002,PesqPict("SYD","YD_TEC"    ),  ,   )
			TRCell():New(olSec3,"YD_DESC_P" 	,"QRY3",STR0003,PesqPict("SYD","B1_DESC"   ),  ,   )
			TRCell():New(olSec3,"D2_QUANT"    	,"QRY3",STR0004,PesqPict("SD2","D2_QUANT"  ),  ,   )
			TRCell():New(olSec3,"D2_PRCVEN"   	,"QRY3",STR0005,PesqPict("SD2","D2_PRCVEN" ),  ,   )
			TRCell():New(olSec3,"D2_VALIMP2"  	,"QRY3",STR0006,PesqPict("SD2","D2_VALIMP2"),  ,   )
			
			TRFunction():New(olSec3:Cell("D2_QUANT")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,PesqPict("SD2","D2_QUANT"  ),/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
			TRFunction():New(olSec3:Cell("D2_VALIMP2")	,/* cID */,"SUM",/*oBreak*/,/*cTitle*/,PesqPict("SD2","D2_VALIMP2"),/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
	//Caso seja IGV
	Else
		olReport:SetLandscape()			// Formato paisagem		
 		olSec1 := TRSection():New(olReport,,{"QRY1"})
 			olSec1:SetTotalInLine(.F.)
			olSec1:SetTotalText(STR0010)
			TRCell():New(olSec1,"F3_ENTRADA","QRY1",STR0012, 								, 			,.F.) 
			TRCell():New(olSec1,"F3_NFISCAL","QRY1",STR0013, 								,13	   		,.F.)
			TRCell():New(olSec1,cSerF3	    ,"QRY1",STR0014, 								,  			,.F.,{|| Iif(Empty(&cSerF3),F3_SERIE2,&cSerF3) })
			TRCell():New(olSec1,"F2_TPDOC"	,"QRY1",STR0015, 								,			,.F.)									
			TRCell():New(olSec1,"A1_COD"   	,"QRY1",STR0016,							 	,nlCliente+1,.F.)
			TRCell():New(olSec1,"A1_LOJA"   ,"QRY1",STR0068,						 		,nlLjCli	,.F.)
			TRCell():New(olSec1,"A1_NOME"   ,"QRY1",STR0069,							 	,nlNomCli	,.F.)						
			TRCell():New(olSec1,"F3_VALCONT","QRY1",STR0017,PesqPict("SF3","F3_VALCONT")	,	  		,.F.)	
			TRCell():New(olSec1,"F3_BASIMP1","QRY1",STR0018,PesqPict("SF3","F3_BASIMP1")	,  			,.F.)
			
			TRFunction():New(olSec1:Cell("F3_VALCONT")	,,"SUM",,,PesqPict("SF3","F3_VALCONT"),,,.F.,)
			TRFunction():New(olSec1:Cell("F3_BASIMP1")	,,"SUM",,,PesqPict("SF3","F3_BASIMP1"),,,.F.,)
			
 		olSec2 := TRSection():New(olReport,,{"QRY2"})
			TRCell():New(olSec2,"F3_ENTRADA","QRY2",STR0012,							 	,	  		,.F.) 
			TRCell():New(olSec2,"F3_NFISCAL","QRY2",STR0013,							 	,13  		,.F.)
			TRCell():New(olSec2,cSerF3		,"QRY2",STR0014,		                     	,			,.F.,{|| Iif(Empty(&cSerF3),F3_SERIE2,&cSerF3) })
			TRCell():New(olSec2,"D1_NFORI"  ,"QRY2",STR0007,							 	,  			,.F.)
			TRCell():New(olSec2,"D1_SERIORI","QRY2",STR0014,							 	,			,.F.)
			TRCell():New(olSec2,"F2_EMISSAO","QRY2",STR0023,							 	,			,.F.)            
			TRCell():New(olSec2,"A1_COD"   	,"QRY2",STR0016,							 	,nlCliente+1,.F.)
			TRCell():New(olSec2,"A1_LOJA"   ,"QRY2",STR0068,						 		,nlLjCli	,.F.)
			TRCell():New(olSec2,"A1_NOME"   ,"QRY2",STR0069,							 	,nlNomCli	,.F.)						
			TRCell():New(olSec2,"F3_VALCONT","QRY2",STR0017,PesqPict("SF3","F3_VALCONT" )	,	   		,.F.)
			TRCell():New(olSec2,"F3_BASIMP1","QRY2",STR0018,PesqPict("SF3","F3_BASIMP1" )	,  			,.F.)
		olSec3 := TRSection():New(olReport,,{"QRY3"})
			TRCell():New(olSec3,"F3_ENTRADA","QRY3",STR0012,							 	,			,.F.) 
			TRCell():New(olSec3,"F3_NFISCAL","QRY3",STR0013,							 	,13	   		,.F.)
			TRCell():New(olSec3,cSerF3		,"QRY3",STR0014,		                     	,  			,.F.,{|| Iif(Empty(&cSerF3),F3_SERIE2,&cSerF3) })
			TRCell():New(olSec3,"F2_TPDOC"	,"QRY3",STR0015,							 	,	   		,.F.)                       
			
			TRCell():New(olSec3,"A1_COD"   	,"QRY3",STR0016,							 	,nlCliente+1,.F.)
			TRCell():New(olSec3,"A1_LOJA"   ,"QRY3",STR0068,						 		,nlLjCli	,.F.)
			TRCell():New(olSec3,"A1_NOME"   ,"QRY3",STR0069,							 	,nlNomCli	,.F.)			
						
			TRCell():New(olSec3,"F3_VALCONT","QRY3",STR0017,PesqPict("SF3","F3_VALCONT")	,	   		,.F.)
			TRCell():New(olSec3,"F3_BASIMP1","QRY3",STR0018,PesqPict("SF3","F3_BASIMP1")	,	   		,.F.)
			TRCell():New(olSec3,"F3_VALIMP1","QRY3",STR0022,PesqPict("SF3","F3_VALIMP1")	,  			,.F.)	
		olSec4 := TRSection():New(olReport,,{"QRY4"})
			TRCell():New(olSec4,"F3_ENTRADA","QRY4",STR0012,							 	,	  		,.F.) 
			TRCell():New(olSec4,"F3_NFISCAL","QRY4",STR0013,							 	,13			,.F.)
			TRCell():New(olSec4,cSerF3		,"QRY4",STR0014,		                     	,  			,.F.,{|| Iif(Empty(&cSerF3),F3_SERIE2,&cSerF3) })
			TRCell():New(olSec4,"D1_NFORI"  ,"QRY4",STR0007,							 	,			,.F.)
			TRCell():New(olSec4,"D1_SERIORI","QRY4",STR0014,							 	,			,.F.)
			TRCell():New(olSec4,"F2_EMISSAO","QRY4",STR0023,							 	,  			,.F.)
			
			TRCell():New(olSec4,"A1_COD"   	,"QRY4",STR0016,							 	,nlCliente+1,.F.)
			TRCell():New(olSec4,"A1_LOJA"   ,"QRY4",STR0068,						 		,nlLjCli	,.F.)
			TRCell():New(olSec4,"A1_NOME"   ,"QRY4",STR0069,							 	,nlNomCli	,.F.)			
									
			TRCell():New(olSec4,"F3_VALCONT","QRY4",STR0017,PesqPict("SF3","F3_VALCONT")	,			,.F.)			
			TRCell():New(olSec4,"F3_BASIMP1","QRY4",STR0018,PesqPict("SF3","F3_BASIMP1")	,			,.F.)
			TRCell():New(olSec4,"F3_VALIMP1","QRY4",STR0022,PesqPict("SF3","F3_VALIMP1")	,			,.F.)			
		olSec5 := TRSection():New(olReport,,{"QRY5"}) 
 			olSec5:SetTotalInLine(.F.)
			olSec5:SetTotalText(STR0010)
			
			TRCell():New(olSec5,"F3_ENTRADA","QRY5",STR0012,							 	,			,.F.) 
			TRCell():New(olSec5,"F3_NFISCAL","QRY5",STR0013,							 	,13			,.F.)
			TRCell():New(olSec5,cSerF3		,"QRY5",STR0014,		                     	, 			,.F.,{|| Iif(Empty(&cSerF3),F3_SERIE2,&cSerF3) })
			TRCell():New(olSec5,"CCL_CODGOV","QRY5",STR0015,							 	,			,.F.)			
			TRCell():New(olSec5,"A1_COD"   	,"QRY5",STR0016,							 	,nlCliente+1,.F.)
			TRCell():New(olSec5,"A1_LOJA"   ,"QRY5",STR0068,						 		,nlLjCli	,.F.)
			TRCell():New(olSec5,"A1_NOME"   ,"QRY5",STR0069,							 	,nlNomCli	,.F.)			
			TRCell():New(olSec5,"F3_VALCONT","QRY5",STR0017,PesqPict("SF3","F3_VALCONT")	,			,.F.)
			TRCell():New(olSec5,"F3_BASIMP1","QRY5",STR0018,PesqPict("SF3","F3_BASIMP1")	,  			,.F.)
			
			TRFunction():New(olSec5:Cell("F3_VALCONT")	,,"SUM",,,PesqPict("SF3","F3_VALCONT"),,,.F.,)
			TRFunction():New(olSec5:Cell("F3_BASIMP1")	,,"SUM",,,PesqPict("SF3","F3_BASIMP1"),,,.F.,)
			
		olSec6 := TRSection():New(olReport,,{"QRY6"})
			TRCell():New(olSec6,"F3_ENTRADA","QRY6",STR0012,							 	,	   		,.F.) 
			TRCell():New(olSec6,"F3_NFISCAL","QRY6",STR0013,							 	,13	   		,.F.)
			TRCell():New(olSec6,cSerF3		,"QRY6",STR0014,		                     	,			,.F.,{|| Iif(Empty(&cSerF3),F3_SERIE2,&cSerF3) })
			TRCell():New(olSec6,"D1_NFORI"  ,"QRY6",STR0007,							 	,			,.F.)
			TRCell():New(olSec6,"D1_SERIORI","QRY6",STR0014,							 	,			,.F.)
			TRCell():New(olSec6,"F2_EMISSAO","QRY6",STR0023,							 	,			,.F.)
			TRCell():New(olSec6,"CLIENTE"   ,"QRY6",STR0016,								,nlCliente	,.F.)
			TRCell():New(olSec6,"F3_VALCONT","QRY6",STR0017,PesqPict("SF3","F3_VALCONT")	,	   		,.F.)
			TRCell():New(olSec6,"F3_BASIMP1","QRY6",STR0018,PesqPict("SF3","F3_BASIMP1")	,  			,.F.)
		olSec7 := TRSection():New(olReport,,{"QRY7"})
			olSec7:SetTotalInLine(.F.)
			olSec7:SetTotalText(STR0010)
			
			TRCell():New(olSec7,"F3_ENTRADA","QRY7",STR0012,							 	,	   		,.F.) 
			TRCell():New(olSec7,"F3_NFISCAL","QRY7",STR0013,							 	,13	   		,.F.)
			TRCell():New(olSec7,cSerF3		,"QRY7",STR0014,		                     	,	   		,.F.,{|| Iif(Empty(&cSerF3),F3_SERIE2,&cSerF3) })
			TRCell():New(olSec7,"F2_TPDOC"  ,"QRY7",STR0015,							 	,	  		,.F.)			
			TRCell():New(olSec7,"A1_COD"   	,"QRY7",STR0016,							 	,nlCliente+1,.F.)
			TRCell():New(olSec7,"A1_LOJA"   ,"QRY7",STR0068,						 		,nlLjCli	,.F.)
			TRCell():New(olSec7,"A1_NOME"   ,"QRY7",STR0069,							 	,nlNomCli	,.F.)						
			TRCell():New(olSec7,"F3_VALCONT","QRY7",STR0017,PesqPict("SF3","F3_VALCONT")	,			,.F.)
			TRCell():New(olSec7,"F3_EXENTAS","QRY7",STR0024,PesqPict("SF3","F3_EXENTAS")	,	   		,.F.)
			
			TRFunction():New(olSec7:Cell("F3_VALCONT")	,,"SUM",,,PesqPict("SF3","F3_VALCONT"),,,.F.,)
			TRFunction():New(olSec7:Cell("F3_EXENTAS")	,,"SUM",,,PesqPict("SF3","F3_EXENTAS"),,,.F.,)
			
		olSec8 := TRSection():New(olReport,,{"QRY8"})
			TRCell():New(olSec8,"F3_ENTRADA","QRY8",STR0012,							 	,	   		,.F.) 
			TRCell():New(olSec8,"F3_EMISSAO","QRY8",STR0025,							 	,	   		,.F.)
			TRCell():New(olSec8,"F3_NFISCAL"	 ,"QRY8",STR0013,		                     	,13	   		,.F.)
			TRCell():New(olSec8,cSerF3		,"QRY8",STR0014,		                     	,	   		,.F.,{|| Iif(Empty(&cSerF3),F3_SERIE2,&cSerF3) })
			TRCell():New(olSec8,"TIPOGOV"	,"QRY8",STR0015,							 	,	  		,.F.,{|| Iif(EMPTY(QRY8->F1_TPDOC),QRY8->F2_TPDOC,QRY8->F1_TPDOC) })
			
			TRCell():New(olSec8,"A2_COD"   	,"QRY8",STR0026,							 	,nlCliente+1,.F.)
			TRCell():New(olSec8,"A2_LOJA"   ,"QRY8",STR0068,						 		,nlLjCli	,.F.)
			TRCell():New(olSec8,"A2_NOME"   ,"QRY8",STR0069,							 	,nlNomCli	,.F.)
											
			TRCell():New(olSec8,"TIPO"      ,"QRY8",SubStr(STR0027,1,3) + SubStr(STR0027,At("/",STR0027),4),								,			,.F.)
			TRCell():New(olSec8,"F3_VALCONT","QRY8",STR0017,PesqPict("SF3","F3_VALCONT")	,           ,.F.)
			TRCell():New(olSec8,"F3_BASIMP1","QRY8",STR0018,PesqPict("SF3","F3_BASIMP1")	,	   		,.F.)
			TRCell():New(olSec8,"F3_EXENTAS","QRY8",STR0024,PesqPict("SF3","F3_EXENTAS")	,	   		,.F.)			
		olSec9 := TRSection():New(olReport,,{"QRY9"})
			TRCell():New(olSec9,"A2_CGC"	 ,"QRY9",STR0033,							 	,13	   		,.F.) 
			TRCell():New(olSec9,"F1_TPDOC"   ,"QRY9",STR0034,							 	,	   		,.F.)
			TRCell():New(olSec9,"FE_SERIE"	 ,"QRY9",STR0035,		                     	,	   		,.F.)
			TRCell():New(olSec9,"FE_NFISCAL","QRY9",STR0036,                            	,13	   		,.F.)			
			TRCell():New(olSec9,"FE_EMISSAO","QRY9",STR0037,							 	,	  		,.F.)
			TRCell():New(olSec9,"FE_VALIMP" ,"QRY9",STR0038,PesqPict("SFE","FE_VALIMP")	,			,.F.)
			TRCell():New(olSec9,cSerF1		,"QRY9",STR0039,								,			,.F.,{|| Iif(Empty(&cSerF1),F1_SERIE2,&cSerF1) })
			TRCell():New(olSec9,"F1_DOC"    ,"QRY9",STR0040,								,13	   		,.F.)			
			TRCell():New(olSec9,"F1_EMISSAO","QRY9",STR0041,								,	   		,.F.)			
			TRCell():New(olSec9,"F1_VALBRUT","QRY9",STR0042,PesqPict("SF1","F1_VALBRUT")	,	   		,.F.,{|| xMoeda(F1_VALBRUT,F1_MOEDA,1,,,F1_TXMOEDA) })
		olSec10 := TRSection():New(olReport,,{"QRY10"})
			TRCell():New(olSec10,"A2_CGC"    ,"QRY10",STR0033,							 	,13	   		,.F.) 
			TRCell():New(olSec10,"F1_TPDOC"	 ,"QRY10",STR0034,							 	,	   		,.F.)
			TRCell():New(olSec10,"FE_SERIE"	 ,"QRY10",STR0035,		                     	,	   		,.F.)
			TRCell():New(olSec10,"FE_NFISCAL","QRY10",STR0036,		                     	,13	   		,.F.)			
			TRCell():New(olSec10,"FE_EMISSAO","QRY10",STR0037,							 	,	  		,.F.)
			TRCell():New(olSec10,"FE_RETENC" ,"QRY10",STR0038,PesqPict("SFE","FE_VALIMP")	,			,.F.)
			TRCell():New(olSec10,cSerF1		,"QRY10",STR0039,								,			,.F.,{|| Iif(Empty(&cSerF1),F1_SERIE2,&cSerF1) })
			TRCell():New(olSec10,"F1_DOC"	  ,"QRY10",STR0040,								,13	   		,.F.)			
			TRCell():New(olSec10,"F1_EMISSAO","QRY10",STR0041,								,	   		,.F.)			
			TRCell():New(olSec10,"F1_VALBRUT","QRY10",STR0042,PesqPict("SF1","F1_VALBRUT")	,	   		,.F.,{|| xMoeda(F1_VALBRUT,F1_MOEDA,1,,,F1_TXMOEDA) })
	Endif

    //Caso seja ISC
	If mv_par01 == 1
    	//Apendice III
		clQry1	:=" SELECT  DISTINCT YD_TEC"
		clQry1	+=" , YD_DESC_P"
		clQry1	+=" , D2_QUANT"
		clQry1	+=" , D2_PRCVEN"
		clQry1	+=" , D2_VALIMP2"
		clQry1	+=" FROM " + RetSqlName('SD2')+ " SD2"
		                 
		clQry1	+=" JOIN " + RetSqlName('SB1')+ " SB1"                   		
		clQry1	+=" ON B1_COD = D2_COD"
		clQry1	+=" AND '"+xFilial('SB1')+"' = B1_FILIAL"
		clQry1	+=" AND SB1.D_E_L_E_T_ = ' '"
		
		clQry1	+=" JOIN " + RetSqlName('SYD')+ " SYD"	
		clQry1	+=" ON YD_TEC = B1_POSIPI"
		clQry1	+=" AND YD_APEND = '1'"
		clQry1	+=" AND '"+xFilial('SYD')+"' = YD_FILIAL"
		clQry1	+=" AND SYD.D_E_L_E_T_ = ' '"
		clQry1	+=" WHERE D2_EMISSAO BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"'"
		clQry1	+=" AND SD2.D_E_L_E_T_ = ' '"
		clQry1	+=" AND '"+xFilial('SD2')+"' = SD2.D2_FILIAL"
		clQry1	+=" AND SD2.D2_VLRISC > 0"

	 	TCQUERY clQry1 NEW ALIAS "QRY1"
	 	
	 	//Apendice IV - Sistema por valor
	 	clQry2	:=" SELECT  DISTINCT YD_TEC"
		clQry2	+=" , YD_DESC_P"
		clQry2	+=" , D2_BASIMP2"
		clQry2	+=" , D2_ALQIMP2"
		clQry2	+=" , D2_VALIMP2"
		clQry2	+=" FROM " + RetSqlName('SD2')+ " SD2"
		                   
		clQry2	+=" JOIN " + RetSqlName('SB1')+ " SB1"                   		
		clQry2	+=" ON B1_COD = D2_COD"
		clQry2	+=" AND '"+xFilial('SB1')+"' = B1_FILIAL"
		clQry2	+=" AND SB1.D_E_L_E_T_ = ' '"
		
		clQry2	+=" JOIN " + RetSqlName('SYD')+ " SYD"	
		clQry2	+=" ON YD_TEC = B1_POSIPI"
		clQry2	+=" AND YD_APEND <> '1'"
		clQry2	+=" AND '"+xFilial('SYD')+"' = YD_FILIAL"
		clQry2	+=" AND SYD.D_E_L_E_T_ = ' '"
		
		clQry2	+=" WHERE D2_EMISSAO BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"'"
		clQry2	+=" AND SD2.D_E_L_E_T_ = ' '"
		clQry2	+=" AND '"+xFilial('SD2')+"' = SD2.D2_FILIAL"
		clQry2	+=" AND SD2.D2_VLRISC = 0"
		clQry2	+=" AND SD2.D2_BASIMP2 > 0"
		clQry2	+=" AND SD2.D2_ALQIMP2 > 0"
		
		clQry2	+=" ORDER BY D2_ALQIMP2"
			
	 	TCQUERY clQry2 NEW ALIAS "QRY2"

	 	//Apendice IV - Sistema especifico
		clQry3	:=" SELECT YD_TEC"
		clQry3	+=" , YD_DESC_P"
		clQry3	+=" , D2_QUANT"
		clQry3	+=" , D2_PRCVEN"
		clQry3	+=" , D2_VALIMP2"
		clQry3	+=" FROM " + RetSqlName('SD2')+ " SD2"
		                   
		clQry3	+=" JOIN " + RetSqlName('SB1')+ " SB1"                   		
		clQry3	+=" ON B1_COD = D2_COD"
		clQry3	+=" AND '"+xFilial('SB1')+"' = B1_FILIAL"
		clQry3	+=" AND SB1.D_E_L_E_T_ = ' '"
		
		clQry3	+=" JOIN " + RetSqlName('SYD')+ " SYD"	
		clQry3	+=" ON YD_TEC = B1_POSIPI"
		clQry3	+=" AND YD_APEND = '2'"
		clQry3	+=" AND '"+xFilial('SYD')+"' = YD_FILIAL"
		clQry3	+=" AND SYD.D_E_L_E_T_ = ' '"
		
		clQry3	+=" WHERE D2_EMISSAO BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"'"
		clQry3	+=" AND SD2.D_E_L_E_T_ = ' '"
		clQry3	+=" AND '"+xFilial('SD2')+"' = SD2.D2_FILIAL"
		clQry3	+=" AND SD2.D2_VLRISC > 0"
		
		clQry3	+=" ORDER BY YD_TEC"		
	 	TCQUERY clQry3 NEW ALIAS "QRY3"
	 	if QRY1->(!EoF())
			olReport:PrintText(STR0055,,)	 
			olSec1:Print()
			olReport:SkipLine()
			//olReport:SkipLine()
		Endif
		if QRY2->(!EoF())
			olReport:PrintText(STR0056,,)
			DbSelectArea("QRY2")
			QRY2->(DbGoTop())
			Do While QRY2->(!EoF())
				nlCont	:= aScan(apTaxa,{|aX| aX == QRY2->D2_ALQIMP2})
				if nlCont == 0
					aAdd(apTaxa,QRY2->D2_ALQIMP2)
				Endif	
				QRY2->(DbSkip())				
			EndDo
			olSec2:Print()          	
			olReport:SkipLine()
		Endif
		if QRY3->(!EoF())
			olReport:PrintText(STR0057,,)
			olSec3:Print()			
		Endif	
				
		QRY1->(dbCloseArea())
		QRY2->(dbCloseArea())
		QRY3->(dbCloseArea())
		
    //Caso seja IGV
	Else
	
		//Vendas Brutas
		clQry1	:="SELECT DISTINCT F3_ENTRADA" 
		clQry1	+=" , F3_NFISCAL"
		If lSerie2
			clQry1 += ", F3_SERIE2 "
		EndIf
		clQry1	+=" ,  F3_SERIE "
		If lUsaNewKey
			clQry1	+=",  F3_SDOC "
		EndIF		
		clQry1	+=" , F2_TPDOC"
		clQry1  +=" , A1_COD"
		clQry1  +=" , A1_LOJA" 
		clQry1  +=" , A1_NOME"
		clQry1  +=" , F2_TPDOC"
		clQry1	+=" , F3_VALCONT"
		clQry1	+=" , F3_BASIMP1"
		clQry1	+=" FROM " + RetSqlName('SF3') + " SF3"
		
		clQry1	+=" JOIN " + RetSqlName('SF2') + " SF2"
		clQry1	+=" ON F3_NFISCAL = F2_DOC"
		clQry1	+=" AND F3_SERIE = F2_SERIE"
		clQry1	+=" AND F3_CLIEFOR = F2_CLIENTE"
		clQry1	+=" AND F3_LOJA = F2_LOJA"
		clQry1	+=" AND '"+xFilial('SF2')+"' = F2_FILIAL AND SF2.D_E_L_E_T_ = ' '"
		
		clQry1	+=" JOIN " + RetSqlName('SA1') + " SA1"
		clQry1	+=" ON F3_CLIEFOR = A1_COD"
		clQry1	+=" AND F3_LOJA = A1_LOJA"
		clQry1	+=" AND '"+xFilial('SA1')+"' = A1_FILIAL AND SA1.D_E_L_E_T_ = ' '"
		 
		clQry1	+=" WHERE F3_ENTRADA BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"'"
		clQry1	+=" AND SF3.D_E_L_E_T_ = ' ' AND '"+xFilial('SF3')+"' = F3_FILIAL AND F3_TIPOMOV = 'V' AND F3_VALIMP1 > 0 AND F3_ESPECIE <> 'NCC'"		
		clQry1	+=" ORDER BY F3_ENTRADA,F3_NFISCAL "		
	 	TCQUERY clQry1 NEW ALIAS "QRY1"

 		//Desc. Concedidos e/ou Devolucoes de Venda
		clQry2	:="SELECT  DISTINCT F3_ENTRADA" 
		clQry2	+=" , F3_NFISCAL"
		If lSerie2
			clQry2 += ", F3_SERIE2 "
		EndIf
		clQry2	+=" ,  F3_SERIE "
		If lUsaNewKey
			clQry2	+=",  F3_SDOC "
		EndIF
		clQry2	+=" , D1_NFORI"
		clQry2	+=" , "+SerieNfId('SD1',3,'D1_SERIORI')+" D1_SERIORI "
		clQry2	+=" , F2_EMISSAO"				
		clQry2	+=" , F2_EMISSAO"				
		clQry2  +=" , A1_COD"
		clQry2  +=" , A1_LOJA" 
		clQry2  +=" , A1_NOME"		
		clQry2	+=" , F3_VALCONT"
		clQry2	+=" , F3_BASIMP1"
		clQry2	+=" FROM " + RetSqlName('SF3') + " SF3"
		
		clQry2	+=" JOIN " + RetSqlName('SD1') + " SD1"
		clQry2	+=" ON F3_NFISCAL = D1_DOC"
		clQry2	+=" AND F3_SERIE = D1_SERIE"
		clQry2	+=" AND F3_CLIEFOR = D1_FORNECE"
		clQry2	+=" AND F3_LOJA = D1_LOJA"				
		clQry2	+=" AND '"+xFilial('SD1')+"' = D1_FILIAL"
		clQry2	+=" AND SD1.D_E_L_E_T_ = ' '"
		
		clQry2	+=" JOIN " + RetSqlName('SF2') + " SF2"
		clQry2	+=" ON D1_NFORI = F2_DOC"
		clQry2	+=" AND D1_SERIORI = F2_SERIE"
	   	clQry2	+=" AND D1_FORNECE = F2_CLIENTE
 		clQry2	+=" AND D1_LOJA = F2_LOJA" 
		clQry2	+=" AND '"+xFilial('SF2')+"' = F2_FILIAL"
		clQry2	+=" AND SF2.D_E_L_E_T_ = ' '"
				
		clQry2	+=" JOIN " + RetSqlName('SA1') + " SA1"
		clQry2	+=" ON F3_CLIEFOR = A1_COD"
		clQry2	+=" AND F3_LOJA = A1_LOJA"
		clQry2	+=" AND '"+xFilial('SA1')+"' = A1_FILIAL"
		clQry2	+=" AND SA1.D_E_L_E_T_ = ' '"
		 
		clQry2	+=" WHERE F3_ENTRADA BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"'"
		clQry2	+=" AND SF3.D_E_L_E_T_ = ' '"
		clQry2	+=" AND '"+xFilial('SF3')+"' = F3_FILIAL"
		clQry2	+=" AND F3_TIPOMOV = 'V'"
		clQry2	+=" AND F3_VALIMP1 > 0"
		clQry2	+=" AND F3_ESPECIE = 'NCC'"		
		clQry2	+=" ORDER BY F3_ENTRADA,F3_NFISCAL "				
	 	TCQUERY clQry2 NEW ALIAS "QRY2"
	 	
	 	//Vendas assumidas pelo Estado
		clQry3	:="SELECT DISTINCT  F3_ENTRADA" 
		clQry3	+=" , F3_NFISCAL"
		If lSerie2
			clQry3 += " , F3_SERIE2 "
		EndIf
		clQry3	+=" ,  F3_SERIE "
		If lUsaNewKey
			clQry3	+=",  F3_SDOC "
		EndIF
		clQry3	+=" , F2_TPDOC"
		clQry3  +=" , A1_COD"
		clQry3  +=" , A1_LOJA" 
		clQry3  +=" , A1_NOME"
		clQry3	+=" , F3_VALCONT"
		clQry3	+=" , F3_BASIMP1"
		clQry3	+=" , F3_VALIMP1"
		clQry3	+=" FROM " + RetSqlName('SF3') + " SF3"
		
		clQry3 += " JOIN " + RetSqlName("SF2") + " SF2 "
		clQry3 += " ON F2_DOC = F3_NFISCAL "
		clQry3 += " AND F2_SERIE = F3_SERIE "
		clQry3 += " AND F2_ESPECIE = F3_ESPECIE "
		clQry3 += " AND F2_CLIENTE = F3_CLIEFOR "
		clQry3 += " AND F2_LOJA = F3_LOJA "			
		clQry3 += " AND F2_FILIAL = '" + XFILIAL("SF2") + "'	" 
		clQry3 += " AND SF2.D_E_L_E_T_ <> '*'"	
		
		clQry3	+=" JOIN " + RetSqlName('SA1') + " SA1"
		clQry3	+=" ON F3_CLIEFOR = A1_COD"
		clQry3	+=" AND F3_LOJA = A1_LOJA"		
		clQry3	+=" AND '"+xFilial('SA1')+"' = A1_FILIAL"
		clQry3	+=" AND SA1.D_E_L_E_T_ = ' '"
		
		clQry3	+=" JOIN " + RetSqlName('SF4') + " SF4"
		clQry3	+=" ON F3_TES = F4_CODIGO"
		clQry3	+=" AND '"+xFilial('SF4')+"' = F4_FILIAL"
		clQry3	+=" AND SF4.D_E_L_E_T_ = ' '"
		clQry3	+=" AND F4_IGVOUT = '1'"
		 
		clQry3	+=" WHERE F3_ENTRADA BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"'"
		clQry3	+=" AND SF3.D_E_L_E_T_ = ' '"
		clQry3	+=" AND '"+xFilial('SF3')+"' = F3_FILIAL"
		clQry3	+=" AND F3_TIPOMOV = 'V'"
		clQry3	+=" AND F3_VALIMP1 > 0"
		clQry3	+=" AND F3_ESPECIE NOT IN ('NCC','NDI')"
		clQry3	+=" ORDER BY F3_ENTRADA,F3_NFISCAL "								
	 	TCQUERY clQry3 NEW ALIAS "QRY3"
	 	
	 	//Desc Concedidos e/ou Devolucoes de Vendas(Vendas Assumidas)
		clQry4	:="SELECT  DISTINCT F3_ENTRADA" 
		clQry4	+=" , F3_NFISCAL"
		If lSerie2
			clQry4 += " ,  F3_SERIE2 "
		EndIf
		clQry4	+=" ,  F3_SERIE "
		If lUsaNewKey
			clQry4	+=",  F3_SDOC "
		EndIF
		clQry4	+=" , D1_NFORI"
		clQry4	+=" , "+SerieNfId('SD1',3,'D1_SERIORI')+" D1_SERIORI "
		clQry4	+=" , F2_EMISSAO"	
		clQry4  +=" , A1_COD"
		clQry4  +=" , A1_LOJA" 
		clQry4  +=" , A1_NOME"
		clQry4	+=" , F3_VALCONT"
		clQry4	+=" , F3_BASIMP1"
		clQry4	+=" , F3_VALIMP1"
		clQry4	+=" FROM " + RetSqlName('SF3') + " SF3"
		
		clQry4	+=" JOIN " + RetSqlName('SD1') + " SD1"
		clQry4	+=" ON F3_NFISCAL = D1_DOC"
		clQry4	+=" AND F3_SERIE = D1_SERIE"
		clQry4	+=" AND F3_CLIEFOR = D1_FORNECE"
		clQry4	+=" AND F3_LOJA = D1_LOJA"				
		clQry4	+=" AND '"+xFilial('SD1')+"' = D1_FILIAL"
		clQry4	+=" AND SD1.D_E_L_E_T_ = ' '"
		
		clQry4	+=" JOIN " + RetSqlName('SF2') + " SF2"
		clQry4	+=" ON D1_NFORI = F2_DOC"
		clQry4	+=" AND D1_SERIORI = F2_SERIE"
	   	clQry4	+=" AND D1_FORNECE = F2_CLIENTE
 		clQry4	+=" AND D1_LOJA = F2_LOJA" 		
		clQry4	+=" AND '"+xFilial('SF2')+"' = F2_FILIAL"
		clQry4	+=" AND SF2.D_E_L_E_T_ = ' '"
		
		clQry4	+=" JOIN " + RetSqlName('SA1') + " SA1"
		clQry4	+=" ON F3_CLIEFOR = A1_COD"
		clQry4	+=" AND F3_LOJA = A1_LOJA"		
		clQry4	+=" AND '"+xFilial('SA1')+"' = A1_FILIAL"
		clQry4	+=" AND SA1.D_E_L_E_T_ = ' '"
		
		clQry4	+=" JOIN " + RetSqlName('SF4') + " SF4"
		clQry4	+=" ON F3_TES = F4_CODIGO"
		clQry4	+=" AND '"+xFilial('SF4')+"' = F4_FILIAL"
		clQry4	+=" AND SF4.D_E_L_E_T_ = ' '"
		clQry4	+=" AND F4_IGVOUT = '1'"
		 
		clQry4	+=" WHERE F3_ENTRADA BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"'"
		clQry4	+=" AND SF3.D_E_L_E_T_ = ' '"
		clQry4	+=" AND '"+xFilial('SF3')+"' = F3_FILIAL"
		clQry4	+=" AND F3_TIPOMOV = 'V'"
		clQry4	+=" AND F3_VALIMP1 > 0"
		clQry4	+=" AND F3_ESPECIE = 'NCC'"		
		clQry4	+=" ORDER BY F3_ENTRADA,F3_NFISCAL "				
		
	 	TCQUERY clQry4 NEW ALIAS "QRY4"
	 		 	
	 	//Vendas Lei 27037
		clQry5	:="SELECT  DISTINCT F3_ENTRADA" 
		clQry5	+=" , F3_NFISCAL"
		If lSerie2
			clQry5 += " , F3_SERIE2 "
		EndIf
		clQry5	+=" ,  F3_SERIE "
		If lUsaNewKey
			clQry5	+=",  F3_SDOC "
		EndIF
		clQry5	+=" , F2_TPDOC"
		clQry5  +=" , A1_COD"
		clQry5  +=" , A1_LOJA" 
		clQry5  +=" , A1_NOME"
		clQry5	+=" , F3_VALCONT"
		clQry5	+=" , F3_BASIMP1"
		clQry5	+=" FROM " + RetSqlName('SF3') + " SF3"
		
		clQry5 += " LEFT JOIN " + RetSqlName("SF2") + " SF2 "
		clQry5 += " ON F2_DOC = F3_NFISCAL "
		clQry5 += " AND F2_SERIE = F3_SERIE "
		clQry5 += " AND F2_ESPECIE = F3_ESPECIE "
		clQry5 += " AND F2_CLIENTE = F3_CLIEFOR "
		clQry5 += " AND F2_LOJA = F3_LOJA "			
		clQry5 += " AND F2_FILIAL = '" + XFILIAL("SF2") + "'	" 
		clQry5 += " AND SF2.D_E_L_E_T_ <> '*'"	
		
		clQry5	+=" JOIN " + RetSqlName('SA1') + " SA1"
		clQry5	+=" ON F3_CLIEFOR = A1_COD"
		clQry5	+=" AND F3_LOJA = A1_LOJA"		
		clQry5	+=" AND '"+xFilial('SA1')+"' = A1_FILIAL"
		clQry5	+=" AND SA1.D_E_L_E_T_ = ' '"
		
		clQry5	+=" JOIN " + RetSqlName('SF4') + " SF4"
		clQry5	+=" ON F3_TES = F4_CODIGO"
		clQry5	+=" AND '"+xFilial('SF4')+"' = F4_FILIAL"
		clQry5	+=" AND SF4.D_E_L_E_T_ = ' '"
		clQry5	+=" AND F4_IGVOUT = '2'"
		 
		clQry5	+=" WHERE F3_ENTRADA BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"'"
		clQry5	+=" AND SF3.D_E_L_E_T_ = ' '"
		clQry5	+=" AND '"+xFilial('SF3')+"' = F3_FILIAL"
		clQry5	+=" AND F3_TIPOMOV = 'V'"
		clQry5	+=" AND F3_VALIMP1 > 0"
		clQry5	+=" AND F3_ESPECIE NOT IN ('NCC','NDI') "  		
		clQry5	+=" ORDER BY F3_ENTRADA,F3_NFISCAL "								
	 	TCQUERY clQry5 NEW ALIAS "QRY5"

	 	//Desc Concedidos e/ou Devolucoes de Venda Lei 27037
		clQry6	:="SELECT  DISTINCT F3_ENTRADA" 
		clQry6	+=" , F3_NFISCAL"
		If lSerie2
			clQry6 += " , F3_SERIE2 "
		EndIf
		clQry6	+=" ,  F3_SERIE "
		If lUsaNewKey
			clQry6	+=",  F3_SDOC "
		EndIF
		clQry6	+=" , D1_NFORI"
		clQry6	+=" , "+SerieNfId('SD1',3,'D1_SERIORI')+" D1_SERIORI "
		clQry6	+=" , F2_EMISSAO"	
		clQry6  +=" , A1_COD"
		clQry6  +=" , A1_LOJA" 
		clQry6  +=" , A1_NOME"
		clQry6	+=" , F3_VALCONT"
		clQry6	+=" , F3_BASIMP1"
		clQry6	+=" FROM " + RetSqlName('SF3') + " SF3"
		
		clQry6	+=" JOIN " + RetSqlName('SD1') + " SD1"
		clQry6	+=" ON F3_NFISCAL = D1_DOC"
		clQry6	+=" AND F3_SERIE = D1_SERIE"
		clQry6	+=" AND F3_CLIEFOR = D1_FORNECE"
		clQry6	+=" AND F3_LOJA = D1_LOJA"		
		clQry6	+=" AND '"+xFilial('SD1')+"' = D1_FILIAL"
		clQry6	+=" AND SD1.D_E_L_E_T_ = ' '"
				
		clQry6	+=" JOIN " + RetSqlName('SF2') + " SF2"
		clQry6	+=" ON D1_NFORI = F2_DOC"
		clQry6	+=" AND D1_SERIORI = F2_SERIE"
	   	clQry6	+=" AND D1_FORNECE = F2_CLIENTE
 		clQry6	+=" AND D1_LOJA = F2_LOJA" 		
		clQry6	+=" AND '"+xFilial('SF2')+"' = F2_FILIAL"
		clQry6	+=" AND SF2.D_E_L_E_T_ = ' '"
		
		clQry6	+=" JOIN " + RetSqlName('SA1') + " SA1"
		clQry6	+=" ON F3_CLIEFOR = A1_COD"
		clQry6	+=" AND F3_LOJA = A1_LOJA"		
		clQry6	+=" AND '"+xFilial('SA1')+"' = A1_FILIAL"
		clQry6	+=" AND SA1.D_E_L_E_T_ = ' '"
		
		clQry6	+=" JOIN " + RetSqlName('SF4') + " SF4"
		clQry6	+=" ON F3_TES = F4_CODIGO"
		clQry6	+=" AND '"+xFilial('SF4')+"' = F4_FILIAL"
		clQry6	+=" AND SF4.D_E_L_E_T_ = ' '"
		clQry6	+=" AND F4_IGVOUT = '2'"
		 
		clQry6	+=" WHERE F3_ENTRADA BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"'"
		clQry6	+=" AND SF3.D_E_L_E_T_ = ' '"
		clQry6	+=" AND '"+xFilial('SF3')+"' = F3_FILIAL"
		clQry6	+=" AND F3_TIPOMOV = 'V'"
		clQry6	+=" AND F3_VALIMP1 > 0"
		clQry6	+=" AND F3_ESPECIE = 'NCC'"			
		clQry6	+=" ORDER BY F3_ENTRADA,F3_NFISCAL "							
	 	TCQUERY clQry6 NEW ALIAS "QRY6"

	 	//Vendas nao gravadas(sem considerar exportacoes)
		clQry7	:="SELECT  DISTINCT F3_ENTRADA" 
		clQry7	+=" , F3_NFISCAL"
		If lSerie2
			clQry7 += " , F3_SERIE2 "
		EndIf
		clQry7	+=" ,  F3_SERIE "
		If lUsaNewKey
			clQry7	+=",  F3_SDOC "
		EndIF
		clQry7	+=" , F2_TPDOC"
		clQry7  +=" , A1_COD"
		clQry7  +=" , A1_LOJA" 
		clQry7  +=" , A1_NOME"
		clQry7	+=" , F3_VALCONT"
		clQry7	+=" , F3_EXENTAS"
		clQry7	+=" FROM " + RetSqlName('SF3') + " SF3"
		
		clQry7 += " LEFT JOIN " + RetSqlName("SF2") + " SF2 "
		clQry7 += " ON F2_DOC = F3_NFISCAL "
		clQry7 += " AND F2_SERIE = F3_SERIE "
		clQry7 += " AND F2_ESPECIE = F3_ESPECIE "
		clQry7 += " AND F2_CLIENTE = F3_CLIEFOR "
		clQry7 += " AND F2_LOJA = F3_LOJA "			
		clQry7 += " AND F2_FILIAL = '" + XFILIAL("SF2") + "'	" 
		clQry7 += " AND SF2.D_E_L_E_T_ <> '*'"	
		
		clQry7	+=" JOIN " + RetSqlName('SA1') + " SA1"
		clQry7	+=" ON F3_CLIEFOR = A1_COD"
		clQry7	+=" AND F3_LOJA = A1_LOJA"
		clQry7	+=" AND '"+xFilial('SA1')+"' = A1_FILIAL"
		clQry7	+=" AND SA1.D_E_L_E_T_ = ' '"		
		
		clQry7	+=" WHERE F3_ENTRADA BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"'"
		clQry7	+=" AND SF3.D_E_L_E_T_ = ' '"
		clQry7	+=" AND '"+xFilial('SF3')+"' = F3_FILIAL"
		clQry7	+=" AND F3_TIPOMOV = 'V'"
		clQry7	+=" AND F3_ESPECIE NOT IN ('NCC','NDI')"
		clQry7	+=" AND F3_EXENTAS <> 0"		
		clQry7	+=" ORDER BY F3_ENTRADA,F3_NFISCAL "						
	 	TCQUERY clQry7 NEW ALIAS "QRY7"

	 	//Destinadas a vendas - Nacionais e Importadas
	 	clQry8	:="SELECT  F3_ENTRADA"
		clQry8	+=" , F3_EMISSAO"
		clQry8	+=" , F3_NFISCAL" 
		If lSerie2
			clQry8 += " , F3_SERIE2 "
		EndIf
		clQry8	+=" ,  F3_SERIE "
		If lUsaNewKey
			clQry8	+=",  F3_SDOC "
		EndIF
		clQry8	+=" , F3_ESPECIE"
		clQry8  +=" , A2_COD"
		clQry8  +=" , A2_LOJA" 
		clQry8  +=" , A2_NOME"
		clQry8  +=" , F2_TPDOC"
		clQry8  +=" , F1_TPDOC"
		clQry8	+=" , CASE WHEN A2_TIPO = 'X' THEN 'I' ELSE 'N' END AS TIPO"
		clQry8	+="	, CASE WHEN F3_ESPECIE     IN ('NCP','NDI') THEN SUM(-1*F3_VALCONT) ELSE SUM(F3_VALCONT) END AS F3_VALCONT "
		clQry8	+="	, CASE WHEN F3_ESPECIE     IN ('NCP','NDI') THEN SUM(-1*F3_BASIMP1) ELSE SUM(F3_BASIMP1) END AS F3_BASIMP1 "
		clQry8	+="	, CASE WHEN F3_ESPECIE 	   IN ('NCP','NDI') THEN SUM(-1*(F3_VALCONT-F3_BASIMP1-F3_VALIMP1)) "
		clQry8	+="	 	   WHEN F3_ESPECIE NOT IN ('NCP','NDI') THEN SUM(F3_VALCONT-F3_BASIMP1-F3_VALIMP1) "
		clQry8	+="	 	   ELSE 0 END AS F3_EXENTAS "
		clQry8	+=" FROM " + RetSqlName('SF3') +" SF3"
					
		clQry8 += " LEFT JOIN " + RetSqlName("SF1") + " SF1 "
		clQry8 += " ON F1_DOC = F3_NFISCAL "
		clQry8 += " AND F1_SERIE = F3_SERIE "
		clQry8 += " AND F1_ESPECIE = F3_ESPECIE "
		clQry8 += " AND F1_FORNECE = F3_CLIEFOR "
		clQry8 += " AND F1_LOJA = F3_LOJA "			
		clQry8 += " AND F1_FILIAL = '" + XFILIAL("SF1") + "'	" 
		clQry8 += " AND SF1.D_E_L_E_T_ <> '*'"	

		clQry8 += " LEFT JOIN " + RetSqlName("SF2") + " SF2 "
		clQry8 += " ON F2_DOC = F3_NFISCAL "
		clQry8 += " AND F2_SERIE = F3_SERIE "
		clQry8 += " AND F2_ESPECIE = F3_ESPECIE "
		clQry8 += " AND F2_CLIENTE = F3_CLIEFOR "
		clQry8 += " AND F2_LOJA = F3_LOJA "			
		clQry8 += " AND F2_FILIAL = '" + XFILIAL("SF2") + "'	" 
		clQry8 += " AND SF2.D_E_L_E_T_ <> '*'"	
		
		clQry8	+=" JOIN " + RetSqlName('SA2') + " SA2" 
		clQry8	+=" ON F3_CLIEFOR = A2_COD"
		clQry8	+=" AND F3_LOJA	= A2_LOJA"
		clQry8	+=" AND '"+xFilial('SA2')+"' = A2_FILIAL"
		clQry8	+=" AND SA2.D_E_L_E_T_ = ' '"
		// o Where deve ser o mesmo da cQryTot
		clQry8	+=" WHERE F3_ENTRADA BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"'"
		
		clQry8  +=" AND F3_TIPOMOV = 'C' "
		clQry8	+=" AND SF3.D_E_L_E_T_ = ' '" 
		clQry8	+=" AND '"+xFilial('SF3')+"' = F3_FILIAL"  
		clQry8	+=" GROUP BY F3_ENTRADA"
		clQry8	+=" , F3_EMISSAO"
		clQry8	+=" , F3_NFISCAL" 
		clQry8	+=" , F3_SERIE"
		If lUsaNewKey
			clQry8	+=",  F3_SDOC "
		EndIF
		If lSerie2
			clQry8 += " , F3_SERIE2"
		EndIf
		clQry8	+=" , F3_ESPECIE"
		clQry8  +=" , A2_COD"
		clQry8  +=" , A2_TIPO"
		clQry8  +=" , A2_LOJA" 
		clQry8  +=" , A2_NOME"
		clQry8  +=" , F2_TPDOC"
		clQry8  +=" , F1_TPDOC"
		clQry8	+=" ORDER BY F3_EMISSAO,F3_NFISCAL "	   
									
	 	TCQUERY clQry8 NEW ALIAS "QRY8"

	 	//Percepcao de IGV
		clQry9	:="SELECT  DISTINCT A2_CGC"
		clQry9	+=" , F1_TPDOC"
		If lSerie2
			clQry9 += " , F1_SERIE2 "
		EndIf
		clQry9	+=" , FE_SERIE"
		If lUsaNewKey
			clQry9	+=",  FE_SDOC "
		EndIF
		clQry9	+=" , FE_NFISCAL"
		clQry9	+=" , FE_EMISSAO"
		clQry9	+=" , FE_VALIMP"
		clQry9	+=" , F1_SERIE "
		If lUsaNewKey
			clQry9	+=",  F1_SDOC "
		EndIF
		clQry9	+=" , F1_DOC"
		clQry9	+=" , F1_EMISSAO"
		clQry9	+=" , F1_VALBRUT"
		clQry9	+=" , F1_MOEDA"
		clQry9	+=" , F1_TXMOEDA"		
		clQry9	+=" FROM " + RetSqlName('SFE') + " SFE"
		
		clQry9	+=" JOIN " + RetSqlName('SF1') + " SF1"
		clQry9	+=" ON FE_NFISCAL = F1_DOC"
		clQry9	+=" AND FE_SERIE = F1_SERIE"
		clQry9	+=" AND FE_FORNECE = F1_FORNECE"
		clQry9	+=" AND FE_LOJA = F1_LOJA"
		clQry9	+=" AND '"+xFilial('SF1')+"' = F1_FILIAL"
		clQry9	+=" AND SF1.D_E_L_E_T_ = ' '"
				
		clQry9	+=" JOIN " + RetSqlName('SA2') + " SA2"
		clQry9	+=" ON FE_FORNECE = A2_COD"
		clQry9	+=" AND FE_LOJA = A2_LOJA"
		clQry9	+=" AND '"+xFilial('SA2')+"' = A2_FILIAL"
		clQry9	+=" AND SA2.D_E_L_E_T_ = ' '"
		
		clQry9	+=" WHERE FE_TIPO = 'P'"  
		clQry9	+=" AND FE_EMISSAO BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"'"
		clQry9	+=" AND SFE.D_E_L_E_T_ = ' '"
		clQry9	+=" AND '"+xFilial('SFE')+"' = FE_FILIAL"
		clQry9	+=" ORDER BY A2_CGC"        
		
	 	TCQUERY clQry9 NEW ALIAS "QRY9"

		//Retencao de IGV
		clQry10 :="SELECT  DISTINCT A2_CGC"
		clQry10	+=" , F1_TPDOC"
		If lSerie2
			clQry10 += " , F1_SERIE2 "
		EndIf
		clQry10	+=" , FE_SERIE "
		If lUsaNewKey
			clQry10	+=",  FE_SDOC "
		EndIF
		clQry10	+=" , FE_NFISCAL"
		clQry10	+=" , FE_EMISSAO"
		clQry10	+=" , FE_RETENC"
		clQry10	+=" , F1_SERIE "
		If lUsaNewKey
			clQry10	+=",  F1_SDOC "
		EndIF
		clQry10	+=" , F1_DOC"
		clQry10	+=" , F1_EMISSAO"
		clQry10	+=" , F1_VALBRUT"
		clQry10 +=" , F1_MOEDA"
		clQry10	+=" , F1_TXMOEDA"		
		clQry10	+=" FROM " + RetSqlName('SFE') + " SFE"
		
		clQry10	+=" JOIN " + RetSqlName('SF1') + " SF1"
		clQry10	+=" ON FE_NFISCAL = F1_DOC"
		clQry10	+=" AND FE_SERIE = F1_SERIE"
		clQry10	+=" AND FE_FORNECE = F1_FORNECE"
		clQry10	+=" AND FE_LOJA = F1_LOJA"
		clQry10	+=" AND '"+xFilial('SF1')+"' = F1_FILIAL"
		clQry10	+=" AND SF1.D_E_L_E_T_ = ' '"
				
		clQry10	+=" JOIN " + RetSqlName('SA2') + " SA2"
		clQry10	+=" ON FE_FORNECE = A2_COD"
		clQry10	+=" AND FE_LOJA = A2_LOJA"
		clQry10	+=" AND '"+xFilial('SA2')+"' = A2_FILIAL"
		clQry10	+=" AND SA2.D_E_L_E_T_ = ' '"
		
		clQry10	+=" WHERE FE_TIPO = 'I'"  
		clQry10	+=" AND FE_EMISSAO BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"'"
		clQry10	+=" AND SFE.D_E_L_E_T_ = ' '"
		clQry10	+=" AND '"+xFilial('SFE')+"' = FE_FILIAL"
		clQry10	+=" ORDER BY A2_CGC"
	 	TCQUERY clQry10 NEW ALIAS "QRY10"
		 		 			
		TcSetField("QRY1" ,"F3_ENTRADA","D",08,0)	
		TcSetField("QRY2" ,"F3_ENTRADA","D",08,0)
		TcSetField("QRY2" ,"F2_EMISSAO","D",08,0)
		TcSetField("QRY3" ,"F3_ENTRADA","D",08,0)
		TcSetField("QRY4" ,"F3_ENTRADA","D",08,0)
		TcSetField("QRY4" ,"F2_EMISSAO","D",08,0)
		TcSetField("QRY5" ,"F3_ENTRADA","D",08,0)				 	
		TcSetField("QRY6" ,"F3_ENTRADA","D",08,0)
		TcSetField("QRY6" ,"F2_EMISSAO","D",08,0)		
		TcSetField("QRY7" ,"F3_ENTRADA","D",08,0)
		TcSetField("QRY8" ,"F1_DTDIGIT","D",08,0)		
		TcSetField("QRY8" ,"F1_EMISSAO","D",08,0)
		TcSetField("QRY9" ,"FE_EMISSAO","D",08,0)
		TcSetField("QRY9" ,"F1_EMISSAO","D",08,0)
		TcSetField("QRY10","FE_EMISSAO","D",08,0)
		TcSetField("QRY10","F1_EMISSAO","D",08,0)		
         
		If mv_par01 == 1
			olReport:PrintText(SubStr(STR0001,At("PDT",STR0001) - 1,Len(STR0001)),,)		
		ElseIf mv_par01 == 2
			olReport:PrintText(SubStr(STR0011,At("PDT",STR0011) - 1,Len(STR0011)),,)		
		EndIf
		
		If QRY1->(!EoF())
			olReport:PrintText(STR0058,,)
			olSec1:Print()
			olReport:SkipLine()
		Endif
		if QRY2->(!EoF())
			olReport:PrintText(STR0059,,)
			olSec2:Print()
			DbSelectArea("QRY2")
			QRY2->(DbGoTop())
			Do While QRY2->(!EoF())
				if QRY2->F2_EMISSAO >= mv_par02 .and. QRY2->F2_EMISSAO <= mv_par03
					nlTotPer	+= QRY2->F3_VALCONT	
				Elseif QRY2->F2_EMISSAO < mv_par02
					nlTotPerA	+= QRY2->F3_VALCONT			
				Endif
				QRY2->(DbSkip())
			EndDo
			nlTotDev	+=	nlTotPer + nlTotPerA
			olReport:PrintText(STR0019 + Alltrim(Transform(nlTotPer ,PesqPict("SF3","F3_VALCONT"))), ,)	 
			olReport:PrintText(STR0020 + Alltrim(Transform(nlTotPerA,PesqPict("SF3","F3_VALCONT"))), ,)	
			olReport:PrintText(STR0021 + Alltrim(Transform(nlTotDev ,PesqPict("SF3","F3_VALCONT"))), ,)
			olReport:SkipLine()
			nlTotPer 	:= 0
			nlTotPerA 	:= 0
			nlTotDev   	:= 0
        Endif
        if QRY3->(!EoF())
        	olReport:PrintText(STR0060,,)
			olSec3:Print()
			DbSelectArea("QRY3")
			QRY3->(DbGoTop())
			Do While QRY3->(!EoF())
				nlTotBas	+= QRY3->F3_BASIMP1
				nlTotImp	+= QRY3->F3_VALIMP1
				QRY3->(DbSkip())
			EndDo
			nlLin	:= olReport:Row()
			olReport:PrintText(STR0010 , ,)	 
			olReport:PrintText(Transform(nlTotBas,PesqPict("SF3","F3_BASIMP1")),nlLin ,1705)	
			olReport:PrintText(Transform(nlTotImp,PesqPict("SF3","F3_VALIMP1")),nlLin ,1995)
			olReport:SkipLine()
			nlTotBas	:= 0
			nlTotImp	:= 0			
		Endif
		if QRY4->(!EoF())
			olReport:PrintText(STR0061,,)
			olSec4:Print()
			dbSelectArea("QRY4")
			QRY4->(DbGoTop())
			Do While QRY4->(!EoF())
				if QRY4->F2_EMISSAO >= mv_par02 .and. QRY4->F2_EMISSAO <= mv_par03
					nlTotPer	+= QRY4->F3_VALCONT	
				Elseif QRY4->F2_EMISSAO < mv_par02
					nlTotPerA	+= QRY4->F3_VALCONT			
				Endif
				QRY4->(DbSkip())
			EndDo
			nlTotDev	+=	nlTotPer + nlTotPerA 		
			olReport:PrintText(STR0019 + Alltrim(Transform(nlTotPer ,PesqPict("SF3","F3_VALCONT"))), ,)	 
			olReport:PrintText(STR0020 + Alltrim(Transform(nlTotPerA,PesqPict("SF3","F3_VALCONT"))), ,)	
			olReport:PrintText(STR0021 + Alltrim(Transform(nlTotDev ,PesqPict("SF3","F3_VALCONT"))), ,)
			olReport:SkipLine()
			nlTotPer 	:= 0
			nlTotPerA 	:= 0
			nlTotDev   	:= 0
		Endif
		if QRY5->(!EoF())
			olReport:PrintText(STR0062,,)
			olSec5:Print()			
			olReport:SkipLine()
		Endif		
		if QRY6->(!EoF())
			olReport:PrintText(STR0063,,)
			olSec6:Print()
			dbSelectArea("QRY6")
			QRY6->(DbGoTop())
			Do While QRY6->(!EoF())
				if QRY6->F2_EMISSAO >= mv_par02 .and. QRY6->F2_EMISSAO <= mv_par03
					nlTotPer	+= QRY6->F3_VALCONT	
				Elseif QRY6->F2_EMISSAO < mv_par02
					nlTotPerA	+= QRY6->F3_VALCONT			
				Endif
				QRY6->(DbSkip())
			EndDo
			nlTotDev	+=	nlTotPer + nlTotPerA
				
			olReport:PrintText(STR0019 + Alltrim(Transform(nlTotPer ,PesqPict("SF3","F3_VALCONT"))), ,)	 
			olReport:PrintText(STR0020 + Alltrim(Transform(nlTotPerA,PesqPict("SF3","F3_VALCONT"))), ,)	
			olReport:PrintText(STR0021 + Alltrim(Transform(nlTotDev ,PesqPict("SF3","F3_VALCONT"))), ,)
			olReport:SkipLine()
			nlTotPer 	:= 0
			nlTotPerA 	:= 0
			nlTotDev   	:= 0
	    Endif
	    if QRY7->(!EoF())
	    	olReport:PrintText(STR0064,,)
			olSec7:Print()
			olReport:SkipLine()	
		Endif
		if QRY8->(!Eof())
			olReport:PrintText(STR0065,,)
			olSec8:Print()

		 	cQryTot	:="SELECT  "
			cQryTot	+="	CASE WHEN F3_ESPECIE IN ('NCP','NDI') THEN SUM(-1*F3_VALCONT) ELSE SUM(F3_VALCONT) END AS F3_VALCONT "
			cQryTot	+="	, CASE WHEN F3_ESPECIE IN ('NCP','NDI') THEN SUM(-1*F3_BASIMP1) ELSE SUM(F3_BASIMP1) END AS F3_BASIMP1 "
			cQryTot	+="	, CASE WHEN F3_ESPECIE 	   IN ('NCP','NDI') THEN SUM(-1*(F3_VALCONT-F3_BASIMP1-F3_VALIMP1)) "
			cQryTot	+="	 	   WHEN F3_ESPECIE NOT IN ('NCP','NDI') THEN SUM(F3_VALCONT-F3_BASIMP1-F3_VALIMP1) "
			cQryTot	+="	 	   ELSE 0 END AS F3_EXENTAS "
			cQryTot	+=" , CASE WHEN A2_TIPO = 'X' THEN 'I' ELSE 'N' END AS TIPO"
			cQryTot	+="	, F3_ALQIMP1"
			cQryTot	+=" FROM "+RetSqlName("SF3") + " SF3 "
			
			cQryTot	+=" JOIN " + RetSqlName('SA2') + " SA2" 
			cQryTot	+=" ON F3_CLIEFOR = A2_COD"
			cQryTot	+=" AND F3_LOJA	= A2_LOJA"
			cQryTot	+=" AND '"+xFilial('SA2')+"' = A2_FILIAL"
			cQryTot	+=" AND SA2.D_E_L_E_T_ = ' '"
			// o Where deve ser o mesmo da clQry8		
			cQryTot	+=" WHERE F3_ENTRADA BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"'"
			cQryTot +=" AND F3_TIPOMOV = 'C' "
			cQryTot	+=" AND SF3.D_E_L_E_T_ = ' '" 
			cQryTot	+=" AND '"+xFilial('SF3')+"' = F3_FILIAL"  
			cQryTot	+=" GROUP BY F3_ALQIMP1, A2_TIPO, F3_ESPECIE"

		 	TCQUERY cQryTot NEW ALIAS "QRYTOT"
	
			DbSelectArea("QRYTOT")
			QRYTOT->(DbGoTop())
			Do While QRYTOT->(!EoF())
				If 	QRYTOT->F3_ALQIMP1 > 0
					nlCont	:= aScan(alTotAlq,{|aX| aX[1] == QRYTOT->TIPO .and. aX[2] == QRYTOT->F3_ALQIMP1 })
					if nlCont == 0
						aAdd(alTotAlq,{QRYTOT->TIPO,QRYTOT->F3_ALQIMP1,QRYTOT->F3_BASIMP1})
					Else
						alTotAlq[nlCont,3]	+= QRYTOT->F3_BASIMP1
					Endif
				EndIf
				If QRYTOT->TIPO == "N"
					alTotNI[1,1] += QRYTOT->F3_VALCONT	  
					alTotNI[1,2] += QRYTOT->F3_EXENTAS
				Else
					alTotNI[2,1] += QRYTOT->F3_VALCONT	  
					alTotNI[2,2] += QRYTOT->F3_EXENTAS
				EndIf	
				QRYTOT->(DbSkip())		
			EndDo     
			DbSelectArea("QRYTOT")
			DbCloseArea()
			olReport:PrintText(STR0028, ,)
			//Nacional																    	 
			olReport:PrintText(STR0029 + Alltrim(Transform(alTotNI[1,1],PesqPict("SF3","F3_VALCONT"))), ,)
			For nlI	:= 1 to Len(alTotAlq)
				if alTotAlq[nlI,1] == "N"													
					olReport:PrintText(STR0030 +" "+ Alltrim(Str(alTotAlq[nlI,2]))+"% : "+ Alltrim(Transform(alTotAlq[nlI,3],PesqPict("SF3","F3_BASIMP1"))), ,)
				Endif
			Next nlI	
			olReport:PrintText(STR0031 + Alltrim(Transform(alTotNI[1,2],PesqPict("SF3","F3_EXENTAS"))), ,)
			
			//Importada
			olReport:PrintText(STR0032 + Alltrim(Transform(alTotNI[2,1],PesqPict("SF3","F3_VALCONT"))), ,)
			For nlI	:= 1 to Len(alTotAlq)
				if alTotAlq[nlI,1] == "I"													
					olReport:PrintText(STR0030 +" "+ Alltrim(Str(alTotAlq[nlI,2]))+"% : "+ Alltrim(Transform(alTotAlq[nlI,3],PesqPict("SF3","F3_BASIMP1"))), ,)
				Endif
			Next nlI		
			olReport:PrintText(STR0031 + Alltrim(Transform(alTotNI[2,2],PesqPict("SF3","F3_EXENTAS"))), ,)						
			olReport:SkipLine()		
		Endif

		if QRY9->(!EoF())
			olReport:PrintText(STR0066,,)
			olSec9:Print()
			olReport:SkipLine()
			GeraTxt("P","QRY9")			
		Endif
		if QRY10->(!EoF())
			olReport:PrintText(STR0067,,)
			olSec10:Print()
			GeraTxt("R","QRY10")
		Endif
		
		For nlI	:= 1 to 10
			&("QRY"+Alltrim(Str(nlI))+"->(dbCloseArea())")
		Next nlI
		
		Do Case
			//Caso tenha ambos
			Case !Empty(apTxt[1,2]) .and. !Empty(apTxt[2,2])
				clTxt	:= STR0044+STR0047+STR0048+STR0050
                clTxt	+= apTxt[2,2]                
				clTxt	+= STR0051
				clTxt	+= apTxt[1,2]
				clTxt	+= STR0052+STR0053+Alltrim(mv_par04)+STR0054
				Aviso(STR0043,clTxt,{"OK"})
			//Caso tenha apenas percepcao
			Case !Empty(apTxt[1,2]) .and. Empty(apTxt[2,2])
				clTxt	:= STR0044+STR0046+STR0048+STR0049
				clTxt	+= apTxt[1,2]
				clTxt	+= STR0053+Alltrim(mv_par04)+STR0054
			    Aviso(STR0043,clTxt,{"OK"})
			//Caso tenha apenas retencao
			Case !Empty(apTxt[2,2]) .and. Empty(apTxt[1,2])
				clTxt	:= STR0044+STR0045+STR0048+STR0049
                clTxt	+= apTxt[2,2]
				clTxt	+= STR0053+Alltrim(mv_par04)+STR0054
			    Aviso(STR0043,clTxt,{"OK"})
		EndCase
			
	Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GeraTxt ¦ Autor ¦ Rafael de Paula Goncalves¦ Data ¦ 23.11.09	   		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³clTipo = tipo do arquivo a ser gerado percepcao ou retencao.			³±±			  												³±±
±±³			 ³clAlias = o alias da query que ira buscar as informacoes.				³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Descricao ³Gera o arquivo de acordo com o "0621"+CGC da empresa+Ano+Mes+clTipo,	³±±
±±³			 ³ira gerar com informacoes da Query de percepcao ou retencao			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Chamado na funcao PrintReport									   		³±±
±±³          ³								                                   		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GeraTxt(clTipo,clAlias)

	Local nlHandle	:= 0
	Local clDir		:= ""
	Local clMsg		:= ""
	Local clRUC		:= ""
	Local nlTipo	:= 0
	Local clArq		:= ""
	
	clArq		:= "0621"+Alltrim(SM0->M0_CGC)+Alltrim(Str(Year(date())))+Alltrim(Str(Month(date())))+clTipo+".txt"
	clDir		:= Alltrim(mv_par04)+clArq
	nlHandle	:= FCREATE(clDir)

    if nlHandle == -1
		MsgStop(STR0073) //"Erro ao criar o arquivo. Verifique o diretório."
	Else                                              
		nlTipo	:= aScan(apTxt,{|aX| aX[1] == clTipo}) // Alimenta o array com os nomes dos arquivos gerado,
		apTxt[nlTipo,2]		:= clArq                    // de acordo com o tipo percepcao ou retencao        
		ft_FUse(clDir) 
		DbSelectArea(clAlias)
		&(clAlias+"->(DbGoTop())")                                 
		Do While &(clAlias+"->(!EoF())")
			clMsg	+= Alltrim(&(clAlias+"->A2_CGC"))+"|"   									// RUC do fornecedor
			clMsg	+= Alltrim(&(clAlias+"->FE_SERIE"))+"|"  									// Serie do Comprovante
			clMsg	+= SubStr(Alltrim(&(clAlias+"->FE_NFISCAL")),6,8)+"|"						// Numero do Comprovante
			clMsg	+= SubStr(DtoS(&(clAlias+"->FE_EMISSAO")),7,2)+"/"				   			// Emissao do Comprovante(Dia)
			clMsg	+= SubStr(DtoS(&(clAlias+"->FE_EMISSAO")),5,2)+"/"					   		// Emissao do Comprovante(Mes)
			clMsg	+= SubStr(DtoS(&(clAlias+"->FE_EMISSAO")),1,4)+"|"							// Emissao do Comprovante(Ano)
			if clTipo	== "P"				
				clMsg	+= Alltrim(Transform(&(clAlias+"->FE_VALIMP"),"999999999.99"))+"|"		// Valor da percepcao
		    Else
				clMsg	+= Alltrim(Transform(&(clAlias+"->FE_RETENC"),"999999999.99"))+"|" 	// Valor da retencao
			Endif		    	
		    clMsg	+= Alltrim(&(clAlias+"->F1_TPDOC"))+"|"   								// Tipo do Comprovante         ///ALTERAR
		    clMsg	+= Alltrim(&(clAlias+"->F1_SERIE"))+"|"     								// Serie da Fatura
		    clMsg	+= SubStr(Alltrim(&(clAlias+"->F1_DOC")),6,8)+"|"       					// Numero da Fatura	
		    clMsg	+= SubStr(DtoS(&(clAlias+"->F1_EMISSAO")),7,2)+"/"							// Emissao da Fatura(Dia)
		    clMsg	+= SubStr(DtoS(&(clAlias+"->F1_EMISSAO")),5,2)+"/"							// Emissao da Fatura(Mes)
		    clMsg	+= SubStr(DtoS(&(clAlias+"->F1_EMISSAO")),1,4)+"|"							// Emissao da Fatura(Ano)
		    clMsg	+= Alltrim(Transform(&(clAlias+"->F1_VALBRUT"),"999999999.99"))+"|"		// Valor da fatura
		    clMsg	+= chr(13)+chr(10)															// Quebra Linha
		    &(clAlias+"->(DbSkip())")
		EndDo
		FWrite(nlHandle,clMsg)
		FClose(nlHandle)
	Endif

				
		
	
Return
