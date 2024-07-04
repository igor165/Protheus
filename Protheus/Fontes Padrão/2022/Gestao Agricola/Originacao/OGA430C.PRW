#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'OGA430C.CH'

/*{Protheus.doc} OGA430C 
- Rotina de vinculo de notas complementares para produtores

@author 	ana.olegini
@since 		08/08/2016
@version 	1.0
@param 		cFiltro 	- filtro da tabela NNC da rotina OGA430A
			cContrato	- codigo do contrato posicionado
			cItemFx		- numeracao da fixacao posicionada
@return 	Nil
*/

Static oArqTemp := Nil

Function OGA430C( cFiltro, cContrato, cItemFx)
	//-- Variaveis de controle tela
	Local nTamH 		:= ( GetScreenRes()[1] -150)
	Local nTamV 		:= ( GetScreenRes()[2] -150)
	Local oLayTel		:= Nil
	
	//-- Variaveis de controle - tela
   	Private _oDlgC		:= Nil
   	Private _oMBPend 	:= Nil
    Private _oMBDocs 	:= Nil
	
	//-- Variaveis temporarias - campos tela
	Private _aCpsPen 	:= {}   
    Private _aCpsDoc 	:= {}
    Private _aStrPen	:= {}
    Private _aStrDoc	:= {}
    
    //-- Variaveis temporarias - tabelas
    Private _cTabPen
   	Private _cTabDoc
   	
   	//-- Variaveis parametros  
    Private _cContrato 	:= cContrato
    Private _cItemFx	:= cItemFx
    Private _cFiltroNNC	:= cFiltro
    Private _cItemNKC	:= ""
    Private _cForCli	:= ""
    Private _cLjClFo	:= ""
    Private _cProdut	:= ""
	Private _lNKC_ITEMNF   := NKC->(ColumnPos("NKC_ITEMNF")) > 0
    
    //-- Controle de quantidade de registros da tabela de documentos
    Private _nRegDoc	:= 0

    Private _cTabDocs   := ""

	//-- TELA STR0001 - "Nota Complementar de Terceiros"
	_oDlgC := TDialog():New( 0, 0, nTamV, nTamH, STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .t. )
	_oDlgC:lEscClose := .T.
	
	//**Inicializa o objeto e nao apresenta botão de fechar
	oLayTel := FwLayer():New()
	oLayTel:Init(_oDlgC, .F.)

	//**Adiciona Linhas
	oLayTel:addLine('L01', 35, .F.)
	oLayTel:addLine('L02', 65, .F.)
	
	//**Adiciona Colunas
	oLayTel:addCollumn('C01_L01', 100, .F., 'L01')
	
	//**Adiciona Janelas na linha 01 Coluna 01
	oLayTel:addWindow('C01_L01', 'C01_L01_W01', STR0002 , 100, .F., .F., /*bAction*/, 'L01', /*bFocus*/) //"Pendencias das Entregas"
	
	//**Painel da Janela da Linha 01	
	oPanelL01 := oLayTel:getWinPanel('C01_L01', 'C01_L01_W01','L01') 
	 
	//**Painel da Janela da Linha 02
	oPanelL02 := oLayTel:GetLinePanel('L02') 
	
	//-- Verifica se a entidade esta ativa 
	lContinua := OGA430CENT()
	//Se entidade ok e tabela maior que zero - ativa as telas
	If lContinua
		GenBrwPend( oPanelL01 )	//Tela de pendencias 			
		GenBrwDocs( oPanelL02 )	//Tela de notas de complemento 	
   		
		//**Ativa as janelas
  		_oMBPend:Activate()
   		_oMBDocs:Activate()
		
		ACTIVATE MSDIALOG _oDlgC CENTER
   	EndIf
	
	//**Ao fechar tela limpa temporarias
	//--Temporaria Pendencias
	IF Select( _cTabPen ) > 0
		(_cTabPen)->( DbCloseArea() )
		FErase(_cTabPen + GetDbExtension() ) 	// Deletando o arquivo
	EndIF
	//--Temporaria Documentos
	IF Select( _cTabDoc ) > 0
		(_cTabDoc)->( DbCloseArea() )
		FErase(_cTabDoc + GetDbExtension() ) 	// Deletando o arquivo
	EndIF
	
    //Elimina a tabela temporária, se houver
    AGRDLTPTB(oArqTemp)
	
Return

