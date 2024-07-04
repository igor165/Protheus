#include 'protheus.ch'
#include 'parmtype.ch'
#include 'OGRX020.ch'

/*{Protheus.doc} OGRX020
Gera extrato do contrato para informar o quanto precisa complementar.
@author jean.schulze
@since 16/07/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/
function OGRX020()
	Local oReport	:= Nil
	Local aCmpRoman := {}
	Local aRetRoman := {}
	Local aCmpAvul  := {}
	Local aRetAvul  := {}
	Local aCmpCotc  := {}
	Local aRetCotc  := {}
	
	Private cAliasRom  := Nil
	Private cAliasAvul := Nil
	Private cAliasCotc := Nil
	Private cPergunta := "OGRX020001"
	
	If TRepInUse()

		//Chamada do relatório via OGA290 com parametro preenchido - DAGROCOM-4255
		//Adiona o contrato posicionado na pergunta caso o relatório seja chamado via oga290 - contratos
		If FunName() == 'OGA290'

			SetMVValue("OGRX020001","MV_PAR01",NJR->NJR_CODCTR)

			Pergunte(cPergunta,.F.)	

		Else
			If !Pergunte(cPergunta,.T.)
				Return
			EndIf

		EndIf		
				
		//cria temporaria para gravar as cotações usadas
		aCmpCotc    := {{"N9J_SEQCP"},;	
						{"N9J_SEQPF"},;	
						{"N9J_QTDE"},  ;	
						{"N9J_VENCIM"}, ;	
						{"N9J_VLRTAX"}}	

		aRetCotc    := AGRCRIATRB(,aCmpCotc,{"N9J_SEQCP+N9J_SEQPF"},STR0002,.T.) 
		cAliasCotc  := aRetCotc[4] //ALIAS  
		
		//cria a temporária para gravar os romaneios
		aCmpRoman := {	{"N8T_FILIAL"},;
						{"NJM_DOCNUM"}, ;	
						{"NJM_DOCSER"}, ;		
						{"N8T_CODROM"},;	
						{"N8T_ITEROM"},  ;	
						{"N8T_VALOR"},;	
						{"E1_VALOR"},;
						{"E1_SALDO"},;
						{"E1_VENCTO"},;
						{"E1_BAIXA"},;					
						{"N8T_QTDVNC"}, ;	
						{"N8T_DATCOT"}, ;
						{"NJM_DOCEMI"},;
						{"N8T_MOECOT"}, ;
						{"N8T_TAXCOT"}, ;					
						{"NJM_CODENT"}, ;	
						{"NJM_LOJENT"}, ;
						{"N_FIXAR","N",TamSX3("N9A_VLT2MO")[1],TamSX3("N9A_VLT2MO")[2],PesqPict('N9A',"N9A_VLT2MO"),STR0003}}	

		aRetRoman := AGRCRIATRB(,aCmpRoman,{"N8T_FILIAL+N8T_CODROM+N8T_ITEROM"},STR0001,.T.) 
		cAliasRom := aRetRoman[4] //ALIAS  
		
		//cria temporaria para gravar os dados das notas avulsas -  Complemento / devolução 
		aCmpAvul    := {{"C_TIPO","C",TamSX3("NJJ_TIPO")[1],TamSX3("NJJ_TIPO")[2],PesqPict('N9A',"NJJ_TIPO"),"TIPO"}, ;
						{"N8T_FILIAL"},;	
						{"N8T_CODROM"},;	
						{"N8T_ITEROM"},  ;	
						{"N8T_QTDVNC"}, ;	
						{"N8T_VALOR"},;
						{"NJM_QTDFCO"}, ;	
						{"NJM_DOCNUM"}, ;	
						{"NJM_DOCSER"}, ;	
						{"NJM_CODENT"}, ;	
						{"NJM_LOJENT"}}	

		aRetAvul    := AGRCRIATRB(,aCmpAvul,{"C_TIPO+N8T_FILIAL+NJM_DOCNUM+NJM_DOCSER+NJM_CODENT+NJM_LOJENT"},STR0004,.T.) 
		cAliasAvul  := aRetAvul[4] //ALIAS  
						
		oReport := ReportDef()
		oReport:PrintDialog()
		
		//deleta a tabela temporária
		AGRDELETRB( aRetRoman[4], aRetRoman[3] )  
		AGRDELETRB( aRetAvul[4] , aRetAvul[3] )  
		AGRDELETRB( aRetCotc[4] , aRetCotc[3] )  
	EndIf
	
return .t.

/*{Protheus.doc} ReportDef
Constroi o layout do relatório
@author jean.schulze
@since 20/06/2018
@version 1.0
@return ${return}, ${return_description}

@type function
*/
Static Function ReportDef()
	Local oReport		:= Nil
	Local oSection1		:= Nil
	
	oReport := TReport():New("OGRX020", STR0005, cPergunta, {| oReport | PrintReport( oReport ) }, STR0005) 
	
	oReport:SetTotalInLine( .f. )
	oReport:SetLandScape()	
				
	//exibe os dados do CTR
	oSection1 := TRSection():New( oReport, STR0006, {"NJR", "NJ0", "" }) 
	
	TRCell():New( oSection1, "NJR_CODCTR" , "NJR")
	TRCell():New( oSection1, "NJR_CODENT" , "NJR")
	TRCell():New( oSection1, "NJR_LOJENT" , "NJR")
	TRCell():New( oSection1, "NJ0_NOME"   , "NJ0")
	TRCell():New( oSection1, "NJR_CODPRO" , "NJR")
	TRCell():New( oSection1, "NJR_TIPMER" , "NJR")
	TRCell():New( oSection1, "NJR_MOEDA"  , "NJR")
	TRCell():New( oSection1, "N_MOEDES"   ,  "", STR0025, '@!', 10) //'Desc. Moeda'
	TRCell():New( oSection1, "NJR_QTDCTR" , "NJR")
	TRCell():New( oSection1, "NJR_UMPRC"  , "NJR")
	TRCell():New( oSection1, "NJR_UM1PRO" , "NJR")
	TRCell():New( oSection1, "NJR_CODSAF" , "NJR")
	TRCell():New( oSection1, "NJR_CTREXT" , "NJR")
		
	//lista quebras
		//exibe os dados das regras fiscais
		oSection2 := TRSection():New( oReport, STR0007, {"N9A", ""} ) 
		
		TRCell():New( oSection2, "N9A_CODENT" , "N9A")
		TRCell():New( oSection2, "N9A_LOJENT" , "N9A")
		TRCell():New( oSection2, "N_NOMEENT"  , "" ,STR0026, PesqPict("NJ0","NJ0_NOME"), TamSX3("NJ0_NOME")[1]) //nome
		TRCell():New( oSection2, "N9A_ITEM"   , "N9A")
		TRCell():New( oSection2, "N9A_SEQPRI" , "N9A")
		TRCell():New( oSection2, "N9A_DATINI" , "N9A")
		TRCell():New( oSection2, "N9A_DATFIM" , "N9A")
		TRCell():New( oSection2, "N9A_QUANT " , "N9A")
		TRCell():New( oSection2, "N9A_QTDNF"  , "N9A")
		TRCell():New( oSection2, "N9A_TES"    , "N9A")
		TRCell():New( oSection2, "N9A_TESAUX" , "N9A")
		TRCell():New( oSection2, "N9A_NATURE" , "N9A")
		
		TRCell():New( oSection2, "N_VALORFAT" , "",STR0008, PesqPict("N9A","N9A_VLTFPR"), TamSX3("N9A_VLTFPR")[1])	
		TRCell():New( oSection2, "N_VALORROM" , "",STR0009, PesqPict("N9A","N9A_VLTFPR"), TamSX3("N9A_VLTFPR")[1])			
		TRCell():New( oSection2, "N_COMPLEME" , "",STR0010, PesqPict("N9A","N9A_VLTFPR"), TamSX3("N9A_VLTFPR")[1])	
			
		//exibe as fixações da regra fiscal
		oSection3 := TRSection():New( oReport, STR0011, {"N8D", "NN8"}) 
		
		TRCell():New( oSection3, "N8D_ITEMFX" , "N8D")
		TRCell():New( oSection3, "N8D_VALOR"  , "N8D")
		TRCell():New( oSection3, "N8D_QTDVNC" , "N8D")
		TRCell():New( oSection3, "N8D_QTDFAT" , "N8D")
		oSection3:nLeftMargin := 5
		
		//exibe as condições de pagamento - cotações -  se for MI - Outras moedas
		oSection4 := TRSection():New( oReport, STR0012, cAliasCotc ) 
		
		TRCell():New( oSection4, "N9J_SEQCP" , cAliasCotc)
		TRCell():New( oSection4, "N9J_SEQPF" , cAliasCotc)
		TRCell():New( oSection4, "N9J_QTDE"  , cAliasCotc)
		TRCell():New( oSection4, "N9J_VENCIM", cAliasCotc)
		TRCell():New( oSection4, "N9J_VLRTAX", cAliasCotc)
		oSection4:nLeftMargin := 5
		
		//exibe os romanieios -  com impostos ---  verificar as notas para constar as devoluções
		oSection5 := TRSection():New( oReport, STR0013, cAliasRom) 
	
		TRCell():New( oSection5, "N8T_FILIAL"  , cAliasRom)
		TRCell():New( oSection5, "N8T_CODROM"  , cAliasRom)
		TRCell():New( oSection5, "N8T_ITEROM"  , cAliasRom)
		TRCell():New( oSection5, "NJM_DOCNUM"  , cAliasRom)
		TRCell():New( oSection5, "NJM_DOCSER"  , cAliasRom)
		TRCell():New( oSection5, "NJM_DOCEMI"  , cAliasRom)	
		TRCell():New( oSection5, "N8T_QTDVNC"  , cAliasRom, STR0014)
		TRCell():New( oSection5, "N8T_VALOR"   , cAliasRom)	
		TRCell():New( oSection5, "E1_VALOR"    , cAliasRom)	
		TRCell():New( oSection5, "E1_SALDO"    , cAliasRom)
		TRCell():New( oSection5, "E1_VENCTO"   , cAliasRom)
		TRCell():New( oSection5, "E1_BAIXA"    , cAliasRom)
		TRCell():New( oSection5, "N8T_MOECOT"  , cAliasRom)		
		TRCell():New( oSection5, "N_MOEDES"    , "", STR0025, '@!', 10)
		TRCell():New( oSection5, "N8T_DATCOT"  , cAliasRom)		
		TRCell():New( oSection5, "N8T_TAXCOT"  , cAliasRom)
		oSection5:nLeftMargin := 5
		
		//exibe os complementos de preço		
		oSection6 := TRSection():New( oReport, STR0020, cAliasAvul)  //"Notas de Complemento"
	
		TRCell():New( oSection6, "N8T_FILIAL"  , cAliasAvul)
		TRCell():New( oSection6, "N8T_CODROM"  , cAliasAvul)
		TRCell():New( oSection6, "NJM_DOCNUM"  , cAliasAvul)
		TRCell():New( oSection6, "NJM_DOCSER"  , cAliasAvul)
		TRCell():New( oSection6, "N8T_VALOR"   , cAliasAvul)
		TRCell():New( oSection6, "N8T_QTDVNC"  , cAliasAvul, STR0014)
		TRCell():New( oSection6, "NJM_QTDFCO"  , cAliasAvul)
		TRCell():New( oSection6, "NJM_CODENT"  , cAliasAvul, STR0016)
		TRCell():New( oSection6, "NJM_LOJENT"  , cAliasAvul, STR0017)
		oSection6:nLeftMargin := 5
		
		//exibe as devoluções
		oSection7 := TRSection():New( oReport, STR0021, cAliasAvul) //"Devoluções"
	
		TRCell():New( oSection7, "N8T_FILIAL"  , cAliasAvul)
		TRCell():New( oSection7, "N8T_CODROM"  , cAliasAvul)
		TRCell():New( oSection7, "N8T_ITEROM"  , cAliasAvul)
		TRCell():New( oSection7, "N8T_VALOR"   , cAliasAvul)
		TRCell():New( oSection7, "N8T_QTDVNC"  , cAliasAvul, STR0014)
		TRCell():New( oSection7, "NJM_QTDFCO"  , cAliasAvul)
		TRCell():New( oSection7, "NJM_DOCNUM"  , cAliasAvul)
		TRCell():New( oSection7, "NJM_DOCSER"  , cAliasAvul)
		TRCell():New( oSection7, "NJM_CODENT"  , cAliasAvul, STR0016)
		TRCell():New( oSection7, "NJM_LOJENT"  , cAliasAvul, STR0017)
		oSection7:nLeftMargin := 5
		
		//exibe os romaneios de remessa
		oSection8 := TRSection():New( oReport, STR0022, cAliasAvul) //"Remessas"
	
		TRCell():New( oSection8, "N8T_FILIAL"  , cAliasAvul)
		TRCell():New( oSection8, "N8T_CODROM"  , cAliasAvul)
		TRCell():New( oSection8, "N8T_ITEROM"  , cAliasAvul)
		TRCell():New( oSection8, "N8T_VALOR"   , cAliasAvul)
		TRCell():New( oSection8, "N8T_QTDVNC"  , cAliasAvul, STR0014)
		TRCell():New( oSection8, "NJM_QTDFCO"  , cAliasAvul)
		TRCell():New( oSection8, "NJM_DOCNUM"  , cAliasAvul)
		TRCell():New( oSection8, "NJM_DOCSER"  , cAliasAvul)
		TRCell():New( oSection8, "NJM_CODENT"  , cAliasAvul, STR0016)
		TRCell():New( oSection8, "NJM_LOJENT"  , cAliasAvul, STR0017)
		oSection8:nLeftMargin := 5
		
		//exibe os romaneios de remessa
		oSection9 := TRSection():New( oReport, STR0023, cAliasAvul)  //"Notas de Crédito/Débito"
		
		TRCell():New( oSection9, "NBX_TIPNUM"  , "NBX")
		TRCell():New( oSection9, "NBX_FILNUM"  , "NBX")
		TRCell():New( oSection9, "NBX_NUM"     , "NBX")
		TRCell():New( oSection9, "NBX_PREFIX"  , "NBX")
		TRCell():New( oSection9, "NBX_PARCEL"  , "NBX")		
		TRCell():New( oSection9, "NBX_VALOR"   , "NBX")
		TRCell():New( oSection9, "NBX_DATA"    , "NBX")		
		TRCell():New( oSection9, "NBX_NATURE"  , "NBX")
		TRCell():New( oSection9, "NBX_STATUS"  , "NBX")		
		oSection9:nLeftMargin := 5
				
	//exibe os pagamentos vinculados
	oSection10 := TRSection():New( oReport, STR0018, "N9G" ) 
	
	TRCell():New( oSection10, "N9G_ITEMPV"  , "N9G")
	TRCell():New( oSection10, "N9G_PARPV"   , "N9G")
    TRCell():New( oSection10, "N9G_FILTIT"  , "N9G")
    TRCell():New( oSection10, "N9G_NUM"     , "N9G")
    TRCell():New( oSection10, "N9G_PARTT"   , "N9G")
    TRCell():New( oSection10, "N9G_PREFIX"  , "N9G")
    TRCell():New( oSection10, "N9G_TIPO"    , "N9G")
    TRCell():New( oSection10, "N9G_VALOR"   , "N9G")
    	TRCell():New( oSection10, "N_RAAPLIC" , "",STR0027, PesqPict("N9A","N9A_VLTFPR"), TamSX3("N9A_VLTFPR")[1])	//"RA Aplicado"
	TRCell():New( oSection10, "N_RASALDO" , "",STR0028, PesqPict("N9A","N9A_VLTFPR"), TamSX3("N9A_VLTFPR")[1])	//"RA Saldo"


	//exibe a necessidade de criar mais complementos
	
	//exibe os totalizadores de valores faturados, fixados, pagos, a pagar.
	
