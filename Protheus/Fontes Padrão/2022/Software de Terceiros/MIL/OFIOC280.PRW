// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 10     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "OFIOC280.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOC280 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 23/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Criacao dos PAINEIS ON-LINE  ( Retorna Vetor com DADOS )   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Chamada   ³ OFIOC280( cPref , cTip , cAna , dDtI , dDtF , cEmp , cFil )³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPref =  B-Balcao / O-Oficina / V-Veiculo                  ³±±
±±³          ³ cTip  =  Tipo de Levantamento:   					      ³±±
±±³          ³  - Balcao:  1-Cond.Pagto / 2-Vendedor                      ³±±
±±³          ³  - Oficina: 1-Pec.Srv.Secao / 2-Sit.Tp.Tmp / 3-Qtd OS's    ³±±
±±³          ³  - Veiculo: 1-Grupo / 2-Vendedor                           ³±±
±±³          ³ cAna  =  Analise:                                          ³±±
±±³          ³  - Se Balcao ou Veiculo e cTip = 1 ou 2: 1-Valor / 2-Qtde  ³±±
±±³          ³  - Se Oficina e cTip=3: 1-OS's em aberto / 2-OS's abertas  ³±±
±±³          ³ dDtI  =  Data Inicial ( Default: 01/mes atual/ano atual )  ³±±
±±³          ³ dDtF  =  Data Final ( Default: dDataBase )                 ³±±
±±³          ³ cFil  =  Filial ( Default: SM0->M0_CODFIL )                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Exemplos de chamadas / retorno:

OFIOC280( "B" , "1" , "1" , dDataInicial , dDataFinal , cFilial )
Retorna: {Cond.de Pagto1.Vlr.Pecas,Vlr.Custo,Vlr.Luc.Bruto}
	       ......
         {Cond.de PagtoN.Vlr.Pecas,Vlr.Custo,Vlr.Luc.Bruto}

OFIOC280( "B" , "1" , "2" , dDataInicial , dDataFinal , cFilial )
Retorna: {Cond.de Pagto1.Qtd.NF Balcao}
	       ......
         {Cond.de PagtoN.Qtd.NF Balcao}

OFIOC280( "B" , "2" , "1" , dDataInicial , dDataFinal , cFilial )
Retorna: {Vendedor1,Vlr.Pecas,Vlr.Custo,Vlr.Luc.Bruto}
	       ......
         {VendedorN,Vlr.Pecas,Vlr.Custo,Vlr.Luc.Bruto}

OFIOC280( "B" , "2" , "2" , dDataInicial , dDataFinal , cFilial )
Retorna: {Vendedor1.Qtd.NF Balcao}
	       ......
         {VendedorN.Qtd.NF Balcao}

OFIOC280( "O" , "1" , "1" , dDataInicial , dDataFinal , cFilial )
Retorna: {"Total Geral", Vlr.Total de Pecas + Vlr.Total de Servicos }
         {"   Pecas"     ,  Vlr.Total de Pecas }
         {"   Servicos" ,  Vlr.Total de Servicos }
         {"      Secao1",  Vlr.Secao1 }
         {"      Secao2",  Vlr.Secao2 }
	       ......	
         {"      SecaoN",  Vlr.SecaoN }

OFIOC280( "O" , "2" , "1" , dDataInicial , dDataFinal , cFilial )
Retorna: {"Total Geral", Vlr.Total de Pecas , Vlr.Total de Servicos }
  	      {"   Publico" , Vlr.Publico Pecas  , Vlr.Publico Servicos }
         {"   Garantia", Vlr.Grantia Pecas  , Vlr.Garantia Servicos }
         {"   Interno" , Vlr.Interno Pecas  , Vlr.Interno Servicos }
         {"   Revisao" , Vlr.Revisao Pecas  , Vlr.Revisao Servicos }

