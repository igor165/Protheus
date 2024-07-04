#include "protheus.ch"
#include "OGX165.ch"

Static __lnewNeg := SuperGetMv('MV_AGRO002', , .F.) //Usa novo negócio

/** {Protheus.doc} OGX165
Rotina chamada através do Ponto de Entrada durante a exclusão do Documento de Saída ( MATA520 )
Chamado antes dos PEs: SF2520E (MATA520) e SF2520E (MATA521).

@param: 	Nil
@return:	Nil
@author: 	Bruna Rocio
@since: 	09/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
//Programa Original: ARMXPE04 

Function OGX165()

	Local aAreaAtu 	:= GetArea()
	Local aAreaSF2 	:= SF2->( GetArea() )
	Local aAreaSD2 	:= SD2->( GetArea() )
	Local aAreaSE1 	:= SE1->( GetArea() )
	
	Local nX			:= 0
	Local aNJM			:= { { "", "", 0, ""} } // Inicializa com a primeira linha em branco para não dar erro no aScan()
	Local lNfCmplPrc	:= iIf( SF2->F2_TIPO == 'C', .T., .F. )
	Local aVincCabNF 	:=	{}
	Local aVincIteNF 	:= 	{}
	Local aVncCRec		:=  {}
	Local aLinVncAux	:=  {}
	Local aLinha		:=	{}
	Local aChvItNkc		:=	{}  // ira conter chave de Seek montada dos itnes da nf. de compl. de preço
	Local nI			:= 0	

	dbselectArea( "SD2" )
	dbSetOrder( 3 ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	If dbSeek( xFilial( "SD2" ) + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA ) ) 
		While ! SD2->( Eof() ) .And. SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA ) == xFilial("SD2") + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA ) 

			/*************************************************************************************/
			/**            Chamada para excluir dados de expedição de sementes - UBS           **/
			/***********************************************************************************/
			IF AGRIFDBSEEK("NJ6",SF2->F2_CARGA + SD2->D2_PEDIDO + SD2->D2_ITEMPV ,2,.F.) .and. NJ6->NJ6_STATUS = 'C'
				NJS->(DbSetOrder(2))
				IF NJS->(MsSeek("NJ6" + NJ6->(NJ6_FILIAL+NJ6_CODCAR+NJ6_NUMPV+NJ6_ITEM+NJ6_SEQUEN+NJ6_PRODUT+NJ6_SEQLT)))
					If RecLock('NJS',.f.)	
						NJS->(dbDelete())
						NJS->(MsUnlock())
					Endif
				ENDIF
				IF AGRIFDBSEEK("NJ5",NJ6->(NJ6_NUMPV + NJ6_ITEM + NJ6_SEQUEN + NJ6_PRODUT) ,1,.F.)
					If RecLock('NJ5',.f.)	
						NJ5->(dbDelete())
						NJ5->(MsUnlock())
					EndIf
				ENDIF
				If RecLock('NJ6',.f.)	
					NJ6->(dbDelete())
					NJ6->(MsUnlock())
				EndIf
			ENDIF
			/*******************************************/
			/**            FIM da Exclusao           **/
			/*****************************************/
			
			//Reabertura da Ordem de Transito ao excluir nota de estorno.
			//Verifica se a nota excluida existe na tabela NK2 e reabre.
			fReabreNFT(SD2->D2_DOC,SD2->D2_SERIE)
			
            if TableInDic('N8J')
				DbselectArea( 'N8J' )
				N8J->( dbSetOrder( 1 ) ) //_FILIAL+_DOC+_SERIE+_CLIFOR+_LOJA
				
				IF  N8J->( DbSeek( FwXfilial('N8J') + SD2->(D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) ))
				
					//Eliminar o vinculo na SD2
					//Array de vinculo do Agro com os Itens do doc. Saida
					IF Len(aVincCabNF) > 0
						nPosCpo:= ASCAN(aVincCabNF, {|aVincCabNF| aVincCabNF[1] ==  'N8J_DOC' })
				   
						IF ! Alltrim ( aVincCabNF[nPosCpo] ) ==  SD2->D2_DOC
							lVinculou := fAgrVncNFS (aVincCabNF,aVincIteNF  , 5)  		//Excluir
						EndIF
				   
						aVincCabNF := {}
						aVincIteNF := {}
					EndIF
		
					aLinha := {}
					aadd( aLinha, { "N8K_FILIAL"    , FwXfilial('N8K')	} )
					aadd( aLinha, { "N8K_DOC" 	   	, SD2->D2_DOC		} )
					aadd( aLinha, { "N8K_SERIE"    	, SD2->D2_ITEM		} )
					aadd( aLinha, { "N8K_CLIFOR"    , SD2->D2_CLIENTE	} ) 
					aadd( aLinha, { "N8K_LOJA"    	, SD2->D2_LOJA		} )
					aadd( aLinha, { "N8K_ITEDOC"    , SD2->D2_ITEM   	} )
					aAdd( aVincIteNF, aLinha )
					
					//Array de vinculo do Agro com o doc. Sada
					
					IF Len (aVincCabNF) == 0
						aadd( aVincCabNF, { "N8J_FILIAL"	, FwXfilial('N8K')	} )
						aadd( aVincCabNF, { "N8J_DOC"		, SF2->F2_DOC		} )
						aadd( aVincCabNF, { "N8J_SERIE"		, SF2->F2_SERIE		} )
						aadd( aVincCabNF, { "N8J_CLIFOR"    , SF2->F2_CLIENTE	} ) 
						aadd( aVincCabNF, { "N8J_LOJA"    	, SF2->F2_LOJA		} )
					EndIf
					
					//Criando o Array de vinculo com SE1 para excluir vinculo do CReceber
					IF Len ( aVncCRec ) == 0
						dbSelectArea("SE1")
						SE1->( dbSetOrder(2) )
						cSeek:=(fwxFilial('SE1') + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_SERIE + SF2->F2_DOC)
						IF SE1->( dbSeek( cSeek ) )
							While !SE1->( Eof() ) .And. cSeek == SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM)
								aLinVncAux := {}
								aadd( aLinVncAux, { "N8L_FILIAL"    	, FwXfilial('N8L') 				} )
								aadd( aLinVncAux, { "N8L_PREFIX"    	, SE1->E1_PREFIXO				} )
								aadd( aLinVncAux, { "N8L_NUM"    		, SE1->E1_NUM					} )
								aadd( aLinVncAux, { "N8L_PARCEL"    	, SE1->E1_PARCELA				} )
								aadd( aLinVncAux, { "N8L_TIPO"    		, SE1->E1_TIPO					} )
				
								aAdd(aVncCRec, aLinvncAux)		
				
								SE1->( dbSkip() )
							EndDo
						EndIf
					EndIF
					
					IF  .not. EMPTY(N8J->N8J_CODROM) .and. Empty(N8J->N8J_CODFIX) .AND. .not. lNfCmplPrc	// Indica que é uma nf  de romaneio
					
						dbSelectArea( "NJM" )
						NJM->(dbSetOrder( 2 )) //NJM_FILIAL+NJM_DOCNUM+NJM_DOCSER+NJM_ITEROM
						If NJM->(dbSeek( xFilial( "NJM" ) + SD2->( D2_DOC + D2_SERIE ) ))
							While ! NJM->( Eof() ) .And. NJM->( NJM_FILIAL + NJM_DOCNUM + NJM_DOCSER ) == xFilial( "NJM" ) + SD2->(  D2_DOC + D2_SERIE )
	
								// Se não achou a linha da NJM no array aNJM
								If aScan( aNJM, { |x| x[3] == NJM->( Recno() ) } ) == 0
	
									// Exclui primeira linha em branco do array aNJM
									If Len( aNJM ) > 0
										If aNJM[ 1, 3 ] == 0
											aNJM := {}
										EndIf
									EndIf
	
									aAdd( aNJM, { NJM->( NJM_FILIAL ), NJM->( NJM_CODROM ), NJM->( Recno() ), NJM->( NJM_PEDIDO ) } )
	
								EndIf
	
								NJM->( DbSkip() ) 
							EndDo
						EndIF
						
					ElseIF .not. Empty( N8J->N8J_FECSER ) // Indica que é de fechamento de serviço;
					
					   dbSelectArea('NKS')
					   NKS->(dbSetOrder(1) )	// NKS_FILIAL+NKS_FECSER
					   IF NKS->( DbSeek(fwxfilial('NKS') + N8J->N8J_FECSER ))
					   		OGA263E(NKS->NKS_STATUS, NKS->NKS_FECSER, .f.)
					   EndIF
					   
					ElseIF lNfCmplPrc	//Indica que é uma nf. de complemento de preço
						//Ajustado para tratar o legado e o novo negócio
	                    DbselectArea( 'N8K' )
						N8K->( dbSetOrder( 1 ) ) //_N8K_FILIAL+N8K_DOC+N8K_SERIE+N8K_CLIFOR+N8K_LOJA+N8K_ITEDOC
						IF  N8K->( DbSeek( FwXfilial('N8K') + SD2->(D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_ITEM) ))
	                        aAdd( aChvItNkc , FWxFilial( "NKC" ) + N8K->( N8K_CODCTR +N8K_CODROM + N8K_ITEROM + N8K_SERIE + N8K_DOC ) + DtOs(SD2->D2_EMISSAO) )
	                    EndIf
					//ElseIF ( N8J->N8J_CODOTR )	//Indica que tem nf. de estorno de ordem de transito
					//ElseIF ( N8J->N8J_ORPGRC )	//Indica que é uma ordem de recebimento do fech. financeiro ( Paraguai )
					EndIf
	
				ElseIf SF2->( FieldPos("F2_CODROM") ) > 0 .and. !Empty(SF2->F2_CODROM)
					IF OgxHeal( SF2->F2_DOC, SF2->F2_SERIE,SF2->F2_TIPO, SF2->F2_CLIENTE, SF2->F2_LOJA )   // Retorna verdadeiro se o doc erá um doc do OG. e foi ajustado para os novos vinculos.
					   Loop
					EndIF
				EndIF //Seek N8J
				
			//Se não tiver a tabela de extensão N8J
			else 
				dbSelectArea( "NJM" )
				NJM->(dbSetOrder( 2 )) //NJM_FILIAL+NJM_DOCNUM+NJM_DOCSER+NJM_ITEROM
				If NJM->(dbSeek( xFilial( "NJM" ) + SD2->( D2_DOC + D2_SERIE ) ))
					While ! NJM->( Eof() ) .And. NJM->( NJM_FILIAL + NJM_DOCNUM + NJM_DOCSER ) == xFilial( "NJM" ) + SD2->(  D2_DOC + D2_SERIE )
	

						// Se não achou a linha da NJM no array aNJM
						If aScan( aNJM, { |x| x[3] == NJM->( Recno() ) } ) == 0
	
							// Exclui primeira linha em branco do array aNJM
							If Len( aNJM ) > 0
								If aNJM[ 1, 3 ] == 0
									aNJM := {}
								EndIf
							EndIf
	
							aAdd( aNJM, { NJM->( NJM_FILIAL ), NJM->( NJM_CODROM ), NJM->( Recno() ), NJM->( NJM_PEDIDO ) } )
	
						EndIf
	
						NJM->( DbSkip() ) 
					EndDo
	
				Else
					//Prestação de serviço não possui tabela Itens de Comercialização - NJM	
	
					/*************************************************************************************************************************************/
					/**            EXCLUSÃO CÁLCULO SERVIÇO QUANDO GEROU NOTA FISCAL DE PRESTAÇÃO DE SERVIÇOS ** SEM ROMANEIO, SÓ NOTA FISCAL           **/
					/*************************************************************************************************************************************/
					dbSelectArea('NKG')
					dbSetOrder(5)
					dbSeek( xFilial('NKG') + SD2->( D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA ) )
					While ! NKG->( Eof() ) .And. NKG->( NKG_FILIAL ) == xFilial('NKG');
					.And. NKG->( NKG_DOCNUM + NKG_DOCSER + NKG_CODENT + NKG_LOJENT ) == SD2->( D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA )
	
						If RecLock('NKG',.f.)	
							NKG->(dbDelete())
							NKG->(MsUnlock())
						EndIf
	
						NKG->( dbSkip() )
					EndDo
					/*************************************************************************************************************************************/
	
				EndIf
			endIf

			SD2->( DbSkip() )
		EndDo
		
		IF lNfCmplPrc 
		   //Atenção aqui exclui a nf. Porem precisamos de PE mais ao final para excluir o PV. desta nf
		   // pois os pvs. ref. a nf. de compl. de prço de venda, simplesmente ficam soltos no erp
		   // apos a exclusão da nf.
           IF Len(aChvItNkc) > 0
			   	NKC->( DbSetOrder( 2 ) ) 			// NKC_FILIAL+NKC_CODCTR+NKC_CODROM+NKC_ITEROM+NKC_SERIE+NKC_DOCTO+NKC_DATA
			    For nI := 1  To Len( aChvItNkc )
					IF NKC->( DbSeek(  aChvItNkc[ nI ]  ) )
														// Ajustando Vrs. da Tabela NNC Entregas da Fixação                          
						NNC->( DbSetOrder( 1 ) ) 		// NNC_FILIAL+NNC_CODCTR+NNC_ITEMFX+NNC_CODROM+NNC_ITEROM
						cChvNNC := FWxFilial( "NNC" ) + NKC->(NKC_CODCTR+NKC_ITEMFX+NKC_CODROM+NKC_ITEROM)
						IF NNC->( DbSeek(  cChvNNC  ) )
							RecLock('NNC',.F.)
							NNC->NNC_VLCMPL -= NKC->NKC_VRTOT
							NNC->NNC_VLIMPC -= NKC->NKC_VRIMP
							IF NKC->NKC_FORMUL == 'S' .and. NNC->NNC_VLFBAJ > 0 // Indica que o Vr. da Nf. emitida foi ajustado Para tentar Garantir Vlr. Liq. fix. no Financeiro 
								NNC->NNC_VLFBAJ := 0
							EndIF
							NNC->NNC_Status := ''
							NNC->( MsUnlock() )
							// -- Atualizando o Status de Forma Centralizada --
							Reclock("NNC",.f. )
							NNC->NNC_STATUS := OG430STAT( NNC->(Recno() )  ) 
							NNC->( MsUnlock() )
						EndIF
						// Fim Ajustando Vrs. Tabela Entregas
		
						RecLock('NKC',.F.)
						NKC->(dbDelete())
						NKC->(MsUnlock())
					EndIF
				nExt nI
		   EndIF
		EndIF			

		// Se o array só possui a primeira linha em branco, exclui a mesma
		If Len( aNJM ) > 0
			If aNJM[ 1, 3 ] == 0
				aNJM := {}
			EndIf
		EndIf

		// Atualiza o status do romaneio (NJJ)
		If Len( aNJM ) > 0
			For nX := 1 to Len( aNJM )

				// Reabre o romaneio que não possui documento fiscal relacionado
				OGX165Reabre( aNJM[ nX, 1 ], aNJM[ nX, 2 ], aNJM[ nX, 3 ], aNJM[ nX, 4 ] )

			Next nX	
		EndIf
		
		IF Len(aVincCabNF) > 0 //
			   
			lVinculou := fAgrVncNFS (aVincCabNF,aVincIteNF  , 5)  		//Excluir
			   
			aVincCabNF := {}
			aVincIteNF := {}
		EndIF
		
		IF Len( aVncCRec ) >0
		   fAgrVncRec (aVncCRec, 5 )  //Excluir
		   aVncCRec := {}
		EndIF

	EndIf
	
	RestArea( aAreaSE1 )
	RestArea( aAreaSD2 )
	RestArea( aAreaSF2 )
	RestArea( aAreaAtu )
