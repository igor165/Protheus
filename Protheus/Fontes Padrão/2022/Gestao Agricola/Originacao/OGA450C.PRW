#include "protheus.ch"
#INCLUDE "PRCONST.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "OGA450C.CH"

/*{Protheus.doc} OGA450C
//TODO Descrição auto-gerada.
@author jean.schulze
@since 25/08/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilCtr, characters, descricao
@param cCodCtr, characters, descricao
@type function
*/
Function OGA450C(cFilCtr, cCodCtr)
	Local aArea		  := GetArea()
	Local aAreaNJR	  := NJR->(GetArea())
	Local aCoors      := FWGetDialogSize( oMainWnd )
	Local oSize       := {}
	Local oFWL        := ""
	Local oDlg		  := Nil
	Local oPnl1       := Nil
	Local oPnlWnd1    := Nil
	Local oPnlWnd2	  := Nil 
	Local oBrwPend    := Nil
	Local oBrwResol   := Nil
	Local aFilBrwPen  := {}
	Local nCont       := 0
	Local bColor02    := {||}
	Local aCpsBrowPen := {}
	Local aCpsTabPen  := {}	
	
	Private _cTabPen  := ""
	Private _cTipCtr := ""
	
	//validação tipo de contrato
	dbSelectArea( "NJR" ) // Contratos
	NJR->(dbSetOrder( 1 ))
	If NJR->(dbSeek( cFilCtr + cCodCtr ))
		_cTipCtr := NJR->NJR_TIPO
	EndIF
	RestArea(aAreaNJR) //restaura a area NJR

	If !(_cTipCtr $ "1|2")
		AgrHelp(STR0016, STR0034, STR0035) //##"Função não disponivel para este tipo de contrato." ###"Função disponivel somente para contratos de compra ou venda.")
		Return
	EndIf

	//montagem da tabela de pendencias
	aCpsBrowPen := {{STR0001  , "MARK"	, "C", 1,, "@!"},; //control utilização
					{STR0002  , "NC8_PENDEN"	, TamSX3( "NC8_PENDEN" )[3]	, TamSX3( "NC8_PENDEN" )[1]	, TamSX3( "NC8_PENDEN" )[2]	, PesqPict("NC8","NC8_PENDEN") },; 
					{STR0003  , "NC8_FILIAL"	, TamSX3( "NC8_FILIAL" )[3]	, TamSX3( "NC8_FILIAL" )[1]	, TamSX3( "NC8_FILIAL" )[2]	, PesqPict("NC8","NC8_FILIAL") },; 
					{STR0004  , "NC8_CODROM"	, TamSX3( "NC8_CODROM" )[3]	, TamSX3( "NC8_CODROM" )[1]	, TamSX3( "NC8_CODROM" )[2]	, PesqPict("NC8","NC8_CODROM") },; 
					{STR0005  , "NC8_ITEMRO"	, TamSX3( "NC8_ITEMRO" )[3]	, TamSX3( "NC8_ITEMRO" )[1]	, TamSX3( "NC8_ITEMRO" )[2]	, PesqPict("NC8","NC8_ITEMRO") }}   
	
	aCpsTabPen := aClone(aCpsBrowPen)
	aAdd(aCpsTabPen, {STR0026  , "NC8_STATUS", TamSX3( "NC8_STATUS" )[3]	, TamSX3( "NC8_STATUS" )[1]	, TamSX3( "NC8_STATUS" )[2]	, PesqPict("NC8","NC8_STATUS") }) //SIT.
    Processa({|| _cTabPen := MonTabela(aCpsTabPen, {{"", "NC8_FILIAL+NC8_CODROM+NC8_ITEMRO"}})},STR0006)
	Processa({|| fGetDados(cFilCtr, cCodCtr)},STR0007)
	
	//tamanho da tela principal
	oSize := FWDefSize():New(.f.) //considerar o enchoice
	oSize:AddObject('DLG',100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.
	oSize:aMargins := {0,0,0,0}
	oSize:Process()
	
	oDlg := MsDialog():New(  oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], STR0008, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) 
	oPnl1:= tPanel():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],,oDlg,,,,,,oSize:aPosObj[1,4] - 3,oSize:aPosObj[1,3])
	    
	// Instancia o layer
	oFWL := FWLayer():New()
	// Inicia o Layer
	oFWL:init( oPnl1, .F., .t. )
	
	// Cria as divisões horizontais
	oFWL:addLine('TOP'   , 60, .F.)
	oFWL:addLine('BOTTOM', 40, .F.)
	oFWL:addCollumn( 'CENTRAL-TOP', 100,.F., 'TOP' )
	oFWL:addCollumn( 'CENTRAL-BOT', 100,.F., 'BOTTOM' )
			
	// Recupera os Paineis das divisões do Layer
	oPnlWnd1:= oFWL:GetColPanel( 'CENTRAL-TOP' , 'TOP' )
	oPnlWnd2:= oFWL:GetColPanel( 'CENTRAL-BOT', 'BOTTOM' )
	
	/****************** Pendencias ********************************/
	//adicionando os widgets de tela
	oBrwPend := FWMBrowse():New()    
	oBrwPend:SetAlias(_cTabPen)
	oBrwPend:DisableDetails()
	oBrwPend:SetMenuDef( "" )    
	oBrwPend:DisableReport(.T.) 
	oBrwPend:SetDescription( STR0009 )
	oBrwPend:SetProfileID("OGA450C1")
	oBrwPend:AddButton(STR0010,	{|| OGA450CFIX(cFilCtr, cCodCtr), oBrwPend, oBrwPend:UpdateBrowse(), oBrwResol:UpdateBrowse()},,,,,,'01')	
	oBrwPend:AddButton(STR0011,	{|| oDlg:End() },,,,,,'02')
	   
	oBrwPend:AddMarkColumns( { ||Iif(  (_cTabPen)->MARK = "1" ,"LBOK","LBNO" ) },{ || fBrwDBClck(), fUpdBrowse(oBrwPend, .f.)   }, { || fBrwHeadCK(), fUpdBrowse(oBrwPend, .t.)  } )     
	
	//legenda
	oBrwPend:AddLegend( "NC8_PENDEN == '1'", "ORANGE" , STR0012) 	//"Fixação"
	oBrwPend:AddLegend( "NC8_PENDEN == '2'", "YELLOW" , STR0013) 	//"Cotação"
	oBrwPend:AddLegend( "NC8_PENDEN == '3'", "RED"    , STR0014) 	//"Cotação e Fixação"

	bColor02 := { || Iif((_cTabPen)->NC8_STATUS=='1','BR_VERMELHO', 'BR_VIOLETA')}
	ADD STATUSCOLUMN oColumn DATA bColor02 DOUBLECLICK { |oBrwPend| OGA450CLeg() }  OF oBrwPend	
	oBrwPend:aColumns[2]:cTitle := STR0026 //'Sit.'	
	oBrwPend:aColumns[2]:nalign := 1
	     
	For nCont := 3  to Len(aCpsBrowPen) //desconsiderar MARK, STATUS, QTD_FARDO, MENSAGEM
	    oBrwPend:AddColumn( {aCpsBrowPen[nCont][1]  , &("{||"+aCpsBrowPen[nCont][2]+"}") ,aCpsBrowPen[nCont][3],aCpsBrowPen[nCont][6],1,aCpsBrowPen[nCont][4],aCpsBrowPen[nCont][5],.f.} )
	    aADD(aFilBrwPen,  {aCpsBrowPen[nCont][2], aCpsBrowPen[nCont][1], aCpsBrowPen[nCont][3], aCpsBrowPen[nCont][4], aCpsBrowPen[nCont][5], aCpsBrowPen[nCont][6] } )
	Next nCont
	
	oBrwPend:SetFieldFilter(aFilBrwPen)
	
	oBrwPend:Activate(oPnlWnd1)   

	
	/****************** Resolvidos ********************************/
	oBrwResol := FWMBrowse():New()
	oBrwResol:DisableReport(.T.) 
	oBrwResol:DisableDetails()
	oBrwResol:SetAlias("NC8")
	oBrwResol:SetMenuDef( "" )
	oBrwResol:DisableReport(.T.) 
	oBrwResol:SetProfileID("OGA450C2") 
	oBrwResol:SetDescription( STR0015 )
	oBrwResol:SetFilterDefault("NC8_FILCTR= '"+cFilCtr+"' .AND. NC8_CODCTR = '"+cCodCtr+"' .AND. NC8_STATUS = '2' .AND. NC8_PENDEN <= '3' " )
	
	//legenda			
	oBrwResol:AddLegend( "NC8_PENDEN == '1'", "ORANGE" , STR0012) 
	oBrwResol:AddLegend( "NC8_PENDEN == '2'", "YELLOW" , STR0013) 	
	oBrwResol:AddLegend( "NC8_PENDEN == '3'", "RED"    , STR0014)
	
	oBrwResol:Activate(oPnlWnd2)
	
	//coloca o browser principal em foco e posicionado
	oBrwPend:SetFocus()	
	oBrwPend:GoColumn(1) 
	
	oDlg:Activate( , , , .t., , ,   ) //ativa a tela	
	
	RestArea(aArea)	
