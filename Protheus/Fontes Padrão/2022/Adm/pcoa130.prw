#INCLUDE "PCOA130.ch"
#Include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFUNCAO    ณ PCOA130  ณ AUTOR ณ Paulo Carnelossi      ณ DATA ณ 25/10/2004 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRICAO ณ Programa de Cadastro de Acessos aos Centros de Custos        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ USO      ณ SIGAPCO                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_DOCUMEN_ ณ PCOA130                                                      ณฑฑ
ฑฑณ_DESCRI_  ณ Programa de Cadastro de Acessos aos Centros de Custos (PCO)  ณฑฑ
ฑฑณ_FUNC_    ณ Esta funcao podera ser utilizada com a sua chamada normal    ณฑฑ
ฑฑณ          ณ partir do Menu ou a partir de uma funcao pulando assim o     ณฑฑ
ฑฑณ          ณ browse principal e executando a chamada direta da rotina     ณฑฑ
ฑฑณ          ณ selecionada.                                                 ณฑฑ
ฑฑณ          ณ Exemplo: PCOA130(2) - Executa a chamada da funcao de visua-  ณฑฑ
ฑฑณ          ณ                       zacao da rotina.                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ_PARAMETR_ณ ExpN1 : Chamada direta sem passar pela mBrowse               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA130(nCallOpcx)

Private cCadastro	:= STR0001 //"Cadastro de Centros Or็amentแrios"
Private aRotina := MenuDef()

If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	If nCallOpcx <> Nil .And. ( nCallOpcx == 3 .OR. nCallOpcx == 4 )
	    If nCallOpcx == 3
	       Inclui := .T.
	    Else
	       Inclui := .F.
	    EndIf   
		PCOA130DLG("AKX",AKX->(RecNo()),nCallOpcx)
	Else
		mBrowse(6,1,22,75,"AKX")
	EndIf
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA130DLGบAutor  ณPaulo Carnelossi    บ Data ณ  25/10/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณfuncao para inclusao ou alteracao de acesso aos centros de  บฑฑ
ฑฑบ          ณde custos (feito desta forma em razao validacao botao OK)   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA130DLG(cAlias,nReg,nOpcx)
If nOpcx == 3
	AxInclui(cAlias,nReg,nOpcx,/*aAcho*/,/*cFunc*/,/*aCpos*/,"PCOA130CC()"/*cTudoOk*/,/*lF3*/,/*cTransact*/,/*aButtons*/,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/)
EndIf
If nOpcx == 4
    AxAltera(cAlias,nReg,nOpcx,/*aAcho*/,/*aCpos*/,/*nColMens*/,/*cMensagem*/,"PCOA130CC()"/*cTudoOk*/,/*cTransact*/,/*cFunc*/,/*aButtons*/,/*aParam*/,/*aAuto*/,/*lVirtual*/,/*lMaximized*/)	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA130CC บAutor  ณPaulo Carnelossi    บ Data ณ  25/10/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณfuncao para inclusao ou alteracao de acesso aos centros de  บฑฑ
ฑฑบ          ณde custos (feito desta forma em razao validacao botao OK)   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA130CC(lAval, cUser, cCustoIni, cCustoFin, lInclui, nRecAKX)
Local aAreaAKX := AKX->(GetArea())
Local cAlias   := Alias()
Local lRet := .T.
Local aFaixaCC
Local nCtd := 0
Local nPriReg := 0
Local nTamCC := Len(AKX->AKX_CC_INI)
Local cQryCC := ""

Local cQryFinal := ""
Local cQryTmp  := GetNextAlias()
Local cTmpCC
Local lVazioTmp := .T.

DEFAULT lAval := .T.
DEFAULT cUser := M->AKX_USER
DEFAULT cCustoIni := M->AKX_CC_INI
DEFAULT cCustoFin := M->AKX_CC_FIN
DEFAULT lInclui   := Inclui
DEFAULT nRecAKX   := If(Inclui, 0, AKX->(Recno()))

If lAval .And. cCustoIni > cCustoFin
   HELP("  ",1,"PCOA1301") //Centro de custo inicial maior que final
   lRet := .F.
EndIf

