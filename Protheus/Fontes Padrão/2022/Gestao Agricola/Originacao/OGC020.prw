#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OGC020.CH"

#DEFINE CRLF CHR(13)+CHR(10)
Static __oMBrowse 	:= Nil
Static __aCpsBrow	:= {}
Static __cTabPen	:= ""
Static __cPergunte 	:= "OGC020"
Static __cNoExec	:= .f.
Static __oArqTemp   := Nil

/*{Protheus.doc} OGC020
Consulta Agenda de Take-UP
@author 	ana.olegini
@since 		20/03/2017
@version 	1.0
*/
Function OGC020(cCodRes, cCodCtr, nPosArot, lAutomato)
	Local aColumns		:= {}	
	Local aWdCol        := {}
	Local nI            := 0
	Local aFilBrowCtr   := {}
    Local nCont         := 0
	Private cCadastro   := STR0002
	Private aRotina     := MenuDef()
	Private _cQueryRel  := ""
	Private _nMxWdTPA   := 0
	Private _nMxWdTHV   := 0
	Private _CancHist   := .F.
    Private  __cProc    := ""
    Private aRotinaAuto   := {"OGC020TKP",; //[01]"Efetuar Take-Up"
                              "OGC020APR",; //[02]"Aprovar Take up"
                              "OGC020CAG",; //[03]"Cancelar Agenda"
                              "OGC020CRV",; //[04]"Cancelar Reserva"
                              "OGC020CAR",; //[05]"Cancelar Agenda/Reserva"
                              "OGC020EST"}  //[06]Estornar Take-Up                              

    Default cCodRes   := ""
    Default cCodCtr   := ""
    Default nPosArot  := 0
    Default lAutomato := .F.

    Private _cCodRes   := cCodRes   /* Automacao */
    Private _cCodCtr   := cCodCtr   /* Automacao */
    Private _lAutomato := lAutomato /* Automacao */

    //-- Proteção de Código - Se parametro não existe realiza a validação.
	If !(SuperGetMv('MV_AGRA001', , .F.))
		Help(" ",1,"OGC010AGRA001") //O parâmetro MV_AGRA001(Novo Conceito UBA) está desativado.
		Return(.F.)
	Endif

	If !IsInCallStack("OGC140") .AND. .NOT. Pergunte(__cPergunte, .T.)
        Return()
    EndIf

    aColumns  := OGC020COL()			//--Cria campos para browser
    __cTabPen := OGC020TAB() 			//--Cria a tabela temporaria com os campos informando no array "__aCpsBrow"
    lContinua := OGC020REG(.F.) 		//--Carrega a tabela temporaria caso possua informações gravadas

    If !_lAutomato

        //--Cria Browser
        __oMBrowse := FWMBrowse():New()		//--Fornece um objeto do tipo grid que permite a exibição de dados do tipo array, texto, tabela e query.        
    
        For nCont := 1  to Len(__aCpsBrow) 
            aADD(aFilBrowCtr,  {__aCpsBrow[nCont][2], __aCpsBrow[nCont][1], __aCpsBrow[nCont][3], __aCpsBrow[nCont][4], __aCpsBrow[nCont][5], __aCpsBrow[nCont][6] } )
        Next nCont


        For nI := 1 to Len(__aCpsBrow)
        If ( __aCpsBrow[nI][2] != "TPACEIT") .AND. ( __aCpsBrow[nI][2] != "TPHVI")
            aAdd(aWdCol, __aCpsBrow[nI][4] )
        ElseIf (__aCpsBrow[nI][2] == "TPACEIT")
            If (_nMxWdTPA <= 30)
                aAdd(aWdCol, _nMxWdTPA )   // Pega o maior comprimento para este campo
            Else
                aAdd(aWdCol, 30)
            EndIF
        ElseIf (__aCpsBrow[nI][2] == "TPHVI")
            If (_nMxWdTHV <= 30)
                aAdd(aWdCol, _nMxWdTHV )  // Pega o maior comprimento para este campo
            Else
                aAdd(aWdCol, 30)
            EndIF
        EndIf
        Next nI
    
    
        //--Se retorno dos registros for
        If lContinua            
            __oMBrowse:SetAlias(__cTabPen)   										//--Indica o alias da tabela que será utilizada no Browse
            __oMBrowse:SetColumns(aColumns)											//--Indica os campos que serão adicionados as colunas do Browse.
            __oMBrowse:SetDescription(STR0002)			 	//"Agenda Take-Up"		//--Indica a descrição do Browse
            __oMBrowse:SetMenuDef(STR0001)					//'OGC020'				//--Indica o programa que será utilizado para a carga do menu funcional
            __oMBrowse:SetOnlyFields({'*'})
            __oMBrowse:SetWidthColumns(aWdCol)
            __oMBrowse:SetFieldFilter(aFilBrowCtr)
            __oMBrowse:SetProfileID("OGC020")
            __oMBrowse:Activate()            
        EndIf
    Else
        (__cTabPen)->(dbSetOrder(1))
        (__cTabPen)->(dbGoTop())
        bBlock := &( "{ |a| " + aRotinaAuto[ nPosArot] + "(a) }" )
        Eval( bBlock, _lAutomato )
    EndIf

	//remove a temp-table
	AGRDLTPTB(__oArqTemp)
Return

/*{Protheus.doc} MenuDef
Função de Menu

@author 	ana.olegini
@since 		20/03/2017
@version 	1.0
@param 		Nil
@return 	aRotina - Array - Array com as opções disponiveis de ações relacionadas
*/
Static Function MenuDef()
	Local aRotina 	:= {}
	/*
	Parametros do array a Rotina - MENU:
		1. Nome a aparecer no cabecalho
		2. Nome da Rotina associada
		3. Reservado
		4. Tipo de Transa+"o a ser efetuada:
		4.1 - Pesquisa e Posiciona em um Banco de Dados
		4.2 - Simplesmente Mostra os Campos
		4.3 - Inclui registros no Bancos de Dados
		4.4 - Altera o registro corrente
		4.5 - Remove o registro corrente do Banco de Dados
		5. Nivel de acesso
		6. Habilita Menu Funcional
	*/
	aAdd( aRotina,{STR0003	,"OGC020TKP",0,3,0,.F.})	//"Efetuar Take-Up"
	aAdd( aRotina,{STR0019  ,"OGC020APR",0,4,0,.F.})	//"Aprovar Take up"
	aAdd( aRotina,{STR0004	,"OGC020IMP",0,3,0,.F.})	//"Emitir Docs. Aprovação"
	aAdd( aRotina,{STR0005	,"OGC020VIN",0,3,0,.F.})	//"Vincular Documento"
	aAdd( aRotina,{STR0022  ,"OGC020CAG",0,4,0,.F.})	//"Cancelar Agenda"
	aAdd( aRotina,{STR0036  ,"OGC020CRV",0,4,0,.F.})	//"Cancelar Reserva"
	aAdd( aRotina,{STR0037  ,"OGC020CAR",0,5,0,.F.})	//"Cancelar Agenda/Reserva"
	aAdd( aRotina,{STR0039  ,"OGC020EST",0,4,0,.F.})	//Estornar Take-Up
	aAdd( aRotina,{STR0040  ,"OGC020IMP2",0,5,0,.F.})	//"Relatório Agendamento"
	aAdd( aRotina,{STR0041  ,"OGC020HIS",0,10, 0, Nil } )   //#Histórico
	aAdd( aRotina,{STR0044  ,"OGC020MAIL", 0, 3, 0, Nil } )   //#Enviar e-mail	

Return( aRotina )

