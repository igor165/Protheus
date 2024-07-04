#include 'protheus.ch'
#include 'parmtype.ch'
#include 'OGRX010.ch'

/*{Protheus.doc} OGRX010
Relatório para verificação de contação proporcional, granel apenas.
@author jean.schulze
@since 20/06/2018
@version 1.0
@return ${return}, ${return_description}

@type function
*/
function OGRX010()
	Local oReport	:= Nil
	Local aCmpTemp  := {}
	Local aRetTemp  := {}
	
	Private cAliasTemp := Nil
	Private cPergunta := "OGRX010001"
	
	If TRepInUse()
		
		//cria a temporária para exibir os contrato
		aCmpTemp := {	{"NJR_FILIAL"},;	
						{"NJR_CODCTR"},;	
						{"NNY_ITEM"},  ;	
						{"N9A_SEQPRI"},;
						{"N9A_QUANT"}, ;	
						{"N9A_SDONF"}, ;
						{"NJR_MOEDAR"}, ;
						{"NJR_DIASR"}, ;						
						{"N_VLRCTR","N",TamSX3("N9A_VLT2MO")[1],TamSX3("N9A_VLT2MO")[2],PesqPict('N9A',"N9A_VLT2MO"),STR0001}   , ;						
						{"N_VLRFAT","N",TamSX3("N9A_VLT2MO")[1],TamSX3("N9A_VLT2MO")[2],PesqPict('N9A',"N9A_VLT2MO"),STR0002}	 , ;	
						{"N_TAXCTR","N",TamSX3("N9A_VLRTAX")[1],TamSX3("N9A_VLRTAX")[2],PesqPict('N9A',"N9A_VLRTAX"),STR0003} , ;						
						{"N_TAXFAT","N",TamSX3("N9A_VLRTAX")[1],TamSX3("N9A_VLRTAX")[2],PesqPict('N9A',"N9A_VLRTAX"),STR0004}	}	
		
		aRetTemp := AGRCRIATRB(,aCmpTemp,{"NJR_FILIAL+NJR_CODCTR+NNY_ITEM+N9A_SEQPRI"},STR0009,.T.) 
		cAliasTemp := aRetTemp[4] //ALIAS  
		  
				
		Pergunte( cPergunta, .f. )
		oReport := ReportDef()
		oReport:PrintDialog()
		
		//deleta a tabela temporária
		AGRDELETRB( aRetTemp[4], aRetTemp[3] )  
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
	
	oReport := TReport():New("OGRX010", STR0008, cPergunta, {| oReport | PrintReport( oReport ) }, STR0010) 
	
	oReport:SetTotalInLine( .f. )
	oReport:SetLandScape()	
	
	/*Monta as Colunas*/	
	oSection1 := TRSection():New( oReport, STR0009, cAliasTemp ) 
	
	TRCell():New( oSection1, "NJR_FILIAL" , cAliasTemp)
	TRCell():New( oSection1, "NJR_CODCTR" , cAliasTemp)
	TRCell():New( oSection1, "NNY_ITEM"   , cAliasTemp)
	TRCell():New( oSection1, "N9A_SEQPRI" , cAliasTemp)
	TRCell():New( oSection1, "N9A_QUANT"  , cAliasTemp)
	TRCell():New( oSection1, "N9A_SDONF"  , cAliasTemp)
	TRCell():New( oSection1, "N_VLRCTR"   , cAliasTemp, STR0001, PesqPict("N9A","N9A_VLT2MO"), TamSX3("N9A_VLT2MO")[1])
	TRCell():New( oSection1, "N_VLRFAT"   , cAliasTemp, STR0002, PesqPict("N9A","N9A_VLT2MO"), TamSX3("N9A_VLT2MO")[1])
	TRCell():New( oSection1, "N_TAXCTR"   , cAliasTemp, STR0003, PesqPict("N9A","N9A_VLRTAX"), TamSX3("N9A_VLRTAX")[1])	
	TRCell():New( oSection1, "N_TAXFAT"   , cAliasTemp, STR0004, PesqPict("N9A","N9A_VLRTAX"), TamSX3("N9A_VLRTAX")[1])	
	
	//PREVISÕES
	oSection2 := TRSection():New( oReport, STR0005, "N9J" ) 
	
	TRCell():New( oSection2, "N9J_SEQCP" , "N9J")
	TRCell():New( oSection2, "N9J_SEQPF" , "N9J")
	TRCell():New( oSection2, "N9J_QTDE"  , "N9J")
	TRCell():New( oSection2, "N9J_VENCIM", "N9J")
	TRCell():New( oSection2, "N9J_VLRTAX", "N9J")
	TRCell():New( oSection2, "N9J_SEQ",    "N9J", STR0006, "@!" )
  
	//Entregas
	oSection3 := TRSection():New( oReport, STR0007, "N8T" ) 
	
	TRCell():New( oSection3, "N8T_FILIAL"  , "N8T")
	TRCell():New( oSection3, "N8T_CODROM"  , "N8T")
	TRCell():New( oSection3, "N8T_ITEROM"  , "N8T")
	TRCell():New( oSection3, "N8T_VALOR"   , "N8T")
	TRCell():New( oSection3, "N8T_QTDVNC"  , "N8T")
	TRCell():New( oSection3, "N8T_DATCOT"  , "N8T")
	TRCell():New( oSection3, "N8T_MOECOT"  , "N8T")
	TRCell():New( oSection3, "N8T_TAXCOT"  , "N8T")
	TRCell():New( oSection3, "N8T_ITEMFX"  , "N8T")
	TRCell():New( oSection3, "N8T_SEQFIX"  , "N8T")

	
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
	
	Local cFilDe	:= mv_par01
	Local cFilAte	:= mv_par02
	Local cCtrDe	:= mv_par03
	Local cCtrAte	:= mv_par04	
	Local lShowPrev	:= iif(mv_par05 == 1, .f., .t.)	
	Local cFiltro	:= ""
		
	If oReport:Cancel()
		Return( Nil )
	EndIf
	
	cFiltro += " AND NJR.NJR_FILIAL >= '" + cFilDe  + "' AND NJR.NJR_FILIAL <= '" + cFilAte  + "' "
	cFiltro += " AND NJR.NJR_CODCTR >= '" + cCtrDe  + "' AND NJR.NJR_CODCTR <= '" + cCtrAte  + "' "
	cFiltro += " AND NJR.NJR_TIPO = '2'" //vendas
	cFiltro += " AND NJR.NJR_TIPMER = '1'" //Interno
	cFiltro += " AND NJR.NJR_MOEDA <> 1" //moeda diferente da moeda corrente 
		
	cFiltro := "%" + cFiltro + "%"
		
	fCreateTemp(cFiltro, lShowPrev) //cria a tabela temporária dos dados
		    	
	DbSelectArea( cAliasTemp )	
	(cAliasTemp)->( dbGoTop() )
	
	
	While .Not. (cAliasTemp)->( Eof( ) )
		oS1:Init()	
		
		oS1:PrintLine( )
				
		//Lista as Cotações do Negócio
		dbSelectArea('N9J')
		N9J->(dbSetOrder(1)) //N9J_FILIAL+N9J_CODCTR+N9J_ITEMPE+N9J_ITEMRF
		If N9J->(dbSeek((cAliasTemp)->NJR_FILIAL+(cAliasTemp)->NJR_CODCTR+(cAliasTemp)->NNY_ITEM+(cAliasTemp)->N9A_SEQPRI))
			oS2:Init()	
			While !Eof() .And. N9J->(N9J_FILIAL+N9J_CODCTR+N9J_ITEMPE+N9J_ITEMRF) == (cAliasTemp)->NJR_FILIAL+(cAliasTemp)->NJR_CODCTR+(cAliasTemp)->NNY_ITEM+(cAliasTemp)->N9A_SEQPRI  
				if !lShowPrev .and. N9J->N9J_VENCIM > dDatabase //não devemos mostrar os previstos
					N9J->(dbSkip())
					Loop
				endif
				oS2:Cell( "N9J_SEQ"):SetValue(iif(N9J->N9J_VENCIM > dDatabase, STR0011, STR0012 )) //Realizado
				oS2:Cell( "N9J_VLRTAX" ):SetValue( xMoeda(1, (cAliasTemp)->NJR_MOEDAR, 1, N9J->N9J_VENCIM - (cAliasTemp)->NJR_DIASR)  ) //atualiza o valor da cotação
				oS2:PrintLine( ) // Cotações
				//talvez fazer uma listagem de dados da N9K, quando a condição de pagamento for por evento				
				N9J->(dbSkip())
			EndDo
			oS2:Finish()
		EndIf
		
		//Lista as Entregas da Regra
		dbSelectArea('N8T')
		N8T->(dbSetOrder(2)) //N8T_FILCTR+N8T_CODCTR+N8T_CODCAD+N8T_CODREG+TIPPRC
		If N8T->(dbSeek((cAliasTemp)->NJR_FILIAL+(cAliasTemp)->NJR_CODCTR+(cAliasTemp)->NNY_ITEM+(cAliasTemp)->N9A_SEQPRI))
			oS3:Init()	
			While !Eof() .And. N8T->(N8T_FILCTR+N8T_CODCTR+N8T_CODCAD+N8T_CODREG+N8T_TIPPRC) == (cAliasTemp)->NJR_FILIAL+(cAliasTemp)->NJR_CODCTR+(cAliasTemp)->NNY_ITEM+(cAliasTemp)->N9A_SEQPRI+"1"   
				oS3:PrintLine( ) // Entregas
				//talvez fazer uma listagem de dados da N9K, quando a condição de pagamento for por evento				
				N8T->(dbSkip())
			EndDo
			oS3:Finish()
		EndIf
		
								
		(cAliasTemp)->( dbSkip() )
		
		oS1:Finish()	
	EndDo
	
	
		
