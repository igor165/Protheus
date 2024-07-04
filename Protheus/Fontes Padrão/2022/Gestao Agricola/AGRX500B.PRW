#INCLUDE "AGRX500.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//======================================================================================
/*****  Funções de solução de pendências fiscais da rotina AGRX500 - Romaneios   *****/
//======================================================================================

#DEFINE OP_EFE	"011" // Efetivar

/*/{Protheus.doc} AGRX500BCF
//Função solução complemento fiscal
@author marina.muller  / silvava.torres
@since 19/02/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function AGRX500SCF(aPendN9C, nValPend, cSafra, cEntidade, cLojEnt, cProduto, oModel)
	Local aArea     := GetArea()
	Local lRet 	    := .T.
	Local cFilCli   := ""
	
	If Select('SD1') <= 0
        dbSelectArea('SD1')
    EndIf
    If Select('SD2') <= 0
        dbSelectArea('SD2')
    EndIf
    If Select('SD3') <= 0
        dbSelectArea('SD3')
    EndIf
    
    //gera produção para quantidade excedente
    lRet := AX500PCFis(aPendN9C, nValPend, cSafra, cEntidade, cLojEnt, cProduto)
	
	If lRet
       //função transferência chama MATA311
       Processa({|| lRet := AGRX500TRE(nValPend, cSafra, cEntidade, cLojEnt, cProduto, "", "", .F., "", aPendN9C)}, STR0036, STR0004 ) //"Gerando transferência..."###"Aguarde"
	EndIf

	//função efetiva transferência chama MATA311
	If lRet
	   Processa({|| lRet := AGRX500EFT()}, STR0041, STR0004 ) //"Efetivando transferência..."###"Aguarde"
	EndIf   
	
	If lRet
	   cFilCli := aPendN9C[3][1] //filial origem da pendência
	   
	   //vincula nota de entrada como nota complementar do romaneio   	  
	   lRet := AGRX500ATN(cSafra, cEntidade, cLojEnt, aPendN9C, cFilCli)
	EndIf
		   
    RestArea(aArea)
    
Return lRet


/*/{Protheus.doc} AGRX500EFT
//Função chama efetivação da transferência MATA311
@author marina.muller
@since 28/02/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AGRX500EFT()
	Local aArea     := GetArea()
	Local lRet 	    := .T.
	Local oModel
    Local aDadoscab	:= {}
    
    Private cOpId311 := OP_EFE
    Private lMsErroAuto := .F.
    
    nModulo := 4  //estoque/custos
    
    //Instancia o Model do MATA311
    oModel := FwLoadModel("MATA311")
    
    aRotina := {}
    
    NNS->(DbSetOrder(1))
	NNS->(DbSeek(FWxFilial("NNS",__cNNTFil) + __cNNTCod))
	
	lMsErroAuto := .F.
	
	aAdd(aDadoscab, {"NNS_CLASS", '2' , Nil})
	aAdd(aDadoscab, {"NNS_COD", __cNNTCod , Nil})
	
	FWMVCRotAuto( oModel,"NNS",4,{{"NNSMASTER", aDadoscab}})
	
	//Se houve erro no ExecAuto, mostra mensagem
	If lMsErroAuto
	     lRet := .F.
	EndIf
	    
    // Desativamos o Model
    oModel:DeActivate()
    
    nModulo := 67  //agro-industria
   
    RestArea(aArea)

Return lRet 