OFIOC280( "O" , "3" , "1" , dDataInicial , dDataFinal , cFilial )
Retorna: {"MES / ANO ", Qtd.OS's em Aberto }
	       ......

OFIOC280( "O" , "3" , "2" , dDataInicial , dDataFinal , cFilial )
Retorna: {"MES / ANO ", Qtd.OS's Abertas }
	       ......

OFIOC280( "V" , "1" , "1" , dDataInicial , dDataFinal , cFilial )
Retorna: {Grupo do Modelo1,Vlr.Finaliz.,Vlr.NaoFinaliz.,Vlr.Cancel.}
	       ......
         {Grupo do ModeloN,Vlr.Finaliz.,Vlr.NaoFinaliz.,Vlr.Cancel.}

OFIOC280( "V" , "1" , "2" , dDataInicial , dDataFinal , cFilial )
Retorna: {Grupo do Modelo1,Qtd.Finaliz.,Qtd.NaoFinaliz.,Qtd.Cancel.}
	       ......
         {Grupo do ModeloN,Qtd.Finaliz.,Qtd.NaoFinaliz.,Qtd.Cancel.}

OFIOC280( "V" , "2" , "1" , dDataInicial , dDataFinal , cFilial )
Retorna: {Vendedor1,Vlr.Finaliz.,Vlr.NaoFinaliz.,Vlr.Cancel.}
	       ......
         {VendedorN,Vlr.Finaliz.,Vlr.NaoFinaliz.,Vlr.Cancel.}

OFIOC280( "V" , "2" , "2" , dDataInicial , dDataFinal , cFilial )
Retorna: {Vendedor1,Qtd.Finaliz.,Qtd.NaoFinaliz.,Qtd.Cancel.}
	       ......
         {VendedorN,Qtd.Finaliz.,Qtd.NaoFinaliz.,Qtd.Cancel.}

ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC280(cPref,cTip,cAna,dDtI,dDtF,cFil)
Local cQuery := ""
Local cQPai  := "SQLPAINEL"
Local cQAux  := "SQLAUXILIAR"
Local aRet   := {}
Local nVlr   := 0
Local nPos   := 0
Local ni     := 0
Local cFilSALVA:= cFilAnt
Default cPref:= "B" // Balcao
Default cTip := "1" // Cond.Pagto
Default cAna := "1" // Valor
Default dDtI := ( dDataBase - day(dDataBase) ) + 1 
Default dDtF := dDataBase
Default cFil := cFilAnt
cFilAnt := cFil // Posiciona na Filial da Empresa
Do Case
///////////////   BALCAO   ///////////////
	   Case cPref == "B" // Balcao
			cQuery := "SELECT "
			If cAna == "1" // Analise por Valor
				cQuery += "SF2.F2_VALFAT , SF2.F2_DOC , SF2.F2_SERIE , "
   		EndIf
			If cTip == "1" // Cond.Pagto
				cQuery += "SF2.F2_COND FROM "+RetSqlName("SF2")+" SF2 WHERE "
			Else // cTip == "2" // Vendedor
				cQuery += "SF2.F2_VEND1 FROM "+RetSqlName("SF2")+" SF2 WHERE "
			EndIf
			cQuery += "SF2.F2_FILIAL='"+xFilial("SF2")+"' AND SF2.F2_PREFORI='"+GetNewPar("MV_PREFBAL","BAL")+"' AND "
			cQuery += "SF2.F2_EMISSAO>='"+dtos(dDtI)+"' AND SF2.F2_EMISSAO<='"+dtos(dDtF)+"' AND SF2.D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQPai , .F., .T. )
			Do While !( cQPai )->( Eof() )
				If cTip == "1" // Cond.Pagto
					nPos := aScan(aRet, {|x| left(x[1],3) == ( cQPai )->( F2_COND ) })
					If nPos == 0
						cQuery := "SELECT SE4.E4_DESCRI FROM "+RetSqlName("SE4")+" SE4 WHERE "
						cQuery += "SE4.E4_FILIAL='"+xFilial("SE4")+"' AND SE4.E4_CODIGO='"+( cQPai )->( F2_COND )+"' AND SE4.D_E_L_E_T_=' '"
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAux, .F., .T. )
						If cAna == "1" // Analise por Valor
							Aadd(aRet,{ ( cQPai )->( F2_COND )+" - "+( cQAux )->( E4_DESCRI ) , 0 , 0 , 0 } )
						Else // cAna == "2" // Analise por Qtde.
							Aadd(aRet,{ ( cQPai )->( F2_COND )+" - "+( cQAux )->( E4_DESCRI ) , 0 } )
						EndIf
						( cQAux )->( dbCloseArea() )
						nPos := len(aRet)
					EndIf
				Else // cTip == "2" // Vendedor
					nPos := aScan(aRet, {|x| left(x[1],6) == ( cQPai )->( F2_VEND1 ) })
					If nPos == 0
						cQuery := "SELECT SA3.A3_NOME FROM "+RetSqlName("SA3")+" SA3 WHERE "	
						cQuery += "SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD='"+( cQPai )->( F2_VEND1 )+"' AND SA3.D_E_L_E_T_=' '"
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAux, .F., .T. )
						If cAna == "1" // Analise por Valor
							Aadd(aRet,{ ( cQPai )->( F2_VEND1 )+" - "+( cQAux )->( A3_NOME ) , 0 , 0 , 0 } )
						Else // cAna == "2" // Analise por Qtde.
							Aadd(aRet,{ ( cQPai )->( F2_VEND1 )+" - "+( cQAux )->( A3_NOME ) , 0 } )
						EndIf
						( cQAux )->( dbCloseArea() )
						nPos := len(aRet)
					EndIf
				EndIf
				If nPos > 0
					If cAna == "1" // Analise por Valor
						cQuery := "SELECT SD2.D2_DOC , SD2.D2_SERIE , SUM(SD2.D2_TOTAL) VLR1 , SUM(SD2.D2_CUSTO1) VLR2 FROM "+RetSqlName("SD2")+" SD2 WHERE "
						cQuery += "SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_DOC='"+( cQPai )->( F2_DOC )+"' AND SD2.D2_SERIE='"+( cQPai )->( F2_SERIE )+"' AND "
						cQuery += "SD2.D2_VALISS=0 AND SD2.D_E_L_E_T_=' ' GROUP BY SD2.D2_DOC , SD2.D2_SERIE"
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAux, .F., .T. )
						If ( cQAux )->( VLR1 ) > 0
							aRet[nPos,2] += ( cQAux )->( VLR1 ) // Venda Pecas
							aRet[nPos,3] += ( cQAux )->( VLR2 ) // Custo
							aRet[nPos,4] += ( ( cQAux )->( VLR1 ) - ( cQAux )->( VLR2 ) ) // Lucro Bruto
						EndIf
						( cQAux )->( dbCloseArea() )
					Else // cAna == "2" // Analise por Qtde.
						aRet[nPos,2] += 1
					EndIf
				EndIf
		   	( cQPai )->( DbSkip() )
			EndDo
			( cQPai )->( dbCloseArea() )
			aSort(aRet,1,,{|x,y| x[2] > y[2] })