If lRet
	//temporario criado no banco
	cTmpCC := CriaTrab( , .F.)
	MsErase(cTmpCC)
	MsCreate(cTmpCC,{{ "CTT_CUSTO", "C", Len(CTT->CTT_CUSTO), 0 }}, "TOPCONN")
	Sleep(1000)
	dbUseArea(.T., "TOPCONN",cTmpCC,cTmpCC/*cAlias*/,.T.,.F.)

	// Cria o indice temporario
	IndRegua(cTmpCC/*cAlias*/,cTmpCC,"CTT_CUSTO",,)

	dbSelectArea("AKX")
	dbSetOrder(1)
	aFaixaCC := {}
	If dbSeek(xFilial("AKX")+cUser)
		While ! Eof() .And. AKX_FILIAL == xFilial("AKX") .And. AKX_USER == cUser
		    If lInclui .OR. (!Inclui .And. Recno() <> nRecAKX)
				aAdd(aFaixaCC, {AKX_CC_INI, AKX_CC_FIN})
		    EndIf
			dbSkip()
		End
	EndIf
		
	If Len(aFaixaCC) > 0
		//1o. avalia se todos os elementos sใo do tipo caracter
		For nCtd := 1 TO Len(aFaixaCC)
		    aFaixaCC[nCtd][1] := PadR(Alltrim(aFaixaCC[nCtd][1]),nTamCC)  //inicio 
	    	aFaixaCC[nCtd][2] := PadR(Alltrim(aFaixaCC[nCtd][2]),nTamCC)  //final
	
			//avalia se todos os elementos sao numericos
			If 	Valtype(aFaixaCC[nCtd][1]) != "C" .OR. ;     //inicio
				Valtype(aFaixaCC[nCtd][2]) != "C"             //final
		    	HELP("  ",1,"PCOA1302") //Erro: Array enviado contem elemento nao caracter!
		   	    lRet := .F.
		    	EXIT
			EndIf
		Next
		
		If lRet
			//Cenario Atual ja incluido no cadastro
			//Usuario Faixa Inicial CC     Faixa Final CC
			//X       01                   03
			//X       10                   20
			//Tentando Incluir os centros de custo na faixa de 04 a 09
			//X       04                  09
			//primeiro contamos quantos CC tem na faixa de 04-09 (C1)
			//depois contamos quantos CC tem na faixa de 04-09 que nao estao cadastrados (C2)
			//entao fazemos comparacao se quantidade de centro de Custo e para permitir cadastros (C1) === (C2)
			//se for diferente entao ้ porque ja existe alguma faixa com cadastro destes centros de custos
		
			//monta a query para retornar todos os centros de custos constantes no array aFaixaCC
			For nCtd := 1 TO Len(aFaixaCC)
				cQryCC := " SELECT CTT_CUSTO FROM " + RetSqlName("CTT")
				cQryCC += " WHERE CTT_FILIAL = '"+xFilial("CTT")+"' "
				cQryCC += " AND CTT_CUSTO BETWEEN '" + aFaixaCC[nCtd][1] + "' AND '" + aFaixaCC[nCtd][2] + "' "
				cQryCC += " AND D_E_L_E_T_ = ' ' "				
				cQryCC := ChangeQuery(cQryCC)
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryCC), cQryTmp, .F., .T.)
				dbSelectArea(cQryTmp)
    	        dbGoTop()
    			//alimenta o temporario criado no banco pois quando usuario tinha muito acesso estourava o tamanho da query	        
    	        While ! Eof()
    	        
    	        	dbSelectArea(cTmpCC)  //temporario criado no banco
    	        	Reclock(cTmpCC, .T.)
                    (cTmpCC)->CTT_CUSTO := (cQryTmp)->CTT_CUSTO
    	        	MsUnlock()
    	        	lVazioTmp := .F.
    	        
    	        	dbSelectArea(cQryTmp)
    	        	dbSkip()
    	        EndDo
				dbSelectArea(cQryTmp)
    	        dbCloseArea()
	
			Next
			
        	dbSelectArea(cTmpCC)  //temporario criado no banco
			dbCloseArea()

			//Monta a query final
		
            //monta a query para retornar se encontrou cc inicial/final informado se existe no array aFaixaCC
			cQryFinal := " SELECT COUNT(CTT_CUSTO) NCOUNTCTT FROM " + RetSqlName("CTT")
			cQryFinal += "        WHERE CTT_FILIAL = '"+xFilial("CTT")+"' "
			cQryFinal += "          AND CTT_CUSTO BETWEEN '" + cCustoIni + "' AND '" + cCustoFin + "' "
			cQryFinal += "          AND D_E_L_E_T_ = ' ' "
			If ! lVazioTmp
				//faz union com arquivo de centro de custo e temporario contendo as faixas de centro de custo ja inclusas
				cQryFinal += " UNION ALL "
	            //somente retorna os centros de custo se nao existe no array aFaixaCC
	            cQryFinal += " SELECT COUNT(CTT_CUSTO) NCOUNTCTT FROM " + RetSqlName("CTT")
				cQryFinal += "         WHERE CTT_FILIAL = '"+xFilial("CTT")+"' "
				cQryFinal += "           AND CTT_CUSTO BETWEEN '" + cCustoIni + "' AND '" + cCustoFin + "' "
				cQryFinal += "           AND D_E_L_E_T_ = ' ' "
				cQryFinal += "           AND CTT_CUSTO NOT IN ( SELECT CTT_CUSTO FROM " + cTmpCC + " ) "
			EndIf
			cQryFinal := ChangeQuery(cQryFinal)
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryFinal), cQryTmp, .F., .T.)
			dbSelectArea(cQryTmp)
            dbGoTop()
			
			//avalia retorno da query no primeiro registro
            lRet := ( (nPriReg := (cQryTmp)->NCOUNTCTT) > 0 )
			//avalia segundo registro se primeiro retornou algum contador de centro de custo            
			If lRet .And. ! lVazioTmp
				dbSelectArea(cQryTmp)
            	dbSkip() //vai para segundo registro
				lRet := ( (cQryTmp)->NCOUNTCTT == nPriReg )
			Else
				HELP("  ",1,"PCOA1303") //Faixa de centro de Custo ja existente nao esta integra.Verificar!
			EndIf						
			            
			dbSelectArea(cQryTmp)
            dbCloseArea()
            //apaga arquivo temporario criado
            MsErase(cTmpCC)
            
            If ! lRet
				HELP("  ",1,"PCOA1304") //Faixa de centro de Custo ja existente, portanto nao pode ser incluida!
            EndIf
            
	    EndIf
	    
	EndIf
		