/*{Protheus.doc} OGC020COL
Função Tela Temporaria

@author 	ana.olegini
@since 		20/03/2017
@version 	1.0
@return 	aColumns - Array - Array com os campos da tela
*/
Static Function OGC020COL(  )
	Local aColumns		:= {}

    //------------------------------------------------------------------
    //*** ARRAY PRINCIPAL COM OS CAMPOS PARA A TELA DE PENDENCIAS E TRB
    //********* REALIZAR MANUTENÇÕES AQUI
    //-------------    [1]         [2]                 [3]                         [4]                         [5] 			            [6]
	__aCpsBrow := { {STR0006 , "RESERVA"	, TamSX3( "DXP_CODIGO" )[3]	, TamSX3( "DXP_CODIGO" )[1]	, TamSX3( "DXP_CODIGO" )[2]	, PesqPict("DXP","DXP_CODIGO") 	},;	//"Reserva"
                    {AgrTitulo("DXP_DATAGD") , "DTAGEND"	, TamSX3( "DXP_DATAGD" )[3]	, TamSX3( "DXP_DATAGD" )[1]	, TamSX3( "DXP_DATAGD" )[2]	, PesqPict("DXP","DXP_DATAGD") 	},;	//"Data Agendamento"
                    {AgrTitulo("DXP_HORAGD") , "HRAGEND"	, TamSX3( "DXP_HORAGD" )[3]	, TamSX3( "DXP_HORAGD" )[1]	, TamSX3( "DXP_HORAGD" )[2]	, PesqPict("DXP","DXP_HORAGD") 	},;	//"Hora Agendamento"
				    {AgrTitulo("DXP_DATTKP") , "DTTAKEUP"	, TamSX3( "DXP_DATTKP" )[3]	, TamSX3( "DXP_DATTKP" )[1]	, TamSX3( "DXP_DATTKP" )[2]	, PesqPict("DXP","DXP_DATTKP") 	},;	//"Data Take-Up"
                    {AgrTitulo("DXP_HORTKP") , "HRTAKEUP"	, TamSX3( "DXP_HORTKP" )[3]	, TamSX3( "DXP_HORTKP" )[1]	, TamSX3( "DXP_HORTKP" )[2]	, PesqPict("DXP","DXP_HORTKP") 	},;	//"Hora Agend"
				    {STR0008 , "TIPORESV"	, TamSX3( "DXP_TIPRES" )[3] , 20						, TamSX3( "DXP_TIPRES" )[2]	, PesqPict("DXP","DXP_TIPRES") 	},;	//"Tipo Reserva"
				    {STR0009 , "CONTRATO"  	, TamSX3( "DXP_CODCTP" )[3]	, TamSX3( "DXP_CODCTP" )[1]	, TamSX3( "DXP_CODCTP" )[2]	, PesqPict("DXP","DXP_CODCTP")	},;	//"Contrato"
				    {AgrTitulo("NJR_CTREXT") , "CTREXTERNO"	, TamSX3( "NJR_CTREXT" )[3]	, TamSX3( "NJR_CTREXT" )[1]	, TamSX3( "NJR_CTREXT" )[2]	, PesqPict("NJR","NJR_CTREXT") 	},;
				    {STR0010 , "CADENCIA"  	, TamSX3( "NNY_ITEM" )[3]	, TamSX3( "NNY_ITEM" )[1]	, TamSX3( "NNY_ITEM" )[2]	, PesqPict("NNY","NNY_ITEM")  	},; //"Cadência"
				    {STR0011 , "DTENTINI"  	, TamSX3( "NNY_DATINI" )[3]	, TamSX3( "NNY_DATINI" )[1]	, TamSX3( "NNY_DATINI" )[2]	, PesqPict("NNY","NNY_DATINI")  },;	//"Entrega De"
				    {STR0012 , "DTENTFIM"  	, TamSX3( "NNY_DATFIM" )[3]	, TamSX3( "NNY_DATFIM" )[1]	, TamSX3( "NNY_DATFIM" )[2]	, PesqPict("NNY","NNY_DATFIM")  },;	//"Entrega Até"
				    {STR0013 , "TIPOALGO"  	, TamSX3( "NJR_TIPALG" )[3]	, TamSX3( "NJR_TIPALG" )[1]	, TamSX3( "NJR_TIPALG" )[2]	, PesqPict("NJR","NJR_TIPALG")  },; //"Tipo Algodão"
	                {STR0042 , "TPACEIT"  	, TamSX3( "DXP_LJCLI" )[3]	, 255	, 0	, "@!"  },;	//"Tipos Aceitáveis"
	                {STR0043 , "TPHVI"   	, TamSX3( "DXP_NOMCLI" )[3]	, 255	, 0	, "@!"  },;	//"Qualidade Algodão"
				    {STR0014 , "QTDENTRE"  	, TamSX3( "NNY_QTDINT" )[3]	, TamSX3( "NNY_QTDINT" )[1]	, TamSX3( "NNY_QTDINT" )[2]	, PesqPict("NNY","NNY_QTDINT")  },; //"Qtd. Entregue"
				    {STR0015 , "QTDRESER"  	, TamSX3( "NNY_TKPQTD" )[3]	, TamSX3( "NNY_TKPQTD" )[1]	, TamSX3( "NNY_TKPQTD" )[2]	, PesqPict("NNY","NNY_TKPQTD")  },; //"Qtd. Reservada"
				    {STR0020 , "QTDTAKUP"  	, TamSX3( "NNY_TKPQTD" )[3]	, TamSX3( "NNY_TKPQTD" )[1]	, TamSX3( "NNY_TKPQTD" )[2]	, PesqPict("NNY","NNY_TKPQTD")  },;	//"Qtd. Take-Up"
                    {AgrTitulo("DXP_CLAEXT") , "CLASCLIE"  	, TamSX3( "DXP_CLAEXT" )[3]	, TamSX3( "DXP_CLAEXT" )[1]	, TamSX3( "DXP_CLAEXT" )[2]	, PesqPict("DXP","DXP_CLAEXT")  },;	//"Classificador Cliente"
	                {AgrTitulo("DXP_CNOEXT") , "NOMEEXT"  	, TamSX3( "DXP_CNOEXT" )[3]	, TamSX3( "DXP_CNOEXT" )[1]	, TamSX3( "DXP_CNOEXT" )[2]	, PesqPict("NNA","DXP_CNOEXT")  },;	//"Classificador Cliente"
	                {AgrTitulo("DXP_CLIENT") , "CODCLI"  	, TamSX3( "DXP_CLIENT" )[3] , TamSX3( "DXP_CLIENT" )[1] , TamSX3( "DXP_CLIENT" )[2] , PesqPict("DXP","DXP_CLIENT")  },;	//"Nome Cliente"
	                {AgrTitulo("DXP_LJCLI")  , "LOJACLI"  	, TamSX3( "DXP_LJCLI"  )[3]	, TamSX3( "DXP_LJCLI"  )[1]	, TamSX3( "DXP_LJCLI"  )[2]	, PesqPict("DXP","DXP_LJCLI" )  },;	//"Loja Cliente"
	                {AgrTitulo("DXP_NOMCLI") , "NOMECLI"  	, TamSX3( "DXP_NOMCLI" )[3]	, TamSX3( "DXP_NOMCLI" )[1]	, TamSX3( "DXP_NOMCLI" )[2]	, PesqPict("DXP","DXP_NOMCLI")  } }	//"Nome Cliente"

	// Montando a coluna para tela

	nCol := 1
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[nCol]:SetData({||RESERVA})				//--Coluna da Temporaria
	aColumns[nCol]:SetTitle(__aCpsBrow[nCol][1]) 			//--Titulo da Coluna
	aColumns[nCol]:SetSize(__aCpsBrow[nCol][4])			//--Tamanho do Campo
	aColumns[nCol]:SetDecimal(__aCpsBrow[nCol][5])		//--Tamanho do Decimal
	aColumns[nCol]:SetPicture(__aCpsBrow[nCol][6])		//--Picture
	aColumns[nCol]:SetAlign(CONTROL_ALIGN_LEFT)		//--Define alinhamento


	nCol++   //2
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[nCol]:SetData({||DTAGEND})				//--Coluna da Temporaria
	aColumns[nCol]:SetTitle(__aCpsBrow[nCol][1]) 			//--Titulo da Coluna
	aColumns[nCol]:SetSize(__aCpsBrow[nCol][4])			//--Tamanho do Campo
	aColumns[nCol]:SetDecimal(__aCpsBrow[nCol][5])		//--Tamanho do Decimal
	aColumns[nCol]:SetPicture(__aCpsBrow[nCol][6])		//--Picture
	aColumns[nCol]:SetAlign(CONTROL_ALIGN_LEFT)		//--Define alinhamento

	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[nCol]:SetData({||HRAGEND})				//--Coluna da Temporaria
	aColumns[nCol]:SetTitle(__aCpsBrow[nCol][1]) 			//--Titulo da Coluna
	aColumns[nCol]:SetSize(__aCpsBrow[nCol][4])			//--Tamanho do Campo
	aColumns[nCol]:SetDecimal(__aCpsBrow[nCol][5])		//--Tamanho do Decimal
	aColumns[nCol]:SetPicture(__aCpsBrow[nCol][6])		//--Picture
	aColumns[nCol]:SetAlign(CONTROL_ALIGN_LEFT)		//--Define alinhamento


	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[nCol]:SetData({||DTTAKEUP})				//--Coluna da Temporaria
	aColumns[nCol]:SetTitle(__aCpsBrow[nCol][1]) 			//--Titulo da Coluna
	aColumns[nCol]:SetSize(__aCpsBrow[nCol][4])			//--Tamanho do Campo
	aColumns[nCol]:SetDecimal(__aCpsBrow[nCol][5])		//--Tamanho do Decimal
	aColumns[nCol]:SetPicture(__aCpsBrow[nCol][6])		//--Picture
	aColumns[nCol]:SetAlign(CONTROL_ALIGN_LEFT)		//--Define alinhamento

	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[nCol]:SetData({||HRTAKEUP})				//--Coluna da Temporaria
	aColumns[nCol]:SetTitle(__aCpsBrow[nCol][1]) 			//--Titulo da Coluna
	aColumns[nCol]:SetSize(__aCpsBrow[nCol][4])			//--Tamanho do Campo
	aColumns[nCol]:SetDecimal(__aCpsBrow[nCol][5])		//--Tamanho do Decimal
	aColumns[nCol]:SetPicture(__aCpsBrow[nCol][6])		//--Picture
	aColumns[nCol]:SetAlign(CONTROL_ALIGN_LEFT)		//--Define alinhamento

	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[nCol]:SetData({||TIPORESV})				//--Coluna da Temporaria
	aColumns[nCol]:SetTitle(__aCpsBrow[nCol][1]) 			//--Titulo da Coluna
	aColumns[nCol]:SetSize(__aCpsBrow[nCol][4])			//--Tamanho do Campo
	aColumns[nCol]:SetDecimal(__aCpsBrow[nCol][5])		//--Tamanho do Decimal
	aColumns[nCol]:SetPicture(__aCpsBrow[nCol][6])		//--Picture
	aColumns[nCol]:SetAlign(CONTROL_ALIGN_LEFT)		//--Define alinhamento

	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[nCol]:SetData({||CONTRATO})				//--Coluna da Temporaria
	aColumns[nCol]:SetTitle(__aCpsBrow[nCol][1]) 			//--Titulo da Coluna
	aColumns[nCol]:SetSize(__aCpsBrow[nCol][4])			//--Tamanho do Campo
	aColumns[nCol]:SetDecimal(__aCpsBrow[nCol][5])		//--Tamanho do Decimal
	aColumns[nCol]:SetPicture(__aCpsBrow[nCol][6])		//--Picture
	aColumns[nCol]:SetAlign(CONTROL_ALIGN_LEFT)		//--Define alinhamento

	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[nCol]:SetData({||CTREXTERNO})				//--Coluna da Temporaria
	aColumns[nCol]:SetTitle(__aCpsBrow[nCol][1]) 			//--Titulo da Coluna
	aColumns[nCol]:SetSize(__aCpsBrow[nCol][4])			//--Tamanho do Campo
	aColumns[nCol]:SetDecimal(__aCpsBrow[nCol][5])		//--Tamanho do Decimal
	aColumns[nCol]:SetPicture(__aCpsBrow[nCol][6])		//--Picture
	aColumns[nCol]:SetAlign(CONTROL_ALIGN_LEFT)		//--Define alinhamento
   

	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[nCol]:SetData({||CADENCIA})				//--Coluna da Temporaria
	aColumns[nCol]:SetTitle(__aCpsBrow[nCol][1]) 			//--Titulo da Coluna
	aColumns[nCol]:SetSize(__aCpsBrow[nCol][4])			//--Tamanho do Campo
	aColumns[nCol]:SetDecimal(__aCpsBrow[nCol][5])		//--Tamanho do Decimal
	aColumns[nCol]:SetPicture(__aCpsBrow[nCol][6])		//--Picture
	aColumns[nCol]:SetAlign(CONTROL_ALIGN_LEFT)		//--Define alinhamento

	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[nCol]:SetData({||DTENTINI})				//--Coluna da Temporaria
	aColumns[nCol]:SetTitle(__aCpsBrow[nCol][1]) 			//--Titulo da Coluna
	aColumns[nCol]:SetSize(__aCpsBrow[nCol][4])			//--Tamanho do Campo
	aColumns[nCol]:SetDecimal(__aCpsBrow[nCol][5])		//--Tamanho do Decimal
	aColumns[nCol]:SetPicture(__aCpsBrow[nCol][6])		//--Picture
	aColumns[nCol]:SetAlign(CONTROL_ALIGN_LEFT)		//--Define alinhamento

	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[nCol]:SetData({||DTENTFIM})				//--Coluna da Temporaria
	aColumns[nCol]:SetTitle(__aCpsBrow[nCol][1]) 		//--Titulo da Coluna
	aColumns[nCol]:SetSize(__aCpsBrow[nCol][4])			//--Tamanho do Campo
	aColumns[nCol]:SetDecimal(__aCpsBrow[nCol][5])		//--Tamanho do Decimal
	aColumns[nCol]:SetPicture(__aCpsBrow[nCol][6])		//--Picture
	aColumns[nCol]:SetAlign(CONTROL_ALIGN_LEFT)		    //--Define alinhamento

	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[nCol]:SetData({||TIPOALGO})				//--Coluna da Temporaria
	aColumns[nCol]:SetTitle(__aCpsBrow[nCol][1]) 		//--Titulo da Coluna
	aColumns[nCol]:SetSize(__aCpsBrow[nCol][4])			//--Tamanho do Campo
	aColumns[nCol]:SetDecimal(__aCpsBrow[nCol][5])		//--Tamanho do Decimal
	aColumns[nCol]:SetPicture(__aCpsBrow[nCol][6])		//--Picture
	aColumns[nCol]:SetAlign(CONTROL_ALIGN_LEFT)		    //--Define alinhamento

	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[ncol]:SetData({||TPACEIT})				//--Coluna da Temporaria
	aColumns[ncol]:SetTitle(__aCpsBrow[nCol][1]) 	//--Titulo da Coluna
	aColumns[ncol]:SetSize(__aCpsBrow[nCol][4])		//--Tamanho do Campo
	aColumns[ncol]:SetDecimal(__aCpsBrow[nCol][5])	//--Tamanho do Decimal
	aColumns[ncol]:SetPicture(__aCpsBrow[nCol][6])	//--Picture
	aColumns[ncol]:SetAlign(CONTROL_ALIGN_LEFT)		//--Define alinhamento

	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[ncol]:SetData({||TPHVI})				//--Coluna da Temporaria
	aColumns[ncol]:SetTitle(__aCpsBrow[nCol][1]) 	//--Titulo da Coluna
	aColumns[ncol]:SetSize(__aCpsBrow[nCol][4])		//--Tamanho do Campo
	aColumns[ncol]:SetDecimal(__aCpsBrow[nCol][5])	//--Tamanho do Decimal
	aColumns[ncol]:SetPicture(__aCpsBrow[nCol][6])	//--Picture
	aColumns[ncol]:SetAlign(CONTROL_ALIGN_LEFT)		//--Define alinhamento


	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[nCol]:SetData({||QTDENTRE})				//--Coluna da Temporaria
	aColumns[nCol]:SetTitle(__aCpsBrow[nCol][1]) 		//--Titulo da Coluna
	aColumns[nCol]:SetSize(__aCpsBrow[nCol][4])			//--Tamanho do Campo
	aColumns[nCol]:SetDecimal(__aCpsBrow[nCol][5])		//--Tamanho do Decimal
	aColumns[nCol]:SetPicture(__aCpsBrow[nCol][6])		//--Picture
	aColumns[nCol]:SetAlign(CONTROL_ALIGN_RIGHT)		//--Define alinhamento

	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[nCol]:SetData({||QTDRESER})				//--Coluna da Temporaria
	aColumns[nCol]:SetTitle(__aCpsBrow[nCol][1]) 		//--Titulo da Coluna
	aColumns[nCol]:SetSize(__aCpsBrow[nCol][4])			//--Tamanho do Campo
	aColumns[nCol]:SetDecimal(__aCpsBrow[nCol][5])		//--Tamanho do Decimal
	aColumns[nCol]:SetPicture(__aCpsBrow[nCol][6])		//--Picture
	aColumns[nCol]:SetAlign(CONTROL_ALIGN_RIGHT)		//--Define alinhamento

	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[nCol]:SetData({||QTDTAKUP})				//--Coluna da Temporaria
	aColumns[nCol]:SetTitle(__aCpsBrow[nCol][1]) 		//--Titulo da Coluna
	aColumns[nCol]:SetSize(__aCpsBrow[nCol][4])			//--Tamanho do Campo
	aColumns[nCol]:SetDecimal(__aCpsBrow[nCol][5])		//--Tamanho do Decimal
	aColumns[nCol]:SetPicture(__aCpsBrow[nCol][6])		//--Picture
	aColumns[nCol]:SetAlign(CONTROL_ALIGN_RIGHT)		//--Define alinhamento

	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[nCol]:SetData({||CLASCLIE})				//--Coluna da Temporaria
	aColumns[nCol]:SetTitle(__aCpsBrow[nCol][1]) 		//--Titulo da Coluna
	aColumns[nCol]:SetSize(__aCpsBrow[nCol][4])		//--Tamanho do Campo
	aColumns[nCol]:SetDecimal(__aCpsBrow[nCol][5])	//--Tamanho do Decimal
	aColumns[nCol]:SetPicture(__aCpsBrow[nCol][6])	//--Picture
	aColumns[nCol]:SetAlign(CONTROL_ALIGN_LEFT)		//--Define alinhamento

	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[nCol]:SetData({||NOMEEXT})				//--Coluna da Temporaria
	aColumns[nCol]:SetTitle(__aCpsBrow[nCol][1]) 	//--Titulo da Coluna
	aColumns[nCol]:SetSize(__aCpsBrow[nCol][4])		//--Tamanho do Campo
	aColumns[nCol]:SetDecimal(__aCpsBrow[nCol][5])	//--Tamanho do Decimal
	aColumns[nCol]:SetPicture(__aCpsBrow[nCol][6])	//--Picture
	aColumns[nCol]:SetAlign(CONTROL_ALIGN_LEFT)		//--Define alinhamento

	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[nCol]:SetData({||CODCLI})				//--Coluna da Temporaria
	aColumns[nCol]:SetTitle(__aCpsBrow[nCol][1]) 	//--Titulo da Coluna
	aColumns[nCol]:SetSize(__aCpsBrow[nCol][4])		//--Tamanho do Campo
	aColumns[nCol]:SetDecimal(__aCpsBrow[nCol][5])	//--Tamanho do Decimal
	aColumns[nCol]:SetPicture(__aCpsBrow[nCol][6])	//--Picture
	aColumns[nCol]:SetAlign(CONTROL_ALIGN_LEFT)		//--Define alinhamento

	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[nCol]:SetData({||LOJACLI})				//--Coluna da Temporaria
	aColumns[nCol]:SetTitle(__aCpsBrow[nCol][1]) 	//--Titulo da Coluna
	aColumns[nCol]:SetSize(__aCpsBrow[nCol][4])		//--Tamanho do Campo
	aColumns[nCol]:SetDecimal(__aCpsBrow[nCol][5])	//--Tamanho do Decimal
	aColumns[nCol]:SetPicture(__aCpsBrow[nCol][6])	//--Picture
	aColumns[nCol]:SetAlign(CONTROL_ALIGN_LEFT)		//--Define alinhamento

	nCol++
	AAdd(aColumns,FWBrwColumn():New())
	nCol := Len(aColumns)
	aColumns[ncol]:SetData({||NOMECLI})				//--Coluna da Temporaria
	aColumns[ncol]:SetTitle(__aCpsBrow[nCol][1]) 	//--Titulo da Coluna
	aColumns[ncol]:SetSize(__aCpsBrow[nCol][4])		//--Tamanho do Campo
	aColumns[ncol]:SetDecimal(__aCpsBrow[nCol][5])	//--Tamanho do Decimal
	aColumns[ncol]:SetPicture(__aCpsBrow[nCol][6])	//--Picture
	aColumns[ncol]:SetAlign(CONTROL_ALIGN_LEFT)		//--Define alinhamento