Return .t.

/*{Protheus.doc} fCreateTemp
Calcula valores e dados - verificação sem impostos -  tratado somente granel
@author jean.schulze
@since 20/06/2018
@version 1.0
@return ${return}, ${return_description}
@param cFiltro, characters, descricao
@param lShowPrev, logical, descricao
@type function
*/
Static Function fCreateTemp(cFiltro, lShowPrev)
	Local cAliasNJR  := GetNextAlias()
	Local cAliasN8T  := GetNextAlias()
	Local cAliasN9J  := GetNextAlias()
	Local nSomaNotas := 0 
	 
	BeginSql Alias cAliasNJR
		SELECT NJR.*, NNY.*, N9A.*
		  FROM %Table:NJR% NJR
		 INNER JOIN %Table:NNY% NNY ON NNY.NNY_FILIAL = NJR.NJR_FILIAL
		                           AND NNY.NNY_CODCTR = NJR.NJR_CODCTR
		                           AND NNY.%notDel%
		 INNER JOIN %Table:N9A% N9A ON N9A.N9A_FILIAL = NJR.NJR_FILIAL
		                           AND N9A.N9A_CODCTR = NJR.NJR_CODCTR
		                           AND N9A.N9A_ITEM   = NNY.NNY_ITEM
		                           AND N9A.%notDel%                          
		 WHERE NJR.%notDel%
		      %Exp:cFiltro% 
	EndSQL 

	//busca os contratos - regras fiscais	
	DbSelectArea( cAliasNJR )		
	(cAliasNJR)->( dbGoTop() )
	While .Not. (cAliasNJR)->( Eof( ) )

		//reset 
		nTotalCotac := 0
	  	nQtdCotac   := 0
	  	nMediaCotac := 0
		nSomaNotas  := 0 
		cCodClient  := ""
		cCodLoja    := ""
		nValorBase  := 0 
		nValorDisp  := 0 
		
		//busca as informações de Cliente - verifciar se não vai ser da NNY ou N9A
		DbSelectArea("NJ0")
		NJ0->(DbSetOrder(1))
		If NJ0->(DbSeek(xFilial("NJ0")+(cAliasNJR)->NJR_CODENT+(cAliasNJR)->NJR_LOJENT))
			if NJR->NJR_TIPO == "1" //Compras - fornecedor
				cCodClient     := NJ0->NJ0_CODFOR
				cCodLoja       := NJ0->NJ0_LOJFOR				
			else //vendas - cliente
				cCodClient     := NJ0->NJ0_CODCLI
				cCodLoja       := NJ0->NJ0_LOJCLI				
			endif
		EndIf
		
		//verificamos se deve ser uma verificação de valor se o contrato está 100% fixado se não vamos tratar
		//verifica se é algodão ou granel
		if AGRTPALGOD((cAliasNJR)->NJR_CODPRO)	//não faz algodão, tratar depois
			(cAliasNJR)->( dbSkip() )
		  	 Loop
		else
			//faz a diferenca entre granel e algodao 
			aVlrBase := OGAX721FAT((cAliasNJR)->NJR_FILIAL,(cAliasNJR)->NJR_CODCTR,(cAliasNJR)->NNY_ITEM, (cAliasNJR)->N9A_SEQPRI, /*RECNO DXI*/ , (cAliasNJR)->N9A_QUANT , /*Preco Base*/ , cCodClient, cCodLoja, "R" )		
		  	
		  	//busca o valor disponivel
		  	aVlrDisp := OGAX721FAT((cAliasNJR)->NJR_FILIAL,(cAliasNJR)->NJR_CODCTR,(cAliasNJR)->NNY_ITEM, (cAliasNJR)->N9A_SEQPRI, /*RECNO DXI*/ , (cAliasNJR)->N9A_SDONF , /*Preco Base*/ , cCodClient, cCodLoja, "F" )		
		  	
		  	//se retornou a fixar, discartamos
		  	if (aVlrBase[1][2] = "2" .and. aVlrBase[1][3] <> "IDX-FIX")
		  		(cAliasNJR)->( dbSkip() )
		  		Loop
		  	endif
		  	
		  	//se o valor da regra fiscal tem a fixar
		  	if (aVlrDisp[1][2] = "2" .and. aVlrDisp[1][3] <> "IDX-FIX")
		  		(cAliasNJR)->( dbSkip() )
		  		Loop
		  	endif
		  		  	
		  	//convertemos para mostra na unidade de medida de faturamento
		  	nValorBase :=  OGX700UMVL(aVlrBase[1][1],(cAliasNJR)->NJR_UMPRC,(cAliasNJR)->NJR_UM1PRO,(cAliasNJR)->NJR_CODPRO)
		  	nValorDisp :=  OGX700UMVL(aVlrDisp[1][1],(cAliasNJR)->NJR_UMPRC,(cAliasNJR)->NJR_UM1PRO,(cAliasNJR)->NJR_CODPRO)
		  	
		endif
			  
	  		  			
	  	//busca as previões de entrega, se tiver pagamento e data ser maior que a atual vamos fazer a média
	  	BeginSql Alias cAliasN9J
			SELECT SUM(N9J.N9J_QTDE) N9J_QTDE, NN7.NN7_DTVENC  
			  FROM %Table:N9J% N9J
			 INNER JOIN %Table:NN7% NN7 ON NN7.NN7_FILIAL = %xFilial:NN7%
			                           AND NN7.NN7_CODCTR = N9J.N9J_CODCTR
			                           AND NN7.NN7_ITEM   = N9J.N9J_SEQPF
			                           AND NN7.%notDel%                       
			 WHERE N9J.%notDel%
			   AND N9J.N9J_FILIAL  = %xFilial:N9J% 
			   AND N9J.N9J_CODCTR  = %exp:(cAliasNJR)->NJR_CODCTR%
			   AND N9J.N9J_ITEMPE  = %exp:(cAliasNJR)->NNY_ITEM%
			   AND N9J.N9J_ITEMRF  = %exp:(cAliasNJR)->N9A_SEQPRI%	
			 GROUP BY NN7.NN7_DTVENC  		   
		EndSQL 
				
		
		DbSelectArea( cAliasN9J )		
		(cAliasN9J)->( dbGoTop() )
		While .Not. (cAliasN9J)->( Eof( ) )
		 	if !lShowPrev
		 		if stod((cAliasN9J)->NN7_DTVENC) > dDatabase //se ainda não aconteceu
		 			(cAliasN9J)->( dbSkip() )
		 			Loop
		 		endif
		 	endif
			nTotalCotac += xMoeda((cAliasN9J)->N9J_QTDE, (cAliasNJR)->NJR_MOEDAR, 1, stod((cAliasN9J)->NN7_DTVENC) - (cAliasNJR)->NJR_DIASR) 
			nQtdCotac   += (cAliasN9J)->N9J_QTDE
			
			(cAliasN9J)->( dbSkip() )				
		Enddo
		(cAliasN9J)->( dbCloseArea() )
		
		if nQtdCotac = 0 //sem itens realizados
			(cAliasNJR)->( dbSkip() )
	  		Loop
		endif
		
		//faremos uma média da cotação, se for + de uma cotação
		nMediaCotac := nTotalCotac / nQtdCotac //temos a cotação média para a cadencia
	  	
	  	//verifica o preço final da cadencia
	  	nValorCaden := nValorBase * nMediaCotac * (cAliasNJR)->N9A_QUANT   //valor provavel da cadencia
	  	
	  	//verifica se tem algum romaneio que saiu a fixar
	  	/*BeginSql Alias cAliasN8T
			SELECT N8T_TAXCOT, N8T_VALOR, N8T_QTDVNC   
			  FROM %Table:N8T% N8T                    
			 WHERE N8T.%notDel%
			   AND N8T.N8T_FILCTR  = %exp:(cAliasNJR)->NJR_FILIAL%
			   AND N8T.N8T_CODCTR  = %exp:(cAliasNJR)->NJR_CODCTR%
			   AND N8T.N8T_CODCAD  = %exp:(cAliasNJR)->NNY_ITEM%
			   AND N8T.N8T_CODREG  = %exp:(cAliasNJR)->N9A_SEQPRI%
			   AND (N8T.N8T_TIPPRC  = '2' OR N8T.N8T_TIPPRC  = '3' )//Preço Faturamento			 		   
		EndSQL*/ 
	  	
	  	
	  	//busca os romaneios elencados na regra fiscal
	  	BeginSql Alias cAliasN8T
			SELECT N8T_TAXCOT, N8T_VALOR, N8T_QTDVNC   
			  FROM %Table:N8T% N8T                    
			 WHERE N8T.%notDel%
			   AND N8T.N8T_FILCTR  = %exp:(cAliasNJR)->NJR_FILIAL%
			   AND N8T.N8T_CODCTR  = %exp:(cAliasNJR)->NJR_CODCTR%
			   AND N8T.N8T_CODCAD  = %exp:(cAliasNJR)->NNY_ITEM%
			   AND N8T.N8T_CODREG  = %exp:(cAliasNJR)->N9A_SEQPRI%
			   AND N8T.N8T_TIPPRC  = '1' //Preço Faturamento			 		   
		EndSQL 
	  	
	  	//verifica os valores de cotação utilizados -  N8T
	  	DbSelectArea( cAliasN8T )		
		(cAliasN8T)->( dbGoTop() )
		While .Not. (cAliasN8T)->( Eof( ) )
		 	//vamos listar?      
			nSomaNotas += (cAliasN8T)->N8T_QTDVNC * (cAliasN8T)->N8T_TAXCOT * OGX700UMVL((cAliasN8T)->N8T_VALOR ,(cAliasNJR)->NJR_UMPRC,(cAliasNJR)->NJR_UM1PRO,(cAliasNJR)->NJR_CODPRO) 
			(cAliasN8T)->( dbSkip() )				
		Enddo
		
	  	(cAliasN8T)->( dbCloseArea() )
	  	//mostra a diferença conforme a quantidade a emitir
	  	If Reclock(cAliasTemp,.t.) 
			(cAliasTemp)->NJR_FILIAL := (cAliasNJR)->NJR_FILIAL 
			(cAliasTemp)->NJR_CODCTR := (cAliasNJR)->NJR_CODCTR 
			(cAliasTemp)->NNY_ITEM   := (cAliasNJR)->NNY_ITEM  
			(cAliasTemp)->N9A_SEQPRI := (cAliasNJR)->N9A_SEQPRI 
			(cAliasTemp)->N9A_QUANT  := (cAliasNJR)->N9A_QUANT 
			(cAliasTemp)->N9A_SDONF  := (cAliasNJR)->N9A_SDONF 
			(cAliasTemp)->NJR_MOEDAR := (cAliasNJR)->NJR_MOEDAR 
			(cAliasTemp)->NJR_DIASR  := (cAliasNJR)->NJR_DIASR 
			(cAliasTemp)->N_VLRCTR   := nValorCaden
			(cAliasTemp)->N_VLRFAT   := nSomaNotas
			(cAliasTemp)->N_TAXCTR   := nMediaCotac
			(cAliasTemp)->N_TAXFAT   := ((nValorCaden - nSomaNotas) / (cAliasTemp)->N9A_SDONF ) / nValorDisp
			MsUnLock()
		endif		
		(cAliasNJR)->( dbSkip() )
	EndDo


	  
Return .t.

