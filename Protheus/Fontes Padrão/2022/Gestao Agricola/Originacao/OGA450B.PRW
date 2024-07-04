#INCLUDE "OGA450B.ch"
#include "protheus.ch"
#include "totvs.ch"
#include "fwmvcdef.ch"

/** {Protheus.doc} OGA450B
INFORMACOES PARA TRANSFERENCIA 

@param:    Nil
@original: Ana Laura Olegini
@author:   Bruna Fagundes Rocio
@since:    12/02/15
@Uso: 	    SIGAAGR - Originação de Grãos
*/
Function OGA450B( cCodEnt, cLojEnt, cNomEnt, cAliasCTR)
    Local aAreaAtu		:= GetArea()
	Local aSimNao 		:= {STR0056,STR0057}	//"Sim"###"Nao"	-->P/Formulario Proprio
	Local aNaoSim 		:= {STR0057,STR0056}	//"Nao"###"Sim"	-->P/Transfere Despesa
	Local aTipoCtr		:= {"",STR0019,STR0008} //"Compra"###"Armaz De 3"
	Local aTipoFrete	:= {STR0076,STR0077,STR0078,STR0079,STR0080,STR0081}
	Local lRet			:= .F.
	Local oDlg			:= Nil
	Local lPadrao		:=.f.
	Local oONomEnt 		:= NIL

	Private lEdtDesp	:= .F.
	Private cOCodCtr	:= Space( TamSX3( "NJR_CODCTR" )[1] )
	Private cONomCtr	:= Space( TamSX3( "NJR_DESCRI" )[1] )
	Private cONomEnt	:= Space( TamSX3( "NJ0_NOME" )[1] )
	Private cTrfDst 	:= ""
	Private aRegNJJ 	:= {}	 
	Private cDCodCtr	:= Space( TamSX3( "NJR_CODCTR" )[1] )
	Private cDNomCtr	:= Space( TamSX3( "NJR_DESCRI" )[1] )
	Private cNFPSer		:= Space( TamSX3( "NJJ_NFPSER" )[1] )
	Private cNFPNum		:= Space( TamSX3( "NJJ_NFPNUM" )[1] )
	Private cCodTra		:= Space( TamSX3( "A4_COD"     )[1] )
	Private cCodVe1		:= Space( TamSX3( "DA3_COD"    )[1] )
	Private cFormProp	:= "1" //Space( TamSX3( "NJJ_TPFORM" )[1] )
	Private cTrnfDesp	:= "1"
	Private cTipoDest   := ""
	Private cMsgDev 	:= Space( TamSX3( "NJJ_MSGNFS" )[1] ) //alterado para NJJ pois esta variavel vai para o romaneio(NJJ_MSGNFS) o qual ao gerar a NF salva na SF1(F1_MEMNOTA)/SF2(F2_MEMNOTA) 
	Private cMsgEnt		:= Space( TamSX3( "NJJ_MSGNFS" )[1] )
	Private cNFData		:= CTOD( "  /  /    " )
	Private cNFNumero	:= Space( TamSX3( "NJJ_DOCNUM" )[1] )
	Private cNFSerie	:= Space( TamSX3( "NJJ_DOCSER" )[1] )
	Private cTesDev		:= Space( TamSX3( "F4_CODIGO"  )[1] )
    Private cOpFisDev   := Space( TamSX3( "N9A_OPEFIS" )[1] )    
    Private cOpFisDest  := Space( TamSX3( "N9A_OPEFIS" )[1] )    
	Private cTESDest	:= Space( TamSX3( "F4_CODIGO"  )[1] )
	Private cNFEspecie	:= Space( TamSX3( "NJJ_DOCESP" )[1] )
	Private cChaveNFE	:= Space( TamSX3( "NJJ_CHVNFE" )[1] )
	Private cLocalD		:= Space( TamSX3( "NJJ_LOCAL"  )[1] )
	Private cLocalO		:= Space( TamSX3( "NJJ_LOCAL"  )[1] )
	Private nNFVlrTot		:= 0
	Private nNFVlrUni		:= 0
	Private nQtd 			:= 0
	Private nVlrFrete		:= 0
	Private cPicQtd		:= "@E 999,999,999,999.99"
	Private cPicUlr		:= "@E 999,999.999999"
	Private cPicVlr		:= "@E 999,999,999,999.99"
	Private cPicVlFrt	:= "@E 99,999,999,999.99"
	Private cTipoFrete  := Space(TamSX3("NJJ_TPFRET")[1])

	Private nQtdOrige	:= 0
	Private nQtdEnFco	:= 0
	Private nQtdSaFco	:= 0
	Private nQtdAFixa	:= 0
	Private nQtdPend    := 0

	Private cPTipo		:= ""
	Private cPCodEnt	:= ""
	Private cPLojEnt	:= ""
	Private cPSafra		:= ""
	Private cPCodPro	:= ""
	Private nDecPeso	:= SuperGetMV("MV_OGDECPS",,0)
	Private cPicPeso	:= SuperGetMV("MV_OGPICPS",,"@E 999,999,999")	
	Private _lnewNeg   := SuperGetMv('MV_AGRO002', , .F.)
				
	/* Vars Grupo 3 */
	Private cNKMTIPOMV	:= Criavar('NKM_TIPOMV', .F.)
	Private cNKMDESTIP	:= Criavar('NKM_DESTIP', .F.)				

    Private cOCodEnt    := ""
    Private cOLojEnt    := ""
	
	Default cAuTesDV  := ''
    Default cAuLocOg  := ''
    Default cAuMsgDe  := ''
    Default cAuDCodE  := ''
    Default cAuDLojE  := ''
    Default cAuTipoD  := ''
    Default cAuTESDe  := ''
    Default nAuQtd    := 0
    Default cAuFormP  := ''
    Default cAuLocDs  := ''
    Default cAuNFPSe  := ''
	Default cAuNFPNu  := ''
	Default cAuMsgEn  := ''
	Default cRom1Aut  := ''
	Default cRom2Aut  := ''

	//*VARIAVEIS DE TELA RECEBEM INFORMACOES DA TELA PRINCIPAL	
	cOCodEnt			:= Alltrim( cCodEnt ) 					//ENTIDADE
	cOLojEnt			:= Alltrim( cLojEnt ) 					//LOJA ENTIDADE
	cONomEnt			:= Alltrim( cNomEnt ) 					//ENTIDADE
	cOCodCtr			:= Alltrim( (cAliasCTR)->C_CODCTR )	//CONTRATO
	cONomCtr			:= Alltrim( (cAliasCTR)->C_DESCRI )	//DESCRICAO
    
	//Validar para nao permitir transferencia para nova comercializacao
	IF  ( cAliasSLD )->S_TIPO = "1" .and. (_lnewNeg .or. !Empty(Posicione("NJR",1,(cAliasCTR)->C_FILIAL + cOCodCtr ,"NJR_CODNGC")))
		Agrhelp( STR0009, STR0091, STR0092) //A operação de transferência não é permitida para a nova comercialização.
		Return( Nil )	
	ENDIF
    
	//*VALIDACAO PARA VERIFICAR SE FOI INFORMADO ENTIDADE NA TELA PRINCIPAL
	If Empty(cCodEnt)
		Help( , , STR0009, , STR0010, 1, 0 ) //"AJUDA"###"Informar Entidade para Transferencia."
		Return( Nil )	 
	EndIf

	//*VALIDACAO PARA ABRIR TELA SOMENTE SE FOR 1=COMPRA OU 3=ARMAZENAGEM DE 3º
	If Posicione( "NJR", 1, xFilial( "NJR" ) + cOCodCtr, "NJR_TIPO" ) $ "2|4"
		Help( , , STR0009, , STR0011 + ": " + cOCodCtr, 1, 0 ) //"AJUDA"###"Operação permitida somente para contratos de Compra e Armazenagem De 3. "
		Return( Nil )
	EndIf

	//SE TIPO FOR IGUAL A 1=COMPRA OU 3=DEP. DE 3º	
	If ( cAliasSLD )->S_TIPO = "1" .OR. ( cAliasSLD )->S_TIPO = "3"
		nQtdPend  := OGA450BRomPd(( cAliasCTR )->C_CODCTR, "%'6','8'%")
		nQtdOrige := ( cAliasCTR )->C_QTEFCO - ( cAliasCTR )->C_QTSFCO - ( cAliasCTR )->C_QTDFIX - ( cAliasCTR )->C_QTDRES
		//Validar posteriormente
		If nQtdOrige < 0 
			nQtdOrige := ( cAliasCTR )->C_QTEFCO - ( cAliasCTR )->C_QTSFCO - ( cAliasCTR )->C_QTDRES
		Endif
		//SE TIPO FOR IGUAL A 2=VENDA OU 4=DEP. EM 3º
	ElseIf ( cAliasSLD )->S_TIPO = "2" .OR. ( cAliasSLD )->S_TIPO = "4"
		nQtdPend  := OGA450BRomPd(( cAliasCTR )->C_CODCTR, "%'7','9'%")
		nQtdOrige := ( cAliasCTR )->C_QTSFCO - ( cAliasCTR )->C_QTEFCO - ( cAliasCTR )->C_QTDFIX - ( cAliasCTR )->C_QTDRES

		//Validar posteriormente
		If nQtdOrige < 0
			nQtdOrige := ( cAliasCTR )->C_QTSFCO - ( cAliasCTR )->C_QTEFCO - ( cAliasCTR )->C_QTDRES
		Endif 
	EndIf

	nQtdEnFco	:= ( cAliasCTR )->C_QTEFCO
	nQtdSaFco	:= ( cAliasCTR )->C_QTSFCO
	nQtdAFixa	:= ( cAliasCTR )->C_QTDFIX
    
    //*PARAMETROS DE TELA - TRANSFERENCIA							
    oDlg	:= TDialog():New( 0, 0, 600, 960, OemToAnsi( STR0012 ), , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Dados para Transferencia"
    oDlg:lEscClose := .f.

    oPanelTop := TPanel():New(0 , 01,,oDlg,,.F.,.F.,,,600,930,.T.,.T.)
    oPanelTop:Align	:= CONTROL_ALIGN_ALLCLIENT 

    //*Grupo 1 - Origem
    oLQtd	:= TGroup():New( 004,004,082/*095*/,477,OemToAnsi( STR0013 ),oPanelTop,CLR_BLACK,CLR_WHITE,.T.,.F. ) //"Origem"

    //*FIXO
    @ 019,012 SAY(OemToAnsi( STR0014 )) Of oLQtd PIXEL		//"Entidade:"
    @ 019,048 MSGET cOCodEnt PICTURE "@!" SIZE 40,10  OF oLQtd PIXEL WHEN .F. 
    @ 019,090 MSGET cOLojEnt PICTURE "@!" SIZE 15,10  OF oLQtd PIXEL WHEN .F.
    @ 019,107 MSGET oONomEnt Var cONomEnt PICTURE "@!" SIZE 110,10 OF oLQtd PIXEL WHEN .F. OBFUSCATED AGRLGPD("NJ0_NOME")				
    //*FIXO
    @ 019,248 SAY(OemToAnsi( STR0015 )) Of oLQtd PIXEL 		//"Contrato:"	
    @ 019,284 MSGET cOCodCtr  PICTURE "@!" SIZE 40,10 OF oLQtd PIXEL WHEN .F.
    @ 019,326 MSGET cONomCtr PICTURE "@!" SIZE 120,10 OF oLQtd PIXEL WHEN .F.					
    //*FIXO
    @ 035,012 SAY(OemToAnsi( STR0016 )) Of oLQtd PIXEL 	//"Qtd Dispon:
    @ 035,048 MSGET nQtdOrige PICTURE cPicQtd OF oLQtd HASBUTTON PIXEL WHEN .F.	
    //*FIXO
    @ 035,130 SAY(OemToAnsi( STR0017 )) Of oLQtd PIXEL	//"Qtd E.Fco.:"
    @ 035,166 MSGET nQtdEnFco PICTURE cPicQtd OF oLQtd HASBUTTON PIXEL WHEN .F.
    //*FIXO
    @ 035,248 SAY(OemToAnsi( STR0018 )) Of oLQtd PIXEL	//"Qtd S.Fco.:"
    @ 035,284 MSGET nQtdSaFco PICTURE cPicQtd OF oLQtd HASBUTTON PIXEL WHEN .F.
    //*FIXO
    @ 035,366 SAY(OemToAnsi( STR0007 )) Of oLQtd PIXEL	//"Qtd a Fixar:"
    @ 035,402 MSGET nQtdAFixa PICTURE cPicQtd OF oLQtd HASBUTTON PIXEL WHEN .F.

    //*INFORMA	
    @ 051,012 SAY(OemToAnsi( "Oper.Fis." )) Of oLQtd PIXEL			//"Oper Fiscal"
    @ 051,048 MSGET cOpFisDev PICTURE "@!" OF oLQtd F3 "DJ" HASBUTTON PIXEL VALID (fTesIntel()) 

    @ 051,078 SAY(OemToAnsi( STR0020 )) Of oLQtd PIXEL			//"TES"
    @ 051,090 MSGET cTesDev PICTURE "@!" OF oLQtd F3 "SF4" HASBUTTON PIXEL 

    //*INFORMA
    @ 051,142 SAY(OemToAnsi( STR0021 )) Of oLQtd PIXEL			//"Local"
    @ 051,166 MSGET cLocalO PICTURE "@!" OF oLQtd F3 "NNR" HASBUTTON PIXEL ON CHANGE (OGA450VALLOC()) 

    //*VALIDACAO PARA TRANSF. DESPESA [Somente p/ 3=Armazenagem De 3] - CAMPO BOX
    OGA450VALCTR('1')		
    @ 051,235 SAY(OemToAnsi( STR0022 )) Of oLQtd PIXEL	//"Gera Despesa"
    @ 051,284 COMBOBOX cTrnfDesp ITEMS aNaoSim SIZE 45,7 OF oLQtd PIXEL WHEN lEdtDesp 

    //TIPO FRETE
    @ 051,371 SAY(OemToAnsi( STR0074 )) Of oLQtd PIXEL	//"Tipo Frete"
    @ 051,397 COMBOBOX cTipoFrete ITEMS aTipoFrete SIZE 70,7 OF oLQtd PIXEL WHEN .T.

    //*INFORMA	
    @ 067,012 SAY(OemToAnsi( STR0023 )) Of oLQtd PIXEL		//"Mens.p/ Nota"
    @ 067,048 MSGET cMsgDev PICTURE "@!" OF oLQtd SIZE 420,010 PIXEL  

    //*Grupo 2 - Destino 
    oLQtd	:= TGroup():New( 090,004,225/*260*/,477,OemToAnsi( STR0024 ),oPanelTop,CLR_BLACK,CLR_WHITE,.T.,.F. ) //"Destino" 

    @ 100,012 SAY(OemToAnsi( STR0014 )) Of oLQtd PIXEL		//"Entidade:"	
    @ 100,048 MSGET cDCodEnt PICTURE "@!" SIZE 40,10  OF oPanelTop F3 "NJ0" HASBUTTON PIXEL VALID ValEntidade(cDCodEnt) 
    @ 100,090 MSGET cDLojEnt PICTURE "@!" SIZE 15,10  OF oPanelTop PIXEL VALID ValEntidade(cDCodEnt,cDLojEnt).Or.Empty(cDLojEnt) WHEN .T.
    @ 100,107 MSGET oDNomEnt Var cDNomEnt PICTURE "@!" SIZE 110,10 OF oPanelTop PIXEL WHEN .F.	OBFUSCATED AGRLGPD("NJ0_NOME")

    @ 100,237 SAY(OemToAnsi( STR0058 )) Of oLQtd PIXEL 		//"Tipo Contrato"
    @ 100,277 COMBOBOX cTipoDest ITEMS aTipoCtr SIZE 60,7 OF oPanelTop PIXEL 				

    @ 115,012 SAY(OemToAnsi( "Oper.Fis." )) Of oLQtd PIXEL			//"Oper Fiscal"
    @ 115,048 MSGET cOpFisDest PICTURE "@!" OF oLQtd F3 "DJ" HASBUTTON PIXEL VALID (fTesIntel()) 

    @ 115,078 SAY(OemToAnsi( STR0020 )) Of oLQtd PIXEL			//"TES:"
    @ 115,090 MSGET cTESDest  PICTURE "@!" OF oPanelTop F3 "SF4" HASBUTTON PIXEL

    @ 115,135 SAY(OemToAnsi( STR0025 )) Of oLQtd PIXEL 	//"Quantidade:"
    @ 115,171 MSGET nQtd PICTURE cPicQtd OF oPanelTop HASBUTTON PIXEL ON CHANGE (ValidQtdVlr('1'))	

    @ 115,253 SAY(OemToAnsi( STR0026 )) Of oLQtd PIXEL	//"Transportadora:"
    @ 115,294 MSGET cCodTra PICTURE "@!" OF oPanelTop F3 "SA4" HASBUTTON PIXEL

    @ 115,371 SAY(OemToAnsi( STR0027 )) Of oLQtd PIXEL			//"Veiculo:"
    @ 115,407 MSGET cCodVe1 PICTURE "@!" OF oPanelTop F3 "DA3" HASBUTTON PIXEL

    //*CONTROLA COMBO BOX - SIM E NAO - PARA VALIDAÇÃO DOS CAMPOS ABAIXO - SE ALTERA 
    @ 130,012 SAY(OemToAnsi( STR0028 )) Of oLQtd PIXEL		//"Form. Prop."
    @ 130,048 COMBOBOX cFormProp ITEMS aSimNao SIZE 45,7 OF oPanelTop PIXEL ON CHANGE (ValidForm())

    @ 130,135 SAY(OemToAnsi( STR0021 )) Of oLQtd PIXEL 	//"Local:"
    @ 130,171 MSGET cLocalD PICTURE "@!" OF oPanelTop F3 "NNR" HASBUTTON PIXEL  

    @ 130,253 SAY(OemToAnsi( STR0075 )) Of oLQtd PIXEL 	//"Valor Frete:"
    @ 130,294 MSGET nVlrFrete PICTURE cPicVlFrt OF oPanelTop HASBUTTON PIXEL 

    @ 145,012 SAY(OemToAnsi( STR0029 )) Of oLQtd PIXEL	 		//"NFP Série"
    @ 145,048 MSGET cNFPSer PICTURE "@!" OF oPanelTop PIXEL WHEN (cFormProp == "Sim")

    @ 145,135 SAY(OemToAnsi( STR0030 )) Of oLQtd PIXEL	 	//"NFP Numero:"
    @ 145,171 MSGET cNFPNum PICTURE "@!" OF oPanelTop PIXEL WHEN (cFormProp == "Sim")

    @ 160,012 SAY(OemToAnsi( STR0031 )) Of oLQtd PIXEL				//"Série"
    @ 160,048 MSGET cNFSerie PICTURE "@!" OF oPanelTop PIXEL WHEN (cFormProp <> "Sim")

    @ 160,135 SAY(OemToAnsi( STR0032 )) Of oLQtd PIXEL			//"Número"
    @ 160,171 MSGET cNFNumero PICTURE "@!" OF oPanelTop PIXEL WHEN (cFormProp <> "Sim")

    @ 160,253 SAY(OemToAnsi( STR0033 )) Of oLQtd PIXEL		//"Data Emissão"
    @ 160,294 MSGET cNFData  PICTURE "99/99/9999" SIZE 45,10 OF oPanelTop HASBUTTON PIXEL WHEN (cFormProp <> "Sim")

    @ 160,371 SAY(OemToAnsi( STR0034 )) Of oLQtd PIXEL			//"Espécie:"
    @ 160,407 MSGET cNFEspecie  PICTURE "@!" OF oPanelTop F3 "42" HASBUTTON PIXEL WHEN (cFormProp <> "Sim") 

    @ 175,012 SAY(OemToAnsi( STR0035 )) Of oLQtd PIXEL	//"Valor Unitário"
    @ 175,048 MSGET nNFVlrUni PICTURE PesqPict("NJM","NJM_VLRUNI") OF oPanelTop HASBUTTON PIXEL WHEN (cFormProp <> "Sim") ON CHANGE (ValidQtdVlr('1'))	

    @ 175,135 SAY(OemToAnsi( STR0036 )) Of oLQtd PIXEL		//"Valor Total"
    @ 175,171 MSGET nNFVlrTot PICTURE PesqPict("NJM","NJM_VLRTOT") OF oPanelTop HASBUTTON PIXEL WHEN (cFormProp <> "Sim") ON CHANGE (ValidQtdVlr('2'))	

    @ 190,012 SAY(OemToAnsi( STR0037 )) Of oLQtd PIXEL		//"Mens.p/ Nota"
    @ 190,048 MSGET cMsgEnt PICTURE "@!" OF oPanelTop SIZE 420,010 PIXEL

    @ 205,012 SAY(OemToAnsi( STR0038 )) Of oLQtd PIXEL			//"Chave NFE:"
    @ 205,048 MSGET cChaveNFE PICTURE "@!" OF oPanelTop PIXEL WHEN (cFormProp <> "Sim") .AND. cFormProp='Nao' .AND. cNFEspecie='SPED'

    //*Grupo 3 - Tpmv  ( Atenção o Objeto deveria ter sido Tpanel para ter link entre o Panel e os itens que ele contem, vou seguir o q ja foi criado  ) 
    oGrTpMv	:= TGroup():New( 0230,004,260/*260*/,477,OemToAnsi( STR0073 ),oPanelTop,CLR_BLACK,CLR_WHITE,.T.,/*.F.*/ ) //"Tipo de Movimento"
    //oPNTpMv := TPanel():New(0230,004,'Emerson',oPanelTop,/*oFontAta*/,.F.,.F.,,,480,260,.T.,.T.)

    //Identifica o nr. do Tipo de Movimento a Ser Gravado na Tab. de Geração de Movimentos, Caso Utilize;
    fGetTpMv()
    //---------------------------------------------------------------------------------------------------//
    @ 0240,012 SAY(OemToAnsi( 'Tp Movto' )) OF oGrTpMv PIXEL		//"Entidade:"	
    @ 0240,048 MSGET cNKMTIPOMV PICTURE PESQPICT('NKM','NKM_TIPOMV') /*SIZE 40,10  */ OF oGrTpMv F3 "NKL" HASBUTTON PIXEL WHEN .f. VALID fVldTpMv(cNKMTIPOMV) 
    @ 0240,090 MSGET cNKMDESTIP PICTURE PESQPICT('NKM','NKM_DESTIP') /*SIZE 220,10 */ OF oGrTpMv PIXEL WHEN .F.

    //fim Grupo 3


    lPadrao		:= .f.  // Para não mostra o botão de ações relacionadas

    ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, {|| iIf( OGA450TOK(), ( lRet:=.T., oDlg:End() ), NIL ) }, {|| oDlg:End() },,,,,,,lPadrao,,,,, ) CENTERED
	
	RestArea( aAreaAtu )
