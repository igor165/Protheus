#INCLUDE "protheus.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "OGX175.ch"
#INCLUDE "TBICONN.CH"

/** {Protheus.doc} OGX765
Rotina a ser executada através da função "Formulas" com a finalidade de
incluir os registros de relacionamentos para as tabelas padrões e suas respectivas
tabelas complementares. O programa pode ser executado de duas maneiras:
1 - Parametro lTodos = .T. - Irá executar o processo para todos os registros localizados
na consutla de cAliasQry
2 - Parametro lTodos = .F. (Padrão) - O programa irá processar todos os registros cujo valor
de NJJ_STATUS seja diferente de 3 e 4 (encerrado e cancelado)

A rotina prevê a não inclusão dos registros das tabelas relacionadas em duplicidade, desta forma,
ao executar mais de uma vez, somente os registros não processados irão atualizar as tabelas.

@param: 	lTodos : Boolean
@return:	Nil
@author: 	Marcelo Ferrari / Emerson Coelho
@since: 	23/02/2018
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGX175(lTodos,cDataQry)
    Local aArea := GetArea()
    Local cAliasQry := ""
    Local cSql      := ""
	Local nCont 	:= 0
    Default lTodos    := .F.
	Default cDataQry := "20220101" //padrão, caso cliente deseja periodo anterior deverá passar no parametro, Fixado periodo para não onerar base do cliente e tabelas existem após release P12.1.23

	If .Not. MsgYesNo(STR0005,STR0004 + FWxFilial("NJJ")) //##"Esta Rotina irá executar o acerto as tabelas complementares(N8H,N8I,N8J,N8K,N8L) dos romaneios de saída, deseja continuar?"###"Rotina de acerto - Filial " 
		Return( .f. )  
	EndIf
    
    cSql := "SELECT DISTINCT NJJ.NJJ_FILIAL, NJJ.NJJ_CODROM, NJJ.NJJ_STATUS, NJM.NJM_FILIAL, " + ;
                                   "NJM.NJM_DOCNUM, NJM.NJM_DOCSER, NJM.NJM_CODENT, NJM.NJM_LOJENT, " + ;
                                   "F2_TIPO, F2_CLIENTE, F2_LOJA " + ;
                           "FROM " + RetSqlName("NJJ") + " NJJ " + ; 
                               "INNER JOIN " + RetSqlName("NJM") + " NJM ON " + ;
                                    "NJJ.NJJ_FILIAL = NJM.NJM_FILIAL AND " + ;
                                    "NJJ.NJJ_CODROM = NJM.NJM_CODROM AND " + ;
                                    "NJJ.D_E_L_E_T_ = '' " + ; 
						       "INNER JOIN " + RetSqlName("SF2") + " SF2 ON " + ; 
						            "SF2.F2_FILIAL = '" + fwxFilial("SF2") + "' AND " + ; 
						            "SF2.F2_DOC    = NJM.NJM_DOCNUM AND " + ;	
						            "SF2.F2_SERIE  = NJM.NJM_DOCSER AND " + ;
                                    "SF2.F2_EMISSAO >='"+cDataQry+"' AND "+;
						            "SF2.D_E_L_E_T_ = '' " + ;									
                           "WHERE 1=1 " + ;
                           "AND NJJ.NJJ_FILIAL = '" + fwxFilial("NJJ") + "' "+;
                           "AND NJM.NJM_DOCNUM IS NOT NULL " + ;
                           "AND NJM.D_E_L_E_T_ = '' "+;
                           "AND ( NJM_CODROM NOT IN (SELECT N8H_CODROM FROM " + RetSqlName("N8H") + " N8H WHERE N8H.D_E_L_E_T_ = '' AND N8H_FILIAL=NJM.NJM_FILIAL)  "+;
								" OR NJM_CODROM NOT IN (SELECT N8I_CODROM FROM " + RetSqlName("N8I") + " N8I WHERE N8I.D_E_L_E_T_ = '' AND N8I_FILIAL=NJM.NJM_FILIAL) "+;
								" OR NJM_CODROM NOT IN (SELECT N8J_CODROM FROM " + RetSqlName("N8J") + " N8J WHERE N8J.D_E_L_E_T_ = '' AND N8J_FILIAL=NJM.NJM_FILIAL)  "+; 
								" OR NJM_CODROM NOT IN (SELECT N8K_CODROM FROM " + RetSqlName("N8K") + " N8K WHERE N8K.D_E_L_E_T_ = '' AND N8K_FILIAL=NJM.NJM_FILIAL) "+;
								" OR ( NJM_CODROM NOT IN (SELECT N8L_CODROM FROM " + RetSqlName("N8L") + " N8L WHERE N8L.D_E_L_E_T_ = '' AND N8L_FILIAL=NJM.NJM_FILIAL) "+; // --NÃO TEM N8L 
								      " AND F2_CLIENTE IN ( SELECT E1_CLIENTE FROM " + RetSqlName("SE1") + " SE1 WHERE SE1.D_E_L_E_T_ = '' AND SE1.E1_FILIAL=SF2.F2_FILIAL "+; //MAS TEM TITULO SE1
															" AND SE1.E1_CLIENTE = SF2.F2_CLIENTE AND SE1.E1_LOJA=SF2.F2_LOJA AND SE1.E1_PREFIXO=SF2.F2_PREFIXO "+;
															" AND SE1.E1_NUM=SF2.F2_DUPL)"+;
								 ")"+;
								")"+;
								"ORDER BY NJJ_FILIAL, NJJ_CODROM"
								
    
    CONOUT(cSql)
    cAliasQry := GetSqlAll( cSql )
    
    If Select(cAliasQry) > 0
       CONOUT("Consulta SLQ Ok")
    Else
		CONOUT("Consulta SQL não retornou dados")
       	Return .F.
    EndIf
    
    (cAliasQry)->(DbGoTop())
    While !( (cAliasQry)->(EOF()) )
       If !((cAliasQry)->NJJ_STATUS $ "4") .OR. lTodos  // diferente de encerrado e cancelado
            
          Processa({|| Ogx175Eql( (cAliasQry)->NJM_DOCNUM,  ; 
                     (cAliasQry)->NJM_DOCSER,  ;
                     (cAliasQry)->F2_TIPO,     ;
                     (cAliasQry)->F2_CLIENTE,  ;
                     (cAliasQry)->F2_LOJA ) }, ;
                     STR0002, ; //"Atualizando tabelas relacionadas"
                     STR0001 ) //"Aguarde"
            nCont++
       EndIf
       (cAliasQry)->(DbSkip())
    EndDo

    CONOUT("SIGAAGR: OGX175 - "+CValToChar(nCont)+" registros ajustados.")
    
    MsgAlert(STR0003) //"Processamento finalizado."

	(cAliasQry)->(DbCloseArea())
    RestArea(aArea)

Return


/*
   Função para equalizar os dados dos contratos em aberto que não possuem registro nas tabelas complementares
*/
function Ogx175Eql( cDocNum, cSerie,cDocTipo, cDoccli, cDocCliLja )

