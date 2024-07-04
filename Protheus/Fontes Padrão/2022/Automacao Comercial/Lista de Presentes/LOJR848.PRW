#INCLUDE "Protheus.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "LOJR848.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJR848   ºAutor  ³Microsiga           º Data ³  22/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio de Conta Corrente de Lista de Presentes           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJR848()

Local cPerg  	:= "LOJR848"                							//grupo de pergunte
Local cAlias1	:= GetNextAlias()										//alias do cabeçalho
Local cAlias2	:= GetNextAlias()										//alias para quebras
Local cAlias3	:= GetNextAlias()										//alias da conta corrente
Local cAlias4	:= GetNextAlias()										//alias 
Local cAlias5	:= GetNextAlias()										//alias dos totais
Local lLstPre   := SuperGetMV("MV_LJLSPRE",.T.,.F.) .AND.;            //Valida se a funcionalidade esta ativa
					 IIf(FindFunction("LjUpd78Ok"),LjUpd78Ok(),.F.)
Local oReport  															//Objeto do relatorio
Local oSection1															//Objeto Secao 1
Local oSection2 														//Objeto Secao 2
Local oSection3 														//Objeto Secao 3
Local oSection4 														//Objeto Secao 4
Local oSection5 														//Objeto Secao 5

Local aAuxCmbRg	:= RetSx3Box( Posicione("SX3", 2, PadR("ME4_TIPREG",10), "X3CBox()" ),,, 1 )

If !lLstPre
	MsgAlert(STR0001)//"O recurso de lista de presente não está ativo ou não foi devidamente aplicado e/ou configurado, impossível continuar!"
    Return .F.
Endif

