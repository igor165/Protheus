#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "FwPrintSetup.Ch" 
#Include "RptDef.Ch" 
#Include "FISR031.ch"  
                                                                                                          
#Define Imp_Spool 2 
#define K_TAB VK_TAB                                                    
#Define cPicture  "@E 999,999,999,999,999,999,999,999,999,999,999,999,999.99"                           
#Define oArial06  TFont():New( "Arial", 10, 10, , .F., , , , .T., .F. )
#Define oArial06N TFont():New( "Arial", 10, 10, , .T., , , , .T., .F. )

/*-------------------------------------------------------------------------------------------------------------------
Função: FISR031

Declaracao de Retencao de Imposto Sobre Servico - DRISS
Decreto Nr. 25.508, de 19 de Janeiro de 2005.

@Retorno ( Nil )

@Author Rodrigo Aguilar
@Since 01/07/2014
@Version 1.0
 
//------------------------------------------------------------------------------------------------------------------*/
Function FISR031()

Local cFilBack      := ""  
Local cPerg         := STR0001 //"FISR031"

Local nForFilial    := 0    
Local nPag  		:= 0  

Local lPreview    := .F.

Local aDevice    	:= {} 
Local aFilsCalc     := {}

Local cSession   	:= GetPrinterSession()
Local cDevice    	:= GetProfString( cSession, "PRINTTYPE", "PDF", .T. )
Local nFlags     	:= PD_ISTOTVSPRINTER + PD_DISABLEORIENTATION + PD_DISABLEPREVIEW + PD_DISABLEPAPERSIZE

Local oSetup     	:= Nil 
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

Private cTitulo  	:= STR0002 //"DECLARACAO_RETENCAO_IMPOSTO" 
Private oPrint	 	:= FWMSPrinter():New( cTitulo, IMP_PDF , .F., , .T., , oSetup )
Private lAbortPrint	:= .F.
Private lVazio	    := .F.  

Private nImprime  := 0

If lVerpesssen
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realizando as configuracoes necessarias para a impressao do ³
	//³relatorio utilizando FWPrintSetup().                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd( aDevice, "DISCO" ) 
	Aadd( aDevice, "SPOOL" ) 
	Aadd( aDevice, "EMAIL" ) 
	Aadd( aDevice, "EXCEL" ) 
	Aadd( aDevice, "HTML"  ) 
	Aadd( aDevice, "PDF"   ) 

	nPrintType := aScan( aDevice,{ |x| x == cDevice } )  

	nLocal     := If( GetProfString( cSession, "LOCAL", "SERVER", .T. ) == "SERVER", 1, 2 )                                                                                                                                                                                                                         
	oSetup 	   := FWPrintSetup():New( nFlags, STR0003 )  //"Declaração de retenção de Imposto"

	oSetup:SetUserParms( {|| Pergunte( cPerg, .T. ) } )  

	oSetup:SetPropert( PD_PRINTTYPE, nPrintType )
	oSetup:SetPropert( PD_ORIENTATION, 1 )
	oSetup:SetPropert( PD_DESTINATION, nLocal )
	oSetup:SetPropert( PD_MARGIN, {60,60,60,60} )
	oSetup:SetPropert( PD_PAPERSIZE, 2 ) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Confirmando a tela de Configuracao eu inicio a Impressao do Relatorio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oSetup:Activate() == PD_OK  	
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Subo asperguntas pro cache caso nao  tenha sido selecionada pelo usuario³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Pergunte( cPerg, .F. )
		
		aFilsCalc := MatFilCalc( MV_PAR01 == 1 )
		
		cFilBack := cFilAnt	
		For nForFilial := 1 To Len( aFilsCalc )	
			If aFilsCalc[ nForFilial, 1 ] 
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Posiciono na Filial de processamento para emitir as informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cFilAnt := aFilsCalc[ nForFilial, 2 ]					
				If SM0->( MsSeek( SM0->M0_CODIGO + cFilAnt ) )  				         		    						
					FPrFISR031( oSetup, @nPag, @lPreview )  				
				EndIf
			EndIf
		Next	
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Volta o posicionamento para a filial inicial do sistema³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cFilAnt := cFilBack		 
		SM0->( MsSeek( SM0->M0_CODIGO + cFilAnt ) )
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso tenha encontrado alguma informacao exibo o relatorio, ³
		//³caso contrario informo ao usuario que nao foram encontradas³
		//³informacoes                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPreview
			oPrint:Preview()	
		Else
			MsgInfo( STR0004 )  //"Não foram encontrados registros para o período selecionado."
			oPrint:Deactivate()  
		EndIf
		
	Else                                                                                                           
		MsgInfo( STR0005 )	//"Relatório cancelado pelo usuário."     
		oPrint:Deactivate()  
	EndIf