Return( lRet )

/*
############################################################################
# Função   : ValidForm                                                     #
# Descrição: Valida se o formulario será ou nao preenchido                 #
# Autor    : Ana Laura Olegini                                             #
# Data     : 21/11/2014                                                    #  
############################################################################
*/
Static Function ValidForm()

	//Formulario Proprio? 
	If cFormProp = "Sim"

		//Limpa tela
		cMsgEnt	:= Space( TamSX3( "F1_MENNOTA" )[1] )
		cNFData	:= CTOD( "  /  /    " )
		cNFNumero	:= Space( TamSX3( "NJJ_DOCNUM" )[1] )
		cNFSerie	:= Space( TamSX3( "NJJ_DOCSER"  )[1] )
		cNFEspecie	:= Space( TamSX3( "NJJ_DOCESP"  )[1] )
		cChaveNFE 	:= Space( TamSX3( "NJJ_CHVNFE"  )[1] )
		nNFVlrTot	:= 0
		nNFVlrUni	:= 0
	ElseIf cFormProp = "Nao"  //Não->trava os campos NFP Série e NFP Numero

		//Limpa tela
		cNFPSer		:= Space( TamSX3( "NJJ_NFPSER" )[1] )
		cNFPNum		:= Space( TamSX3( "NJJ_NFPNUM" )[1] )
	EndIf

	lRefresh := .T.