Return(aColumns)

/*{Protheus.doc} OGC020TAB
Função para realizar a criação da tabela temporária

@author 	ana.olegini
@since 		20/03/2017
@version 	1.0
@return 	cTabela 	- Caracter	- Retorna a tabela criada
*/
Function OGC020TAB()
    Local nCont 	:= 0
    Local cTabela	:= ''
	Local aStrTab 	:= {}	//Estrutura da tabela

    //-- Busca no __aCpsBrow as propriedades para criar as colunas
    For nCont := 1 to Len(__aCpsBrow)
        aADD(aStrTab,{__aCpsBrow[nCont][2], __aCpsBrow[nCont][3], __aCpsBrow[nCont][4], __aCpsBrow[nCont][5] })
    Next nCont
   	//-- Tabela temporaria de pendencias
   	cTabela  := GetNextAlias()
   	//-- A função AGRCRTPTB está no fonte AGRUTIL01 - Funções Genericas
    __oArqTemp := AGRCRTPTB(cTabela, {aStrTab, {{"","RESERVA"}}})
Return cTabela

/*{Protheus.doc} OGC020REG
Função para realizar a busca dos registros para consulta

@author 	ana.olegini
@since 		20/03/2017
@version 	1.0
@param 		lF12, logico, (Identifica se pergunte foi ativo pela tecla F12)
*/
Function OGC020REG(lF12)
	Local cTemp 	:= GetNextAlias()
	Local cTipoResv := ""
	Local lVazio 	:= .T.
	Local nQtdResv  := 0
	Local nQtdTkup	:= 0

	Local dDtaIni := ''		//*
	Local dDtaFim := ''		//*
	Local cStatus := ''		//*
	Local cTakFis := ''				//NJR_TKPFIS
	Local cQuery   := ""
	Local aQuery   := {}    

	//Se for chamada da tecla F12	    
    If lF12 .AND. .NOT. Pergunte(__cPergunte, .T.)
           Return(.T.)
    EndIf            

	//--Variaveis dos parametros
	dDtaIni := mv_par01					//*Data Agenda De
	dDtaFim := mv_par02					//*Data Agenda Até
	cStatus := cValToChar(mv_par03)		//*Status da Reserva
	cTakFis := cValToChar(mv_par04) 	//*Take-Up Físico
   __cProc  := cValToChar(mv_par05)     //*Processo

	//--Deleta tudo da temporaria para realizar nova busca
	DbSelectArea((__cTabPen))
	DbGoTop()
	If DbSeek((__cTabPen)->RESERVA)
		While .Not. (__cTabPen)->(Eof())
			If RecLock((__cTabPen),.f.)
				(__cTabPen)->(DbDelete())
				(__cTabPen)->(MsUnlock())
			EndIf

			(__cTabPen)->( dbSkip() )
		EndDo
	EndIF

	//--Query dados para consulta
	cQuery := " SELECT DISTINCT DXP.DXP_FILIAL, DXP.DXP_STATUS, DXP.DXP_CODIGO, "
	cQuery +=        " DXP_DATAGD, DXP_HORAGD, DXP_DATTKP, DXP_HORTKP, "
	cQuery +=        " DXP.DXP_TIPRES, DXP.DXP_CODCTP, DXP.DXP_ITECAD, "
	cQuery +=        " DXP.DXP_CLIENT, DXP.DXP_LJCLI, "
	cQuery +=        " NNY.NNY_ITEM,   NNY.NNY_DATINI, NNY.NNY_DATFIM,  NNY.NNY_QTDINT, NNY.NNY_TKPQTD, "
	cQuery +=        " NJR.NJR_TIPALG, NJR.NJR_TKPFIS,NJR.NJR_CTREXT, "
	cQuery +=        " DXP.DXP_CLAEXT, DXP.DXP_CLAINT "
	aAdd(aQuery, cQuery)
	cQuerySum := ", DXQ.DXQ_APROVA,	SUM(DXQ.DXQ_PSLIQU) DXQ_PSLIQU "

	cQuery := ""
	cQuery +=  " FROM " + RetSqlName("DXP") + " DXP"
	cQuery += " LEFT JOIN " + RetSqlName("DXQ") + " DXQ ON DXQ.D_E_L_E_T_ = '' "
	cQuery +=  									     " AND DXQ.DXQ_FILIAL = DXP.DXP_FILIAL "
	cQuery +=  									     " AND DXQ.DXQ_CODRES = DXP.DXP_CODIGO "
	cQuery += " INNER JOIN " + RetSqlName("NNY") + " NNY ON NNY.D_E_L_E_T_ = '' "
	cQuery +=  									      " AND NNY.NNY_FILIAL = DXP.DXP_FILIAL "
	cQuery +=  									      " AND NNY.NNY_CODCTR = DXP.DXP_CODCTP "
	cQuery +=  									      " AND NNY.NNY_ITEM   = DXP.DXP_ITECAD "
	cQuery += " INNER JOIN " + RetSqlName("NJR") + " NJR ON NJR.D_E_L_E_T_ = '' "
	cQuery +=  									      " AND NJR.NJR_FILIAL = DXP.DXP_FILIAL "
	cQuery +=  									      " AND NJR.NJR_CODCTR = DXP.DXP_CODCTP "
	cQuery +=  									      " AND NJR.NJR_TKPFIS = '"+ cTakFis +"'"
	cQuery +=                                         " AND (NJR.NJR_STATUS = 'A' OR NJR.NJR_STATUS = 'I')"
	cQuery += " WHERE DXP.D_E_L_E_T_ 	= '' "
	cQuery +=   " AND DXP.DXP_FILIAL 	= '"+xFilial("DXP")+"'"
	If .NOT. Empty(dDtaIni)
		cQuery +=  									  " AND DXP.DXP_DATAGD >= '"+ DTOS(dDtaIni) +"'"
	EndIf
	If .NOT. Empty(dDtaFim)
		cQuery +=  									  " AND DXP.DXP_DATAGD <= '"+ DTOS(dDtaFim) +"'"
	EndIf
	If .NOT. Empty(cStatus)
		cQuery +=  " AND DXP.DXP_STATUS = '"+ cStatus +"'"
	EndIf

    /* Se automação busca registro exato */
    If _lAutomato
        cQuery +=  " AND DXP.DXP_CODIGO = '"+ _cCodRes +"'"
        cQuery +=  " AND DXP.DXP_CODCTP = '"+ _cCodCtr +"'"
    EndIf

    aAdd(aQuery, cQuery)
    cQuery := aQuery[1] + cQuerySum + aQuery[2]
    _cQueryRel := aQuery[1] + aQuery[2]

	cQuery += " GROUP BY DXP.DXP_FILIAL, DXP.DXP_STATUS, DXP.DXP_CODIGO, "
	cQuery +=          " DXP_DATAGD, DXP_HORAGD, DXP_DATTKP, DXP_HORTKP, "
	cQuery +=          " DXP.DXP_TIPRES, DXP.DXP_CODCTP, DXP.DXP_ITECAD, "
	cQuery +=          " DXP.DXP_CLIENT, DXP.DXP_LJCLI, "
	cQuery +=          " NNY.NNY_ITEM,	 NNY.NNY_DATINI,  NNY.NNY_DATFIM,  NNY.NNY_QTDINT,  NNY.NNY_TKPQTD, "
	cQuery +=          " NJR.NJR_TIPALG, NJR.NJR_TKPFIS,NJR.NJR_CTREXT, "
	cQuery +=          " DXP.DXP_CLAEXT, DXP.DXP_CLAINT,  DXQ.DXQ_APROVA   "
	cQuery := ChangeQuery( cQuery )
	If select(cTemp) <> 0
		(cTemp)->(dbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTemp,.T.,.T.)

	//--Alimenta a tabela temporária.
	While .Not. (cTemp)->(Eof()) .AND. (cTemp)->DXP_FILIAL == xFilial("DXP")
		//--Data de agenda e contrato não podem estar vazios.
		If .NOT. Empty((cTemp)->DXP_DATAGD) .AND. .NOT. Empty((cTemp)->DXP_CODCTP)
			//--Verifica tipo da Reserva
			cTipoResv := ""
			If (cTemp)->DXP_TIPRES == '1'
				cTipoResv := STR0016	//"Reserva de Contrato"
			ElseIf (cTemp)->DXP_TIPRES == '2'
				cTipoResv := STR0017	//"Reserva Específica"
			EndIf

			//--Se codigo da reserva for igual ao codigo da qury soma o valor de qtd de take-up
			//--Só posso ter uma linha da mesma reserva, a query traz duas linhas por filtro do
			//--campo Aprovar (DXQ_APROVA)
			If (__cTabPen)->RESERVA == (cTemp)->DXP_CODIGO
				nQtdResv += (cTemp)->DXQ_PSLIQU

				//--Se aprovado - soma
				If (cTemp)->DXQ_APROVA == "1"
					nQtdTkup += (cTemp)->DXQ_PSLIQU
				EndIf
			Else
				nQtdResv := (cTemp)->DXQ_PSLIQU
				//--Se aprovado - soma
				If (cTemp)->DXQ_APROVA == "1" .AND. (cTemp)->DXP_STATUS == '2'
					nQtdTkup := (cTemp)->DXQ_PSLIQU
				EndIf
			EndIf

			//--Se codigo da reserva for igual ao codigo da qury sai fora.
			//--Só posso ter uma linha da mesma reserva, a query traz duas linhas
			//--Pelo filtro do campo Aprovar (DXQ_APROVA)
			If .NOT. (__cTabPen)->RESERVA == (cTemp)->DXP_CODIGO
				RecLock((__cTabPen),.T.)
					(__cTabPen)->RESERVA	:= (cTemp)->DXP_CODIGO
					(__cTabPen)->DTAGEND	:= STOD((cTemp)->DXP_DATAGD)
					(__cTabPen)->HRAGEND	:= (cTemp)->DXP_HORAGD
					(__cTabPen)->DTTAKEUP	:= STOD((cTemp)->DXP_DATTKP)
					(__cTabPen)->HRTAKEUP	:= (cTemp)->DXP_HORTKP
					(__cTabPen)->TIPORESV	:= cTipoResv
					(__cTabPen)->CONTRATO	:= (cTemp)->DXP_CODCTP
					(__cTabPen)->CTREXTERNO	:= (cTemp)->NJR_CTREXT
					(__cTabPen)->CADENCIA	:= (cTemp)->NNY_ITEM
					(__cTabPen)->DTENTINI	:= STOD((cTemp)->NNY_DATINI)
					(__cTabPen)->DTENTFIM	:= STOD((cTemp)->NNY_DATFIM)
					(__cTabPen)->TIPOALGO	:= (cTemp)->NJR_TIPALG
					(__cTabPen)->QTDENTRE	:= (cTemp)->NNY_QTDINT - (cTemp)->NNY_TKPQTD
					(__cTabPen)->QTDRESER	:= nQtdResv
					(__cTabPen)->QTDTAKUP	:= nQtdTkup
					(__cTabPen)->CLASCLIE	:= (cTemp)->DXP_CLAEXT
					(__cTabPen)->NOMEEXT    := Posicione("NNA",1,xFilial("NNA")+(cTemp)->DXP_CLAEXT,"NNA_NOME")
					(__cTabPen)->CODCLI     := (cTemp)->DXP_CLIENT
					(__cTabPen)->LOJACLI    := (cTemp)->DXP_LJCLI
					(__cTabPen)->NOMECLI    := Posicione("SA1", 1, xFilial("SA1")+(cTemp)->(DXP_CLIENT+DXP_LJCLI), "A1_NOME")
					(__cTabPen)->TPACEIT    := GetQualidade((cTemp)->DXP_CODCTP, 1)
					(__cTabPen)->TPHVI      := GetQualidade((cTemp)->DXP_CODCTP, 2)
				MsUnlock()

			ElseIf (__cTabPen)->RESERVA == (cTemp)->DXP_CODIGO
				RecLock((__cTabPen),.F.)
					(__cTabPen)->QTDRESER := nQtdResv //If( Empty((cTemp)->DXQ_PSLIQU),0, (cTemp)->DXQ_PSLIQU )
					(__cTabPen)->QTDTAKUP := nQtdTkup
				MsUnlock()
			EndIf

			lVazio := .F.
		EndIf

		(cTemp)->( dbSkip() )
	EndDo
	(cTemp)->(dbCloseArea())

	(__cTabPen)->(dbGoTop())
	
    If !_lAutomato .and. ValType(__oMBrowse) == "O"
        __oMBrowse:UpdateBrowse()
    EndIf

	//--Se não tiver registros apresenta msg
	If lVazio .and. !_lAutomato
		Help(" ",1,"OGC020VAZIO") //Não há dados para ser listados.
		Return(.F.)
	EndIf