return .t.

/** {Protheus.doc} OGA450CLeg
Legenda para o status da pendência

@param.:  Nil
@return:  Nil
@author:  Rafael Völtz
@since.:  02/02/2018
@Uso...:  OGA700Leg - Negócio
*/
Static Function OGA450CLeg()
	Local oLegenda  :=  FWLegend():New()     // Objeto FwLegend.
		
	oLegenda:Add( "NC8_STATUS=='1'"  , "BR_VERMELHO"     , X3CboxDesc( "NC8_STATUS", "1" )   ) //"Pendente"
	//oLegenda:Add( "NC8_STATUS=='2'"  , "BR_VERDE"    	 , X3CboxDesc( "NC8_STATUS", "2" )   ) //"Resolvido
	oLegenda:Add( "NC8_STATUS=='3'"  , "BR_VIOLETA"      , X3CboxDesc( "NC8_STATUS", "3" )   ) //"Ag. Aprovação	

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()
	
Return(.T.)

/*{Protheus.doc} MonTabela
//TODO Descrição auto-gerada.
@author jean.schulze
@since 25/08/2018
@version 1.0
@return ${return}, ${return_description}
@param aCpsBrow, array, descricao
@param aIdxTab, array, descricao
@type function
*/
Static Function MonTabela(aCpsBrow, aIdxTab)
    Local nCont 	:= 0
    Local cTabela	:= ''
	Local aStrTab 	:= {}	//Estrutura da tabela
	Local oArqTemp	:= Nil	//Objeto retorno da tabela

    //-- Busca no aCpsBrow as propriedades para criar as colunas
    For nCont := 1 to Len(aCpsBrow)
        aADD(aStrTab,{aCpsBrow[nCont][2], aCpsBrow[nCont][3], aCpsBrow[nCont][4], aCpsBrow[nCont][5] })
    Next nCont
   	//-- Tabela temporaria de pendencias
   	cTabela  := GetNextAlias()
   	//-- A função AGRCRTPTB está no fonte AGRUTIL01 - Funções Genericas
    oArqTemp := AGRCRTPTB(cTabela, {aStrTab, aIdxTab})
Return cTabela


/*{Protheus.doc} fGetDados
//TODO Descrição auto-gerada.
@author jean.schulze
@since 25/08/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/
Static Function fGetDados(cFilCtr, cCodCtr)

	//se for contrato fixo, processa as pendencias em tempo de execução
	If Posicione("NJR" ,1 ,cFilCtr + cCodCtr ,"NJR_TIPFIX") == "1" //fixo
		fDadosFixo(cFilCtr, cCodCtr)
	Else //senão busca o processamento ja realizado na função do OGX060
		fDadosAfix(cFilCtr, cCodCtr)
	EndIf

return .t.

/*/{Protheus.doc} fDadosFixo
(long_description)
@type  Static Function
@author user
@since date
@version version
@param cFilCtr, char, filial do contrato
@param cCodCtr, char, codigo do contrato
/*/
 Static Function fDadosFixo(cFilCtr, cCodCtr)
	Local cAliasN9K	:= GetNextAlias()
	Local cAliasN9M	:= GetNextAlias()
	Local cAliasNN7	:= GetNextAlias()
	Local cAliasNC8 := GetNextAlias()
	Local nQtdFatur	:= 0
	Local nQtdSaldo	:= 0
	Local nValorFat	:= 0
	Local nValorTot := 0 
	Local lPendRom	:= .F. //indica se ja houve pendencia de valor no romaneio
	Local cFilRom	:= "" //salva o ultimo romaneio apenas para referencia
	Local cUltRom	:= "" //salva o ultimo romaneio apenas para referencia 
	Local cItemRom	:= "" //salva o ultimo romaneio apenas para referencia
	Local cItemPE	:= "" //salva o ultimo romaneio apenas para referencia
	Local cItemRF	:= "" //salva o ultimo romaneio apenas para referencia

	//Limpa temporária
	DbselectArea((_cTabPen))
	ZAP

	//primeiro faz buscas de pendencias financeiras
	
	If Select(cAliasN9K) <> 0
		(cAliasN9K)->(dbCloseArea())
	EndIf 

	//buscar os romaneios gerados
	BeginSQL Alias cAliasN9K 
	  SELECT N9K_FILIAL, N9K_CODROM, N9K_ITEROM, N9K_ITEMPE,
			 N9K_ITEMRF,  SUM(N9K_VALOR) VALOR, 
			 SUM(N9K_QTDVNC) QTDVNC
	    FROM %Table:N9K%
	   WHERE %notDel%
		 AND N9K_FILORI = %Exp:cFilCtr%
	     AND N9K_CODCTR = %Exp:cCodCtr%
       GROUP BY N9K_FILIAL, N9K_CODROM, N9K_ITEROM, N9K_ITEMPE,
			 	N9K_ITEMRF 
	EndSQL
	
	While (cAliasN9K)->(!Eof())

		//para cada romaneio, verifica se houve pagamento, se não houve adiciona como pendencia, se houve parcial tbm
		//adiciona como pendencia
		If Select(cAliasN9M) <> 0
			(cAliasN9M)->(dbCloseArea())
		EndIf 

		//buscar se houve pagamentos para cada romaneio
		BeginSQL Alias cAliasN9M 
		  SELECT SUM(N9M_VALCOM) VALCOM
		    FROM %Table:N9M%
		   WHERE %notDel%
			 AND N9M_FILIAL = %Exp:(cAliasN9K)->N9K_FILIAL%
			 AND N9M_CODROM = %Exp:(cAliasN9K)->N9K_CODROM%
		     AND N9M_CODCTR = %Exp:cCodCtr%
		EndSQL
	
		If (cAliasN9M)->(!Eof())
			If (cAliasN9K)->VALOR > (cAliasN9M)->VALCOM
				//se o valor do romaneio for menor que o valor compensado, gera pendencia
				lPendRom := .T.
				
				If Select(cAliasNC8) <> 0
					(cAliasNC8)->(dbCloseArea())
				EndIf 

				//buscar se houve pagamentos para cada romaneio
				BeginSQL Alias cAliasNC8 
				  SELECT * 
				    FROM %Table:NC8% 
				   WHERE %notDel%
				     AND NC8_FILIAL = %Exp:(cAliasN9K)->N9K_FILIAL%
				     AND NC8_CODROM = %Exp:(cAliasN9K)->N9K_CODROM% 
				     AND NC8_ITEMRO = %Exp:(cAliasN9K)->N9K_ITEROM%
				EndSQL

				If (cAliasNC8)->(!Eof())
					If (cAliasNC8)->NC8_STATUS == "1" .AND. (cAliasNC8)->NC8_PENDEN <= '3'
						//Inclui na TEMP
						fGravTMP((cAliasN9K)->N9K_FILIAL, (cAliasN9K)->N9K_CODROM, (cAliasN9K)->N9K_ITEROM, "4", "1")
					EndIf 
				Else
					//inclui na tabela NC8
					OGX060PEND((cAliasN9K)->N9K_CODROM,;
					           (cAliasN9K)->N9K_ITEROM,;
							   "4",;
							   cFilCtr,;
							   cCodCtr,;
							   (cAliasN9K)->N9K_ITEMPE,;
							   (cAliasN9K)->N9K_ITEMRF,;
							   ((cAliasN9K)->VALOR - (cAliasN9M)->VALCOM))
				
					//Inclui na TEMP
					fGravTMP((cAliasN9K)->N9K_FILIAL, (cAliasN9K)->N9K_CODROM, (cAliasN9K)->N9K_ITEROM, "4", "1")

				EndIf
				
			EndIf
		EndIf

		//acumula a quantidade e valor faturada
		nQtdFatur += (cAliasN9K)->QTDVNC
		nValorFat += (cAliasN9K)->VALOR

		//grava o ultimo romaneio para as pendencias gerais ao final da funcao
		cFilRom	 := (cAliasN9K)->N9K_FILIAL
		cUltRom	 := (cAliasN9K)->N9K_CODROM
		cItemRom := (cAliasN9K)->N9K_ITEROM
		cItemPE	 := (cAliasN9K)->N9K_ITEMPE
		cItemRF	 := (cAliasN9K)->N9K_ITEMRF

		(cAliasN9K)->(dbSkip())
	EndDo

	//busca a quantidade devolvida e valor total
	If Select(cAliasNN7) <> 0
		(cAliasNN7)->(dbCloseArea())
	EndIf 

	BeginSQL Alias cAliasNN7 
	  SELECT SUM(NN7_VALOR) VALOR, SUM(NN7_SLDQTD) SLDQTD
	    FROM %Table:NN7%
	   WHERE %notDel%
		 AND NN7_FILIAL = %Exp:cFilCtr%
	     AND NN7_CODCTR = %Exp:cCodCtr%
	EndSQL
	
	If (cAliasNN7)->(!Eof())
		nQtdSaldo := (cAliasNN7)->SLDQTD
		nValorTot := (cAliasNN7)->VALOR
	EndIf

	//nao foi implementada pendencia de quantidade, deixado este item comentado para evolução.
	//verifica se a quantidade faturada + devolvida é mmenor que a quantidade de contrato
	//If (nQtdFatur - nQtdSaldo) < Posicione('NJR',1,cFilCtr + cCodCtr,'NJR_QTDCTR')
	//EndIf
	
	//se nao houve pendencia de valor no romaneio, verifica a pendencia de valor geral
	If !lPendRom
		//se o valor for diferente gera pendendia. se for maior tbm gerar.
		If nValorFat != nValorTot .and. nQtdSaldo = 0 //ajuste temporario, será melhorado em outra issue
			//gera pendencia de valor
			//inclui na tabela NC8
			If Select(cAliasNC8) <> 0
				(cAliasNC8)->(dbCloseArea())
			EndIf 

			//buscar se houve pagamentos para cada romaneio
			BeginSQL Alias cAliasNC8 
			  SELECT * 
			    FROM %Table:NC8% 
			   WHERE %notDel%
				 AND NC8_FILIAL = %Exp:cFilRom%
				 AND NC8_CODROM = %Exp:cUltRom% 
				 AND NC8_ITEMRO = %Exp:cItemRom%
			EndSQL

			If (cAliasNC8)->(!Eof())
				If (cAliasNC8)->NC8_STATUS == "1"
					//Inclui na TEMP
					fGravTMP(cFilCtr, cUltRom, cItemRom, "4", "1")
				EndIf
			Else
				OGX060PEND( cUltRom,;
							cItemRom,;
							"4",;
							cFilCtr,;
							cCodCtr,;
							cItemPE,;
							cItemRF,;
							(nValorTot - nValorFat))
			
				//Inclui na TEMP
				fGravTMP(cFilCtr, cUltRom, cItemRom, "4", "1")
			EndIf

		EndIf
	EndIf

Return nil

/*{Protheus.doc} fGravTMP
//TODO Descrição auto-gerada.
@author filipe.olegini
@since 11/12/2018
@version 1.0
@type static function
*/
Static Function fGravTMP(cFil, cCodRom, cItemRom, cPend, cStatus)

	If RecLock((_cTabPen),.T.)
		(_cTabPen)->NC8_FILIAL	:= cFil
		(_cTabPen)->NC8_CODROM	:= cCodRom
		(_cTabPen)->NC8_ITEMRO	:= cItemRom
		(_cTabPen)->NC8_PENDEN	:= cPend
		(_cTabPen)->NC8_STATUS	:= cStatus
		(_cTabPen)->(MsUnlock())
	EndIf

