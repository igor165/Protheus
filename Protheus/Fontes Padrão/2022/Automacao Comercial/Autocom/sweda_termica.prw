#INCLUDE "PROTHEUS.CH"
#INCLUDE "SWEDA_TERMICA.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "SHELL.CH"

#DEFINE DEFAULT_ARQMEMSIM  'LMFS.TXT'
#DEFINE DEFAULT_ARQMEMCOM  'LMFC.TXT'
#DEFINE DEFAULT_PATHARQMFD 'ARQ MFD\'         //Pasta onde sera gerado o arquivo de registro TipoE (SE ALTERADO TERA QUE SER ALTERADO LOJXECF)
#DEFINE ARQDOWNTXT  		'DOWNLOAD.TXT'
#DEFINE ARQTIPREGE  		'COTEPE1704.TXT'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ LJSwedaSTบAutor  ณ IP Vendas Clientes บ Data ณ  18/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST para a biblioteca AUTOCOM    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   บฑฑ
ฑฑฬออออออออออุออออออออัออออออัออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Analista ณ Data   ณBOPS  ณDescricao	  	 							  บฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤนฑฑ
ฑฑภออออออออออสออออออออสออออออสออออออออออออออออออออออออออออออออออออออออออออูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
CLASS LJSwedaST
	DATA cBuffer
    DATA Aliquotas
    DATA ICMS     
    DATA ISS      
    DATA FormasPgto
    DATA Pdv       
    DATA NumCaixa    
    DATA lOpened	
    DATA aIndAliq
    DATA lDescAcres	

	METHOD New()

    //Funcoes da Impressora Fiscal
	METHOD IFAbrir		   		(cModelo, cPorta) 
	METHOD IFFechar		   		(cPorta)
	METHOD IFAbrECF		   		()
	METHOD IFFchECF		   		()
	METHOD IFLeituraX			()
	METHOD IFReducaoZ			(cMapaRes)
	METHOD IFStatus		   		(cTipo)	
	METHOD IFLeAliq  	   		()
	METHOD IFLeAliIss	   		() 
	METHOD IFLeConPag	   		() 
	METHOD IFDownloadMFD   		(cTipo, cInicio, cFinal)
	METHOD IFGeraRegTipoE  		(cTipo, cInicio, cFinal, cRazao, cEnd, cNomeFile )
	METHOD IFMemFisc 	   		(cDataInicio, cDataFim, cReducInicio, cReducFim, cTipo)	
	METHOD IFAdicAliq	   		(cAliquota, cTipo)
	METHOD IFAbrCNFis	   		(cCondicao, cValor, cTotalizador, cTexto)
	METHOD IFTxtNFis	   		(cTexto, nVias)
	METHOD IFFchCNFis			()
	METHOD IFAutentic	   		(cVezes, cValor, cTexto)
	METHOD IFSupr		   		(nTipo, cValor, cForma, cTotal, cModo)
	METHOD IFGaveta		   		()	
	METHOD IFHrVerao			(cTipo)
	METHOD IFPrgArred   		() 
	METHOD IFPrgTrunc    		()
	METHOD IFPegSerie	  		()
	METHOD IFPedido		  		(cTEF, cTexto, cValor, cCondPgTEF)
	METHOD IFRecbNFis	  		(cTotalizador, cValor, cForma)
	METHOD IFAbreCup 	   		(cCliente)
	METHOD IFAlimProp	 		()
	METHOD IFRegItem 	  		(cCodigo, cDescricao, cQtde, cVlrUnit, cVlrdesconto, cAliquota, cVlTotIt,cUnidade)
	METHOD IFPagto		  		(cPagto, cVinculado, nVlrTotal, aImpsSL1)
	METHOD IFFechaCup	  		(cMensagem)
	METHOD IFPegCupom	  		(cCancelamento)
	METHOD IFCancItem	  		(cNumItem, cCodigo, cDescricao, cQtde, cVlrunit, cVlrdesconto, cAliquota)
	METHOD IFCancCup	  		(cSupervisor)
	METHOD IFDescTot	 		(cVlrDesconto)
	METHOD IFAcresTot			(cVlrAcrescimo)
	METHOD IFRelGer	  			(cTexto, nVias)
	METHOD IFPegPDV	  			()         
	METHOD TrataRetorno			(nRet)         
	METHOD OpenSweda	   		(cPorta)
	METHOD CloseSweda	   		()        
	
    //Funcoes da Impressora de cheque
	METHOD ChStatus		  		(cTipo)
	METHOD CHImprime	  		(cBanco, cValor, cFavorec, cCidade, cData, cMensagem, cVerso, cExtenso, cChancela )
	METHOD CHAbrir		  		(cModelo, cPorta)
	METHOD CHFechar				(cPorta)
	METHOD CapturaIndAliqtICMS	()	
	METHOD CargaIndiceAliq		()	
	METHOD RetorInfMFD  		(nIndice)   
	METHOD RetMarcMod   		(nIndice)  
	METHOD VerfCRZPend  		()
ENDCLASS

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ New        บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD New() CLASS LJSwedaST    
	::lOpened 	 := .F.
	::lDescAcres := .F.	
	::aIndAliq	 := {}
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFAbrir    บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFAbrir(cModelo, cPorta) CLASS LJSwedaST
Local nRet	:= -1
Local cRet  := ""    

// Verifica o arquivo de configuracao da Sweda
If ArqIniSweda( cPorta, .F. )
	If !::lOpened
 		nRet := Val( ::OpenSweda(cPorta) )
    Else
    	nRet := 0       
    EndIf
    cRet := cValToChar(nRet)	
      
    // Carrega as aliquotas e N. PDV para ganhar performance
    If SubStr(cRet, 1, 1) == "0"
    	Self:IFAlimProp()
    EndIf  
Else
    Alert( STR0001 + cIni ) //"Problemas com o arquivo "
EndIf    

Return(nRet)    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFFechar   บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFFechar(cPorta) CLASS LJSwedaST
Local nRet := -1

nRet := ::CloseSweda()
If nRet == 1 
   	nRet := 0
Else
   	nRet := 1
EndIf
Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFLeituraX บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFLeituraX() CLASS LJSwedaST
Local nRet := -1

nRet := ExecDLL("ECF_LeituraX",{})
::TrataRetorno( nRet )

If nRet == 1 
	nRet := 0
Else
    nRet := 1
EndIf

Return( nRet )    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFAbrECF	  บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFAbrECF() CLASS LJSwedaST