#IFDEF TOP
	
	Pergunte(cPerg,.T.)
	
	//ÚÄÄÄÄÄÄÄÄÄ¿
	//³Relatorio³                                                              
	//ÀÄÄÄÄÄÄÄÄÄÙ	
	oReport:= TReport():New("LOJR848",STR0002, cPerg, {|oReport| PrintReport(oReport, cPerg, cAlias1,cAlias2,cAlias3,cAlias4,cAlias5)})//"Conta Corrente"
	oReport:SetLandscape() //Escolher o padrão de Impressao como Paisagem  	
	
	oReport:nFontBody   := 9
	oReport:nLineHeight := 50
	oReport:cFontBody   := "Arial"
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Sessao 1 - Lista ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1:= TRSection():New(oReport, STR0003)//"Lista"
	oSection1:SetLineStyle(.T.)	
	oSection1:SetHeaderBreak(.T.)
	oSection1:SetPageBreak(.T.)
	
	TRCell():New(oSection1,"ME1_CODIGO"	,,STR0003+Space(20-(Len(STR0003)))+".",,60,,,	"LEFT")//"Lista"	
	TRCell():New(oSection1,"ME1_TIPO"	,,STR0004+Space(20-(Len(STR0004)))+".",,60,,{||LJR848X3Bx((cAlias1)->ME1_TIPO,"ME1_TIPO")},"LEFT")//"Tipo de Lista"		    
	TRCell():New(oSection1,"ME1_NOME"	,,STR0005+Space(20-(Len(STR0005)))+".",,60,,,"LEFT")//"Evento" 		
	TRCell():New(oSection1,"ME1_DTEVEN"	,,STR0006+Space(20-(Len(STR0006)))+".",,60,,,"LEFT")//"Data Evento"		
	TRCell():New(oSection1,"ME1_LOCAL"	,,STR0007+Space(20-(Len(STR0007)))+".",,60,,,"LEFT")//"Local do Evento"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   		
	TRCell():New(oSection1,"ME1_EMISSA"	,,STR0008+Space(20-(Len(STR0008)))+".",,60,,,"LEFT")//"Dt.Abertura Lista" 		
	TRCell():New(oSection1,"A1_NOME"	,,STR0009+Space(20-(Len(STR0009)))+".",,60,,,"LEFT")//"Organizador" 		
	TRCell():New(oSection1,"ME1_STATUS"	,,STR0010+Space(20-(Len(STR0010)))+".",,60,,{||LJR848X3Bx((cAlias1)->ME1_STATUS,"ME1_STATUS")},"LEFT")//"Status"
	TRCell():New(oSection1,"ME1_PBONUS"	,,"Bonus %"+Space(20-(Len('Bonius %')))+".",,60,,,"LEFT")//"BONUS" //FSM
	
	 		   
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Sessao 2 - Participantes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSection2:= TRSection():New(oSection1, STR0011)//"Lista de Presente"		
	
	   	
	   		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Sessao 3 - Quebra ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oSection3:= TRSection():New(oSection1,STR0012)// "Quebra"	
			oSection3:SetLineStyle(.T.)	
			oSection3:SetHeaderBreak(.T.)		                                            
			
			Do Case
				Case MV_PAR12 == 1 //Quebra por Data da Compra
					TRCell():New(oSection3,"ME4_EMISSA"	,,STR0013,,50,.T.,,"LEFT")//"Data da Compra" 		
				Case MV_PAR12 == 2 //Quebra por Tipo de Registro                                                       
					TRCell():New(oSection3,"ME4_TIPREG"	,,STR0014,,50,.T.,{||Iif((cAlias3)->TIPOCD == "1",STR0048,STR0049)},"LEFT") //"Tipo do Registro"		   ///"Crédito","Débito"
				Case MV_PAR12 == 3 //Quebra por Tipo de Movimento
					TRCell():New(oSection3,"ME4_TIPO"	,,STR0015,,50,.T.,{||LJR848TpMv((cAlias3)->ME4_TIPO)},"LEFT")//"Tipo de Movimento" 		
			EndCase
			
							
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Sessao 4 - Conta Corrente ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oSection4:= TRSection():New(oSection3, STR0016)//"Conta Corrente"	
						
				TRCell():New(oSection4,"ME4_EMISSA"	,,STR0017,,27,.T.,,"LEFT") 	//"Dt.Compra"
				TRCell():New(oSection4,"ME4_TIPREG"	,,STR0018,,18,.T.,{||IIf ((cAlias4)->ME4_TIPREG <> "2",STR0048,STR0049)},"LEFT")//"Tp.Registro" 							
				TRCell():New(oSection4,"ME4_TIPO"	,,STR0019,,20,.T.,{||LJR848TpMv((cAlias4)->ME4_TIPO)},"LEFT")//"Tp. Movimento"				
				TRCell():New(oSection4,"ME4_TIPREG"	,,STR0010,,30,.T.,{||LJR848TpRg((cAlias4)->ME4_TIPREG,aAuxCmbRg)},"LEFT")//"Status"
				TRCell():New(oSection4," "      	,,""     ,,08,.T.,{|| IIf((cAlias4)->ME4_TIPTIT="NCC",STR0050," ")},"LEFT")//"Status"		  ///NCC						
				TRCell():New(oSection4,"ME4_ITLST"	,,STR0020,,9,.T.,,"LEFT")//"Item" 				
				TRCell():New(oSection4,"ME2_DESCRI"	,,STR0021,,28,.T.,{||Rtrim((cAlias4)->ME2_PRODUT)+"-"+Rtrim((cAlias4)->ME2_DESCRI)},"LEFT")//"Produto"								
				TRCell():New(oSection4,"ME4_QUANT"	,,STR0022,PesqPict("ME1","ME1_CODIGO"),7,.T.,,	"LEFT",,"LEFT")//"Qtde."
				TRCell():New(oSection4,"ME4_FILMOV"	,,STR0023,,22,.T.,{||(cAlias4)->ME4_FILMOV + "-" + (Posicione("SM0",1,(cAlias4)->ME4_EMPMOV+(cAlias4)->ME4_FILMOV,"M0_FILIAL"))},"LEFT")//"Filial"
												
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Documento                                                                                  ³
				//³Se o Tipo de Credito/Debito for igual a 3(Resgate de credito), retornar os dados do titulo.³
				//³Caso contrario retornar os dados do documento Fiscal/Nao Fiscal.                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				TRCell():New(oSection4,"ME4_DOC"	,,STR0024,,45,.T.,{||Iif((cAlias4)->ME4_TIPO=="3" .AND.(cAlias4)->ME4_TIPREG=="2" ,;
																					STR0025+ ":" + Rtrim((cAlias4)->ME4_NUMORC)+ " , "+STR0026+ ":" + Rtrim((cAlias4)->ME4_NUMTIT),;
																					STR0025+ ":" + Rtrim((cAlias4)->ME4_NUMORC)+ " , "+STR0027+ ":" + Rtrim((cAlias4)->ME4_DOC) + "-" +Rtrim((cAlias4)->ME4_SERIE))},"LEFT")//"Documento"#"Tit."#"Orc."#"Doc."
				
				TRCell():New(oSection4,"ME4_CODCLI"	,,STR0028,,45,.T.,{||Rtrim((cAlias4)->ME4_CODCLI)+" - "+Rtrim((cAlias4)->ME4_NOMCLI)},"LEFT")//"Cliente"									
				TRCell():New(oSection4,"ME4_VALOR"	,,STR0030,,24,.T.,,"RIGHT",,"RIGHT")//"Valor"
				
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Sessao 5 - Totalizadores da Lista ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oSection5:= TRSection():New(oSection1, STR0031)//"Totalizadores"	
					oSection5:SetLineStyle(.T.)	
					//Venda
					TRCell():New(oSection5,"VENDA"		,,Padr(STR0051,30,"_"),PesqPict("ME4","ME4_VALOR"),100,,,"LEFT")//"TOTAL DE VENDA" 
					//Bonus
					TRCell():New(oSection5,"BONUS"		,,Padr(STR0052,30,"_"),PesqPict("ME4","ME4_VALOR"),100,,,"LEFT")//"BONUS" 
					//SubTotal
					TRCell():New(oSection5,"SUBTOTAL"	,,Padr(STR0053,30,"_"),PesqPict("ME4","ME4_VALOR"),100,,{||(cAlias5)->VENDA + (cAlias5)->BONUS},"LEFT")//"SUBTOTAL" 
					//Bloqueado
					TRCell():New(oSection5,"BLOQUEADO"	,,Padr(STR0054,30,"_"),PesqPict("ME4","ME4_VALOR"),100,,,"LEFT")//"CREDITO BLOQUEADO" 
					//Retirado
					TRCell():New(oSection5,"RETIRADO"	,,Padr(STR0055,30,"_"),PesqPict("ME4","ME4_VALOR"),100,,,"LEFT")//"PRODUTO RETIRADO" 
					//Ncc
					TRCell():New(oSection5,"NCC"		,,Padr(STR0056,30,"_"),PesqPict("ME4","ME4_VALOR"),100,,,"LEFT")//"GERACAO NCC" 
					//CancCred
					TRCell():New(oSection5,"CANCCRED"	,,Padr(STR0057,30,"_"),PesqPict("ME4","ME4_VALOR"),100,,,"LEFT")//"CANCELAMENTO DE CREDITO" 
					//Credito Liberado
					TRCell():New(oSection5,"TOTAL"	,,Padr(STR0058,30,"_"),PesqPict("ME4","ME4_VALOR"),100,,{||(cAlias5)->VENDA + (cAlias5)->BONUS - (cAlias5)->BLOQUEADO - (cAlias5)->RETIRADO - (cAlias5)->NCC - (cAlias5)->CANCCRED},"LEFT")//"CREDITO LIBERADO"
					oReport:PrintDialog()
