#INCLUDE "AGRXFUN1.CH"
#include "protheus.ch"
#include "fwmvcdef.ch"

Static __lnewNeg	:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utiliza??o do novo modelo de negocio

//----------------------------------------------------------------------
/** {Protheus.doc} AgrGeraNFS
Desbloqueia Pedido de Venda e gera NF de Saída.

@param.: 	<pcNumPed>		Número do Pedido de Vendas (C5_NUM).
			[pcSerie]		Serie da Nota a ser gerada (caso informado, não abre a tela para selecionar a série).
@return:	Array { cNumNFS, cSerie }	Retorna um array contendo o número e a série da NF de saída gerada.
@author: 	Marlon Richard Trettin
@since.: 	21/10/2014
@Uso...:	SIGAAGR
@type function
*/
//----------------------------------------------------------------------
Function AgrGeraNFS( pcNumPed, pcSerie )
	Local aSaveArea 		:= GetArea()
// -- Retorno da Ma410LBNFS --
	Local aPvlNfs   		:= {}
	Local aBloqueio 		:= {{"","","","","","","",""}}

	Local cSerie			:= iIf( Empty(pcSerie), Space( TamSX3( "F2_SERIE" )[1] ), pcSerie )
	Local cNumNFS			:= Space( TamSX3( "F2_DOC" )[1] )
	Local cTpNrNfs  		:= SuperGetMV("MV_TPNRNFS")

	Local cModAtu        	:= cModulo
	Local nModAtu        	:= nModulo
	Local bAtupvl           := {|| .T.}

	Local cEOL	    		:= Chr(13)+Chr(10)
	
	Local lOkFaturar        := .F.
	
// Vars, para Gerar nf, utilizadas na MaPvlNfs
	Local 	dDataMoe  		:= dDataBase
	Private lmudouNum		:= .f.
	Private cNumero			:= Criavar('F2_DOC',.F.)

	Private cOGUBS_NF		:= fAgrtpnf(Nil)			/*Chamado TSJVFB*/

	Private aAgrItFat       := {}

	cModulo   := 'FAT'
	nModulo   := 5

//-- Como nao sei o pq usavam SubStr(pcNumPed,1,6), Vou melhorar para considerar o tamanho do pv no ERP
//pcNumPed 	:= strzero( Val(pcNumPed),TamSx3('C5_NUM' )[1] )   Retirado pois client possui letras para identificar o nr. ai dá erro

	// -- Verificando se o PV encontra-se Liberado e Abastecendo os Arrays [ APVLNFS e Abloqueio ] -- //
	DBSelectArea("SC5")
	SC5->( dbSetOrder(1) )
	IF SC5->( dbSeek(xFilial("SC5")+ pcNumPed ) )
   			// Chama Rotina para Liberacao de pedido
		Ma410LbNfs( 2, @aPvlNfs, @aBloqueio )
			
   			// Checa itens liberados
		aPvlNfs 	:= {}
		aBloqueio	:= {}
		Ma410LbNfs( 1, @aPvlNfs, @aBloqueio )
		IF  ! Empty( aBloqueio )  	//ERP, bloqueou o PV
			lOkFaturar := AgrLibPv( pcNumPed ) 	// Faz tratamento de Liberação cfe Parametro do OG
				
				// Checa SE TEM itens liberados e abastece o APVLNFS
			aPvlNfs 	:= {}
			aBloqueio	:= {}
			Ma410LbNfs( 1, @aPvlNfs, @aBloqueio )
				
		Else
			lOkFaturar := .t.
		ENDIF
	EndIF

	IF ! lOkFaturar	// Indica que o PV Stá Bloqueado mesmo apos aplicar as Regras especificas do Originação
		cMsg := STR0017 + cEOL						//'O Ped. Vendas ref. ao romaneio encontra-se bloqueado. Favor verificar'
		cMsg += " " + cEOL
		cMsg += STR0018 + pcNumPed					//"Pedido de Vendas : "
		Aviso(STR0019,cMsg,{'OK'},3) //#Aviso#"Emissão docto. Fiscal Romaneio"
		Return({})//A função que chamou espera um Array, com serie, e número da NF
	EndIF

//--Ajusta tamanho do cSerie de Acordo com o Dicionario, pois parametro PcSerie Stava vindo com Tamanho 1
	If ! Len(cSerie) = TamSx3('F2_SERIE')[1]
		cSerie := PadR(Alltrim(cSerie),TamSx3('F1_SERIE')[1] )
	EndIf

// Verifica se abre ou não a tela para selecionar a Série e Número da NF
	If empty(cSerie)
	// Abre a tela para selecionar a Série e Número da NF
		if ! Sx5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1"))
			MsgAlert( STR0004 + pcNumPed +Chr(13) + STR0005 ) //"NF de Saída não foi gerada para o Pedido de Vendas "######//"Operação abortada!"
			RestArea( aSaveArea )
			Return( {} )
		EndIf	
	Else
		If cTpNrNfs == "3"	.and. !SuperGetMV("MV_MUDANUM",.F.,.F.)	//Controle pela SD9 e MV_MUDANUM = .F.
			cNumero :=  CriaVar("F2_DOC", .f.)    //envia vazio para rotina faturamento definir numero.
		EndIF
	EndIF
	
	Pergunte("MT460A",.F.)
	
	if __lNewNeg
		bAtupvl	:= {|| AgrxFat( SC9->C9_PEDIDO, SC9->C9_ITEM, SC9->C9_SEQUEN, SC9->C9_PRCVEN, nItem )}
		
		//	cNumNFS := MaPvlNfs( aPvlNfs, cSerie , .F.     , .F.     , .F.      , .F.     , .F.    , 0      , 0          , .T.   , .F., ""    ,       )
		cNumNFS := MaPvlNfs(aPvlNfs, cSerie ,MV_PAR01==1,MV_PAR02==1,MV_PAR03==1,MV_PAR04==1,MV_PAR05==1,MV_PAR07,MV_PAR08,MV_PAR15==1,MV_PAR16==2,,,,bAtupvl,,dDataMoe)
	else
		cNumNFS := MaPvlNfs(aPvlNfs, cSerie ,MV_PAR01==1,MV_PAR02==1,MV_PAR03==1,MV_PAR04==1,MV_PAR05==1,MV_PAR07,MV_PAR08,MV_PAR15==1,MV_PAR16==2,,,,,,dDataMoe)
	endIf


 //-- Retornando o modulo --//
	cModulo    := cModAtu
	nModulo    := nModAtu

	DbSelectArea("SC5")
	DbSetOrder(01) //C5_FILIAL+C5_NUM
	If DbSeek(xFilial("SC5")+pcNumPed)
	
		DbSelectArea("SF2")
		DbSetOrder(01) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		If DbSeek(xFilial("SF2") + SC5->C5_NOTA + SC5->C5_SERIE + SC5->C5_CLIENTE + SC5->C5_LOJACLI )
		
			cNumNFS	:= SC5->C5_NOTA
			cSerie		:= SC5->C5_SERIE
		
		Else
		
			MsgAlert( STR0003 + cNumNFS+"/"+cSerie + Chr(13) + Chr(10) + STR0014 + pcNumPed ) //"Não foi possível gerar a NF de Saída "###"Na tela de Pedido de Vendas, verifique o que aconteceu com o pedido de vendas "
			RestArea( aSaveArea )
			Return( {} )
		
		Endif
	
	Else
	
		MsgAlert( STR0015 + xFilial("SC5") + pcNumPed ) //"Não foi possível localizar o pedido de vendas na tabela de pedidos (SC5): "
		RestArea( aSaveArea )
		Return( {} )
	
	EndIf

	RestArea( aSaveArea )
Return( { cNumNFS, cSerie } )

/** {Protheus.doc} AgrUmPrc

@param: 	[Produto] Codigo do Produto ()
@return:	Unidade de medida de Preço
@author: 	Emerson Coelho
@since: 	24/10/2014
@Uso: 		SIGAAGR
*/
Function AgrUmPrc ( cProduto )
	Local aSaveArea 	:= GetArea()
	Local aAreaSB5 	:= SB5->(GetArea())
	Local cUmPrc		:= ""
	Local cAliasB5UM  := "SB5"
	
	dbSelectArea(cAliasB5UM)
	(cAliasB5UM)->( dbSetOrder(1) )
	If (cAliasB5UM)->(DbSeek(xFilial(cAliasB5UM) + cProduto))
		If FieldPos('B5_UMPRC') > 0
			cUmPrc :=	SB5->B5_UMPRC
		EndIF
	EndIF

	RestArea(aAreaSB5)
	RestArea( aSaveArea )

Return( cUmPrc )
****************

/** {Protheus.doc} AGRTPALGOD

@param: 	[Produto] Codigo do Produto ()
@return:	.t. para verdadeiro .f. para falso
@author: 	Ana Laura Olegini
@since: 	30/03/2017
@Uso: 		SIGAAGR
*/
Function AGRTPALGOD(cProduto)
	Local lContinua := .F.
	Local cTipoAlgo := ''
	
	//*Funcao AGRColPos no fonte AGRUTIL01 
	If AGRColPos('B5_TPCOMMO')
		cTipoAlgo := Posicione("SB5",1,xFilial("SB5")+cProduto,"B5_TPCOMMO")
	EndIf
	
	//*Se não for vazio
	If .NOT. Empty(cTipoAlgo)
		//*se for algodão
		If cTipoAlgo == '2' 	//algodão
			lContinua := .T.	//habilita campos
		Else
			lContinua := .F.	//desabilita campos	
		EndIf
	Else
		lContinua := .F.		//desabilita campos
	EndIf 
Return(lContinua)


/** {Protheus.doc} AgrGetInd

@param: 	[Indice] Indice ( NK0_INDICE )
			[TpCota] Tipo de Cotacao ( NK0_TPCOTA )
			[DATA  ] Data do Indice a Retornar
			[aTabela] Dados do campo de tabela
			[cCampo] Campo Retornado 
@return:	Indice Correspondente ao Tipo de Cotação
@author: 	Emerson Coelho
@since: 	24/10/2014
@Uso: 		SIGAAGR
*/
Function AgrGetInd (cIndice , cTpCota , dData, cCodPro, cTipo, cSafra, cUfOrig, cUfDest, cCampo, cRegiao, cUnDes )
	Local aSaveArea    := GetArea()
	Local aAreaNK1 	   := NK1->(GetArea())
	Local xVr 		   := CriaVar("NK1_VALOR")
	Local cAliasNK1	   := ""
	Local cQuery       := ""
	Local cFiltro      := ""
	Local cAliasN9H    := ""
	Local cUnOri       := ""
	
	Default cCodPro    := ""
	Default cTipo      := ""
	Default cSafra     := ""
	Default cUfOrig    := ""
	Default cUfDest    := "" 
	Default cCampo     := ""
	Default cRegiao    := ""

	If cTpCota <> 'T' .And. cCampo == 'O' //Retorna Observação
        Return( '' )
    EndIf

	DO Case
	Case cTpCota == 'D'  	//--<< Diario >>--
		DBSelectArea("NK1")
		NK1->(DBSetOrder(1)) 	//--<< NK1_FILIAL+DTOS(NK1_DATA)+NK1_INDICE >>--
		IF NK1->(DBSeek(xFilial("NK1")+DTOS(dData)+cIndice))
			xVr := NK1->NK1_VALOR
		Else
			xVr := 0
		ENDif
	Case cTpCota == 'A' 	//--<< +Atual >>--
		cAliasNK1 := GetNextAlias()
  //--<< Retorna a Qtidade Vendia no mes de Referencia >>--
		cQuery += " SELECT NK1A.NK1_VALOR FROM " + RetSqlName("NK1") + " NK1A "
		cQuery += " WHERE NK1A.NK1_DATA IN "
		cQuery += " ( SELECT MAX(NK1B.NK1_DATA) FROM " +  RetSqlName("NK1") + " NK1B "
		cQuery += " WHERE NK1B.NK1_INDICE = NK1A.NK1_INDICE "
		cQuery += "   AND NK1B.NK1_DATA <= '" + DTOS(dData) + "'" 
		cQuery += "   AND NK1B.NK1_FILIAL = '" + xFilial('NK1') + "'"
		cQuery += "   AND NK1B.D_E_L_E_T_ = ' '"
		cQuery += " )"
		cQuery += "  AND NK1A.NK1_INDICE = '" + cIndice + "'"
		cQuery += "  AND NK1A.D_E_L_E_T_ != '*'"
		cQuery += "  AND NK1A.NK1_FILIAL = '" + xFilial('NK1') + "'"
  	
		cQuery:=ChangeQuery(cQuery)
  	
		DbUseArea(.t.,"TOPCONN", TcGenQry(,,cQuery), cAliasNK1,.f.,.T.)

		(cAliasNK1)->(dbGoTop())
		If !(cAliasNK1)->(Eof())
			xVr:=(cAliasNK1)->NK1_VALOR
		EndIf
		(cAliasNK1)->( dbCloseArea() )
	case cTpCota == 'F' //formula
		If NK0->(DbSeek(xFilial("NK0") + cIndice ))
			xVr:= Formula(NK0->NK0_FORMUL)
		endif		
	case cTpCota == 'T' .And. N9H->(ColumnPos("N9H_FILIAL")) > 0 //tabela 	
		if !empty(cCodPro) //tem informação de produto -  somente uso para armazenagem
			cAliasN9H := GetNextAlias() //novo alias para busca de preço de tabela
			
			//monta o filtro
			cFiltro += " AND N9H_FILIAL  = '"+FwXFilial("N9H")+"' "
			cFiltro += " AND N9H_INDICE  = '"+cIndice+"' "
			cFiltro += " AND N9H_PROD    = '"+cCodPro+"' "
			cFiltro += " AND N9H_CODSAF  = '"+cSafra+"' "
			
			if !Empty(cTipo)
			   cFiltro += " AND N9H_TIPO    = '"+cTipo+"' "
			EndIF
					
			cFiltro += " AND (N9H_UFDEST = '"+cUfDest+"' OR N9H_UFDEST = '' )"
			cFiltro += " AND (N9H_UFORIG = '"+cUfOrig+"' OR N9H_UFORIG = '' )"
			cFiltro += " AND (N9H_CODREG =  '"+cRegiao+"' OR N9H_CODREG = '' )"
	        cFiltro += " AND N9H_DTINVG <= '" + DTOS(dData) + "'" 
			cFiltro := "%" + cFiltro + "%" 	
			
			BeginSql Alias cAliasN9H
		
				SELECT N9H.N9H_VLINDT, N9H.N9H_OBSERV, N9H.N9H_CODREG, N9H.N9H_UFORIG, N9H.N9H_DTINVG , N9H.N9H_UNIMED
			  	  FROM %Table:N9H% N9H
			    WHERE N9H.%notDel%
				  %exp:cFiltro%
				ORDER BY  N9H_CODREG DESC , N9H_UFORIG DESC , N9H_UFDEST DESC, N9H_DTINVG DESC 
				 	  
		    EndSQL
		   
		   	DbselectArea( cAliasN9H )
			DbGoTop()
			if ( cAliasN9H )->( !Eof() )
			 	
			 	If cCampo = 'O' //Retorna Observação
			 		xVr := (cAliasN9H )->N9H_OBSERV
			 	ElseIf cCampo = '1' //regiao
			 		xVr := {(cAliasN9H )->N9H_CODREG , (cAliasN9H )->N9H_UFORIG} 
			 	Else  
			 		xVr := (cAliasN9H )->N9H_VLINDT
			 		IF !Empty(cUnDes)
             		    IF !EMPTY((cAliasN9H )->N9H_UNIMED) 
	             		    xVr := OGX700UMVL(xVr, (cAliasN9H )->N9H_UNIMED, cUnDes, cCodPro)	
	             		ELSE
	             		    cUnOri := Posicione("NK0", 1, xFilial("NK0") + cIndice, "NK0_UM1PRO")  
	             		    xVr    := OGX700UMVL(xVr, cUnOri, cUnDes, cCodPro)
	             		ENDIF    
			 		EndIF			 		
			 		
			 	EndIf
			 	( cAliasN9H )->( dbSkip() )
			Endif
			
			( cAliasN9H )->( dbCloseArea() )
	    Endif

	EndCase

	RestArea(aAreaNK1)
	RestArea( aSaveArea )
	
	If cCampo = '1' .and. Empty(xVr)
	   xVr := {' ',' '}
	ElseIf ValType(xVr) <> 'N' .and. cCampo <> '1'
		xVr := 0
	EndIf

Return( xVr )


/** {Protheus.doc} AgrEntidOk
Rotina para verificar dados do cliente e fornecedor associado a entidade informada

@param: 	NIL
@return:	.T. ou .F. 
@author: 	Marlon Richard Trettin
@since: 	07/12/2014
@Uso: 		SIGAAGR
*/
Function AgrEntidOk( cAliasE, cCodEnt, cLojEnt)
	Local aAreaAtu  	:= GetArea()
	
	If cAliasE == "SA2"
		SA2->( dbSetOrder( 1 ) ) // Fornecedores
		If SA2->( dbSeek( xFilial( "SA2" ) + NJ0->( NJ0_CODFOR ) + NJ0->( NJ0_LOJFOR ) ) )
			If SA2->( A2_MSBLQL ) == '1' // 1=Sim (Bloqueado)
				Help( ,, STR0001,, STR0006 + NJ0->( NJ0_CODFOR )+" "+NJ0->( NJ0_LOJFOR ), 1, 0) //'HELP'###"Fornecedor bloqueado para uso pelo sistema. Verifique o cadastro do fornecedor: "
				Return( .F. )
			EndIf
		Else
			Help( ,, STR0001,, STR0007 + NJ0->( NJ0_CODFOR )+" "+NJ0->( NJ0_LOJFOR ), 1, 0) 	//'HELP'###"Fornecedor associado a Entidade não localizado no cadastro de Fornecedor (SA2): "
			Return( .F. )
		EndIf		
	EndIf 
	
	If cAliasE == "SA1"
		SA1->( dbSetORder( 1 ) ) // Clientes
		If SA1->( dbSeek( xFilial( "SA1" ) + NJ0->( NJ0_CODCLI ) + NJ0->( NJ0_LOJCLI ) ) )
			If SA1->( A1_MSBLQL ) == '1' // 1=Sim (Bloqueado)
				Help( ,, STR0001,, STR0008 + NJ0->( NJ0_CODCLI )+" "+NJ0->( NJ0_LOJCLI ), 1, 0) //'HELP'###"Cliente bloqueado para uso pelo sistema. Verifique o cadastro do cliente: "
				Return( .F. )
			EndIf
		Else
			Help( ,, STR0001,, STR0009 + NJ0->( NJ0_CODCLI )+" "+NJ0->( NJ0_LOJCLI ), 1, 0) 	//'HELP'###"Cliente associado a Entidade não localizado no cadastro de Cliente (SA1): "
			Return( .F. )
		EndIf
	EndIf
	
	RestArea( aAreaAtu )
Return( .T. )