Return nil

/*{Protheus.doc} fDadosAfix
//TODO Descrição auto-gerada.
@author jean.schulze
@since 25/08/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/
Static Function fDadosAfix(cFilCtr, cCodCtr)
	Local cAliasNC8	 := GetNextAlias()
	Local cQuery 	 := ""

	//Limpa temporária
	DbselectArea((_cTabPen))
	ZAP

	//monta a query de busca
	cQuery := " SELECT NC8.NC8_FILIAL, NC8.NC8_CODROM, NC8.NC8_ITEMRO, NC8.NC8_PENDEN, NC8.NC8_STATUS "
	cQuery += " FROM " + RetSqlName('NC8') + " NC8 "
	cQuery += " INNER JOIN " + RetSqlName('NJJ') + " NJJ ON NJJ.D_E_L_E_T_='' AND NJJ.NJJ_FILIAL = NC8.NC8_FILIAL AND NJJ.NJJ_CODROM = NC8.NC8_CODROM AND NJJ.NJJ_STATUS='3' " //ROMANEIO CONFIRMADO
	cQuery += " INNER JOIN " + RetSqlName('NJM') + " NJM ON NJM.D_E_L_E_T_='' AND NJM.NJM_FILIAL = NJJ.NJJ_FILIAL AND NJM.NJM_CODROM = NJJ.NJJ_CODROM AND NJM.NJM_CODCTR = NC8.NC8_CODCTR " 
	cQuery += " AND NJM.NJM_ITEM = NC8.NC8_CODCAD AND NJM.NJM_SEQPRI = NC8.NC8_REGRA AND NJM.NJM_DOCNUM != '' " //COM NF
	cQuery += " WHERE NC8.D_E_L_E_T_ = ' ' "
	cQuery += " AND NC8.NC8_FILCTR = '" + cFilCtr + "' "  
	cQuery += " AND NC8.NC8_CODCTR = '" + cCodCtr + "' "  
	cQuery += " AND NC8.NC8_STATUS IN ('1', '3') " //pendente e ag. aprovação
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasNC8, .F., .T.)

	While ( cAliasNC8 )->( !Eof() )

		fGravTMP((cAliasNC8)->NC8_FILIAL, (cAliasNC8)->NC8_CODROM, (cAliasNC8)->NC8_ITEMRO, (cAliasNC8)->NC8_PENDEN, (cAliasNC8)->NC8_STATUS)

		(cAliasNC8)->(dbSkip())
	EndDo

	(cAliasNC8)->(dbCloseArea())

return .T.

/*{Protheus.doc} fBrwDBClck
//TODO Descrição auto-gerada.
@author jean.schulze
@since 25/08/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/
static function fBrwDBClck()
	If (_cTabPen)->NC8_STATUS == '3'
		MsgInfo(STR0027) //Pendência já foi resolvida e está aguardando aprovação.
		Return
	EndIf
	if RecLock((_cTabPen),.F.)	.and. !empty((_cTabPen)->NC8_CODROM) //tratamento de excessao - sempre posicionado
		(_cTabPen)->MARK := IIF((_cTabPen)->MARK  == "1", "", "1")	
		(_cTabPen)->(MsUnlock())	
	endif
return

/*{Protheus.doc} fUpdBrowse
//TODO Descrição auto-gerada.
@author jean.schulze
@since 25/08/2018
@version 1.0
@return ${return}, ${return_description}
@param objBrowser, object, descricao
@param lUpdAll, logical, descricao
@param nLine, numeric, descricao
@type function
*/
static function fUpdBrowse(objBrowser, lUpdAll, nLine) //tratamento de refresh	
	Default lUpdAll := .t.
	Default nLine   := 0
	
	if lUpdAll        
		objBrowser:UpdateBrowse() //reconstroi tudo	
		
		if nLine > 0 //posiciona na linha
			objBrowser:GoTo(nLine)
		endif		
	else	
		objBrowser:LineRefresh() //só refaz a linha
	endif
	
	objBrowser:GoColumn(1)	
	
return .t.