Return( )

/** {Protheus.doc} OGX165Reabre
Rotina que reabre o romaneio relacionado à nota que foi excluída ou não existe na base

@param: 	Nil
@author: 	Marlon Richard Trettin
@since: 	25/03/2015
@Uso: 		SIGAAGR
*/
Function OGX165Reabre( pcFilial, pcCodRom, pnNJMRecno, pcNumPV ) 
	Local aAreaAtu 	:= GetArea()
	Default pcNumPV := ""

	dbSelectArea( "NJM" )
	DbGoTo( pnNJMRecno )

	// Atualiza o registro da NJM, reabrindo o mesmo
	OGX145ANJM( pcNumPV )

	If NJM->( NJM_TIPO ) == '6'

		/******************************************************************************************************/
		/**            EXCLUSÃO CÁLCULO SERVIÇO QUANDO FOR RETENÇÃO QUE GEROU ROMANEIO RETORNO SIMBOLICO     **/
		/******************************************************************************************************/
		dbSelectArea('NKG')
		dbSetOrder(2)
		dbSeek( xFilial('NKG') + NJM->( NJM_CODROM + NJM_ITEROM ) )
		While ! NKG->( Eof() ) .And. NKG->( NKG_FILIAL + NKG_CODROM + NKG_ITEROM ) == xFilial('NKG') + NJM->( NJM_CODROM + NJM_ITEROM )

			If RecLock( 'NKG', .f. )	
				NKG->( dbDelete() )
				NKG->( MsUnlock() )
			EndIf

			NKG->( dbSkip() )
		EndDo	
		/******************************************************************************************************/

	ElseIf NJM->( NJM_TIPO ) $ "4|5|8|9"
		If NJJ->(ColumnPos('NJJ_ORIGEM')) > 0
	        //verifica se o contrato é novo negócio e romaneio de de venda
			If !Empty(Posicione("NJR",1,xFilial("NJR")+NJM->NJM_CODCTR ,"NJR_CODNGC"))  .AND. NJM->( NJM_TIPO ) $ "4|5"
	
	            RetSaldo()
	
	        Else    
	            // Rotina para atualização dos valores financeiros provisorios do contrato
			    OGA250ATUF( NJM->( NJM_CODCTR ), NJM->( NJM_QTDFIS ), IIF( NJM->( NJM_TIPO ) $ "4|5", "1", "2" ) )
	        EndIf
	    else
	    	// Rotina para atualização dos valores financeiros provisorios do contrato
			OGA250ATUF( NJM->( NJM_CODCTR ), NJM->( NJM_QTDFIS ), IIF( NJM->( NJM_TIPO ) $ "4|5", "1", "2" ) )
	    endIf
	EndIf		

	// Atualiza o registro de NJJ, reabrindo o romaneio
	OGX145AtNJJ( pcFilial, pcCodRom )
	
	if __lnewNeg
	    //ELIMINA RELACIONAMENTO REMESSA X IE (N91)
	    IF  NJM->NJM_SUBTIP = '21' //(S) REMESSA PARA FORMAÇÃO LOTE
	    	OG250HCN9I(NJM->NJM_FILIAL, NJM->NJM_CODROM, NJM->NJM_ITEROM) 
		EndIf
		
		//Cria movimentação dos fardos (07 - Romaneio) inativo, para histórico
		OG250EMFR(pcFilial, pcCodRom)
		
		//Deleta a movimentação dos fardos (08 - Em trânsito)
		OG250EDMFT(pcFilial, pcCodRom)
			
		// Atualiza o registro de N7Q, alterando Status Faturamento da Instrução de Embarque
		OG710AtN7Q(pcFilial, pcCodRom)
	endIf

	RestArea( aAreaAtu )