/*{Protheus.doc} GenBrwPend
- Função que controla o Browser de Pendencias

@author 	ana.olegini
@since 		08/08/2016
@version 	1.0
@param 		oPanel 		- Objeto da tela principal
@return 	lContinua	- Retorno .T. verdadeiro ou .F. falso
*/
Static Function GenBrwPend(oPanel)
	Local aColumns	:= {}
	Local lContinua	:= .T.

    //------------------------------------------------------------------
    //*** ARRAY PRINCIPAL COM OS CAMPOS PARA A TELA DE PENDENCIAS E TRB 
    //********* REALIZAR MANUTENÇÕES AQUI 
    //------------------------------------------------------------------
	_aCpsPen := {{STR0005    		,"ROMANEIO"    	,"C" ,10	,  0, "@!"	},;						//"Romaneio" 
                 {STR0006	  		,"ITMROMAN"    	,"C" ,02	,  0, "@!"	},;						//"Item Romaneio"
                 {STR0007	    	,"QTDENT"    	,"N" ,14	, 02, "@E 999,999,999.99"	},;		//"Qtd. Entrega"
                 {STR0008	     	,"VLRENT"    	,"N" ,14	, 02, "@E 999,999,999.99"	},;		//"Valor Entrada"
                 {STR0009	    	,"VLRFIX"    	,"N" ,14	, 02, "@E 999,999,999.99"	},;		//"Valor Fixado"
                 {STR0010		    ,"VLRCOM"    	,"N" ,14	, 02, "@E 999,999,999.99"	},;		//"Valor Complemento"
                 {STR0011		   	,"VLRASS"    	,"N" ,14	, 02, "@E 999,999,999.99"	},;		//"Valor Associado"
                 {STR0012	    	,"ROMITEM"    	,"C" ,12	,  0, "@!"	} }						//"RomaneioItem"		 //*NAO EH APRESENTADO EM TELA
	
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData({||ROMANEIO})				//--Coluna da Temporaria
	aColumns[Len(aColumns)]:SetTitle(_aCpsPen[1][1]) 			//--Titulo da Coluna
	aColumns[Len(aColumns)]:SetSize(_aCpsPen[1][4])				//--Tamanho do Campo
	aColumns[Len(aColumns)]:SetDecimal(_aCpsPen[1][5])			//--Tamanho do Decimal
	aColumns[Len(aColumns)]:SetPicture(_aCpsPen[1][6])			//--Picture
	aColumns[ Len(aColumns) ]:SetAlign(CONTROL_ALIGN_LEFT)		//--Define alinhamento

	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData({||ITMROMAN})
	aColumns[Len(aColumns)]:SetTitle(_aCpsPen[2][1]) 
	aColumns[Len(aColumns)]:SetSize(_aCpsPen[2][4])
	aColumns[Len(aColumns)]:SetDecimal(_aCpsPen[2][5])
	aColumns[Len(aColumns)]:SetPicture(_aCpsPen[2][6])
	aColumns[ Len(aColumns) ]:SetAlign( CONTROL_ALIGN_LEFT)		

	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData({||QTDENT})
	aColumns[Len(aColumns)]:SetTitle(_aCpsPen[3][1]) 
	aColumns[Len(aColumns)]:SetSize(_aCpsPen[3][4])
	aColumns[Len(aColumns)]:SetDecimal(_aCpsPen[3][5])
	aColumns[Len(aColumns)]:SetPicture(_aCpsPen[3][6])
	aColumns[ Len(aColumns) ]:SetAlign( CONTROL_ALIGN_RIGHT)		

	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData({||VLRENT})
	aColumns[Len(aColumns)]:SetTitle(_aCpsPen[4][1]) 
	aColumns[Len(aColumns)]:SetSize(_aCpsPen[4][4])
	aColumns[Len(aColumns)]:SetDecimal(_aCpsPen[4][5])
	aColumns[Len(aColumns)]:SetPicture(_aCpsPen[4][6])
	aColumns[ Len(aColumns) ]:SetAlign( CONTROL_ALIGN_RIGHT)			

	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData({||VLRFIX})
	aColumns[Len(aColumns)]:SetTitle(_aCpsPen[5][1]) 
	aColumns[Len(aColumns)]:SetSize(_aCpsPen[5][4])
	aColumns[Len(aColumns)]:SetDecimal(_aCpsPen[5][5])
	aColumns[Len(aColumns)]:SetPicture(_aCpsPen[5][6])
	aColumns[ Len(aColumns) ]:SetAlign( CONTROL_ALIGN_RIGHT)		
	
	AAdd(aColumns,FWBrwColumn():New())
	aColumns[Len(aColumns)]:SetData({||VLRCOM})
	aColumns[Len(aColumns)]:SetTitle(_aCpsPen[6][1]) 
	aColumns[Len(aColumns)]:SetSize(_aCpsPen[6][4])
	aColumns[Len(aColumns)]:SetDecimal(_aCpsPen[6][5])
	aColumns[Len(aColumns)]:SetPicture(_aCpsPen[6][6])
	aColumns[ Len(aColumns) ]:SetAlign( CONTROL_ALIGN_RIGHT)		
	
	_cTabPen := OGA430CTAB(1) 			// Cria a tabela
    OGA430CREG(_cContrato, 1) 			// Carrega 
	
	//-- GRID DE ROMANEIOS COM SALDO PARA ASSOCIAR
    _oMBPend := FWBrowse():New()					//--Fornece um objeto do tipo grid que permite a exibição de dados do tipo array, texto, tabela e query.
    _oMBPend:SetOwner(oPanel)						//--Indica o container para criação do Browse.     
    _oMBPend:SetDataTable(.T.)                      //--Indica que o Browse exibe dados através de uma tabela.       
    _oMBPend:SetAlias(_cTabPen)   					//--Indica o alias da tabela que será utilizada no Browse.    
	_oMBPend:SetColumns(aColumns)					//--Adiciona uma coluna no Browse em tempo de execução
	_oMBPend:SetChange ({|| OG430CREFR() })			//--Indica a Code-Block executado após a mudança de uma linha.         
	_oMBPend:DisableConfig(.T.)						//--Desabilita a utilização das configurações do Browse.

Return lContinua