/*{Protheus.doc} fBrwHeadCK
//TODO Descrição auto-gerada.
@author jean.schulze
@since 25/08/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/
static function fBrwHeadCK()
	Local cOperDat := ""
	  		
	DbSelectArea((_cTabPen))
	DbGoTop()
	If DbSeek((_cTabPen)->NC8_FILIAL+(_cTabPen)->NC8_CODROM+(_cTabPen)->NC8_ITEMRO) 
		cOperDat := IIF((_cTabPen)->MARK  == "1", "", "1")
		While !(_cTabPen)->(Eof())
			If RecLock((_cTabPen),.f.)	
				(_cTabPen)->MARK = cOperDat
				MsUnlock()	
			EndIf			
			(_cTabPen)->( dbSkip() )	
		enddo
	endif		

return .t.

/** {Protheus.doc} OGA450CFIX
Função de correções de pendencias de contratos do Fixação
@param: 	cFilRom - Filial do romaneio
@param: 	cCodRom - Código do romaneio
@param: 	cIteRom - Item do romaneio
@param: 	cTipPend - Tipo de pendencia
@author: 	Equipe Agroindustria
@since: 	24/08/2018
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function OGA450CFIX(cFilCtr as char, cCodCtr as char) 
	Local aAreaTemp	as array
	Local cAliasNC8	as char
	Local nValNFC	as numeric
	Local nPos		as numeric
	Local nPos2		as numeric
	Local nX		as numeric
	Local nX2		as numeric
	Local nY		as numeric
	Local nvldCot	as numeric
	Local aVincNKC	as array
	Local aItensNKC	as array
	Local aRet		as array
	Local aValRegra	as array
	Local aRetVal	as array
	Local aVenc		as array
	Local aVldCot 	as array
	Local cSerieOR	as char
	Local lAjustou	as logical
	Local lGerouDoc as logical
	Local lValFix	as logical
	Local lValCot	as logical
	Local lVlCotFix as logical
	Local lCrtFixo  as logical
	Local nOpcao    as numeric
	Local cNatureza as char
    Local lSerie := .F. //para controlar a procura da serie 
	
	aAreaTemp	:= (_cTabPen)->(GetArea())
	cAliasNC8	:= GetNextAlias()
	nValNFC		:= 0
	nPos		:= 0
	nPos2		:= 0
	nX			:= 0
	nX2			:= 0
	nY			:= 0
	nvldCot		:= 0
	aVincNKC	:= {}
	aItensNKC	:= {}
	aRet		:= {}
	aValRegra	:= {}
	cSerieOR	:= Criavar ('F1_SERIE', .F.)
	lAjustou	:= .F.
	lGerouDoc   := .F.	
	lValFix		:= .F.
	lValCot		:= .F.
	lVlCotFix 	:= .F.
	lCrtFixo	:= .F.
	aVldCot		:= {}

	//abre a temporária para pegar os registros marcados
	(_cTabPen)->(dbGoTop())

	While (_cTabPen)->(!EOF())

		If (_cTabPen)->MARK == "1" .AND. (_cTabPen)->NC8_PENDEN $ ('1|3|4')
				
			//busca a NC8
			If Select(cAliasNC8) <> 0
				(cAliasNC8)->(dbCloseArea())
			EndIf 

			cQuery := " SELECT * "
			cQuery += " FROM " + RetSqlName("NC8")
			cQuery += " WHERE D_E_L_E_T_ = '' "
			cQuery += " AND NC8_FILIAL = '" + (_cTabPen)->NC8_FILIAL + "'"
			cQuery += " AND NC8_CODROM = '" + (_cTabPen)->NC8_CODROM + "'"
			cQuery += " AND NC8_ITEMRO = '" + (_cTabPen)->NC8_ITEMRO + "'"
			
			cQuery := ChangeQuery(cQuery)
			
			dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery),cAliasNC8, .F., .T.)
			
			IF (cAliasNC8)->(!Eof()) //busca os demais campos da tabela e separa por regra fiscal
				
				// o valor por regra fiscal
				nPos := aScan(aValRegra, {|x| AllTrim(x[1]) == AllTrim((cAliasNC8)->NC8_CODCAD) .AND. AllTrim(x[2]) == AllTrim((cAliasNC8)->NC8_REGRA) }) 
				If nPos > 0

					nPos2 := aScan(aValRegra[nPos][3], {|x| AllTrim(x[1]) == AllTrim((cAliasNC8)->NC8_FILIAL) .AND. AllTrim(x[2]) == AllTrim((cAliasNC8)->NC8_CODROM) .AND. AllTrim(x[2]) == AllTrim((cAliasNC8)->NC8_ITEMRO) }) 
					If nPos2 == 0
						aAdd(aValRegra[nPos][3],{(cAliasNC8)->NC8_FILIAL, (cAliasNC8)->NC8_CODROM, (cAliasNC8)->NC8_ITEMRO, (cAliasNC8)->R_E_C_N_O_, (cAliasNC8)->NC8_VALOR})
					EndIf
				Else
					aAdd(aValRegra, {(cAliasNC8)->NC8_CODCAD, (cAliasNC8)->NC8_REGRA, {{(cAliasNC8)->NC8_FILIAL, (cAliasNC8)->NC8_CODROM, (cAliasNC8)->NC8_ITEMRO, (cAliasNC8)->R_E_C_N_O_, (cAliasNC8)->NC8_VALOR}} })
				EndIf

			EndIf

			(cAliasNC8)->(dbCloseArea())
		EndIf



		If (_cTabPen)->MARK == "1" 
			Do Case 
			Case (_cTabPen)->NC8_PENDEN $ '1'
				lValFix		:= .T.
				lValCot 	:= .F.
				lVlCotFix 	:= .F.
				lCrtFixo	:= .F.
			
			Case (_cTabPen)->NC8_PENDEN $ '2'
				lValFix		:= .F.
				lValCot 	:= .T.
				lVlCotFix 	:= .F.
				lCrtFixo	:= .F.

				aAdd(aVldCot,{(_cTabPen)->NC8_FILIAL,;
							  (_cTabPen)->NC8_CODROM,;
							  (_cTabPen)->NC8_ITEMRO})
			
			Case (_cTabPen)->NC8_PENDEN $ '3'
				lValFix		:= .F.
				lValCot 	:= .F.
				lVlCotFix 	:= .T.
				lCrtFixo	:= .F.
				
				aAdd(aVldCot,{(_cTabPen)->NC8_FILIAL,;
							  (_cTabPen)->NC8_CODROM,;
							  (_cTabPen)->NC8_ITEMRO})
			
			Case (_cTabPen)->NC8_PENDEN == '4'
				lValFix		:= .F.
				lValCot 	:= .F.
				lVlCotFix 	:= .F.
				lCrtFixo	:= .T.

			Case (_cTabPen)->NC8_PENDEN == '5' //nao implementado nesta versão - Evoluir rotina de pendencias
				lValFix		:= .F.
				lValCot 	:= .F.
				lVlCotFix 	:= .F.
				lCrtFixo	:= .T.

			EndCase
		Endif
		
		(_cTabPen)->(dbSkip())
	EndDo 

	If lValFix
		If!(OGA450VLD(cFilCtr,cCodCtr,aValRegra))
			Return
		EndIf
	EndIf

	If lValCot
		For nvldCot := 1 To Len(aVldCot)
			If !OGA450CHK(aVldCot[nvldCot][1], aVldCot[nvldCot][2], aVldCot[nvldCot][3])
				Return
			EndIf
		Next nvldCot
	EndIf

	If lVlCotFix
		For nvldCot := 1 To Len(aVldCot)
			If !OGA450CHK(aVldCot[nvldCot][1], aVldCot[nvldCot][2], aVldCot[nvldCot][3])
				Return
			Else
				If!(OGA450VLD(cFilCtr,cCodCtr,aValRegra))
					Return
				EndIf	
			EndIf
		Next nvldCot
	EndIf

	If lCrtFixo
		//realiza a validação do contrato fixo
	EndIf

	//PERGUNTAR SE DESEJA GERAR NF DE COMPLEMENTO TIPO 1
	If Len(aValRegra) > 0 
		//loop por regra fiscal
		For nX := 1 To Len(aValRegra)

			//verifica se nao foi carregado o parametro - trata fora da função devido ao uso da trasação
			If _cTipCtr == "1" //compra
				If !lSerie .and. !SX5NumNota(@cSerieOR, GetNewPar("MV_OGASERE","1") )
					Return
				EndIf
				lSerie := .T.
			Else //venda
				If !lSerie .and. !SX5NumNota(@cSerieOR, GetNewPar("MV_OGASERS","1") )
					Return
				EndIf
				
				lSerie := .T.
			EndIf
			
			//controla a transação por regra fiscal
			BEGIN TRANSACTION

			//se não for pendencia de contrato fixo
			If !lCrtFixo
				//função que retorna os valores e datas de vencimento
				MsgRun( STR0019, STR0008, {|| aRetVal := OGA450CPRC(cFilCtr, cCodCtr, aValRegra[nX][1], aValRegra[nX][2], aValRegra[nX][3]) }) //"Calculando os valores das pendências selecionadas" ## "Pendências do Contrato"

				nValNFC := aRetVal[1]
				aVenc	:= aRetVal[2]
			Else
				nValNFC := 0
				aVenc	:= {{dDataBase,1}} //data de hoje pois é ajuste de valor

				// soma todos as pendencias selecionadas, se a soma for positiva é feita a escolha NF ou NCC, se nao é NDC
				For nY := 1 To Len(aValRegra[nX][3])
					nValNFC += aValRegra[nX][3][nY][5]
				Next

			EndIf 

			aItensNKC := {}

			If nValNFC < 0 //somente é NF de complemento se o valor fixado for menor que o faturado
                
				nOpcao := Aviso(STR0016, STR0017 + TRANSFORM(nValNFC, '@E 999,999,999.99') + "."+ STR0028, {STR0029 /*"Fechar"*/, STR0030 /*"Gerar NDC"*/, STR0031 /*"Gerar Complemento"*/}, 2) //Este Contrato possui pendência de Fixação no valor de R$: //Escolha uma das opções abaixo:
				
                nValNFC   := nValNFC * -1

				If nOpcao > 1 //2 - NDC; 3 - Complemento

					If nOpcao == 3
						For nY := 1 To Len(aValRegra[nX][3])
							aVincNKC := {}
							aAdd( aVincNKC, { "NKC_FILIAL", aValRegra[nX][3][nY][1]		} )
							aAdd( aVincNKC, { "NKC_CODCTR", cCodCtr                     } )
							aAdd( aVincNKC, { "NKC_ITEMFX", ""                          } )
							aAdd( aVincNKC, { "NKC_CODROM", aValRegra[nX][3][nY][2]		} )
							aAdd( aVincNKC, { "NKC_ITEROM", aValRegra[nX][3][nY][3]		} )
							aAdd( aVincNKC, { "NKC_ITEM  ", 0                           } )
							aAdd( aVincNKC, { "NKC_SERIE ", ""                          } )
							aAdd( aVincNKC, { "NKC_DOCTO ", ""                          } )
							aAdd( aVincNKC, { "NKC_PREFIX", ""                          } )
							aAdd( aVincNKC, { "NKC_FORMUL", ""                          } )
							aAdd( aVincNKC, { "NKC_QTD   ", 0                           } )
							aAdd( aVincNKC, { "NKC_VRUN	 ", 0                           } ) 
							aAdd( aVincNKC, { "NKC_VRTOT ", IIF(nY == 1,nValNFC,0)		} ) // grava o valor somente no primeiro, utilizado para gerar a nota, os demais é para rastro apenas
							aAdd( aVincNKC, { "NKC_VRIMP ", 0                           } )
							aAdd( aVincNKC, { "NKC_DATA	 ", ""                          } )
							aAdd( aVincNKC, { "NKC_TPDOC ", ""                          } )
							aAdd( aVincNKC, { "NKC_PEDIDO", ""                          } )
							aAdd( aVincNKC, { "NKC_FORCLI", ""                          } )
							aAdd( aVincNKC, { "NKC_LOJA  ", ""                          } )
							aAdd(aItensNKC, aVincNKC)
						Next

						If _cTipCtr == "1" //COMPRA 
							MsgRun( STR0018, STR0008, {|| aRet := OGX009CPL(aValRegra[nX][3][1][1], aValRegra[nX][3][1][2], aValRegra[nX][3][1][3], cSerieOR, "1", nValNFC, aItensNKC) } ) //"Gerando NF de Complemento." ## "Pendências do Contrato"
						Else //VENDA
							//chama a rotina para criar o pedido e NF apenas para o primeiro  romaneio de cada regra fiscal
							MsgRun( STR0018, STR0008, {|| aRet := OGX008ACPL(aValRegra[nX][3][1][1], aValRegra[nX][3][1][2], aValRegra[nX][3][1][3], cSerieOR, "1", nValNFC, aItensNKC, aVenc) } ) //"Gerando NF de Complemento." ## "Pendências do Contrato"
						EndIf

						If !aRet[1] 
							If !Empty(aRet[2])
								MsgInfo(aRet[2]) 
							EndIf
							DisarmTransaction()
							break
						Else
							lGerouDoc := .T.
						EndIf
					ElseIf nOpcao == 2	//NDC													
						cNatureza := POSICIONE("N9A",1, cFilCtr + cCodCtr + aValRegra[nX][1] + aValRegra[nX][2], "N9A_NATURE")
						aRet 	  := OGA450ALCF("D", {cFilCtr, cCodCtr, aValRegra[nX][1], aValRegra[nX][2], cNatureza, nValNFC, STR0032, aVenc[1,1]})	//Solução de Pendência					
						
						If !aRet[1] 
							If !Empty(aRet[2])
								MsgInfo(aRet[2]) 							
                            EndIf
							DisarmTransaction()
							break
						Else
							lGerouDoc := .T.
						EndIf
					EndIf
				
					If nOpcao == 3
						lAjustou := .T. //utilizado apenas para executar os ajustes ##performance

						//Abate o saldo na NN7 utilizando os parametros do romaneio usado para gerar a NF
						N9K->(dbSetOrder(1)) //N9K_FILIAL+N9K_CODROM+N9K_ITEROM+N9K_FILORI+N9K_CODCTR+N9K_ITEMPE+N9K_ITEMRF+N9K_SEQCP+N9K_SEQPF+N9K_SEQN9J
						If N9K->(dbSeek(aValRegra[nX][3][1][1] + aValRegra[nX][3][1][2] + aValRegra[nX][3][1][3] + cFilCtr + cCodCtr))

							NN7->(dbSetOrder(1)) //NN7_FILIAL+NN7_CODCTR+NN7_ITEM
							If NN7->(dbSeek(cFilCtr + cCodCtr + N9K->N9K_SEQPF))
								If RecLock("NN7",.F.)
									NN7->NN7_VLSALD -= nValNFC
									NN7->NN7_VLTEMI += nValNFC
									NN7->NN7_STSTIT := "2"
									NN7->(MsUnLock())
								EndIf
							EndIf
						EndIf
					EndIf

				Else
					//realiza o desarme pois se nao gerar a NF de complemento ele deixa as pendencias abertas
					DisarmTransaction()
					break	
				EndIf

			Else 			
				If MSGYESNO( STR0017 + TRANSFORM(nValNFC, '@E 999,999,999.99')+ "." + STR0033 , STR0016) //"Este Contrato possui pendência de Fixação no valor de R$:" //"Deseja gerar um Nota de Crédito (NCC)?"					
					cNatureza := POSICIONE("N9A",1, cFilCtr + cCodCtr + aValRegra[nX][1] + aValRegra[nX][2], "N9A_NATURE")
					aRet 	  := OGA450ALCF("C", {cFilCtr, cCodCtr, aValRegra[nX][1], aValRegra[nX][2], cNatureza, nValNFC, STR0032, aVenc[1,1]})	//Solução de Pendência

					If !aRet[1] 
						If !Empty(aRet[2])
							MsgInfo(aRet[2]) 
						EndIf
						DisarmTransaction()
						break
					Else
						lGerouDoc := .T.
					EndIf					
				EndIf
			EndIf

			//se tudo der certo
			If lGerouDoc				
				For nY := 1 To Len(aValRegra[nX][3])					
					NC8->(dbGoTo(aValRegra[nX][3][nY][4]))
					If RecLock("NC8",.F.)
						
						If nOpcao = 3 .or. aRet[5] //Complementou ou Aprov. Alçada
							NC8->NC8_STATUS := "2" //atualiza para resolvido
						Else									
							NC8->NC8_STATUS := "3" //em aprovação alçada
						EndIf 

						NC8->NC8_DOC	:= aRet[3]
						NC8->NC8_SERIE	:= aRet[4] 
						NC8->NC8_TPDOC  := IIF(nOpcao = 2,"NDC", IIF(nOpcao = 3, "NFC", "NCC"))
                        NC8->NC8_VALOR  := nValNFC
						NC8->(MsUnlock())
					EndIf
				Next nY				
			EndIf

			END TRANSACTION
		Next

	EndIf

	If lAjustou
		//ajusta PRevisao financeira
   		OGX018ATPR(cfilCtr, cCodCtr, "OGA450C")

		//ajusta dados do contrato
		OGX310(1,NJJ->NJJ_CODROM)
	EndIf

	RestArea(aAreaTemp)

	//limpa os array da memoria
	FwFreeObj(aAreaTemp)
	FwFreeObj(aRet)
	FwFreeObj(aVincNKC)
	FwFreeObj(aItensNKC)
	FwFreeObj(aValRegra)
	FwFreeObj(aRetVal)
	FwFreeObj(aVenc)

	//recarrega os dados do browser superior
	fGetDados(cFilCtr, cCodCtr)

