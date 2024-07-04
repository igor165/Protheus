#INCLUDE "PROTHEUS.CH"        
#INCLUDE "MSOBJECT.CH"

Function LOJA1906E ; Return     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJCCfgTefDirecao    ºAutor  ³VENDAS CRM  º Data ³  29/10/09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Carrega as configuracoes de TEF Direcao disponiveis para aº±± 
±±º          ³aplicacao.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß     
*/
Class LJCCfgTefDirecao

	Data cAppPath		// caminho da aplicacao
	Data cDirTx			// caminhos da envio
	Data cDirRx         // caminho de resposta
	Data lCCCD			// cartao de credito
	Data lCheque 		// chaque 
	Data oConFig        // configurações  
	Data lInfAdm		//
	Data nVias			//Numero de vias
	
	Method New()
	Method Carregar()
	Method Salvar()

EndClass                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³New          ºAutor  ³Vendas CRM       º Data ³  29/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo construtor da classe.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method New() Class LJCCfgTefDirecao
 
	Self:cAppPath 	:= Space(200)
	Self:cDirTx 	:= Space(200)
	Self:cDirRx 	:= Space(200)
	Self:lCCCD		:= .F.
	Self:lCheque	:= .F.   
	Self:lInfAdm	:= .T.

Return Self     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Carregar     ºAutor  ³Vendas CRM       º Data ³  29/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega as configuracoes de TEF disponiveis.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method Carregar(cAlias) Class LJCCfgTefDirecao
	
	Local lRet := .F.
	
	If Select(cAlias) > 0
		Self:cAppPath 	:= (cAlias)->MDG_DIRAPL
		Self:cDirTx 	:= AllTrim((cAlias)->MDG_DIRTX)
		Self:cDirRx 	:= AllTrim((cAlias)->MDG_DIRRX)
		Self:lCCCD		:= IIf((cAlias)->MDG_CARDIR=="1",.T.,.F.)
		Self:lCheque	:= IIf((cAlias)->MDG_CHQDIR=="1",.T.,.F.)
		lRet := .T.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega coleção³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	Self:oConFig := LJCConfiguracoesGer():New()	

	If	Self:lCCCD	.OR. Self:lCheque
		Self:nVias := STFGetStat( "TEFVIAS" )    
		//ÚÄÄÄÄÄ¿
		//³DIRECAO³
		//ÀÄÄÄÄÄÙ
		oConFigGer := LJCConfiguracaoGer():New()
		oConFigGer:cAdmFin		:= 'DIRECAO'
		oConFigGer:cDirTx		:= Self:cDirTx
		oConFigGer:cDirRx      	:= Self:cDirRx
		oConFigGer:cAplicacao  	:= Self:cAppPath
		oConFigGer:lCheque   	:= Self:lCheque
		Self:oConFig:Add(oConFigGer:cAdmFin, oConFigGer)
		
/*		//ÚÄÄÄÄÄ¿
		//³DIRECAO³
		//ÀÄÄÄÄÄÙ
		oConFigGer := LJCConfiguracaoGer():New()
		oConFigGer:cAdmFin		:= 'AMEX'
		oConFigGer:cDirTx		:= Self:cDirTx
		oConFigGer:cDirRx      	:= Self:cDirRx
		oConFigGer:cAplicacao  	:= Self:cAppPath
		oConFigGer:lCheque   	:= Self:lCheque
		Self:oConFig:Add(oConFigGer:cAdmFin, oConFigGer)
		
		//ÚÄÄÄÄÄ¿
		//³DIRECAO³
		//ÀÄÄÄÄÄÙ
		oConFigGer := LJCConfiguracaoGer():New()
		oConFigGer:cAdmFin		:= 'CIELO'
		oConFigGer:cDirTx		:= Self:cDirTx
		oConFigGer:cDirRx      	:= Self:cDirRx
		oConFigGer:cAplicacao  	:= Self:cAppPath
		oConFigGer:lCheque   	:= Self:lCheque
		Self:oConFig:Add(oConFigGer:cAdmFin, oConFigGer)
				
		//ÚÄÄÄÄÄ¿
		//³DIRECAO³
		//ÀÄÄÄÄÄÙ
		oConFigGer := LJCConfiguracaoGer():New()
		oConFigGer:cAdmFin		:= 'VISANET'
		oConFigGer:cDirTx		:= Self:cDirTx
		oConFigGer:cDirRx      	:= Self:cDirRx
		oConFigGer:cAplicacao  	:= Self:cAppPath
		oConFigGer:lCheque   	:= Self:lCheque
		Self:oConFig:Add(oConFigGer:cAdmFin, oConFigGer)		*/

    EndIf

Return lRet   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Salvar       ºAutor  ³Vendas CRM       º Data ³  29/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Salva as configuracoes de TEF disponiveis.                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method Salvar(cAlias) Class LJCCfgTefDirecao

	Local lRet := .F.
		
	If Select(cAlias) > 0
		REPLACE  (cAlias)->MDG_DIRAPL	WITH Self:cAppPath 	
		REPLACE  (cAlias)->MDG_DIRTX	WITH Self:cDirTx 	
		REPLACE  (cAlias)->MDG_DIRRX	WITH Self:cDirRx 	
		REPLACE  (cAlias)->MDG_CARDIR	WITH IIf(Self:lCCCD,"1","2")		
		REPLACE  (cAlias)->MDG_CHQDIR	WITH IIf(Self:lCheque,"1","2")
		lRet := .T.
	EndIf

Return lRet