/** {Protheus.doc} AgrExcluPV
Rotina para excluir Pedido de Venda

@param: 	pcNumPV - Número do Pedido de Venda a ser excluído
@return:	.T. ou .F. 
@author: 	Marlon Richard Trettin
@since: 	07/12/2014
@Uso: 		SIGAAGR
*/
Function AgrExcluPV( pcNumPV )

	Local 	 lRet		:= .T.
	Local   aCabPV	:= {}
	Local   aItensPV	:= {}
	Private lMSErroAuto := .F.
	Private lMSHelpAuto := .T.

	SC5->( dbSetOrder( 1 ) ) // C5_FILIAL+C5_NUM
	SC6->( dbSetOrder( 1 ) ) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	If SC5->( dbSeek( xFilial( "SC5" ) + pcNumPV ) )
	
		AADD( aCabPV, { "C5_NUM", pcNumPV, Nil } )
	
		If SC6->( dbSeek( xFilial( "SC6" ) + pcNumPV ) )
			While !SC6->( Eof() ) .And. SC6->( C6_FILIAL + C6_NUM ) == xFilial( "SC6" ) + pcNumPV
				AADD( aItensPV, {} )
				AADD( aTail( aItensPV ), { "C6_NUM"	, SC6->C6_NUM	 , Nil } )
				AADD( aTail( aItensPV ), { "C6_ITEM"	, SC6->C6_ITEM , Nil } )
				SC6->( dbSkip() )
			EndDo
		EndIf

		MsAguarde( { || MSExecAuto( {|x,y,z| Mata410( x, y, z) }, aCabPV, aItensPV, 5 ) }, STR0012, STR0013 + " ["+pcNumPV+"]" ) //"AGUARDE"###"Excluindo pedido de venda..."

		If lMSErroAuto
			lRet := .F.
			MostraErro()
		EndIf

	EndIf

Return( lRet )

/*/
{Protheus.doc} AgrLibPV
Função Para Tratar Liberação dos PV
dos romaneios de Saida do Originação
@param: 	cPedido ( Nr. do Pedido a Ser Emitido
@Return:	Tratamento de Lib. de PV cfe. Parametro
.t. Ok Faturar, .f. não ok faturar
@author: E.Coelho
@since: 21/05/2015
@Uso: Originação

Rotina de Liberação de PV, baseado no Link
http://tdn.totvs.com/pages/releaseview.action;jsessionid=F74CC04620C001D921574BDDE73051D0?pageId=6783974
/*/

function AgrLibPV( cPedLib )   // Liberacao de pedido Manual
	//Pega o parametro do Agro que identifica que ação tomar se o ERP, bloquear o PV, de um romaneio de saida.
	Local cOGTpLib	:= SuperGetMV( "MV_OGLIBPV",.F., '2' )   	//Se o parametro n. Existir Ele Considera '2'
	   						// 1=Não toma nenhuma ação usuario deve analisar o pq do bloqueio e se for o caso utilizar a rotina de lib. manual do Faturamento.
							// 2=Força Liberar Credido/ Não Meche em Outros Bloqueios
							// 3=Força Liberar Credido / Chama rotina Lib. Caso ainda Esteja Bloqueado)
	Local cPedido		:= Criavar('C5_NUM',.F.)
	Local aAreaAtu 	:= GetArea()
	Local aAreaSC5 	:= SC5->( GetArea() )
	Local aAreaSC6 	:= SC6->( GetArea() )
	Local aAreaSC9 	:= SC9->( GetArea() )
	
	Local 	 cEOL	    := Chr(13)+Chr(10)
	Local   cMsg		:=''
	Local 	lOkFaturar	:= .f.
	Local 	lRet		:= .f.

// -- Retorno da Ma410LBNFS --
	Local aPvlNfs   := {}
	Local aBloqueio := {{"","","","","","","",""}}

// -- Var Utilizada na A456LibMan() -- // 
	Private bFiltraBrw := {|| Nil}

	cPedido := cPedLib

// -- A MA410LBNFS Requer SC5 Posicionada, Libera o pedido -- //
	DBSelectArea("SC5")
	SC5->( dbSetOrder(1) )
	IF SC5->( dbSeek(xFilial("SC5")+ cPedido ) )
   			// Chama Rotina para Liberacao de pedido
		Ma410LbNfs( 2, @aPvlNfs, @aBloqueio )
			
   			// Checa itens liberados
		aPvlNfs 	:= {}
		aBloqueio	:= {}
		Ma410LbNfs( 1, @aPvlNfs, @aBloqueio )
			
    		// Se tiver algum item do PV. Bloqueado Pelo Erp não mando Faturar
		If ! Empty(aBloqueio)
          		// Pedido bloqueado verifico a Situacao a tomar com relação ao PV.  
          		// Atraves do Parametro MV_OGPVLIB e Seguimos com Ação 
			DO Case
			Case cOgTpLib == '1' // Não Libera
				lOkFaturar := .f.
			Case cOgTpLib == '2' // Força Libear o Credito
						// Força Liberar Credito;
				fLibBlCred( cPedido )
						
						// -- Apos Libear o Credito , Verifica se não Está mais bloqueado -- //
				aPvlNfs 	:= {}
				aBloqueio	:= {}
				Ma410LbNfs( 1, @aPvlNfs, @aBloqueio )
				If ! Empty(aBloqueio)
					lOkFaturar := .f.
				Else
					lOkFaturar := .t.
				EndIF
			Case cOgTpLib == '3'	// Força Liberar Credito e Se Ainda Estiver Bloqueado Abre Tela  de Liberação Manual Para Liberar Credito / Estoque
					//// Força Liberar Credito --//
				fLibBlCred( cPedido )
					
					// Checa itens liberados
				aPvlNfs 	:= {}
				aBloqueio	:= {}
				Ma410LbNfs( 1, @aPvlNfs, @aBloqueio )
					
					// -- Apos Libear o Credito , Verifica se não Está mais bloqueado 				-- //
					// -- Se tiver algum item do PV. Bloqueado Chamo rotina de Liberação Manual 	--//
				If ! Empty(aBloqueio)
					lRet := .f.
					cMsg := STR0020 + cEOL				//"Ped. de Vendas ref. ao romaneio encontra-se bloqueado."
					cMsg +=  ""
					cMsg += STR0021						//"Deseja Libear o Pedido de forma Manual?"
					lRet:= MSGYESNO(cMsg, STR0022 )		//#cmsg #"Romaneio"
						
					IF lRet  // -- Abre tela de Liberação Manual--
						lOkFaturar := fLibCrdEst ( cPedido )
					EndIF
				Else
					lOkFaturar := .t.
				EndIF
			EndCase
		ElseIF Empty( aPvlNfs )
			lOkFaturar := .t.
		EndIF
	EndIF
	
	/*
	IF ! lOkFaturar
		cMsg := 'O Ped. Vendas ref. ao romaneio encontra-se bloqueado. Favor verificar' + cEOL
		cMsg += " " + cEOL
		cMsg += "Pedido de Vendas : " + cPedido 
		Aviso("Emissão docto. Fiscal Romaneio",cMsg,{'OK'},3) //#Aviso
	EndIF
	*/
	

	RestArea(aAreaSC9)
	RestArea(aAreaSC6)
	RestArea(aAreaSC5)
	RestArea(aAreaAtu)

Return ( lOkFaturar )


/*/
{Protheus.doc} fLibBlCred
Função que força liberar o Credito de um PV,
Conceito da Liberação Manual do FATURAMENTEO
Onde libera o PV, mesmo que o ERP o tenha Bloqueado
Por Credito.

@param: 	cPedido ( Nr. do Pedido a Ser Emitido
@Return:	PV. Liberado
@author: E.Coelho
@since: 18/08/2015
@Uso: AgrLibPV

/*/
Static Function flibBlCred ( cPedido )

	Local aAreaAtu 	:= GetArea()
	Local aAreaSC5 	:= SC5->( GetArea() )
	Local aAreaSC6 	:= SC6->( GetArea() )
	Local aAreaSC9 	:= SC9->( GetArea() )

	dbSelectArea("SC9")
	SC9->( dbSetOrder(1) )
	SC9->( dbSeek(FwxFilial('SC9')+ cPedido ) )
	While SC9->( !Eof() ) .And. SC9->( C9_FILIAL + C9_PEDIDO) == FwxFilial("SC9") + cPedido
	//-- Libera de Credito para o item da liberacao do Pedido de Venda ( SC9 )   --             
		a450Grava(1,.T.,.F.)
		SC9->(dbSkip() )
	EndDO
	

	RestArea(aAreaSC9)
	RestArea(aAreaSC6)
	RestArea(aAreaSC5)
	RestArea(aAreaAtu)

Return()

/*/
{Protheus.doc} fLbBlEst
Função que Chama rotina de Liberação Manual de um PV,
Conceito da Liberação Manual do FATURAMENTEO
Onde libera o PV, mesmo que o ERP o tenha Bloqueado
Por Credito.

@param: 	cPedido ( Nr. do Pedido a Ser Emitido
@Return:	PV. Liberado
@author: E.Coelho
@since: 18/08/2015
@Uso: AgrLib

/*/
Static Function fLibCrdEst ( cPedido )

	Local aAreaAtu 	:= GetArea()
	Local aAreaSC5 	:= SC5->( GetArea() )
	Local aAreaSC6 	:= SC6->( GetArea() )
	Local aAreaSC9 	:= SC9->( GetArea() )
	Local lShowTela	:= .t.
	Local nOpca
	Local lLiberar	:= .f.
	Local lRejeitar  	:= .f.
	Local lOkFaturar	:= .f.
	
	// -- Vars. Utilizadas Pelo a450Tela -- //
	Local lcontinua  	:= .t.
	Local dLimLib   := dDataBase
	// ------------------------------------ //
	dbSelectArea("SC9")
	SC9->( dbSetOrder(1) )
	SC9->( dbSeek(FwxFilial('SC9')+ cPedido ) )
	While SC9->( !Eof() ) .And. SC9->( C9_FILIAL + C9_PEDIDO) == FwxFilial("SC9") + cPedido
		IF lShowTela
			nOpcA := a450Tela( @lContinua , .T. , .T., @dLimLib )
			lShowTela := .f.
		EndIF
		Do Case
		Case ( nOpca == 1  .or. nOpca == 4) //Seja OK, Ou Lib todos Sempre iremos Liberar Todos
			lLiberar := .t.
		Case ( nOpca == 3 ) // Rejeita
			lLiberar 	:= .f.
			lRejeitar	:= .t.
		EndCase
		
		SC9->(dbSkip() )
		
	EndDO

   // Atenção, Iremos Ignorar neste momento a dLimLib, e tbem sermpe iremos liberar todos os itens do PV do Romaneio
	
	dbSelectArea("SC9")
	SC9->( dbSetOrder(1) )
	SC9->( dbSeek(FwxFilial('SC9')+ cPedido ) )
	While SC9->( !Eof() ) .And. SC9->( C9_FILIAL + C9_PEDIDO) == FwxFilial("SC9") + cPedido
		IF lLiberar // Libera o Pv
			//-- Libera Estoque  e Credito para o item da liberacao do Pedido de Venda ( SC9 )   --
			a450Grava(1,.t.,.T.)
		
		ElseIF lRejeitar	//Força Avaliar novamente
			//-- Avalia Estoque/Credito novamente   --
			a450Grava(2,.T.,.T.)
		EndIF
		SC9->(dbSkip() )
	
	EndDO
	
	IF lLiberar
		lOkFaturar := .t.
	ElseIF lRejeitar
		lOkFaturar := .f.
	EndIF

	RestArea(aAreaSC9)
	RestArea(aAreaSC6)
	RestArea(aAreaSC5)
	RestArea(aAreaAtu)

Return( lOkFaturar )

/*/
{Protheus.doc} fAgrtpnf
@param.: cTpRom (Tipo do Romaneio)
@Return: cTpNf  (Tipo da NF)
@author: E.Coelho
@since.: 10/12/2015
@Uso...: Originação 
/*/
Function fAgrtpnf(cTpRom)
	Local cTpNf    	:= ''
	Default cTpRom	:= cTpRom
	
	// -- Vrs. Definidos Pela Equipe Inovação Para Vrs. de Variavel   --//
	//    Private a ser declara antes da chamada da Função de emissao --//
	//    de doctos fiscais no ORIGINACAO                             --//      
	//cOGUBS_NF = '01'   == COMPRA E VENDA
	//cOGUBS_NF = '02'   == COMPRA E VENDA complemento de preço;
	//cOGUBS_NF = '03'   == Nf. de Serviço;
	//Esses cpos poderam ser tratados para mudar o tipo de prefixo no financeiro EX:
	//MV_1DUPREF 
	//IIF(!TYPE('cOGUBS_NF') = 'U' .and. OGUBS_NF == '01','OGV',SF2->F2_SERIE)	// o Tit. gerado pela NF de Saida do romaneio de venda terá prefixo OGV, e para entradas do compras o prefixo será a Serie
	//IIF(!TYPE('cOGUBS_NF') = 'U' .and. OGUBS_NF == '03','OGS',SF2->F2_SERIE)  // o Tit. gerado pela NF de Saida de Cobrança de Armazenagem terá prefixo OGS, e para entradas do compras o prefixo será a Serie
	//IIF(!TYPE('cOGUBS_NF') = 'U','ZOG',SF2->F2_SERIE)                         // o Tit. gerado pela NF de Saida do OG/Cob. Armazenagem  , terá o prefixo ZOG
	//MV_2DUPREF 
	//IIF(!TYPE('cOGUBS_NF') = 'U' .and. OGUBS_NF == '01','OGC',SF1->F1_SERIE)  	// o Tit. gerado pela NF de Compra do romaneio de compra ira emitir um tit. com prefixo OGC, e para entradas do compras o //prefixo será a Serie

	If ISINCALLSTACK('OGA250') //Romaneios
		If cTpRom == '4' .OR. cTpRom == '5'    //Compra e Venda
			cTpNf := '01'
		EndIf
	ElseIf ISINCALLSTACK('fNfCplCpra') .OR. ISINCALLSTACK('fNfCplVnda')   //== Compl. Preco Compra, Compl. Preco Venda
		cTpNf := '02'
	ElseIf ISINCALLSTACK('OGA261A') //== Serviços
	    cTpNf := '03'
	EndIf

Return(cTpNF)


// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRUSEUBSA
Verifica que se os módulos UBA e UBS são utilizados
@author: Bruna Fagundes Rocio
@since: 30/03/2016
@Uso: UBA/UBS
/*/
// -------------------------------------------------------------------------------------


Function AGRUSEUBSA( )

	Local lUse := .f.
	
	lUse := Iif (SuperGetMv("MV_AGRUBA",,.F.) .or. SuperGetMv("MV_AGRUBS",,.F.), .T., .F.)

Return lUse


// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRDELNFS
Exclui documento de saída via rotina MATA521
@author: Bruna Fagundes Rocio
@since: 30/03/2016
@Uso: UBA/UBS
/*/
// -------------------------------------------------------------------------------------

Function AGRDELNFS( cAliasSF2 )
	    
    If AGRIFDBSEEK("NPM",(cAliasSF2)->F2_DOC + (cAliasSF2)->F2_SERIE ,4,.F.)

	    oModel := FWLoadModel( "AGRA900" )
	    oModel:SetOperation( MODEL_OPERATION_UPDATE )
	    oModel:Activate()
	
	    AGRA900DNF()
	
	    oModel:DeActivate()
	    	        
    Endif

Return 


/*/{Protheus.doc} AGRVLDTMPR
Validação de TM do tipo PR
@author bruna.rocio
@since 05/05/2016
@version undefined
@param cTM, characters, descricao
@type function
/*/
Function AGRVLDTMPR( cTM )
	Local lRet := .T.
	
	dbSelectArea('SF5')
	dbSetOrder(1)
	If !dbSeek(FwxFilial('SF5')+cTM)
		lRet := .F.
	ElseIf !SF5->F5_TIPO = 'P'	
		lRet := .F.
	Endif
Return lRet


/*/{Protheus.doc} AGRVLDTMRQ
Validação de TM do tipo RQ
@author bruna.rocio
@since 05/05/2016
@version undefined
@param cTM, characters, descricao
@type function
/*/
Function AGRVLDTMRQ( cTM )
	Local lRet := .T.

	dbSelectArea('SF5')
	dbSetOrder(1)
	If !dbSeek(FwxFilial('SF5')+cTM)
		lRet := .F.
	ElseIf !SF5->F5_TIPO = 'R' 	
		lRet := .F.
	Endif

Return lRet

/*/{Protheus.doc} AGRDLPDVEN
//Eliminação do Pedido de Venda
@author bruna.rocio
@since 07/07/2016
@version undefined
@param cNumPed, characters, descricao
@type function
/*/
Function AGRDLPDVEN(cNumPed)
	Local aArea   := GetArea()
	Local aCabORD := {}, aItensORD := {}
	
	Private lMSErroAuto := .F.
	Private lMSHelpAuto := .T.
	
	Aadd(aCabORD,{"C5_NUM",cNumPed,Nil})
	
	dbSelectArea('SC5')
	dbSetOrder(1)
	If dbSeek(xFilial('SC5')+cNumPed)
		
		dbSelectArea('SC6')
		dbSetOrder(1)
		If dbSeek(xFilial('SC6')+cNumPed)
					
			While !Eof() .And. SC6->C6_FILIAL = Xfilial("SC6") .And. SC6->C6_NUM = cNumPed
				Aadd(aItensORD,{})
				Aadd(aTail(aItensORD),{"C6_NUM" ,SC6->C6_NUM	,Nil})
				Aadd(aTail(aItensORD),{"C6_ITEM",SC6->C6_ITEM	,Nil})
				DbSkip()
			EndDo
		EndIf
		
		dbSelectArea('SC5')
		If RecLock('SC5',.f.)
			SC5->C5_LIBEROK := " "
			SC5->(MsUnlock())
		Endif
				
		MsAguarde({||MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabORD,aItensORD,5)},STR0023,STR0024) //"Aguarde..."###"Excluindo Pedido de Vendas..."
		
		If lMSErroAuto
			MostraErro()
		Endif
	EndIf
	
	RestArea(aArea)
Return (!lMSErroAuto)


