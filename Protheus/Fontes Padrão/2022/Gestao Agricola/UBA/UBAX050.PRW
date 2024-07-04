#include "protheus.ch"
#include "UBAX050.CH"

/*/{Protheus.doc} ResultFaixa
@author bruna.rocio
@since 03/04/2017
@version undefined
@param cContaminante, characters, descricao
@param xValor, , descricao
@type function
/*/
Static Function ResultFaixa(cContaminante, xValor)
	Local aArea     := GetArea()
	Local cAliasN77 := GetNextAlias()
	Local xResult

	BeginSQL Alias cAliasN77
		Select N77_RESULT FROM %Table:N77% N77
			Where N77.%notDel%
			  and N77.N77_FILIAL  = %xFilial:N77%
			  and N77.N77_CODCTM  = %exp:cContaminante%
			  and N77.N77_FAIINI  <= %exp:xValor%
			  and N77.N77_FAIFIM  >= %exp:xValor%
	EndSQL
	
	dbGoTop()
	If (cAliasN77)->(!Eof())
		xResult := (cAliasN77)->N77_RESULT
	Else
		xResult := "ERROR"
	Endif
	
	RestArea(aArea)
Return xResult

/*/{Protheus.doc} UBA050LANC
//Função de pré-lançamento de contaminantes
@author bruna.rocio
@since 27/03/2017
@version undefined
@param cContaminante, characters, descricao
@param cEntidade, characters, descricao
@param cTipoResul, characters, descricao
@param xResult, undefined, descricao
@param oGrid, object, descricao
@type function
/*/
Function UBAX050LANC(cContaminante, cEntidade, cTipoResul, xValor, oGrid)
	Local lRet    := .T.
	Local aArea   := GetArea()
	Local xResult := {}
	Local cDescRes := ""
	
	If cTipoResul = "5" //Faixa
		cDescRes := ResultFaixa(cContaminante, xValor)
		If cDescRes = "ERROR"
			Help(,,STR0001,,STR0006, 1, 0) //"ATENCAO"###"Valor informado invalido para o contaminante"
			Return .F.
		Endif
		aAdd(xResult,xValor)
		aAdd(xResult,cDescRes)
	Else
		aAdd(xResult,xValor)
	Endif
	
	Do Case
		Case cEntidade = "DXL"
			lRet := PrepDXL(cContaminante, cTipoResul, xResult, oGrid)
		Case cEntidade = "DXI"
			lRet := PrepDXI(cContaminante, cTipoResul, xResult, oGrid)
		Case cEntidade = "DXJ"
			lRet := PrepDXJ(cContaminante, cTipoResul, xResult, oGrid)
		Case cEntidade = "DXD"
			lRet := PrepDXD(cContaminante, cTipoResul, xResult, oGrid)
	EndCase
		
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} PrepDXL
//Preparação lançamento resultados contaminantes para fardão
@author bruna.rocio
@since 28/03/2017
@version undefined
@param cContam, characters, descricao
@param cTipoResul, characters, descricao
@param xResult, , descricao
@param oGrid, object, descricao
@type function
/*/
Static Function PrepDXL(cContam, cTipoResul, xResult, oGrid)
	Local aArea := GetArea()
	Local lRet  := .T.
	
	Begin Transaction
		
		DXL->(dbGoTop())
		While .Not. DXL->(Eof())
			
			If oGrid:IsMark()
				MsAguarde({||lRet := LancaResul(DXL->DXL_SAFRA, "DXL", DXL->DXL_CODIGO, DXL->DXL_PRDTOR, DXL->DXL_LJPRO, DXL->DXL_FAZ,; 
									cContam, xResult, cTipoResul, DXL->DXL_CODPRO, DXL->(Recno()))},STR0001,STR0002) //#"Atenção"##"Efetuando lançamento de contaminante para fardão"
												
				If RecLock('DXL',.F.)
					DXL->DXL_OK = ' '
					MsUnlock()
				Endif
			EndIf
			DXL->(dbSkip())
		EndDo
	End Transaction
	
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} PrepDXI
//Preparação lançamento resultados contaminantes para fardo
@author bruna.rocio
@since 28/03/2017
@version undefined
@param cContam, characters, descricao
@param cTipoResul, characters, descricao
@param xResult, , descricao
@param oGrid, object, descricao
@type function
/*/
Static Function PrepDXI(cContam, cTipoResul, xResult, oGrid)
	Local aArea := GetArea()
	Local lRet  := .T.
	
	Begin Transaction
		DXI->(dbGoTop())
		While .Not. DXI->(Eof())
			
			If oGrid:IsMark()
				
				MsAguarde({||lRet := LancaResul(DXI->DXI_SAFRA, "DXI", DXI->DXI_ETIQ, DXI->DXI_PRDTOR, DXI->DXI_LJPRO, DXI->DXI_FAZ, cContam, xResult,;
				 					 cTipoResul, '', DXI->(Recno()))},STR0001,STR0003) //#"Atenção"##"Efetuando lançamento de contaminante para fardo"
				
				If RecLock('DXI',.F.)
					DXI->DXI_OK = ' '
					MsUnlock()
				Endif
			EndIf
			DXI->(dbSkip())
		EndDo
	End Transaction
	
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} PrepDXJ
//Preparação lançamento resultados contaminantes para mala
@author bruna.rocio
@since 28/03/2017
@version undefined
@param cContam, characters, descricao
@param cTipoResul, characters, descricao
@param xResult, , descricao
@param oGrid, object, descricao
@type function
/*/
Static Function PrepDXJ(cContam, cTipoResul, xResult, oGrid)
	Local aArea := GetArea()
	Local lRet  := .T.
	
	Begin Transaction
		DXJ->(dbGoTop())
		While .Not. DXJ->(Eof())
			
			If oGrid:IsMark()
				MsAguarde({||lRet := LancaResul(DXJ->DXJ_SAFRA, "DXJ", DXJ->DXJ_CODIGO, DXJ->DXJ_PRDTOR, DXJ->DXJ_LJPRO, DXJ->DXJ_FAZ,; 
				                     cContam, xResult, cTipoResul, "", DXJ->(Recno()))},STR0001,STR0004) //#"Atenção"##"Efetuando lançamento de contaminante para mala"
				
				If lRet
					lRet := FdoByMala( DXJ->DXJ_CODIGO, DXJ->DXJ_TIPO, cContam, cTipoResul, xResult )
				Endif
				
				If RecLock('DXJ',.F.)
					DXJ->DXJ_OK = ' '
					MsUnlock()
				Endif	
			EndIf
			DXJ->(dbSkip())
		EndDo
	End Transaction
	
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} PrepDXD
//Preparação lançamento resultados contaminantes para bloco
@author bruna.rocio
@since 28/03/2017
@version undefined
@param cContam, characters, descricao
@param cTipoResul, characters, descricao
@param xResult, , descricao
@param oGrid, object, descricao
@type function
/*/
Static Function PrepDXD(cContam, cTipoResul, xResult, oGrid)
	Local aArea := GetArea()
	Local lRet  := .T.
	
	Begin Transaction
		
		DXD->(dbGoTop())
		While .Not. DXD->(Eof())
			
			If oGrid:IsMark()
				MsAguarde({||lRet := LancaResul(DXD->DXD_SAFRA, "DXD", DXD->DXD_CODIGO, DXD->DXD_PRDTOR, DXD->DXD_LJPRO, DXD->DXD_FAZ, ; 
									 cContam, xResult, cTipoResul, "", DXD->(Recno()))},STR0001,STR0005) //#"Atenção"##"Efetuando lançamento de contaminante para bloco"
						 
				If lRet
					lRet := FdoByBloco( DXD->DXD_SAFRA, DXD->DXD_CODIGO, cContam, cTipoResul, xResult )
				Endif
				
				If RecLock('DXD',.F.)
					DXD->DXD_OK = ' '
					MsUnlock()
				Endif				
			EndIf
			DXD->(dbSkip())
		EndDo
	End Transaction
	
	RestArea(aArea)
