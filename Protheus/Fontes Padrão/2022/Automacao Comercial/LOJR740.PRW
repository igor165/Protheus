#INCLUDE "REPORT.CH"   
#INCLUDE "LOJR740.CH"

Static cAlias1	:= ""	// Pega o proximo Alias Disponivel
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LOJR740	³ Autor ³ Vendas Crm            ³ Data ³ 16/10/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Relatorio de Movimentos de Vendas Perdidas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LOJR740()
Local oReport	

cAlias1	:= GetNextAlias()	// Pega o proximo Alias Disponivel

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina disponivel a partir do Release 11.5³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !GetRpoRelease("R5")   
	Return NIL
Endif

#IFDEF TOP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("LOJR740",.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ MV_PAR01          // Filial De ?                             ³
	//³ MV_PAR02          // Filial Até ?                            ³
	//³ MV_PAR03          // Loja de ?                               ³
	//³ MV_PAR04          // Loja até ?                              ³
	//³ MV_PAR05          // Vendedor de ?                           ³
	//³ MV_PAR06          // Vendedor até ?                          ³
	//³ MV_PAR07          // Cliente de ?                            ³
	//³ MV_PAR08          // Cliente até ?                           ³
	//³ MV_PAR09          // Produto de?                             ³
	//³ MV_PAR10          // Produto até?                            ³
	//³ MV_PAR11          // Motivo venda perdida de?                ³
	//³ MV_PAR12          // Motivo venda perdida até?               ³
	//³ MV_PAR13          // Data venda perdida de?                  ³
	//³ MV_PAR14          // Data venda perdida até?                 ³
	//³ MV_PAR15          // Tipo de relatório                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A partir da release 12.1.30 os mparâmetros a baixo tiveram   ³
	//³ a ordem alterada											 ³
	//³ MV_PAR03          // Vendedor de ?                           ³
	//³ MV_PAR04          // Vendedor até ?                          ³
	//³ MV_PAR05          // Cliente de ?                            ³
	//³ MV_PAR06          // Loja de ?                               ³
	//³ MV_PAR07          // Cliente até ?                           ³
	//³ MV_PAR08          // Loja até ?                              ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:=LOJR740Def() 
	oReport:PrintDialog() 

#ENDIF	

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LOJR740Def   ³ Autor ³Vendas Crm          ³ Data ³16/10/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina que define os itens que serao apresentados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                       
Static Function LOJR740Def()
Local oReport						//Objeto relatorio TReport (Release 4)
Local oSection1 					//Objeto secao 1 do relatorio (Lista, campos das tabelas SB1) 
//Local cAlias1	:= GetNextAlias()	// Pega o proximo Alias Disponivel
Local cTitulo   := ""				// Titulo do relatorio 

//cAlias1		:= GetNextAlias()						


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TIPO ANALITICO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR15 == 1
	cTitulo := STR0001 //"Relatório de vendas perdidas - Analítico"	
Else
	cTitulo := STR0002//"Relatório de vendas perdidas - Sintético"	
