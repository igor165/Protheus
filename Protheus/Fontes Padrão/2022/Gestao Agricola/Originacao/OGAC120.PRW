#INCLUDE "OGAC120.ch"
#INCLUDE "protheus.ch"
#INCLUDE "fwmvcdef.ch"

/*/{Protheus.doc} OGAC120
Tela de consulta de Saldos do Produto
@type  Function
@author rafael.kleestadt
@since 22/03/2018
@version 1.0
@param cCodProd, caracter, código do produto a ser exibido
@param cCodFilial, caracter, código da filial do produto
@return returno, return_type, return_description
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=287072658
/*/
Function OGAC120(cCodProd, cCodFilial)
	Local aCords 	 := FWGetDialogSize( oMainWnd )
	Local oDlg		 := Nil
	Local oFwLayer   := Nil
	Local nX         := 0
	
	Local aRetTRB := {} // Variável que recebe o retorno da criação das tabelas temporárias
	
	//--- Definição da estrutura da tabela temporária de Titulos - NF ---//
	Local aEstruSld := { { "T_FILIAL" , "C", TamSX3("B2_FILIAL")[ 1 ],    0, RetTitle("B2_FILIAL"),  PesqPict("SB2","B2_FILIAL")},;
						 { "T_CODPRO" , "C", TamSX3("B2_COD")[ 1 ],       0, RetTitle("B2_COD"),     PesqPict("SB2","B2_COD")},;
                         { "T_DESPRO" , "C", TamSX3("B2_DPROD")[ 1 ],     0, RetTitle("B2_DPROD"),   PesqPict("SB2","B2_DPROD")},;
                         { "T_CODARM" , "C", TamSX3("B2_LOCAL")[ 1 ],     0, RetTitle("B2_LOCAL"),   PesqPict("SB2","B2_LOCAL")},;
						 { "T_DESARM" , "C", TamSX3("NNR_DESCRI"  )[ 1 ], 0, RetTitle("NNR_DESCRI"), PesqPict("NNR","NNR_DESCRI")},;
						 { "T_LOTE"   , "C", TamSX3("B8_LOTECTL")[ 1 ] ,  0, RetTitle("B8_LOTECTL"), PesqPict("SB8","B8_LOTECTL")},;
	 					 { "T_SUBLOT" , "C", TamSX3("B8_NUMLOTE")[ 1 ] ,  0, RetTitle("B8_NUMLOTE"), PesqPict("SB8","B8_NUMLOTE")},;
	 					 { "T_DVALOT" , "D", 8                        ,   0, RetTitle("B8_DTVALID"), "@D"},;
	 					 { "T_SALDAT" , "N", TamSX3("B2_QATU")[ 1 ],      0, RetTitle("B2_QATU"),    PesqPict("SB2","B2_QATU")} }
						 
	Local aCpBrwSld := {}
	Local aIndSld   := { "T_FILIAL+T_CODPRO+T_CODARM+T_LOTE","T_CODPRO","T_CODARM","T_LOTE","T_SUBLOT" } // Definição dos índices
	//Removido o índice 2(T_FILIAL), pois o mesmo já era atendido pelo índice 1 
	
	//--- Variáveis de acesso às tabelas temporárias ---//
	Private cAliasSld 
	Private cTrabSld	 
	Private oBrwSld 
	Private aIndice1
    Private _cCodProd   := cCodProd
    Private _cCodFilial := cCodFilial

	If Empty(_cCodProd)
		Help(" ", 1, ".OGAC12000001.")//Problema: "Não foi informado um produto para esta consulta."
		Return .T.                    //Solução: "Informe um produto para realizar a consulta do saldo."
	EndIf
		
	//--- Criação das tabelas temporárias ---//
	
	// Tabela temporária de Saldos
	aRetTRB := AGRCRIATRB( , aEstruSld, aIndSld, FunName(), .T. )
	 
	cTrabSld 	:= aRetTRB[3] //Nome do arquivo temporário 
	cAliasSld  	:= aRetTRB[4] //Nome do alias do arquivo temporario
	aCpBrwSld 	:= aRetTRB[5] //Matriz com a estrutura do arquivo temporario + label e picutre
	
	aIndice1	:= AGRINDICONS(aIndSld , aCpBrwSld  )	
	
	//primeira carga na tabela
	OG120LDSLD()
	
	//--- Montagem da tela ---//
	oDlg := TDialog():New( aCords[ 1 ], aCords[ 2 ], aCords[ 3 ], aCords[ 4 ], STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Saldo do Produto" 

	//--- Layers ---//
	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlg, .f., .t. )

	// Saldos
	oFWLayer:AddLine( 'LinTitulo', 100, .F. )
	oFWLayer:AddCollumn( 'ColTitulo', 100, .T., 'LinTitulo' )
	oPnSld := oFWLayer:GetColPanel( 'ColTitulo', 'LinTitulo' )
		
	//--- Conteúdo dos panels ---// 
	DEFINE FWFORMBROWSE oBrwSld DATA TABLE ALIAS cAliasSld DESCRIPTION STR0001 OF oPnSld //Títulos //"Saldo do Produto"
	    oBrwSld:SetTemporary(.T.)
		oBrwSld:SetdbFFilter(.T.)
		oBrwSld:SetUseFilter(.T.)	
		oBrwSld:SetFieldFilter(AGRITEMCBRW(aCpBrwSld))	
		oBrwSld:SetSeek(,aIndice1)
		oBrwSld:SetDetails(.T.)
		
 		For nx := 1 To Len(aCpBrwSld)			
		    nTamCpoIDX	:= 1
		    If !(aCpBrwSld[nX,2] == "C")
		    	nTamCpoIDX	:= 0.80			// Indice para Manipulação do tamanho do campo (0.50 Indica que irá utilizar 50 % do tamanho )
		    EndIF
            ADD COLUMN oColumn 	DATA 	&('{||'+aCpBrwSld[nX,1]+'}');
                                Title	aCpBrwSld[nX,5];
                                SIZE	aCpBrwSld[nX,3] * nTamCpoIDX;
                                PICTURE	aCpBrwSld[nX,6];
                                Align	IIf(aCpBrwSld[nX,2] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT);
                                Of oBrwSld		
		Next nx 
		oBrwSld:DisableDetails()
		
		oBrwSld:DisableDetails()		
		oBrwSld:AddButton("Sair" ,	{|| oDlg:End() }	,,,,,,'31')	//"Sair"
	
	ACTIVATE FWFORMBROWSE oBrwSld

	oDlg:Activate( , , , .t., { || .t. }, , { || } )
	
	//--- Apaga as tabelas temporárias ---//
	AGRDELETRB( cAliasSld, cTrabSld )  
	 
