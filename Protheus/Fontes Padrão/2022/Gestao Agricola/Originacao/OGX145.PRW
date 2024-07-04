#include "protheus.ch"
#include "fwmvcdef.ch"

/** {Protheus.doc} OGX145
Rotina chamada através do Ponto de Entrada na exclusão do Documento de Entrada ( MATA103 )
Chamado após os PEs: MT100GRV (MATA100A) e MT100GRV (MATA103)

@param: 	lDeleta	-  
@return:	Nil
@author: 	Marlon Richard Trettin
@since: 	25/03/2015
@Uso: 		SIGAAGR
*/
// Função Original:ARMXPE10 
Function OGX145( lDeleta )
	Local aAreaAtu 		:= GetArea()
	Default lDeleta 	:= .f.
	
	If lDeleta
		
		// Exclusão do documento fiscal de entrada
		OGX145B() 
		
	EndIF
	
	RestArea( aAreaAtu )
Return( Nil )

/** {Protheus.doc} OGX145B
Rotina para exclusão do documento fiscal de entrada

@param: 	Nil
@return:	Nil
@author: 	Marlon Richard Trettin
@since: 	25/03/2015
@Uso: 		SIGAAGR
*/
Function OGX145B()
	Local aAreaAtu		:= GetArea()
	Local aAreaSF1 		:= SD1->( GetArea() )
	Local aAreaSD1 		:= SD1->( GetArea() )
	Local _F1FILIAL 	:= SF1->( F1_FILIAL )
	Local _F1CODROM		:= SF1->( F1_CODROM )
	Local _F1SERIE		:= SF1->( F1_SERIE )
	Local _F1DOC		:= SF1->( F1_DOC )
	Local _F1EMISSAO	:= SF1->( F1_EMISSAO )
	Local lNfCmplPrc	:= iIf( SF1->F1_TIPO == 'C', .T., .F. )
	Local cChave		:=''
	Local cChvNNC		:=''
	Local aLinVncAux2	:= {}
	Local aVncCPag		:= {}

	dbSelectArea("SD1")
	SD1->(DbSetOrder(1))
	SD1->(DbSeek(xFilial("SD1")+SF1->(F1_Doc+F1_Serie+F1_Fornece+F1_Loja)))
	While SD1->(!Eof()) .And. SD1->(D1_Filial+D1_Doc+D1_Serie+D1_Fornece+D1_Loja) == SF1->(F1_Filial+F1_Doc+F1_Serie+F1_Fornece+F1_Loja)
		//NKC->( DbSetOrder( 2 ) ) // NKC_FILIAL+NKC_CODCTR+NKC_CODROM+NKC_ITEROM+NKC_SERIE+NKC_DOCTO+NKC_DATA
		//cChave := FWxFilial( "NKC" ) + SD1->(D1_CTROG + D1_CODROM + D1_ITEROM + D1_SERIE + D1_DOC ) + DtoS(SD1->D1_EMISSAO)
		NKC->( DbSetOrder(3) )	//NKC_FILIAL+NKC_DOCTO+NKC_SERIE+NKC_FORCLI+NKC_LOJA+NKC_ITEM
		cChave := FWxFilial( "NKC" ) + SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA ) 
		//-- Addicionado por emerson em 10/02/2015 --//
		IF lNfCmplPrc // -- Qdo estiver Excluindo uma nf. de complemento de Preço tenho q desvincular da NKC --/
			IF NKC->( DbSeek(  cChave  ) )

				While NKC->(!Eof()) .AND. NKC->(NKC_DOCTO + NKC_SERIE + NKC_FORCLI + NKC_LOJA ) == SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA ) 

					// Ajustando Vrs. da Tabela NNC Entregas da Fixação                          
					NNC->( DbSetOrder( 1 ) ) // NNC_FILIAL+NNC_CODCTR+NNC_ITEMFX+NNC_CODROM+NNC_ITEROM
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

					NKC->( DbSkip() )
				EndDo
			EndIF
		EndIf       

		SD1->( DbSkip() )
	EndDo

	If TableInDic("N8M")
		// Exclui vinculo da CPag
		dbSelectArea( "SE2" )
		SE2->( dbSetOrder( 6 ) ) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		IF SE2->( dbSeek( xFilial( "SE2" ) + SF1->( F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DOC ) ) )
			While SE2->( !Eof() )  .And. SE2->E2_FILIAL == xFilial( "SE2" );
			.And. SE2->(E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM ) == SF1->( F1_FORNECE + F1_LOJA + F1_PREFIXO + F1_DOC )
				DbselectArea( 'N8M' )
				N8M->( dbSetOrder( 1 ) )  //N8M_FILIAL+N8M_PREFIX+N8M_NUM+N8M_PARCEL+N8M_TIPO+N8M_FORNEC+N8M_LOJA 
				IF  N8M->(DbSeek( FwXfilial('N8M') + SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))  
					aLinVncAux2 := {}
					aadd( aLinVncAux2, { "N8M_FILIAL"	, SE2->E2_FILIAL				} )
					aadd( aLinVncAux2, { "N8M_FILORI"	, SE2->E2_FILORIG				} )
					aadd( aLinVncAux2, { "N8M_PREFIX"	, SE2->E2_PREFIXO				} )
					aadd( aLinVncAux2, { "N8M_NUM"		, SE2->E2_NUM 					} )
					aadd( aLinVncAux2, { "N8M_PARCEL"	, SE2->E2_PARCELA				} )
					aadd( aLinVncAux2, { "N8M_TIPO"		, SE2->E2_TIPO					} )
					aadd( aLinVncAux2, { "N8M_FORNEC"	, SE2->E2_FORNECE				} )
					aadd( aLinVncAux2, { "N8M_LOJA"    	, SE2->E2_LOJA					} )

					aAdd(aVncCPag,aLinVncAux2)
				EndIF
				SE2->( DbSkip() )
			EndDO
			IF  Len( aVncCPag ) > 0
				fAgrVncPag (aVncCPag, 5 )  	//Excluir
			EndIF
		EndIF
	EndIf
	//-------------------------------------------//
	// Reabre o romaneio relacionado à nota que foi excluída
	OGX145Reabre( xFilial("NJM"), _F1CODROM, _F1SERIE, _F1DOC )

	// Verifica se a NF excluída era uma Nota de Transito
	BeginSql Alias "QryNK2"
		Select
		R_E_C_N_O_ as NK2_RECNO
		From
		%Table:NK2% NK2
		Where
		NK2.NK2_FILIAL = %exp:_F1FILIAL% And
		NK2.NK2_SERNFT = %exp:_F1SERIE% And
		NK2.NK2_NUMNFT = %exp:_F1DOC% And
		NK2.NK2_DATNFT = %exp:DtoS( _F1EMISSAO )% And
		NK2.%NotDel%
	EndSql
	If .Not. QryNK2->( Eof() )

		NK2->( dbGoto( QryNK2->( NK2_RECNO ) ) )

		// Volta o status da Ordem de Transito para 1=Ordem de Transito 
		If NK2->( RecLock( "NK2", .f. ) )
			NK2->( NK2_STATUS )	:= "1"  // 1=Ordem de Transito
			NK2->( NK2_ROMANE )	:= Space( TamSX3( "NK2_ROMANE" )[1] )
			NK2->( NK2_SERNFT )	:= Space( TamSX3( "NK2_SERNFT" )[1] )
			NK2->( NK2_NUMNFT )	:= Space( TamSX3( "NK2_NUMNFT" )[1] )
			NK2->( NK2_DATNFT )	:= CtoD( "  /  /  " )
			NK2->( MsUnLock() )
		EndIf
	EndIf
	QryNK2->( dbCloseArea() )

	//-------------------------------------------//
	// Verifica se a NF excluída era uma Nota de complementodo romaneio de entrada(DXM - AGRA600)
	BeginSql Alias "QryDXM"
		Select
		R_E_C_N_O_ as DXM_RECNO
		From
		%Table:DXM% DXM
		Where
		DXM.DXM_FILIAL = %exp:_F1FILIAL% And
		DXM.DXM_NFCOMP = %exp:_F1DOC% And
		DXM.DXM_SRCOMP = %exp:_F1SERIE% And
		DXM.%NotDel%
	EndSql
	If .Not. QryDXM->( Eof() )
		DXM->( dbGoto( QryDXM->( DXM_RECNO ) ) )
		// limpa campo de nf de complemento do romaneio de entrada(DXM - AGRA600)
		If DXM->( RecLock( "DXM", .f. ) )
			DXM->( DXM_NFCOMP )	:= Space( TamSX3( "DXM_NFCOMP" )[1] )
			DXM->( DXM_SRCOMP )	:= Space( TamSX3( "DXM_SRCOMP" )[1] )
			DXM->( MsUnLock() )
		EndIf
	EndIf
	QryDXM->( dbCloseArea() )

	RestArea( aAreaSD1 )
	RestArea( aAreaSF1 )
	RestArea( aAreaAtu )