Return( Nil )

/*/{Protheus.doc} fReabreNFT(cNota,cSerie)
	verifica se existe a nota excluida na tabela NK2.
	@type  Static Function
	@author mauricio.joao
	@since 27/03/2020
	@version 1.0

	/*/
Static Function fReabreNFT(cNota,cSerie)
Local cAliasNK2 := GetNextAlias() 
//Gera a Query 
BeginSql alias cAliasNK2 
SELECT
	NK2.NK2_CODIGO
FROM
	%table:NK2% NK2
WHERE
	NK2.NK2_FILIAL= %xfilial:NK2% AND
	NK2.NK2_NUENFT= %Exp:cNota% AND
	NK2.NK2_SEENFT= %Exp:cSerie% AND
	NK2.%notDel% 
EndSql
//While no resultado da Query
While (cAliasNK2)->(!Eof())
	DbSelectArea("NK2")
	NK2->(DbSetOrder(1))
	If NK2->(DbSeek(xFilial("NK2")+(cAliasNK2)->NK2_CODIGO))
		Reclock("NK2", .F.)
		NK2->NK2_STATUS := "2"
		NK2->NK2_NUENFT := ""
		NK2->NK2_SEENFT := ""
		NK2->NK2_DTENFT := STOD("")
		NK2->(MsUnlock())
	EndIf
	(cAliasNK2)->(DbSkip())