Return

/*
############################################################################
# Função   : OGA450TOK                                                     #
# Descrição: CONFIRMA TRANSFERÊNCIA ENTRE CONTRATOS                        #
# Autor    : Ana Laura Olegini                                             #
# Data     : 18/07/2014                                                    #  
############################################################################
*/
Static Function OGA450TOK()
	Local aAreaAtu 	 := GetArea()
	Local cDCodCtr   := ""
	Local cAliasQry  := GetNextAlias()
	Local lRetorno	 := .T.
	Local nX 		 := 0
	Local nVerifica	 := 0
	Local cCultra    := ""
	Local cIdMov	 := Criavar('NKM_IDMOV',.f.)
	Local cMsg		 := ''
	
	Private cPicPeso	:= SuperGetMV("MV_OGPICPS",,"@E 999,999,999")	

	aRegNJJ := {}
	cTrfDst := ""	

	If nQtd <= 0 
		MsgAlert(STR0039+Chr(13)+STR0040) //"Não foi informada nenhuma quantidade a ser negociada."###"Nenhum movimento será gerado."
		Return( .F. )
	EndIf

	If Empty(cLocalD)
		cLocalD := cLocalO		
	Endif

	If Empty(cTipoDest)
		MsgAlert(STR0059) //"Tipo de contrato Destino (Compra/Armazenagem de 3) deverá ser informado."
		Return ( .f. )
	Endif
	
	IF ! Empty( cNKMTIPOMV )// Validação ref. a Tipo de Movimentos Caso Controle a Geração de Movimentos da Transferencia Simples
			DbSelectArea( "NKL" )
			NKL->( DbSetOrder( 1 ) ) 
			If ! NKL->( MsSeek( fWxFilial( "NKL" ) + cNKMTIPOMV ))
				cMsg := STR0070 + CRLF		//'Transferência Simples, Configurada para gerar controle de movimentações com tipo de movimentação inválido.' + CRLF
				cMsg += STR0071  			//'Favor verificar o parametro MV_OGCTRMV, e avegiguar o tipo de movimentação informado para os movimentos de TRFS.'
				MsgAlert( cMsg )
				Return( .f. )
			ElseIF Alltrim( NKL->NKL_ATIVO ) == '2'
			  	cMsg := STR0070 + CRLF		//'Transferência Simples, Configurada para gerar controle de movimentações com tipo de movimentação inválido.' + CRLF
				cMsg += STR0072				//'Favor verificar o parametro MV_OGCTRMV;  Tipo de Movto para os movimentos de TRFS. está Inátivo'
				MsgAlert( cMsg ) 
				Return( .f. )
			EndIF
	EndIF

	//Se escolher compra - vai buscar os contratos de compra 
	If cTipoDest = STR0019	//"Compra"
		cTipoCtr := "1"
		cTipoRom := "5"	//5=Entrada Compra 
		cDescTip := STR0019	//"Compra"
		//Se escolher armaz. - vai buscar os contratos de armazenagem
	ElseIf cTipoDest = STR0008 	//"Armaz De 3"
		cTipoCtr := "3"
		cTipoRom := "3"	//3=Entrada Depos. 3 
		cDescTip := STR0008 		//"Armaz De 3"
	EndIf
		
    If !MsgYesNo(STR0041) //"Deseja confirmar a transferência entre os contratos?"
        Return( .f. )  // A lRetorno ira retornar .t. ou .f. aqui nao posso retornar nil tenho q padronizar
    EndIf	
	
	cPSafra  := Posicione( "NJR", 1, xFilial( "NJR" ) + cOCodCtr, "NJR_CODSAF" )
	cPCodPro := Posicione( "NJR", 1, xFilial( "NJR" ) + cOCodCtr, "NJR_CODPRO" )
	nVlrBase := Posicione( "NJR", 1, xFilial( "NJR" ) + cOCodCtr, "NJR_VLRBAS" )
	cCodIdx  := Posicione( "NJR", 1, xFilial( "NJR" ) + cOCodCtr, "NJR_CODIDX" )

	If !Empty(cPCodPro)   
		dbSelectArea('SB5')
		dbSetOrder(1)
		If dbSeek( xFilial('SB5') + cPCodPro )
			cCultra := SB5->B5_CULTRA 	
		Endif	
	Endif   

	//feita consistência, pois esse erro ocorre só lá no romaneio e não é atualizado, causando impactos nos saldos de transf.
	If nVlrBase <= 0 .AND. Empty(cCodIdx)
		AgrHelp(STR0009, STR0082 + alltrim(cOCodCtr) + STR0083, STR0084) //#O contrato ##" não possui valor base ou índice de preço. Não será possível gerar o romaneio." ##"Por favor, verifique essas informações no cadastro do contrato."
		Return .f.
	EndIf

	cQuery := " SELECT * "
	cQuery +=   " FROM "+ RetSqlName("NJR") + " NJR "

	If !Empty(cCultra)
		cQuery +=  " RIGHT JOIN " + RetSqlName("SB5") + " SB5 "
		cQuery +=  "         ON SB5.D_E_L_E_T_ = '' "
		cQuery +=  "        AND SB5.B5_CULTRA  = '" + cCultra + "'"
		cQuery +=  "        AND SB5.B5_COD     = NJR.NJR_CODPRO "
	EndIf

	cQuery +=  " WHERE NJR.D_E_L_E_T_ = '' "
	cQuery +=    " AND NJR.NJR_FILIAL = '" + xFilial( 'NJR' ) + "'"	
	cQuery +=    " AND NJR.NJR_TIPO   = '" + cTipoCtr + "'"	  
	cQuery +=    " AND NJR.NJR_CODENT = '" + cDCodEnt + "'"  
	cQuery +=    " AND NJR.NJR_LOJENT = '" + cDLojEnt + "'"  
	cQuery +=    " AND NJR.NJR_CODSAF = '" + cPSafra  + "'" 
	cQuery +=    " AND NJR.NJR_STATUS in ( 'P', 'A', 'I' )
	cQuery := ChangeQuery(cQuery)

	If Empty(cCultra)
		cQuery +=    " AND NJR.NJR_CODPRO = '" + cPCodPro + "'"
	EndIf

	//-- VERIFICA SE EXISTE - SE SIM APAGA TABELA TEMP
	If Select(cAliasQry) <> 0
		(cAliasQry)->(dbCloseArea())
	EndIf
	//-- DEFINE UM ARQUIVO DE DADOS COMO UMA AREA DE TRABALHO DISPONIVEL NA APLICACAO
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)			

	COUNT TO nVerifica

	// Busca o código do contrato destino		
    If nVerifica > 0  
        If .Not. Empty( cCultra )
            OGX010TRCT( cTipoCtr , cDCodEnt ,cDLojEnt, cPSafra, cCultra )
            cDCodCtr := __cCodigo
        Else
            OGX010CT( OGX010TC( cTipoCtr ) , cDCodEnt ,cDLojEnt, cPSafra, cPCodPro )
            cDCodCtr := __cCodigo
        EndIf
    Else
        cDCodCtr := OGX010BC(OGX010TC(cTipoRom), cDCodEnt, cDLojEnt, cPSafra, cPCodPro)
        If valType(cDCodCtr) == "A" //se for array, pega apenas codigo do contrato - trata inovação liberada na P12.1.23
            cDCodCtr := cDCodCtr[1]
        EndIf
    EndIf
    
    
	If Empty(cDCodCtr)
		MsgStop( STR0060 ) //"Não foi possível encontrar nenhum contrato que satisfaça as condições de mesma Safra, Produto e Tipo de Contrato, na entidade destino da transferência."
		lRetorno := .F.
	Endif

	//Validar para nao permitir transferencia quando compra nova comercialização
	IF !Empty(cDCodCtr) .and. cTipoCtr == "1" .and. ( _lnewNeg .OR. !Empty(Posicione("NJR",1,(cAliasCTR)->C_FILIAL + cDCodCtr ,"NJR_CODNGC"))) 
		Agrhelp( STR0009, STR0091, STR0092) //A operação de transferência não é permitida para a nova comercialização.
		Return .F.
	ENDIF

	if .not. ValidNFFP(cDCodCtr)
		return (.f.)
	endif	

	If nQtd > 0 .And. lRetorno
		cTrfDst := ""
		BEGIN SEQUENCE
			BEGIN TRANSACTION
				//"Gerando devolução contrato origem..."###"Romaneio Simbólico"
				IF ! Empty(cNKMTIPOMV)  // Identifica que Deve-se Utilizar o Controle de Movimentos do OG, Para criar vinculo entre os Romaneios do Processo 
				   cIdMov := fGerMvID( cNKMTIPOMV ) // Identificando o Tipo de Movto
				EndIF
				
				MsgRun( STR0042	, STR0044 	, {|| lRetorno := GeraRomSimb( 	"O", cOCodCtr, nQtd, "1", "", "", "",;
				"", cMsgDev, "",;
				"", "", cTesDev, "","",;	
				"", "" , cLocalD, cTrnfDesp, cIdMov,,cTipoFrete,cRom1Aut) } )
				If .Not. lRetorno
					DisarmTransaction()
					BREAK
				EndIf
                
				//"Gerando entrada contrado destino..."###"Romaneio Simbólico"
				MsgRun( STR0043 , STR0044 	, {|| lRetorno := GeraRomSimb( 	"D", cDCodCtr, nQtd, If( cFormProp = "Sim","1","2"), cNFPSer, cNFPNum, cCodTra,;
				cCodVe1, cMsgEnt, cNFData,;
				cNFNumero, cNFSerie, cTESDest, cNFEspecie, cChaveNFE,;	
				nNFVlrTot, nNFVlrUni, cLocalD, cTrnfDesp,cIdMov, nVlrFrete, ,cRom2Aut ) } )
				If .Not. lRetorno
					DisarmTransaction()
					BREAK
				EndIf
			END TRANSACTION
		END SEQUENCE				

		If lRetorno = .t. .And. Len( aRegNJJ ) = 2

			For nX := 1 to Len( aRegNJJ )
				NJJ->( dbGoto( aRegNJJ[ nX ] ) )
				If RecLock( "NJJ", .f. )
					NJJ->( NJJ_FILREL ) := FWxFilial( "NJJ" )
					NJJ->( NJJ_ROMREL ) := cTrfDst
					msUnLock()
				EndIf

				lRetorno := OGA250ATUC( Alias(), Recno(), 4, .t. )

				If .Not. lRetorno
					MsgStop(STR0065 + NJJ->( NJJ_CODROM) ) //"Problema ao atualizar romaneio: "
					lRetorno := .t.
				EndIf
			Next nX
		Else
			MsgStop(STR0057+chr(13)+STR0058) //"A transação foi desfeita!"###"Nenhum movimento foi gerado."
		EndIf		
	Else
		MsgStop(STR0057+chr(13)+STR0058) //"A transação foi desfeita!"###"Nenhum movimento foi gerado."
	EndIf    
    
    If lRetorno	 
        MsgInfo(STR0064) ///"Romaneios gerados com sucesso!"
    EndIf	

	RestArea( aAreaAtu )