EndIf
	
RestArea(aAreaAKX)
dbSelectArea(cAlias)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAvFaixaCC บAutor  ณPaulo Carnelossi    บ Data ณ  25/10/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAvalia se elemento 1 ou 2 podem ser inseridos na Tabela de  บฑฑ
ฑฑบ          ณAcessos ao Centro de Custo                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AvFaixaCC(lAval,cNewElem1, cNewElem2, aElemExistente)
Local cInicio, cFim, nCtd, cAnterior := Space(Len(AKX->AKX_CC_INI))
Local lRet := .T.
Local nTamCC := Len(cNewElem1)

cNewElem1 := PadL(Alltrim(cNewElem1),nTamCC)
cNewElem2 := PadL(Alltrim(cNewElem2),nTamCC)

For nCtd := 1 TO Len(aElemExistente)
    aElemExistente[nCtd][1] := PadL(Alltrim(aElemExistente[nCtd][1]),nTamCC)
    aElemExistente[nCtd][2] := PadL(Alltrim(aElemExistente[nCtd][2]),nTamCC)
Next

If lAval .And. cNewElem1 > cNewElem2
   HELP("  ",1,"PCOA1301") //Centro de custo inicial maior que final
   lRet := .F.
EndIf

If lRet
	For nCtd := 1 TO Len(aElemExistente)
		//avalia se todos os elementos sao numericos
		If Valtype(aElemExistente[nCtd][1]) != "C" .OR. ;
	    	Valtype(aElemExistente[nCtd][2]) != "C"
	    	HELP("  ",1,"PCOA1302") //Erro: Array enviado contem elemento nao caracter!
	   	    lRet := .F.
	    	EXIT
	   EndIf
	   // avalia se elemento inicial e maior que anterior e neste caso
	   // atribui a cAnterior o segundo elemento
	   // senao esta errado - avisa usuario e sai
	   If aElemExistente[nCtd][1] > cAnterior
			cAnterior := aElemExistente[nCtd][2]
		Else
			HELP("  ",1,"PCOA1303") //Faixa de centro de Custo ja existente nao esta integra.Verificar!
	    	lRet := .F.
	    	EXIT
		EndIf	
	Next
EndIf

If lRet
	For nCtd := 1 TO Len(aElemExistente)
		cInicio	:= aElemExistente[nCtd][1]
		cFim		:= aElemExistente[nCtd][2]
		
		If cNewElem1 > cInicio
		    //avalia elementos a Inserir
			If cNewElem1 <= cFim .OR. cNewElem2 <= cFim
				HELP("  ",1,"PCOA1304") //Faixa de centro de Custo ja existente, portanto nao pode ser incluida!
				lRet := .F.
				EXIT
			EndIf	
		Else	
			//se elemento 1 for menor que inicio avalia elemento 2
			If cNewElem2 >= cInicio
				HELP("  ",1,"PCOA1304") //Faixa de centro de Custo ja existente, portanto nao pode ser incluida!
				lRet := .F.
				EXIT
			EndIf	
		EndIf
	Next
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Ana Paula N. Silva     ณ Data ณ10/12/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados     ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function MenuDef()
Local aRotina 	:= {	{ STR0002,		"AxPesqui" , 0 , 1, ,.F.},;    //"Pesquisar"
							{ STR0003, 	"AxVisual" , 0 , 2},;    //"Visualizar"
							{ STR0004, 		"pcoa130Dlg" , 0 , 3},;	  //"Incluir"
							{ STR0005, 		"pcoa130Dlg" , 0 , 4},; //"Alterar"
							{ STR0006, 		"AxDeleta" , 0 , 5}} //"Excluir"
						
If AMIIn(57) // AMIIn do modulo SIGAPCO ( 57 )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Adiciona botoes do usuario no Browse                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock( "PCOA1301" )
		//P_Eฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//P_Eณ Ponto de entrada utilizado para inclusao de funcoes de usuarios no     ณ
		//P_Eณ browse da tela de Centros Orcamentarios                                            ณ
		//P_Eณ Parametros : Nenhum                                                    ณ
		//P_Eณ Retorno    : Array contendo as rotinas a serem adicionados na enchoice ณ
		//P_Eณ               Ex. :  User Function PCOA1301                            ณ
		//P_Eณ                      Return {{"Titulo", {|| U_Teste() } }}             ณ
		//P_Eภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ValType( aUsRotina := ExecBlock( "PCOA1301", .F., .F. ) ) == "A"
			AEval( aUsRotina, { |x| AAdd( aRotina, x ) } )
		EndIf
	EndIf          
EndIf
Return(aRotina)	