EndIf

Return ( Nil )

/*-------------------------------------------------------------------------------------------------------------------
Função: FPrFISR031

Monta a estrutura do relatorio de acordo com os paremtros
informados

@Param   
oSetup   - Objeto com as configuracoes iniciais do Relatorio
nPag     - Numero atual da Pagina   
lPreview - Informa se foram encontradas informacoes para geracao do relatorio

@Retorno ( Nil )

@Author Rodrigo Aguilar
@Since 01/07/2014
@Version 1.0
  
//------------------------------------------------------------------------------------------------------------------*/
Static Function FPrFISR031( oSetup, nPag, lPreview )

Local nLin  := 40  
Local nVia  := Iif( MV_PAR09 <= 0, 1, MV_PAR09 )  

Local cCliente   :=  ""
Local cEnderec   :=  ""
Local cCPF       :=  ""
Local cCNPJ      :=  ""	
Local cNotasFisc :=  ""   
Local cVarAux    :=  ""
Local cDataDe    := MV_PAR06
Local cDataAte   := MV_PAR07 
Local cAlsFin	 := ""
Local aParams	 := {}
Local cCliDe     := MV_PAR02
Local cCliAte    := Iif( !Empty( MV_PAR03 ), MV_PAR03, Replicate( "Z", TamSx3( "A2_COD" )[1]  ) )
Local cLojaDe    := MV_PAR04
Local cLojaAte   := Iif( !Empty( MV_PAR05 ), MV_PAR05, Replicate( "Z", TamSx3( "A2_LOJA" )[1] ) )  
Local aAux		 := {}
Local nPos		 := 0
Local nX		 := 0


Local nValSer    := 0
Local nIssRec    := 0  
Local nAliqIcm   := 0 
Local nlZ        := 0 

Local lPDF       := .F.

Local aFator := {}