EndIf
oReport := TReport():New("LOJR740",cTitulo,"LOJR740",{|oReport| LOJR740RPT( oReport )}, STR0003 )// "Venda Perdida"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TIPO ANALITICO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR15 == 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define a secao1 do relatorio, informando que o arquivo principal ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1 := TRSection():New( oReport,STR0003,{ "MBR","MBQ","SA1","SA3","SB1" } )	//"Venda Perdida"   
	oSection1 :SetLineStyle()
	                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define as celulas que irao aparecer na secao1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	
	/*Linha 1*/
	TRCell():New(oSection1,"MBR_FILIAL"	,"MBR"	,,,70,,,"LEFT")	  
	TRCell():New(oSection1,"MBR_LOJA"	,"MBR" 	,,,70,,,"LEFT")	  	
	
	/*Linha 2*/
	TRCell():New(oSection1,"A1_NOME"	,"SA1"	,STR0004,,69,,{ || Rtrim((cAlias1)->MBR_CODCLI) + ' - ' + Rtrim((cAlias1)->A1_NOME) },"LEFT")//"Cliente"
	TRCell():New(oSection1,"A1_CGC"		,"SA1"	,,,70,,,"LEFT")	  	
	
	/*Linha 3*/
	TRCell():New(oSection1,"A1_EMAIL"	,"SA1"	,,,70,,,"LEFT")	
	TRCell():New(oSection1,"A3_NOME"	,"SA3"	,STR0005,,70,,,"LEFT")//"Vendedor"
	
	/*Linha 4*/
	TRCell():New(oSection1,"MBR_NUMORC"	,"MBR" 	,,,67,,,"LEFT")			
	TRCell():New(oSection1,"MBR_DOC"	,"MBR"	,STR0012,,70,,{ || Rtrim((cAlias1)->MBR_DOC) + '/' + Rtrim((cAlias1)->MBR_SERIE) },"LEFT")		
	
	/*Linha 5*/
	TRCell():New(oSection1,"MBR_EMISSA"	,"MBR"	,,,69,,,"LEFT")		
	TRCell():New(oSection1,"MBR_ITEM"	,"MBR"	,,,72,,,"LEFT")		
	
	/*Linha 6*/
	TRCell():New(oSection1,"B1_DESC"	,"SB1"	,STR0006,,69, ,{ || Rtrim((cAlias1)->MBR_PROD) + ' - ' + Rtrim((cAlias1)->B1_DESC) },"LEFT")//"Produto"	
	TRCell():New(oSection1,"MBQ_DSCVEP"	,"MBR"	,STR0007,,70, ,{ || Rtrim((cAlias1)->MBR_MOTIVO) + ' - ' + Rtrim((cAlias1)->MBQ_DSCVEP) },"LEFT")//"Motivo" 
	
	/*Linha 7*/
	TRCell():New(oSection1,"MBR_JUSTIF"	,"MBR"	,STR0008,,63, ,,"LEFT")	//"Justificativa"	
	TRCell():New(oSection1,"MBR_AVDISP"	,""		,STR0009,,68, ,{ || Iif((cAlias1)->MBR_AVDISP,STR0013,STR0014)},"LEFT")//Enviar aviso ?"
	
	/*Linha 8*/
	TRCell():New(oSection1,"MBR_DTENAV"	,"MBR"	,STR0015,,70, ,,"LEFT")	//"Data do Aviso"
	
  	
Else  
	
	oReport:SetTotalInLine(.T.)
	oReport:SetLandScape()    
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define a secao1 do relatorio, informando que o arquivo principal ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1 := TRSection():New( oReport,STR0003,{ "MBR","MBQ","SA1","SA3" } )	//"Venda Perdida"   
		                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define as celulas que irao aparecer na secao1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 
	
	TRCell():New(oSection1,"MBQ_DSCVEP"	,STR0007) //"Motivo"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
	TRCell():New(oSection1,"TOTAL"	,STR0010) //"Total de movimentos no periodo"
	
	oSection1:Cell("MBQ_DSCVEP"):SetSize (90)	
	oSection1:Cell("MBQ_DSCVEP"):SetBlock ({ || Rtrim((cAlias1)->MBQ_CODVEP) + ' - ' + Rtrim((cAlias1)->MBQ_DSCVEP) })
	
   	TRFunction():New(oSection1:Cell("TOTAL"),NIL,"SUM",,STR0011,,,.F.)  //"TOTAL DE VENDAS PERDIDAS"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
	
Endif

                    
Return(oReport) 
Return Nil    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LOJR740RPT   ³ Autor ³Leandro Nogueira    ³ Data ³16/10/2010³±±
±±³          ³             ³       ³                    ³      ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina responsavel pela impressao do relatorio              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LOJR740RPT (oReport)
Local oSection1 	:= oReport:Section(1) 		//Objeto secao 1 do relatorio (Lista, campos das tabelas SB1)
Local cFiltro		:= ""   					//String contendo o filtro de busca a ser utilizado com DBF   

Local cVendDe		:= ''
Local cVendAte		:= ''
Local cClienteDe 	:= ''
Local cClienteAte	:= ''
Local cLojaDe		:= ''
Local cLojaAte		:= ''

MakeSqlExpr("LOJR740")      


// Foi alterado a ordem dos parâmetros na release 12.1.30, pois os parâmetros Loja De e Loja Até estavam em posições incorretas
If GetRPORelease() > "12.1.027"
	cVendDe		:= MV_PAR03
	cVendAte	:= MV_PAR04
	cClienteDe 	:= MV_PAR05
	cClienteAte	:= MV_PAR07
	cLojaDe		:= MV_PAR06
	cLojaAte	:= MV_PAR08
Else
	cLojaDe		:= MV_PAR03
	cLojaAte	:= MV_PAR04
	cVendDe		:= MV_PAR05
	cVendAte	:= MV_PAR06
	cClienteDe 	:= MV_PAR07
	cClienteAte	:= MV_PAR08	
