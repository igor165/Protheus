#INCLUDE "loja3022.ch"
#Include 'RwMake.ch'
#Include 'TopConn.ch'
#Include 'Protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Loja3022  ºAutor  ³					 º Data ³  31/03/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Grava Grids da regra de desconto, Forma de pagamento,     º±±
±±º          ³	Condiçao de pagamentos, e Administradora				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaloja 												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                            	
Function loja3022(_cCodRgr, _aLstBxFrm, _aLstBxCPg, _aLstBxAdm)

Local _nI   := 0     // Contador
Local _lCpoFrm	:= MB5->(FieldPos("MB5_CODFRM")) > 0 	//  Controla se existem o campar par vincular a MB4 e a MB5

Default _cCodRgr 	:= ""	// _cCodRgr
Default _aLstBxFrm	:= {}	// _aLstBxFrm
Default _aLstBxCPg	:= {} 	// _aLstBxCPg
Default _aLstBxAdm	:= {}	// _aLstBxAdm

dbSelectArea("MB4")
dbSetorder(1)		//MB4_FILIAL+MB4_CODIGO+MB4_CODFRM

dbSelectArea("MB5")
dbSetOrder(1)		//MB5_FILIAL+MB5_CODIGO+MB5_CONDPG

dbSelectArea("MB6")
dbSetOrder(1)		//MB6_FILIAL+MB6_CODIGO+MB6_ADMFIN

//********************************************************************************//Forma de pagamento
If MB4->( dbSeek( xFilial("MB4") + _cCodRgr ) )
	While !MB4->( Eof() ) .And.	xFilial("MB4") + _cCodRgr == MB4->MB4_FILIAL + MB4->MB4_CODREG
		If aScan(_aLstBxFrm,{|x| Alltrim(x[2]) == Alltrim(MB4->MB4_CODFRM) }) <> 0
			RecLock("MB4",.F.)
			MB4->( dbDelete() )
			MB4->( MsUnLock() )
		EndIf
		MB4->( dbSkip() )
	End
EndIf

If M->MEI_TPIMPD <> 'I'         // so grava se for regra por total.
For _nI := 1 to Len(_aLstBxFrm)
	If _aLstBxFrm[_nI][1]
		If !MB4->( dbSeek( xFilial("MB4" ) + _cCodRgr + _aLstBxFrm[_nI][2]) )
			RecLock("MB4",.T.)
			MB4->MB4_FILIAL := xFilial("MB4")
			MB4->MB4_CODREG := _cCodRgr
			MB4->MB4_CODFRM := _aLstBxFrm[_nI][2]
			If (lChkPropor,MB4->MB4_PROPOR	:= "1","2")  //   1=SIM  , 2=NAO
			MB4->( MsUnLock() )
		EndIf
	EndIf
Next _nI  
Endif

//********************************************************************************//condicao de pagamento
If MB5->( dbSeek( xFilial("MB5") + _cCodRgr ) )
	While !MB5->( Eof() ) .And.	xFilial("MB5") + _cCodRgr == MB5->MB5_FILIAL + MB5->MB5_CODREG
		If aScan(_aLstBxCPg,{|x| Alltrim(x[2]) == Alltrim(MB5->MB5_CODPG) }) <> 0
			RecLock("MB5",.F.)
			MB5->( dbDelete() )
			MB5->( MsUnLock() )
		EndIf
		MB5->( dbSkip() )
	End
EndIf

If M->MEI_TPIMPD <> 'I'         // so grava se for regra por total.
For _nI := 1 to Len(_aLstBxCPg)
	If _aLstBxCPg[_nI][1]
		If !MB5->( dbSeek( xFilial("MB5" ) + _cCodRgr + _aLstBxCPg[_nI][2]) )
			RecLock("MB5",.T.)
			MB5->MB5_FILIAL := xFilial("MB5")
			MB5->MB5_CODREG := _cCodRgr
			MB5->MB5_CODPG := _aLstBxCPg[_nI][2]
			
			If _lCpoFrm
				MB5->MB5_CODFRM	:= Iif(Len(_aLstBxCPg[_nI])>3,_aLstBxCPg[_nI][4],""	)
			EndIf
				
			MB5->( MsUnLock() )
		EndIf
	EndIf
Next _nI                                                           
Endif
//********************************************************************************//
If MB6->( dbSeek( xFilial("MB6") + _cCodRgr ) )
	While !MB6->( Eof() ) .And.	xFilial("MB6") + _cCodRgr == MB6->MB6_FILIAL + MB6->MB6_CODREG
			RecLock("MB6",.F.)
			MB6->( dbDelete() )
			MB6->( MsUnLock() )
		MB6->( dbSkip() )
	End
EndIf

If M->MEI_TPIMPD <> 'I'         // so grava se for regra por total.
For _nI := 1 to Len(_aLstBxAdm)
	If _aLstBxAdm[_nI][1]
		If !MB6->( dbSeek( xFilial("MB6") + _cCodRgr + _aLstBxAdm[_nI][2]) )
			RecLock("MB6",.T.)
			MB6->MB6_FILIAL := xFilial("MB6")
			MB6->MB6_CODREG := _cCodRgr
			MB6->MB6_ADMFIN := _aLstBxAdm[_nI][2]
			MB6->( MsUnLock() )
		EndIf
	EndIf