Return lRet



/*/{Protheus.doc} FdoByMala
//Função que efetua o lançamento de fardos por mala
@author bruna.rocio
@since 04/04/2017
@version undefined
@param cMala, characters, descricao
@param cTpMala, characters, descricao
@param cContam, characters, descricao
@param cTipoResul, characters, descricao
@param xResult, , descricao
@type function
/*/
Static Function FdoByMala( cMala, cTpMala, cContam, cTipoResul, xResult)
	Local aArea    := GetArea()
	Local lRet     := .T.
	Local cAliasMl := GetNextAlias()
	
	BeginSql Alias cAliasMl
		Select DXI_SAFRA, DXI_ETIQ, DXI_PRDTOR, DXI_LJPRO, DXI_FAZ, DXI.R_E_C_N_O_ as RECNUM FROM %Table:DXK% DXK
		INNER JOIN %Table:DXI% DXI ON 
			DXI.%notDel%
		AND DXI.DXI_FILIAL = %xFilial:DXI%
		AND DXI.DXI_SAFRA  = DXK.DXK_SAFRA
		AND DXI.DXI_ETIQ   = DXK.DXK_ETIQ
	  WHERE DXK.%notDel%	
	    AND DXK.DXK_FILIAL = %xFilial:DXK%
	    AND DXK.DXK_CODROM = %exp:cMala%
	    AND DXK.DXK_TIPO   = %exp:cTpMala%
	EndSql 
		
	(cAliasMl)->(dbGoTop())
	While (cAliasMl)->(!Eof())
		
		MsAguarde({||lRet := LancaResul((cAliasMl)->DXI_SAFRA, "DXI", (cAliasMl)->DXI_ETIQ, (cAliasMl)->DXI_PRDTOR, (cAliasMl)->DXI_LJPRO, (cAliasMl)->DXI_FAZ,;
		 					 cContam, xResult, cTipoResul, '', (cAliasMl)->RECNUM)},STR0001,STR0003) //#"Atenção"##"Efetuando lançamento de contaminante para fardo"
		
		(cAliasMl)->(dbSkip())
	EndDo

	RestArea(aArea)