/*/{Protheus.doc} AGRDLDOCFIS
//Função para eliminação do documento fiscal
@author bruna.rocio
@since 07/07/2016
@version undefined
@param cNF, characters, descricao
@param cSerie, characters, descricao
@type function
/*/
Function AGRDLDOCFIS(cNF, cSerie)
	Local aArea := GetArea()
	Local lRet  := .t.
	Local aRegSD2 := {},aRegSE1 := {},aRegSE2 := {}
			
	If !MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2,'MATA460') // Validação na exclusão da Nota Fiscal
		Alert(STR0021) //#"Não foi possivel excluir o docto. de saida."
		lRet := .f.		
	Else 
		// Estorna o documento de saída e deixa o pedido de vendas em carteira
		dbSelectArea('SF2')
		dbSetOrder(1)
		If dbSeek(xFilial('SF2')+cNF+cSerie)
				
			MsAguarde({||SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,.F.,.F.,.F.,.T.))},STR0023,STR0025) //"Aguarde..."###"Estonarndo o documento de saída..."
			SF2->( MsUnlock() )
		EndIf
	EndIF

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} AGRCRTPED
//Criação do Pedido de Venda
@author bruna.rocio
@since 07/07/2016
@version undefined
@param cNumPed, characters, número do pedido
@param cCTR, characters, contrato
@param cCODCLI, characters, cliente do pedido
@param cLOJCLI, characters, loja do cliente
@param nQtdOP, numeric, quantidade do pedido
@param cCONDPG, characters, condição de pagamento
@param cProd, characters, produto do pedido
@param cLocal, characters, local do produto
@type function
/*/
Function AGRCRTPED(cNumPed, cCTR, cCODCLI, cLOJCLI, nQtdOP, cCONDPG, cProd, cLocal, cUM, cTES, nPVen, cRotina)
	Local aArea   := GetArea()
	Local aPedCab := {}
	Local aPedIte := {}
	Local aItens  := {}
	 
	Local cIteCon := ""
	
	Private lMSErroAuto := .F.
	Private lMSHelpAuto := .T.
	
	cUM	  := IIF(Empty(cUM) ,CriaVar('ADB_UM'	, .F.),cUM)
	cTes	  := IIF(Empty(cTes),CriaVar('ADB_TES'	, .F.),cTes)
		
	aAdd(aPedCab,{'C5_FILIAL' , FwXFilial('SC5') , Nil}) //Numero do Pedido	
	aAdd(aPedCab,{'C5_NUM'    , cNumPed   , Nil}) //Numero do Pedido
	
	If cRotina = "AGRA610"
		aAdd(aPedCab,{'C5_TIPO'   , 'C'       , Nil}) //Complemento
		aAdd(aPedCab,{'C5_TPCOMPL', '2'       , Nil}) //Tipo COmplemento - Quantidade
	Else
		aAdd(aPedCab,{'C5_TIPO'   , 'N'       , Nil}) //Tipo de Pedido	
	Endif
	
	aAdd(aPedCab,{'C5_CLIENTE', cCODCLI   , Nil}) //Codigo do Cliente
	aAdd(aPedCab,{'C5_LOJACLI', cLOJCLI   , Nil}) //Loja do Cliente
	aAdd(aPedCab,{'C5_CLIENT' , cCODCLI   , Nil}) //Codigo do Cliente
	aAdd(aPedCab,{'C5_LOJAENT', cLOJCLI   , Nil}) //Loja do Cliente
	aAdd(aPedCab,{'C5_EMISSAO', ddatabase , Nil}) //Data de Emissao
	aAdd(aPedCab,{'C5_LIBEROK', 'S'       , Nil}) //Liberacao Total
	aAdd(aPedCab,{"C5_CONDPAG", cCONDPG	  , Nil})
				
	If !Empty(cCTR)
						
		dbSelectArea('ADB')
		dbSetOrder(1)
		If dbSeek(xFilial('ADB')+cCTR)
			
			While ADB->(!Eof())                  .And. ;
				ADB->ADB_FILIAL = xFilial('SC6') .And. ;
				ADB->ADB_NUMCTR = cCTR
				
				If (ADB->ADB_CODPRO = cProd)
					cUM   := ADB->ADB_UM
					nPVen := ADB->ADB_PRCVEN
				    cTES  := ADB->ADB_TES
				    cIteCon := ADB->ADB_ITEM
					EXIT
				EndIf
				ADB->( DBSkip() )
			EndDo
		Endif
	Endif
		
	cNumIte := RetAsc( 1, TamSX3('C6_ITEM')[1],.F.)
	
	aAdd(aPedIte,{'C6_ITEM'   , cNumIte    		, Nil})
	aAdd(aPedIte,{'C6_PRODUTO', cProd     		, Nil})
	aAdd(aPedIte,{'C6_UM'     , cUM         	, Nil})
	aAdd(aPedIte,{'C6_LOCAL'  , cLocal    		, Nil})
	aAdd(aPedIte,{'C6_QTDVEN' , nQtdOP      	, Nil})
	aAdd(aPedIte,{'C6_PRCVEN' , nPVen	        , Nil})
	aAdd(aPedIte,{'C6_VALOR'  , Round(nPVen * nQtdOP,2), Nil})
	aAdd(aPedIte,{'C6_TES'    , cTES           , Nil})
	aAdd(aPedIte,{"C6_PRUNIT",	nPVen			,Nil})
	
	If !Empty(cCTR)
		aAdd(aPedIte,{'C6_CONTRAT' , cCTR      	, Nil})
		aAdd(aPedIte,{'C6_ITEMCON' , cIteCon    , Nil})
	Endif
	
	aAdd(aItens, aPedIte)
	
	If ExistBlock('AGRXCTPED')
		aRet := ExecBlock('AGRXCTPED',.F.,.F.,{aPedCab, aItens, cRotina})
		If ValType(aRet) == 'A'
			aPedCab	:= aRet[1] // Cabeçalho da desmontagem de produtos
			aItens  := aRet[2] // Itens da demontagem de produtos
		EndIf
	EndIf
	
	MSExecAuto({|x,y,z|Mata410(x,y,z)}, aPedCab, aItens, 3) //Opção para Inclusão

	If lMsErroAuto
		Mostraerro()				
	EndIf

	If __lSX8
		ConfirmSX8()
	EndIf
	
	RestArea(aArea)
Return !(lMsErroAuto)

/*/{Protheus.doc} AGREMTNF
// Emissão de Nota Fiscal
@author emerson.coelho
@since 21/05/2015
@version undefined
@param cPedido, characters, descricao
@type function
/*/
Function AGREMTNF( cPedido, cRotina )
	Local _nPrcVen,_nRegDAK,nX
	Local lEmitiuNf		:= .f.,lContinua := .t.,lOutraMoed	 := .f.
	Local aAreaAnt		:= GetArea()
	Local aPvlNfs		:= {}
	Local cRot      	:= ProcName()
	Local cModAtu   	:= cModulo
	Local nModAtu   	:= nModulo
	Local dDataMoe		:= dDatabase	
	Local cSerie		:= CriaVar('F2_SERIE', .F.)
	Local cNota 		:= Criavar('F2_DOC',.F.)
	Local cTpNrNfs  	:= SuperGetMV("MV_TPNRNFS")
	
	Private lMudouNum   := .F.
	Private cNumero     := ""
	Store 0 To _nPrcVen,_nRegDAK,nX

	SetFunName("MATA461")

	cModulo	:= 'FAT'
	nModulo := 5

	//--Posiciona no Pedido a Gerar o Doct Fiscal --
	AGRIFDBSEEK("SC5",cPedido,1,.F.)

	// Verifica se o usuario tem premissao para gerar   o ³
	If cPaisLoc <> "BRA" .AND. FieldPos("C5_CATPV") > 0 .AND. !Empty(SC5->C5_CATPV)
		If AliasIndic("AGS") //Tabela que relaciona usuario com os Tipos de Pedidos de vendas que ele tem acesso
			If AGRIFDBSEEK("AGS",__cUserId,1,.F.) //Se não encontrar o usuário na tabela, permite ele alterar o pedido
				If !AGRIFDBSEEK("AGS",__cUserId+ SC5->C5_CATPV,1,.F.) //Verifica se o usuario tem premissao
					MsgStop(STR0026)
					lContinua := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	
	aPvLnfs :={}
	cSerie  := cNota := ''

	IF lContinua
		//Escolhendo a Serie da Nf.
		lContinua := Iif( Sx5NumNota(@cSerie,SuperGetMV("MV_TPNRNFS")), .t., .f.)
		// Verifica se o registro está travado para outra estação,pois, está ocorrendo problema na geração da NFE
		If AGRIFDICIONA("SX6",Xfilial("SX6")+"MV_NUMITEN",1,.f.)
			If !SoftLock("SX6")
				SX6->(MsRUnLock())
			EndIf
		EndIf
	EndIF
	
	IF lContinua
		Pergunte("MT460A",.F.)

		// Preparando p PV para  Gerar a Nf.
		If AGRIFDBSEEK('SC5',cPedido,1,.F.)
			nVrMoedNeg := 0
			cNktTrcNum := ''

			If AGRIFDBSEEK("SC6",cPedido,1,.F.)
				While !Eof() .And. SC6->C6_FILIAL+SC6->C6_NUM = Xfilial("SC6")+cPedido
				

					If AGRIFDBSEEK('SC9',SC5->C5_CLIENTE+SC5->C5_LOJACLI+SC6->C6_NUM+SC6->C6_ITEM,2,.F.)
						// Posiciona na condicao de pagamento
						AGRIFDBSEEK('SE4',SC5->C5_CONDPAG,1,.F.)
						// Posiciona no produto
						AGRIFDBSEEK('SB1',SC6->C6_PRODUTO,1,.F.)
						// Posiciona no saldo em estoque
						AGRIFDBSEEK('SB2',SC6->C6_PRODUTO+SC6->C6_LOCAL,1,.F.)
						// Posiciona no TES
						cTes := SC6->C6_TES
						AGRIFDBSEEK('SF4',cTes,1,.F.)

						// Converte o valor unitario em Reais quando pedido em outra moeda
						_nPrcVen := SC9->C9_PRCVEN
						If (SC5->C5_MOEDA!=1)
							_nPrcVen := xMoeda(_nPrcVen,SC5->C5_MOEDA,1,dDataMoe)
							lOutraMoed := .t.
						EndIf

						// Monta array para gerar a nota fiscal
						Aadd(aPvlNfs,{SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,SC9->C9_QTDLIB,_nPrcVen,	SC9->C9_PRODUTO,;
						.F.,SC9->(RecNo()),SC5->(RecNo()),SC6->(RecNo()),	SE4->(RecNo()),SB1->(RecNo()),SB2->(RecNo()),;
						SF4->(RecNo()),SC6->C6_LOCAL,_nRegDAK,	SC9->C9_QTDLIB2})
					Else
						Aviso(cRot,STR0027+Trim(cPedido)+" "+STR0028,{STR0029})
						lContinua := .F.
					Endif
					SC6->( DBSkip() )
				EndDo
			Else
				Aviso(cRot,STR0027+Trim(cPedido)+" "+STR0028,{STR0029})
				lConTinua := .f.
			EndIf
		Else
			Aviso(cRot,STR0027+" "+STR0030,{STR0029})
			lContinua := .f.
		EndIf

		IF lContinua 	// Tudo ok Para emitir a NF,
			IF lOutraMoed // Pedido é em outra Moeda e não Possui taxa Cadastrada Para a Moeda
				IF !AGRIFDBSEEK("SM2",DtoS(dDataBase),1,.F.) .or.  xMoeda( 1, ADA->ADA_MOEDA, 1, dDataBase, TamSX3("M2_MOEDA2")[2] ) == 0 //Se não encontrou Taxa Cadastrada na Data
					//Atenção a Xmoeda irah encontrar a Taxa mais proxima da mais atual para menos aatul o por isso do Dbseek 
					Aviso(cRot,STR0031+" "+ Trim(cPedido)+" "+STR0032,{STR0009})  //#"Pedido" + #"é um pedido em Outra Moeda. Favor antes de prosseguir Cadastrar a Taxa da Moeda para a data de Hoje." #"&Abandonar"
					lContinua := .f.
				EndIF
			EndIF
		EndIF

		//-- Inicio Emitindo NF --//
		If lContinua
			If !Empty(aPvlNfs)
								
				IF lContinua
					// -- Esse foi um ajuste que fiz na Sem.Goias (Eles usam SD9), pq a conexão deles estava caindo e deixando o parametro bloqueado --
					If cTpNrNfs == "3" .and. !lMudouNum = .t. 		//Controle pela SD9 e o nr. não foi mudado na tela
						lMudouNum 		:= .T.    	// Força a Chamar a funcao Ma461NumNF  e nao chamar a NXTSX5NOTA na função MAPVLNFS, ( Razao stavamos com 
						// DEADLOCK frequente  no mv_numiten. mesmo criando o mv_numiten por filial , na Sem. Goias e 
						// como utilizam a SD9 fizemos essa solução de contorno)
						cNumero	:= CriaVar("F2_DOC", .f.)
					EndIf  

					// Emite Docto Fiscal
					If ExistBlock('AGRXEMTNT')
						aRet := ExecBlock('AGRXEMTNT',.F.,.F.,{aPvlNfs, cSerie, cRotina})
						If ValType(aRet) == 'A'
							aPvlNfs	:= aRet[1] // Cabeçalho da desmontagem de produtos
							cSerie  := aRet[2] // Itens da demontagem de produtos
						EndIf
					EndIf
					
					cNota := ''
					MsAguarde({|| cNota := MaPvlNfs(aPvlNfs	,cSerie,MV_PAR01 = 1,MV_PAR02 = 1,MV_PAR03 = 1,MV_PAR04 = 1,MV_PAR05 = 1,;
					MV_PAR07,MV_PAR08	,MV_PAR15 = 1,MV_PAR16 = 2,,,,,,dDataMoe)},STR0023,STR0033) //"Aguarde..."###"Gerando documento fiscal..."					
				EndIf
				lEmitiuNF := IIF(!Empty(cNota),.t.,.f.)
			EndIf
		EndIf
		SX5->(MsRUnlock())
	EndIF
	SetFunName(cRotina)
	cModulo := cModAtu
	nModulo := nModAtu
	RestArea(aAreaAnt)
Return (lEmitiuNF)


/*/{Protheus.doc} AGRSmartCode
//Gera código único para geração de codigo de barras
@author bruna.rocio
@since 09/02/2017
@version undefined
@param cTabela, characters, descricao
@param cSafra, characters, descricao
@param cCodigo, characters, descricao
@param cTipo, characters, descricao
@param cSufixo, characters, descricao
@type function
/*/
Function AGRSmartCode(cTabela, cSafra, cCodigo, cTipo, cSufixo)
	Local aArea   := GetArea()
	Local cSmartCode 
	
	//Monta o código conforme parametros
	cSmartCode := FwXFilial(cTabela)+"-"+AllTrim(cSafra)+"-"+cCodigo+"-"+cTipo+"-"+cSufixo

	RestArea(aArea)
Return cSmartCode


/*/{Protheus.doc} AGRCodeUni
//Gera código único para geração de código de barras referente DXD
@author marina.muller
@since 18/09/2017
@param cTabela, characters, descricao
@param cSafra, characters, descricao
@param cCodigo, characters, descricao
@param cSufixo, characters, descricao
@type function
/*/
Function AGRCodeUni(cTabela, cSafra, cCodigo, cSufixo)
	Local aArea   := GetArea()
	Local cSmartCode

	//Monta o código conforme parametros
	cSmartCode := FwXFilial(cTabela)+"-"+AllTrim(cSafra)+"-"+cCodigo+"-"+cSufixo

	RestArea(aArea)
Return cSmartCode

/*/{Protheus.doc} AGRCdgFrd
//Responsável por gerar o código único do fardão. (No momento da inclusão de um fardão.)
@author brunosilva
@since 15/03/2018
@version undefined
@param cCodigo, characters, Código do fardão
@param cSafra, characters, Safra 
@param cCodEnt, characters, Entidade 
@param cLojEnt, characters, Loja da entidade
@param cCodFaz, characters, Fazenda
@type function
/*/
Function AGRCdgFrd(cCodigo, cSafra, cCodEnt, cLojEnt, cCodFaz)
	Local aArea   := GetArea()
	Local cSmartCode 

	//Monta o código conforme parametros
	cSmartCode := cCodigo+"-"+cSafra+"-"+cCodEnt+"-"+cLojEnt+"-"+cCodFaz

	RestArea(aArea)
Return cSmartCode


/*/{Protheus.doc} AGRSmartPic
//TODO Descrição auto-gerada.
@author bruna.rocio
@since 15/02/2017
@version undefined

@type function
/*/
Function AGRSmartPic()
	Local cPicture := ""
	Local cTamFil  := TamSX3('DXJ_FILIAL')[1]
	Local cTamSaf  := TamSX3('DXJ_SAFRA')[1]
	Local cTamMal  := TamSX3('DXJ_CODIGO')[1]
	
	cTamFil := STRTRAN(cTamFil, ' ', '!')
	cTamSaf := STRTRAN(cTamSaf, ' ', '!')
	cTamMal := STRTRAN(cTamMal, ' ', '!')
	
	cPicture := "@R " + cTamFil + "-" + cTamSaf + "-" + cTamMal  + "-" + "!-!!"

Return cPicture

/** {Protheus.doc} fAgrVncPV
Função que vincula PV. de movimento do OG as tabelas de vinculo de PV
@param:   	Cabeçalho do PV, Item do PV, opc ( 3=Incluir, 5=Excluir)
Retorno:  	.t. ou .f. 
@author: 	Equipe Agro
@since: 	08/01/2018
@Uso: 		SIGAAGR - Originação de Grãos
*/
function fAgrVncPV(aCab, Aitens, nOpc)
	Local cTabCab 	:= 'N8H'
	Local cTabItens	:= 'N8I'
	Local aItemAtual:= {}	
	Local nI		:= 0
	Local nII		:= 0	
	Local cChavCab	:= ''
	Local cChavItens:= ''
	Local lTudoOK	:= .t.
	
	DbselectArea( cTabCab )
	(cTabCab)->( dbSetOrder( 1 ) ) // _Filial + _NUMPV

	// monstando a Chave do Cab do PV
	nPosCpo:= ASCAN(aCab, {|aCab| aCab[1] ==  'N8H_NUMPV' })

	cChavCab := FWxFILIAL(cTabCab) + aCab[nPosCpo,2]  // Formando a Chave

	IF nOpc == 3

		IF .NOT. ( cTabCab )->(DbSeek( cChavCab))   

			IF RecLock(cTabCab, .T. )    	//Gravando PV de Vendas
				For nI := 1 to Len(aCab) sTep 1 
					//&("N8H->"+aCab[Ni,1])	:= aCab[nI,2]
					&(cTabCab + "->"+aCab[Ni,1])	:= aCab[nI,2]
				Next nI
				( cTabCab )->(msUnLock())
			Else
				lTudoOK := .f.
			EndIF
			IF lTudoOK 
				//Acrescentando o Item na Chave do PV para formar a chave dos itens 
				//cChavCab += " + " 		
				For nI := 1 to Len(aItens) sTep 1
					// Montando a Chave da tab. de itens do PV
					aItemAtual := aClone( aItens[ nI ] )
					nPosCpo:= ASCAN(aItemAtual, {|aItemAtual| aItemAtual[1] ==  'N8I_ITEMPV' })
					cChavItens := cChavCab + aItemAtual[nPosCpo,2]

					DbselectArea( cTabItens )
					(cTabItens)->( dbSetOrder( 1 ) ) // _Filial + _NUMPV + _ITENSPV
					IF .NOT. (cTabItens)->(DbSeek( cChavItens))
						RecLock(cTabItens, .T. )
						(cTabItens)->N8I_NUMPV := ( cTabCab )->N8H_NUMPV
						For nII:= 1 to Len(aItemAtual) sTep 1 
							&( cTabItens + "->"+aItemAtual[nII,1])	:= aItemAtual[nII,2]
						Next nII
						(cTabItens)->( msUnLock() )
					Else  // Ja tem um item com o numero gravado
						lTudoOK := .f.
						Exit
					EndIF 
				Next nI
			EndIF
		Else
			lTudoOK	 := .f.	
		EndIF
	ElseIF nopc == 5  // Excluir
	
		IF  ( cTabCab )->(DbSeek( cChavCab))
			IF RecLock(cTabCab, .f. )    	//Excluindo Cab PV
				( cTabCab )->(DbDelete())
				( cTabCab )->(msUnLock())
			Else
				lTudoOK := .f.
			EndIF

			IF lTudoOk
				DbselectArea( cTabItens )
				(cTabItens)->( dbSetOrder( 1 ) ) 	// _Filial + _NUMPV + _ITENSPV
				( cTabItens )->(DbSeek( cChavCab))	//Posicionando no 1o. item do pedido de vendas
				While ( cTabItens )->(!Eof()) .AND. N8I->(N8I_FILIAL + N8I_NUMPV ) == cChavCab
					IF RecLock(cTabItens, .f. )    	//Gravando PV de Vendas
						( cTabItens )->(DbDelete() )
						( cTabItens )->(msUnLock() )
					Else
						lTudoOK := .f.
						Exit
					EndIF
					(cTabItens)->( DbSkip() )
				EndDo
			EndIF
		EndIF
	EndIF	

Return ( lTudoOk )