/*{Protheus.doc} GenBrwDocs
- Função que controla o Browser de Documentos a Vincular

@author 	ana.olegini
@since 		08/08/2016
@version 	1.0
@param 		oPanel 	- Objeto da tela principal
@return 	lContinua	- Retorno .T. verdadeiro ou .F. falso
*/
Static Function GenBrwDocs(oPanel)
	Local lMarkAll	:= .F.
	Local nCont		:= 0 
	Local lContinua := .T.

    //------------------------------------------------------------------
    //*** ARRAY PRINCIPAL COM OS CAMPOS PARA A TELA DE VINCULO E TRB 
    //********* REALIZAR MANUTENÇÕES AQUI 
    //------------------------------------------------------------------
	_aCpsDoc := {{""                    ,"MARCA"        ,"C" ,01 , 00, ""  	},;
                {STR0012        		,"SERIE"    	,"C" ,03 , 00, "@!"	},;						//"Série"
                {STR0013	        	,"DOCTO"      	,"C" ,09 , 00, "@!"	},;						//"Documento"
                {STR0014       	    	,"EMISSAO" 		,"D" ,08 , 00, ""  	},;						//"Emissão"
                {STR0015       	    	,"ITEM"   		,"C" ,04 , 00, "@!"	},;						//"Item"
                {STR0016		    	,"VUNIT"    	,"N" ,14 , 02, "@E 999,999,999.99"	},;		//"Valor Unitário"
                {STR0017		   	    ,"TOTAL"    	,"N" ,14 , 02, "@E 999,999,999.99"	},;		//"Valor Total"
                {STR0018		 	    ,"ASSOCIA"    	,"N" ,14 , 02, "@E 999,999,999.99"	},;		//"Valor Associado"
                {STR0019	  		   	,"SALDO"    	,"N" ,14 , 02, "@E 999,999,999.99"	},;		//"Valor Saldo" 
				{STR0020				,"ITROMVINC"	,"C" ,250, 00, "@!"					} } 	//"ItRomVinc"  		//**Irá conter lista de romaneios vinculados ex: 0000000001001|0000000002001 

    For nCont := 2 to Len(_aCpsDoc)
    	If _aCpsDoc[nCont][2] != "ITROMVINC" 
        	aADD(_aStrDoc,{ _aCpsDoc[nCont][1], _aCpsDoc[nCont][2], _aCpsDoc[nCont][3], _aCpsDoc[nCont][4], _aCpsDoc[nCont][5], _aCpsDoc[nCont][6]})
    	EndIf 
    Next nCont
	
	_cTabDoc := OGA430CTAB(2) 			// Cria a tabela
    OGA430CREG(_cContrato, 2) 			// Carrega 
	
	//-- GRID DOCUMENTOS DISPONIVEIS PARA ASSOCIAR 
	_oMBDocs := FWMarkBrowse():New()																//--Fornece um objeto do tipo grid, botões laterais e uma coluna com a opção de marca e desmarca
	_oMBDocs:SetDescription(STR0003)							//"Selecione a nota complementar"	//--Indica a descrição do Browse  
	_oMBDocs:SetFieldMark("MARCA")																	//--Indica o campo que deverá ser atualizado com a marca no registro
	_oMBDocs:SetOwner(oPanel)																		//--Indica o container para criação do Browse
	_oMBDocs:SetTemporary(.T.)																		//--Indica que o Browse utiliza tabela temporária
	_oMBDocs:SetAlias(_cTabDoc)                         											//--Indica o alias da tabela que será utilizada no Browse
	_oMBDocs:SetFields(_aStrDoc)																	//--Indica os campos que serão adicionados as colunas do Browse.
	_oMBDocs:SetMenuDef("OGA430C")																	//--Indica o programa que será utilizado para a carga do menu funcional
	_oMBDocs:SetCustomMarkRec({|| OGA430CMK1( _oMBDocs ) })											//--Marca um
	_oMBDocs:SetWalkThru(.F.)																		//--Habilita a utilização da funcionalidade Walk-Thru no Browse
	_oMBDocs:DisableConfig(.T.)																		//--Desabilita a utilização das configurações do Browse
	_oMBDocs:DisableSeek(.T.)																		//--Desabilita a utilização da pesquisa no Browse
	_oMBDocs:DisableFilter(.T.)																		//--Desabilita a utilização do filtro no Browse
	_oMBDocs:SetAmbiente(.F.)																		//--Habilita a utilização da funcionalidade Ambiente no Browse
	_oMBDocs:ForceQuitButton(.T.)																	//--Forca a exibição SAIR para Browses 
  	
Return lContinua

/*{Protheus.doc} MenuDef
- Função de Menu 

@author 	ana.olegini
@since 		16/08/2016
@version 	1.0
@param 		Nil
@return 	aRotina - Array - Array com as opções disponiveis de ações relacionadas
*/
Static Function MenuDef()
	Local aRotina 	:= {}
	//*Criado o aRotina em branco para que fosse possivel apresentar  
	//*o botão "Sair" com a propriedade ForceQuitButton() do Browse.
	aAdd( aRotina,{"Vincula","Staticcall(OGA430C,fvincula)",0,3,0,Nil})

Return( aRotina )

/*/{Protheus.doc} fvincula
	faz o vinculo das notas marcadas á pendencia
	@type  Static Function
	@author mauricio.joao
	@since 18/03/2020
	@version 1.0
	/*/
Static Function fvincula()
	Local aAreaAtu		:= GetArea()
	Local nVlComplto	:= (_cTabPen)->VLRCOM				//valor do complemento
	Local lRet          := .F.    
    Local nTotalAssoc   := 0
    Local lAchou        := .f.

	Private _lComplRom  := .T.	

    If fVldValor(nVlComplto, @nTotalAssoc)
        aInfoRom := fInfoRom((_cTabPen)->ROMANEIO,(_cTabPen)->ITMROMAN)    

        Begin Transaction		
            _oMBDocs:GoTop(.t.)
            While (_oMBDocs:Alias())->(!Eof())
                If _oMBDocs:IsMark()    
                    lAchou := .T.                
                    // Gera o romaneio simbólico a partir da NF
                    // NJJ_TIPO, NJJ_CODENT, NJJ_LOJENT, NJJ_DOCSER, NJJ_DOCNUM, NJJ_CODCTR
                    If lRet := OGA251GSimb( '5', aInfoRom[1],aInfoRom[2] , (_oMBDocs:Alias())->SERIE, (_oMBDocs:Alias())->DOCTO, aInfoRom[3], _cProdut, (_oMBDocs:Alias())->ITEM )	
                        If lRet := OGA250RELC((_cTabPen)->ROMANEIO, NJJ->NJJ_CODROM, "C" /*COMPLEMENTO*/) 
                            If lRet := OGA250ATUC() //atualiza romaneio			
                                If NJJ->(NJJ_STATUS) == '2' //se romaneio atualizado, para tratar quando MV_OG250FE=.T.
									lRet := OGA250NF( Alias(), Recno(), 4, .t. ) //confirma romaneio
                                EndIf
								If lRet
									lRet := OGA430CGRA((_oMBDocs:Alias())->ASSOCIA)
								EndIf
                            EndIf						
                        EndIf
                    EndIf                    

                    If !lRet
                        DisarmTransaction()
                        break
                    EndIf
                    _oMBDocs:MarkRec()
                EndIF	
                (_oMBDocs:Alias())->(DbSkip())
            EndDo
        End Transaction
        
        If lRet
            fCleanReload()
            MsgInfo(STR0028) //"Vínculo realizado com sucesso."
        EndIf

        If !lAchou
            AgrHelp(STR0021, STR0029,STR0030) //"Não foi selecionado nenhum documento." "Por favor, selecione um documento para realizar o vínculo."
        EndIf
    Else
        MsgAlert(STR0026+cValToChar(nTotalAssoc)+STR0027+CVALTOCHAR( nVlComplto )+"!")					
    EndIf

	//-- Realiza refresh na tela de Pendencias
	_oMBPend:Refresh()		
	_oMBDocs:Refresh()
	_lComplRom := .F.
	//-- Restaura Area
	RestArea(aAreaAtu)
	

Return lRet

/*/{Protheus.doc} fInfoRom(cRomaneio,cItem)	
	procura o fornecedor do romaneio
	@type  Static Function
	@author mauricio.joao
	@since 25/03/2020
	@version 1.0
/*/
Static Function fInfoRom(cRomaneio,cItem)
Local aInfoRom := {}