/*/{Protheus.doc} AGRX500ATN
//Função vincula nota de entrada como nota complementar do romaneio que originou pendência
@author marina.muller
@since 27/02/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function AGRX500ATN(cSafra, cEntidade, cLojEnt, aPendN9C, cFilCli)
   Local aArea     := GetArea()
   Local lRet 	   := .T.
   Local cNNTDoc   := ""
   Local cNNTSerie := ""
   Local cFilRom   := ""
   Local cCodRom   := ""    
   
   //busca nota e serie gerada na efetivação da transferência
   DbSelectArea("NNT")
   NNT->(dbSetOrder(1))
   If NNT->(MsSeek(__cNNTFil+__cNNTCod)) //filial+código transferência
   	  cNNTDoc   := NNT->NNT_DOC   
   	  cNNTSerie := NNT->NNT_SERIE
   Else
      Help( ,, STR0043,, STR0042, 1, 0) //'Erro'###"Não encontrou registro de transferência."
      lRet := .F.
   EndIf	  
   NNT->( DbCloseArea())
	   	  
   //busca romaneio para vincular nota de entrada como nota complementar 	
   If lRet
	   DbSelectArea("NJM")
	   NJM->(dbSetOrder(1))
	  
   	   If NJM->(MsSeek(cFilCli+aPendN9C[1][1])) //filial+código romaneio
   	      cFilRom := cFilCli
   	      cCodRom := aPendN9C[1][1]
   	     
   	      If RecLock( "NJM", .F. )
   	         NJM->NJM_NUMCOM := cNNTDoc 
   	         NJM->NJM_SERCOM := cNNTSerie 
   	         NJM->( msUnLock() ) 
	   	  Else
	   	      Help( ,, STR0044,, STR0042, 1, 0) //'Erro'###"Não encontrou romaneio para atualizar nota complementar."
	   	      lRet := .F.
	   	  EndIf
	   EndIf	  
	   NJM->( DbCloseArea())
   EndIf	   
      
   RestArea(aArea)

Return lRet


/*/{Protheus.doc} AGRX500TRE
//Função para transferência do excedente entre filiais (chama MATA311)
@author marina.muller  / silvava.torres
@since 20/02/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function AGRX500TRE(nValPend, cSafra, cEntidade, cLojEnt, cProduto, cTes, cLocal, lSaiAut, cTesEnt, aPendN9C)
	Local nI         := 0
	Local nPos       := 0
	Local aArea      := GetArea()
	Local aCposCab   := {}
	Local aCposDet   := {}
	Local aAux       := {}
	Local aErro      := {}
	Local aDadosNJJ  := {}
	Local lRet       := .T.
	Local lAux       := .T.
	Local cFilDes    := ""
	Local cFilOri    := ""
	Local oAux
	Local oModel
	Local oStruct
	Local lUltOg     := SuperGetMV('MV_AGRORI',.F.,.F.)
	Local cSerieAgro := SuperGetMV("MV_OGASERS",," ")
	
	nModulo := 4  //estoque/custos
	
	//inicializa variaveis estaticas
	__cNNTFil := "" 
    __cNNTCod := ""
	
	//Instancia o Model do MATA311
	oModel := FwLoadModel("MATA311")

	//Campos do cabeçalho
	aCposCab := {}
	aAdd(aCposCab,{"NNS_DATA"  ,dDataBase})
	aAdd(aCposCab,{"NNS_STATUS","2"})  //estamos enviando status como "2", porque invertem o valor na função A311ActMod()
	aAdd(aCposCab,{"NNS_CLASS" ,"2"})
    
    //se array tiver mais que 3 posições veio da gestão de pendência
    If len(aPendN9C) > 3
       cFilOri := aPendN9C[4][1] //filial romaneio origem
    Else
       //senão veio  saída por transferência
       cFilOri := aPendN9C[1][3]
    EndIf   

    //Busca filial informada na correspondente ao cliente 
   	cFilDes := AGRX500POF(cEntidade, cLojEnt)
   
	//Busca informações do romaneio na NJJ/SB1/N92   
	aDadosNJJ := AGRX500LOC(aPendN9C, cFilOri)
  
	//Campos detalhe
   	aAux := {}
   	aAdd(aAux,{"NNT_FILORI", cFilOri      })
   	aAdd(aAux,{"NNT_PROD"  , cProduto     })
   	aAdd(aAux,{"NNT_UM"    , aDadosNJJ[3] })
   	aAdd(aAux,{"NNT_LOCAL" , aDadosNJJ[2] }) //Local de origem
   	aAdd(aAux,{"NNT_POTENC", 0            })
   	aAdd(aAux,{"NNT_QUANT" , nValPend     })
   
   	aAdd(aAux,{"NNT_FILDES", cFilDes      })
   	aAdd(aAux,{"NNT_PRODD" , cProduto     })
   	aAdd(aAux,{"NNT_UMD"   , aDadosNJJ[3] })
   
   	If lSaiAut
   		aAdd(aAux,{"NNT_LOCLD" , cLocal }) //Local do tipo de operação (destino)
   	Else
   		aAdd(aAux,{"NNT_LOCLD" , aDadosNJJ[8] }) //Local do tipo de operação (destino)
   	EndIf

   	If lSaiAut
   		aAdd(aAux,{"NNT_TS"    , cTes		  }) //TES romaneio saída	   
   		aAdd(aAux,{"NNT_TE"    , cTesEnt 	  }) //TES romaneio entrad
   	Else   
   		//tipo for entrada por transferência
   		If aDadosNJJ[6] == "A"
   			aAdd(aAux,{"NNT_TS"    , aDadosNJJ[5] }) //TES N92
   			aAdd(aAux,{"NNT_TE"    , aDadosNJJ[4] }) //TES NJJ
   		//tipo for saída por transferência
   		Else
   			aAdd(aAux,{"NNT_TS"    , aDadosNJJ[4] }) //TES NJJ	   
   			aAdd(aAux,{"NNT_TE"    , aDadosNJJ[5] }) //TES N92
   		EndIf
   	End If
   
   	aAdd(aAux,{"NNT_OBS"   , "AGRX500"    })
   
   	aAdd(aAux,{"NNT_LOTECT" 	, aDadosNJJ[9] 	}) 
   	aAdd(aAux,{"NNT_NUMLOTE" , aDadosNJJ[10] }) 
   	aAdd(aAux,{"NNT_LOCALI" 	, aDadosNJJ[11]	})
   	aAdd(aAux,{"NNT_LOTED" 	, aDadosNJJ[9] 	})
   
   	//se for processo do AGRO e parâmetro serie preenchido
   	If lUltOg .And. !Empty(cSerieAgro)
   		aAdd(aAux,{"NNT_SERIE" 	, PadR(cSerieAgro,3) 	})
   	EndIf  

	aCposDet := {}
	aAdd(aCposDet,aAux)

	aAux := {}

	dbSelectArea("NNS")
	dbSetOrder(1)
	dbSelectArea("NNT")
	dbSetOrder(1)

	//Seta operação de Inclusão
	oModel:SetOperation(3)
	//Ativa o modelo
	oModel:Activate()

	//Instancia o modelo referente ao cabeçalho
	oAux := oModel:GetModel( 'NNSMASTER' )
	//Obtem a estrutura de dados do cabeçalho
	oStruct := oAux:GetStruct()

	aAux := oStruct:GetFields()
	lRet := .T.
	For nI := 1 To Len(aCposCab)
		// Verifica se os campos passados existem na estrutura do cabeçalho
		If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCposCab[nI][1] ) } ) ) > 0
			// É feita a atribuição do dado ao campo do Model do cabeçalho
			If !( lAux := oModel:SetValue( 'NNSMASTER', aCposCab[nI][1],aCposCab[nI][2] ) )
				// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
				// o método SetValue retorna .F.
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nI

	If lRet
		// Instanciamos apenas a parte do modelo referente aos dados do item
		oAux := oModel:GetModel( 'NNTDETAIL' )
		// Obtemos a estrutura de dados do item
		oStruct := oAux:GetStruct()
		aAux := oStruct:GetFields()

		For nI := 1 To Len( aCposDet[1] )
			// Verifica se os campos passados existem na estrutura de item
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCposDet[1][nI][1] ) } ) ) > 0
				If !( lAux := oModel:SetValue( 'NNTDETAIL', aCposDet[1][nI][1], aCposDet[1][nI][2] ) )
					// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
					// o método SetValue retorna .F.
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next
	EndIf

	If lRet
		// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
		// neste momento os dados não são gravados, são somente validados.
		If ( lRet := oModel:VldData() )
			// Se os dados foram validados faz-se a gravação efetiva dos
			// dados (commit)
			lRet := FWFormCommit(oModel)
		EndIf
	EndIf

	If !lRet
		// Se os dados não foram validados obtemos a descrição do erro para gerar
		// LOG ou mensagem de aviso
		aErro := {}
		aErro := oModel:GetErrorMessage()

      AutoGrLog( STR0026 + ' [' + AllToChar( aErro[1] ) + ']' )
	  AutoGrLog( STR0027 + ' [' + AllToChar( aErro[2] ) + ']' )
	  AutoGrLog( STR0028 + ' [' + AllToChar( aErro[3] ) + ']' )
	  AutoGrLog( STR0029 + ' [' + AllToChar( aErro[4] ) + ']' )
	  AutoGrLog( STR0030 + ' [' + AllToChar( aErro[5] ) + ']' )
	  AutoGrLog( STR0031 + ' [' + AllToChar( aErro[6] ) + ']' )
	  AutoGrLog( STR0032 + ' [' + AllToChar( aErro[7] ) + ']' )
	  AutoGrLog( STR0033 + ' [' + AllToChar( aErro[8] ) + ']' )
	  AutoGrLog( STR0034 + ' [' + AllToChar( aErro[9] ) + ']' )
	  MostraErro()
   Else
      __cNNTFil := NNS->NNS_FILIAL  //filial da transferência
      __cNNTCod := NNS->NNS_COD     //código da transferência 
   EndIf
   
   // Desativamos o Model
   oModel:DeActivate()

   NNS->(dbCloseArea())
   NNT->(dbCloseArea())
   
   nModulo := 67  //agro-industria
   
   RestArea(aArea)