Local cAliasQry  := "" 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao do objeto grafico  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:lServer := oSetup:GetProperty( PD_DESTINATION ) == AMB_SERVER                      
oPrint:SetResolution( 75 )
oPrint:SetPortrait()                                                                            	
oPrint:SetPaperSize( DMPAPER_A4 )
oPrint:SetMargin( 60, 60, 60, 60 ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define saida de impressão³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oSetup:GetProperty( PD_PRINTTYPE ) == Imp_Spool  

	oPrint:nDevice := Imp_Spool
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Salva impressora selecionada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	WriteProfString( GetPrinterSession(), "DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T. )  
	oPrint:cPrinter := oSetup:aOptions[PD_VALUETYPE]
	
ElseIf oSetup:GetProperty( PD_PRINTTYPE ) == IMP_PDF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define para salvar o PDF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPrint:nDevice := IMP_PDF	
	oPrint:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
	lPDF := .T.
	
EndIf          

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta e Executa Query para processamento do relatorio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlsFin := ISSFiscal(cDataDe ,cDataAte ,,,,"P")

dbSelectArea(cAlsFin)
(cAlsFin)->(DbGoTop())
(cAlsFin)->(DBCreateIndex("FININDEX1", "CLIFOR+LOJA+PREFIXO"         , {|| PREFIXO+CLIFOR+LOJA  })) // Cria Indice


While (cAlsFin)->( !Eof() ) 

	If (cAlsFin)->LOJA < Alltrim(cLojaDe) .Or. (cAlsFin)->LOJA > Alltrim(cLojaAte) .Or. (cAlsFin)->CLIFOR < Alltrim(cCliDe) .Or.;
		(cAlsFin)->CLIFOR > Alltrim(cCliAte)
		
		(cAlsFin)->(DbSkip())
		Loop
	EndIf	

	aParams := {(cAlsFin)->NUMERO, (cAlsFin)->PREFIXO, (cAlsFin)->CLIFOR, (cAlsFin)->LOJA,  DToS(cDataAte) }

	cAliasQry := FExcQryRel( @lPreview, aParams )

	While (cAliasQry)->( !Eof() )
		
		nAliqICM   :=  (cAliasQry)->F3_ALIQICM	
		
		nPos := aScan(aAux, {|aX| aX[1]+aX[2]+Alltrim(Str(aX[3])) == (cAliasQry)->( A2_COD + A2_LOJA + Alltrim(Str(nAliqICM)))})		

		If nPos <> 0
			aAux[nPos,8]  +=  (cAliasQry)->F3_VALICM  
			aAux[nPos,9]  +=  (cAliasQry)->F3_VALCONT

			If !(Alltrim((cAliasQry)->F3_NFISCAL) $ aAux[nPos,10])
				aAux[nPos,10]  += Alltrim( (cAliasQry)->F3_NFISCAL ) + " ,"
			EndIf

		Else

			cCliente   :=  Alltrim( (cAliasQry)->A2_NOME )
			cEnderec   :=  Alltrim( (cAliasQry)->A2_END ) + " - " + Alltrim( (cAliasQry)->A2_MUN )
			cCPF       :=  Alltrim( Iif( Len( Alltrim( (cAliasQry)->A2_CGC ) ) <= 11, (cAliasQry)->A2_CGC, "" ) )
			cCNPJ      :=  Alltrim( Iif( Len( Alltrim( (cAliasQry)->A2_CGC ) ) > 11,  (cAliasQry)->A2_CGC, "" ) )				
			nIssRec    :=  (cAliasQry)->F3_VALICM  
			nValSer    :=  (cAliasQry)->F3_VALCONT
			cNotasFisc := Alltrim( (cAliasQry)->F3_NFISCAL ) + " ,"

			aAdd (aAux, {})
			nPos :=	Len(aAux)
			aAdd (aAux[nPos], Alltrim((cAliasQry)->A2_COD)) //1
			aAdd (aAux[nPos], Alltrim((cAliasQry)->A2_LOJA)) //2			
			aAdd (aAux[nPos], nAliqICM   ) //3
			aAdd (aAux[nPos], cCliente   ) //4
			aAdd (aAux[nPos], cEnderec   ) //5
			aAdd (aAux[nPos], cCPF       ) //6
			aAdd (aAux[nPos], cCNPJ      ) //7			
			aAdd (aAux[nPos], nIssRec    ) //8
			aAdd (aAux[nPos], nValSer    ) //9
			aAdd (aAux[nPos], cNotasFisc ) //10	
		Endif
		
		(cAliasQry)->( DbSkip() )
	EndDo
	//Fecha tabela ja utilizada
	If Select(cAliasQry) > 0
		(cAliasQry)->(dbCloseArea())
	Endif 

	(cAlsFin)->( DbSkip() )
EndDo

(cAlsFin)->(dbCloseArea())

	
For nX := 1 To len(aAux)  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Guardo as variaveis de controle e impressao do relatorio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nAliqICM   :=  aAux[nX,3]
	cCliente   :=  aAux[nX,4]
	cEnderec   :=  aAux[nX,5]
	cCPF       :=  aAux[nX,6]
	cCNPJ      :=  aAux[nX,7]	
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Iniciando as variaveis de controle utilizadas dentro do laco³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	nIssRec    :=  aAux[nX,8]     
	nValSer    :=  aAux[nX,9]
	cNotasFisc :=  aAux[nX,10]
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Controle de Paginas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPag++			
	
	cNotasFisc := Substr( cNotasFisc, 1, Len( cNotasFisc ) - 1 )	
	
	For nlZ := 1 To nVia 
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Linha Inicial para a impressao³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	nLin  := 40  
		
		oPrint:StartPage()	
								
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Impresao do Cabecalho do relatorio³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cVarAux := STR0006 //"DECRETO Nº 25.508, DE 19 DE JANEIRO DE 2005."
			oPrint:SayAlign( FnLin( @nLin, 0  ), 200, cVarAux , oArial06N, 500, 100 , , 0 )
			
			cVarAux := STR0007 //"ANEXO IX"
			oPrint:SayAlign( FnLin( @nLin, 35 ), 275, cVarAux, oArial06N, 100, 100 , , 0 )
			
			cVarAux := STR0008 //"DECLARAÇÃO DE RETENÇÃO DO IMPOSTO SOBRE SERVIÇOS - DRISS"
			oPrint:SayAlign( FnLin( @nLin, 35 ), 165, cVarAux, oArial06N, 500, 100 , , 0 )
			
			cVarAux := STR0009 + Strzero( nPag, 3 ) //"Nº "
			oPrint:SayAlign( FnLin( @nLin, 35 ), 500, cVarAux, oArial06N, 100, 100 , , 0 )
			
			cVarAux := STR0010 + StrZero( nlZ, 3 ) //"VIA "
			oPrint:SayAlign( FnLin( @nLin, 15 ), 500, cVarAux, oArial06N, 100, 100 , , 0 )
			
			cVarAux := STR0011 //"TOMADOR DO SERVIÇO"
			oPrint:SayAlign( FnLin( @nLin, 45 ), 110, cVarAux, oArial06N, 500, 100 , , 0 )
			
			cVarAux := STR0012  + SM0->M0_NOMECOM //"NOME:   " 
			oPrint:SayAlign( FnLin( @nLin, 35 ), 110, cVarAux, oArial06N, 500, 100 , , 0 )
			
			cVarAux := STR0013  + Iif( !Empty( SM0->M0_CGC ), Transform( SM0->M0_CGC, "@R 99.999.999/9999-99" ), SM0->M0_CGC )                        
			oPrint:SayAlign( FnLin( @nLin, 15 ), 110, cVarAux, oArial06N, 500, 100 , , 0 )
			
			cVarAux := STR0014  + SM0->M0_INSC //"CF/DF:  "
			oPrint:SayAlign( FnLin( @nLin, 0  ), 300, cVarAux, oArial06N, 500, 100 , , 0 )
			
			cVarAux := STR0015 + SM0->M0_ENDENT //"ENDEREÇO: "
			oPrint:SayAlign( FnLin( @nLin, 15 ), 110, 	cVarAux, oArial06N, 500, 100 , , 0 )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Impresao do corpo do relatorio	 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			cVarAux := STR0016 //"Declaro(amos), para fins de comprovação junto à Fazenda Pública do Distrito Federal"  
			oPrint:SayAlign( FnLin( @nLin, 35 ), 150, cVarAux, oArial06, 500, 100 , , 0 )
			
			cVarAux := STR0017 + Alltrim( Transform( nIssRec, cPicture ) ) + " ( " + Lower( Extenso( nIssRec ) ) + " ) "+;
						STR0018 //"que retive(mos) a importância de R$ " ### "relativo ao ISS "
			oPrint:SayAlign( FnLin( @nLin, 12 ), 110, cVarAux, oArial06, 500, 100 , , 0 )
			
			cVarAux := STR0019 + cCliente + STR0020 //"proveniente dos serviços prestados por " ### "com " 
			oPrint:SayAlign( FnLin( @nLin, 12 ), 110, cVarAux, oArial06, 500, 100 , , 0 )
			
			cVarAux := STR0021 + cEnderec + STR0022 + STR0009 + Alltrim(SA2->A2_INSCR) //"endereço " ### "CF/DF " ### Nº
			oPrint:SayAlign( FnLin( @nLin, 12 ), 110, cVarAux, oArial06, 500, 100 , , 0 )   		
	
			cVarAux := STR0023 + Iif(!Empty(cCPF),Transform( cCPF, "@R 999.999.999-99" ),Space(11)) + STR0024 + STR0009 + Iif( !Empty( cCNPJ ), Transform( cCNPJ, "@R 99.999.999/9999-99" ), Space(14) ) + Iif( !lPDF, Space( 07 ), "" ) + STR0025 + Right( DToS( MV_PAR06 ), 2 ) + STR0026 + MesExtenso( Month( MV_PAR06 ) ) + STR0026 + Alltrim( Str( Year( MV_PAR06 ) ) )  //"Nº "     de //"CPF " ### " ou CNPJ" ### " no período de "
			cVarAux += STR0027 + Right( DToS( MV_PAR07 ), 2 ) + STR0026 + MesExtenso( Month( MV_PAR07 ) ) + STR0026 + Alltrim( Str( Year( MV_PAR07 ) ) ) + STR0028
			oPrint:SayAlign( FnLin( @nLin, 12 ), 110, cVarAux, oArial06, 500, 100 , , 0 )   		
			
			cVarAux := STR0034 + cNotasFisc //"Nota(s) Fiscal(is) nº(s) "
			oPrint:SayAlign( FnLin( @nLin, 20 ), 110, cVarAux , oArial06, 340, 100 , , 0 )   		   						
			
			aFator   := FClcFatLin( cVarAux )		   		   		
			cVarAux  := STR0029 + Alltrim( Transform(  nValSer, cPicture ) )
			oPrint:SayAlign( FnLin( @nLin, ( aFator[ 02 ] * 20 ) ), 110,  cVarAux, oArial06, 500, 100 , , 0 )   		   						

			cVarAux := STR0030 + Alltrim( Transform( nAliqICM , cPicture ) ) + " %"
			oPrint:SayAlign( FnLin( @nLin, 20 ), 110,  cVarAux, oArial06, 500, 100 , , 0 )   		   									
			
			cVarAux := STR0031 + DtoC(ddatabase)
			oPrint:SayAlign( FnLin( @nLin, 100 ), 250, cVarAux, oArial06, 500, 100 , , 0 )

			cVarAux := STR0032 //"       ___________________________________"
			oPrint:SayAlign( FnLin( @nLin, 60 ), 205, cVarAux, oArial06, 500, 100 , , 0 )
			
			cVarAux := STR0033 //"     Assinatura ( Tomador do Serviço )"
			oPrint:SayAlign( FnLin( @nLin, 15 ), 225, cVarAux, oArial06, 500, 100 , , 0 )         	
		oPrint:EndPage()                                                                                                           
	Next
next



Return ( Nil )                                    

/*-------------------------------------------------------------------------------------------------------------------
Função: FClcFatLin

Monta e Executa Query para geracao do Relatorio

@Param   
cString - String que sera verificada a quantidade de linhas utilizadas
para a impressao

@Retorno ( aRet )  - Quantidade de Linhas que foram utilizadas para a impressao da informacao

@Author Rodrigo Aguilar
@Since 07/07/2014
@Version 1.0
  
//------------------------------------------------------------------------------------------------------------------*/
Static Function FClcFatLin( cString ) 

Local aRet := Array( 02 )

aRet[01] := Len( cString ) / 96 

If aRet[01] / Int( aRet[01] ) <> 1
	aRet[ 02 ] := Int( aRet[01] ) + 1 
Else
	aRet[ 02 ] := Int( aRet[01] )
EndIf   

aRet[01] := Int ( aRet[01] )

Return ( aRet )

/*-------------------------------------------------------------------------------------------------------------------
Função: FExcQryRel

Monta e Executa Query para geracao do Relatorio

@Param   
lPreview  - Controla se queru teve resultados

@Retorno ( Alias da Query  )

@Author Rodrigo Aguilar
@Since 01/07/2014
@Version 1.0
  
//------------------------------------------------------------------------------------------------------------------*/
Static Function FExcQryRel( lPreview, aParams )

Local cWhere   := ""    
Local cFrom	   := ""
Local nAliq    := MV_PAR08
Local cRet	   := GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtros a serem utilizados na Query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cFrom := RetSQLName("SF1") + " SF1 "
cFrom += "JOIN " + RetSQLName("SF3") + " SF3 ON (SF3.F3_FILIAL = " + ValToSql(xFilial("SF3")) + " AND SUBSTRING( SF3.F3_CFO, 1, 1 ) <= 3 AND SF3.F3_SERIE = SF1.F1_SERIE AND SF3.F3_NFISCAL = SF1.F1_DOC AND SF3.F3_CLIEFOR = SF1.F1_FORNECE AND SF3.F3_LOJA = SF1.F1_LOJA AND "		

If !Empty( nAliq )
	cFrom += "	 SF3.F3_ALIQICM  = '" + Alltrim( Str ( MV_PAR08 ) ) + "' AND "
EndIf    

cFrom += " SF3.F3_TIPO = 'S' AND SF3.D_E_L_E_T_ = ' ') "


cWhere := "SF1.F1_FILIAL = " + ValToSQL(xFilial("SF1")) + " AND "
cWhere += "SF1.F1_DOC = " + ValToSQL(aParams[1]) + " AND "
// Usei o prefixo pois a SE2 não tem a série do documento (deveria ter, já que a SE1 tem). 
// Esta comparação (E2_PREFIXO == F1_SERIE) nunca deveria ser feita, pois o prefixo pode ser
// alterado no parâmetro MV_2DUPREF e não necessariamente será igual ao F1_SERIE.
cWhere += "SF1.F1_PREFIXO = " + ValToSQL(aParams[2]) + " AND "
cWhere += "SF1.F1_FORNECE = " + ValToSQL(aParams[3]) + "  AND "
cWhere += "SF1.F1_LOJA = " + ValToSQL(aParams[4]) + " AND "
cWhere += "SF1.F1_DTDIGIT <= " + ValToSql(aParams[5]) + " AND "
cWhere += "SF1.D_E_L_E_T_ = ' ' "

cWhere := "%"+cWhere+"%"
cFrom := "%"+cFrom+"%"
		
BeginSql Alias cRet    

	SELECT             
		SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SA2.A2_END, SA2.A2_CGC, SA2.A2_MUN,
		SF3.F3_NFISCAL, SF3.F3_SERIE, SF3.F3_ALIQICM, Max( SF3.F3_VALICM ) F3_VALICM, Max( SF3.F3_VALCONT ) F3_VALCONT
	FROM 
		%Exp:cFrom%	 		
		LEFT JOIN %Table:SA2% SA2 ON ( SA2.A2_FILIAL =  %xFilial:SA2%  AND SA2.A2_COD = SF1.F1_FORNECE AND 
										SA2.A2_LOJA = SF1.F1_LOJA AND SA2.%NotDel%   ) 
	WHERE
		%Exp:cWhere%
	GROUP BY
		SA2.A2_COD, SA2.A2_NOME, SA2.A2_LOJA, SA2.A2_END, 
		SA2.A2_CGC, SA2.A2_MUN, SF3.F3_NFISCAL, SF3.F3_SERIE, SF3.F3_ALIQICM   
	ORDER BY
		SA2.A2_COD, SA2.A2_LOJA, SF3.F3_ALIQICM, SF3.F3_NFISCAL, SF3.F3_SERIE
 		
EndSql 

If !lPreview
	If (cRet)->( !Eof() )
		lPreview := .T.
	EndIf
EndIf
	
Return ( cRet )       

/*-------------------------------------------------------------------------------------------------------------------
Funcao FnLin
Controla variavel de impressao da linha do relatorio

@Param:
nLin  - Conteudo da linha atual   
nQtde - Valor a ser somado a linha atual 

@Retorno: nLin - ( Nova linha para impressao )

@Author Rodrigo Aguilar
@Since 01/07/2014
@Version 1.0
-------------------------------------------------------------------------------------------------------------------*/
Static Function FnLin( nLin, nQtde )

nLin += nQtde

Return ( nLin )           
                                                                             