Return(0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFPegCupom บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFPegCupom(cCancelamento) CLASS LJSwedaST
Local nRet 		:= -1
Local cNumCupom	:= Space( 6 )
Local aRetorno 	:= {}

nRet := ExecDLL("ECF_NumeroCupom",{@cNumCupom} )
::TrataRetorno( nRet )    
aRetorno := TrataBuffer()
cNumCupom := aRetorno[1]
oAutocom:cBuffer := cNumCupom

If nRet == 1 
    cRet := "0|" + cNumCupom
    nRet := 0
Else
    cRet := "1"
    nRet := 1
EndIf

Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFFchECF	  บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFFchECF() CLASS LJSwedaST
Local dDataHoje
Local cDataHoje
Local nRet := -1

MsgRun("Aguarde a impressใo da Redu็ใo Z...")
dDataHoje:= dDataBase
cDataHoje := DToS( dDataHoje )     
  
nRet := ExecDLL("ECF_ReducaoZ",{ cDataHoje, Nil} )
::TrataRetorno( nRet )      

If nRet == 1
	nRet := 0
Else
	nRet := 1
EndIf		
 
Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFDescTot  บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFDescTot(cVlrDesconto) CLASS LJSwedaST
Local nRet	:= -1

nRet := ExecDLL("ECF_IniciaFechamentoCupom",{ "D", "$", cVlrDesconto } )
::TrataRetorno( nRet )
If nRet == 1
	::lDescAcres := .T.
    nRet := 0
Else
	nRet := 1
EndIf

Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFAcresTot บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFAcresTot(cVlrAcrescimo) CLASS LJSwedaST
Local nRet := -1

nRet := ExecDLL("ECF_IniciaFechamentoCupom",{"A", "$", cVlrAcrescimo})
::TrataRetorno( nRet )
If nRet >= 0
	::lDescAcres := .T.
    nRet := 0 
Else
	nRet := 1
EndIf

Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFCancItem บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFCancItem(cNumItem, cCodigo, cDescricao, cQtde, cVlrunit, cVlrdesconto, cAliquota) CLASS LJSwedaST
Local nRet := -1

cNumItem := FormataTexto( cNumitem, 3, 0, 2 )
nRet := ExecDLL( "ECF_CancelaItemGenerico",{ cNumItem } )
::TrataRetorno( nRet )

If nRet == 1
	nRet := 0
Else
	nRet := 1
EndIf

Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFCancCup  บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFCancCup (cSupervisor) CLASS LJSwedaST
Local nRet := -1

nRet := ExecDLL( "ECF_CancelaCupomMFD", { "", "", "" } )
::TrataRetorno( nRet )

If nRet == 1
	nRet := 0
Else
	nRet := 1
EndIf

Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFAbrCNFis บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFAbrCNFis (cCondicao, cValor, cTotalizador, cTexto) CLASS LJSwedaST
Local nRet := -1

cValor 		:= StrTran(cValor, '.', '')
cValor 		:= AllTrim(StrTran(cValor, ',', ''))
cCondicao	:= SubStr(AllTrim(cCondicao), 1, 16)

nRet := ExecDLL( "ECF_AbreComprovanteNaoFiscalVinculado", { cCondicao, cValor, ""} )

If nRet <> 0 
	If Status_Impressora( .F. ) == 1
        nRet := 0
    Else
    	//*******************************************************************************
        // Faz um recebimento nใo fiscal para abrir o cupom vinculado
        //*******************************************************************************
        nRet := ExecDLL("ECF_RecebimentoNaoFiscal", { AllTrim(cTotalizador), AllTrim(cValor), AllTrim(cCondicao)} )
        If Status_Impressora( .F. ) == 1
	        //*******************************************************************************
            // Abre o comprovante vinculado
            //*******************************************************************************
            nRet := ExecDLL("ECF_AbreComprovanteNaoFiscalVinculado", { cCondicao, cValor, ""} )
            ::TrataRetorno( nRet )
            
            If Status_Impressora( .F. ) == 1 
	            If nRet == 1 
	                nRet := 0
                Else
					nRet := 1
				EndIf
			Else
				nRet := 1   
			EndIf				
		EndIf    
	EndIf	
Else
    nRet := 1
EndIf

Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFFchCNFis บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFFchCNFis () CLASS LJSwedaST
Local nRet := -1

nRet := ExecDLL("ECF_FechaComprovanteNaoFiscalVinculado", {})
If nRet <> 0
	nRet := Status_Impressora( .T. )
    If nRet == 1
        nRet := 0
	Else
        nRet := 1
	EndIf
Else
    nRet := 1
EndIf

Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFFechaCup บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFFechaCup (cMensagem)CLASS LJSwedaST
Local nRet := -1

nRet := ExecDLL("ECF_TerminaFechamentoCupom", { cMensagem })
::TrataRetorno( nRet )
If nRet == 1
	nRet := Status_Impressora( .T. )
	If nRet == 1 
		nRet := 0
	Else
		nRet := 1
	EndIf
Else
	nRet := 1
EndIf

Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFAutentic บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFAutentic (cVezes, cValor, cTexto) CLASS LJSwedaST
Alert( STR0002 ) //"Fun็ใo nใo disponํvel para este equipamento"
Return( 1 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFRelGer	  บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFRelGer (cTexto,nVias) CLASS LJSwedaST
Local nRet		:= -1
Local nI		:= 0
Local cTextoAux	:= ""
Local nTamTexto	:= 0
Local nCar		:= 0   

cTexto = RemoveAcento(cTexto)
ExecDLL( "ECF_FechaComprovanteNaoFiscalVinculado",{} )

If nVias > 1 
	cTextoAux := cTexto
    nI:=1
    While nI < nVias 
	    cTexto := cTexto + cTextoAux
        nI ++
    End
EndIf

// La็o para imprimir toda a mensagem
While( AllTrim(cTexto) <> "" ) 
	nTamTexto := Len( cTexto )
    While( nTamTexto >= nCar ) .AND. ( cTexto <> "" ) 
	    cTextoAux	:= SubStr( cTexto, 1, 600 )
      	cTexto		:= SubStr( cTexto, 601, Len( cTexto ) )
      	nRet   		:= ExecDLL("ECF_RelatorioGerencial", {cTextoAux} )
     	::TrataRetorno( nRet )
      	nCar += Len( cTextoAux )
    End
    // Ocorreu erro na impressใo do cupom
    If nRet == 0 
    	cRet := 1
      	Exit
    End
End

nRet := ExecDLL("ECF_FechaRelatorioGerencial", {})
::TrataRetorno( nRet )
If nRet == 1
	nRet := 0
Else
	nRet := 1
EndIf	

Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFGaveta	  บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFGaveta () CLASS LJSwedaST
Local nRet := -1

nRet := ExecDLL("ECF_AcionaGaveta", {})
::TrataRetorno( nRet )

If nRet >= 0 
	nRet := 1
Else
	nRet := 0
EndIf

Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFPegSerie บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFPegSerie() CLASS LJSwedaST
Local nRet 		:= -1
Local cNumSerie := Space( 20 )
Local aRetorno := {}
nRet := ExecDLL("ECF_NumeroSerieMFD",{@cNumSerie} )
::TrataRetorno( nRet )
aRetorno := TrataBuffer()
cNumSerie := aRetorno[1]
oAutocom:cBuffer := cNumSerie
If nRet == 1 
    nRet := 0
Else
    nRet := 1
EndIf
Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFPedido	  บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFPedido(cTEF, cTexto, cValor, cCondPgTEF) CLASS LJSwedaST
MsgStop("Recurso de emissใo de pedido nใo disponํvel para Impressora Fiscal Sweda.")
Return (1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFRecbNFis บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFRecbNFis(cTotalizador, cValor, cForma) CLASS LJSwedaST   
Local nRet := -1

nRet := ExecDLL("ECF_RecebimentoNaoFiscal", { cTotalizador, cValor, cForma } )
::TrataRetorno(nRet)

If nRet == 1
	nRet := 0
Else
	nRet := 1
EndIf

Return( nRet )	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFHrVerao  บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFHrVerao( cTipo ) CLASS LJSwedaST
Local nRet := -1 

nRet := ExecDLL("ECF_ProgramaHorarioVerao", {})

If nRet == 1 
	nRet := 0
Else
	nRet := 1
EndIf
	
Return( nRet )            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFPrgArred บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFPrgArred( ) CLASS LJSwedaST
Local nRet := -1 

nRet := ExecDLL("ECF_ProgramaArredondamento", {})

If nRet == 1 
	nRet := 0
Else
	nRet := 1
EndIf
	
Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFPrgTrunc บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFPrgTrunc( ) CLASS LJSwedaST
Local nRet := -1 

nRet := ExecDLL("ECF_ProgramaTruncamento", {})

If nRet == 1 
	nRet := 0
Else
	nRet := 1
EndIf
	
Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFAbreCup  บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFAbreCup (cCliente) CLASS LJSwedaST
Local nRet := -1

::lDescAcres := .F.

If Len( cCliente ) > 29 
	cCliente := SubStr( cCliente, 1, 29 )
EndIf
nRet := ExecDLL("ECF_AbreCupomMFD", {'', cCliente, ''} )
::TrataRetorno( nRet )

If nRet == 1 
   	nRet := 0 
Else
	nRet := 1
EndIf

Return( nRet )	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFRegItem  บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFRegItem (cCodigo, cDescricao, cQtde, cVlrUnit, cVlrdesconto, cAliquota, cVlTotIt , cUnidade ) CLASS LJSwedaST
Local nRet 			:= -1
Local cTrib			:= ""
Local cIndiceISS	:= Space(48)
Local cAliqISS		:= ""
Local cTipoQtd		:= ""
Local nCasas		:= 2
Local aRetorno		:= {}

// Verifica o ponto decimal dos parโmetros
cVlrUnit 	:= StrTran( cVlrUnit, ',', '.' )
cVlrdesconto:= StrTran( cVlrdesconto, ',', '.' )
cQtde 		:= StrTran( cQtde, ',', '.' )

// Verifica se existe a aliquota cadastrada na impressora.
cTrib 		:= SubStr( cAliquota, 1, 1 )
cAliquota	:= SubStr( cAliquota, 2, 5 )
cAliquota	:= StrTran( StrTran( cAliquota, ',', '' ), '.', '' )

If cTrib == "F"
	cAliquota := "FF"
ElseIf cTrib == 'I'
    cAliquota := "II"
ElseIf cTrib == "N"
	cAliquota := "NN"
Endif
If cTrib == "T"
	cAliquota := FormataTexto( SubStr( cAliquota, 1, 4 ), 4, 2, 1, "." )
    If At( cAliquota, ::ICMS ) > 0 
    	cAliquota := ::CapturaIndAliqtICMS()
    Else
		cAliquota := FormataTexto( StrTran( StrTran( cAliquota, ",", "" ), ".", "" ), 4, 0, 2 )
    EndIf
EndIf    
  
If cTrib == "S"
	cAliquota := ""
	cAliqISS := ::IFLeAliIss()
	cAliqISS := SubStr( cAliqISS, 3, Len( cAliqISS ) )
    nRet := ExecDLL("ECF_VerificaIndiceAliquotasIss", {@nIndiceISS} )
    aRetorno := TrataBuffer()
    nIndiceISS := aRetorno[1]
    ::TrataRetorno(nRet)
    If nRet == 1 
	    While( cAliquota == "") .AND. (Len( cIndiceISS ) > 0 )
	        If Val( SubStr( cAliqISS, 1, 5 ) ) == Val( SubStr( cAliquota, 2, Len( cAliquota ) ) )
	            cAliquota := SubStr( cIndiceISS, 1, 2 )
            Else
                cAliqISS := SubStr( cAliqISS, 7, Len( cAliqISS ) )
                If At( ",", sIndiceISS ) > 0 
	                cIndiceISS := SubStr( cIndiceISS, At( ",", cIndiceISS ) + 1, Len( cIndiceISS ) )
                Else
                	cIndiceISS := ""
                EndIf
            EndiF
            
            If cAliquota == ""
				Alert( STR0003 ) //"Alํquota nใo programada"
                nRet := 1
				Exit
            EndIf
        End
  	EndIf
EndIf  	

// Codigo s๓ pode ser at้ 13 posicoes.
cCodigo := SubStr( cCodigo + Space(13), 1, 13 )

cDescricao := AllTrim( cDescricao )
If Len( cDescricao ) < 29
	cDescricao := SubStr( cDescricao + Space(29), 1, 29 )
ElseIf Len( cDescricao ) > 29
	ExecDLL("ECF_AumentaDescricaoItem", {cDescricao} )
    cDescricao := SubStr( cDescricao, 1, 29 )
EndIf

// Tipo da quantidade 'I'-Inteiro  'F'-Fracionario
cTipoQtd := "F"

// Formata a quantidade como XXXXZZZ onde XXXX = parte inteira e ZZZ = parte fracionแria
cQtde := FormataTexto( cQtde, 7, 3, 2 )

// Numero de cadas decimais para o pre็o unitแrio
If At(".", cVlrUnit) > 0
	If Val( SubStr( cVlrUnit, At( ".", cVlrUnit ) + 1, Len( cVlrUnit ) ) ) > 99
		nCasas := 3
    Else
    	nCasas := 2
    EndIf	

	If nRet <> 1 
    	nRet := 1
    EndIf	
    
	// Valor unitแrio deve ter at้ 8 digitos
	cVlrUnit := FormataTexto( cVlrUnit, 9, 3, 2 )
  	// Valor desconto deve ter at้ 8 digitos
  	cVlrDesconto := FormataTexto( cVlrDesconto, 10, 2, 2 )

    nRet := ExecDLL("ECF_VendeItemDepartamento", { cCodigo, cDescricao, cAliquota, cVlrUnit, cQtde, "0", cVlrDesconto, "01", cUnidade} )
  
   	::TrataRetorno( nRet )
  
  	If nRet == 1 
    	nRet := 0
  	Else
    	nRet := 1
    EndIf
EndIf    	

Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFPagto    บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFPagto(cPagto, cVinculado, nVlrTotal,aImpsSL1) CLASS LJSwedaST
Local nRet 		:= -1
Local cFrmPag	:= "" 
Local cVlrPag	:= ""

While Len( cPagto )>0 
	If At( '|', cPagto ) > 17
		cFrmPag := SubStr( cPagto, 1, 16 )
  	Else
		cFrmPag := SubStr( cPagto, 1, At( "|", cPagto ) - 1 )
	EndIf	
    
    cPagto := SubStr( cPagto, At( "|", cPagto ) + 1, Len( cPagto ) )

    If At( "|", cPagto ) > 0 
	    cVlrPag := SubStr( cPagto, 1, At( "|", cPagto ) - 1 )
        cPagto	:= SubStr( cPagto, At( "|", cPagto ) + 1, Len( cPagto ) )
    Else
        cVlrPag := SubStr( cPagto, 1, Len( cPagto ) )
        cPagto := ""
    EndIf

    cVlrPag := AllTrim( FormataTexto( cVlrPag, 12, 2, 3 ) ) 

    nRet := ExecDLL("ECF_EfetuaFormaPagamento", {cFrmPag , cVlrPag})
    
End
   
::TrataRetorno( nRet )
If nRet == 1 
	nRet := 0
Else
	nRet := 1
EndIf
	
Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFLeAliq   บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFLeAliq() CLASS LJSwedaST
oAutocom:cBuffer := ::Aliquotas
Return (0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFLeAliIss บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFLeAliIss() CLASS LJSwedaST
oAutocom:cBuffer := ::ISS
Return (0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFLeConPag บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFLeConPag() CLASS LJSwedaST
oAutocom:cBuffer := ::FormasPgto
Return (0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFPegPDV   บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFPegPDV() CLASS LJSwedaST
Local nRet := ::IFSTATUS( "31" )    
::PDV = oAutocom:cBuffer
Return( nRet )      	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFTxtNFis  บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFTxtNFis(cTexto, nVias) CLASS LJSwedaST
Local nI 		:= 1
Local cTextoAux	:= ""
Local nRet 		:= -1
Local nCar		:= 0
Local nTamTexto	:= 0 
Local aRetorno	:= {}
If nVias > 1
	cTextoaux := cTexto
    While nI < nVias
    	cTexto := cTexto + cTextoAux
        nI++
    End
EndIf

nTamTexto := Len( cTexto )
While (nTamTexto >= nCar) .AND. (cTexto <> '')
	nTam := AT('(SiTef)', cTexto )
    If ( nTam > 0 ) .AND. ( nTam < 600 )
	    cTextoAux := SubStr( cTexto, 1, nTamTexto + 7 )
    	cTexto  := SubStr( cTexto, nTamTexto + 8, Len( cTexto ) )
    Else
	    cTextoAux := SubStr( cTexto, 1, 420 )
		cTexto  := SubStr( cTexto, 421, Len( cTexto ) )
	EndIf
    nRet := ExecDLL("ECF_UsaComprovanteNaoFiscalVinculado",{ cTextoAux } )
    aRetorno := TrataBuffer()
    cTextoAux := aRetorno[1]
    ::TrataRetorno( nRet )
    nCar := nCar + Len( cTextoAux )
End
If nRet == 1
	nRet := 0
Else
	nRet := 1
EndIf

Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFAlimProp บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFAlimProp() CLASS LJSwedaST
Local nRet	:= -1 
Local cRet	:= Space( 79 )
Local cICMS	:= ""
Local cISS	:= ""
Local cAliq	:= ""
Local aRetorno := {}

// Inicaliza็ใo de variaveis
::ICMS			:= ""
::ISS			:= ""
::PDV			:= ""
::ALIQUOTAS 	:= ""

// Retorno de Aliquotas ( ISS )
nRet := ExecDLL("ECF_VerificaAliquotasIss", {@cRet} )
::TrataRetorno( nRet )
aRetorno := TrataBuffer()
cRet := aRetorno[1]
If nRet == 1
	cISS := AllTrim( StrTran( cRet, ",", "|" ) )
EndIf	
While Len( cISS ) > 0
	cAliq := SubStr( cISS,1,2 ) + ',' + SubStr( cISS, 3, 2 )
    ::ISS := ::ISS + FormataTexto( cRet, 5, 2, 1) + "|"
    cISS  := SubStr( cISS, 6, Len( cISS ) )
End

// Retorno de Aliquotas ( ICMS )
cRet := Space(79)
nRet := ExecDLL("ECF_RetornoAliquotas", {@cRet})
::TrataRetorno( nRet )
aRetorno := TrataBuffer()
cRet := aRetorno[1]
If nRet == 1
	cICMS := cRet
	cICMS := AllTrim( StrTran( cRet, ",", "|" ) )
	While Len( cICMS ) > 0 
 		cRet := SubStr( cICMS, 1, 2 ) + "," + SubStr( cICMS, 3, 2 )
	    ::ALIQUOTAS  := ::ALIQUOTAS + FormataTexto( cRet, 5, 2, 1 ) + "|"
    	cICMS := SubStr( cICMS, 6, Len( cICMS ) )
    End
EndIf    

::CargaIndiceAliq()

// Retorno do Numero do Caixa (PDV)
cRet := Space ( 4 )
nRet := ExecDLL("ECF_NumeroCaixa",{ @cRet} )
::TrataRetorno( nRet )
aRetorno := TrataBuffer()
cRet := aRetorno[1]
If nRet == 1
	If At( Chr(0), cRet ) > 0
 		::PDV := SubStr( cRet,1, At( Chr(0), cRet ) - 1 )
    Else
	    ::PDV := SubStr( cRet, 1, 4 )
	EndIf
EndIf	    
Return Nil                                             

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบ Classe   ณ IFReducaoZ บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
METHOD IFReducaoZ (cMapaRes) CLASS LJSwedaST	
Local nRet		:= -1
Local nI		:= 0
Local cData		:= ""
Local cHora		:= ""
Local aRetorno	:= {}
Local cRetorno	:= ""
Local cBase		:= ""
Local cNome		:= ""
Local cImp		:= ""
Local cAux		:= ""
Local cValISS	:= ""
Local cValICMS	:= ""
Local nAliq		:= 0
Local nBase		:= 0
Local nCNom		:= 0
Local nCBas		:= 0
Local cAImp		:= ""
Local nLiq		:= 0
Local nIss		:= 0
Local nAImp		:= 0
Local aRetornoB := {}

If Left( cMapaRes, 1 ) == "S"
	aSize( aRetorno, 21 )

    aRetorno[ 1] := Space(6)                                //**** Data do Movimento ****//
    nRet := ExecDLL( "ECF_DataMovimento", {@aRetorno[1]} )
    aRetornoB := TrataBuffer()
    aRetorno[1] := aRetornoB[1]
    
    aRetorno[ 1] := SubStr( aRetorno[ 1], 1, 2 ) + "/" + SubStr( aRetorno[1], 3, 2 ) + "/" + SubStr( aRetorno[1], 5, 2 )

    aRetorno[ 2] := ::PDV                                   //**** Numero do ECF ****//
                    
	::IFPegSerie()
    aRetorno[ 3] := oAutocom:cBuffer                    	    //**** Serie do ECF ****//
    If SubStr(aRetorno[ 3], 1, 1) == "0"
    	aRetorno[ 3] := AllTrim( SubStr( aRetorno[3], 3, Len( aRetorno[3] ) ) )
    EndIf	
    
    aRetorno[ 4] := Space(4)                               //**** Numero de reducoes ****//
    nRet := ExecDLL("ECF_NumeroReducoes", {@aRetorno[4]})
    aRetornoB := TrataBuffer()
    aRetorno[4] := aRetornoB[1]
    aRetorno[4] := Alltrim(FormataTexto( Str( Val( aRetorno[4] ) + 1 ), 4, 0, 2 ))

    aRetorno[ 5] := Space(18)                              //**** Grande Total Final ****//
    nRet := ExecDLL("ECF_GrandeTotal", {@aRetorno[ 5]} )
    aRetornoB := TrataBuffer()
    aRetorno[ 5] := aRetornoB[1]
    aRetorno[ 5] := StrZero( Val( aRetorno[5] )/100, 19, 2 )

    aRetorno[ 7] := Space(6)                           //**** Numero documento Final ****//
    nRet := ExecDLL("ECF_NumeroCupom", {@aRetorno[ 7]} )
    aRetornoB := TrataBuffer()
    aRetorno[ 7] := aRetornoB[1]
    aRetorno[ 7] := FormataTexto( aRetorno[7], 6, 0, 2 )
    
    aRetorno[ 6] := aRetorno[ 7]
    
    //VALOR DOS CANCELAMENTOS
    cValISS := Space(14)
    cValICMS:= Space(14)
    nRet := ExecDLL("ECF_CancelamentosICMSISS", {@cValICMS,@cValISS} )
    aRetornoB := TrataBuffer()
    
    //**** Valor do Cancelamento de ICMS****//
    aRetorno[8]:= aRetornoB[1]
    aRetorno[8] := StrZero( Val(aRetorno[8])/100, 15, 2 )
    
    //**** Valor do Cancelamento de ISS****//
    aRetorno[20]:= aRetornoB[2]
    aRetorno[20] := StrZero( Val(aRetorno[20])/100, 15, 2 )
    
    //VALOR DOS DESCONTOS
    cValISS := Space(14)
    cValICMS:= Space(14)
    nRet := ExecDLL( "ECF_DescontosICMSISS", {@cValICMS,@cValISS} )
    aRetornoB := TrataBuffer()
    
    //**** Desconto de ICMS****//
    aRetorno[10] := aRetornoB[1]
    aRetorno[10] := StrZero( Val(aRetorno[10])/100, 11, 2 )    
    
    //**** Desconto de ISS****//
    aRetorno[19] := aRetornoB[2]
    aRetorno[19] := StrZero( Val(aRetorno[19])/100, 15, 2 )
    
    //Totalizadores Gerais
    cRetorno := Space(445)
    nRet := ExecDLL( "ECF_VerificaTotalizadoresParciais", {@cRetorno} )
	aRetornoB := TrataBuffer()
    cRetorno := aRetornoB[1]
    cRetorno := SubStr( cRetorno, At( ",", cRetorno ) + 1 , Len( cRetorno ) )    
    
    aRetorno[12] := SubStr( cRetorno, 1, At( ",", cRetorno ) - 1 )           //**** Nao tributado ISENTO      ***//
    aRetorno[12] := StrZero(Val(aRetorno[12])/100, 11, 2 )

    cRetorno := SubStr( cRetorno, At( "," , cRetorno ) + 1, Len( cRetorno ) ) 
    aRetorno[13] := SubStr( cRetorno, 1, At( ",", cRetorno ) - 1 )           //**** Nao tributado Nao Tributado  ****//
    aRetorno[13] := StrZero(Val(aRetorno[13])/100, 11, 2 )

    cRetorno := SubStr( cRetorno, At( ",", cRetorno ) + 1, Len( cRetorno ) )
    aRetorno[11] := SubStr(cRetorno, 1, At( ",", cRetorno ) - 1 )           //**** Nao tributado SUBSTITUIcao TRIB ****//
    aRetorno[11] := StrZero(Val(aRetorno[11])/100, 11, 2 )
                 
	::IFSTATUS( "2" )    
    aRetorno[14] := Substr( oAutocom:cBuffer, 1, 10 )                     //**** Data da Reducao  Z ****//  
    aRetorno[15] := StrZero( Val( aRetorno[7] ) + 1, 6, 0 )

    aRetorno[16] := StrZero(0,16) // FormataTexto( "0",16, 0, 1 )                         // --outros recebimentos--

    aRetorno[21] := "00"                                         // QTD DE Aliquotas

    // Contador de Reinicio de opera็ใo
    aRetorno[18] := Space( 950 )
	::IFSTATUS( "23" )    
    aRetorno[18] := Right(oAutocom:cBuffer,3)

    // Aliquotas T e S
    ///////////// Acha o valor dase de cada alํquota( ICMS e ISS )
    cBase := Space( 400 )
    nRet := ExecDLL("ECF_RetornaRegistradoresFiscais", {@cBase} )
    aRetornoB := TrataBuffer()
    cBase := SubStr( aRetornoB[1], 95, 224 )

    //////////// Acha o nome das aliquotas( ICMS )
    cNome := Space( 300 )
    nRet := ExecDLL("ECF_LerAliquotasComIndice", {@cNome} )
    aRetornoB := TrataBuffer()
    cNome := aRetornoB[1]
    cAux := cNome
    cNome := ""
    nAliq := 0

    /////////// Monta os nomes
    While SubStr( cAux, 1, 1 ) == "T"
    	cNome := cNome + "T" + SubStr( cAux, 3, 2 ) + "." + SubStr( cAux, 5, 2 ) + "|"
      	cAux := SubStr( cAux, 8, Len( cAux ) )
      	nAliq++
    End

    ////////// Monta as Bases
    cAux := cBase
    cBase := ""
    nBase := 1
    While nBase <= nAliq
	    cBase := cBase + SubStr( cAux, 1, 14 ) + "|"
   	   	cAux := SubStr( cAux, 15, Len( cAux ) )
        nBase++
    End

    ///////// Monta os impostos debitados
    nBase := 1
    nCNom := 2
    nCBas := 1
    While nBase <= nAliq 
		nAImp := ( Val( SubStr( cNome, nCNom, 5 ) ) / 100 )  * ( Val( SubStr( cBase, nCBas, 14 ) ) /100 )
      	cAImp := StrZero( nAImp, 14, 2 )
      
      	cImp  := cImp + cAImp + "|"
      
	    nCnom := nCNom + 7
	    nCBas := nCBas + 15
      	nBase++
    End

    nBase := 1
    While nBase <= nAliq
    	aSize( aRetorno, Len( aRetorno ) + 1 )
	                                    // Aliquota                       Base                                                  Valor Debitado
    	aRetorno[ Len( aRetorno ) ] := SubStr( cNome, 1, 6 ) + " " + SubStr( cBase, 2, 11 ) + "." + SubStr( cBase, 13, 2 ) + " " + SubStr( cImp, 2, 13 )
      	cNome := SubStr( cNome, 8, Len( cNome ) )
      	cBase := SubStr( cBase, 16, Len( cBase ) )
      	cImp  := SubStr( cImp, 16, Len( cImp ) )
      	nBase++
    End

    // Total de ISS
    nIss := 0
    While SubStr( cAux, 1, 14 ) <> "00000000000000"
		fIss := Val( SubStr( cAux, 1, 14 ) ) + nIss
		cAux := SubStr( cAux, 15, Len( cAux ) )
    End
    aRetorno[17] := StrZero( nIss/100, 14, 2 )    
    aRetorno[21] := FormataTexto( Str( nAliq ), 2, 0, 2 )

    // Venda Lํquida
    aRetorno[ 9] := Space( 18 )
    ExecDLL("ECF_VendaBruta", {aRetorno[ 9]} )  
    
    aRetornoB := TrataBuffer()
    aRetorno[ 9] := aRetornoB[1]
    aRetorno[ 9] := StrZero(Val(aRetorno[9])/100, Len( aRetorno[ 8]), 2 )
    
    nLiq := Val( aRetorno[ 9] ) - Val( aRetorno[ 8] ) - Val( aRetorno[10]) - Val( aRetorno[17] ) - Val(aRetorno[19]) - Val(aRetorno[20])
    aRetorno[ 9] := StrZero( nLiq, Len( aRetorno[ 8]), 2 )
EndIf
cData := StrZero(Day(dDatabase),2) + StrZero(Month(dDatabase),2) + Str(Year(dDatabase),4)
cHora := Time()

nRet := ExecDLL("ECF_ReducaoZ", { cData, cHora} )
::TrataRetorno( nRet )

oAutocom:cBuffer = ""
If nRet == 1
	If Left( cMapaRes, 1 ) == "S"
  		//*************************************************************************
		// Ajusta o valor que sera devolvido para o Protheus gravar no LOJA160
  		//*************************************************************************
    	cRet := "0|"
       	For nI := 1 To Len( aRetorno )
			cRet += aRetorno[nI] + "|"
   		Next nI  
		oAutocom:cBuffer = Substr(cRet,3)
	Else
		cRet := "0"     
	EndIf	
Else
	cRet := "1" 
EndIf	
Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFStatus   บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFStatus	(cTipo) CLASS LJSwedaST	
Local nRet 			:= -1		// Retorno do ECF (diferente do retorno da funcao)
Local cRet 			:= ""
Local cData			:= Space(6)
Local cHora			:= Space(6)
Local cDataHoje		:= ""
Local dDtHoje
Local dDtMov
Local nI 			:= 1
Local nAck			:= 0
Local nSt1			:= 0
Local nSt2			:= 0
Local cAck			:= ""
Local cSt1			:= ""
Local cSt2			:= ""

Local cVendaBruta	:= ""
Local cGrandeTotal	:= ""
Local cDataMov		:= "" 
Local cCNPJ         := "" 
Local cIE           := "" 
Local cNumRDZ       := "" 
Local cNumCRO       := ""
//Local cTipo         := ""   
Local cSoftBasic    := "" 
Local cPdv          := "" 
Local cGrdTotIni    := ""
//Local nPos          := 0   
//Local lReducao      := .F.
Local cDataCRZ      := ""
Local cRetorno      := "" 
Local cNumCCF       := ""  
Local cOperacoes    := "" 
Local cNumGRG       := "" 
Local cNumCredDeb   := ""   
Local cDtUltDoc     := ""
Local cCodModFis    := ""

Local nPosPipe		:= 0	// Posicao do pipe (|) de concatenacao
Local nRetorno		:= 0	// Retorno da funcao

Local aRetorno		:= {}

//Tipo - Indica qual o status quer se obter da impressora
//  1 - Obtem a Hora da Impressora
//  2 - Obtem a Data da Impressora
//  3 - Verifica o Papel
//  4 - Verifica se ้ possํvel cancelar um ou todos os itens.
//  5 - Cupom Fechado ?
//  6 - Ret. suprimento da impressora
//  7 - ECF permite desconto por item
//  8 - Verifica se o dia anterior foi fechado
//  9 - Verifica o Status do ECF
// 10 - Verifica se todos os itens foram impressos.
// 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
// 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
// 13 - Verifica se o ECF Arredonda o Valor do Item
// 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
// 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
// 16 - Verifica se exige o extenso do cheque
// 17 - Verifica Venda Bruta (RICMS 01 - SC - ANEXO 09)
// 18 - Verifica Grande Total (RICMS 01 - SC - ANEXO 09)
// 19 - Retorna a data do movimento da impressora
// 20 - Retorna o CNPJ cadastrado na impressora
// 21 - Retorna o IE cadastrado na impressora
// 22 - Retorna o CRZ - Contador de Redu็๕es Z
// 23 - Retorna o CRO - Contador de Reinicio de Opera็๕es
// 24 - Retorna a letra indicativa de MF adicional
// 25 - Retorna o Tipo de ECF
// 26 - Retorna a Marca do ECF
// 27 - Retorna o Modelo do ECF
// 28 - Retorna o Versใo atual do Software Bแsico do ECF gravada na MF
// 29 - Retorna a Data de instala็ใo da versใo atual do Software Bแsico gravada na Mem๓ria Fiscal do ECF
// 30 - Retorna o Horแrio de instala็ใo da versใo atual do Software Bแsico gravada na Mem๓ria Fiscal do ECF
// 31 - Retorna o Nบ de ordem seqüencial do ECF no estabelecimento usuแrio
// 32 - Retorna o Grande Total Inicial
// 33 - Retorna o Grande Total Final
// 34 - Retorna a Venda Bruta Diaria
// 35 - Retorna o Contador de Cupom Fiscal CCF
// 36 - Retorna o Contador Geral de Opera็ใo Nใo Fiscal
// 37 - Retorna o Contador Geral de Relat๓rio Gerencial
// 38 - Retorna o Contador de Comprovante de Cr้dito ou D้bito
// 39 - Retorna a Data e Hora do ultimo Documento Armazenado na MFD
// 40 - Retorna o Codigo da Impressora Referente a TABELA NACIONAL DE CำDIGOS DE IDENTIFICAวรO DE ECF
// 41 - Retorna o sequencial do ๚ltimo item vendido
// 42 - Retorna o subtotal do cupom
// 43 - Retorna o patch do arquivo
// 44 - Retorna o patch do arquivo MFD
// 45 - Retorna o C๓digo do ECF
// 46 - Retorna o nome do ECF

//  1 - Obtem a Hora da Impressora
If cTipo == "1"
	nRet := ExecDll("ECF_DataHoraImpressora",{ @cData, @cHora })
    ::TrataRetorno( nRet )
    aRetorno := TrataBuffer()
    cData := aRetorno[1]
    cHora := aRetorno[2]
    cHora := Substr(cHora,1,6)
    cData :=Substr(cData, 1,6)

    If nRet == 1
    	cRet := "0"+"|"+SubStr( cHora, 1, 2 ) + ":" + SubStr( cHora, 3, 2 ) + ":" + SubStr( cHora, 5, 2 )
    Else
    	cRet := "1"
    EndIf

//  2 - Obtem a Data da Impressora
ElseIf cTipo == "2"
	nRet := ExecDll("ECF_DataHoraImpressora",{ @cData, @cHora })
    ::TrataRetorno( nRet )
    aRetorno := TrataBuffer()
    cData := aRetorno[1]
    cHora := aRetorno[2]
    cHora := Substr(cHora,1,6)
    cData :=Substr(cData, 1,6)
    If nRet == 1 
	    cRet := "0"+"|"+SubStr( cData, 1, 2 ) + "/" + SubStr( cData, 3, 2 ) + "/" + SubStr( cData, 5, 2 )
   	Else
      	cRet := "1"
  	EndIf
  	
//  3 - Verifica o Papel
ElseIf cTipo == "3"
	nRet := ExecDll("ECF_VerificaEstadoImpressora",{ @cAck, @cSt1, @cSt2 })

    aRetorno := TrataBuffer()
                            
    nAck := Val(aRetorno[1])
    nSt1 := Val(aRetorno[2])
    nSt2 := Val(aRetorno[3])
    
    If nSt1 >= 128
    	cRet := "3"    // Falta papel.
    ElseIf nSt1 >= 64
      	cRet := "2"    // Pouco papel
    Else
      	cRet := "0"
    EndIf

//  4 - Verifica se ้ possํvel cancelar um ou todos os itens.
ElseIf cTipo == "4"
    cRet := "0|TODOS"

//  5 - Cupom Fechado ?
ElseIf cTipo == "5"
	nRet := ExecDll("ECF_VerificaEstadoImpressora",{ @cAck, @cSt1,@cSt2 })
    
    aRetorno := TrataBuffer()	
	    
    nAck := Val(aRetorno[1])
    nSt1 := Val(aRetorno[2])
    nSt2 := Val(aRetorno[3])
    
    If nSt1 >= 128
    	nSt1 -= 128
    EndIf	
    If nSt1 >= 64
    	nSt1 -= 64
    EndIf
    If nSt1 >= 32
    	nSt1 -= 32
    EndIf	
    If nSt1 >= 16
    	nSt1 -= 16
    EndIf	
    If nSt1 >= 8
    	nSt1 -= 8
    EndIf	
    If nSt1 >= 4
    	nSt1 -= 4
    EndIf	
    If nSt1 >= 2 
    	cRet := "7"    // aberto
    Else
        cRet := "0"  // Fechado
    EndIf    

//  6 - Ret. suprimento da impressora
ElseIf cTipo == "6"
	cRet := Space(3016)
    nRet := ExecDLL("ECF_VerificaFormasPagamento",{ @cRet })
    aRetorno := TrataBuffer()
    cRet := aRetorno[1]
    ::TrataRetorno( nRet )
    If nRet == 1
	    nI := 1 
		While ( nI <= 50 )
            If Upper( AllTrim( SubStr( cRet, 1, 16 ) ) ) == "DINHEIRO"
            	cRet := '0|' + AllTrim( FormataTexto( SubStr( cRet, 17, 18 ) + "," + SubStr( cRet,35,2 ), 12, 2, 3 ) )
            	Exit
            Endif	
           	cRet := SubStr( cRet, 58, Len( cRet ) )
           	nI ++
        End
    Else
       cRet := 1
   	EndIf

//  7 - ECF permite desconto por item
ElseIf cTipo == "7"
    cRet := "11"

//  8 - Verifica se o dia anterior foi fechado
ElseIf cTipo == "8"
    nRet := ExecDLL("ECF_DataMovimento", {@cData} )
    aRetorno := TrataBuffer()
    cData := aRetorno[1]
    
    If cData = "000000"
        cRet := "0"
    Else
        nRet        := ::IFSTATUS("2")
        cDataHoje	:= oAutocom:cBuffer
        dDtHoje  	:= CToD( cDataHoje )
        cData 		:= SubStr( cData,1,2 ) + "/" + SubStr( cData, 3, 2 ) + "/" + SubStr( cData, 5, 2 )
        dDtMov   	:= CToD(cData)
        If( dDtMov < dDtHoje )    // reducao pendente
        	cRet := "10"
        Else
           	cRet := "0"
        EndIf
    EndIf

//  9 - Verifica o Status do ECF
ElseIf cTipo == "9"
    cRet := "0"

// 10 - Verifica se todos os itens foram impressos.
ElseIf cTipo == "10"
    cRet := "0"

// 11 - Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
ElseIf cTipo == "11"
    cRet := "1"

// 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
ElseIf cTipo == "12"
    cRet := "1"

// 13 - Verifica se o ECF Arredonda o Valor do Item
ElseIf cTipo == "13" 
	cRet := "1"
  
// 14 - Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
ElseIf cTipo == "14"
    cRet := "0"

// 15 - Verifica se o ECF permite desconto apos registrar o item (0=Permite)
Elseif cTipo == "15"
	cRet := "1"

// 16 - Verifica se exige o extenso do cheque
Elseif cTipo == "16"
	cRet := "1"

// 17 - Verifica venda bruta
Elseif cTipo == "17"
	cVendaBruta := Space(18)
    nRet := ExecDLL("ECF_VendaBruta", {@cVendaBRuta} )
    ::TrataRetorno( nRet )
    aRetorno := TrataBuffer()
    cVendaBRuta := aRetorno[1]
    If nRet == 1
        cRet := "0|" + cVendaBRuta
    Else
        cRet := "1"
    EndIf
// 18 - Verifica Grande Total
ElseIf cTipo == "18" 
	cGrandeTotal:= Space(18)
    nRet := ExecDLL("ECF_GrandeTotal", {@cGrandeTotal} )
    ::TrataRetorno( nRet )
    aRetorno := TrataBuffer()
    cGrandeTotal := aRetorno[1]
    If nRet == 1
        cRet := "0|" + cGrandeTotal
    Else
        cRet := "1"
  	EndIf

// 19 - Verifica a data de movimento da impressora
ElseIf cTipo == "19"
	cDataMov    := Space(6)
    cDataHoje   := Space(6)
    nRet        := ExecDLL("ECF_DataMovimento", {@cDataMov} )
    aRetorno    := TrataBuffer() 
    cDataMov	:= aRetorno[1]
    ::TrataRetorno( nRet )
    cData        := Space(6)

    If nRet == 1 
		nRet := ::IFSTATUS("2")
		cDataHoje := oAutocom:cBuffer
  		If cDataMov == "000000"
        	cRet := "2|" + cDataHoje
        Else
            cDataMov := SubStr( cDataMov, 1, 2 ) + "/" + SubStr( cDataMov, 3, 2 )+ "/" + SubStr( cDataMov, 5, 2 )
            If CToD( cDataMov ) < CToD( cDataHoje )     // reducao pendente
        	    cRet := "0|" + cDataMov
            Else
                cRet := "2|"+ cDataHoje
            EndIf
        EndIf
    Else
        // Retornou erro na opercao do 19
        cRet := "-1"
    EndIf 

//20 - Retorna o CNPJ cadastrado na impressora
ElseIf cTipo == "20"    
	cCNPJ:= Space(20)
    nRet := ExecDLL("ECF_CNPJMFD", {@cCNPJ} )
    ::TrataRetorno( nRet )
    aRetorno := TrataBuffer()
    cCNPJ := aRetorno[1]
    If nRet == 1  
        cRet := "0|" + cCNPJ
    Else
        cRet := "1"
  	EndIf

// 21 - Retorna o IE cadastrado na impressora
ElseIf cTipo == "21"
	cIE:= Space(20)
    nRet := ExecDLL("ECF_InscricaoEstadualMFD", {@cIE} )
    ::TrataRetorno( nRet )
    aRetorno := TrataBuffer()
    cIE := aRetorno[1]
    If nRet == 1          
        cRet := "0|" + cIE
    Else
        cRet := "1" 
    EndIf

// 22 - Retorna o CRZ - Contador de Redu็๕es Z
ElseIf cTipo == "22"   
	cNumRDZ := Space(4)
    nRet := ExecDLL("ECF_NumeroReducoes", {@cNumRDZ} )
    ::TrataRetorno( nRet )
    aRetorno := TrataBuffer()
    cNumRDZ := aRetorno[1]
    If nRet == 1          
        cRet := "0|" + cNumRDZ
    Else
        cRet := "1" 
    EndIf  

// 23 - Retorna o CRO - Contador de Reinicio de Opera็๕es    
ElseIf cTipo == "23" 
    cNumCRO := Space(4)
    nRet := ExecDLL("ECF_NumeroIntervencoes", {@cNumCRO} )
    ::TrataRetorno( nRet )
    aRetorno := TrataBuffer()
    cNumCRO := aRetorno[1]
    If nRet == 1          
        cRet := "0|" + cNumCRO
    Else
        cRet := "1" 
    EndIf
    
// 24 - Retorna a letra indicativa de MF adicional
ElseIf cTipo == "24"  
    cRet := ::RetorInfMFD(1) 
    
// 25 - Retorna o Tipo de ECF
ElseIf cTipo == "25"
	cTipo  := Space(2)
    nRet := ExecDLL("ECF_RetornaTipoEcf", {@cTipo} )
	::TrataRetorno( nRet )
    aRetorno := TrataBuffer()
    cTipo := aRetorno[1]
    If nRet == 1          
        cRet := "0|" + cTipo
    Else
        cRet := "1" 
    EndIf
    
// 26 - Retorna a Marca do ECF
ElseIf cTipo == "26"
	cRet := ::RetMarcMod (1)

// 27 - Retorna o Modelo do ECF
ElseIf cTipo == "27"
	cRet := ::RetMarcMod (2)  

// 28 - Retorna o Versใo atual do Software Bแsico do ECF gravada na MF
ElseIf cTipo == "28"
	cSoftBasic := Space(6)
	nRet := ExecDLL("ECF_VersaoFirmwareMFD", {@cSoftBasic} )
	::TrataRetorno( nRet )
    aRetorno := TrataBuffer()
    cSoftBasic := aRetorno[1]
    If nRet == 1          
        cRet := "0|" + cSoftBasic
    Else
        cRet := "1" 
    EndIf

// 29 - Retorna a Data de instala็ใo da versใo atual do Software Bแsico gravada na Mem๓ria Fiscal do ECF
ElseIf cTipo == "29"
	cRet := ::RetorInfMFD(2)

// 30 - Retorna o Horแrio de instala็ใo da versใo atual do Software Bแsico gravada na Mem๓ria Fiscal do ECF
ElseIf cTipo == "30"
	cRet := ::RetorInfMFD(3)

// 31 - Retorna o Nบ de ordem seqüencial do ECF no estabelecimento usuแrio
ElseIf cTipo == "31"
 	cPdv := Space(4)
 	nRet := ExecDLL("ECF_NumeroCaixa", {@cPdv} )
	::TrataRetorno( nRet )
    aRetorno := TrataBuffer()
    cPdv := aRetorno[1]
    If nRet == 1          
        cRet := "0|" + SubStr(cPdv, 1,4)
    Else
        cRet := "1" 
    EndIf
 
// 32 - Retorna o Grande Total Inicial
ElseIf cTipo == "32" 
	cGrdTotIni   := Space(18)
	cVendaBruta	 := Space(18)
    cGrandeTotal := Space(18)
    
    nRet := ExecDLL("ECF_GrandeTotal", {@cGrandeTotal} ) 
    ::TrataRetorno( nRet )
    aRetorno := TrataBuffer()
    cGrandeTotal := aRetorno[1]  
    cGrandeTotal := StrTran(cGrandeTotal,",","")
    cGrandeTotal := StrTran(cGrandeTotal,".","")
    If nRet == 1    	
    	nRet := ExecDLL("ECF_VendaBruta", {@cVendaBruta} )
    	::TrataRetorno( nRet )
    	aRetorno := TrataBuffer()
    	cVendaBruta := aRetorno[1]  
	    cVendaBruta := StrTran(cVendaBruta,",","")
	    cVendaBruta := StrTran(cVendaBruta,".","")
        If nRet == 1
        	// Calcula o Grande Total Inicial, (GTFinal - VendaBrutaDia)
      		cGrdTotIni  := AllTrim(Str( Val(cGrandeTotal) - Val(cVendaBruta))) 
            cRet := "0|" + Padl(cGrdTotIni,Len(cGrandeTotal),"0")
        Else 
        	cRet := "1"
        EndIf
    Else    
    	cRet := "1"  
    EndIf 
     
// 33 - Retorna o Grande Total Final  
ElseIf cTipo == "33"
	cDataCRZ     := Space (6)
	cGrandeTotal := Space(18)  
    cRetorno := ::VerfCRZPend()
	If Val(SubStr(cRetorno, 1,1)) ==  0
       If Val(SubStr(cRetorno, 3,1)) ==  0
       		nRet := ExecDLL("ECF_GrandeTotal", {@cGrandeTotal} )
 			::TrataRetorno( nRet )
    		aRetorno     := TrataBuffer()
    		cGrandeTotal := aRetorno[1]      
    		cRet  :=  "0|" + cGrandeTotal
       Else
       		cRet := "1"		
       EndIf
    Else
    	cRet := "1"
    EndIf    
    
// 34 - Retorna a Venda Bruta Diaria
ElseIf cTipo == "34"
	cVendaBruta := Space(18)
	cRetorno := ::VerfCRZPend()
	If Val(SubStr(cRetorno, 1,1)) ==  0
       If Val(SubStr(cRetorno, 3,1)) ==  0
       		nRet := ExecDLL("ECF_VendaBruta", {@cVendaBruta} )
			::TrataRetorno( nRet )
    		aRetorno     := TrataBuffer()
    		cVendaBruta  := aRetorno[1]      
    		cRet  :=  "0|" + cVendaBruta
       Else
       		cRet := "1"
       EndIf
    Else   
       cRet := "1"
    EndIf

// 35 - Retorna o Contador de Cupom Fiscal CCF
ElseIf cTipo == "35"
	cNumCCF := space(18)
    nRet := ExecDLL("ECF_ContadorCupomFiscalMFD", {@cNumCCF} )
    ::TrataRetorno( nRet ) 
    aRetorno     := TrataBuffer()
    cNumCCF 	 := aRetorno[1] 
     If nRet == 1          
        cRet := "0|" + cNumCCF
    Else
        cRet := "1" 
    EndIf                        
    
// 36 - Retorna o Contador Geral de Opera็ใo Nใo Fiscal    
ElseIf cTipo == "36"
	cOperacoes := Space(6)
	nRet := ExecDLL("ECF_NumeroOperacoesNaoFiscais", {@cOperacoes} )
	::TrataRetorno( nRet ) 
    aRetorno     := TrataBuffer()
    cOperacoes 	 := aRetorno[1] 
    If nRet == 1          
        cRet := "0|" + cOperacoes
    Else
        cRet := "1" 
    EndIf   

// 37 - Retorna o Contador Geral de Relat๓rio Gerencial    
ElseIf cTipo == "37"    
	cNumGRG := Space(6)
	nRet := ExecDLL("ECF_ContadorRelatoriosGerenciaisMFD", {@cNumGRG} )
	::TrataRetorno( nRet ) 
    aRetorno     := TrataBuffer()
    cNumGRG 	 := aRetorno[1] 
    If nRet == 1          
        cRet := "0|" + cNumGRG
    Else
        cRet := "1" 
    EndIf 
      
// 38 - Retorna o Contador de Comprovante de Cr้dito ou D้bito
ElseIf cTipo == "38"
	cNumCredDeb := Space(4)
	nRet := ExecDLL("ECF_ContadorComprovantesCreditoMFD", {@cNumCredDeb} )
	::TrataRetorno( nRet )
    aRetorno     := TrataBuffer()
    cNumCredDeb	 := aRetorno[1] 
    If nRet == 1          
        cRet := "0|" + cNumCredDeb
    Else
        cRet := "1" 
    EndIf   

// 39 - Retorna a Data e Hora do ultimo Documento Armazenado na MFD    
ElseIf cTipo == "39"
	cDtUltDoc := Space(12)
	nRet := ExecDLL("ECF_DataHoraUltimoDocumentoMFD", {@cDtUltDoc} )
	::TrataRetorno( nRet )
    aRetorno     := TrataBuffer()
    cNumCredDeb	 := aRetorno[1] 
    If nRet == 1 
        cNumCredDeb := SubStr(cNumCredDeb, 1,8)     
        cRet := "0|" + cNumCredDeb
    Else
        cRet := "1" 
    EndIf   

// 40 - Retorna o Codigo da Impressora Referente a TABELA NACIONAL DE CำDIGOS DE IDENTIFICAวรO DE ECF
ElseIf cTipo == "40"
	cCodModFis := Space(6)
	cCompl := Space(128)
	nRet := ExecDLL("ECF_CodigoModeloFiscal", {@cCodModFis,@cCompl} )
	::TrataRetorno( nRet )
    aRetorno     := TrataBuffer()
    cCodModFis	 := aRetorno[1] 
    If nRet == 1             
        cRet := "0|" + cCodModFis
    Else
        cRet := "1" 
    EndIf                
// 41 - Verifica ultimo item vendido
Elseif cTipo == "41"
	cUltItem := Space(4)
    nRet := ExecDLL("ECF_UltimoItemVendido", {@cUltItem} )
    ::TrataRetorno( nRet )
    aRetorno := TrataBuffer()
    cUltItem := aRetorno[1]
    If nRet == 1
        cRet := "0|" + cUltItem
    Else
        cRet := "1"
    EndIf
// 42 - Verifica venda bruta
Elseif cTipo == "42"
	cSubTotal := Space(14)
    nRet := ExecDLL("ECF_SubTotal", {@cSubTotal} )
    ::TrataRetorno( nRet )
    aRetorno := TrataBuffer()
    cSubTotal := aRetorno[1]
    If nRet == 1
        cRet := "0|" + cSubTotal
    Else
        cRet := "1"
    EndIf
// 43 - Verifica Path
Elseif cTipo == "43"
	cPath := Space(512)
    nRet := ExecDLL("ECF_RetornaPath", {@cPath} )
    ::TrataRetorno( nRet )
    aRetorno := TrataBuffer()
    cPath := aRetorno[1]
    If ! Empty( cPath ) .And. Right( cPath, 1 ) <> Iif( GetRemoteType() <> REMOTE_LINUX, "\", "/" )
       cPath += Iif( GetRemoteType() <> REMOTE_LINUX, "\", "/" )
    Endif
    If nRet == 1
        cRet := "0|" + cPath
    Else
        cRet := "1"
    EndIf
// 44 - Verifica Path MFD
Elseif cTipo == "44"
	cPathMFD := Space(512)
    nRet := ExecDLL("ECF_RetornaPathMFD", {@cPathMFD} )
    ::TrataRetorno( nRet )
    aRetorno := TrataBuffer()
    cPathMFD := aRetorno[1]
    If ! Empty( cPathMFD ) .And. Right( cPathMFD, 1 ) <> Iif( GetRemoteType() <> REMOTE_LINUX, "\", "/" )
       cPathMFD += Iif( GetRemoteType() <> REMOTE_LINUX, "\", "/" )
    Endif
    If nRet == 1
        cRet := "0|" + cPathMFD
    Else
        cRet := "1"
    EndIf 
Elseif cTipo == "45"

        cRet := "0" 

Elseif cTipo == "46"

        cRet := "0"

Else                      
    cRet := "1"
EndIf

nPosPipe := At("|", cRet)
If nPosPipe > 0
	oAutocom:cBuffer := Substr(cRet, nPosPipe + 1) 
	nRetorno := Val(Left(cRet, nPosPipe - 1))
Else
	oAutocom:cBuffer := ""
	nRetorno := Val(cRet)
Endif   

Return(nRetorno)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ RetorInfMFDบAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD RetorInfMFD(nIndice) CLASS LJSwedaST
Local nRet     := 0
Local cRetorno := "" 
Local cAuxDtU  := Space(20) 
Local cAuxDtE  := Space(20)
local cAuxMfA  := Space(5)

 // 1 Retorna Letra indicativa de MF adicional                 
 // 2 Retorna Data de Instala็ใo da Eprom                      
 // 3 Retorna Hora de Instala็ใo da Eprom                      
 // 4 Retorna Data de grava็ใo do ๚ltimo usuแrio da impressora 
 // 5 Retorna Hora de grava็ใo do ๚ltimo usuแrio da impressora 

nRet := ExecDLL("ECF_DataHoraGravacaoUsuarioSWBasicoMFAdicional", {@cAuxDtU,@cAuxDtE,@cAuxMfA} )

::TrataRetorno( nRet )
aRetorno := TrataBuffer()
cAuxDtE := aRetorno[1]
cAuxDtU := aRetorno[2]
cAuxMfA := aRetorno[3]
     
    If nRet == 1          
       If nIndice == 1  
          cRetorno := "0|" + AllTrim(cAuxMfA)   
       ElseIf nIndice == 2  
          cRetorno := "0|" + StrTran( SubStr( cAuxDtE, 1, 10 ), '/', '')  
       ElseIf nIndice == 3   
		  cRetorno := "0|" + StrTran( SubStr( cAuxDtE, 12, 8 ), ':', '')         
	   ElseIf nIndice == 4  
          cRetorno := "0|" + StrTran( SubStr( cAuxDtU, 1, 10 ), '/', '')
       ElseIf nIndice == 5
          cRetorno := "0|" + StrTran( SubStr( cAuxDtU, 12, 8 ), ':', '')
       EndIf   
    Else
        cRetorno := "1" 
    EndIf           	

Return(cRetorno)     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ RetMarcMod บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD RetMarcMod (nIndice) CLASS LJSwedaST
Local cRetorno := ""
Local nRet     := 0  
Local cMarca   := Space(15)
Local cModelo  := Space(20)
Local cTipo    := Space(7)

nRet := ExecDLL("ECF_MarcaModeloTipoImpressoraMFD", {@cMarca,@cModelo,@cTipo} ) 
::TrataRetorno( nRet )
aRetorno := TrataBuffer()
cMarca   := aRetorno[1]
cModelo  := aRetorno[2]
cTipo    := aRetorno[3]
If nRet == 1
	If nIndice == 1  
       cRetorno := "0|" + SubStr(cMarca,1,15)   
    ElseIf nIndice == 2  
       cRetorno := "0|" + SubStr( cModelo, 1, 20 )
    ElseIf nIndice == 3   
       cRetorno := "0|" + SubStr( cTipo, 1, 7 )
    EndIf 
Else 
	cRetorno := "1"       	  
EndIf

Return(cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFMemFisc  บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFMemFisc (cDataInicio, cDataFim, cReducInicio, cReducFim, cTipo) CLASS LJSwedaST	
Local nRet		:= -1
Local cDatai	:= ""
Local cDataf 	:= ""
Local cPathOrig := ""
Local cPathDest := ""
//Local cCopy     := ""

If Left(cTipo,1) == "I" 
	// Se o relat๓rio for por Data
    If AllTrim( cReducInicio ) + AllTrim( cReducFim ) == "" 
	    cDatai := FormataData( CTOD(cDataInicio), 1 )
        cDataf := FormataData( CTOD(cDataFim), 1 )
        nRet := ExecDLL("ECF_LeituraMemoriaFiscalDataMFD", {cDatai, cDataf, Iif(Right(cTipo,1)$"S","S","C")} )
        ::TrataRetorno( nRet )
        If nRet >= 0
        	nRet := 0
        Else
          	nRet := 1
      	EndIf
    Else       // Se o relat๓rio serแ por redu็ใo Z
    	nRet := ExecDLL("ECF_LeituraMemoriaFiscalReducaoMFD", {cReducInicio, cReducFim, Iif(Right(cTipo,1)$"S","S","C")} )
        ::TrataRetorno( nRet )
        If nRet == 1 
          	nRet := 0
        Else
        	nRet := 1
      	EndIf
  	EndIf
Else    
	// Se o relat๓rio for por Data
    If AllTrim( cReducInicio ) + AllTrim( cReducFim ) == ""
	    cDatai := FormataData( CTOD(cDataInicio), 4 )
        cDataf := FormataData( CTOD(cDataFim), 4 )
        nRet := ExecDLL("ECF_LeituraMemoriaFiscalSerialDataMFD", { cDatai, cDataf, Iif(Right(cTipo,1)$"S","S","C") })
        ::TrataRetorno( nRet )
        If nRet == 1 
          	nRet := 0
        Else
          	nRet := 1
        EndIf  	
    Else       // Se o relat๓rio serแ por redu็ใo Z
        nRet := ExecDLL("ECF_LeituraMemoriaFiscalSerialReducaoMFD", {cReducInicio, cReducFim, Iif(Right(cTipo,1)$"S","S","C")} )
        ::TrataRetorno( nRet )
        If nRet == 1 
          	nRet := 0
        Else
          	nRet := 1
	    EndIf
  	EndIf       
  	If nRet = 0
    	LjxGerPath( @cPathDest )   		  	
	  	::IFSTATUS("43")
	  	cPathOrig := oAutocom:cBuffer	  		  	
	  	cPathOrig += "RETORNO.TXT"   	  	
	  	cPathDest += Iif(Right(cTipo,1)$"S",DEFAULT_ARQMEMSIM,DEFAULT_ARQMEMCOM)	  	
	  	fRenameSWE( cPathOrig, lower(cPathDest) )
	 Endif 	
EndIf

Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFSupr     บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFSupr(nTipo, cValor, cForma, cTotal, cModo) CLASS LJSwedaST	
Local nRet 			:= 1
Local nSuprimento	:= 0

// Tipo = 1 - Verifica se tem troco disponivel
// Tipo = 2 - Grava o valor informado no Suprimentos
// Tipo = 3 - Sangra o valor informado

Do Case
	Case nTipo == 1  
	    ::IFSTATUS("6")	    
		//nSuprimento := Val( SubStr( oAutocom:cBuffer, 3 ) )
		nSuprimento := Val( oAutocom:cBuffer )
		If nSuprimento >= Val( cValor )
            nRet := 8
        Else
            nRet := 9
       	EndIf 
       	
    Case nTipo ==2
    	nRet:= ExecDLL("ECF_Suprimento", {cValor, "Dinheiro" } )
		::TrataRetorno( nRet )
        If nRet == 1 
			nRet := 0
   		Else
			nRet := 1
		EndIf     
		
	Case nTipo == 3	
		nRet := ExecDLL("ECF_Sangria", {cValor} )
		::TrataRetorno( nRet )
        If nRet == 1
  			nRet := 0
        Else
			nRet := 1
       	EndIf
EndCase

Return( nRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFAdicAliq บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD IFAdicAliq (cAliquota, cTipo) CLASS LJSwedaST	
Local nRet := -1

// Tipo = 1 - ICMS
// Tipo = 2 - ISS	
If cTipo ==  2
	cTipo := 1
Else	
	cTipo := 0
EndIf
	
cAliquota := FormataTexto( cAliquota, 5, 2, 1 )
cAliquota := StrTran( cAliquota, ".", "" )
nRet := ExecDLL("ECF_ProgramaAliquota", {cAliquota , cTipo} )
::TrataRetorno( nRet )

If nRet == 1 
	nRet := Status_Impressora( .T. )
    If nRet == 1 
    	nRet := 0
    Else
    	nRet := 1
   	EndIf
Else
	nRet := 1
EndIf

Return( nRet )	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ TrataRetornบAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TrataRetorno(nRet) CLASS LJSwedaST
Local cMsg	:= ""

If (nRet < 1) .AND. (nRet > -27) 
	cMsg := MsgErro( nRet )
    Alert( cMsg )
ElseIf nRet == -27
    nRet := Status_Impressora(.F.)
End

Return( Nil )   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ VerfCRZPendบAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD VerfCRZPend() CLASS LJSwedaST
Local nRet     := 0
Local cRet     := Space(2)  
Local aRetorno := {}

nRet := ExecDLL("ECF_VerificaZPendente", {@cRet} )
::TrataRetorno( nRet )
aRetorno := TrataBuffer()
cRet := aRetorno[1]
If nRet == 1          
    cRet := "0|" + cRet
Else
    cRet := "1" 
EndIf  

Return (cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ TrataValor บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*Static Function TrataValor(cValor)
Local nValor := 0
Local n      := 0  
Local nPos   := 0   
Default cValor := ""

If !Empty(AllTrim(cValor) )
	For n:= 1 to Len(Alltrim(cValor))
	    nPos := At(".", cValor )
	    If nPos > 0
			cValor := Stuff(cValor, nPos , 1 ,"")
		EndIf	
    Next n 
    nPos := At(",", cValor ) 
    cValor := Stuff(cValor, nPos , 1 ,".") 
    nValor := Val(cValor)
Else
	nValor := 0 
EndIf

Return(nValor)*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ TrataData  บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*Static Function TrataData(cDtECf) 
Local cData    := ""
Local aConfDt  := Array(3)
Local n        := 0 
Default cDtECf := ""

If !Empty(AllTrim(cDtECf) )
	For n := 1 to 3
	    aConfDt[n] := SubStr(cDtECf , 1, 2)
	    If n < 3
	    	cDtECf     := SubStr(cDtECf , 3, len(cDtECf) ) 
	    EndIf	
    Next n 
    If Val(aConfDt[3]) < 99
    	aConfDt[3] := "20" + aConfDt[3]
    EndIf	
    cData := aConfDt[3] + aConfDt[2] + aConfDt[1]
EndIf
    
Return (cData)*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ TrataBufferบAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TrataBuffer
Local nPos		:= -1
Local aRetorno	:= {}
Local cString	:= ""

cString := AllTrim(oAutocom:cBuffer)

While nPos <> 0
	// O Chr(1) ้ o separador de campos
	nPos := At(Chr(1), cString)
	
	If nPos == 0
		// O Chr(2) ้ o marcador do final do aParams, o resto ้ somente buffer		
		If At(Chr(2), cString) == 1					// Foi enviado o ultimo parametro vazio
			AAdd(aRetorno, "")
		Else
			AAdd( aRetorno, AllTrim( Substr(cString,1,Len(cString) - 2) ) )
		EndIf
	EndIf
	
	If nPos == 1									// Foi enviado um parametro vazio
		AAdd(aRetorno, "")
	Else
		AAdd(aRetorno, AllTrim(Substr(cString,1,nPos-1)))
	EndIf
	
	cString := Substr(cString,nPos+1)
	
End
Return aRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ MsgErro    บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MsgErro(nRet)
Local cMsg	:= ""

Do Case 
	Case nRet == 0
		cMsg := 'Erro de comunica็ใo'
	Case nRet == -1
		cMsg := 'Erro de execu็ใo da fun็ใo'
    Case nRet == -2  
    	cMsg := 'Parโmetro invแlido'
    Case nRet == -3
    	cMsg := 'Alํquota nใo programada'
    Case nRet == -4
    	cMsg := 'Tipo de Parโmetro Invแlido'
    Case nRet == -5
    	cMsg := 'Erro ao abrir a porta de comunica็ใo'
    Case nRet == -6
    	cMsg := 'Impressora desligada ou desconectada'
    Case nRet == -7
    	cMsg := 'Banco nใo localizado no arquivo de configura็ใo BemaFi32.ini'
    Case nRet == -8
    	cMsg := 'Erro ao criar ou gravar no arquivo status.txt ou retorno.txt'
    Case nRet == -9
    	cMsg := 'Erro ao fechar a porta'
    Case nRet == -18
    	cMsg := 'Nใo foi possํvel abrir arquivo INTPOS.001'
    Case nRet == -19
    	cMsg := 'Parโmetro diferentes'
    Case nRet == -20
    	cMsg := 'Transa็ใo cancelada pelo Operador'
    Case nRet == -21
    	cMsg := 'A Transa็ใo nใo foi aprovada'
    Case nRet == -22
    	cMsg := 'Nใo foi possํvel terminar a Impressใo'
    Case nRet == -23
    	cMsg := 'Nใo foi possํvel terminar a Opera็ใo'
EndCase
Return(cMsg)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ Status_ImprบAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Status_Impressora( lMensagem )
Local nACK	:= 0
Local nST1	:= 0
Local nST2	:= 0
Local cACK	:= ""
Local cST1	:= ""
Local cST2	:= ""
Local nRet	:= 0
Local aRetorno := {}
nRet := ExecDLL("ECF_RetornoImpressora", {@cACK, @cST1, @cST2} )
aRetorno := TrataBuffer()

nACK := Val(aRetorno[1])
cST1 := Val(aRetorno[2])
nST2 := Val(aRetorno[3])
                               
If nACK == 6 
	// Verifica ST1
    If nST1 >= 128 
    	nST1 := nST1 - 128
    	nRet := 1 
    	If lMensagem 
    		Alert('Fim de Papel')
    	EndIf
    EndIf
    		
    If nST1 >= 64
    	nST1 := nST1 - 64
    	nRet := 1
    	If lMensagem
    		Alert('Pouco Papel')
    	EndIf
    EndIf		
    
    If nST1 >= 32  
    	nST1 := nST1 - 32
    	nRet := 1
    	If lMensagem
    		Alert('Erro no Rel๓gio')
    	EndIf
    EndIf
    	
    If nST1 >= 16
		nST1 := nST1 - 16
		nRet := 1
		If lMensagem
			Alert('Impressora em Erro')
		EndIf
	EndIf		
    
    If nST1 >= 8
    	nST1 := nST1 - 8
    	nRet := 1
    	If lMensagem
    		Alert('CMD nใo iniciado com ESC')
    	EndIf
    EndIf
    		
    If nST1 >= 4
		nST1 := nST1 - 4
		nRet := 1
		If lMensagem
			Alert('Comando Inexistente')
		EndIf
	EndIf
			
    If nST1 >= 2
    	nST1 := nST1 - 2
    	nRet := 1
    	If lMensagem
    		Alert('Cupom Aberto')
    	EndIf
    EndIf		
    
    If nST1 >= 1
    	nST1 := nST1 - 1
    	nRet := 1
    	If lMensagem
    		Alert('Nบ de Parโmetros Invแlidos')
    	EndIf
    EndIf		

    // Verifica ST2
    If nST2 >= 128
    	nST2 := nST2 - 128
    	nRet := 1
    	If lMensagem
    		Alert('Tipo de Parโmetro Invแlido')
    	EndIf
    EndIf
    		
    If nST2 >= 64
    	nST2 := nST2 - 64
    	nRet := 1
    	If lMensagem
    		Alert('Mem๓ria Fiscal Lotada')
    	EndIf  
    EndIf	
    		
    If nST2 >= 32
    	nST2 := nST2 - 32
		nRet := 1
		If lMensagem
			Alert('CMOS nใo Volแtil')
		EndIf
	EndIf		
    
    If nST2 >= 16
    	nST2 := nST2 - 16
		nRet := 1
		If lMensagem
			Alert('Alํquota Nใo Programada')
		EndIf
	EndIf		
    
    If nST2 >= 8
		nST2 := nST2 - 8
		nRet := 1
		If lMensagem
			Alert('Alํquotas Lotadas')
		Endif
	EndIf
			
    If nST2 >= 4
    	nST2 := nST2 - 4
		nRet := 1
		If lMensagem
			Alert('Cancelamento Nใo Permitido')
		EndIf
	EndIf		

    If nST2 >= 2
    	nST2 := nST2 - 2
    	nRet := 1
    	If lMensagem
    		Alert('CGC/IE Nใo Programados')
    	EndIf
    EndIf		

    If nST2 >= 1
    	nST2 := nST2 - 1
    	nRet := -1
		If lMensagem
			Alert('Comando Nใo Executado')
		EndIf
	EndIf
EndIf			

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ ArqIniSwedaบAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ArqIniSweda( cPorta, lMfd )
Local cPath	:= ""
Local lRet	:= .T.
Local cIni	:= ""       
Local cArqIniSweda	:= "swc.ini"

cPath := GetClientDir()
If SubStr(cPath, Len(cPath), 1 ) == "/"
	cIni := cPath + cArqIniSweda
Else
    cIni := cPath + "/" + cArqIniSweda
End
If GetRemoteType() <> REMOTE_LINUX
	If File(cIni) 
	    If GetPvProfString( "COMUNICAวรO", "PORTA", "", cIni ) <> Upper(cPorta)
	    	WritePProString( "COMUNICAวรO", "PORTA", Upper( SubStr( cPorta, Len( cPorta ), 1 ) ), cIni )
	    Else      
			lRet := .F.
	    End
	Else
	    Alert( 'Arquivo ' + cIni + ' nใo encontrado. ')
	    lRet := .F.
	End
Endif
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ CloseSweda บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method CloseSweda() CLASS LJSwedaST
Local nRet	:= 0

If ::lOpened
	nRet := ExecDll("ECF_FechaPortaSerial", {})
    ::TrataRetorno( nRet )
Else
	::lOpened := .F.
EndIf       

Return(nRet) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ OpenSweda  บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method OpenSweda( cPorta ) CLASS LJSwedaST
Local lRet	:= ""
Local nRet	:= ""
Local cRet	:= ""

cRet := "0"
If !::lOpened
	lRet := .T.
Else
	Alert(STR0004) //'O arquivo LIBCONVECF.SO nใo foi encontrado.'
 	lRet := .F.
EndIf

If lRet
    nRet := ExecDLL("ECF_AbrePortaSerial",{}) //trocada a funcao por que a ECF_AbreConnectC  possui mais opcoes.
	::TrataRetorno( nRet )
		
	If nRet <> 1 
   		Alert(STR0005) //"Erro na abertura da porta"
        cRet := "1"
	Else
	    ::lOpened := .T.
	EndIf
Else
    cRet := "1"
EndIf

Return (cRet) 
    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ CapturaIndAบAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method CapturaIndAliqtICMS() CLASS LJSwedaST
Local nI	:= 1
Local cRet	:= ""

While ( cRet <> "" ) .OR. ( nI > 20 )
	If At( ::ALIQUOTAS, ::aIndAliq[ nI ] ) > 0 
		cRet := ::aIndAliq[ nI ]
	Else
		nI := nI + 2
	EndIf
End	
   
Return( cRet )   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ CargaIndiceบAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method CargaIndiceAliq() CLASS LJSwedaST
Local nI			:= 1
Local nRet			:= -1
Local cIndiceISS	:= Space(48)
Local cICMS			:= ""
Local aRetorno		:= {}

cICMS	:= ::ICMS
nRet	:= ExecDLL("ECF_VerificaIndiceAliquotasIss", {cIndiceISS} )
::TrataRetorno( nRet )
aRetorno := TrataBuffer()
cIndiceISS := aRetorno[1]
If( nRet == 1) .AND. ( SubStr( cIndiceISS, 1, 1)  <> Chr( 0 ) )
	While Len( cICMS ) > 0
    	aSize( ::aIndAliq, Len( ::aIndAliq ) + 1 )
        ::aIndAliq[ Len( ::aIndAliq ) ] := FormataTexto( Str( nI ), 2, 0, 2 )
        If nI <> Val( SubStr( cIndiceISS, 1, 2 ) )
	        ::aIndAliq[ Len( ::aIndAliq ) ] := "T" + SubStr( cICMS, 1, At( "|", cICMS ) - 1 )
        Else
            ::aIndAliq[ Len( ::aIndAliq )  ] := "S" + SubStr( cICMS, 1, AT( "|", cICMS ) - 1 )
            cIndiceISS := SubStr( cIndiceISS, At( ",", cIndiceISS ) + 1, Len( cIndiceISS ) )
        EndIf
        cICMS := SubStr( cICMS, At( "|", cICMS) + 1, Len( cICMS ) )
        nI++
     End
EndIf                                                   

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFDownloadMบAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method IFDownloadMFD( cTipo, cInicio, cFinal ) CLASS LJSwedaST
Local cArquivo  := "DOWNLOAD.MDF" // Arquivo de download da MFD
Local cUsuario := "1"  // Usuario do movimento
Local cDestino  := "DOWNLOAD.TXT" // Arquivo de destino depois de convertido
Local cPathECF := ""
Local cPathDest := ""
Local nRet
//Quando por COO, preenche com zeros a esquerda para evitar erro
If cTipo = '2'
	cInicio := Padl(cInicio,6,"0")
	cFinal  := Padl(cFinal,6,"0")
Endif		

nRet	:= ExecDLL("ECF_DownloadMFD", {cArquivo, cTipo, cInicio, cFinal, cUsuario} )
::TrataRetorno( nRet )

If nRet = 1 
    nRet := ExecDLL("ECF_FormatoDadosMFD", { cArquivo, cDestino, '0', cTipo, cInicio, cFinal, cUsuario } )
	::TrataRetorno( nRet )
Endif

If nRet == 1 
   	LjxGerPath( @cPathDest )   		  	
  	::IFSTATUS("43")
  	cPathECF := oAutocom:cBuffer	  		  	
  	cPathECF += cDestino
  	cPathDest += ARQDOWNTXT
  	fRenameSWE( cPathECF, lower(cPathDest) )
	nRet := 0
Else
	nRet := 1
EndIf

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ IFGeraRegTiบAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method IFGeraRegTipoE( cTipo, cInicio, cFinal, cRazao, cEnd, cNomeFile ) CLASS LJSwedaST
Local cArquivo
Local nRet
Local cPathECF
Local cPathDest := ""
Local cFileDest := ""

::IFSTATUS("43")
cPathECF := oAutocom:cBuffer

LjxGerPath( @cPathDest )   		  	

//Arquivo binแrio necessแrio para Reproduzir a Memoria Fiscal
cArquivo := 'MF.bin'
nRet := ExecDLL("ECF_DownloadMF", {cPathECF+cArquivo} )
::TrataRetorno( nRet )

If nRet = 1
    //quando por COO, deverแ ter 7 digitos
	If cTipo = '2'
		cInicio := Padl(cInicio,7,"0")
		cFinal  := Padl(cFinal,7,"0")
	Endif		
	cFileDest:= cPathDest+DEFAULT_PATHARQMFD+ARQTIPREGE
	If GetRemoteType() = REMOTE_LINUX
	   cFileDest := Lower(StrTran(cFileDest,DEFAULT_PATHARQMFD,"arq_mfd/"))
   	Endif
   	If ValType(cNomeFile) = "C" .And. ! Empty( cNomeFile )
       cFileDest := Lower(cNomeFile)
   	Endif

	nRet	:= ExecDLL("ECF_ReproduzirMemoriaFiscalMFD", {'3',cInicio,cFinal,cFileDest,cPathECF+cArquivo} )
	::TrataRetorno( nRet )
	If nRet == 1 
		nRet := 0
	Else
		nRet := 1
	EndIf
Endif
Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ fRenameSWE บAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fRenameSWE( pcArqOrig, pcArqDest )
Local cMove:= "mv "+pcArqOrig+" "+pcArqDest
If GetRemoteType() = REMOTE_LINUX
	WaitRun(cMove, SW_SHOWNORMAL )
Else 
    MsCopyFile(	pcArqOrig, pcArqDest )
Endif	
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Classe   ณ RemoveAcentบAutor  ณ Vendas Clientes    บ Data ณ  08/09/2011 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Classe da impressora Sweda ST120 para a biblioteca AUTOCOM  	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Todos os produtos de Automacao Comercial - bibl. AUTOCOM   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RemoveAcento(cString)
Local nX        := 0 
Local nY        := 0 
Local cSubStr   := ""
Local cRetorno  := ""

Local cStrEsp	:= "มรยภแเโใำีิ๓๔๕ว็ษส้๊บ"  
Local cStrEqu   := "AAAAaaaaOOOoooCcEEeer" //char equivalente ao char especial

For nX:= 1 To Len(cString)
	cSubStr := SubStr(cString,nX,1)
	nY := At(cSubStr,cStrEsp)
	If nY > 0 
		cSubStr := SubStr(cStrEqu,nY,1)
	EndIf
    
	cRetorno += cSubStr
Next nX

Return cRetorno