Return( oReport )

/*{Protheus.doc} PrintReport
Lista os dados
@author jean.schulze
@since 20/06/2018
@version 1.0
@return ${return}, ${return_description}
@param oReport, object, descricao
@type function
*/
Static Function PrintReport( oReport ) 
	Local oS1		:= oReport:Section( 1 )
	Local oS2		:= oReport:Section( 2 )
	Local oS3		:= oReport:Section( 3 )
	Local oS4		:= oReport:Section( 4 )
	Local oS5		:= oReport:Section( 5 )
	Local oS6		:= oReport:Section( 6 )
	Local oS7		:= oReport:Section( 7 )
	Local oS8		:= oReport:Section( 8 )
	Local oS9		:= oReport:Section( 9 )
	Local oS10		:= oReport:Section( 10 )
	
	Local cCtrSelec	:= MV_PAR01 //Contrato selecionado
		
	If oReport:Cancel()
		Return( Nil )
	EndIf
			
	//Posiciona no contrato				    	
	DbSelectArea( "NJR" )	
	NJR->( dbGoTop() )
	
	if NJR->( dbSeek(FwxFilial("NJR")+cCtrSelec) )
		oS1:Init()

			oS1:Cell( "N_MOEDES"):SetValue(GetMV("MV_MOEDA"+cValToChar(NJR->NJR_MOEDA)))
	
		oS1:PrintLine( )			
		
		//previsões de entrega -  Regra fiscal	    	
		DbSelectArea( "N9A" )	
		N9A->( dbGoTop() )
		
		if N9A->( dbSeek(NJR->(NJR_FILIAL+NJR_CODCTR)) )
				
			While .Not. N9A->( Eof( ) ) .and. alltrim(NJR->(NJR_FILIAL+NJR_CODCTR)) == alltrim(N9A->(N9A_FILIAL+N9A_CODCTR))
				oReport:SkipLine(1)
				oReport:PrintText ( STR0007	,oReport:Row(),10)
				oS2:Init()	
				
				oS2:Cell( "N_NOMEENT"):SetValue(Posicione('NJ0',1,N9A->N9A_FILIAL+N9A_CODENT+N9A_LOJENT,'NJ0_NOME'))
				//calcula os valores da regra fiscal
				aValorCmplt := fCalcNotComp(NJR->NJR_CODCTR, N9A->N9A_ITEM, N9A->N9A_SEQPRI)
				
				//informa os novos dados das regras
				oS2:Cell( "N_COMPLEME"):SetValue(aValorCmplt[1]) //Valor 
				oS2:Cell( "N_VALORFAT"):SetValue(aValorCmplt[2])
				oS2:Cell( "N_VALORROM"):SetValue(aValorCmplt[3])
		
				//exibe as informações da regra fiscal
				oS2:PrintLine( )
				
				//exibe as fixações da regra fiscal
			    if AGRTPALGOD(NJR->NJR_CODPRO)	//não faz algodão, tratar depois
			
			    else
			    	//Lista as Fixações do Negócio
					dbSelectArea('N8D')
					N8D->(dbSetOrder(3)) //Filial+Ctr+PrevEntrega
					If N8D->(dbSeek(N9A->N9A_FILIAL+N9A->N9A_CODCTR+N9A->N9A_ITEM))
						oReport:SkipLine(1)
						oReport:PrintText ( STR0011	,oReport:Row(),80)
						oS3:Init()	
						
						While N8D->(!Eof()) .And. N8D->(N8D_FILIAL+N8D_CODCTR+N8D_CODCAD) == N9A->N9A_FILIAL+N9A->N9A_CODCTR+N9A->N9A_ITEM
							if N9A->N9A_SEQPRI == N8D->N8D_REGRA //somente imprime o que é da regra fiscal
								oS3:PrintLine() // Cotações
							endif
							N8D->(dbSkip())
						EndDo
								
						oS3:Finish()
					EndIf			    	
			    endif
								
				//se é mercado interno - outras moedas -  devemos buscar as cotações
				if NJR->NJR_TIPMER == "1" .and. NJR->NJR_MOEDA > 1 						
					//Lista as Cotações do Negócio
					dbSelectArea(cAliasCotc)
					(cAliasCotc)->( dbGoTop() ) //N9J_FILIAL+N9J_CODCTR+N9J_ITEMPE+N9J_ITEMRF
					If .Not. (cAliasCotc)->( Eof( ) )
						oReport:SkipLine(1)
						oReport:PrintText ( STR0012	,oReport:Row(),80)
						oS4:Init()	
						
						While .Not. (cAliasCotc)->( Eof( ) )
							oS4:PrintLine( ) // Cotações
							(cAliasCotc)->(dbSkip())
						EndDo	
											
						oS4:Finish()
					EndIf										
				endif
				
				//Lista as Entregas da Regra - temos que ir atrás das notas - ou gravar os dados de nota na N8T	
				DbSelectArea( cAliasRom )		
				(cAliasRom)->( dbGoTop() )
				if .Not. (cAliasRom)->( Eof( ) )
					oReport:SkipLine(1)
					oReport:PrintText ( STR0019	,oReport:Row(),80)
					oS5:Init()	

					While .Not. (cAliasRom)->( Eof( ) )
						oS5:Cell( "N_MOEDES"):SetValue(GetMV("MV_MOEDA"+cValToChar((cAliasRom)->N8T_MOECOT)))	
					
						oS5:PrintLine( ) // Entregas	
	 			
						(cAliasRom)->(dbSkip())
					EndDo
					
					oS5:Finish()
				EndIf
				
				//lista notas complementares - devoluções e complementos de preço
				DbSelectArea( cAliasAvul )		
				(cAliasAvul)->( dbGoTop() )
				if (cAliasAvul)->( dbSeek("C") )
					oReport:SkipLine(1)
					oReport:PrintText (STR0024,oReport:Row(),80) //"Complementos"
					oS6:Init()	
					
					While .Not. (cAliasAvul)->( Eof( ) ) .and. (cAliasAvul)->( C_TIPO ) == "C" 
						oS6:PrintLine( ) // Entregas				
						(cAliasAvul)->(dbSkip())
					EndDo
					
					oS6:Finish()
				EndIf
				
				//devoluções
				(cAliasAvul)->( dbGoTop() )
				if (cAliasAvul)->( dbSeek("D") )
					oReport:SkipLine(1)
					oReport:PrintText (STR0021,oReport:Row(),80) //DEVOLUÇÕES
					oS7:Init()	
					
					While .Not. (cAliasAvul)->( Eof( ) ) .and. (cAliasAvul)->( C_TIPO ) == "D" 
						oS7:PrintLine( ) // Entregas				
						(cAliasAvul)->(dbSkip())
					EndDo
					
					oS7:Finish()
				EndIf
				
				//remessas
				(cAliasAvul)->( dbGoTop() )
				if (cAliasAvul)->( dbSeek("R") )
					oReport:SkipLine(1)
					oReport:PrintText (STR0022,oReport:Row(),80) //REMESSAS
					oS8:Init()	
					
					While .Not. (cAliasAvul)->( Eof( ) ) .and. (cAliasAvul)->( C_TIPO ) == "R" 
						oS8:PrintLine( ) // Entregas				
						(cAliasAvul)->(dbSkip())
					EndDo
					
					oS8:Finish()
				EndIf
				
				dbSelectArea('NBX')
				NBX->(dbSetOrder(1)) //N8T_FILCTR+N8T_CODCTR+N8T_CODCAD+N8T_CODREG+TIPPRC
				If NBX->(dbSeek(NJR->NJR_FILIAL+NJR->NJR_CODCTR))
					oReport:SkipLine(1)
					oReport:PrintText ( STR0023 ,oReport:Row(),80) //"Notas de Crédito/Débito"
					oS9:Init()	
					While !Eof() .And. NBX->(NBX_FILIAL+NBX_CODCTR) == NJR->NJR_FILIAL+NJR->NJR_CODCTR  
						if NBX->(NBX_CODCAD+NBX_SEQPRI) == N9A->N9A_ITEM+N9A->N9A_SEQPRI
							oS9:PrintLine( ) // Entregas
						endif				
						NBX->(dbSkip())
					EndDo
					oS9:Finish()
				EndIf
												
				N9A->( dbSkip() )
				
				//finaliza a regra Fiscal
				oS2:Finish()		
			EndDo
			
			
		endif

		//exibe os pagamentos vinculados
		dbSelectArea('N9G')
		N9G->(dbSetOrder(1)) //N8T_FILCTR+N8T_CODCTR+N8T_CODCAD+N8T_CODREG+TIPPRC
		If N9G->(dbSeek(NJR->NJR_FILIAL+NJR->NJR_CODCTR))
			oReport:SkipLine(1)
			oReport:PrintText ( STR0018	,oReport:Row(),10)
			oS10:Init()	
			While N9G->(!Eof()) .And. N9G->(N9G_FILIAL+N9G_CODCTR) == NJR->NJR_FILIAL+NJR->NJR_CODCTR  
				
				nTotal := fCalcRA(N9G->N9G_FILTIT,N9G->N9G_NUM,N9G->N9G_PARTT)
				
				oS10:Cell( "N_RAAPLIC"):SetValue(nTotal)	 
				oS10:Cell( "N_RASALDO"):SetValue(N9G->N9G_VALOR - nTotal) //valor vinculado - valor aplicado

			
				oS10:PrintLine( ) // Entregas				
				N9G->(dbSkip())

			EndDo
			oS10:Finish()
		EndIf
		
		//exibe os totalizadores de valores faturados, fixados, pagos, a pagar.
		//talvez pegar campos do próprio contrato
		
		//finaliza o contrato
		oS1:Finish()	
	endif
	
		
