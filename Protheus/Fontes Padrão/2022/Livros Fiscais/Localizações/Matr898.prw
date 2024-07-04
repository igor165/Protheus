#INCLUDE "Protheus.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "MATR898.CH"

/*/               
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATR898     º Autor ³Vendas CRM          º Data ³  19/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Relatorio de status de Pedido de vendas                       º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³06/07/15³PCREQ-4256³Se elimina funcion Mata898CriaSX1() la³±±
±±³            ³        ³          ³hace modificacion a SX1 por motivo de ³±±
±±³            ³        ³          ³adecuacion a fuentes a nuevas estruc- ³±±
±±³            ³        ³          ³turas SX para Version 12.             ³±±
±±³M.Camargo   ³09.11.15³PCREQ-4262³Merge sistemico v12.1.8		           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Matr898()
	Local cPerg := "MATR898"
	Local cAlias := ""
	Static cVar2 := ""
	Static oTotA
	#IFDEF TOP
		cAlias := GetNextAlias()
	#ELSE
		cAlias := "SC9"
	#ENDIF
	
	Pergunte(cPerg, .F.)
	
	//Relatório
	DEFINE REPORT oReport NAME "Matr898" TITLE STR0003 PARAMETER cPerg ACTION {|oReport| PrintReport(oReport, cPerg, cAlias)} //"Relatório de Pedidos de Vendas"
	
	//Sessão
 	DEFINE SECTION oPedVend OF oReport TITLE STR0004 TABLES "AGL" BREAK HEADER LINE BREAK  //"Pedidos de Vendas"
	
	//Celulas
	DEFINE CELL NAME "C5_CATPV"		OF oPedVend ALIAS "SC5" SIZE TAMSX3("C5_CATPV")[1] LINE BREAK
	DEFINE CELL NAME "C5_NUM"		OF oPedVend ALIAS "SC5"	SIZE TAMSX3("C5_NUM")[1] LINE BREAK
	DEFINE CELL NAME "C5_EMISSAO"	OF oPedVend ALIAS "AGL"	SIZE TAMSX3("C5_EMISSAO")[1] LINE BREAK	
	DEFINE CELL NAME "C5_CLIENTE"	OF oPedVend ALIAS "SC5"	SIZE TAMSX3("C5_CLIENTE")[1] LINE BREAK
	DEFINE CELL NAME "A1_NOME"		OF oPedVend ALIAS "SA1"	SIZE TAMSX3("A1_NOME")[1] BLOCK {|| POSICIONE('SA1',1,XFILIAL('SA1') + (cAlias)->C5_CLIENTE, 'A1_NOME')} LINE BREAK
	DEFINE CELL NAME "nQTDPROD"		OF oPedVend TITLE STR0005 SIZE 6 ALIGN LEFT /*"Quantidade"*/ LINE BREAK
	DEFINE CELL NAME "Kgs"			OF oPedVend TITLE "Kgs" BLOCK {|| ROUND((cAlias)->nPESO,2)} ALIGN LEFT SIZE 10 LINE BREAK
	DEFINE CELL NAME "MOEDA"		OF oPedVend ALIAS "SC5" BLOCK {|| IIF( (cAlias)->C5_MOEDA <>0 , SuperGetMv("MV_MOEDAP"+AllTrim(Str((cAlias)->C5_MOEDA))) , SuperGetMv("MV_MOEDAP1") )} SIZE 10 LINE BREAK
	DEFINE CELL NAME "nPRCTOT" 		OF oPedVend TITLE STR0006 BLOCK {|| Transform(Round((cAlias)->nPRCTOT , 2),PesqPict("SC6","C6_VALOR"))} ALIGN LEFT /*"Vlr Total"*/ SIZE 12 LINE BREAK
	DEFINE CELL NAME "STATUS"		OF oPedVend TITLE "Status" BLOCK {|| MATA898MostraStatus((cAlias)->C5_NUM, (cAlias)->A1_RISCO/*,(cAlias)->A1_COD, (cAlias)->A1_LOJA*/)} SIZE 20 LINE BREAK
	DEFINE CELL NAME "Detalhe"		OF oPedVend TITLE STR0001 BLOCK {|| cVar2} SIZE 30 LINE BREAK

	//Totalizador
	DEFINE FUNCTION oTotA FROM oPedVend:Cell("C5_NUM") OF oPedVend FUNCTION COUNT TITLE STR0002 NO END SECTION //"Quantidade total"
	
	oReport:SetLandscape()
	oReport:PrintDialog()
	
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReportºAutor  ³Vendas CRM         º Data ³  10/01/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Selecao dos itens a serem impressos                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³TMKRXX                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintReport(oReport, cPerg, cAlias)