/** {Protheus.doc} fAgrVncNFS
Função que vincula  movimento que geram Nf. de saida do OG 
as tabelas de vinculo SF2/Sd2
@param:   	Cabeçalho da NF, Itens da NF, opc ( 3=Incluir, 5=Excluir)
Retorno:  	.t. ou .f. 
@author: 	Equipe Agro
@since: 	08/01/2018
@Uso: 		SIGAAGR - Originação de Grãos
*/
function fAgrVncNFS(aCab, Aitens, nOpc)
	Local cTabCab 	:= 'N8J'
	Local cTabItens	:= 'N8K'
	Local aItemAtual:= {}	
	Local nI		:= 0
	Local nII		:= 0	
	Local cChavCab	:= ''
	Local cChavItens:= ''
	Local lTudoOK	:= .t.
	
	DbselectArea( cTabCab )
	(cTabCab)->( dbSetOrder( 1 ) ) //_FILIAL+_DOC+_SERIE+_CLIFOR+_LOJA                                                                                                                                                                                                              
	// Montando a Chave da NF
	
	cChavCab := FWxFILIAL(cTabCab)
	
	nPosCpo:= ASCAN(aCab, {|aCab| aCab[1] ==  'N8J_DOC' })
	cChavCab +=  aCab[nPosCpo,2]
	
	nPosCpo:= ASCAN(aCab, {|aCab| aCab[1] ==  'N8J_SERIE' })
	cChavCab +=  aCab[nPosCpo,2]
	
	nPosCpo:= ASCAN(aCab, {|aCab| aCab[1] ==  'N8J_CLIFOR' })
	cChavCab +=  aCab[nPosCpo,2]
	
	nPosCpo:= ASCAN(aCab, {|aCab| aCab[1] ==  'N8J_LOJA' })
	cChavCab += aCab[nPosCpo,2]
	
	// Fim Monstando Chave NF
	
	
	IF nOpc == 3

		IF .NOT. ( cTabCab )->(DbSeek( cChavCab))   

			IF RecLock(cTabCab, .T. )    	//Gravando PV de Vendas
				For nI := 1 to Len(aCab) sTep 1 
					&(cTabCab + "->"+aCab[Ni,1])	:= aCab[nI,2]
				Next nI
				( cTabCab )->(msUnLock())
			Else
				lTudoOK := .f.
			EndIF
			IF lTudoOK 
				//Acrescentando o Item na Chave da nf para formar a chave dos itens 
				//cChavCab += " + " 		
				For nI := 1 to Len(aItens) sTep 1
					// Montando a Chave da tab. de itens da NF
					aItemAtual := aClone( aItens[ nI ] )
					nPosCpo:= ASCAN(aItemAtual, {|aItemAtual| aItemAtual[1] ==  'N8K_ITEDOC' })
					cChavItens := cChavCab + aItemAtual[nPosCpo,2]

					DbselectArea( cTabItens )
					(cTabItens)->( dbSetOrder( 1 ) ) //N8K_FILIAL+N8K_DOC+N8K_SERIE+N8K_CLIFOR+N8K_LOJA+N8K_ITEDOC
					IF .NOT. (cTabItens)->(DbSeek( cChavItens))
						RecLock(cTabItens, .T. )
						(cTabItens)->N8K_DOC := ( cTabCab )->N8J_DOC
						For nII:= 1 to Len(aItemAtual) sTep 1 
							&( cTabItens + "->"+aItemAtual[nII,1])	:= aItemAtual[nII,2]
						Next nII
						(cTabItens)->( msUnLock() )
					Else  // Ja tem um item com o numero gravado
						lTudoOK := .f.
						Exit
					EndIF 
				Next nI
			EndIF
		Else
			lTudoOK	 := .f.	
		EndIF
	ElseIF nopc == 5  // Excluir
	
		IF  ( cTabCab )->(DbSeek( cChavCab))
			IF RecLock(cTabCab, .f. )    	//Excluindo Doc Fiscal Saida
				( cTabCab )->(DbDelete())
				( cTabCab )->(msUnLock())
			Else
				lTudoOK := .f.
			EndIF

			IF lTudoOk
				DbselectArea( cTabItens )
				(cTabItens)->( dbSetOrder( 1 ) )   //_FILIAL+_DOC+_SERIE+_CLIFOR+_LOJA+_ITEM
				( cTabItens )->(DbSeek( cChavCab)) // Dbseek para pegar todos os itens da nf. que está sendo excluida
				While ( cTabItens )->(!Eof()) .AND. (cTabItens)->(N8K_FILIAL+N8K_DOC+N8K_SERIE+N8K_CLIFOR+N8K_LOJA) == cChavCab
					IF RecLock(cTabItens, .f. )    	//Gravando PV de Vendas
						( cTabItens )->(DbDelete() )
						( cTabItens )->(msUnLock() )
					Else
						lTudoOK := .f.
						Exit
					EndIF
					(cTabItens)->( DbSkip() )
				EndDo
			EndIF
		EndIF
	EndIF

Return ( lTudoOk )


/** {Protheus.doc} fAgrVncNFS
Função que vincula  os documentos a Receber SE1 aos movimentos do originação 
@param:   	Dados do Titulo x Dados ref. ao controle agricola
Retorno:  	.t. ou .f. 
@author: 	Equipe Agro
@since: 	06/02/2018
@Uso: 		SIGAAGR - Originação de Grãos
*/
function fAgrVncRec(aCrec, nOpc)


	Local cTab 		:= 'N8L'
	Local nI		:= 0
	Local nII		:= 0
	Local cChavTab	:= ''
	Local lTudoOK	:= .t.
	Local aAux		:= {}
	
	//Somente executar? a fun??o se existir a tabela inclu?da na vers?o .23
	
	DbselectArea( cTab )
	( cTab )->( dbSetOrder( 1 ) ) // N8L_FILIAL + N8L_PREFIX + N8L_NUM + N8L_PARCEL + N8L_TIPO
	
	IF .not. Len( acRec) > 0
		lTudoOK := .F.
	EndIF

	IF nOpc == 3 .and. lTudoOK
		For nI := 1 to Len(aCRec) sTep 1
			aAux := aClone( aCRec[ nI] )

			//Montando Chave do Titulo
			cChavtab := FWxFILIAL( cTab )

			nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8L_PREFIX' })
			cChavTab +=  aAux[nPosCpo,2]

			nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8L_NUM' })
			cChavTab +=  PADR(aAux[nPosCpo,2], TamSx3('N8L_NUM')[1] )
			
			nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8L_PARCEL' })
			cChavTab +=  aAux[nPosCpo,2]

			nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8L_TIPO' })
			cChavTab += aAux[nPosCpo,2]
			// Fim Monstando Chave N8L
			IF !(( cTab )->(DbSeek( cChavTab)))   
				IF RecLock(cTab, .t. )    	//Gravando Vinc. do Titulo da E1
					For nII := 1 to Len( aAux ) sTep 1 
						&(cTab + "->"+aAux[Nii,1])	:= aAux[Nii,2]
					Next nI
					( cTab )->(msUnLock())
				Else
					lTudoOK	 := .f.
					Exit
				EndIF
			Else
				//estou incluindo mas achei o registro
				//deleto o resgistro achado 
				IF RecLock(cTab, .f. )    			//Deletando Vinc. do Titulo da E1
					( cTab )->( DbDelete() )
					( cTab )->( MsUnLock() )
				EndIf
				//recrio o regsitro correto
				IF RecLock(cTab, .t. )    	//Gravando Vinc. do Titulo da E1
					For nII := 1 to Len( aAux ) sTep 1 
						&(cTab + "->"+aAux[Nii,1])	:= aAux[Nii,2]
					Next nI
					( cTab )->(msUnLock())
				EndIf
				lTudoOK	 := .t.
				Exit
			EndIF
		nExt nI
	ElseIF nopc == 5  .and. lTudoOk // Excluir
	
		For nI := 1 to Len(aCRec) sTep 1
			aAux := aClone( aCRec[ nI] )

			//Montando Chave do Titulo
			cChavtab := FWxFILIAL( cTab )

			nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8L_PREFIX' })
			cChavTab +=  aAux[nPosCpo,2]
			
			nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8L_NUM' })
			cChavTab += PADR(aAux[nPosCpo,2], TamSx3('N8L_NUM')[1] ) 

			nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8L_PARCEL' })
			cChavTab +=  aAux[nPosCpo,2]

			nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8L_TIPO' })
			cChavTab += aAux[nPosCpo,2]
			// Fim Monstando Chave N8L
			IF ( cTab )->(DbSeek( cChavTab))   
				IF RecLock(cTab, .f. )    			//Deletando Vinc. do Titulo da E1
					( cTab )->( DbDelete() )
					( cTab )->( MsUnLock() )
				Else
					lTudoOK	 := .f.
					Exit
				EndIF			
			EndIF
		nExt nI
	EndIF	

Return ( lTudoOk )
//

/** {Protheus.doc} fAgrVncPag
Função que vincula  as Contas a pagar SE2 aos movimentos do originação 
@param:   	Dados do Titulo x Dados ref. ao controle agricola
Retorno:  	.t. ou .f. 
@author: 	Equipe Agro
@since: 	12/02/2018
@Uso: 		SIGAAGR - Originação de Grãos
*/
function fAgrVncPag(aCPag, nOpc)


	Local cTab 		:= 'N8M'
	Local nI		:= 0
	Local nII		:= 0
	Local cChavTab	:= ''
	Local lTudoOK	:= .t.
	Local aAux		:= {}

	If N8M->(ColumnPos("N8M_FILIAL")) > 0
		
		DbselectArea( cTab )
		( cTab )->( dbSetOrder( 1 ) ) // N8M_FILIAL+N8M_PREFIX+N8M_NUM+N8M_PARCEL+N8M_TIPO+N8M_FORNEC+N8M_LOJA                                                                                                                                                                                     
		
		IF .not. Len( aCPag) > 0
			lTudoOK := .F.
		EndIF
	
		IF nOpc == 3 .and. lTudoOK
			For nI := 1 to Len(aCPag) sTep 1
				aAux := aClone( aCPag[ nI] )
	
				//Montando Chave do Titulo
				cChavtab := FWxFILIAL( cTab )
	
				nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8M_PREFIX' })
				cChavTab +=  aAux[nPosCpo,2]
	
				nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8M_NUM' })
				cChavTab +=  aAux[nPosCpo,2]
				
				nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8M_PARCEL' })
				cChavTab +=  aAux[nPosCpo,2]
	
				nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8M_TIPO' })
				cChavTab += aAux[nPosCpo,2]
				
				nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8M_FORNEC' })
				cChavTab += aAux[nPosCpo,2]
				
				nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8M_LOJA' })
				cChavTab += aAux[nPosCpo,2]
				// Fim Monstando Chave N8M
				IF .NOT. ( cTab )->(DbSeek( cChavTab))   
					IF RecLock(cTab, .t. )    	//Gravando Vinc. do Titulo da E2
						For nII := 1 to Len( aAux ) sTep 1 
							&(cTab + "->"+aAux[Nii,1])	:= aAux[Nii,2]
						Next nI
						( cTab )->(msUnLock())
					Else
						lTudoOK	 := .f.
						Exit
					EndIF
				Else
					//estou incluindo mas achei o registro
					//deleto o resgistro achado 
					IF RecLock(cTab, .f. )    			//Deletando Vinc. do Titulo da E2
						( cTab )->( DbDelete() )
						( cTab )->( MsUnLock() )
					EndIf
					//recrio o regsitro correto
					IF RecLock(cTab, .t. )    	//Gravando Vinc. do Titulo da E2
						For nII := 1 to Len( aAux ) sTep 1 
							&(cTab + "->"+aAux[Nii,1])	:= aAux[Nii,2]
						Next nI
						( cTab )->(msUnLock())
					EndIf
					lTudoOK	 := .t.
					Exit
				EndIF
			nExt nI
		ElseIF nopc == 5  .and. lTudoOk // Excluir
		
			For nI := 1 to Len(aCPag) sTep 1
				aAux := aClone( aCPag[ nI] )
	
				//Montando Chave do Titulo
				cChavtab := FWxFILIAL( cTab )
	
				nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8M_PREFIX' })
				cChavTab +=  aAux[nPosCpo,2]
				
				nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8M_NUM' })
				cChavTab +=  aAux[nPosCpo,2]
	
				nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8M_PARCEL' })
				cChavTab +=  aAux[nPosCpo,2]
	
				nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8M_TIPO' })
				cChavTab += aAux[nPosCpo,2]
				
				nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8M_FORNEC' })
				cChavTab += aAux[nPosCpo,2]
				
				nPosCpo:= ASCAN(aAux, {|aAux| aAux[1] ==  'N8M_LOJA' })
				cChavTab += aAux[nPosCpo,2]
				// Fim Monstando Chave N8M
				IF ( cTab )->(DbSeek( cChavTab))   
					IF RecLock(cTab, .f. )    			//Deletando Vinc. do Titulo da E2
						( cTab )->( DbDelete() )
						( cTab )->( MsUnLock() )
					Else
						lTudoOK	 := .f.
						Exit
					EndIF
				Else
					lTudoOK	 := .f.
					Exit
				EndIF
			nExt nI
		EndIF	
	EndIf
Return ( lTudoOk )