Return .t.
	
/*{Protheus.doc} fCalcNotComp
Calcula a quantidade a ser complementada no contrato
@author jean.schulze
@since 16/07/2018
@version 1.0
@return ${return}, ${return_description}
@param cCodCtr, characters, descricao
@param cCodPrev, characters, descricao
@param cCodRegra, characters, descricao
@type function
*/
Static Function fCalcNotComp(cCodCtr, cCodPrev, cCodRegra)
	Local aAreaNJR   := GetArea("NJR")
	Local aAreaN9A   := GetArea("N9A")
	Local cAliasNJM  := GetNextAlias()
	Local cAliasSD1  := GetNextAlias() //devoluções
	Local cAliasSD2  := GetNextAlias() //complementos
	Local cAliasN9K  := GetNextAlias() //precos
	Local cAliasN8L  := GetNextAlias() //titulos
	Local aDadoRegra := {}
	Local aLstPreco  := {}
	Local nValorAFix := 0
	Local nQtdAFix   := 0
    Local cFilOrg    := N9A->N9A_FILORG
    Local nMoeda     := NJR->NJR_MOEDA
    Local cTes       := N9A->N9A_TES
    Local cNatuFin   := N9A->N9A_NATURE
    Local cTipoMerc  := NJR->NJR_TIPMER
    Local nMoedaFat  := NJR->NJR_MOEDAR 
    Local nDias      := NJR->NJR_DIASR
    Local cUmPrec    := NJR->NJR_UMPRC
    Local cUmProd    := NJR->NJR_UM1PRO 
    Local cCodPro    := NJR->NJR_CODPRO
    Local cCodNgc    := NJR->NJR_CODNGC
    Local cVersao    := NJR->NJR_VERSAO 
    Local cTipoCli   := N9A->N9A_TIPCLI
	Local nValNCCNDC := 0
	
	//verifica o cliente 
	DbSelectArea("NJ0")
	NJ0->(DbSetOrder(1))
	If NJ0->(DbSeek(xFilial("NJ0")+N9A->N9A_CODENT+N9A->N9A_LOJENT))
		if NJR->NJR_TIPO == "1" //Compras - fornecedor
			cCodClient     := NJ0->NJ0_CODFOR
			cCodLoja       := NJ0->NJ0_LOJFOR				
		else //vendas - cliente
			cCodClient     := NJ0->NJ0_CODCLI
			cCodLoja       := NJ0->NJ0_LOJCLI				
		endif
	EndIf
	
	//dá um zap nas tabelas de gravação
	DbSelectArea(cAliasRom)
	ZAP
	DbSelectArea(cAliasAvul)
	ZAP
	DbSelectArea(cAliasCotc)
	ZAP
	
	//Lista todos os romaneios contabilizando as devoluções que estão a fixar
	BeginSql Alias cAliasNJM
		SELECT NJM.*, N8T_DATCOT, N8T_MOECOT, N8T_TAXCOT, SF2.F2_CLIENTE, SF2.F2_LOJA
		  FROM %Table:NJM% NJM
		 INNER JOIN %Table:NJ0% NJ0 ON NJ0.NJ0_FILIAL = %xFilial:NJ0%  
								   AND NJ0.NJ0_CODENT = NJM.NJM_CODENT    
								   AND NJ0.NJ0_LOJENT = NJM.NJM_LOJENT 
								   AND NJ0.%notDel%    
		 INNER JOIN %Table:SF2% SF2 ON SF2.F2_FILIAL  = NJM.NJM_FILIAL 
								   AND SF2.F2_DOC     = NJM.NJM_DOCNUM    
								   AND SF2.F2_SERIE   = NJM.NJM_DOCSER  
								   AND SF2.F2_CLIENTE = NJ0.NJ0_CODCLI 
								   AND SF2.F2_LOJA    = NJ0.NJ0_LOJCLI  
		                           AND SF2.%notDel%    
		 INNER JOIN  %Table:N8T% N8T ON N8T.N8T_FILIAL = NJM.NJM_FILIAL
		                           AND N8T.N8T_CODROM  = NJM.NJM_CODROM
		                           AND N8T.N8T_ITEROM  = NJM.NJM_ITEROM	
		                           AND N8T.N8T_TIPPRC    = "5" //preço final		                           
		                           AND N8T.%notDel%                        
		 WHERE NJM.%notDel%
		   AND NJM.NJM_FILORG  = %xFilial:NJR% 
		   AND NJM.NJM_CODCTR  = %exp:cCodCtr%
		   AND NJM.NJM_ITEM    = %exp:cCodPrev%
		   AND NJM.NJM_SEQPRI  = %exp:cCodRegra%	
	EndSQL 

	//lista os romaneios
	DbSelectArea( cAliasNJM )		
	(cAliasNJM)->( dbGoTop() )
	While .Not. (cAliasNJM)->( Eof( ) )

		//reset
		/*lFixar 	   := .f.
				
		//verifica as entregas
		//verifica se foi a fixar ou não
		dbSelectArea('N8T')
		N8T->(dbSetOrder(1)) //N8T_FILCTR+N8T_CODCTR+N8T_CODCAD+N8T_CODREG+TIPPRC
		If N8T->(dbSeek((cAliasNJM)->NJM_FILIAL+(cAliasNJM)->NJM_CODROM+(cAliasNJM)->NJM_ITEROM))
			While !Eof() .And. !lFixar .and. N8T->(N8T_FILIAL+N8T_CODROM+N8T_ITEROM) == alltrim((cAliasNJM)->NJM_FILIAL+(cAliasNJM)->NJM_CODROM+(cAliasNJM)->NJM_ITEROM)
				if N8T_TIPPRC $ "2|3" //Indice/preco base
					lFixar := .t.
				endif
				N8T->(dbSkip())
			EndDo	
		EndIf
		*/

		//titulos do romaneio
	BeginSql Alias cAliasN8L
		SELECT
			N8L.*, SE1.*
		FROM 
			%Table:N8L% N8L
		INNER JOIN %Table:SE1% SE1 ON 
			(SE1.%notDel% AND
            E1_PREFIXO = N8L_PREFIX AND
         	E1_NUM = N8L_NUM AND
        	E1_PARCELA = N8L_PARCEL AND
        	E1_TIPO = N8L_TIPO)
		WHERE 
			N8L.%notDel% AND 
			N8L.N8L_FILORI = %Exp:(cAliasNJM)->NJM_FILIAL% AND
			N8L.N8L_CODROM = %Exp:(cAliasNJM)->NJM_CODROM% AND
			N8L.N8L_ITEROM = %Exp:(cAliasNJM)->NJM_ITEROM%
	EndSql
				
		//grava a nota atual
		If Reclock(cAliasRom,.t.) 
			(cAliasRom)->N8T_FILIAL := (cAliasNJM)->NJM_FILIAL 	
			(cAliasRom)->N8T_CODROM := (cAliasNJM)->NJM_CODROM 		
			(cAliasRom)->N8T_ITEROM := (cAliasNJM)->NJM_ITEROM 		
			(cAliasRom)->N8T_VALOR  := (cAliasNJM)->NJM_VLRTOT 	
			(cAliasRom)->N8T_QTDVNC := (cAliasNJM)->NJM_QTDFIS 		
			(cAliasRom)->N8T_DATCOT := stod((cAliasNJM)->N8T_DATCOT)
			(cAliasRom)->NJM_DOCEMI := stod((cAliasNJM)->NJM_DOCEMI)
			(cAliasRom)->E1_VALOR   := (cAliasN8L)->E1_VALOR
			(cAliasRom)->E1_SALDO   := (cAliasN8L)->E1_SALDO	
			(cAliasRom)->E1_VENCTO  := stod((cAliasN8L)->E1_VENCTO)	
			(cAliasRom)->E1_BAIXA   := stod((cAliasN8L)->E1_BAIXA)	
			(cAliasRom)->N8T_MOECOT := (cAliasNJM)->N8T_MOECOT 	
			(cAliasRom)->N8T_TAXCOT := (cAliasNJM)->N8T_TAXCOT 			
			(cAliasRom)->NJM_DOCNUM := (cAliasNJM)->NJM_DOCNUM 		
			(cAliasRom)->NJM_DOCSER := (cAliasNJM)->NJM_DOCSER 		
			(cAliasRom)->NJM_CODENT := (cAliasNJM)->NJM_CODENT 		
			(cAliasRom)->NJM_LOJENT := (cAliasNJM)->NJM_LOJENT
			MsUnLock()
		endif
		
		nValorAFix += (cAliasNJM)->NJM_VLRTOT 
		nQtdAFix   += (cAliasNJM)->NJM_QTDFIS 
		
		(cAliasN8L)->( dbCloseArea())	

		//verifica notas de complemento, verifica as notas filhas
		BeginSql Alias cAliasSD2
			SELECT SD2.*, SF2.F2_TIPO
			  FROM %Table:SD2% SD2    
			  INNER JOIN %Table:SF2% SF2 ON D2_FILIAL  = F2_FILIAL
									    AND D2_DOC     = F2_DOC
									    AND D2_SERIE   = F2_SERIE
									    AND D2_CLIENTE = F2_CLIENTE
									    AND D2_LOJA    = F2_LOJA                 
			 WHERE SD2.%notDel%
			   AND SD2.D2_FILIAL  = %exp:(cAliasNJM)->NJM_FILIAL% 
			   AND SD2.D2_SERIORI = %exp:(cAliasNJM)->NJM_DOCSER%
			   AND SD2.D2_NFORI   = %exp:(cAliasNJM)->NJM_DOCNUM%
			   AND SD2.D2_CLIENTE = %exp:(cAliasNJM)->F2_CLIENTE% 
			   AND SD2.D2_LOJA    = %exp:(cAliasNJM)->F2_LOJA%
		EndSQL 
			
		DbSelectArea( cAliasSD2 )		
		(cAliasSD2)->( dbGoTop() )
		While .Not. (cAliasSD2)->( Eof( ) )
			If Reclock(cAliasAvul,.t.) 
				if (cAliasSD2)->F2_TIPO == "C" //complemento
					(cAliasAvul)->C_TIPO     := "C"
					(cAliasAvul)->N8T_FILIAL :=	(cAliasSD2)->D2_FILIAL
					(cAliasAvul)->N8T_CODROM :=	(cAliasNJM)->NJM_CODROM	
					(cAliasAvul)->N8T_ITEROM :=	(cAliasNJM)->NJM_ITEROM 
					(cAliasAvul)->N8T_QTDVNC := (cAliasSD2)->D2_QUANT 
					(cAliasAvul)->NJM_QTDFCO := 0				 
					(cAliasAvul)->N8T_VALOR  := (cAliasSD2)->D2_TOTAL  
					(cAliasAvul)->NJM_DOCNUM :=	(cAliasSD2)->D2_DOC    
					(cAliasAvul)->NJM_DOCSER :=	(cAliasSD2)->D2_SERIE      
					(cAliasAvul)->NJM_CODENT :=	(cAliasSD2)->D2_CLIENTE
					(cAliasAvul)->NJM_LOJENT := (cAliasSD2)->D2_LOJA   
					(cAliasAvul)->(MsUnLock())
					nValorAFix += (cAliasSD2)->D2_TOTAL  
					nQtdAFix   += (cAliasSD2)->D2_QUANT
				elseif (cAliasSD2)->D2_TIPO == "N" //remessa
					(cAliasAvul)->C_TIPO     := "R"
					(cAliasAvul)->N8T_FILIAL :=	(cAliasSD2)->D2_FILIAL				
					(cAliasAvul)->N8T_QTDVNC := (cAliasSD2)->D2_QUANT 
					(cAliasAvul)->NJM_QTDFCO := 0				 
					(cAliasAvul)->N8T_VALOR  := (cAliasSD2)->D2_TOTAL  
					(cAliasAvul)->NJM_DOCNUM :=	(cAliasSD2)->D2_DOC    
					(cAliasAvul)->NJM_DOCSER :=	(cAliasSD2)->D2_SERIE      
					(cAliasAvul)->NJM_CODENT :=	(cAliasSD2)->D2_CLIENTE
					(cAliasAvul)->NJM_LOJENT := (cAliasSD2)->D2_LOJA  
					
					//verifica qual é o romaneio						
					(cAliasAvul)->N8T_CODROM :=	Posicione("NJM",5,(cAliasSD2)->D2_FILIAL+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasNJM)->NJM_CODENT+(cAliasNJM)->NJM_LOJENT+(cAliasNJM)->NJM_CODPRO,"NJM_CODROM")
					(cAliasAvul)->N8T_ITEROM :=	Posicione("NJM",5,(cAliasSD2)->D2_FILIAL+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasNJM)->NJM_CODENT+(cAliasNJM)->NJM_LOJENT+(cAliasNJM)->NJM_CODPRO,"NJM_ITEROM")
					 
					(cAliasAvul)->(MsUnLock())
				Endif
			endif	
			
			(cAliasSD2)->(dbSkip()) 			
		enddo
		(cAliasSD2)->(dbCloseArea())
		
		//verifica devoluções
		BeginSql Alias cAliasSD1
			SELECT SD1.*, NJM_CODROM, NJM_ITEROM, NJM_QTDFCO
			  FROM %Table:SD1% SD1  
		 LEFT  JOIN %Table:NJM% NJM ON NJM.NJM_FILIAL = SD1.D1_FILIAL 
								   AND NJM.NJM_CODROM = SD1.D1_CODROM   
								   AND NJM.NJM_ITEROM = SD1.D1_ITEROM  
								   AND NJM.%notDel%                        
			 WHERE SD1.%notDel%
			   AND SD1.D1_FILIAL  = %exp:(cAliasNJM)->NJM_FILIAL% 
			   AND SD1.D1_SERIORI = %exp:(cAliasNJM)->NJM_DOCSER%
			   AND SD1.D1_NFORI   = %exp:(cAliasNJM)->NJM_DOCNUM%
		EndSQL 
			
		DbSelectArea( cAliasSD1 )		
		(cAliasSD1)->( dbGoTop() )
		While .Not. (cAliasSD1)->( Eof( ) )
			If Reclock(cAliasAvul,.t.) 
				(cAliasAvul)->C_TIPO     := "D"
				(cAliasAvul)->N8T_FILIAL :=	(cAliasSD1)->D1_FILIAL
				(cAliasAvul)->N8T_CODROM :=	(cAliasSD1)->NJM_CODROM	
				(cAliasAvul)->N8T_ITEROM :=	(cAliasSD1)->NJM_ITEROM 
				(cAliasAvul)->N8T_QTDVNC := (cAliasSD1)->D1_QUANT * -1  
				(cAliasAvul)->N8T_VALOR  := (cAliasSD1)->D1_TOTAL * -1  
				(cAliasAvul)->NJM_QTDFCO := IIF(!empty((cAliasSD1)->NJM_QTDFCO),(cAliasSD1)->NJM_QTDFCO	* -1,0) 
				(cAliasAvul)->NJM_DOCNUM :=	(cAliasSD1)->D1_DOC    
				(cAliasAvul)->NJM_DOCSER :=	(cAliasSD1)->D1_SERIE      
				(cAliasAvul)->NJM_CODENT :=	(cAliasSD1)->D1_FORNECE
				(cAliasAvul)->NJM_LOJENT := (cAliasSD1)->D1_LOJA   
				(cAliasAvul)->(MsUnLock())
			endif	
			nValorAFix -= (cAliasSD1)->D1_TOTAL  
			nQtdAFix   -= (cAliasSD1)->D1_QUANT 	
			
			//verifica o quanto foi devolvido de fato consultar o NJM -  diferença fisico /fiscal -
			
			(cAliasSD1)->(dbSkip()) 
		enddo
		(cAliasSD1)->(dbCloseArea())		
		
		//verifica o valor total conforme a precificação
		/*if lFixar
			//calcula a fixação correta
		elseif NJR->NJR_TIPMER == "1" .and. NJR->NJR_MOEDA > 1  
			//verifica se tem alguma fixação com corretagem a ser feita
			//verifica se é a cotação usada está ok -  se não foi usada a provisória
		endif*/
				
		(cAliasNJM)->( dbSkip() )
	EndDo
	
	//Lista o preco final da regra fiscal conforme o contrato - verificar se existe alguma quantidade emitida de outra forma tes/etc
	//pega todas as datas que foram usadas
	//verificar se é por evento
	if NJR->NJR_TIPMER == "1" .and. NJR->NJR_MOEDA > 1 

		BeginSql Alias cAliasN9K
			SELECT NN7_DTVENC, N9K_SEQPF, N9K_SEQCP, SUM(N9K_QTDVNC) N9K_QTDVNC
			  FROM %table:N9K% N9K
			INNER JOIN %Table:NN7% NN7  ON NN7.NN7_FILIAL = N9K.N9K_FILORI
									   AND NN7.NN7_CODCTR = N9K.N9K_CODCTR    
									   AND NN7.NN7_ITEM   = N9K.N9K_SEQPF 								 
			                           AND NN7.%notDel%      
			 WHERE N9K_FILORI  = %xFilial:NJR% 
			   AND N9K_CODCTR  = %Exp:cCodCtr%
			   AND N9K_ITEMPE  = %Exp:cCodPrev%
			   AND N9K_ITEMRF  = %Exp:cCodRegra%		      
			   AND N9K.%notDel%
			  GROUP BY NN7_DTVENC, N9K_SEQPF, N9K_SEQCP 
		EndSQL
		
		DbSelectArea( cAliasN9K )		
		(cAliasN9K)->( dbGoTop() )
		While .Not. (cAliasN9K)->( Eof( ) )
			//grava as cotações
			If Reclock(cAliasCotc,.t.) 
				(cAliasCotc)->N9J_SEQCP  :=	(cAliasN9K)->N9K_SEQCP
				(cAliasCotc)->N9J_SEQPF  :=	(cAliasN9K)->N9K_SEQPF	
				(cAliasCotc)->N9J_QTDE   :=	(cAliasN9K)->N9K_QTDVNC 
				(cAliasCotc)->N9J_VENCIM := stod(( cAliasN9K )->NN7_DTVENC)
				(cAliasCotc)->N9J_VLRTAX := xMoeda(1, NJR->NJR_MOEDAR, 1, stod(( cAliasN9K )->NN7_DTVENC) - NJR->NJR_DIASR)
				(cAliasCotc)->(MsUnLock())
			endif	
			OGX018STRG(@aLstPreco, 0, stod(( cAliasN9K )->NN7_DTVENC), ( cAliasN9K )->N9K_QTDVNC,0, 0, NJR->NJR_MOEDA, 0, 0)
			(cAliasN9K)->(dbSkip())
		enddo
		(cAliasN9K)->(dbCloseArea())		 
	else
		OGX018STRG(@aLstPreco, 0, dDataBase, nQtdAFix,0, 0, NJR->NJR_MOEDA, 0, 0) //nao tem problemas com cotação, podemos mandar o dia atual
	endif	

	//temos o valor que deveria estar do contrato com essa quantidade consumida
	aDadoRegra := OGX018UVLR(@aLstPreco, FwXFilial("NJR"), cCodCtr, cCodPrev, cCodRegra, cCodClient, cCodLoja, cTes, cNatuFin, cFilOrg, cCodNgc, cVersao, cTipoMerc, nMoedaFat, nDias, cUmPrec, cUmProd, cCodPro, nMoeda, cTipoCli, 0, .T.) //Busca somente os faturados
	
	nValNCCNDC := fGetNCCNDC(FwXFilial("NJR"), cCodCtr, cCodPrev, cCodRegra)
	
	//podemos verificar se o valor total está batendo
	nValorDif := (aDadoRegra[3] - nValorAFix) + nValNCCNDC
		
	//restore area	
	RestArea(aAreaNJR)
	RestArea(aAreaN9A)
		
