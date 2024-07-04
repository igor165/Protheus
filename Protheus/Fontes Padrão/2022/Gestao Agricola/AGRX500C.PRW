#INCLUDE "AGRX500.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//===================================================================================
/*****  Funçõe de solução de pendências físicas da rotina AGRX500 - Romaneios  *****/
//===================================================================================


/*/{Protheus.doc} AGRX500SPD
Função para solucionar pendência de devolução fisica
@author silvana.torres
@since 25/01/2018
@version undefined
@param aPendN9C, array, descricao
@param nValPend, numeric, descricao
@param cSafra, characters, descricao
@param cEntidade, characters, descricao
@param cLojEnt, characters, descricao
@param cProduto, characters, descricao
@type function
/*/
Function AGRX500SPD(aPendN9C, nValPend, cSafra, cEntidade, cLojEnt, cProduto)
	
	Local aArea     := GetArea()
	Local lRet 		:= .F.
	Local cAliasFar 
	Local cAliasRom 
	Local cQuery2	:= ""
	Local cNumOP
	Local cAponOP
	Local cNumAx
	Local cProd    
	Local aDadosNJJ := {}
	Local cLocal    := ""
	Local lOPEspec  := .F. 
	Local lAlgodao	:= .F.
	
	Private lMsErroAuto := .f.
	Private lMSHelpAuto	:= .T.
	
	lOPEspec := ExistBlock("AGRX50OP")
	
	lAlgodao := if(Posicione("SB5",1,fwxFilial("SB5")+cProduto,"B5_TPCOMMO")== '2',.T.,.F.)
	
	if lAlgodao		
		//busca os fardões do romaneio
		DbSelectArea('DX0')
		DbSetOrder(3)
	
		If MsSeek(fwxFilial('DX0')+aPendN9C[1][1]) //FILIAL + ROMANEIO
    
		 	While DX0->(!Eof()) .And.;
		 		  DX0->DX0_FILIAL = FWxFilial("DX0") .And.;
		 		  DX0->DX0_NRROM  = aPendN9C[1][1]	  
                  
                cAliasFar := GetNextAlias()
                
				//busca o numéro da OP e o número do apontamento de produção para cada fardão
				cQuery2 := "SELECT * FROM  " + RetSqlName('DXB')+ " DXB " 
				cQuery2 += " WHERE DXB.D_E_L_E_T_ = ''              
				cQuery2 += " 	AND DXB.DXB_FILIAL = '"+ FWxFilial("DXB") +"'" 
				cQuery2 += "  	AND DXB.DXB_FARDAO = '" + DX0->DX0_FARDAO + "'"
				cQuery2 += "  	AND DXB.DXB_SAFRA  = '" + cSafra + "'   "
			 	cQuery2 += " 	AND DXB.DXB_ROTINA = 'AGRA601' "
		 		cQuery2    := ChangeQuery(cQuery2)

				//--Identifica se tabela esta aberta e fecha
				If Select(cAliasFar) <> 0
					(cAliasFar)->(dbCloseArea())
				EndIf
		 		
		 		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery2 ), cAliasFar, .F., .T. )

		 		While (cAliasFar)->(!Eof())
		 		
		 			cNumOP 	:= (cAliasFar)->DXB_OP
					cAponOP := (cAliasFar)->DXB_DOC
					cProd   := (cAliasFar)->DXB_CODPRO
					
					cNumAx := SubStr(cNumOP,1,len(SC2->C2_NUM))
					
					if .NOT. AX500EstOP(cNumAx, cProd, cAponOP)
						return .F.
					endIf		
					
					(cAliasFar)->(dbSkip())	
		 		endDo
		 		DX0->(dbSkip())	
		 	endDo
		endIf
	else
		cAliasRom := GetNextAlias()
		
		//busca o numéro da OP e o número do apontamento de produção para o romaneio
		cQuery2 := "SELECT * "
		cQuery2 += "  FROM " + RetSqlName('NJJ')+ " NJJ " 
		cQuery2 += " WHERE NJJ.D_E_L_E_T_ = ''              
		cQuery2 += "   AND NJJ.NJJ_FILIAL = '"+ FWxFilial("NJJ") +"'" 
		cQuery2 += "   AND NJJ.NJJ_CODROM = '" + aPendN9C[1][1] + "'"
		cQuery2    := ChangeQuery(cQuery2)

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery2 ), cAliasRom, .F., .T. )

 		While (cAliasRom)->(!Eof())
 		
 			cNumOP 	:= (cAliasRom)->NJJ_NUMOP
			cAponOP := (cAliasRom)->NJJ_APONOP
			cProd   := (cAliasRom)->NJJ_CODPRO
			
			cNumAx := SubStr(cNumOP,1,len(SC2->C2_NUM))
			
			if .NOT. AX500EstOP(cNumAx, cProd, cAponOP)
				return .F.
			endIf
 		endDo
	endif
		
	//OP (ordem produção) específica enviada pelo cliente por ponto entrada
	If lOPEspec
	  	cNumOP := ExecBlock('AGRX50OP',.F.,.F.,)
	Else
	    cNumOP := ""
	EndIf
 
    aDadosNJJ := AGRX500LOC(aPendN9C, "") 
    cLocal    := aDadosNJJ[2]
 
	If Empty(cNumOP) 
		//gerar nova OP, apontar quantidade real
		//-- Gera ordem de produção
		//Retorno := (Numero da OP - Modelo - Operação de Inclusão)
		Processa({|| lRet := A500GERAOP(@cNumOP, cProduto, nValPend, cLocal, 3) }, STR0002, STR0004 ) //"Gerando Ordem de Produção..."###"Aguarde"
	EndIf
		 		
	If lRet
		//-- Realiza o apontamento da OP 
		//Retorno := (Numero da OP - Modelo - Operação de Inclusão)
		Processa({|| lRet := A500APROD(cNumOP, aPendN9C[1][1], cProduto, nValPend, cLocal, 3) }, STR0003, STR0004 ) //"Movimentando Ordem de Produção..."###"Aguarde"
	EndIf
		
	If lRet
		if lAlgodao
			//-- Grava o rastro da devolução física
			lRet := AGRX500RAS(cNumOP, aPendN9C, "AGRX500SPD")
		endIf
	EndIf
	
	If lRet
		//--Atualiza status das pendências
		lRet := AGRX500STT(aPendN9C, cSafra, cEntidade, cLojEnt, "")
	EndIf
		
	RestArea(aArea)
	