cAliasTrb := GetNextAlias()

BeginSQL Alias cAliasTrb
    SELECT 
		NJM_CODENT, NJM_LOJENT, NJM_CODCTR
    FROM 
		%Table:NJM% NJM
    WHERE 
		NJM_FILIAL = %XFilial:NJM% AND
		NJM_CODROM = %Exp:cRomaneio% AND
		NJM_ITEROM = %Exp:cItem% AND
		NJM.%NotDel% 
EndSQL

While (cAliasTrb)->(!Eof())
	AADD( aInfoRom, (cAliasTrb)->NJM_CODENT )
	AADD( aInfoRom, (cAliasTrb)->NJM_LOJENT )
	AADD( aInfoRom, (cAliasTrb)->NJM_CODCTR )
	(cAliasTrb)->(DbSkip())
EndDo

(cAliasTrb)->(DBCLOSEAREA())

Return aInfoRom

/*{Protheus.doc} OGA430CTAB
- Função para realizar a criação da tabela temporária

@author 	ana.olegini
@since 		16/08/2016
@version 	1.0
@param 		nOrdem 		- Numérico	- Ordem para a criação da TRB
@return 	cTabela 	- Caracter	- Retorna a tabela criada
*/
Function OGA430CTAB(nOrdem)
    Local nCont 	:= 0
    Local cTabela	:= ''
    Local _aStrPen 	:= {}
	Local _aStrDoc 	:= {}
    
    If nOrdem == 1		//Ordem 1 = Pendencias
	    //-- busca no _aCpsPen as propriedades para criar as colunas
	    For nCont := 1 to Len(_aCpsPen) 
	        aADD(_aStrPen,{_aCpsPen[nCont][2], _aCpsPen[nCont][3], _aCpsPen[nCont][4], _aCpsPen[nCont][5] })
	    Next nCont 
	   	//-- Tabela temporaria de pendencias
	   	cTabela := GetNextAlias()
        oArqTemp  := AGRCRTPTB(cTabela, {_aStrPen, {{"", "ROMANEIO"}} })	   	
	   	
    ElseIf nOrdem == 2	//Ordem 2 = Documentos para Vinculo
	    //-- busca no _aCpsDoc as propriedades para criar as colunas
	    For nCont := 1 to Len(_aCpsDoc) 
	        aADD(_aStrDoc,{_aCpsDoc[nCont][2], _aCpsDoc[nCont][3], _aCpsDoc[nCont][4], _aCpsDoc[nCont][5]})
	    Next nCont 
	    //-- Tabela temporaria de documentos
	    cTabela := GetNextAlias()
        oArqTemp  := AGRCRTPTB(cTabela, {_aStrDoc, {{"", "SERIE"}} })	    
        _cTabDocs := oArqTemp:GetRealName()
    EndIf 
    
Return cTabela