Enddo
//Fecha a tabela
(cAliasNK2)->(DbCloseArea())

Return .t.

/** {Protheus.doc} OgxHeal ( Rotina de workaround )
Esta rotina foi criada, quando foi feito uma nova forma de criar vinculo entre as tabelas do agro e do ERP.
A OGXheal sera executada somente se:
Efetuarem a atualização do sistema ( Sistema passa a enxergar as tabelas de vinculo)
Excluir uma nf dentro do prazo de 24hrs que foi criada por um romaneio no vinculo antigo, e no momento 
da exc. o sistema esta atualizado olhando o vinc. novo.
@param: 	codigo da nf. de saida, serie, tipo, cliente, loja
@author: 	Equipe Agro
@since: 	12/03/2018
@Uso: 		SIGAAGR
*/
Static function OgxHeal( cDocNum, cSerie,cDocTipo, cDoccli, cDocCliLja )

	Local cNfTratada 		:= ''
	Local aVincCab			:= {}
	Local aVincITE 			:= {}
	Local aVincCabNF		:= {}
	Local aVincIteNF		:= {}
	Local aLinVncAux		:= {}
	Local aVncCRec			:= {}
	Local lEhDocOg			:= .f.
	Local aAreaAtu 			:= GetArea()
	Local aAreaSF2 			:= SF2->( GetArea() )
	Local aAreaSD2 			:= SD2->( GetArea() )
	Local aAreaSE1 			:= SE1->( GetArea() )
	Local cMsg1				:= STR0001
	Local cMsg2				:= STR0002

	Local cqry	:= GetNextAlias()

	If .not. Alltrim(cDocTipo) $ "DB"
		dbselectArea( "NJ0" )
		NJ0->( dbSetOrder( 4 ) ) 	// NJ0_FILIAL+NJ0_CODCLI+NJ0_CODCLI
		IF   .not. NJ0->(Dbseek( FwXfilial('NJ0') + cDoccli + cDocCliLja ) )
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg1 , 0, 0, {})

			RestArea(aAreaAtu)
			RestArea(aAreaSF2)
			RestArea(aAreaSD2)
			RestArea(aAreaSE1)

			Return( .f.)
		EndIF
	Else
		dbselectArea( "NJ0" )
		NJ0->( dbSetOrder( 3 ) ) 	//NJ0_FILIAL+NJ0_CODFOR+NJ0_LOJFOR
		IF   .not. NJ0->(Dbseek( FwXfilial('NJ0') + cDoccli + cDocCliLja ) )
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg2 , 0, 0, {})

			RestArea(aAreaAtu)
			RestArea(aAreaSF2)
			RestArea(aAreaSD2)
			RestArea(aAreaSE1)

			Return( .f.)
		EndIF
	Endif

	BeginSql Alias cQry
		Select SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA,SF2.F2_TIPO,
		NJM.*, NKC.*, NK2.*,NKS.*
		FROM %Table:SF2% SF2
		LEFT JOIN  %Table:NJM% NJM
		ON  NJM.NJM_FILIAL 	= %xFilial:NJM%
		And	NJM.NJM_DOCNUM	= %Exp:cDocNum%
		And	NJM.NJM_DOCSER	= %Exp:cSerie%
		And	NJM.NJM_CODENT	= %Exp:NJ0->NJ0_CODENT%
		And	NJM.NJM_LOJENT	= %Exp:NJ0->NJ0_LOJENT%
		And	NJM.%NotDel%
		LEFT JOIN  %Table:NKC% NKC
		ON  NKC.NKC_FILIAL 	= %xFilial:NKC%
		AND NKC.NKC_DOCTO 	= %Exp:cDocNum%
		AND NKC.NKC_SERIE	= %Exp:cSerie%
		AND NKC.NKC_FORCLI 	= %Exp:cDoccli%
		AND NKC.NKC_LOJA 	= %Exp:cDoccliLja%
		AND NKC.%NotDel%
		LEFT JOIN  %Table:NK2% NK2
		ON  NK2.NK2_FILIAL 	= %xFilial:NK2%
		AND NK2.NK2_NUMNFT 	= %Exp:cDocNum%
		AND NK2.NK2_SERNFT	= %Exp:cSerie%
		AND NK2.NK2_CODENT 	= %Exp:NJ0->NJ0_CODENT%
		AND NK2.NK2_LOJENT 	= %Exp:NJ0->NJ0_LOJENT%
		AND NK2.%NotDel%
		LEFT JOIN  %Table:NKS% NKS
		ON  NKS.NKS_FILIAL 	= %xFilial:NKS%
		AND NKS.NKS_DOCNUM 	= %Exp:cDocNum%
		AND NKS.NKS_DOCSER	= %Exp:cSerie%
		AND NKS.NKS_CLIENT 	= %Exp:cDocCli%
		AND NKS.NKS_LOJA 	= %Exp:cDocCliLja%
		AND NKS.NKS_STATUS  <> '2'				/* Cancelado */
		AND NKS.%NotDel%
		WHERE	SF2.F2_FILIAL 	= %xFilial:SF2%
		AND 	SF2.F2_DOC 		= %Exp:cDocNum%
		AND 	SF2.F2_SERIE	= %Exp:cSerie%
		AND 	SF2.F2_CLIENTE	= %Exp:cDocCli%
		AND 	SF2.F2_LOJA 	= %Exp:cDocCliLja%
		AND 	SF2.%NotDel%
	EndSql

	// Qdo é compra somente tem o vinculo da SE2

	cNfTratada := ''
	(cQry)->( dbGoTop() )
	If !(cQry)->( Eof() )
		While !(cQry)->( Eof() )
			cDocDoOG := Alltrim( ( cQry )->NJM_DOCNUM) + Alltrim (( cQry )->NKC_DOCTO ) + Alltrim (( cQry )->NK2_NUMNFT ) + Alltrim (( cQry )->NKS_DOCNUM )
			IF Len( Alltrim( cDocDoOG ) ) == 0
				(cqry)->( DbSkip() )
				Loop
			Else
			lEhDocOg := .t.
			EndIF
			IF Len(Alltrim(cNfTratada)) == 0 //Vazio
				cNfTratada :=  (cQry)->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )
			ElseIF cNfTratada == (cQry)->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )
				(cqry)->( DbSkip() )
				Loop
			ElseIF .not. cNfTratada = (cQry)->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )
				cNfTratada 	:=  (cQry)->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )
				aVincCab		:= {}
				aVincITE 		:= {}
				aVincCabNF		:= {}
				aVincIteNF		:= {}
				
			EndIF
			
			dbselectArea( "SD2" )
			dbSetOrder( 3 ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			If dbSeek( xFilial( "SD2" ) + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA ) )
				While ! SD2->( Eof() ) .And. SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA ) == xFilial("SD2") + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )
					
					cCodCtr 	:= ''
					cSafra		:= ''
					cCodRom		:= ''
					cItcodRom   := ''
					cCodFIX 	:= ''
					cCodOtr		:= ''
					cIteOTR		:= ''
					cFecser		:= ''
					cOrigem		:= ''
					cHistor		:= ''
					
					IF  .not. Empty( Alltrim( ( cQry )->NJM_DOCNUM) )
						cCodCtr 	:= (cQry)->NJM_CODCTR
						cSafra		:= (cQry)->NJM_CODSAF
						cCodRom		:= (cQry)->NJM_CODROM
						cItcodRom   := (cQry)->NJM_ITEROM
						cCodFIX 	:= ''
						cCodOtr		:= ''
						cIteOTR		:= ''
						cFecser		:= ''
						cOrigem		:= 'OGA250/OGA251'
						cHistor		:= ''
						
						cTpEntRom 	:=  Posicione("NJJ", 1, FwXfilial("NJJ") + (cQry)->NJM_CODROM ,"NJJ_TIPENT")
						IF cTpEntRom $ '2|3'"
							cOrigem := 'OGA251'
						Else
							cOrigem := 'OGA250'
						EndIF
						cHist := Alltrim(Posicione("SX5",1,fwxFilial("SX5")+'K5' + (cQry)->NJM_TIPO,"X5_DESCRI"))
					ElseIF .not. Empty( Alltrim (( cQry )->NKC_DOCTO ) )
						cCodCtr 	:= (cQry)->NKC_CODCTR
						cSafra		:= Posicione("NJJ", 1, FwXfilial("NJJ") + (cQry)->NJM_CODROM ,"NJJ_CODSAF")
						cCodRom		:= (cQry)->NKC_CODROM
						cItcodRom   := (cQry)->NKC_ITEROM
						cCodFIX 	:= (cQry)->NKC_ITEMFIX
						cCodOtr		:= ''
						cIteOTR		:= ''
						cFecser		:= ''
						cOrigem		:= 'OGA430B'
						cHistor		:= 'Complemento de Preço'
					ElseIF .not. Empty( Alltrim (( cQry )->NK2_NUMNFT ))   // Essa sit. so ocorre para um nf. de extorno de nf. de transito
						cCodCtr 	:= (cQry)->NK2_CODCTR
						cSafra		:= (cQry)->NK2_CODSAF
						cCodRom		:= ''
						cItcodRom   := ''
						cCodFIX 	:= ''
						cCodOtr		:= (cQry)->NK2_CODIGO
						cIteOTR		:= '001'		// Para ajustes vou sempre mover o 1o. item
						cFecser		:= ''
						cOrigem		:= 'OGA430B'
						cHistor		:= 'Nota de Transito'
					ElseIF .not. Empty( Alltrim (( cQry )->NKS_DOCNUM ) )
						cCodCtr 	:= ''
						cSafra		:= ''
						cCodRom		:= ''
						cItcodRom   := ''
						cCodFIX 	:= ''
						cCodOtr		:= ''
						cIteOTR		:= ''
						cFecser		:= ( cQry )->NKS_FECSER
						cOrigem		:= 'OGA261'
						cHistor		:= 'Fechto Servico'
					EndIF
					
					aLinhaVinc := {}
					aadd( aLinhaVinc, { "N8K_FILIAL"    , FwXfilial('N8K')	} )
					aadd( aLinhaVinc, { "N8K_DOC" 	   	, SD2->D2_DOC		} )
					aadd( aLinhaVinc, { "N8K_SERIE"    	, SD2->D2_SERIE		} )
					aadd( aLinhaVinc, { "N8K_CLIFOR"    , SD2->D2_CLIENTE	} )
					aadd( aLinhaVinc, { "N8K_LOJA"    	, SD2->D2_LOJA		} )
					aadd( aLinhaVinc, { "N8K_ITEDOC"    , SD2->D2_ITEM   	} )
					aadd( aLinhaVinc, { "N8K_PRODUT"    , SD2->D2_COD 		} )
					aadd( aLinhaVinc, { "N8K_TPPROD"    , ''				} )
					aadd( aLinhaVinc, { "N8K_CODCTR"    , cCodCtr			} )
					aadd( aLinhaVinc, { "N8K_SAFRA"    	, cSafra 			} )
					aadd( aLinhaVinc, { "N8K_CODROM"   	, cCodRom		   	} )
					aadd( aLinhaVinc, { "N8K_ITEROM"   	, cItCodRom			} )
					aadd( aLinhaVinc, { "N8K_CODFIX"    , cCodFix			} )
					aadd( aLinhaVinc, { "N8K_CODOTR"    , cCodOtr			} )
					aadd( aLinhaVinc, { "N8K_ITEOTR"    , cIteOtr		 	} )
					aadd( aLinhaVinc, { "N8K_ORPGRC"    , ''			 	} )
					aadd( aLinhaVinc, { "N8K_FECSER"    , cFecser			} )
					aadd( aLinhaVinc, { "N8K_ORIGEM"    , cOrigem			} )
					aadd( aLinhaVinc, { "N8K_HISTOR"    , cHistor			} )
					
					aAdd( aVincIteNF, aLinhaVinc )
					
					//Array de vinculo do Agro com o doc. Sada
					
					IF Len (aVincCabNF) == 0
						aadd( aVincCabNF, { "N8J_FILIAL"	, FwXfilial('N8K')	} )
						aadd( aVincCabNF, { "N8J_DOC"		, SD2->D2_DOC		} )
						aadd( aVincCabNF, { "N8J_SERIE"		, SD2->D2_SERIE		} )
						aadd( aVincCabNF, { "N8J_CLIFOR"    , SD2->D2_CLIENTE	} )
						aadd( aVincCabNF, { "N8J_LOJA"    	, SD2->D2_LOJA		} )
						aadd( aVincCabNF, { "N8J_TPDOC"    	, SD2->D2_TIPO   	} )
						aadd( aVincCabNF, { "N8J_CODCTR"    , cCodCtr			} )
						aadd( aVincCabNF, { "N8J_CODROM"   	, cCodRom		 	} )
						aadd( aVincCabNF, { "N8J_CODFIX"	, cCodFix			} )
						aadd( aVincCabNF, { "N8J_CODOTR"   	, cCodOtr			} )
						aadd( aVincCabNF, { "N8J_ORPGRC"	, ''				} )
						aadd( aVincCabNF, { "N8J_FECSER"	, cFecser			} )
						aadd( aVincCabNF, { "N8J_ORIGEM"	, 'OGA251'			} )
						aadd( aVincCabNF, { "N8J_HISTOR"	, FWI18NLang("OGA251","STR0061",61)	} )
					EndIf
					
					//Gerando o link com o pv de saida
					
					IF len(aVincCab) > 0
						nPosCpo:= ASCAN(aVincCab, {|aVincCab| aVincCab[1] ==  'N8H_NUMPV' })
						IF ! Alltrim ( aVincCab[nPosCpo] ) ==  SD2->D2_PEDIDO
							lVinculou := fAgrVncPV (aVincCab,aVincITE  , 3)  	//Incluir
						EndIF
						aVincCab := {}
						aVincITE := {}
					EndIF
					
					aLinhaVinc := {}
					aadd( aLinhaVinc, { "N8I_FILIAL"    	, FwXfilial('N8I') 			} )
					aadd( aLinhaVinc, { "N8I_ITEMPV"    	, SD2->D2_ITEMPV			} )
					aadd( aLinhaVinc, { "N8I_PRODUT"    	, SD2->D2_COD				} )
					aadd( aLinhaVinc, { "N8I_TPPROD"    	, ''			 			} )
					aadd( aLinhaVinc, { "N8I_CODCTR"    	, cCodCtr					} )
					aadd( aLinhaVinc, { "N8I_SAFRA"    		, cSafra					} )
					aadd( aLinhaVinc, { "N8I_CODROM"    	, cCodRom					} )
					aadd( aLinhaVinc, { "N8I_ITEROM"    	, cItcodRom					} )
					aadd( aLinhaVinc, { "N8I_CODFIX"    	, cCodFIX					} )
					aadd( aLinhaVinc, { "N8I_CODOTR"   		, cCodOtr					} )
					aadd( aLinhaVinc, { "N8I_ITEOTR"   		, cIteOTR					} )
					aadd( aLinhaVinc, { "N8I_ORPGRC"   		, ''						} )
					aadd( aLinhaVinc, { "N8I_FECSER"   		, cFecser					} )
					aadd( aLinhaVinc, { "N8I_ORIGEM"    	, cOrigem		 			} )
					aAdd( aLinhaVinc, { "N8I_HISTOR"    	, cHistor					} )
					aAdd(aVincITE, aLInhaVinc )
					
					// Criando Array de vinculo
					// Alimentando as tabelas de auxiliares de vinculo com ERP
					
					IF len( avincCab) == 0
						aadd( aVincCab, { "N8H_FILIAL"      , FwXfilial('N8H') 						} )
						aadd( aVincCab, { "N8H_NUMPV"    	, SD2->D2_PEDIDO			  			} )
						aadd( aVincCab, { "N8H_CODCTR"    	, cCodCtr					 			} )
						aadd( aVincCab, { "N8H_CODROM"    	, cCodRom								} )
						aadd( aVincCab, { "N8H_CODFIX"   	, cCodFix								} )
						aadd( aVincCab, { "N8H_CODOTR"   	, cCodOtr								} )
						aadd( aVincCab, { "N8H_ORPGRC"   	, ''									} )
						aadd( aVincCab, { "N8H_FECSER"   	, cFecser								} )
						aadd( aVincCab, { "N8H_ORIGEM"   	, cOrigem								} )
						aAdd( aVincCab, { "N8H_HISTOR"    	, cHistor								} )
					EndIF
					
					SD2->( DbSkip() )
				EnddO
				
				dbSelectArea( "SE1" ) 	// Titulo a Receber
				dbSetOrder( 2 )  		//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				SE1-> ( dbSeek( xFilial( "SE1" ) + SF2->( F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DUPL ) ) )
				While	.Not. SE1->( Eof() ) .And. SE1->( E1_FILIAL ) == xFilial( "SE1" );
					.And. SE1->( E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM ) ==  SF2->( F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DUPL )
					
					DbselectArea( 'N8L' )
					N8L->( dbSetOrder( 1 ) ) // N8L_FILIAL + N8L_PREFIX + N8L_PARCEL + N8L_NUM + N8L_TIPO
					IF .NOT. N8L->(DbSeek( FwXfilial('N8L') + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
						
						//Removento o vinculo da SE1
						aLinVncAux := {}
						
						aadd( aLinVncAux, { "N8L_FILIAL"    	, FwXfilial('N8L') 				} )
						aadd( aLinVncAux, { "N8L_FILORI"    	, SE1->E1_FILORIG 				} )
						aadd( aLinVncAux, { "N8L_PREFIX"    	, SE1->E1_PREFIXO				} )
						aadd( aLinVncAux, { "N8L_NUM"    		, SE1->E1_NUM					} )
						aadd( aLinVncAux, { "N8L_PARCEL"    	, SE1->E1_PARCELA				} )
						aadd( aLinVncAux, { "N8L_TIPO"    		, SE1->E1_TIPO					} )
						aadd( aLinVncAux, { "N8L_CODCTR"    	, cCodCtr						} )
						aadd( aLinVncAux, { "N8L_SAFRA"    		, cSafra						} )
						aadd( aLinVncAux, { "N8L_CODROM"    	, cCodRom						} )
						aadd( aLinVncAux, { "N8L_ITEROM"   		, cItcodRom						} )
						aadd( aLinVncAux, { "N8L_CODFIX"   		, cCodFix						} )
						aadd( aLinVncAux, { "N8L_CODOTR"    	, cCodOtr						} )
						aadd( aLinVncAux, { "N8L_ORPGRC"   		, ''							} )
						aadd( aLinVncAux, { "N8L_FECSER"   		, cFecser						} )
						aadd( aLinVncAux, { "N8L_ORIGEM"    	, cOrigem						} )
						aAdd( aLinVncAux, { "N8L_HISTOR"    	, cHistor						} )
						
						aAdd(aVncCRec, aLinvncAux)
					EndIF
					
					SE1->( DbSkip() )
					
				EndDo
				
				IF len( aVincCab ) > 0
					lVinculou := fAgrVncPV (aVincCab,aVincITE  , 3)  			//Incluir PV
				EndIF
				
				IF len( aVincCabNF ) > 0
					lVinculou := fAgrVncNFS (aVincCabNF,aVincIteNF  , 3)  		//Incluir NF
				EndIF
				
				IF  Len( aVncCRec ) > 0
					fAgrVncRec (aVncCRec, 3 )  	//Incluir  Se1
				EndIF
				
				aVincCab	:= {}
				aVincITE	:= {}
				aVincCabNF	:= {}
				aVincIteNF	:= {}
				aLinVncAux	:= {}
				aVncCRec	:= {}
				
			EndIF
			(cqry)->( DbSkip() )
		EndDo
	EndIF

	RestArea(aAreaAtu)
	RestArea(aAreaSF2)
	RestArea(aAreaSD2)
	RestArea(aAreaSE1)

Return( lEhDocOG )

/*/{Protheus.doc} RetSaldo
    Função responsável por realizar o estorno de saldo de valor na NN7 e acionar a função de ajuste das previsões
    Nesta função as tabela SE1 e NJM ja estao possicionadas e não há necessidade de posicionar novamente.
    @type  Static Function
    @author filipe.olegini
    @since 06/06/2018
    @see (links_or_references)
/*/
 Static Function RetSaldo()
    Local aAreaN9M  := N9M->(GetArea())
	Local aAreaN9K  := N9K->(GetArea())
	Local aAreaSE1  := SE1->(GetArea())
	Local aAreaNN7  := NN7->(GetArea())
    Local cAliasN9K := GetNextAlias()
    Local cQuery    := " "
	Local aSldNN7   := {}
	Local nValPrev  := 0

    cQuery := " SELECT N9K_SEQPF, N9K_VALOR, N9K_FILIAL , N9K_CODCTR , N9K_CODROM , N9K_ITEROM , N9K_FILTIT , N9K_PREFIX , N9K_NUM , N9K_PARCEL , N9K_TIPO " 
    cQuery +=   " FROM  " + RetSqlname("N9K")
    cQuery +=  " WHERE D_E_L_E_T_ = '' "
    cQuery +=    " AND N9K_FILIAL = '" + FwXfilial("N9K") + "'"
    cQuery +=    " AND N9K_CODCTR = '" + NJM->NJM_CODCTR + "'"
    cQuery +=    " AND N9K_CODROM = '" + NJM->NJM_CODROM + "'"
    cQuery +=    " AND N9K_ITEROM = '" + NJM->NJM_ITEROM + "'"
    cQuery +=    " AND N9K_PREFIX = '" + SF2->F2_SERIE + "'"
    cQuery +=    " AND N9K_NUM    = '" + SF2->F2_DOC + "'"
    cQuery +=    " AND N9K_TIPO   = 'NF'"

    cQuery := ChangeQuery( cQuery )

    If Select(cAliasN9K) <> 0
        (cAliasN9K)->(dbCloseArea())
    EndIf

    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasN9K,.T.,.T.)

    While (cAliasN9K)->(!EOF())
		aSldNN7 := {}         		
		
		If N9M->(DbSeek((cAliasN9K)->(N9K_FILIAL + N9K_CODCTR + N9K_CODROM + N9K_ITEROM + N9K_FILTIT + N9K_PREFIX + N9K_NUM + N9K_PARCEL + N9K_TIPO) ))						
		   /* Um título pode ter sido compensado por mais de uma RA */
		   While N9M->(!Eof()) .and. N9M->(N9M_FILIAL + N9M_CODCTR + N9M_CODROM + N9M_ITEROM + N9M_FILTIT + N9M_PREFIX + N9M_NUM + N9M_PARCEL + N9M_TIPO) == (cAliasN9K)->(N9K_FILIAL + N9K_CODCTR + N9K_CODROM + N9K_ITEROM + N9K_FILTIT + N9K_PREFIX + N9K_NUM + N9K_PARCEL + N9K_TIPO)
				/* DEVOLVE VALOR COMPENSADO */
				aAdd(aSldNN7,  {"NN7_VLCOMP", (cAliasN9K)->N9K_VALOR, "SOMA"} )
				
				/* APAGA N9M */
				RecLock('N9M', .F.)
					N9M->(dbDelete())
				N9M->(MsUnlock()) 									
				N9M->(dbSkip())
			EndDo
		Else
			/* CASO NÃO ENCONTRE N9M, DIMINIU TOTAL TÍTULOS NÃO COMPENSADOS E AUMENTA SALDO DA PREVISAO*/
			aAdd(aSldNN7,  {"NN7_VLTNCO", (cAliasN9K)->N9K_VALOR, "SUBT"} )
			
			If NN7->(dbSeek(FwxFilial("NN7") + (cAliasN9K)->N9K_CODCTR + (cAliasN9K)->N9K_SEQPF))
				If NN7->NN7_TIPEVE != "1"
					If (NN7->NN7_VLRAVI + NN7->NN7_VLTNCO + (cAliasN9K)->N9K_VALOR) > NN7->NN7_VALOR //significa que tem mais compensado. Nesse caso mantém o que já existe de saldo de pr e apenas volta o saldo
						nValPrev := NN7->NN7_VLSALD
					ELSE
						nValPrev :=  NN7->NN7_VALOR - (NN7->NN7_VLRAVI + NN7->NN7_VLTNCO + (cAliasN9K)->N9K_VALOR)
					EndIf
				Else
					nValPrev := NN7->NN7_VLSALD
				EndIf
			EndIf

			aAdd(aSldNN7,  {"NN7_VLTNCO", (cAliasN9K)->N9K_VALOR, "SUBT"} )
			aAdd(aSldNN7,  {"NN7_VLSALD", nValPrev, "ATU"} )
			aAdd(aSldNN7,  {"NN7_STSTIT", "2", "ATU"} )
		EndIf

		/* DIMINIU TOTAL TÍTULO EMITIDOS NN7 */
		aAdd(aSldNN7,  {"NN7_VLTEMI", (cAliasN9K)->N9K_VALOR, "SUBT"} )		
		
		/* ATUALIZA NN7 TOTAL TÍTULOS NÃO COMPENSADOS e NN7_SLDRA SALDO RA */
		OGX018ASLD(FwxFilial("NN7"), (cAliasN9K)->N9K_CODCTR, (cAliasN9K)->N9K_SEQPF, "", aSldNN7)				

		(cAliasN9K)->(dbSkip())
    EndDo

	//chama a função que varre a NN7 toda e reajusta os titulos provisórios
    OGX018ATPR(FWxfilial("NJR"), NJM->NJM_CODCTR, "OGX165")

    (cAliasN9K)->(dbCloseArea())

    RestArea(aAreaN9K)
    RestArea(aAreaSE1)
    RestArea(aAreaNN7)
	RestArea(aAreaN9M)

Return NIL