Return lRet


/*/{Protheus.doc} AGRX500PCF
//Função para solução de pendências de complemento físico
@author marina.muller
@since 26/01/2018
@version undefined
@param aPendN9C, array, descricao
@param nValPend, numeric, descricao
@param cSafra, characters, descricao
@param cEntidade, characters, descricao
@param cLojEnt, characters, descricao
@param cProduto, characters, descricao
@type function
/*/
Function AGRX500PCF(aPendN9C, nValPend, cSafra, cEntidade, cLojEnt, cProduto)
	Local aArea     := GetArea()
	Local lRet   	:= .T.
	Local cNumOP	:= ""
	Local aDadosNJJ := {}
	Local cLocal    := ""
	Local lAlgodao	:= .F.
    
    //OP (ordem produção) específica enviada pelo cliente por ponto entrada
	If ExistBlock("AGRX50OP")
		cNumOP := ExecBlock('AGRX50OP',.F.,.F.,)
	EndIf

    aDadosNJJ := AGRX500LOC(aPendN9C, "")
    cLocal    := aDadosNJJ[2] 

    //-- Se ordem produção não vier do ponto de entrada inclui uma nova ordem de produção
    If Empty(cNumOP)
		//-- Gera ordem de produção
		Processa({|| lRet := A500GERAOP(@cNumOP, cProduto, nValPend, cLocal, 3)}, STR0002, STR0004 ) //"Gerando Ordem de Produção..."###"Aguarde"
	EndIf
		
	If lRet
		//-- Realiza o apontamento da OP 
		Processa({|| lRet := A500APROD(cNumOP, NJJ->NJJ_CODROM, cProduto, nValPend, cLocal, 3)}, STR0003, STR0004 ) //"Movimentando Ordem de Produção..."###"Aguarde"
	EndIf
	
	If lRet
		lAlgodao := if(Posicione("SB5",1,fwxFilial("SB5")+NJJ->NJJ_CODPRO,"B5_TPCOMMO")== '2',.T.,.F.)
		
		if lAlgodao
		    //-- Grava o rastro do complemento    
            lRet := AGRX500RAS(cNumOP, aPendN9C, "AGRX500PCF")
        endIf 
    EndIf
    
    If lRet
        //--Atualiza status das pendências
        lRet := AGRX500STT(aPendN9C, cSafra, cEntidade, cLojEnt, "")
	EndIf
	
	RestArea(aArea)	