#ELSE
	MsgStop (STR0033)//"Relatório incompatível para este tipo de banco de dados !"
#ENDIF

Return Nil 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReportºAutor  ³Leandro Nogueira   º Data ³  22/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Selecao dos itens a serem impressos                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oReport  - Objeto do Relatório							  º±±
±±º			   cPerg    - Cadastro de Perguntas para o Filtro do Relatórioº±±
±±º			   cAlias1  - Area Para Select da Primeira Seção - Cabeçalho  º±±
±±º			   cAlias2  - Area para Select da Segunda  Seção - Particip.  º±±
±±º			   cAlias3  - Area para Select da Terceira Seção - Categoria  º±±
±±º			   cAlias4  - Area para Select da Quarta   Seção - Produtos	  º±±
±±º			   cAlias5  - Novo Relatorio para as Mensagens dos Convidados º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJR848                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintReport(oReport, cPerg, cAlias1,cAlias2,;
							cAlias3,cAlias4,cAlias5)

Local oSection1 	:= oReport:Section(1)                          			//Define a secao 1 
Local oSection2     := oSection1:Section(1)	         		   				//Define a secao 2
Local oSection3     := oSection1:Section(2)  								//Define a secao 3
Local oSection4     := oSection3:Section(1)									//Define a secao 4
Local oSection5     := oSection1:Section(3)  								//Define a secao 5
Local cQuebra		:= ""													//Query da secao de quebra
Local cFiltro		:= ""													//Filtro de acordo com os parametro informados
Local cSelect3		:= ""													//Select especifico para a secao 3 de a cordo com a quebra escolhida.
Local cOrder4  		:= ""													//Order By da Query especifico para a secao 4
Local cCond4		:= ""													//Condicao da secao 4 de acordo com a quebra utilizada.
Local cCondSub1		:= ""													//Condicao da subquery da secao 1 que retorna o total de movimentos da lista
Local cTipReg		:= ""													//Aramazena o tipo de registro escolhido na tela do pergunte
Local nRow,nCol
Local oFontTotal    := TFont():New("Couriew New" ,0,12,.f.,.T.,0,.f.,0,.F.,.F.)
 