#IFDEF TOP

	Local cSQL := ""

	MakeSqlExp(cPerg)

	If !Empty(MV_PAR01)//Data De:
		cSQL += "AND C5_EMISSAO >= '" + DToS(MV_PAR01) + "' "
	EndIf

	If !Empty(MV_PAR02)//Data Até:
		cSQL += "AND C5_EMISSAO <= '" + DToS(MV_PAR02) + "' "
	EndIf
	
	If !Empty(MV_PAR03) //Cat PV De
		cSQL += "AND C5_CATPV >= '" + MV_PAR03 + "' "
	EndIf

	If !Empty(MV_PAR04)//Cat PV Ate
		cSQL += "AND C5_CATPV <= '" + MV_PAR04 + "' "
	EndIf
	
	If !Empty(MV_PAR05) //Pedido De
		cSQL += "AND C5_NUM >= '" + MV_PAR05 + "' "
	EndIf

	If !Empty(MV_PAR06)//Pedido Ate
		cSQL += "AND C5_NUM <= '" + MV_PAR06 + "' "
	EndIf

	If !Empty(MV_PAR07)//Cliente De
		cSQL += "AND C5_CLIENTE >= '" + MV_PAR07 + "' "
	EndIf

	If !Empty(MV_PAR09)//Cliente Até
		cSQL += "AND C5_CLIENTE <= '" + MV_PAR09 + "' "
	EndIf
	
	If !Empty(MV_PAR08) //Loja De
		cSQL += "AND C5_LOJACLI >= '" + MV_PAR08 + "' "
	EndIf

	If !Empty(MV_PAR10)//Loja Ate
		cSQL += "AND C5_LOJACLI <= '" + MV_PAR10 + "' "
	EndIf

	cSQL := "%"+cSQL+"%"
	
    //If MV_PAR10 == 1 // 1 = Analitico
		BEGIN REPORT QUERY oReport:Section(1)
			BeginSql Alias cAlias
				SELECT C5_NUM, C5_EMISSAO, C5_CATPV, C5_CLIENTE, C5_MOEDA, 
				SUM(SC6.C6_QTDVEN) AS nQTDPROD, 
				SUM(SC6.C6_QTDVEN * SC6.C6_PRCVEN) AS nPRCTOT,
				SUM(SB1.B1_PESO * SC6.C6_QTDVEN) AS nPESO,
				SA1.A1_COD, SA1.A1_LOJA, SA1.A1_RISCO
				FROM %Table:SC5% SC5
				INNER JOIN %Table:SC6% SC6 ON SC5.C5_NUM = SC6.C6_NUM
				INNER JOIN %Table:SB1% SB1 ON SB1.B1_COD = SC6.C6_PRODUTO
				INNER JOIN %Table:SA1% SA1 ON SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI
				WHERE SC5.C5_FILIAL=%xfilial:SC5% AND SC6.C6_FILIAL=%xfilial:SC6% AND SB1.B1_FILIAL=%xfilial:SB1% AND
				SA1.A1_FILIAL=%xfilial:SA1% AND SC5.%NotDel% AND SC6.%NotDel% AND SB1.%NotDel% AND SA1.%NotDel% %Exp:cSQL%
				GROUP BY SA1.A1_COD,SA1.A1_LOJA,SA1.A1_RISCO,
						 SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_EMISSAO, SC5.C5_NUM, SC5.C5_MOEDA, SC5.C5_DOCGER, SC5.C5_CATPV
				ORDER BY C5_EMISSAO
			EndSql
		END REPORT QUERY oReport:Section(1)
		oReport:Section(1):Print()
		//conout(GetLastQuery()[2])