Return

/*/{Protheus.doc} nomeFunction
Função que realiza o consumo das fixações pendentes e atualiza os valores nas tabelas de rastro
@type  Function
@author jean.schulz
@since 28/08/2018
@version P12
@param cFilCtr, Caracter, Filial do contrato
@param cCodCtr, Caracter, código do contrato
@param cCodCad, Caracter, Código da cadencia (previsao de entrega)
@param cRegra, Caracter, Código da regra fiscal
@param aRomaneio, Array, lista de romaneios -> {cFilial,cCodRom,cItemRom}
@return aReturn, Array, Retorno com valor e datas de vencimento -> {nValorDif, aParcelas}
/*/
Static Function OGA450CPRC(cFilCtr as char, cCodCtr as char, cCodCad as char, cRegra as char, aRomaneio as array) 
	Local nCountRom  := 0
	Local nVlrFixUse := 0
	Local cCodProd   := Posicione('NJR',1,cFilCtr+cCodCtr,'NJR_CODPRO') 
	Local cMoedaFat  := Posicione('NJR',1,cFilCtr+cCodCtr,'NJR_MOEDAR') 
	Local cCodNgc    := Posicione('NJR',1,cFilCtr+cCodCtr,'NJR_CODNGC') 
	Local cVersao    := Posicione('NJR',1,cFilCtr+cCodCtr,'NJR_VERSAO')  
	Local cTipMerca  := Posicione('NJR',1,cFilCtr+cCodCtr,'NJR_TIPMER')  
	Local cUmProd    := Posicione('NJR',1,cFilCtr+cCodCtr,'NJR_UM1PRO')  
	Local cUmPrec    := Posicione('NJR',1,cFilCtr+cCodCtr,'NJR_UMPRC')  
	Local nMoedaCalc := IIF(cTipMerca == "1", 1, Posicione('NJR',1,cFilCtr+cCodCtr,'NJR_MOEDA')) 
	Local nQtdFix    := 0
	Local nCotacao   := 0
	Local cCodClient := ""
	Local cCodLoja   := ""
	Local nValorDif  := 0  
	Local lAssPauta  := .f.
	Local aParcelas  := {}  
	Local nContFixa  := 0
	Local aFixacoes  := {}
	Local aVlrDisp   := {}
	Local nSeqN8T    := ""
	Local nPos		 := 0	
	Local cAliasN9D := GetNextAlias()
	Local cAliasDXI := GetNextAlias()
	Local aBlocosCal := {}
		
	dbSelectArea('N8F')
	N8F->(dbSetOrder(1))
	If N8F->(dbSeek(cFilCtr+cCodNgc+cVersao))
		While !Eof() .And. N8F->N8F_FILIAL+N8F->N8F_CODNGC+N8F->N8F_VERSAO == cFilCtr+cCodNgc+cVersao .and. !lAssPauta
			If N8F->N8F_APAUTA  = "0"  //Assume valor de pauta? : 0=Sim;1=Não
				lAssPauta := .t. 
			EndIf			
			N8F->(dbSkip())
		EndDo
	EndIf
	
	For nCountRom := 1 To len(aRomaneio)
		
		//reset values
		nVlrFixUse := 0 
		aFixacoes  := {}
		nCotacao   := 0

		If !OGA450CHK(aRomaneio[nCountRom][1], aRomaneio[nCountRom][2], aRomaneio[nCountRom][3])
			DisarmTransaction()
			Exit
		EndIf
		
		//posiciona na NJM			
		DbSelectArea("NJM")
		NJM->(DbSetOrder( 1 ))
		NJM->(DbGoTop())

		If NJM->(dbSeek( aRomaneio[nCountRom][1] + aRomaneio[nCountRom][2] + aRomaneio[nCountRom][3]))

			//não é algodão
			If !AGRTPALGOD(cCodProd)
										
				DbSelectArea("N8T")
				N8T->(DbSetOrder( 1 ))
				N8T->(DbGoTop())
		
				If N8T->(dbSeek( aRomaneio[nCountRom][1] + aRomaneio[nCountRom][2] + aRomaneio[nCountRom][3]))
			
					While !N8T->( EoF() ) .And. N8T->( N8T_FILIAL + N8T_CODROM + N8T_ITEROM ) ==  aRomaneio[nCountRom][1] + aRomaneio[nCountRom][2] + aRomaneio[nCountRom][3]
						//busca as fixações que são de preco
					    If N8T->N8T_TIPPRC == "1"
					    	nVlrFixUse += N8T->N8T_VALOR * N8T->N8T_QTDVNC
					    	nQtdFix    += N8T->N8T_QTDVNC
						EndIf
						
						//guarda a ultima sequencia usada para o romaneio
						If empty(nSeqN8T) .or. nSeqN8T < N8T->N8T_SEQVNC 
							nSeqN8T := N8T->N8T_SEQVNC
						EndIf
													
						N8T->(DBSkip())
					EndDo
					
				EndIf
				
				If NJM->NJM_QTDFIS - nQtdFix > 0
					//busca o preco que deveria usar ??  verifica se nao deveria ajusta isso na fixacao
					aVlrDisp := OGAX721FAT(cFilCtr,cCodCtr,cCodCad, cRegra, /*RECNO DXI*/ , NJM->NJM_QTDFIS - nQtdFix , /*Preco Base*/ , cCodClient, cCodLoja, "F" )		
			  		
			  		//monta a média ponderada da fixação
			  		nVlrFixUse := nVlrFixUse + ( aVlrDisp[1][1] * (NJM->NJM_QTDFIS - nQtdFix))
			  		
			  		aFixacoes  := aVlrDisp[1][4]
		  		EndIf
		  		
		  		//realiza a média ponderada
		  		nVlrFixUse := nVlrFixUse / NJM->NJM_QTDFIS 
		  		
		  		//monta o valor base, sem fixação
		  		nVlrFixUse := OGX700UMVL(nVlrFixUse,cUmPrec,cUmProd,cCodProd)		
		  			
		  		//grava os precos na N8D, N8T
		  		For nContFixa := 1 To len(aFixacoes)
		  			
					If aFixacoes[nContFixa][1] == "1" //fixacao
						IF (Select("N8D") == 0)
							DbSelectArea("N8D")
						EndIf
						
						N8D->(dbSetOrder(2))
						If N8D->(DbSeek(cFilCtr + cCodCtr + aFixacoes[nContFixa][4] + aFixacoes[nContFixa][5]))
							If RecLock('N8D',.f.)
								N8D->N8D_QTDFAT += aFixacoes[nContFixa][3] //soma a quantidade
								N8D->(MsUnLock())
							EndIf
						EndIf
						
						//utiliza a NN8
						IF (Select("NN8") == 0)
							DbSelectArea("NN8")
						EndIf
						
						NN8->(dbSetOrder(1))
						If NN8->(DbSeek(cFilCtr + cCodCtr + aFixacoes[nContFixa][4]))
							If RecLock('NN8',.f.)
								NN8->NN8_QTDENT += aFixacoes[nContFixa][3] //soma a quantidade
								NN8->(MsUnLock())
							EndIf
						EndIf
						
					EndIf
					
					//grava na tabela de preços
					IF (Select("N8T") == 0)
						DbSelectArea("N8T")
					EndIf
					
					nSeqN8T := SOMA1(alltrim(nSeqN8T))
					
					IF RecLock('N8T',.T.)
						N8T->N8T_FILIAL := aRomaneio[nCountRom][1]
						N8T->N8T_CODROM := aRomaneio[nCountRom][2]
						N8T->N8T_ITEROM := aRomaneio[nCountRom][3]
						N8T->N8T_FILCTR := cFilCtr
						N8T->N8T_CODCTR := cCodCtr
						N8T->N8T_CODCAD := cCodCad
						N8T->N8T_CODREG := cRegra
						N8T->N8T_SEQVNC := nSeqN8T
						N8T->N8T_TIPPRC := aFixacoes[nContFixa][1]
						N8T->N8T_VALOR  := aFixacoes[nContFixa][2]
						N8T->N8T_QTDVNC := aFixacoes[nContFixa][3]
						N8T->N8T_ITEMFX := aFixacoes[nContFixa][4]
						N8T->N8T_SEQFIX := aFixacoes[nContFixa][5]
						N8T->(MsUnLock())
					EndIf
				Next nContFixa	
		  			
				//verifica as cotações que deveria ter usado
				//verifica as cotações a serem usadas - N9K - ajusta já o valor
				DbSelectArea("N9K")
				N9K->(DbSetOrder( 1 ))
				N9K->(DbGoTop())
		
				If N9K->(dbSeek( aRomaneio[nCountRom][1] + aRomaneio[nCountRom][2] + aRomaneio[nCountRom][3] ))
			
					While !N9K->( EoF() ) .And. N9K->( N9K_FILIAL + N9K_CODROM + N9K_ITEROM  ) ==  aRomaneio[nCountRom][1] + aRomaneio[nCountRom][2] + aRomaneio[nCountRom][3]
						
						//faz a verificação para somar as quantidades caso as datas sejam iguais
						//converte a data para string para deixar no mesmo retorno da função de geração de NF
						If (nPos := aScan(aParcelas, {|x| AllTrim(x[1]) == AllTrim(DtoS(N9K_DTVENC)) } )) > 0
							aParcelas[nPos][2] += N9K_QTDVNC 
						Else
							aadd(aParcelas, {DtoS(N9K_DTVENC), N9K_QTDVNC}) 
						EndIf

						nCotacao  += N9K_QTDVNC * xMoeda(1, cMoedaFat, 1, N9K->N9K_DTVENC)
						
						//grava novo preco da fixacao
						If RecLock('N9K',.f.)
							N9K->N9K_VLRFIX := nVlrFixUse * NJM->NJM_QTDFIS  //valor consumido da fixação 
							N9K->N9K_FIXADO := "2" //2=Fixo , 1= Afixar
							N9K->(MsUnLock())
						EndIf
						
						N9K->(DBSkip())
					EndDo
					
				EndIf
				
				//usa uma cotacao média
				nCotacao := nCotacao / NJM->NJM_QTDFIS
				If cMoedaFat > 1
					nVlrFixUse := nVlrFixUse * nCotacao  
				EndIf
				
				//verifica o código do cliente
				DbSelectArea("NJ0")
				NJ0->(DbSetOrder(1))
				If NJ0->(DbSeek(xFilial("NJ0")+NJM->NJM_CODENT+NJM->NJM_LOJENT))
					If Posicione('NJR',1,NJM->NJM_FILORG+NJM->NJM_CODCTR,'NJR_TIPO')  == "1" //Compras - fornecedor
						cCodClient := NJ0->NJ0_CODFOR
						cCodLoja   := NJ0->NJ0_LOJFOR
					Else //vendas - cliente
						cCodClient := NJ0->NJ0_CODCLI
						cCodLoja   := NJ0->NJ0_LOJCLI
					EndIf
				EndIf								
			
				//verifica o valor das notas q foram usadas
				nValorDif  += Round(NJM->NJM_VLRTOT - (nVlrFixUse * NJM->NJM_QTDFIS), TamSX3( "C6_VALOR" )[2]) //ajusta conforme o decimal do pedido
				
				//grava a pendencia recalculada pra o romaneio
				nSeqN8T := SOMA1(alltrim(nSeqN8T))
					
				If RecLock('N8T',.T.)
					N8T->N8T_FILIAL := aRomaneio[nCountRom][1]
					N8T->N8T_CODROM := aRomaneio[nCountRom][2]
					N8T->N8T_ITEROM := aRomaneio[nCountRom][3]
					N8T->N8T_FILCTR := cFilCtr
					N8T->N8T_CODCTR := cCodCtr
					N8T->N8T_CODCAD := cCodCad
					N8T->N8T_CODREG := cRegra
					N8T->N8T_SEQVNC := nSeqN8T
					N8T->N8T_TIPPRC := "6" //complemento
					N8T->N8T_VALOR  := nVlrFixUse
					N8T->N8T_QTDVNC := NJM->NJM_QTDFIS
					N8T->N8T_DATCOT := dDataBase
					N8T->N8T_MOECOT := nMoedaCalc
					N8T->N8T_TAXCOT := nCotacao 
					N8T->(MsUnLock())
				EndIf
			Else
				/*************************************************/
				// Inicio tratamento do Algodão 
				/*************************************************/

				//vê as cotações a serem aplicadas
				DbSelectArea("N9K") // ROM X PREV
				N9K->(DbSetOrder( 1 ))
				N9K->(DbGoTop())  

				If N9K->(dbSeek( aRomaneio[nCountRom][1] + aRomaneio[nCountRom][2] + aRomaneio[nCountRom][3] ))
                                           
    				While !N9K->( EoF() ) .And. N9K->( N9K_FILIAL + N9K_CODROM + N9K_ITEROM  ) ==  aRomaneio[nCountRom][1] + aRomaneio[nCountRom][2] + aRomaneio[nCountRom][3]
						aadd(aParcelas, {N9K_DTVENC, N9K_QTDVNC})                                                                          
						nCotacao  += N9K_QTDVNC * xMoeda(1, cMoedaFat, 1, N9K->N9K_DTVENC)                                                                                                                                                            

						N9K->(DBSkip())
					EndDo   				
				EndIf 

				//usa uma cotacao média
				nCotacao   := nCotacao / NJM->NJM_QTDFIS			

				//busca os fardos
				//verifica se todos estao fixos

				BeginSql Alias cAliasN9D //MOVIMENTAÇÕES DE FARDOS 

				SELECT DXI.DXI_BLOCO
				  FROM %table:N9D% N9D 
				 INNER JOIN %Table:DXI% DXI ON DXI.DXI_FILIAL = N9D.N9D_FILIAL
				   AND DXI.DXI_SAFRA  = N9D.N9D_SAFRA
				   AND DXI.DXI_ETIQ   = N9D.N9D_FARDO 
				   AND DXI.%notDel% 
				 WHERE N9D.N9D_FILORG = %Exp:aRomaneio[nCountRom][1]%
				   AND N9D.N9D_CODROM = %Exp:aRomaneio[nCountRom][2]%
				   AND N9D.N9D_ITEROM = %Exp:aRomaneio[nCountRom][3]%
				   AND N9D.N9D_CODCTR = %Exp:cCodCtr%
				   AND N9D.N9D_ITEETG = %Exp:cCodCad%
				   AND N9D.N9D_ITEREF = %Exp:cRegra%
				   AND N9D.N9D_STATUS = "2"
				   AND N9D.N9D_TIPMOV = "07" 
				   AND DXI.DXI_TIPPRE <> "1"
				   AND N9D.%notDel%                 
				 GROUP BY DXI.DXI_BLOCO       

				EndSQL

				While (cAliasN9D)->(!Eof())
    				aadd(aBlocosCal,(cAliasN9D)->DXI_BLOCO)

    				(cAliasN9D)->(dbSkip())
				EndDo

				(cAliasN9D)->(dbCloseArea())

				//refaz os precos dos mesmos - ogx016
				If Len(aBlocosCal) > 0
				//reexecuta com agio e deságio
					Processa({|| OGX016(cFilCtr, cCodCtr, aBlocosCal, 0, cCodClient, cCodLoja), STR0025}) //"Processando Ágio e Deságio"
				EndIf

				nValorTot := 0                                                              

				//select for tipo
				BeginSql Alias cAliasDXI //Fardos algodão em pluma

				SELECT DXI_FILIAL, DXI_CLACOM, DXI_VLCAGD, SUM(DXI_PSESTO) DXI_PSESTO
				  FROM %table:N9D% N9D
				 INNER JOIN %Table:DXI% DXI ON DXI.DXI_FILIAL = N9D.N9D_FILIAL
				   AND DXI.DXI_SAFRA  = N9D.N9D_SAFRA
				   AND DXI.DXI_ETIQ   = N9D.N9D_FARDO 
				   AND DXI.%notDel% 
				 WHERE N9D.N9D_FILORG = %Exp:aRomaneio[nCountRom][1]%
				   AND N9D.N9D_CODROM = %Exp:aRomaneio[nCountRom][2]%
				   AND N9D.N9D_ITEROM = %Exp:aRomaneio[nCountRom][3]%
				   AND N9D.N9D_CODCTR = %Exp:cCodCtr%
				   AND N9D.N9D_ITEETG = %Exp:cCodCad%
				   AND N9D.N9D_ITEREF = %Exp:cRegra%
				   AND N9D.N9D_STATUS = "2"
				   AND N9D.N9D_TIPMOV = "07" 
				  // AND DXI.DXI_TIPPRE <> "1"
				   AND N9D.%notDel%                 
				 GROUP BY DXI_FILIAL, DXI_CLACOM, DXI_VLCAGD                  

				EndSQL

				While (cAliasDXI)->(!Eof())
                                                                             
					//prepara o valor da fixacao
					nVlrFixUse := OGX700UMVL((cAliasDXI)->DXI_VLCAGD,cUmPrec,cUmProd,cCodProd) 

					If cMoedaFat > 1
						nVlrFixUse := nVlrFixUse * nCotacao 
					EndIf                                                                             					
					
					nValorTot += nVlrFixUse * (cAliasDXI)->DXI_PSESTO

    				(cAliasDXI)->(dbSkip())

				Enddo

				(cAliasDXI)->(dbCloseArea())
				//verifica os precos
				nValorDif  += NJM->NJM_VLRTOT - nValorTot 

				/*************************************************/
				// Fim tratamento do Algodão 
				/*************************************************/
			EndIf	
		EndIf	

	Next nCountRom
	FwFreeObj(aVlrDisp)