Default	oReport		:= Nil
Default cPerg       := ""
Default cAlias1     := ""
Default cAlias2     := ""
Default cAlias3     := ""
Default cAlias4     := ""
Default cAlias5     := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametro - Filial Origem ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
	cCondSub1+= " AND (ME4_FILMOV BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "') "           
	cCond4+=" AND (ME4_FILMOV BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "') "
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametro - Lista ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(MV_PAR03) .OR. !Empty(MV_PAR04)
	cFiltro += 	" AND (ME1_CODIGO BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "') "           
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametro - Cliente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(MV_PAR05) .OR. !Empty(MV_PAR06)
	cCondSub1+= " AND (ME4_CODCLI BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "') "           
	cFiltro += 	" AND (ME1_CODCLI BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "') "           
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametro - Data do Evento  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(MV_PAR07)
   	cFiltro += " AND ME1_DTEVEN >= '" + DToS(MV_PAR07) + "' "
EndIf
If !Empty(MV_PAR08)
	cFiltro += " AND ME1_DTEVEN <= '" + DToS(MV_PAR08) + "' "
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametro - Data de Abertura da Lista ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(MV_PAR09)
   	cFiltro += " AND ME1_EMISSA >= '" + DToS(MV_PAR09) + "' "
EndIf
If !Empty(MV_PAR10)
	cFiltro += " AND ME1_EMISSA <= '" + DToS(MV_PAR10) + "' "
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametro - Ordem³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case MV_PAR11 == 1 //Data do Movimento
		cOrder4 += " ME4_EMISSA,ME4_ITLST,ME4_SEQ "
	Case MV_PAR11 == 2 //Tipo de Registro
		cOrder4 += " ME4_TIPREG,ME4_ITLST,ME4_SEQ "
	Case MV_PAR11 == 3 //Tipo de Movimento
		cOrder4 += " ME4_TIPO,ME4_ITLST,ME4_SEQ "
	Case MV_PAR11 == 4 //Item da Lista
		cOrder4 += " ME4_ITLST,ME4_SEQ "		
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametro - Quebra³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case MV_PAR12 == 1 //Data de Compra  
		cSelect3+= " ME4_EMISSA "
		cCond4+= " AND ME4_EMISSA = %report_param: (cAlias3)->ME4_EMISSA%"			
	Case MV_PAR12 == 3 //Tipo de Movimento
		cSelect3+= " ME4_TIPO "                                           
		cCond4+= " AND ME4_TIPO = %report_param: (cAlias3)->ME4_TIPO%"