/*{Protheus.doc} OGA430CREG
Função para carregar as tabelas temporarias
@author ana.olegini
@since 	17/08/2016
@version 1.0
@param _cContrato, Caracter, Informa o contrato posicionado
@param nOrdem, Numérico, Ordem das tabelas temporarias 
@return Logical, True or False
@type function
*/
Function OGA430CREG(_cContrato, nOrdem)
    Local cSavFiltro	:= NNC->( dbfilter() )
	Local lContinua		:= .T.
    Local cNForig       := ""
	Local cSeOrig       := ""
	Local cTmpCod	    := ''
	Local cTmpLoj	    := ''
	Local aRtPE430C     := {}

    Private _cTabQry1 	:= GetNextAlias()  

	//-- Encontra atraves da tabela de contratos o produto posicionado.
	_cProdut := Posicione( "NJR", 1, xFilial( "NJR" ) + _cContrato, "NJR_CODPRO" )
	
	//-- Ordem [1] - Tabela temporária de Pendencias
	If nOrdem == 1
		//-- Aplica o filtro da primeira tela com os romaneios selecionados 
		NNC->( dbSetFilter( {|| &_cFiltroNNC}, _cFiltroNNC) )     // Filtra somente Registros selecionados e da Filial Corrente
		NNC->( dbGoTop() )
		While NNC->( !EOF() )
			RecLock((_cTabPen),.T.)
				(_cTabPen)->ROMANEIO	= NNC->NNC_CODROM											//* codigo do romaneio
				(_cTabPen)->ITMROMAN	= NNC->NNC_ITEROM											//* item do romaneio
				(_cTabPen)->QTDENT		= NNC->NNC_QTDENT											//* quantidade entrega
				(_cTabPen)->VLRENT		= NNC->NNC_VLENT											//* valor entrega
				(_cTabPen)->VLRFIX		= NNC->NNC_VLFIXB											//* valor fixado
				(_cTabPen)->VLRCOM		= (NNC->NNC_VLFIXB - NNC->NNC_VRENPF) - NNC->NNC_VLCMPL		//* valor complemento
				(_cTabPen)->ROMITEM		= NNC->NNC_CODROM+NNC->NNC_ITEROM							//* romaneio + item
			MsUnlock()
			//-- Pula para o proximo registro
			NNC->(dbSkip())			
		EndDo
		
		//-- Retira o filtro da tabela NNC retornando o filtro inicial
		NNC->(DBClearFilter())	
		IF !Empty(cSavFiltro)
			//-- Retorna o filtro Inicial		
			NNC->( DBSetFilter ( {|| &cSavFiltro}, cSavFiltro) )  
		EndIF		
	
	//-- Ordem [2] - Tabela temporária de Documentos a Vincular
	ElseIf nOrdem == 2
		
        NNC->( dbSetFilter( {|| &_cFiltroNNC}, _cFiltroNNC) ) 
        NNC->( dbGoTop() )
        IF NNC->( !EOF() )
            cNForig := NNC->NNC_NUMDOC
            cSeOrig := NNC->NNC_SERDOC
        EndIf
	
		cTmpCod := _cForCli
		cTmpLoj := _cLjClFo
		
		//Ponto de entrada para alteração dos dados na localização das notas de Entrada e/ou Saida.
		If ExistBlock("OGA430C1")  
			aRtPE430C := ExecBlock( "OGA430C1",.F.,.F.,{cTmpCod, cTmpLoj, _cContrato, NNC->NNC_CODROM })
			If ValType(aRtPE430C)=="A" .And. Len(aRtPE430C) > 0 .And. Len(aRtPE430C)== 2
				cTmpCod	:= IIF(Empty(aRtPE430C[1]), cTmpCod	, aRtPE430C[1] )					
				cTmpLoj	:= IIF(Empty(aRtPE430C[2]), cTmpLoj	, aRtPE430C[2] )	
			EndIf
		EndIf

		_cForCli := cTmpCod
		_cLjClFo := cTmpLoj

        //------------------------------------------------------------------
		//-- Query para selecao dos documentos de complemento para vincular
		//------------------------------------------------------------------
		cQuery := " SELECT SD1.D1_SERIE, "
		cQuery +=        " SD1.D1_DOC,   "
		cQuery +=        " SD1.D1_EMISSAO, "
		cQuery +=        " SD1.D1_ITEM,  "
		cQuery +=        " SD1.D1_VUNIT, "
		cQuery +=        " SD1.D1_TOTAL,  "
		//-- Verifica na NNC se já possui algum vinculo
		cQuery +=        " (SELECT SUM(NKC.NKC_VRTOT) "
		cQuery +=           " FROM "+ RetSqlName("NKC") + " NKC "  
		cQuery +=          " WHERE NKC.D_E_L_E_T_ = '' "
		cQuery +=            " AND NKC.NKC_FILIAL = '" + xFilial( "NKC" ) + "'" 
        cQuery +=            " AND NKC.NKC_DOCTO  = SD1.D1_DOC      "
		cQuery +=            " AND NKC.NKC_SERIE  = SD1.D1_SERIE    "
		If _lNKC_ITEMNF
			cQuery +=        " AND NKC.NKC_ITEMNF = SD1.D1_ITEM     "
		EndIf
	    cQuery +=            " AND NKC.NKC_FORCLI = SD1.D1_FORNECE  "
	    cQuery +=            " AND NKC.NKC_LOJA   = SD1.D1_LOJA) AS ASSOCIA     "
		cQuery +=   " FROM "+ RetSqlName("SD1") + " SD1 " 
		cQuery +=  " WHERE SD1.D_E_L_E_T_ = '' "
		cQuery +=    " AND SD1.D1_FILIAL  = '" + xFilial( "SD1" ) + "' " 
		cQuery +=    " AND SD1.D1_COD     = '" + _cProdut + "' " 
		cQuery +=    " AND SD1.D1_FORNECE = '" + _cForCli + "' " 
		cQuery +=    " AND SD1.D1_LOJA    = '" + _cLjClFo + "' " 
		cQuery +=    " AND SD1.D1_FORMUL != 'S' "
		cQuery +=    " AND SD1.D1_TIPO    = 'C' "
        cQuery +=    " AND SD1.D1_NFORI   = '" + cNForig + "' " 
        cQuery +=    " AND SD1.D1_SERIORI = '" + cSeOrig + "' "
		cQuery +=  " ORDER BY SD1.D1_EMISSAO, SD1.D1_SERIE, SD1.D1_DOC "
		cQuery := ChangeQuery(cQuery)
		//-- VERIFICA SE EXISTE - SE SIM APAGA TABELA TEMP
		If Select(_cTabQry1) <> 0
			(_cTabQry1)->(dbCloseArea())
		EndIf
		//-- DEFINE UM ARQUIVO DE DADOS COMO UMA AREA DE TRABALHO DISPONIVEL NA APLICACAO
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),_cTabQry1,.T.,.T.)
		
		//-- Trata o formato Data
		TCSetField(_cTabQry1, 'D1_EMISSAO'   , 'D')
		
		//-- Seleciona a tabela
		dbSelectArea(_cTabQry1)
		(_cTabQry1)->(dbGoTop())
		While (_cTabQry1)->(!Eof()) 
			//-- Se total e associado for maior que zero alimenta a temporaria 
			If ((_cTabQry1)->D1_TOTAL-(_cTabQry1)->ASSOCIA) > 0
				RecLock((_cTabDoc),.T.)
					(_cTabDoc)->SERIE	= (_cTabQry1)->D1_SERIE
					(_cTabDoc)->DOCTO	= (_cTabQry1)->D1_DOC
					(_cTabDoc)->EMISSAO	= (_cTabQry1)->D1_EMISSAO
					(_cTabDoc)->ITEM	= (_cTabQry1)->D1_ITEM
					(_cTabDoc)->VUNIT	= (_cTabQry1)->D1_VUNIT
					(_cTabDoc)->TOTAL	= (_cTabQry1)->D1_TOTAL
					(_cTabDoc)->ASSOCIA	= (_cTabQry1)->ASSOCIA
					(_cTabDoc)->SALDO	= (_cTabQry1)->D1_TOTAL-(_cTabQry1)->ASSOCIA				
				MsUnlock()
				
				//-- Soma a quantidade de registros na tabela
				_nRegDoc ++
			EndIf
			//-- Pula para o proximo registro
			(_cTabQry1)->(dbSkip())			
		EndDo
	EndIf
Return lContinua

