#INCLUDE "AGRXFUN1.CH"
#include "protheus.ch"
#include "fwmvcdef.ch"

//----------------------------------------------------------------------
/** {Protheus.doc} AgrGeraNFS
Desbloqueia Pedido de Venda e gera NF de Saída.

@param.: 	<pcNumPed>		Número do Pedido de Vendas (C5_NUM).
			[pcSerie]		Serie da Nota a ser gerada (caso informado, não abre a tela para selecionar a série).
@return:	Array { cNumNFS, cSerie }	Retorna um array contendo o número e a série da NF de saída gerada.
@author: 	Marlon Richard Trettin
@since.: 	21/10/2014
@Uso...:	SIGAAGR
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

	Local cEOL	    		:= Chr(13)+Chr(10)

// Vars, para Gerar nf, utilizadas na MaPvlNfs
	Local 	dDataMoe  		:= dDataBase
	Private lmudouNum		:= .f.
	Private cNumero			:= Criavar('F2_DOC',.F.)

	Private cOGUBS_NF		:= fAgrtpnf(Nil)			/*Chamado TSJVFB*/

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
	
	Else // Encontra Numero de forma Automatica
		If cTpNrNfs == "3"		//Controle pela SD9
			lMudouNum 		:= .T.    	// Força a Chamar a funcao Ma461NumNF  e nao chamar a NXTSX5NOTA na função MAPVLNFS, ( Razao stavamos com
   								// DEADLOCK frequente  no mv_numiten. mesmo criando o mv_numiten por filial , na Sem. Goias e 
   								// como utilizam a SD9 fizemos essa solução de contorno)
			cNumero		:= CriaVar("F2_DOC", .f.)
		EndIF     C
       	
	EndIf
	
	Pergunte("MT460A",.F.)

//	cNumNFS := MaPvlNfs( aPvlNfs, cSerie , .F.     , .F.     , .F.      , .F.     , .F.    , 0      , 0          , .T.   , .F., ""    ,       )
	cNumNFS := MaPvlNfs(aPvlNfs, cSerie ,MV_PAR01==1,MV_PAR02==1,MV_PAR03==1,MV_PAR04==1,MV_PAR05==1,MV_PAR07,MV_PAR08,MV_PAR15==1,MV_PAR16==2,,,,,,dDataMoe)

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
@return:	Indice Correspondente ao Tipo de Cotação
@author: 	Emerson Coelho
@since: 	24/10/2014
@Uso: 		SIGAAGR
*/
Function AgrGetInd (cIndice , cTpCota , dData )
	Local aSaveArea 	:= GetArea()
	Local aAreaNK1 	:=NK1->(GetArea())
	Local nVr 			:= CriaVar("NK1_VALOR")
	Local cAliasNK1	:= GetNextAlias()
	Local cQuery       :=""

	DO Case
	Case cTpCota == 'D'  	//--<< Diario >>--
		DBSelectArea("NK1")
		NK1->(DBSetOrder(1)) 	//--<< NK1_FILIAL+DTOS(NK1_DATA)+NK1_INDICE >>--
		IF NK1->(DBSeek(xFilial("NK1")+DTOS(dData)+cIndice))
			nVr := NK1->NK1_VALOR
		Else
			nVr := 0
		ENDif
	Case cTpCota == 'A' 	//--<< +Atual >>--
  //--<< Retorna a Qtidade Vendia no mes de Referencia >>--
		cQuery += " SELECT NK1A.NK1_VALOR FROM " + RetSqlName("NK1") + " NK1A "
		cQuery += " WHERE NK1A.NK1_DATA IN "
		cQuery += " ( SELECT MAX(NK1B.NK1_DATA) FROM " +  RetSqlName("NK1") + " NK1B "
		cQuery += " WHERE NK1B.NK1_INDICE = NK1A.NK1_INDICE "
		
		If NJR->(ColumnPos("NJR_DATREF")) > 0		
			cQuery += "   AND NK1B.NK1_DATA <= '" + DTOS(dData) + "'" 
		EndIf
		
		cQuery += "   AND NK1B.NK1_FILIAL = '" + xFilial('NK1') + "'"
		cQuery += "   AND NK1B.D_E_L_E_T_ = ' '"
		cQuery += " )"
		cQuery += "  AND NK1A.NK1_INDICE = '" + cIndice + "'"
		cQuery += "  AND NK1A.D_E_L_E_T_ != '*'"
		cQuery += "  AND NK1A.NK1_FILIAL = '" + xFilial('NK1') + "'"
  	
		cQuery:=ChangeQuery(cQuery)
  	
		DbUseArea(.t.,"TOPCONN", TcGenQry(,,cQuery), cAliasNK1,.f.,.T.)

		(cAliasNK1)->(dbGoTop())
		nVr:=(cAliasNK1)->NK1_VALOR
		(cAliasNK1)->( dbCloseArea() )
	EndCase

	RestArea(aAreaNK1)
	RestArea( aSaveArea )

Return( nVr )
*************


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
			SC9->(dbSkip() )
		
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
	Local nPreco, nTotal
	
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
	Local oModel		:= FwModelActivate()
	Local oView 		:= FwViewActive()
	Local lEmitiuNf		:= .f.,lContinua := .t.,lOutraMoed	 := .f.
	Local aAreaAnt		:= GetArea()
	Local aPvlNfs		:= {},aTexto 	:= {}
	Local cRot      	:= ProcName()
	Local cModAtu   	:= cModulo
	Local nModAtu   	:= nModulo
	Local dDataMoe		:= dDatabase
	Local cFunName		:= FunName()
	Local cSerie		:= CriaVar('F2_SERIE', .F.)
	Local cNota 		:= Criavar('F2_DOC',.F.)
	Local aBloqueio 	:= {{"","","","","","","",""}}
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