EndCase

cFiltro := "%"+cFiltro+"%"
cSelect3:= "%"+cSelect3+"%"
cOrder4:= "%"+cOrder4+"%"
cCond4:= "%"+cCond4+"%"
cCondSub1:= "%"+cCondSub1+"%"

MakeSqlExpr(cPerg) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 1 - Lista ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEGIN REPORT QUERY oSection1
	BeginSQL alias cAlias1    		    
	    SELECT
			ME1_CODIGO,
			ME1_TIPO,
			ME1_NOME,
			ME1_DTEVEN,
			ME1_LOCAL,
			ME1_EMISSA,
			ME1_PBONUS,
			A1_NOME,
			ME1_STATUS,
			(SELECT COUNT(1) FROM %table:ME4% ME4 WHERE ME4.ME4_CODIGO = ME1.ME1_CODIGO AND ME4.%notDel% %Exp:cCondSub1%) AS CONTMOV
		FROM
			%table:ME1% ME1	
			INNER JOIN %table:SA1% SA1 ON ME1.ME1_CODCLI = SA1.A1_COD AND ME1.ME1_LOJCLI = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = ' '
		WHERE
			ME1.%notDel% %Exp:cFiltro%    					
	EndSql
END REPORT QUERY oSection1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 2 - Participantes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEGIN REPORT QUERY oSection2
	BeginSQL alias cAlias2 		
		SELECT
			MEE_CODLIS,
			MEE_CODATO,
			MEE_NOME,
			ME5_DESCRI	
		FROM
			%table:MEE% MEE	
			INNER JOIN %table:ME5% ME5 ON ME5.ME5_CODIGO = MEE.MEE_CODATO AND ME5.%notDel%
		WHERE
			MEE.%notDel%
			AND MEE.MEE_CODLIS = %report_param: (cAlias1)-> ME1_CODIGO % 		
		ORDER BY MEE.MEE_NOME					
	EndSql
END REPORT QUERY oSection2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 3 - Quebra ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR12 == 2 //Tipo de Registro
	BEGIN REPORT QUERY oSection3
	BeginSQL alias cAlias3 		
		SELECT DISTINCT
			'1' AS TIPOCD				
		FROM 
			%table:ME4% ME4	
		WHERE
			ME4.%notDel% AND ME4_TIPREG IN (1,3,4) AND ME4_CODIGO = %report_param: (cAlias1)->ME1_CODIGO % %Exp:cCondSub1%
		UNION
		SELECT DISTINCT
			'2' AS TIPOCD				
		FROM 
			%table:ME4% ME4	
		WHERE
			ME4.%notDel% AND ME4_TIPREG = 2 AND ME4_CODIGO = %report_param: (cAlias1)->ME1_CODIGO % %Exp:cCondSub1%
		ORDER BY 1
	EndSql
	END REPORT QUERY oSection3