/*{Protheus.doc} OGA430CMK1
- Função de marca um no browser de documentos a vincular

@author 	ana.olegini
@since 		17/08/2016
@version 	1.0
@param 		_oMBDocs 	- Objeto	- Objeto do browser
@return 	lContinua	- Logico	- Retorno .T. verdadeiro ou .F. falso
*/
Static Function OGA430CMK1( _oMBDocs )
	Local aAreaAtu		
	Local lContinua 	:= .T.
	Local nVlComplto	:= (_cTabPen)->VLRCOM				//valor do complemento
	Local nVlAssocia	:= (_oMBDocs:Alias())->ASSOCIA		//valor ja associado
	Local cSavFiltro	:= NKC->( dbfilter() )
	
	//-- Se estiver desmarcado, marcamos e vinculamos os valores.
	If !_oMBDocs:IsMark() 
		RecLock(_oMBDocs:Alias(),.F.)
			(_oMBDocs:Alias())->MARCA  		:= _oMBDocs:Mark()											//* Marca
			(_oMBDocs:Alias())->ASSOCIA 	+= (_oMBDocs:Alias())->SALDO//* Associa [soma o valor do complemento]
			(_oMBDocs:Alias())->SALDO		-= (_oMBDocs:Alias())->ASSOCIA	//* Saldo
			//-- Se conter Item/Romaneio Vinculado
			IF Len( Alltrim ( (_oMBDocs:Alias())->ITROMVINC ) ) > 0
				//-- Acrescenta separador
				(_oMBDocs:Alias())->ITROMVINC := Alltrim( (_oMBDocs:Alias())->ITROMVINC ) + "|"
			EndIF 	
			//-- Abastece lista de romaneios que estão vindulados ao documento
			(_oMBDocs:Alias())->ITROMVINC	:= Alltrim( (_oMBDocs:Alias())->ITROMVINC ) + (_cTabPen)-> (ROMANEIO+ITMROMAN) 					
		(_oMBDocs:Alias())->(MsUnLock())	
	//-- Se estiver marcado, desmarcamos.
	else
		RecLock(_oMBDocs:Alias(),.F.)
			(_oMBDocs:Alias())->MARCA  		:= ''
			(_oMBDocs:Alias())->SALDO		+= (_oMBDocs:Alias())->ASSOCIA	//* Saldo
			(_oMBDocs:Alias())->ASSOCIA 	-= (_oMBDocs:Alias())->SALDO//* Associa [soma o valor do complemento]
			//-- Se conter Item/Romaneio Vinculado
			IF Len( Alltrim ( (_oMBDocs:Alias())->ITROMVINC ) ) > 0
				//-- Acrescenta separador
				(_oMBDocs:Alias())->ITROMVINC := Alltrim( (_oMBDocs:Alias())->ITROMVINC ) + "|"
			EndIF 	
			//-- Abastece lista de romaneios que estão vindulados ao documento
			(_oMBDocs:Alias())->ITROMVINC	:= Alltrim( (_oMBDocs:Alias())->ITROMVINC ) + (_cTabPen)-> (ROMANEIO+ITMROMAN) 					
		(_oMBDocs:Alias())->(MsUnLock())
	EndIf

Return(lContinua)

/*{Protheus.doc} OG430CREFR
- Função de refresh da tela de pendencias

@author 	ana.olegini
@since 		17/08/2016
@version 	1.0
@param 		Nil
@return 	.T. - Verdadeiro
*/
Static function OG430CREFR()
	Local cFiltro	:= ""
	
	//-- Filtro para quando houver mudança de romaneios na tela de pendencias 	
	cFiltro := "(_cTabDoc)->SALDO > 0 .OR. (_cTabPen)->ROMITEM $ ( _cTabDoc )->ITROMVINC"
	//-- Limpa filtro
	_oMBDocs:oBrowse:CleanFilter()
	//-- Aplica o filtro
	_oMBDocs:oBrowse:SetFilterDefault( cFiltro )
	//-- Altera o Browser
	_oMBDocs:oBrowse:UpdateBrowse()	
	//-- Fazendo o Refresh do Browse
	_oMBDocs:Refresh(.T.)						
Return( .T. )

/*{Protheus.doc} OGA430CGRA
- Função que realiza a gravação da NKC 

@author 	ana.olegini
@since 		17/08/2016
@version 	1.0
@param 		nVlrAsso - Numerico - Valor Associado
@return 	lRetorno - Logico	- .T. para vedadeiro .F. para falso
*/
Static Function OGA430CGRA(nVlrAsso)
	Local lRetorno 	 	:= .T.
	Local cSavFiltro	:= NNC->( dbfilter() )
	Local cPrefixo 		:= "" 	
	
	//-- Retirando o Filtro 
	NNC->(DBClearFilter())	
	//-- Filtrando na NNC 
	dbSelectArea("NNC")
	dbSetOrder(1)	//NNC_FILIAL+NNC_CODCTR+NNC_ITEMFX+NNC_CODROM+NNC_ITEROM	
	If dbSeek(xFilial( "NNC" ) + _cContrato + _cItemFx + (_cTabPen)->ROMANEIO + (_cTabPen)->ITMROMAN)
		While NNC->( !EOF() ) .AND. NNC->NNC_FILIAL == xFilial( "NNC" ) 	;		//Filial
		                      .AND. NNC->NNC_CODCTR == _cContrato 			;		//Contrato
		                      .AND. NNC->NNC_ITEMFX == _cItemFx				;		//Item Fixação
		                      .AND. NNC->NNC_CODROM == (_cTabPen)->ROMANEIO	;		//Romaneio
		                      .AND. NNC->NNC_ITEROM == (_cTabPen)->ITMROMAN			//Item Romaneio
				
			//valor complemento / quantidade fixada
			nVrUnit		:= nVlrAsso/NNC->NNC_QTDFIX
					
			//valor complemento 
			nVrTotal	:= nVlrAsso
	 			
	 		//valor impostos
			nVrImposto	:= 0	
			//-- Busca na SD1 - Documentos de Entrada os impostos do complemento	
			dbSelectArea('SD1')
			SD1->(DbSetOrder(1))	//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			SD1->(dBSeek(fWxFilial('SD1')+(_cTabDoc)->DOCTO+(_cTabDoc)->SERIE+_cForCli+_cLjClFo))
			While SD1->(! Eof() )  .and. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == fWxFilial('SD1')+(_cTabDoc)->DOCTO+(_cTabDoc)->SERIE+_cForCli+_cLjClFo
				//-- Soma todos os impostos do complemento
				nVrImposto := SD1->(D1_VLSENAR + D1_VALFET + D1_VALFAC + D1_VALFUN + D1_VALFDS + D1_VALINS)
				nVrTotItem := SD1->D1_TOTAL
				SD1->( DbSkip() )
			EndDo
		 	
		 	//-- Busca o prefixo da nota de complemento
		 	dbSelectArea("SF1")
		 	SF1->(DbSetOrder(1))	//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		 	If SF1->(dBSeek(fWxFilial('SF1')+(_cTabDoc)->DOCTO+(_cTabDoc)->SERIE+_cForCli+_cLjClFo))
		 		cPrefixo := SF1->F1_PREFIXO
		 	EndIf
		 	
		 	//-- Realiza a gravação da NKC
			Begin Transaction
				Reclock('NKC',.T. )
					NKC->NKC_FILIAL	:= fWxFilial('NKC')
					NKC->NKC_CODCTR	:= NNC->NNC_CODCTR
					NKC->NKC_ITEMFX	:= NNC->NNC_ITEMFX
					NKC->NKC_CODROM	:= (_cTabPen)->ROMANEIO
					NKC->NKC_ITEROM	:= (_cTabPen)->ITMROMAN
					NKC->NKC_ITEM	:= fNEXTNKCIT( NNC->NNC_CODCTR, NNC->NNC_ITEMFX, NNC->NNC_CODROM, NNC->NNC_ITEROM ) //-- Busca o proximo item da NKC
					NKC->NKC_SERIE	:= (_cTabDoc)->SERIE
					NKC->NKC_DOCTO	:= (_cTabDoc)->DOCTO
					If _lNKC_ITEMNF
						NKC->NKC_ITEMNF := (_cTabDoc)->ITEM
					EndIf
					NKC->NKC_PREFIX	:= cPrefixo
					NKC->NKC_FORMUL	:= 'N'					//-- Não = "Formulario Proprio Não"
					NKC->NKC_QTD	:= NNC->NNC_QTDFIX
					NKC->NKC_VRUN	:= nVrUnit
					NKC->NKC_VRTOT	:= nVrTotal
					NKC->NKC_VRIMP  := a410Arred( nVrImposto * (nVrTotal / nVrTotItem), 'D1_TOTAL' ) 
					NKC->NKC_DATA	:= dDatabase
					NKC->NKC_TPDOC	:= '7' 					//-- 7 = "Nf. Complemento/Produtor Vinculada"
					NKC->NKC_PEDIDO	:= ''
					NKC->NKC_FORCLI := _cForCli
					NKC->NKC_LOJA   := _cLjClFo					
				NKC->( MsUnLock() )
				
				//-- Ajusta a NNC com valor de complemento + valor de imposto + status
				Reclock("NNC",.F. )
					NNC->NNC_VLCMPL += nVrTotal
					NNC->NNC_VLIMPC += a410Arred( nVrImposto * (nVrTotal / nVrTotItem), 'D1_TOTAL' ) 
					//Atualiza o status de forma centralizada
					NNC->NNC_STATUS := OG430STAT() 			//7 = "Nf. Complemento/Produtor Vinculada"
				NNC->( MsUnlock() )							
			End Transaction
			
			NNC->(dbSkip())			
		EndDo
	Else
		lRetorno := .F.
	EndIf
	
	//-- Retira o filtro da tabela NNC retornando o filtro inicial
	NNC->(DBClearFilter())	
	IF !Empty(cSavFiltro)
		//-- Retorna o filtro Inicial		
		NNC->( DBSetFilter ( {|| &cSavFiltro}, cSavFiltro) )  
	EndIF	