/*{Protheus.doc} AGRMOVFARD
//Função para tratar a gravação na dados na tabela
N9D ( Movimento de fardos ), Trata inclusão, alteração e deleção.
@author roney.maia
@since 23/02/2018
@version 1.0
@return ${Array}, Array contendo o IDMOV caso inclusão e também uma mensagem de erro caso ocorrer
@param aDados, array, Array contendo os fardos a serem inclusos ou alterados


		aDados := 	{	{{"N9D_FILIAL",  "D MG 01 "},
						{"N9D_SAFRA",	  "2018" },
						{"N9D_FARDO",	  "F00001" },
						{"N9D_TIPMOV",	       "1" },
						{"N9D_DATA",	 dDAtaBase },
						{"N9D_CODRES", 	  "000001" }}   ,    
						
						 									{{"N9D_FILIAL",  "D MG 01 "},
						 									{"N9D_FARDO",	  "2018" },
															{"N9D_FARDO",	  "F00002" },
															{"N9D_TIPMOV",	       "3" },
															{"N9D_DATA",	 dDAtaBase },
															{"N9D_CODRES", 	  "000002" }}		}
								

@param nIncUpdDel, number, Operação de 1 - Inclusão, 2 - Alteração ou 3 - Deleção
@param nIndice, numeric, Indice de ordenação de pesquisa
@param aChave, array, Chave para pesquisa de registro quando em modo de alteração

Exemplo: {{"D MG 02 "},{"2017"},{"200180123FARD001"},{"1"},{"0000000001"}} // Estrutura necessária para tratar o tamanho dos dados da chave
														                  comparados ao tamanho do campo, levando em consideração dados de
														                  campos vazios

@param aUpdLote, array, Atualização de fardos em lote

###Exemplo###

aAltera := {   {"N9D_TIPMOV","1"}, {"N9D_DATA",dDAtaBase }    }
aChave := {{"D MG 02 "},{"2017"},{"200180123FARD001"},{"1"},{"0000000001"}}

aUpdLote :=  {  {aAltera, aChave} ,  { aAltera2, aChave2 }     }

@param aDelLote, array, Deleção de fardos em lote

###Exemplo###

aDelLote :=  { {{"D MG 01 "},{"2017"},{"200180123FARD001"},{"01"},{"0000000001"}} ,  
			   {{"D MG 02 "},{"2017"},{"200180123FARD001"},{"01"},{"0000000002"}} }
			
@type function
// OBS : N9D_IDMOV não é necessário alteração por se tratar de um campo auto incremental //
*/
Function AGRMOVFARD(aDados, nIncUpdDel, nIndice, aChave, aUpdLote, aDelLote)

	Local aArea			:= GetArea()
	Local nIt			:= 0
	Local nX			:= 0	
	Local cId			:= ""
	Local aStruct		:= {}
	Local cChave		:= ""
	Local aIndice		:= {}	
	Local lUpdLote		:= .F.
	Local lDelLote		:= .F.
	Local cQry			:= ""
	Local cAliasQry     := ""
	Local nItStr		:= 0
	Local nQtdFor		:= 0
	Local nT
	Local lRetorno      := .t.
	
	Default aDados 		:= {}
	Default nIncUpdDel 	:= 1
	Default nIndice		:= 1
	Default aChave	 	:= {}
	Default aUpdLote	:= {}

	If N9D->(ColumnPos("N9D_FILIAL")) > 0
		
		If !Empty(aUpdLote)
			nIncUpdDel := 2
			lUpdLote   := .T.
		EndIf
		
		If !Empty(aDelLote)
			nIncUpdDel := 3
			lDelLote   := .T.
		EndIf
			
		DbSelectArea("N9D")
		N9D->(dbSetOrder(nIndice))
		N9D->(dbGoTop())
			
		aStruct := N9D->(dBStruct()) // Obtém a estrutura
			
		Do Case  // Validações de consistencia da gravação
			Case !lUpdLote .AND. nIncUpdDel != 3 .AND. Empty(aDados) // Array de dados vazio
				N9D->(dbCloseArea())
				RestArea(aArea)
				Return {cId, STR0035} // #"Array de dados vazio."
			Case nIncUpdDel == 2 .AND. !lUpdLote .AND. Empty(aChave) // Alteração de registro sem informar uma chave
				N9D->(dbCloseArea())
				RestArea(aArea)
				Return {cId, STR0036} // #"Para uma alteração de registro é necessário informar uma chave como parâmetro."
		EndCase
		
		If lDelLote
			aIndice := Separa(N9D->(IndexKey(nIndice)), "+")
			
			For nIt := 1 To Len(aDelLote)
				If Len(aDelLote[nIt]) > Len(aIndice) // Compara o tamanho da chave com o tamanho do indice, Se for menor nao tem problema é um indice parcial
					N9D->(dbCloseArea())
					RestArea(aArea)
					Return {cId, STR0038} // #"Chave informada é maior que a chave do indice informado."
				EndIf
			Next nIt		
		EndIf	
		
		If nIncUpdDel == 1 .AND. !lUpdLote	
			If N9D->(Eof()) .AND. (nPos := aScan(aStruct, {|x| AllTrim(x[1]) == "N9D_IDMOV" })) > 0
				cId := StrZero(1, aStruct[nPos][3])
			Else		
				nPosFil := aScan(aDados[1], { |x| AllTrim(x[1]) == "N9D_FILIAL"})
				nPosSaf	:= aScan(aDados[1], { |x| AllTrim(x[1]) == "N9D_SAFRA"})
				nPosFrd	:= aScan(aDados[1], { |x| AllTrim(x[1]) == "N9D_FARDO"})		
			
				For nIt := 1 To Len(aDados)
					// Verifica o último registro inserido para a filial, safra e fardo para realizar a cópia dos
					// campos. A cópia é realizada apenas dos campos que não foram enviados no parâmetro (aDados)
					cAliasQry := GetNextAlias()
					cQry := " SELECT N9D.* "
					cQry += "   FROM " + RetSqlName("N9D") + " N9D "
					cQry += "  WHERE N9D.N9D_FILIAL = '"+ aDados[nIt][nPosFil][2] +"' "   // D MG 01
					cQry += "    AND N9D.N9D_SAFRA  = '"+ aDados[nIt][nPosSaf][2] +"' "   // D MG 01 
					cQry += "    AND N9D.N9D_FARDO  = '"+ aDados[nIt][nPosFrd][2] +"' "
					cQry += "    AND N9D.D_E_L_E_T_ <> '*' "
					cQry += "    AND N9D_IDMOV IN (SELECT MAX(N9D2.N9D_IDMOV) "				
					cQry += "	                     FROM " + RetSqlName("N9D") + " N9D2 "
					cQry += "	                    WHERE N9D2.N9D_FILIAL = N9D.N9D_FILIAL "
					cQry += "	                      AND N9D2.N9D_SAFRA  = N9D.N9D_SAFRA "
					cQry += "		                  AND N9D2.N9D_FARDO  = N9D.N9D_FARDO AND N9D2.D_E_L_E_T_ <> '*') "	
					cQry := ChangeQuery(cQry)	
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.F.,.T.)
	
					dbSelectArea(cAliasQry)
					(cAliasQry)->(DbGoTop())
					
					If (cAliasQry)->(Eof()) .AND. (nPos := aScan(aStruct, {|x| AllTrim(x[1]) == "N9D_IDMOV" })) > 0
						Aadd(aDados[nIt],{"N9D_IDMOV", StrZero(1, aStruct[nPos][3])})
					Else	
						If (cAliasQry)->(!Eof())												
							For nItStr := 1 To Len(aStruct)
								// Apenas insere no array (aDados) os campos que não estão no array
								If (aScan(aDados[nIt], { |x| AllTrim(x[1]) == aStruct[nItStr][1]})) == 0 .AND. !Empty((cAliasQry)->&(AllTrim(aStruct[nItStr][1])))
									If AllTrim(aStruct[nItStr][1]) == "N9D_IDMOV"	                    		
										Aadd(aDados[nIt],{"N9D_IDMOV", Soma1((cAliasQry)->N9D_IDMOV)})
									Else
										If aStruct[nItStr][2] == "D"
											AADD(aDados[nIt], {aStruct[nItStr][1], STOD((cAliasQry)->&(AllTrim(aStruct[nItStr][1])))})
										Else
											AADD(aDados[nIt], {aStruct[nItStr][1], (cAliasQry)->&(AllTrim(aStruct[nItStr][1]))})
										EndIf
									EndIf
								EndIf
							Next nItStr
						EndIf																	 	
					EndIf
					(cAliasQry)->(DbCloseArea())							
				Next nIt
			EndIf		
		EndIf
			
		//Trata chave caso necessário com os espaços especificos baseado no tamanho do campo para uso no dbSeek
		If ((nIncUpdDel == 2 .OR. nIncUpdDel == 3) .AND. !Empty(aChave)) .OR. lUpdLote
		
			aIndice := Separa(N9D->(IndexKey(nIndice)), "+")
				
			If lUpdLote // Se for update em lote, trata as chaves para cada fardo
				For nIt := 1 To Len(aUpdLote)
					If Len(aUpdLote[nIt][2]) > Len(aIndice) // Compara o tamanho da chave com o tamanho do indice, Se for menor nao tem problema é um indice parcial
						N9D->(dbCloseArea())
						RestArea(aArea)
						Return {cId, STR0038} // #"Chave informada é maior que a chave do indice informado."
					EndIf
				Next nIt
				
				For nIt := 1 To Len(aUpdLote) // Trata o array de chave para cada fardo com o tamanho correto dos campos
					For nX := 1 To Len(aUpdLote[nIt][2])
						aAdd(aUpdLote[nIt][2][nX], aIndice[nX])
						If (nPos := aScan(aStruct, {|x| AllTrim(x[1]) == aUpdLote[nIt][2][nX][2] })) > 0 
							If Len(aUpdLote[nIt][2][nX][1]) < aStruct[nPos][3]
								cChave += aUpdLote[nIt][2][nX][1] + Space( aStruct[nPos][3] - Len(aUpdLote[nIt][2][nX][1]) )
							Else
								cChave += aUpdLote[nIt][2][nX][1]
							EndIf
						EndIf
					Next nX
					
					aAdd(aUpdLote[nIt], cChave) // Adiciona a chave tratada ao fardo
					cChave := "" // Reset de variavel para proxima iteração
				Next nIt
			Else // Trata a chave padrão do parametro para um unico fardo
				If Len(aChave) > Len(aIndice) // Compara o tamanho da chave com o tamanho do indice, Se for menor nao tem problema é um indice parcial
					N9D->(dbCloseArea())
					RestArea(aArea)
					Return {cId, STR0038} // #"Chave informada é maior que a chave do indice informado."
				EndIf
					
				For nIt := 1 To Len(aChave)
					aAdd(aChave[nIt], aIndice[nIt])
					If (nPos := aScan(aStruct, {|x| AllTrim(x[1]) == aChave[nIt][2] })) > 0 
						If Len(aChave[nIt][1]) < aStruct[nPos][3]
							cChave += aChave[nIt][1] + Space( aStruct[nPos][3] - Len(aChave[nIt][1]) )
						Else
							cChave += aChave[nIt][1]
						EndIf
					EndIf
				Next nIt
			EndIf	
		EndIf
	
		If nIncUpdDel == 4
			cAliasQry := GetNextAlias()
			
			cQry := " SELECT MAX(N9D_IDMOV) AS IDMOV"
			cQry += " FROM " + RetSqlName("N9D") + " N9D "
			cQry += " WHERE N9D.N9D_FILIAL = '"+ FWxFilial('N9D') +"' "  
			cQry += " AND D_E_L_E_T_ = ' ' "
			cQry += " AND N9D.N9D_SAFRA  = '"+ DXI->DXI_SAFRA +"' "
			cQry += " AND N9D.N9D_FARDO  = '"+ DXI->DXI_ETIQ +"' "
			cQry += " AND N9D.N9D_TIPMOV  = '01' "		
			cQry := ChangeQuery(cQry)	
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.F.,.T.)
	
			dbSelectArea(cAliasQry)
			(cAliasQry)->(DbGoTop())
			
			Aadd(aChave,{(cAliasQry)->(IDMOV)})		
			
			(cAliasQry)->(DbCloseArea())
		
			aIndice := Separa(N9D->(IndexKey(nIndice)), "+")
			
			If Len(aChave) > Len(aIndice) // Compara o tamanho da chave com o tamanho do indice, Se for menor nao tem problema é um indice parcial
				N9D->(dbCloseArea())
				RestArea(aArea)
				Return {cId, STR0038} // #"Chave informada é maior que a chave do indice informado."
			EndIf
		EndIF
	
		// #################### INICIO DE GRAVAÇÃO ##########################
		BEGIN TRANSACTION
			
			If lUpdLote
				For nIt := 1 To Len(aUpdLote)
					N9D->(dbGoTop()) // Posiciona no topo do alias com a ordem ja setada anteriormente na função
					If N9D->(dbSeek(aUpdLote[nIt][3]))
						If RecLock("N9D", .F.) // Procura o registro e abre a gravação																	
							For nX := 1 To Len(aUpdLote[nIt][1])
								If !(AllTrim(aUpdLote[nIt][1][nX][1]) $ "N9D_IDMOV") // Verificação para não gravar o campo IDMOV caso passado nos dados
									N9D->&(AllTrim(aUpdLote[nIt][1][nX][1])) := aUpdLote[nIt][1][nX][2]
								EndIf		
							Next nX						
							N9D->(MsUnlock())
						EndIf
					Else
						lRetorno := .f.
						DisarmTransaction() // Se não encontrou um dos fardos, então desarma a transação
						Break
					EndIf	
				Next nIt
			ElseIf lDelLote			
				For nIt := 1 To Len(aDelLote)
					cChave := "" // Reset de variavel para proxima iteração
					
					For nX := 1 To Len(aDelLote[nIt])					
						If (nPos := aScan(aStruct, {|x| AllTrim(x[1]) == aIndice[nX] })) > 0 
							If Len(aDelLote[nIt][nX][1]) < aStruct[nPos][3]
								cChave += aDelLote[nIt][nX][1] + Space(aStruct[nPos][3] - Len(aDelLote[nIt][nX][1]))
							Else
								cChave += aDelLote[nIt][nX][1]
							EndIf
						EndIf
					Next nX												
				
					N9D->(dbGoTop()) // Posiciona no topo do alias com a ordem ja setada anteriormente na função
					If N9D->(dbSeek(cChave))
						If RecLock("N9D", .F.) // Procura o registro e abre a gravação						
							N9D->(DbDelete())						
							N9D->(MsUnlock())
						EndIf				
					Else
						lRetorno := .f.
						DisarmTransaction() // Se não encontrou um dos fardos, então desarma a transação
						Break
					EndIf			
				Next nIt			
			Else
				nQtdFor := IIf(nIncUpdDel == 3,1,Len(aDados))	
				nIt := 0
				nX  := 0			
				For nIt := 1 To nQtdFor	// Percorre cada linha de registro		
					If nIncUpdDel == 1
						If RecLock("N9D", .T.) // Se for inclusão, então grava os dados
							N9D->N9D_IDMOV  := cId  // Grava o IDMOV obtido anteriormente (Apenas para a primeira inclusão)						
							For nX := 1 To Len(aDados[nIt])
								N9D->&(aDados[nIt][nX][1]) := aDados[nIt][nX][2]								
							Next nX
							N9D->(MsUnlock())
						EndIf
					ElseIf nIncUpdDel == 2 .OR. nIncUpdDel == 3 // Se for alteração/deleção
						N9D->(dbGoTop()) // Posiciona no topo do alias com a ordem ja setada anteriormente na função
						If N9D->(dbSeek(cChave))
							If RecLock("N9D", .F.) // Procura o registro e abre a gravação
								If nIncUpdDel == 3
									N9D->(DbDelete())
								EndIf
								
								If nIncUpdDel == 2						
									For nX := 1 To Len(aDados[nIt])
										If !(AllTrim(aDados[nIt][nX][1]) $ "N9D_IDMOV") // Verificação para não gravar o campo IDMOV caso passado nos dados
											N9D->&(AllTrim(aDados[nIt][nX][1])) := aDados[nIt][nX][2]
										EndIf		
									Next nX
								EndIf
								N9D->(MsUnlock())
							EndIf
						Else
							lRetorno := .f.
							DisarmTransaction() // Se não encontrou um dos fardos, então desarma a transação
							Break
						EndIf				
					ElseIf nIncUpdDel == 4	
						For nT := 1 to Len(aChave)
							cChave += aChave[nT][1]
						Next nT
						
						If N9D->(dbSeek(cChave))
							If RecLock("N9D", .F.) 
								For nX := 1 To Len(aDados[1])
									N9D->&(aDados[1][nX][1]) := aDados[1][nX][2]								
								Next nX
								N9D->(MsUnlock())
							EndIf
						Else
							lRetorno := .f.
							DisarmTransaction() // Se não encontrou um dos fardos, então desarma a transação
							Break
						EndIF
					EndIf			
				Next nIt
			EndIf
	
		END TRANSACTION
		
		N9D->(dbCloseArea())
		RestArea(aArea)
		If !lRetorno
			Return {cId, STR0039} // #"Registro não encontrado."
		EndIf
	EndIf
Return {cId, ""}

/*{Protheus.doc} AGRXCOM1
Funçaõ centralizadora para controlar a integração no controle de alçadas com o modulo AGRO. 
Esta função é para chamar as views de acordo com o tipo de documentos A. Está atrelada ao botão tipo documento.
Utilizado no MATA097 - funcao A097Visual

@param: cNumDoc	=> SCR->CR_NUM;
@param: cTipDoc => SCR->CR_TIPO
@param: cRecno  => SCR->(RECNO()) - Permite pegar todos os campos da SCR se necessário. 
@author: filipe.olegini
@since: 12/04/2018
@Uso: Integação compras
@Retorno: nil .
*/

Function AGRXCOM1(cNumDoc, cTipDoc, cRecno)

	If Findfunction("OGA700")
	    If cTipDoc == "A1" //Multas
			FWExecView(STR0040,'OGA700',1,,{||.T.},,) //Registro de Negócio		
	    ElseIf cTipDoc == "A2" // Comissões			
			OGC110VIEW(cNumDoc) //abre tela de detalhes da comissão	
	    ElseIf cTipDoc == "A3" .OR. cTipDoc == "A4"  //NCC	NDC	
	        OGX001VCtr( NJR->(Recno()))	
		EndIf
	EndIf
		
Return

/*{Protheus.doc} AGRXCOM2
Funçaõ centralizadora para controlar a integração no controle de alçadas com o modulo AGRO. 
Esta função é chamada para retornar os alias utilizado nos dbselectarea para os documentos do tipo A.
Utilizado no MATA094 e MATA097 em varios pontos.

@param: cNumDoc	=> SCR->CR_NUM;
@param: cTipDoc => SCR->CR_TIPO
@param: cRecno  => SCR->(RECNO()) - Permite pegar todos os campos da SCR se necessário.
@author: filipe.olegini
@since: 12/04/2018
@Uso: Integação compras
@Retorno: nil .
*/

Function AGRXCOM2(cNumDoc, cTipDoc, cRecno)
	Local cArea		:= ""
	Local nIndice	:= 1
	Local cChave	:= ""
	
	If N79->(ColumnPos("N79_FILIAL")) > 0 .And. N89->(ColumnPos("N89_FILIAL")) > 0 .And. N7Q->(ColumnPos("N7Q_FILIAL")) > 0 
	
		If cTipDoc == "A1" //multas
			If FwISINCALLSTACK('A097Visual') 
				cArea	:= "N79"
				nIndice	:= 1
				cChave	:= FWxFilial("N79")+Substr(cNumDoc,1,len(N79->N79_CODNGC))+Substr(cNumDoc,7,3)
			ElseIf FwISINCALLSTACK('A097Lock')
				cArea	:= "N79"
				nIndice	:= 1
				cChave	:= xFilial("N79")+cNumDoc
			EndIf
		
		ElseIf cTipDoc == "A2" //comissões
			cArea	:= "N89"
			nIndice	:= 3
			cChave	:= xFilial("N89")+cNumDoc
	    
	    ElseIf cTipDoc $ "A3|A4" //NCC  
	        cArea	:= "NJR"
			nIndice	:= 1 //NJR_FILIAL+NJR_CODCTR
			cChave	:= xFilial("NJR") + PadR(cNumDoc, TamSX3("NJR_CODCTR")[1]) //O PADR retira o sequencia do documento
		EndIf
	
	EndIf
	
Return {cArea,nIndice,cChave}

/*{Protheus.doc} AGRXCOM3
Funçaõ centralizadora para controlar a integração no controle de alçadas com o modulo AGRO. 
Esta função é chamada no commit dos documentos do tipo A, é chamada para todas as operações e todos os niveis
Utilizado no MATA094 - A094Commit

@param: cNumDoc	=> SCR->CR_NUM;
@param: cTipDoc => SCR->CR_TIPO
@param: cRecno  => SCR->(RECNO()) - Permite pegar todos os campos da SCR se necessário.
@param: cIdOper => Operação que está sendo realizada 001 - Aprovacao / 005 - Rejeicao
@author: filipe.olegini
@since: 12/04/2018
@Uso: Integação compras
@Retorno: nil .
*/

Function AGRXCOM3(cNumDoc, cTipDoc, cRecno, cIdOper)
	Local aArea		:= GetArea()
    Local aAreaN89  := N89->(GetArea())
	
	If N89->(ColumnPos("N89_FILIAL")) > 0
		If cTipDoc == "A1" //multas
	        //Não tem ação neste tipo
	
		ElseIf cTipDoc == "A2" //comissões
			
			If cIdOper == "005" //rejeitado
				
	            dbSelectArea("N89")
	            dbSetOrder(3)
	            If dbSeek(FWxFilial("N89") + PadR(AllTrim(cNumDoc),TamSx3('N89_CODCOM')[1] ))
	
	                While N89->(!EOF()) .AND. N89->N89_FILIAL == FWxFilial("N89") .AND. N89->N89_CODCOM == PadR(AllTrim(cNumDoc),TamSx3('N89_CODCOM')[1] )
	                
	                    If RecLock("N89",.F.)
	                        N89->N89_STATUS := '5'
	                        N89->(msUnLock())
	                    EndIf
	
	                    N89->(dbSkip())
	                EndDo
	            EndIf
	    	EndIf	
	
		ElseIf cTipDoc == "A3" //NCC
	        //Não tem ação neste tipo
		EndIf
		
	    RestArea(aAreaN89)
		RestArea(aArea)
	EndIf
	
Return 

/*{Protheus.doc} AGRXCOM4
Funçaõ centralizadora para controlar a integração no controle de alçadas com o modulo AGRO. 
Esta função é chamado na motangem dos campos para incluir campos referente aos documentos do tipo A.
Utilizado no MATA094 - ModelDef

@param: cNumDoc	=> SCR->CR_NUM;
@param: cTipDoc => SCR->CR_TIPO
@param: cRecno  => SCR->(RECNO()) - Permite pegar todos os campos da SCR se necessário.
@author: filipe.olegini
@since: 12/04/2018
@Uso: Integação compras
@Retorno: nil .
*/