Return {nValorDif, aParcelas}

/*{Protheus.doc} OGA450CHK
//Função de OK da tela de valor
@type  Function
@author marcos.wagner
@since 04/09/2018
@version 1.0
@type function
*/
Static Function OGA450CHK(cFilRom, cRomaneio, cItemRom)
	Local cMsg1     := ''
	Local cMsg2     := ''
	Local nCotacao  := 0
	Local lRet      := .t.
	Local cAliasQry	:= GetNextAlias()

	cQry := " SELECT N9K.N9K_DTVENC, NJR.NJR_MOEDAR "
	cQry += "  FROM " + RetSqlName('N9K') + " N9K "
	cQry += "  LEFT JOIN " + RetSqlName('NJM') + " NJM "
	cQry += "    ON NJM.NJM_FILIAL = N9K.N9K_FILIAL "
	cQry += "   AND NJM.NJM_CODROM = N9K.N9K_CODROM "
	cQry += "   AND NJM.NJM_CODCTR = N9K.N9K_CODCTR "
	cQry += "   AND NJM.NJM_ITEROM = N9K.N9K_ITEROM "
	cQry += "   AND NJM.D_E_L_E_T_ = ' ' "
	cQry += "  LEFT JOIN " + RetSqlName('NJR') + " NJR "
	cQry += "    ON NJR.NJR_FILIAL = N9K.N9K_FILORI "
	cQry += "   AND NJR.NJR_CODCTR = N9K.N9K_CODCTR "
	cQry += "   AND NJR.D_E_L_E_T_ = ' ' "
	cQry += "  WHERE N9K.N9K_FILIAL = '" + FwxFilial("N9K",cFilRom) + "' "
	cQry += "    AND N9K.N9K_CODROM = '" + cRomaneio + "' "
	cQry += "    AND N9K.N9K_ITEROM = '" + cItemRom  + "' "
	cQry += "    AND N9K.D_E_L_E_T_ = ' ' "
	cQry := ChangeQuery( cQry )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), cAliasQry, .F., .T. )
	dbSelectArea(cAliasQry)
	dbGoTop()
	While (cAliasQry)->(!Eof())
		nCotacao := xMoeda(1,(cAliasQry)->NJR_MOEDAR,1,STOD((cAliasQry)->N9K_DTVENC))
		If nCotacao == 0
			cMsg1 := STR0020+AllTrim(Str((cAliasQry)->NJR_MOEDAR))+STR0021+DTOC(STOD((cAliasQry)->N9K_DTVENC))+"." //"Não há cotação disponível para a moeda '" ### "' na data: "
			cMsg2 := STR0022 //"Deverá ser cadastrada cotação para a moeda na data."
			Help(,,STR0016,,cMsg1,1,0,,,,,,{cMsg2} ) //"Atenção"
			lRet := .f.
			Exit
		EndIf

		(cAliasQry)->(dbSkip())
	End

	(cAliasQry)->(dbCloseArea())
 