Return( NIL )

/** {Protheus.doc} OGX145Reabre
Rotina que reabre o romaneio relacionado à nota que foi excluída ou não existe na base

@param: 	Nil
@return:	Nil
@author: 	Marlon Richard Trettin
@since: 	25/03/2015
@Uso: 		SIGAAGR
*/
Function OGX145Reabre( pcFILIAL, pcCODROM, pcSERIE, pcDOC )
	Local aAreaAtu 	:= GetArea()
	Local aAreaNJJ	:= NJM->( GetArea() )
	Local aAreaNJM	:= NJM->( GetArea() )
	Local lExcDev as logical

	lExcDev := .F.

	// Seleciona os registros de NJM (itens do romaneio) que possuem status fiscal = SIM (NJM_STAFIS = '2')
	BeginSql Alias "QryNJM"
		Select NJM.R_E_C_N_O_ as NJM_RECNO
		  From %Table:NJM% NJM
		 Where NJM.NJM_FILIAL = %exp:pcFILIAL% 
		   And	NJM.NJM_CODROM = %exp:pcCODROM% 
		   And	NJM.NJM_DOCSER = %exp:pcSERIE% 
		   And	NJM.NJM_DOCNUM = %exp:pcDOC% 
		   And NJM.NJM_STAFIS = %exp:"2"% 
		   And	NJM.%NotDel%
	EndSql
	While .Not. QryNJM->( Eof() )
			
		DbSelectArea( "NJM" )
		NJM->( dbGoto( QryNJM->( NJM_RECNO ) ) )

		If NJM->( NJM_TIPO ) $ "9"
			lExcDev := .T.			
		EndIf
		
		// Atualiza o registro da NJM, reabrindo o mesmo
		OGX145ANJM()
		
		If NJM->( NJM_TIPO ) $ "4|5|8|9"
			
			// Atualiza valores financeiros provisorios do contrato
			OGA250ATUF( NJM->( NJM_CODCTR ), NJM->( NJM_QTDFIS ), IIF(NJM->( NJM_TIPO ) $ "4|5","1","2" ) )
			

		ElseIf NJM->( NJM_TIPO ) = '3' //Entrada para Depósito
			
			/******************************************************************************************************/
			/**            EXCLUSÃO CÁLCULO SERVIÇO QUANDO FOR RETENÇÃO QUE GEROU ROMANEIO RETORNO SIMBOLICO     **/
			/******************************************************************************************************/
			dbSelectArea( 'NKG' )
			dbSetOrder( 2 )
			dbSeek( xFilial( 'NKG' ) + NJM->( NJM_CODROM + NJM_ITEROM ) ) 
			While ! NKG->( Eof() ) .And. NKG->( NKG_FILIAL + NKG_CODROM + NKG_ITEROM ) == xFilial('NKG') + NJM->( NJM_CODROM + NJM_ITEROM )
					
				If RecLock( 'NKG', .f. )
					NKG->( dbDelete() )
					NKG->( MsUnlock() )
				EndIf
				
				NKG->( dbSkip() )
			EndDo
			/******************************************************************************************************/
			
		EndIf
		
		QryNJM->( dbSkip() )
	EndDo
	
	If lExcDev

		OGX145EDEV(pcFILIAL, pcCODROM, pcSERIE, pcDOC) 

	EndIf

	QryNJM->( dbCloseArea() )
	
	// Atualiza o registro de NJJ, reabrindo o romaneio
	OGX145AtNJJ( pcFILIAL, pcCODROM )
	
	RestArea( aAreaNJM )
	RestArea( aAreaNJJ )
	RestArea( aAreaAtu )
	