#ELSE

	MakeAdvplExpr(cPerg)
	dbSelectArea("AGL")
	alert(STR0018)
#ENDIF

Return Nil



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MostraStatus  ºAutor  ³Vendas CRM      º Data ³  10/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o Status dos pedidos de vendas selecionados         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAFAT                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATA898MostraStatus(cNumPed, cA1_RISCO)
Local cStatus := ""
cVar2 := ""

    If SC9->(DbSeek(xFilial("SC9")+cNumPed)) 
    	If SC9->C9_BLCRED == "09"  
			cEstatus		:= STR0032//"Rejeitado"
			If cA1_RISCO == "E"
				cVar2 := STR0018//"MANUAL"
			Else
				cVar2 := STR0019//"Supera Limite de Credito"
			EndIf
	    ElseIf (!Empty(SC9->C9_BLCRED) .AND. SC9->C9_BLCRED <> "10") .AND. cA1_RISCO <> "E"
			cEstatus		:= STR0020//"Análise" ou "Analisis"
			cVar2 := STR0019//"Supera Limite de Credito"
		ElseIf (!Empty(SC9->C9_BLCRED) .AND. SC9->C9_BLCRED <> "10") .AND. cA1_RISCO == "E"
			cEstatus		:= STR0018//"Manual"
			cVar2 := STR0021//"Bloqueio para analise"
		ElseIf SC9->C9_BLCRED == "10"
			IF !Empty(SC9->C9_NFISCAL)
				cStatus		:= STR0022//"Facturado"
			ELSEIF !Empty(SC9->C9_REMITO)
				cEstatus		:= STR0023//"Facturacion"
			ENDIF
			If cA1_RISCO == "A" 
				cVar2 := STR0024 //"Sempre autoriza"
			ElseIf cA1_RISCO == "E"
				cVar2 := STR0018//"Manual"
			Else
				cVar2 := STR0025//"Risco não definido"
			EndIf
        //Control de status "Despacho"
		ElseIf Empty(SC9->C9_BLCRED) .and. Empty(SC9->C9_BLEST) 
			IF Empty(SC9->C9_REMITO) .and. Empty(SC9->C9_NFISCAL)
		        cStatus		:= STR0017//"Aprovado" ou "Despacho"
			ELSEIF !Empty(SC9->C9_NFISCAL) 
				cStatus		:= STR0023//"Facturacion"
			ELSEIF !Empty(SC9->C9_REMITO) 
				cStatus := STR0026//"Remitido"
			EndIf
            If cA1_RISCO == "A"
                	cVar2 := STR0024//"Sempre Autoriza"
			ElseIf cA1_RISCO == "E"
				cVar2 := STR0018//"Manual"
			Else            
				cVar2 := STR0025//"Risco não definido"
			Endif
		
		ElseIf Empty(SC9->C9_BLCRED) .and. !Empty(SC9->C9_BLEST) 
		  cStatus		:= STR0027//"Bloqueado por Estoque"
 		  If cA1_RISCO == "A"
 		  	cVar2 := STR0024//"Sempre autoriza"
		  ElseIf SA1->A1_RISCO == "E"
		  	cVar2 := STR0018//"Manual"
		  Else
			cVar2 := STR0025//"Risco não definido"
		  EndIf
		EndIf    
	Else //no existe en SC9
		If Empty(alltrim(Posicione("SC5",1,xFilial("SC5")+cNumPed,"C5_NOTA")))
		    cStatus	:= STR0028//"Em Carteira"
		    cVar2 :=  STR0029//"Pedido en cartera"
		Else
		    cStatus	:= STR0030//"Residuo"
		    cVar2 := STR0031//"Pedido 100% Elim por Residuo"
		Endif
	EndIf

Return cStatus