Return( lRetorno )

/** {Protheus.doc} GeraRomSimb
//"Gerando romaneio de entrada e Saída

@param: 	Nil
@return:	Nil
@author: 	Vitor Alexandre de Barba
@since: 	02/12/2014
@Uso: 		OG - Originação de Grãos
*/
Static Function GeraRomSimb( cModelo, cCodCtrRom, nQtdRom, cTpFormRom, cNFPSerRom, cNFPNumRom,;
	cCodTraRom, cCodVeRom, cMsgRom, cNFDataRom,;
	cNFNumeroRom, cNFSerieRom, cTesRom, cNFEspRom, cChNFERom,;	
	nNFVlrTot, nNFVlrUni, cLocalD, cTrnfDesp, cIdMov, nVlrFrete, cTipoFrete, pRomAuto )

	Local aAreaAtu 	:= GetArea()
	Local lRetorno	:= .t.
	Local cPlaca 	:= ""
	Local cTipo		:= ""
	Local cNewNJJ   := ""
	Local cItem		:= ""
	
	Default nVlrFrete  := 0
	Default cTipoFrete := "C"
	Default cIdmov     := CriaVar('NKM_IDMOV', .F. ) 
    	
	cTipoFrete := SUBSTR(cTipoFrete,1,1) //Tratamento do tipo de frete

	//Contrato
	dbSelectArea("NJR")
	NJR->( dbSetOrder( 1 ) )
	NJR->( dbSeek( FWxFilial( "NJR" ) + cCodCtrRom ) )

	dbSelectArea( "NJ0" )
	dbSetOrder( 1 )
	If .Not. dbSeek( FWxFilial( "NJ0" ) + NJR->( NJR_CODENT + NJR_LOJENT) )
		Return( Nil )
	EndIf
	//Veiculos
	DA3->( dbSetOrder( 1 ) )
	if DA3->( dbSeek( FWxFilial( "DA3" ) + cCodVeRom ) )
		cPlaca := DA3->( DA3_PLACA )
	EndIf

	//Transportadora 
	SA4->( dbSetOrder( 1 ) )
	If !SA4->( dbSeek( FWxFilial( "SA4" ) + cCodTraRom ) )
		cCodTraRom := ""
	EndIF

	If NJR->( NJR_TIPO ) = "1" 
		cTipo := if (cModelo = "D", "5", "8")
		cTipMod := If (cModelo = "D", "E", "S")
	EndIf
	If NJR->( NJR_TIPO ) = "2" 
		cTipo := If (cModelo = "D", "4", "9")
		cTipMod := If (cModelo = "D", "S", "E")
	EndIf
	If NJR->( NJR_TIPO ) = "3" 
		cTipo := If (cModelo = "D", "3", "6")
		cTipMod := If (cModelo = "D", "E", "S")
	EndIf
	If NJR->( NJR_TIPO ) = "4" 
		cTipo := If (cModelo = "D", "2", "7")
		cTipMod := If (cModelo = "D", "S", "E")
	EndIf    
   	
    cNewNJJ := GetSXENum('NJJ','NJJ_CODROM')
    If ( __lSx8 )
        ConfirmSX8()
    EndIf

	dbSelectArea( "NJJ" )
	If RecLock( "NJJ", .t. )
		NJJ->( NJJ_FILIAL ) := FWxFilial( "NJJ" )
		NJJ->( NJJ_CODROM ) := cNewNJJ
		NJJ->( NJJ_TIPO ) 	:= cTipo
		If cTipo $ "4|5" //Destino
			NJJ->( NJJ_FRETE ) := nVlrFrete
		ElseIf cTipo $ "8|9"
			NJJ->( NJJ_TPFRET) := cTipoFrete
		EndIF

		NJJ->( NJJ_CODENT ) := NJ0->( NJ0_CODENT )
		NJJ->( NJJ_LOJENT ) := NJ0->( NJ0_LOJENT )
		NJJ->( NJJ_ENTENT ) := NJ0->( NJ0_CODENT )
		NJJ->( NJJ_ENTLOJ ) := NJ0->( NJ0_LOJENT )
		NJJ->( NJJ_STATUS )	:= "1"
		NJJ->( NJJ_STSPES ) := "1"
		NJJ->( NJJ_STSCLA ) := "1"
		NJJ->( NJJ_STAFIS ) := "1"
		NJJ->( NJJ_TIPENT ) := "2"  
		NJJ->( NJJ_PLACA ) 	:= cPlaca
		NJJ->( NJJ_CODTRA ) := cCodTraRom
		NJJ->( NJJ_CODSAF ) := NJR->( NJR_CODSAF )
		NJJ->( NJJ_CODPRO )	:= NJR->( NJR_CODPRO )
		NJJ->( NJJ_UM1PRO )	:= NJR->( NJR_UM1PRO )
		NJJ->( NJJ_TABELA )	:= NJR->( NJR_TABELA )
		NJJ->( NJJ_LOCAL )  := cLocalD 
		NJJ->( NJJ_TPFORM ) := cTpFormRom
		NJJ->( NJJ_NFPSER ) := cNFPSerRom
		NJJ->( NJJ_NFPNUM ) := cNFPNumRom
		NJJ->( NJJ_QTDFIS ) := nQtdRom
		NJJ->( NJJ_PESO1 ) 	:= nQtdRom
		NJJ->( NJJ_PSSUBT ) := nQtdRom
		NJJ->( NJJ_PSBASE ) := nQtdRom 
		NJJ->( NJJ_PSLIQU ) := nQtdRom
		NJJ->( NJJ_MSGNFS ) := cMsgRom 
		NJJ->( NJJ_DATA ) 	:= dDataBase
		NJJ->( NJJ_DATPS1 ) := dDataBase
		NJJ->( NJJ_DATPS2 ) := dDataBase    
		NJJ->( NJJ_STACTR ) := "2"
		NJJ->( NJJ_TRSERV ) := cTrnfDesp

		If cTpFormRom = "2"
			NJJ->( NJJ_DOCSER ) 	:= cNFSerieRom
			NJJ->( NJJ_DOCNUM ) 	:= cNFNumeroRom
			NJJ->( NJJ_DOCEMI ) 	:= cNFDataRom
			NJJ->( NJJ_DOCESP ) 	:= cNFEspRom
			NJJ->( NJJ_CHVNFE ) 	:= cChNFERom
			NJJ->( NJJ_VLRUNI ) 	:= nNFVlrUni
			NJJ->( NJJ_VLRTOT ) 	:= nNFVlrTot
		EndIf

		If FieldPos("NJJ_PESO3") > 0
			NJJ->( NJJ_PESO3 ) := nQtdRom
		EndIf
		
		msUnLock()
	EndIf

	cItem := StrZero( 1, TamSX3( "NJM_ITEROM" )[1] )

	dbSelectArea( "NJM" )
	If RecLock( "NJM", .t. )
		NJM->( NJM_FILIAL ) := FWxFilial( "NJJ" )
		NJM->( NJM_CODROM ) := cNewNJJ
		NJM->( NJM_ITEROM ) := cItem 
		NJM->( NJM_TIPO )   := cTipo
		NJM->( NJM_CODCTR ) := cCodCtrRom
		NJM->( NJM_CODENT ) := NJ0->( NJ0_CODENT )
		NJM->( NJM_LOJENT ) := NJ0->( NJ0_LOJENT )
		NJM->( NJM_CODSAF ) := NJR->( NJR_CODSAF )
		NJM->( NJM_CODPRO ) := NJR->( NJR_CODPRO )
		NJM->( NJM_UM1PRO ) := NJR->( NJR_UM1PRO )
		If ColumnPos("NJM_GENMOD") > 0 .and. ColumnPos("NJR_GENMOD") > 0
			NJM->( NJM_GENMOD ) := NJR->( NJR_GENMOD )
		EndIf
		NJM->( NJM_MSGNFS ) := cMsgRom 
		NJM->( NJM_PERDIV ) := 100.00
		NJM->( NJM_STAFIS ) := "1"
		NJM->( NJM_TPFORM ) := cTpFormRom
		NJM->( NJM_NFPSER ) := cNFPSerRom
		NJM->( NJM_NFPNUM ) := cNFPNumRom
		NJM->( NJM_QTDFIS ) := nQtdRom
		NJM->( NJM_QTDFCO ) := nQtdRom
		NJM->( NJM_TES )    := cTesRom
		NJM->( NJM_LOCAL )  := cLocalD 
		NJM->( NJM_TRSERV ) := cTrnfDesp
		NJM->NJM_IDMOV		:= cIdMov 

		If cTpFormRom = "2"
			NJM->( NJM_DOCSER ) := cNFSerieRom
			NJM->( NJM_DOCNUM ) := cNFNumeroRom
			NJM->( NJM_DOCEMI ) := cNFDataRom
			NJM->( NJM_DOCESP ) := cNFEspRom
			NJM->( NJM_CHVNFE ) := cChNFERom
			NJM->( NJM_VLRUNI ) := nNFVlrUni
			NJM->( NJM_VLRTOT ) := nNFVlrTot
		EndIf

		msUnLock()
	EndIf

	aAdd( aRegNJJ, NJJ->( Recno() ) )
	If cModelo = "D"
		cTrfDst := NJJ->( NJJ_CODROM ) 
	Endif	

	RestArea( aAreaAtu )