Return lRet



/*/{Protheus.doc} FdoByBloco
//Função que efetua o lançamento de fardos por bloco
@author bruna.rocio
@since 04/04/2017
@version undefined
@param cSafra, characters, descricao
@param cBloco, characters, descricao
@param cContam, characters, descricao
@param cTipoResul, characters, descricao
@param xResult, , descricao
@type function
/*/
Static Function FdoByBloco( cSafra, cBloco, cContam, cTipoResul, xResult )
	Local aArea  := GetArea()
	Local lRet   := .T.
	Local cAliBl := GetNextAlias()
	
	BeginSql Alias cAliBl
		Select DXI_SAFRA, DXI_ETIQ, DXI_PRDTOR, DXI_LJPRO, DXI_FAZ, R_E_C_N_O_ as RECNUM
			From %table:DXI% DXI
		   Where DXI_FILIAL = %xFilial:DXI%
		     And DXI_SAFRA  = %exp:cSafra%
		     And DXI_BLOCO  = %exp:cBloco%
	EndSql
	
	(cAliBl)->(dbGoTop())
	While (cAliBl)->(!Eof())
		
		MsAguarde({||lRet := LancaResul((cAliBl)->DXI_SAFRA, "DXI", (cAliBl)->DXI_ETIQ, (cAliBl)->DXI_PRDTOR,  (cAliBl)->DXI_LJPRO,  (cAliBl)->DXI_FAZ,;
		 								cContam, xResult, cTipoResul, '', (cAliBl)->RECNUM)},STR0001,STR0003) //#"Atenção"##"Efetuando lançamento de contaminante para fardo"
		
		(cAliBl)->(dbSkip())
	EndDo
		
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} FdoByMlEx
//Função que efetua a exclusão do lançamento de fardos por mala
@author silvana.torres
@since 28/04/2017
@version undefined
@param cMala, characters, descricao
@param cTpMala, characters, descricao
@param cContam, characters, descricao
@type function
/*/
Static Function FdoByMlEx( cMala, cTpMala, cContam)
	Local aArea    := GetArea()
	Local lRet     := .T.
	Local cAliasMl := GetNextAlias()
	
	BeginSql Alias cAliasMl
		Select DXI_SAFRA, DXI_ETIQ, DXI.R_E_C_N_O_ as RECNUM FROM %Table:DXK% DXK
		INNER JOIN %Table:DXI% DXI ON 
			DXI.%notDel%
		AND DXI.DXI_FILIAL = %xFilial:DXI%
		AND DXI.DXI_SAFRA  = DXK.DXK_SAFRA
		AND DXI.DXI_ETIQ   = DXK.DXK_ETIQ
	  WHERE DXK.%notDel%	
	    AND DXK.DXK_FILIAL = %xFilial:DXK%
	    AND DXK.DXK_CODROM = %exp:cMala%
	    AND DXK.DXK_TIPO   = %exp:cTpMala%
	EndSql 
		
	(cAliasMl)->(dbGoTop())
	While (cAliasMl)->(!Eof())
						 					 
		MsAguarde({||lRet := ExcResul((cAliasMl)->DXI_SAFRA, "DXI", (cAliasMl)->DXI_ETIQ, cContam, ;
				 			 		  '', (cAliasMl)->RECNUM)},STR0001,STR0008) //#"Atenção"##"Efetuando a exclusão do lançamento de contaminante para fardo"
		
		(cAliasMl)->(dbSkip())
	EndDo

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} FdoByBlEx
//Função que efetua a exclusão do lançamento de fardos por bloco
@author silvana.torres
@since 28/04/2017
@version undefined
@param cSafra, characters, descricao
@param cBloco, characters, descricao
@param cContam, characters, descricao
@type function
/*/
Static Function FdoByBlEx( cSafra, cBloco, cContam)
	Local aArea  := GetArea()
	Local lRet   := .T.
	Local cAliBl := GetNextAlias()
	
	BeginSql Alias cAliBl
		Select DXI_SAFRA, DXI_ETIQ, R_E_C_N_O_ as RECNUM
			From %table:DXI% DXI
		   Where DXI_FILIAL = %xFilial:DXI%
		     And DXI_SAFRA  = %exp:cSafra%
		     And DXI_BLOCO  = %exp:cBloco%
	EndSql
	
	(cAliBl)->(dbGoTop())
	While (cAliBl)->(!Eof())
		
		MsAguarde({||lRet := ExcResul((cAliBl)->DXI_SAFRA, "DXI", (cAliBl)->DXI_ETIQ, cContam, ;
				 					 '', (cAliBl)->RECNUM)},STR0001,STR0008) //#"Atenção"##"Efetuando a exclusão do lançamento de contaminante para fardo"
		
		(cAliBl)->(dbSkip())
	EndDo
		
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} LancaResul
//Função de lançamento de contaminantes
@author bruna.rocio
@since 28/03/2017
@version undefined
@param cSafra, characters, descricao
@param cEntidade, characters, descricao
@param cChvEnt, characters, descricao
@param cContam, characters, descricao
@param xResult, , descricao
@param cTipoResul, characters, descricao
@type function
/*/
Static Function LancaResul(cSafra, cEntidade, cCodigo, cProdutor, cLoja, cFazenda, cContam, xResult, cTipoResul, cProd, nRecno)
	Local lRet   := .T.
	Local aArea  := GetArea()
	Local cRecno := cEntidade + cValtoChar(nRecno)
	Local nSeq   := 1
	
	//Inativa os registros anteriores
	DbSelectArea("NPX")
	dbSetOrder(1)
	MsSeek(fwxFilial('NPX')+cSafra+PADR(cProd,TamSX3('NPX_CODPRO')[1],'')+PADR(cRecno,TamSX3('NPX_LOTE')[1],'')+;
		   PADR(cContam,TamSX3('NPX_CODTA')[1],'')+PADR(cContam,TamSX3('NPX_CODVA')[1],''))
		   
	While NPX->(!Eof())                      .And. ;
		NPX->NPX_FILIAL = fwxFilial('NPX')   .And. ;
		NPX->NPX_CODSAF = cSafra             .And. ;
		NPX->NPX_CODPRO = PADR(cProd,TamSX3('NPX_CODPRO')[1],'')   .And. ;
		NPX->NPX_LOTE   = PADR(cRecno,TamSX3('NPX_LOTE')[1],' ')   .And. ;
		NPX->NPX_CODTA  = PADR(cContam,TamSX3('NPX_CODTA')[1],' ') .And. ;
		NPX->NPX_CODVA  = PADR(cContam,TamSX3('NPX_CODVA')[1],' ')            
				
		If (NPX->NPX_ATIVO  = "1")
			AGRTRAVAREG("NPX",.f.)
			NPX->NPX_ATIVO  := "2"
			NPX->NPX_USUATU := SubStr(cusuario,7,15)
			AGRDESTRAREG("NPX")
		Endif
		nSeq++
		NPX->(DBSKIP())
	EndDo
		
	If RecLock('NPX',.T.)
		NPX->NPX_FILIAL := FwXFilial('NPX')
		NPX->NPX_CODPRO := cProd
		NPX->NPX_CODTA  := cContam
		NPX->NPX_CODVA  := cContam
		NPX->NPX_DESVA  := Posicione('N76',1,fwxFilial('N76')+cContam,'N76_DESCON')
		NPX->NPX_SEQ    := cValToChar(nSeq)
		NPX->NPX_LOTE   := cRecno
		NPX->NPX_CODSAF := cSafra
		NPX->NPX_TPPROD := "1"
		
		//se for Lista grava tipo de variavel como texto
		If cTipoResul == "4"
			NPX->NPX_TIPOVA := "2"
		
		//se for Faixa grava tipo de variavel como númerico
		ElseIf cTipoResul == "5"
			NPX->NPX_TIPOVA := "1"
		
		//senão grava tipo que estiver vindo como parâmetro (númerico, texto, data)
		Else
			NPX->NPX_TIPOVA := cTipoResul
		EndIf
		
		NPX->NPX_DTATU  := dDatabase
		NPX->NPX_ATIVO  := '1' //Sim
		NPX->NPX_USUATU := SubStr(cusuario,7,15) //Usuário
		
		Do Case
			Case cTipoResul = "1" //Numerico
				NPX->NPX_RESNUM := xResult[1]
			Case cTipoResul = "2" //Texto
				NPX->NPX_RESTXT := xResult[1]
			Case cTipoResul = "3" //Data
				NPX->NPX_RESDTA := xResult[1]
			Case cTipoResul = "4" //Lista
				NPX->NPX_RESTXT := xResult[1]
			Case cTipoResul = "5" //Faixa
				NPX->NPX_RESNUM := xResult[1]
				NPX->NPX_RESTXT := xResult[2]
		EndCase
				
		If cEntidade = "DXI"
				NPX->NPX_ETIQ   := cCodigo 
				NPX->NPX_FARDO  := Substr(cCodigo,14,6)
				NPX->NPX_PRDTOR := cProdutor 
				NPX->NPX_LJPRO  := cLoja 
				NPX->NPX_FAZ    := cFazenda 
		ElseIf cEntidade = "DXD"
				NPX->NPX_CDUBLC := Posicione('DXD',1,fwxFilial('DXD')+cSafra+cCodigo,'DXD_CODUNI') 
				NPX->NPX_BLOCO  := cCodigo 
				NPX->NPX_PRDTOR := cProdutor 
				NPX->NPX_LJPRO  := cLoja 
				NPX->NPX_FAZ    := cFazenda 
		ElseIf cEntidade = "DXJ"
				NPX->NPX_CDUMAL := Posicione('DXJ',3,fwxFilial('DXJ')+cSafra+cCodigo+"1",'DXJ_CODBAR')
				NPX->NPX_TPMALA := "1"
				NPX->NPX_ROMCLA := cCodigo 
				NPX->NPX_PRDTOR := cProdutor 
				NPX->NPX_LJPRO  := cLoja 
				NPX->NPX_FAZ    := cFazenda 	
		ElseIf cEntidade = "DXL"
				NPX->NPX_FARDAO := cCodigo 
				NPX->NPX_PRDTOR := cProdutor 
				NPX->NPX_LJPRO  := cLoja 
				NPX->NPX_FAZ    := cFazenda
		Endif
		
		MsUnlock()
	Endif
		
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} UBAX050EXC
//Função de exclusão de lançamento de contaminantes
@author silvana.torres
@since 11/04/2017
@version undefined
@param cContaminante, characters, descricao
@param cEntidade, characters, descricao
@param oGrid, object, descricao
@type function
/*/
Function UBAX050EXC(cContaminante, cEntidade, oGrid)
	Local lRet    := .T.
	Local aArea   := GetArea()
	
	Do Case
		Case cEntidade = "DXL"
			lRet := PrepEDXL(cContaminante, oGrid)
		Case cEntidade = "DXI"
			lRet := PrepEDXI(cContaminante, oGrid)
		Case cEntidade = "DXJ"
			lRet := PrepEDXJ(cContaminante, oGrid)
		Case cEntidade = "DXD"
			lRet := PrepEDXD(cContaminante, oGrid)
	EndCase
		
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} PrepEDXL
//Preparação de exclusão de lançamento resultados contaminantes para fardão
@author silvana.torres
@since 11/04/2017
@version undefined
@param cContam, characters, descricao
@param oGrid, object, descricao
@type function
/*/
Static Function PrepEDXL(cContam, oGrid)
	Local aArea := GetArea()
	Local lRet  := .T.
	
	private _lEntSCon := .F. /*variável para identificar se houve entidades selecionadas que não tinham o contaminante para ser excluído*/
	
	Begin Transaction
		
		DXL->(dbGoTop())
		While .Not. DXL->(Eof())
			
			If oGrid:IsMark()
				MsAguarde({||lRet := ExcResul(DXL->DXL_SAFRA, "DXL", DXL->DXL_CODIGO, DXL->DXL_PRDTOR, DXL->DXL_LJPRO ,DXL->DXL_FAZ,; 
									 cContam, DXL->DXL_CODPRO, DXL->(Recno()))},STR0001,STR0007) //#"Atenção"##"Efetuando exclusão de lançamento de contaminante para fardão"
												
				If RecLock('DXL',.F.)
					if lRet == .T.
						DXL->DXL_OK = ' '
					endif
					
					MsUnlock()
				Endif
			EndIf
			DXL->(dbSkip())
		EndDo
		
		if _lEntSCon == .T.
		 	Help(,,STR0001,,STR0012, 1, 0) //"ATENCAO"###"Há registros selecionados que não têm o contaminante infomado."
		endIf
		
	End Transaction
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} PrepEDXI
//Preparação de exclusão de lançamento resultados contaminantes para fardo
@author silvana.torres
@since 11/04/2017
@version undefined
@param cContam, characters, descricao
@param oGrid, object, descricao
@type function
/*/
Static Function PrepEDXI(cContam, oGrid)
	Local aArea := GetArea()
	Local lRet  := .T.
	
	private _lEntSCon := .F. /*variável para identificar se houve entidades selecionadas que não tinham o contaminante para ser excluído*/
	
	Begin Transaction
		DXI->(dbGoTop())
		While .Not. DXI->(Eof())
			
			If oGrid:IsMark()
				
				MsAguarde({||lRet := ExcResul(DXI->DXI_SAFRA, "DXI", DXI->DXI_ETIQ, /*Produtor*/, /*Loja*/, /*Fazenda*/, cContam, ;
				 					 '', DXI->(Recno()))},STR0001,STR0008) //#"Atenção"##"Efetuando exclusão de lançamento de contaminante para fardo"
				
				If RecLock('DXI',.F.)
					if lRet = .T.
						DXI->DXI_OK = ' '
					endif
					MsUnlock()
				Endif
			EndIf
			DXI->(dbSkip())
		EndDo
		
		if _lEntSCon = .T.
		 	Help(,,STR0001,,STR0012, 1, 0) //"ATENCAO"###"Há registros selecionados que não têm o contaminante infomado."
		endIf
	End Transaction
	
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} PrepEDXJ
//Preparação de exclusão de lançamento resultados contaminantes para mala
@author silvana.torres
@since 11/04/2017
@version undefined
@param cContam, characters, descricao
@param oGrid, object, descricao
@type function
/*/
Static Function PrepEDXJ(cContam, oGrid)
	Local aArea := GetArea()
	Local lRet  := .T.
	
	private _lEntSCon := .F. /*variável para identificar se houve entidades selecionadas que não tinham o contaminante para ser excluído*/
	
	Begin Transaction
	
		DXJ->(dbGoTop())
		While .Not. DXJ->(Eof())
			
			If oGrid:IsMark()
				MsAguarde({||lRet := ExcResul(DXJ->DXJ_SAFRA, "DXJ", DXJ->DXJ_CODIGO, /*Produtor*/, /*Loja*/, /*Fazenda*/,; 
				                     cContam, "", DXJ->(Recno()))},STR0001,STR0009) //#"Atenção"##"Efetuando exclusão de lançamento de contaminante para mala"
				
				If RecLock('DXJ',.F.)
					if lRet == .T.
						DXJ->DXJ_OK = ' '
						
						lRet := FdoByMlEx(DXJ->DXJ_CODIGO, DXJ->DXJ_TIPO, cContam)
					endif
					
					MsUnlock()
				Endif	
			EndIf
			DXJ->(dbSkip())
		EndDo
		
		if _lEntSCon == .T.
		 	Help(,,STR0001,,STR0012, 1, 0) //"ATENCAO"###"Há registros selecionados que não têm o contaminante infomado."
		endIf
	End Transaction
	
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} PrepEDXD
//Preparação de exclusão de lançamento resultados contaminantes para bloco
@author silvana.torres
@since 11/04/2017
@version undefined
@param cContam, characters, descricao
@param oGrid, object, descricao
@type function
/*/
Static Function PrepEDXD(cContam, oGrid)
	Local aArea := GetArea()
	Local lRet  := .T.
	
	private _lEntSCon := .F. /*variável para identificar se houve entidades selecionadas que não tinham o contaminante para ser excluído*/
	
	Begin Transaction
		
		DXD->(dbGoTop())
		While .Not. DXD->(Eof())
			
			If oGrid:IsMark()
				MsAguarde({||lRet := ExcResul(DXD->DXD_SAFRA, "DXD", DXD->DXD_CODIGO, /*Produtor*/, /*Loja*/ , /*Fazenda*/,; 
									 cContam, "", DXD->(Recno()))},STR0001,STR0010) //#"Atenção"##"Efetuando exclusão de lançamento de contaminante para bloco"
									 
				If RecLock('DXD',.F.)
					if lRet == .T.
						DXD->DXD_OK = ' '
						
						lRet := FdoByBlEx( DXD->DXD_SAFRA, DXD->DXD_CODIGO, cContam)
					endif
					MsUnlock()
				Endif				
			EndIf
			DXD->(dbSkip())
		EndDo
		
		if _lEntSCon == .T.
		 	Help(,,STR0001,,STR0012, 1, 0) //"ATENCAO"###"Há registros selecionados que não têm o contaminante infomado."
		endIf
	End Transaction
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} ExcResul
//Função de exclusão de lançamento de contaminantes
@author silvana.torres
@since 11/04/2017
@version undefined
@param cSafra, characters, descricao
@param cEntidade, characters, descricao
@param cChvEnt, characters, descricao
@param cContam, characters, descricao
@type function
/*/
Static Function ExcResul(cSafra, cEntidade, cCodigo, cProdutor, cLoja, cFazenda, cContam, cProd, nRecno)
	Local lRet  := .T.
	Local aArea := GetArea()
	
	dbSelectArea('NPX')
	
	If cEntidade = "DXI"
		dbSetOrder(4)
		If MsSeek(FwXFilial('NPX')+cSafra+cCodigo+PADR(_cGetContam,TamSx3('NPX_CODTA')[1],'')+"1")
			If Reclock('NPX',.F.)
				dbDelete()
				MsUnlock()
			Else
				_lEntSCon := .T.
				lRet  	  := .F.	
			Endif
		Endif
	ElseIf cEntidade = "DXD"
		dbSetOrder(5)
		If MsSeek(FwXFilial('NPX')+cSafra+cCodigo+PADR(_cGetContam,TamSx3('NPX_CODTA')[1],'')+"1")
			If Reclock('NPX',.F.)
				dbDelete()
				MsUnlock()
			Else
				_lEntSCon := .T.
				lRet  	  := .F.	
			Endif
		Endif
	ElseIf cEntidade = "DXJ"
		dbSetOrder(6)
		If MsSeek(FwXFilial('NPX')+cSafra+cCodigo+"1"+PADR(_cGetContam,TamSx3('NPX_CODTA')[1],'')+"1") //mala visual
			If Reclock('NPX',.F.)
				dbDelete()
				MsUnlock()
			Else
				_lEntSCon := .T.
				lRet  	  := .F.	
			Endif
		Endif
	ElseIf cEntidade = "DXL"
		dbSetOrder(7)
		If MsSeek(FwXFilial('NPX')+cCodigo+cSafra+cProdutor+cLoja+cFazenda+PADR(_cGetContam,TamSx3('NPX_CODTA')[1],'')+"1")
			If Reclock('NPX',.F.)
				dbDelete()
				MsUnlock()
			Else
				_lEntSCon := .T.
				lRet  	  := .F.	
			Endif
		Endif
	Endif		
	
	RestArea(aArea)
Return lRet