///////////////   OFICINA   ///////////////
	   Case cPref == "O" // Oficina
			If cTip $ "12"
				cQuery := "SELECT "
				If cTip == "2" // Sit.Tp.Tmp 
					cQuery += "VEC.VEC_TIPTEM , "
				EndIf
				cQuery += "SUM(VEC.VEC_VALVDA) VLR FROM "+RetSqlName("VEC")+" VEC WHERE VEC.VEC_FILIAL='"+xFilial("VEC")+"' AND "
				cQuery += "VEC.VEC_BALOFI='O' AND VEC.VEC_DATVEN>='"+dtos(dDtI)+"' AND VEC.VEC_DATVEN<='"+dtos(dDtF)+"' AND VEC.D_E_L_E_T_=' ' "
				If cTip == "2" // Sit.Tp.Tmp 
					cQuery += "GROUP BY VEC.VEC_TIPTEM"
				EndIf
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQPai , .F., .T. )
				If cTip == "1" // Pecas e Srvcs Secao
					Aadd(aRet,{	STR0001 , ( cQPai )->( VLR ) })
					Aadd(aRet,{	" "+STR0002 , ( cQPai )->( VLR ) })
				Else // cTip == "2" // Sit.Tp.Tmp
					Aadd(aRet,{	STR0001 , 0 , 0 })
					Aadd(aRet,{	" "+STR0004 , 0 , 0 })
					Aadd(aRet,{	" "+STR0005 , 0 , 0 })
					Aadd(aRet,{	" "+STR0006 , 0 , 0 })
					Aadd(aRet,{	" "+STR0007 , 0 , 0 })
					Do While !( cQPai )->( Eof() )
						cQuery := "SELECT VOI.VOI_SITTPO FROM "+RetSqlName("VOI")+" VOI WHERE "	
						cQuery += "VOI.VOI_FILIAL='"+xFilial("VOI")+"' AND VOI.VOI_TIPTEM='"+( cQPai )->( VEC_TIPTEM )+"' AND VOI.D_E_L_E_T_=' '"
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAux, .F., .T. )
		           	nPos := val(( cQAux )->( VOI_SITTPO )) + 1
		           	If nPos >= 2 .and. nPos <= 5
							aRet[1,2]    += ( cQPai )->( VLR )
							aRet[nPos,2] += ( cQPai )->( VLR )
						EndIf
						( cQAux )->( dbCloseArea() )
				   	( cQPai )->( DbSkip() )
					EndDo
				EndIf
				( cQPai )->( dbCloseArea() )
				If cTip == "1" // Pecas e Srvcs Secao
					cQuery := "SELECT VSC.VSC_CODSEC , "
				Else // cTip == "2" // Sit.Tp.Tmp
					cQuery := "SELECT VSC.VSC_TIPTEM , "
				EndIf
				cQuery += "SUM(VSC.VSC_VALSER) VLR FROM "+RetSqlName("VSC")+" VSC WHERE VSC.VSC_FILIAL='"+xFilial("VSC")+"' AND "
				cQuery += "VSC.VSC_DATVEN>='"+dtos(dDtI)+"' AND VSC.VSC_DATVEN<='"+dtos(dDtF)+"' AND VSC.D_E_L_E_T_=' ' GROUP BY "
				If cTip == "1" // Pecas e Srvcs Secao
					cQuery += "VSC.VSC_CODSEC"
				Else // cTip == "2" // Sit.Tp.Tmp
					cQuery += "VSC.VSC_TIPTEM"
				EndIf
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQPai , .F., .T. )
				If cTip == "1" // Pecas e Srvcs Secao			
					Aadd(aRet,{	" "+STR0003 , 0 })
					Do While !( cQPai )->( Eof() )
						nPos := aScan(aRet, {|x| left(x[1],5) == "  "+( cQPai )->( VSC_CODSEC ) })
						If nPos == 0
							cQuery := "SELECT VOD.VOD_DESSEC FROM "+RetSqlName("VOD")+" VOD WHERE "
							cQuery += "VOD.VOD_FILIAL='"+xFilial("VOD")+"' AND VOD.VOD_CODSEC='"+( cQPai )->( VSC_CODSEC )+"' AND VOD.D_E_L_E_T_=' '"
							dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAux, .F., .T. )
							Aadd(aRet,{	left("  "+( cQPai )->( VSC_CODSEC ),5)+" - "+( cQAux )->( VOD_DESSEC ), 0 })
							( cQAux )->( dbCloseArea() )
							nPos := len(aRet)
						EndIf
						aRet[1,2]    += ( cQPai )->( VLR ) // Total
						aRet[3,2]    += ( cQPai )->( VLR ) // Servicos 
	               aRet[nPos,2] += ( cQPai )->( VLR ) // Secao do Servico
				   	( cQPai )->( DbSkip() )
					EndDo
				Else // cTip == "2" // Sit.Tp.Tmp
					Do While !( cQPai )->( Eof() )
						cQuery := "SELECT VOI.VOI_SITTPO FROM "+RetSqlName("VOI")+" VOI WHERE "
						cQuery += "VOI.VOI_FILIAL='"+xFilial("VOI")+"' AND VOI.VOI_TIPTEM='"+( cQPai )->( VSC_TIPTEM )+"' AND VOI.D_E_L_E_T_=' '"
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAux, .F., .T. )
	            	nPos := val(( cQAux )->( VOI_SITTPO )) + 1
	            	If nPos >= 2 .and. nPos <= 5
							aRet[1,3]    += ( cQPai )->( VLR )
							aRet[nPos,3] += ( cQPai )->( VLR )
						EndIf
						( cQAux )->( dbCloseArea() )
				   	( cQPai )->( DbSkip() )
					EndDo
				EndIf
				( cQPai )->( dbCloseArea() )
			Else // cTip == "3" // OS's em aberto e OS's abertas
				cQuery := "SELECT "+FG_CONVSQL("SUBS")+"(VO1.VO1_DATABE,1,6) DTA , COUNT(VO1.VO1_NUMOSV) QTD FROM "+RetSqlName("VO1")+" VO1 WHERE "
				cQuery += "VO1.VO1_FILIAL='"+xFilial("VO1")+"' AND VO1.VO1_DATABE>='"+dtos(dDtI)+"' AND VO1.VO1_DATABE<='"+dtos(dDtF)+"' AND VO1.D_E_L_E_T_=' ' "
            If cAna == "1" // Somente OS's em aberto
					cQuery += "AND VO1.VO1_NUMOSV NOT IN ( SELECT VO2.VO2_NUMOSV FROM "+RetSqlName("VO2")+" VO2 ) "
				EndIf
				cQuery += "GROUP BY "+FG_CONVSQL("SUBS")+"(VO1.VO1_DATABE,1,6)"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQPai , .F., .T. )
				Do While !( cQPai )->( Eof() )
					Aadd(aRet,{	right(( cQPai )->( DTA ),2)+" / "+left(( cQPai )->( DTA ),4) , ( cQPai )->( QTD ) })
			   	( cQPai )->( DbSkip() )
				EndDo
				( cQPai )->( dbCloseArea() )
			EndIf