Next _nI
Endif

Return (Nil)
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ3022EXRGºAutor  ³     		  		 º Data ³  06/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina que exclui (apaga) a Regra de Desconto				  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Sigaloja                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Function LJ3022EXRG(_cRgrDesc)

Local _cQry := ""			// Query

Default _cRgrDesc := ""		// _cRgrDesc

dbSelectArea("MB7") // exclui dias da semana  = PM0
dbSetOrder(1)// MB7_FILIAL+MB7_CODREG
lPainel:=SuperGetMV("MV_LJGEPRE",.F.,.F.)`   /// Se painel de gestao ATIVO, nao exclui, apenas altera o Status para MEI_ATIVA= 2
												// regra nao ativa

If MB7->( dbSeek( xFilial("MB7") + _cRgrDesc) ) .AND. !lPainel
	
	RecLock("MB7",.F.)
	MB7->( dbDelete() )
	MB7->( MsUnLock() )       
	
	_cQry := "SELECT R_E_C_N_O_ REC_MB2 FROM " + RetSqlName("MB2")   //// Exclui  Range de valores. = PM1
	_cQry += " WHERE MB2_FILIAL = '" + xFilial("MB2") + "'" 
	_cQry += "   AND MB2_CODREG = '" + _cRgrDesc + "'"
	_cQry += "   AND D_E_L_E_T_ = ' '"
	TcQuery _cQry New Alias "TMB2"
	While !TMB2->( Eof() )
		MB2->( dbGoTo(TMB2->REC_MB2) )
		RecLock("MB2",.F.)
		MB2->( dbDelete() )
		MB2->( MsUnLock() )
		TMB2->( dbSkip() )
	End
	TMB2->( dbCloseArea() )

	_cQry := "SELECT R_E_C_N_O_ REC_MB3 FROM " + RetSqlName("MB3")    ////// Exclui empresa/Filial = PM2
	_cQry += " WHERE MB3_FILIAL = '" + xFilial("MB3") + "'" 
	_cQry += "   AND MB3_CODREG = '" + _cRgrDesc + "'"
	_cQry += "   AND D_E_L_E_T_ = ' '"
	TcQuery _cQry New Alias "TMB3"
	While !TMB3->( Eof() )
		MB3->( dbGoTo(TMB3->REC_MB3) )
		RecLock("MB3",.F.)
		MB3->( dbDelete() )
		MB3->( MsUnLock() )
		TMB3->( dbSkip() )
	End
	TMB3->( dbCloseArea() )
	
	_cQry := "SELECT R_E_C_N_O_ REC_MB4 FROM " + RetSqlName("MB4")  ////// Exclui Forma de Pagamento = PM3
	_cQry += " WHERE MB4_FILIAL = '" + xFilial("MB4") + "'" 
	_cQry += "   AND MB4_CODREG = '" + _cRgrDesc + "'"
	_cQry += "   AND D_E_L_E_T_ = ' '"
	TcQuery _cQry New Alias "TMB4"
	While !TMB4->( Eof() )
		MB4->( dbGoTo(TMB4->REC_MB4) )
		RecLock("MB4",.F.)
		MB4->( dbDelete() )
		MB4->( MsUnLock() )
		TMB4->( dbSkip() )
	End
	TMB4->( dbCloseArea() )

	_cQry := "SELECT R_E_C_N_O_ REC_MB5 FROM " + RetSqlName("MB5")     /// Exclui Forma de Pagamento = PM4
	_cQry += " WHERE MB5_FILIAL = '" + xFilial("MB5") + "'" 
	_cQry += "   AND MB5_CODREG = '" + _cRgrDesc + "'"
	_cQry += "   AND D_E_L_E_T_ = ' '"
	TcQuery _cQry New Alias "TMB5"
	While !TMB5->( Eof() )
		MB5->( dbGoTo(TMB5->REC_MB5) )
		RecLock("MB5",.F.)
		MB5->( dbDelete() )
		MB5->( MsUnLock() )
		TMB5->( dbSkip() )
	End
	TMB5->( dbCloseArea() )
	
	_cQry := "SELECT R_E_C_N_O_ REC_MB6 FROM " + RetSqlName("MB6")    /// ADM FINANCEIRA = PM5
	_cQry += " WHERE MB6_FILIAL = '" + xFilial("MB6") + "'" 
	_cQry += "   AND MB6_CODREG = '" + _cRgrDesc + "'"
	_cQry += "   AND D_E_L_E_T_ = ' '"
	TcQuery _cQry New Alias "TMB6"
	While !TMB6->( Eof() )
		MB6->( dbGoTo(TMB6->REC_MB6) ) 
		RecLock("MB6",.F.)
		MB6->( dbDelete() )
		MB6->( MsUnLock() )
		TMB6->( dbSkip() )
	End
	TMB6->( dbCloseArea() )                                       

    /////// 
	_cQry := "SELECT R_E_C_N_O_ REC_MEI FROM " + RetSqlName("MEI")    //// Exclui cabeçalho da Regra de desconto  ACO
	_cQry += " WHERE MEI_FILIAL = '" + xFilial("MEI") + "'" 
	_cQry += "   AND MEI_CODREG = '" + _cRgrDesc + "'"
	_cQry += "   AND D_E_L_E_T_ = ' '"
	TcQuery _cQry New Alias "TMEI"
	While !TMEI->( Eof() )
		MEI->( dbGoTo(TMEI->REC_MEI) )
		RecLock("MEI",.F.)
		MEI->( dbDelete() )
		MEI->( MsUnLock() )
		TMEI->( dbSkip() )
	End
	TMEI->( dbCloseArea() )	
	
    ///////////
    
	_cQry := "SELECT R_E_C_N_O_ REC_MB8 FROM " + RetSqlName("MB8")    /// Itens - Categoria
	_cQry += " WHERE MB8_FILIAL = '" + xFilial("MB8") + "'" 
	_cQry += "   AND MB8_CODREG = '" + _cRgrDesc + "'"
	_cQry += "   AND D_E_L_E_T_ = ' '"
	TcQuery _cQry New Alias "TMB8"
	While !TMB8->( Eof() )
		MB8->( dbGoTo(TMB8->REC_MB8) ) 
		RecLock("MB8",.F.)
		MB8->( dbDelete() )
		MB8->( MsUnLock() )
		TMB8->( dbSkip() )
	End
	TMB8->( dbCloseArea() )           
	
	
	///////   exclui a prioridade da regra. MEJ CARDIAL  
	
		_cQry := "SELECT R_E_C_N_O_ REC_MEJ FROM " + RetSqlName("MEJ")    /// Itens - Categoria
	_cQry += " WHERE MEJ_FILIAL = '" + xFilial("MEJ") + "'" 
	_cQry += "   AND MEJ_CODREG = '" + _cRgrDesc + "'"
	_cQry += "   AND D_E_L_E_T_ = ' '"
	TcQuery _cQry New Alias "TMEJ"
	While !TMEJ->( Eof() )
		MEJ->( dbGoTo(TMEJ->REC_MEJ) ) 
		RecLock("MEJ",.F.)
		MEJ->( dbDelete() )
		MEJ->( MsUnLock() )
		TMEJ->( dbSkip() )
	End
	TMEJ->( dbCloseArea() )   
	
	 	
	// Deleta os produtos vinculados a esta regra de desconto
	MGB->( DbSetOrder(1) )
	IF MGB->( DbSeek( xFilial("MGB") + _cRgrDesc ) )
		While MGB->( !Eof() .And. MGB_FILIAL+MGB_CODREG == xFilial("MGB") + _cRgrDesc )
			RecLock("MGB",.F.)
			MGB->( dbDelete() )
			MGB->( MsUnLock() )				
			MGB->( DbSkip() )				
		End 			
	Endif 	 		 	
	 	
Elseif lPainel   /// se Painel tiver ativo , altera  MEI_ATIVA = 2  (nao ativo) , só deleta se painel Desligado

	_cQry := "SELECT R_E_C_N_O_ REC_MEI FROM " + RetSqlName("MEI")    //// Exclui cabeçalho da Regra de desconto  ACO
	_cQry += " WHERE MEI_FILIAL = '" + xFilial("MEI") + "'" 
	_cQry += "   AND MEI_CODREG = '" + _cRgrDesc + "'"
	_cQry += "   AND D_E_L_E_T_ = ' '"
	TcQuery _cQry New Alias "TMEI"     
	
	While !TMEI->( Eof() )
		MEI->( dbGoTo(TMEI->REC_MEI) )
		RecLock("MEI",.F.)
			MEI->MEI_ATIVA	:= "2"    /// 2 Regra não ativa.
		MEI->( MsUnLock() )
		TMEI->( dbSkip() )
	End
	TMEI->( dbCloseArea() )	


	///////   exclui a prioridade da regra. MEJ CARDIAL  
	
		_cQry := "SELECT R_E_C_N_O_ REC_MEJ FROM " + RetSqlName("MEJ")    /// Itens - Categoria
	_cQry += " WHERE MEJ_FILIAL = '" + xFilial("MEJ") + "'" 
	_cQry += "   AND MEJ_CODREG = '" + _cRgrDesc + "'"
	_cQry += "   AND D_E_L_E_T_ = ' '"
	TcQuery _cQry New Alias "TMEJ"
	While !TMEJ->( Eof() )
		MEJ->( dbGoTo(TMEJ->REC_MEJ) ) 
		RecLock("MEJ",.F.)
		MEJ->( dbDelete() )
		MEJ->( MsUnLock() )
		TMEJ->( dbSkip() )
	End
	TMEJ->( dbCloseArea() )   
	MsgAlert(STR0001)	 //"Painel de Gestão está ativo, Regra atual ficará com Status de Inativo, MEI_ATIVA=2"
Else
	MsgAlert(STR0002) //"Regra de Desconto nao encontrada para o cancelamento, favor entrar em contato com o Depto TI"
EndIf

Return (Nil)
                                           