EndIf

// FILIAL
If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
	cFiltro += 	" AND (MBR_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "') "           
Endif
		
//VENDEDOR
If !Empty(cVendDe) .OR. !Empty(cVendAte)
	cFiltro += 	" AND (MBR_VEND BETWEEN '" + cVendDe + "' AND '" + cVendAte + "') "           
Endif

//CLIENTE
If !Empty(cClienteDe) .OR. !Empty(cClienteAte)
	cFiltro += 	" AND (MBR_CODCLI BETWEEN '" + cClienteDe + "' AND '" + cClienteAte + "') "           
Endif

//LOJA
If !Empty(cLojaDe) .OR. !Empty(cLojaAte)
	cFiltro += 	" AND (MBR_LOJA BETWEEN '" + cLojaDe + "' AND '" + cLojaAte + "') "           
Endif

//PRODUTO
If !Empty(MV_PAR09) .OR. !Empty(MV_PAR10)
	cFiltro += 	" AND (MBR_PROD BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "') "           
Endif

//MOTIVO
If !Empty(MV_PAR11) .OR. !Empty(MV_PAR12)
	cFiltro += 	" AND (MBR_MOTIVO BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "') "           
Endif

//DATA
If !Empty(MV_PAR13) .OR. !Empty(MV_PAR14)
	cFiltro += 	" AND (MBR_EMISSA BETWEEN '" + DTOS(MV_PAR13) + "' AND '" + DTOS(MV_PAR14) + "') "           
Endif

cFiltro := "%"+cFiltro+"%"
    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa a secao 1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:BeginQuery()	   
	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TIPO ANALITICO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR15 == 1	

	BeginSQL alias cAlias1                          	
		SELECT 	MBR_FILIAL, 
				MBR_LOJA,
				MBR_CODCLI,
				A1_NOME,
				A1_CGC,
				A1_EMAIL,
				MBR_DOC,
				MBR_SERIE,				
				A3_NOME ,
				MBR_NUMORC,
				MBR_EMISSA,
				MBR_PROD,
	   			B1_DESC ,
	   			MBR_ITEM,
	   			MBR_MOTIVO,
	   			MBQ_DSCVEP,
	   			MBR_JUSTIF,
	   		   	MBR_AVDISP,
	   			MBR_DTENAV
	    FROM %table:MBR% MBR
			INNER JOIN %table:SA1% SA1 ON MBR.MBR_CODCLI = SA1.A1_COD AND MBR.MBR_LOJA = SA1.A1_LOJA
			INNER JOIN %table:MBQ% MBQ ON MBR.MBR_MOTIVO = MBQ.MBQ_CODVEP   
			INNER JOIN %table:SA3% SA3 ON MBR.MBR_VEND = SA3.A3_COD 
			INNER JOIN %table:SB1% SB1 ON MBR.MBR_PROD = SB1.B1_COD AND
			SA1.%notDel% AND   
			MBQ.%notDel% AND   
			SB1.%notDel% AND   
			SA3.%notDel%    
	   	WHERE MBR.%notDel% %Exp:cFiltro%
			     
	     ORDER BY MBR_FILIAL, MBR_LOJA
	EndSql   	
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³TIPO SINTETICO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Else
	BeginSQL alias cAlias1                          	
   		SELECT 	
   			MBQ_CODVEP,
   			MBQ_DSCVEP ,
   			COUNT(MBQ_CODVEP) AS TOTAL   			
	    FROM %table:MBR% MBR
			INNER JOIN %table:SA1% SA1 ON MBR.MBR_CODCLI = SA1.A1_COD AND MBR.MBR_LOJA = SA1.A1_LOJA
			INNER JOIN %table:MBQ% MBQ ON MBR.MBR_MOTIVO = MBQ.MBQ_CODVEP   
			INNER JOIN %table:SA3% SA3 ON MBR.MBR_VEND = SA3.A3_COD AND		         
			SA1.%notDel% AND   
			MBQ.%notDel% AND   
			SA3.%notDel%
	   	WHERE MBR.%notDel% %Exp:cFiltro%
   		GROUP BY MBQ_CODVEP,MBQ_DSCVEP		     
	    ORDER BY MBQ_CODVEP
	EndSql  

EndIf    

oSection1:EndQuery() 
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quebra a linha, caso existam muitas colunas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:SetLineBreak()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a impressao dos dados, de acordo com o filtro ou query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:Print()    

Return NIL