Return .T.

/*/{Protheus.doc} OG120LDSLD()
Função que realiza a busca dos registros e carrega a tabela temporaria de saldos do produto
@type  Static Function
@author rafael.kleestadt
@since 22/03/2018
@version 1.0
@param param, param_type, param_descr
@return returno,return_type, return_description
@example
(examples)
@see http://tdn.totvs.com/pages/viewpage.action?pageId=287072658
/*/
Static Function OG120LDSLD()
	Local aAreaAtu	:= GetArea()
	Local cAliasQry	:= GetNextAlias()
    Local lContLt   := Posicione("SB1", 1, FwXFilial("SB1")+_cCodProd, "B1_RASTRO") <> "N" .And. SuperGetMv('MV_RASTRO', , .F.) == 'S'
	
	//--- Apaga conteúdo anterior da tabela temporária CTR ---//
	fZapTRB( cAliasSld )

    If lContLt //Controla produto por lote 

        cQuery := " SELECT SB8.B8_FILIAL AS FILIAL,  "
        cQuery += "        SB8.B8_PRODUTO AS PRODUTO, "
        cQuery += "        SB8.B8_LOCAL AS ARMAZEM, "
        cQuery += "        SB8.B8_LOTECTL AS LOTE, "
        cQuery += "        SB8.B8_NUMLOTE AS SUBLOTE, "
        cQuery += "        SB8.B8_DTVALID AS DTVALID, "
        cQuery += "        SB8.B8_SALDO AS SALDO "
        cQuery += "   FROM " + RetSqlName("SB8") + " SB8 "
        cQuery += "  WHERE SB8.B8_PRODUTO  = '" + _cCodProd + "' "
        cQuery += "    AND SB8.D_E_L_E_T_ = ' ' "
        
        If .Not. Empty(_cCodFilial)
        	cQuery += " AND SB8.B8_FILIAL = '"+ _cCodFilial +"'"
        EndIf
    
    Else

        cQuery := " SELECT SB2.B2_FILIAL AS FILIAL,  "
        cQuery += "        SB2.B2_COD AS PRODUTO, "
        cQuery += "        SB2.B2_LOCAL AS ARMAZEM, "
        cQuery += "        SB2.B2_QATU AS SALDO "
        cQuery += "   FROM " + RetSqlName("SB2") + " SB2 "
        cQuery += "  WHERE SB2.B2_COD  = '" + _cCodProd + "' "
        cQuery += "    AND SB2.D_E_L_E_T_ = ' ' "

        If .Not. Empty(_cCodFilial)
        	cQuery += " AND SB2.B2_FILIAL = '"+ _cCodFilial +"'"
        EndIf

    EndIf
	
	cQuery := ChangeQuery(cQuery)
    dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
    DbselectArea( cAliasQry )
    (cAliasQry)->(DbGoTop())

	While ( cAliasQry )->( !Eof() )
					
		RecLock( cAliasSld, .T. )
		    ( cAliasSld )->T_FILIAL  := (cAliasQry)->FILIAL 
			( cAliasSld )->T_CODPRO  := (cAliasQry)->PRODUTO
			( cAliasSld )->T_DESPRO  := Posicione('SB1',1,xFilial('SB1')+(cAliasQry)->PRODUTO,'B1_DESC')
			( cAliasSld )->T_CODARM  := (cAliasQry)->ARMAZEM  
			( cAliasSld )->T_DESARM	 := Posicione('NNR',1,xFilial('NNR')+(cAliasQry)->ARMAZEM,'NNR_DESCRI')
			( cAliasSld )->T_LOTE    := IIF(lContLt, (cAliasQry)->LOTE, "")
			( cAliasSld )->T_SUBLOT  := IIF(lContLt, (cAliasQry)->SUBLOTE, "" )
			( cAliasSld )->T_DVALOT  := IIF(lContLt, StoD((cAliasQry)->DTVALID), NIL) 
			( cAliasSld )->T_SALDAT  := (cAliasQry)->SALDO
			
		( cAliasSld )->( MsUnLock() )
        
		( cAliasQry )->( DbSkip() )
	EndDo
	( cAliasQry )->( DbCloseArea() )
	
	If Type("oBrwSld") <> "U"
		oBrwSld:Refresh(.T.)
	EndIf
	
	RestArea( aAreaAtu )

Return()


/*{Protheus.doc} fZapTRB

@author 	Tamyris Ganzenmueller
@since 		27/07/2017
@version 	1.0
@param 		Nil
@return 	Nil
*/
Static Function fZapTRB( pcAliasTRB )
    Local aAreaAtu         := GetArea()
    
    If Select( pcAliasTRB ) > 0
        DbSelectArea( pcAliasTRB )
        Zap
    Endif
    
    RestArea( aAreaAtu )
Return( NIL )