Return(lRetorno)

/*{Protheus.doc} OGA430CEXC
- Função que realiza a exclusão da NKC

@author 	ana.olegini
@since 		17/08/2016
@version 	1.0
@param 		Nil
@return 	lRetorno - Logico - .T. para vedadeiro .F. para falso
*/
Static Function OGA430CEXC()
	Local lRetorno := .T.
	Local cSavFiltro	:= NNC->( dbfilter() )
	
	NNC->(DBClearFilter())	//Retirando o Filtro
	
	//-- Acessa a NKC 
	DbSelectArea("NKC")
	NKC->(DbSetOrder(1)) 	//NKC_FILIAL+NKC_CODCTR+NKC_ITEMFX+NKC_CODROM+NKC_ITEROM+NKC_ITEM
	If NKC->(DbSeek(xFilial("NKC") + _cContrato + _cItemFx + (_cTabPen)->ROMANEIO + (_cTabPen)->ITMROMAN ))	
		While NKC->( !EOF() ) .AND. NKC->NKC_FILIAL == xFilial( "NKC" ) 	;		//Filial
		                      .AND. NKC->NKC_CODCTR == _cContrato 			;		//Contrato
		                      .AND. NKC->NKC_ITEMFX == _cItemFx				;		//Item Fixação
		                      .AND. NKC->NKC_CODROM == (_cTabPen)->ROMANEIO	;		//Romaneio
		                      .AND. NKC->NKC_ITEROM == (_cTabPen)->ITMROMAN			//Item Romaeio
			//-- Verifica o Item da NKC
			If NKC->NKC_ITEM ==	_cItemNKC		
				
				//-- Guarda o valor de complemento e de imposto
				nVlCompl := NKC->NKC_VRTOT
				nVlImpto := NKC->NKC_VRIMP
				
				//-- Realiza o delete do registro na NKC
				NKC->(RecLock("NKC",.F.))
					NKC->(DbDelete())
				NKC->(MsUnLock())
				
				//-- Acessa a NNC 	
				dbSelectArea("NNC")
				dbSetOrder(1)		//NNC_FILIAL+NNC_CODCTR+NNC_ITEMFX+NNC_CODROM+NNC_ITEROM	
				If dbSeek(xFilial( "NNC" ) + _cContrato + _cItemFx + (_cTabPen)->ROMANEIO + (_cTabPen)->ITMROMAN)			
					//-- Ajusta a NNC com valor de complemento + valor de imposto + status
					Reclock("NNC",.F. )
						NNC->NNC_VLCMPL -= nVlCompl
						NNC->NNC_VLIMPC -= nVlImpto 
						//Atualiza o status de forma centralizada
						NNC->NNC_STATUS := OG430STAT() 					//'2' = "Requer NF.Complemento/Produtor"
					NNC->( MsUnlock() )
				EndIf
			EndIf
			NKC->(dbSkip())
		EndDo
	Else
		lRetorno := .F.
	EndIf
	
	//-- Retira o filtro da tabela NNC retornando o filtro inicial
	NNC->(DBClearFilter())
	IF !Empty(cSavFiltro)		
		//-- Retorna o filtro Inicial
		NNC->( DBSetFilter ( {|| &cSavFiltro}, cSavFiltro) )  
	EndIF	
Return(lRetorno)

