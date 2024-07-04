#INCLUDE "OGA261B.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"

Function OGA261B( pcCodEnt, pcLojEnt )
	Local lRetorno := .t.
	
/** Este programa está aguardando a 2a etapa serviços armazenagem, por este motivo está em comentários
	
	Local oDlg		 := Nil
	Local oFwLayer := Nil
	Local oPnNKG	 := Nil
	Local oPnFold	 := Nil
	Local nX       := 0
	
	Local aRetTRB := {} // Variável que recebe o retorno da criação das tabelas temporárias
	
	//		Status Contrato Cod. Desp	Descrição 	Valor Serviço 	Qtd. Ret.										
	
	
	//--- Definição da estrutura da tabela temporária de negócios pendentes ---//
	//[n][01] Nome do campo
	//[n][02] Tipo
	//[n][03] Tamanho
	//[n][04] Decimal
	//[n][05] Titulo
	//[n][06] Picture
	Local aEstruTot := { { "OK", "C", 2, 0 , , } , ;
							{ "T_FILIAL", "C", TamSX3( "NKG_FILIAL" )[ 1 ], 0 , RetTitle( "NKG_FILIAL" )	, PesqPict("NKG","NKG_FILIAL") }, ;
	 						{ "T_CODCTR", "C", TamSX3( "NKG_CODCTR" )[ 1 ], 0 , RetTitle( "NKG_CODCTR" )	, PesqPict("NKG","NKG_CODCTR") }, ;
	 						{ "T_DESCTR", "C", TamSX3( "NKG_DESCTR" )[ 1 ], 0 , RetTitle( "NKG_DESCTR" )	, PesqPict("NKG","NKG_DESCTR") } , ;
	 						{ "T_CODDES",	"C", TamSX3( "NKG_CODDES" )[ 1 ], 0 , RetTitle( "NKG_CODDES" )	, PesqPict("NKG","NKG_CODDES") } , ; 
							{ "T_DESDES", "C", TamSX3( "NKG_DESDES" )[ 1 ], 0 , RetTitle( "NKG_DESDES" )	, PesqPict("NKG","NKG_DESDES") } , ;
							{ "T_CODPRO",	"C", TamSX3( "NKG_CODPRO" )[ 1 ], 0 , RetTitle( "NKG_CODPRO" )	, PesqPict("NKG","NKG_CODPRO") } , ; 
							{ "T_DESPRO", "C", TamSX3( "NKG_DESPRO" )[ 1 ], 0 , RetTitle( "NKG_DESPRO" )	, PesqPict("NKG","NKG_DESPRO") } , ;
							{ "T_QTDRET", "N", TamSX3( "NKG_QTDRET" )[ 1 ], TamSX3( "NKG_QTDRET" )[ 2 ] , RetTitle( "NKG_QTDRET" )	, PesqPict("NKG","NKG_QTDRET") } , ;
							{ "T_QTDAJU", "N", TamSX3( "NKG_QTDAJU" )[ 1 ], TamSX3( "NKG_QTDAJU" )[ 2 ] , STR0009	, PesqPict("NKG","NKG_QTDAJU") } , ; 
							{ "T_QTRETC", "N", TamSX3( "NKG_QTRETC" )[ 1 ], TamSX3( "NKG_QTRETC" )[ 2 ] , RetTitle( "NKG_QTRETC" )	, PesqPict("NKG","NKG_QTRETC") } } 
									
	Local aCpBrwTot := {}
	Local aIndTot   := { "T_FILIAL+T_CODCTR+T_CODDES+T_STATUS" } // Definição dos índices
		
	//--- Variáveis de acesso às tabelas temporárias ---//
	Private cAliasTOT 
	Private cTrabTOT 	
	Private oBrwTot
	
	Private cAliasQry := GetNextAlias()
	Private cNoFldTOT	:= "OK,T_DESPRO,T_DESCTR"
	Private cMarca   := GetMark()
	
	//--- Criação das tabelas temporárias ---//
	// Tabela temporária de Totais
	aRetTRB := AGRCRIATRB( , aEstruTot, aIndTot, FunName(), .T. )
	 
	cTrabTOT 	:= aRetTRB[3] //Nome do arquivo temporário 
	cAliasTOT 	:= aRetTRB[4] //Nome do alias do arquivo temporario
	aCpBrwTot	:= aRetTRB[5] //Matriz com a estrutura do arquivo temporario + label e picture
	
	A261BLoadTot() 
	
	//---GRID CONFIRMAÇÃO EM LOTE							
	oDlg	:= TDialog():New( 0, 0, 660, 960, OemToAnsi( STR0001 ), , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Confirmar Quebra Técnica em Lote"
	oDlg:lEscClose := .f.
	
	//--- Layers ---//
	oFwLayer:= FwLayer():New()
	oFwLayer:Init( oDlg, .f., .t. )
	
		// Entidade
		oFWLayer:AddLine( 'LinLote', 100, .T. )				
		oFWLayer:AddCollumn( 'ColLote', 100, .T., 'LinLote' )
		oPnNKG := oFWLayer:GetColPanel( 'ColLote', 'LinLote' )
		
		
		DEFINE FWFormBrowse oBrwTot DATA TABLE ALIAS cAliasTOT DESCRIPTION STR0002 OF oPnNKG //"Totais"
	    oBrwTot:SetTemporary(.T.)
		oBrwTot:SetdbFFilter(.T.)
		oBrwTot:SetUseFilter(.T.)	
		oBrwTot:SetFieldFilter(AGRITEMCBRW(aCpBrwTot))	
					
		ADD MARKCOLUMN oColumn DATA { || If(( cAliasTOT )->OK == cMarca,'LBOK','LBNO') } ;
		DOUBLECLICK { |oBrwTot| OGA261BCLK( cAliasTOT , oBrwTot) } ;
		HEADERCLICK { |oBrwTot| OGA261BCHK( cAliasTOT , oBrwTot) } OF oBrwTot	
						
		For nx := 1 To Len(aCpBrwTot)
			If !( aCpBrwTot[nX,1] $ cNoFldTOT )
				ADD COLUMN oColumn DATA &('{||'+aCpBrwTot[nX,1]+'}') Type aCpBrwTot[nX,2] Title aCpBrwTot[nX,5] SIZE aCpBrwTot[nX,3] PICTURE aCpBrwTot[nX,6] Of oBrwTot
			EndIf
		Next nx 
		
		oBrwTot:DisableDetails()		
	ACTIVATE FWFormBrowse oBrwTot
		
		
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||  nOpcao := 1,If(!A216BVLD(),nOpcao := 0, oDlg:End()) },{|| oDlg:End() }) CENTERED

	//--- Apaga as tabelas temporárias ---//
	AGRDELETRB( cAliasTOT,    cTrabTOT ) 

fim do comentário **/

