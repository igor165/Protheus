#include 'protheus.ch'
#include 'parmtype.ch'

/** {Protheus.doc} OGX310
Grava os totais financeiros no contrato.

@return:	Nil
@author: 	mauricio.joao
@since: 	29/06/2018
@Uso: 		OGA250 - Romaneio, OGC120B - Painel Financeiro

26/02/2019 - atualização do campo de total faturado na regra fiscal
*/
Function OGX310(cOrigem,cCodigo)
	Local aArea	     := GetArea()
	Local aAreaNJJ	 := NJJ->(GetArea())
	Local aAreaNJM	 := NJM->(GetArea())
    Local aAreaN9A   := N9A->(GetArea())
    Local aCtr := {}
    Local cAliasN9K	 := GetNextAlias()
	Local cAliasN9G	 := GetNextAlias()
	Local nTotalNN7  := 0 //quantidade total das NN7
	Local nTotalN9K  := 0 //quantidade total das N9K
	Local nTotalN9G  := 0 //quantidade total das N9G   

    Local nCtr := 0

    //Verifico a origem da chamada, se é por romaneio(1) ou painel finanaciero(2)
    //coloco os contratos envolvidos em um array

    If cOrigem == 1 // Romaneio

        DbselectArea("NJM")
        NJM->(dbSetOrder(1))

        If NJM->(dbSeek(xfilial("NJM")+cCodigo))

            While NJM->(!EOF()) .AND. alltrim(NJM->NJM_CODROM) == alltrim(cCodigo)

				If aScan(aCtr, { |x| Alltrim(x[1]) == NJM->NJM_CODCTR}) <= 0
                	aAdd(aCtr,{NJM->NJM_CODCTR})
                Endif
                NJM->(dbSkip())
            EndDo

        EndIf

    ElseIf cOrigem == 2 // Painel financeiro

        aAdd(aCtr,{cCodigo})
        
    EndIf
    
        //varro o arrey com os contratos e atualizo cada um. 
       For nCtr:= 1 To len(aCtr)   
	            //monta a quantidade total das NN7
	            dbSelectArea( "NN7" )
	            NN7->(dbSetOrder(1)) 	
	
	                If NN7->(dbSeek(xFilial("NN7")+aCtr[nCtr][1]))
		            //soma os valores das NN7
		                While NN7->(!EOF()) .AND. alltrim(NN7->(NN7_FILIAL+NN7_CODCTR) ) == alltrim(xFilial("NN7")+aCtr[nCtr][1])
			                nTotalNN7 += NN7->(NN7_VALOR)	
			                NN7->(dbSkip())
		                EndDo
				
		                 //busca os faturamentos 
    	                BeginSql Alias cAliasN9K
	
	    		        SELECT 
                            SUM(N9K_VALOR) VALOR, N9K_ITEMRF, N9K_ITEMPE
		                FROM 
                            %Table:N9K% N9K			 
		    	        WHERE 
                            N9K.%notDel% AND
			                N9K.N9K_FILORI = %exp:xFilial("NJR")% AND
			                N9K.N9K_CODCTR = %exp:aCtr[nCtr][1]%
			            GROUP BY 
                            N9K.N9K_CODCTR, N9K_ITEMRF, N9K_ITEMPE

		                EndSQL
		
		                DbselectArea(cAliasN9K)
		                (cAliasN9K)->(DbGoTop())

                        nTotalN9K := 0
                        While (cAliasN9K)->(!Eof())
                       
                            dbSelectArea("N9A")
                            N9A->(dbSetOrder(1))
                            If N9A->(dbSeek(FwxFilial("N9A")+aCtr[nCtr][1]+(cAliasN9K)->N9K_ITEMPE+(cAliasN9K)->N9K_ITEMRF))
                                If RecLock( "N9A", .F. )
                                    N9A->N9A_VTOTNF := (cAliasN9K)->VALOR
                                                            
                                    N9A->( MsUnLock() )
                                EndIf
                            EndIf
                            //totalizador
			                nTotalN9K += (cAliasN9K)->VALOR

                            (cAliasN9K)->(DbSkip())
		                EndDo
		
                       ( cAliasN9K )->(dbCloseArea())

		               //busca os pagamentos
		                BeginSql Alias cAliasN9G
	
                        SELECT 
                            SUM(N9G_VALOR) VALOR
			            FROM 
                            %Table:N9G% N9G		 
			            WHERE 
                            N9G.%notDel% AND
			                N9G.N9G_FILIAL = %exp:xFilial("N9G")% AND
			                N9G.N9G_CODCTR = %exp:aCtr[nCtr][1]%
			            GROUP BY 
                            N9G.N9G_CODCTR
				
		                EndSQL
		
                        DbselectArea( cAliasN9G )
                        ( cAliasN9G )->(DbGoTop())
                        If ( cAliasN9G )->( !Eof() )
                            nTotalN9G := ( cAliasN9G )->VALOR
                        EndIf

                        ( cAliasN9G ) ->(dbCloseArea())
		
	                EndIf    

                    //Grava os valores no contrato.
                    DbselectArea("NJR")
                    NJR->(dbSetOrder(1))

                    If NJR->(dbSeek(xfilial("NJR")+aCtr[nCtr][1]))

                        while NJR->(!eof()) .AND. ALLTRIM(NJR->NJR_CODCTR) == ALLTRIM(aCtr[nCtr][1])

                            If RecLock( "NJR", .F. )
                                NJR->NJR_TOTNN7 := nTotalNN7 //previsto
                                NJR->NJR_TOTN9K := nTotalN9K //faturado
                                NJR->NJR_TOTN9G := nTotalN9G //recebido
                                NJR->NJR_TOTAFT := (nTotalNN7-nTotalN9K) //a faturar
                                NJR->NJR_TOTARB := (nTotalNN7-nTotalN9G) //a receber
                                                                
                                NJR->( msUnLock() )

                            EndIf
                                
                                NJR->(dbSkip())

                            endDo
                     EndIf
        
        next nCtr  

    RestArea( aAreaNJM )
    RestArea( aAreaNJJ )
    RestArea( aAreaN9A )
    RestArea( aArea )

return