///////////////   VEICULO   ///////////////
	   Case cPref == "V" // Veiculo
			If cTip == "1" // Grupo do Modelo
				cQuery := "SELECT VV0.VV0_CODMAR , VV0.VV0_GRUMOD , "	
			Else // cTip == "2" // Vendedor
				cQuery := "SELECT VV0.VV0_CODVEN , "
			EndIf
			If cAna == "1" // Analise por Valor
				cQuery += "VV0.VV0_VALMOV , VV0.VV0_ACESSO , VV0.VV0_AGREGA , "
			EndIf
			cQuery += "VV9.VV9_STATUS FROM "+RetSqlName("VV9")+" VV9 INNER JOIN "+RetSqlName("VV0")+" VV0 ON VV9.VV9_NUMATE=VV0.VV0_NUMTRA WHERE "
			cQuery += "VV9.VV9_FILIAL='"+xFilial("VV9")+"' AND VV0.VV0_FILIAL='"+xFilial("VV0")+"' AND "
			cQuery += "VV9.VV9_DATVIS>='"+dtos(dDtI)+"' AND VV9.VV9_DATVIS<='"+dtos(dDtF)+"' AND "
			cQuery += "VV9.VV9_STATUS IN ('F','T','O','R','L','A','P','C','D') AND VV9.D_E_L_E_T_=' ' AND VV0.D_E_L_E_T_=' ' "
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQPai , .F., .T. ) 
			Do While !( cQPai )->( Eof() )
				If ( cQPai )->( VV9_STATUS ) $ "FT" // Finalizados
					ni := 2
				ElseIf ( cQPai )->( VV9_STATUS ) $ "ORLAP" // Nao Finalizados
					ni := 3
				Else // ( cQPai )->( VV9_STATUS ) $ "CD" // Canceladas
					ni := 4
				EndIf
				If cAna == "1" // Analise por Valor
					nVlr := ( cQPai )->( VV0_VALMOV ) + ( cQPai )->( VV0_ACESSO ) + ( cQPai )->( VV0_AGREGA ) // Vlr Movto + Acessorios + Agregados
				Else // cAna == "2" // Analise por Qtde.
	   			nVlr := 1
	   		EndIf
				If cTip == "1" // Grupo do Modelo
					nPos := aScan(aRet, {|x| left(x[1],10) == left(( cQPai )->( VV0_CODMAR )+" "+( cQPai )->( VV0_GRUMOD ),10) })
					If nPos == 0
						cQuery := "SELECT VVR.VVR_DESCRI FROM "+RetSqlName("VVR")+" VVR WHERE VVR.VVR_FILIAL='"+xFilial("VVR")+"' AND "
						cQuery += "VVR.VVR_CODMAR='"+( cQPai )->( VV0_CODMAR )+"' AND VVR.VVR_GRUMOD='"+left(( cQPai )->( VV0_GRUMOD ),6)+"' AND VVR.D_E_L_E_T_=' '"
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAux, .F., .T. )
						Aadd(aRet,{	left(( cQPai )->( VV0_CODMAR )+" "+( cQPai )->( VV0_GRUMOD ),10)+" - "+( cQAux )->( VVR_DESCRI ), 0 , 0 , 0 })
						( cQAux )->( dbCloseArea() )
						nPos := len(aRet)
					EndIf
				Else // cTip == "2" // Vendedor
					nPos := aScan(aRet, {|x| left(x[1],6) == left(( cQPai )->( VV0_CODVEN ),6) })
					If nPos == 0
						cQuery := "SELECT SA3.A3_NOME FROM "+RetSqlName("SA3")+" SA3 WHERE "
						cQuery += "SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD='"+( cQPai )->( VV0_CODVEN )+"' AND SA3.D_E_L_E_T_=' '"
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ),cQAux, .F., .T. )
						Aadd(aRet,{	left(( cQPai )->( VV0_CODVEN ),6)+" - "+( cQAux )->( A3_NOME ), 0 , 0 , 0 })
						( cQAux )->( dbCloseArea() )
						nPos := len(aRet)
					EndIf
				EndIf
				If nPos > 0
					aRet[nPos,ni] += nVlr
				EndIf
		   	( cQPai )->( DbSkip() )
			EndDo
			( cQPai )->( dbCloseArea() )
			aSort(aRet,1,,{|x,y| x[2] > y[2] })
EndCase
cFilAnt := cFilSALVA	
Return(aRet)