Return ( lRetorno )


/** {Protheus.doc} A261BLoadTot()
Carrega dados da tabela temporária de negócios pendentes.

@param: 	Nil
@author: 	Bruna Rocio
@since: 	28/10/14
@Uso: 		SIGAAGR - Originação de Grãos
*/

/**
Static Function A261BLoadTot()

Local aAreaAtu	:= GetArea()
Local cAliasCab	:= GetNextAlias()
Local aContrato   := {}
Local cFiltro    := ""

//--- Apaga conteúdo anterior da tabela temporária TOT ---//
A261BZapTRB( cAliasTOT )

If !Empty(pcCodEnt)  
	cFiltro += " AND NKG_CODENT = pcCodEnt " 
Endif

If !Empty(pcLojEnt)	
	cFiltro += " AND NKG_LOJENT = pcLojEnt "
Endif	
	
cFiltro += " AND NKG_STATUS = '1' "
cFiltro += " AND NKG_TIPRET = '0' "
cFiltro := "%" + cFiltro + "%" 

//--- Query para trazer os totais ---//
BeginSql Alias cAliasCab

	SELECT ' ' as OK
	      ,NKG_FILIAL 
	      ,NKG_STATUS 
	      ,NKG_CODCTR
	      ,NKG_CODDES
	      ,NKG_CODPRO
	      ,SUM(NKG_VALSER) as NKG_VALSER
	      ,SUM(NKG_QTDRET) as NKG_QTDRET	      
	      ,SUM(NKG_QTDAJU) as NKG_QTDAJU
	      ,SUM(NKG_VLTARC) as NKG_VLTARC
	      ,SUM(NKG_QTRETC) as NKG_QTRETC
	  FROM %Table:NKG% NKG
	 WHERE NKG.%notDel%
	   AND NKG_FILIAL = %xFilial:NKG%
	   %cFiltro% 
	GROUP BY NKG_FILIAL 
	      ,NKG_CODCTR
	      ,NKG_CODDES  
	      ,NKG_STATUS	 
	      ,NKG_CODPRO 	      
EndSQL

DbselectArea( cAliasCab )
DbGoTop()
While ( cAliasCab )->( !Eof() )

	aContrato :=  GetContrato( ( cAliasCab )->NKG_CODCTR )

	RecLock( cAliasTOT, .T. )
		( cAliasTOT )->OK 	   := ( cAliasCab )->OK
		( cAliasTOT )->T_FILIAL := ( cAliasCab )->NKG_FILIAL
		( cAliasTOT )->T_CODCTR 	:= ( cAliasCab )->NKG_CODCTR
		( cAliasTOT )->T_DESCTR 	:= aContrato[1]
		( cAliasTOT )->T_DESPRO :=  aContrato[2]
		( cAliasTOT )->T_CODDES 	:= ( cAliasCab )->NKG_CODDES
		( cAliasTOT )->T_DESDES 	:= POSICIONE('NJT',1,XFILIAL('NJT')+( cAliasCab )->NKG_CODDES,'NJT_DESCRI')
		( cAliasTOT )->T_VALSER 	:= ( cAliasCab )->NKG_VALSER
		( cAliasTOT )->T_QTDRET 	:= ( cAliasCab )->NKG_QTDRET	
		( cAliasTOT )->T_QTDAJU := 	( cAliasCab )->NKG_QTDAJU
		( cAliasTOT )->T_VLTARC := 	( cAliasCab )->NKG_VLTARC
		( cAliasTOT )->T_QTRETC := 	( cAliasCab )->NKG_QTRETC
	( cAliasTOT )->( MsUnLock() )

	( cAliasCab )->( DbSkip() )
EndDo
( cAliasCab )->( DbCloseArea() )

If Type("oBrwTot") <> "U"
	oBrwTot:Refresh(.T.)
EndIf

RestArea( aAreaAtu )
Return 

/** {Protheus.doc} GetContrato
Busca descrição do contrato
@param: 	Contrato
@return:	Safra
@author: 	Bruna
@since: 	19/12/2014
@Uso: 		OG - Originação de Grãos
*/
/**
Static Function GetContrato( pcContrato )

	Local aRetorno := { , }
	
	dbSelectArea('NJR')
	dbSetOrder(1)
	If( dbSeek( xFilial('NJR') + pcContrato ) )
		
		aRetorno[1] := NJR->NJR_DESCRI
		aRetorno[2] := Posicione('SB1',1,xFilial('SB1')+NJR->NJR_CODPRO,'B1_DESC') 
	Endif

Return ( aRetorno )
**/
/** {Protheus.doc} OGA261BCLK()
Marca/Desmarca registro

@param: 	
@author: 	Bruna Fagundes Rocio
@since: 	01/12/14
@Uso: 		SIGAAGR - Originação de Grãos
*/
/**
Static Function OGA261BCLK( pcAliasTRB, pOBrw  )
	
	If !(pcAliasTRB)->( Eof() )		
		RecLock(pcAliasTRB, .F.)
		(pcAliasTRB)->OK := IIf((pcAliasTRB)->OK=cMarca,' ',cMarca)
		MsUnlock(pcAliasTRB)
	EndIf
				
	pOBrw:Refresh()			
Return
**/
/** {Protheus.doc} OGA261BUNSEL
Função chamada para verificar a existência de registro selecionado 

@param: 	Nil
@author: 	Bruna Rocio
@since: 	01/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
/**
Function OGA261BUNSEL( pcAliasTRB )
	
	dbSelectArea(pcAliasTRB)
	(pcAliasTRB)->( dbGoTop() )
	While !(pcAliasTRB)->( Eof() )
				
		RecLock(pcAliasTRB,.f.)
		(pcAliasTRB)->OK := ' '
		msUnLock(pcAliasTRB)		
		(pcAliasTRB)->( dbSkip() )
	EndDo
Return 
**/
/** {Protheus.doc} OGA261BTSEL
Função chamada para verificar a existência de registro selecionado 

@param: 	Nil
@author: 	Bruna Rocio
@since: 	01/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
/**
Function OGA261BTSEL( pcAliasTRB )
	
	dbSelectArea(pcAliasTRB)
	(pcAliasTRB)->( dbGoTop() )
	While !(pcAliasTRB)->( Eof() )
			
		RecLock(pcAliasTRB,.f.)
		(pcAliasTRB)->OK := cMarca
		msUnLock(pcAliasTRB)
								
		(pcAliasTRB)->( dbSkip() )
	EndDo
Return 
**/
/** {Protheus.doc} OGA261BCHK
Função para marcar/desmarcar todos

@param: 	Nil
@author: 	Bruna Rocio
@since: 	01/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
/**
Function OGA261BCHK( pcAliasTRB, pOBrw )
	
	If lSelAll
		OGA261BTSEL( pcAliasTRB )
	Else
		OGA261BUNSEL( pcAliasTRB )		
	Endif
	
	DbSelectArea(pcAliasTRB)
	(pcAliasTRB)->( DbGoTop() )

	pOBrw:Refresh()

Return 
**/
/** {Protheus.doc} A261BZapTRB
Apaga todos os dados de uma tabela temporária.

@param: 	Nil
@author: 	Bruna Rocio
@since: 	Bruna Rocio
@Uso: 		SIGAAGR - Originação de Grãos
*/
/**
Static Function A261BZapTRB( pcAliasTRB )
	Local aAreaAtu	 	:= GetArea()
	
	DbSelectArea( pcAliasTRB )
	DbGoTop()
	While !Eof()
		RecLock( pcAliasTRB, .F. )
			DbDelete()
		( pcAliasTRB )->( MsUnLock() )
		( pcAliasTRB )->( DbSkip() )
	EndDo
	
	RestArea( aAreaAtu )
Return
**/
/** {Protheus.doc} GeraRomRet
//"Gerando romaneio de retorno simbólico (Saída)

@param: 	Nil
@return:	Nil
@author: 	Bruna
@since: 	16/12/2014
@Uso: 		OG - Originação de Grãos
*/
/**
Static Function GeraRomRet(nQtdRom, cMsgRom, cNFSerieRom, cTesRom, cLocalD )
	Local aAreaAtu 	:= GetArea()
	Local lRetorno	:= .t.
	Local cNewNJJ    	:= ""
	Local cItem		:= ""
	Local cFecSer     := ""
		
	//Contrato
	dbSelectArea("NJR")
	NJR->( dbSetOrder( 1 ) )
	NJR->( dbSeek( xFilial( "NJR" ) + cContrato ) )

	dbSelectArea( "NJ0" )
	dbSetOrder( 1 )
	If .Not. dbSeek( xFilial( "NJ0" ) + NJR->( NJR_CODENT + NJR_LOJENT) )
		Help( ,, STR0033 ,, STR0099, 1, 0) //'HELP'###"Nota Fiscal não encontrada"
		Return( .f. )
	EndIf
	//Alimenta os campos - do Romaneio
	
	BEGIN TRANSACTION
		cNewNJJ := GETSXENUM("NJJ",xFilial( "NJJ" ),xFilial( "NJJ" )+x2path("NJJ")); ConfirmSX8()
									 
		dbSelectArea( "NJJ" )
		If RecLock( "NJJ", .t. )
			NJJ->NJJ_FILIAL 	:= xFilial( "NJJ" )
			NJJ->NJJ_CODROM 	:= cNewNJJ
			NJJ->NJJ_TIPO 	:= "6"
			NJJ->NJJ_TIPENT   := "3" //Retenção
			NJJ->NJJ_CODENT 	:= NJ0->NJ0_CODENT
			NJJ->NJJ_LOJENT 	:= NJ0->NJ0_LOJENT			
			NJJ->NJJ_ENTENT 	:= NJ0->NJ0_CODENT
			NJJ->NJJ_ENTLOJ 	:= NJ0->NJ0_LOJENT				
			NJJ->NJJ_STATUS	:= "1"
			NJJ->NJJ_STSPES   := "1"
			NJJ->NJJ_STSCLA   := "1"
			NJJ->NJJ_STAFIS 	 := "1"
			NJJ->NJJ_PLACA 	 := ""
			NJJ->NJJ_CODTRA   := ""
			NJJ->NJJ_CODSAF 	:= NJR->NJR_CODSAF
			NJJ->NJJ_CODPRO	:= NJR->NJR_CODPRO
			NJJ->NJJ_UM1PRO	:= NJR->NJR_UM1PRO
			NJJ->NJJ_TABELA	:= NJR->NJR_TABELA
			NJJ->NJJ_LOCAL   := cLocalD 
			NJJ->NJJ_TPFORM 	:= "1"
			NJJ->NJJ_NFPSER  := ""
			NJJ->NJJ_NFPNUM  := ""
			NJJ->NJJ_QTDFIS 	:= nQtdRom
			NJJ->NJJ_DATA 	:= dDataBase
			NJJ->NJJ_STACTR 	:= "2"
		 	NJJ->NJJ_TRSERV  := "0"     // não 
			NJJ->NJJ_DOCSER 	:= cNFSerieRom
			msUnLock()
		EndIf
		
		cItem := StrZero( 1, TamSX3( "NJM_ITEROM" )[1] )
		
		dbSelectArea( "NJM" )
		If RecLock( "NJM", .t. )
			NJM->NJM_FILIAL := xFilial( "NJJ" )
			NJM->NJM_CODROM := cNewNJJ
			NJM->NJM_ITEROM := cItem 
			NJM->NJM_TIPO   := "6"
			NJM->NJM_CODCTR := cContrato
			NJM->NJM_CODENT := NJ0->NJ0_CODENT
			NJM->NJM_LOJENT := NJ0->NJ0_LOJENT
			NJM->NJM_NOMENT := NJ0->NJ0_NOME
			NJM->NJM_NLJENT := NJ0->NJ0_NOMLOJ
			NJM->NJM_CODSAF := NJR->NJR_CODSAF
			NJM->NJM_CODPRO := NJR->NJR_CODPRO
			
			NJM->NJM_UM1PRO := NJR->NJR_UM1PRO
			NJM->NJM_PERDIV := 100.00
			NJM->NJM_STAFIS := "1"
			NJM->NJM_TPFORM := "1"
			NJM->NJM_NFPSER := ""
			NJM->NJM_NFPNUM := ""
			NJM->NJM_QTDFIS := nQtdRom
			NJM->NJM_QTDFCO := nQtdRom
			NJM->NJM_TES    := cTesRom
			NJM->NJM_LOCAL  := cLocalD 
		 	NJM->NJM_TRSERV := "0"     // não 
			NJM->NJM_DOCSER := cNFSerieRom
				
			msUnLock()
		EndIf
		
		dbSelectArea('NJJ')	
		lRetorno := OGA250ATUC( Alias(), Recno(), 4, .t. )
		
		If lRetorno
		
			aEntidade := getCliente( NJM->NJM_CODENT , NJM->NJM_LOJENT )
																	    
		    cFecSer := GetSXENum("NKS","NKS_FECSER")
		    ConfirmSX8()
		    
		    dbSelectArea('NKS')
		    If RecLock('NKS', .t.)
			    NKS->NKS_FILIAL  := xFilial('NKS')
			    NKS->NKS_FECSER  := cFecSer
			    NKS->NKS_CODDEV  := NJM->NJM_CODENT
			    NKS->NKS_LOJDEV  := NJM->NJM_LOJENT
			    NKS->NKS_CODROM  := NJM->NJM_CODROM
			    NKS->NKS_ITEROM  := NJM->NJM_ITEROM
			    NKS->NKS_DOCSER  := NJM->NJM_DOCSER
			    NKS->NKS_DOCNUM  := NJM->NJM_DOCNUM
			    NKS->NKS_CLIENT  := aEntidade[1]
			    NKS->NKS_LOJA    := aEntidade[2]
			    NKS->NKS_DOCEMI  := dDatabase
			    NKS->NKS_TPFORM  := NJM->NJM_TPFORM
			    NKS->NKS_TES     := NJM->NJM_TES
			    NKS->NKS_STATUS  := '1' //Gerado
			    NKS->NKS_OBSNF   := cMsgRom
			    NKS->NKS_PEDIDO  := NJM->NJM_PEDIDO
			    NKS->NKS_QTDRET  := nQtdRom
					    
				MsUnlock()
			Endif	
				
			//Posiciona no inicio do arquivo temporário
			ARGSETIFARQUI(cAliasTot)
			
			While !Eof() 
				If (cAliasTot)->OK = cMarca .And. (cAliasTot)->T_QTDRET > 0
																				
					//Posiciona no inicio do arquivo temporario
					ARGSETIFARQUI(cAliasQry)		
					
					While !Eof()
					
						If  ( cAliasQry )->NKG_STATUS = (cAliasTOT)->T_STATUS .And. ;
							( cAliasQry )->NKG_CODCTR = (cAliasTOT)->T_CODCTR .And. ;
							( cAliasQry )->NKG_CODDES = (cAliasTOT)->T_CODDES 
					
							//Busca o registro com a chave primária
							If AGRIFDBSEEK('NKG',(cAliasQry)->NKG_CODCTR+(cAliasQry)->NKG_ITEMOV,1,.f.)
							
								RecLock('NKG', .f.)
								NKG->NKG_FECSER := cFecSer
								NKG->NKG_STATUS := '2' //Confirmado
								MsUnlock()
								//Retoma a área e vai para o próximo registro
								AGRDBSELSKIP('NKG')
							Endif
						EndIf	
							
						//Retoma a área e vai para o próximo registro
						AGRDBSELSKIP(cAliasQry)	
					EndDo
				Endif	
				
				//Retoma a área e vai para o próximo registro
				AGRDBSELSKIP(cAliasTot)	
			EndDo
		Else
			DisarmTransaction()		
		EndIf
	END TRANSACTION		
	RestArea( aAreaAtu )
	
Return( lRetorno )
**/
/** {Protheus.doc} GetSafra
Busca safra do contrato
@param: 	Contrato
@return:	Safra
@author: 	Bruna
@since: 	11/12/2014
@Uso: 		OG - Originação de Grãos
*/
/**
Static Function GetSafra( pcContrato )

	Local cSafra := ""
	
	dbSelectArea('NJR')
	dbSetOrder(1)
	If( dbSeek( xFilial('NJR') + pcContrato ) )
		
		cSafra := NJR->NJR_CODSAF
	Endif

Return ( cSafra )
**/
/** {Protheus.doc} GetContrato
Busca descrição do contrato
@param: 	Contrato
@return:	Safra
@author: 	Bruna
@since: 	19/12/2014
@Uso: 		OG - Originação de Grãos
*/
/**
Static Function GetContrato( pcContrato )

	Local aRetorno := { , }
	
	dbSelectArea('NJR')
	dbSetOrder(1)
	If( dbSeek( xFilial('NJR') + pcContrato ) )
		
		aRetorno[1] := NJR->NJR_DESCRI
		aRetorno[2] := Posicione('SB1',1,xFilial('SB1')+NJR->NJR_CODPRO,'B1_DESC') 
	Endif

Return ( aRetorno )
**/
/** {Protheus.doc} A261AZapTRB
Apaga todos os dados de uma tabela temporária.

@param: 	Nil
@author: 	Bruna Rocio
@since: 	Bruna Rocio
@Uso: 		SIGAAGR - Originação de Grãos
*/
/**
Static Function getCliente( pcEntidade, pcLoja )
	
	Local aRet := { , }
	
	dbSelectArea('NJ0')
	dbSetOrder(1)
	If (dbSeek( xFilial('NJ0') + pcEntidade + pcLoja ))
	
		aRet[1] := NJ0->NJ0_CODCLI
		aRet[2] := NJ0->NJ0_LOJCLI
				
	EndIf
	
Return ( aRet )
**/