Return lRet


/*/{Protheus.doc} AX500PCFis
Função para solução de complemento fiscal
@author silvana.torres
@since 04/04/2018
@version undefined
@param aPendN9C, array, descricao
@param nValPend, numeric, descricao
@param cSafra, characters, descricao
@param cEntidade, characters, descricao
@param cLojEnt, characters, descricao
@param cProduto, characters, descricao
@type function
/*/
Function AX500PCFis(aPendN9C, nValPend, cSafra, cEntidade, cLojEnt, cProduto)
	Local aArea     := GetArea()
	Local lRet   	:= .T.
	Local cNumOP	:= ""
	Local aDadosNJJ := {}
	Local cLocal    := ""
	Local lAlgodao	:= .F.
    
    //OP (ordem produção) específica enviada pelo cliente por ponto entrada
	If ExistBlock("AGRX50OP")
		cNumOP := ExecBlock('AGRX50OP',.F.,.F.,)
	EndIf

    aDadosNJJ := AGRX500LOC(aPendN9C, "")
    cLocal    := aDadosNJJ[2] 

    //-- Se ordem produção não vier do ponto de entrada inclui uma nova ordem de produção
    If Empty(cNumOP)
		//-- Gera ordem de produção
		Processa({|| lRet := A500GERAOP(@cNumOP, cProduto, nValPend, cLocal, 3)}, STR0002, STR0004 ) //"Gerando Ordem de Produção..."###"Aguarde"
	EndIf
		
	If lRet
		//-- Realiza o apontamento da OP 
		Processa({|| lRet := A500APROD(cNumOP, NJJ->NJJ_CODROM, cProduto, nValPend, cLocal, 3)}, STR0003, STR0004 ) //"Movimentando Ordem de Produção..."###"Aguarde"
	EndIf
	
	If lRet
		lAlgodao := if(Posicione("SB5",1,fwxFilial("SB5")+NJJ->NJJ_CODPRO,"B5_TPCOMMO")== '2',.T.,.F.)
		
		if lAlgodao
		    //-- Grava o rastro do complemento    
            lRet := AGRX500RAS(cNumOP, aPendN9C, "AGRX500PCF")
        endIf
    EndIf
    
	RestArea(aArea)	

Return lRet