/*{Protheus.doc} fNEXTNKCIT
- Função que retorna o número do próximo item da NKC

@author 	Emerson Coelho
            -- Alterações: Ana Laura Olegini
@since 		29/01/2015
			-- 17/08/2016
@version 	1.0
@param 		cCodCtr		- Caracter	- Codigo do contrato
@param 		cItemFx		- Caracter	- Item da Fixação
@param 		cCodRom		- Caracter	- Codigo do romaneio
@param 		cIteRom		- Caracter	- Item do Romaneio
@return 	cNextItem	- Numerico	- Sequencia do Item
*/
Static Function fNEXTNKCIT(cCodCtr, cItemFx, cCodRom, cIteRom)
	Local aSaveArea 	:= GetArea()
	Local cTabQry2 		:= GetNextAlias()
	Local cQuery		:= ''
	Local cNextItem		:= ''
 
	cQuery := " SELECT MAX( NKC_ITEM ) AS LAST_ITEM "
	cQuery +=   " FROM "+ RetSqlName("NKC") + " NKC "
	cQuery +=  " WHERE NKC.D_E_L_E_T_ = '' "
	cQuery +=    " AND NKC_FILIAL = '" + xFilial( "NKC" ) + "' " 
	cQuery +=    " AND NKC_CODCTR = '" + cCodCtr + "' "
	cQuery +=    " AND NKC_ITEMFX = '" + cItemFx + "' "
	cQuery +=    " AND NKC_CODROM = '" + cCodRom + "' "
	cQuery +=    " AND NKC_ITEROM = '" + cIteRom + "' "
	cQuery := ChangeQuery(cQuery)
	//-- VERIFICA SE EXISTE - SE SIM APAGA TABELA TEMP
	If Select(cTabQry2) <> 0
		(cTabQry2)->(dbCloseArea())
	EndIf
	//-- DEFINE UM ARQUIVO DE DADOS COMO UMA AREA DE TRABALHO DISPONIVEL NA APLICACAO
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTabQry2,.T.,.T.)
			
	//-- Seleciona a tabela
	dbSelectArea(cTabQry2)
	(cTabQry2)->(dbGoTop())
	
	//-- Retorna a proxima sequencia da NKC
	cNextItem := Soma1( (cTabQry2)->LAST_ITEM )
	cNextItem := StrZero( Val(cNextItem), TamSX3( "NKC_ITEM" )[1] )
	
	//-- Fecha a tabela temporaria
	(cTabQry2)->( DbCloseArea() )
	//-- Restaura Area
	RestArea( aSaveArea )
Return( cNextItem )

/*{Protheus.doc} OGA430CENT
- Função para verificar se entidade é ativa ou inativa

@author 	ana.olegini
@since 		17/08/2016
@version 	1.0
@param 		Nil
@return 	lContinua - Logico	- .T. para vedadeiro .F. para falso
*/
Static Function OGA430CENT()
	Local lContinua := .T.
	Local lCtrVnd	
	Local cCodEnt	:= ""
	Local cFilEnt	:= ""

	//-- Encontra atraves da tabela de contratos a entidade posicionada.
	cCodEnt := Posicione( "NJR", 1, xFilial( "NJR" ) + _cContrato, "NJR_CODENT" )
	cFilEnt := Posicione( "NJR", 1, xFilial( "NJR" ) + _cContrato, "NJR_LOJENT" )
	
	//-- Verifica se contrato é de [1] Compra ou [2] Venda
	lCtrVnd	:= IIF( Posicione( "NJR", 1, xFilial( "NJR" ) + _cContrato, "NJR_TIPO" ) == '1', .t., .f. ) //-- [1] Compra -- [2] Venda	
	dbSelectArea("NJ0")	//Tabela de Entidade
	dbSetOrder(1)		//NJ0_FILIAL+NJ0_CODENT+NJ0_LOJENT
	If dbSeek(xFilial( "NJ0" ) + cCodEnt + cFilEnt) 	
		//-- Verificar se a entidade esta [1] ativa ou [2] inativa
		//If NJ0->NJ0_ATIVO == '1'
			//-- Verifica se compra = fornecedor ou venda = cliente
			If lCtrVnd 	  			//-- Se for contrato de [1] Compra
				_cForCli := NJ0->NJ0_CODFOR			//Cliente/Fornecedor - Código
				_cLjClFo := NJ0->NJ0_LOJFOR 		//Cliente/Fornecedor - Loja
			ElseIf  .NOT. lCtrVnd	//-- Se for contrato de [2] Venda
				_cForCli := NJ0->NJ0_CODCLI			//Cliente/Fornecedor - Código
				_cLjClFo := NJ0->NJ0_LOJCLI			//Cliente/Fornecedor - Loja
			EndIf
		//Else
		//	lContinua := .F.
		//	Help(,,STR0021,, STR0022+ Alltrim(cCodEnt) + " " + Alltrim(cFilEnt) + STR0023, 1,0) //"Ajuda"#"Entidade "#" está Inativa! Favor verificar a entidade."	
		//EndIf
	Else 
		lContinua := .F.
		Help(,,STR0021 ,,STR0024, 1,0) //"Ajuda"#"Entidade "#" está Inativa! Favor verificar a entidade."	
	EndIf
Return lContinua

/*/{Protheus.doc} fCleanReload
Limpa e carrega tabela de documentos
@type function
@version 
@author rafael.voltz
@since 22/05/2020
@return return_type, return_description
/*/
Static Function fCleanReload()

	(_cTabPen)->(dbGoTop())
	While (_cTabPen)->(!Eof())
		RecLock((_cTabPen),.f.)
			(_cTabPen)->(DbDelete())
		(_cTabPen)->(MsUnLock())
		(_cTabPen)->(dbSkip())
	EndDo
    
    (_cTabDoc)->(dbGoTop())
	While (_cTabDoc)->(!Eof())
		RecLock((_cTabDoc),.f.)
			(_cTabDoc)->(DbDelete())
		(_cTabDoc)->(MsUnLock())
		(_cTabDoc)->(dbSkip())
	EndDo

    OGA430CREG(_cContrato, 1) 
	OGA430CREG(_cContrato, 2) 
Return

/*/{Protheus.doc} fVldValor
    Função para validar se o valor de notas marcas é maior que o complemento
    @type  Static Function
    @author rafael.voltz
    @since 05/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return lRet, logical, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function fVldValor(nVlrCompl, nTotalAssoc)
    Local cAliasQry     := GetNextAlias()    
    Local lRet          := .T.
    
    BeginSQL Alias cAliasQry
        SELECT SUM(ASSOCIA) AS ASSOCIA
          FROM %temp-table:_cTabDocs%
         WHERE MARCA != ''
    EndSql

    nTotalAssoc := (cAliasQry)->ASSOCIA

    If nTotalAssoc > nVlrCompl        
        lRet := .F.
    EndIf

    (cAliasQry)->(dbCloseArea())

Return lRet
