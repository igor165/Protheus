#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA7009.CH"

Function LOJA7009 ; Return  // "dummy" function - Internal Use

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    |LJCFrmCupom      บAutor  ณFabiana Cristina    บ Data ณ  19/11/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณJanela para capturar as informacoes da venda a ser estornada       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCFrmCupom  	
   	Data oDlgVen														//Objeto Dialog da Venda
	Data oFontText                                                      //Objeto Fonte
	Data oBtnConf                                                       //Objeto Button Confirma
	Data oBtnCanc                                                       //Objeto Button Cancela
	Data oEstVenda														//Objeto do tipo Estorno
	Data cCupom															//C๓digo do Cupom   
	Data oCupom															//Objeto para digitar o cupom 
	Data oSerie															//Objeto para digitar a s้rie						     
	Data cSerie														    //Numero da Serie 		   	   			
	Method New()								
	Method Show()														
									
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNew   	       บAutor  ณFabiana Cristina    บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe LJCFrmCupom   			    	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPO1 (1 - oEstVenda) - Objeto do tipo LjClEstVen     			 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New(oEstVenda) Class LJCFrmCupom
   
    Self:oDlgVen 	:= nil														//Objeto Dialog da Venda
	Self:oFontText 	:= nil                                                     //Objeto Fonte
	Self:oBtnConf  	:= nil                                                     //Objeto Button Confirma
	Self:oBtnCanc 	:= nil                                                      //Objeto Button Cancela
	Self:oEstVenda 	:= oEstVenda   											   //Objeto do tipo Lj600ClEst
	Self:cCupom 		:= ""													//C๓digo do Cupom   
	Self:oCupom		:= nil														//Objeto para digitar o cupom 
	Self:oSerie		:= nil														//Objeto para digitar a s้rie						     
	Self:cSerie		:= ""													    //Numero da Serie 

Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณShow  	       บAutor  ณVendas Clientes     บ Data ณ  22/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em exibir a tela.							    	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ																	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณString														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Show() Class LJCFrmCupom
	
Local oObj	 		:= Self						//Objeto criado para ser executado no ON INIT do Dialog. 			
Local cDesCup		:= ""						//Descri็ใo do label cupom ou Nota Fiscal
Local cPicDescCup	:= ""						//Picture da descri็ใo do label de cupom ou Nota Fiscal
Local lEmitNFCe		:= FindFunction("LjEmitNFCe") .AND. LjEmitNFCe()				//Indica a utilizacao da NFC-e
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAbre tela para digitarณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
If SuperGetMv("MV_LJVFNFS", Nil, .F.) .Or. lEmitNFCe	//Verifica se a Nota de Simples Faturamento (Venda Futura) esta habilitada ou NFC-e
	Self:cCupom :=  space(Max(TamSx3("L1_DOCPED")[1],TamSx3("L1_DOCPED")[1]))
	cDesCup		:=	"Cupom / NF" //"Cupom / NF"
Else
	Self:cCupom :=  space(TamSx3("LG_TAMSER")[1])
	cDesCup		:=	STR0003 //"Cupom"
EndIf

cPicDescCup	:= Replic("9", Len(Self:cCupom))

Self:cSerie := space(TamSx3("LG_SERIE")[1])   

Self:cSerie := Self:oEstVenda:cSerie    

DEFINE FONT Self:oFontText NAME "Courier New" SIZE 07,15    

//"Estornar"   
DEFINE MSDIALOG Self:oDlgVen TITLE STR0001 FROM 323,112 TO 440,398 PIXEL STYLE DS_MODALFRAME STATUS
	
	//"Digite os dados da venda"
	@ 005,007 SAY   STR0002              SIZE 100,10 FONT Self:oFontText OF Self:oDlgVen PIXEL 
	//"Cupom"
	@ 020,007 SAY  cDesCup	             SIZE 40,08 FONT Self:oFontText OF Self:oDlgVen PIXEL             
	@ 020,045 MSGET Self:oCupom  VAR Self:cCupom  picture cPicDescCup SIZE 38,08 FONT Self:oFontText OF Self:oDlgVen PIXEL
	//"S้rie"
	@ 020,090 SAY   STR0004              SIZE 18,08 FONT Self:oFontText OF Self:oDlgVen PIXEL             
	@ 020,110 MSGET Self:oSerie  VAR Self:cSerie  picture "@!" SIZE 09,08 FONT Self:oFontText OF Self:oDlgVen PIXEL   
	
	// "C&onfirma"
	@ 040,030 BUTTON Self:oBtnConf PROMPT STR0005 SIZE 40,10 OF Self:oDlgVen PIXEL ACTION (Self:oEstVenda:BuscaOrcamento(Self:cCupom, Self:cSerie) , Self:oDlgVen:End() ) //"&Continuar"
	// "&Cancela"
	@ 040,073 BUTTON Self:oBtnCanc PROMPT STR0006 SIZE 40,10 OF Self:oDlgVen PIXEL ACTION Self:oDlgVen:End()  


ACTIVATE MSDIALOG Self:oDlgVen CENTERED
 
Return Nil