Return lRet

/*/{Protheus.doc} OGA450VLD
	Função que valida se existe fixação suficiente para atender as pendencias marcadas
	@type  Static Function
	@author mauricio.joao
	@since 03/09/2018
	@version 1.0
	@param cFilCtr, Char, Filial do contrato
	@param cCodCtr, Char, Codigo contrato
	@param aValida, Array, Romaneios marcados na tela de pendencias.
	@return lValida, Logical, Retorna se foi validado ou não.
	/*/
Static Function OGA450VLD(cFilCtr as Char,cCodCtr as Char, aValida as Array )
	Local nCad    	as numeric
	Local nQtdRom	as numeric
	Local nRom		as numeric
	Local nDisp     as numeric
	Local nEmp		as numeric
	Local lValida	as logical
	Local aAreaNJM	as array

	//Load de variaveis
	lValida		:= .T.
	aAreaNJM	:= GetArea('NJM')
	caliasDisp 	:= GetNextAlias()
	nQtdRom		:= 0

	If !Empty(aValida)

		For nCad := 1 To Len(aValida)

		//Totais de valores fixados
		BeginSql Alias caliasDisp

		SELECT NN8_FILIAL, NN8_CODCTR, NN8_CODCAD, SUM(NN8_QTDFIX) QTDFIX, SUM(NN8_QTDENT) QTDFAT
		FROM %Table:NN8% NN8
		WHERE NN8.%notDel%
		AND NN8_CODCTR = %Exp:cCodCtr% 
		AND NN8_FILIAL = %Exp:cFilCtr% 
		AND NN8_CODCAD = %Exp:aValida[nCad][1]%	
		GROUP BY NN8_FILIAL, NN8_CODCTR, NN8_CODCAD

		EndSQL

			//Total de quantidade dos romaneios marcados por cadência.
			For nRom := 1 To Len(aValida[nCad][3])
				NJM->(DbSetOrder(1))
				If NJM->(DbSeek(aValida[nCad][3][nRom][1]+;
						aValida[nCad][3][nRom][2]+;
						aValida[nCad][3][nRom][3]))

						nQtdRom += NJM->NJM_QTDFIS					
				EndIf
			Next nRom
			
			//quantidade total fixada - quantidade fixada já faturada
			nDisp := ( (caliasDisp)->QTDFIX - (caliasDisp)->QTDFAT )	
			//quantidade do romaneio - quantidade fixada já faturada
			nEmp  := Iif((nQtdRom - (caliasDisp)->QTDFAT) < 0, 0, (nQtdRom - (caliasDisp)->QTDFAT))

			If nEmp > nDisp .OR. nDisp = 0 //aqui validar saldo parcial
				lValida := .F. 		
				MsgAlert(STR0023) //'Quantidade Fixada insuficiente, operação de solução não pode ser concluida.'
						
				Return(lValida)
			EndIf

		(caliasDisp)->(DbCloseArea())

		Next nCad

	Else
		lValida := .F.
		MsgAlert(STR0024) //'Contrato sem fixação, operação de solução não pode ser concluida.'

	EndIf

	RestArea(aAreaNJM)

Return(lValida)

