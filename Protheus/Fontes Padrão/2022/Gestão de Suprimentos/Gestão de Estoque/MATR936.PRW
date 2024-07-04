#INCLUDE "MATR936.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Matr936   ³ Autor ³ Andressa Fagundes     ³ Data ³30/05/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controle semestral de estoque de agrotoxico.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Matr936()
Local oReport

	oReport	:= ReportDef()
	oReport:PrintDialog() 

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Andressa Fagundes      ³ Data ³30/05/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport
Local oCabec
Local oEntSaid
Local oProdDesc
Local cMvEstado := SuperGetMv("MV_ESTADO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Componente de impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte("MTR936",.F.)

If cMvEstado=="ES"  // Se for Espirito Santo 
	oReport := TReport():New("MATR936",STR0084,"MTR936", {|oReport| ReportPrint(oReport)},STR0085)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 1 - Cabecalho Padrao    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oCabec	:= TRSection():New(oReport,"Dados da Empresa/Filial",{"SM0"},{"Código do Produto"},/*Campos do SX3*/,/*Campos do SIX*/)
	oCabec:SetPageBreak()
	TRCell():New(oCabec,"MV_PAR07"	,"SM0"	,STR0060 ,/*Picture*/,10	,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"MV_PAR08"	,"SM0"	,STR0086 ,/*Picture*/,10	,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"M0_NOMECOM","SM0"	,STR0062 ,/*Picture*/,25 	,/*lPixel*/,/*{|| }*/)
	TRCell():New(oCabec,"M0_ENDENT"	,"SM0"	,STR0063 ,/*Picture*/,25	,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"M0_CIDENT"	,"SM0"	,STR0064 ,/*Picture*/,20	,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"M0_ESTENT"	,"SM0"	,STR0065 ,/*Picture*/,02 	,/*lPixel*/,/*{||   }*/)
	TRCell():New(oCabec,"MV_PAR09"	,"SM0"	,STR0066 ,/*Picture*/,14	,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"MV_PAR01"	,"SM0"	,STR0067 ,/*Picture*/,24	,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"TRB_DESCL"	,"" 	,STR0072 ,/*Picture*/,15  	,/*lPixel*/,/*{||  }*/)  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 2 - Entradas e Saidas   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oEntSaid	:= TRSection():New(oReport,"Movimentacao dos Produtos",{"TRB"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	TRCell():New(oEntSaid,"TRB_CLTOX"	,"TRB"	,STR0072 ,/*Picture*/,,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_DESCPR"	,"TRB"	,STR0069 ,/*Picture*/,20,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_PRIATV"	,"TRB"	,STR0070 ,/*Picture*/,25,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_SLDANT"	,"TRB"	,STR0073 ,"@E 9,999,999.99",,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_ENTRAD"	,"TRB"	,STR0074 ,"@E 9,999,999.99",,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_SAIDA"	,"TRB"	,STR0075 ,"@E 9,999,999.99",,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_SLDATU"	,"TRB"	,STR0076 ,"@E 9,999,999.99",,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_COMER"	,"TRB"	,STR0081 ,"@E 9,999,999.99",,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_USUAR"	,"TRB"	,STR0082 ,"@E 9,999,999.99",,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_DEVOL"	,"TRB"	,STR0083 ,"@E 9,999,999.99",,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_EMBUM"	,"TRB"	,STR0077 ,/*Picture*/,,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_EMBTP"	,"TRB"	,STR0078 ,/*Picture*/,,/*lPixel*/,/*{||  }*/)
	
ElseIf cMvEstado=="SC"  .Or. !cMvEstado$("ES|MG|RS") // Se for Santa Catarina ou Diferente de ES|MG|RS
	oReport := TReport():New("MATR936",STR0001, "MTR936", {|oReport| ReportPrint(oReport)},IIF(cMvEstado=="SC",STR0002,STR0128))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 1 - Cabecalho Padrao    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oCabec	:= TRSection():New(oReport,"Dados da Empresa/Filial",{"SM0"},{"Código do Produto"},/*Campos do SX3*/,/*Campos do SIX*/)
	TRCell():New(oCabec,"MV_PAR07"	,"SM0",STR0060 ,/*Picture*/,10	,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"MV_PAR08"	,"SM0",STR0061 ,/*Picture*/,10	,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"M0_NOMECOM","SM0",STR0062 ,/*Picture*/,25  ,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"M0_ENDENT"	,"SM0",STR0063 ,/*Picture*/,25	,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"M0_CIDENT"	,"SM0",STR0064 ,/*Picture*/,20	,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"M0_ESTENT"	,"SM0",STR0065 ,/*Picture*/,02  ,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"MV_PAR09"	,"SM0",STR0066 ,/*Picture*/,14	,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"MV_PAR01"	,"SM0",STR0067 ,/*Picture*/,24	,/*lPixel*/,/*{||  }*/)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 2 - Entradas e Saidas   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oEntSaid	:= TRSection():New(oReport,"Movimentacao dos Produtos",{"TRB"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	TRCell():New(oEntSaid,"TRB_TPPROD"	,"TRB"	,STR0068 ,/*Picture*/,,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_DESCPR"	,"TRB"	,STR0069 ,/*Picture*/,20,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_PRIATV"	,"TRB"	,STR0070 ,/*Picture*/,25,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_PPATV"	,"TRB"	,STR0071 ,"@E 999.99",,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_CLTOX"	,"TRB"	,STR0072 ,/*Picture*/,,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_SLDANT"	,"TRB"	,STR0073 ,"@E 9,999,999.99",,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_ENTRAD"	,"TRB"	,STR0074 ,"@E 9,999,999.99",,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_SAIDA"	,"TRB"	,STR0075 ,"@E 9,999,999.99",,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_SLDATU"	,"TRB"	,STR0076 ,"@E 9,999,999.99",,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_EMBUM"	,"TRB"	,STR0077 ,/*Picture*/,,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_EMBTP"	,"TRB"	,STR0078 ,/*Picture*/,,/*lPixel*/,/*{||  }*/)
	
ElseIf cMvEstado=="MG"  // Se for Minas Gerais
	oReport := TReport():New("MATR936",STR0001,"MTR936", {|oReport| ReportPrint(oReport)},STR0110)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 1 - Cabecalho Padrao    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oCabec	:= TRSection():New(oReport,"Dados da Empresa/Filial",{"SM0"},{"Código do Produto"},/*Campos do SX3*/,/*Campos do SIX*/)
	TRCell():New(oCabec,"MV_PAR07"	,"SM0"	,STR0060 ,/*Picture*/,10	,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"MV_PAR08"	,"SM0"	,STR0112 ,/*Picture*/,10	,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"M0_NOMECOM","SM0"	,STR0062 ,/*Picture*/,25 ,/*lPixel*/,/*{|| }*/)
	TRCell():New(oCabec,"M0_ENDENT"	,"SM0"	,STR0063 ,/*Picture*/,25	,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"M0_CIDENT"	,"SM0"	,STR0064 ,/*Picture*/,20	,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"M0_ESTENT"	,"SM0"	,STR0065 ,/*Picture*/,02 ,/*lPixel*/,/*{||   }*/)
	TRCell():New(oCabec,"MV_PAR09"	,"SM0"	,STR0066 ,/*Picture*/,14	,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"MV_PAR01"	,"SM0"	,STR0067 ,/*Picture*/,24	,/*lPixel*/,/*{||  }*/)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 2 - Entradas e Saidas   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oEntSaid	:= TRSection():New(oReport,"Movimentacao dos Produtos",{"TRB"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	TRCell():New(oEntSaid,"TRB_TPPROD"	,"TRB"	,STR0068 ,/*Picture*/,,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_DESCPR"	,"TRB"	,STR0069 ,/*Picture*/,20,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_PRIATV"	,"TRB"	,STR0070 ,/*Picture*/,25,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_PPATV"	,"TRB"	,STR0071,"@E 999.99",,/*lPixel*/,/*{||  }*/,"right",,"right")
	TRCell():New(oEntSaid,"TRB_CLTOX"	,"TRB"	,STR0072 ,/*Picture*/,,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_SLDANT"	,"TRB"	,STR0073 ,"@E 9,999,999.99",,/*lPixel*/,/*{||  }*/,"right",,"")
	TRCell():New(oEntSaid,"TRB_ENTRAD"	,"TRB"	,STR0074 ,"@E 9,999,999.99",,/*lPixel*/,/*{||  }*/,"right",,"")
	TRCell():New(oEntSaid,"TRB_SAIDA"	,"TRB"	,STR0075 ,"@E 9,999,999.99",,/*lPixel*/,/*{||  }*/,"right",,"")
	TRCell():New(oEntSaid,"TRB_SLDATU"	,"TRB"	,STR0076 ,"@E 9,999,999.99",,/*lPixel*/,/*{||  }*/,"right",,"")
	TRCell():New(oEntSaid,"TRB_EMBUM"	,"TRB"	,STR0077 ,/*Picture*/,,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_EMBTP"	,"TRB"	,STR0078 ,/*Picture*/,,/*lPixel*/,/*{||  }*/)       
		
ElseIf cMvEstado=="RS"  // Se for Rio Grande do Sul
	oReport := TReport():New("MATR936",STR0121,"MTR936", {|oReport| ReportPrint(oReport)},STR0110)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 1 - Cabecalho Padrao    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oCabec	:= TRSection():New(oReport,"Dados da Empresa/Filial",{"SM0"},{"Código do Produto"},/*Campos do SX3*/,/*Campos do SIX*/)
 	TRCell():New(oCabec,"M0_NOMECOM","SM0"	,STR0062 ,/*Picture*/,25 ,/*lPixel*/,/*{|| }*/)
 	TRCell():New(oCabec,"M0_CGC"	,"SM0"	,"CNPJ" ,/*Picture*/,25	,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"MV_PAR11"	,"SM0"	,"Nº Registro da Empresa na SEAPA" ,/*Picture*/,24	,/*lPixel*/,/*{||  }*/)
 	TRCell():New(oCabec,"M0_ENDENT"	,"SM0"	,STR0063 ,/*Picture*/,35	,/*lPixel*/,/*{||  }*/)
  	TRCell():New(oCabec,"M0_CIDENT"	,"SM0"	,STR0064 ,/*Picture*/,20	,/*lPixel*/,/*{||  }*/)
	TRCell():New(oCabec,"M0_ESTENT"	,"SM0"	,STR0065 ,/*Picture*/,02 ,/*lPixel*/,/*{||   }*/)
	TRCell():New(oCabec,"M0_CEPCOB"	,"SM0"	,"CEP      " ,/*Picture*/,10 ,/*lPixel*/,/*{||   }*/)
 	TRCell():New(oCabec,"MV_PAR01"	,"SM0"	,STR0067 ,/*Picture*/,27	,/*lPixel*/,/*{||  }*/)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 2 - Entradas e Saidas   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oEntSaid	:= TRSection():New(oReport,"Movimentacao dos Produtos",{"TRB"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)

	TRCell():New(oEntSaid,"TRB_NUMNF"	,"TRB"	,STR0114 ,/*Picture*/,,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_COMFOR"	,"TRB"	,STR0115 ,/*Picture*/,25,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_ENDCF"	,"TRB"	,STR0116 ,/*Picture*/,35,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_MUNCF"	,"TRB"	,STR0064 ,/*Picture*/,20	,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_ESTCF"	,"TRB"	,STR0065 ,/*Picture*/,04 ,/*lPixel*/,/*{||   }*/)
	TRCell():New(oEntSaid,"TRB_NRECAG"	,"TRB"	,STR0117 ,"@E 9999999999",,/*lPixel*/,/*{||  }*/,"right",,"right")
	TRCell():New(oEntSaid,"TRB_DATA"	,"TRB"	,STR0118 ,/*Picture*/,14,/*lPixel*/,/*{||  }*/)
	TRCell():New(oEntSaid,"TRB_ESTANT"	,"TRB"	,STR0073 ,"@E 9,999,999.99",,/*lPixel*/,/*{||  }*/,"right",,"")
	TRCell():New(oEntSaid,"TRB_QTDCOM"	,"TRB"	,STR0119 ,"@E 9,999,999.99",,/*lPixel*/,/*{||  }*/,"right",,"")
	TRCell():New(oEntSaid,"TRB_ESTOQ"	,"TRB"	,STR0120 ,"@E 9,999,999.99",,/*lPixel*/,/*{||  }*/,"right",,"")
	
	oProdDesc	:= TRSection():New(oReport,"Dados do Produto",{"TRB"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	
	TRCell():New(oProdDesc,"TRB_CODPRO","TRB"	,STR0122,/*Picture*/,32,/*lPixel*/,/*{||  }*/)
	TRCell():New(oProdDesc,"TRB_INGATV","TRB"	,STR0123,/*Picture*/,40,/*lPixel*/,/*{||  }*/)
	TRCell():New(oProdDesc,"TRB_FORCAO","TRB"	,STR0124,/*Picture*/,160,/*lPixel*/,/*{||  }*/)

	oProdClass	:= TRSection():New(oReport,"Dados complementares do Produto",{"TRB"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)

	TRCell():New(oProdClass,"TRB_CLASSE","TRB"	,STR0125,/*Picture*/,70,/*lPixel*/,/*{||  }*/)	 
	TRCell():New(oProdClass,"TRB_CONCEN","TRB"	,STR0126,/*Picture*/,45,/*lPixel*/,/*{||  }*/)	 
	TRCell():New(oProdClass,"TRB_UNID"	,"TRB"	,STR0127,/*Picture*/,215,/*lPixel*/,/*{||  }*/)	

EndIf

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Andressa Fagundes      ³ Data ³30/05/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportPrint devera ser criada para todos  ³±±
±±³          ³os relatorios que poderao ser agendados pelo usuario.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

Local cDataDe	:=	StrZero(Day(MV_PAR01),2)+"/"+StrZero(Month(MV_PAR01),2)+"/"+StrZero(Year(MV_PAR01),4)
Local cDataAte	:=	StrZero(Day(MV_PAR02),2)+"/"+StrZero(Month(MV_PAR02),2)+"/"+StrZero(Year(MV_PAR02),4)
Local aCamposB5	:= 	{}
Local lRet		:= 	.T.
Local aTrb		:= 	{}
Local aBaseImp	:= 	{} 
Local cClasseTox:= 	""
Local cProduto	:= 	""
Local cPar11	:=	MV_PAR11
Local nQtdEst	:= 0
Local cMvEstado := SuperGetMv("MV_ESTADO")

If cMvEstado=="ES"  // Se for Espirito Santo 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 1 - Cabecalho Padrao                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):Cell("MV_PAR07"):SetBlock({|| MV_PAR07})
	oReport:Section(1):Cell("MV_PAR08"):SetBlock({|| MV_PAR08})
	oReport:Section(1):Cell("M0_NOMECOM"):SetBlock({|| SM0->M0_NOMECOM})
	oReport:Section(1):Cell("M0_ENDENT"):SetBlock({|| SM0->M0_ENDENT})
	oReport:Section(1):Cell("M0_CIDENT"):SetBlock({|| SM0->M0_CIDENT})
	oReport:Section(1):Cell("M0_ESTENT"):SetBlock({|| SM0->M0_ESTENT})
	oReport:Section(1):Cell("MV_PAR09"):SetBlock({|| MV_PAR09})
	oReport:Section(1):Cell("MV_PAR01"):SetBlock({|| cDataDe+STR0006+cDataAte})
   	oReport:Section(1):Cell("TRB_DESCL"):SetBlock({|| (aTrb[1])->TRB_DESCL})  


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 2 - Entradas e Saidas                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
	oReport:Section(2):Cell("TRB_CLTOX"):SetBlock({|| 	TRB->TRB_CLTOX})
	oReport:Section(2):Cell("TRB_DESCPR"):SetBlock({|| TRB->TRB_DESCPR})
	oReport:Section(2):Cell("TRB_PRIATV"):SetBlock({|| TRB->TRB_PRIATV})
	oReport:Section(2):Cell("TRB_SLDANT"):SetBlock({|| TRB->TRB_SLDANT})
	oReport:Section(2):Cell("TRB_ENTRAD"):SetBlock({|| TRB->TRB_ENTRAD})
	oReport:Section(2):Cell("TRB_SAIDA"):SetBlock({|| 	TRB->TRB_SAIDA})
	oReport:Section(2):Cell("TRB_SLDATU"):SetBlock({|| TRB->TRB_SLDATU})
	oReport:Section(2):Cell("TRB_COMER"):SetBlock({|| 	TRB->TRB_COMER})
	oReport:Section(2):Cell("TRB_USUAR"):SetBlock({|| 	TRB->TRB_USUAR})
	oReport:Section(2):Cell("TRB_DEVOL"):SetBlock({|| 	TRB->TRB_DEVOL})
	oReport:Section(2):Cell("TRB_EMBUM"):SetBlock({|| 	TRB->TRB_EMBUM})
	oReport:Section(2):Cell("TRB_EMBTP"):SetBlock({|| 	TRB->TRB_EMBTP})  
		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatório                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !R936CmpPar (@aCamposB5)
		Return (lRet)
	EndIf
     
	aTrb := R936Trb(aCamposB5)

	DbSelectArea (aTrb[1])  
	(aTrb[1])->(DbSetOrder (2))
	(aTrb[1])->(dbGoTop())
	
    oReport:SetMeter(1)
    oReport:Section(1):Init() 
    oReport:Section(1):PrintLine()
   	oReport:Section(1):Finish()	 
    	     
	oReport:SetMeter((aTrb[1])->(LastRec()))
	oReport:Section(2):Init()
	//
	Do While !(aTrb[1])->(Eof())
	
		If oReport:Cancel()
			Exit
		EndIf
       If (!Empty(cClasseTox) .And. !cClasseTox == (aTrb[1])->TRB_CLTOX ) 
		   	oReport:Section(2):Finish()
	   		oReport:SkipLine()
			oReport:ThinLine() 
       		oReport:Section(2):Init()  
       		 
    		oReport:SetMeter(1)
			oReport:Section(1):Init() 
			oReport:Section(1):PrintLine()  
			oReport:Section(1):Finish()
		EndIf                
		
		oReport:IncMeter() 
		oReport:Section(2):PrintLine() 
		cClasseTox:= (aTrb[1])->TRB_CLTOX
        //
		(aTrb[1])->(DbSkip())
	EndDo
	//  
      
   	oReport:Section(2):Finish()
	oReport:SkipLine()
	oReport:ThinLine() 
	oReport:IncMeter()

ElseIf cMvEstado=="SC" .OR. cMvEstado=="MG" .Or. !cMvEstado$("ES|MG|RS")  // Se for Santa Catarina,Minas Gerais ou diferente de ES|MG|RS
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 1 - Cabecalho Padrao                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):Cell("MV_PAR07"):SetBlock({|| MV_PAR07})
	oReport:Section(1):Cell("MV_PAR08"):SetBlock({|| MV_PAR08})
	oReport:Section(1):Cell("M0_NOMECOM"):SetBlock({|| SM0->M0_NOMECOM})
	oReport:Section(1):Cell("M0_ENDENT"):SetBlock({|| SM0->M0_ENDENT})
	oReport:Section(1):Cell("M0_CIDENT"):SetBlock({|| SM0->M0_CIDENT})
	oReport:Section(1):Cell("M0_ESTENT"):SetBlock({|| SM0->M0_ESTENT})
	oReport:Section(1):Cell("MV_PAR09"):SetBlock({|| MV_PAR09})
	oReport:Section(1):Cell("MV_PAR01"):SetBlock({|| cDataDe+STR0006+cDataAte})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 2 - Entradas e Saidas                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(2):Cell("TRB_TPPROD"):SetBlock({|| TRB->TRB_TPPROD})
	oReport:Section(2):Cell("TRB_DESCPR"):SetBlock({|| TRB->TRB_DESCPR})
	oReport:Section(2):Cell("TRB_PRIATV"):SetBlock({|| TRB->TRB_PRIATV})
	oReport:Section(2):Cell("TRB_PPATV"):SetBlock({|| 	TRB->TRB_PPATV})
	oReport:Section(2):Cell("TRB_CLTOX"):SetBlock({|| 	TRB->TRB_CLTOX})
	oReport:Section(2):Cell("TRB_SLDANT"):SetBlock({|| TRB->TRB_SLDANT})
	oReport:Section(2):Cell("TRB_ENTRAD"):SetBlock({|| TRB->TRB_ENTRAD})
	oReport:Section(2):Cell("TRB_SAIDA"):SetBlock({|| 	TRB->TRB_SAIDA})
	oReport:Section(2):Cell("TRB_SLDATU"):SetBlock({|| TRB->TRB_SLDATU})
	oReport:Section(2):Cell("TRB_EMBUM"):SetBlock({|| 	TRB->TRB_EMBUM})
	oReport:Section(2):Cell("TRB_EMBTP"):SetBlock({|| 	TRB->TRB_EMBTP})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatorio                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If !R936CmpPar (@aCamposB5)
		Return (lRet)
	EndIf

	oReport:SetMeter(1)
	oReport:Section(1):Init()
	oReport:Section(1):PrintLine()
	oReport:Section(1):Finish()	

	aTrb := R936Trb(aCamposB5)

	(aTrb[1])->(dbGoTop())
	DbSelectArea (aTrb[1])            
	oReport:SetMeter((aTrb[1])->(LastRec()))
	oReport:Section(2):Init()
	//
	Do While !(aTrb[1])->(Eof())
	
		If oReport:Cancel()
			Exit
		EndIf                     

		oReport:IncMeter()
		oReport:Section(2):PrintLine()
        //
		(aTrb[1])->(DbSkip())
	EndDo
	//                    
   	oReport:Section(2):Finish()
	oReport:SkipLine()
	oReport:ThinLine() 
	oReport:IncMeter()   

ElseIf cMvEstado=="RS"  // Se for Rio Grande do Sul
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 1 - Cabecalho Padrao                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):Cell("M0_NOMECOM"):SetBlock({|| SM0->M0_NOMECOM}) 
	oReport:Section(1):Cell("M0_CGC"):SetBlock({|| SM0->M0_CGC})                
	oReport:Section(1):Cell("MV_PAR11"):SetBlock({|| cPar11}) 
	oReport:Section(1):Cell("M0_ENDENT"):SetBlock({|| SM0->M0_ENDENT})
	oReport:Section(1):Cell("M0_CIDENT"):SetBlock({|| SM0->M0_CIDENT})
	oReport:Section(1):Cell("M0_ESTENT"):SetBlock({|| SM0->M0_ESTENT})	
	oReport:Section(1):Cell("M0_CEPCOB"):SetBlock({|| SM0->M0_CEPCOB})
	oReport:Section(1):Cell("MV_PAR01"):SetBlock({|| cDataDe+STR0006+cDataAte}) 	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 2 - Entradas e Saidas                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
	oReport:Section(2):Cell("TRB_NUMNF"):SetBlock({|| 	TRB->TRB_NUMNF})
	oReport:Section(2):Cell("TRB_COMFOR"):SetBlock({|| TRB->TRB_COMFOR})
	oReport:Section(2):Cell("TRB_ENDCF"):SetBlock({|| 	TRB->TRB_ENDCF})
	oReport:Section(2):Cell("TRB_MUNCF"):SetBlock({|| 	TRB->TRB_MUNCF})
	oReport:Section(2):Cell("TRB_ESTCF"):SetBlock({|| 	TRB->TRB_ESTCF})
	oReport:Section(2):Cell("TRB_NRECAG"):SetBlock({|| TRB->TRB_NRECAG})
	oReport:Section(2):Cell("TRB_DATA"):SetBlock({||	TRB->TRB_DATA})
	oReport:Section(2):Cell("TRB_ESTANT"):SetBlock({|| TRB->TRB_ESTANT})
	oReport:Section(2):Cell("TRB_QTDCOM"):SetBlock({|| TRB->TRB_QTDCOM})
	oReport:Section(2):Cell("TRB_ESTOQ"):SetBlock({|| nQtdEst})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 3 - Dados do Produto                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
	oReport:Section(3):Cell("TRB_CODPRO"):SetBlock({|| TRB_CODPRO})
	oReport:Section(3):Cell("TRB_INGATV"):SetBlock({|| TRB_INGATV})   
	oReport:Section(3):Cell("TRB_FORCAO"):SetBlock({|| TRB_FORCAO })
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Secao 4 - Dados complementares do Produto              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	
	oReport:Section(4):Cell("TRB_CLASSE"):SetBlock({|| TRB_CLASSE})	 
	oReport:Section(4):Cell("TRB_CONCEN"):SetBlock({|| TRB_CONCEN})	
	oReport:Section(4):Cell("TRB_UNID"):SetBlock({|| TRB_UNID})	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatório                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !R936CmpPar (@aCamposB5)
		Return (lRet)
	EndIf
     
	aTrb := R936Trb(aCamposB5)

	DbSelectArea (aTrb[1])  
	(aTrb[1])->(DbSetOrder (2))
	(aTrb[1])->(dbGoTop())
	
    oReport:SetMeter(1)
    oReport:Section(1):Init() 
    oReport:Section(1):PrintLine()
   	oReport:Section(1):Finish()	 
   	
   	oReport:SkipLine()
	oReport:ThinLine()
	oReport:SkipLine()
	oReport:SkipLine() 
    	             
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define chave para impressao do primeiro produto e inicia variavel de controle de linha/contador de registros por folha³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do While !(aTrb[1])->(Eof())
	
		oReport:SetMeter((aTrb[1])->(LastRec()))
		oReport:Section(2):Init() 		
	
		nContReg   := 1	
		cProduto	:= TRB->TRB_CODPRO
		nQtdEst  := 0
		cClasseTox:= ""
		Do While !(aTrb[1])->(Eof()) .And. ( TRB->TRB_CODPRO == cProduto ) .And. !Empty(TRB->TRB_CODPRO)
		
			If oReport:Cancel()
				Exit
			EndIf
	       If (!cClasseTox == (aTrb[1])->TRB_NUMNF .And. !Empty((aTrb[1])->TRB_NUMNF)) 
				nQtdEst += (aTrb[1])->TRB_ESTOQ

			 	If nContReg == 1 		 		  
				    oReport:SetMeter(3)
				    oReport:Section(3):Init() 
				    oReport:Section(3):PrintLine()
				   	oReport:Section(3):Finish()	 	 	       	 
				   	
 				    oReport:SetMeter(4)
				    oReport:Section(4):Init() 
				    oReport:Section(4):PrintLine()
				   	oReport:Section(4):Finish()	 
				   								 
				  	oReport:SkipLine()
			  	  	oReport:SkipLine()
					
				EndIf                            			
				oReport:IncMeter() 
				oReport:Section(2):PrintLine() 
		
	  			cClasseTox:= (aTrb[1])->TRB_NUMNF	       		 
			EndIf                			
			
			(aTrb[1])->(DbSkip())
		nContReg++
		EndDo
	      
	   	oReport:Section(2):Finish()
		oReport:SkipLine()
		oReport:IncMeter()
		
		oReport:EndPage()
	EndDo
EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Excluindo TRB apos gerar o relatorio.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTrb[3]:Delete()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³R936Trb   ³ Autor ³Gustavo G. Rueda       ³ Data ³03/01/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Processamento do TRB para impressao do relatorio.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 - Array contendo os campos da tabela SB5 referenciados³±±
±±³          ³atraves dos parametros.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. Sempre                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATR936                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R936Trb (aCamposB5)
	Local	aRet	:=	.T.
	Local	cArqTrb		:=	""
	Local	aStru		:=	{}
	Local	cAliasSf2	:=	"SF2"
	Local	aStruSF2  	:= SF2->(DbStruct ())
	Local	cAliasSd2	:=	"SD2"
	Local	aStruSd2 	:= SD2->(DbStruct ())
	Local	nX			:=	0
	Local	cQuery		:=	""
	Local	nRegsSf2	:=	0
	Local	aTrbInvet	:=	{"INV", ""}
	Local	cArqIndINV	:=	""
	Local	cChave		:=	""
	Local	nIndINV		:=	0
	Local	cAliasSf1	:=	"SF1"
	Local	aStruSF1	:=	SF1->(DbStruct ())
	Local	cArqSf1		:=	""
	Local	nRegsSf1	:=	0
	Local	cAliasSd1	:=	"SD1"
	Local	aStruSd1	:=	SD1->(DbStruct ())
	Local	cArqSd1		:=	""
	Local	cArqSd2		:=	""
	Local	cQueryB5	:=	""   
	Local   cCfopTrans  := GetNewPar("MV_CFTRANS","")  
	Local 	cDesCla   	:= ""
	Local 	aDesCla   	:= {}	 
	Local 	nY			:= 1
	Local 	cNUMNF		:=	AllTrim ((cAliasSd2)->D2_DOC) 
	Local 	cComFor		:=	""
	Local	cEndCF		:= "Endereço"
	Local   cMunCF		:= "Município"
	Local   cEstCF		:= "EST"
	Local	cNRecAgr	:= ""
	Local	cDATA		:= ""
	Local	nQtdCom		:= 0
	Local	nSaldoAnt	:= 0
	Local   nEstAnt		:= 0
	Local	cIngAtv		:= ""
	Local	cForcao		:= ""
	Local	cClasse 	:= ""
	Local	cUnidade	:= ""
	Local	cConcen		:= ""
	Local	cPrincAtv	:= ""
	Local	lD1_NRECAGR	:= SD1->(ColumnPos("D1_NRECAGR"))>0
	Local	lD2_NRECAGR	:= SD2->(ColumnPos("D2_NRECAGR"))>0
	Local	nSaldoIni := 0
	Local  	lSaldoIni := .T.
	Local  	aAreaSd
	Local  	cAliSB9
	Local  	cTpCam
	Local 	aSaldoIni
	Local 	cAliSB2
	Local 	oTempTable
	Local   cMvEstado := SuperGetMv("MV_ESTADO")

	cDesCla := GetNewPar("MV_DESCLAT","")  
    
	If !Empty(cDesCla)  
		Do While Len(cDesCla)<>0      //corrigido quando termina o ultimo item da string
			 If nY==0
			 	Exit
			 EndIf
			 nY      := At("-",cDesCla)
		     cCodigo := Alltrim(SubStr(cDesCla,1,nY-1))
		     cDesCla := SubStr(cDesCla,nY+1,len(cDesCla))
		     
			 nY      := At("/",cDesCla)  
			 cDClas  := SubStr(cDesCla,1,iif(nY<>0,nY-1,len(cDesCla))) //corrigido quando nao existe barra no final do string
			 cDesCla := SubStr(cDesCla,nY+1,len(cDesCla))
 			 Aadd(aDesCla,{cCodigo,cDClas})
		 Dbskip()
		 EndDo
	 EndIf



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montar o Inventario em um TRB para utilizacao no relatorio.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Verifica o inventario somente dos itens com os campos de agrotoxicos preenchidos
	dbSelectArea("SB5")
	For nX := 1 to Len(aCamposB5)
		#IFDEF TOP
			If (TcSrvType()<>"AS/400")
				If aCamposB5[nX,2] == "C"
					cQueryB5 += " AND SB5." + Alltrim(aCamposB5[nX,1]) + " <> '' "
				Else
					cQueryB5 += " AND SB5." + Alltrim(aCamposB5[nX,1]) + " > 0 "
				Endif
			Else
		#ENDIF
				If aCamposB5[nX,2] == "C"
					If Empty(cQueryB5)
						cQueryB5 += ".AND. !EMPTY(SB5->" + Alltrim(aCamposB5[nX,1]) + ") "
					Else
						cQueryB5 += ".AND. !EMPTY(SB5->" + Alltrim(aCamposB5[nX,1]) + ") "
					Endif
				Else   
					If Empty(cQueryB5)
						cQueryB5 += ".AND. SB5->" + Alltrim(aCamposB5[nX,1]) + " > 0 "
					Else
						cQueryB5 += ".AND. SB5->" + Alltrim(aCamposB5[nX,1]) + " > 0 "
					Endif
				Endif
		#IFDEF TOP
			EndIf
		#ENDIF	
	Next
	FsEstInv (@aTrbInvet, 1, .T., .F., MV_PAR10, .T.,,!Empty(cQueryB5),cQueryB5)
	DbSelectArea ("INV")
	cArqIndINV	:=	CriaTrab (Nil, .F.)
	cChave 		:= "CODIGO"
	IndRegua ("INV", cArqIndINV, cChave,,)
	INV->(DbGoTop ())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monto o TRB para impressao.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd (aStru, {"TRB_CODPRO"	,	"C",	TAMSX3("B1_COD")[1]	,	0})
	aAdd (aStru, {"TRB_TPPROD"	,	"C",	02					,		0})
	aAdd (aStru, {"TRB_DESCPR"	,	"C",	40					,		0})
	aAdd (aStru, {"TRB_PRIATV"	,	"C",	50					,		0})
	aAdd (aStru, {"TRB_PPATV"	,	"N",	05					,		2})
	aAdd (aStru, {"TRB_CLTOX"	,	"C",	03					,		0})	
	aAdd (aStru, {"TRB_SLDANT"	,	"N",	12					,		2})
	aAdd (aStru, {"TRB_ENTRAD"	,	"N",	12					,		2})
	aAdd (aStru, {"TRB_SAIDA"	,	"N",	12					,		2})
	aAdd (aStru, {"TRB_SLDATU"	,	"N",	12					,		2})
	aAdd (aStru, {"TRB_EMBUM"	,	"C",	03					,		0})
	aAdd (aStru, {"TRB_EMBTP"	,	"C",	20					,		0})
	aAdd (aStru, {"TRB_COMER"	,	"N",	12					,		2})
	aAdd (aStru, {"TRB_USUAR"	,	"N",	12					,		2})
	aAdd (aStru, {"TRB_DEVOL"	,	"N",	12					,		2})  
	aAdd (aStru, {"TRB_DESCL"	,  	"C",	15					,		0}) 

	If cMvEstado=="RS"
		aAdd (aStru, {"TRB_NUMNF"	,	"C",	TAMSX3("F1_DOC")[1]	,	0})
		aAdd (aStru, {"TRB_COMFOR"	,	"C",	25						,	0})
		aAdd (aStru, {"TRB_ENDCF"	,	"C",	35						,	0})
		aAdd (aStru, {"TRB_MUNCF"	,	"C",	20						,	0})
		aAdd (aStru, {"TRB_ESTCF"	,	"C",	04						,	0})
		aAdd (aStru, {"TRB_NRECAG"	,	"C",	12						,	0})
		aAdd (aStru, {"TRB_DATA" 	,	"C",	14						,	0})
		aAdd (aStru, {"TRB_ESTANT"	,	"N",	12						,	2})
		aAdd (aStru, {"TRB_QTDCOM"	,	"N",	12						,	2})
		aAdd (aStru, {"TRB_ESTOQ"	,	"N",	12						,	2})
		aAdd (aStru, {"TRB_INGATV"	,	"C",	40						,	0})
		aAdd (aStru, {"TRB_FORCAO"	,	"C",	70						,	0})
		aAdd (aStru, {"TRB_CLASSE"	,	"C",	70						,	0})
		aAdd (aStru, {"TRB_CONCEN"	,	"C",	45						,	0})
		aAdd (aStru, {"TRB_UNID" 	,	"C",	14						,	0})	
	EndIf

	//
	oTempTable := FWTemporaryTable():New( "TRB" )
	oTempTable:SetFields( aStru )

	If cMvEstado=="SC".OR. cMvEstado=="MG"	
		oTempTable:AddIndex( "01", {"TRB_CODPRO"} )
	Else		
		oTempTable:AddIndex( "01", {"TRB_CODPRO"} )
		
	   	If cMvEstado=="RS"
			oTempTable:AddIndex( "02",{"TRB_NUMNF","TRB_CODPRO"})
				   
	 	Else
			oTempTable:AddIndex( "02",{"TRB_CLTOX", "TRB_CODPRO"})
	 	EndIf		
	Endif	
	oTempTable:Create()
	dbSelectArea("TRB")
	dbSetOrder(1)
	dbGoTop()
	aRet	:=	{"TRB", "01", oTempTable}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                                       ³
	//³                                       ³
	//³PROCESSANDO AS NOTAS FISCAIS DE ENTRADA³
	//³                                       ³
	//³                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea ("SF1")
		SF1->(DbSetOrder (1))
	//
	#IFDEF TOP
		If (TcSrvType ()<>"AS/400")
			cAliasSf1	:=	"SF1Query"
			//
			cQuery	:=	"SELECT "
			cQuery	+=	"SF1.F1_FILIAL, SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_EMISSAO, SF1.F1_DTDIGIT, SF1.F1_TIPO "
			cQuery	+=	"FROM "
			cQuery	+=	RetSqlName ("SF1")+" SF1 "
			cQuery	+=	"WHERE "
			cQuery	+=	"SF1.F1_FILIAL='"+xFilial ("SF1")+"' AND "
			cQuery	+=	"SF1.F1_DTDIGIT>='"+DToS (MV_PAR01)+"' AND "
			cQuery	+=	"SF1.F1_DTDIGIT<='"+DToS (MV_PAR02)+"' AND "
			cQuery	+=	"SF1.F1_TIPO IN ('N','D','B') AND "
			cQuery	+=	"SF1.D_E_L_E_T_ = ' ' "
			cQuery	+=	"ORDER BY "	
			cQuery	+=	"SF1.F1_FILIAL, SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_FORNECE, SF1.F1_LOJA "
			//
			cQuery := ChangeQuery (cQuery)
			//
			dbUseArea (.T., "TOPCONN", TcGenQry (,,cQuery), cAliasSf1, .T., .T.)
			//
			For nX := 1 To Len (aStruSF1)
				If (aStruSF1[nX][2]<>"C") .And. (ColumnPos (aStruSF1[nX][1])<>0)
					TcSetField (cAliasSF1, aStruSF1[nX][1], aStruSF1[nX][2], aStruSF1[nX][3], aStruSF1[nX][4])
				EndIf
			Next (nX)
		Else
	#ENDIF
			cArqSf1 := CriaTrab (Nil, .F.)
			cQuery	:=	"F1_FILIAL=='"+xFilial ("SF1")+"' .And. DTOS (F1_DTDIGIT)>='"+DTOS (MV_PAR01)+"' .And. DTOS (F1_DTDIGIT)<='"+DTOS (MV_PAR02)+"' .And. "
			cQuery	+=	"F1_TIPO$'NDB' "
			IndRegua (cAliasSf1, cArqSf1, IndexKey (),, cQuery, STR0005)	//"Selecionando Documentos ..."
	#IFDEF TOP
		EndIf
	#ENDIF	
	//
	DbSelectArea (cAliasSf1)
	COUNT TO nRegsSf1
	(cAliasSf1)->(DbGoTop ())
	//
	Do While !(cAliasSf1)->(Eof ())
		DbSelectArea ("SD1")
		SD1->(DbSetOrder (3))
		//
		#IFDEF TOP
			If (TcSrvType ()<>"AS/400")
				cAliasSd1	:=	"SD1query"
				//
				cQuery	:=	"SELECT "
				cQuery	+=	"SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_COD, SD1.D1_QUANT, SD1.D1_UM, "
				If lD1_NRECAGR
					cQuery +=  "SD1.D1_NRECAGR, "
				EndIf 
				cQuery	+=	"SB1.B1_DESC, SB1.B1_UM, SB1.B1_TIPO, "
				If cMvEstado == "RS"
					cQuery += "SB5.B5_NRECAGR"+", SB5."+AllTrim (aCamposB5[1,1])+", SB5."+AllTrim (aCamposB5[2,1])+", SB5."+AllTrim (aCamposB5[3,1])+", SB5."+AllTrim (aCamposB5[4,1])
				Else
					cQuery += "SB5."+AllTrim (aCamposB5[1,1])+", SB5."+AllTrim (aCamposB5[2,1])+", SB5."+AllTrim (aCamposB5[3,1])+", SB5."
					cQuery += AllTrim (aCamposB5[4,1])+Iif(cMvEstado=="RS",", SB5."+AllTrim (aCamposB5[5,1])+" "," ")
				EndIf
				cQuery	+=	"FROM "
				cQuery	+=	RetSqlName ("SD1")+" SD1, "+RetSqlName ("SB1")+" SB1, "+RetSqlName ("SB5")+" SB5, "+RetSqlName ("SF4")+" SF4 "
				cQuery	+=	"WHERE "
				cQuery	+=	"SD1.D1_FILIAL='"+xFilial ("SD1")+"' AND "
				cQuery	+=	"SD1.D1_DOC='"+(cAliasSf1)->F1_DOC+"' AND "
				cQuery	+=	"SD1.D1_SERIE='"+(cAliasSf1)->F1_SERIE+"' AND "
				cQuery	+=	"SD1.D1_FORNECE='"+(cAliasSf1)->F1_FORNECE+"' AND "
				cQuery	+=	"SD1.D1_LOJA='"+(cAliasSf1)->F1_LOJA+"' AND "
				cQuery	+=	"SD1.D1_COD>='"+MV_PAR03+"' AND "
				cQuery	+=	"SD1.D1_COD<='"+MV_PAR04+"' AND "
				cQuery	+=	"SB1.B1_FILIAL='"+xFilial ("SB1")+"' AND "
				If !cMvEstado=="RS"
					cQuery	+=	"SB1.B1_GRUPO>='"+MV_PAR05+"' AND "
					cQuery	+=	"SB1.B1_GRUPO<='"+MV_PAR06+"' AND "
				EndIf
				cQuery	+=	"SB1.B1_COD=SD1.D1_COD AND "
				cQuery	+=	"SB5.B5_FILIAL='"+xFilial ("SB5")+"' AND "
				cQuery	+=	"SB5.B5_COD=SD1.D1_COD "
				If cMvEstado == "RS"
					If lD1_NRECAGR
						cQuery +=	"AND ( SD1.D1_NRECAGR <> ' ' OR SB5.B5_NRECAGR <> ' ' ) "
					Else
						cQuery += "AND SB5.B5_NRECAGR <> ' ' " 
					EndIf
				EndIf
				If !Empty(cQueryB5)
					cQuery += cQueryB5
				Endif
				If !Empty(cQueryB5)
					cQuery	+= cQueryB5
				Endif
				cQuery	+=	"AND SF4.F4_FILIAL='"+xFilial ("SF4")+"' AND "
				cQuery	+=	"SF4.F4_CODIGO=SD1.D1_TES AND "
				cQuery	+=	"SF4.F4_ESTOQUE IN ('S') AND "
				cQuery	+=	"SB1.D_E_L_E_T_ = ' ' AND "
				cQuery	+=	"SD1.D_E_L_E_T_ = ' ' AND "
				cQuery	+=	"SB5.D_E_L_E_T_ = ' ' AND "
				cQuery	+=	"SF4.D_E_L_E_T_ = ' ' "
				cQuery	+=	"ORDER BY "	
				cQuery	+=	"SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_COD "
				//
				cQuery := ChangeQuery (cQuery)
				//
				dbUseArea (.T., "TOPCONN", TcGenQry (,,cQuery), cAliasSd1, .T., .T.)
				//
				For nX := 1 To Len (aStruSd1)
					If (aStruSd1[nX][2]<>"C") .And. (ColumnPos (aStruSd1[nX][1])<>0)
						TcSetField (cAliasSd1, aStruSd1[nX][1], aStruSd1[nX][2], aStruSd1[nX][3], aStruSd1[nX][4])
					EndIf
				Next (nX)
			Else
		#ENDIF
				cArqSd1 := CriaTrab (Nil, .F.)
				cQuery	:=	"D1_FILIAL=='"+xFilial ("SD1")+"' .And. D1_DOC=='"+(cAliasSf1)->F1_DOC+"' .And. D1_SERIE=='"+(cAliasSf1)->F1_SERIE+"' .And. "
				cQuery	+=	"D1_FORNECE=='"+(cAliasSf1)->F1_FORNECE+"' .And. D1_LOJA=='"+(cAliasSf1)->F1_LOJA+"' .And. D1_COD>='"+MV_PAR03+"' .And. "
				cQuery	+=	"D1_COD<='"+MV_PAR04+"' "
				IndRegua (cAliasSd1, cArqSd1, IndexKey (),, cQuery, STR0005)	//"Selecionando Documentos ..."
		#IFDEF TOP
			EndIf
		#ENDIF
		//
		SA2->(DbSetOrder(1))
		SA2->(DbSeek(xFilial("SA2")+(cAliasSf1)->F1_FORNECE+(cAliasSf1)->F1_LOJA))	
		//
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+(cAliasSf1)->F1_FORNECE+(cAliasSf1)->F1_LOJA))	
		//
		DbSelectArea (cAliasSd1)
		(cAliasSd1)->(DbGoTop ())
		//
		Do While !(cAliasSd1)->(Eof ())
			
			nSaldoIni := 0
			If lSaldoIni
				aAreaSd := SD1->(GetArea())
				If cMvEstado=="RS"					
					cAliSB2 := GetNextAlias()			
					cQuery := "SELECT B2_COD, B2_LOCAL FROM "+RETSQLNAME('SB2')+" WHERE B2_FILIAL='"+xFilial("SB2")+"' AND D_E_L_E_T_ <> '*' AND B2_COD = '" + (cAliasSd1)->D1_COD + "'"
					cQuery := ChangeQuery(cQuery)
					DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliSB2,.F.,.T.)
					Do While !(cAliSB2)->(Eof ())
						aSaldoIni := CalcEst((cAliSB2)->B2_COD, (cAliSB2)->B2_LOCAL, MV_PAR01-1)
						nSaldoIni += aSaldoIni[1]
						(cAliSB2)->(dbSkip())
					EndDo
					(cAliSB2)->( DBCloseArea())
					lSaldoIni := .F.
				Else
					cAliSB9 := GetNextAlias()								
					cQuery := "SELECT SUM(B9_QINI) AS B9_QINI FROM "+RETSQLNAME('SB9')+" WHERE B9_FILIAL='"+xFilial("SB9")+"' AND D_E_L_E_T_ <> '*' AND B9_COD = '" + (cAliasSd1)->D1_COD + "'"
					cQuery := ChangeQuery(cQuery)
					DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliSB9,.F.,.T.)
					nSaldoIni := (cAliSB9)->B9_QINI
					(cAliSB9)->( DBCloseArea())
					RestArea(aAreaSd)
				lSaldoIni := .F.
				EndIf
			EndIf
			
			#IFNDEF TOP
				DbSelectArea ("SB1")
				SB1->(DbSetOrder (1))
				If !(SB1->(DbSeek (xFilial ("SB1")+(cAliasSd1)->D1_COD)) .And. (SB1->B1_GRUPO>=MV_PAR05) .And. (SB1->B1_GRUPO<=MV_PAR06)) .And. !cMvEstado=="RS"
					(cAliasSd1)->(DbSkip ())
					Loop
				EndIf
				//
				DbSelectArea ("SB5")
				SB5->(DbSetOrder (1))
				If !(SB5->(DbSeek (xFilial ("SB5")+(cAliasSd1)->D1_COD)))
					(cAliasSd1)->(DbSkip ())
					Loop
				EndIf
				//
				DbSelectArea ("SF4")
					SF4->(DbSetOrder (1))
				If !(SF4->(DbSeek (xFilial ("SF4")+(cAliasSd1)->D1_TES))) .And. !(SF4->F4_ESTOQUE=='S')	//TES tem que movimentar estoque
					(cAliasSd1)->(DbSkip ())
					Loop
				EndIf
				//
				cTipProd	:=	AllTrim (SB1->B1_TIPO)
				cDescProd	:=	AllTrim (SB1->B1_DESC)
				cEmbalUm	:=	AllTrim (SB1->B1_UM)
				If cMvEstado=="RS"
					cNUMNF		:=	AllTrim ((cAliasSd1)->D1_DOC) 
					cComFor	:=	IIf((cAliasSf1)->F1_TIPO == "D" .Or. (cAliasSf1)->F1_TIPO == "B",AllTrim(SA1->A1_NOME),AllTrim(SA2->A2_NOME))
					cEndCF		:=	IIf((cAliasSf1)->F1_TIPO == "D" .Or. (cAliasSf1)->F1_TIPO == "B",AllTrim(SA1->A1_END),AllTrim(SA2->A2_END))
					cNRecAgr	:=	Alltrim((cAliasSd1)->(FieldGet (ColumnPos ("D1_NRECAGR"))))
					cDATA		:=	StrZero(Day((cAliasSf1)->F1_EMISSAO),2)+"/"+StrZero(Month((cAliasSf1)->F1_EMISSAO),2)+"/"+StrZero(Year((cAliasSf1)->F1_EMISSAO),4)
					nQtdCom		:=	(cAliasSd1)->D1_QUANT
					cIngAtv		:= 	Alltrim(SB5->(FieldGet (ColumnPos (aCamposb5[1,1]))))
					cForcao		:= 	Alltrim(SB5->(FieldGet (ColumnPos (aCamposb5[2,1]))))
					cClasse 	:= 	Alltrim(SB5->(FieldGet (ColumnPos (aCamposb5[3,1]))))
					cConcen 	:= 	Alltrim(SB5->(FieldGet (ColumnPos (aCamposb5[4,1]))))
					cUnidade	:= (cAliasSd1)->D1_UM
				Else
					cPrincAtv	:=	AllTrim (SB5->(FieldGet (ColumnPos (aCamposb5[1,1]))))
					nPercPAtv	:=	SB5->(FieldGet (ColumnPos (aCamposb5[2])))
					cClToxico	:=	AllTrim (SB5->(FieldGet (ColumnPos (aCamposb5[3,1]))))
					cTipEmbal	:=	AllTrim (SB5->(FieldGet (ColumnPos (aCamposb5[4,1]))))
				EndIf

				If Empty(cPrincAtv) .Or. Empty(cClToxico) .Or. Empty(cTipEmbal) .Or. nPercPAtv == 0
					(cAliasSd2)->(DbSkip ())
					Loop
				Endif

			#ELSE
				cTipProd	:=	AllTrim ((cAliasSd1)->B1_TIPO)
				cDescProd	:=	AllTrim ((cAliasSd1)->B1_DESC)
				cEmbalUm	:=	AllTrim ((cAliasSd1)->B1_UM)
				If cMvEstado=="RS"
					cNUMNF  := AllTrim ((cAliasSd1)->D1_DOC)
					cComFor := IIf((cAliasSf1)->F1_TIPO == "D" .Or. (cAliasSf1)->F1_TIPO == "B",AllTrim(SA1->A1_NOME),AllTrim(SA2->A2_NOME))
					cEndCF  := IIf((cAliasSf1)->F1_TIPO == "D" .Or. (cAliasSf1)->F1_TIPO == "B",AllTrim(SA1->A1_END),AllTrim(SA2->A2_END))
					cMunCF	 := IIf((cAliasSf1)->F1_TIPO == "D" .Or. (cAliasSf1)->F1_TIPO == "B",AllTrim(SA1->A1_MUN),AllTrim(SA2->A2_MUN))
					cEstCF	 := IIf((cAliasSf1)->F1_TIPO == "D" .Or. (cAliasSf1)->F1_TIPO == "B",AllTrim(SA1->A1_EST),AllTrim(SA2->A2_EST))
					
					If	lD1_NRECAGR .And. !Empty((cAliasSd1)->(D1_NRECAGR))
						cNRecAgr	:=	Alltrim((cAliasSd1)->(FieldGet (ColumnPos ("D1_NRECAGR"))))
					EndIf

					cDATA		:= StrZero(Day((cAliasSf1)->F1_EMISSAO),2)+"/"+StrZero(Month((cAliasSf1)->F1_EMISSAO),2)+"/"+StrZero(Year((cAliasSf1)->F1_EMISSAO),4)
					nQtdCom		:= (cAliasSd1)->D1_QUANT
					cIngAtv		:= Alltrim((cAliasSd1)->(FieldGet (ColumnPos (aCamposb5[1,1]))))
					cForcao		:= Alltrim((cAliasSd1)->(FieldGet (ColumnPos (aCamposb5[2,1]))))
					cClasse		:= Alltrim((cAliasSd1)->(FieldGet (ColumnPos (aCamposb5[3,1]))))
					cConcen		:= Alltrim((cAliasSd1)->(FieldGet (ColumnPos (aCamposb5[4,1]))))
					cUnidade	:= (cAliasSd1)->D1_UM
				Else

					If	lD1_NRECAGR .And. !Empty((cAliasSd1)->(D1_NRECAGR))
						cPrincAtv	:=	Alltrim((cAliasSd1)->(FieldGet (ColumnPos ("D1_NRECAGR"))))
					Else
						cPrincAtv	:=	AllTrim ((cAliasSd1)->(FieldGet (FieldPos (aCamposb5[1,1]))))
					EndIf

					nPercPAtv	:=	(cAliasSd1)->(FieldGet (ColumnPos (aCamposb5[2,1])))
					cClToxico	:=	AllTrim ((cAliasSd1)->(FieldGet (ColumnPos (aCamposb5[3,1]))))
					cTipEmbal	:=	AllTrim ((cAliasSd1)->(FieldGet (ColumnPos (aCamposb5[4,1]))))
				EndIf
			#ENDIF
			//
			If cMvEstado=="RS"
				nSaldoAnt += (cAliasSd1)->D1_QUANT
			Else
				DbSelectArea ("INV")
				If INV->(DbSeek((cAliasSd1)->D1_COD))
					nSaldoAnt := INV->QUANT
				EndIf
			EndIf
			//
			If (TRB->(DbSeek(IIF(cMvEstado=="RS",(cAliasSd1)->D1_DOC,"")+(cAliasSd1)->D1_COD)))
				RecLock ("TRB", .F.)
			Else
				RecLock ("TRB", .T.)
					TRB->TRB_CODPRO	:= (cAliasSd1)->D1_COD
					TRB->TRB_TPPROD	:= cTipProd
					TRB->TRB_DESCPR	:= cDescProd
					If cMvEstado=="RS"
						TRB->TRB_NUMNF	:= cNUMNF
						TRB->TRB_COMFOR	:= cComFor
						TRB->TRB_ENDCF	:= cEndCF
						TRB->TRB_MUNCF	:= cMunCF
						TRB->TRB_ESTCF	:= cEstCF
						TRB->TRB_NRECAG	:= cNRecAgr
						TRB->TRB_DATA		:= cDATA
						TRB->TRB_INGATV	:= cIngAtv
						TRB->TRB_FORCAO	:= cForcao
						TRB->TRB_CLASSE	:= cClasse
						TRB->TRB_CONCEN	:= cConcen
						TRB->TRB_UNID	:= cUnidade
					Else
						TRB->TRB_PRIATV	:= cPrincAtv
						TRB->TRB_PPATV	:= nPercPAtv
						TRB->TRB_CLTOX	:= cClToxico 
					EndIf
					If cMvEstado=="ES" .And. Len(aDesCla)>0
						For nY :=1 to Len(aDesCla)
							If aDesCla[nY][1]==cClToxico
								TRB->TRB_DESCL:=aDesCla[nY][2]
							EndIf
						Next nY
					Endif
					TRB->TRB_SLDANT	:= nSaldoAnt
					TRB->TRB_SLDATU	:= nSaldoAnt
					TRB->TRB_EMBUM	:= cEmbalUm
					If !cMvEstado=="RS"
						TRB->TRB_EMBTP	:=	cTipEmbal
					EndIf
			EndIf
			If cMvEstado=="RS"
				TRB->TRB_ESTANT	:= nEstAnt
				TRB->TRB_QTDCOM	+= nQtdCom
				TRB->TRB_ESTOQ	+= nQtdCom + nSaldoIni
			EndIf
					TRB->TRB_ENTRAD	+=	(cAliasSd1)->D1_QUANT
					TRB->TRB_SLDATU	+=	(cAliasSd1)->D1_QUANT
				MsUnLock ()
			//
			DbSelectArea (cAliasSd1)
			(cAliasSd1)->(DbSkip ())
		EndDo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apago arquivo trabalho SD1.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea (cAliasSd1)
		(cAliasSd1)->(DbCloseArea ())
		#IFNDEF TOP
			Ferase (cArqSd1+GetDBExtension ())
			Ferase (cArqSd1+OrdBagExt ())
		#ENDIF
		//
		DbSelectArea (cAliasSf1)
		(cAliasSf1)->(DbSkip ())
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apago arquivo trabalho SF2.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea (cAliasSf1)
	(cAliasSf1)->(DbCloseArea ())
	#IFNDEF TOP
		Ferase (cArqSf1+GetDBExtension ())
		Ferase (cArqSf1+OrdBagExt ())
	#ENDIF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                                      ³
	//³                                      ³
	//³PROCESSANDO AS NOTAS FISCAIS DE SAIDA ³
	//³                                      ³
	//³                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea ("SF2")
		SF2->(DbSetOrder (1))
	//
	#IFDEF TOP
		If (TcSrvType ()<>"AS/400")
			cAliasSf2	:=	"SF2Query"
			//
			cQuery	:=	"SELECT "
			cQuery	+=	"SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_EMISSAO, SF2.F2_TIPO "
			cQuery	+=	"FROM "
			cQuery	+=	RetSqlName ("SF2")+" SF2 "
			cQuery	+=	"WHERE "
			cQuery	+=	"SF2.F2_FILIAL='"+xFilial ("SF2")+"' AND "
			cQuery	+=	"SF2.F2_EMISSAO>='"+DToS (MV_PAR01)+"' AND "
			cQuery	+=	"SF2.F2_EMISSAO<='"+DToS (MV_PAR02)+"' AND "
			cQuery	+=	"SF2.F2_TIPO IN ('N','D','B') AND "
			cQuery	+=	"SF2.D_E_L_E_T_ = ' ' "
			cQuery	+=	"ORDER BY "	
			cQuery	+=	"SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA "
			//
			cQuery := ChangeQuery (cQuery)
			//
			dbUseArea (.T., "TOPCONN", TcGenQry (,,cQuery), cAliasSf2, .T., .T.)
			//
			For nX := 1 To Len (aStruSF2)
				If (aStruSF2[nX][2]<>"C") .And. (ColumnPos (aStruSF2[nX][1])<>0)
					TcSetField (cAliasSF2, aStruSF2[nX][1], aStruSF2[nX][2], aStruSF2[nX][3], aStruSF2[nX][4])
				EndIf
			Next (nX)
		Else
	#ENDIF
			cArqSf2 := CriaTrab (Nil, .F.)
			cQuery	:=	"F2_FILIAL=='"+xFilial ("SF2")+"' .And. DTOS (F2_EMISSAO)>='"+DTOS (MV_PAR01)+"' .And. DTOS (F2_EMISSAO)<='"+DTOS (MV_PAR02)+"' .And. "
			cQuery	+=	"F2_TIPO$'NDB' "
			IndRegua (cAliasSf2, cArqSf2, IndexKey (),, cQuery, STR0005)	//"Selecionando Documentos ..."
	#IFDEF TOP
		EndIf
	#ENDIF
	//
	DbSelectArea (cAliasSf2)
	nRegsSf2 := LastRec()
	(cAliasSf2)->(DbGoTop ())
	//
	Do While !(cAliasSf2)->(Eof ())
		DbSelectArea ("SD2")
		SD2->(DbSetOrder (3))
		//
		#IFDEF TOP
			If (TcSrvType ()<>"AS/400")
				cAliasSd2	:=	"SD2query"
				//
				cQuery	:=	"SELECT "
				cQuery	+=	"SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, SD2.D2_QUANT, SD2.D2_CF, SD2.D2_UM, "
				If lD2_NRECAGR
					cQuery +=  "SD2.D2_NRECAGR, "
				EndIf 
				cQuery	+=	"SB1.B1_DESC, SB1.B1_UM, SB1.B1_TIPO, "
				If cMvEstado == "RS" 						
					cQuery += "SB5.B5_NRECAGR"+", SB5."+AllTrim (aCamposB5[1,1])+", SB5."+AllTrim (aCamposB5[2,1])+", SB5."+AllTrim (aCamposB5[3,1])+", SB5."+AllTrim (aCamposB5[4,1])
				Else
					cQuery += "SB5."+AllTrim (aCamposB5[1,1])+", SB5."+AllTrim (aCamposB5[2,1])+", SB5."+AllTrim (aCamposB5[3,1])+", SB5."
					cQuery += AllTrim (aCamposB5[4,1])+Iif(cMvEstado=="RS",", SB5."+AllTrim (aCamposB5[5,1])+" "," ")
				EndIf					
				cQuery	+=	"FROM "
				cQuery	+=	RetSqlName ("SD2")+" SD2, "+RetSqlName ("SB1")+" SB1, "+RetSqlName ("SB5")+" SB5, "+RetSqlName ("SF4")+" SF4 "
				cQuery	+=	"WHERE "
				cQuery	+=	"SD2.D2_FILIAL='"+xFilial ("SD2")+"' AND "
				cQuery	+=	"SD2.D2_DOC='"+(cAliasSf2)->F2_DOC+"' AND "
				cQuery	+=	"SD2.D2_SERIE='"+(cAliasSf2)->F2_SERIE+"' AND "
				cQuery	+=	"SD2.D2_CLIENTE='"+(cAliasSf2)->F2_CLIENTE+"' AND "
				cQuery	+=	"SD2.D2_LOJA='"+(cAliasSf2)->F2_LOJA+"' AND "
				cQuery	+=	"SD2.D2_COD>='"+MV_PAR03+"' AND "
				cQuery	+=	"SD2.D2_COD<='"+MV_PAR04+"' AND "
				cQuery	+=	"SB1.B1_FILIAL='"+xFilial ("SB1")+"' AND "
				If !cMvEstado=="RS"
					cQuery	+=	"SB1.B1_GRUPO>='"+MV_PAR05+"' AND "
					cQuery	+=	"SB1.B1_GRUPO<='"+MV_PAR06+"' AND "
				EndIf
				cQuery	+=	"SB1.B1_COD=SD2.D2_COD AND "
				cQuery	+=	"SB5.B5_FILIAL='"+xFilial ("SB5")+"' AND "
				cQuery	+=	"SB5.B5_COD=SD2.D2_COD "
				If cMvEstado == "RS"
					If lD2_NRECAGR
						cQuery +=	"AND ( SD2.D2_NRECAGR <> ' ' OR SB5.B5_NRECAGR <> ' ' ) "
					Else
						cQuery += "AND SB5.B5_NRECAGR <> ' ' " 
					EndIf
				EndIf
				If !Empty(cQueryB5)
					cQuery += cQueryB5
				Endif
				If !Empty(cQueryB5)
					cQuery	+= cQueryB5
				Endif
				cQuery	+=	"AND SF4.F4_FILIAL='"+xFilial ("SF4")+"' AND "
				cQuery	+=	"SF4.F4_CODIGO=SD2.D2_TES AND "
				cQuery	+=	"SF4.F4_ESTOQUE IN ('S') AND "
				cQuery	+=	"SB1.D_E_L_E_T_ = ' ' AND "
				cQuery	+=	"SD2.D_E_L_E_T_ = ' ' AND "
				cQuery	+=	"SB5.D_E_L_E_T_ = ' ' AND "
				cQuery	+=	"SF4.D_E_L_E_T_ = ' ' "
				cQuery	+=	"ORDER BY "	
				cQuery	+=	"SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD "
				//
				cQuery := ChangeQuery (cQuery)
				//
				dbUseArea (.T., "TOPCONN", TcGenQry (,,cQuery), cAliasSd2, .T., .T.)
				//
				For nX := 1 To Len (aStruSd2)
					If (aStruSd2[nX][2]<>"C") .And. (ColumnPos (aStruSd2[nX][1])<>0)
						TcSetField (cAliasSd2, aStruSd2[nX][1], aStruSd2[nX][2], aStruSd2[nX][3], aStruSd2[nX][4])
					EndIf
				Next (nX)
			Else
		#ENDIF
				cArqSd2 := CriaTrab (Nil, .F.)
				cQuery	:=	"D2_FILIAL=='"+xFilial ("SD2")+"' .And. D2_DOC=='"+(cAliasSf2)->F2_DOC+"' .And. D2_SERIE=='"+(cAliasSf2)->F2_SERIE+"' .And. "
				cQuery	+=	"D2_CLIENTE=='"+(cAliasSf2)->F2_CLIENTE+"' .And. D2_LOJA=='"+(cAliasSf2)->F2_LOJA+"' .And. D2_COD>='"+MV_PAR03+"' .And. "
				cQuery	+=	"D2_COD<='"+MV_PAR04+"' "
				IndRegua (cAliasSd2, cArqSd2, IndexKey (),, cQuery, STR0005)	//"Selecionando Documentos ..."
		#IFDEF TOP
			EndIf
		#ENDIF
		//
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+(cAliasSf2)->F2_CLIENTE+(cAliasSf2)->F2_LOJA))	
		//
		SA2->(DbSetOrder(1))
		SA2->(DbSeek(xFilial("SA2")+(cAliasSf2)->F2_CLIENTE+(cAliasSf2)->F2_LOJA))	
		//
		DbSelectArea (cAliasSd2)
		(cAliasSd2)->(DbGoTop ())
		//
		Do While !(cAliasSd2)->(Eof ())

			nSaldoIni := 0
			If lSaldoIni
				aAreaSd := SD2->(GetArea())

				If cMvEstado=="RS"
					cAliSB2 := GetNextAlias()
					cQuery := "SELECT B2_COD, B2_LOCAL FROM "+RETSQLNAME('SB2')+" WHERE B2_FILIAL='"+xFilial("SB2")+"' AND D_E_L_E_T_ <> '*' AND B2_COD = '" + (cAliasSd2)->D2_COD + "'"
					cQuery := ChangeQuery(cQuery)
					DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliSB2,.F.,.T.)
					while !(cAliSB2)->(Eof ())
						aSaldoIni := CalcEst((cAliSB2)->B2_COD, (cAliSB2)->B2_LOCAL, MV_PAR01-1)
						nSaldoIni += aSaldoIni[1]
						(cAliSB2)->(dbSkip())
					EndDo				
					(cAliSB2)->( DBCloseArea())
					RestArea(aAreaSd)
					lSaldoIni := .F.

				Else	
					cAliSB9 := GetNextAlias()		
					cQuery := "SELECT B9_COD, B9_LOCAL FROM "+RETSQLNAME('SB9')+" WHERE B9_FILIAL='"+xFilial("SB9")+"' AND D_E_L_E_T_ <> '*' AND B9_COD = '" + (cAliasSd2)->D2_COD + "'"
					cQuery := ChangeQuery(cQuery)
					DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliSB9,.F.,.T.)

					aSaldoIni := CalcEst((cAliSB9)->B9_COD, (cAliSB9)->B9_LOCAL, MV_PAR10)
					nSaldoIni := aSaldoIni[1]

					(cAliSB9)->( DBCloseArea())				
					RestArea(aAreaSd)
					lSaldoIni := .F.
				EndIf
			EndIf
			
			#IFNDEF TOP
				DbSelectArea ("SB1")
				SB1->(DbSetOrder (1))
				If !(SB1->(DbSeek (xFilial ("SB1")+(cAliasSd2)->D2_COD)) .And. (SB1->B1_GRUPO>=MV_PAR05) .And. (SB1->B1_GRUPO<=MV_PAR06)) .And. !cMvEstado=="RS"
					(cAliasSd2)->(DbSkip ())
					Loop
				EndIf
				//
				DbSelectArea ("SB5")
				SB5->(DbSetOrder (1))
				If cMvEstado=="RS"
					If !(SB5->(DbSeek (xFilial ("SB5")+(cAliasSd2)->D2_COD+SB5->B5_NRECAGR)))	
						(cAliasSd2)->(DbSkip ())
						Loop
					EndIf
				Else
					If !(SB5->(DbSeek (xFilial ("SB5")+(cAliasSd2)->D2_COD)))
						(cAliasSd2)->(DbSkip ())
						Loop
					EndIf
				EndIf
				//
				DbSelectArea ("SF4")
				SF4->(DbSetOrder (1))
				If !(SF4->(DbSeek (xFilial ("SF4")+(cAliasSd2)->D2_TES))) .And. !(SF4->F4_ESTOQUE=='S')	//TES tem que movimentar estoque
					(cAliasSd2)->(DbSkip ())
					Loop
				EndIf
				//
				cTipProd	:=	AllTrim (SB1->B1_TIPO)
				cDescProd	:=	AllTrim (SB1->B1_DESC)
				cEmbalUm	:=	AllTrim (SB1->B1_UM)
				If cMvEstado=="RS"
					cNUMNF  := AllTrim ((cAliasSd2)->D2_DOC)
					cComFor := IIf((cAliasSf2)->F2_TIPO == "D" .Or. (cAliasSf2)->F2_TIPO == "B",AllTrim(SA2->A2_NOME),AllTrim(SA1->A1_NOME))
					cEndCF  := IIf((cAliasSf2)->F2_TIPO == "D" .Or. (cAliasSf2)->F2_TIPO == "B",AllTrim(SA2->A2_END),AllTrim(SA1->A1_END))

					If lD2_NRECAGR .And. !Empty((cAliasSd2)->(D2_NRECAGR))
						cNRecAgr	:=	AllTrim ((cAliasSd2)->(D2_NRECAGR))
					EndIf

					cDATA		:= StrZero(Day((cAliasSf2)->F2_EMISSAO),2)+"/"+StrZero(Month((cAliasSf2)->F2_EMISSAO),2)+"/"+StrZero(Year((cAliasSf2)->F2_EMISSAO),4)
					nQtdCom		:= (cAliasSd2)->D2_QUANT
					cIngAtv		:= Alltrim(SB5->(FieldGet (ColumnPos (aCamposb5[2,1]))))
					cForcao		:= Alltrim(SB5->(FieldGet (ColumnPos (aCamposb5[3,1]))))
					cClasse		:= Alltrim(SB5->(FieldGet (ColumnPos (aCamposb5[4,1]))))
					cConcen		:= Alltrim(SB5->(FieldGet (ColumnPos (aCamposb5[5,1]))))
					cUnidade	:= (cAliasSd2)->D2_UM
				Else

					If lD2_NRECAGR .And. !Empty((cAliasSd2)->(D2_NRECAGR))
						cPrincAtv	:=	AllTrim ((cAliasSd2)->(D2_NRECAGR))
					Else
						cPrincAtv	:=	AllTrim (SB5->(FieldGet (FieldPos (aCamposb5[1,1]))))
					EndIf

					nPercPAtv	:=	SB5->(FieldGet (ColumnPos (aCamposb5[2,1])))
					cClToxico	:=	AllTrim (SB5->(FieldGet (ColumnPos (aCamposb5[3,1]))))				
					cTipEmbal	:=	AllTrim (SB5->(FieldGet (ColumnPos (aCamposb5[4,1]))))
				EndIf
				
				If Empty(cPrincAtv) .Or. Empty(cClToxico) .Or. Empty(cTipEmbal) .Or. nPercPAtv == 0
					(cAliasSd2)->(DbSkip ())
					Loop
				Endif
				
			#ELSE
				cTipProd	:=	AllTrim ((cAliasSd2)->B1_TIPO)
				cDescProd	:=	AllTrim ((cAliasSd2)->B1_DESC)
				cEmbalUm	:=	AllTrim ((cAliasSd2)->B1_UM)
				If cMvEstado=="RS"
					cNUMNF  := AllTrim ((cAliasSd2)->D2_DOC)
					cComFor := IIf((cAliasSf2)->F2_TIPO == "D" .Or. (cAliasSf2)->F2_TIPO == "B",AllTrim(SA2->A2_NOME),AllTrim(SA1->A1_NOME))
					cEndCF  := IIf((cAliasSf2)->F2_TIPO == "D" .Or. (cAliasSf2)->F2_TIPO == "B",AllTrim(SA2->A2_END),AllTrim(SA1->A1_END))
					cMunCF	:= IIf((cAliasSf2)->F2_TIPO == "D" .Or. (cAliasSf2)->F2_TIPO == "B",AllTrim(SA2->A2_MUN),AllTrim(SA1->A1_MUN))
					cEstCF	:= IIf((cAliasSf2)->F2_TIPO == "D" .Or. (cAliasSf2)->F2_TIPO == "B",AllTrim(SA2->A2_EST),AllTrim(SA1->A1_EST))

					If lD2_NRECAGR .And. !Empty((cAliasSd2)->(D2_NRECAGR))
						cNRecAgr	:=	AllTrim ((cAliasSd2)->(D2_NRECAGR))
					EndIf

					cDATA		:= StrZero(Day((cAliasSf2)->F2_EMISSAO),2)+"/"+StrZero(Month((cAliasSf2)->F2_EMISSAO),2)+"/"+StrZero(Year((cAliasSf2)->F2_EMISSAO),4)
					nQtdCom		:= (cAliasSd2)->D2_QUANT
					cIngAtv		:= Alltrim((cAliasSd2)->(FieldGet (ColumnPos (aCamposb5[1,1]))))
					cForcao		:= Alltrim((cAliasSd2)->(FieldGet (ColumnPos (aCamposb5[2,1]))))
					cClasse		:= Alltrim((cAliasSd2)->(FieldGet (ColumnPos (aCamposb5[3,1]))))
					cConcen		:= Alltrim((cAliasSd2)->(FieldGet (ColumnPos (aCamposb5[4,1]))))
					cUnidade	:= (cAliasSd2)->D2_UM
				Else

					If lD2_NRECAGR .And. !Empty((cAliasSd2)->(D2_NRECAGR))
						cPrincAtv	:=	AllTrim ((cAliasSd2)->(D2_NRECAGR))
					Else
						cPrincAtv	:=	AllTrim ((cAliasSd2)->(FieldGet (FieldPos (aCamposb5[1,1]))))
					EndIf
					
					nPercPAtv	:=	(cAliasSd2)->(FieldGet (ColumnPos (aCamposb5[2,1])))
					cClToxico	:=	AllTrim ((cAliasSd2)->(FieldGet (ColumnPos (aCamposb5[3,1])))) 				
					cTipEmbal	:=	AllTrim ((cAliasSd2)->(FieldGet (ColumnPos (aCamposb5[4,1])))) 
				EndIf
			#ENDIF
			//
			If cMvEstado=="RS"
				nSaldoAnt -= (cAliasSd2)->D2_QUANT
			Else
				DbSelectArea ("INV")
				If INV->(DbSeek ((cAliasSd2)->D2_COD))
					nSaldoAnt := INV->QUANT
				EndIf
			EndIf
			//
			If (TRB->(DbSeek(IIF(cMvEstado=="RS",(cAliasSd2)->D2_DOC,"")+(cAliasSd2)->D2_COD)))
				RecLock ("TRB", .F.)
			Else
				RecLock ("TRB", .T.)
					TRB->TRB_CODPRO	:=	(cAliasSd2)->D2_COD
					TRB->TRB_TPPROD	:=	cTipProd
					TRB->TRB_DESCPR	:=	cDescProd
					If cMvEstado=="RS"
						TRB->TRB_NUMNF	:= cNUMNF
						TRB->TRB_COMFOR	:= cComFor
						TRB->TRB_ENDCF	:= cEndCF
						TRB->TRB_MUNCF	:= cMunCF
						TRB->TRB_ESTCF	:= cEstCF
						TRB->TRB_NRECAG	:= cNRecAgr
						TRB->TRB_DATA	:= cDATA
						TRB->TRB_INGATV	:= cIngAtv
						TRB->TRB_FORCAO	:= cForcao
						TRB->TRB_CLASSE	:= cClasse
						TRB->TRB_CONCEN	:= cConcen
						TRB->TRB_UNID	:= cUnidade
					Else
						TRB->TRB_PRIATV	:=	cPrincAtv
						TRB->TRB_PPATV	:=	nPercPAtv
						TRB->TRB_CLTOX	:=	cClToxico
					EndIf
					If cMvEstado=="ES" .And. Len(aDesCla)>0
						For nY :=1 to Len(aDesCla)
							If aDesCla[nY][1]==cClToxico
						   		TRB->TRB_DESCL:=aDesCla[nY][2]
			                EndIf
						Next nY
					Endif
					TRB->TRB_SLDANT	:= nSaldoAnt
					TRB->TRB_SLDATU	:= nSaldoAnt
					TRB->TRB_EMBUM	:= cEmbalUm
					If !cMvEstado=="RS"
						TRB->TRB_EMBTP	:=	cTipEmbal
					EndIf
			EndIf

			If cMvEstado=="ES"
				 //Verificar se é Devolução, Usuario Final ou Comerc.
				 If (cAliasSf2)->F2_TIPO=="D"
				 	TRB->TRB_DEVOL  +=	(cAliasSd2)->D2_QUANT
				 ElseIf !Empty(cCfopTrans) .And. AllTrim((cAliasSd2)->D2_CF)$cCfopTrans
					TRB->TRB_COMER  +=	(cAliasSd2)->D2_QUANT
				 Else
					TRB->TRB_USUAR  +=	(cAliasSd2)->D2_QUANT
				 EndIf
			Elseif cMvEstado=="MG" .OR. cMvEstado=="SC"
			 	 //Verificar se é Devolução, Usuario Final ou Comerc.
				 If (cAliasSf2)->F2_TIPO=="D"
				 	TRB->TRB_DEVOL  +=	(cAliasSd2)->D2_QUANT
				 ElseIf  SA1->A1_TIPO="F"
					TRB->TRB_USUAR  +=	(cAliasSd2)->D2_QUANT
				 Else
					TRB->TRB_COMER  +=	(cAliasSd2)->D2_QUANT
				 EndIf
			ElseIf cMvEstado=="RS"
				TRB->TRB_QTDCOM	+= nQtdCom * (-1)
				
				TRB->TRB_ESTOQ	-= nQtdCom - nSaldoIni
			EndIf
					TRB->TRB_SAIDA	+=	(cAliasSd2)->D2_QUANT
					TRB->TRB_SLDATU	-=	(cAliasSd2)->D2_QUANT

				MsUnLock()
			//
			DbSelectArea (cAliasSd2)
			(cAliasSd2)->(DbSkip())
		EndDo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apago arquivo trabalho SD2.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea (cAliasSd2)
		(cAliasSd2)->(DbCloseArea ())
		#IFNDEF TOP
			Ferase (cArqSd2+GetDBExtension ())
			Ferase (cArqSd2+OrdBagExt ())
		#ENDIF
		//
		DbSelectArea (cAliasSf2)
		(cAliasSf2)->(DbSkip ())
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apago arquivo trabalho SF2.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea (cAliasSf2)
	(cAliasSf2)->(DbCloseArea ())
	#IFNDEF TOP
		Ferase (cArqSf2+GetDBExtension ())
		Ferase (cArqSf2+OrdBagExt ())
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criando o registro para os produtos que nao tiveram movimento³
	//³no periodo mas que possuem estoque.                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !cMvEstado=="RS"
		INV->(dbGoTop())
		Do While !INV->(Eof())
			If INV->QUANT > 0
				If !(TRB->(DbSeek(INV->CODIGO)))
					If SB1->(dbSeek(xFilial("SB1")+INV->CODIGO))
						If SB5->(dbSeek(xFilial("SB5")+INV->CODIGO))
							cTipProd	:=	AllTrim (SB1->B1_TIPO)
							cDescProd	:=	AllTrim (SB1->B1_DESC)
							cEmbalUm	:=	AllTrim (SB1->B1_UM)
							If !cMvEstado=="RS"
								cPrincAtv	:=	AllTrim (SB5->(FieldGet (ColumnPos (aCamposb5[1,1]))))
								nPercPAtv	:=	SB5->(FieldGet (ColumnPos (aCamposb5[2,1])))
								cClToxico	:=	AllTrim (SB5->(FieldGet (ColumnPos (aCamposb5[3,1]))))
								cTipEmbal	:=	AllTrim (SB5->(FieldGet (ColumnPos (aCamposb5[4,1]))))
								If Empty(cPrincAtv) .Or. Empty(cClToxico) .Or. Empty(cTipEmbal) .Or. nPercPAtv == 0
									INV->(DbSkip())
									Loop
								Endif
							EndIf
							RecLock("TRB",.T.)
							TRB->TRB_CODPRO	:=	INV->CODIGO
							TRB->TRB_TPPROD	:=	cTipProd
							TRB->TRB_DESCPR	:=	cDescProd
							TRB->TRB_PRIATV	:=	cPrincAtv
							TRB->TRB_PPATV	:=	nPercPAtv
							TRB->TRB_CLTOX	:=	cClToxico
							If cMvEstado=="ES" .And. Len(aDesCla)>0
								For nY :=1 to Len(aDesCla)
									If aDesCla[nY][1]==cClToxico
								   		TRB->TRB_DESCL:=aDesCla[nY][2]
					                EndIf
								Next nY
							Endif
							TRB->TRB_SLDANT	:=	INV->QUANT
							TRB->TRB_EMBUM	:=	cEmbalUm
							If !cMvEstado=="RS"
								TRB->TRB_EMBTP	:=	cTipEmbal
							EndIf
							TRB->TRB_SLDATU	:=	INV->QUANT
							TRB->TRB_ENTRAD	:=	0
							TRB->TRB_SLDATU	:=	INV->QUANT
							TRB->TRB_COMER  :=	0
							TRB->TRB_USUAR  :=	0
							TRB->TRB_DEVOL	:=	0
							MsUnLock()
		                Endif
		     		Endif
		        Endif
		    Endif
			INV->(dbskip())
		Enddo
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apagando o TRB gerado para inventario.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea ("INV")
	INV->(DbCloseArea ())
	Ferase (cArqIndINV+GetDBExtension ())
	Ferase (cArqIndINV+OrdBagExt ())
Return (aRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AjustaSX1  ³ Autor ³Gustavo G. Rueda    ³ Data ³ 03/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica a existencia dos parametros e validas os campos    ³±±
±±³          ³ da tabela SB5 neles referenciados.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 -> Array a ser armazenados os nomes dos campos.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> Flag de continuacao de execucao das demais rotinas. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATR936                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R936CmpPar (aCamposB5)
	Local	lRet	:=	.T.
	Local	lMVPATIVO	:=	!GetNewPar ("MV_PATIVO", "XXX")=="XXX"	//Campo da tabela SB5 que se relaciona ao Principio ativo do produto exigido pelo relatório.
	Local	lMVPPATIV	:=	!GetNewPar ("MV_PPATIV", "XXX")=="XXX"	//Campo da tabela SB5 que se relaciona ao % Principio ativo do produto exigido pelo relatório.
	Local	lMVCLTOXI	:=	!GetNewPar ("MV_CLTOXI", "XXX")=="XXX"	//Campo da tabela SB5 que se relaciona a classe toxicologica do produto exigido pelo relatório.
	Local	lMVTPEMBA	:=	!GetNewPar ("MV_TPEMBA", "XXX")=="XXX"	//Campo da tabela SB5 que se relaciona ao o Tipo da embalagem do produto exigido pelo relatório.
	Local	cProblema	:=	""
	Local	cSolucao	:=	""
	Local   cMvEstado 	:= SuperGetMv("MV_ESTADO")
	Local 	lNRecAgr	:= 	SB5->(ColumnPos("B5_NRECAGR")) > 0   
	Local 	lIngAtv		:= 	SB5->(ColumnPos("B5_INGATV")) > 0
	Local 	lForcao		:=	SB5->(ColumnPos("B5_FORCAO")) > 0
	Local 	lClasse		:=	SB5->(ColumnPos("B5_CLASSE")) > 0
	Local 	lConcen		:=	SB5->(ColumnPos("B5_CONCEN")) > 0
	Local 	cAreaSB5 	:=  SB5->(GetArea())
	Local   cAreaSM0    :=  SM0->(GetArea())
	
	//
	If !(lMVPATIVO)
		cProblema	:=	STR0045	//"Parâmetro [MV_PATIVO] não encontrado no dicionário de dados."
		cSolucao	:=	STR0046	//"Para que a rotina continue corretamente será necessário criá-lo e definí-lo com um campo da tabela SB5 que indica qual o princípio ativo do produto agrotóxico"
		xMagHelpFis (STR0047, cProblema, cSolucao)	//"Parametro inexistente."
		//
		lRet	:=	.F.	
	Else
		If  !(lMVPPATIV) 
			cProblema	:=	STR0048	//"Parâmetro [MV_PPATIV] não encontrado no dicionário de dados."
			cSolucao	:=	STR0049	//"Para que a rotina continue corretamente será necessário criá-lo e definí-lo com um campo da tabela SB5 que indica qual o percentual de princípio ativo do produto agrotóxico"
			xMagHelpFis (STR0047, cProblema, cSolucao)	//"Parametro inexistente."
			//
			lRet	:=	.F.	
		Else	
			If !(lMVCLTOXI)
				cProblema	:=	STR0050	//"Parâmetro [MV_CLTOXI] não encontrado no dicionário de dados."
				cSolucao	:=	STR0051	//"Para que a rotina continue corretamente será necessário criá-lo e definí-lo com um campo da tabela SB5 que indica qual a classe toxicológica do produto agrotóxico"
				xMagHelpFis (STR0047, cProblema, cSolucao)	//"Parametro inexistente."
				//
				lRet	:=	.F.	
			Else
				If !(lMVTPEMBA)
					cProblema	:=	STR0052	//"Parâmetro [MV_TPEMBA] não encontrado no dicionário de dados."
					cSolucao	:=	STR0053	//"Para que a rotina continue corretamente será necessário criá-lo e definí-lo com um campo da tabela SB5 que indica qual o tipo de embalagem do produto agrotóxico"
					xMagHelpFis (STR0047, cProblema, cSolucao)	//"Parametro inexistente."
					//
					lRet	:=	.F.	 
				EndIf      
			EndIf
		EndIf
	EndIf
	//
	dbSelectArea("SB5")
	If (lRet) .And. !cMvEstado=="RS"
		aAdd (aCamposB5,{ SuperGetMv ("MV_PATIVO"),iif(lMVPATIVO,Type(SuperGetMv ("MV_PATIVO")),"C")})
	   	aAdd (aCamposB5,{ SuperGetMv ("MV_PPATIV"),iif(lMVPPATIV,Type(SuperGetMv ("MV_PPATIV")),"C")})
		aAdd (aCamposB5,{ SuperGetMv ("MV_CLTOXI"),iif(lMVCLTOXI,Type(SuperGetMv ("MV_CLTOXI")),"C")})
		aAdd (aCamposB5,{ SuperGetMv ("MV_TPEMBA"),iif(lMVTPEMBA,Type(SuperGetMv ("MV_TPEMBA")),"C")})
		//
		If SB5->(ColumnPos (aCamposB5[1,1]))==0
			cProblema	:=	STR0054+aCamposB5[1,1]+STR0055	//"Campo ["###"] do parâmetro [MV_PATIVO] não encontrado no dicionário de dados."
			cSolucao	:=	STR0056	//"Para que a rotina continue corretamente será necessário criá-lo e alimentá-lo com o princípio ativo do produto agrotóxico"
			xMagHelpFis (STR0105, cProblema, cSolucao)	//"Campo inexistente."
			//
			lRet	:=	.F.	
		Else
			If SB5->(ColumnPos (aCamposB5[2,1]))==0 
				cProblema	:=	STR0054+aCamposB5[2,1]+STR0106	//"Campo ["###"] do parâmetro [MV_PPATIV] não encontrado no dicionário de dados."
				cSolucao	:=	STR0057	//"Para que a rotina continue corretamente será necessário criá-lo e alimentá-lo com o percentual de princípio ativo do produto agrotóxico"
				xMagHelpFis (STR0105, cProblema, cSolucao)	//"Campo inexistente."
				//
				lRet	:=	.F.	
			Else
				If SB5->(ColumnPos (aCamposB5[3,1]))==0
					cProblema	:=	STR0054+aCamposB5[3,1]+STR0107	//"Campo ["###"] do parâmetro [MV_CLTOXI] não encontrado no dicionário de dados."
					cSolucao	:=	STR0058	//"Para que a rotina continue corretamente será necessário criá-lo e alimentá-lo com a classe toxicológica do produto agrotóxico"
					xMagHelpFis (STR0105, cProblema, cSolucao)	//"Campo inexistente."
					//
					lRet	:=	.F.	
				Else
					If SB5->(ColumnPos (aCamposB5[4,1]))==0
						cProblema	:=	STR0054+aCamposB5[4,1]+STR0108	//"Campo ["###"] do parâmetro [MV_TPEMBA] não encontrado no dicionário de dados."
						cSolucao	:=	STR0059	//"Para que a rotina continue corretamente será necessário criá-lo e alimentá-lo tipo de embalagem do produto agrotóxico"
						xMagHelpFis (STR0105, cProblema, cSolucao)	//"Campo inexistente."
						//
						lRet	:=	.F.	
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If cMvEstado=="RS" 
		If lNRecAgr .And. lIngAtv .And. lForcao .And. lClasse .And. lConcen
			//aAdd (aCamposB5, "B5_NRECAGR") 
			aAdd (aCamposB5,{ "B5_INGATV",Type("B5_INGATV")}) 
			aAdd (aCamposB5,{ "B5_FORCAO",Type("B5_FORCAO")}) 
			aAdd (aCamposB5,{ "B5_CLASSE",Type("B5_CLASSE")}) 
			aAdd (aCamposB5,{ "B5_CONCEN",Type("B5_CONCEN")}) 
			lRet := .T.	                 
		Else
			cProblema	:=	STR0054+""+STR0106	//"Campo ["###"] não encontrado no dicionário de dados."
			cSolucao	:=	STR0113	//"Para que a rotina continue corretamente será necessário criá-lo e alimentá-lo no cadastro de Produtos"
			xMagHelpFis (STR0105, cProblema, cSolucao)	//"Campo inexistente."
			lRet	:=	.F.			
		EndIf
	EndIf 
	RestArea(cAreaSB5)	
	RestArea(cAreaSM0)	
Return (lRet)