Return( lRetorno )

/** {Protheus.doc} ValidQtdVlr
@param: 	Nil
@return:	Nil
@author: 	Ricardo Tomasi
@since: 	08/06/2010
@Uso: 		OG - Originação de Grãos
*/
Static Function ValidQtdVlr(cCond)
	Local cMsg := ""

	If nQtd <= 0 
		Help( , , STR0009, , STR0048, 1, 0 ) //"AJUDA"###"Quantidade não pode ser menor ou igual a ZERO."
		nQtd := 0
		Return	
	ElseIf nQtd > nQtdOrige - nQtdPend
		cMsg := STR0049 + CRLF + CRLF + STR0085 + cValToChar(nQtdOrige) + CRLF  //###"Quantidade não pode ser maior que a quantidade disponível." ###"Saldo contrato de origem: " 
		If nQtdPend > 0
			cMsg += STR0086 + cValToChar(nQtdPend) + CRLF 		 //###"Volume em romaneios não confirmados: "
			cMsg += STR0087 + cValToChar(nQtdOrige - nQtdPend)   // ###"Disponível para transferência: "     		
		EndIf		
				
		Help( , , STR0009, , cMsg, 1, 0 ) //"AJUDA"  
		nQtd := 0
		Return	
	Else 
		If cCond = '1'
			nNFVlrTot	:= NoRound((nQtd*nNFVlrUni),TamSX3( "NJM_VLRTOT" )[2])
		ElseIf cCond = '2'
			nNFVlrUni	:= Round((nNFVlrTot/nQtd),TamSX3( "NJM_VLRUNI" )[2])
		EndIf
	EndIf 

