#INCLUDE "PROTHEUS.CH"   
#INCLUDE "CRDA260.CH"  
#INCLUDE "FONT.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCRDA260   บAutor  ณHanna C. Inglez     บ Data ณ  14/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega tela com o a pontuacao total do cliente             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CRDA260                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Crda260()
Local nTamCli	:= TamSX3("A1_COD")[1]     			// Codigo do cliente
Local nTamLoja	:= TamSX3("A1_LOJA")[1]				// Loja
Local cNomeCli	:= ""   			// Nome do cliente
Local nPontos	:= 0				// Nro de pontos

Local oDlg							// Tela de Resgate 
Local oBold							// Objeto para deixar a fonte em negrito
Local oBold1						// Objeto para deixar a fonte em negrito
   
Pergunte("CRD260",.T.)
    
cCliente := PadR(Alltrim(mv_par01),nTamCli)
cLoja	 := PadR(Alltrim(mv_par02),nTamLoja)

If cCliente <> "" .AND. cLoja <> ""
	
	dbSelectArea("SA1")
	dbSetOrder(1)
   		
	If MsSeek(xFilial("SA1")+cCliente+cLoja )
  		cNomeCli := A1_NOME		
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณBusca os pontos acumulados do cliente referente a campanha      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("MAX")
	dbSetOrder(1)
	If MsSeek( xFilial("MAX")+cCliente+cLoja ) 
		    			
		Do While MAX->( !Eof() ) .AND. MAX->MAX_FILIAL == xFilial("MAX");
								  .AND. MAX->MAX_CODCLI == cCLiente;
								  .AND. MAX->MAX_LOJA   == cLoja
  
			nPontos	:= nPontos + MAX->MAX_SALDO
			MAX->( dbSkip() )
		End  

	EndIf

	DEFINE FONT oBold    NAME "Arial" SIZE 0, -30 BOLD
	DEFINE FONT oBold1   NAME "Arial" SIZE 0, -14 BOLD
	DEFINE MSDIALOG oDlg FROM  0,0 TO 170,350 TITLE STR0001 PIXEL STYLE DS_MODALFRAME 			// Resgate de Pontos
		
		@ 010,010 SAY STR0002	OF oDlg PIXEL FONT oBold1										// "Codigo : "
		@ 010,040 SAY cCliente	OF oDlg PIXEL FONT oBold1
				                                                                                        
		@ 010,080 SAY STR0003	OF oDlg PIXEL FONT oBold1										// "Loja : "
		@ 010,100 SAY cLoja		OF oDlg PIXEL FONT oBold1
		
		@ 025,010 SAY cNomeCli	OF oDlg PIXEL FONT oBold1 COLOR CLR_BLUE
			
	    If nPontos > 0		
			@ 045,15 SAY STR0004 + Alltrim( ( STR( nPontos ) ) )	OF oDlg PIXEL FONT oBold	//"Total de Pontos: "
		Else
			@ 045,15 SAY STR0005	OF oDlg PIXEL FONT oBold	//"Nใo possui pontos."			
		EndIf
		
		DEFINE SBUTTON FROM 70,080 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
		oDlg:LESCCLOSE := .F.
		ACTIVATE MSDIALOG oDlg CENTERED
				
	EndIf
Return