Local cNfTratada 		:= ''
Local aVincCab			:= {}
Local aVincITE 			:= {}
Local aVincCabNF		:= {}
Local aVincIteNF		:= {}
Local aLinVncAux		:= {}
Local aVncCRec			:= {}

Local cqry	:= GetNextAlias()

If .not. Alltrim(cDocTipo) $ "DB"
	dbselectArea( "NJ0" )
	NJ0->( dbSetOrder( 4 ) ) 	// NJ0_FILIAL+NJ0_CODCLI+NJ0_CODCLI
	IF   .not. NJ0->(Dbseek( FwXfilial('NJ0') + cDoccli + cDocCliLja ) )
		Conout('Não foi encontrado o Cliente no Cadastro de entidades')
		Return( .f.)
	EndIF
Else
	dbselectArea( "NJ0" )
	NJ0->( dbSetOrder( 3 ) ) 	//NJ0_FILIAL+NJ0_CODFOR+NJ0_LOJFOR
	IF   .not. NJ0->(Dbseek( FwXfilial('NJ0') + cDoccli + cDocCliLja ) )
		Conout('Não foi encontrado o Fornecedor no Cadastro de entidades')
		Return( .f.)
	EndIF
Endif

BeginSql Alias cQry
	Select SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA,SF2.F2_TIPO,
	F2_PREFIXO, F2_DUPL,
	NJM.*, NKC.*, NK2.*, NKS.*
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
	AND NK2.NK2_NUENFT 	= %Exp:cDocNum%
	AND NK2.NK2_SEENFT	= %Exp:cSerie%
	AND NK2.NK2_CODENT 	= %Exp:NJ0->NJ0_CODENT%
	AND NK2.NK2_LOJENT 	= %Exp:NJ0->NJ0_LOJENT%
	AND NK2.%NotDel%
	LEFT JOIN  %Table:NKS% NKS
	ON  NKS.NKS_FILIAL 	= %xFilial:NKS%
	AND NKS.NKS_DOCNUM 	= %Exp:cDocNum%
	AND NKS.NKS_DOCSER	= %Exp:cSerie%
	AND NKS.NKS_CLIENT 	= %Exp:cDocCli%
	AND NKS.NKS_LOJA 	= %Exp:cDocCliLja%
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
		If SD2->(dbSeek( fwxFilial( "SD2" ) + (cQry)->( F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA ) ) )
			While ! SD2->( Eof() ) .And. SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA ) == fwxFilial("SD2") + (cQry)->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )
				
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
					cHistor += Alltrim(Posicione("SX5",1,fwxFilial("SX5")+'K5' + (cQry)->NJM_TIPO,"X5_DESCRI")) + " - OGX175"
				ElseIF .not. Empty( Alltrim (( cQry )->NKC_DOCTO ) )
					cCodCtr 	:= (cQry)->NKC_CODCTR
					cSafra		:= (cQry)->NJM_CODSAF
					cCodRom		:= (cQry)->NKC_CODROM
					cItcodRom   := (cQry)->NKC_ITEROM
					cCodFIX 	:= (cQry)->NKC_ITEMFX
					cCodOtr		:= ''
					cIteOTR		:= ''
					cFecser		:= ''
					cOrigem		:= 'OGA430B'
					cHistor		:= STR0006 + " - OGX175" //'Complemento de Preço'
				ElseIF .not. Empty( Alltrim (( cQry )->NK2_NUMNFT ))   // Essa sit. so ocorre para um nf. de extorno de nf. de transito
					cCodCtr 	:= (cQry)->NK2_CODCTR
					cSafra		:= (cQry)->NK2_CODSAF
					cCodRom		:= ''
					cItcodRom   := ''
					cCodFIX 	:= ''
					cCodOtr		:= (cQry)->NK2_CODIGO
					cIteOTR		:= '001'		// Para ajustes vou sempre mover o 1o. item
					cFecser		:= ''
					cOrigem		:= 'OGA245'
					cHistor		:= STR0007 + " - OGX175" //'Nota de Transito'
				ElseIF .not. Empty( Alltrim (( cQry )->NKS_DOCNUM ) )
					cCodCtr 	:=  Alltrim(Posicione("NKG",4,fwxFilial("NKG")+( cQry )->NKS_FECSER,"NKG_CODCTR"))
					cSafra		:=  NKG->NKG_CODSAF //SE ESTA POSISIONADO NO POSICIONE ACIMA
					cCodRom		:= ''
					cItcodRom   := ''
					cCodFIX 	:= ''
					cCodOtr		:= ''
					cIteOTR		:= ''
					cFecser		:= ( cQry )->NKS_FECSER
					cOrigem		:= 'OGA261A'
					cHistor		:= STR0008 + " - OGX175" //"Fechamento Servico"
				EndIF
				
				DbselectArea( 'N8K' )
				N8K->( dbSetOrder( 1 ) ) //N8K_FILIAL+N8K_DOC+N8K_SERIE+N8K_CLIFOR+N8K_LOJA+N8K_ITEDOC
				//SE NAO EXISTIR N8K PARA O REGISTRO OU EXISTIR E ROMANEIO OU CONTRATO DIFERENTE, GERA ARRAY PARA O REGISTRO
				IF .NOT. N8K->(DbSeek( FwXfilial('N8K') + SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA))) .OR. N8K->N8K_CODROM != cCodRom .OR. N8K->N8K_CODCTR != cCodCtr
					//Array de vinculo do Agro com o doc. Sada
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
						aadd( aVincCabNF, { "N8J_ORIGEM"	, cOrigem			} )
						aadd( aVincCabNF, { "N8J_HISTOR"	, cHistor	} )
					EndIf
				EndIf
				
				//Gerando o link com o pv de saida				
				IF len(aVincCab) > 0
					nPosCpo:= ASCAN(aVincCab, {|aVincCab| aVincCab[1] ==  'N8H_NUMPV' })
					IF ! Alltrim ( aVincCab[nPosCpo] ) ==  SD2->D2_PEDIDO
						fAgrVncPV (aVincCab,aVincITE  , 3)  	//Incluir
					EndIF
					aVincCab := {}
					aVincITE := {}
				EndIF

				DbselectArea( 'N8I' )
				N8I->( dbSetOrder( 1 ) ) //N8I_FILIAL+N8I_NUMPV+N8I_ITEMPV
				//SE NAO EXISTIR N8I PARA O REGISTRO OU EXISTIR E ROMANEIO OU CONTRATO DIFERENTE, GERA ARRAY PARA O REGISTRO
				IF .NOT. N8I->(DbSeek( FwXfilial('N8I') + SD2->D2_PEDIDO)) .OR. N8I->N8I_CODROM != cCodRom .OR. N8I->N8I_CODCTR != cCodCtr			
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
				EndIf
				
				SD2->( DbSkip() )
			EnddO
			
			dbSelectArea( "SE1" ) 	// Titulo a Receber
			dbSetOrder( 2 )  		//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			SE1->( dbSeek( fwxFilial( "SE1" ) + (cQry)->( F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DUPL ) ) )
			While	.Not. SE1->( Eof() ) .And. SE1->( E1_FILIAL ) == fwxFilial( "SE1" );
				.And. SE1->( E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM ) ==  (cQry)->( F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DUPL )
				
				DbselectArea( 'N8L' )
				N8L->( dbSetOrder( 1 ) ) // N8L_FILIAL + N8L_PREFIX + N8L_PARCEL + N8L_NUM + N8L_TIPO
				//SE NAO EXISTIR N8L PARA O REGISTRO OU EXISTIR E ROMANEIO OU CONTRATO DIFERENTE, GERA ARRAY PARA O REGISTRO
				IF .NOT. N8L->(DbSeek( FwXfilial('N8L') + SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))) .OR. N8L->N8L_CODROM != cCodRom .OR. N8L->N8L_CODCTR != cCodCtr
					//vinculo da SE1
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
					aAdd( aLinVncAux, { "N8L_HISTOR"    	, cHistor							} )
					
					aAdd(aVncCRec, aLinvncAux)
				EndIF
				
				SE1->( DbSkip() )
				
			EndDo
			
			IF len( aVincCab ) > 0
				fAgrVncPV (aVincCab,aVincITE  , 5)  //PRIMEIRO TENTA EXCLUIR, TRATANDO OS CASOS DE REGISTROS JA EXISTENTES MAS COM INCONSISTENCIA, EVITANDO ERRO DE DUPLICIDADE 
				fAgrVncPV (aVincCab,aVincITE  , 3)  //Incluir PV
			EndIF
			
			IF len( aVincCabNF ) > 0
				fAgrVncNFS (aVincCabNF,aVincIteNF  , 5)  //PRIMEIRO TENTA EXCLUIR, TRATANDO OS CASOS DE REGISTROS JA EXISTENTES MAS COM INCONSISTENCIA, EVITANDO ERRO DE DUPLICIDADE 
				fAgrVncNFS (aVincCabNF,aVincIteNF  , 3)  //Incluir NF
			EndIF
			
			IF  Len( aVncCRec ) > 0
				fAgrVncRec (aVncCRec, 5 )  	//PRIMEIRO TENTA EXCLUIR, TRATANDO OS CASOS DE REGISTROS JA EXISTENTES MAS COM INCONSISTENCIA, EVITANDO ERRO DE DUPLICIDADE 
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

(cqry)->( DbCloseArea() )

Return .T.