Return

/** {Protheus.doc} ValidNFFP

@param: 	Nil
@return:	Nil
@author: 	Agroindustria
@since: 	30/06/2016
@Uso: 		OG - Originação de Grãos
*/
Static Function ValidNFFP(cCodCtrRom)

	Local cAliasSF1 	:= GetNextAlias()

	If cFormProp = "Nao"

		If cTipoDest = STR0019			
			cTipoRom := "5"	//5=Entrada Compra 
		ElseIf cTipoDest = STR0008 
			cTipoRom := "3"	//3=Entrada Depos. 3 
		EndIf		

		//Retorna o Cliente ou Fornecedor, conforme o tipo do movimento do romaneio
		aRetClFr    := OGA250ClFr( cDCodEnt, cDLojEnt, cTESDest, cTipoRom, nQtd )
		cTipoNF     := aRetClFr[ 1 ]
		cCliFor     := aRetClFr[ 2 ]
		cLoja       := aRetClFr[ 3 ]

		BeginSql Alias cAliasSF1
		Select SF1.R_E_C_N_O_ as F1_RECNO 
		,SD1.R_E_C_N_O_ as D1_RECNO
		From %table:SD1% SD1
		Inner Join %table:SF1% SF1
		on SF1.F1_FILIAL  = SD1.D1_FILIAL 
		And SF1.F1_DOC     = SD1.D1_DOC
		And SF1.F1_SERIE   = SD1.D1_SERIE
		And SF1.F1_FORNECE = SD1.D1_FORNECE
		And SF1.F1_LOJA    = SD1.D1_LOJA
		And SF1.F1_TIPO    = SD1.D1_TIPO
		And SF1.%NotDel%
		Where SD1.D1_FILIAL  = %xFilial:SD1% 
		And SD1.D1_DOC     = %Exp:cNFNumero%
		And SD1.D1_SERIE   = %Exp:cNFSerie%
		And SD1.D1_FORNECE = %Exp:cCLiFor%
		And SD1.D1_LOJA    = %Exp:cLoja%
		And SD1.D1_TIPO    = %Exp:cTipoNF%
		And SD1.%NotDel%
		EndSql

		(cAliasSF1)->( dbGoTop() )
		If !(cAliasSF1)->( Eof() )	

			DbSelectArea( "SD1" )
			DbGoTo( (cAliasSF1)->( D1_RECNO ) )

			//busca o contrato
			dbSelectArea("NJR")
			NJR->( dbSetOrder( 1 ) )
			NJR->( dbSeek( FWxFilial( "NJR" ) + cCodCtrRom ) )

			// Verifica se a quantidade da NF fecha com a quantidade do Romaneio
			If SD1->( D1_QUANT ) <> nQtd
				MsgAlert(STR0061)	//"Não será possível associar Romaneio à Nota Fiscal já gerada, pois a Quantidade Fiscal do Romaneio difere da Quantidade da NF"        				
				(cAliasSF1)->( dbCloseArea( ) )
				Return( .F. )
			EndIf

			// Verifica se o Produto do Romaneio é o mesmo da NF
			If SD1->( D1_COD ) <> NJR->( NJR_CODPRO )
				MsgAlert(STR0062) //Não será possível associar Romaneio à Nota Fiscal já gerada, pois o Produto do Romaneio difere do Produto da NF.
				(cAliasSF1)->( dbCloseArea( ) )
				Return( .F. )
			EndIf

			// Verifica NF informada não pertence a outro romaneio
			If ! Empty( SD1->( D1_CODROM ) )
				DbSelectArea( "NJJ" )
				DbSetOrder( 1 )
				If DbSeek( xFilial( "NJJ" ) + SD1->( D1_CODROM ) )
					If NJJ->( NJJ_STATUS ) $ "2|3" 	// 2=Atualizado; 3=Confirmado
						MsgAlert(STR0063 + ": " + SD1->( D1_CODROM )) //Não será possível associar Romaneio à Nota Fiscal já gerada, pois a NF informada já está associada a outro romaneio. Romaneio      
						(cAliasSF1)->( dbCloseArea( ) )
						Return( .F. )
					EndIf
				EndIf
			EndIf

		endIf /*busca SF1*/
		(cAliasSF1)->( dbCloseArea( ) )
	endif /*Form Prop*/