Return( Nil )


/** {Protheus.doc} OGX145ANJM
Atualiza o registro de NJM reabrindo. 

@param: 	pcNumPed - Numero do PV
@return:	Nil
@author: 	Marlon Richard Trettin
@since: 	20/04/2015
@Uso: 		SIGAAGR 
*/
Function OGX145ANJM( pcNumPV )
	Local aAreaNJM	:= GetArea( "NJM" )
	
	// Volta o status fiscal do romaneio para NAO (NJM_STAFIS = '1')
	If NJM->( RecLock( "NJM", .f. ) )
		NJM->( NJM_STAFIS )	:= "1"  //1=Sem Fiscal;2=Com Fiscal;3=Gerencial
		NJM->( NJM_DTRANS )	:= CtoD( "//" )
		If NJM->NJM_TPFORM == "1" ;			// Se Formulário Próprio = 1 ( SIM )
		.Or. NJM->( NJM_TIPO ) $ "2|4|6|8" // ou Tipo do Romaneio = SAIDA
			NJM->( NJM_DOCSER )	:= Space( TamSX3( "NJM_DOCSER" )[1] )
			NJM->( NJM_DOCNUM )	:= Space( TamSX3( "NJM_DOCNUM" )[1] )
			NJM->( NJM_DOCEMI )	:= CtoD( "//" )
			NJM->( NJM_DOCESP ) := Space( TamSX3( "NJM_DOCESP" )[1] )
			NJM->( NJM_CHVNFE ) := Space( TamSX3( "NJM_CHVNFE" )[1] )
		EndIf
		If Empty( pcNumPV )
			NJM->( NJM_PEDIDO ) := Space( TamSX3( "NJM_PEDIDO" )[1] )
		EndIf
		
		NJM->( MsUnLock() )
	EndIf
	
	RestArea( aAreaNJM )
