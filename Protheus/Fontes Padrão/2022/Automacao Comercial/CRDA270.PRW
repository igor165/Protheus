#INCLUDE "PROTHEUS.CH"
#INCLUDE "CRDA270.CH" 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCRDA270   บAutor  ณIP Vendas Clientes  บ Data ณ  11/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para fazer o cancelamento dos vale compra do tipo    บฑฑ
ฑฑบ          ณresgatado 			                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Sigaloja                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                     
Function CRDA270()
 
Local oDlg
Local oVale
Local cVale	:= Space( TamSX3( "MAV_CODIGO" )[1] )

DEFINE MSDIALOG oDlg FROM 10,20 TO 150,300 TITLE STR0001 PIXEL STYLE DS_MODALFRAME

	@ 05,10 SAY STR0002 SIZE 30,8 PIXEL OF oDlg			// "Vale Compra"	
	@ 05,57 MSGET oVale VAR cVale SIZE 60,8 PIXEL OF oDlg PICTURE "@!" WHEN .T. 		
	
	
	DEFINE SBUTTON FROM 50,070 TYPE 1 ACTION ( If ( CRDA270Can( cVale ), oDlg:End(), Nil )  ) ENABLE OF oDlg
	DEFINE SBUTTON FROM 50,105 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
	oDlg:LESCCLOSE := .F.
ACTIVATE MSDIALOG oDlg CENTER

Return( Nil ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCRDA270CanบAutor  ณMicrosiga           บ Data ณ  12/14/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CRDA270Can( cVale )   
Local lRet := .F.

DbSelectArea( "MAV" )
DbSetOrder( 1 )

If DbSeek( xFilial( "MAV" ) + AllTrim( cVale ) )
	If AllTrim( MAV->MAV_STATUS ) <> "4"
		RecLock( "MAV", .F. )
		Replace MAV->MAV_STATUS With "4"
		MsgInfo( STR0003 + AllTrim( MAV->MAV_CODIGO ) + STR0004 )
		MsUnlock()
		Crda270Log( {MAV->MAV_CODIGO, Nil}, "4" )
		lRet := .T.
	Else                         
		Alert( STR0003 + AllTrim( MAV->MAV_CODIGO ) + STR0005 )
	EndIf	 
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCRDA270LogบAutor  ณIP Vendas Cliente   บ Data ณ  11/13/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a gravacao do log de status dos vale compras (MB1)      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณExpA1 - Array com os dados do vale compra                   บฑฑ
ฑฑบ          ณExpC1 - Tipo da operacao                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CRDA270Log( aVale, cOper, cDoc, cPdv, cSerie, cCliente )

Local aArea		:= GetArea()		// Guarda area corrente
Local cSeq		:= "01"				// Sequencial do vale compra 
Local nOper		:= 0    			// situacao do vale compra: 1- Geracao, 2-Resgate, 3-Recebido, 4-Cancelado
Local nCodigo	:= 2				// codigo da filial     
Local aAux		:= aClone( aVale )	// Auxiliar do aVale  
Local lAchou	:= .F.				// Achou sequencial na MB1       
Local cOperador	:= ""				// Codigo do operador   
Local lNew		:= AliasIndic("MB1")// Verifica se ha as melhorias no vale compra			

Default cDoc		:= ""			// Numero do cupom fiscal
Default cSerie		:= ""			// Serie do cupom fiscal 
Default cPdv		:= ""			// Pdv da finalizacao       
Default cCliente	:= ""			// Cliente para gravacao do log	

If cOper == "2" .OR. cOper == "3" 
	cCliente := SL1->L1_CLIENTE
EndIf		


If ValType( cOper ) == "C"
	nOper := Val( cOper )
Else
	Return( Nil )
EndIf        

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTratamento para logar o resgate do vale compra.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cOper == "2" 
	nCodigo := 4 
EndIf 

If cOper == "3" .OR. cOper == "4"	  
	nCodigo := 1
Endif	

If Len( aAux ) >= 1 .AND. lNew
	DbSelectArea( "MB1" )
	DbSetOrder( 1 )                          

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ1 = geracao -> cSeq = 01                          ณ
	//ณSe qualquer outra operacao procura no MB1 o ultimoณ
	//ณsequencial e incrementa 1.                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If cOper <> "1"
		If MB1->( DbSeek( xFilial( "MB1" ) + aAux[nCodigo] ) )
			While ! MB1->( Eof() ) .AND. MB1->MB1_CODIGO == aAux[nCodigo]
				cSeq := MB1->MB1_MOVIM
				lAchou := .T.
				MB1->( DbSkip() ) 				
			End	    			
		EndIf          
	EndIf
	
	If cOper <> "01" .AND. lAchou
		cSeq := Soma1( cSeq )
	EndIf
	
	cOperador := xNumCaixa()
	If Empty( cOperador )
		cOperador := "ADM"
	EndIf	
		
	RecLock( "MB1", .T. )
	REPLACE MB1_FILIAL		WITH xFilial( "MB1" )		// Filial  
	REPLACE MB1_CODIGO		WITH aAux[nCodigo]		// Codigo do Vale Compra
	REPLACE MB1_MOVIM		WITH cSeq		  		// Sequencial de movimentacao
	REPLACE MB1_DTMOVI		WITH dDatabase			// Data do movimento
	REPLACE MB1_HRMOV		WITH Time()				// Hora do movimento
	REPLACE MB1_OPERAD		WITH cOperador  		// Numero do operador
	REPLACE MB1_OPER		WITH nOper				// Numero da operacao  

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe pagamento com vale compra atualiza com os dados da vendaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If cOper <> "1" 
	   	If cOper <> "4" .AND. MB1->(FieldPos( "MB1_CLIENT" ) ) > 0
			REPLACE MB1_CLIENT		WITH cCliente		// Cliente		
		EndIf	
			 
		REPLACE MB1_PDV		WITH cPdv		// PDV
		REPLACE MB1_NF		WITH cDoc		// Nota fiscal / cupom fiscal
		SerieNfId("MB1",1,"MB1_SERIE",dDataBase,LjEspecieNF(), cSerie) 
	EndIf		
	
	MsUnlock( )
Else
	Return( Nil )
Endif			
			
RestArea( aArea )
Return( Nil )       