Return(.t.)

/** {Protheus.doc} OGA450VALINF

@param: 	Nil
@return:	Nil
@author: 	Ana Laura Olegini
@since: 	04/12/2014
@Uso: 		OG - Originação de Grãos
*/
Static Function OGA450VALLOC()

	Local lRetValInf := .T.

	If cLocalO = ""
		Help( , , STR0009, , STR0050, 1, 0 ) //"AJUDA"###"Local deve ser informado!"
		lRetValInf := .F.
		cLocalO := Space( TamSX3( "NJJ_LOCAL"  )[1] )
	EndIf

Return 

/** {Protheus.doc} OGA450VALCTR
-> VALIDACOES DE TELA - PARA CONTRATO
@author: 	Ana Laura Olegini
@since: 	04/12/2014
@Uso: 		OG - Originação de Grãos
**/
Static Function OGA450VALCTR(cNCtr)

	If cNCtr = '1'
		dbSelectArea("NJR")
		dbSetOrder(1)
		If dbSeek(xFilial("NJR")+cOCodCtr)

			If NJR->NJR_TIPO = "3"	//*Somente p/ 3=Armazenagem De 3
				lEdtDesp := .T.
			Else
				lEdtDesp := .F.
			EndIf
		EndIf

	ElseIf cNCtr = '2'

		If cOCodCtr = cDCodCtr
			Help( , , STR0009, , STR0051 +": "+ cDCodCtr, 1, 0 ) //"AJUDA"###"Contrato Destino deve ser diferente do Contrato Origem"
			cDCodCtr	:= Space( TamSX3("NJR_CODCTR")[1] )
			cDNomCtr	:= Space( TamSX3("NJR_DESCRI")[1] )
			Return( .F. )
		EndIf

		If Posicione( "NJR", 1, xFilial( "NJR" ) + cDCodCtr, "NJR_TIPO" ) $ "2|4"
			Help( , , STR0009, , STR0052 +": "+ cDCodCtr, 1, 0 ) //"AJUDA"###"Contrato Destino somente contratos de Compra ou Armazenagem De 3."
			cDCodCtr	:= Space( TamSX3("NJR_CODCTR")[1] )
			cDNomCtr	:= Space( TamSX3("NJR_DESCRI")[1] )
			Return( .F. )
		EndIf		

		cPSafra  := Posicione( "NJR", 1, xFilial( "NJR" ) + cOCodCtr, "NJR_CODSAF" )
		cPCodPro := Posicione( "NJR", 1, xFilial( "NJR" ) + cOCodCtr, "NJR_CODPRO" )
		cPCodEnt := Posicione( "NJ0", 1, xFilial( "NJ0" ) + cDCodEnt, "NJ0_CODENT" )
		cPLojEnt := Posicione( "NJ0", 1, xFilial( "NJ0" ) + cDLojEnt, "NJ0_LOJENT" )

		DbSelectArea( "NJR" )
		DbSetOrder( 1 ) 
		If DbSeek( xFilial( "NJR" ) + cDCodCtr )
			If NJR->( NJR_CODSAF ) <> cPSafra
				Help( , , STR0009, , STR0053 +": "+ cDCodCtr, 1, 0 ) //"AJUDA"###"Contrato Destino não pode ter Safra diferente."
				cDCodCtr	:= Space( TamSX3("NJR_CODCTR")[1] )
				cDNomCtr	:= Space( TamSX3("NJR_DESCRI")[1] )
				Return( .F. )
			EndIf

			If NJR->( NJR_CODPRO ) <> cPCodPro
				Help( , , STR0009, , STR0054 +": "+ cDCodCtr, 1, 0 ) //"AJUDA"###"Contrato Destino não pode ter Produto diferente."
				cDCodCtr	:= Space( TamSX3("NJR_CODCTR")[1] )
				cDNomCtr	:= Space( TamSX3("NJR_DESCRI")[1] )
				Return( .F. )
			EndIf

			cDNomCtr  := NJR->( NJR_DESCRI )	
		Else 
			Return( .F. )	
		EndIf

	EndIf

	lRefresh := .T.
Return 