Function AGRXCOM4(cNumDoc, cTipDoc, cRecno)
	Local aFields	:= {}
	Local aArea		:= GetArea()
	
	If N79->(ColumnPos("N79_FILIAL")) > 0 .And. N7Q->(ColumnPos("N7Q_FILIAL")) > 0
	
		If cTipDoc == "A1" //multas
			
			cTitulo := iif(POSICIONE("N79",1,xFilial("N79")+Substr(cNumDoc,1,TamSX3("N79_CODNGC")[1])+Substr(cNumDoc,7,TamSX3("N79_VERSAO")[1]) ,"N79_OPENGC") == '1', STR0016,"Cliente")
	        
	        aAdd(aFields,{cTitulo					,;  // 	[01]  C   Titulo do campo 
	        			  cTitulo					,;	// 	[02]  C   ToolTip do campo
						  "ENTIDADE"				,;	// 	[03]  C   Id do Field
						  "C"						,;	// 	[04]  C   Tipo do campo
						  TAMSX3("A2_NOME")[1]		,;	// 	[05]  N   Tamanho do campo
						  0							,;	// 	[06]  N   Decimal do campo
						  NIL						,;	// 	[07]  B   Code-block de validação do campo
						  NIL						,;	// 	[08]  B   Code-block de validação When do campo
						  NIL						,;	//	[09]  A   Lista de valores permitido do campo
						  .F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
						  NIL						,;	//	[11]  B   Code-block de inicializacao do campo
						  NIL						,;	//	[12]  L   Indica se trata-se de um campo chave
						  NIL						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						  .F.						})	// 	[14]  L   Indica se o campo é virtual		
						 
			aAdd(aFields,{STR0041					,;	// # "Contrato"	 
						  STR0041					,;	// 	[02]  C   ToolTip do campo # "Contrato"
						  "N79_CODCTR"				,;	// 	[03]  C   Id do Field
						  TamSX3( "N79_CODCTR" )[3]	,;	// 	[04]  C   Tipo do campo
						  TamSX3( "N79_CODCTR" )[1]	,;	// 	[05]  N   Tamanho do campo
						  TamSX3( "N79_CODCTR" )[2]	,;	// 	[06]  N   Decimal do campo
						  NIL						,;	// 	[07]  B   Code-block de validação do campo
						  NIL						,;	// 	[08]  B   Code-block de validação When do campo
						  NIL						,;	//	[09]  A   Lista de valores permitido do campo
						  .F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
						  NIL						,;	//	[11]  B   Code-block de inicializacao do campo
						  NIL						,;	//	[12]  L   Indica se trata-se de um campo chave
						  NIL						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						  .F.						})	// 	[14]  L   Indica se o campo é virtual					 
	
			aAdd(aFields,{STR0042					,;	// # "Tipo Cancel."	 
						  STR0042					,;	// 	[02]  C   ToolTip do campo # "Tipo Cancel."
						  "N79_TPCANC"				,;	// 	[03]  C   Id do Field
						  TamSX3( "N79_TPCANC" )[3]	,;	// 	[04]  C   Tipo do campo
						  TamSX3( "N79_TPCANC" )[1]	,;	// 	[05]  N   Tamanho do campo
						  TamSX3( "N79_TPCANC" )[2]	,;	// 	[06]  N   Decimal do campo
						  NIL						,;	// 	[07]  B   Code-block de validação do campo
						  NIL						,;	// 	[08]  B   Code-block de validação When do campo
						  {STR0044,STR0045},;	//	[09]  A   Lista de valores permitido do campo # "1=Fixação" # "2=Quantidade"
						  .F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
						  NIL						,;	//	[11]  B   Code-block de inicializacao do campo
						  NIL						,;	//	[12]  L   Indica se trata-se de um campo chave
						  NIL						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						  .F.						})	// 	[14]  L   Indica se o campo é virtual					 
	
			aAdd(aFields,{STR0043					,;	// # "Operaçao"	 
						  STR0043					,;	// 	[02]  C   ToolTip do campo # "Operaçao"
						  "N79_OPENGC"				,;	// 	[03]  C   Id do Field
						  TamSX3( "N79_OPENGC" )[3]	,;	// 	[04]  C   Tipo do campo
						  TamSX3( "N79_OPENGC" )[1]	,;	// 	[05]  N   Tamanho do campo
						  TamSX3( "N79_OPENGC" )[2]	,;	// 	[06]  N   Decimal do campo
						  NIL						,;	// 	[07]  B   Code-block de validação do campo
						  NIL						,;	// 	[08]  B   Code-block de validação When do campo
						  {STR0046,STR0047}  ,;	//	[09]  A   Lista de valores permitido do campo # "1=Compras" # "2=Vendas"
						  .F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
						  Nil						,;	//	[11]  B   Code-block de inicializacao do campo
						  NIL						,;	//	[12]  L   Indica se trata-se de um campo chave
						  NIL						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						  .F.						})	// 	[14]  L   Indica se o campo é virtual
	    
	    ElseIf cTipDoc == "A2" //comissões
	        //Não tem ação apra este tipo
	
	    ElseIf cTipDoc == "A3" .OR. cTipDoc == "A4" //NCC NDC
	        
	        aAdd(aFields,{STR0048					,;  // 	[01]  C   Cliente
	        			  STR0048					,;	// 	[02]  C   ToolTip do campo
						  "A1_NOME"				    ,;	// 	[03]  C   Id do Field
						  TAMSX3("A1_NOME")[3]		,;	// 	[04]  C   Tipo do campo
						  TAMSX3("A1_NOME")[1]		,;	// 	[05]  N   Tamanho do campo
						  TAMSX3("A1_NOME")[2]		,;	// 	[06]  N   Decimal do campo
						  NIL						,;	// 	[07]  B   Code-block de validação do campo
						  NIL						,;	// 	[08]  B   Code-block de validação When do campo
						  NIL						,;	//	[09]  A   Lista de valores permitido do campo
						  .F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
						  NIL						,;	//	[11]  B   Code-block de inicializacao do campo
						  NIL						,;	//	[12]  L   Indica se trata-se de um campo chave
						  NIL						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						  .F.						})	// 	[14]  L   Indica se o campo é virtual		
						 
			aAdd(aFields,{STR0041					,;	//          # "Contrato"	 
						  STR0041					,;	// 	[02]  C   ToolTip do campo # "Contrato"
						  "NJR_CTREXT"				,;	// 	[03]  C   Id do Field
						  TamSX3( "NJR_CTREXT" )[3]	,;	// 	[04]  C   Tipo do campo
						  TamSX3( "NJR_CTREXT" )[1]	,;	// 	[05]  N   Tamanho do campo
						  TamSX3( "NJR_CTREXT" )[2]	,;	// 	[06]  N   Decimal do campo
						  NIL						,;	// 	[07]  B   Code-block de validação do campo
						  NIL						,;	// 	[08]  B   Code-block de validação When do campo
						  NIL						,;	//	[09]  A   Lista de valores permitido do campo
						  .F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
						  NIL						,;	//	[11]  B   Code-block de inicializacao do campo
						  NIL						,;	//	[12]  L   Indica se trata-se de um campo chave
						  NIL						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						  .F.						})	// 	[14]  L   Indica se o campo é virtual					 
		
		EndIf
	
		
		RestArea(aArea)
	EndIf
	
Return aFields

/*{Protheus.doc} AGRXCOM5
Funçaõ centralizadora para controlar a integração no controle de alçadas com o modulo AGRO. 
Esta função é chamada no estorno dos documentos do tipo A.
Utilizado no MATA094 - A094VldEst

@param: cNumDoc	=> SCR->CR_NUM;
@param: cTipDoc => SCR->CR_TIPO
@param: cRecno  => SCR->(RECNO()) - Permite pegar todos os campos da SCR se necessário.
@author: filipe.olegini
@since: 12/04/2018
@Uso: Integação compras
@Retorno: nil .
*/

Function AGRXCOM5(cNumDoc, cTipDoc, cRecno)
	Local lRet	:= .F.
	
	Help('',1, "AGRXFUN1NOCOM") // # Operação não disponível. # O modulo do agroindustria não permite esta operação para os documentos do tipo A.
	
Return lRet

/*{Protheus.doc} AGRXCOM6
Funçaõ centralizadora para controlar a integração no controle de alçadas com o modulo AGRO. 
Esta função é chamada no bloqueio dos documentos do tipo A.
Utilizado no MATA094 - A094Bloqu

@param: cNumDoc	=> SCR->CR_NUM;
@param: cTipDoc => SCR->CR_TIPO
@param: cRecno  => SCR->(RECNO()) - Permite pegar todos os campos da SCR se necessário.
@author: filipe.olegini
@since: 12/04/2018
@Uso: Integação compras
@Retorno: nil .
*/

Function AGRXCOM6(cNumDoc, cTipDoc, cRecno)
	Local lRet	:= .F.
	
	Help('',1, "AGRXFUN1NOCOM") // # Operação não disponível. # O modulo do agroindustria não permite esta operação para os documentos do tipo A.
	
Return lRet

/*{Protheus.doc} AGRXCOM7
Funçaõ centralizadora para controlar a integração no controle de alçadas com o modulo AGRO. 
Esta função é chamada no Rejeitar dos documentos do tipo A.
Utilizado no MATA094 - A094Rejeita

@param: cNumDoc	=> SCR->CR_NUM;
@param: cTipDoc => SCR->CR_TIPO
@param: cRecno  => SCR->(RECNO()) - Permite pegar todos os campos da SCR se necessário.
@author: filipe.olegini
@since: 12/04/2018
@Uso: Integação compras
@Retorno: nil .
*/

Function AGRXCOM7(cNumDoc, cTipDoc, cRecno)
	Local lRet	:= .T.
	
	
Return lRet

/*{Protheus.doc} AGRXCOM8
Funçaõ centralizadora  para controlar a integração no controle de alçadas com o modulo AGRO. 
Esta função é chamada no aprovar e possibilita o desarmtransaction dos documentos do tipo A. So é chamado no ultimo nivel da alçada equivale a liberaçãod o pedido
Utilizado no MATA094 - A097ProcLib

@param: cNumDoc	=> SCR->CR_NUM;
@param: cTipDoc => SCR->CR_TIPO
@param: cRecno  => SCR->(RECNO()) - Permite pegar todos os campos da SCR se necessário.
@author: filipe.olegini
@since: 12/04/2018
@Uso: Integação compras
@Retorno: nil .
*/

Function AGRXCOM8(cNumDoc, cTipDoc, cRecno)
	Local aAreaN89    := N89->(GetArea())
    Local aAreaSCR    := SCR->(GetArea())
	Local aAreaN79    := N79->(GetArea())	
    Local lRet		  := .T.	
	Local cStatus	  := ""
	Local cChave      := ""
	Local nSeek	  := 0	
	Local aRecnoSeek  := {}
    
    Private lMsErroAuto := .F.	

    If N89->(ColumnPos("N89_FILIAL")) > 0 .And. SCR->(ColumnPos("CR_FILIAL")) .And. N79->(ColumnPos("N79_FILIAL"))
	
		If FWISINCALLSTACK('MaAlcDoc') 
			cStatus := "R"
		Else
			cStatus := "A"
		EndIf	        
		
		If cTipDoc == "A1" //multas
			dbSelectArea("SCR")
			dbGoto(cRecno)
			
			cChave := xFilial("N79") + SCR->CR_NUM
	
			N79->(DbSetOrder(1))
			If N79->(DbSeek(cChave))		
				If N79->N79_STATUS != '5'
					lRet := .t. //já houve aprovação/rejeição retorna .t.
				Else
					lRet := OGX701AALC( SCR->CR_NUM, SCR->CR_OBS, cStatus, SCR->CR_USER)
				EndIf
			EndIf
	
			
	
		ElseIf cTipDoc == "A2" //comissões
	
			If SCR->CR_STATUS == '06' //se for rejeição		
				cStatus := '1' //Simulado							
			Else				
				cStatus	:= "3"				
			EndIf		
	
			dbSelectArea("N89")
	        dbSetOrder(3)
	        If dbSeek(FWxFilial("N89") + PadR(AllTrim(cNumDoc),TamSx3('N89_CODCOM')[1] ))
				While N89->(!EOF()) .AND. N89->N89_FILIAL == FWxFilial("N89") .AND. ;
						N89->N89_CODCOM == PadR(AllTrim(cNumDoc),TamSx3('N89_CODCOM')[1] )
	
					If cStatus == '1'
						//guardo os Recno para atualizar o N89_CODCOM novo.
						aAdd(aRecnoSeek,{N89->(Recno())})
					EndIf
	
	                If RecLock("N89",.F.)											
	                    N89->N89_STATUS := cStatus
	                    N89->(msUnLock())
	                EndIf
	
	                N89->(dbSkip())
	            EndDo
	        EndIf
	
			//tratamento do N89_CODCOM para estornos
			If cStatus == '1'
	
				//Incremento o numero da comissão para não duplicar na SCR.
				cNovoNumDoc := GetSXENum('N89','N89_CODCOM')
	
				For nSeek := 1 to Len(aRecnoSeek)
					N89->(DbGoTo(aRecnoSeek[nSeek][1]))
	
					If RecLock("N89",.F.)											
	                    N89->N89_CODCOM := cNovoNumDoc
	                    N89->(msUnLock())
	                EndIf	
	
				Next nSeek
			EndIf
			
	    ElseIf cTipDoc == "A3" //NCC 
			
	        //Grava o titulo
	        lRet := A450GERTIT(FwXFilial("NJR"), PadR(AllTrim(cNumDoc),TamSx3('NJR_CODCTR')[1]), cNumDoc, "001", ,'', cStatus)
	
	    ElseIf cTipDoc == "A4" //NDC        
	
	        //Grava o titulo
	        lRet := A450GERNDC(FwXFilial("NJR"), PadR(AllTrim(cNumDoc),TamSx3('NJR_CODCTR')[1]), cNumDoc, "001",'', , ,cStatus)
	    EndIf
	    RestArea(aAreaSCR)
	    RestArea(aAreaN89)
		RestArea(aAreaN79)
	EndIf

Return lRet

/*{Protheus.doc} AGRXCOM9
Funçaõ centralizadora para controlar a integração no controle de alçadas com o modulo AGRO. 
Esta função é chamado na motangem dos campos para incluir campos referente aos documentos do tipo A.
Utilizado no MATA094 - ViewDef

@param: cNumDoc	=> SCR->CR_NUM;
@param: cTipDoc => SCR->CR_TIPO
@param: cRecno  => SCR->(RECNO()) - Permite pegar todos os campos da SCR se necessário.
@author: filipe.olegini
@since: 12/04/2018
@Uso: Integação compras
@Retorno: nil .
*/

Function AGRXCOM9(cNumDoc, cTipDoc, cRecno)
    Local aFields   := {}
    Local cTitulo   := ""
    
    If N79->(ColumnPos("N79_FILIAL")) > 0 .And. N7Q->(ColumnPos("N7Q_FILIAL")) > 0

	    If cTipDoc == "A1" //multas
	        cTitulo   := iif(POSICIONE("N79",1,xFilial("N79")+Substr(cNumDoc,1,TamSX3("N79_CODNGC")[1])+Substr(cNumDoc,7,TamSX3("N79_VERSAO")[1]) ,"N79_OPENGC") == '1', STR0016,"Cliente")
	
		    aAdd(aFields,  {"ENTIDADE"						,;	// [01]  C   Nome do Campo
			    		    "03"							,;	// [02]  C   Ordem
			    			cTitulo							,;	// [03]  C   Titulo do campo//"Descrição"
			    			cTitulo							,;	// [04]  C   Descricao do campo//"Descrição"
			    			NIL								,;	// [05]  A   Array com Help
			    			"C"								,;	// [06]  C   Tipo do campo
			    			""								,;	// [07]  C   Picture
			    			NIL								,;	// [08]  B   Bloco de Picture Var
			    			NIL								,;	// [09]  C   Consulta F3
			    			.F.								,;	// [10]  L   Indica se o campo é alteravel
			    			NIL								,;	// [11]  C   Pasta do campo
			    			NIL								,;	// [12]  C   Agrupamento do campo
			    			NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
			    			NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
			    			NIL								,;	// [15]  C   Inicializador de Browse
			    			.T.								,;	// [16]  L   Indica se o campo é virtual
			    			NIL								,;	// [17]  C   Picture Variavel
			    			NIL								})	// [18]  L   Indica pulo de linha após o campo
																					
		    aAdd(aFields,  {"N79_CODCTR"					,;	// [01]  C   Nome do Campo
			    			"05"							,;	// [02]  C   Ordem
			    			STR0041							,;	// [03]  C   Titulo do campo//"Descrição"       ##Contrato
			    			STR0041							,;	// [04]  C   Descricao do campo//"Descrição"    ##Contrato
			    			NIL								,;	// [05]  A   Array com Help
			    			TamSX3( "N79_CODCTR" )[3]		,;	// [06]  C   Tipo do campo
			    			""								,;	// [07]  C   Picture
			    			NIL								,;	// [08]  B   Bloco de Picture Var
			    			NIL								,;	// [09]  C   Consulta F3
			    			.F.								,;	// [10]  L   Indica se o campo é alteravel
			    			NIL								,;	// [11]  C   Pasta do campo
			    			NIL								,;	// [12]  C   Agrupamento do campo
			    			NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
			    			NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
			    			NIL								,;	// [15]  C   Inicializador de Browse
			    			.T.								,;	// [16]  L   Indica se o campo é virtual
			    			NIL								,;	// [17]  C   Picture Variavel
			    			NIL								})	// [18]  L   Indica pulo de linha após o campo
	
		    aAdd(aFields,  {"N79_OPENGC"					,;	// [01]  C   Nome do Campo
			    			"06"							,;	// [02]  C   Ordem
			    			STR0043						    ,;	// [03]  C   Titulo do campo//"Descrição"       ##Operação
			    			STR0043						    ,;	// [04]  C   Descricao do campo//"Descrição"    ##Operação
			    			NIL								,;	// [05]  A   Array com Help
			    			TamSX3( "N79_OPENGC" )[3]		,;	// [06]  C   Tipo do campo
			    			""								,;	// [07]  C   Picture
			    			NIL								,;	// [08]  B   Bloco de Picture Var
			    			NIL								,;	// [09]  C   Consulta F3
			    			.F.								,;	// [10]  L   Indica se o campo é alteravel
			    			NIL								,;	// [11]  C   Pasta do campo
			    			NIL								,;	// [12]  C   Agrupamento do campo
			    			{STR0046,STR0047}		        ,;	// [13]  A   Lista de valores permitido do campo (Combo)  ##"1=Compras","2=Vendas"
			    			NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
			    			NIL								,;	// [15]  C   Inicializador de Browse
			    			.T.								,;	// [16]  L   Indica se o campo é virtual
			    			NIL								,;	// [17]  C   Picture Variavel
			    			NIL								})	// [18]  L   Indica pulo de linha após o campo
	
		    aAdd(aFields,  {"N79_TPCANC"					,;	// [01]  C   Nome do Campo
			    			"07"							,;	// [02]  C   Ordem
			    			STR0042					        ,;	// [03]  C   Titulo do campo//"Descrição"       ##Tip. Cancel
			    			STR0042					        ,;	// [04]  C   Descricao do campo//"Descrição"    ##Tip. Cancel
			    			NIL								,;	// [05]  A   Array com Help
			    			TamSX3( "N79_TPCANC" )[3]		,;	// [06]  C   Tipo do campo
			    			""								,;	// [07]  C   Picture
			    			NIL								,;	// [08]  B   Bloco de Picture Var
			    			NIL								,;	// [09]  C   Consulta F3
			    			.F.								,;	// [10]  L   Indica se o campo é alteravel
			    			NIL								,;	// [11]  C   Pasta do campo
			    			NIL								,;	// [12]  C   Agrupamento do campo
			    			{STR0044,STR0045}                ,;	// [13]  A   Lista de valores permitido do campo (Combo)
			    			NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
			    			NIL								,;	// [15]  C   Inicializador de Browse
			    			.T.								,;	// [16]  L   Indica se o campo é virtual
			    			NIL								,;	// [17]  C   Picture Variavel
			    			NIL								})	// [18]  L   Indica pulo de linha após o campo
	    
	    ElseIf cTipDoc == "A2" //Comissões
	        //Não tem ação neste Tipo
	
	    ElseIf cTipDoc == "A3" //NCC
	
		    aAdd(aFields,  {"A1_NOME"                    ,;	// [01]  C   Nome do Campo
			    		    "03"							,;	// [02]  C   Ordem
			    			STR0048							,;	// [03]  C   Titulo do campo//"Descrição"
			    			STR0048							,;	// [04]  C   Descricao do campo//"Descrição"
			    			NIL								,;	// [05]  A   Array com Help
			    			"C"								,;	// [06]  C   Tipo do campo
			    			""								,;	// [07]  C   Picture
			    			NIL								,;	// [08]  B   Bloco de Picture Var
			    			NIL								,;	// [09]  C   Consulta F3
			    			.F.								,;	// [10]  L   Indica se o campo é alteravel
			    			NIL								,;	// [11]  C   Pasta do campo
			    			NIL								,;	// [12]  C   Agrupamento do campo
			    			NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
			    			NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
			    			NIL								,;	// [15]  C   Inicializador de Browse
			    			.T.								,;	// [16]  L   Indica se o campo é virtual
			    			NIL								,;	// [17]  C   Picture Variavel
			    			NIL								})	// [18]  L   Indica pulo de linha após o campo
																					
		    aAdd(aFields,  {"NJR_CTREXT"					,;	// [01]  C   Nome do Campo
			    			"05"							,;	// [02]  C   Ordem
			    			STR0041							,;	// [03]  C   Titulo do campo//"Descrição"       ##Contrato
			    			STR0041							,;	// [04]  C   Descricao do campo//"Descrição"    ##Contrato
			    			NIL								,;	// [05]  A   Array com Help
			    			TamSX3( "NJR_CTREXT" )[3]		,;	// [06]  C   Tipo do campo
			    			""								,;	// [07]  C   Picture
			    			NIL								,;	// [08]  B   Bloco de Picture Var
			    			NIL								,;	// [09]  C   Consulta F3
			    			.F.								,;	// [10]  L   Indica se o campo é alteravel
			    			NIL								,;	// [11]  C   Pasta do campo
			    			NIL								,;	// [12]  C   Agrupamento do campo
			    			NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
			    			NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
			    			NIL								,;	// [15]  C   Inicializador de Browse
			    			.T.								,;	// [16]  L   Indica se o campo é virtual
			    			NIL								,;	// [17]  C   Picture Variavel
			    			NIL								})	// [18]  L   Indica pulo de linha após o campo
	    EndIf
    EndIf