Else
	BEGIN REPORT QUERY oSection3
	BeginSQL alias cAlias3 		
		SELECT DISTINCT
			%Exp:cSelect3%
		FROM 
			%table:ME4% ME4	
		WHERE
			ME4.%notDel% AND ME4_CODIGO = %report_param: (cAlias1)->ME1_CODIGO % %Exp:cCondSub1%
		ORDER BY 1
	EndSql
	END REPORT QUERY oSection3
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 4 - Movimentos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEGIN REPORT QUERY oSection4
	BeginSQL alias cAlias4 			
		SELECT			
			ME4_CODIGO,			
			ME4_EMISSA,
			ME4_TIPREG,
			CASE ME4_TIPO WHEN 1 THEN 'CREDITO' WHEN 2 THEN 'BONUS' WHEN 3 THEN 'NCC' WHEN 4 THEN 'RETIRADO' WHEN 7 THEN 'CANCCRED' END AS ME4_TIPO,		
			ME4_ITLST,
			ME2_PRODUT,
			ME2_DESCRI,
			ME4_QUANT,
			ME4_EMPMOV,
			ME4_FILMOV,			
			ME4_CODCLI,
			ME4_LOJCLI,
			ME4_NOMCLI,			
			ME4_VALOR,
			ME4_TIPTIT,
			ME4_PRFTIT,
			ME4_NUMTIT,
			ME4_DOC,
			ME4_SERIE,
			ME4_SEQ,
			ME1_PBONUS,
			ME4_NUMORC	
		FROM 
			%table:ME4% ME4
			LEFT  JOIN 	%table:ME2% ME2 ON ME2.ME2_CODIGO = ME4.ME4_CODIGO AND ME2.ME2_PRODUT = ME4.ME4_COD AND ME2.%notDel%
			INNER JOIN 	%table:ME1% ME1 ON ME1.ME1_CODIGO = ME4.ME4_CODIGO AND ME1.%notDel%
		WHERE
			ME4.%notDel% AND ( ME4_TIPO = '3' or ME2_CODIGO is not NULL)
						 AND ME4_CODIGO = %report_param:(cAlias1)->ME1_CODIGO % %Exp:cCond4% ORDER BY %Exp:cOrder4%			
			
	EndSql
END REPORT QUERY oSection4

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Secao 5 - Totalizadores ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BEGIN REPORT QUERY oSection5
	BeginSQL alias cAlias5 		
		SELECT
			ME1_CODIGO,			
			(SELECT SUM(ME4_VALOR)
				FROM %table:ME4% ME4 
				WHERE  ME4.ME4_CODIGO = ME1.ME1_CODIGO AND ME4.ME4_FILIAL = ME1.ME1_FILIAL AND ME4_TIPO = '1' AND ME4.%notDel% ) AS VENDA,	
			(SELECT SUM(ME4_VALOR)
				FROM %table:ME4% ME4 
				WHERE  ME4.ME4_CODIGO = ME1.ME1_CODIGO AND ME4.ME4_FILIAL = ME1.ME1_FILIAL AND ME4_TIPO = '2' AND ME4.%notDel% ) AS BONUS,	
			(SELECT SUM(ME4_VALOR)
				FROM %table:ME4% ME4 
				WHERE  ME4.ME4_CODIGO = ME1.ME1_CODIGO AND ME4.ME4_FILIAL = ME1.ME1_FILIAL AND ME4_TIPREG = '3' AND ME4.%notDel% ) AS BLOQUEADO,	
			(SELECT SUM(ME4_VALOR)
				FROM %table:ME4% ME4 
				WHERE  ME4.ME4_CODIGO = ME1.ME1_CODIGO AND ME4.ME4_FILIAL = ME1.ME1_FILIAL AND ME4_TIPO = '4' AND ME4.%notDel% ) AS RETIRADO,	
			(SELECT SUM(ME4_VALOR)
				FROM %table:ME4% ME4 
				WHERE  ME4.ME4_CODIGO = ME1.ME1_CODIGO AND ME4.ME4_FILIAL = ME1.ME1_FILIAL AND ME4_TIPO = '3' AND ME4.%notDel% ) AS NCC,	
			(SELECT SUM(ME4_VALOR)
				FROM %table:ME4% ME4 
				WHERE  ME4.ME4_CODIGO = ME1.ME1_CODIGO AND ME4.ME4_FILIAL = ME1.ME1_FILIAL AND ME4_TIPO = '7' AND ME4.%notDel% ) AS CANCCRED
		FROM
			%table:ME1% ME1				
		WHERE
			ME1.%notDel% AND ME1_CODIGO = %report_param: (cAlias1)->ME1_CODIGO% 
		ORDER BY 1
	EndSql