Return(.T.)

/*{Protheus.doc} OGC020VIN
Vincular documento - chamada da funcao do agrutil01 MsDocument

@author 	ana.olegini
@since 		24/03/2017
@version 	1.0
*/
Function OGC020VIN(cVarRand)
	Local aAreaL := GetArea()

	if __cNoExec //Método alternativo para correção do BUG - Não podemos usar a opção "4" que dá erro.
	   __cNoExec := .f.
	   return(.t.)
	endif

	DbSelectArea("DXP")
	DbSetOrder(1)
	If DbSeek(xFilial("DXP")+(__cTabPen)->RESERVA)
		__cNoExec = MsDocument("DXP",Recno(),4)
	EndIf

	RestArea(aAreaL)

Return (.T.)

/*{Protheus.doc} OGC020TKP
função efetuar Take up

@author 	marcelo.wesan
@since 		28/03/2017
@version 	1.0
*/
Function OGC020TKP()
	Local lContinua		:= .T.
	Local aAreaAtu		:= GetArea()
	Local aAreaNJR		:= NJR->(GetArea())
	Local aAreaN9A		:= N9A->(GetArea())
	Local aAreaDXP		:= DXP->(GetArea())

	//Vars do ExecView
	Local cTitulo			:= STR0023	//"Reservas"
	Local cPrograma			:= "AGRA720"
	Local nOperation 		:= MODEL_OPERATION_UPDATE
	Local nRetorno       := 0
	Local cReserva		 := (__cTabPen)->RESERVA
	Local cContrato      := (__cTabPen)->CONTRATO
	Local aItens	:= {}
	Local aItensBkp := {}
	Local cIdRegra := ""

	Private _cTkpFis		:= "SIM"
	Private aFardos	:= {}

    //--Lendo  a NJR para obter o valor do Take up Fisico 1 ou 2 //    
    NJR->( dbSetOrder( 1 ) )
    If NJR->(dbSeek(xFilial("NJR")+ cContrato))
     	If NJR->NJR_TKPFIS == "2"
     		_cTkpFis := "NAO"
     	EndIf

	    dbSelectArea( "N9A" )
	    N9A->( dbSetOrder( 1 ) ) //N9A_FILIAL+N9A_CODCTR+N9A_ITEM+N9A_SEQPRI
	    If dbSeek( FwxFilial("N9A")+cContrato) //(__cTabPen)->CADENCIA
	    	While !(N9A->(Eof())) .And. N9A->N9A_CODCTR == cContrato
	    		If Empty(N9A->N9A_TES)
    				cIdRegra := N9A->N9A_SEQPRI		    			

	    			lContinua := .F.
	    			Exit
	    		EndIf
	    		N9A->(DbSkip())
	    	End
	    EndIf

    EndIf

    If lContinua
	    //--Lendo  //
	    dbSelectArea( "DXP" )
	    DXP->( dbSetOrder( 1 ) )
	    If .Not. dbSeek( xFilial( "DXP" ) + cReserva )
	       lContinua := .F.
	    EndIf
	Else
		If !Empty(cIdRegra)
			Help(NIL, NIL, STR0051, NIL, STR0052 + allTrim(cIdRegra) + STR0053, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Deverá ser informada a operação fiscal/TES no Contrato."}) //"Atenção" ## "A operação fiscal/TES da regra " ## " não foi informada."  
		EndIf
	EndIf

	If lContinua

		If DXP->DXP_STATUS == "1"
			nOper    := MODEL_OPERATION_UPDATE
			aItensBkp := OGX014QRY(Nil, cReserva ) // Executa a query para buscar as reservas com agendamentos
			
            If !_lAutomato            
                nRetorno := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/ , , 12/*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )
            Else                
                /* INI Código exclusivo para automação */
                oModelAuto := FWLoadModel("AGRA720")
                oModelAuto:SetOperation(nOper)
	            oModelAuto:Activate()
                If oModelAuto:VldData()    // Valida o Model
                    oModelAuto:CommitData()
                    oModelAuto:DeActivate() // Desativa o model
					oModelAuto:Destroy() // Destroi o objeto do model
                EndIf
                /* FIM Código exclusivo para automação */
            EndIf
			aItens	  := OGX014QRY(Nil, cReserva ) // Executa a query para buscar as reservas com agendamentos
			//Grava o histórico de alteração no agendamento, se houver
			If !_lAutomato
                OGX014HIST(aItens, aItensBkp, nOperation)
            EndIf
		    If nRetorno == 0
				OGC020REG(.f.)
			ElseIf nRetorno == 1
				lContinua := .F.
			EndIf
		Else
			nOperation 	:= MODEL_OPERATION_VIEW
			cTitulo     := STR0021 //Reserva - Visualizar
			nRetorno 	:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/ , , 12/*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ )
		EndIf

	EndIf

	RestArea( aAreaAtu )
	RestArea( aAreaNJR )
	RestArea( aAreaN9A )
	RestArea( aAreaDXP )

Return

/*{Protheus.doc} OGC020APR
função aprovar Take up

@author 	marcelo.wesan
@since 		29/03/2017
@version 	1.0
*/
Function OGC020APR()// APROVA TAKE UP
    Local aArea		:= GetArea()
	Local oModel    := FwLoadModel("AGRA720")
	Local lRetorno  := .F.
	Local oStruN7I  := FwFormStruct(1, "N7I") // Carrega a estrutura da tabela de Blocos Reprovados
	Local cTakFis   := cValToChar(mv_par04)		
	
	DXP->(dbSetOrder(1))
	If  DXP->(DbSeek( xFilial( "DXP" ) + (__cTabPen)->RESERVA + (__cTabPen)->CONTRATO ))
		If cTakFis = "1"
		   If Empty(DXP->DXP_CLAINT) .OR. Empty(DXP->DXP_CLAEXT)
			   Help(,,STR0018,,STR0049, 1, 0 ) //OGC020CMP Os campos classificador interno e externo são obrigatorios.
		       RestArea( aArea )
		       Return .F.
		    EndIf  
		ElseIf cTakFis = "2"
			If  Empty(DXP->DXP_CLAINT)
		      Help(,,STR0018,,STR0050, 1, 0 ) //OGC020CMPC O campo classificador interno é obrigatório. Informe o classificador interno.
		      RestArea( aArea )
		      Return .F.
			EndIf
		EndIf
		oModel:AddGrid("N7IMASTER", "DXPMASTER", oStruN7I) // Adiciona ao model a grid de Blocos Reprovados para adição ao histórico
		oModel:GetModel("N7IMASTER"):SetOptional(.T.) // Seta o submodelo como opcional
		oModel:SetRelation("N7IMASTER", { {"N7I_FILIAL", "xFilial('N7I')" }, { "N7I_CODRES", "DXP_CODIGO" } }, N7I->( IndexKey( 1 ) ) ) // Seta a relação do submodelo com o modelo pai
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()		
	    
        FwMsgRun(, {|tSay| lRetorno := AGRA720APT(oModel)}, STR0047) // # "Aprovando Take-up..."        
	  	
		//Valida se devemos fazer o vinculo automático de acordo com o parametro (sx6)
		If SuperGetMV("MV_AGRO038",.F.,.F.)	
			OGC020FIX(DXP->DXP_ITECAD)
		EndIf

		If lRetorno		  	
            If !_lAutomato
                Help(" ",1,"OGC020TA")	//take up aprovado com sucesso!
            EndIf
	   	Else
		  	Help(" ",1,"OGC020TNA")	//não foi possivel aprovar o Take up
		EndIf
	EndIf
 RestArea( aArea )
Return

/*{Protheus.doc} OGC020IMP
Impressao do termo de reserva - precisa passar a reserva posicionada no browse

@author janaina.duarte
@since 04/04/2017
@version 1.0
@type function
*/
Function OGC020IMP()
    If !Empty((__cTabPen)->RESERVA)
    	UBAR007((__cTabPen)->RESERVA)
    EndIf
Return

/*{Protheus.doc} OGC020CAG
Função de cancelar agenda - deleta reservas sem blocos

@author 	ana.olegini
@since 		26/05/2017
@version 	1.0
@return 	lRet	- lógico	- retorno .T. verdadeiro .F. falso
*/
Function OGC020CAG()
	Local aArea		:= GetArea()
	Local oModel 	:= FwLoadModel("AGRA720") // Carrega o modelo da rotina de Reservas	
	Local oModelDXP	:= Nil
	Local lRetorno	:= .T.
	Local nOperation:= 0
	
	DXP->(dbSetOrder(1))
	If  DXP->(DbSeek( xFilial( "DXP" ) + (__cTabPen)->RESERVA + (__cTabPen)->CONTRATO ))
		//*Se status for igual a 1="Aguardando Take-Up" faz condições
		If DXP->DXP_STATUS == '1'	//1="Aguardando Take-Up"


			dbSelectArea("DXQ")
			dbSetOrder(1)
			//*Se reserva não possuir blocos - deleta a reserva.
			If  .NOT. DbSeek( xFilial( "DXQ" ) + (__cTabPen)->RESERVA )
				//*Salva a operação
				nOperation := 5
				//*Operação Update
				oModel:SetOperation(5)	//5 - Delete
				//*Verificando se o Activate Falhou
		   		If !oModel:Activate()
					cMsg := oModel:GetErrorMessage()[3] + oModel:GetErrorMessage()[6]
					Help( ,,STR0018,,cMsg, 1, 0 ) //"AJUDA"
					Return(.F.)
				EndIf
				//Commit do modelo - delete
				lRetorno := oModel:CommitData()
			Else	//*Se reserva não possuir blocos - deleta a reserva.
				//*Salva a operação
				nOperation := 4
				//*Operação Update
				oModel:SetOperation(4)
				//*Verificando se o Activate Falhou
		   		If !oModel:Activate()
					cMsg := oModel:GetErrorMessage()[3] + oModel:GetErrorMessage()[6]
					Help( ,,STR0018,,cMsg, 1, 0 ) //"AJUDA"
					Return(.F.)
				EndIf

				//*Limpa os campos de data e hora da agenda
				oModelDXP := oModel:GetModel("DXPMASTER")
				oModelDXP:ClearField("DXP_DATAGD")
				oModelDXP:ClearField("DXP_HORAGD")
				oModelDXP:ClearField("DXP_DATTKP")
				oModelDXP:ClearField("DXP_HORTKP")

				//*Verificando se o VlDData não falhou
				If lRetorno := oModel:VldData()
					lRetorno := oModel:CommitData()
				EndIf
			EndIf

			//*Apresenta mensagem se VldData falhou
			If .NOT. lRetorno
				// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
				aErro := oModel:GetErrorMessage()
				AutoGrLog( STR0025 + ' [' + AllToChar( aErro[1] ) + ']' )	//"Id do formulário de origem:"
				AutoGrLog( STR0026 + ' [' + AllToChar( aErro[2] ) + ']' )	//"Id do campo de origem: "
				AutoGrLog( STR0027 + ' [' + AllToChar( aErro[3] ) + ']' )	//"Id do formulário de erro: "
				AutoGrLog( STR0028 + ' [' + AllToChar( aErro[4] ) + ']' )	//"Id do campo de erro: "
				AutoGrLog( STR0029 + ' [' + AllToChar( aErro[5] ) + ']' )	//"Id do erro: "
				AutoGrLog( STR0030 + ' [' + AllToChar( aErro[6] ) + ']' )	//"Mensagem do erro: "
				AutoGrLog( STR0031 + ' [' + AllToChar( aErro[7] ) + ']' )	//"Mensagem da solução: "
				AutoGrLog( STR0032 + ' [' + AllToChar( aErro[8] ) + ']' )   //"Valor atribuído: "
				AutoGrLog( STR0033 + ' [' + AllToChar( aErro[9] ) + ']' )	//"Valor anterior: "
				MostraErro()
			EndIf

			If .NOT. _CancHist //Caso tenha cancelado o motivo de cancelamento
				If lRetorno .AND. nOperation == 4		//**Alteração
					If !_lAutomato
                        Help(" ",1,"OGC020CAG4")		//Agendamento Cancelado com sucesso. # Agendamento cancelado com sucesso. Reserva possui blocos vinculados.
                    EndIf
                ElseIf lRetorno .AND. nOperation == 5	//**Exclusão
					Help(" ",1,"OGC020CAG5")		//Agendamento cancelado e Reserva excluída com sucesso. # Agendamento cancelado e Reserva excluída com sucesso. Reserva sem blocos vinculados.
				EndIf
			EndIf
			//*Desativação da classe
			oModel:DeActivate()
			//*Fechando tabela
			DXP->(dbCloseArea())
			//*Atualiza consulta
			OGC020REG(.f.)
			//*Restaurando Area
			RestArea(aArea)

		Else	//*Se status for igual a 2="Take-Up Efetuado" não faz nenhuma ação.
			Help(" ",1,"OGC020STSCAN")	//Reserva já possui movimentações e não poderá ser alterada. # Somente Reservas com status "Aguardando Take-Up" podem ser alteradas.
		EndIf
	EndIf
	//*Restaurando Area
	RestArea(aArea)
Return(lRetorno)

/*{Protheus.doc} OGC020CRV
Função de cancelar reserva:
	- deleta os blocos;
	- sem agenda deleta reserva.

@author 	ana.olegini
@since 		26/05/2017
@version 	1.0
@return 	lRet	- lógico	- retorno .T. verdadeiro .F. falso
*/
Function OGC020CRV()
	Local aArea		:= GetArea()
	Local oModel 	:= FwLoadModel("AGRA720") // Carrega o modelo da rotina de Reservas	
	Local oModelDXQ	:= Nil
	Local lRetorno	:= .T.
	Local nOperation:= 0
	Local nX		:= 0
	Local nLinha	:= 0
	Local aBloco	:= {}

	//reativa as operações de gravar os blocos
	oModel:getModel("DXQDETAIL"):SetNoInsertLine(.F.)
	oModel:getModel("DXQDETAIL"):SetNoDeleteLine(.F.)
	
	DXP->(dbSetOrder(1))
	If  DXP->(DbSeek( xFilial( "DXP" ) + (__cTabPen)->RESERVA + (__cTabPen)->CONTRATO ))
		//*Se status for igual a 1="Aguardando Take-Up" faz condições
		If DXP->DXP_STATUS == '1'	//1="Aguardando Take-Up"


			dbSelectArea("DXQ")
			dbSetOrder(1)
			//*Se reserva possuir blocos - deleta os blocos da reserva
			If DbSeek( xFilial( "DXQ" ) + (__cTabPen)->RESERVA )
				//*Se possuir data e hora de agendamento para a reserva - deleta blocos
				If .NOT. Empty(DXP->DXP_DATAGD) .AND. .NOT. Empty(DXP->DXP_HORAGD)
					//*Salva a operação
					nOperation := 4
					//*Operação Update
					oModel:SetOperation(4)	//4 - Alteração
					//*Verificando se o Activate Falhou
			   		If !oModel:Activate()
						cMsg := oModel:GetErrorMessage()[3] + oModel:GetErrorMessage()[6]
						Help( ,,STR0018,,cMsg, 1, 0 ) //"AJUDA"
						Return(.F.)
					EndIf

					//*Exclui os blocos da reserva
					oModelDXQ := oModel:GetModel("DXQDETAIL")
					nLinha := oModelDXQ:GetLine()
					For nX := 1 to oModelDXQ:Length()
						oModelDXQ:GoLine( nX )
						AAdd(aBloco, { oModelDXQ:GetValue("DXQ_SAFRA") , oModelDXQ:GetValue("DXQ_BLOCO") })
						//*Deleta as linhas existentes
						oModelDXQ:DeleteLine()
					Next nX
					oModelDXQ:GoLine( nLinha )

					//*Verificando se o VlDData não falhou
					If lRetorno := oModel:VldData()
						//*Verifica se o CommitData não falhou
						lRetorno := oModel:CommitData()
					EndIf
				Else	//*Se não possuir data e hora de agendamento para a reserva - deleta reserva
					//*Salva a operação
					nOperation := 5
					//*Operação Update
					oModel:SetOperation(5)	//5 - Delete
					//*Verificando se o Activate Falhou
		   			If !oModel:Activate()
						cMsg := oModel:GetErrorMessage()[3] + oModel:GetErrorMessage()[6]
						Help( ,,STR0018,,cMsg, 1, 0 ) //"AJUDA"
						Return(.F.)
					EndIf
					//Commit do modelo - delete
					lRetorno := oModel:CommitData()
				EndIf

			else
				Help(" ",1,"OGC020STCN2") //A reserva não possui blocos reservados.
				Return(.F.)
			EndIf //DXQ

			//*Apresenta mensagem se VldData falhou
			If .NOT. lRetorno
				// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
				aErro := oModel:GetErrorMessage()
				AutoGrLog( STR0025 + ' [' + AllToChar( aErro[1] ) + ']' )	//"Id do formulário de origem:"
				AutoGrLog( STR0026 + ' [' + AllToChar( aErro[2] ) + ']' )	//"Id do campo de origem: "
				AutoGrLog( STR0027 + ' [' + AllToChar( aErro[3] ) + ']' )	//"Id do formulário de erro: "
				AutoGrLog( STR0028 + ' [' + AllToChar( aErro[4] ) + ']' )	//"Id do campo de erro: "
				AutoGrLog( STR0029 + ' [' + AllToChar( aErro[5] ) + ']' )	//"Id do erro: "
				AutoGrLog( STR0030 + ' [' + AllToChar( aErro[6] ) + ']' )	//"Mensagem do erro: "
				AutoGrLog( STR0031 + ' [' + AllToChar( aErro[7] ) + ']' )	//"Mensagem da solução: "
				AutoGrLog( STR0032 + ' [' + AllToChar( aErro[8] ) + ']' )   //"Valor atribuído: "
				AutoGrLog( STR0033 + ' [' + AllToChar( aErro[9] ) + ']' )	//"Valor anterior: "
				MostraErro()
			EndIf

			If .NOT. _CancHist //Caso tenha cancelado o motivo de cancelamento
				If lRetorno .AND. nOperation == 4		//**Alteração
					If !_lAutomato
                        Help(" ",1,"OGC020CRV4")		//Reserva cancelada com sucesso. # Reserva cancelada com sucesso. Reserva possui agendamento.
                    EndIf
                ElseIf lRetorno .AND. nOperation == 5	//**Exclusão
					Help(" ",1,"OGC020CRV5")		//Reserva cancelada e excluída com sucesso. # Reserva cancelada e excluída com sucesso. Reserva sem agendamento e sem blocos.
				EndIf
			EndIf
			//*Desativação da classe
			oModel:DeActivate()
			//*Fechando tabela
			DXP->(dbCloseArea())
			//*Atualiza consulta
			OGC020REG(.f.)
		Else	//*Se status for igual a 2="Take-Up Efetuado" não faz nenhuma ação.
			Help(" ",1,"OGC020STSCAN")	//Reserva já possui movimentações e não poderá ser alterada. # Somente Reservas com status "Aguardando Take-Up" podem ser alteradas.
		EndIf
	EndIf //DXP

	//*Restaurando Area
	RestArea(aArea)
Return(lRetorno)

/*{Protheus.doc} OGC020CAR
Função de cancelar agenda e excluir reserva.

@author 	ana.olegini
@since 		26/05/2017
@version 	1.0
@return 	lRet	- lógico	- retorno .T. verdadeiro .F. falso
*/
Function OGC020CAR()
	Local aArea		:= GetArea()
	Local oModel 	:= FwLoadModel("AGRA720") // Carrega o modelo da rotina de Reservas	
	Local lRetorno	:= .T.
	Local nOperation:= 0	
	
	DXP->(dbSetOrder(1))
	If  DXP->(DbSeek( xFilial( "DXP" ) + (__cTabPen)->RESERVA + (__cTabPen)->CONTRATO ))
		//*Se status for igual a 1="Aguardando Take-Up" faz condições
		If DXP->DXP_STATUS == '1'	//1="Aguardando Take-Up"


			dbSelectArea("DXQ")
			dbSetOrder(1)
			//*Se reserva possuir blocos - deleta os blocos da reserva
			If DbSeek( xFilial( "DXQ" ) + (__cTabPen)->RESERVA )

				//*Salva a operação
				nOperation := 5
				//*Operação Delete
				oModel:SetOperation(5)	//5 - Delete
				//*Verificando se o Activate Falhou
		   		If !oModel:Activate()
					cMsg := oModel:GetErrorMessage()[3] + oModel:GetErrorMessage()[6]
					Help( ,,STR0018,,cMsg, 1, 0 ) //"AJUDA"
					Return(.F.)
				EndIf

				//*Verifica se o CommitData não falhou
				lRetorno := oModel:CommitData()
			Else
				//*Salva a operação
				nOperation := 5
				//*Operação Delete
				oModel:SetOperation(5)	//5 - Delete
				//*Verificando se o Activate Falhou
		   		If !oModel:Activate()
					cMsg := oModel:GetErrorMessage()[3] + oModel:GetErrorMessage()[6]
					Help( ,,STR0018,,cMsg, 1, 0 ) //"AJUDA"
					Return(.F.)
				EndIf

				//*Verifica se o CommitData não falhou
				lRetorno := oModel:CommitData()
			EndIf

			//*Apresenta mensagem se VldData falhou
			If .NOT. lRetorno
				// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
				aErro := oModel:GetErrorMessage()
				AutoGrLog( STR0025 + ' [' + AllToChar( aErro[1] ) + ']' )	//"Id do formulário de origem:"
				AutoGrLog( STR0026 + ' [' + AllToChar( aErro[2] ) + ']' )	//"Id do campo de origem: "
				AutoGrLog( STR0027 + ' [' + AllToChar( aErro[3] ) + ']' )	//"Id do formulário de erro: "
				AutoGrLog( STR0028 + ' [' + AllToChar( aErro[4] ) + ']' )	//"Id do campo de erro: "
				AutoGrLog( STR0029 + ' [' + AllToChar( aErro[5] ) + ']' )	//"Id do erro: "
				AutoGrLog( STR0030 + ' [' + AllToChar( aErro[6] ) + ']' )	//"Mensagem do erro: "
				AutoGrLog( STR0031 + ' [' + AllToChar( aErro[7] ) + ']' )	//"Mensagem da solução: "
				AutoGrLog( STR0032 + ' [' + AllToChar( aErro[8] ) + ']' )   //"Valor atribuído: "
				AutoGrLog( STR0033 + ' [' + AllToChar( aErro[9] ) + ']' )	//"Valor anterior: "
				MostraErro()
			EndIf

			If .NOT. _CancHist //Caso tenha cancelado o motivo de cancelamento
				If lRetorno .AND. nOperation == 5 .and. !_lAutomato		//**Exclusão
					Help(" ",1,"OGC020CAR5")		//Agenda cancelada e Reserva excluída com sucesso. # Reserva excluída com sucesso.
				EndIf
			EndIf

			//*Desativação da classe
			oModel:DeActivate()
			//*Fechando tabela
			DXP->(dbCloseArea())
			//*Atualiza consulta
			OGC020REG(.f.)

		Else	//*Se status for igual a 2="Take-Up Efetuado" não faz nenhuma ação.
			Help(" ",1,"OGC020STSCAN")	//Reserva já possui movimentações e não poderá ser alterada. # Somente Reservas com status "Aguardando Take-Up" podem ser alteradas.
		EndIf
	EndIf //DXP

	//*Restaurando Area
	RestArea(aArea)
Return(lRetorno)

/*{Protheus.doc} OGC020IMP
Impressao do Relatório de Agendamento do TAke-up

@author Marcelo Ferrari
@since 23/06/2017
@version 1.0
@type function
*/
Function OGC020IMP2()
    If !Empty(( __cTabPen ))
    	UBAR008(( _cQueryRel ))
    EndIf
Return


/*{Protheus.doc} OGC020EST
Estorna os take-up efetuado
@author jean.schulze
@since 23/06/2017
@version undefined

@type function
*/
Function OGC020EST()
	Local aArea	   := GetArea()
	Local oModel   := FwLoadModel("AGRA720")
	Local oStruN7I := FwFormStruct(1, "N7I") // Carrega a estrutura da tabela de Blocos Reprovados
	Local lRetorno := .F.
	
    DXP->(DbSetOrder(1))
	If  DXP->(DbSeek( xFilial( "DXP" ) + (__cTabPen)->RESERVA + (__cTabPen)->CONTRATO ))

		//*Se status for igual a 1="Aguardando Take-Up" faz condições
		If DXP->DXP_STATUS == '2'	//2="Take-Up Efetuado"


			oModel:AddGrid("N7IMASTER", "DXPMASTER", oStruN7I) // Adiciona ao model a grid de Blocos Reprovados para adição ao histórico
			oModel:GetModel("N7IMASTER"):SetOptional(.T.) // Seta o submodelo como opcional
			oModel:SetRelation("N7IMASTER", { {"N7I_FILIAL", "xFilial('N7I')" }, { "N7I_CODRES", "DXP_CODIGO" } }, N7I->( IndexKey( 1 ) ) ) // Seta a relação do submodelo com o modelo pai
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
			oModel:Activate()

			FwMsgRun(, {|tSay| lRetorno := AGRA720APT(oModel, .t.)}, STR0048) // # "Estornando Take-up..."             
            If lRetorno .AND. .NOT. _CancHist  .AND. !_lAutomato
                Help(" ",1,"OGC020ESTOK")	//Take up Estornado com sucesso!			  
            EndIf                        

		Else	//*Se status for igual a 1="Aguardando Take-Up" não faz nenhuma ação.
			Help(" ",1,"OGC020STSEST")	//Reserva já possui movimentações e não poderá ser alterada. # Somente Reservas com status "Aguardando Take-Up" podem ser alteradas.
		EndIf
	endif

	//*Restaurando Area
	RestArea(aArea)
Return(lRetorno)

/** {Protheus.doc} OGC020HIS
Apresenta em tela de Historico do contrato

@param:     Nil
@author:    Marcelo Wesan
@since:     29/06/2017
@Uso:       OGC020HIS
*/
Function OGC020HIS()

	Local cReserva		:= (__cTabPen)->RESERVA
	Local cChave := FwxFilial('DXP') + cReserva

	AGRHISTTABE("DXP",cChave)
Return

/** {Protheus.doc} OGC020HIS
   Monta a string para o texto das culunas Tipos Aceitáveis e Qualidade Algodão
@param:     Nil
@author:    Marcelo Ferrari
@since:     05/07/2017
@Param: cContr : Char Numero do contrato / nTp Número 1 para Tipos aceitáveis e 2 para Qualidade Algodão
@Return Char
@Uso:       OGC020
*/
Static Function GetQualidade(cContr, nTp)
   Local cRet      := ""
   Local cStr := ""

   If nTp == 1
	    //Classificação aceitável do contrato
	    cQryN7E := GetSqlAll( "SELECT N7E_FILIAL, N7E_CODCTR, N7E_TIPACE, N7E_PERCEN, N7E_ORDEM " + ;
	                          " FROM " + retSqlName('N7E') + " N7E "  + ;
	                          " WHERE N7E_FILIAL = '"+xFilial("N7E")+"' " + ;
	                          " AND N7E_CODCTR = '" + cContr + "' " + ;
	                          " AND D_E_L_E_T_ = '' " + ;
	                          " ORDER BY N7E_ORDEM " )

        cStr := ""
        While !( (cQryN7E)->(EOF()) )
           cStr := cStr + (cQryN7E)->N7E_TIPACE + IIF( !Empty((cQryN7E)->N7E_PERCEN), " (" + AllTrim(STR((cQryN7E)->N7E_PERCEN))+"%), ", ", " )
           (cQryN7E)->(DbSkip())
        End
        cStr := SubStr(cStr, 1 , Len(cStr)-2)
        cRet := cStr

        If (Len(cStr) > _nMxWdTPA)
           _nMxWdTPA := Len(cStr)
        EndIf
   ElseIf nTp = 2
        cQryN7H := GetSqlAll( "SELECT N7H_CAMPO, N7H_HVIDES, N7H_VLRINI, N7H_VLRFIM " + ;
                              " FROM " + retSqlName('N7H') + " N7H " + ;
                              " WHERE N7H_FILIAL = '"+xFilial("N7H")+"' " + ;
                              " AND N7H_CODCTR = '" + cContr + "' " + ;
                              " AND D_E_L_E_T_ = '' " + ;
                              " ORDER BY N7H_ITEM " )

        cStr := ""
        While !( (cQryN7H)->(EOF()) )
           cStr := cStr + AllTrim((cQryN7H)->N7H_HVIDES) + " (" + AllTrim(STR((cQryN7H)->N7H_VLRINI))+" - " + AllTrim(STR((cQryN7H)->N7H_VLRFIM)) + "), "
           (cQryN7H)->(DbSkip())
        End
        cStr := SubStr(cStr, 1 , Len(cStr)-2)
        cRet := cStr

        If (Len(cStr) > _nMxWdTHV)
           _nMxWdTHV := Len(cStr)
        EndIf

   EndIf

Return cRet

/*{Protheus.doc} OGC020MAIL
//Função chamada via menu que abre a tela de envio.
de e-mail.
@author roney.maia
@since 25/08/2017
@version 6
@type function
*/
Function OGC020MAIL()

	Local cEmails 	:= "" // E-mails de envio, ou seja, os destinatários. ! Não obrigatório
	Local cBody	 	:= "" // Corpo da mensagem, caso exista. ! Não obrigatório	
	Local cChaveFt	:= "DXP_CODIGO = '" + (__cTabPen)->RESERVA + "'" // Chave para trazer somente os dados referente ao registro posicionado. ! Obrigatório
	Local cProcess	:= __cProc // 001 Código do processo. ! Obrigatório	
	Local aRet		:= {}
	Local aArea		:= GetArea()
	Local cMsg		:= ""

	dbSelectArea("DXP") // Seleciona a area desejada

	If Posicione('DXP', 1, xFilial("DXP") + (__cTabPen)->RESERVA, "DXP_STATUS") == '1'
		Help(" ",1,"OGC020MAIL") // O take-up deve ser aprovado para realizar o envio de e-mail.
	Else
		cEmails := Posicione('DXP', 1, xFilial("DXP") + (__cTabPen)->RESERVA, "DXP_EMAIL") // Obtem os emails da reserva para repassar a tela de envio de email

		aRet := OGX017(cEmails, cBody, __cTabPen, cChaveFt, cProcess) // Chama a tela de envio de email, passando os emails e o corpo da mensagem, alias e a chave referente ao filtro.

	    If .NOT. Select("SX2") > 0 // Se a SX2 estiver fechada, reabre a mesma
		     dbSelectArea("SX2")
		EndIf

		If .NOT. Empty(aRet) // Caso houve retorno, realiza a gravação dos dados
		    cMsg += STR0045 + AllTrim(aRet[1][1]) + CRLF
	        cMsg += STR0046 + AllTrim(aRet[1][2]) + CRLF
			AGRGRAVAHIS(,,,,{"DXP",xFilial("DXP")+(__cTabPen)->RESERVA,"4",cMsg}) //Alteraradmin
		EndIf
     EndIf

	 RestArea(aArea)

Return

/*/{Protheus.doc} OGC020FIX()
	Realiza o vinculo automático dos fardinhos a fixação
	@type  Function
	@author mauricio.joao
	@since 14/03/2019
	@version 1.0
	@param cCodCad, character, codigo da cadencia
	@return .t./.f., logical, retorna se foi feito ou não
	/*/
 Function OGC020FIX(cCodCad)
 Local oModel as Object
 Local oStrNN8 as Object
 Local lAuto as Logical
 Local nLinNN8 as numeric
 Local aCadecias as Array

 Private _LALGODAO as Logical

 _LALGODAO := .T.

oModel := FwLoadModel('OGA570')
oStrNN8 := oModel:GetModel('NN8VISUL')
lAuto := .T.
nLinNN8 := 0
aCadecias := {}

oModel:SetOperation( 4 ) //alteração
oModel:Activate()

If .NOT. Empty(oStrNN8:Length())
	For nLinNN8 := 1 To oStrNN8:Length()
		
		//se houver mais de uma cadencia pra mesma fixação, retorna falso
		If aScan(aCadecias, oModel:GetValue("NN8VISUL", "NN8_CODCAD",nLinNN8) ) > 0
			Help(, , STR0055 , , STR0056, 1, 0, , , , , , {STR0057})
			//"Vinculo Não Realizado" ## "O vinculo dos Fardinhos com a fixação não será realizada automaticamente, por existir mais de uma fixação no Cronograma de Entrega."
			//"Realize o vinculo manualmente."
			Return .F.
		EndIf

		Aadd(aCadecias, oModel:GetValue("NN8VISUL", "NN8_CODCAD",nLinNN8) )

	Next nLinNN8
Else
	Help(, , STR0055 , , STR0058, 1, 0, , , , , , {STR0059})
	//"Vinculo Não Realizado" ## "O vinculo dos Fardinhos com a fixação não será realizada automaticamente, por não existir fixação para o Cronograma de Entrega."
	//"Realize a fixação e faça o vinculo manualmente."
	Return .F.
EndIf

If .NOT. oStrNN8:SeekLine({{"NN8_CODCAD",cCodCad}}, .F. , .T.)
	Help(, , STR0055 , , STR0058, 1, 0, , , , , , {STR0059})
	//"Vinculo Não Realizado" ## "O vinculo dos Fardinhos com a fixação não será realizada automaticamente, por não existir fixação para o Cronograma de Entrega."
	//"Realize a fixação e faça o vinculo manualmente."
	Return .F.
Else
	lFard := fSelecFard(nil, lAuto, oModel)

	If oModel:VldData()
		oModel:CommitData()
	EndIf
EndIf

oModel:DeActivate()

Return .T.