Return aFields

/*{Protheus.doc} AGRXCOM10
Funçaõ centralizadora para controlar a integração no controle de alçadas com o modulo AGRO. 
Esta função é chamado na motangem dos campos para incluir as propriedades do campos referente aos documentos do tipo A.
Utilizado no MATA094 - ViewDef

@param: cNumDoc	=> SCR->CR_NUM;
@param: cTipDoc => SCR->CR_TIPO
@param: cRecno  => SCR->(RECNO()) - Permite pegar todos os campos da SCR se necessário.
@author: filipe.olegini
@since: 12/04/2018
@Uso: Integação compras
@Retorno: nil .
*/

Function AGRXCOM10(cNumDoc, cTipDoc, cRecno)
    Local aFields   := {}

    If cTipDoc == "A1" //multas
        aAdd(aFields,{"CR_EMISSAO", MVC_VIEW_ORDEM, "04" })
    EndIf
    
Return aFields

/*{Protheus.doc} AGRXCOM11
Funçaõ centralizadora para controlar a integração no controle de alçadas com o modulo AGRO. 
Esta função é chamado na motangem dos campos para incluir campos referente aos documentos do tipo A.
Utilizado no MATA094 - ViewDef

@param: cNumDoc	=> SCR->CR_NUM;
@param: cTipDoc => SCR->CR_TIPO
@param: cRecno  => SCR->(RECNO()) - Permite pegar todos os campos da SCR se necessário.
@author: filipe.olegini
@since: 12/04/2018
@Uso: Integação compras
@Retorno: nil .
*/

Function AGRXCOM11(cNumDoc, cTipDoc, cRecno)
    Local cAliasN79 := ""
    Local aAreaNJR  := {}
    Local aFields   := {}
    Local cNome     := ""
    
    If N79->(ColumnPos("N79_FILIAL")) > 0

	    If cTipDoc == "A1" //multas
	        cAliasN79 := GetNextAlias()
	
		    BeginSql Alias cAliasN79
		    	SELECT SA1.A1_NOME, SA2.A2_NOME, N79.N79_OPENGC, N79.N79_CODCTR, N79.N79_TPCANC
			      FROM %Table:N79% N79
			     INNER JOIN %Table:NJ0% NJ0 ON NJ0.NJ0_CODENT = N79.N79_CODENT
			  							AND NJ0.NJ0_LOJENT    = N79.N79_LOJENT
			  							AND NJ0.NJ0_FILIAL    = %xfilial:NJ0%
			  							AND NJ0.%notDel%
			      LEFT JOIN %Table:SA1% SA1  ON SA1.A1_COD  = NJ0.NJ0_CODCLI
			  							AND SA1.A1_LOJA     = NJ0.NJ0_LOJCLI
			  							AND SA1.A1_FILIAL   = %xfilial:SA1%
			  							AND SA1.%notDel%
			      LEFT JOIN %Table:SA2% SA2  ON SA2.A2_COD = NJ0.NJ0_CODFOR
			  							AND SA2.A2_LOJA    = NJ0.NJ0_LOJFOR
			  							AND SA2.A2_FILIAL  = %xfilial:SA2%
			  							AND SA2.%notDel%
			     WHERE N79.N79_FILIAL = %xfilial:N79%
			  	   AND N79.N79_CODNGC = %exp:Substr(cNumDoc,1,TamSX3("N79_CODNGC")[1])%
			  	   AND N79.N79_VERSAO = %exp:Substr(cNumDoc,7,TamSX3("N79_VERSAO")[1])%
			  	   AND N79.%notDel%
		    EndSQL 
	
		    DbselectArea( cAliasN79 )
		    DbGoTop()
	        If ( cAliasN79 )->( !Eof() )
	            aAdd(aFields, {"ENTIDADE",iif(( cAliasN79 )->N79_OPENGC == '1',  ( cAliasN79 )->A2_NOME, ( cAliasN79 )->A1_NOME)})
			    aAdd(aFields, {"N79_CODCTR",( cAliasN79 )->N79_CODCTR})
			    aAdd(aFields, {"N79_OPENGC",( cAliasN79 )->N79_OPENGC})
	            aAdd(aFields, {"N79_TPCANC",( cAliasN79 )->N79_TPCANC})
		    EndIf
	
	        (cAliasN79)->(DbCloseArea())
	    
	    ElseIf cTipDoc == "A2" //Comissões
	        //Não tem ação neste tipo
	
	    ElseIf cTipDoc == "A3" //NCC
	
	        aAreaNJR  := NJR->(GetArea())
	
	        DbselectArea("NJR")
		    DbSetOrder(1)
	        If DbSeek(xFilial("NJR") + PadR( cNumDoc, TamSX3( "NJR_CODCTR" )[1] )) //neste ponto o PADR irá retirar o sequencial gerado no documento
	            cNome := Posicione("NJ0",1,FwXFilial("NJ0") + NJR->NJR_CODENT + NJR->NJR_LOJENT,"NJ0_NOME")
	            
	            aAdd(aFields, {"A1_NOME",cNome})
			    aAdd(aFields, {"NJR_CTREXT",NJR->NJR_CTREXT})
		    EndIf
	
	        RestArea(aAreaNJR)
	
	    EndIf
	EndIf

Return aFields

/*{Protheus.doc} AGRXCOM12
Funçaõ centralizadora para controlar a integração no controle de alçadas com o modulo AGRO. 
Esta função é chamado para permitir a visualização aos documentos do tipo A.
Utilizado no MATA094 - ViewDef

@param: lDocsAgro => SAL->AL_AGRCNNG;
@param: cTipDoc   => SCR->CR_TIPO
@param: cGrupoAprov  => SAL->AL_COD 
@author: filipe.olegini
@since: 12/04/2018
@Uso: Integação compras
@Retorno: nil .
*/

Function AGRXCOM12(lDocsAgro, cTipDoc, cGrupoAprov)
    Local lRet  := lDocsAgro

Return lRet

/*/{Protheus.doc} AGRXSTPROP
//Verificação de campos das estruturas da view, antes de setar
uma propriedade, essa validação é necessária pois se o usuário não tem
permissões de visualização de campos(Nivel de Acesso), a view apresenta erro ao setar
um campo inexistente.
@author roney.maia
@since 17/04/2018
@version 1.0
@return ${return}, ${.T. - Válido, .F. - Inválido}
@param oStruct, object, Objeto FwFormViewStruct
@param cField, characters, Nome do Campo
@param nTypeView, numeric, Tipo se Propriedade
@param xValue, generic, Valor
@type function
/*/
Function AGRXSTPROP(oStruct, cField , nTypeView , xValue)
        
    Local lRet      := .F.
    Local l_AGXFUN1 := ExistBlock("AGXFUN1")

    If "*" $ cField // Se for para todos os campos, então não verifica se o campo existe
        oStruct:SetProperty(cField, nTypeView, xValue)
        lRet := .T.
    ElseIf oStruct:HasField(cField) // Verifica se o campo existe
        oStruct:SetProperty(cField, nTypeView, xValue)
        lRet := .T.
    EndIf

    If lRet .AND. l_AGXFUN1
    	ExecBlock("AGXFUN1",.F.,.F.,{oStruct, cField, nTypeView, xValue})
    EndIf

Return lRet


/*/{Protheus.doc} AgrStrToNm
//Converte String de numeros com casas decimais em Tipo Numerico
@author carlos.augusto/brunosilva
@since 25/05/2018
@version 12.1.21
@param cNum, characters, descricao
@type function
/*/
Function AgrStrToNm(cNum)
	Local aNum := StrTokArr2(cNum,".")
	Local nElement := 0
	aNum[1] := Val(aNum[1])
	nNumero := aNum[1]
	If Len(aNum) > 1
		nElement := Len(CValToChar(aNum[2]))
		aNum[2]  := (Val(aNum[2])/(10^nElement))
		nNumero  := aNum[1] + aNum[2]
	Endif


Return nNumero


/*/{Protheus.doc} AGRFILTBAL
//Filtra todas as balancas do usuario
@author carlos.augusto
@since 30/06/2018
@version undefined
@type function
/*/
Function AGRFILTBAL(lPadrao)
	Local aGrpUser	:= {}
	Local nX		:= 0
	Local cFiltro   := ""
	
	aGrpUser := UsrRetGrp(cUserName,RetCodUsr())
	
	If lPadrao
		cFiltro += "@ "
	EndIf
	
	cFiltro += " D_E_L_E_T_=' '
	cFiltro += " AND ((DX6_FILIAL ='"+FwxFilial("DX6")+"'"
	cFiltro += " AND DX6_CODUSU ='"+RetCodUsr()+"')"
	If .Not. Empty(aGrpUser)
		For nX := 1 to Len( aGrpUser )
			If nX == 1
				cFiltro += " OR("
			Else
				cFiltro += " OR "
			EndIf
			cFiltro += " DX6_GRPUSR ='" + aGrpUser[nX] + "'"
			If nX == Len( aGrpUser )
				cFiltro += ")"
			EndIf
		Next nX
	EndIf
	cFiltro += ")"
Return cFiltro


/*/{Protheus.doc} AGRBalsUsr
//Todas as balancas do usuario
@author carlos.augusto
@since 01/07/2018
@version undefined
@type function
/*/
Function AGRBalsUsr()
	Local aBalancas	:= {}
	Local aArea	    := GetArea()
	Local cAliasQry := ""
	Local cQry 		:= ""
	
	cAliasQry := GetNextAlias()

	cQry := " SELECT DX6_CODBAL "
	cQry += 	"FROM " + RetSqlName("DX6") + " DX6 "
	cQry += 	" WHERE "
	cQry += 	AGRFILTBAL(.F.)
	
	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	

	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof()) 
		aAdd( aBalancas,  (cAliasQry)->DX6_CODBAL )								
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
		
Return aBalancas


/*/{Protheus.doc} AGRBALSVLD
//Valida o preenchimento da balanca em AGRA500002
@author carlos.augusto
@since 01/07/2018
@version undefined
@type function
/*/
Function AGRBALSVLD()
	Local lRet 		:= .F.
	Local aBalancas	:= AGRBalsUsr()
	Local nX		:= 0
	Local aValid	:= {}
	Local cDescBal	:= ""

	For nX := 1 to Len( aBalancas )
		If MV_PAR01 == aBalancas[nX]
			lRet := .T.
			exit
		EndIf
	Next nX
	If lRet
		aValid := AGRXFUNBL(MV_PAR01)
		
		lRet	 := aValid[1]
		cDescBal := aValid[2]
		
		If Valtype(MV_PAR02) <> "U"
			MV_PAR02 := cDescBal
		EndIf
	Else
		MsgAlert( STR0050 ) //"Balança inválida para o usuário."
		MV_PAR01 := Space(TamSX3("DX6_CODBAL")[1])
		If Valtype(MV_PAR02) <> "U"
			MV_PAR02 := Space(TamSX3("DX5_DESCRI")[1])
		EndIf
	EndIf
Return lRet
/*/{Protheus.doc} AGRXFNSF
//TODO Controle do Status do Fardo
@author Vanilda.Moggio \ fernanda.Vieira
@since 06/07/2018
@version 1.0
@param nOpcao, numeric, 1 - Retirar, 2- Incluir
@param cProcesso, characters, numero do processo que esta alterando o status do fardo IE / Romaneio
@param aFardos, array, todos os fardos que serao ajustados
@type function
/*/
Function AGRXFNSF(nOpcao, cProcesso, aFardos)
	
	Default aFardos := {} //quando não informado o array de fardos, a DXI deve estar posicionada
	
	If Len(aFardos) = 0
		AGRXFN01(nOpcao, cProcesso)
	Else
		AGRXFN02(nOpcao, cProcesso, aFardos)
	EndIf

return 

/*/{Protheus.doc} AGRXFN02
//TODO Controle do Status do Fardo - percorre array de fardos 
@author Vanilda.Moggio \ fernanda.Vieira
@since 06/07/2018
@version 1.0
@param nOpcao, numeric, 1 - Retirar, 2- Incluir
@param cProcesso, characters, numero do processo que esta alterando o status do fardo IE / Romaneio
@param aFardos, array, todos os fardos que serao ajustados
@type function
/*/
Static Function AGRXFN02 (nOpcao, cProcesso, aFardos)
	Local nI := 0 

	For  nI := 1 to Len( aFardos )
		dbSelectArea( "DXI" ) 
		DXI->(dbSetorder(1)) //DXI_FILIAL+DXI_SAFRA+DXI_ETIQ
		If DXI->(DbSeek(aFardos[nI][1] + aFardos[nI][2] + aFardos[nI][3]))
			AGRXFN01(nOpcao,cProcesso)
		EndIf	   			
	Next nI

Return

/*/{Protheus.doc} AGRXFN01
//TODO Controle do Status do Fardo - realiza o registro do status do fardo
@author Vanilda.Moggio \ fernanda.Vieira
@since 06/07/2018
@version 1.0
@param nOpcao, numeric, 1 - Retirar, 2- Incluir
@param cProcesso, characters, numero do processo que esta alterando o status do fardo IE / Romaneio
@type function
/*/
Static Function AGRXFN01 (nOpcao, cProcesso)
	Local nVar := 0
	Local cStatusAnt := AllTrim(DXI->DXI_STATUS)
	
	If DXI->(ColumnPos("DXI_CODINE")) > 0 
		
		RecLock( "DXI", .F. )
		If nOpcao = 1 /*Incluir*/
			If cProcesso = 'IE'
				//verificar se precisa alterar o status atual ou mantem
				If  AllTrim(DXI->DXI_STATUS) $ "30|60|70|80" .or. Empty(DXI->DXI_STATUS) /* 70-take-up, 80-take-up faturado e 140 - armazenado() ou branco legado (ben - ajustar  status)*/
					//remover status 30 quando BEN e MI implementar status 70|80|140, hoje ao beneficiar esta salvando 30
					DXI->DXI_STATUS := "90" /*Instruido*/
				ElseIf AllTrim(DXI->DXI_STATUS) = "140" /*armazenado*/
					DXI->DXI_STATUS := "120" /*remetido*/
				EndIf 						
			ElseIf cProcesso = 'RomaneioVin'
				DXI->DXI_STATUS := "100" /*Expedição - vincula o fardo no romaneio antes de atualizar ou confirmar*/
			ElseIf cProcesso = 'RomaneioVnd' 
				DXI->DXI_STATUS := "170" /*faturado - qdo confirma e for romaneio de venda */
			ElseIf cProcesso = 'RomanRemTra' 
				DXI->DXI_STATUS := "110" /*Transito- qdo atualiza/confirma e for romaneio de remessa*/     
			ElseIf cProcesso = 'RomaneioFut' 
				//verificar se precisa alterar o status atual ou mantem
				If  AllTrim(DXI->DXI_STATUS) $ "30|70" .or. Empty(DXI->DXI_STATUS) /* 70-take-up ou branco legado (ben - ajustar  status)*/
					//remover status 30 quando BEN e MI implementar status 70, hoje ao beneficiar esta salvando 30
					DXI->DXI_STATUS := "80" /* 80-Take-up faturado - venda global futura */  
				EndIf
			ElseIf cProcesso = 'RomanRemChe' /*romaneio chegado transito*/
				If  AllTrim(DXI->DXI_STATUS) = "110" //Em Transito
					If Empty(DXI->DXI_CODINE) 
						//fardo foi retirado da instrução de embarque 
						DXI->DXI_STATUS := "140" /*Armazenado - Ocorrencia via transportadora / gfe */ 
					Else
						//fardo esta na IE
						DXI->DXI_STATUS := "120" /*Remetido - Ocorrencia via transportadora / gfe*/
					EndIf
				EndIf
			ElseIf cProcesso = 'EstufagIni' /*Aguardando estufagem(iniciado) - foi carregado no cantainer*/ 
				DXI->DXI_STATUS := "130" /*Aguardando estufagem - incluir chegada no romaneio*/     
			ElseIf cProcesso = 'EstufagFin' /*estufagem finalizada*/ 
				DXI->DXI_STATUS := "150" /*estufado*/     
			ElseIf cProcesso = 'EstufagCert' /*estufagem certificada*/ 
				DXI->DXI_STATUS := "160" /*Certificado*/     
			EndIf
		ElseIf nOpcao = 2 /*Retirar*/
			If cProcesso = 'IE' /*instrução de embarque*/
				//verificar se precisa alterar o status atual ou mantem
				If  AllTrim(DXI->DXI_STATUS) = "90" /* 90-instruido */ 
					If FRDGBLFUT( DXI->DXI_FILIAL,DXI->DXI_SAFRA,DXI->DXI_ETIQ )
						//se o fardo tem uma venda global N9A (codrom)
						DXI->DXI_STATUS := "80" /*take-up farurado*/
					Else 
						DXI->DXI_STATUS := "70" /*take-up*/
					EndIf				
				ElseIf AllTrim(DXI->DXI_STATUS) = '120' //remetido
					DXI->DXI_STATUS := "140" /*armazenado */
				EndIf
			ElseIf cProcesso = 'RomaneioFut' /*romaneio venda futura */
				If  AllTrim(DXI->DXI_STATUS) = "80" /* 80-Take-up faturado - venda global futura */  
					DXI->DXI_STATUS := "70" /* Take-up */
				EndIf     
			ElseIf cProcesso = 'RomaneioVin' /*romaneio*/
				If FRDVINCIE(DXI->DXI_FILIAL, DXI->DXI_SAFRA, DXI->DXI_ETIQ) > 0 //tem vinculo em IE
					//nVar busca tipo de vinculo do fardo no container 
					nVar := FRDVINCNT(DXI->DXI_FILIAL, DXI->DXI_SAFRA, DXI->DXI_ETIQ)
					If nVar = 3
						DXI->DXI_STATUS := "160" /* Certificado */
					ElseIf nVar = 2 
						DXI->DXI_STATUS := "150" /* Estufado */
					ElseIf nVar = 1 
						DXI->DXI_STATUS := "130" /* aguardando estufagem */
					ElseIf FRDEMTRANS(DXI->DXI_FILIAL, DXI->DXI_SAFRA, DXI->DXI_ETIQ) = 1 .and. !Empty(DXI->DXI_ROMSAI)
						//se esta em transito a caminho do destino(remessa), e esta em um romaneio de venda(Exportação)
						DXI->DXI_STATUS := "110" /* em transito */
					ElseIf FRDEMTRANS(DXI->DXI_FILIAL, DXI->DXI_SAFRA, DXI->DXI_ETIQ) = 2 .and. !Empty(DXI->DXI_ROMSAI)
						//se chegou ao destino, foi remetido(remessa), e esta em um romaneio de venda(Exportação) 
						DXI->DXI_STATUS := "120" /* remetido */
					ElseIf AGRXTVFBIE(DXI->DXI_CODINE,DXI->DXI_FILIAL,DXI->DXI_BLOCO) != "1"
						DXI->DXI_STATUS := "70" /*take-up*/
					Else
						DXI->DXI_STATUS := "90" /*Instruido*/
					EndIf
				Else
					//global futura não tem vinculo com IE, só após romaneio venda para remessa
					DXI->DXI_STATUS := "70" /*take-up*/
				EndIf
			ElseIf cProcesso = 'RomanRemTra' /*romaneio Remessa em transito */
				DXI->DXI_STATUS := "100" /*Em Expedição*/  
			ElseIf cProcesso = 'RomanCancNF' /*cancelamento NF do romaneio*/
				If DXI->DXI_STATUS = "80" //se for global futura - permanece
					DXI->DXI_STATUS := "80" /*take-up faturado - global futura*/
				ElseIf FRDVINCIE(DXI->DXI_FILIAL, DXI->DXI_SAFRA, DXI->DXI_ETIQ) = 2 //se for venda exportação 
					//nVar busca tipo de vinculo do fardo no container 
					nVar := FRDVINCNT(DXI->DXI_FILIAL, DXI->DXI_SAFRA, DXI->DXI_ETIQ)
					If nVar = 3
						DXI->DXI_STATUS := "160" /* Certificado */
					ElseIf nVar = 2 
						DXI->DXI_STATUS := "150" /* Estufado */
					ElseIf nVar = 1 
						DXI->DXI_STATUS := "130" /* aguardando estufagem */
					ElseIf FRDEMTRANS(DXI->DXI_FILIAL, DXI->DXI_SAFRA, DXI->DXI_ETIQ) = 1 .and. !Empty(DXI->DXI_ROMSAI)
						//se esta em transito a caminho do destino(remessa), e esta em um romaneio de venda(Exportação) 
						DXI->DXI_STATUS := "110" /* em transito */
					ElseIf FRDEMTRANS(DXI->DXI_FILIAL, DXI->DXI_SAFRA, DXI->DXI_ETIQ) = 2 .and. !Empty(DXI->DXI_ROMSAI)
						//se chegou ao destino, foi remetido(remessa), e esta em um romaneio de venda(Exportação)  
						DXI->DXI_STATUS := "120" /* remetido */
					Else
						DXI->DXI_STATUS := "100" /*Em Expedição*/
					EndIF
				Else
					DXI->DXI_STATUS := "100" /*Em Expedição*/
				EndIf
			ElseIf cProcesso = 'EstufagIni'  /*Aguardando estufagem(iniciado) - foi carregado no cantainer*/    
				DXI->DXI_STATUS := "120" /*Remetido */
			ElseIf cProcesso = 'EstufagFin' /*estufagem finalizada*/ 
				DXI->DXI_STATUS := "130" /*Aguardando Estufagem*/     
			ElseIf cProcesso = 'EstufagCert' /*estufagem certificada*/ 
				DXI->DXI_STATUS := "150" /*estufado*/     
			EndIf 
		EndIF
		
		If Alltrim(DXI->DXI_STATUS) $ "90|100" .OR. (cStatusAnt $ "90|100" .AND. cStatusAnt != Alltrim(DXI->DXI_STATUS))
		
			DXI->DXI_DATATU := dDatabase
			DXI->DXI_HORATU := Time()
		
			DbselectArea('DXD')
			DXD->(DbSetOrder(1)) //DXD_FILIAL+DXD_SAFRA+DXD_CODIGO 	
			If DXD->(DbSeek(DXI->DXI_FILIAL+DXI->DXI_SAFRA+DXI->DXI_BLOCO))
				If RecLock("DXD", .F.)
					DXD->DXD_DATATU := dDataBase
					DXD->DXD_HORATU := Time()
					DXD->(MsUnLock())
				EndIf
			EndIf
		endif
		DXI->(MsUnLock())
	EndIf
	