END REPORT QUERY oSection5

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Controle de impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !oReport:Cancel() .AND. (cAlias1)->(!Eof()) //Regra de impressao
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao houver movimento de conta corrente para ³
	//³a lista da secao 1, não imprime a secao        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If (cAlias1)->CONTMOV > 0 
		//Impressao da secao 1 - cabecalho da Lista 
		oSection1:Init() 
		oSection2:ExecSql() 	
		
		If  !(cAlias2)->(Eof()) 
			oSection1:PrintLine()	
		EndIf
	
		//Impressao da secao 2
		oReport:PrintText(STR0030)//"Participantes:"
		While !oReport:Cancel() .And. !(cAlias2)->(Eof())		
			oReport:PrintText((cAlias2)->MEE_NOME+SPACE(6)+(cAlias2)->ME5_DESCRI)								
		 	(cAlias2)->(DbSkip())	 	 			 			
		End
		oReport:ThinLine()	

		//Impressao da secao 3
		oSection3:ExecSql() 		
		While !oReport:Cancel() .And. !(cAlias3)->(Eof())
			
			oSection3:Init()			   		
			oReport:SkipLine()			
			oSection3:PrintLine()              			
		
			//Impressao da secao 4
			oSection4:ExecSql() 		
			While !oReport:Cancel() .And. !(cAlias4)->(Eof())
				oReport:IncMeter()
				oSection4:Init()			   		
				If MV_PAR12 == 2 //Quebra por Tipo de Registro
					If (cAlias3)->TIPOCD == "1" .AND. (cAlias4)->ME4_TIPREG <> "2" 
						oSection4:PrintLine()              
					ElseIf (cAlias3)->TIPOCD == "2" .AND. (cAlias4)->ME4_TIPREG = "2" 
						oSection4:PrintLine()              				
					EndIf                    
				Else
					oSection4:PrintLine()
				EndIf
				
			 	(cAlias4)->(DbSkip())	 	 			 				 			
			End	
			oSection4:Finish()
			
		 	(cAlias3)->(DbSkip())	 	 			 			
		 	oSection3:Finish()		
		 	oSection1:Finish()
		End	
		
		//Impressao da secao 5 
		oSection5:ExecSql()
		oReport:SkipLine()
		oReport:SkipLine()
		oReport:ThinLine()
		oReport:lBold:=.T. 
		oReport:PrintText(STR0031)//"Totais da Lista de Presente"
		oReport:lBold:=.F. 
		While !oReport:Cancel() .And. !(cAlias5)->(Eof())		
			oSection5:Init()			   		
    		nRow := oReport:Row()
    		nCol := 500
		    oReport:PrintText(Padr(STR0051,30),nRow,5)	    
		    oReport:Say(nRow,nCol,transform((cAlias5)->Venda,PesqPict("ME4","ME4_VALOR")),oFontTotal)	    
			oReport:SkipLine()			
    		nRow := oReport:Row()
		    oReport:PrintText(Padr(STR0052,30),nRow,5)	    
		    oReport:Say(nRow,nCol,transform((cAlias5)->Bonus,PesqPict("ME4","ME4_VALOR")),oFontTotal)	    
			oReport:SkipLine()			
    		nRow := oReport:Row()
		    oReport:PrintText(Padr(STR0053,30),nRow,5)	    
		    oReport:Say(nRow,nCol,transform((cAlias5)->VENDA + (cAlias5)->BONUS,PesqPict("ME4","ME4_VALOR")),oFontTotal)
			oReport:SkipLine()			
    		nRow := oReport:Row()
		    oReport:PrintText(Padr(STR0054,30),nRow,5)	    
		    oReport:Say(nRow,nCol,transform((cAlias5)->BLOQUEADO,PesqPict("ME4","ME4_VALOR")),oFontTotal)
			oReport:SkipLine()			
    		nRow := oReport:Row()
		    oReport:PrintText(Padr(STR0055,30),nRow,5)	    
		    oReport:Say(nRow,nCol,transform((cAlias5)->RETIRADO,PesqPict("ME4","ME4_VALOR")),oFontTotal)   
			oReport:SkipLine()			
    		nRow := oReport:Row()
		    oReport:PrintText(Padr(STR0056,30),nRow,5)	    
		    oReport:Say(nRow,nCol,transform((cAlias5)->NCC,PesqPict("ME4","ME4_VALOR")),oFontTotal)
			oReport:SkipLine()			
    		nRow := oReport:Row()
		    oReport:PrintText(Padr(STR0057,30),nRow,5)	    
		    oReport:Say(nRow,nCol,transform((cAlias5)->CANCCRED,PesqPict("ME4","ME4_VALOR")),oFontTotal)
			oReport:SkipLine()			
    		nRow := oReport:Row()
		    oReport:PrintText(Padr(STR0058,30),nRow,5)	    
		    oReport:Say(nRow,nCol,transform((cAlias5)->VENDA + (cAlias5)->BONUS - (cAlias5)->BLOQUEADO - (cAlias5)->RETIRADO - (cAlias5)->NCC - (cAlias5)->CANCCRED,PesqPict("ME4","ME4_VALOR")),oFontTotal)
			oReport:SkipLine()			
		 	(cAlias5)->(DbSkip()) 	 			 			
		End	
		oSection5:Finish()			
	
		(cAlias1)->(DbSkip())		
		oSection1:Finish()         
	Else
		(cAlias1)->(DbSkip())	
	EndIf