Return( Nil )

/** {Protheus.doc} OGX145AtNJJ
Atualiza o registro de NJJ reabrindo o romaneio. 

@param: 	pcFilial - Filial do romaneio
@param: 	pcCodRom - Código do romaneio
@return:	Nil
@author: 	Marlon Richard Trettin
@since: 	20/04/2015
@Uso: 		SIGAAGR 
*/
Function OGX145AtNJJ( pcFilial, pcCodRom )
	Local aArea		:= GetArea()
	Local aAreaNJJ	:= NJJ->(GetArea())
	Local aAreaNJM	:= NJM->(GetArea())	
	Local lFiscal   := .F. //Verifica se h? alguma NJM com nota vinculada ainda

	NJJ->( DbSetOrder( 1 ) )
	If NJJ->( dbSeek( pcFilial + pcCodRom ) )
		
		DbselectArea("NJM")
		DbSetOrder(1)
		DbSeek(pcFilial + pcCodRom)
		While NJM->(!EOF()) .AND. NJM->NJM_FILIAL+NJM->NJM_CODROM == pcFilial + pcCodRom
			If !Empty(NJM->NJM_DOCNUM) .AND. !lFiscal
				lFiscal := .T.
			EndIf
			NJM->(DbSkip())
		EndDo
		// Atualiza o status do romaneio (NJJ) caso todos os NJM estejam estornados
		If !lFiscal .AND. RecLock( "NJJ", .f. ) 
			NJJ->( NJJ_STATUS ) := "2"  // 2=Atualizado
			NJJ->( NJJ_STAFIS ) := "1"  // 1=Sem Fiscal
			NJJ->( NJJ_DTRANS ) := CtoD( "//" )
			If NJJ->( NJJ_TPFORM ) == "1"; 		// Se Formulÿrio Prÿprio = 1 ( SIM )
			.Or. NJJ->( NJJ_TIPO ) $ "2|4|6|8" // ou Tipo do Romaneio = SAIDA
				NJJ->( NJJ_DOCSER ) := Space( TamSX3( "NJJ_DOCSER" )[1] )
				NJJ->( NJJ_DOCNUM ) := Space( TamSX3( "NJJ_DOCNUM" )[1] )
				NJJ->( NJJ_DOCEMI ) := CtoD( "//" )
				NJJ->( NJJ_DOCESP ) := Space( TamSX3( "NJJ_DOCESP" )[1] )
				NJJ->( NJJ_CHVNFE ) := Space( TamSX3( "NJJ_CHVNFE" )[1] )
			EndIf
			NJJ->( msUnLock() )
		EndIf
		
	EndIf

	//Prote??o
	If TableInDic('N9G') .AND. TableInDic('N9K') .AND. TableInDic('N9A') 
		// Atualiza os saldos financeiros do contrato - DAGROCOM-3978
		OGX310(1,pcCodRom)
	EndIf

	RestArea( aAreaNJJ )
	RestArea( aAreaNJM )
	RestArea( aArea )