/*/{Protheus.doc} AX500EstOP
Estorna OP e Apont
@author silvana.torres
@since 05/04/2018
@version undefined
@param cNumAx, characters, descricao
@param cProd, characters, descricao
@param cAponOP, characters, descricao
@type function
/*/
Function AX500EstOP(cNumAx, cProd, cAponOP)

	Local dDataFe
	Local vVetRD3PR := {} //Informações de Produção   
	Local aVetor    := {}
	Local aApont    := {}
	Local nx
	Local cItemOP   := ""
	Local cSeqOp    := ""
	Local cBatRot   := ""
	Local lExcluiOP
	Local lIniciada
	
	Pergunte('AGRA60102', .F.)
	
	if MV_PAR02 = 1
		lIniciada := .T.
	else
	 	lIniciada := .F. 
	endIf

	// Reabre a OP
	DbselectArea("SC2")
	DBClearFilter()
	If AGRIFDBSEEK("SC2",cNumAx+'01'+cProd,9,.f.)
		AGRTRAVAREG("SC2")
		dDataFe       := SC2->C2_DATRF
		SC2->C2_DATRF := AGRINICIAVAR("C2_DATRF")
		AGRDESTRAREG("SC2")
	EndIf
	SC2->(dbCloseArea())

	//Posiciona nos movimentos relacionados a OP 
	DbSelectArea("SD3")
	SD3->(dbSetOrder(2))
	SD3->(MsSeek(FwXFilial('SD3')+PADR(cAponOP,TamSX3('D3_DOC')[1],' ')+;
							      PADR(cProd,TamSX3('D3_COD')[1],' ')))
							
	// Pesquisa e armazena movimentações de produção da ordem de produção
	While !Eof() .And. SD3->(D3_FILIAL+D3_DOC+D3_COD) = FWxFilial("SD3")+cAponOP+cProd 

		If Substr(SD3->D3_CF,1,2) = "PR" .And. SD3->D3_ESTORNO <> 'S' 
			Aadd(vVetRD3PR,Recno())
		EndIf
		SD3->(DbSkip())
	End

	// Estorna a produção	
	For nx := 1 To Len(vVetRD3PR)
		DbSelectArea("SD3")
		Dbgoto(vVetRD3PR[nx])

		aApont := {}
		lMsErroAuto := .F.
		Aadd(aApont,{"D3_DOC"	 ,SD3->D3_DOC		,Nil})
		Aadd(aApont,{"D3_OP"	 ,SD3->D3_OP		,Nil})
		Aadd(aApont,{"D3_COD"    ,SD3->D3_COD		,Nil})
		Aadd(aApont,{"D3_UM"     ,SD3->D3_UM		,Nil})
		Aadd(aApont,{"D3_QUANT"  ,SD3->D3_QUANT		,Nil}) 
		Aadd(aApont,{"D3_LOCAL"  ,SD3->D3_LOCAL		,Nil})
		Aadd(aApont,{"D3_CC"     ,SD3->D3_CC		,Nil})
		Aadd(aApont,{"D3_EMISSAO",SD3->D3_EMISSAO	,Nil}) 
		Aadd(aApont,{"D3_LOTECTL",SD3->D3_LOTECTL	,Nil})
		Aadd(aApont,{"D3_DTVALID",SD3->D3_DTVALID	,Nil}) 
		Aadd(aApont,{"D3_NUMSEQ" ,SD3->D3_NUMSEQ    ,Nil})
		Aadd(aApont,{"D3_CHAVE"	 ,SD3->D3_CHAVE		,Nil})
		Aadd(aApont,{"D3_CF"	 ,"PR0"				,Nil})
		aAdd(aApont,{"INDEX"     , 4                ,Nil})

		lMsErroAuto := .F.
		Processa({||MsExecAuto({|x,y| MATA250(x,y)},aApont,5)},STR0005,STR0004) //"Aguarde"##"Excluindo apontamento de produção"

		If lMsErroAuto
			MostraErro()
			Return .F.
		EndIf
		AGRQUEBRAFIL("SF5")
	Next nx
	SD3->(dbCloseArea())

	// Refaz o tratamento da OP
	DbselectArea("SC2")
	DBClearFilter()
	If AGRIFDBSEEK("SC2",cNumAx+'01'+cProd,9,.f.)
		AGRTRAVAREG("SC2")
		If lIniciada
			SC2->C2_DATRF := If(SC2->C2_QUANT - SC2->C2_QUJE > 0,Ctod(''),dDataFe)
		Else
			SC2->C2_DATRF := If(SC2->C2_QUJE > 0,dDataFe,Ctod(''))
		Endif
		SC2->C2_QUJE  := If(SC2->C2_QUJE < 0,0,SC2->C2_QUJE)
		cItemOP       := SC2->C2_ITEM
		cSeqOP        := SC2->C2_SEQUEN
		cBatRot       := SC2->C2_BATROT
		AGRDESTRAREG("SC2")

		lExcluiOP := .F.
		If A650DefLeg(2)
			lExcluiOP := .T.
		Endif
	EndIf

	If lExcluiOP .And. (cBatRot <> "MATA650")
		AADD(aVetor,{'C2_NUM' 		, cNumAx , NIL}) //Numero da OP
		AADD(aVetor,{'C2_ITEM'		, cItemOP, NIL}) //Item da OP
		AADD(aVetor,{'C2_SEQUEN'	, cSeqOP , NIL}) //Sequencia da OP

		//-----------------------------
		// Executa rotina a automatica
		//-----------------------------
		Processa( {||MSExecAuto({|x,y| MATA650(x,y)},aVetor, 5)},STR0006,STR0004) //"Aguarde"##"Excluindo ordem de produção"

		If lMSErroAuto
			MostraErro()
			Return .F.		 		
		EndIf				
	Endif
	
	SC2->(dbCloseArea())
	
Return .T.