End
oSection1:Finish()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJR848X3BxºAutor  ³Leandro Noguira     º Data ³  23/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a descrição do combo box do campo no SX3            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ cCodigo	- Codigo do combo								  º±±
±±º          ³ cCamp	- campo a ser exibido							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJR848                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJR848X3Bx (cCodigo,cCampo)                                       

Local aSX3Box	:= {}	//Array de Opcoes do Combo Box
Local cRet  	:= ""  	//Retorno
Local nPos		:= 0   	//Posicao do array    

Default cCodigo	:= ""
Default cCampo	:= ""

If !Empty(Posicione("SX3", 2, cCampo, "X3CBox()" ))
	aSX3Box	:= RetSx3Box( Posicione("SX3", 2, cCampo, "X3CBox()" ),,, 1 )
	
	nPos := Ascan(aSX3BOX,{|x| x[2]== cCodigo})
	If nPos > 0 
		cRet:= aSX3Box[nPos,3]
	Endif
Endif

If Empty(cRet)
	cRet := cCodigo
Endif

Return Rtrim(cRet)   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJR848TpMvºAutor  ³Leandro Noguira     º Data ³  25/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o tipo de movimento cadastrado na tabel ZI do SX5   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ cCodigo	- Codigo do combo								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJR848                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJR848TpMv (cCodigo)                                       
Local cRet  	:= ""  	//Retorno

Default cCodigo := ""

DbSelectArea( "SX5" )
If DbSeek( xFilial("SX5")+"ZI"+cCodigo )
	cRet:= X5Descri()
EndIf

If Empty(cRet)
	cRet := cCodigo
Endif

Return Rtrim(cRet)      
                        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJR848TpRgºAutor  ³Leandro Noguira     º Data ³  25/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o tipo de movimento cadastrado na tabel ZI do SX5   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ cCodigo	- Codigo do combo								  º±±
±±º          ³ aCmb	    - array para o retorno da descricao               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJR848                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJR848TpRg(cCodigo,aCmb)
Local cRet  	:= ""  	//Retorno
Local nPos      := 0

Default cCodigo := ""
Default aCmb	:={}

//Atualiza o item com a descricao do combo
nPos := Ascan(aCmb,{|x| x[2]== cCodigo})

If nPos > 0 
   cRet:= aCmb[nPos,3]
Endif

Return cRet