Return lRet

/*/{Protheus.doc} A500TRANSF
//Interferência no MATA311, manipulando a variavel lRegTransf.
@author brunosilva
@since 23/02/2018
@version undefined
@param lUltOg, logical, vindo do MATA311
// LRT = Lógico de: Registra transferência?
@type function
/*/
Function AGRX500LRT(lRegTransf)
	If IsInCallStack('A500ConfRom')
		lRegTransf := .T.
	EndIf
	
	If IsInCallStack('AGRX500SCF')
		lRegTransf := .T.
	EndIf
Return .T. 

/*/{Protheus.doc} AGRX500PED
// Responsável pela geração de pedido caso o romaneio seja tipo B - saída por transferência
// e não pré-romaneio no destino.
@author brunosilva
@since 15/02/2018
@version undefined
@param cCodRom, characters, código do romaneio
@type function
/*/
Function AGRX500PED(cCodRom)
	Local oModel		 := FWLoadModel( 'AGRA500' )
	Local oMdlNJM        := Nil
	Local aArea          := GetArea()
	Local aPedido		 := {{},{}}
	Local cPvGerado	     := Criavar("C5_NUM",.F. )  // Ira Armazenar o nr. do Pv Gerado
	Local cSerie         := SuperGetMV("MV_OGASERS",," ")
	Local aRet           := {}
	Local aRetPe         := {}
	Local lRet           := .T.
	Local cAliasQry      := ""
	Local cQry
	Local cNatureza		 := ""
	
	Private lMsErroAuto  := .F.
	Private _aCab		 := {}
	Private _aItens 	 := {}
	
	oModel:Activate()
	oMdlNJM := oModel:GetModel( 'AGRA500_NJM' )
	
	cAliasQry := GetNextAlias()
	
	cQry := " SELECT * FROM "+ RetSqlName("NJM") +" NJM "
	cQry += " WHERE NJM_FILIAL = '" + FWxFilial('NJM') + "' "
	cQry += " AND  NJM_CODROM  = '" + cCodRom + "'" 
	cQry += " AND D_E_L_E_T_<> '*' "
	
	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	
	
	nModulo := 5
	
	/*IF nOpPed == MODEL_OPERATION_UPDATE .or. nOpPed == MODEL_OPERATION_DELETE
		aAdd( aPedido[1], { "C5_NUM", (cAliasQry)->NJM_PEDIDO, nil } )
	EndIF*/

	//posiciona o cliente para buscar outras informações
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	SA1->(DbSeek(FWxFilial("SA1")+Posicione('NJ0',1,FWxFilial('NJ0')+((cAliasQry)->NJM_CODENT)+(cAliasQry)->NJM_LOJENT,'NJ0_CODCLI')+Posicione('NJ0',1,FWxFilial('NJ0')+((cAliasQry)->NJM_CODENT)+(cAliasQry)->NJM_LOJENT,'NJ0_LOJCLI')))

	//posiciona a regra fiscal para pegar a natureza/ se estiver em branco usa do cliente
	cNatureza := Posicione("N9A",1,(cAliasQry)->NJM_FILORG+(cAliasQry)->NJM_CODCTR+(cAliasQry)->NJM_ITEM+(cAliasQry)->NJM_SEQPRI,"N9A_NATURE")
	If Empty(cNatureza)
		cNatureza := SA1->A1_NATUREZ
	EndIf

	//busca o tipo de frete do romaneio, se estiver em branco usa do contrato
	cTpFrete := FWFLDGET("NJJ_FRETE")
	If Empty(cTpFrete)
		cTpFrete := Posicione("NJR",1,(cAliasQry)->NJM_FILORG+(cAliasQry)->NJM_CODCTR,"NJR_TPFRET")
	EndIf

	aAdd(aPedido[1],{"C5_CODROM"   , cCodRom 				, Nil})
	aAdd(aPedido[1],{"C5_TIPO"     , "N"	 				, Nil})
	aAdd(aPedido[1],{"C5_CLIENTE"  , SA1->A1_COD			, Nil})
	aAdd(aPedido[1],{"C5_LOJACLI"  , SA1->A1_LOJA			, Nil})
	aAdd(aPedido[1],{"C5_TIPOCLI"  , SA1->A1_TIPO		 	 , Nil})
	aAdd(aPedido[1],{"C5_CLIENT"   , Posicione('NJ0',1,FWxFilial('NJ0')+FWFLDGET("NJJ_ENTENT")+FWFLDGET("NJJ_ENTLOJ"),'NJ0_CODCLI')    , Nil}) 
	aAdd(aPedido[1],{"C5_LOJAENT"  , Posicione('NJ0',1,FWxFilial('NJ0')+FWFLDGET("NJJ_ENTENT")+FWFLDGET("NJJ_ENTLOJ"),'NJ0_LOJCLI')    , Nil})
	aAdd(aPedido[1],{"C5_CONDPAG"  , Iif(!(EMPTY((cAliasQry)->NJM_CONDPG)),(cAliasQry)->NJM_CONDPG, '001') , Nil})
	aAdd(aPedido[1],{"C5_CODSAF"   , (cAliasQry)->NJM_CODSAF , Nil})
	aAdd(aPedido[1],{"C5_MOEDA"    , 1     					 , Nil})
	aAdd(aPedido[1],{"C5_TRANSP"   , FWFLDGET("NJJ_CODTRA")  , Nil})
	aAdd(aPedido[1],{"C5_TPFRETE"  , FWFLDGET("NJJ_TPFRET")  , Nil})
	aAdd(aPedido[1],{"C5_FRETE"    , cTpFrete			     , Nil})
	aAdd(aPedido[1],{"C5_SEGURO"   , FWFLDGET("NJJ_SEGURO")  , Nil})
	aAdd(aPedido[1],{"C5_DESPESA"  , FWFLDGET("NJJ_DESPES")  , Nil})
	aAdd(aPedido[1],{"C5_TIPLIB"   , "1"     				 , Nil})
	aAdd(aPedido[1],{"C5_VEICULO"  , FWFLDGET("NJJ_PLACA")   , Nil})
	aAdd(aPedido[1],{"C5_NATUREZ"  , cNatureza				 , Nil})
	aAdd(aPedido[1],{"C5_ORIGEM"   , 'AGRA500'				 , Nil})
	aAdd(_aCab, aPedido[1])
		                                                           
	aAdd(aPedido[2], {"C6_ITEM"	   , '01'   			     , Nil})
	aAdd(aPedido[2], {"C6_PRODUTO" , (cAliasQry)->NJM_CODPRO , Nil})
	aAdd(aPedido[2], {"C6_QTDVEN"  , (cAliasQry)->NJM_QTDFCO , Nil})
	aAdd(aPedido[2], {"C6_QTDLIB"  , (cAliasQry)->NJM_QTDFCO , Nil})
	aAdd(aPedido[2], {"C6_TES"     , Iif(!(EMPTY((cAliasQry)->NJM_TES)),(cAliasQry)->NJM_TES,FWFLDGET('NJJ_TES')), Nil})
	aAdd(aPedido[2], {"C6_PRCVEN"  , Posicione('SB1',1,FWxFilial('SB1')+(cAliasQry)->NJM_CODPRO,'B1_PRV1'), Nil})
	aAdd(_aItens, aPedido[2])
		
	If !(Empty(_aItens)) 
		//PONTO DE ENTRADA PARA GERAÇÃO DE PEDIDO DE VENDA A PARTIR DE UMA SAIDA POR TRANSFERENCIA
		//SEM GERAÇÃO DE PRE ROMANEIO NO DESTINO.
		If EXISTBLOCK ("AGX500BT") 
			aRetPe := ExecBlock("AGX500BT",.F.,.F.,{oModel, aPedido[1], _aItens})
			
			If Len(aRetPe) == 2 .And. ValType(aRetPe[1]) == "A" .And. ValType(aRetPe[2]) == "A"
				aPedido[1] := aRetPe[1]
				_aItens    := aRetPe[2]
			EndIf
		EndIf
		
		_aCab      := aPedido[1]
		aPedido[1] := FWVetByDic(_aCab,'SC5')
		_aItens    := FWVetByDic(_aItens,'SC6',.T.)
		MsgRun( STR0037, STR0001, {||MSExecAuto({|a,b,c|Mata410(a,b,c)},_aCab,_aItens,3)}) //"Gerando Pedido de Venda."  //"Romaneio" 
	EndIf
		
	If lMsErroAuto .OR. Empty(_aItens) .OR. !lRet
		RollBackSx8()
		MostraErro()
		lRet := .F.
	Else
		ConfirmSx8()
		cPvGerado := SC5->C5_NUM
		AGRGRAVAHIS(,,,,{"NJJ",FWxFilial("NJJ")+cCodRom,"4",STR0039}) //"Pedido gerado com sucesso."
	EndIf
		
	IF !(Empty(cPVGerado)) 
		//Deixado para caso algum dia tenha necessidade de se pegar o numero da série 
		//pelo contrato vinculado.
		/*cSerie := NJM->(NJM_DOCSER) Neste caso não vincula contrato
		If Empty(cSerie)
            //Busca serie de nota de Saida  *Parametro*
            cSerie    := SuperGetMV("MV_OGASERS",," ")
        EndIf*/
        
		MsgRun( STR0038, STR0001, {|| aRet := AgrGeraNFS( cPVGerado, cSerie ) } ) //"Gerando NF de Saida." //"Romaneio"
	
		If Len( aRet ) == 0
            MsgInfo (STR0039 + cCodRom +" "+  NJM->( NJM_ITEROM )) //"Não foi possível gerar o Documento de Saída para o Romaneio "
            lRet := .F.
        Else
        	dbSelectArea('NJM')
            dbSetOrder(1)
            If NJM->(msSeek(FWxFilial('NJM')+cCodRom))
            	If RecLock( "NJM", .F. )
					NJM->NJM_PEDIDO := cPVGerado
					NJM->NJM_DOCNUM := aRet[1]
					NJM->NJM_DOCSER := aRet[2]
					msUnLock()
				EndIf
            EndIf
        EndIF
	EndIF
		
	nModulo := 67
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} AX500SPDFc
Função para solucionar pendência de devolução fiscal
@author silvana.torres
@since 05/04/2018
@version undefined
@param aPendN9C, array, descricao
@param nValPend, numeric, descricao
@param cSafra, characters, descricao
@param cEntidade, characters, descricao
@param cLojEnt, characters, descricao
@param cProduto, characters, descricao
@type function
/*/
Function AX500SPDFc(aPendN9C, nValPend, cSafra, cEntidade, cLojEnt, cProduto)
	
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
	Local cFilOri	:= cFilAnt	//--SALVA A FILIAL LOGADA
	
	Private lMsErroAuto := .F.
	Private lMSHelpAuto	:= .T.
	
	//--ALTERA A FILIAL CORRENTE PARA A FILIAL DA PRODUÇÃO
	//================================
	cFilAnt := aPendN9C[4][1]			
	//================================
	
	lOPEspec := ExistBlock("AGRX50OP")
	
	lAlgodao := if(Posicione("SB5",1,fwxFilial("SB5")+cProduto,"B5_TPCOMMO")== '2',.T.,.F.)
	
	if lAlgodao		
		//busca os fardões do romaneio
		DbSelectArea('DX0')
		DbSetOrder(3)
	
		If MsSeek(fwxFilial('DX0')+aPendN9C[5][1]) //FILIAL + ROMANEIO
    
		 	While DX0->(!Eof()) .And.;
		 		  DX0->DX0_FILIAL = FWxFilial("DX0") .And.;
		 		  DX0->DX0_NRROM  = aPendN9C[5][1]	  
                  
                cAliasFar := GetNextAlias()
                
				//busca o numéro da OP e o número do apontamento de produção para cada fardão
				cQuery2 := "SELECT * FROM  " + RetSqlName('DXB')+ " DXB " 
				cQuery2 += " WHERE DXB.D_E_L_E_T_ = ''              
				cQuery2 += " 	AND DXB.DXB_FILIAL = '"+ fwxFilial('DXB') +"'" 
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
		cQuery2 += "   AND NJJ.NJJ_FILIAL = '"+ FWxFilial("NJJ")	 +"'" 
		cQuery2 += "   AND NJJ.NJJ_CODROM = '" + aPendN9C[5][1] + "'"
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
	Else
		return .F.
	EndIf
		 		
	If lRet
		//-- Realiza o apontamento da OP 
		//Retorno := (Numero da OP - Modelo - Operação de Inclusão)
		Processa({|| lRet := A500APROD(cNumOP, NJJ->NJJ_CODROM, cProduto, nValPend, cLocal, 3) }, STR0003, STR0004 ) //"Movimentando Ordem de Produção..."###"Aguarde"
	Else
		return .F.
	EndIf
	
	//--RETORNA COM A FILIAL DE ORIGEM 
	//================================
	cFilAnt := cFilOri
	//================================
		
	If lRet
		if lAlgodao
			//-- Grava o rastro da devolução física
			lRet := AGRX500RAS(cNumOP, aPendN9C, "AX500SPDFc")
		endIf
	Else
		return .F.
	EndIf
		
	If .Not. lRet
		return .F.
	Endif	
		
	RestArea(aArea)
	
Return lRet




/*/{Protheus.doc} AGRX500SPA
// Responsável por solucionar as pendências automaticamente quando a flag estiver marcada
@author brunosilva
@since 15/05/2018
@version undefined
@param cTipo, characters, 2 - Comp. Fiscal, 4 - Dev.Fiscal
@type function
/*/
Function AGRX500SPA(cTipo)
	Local cFilTemp	:= cFilAnt
	Local aPendN9C	:= {} 
	Local aOutN9C	:= {} //dados adicionais que preciso da N9C e não podem ser passados para o aPendN9C
	Local cEntOri
	Local cLojOri
	Local aAreaNJ0	:= GetArea('NJ0')
	Local lRetorno	:= .F.
	Local lAlgodao	:= .F.
	Local oMdl520	:= Nil

	//===========================================================================//
	/********************* SOLUÇÃO AUTOMÁTICA DE PENDÊNCIAS **********************/
	//===========================================================================//
	aAdd(aPendN9C, {N9C->N9C_CODROM})  //1 - romaneio
    aAdd(aPendN9C, {N9C->N9C_ITEM  })  //2 - item da pendência
    aAdd(aPendN9C, {N9C->N9C_FILORI})  //3 = filial origem da pendência
    aAdd(aPendN9C, {N9C->N9C_FILROM})  //4 = filial romaneio origem 
    aAdd(aPendN9C, {N9C->N9C_ROMORI})  //5 = romaneio origem
    aAdd(aPendN9C, {N9C->N9C_FILIAL})  //6 = filial romaneio
    aAdd(aPendN9C, {N9C->N9C_TPPEN })  //7 = tipo pendencia
    aAdd(aPendN9C, {N9C->N9C_CODPRO})  //8 = produto
    
    aAdd(aOutN9C, {N9C->N9C_FILIAL})   //1 = Filial do registro
    aAdd(aOutN9C, {N9C->N9C_CODSAF})   //2 = Safra
    aAdd(aOutN9C, {N9C->N9C_CODENT})   //3 = Codigo da entidade
    aAdd(aOutN9C, {N9C->N9C_LOJENT})   //4 = Loja da entidade
    aAdd(aOutN9C, {N9C->N9C_QTDPEN})   //5 = Quantidade da pendencia    
    
    lAlgodao := if(Posicione("SB5",1,FWxFilial("SB5")+aPendN9C[8][1],"B5_TPCOMMO")== '2',.T.,.F.)
	
	if cTipo == '4' // DevFiscal	 	
		lRetorno := .T.		
    	/*If lAlgodao
    		lRetorno := AX520APFar(N9C->N9C_FILORI, N9C->N9C_CODROM, N9C->N9C_QTDPEN) //ajusta o peso do fardão
    	EndIf*/		
    	
    	dbSelectArea('NJ0')
		NJ0->(dbSetOrder(5))
		If NJ0->(MsSeek(FWxFilial('NJ0')+N9B->N9B_FILIAL)) 
			cEntOri := NJ0->NJ0_CODENT
			cLojOri := NJ0->NJ0_LOJENT
		EndIf
		RestArea(aAreaNJ0)
						
		if lRetorno
	    	//Gera PV e NF com tipo de devolução com a quantidade da pendencia.			
			MsgRun( STR0004, STR0040, {||lRetorno := AGRX520PED(N9C->N9C_FILORI, N9C->N9C_CODROM, ABS(N9C->N9C_QTDPEN), cEntOri, cLojOri, N9C->N9C_ROMORI)}) //"Aguarde" //"Solucionando pendência."
		endIF
			
		If lRetorno
			dbSelectArea("N9B")
			N9B->(dbSetOrder(1))
			N9B->(DbSeek(FWxFilial("N9B") + N9C->N9C_CODSAF + N9C->N9C_CODENT + N9C->N9C_LOJENT + N9B->N9B_CODPRO ))
										
			oMdl520 := FwLoadModel("AGRA520")
			oMdl520:SetOperation( MODEL_OPERATION_UPDATE )
			oMdl520:Activate()		
			
			if lRetorno .AND. AGRA520Qtd(oMdl520, aOutN9C[2][1], cEntOri, cLojOri, aPendN9C[8][1], ABS(aOutN9C[5][1]), "FISCAL", aPendN9C[3][1])
				//Se não conseguir atualizar o status da pendencia da ORIGEM
				// Se conseguir, prossegue.
				cBkpFil := aPendN9C[4][1]
				aPendN9C[4][1] := aPendN9C[3][1]
				If AGRX500STT(aPendN9C, aOutN9C[2][1], cEntOri, cLojOri, "ORIGEM")
					aPendN9C[4][1] := cBkpFil  
							
					/****************ATUALIZA DESTINO******************/
					//Atualiza a quantidade no destino
					if AGRA520Qtd(oMdl520,aOutN9C[2][1], aOutN9C[3][1], aOutN9C[4][1], aPendN9C[8][1], ABS(aOutN9C[5][1]), "FISCAL",aOutN9C[1][1])			    	
						//Atualiza o status da pendencia do DESTINO
						If !(AGRX500STT(aPendN9C, aOutN9C[2][1], aOutN9C[3][1], aOutN9C[4][1], "DESTINO"))
							lRetorno := .F.
						EndIf
					Else //Deu erro na atualização da quantidade no DESTINO
						lRetorno := .F.
					EndIF
					/****************ATUALIZA DESTINO******************/
					
				Else //Deu erro na atualização do status na ORIGEM.
					lRetorno := .F.
				EndIf	
			else //Deu erro na atualização da quantidade na ORIGEM
				lRetorno := .F.
			EndIf					
		endIf
		
	// Se for 'COMPLEMENTO FISCAL'
	elseIf cTipo = '2'
		// QUEM RESOLVE É A ORIGEM!
		cFilAnt := aPendN9C[4][1]
			
		 lRetorno := AGRX500SCF(aPendN9C, N9C->N9C_QTDPEN, N9C->N9C_CODSAF, N9C->N9C_CODENT, N9C->N9C_LOJENT, N9B->N9B_CODPRO)
				    
	    /*if lRetorno .AND. lAlgodao
			lRetorno := AX520APFar(N9C->N9C_FILROM, N9C->N9C_ROMORI, N9C->N9C_QTDPEN) //ajusta o peso do fardão
	    endIf*/					
	    
	    if lRetorno
			dbSelectArea('NJ0')
			NJ0->(dbSetOrder(5))
			If NJ0->(MsSeek(FWxFilial('NJ0')+N9B->N9B_FILIAL)) 
				cEntOri := NJ0->NJ0_CODENT
				cLojOri := NJ0->NJ0_LOJENT
			EndIf
			RestArea(aAreaNJ0)
			
			dbSelectArea("N9B")
			N9B->(dbSetOrder(1))
			N9B->(DbSeek(FWxFilial("N9B") + N9C->N9C_CODSAF + N9C->N9C_CODENT + N9C->N9C_LOJENT + N9B->N9B_CODPRO ))
											
			oMdl520 := FwLoadModel("AGRA520")
			oMdl520:SetOperation( MODEL_OPERATION_UPDATE )
			oMdl520:Activate()
			
					/****************ATUALIZA ORIGEM******************/
			if AGRA520Qtd(oMdl520, aOutN9C[2][1], aOutN9C[3][1], aOutN9C[4][1], aPendN9C[8][1], aOutN9C[5][1], "FISCAL", aPendN9C[4][1])
				//Se não conseguir atualizar o status da pendencia da ORIGEM
				// Se conseguir, prossegue.
				If AGRX500STT(aPendN9C, aOutN9C[2][1], aOutN9C[3][1], aOutN9C[4][1], "ORIGEM")
					/****************ATUALIZA ORIGEM******************/
			
					/****************ATUALIZA DESTINO******************/
					//Atualiza a quantidade no destino
					if AGRA520Qtd(oMdl520, aOutN9C[2][1], cEntOri, cLojOri, aPendN9C[8][1], aOutN9C[5][1], "FISCAL", aPendN9C[3][1])			    	
						//Atualiza o status da pendencia do DESTINO
						If !(AGRX500STT(aPendN9C, aOutN9C[2][1], cEntOri , cLojOri, "DESTINO"))
							lRetorno := .F.
						EndIf
					Else //Deu erro na atualização da quantidade no DESTINO
						lRetorno := .F.
					EndIF
					/****************ATUALIZA DESTINO******************/
					
				Else //Deu erro na atualização do status na ORIGEM.
					lRetorno := .F.
				EndIf	
			Else //Deu erro na atualização da quantidade na ORIGEM
				lRetorno := .F.
			EndIf
			oMdl520:DeActivate()
		endIf
	endIf	
	
	cFilAnt := cFilTemp	 
Return lRetorno