Return( Nil )

/*/{Protheus.doc} OGX145EDEV()
    Atualização dos valores após a exclusão do documento de entrada do tipo dev.
	Tabelas alteradas: N9J, NN7, N9G, N84, N9K, N8T, NN8, N8D
    @type  Function
    @author mauricio.joao
    @since 03/10/2018
    @version 1.0
    @param pcFILIAL, char, filial
           pcCODROM, char, codigo do romaneio
           pcSERIE, char, serie do doc de entrada
		   pcDOC, char, numero do documento de entrada
    /*/
 Function OGX145EDEV(pcFILIAL as char, pcCODROM as char, pcSERIE as char, pcDOC as char)

Local cAliasN9K as char
Local cAliasN9E as char
Local cAliasN8T as char
Local cAliasNN8 as char
Local cAliasN8D as char
Local aN9J as array
Local aNN7 as array
Local aN9G as array
Local aN84 as array
Local aN9K as array
Local aN8T as array
Local aNN8 as array
Local aN8D as array
Local cQtdDev as char
Local nValor as numeric

cAliasN9K := GetNextAlias()
cAliasN9E := GetNextAlias()
cAliasN8T := GetNextAlias()
cAliasNN8 := GetNextAlias()
cAliasN8D := GetNextAlias()

aN9J := N9J->(GetArea())
aNN7 := NN7->(GetArea())
aN9G := N9G->(GetArea())
aN84 := N84->(GetArea())
aN9K := N9K->(GetArea())
aN8T := N8T->(GetArea())
aNN8 := NN8->(GetArea())
aN8D := N8D->(GetArea())

BeginSQL Alias cAliasN9E 

	SELECT 
		NJM_FILIAL, N9E.N9E_CODROM, N9E.N9E_QTDEST, 
		N9E.N9E_QTDRET, NJM.NJM_CODROM, NJM_ITEROM, 
		NJM_FILORG, NJM_CODCTR, NJM_SEQPRI, NJM_VLRTOT, NJM_QTDFIS
	FROM 
		%Table:N9E% N9E
	INNER JOIN 
		%Table:NJM% NJM ON 
		NJM_DOCNUM = N9E_DOC AND 
		NJM.%notDel%
	WHERE 
		N9E.%notDel% AND 
		N9E_CODROM = %Exp:pcCODROM%

EndSQL