Return

/*/{Protheus.doc} FRDGBLFUT
//TODO Verifica se fardo esta vinculado em um romaneio de venda global futura
@author claudineia.reinert
@since 16/07/2018
@version undefined
@param cFil, characters, filial do fardo
@param cSafra, characters, safra do fardo
@param cEtiq, characters, codigo da etiqueta do fardo
@param cFilRom, characters, Filial do romaneio, opcional, se informado necessario informar tambem o codigo do romaneio para verificar se o romaneio para o fardo é global futura 
@param cCodRom, characters, codigo do romaneio, opcional, se informado necessario informar tambem a filial do romaneio para verificar se o romaneio para o fardo é global futura
@type function
/*/
Function FRDGBLFUT(cFil, cSafra, cEtiq, cFilRom, cCodRom)
	Local lRet := .F.
	Local cQuery 	:= ""
	Local cAliasQry := GetNextAlias()
	
	Default cFilRom := ''
	Default cCodRom := ''
	
	If N9D->(ColumnPos("N9D")) > 0 
	
		cQuery := " SELECT N9D.N9D_FARDO "
		cQuery += " FROM " + RetSqlName('N9D') + " N9D " 
		cQuery += " INNER JOIN " + RetSqlName('N9A') + " N9A ON N9A.D_E_L_E_T_ <> '*' AND N9A.N9A_CODCTR = N9D.N9D_CODCTR " 
	    cQuery += "     AND N9A.N9A_ITEM = N9D.N9D_ITEETG AND N9A.N9A_SEQPRI = N9D.N9D_ITEREF "
		cQuery += "     AND N9A.N9A_OPEFUT='1' AND N9A.N9A_CODROM = N9D.N9D_CODROM "
		cQuery += " WHERE N9D.D_E_L_E_T_ <> '*' AND N9D.N9D_FILIAL = '"+cFil+"' AND N9D.N9D_SAFRA='"+cSafra+"' " 
		cQuery += " AND  N9D_FARDO='"+cEtiq+"' AND N9D_TIPMOV='07' AND N9D_STATUS='2' "
		If !Empty(cFilRom) .AND. !Empty(cCodRom)
			cQuery += " AND  N9D_FILORG='"+cFilRom+"' AND N9D_CODROM = '"+cCodRom+"' "
		EndIf
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
		
		DbSelectArea( cAliasQry )  
		If (cAliasQry)->(!EoF())
			lRet := .T. //fardo esta em contrato de global futura e tem romaneio de global futura
		EndIf
		(cAliasQry)->(dbCloseArea())
		
	EndIf
	
Return lRet 


/*/{Protheus.doc} FRDEMTRANS
//TODO Verifica se fardo esta em transito - não houve registro de chegada do romaneio no destino
@author claudineia.reinert
@since 16/07/2018
@version undefined
@param cFil, characters, filial do fardo
@param cSafra, characters, safra do fardo
@param cEtiq, characters, codigo da etiqueta do fardo
@type function
@return nRet, Numeric, retorna 0=não existe, 1=em transito, 2=remetido
/*/
Static Function FRDEMTRANS(cFil, cSafra, cEtiq)
	Local nRet := 0
	Local cQuery 	:= ""
	Local cAliasQry := GetNextAlias()
	
	If N9D->(ColumnPos("N9D_FILIAL")) > 0
	
		cQuery := " SELECT N9D_PESFIM "
		cQuery += " FROM " + RetSqlName('N9D') + " N9D " 
		cQuery += " INNER JOIN " + RetSqlName('NJJ') + " NJJ ON NJJ.D_E_L_E_T_ <> '*' AND NJJ.NJJ_FILIAL = N9D.N9D_FILORG "
	    cQuery += "     AND NJJ.NJJ_CODROM = N9D.N9D_CODROM AND NJJ_STATUS = '3' "
		cQuery += " WHERE N9D.D_E_L_E_T_ <> '*' AND N9D.N9D_FILIAL = '"+cFil+"' AND N9D.N9D_SAFRA='"+cSafra+"' " 
		cQuery += " AND  N9D_FARDO='"+cEtiq+"' AND N9D_TIPMOV='08' AND N9D_STATUS='2' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
		
		DbSelectArea( cAliasQry )  
		If (cAliasQry)->(!EoF())
			If (cAliasQry)->N9D_PESFIM = 0
				//se não tem registro de chegada 
				nRet := 1 //em transito
			Else
				nRet := 2 //chegada de transito - remetido
			EndIF
		EndIf
		(cAliasQry)->(dbCloseArea())
		
	EndIf

Return nRet 

/*/{Protheus.doc} FRDVINCIE
//TODO Verifica se fardo esta instruido, retornando o tipo da instrução
@author claudineia.reinert
@since 16/07/2018
@version undefined
@param cFil, characters, filial do fardo
@param cSafra, characters, safra do fardo
@param cEtiq, characters, codigo da etiqueta do fardo
@type function
@return nRet, numeric,  retorna um numerico indicando tipo de contrato e mercado, sendo: 1=venda interno, 2=venda externo, 3=armazenagem interno, 4=armazenagem externo
/*/
Function FRDVINCIE(cFil, cSafra, cEtiq)
	Local nRet 		:= 0
	Local cQuery 	:= ""
	Local cAliasQry := GetNextAlias()
	
	If N7Q->(ColumnPos("N7Q_FILIAL")) > 0
	
		cQuery := " SELECT N7Q_CODINE, N7Q_TPMERC, N7Q_TPCTR "
		cQuery += " FROM " + RetSqlName('N9D') + " N9D "
		cQuery += " INNER JOIN " + RetSqlName('N7Q') + " N7Q ON N7Q.D_E_L_E_T_ <> '*' AND N7Q_FILIAL = N9D_FILORG AND N7Q_CODINE = N9D_CODINE " 
		cQuery += " WHERE N9D.D_E_L_E_T_ <> '*' AND N9D.N9D_FILIAL = '"+cFil+"' AND N9D.N9D_SAFRA='"+cSafra+"' " 
		cQuery += " AND  N9D_FARDO='"+cEtiq+"' AND N9D_TIPMOV='04' AND N9D_STATUS='2' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
		
		DbSelectArea( cAliasQry )  
		If (cAliasQry)->(!EoF())
			If (cAliasQry)->N7Q_TPCTR = '1' .AND. (cAliasQry)->N7Q_TPMERC = '1' 
				nRet := 1 //venda mercado interno
			elseIf (cAliasQry)->N7Q_TPCTR = '1' .AND. (cAliasQry)->N7Q_TPMERC = '2' 
				nRet := 2 //venda mercado externo
			elseIf (cAliasQry)->N7Q_TPCTR = '2' .AND. (cAliasQry)->N7Q_TPMERC = '1' 
				nRet := 3 //armazenagem\remessa mercado interno
			elseIf (cAliasQry)->N7Q_TPCTR = '2' .AND. (cAliasQry)->N7Q_TPMERC = '2' 
				nRet := 4 //armazenagem\remessa mercado externo
			EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())
		
	EndIf

Return nRet  

/*/{Protheus.doc} FRDVINCNT
//TODO Retorna o tipo de vinculo do fardo com o container
@author claudineia.reinert
@since 16/07/2018
@version undefined
@param cFil, characters, filial do fardo
@param cSafra, characters, safra do fardo
@param cEtiq, characters, codigo da etiqueta do fardo
@type function
@return nRet, numeric,  retorna 0=nenhum, 1=em estufagem, 2=estufado, 3=certificado
/*/
Function FRDVINCNT(cFil, cSafra, cEtiq)
	Local nRet 		:= 0
	Local cQuery 	:= ""
	Local cAliasQry := GetNextAlias()
	
	If N91->(ColumnPos("N91_FILIAL")) > 0
	
		cQuery := " SELECT N91_CODINE,N91_CONTNR, N91_STATUS "
		cQuery += " FROM " + RetSqlName('N9D') + " N9D "
		cQuery += " INNER JOIN " + RetSqlName('N91') + " N91 ON N91.D_E_L_E_T_ <> '*' AND N91_FILIAL = N9D_FILORG AND N91_CODINE = N9D_CODINE AND N91_CONTNR = N9D_CONTNR " 
		cQuery += " WHERE N9D.D_E_L_E_T_ <> '*' AND N9D.N9D_FILIAL = '"+cFil+"' AND N9D.N9D_SAFRA='"+cSafra+"' " 
		cQuery += " AND  N9D_FARDO='"+cEtiq+"' AND N9D_TIPMOV='05' AND N9D_STATUS='2' AND N9D_TIPOPE='1' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
		
		DbSelectArea( cAliasQry )  
		If (cAliasQry)->(!EoF())
			If (cAliasQry)->N91_STATUS = '2' 
				nRet := 1 //EM ESTUFAGEM
			elseIf (cAliasQry)->N91_STATUS = '3' 
				nRet := 2 //ESTUFADO
			elseIf (cAliasQry)->N91_STATUS != '1'
				nRet := 3 //CERTIFICADO
			EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())
		
	EndIf
Return nRet   

/*/{Protheus.doc} AGRXVALNFE
//TODO Função de integração AGRO e SPEDNFE para validar a transmissão da NF.
@author claudineia.reinert
@since 21/08/2018
@version undefined
@param cSerie, characters, serie da nota fiscal 
@param cNota, characters, codigo da nota fiscal
@param aErro, characters, array de erro para o SPEDNFE, manter padrão SPEDNFE
@type function
/*/
Function AGRXVALNFE(cSerie, cNota, aErro)
	Local lRet := .T.
	Local cQuery := ''
	Local cAliasQry := ''	
	Local cAliasVnd := ''
	Local cMsgErro := ''
	
	If  TableInDic('N8J') //Proteç?o
	
		//VALIDAR SE OS DADOS DE REFERENCIA DA REMESSA DE VENDA A ORDEM FORAM PREENCHIDOS NO AGRO	
		cAliasQry	:= GetNextAlias() 
		cAliasVnd	:= GetNextAlias() 
		cQuery := " SELECT N8J_DOCREF, N8J_SERREF, N8J_DTEREF, NJM_CODROM, NJM_FILIAL, NJM_CODINE, NJM_CODCTR, NJM_ITEM, NJM_SEQPRI " 
		cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
		cQuery += " INNER JOIN " + RetSqlName("N8J") + " N8J ON N8J.D_E_L_E_T_ = '' AND N8J_DOC = F2_DOC AND N8J_SERIE = F2_SERIE " 
		cQuery += " INNER JOIN " + RetSqlName("NJM") + " NJM ON NJM.D_E_L_E_T_ = '' AND NJM_DOCNUM = F2_DOC AND NJM_DOCSER = F2_SERIE AND NJM_SUBTIP = '46' " 
		cQuery += " WHERE F2_FILIAL = '"+ FWxFilial("SF2") +"' AND F2_DOC = '"+ cNota +"' AND F2_SERIE = '"+ cSerie +"' "
		cQuery += " AND SF2.D_E_L_E_T_ <> '*' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  	
		
		DbselectArea( cAliasQry )
		If (cAliasQry)->( !Eof())
			If Empty((cAliasQry)->(N8J_DOCREF)) .OR. Empty((cAliasQry)->(N8J_DTEREF))//OBS: serie(N8J_SERREF) não obrigatória
				lRet := .F. //não transmite a NF
				cMsgErro := STR0052 //##"Faltam dados de referência da venda a ordem(SIGAAGR)! "
				cMsgErro += STR0053 + (cAliasQry)->(NJM_FILIAL) + STR0054 + (cAliasQry)->(NJM_CODROM) //##"Filial: " ##" Romaneio: "
				aAdd( aErro , {} )
				aAdd( aErro[Len(aErro)] , .T. )	    //Tem erro
				aAdd( aErro[Len(aErro)] , cNota ) 	//NF
				aAdd( aErro[Len(aErro)] , cSerie ) 	//Serie
				aAdd( aErro[Len(aErro)] , cMsgErro ) //Motivo
			EndIf		
		EndIf
		(cAliasQry)->(DbCloseArea())
		
	EndIf
		
Return lRet


/*/{Protheus.doc} AGRGMSGERR
//De acordo com o array aErrorMessage, retorna as mensagem de erros do modelo.
@author carlos.augusto
@since 24/09/2018
@version undefined
@param aErros, array, descricao
@type function
/*/
Function AGRGMSGERR(aErros)
	Local cMensagem := ""
	Local nI		:= 0 

	For nI := 1 to Len( aErros )
		If .Not. Empty(aErros[nI])
			cMensagem += cValToChar(aErros[nI]) + "|"
		EndIf
	Next nI

Return cMensagem

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRXDIR
Função responspavel por abrir popup para seleção de diretório.
@author  Rafael Voltz
@since   28/12/2018
@version version
/*/
//-------------------------------------------------------------------
Function AGRXDIR( cCPO )        
	Local cRET        := ""

	cRET := cGetFile( ,STR0056,,,.T., nOR(GETF_MULTISELECT,GETF_NETWORKDRIVE,GETF_LOCALHARD, GETF_RETDIRECTORY)) //"Seleciona diretórios
	
    If !Empty(cRET)
		&(cCPO) := cRET   
	EndIf
    
Return (!Empty(cRET))

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRXARQ
Função responspavel por abrir popup para seleção de arquivo.
@author  Rafael Voltz
@since   28/12/2018
@version version
/*/
//-------------------------------------------------------------------
Function AGRXARQ( cCPO )        
	Local cRET        := ""

	cRET := cGetFile( ,STR0057,,,, nOR(GETF_MULTISELECT,GETF_NETWORKDRIVE,GETF_LOCALHARD)) //"Selecione o arquivo 
	
    If !Empty(cRET)
		&(cCPO) := cRET   
	EndIf
    
Return (!Empty(cRET))

//-------------------------------------------------------------------
/*/{Protheus.doc} AGRTITFIN
Função responsável por validar os títulos no módulo do financeiro.
Função chamada pelo FINA070, FINA330 e FINA460
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Function AGRTITFIN()
	Local aAreaSE1  as array
	Local lRet  	as logical
	
	aAreaSE1 := SE1->(GetArea())
	lRet 	  := fValidTit()

	RestArea(aAreaSE1)

Return lRet

/*/{Protheus.doc} fValidTit
	(long_description)
	@type  Static Function
	@author rafael.voltz
	@since 28/11/2019
	@version 1.0
	/*/
 Static Function fValidTit()
	Local lbaixaAuto	as logical
	
	lbaixaAuto := SuperGetMv('MV_AGRO207', , .F.) // Parametro baixa automática

	If __lnewNeg .and. lbaixaAuto 
		If fTitAgro()
			Agrhelp(STR0001,STR0058, STR0059) //#Operação não permitida. A nova comercialização (MV_AGRO002) e a baixa automática dos títulos (MV_AGRO207) estão habilidadas. #Utilize o painel financeiro do módulo de Gestão de Agronegócio (SIGAAGR).
			Return .F.
		EndIf
	EndIf
 
Return .T.

/*/{Protheus.doc} fTitAgro
	Função para verificar se o registro teve origem no agro. Caso sim, retorna false para bloquear a utilização pelo módulo financeiro
	@type  Static Function
	@author RAFAEL.VOLTZ
	@since 30/01/2020
	@version 1.0	
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fTitAgro()
	Local aAreaN8L := N8L->(GetArea())
	Local lRet     := .F.
	
	N8L->(DBSETORDER( 1 ))
	If N8L->(DBSEEK( xFilial("N8L") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO ))
		lRet := .T.
	EndIf

	RestArea(aAreaN8L)

Return lRet
/*/{Protheus.doc} AGRLGPD
//protege dados sensiveis ao LGPD
@author felipemendes
@since 10/02/2019
@version 1.0
@param cFilLog, characters, Filial.
@type function
/*/
Function AGRLGPD(cCampo)
Local lRet := .F.
Local lLGPD := FindFunction( "FwPDCanUse" ) .And. FwPDCanUse(.T.)

If lLGPD
	lRet := LEN(FwProtectedDataUtil():UsrAccessPDField(RetCodUsr(),{cCampo}) ) == 0 
Endif

Return lRet