return {nValorDif,aDadoRegra[3],nValorAFix,nQtdAFix }


//-------------------------------------------------------------------
/*/{Protheus.doc} fGetNCCNDC
Busca valores das NCC e NDC geradas
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function fGetNCCNDC(cFilialCtr, cCodCtr, cCodCad, cSeqPri)
 Local cAliasQry := GetNextAlias()
 Local nValorNCC := 0
 Local nValorNDC := 0
 Local nValor    := 0

 BeginSql Alias cAliasQry
	SELECT SUM(NBX_VALOR) VALOR, 'NCC' TIPO
  	  FROM %table:NBX% NBX
 	 WHERE NBX.NBX_FILIAL = %Exp:cFilialCtr%
       AND NBX.NBX_CODCTR = %Exp:cCodCtr%
   	   AND NBX.NBX_CODCAD = %Exp:cCodCad%
   	   AND NBX.NBX_SEQPRI = %Exp:cSeqPri%
	   AND NBX.NBX_TIPO   = 'A3' //NCC
   	   AND NBX.%notDel%
    UNION		  
	SELECT SUM(NBX_VALOR) VALOR, 'NDC' TIPO
  	  FROM %table:NBX% NBX
 	 WHERE NBX.NBX_FILIAL = %Exp:cFilialCtr%
       AND NBX.NBX_CODCTR = %Exp:cCodCtr%
   	   AND NBX.NBX_CODCAD = %Exp:cCodCad%
   	   AND NBX.NBX_SEQPRI = %Exp:cSeqPri%
	   AND NBX.NBX_TIPO   = 'A4' //NDC
   	   AND NBX.%notDel%
 EndSql

 While (cAliasQry)->(!Eof())
	If (cAliasQry)->TIPO == 'NCC'
		nValorNCC += (cAliasQry)->VALOR 
	Else	
		nValorNDC += (cAliasQry)->VALOR 
	EndIf	
	(cAliasQry)->(dbSkip())
 EndDo

 (cAliasQry)->(dbCloseArea())

 nValor := nValorNCC - nValorNDC

Return nValor

/*/{Protheus.doc} fCalcRA()
	(long_description)
	@type  Static Function
	@author mauricio.joao
	@since 20/11/2018
	@version 1.0
	@param cFilTit, Char, filial do titulo
	@param cNum, Char, numero do vinculo N9G x N9M
	@param cParcela, Char, parcela do vinculo N9G x N9M
	@return nTotal, Numeric, total de RA aplicada no contrato
	/*/
 Static Function fCalcRA(cFilTit, cNum, cParcela)
Local nTotal := 0
Local cAliasN9M := GetNextAlias()
		
	BeginSql Alias cAliasN9M

	SELECT 
		N9M.N9M_NUMC, SUM(N9M_VALCOM) TOTAL
	FROM 
		%Table:N9M% N9M
	WHERE 
		N9M.%notDel% AND
		N9M.N9M_FILIAL = %Exp:cFilTit% AND
		N9M.N9M_NUMC = %Exp:cNum% AND
		N9M.N9M_PARCEC = %Exp:cParcela%
	GROUP BY 
		N9M.N9M_NUMC

	EndSql
	
	nTotal := (cAliasN9M)->TOTAL 
	
	(cAliasN9M)->(dbCloseArea())

Return nTotal