While (cAliasN9E)->(!Eof())

    BeginSQL Alias cAliasN9K

		SELECT 
			N9K_CODCTR, N9K_ITEMPE, N9K_ITEMRF, 
			N9K_QTDEVL, N9K_QTDVNC, N9K_SEQN9J,
			N9K_ITEROM, N9K_VALOR, N9K_ORIGPF,
			N9K_SEQPF, N9K_VLRFIX, N9K_FILORI,
			N9K_SEQCP, N9J_CODCTR, N9J_ITEMPE, 
			N9J_ITEMRF, N9J_SEQCP, N9J_SEQPF,             
			N9J_QTDE, N9J_QTDEVT, N9J_SLDQTD,
			N9J_VLFCON, N9J_SEQ           
		FROM 
			%Table:N9K% N9K
		INNER JOIN 
			%Table:N9J% N9J	ON 
			N9K.N9K_CODCTR = N9J_CODCTR AND 
			N9J_ITEMPE = N9J_ITEMPE	AND
			N9J_ITEMRF = N9J_ITEMRF AND 
			N9K_SEQN9J = N9J_SEQ AND 
			N9J.%notDel%
		WHERE 
			N9K.%notDel% AND 
			N9K_CODROM = %Exp:(cAliasN9E)->(NJM_CODROM)%

    EndSQL

    nValor  :=  ( (cAliasN9E)->(NJM_VLRTOT) / (cAliasN9E)->(NJM_QTDFIS) ) * (cAliasN9E)->(N9E_QTDRET)
    cQtdDev := (cAliasN9E)->(N9E_QTDRET)

    Begin Transaction
        N9J->(DbSetOrder(1))
        If N9J->(DbSeek(xFilial('N9J')+(cAliasN9K)->(N9K_CODCTR)+;
        (cAliasN9K)->(N9J_ITEMPE)+(cAliasN9K)->(N9J_ITEMRF)+;
        (cAliasN9K)->(N9J_SEQCP)+(cAliasN9K)->(N9J_SEQPF)+;
        (cAliasN9K)->(N9J_SEQ)))
            If RecLock('N9J',.F.)
			    N9J->N9J_VALOR  -= nValor
				N9J->N9J_VLFCON += nValor
                N9J->N9J_SLDQTD -= cQtdDev
                N9J->N9J_QTDEVT += cQtdDev                
                N9J->(MsUnLock())
            EndIf
        EndIf

		If ((cAliasN9K)->(N9K_ORIGPF) <> (cAliasN9K)->(N9K_SEQPF))
            //prev. fin original
       		NN7->(DbSetOrder(1))
			If NN7->(DbSeek(xFilial('NN7')+(cAliasN9K)->(N9K_CODCTR)+(cAliasN9K)->(N9K_ORIGPF)))
				If RecLock('NN7',.F.)
					NN7->NN7_VALOR  -= nValor
					NN7->NN7_VLSALD -= nValor 
					NN7->NN7_QTDE   -= cQtdDev
					NN7->NN7_SLDQTD -= cQtdDev  
						NN7->(MsUnLock())
				EndIf
			EndIf
		
        	//prev. fin fake
			NN7->(DbSetOrder(1))
			If NN7->(DbSeek(xFilial('NN7')+(cAliasN9K)->(N9K_CODCTR)+(cAliasN9K)->(N9K_SEQPF)))
				cItemPV := NN7->NN7_ITEM
				cParcel := NN7->NN7_PARCEL
				If RecLock('NN7',.F.)
					NN7->NN7_VALOR  += nValor
					NN7->NN7_VLSALD += nValor
					NN7->NN7_QTDE   += cQtdDev
					NN7->NN7_VLDEVL -= nValor  
					NN7->NN7_VLCOMP -= nValor   
					NN7->NN7_VLRAVI -= nValor     
						NN7->(MsUnLock())
				EndIf
			EndIf
		Else
			NN7->(DbSetOrder(1))
			If NN7->(DbSeek(xFilial('NN7')+(cAliasN9K)->(N9K_CODCTR)+(cAliasN9K)->(N9K_SEQPF)))
				cItemPV := NN7->NN7_ITEM
				cParcel := NN7->NN7_PARCEL
				If RecLock('NN7',.F.)
					//NN7->NN7_VALOR  -= nValor
					NN7->NN7_VLSALD -= nValor
					NN7->NN7_SLDQTD -= cQtdDev
					NN7->NN7_VLDEVL -= nValor  
					NN7->NN7_VLCOMP -= nValor   
					NN7->NN7_VLRAVI -= nValor     
						NN7->(MsUnLock())
				EndIf
			EndIf
		EndIf

        N9G->(DbSetOrder(1))
        If N9G->(DbSeek(xfilial('N9G') + (cAliasN9K)->(N9K_CODCTR) + cItemPV + cParcel + pcDOC  )) 
            If ( N9G->N9G_VALOR  - nValor ) > 0 
                If RecLock('N9G',.F.)
                    N9G->N9G_VALOR  -= nValor          
                        N9G->(MsUnLock())
                EndIf
            Else
                If RecLock('N9G',.F.)
                    N9G->(DbDelete())      
                        N9G->(MsUnLock())
                EndIf
            EndIf
        EndIf

        N84->(DbSetOrder(1))
        IF N84->(DbSeek((cAliasN9K)->N9K_FILORI + (cAliasN9K)->(N9K_CODCTR) + (cAliasN9K)->N9K_SEQCP))
            If RecLock("N84", .F.)
                N84->N84_QTDVNC += cQtdDev	
                	N84->(MsUnlock())
            EndIf
        Endif

        N9K->(DbSetOrder(1))
        If N9K->(DbSeek(xFilial('N9K')+(cAliasN9E)->(NJM_CODROM)+(cAliasN9K)->(N9K_ITEROM)))
            If RecLock('N9K',.F.)
                N9K->N9K_QTDEVL -= cQtdDev
                N9K->N9K_VLRFIX += nValor
                    N9K->(MsUnLock())
            EndIf
        EndIf

		BeginSQL Alias cAliasN8T

			SELECT 
				R_E_C_N_O_ AS RECNO,
				N8T.* 
			FROM
				%Table:N8T% N8T
			WHERE 
				N8T.%notDel% AND 
				N8T_FILCTR = %xfilial:NJR% AND 
				N8T_CODROM = %Exp:(cAliasN9E)->(NJM_CODROM)% AND 
				N8T_TIPPRC = '1'

		EndSQL

			N8T->(dbGoTo((cAliasN8T)->RECNO))                                                                                             
			If RecLock('N8T',.F.)
                N8T->N8T_QTDEVL -= cQtdDev 
                    N8T->(MsUnLock())
            EndIf 

		BeginSQL Alias cAliasNN8

			SELECT 
				R_E_C_N_O_ AS RECNO, NN8.*
			FROM 
				%Table:NN8% NN8
			WHERE 
				NN8.%notDel% AND 
				NN8_FILIAL = %xFilial:NN8% AND 
				NN8_CODCTR = %Exp:(cAliasN9K)->(N9K_CODCTR)% AND 
				NN8_ITEMFX = %Exp:(cAliasN8T)->(N8T_ITEMFX)%
				
		EndSQL

			NN8->(dbGoTo((cAliasNN8)->RECNO))                                                                                             
			If RecLock('NN8',.F.)
                NN8->NN8_QTDENT += cQtdDev
                    NN8->(MsUnLock())
            EndIf 

		BeginSQL Alias cAliasN8D

			SELECT 
				R_E_C_N_O_ AS RECNO, 
				N8D.*
			FROM 
				%Table:N8D% N8D
			WHERE 
				N8D.%notDel% AND 
				N8D_FILIAL = %xFilial:N8D% AND 
				N8D_CODCTR = %Exp:(cAliasN9K)->(N9K_CODCTR)% AND 
				N8D_ITEMFX = %Exp:(cAliasN8T)->(N8T_ITEMFX)% AND 
				N8D_SEQVNC = %Exp:(cAliasN8T)->(N8T_SEQFIX)%
				
		EndSQL

			N8D->(dbGoTo((cAliasN8D)->RECNO))                                                                                             
			If RecLock('N8D',.F.)
                N8D->N8D_QTDFAT += cQtdDev
                    N8D->(MsUnLock())
            EndIf 


		(cAliasN8D)->(DbCloseArea())
		(cAliasNN8)->(DbCloseArea())
        (cAliasN9K)->(DbCloseArea())
		(cAliasN8T)->(DbCloseArea())	

    End Transaction

    (cAliasN9E)->(DbSkip())
EndDo

(cAliasN9E)->(DbCloseArea())

RestArea(aN9J) 
RestArea(aNN7) 
RestArea(aN9G) 
RestArea(aN84)
RestArea(aN9K) 
RestArea(aN8T)
RestArea(aNN8)
RestArea(aN8D)

Return