/** {Protheus.doc} ValEntidade()
Valida a entidade

@param: 	pcEntidade		Recebe cCodEnt sozinho ou acompanhado de cLojEnt
@author: 	Marlon Richard Trettin
@since: 	28/10/14
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function ValEntidade( pcCodEnt, pcLojEnt )

	DbSelectArea( "NJ0" )
	DbSetOrder( 1 ) 
	If DbSeek( xFilial( "NJ0" ) + pcCodEnt + iIf( !Empty( AllTrim( pcLojEnt ) ), pcLojEnt, "" ) )

		If !Empty(cDCodEnt)
			cDNomEnt := NJ0->( NJ0_NOME )
		EndIf

	Else
		Return( .F. )
	EndIf

Return( .T. )



/** {Protheus.doc} fVldTpMv()
Valida o Tipo de Movimento

@param: 	cTpMv - Id do Tipo de Movimento
@author: 	Emerson
@since: 	28/12/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static function fVldTpMv( cTpMv )
	Local lOk 		:= .t.
	Local aAreaAtu	:= GetArea()
	Local aAreaNKL	:= NKL->( GetArea() )

	IF !Empty( cTpMv )
		DbSelectArea( "NKL" )
		NKL->( DbSetOrder( 1 ) ) 
		If NKL->( DbSeek( xFilial( "NKL" ) + cTpMv ))
			cNKMDESTIP := NKL->NKL_DESCRI
		Else
			Help( , , STR0009, , STR0069, 1, 0 ) //"AJUDA"###"Informar Entidade para Transferencia."	
			lOk :=.f.
		EndIf
	Else
		cNKMDESTIP := '' 
	EndIf

	RestArea( aAreaAtu )
	RestArea( aAreaNKL )

Return( lok )

/** {Protheus.doc} fGetTpMv()
Identifica se o tipo de movto para
transferencias simples esta informado no parametro
MV_OGCTRMV, Se Sim, indica que deve gerar o id de
controle de movto senão é pq não controla e então
não se gera tabela de movtos.

@param: 	nil.
@author: 	Emerson
@since: 	28/12/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fGetTpMv()
	Local cMvOgCtrMv	:= SuperGetMV("MV_OGCTRMV",.F.,'')
	Local aAux			:= Separa(cMvOgCtrMv, ';')
	Local cCodTpMv		:= ''
	Local nX			:=0
	Local nPosTRFS		:=0

	For nX := 1 to Len(aAux) Step 1
		IF Upper( SUBSTR(aAux[nX],1,at('|', aAux[nX]) - 1)) == 'TRFS' //TRFS Identificação de Transferencia Simples
			nPosTRFS := nX
			Exit 
		EndIF
	nExt nX

	IF nPosTRFS == 0  // Indica Q não utiliza
		cNKMTIPOMV := ' '
		cNKMDESTIP := STR0066 	//'Não Utilizado'
	ElseIF nPosTRFS > 0
		cCodTPMV := Substr(aAux[ nPosTRFS ],at('|', aAux[ nPosTRFS ]) + 1,Len(aAux[ nPosTRFS]))

		cNKMTIPOMV := cCodTPMV
		cNKMDESTIP := STR0066	//'Não Utilizado'

		IF ! Empty(cCodTpMv)
			DbSelectArea( "NKL" )
			cNKMTIPOMV := cCodTPMV 
			NKL->( DbSetOrder( 1 ) ) 
			If NKL->( DbSeek( fWxFilial( "NKL" ) + cCodTPMV ))
				cNKMTIPOMV := cCodTPMV
				IF Alltrim( NKL->NKL_ATIVO ) == '1'
				   cNKMDESTIP := NKL->NKL_DESCRI
				Else
				   cNKMDESTIP := STR0067 + 	STR0068	//'Inválido' + '( Tp. Movto Inativo )'
				EndIF
			Else
				cNKMDESTIP := STR0067
			EndIF
		EndIF
	EndIF

Return( )

/** {Protheus.doc} fGerMvID()
Função que Gera um registro de movto
na tabela de movtos do OG.
(Utilizado qdo empresa decide que o processo de transf simples
deve gerar um controle de movtos.)

@param: 	Tipo do Movto.
@Return:    o id do movto a ser Gerado;
@author: 	Emerson
@since: 	28/12/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function fGerMvID( cNKMTpMv)
	Local cIdMv := ''
	Local cMsg	:= ''

	oMdlNKM := FWLoadModel( "OGA440" )
	oMdlNKM:SetOperation( MODEL_OPERATION_INSERT )
	oMdlNKM:Activate()
	oNKM:= oMdlNKM:GetModel( "NKMUNICO" )


	lRet:= oNKM:SetValue( "NKM_FILIAL"  ,   fwXfilial("NKM")	)
	lRet:= oNKM:SetValue( "NKM_TIPOMV"  ,   cNKMTpMv 			)
	///lRet:= oNKM:SetValue( "NKM_STATUS"  ,   '3' 				)   // Status de Encerrada


	If ( lRet:=oMdlNKM:VldData() )
		oMdlNKM:CommitData()
		lContinua := .t.
		cIdMV := FWFLDGET('NKM_IDMOV')   // Identificando o Id do Movto a Ser Gerado
	Else
		cMsg := oMdlNKM:GetErrorMessage()[3] + oMdlNKM:GetErrorMessage()[6]
		Help( ,,STR0009,,cMsg, 1, 0 ) //"Ajuda"
		lContinua := .F.
	EndIf
	oMdlNKM:DeActivate()

Return ( cIdMV )

/*/{Protheus.doc} OGA450BRomPd
	Verifica saldo de romaneios de devolução que ainda não estejam confirmados.
	@type  Static Function
	@author user
	@since 28/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OGA450BRomPd(cCtr, cTipos)
 Local cAliasQ   := GetNextAlias()
 Local nPesoPend := 0

 BeginSql Alias cAliasQ
	SELECT SUM(NJJ_PSLIQU) NJJ_PSLIQU
	 FROM %table:NJJ% NJJ
	INNER JOIN %table:NJM% NJM ON NJM.NJM_FILIAL = NJJ.NJJ_FILIAL AND NJM.NJM_CODROM = NJJ.NJJ_CODROM AND NJM.%notDel%
	WHERE NJJ.NJJ_FILIAL = %xFilial:NJJ%
	  AND NJJ.NJJ_STATUS IN ("0", "1") //Pendente, Completo
	  AND NJM.NJM_CODCTR = %Exp: cCtr%	  
	  AND NJM.NJM_TIPO   IN ( %Exp:cTipos%)
	  AND NJJ.%notDel%
 EndSql 

 If (cAliasQ)->NJJ_PSLIQU > 0
 	nPesoPend := (cAliasQ)->NJJ_PSLIQU
 EndIf

 (cAliasQ)->(dbCloseArea())
	
Return nPesoPend

/*/{Protheus.doc} fTesIntel
    Função para buscar a TES Inteligente
    @type  Static Function
    @author user
    @since 26/08/2020
    @version version
    @param cTipoTes, char, Tipo de TES a ser buscada ("DEV" - DEVOLUÇÃO | "DEST" - DESTINO)
    @return nil    
    /*/
Static Function fTesIntel()
    
    Local cProduto    as char    
    Local cMsgRetErro as char    
    Local lRet        as logical

    If lRet := fVldOpFis()
        If READVAR() == "COPFISDEV" .and. !Empty(cOpFisDev) 
            cProduto := Posicione( "NJR", 1, xFilial( "NJR" ) + cOCodCtr, "NJR_CODPRO" )        
            cTesDev  := AGRXTESINT(.F., @cMsgRetErro, cOCodEnt, cOLojEnt, cOpFisDev, "2", cProduto)
        ElseIf READVAR() == "COPFISDEST" .and. !Empty(cOpFisDest) 
            cProduto := Posicione( "NJR", 1, xFilial( "NJR" ) + cOCodCtr, "NJR_CODPRO" )        
            cTESDest := AGRXTESINT(.F., @cMsgRetErro, cDCodEnt, cDLojEnt, cOpFisDest, "1", cProduto)
        EndIf

        If !Empty(cMsgRetErro)         
            AgrHelp(STR0009,cMsgRetErro,STR0090) //#"Verifique o cadastro da TES Inteligente."            
            lRet := .F.
        EndIf        
    EndIf
    
Return lRet

/*/{Protheus.doc} fVldOpFd
    Validação do campo de código operação destino.
    @type  Static Function
    @author user
    @since 26/08/2020
    @version version    
    /*/
Static Function fVldOpFis()
    
    If !Vazio()        
        If READVAR() == "COPFISDEST"
            If Empty(cDCodEnt) .or. Empty(cDLojEnt)
                AgrHelp(STR0009,STR0088,STR0089) //#"O código da entidade ou da loja de destino não foram informados." #"É necessário informar a entidade e loja de destino para buscar a TES Inteligente."
                Return .F.
            EndIf        
        EndIf
    EndIf

Return (Vazio() .or. ExistCpo('SX5','DJ'+&(READVAR())))
